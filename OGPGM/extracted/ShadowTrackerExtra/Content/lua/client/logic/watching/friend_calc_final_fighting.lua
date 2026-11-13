
-- 用于制作 好友 决赛状态逻辑  2018年12月10日   zengzuo 

FriendCalcFinalFighting = FriendCalcFinalFighting or 
{
    UpdateTimerEvent = nil,
	DeltaTimeCount = 1,
	Sum_Second = 0,
	
	Popup_WndExistTime = 10;	--弹窗存在的时间
	Copy_CDTime = 30;			--复制数据的CD时间
	Copy_SumTime = 0;			--复制数据的累计时间，用于和CDTime做比较
	Request_SumTime = 0;		--请求的时间
	is_update_state = false;		--允许弹窗的时候，暂停 UpdateFightingState，uid_forbid_list的状态，需要继续update

	--读取策划配置   刷新第7个安全区的时间（决胜阶段）
	has_initialized_once = false;	--初始化一次
	WatchTotalTime_Savage  = 1760;  --海岛
	WatchTotalTime_Desert  = 1760;  --沙漠
	WatchTotalTime_Forest  = 1290;	--森林
	WatchTotalTime_Vikendi = 1605;  --雪地
	WatchForbidTimeCount = 1000;	--计算是否到下一局的时间
	FriendListReqDuration = 200;        -- 好友请求时间
	Watch_DelayTime = 5;		-- 延迟时间，决胜时刻判定： pass_time - sinceGameTime - Watch_DelayTime > WatchTotalTime 

	uid_teacher = "";
	uid_student_list = {};
	black_list = {};
	intimacy_list = {};
	intimacyInfo_list = {};

	Submit_PlayerData = {};

	req_black_list = false;
	req_teacher_student = false;
	req_intimacy_list = false;
	req_OneTimeTotal = false;
	LastPostEventBattleBeginTime = 0, --最近postEvent时间，用于判断是否同一局

	FCFFBeginInfo_SaveKey = "FCFF_BeginInfo";
}

-- Friend_calc_final_fighting 的 uidList，包含：亲密好友和师徒
FCFF_UidList = {};

-- 最终返回、处理的数据结构
FCFF_InfoList = 
{
-- 	uid = "0";
-- 	gameSubMode = 1000;
-- 	cur_max_segment_level = 10;

-- ----UI显示需要 Begin
-- 	relationship_index = 0;
-- 	player_name = "DefaultName";
-- 	is_in_final_state = false;  -- 是否在决胜阶段
-- ----UI显示需要 End

-- 	online=0;		--在线是1
-- 	teamState=0;	--战斗中是2
-- 	enableWatch=0;	--允许观战是1
-- 	pass_time = 0;
-- 	intimacy_degree = 0;  		-- 亲密度数值（用于排序）
}

--禁止弹窗uid列表及其状态
FCFF_ForbidStateList = 
{
	--uid = "0";
	--forbid_sumTime = 0;
	--forbid_beginTime = "0";
}

--弹窗时间内，不发相同的消息
FCFF_Popup_TimeCountList = 
{
	--uid = "0";
	--time_count = 0;
}

--计时器相关实现  -- begin ----------
function FriendCalcFinalFighting:SetTimer()
	self:RemoveTimer()
	self.UpdateTimerEvent = Timer.InsertTimer(1, function() 
													self:UpdateSumSecond() 
												 end,  true, "" );
end

function FriendCalcFinalFighting:RemoveTimer()
	if self.UpdateTimerEvent~=nil then
		Timer.RemoveTimer(self.UpdateTimerEvent)
		self.UpdateTimerEvent = nil
	end
	FCFF_ForbidStateList = {};
end

function FriendCalcFinalFighting:UpdateSumSecond()
	self.Sum_Second = self.DeltaTimeCount + self.Sum_Second;
	if self.Sum_Second >= 1 then

		--代码更新写在此处
		self.Copy_SumTime = self.Copy_SumTime + self.Sum_Second;
		self.Request_SumTime = self.Request_SumTime + self.Sum_Second;
		FriendCalcFinalFighting:UpdateFightingState(self.Sum_Second);
		FriendCalcFinalFighting:UpdateForbidListState(self.Sum_Second);
		FriendCalcFinalFighting:UpdatePopupTimeCountList(self.Sum_Second);

		self.Sum_Second = 0;
	end
end
--计时器相关实现  -- end ----------


local function ResetLocalValue()
	FriendCalcFinalFighting.Copy_SumTime = 0;
	FriendCalcFinalFighting.Request_SumTime = 0;
	FriendCalcFinalFighting.uid_teacher = "";
	FriendCalcFinalFighting.uid_student_list = {};
	FriendCalcFinalFighting.black_list = {};
	FriendCalcFinalFighting.intimacy_list = {};
	FCFF_ForbidStateList = {};
end

--向其他模块请求数据 
local function req_FromOtherModules()
	if FriendSystem~=nil then
		--黑名单
		FriendSystem.get_black_list_req();
	end
	
	if MasterSystem~=nil then
		--师徒
		MasterSystem.PreRequestMasterInfoList();
	end
	
	if FriendIntimacyModule~=nil then
		--亲密关系
		FriendIntimacyModule.getIntimacyRelationReq();
	end
	FriendCalcFinalFighting.req_OneTimeTotal = true;
end

local function copy_FromOtherModules()
    --大厅 弹出观战窗口 
	if FriendCalcFinalFighting~=nil then
		FriendCalcFinalFighting.black_list = {};
		FriendCalcFinalFighting.black_list = FuncUtil:CopyTable(BP_ARRAY_Friend_ID_Blacklist);
		-- log_tree("FCFF copy: on_req_BlackList = ",FriendCalcFinalFighting.black_list);
		FriendCalcFinalFighting.req_black_list = true;
    end

	--大厅 弹出观战窗口 
    if FriendCalcFinalFighting~=nil then
        --师傅的uid
        FriendCalcFinalFighting.uid_teacher = nil;
        if MasterSystem.my_teacher_uid~=nil and tonumber(MasterSystem.my_teacher_uid)~="0" then
            FriendCalcFinalFighting.uid_teacher = MasterSystem.my_teacher_uid;
        end
       
        --徒弟的uid
        FriendCalcFinalFighting.uid_student_list = {};
        if MasterSystem.my_student_list~=nil and #MasterSystem.my_student_list~=0 then
            for k,v in pairs(MasterSystem.my_student_list) do
                table.insert( FriendCalcFinalFighting.uid_student_list, tostring(v.uid) )
             end
        end
      
        -- log("FCFF copy: on_req_teacher_student, uid_teacher= "..FriendCalcFinalFighting.uid_teacher);
        -- log_tree("FCFF copy: on_req_teacher_student, uid_student_list= ",FriendCalcFinalFighting.uid_student_list);
        FriendCalcFinalFighting.req_teacher_student = true;
    end

	--大厅 弹出观战窗口 
	if FriendCalcFinalFighting~=nil then
		FriendCalcFinalFighting.intimacyInfo_list = {};
		FriendCalcFinalFighting.intimacyInfo_list = FuncUtil:CopyTable(BP_ARRAY_Intimacy_Data);
		-- log_tree("FCFF copy: on_req_IntimacyList = ",FriendCalcFinalFighting.intimacyInfo_list);
		FriendCalcFinalFighting.req_intimacy_list = true;
	end
end


local function ReadDataFromExcel()
	FriendCalcFinalFighting.WatchTotalTime_Savage  =  tonumber( DataMgr.GetSystemConfig("WatchTotalTime_Savage") );  
	FriendCalcFinalFighting.WatchTotalTime_Desert  =  tonumber( DataMgr.GetSystemConfig("WatchTotalTime_Desert") );  
	FriendCalcFinalFighting.WatchTotalTime_Forest  =  tonumber( DataMgr.GetSystemConfig("WatchTotalTime_Forest") );  
	FriendCalcFinalFighting.WatchTotalTime_Vikendi =  tonumber( DataMgr.GetSystemConfig("WatchTotalTime_Vikendi") );

	FriendCalcFinalFighting.WatchForbidTimeCount =  tonumber( DataMgr.GetSystemConfig("WatchForbidTimeCount") );

	local reqMinTime = math.min(FriendCalcFinalFighting.WatchTotalTime_Savage, FriendCalcFinalFighting.WatchTotalTime_Desert)
	reqMinTime = math.min(reqMinTime, FriendCalcFinalFighting.WatchTotalTime_Forest)
	reqMinTime = math.min(reqMinTime, FriendCalcFinalFighting.WatchTotalTime_Vikendi)

	FriendCalcFinalFighting.FriendListReqDuration = math.floor(reqMinTime * 0.5); --断线重连也可以从服务器拉取到亲密好友的数据，设置为0.5
end

-- 判断是否是经典模式 (通过gameMode判断)
local function IsClassicMode(gameMode)
	if 
	gameMode == 101 or  
	gameMode == 102 or
	gameMode == 103 or
	gameMode == 401 or
	gameMode == 402 or 
	gameMode == 403 or
	gameMode == 503 then   --军团战
		return true;
	else
		return false; 
	end
end

--通过gameSubMode -> 地图 -> 比较时间
local function IsInFinalState(gameSubMode,pass_time)
	if gameSubMode==nil or tostring(gameSubMode)=="0" then
		log("Error: FCFF IsClassicMode, Error gameSubMode = "..tostring(gameSubMode));
		return false;
	end

	local row_Info = Client.GetTableData("BTMode",tostring(gameSubMode));
	if row_Info==nil then
		log("Error: FCFF IsClassicMode, Not exist in BTMode with row id = "..tostring(gameSubMode));
		return false;
	end

	local map_id = tonumber(row_Info.MapID);
	local PassTimeDelay = pass_time - FriendCalcFinalFighting.Watch_DelayTime;

	if map_id==1  or 
	   map_id==5 	  then	-- forest	森林	剩余 258s
		if PassTimeDelay - FriendCalcFinalFighting.WatchTotalTime_Forest >= 0 then
			return true;
		end
	elseif map_id==6  or
		   map_id==10 then	-- Desert	沙漠	剩余 420s
		if PassTimeDelay - FriendCalcFinalFighting.WatchTotalTime_Desert >= 0 then
			return true;
		end
	elseif map_id==7 or
		   map_id==13 then	-- Savage	雨林	剩余 420s
		if PassTimeDelay - FriendCalcFinalFighting.WatchTotalTime_Savage >= 0 then
			return true;
		end
	elseif map_id==14 or
		   map_id==15 then	-- Vikendi	雪地	剩余 345s
		if PassTimeDelay - FriendCalcFinalFighting.WatchTotalTime_Vikendi >= 0 then
			return true;
		end
	else
		-- log("IsInFinalState: not Classic mode with id = "..tostring(gameSubMode));
		return false;
	end
end

local function isContainInBlackList(in_uid)
	for i,v in pairs(FriendCalcFinalFighting.black_list) do
		if tonumber(v) == tonumber(in_uid) then
			return true;
		end
	end
	return false;
end

local function isContainInForbidList(in_uid)
	for i,v in pairs(FCFF_ForbidStateList) do
		if tonumber(v.uid) == tonumber(in_uid) then
			return true;
		end
	end
	return false;
end

local function isContainInPopupList(in_uid)
	for i,v in pairs(FCFF_Popup_TimeCountList) do
		if tonumber(v.uid) == tonumber(in_uid) then
			-- log("isContainInPopupList with uid = "..in_uid);
			return true;
		end
	end
	return false;
end

local function GetRelationShipIndexFromList(in_uid)
	if FriendCalcFinalFighting.intimacyInfo_list==nil or 
	#FriendCalcFinalFighting.intimacyInfo_list==0 then
		return 0;
	end

	for i,v in pairs(FriendCalcFinalFighting.intimacyInfo_list) do
		if tonumber(v.gid) == tonumber(in_uid) then
			-- log("GetRelationShipIndexFromList"..v.relation);
			if tonumber(v.relation) > 4 then
				return 0;
			end
			return v.relation;
		end
	end

	return 0;
end

local function MakeRelationFlag(in_uid)
	--0是亲密好友、1是师傅、2是徒弟
	if in_uid~=nil then
		if tonumber(in_uid) == tonumber(FriendCalcFinalFighting.uid_teacher) then
			-- log("MakeRelationFlag 师傅 uid ="..in_uid);
			return 1;
		else
			for k,v in pairs(FriendCalcFinalFighting.uid_student_list) do
				if tonumber(in_uid) == tonumber(v) then
					-- log("MakeRelationFlag 徒弟 uid ="..in_uid);
					return 2;
				end
			end
		end
		return 0;
	end
end

local function RemoveSameElement(uidList)
	--去除相同的元素
	local exist_list = {}
    for i,v in pairs(uidList) do
        exist_list[v] = true
	end
	
	local result = {}
	for i,v in pairs(exist_list) do
		if i~=nil and tostring(i)~="0" and tostring(i)~="" then
			table.insert(result, tostring(i));
		end
	end
	uidList = result;
end


function FriendCalcFinalFighting:Begin(isReconnect)
	self:SetTimer();
	-- EventSystem:registEvent(EVENTTYPE_WATCH_POPUP, EVENTID_POPUP_WATCHWND, FriendCalcFinalFighting.PostEvent);

	if FriendCalcFinalFighting.has_initialized_once==false then
		ReadDataFromExcel();   --读1次配置文件 
		FriendCalcFinalFighting.has_initialized_once = true;
	end

	ResetLocalValue();	-- 初始化一些值
	FriendCalcFinalFighting:Load_FCFFInfo_ToFile();	-- 加载 ForbidStateList	
	self.is_update_state = true;

	--Begin的时候，发送一次请求
	if isReconnect then
		copy_FromOtherModules();
	else
		req_FromOtherModules();
	end
	
	FriendCalcFinalFighting:OnProcess_CallBackData();

	-- log("FCFF FriendCalcFinalFighting:Begin");
end

function FriendCalcFinalFighting:UpdateForbidListState(DeltaTime)
	-- 累加各个forbid_sumTime，大于TimeCount，从forbid列表中剔除 (1000秒保证不在这一局) 
	if FCFF_ForbidStateList==nil or #FCFF_ForbidStateList == 0 then
		return;
	end

	for k,v in pairs(FCFF_ForbidStateList) do
		if v.uid~=nil then
			v.forbid_sumTime = v.forbid_sumTime + DeltaTime;
			-- log("FCFF UpdateForbidListState uid="..v.uid.." ,forbid_sumTime = "..v.forbid_sumTime);
			if tonumber(v.forbid_sumTime) >= tonumber(self.WatchForbidTimeCount) then
				-- log("FCFF FCFF_ForbidStateList.remove value with uid =  "..v.uid);
				table.remove( FCFF_ForbidStateList, k );
			end
		end
	end
end

function FriendCalcFinalFighting:UpdatePopupTimeCountList(DeltaTime)
	if FCFF_Popup_TimeCountList==nil or #FCFF_Popup_TimeCountList == 0 then
		return;
	end

	for k,v in pairs(FCFF_Popup_TimeCountList) do
		if v.uid~=nil and 
		tostring(v.uid)~="0" and 
		tostring(v.uid)~="" then
			v.time_count = v.time_count + DeltaTime;
			if tonumber(v.time_count) >= tonumber(self.Popup_WndExistTime) then
				-- log("FCFF FCFF_ForbidStateList.remove value with uid =  "..v.uid);
				table.remove( FCFF_Popup_TimeCountList, k );
			end
		end
	end
end

function FriendCalcFinalFighting:OnProcess_CallBackData()
	-- log("FCFF:OnProcess_CallBackData");

	--请求 uid_List
	-- self.black_list = {};
	-- self.black_list = FuncUtil:CopyTable(BP_ARRAY_Friend_ID_Blacklist);
					
	-- --亲密好友
	-- self.intimacyInfo_list = {};
	-- self.intimacyInfo_list = FuncUtil:CopyTable(BP_ARRAY_Intimacy_Data);

	self.intimacy_list = {};
	for k,v in pairs(self.intimacyInfo_list) do
		if v.gid~=nil then
			table.insert( self.intimacy_list, v.gid );
		end
	end
	-- log_tree("FCFF self.intimacy_list = ",self.intimacy_list);

	---------- uid的剔除(不在黑名单、禁止列表中)，insert 到 FCFF_UidList列表
	FCFF_UidList = {};
	-- log_tree("FCFF self.uid_teacher = ",self.uid_teacher);
	-- log_tree("FCFF self.uid_student_list = ",self.uid_student_list);

	--师傅
	if self.uid_teacher~=nil and 
	tostring(self.uid_teacher) ~="" and
	tostring(self.uid_teacher) ~="0" and
	isContainInBlackList(self.uid_teacher) == false then
		table.insert( FCFF_UidList, self.uid_teacher ); 
	end

	--徒弟
	for k,v in pairs(self.uid_student_list) do
		if v~=nil and 
		isContainInBlackList(v) == false then
			table.insert( FCFF_UidList, v );
		end
	end

	--亲密好友
	for k,v in pairs(self.intimacy_list) do
		if v~=nil and 
		isContainInBlackList(v) == false and
		GetRelationShipIndexFromList(v) > 0 then
			table.insert( FCFF_UidList, v );
		end
	end

	-- log_tree("FCFF OnProcess_CallBackData FCFF_UidList = ",FCFF_UidList);
	--剔除相同元素
	RemoveSameElement(FCFF_UidList);
end

function FriendCalcFinalFighting:IsInUidList(uid)
	for i, v in ipairs(FCFF_UidList) do
		if v ~= nil and tonumber(uid) == tonumber(v) then
			return true
		end
	end

	return false
end


function FriendCalcFinalFighting:UpdateInLocalClient(DeltaTime)
	--在一个请求CD内，做的更新工作，判定 >= self.WatchForbidTimeCount
	if self.req_black_list == true and
	self.req_intimacy_list == true	and
	self.req_teacher_student == true and
	self.req_OneTimeTotal == true then
		FriendCalcFinalFighting:OnProcess_CallBackData();
		self.req_black_list = false;
		self.req_intimacy_list = false;
		self.req_teacher_student = false;
		self.req_OneTimeTotal = false;
		if FCFF_UidList~=nil and #FCFF_UidList ~= 0 then
			-- 获取数据
			ProfileMgr.GetProfileList(FCFF_UidList, FriendCalcFinalFighting.DataCallback_GetProfile,true,true,nil,true);
		end
	end
	
	-- 只需要在本地客户端更新 pass_time
	if FCFF_InfoList==nil or #FCFF_InfoList == 0 then
		return;
	end

	for k,v in pairs(FCFF_InfoList) do
		if v.uid ~=nil and v.uid~="0" then
			v.pass_time = v.pass_time + DeltaTime;

			-- log("FCFF PassTimeLog, UpdateInLocalClient uid = "..v.uid..",pass_time = "..tostring(v.pass_time));
			if IsInFinalState(v.gameSubMode,v.pass_time) == true then
				v.is_in_final_state = true;  
				-- log("IsInFinalState = true with uid = "..tostring(v.uid));
			end
		end
	end

	--依次判断是否可以弹窗
	for k,v in pairs(FCFF_InfoList) do
		if v.uid ~=nil and 
		v.uid~="0" and
		v.is_in_final_state == true and 
		isContainInForbidList(v.uid) == false and  -- 不在禁止弹窗的名单内   
		isContainInPopupList(v.uid) == false then
			local in_uid = v.uid
			ProfileMgr.GetProfile(in_uid,FriendCalcFinalFighting.CallBack_RefreshPlayerState, true, true);
		end
	end
end


function FriendCalcFinalFighting:UpdateFightingState(DeltaTime)
	if self.is_update_state == true then
		if self.Request_SumTime >= self.FriendListReqDuration then
			req_FromOtherModules();
			self.Request_SumTime = 0;
		end

		-- 复制新数据的CD ，避免频率太快，后台刷新亲密数据也要几分钟
		if self.Copy_SumTime >= self.Copy_CDTime then
			--复制一次所有数据
			copy_FromOtherModules();
			FriendCalcFinalFighting:OnProcess_CallBackData();
			self.Copy_SumTime = 0;
		end

		FriendCalcFinalFighting:UpdateInLocalClient(DeltaTime);
	end
end


function FriendCalcFinalFighting.PostEvent()
	-- log_tree("FCFF.PostEvent Submit_PlayerData = ", FriendCalcFinalFighting.Submit_PlayerData)
	EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_POPUP_WATCHWND, FriendCalcFinalFighting.Submit_PlayerData)
end


function FriendCalcFinalFighting:Clear()
	self.has_initialized_once = false;
	self.is_update_state  = false;

	self:RemoveTimer();
	--EventSystem:unregistEvent(EVENTTYPE_WATCH_POPUP, EVENTID_POPUP_WATCHWND, FriendCalcFinalFighting.PostEvent);
end

function FriendCalcFinalFighting.DataCallback_GetProfile(uidList)
	-- log_tree("FCFF DataCallback_GetProfile Begin uidAllData = ",uidList);
	FCFF_InfoList = {};

	--先设置 所有的状态
	for k,v in pairs(uidList) do
		if v.online == 1 then 			
			local one_data = {};
			one_data.uid = v.uid;
			one_data.intimacy_degree = v.intimacy;  	
			one_data.cur_max_segment_level = v.cur_max_segment_level;

			one_data.gameSubMode = v.gameSubMode;
			one_data.pass_time = v.timeSinceGameBegin;
			one_data.online = v.online ; 
			one_data.teamState = v.teamState ;
			one_data.enableWatch = v.enableWatch ;
			
			one_data.relationship_index = GetRelationShipIndexFromList(v.uid);
			one_data.player_name = v.player_name;

			if IsClassicMode(v.gameMode) and			---- 在线、是否是经典模式 ，用gameMode判断	
			IsInFinalState(v.gameSubMode,one_data.pass_time) == true then
				one_data.is_in_final_state = true;  
				-- log("IsInFinalState = true with uid = "..v.uid);
			end

			table.insert( FCFF_InfoList, one_data );
		end
	end
		
	--按照亲密度 -> 当前最高段位 -> uid 排序  
	local function func_sort(left,right)
		if left.intimacy_degree == right.intimacy_degree then
			if left.cur_max_segment_level == right.cur_max_segment_level then
				return tonumber(left.uid) > tonumber(right.uid);
			else
				return left.cur_max_segment_level > right.cur_max_segment_level;
			end
		else
			return left.intimacy_degree > right.intimacy_degree;
		end
	end 
	table.sort( FCFF_InfoList, func_sort );

	if #FCFF_InfoList == 0 then
		log("FCFF:DataCallback_GetProfile #FCFF_UidList == 0 ")
	else
		-- log_tree("FCFF DataCallback_GetProfile:", FCFF_InfoList)
	end

	--依次判断是否可以弹窗
	for k,v in pairs(FCFF_InfoList) do
		if v.is_in_final_state == true and 
		isContainInForbidList(v.uid) == false and  -- 不在禁止弹窗的名单内   
		isContainInPopupList(v.uid) == false then  
			local in_uid = v.uid
			if in_uid ~= nil then
				ProfileMgr.GetProfile(in_uid,FriendCalcFinalFighting.CallBack_RefreshPlayerState, true, true);
			end
		end
	end
end

function FriendCalcFinalFighting.CallBack_RefreshPlayerState(player_data_list)
	--刷新数据 
	---> 判断最新的timeSinceGameBegin / 是否活着 / 是否允许观战
	---> 触发PostEvent
	-- log("FCFF.CallBack_RefreshPlayerState ")

	if nil == player_data_list or 0 == #player_data_list then
		log("FCFF:CallBack_RefreshPlayerState nil ")
		return;
	end

	-- 返回是列表，这里也只有一个
	FriendCalcFinalFighting.PostOneFriend(player_data_list[1])
end

function FriendCalcFinalFighting.GetPlayerShowName(player_data)
	if player_data.nickName ~= nil and player_data.nickName ~= "" then
		return player_data.nickName
	elseif player_data.gameName ~= nil and player_data.gameName ~= "" then
		return player_data.gameName
	elseif player_data.remarks_name ~= nil and player_data.remarks_name ~= "" then
		return player_data.remarks_name
	end
	return ""
end

function FriendCalcFinalFighting.PostOneFriend(player_data)
	if player_data == nil then
		return
	end
	-- log_tree("FCFF PostOneFriend player_data = ",player_data);

	-- 房间开启的战斗不推荐
	local ownerID = player_data.owner_id
	if ownerID == nil then
		local profile = ProfileMgr.GetFriendProfileByUid(player_data.uid)	
		ownerID = profile.ownerID
	end

	if ownerID > 0 then
		log("CalcFinalFighting FriendCalcFinalFighting.PostOneFriend ownerID:"..ownerID)
	end

	-- 同一局直接忽略，5是心跳时间
	local CurBattleStartTime = NetUtil.GetCurServerTime() - player_data.timeSinceGameBegin
	if FriendCalcFinalFighting.LastPostEventBattleBeginTime > 0 and CurBattleStartTime - FriendCalcFinalFighting.LastPostEventBattleBeginTime <= 5 then
		FriendCalcFinalFighting:OnClick_ForbidPlayer(player_data.uid)
		return
	end

	if player_data~=nil and
	ownerID == 0 and
	player_data.online == 1 and 
	player_data.teamState == 2 and
	player_data.enableWatch == 1 and
	IsClassicMode(player_data.gameMode) and
	IsInFinalState(player_data.gameSubMode,player_data.timeSinceGameBegin) == true then	
		FriendCalcFinalFighting.Submit_PlayerData = {};
		FriendCalcFinalFighting.Submit_PlayerData.uid = player_data.uid;
		--使用昵称判断 
		FriendCalcFinalFighting.Submit_PlayerData.player_name = FriendCalcFinalFighting.GetPlayerShowName(player_data)
		FriendCalcFinalFighting.Submit_PlayerData.relation_flag = MakeRelationFlag(player_data.uid);
		FriendCalcFinalFighting.Submit_PlayerData.relationship_index = GetRelationShipIndexFromList(player_data.uid);

		FriendCalcFinalFighting.LastPostEventBattleBeginTime = NetUtil.GetCurServerTime() - player_data.timeSinceGameBegin
		FriendCalcFinalFighting.PostEvent();
		FriendCalcFinalFighting:AddToPopupList(player_data.uid);

		log("FCFF PostOneFriend with uid = "..player_data.uid);
	end
end


function FriendCalcFinalFighting:AddToPopupList(in_uid)
	-- log("FCFF AddToPopupList uid = "..tostring(in_uid));
	if isContainInPopupList(in_uid) then
		return;
	end

	local one_data = {};
	one_data.uid = tostring(in_uid);
	one_data.time_count = 0;
	table.insert( FCFF_Popup_TimeCountList, one_data );
end

function FriendCalcFinalFighting:OnClick_ForbidPlayer(in_uid)
	-- log("FCFF OnClick_ForbidPlayer uid = "..tostring(in_uid));
	if isContainInForbidList(in_uid) then
		for k,v in pairs(FCFF_ForbidStateList) do
			if tonumber(in_uid) == tonumber(v.uid) then
				v.forbid_sumTime = 0;
				v.forbid_beginTime = NetUtil.GetCurServerTime();
				return;
			end
		end
	end

	local one_data = {};
	one_data.uid = tostring(in_uid);
	one_data.forbid_sumTime = 0;
	one_data.forbid_beginTime = NetUtil.GetCurServerTime();
	table.insert( FCFF_ForbidStateList, one_data );
end

function FriendCalcFinalFighting:SetIsAbleToUpdateState(isAble)
	self.is_update_state = isAble;
end

function FriendCalcFinalFighting:IsClassicModeFinalState(gameMode,gameSubMode,pass_time)
	if has_initialized_once == false then
		ReadDataFromExcel();
		has_initialized_once = true;
	end

	if IsClassicMode(gameMode) == false then
		-- log("CalcFinalFighting IsClassicModeFinalState IsClassicMode false")
		return false;          
	else
		if IsInFinalState(gameSubMode,pass_time) == true then
			-- log("CalcFinalFighting IsClassicModeFinalState IsInFinalState IsClassicMode true");
			return true;
		else 
			-- log("CalcFinalFighting IsClassicModeFinalState IsInFinalState IsClassicMode false")
			return false;
		end
	end
end

--==============================----==============================--
--desc:Forbid信息存到 file, UID 对应 BeginTime
--time:2019年1月2日 14:42:50
--Save_FCFFInfo_ToFile : 在游戏退出之际，调用 ( OnApplicationWillTerminate )
--Load_FCFFInfo_ToFile : 在本模块Begin，调用

function FriendCalcFinalFighting:Save_FCFFInfo_ToFile()
	-- log("FCFF Save_FCFFInfo_ToFile");
	if FCFF_ForbidStateList==nil or #FCFF_ForbidStateList==0 then
		log("FCFF Save_FCFFInfo_ToFile： nil or 0");
		return;
	end

	local tableStr = FuncUtil:serialize(FCFF_ForbidStateList);
	GlobalData.SetGlobalConfigStringValue(self.FCFFBeginInfo_SaveKey,tostring(tableStr));
end

function FriendCalcFinalFighting:Load_FCFFInfo_ToFile()
	-- 初次进入游戏 该加载文件 ：亲密好友、师徒的beginTime，防止再次进入游戏弹同一局
	-- log("FCFF Load_FCFFInfo_ToFile");
	
	local tableStr = GlobalData.GetGlobalConfigStringValue(self.FCFFBeginInfo_SaveKey);
	if tableStr==nil or tostring(tableStr)=="" then
		log("FCFF Save_FCFFInfo_ToFile tableStr == nil ");
		return;
	end

	local ForbidTable = FuncUtil:unserialize(tostring(tableStr));
	FCFF_ForbidStateList = FuncUtil:CopyTable(ForbidTable);
	-- log_tree("Load_FCFFInfo_ToFile FCFF_ForbidStateList ",FCFF_ForbidStateList);

	if FCFF_ForbidStateList==nil or #FCFF_ForbidStateList==0 then
		log("FCFF Save_FCFFInfo_ToFile list == nil or #=0");
		return;
	end

	-- 重新计算所有的sumTime
	local remind_time = 0; -- 重新计算剩余的forbid时间
	for k,v in pairs(FCFF_ForbidStateList) do
		if v~=nil and
		v.uid~=nil then
			remind_time = NetUtil.GetCurServerTime() - v.forbid_beginTime >= self.WatchForbidTimeCount;
			if remind_time>=0 then
				table.remove( FCFF_ForbidStateList, k );
			else
				v.forbid_sumTime = remind_time;
			end
		end
	end
end
--==============================----==============================--
