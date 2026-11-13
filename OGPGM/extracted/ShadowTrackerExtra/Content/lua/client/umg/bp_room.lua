RoomUI = RoomUI or
{
	IsRegister = false;
	IsShow = false;
	ClickRefreshTime = 0;
	isOnlyShow = true;
}

BP_Zone_Id_In_Room = 0;
BP_ARRAY_ZoneListInRoom = {0};
BP_CreateRoom_Hot_Point_IsShow = false
BP_CreateRoom_Adv_Hot_Point_IsShow = false

--测试修改lua对蓝图的影响
--注册Widget
function bp_room_RegisterUI()
  LuaClassObj.SubUIWidgetList(bp_room,
	{{Path="/Game/UMG/UI_BP/Room/RoomList_BP.RoomList_BP_C", Container="Default", ZOrder=BP_ENUM_UI_ROOM_LIST_ZORDER}},
    {"Lobby"},
	false,
	bp_room_OnModeSwitched ~= nil,
	true
  );
  
  LuaClassObj.SubShowHideEvent(bp_room, { "RoomList_BP_C" });
  
  RoomUI.initGroupTypeList();
  FuncUtil:InitConfigs(); --初始化临时放在这，等有好地方再挪
end

--进入Lobby请求房间界面
function bp_room_OnModeSwitched(gamestatus)
	RoomUI.initGroupTypeList();
	log("bp_room_OnModeSwitched gamestatus = " .. gamestatus);
	-- RoomUI.IsRegister = true;
	if string.lower(gamestatus) == "lobby" then
		-- if RoomWaitingUI.IsRegister then
			log("bp_room room_info_request");
			NetUtil.SendPkg("room_info_request");
		-- end
	else
		RoomUI.IsShow = false;
	end
	
	log("Timer.InsertTimer(1, RoomUI.OnQuickJoinRoomDirect, false)");
	Timer.InsertTimer(1, RoomUI.OnQuickJoinRoomDirect, false);
end


 
--房间信息(定义结构体：当且仅当以BP_STRUCT_开头的table能作为结构体给蓝图访问)
BP_STRUCT_RoomInfo =
{
	name="房间名",
	owner_name = "房主名", 
	owner_id="房主uid",
	map_id = 1,
	state = "房间状态",
	id = 1,
	player_count=1,	
	group_type = 1, --1：单人模式 2:双人模式 4：4人模式
	create_time = 0,	--房间创建时间
	game_start = 0,	--开局了多久时间，state为游戏中才有效
	lock_state = true,	--	密码锁
	version = "",
	ob_count = 0,
	is_anchor_ob = false, -- 房主是否可以观战
	max_room_player = 0,
	max_room_ob = 0,
	room_type = "",
};

--房间信息列表
BP_ARRAY_RoomList = 
{
	BP_STRUCT_RoomInfo=_G.BP_STRUCT_RoomInfo, --定义结构体数组，这种写法要作为规范规定下来
};

--进入房间参数列表
BP_EnterRoom_ID = "";
BP_EnterRoom_Passwd = "";

--进入房间的方式
BP_EnterRoom_Type = 0;	-- 1-输入ID进入房间 2-点击列表进入房间

--选中的房间ID(列表序列id)
BP_SelectRoomID = 0;

--自己的名字
BP_Room_SelfName = "";

--是否是主播
BP_Room_IsAnchor = false;

--客户端版本号(大版本号)
BP_Room_ClientVersion = "";

--房卡信息
BP_Room_CardInfo = "";
BP_Room_CardInfo_Normal = "";
BP_Room_CardInfo_NormalIsTime = false;
BP_Room_CardInfo_Highlevel = "";
BP_Room_CardInfo_HighlevelIsTime = false;
BP_Room_CardInfo_Match = "";

--是否高级房间
BP_Room_IsHighLevelRoom = false;
--是否赛事房间
BP_Room_IsCompetitionRoom = false;
--是否当前列表是普通房间
BP_Room_IsCurListNormalRoom = true;

--刷新列表剩余时间
BP_Room_RefreshLeftTime = 0;

--模式信息
BP_STRUCT_GroupType =
{
	Type = 0, --1,2,4
	GroupName = "",
};


--模式列表
BP_ARRAY_GroupTypeList = 
{
	BP_STRUCT_GroupType=_G.BP_STRUCT_GroupType, 
};

--上次请求进入房间时间
LastRequestJoinRoomTime = 0;

function RoomUI.initGroupTypeList()	
	BP_ARRAY_GroupTypeList = {};
	--table.insert(BP_ARRAY_GroupTypeList, {Type = 1, GroupName = "单人模式"});
	--table.insert(BP_ARRAY_GroupTypeList, {Type = 2, GroupName = "双人模式"});
	--table.insert(BP_ARRAY_GroupTypeList, {Type = 4, GroupName = "四人模式"});
	local groupNameString = Client.GetTableData("LocalizeRes", "110049").TextValue;
	table.insert(BP_ARRAY_GroupTypeList, {Type = 1, GroupName = groupNameString});
	groupNameString = Client.GetTableData("LocalizeRes", "110050").TextValue;
	table.insert(BP_ARRAY_GroupTypeList, {Type = 2, GroupName = groupNameString});
	groupNameString = Client.GetTableData("LocalizeRes", "110051").TextValue;
	table.insert(BP_ARRAY_GroupTypeList, {Type = 4, GroupName = groupNameString});
end



local function roomEventHandler(eventType, eventID, vars)
    if eventType ~= EVENTTYPE_ROOM then
      return;
    end
	
	if eventID == EVENTID_UPDATE_ROOM_LIST then 
		RoomUI:updateBPData();
	elseif eventID == EVENTID_UPDATE_ROOMCARDINFO then
		RoomUI.UpdateRoomCardInfo();
	end
end


function RoomUI:Init()
	log("RoomUI init");
	LuaClassObj.HandleDynamicCreation(bp_room);
	
	BP_Room_SelfName = DataMgr.roleData.nickName;
	if DataMgr.anchor == 1 then
		BP_Room_IsAnchor = true;
	else
		BP_Room_IsAnchor = false;
	end
	BP_Room_ClientVersion = FuncUtil:GetClientFormat(Client.GetAppVersion());	
	
	EventSystem:registEvent(EVENTTYPE_ROOM, EVENTID_UPDATE_ROOM_LIST, roomEventHandler);
	EventSystem:registEvent(EVENTTYPE_ROOM, EVENTID_UPDATE_ROOMCARDINFO, roomEventHandler);
	UIManager.Show(eUIType.eRoomUI)
	local uiStruct = UIManager.GetUI(eUIType.eRoomUI)
	local depth = 100
	if uiStruct then
		depth = uiStruct.depth;
	else
		local num = XList.Len(UIManager.uiShowStack)
		if num > 0 then
			depth = UIManager.uiShowStack[num].depth + 100
		end
	end
	LuaClassObj.SetWidgetZorder(bp_chat_entrance,0,depth+1)
	LuaClassObj.SetWidgetZorder(bp_teamup_friend,0,depth+1)
end


function RoomUI:Release()
	log("RoomUI release");
	BP_Room_SelfName = "";
	BP_Room_IsAnchor = false;
	BP_Room_ClientVersion = "";
	
	RoomUI.IsShow = false;
	LobbyChatEntranceUI.OnRoomModeChanged();
	
	EventSystem:unregistEvent(EVENTTYPE_ROOM, EVENTID_UPDATE_ROOM_LIST, roomEventHandler);
	EventSystem:unregistEvent(EVENTTYPE_ROOM, EVENTID_UPDATE_ROOMCARDINFO, roomEventHandler);
    --LuaClassObj.HandleUIMessage(bp_teamup_friend, "ShowBtnPanel");
	LuaClassObj.RestoreWidgetZorder(bp_expression,0)
	LuaClassObj.HandleUIMessage(bp_chat_entrance, "UIShow");
	UIManager.Hide(eUIType.eRoomUI)
	LuaClassObj.SetWidgetZorder(bp_chat_entrance,0,37)
	LuaClassObj.SetWidgetZorder(bp_teamup_friend,0,34)
end

function RoomUI:RoomShow()
	log("RoomUI:RoomShow")
	RoomUI.ChangeIsOnlyShow(true)
	LuaClassObj.HandleUIMessage(bp_room, "RoomShow");;
end

function RoomUI:RoomHide()
	log("RoomUI:RoomHide")
	LuaClassObj.HandleUIMessage(bp_room, "RoomHide");
end

function RoomUI:updateBPZoneId()
	
	--更新房间选服列表
	BP_Zone_Id_In_Room = RoomSystem.RoomZoneId;
	log("RoomUI:updateBPZoneId, BP_Zone_Id_In_Room " .. BP_Zone_Id_In_Room);
    --【【协议请求量优化】登陆协议量整理和优化】 http://tapd.oa.com/iGameInternational/prong/stories/view/1020360302064176571
    if RoomUI.IsShow then
        RoomSystem.req_room_list();
    end
end

function RoomUI:updateBPData()
	
	--更新房间选服列表
	BP_Zone_Id_In_Room = RoomSystem.RoomZoneId;
	log("RoomUI:updateBPData, BP_Zone_Id_In_Room " .. BP_Zone_Id_In_Room);

	log("RoomUI updateBPData");
	--更新房间列表
	BP_ARRAY_RoomList = FuncUtil:CopyTable(RoomSystem.RoomInfoList);
	BP_ARRAY_RoomList.lock_pos_list = nil;
end

function RoomUI.UpdateRoomCardInfo()
	-- log("RoomUI UpdateRoomCardInfo");
	--更新房卡信息
	--room_cards[]
	local left_ts = DataMgr.room_card_info.expire_ts - NetUtil.GetCurServerTime();
	local left_times = DataMgr.room_card_info.rest_times;
	BP_Room_CardInfo_NormalIsTime = false;
	--永久房卡
	if DataMgr.room_card_info.expire_ts <0 then
		--local msg = Client.GetTableData("LocalizeRes", "110249").TextValue;
		BP_Room_CardInfo = FuncUtil.GetLocalizeResStr("5013");
	--时效卡
	elseif left_ts > 0 then
		local format_ts = RoomUI.FormatRoomCardTime(left_ts);
		if format_ts == "" then
			BP_Room_CardInfo = "";
		else
			--local msg = Client.GetTableData("LocalizeRes", "110249").TextValue;
			BP_Room_CardInfo = format_ts;
			BP_Room_CardInfo_NormalIsTime = true;
		end
	--次数卡
	elseif left_times > 0 then
		BP_Room_CardInfo = FuncUtil.LocalizeResFormat( "6184", tonumber(left_times));
	else
		BP_Room_CardInfo = "";
	end

	left_ts = DataMgr.room_card_info_adv.expire_ts - NetUtil.GetCurServerTime();
	left_times = DataMgr.room_card_info_adv.rest_times;
	BP_Room_CardInfo_HighlevelIsTime = false;
	--永久房卡
	if DataMgr.room_card_info_adv.expire_ts <0 then
		--local msg = Client.GetTableData("LocalizeRes", "110249").TextValue;
		BP_Room_CardInfo_Highlevel = FuncUtil.GetLocalizeResStr("5013");
		--时效卡
	elseif left_ts > 0 then
		local format_ts = RoomUI.FormatRoomCardTime(left_ts);
		if format_ts == "" then
			BP_Room_CardInfo_Highlevel = "";
		else
			--local msg = Client.GetTableData("LocalizeRes", "110249").TextValue;
			BP_Room_CardInfo_Highlevel = format_ts;
			BP_Room_CardInfo_HighlevelIsTime = true;
		end
		--次数卡
	elseif left_times > 0 then
		BP_Room_CardInfo_Highlevel = FuncUtil.LocalizeResFormat( "6184", tonumber(left_times));
	else
		BP_Room_CardInfo_Highlevel = "";
	end

	left_ts = DataMgr.room_card_info_mat.expire_ts - NetUtil.GetCurServerTime();
	left_times = DataMgr.room_card_info_mat.rest_times;
	--永久房卡
	if DataMgr.room_card_info_mat.expire_ts <0 then
		--local msg = Client.GetTableData("LocalizeRes", "110249").TextValue;
		BP_Room_CardInfo_Match = FuncUtil.GetLocalizeResStr("5013");
		--时效卡
	elseif left_ts > 0 then
		local format_ts = RoomUI.FormatRoomCardTime(left_ts);
		if format_ts == "" then
			BP_Room_CardInfo_Match = "";
		else
			--local msg = Client.GetTableData("LocalizeRes", "110249").TextValue;
			BP_Room_CardInfo_Match = format_ts;
		end
		--次数卡
	elseif left_times > 0 then
		BP_Room_CardInfo_Match = FuncUtil.LocalizeResFormat( "6184", tonumber(left_times));
	else
		BP_Room_CardInfo_Match = "";
	end
end

function RoomUI.UpdateRoomHotState()
	LuaClassObj.HandleUIMessage(bp_room, "UpdateCreateRoomHot")
	LuaClassObj.HandleUIMessage(bp_teamup_model, "UpdateRoomHot")
end

function RoomUI.FormatRoomCardTime(left_ts)
	local format_ts = "";
	
	if left_ts == nil or type(left_ts) ~= "number" then
		return format_ts;
	end
	
	local days = math.floor(left_ts/86400);
	local hours = math.fmod(math.floor(left_ts/3600), 24);
	local mins = math.fmod(math.floor(left_ts/60), 60);
	local seconds = math.fmod(left_ts, 60);
	
	if days == 0 and hours == 0 and mins == 0 and seconds == 0 then
		format_ts = "";
	else
		local days_s = FuncUtil.LocalizeResFormat("301153", days);
		local hours_s = FuncUtil.LocalizeResFormat("301155", hours);
		local mins_s = FuncUtil.LocalizeResFormat("301156", mins);
		local seconds_s = FuncUtil.LocalizeResFormat("301157", seconds);
		if days > 0 then
			format_ts = days_s.." "..hours_s.." ".. mins_s;
		else
			format_ts = hours_s.." ".. mins_s.." "..seconds_s;
		end
	end
	
	return format_ts;
end

function RoomUI.UseRoomCardCallBackInRoom()
	CommonItemListUI.Hide();
	RoomCreateUI.Init();
end

function RoomUI.OnQuickJoinRoomImm()
	RoomUI.OnQuickJoinRoom(RoomSystem.QRCodeRoomInfo);
end

function RoomUI.OnQuickJoinRoomDirect()
	log("Timer.InsertTimer(1, RoomUI.OnQuickJoinRoomImm, false)");
	Timer.InsertTimer(1, RoomUI.OnQuickJoinRoomImm, false);
end

function RoomUI.OnQuickJoinRoom(roominfo)
	if roominfo ~= nil and type(roominfo) == "table" then 
		if roominfo.game_roomid ~= nil and roominfo.game_roompw ~= nil then
			log("rmid=" .. roominfo.game_roomid .. " rmpw=" .. roominfo.game_roompw);	
			local curStatus = string.lower(LuaClassObj.GetGameStatus(bp_lobby));
			log("curStatus=" .. curStatus);
			-- 如果在login界面直接返回不清空，待到大厅载入的时候再OnQuickJoinRoom
			if curStatus == "login" then
				return;
			end;
			
			if curStatus == "fighting" or curStatus == "pending" then
				RoomSystem.QRCodeRoomInfo = nil;
				return;
			end;
			
			if curStatus == "createrole" then
				--DataMgr.ShowNoticeByID(110132);
				return;
			end;
			
			if RoomWaitingUI.IsInRoom() then
				DataMgr.ShowNoticeByID(110132);
				RoomSystem.QRCodeRoomInfo = nil;
				return;
			end;
			
			if (TeamUp_Is_Matching) then
				log("TeamUp_Is_Matching");
				DataMgr.ShowNoticeByID(110133);
				RoomSystem.QRCodeRoomInfo = nil;
				return;
			end;
			
			if BP_LobbyPlayerNum > 1 then
				log("BP_LobbyPlayerNum > 1");
				DataMgr.ShowNoticeByID(110103);
				RoomSystem.QRCodeRoomInfo = nil;
				return;
			end
			
			LobbyUI:WakeupHidePanels();
			
			--if Client.IsConnected(NetInterface) then
			-- 不修复10min掉线重用二维码进房间的bug
				RoomSystem.Enter();
				RoomUI:Init();
				RoomSystem.IsQRCodeEnterRoom = true;
				RoomSystem.req_join_room(tonumber(roominfo.game_roomid), roominfo.game_roompw);
			--end;
		end
	end
end




--不做任何事，蓝图里调这个函数将把lua变量的值同步给蓝图变量
function EventFetchInfo()
end

function EventRoomRelease()
	RoomSystem.Release();
	RoomUI:Release();
end

--显示创建房间界面
function EventShowRoomCreateUI()
	RoomCreateUI.Init();
end

--请求房间列表
function EventRequestRoomList()
	RoomUI.ClickRefreshTime = NetUtil.GetCurServerTime();
	RoomSystem.req_room_list();
end

--请求加入房间
function EventRequestJoinRoom()
	log("event_req_room_request " .. BP_SelectRoomID);
	
	if BP_EnterRoom_Type == 1 then
		RoomSystem.req_join_room(tonumber(BP_EnterRoom_ID), BP_EnterRoom_Passwd);
	elseif BP_EnterRoom_Type == 2 then
		if BP_ARRAY_RoomList[BP_SelectRoomID] ~= nil then
			RoomSystem.req_join_room(BP_ARRAY_RoomList[BP_SelectRoomID].id, BP_EnterRoom_Passwd);
		else
			log("request create room: not found room info");
		end
	else
		log("request create room: enter_room type error");
	end
end

--检查输入ID
function EventCheckInputRoomID()
	local id = BP_EnterRoom_ID;
	local idlen = string.len(BP_EnterRoom_ID);
	
	if type(id) ~= "string" then
		BP_EnterRoom_ID = "";
		return;
	end
	
	if idlen <= 0 then
		DataMgr.ShowNoticeByID(110087);
		BP_EnterRoom_ID = "";
		return;
	end
	
	for i=1,idlen do
		local curByte = string.byte(id, i);
		if curByte < 48 or curByte > 57 then
			DataMgr.ShowNoticeByID(110088);
			return;
		end
	end
	
	RoomSystem.req_query_one_room(tonumber(id));
	-- LuaClassObj.HandleUIMessage(bp_room, "ShowEnterRoomPSWUI");
end

--进入房间
function EventEnterRoom()
	local psw = BP_EnterRoom_Passwd;
	local pswlen = string.len(BP_EnterRoom_Passwd);
	
	if type(psw) ~= "string" then
		BP_EnterRoom_Passwd = "";
		return;
	end
	
	-- if pswlen <= 0 then
		-- DataMgr.ShowNoticeByID(110084);
		-- BP_EnterRoom_Passwd = "";
		-- return;
	if pswlen > 6 then
		DataMgr.ShowNoticeByID(110086);
		BP_EnterRoom_Passwd = "";
		return;
	else
		for i=1,pswlen do
			local curByte = string.byte(psw, i)
			if curByte < 48 or (curByte > 57 and curByte < 65) or (curByte > 90 and curByte < 97) or curByte > 122 then
				DataMgr.ShowNoticeByID(110086);
				BP_EnterRoom_Passwd = "";
				return;
			end
		end
	end
	--房间人数已满
	--if BP_ARRAY_RoomList[BP_SelectRoomID].player_count == BP_ARRAY_RoomList[BP_SelectRoomID].max_room_player then
	--	DataMgr.ShowNoticeByID(6837);
	--	return;
	--end
	--频繁点击进入房间
	local curTime = FuncUtil.GetServerTimeInSec();
	if curTime - LastRequestJoinRoomTime <= 2 and curTime - LastRequestJoinRoomTime > 0 then
		DataMgr.ShowNoticeByID(210020);
		return;
	end
	LastRequestJoinRoomTime = FuncUtil.GetServerTimeInSec();

	EventRequestJoinRoom();
end

--不是主播
function EventNotAnchor()
	local left_ts = 0;
	local left_times = 0;
	local _judge = false;
	local _subTypeList = {2103, 2104,2105}
	if BP_Room_IsHighLevelRoom and not BP_Room_IsCompetitionRoom then
		left_ts = DataMgr.room_card_info_adv.expire_ts - NetUtil.GetCurServerTime();
		left_times = DataMgr.room_card_info_adv.rest_times;
		_judge = DataMgr.room_card_info_adv.expire_ts<0 or left_ts > 0 or left_times > 0;
		_subTypeList = {2106, 2107,2108};
	elseif BP_Room_IsHighLevelRoom and BP_Room_IsCompetitionRoom then
			left_ts = DataMgr.room_card_info_mat.expire_ts - NetUtil.GetCurServerTime();
			left_times = DataMgr.room_card_info_mat.rest_times;
			_judge = DataMgr.room_card_info_mat.expire_ts<0 or left_ts > 0 or left_times > 0;
			_subTypeList = {2109};
	else
		left_ts = DataMgr.room_card_info.expire_ts - NetUtil.GetCurServerTime();
		left_times = DataMgr.room_card_info.rest_times;
		_judge = DataMgr.room_card_info.expire_ts<0 or left_ts > 0 or left_times > 0
		_subTypeList = {2103, 2104,2105}
	end
	if _judge then
		RoomCreateUI.Init();
	else
		for k,v in pairs(DataMgr.arrayHallDepotItemInfo) do
			if DataMgr.IsValidTime(v.expireTS) and (v.itemSubType == _subTypeList[1] or v.itemSubType == _subTypeList[2] or v.itemSubType == _subTypeList[3]) then
				local title = Client.GetTableData("LocalizeRes", 117082).TextValue;
				CommonItemListUI.ShowBySubTypeList(title, _subTypeList, RoomUI.UseRoomCardCallBackInRoom);
				return;
			end
		end

		local str = Client.GetTableData("LocalizeRes", 6024).TextValue;
		local tip = Client.GetTableData("LocalizeRes", 117082).TextValue;
		CommonMessageBoxUI:ShowPanel(2, tip, str, function()
			RoomUI:RoomHide()
			LobbyUI.CloseOtherMenu();
			--[[if BP_Room_IsHighLevelRoom then
				JumpUtils.JumpAll(JumpUtils.MODEL_ID_LOBBY,2104001)
				JumpUtils.JumpAll(JumpUtils.MODEL_ID_LOBBY,2104006)
			else
				JumpUtils.JumpAll(JumpUtils.MODEL_ID_LOBBY,2104006)
				JumpUtils.JumpAll(JumpUtils.MODEL_ID_LOBBY,2104001)
			end--]]
			local strRegion = Client.GetPublishRegion();
			if strRegion == "JAPAN" or strRegion == "KOREA" then
				JumpUtils.JumpAll(JumpUtils.MODEL_ID_LOBBY,2103006)
				--local MallOtherTabUrl="game://?module=1003200&Tab1=17&Tab2=0&selectShopId=23001"
				--GlobalData:JumpUrl(MallOtherTabUrl)
			else
				JumpUtils.JumpAll(JumpUtils.MODEL_ID_LOBBY,2104006)
			end
			return true;
		end);
	end
end

--进入房间后
function EventAfterEnterRoomList()
	RoomUI.IsShow = true;
	LobbyChatEntranceUI.OnRoomModeChanged();
end

--离开房间后
function EventAfterLeaveRoomList()
	RoomUI.IsShow = false;
	LobbyChatEntranceUI.OnRoomModeChanged();
end

--游戏中不能加入房间
function EventEnterGamingRoomNotice()
	DataMgr.ShowNoticeByID(110081);
end

--提示版本不一致
function EventVersionNotMatched()
	DataMgr.ShowMessageBoxByID(110091);
end

--打开聊天框
function EventOpenRoomChatUI()
	LobbyChatEntranceUI.SetVisibility(true);
end

--关闭聊天框
function EventCloseRoomChatUI()
	LobbyChatEntranceUI.SetVisibility(false);
end

--刷新房卡信息
function EventRefreshRoomCardInfo()
	RoomUI.UpdateRoomCardInfo();
	LuaClassObj.HandleUIMessage(bp_room, "RefreshRoomCardInfo");
end

--与点击刷新时的时间对比
function EventCompareClickRefreshTime()
	BP_Room_RefreshLeftTime = RoomUI.ClickRefreshTime + 5 - NetUtil.GetCurServerTime();
	--log("BP_Room_RefreshLeftTime = " .. BP_Room_RefreshLeftTime);
	if BP_Room_RefreshLeftTime > 0 then
		LuaClassObj.HandleUIMessage(bp_room, "SetRefreshTime");
	else
		BP_Room_RefreshLeftTime = 0;
		LuaClassObj.HandleUIMessage(bp_room, "ResetRefreshTime");
	end
end

---------------------------- Zone List ------------------------------

--房间内获取服务区列表
function EventGetZoneListInRoom()
	log("EventGetZoneListInRoom");
	--根据RoomZoneId对zonelist根据区服是否是日韩服进行筛选
	local SortedZoneList = {};
	for _,v in ipairs(DataMgr.AllZoneList) do
		zone_id = v;
		if 6 == RoomSystem.RoomZoneId then --当前区服是日韩服
			if 6 == zone_id then
				table.insert(SortedZoneList, v);
			end
		else			--当前区服是非日韩服
			if 6 ~= zone_id then
				table.insert(SortedZoneList, v);
			end
		end
	end

	BP_ARRAY_ZoneListInRoom = SortedZoneList;
end

function EventSelectZoneInRoomList_Push()
	log("EventSelectZoneInRoomList_Push, BP_Zone_Id_In_Room=" .. BP_Zone_Id_In_Room);
	RoomSystem.on_select_zone_req(BP_Zone_Id_In_Room);
	-- RoomSystem.req_room_list();
end

function EventGetMoreRoom()
	RoomSystem.req_more_room_list()
end


function RoomUI.ChangeIsOnlyShow(isOnlyShow)
	log("RoomUI.ChangeIsOnlyShow:" .. tostring(isOnlyShow))
	RoomUI.isOnlyShow = isOnlyShow
	if RoomUI.isOnlyShow then
		LuaClassObj.HandleUIMessageNoFetch(bp_room, "UIOnlyShow");
	else
		LuaClassObj.HandleUIMessageNoFetch(bp_room, "UIOnlyHide");
	end
end

function RoomUI.GetStatus()
	log("RoomUI.GetStatus:" .. tostring(RoomUI.isOnlyShow))
	return {isOnlyShow = RoomUI.isOnlyShow}
end

function RoomUI.RecoverStatus(status)
	if status and status.isOnlyShow ~= nil then
		log("RoomUI.RecoverStatus:" .. tostring(status.isOnlyShow))
		RoomUI.ChangeIsOnlyShow(status.isOnlyShow)
	end

end