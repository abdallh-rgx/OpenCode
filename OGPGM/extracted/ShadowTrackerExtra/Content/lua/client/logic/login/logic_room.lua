--[[
  房间的相关逻辑
]]--
RoomModeCreateState = {
	CanCreate 			= 1,	-- 可以创建
	HaveCard 			= 2,	-- 有房卡
	NoCard 				= 3,	-- 没有房卡
	Closed 				= 4,	-- 模式关闭
	NoVersionMatched 	= 5		-- 模式没有任何可以匹配的版本号
}

RoomSystem =  RoomSystem or {
	RoomInfoList = {},
	
	CurrentRoomInfo = {},
	QRCodeRoomInfo = {},
	SelectRoomId = 0,
	RoomZoneId = 0,
	RoomOldMemberInfoList = {},
	RoomNewMemberInfoList = {},
	RoomNewMemberAllInfoList = {},
	
	IsQRCodeEnterRoom = false,
	AcceptJoinRoom = false;
}

IsRoomToBattle = false;
RoomDisbandReason = "";

function RoomSystem.isRoomOwner()
	if  RoomSystem.CurrentRoomInfo == nil then
		return false;
	end

	if tonumber(RoomSystem.CurrentRoomInfo.owner_id) == tonumber(DataMgr.roleData.uid) then
		return true;
	else
		return false;
	end
end


function RoomSystem.Enter()
	log("RoomSystem Enter");
	
	RoomSystem.RoomInfoList = {};
	RoomSystem.CurrentRoomInfo = {};
	RoomSystem.SelectRoomId = 0;
	RoomSystem.RoomOldMemberInfoList = {};
	RoomSystem.RoomNewMemberInfoList = {};
	RoomSystem.RoomNewMemberAllInfoList = {};
	RoomSystem.CurrentCarteamInfo = {};
	RoomSystem.MyUID = DataMgr.roleData.uid;

	RoomSystem.req_room_list();
	RoomSystem.isEnterRoomGettingRoomList = true;
end


function RoomSystem.Release()
	log("RoomSystem Release");
	RoomSystem.RoomInfoList = {};
	RoomSystem.CurrentRoomInfo = {};
	RoomSystem.SelectRoomId = 0;
	RoomSystem.RoomOldMemberInfoList = {};
	RoomSystem.RoomNewMemberInfoList = {};
	RoomSystem.RoomNewMemberAllInfoList = {};
	RoomSystem.CurrentCarteamInfo = {};
end

function RoomSystem.BeKicked()
	log("RoomSystem BeKicked");

	--清空房间
	RoomSystem.CurrentRoomInfo = {};

	--更新房间蓝图数据
	EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_UPDATE_ROOMMEMBER_LIST);
	
	--提示被移出房间
	local curStatus = string.lower(LuaClassObj.GetGameStatus(bp_lobby));
	if curStatus == "lobby" then
		if BP_Room_InitiativeLeave == false then
			local title_data = Client.GetTableData("LocalizeRes", 101001);
			local title = tostring(title_data.TextValue);
			local msg_data = Client.GetTableData("LocalizeRes", 110085);
			local msg = tostring(msg_data.TextValue);
			CommonMessageBoxUI:ShowPanel(1, title, msg);
		else
			BP_Room_InitiativeLeave = false;
		end
	end
	
	--退出房间
	BP_Room_InitiativeLeave = false;
	BP_Room_IsInRoom = false;


	RoomWaitingUI:LeaveRoom()
	
	if curStatus == "lobby" then
		IsRoomToBattle = false;
		--刷新下当前的房间列表
		--RoomSystem.req_room_list();
	end
end

--生成QQ房间邀请二维码
function RoomSystem.InviteJoinRoomQQ(roomid, roompw)
	log("RoomSystem InviteJoinRoomQQ")
	local gamedata = "rmid:" .. roomid .. ",rmpw:".. roompw .. ",t:" .. math.floor(os.time() / 60);
	QRCodeHandler.GenQRImage(QRCodeGenType.ROOM, gamedata);
end

function RoomSystem.OnLoadStartGameFailed()
	log("RoomSystem OnLoadStartGameFailed");
	-- LoadingUI:Hide();
	LoadingUI.RefreshLoadPercent(1);
	Client.ReturnToLobby(GameFrontendHUD);
end

function RoomSystem.GetProfileAfterJoinRoom(listinfo)
	log("RoomSystem GetProfileAfterJoinRoom");
	
	for k,v in pairs(listinfo) do
		for kk,vv in pairs(RoomSystem.CurrentRoomInfo.MemberInfoList) do
			if tonumber(v.uid) == tonumber(vv.openid) then
				if tonumber(v.uid) == tonumber(DataMgr.roleData.uid) then
					vv["head_url"] = DataMgr.roleData.headIconUrl;
					vv["gender"] = DataMgr.roleData.gender;
					vv["frame_level"] = DataMgr.roleData.cur_avatar_box_id;
				else
					vv["head_url"] = v.picUrl;
					vv["gender"] = v.sex;
					vv["frame_level"] = v.cur_avatar_box_id;
				end
				break;
			end
		end
	end
	
	RoomWaitingUI:Init();
	
	--更新房间蓝图数据
	EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_UPDATE_ROOMMEMBER_LIST);
	
	LuaClassObj.HandleUIMessage(bp_room, "ClosePSWUIAfterEnterRoom");

	RoomWaitingUI:EnterRoom()
end

function RoomSystem.GetProfileAfterSync(listinfo)
	log("RoomSystem GetProfileAfterSync");
	
	RoomSystem.RoomNewMemberAllInfoList = {};
	
	for k,v in pairs(listinfo) do
		for kk,vv in pairs(RoomSystem.CurrentRoomInfo.MemberInfoList) do
			if tonumber(v.uid) == tonumber(vv.openid) then
				if tonumber(v.uid) == tonumber(DataMgr.roleData.uid) then
					vv["head_url"] = DataMgr.roleData.headIconUrl;
					vv["gender"] = DataMgr.roleData.gender;
					vv["frame_level"] = DataMgr.roleData.cur_avatar_box_id;
				else
					vv["head_url"] = v.picUrl;
					vv["gender"] = v.sex;
					vv["frame_level"] = v.cur_avatar_box_id;
				end
				local tmp = FuncUtil:CopyTable(vv);
				table.insert(RoomSystem.RoomNewMemberAllInfoList, tmp);
				break;
			end
		end
	end
	
	--更新房间蓝图数据
	EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_UPDATE_ROOMMEMBER_LIST);
	-- log_tree("sync_room_member, updated:", BP_ARRAY_RoomMemberList);

	--更新UI
	LuaClassObj.HandleUIMessage(bp_room_waiting, "RefreshNewMemberAllInfo");
end

function RoomSystem.GetProfileAfterOffline(listinfo)
	log("RoomSystem GetProfileAfterOffline");
	
	for k,v in pairs(listinfo) do
		for kk,vv in pairs(RoomSystem.CurrentRoomInfo.MemberInfoList) do
			if tonumber(v.uid) == tonumber(vv.openid) then
				if tonumber(v.uid) == tonumber(DataMgr.roleData.uid) then
					vv["head_url"] = DataMgr.roleData.headIconUrl;
					vv["gender"] = DataMgr.roleData.gender;
					vv["frame_level"] = DataMgr.roleData.cur_avatar_box_id;
				else
					vv["head_url"] = v.picUrl;
					vv["gender"] = v.sex;
					vv["frame_level"] = v.cur_avatar_box_id;
				end
				break;
			end
		end
	end
	RoomSystem.get_room_battle_watch_info_req();
	RoomSystem.isEnterRoomGettingRoomList = false;
	RoomWaitingUI:Init();
	
	--更新房间蓝图数据
	EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_UPDATE_ROOMMEMBER_LIST);

	RoomUI:RoomShow()

	RoomWaitingUI:EnterRoom()
end




function RoomSystem.get_room_battle_watch_info_req()
	log("RoomSystem get_room_battle_watch_info_req");
	NetUtil.SendPkg("get_room_battle_watch_info_req");
end

function RoomSystem.get_room_battle_watch_info_rsp(room_ob_info)
	log("RoomSystem get_room_battle_watch_info_rsp");
	log_tree("room_ob_info", room_ob_info);
	if room_ob_info ~= nil and room_ob_info.room_id ~= 0 then -- == RoomSystem.CurrentRoomInfo.id then
		local strTile = DataMgr.GetMsgByID(102012); -- 提示
		local strMsg = DataMgr.GetMsgByID(501151); -- 是否进入观战？

		local function clickOkCallback()
			BattleResult.enter_room_battle_watch()
		end

		local function clickCancelCallback()
			RoomSystem.leave_room_battle_watch()
		end

		CommonMessageBoxUI:ShowPanel(2, strTile, strMsg, clickOkCallback, clickCancelCallback);	
	end

end

function RoomSystem.leave_room_battle_watch()
	log("RoomSystem leave_room_battle_watch");
	NetUtil.SendPkg("leave_room_battle_watch");
end

function RoomSystem.SetAcceptJoinRoom(isAccept)
	RoomSystem.AcceptJoinRoom = isAccept;
end

--c2s.create_room_request(ss, name, map_id, password, group_type, is_anchor_ob, allow_invite, room_type, battle_custom_cfg)
--请求创建房间
function RoomSystem.req_create_room(_roomName, _mapID, _passWd, _groupType, _host_can_ob, _battle_cfg, modeid, is_use_pc_param)
	local temp_cfg ={}
	temp_cfg["ShrinkSpeed"] = 100;
	temp_cfg["SoundVisual"] = true;
	temp_cfg["AutoOpenDoor"] = true;
	temp_cfg["AutoPick"] = true;
	temp_cfg["AimAssist"] = true;
	temp_cfg["BuckleBullet"] = false;
	_battle_cfg = BP_Room_IsHighLevelRoom and _battle_cfg or temp_cfg;
	local msgModeId = BP_Room_IsHighLevelRoom and modeid or 10000
	local _str = BP_Room_IsHighLevelRoom and "advanced" or "ordinary";
	if BP_CreateRoom_IsCompetitionRoom then
		_str = "match";
	end
	local local_map = Client.GetTableData("Map", _mapID);
	log_tree("req_create_room battle_cfg = ",_battle_cfg)
	local isfpp = local_map.IsFpp and local_map.IsFpp==1
	if _passWd == "" then
		CreateRoomHandler.send_create_room_request( _roomName, _mapID, nil, _groupType, _host_can_ob, true, _str, _battle_cfg, isfpp, is_use_pc_param);
	else
		CreateRoomHandler.send_create_room_request( _roomName, _mapID, _passWd, _groupType, _host_can_ob, true, _str, _battle_cfg, isfpp, is_use_pc_param);
	end
end


--请求进入房间
function RoomSystem.req_join_room(_roomID, _passWd)
	if _roomID == nil then
		if RoomSystem.IsQRCodeEnterRoom == true then
			RoomSystem.IsQRCodeEnterRoom = false;
		end
		return;
	end
	log("_roomID = ".._roomID);
	
	if BP_Room_IsInRoom == true then
		DataMgr.ShowMessageBoxByID(110132);
		if RoomSystem.IsQRCodeEnterRoom == true then
			RoomSystem.IsQRCodeEnterRoom = false;
		end
		return;
	end
	
	if _roomID > 10000000 then
		NetUtil.SendPkg("enter_league_ob_req", _roomID);
	else
		-- log("join_room_request() "..debug.traceback())
		if _passWd == "" then
			NetUtil.SendPkg("join_room_request", _roomID, nil);
		else
			NetUtil.SendPkg("join_room_request", _roomID, _passWd);
		end
	end
	
end


--请求退出房间
function RoomSystem.req_exit_room()
	log("exit_room:" .. DataMgr.roleData.uid);
	-- log("req_exit_room() "..debug.traceback())
	--DataMgr.ShowNoticeByString("请求退出房间");
	NetUtil.SendPkg("exit_room", tonumber(DataMgr.roleData.uid));
end

--请求开始游戏
function RoomSystem.req_start_game()
	log("[HHF]RoomSystem.req_start_game, Send start_game_request");
	NetUtil.SendPkg("start_game_request");
end

--请求更换位置
function RoomSystem.req_change_room_pos_request(room_id, new_pos)
	log("req_change_room_pos_request: room_id = "..room_id.."new_pos == "..new_pos);
	
	if RoomSystem.CurrentRoomInfo == nil then
		return;
	end
	NetUtil.SendPkg("change_room_pos_request", RoomSystem.CurrentRoomInfo.id, new_pos);
end

--请求踢人
function  RoomSystem.req_room_kick_request(room_id,  kick_id)
	log("req_room_kick_request: room_id = "..room_id.."kick_id == "..kick_id);
	if not RoomSystem.isRoomOwner() then
		return;
	end
	if BP_STRUCT_RoomWaitingInfo == nil then
		return;		
	end
	NetUtil.SendPkg("room_kick_request", RoomSystem.CurrentRoomInfo.id, kick_id);
end

--房间内修改房间名
function RoomSystem.req_change_room_name(room_id, name)
	log("req_change_room_name: room_id = "..room_id.." name = "..name);
	NetUtil.SendPkg("change_room_name_request", room_id, name);
end

--房间内请求修改房间模式
function RoomSystem.req_change_room_group_type(room_id, group_type)
	log("req_change_room_group_type: room_id = "..room_id.." group_type = "..group_type);
	NetUtil.SendPkg("change_room_group_type_request", room_id, group_type);
end

--房间内请求修改地图
function RoomSystem.req_change_room_map(room_id, map_id)
	log("req_change_room_map: room_id = "..room_id.." map_id = "..map_id);
	NetUtil.SendPkg("change_room_map_request", room_id, map_id);
end

--ID查询某个房间
function RoomSystem.req_query_one_room(room_id)
	log("req_query_one_room: room_id = "..room_id);
	NetUtil.SendPkg("query_room_request", room_id);
	--精确搜索服务器响应回调 on_query_room_respond
end

--加入房间请求概要信息
function RoomSystem.req_profile_join_room()
	log("RoomSystem req_profile_join_room");
	
	local listUid = {};
	for k,v in pairs(RoomSystem.CurrentRoomInfo.MemberInfoList) do
		table.insert(listUid, tonumber(v.openid));
	end
	
	ProfileMgr.GetProfileList(listUid, RoomSystem.GetProfileAfterJoinRoom);
	LuaClassObj.HandleDynamicCreation(bp_room_waiting);
end

--同步信息请求概要信息（只加入玩家使用）
function RoomSystem.req_profile_sync_room()
	log("RoomSystem req_profile_sync_room");
	
	local listUid = {};
	for k,v in pairs(RoomSystem.RoomNewMemberInfoList) do
		table.insert(listUid, tonumber(v.openid));
	end
	
	RoomSystem.RoomNewMemberInfoList = {};
	
	ProfileMgr.GetProfileList(listUid, RoomSystem.GetProfileAfterSync);
end

--短线重连请求概要信息
function RoomSystem.req_profile_info_offline_room()
	log("RoomSystem req_profile_info_offline_room");
	
	local listUid = {};
	for k,v in pairs(RoomSystem.CurrentRoomInfo.MemberInfoList) do
		table.insert(listUid, tonumber(v.openid));
	end
	
	ProfileMgr.GetProfileList(listUid, RoomSystem.GetProfileAfterOffline);
end

--请求锁ob位置
function RoomSystem.req_lock_room_pos(lock_pos)
	log("RoomSystem req_lock_room_pos");
	log("lock_pos = "..lock_pos);
	NetUtil.SendPkg("lock_room_pos_request", lock_pos);
end

--请求解锁ob位置
function RoomSystem.req_unlock_room_pos(unlock_pos)
	log("RoomSystem req_unlock_room_pos");
	log("unlock_pos = "..unlock_pos);
	NetUtil.SendPkg("unlock_room_pos_request", unlock_pos);
end








--创建房间响应
function RoomSystem.on_create_room_respond(res, room_info)
	log("create_room_respond " .. res);
	-- log_tree("roominfo", room_info);
	
	if res ~= 0 then
		sandbox.LogNormal("create_room_respond failed ");
		DataMgr.ShowNoticeByID(res);
		return;
	end
	
	BattleResult.IgnoreDSError = false;

	--调刷新房间
	RoomSystem.CurrentRoomInfo = room_info;

	RoomSystem.CurrentRoomInfo.IsRoomOwner = true;
	RoomSystem.CurrentRoomInfo.owner_id = tostring(RoomSystem.CurrentRoomInfo.owner_id);

	RoomSystem.CurrentRoomInfo.MemberInfoList = {};
	--把自己加入成员列表
	local isEmulator = DataMgr.roleData.isEmulator;
	table.insert(RoomSystem.CurrentRoomInfo.MemberInfoList, 
	{
	  openid = DataMgr.roleData.uid,
	  name = DataMgr.roleData.nickName,
	  level = DataMgr.roleData.level,
	  svr = 0,
	  isRoomMaster = true,
	  pos = GetWindowOBState() and 101 or 1,
	  state = "idle",
	  head_url = DataMgr.roleData.headIconUrl,
	  gender = DataMgr.roleData.gender,
	  frame_level = DataMgr.roleData.cur_avatar_box_id,
	  device_type = isEmulator == true and 1 or 0,
	}
	);
	
	RoomWaitingUI:Init();
	BP_Room_Passwd = BP_CreateRoom_Passwd;

	--更新房间蓝图数据
	EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_UPDATE_ROOMMEMBER_LIST);

	--刷新UI
	RoomCreateUI.HideUI()
	RoomWaitingUI:EnterRoom()
end

local _is_can_get_more = true;
--请求房间列表
function RoomSystem.req_room_list()
	log("req_room_list, RoomZoneId" .. RoomSystem.RoomZoneId);
	--NetUtil.SendPkg("query_room_list", 1, 100);
	--query_room_list增加区服id参数，根据用户选择的区服请求房间列表数据
	local viewStr =  BP_Room_IsCurListNormalRoom and "view_common" or "view_match"
	NetUtil.SendPriorityPkg(false, "sync_room_list", "query_room_list",1, 10, RoomSystem.RoomZoneId,viewStr);
end

--请求新增房间列表
function RoomSystem.req_more_room_list()
	if _is_can_get_more then
		log("req_more_room_list, RoomZoneId" .. RoomSystem.RoomZoneId);
		local curCount = #RoomSystem.RoomInfoList
		local viewStr =  BP_Room_IsCurListNormalRoom and "view_common" or "view_match"
		NetUtil.SendPriorityPkg(false, "sync_room_list", "query_room_list",curCount+1, 5, RoomSystem.RoomZoneId,viewStr);
		_is_can_get_more=false;
	end
end

--请求房间响应
function RoomSystem.on_sync_room_list(view, pos, total)
	if view == nil then
		return;
	end
	if total ~=0 and view ~= {} then
		_is_can_get_more=true;
	end
	log_tree("[CCL]sync_room_list viewCount= " .. tostring(#view).." pos = "..tostring(pos).." total = "..tostring(total),view);

	if pos==1 then
		RoomSystem.RoomInfoList = {};
	else
		for i,j in pairs(view) do
			if j.state == "gaming" then
				local cur_time = FuncUtil.GetServerTimeInSec();
				local start_time = j.game_start;
				j.game_start = math.ceil( (cur_time-start_time)/60 );
			end
		end
	end

	local _flag = true
	for _roomIndex = 1, total do
		_flag = true
		local item = view[_roomIndex]
		if item then
			for k,v in ipairs(RoomSystem.RoomInfoList) do
				if v.id == item.id then
					RoomSystem.RoomInfoList[k]= item
					_flag = false;
					break;
				end
			end
			if _flag then
				table.insert(RoomSystem.RoomInfoList, item);
			end
		end
	end
	if pos == 1 then
		local IdleRoomList = {};
		local GamingRoomList = {};
		local SortRoomList = {};
		for i,v in ipairs(RoomSystem.RoomInfoList) do
			v.owner_id = tostring(v.owner_id);
			if v.state == "idle" then
				table.insert(IdleRoomList, v);
			elseif v.state == "gaming" then
				local cur_time = FuncUtil.GetServerTimeInSec();
				local start_time = v.game_start;
				v.game_start = math.ceil( (cur_time-start_time)/60 );
				table.insert(GamingRoomList, v);
			end
		end

		table.sort( IdleRoomList, function(a,b) return a.create_time > b.create_time; end );
		table.sort( GamingRoomList, function(a,b) return a.create_time > b.create_time; end );

		for i,v in ipairs(IdleRoomList) do
			table.insert(SortRoomList, v);
		end
		for i,v in ipairs(GamingRoomList) do
			table.insert(SortRoomList, v);
		end

		RoomSystem.RoomInfoList = SortRoomList;
		-- log_tree("RoomSystem.RoomInfoList =",RoomSystem.RoomInfoList);

		--更新房间蓝图数据
		EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_UPDATE_ROOM_LIST);

		if RoomSystem.isEnterRoomGettingRoomList then
			--大厅进入房间
			RoomUI:RoomShow()
			LuaClassObj.HandleUIMessage(bp_room, "RefreshRoomList");
			RoomSystem.isEnterRoomGettingRoomList = false;
			LobbyUI.CloseOtherMenu();
		else
			--其他拉取列表
			LuaClassObj.HandleUIMessage(bp_room, "RefreshRoomList");
		end
	else
		--更新房间蓝图数据
		EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_UPDATE_ROOM_LIST);
		--下拉增加房间列表
		LuaClassObj.HandleUIMessage(bp_room, "AddRoomList");
	end
end

--加入房间响应
function RoomSystem.on_join_room_respond(res, param1, param2)
	log("join_room_respond " .. res);
	-- log_tree("baseinfo", base_info);
	-- log_tree("room_members", members);
	
	RoomSystem.QRCodeRoomInfo = nil;
	if res ~= 0 then
		sandbox.LogNormal("join_room_respond failed = " .. res);
		--版本不一致
		if res == 110091 then
			DataMgr.ShowMessageBoxByID(res);
			RoomSystem.req_room_list();
			return;
		end
		
		--二维码扫描，组队或匹配中
		if RoomSystem.IsQRCodeEnterRoom == true then
			RoomSystem.IsQRCodeEnterRoom = false;
			if res == 110103 or res == 110133 then
				DataMgr.ShowNoticeByID(res);
				RoomUI:RoomHide()
				return;
			end
		end

		if res == 210001 then
			--res=210001，成功进入房间
			local left_time = param1 		 --剩余进入房间的时间
			local total_limit_time = param2  --踢人后限制其再次进入的时间
			log("on_join_room_respond, left time to enter room:" .. left_time)
			DataMgr.ShowNoticeByString(string.format(DataMgr.GetMsgByID(210001), left_time)); 
			return;
		end
		
		DataMgr.ShowNoticeByID(res);
        RoomSystem.req_room_list();
		return;
	end

	--res=0，成功进入房间
	base_info = param1
	members = param2

	BattleResult.IgnoreDSError = false;
			
	RoomSystem.CurrentRoomInfo = base_info;
	RoomSystem.CurrentRoomInfo.owner_id = tostring(RoomSystem.CurrentRoomInfo.owner_id);
	if base_info ~= nil then
		BP_Room_IsHighLevelRoom = base_info.room_type == "advanced" or base_info.room_type == "match";
	end
	
	RoomSystem.CurrentRoomInfo.MemberInfoList = {};
	for k, v in pairs(members) do
		local tmp = v;
		tmp.openid = tostring(k);
		tmp.isRoomMaster = (RoomSystem.CurrentRoomInfo.owner_id == tmp.openid);
		tmp["head_url"] = "";
		tmp["gender"] = "";
		tmp["frame_level"] = "";
		table.insert(RoomSystem.CurrentRoomInfo.MemberInfoList, tmp);
	end
	
	RoomSystem.req_profile_join_room();	

	if base_info ~= nil and base_info.room_can_kick_player_in_game ~= nil then
		log("on_join_room_respond, room_can_kick_player_in_game = " .. tostring(base_info.room_can_kick_player_in_game))
		-- 房主有踢人权限，弹窗提示
		if base_info.room_can_kick_player_in_game then		
			local title = Client.GetTableData("LocalizeRes", "101001").TextValue;
			local content = Client.GetTableData("LocalizeRes", "6277").TextValue; -- "请您注意：当前房间的房主有在游戏内踢人的权限"
	        CommonMessageBoxUI:ShowPanel(1, title, content);
		end
	end
end

--房间状态
function RoomSystem.on_sync_room_state(state)
	-- log_tree("sync_room_state", state);

	RoomSystem.CurrentRoomInfo.state = state;

	--更新房间蓝图数据
	EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_UPDATE_ROOMMEMBER_LIST);
end


--房间解散
function RoomSystem.on_room_disband(room_id, reason)
	log("on_room_disband ");
	
	local curStatus = string.lower(LuaClassObj.GetGameStatus(bp_lobby));
	if curStatus == "lobby" then
		log("lobby on_room_disband ");
		if reason == "owner-exit" then
			if not RoomSystem.isRoomOwner() then
				local title_data = Client.GetTableData("LocalizeRes", 101001);
				local title = tostring(title_data.TextValue);
				local msg_data = Client.GetTableData("LocalizeRes", 110069);
				local msg = tostring(msg_data.TextValue);
				CommonMessageBoxUI:ShowPanel(1, title, msg);
				RoomDisbandReason = "owner-exit";
			end
		elseif reason == "owner-offline" then
			local title_data = Client.GetTableData("LocalizeRes", 101001);
			local title = tostring(title_data.TextValue);
			local msg_data = Client.GetTableData("LocalizeRes", 110073);
			local msg = tostring(msg_data.TextValue);
			CommonMessageBoxUI:ShowPanel(1, title, msg);
			RoomDisbandReason = "owner-offline";
		elseif reason == "version-not-same" then
		elseif reason == "over-time" then
			local title_data = Client.GetTableData("LocalizeRes", 101001);
			local title = tostring(title_data.TextValue);
			local msg_data = Client.GetTableData("LocalizeRes", 117073);
			local msg = tostring(msg_data.TextValue);
			CommonMessageBoxUI:ShowPanel(1, title, msg);
			RoomDisbandReason = "over-time";
		elseif reason == "game-over" then
			local title_data = Client.GetTableData("LocalizeRes", 101001);
			local title = tostring(title_data.TextValue);
			local msg_data = Client.GetTableData("LocalizeRes", 110127);
			local msg = tostring(msg_data.TextValue);
			--CommonMessageBoxUI:ShowPanel(1, title, msg);
			RoomDisbandReason = "game-over";
		end
	else
		log("fighting on_room_disband ");
		if reason == "owner-exit" then
			if not RoomSystem.isRoomOwner() then
				RoomDisbandReason = "owner-exit";
			end
		elseif reason == "owner-offline" then
			RoomDisbandReason = "owner-offline";
		elseif reason == "version-not-same" then
		elseif reason == "game-over" then
			RoomDisbandReason = "game-over";
		end
	end

	--清空房间
	RoomSystem.CurrentRoomInfo = {};

	--更新房间蓝图数据
	EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_UPDATE_ROOMMEMBER_LIST);
	
	--退出房间
	BP_Room_InitiativeLeave = false;
	BP_Room_IsInRoom = false;

	RoomWaitingUI:LeaveRoom()
	
	if curStatus == "lobby" then
		IsRoomToBattle = false;
		if reason == "game-over" then
			--RoomSystem.Enter();
			--RoomUI:Init();
		else
			--刷新下当前的房间列表
			--RoomSystem.req_room_list();
		end
	end
end




--同步房间的玩家信息
function RoomSystem.on_sync_room_member(id, info, carteamInfo)
	log_tree("sync_room_member carteam = ", carteamInfo);
	if RoomSystem.CurrentRoomInfo == nil then
		return;
	end

	if RoomSystem.CurrentRoomInfo.MemberInfoList == nil then
		RoomSystem.CurrentRoomInfo.MemberInfoList = {};
	end
	
	local curStatus = string.lower(LuaClassObj.GetGameStatus(bp_lobby));
	if curStatus ~= "lobby" then
		log("Not lobby on_sync_room_member ");
		return;
	end
	id = tostring(id);
	local isLeaveRoomSync = false;
	local isInRoomMemberInfoList = false;	--玩家是否在房间中
	
	--1.玩家离开房间同步
	if info == nil then
		log("sync_room_member, delete member id = "..id);
		log("sync leave room");
		isLeaveRoomSync = true;
		--删除当前房间中的玩家
		for _memberIndex = 1, #RoomSystem.CurrentRoomInfo.MemberInfoList do
			if RoomSystem.CurrentRoomInfo.MemberInfoList[_memberIndex].openid == id then
				--记录刷新位置和数据
				BP_RoleOldPos = RoomSystem.CurrentRoomInfo.MemberInfoList[_memberIndex].pos;
				BP_RoleNewPos = 0;
				local tmp = FuncUtil:CopyTable(RoomSystem.CurrentRoomInfo.MemberInfoList[_memberIndex]);
				RoomSystem.RoomOldMemberInfoList = {};
				table.insert(RoomSystem.RoomOldMemberInfoList, tmp);
				--删除该玩家
				table.remove(RoomSystem.CurrentRoomInfo.MemberInfoList, _memberIndex);
				--更新房间人数
				if tmp.pos <= 100 then
					RoomSystem.CurrentRoomInfo.player_count = RoomSystem.CurrentRoomInfo.player_count - 1;
				else
					RoomSystem.CurrentRoomInfo.ob_count = RoomSystem.CurrentRoomInfo.ob_count - 1;
				end
				break;
			end
		end
		--自己被踢，退出房间
		if id == DataMgr.roleData.uid then --踢人
			RoomSystem.BeKicked();
			return;
		end
	--增加或者更新玩家信息
	else
		RoomWaitingUI:AddCarteam(carteamInfo,info.pos);
		local tmp = info;
		tmp.openid = id;
		tmp.isRoomMaster = (RoomSystem.CurrentRoomInfo.owner_id == id);
		tmp["head_url"] = "";
		tmp["gender"] = "";
		tmp["frame_level"] = "";
		
		for _memberIndex = 1, #RoomSystem.CurrentRoomInfo.MemberInfoList do
			--2.换位置或游戏状态同步
			if RoomSystem.CurrentRoomInfo.MemberInfoList[_memberIndex].openid == id then
				log("sync change room pos");
				local tmp2 = FuncUtil:CopyTable(RoomSystem.CurrentRoomInfo.MemberInfoList[_memberIndex]);
				tmp["head_url"] = tmp2.head_url;
				tmp["gender"] = tmp2.gender;
				tmp["frame_level"] = tmp2.frame_level;
				--记录刷新位置和数据
				BP_RoleOldPos = tmp2.pos;
				BP_RoleNewPos = tmp.pos;
				local tmp3 = FuncUtil:CopyTable(tmp);
				RoomSystem.RoomOldMemberInfoList = {};
				table.insert(RoomSystem.RoomOldMemberInfoList, tmp3);
				--修改玩家数据
				RoomSystem.CurrentRoomInfo.MemberInfoList[_memberIndex] = FuncUtil:CopyTable(tmp);
				--更新房间人数
				if BP_RoleOldPos <= 100 and BP_RoleNewPos > 100 then
					RoomSystem.CurrentRoomInfo.player_count = RoomSystem.CurrentRoomInfo.player_count - 1;
					RoomSystem.CurrentRoomInfo.ob_count = RoomSystem.CurrentRoomInfo.ob_count + 1;
				elseif BP_RoleOldPos > 100 and BP_RoleNewPos <= 100 then
					RoomSystem.CurrentRoomInfo.player_count = RoomSystem.CurrentRoomInfo.player_count + 1;
					RoomSystem.CurrentRoomInfo.ob_count = RoomSystem.CurrentRoomInfo.ob_count - 1;
				end
				isInRoomMemberInfoList = true;
				break;
			end
		end
		if not isInRoomMemberInfoList then
			--3.玩家加入房间同步
			log("not found in roomm member list");
			log("sync enter room");
			local tmp2 = FuncUtil:CopyTable(tmp);
			local tmp3 = FuncUtil:CopyTable(tmp);
			table.insert(RoomSystem.CurrentRoomInfo.MemberInfoList, tmp2);
			--放入新玩家队列
			table.insert(RoomSystem.RoomNewMemberInfoList, tmp3);
			--更新房间人数
			if tmp.pos <= 100 then
				RoomSystem.CurrentRoomInfo.player_count = RoomSystem.CurrentRoomInfo.player_count + 1;
			else
				RoomSystem.CurrentRoomInfo.ob_count = RoomSystem.CurrentRoomInfo.ob_count + 1;
			end
		end
	end
	
	if not isLeaveRoomSync and not isInRoomMemberInfoList then
		if BP_Room_CanGetProfile == false then
			BP_Room_CanGetProfile = true;
			LuaClassObj.HandleUIMessage(bp_room_waiting, "SetCanGetProfile");
		end
		--更新房间蓝图数据
		EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_UPDATE_ROOMMEMBER_LIST);
	else
		--更新房间蓝图数据
		EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_UPDATE_ROOMMEMBER_LIST);

		--更新UI
		-- LuaClassObj.HandleUIMessage(bp_room_waiting, "RefreshMemberList");
		LuaClassObj.HandleUIMessage(bp_room_waiting, "RefreshOldMemberInfo");
	end
end

--更换位置回调
function RoomSystem.on_change_room_pos_respond(res,  new_pos)
	log("on change room pos respond");
	
	if res ~= 0 then
		log("change room pos failed");
		log("res: "..res);
		DataMgr.ShowNoticeByID(res);
		return;
	end
	
	if RoomSystem.CurrentRoomInfo == nil then
		return;
	end
	
	--找到自己
	-- local isFoundOpenId = false;
	-- for _memberIndex = 1, #RoomSystem.CurrentRoomInfo.MemberInfoList do
		-- if RoomSystem.CurrentRoomInfo.MemberInfoList[_memberIndex].openid == DataMgr.roleData.uid then
			-- RoomSystem.CurrentRoomInfo.MemberInfoList[_memberIndex].pos = new_pos;
			-- isFoundOpenId = true;
			-- break;
		-- end
	-- end
	-- if not isFoundOpenId then
		-- log("not found myself openID = "..DataMgr.roleData.uid);
	-- end
	LuaClassObj.HandleUIMessage(bp_room_waiting, "SetMyOldTeamBGEmpty");
	-- EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_UPDATE_ROOMMEMBER_LIST);
end

--踢人回调
function RoomSystem.on_room_kick_respond(res,  kick_id)
	log("on room kick respond res = "..res);
	if res ~= 0 then
		log("room kick failed");
		DataMgr.ShowNoticeByID(res);
		return;
	end
	log("memberID = "..kick_id.." was kicked by room owner");
end

--通知进入游戏
function RoomSystem.on_notify_enter_game(ip, port, key)
	sandbox.LogNormal("notify_enter_game " .. ip .. ":" .. port .. ",key=" .. key);
end

--开始游戏结果
function RoomSystem.on_start_game_respond(res)
	log("[HHF]RoomSystem.on_start_game_respond, res = " .. tostring(res));
	if res ~= 0 then
		if res == 210005 then
			return;
		end
		log("start game failed");
		DataMgr.ShowNoticeByID(res);
		return;
	end
end

g_game_id = 0;
g_game_mode="";

--正式进入游戏
function RoomSystem.on_enter_game(ip, port, key, packet_key, game_id, is_ob, ad_conf)
	log("[HHF]RoomSystem.on_enter_game, received enter_game, ip = " .. tostring(ip) .. ", port = " .. tostring(port) .. ", key = " .. tostring(key) .. ", game_id = " .. tostring(game_id) .. ", is_ob = " .. tostring(is_ob or false));
	log_tree("[LHM]RoomSystem.on_enter_game ad_conf", ad_conf);
	
    BattleResult.IgnoreDSError = false;
	g_game_id = game_id;
	
	--跟服务器同学确认，is_ob变量传过来的是子模式
	g_game_mode = is_ob;

	if is_ob ~= nil then
		Client.TApmDataReport(GameFrontendHUD, 401, tostring(is_ob));
    else
    	Client.TApmDataReport(GameFrontendHUD, 401, "");
    end
	
	--切换到战斗场景
	BP_LoadingTo = 0;
	LoadingUI:Init();
	NetUtil.EnterBattle(ip, port, key, DataMgr.roleData.nickName, packet_key, game_id, is_ob, ad_conf);
	LobbySystem.ResetMatchInfo();
	ProfileMgr.ClearStrangerProfileList();
	Client.JoinLbsVoiceRoom(GameFrontendHUD, game_id, DataMgr.roleData.openID);
	TeamUpMatchInfoUI.PauseAllDownloading();
end

--房间内修改房间名响应
function RoomSystem.on_change_room_name_request(res, room_id, name)
	log("change_room_name_request");
	log("room_id = "..room_id);
	log("name = "..name);
	
	if res ~= 0 then
		DataMgr.ShowNoticeByID(res);
		return;
	end
	
	DataMgr.ShowNoticeByID(110100);
end

--房间内修改房间模式
function RoomSystem.on_change_room_group_type_respond(res, room_id, group_type)
	log("change_room_group_type_respond res = "..res);
	log("room_id = "..room_id);
	log("group_type = "..group_type);
	
	if res ~= 0 then
		DataMgr.ShowNoticeByID(res);
		return;
	end
end

--房间内修改地图
function RoomSystem.on_change_room_map_respond(res, room_id, map_id)
	log("[HHF]RoomSystem.on_change_room_map_respond, res = " .. res);
	log("room_id = "..room_id);
	log("map_id = "..map_id);
	
	if res ~= 0 then
		if res == 210006 then
			local tips = FuncUtil.GetLocalizeResStr(5010);
			PopUpNoticeUI.ShowNewNotice(tips);
			return;
		end
		DataMgr.ShowNoticeByID(res);
		return;
	end
	
	DataMgr.ShowNoticeByID(110097);
end

--房间信息变更通知	opt: 1-变更房间名 2-变更地图id 3-变更房间模式
function RoomSystem.on_room_info_notify(room_id, opt, param)
	log("room_info_notify");
	log("room_id = "..room_id);
	log("opt = "..opt);
	log("param = "..param);
	
	if opt == 1 then
		RoomSystem.CurrentRoomInfo.name = param;
		EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_UPDATE_ROOMMEMBER_LIST);
		LuaClassObj.HandleUIMessage(bp_room_waiting, "UpdateRoomName");
	elseif opt == 2 then
		RoomSystem.CurrentRoomInfo.map_id = param;
		EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_UPDATE_ROOMMEMBER_LIST);
		LuaClassObj.HandleUIMessage(bp_room_waiting, "UpdateRoomMapType");
	elseif opt == 3 then
		RoomSystem.CurrentRoomInfo.group_type = param;
		EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_UPDATE_ROOMMEMBER_LIST);
		LuaClassObj.HandleUIMessage(bp_room_waiting, "UpdateRoomGroupType");
		LuaClassObj.HandleUIMessage(bp_room_waiting, "SetAllTeamBGEmpty");
		LuaClassObj.HandleUIMessage(bp_room_waiting, "RefreshMemberList");
	elseif opt == 4 then
		RoomSystem.CurrentRoomInfo.state = param;
	else
		log("room_info_notify Error!");
	end
	RoomWaitingUI:UpdateBPCurrentRoomInfo()
end

--ID查询某个房间响应
function RoomSystem.on_query_room_respond(res, room_id, room)
	log("query_room_respond");
	log("room_id = "..room_id);
	-- log_tree("room =", room);
	
	if res ~= 0 then
		log("on_query_room_respond, res:" .. res)
		DataMgr.ShowNoticeByID(res);
		RoomSystem.req_room_list();
		return;
	end
	
	local isMatch = FuncUtil:IsMatchVersion(room.version);
	if isMatch == false then
		DataMgr.ShowMessageBoxByID(110091);
		RoomSystem.req_room_list();
		return;
	end
	
	if room.lock_state == true then
		LuaClassObj.HandleUIMessage(bp_room, "ShowEnterRoomPSWUI");
	else
		LuaClassObj.HandleUIMessage(bp_room, "EnterRoomWithoutPSW");
	end
end

--同步房间信息(如登录、战斗回大厅、断线重连时)
function RoomSystem.on_sync_room_info(room, members)
	log("sync_room_info");
	--log_tree("room =", room);
	-- log_tree("members =", members);
	
	if room == nil then
		log("no_room_info");
		local curStatus = string.lower(LuaClassObj.GetGameStatus(bp_lobby));
		if curStatus == "lobby" then
			log("Lobby State");
			
			if RoomSystem.MyUID ~= DataMgr.roleData.uid then
				RoomSystem.MyUID = DataMgr.roleData.uid;
				BP_Room_IsInRoom = false;
				IsRoomToBattle = false;
				RoomDisbandReason = "";
				return;
			end

			--客户端房间状态还存在（实际不存在  1.未开始战斗被解散了 2.这场战斗结束而自动解散）
			if BP_Room_IsInRoom == true then
				log("Lobby BP_Room_IsInRoom LeaveRoom");
				--清空房间
				RoomSystem.CurrentRoomInfo = {};
				--更新房间蓝图数据
				EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_UPDATE_ROOMMEMBER_LIST);
				--离开房间
				BP_Room_InitiativeLeave = false;
				BP_Room_IsInRoom = false;

				RoomWaitingUI:LeaveRoom()
				
				--2.从战斗退回
				if IsRoomToBattle == true then
					log("IsRoomToBattle");
					IsRoomToBattle = false;
					--RoomSystem.Enter();
					--RoomUI:Init();
					
					local title_data = Client.GetTableData("LocalizeRes", 101001);
					local title = tostring(title_data.TextValue);
					local msg_data = "";
					if RoomDisbandReason == "owner-exit" then
						msg_data = Client.GetTableData("LocalizeRes", 110069);
						local msg = tostring(msg_data.TextValue);
						CommonMessageBoxUI:ShowPanel(1, title, msg);
					elseif RoomDisbandReason == "owner-offline" then
						msg_data = Client.GetTableData("LocalizeRes", 110073);
						local msg = tostring(msg_data.TextValue);
						CommonMessageBoxUI:ShowPanel(1, title, msg);
					elseif RoomDisbandReason == "game-over" then
						msg_data = Client.GetTableData("LocalizeRes", 110127);
						local msg = tostring(msg_data.TextValue);
						--CommonMessageBoxUI:ShowPanel(1, title, msg);
					end
					RoomDisbandReason = "";
					
					return;
				end
				--刷新下当前的房间列表
				--RoomSystem.req_room_list();
			--客户端房间状态不存在（1.战斗中房间已被解散  2.不是房间进的战斗或没房间操作）
			else
				log("Lobby Not BP_Room_IsInRoom LeaveRoom");
				--1.战斗中房间已被解散
				if IsRoomToBattle == true then
					log("IsRoomToBattle");
					IsRoomToBattle = false;
					BP_Room_InitiativeLeave = false;
					BP_Room_IsInRoom = false;
					--RoomSystem.Enter();
					--RoomUI:Init();
					
					local title_data = Client.GetTableData("LocalizeRes", 101001);
					local title = tostring(title_data.TextValue);
					local msg_data = "";
					if RoomDisbandReason == "owner-exit" then
						msg_data = Client.GetTableData("LocalizeRes", 110069);
						local msg = tostring(msg_data.TextValue);
						CommonMessageBoxUI:ShowPanel(1, title, msg);
					elseif RoomDisbandReason == "owner-offline" then
						msg_data = Client.GetTableData("LocalizeRes", 110073);
						local msg = tostring(msg_data.TextValue);
						CommonMessageBoxUI:ShowPanel(1, title, msg);
					elseif RoomDisbandReason == "game-over" then
						msg_data = Client.GetTableData("LocalizeRes", 110127);
						local msg = tostring(msg_data.TextValue);
						--CommonMessageBoxUI:ShowPanel(1, title, msg);
					end
					RoomDisbandReason = "";
				end
				--2.不是房间进的战斗或没房间操作
			end
		end
		return;
	end

	BP_Room_IsHighLevelRoom = room.room_type == "advanced" or room.room_type == "match";
	--RoomSystem.Enter();
	--RoomUI:Init();
	
	BattleResult.IgnoreDSError = false;
	
	RoomSystem.CurrentRoomInfo = room;
	--log("tostring "..tostring(room.zone_id))
	RoomSystem.RoomZoneId = room.zone_id;
	RoomSystem.CurrentRoomInfo.owner_id = tostring(RoomSystem.CurrentRoomInfo.owner_id);
	if RoomSystem.CurrentRoomInfo.password ~= nil then
		BP_CreateRoom_Passwd = RoomSystem.CurrentRoomInfo.password;
		BP_Room_Passwd = RoomSystem.CurrentRoomInfo.password;
		RoomSystem.CurrentRoomInfo.password = nil;
	else
		BP_CreateRoom_Passwd = "";
		BP_Room_Passwd = "";
	end
	
	RoomSystem.CurrentRoomInfo.MemberInfoList = {};
	for k, v in pairs(members) do
		local tmp = v;
		tmp.openid = tostring(k);
		tmp.isRoomMaster = (RoomSystem.CurrentRoomInfo.owner_id == tmp.openid);
		tmp["head_url"] = "";
		tmp["gender"] = "";
		tmp["frame_level"] = "";
		table.insert(RoomSystem.CurrentRoomInfo.MemberInfoList, tmp);
	end
	
	for i=1, #RoomSystem.CurrentRoomInfo.MemberInfoList do
		RoomSystem.CurrentRoomInfo.MemberInfoList[i].offline_time = nil;
	end
	
	RoomSystem.req_profile_info_offline_room();
end

--进入游戏响应
function RoomSystem.on_room_start_game_notify(res, gvoice_url)
	log("[HHF]RoomSystem.on_room_start_game_notify, received on_room_start_game_notify, res = " .. tostring(res));
	
	if res == "start" then
		RoomSystem.CurrentRoomInfo.state = "gaming";
		EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_UPDATE_ROOMMEMBER_LIST);
		IsRoomToBattle = true;
		BP_LoadingTo = 0;
		LoadingUI:Init();
		GlobalChatVoice.JoinGameVoiceRoom(nil);
		if gvoice_url ~= nil then
			log("room_start_game_notify" .. gvoice_url);
			TeamUpSystem.SelectRegionVoiceUrl = gvoice_url
			BP_SelectRegionVoiceUrl = gvoice_url
			LuaClassObj.HandleUIMessage(bp_teamup, "UpdateVoiceUrl");
		end
	elseif res == "load-game-fail" then
		RoomSystem.CurrentRoomInfo.state = "idle";
		EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_UPDATE_ROOMMEMBER_LIST);
		IsRoomToBattle = false;
		local title = Client.GetTableData("LocalizeRes", "101001").TextValue;
		local content = Client.GetTableData("LocalizeRes", "9911109").TextValue;
		CommonMessageBoxUI:ShowPanel(1, title, content, RoomSystem.OnLoadStartGameFailed, nil);
	elseif res == "version-not-support" then
		RoomSystem.CurrentRoomInfo.state = "idle";
		EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_UPDATE_ROOMMEMBER_LIST);
		IsRoomToBattle = false;
		local title = Client.GetTableData("LocalizeRes", "101001").TextValue;
		local content = Client.GetTableData("LocalizeRes", "9911112").TextValue;
		CommonMessageBoxUI:ShowPanel(1, title, content, RoomSystem.OnLoadStartGameFailed, nil);
	else
		RoomSystem.CurrentRoomInfo.state = "idle";
		EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_UPDATE_ROOMMEMBER_LIST);
		IsRoomToBattle = false;
	end
end

function RoomSystem.team_match_zone_notify(match_zone)
	RoomSystem.RoomZoneId = match_zone;
	log("team_match_zone_notify RoomSystem.RoomZoneId="..RoomSystem.RoomZoneId);
	EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_UPDATE_BP_DATA);
	LuaClassObj.HandleUIMessage(bp_room_waiting, "UpdateRoomServerType");
	LuaClassObj.HandleUIMessage(bp_room, "UpdateServerTypeInRoom");
end

function RoomSystem.on_select_zone_rsp(ret, match_zone)
    log("RoomSystem.on_select_zone_rsp, ret = "..ret..", match_zone = "..match_zone);
	if(string.lower(ret)=="ok") then
		RoomSystem.RoomZoneId = match_zone;
		EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_UPDATE_BP_DATA);
		--TODO:更新回调改成postEvent事件传递
		RoomUI:updateBPZoneId();
		LuaClassObj.HandleUIMessage(bp_room_waiting, "UpdateRoomServerType");
		LuaClassObj.HandleUIMessage(bp_room, "UpdateServerTypeInRoom");
		log("RoomSystem.on_select_zone_rsp");

    elseif (string.lower(ret)=="on_room" or string.lower(ret)=="invalid zone") then
        textMsg =  Client.GetTableData("LocalizeRes", "4055").TextValue; --玩家不在房间中
        DataMgr.ShowNoticeByString(textMsg);
    elseif (string.lower(ret)=="not_owner") then
        textMsg =  Client.GetTableData("LocalizeRes", "4056").TextValue; --只有房主才能修改选服
        DataMgr.ShowNoticeByString(textMsg);
    elseif (string.lower(ret)=="in_game") then
        textMsg =  Client.GetTableData("LocalizeRes", "4057").TextValue; --当前为游戏中，停止游戏才能进行选区操作
        DataMgr.ShowNoticeByString(textMsg);
    elseif (string.lower(ret)=="unknown_err") then
        textMsg =  Client.GetTableData("LocalizeRes", "4058").TextValue; --未知错误
        DataMgr.ShowNoticeByString(textMsg);
    end
end

function RoomSystem.on_select_zone_req(zone_id)
    log("RoomSystem.on_select_zone_req,match_zone = "..zone_id);
    NetUtil.SendPkg("on_select_zone_req", zone_id);
end

--锁ob位置响应
function RoomSystem.on_lock_room_pos_respond(res, lock_pos)
	log("on_lock_room_pos_respond");
	if res ~= 0 then
		log("failed");
		return;
	end
	log("succeed");
end

--解锁ob位置响应
function RoomSystem.on_unlock_room_pos_respond(res, unlock_pos)
	log("on_unlock_room_pos_respond");
	if res ~= 0 then
		log("failed");
		return;
	end
	log("succeed");
end

--同步房间锁信息
function RoomSystem.on_sync_room_lock(islock, pos)
	log("on_sync_room_lock");
	if islock == true then
		log("lock");
		BP_Room_LockedPos = pos;
		RoomSystem.CurrentRoomInfo.ob_count = RoomSystem.CurrentRoomInfo.ob_count + 1;
		EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_UPDATE_CURRENTROOMINFO);
		LuaClassObj.HandleUIMessage(bp_room_waiting, "LockObItem");
	else
		log("unlock");
		BP_Room_UnLockedPos = pos;
		RoomSystem.CurrentRoomInfo.ob_count = RoomSystem.CurrentRoomInfo.ob_count - 1;
		EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_UPDATE_CURRENTROOMINFO);
		LuaClassObj.HandleUIMessage(bp_room_waiting, "UnLockObItem");
	end
end

--进入线上赛房间
function RoomSystem.on_enter_online_room(res, ss, room, members, carteamInfo)
	log_tree("on_enter_online_room carteam = ",carteamInfo)
	log_tree("OnEnterOnlineRoomInfo",room);
	--LuaClassObj.HandleUIMessage(bp_room, "EnterRoomWithoutPSW");
	if res ~= 0 then
		sandbox.LogNormal("join_room_respond failed = " .. tostring(res));
		--版本不一致
		if res == 110091 then
			DataMgr.ShowMessageBoxByID(res);
			RoomSystem.req_room_list();
			return;
		end

		--二维码扫描，组队或匹配中
		if RoomSystem.IsQRCodeEnterRoom == true then
			RoomSystem.IsQRCodeEnterRoom = false;
			if res == 110103 or res == 110133 then
				DataMgr.ShowNoticeByID(res);
				RoomUI:RoomHide()
				return;
			end
		end

		if res == 210001 then
			--res=210001，成功进入房间
			local left_time = ss 		 --剩余进入房间的时间
			log("on_join_room_respond, left time to enter room:" .. left_time)
			DataMgr.ShowNoticeByString(string.format(DataMgr.GetMsgByID(210001), left_time));
			return;
		end

		DataMgr.ShowNoticeByID(res);
		RoomSystem.req_room_list();
		return;
	end

	--res=0，成功进入房间
	RoomWaitingUI:SetCarteam(carteamInfo);
	base_info = room

	BattleResult.IgnoreDSError = false;

	RoomSystem.CurrentRoomInfo = base_info;
	RoomSystem.CurrentRoomInfo.owner_id = tostring(RoomSystem.CurrentRoomInfo.owner_id);

	RoomSystem.CurrentRoomInfo.MemberInfoList = {};
	for k, v in pairs(members) do
		local tmp = v;
		tmp.openid = tostring(k);
		tmp.isRoomMaster = (RoomSystem.CurrentRoomInfo.owner_id == tmp.openid);
		tmp["head_url"] = "";
		tmp["gender"] = "";
		tmp["frame_level"] = "";
		table.insert(RoomSystem.CurrentRoomInfo.MemberInfoList, tmp);
	end

	RoomSystem.req_profile_join_room();
end

-----------------------------------
---add By cole
-----------------------------------
--房间邀请好友
function RoomSystem.room_invite_request(userid)
	log("room_invite_request, invite: " .. userid);
	NetUtil.SendPkg("room_invite_request", userid);
end

--房间邀请好友响应
function RoomSystem.on_room_invite_respond(res, invitee, extend_info)
	log("on_room_invite_respond res = "..res..", invitee = "..invitee);
	if res == 0 then
		DataMgr.ShowNoticeByID(110004);	--邀请消息已发送
	elseif (res == "refuse") then
		if extend_info ~= nil and extend_info.reply_type ~= nil then
			if extend_info.reply_type == 1 and extend_info.refuseMsgInfo ~= nil  then --主动拒绝
				DataMgr.ShowNoticeByString(tostring(extend_info.refuseMsgInfo));
			elseif extend_info.reply_type == 2 then -- 被动拒绝
				DataMgr.ShowNoticeByID(110011);	--对方暂时没有响应你的邀请
			end
		else
			DataMgr.ShowNoticeByID(110011);		--对方暂时没有响应你的邀请
		end
	elseif res == 110116 then
		TeamUpUI.NotSameVertionTips();--版本不一致，无法一起游戏
	else
		DataMgr.ShowNoticeByID(res);
	end
end

--房间邀请他人收到他人的回复
function RoomSystem.on_room_invite_reply_notify(res, invitee, extend_info)
	log("on_room_invite_respond res = "..res..", invitee = "..invitee);
	if res == "ok" then

	elseif res == "refuse" then
		if extend_info ~= nil and extend_info.reply_type ~= nil then
			if extend_info.reply_type == 1 and extend_info.refuseMsgInfo ~= nil  then --主动拒绝
				DataMgr.ShowNoticeByID(110011);	--对方暂时没有响应你的邀请
				--DataMgr.ShowNoticeByString(tostring(extend_info.refuseMsgInfo));
			elseif extend_info.reply_type == 2 then -- 被动拒绝
				DataMgr.ShowNoticeByID(110011);	--对方暂时没有响应你的邀请
			end
		else
			DataMgr.ShowNoticeByID(110011);		--对方暂时没有响应你的邀请
		end
	elseif (res == "autoRefuseOnTeamChange") then
		DataMgr.ShowNoticeByID(110056);	--对方已加入其它队伍
	end
end

function RoomSystem.GetAllRoomCanCreateState()
	log("RoomSystem.GetAllRoomCanCreateState")
	local stateList = {}
	for _,v in pairs(RoomModeType) do
		if v ~= RoomModeType.ALL then
			--[[if RoomSystem.CanCreateRoomType(v) then
				stateList[v] = RoomModeCreateState.CanCreate
			else
				if RoomSystem.HaveRoomCardType(v) then
					stateList[v] = RoomModeCreateState.HaveCard
				else
					stateList[v] = RoomModeCreateState.NoCard
				end

			end--]]
			stateList[v] = RoomModeCreateState.CanCreate
			if RoomSystem.IsRoomModeOpen(v) == false then
				stateList[v] = RoomModeCreateState.Closed
			end
			if RoomSystem.IsRoomModeClosedByVersion(v) then
				stateList[v] = RoomModeCreateState.NoVersionMatched
			end
		end
	end
	return stateList
end

--是否能创建对应类型房间
function RoomSystem.CanCreateRoomType(roomType)
	-- 如果开关表关了，直接false
	if RoomSystem.IsRoomModeOpen(roomType) == false then
		return false
	end

	-- 如果没有一个版本好符合要求也不能创建
	if RoomSystem.IsRoomModeClosedByVersion(roomType) then
		return false
	end
	-- 白名单要啥有啥
	if DataMgr.anchor == 1 then
		return true
	end

	local CardInfo = RoomSystem.RoomCardInfoList[Mode2RoomCardSubType[roomType]]

	if CardInfo ~= nil then
		-- 只要次数还有，就直接反回了，省的判断时间
		if CardInfo.leftCount > 0 then
			return true
		end

		if CardInfo.expireTime - NetUtil.GetCurServerTime() > 0 then
			return true
		end
	end

	CardInfo = RoomSystem.RoomCardInfoList[Mode2RoomCardSubType[RoomModeType.ALL]]

	if CardInfo ~= nil then
		-- 只要次数还有，就直接反回了，省的判断时间
		if CardInfo.leftCount > 0 then
			return true
		end

		if CardInfo.expireTime - NetUtil.GetCurServerTime() > 0 then
			return true
		end
	end
	return false
end

-- 是否有对应类型的房卡
function RoomSystem.HaveRoomCardType(roomType)
	for k,v in pairs(DataMgr.arrayHallDepotItemInfo) do
		if v.itemSubType == Mode2RoomCardSubType[roomType] or v.itemSubType == Mode2RoomCardSubType[RoomModeType.ALL] then
			return true
		end
	end

	return false
end

-- 模式是否开启
function RoomSystem.IsRoomModeOpen(roomType)
	return LobbySystem.LobbyMenuOpenStatus[Mode2SwithID[roomType]] ~= nil and LobbySystem.LobbyMenuOpenStatus[Mode2SwithID[roomType]].is_open == 1
end

function RoomSystem.IsRoomModeClosedByVersion(roomType)
	-- 如果表格里找到一条同样模式的，就说明有符合的版本好
	for k, v in pairs(RoomCreateUI.RoomModeTableWithVersion) do
		if v.ModeID == roomType then
			return false
		end
	end

	return true
end

--请求修改房间参数
--ss, name, map_id, password, group_type, allow_invite, battle_custom_cfg, is_fpp
function RoomSystem.req_change_room(name, map_id, password, group_type, allow_invite, battle_cfg, modeid)
	local local_map = Client.GetTableData("Map", map_id);
	local isfpp = local_map.IsFpp and local_map.IsFpp==1
	if password == "" then
		NetUtil.SendPkg("change_room_request", name, map_id, nil, group_type, allow_invite, battle_cfg, isfpp, RoomSystem.CurrentRoomInfo.use_pc_param);
	else
		NetUtil.SendPkg("change_room_request", name, map_id, password, group_type, allow_invite, battle_cfg, isfpp, RoomSystem.CurrentRoomInfo.use_pc_param);
	end
end

function RoomSystem.on_change_room_respond(res)
	log("on_change_room_respond res = "..res);

	if res ~= 0 then
		DataMgr.ShowNoticeByID(res);
		return;
	end

	RoomCreateUI.HideUI()
end

--房间参数变更通知
function RoomSystem.on_sync_room_change(room_id, room)
	log("on_sync_room_change");
	-- log_tree("room = ", room);

	local bModifyMode = false;
	RoomSystem.CurrentRoomInfo = room;
	--[[
	RoomSystem.CurrentRoomInfo.name = room.name;
	RoomSystem.CurrentRoomInfo.game_mode_id = room.game_mode_id;
	RoomSystem.CurrentRoomInfo.is_fpp = room.is_fpp;
	RoomSystem.CurrentRoomInfo.weather_id = room.weather_id;
	RoomSystem.CurrentRoomInfo.weather_name = room.weather_name;
	RoomSystem.CurrentRoomInfo.map_id = room.map_id;
	RoomSystem.CurrentRoomInfo.lock_state = room.lock_state;
	RoomSystem.CurrentRoomInfo.allow_invite = room.allow_invite;
	RoomSystem.CurrentRoomInfo.battle_custom_cfg = room.battle_custom_cfg;
	RoomSystem.CurrentRoomInfo.use_pc_param = room.use_pc_param;
	RoomSystem.CurrentRoomInfo.disband_tm = room.disband_tm;
	log("[CLL] disband time = "..tostring(room.disband_tm))
	--]]
	if RoomSystem.isRoomOwner() == true then
		if room.password ~= nil then
			BP_CreateRoom_Passwd = room.password;
			BP_Room_Passwd = room.password;
		else
			BP_CreateRoom_Passwd = "";
			BP_Room_Passwd = "";
		end
	end
	if RoomSystem.CurrentRoomInfo.group_type ~= room.group_type then
		RoomSystem.CurrentRoomInfo.group_type = room.group_type;
		bModifyMode = true;
	end

	EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_UPDATE_CURRENTROOMINFO);

	LuaClassObj.HandleUIMessage(bp_room_waiting, "RefreshRoomUI");
	if bModifyMode then
		LuaClassObj.HandleUIMessage(bp_room_waiting, "InitRoomUI");
		LuaClassObj.HandleUIMessage(bp_room_waiting, "RefreshMemberList");
	end
end

--退出房间
function RoomSystem.on_exit_room_rsp()
	--清空房间
	RoomSystem.CurrentRoomInfo = {};
	--退出房间
	BP_Room_InitiativeLeave = false;
	BP_Room_IsInRoom = false;

	RoomWaitingUI:LeaveRoom()
end
--[[网络回调]]--
s2c["sync_room_list"] = RoomSystem.on_sync_room_list;
s2c["join_room_respond"] = RoomSystem.on_join_room_respond;
s2c["sync_room_member"] = RoomSystem.on_sync_room_member;
s2c["sync_room_state"] = RoomSystem.on_sync_room_state;
s2c["room_disband"] = RoomSystem.on_room_disband;
s2c["change_room_pos_respond"] = RoomSystem.on_change_room_pos_respond;
s2c["room_kick_respond"] = RoomSystem.on_room_kick_respond;
s2c["notify_enter_game"] = RoomSystem.on_notify_enter_game;
s2c["start_game_respond"] = RoomSystem.on_start_game_respond;
s2c["enter_game"] = RoomSystem.on_enter_game;
s2c["change_room_name_respond"] = RoomSystem.on_change_room_name_request;
s2c["change_room_group_type_respond"] = RoomSystem.on_change_room_group_type_respond;
s2c["change_room_map_respond"] = RoomSystem.on_change_room_map_respond;
s2c["room_info_notify"] = RoomSystem.on_room_info_notify;
s2c["query_room_respond"] = RoomSystem.on_query_room_respond;
s2c["sync_room_info"] = RoomSystem.on_sync_room_info;
s2c["room_start_game_notify"] = RoomSystem.on_room_start_game_notify;
s2c["lock_room_pos_respond"] = RoomSystem.on_lock_room_pos_respond;
s2c["unlock_room_pos_respond"] = RoomSystem.on_unlock_room_pos_respond;
s2c["sync_room_lock"] = RoomSystem.on_sync_room_lock;
s2c["get_room_battle_watch_info_rsp"] = RoomSystem.get_room_battle_watch_info_rsp;
s2c["enter_league_room_rsp"] = RoomSystem.on_enter_online_room;

s2c["room_invite_respond"] = RoomSystem.on_room_invite_respond;	--房间邀请他人响应
s2c["room_invite_reply_notify"] = RoomSystem.on_room_invite_reply_notify;	--房间邀请他人收到他人的回复
s2c["change_room_respond"] = RoomSystem.on_change_room_respond;
s2c["sync_room_change"] = RoomSystem.on_sync_room_change;
s2c["exit_room_rsp"] = RoomSystem.on_exit_room_rsp;--房间同步信息丢包再次点击退出房间时

