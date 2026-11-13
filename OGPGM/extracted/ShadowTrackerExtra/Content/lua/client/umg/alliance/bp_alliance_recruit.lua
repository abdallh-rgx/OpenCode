--[[
	车队招募与申请列表
--]]

 AllianceRecruitUI = AllianceRecruitUI or {
	 isOnlyShow = true,
 	--离线tips的当前显示UID
 	CurrentOffmsg = {},

 	--前台存储已发送列表
 	HasInviteList = {},

	--当前推荐列表type , 1 好友，2 最近，3 附近， 4 战队 ， 10 车队
	CurrSuggestionDataType = 1;

	TP_Team = 1,
	TP_Corps = 2,
	TP_AllianceCompetition = 3,

	profileSlice = 8, --列表最多显示的数量

	InviteDataType_Friend = 1,
	InviteDataType_Recent = 2,
	InviteDataType_Nearby = 3,
	InviteDataType_Army = 4,
	InviteDataType_Team = 10,

	InviteDataType_AlianceCompetition = 10,

	DataInit = false,

}
-- 招募成员、申请列表相关数据结构
BP_STRUCT_AllianceRecruit =
{
    gid="",
	nickName = "",
	level = 0,
	militaryRank = "";
    picUrl = "",
    vipLevel = 0,
    ladder = 0,-- 天梯
    platName = "",
    sex = 0,
    lastOnlineTime = 0,
	lastOnlineTimeStr = "";
	lastLoginTime = 0;
	exp = 0;
    roleNation = "",
	segment_info_solo = 0;-- 段位数据
	segment_info_duo = 0;
	segment_info_squad = 0;
	
	friendType = 0;-- 好友类型（平台1、游戏内0） 
	
    applyMsg="", --好友申请里的留言
	createTime = 0,--好友申请的发送时间
	createTimeStr = "";
	
	online = 1, -- 0为离线，1为在线
		
	teamState = 0, -- 0为空闲，1为组队中（组队中提供当前队伍人数，队伍最大可容纳人数，队伍id）,2为已开局状态（需已开局时间数据）
	currentTeamAmount = 1, -- 当前队伍人数
	maxTeamAmount = 4, -- 队伍最大可容纳人数
	teamId = 0, -- 队伍id
	timeSinceGameBegin = 0, -- 已开局时间
	timeSinceGameBeginStr = "",
	cur_avatar_box_id = 0, --头像框
	history_max_segment_level = 0,
	cur_max_segment_level = 0,	--当前最高段位
	---招募独有字段
	hasSendInvite = false,
	aliasId = 0,
	aliasTitle = "",
	aliasNation = "",
	invite_source = 1,
};

-- 招募成员列表
local _Alliance_RecruitList =
{
	BP_STRUCT_AllianceRecruit = _G.BP_STRUCT_AllianceRecruit;
}

-- 申请列表
BP_ARRAY_Alliance_ApplyList =
{
	BP_STRUCT_AllianceRecruit =  _G.BP_STRUCT_AllianceRecruit;
}

--面板是否打开
BP_AllianceRecruit_IsShow = false;

--0：招募面板， 1：申请面板
BP_AllianceRecruit_CurType = 0;

--好友数量23/45
BP_AllianceFriendNumStr = "";

--招募邀请的ID
BP_AllianceRecruit_InviterGid = "";

--申请列表拒绝同意gid
BP_AllianceApply_Gid = "";

--红点
BP_AllianceRecruitReadPoint = false;

-- 是否显示申请列表按钮
BP_AllianceRecruitShowApply = false;


-- 招募目标类型，1 战队，2 军团
BP_Alliance_TargetType = 1;

-- 剩余招募总数
BP_Alliance_InvitedRemainNum = 0;


function bp_alliance_recruit_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_alliance_recruit,
		{	
			{Path="/Game/UMG/UI_Logic/Lobby_Team/LobbyTeam_LogicRecruitBP.LobbyTeam_LogicRecruitBP_C", Container="Default", ZOrder=BP_ENUM_UI_Alliance_Recruit},

		},
		{"Lobby"},
		false,		
		bp_alliance_recruit_OnModeSwitched ~= nil,
		true
	);

	--EventSystem:registEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_NEARBY_INFO_GOT, AllianceRecruitUI.OnNearbyInfoListGot);
end	

function bp_alliance_recruit_OnModeSwitched(gamestatus)
	log("bp_alliance_recruit_OnModeSwitched gamestatus = " .. gamestatus);
	if string.lower(gamestatus) == "lobby" then
       	AllianceRecruitUI.AddRegistUIEvent();
       	--发送离线消息,1表示车队
        AllianceSystem.SendAllOffMsgReq(1);
	end
end


--事件监听注册
local function OnAlianceRecruitEventHandler(eventType, eventID, dataVar)
	if eventType ~= EVENTTYPE_ALLIANCE then
		return;
	end

	if eventID == EVENTID_ALLIANCE_RECRUIT_APPLIST then --邀请列表取到概要信息返回
		--log_tree("OnAlianceRecruitEventHandler", dataVar);

		BP_ARRAY_Alliance_ApplyList = {};
		for k,v in pairs(dataVar) do  

	        local profileData = {};
	        profileData.gid = tostring(math.floor(v.uid));
	        profileData.picUrl = v.picUrl;
	        profileData.nickName = v.nickName--AllianceSystem.GetPlatformorRemarkName(v.uid, v.nickName);
	        profileData.sex = v.sex;     
	        profileData.level = v.level;
	        profileData.aliasId = v.id;
	        profileData.aliasTitle = v.title;
	        profileData.aliasNation = v.nation;
            --waynedong todo 
            ----------------------------------------intl modify--------------------------------------
            --[[
	        profileData.segment_info_solo = v.segment_info[1];
	        profileData.segment_info_duo = v.segment_info[2];
	        profileData.segment_info_squad = v.segment_info[3];
            ]]
            profileData.AllSegment_Info = v.segment_info;
            for kseg, vseg in pairs(profileData.AllSegment_Info) do
               profileData.segment_info_solo   = profileData.AllSegment_Info[kseg][1];
               profileData.segment_info_duo    = profileData.AllSegment_Info[kseg][2];
               profileData.segment_info_squad = profileData.AllSegment_Info[kseg][3];
               break;
            end
            profileData.segment_info_solo,  profileData.segment_info_duo,  profileData.segment_info_squad =  FuncUtil.GetMaxSegement( profileData.AllSegment_Info );
            ----------------------------------------intl modify--------------------------------------
	        profileData.cur_avatar_box_id = v.cur_avatar_box_id;
	        --profileData.segmentMax = math.max(profileData.segmentSolo, profileData.segmentDuo, profileData.segmentSquad);
	        profileData.cur_max_segment_level = v.cur_max_segment_level
			
			--组队状态
			profileData.online = v.online
			profileData.teamState = v.teamState
			profileData.currentTeamAmount = v.currentTeamAmount
			profileData.maxTeamAmount = v.maxTeamAmount
			
			--加入来源
			if AllianceSystem.apply_list_invite_source and AllianceSystem.apply_list_invite_source[math.floor(v.uid)] then
				profileData.invite_source = AllianceSystem.apply_list_invite_source[math.floor(v.uid)];
			else
				profileData.invite_source = 1;
			end
			
			log("AllianceSystem.apply_list_invite_source .." .. tostring(profileData.invite_source));
	        table.insert(BP_ARRAY_Alliance_ApplyList, profileData);  
    	end 
	end

	--TODO更新UI
	if BP_AllianceRecruit_CurType == 1 then
		AllianceRecruitUI.UpdateApplyList();		
	end
end

--注册事件
function AllianceRecruitUI.AddRegistUIEvent()
	--注册事件 TODO
	EventSystem:registEvent(EVENTTYPE_ALLIANCE, EVENTID_ALLIANCE_RECRUIT_APPLIST, OnAlianceRecruitEventHandler);
end

--删除事件
function AllianceRecruitUI.RemoveUIEvent()
	EventSystem:unregistEvent(EVENTTYPE_ALLIANCE, EVENTID_ALLIANCE_RECRUIT_APPLIST, OnAlianceRecruitEventHandler);
end


local function hasSend(uid)
	local result = false;
	local localUID = tonumber(uid);
	for k,v in pairs(AllianceRecruitUI.HasInviteList) do
		if localUID == v then
			result = true;
			--log("dddddddddddd"..localUID);
			break;
		end
	end
	return result;
end


-- 是否能在军团类显示
function AllianceRecruitUI.IsShowInCorpsType(listItem, corpsOpenLevel)
	if listItem == nil then
		return false;
	end

	-- log_tree("AllianceRecruitUI.IsShowInCorpsType listItem", listItem);

	if listItem.corps_id ~= nil and listItem.corps_id ~= 0 then
		return false;
	end

	if DataMgr.corpsInfo.isNeedApproval then
		if listItem.level < corpsOpenLevel then
			return false;
		end

		local maxSegment = math.max(listItem.segment_info_solo, listItem.segment_info_duo, listItem.segment_info_squad);
		if maxSegment < DataMgr.corpsInfo.joinSegment then
			return false;
		end
	end

	return true;
end

local function ClearUselessData(list)
	local levelLimit = math.max(CorpsMgr.GetConfigToNumber("CreateCorpsLevel"), DataMgr.corpsInfo.joinLevel)

	local delete = false 
	for i = #list,1,-1 do
		delete = false 
		-- log_tree("AllianceRecruitUI.IsShowInCorpsType listItem", list[i]);

		if list[i].corps_id ~= nil and list[i].corps_id ~= 0 then
			delete = true
		end
		if list[i].level < levelLimit then 
			delete = true
		end
		local maxSegment = math.max(list[i].segment_info_solo, list[i].segment_info_duo, list[i].segment_info_squad);
		log("ClearUselessData maxSegment:" .. tostring(maxSegment))
		--[[
		if not maxSegment then
			maxSegment = 0
		end
		]]
		if maxSegment < DataMgr.corpsInfo.joinSegment then
			delete = true
		end

		if delete == true then 
			table.remove(list,i)
		end
	end
end

-- function AllianceRecruitUI.InitData()
-- 	-- body
-- 	--构造招募数据,好友数量	
-- 	--_Alliance_RecruitList = {};
-- 	_Alliance_RecruitList = FriendSystem.SortFriendList();
--     local allianceOpenLvStr = DataMgr.GetSystemConfig("MinCarTeamLevel");
-- 	local allianceOpenLv = allianceOpenLvStr == nil and 0 or tonumber(allianceOpenLvStr);
    
-- 	--过滤队员的列表
-- 	if BP_Alliance_TargetType == AllianceRecruitUI.TP_Team then
-- 		for i = #_Alliance_RecruitList,1,-1 do
-- 			local  isMember = AllianceSystem.IsAllianceMember(_Alliance_RecruitList[i].gid);
-- 			if isMember == true or _Alliance_RecruitList[i].level < allianceOpenLv then
-- 				table.remove(_Alliance_RecruitList,i);
-- 			end
-- 		end
-- 	elseif BP_Alliance_TargetType == AllianceRecruitUI.TP_Corps then
-- 		local levelLimit = math.max(CorpsMgr.GetConfigToNumber("CreateCorpsLevel"), DataMgr.corpsInfo.joinLevel)

-- 		for i = #_Alliance_RecruitList,1,-1 do

-- 			if not AllianceRecruitUI.IsShowInCorpsType(_Alliance_RecruitList[i], levelLimit) then
-- 				table.remove(_Alliance_RecruitList,i);
-- 			end
-- 		end
-- 	end

--     for i = #_Alliance_RecruitList,1,-1 do
--         -- 设置备注名
--         _Alliance_RecruitList[i].nickName = AllianceSystem.GetPlatformorRemarkName(_Alliance_RecruitList[i].gid, _Alliance_RecruitList[i].nickName)
-- 	end

-- 	AllianceRecruitUI.UpdateLeaderFlag();
-- 	local onlineNum  = 0;
-- 	for k,v in pairs(_Alliance_RecruitList) do
-- 		if v.online == 1 then
-- 			onlineNum = onlineNum + 1;
-- 		end
-- 		--是否显示已发送
-- 		_Alliance_RecruitList[k].hasSendInvite = hasSend(v.gid);
-- 	end
-- 	--log_tree("AllianceRecruitUI",_Alliance_RecruitList);
-- 	BP_AllianceFriendNumStr = "("..tostring(onlineNum).."/"..tostring(#_Alliance_RecruitList) ..")";

-- 	AllianceRecruitUI.UpdateAllianceRecruit();
-- end

function AllianceRecruitUI.InitData(dataType)
	log("AllianceRecruitUI.InitData" .. dataType)
	AllianceRecruitUI.DataInit = false 
	AllianceRecruitUI.CurrSuggestionDataType = dataType;
	local levelLimit = math.max(CorpsMgr.GetConfigToNumber("CreateCorpsLevel"), DataMgr.corpsInfo.joinLevel)

	--构造招募数据,好友数量	

	--构造军团招募-好友数据
	if dataType == AllianceRecruitUI.InviteDataType_Friend then
		_Alliance_RecruitList = FriendSystem.SortFriendList();

		for i = #_Alliance_RecruitList,1,-1 do
	        -- 设置备注名
	        if _Alliance_RecruitList[i].nickName == "" then
	        	_Alliance_RecruitList[i].nickName = AllianceSystem.GetPlatformorRemarkName(_Alliance_RecruitList[i].gid, _Alliance_RecruitList[i].nickName)
	        end
            _Alliance_RecruitList[i].roleNation = ProfileMgr.GetRoleNationByUid(_Alliance_RecruitList[i].gid);
		end

		ClearUselessData(_Alliance_RecruitList)
		AllianceRecruitUI.GetProfileForCorps(dataType)
	--构造军团招募-最近好友数据
	elseif dataType == AllianceRecruitUI.InviteDataType_Recent then
		--_Alliance_RecruitList = FriendRecentTeammateModule.SortRecentList();
		ClearUselessData(_Alliance_RecruitList)
		--AllianceRecruitUI.GetProfileForCorps(dataType)
	--构造军团招募-附近的人数据
	elseif dataType == AllianceRecruitUI.InviteDataType_Nearby then
		--_Alliance_RecruitList = NearBySystem.SortNearbyList();
		_Alliance_RecruitList = {}
		ClearUselessData(_Alliance_RecruitList)
		--AllianceRecruitUI.GetProfileForCorps(dataType)
	--构造军团招募-战队成员数据
	elseif dataType == AllianceRecruitUI.InviteDataType_Army then
		_Alliance_RecruitList = AllianceSystem.GetAllianceProfileListWithoutSelf()
		-- log_tree("_Alliance_RecruitList===========",_Alliance_RecruitList)

		if BP_Alliance_TargetType ~= AllianceRecruitUI.TP_AllianceCompetition then
			ClearUselessData(_Alliance_RecruitList)
		end

		-- log_tree("_Alliance_RecruitList===========",_Alliance_RecruitList)
		if BP_Alliance_TargetType == AllianceRecruitUI.TP_AllianceCompetition then
			local onlineNum  = 0;
			for k,v in pairs(_Alliance_RecruitList) do
				if v.online == 1 then
					onlineNum = onlineNum + 1;
				end
				--是否显示已发送
				_Alliance_RecruitList[k].hasSendInvite = hasSend(v.gid);
			end
			BP_AllianceFriendNumStr = "("..tostring(onlineNum).."/"..tostring(#_Alliance_RecruitList) ..")";
		end

		AllianceRecruitUI.GetProfileForCorps(dataType)

		if BP_Alliance_TargetType == AllianceRecruitUI.TP_AllianceCompetition then
			AllianceRecruitUI.UpdateAllianceRecruit()
		end
	--构造战队招募-招募数据
	elseif dataType == AllianceRecruitUI.InviteDataType_Team then
		_Alliance_RecruitList = FriendSystem.SortFriendList();
	    local allianceOpenLvStr = DataMgr.GetSystemConfig("MinCarTeamLevel");
		local allianceOpenLv = allianceOpenLvStr == nil and 0 or tonumber(allianceOpenLvStr);
		for i = #_Alliance_RecruitList,1,-1 do
			local  isMember = AllianceSystem.IsAllianceMember(_Alliance_RecruitList[i].gid);
			if isMember == true or _Alliance_RecruitList[i].level < allianceOpenLv then
				table.remove(_Alliance_RecruitList,i);
			end
		end

		for i = #_Alliance_RecruitList,1,-1 do
	        -- 设置备注名
	        if _Alliance_RecruitList[i].nickName == "" then
	        	_Alliance_RecruitList[i].nickName = AllianceSystem.GetPlatformorRemarkName(_Alliance_RecruitList[i].gid, _Alliance_RecruitList[i].nickName)
	        end
            _Alliance_RecruitList[i].roleNation = ProfileMgr.GetRoleNationByUid(_Alliance_RecruitList[i].gid);
		end

		local onlineNum  = 0;
		for k,v in pairs(_Alliance_RecruitList) do
			if v.online == 1 then
				onlineNum = onlineNum + 1;
			end
			--是否显示已发送
			_Alliance_RecruitList[k].hasSendInvite = hasSend(v.gid);
		end
		BP_AllianceFriendNumStr = "("..tostring(onlineNum).."/"..tostring(#_Alliance_RecruitList) ..")";

		AllianceRecruitUI.DataInit = true
		AllianceRecruitUI.UpdateShowCanvasApplyFlag();
		AllianceRecruitUI.UpdateAllianceRecruit();

		return
	end

	-- log_tree("AllianceRecruitUI",_Alliance_RecruitList);

	-- AllianceRecruitUI.UpdateAllianceRecruit();
end

--打开招募UI
function AllianceRecruitUI.ShowUIRecruit(type)
	BP_Alliance_TargetType = type;
	
	--重新打开UI清空列表
	AllianceRecruitUI.HasInviteList = {};
	BP_AllianceRecruit_IsShow = true;

	AllianceRecruitUI.ChangeIsOnlyShow(true)

	if BP_Alliance_TargetType == AllianceRecruitUI.TP_Team then
		--招募拉取好友，走好友2分钟后强制拉取最新的概要
		FriendSystem.CheckFetchFriendList();
		-- 获取好友数据
		AllianceRecruitUI.InitData(AllianceRecruitUI.InviteDataType_Team);
		EventSystem:registEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_ONLINE_STATE_CHANGE, AllianceRecruitUI.OnFriendOnlineStateChange);
		EventSystem:registEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_REFRESH_LIST, AllianceRecruitUI.OnFriendOnlineStateChange)

			-- 如果是军团，拉去已邀请列表
	elseif BP_Alliance_TargetType == AllianceRecruitUI.TP_Corps then
		--NearBySystem.CheckAndGetNearbyPersonInfo(); -- 如果是军团邀请需要先请求附近的人数据（因为数据不是同步到，提前申请）

		_Alliance_RecruitList = {};
		BP_ARRAY_AllianceRecruit_Lite_Profile = {};
		BP_ARRAY_AllianceRecruit_Detail_Profile = {};
		BP_AllianceRecruitShowApply = false
		BP_AllianceFriendNumStr = "(0/0)"
		log("AllianceRecruitUI.ShowUIRecruit registerMsg")
		EventSystem:registEvent(EVENTTYPE_CORPS, EVENTID_CORPS_FRIEND_REFRESH, AllianceRecruitUI.OnCorpsIDRefreshed);
		-- FriendSystem.RefreshFriendsCorpsID();

		CorpsMemberSystem.SendGetDailyInvitedListReq(AllianceRecruitUI.OnGetDailyInvitedListDone);

	elseif BP_Alliance_TargetType == AllianceRecruitUI.TP_AllianceCompetition then
		AllianceRecruitUI.InitData(AllianceRecruitUI.InviteDataType_Army)
		BP_AllianceRecruitShowApply = false
		
	end
	
	LuaClassObj.HandleDynamicCreation(bp_alliance_recruit);
	LuaClassObj.HandleUIMessage(bp_alliance_recruit, "ShowUIRecruit");
	UIManager.Show(eUIType.eAllianceRecruitUI)
end

function AllianceRecruitUI.OnFriendOnlineStateChange()
	AllianceRecruitUI.UpdateAllianceRecruit();
	LuaClassObj.HandleUIMessage(bp_alliance_recruit, "UpdateRecruitListUI")
end

function AllianceRecruitUI.OnGetDailyInvitedListDone()
	log("AllianceRecruitUI.OnGetDailyInvitedListDone")
	AllianceRecruitUI.InitData(AllianceRecruitUI.InviteDataType_Friend)
end

function AllianceRecruitUI.OnCorpsIDRefreshed()
	log("AllianceRecruitUI.OnCorpsIDRefreshed")
	if BP_AllianceRecruit_IsShow and BP_Alliance_TargetType == AllianceRecruitUI.TP_Corps then
		-- AllianceRecruitUI.InitData(AllianceRecruitUI.InviteDataType_Friend); -- 默认第一个
		-- CorpsMemberSystem.SendGetDailyInvitedListReq();

		-- for i = #_Alliance_RecruitList,1,-1 do
		-- 	if not AllianceRecruitUI.IsShowInCorpsType(_Alliance_RecruitList[i], levelLimit) then
		-- 		table.remove(_Alliance_RecruitList,i);
		-- 	end
		-- end

		AllianceRecruitUI.UpdateCorpsInviteList()
	end

	AllianceRecruitUI.DataInit = true
end

function AllianceRecruitUI.CloseUI()
	LuaClassObj.HandleUIMessage(bp_alliance_recruit, "UIHide");
end

function AllianceRecruitUI.UpdateCorpsInviteList()
	log("AllianceRecruitUI.UpdateCorpsInviteList BP_AllianceRecruit_IsShow "..tostring(BP_AllianceRecruit_IsShow))
	if not BP_AllianceRecruit_IsShow then
		return;
	end


	-- AllianceRecruitUI.HasInviteList = {}
	for i,v in ipairs(CorpsMemberSystem.InvitedList) do
		if not hasSend(v) then
			table.insert(AllianceRecruitUI.HasInviteList,v);
		end
	end	
	--log_tree("!!!!!!!!!!" , CorpsMemberSystem.InvitedList)
	--log_tree("!!!!!!!!!!" , AllianceRecruitUI.HasInviteList)

	-- log_tree("AllianceRecruitUI.UpdateCorpsInviteList AllianceRecruitUI.HasInviteList", AllianceRecruitUI.HasInviteList)
	AllianceRecruitUI.UpdateInviteToRecruit();
end

function AllianceRecruitUI.HasSendInvite(uid)
	if not BP_AllianceRecruit_IsShow then
		return;
	end

	table.insert(AllianceRecruitUI.HasInviteList,uid);
	AllianceRecruitUI.UpdateInviteToRecruit();
end

function AllianceRecruitUI.UpdateInviteToRecruit()
	log("AllianceRecruitUI.UpdateInviteToRecruit")
	for k,v in pairs(_Alliance_RecruitList) do
		--是否显示已发送		
		_Alliance_RecruitList[k].hasSendInvite = hasSend(v.gid);
		--log_tree("_Alliance_RecruitList",_Alliance_RecruitList[k]);
	end

	-- 更新剩余次数
	BP_Alliance_InvitedRemainNum = CorpsMemberSystem.invitedRemainNum;
	log("AllianceRecruitUI.UpdateApplyList BP_Alliance_InvitedRemainNum"..tostring(BP_Alliance_InvitedRemainNum));

	-- log_tree("AllianceRecruitUI.UpdateInviteToRecruit _Alliance_RecruitList", _Alliance_RecruitList)
	--更新列表
	--LuaClassObj.HandleUIMessage(bp_alliance_recruit, "UpdateRecruitListInvite");
	AllianceRecruitUI.UpdateAllianceRecruit();
	LuaClassObj.HandleUIMessageNoFetch(bp_alliance_recruit, "UpdateRecruitListUI");
end

function AllianceRecruitUI.ClearInviteToRecruit()
	_Alliance_RecruitList = {}
	AllianceRecruitUI.UpdateAllianceRecruit()
	LuaClassObj.HandleUIMessageNoFetch(bp_alliance_recruit, "UpdateRecruitListUI");
end

--打开申请列表UI
function AllianceRecruitUI.ShowUIApplist()
	LuaClassObj.HandleDynamicCreation(bp_alliance_recruit);
	BP_AllianceRecruit_IsShow = true;
	BP_ARRAY_Alliance_ApplyList = {}
	--- 请求申请列表数据，拉取申请列表ID，返回后直接拉取概要信息，回调更新UI
	AllianceSystem.SendGetApplyListReq();
	--显示申请UI
	LuaClassObj.HandleUIMessage(bp_alliance_recruit, "ShowUIApplist");
end

--请求概要信息回来后显示更新UI
function AllianceRecruitUI.UpdateApplyList(isemty)
	log("AllianceRecruitUIUpdateApplyList"..tostring(isemty));
	if isemty ~= nil and isemty == true then
		log("AllianceRecruitUIUpdateApplyList isemty");
		BP_ARRAY_Alliance_ApplyList = {};
	end

	--UI打开才更新
	if BP_AllianceRecruit_IsShow == true then
		LuaClassObj.HandleUIMessage(bp_alliance_recruit, "UpdateApplyListUI");
	end	
end

--队长接受拒绝
function AllianceRecruitUI.RemoveApplyList(uid)
	for k,v in pairs(BP_ARRAY_Alliance_ApplyList) do
		if tostring(uid) == v.gid then
			table.remove(BP_ARRAY_Alliance_ApplyList,k);
		end
	end
	AllianceRecruitUI.UpdateApplyList();

	--更新小红点
	AllianceRecruitUI.UpdateRepoint(#BP_ARRAY_Alliance_ApplyList);
end


function AllianceRecruitUI.OnClickOkCallBack()
		-- 接受邀请			
	local teamid = AllianceRecruitUI.CurrentOffmsg.msg.team_id;
	local fromuid = AllianceRecruitUI.CurrentOffmsg.msg.from_uid;
	local offmsgid = AllianceRecruitUI.CurrentOffmsg.index;

	--log_tree("clickOkCallback",AllianceRecruitUI.CurrentOffmsg);
	AllianceSystem.SendAcceptJoinReq(teamid, fromuid, offmsgid, true);
	AllianceSystem.RemoveOffMsgInfoByIndex(offmsgid);
	AllianceRecruitUI.CurrentOffmsg = {};
	--AllianceRecruitUI.PopQueueMsgInfoTips();
end

function AllianceRecruitUI.OnClickCancelCallBack()
	-- 拒绝
	local teamid = AllianceRecruitUI.CurrentOffmsg.msg.team_id;
	local fromuid = AllianceRecruitUI.CurrentOffmsg.msg.from_uid;
	local offmsgid = AllianceRecruitUI.CurrentOffmsg.index;
	--log_tree("clickCancelCallback",AllianceRecruitUI.CurrentOffmsg);

	AllianceSystem.SendAcceptJoinReq(teamid, fromuid, offmsgid, false);
	AllianceSystem.RemoveOffMsgInfoByIndex(offmsgid);
	AllianceRecruitUI.CurrentOffmsg = {};
	--AllianceRecruitUI.PopQueueMsgInfoTips();
end

function AllianceRecruitUI.GetPopNickNameBack(profile_list)  
	--log_tree("getNickNameBack",profile_list);      		
 	local friendName = DataMgr.GetMsgByID(117032);--"陌生人";        		
	if #profile_list ~= 0 then
		 friendName = profile_list[1].nickName;
	end

   -- local friendData = FriendSystem.GetFriendDataByGID(AllianceRecruitUI.CurrentOffmsg.msg.from_uid);
    --log_tree("friendDataddddddddd",friendData);
    --if(friendData ~= nil) then
     --   friendName = friendData.nickName;
    --end	

    local tipstr = DataMgr.GetMsgByID(117033);-- "<MessageProductColor>%s</>邀请你加入<MessageProductColor>%s</>小分队，你同意吗？";
    local contentStr = string.format(tipstr, friendName, AllianceRecruitUI.CurrentOffmsg.msg.team_name);
    CommonMessageBoxUI:ShowPanel(2, DataMgr.GetMsgByID(117034), contentStr, AllianceRecruitUI.OnClickOkCallBack, AllianceRecruitUI.OnClickCancelCallBack, DataMgr.GetMsgByID(117035),DataMgr.GetMsgByID(117036));	

end

--弹出离线消息
function AllianceRecruitUI.PopQueueMsgInfoTips()
	--CurrentOffmsg
	--[[
		offmsg:
		index:  	索引
		uid:		uid
		type:	1 车队消息
		sendtime: 	时间
		msg:		消息
		op	  1 邀请; 2 通知审核完加入
		team_id   车队ID
		team_name 车队名称
		from_uid  邀请人uid
	]]
	local find = false;
	for k,v in pairs(AllianceSystem.OffMsgInfo) do
		AllianceRecruitUI.CurrentOffmsg = v;
		find = true; 
		break;
	end

	if find == true then
		
        if AllianceRecruitUI.CurrentOffmsg.msg.op == 1 then
        	--log_tree("AllianceRecruitUI.CurrentOffmsg",AllianceRecruitUI.CurrentOffmsg);
			ProfileMgr.GetProfile(AllianceRecruitUI.CurrentOffmsg.msg.from_uid, AllianceRecruitUI.GetPopNickNameBack);

        elseif AllianceRecruitUI.CurrentOffmsg.msg.op == 2 then
        	--恭喜加入XXX战队
            AllianceUI.ProtocolErroCode("cline_JoinCarTeam",AllianceRecruitUI.CurrentOffmsg.msg.team_name);
			--加入战队(1表示战队离线消息)后同步下离线消息，因为后台会清离线消息，前台有可能还会有。。所以.
        	AllianceSystem.SendAllOffMsgReq(1);
        end
    
	end
	

end

function AllianceRecruitUI.UpdateShowCanvasApplyFlag()
	BP_AllianceRecruitShowApply = false

	if AllianceSystem.IsLeader() and BP_Alliance_TargetType == AllianceRecruitUI.TP_Team then
		BP_AllianceRecruitShowApply = true
	end
end


--更新小红点
function AllianceRecruitUI.UpdateRepoint(listNum)
	--大厅车队按钮
	--车队界面
	--招募界面
	AllianceRecruitUI.UpdateShowCanvasApplyFlag()
	if tonumber(listNum) > 0 then
		BP_AllianceRecruitReadPoint = true;
		--显示小红点 TODO
	else
		--关闭小红点 TOD
		BP_AllianceRecruitReadPoint = false;
	end
	--更新大厅和车队界面
	AllianceUI:RedPointStatusUpdate(BP_AllianceRecruitReadPoint);	
	if BP_AllianceRecruit_IsShow == true then
		LuaClassObj.HandleUIMessage(bp_alliance_recruit,"UpdateBPRepoint");
	end
end


function EventAllianceRecruit_Push()
	--蓝图变量同步给lua
end

function EventAllianceRecruitFetchInfo()
	--lua变量同步蓝图
end

--点击申请按钮回调，发送请求
function EventShowApplyList()	
	 AllianceRecruitUI.ShowUIApplist();
	 --test
	 --BP_ARRAY_Alliance_ApplyList = _Alliance_RecruitList;
	 --AllianceRecruitUI.UpdateApplyList()
end

--关闭UI回调
function EventAllianceRecruitHideUI()
	BP_AllianceRecruit_IsShow = false;

	EventSystem:unregistEvent(EVENTTYPE_CORPS, EVENTID_CORPS_FRIEND_REFRESH, AllianceRecruitUI.OnCorpsIDRefreshed);
	EventSystem:unregistEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_ONLINE_STATE_CHANGE, AllianceRecruitUI.OnFriendOnlineStateChange);
	EventSystem:unregistEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_REFRESH_LIST, AllianceRecruitUI.OnFriendOnlineStateChange)
end

--点击招募按钮
function EventClickRecruit()
	-- log_tree("EventClickRecruit _Alliance_RecruitList", _Alliance_RecruitList)
	-- body
	if BP_AllianceRecruit_InviterGid ~= "" then
		if BP_Alliance_TargetType == AllianceRecruitUI.TP_Team then
			AllianceSystem.SendInviteCarTeamReq(BP_AllianceRecruit_InviterGid);

		elseif BP_Alliance_TargetType == AllianceRecruitUI.TP_Corps then
			log("EventClickRecruit DataMgr.corpsInfo.id "..DataMgr.corpsInfo.id);
			if DataMgr.corpsInfo.id ~= 0 then
				CorpsMemberSystem.SendInviteReq(BP_AllianceRecruit_InviterGid, 0);
			end

		elseif BP_Alliance_TargetType == AllianceRecruitUI.TP_AllianceCompetition then
			AllianceCompetitionSystem.log("EventClickRecruit")
			TeamUpSystem.team_invite_request(tonumber(BP_AllianceRecruit_InviterGid))
		end
	end
end

--点击申请列表，同意
function EventClickApplyAgree()
	-- body
	if BP_AllianceApply_Gid ~= "" then
		 AllianceSystem.SendApproveReq(BP_AllianceApply_Gid, true);
	end
end

--点击申请列表，拒绝
function EventClickApplyRefuse()
	-- body
	if BP_AllianceApply_Gid ~= "" then
		 AllianceSystem.SendApproveReq(BP_AllianceApply_Gid, false);
	end
end


BP_Alliance_UpdateInnerIndex = 0;
function AllianceRecruitUI.OnRecruitItemChange(list)
	log("AllianceRecruitUIOnRecruitItemChange");
	local listCount = #list;
	if listCount > 0 then
		local profile = list[1];
		for i=1, #_Alliance_RecruitList do
			local v = _Alliance_RecruitList[i];
			if tostring(profile.uid) == tostring(v.gid) then
				v = AllianceRecruitUI.CopyBaseInfo(v, profile);
				BP_Alliance_UpdateInnerIndex = i-1;
				log("AllianceRecruitUI.OnRecruitItemChange BP_Alliance_UpdateInnerIndex = " .. BP_Alliance_UpdateInnerIndex);
				LuaClassObj.HandleUIMessage(bp_alliance_recruit, "UpdateRecruitOneSync");
			end
		end
	end
	
end

function AllianceRecruitUI.OnApplyItemChange(list)
	log("AllianceRecruitUIOnApplyItemChange");
	local listCount = #list;
	if listCount > 0 then
		local profile = list[1];
		for i=1, #BP_ARRAY_Alliance_ApplyList do
			local v = BP_ARRAY_Alliance_ApplyList[i];
			if tostring(profile.uid) == tostring(v.gid) then
				v = AllianceRecruitUI.CopyBaseInfo(v, profile);
				BP_Alliance_UpdateInnerIndex = i-1;
				log("AllianceRecruitUI.OnApplyItemChange BP_Alliance_UpdateInnerIndex = " .. BP_Alliance_UpdateInnerIndex);
				LuaClassObj.HandleUIMessage(bp_alliance_recruit, "UpdateApplyOneSync");
			end
		end
	end
end

function AllianceRecruitUI.CopyBaseInfo(v, profile)	    
	v.nickName = profile.nickName;
	v.level = profile.level;
	v.vipLevel = profile.vipLevel;
	v.picUrl = profile.picUrl;
	v.platName = profile.platName;
	v.sex = profile.sex;
	v.aliasID = profile.id;
	v.aliasTitle = profile.title;
	v.aliasNation = profile.nation;

	-- v.segment_info_solo = profile.segment_info[1];
	-- v.segment_info_duo = profile.segment_info[2];
	-- v.segment_info_squad = profile.segment_info[3];

	v.segment_info_solo, v.segment_info_duo, v.segment_info_squad =  FuncUtil.GetMaxSegement(profile.segment_info);

	v.cur_avatar_box_id = profile.cur_avatar_box_id;
	v.cur_max_segment_level = profile.cur_max_segment_level
	return v;
end


--点击招募列表头像
function EventClickHeadRecruit()
	RoleInfoSystem.Enter(BP_AllianceRecruit_InviterGid);
	log("enter profile panel:"..tostring(BP_AllianceRecruit_InviterGid));
	RoleInfoUI.Init(true, RoleInfoOpenFromType.AllianceRecruitInvite);

	ProfileMgr.GetProfile(tostring(BP_AllianceRecruit_InviterGid), AllianceRecruitUI.OnRecruitItemChange, true);
end

--点击申请列表头像
function EventClickHeadApply()
	RoleInfoSystem.Enter(BP_AllianceApply_Gid);
	log("enter profile panel:"..tostring(BP_AllianceApply_Gid));
	RoleInfoUI.Init(true, RoleInfoOpenFromType.AllianceRecruitApply);

	ProfileMgr.GetProfile(tostring(BP_AllianceApply_Gid), AllianceRecruitUI.OnApplyItemChange, true);
end

---列表优化

BP_Alliance_Recruit_Scroll_Start = 0;--起始位置
BP_Alliance_Recruit_Scroll_End = 0; --列表滚动的终止

--分段加载gid全量
BP_STRUCT_AllianceRecruitProfile = 
{
	gid = "",	
}
BP_ARRAY_AllianceRecruit_Lite_Profile = 
{
	BP_STRUCT_AllianceRecruitProfile = _G.BP_STRUCT_AllianceRecruitProfile,
}
--ui（暂且显示8个）分段显示详细数据
BP_ARRAY_AllianceRecruit_Detail_Profile = 
{
	BP_STRUCT_AllianceRecruit = _G.BP_STRUCT_AllianceRecruit,
}

function AllianceRecruitUI.UpdateAllianceRecruit()
	
	BP_ARRAY_AllianceRecruit_Lite_Profile = {}; --只存gid的全量数据
	BP_ARRAY_AllianceRecruit_Detail_Profile = {}; --列表显示详细数据

	--取全量
	if 0 == BP_Alliance_Recruit_Scroll_Start and  BP_Alliance_Recruit_Scroll_End <= 0 then
		BP_Alliance_Recruit_Scroll_End = AllianceRecruitUI.profileSlice;
	end
	local startIndex = BP_Alliance_Recruit_Scroll_Start / AllianceRecruitUI.profileSlice;
	local endIndex = BP_Alliance_Recruit_Scroll_End / AllianceRecruitUI.profileSlice;	
	--local count = 0;  
	local count = 0;
	-- log("startIndex:"..startIndex.." endIndex:"..endIndex);
	-- log_tree("_Alliance_RecruitList",_Alliance_RecruitList);
	for k,v in pairs(_Alliance_RecruitList) do
		local str_gid = v.gid;
		table.insert(BP_ARRAY_AllianceRecruit_Lite_Profile,{gid = tostring(str_gid)});			
		if (startIndex * AllianceRecruitUI.profileSlice <= count) and (endIndex * AllianceRecruitUI.profileSlice >= count) then			
			table.insert(BP_ARRAY_AllianceRecruit_Detail_Profile, v);
		end

		count = count + 1;	
	end

	--计算最高段位
	for k, v in pairs(BP_ARRAY_AllianceRecruit_Detail_Profile) do
		local max_segment = 101
		if v and v.AllSegment_Info then
			for i, info in pairs(v.AllSegment_Info) do
				max_segment = math.max(max_segment, info[1], info[2], info[3], info[4], info[5], info[6])
			end	
		end
		if v then
			v.cur_max_segment_level = max_segment;
		end
	end

	--log_tree("BP_ARRAY_AllianceRecruit_Lite_Profile", BP_ARRAY_AllianceRecruit_Lite_Profile);
	-- log_tree("BP_ARRAY_AllianceRecruit_Detail_Profile", BP_ARRAY_AllianceRecruit_Detail_Profile);
end

--滚动的时候刷新数据
function EventAllianceRecruitScrollChanged()
	if AllianceRecruitUI.DataInit == false then
		return
	end

	if BP_Alliance_Recruit_Scroll_End ~= 0 then		
		AllianceRecruitUI.UpdateAllianceRecruit();
	end 	
	LuaClassObj.HandleUIMessageNoFetch(bp_alliance_recruit, "UpdateRecruitListUI");
end

function EventAllianceRecruitFriendBtnClicked()
	log("EventAllianceRecruitFriendBtnClicked")
	--AllianceRecruitUI.ClearInviteToRecruit()--这里不需要清除数据，通过后面的操作来刷新数据即可，不然会闪烁一下
	AllianceRecruitUI.InitData(AllianceRecruitUI.InviteDataType_Friend); 
	-- AllianceRecruitUI.UpdateCorpsInviteList()
	ClientSendBAReport(BP_BA_CORPS_INVITE_FRIEND, 0);
end

function EventAllianceRecruitRecentBtnClicked()
	log("EventAllianceRecruitRecentBtnClicked")
	AllianceRecruitUI.ClearInviteToRecruit()
	--AllianceRecruitUI.InitData(AllianceRecruitUI.InviteDataType_Recent); 
	-- AllianceRecruitUI.UpdateCorpsInviteList()
	--ClientSendBAReport(BP_BA_CORPS_INVITE_RECENT, 0);
end

function EventAllianceRecruitNearbyBtnClicked()
	log("EventAllianceRecruitNearbyBtnClicked")
	AllianceRecruitUI.ClearInviteToRecruit()
	--AllianceRecruitUI.InitData(AllianceRecruitUI.InviteDataType_Nearby); 
	-- AllianceRecruitUI.UpdateCorpsInviteList()
	--ClientSendBAReport(BP_BA_CORPS_INVITE_NEARBY, 0);
end

function EventAllianceRecruitArmyBtnClicked()
	log("EventAllianceRecruitArmyBtnClicked")
	--AllianceRecruitUI.ClearInviteToRecruit()--这里不需要清除数据，通过后面的操作来刷新数据即可，不然会闪烁一下
	AllianceRecruitUI.InitData(AllianceRecruitUI.InviteDataType_Army); 
	-- AllianceRecruitUI.UpdateCorpsInviteList()
	ClientSendBAReport(BP_BA_CORPS_INVITE_ARMY, 0);
end


--附近的人的数据是异步的，在打开招募界面就会请求，如果在切换到附近的人的页签时才收到数据需要及时刷新界面
function AllianceRecruitUI.OnNearbyInfoListGot()
	if AllianceRecruitUI.CurrSuggestionDataType == AllianceRecruitUI.InviteDataType_Nearby then 
		EventAllianceRecruitNearbyBtnClicked()
	end
end

function EventAllianceRecruitPlatformInviteBtnClicked()
	log("EventCorpsOnClickPlatformInvite");
	EventCorpsOwnHomePagePlatformInviteBtnClicked();
end

function AllianceRecruitUI.GetProfileForCorps(dataType)
	log("AllianceRecruitUI.GetProfileForCorps" .. tostring(dataType))
	if dataType == AllianceRecruitUI.InviteDataType_Friend then
		FriendSystem.RefreshFriendsCorpsID();
	else
		local idList = {}
		for _,v in pairs(_Alliance_RecruitList) do 
			table.insert(idList,tonumber(v.gid))
		end
		-- log_tree("AllianceRecruitUI.GetProfileForCorps" , idList)

		AllianceRecruitUI.OnCorpsIDRefreshed()
		if #idList ~= 0 then
			ProfileMgr.GetProfileList(idList,AllianceRecruitUI.OnGetProfileForCorps,true,false)
		end
	end
end

function AllianceRecruitUI.OnGetProfileForCorps(profileList)
	for _,p in pairs (profileList) do
		for _,v in pairs(_Alliance_RecruitList) do
			if tonumber(p.uid) == tonumber(v.gid) then
				v.corps_id = p.corps_id
			end
		end
	end
	AllianceRecruitUI.OnCorpsIDRefreshed()
end


function EventAllianceRecruit_Close()
	UIManager.Hide(eUIType.eAllianceRecruitUI)
end

function AllianceRecruitUI.ChangeIsOnlyShow(isOnlyShow)
	log("AllianceRecruitUI.ChangeIsOnlyShow:" .. tostring(isOnlyShow))
	
	AllianceRecruitUI.isOnlyShow = isOnlyShow
	if AllianceRecruitUI.isOnlyShow then
		LuaClassObj.HandleUIMessageNoFetch(bp_alliance_recruit, "UIOnlyShow");
	else
		LuaClassObj.HandleUIMessageNoFetch(bp_alliance_recruit, "UIOnlyHide");
	end
end

function AllianceRecruitUI.GetStatus()
	return {isOnlyShow = AllianceRecruitUI.isOnlyShow}
end

function AllianceRecruitUI.RecoverStatus(status)
	if status and status.isOnlyShow then
		AllianceRecruitUI.ChangeIsOnlyShow(status.isOnlyShow)
	end
end