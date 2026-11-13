
--https://docs.google.com/spreadsheets/d/1wAtt7xOlIcX3dpuM7UbbS0Wr9dwEVKxwRsfUHbcNws8/edit#gid=993147048
--[[
 组队相关逻辑
]]--

local AUTO_REFUSE_TIME_OUT = 300;
local APPLY_INVITE_SHOW_TIME = 5;
local bAddTeamMemberForTest = true;

TeamUpSystem = TeamUpSystem or
{
	--暂时没有地方取自己的uid
	--这个地方处理一下
	MyUserID = 0,
	TeamInfo = {},	
	--[[
	 TeamInfo
		├─ members
		│  └─ 382236358
		│     ├─ name: "吃鹅ebrcx"
		│     └─ svr: 17039369		
				team.member[uid].carteam_name，为nil时无战队
		│  └─ 38223623123
		│     ├─ name: "吃鹅2ebrcx"
		│     └─ svr: 17039369
		├─ team_type: 4
		├─ id: 6488841903671345157
		├─ create_time: 1510841388
		├─ player_count: 0
		└─ leader: 382236358
	]]--
	--邀请者ID
	Inviter = 0,
	InviterTeamID = 0,
	--申请入队者ID
	ApplyerID = 0,
	ApplyerTeamID = 0,
	
	--是否增加成员
	IsAddMember = true,
	ChangeMemberInfo = {},	
		
	--队员换装广播数据存储
	ChangeWearInfo = {},
	HeadShowChangeInfo = {},
	ChangeWearPair = {},
	AutoRefuseInviterMap  = {},
	AutoRefuseApplyerMap = {},
	
	--存储聊天相关人的状态,在线，离线，组队状态，游戏状态
	PlayerStatu = {},
	--组队限时开放
	ModeShields = {},
	ModeSwitchTable = {},
	ModeInfoList = {},
	ModeViewLimit = {},
	TeammateModeInfo = {}, -- 队友查看的模式

	InviteApplyQueue = {},
	InviteApplyShowing = false,
	InviteApplyShowType = 0,
	InviteApplyShowTime = 0,

	--队友捏脸换性别
	ChangeAvatarInfo = {},

	--当前队伍是否模拟器
	CurTeamEmulator = false,
	CurTeamEmulatorType = -1, --0表示手机用户，1表示腾讯模拟器队伍，2表示非腾讯模拟器队伍

	WXPlatformInviteType = 0, -- 0结构化，1小程序

  	ChooseZoneList = {},

  	ChooseZoneId = 0,

  	RegionVoiceUrlList = {},

  	SelectRegionVoiceUrl = "",

  	-- 标记是否进过战斗
  	HasEnterFighting = false,

  	msgIdGuid = 0;--msgId全局唯一标识符
	msgContentCacheMap =  --缓存发送的消息，服务器不再回发给发送者
	{
		--msgId = msgContent,
	};

	-- 仅用于首次更新到下载地图版本时，修改当前模式为可用地图
	mapModelID = 0,
	mapGroupID = {},

	mapSkillInfo = nil;		-- 地图词缀信息
}

--取成员数量
function TeamUpSystem.GetTeamPlayCount()
	--默认单人
	local result = 0;
	if TeamUpSystem.TeamInfo ~= nil and TeamUpSystem.TeamInfo.player_count ~= nil then
		result = tonumber(TeamUpSystem.TeamInfo.player_count);
	end
	return result;	
end

--取组队模式
function TeamUpSystem.GetTeamType()
	local result = 0;
	if TeamUpSystem.TeamInfo ~= nil and TeamUpSystem.TeamInfo.team_type ~= nil then
		result = tonumber(TeamUpSystem.TeamInfo.team_type);
	end
	return result;	
end

---自己是否是队长
function TeamUpSystem.IsTeamLeader()		
	local result  = true;
	if TeamUpSystem.TeamInfo ~= nil and  TeamUpSystem.MyUserID ~= nil and TeamUpSystem.TeamInfo.leader ~= nil then		
		if TeamUpSystem.MyUserID ~= TeamUpSystem.TeamInfo.leader then
			result = false;
		end
	end
	
	return result;
	--return TeamUpSystem.TeamInfo ~= nil and TeamUpSystem.MyUserID == TeamUpSystem.TeamInfo.leader;	
end

--获取非队长状态下是否已准备--
function TeamUpSystem.GetMyStatus()
	if TeamUpSystem.TeamInfo ~= nil then
		local myInfo = TeamUpSystem.GetMemberInfo(TeamUpSystem.MyUserID);
		if myInfo ~= nil then
			return myInfo.status;
		end
	end
	
	return 1;	--如果没有队伍信息，默认是准备--
end

--获取是否所有玩家已准备
function TeamUpSystem.IsEverybodyReady()
	--队伍只有一个人的时候无需判断准备的条件
	if TeamUpSystem.TeamInfo.player_count ~= nil then
		if TeamUpSystem.TeamInfo.player_count == 1 then
			return true;
		end
	end

	for key, value in pairs (TeamUpSystem.TeamInfo.members) do
		if (TeamUpSystem.TeamInfo.members[key].status ~= 1) and (key ~= TeamUpSystem.TeamInfo.leader) then
			return false;
		end
	end
	return true;
end

--获取默认模式ID
function TeamUpSystem.GetDefaultRoomMode()
-- nanneli csv
	local Match_Mode_Table = Client.GetTable("MatchModeTable")
	for key, value in pairs(Match_Mode_Table) do  
		if Client.GetTableData("MatchModeTable", key).DefaultChosen == 1 then
			return Client.GetTableData("MatchModeTable", key).ID;
		end
	end 
end

--[[
	   ret
	   ├─ svr: 17039369
	   ├─ name: "吃鹅hbyyi"
	   └─ status: 1
]]

--获取成员信息
function TeamUpSystem.GetMemberInfo(userid)
	return TeamUpSystem.TeamInfo.members[tonumber(userid)];
end

function TeamUpSystem.GetMemberName(userid)
	--优先取队伍中的成员名字，然后再从好友中取名字
	local userinfo = TeamUpSystem.GetMemberInfo(userid);
	if (userinfo == nil) then

		local friendData = FriendSystem.GetFriendDataByGID(userid);
		if(friendData == nil) then
			return "";
		end			

		return friendData.nickName;			

	else
		return userinfo.name;
	end
end

function TeamUpSystem.InitMyUserID()
	if DataMgr.roleData ~=nil and DataMgr.roleData.uid ~= nil then
		TeamUpSystem.MyUserID = tonumber(DataMgr.roleData.uid);
	end	
end

function TeamUpSystem.Enter()
	log("TeamUpSystem enter"); 
	TeamUpSystem.InitMyUserID();
	TeamUpSystem.query_myid_request();
	--TeamUpSystem.team_info_request();
	TeamUpSystem.get_label_status_req();
	TeamUpSystem.get_horse_lamp_req();
end

--更新聊天菜单信息
function TeamUpSystem.UpdateMenuForChat()
	log("TeamUpSystem.UpdateMenuForChat");
	if nil ~= TeamUpSystem.PlayerStatu.teamState then	
		LobbyChatLogic.UpdateTeamupMenu(TeamUpSystem.PlayerStatu.teamState, TeamUpSystem.PlayerStatu.online);
	end
end

--取状态
function TeamUpSystem.GetStatuByUID(uid)
	--[[
	teamState=teamState,						// 0 空闲 1 组队中 2 游戏中
	teamId=teamId, 								// 队伍ID
	currentTeamAmount=currentTeamAmount,		// 队伍当前人数
	maxTeamAmount=maxTeamAmount, 				// 队伍最大人数
	timeSinceGameBegin=timeSinceGameBegin, 		// 游戏开局了多久(单位秒)
	online=online  								// 0 不在线  1 在线
	--]]
	local result = nil;
	for key,v in pairs(TeamUpSystem.PlayerStatu) do
		
		if key == uid then
			result = v;
			break;
		end
	
	end	
	return result;
end

--队员语音房间信息
function TeamUpSystem.UpdateVoiceInfo(uid, voiceinfo)
	local memberinfo = TeamUpSystem.GetMemberInfo(uid);
	if memberinfo == nil then
		log("TeamUpSystem.UpdateVoiceInfo memberinfo is none");
		return;
	end
	--member.voice={voice_uid=voice_uid, voice_open=voice_open}
	TeamUpSystem.TeamInfo.members[uid].voice = voiceinfo;
	--voice_info = {uid=uid, voice={voice_uid=voice_uid, voice_open=voice_open}};
end

--队员战队名字
function TeamUpSystem.UpdateCarteamName(uid, carteam_name)
	local memberinfo = TeamUpSystem.GetMemberInfo(uid);
	if memberinfo == nil then
		log("TeamUpSystem.UpdateCarteamName memberinfo is none");
		return;
	end
	TeamUpSystem.TeamInfo.members[uid].carteam_name = carteam_name;
	log("TeamUpSystem.UpdateCarteamName carteam_name:"..tostring(TeamUpSystem.TeamInfo.members[uid].carteam_name));
end

--队员战队名字
function TeamUpSystem.GetMemberCarteamName(uid)
	local result = "";
	local memberinfo = TeamUpSystem.GetMemberInfo(uid);
	if memberinfo ~= nil and memberinfo.carteam_name ~= nil  then
		result = memberinfo.carteam_name;
	end
	return result;
end

--是否打开语音
function TeamUpSystem.IsOpenVoice(uid)
	log("IsOpenVoice"..tostring(uid));
	local result = false;
	local memberinfo = TeamUpSystem.GetMemberInfo(tonumber(uid));
	--log_tree("IsOpenVoice",memberinfo)
	if memberinfo ~= nil then
		if memberinfo.voice ~= nil and memberinfo.voice.voice_open == true then
			result = true;
		end
	end
	log("IsOpenVoice"..tostring(result));
	return result;
end
------- C2S -------
--获取自己的uid
--临时用，因为暂时没有其它地方可以取得
function TeamUpSystem.query_myid_request()
	log("query_myid_request" );
	NetUtil.SendPkg("query_myid_request");
end

--请求队伍信息
function TeamUpSystem.team_info_request()
	log("team_info_request" );
	NetUtil.SendPkg("team_info_request");
end

--改变房间类型
function TeamUpSystem.team_change_type_request(modelId)
	log("[HHF]TeamUpSystem.team_change_type_request, modelId = " .. tostring(modelId));
	-- 获取当前选中视图id列表
	local viewIds = {};
	for k,v in pairs(TeamUpSystem.ModeInfoList) do
		if k == modelId then	
			for kk,vv in pairs(v.mode_group) do
				if vv.is_default == 1 then
					table.insert(viewIds, vv.group_id);
				end
			end
			break;
		end
	end
	--log_tree("[HHFTEST]TeamUpSystem.team_change_type_request, viewIds = ", viewIds, "[HHFTEST]");

	NetUtil.SendPkg("team_change_type_request", modelId, viewIds);
end

--邀请好友
function TeamUpSystem.team_invite_request(userid)
	local inviteInfo = {}
	inviteInfo.stringId = 0
	--inviteInfo.netDelay = BP_LobbyNetworkDelay
	local zoneIp = "";
	for i,v in pairs(TeamUpSystem.ChooseZoneList) do
		if v.zone_id == TeamUpSystem.ChooseZoneId then
			zoneIp = v.tpingsvr_ip;
		end
	end

	inviteInfo.netDelay = Client.GetServerDelay(zoneIp);
	--获取地图名
	local curModelMapInfo = nil;
	local mapId = 0;
	local selectedCount = 0;
	if TeamUpSystem.IsTeamLeader() then
		for k,v in pairs(TeamUpSystem.ModeInfoList) do
			if k == BP_STRUCT_CurSelectedModelInfo.model_id then
				curModelMapInfo = v;
				break;
			end
		end
	else
		curModelMapInfo = TeamUpSystem.TeammateModeInfo;
	end
	for k,v in pairs(curModelMapInfo.mode_group) do
		if v.is_default == 1 then
			selectedCount = selectedCount + 1;
			mapId = k;
		end
	end
	if selectedCount == 1 then
		local infoConfig = Client.GetTableData("ModeTeamTable", mapId);
		if infoConfig then
			inviteInfo.stringId = tonumber(infoConfig.mapName);
		end
	else
		--获取模式名
		local modelConfig = Client.GetTableData("MatchModeTable", BP_STRUCT_CurSelectedModelInfo.model_id);
		inviteInfo.stringId = modelConfig.ModeWhenHide;
	end
	log("team_invite_request, invite: " .. userid.." stringID= "..tostring(inviteInfo.stringId).." delay = "..tostring(inviteInfo.netDelay ));
	NetUtil.SendPkg("team_invite_request", userid, inviteInfo);
end

--聊天招募接口team_join_respond
function TeamUpSystem.JoinTeamByChat(uid, teamid, src)
	log("[HHF]TeamUpSystem.JoinTeamByChat, uid = " .. tostring(uid) .. ", teamid = " .. tostring(teamid) .. ", src = " .. tostring(src));
	if DataMgr.roleData ~= nil then
		if DataMgr.roleData.uid == uid then
			if src ~= "facebook" then
				--你已经在队伍中
				DataMgr.ShowNoticeByID(110045);
			end
			return;			
		end
	end	

	--local timeTick = os.time - timeString;
	--if timeTick > 600 then --如果大于10分钟，则表示消息失效
		--TODO,提示
	--	log("JoinTeamByChat time is vaild");
		--return;
	--end
	--res 用 enlist ，我就不发给队长,队长就收不到申请	
	TeamUpSystem.team_invite_reply("enlist", tonumber(uid), tonumber(teamid), src);
end

--回应收到的邀请
function TeamUpSystem.team_invite_reply(ispermit, userid, teamid, src)
	log("[HHF]TeamUpSystem.team_invite_reply, Send team_invite_reply, ispermit = " .. tostring(ispermit) .. ", userid = " .. tostring(userid) .. ", teamid = " .. tostring(teamid) .. ", src = " .. tostring(src));
	NetUtil.SendPkg("team_invite_reply", ispermit, userid,teamid, src);
end

--回应收到的房间邀请
--extend_info={reply_type=1(主动回复) or 2(被动回复), }
function TeamUpSystem.room_invite_reply(ispermit, room_id, inviter, src, extend_info)
	log("room_invite_reply: room_id = "..room_id..", ispermit = "..ispermit);
	NetUtil.SendPkg("room_invite_reply", ispermit, room_id, inviter, src, extend_info);
	if ispermit == "ok" then
		RoomSystem.SetAcceptJoinRoom(true);
	end
end

--申请离队
function TeamUpSystem.team_quit_request(teamid)
	log("team_quit_request teamid = "..teamid);
	NetUtil.SendPkg("team_quit_request", teamid);
	-- bAddTeamMemberForTest = false;
end

--申请加入好友队伍
function TeamUpSystem.team_apply_request(userid)
	log("team_apply_request userid = "..userid);
	NetUtil.SendPkg("team_apply_request", userid);
	--后台返回才提示
	--DataMgr.ShowNoticeByID(110012);	--入队申请已发送
end

--对于申请组队提示的回应
function TeamUpSystem.team_apply_reply(ispermit, userid, teamid)
	log("team_apply_reply ispermit = "..ispermit..", userid = " .. userid);
	NetUtil.SendPkg("team_apply_reply", ispermit, userid, teamid);
end

--踢人
function TeamUpSystem.team_kick_request(userid)
	log("team_kick_request userid = "..userid);
	NetUtil.SendPkg("team_kick_request", userid);
end

--是否需要实时拉取好友变化
function TeamUpSystem.recv_stau_request(isNeed)
	log("recv_stau_request "..tostring(isNeed));
	--iphonexiao(肖建)  01-13 22:34:05备忘 是否接受好友通知标志的请求给干掉
	--NetUtil.SendPkg("chang_recv_group_statu_flag",true);
end


function TeamUpSystem.team_change_fill_request(fill)
	log("team_change_fill_request fill = "..tostring(fill));
	NetUtil.SendPkg("team_change_fill_request",fill);
end


------- S2C -------
function TeamUpSystem.team_change_leader_request(new_leader)
	log("team_change_leader_request new_leader = "..new_leader);
	NetUtil.SendPkg("team_change_leader_request", new_leader);
end

--请求陌生人所有状态
function TeamUpSystem.stange_all_status_request(uid)
	local oneUid = tonumber(uid);
	local list = {};
	table.insert(list,oneUid);
	local cb = "strengthStatu";
	NetUtil.SendPkg("batch_get_group_and_online_req",cb,list);
end

--请求预留teamid，用于平台邀请
function TeamUpSystem.get_teamid_for_plat_request()
	--c2s.team_recruit_for_plat_req( )
	log("get_teamid_for_plat ");
	if _G.BP_Platform == BP_ENUM_PLAYFORM_WX and Client.IsInstallWX(NetInterface) == false then
		--你还没有安装微信，无法使用此功能
		DataMgr.ShowNoticeByID(110126);
		return;
	elseif _G.BP_Platform == BP_ENUM_PLAYFORM_QQ and Client.IsInstallQQ(NetInterface) == false then
		--你还没有安装QQ，无法使用此功能
		DataMgr.ShowNoticeByID(110125);
		return;
	end
	NetUtil.SendPkg("team_recruit_for_plat_req");
end

--上报自己的语音房间信息
function TeamUpSystem.ReportVoiceInfo(voiceuid,voiceOpen)
	log("ReportVoiceInfo:"..voiceuid.."isOpen:"..tostring(voiceOpen));
	NetUtil.SendPkg("team_report_voice_info",tonumber(voiceuid),voiceOpen);
end

function TeamUpSystem.CacheMsg(tabContent)
	TeamUpSystem.msgIdGuid = TeamUpSystem.msgIdGuid + 1;
	TeamUpSystem.msgContentCacheMap[TeamUpSystem.msgIdGuid] = tabContent;
	return TeamUpSystem.msgIdGuid;
end

--招募请求
function TeamUpSystem.team_recruit(msgContent,sendWord,sendFriend,sendChannel,sendLocalLanguage,sendCorps,sendTeamRecruit,voiceType, mapArr)
	-- chat_content 招募内容  chat_content.text 文本消息
	-- send_world  世界招募  true or false
	-- send_friend  好友招募 true or false
	-- send_channel  频道招募  true or false	
	-- send_LocalLanguage  语种频道招募  true or false	
	-- sendCorps 军团 true or false	
	-- sendTeamRecruit 组队招募
	-- game_model_type 模式
	-- voiceType 语音模式
	local gameType = TeamUpModelUI.GetCurSelectModelType();
	local list = {};
	list.text = msgContent;
	list.game_model_type = gameType;
	list.VoiceType = voiceType;
	list.msgType = 1;
	list.team_recuit_map_data = mapArr;

	local msgId = TeamUpSystem.CacheMsg(list)

	--log("team_recruit_req:" .. msgId)	

	log("TeamUpSystem.team_recruit"..list.text..tostring(sendWord)..tostring(sendFriend)..tostring(sendChannel)..tostring(sendLocalLanguage));
	NetUtil.SendPkg("team_recruit",list, msgId)
end

--招募请求返回,ok不处理
function TeamUpSystem.team_recruit_rsp(ret, time_left, team_id, msg_id)

	local tabContent = TeamUpSystem.msgContentCacheMap[msg_id]; --自己收到自己发送的消息，如果没有敏感词需要过滤的情况下不再发送chat_content，节省下行流量
	TeamUpSystem.msgContentCacheMap[msg_id] = nil;

	--log("TeamUpSystem.team_recruit_rsp"..tostring(ret));
	if ret == "ok" then
		--log_tree("msgContentCacheMap:", TeamUpSystem.msgContentCacheMap)
		--if chat_type ~= LobbyChatSystem.channelPrivate and chat_type ~= LobbyChatSystem.channelTeam then
			--log_tree("ddddddddddddddddddd me",tabContent)
			--if tabContent.client_ver ~= nil then
				--local isMatch = FuncUtil:IsMatchVersion(tabContent.client_ver);
				--if isMatch == false then
					--如果版本不匹配，则不要在世界聊天显示，前台过滤
					--log("versionIsNotMatch");
					--return;
				--end
			--end	
		--log("team_recruit_msg_id:" .. msg_id)			
			-- 小古在这加队伍Id
			local voice_file = "";
			local voice_time = 0;
			local chat_ctt = tabContent.text;
			if true == tabContent.quickMsg then
				--log("LobbyChatSystem.on_chat_rsp,tabContent.quickMsg:" .. tostring(tabContent.quickMsg));
				chat_ctt = Client.GetTableData("LocalizeRes", tabContent.text).TextValue;
			end
			if nil ~= tabContent.voice and "" ~= tabContent.voice then
				voice_time = tabContent.voiceLength;
				voice_file = tabContent.voice;		

				--log("send voice message length" .. tostring(voice_time));
			end

			local sender_name = DataMgr.roleData.nickName;
			local sender_uid = DataMgr.roleData.uid;			
			local msg_type = tabContent.msgType;
	        local nation = ProfileMgr.GetRoleNationByUid(sender_uid);
	        --local topic = tabContent.topic;
	        --local other = tabContent.other;

			--local team_id = time_left;
			local map_data = tabContent.team_recuit_map_data;
			local avatarData = LobbyChatLogic.GetHeadData(sender_uid)
			LobbyChatLogic.AddNewChat(LobbyChatSystem.channelTeamRecruit, 1, sender_name, voice_file, voice_time, chat_ctt, sender_uid, true, team_id, "", "", nation, nil, nil, nil, avatarData, map_data);
			LobbyChatEntranceUI.ReceiveNewMsg(LobbyChatSystem.channelTeamRecruit, msg_type, sender_name, voice_file, voice_time, chat_ctt, "", true);
		--end
	elseif ret == "request_frequent" then
		--todo
		local msgContent = string.format(Client.GetTableData("LocalizeRes", "100007").TextValue, time_left);
		DataMgr.ShowNoticeByString(msgContent);
		--time_left    请求频繁时返回还剩余多少秒可以请求
	end
end

local function CreateTeamInfoSingle(_teaminfo)
	--local nickname  = DataMgr.roleData == nil and "" or DataMgr.roleData.nickName;	
	--重构单人数据结构
	local teaminfo = {};
	teaminfo.fill = _teaminfo.fill;
	teaminfo.player_count = 1;
	teaminfo.id = 0;
	teaminfo.leader = TeamUpSystem.MyUserID;
	teaminfo.members = _teaminfo.members;	
	teaminfo.team_type = _teaminfo.team_type;
	teaminfo.sub_mode_view_ids = _teaminfo.sub_mode_view_ids;
	return teaminfo;
end


--聊天内点击进入队伍

--获取自己uid回应
function TeamUpSystem.on_query_myid_respond(myuserid)
	log("on_query_myid_respond "..myuserid);
	TeamUpSystem.MyUserID = myuserid;
	TeamUpSystem.team_info_request();
	
	--同步下组队限时开放
	TeamUpSystem.on_mode_shield_req();
end

--队伍信息同步
function TeamUpSystem.on_team_info_sync(teamid, teaminfo)
	log("[HHF]TeamUpSystem.on_team_info_sync, received team_info_sync, teamid = " .. tostring(teamid));
	--log_tree("[HHF]TeamUpSystem.on_team_info_sync, teaminfo = ", teaminfo, "[HHF]");

	--为0表示单人
	if teamid == 0 then
		teaminfo =  CreateTeamInfoSingle(teaminfo);
	end
	
	--更新性别
	for k,v in pairs(teaminfo.members) do
		ProfileMgr.UpdateRoleSexByUid(k, v.avatar.gamegender)
		----伪造pet数据
		--v.pet_info = {}
		--v.pet_info.id = 50001
		--v.pet_info.exp = 200000
	end
	
	--主题处理组队
	if teamid == 0 then
		HallThemeUtils.ProcLeaveTeam()
	else
		HallThemeUtils.ProcEnterTeam(teaminfo)
	end

	--log_tree("[HHF]TeamUpSystem.on_team_info_sync, teaminfo = ", teaminfo, "[HHF]");

	Client.ClearAdjustDeepLink();
	local curStatus = string.lower(LuaClassObj.GetGameStatus(bp_global));
	log("[LLP]TeamUpSystem.on_team_info_sync, received team_info_sync, team(player_count) = " .. tostring(teaminfo.player_count));
	log("[LLP]TeamUpSystem.on_team_info_sync, received team_info_sync, team(curStatus) = " .. curStatus);
	if curStatus == "lobby" then
		
	elseif curStatus == "fighting" then
		log("[LLP]TeamUpSystem.on_team_info_sync, received team_info_sync, fighting player change");
		-- 战斗中队伍信息的改变需要调整BP_LobbyPlayerNum，避免回到大厅时镜头错误
		-- http://tapd.oa.com/iGameInternational/bugtrace/bugs/view?bug_id=1020360302065358253
		BP_LobbyPlayerNum = teaminfo.player_count;
	end
	if teaminfo.gvoice_url ~= nil then
		log("TeamUpSystem.on_team_info_sync" .. teaminfo.gvoice_url);
		if TeamUpSystem.SelectRegionVoiceUrl == nil or TeamUpSystem.SelectRegionVoiceUrl ~= teaminfo.gvoice_url then
			TeamUpSystem.SelectRegionVoiceUrl = teaminfo.gvoice_url;
			BP_SelectRegionVoiceUrl = teaminfo.gvoice_url;
			LuaClassObj.HandleUIMessage(bp_teamup, "UpdateVoiceUrl");
		else
			TeamUpSystem.SelectRegionVoiceUrl = teaminfo.gvoice_url;
			BP_SelectRegionVoiceUrl = teaminfo.gvoice_url;
		end
	end

	--TODO jack , modify by lepengli
	-- if bAddTeamMemberForTest then
	-- 	TeamUpUI.TestAddOnPlayer(teaminfo, 1);
	-- 	TeamUpUI.TestAddOnPlayer(teaminfo, 2);
	-- 	-- TeamUpUI.TestAddOnPlayer(teaminfo, 3);
	-- 	teaminfo.team_type = 0;
	-- end

	-- 用于处理邀请队列
	-- 战队赛需要
	TeamUpSystem.CheckInviteApplyOnTeamChange(teaminfo);
	
	-- 用于处理大厅匹配逻辑
	-- 战队赛应该不需要

	TeamUpSystem.CompareMemBer(teaminfo);
	--EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_COMPARE_DATA);

	-- 战队赛需要
	TeamUpSystem.TeamInfo = teaminfo;
	
	-- 更新当前选中的模式的模式组选中状态
	-- 战队赛需要
	TeamUpSystem.SaveTeamModelInfo(teaminfo.team_type, teaminfo.sub_mode_view_ids);
			
	if teaminfo.is_participate_competition == true then
		AllianceCompetitionRoomUI.Show()
	else
		AllianceCompetitionRoomUI.Hide()
	end
	
	EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_SYNC)
	--基本用于聊天处理，但也可以用于界面处理 
	-- 战队赛需要
	-- EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_SYNC)
	
	-- 聊天处理
	-- 战队赛应该不需要
	TeamUpSystem.ProcessChat();


	--模拟器检测
	TeamUpSystem.InitTeamEmulatorType();
	TeamUpSystem.ProcessEmulatorTips();
	
	--刷新下锁
	TeamUpUI.ProcessDestinyLock();
	
	-- 装备处理
	-- 战队赛应该不需要
	TeamUpSystem.RefreshWeapon();

	-- 战队赛应该需要
	-- 战斗中A和B组队，A断线重连过程中队伍信息的改变，重连后只能在这里处理相机逻辑，避免回到大厅时镜头错误
	-- http://tapd.oa.com/iGameInternational/bugtrace/bugs/view?bug_id=1020360302065358253
	if TeamUpSystem.HasEnterFighting then
		-- 处理成强制切一次相机
		log("[LLP]TeamUpSystem.on_team_info_sync, received team_info_sync, force switch camera");
		LuaClassObj.HandleUIMessage(bp_lobby, "SwitchBackLobbyMainCamera");
		TeamUpSystem.HasEnterFighting = false;
	end

	--	处理宠物
	local PetSystem = require("client.slua.logic.pet.logic_pet")
	for k,v in pairs(teaminfo.members) do
		local pet_info = v.pet_info
		if pet_info ~= nil then
			local petLevel = PetSystem.GetPetLevelByExp(pet_info.id, pet_info.exp)
			TeamAvatarManager.CreatePet(k, pet_info.id, petLevel)
			if v.name ~= nil then
				TeamAvatarManager.SetPetName(k, v.name)
			end
		end
	end
end

function TeamUpSystem.RefreshWeapon()

	if (TeamUpSystem.TeamInfo ~= nil and TeamUpSystem.TeamInfo.members ~= nil and TeamUpSystem.TeamInfo.player_count > 1) then
		for k,v in pairs(TeamUpSystem.TeamInfo.members) do
			local uid = k;
			local weaponId = v.weapon_wear_info ~= nil and v.weapon_wear_info.weapon_id or 0;
			local skinId = v.weapon_wear_info ~= nil and v.weapon_wear_info.skin_id or 0;
			if (weaponId == nil or weaponId == 0 or weaponId == "0") then
				LobbyUI:UnEquipWeapon(uid)
			else
				LobbyUI:EquipWeapon(uid, weaponId, skinId)
			end
		end
	end
end

function TeamUpSystem.CheckInviteApplyOnTeamChange(teaminfo)
	log("TeamUpSystem.CheckInviteApplyOnTeamChange");
	if (TeamUpSystem.TeamInfo ~= nil and TeamUpSystem.TeamInfo.id ~= nil and TeamUpSystem.TeamInfo.id ~= teaminfo.id) then
		local queueLength = #TeamUpSystem.InviteApplyQueue;
		log("queueLength = " .. queueLength);
		if (queueLength > 0) then
			for i = 1, queueLength, 1 do
				local inviteApplyData = TeamUpSystem.InviteApplyQueue[i];
				--log_tree("inviteApplyData", inviteApplyData);
				if (inviteApplyData ~= nil and inviteApplyData.type == 0) then
					log("autoRefuseOnTeamChange invite playerId = " .. inviteApplyData.playerId);
					TeamUpSystem.team_invite_reply("autoRefuseOnTeamChange", tonumber(inviteApplyData.playerId),tonumber(inviteApplyData.InviterTeamID));
				elseif (inviteApplyData ~= nil and inviteApplyData.type == 1) then
					--log("autoRefuseOnTeamChange apply playerId = " .. inviteApplyData.playerId);
					TeamUpSystem.team_apply_reply("autoRefuseOnTeamChange", tonumber(inviteApplyData.playerId),tonumber(inviteApplyData.ApplyerTeamID));
				elseif (inviteApplyData ~= nil and inviteApplyData.type == 2) then
					log("autoRefuseOnTeamChange room invite playerId = " .. inviteApplyData.playerId);
					TeamUpSystem.room_invite_reply("autoRefuseOnTeamChange", tonumber(inviteApplyData.InviterRoomID), tonumber(inviteApplyData.playerId));
				end
			end
		end
		
		TeamUpSystem.InviteApplyQueue = {};
		TeamUpUI.CloseInviteApplyPanel();		
	end
end


--邀请好友响应
function TeamUpSystem.on_team_invite_respond(state, invitee, verCompareResult)
	log("on_query_myid_respond state = "..state..", invitee = "..invitee);
	if(state == "ok") then
		DataMgr.ShowNoticeByID(110004);	--邀请消息已发送
		--好友进入队伍
		TeamUpSystem.team_info_request();
	elseif (state == "target-not-online") then
		DataMgr.ShowNoticeByID(110016);
		--PopUpNoticeUI.ShowMessageBox("提示", "邀请失败，对方不在线。");
	elseif (state == "team-is-full") then
		DataMgr.ShowNoticeByID(110007);
		--PopUpNoticeUI.ShowMessageBox("提示", "邀请失败，队伍人数已满。");
	elseif (state == "refuse") then
		DataMgr.ShowNoticeByID(110011);
		--用户主动拒绝
	elseif (state == "autoRefuseOnTeamChange") then
		DataMgr.ShowNoticeByID(110056);	--对方已加入其它队伍
	elseif (state == "invitee_in_match") then 
		DataMgr.ShowNoticeByID(110059);----%s在匹配中		
	elseif (state == "inviter_in_match") then 
		DataMgr.ShowNoticeByID(110059);----%s在匹配中			
	elseif (state == "inviter_in_game") then 
		DataMgr.ShowNoticeByID(9911106);----游戏中		
	elseif (state == "team in match") then 
		DataMgr.ShowNoticeByID(110060);----	队伍已经在匹配中
	elseif (state == "already_in_match") then 
		DataMgr.ShowNoticeByID(110061);----	已经在匹配中
	elseif state == "not_same_version" then
		--[110149]={TextId=110149, TextValue="因您未更新到新版本，邀请组队失败。建议您更新游戏。"},
		--[110150]={TextId=110150, TextValue="对方未更新到最新版本，无法组队。 "},
		TeamUpUI.HandelVertionCompareTips(verCompareResult);
		
	elseif state == "already_has_team"  then		
		--您已在组队中，不可加入其他队伍。	
		DataMgr.ShowNoticeByID(110044);

	elseif state == "invitee_already_in_team"  then		
		--被邀请者已在组队中，不可加入其他队伍。	
		DataMgr.ShowNoticeByID(6283)
		
	else
	--team_invite_respond("already_in_room", invitee)   ---您在房间中，不能组队。
	--team_invite_respond("invitee_in_room", invitee)   ---对方房间中，不能组队。
		TeamUpUI.ProtocolErrorCode(state);
	end
end

--收到邀请提示
function TeamUpSystem.on_team_invite_notify(inviter,  teamId, team_type, inviteInfo)
	local autoRefuse = TeamUpSystem.CheckInviteAutoRefuse(inviter);
	
	if (autoRefuse == true) then
		log("on_team_invite_notify autoRefuse = true");
		return;
	end
	--不在黑名单的才弹出邀请消息
	local isPullBack = FriendSystem.IsPulBlack(inviter);
	log("on_team_invite_notify ispulblack:"..tostring(isPullBack));
	if isPullBack == false then			
		local inviteApplyData = {};
		inviteApplyData.type = 0;
		inviteApplyData.playerId = inviter;
		inviteApplyData.InviterTeamID = teamId;
		inviteApplyData.playerName = TeamUpSystem.GetMemberName(inviter);
        inviteApplyData.gameType = TeamUpUI.GetOldGameType(team_type);
		if inviteInfo and inviteInfo.netDelay then
			inviteApplyData.netDelay = inviteInfo.netDelay
		end
		if inviteInfo and inviteInfo.stringId then
			inviteApplyData.mapName = inviteInfo.stringId
		end
		table.insert(TeamUpSystem.InviteApplyQueue, inviteApplyData);
		TeamUpSystem.CheckNextInviteApply();
		--TeamUpSystem.Inviter = inviter;	
		--EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_GET_INVITE);
	end
end

function TeamUpSystem.CheckNextInviteApply()
	
	if (TeamUpSystem.InviteApplyShowing)  then
		local timeDiff = os.time() - TeamUpSystem.InviteApplyShowTime;
		if (timeDiff < (APPLY_INVITE_SHOW_TIME + 1)) then
			return;
		end
	end
	
	if #TeamUpSystem.InviteApplyQueue > 0 then
		
		local inviteApplyData = TeamUpSystem.InviteApplyQueue[1];
		table.remove(TeamUpSystem.InviteApplyQueue, 1);
		
		TeamUpSystem.InviteApplyShowing = true;
		TeamUpSystem.InviteApplyShowTime = os.time();
		
		--log("show invite apply");
		--log_tree("inviteApplyData", inviteApplyData);
		
		if (inviteApplyData.type == 0) then
			if (TeamUpSystem.TeamInfo.player_count > 1) then
				TeamUpSystem.InviteApplyShowing = false;
				TeamUpSystem.team_invite_reply("autoRefuseOnTeamChange", tonumber(inviteApplyData.playerId),tonumber(inviteApplyData.InviterTeamID));
				TeamUpSystem.CheckNextInviteApply();
				return;
			end
			TeamUpSystem.InviteApplyShowType = 0;
			TeamUpSystem.Inviter = inviteApplyData.playerId;	
			TeamUpSystem.InviterTeamID = inviteApplyData.InviterTeamID;
			TeamUp_Inviter_Name = inviteApplyData.playerName;
			BP_Teamup_NetworkDelay = inviteApplyData.netDelay or 0;
			BP_Teamup_DesStrId = inviteApplyData.mapName or 0;
			EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_GET_INVITE);
		elseif (inviteApplyData.type == 1) then
			if (TeamUpSystem.IsTeamLeader() == false) then
				TeamUpSystem.InviteApplyShowing = false;
				TeamUpSystem.team_apply_reply("autoRefuseOnTeamChange", tonumber(inviteApplyData.playerId),tonumber(inviteApplyData.ApplyerTeamID));
				TeamUpSystem.CheckNextInviteApply();
				return;
			end
			
			TeamUpSystem.InviteApplyShowType = 1;
			TeamUpSystem.ApplyerID = inviteApplyData.playerId;
			TeamUpSystem.ApplyerTeamID = inviteApplyData.ApplyerTeamID;
			TeamUp_Applyer_Name = inviteApplyData.playerName;
			EventSystem:postEvent(EVENTTYPE_TEAMUP, EVNETID_TEAMUP_APPLY_JOIN);
		elseif (inviteApplyData.type == 2) then		--房间邀请
			if TeamUpSystem.GetTeamPlayCount() > 1 then
				TeamUpSystem.InviteApplyShowing = false;
				TeamUpSystem.room_invite_reply("autoRefuseOnTeamChange", tonumber(inviteApplyData.InviterRoomID), tonumber(inviteApplyData.playerId));
				TeamUpSystem.CheckNextInviteApply();
				return;
			end
			TeamUpSystem.InviteApplyShowType = 2;
			TeamUpSystem.Inviter = inviteApplyData.playerId;
			TeamUpSystem.InviterRoomID = inviteApplyData.InviterRoomID;
			TeamUp_Inviter_Name = inviteApplyData.playerName;
			TeamUp_Invite_GameType = inviteApplyData.gameType;
			TEAMUP_INVITE_TIP = DataMgr.GetMsgByID(117090);		--邀请您进房间

			EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_ROOM_GET_INVITE);
		end
	end
end

--addby cole 10.17
function TeamUpSystem.RemoveAllRoomInvite()
	log("TeamUpSystem All CurInviter's RoomInvite")
	if #TeamUpSystem.InviteApplyQueue > 0 then
		for k=#TeamUpSystem.InviteApplyQueue,1 do
			if TeamUpSystem.InviteApplyQueue[k] and TeamUpSystem.InviteApplyQueue[k].type == 2
			and TeamUpSystem.Inviter and TeamUpSystem.Inviter == TeamUpSystem.InviteApplyQueue[k].playerId then
				table.remove(TeamUpSystem.InviteApplyQueue,k);
			end
		end
	end
end

function TeamUpSystem.CheckInviteAutoRefuse(inviter)
	return TeamUpSystem.CheckAutoRefuse(TeamUpSystem.AutoRefuseInviterMap, inviter, AUTO_REFUSE_TIME_OUT);
end

function TeamUpSystem.CheckApplyAutoRefuse(applyerID)
	return TeamUpSystem.CheckAutoRefuse(TeamUpSystem.AutoRefuseApplyerMap, applyerID, AUTO_REFUSE_TIME_OUT);
end

function TeamUpSystem.CheckAutoRefuse(map, id, timeout)

	if (map == nil or id == nil or timeout == nil) then
		return false;
	end
	
	local autoRefuseTime = map[id];
	
	if (autoRefuseTime == nil) then
		return false;
	end
	
	local timeDiff = os.time() - autoRefuseTime;
	log("TeamUpSystem.CheckAutoRefuse id = " .. id .. ", timeDiff = " .. timeDiff);
	
	return timeDiff < timeout;
end

--发送表情动作同步
function TeamUpSystem.team_player_action(action_id, randSoundId)
	randSoundId = randSoundId or 0
	--log("team_player_action action_id = " .. tostring(action_id)..",randSoundId="..randSoundId);
	NetUtil.SendPkg("team_player_action", action_id, randSoundId);
end

--退出队伍响应
function TeamUpSystem.on_team_quit_respond(state)
	log("on_team_quit_respond state = "..state)
	-- 请求一下新队伍的信息
	-- 还需要做其它什么吗？？
	if(state == "ok") then
		AllianceCompetitionSystemHandler.rspQuickRoom()

		TeamUpSystem.team_info_request();
		
		HallThemeUtils.ProcLeaveTeam()
	else
		--PopUpNoticeUI.ShowMessageBox("提示", "退出队伍失败");
	end	
	
end

--申请加入好友队伍 收到的响应
function TeamUpSystem.on_team_apply_respond(state, verCompareResult)
	log("on_team_apply_respond state = "..state);
	-- 请求一下新队伍的信息
	-- 还需要做其它什么吗？？
	if(state == "ok") then
		TeamUpSystem.team_info_request();
	elseif (state == "refuse") then
		DataMgr.ShowNoticeByID(110013); --对方拒绝了入队申请
	elseif (state == "autoRefuseOnTeamChange") then
		DataMgr.ShowNoticeByID(110057);	--对方队长退出队伍了，请重新申请
	elseif (state == "team in match") then 
		DataMgr.ShowNoticeByID(110060);----	队伍已经在匹配中
	elseif state == "send_apply_success" then
		--后台返回才提示
		DataMgr.ShowNoticeByID(110012);	--入队申请已发送
	elseif state == "not_same_version" then
		--[110149]={TextId=110149, TextValue="因您未更新到新版本，邀请组队失败。建议您更新游戏。"},
		--[110150]={TextId=110150, TextValue="对方未更新到最新版本，无法组队。 "},
		TeamUpUI.HandelVertionCompareTips(verCompareResult);
	elseif state == "team_is_full" then
		DataMgr.ShowNoticeByID(110007);
	else
		--team_apply_respond("already_in_room")             ---您在房间中，不能组队。
		--team_apply_respond("applicant_in_room")           ---被申请者在房间中，不能组队。
		TeamUpUI.ProtocolErrorCode(state);

	end
end

--踢人
function TeamUpSystem.on_team_kick_respond(res, targetUID)
	
	log("on_team_kick_respond res = "..res..", targetUID = "..targetUID);

	if(res == "ok") then
		TeamUpSystem.team_info_request();
	else
		--PopUpNoticeUI.ShowNewNotice("踢出失败");
		PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes",301165).TextValue);
	end	
end

--收到申请进入队伍提示
function TeamUpSystem.on_team_apply_notify(applyerID, applyerName, teamid)
	
	log("on_team_apply_notify applyerID = "..applyerID..", applyerName = "..applyerName);
	
	local autoRefuse = TeamUpSystem.CheckApplyAutoRefuse(applyerID);

	if (autoRefuse == true) then
		log("on_team_apply_notify autoRefuse = true");
		return;
	end	
	
	local inviteApplyData = {};
	inviteApplyData.type = 1;
	inviteApplyData.playerId = applyerID;
	inviteApplyData.playerName = applyerName;
	inviteApplyData.ApplyerTeamID = teamid;	
	table.insert(TeamUpSystem.InviteApplyQueue, inviteApplyData);	
	TeamUpSystem.CheckNextInviteApply();
	--TeamUpSystem.ApplyerID = applyerID;
	--TeamUp_Applyer_Name = applyerName;
	
	--EventSystem:postEvent(EVENTTYPE_TEAMUP, EVNETID_TEAMUP_APPLY_JOIN);
end

--队伍信息改变通知
--[[
operate_type:
1  team other join in my team
2  team other quit
3  team change leader,param1代表成员数量
4  team join a team
5  team change type to param 1 2 4
6  team member status changed
7  team member online or offline    param  svr( not nil = online,  nil = offline)
8  change fill 
9  client version not match team 
10 voice notify
11 通知某队员的站队名变更, 其中param ={uid=uid, carteam_name=carteam_name}
13 team_info_notify(teamid, 13, param) param ={uid=uid, credit=credit};
]]
function TeamUpSystem.on_team_info_change_notify(teamid, operate_type, param, param1)
	log("[HHF]TeamUpSystem.on_team_info_change_notify, received team_info_notify, teamid = " .. tostring(teamid) .. ", operate_type = " .. tostring(operate_type) .. ", param = " .. tostring(param) .. ", param1 = " .. tostring(param1));
	
	--log_tree("param :", param);
	if(operate_type == 1) then
		TeamUpSystem.team_info_request();
	elseif(operate_type == 2) then
		if param ~= nil and TeamUpSystem.MyUserID == tonumber(param) then
			--您已被请出队伍
			TeamUpUI.ProtocolErrorCode("kickOut")
		end

		TeamUpSystem.team_info_request();
	elseif(operate_type == 3) then
		
		local myId = DataMgr.roleData.uid;
		--log("team change leader myID = " .. myId .. " , param = " .. param);
		log("on_team_info_change_notify param1",param1);
		local curPlayerCount = TeamUpSystem.TeamInfo.player_count;
		if param1 ~= nil then
			curPlayerCount = param1;
		end

		if ((tostring(myId)  == tostring(param)) and curPlayerCount > 1) then

			--如果在战斗过程中不提示
			local curStatus = string.lower(LuaClassObj.GetGameStatus(bp_lobby));
			if curStatus ~= "fighting" then
				DataMgr.ShowNoticeByID(110046); --被任命为队长
			end
		
		end
		if (tostring(myId)  ~= tostring(param)) then
			--log("TeamUpSystem.InviteApplyShowing = " .. tostring(TeamUpSystem.InviteApplyShowing));
			--log("TeamUpSystem.InviteApplyShowType = " .. tostring(TeamUpSystem.InviteApplyShowType));
			if (TeamUpSystem.InviteApplyShowing and TeamUpSystem.InviteApplyShowType == 1) then		
				TeamUpUI.CloseInviteApplyPanel();
				TeamUpSystem.CheckNextInviteApply();
			end
		end
		TeamUpSystem.TeamInfo.leader = param;
		--换队长，重新执行下聊天相关的逻辑
		TeamUpSystem.ProcessChat();
		
		if AllianceCompetitionRoomUI.isShowing == true then
			AllianceCompetitionRoomUI.UpdateAllPos()
		else
			EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_SYNC)
		end
		HallThemeUtils.ProcEnterTeam(TeamUpSystem.TeamInfo)
	elseif(operate_type == 4) then
		TeamUpSystem.team_info_request();
	elseif(operate_type == 5) then
		log("new teamtype = " .. param);
		--log_tree("new sub_mode_view_ids", param1);

		if TeamUpSystem.ModeInfoList then			
			TeamUpSystem.TeamInfo.game_type = 1;
			TeamUpSystem.TeamInfo.team_type = tonumber(param);
			
			-- 更新当前选中的模式的模式组选中状态
			TeamUpSystem.SaveTeamModelInfo(tonumber(param), param1)

			--EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TYPE_CHAGNE);
			EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_SYNC);
			--TeamUpUI.OnTeamTypeChange();
		else
			log("TeamUpSystem.ModeInfoList is not Init~~~~");
		end
	elseif (operate_type == 6) then
		local mermberInfo = TeamUpSystem.GetMemberInfo(param.uid);
		if mermberInfo == nil then
			log("[HHF]TeamUpSystem.on_team_info_change_notify, uid = " .. tostring(param.uid) .. " is not in team!");
		else
			mermberInfo.status = param.status;
			EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_SYNC);
		end
	elseif (operate_type == 7) then
		TeamUpSystem.ReLinkLine(param);
	elseif (operate_type == 8) then
		TeamUpSystem.TeamInfo.fill = param;
		LobbySystem.SetFillValue(param);
		EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_SYNC);
	elseif operate_type == 9 then
		--版本不一致，无法一起游戏
		TeamUpUI.NotSameVertionTips();
	elseif operate_type == 10 then --通知队员语音房间信息
		--voice_info = {uid=uid, voice={voice_uid=voice_uid, voice_open=voice_open}};				
		if param ~= nil then
			--log_tree("team_info_notify  voice_info", param);
			TeamUpSystem.UpdateVoiceInfo(param.uid, param.voice);			
		end
		--同步队友的语音信息
		EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_SYNC);
				
	elseif operate_type == 11 then --通知某队员的站队名变更, 其中param ={uid=uid, carteam_name=carteam_name}
		if param ~= nil then
			--log_tree("team_info_notify  carteam_name", param);
			TeamUpSystem.UpdateCarteamName(param.uid, param.carteam_name);
			--同步战队名字
			EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_SYNC);
		end
	elseif operate_type == 12 then
		--同步军团信息
		--log_tree("paramparamparamparam", param);
		TeamUpUI.SetCorpsNameIcon(param.uid, param.corps_name, param.corps_icon, param.cur_corps_alias_id, param.corps_position);
	elseif operate_type == 13 then
		--同步信誉
		TeamUpUI.SetCredit(param.uid, param.credit);
	elseif operate_type == 15 then
		--[[
			2、team_info_notify(teamid, 15, param) 同步某队员的枪械信息变更
			param={uid=uid, weapon_wear_info=weapon_wear_info}
			2、team_info_notify(teamid, 15, param) 同步某队员的枪械信息变更
			param={uid=uid, weapon_wear_info=weapon_wear_info}
			member.weapon_wear_info = {weapon_id=xxx, skin_id=xxx}。
		]]
		local mermberInfo = TeamUpSystem.GetMemberInfo(param.uid);
		if (mermberInfo ~= nil) then
			mermberInfo.weapon_wear_info = param.weapon_wear_info;
			TeamUpSystem.OnMemberWeaponChange(param.uid);
		end
	elseif operate_type == 17 then
		HallThemeUtils.ProcTeamInfoChange(param)
	elseif operate_type == 18 then
		HallThemeUtils.ProcTeamInfoChange(param)
	elseif operate_type == 16 then
		-- only for kickout without map
		TeamUpSystem.team_info_request();
	elseif operate_type == 100 then -- 同步点赞信息
		local mermberInfo = TeamUpSystem.GetMemberInfo(param1);
		if (mermberInfo ~= nil) then
			mermberInfo.upvote = param;
			EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_SYNC);
		end
	elseif operate_type == 101 then -- 同步段位信息

	elseif operate_type == 102 then
		local mermberInfo = TeamUpSystem.GetMemberInfo(param1);
		if (mermberInfo ~= nil) then
			mermberInfo.aliasid = param.id;
			mermberInfo.aliastitle = FuncUtil:Gen_title(param.id, param.rank);
			mermberInfo.aliasnation = param.nation;
		end
		EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_SYNC);
	elseif operate_type == 104 then
		log("HeadShowChangeParam is :");
		log_tree("param", param);
		for i, v in pairs(param) do
			TeamUpSystem.HeadShowChangeInfo.uid = i;
			TeamUpSystem.HeadShowChangeInfo.param = v;
		end
		log_tree("HeadShowChangeInfo", TeamUpSystem.HeadShowChangeInfo)
		
		EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_CHANGE_HEADSHOW);
	end


end

--队伍成员换武器
function TeamUpSystem.OnMemberWeaponChange(uid)
	log("OnMemberWeaponChange uid = " .. tostring(uid));
	local mermberInfo = TeamUpSystem.GetMemberInfo(uid);
	if (mermberInfo ~= nil and mermberInfo.weapon_wear_info ~= nil) then
		if (mermberInfo.weapon_wear_info.weapon_id == nil or mermberInfo.weapon_wear_info.weapon_id == 0 or mermberInfo.weapon_wear_info.weapon_id == "0") then
			LobbyUI:UnEquipWeapon(uid);
		else
			LobbyUI:EquipWeapon(uid, mermberInfo.weapon_wear_info.weapon_id, mermberInfo.weapon_wear_info.skin_id);
		end
	end
end

function TeamUpSystem.ResetModeToAvailableMap()
	log("[HHF]TeamUpSystem.ResetModeToAvailableMap, TeamUpSystem.mapModelID = " .. tostring(TeamUpSystem.mapModelID));

	if TeamUpSystem.IsTeamLeader() == false then
		--DataMgr.ShowNoticeByID(500045); --队员无法进行选择
		return;
	end

	if TeamUp_Is_Matching then
		--DataMgr.ShowNoticeByID(110014); --匹配中无法设置
		return;
	end

	local needSend = false;
	for k, v in pairs(TeamUpSystem.ModeInfoList) do
		if k == TeamUpSystem.mapModelID then
			--log_tree("[HHF]TeamUpSystem.ResetModeToAvailableMap, before modeInfoList = ", v, "[HHFTEST]");
			local haveMapAvailable = false;
			for kk, vv in pairs(TeamUpSystem.mapGroupID) do
				for kkk, vvv in pairs(v.mode_group) do
					if vv == vvv.group_id then
						local mapInfo = TeamUpMatchInfoUI.GetMapStateByModeID(kkk);
						if mapInfo.downloadstate == TeamUpMatchInfoUI.downloadState_have then
							haveMapAvailable = true;
							vvv.is_default = 1;
						else
							needSend = true;
							vvv.is_default = 0;
						end
						break;
					end
				end
			end

			if haveMapAvailable == true then				
				for kk, vv in pairs(v.mode_group) do
					local have = false;
					for kkk, vvv in pairs(TeamUpSystem.mapGroupID) do
						if vv.group_id == vvv then
							have = true;
							break;
						end
					end

					if have == false then
						vv.is_default = 0;
					end
				end
			end

			--log_tree("[HHF]TeamUpSystem.ResetModeToAvailableMap, after modeInfoList = ", v, "[HHFTEST]");
			break;
		end
	end

	log("[HHF]TeamUpSystem.ResetModeToAvailableMap, needSend = " .. tostring(needSend));

	if needSend then
		TeamUpSystem.team_change_type_request(TeamUpSystem.mapModelID);
	end
end

function TeamUpSystem.SaveTeamModelInfo(modelId, subViewIds)
	log("[HHF]TeamUpSystem.SaveTeamModelInfo, modelId = " .. tostring(modelId));
	--log_tree("[HHFTEST]TeamUpSystem.SaveTeamModelInfo, subViewIds = ", subViewIds, "[HHFTEST]");
	TeamUpSystem.mapModelID = modelId;
	TeamUpSystem.mapGroupID = subViewIds;
	-- 队员的看到的模式数据需要单独存储，不与自己的模式混合到一起
	local modelType = 0;
	for k,v in pairs(TeamUpSystem.ModeInfoList) do
		if k == modelId then
			modelType = v.model_type;
			break;
		end
	end
	for k,v in pairs(TeamUpSystem.ModeInfoList) do
		if v.model_type == modelType then
			-- 找到当前子模式
			--log_tree("v", v);
			for kk, vv in pairs(v.mode_group) do
				-- 遍历子模式组
				vv.is_default = 0;
				for kkk,vvv in pairs(subViewIds) do
					if vv.group_id == vvv then
						local levelLimit = (vv.need_level <= DataMgr.roleData.level);
						local ratingLimit = (vv.rating_limit <= TeamUpSystem.GetRatingByModelId(k));
						local pveLevelLimit = (vv.need_pve_level <= DataMgr.roleData.pve_level);
						log("levelLimit "..tostring(levelLimit).."ratingLimit "..tostring(ratingLimit))
						if levelLimit and ratingLimit and pveLevelLimit then
							vv.is_default = 1;
						end
						break;
					end
				end
			end
		end
	end
	
	TeamUpSystem.TeammateModeInfo = TeamUpSystem.CreateTeammateModelInfo(modelId, subViewIds);
	--log_tree("[HHFTEST]TeamUpSystem.SaveTeamModelInfo, TeamUpSystem.TeammateModeInfo = ", TeamUpSystem.TeammateModeInfo, "[HHFTEST]");
end

-- 创建一个队伍成员可见的地图数据
function TeamUpSystem.CreateTeammateModelInfo(modelId, subViewIds)
	local modelInfoList = {};
	modelInfoList.mode_group = {};
	

	for k,v in pairs(TeamUpSystem.ModeInfoList) do
		if k == modelId then
			modelInfoList.model_type = v.model_type;
			modelInfoList.is_optional = v.is_optional;
			for kk,vv in pairs(v.mode_group) do
				local mapInfo = {
					need_level = vv.need_level,
					is_default = vv.is_default,
					rating_limit = vv.rating_limit,
					group_id = vv.group_id,
				};
				modelInfoList.mode_group[kk] = mapInfo;
			end
			break;
		end
	end

	for k,v in pairs(modelInfoList.mode_group) do
		v.is_default = 0;
		for kk,vv in pairs(subViewIds) do
			if v.group_id == vv then
				-- 永远可见
				v.is_default = 1;
				v.rating_limit = 0;
				v.need_level = 1;
			end
		end
	end
	--log_tree("CreateTeammateModelInfoList modelInfoList", modelInfoList);
	return modelInfoList;
end

--主要用于聊天招募,加入失败的处理，并不是一一对应的协议
function TeamUpSystem.on_team_join_rsp(res, teamid, teamInfo, verCompareResult)
	-- "team-is-full" 队伍满了
	--"target-not-online"队伍已解散
	log("[HHF]TeamUpSystem.on_team_join_rsp, received team_join_respond, res = " .. tostring(res) .. ", teamid = " .. tostring(teamid) .. ", teamInfo = " .. tostring(teamInfo));
	if res == "ok" then				
		DataMgr.ShowNoticeByID(110042);
	elseif res == "team_is_full" then	
		DataMgr.ShowNoticeByID(110007);
		
	elseif res == "target_not_online" then		
		DataMgr.ShowNoticeByID(110009);
	elseif res == "already_in_team"  then
		--你已经在队伍中		
		DataMgr.ShowNoticeByID(110045);		
	elseif res == "already_has_team"  then		
		--您已在组队中，不可加入其他队伍。	
		DataMgr.ShowNoticeByID(110044);
	elseif res == "team-in-match" then
		DataMgr.ShowNoticeByID(110059);	--对方在匹配中
	elseif res == "team_not_exist" then
		DataMgr.ShowNoticeByID(6432);	--队伍已解散
	elseif res == "not_same_version" then
		--[110149]={TextId=110149, TextValue="因您未更新到新版本，邀请组队失败。建议您更新游戏。"},
		--[110150]={TextId=110150, TextValue="对方未更新到最新版本，无法组队。 "},
		TeamUpUI.HandelVertionCompareTips(verCompareResult);
	elseif (res == "inviter_in_match") then 
		DataMgr.ShowNoticeByID(110059);----%s在匹配中			
	elseif (res == "inviter_in_game") then 
		DataMgr.ShowNoticeByID(9911106);----游戏中	
	elseif res == "team_not_found" then
		DataMgr.ShowNoticeByID(4361);
	elseif res == "already_in_match" then
		DataMgr.ShowNoticeByID(4360);
	elseif res == "already_in_game" then
		DataMgr.ShowNoticeByID(4400);
	else
		--team_join_respond("inviter_in_room", nil, nil)    ---邀请者在房间中，不能组队。
		--team_join_respond("already_in_room", nil, nil)    ---您在房间中，不能组队。
		TeamUpUI.ProtocolErrorCode(res);
	end
	Client.ClearAdjustDeepLink();
end

local  function UpdateTeamInfoWear(memberUid, isPushOn, wearInfo, mAvatarPos)
	local memberInfo  =  TeamUpSystem.GetMemberInfo(tonumber(memberUid));
	if memberInfo == nil then
		return;
	end

	if memberInfo.wear_ext == nil then
		log("UpdateTeamInfoWear  memberInfo.wear_ext == nil");
		return;
	end

	local hasWear = memberInfo.wear_ext[mAvatarPos];
	if hasWear == nil then
		if isPushOn == 1 then
			TeamUpSystem.TeamInfo.members[tonumber(memberUid)].wear_ext[mAvatarPos] = wearInfo;
			--memberInfo.ware[mAvatarPos] = mResId;
		end		
	elseif hasWear ~= nil then
		if isPushOn == 1 then --表示穿
			TeamUpSystem.TeamInfo.members[tonumber(memberUid)].wear_ext[mAvatarPos] = wearInfo;
			--memberInfo.ware[mAvatarPos] = mResId;
		else --0表示脱		
			for k,v in pairs(memberInfo.wear_ext) do
				if k == mAvatarPos then
					TeamUpSystem.TeamInfo.members[tonumber(memberUid)].wear_ext[k] = nil;
					-- table.remove(TeamUpSystem.TeamInfo.members[tonumber(memberUid)].ware,k);
					 --table.remove(memberInfo.ware,k)
				end
			end
		end
	end
end

--wearInfo:{[1]=item_id,[2]=color,[3]=pattern}
function TeamUpSystem.on_team_change_wear(memberUid, isPushOn, mResId, mAvatarPos, wearInfo)
	TeamUpSystem.ChangeWearInfo = {
		uid = memberUid,
		pos = isPushOn, --0 是脱，1是穿
		resId = mResId, 
		--新增人的avatar位置
		avatarPos = mAvatarPos,
		wearInfo = wearInfo or {},
	};
	--同步下数据，用于断线重连
	UpdateTeamInfoWear(memberUid, isPushOn, wearInfo, mAvatarPos);
	--log_tree("TeamUpSystem.on_team_change_wear", TeamUpSystem.TeamInfo);
	
	EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_CHANGE_WEAR);	
end

function TeamUpSystem.UpdateTeamMemberWear(uid, wear_ext, wear_ext_res)
	local memberInfo  =  TeamUpSystem.GetMemberInfo(tonumber(uid));
	log_tree("memberInfo", memberInfo);
	if memberInfo == nil then
		return;
	end

	if memberInfo.wear_ext == nil then
		log("UpdateTeamMemberWear  memberInfo.wear_ext == nil");
	else
		memberInfo.wear_ext = wear_ext_res;
	end

	if memberInfo.ware == nil then
		log("UpdateTeamMemberWear  memberInfo.ware == nil");
	else
		memberInfo.ware = wear_ext;
	end
end



--返回陌生人状态信息,用于聊天菜单弹出
function TeamUpSystem.on_stranger_staus_rsp(cb, res, infos)
	--[[
	// res 字符串返回码. "ok": 正常; "timeout": 超时,此时仅有部分数据拉取成功
	//此时仅有部分数据拉取成功; "invalid_param": 表示参数非法; "busy": 表示当前系统繁忙
	// infos = 	  {[uid1] = 
	{
		teamState=teamState,						// 0 空闲 1 组队中 2 游戏中
		teamId=teamId, 								// 队伍ID
		currentTeamAmount=currentTeamAmount,		// 队伍当前人数
		maxTeamAmount=maxTeamAmount, 				// 队伍最大人数
		timeSinceGameBegin=timeSinceGameBegin, 		// 游戏开局了多久(单位秒)
		online=online  								// 0 不在线  1 在线
	} --]]
	if cb ~= "strengthStatu" then
		log("no strengthStatu");
		return;
	end
	
	
		
	local curUID = 0;
	TeamUpSystem.PlayerStatu = {};	
	if res =="ok" then
		if infos ~= nil then
			for k,v in pairs(infos) do
				--始终取第一个
				curUID = k;
				TeamUpSystem.PlayerStatu.teamState = v.teamState;
				TeamUpSystem.PlayerStatu.teamId = v.teamId;
				TeamUpSystem.PlayerStatu.currentTeamAmount = v.currentTeamAmount;
				TeamUpSystem.PlayerStatu.maxTeamAmount = v.maxTeamAmount;
				TeamUpSystem.PlayerStatu.timeSinceGameBegin = v.timeSinceGameBegin;
				TeamUpSystem.PlayerStatu.online = v.online;
				break; 
			end			
		end		
		--log_tree("TeamUpSystem.PlayerStatu ",TeamUpSystem.PlayerStatu);
		--TeamUpSystem.PlayerStatu = infos;	
		if curUID > 0 then
			local myInfo = TeamUpSystem.GetMemberInfo(curUID);
			if myInfo == nil then
				TeamUpSystem.UpdateMenuForChat();
			end		
		end
		
	elseif res == "timeout" then
		--超时
	elseif res == "invalid_param" then
		--参数非法
	elseif res == "busy" then
		--系统繁忙
	end

end

--如果只是换头发则不需要重新删除角色
local function NeedReCreatPalyer(op_uid,newAvatar)
	local result = false;
	local _info = TeamUpSystem.GetMemberInfo(op_uid);
	if _info ~= nil then
		--判断性别
		if _info.avatar.gamegender ~= newAvatar.gamegender then
			return true;
		end		
		--判断头ID
		if _info.avatar.headid ~= newAvatar.headid then
			return true;
		end
	end
	
	return result;
end


--更新队友模型，
local function UpdateMemberModle(newTeamInfo)
	--单人不需要替换模型
	if newTeamInfo.player_count == 1 then
		return;
	end

	local  needUpdate = false;
	for k,v in pairs(newTeamInfo.members) do
		local _newGid = k;
		if k ~= TeamUpSystem.MyUserID then
			local info =TeamUpSystem.GetMemberInfo(tonumber(k));
			--判断性别不一样或者判断头ID不一样都要重新删除模型，然后再加载模型
			local notSameSex = false;
			local notSameHeadid = false;
			if info ~= nil then
				notSameSex = NeedReCreatPalyer(_newGid,info.avatar)
				notSameHeadid = NeedReCreatPalyer(_newGid,info.avatar)
			end

			if info == nil or notSameSex == true or notSameHeadid == true  then
				needUpdate = true;
				break;
			end
		end
	end

	if needUpdate == true then
		--删除旧的模型
		local oldTeamInfo = TeamUpSystem.TeamInfo;	
		for k1,v1 in pairs(oldTeamInfo.members) do
			local _oldGid = k1;
			if k1 ~= TeamUpSystem.MyUserID then

				local _sex = 1;
				if v1.gender  ~= nil then
					_sex = v1.gender;
				end	

				local wareArray = {};
				if v1.wear_ext ~= nil then
					for wk,wv in pairs(v1.wear_ext) do
						table.insert(wareArray, LobbyUI.MakeClientAvatarWearInfo(wv));
					end
				else
					log("UpdateMemberModle v1.wear_ext = nil");
				end

				local playerData ={
					gid = _oldGid,
					sex = _sex,		
					BP_ARRAY_AvatarList = wareArray,
	                avatar = v1.avatar,
					bagSkinInsId = v1.skin_info.bag_skin,
					headShow = v1.skin_info.head_show,
				};
				--log_tree("UpdateMemberModle del", playerData);	
				LobbyUI:SpawnPlayer(playerData, false);
			end
		end

		--重新加载新的模型
		for k2,v2 in pairs(newTeamInfo.members) do
			local _newGid1 = k2;
			if k2 ~= TeamUpSystem.MyUserID then

				local _sex = 1;
				if v2.gender  ~= nil then
					_sex = v2.gender;
				end	

				local wareArray = {};
				if v2.wear_ext ~= nil then
					for wk1,wv1 in pairs(v2.wear_ext) do
						table.insert(wareArray, LobbyUI.MakeClientAvatarWearInfo(wv1));
					end
				else
					log("UpdateMemberModle v2.wear_ext = nil");
				end

				local head_show = 0;
				if v2.skin_info ~= nil then
					if(v2.skin_info.head_show == 0 or v2.skin_info.head_show == v2.skin_info.helmet_skin) then
						local head = v2.wear[1];
						if(head ~= nil) then
							log_tree("head", head);
							for i, v in pairs(wareArray) do
								if(v.resID == head[1]) then
									v.resID = 0;
								end
							end
						end
						head_show = DataMgr.GetEquipmentItemIDByResID(v2.skin_info.helmet_level, v2.skin_info.head_show);
					end
				end

				local playerData ={
					gid = _newGid1,
					sex = _sex,		
					BP_ARRAY_AvatarList = wareArray,
	                avatar = v2.avatar,
					bagSkinInsId = DataMgr.GetEquipmentItemIDByResID(v2.skin_info.bag_level ,v2.skin_info.bag_skin),
					headShow = head_show,
				};
				log_tree("UpdateMemberModle", playerData);	
				LobbyUI:SpawnPlayer(playerData, true);
			end
		end


	end
	
end

-- 用于处理大厅匹配逻辑
function TeamUpSystem.CompareMemBer(newTeamInfo)
	if newTeamInfo == nil then
		log("TeamUpSystem.CompareMemBer newTeamInfo none");
		return;
	end
	--log_tree("TeamUpSystem.CompareMemBer parmNewTeamInfo" , newTeamInfo);
	local oldTeamInfo = TeamUpSystem.TeamInfo;	
	--log_tree("TeamUpSystem.CompareMemBer oldTeamInfo" , oldTeamInfo);
	if oldTeamInfo.player_count == nil then		
		--登录只设一次
		log("TeamUpSystem.CompareMemBer MyUserID" ..tostring(TeamUpSystem.MyUserID));
		TeamUpSystem.IsAddMember = true;				
		for k,v in pairs(newTeamInfo.members) do
			if v.wear_ext == nil then
				log("TeamUpSystem.CompareMemBer v.wear_ext = nil 1");
			end
			local _newGid = k;
			if k ~= TeamUpSystem.MyUserID then
				local _newStructData ={
				gid = _newGid,
				name = v.name,
				status = v.status,
				svr = v.svr, 
				wear = v.wear_ext or {},
				gender = v.gender,
                avatar = v.avatar,
				skin_info = v.skin_info or {},
				};
				table.insert(TeamUpSystem.ChangeMemberInfo, _newStructData);
			end
		end
		--log_tree(" TeamUpUI.CompareMemBer initData", TeamUpSystem.ChangeMemberInfo);		
		return;
	end	

	TeamUpSystem.ChangeMemberInfo = {};		

	--计算增量
	if newTeamInfo.player_count == oldTeamInfo.player_count then		
		TeamUpSystem.IsAddMember = false;	
		--更新模型
		UpdateMemberModle(newTeamInfo);
		--处理断线重连后换装的逻辑
		TeamUpSystem.UpdateTeamMemberAvatar(newTeamInfo);
		return;
	end 	

	
	--[[
	    │  └─ 382236358
		│    ├─ name: "吃鹅ebrcx"
		│    └─ svr: 17039369	
	--]]	
	--log_tree("TeamUpSystem.CompareMemBer newTeamInfo" , newTeamInfo);	
	
	if newTeamInfo.player_count > oldTeamInfo.player_count then
		
		--增加角色
		TeamUpSystem.IsAddMember = true;
		for k,v in pairs(newTeamInfo.members) do
			if v.wear_ext == nil then
				log("TeamUpSystem.CompareMemBer v.wear_ext = nil 2");
			end
			local _newGid = k;
			local _isFind = false;
			for i,iv in pairs(oldTeamInfo.members) do
				local _oldGid = i;			
				if _newGid == _oldGid then
					_isFind =true;
					break;
				end		
			end		
			if _isFind == false then
				local _newStructData ={
					gid = _newGid,
					name = v.name,
					status = v.status,
					svr = v.svr,
					wear = v.wear_ext or {},
					gender = v.gender,
                    avatar = v.avatar,
					skin_info = v.skin_info or {},
				};
				table.insert(TeamUpSystem.ChangeMemberInfo, _newStructData);
			end	
		end		
		
	elseif newTeamInfo.player_count < oldTeamInfo.player_count then		
		--删除角色
		TeamUpSystem.IsAddMember = false;	
		for k,v in pairs(oldTeamInfo.members) do
			if v.wear_ext == nil then
				log("TeamUpSystem.CompareMemBer v.wear_ext = nil 2");
			end
			local _newGid = k;
			local _isFind = false;
			for i,iv in pairs(newTeamInfo.members) do
				local _oldGid = i;			
				if _newGid == _oldGid then
					_isFind =true;
					break;
				end				
			end			
			
			if _isFind == false then
				local _newStructData ={
					gid = _newGid,
					name = v.name,
					status = v.status,
					svr = v.svr,
					wear = v.wear_ext or {},
					gender = v.gender,
                    avatar = v.avatar,
					skin_info = v.skin_info or {},
				};
				table.insert(TeamUpSystem.ChangeMemberInfo, _newStructData);
			end	
		
		end
			
	end	
	
	--log_tree(" TeamUpUI.CompareMemBer memberInfo", TeamUpSystem.ChangeMemberInfo);	
		--处理断线重连后换装的逻辑
	TeamUpSystem.UpdateTeamMemberAvatar(newTeamInfo);
	
end 

--同步avatar信息
local function HasPosInNewWare(ware, position)
	log("HasPosInNewWare"..position);
	--log_tree("HasPosInNewWare",ware);
	if ware ~= nil then
		for k,v in pairs(ware) do
			if k == position then
				return v;
			end		
		end
	end

	return nil;
	
end 

function TeamUpSystem.UpdateTeamMemberAvatar(newTeamInfo)
	local oldTeamInfo = TeamUpSystem.TeamInfo;	
	--log_tree("oldTeamInfo",oldTeamInfo);
	--log_tree("newTeamInfo",newTeamInfo);
	for k,v in pairs(newTeamInfo.members) do
		if v.wear_ext == nil then
			log("TeamUpSystem.CompareMemBer v.wear_ext = nil 2");
		end
		local _newGid = k;
		local _newWare = v.wear_ext or {};
		--log_tree("member:", v);
		--log_tree("v.wear_ext", v.wear_ext);
		local oldMemberInfo = TeamUpSystem.GetMemberInfo(_newGid);
		--log("oldMemberInfo",oldMemberInfo);
		--先脱后穿
		if oldMemberInfo ~= nil then
			local _oldWare = oldMemberInfo.wear_ext or {};
			--log_tree("_oldWare",_oldWare);
			for k1,v1 in pairs(_oldWare) do
				local wearInfo = HasPosInNewWare(_newWare,k1);
				--老的avatar在新的模型上取不到，说明被脱了
				if wearInfo == nil then
					local avatar_data = {};
					avatar_data.gid = _newGid;
					avatar_data.resId = v1[1];
					--脱掉
					--log("tttttttttd:"..v1);
					LobbyUI:AvatarChange(LobbyUI:CreateAvatarChangeData(_newGid, v1[1]), false);
				end
			end
		end	

		--穿上新的avatar;
		local head_show = v.skin_info.head_show;
		local bag_skin = v.skin_info.bag_skin;
		local helmet_skin = v.skin_info.helmet_skin;
		local bag_level = v.skin_info.bag_level;
		local helmet_level = v.skin_info.helmet_level;
		if(head_show == helmet_skin or head_show == 0) then
			table.remove(_newWare, 1);
			head_show = DataMgr.GetEquipmentItemIDByResID(helmet_level, head_show);
		else
			head_show = 0;
		end
		bag_skin = DataMgr.GetEquipmentItemIDByResID(bag_level, bag_skin);
		-- log_tree("_newWare", _newWare);
		for k2,v2 in pairs(_newWare) do
			-- local newAvatar_data = {};
			-- newAvatar_data.gid = _newGid;
			-- newAvatar_data.resId = v2[1];
			-- newAvatar_data.color
			--log("cccccccccccd::"..v2);
			LobbyUI:AvatarChange(LobbyUI:CreateAvatarChangeData(_newGid, v2[1], v2[2], v2[3]), true);
		end
		log("=====================bag_skin" .. tostring(bag_skin));
		log("=====================bag_skin" .. tostring(head_show));
		LobbyUI:AvatarChange(LobbyUI:CreateAvatarChangeData(_newGid, bag_skin), true);
		LobbyUI:AvatarChange(LobbyUI:CreateAvatarChangeData(_newGid, head_show), true);
	end
end

function TeamUpSystem.UpdateMemberHeadShowInfo(HeadShowChangeInfo)
	local uid = HeadShowChangeInfo.uid;
	local param = HeadShowChangeInfo.param;
	if(param.head_show ~= nil) then
		TeamUpSystem.TeamInfo.members[tonumber(uid)].skin_info.head_show = param.head_show;
	end

	if(param.bag_skin ~= nil) then
		TeamUpSystem.TeamInfo.members[tonumber(uid)].skin_info.bag_skin = param.bag_skin;
	end

	if(param.helmet_skin ~= nil) then
		TeamUpSystem.TeamInfo.members[tonumber(uid)].skin_info.helmet_skin = param.helmet_skin;
	end

	if(param.bag_level ~= nil) then
		TeamUpSystem.TeamInfo.members[tonumber(uid)].skin_info.bag_level = param.bag_level;
	end

	if(param.helmet_level ~= nil) then
		TeamUpSystem.TeamInfo.members[tonumber(uid)].skin_info.helmet_level = param.helmet_level;
	end
end


function TeamUpSystem.ReLinkLine(tParam)
	
	if tParam == nil then 
		log("TeamUpSystem.ReLinkLine tParam none");
		TeamUpSystem.team_info_request();
		return;
	end	
	
	--log_tree("TeamUpSystem.ReLinkLine :", tParam);
	local pUid = tParam.uid;
	local _info = TeamUpSystem.GetMemberInfo(pUid);
	local isOnlineLastTime = false;
	if _info == nil then
		log("TeamUpSystem.ReLinkLine _info none uid:"..tostring(pUid));		
		return;	
	end

	if _info ~= nil then
		isOnlineLastTime = (_info.svr ~= nil);
	end	
	
	local isOnlineNow = (tParam.svr ~= nil);
	if isOnlineLastTime == false and isOnlineNow == true then
		log("TeamUpSystemReLinkLine perOnline"..pUid);
		local stringName = TeamUpSystem.GetMemberName(pUid);
		local tipString =DataMgr.GetMsgByID(110020);
		local finalString = string.format(tostring(tipString),tostring(stringName));	

		--如果在战斗过程中不提示
		local curStatus = string.lower(LuaClassObj.GetGameStatus(bp_lobby));
		if curStatus ~= "fighting" then
			DataMgr.ShowNoticeByString(finalString);
		end

		
		--CommonMessageBoxUI:ShowPanel(1, "提示", finalString, nil, nil);		
		---xxx已上线啦
	elseif isOnlineLastTime == true and isOnlineNow == false then
		log("TeamUpSystemReLinkLine perOffline"..pUid);
		local stringName = TeamUpSystem.GetMemberName(pUid);
		local tipString =DataMgr.GetMsgByID(110021);
		local finalString = string.format(tostring(tipString),tostring(stringName));	
		--DataMgr.ShowNoticeByString(finalString);		
		--CommonMessageBoxUI:ShowPanel(1, "提示", finalString, nil, nil);
		-----xxx下线啦
	end
	--game_start不为空则游戏中，nil为非游戏中
	_info.svr = tParam.svr;
	_info.game_start = 0;
	if tParam.game_start ~= nil then
		_info.game_start = tParam.game_start;
	end
	EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_SYNC);		

end

function TeamUpSystem.ProcessChat()	
	--log_tree("ProcessChat ",TeamUpSystem.TeamInfo)
	if TeamUpSystem.TeamInfo.player_count ~= nil then
		if TeamUpSystem.TeamInfo.player_count > 1 then
			if TeamUpSystem.TeamInfo.leader ~= nil then
				local leaderUid = TeamUpSystem.TeamInfo.leader;
				log("chatddddd:"..leaderUid);
				leaderUid = math.floor(leaderUid);
				log("chatmath.floorddddd:"..leaderUid);
				GlobalChatVoice.JoinLobbyVoiceRoom(tostring(leaderUid));				
			end
		else
			 GlobalChatVoice.QuitLobbyVoiceRoom();
		end
	end

end

--初始化模拟器类型
function TeamUpSystem.InitTeamEmulatorType()
	if TeamUpSystem.CurTeamEmulatorType < 0 then
		log("TeamUpSystem.InitTeamEmulatorType");
		TeamUpSystem.CurTeamEmulatorType = 0;
		local mySelfEmulator = DataMgr.IsEmulator() or DataMgr.IsBLE();
		if mySelfEmulator == true then
			TeamUpSystem.CurTeamEmulatorType  = 1;
			if DataMgr.IsEmulator() then
				local emulatorName = EmulatorSystem.GetEmulatorName();
				-- log("TeamUpSystem.InitTeamEmulatorType"..tostring(emulatorName));
				local isTecent = EmulatorSystem.is_tencent_simulator(emulatorName);
				--log("TeamUpSystem.InitTeamEmulatorType isTecent"..tostring(isTecent));
				if isTecent == false then
					TeamUpSystem.CurTeamEmulatorType = 2;
				end
			end
		end
		--TeamUpSystem.SetTeamEmulatorType();
	end
end

function TeamUpSystem.ProcessMemberOnline(deviceType, finalString)
	local needShow = TeamUpSystem.NeedShowEmulatorTips();
	TeamUpSystem.SetTeamEmulatorType();
	if needShow == true then
		--上线提示和模拟器合并
		local str  = DataMgr.GetMsgByID(110138);
		local msg = finalString.." "..tostring(str);
		-- log("ProcessMemberOnline"..tostring(TeamUpSystem.CurTeamEmulatorType));
		if TeamUpSystem.CurTeamEmulatorType == 2 then
			DataMgr.ShowMessageBoxByID(110424);
		else
			--log("ProcessMemberOnline"..tostring(msg));
			--DataMgr.ShowNoticeByString(msg);
			DataMgr.ShowMessageBoxByStr(msg);
		end

	else
		if finalString ~= "" then
			DataMgr.ShowNoticeByString(finalString);
		end
	end

end

function TeamUpSystem.NeedShowEmulatorTips()
	local result = false;
	--自己是模拟器永远不提示 2018-6-9新增如果是外设也不提示
	local mySelfEmulator = DataMgr.IsEmulator() or DataMgr.IsBLE();
	if mySelfEmulator == true then
		--return result;
	end

	local lastEmulatorType = TeamUpSystem.CurTeamEmulatorType;
	--log("TeamUpSystem.NeedShowEmulatorTips lastEmulatorType"..TeamUpSystem.CurTeamEmulatorType);
	local curEmulatorType = 0; --0表示手机，1表示模拟器，（腾讯模拟器）2表示非腾讯模拟器
	local playCount = 1;
	if TeamUpSystem.TeamInfo ~= nil then
		if TeamUpSystem.TeamInfo.player_count ~= nil then
			playCount = TeamUpSystem.TeamInfo.player_count;
		end
	end
	--如果在战斗过程中不提示,并且要组队成员大于1
	local curStatus = string.lower(LuaClassObj.GetGameStatus(bp_lobby));
	if curStatus ~= "fighting" and playCount > 1  then
		if TeamUpSystem.TeamInfo ~= nil then
			--log_tree("TeamUpSystem.NeedShowEmulatorTips member:",TeamUpSystem.TeamInfo.members);
			for key, value in pairs (TeamUpSystem.TeamInfo.members) do
				if value.device_type ~= nil and value.device_type ~= 0 then
					curEmulatorType = 1;
					local isEmum = EmulatorSystem.IsEmulator(value.emulator_name);
					if isEmum and value.emulator_name ~= nil then
						local isTecent =  EmulatorSystem.is_tencent_simulator(tostring(value.emulator_name));
						if isTecent == false then
							curEmulatorType = 2;
							break;
						end
					end

				end
			end
		end
	end
	log("TeamUpSystem.NeedShowEmulatorTips curEmulatorType : ".. curEmulatorType .. "|| lastEmulatorType : " .. lastEmulatorType);
	if lastEmulatorType ~= curEmulatorType and curEmulatorType > lastEmulatorType then
		result = true;
	end
	return result;
end

--设置模拟器类型
function TeamUpSystem.SetTeamEmulatorType()
	TeamUpSystem.CurTeamEmulatorType = 0;
	if TeamUpSystem.TeamInfo ~= nil then
		for key, value in pairs (TeamUpSystem.TeamInfo.members) do
			if value.device_type ~= nil and value.device_type ~= 0 then
				TeamUpSystem.CurTeamEmulatorType = 1;
				log("TeamUpSystem.TeamInfo.CurTeamEmulatorType"..tostring(TeamUpSystem.CurTeamEmulatorType));
				--1是PC模拟器，2是外设键鼠 3是外设手柄
				local isEmum = EmulatorSystem.IsEmulator(value.emulator_name);
				if isEmum and value.emulator_name ~= nil then
					-- log("SetTeamEmulatorType"..tostring(value.emulator_name));
					local isTecent = EmulatorSystem.is_tencent_simulator(tostring(value.emulator_name));
					--log("SetTeamEmulatorType isTecent"..tostring(isTecent));
					if isTecent == false then
						TeamUpSystem.CurTeamEmulatorType = 2;
						break;
					end
				end

			end
		end
	end
end

--断线重连
function TeamUpSystem.ReconnectFetchTeamUpInfo()
	--清空模型相关
	TeamUpSystem.ChangeMemberInfo = {};
	--请求自己队伍信息 和同步下组队限时开放	
	TeamUpSystem.team_info_request();		
	TeamUpSystem.on_mode_shield_req();

	--同步下好友状态
	FriendSystem.batchGetTeamInfoList();
end

--是否模拟器队伍
function TeamUpSystem.IsEmulatorTeam()
	--[[
        1、team_info_sync中增加了device_type(0或nil：手机，1模拟器)
        team_info_sync(teamid, team) 新增了team.member[uid].device_type
        2、team_info_notify（teamid, 7, param）通知某队员的站队名变更, 其中param ={uid=uid, svr=svr, game_start=member.game_start, device_type=device_type}
        3、入队通知
        team_info_notify（team_id, 1, member）member中新增device_type
    ]]
	local result = false;
	if TeamUpSystem.TeamInfo ~= nil then
		for key, value in pairs (TeamUpSystem.TeamInfo.members) do
			if value.device_type ~= nil and value.device_type ~= 0 then
				result = true;
				break;
			end
		end
	end
	return result;
end

--是否混合模拟器队伍，
function TeamUpSystem.IsMixEmulatorTeam()
	local result = false;
	local isEmulator = TeamUpSystem.IsEmulatorTeam();
	if isEmulator == true then
		if TeamUpSystem.TeamInfo ~= nil then
			for key, value in pairs (TeamUpSystem.TeamInfo.members) do
				if value.device_type ~= nil and value.device_type == 0 then
					result = true;
					break;
				end
			end
		end
	end
	return result;
end

function TeamUpSystem.ProcessEmulatorTips()
	local needShow = TeamUpSystem.NeedShowEmulatorTips();
	TeamUpSystem.SetTeamEmulatorType();
	if needShow == true then
		if TeamUpSystem.CurTeamEmulatorType == 2 then
			DataMgr.ShowMessageBoxByID(110424);
		else
			--您的队伍中有模拟器玩家，只能匹配到其他模拟器队伍。
			--DataMgr.ShowNoticeByID(110138); --需求改成确定提示框
			DataMgr.ShowMessageBoxByID(110138)
		end
	else
		log("ProcessEmulatorTips"..tostring(TeamUpSystem.IsFightingBackLobby));
		--判断如果从战斗回到大厅，如果队伍是模拟器队伍，则所有人都弹窗提示
		if TeamUpSystem.IsFightingBackLobby == true then
			--您的队伍中有模拟器玩家，只能匹配到其他模拟器队伍。
			if TeamUpSystem.IsMultiTeam() and TeamUpSystem.IsMixEmulatorTeam() then
				if TeamUpSystem.CurTeamEmulatorType == 2 then
					DataMgr.ShowMessageBoxByID(110424);
				else
					--您的队伍中有模拟器玩家，只能匹配到其他模拟器队伍。
					DataMgr.ShowMessageBoxByID(110138);
				end
			end
			--TeamUpSystem.IsFightingBackLobby = false;
		end
	end
	TeamUpSystem.IsFightingBackLobby = false;

end

---------------------------------组队限时开放逻辑------------------
function TeamUpSystem.GetShieldByType(modelType)
	--log_tree("GetShieldByType",TeamUpSystem.ModeShields);
	if TeamUpSystem.ModeShields ~= nil then
		return TeamUpSystem.ModeShields[modelType];
	end
	
	return nil;
end

function TeamUpSystem.on_mode_shield_req()
	--登录断线重连的时候会请求一次，点击切换模式会请求一次,选择模式失败也请求一次
	--log("[HHF]TeamUpSystem.on_mode_shield_req, " .. debug.traceback());
	log("[HHF]TeamUpSystem.on_mode_shield_req, Send get_mode_shield_req");
    --获得模式屏蔽表数据
	NetUtil.SendPkg("get_mode_shield_req");
end

function TeamUpSystem.on_mode_shield_rsp(mode_shields, mode_switch_table, mode_info_table, mode_view_limit)
	log("[HHF]TeamUpSystem.on_mode_shield_rsp, received get_mode_shield_rsp.");
	--[[
	mode_shields:	
	   ├─ 101
	   │  ├─ open_end: 0
	   │  ├─ is_shield: true
	   │  └─ open_begin: 0
		  
	on_mode_shield_rsp mode_switch_table
  	   ├─ 202: 1
  	   ├─ 203: 1
  	   └─ 301: 1
	   
	mode_info_table
	   └─ 401
	       ├─ default_mode_group
	       │  └─ 1: 7
	       ├─ mode_group
	       │  ├─ 46
	       │  │  ├─ need_level: 15
	       │  │  └─ rating_limit: 0
	       │  └─ 49
	       │     ├─ need_level: 15
	       │     └─ rating_limit: 0
	       └─ is_optional: true
		
	mode_view_limit
		└─ 10
		    └─ 1
		       ├─ open_type: 0
		       ├─ preview_content: "18:00-23:00开放"
		       ├─ preview_hours: 5
		       ├─ start_time: "2018-05-14 18:00:00"
		       └─ end_time: "2018-06-14 23:00:00"
	--]]
	
	--log_tree("on_mode_shield_rsp mode_shields", mode_shields);
	--log_tree("on_mode_shield_rsp mode_switch_table", mode_switch_table);	
	--log_tree("on_mode_shield_rsp mode_info_table", mode_info_table);
	--log_tree("on_mode_shield_rsp mode_view_limit", mode_view_limit);
	
	if mode_switch_table ~= nil then
		TeamUpSystem.ModeSwitchTable = mode_switch_table;
	else
		TeamUpSystem.ModeSwitchTable = {};
	end
	
	if mode_shields ~= nil and mode_info_table ~= nil then
		TeamUpSystem.ModeShields = mode_shields;
		TeamUpSystem.ModeViewLimit = mode_view_limit;
		TeamUpSystem.ModeInfoList = TeamUpSystem.CreateModelInfoList(mode_info_table);
		
		-- 更新当前可玩的游戏模式
		TeamUpModelUI.InitModel(TeamUpSystem.ModeSwitchTable, TeamUpSystem.ModeShields, TeamUpSystem.ModeViewLimit);
	else
		--CommonMessageBoxUI:ShowPanel(1, "提示", "组队模式状态异常");
		DataMgr.ShowMessageBoxByID(500038);
	end
	
	if mode_shields ~= nil then
		TeamUpSystem.ModeShields = mode_shields;
		--test
		--TeamUpSystem.testShieldData( );
		--更新组队模式菜单
		TeamUpUI.SetShieldLock();		
	end
	--更新一下数据
	TeamUpMatchInfoUI.InitMapInfo();
	RecruitUI.InitSelectData();
	RecruitUI.refreshUI();
	TeamUpMatchInfoUI.ResetMapList(true, true);
	-- 主动请求一次当前组队信息
	--63675347优化注释
	TeamUpSystem.team_info_request();
end


-- 获取剩余秒数
-- serverTime 是服务器时间，时区是UTC时区
-- localTime 是本地时间戳，时区是本地时区
function TeamUpSystem.GetLeftSecond(serverTime, localTime)
	local sd = os.date("*t", serverTime);
	local ld = os.date("!*t", localTime);
	sd.isdst = false;
	ld.isdst = false;

	return os.difftime(os.time(sd), os.time(ld));
end

-- 将服务器时间（UTC）转换成本地时间
-- serverTime 是服务器时间，时区是UTC时区
function TeamUpSystem.ConvertToLocalTimestamp(serverTime)
	local ld = os.date("!*t", serverTime);
	ld.isdst = false;
	return os.time(ld);
end

-- 获取剩余时间字符串
-- leftSeconds >= 24小时：（距离开放还有：X天X小时）
-- leftSeconds < 24小时：（距离开放还有：X小时X分）
function TeamUpSystem.GetLeftTimeStr(leftSeconds)
	if leftSeconds > 24 * 3600 then
		local hours = math.floor(leftSeconds/3600);
		local leftTimeStr = string.format(FuncUtil.GetLocalizeResStr("301152"), math.floor(hours/24), hours%24);
		return string.format(FuncUtil.GetLocalizeResStr("502509"), leftTimeStr);
	elseif leftSeconds > 0 then
		local leftTimeStr = string.format(FuncUtil.GetLocalizeResStr("301154"), math.floor(leftSeconds/(60*60)), math.floor(leftSeconds/60%60));
		return string.format(FuncUtil.GetLocalizeResStr("502509"), leftTimeStr);
	else
		return "";
	end
end

-- 当前地图是否在开启时间内
function TeamUpSystem.IsOnTime(mapInfo)	
	--log_tree("TeamUpSystem.IsOnTime mapInfo", mapInfo);
	
	local isOpen = true;
	local hasPreview = false;
	local previewStr = "";
	local previewTime = 0;
	local previewPriority = 0;
	
	if not mapInfo or not mapInfo.group_id then
		log("TeamUpSystem.IsOnTime param error!");
		return isOpen, hasPreview, previewStr;
	end
		
	local viewLimitInfo = nil;
	if TeamUpSystem.ModeViewLimit then
		viewLimitInfo = TeamUpSystem.ModeViewLimit[mapInfo.group_id];
	end
	
    if not viewLimitInfo then
		-- 没有设置的 默认为始终开启
		log("TeamUpSystem.IsOnTime viewLimitInfo is nil!");
        return isOpen, hasPreview, previewStr;
    end
	
	log_tree("TeamUpSystem.IsOnTime viewLimitInfo", viewLimitInfo);
	
	local curTime = NetUtil.GetCurServerTime();
	local curWeekDay = FuncUtil.GetUTCWeekDayByTime(curTime);
	
	log("curTime: " .. curTime);
	log("!curTime:"..os.date("!%y-%m-%d, %H:%M:%S", curTime));
	log("curWeekDay:"..curWeekDay..", curTime:"..os.date("%y-%m-%d, %H:%M:%S", curTime));
	
	-- 最近预告时间
	local recentlyPreviewTime = 0;
	-- 最近开启时间
	local recentlyOpenTime = 0;
			
	for k,v in pairs(viewLimitInfo) do
		local startTime = TimeUtil.TimeStringToUnixstamp(v.start_time);
        local endTime   = TimeUtil.TimeStringToUnixstamp(v.end_time);
				
		------------------------
		-- 以下是开启检查逻辑 --
		------------------------
		if curTime >= startTime and curTime <= endTime then
			if v.open_type == 0 then
				-- 每天指定时段开放
				local startHourTimeStr = string.sub(v.start_time, 12, string.len(v.start_time));
                local endHourTimeStr   = string.sub(v.end_time, 12, string.len(v.end_time));
				
				if FuncUtil.IsInUTCDayTimeRange(curTime, startHourTimeStr, endHourTimeStr) then
					return isOpen, hasPreview, previewStr;
				end
            end
			
            if v.open_type == 1 then	
				-- 日期内连续时间开放
                return isOpen, hasPreview, previewStr;
            end
			
			if v.open_type == 2 then				
				-- 每周指定星期几，指定时段开放
				local startWeekDay = FuncUtil.GetUTCWeekDayByTime(startTime);
				local endWeekDay = FuncUtil.GetUTCWeekDayByTime(endTime);
				
				if curWeekDay >= startWeekDay and curWeekDay <= endWeekDay then
					-- 当前在指定星期几
					local startHourTimeStr = string.sub(v.start_time, 12, string.len(v.start_time));
					local endHourTimeStr   = string.sub(v.end_time, 12, string.len(v.end_time));
					--log("type2 startHourTimeStr:"..startHourTimeStr..", endHourTimeStr:"..endHourTimeStr);
					if FuncUtil.IsInUTCDayTimeRange(curTime, startHourTimeStr, endHourTimeStr) then
						return isOpen, hasPreview, previewStr;
					end
				end
            end
		end
		
		------------------------------------
		-- 以下是未开启，预告数据处理逻辑 --
		------------------------------------
		if curTime <= endTime then		
			local tmpStartTime = 0;
			local tmpEndTime = 0;
			local startHourTimeStr = "";
			local endHourTimeStr = "";
			
			if v.open_type == 0 then				
				-- 每天指定时段开放
				startHourTimeStr = string.sub(v.start_time, 12, string.len(v.start_time));	
				endHourTimeStr = string.sub(v.end_time, 12, string.len(v.end_time));	
				
				if curTime < startTime then
					-- 还未开始
					tmpStartTime = TeamUpSystem.GetStartHourTime(startTime, startHourTimeStr);
				else
					-- 已经开始
					tmpStartTime = TeamUpSystem.GetStartHourTime(curTime, startHourTimeStr);
					tmpEndTime = TeamUpSystem.GetStartHourTime(curTime, endHourTimeStr);
					if curTime > tmpEndTime then
						-- 取第二天的开启时间
						tmpStartTime = tmpStartTime + 86400;
					end
				end
				
				log("open_type:"..v.open_type..", 开启时间:"..os.date("%y-%m-%d, %H:%M:%S", tmpStartTime));
				log("预告时间:"..os.date("%y-%m-%d, %H:%M:%S", (tmpStartTime - v.preview_hours * 3600))..", 优先级:"..v.preview_priority..", 内容"..v.preview_content);
				
				if tmpStartTime < endTime and (recentlyOpenTime == 0 or recentlyOpenTime >= tmpStartTime) then				
					-- 更新最近开启时间
					if recentlyOpenTime == tmpStartTime and previewPriority > v.preview_priority then
						-- 相同预告时间，如果当前优先级高于更新优先级则不处理
					else
						recentlyOpenTime = tmpStartTime;
						previewStr = v.preview_content;
						
						previewPriority = v.preview_priority;
						log("更新最近开启时间:"..os.date("%y-%m-%d, %H:%M:%S", recentlyOpenTime)..", 预告:"..previewStr);
						local leftSecond = tmpStartTime - curTime;
						if leftSecond > 0 then
							previewStr = string.format("%s\n%s", TeamUpSystem.GetLeftTimeStr(leftSecond), previewStr);
						end
					end
				end
							
				if previewTime == 0 or previewTime > (tmpStartTime - v.preview_hours * 3600) then
					-- 更新最近预告时间
					previewTime = tmpStartTime - v.preview_hours * 3600;
					log("更新最近预告时间:"..os.date("%y-%m-%d, %H:%M:%S", previewTime));
				end
			elseif v.open_type == 1 and curTime < startTime then
				log("open_type:"..v.open_type..", 开启时间:"..os.date("%y-%m-%d, %H:%M:%S", startTime));
				log("预告时间:"..os.date("%y-%m-%d, %H:%M:%S", (startTime - v.preview_hours * 3600))..", 优先级:"..v.preview_priority..", 内容"..v.preview_content);
				
				-- 日期内连续时间开放
				if recentlyOpenTime == 0 or recentlyOpenTime > startTime then				
					-- 更新最近开启时间
					if recentlyOpenTime == startTime and previewPriority > v.preview_priority then
						-- 相同预告时间，如果当前优先级高于更新优先级则不处理
					else
						recentlyOpenTime = startTime;
						previewStr = v.preview_content;
						previewPriority = v.preview_priority;

						local leftSecond = startTime - curTime;
						log("[HHF]TeamUpSystem.IsOnTime, v.preview_content = " .. tostring(v.preview_content) .. ", leftSecond = " .. tostring(leftSecond) ..
							", curTime = " .. tostring(curTime) .. ", tmpStartTime = " .. tostring(tmpStartTime));
						if leftSecond > 0 then
							previewStr = string.format("%s\n%s", TeamUpSystem.GetLeftTimeStr(leftSecond), previewStr);
						end
						log("[HHF]TeamUpSystem.IsOnTime, previewStr = " .. tostring(previewStr));
					end
				end
				
				if previewTime == 0 or previewTime >= (startTime - v.preview_hours * 3600) then					
					-- 更新最近预告时间
					previewTime = startTime - v.preview_hours * 3600;
					log("更新最近预告时间:"..os.date("%y-%m-%d, %H:%M:%S", previewTime));
				end
			elseif v.open_type == 2 then
				-- 每周指定星期几，指定时段开放
				startHourTimeStr = string.sub(v.start_time, 12, string.len(v.start_time));				
				if curTime < startTime then
					-- 还未开始
					tmpStartTime = TeamUpSystem.GetStartHourTime(startTime, startHourTimeStr);					
				else
					-- 已经开始
					local startWeekDay = FuncUtil.GetUTCWeekDayByTime(startTime);
					local endWeekDay = FuncUtil.GetUTCWeekDayByTime(endTime);
					
					tmpStartTime = TeamUpSystem.GetStartHourTime(curTime, startHourTimeStr);
					tmpEndTime = TeamUpSystem.GetStartHourTime(curTime, endHourTimeStr);
					
					if curWeekDay < startWeekDay then
						-- 早于开启日，补齐到第一个开启星期几
						tmpStartTime = tmpStartTime + (startWeekDay - curWeekDay) * 86400;
					elseif curWeekDay > endWeekDay then
						-- 晚于开启日，补齐到下一个开启星期几
						tmpStartTime = tmpStartTime + (7 - (curWeekDay - startWeekDay)) * 86400;
					else
						-- 在开启日区间，如果超过时段，取下一天
						if (curWeekDay + 1) <= endWeekDay then
							tmpStartTime = tmpStartTime + 86400;
						else
							tmpStartTime = 0;
						end
					end
				end
				
				log("open_type:"..v.open_type..", 开启时间:"..os.date("%y-%m-%d, %H:%M:%S", tmpStartTime));
				
				if tmpStartTime > 0 then
					log("预告时间:"..os.date("%y-%m-%d, %H:%M:%S", (tmpStartTime - v.preview_hours * 3600))..", 优先级:"..v.preview_priority..", 内容"..v.preview_content);
					if recentlyOpenTime < endTime and (recentlyOpenTime == 0 or recentlyOpenTime >= tmpStartTime) then
						-- 更新最近开启时间
						if recentlyOpenTime == tmpStartTime and previewPriority > v.preview_priority then
							-- 相同预告时间，如果当前优先级高于更新优先级则不处理
						else
							recentlyOpenTime = tmpStartTime;
							previewStr = v.preview_content;
							previewPriority = v.preview_priority;
							log("更新最近开启时间:"..os.date("%y-%m-%d, %H:%M:%S", recentlyOpenTime)..", 预告:"..previewStr);
							
							local leftSecond = tmpStartTime - curTime;
							if leftSecond > 0 then
								previewStr = string.format("%s\n%s", TeamUpSystem.GetLeftTimeStr(leftSecond), previewStr);
							end
						end
					end
					
					if previewTime == 0 or previewTime > (tmpStartTime - v.preview_hours * 3600) then
						-- 更新最近预告时间
						previewTime = tmpStartTime - v.preview_hours * 3600;
						log("更新最近预告时间:"..os.date("%y-%m-%d, %H:%M:%S", previewTime));
					end
				end
			end
		end
	end
	
	-- 以下处理未开启情况
	isOpen = false;
	hasPreview = previewTime > 0 and curTime >= previewTime;
		
	log("TeamUpSystem.IsOnTime return isOpen:"..tostring(isOpen)..",hasPreview:"..tostring(hasPreview));
	log("预告时间:"..os.date("%y-%m-%d, %H:%M:%S", previewTime)..", 内容:"..previewStr);
	return isOpen, hasPreview, previewStr;
end

-- 获取指定开启时间
-- dayTime 使用年月日
-- hourTimeStr 小时
function TeamUpSystem.GetStartHourTime(dayTime, hourTimeStr)
	if not dayTime or dayTime == 0 or not hourTimeStr or hourTimeStr == "" then
        return 0;
    end
	
	local startTimeStr = string.format("%s %s", os.date("!%Y-%m-%d", dayTime), hourTimeStr);
	
	return TimeUtil.TimeStringToUnixstamp(startTimeStr);
end

function TeamUpSystem.CreateModelInfoList(mode_info_table)
	local newModelInfo = mode_info_table;
	local modelCfg = {};
	local groupCfg = {};
	local isDefault = 0; -- 0未选中，1选中

	for k,v in pairs(newModelInfo) do
		modelCfg = Client.GetTableData("MatchModeTable", k);
		if modelCfg then
			v.model_type = modelCfg.ModeType;
			if v.model_type == 1 or v.model_type == 2 or v.model_type == 3 or v.model_type == 4 then
				-- 补齐地图对应的视图id
				for kk,vv in pairs(v.mode_group) do
					groupCfg = Client.GetTableData("GroupingTable", kk);
					if groupCfg then
						vv.group_id = groupCfg.ViewId;
					else
						vv.group_id = 0;
					end
				end

				-- 补齐地图对应的选中状态			
				for kk,vv in pairs(v.mode_group) do
					isDefault = 0;

					--for kkk,vvv in pairs(v.default_mode_group) do
						--if vvv == vv.group_id then
							-- 检查当前等级
					local levelLimit = (vv.need_level <= DataMgr.roleData.level);
					local ratingLimit = (vv.rating_limit <= TeamUpSystem.GetRatingByModelId(k));
					local pveLevelLimit = (vv.need_pve_level <= DataMgr.roleData.pve_level);
					if levelLimit and ratingLimit and pveLevelLimit then
						isDefault = 1;
					end
							--break;
						--end
					--end
									
					local isOpen, hasPreview, previewStr = TeamUpSystem.IsOnTime(vv);					
					if not isOpen then
						isDefault = 0;
					end
					--log_tree("CreateModelInfoList mode_group_info", vv);	
					--log("isOpen:"..tostring(isOpen)..", hasPreview:"..tostring(hasPreview)..", previewStr:"..previewStr);
										
					vv.is_default = isDefault;
				end
			end
		else
			--PopUpNoticeUI.ShowNewNotice("组队模式配置出错");
			DataMgr.ShowNoticeByID(500039);
		end
	end
	
	log_tree("TeamUpSystem.CreateModelInfoList", newModelInfo);
	--[[ 最终结构
	newModelInfo
		├─ 201
		│  ├─ model_type: 2
		│  ├─ default_mode_group
		│  │  ├─ 1: 3
		│  │  └─ 2: 4
		│  ├─ is_optional: false
		│  └─ mode_group
		│     ├─ 34
		│     │  ├─ need_level: 1
		│     │  ├─ is_default: 1
		│     │  ├─ rating_limit: 0
		│     │  └─ group_id: 3
		│     └─ 37
		│        ├─ need_level: 1
		│        ├─ is_default: 1
		│        ├─ rating_limit: 0
		│        └─ group_id: 4
	]]--
	return newModelInfo;
end

function TeamUpSystem.GetRatingByModelId(modelId)
	--log("TeamUpSystem.GetRatingByModelId solo:"..DataMgr.roleData.segment.solo..", double:"..DataMgr.roleData.segment.double..", team:"..DataMgr.roleData.segment.team);
	-- if modelId == 101 then
	-- 	return DataMgr.roleData.rankdata.solo.rank_rating;
	-- elseif modelId == 102 then
	-- 	return DataMgr.roleData.rankdata.duo.rank_rating;
	-- elseif modelId == 103 then
	-- 	return DataMgr.roleData.rankdata.squad.rank_rating;
	-- end

	return 0;
end

-- 更新当前模式地图属性
function TeamUpSystem.UpdateModelMapInfo(modelId, mapId, isSelected)	
	local groupId = 0;
	local modelType = 0;
	for k,v in pairs(TeamUpSystem.ModeInfoList) do
		if k == modelId then
			for kk, vv in pairs(v.mode_group) do
				if kk == mapId then
					groupId = vv.group_id;
					modelType = v.model_type;
					break;
				end
			end
			break;
		end
	end

	log("TeamUpSystem.UpdateModelMapInfo modelId:"..modelId..", mapId:"..mapId..", modelType:"..modelType..", groupId:"..groupId..", isSelected:"..tostring(isSelected));
	local levelLimit = false;
	local ratingLimit = false;
	local pveLevelLimit = false;
	for k,v in pairs(TeamUpSystem.ModeInfoList) do
		if v.model_type == modelType then
			for kk, vv in pairs(v.mode_group) do
				if vv.group_id == groupId then
					levelLimit = vv.need_level <= DataMgr.roleData.level;
					pveLevelLimit = vv.need_pve_level <= DataMgr.roleData.pve_level;
					ratingLimit = vv.rating_limit <= TeamUpSystem.GetRatingByModelId(k);
					if isSelected and levelLimit and ratingLimit and pveLevelLimit then
						vv.is_default = 1;
					else
						vv.is_default = 0;
					end
				end
			end
		end
	end

	local modelInfo = {};
	for k,v in pairs(TeamUpSystem.ModeInfoList) do
		if k == modelId then
			modelInfo = v;
			break;
		end
	end

	return modelInfo;
end

function TeamUpSystem.testShieldData( )
	local  mode_shields = 
	{
		[101] = {open_end = 0, is_shield = false, open_begin = 0};
		[102] = {open_end = 1514304000, is_shield = true, open_begin = 1513526400};
		[103] = {open_end = 0, is_shield = true, open_begin = 1513612800};

	}
	TeamUpSystem.ModeShields = mode_shields;
end

function TeamUpSystem.on_change_type_rsp(res)
	log("on_change_type_rsp faild"..res);
	if res ~= "ok" then
		TeamUpSystem.on_mode_shield_req();
	end 
end

function TeamUpSystem.on_change_leader_rsp( new_leader, res)
	log("on_change_leader_rsp"..res);
	if res == "member-offline" then
		--提示“对方已离线，不能任命队长”。后台返回 TODO
		DataMgr.ShowNoticeByID(110065);

	end
end

function TeamUpSystem.on_team_update_wear(op_uid, wear_res, wear_ext_res, knapsack_ext_info)
	log_tree("wear_res", wear_res);
	log_tree("wear_res", wear_ext_res);
	TeamUpSystem.ChangeWearPair =
	{
		uid = op_uid;
		ware = wear_res;
		wear_ext = wear_ext_res;
	}
	HallThemeUtils.ProcTeamUpdateWear(op_uid, knapsack_ext_info)

	EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_CHANGE_WEAR_PAIR);
end

--返回预留teamid,用于平台邀请
function TeamUpSystem.on_plat_get_teamid_rsp(res,team_id,battle_id)
	log("on_plat_get_teamid_rsp "..team_id.. "  " .. battle_id);
	--[[
		team_is_full
		already_in_match
		already_in_game
	]]
	if res == "ok" then
		if _G.BP_Platform == BP_ENUM_PLAYFORM_WX then
			ShareMgr:InviteJoinTeamWX(team_id, battle_id);
		elseif _G.BP_Platform == BP_ENUM_PLAYFORM_QQ then
			ShareMgr:InviteJoinTeamQQ(team_id);
		end
	elseif res == "team_is_full" then		
		DataMgr.ShowNoticeByID(110007);
		--PopUpNoticeUI.ShowMessageBox("提示", "邀请失败，队伍人数已满。");
	elseif res == "already_in_match" then
		DataMgr.ShowNoticeByID(110061);----%s在匹配中
	elseif res == "already_in_game" then
		DataMgr.ShowNoticeByID(9911106);----游戏中
	else
		--team_recruit_for_plat_res("already_in_room")      ---您在房间中，不能邀请组队。
		TeamUpUI.ProtocolErrorCode(res);
	end

end	

--捏脸换性别
function TeamUpSystem.on_team_change_avatar(op_uid, newAvatar)
	log("on_team_change_avatar"..op_uid);
	--log_tree("on_team_change_avatar",newAvatar);
	--newAvatar = {gamegender=0,headid=0,hairid=0}
	TeamUpSystem.ChangeAvatarInfo = {
		reCreate = NeedReCreatPalyer(op_uid,newAvatar), --是否重新创建
		uid = op_uid,
		avatar = newAvatar,
	};
	--同步下数据，用于断线重连	
	local _info = TeamUpSystem.GetMemberInfo(op_uid);
	if _info ~= nil then
		--更新
		_info.avatar = newAvatar;
		_info.gender = newAvatar.gamegender;
		ProfileMgr.UpdateRoleSexByUid(op_uid, newAvatar.gamegender)
		EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_CHANGE_AVATAR);	
	end
end

--收到表情动作同步（没队伍不需要同步，即使是有队伍，也不会同步给自己）
function TeamUpSystem.sync_player_action(player_uid, action_id, randSoundId)
	log("sync_player_action player_uid = " .. tostring(player_uid) .. ", action_id = " .. tostring(action_id)..",randSoundId="..randSoundId);
	local sex = ProfileMgr.GetRoleSexByUid(player_uid)
	LobbyUI:ShowEmoteAction(player_uid, action_id, sex, randSoundId);
end

--[[网络回调]]--

s2c["team_invite_respond"] = TeamUpSystem.on_team_invite_respond; --邀请他人

s2c["team_invite_notify"] = TeamUpSystem.on_team_invite_notify; --收到组队邀请

s2c["team_quit_respond"] = TeamUpSystem.on_team_quit_respond;  --退出队伍

s2c["team_apply_respond"] = TeamUpSystem.on_team_apply_respond; -- 申请入队

s2c["team_apply_notify"] = TeamUpSystem.on_team_apply_notify; --队长收到入队申请

s2c["team_info_sync"] = TeamUpSystem.on_team_info_sync; --同步当前队伍信息

s2c["team_kick_respond"] = TeamUpSystem.on_team_kick_respond; --踢人

s2c["query_myid_respond"] = TeamUpSystem.on_query_myid_respond; --查询我得GID

s2c["team_info_notify"] = TeamUpSystem.on_team_info_change_notify; --队伍信息变动

s2c["team_change_wear"] = TeamUpSystem.on_team_change_wear; --队伍换装通知

s2c["team_join_respond"] =  TeamUpSystem.on_team_join_rsp -- 用于招募队员加入错误信息返回

s2c["team_recruit_rsp"] =  TeamUpSystem.team_recruit_rsp; --招募消息时间限制

s2c["get_mode_shield_rsp"] =  TeamUpSystem.on_mode_shield_rsp -- 限时组队开放

s2c["team_change_type_respond"] = TeamUpSystem.on_change_type_rsp; -- 主要用于限时组队开放，选择模式失败重新拉下开放数据

s2c["team_change_leader_respond"] = TeamUpSystem.on_change_leader_rsp;  --只处理点离线队员的“转让队长”按钮，提示“对方已离线，不能任命队长”

s2c["team_update_wear"] = TeamUpSystem.on_team_update_wear;	-- 队员更换衣橱

--平台邀请组队
--[[
c2s.team_recruit_for_plat_req( )
s2c.team_recruit_for_plat_res( res，team_id)
--]]
s2c["team_recruit_for_plat_res"] = TeamUpSystem.on_plat_get_teamid_rsp; --申请teamid返回，用于平台邀请
s2c["team_change_avatar"] = TeamUpSystem.on_team_change_avatar; --队伍捏脸通知
s2c["sync_player_action"] = TeamUpSystem.sync_player_action;





-----------------intl start-------------------

--请求服务器大区列表
function TeamUpSystem.query_match_zone_list_req()
    log("query_match_zone_list_req");
    NetUtil.SendPkg("query_match_zone_list");
end

--服务器下发服务器大区列表
function TeamUpSystem.sync_match_zone_list_rsp(tpingsvr_tab)
    log("sync_match_zone_list_rsp");
    TeamUpSystem.SaveZoneListInfo(tpingsvr_tab);
    DataMgr.SyncZoneList(tpingsvr_tab);
    EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_INTL_ZONELIST_RSP);
end

function TeamUpSystem.SaveZoneListInfo(tpingsvr_tab)

	if(tpingsvr_tab == nil) then
		log("TeamUpSystem.SaveZoneListInfo, tpingsvr_tab is nil! ")
		return
	end

	local strRegion = Client.GetPublishRegion() ;

    TeamUpSystem.ChooseZoneList = {};
    table.sort(tpingsvr_tab, function(a, b) return a.zone_id < b.zone_id end)
    
    log("TeamUpSystem.SaveZoneListInfo count: "..#tpingsvr_tab)
	if(tpingsvr_tab ~= nil) then
		for k,v in pairs(tpingsvr_tab) do
			local zoneinfo =
			{
				zone_id = v.zone_id,
				tpingsvr_ip = v.tpingsvr_ip,
                tpingsvr_port = v.tpingsvr_port

			};
            --log("TeamUpSystem.SaveZoneListInfo: zoneinfo.zone_id = "..tostring(zoneinfo.zone_id) .."tpingsvr_ip = "..zoneinfo.tpingsvr_ip .."tpingsvr_port = "..zoneinfo.tpingsvr_port);
			-- 日韩版日韩服排第一
			if v.zone_id == 6 and (strRegion == "KOREA" or strRegion == "JAPAN")then
				table.insert(TeamUpSystem.ChooseZoneList, 1, zoneinfo);
			else
				table.insert(TeamUpSystem.ChooseZoneList, zoneinfo);
			end
		end
	end
--[[
    local zoneinfoTest1 =
			{
				zone_id = 3,
				tpingsvr_ip = "100.226.129.164",
                tpingsvr_port = "10199"

			};
    table.insert(TeamUpSystem.ChooseZoneList, zoneinfoTest1);

    local zoneinfoTest2 =
			{
				zone_id = 3,
				tpingsvr_ip = "100.112.20.95",
                tpingsvr_port = "9030"

			};

    table.insert(TeamUpSystem.ChooseZoneList, zoneinfoTest2);
--]]
    --log_tree("---TeamUpSystem.ChooseZoneList",TeamUpSystem.ChooseZoneList);
end

function  TeamUpSystem.SaveRegionVoiceUrlList( regionVoiceUrlList )
	-- 
	log ("SaveRegionVoiceUrlList")

	if nil == regionVoiceUrlList or #regionVoiceUrlList == 0 then
		return
	end

	TeamUpSystem.RegionVoiceUrlList = {}
	--log_tree("regionVoiceUrlList from server", regionVoiceUrlList)

	for k,v in pairs(regionVoiceUrlList)  do
		local voiceUrlInfo = 
		{
			RegionId = v.region_id,
			Country = v.country,
			ZoneId = v.zone_id,
			GVoiceServer = v.gvoice_server,
			Province = v.province
		}
		
		local listKey = v.region_id
		
		if v.province ~= nil then
			listKey = listKey .. v.province
		end

		TeamUpSystem.RegionVoiceUrlList[listKey] = voiceUrlInfo
	end	

	--log_tree ("TeamUpSystem.RegionVoiceUrlList", TeamUpSystem.RegionVoiceUrlList)
end

function  TeamUpSystem.UpdateVoiceUrlAfterSelectZone()

	--url改为由后台下发，此方法暂时废弃
	--[[
	if TeamUpSystem.TeamInfo.leader ~= nil then
		local leaderUid = TeamUpSystem.TeamInfo.leader;
		if leaderUid ~= 0 then
			local myInfo = TeamUpSystem.GetMemberInfo(leaderUid);
			if myInfo ~= nil then
				--保证新老版本兼容性
				local listKey = myInfo.ip_region
				if myInfo.ip_region_info ~= nil then
					listKey = myInfo.ip_region_info.country
				end
				if myInfo.ip_region_info ~= nil and myInfo.ip_region_info.province ~= nil then
					listKey = listKey .. myInfo.ip_region_info.province
				end
				log ("ip_region Key" .. listKey)
				if nil ~= listKey and nil ~= TeamUpSystem.RegionVoiceUrlList[listKey] and TeamUpSystem.RegionVoiceUrlList[listKey].ZoneId == TeamUpSystem.ChooseZoneId	 then
					TeamUpSystem.SelectRegionVoiceUrl = TeamUpSystem.RegionVoiceUrlList[listKey].GVoiceServer
					log("UpdateVoiceUrlAfterSelectZone Select listKey:" .. listKey .. " ||Url:" .. TeamUpSystem.SelectRegionVoiceUrl)
				elseif nil ~= listKey and nil ~= TeamUpSystem.RegionVoiceUrlList[myInfo.RegionId] and TeamUpSystem.RegionVoiceUrlList[myInfo.RegionId].ZoneId == TeamUpSystem.ChooseZoneId	 then
					TeamUpSystem.SelectRegionVoiceUrl = TeamUpSystem.RegionVoiceUrlList[myInfo.RegionId].GVoiceServer
					log("UpdateVoiceUrlAfterSelectZone Select listKey:" .. listKey .. " ||Url:" .. TeamUpSystem.SelectRegionVoiceUrl)
				end
			end	
		end	
	end	
	]]--		
end

--选择匹配大区请求
function TeamUpSystem.on_select_zone_req(match_zone)
	-- modify by stephezhang, 自动化测试，只选择北美区
	local bUIAutoTest = Client.IsUIAutoTest();
	if bUIAutoTest then
		match_zone = 1
	end
    log("on_select_zone_req,match_zone = "..match_zone);
    NetUtil.SendPkg("on_select_zone_req",match_zone);
end

--选择匹配大区回复
--ret:
----"ok" -->成功
----"nil zone" --> 没有传递zone
----"invalid zone" --> 所选zone不存在
----"player_matching" --> 匹配中不能选择zone
----"not-leader" --> 不是队长
-- match_zone:匹配大区id
function TeamUpSystem.on_select_zone_rsp(ret, match_zone)
    log("on_select_zone_res, ret = "..ret..", match_zone = "..match_zone);
    if(string.lower(ret)=="ok") then
        TeamUpSystem.ChooseZoneId = match_zone;
        LobbySystem.matchZone = match_zone;
        TeamUpSystem.on_mode_shield_req();

    elseif (string.lower(ret)=="nil zone" or string.lower(ret)=="invalid zone") then
        textMsg =  Client.GetTableData("LocalizeRes", "1012").TextValue; --所选区不存在
        DataMgr.ShowNoticeByString(textMsg);
    elseif (string.lower(ret)=="player_matching") then
        textMsg =  Client.GetTableData("LocalizeRes", "1013").TextValue; --当前为匹配状态，停止匹配才能进行选区操作
        DataMgr.ShowNoticeByString(textMsg);
    elseif (string.lower(ret)=="not-leader") then
        textMsg =  Client.GetTableData("LocalizeRes", "1014").TextValue; --当前处于队伍中，只有队长才能选区
        DataMgr.ShowNoticeByString(textMsg);
    end

    TeamUpSystem.UpdateVoiceUrlAfterSelectZone()
	
	MatchPopupUI.SetMatchParamByZoneList()

    EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_INTL_SELECT_ZONE_RSP, string.lower(ret));
end

--队伍匹配大区变更通知广播
-- teamid:integer 队伍id
-- match_zone:integer 匹配大区id
function TeamUpSystem.team_match_zone_notify( match_zone)
    log("team_match_zone_notify, match_zone = "..match_zone);
    TeamUpSystem.ChooseZoneId = match_zone;
    LobbySystem.matchZone = match_zone;
	
    TeamUpSystem.UpdateVoiceUrlAfterSelectZone()

	MatchPopupUI.SetMatchParamByZoneList()
	
    EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_INTL_MATCH_ZONE_NOTIFY);
end

function TeamUpSystem.GetTeamCode()
	local teamCode = ""
	if TeamUpSystem.TeamInfo ~= nil and TeamUpSystem.TeamInfo.code ~= nil then
		teamCode = TeamUpSystem.TeamInfo.code
	end
	return teamCode
end

function TeamUpSystem.SetTeamCode(code)
	if TeamUpSystem.TeamInfo ~= nil then
		TeamUpSystem.TeamInfo.code = code
	end
end

--判断是否在面对面组队中
function TeamUpSystem.IsInFaceTeam()
	local isIn = false
	local teamCode = TeamUpSystem.GetTeamCode()
	if teamCode and string.len(teamCode)>0 then
		isIn = true
	end
	return isIn
end

function TeamUpSystem.GetMapSkillInfo(mapId)
	if nil == TeamUpSystem.mapSkillInfo then
		TeamUpSystem.mapSkillInfo = {};
	end
	if TeamUpSystem.mapSkillInfo[tostring(mapId)] then
		return TeamUpSystem.mapSkillInfo[tostring(mapId)];
	else
		local PlayerPrefs = require("client.tools.playerprefs")
		local skillInfo = PlayerPrefs.GetPlayerPrefs(tostring(mapId),PlayerPrefs.ePlayerPrefsType.eMapSkill);
		TeamUpSystem.mapSkillInfo[tostring(mapId)] = skillInfo;
		return skillInfo;
	end
end

--6.0需求,获取更新说明数据
function TeamUpSystem.get_label_status_req()
	--log("get_label_status_req");
	NetUtil.SendPkg("get_label_status");	
end

function TeamUpSystem.get_label_status_rsp(res, tb)
	--log_tree("get_label_status_rsp", tb);
	--log("get_label_status_rspok--" .. res);
	if res == "ok" then
		if tb == nil or _G.next(tb) == nil then
			BP_MODETYPE_NEW = 0;
			BP_PLAYERNUM_NEW = 0;
			BP_MAPID_NEW = 0;
			BP_PERSPECTIVE_NEW = 0;
		else
			for k,v in pairs(tb) do
				if v.mode_type > 0 then
					BP_MODETYPE_NEW = v.mode_type;
				end
				if v.player_num > 0 then
					BP_PLAYERNUM_NEW = v.player_num;
				end
				if v.map_id > 0 then
					BP_MAPID_NEW = v.map_id;
				end
				if v.perspective > 0 then
					BP_PERSPECTIVE_NEW = v.perspective;
				end
			end
		end	
	end
end

--获取走马灯信息
function TeamUpSystem.get_horse_lamp_req()
	NetUtil.SendPkg("get_horse_lamp");	
end

function TeamUpSystem.get_horse_lamp_rsp(msg, info)
	--log_tree("get_horse_lamp_rsp", info);
	if msg == "ok" then
		if info == nil or _G.next(info) == nil then
			TeamUpModelUI.CancelRollTip();
		else
			for k,v in pairs(info) do
				if v.info ~= "" then
					BP_SCROLLBAR_TIPS = true;
					BP_MSG_CONTENT = v.info;
					SCROLLBAR_KEY = k;
				end
			end
			TeamUpModelUI.ShowRollTip();
		end		
	end
end

function TeamUpSystem.SendMyMapInfo(param)
	--log_tree("[HHF]TeamUpSystem.SendMyMapInfo, Send update_client_map_info, param = ", param, "[HHF]");
	NetUtil.SendPkg("update_client_map_info", param);
end

function TeamUpSystem.update_client_map_info_rsp(res)
	log("[HHF]TeamUpSystem.update_client_map_info_rsp, received update_client_map_info_rsp, res = " .. tostring(res));
	if res == "ok" then
	else
	end
end

function TeamUpSystem.UpdateMyMapInfo(param)
	--log_tree("[HHF]TeamUpSystem.UpdateMyMapInfo, Send user_finish_download_map, param = ", param, "[HHF]");
	NetUtil.SendPkg("user_finish_download_map", param);
end

function TeamUpSystem.user_finish_download_map_rsp(res)
	log("[HHF]TeamUpSystem.user_finish_download_map_rsp, received user_finish_download_map_rsp, res = " .. tostring(res));
	if res == "ok" then
	else
	end
end

--收到房间邀请提示
function TeamUpSystem.on_room_invite_notify(inviter, room_id, mode)
	log("on_room_invite_notify inviter = "..inviter);
	log("on_room_invite_notify room_id = "..room_id);
	if mode ~= nil then
		log("on_room_invite_notify mode = " .. mode);
	end

	local autoRefuse = TeamUpSystem.CheckInviteAutoRefuse(inviter);

	if (autoRefuse == true) then
		log("on_room_invite_notify autoRefuse = true");
		return;
	end
	--不在黑名单的才弹出邀请消息
	local isPullBack = FriendSystem.IsPulBlack(inviter);
	log("on_room_invite_notify ispulblack:"..tostring(isPullBack));
	if isPullBack == false then
		local inviteApplyData = {};
		inviteApplyData.type = 2;	--房间邀请提示
		inviteApplyData.playerId = inviter;
		inviteApplyData.InviterRoomID = room_id;
		inviteApplyData.playerName = TeamUpSystem.GetMemberName(inviter);
		inviteApplyData.gameType = TeamUpUI.GetOldGameType(999);	--房间
		table.insert(TeamUpSystem.InviteApplyQueue, inviteApplyData);
		TeamUpSystem.CheckNextInviteApply();
		log("on_room_invite_notify inviteApplyData.gameType = " .. inviteApplyData.gameType);
	end
end

s2c["on_select_zone_res"] = function(ret, match_zone)
	TeamUpSystem.on_select_zone_rsp(ret, match_zone);
	RoomSystem.on_select_zone_rsp(ret, match_zone);
end

s2c["sync_match_zone_list"] = TeamUpSystem.sync_match_zone_list_rsp;

s2c["team_match_zone_notify"] = function(match_zone)
	TeamUpSystem.team_match_zone_notify(match_zone);
	RoomSystem.team_match_zone_notify(match_zone);
end

s2c["get_label_status_rsp"] = TeamUpSystem.get_label_status_rsp;
s2c["get_horse_lamp_rsp"] = TeamUpSystem.get_horse_lamp_rsp;


s2c["update_client_map_info_rsp"] = TeamUpSystem.update_client_map_info_rsp;
s2c["user_finish_download_map_rsp"] = TeamUpSystem.user_finish_download_map_rsp;

s2c["room_invite_notify"] = TeamUpSystem.on_room_invite_notify; --收到房间邀请
-----------------intl end-------------------