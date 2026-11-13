RoomWaitingUI = RoomWaitingUI or
{
	IsRegister = false;
	IsShow = false;
	KickedMemberID = 0;
	isOnlyShow = true;
	IsShowChatEntrance = true,
}

--注册Widget
function bp_room_waiting_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_room_waiting,
		{{Path="/Game/UMG/UI_BP/Room/RoomWaiting_BP.RoomWaiting_BP_C", Container="Default", ZOrder=BP_ENUM_UI_ROOM_WAITING_ZORDER}},
	    {"Lobby"},
		false,
		bp_room_waiting_OnModeSwitched ~= nil,
		true
	);
  
  	RoomWaitingUI.InitRoomGroupTypeList();
  	FuncUtil:InitConfigs(); --初始化临时放在这，等有好地方再挪
  

	EventSystem:registEvent(EVENTTYPE_BIND_INTL, EVENTID_VERSION_UPDATE_IOS_CHECK, RoomWaitingUI.HandleIOSCheck);

	LuaClassObj.SubShowHideEvent(bp_room_waiting, { "RoomWaiting_BP_C" });
end

function RoomWaitingUI.HandleIOSCheck()
	-- body
  if GlobalData:IsIOSCheck() then
    LuaClassObj.SubCollapseWidgetList(bp_room_waiting,
        "RoomWaiting_BP_C",
        {
            "CanvasPanel_12",
        }
    );
    LuaClassObj.HandleCollapseWidgetList(bp_room_waiting, "RoomWaiting_BP_C");
   end
   
end


--进入Lobby请求房间界面
function bp_room_waiting_OnModeSwitched(gamestatus)
	log("bp_room_waiting_OnModeSwitched gamestatus = " .. gamestatus);
	-- RoomWaitingUI.IsRegister = true;
	-- if string.lower(gamestatus) == "lobby" then
		-- if RoomUI.IsRegister then
			-- log("bp_room_waiting room_info_request");
			-- NetUtil.SendPkg("room_info_request");
		-- end
	-- end
	
	if string.lower(gamestatus) ~= "lobby" then
		RoomWaitingUI.IsShow = false;
	end
end



--房间内信息(定义结构体：当且仅当以BP_STRUCT_开头的table能作为结构体给蓝图访问)
BP_STRUCT_RoomWaitingInfo =
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
	max_room_player = 0,
	max_room_ob = 0,
}

--房间成员信息
BP_STRUCT_RoomMemberInfo =
{
	openid="openid",
	name="角色名",
	level=1,
	svr=0,
	isRoomMaster=false,
	pos = 0,
	state = "",
	head_url = "",
	gender = 0,
	frame_level = 0,
	device_type = 0,
};

--房间成员信息列表
BP_ARRAY_RoomMemberList = 
{
	BP_STRUCT_RoomMemberInfo=_G.BP_STRUCT_RoomMemberInfo,
};

--自己的信息
BP_STRUCT_RoomSelfInfo =
{
	openid="openid",
	name="角色名",
	level=1,
	svr=0,
	isRoomMaster=false,
	pos = 0,
	state = "",
	head_url = "",
	gender = 0,
	frame_level = 0,
};

--房间车队信息
BP_STRUCT_RoomCarTeamInfo =
{
	name = "",
	teamFlag = "",
	nationFlag = "",
};
BP_ARRAY_RoomCarteamList =
{
	BP_STRUCT_RoomCarTeamInfo=_G.BP_STRUCT_RoomCarTeamInfo
};


--房间离开或换位成员的信息
BP_ARRAY_RoomOldMemberInfoList =
{
	BP_STRUCT_RoomMemberInfo=_G.BP_STRUCT_RoomMemberInfo,
};

--房间新增成员的基本信息
BP_ARRAY_RoomNewMemberInfoList =
{
	BP_STRUCT_RoomMemberInfo=_G.BP_STRUCT_RoomMemberInfo,
};

--房间新增成员的信息（拉取了头像）
BP_ARRAY_RoomNewMemberAllInfoList =
{
	BP_STRUCT_RoomMemberInfo=_G.BP_STRUCT_RoomMemberInfo,
};

--房间密码
BP_Room_Passwd = "";

--是否房主
BP_IsRoomOwner = false;

--选中的新的位置
BP_SelectNewPos = -1;

--被踢的位置
BP_KickedMemberPos = 0;

--自己的uid
BP_Room_SelfID = "";

--旧位置
BP_Room_SelfOldPos = 0;

--被点击玩家的ID
BP_Room_SelectedRoleID = "";

--修改的房间名
BP_Room_ChangeName = "";

--是否主动离开房间
BP_Room_InitiativeLeave = false;

--是否在房间
BP_Room_IsInRoom = false;

--二维码图片路径
BP_Room_QRIamgePath = "";

BP_Room_Zone_Id = 0;
BP_ARRAY_RoomZoneList = {0};
--模式信息
BP_STRUCT_RoomGroupType =
{
	Type = 0, --1,2,4
	GroupName = "",
};

--模式列表
BP_ARRAY_RoomGroupTypeList = 
{
	BP_STRUCT_RoomGroupType=_G.BP_STRUCT_RoomGroupType, 
};

--当前选择的Group
BP_SelectedGroupType= 0;

--当前选择的地图ID
BP_SelectedMapID = 0;

--玩家旧位置
BP_RoleOldPos = 0;

--玩家新位置
BP_RoleNewPos = 0;

--可否拉概要
BP_Room_CanGetProfile = false;

--是否观战编辑状态
BP_Room_IsObEditState = false;

--锁位置
BP_Room_LockedPos = 0;

--解锁位置
BP_Room_UnLockedPos = 0;

--房间锁位置列表
BP_ARRAY_RoomLockInfoList = 
{
	lock_pos = 0,
};

--比赛倒计时
BP_Room_Waiting_RemainTime = "";

--房间解散时间
BP_Room_Waiting_DisbandTime = "";

function RoomWaitingUI.InitRoomGroupTypeList()	
	BP_ARRAY_RoomGroupTypeList = {};
	--table.insert(BP_ARRAY_RoomGroupTypeList, {Type = 1, GroupName = "单人模式"});
	--table.insert(BP_ARRAY_RoomGroupTypeList, {Type = 2, GroupName = "双人模式"});
	--table.insert(BP_ARRAY_RoomGroupTypeList, {Type = 4, GroupName = "四人模式"});
	local groupNameString = Client.GetTableData("LocalizeRes", "110049").TextValue;
	table.insert(BP_ARRAY_RoomGroupTypeList, {Type = 1, GroupName = groupNameString});
	groupNameString = Client.GetTableData("LocalizeRes", "110050").TextValue;
	table.insert(BP_ARRAY_RoomGroupTypeList, {Type = 2, GroupName = groupNameString});
	groupNameString = Client.GetTableData("LocalizeRes", "110051").TextValue;
	table.insert(BP_ARRAY_RoomGroupTypeList, {Type = 4, GroupName = groupNameString});
end

local function RoomWaitingEventHandler(eventType, eventID, vars)
    if eventType ~= EVENTTYPE_ROOM then
		return;
    end
    
    if eventID == EVENTID_UPDATE_ROOMMEMBER_LIST then 
		RoomWaitingUI:UpdateBPData();
	elseif eventID == EVENTID_UPDATE_CURRENTROOMINFO then
		RoomWaitingUI:UpdateBPCurrentRoomInfo();
    end
end

function RoomWaitingUI:Init()
	LuaClassObj.HandleDynamicCreation(bp_room_waiting);
	
	BP_Room_SelfID = DataMgr.roleData.uid;
	BP_Room_InitiativeLeave = false;
	BP_Room_IsInRoom = false;
	BP_Room_CanGetProfile = false;

	RoomWaitingUI.IsShowChatEntrance = true

	
	EventSystem:registEvent(EVENTTYPE_ROOM, EVENTID_UPDATE_ROOMMEMBER_LIST, RoomWaitingEventHandler);
	EventSystem:registEvent(EVENTTYPE_ROOM, EVENTID_UPDATE_CURRENTROOMINFO, RoomWaitingEventHandler);
	--ALuaClassObj::SetWidgetZorder(const int32 index,const int32 zOrder)

	--add by cole 解决bug通过邀请跳转房间
	EventStartCloseMallSystem()
	AllianceUI:CloseTeamMainPanel()
	WarZoneRankUI.CloseUI()
	RoleInfoUI.BtnCloseRoleInfo()
	ArmoryUI.CloseUI()
	ItemUpgradeUI.Hide();
	CreateRoleUI.ClosePanel()

	UIManager.Show(eUIType.eRoomWaitingUI)
	local uiStruct = UIManager.GetUI(eUIType.eRoomWaitingUI)
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
	LuaClassObj.HandleUIMessage(bp_teamup_friend, "HideBtnPanel");
	LuaClassObj.HandleUIMessage(bp_chat_entrance, "ShowInviteFriendBtnForRoom");
end

function RoomWaitingUI:EnterRoom()
	RoomWaitingUI.ChangeIsOnlyShow(true)
	LuaClassObj.HandleUIMessage(bp_room_waiting, "EnterRoom");
	LuaClassObj.HandleUIMessage(bp_chat_entrance, "ShowInviteFriendBtnForRoom");
end

function RoomWaitingUI:LeaveRoom()
	LuaClassObj.HandleUIMessage(bp_room_waiting, "LeaveRoom");
	LuaClassObj.HandleUIMessage(bp_chat_entrance, "HideInviteFriendBtnForRoom");
end


function RoomWaitingUI:Release()
	log("RoomWaitingUI release");
	BP_Room_SelfID = "";
	BP_Room_InitiativeLeave = false;
	BP_Room_IsInRoom = false;
	BP_Room_CanGetProfile = false;
	
	RoomWaitingUI.IsShow = false;
	LobbyChatEntranceUI.OnRoomModeChanged();

	RoomWaitingUI.IsShowChatEntrance = true;

	EventSystem:unregistEvent(EVENTTYPE_ROOM, EVENTID_UPDATE_ROOMMEMBER_LIST, RoomWaitingEventHandler);
	EventSystem:unregistEvent(EVENTTYPE_ROOM, EVENTID_UPDATE_CURRENTROOMINFO, RoomWaitingEventHandler);

	--ALuaClassObj::RestoreWidgetZorder(const int32 index)

	RoomUI:RoomHide()

	if RoomWaitingUI.TimeRemainTimer ~= nil then
		Timer.RemoveTimer(RoomWaitingUI.TimeRemainTimer)
		RoomWaitingUI.TimeRemainTimer = nil
	end
	if RoomWaitingUI.TimeDisbandTimer ~= nil then
		Timer.RemoveTimer(RoomWaitingUI.TimeDisbandTimer)
		RoomWaitingUI.TimeDisbandTimer = nil
	end
	UIManager.Hide(eUIType.eRoomWaitingUI)
	LuaClassObj.SetWidgetZorder(bp_chat_entrance,0,37)
	LuaClassObj.SetWidgetZorder(bp_teamup_friend,0,34)
	LuaClassObj.HandleUIMessage(bp_teamup_friend, "ShowBtnPanel");
	LuaClassObj.HandleUIMessage(bp_chat_entrance, "HideInviteFriendBtnForRoom");
end

function RoomWaitingUI:UpdateBPData()
	log("RoomWaitingUI UpdateBPData "..tostring(RoomSystem.CurrentRoomInfo.disband_tm));
	
	--是否房主
	if not RoomSystem.isRoomOwner() then
		BP_IsRoomOwner = false;
	else
		BP_IsRoomOwner = true;
	end
	
	--更新房间信息
	BP_STRUCT_RoomWaitingInfo = FuncUtil:CopyTable(RoomSystem.CurrentRoomInfo);
	if BP_STRUCT_RoomWaitingInfo ~= nil then
		log("[CLLL] "..tostring(BP_STRUCT_RoomWaitingInfo.id))
		if BP_STRUCT_RoomWaitingInfo.id then
			DataMgr.RoomID = BP_STRUCT_RoomWaitingInfo.id;
		end
		if  BP_STRUCT_RoomWaitingInfo.id and BP_STRUCT_RoomWaitingInfo.id > 10000000 and BP_STRUCT_RoomWaitingInfo.id < 20000000 then
			BP_STRUCT_RoomWaitingInfo.name = BP_LeagueGame_MatchStageName;
			RoomWaitingUI:ShowRoomWaitingTimeRemain()
		elseif BP_STRUCT_RoomWaitingInfo.id and BP_STRUCT_RoomWaitingInfo.id > 20000000 and BP_STRUCT_RoomWaitingInfo.id < 100000000 then
			BP_STRUCT_RoomWaitingInfo.name = IndiaChampionShipLogic.GetEnrollName();
			RoomWaitingUI:ShowRoomWaitingTimeRemain()
		end
		-- log_tree("--roominfo--", BP_STRUCT_RoomWaitingInfo);
	end

	RoomWaitingUI:ShowRoomWaitingTimeDisband()
	
	--更新玩家列表
	BP_ARRAY_RoomMemberList = {};
	BP_STRUCT_RoomSelfInfo = {};
	if RoomSystem.CurrentRoomInfo ~= nil and RoomSystem.CurrentRoomInfo.MemberInfoList ~= nil then
		for i=1, #RoomSystem.CurrentRoomInfo.MemberInfoList do
			local _memberInfo = FuncUtil:CopyTable(RoomSystem.CurrentRoomInfo.MemberInfoList[i]);
			if _memberInfo ~= nil then
				if _memberInfo.device_type == nil then
					_memberInfo.device_type = 0;
				end
				
				table.insert(BP_ARRAY_RoomMemberList, _memberInfo);
				if _memberInfo.openid == DataMgr.roleData.uid then
					BP_STRUCT_RoomSelfInfo = FuncUtil:CopyTable(_memberInfo);
				end
			end
		end   
	end
	--更新房间选服列表
	BP_Room_Zone_Id = RoomSystem.RoomZoneId;
    if  BP_STRUCT_RoomWaitingInfo.id and BP_STRUCT_RoomWaitingInfo.id > 10000000 and BP_STRUCT_RoomWaitingInfo.id < 100000000 then
        BP_Room_Zone_Id = BP_STRUCT_RoomWaitingInfo.zone_id;
    end
	--log_tree("--memberlist--", BP_ARRAY_RoomMemberList);
	--log_tree("--selfinfo--", BP_STRUCT_RoomSelfInfo);
	
	--更新锁信息
	BP_ARRAY_RoomLockInfoList = {};
	if RoomSystem.CurrentRoomInfo ~= nil and RoomSystem.CurrentRoomInfo.lock_pos_list ~= nil then
		BP_ARRAY_RoomLockInfoList = FuncUtil:CopyTable(RoomSystem.CurrentRoomInfo.lock_pos_list);
	end
	-- log_tree("BP_ARRAY_RoomLockInfoList =", BP_ARRAY_RoomLockInfoList);
	
	--更新同步的玩家信息
	BP_ARRAY_RoomOldMemberInfoList = {};
	BP_ARRAY_RoomOldMemberInfoList = FuncUtil:CopyTable(RoomSystem.RoomOldMemberInfoList);
	-- log_tree("BP_ARRAY_RoomOldMemberInfoList",BP_ARRAY_RoomOldMemberInfoList);
	
	BP_ARRAY_RoomNewMemberInfoList = {};
	BP_ARRAY_RoomNewMemberInfoList = FuncUtil:CopyTable(RoomSystem.RoomNewMemberInfoList);
	-- log_tree("BP_ARRAY_RoomNewMemberInfoList",BP_ARRAY_RoomNewMemberInfoList);
	
	BP_ARRAY_RoomNewMemberAllInfoList = {};
	BP_ARRAY_RoomNewMemberAllInfoList = FuncUtil:CopyTable(RoomSystem.RoomNewMemberAllInfoList);
	-- log_tree("BP_ARRAY_RoomNewMemberAllInfoList",BP_ARRAY_RoomNewMemberAllInfoList);

	--房间解散时间
	BP_Room_Waiting_DisbandTime = RoomSystem.CurrentRoomInfo.disband_tm and RoomSystem.CurrentRoomInfo.disband_tm - FuncUtil.GetServerTimeInSec() or -1;
	-- log_tree("--memberlist--", BP_ARRAY_RoomMemberList);
	-- log_tree("--selfinfo--", BP_STRUCT_RoomSelfInfo);
end

function RoomWaitingUI:UpdateBPCurrentRoomInfo()
	log("RoomWaitingUI UpdateBPCurrentRoomInfo");
	
	--更新房间信息
	BP_STRUCT_RoomWaitingInfo = FuncUtil:CopyTable(RoomSystem.CurrentRoomInfo);
	if BP_STRUCT_RoomWaitingInfo ~= nil then
		if BP_STRUCT_RoomWaitingInfo.id and BP_STRUCT_RoomWaitingInfo.id > 10000000 and BP_STRUCT_RoomWaitingInfo.id < 20000000 then
			BP_STRUCT_RoomWaitingInfo.name = BP_LeagueGame_MatchStageName;
		elseif BP_STRUCT_RoomWaitingInfo.id and BP_STRUCT_RoomWaitingInfo.id > 20000000 and BP_STRUCT_RoomWaitingInfo.id < 100000000 then
			BP_STRUCT_RoomWaitingInfo.name = IndiaChampionShipLogic.GetEnrollName();
		end
		-- log_tree("--roominfo--", BP_STRUCT_RoomWaitingInfo);
	end
end

function RoomWaitingUI.OnClickBtnDisbandOK()
	RoomSystem.req_exit_room();
end

function RoomWaitingUI.IsInRoom()
	return BP_Room_IsInRoom;
end

function RoomWaitingUI.SetQRImagePath(QRImagePath)
	BP_Room_QRIamgePath = QRImagePath;
end

function RoomWaitingUI.OnClickBtnKickOK()
	RoomSystem.req_room_kick_request(BP_STRUCT_RoomWaitingInfo.id,  RoomWaitingUI.KickedMemberID);
end

function RoomWaitingUI.GetTeamMemberInfo()
	log("RoomWaitingUI GetTeamMemberInfo");
	local uid_list = {};
	
	if BP_STRUCT_RoomSelfInfo.pos > 100 then
		table.insert(uid_list, tonumber(BP_STRUCT_RoomSelfInfo.openid));
		return uid_list;
	end
	
	if BP_STRUCT_RoomWaitingInfo.group_type == 1 then
		table.insert(uid_list, tonumber(BP_STRUCT_RoomSelfInfo.openid));
	elseif BP_STRUCT_RoomWaitingInfo.group_type == 2 then
		local myTeamNum = math.floor((BP_STRUCT_RoomSelfInfo.pos-1)/2);
		for k,v in pairs(BP_ARRAY_RoomMemberList) do
			if math.floor((v.pos-1)/2) == myTeamNum then
				table.insert(uid_list, tonumber(v.openid));
			end
		end
	elseif BP_STRUCT_RoomWaitingInfo.group_type == 4 then
		local myTeamNum = math.floor((BP_STRUCT_RoomSelfInfo.pos-1)/4);
		for k,v in pairs(BP_ARRAY_RoomMemberList) do
			if math.floor((v.pos-1)/4) == myTeamNum then
				table.insert(uid_list, tonumber(v.openid));
			end
		end
	end
	return uid_list;
end

--不做任何事，蓝图里调这个函数将把lua变量的值同步给蓝图变量
function EventFetchInfo()
end

function EventRoomWaitingRelease()
	log("EventRoomWaitingRelease");
	RoomWaitingUI:Release();	
end

--请求更换位置
function EventRequestChangeRoomPos()
	log("EventRequestChangeRoomPos " .. BP_SelectNewPos);
	
	if BP_STRUCT_RoomWaitingInfo == nil then
		log("request change room: not found room info");
		return;		
	end
	
	BP_Room_SelfOldPos = BP_STRUCT_RoomSelfInfo.pos;
	
	RoomSystem.req_change_room_pos_request(BP_STRUCT_RoomWaitingInfo.id, BP_SelectNewPos+1)
end

--请求踢人
function EventRequestKickMember()
	log("EventRequestKickMember " .. BP_KickedMemberPos);
	
	if not RoomSystem.isRoomOwner() then
		log("kick member: not room owner");
		return;
	end
	
	if BP_STRUCT_RoomWaitingInfo == nil then
		log("kick member: not found room info");
		return;		
	end
	
	local findKickedMemberID = "";
	for memberIndex = 1, #BP_ARRAY_RoomMemberList do
		local memberInfo = BP_ARRAY_RoomMemberList[memberIndex];
		if memberInfo ~= nil and memberInfo.pos == BP_KickedMemberPos then
			findKickedMemberID = memberInfo.openid;
			break;
		end
	end
	
	if findKickedMemberID == "" then
		log("kick member: not find memberID");
		return;		
	end
	
	RoomWaitingUI.KickedMemberID = tonumber(findKickedMemberID);
	local title_data = Client.GetTableData("LocalizeRes", 101001);
	local title = tostring(title_data.TextValue);
	local msg_data = Client.GetTableData("LocalizeRes", 110136);
	local msg = tostring(msg_data.TextValue);
	CommonMessageBoxUI:ShowPanel(2, title, msg, RoomWaitingUI.OnClickBtnKickOK);
end

--退出房间
function EventExitRoom()
	RoomSystem.req_exit_room();
end

--开始游戏
function EventStarGame()
	if BP_STRUCT_RoomWaitingInfo.state == "gaming" then
		DataMgr.ShowNoticeByID(110130);
		return;
	end
	RoomSystem.req_start_game();
end

--房间内修改房间模式
function EventChangeRoomType()
	RoomSystem.req_change_room_group_type(BP_STRUCT_RoomWaitingInfo.id, BP_SelectedGroupType);
end

--房间内修改地图
function EventChangeMap()
	RoomSystem.req_change_room_map(BP_STRUCT_RoomWaitingInfo.id, BP_SelectedMapID);
end

--提示只能房主点击切换模式
function EventOnlyRoomMasterCanClick()
	DataMgr.ShowNoticeByID(110098);
end

--提示房主是否解散房间
function EventWhetherDisbandRoom()
	local title_data = Client.GetTableData("LocalizeRes", 101001);
	local title = tostring(title_data.TextValue);
	local msg_data = Client.GetTableData("LocalizeRes", 110099);
	local msg = tostring(msg_data.TextValue);
	CommonMessageBoxUI:ShowPanel(2, title, msg, RoomWaitingUI.OnClickBtnDisbandOK);
end

--打开个人信息
function EventOpenRoleInfo()
	RoleInfoSystem.Enter(BP_Room_SelectedRoleID);
    RoleInfoUI.Init(true, RoleInfoOpenFromType.RoomWaitingInfo);
end

--修改房间名
function EventChangeRoomName()
	RoomSystem.req_change_room_name(BP_STRUCT_RoomWaitingInfo.id, BP_Room_ChangeName);
end

--生成二维码
function EventCreateQRImage()
	RoomSystem.InviteJoinRoomQQ(BP_STRUCT_RoomWaitingInfo.id, BP_CreateRoom_Passwd);
end

--打开聊天框
function EventOpenRoomWaitingChatUI()
	RoomWaitingUI.IsShow = true;

	RoomWaitingUI.IsShowChatEntrance = true
	LobbyChatEntranceUI.OnRoomModeChanged()
	LobbyChatEntranceUI.SetVisibility(true);
end

--关闭聊天框
function EventCloseRoomWaitingChatUI()
	RoomWaitingUI.IsShowChatEntrance = false
	LobbyChatEntranceUI.SetVisibility(false);
end

--保存本地成功
function EventSaveSuccess()
	DataMgr.ShowNoticeByID(110124);
end

--战斗中不能踢人
function EventKickRoleDisable()
	DataMgr.ShowNoticeByID(110130);
end

--战斗中不能点击按钮
function EventBtnDisableInGaming()
	DataMgr.ShowNoticeByID(110130);
end

function EventRoomSelectZone_Push()
	log("EventRoomSelectZone_Push, BP_Room_Zone_Id="..BP_Room_Zone_Id);
	RoomSystem.on_select_zone_req(BP_Room_Zone_Id);
end

function EventRoomGetZoneList()
	log("EventRoomGetZoneList");	
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
	BP_ARRAY_RoomZoneList = SortedZoneList;
end

--拉取新入房间人概要
function EventGetNewMemberProfInfo()
	-- LuaClassObj.HandleUIMessage(bp_room_waiting, "RefreshNewMemberInfo");
	RoomSystem.req_profile_sync_room();
end

--切换到观战编辑状态
function EventChangeToObEditState()
	BP_Room_IsObEditState = true;
	LuaClassObj.HandleUIMessage(bp_room_waiting, "SetObEditStateUI");
end

--切换到非观战编辑状态
function EventChangeToObEditDisableState()
	BP_Room_IsObEditState = false;
	LuaClassObj.HandleUIMessage(bp_room_waiting, "SetObEditDisableStateUI");
end

--锁ob位
function EventLockObPos()
	RoomSystem.req_lock_room_pos(BP_Room_LockedPos);
end

--解锁ob位
function EventUnLockObPos()
	RoomSystem.req_unlock_room_pos(BP_Room_UnLockedPos);
end

--房间打开设置参数界面
function EventOpenRoomCustomSettingUI()
	RoomCreateUI.ShowUIInRoom();
end

--更新房间内车队信息
function RoomWaitingUI:SetCarteam(serverCartemInfo)
	BP_STRUCT_RoomCarTeamInfo =
	{
		name = "",
		teamFlag = "",
		nationFlag = "",
	};
	BP_ARRAY_RoomCarteamList = {};
	for i=1,25 do
		local _teamInfo = {}
		_teamInfo.name = "";
		_teamInfo.teamFlag = "";
		_teamInfo.nationFlag = "";
		BP_ARRAY_RoomCarteamList[i]=_teamInfo;
	end

	if serverCartemInfo then
		local guidonConfig = Client.GetTable("GuidonConfig");
		local nationConfig = FuncUtil.GetRegionConfigTable();
		for k,v in pairs(serverCartemInfo) do
			local _teamInfo = {}
			if not v.team_flag then
				v.team_flag = "1"			
			end
			if not v.nation_flag then
				v.nation_flag = "AD"
			end
			_teamInfo.name = v.name;
			if guidonConfig[v.team_flag] then
				_teamInfo.teamFlag = guidonConfig[v.team_flag].res_path;
			end
			if nationConfig[v.nation_flag] then
				_teamInfo.nationFlag = nationConfig[v.nation_flag].res_path;
			end
			BP_ARRAY_RoomCarteamList[k] = _teamInfo;
			--table.insert(BP_ARRAY_RoomCarteamList,_teamInfo);
		end
	end
	log_tree("RoomWaitingUI:SetCarteam: ",BP_ARRAY_RoomCarteamList);
end

--增量更新房间内车队信息
function RoomWaitingUI:AddCarteam(serverCartemInfo,pos)
	if serverCartemInfo then
		local guidonConfig = Client.GetTable("GuidonConfig");
		local nationConfig = FuncUtil.GetRegionConfigTable();
		local _teamInfo = {}
		if not serverCartemInfo.team_flag then
			serverCartemInfo.team_flag = "1"
		end
		if not serverCartemInfo.nation_flag then
			serverCartemInfo.nation_flag = "AD"
		end
		_teamInfo.name = serverCartemInfo.name;
		_teamInfo.teamFlag = guidonConfig[serverCartemInfo.team_flag].res_path;
		_teamInfo.nationFlag = nationConfig[serverCartemInfo.nation_flag].res_path;
		local index=math.ceil(pos/4);
		BP_ARRAY_RoomCarteamList[index] = _teamInfo;
	end
	log_tree("RoomWaitingUI:AddCarteam: ",BP_ARRAY_RoomCarteamList);
end

function EventRoomWaitingUIGetTimeRemain()
	local timeRemain = 0;
	if BP_STRUCT_RoomWaitingInfo.id and BP_STRUCT_RoomWaitingInfo.id > 10000000 and BP_STRUCT_RoomWaitingInfo.id < 20000000 then
		timeRemain = LeagueGameSystem.end_time - FuncUtil.GetServerTimeInSec()
	elseif BP_STRUCT_RoomWaitingInfo.id and BP_STRUCT_RoomWaitingInfo.id > 20000000 and BP_STRUCT_RoomWaitingInfo.id < 100000000 then
		timeRemain = IndiaChampionShipLogic.GetEnrollStartTime() - FuncUtil.GetServerTimeInSec()
	end
	BP_Room_Waiting_RemainTime = FuncUtil.FormatTimeCountDown(timeRemain);
end

function RoomWaitingUI.UpdateRoomWaitingTimeRemain()
	local timeRemain = 0;
	if BP_STRUCT_RoomWaitingInfo.id and BP_STRUCT_RoomWaitingInfo.id > 10000000 and BP_STRUCT_RoomWaitingInfo.id < 20000000 then
		timeRemain = LeagueGameSystem.end_time - FuncUtil.GetServerTimeInSec()
	elseif BP_STRUCT_RoomWaitingInfo.id and BP_STRUCT_RoomWaitingInfo.id > 20000000 and BP_STRUCT_RoomWaitingInfo.id < 100000000 then
		timeRemain = IndiaChampionShipLogic.GetEnrollStartTime() - FuncUtil.GetServerTimeInSec()
	end
	BP_Room_Waiting_RemainTime = FuncUtil.FormatTimeCountDown(timeRemain);
	LuaClassObj.HandleUIMessage(bp_room_waiting,"SetRoomWaitingTimeRemainText")
end

function RoomWaitingUI:ShowRoomWaitingTimeRemain()
	if RoomWaitingUI.TimeRemainTimer ~= nil then
		Timer.RemoveTimer(RoomWaitingUI.TimeRemainTimer)
		RoomWaitingUI.TimeRemainTimer = nil
	end
	RoomWaitingUI.TimeRemainTimer = Timer.InsertTimer(1, RoomWaitingUI.UpdateRoomWaitingTimeRemain, true, false)
end

function RoomWaitingUI.UpdateRoomWaitingTimeDisband()
	local timeRemain = 0;
	if RoomSystem.CurrentRoomInfo.disband_tm and RoomSystem.CurrentRoomInfo.disband_tm then
		timeRemain = RoomSystem.CurrentRoomInfo.disband_tm - FuncUtil.GetServerTimeInSec()
	end
	BP_Room_Waiting_DisbandTime = timeRemain > 0 and FuncUtil.FormatTimeCountDown(timeRemain) or "";
	LuaClassObj.HandleUIMessage(bp_room_waiting,"SetRoomDisbandTime")
end

function RoomWaitingUI:ShowRoomWaitingTimeDisband()
	if RoomWaitingUI.TimeDisbandTimer ~= nil then
		Timer.RemoveTimer(RoomWaitingUI.TimeDisbandTimer)
		RoomWaitingUI.TimeDisbandTimer = nil
	end
	RoomWaitingUI.TimeDisbandTimer = Timer.InsertTimer(1, RoomWaitingUI.UpdateRoomWaitingTimeDisband, true, false)
end

function RoomWaitingUI.ChangeIsOnlyShow(isOnlyShow)
	log("RoomWaitingUI.ChangeIsOnlyShow:" .. tostring(isOnlyShow))
	RoomWaitingUI.isOnlyShow = isOnlyShow
	if RoomWaitingUI.isOnlyShow then
		LuaClassObj.HandleUIMessageNoFetch(bp_room_waiting, "UIOnlyShow");
	else
		LuaClassObj.HandleUIMessageNoFetch(bp_room_waiting, "UIOnlyHide");
	end
end

function RoomWaitingUI.GetStatus()
	log("RoomWaitingUI.GetStatus:" .. tostring(RoomWaitingUI.isOnlyShow))
	return {isOnlyShow = RoomWaitingUI.isOnlyShow}
end

function RoomWaitingUI.RecoverStatus(status)
	if status and status.isOnlyShow ~= nil then
		log("RoomWaitingUI.RecoverStatus:" .. tostring(status.isOnlyShow))
		RoomWaitingUI.ChangeIsOnlyShow(status.isOnlyShow)
	end
end