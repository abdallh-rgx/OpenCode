--[[
聊天消息数据管理
]]--

LobbyChatSystem = LobbyChatSystem or
{
	chatInited = false;
		
	chatBufferList = {};			--消息缓存列表
	chatRoomBufferList = {};		--聊天室消息缓存列表
	chatFriendBufferList = {};		--好友离线消息缓存列表
	
	chatProfileInfoList = {};		-- 聊天对象概要信息列表
	
	MAX_MESSAGE_BUFFER_CACHE_NUM = 200;	--消息队列缓存列表
	MAX_MESSAGE_CACHE_NUM = 100;    		--历史消息的最大支持条数
	MAX_CORPS_MESSAGE_CACHE_NUM = 200;    	--军团消息的最大支持条数
	MAX_TEAM_RECRUIT_CACHE_NUM = 100;		--队伍招募信息的最大支持条数
	MAX_MESSAGE_CHATROOM_HISTORY_CACHE = 20;
	MAX_MESSAGE_CORPS_CHAT_HISTORY_CACHE = 30;
	MAX_FRIEND_MESSAGE_CACHE_NUM = 100;		--好友消息的最大支持条数
	MAX_PROFILE_CACHE_NUM = 30;
	MAX_CHATROOM_MEMBER = 200;		--TODO 讨论人数上限
	STATIC_MESSAGE_COUNTER = 1;
	STATIC_SELF_MESSAGE_COUNTER = 1;
	MAX_MESSAGE_TOPIC_NUM = 200; ---话题聊天的缓存列表条数

	bargainMessageType = 15;
	
	--聊天频道（系统消息，世界频道，战队以及私聊）
	channelSystem = 1;
	channelWorld = 2;
	channelTeam = 3;
	channelPrivate = 4;
	channelChatRoom = 5;
	channelCorps = 8;
	--这里用20表示语种频道
	channelLocalLanguage = 0; -- 0.7.0干掉
	--组队招募频道
	channelTeamRecruit = 20;
	channelCorpsBargain = 25;
	--话题频道
	channelTopic = 100;
	channelTopic2 = 101;
	channelInvalid = -1;

	teamRecruitMsgType = 1;		-- 组队招募消息类型
	corpsRecruitMsgType = 2;	-- 军团招募消息类型
	roomRecruitMsgType = 3;		-- 房间招募消息类型
	changeRoomTipsMsgType = 99;	-- 换房提示消息类型
		
	chatMsgType = 0;
	chatInviteType = 1;
	chatSelfMark = 0;
	
	chatEnterFight = false;
	chatWndOpen = false;
	chatTodayDate = "";
	
	canOpenChatWnd = true;
	chatRoomQueryPassword = false;
	
	chatNewestFriendChat = "";
	chatSelectedFriendInFight = "";
	
	friendReservingList = {};
	friendReservedInFight = {};	
	friendReservationFromLobby = {};
	
	FriendChatData =
	{
		gid = 0,
		newMessageCount = 0,
		lastMsgSendTime = 0,
		messageList = 
		{
			BP_STRUCT_ChatMessageSingleData = _G.BP_STRUCT_ChatMessageSingleData,
		};
	};

	friendChatList = 
	{
		
	};
	
	fightFriendChatList = 
	{
	};
	
	tempNewMessageList = 
	{
	};
	
	channelList = 
	{
	};	
	
	chatRoomLastMsgTime = 0;
	chatRoomMsgCounter = 0;
	chatRoomMsgMaxLimit = 8;
	chatRoomStatusDict = {};
	chatRoomPasswordContainer = {};
	chatRoomMyCreateCount = 0;
	chatRoomMaxCreate = 1;
	maxLabelNum = 3;

	recvSameLanguage = true;		-- 组队招募接收相同语言
	maxTeamRecruitDelayTime = 1000; -- 组队招募接收消息的最大延迟阈值


	msgIdGuid = 0;--msgId全局唯一标识符
	msgContentCacheMap =  --缓存发送的消息，服务器不再回发给发送者
	{
		--msgId = msgContent,
	};
	
	--sami 离线好友消息列表
	resOfflineChatMsg = {};
	resOfflineChatMsgNum = 0;
}

--[[
-----------聊天消息发送接口--------------
receiver         私聊的接收者，如果不是私聊这个字段不用
channelType      要发送的聊天频道
msgId            私聊的消息计数,可以是客户端维护
content          聊天内容
]]

function LobbyChatSystem.Entry()
	if not LobbyChatSystem.canOpenChatWnd then
		return;
	end
	
	LobbyChatSystem.Init();
	LobbyChatEntranceUI.Init();
	LobbyChatSystem.ClearFight();
	LobbyChatSystem.EnterLobby();
end

function LobbyChatSystem.Init()
	if not LobbyChatSystem.chatInited then
		LobbyChatSystem.chatInited = true;
		LobbyChatSystem.Construct();		
	end	
	
	LobbyChatLogic:PreInit();
end

function LobbyChatSystem.Release()
	if LobbyChatSystem.chatInited then
		LobbyChatSystem.Destruct();
	end	
	
	LobbyChatSystem.friendReservingList = {};
	LobbyChatSystem.friendReservedInFight = {};
	LobbyChatSystem.friendReservationFromLobby = {};
	LobbyChatSystem.ClearFight();
	LobbyChatSystem.chatInited = false;
end

function LobbyChatSystem.EnterLobby()
	local reservationLength = #LobbyChatSystem.friendReservationFromLobby;
	if reservationLength > 0 then
		local reservation = LobbyChatSystem.friendReservationFromLobby[reservationLength];
		CommonRightNotifyUI.ShowNotify(reservation, nil);
		LobbyChatSystem.friendReservationFromLobby = {};
	end
end

function LobbyChatSystem.EnterFight()	
	LobbyChatSystem.chatEnterFight = true;
	LobbyChatSystem.friendReservingList = {};
	LobbyChatSystem.friendReservedInFight = {};
end

function LobbyChatSystem.ClearFight()
	LobbyChatSystem.chatEnterFight = false;
	LobbyChatSystem.chatSelectedFriendInFight = "";
	LobbyChatSystem.fightFriendChatList = {};		
end

function LobbyChatSystem.Construct()
	EventSystem:registEvent(EVENTTYPE_LOGIN,EVENTID_BACKLOGIN, LobbyChatSystem.on_backto_login);
	EventSystem:registEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_SYNC, LobbyChatSystem.on_teamup_info_changed);
    EventSystem:registEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN, LobbyChatSystem.WardRobeAvatarResetOpen);
    EventSystem:registEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE, LobbyChatSystem.WardRobeAvatarResetClose);
end

function LobbyChatSystem.Destruct()
	EventSystem:unregistEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_SYNC, LobbyChatSystem.on_teamup_info_changed);
	EventSystem:unregistEvent(EVENTTYPE_LOGIN, EVENTID_BACKLOGIN, LobbyChatSystem.on_backto_login);
    EventSystem:unregistEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN, LobbyChatSystem.WardRobeAvatarResetOpen);
    EventSystem:unregistEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE, LobbyChatSystem.WardRobeAvatarResetClose);
	
	GlobalChatVoice.ClearRoleInfo();
end

function LobbyChatSystem.WardRobeAvatarResetOpen()
    log("LobbyChatSystem.WardRobeAvatarResetOpen")
	LuaClassObj.HandleUIMessage(bp_chat_entrance, "UIHide");
end

function LobbyChatSystem.WardRobeAvatarResetClose()
    log("LobbyChatSystem.WardRobeAvatarResetClose")
	if CorpsBaseUI.isShow == false
	and TeamUPFriendUI.isContentShowing == false
	and WardrobeUI.saveIsShowing == false
	and (RoomWaitingUI.IsShowChatEntrance == true)
	then
		LuaClassObj.HandleUIMessage(bp_chat_entrance, "UIShow");
	end
end

function LobbyChatSystem:OpenUI()
	TeamUPFriendUI.HidePanel();
	LobbyChatLogic.OpenUI();
end

function LobbyChatSystem.UpdateFriend()
	LobbyChatLogic.RefreshFriendState();
end

function LobbyChatSystem.DeleteFriend(uid)
	LobbyChatSystem.friendChatList[tostring(uid)] = nil;
	
	if LobbyChatSystem.chatNewestFriendChat == tostring(uid) then
		LobbyChatSystem.chatNewestFriendChat = ""
	end
	
	LobbyChatLogic.DeleteFriend(tostring(uid));
	LobbyChatSystem.RefreshTotalUnread();
end

function LobbyChatSystem.RefreshTotalUnread()
	local unreadCount = 0;
	for k, v in pairs(LobbyChatSystem.friendChatList) do
		unreadCount = unreadCount + v.newMessageCount;
	end
	
	LobbyChatLogic.RefreshFriendTotalUnread();
	LobbyChatEntranceUI.RefreshUnreadList(unreadCount);	
end

--[[
	gid: string
]]
function LobbyChatSystem.ChatWithFriend(gid)	
	LobbyChatEntranceUI.OpenChatUI();	
	LobbyChatLogic.ChatWithFriend(gid);
end

function LobbyChatSystem.NewestFriendChatSort(lhs, rhs)
	return lhs.newMsgTime > rhs.newMsgTime;
end

function LobbyChatSystem.OpenNewestFriendChat()
	LobbyChatSystem.tempNewMessageList = {};
	
	for k, v in pairs(LobbyChatSystem.friendChatList) do
		if 0 ~= v.newMessageCount then
			local newMsgTrunk = {};
			newMsgTrunk.gid = k;
			newMsgTrunk.newMsgTime = v.lastMsgSendTime;
			table.insert(LobbyChatSystem.tempNewMessageList, newMsgTrunk);			
		end
	end
	
	if 0 == #LobbyChatSystem.tempNewMessageList then
		return;
	end

	table.sort(LobbyChatSystem.tempNewMessageList, LobbyChatSystem.NewestFriendChatSort);
	
	LobbyChatSystem.ChatWithFriend(LobbyChatSystem.tempNewMessageList[1].gid);
end

function LobbyChatSystem.ChangeTeamType(teamType)

end

function LobbyChatSystem.ChangeCorpsData()
	LobbyChatLogic.OnCorpsDataChanged();
end

function LobbyChatSystem.QuitCorps()
	LobbyChatLogic.OnQuitCorps();
	LobbyChatEntranceUI.OnQuitCorps();
end

function LobbyChatSystem.SendCorpsRecruit()
	EventCorpsClose();
	LobbyChatEntranceUI.OpenChatUI();
	
end
function LobbyChatSystem.ChangeTickBuffer()
	if #LobbyChatSystem.chatBufferList > LobbyChatSystem.MAX_MESSAGE_BUFFER_CACHE_NUM then
		for i = LobbyChatSystem.MAX_MESSAGE_BUFFER_CACHE_NUM + 1, #LobbyChatSystem.chatBufferList do
			table.remove(LobbyChatSystem.chatBufferList, 1);
		end
	end
	
	if #LobbyChatSystem.chatRoomBufferList > LobbyChatSystem.MAX_MESSAGE_BUFFER_CACHE_NUM then
		for i = LobbyChatSystem.MAX_MESSAGE_BUFFER_CACHE_NUM + 1, #LobbyChatSystem.chatRoomBufferList do
			table.remove(LobbyChatSystem.chatRoomBufferList, 1);
		end
	end
	
	if #LobbyChatSystem.chatFriendBufferList > LobbyChatSystem.MAX_MESSAGE_BUFFER_CACHE_NUM then
		for i = LobbyChatSystem.MAX_MESSAGE_BUFFER_CACHE_NUM + 1, #LobbyChatSystem.chatFriendBufferList do
			table.remove(LobbyChatSystem.chatFriendBufferList, 1);
		end
	end
	LobbyChatEntranceUI.RefreshTickBufferState();	
end

local cnt = 0;
function LobbyChatSystem.PopBufferList()
	if (nil == LobbyChatSystem.chatBufferList or 0 == #LobbyChatSystem.chatBufferList) and
	   (nil == LobbyChatSystem.chatRoomBufferList or 0 == #LobbyChatSystem.chatRoomBufferList) and
	   (nil == LobbyChatSystem.chatFriendBufferList or 0 == #LobbyChatSystem.chatFriendBufferList) then
		LobbyChatSystem.ChangeTickBuffer();
		return;
	end
	--log("print addmsgCd"..LobbyChatLogic.addMsgCd);

	--log("print pass:"..pass);
	if nil ~= LobbyChatSystem.chatBufferList and #LobbyChatSystem.chatBufferList > 0 then
			local bufferData = LobbyChatSystem.chatBufferList[1];
			--log("LobbyChatSystem.PopBufferList:",bufferData.chat_content.text);
		LobbyChatSystem.chat_true_notify(bufferData.chat_type, bufferData.sender_name, bufferData.msg_id, bufferData.chat_content, bufferData.sender_uid, bufferData.zone_id, bufferData.roleNation, bufferData.is_extend);
		table.remove(LobbyChatSystem.chatBufferList, 1);
	end
	if nil ~= LobbyChatSystem.chatRoomBufferList and #LobbyChatSystem.chatRoomBufferList > 0 then
		local bufferData = LobbyChatSystem.chatRoomBufferList[1];
		LobbyChatSystem.chat_true_notify(bufferData.chat_type, bufferData.sender_name, bufferData.msg_id, bufferData.chat_content, bufferData.sender_uid, bufferData.zone_id, bufferData.roleNation, bufferData.is_extend);
		table.remove(LobbyChatSystem.chatRoomBufferList, 1);
	end
	
	if nil ~= LobbyChatSystem.chatFriendBufferList and #LobbyChatSystem.chatFriendBufferList > 0 then
		local bufferData = LobbyChatSystem.chatFriendBufferList[1];
		LobbyChatSystem.chat_true_notify(bufferData.chat_type, bufferData.sender_name, bufferData.msg_id, bufferData.chat_content, bufferData.sender_uid, bufferData.zone_id, bufferData.roleNation, bufferData.is_extend);
		table.remove(LobbyChatSystem.chatFriendBufferList, 1);
	end
end

function LobbyChatSystem.ReplaceEmoji(chat_ctt)
	local ctt = chat_ctt;

	-- 在每个表情后添加 &nbsp; 来解决表情无法换行问题
	-- utf8.char(160)即为 &nbsp;
	local SpecialCharacter = utf8.char(160)

	for emoji in string.gmatch(chat_ctt, "%%%d+") do
		local num = string.match(emoji, "%d+");
		if string.len(num) >= 3 then
			num = string.sub(num, 1, 2);
		end
		
		local no = tonumber(num);
		if no < 1 then
			;
		elseif no > 64 then
			num = tostring(math.floor(no / 10));
			ctt = string.gsub(ctt, "%%" .. num, "<img src=\"Emoji1_22_" .. num .. "\"/>" .. SpecialCharacter, 1);
			--ctt = string.gsub(ctt, "%%" .. num, "<img src=\"Emoji1_22_".. num .."\"/>‬", 1)
		else
			ctt = string.gsub(ctt, "%%" .. no, "<img src=\"Emoji1_22_" .. num .. "\"/>" .. SpecialCharacter, 1);
			--ctt = string.gsub(ctt, "%%" .. no, "<img src=\"Emoji1_22_".. num .."\"/>‬", 1)
		end
	end

	----若连续的表情超过10个则换行
	--local pattern={}
	--table.insert(pattern,"(")
	--for i = 1, 10 do
	--	table.insert(pattern,"<img src=\"Emoji1_22_%d+\"/>")
	--end
	--table.insert(pattern,")")
	--local patternStr = table.concat(pattern)
	--ctt = string.gsub(ctt, patternStr,"%1\r")
	--
	----若表情前超过20个字符则换行
	--local pos = 1
	--local len = #ctt
	--local patternStr = "<img src=\"Emoji1_22_(%d+)\"/>"
	--local bg = 0
	--local lastbg = 0
	--local res = {}
	--while bg <= len do
	--	bg = string.find(ctt, patternStr, pos)
	--	if not bg then
	--		table.insert(res, string.sub(ctt, lastbg, len))
	--		break
	--	end
	--	table.insert(res, string.sub(ctt, lastbg, bg - 1))
	--	if bg - pos > 20 then
	--		table.insert(res, "\r")
	--	end
	--	lastbg = bg
	--	pos = bg + #patternStr
	--end
	--ctt = table.concat(res)

	return ctt;
end

function LobbyChatSystem.on_report_req(uid, name, content)
	local fmtMsg = Client.GetTableData("LocalizeRes", 106069);
	local str = string.format(fmtMsg.TextValue, name);

	ChatReport.ShowPanel(str, 
		function(reason)
			local securityLog = {};
			securityLog.ReportRoleID = tonumber(uid);
			securityLog.UserName = name;
			securityLog.ComplaintType2 = 2;
			securityLog.ComplaintType = reason;
	
			NetUtil.SendPkg("report_info", securityLog);
		end
	);	
end

function LobbyChatSystem.on_report_rsp(res)
	log("on_report_rsp");
	if res == 510001 then
		PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", 4715).TextValue);
	else
		local curStatus = string.lower(LuaClassObj.GetGameStatus(bp_lobby));
		if curStatus == "lobby" then
			PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", 117066).TextValue);
		end
	end
end

function LobbyChatSystem.ProfileCallBack(profile_list)
	if nil == profile_list or 0 == #profile_list then
		return;
	end
	
	for i = 1, #profile_list do 
		local dat = profile_list[i];
		local profileData = {};
		profileData.gid = tostring(math.floor(dat.uid));
		profileData.url = dat.picUrl;
		profileData.nickName = dat.nickName;
		profileData.gender = dat.sex;		
		profileData.level = dat.level;
        
        ----------------------------------------intl modify--------------------------------------
        --[[
		profileData.segmentSolo = dat.segment_info[1];
		profileData.segmentDuo = dat.segment_info[2];
		profileData.segmentSquad = dat.segment_info[3];
		profileData.segmentMax = math.max(profileData.segmentSolo, profileData.segmentDuo, profileData.segmentSquad);
        ]]
        --waynedong todo  check
        -- 取全区最高的段位设置当前段位（最终是用到蓝图中设置称号用的，因此只需要取所有区中最高段位的一个保存即可）
        all_segment_info = dat.segment_info;
        --[[
        maxSegment = -1;
        for k,v in pairs(all_segment_info) do
            local segemnt_solo = all_segment_info[k][1];
            local segemnt_duo =  all_segment_info[k][2];
            local segemnt_squad =  all_segment_info[k][3];
            --log("chatwaynedong: segemnt_solo = "..segemnt_solo..", segemnt_duo = "..segemnt_duo..", segemnt_squad = "..segemnt_squad)
            local tmpmax = math.max(segemnt_solo, segemnt_duo, segemnt_squad);
            if maxSegment < tmpmax then
                maxSegment = tmpmax;
                profileData.segment_info_solo = segemnt_solo;
                profileData.segment_info_duo = segemnt_duo;
                profileData.segment_info_squad = segemnt_squad;
            end
             log("chatwaynedong:profileData.segment_info_solo = "..profileData.segment_info_solo..", profileData.segment_info_duo = "..profileData.segment_info_duo..", profileData.segment_info_squad = "..profileData.segment_info_squad)
        end
        ]]
        profileData.segment_info_solo,  profileData.segment_info_duo,  profileData.segment_info_squad =  FuncUtil.GetMaxSegement( all_segment_info );
        profileData.segmentMax = math.max(profileData.segment_info_solo, profileData.segment_info_duo, profileData.segment_info_squad);
        ----------------------------------------intl modify--------------------------------------
		profileData.avatarBox = dat.cur_avatar_box_id;
		profileData.upassIsBuy, profileData.upassShow = LobbyChatSystem.ParseUpassInfo(dat.upass);
		profileData.roleNation = dat.nation;
		profileData.aliasId = dat.alias.id;
		profileData.aliasTitle = dat.alias.title;
		profileData.aliasNation = dat.alias.nation;
		--log(string.format("yyc, ProfileCallBack case, upassIsBuy = %s , upassShow = %s ", profileData.upassIsBuy, profileData.upassShow));
		LobbyChatLogic.RefreshProfileData(profileData);
	end
end

function LobbyChatSystem.on_profile_req(uid)
	--log("get profile in chat " .. uid);
	ProfileMgr.GetProfile(tonumber(uid), LobbyChatSystem.ProfileCallBack, false);
	--NetUtil.SendPkg("batch_get_profile_req", "", {tonumber(uid)}, "chat");
end

function LobbyChatSystem.on_profile_rsp(listType, res, role_basic_info_list, systemType)
	if "chat" ~= systemType then		
		return;
	end
end

function LobbyChatSystem.on_chat_corps_recruit()
	if false == CorpsMgr.IsInCorps() then
		return;
	end
	
	if nil == DataMgr.corpsInfo then
		return;
	end
	
	if 0 == DataMgr.corpsInfo.id or 0 == #DataMgr.corpsInfo.corpsMemberList or 0 == DataMgr.corpsInfo.level then
		return;
	end
		
	--log_tree("LobbyChatSystem.on_chat_corps_recruit", DataMgr.corpsInfo);
	
	local corpsData = {};
	corpsData.corpsId = tostring(DataMgr.corpsInfo.id);
	corpsData.corpsLevel = DataMgr.corpsInfo.level;
	corpsData.corpsCity = "";
	corpsData.corpsName = DataMgr.corpsInfo.name;
	
	local cityCfg = Client.GetTableData("SocialCardCity", DataMgr.corpsInfo.city);
	if nil ~= cityCfg then
		corpsData.corpsCity = cityCfg.City2;		
	end
	
	if "" == corpsData.corpsCity then
		corpsData.corpsCity = "--";
	end
	
	local maxMember = DataMgr.corpsInfo.memberNum;
	local corpsCfg = Client.GetTableData("CorpsLevel", corpsData.corpsLevel);
	if nil ~= corpsCfg then
		maxMember = corpsCfg.MemberLimit;
	end
	
	corpsData.corpsMember = tostring(DataMgr.corpsInfo.memberNum) .. " / " .. tostring(maxMember);
	
	corpsData.corpsLimitLevel = DataMgr.corpsInfo.joinLevel;
	corpsData.corpsLimitSegment = DataMgr.corpsInfo.joinSegment;	
	corpsData.corpsIcon = DataMgr.corpsInfo.icon;
	
	local tabContent = {};
	tabContent.voice = "";
	tabContent.text = "";
	tabContent.voiceLength = 0;
	tabContent.quickMsg = true;
	tabContent.msgType = 2;
	tabContent.corpsInfo = corpsData;
	--tabContent.clientMsgType = 2;
	
	--NetUtil.SendPkg("corps_recruit", tabContent, true, false, false);
	
	--[[
	local corpsData = {};
	
	local corpsData = DataMgr.corpsInfo;
	corpsData.corpsMemberList = {};	]]
end

function LobbyChatSystem.on_chat_corps_recruit_rsp(res, surplus)
	if "ok" == res then
		ShowNotice(410076)
	elseif "not_has_corps" == res then
		DataMgr.ShowNoticeByID(411008);
	elseif "request_frequent" == res then		
		local msg = string.format(Client.GetTableData("LocalizeRes", 100007).TextValue, surplus);
		PopUpNoticeUI.ShowNewNotice(msg);		
	end
end
--[[
	receiver_uid (number)
]]

function LobbyChatSystem.on_chat_quick_msg(content)
	--log("on_chat_quick_msg,content:"..content);
	if nil == content or "" == content then
		return;
	end
		
	--log("LobbyChatSystem.on_chat_quick_msg:"..content);
	local tabContent = {};
	tabContent.voice = "";
	--快捷聊天不过滤 _, _, tabContent.text = FuncUtil:CheckName(content);
	tabContent.text = content;
	tabContent.voiceLength = 0;	
	tabContent.quickMsg = true;
	tabContent.msgType = 0;	
	tabContent.msgID = content;
	--log("LobbyChatSystem.on_chat_quick_msg:"..tabContent.text);
	local msgId = LobbyChatSystem.CacheMsg(tabContent);
	NetUtil.SendPkg("chat_req", 0, LobbyChatSystem.channelTeam, msgId, tabContent);
end

function LobbyChatSystem.CacheMsg(tabContent)
	LobbyChatSystem.msgIdGuid = LobbyChatSystem.msgIdGuid + 1;
	LobbyChatSystem.msgContentCacheMap[LobbyChatSystem.msgIdGuid] = tabContent;
	return LobbyChatSystem.msgIdGuid;
end

function LobbyChatSystem.on_chat_req(receiver_uid, channelType, content, topicId, selectPlayer, topicList, other, msgType)
	if nil == content or "" == content then
		return;
	end		
	
	local tabContent = {};
	tabContent.voice = "";
	--_, _, tabContent.text = FuncUtil:CheckName(content);
	tabContent.text = content;
	tabContent.voiceLength = 0;	
	tabContent.quickMsg = false;
	tabContent.msgType = msgType or 0;
	tabContent.topic = "";
	tabContent.selectPlayer = {};
	tabContent.topicList = {};
	tabContent.other = other;

	if topicId ~= nil and topicId ~= "" then
		tabContent.topic = topicId;
	end
	if selectPlayer ~= nil then
		tabContent.selectPlayer = selectPlayer;
	end
	if topicList ~= nil then
		tabContent.topicList = topicList;
	end
	--log_tree("zinotest tabContent",tabContent)
	sandbox.LogNormal(tostring(channelType) .. "send chat req" .. tabContent.text);
	
	local msgId = LobbyChatSystem.CacheMsg(tabContent);

	if  channelType == LobbyChatSystem.channelPrivate then
		if 0 ~= receiver_uid then
			local isFriend = FriendSystem.IsMyFriend(receiver_uid);
			if isFriend then
				NetUtil.SendPkg("chat_req", receiver_uid, channelType, msgId, tabContent);
			else
				PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", 106020).TextValue);
			end			
		end
	else
		sandbox.LogNormal(tostring(channelType) .. "send chat req" .. content);
		if channelType == LobbyChatSystem.channelChatRoom then
			NetUtil.SendPkg("chat_req", receiver_uid, channelType, msgId, tabContent);
		else
			NetUtil.SendPkg("chat_req", 0, channelType, msgId, tabContent);
		end
	end
end

function LobbyChatSystem.on_voice_chat_req(receiver_uid, channel_type, voice_id, msg_time, content, topicId)
	if nil == voice_id or "" == voice_id then
		return;
	end
	
	local tabContent = {};
	tabContent.voice = voice_id;
	--_, _, tabContent.text = FuncUtil:CheckName(content);
	tabContent.text = content;
	tabContent.voiceLength = msg_time;
	tabContent.quickMsg = false;
	tabContent.msgType = 0;
	tabContent.topic = topicId;
	
	local msgId = LobbyChatSystem.CacheMsg(tabContent);--缓存消息

	if channel_type == LobbyChatSystem.channelPrivate then
		sandbox.LogNormal("send voice chat req with msgId " .. voice_id .. " to " .. tostring(receiver_uid) .. content);
		
		NetUtil.SendPkg("chat_req", receiver_uid, channel_type, msgId, tabContent);
	else
		sandbox.LogNormal("send voice chat req with msgId " .. voice_id .. content);
		
		if channel_type == LobbyChatSystem.channelChatRoom then
			sandbox.LogNormal("send voice chat req with msgId to chatroom " .. tostring(receiver_uid) .. voice_id .. content);
			NetUtil.SendPkg("chat_req", receiver_uid, channel_type, msgId, tabContent);
		else
			NetUtil.SendPkg("chat_req", 0, channel_type, msgId, tabContent);
		end
	end
end

function LobbyChatSystem.on_clear_msg(gid)
	local strGid = tostring(gid);
	for i = #LobbyChatSystem.chatBufferList, 1, -1 do
		local chatBuffer = LobbyChatSystem.chatBufferList[i];
		if chatBuffer.sender_uid == strGid then
			table.remove(LobbyChatSystem.chatBufferList, i);
		end
	end
	
	for i = #LobbyChatSystem.chatRoomBufferList, 1, -1 do
		local chatBuffer = LobbyChatSystem.chatRoomBufferList[i];
		if chatBuffer.sender_uid == strGid then
			table.remove(LobbyChatSystem.chatRoomBufferList, i);
		end
	end
	
	for i = #LobbyChatSystem.chatFriendBufferList, 1, -1 do
		local chatBuffer = LobbyChatSystem.chatFriendBufferList[i];
		if chatBuffer.sender_uid == strGid then
			table.remove(LobbyChatSystem.chatFriendBufferList, i);
		end
	end
	
	if DataMgr.roleData.uid == strGid then
		LobbyChatSystem.friendChatList = {};
		LobbyChatSystem.RefreshTotalUnread();
	else	
		LobbyChatSystem.DeleteFriend(gid);
	end
	
	LobbyChatLogic.ClearSomeonesMsg(strGid);
	LobbyChatEntranceUI.ClearSomeonesMsg(strGid);
end

--[[
聊天消息发送回包
surplus 聊天频率限制，表示还剩下多少秒的限制
chat_content,要么为空，要么是一个string
]]
function LobbyChatSystem.on_chat_rsp(res, msg_id, chat_type, surplus, receiver_gid, chat_content)
	--log_tree("LobbyChatSystem.on_chat_rsp ", chat_content);
	local tabContent = LobbyChatSystem.msgContentCacheMap[msg_id]; --自己收到自己发送的消息，如果没有敏感词需要过滤的情况下不再发送chat_content，节省下行流量
	LobbyChatSystem.msgContentCacheMap[msg_id] = nil;

	if res == "chat-banned" then
        --receiver_gid = reason chat_content = surplus_time
        local time = chat_content;
        --local date = os.date("%Y年%m月%d日%H时%M分%S秒", time);
		local date = os.date(Client.GetTableData("LocalizeRes",115005).TextValue, time);
        --CommonMessageBoxUI:ShowPanel(1, "提示", reason.."\n解封时间为: "..date);
		local str = string.format(Client.GetTableData("LocalizeRes",301143).TextValue, tostring(date));
    	local promptTip = FuncUtil.GetLocalizeResStr("101001");
        --CommonMessageBoxUI:ShowPanel(1, promptTip, receiver_gid.."\n解封时间为: "..date);
        if nil == receiver_gid or "" == receiver_gid then
        	receiver_gid = "0";
        end
        CommonMessageBoxUI:ShowPanel(1, promptTip, receiver_gid..str);
        return;
    end

	local strGid = "";
	if nil ~= receiver_gid and "" ~= receiver_gid then
		if type(receiver_gid) == "string" then
			strGid = receiver_gid;
		else
			local gid = math.floor(receiver_gid);
			strGid = tostring(gid);
		end
	end			
	
	if res == "ok" then		
		if chat_type == LobbyChatSystem.channelTeamRecruit then --如果是组队招募，则不再此处理了
			return
		end

		if nil ~= chat_content and "" ~= chat_content then
    		tabContent.text = chat_content;
    		--log("LobbyChatSystem.on_chat_rsp replace");
    	end

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
		--log("LobbyChatSystem.on_chat_rsp"..chat_ctt);
		chat_ctt = LobbyChatSystem.ReplaceEmoji(chat_ctt);
		--log("LobbyChatSystem.on_chat_rsp"..chat_ctt);
		--sandbox.LogNormal("send chat message success" .. chat_ctt);
		
		local sender_name = DataMgr.roleData.nickName;
		local sender_uid = DataMgr.roleData.uid;			
		local msg_type = tabContent.msgType;
		if tabContent.other ~= nil and tabContent.other.msg_type ~= nil then
			msg_type = tabContent.other.msg_type;
		end
        local nation = ProfileMgr.GetRoleNationByUid(sender_uid);
        local topic = tabContent.topic;
        local other = tabContent.other;
		local avatarData = LobbyChatLogic.GetHeadData(sender_uid)
		
		if 0 == msg_type then
			LobbyChatLogic.OnSendMsgSuccess(voice_file);
			
			if chat_type == LobbyChatSystem.channelTeam and "" == voice_file then
				TeamUpUI.OnQuickMsg(sender_uid, chat_ctt);
			end
			
			if chat_type == LobbyChatSystem.channelPrivate then
				LobbyChatSystem.on_friend_msg(strGid, DataMgr.roleData.uid, sender_name, voice_file, voice_time, chat_ctt, true, nation, nil, avatarData);
			else
				local avatarData = LobbyChatLogic.GetHeadData(sender_uid)
				LobbyChatLogic.AddNewChat(chat_type, msg_type, sender_name, voice_file, voice_time, chat_ctt, sender_uid, true, "", "", "", nation, 0, topic, nil, avatarData);
				LobbyChatEntranceUI.ReceiveNewMsg(chat_type, msg_type, sender_name, voice_file, voice_time, chat_ctt, "", true);
			end
		elseif 1 == msg_type then
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
			-- 小古在这加队伍Id
			--local team_id = time_left;
			--LobbyChatLogic.AddNewChat(LobbyChatSystem.channelTeamRecruit, msg_type, sender_name, voice_file, voice_time, chat_ctt, sender_uid, true, team_id, "", "", nation);
			--LobbyChatEntranceUI.ReceiveNewMsg(chat_type, msg_type, sender_name, voice_file, voice_time, chat_ctt);
		--end
		elseif 2 == msg_type then		
			LobbyChatLogic.AddCorpsRecruit(chat_type, 2, sender_uid, sender_name, true, tabContent.corpsInfo);
			--log_tree("tabContent.corpsInfo ", tabContent.corpsInfo);			
			LobbyChatEntranceUI.ReceiveNewMsg(chat_type, 2, sender_name, voice_file, voice_time, tabContent.corpsInfo.corpsName, "", true);
		elseif 14 == msg_type then		--成就分享
			local achievement = AchievementDetailUI.MakeSingleDetailData(other.achievementId);
			achievement.finish_time = other.finish_time;
			if chat_type == LobbyChatSystem.channelPrivate then

				LobbyChatSystem.on_friend_msg(strGid, DataMgr.roleData.uid, sender_name, voice_file, voice_time, chat_ctt, true, nation, achievement, avatarData);
			else
				local avatarData = LobbyChatLogic.GetHeadData(sender_uid)
				LobbyChatLogic.AddNewChat(chat_type, msg_type, sender_name, voice_file, voice_time, chat_ctt, sender_uid, true, "", "", "", nation, 0, topic, achievement, avatarData);
				LobbyChatEntranceUI.ReceiveNewMsg(chat_type, msg_type, sender_name, voice_file, voice_time, chat_ctt, "", true, achievement, avatarData);
			end
		elseif LobbyChatSystem.bargainMessageType == msg_type then	-- 砍价分享
			--log("[HHF]LobbyChatSystem.on_chat_rsp, received chat_rsp, res = " .. tostring(res) ..
			--	", msg_id = " .. tostring(msg_id) ..
			--	", chat_type = " .. tostring(chat_type) ..
			--	", surplus = " .. tostring(surplus) .. 
			--	", receiver_gid = " .. tostring(receiver_gid));
			other.description = Bargain_Detail_UI.GetDescForChat(other.channel, other.item_id, other.ori_price, other.description);
			--log_tree("[HHFTEST]LobbyChatSystem.on_chat_rsp, received chat_rsp, other = ", other, "[HHFTEST]");
			if chat_type == LobbyChatSystem.channelPrivate then
				--已废弃拼多多好友消息
				--LobbyChatSystem.on_friend_msg(strGid, DataMgr.roleData.uid, sender_name, voice_file, voice_time, chat_ctt, true, nation, other);
				--Bargain_Detail_UI.OnSendFriendSuccess(receiver_gid);
			elseif chat_type == LobbyChatSystem.channelCorpsBargain then
				local avatarData = LobbyChatLogic.GetHeadData(sender_uid)
				LobbyChatLogic.AddNewChat(chat_type, msg_type, sender_name, voice_file, voice_time, chat_ctt, sender_uid, true, "", "", "", nation, 0, topic, other, avatarData);
				--LobbyChatEntranceUI.ReceiveNewMsg(chat_type, msg_type, sender_name, voice_file, voice_time, chat_ctt, "", true, other);
				
				Bargain_Detail_UI.OnSendFriendSuccess(DataMgr.corpsInfo.id);
			end
		end
	elseif res == "chat_busy" then		
		PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", 106012).TextValue);
	elseif res == "chat_frequent" then
		--sandbox.LogNormal("chat response error = " ..res);
		msgContent = string.format(Client.GetTableData("LocalizeRes", 100007).TextValue, surplus);
		sandbox.LogNormal(msgContent);
		PopUpNoticeUI.ShowNewNotice(msgContent);
	elseif res == "no-corps" then
		local tips = FuncUtil.GetLocalizeResStr(5085);
		PopUpNoticeUI.ShowNewNotice(tips);
	end
end

--[[
收到聊天消息的通知回包
]]

function LobbyChatSystem.chat_merge_notify(merge_world_chat)
	--zinotag chat_merge_notify收到聊天消息的通知回包
	--log_tree("[HHF]LobbyChatSystem.chat_merge_notify, merge_world_chat = ", merge_world_chat, "[HHF]");
	if nil == merge_world_chat or #merge_world_chat == 0 then
		--log("empty merge list");
		return;
	end

	for i = 1, #merge_world_chat do
		local chatData = merge_world_chat[i];
		-- log_tree("zino chatdata ",merge_world_chat[i])
		local msg = {};
		msg.chat_type = chatData.chat_type;
		msg.sender_name = chatData.sender_name;
		msg.msg_id = chatData.msg_id;
		msg.chat_content = chatData.chat_content;
		msg.sender_uid = chatData.send_uid;
		msg.zone_id = chatData.zone_id;
		msg.roleNation = chatData.nation;
		-- 第二语言判断
		if nil ~= merge_world_chat.is_extend then
			msg.is_extend = chatData.send_uid
		end
		table.insert(LobbyChatSystem.chatBufferList, msg)
	end

	LobbyChatSystem.ChangeTickBuffer();
end

function LobbyChatSystem.chat_true_notify(chat_type, sender_name, msg_id, chat_content, sender_uid, zone_id, nation, is_extend)
	--[[
		chat_content所包含字段以及定义
		前台透传
		chat_content.team_id 组队ID
		chat_content.client_ver 版本号
		chat_content.game_model_type --天命圈还是经典
	]]
	--log("chat_type...." .. chat_type);
	--log_tree("LobbyChatSystem.chat_true_notify", chat_content);
	if nil == sender_uid or "" == sender_uid then
		return;
	end
	
	local strGid = "";
	if type("sender_uid") == "string" then
		strGid = sender_uid;
	else
		local gid = math.floor(sender_uid);
		strGid = tostring(gid);
	end	
	
	if tonumber(strGid) == tonumber(DataMgr.roleData.uid) then
		--log("receive chat from me");
		return;
	end;
		
	if FriendSystem.IsPulBlack(strGid) then
		return;
	end
	local avatarData = LobbyChatLogic.GetHeadData(sender_uid,sender_name,nation,chat_content)
	local voice_file = "";
	local voice_time = 0;
	local chat_ctt = chat_content.text;
	local voiceType = chat_content.VoiceType;
	local other = chat_content.other;

	if true == chat_content.quickMsg then
		--log("LobbyChatSystem.on_chat_rsp,chat_content.quickMsg:" .. tostring(chat_content.quickMsg));
		chat_ctt = Client.GetTableData("LocalizeRes", chat_content.text).TextValue;
	end

	if nil ~= chat_content.voice and "" ~= chat_content.voice then
		voice_time = chat_content.voiceLength;
		voice_file = chat_content.voice;
	end
	
	chat_ctt = LobbyChatSystem.ReplaceEmoji(chat_ctt);
	
	if chat_type == LobbyChatSystem.channelTeam and "" == voice_file then
		--log("LobbyChatSystem.chat_true_notify!!!"..chat_ctt);
		TeamUpUI.OnQuickMsg(strGid, chat_ctt);
	end
		
	--sandbox.LogNormal("receive msg from :"..sender_name .. "  chat type " .. tostring(chat_type) .. " says: "..chat_ctt);		
	
	local msg_type = chat_content.msgType;
	if other ~= nil and other.msg_type ~= nil then
		msg_type = other.msg_type;
	end
	local topic = chat_content.topic;
	--local msg_type = 1;
	if 0 == msg_type then
		if chat_type == LobbyChatSystem.channelPrivate then
			LobbyChatSystem.on_friend_msg(strGid, strGid, sender_name, voice_file, voice_time, chat_ctt, false, nation, nil, avatarData);
		else
			LobbyChatLogic.AddNewChat(chat_type, msg_type, sender_name, voice_file, voice_time, chat_ctt, strGid, false, "", "", "", nation, voiceType, topic,nil, avatarData);
		end
				
		LobbyChatEntranceUI.ReceiveNewMsg(chat_type, msg_type, sender_name, voice_file, voice_time, chat_ctt, "", false);
	elseif LobbyChatSystem.teamRecruitMsgType == msg_type then	-- 组队招募消息 只有世界、聊天室和语种频道
		if chat_type ~= LobbyChatSystem.channelPrivate and chat_type ~= LobbyChatSystem.channelTeam then
			
			--不是好友才进行过滤，好友不过滤
			local isFriend = FriendSystem.IsMyFriend(strGid);
			if isFriend == false then 
				--log_tree("ddddddddddddddddddd other",chat_content);
				if chat_content.client_ver ~= nil then
					local isMatch = FuncUtil:IsMatchVersion(chat_content.client_ver);
					if isMatch == false then
						--如果版本不匹配，则不要在世界聊天显示，前台过滤
						--log("vertion is not same");
						return;
					end
				end	
			end

			-- 玩家设置了只接收相同语言,过滤掉其他语言的组队招募
			if is_extend and true == BP_RecruitSameLanguageState then
				return;
			end

			-- 小古在这加队伍Id
			local team_id = chat_content.team_id;
			local game_model_type = chat_content.game_model_type;
			local map_data = chat_content.team_recuit_map_data;
			if map_data then
				for index,id in pairs(map_data) do
                    if id ~= 0 then
                        local infoConfig = Client.GetTableData("ModeTeamTable", id);
                        if nil == infoConfig then
                            return;		-- 没有相关的模式，不接受消息
                        end
                    end
				end
			end
			--log("chatTeamID"..team_id);
			LobbyChatLogic.AddNewChat(chat_type, msg_type, sender_name, voice_file, voice_time, chat_ctt, strGid, false, team_id, zone_id, game_model_type, nation, voiceType, topic,nil, avatarData, map_data);
			LobbyChatEntranceUI.ReceiveNewMsg(chat_type, msg_type, sender_name, voice_file, voice_time, chat_ctt, zone_id, false);
		end
	elseif LobbyChatSystem.corpsRecruitMsgType == msg_type then	-- 军团招募消息
		LobbyChatLogic.AddCorpsRecruit(chat_type, 2, sender_uid, sender_name, false, chat_content.corpsInfo);
		chat_ctt = chat_content.corpsInfo.corpsName;
		LobbyChatEntranceUI.ReceiveNewMsg(chat_type, 2, sender_name, voice_file, voice_time, chat_ctt, "", false);
	elseif LobbyChatSystem.roomRecruitMsgType == msg_type then	-- 房间招募,只有招募频道可见
		local room_id = chat_content.room_id;
		local map_id = chat_content.map_id;		
		local game_model_type = chat_content.game_model_type;
		local player_num = chat_content.player_num;
		local max_player_num = chat_content.max_player_num;
		chat_content = RoomUpSystem.CombineRoomRecruitMsg(map_id, player_num, max_player_num);	-- 房间招募拼接消息
		LobbyChatLogic.AddNewChat(chat_type, msg_type, sender_name, voice_file, voice_time, chat_content, strGid, false, room_id, zone_id, game_model_type, nation, voiceType, topic,nil, avatarData);
		LobbyChatEntranceUI.ReceiveNewMsg(chat_type, msg_type, sender_name, voice_file, voice_time, "", "", false);
	elseif 14 == msg_type then	--成就分享
		local achievement = AchievementDetailUI.MakeSingleDetailData(other.achievementId);
		achievement.finish_time = other.finish_time;
		if chat_type == LobbyChatSystem.channelPrivate then
			LobbyChatSystem.on_friend_msg(strGid, strGid, sender_name, voice_file, voice_time, chat_ctt, false, nation, achievement, avatarData);
		else
			LobbyChatLogic.AddNewChat(chat_type, msg_type, sender_name, voice_file, voice_time, chat_ctt, strGid, false, "", "", "", nation, voiceType, topic, achievement, avatarData);
		end
				
		LobbyChatEntranceUI.ReceiveNewMsg(chat_type, msg_type, sender_name, voice_file, voice_time, chat_ctt, "", false);
	elseif LobbyChatSystem.bargainMessageType == msg_type then	-- 砍价分享
		--log("[HHF]LobbyChatSystem.chat_true_notify, received chat_notify, chat_type = " .. tostring(chat_type) ..
		--	", sender_name = " .. tostring(sender_name) ..
		--	", msg_id = " .. tostring(msg_id) ..
		--	", sender_uid = " .. tostring(sender_uid) .. 
		--	", zone_id = " .. tostring(zone_id) .. 
		--	", nation = " .. tostring(nation));
		other.have_bargained = PDD_System_UI.HaveBargainedByOrderID(other.cur_orderid);
		other.description = Bargain_Detail_UI.GetDescForChat(other.channel, other.item_id, other.ori_price, other.description);
		--log_tree("[HHFTEST]LobbyChatSystem.chat_true_notify, received chat_notify, chat_content = ", chat_content, "[HHFTEST]");
		if chat_type == LobbyChatSystem.channelPrivate then
			--拼多多好友消息已废弃
			--LobbyChatSystem.on_friend_msg(strGid, strGid, sender_name, voice_file, voice_time, chat_ctt, false, nation, other);
		elseif chat_type == LobbyChatSystem.channelCorpsBargain then
			LobbyChatLogic.AddNewChat(chat_type, msg_type, sender_name, voice_file, voice_time, chat_ctt, strGid, false, "", "", "", nation, voiceType, topic, other, avatarData);
		end
		--LobbyChatEntranceUI.ReceiveNewMsg(chat_type, msg_type, sender_name, voice_file, voice_time, chat_ctt, "", false);
	end	
end

function LobbyChatSystem.chat_notify(chat_type, sender_name, msg_id, chat_content, sender_uid, nation)
	log("LobbyChatSystem.chat_notify1:"..msg_id,"martinhtma")
	--log_tree("LobbyChatSystem.chat_notify chat_content ",chat_content)
	if nil == sender_uid or "" == sender_uid then
		return;
	end

	local strGid = "";
	if type("sender_uid") == "string" then
		strGid = sender_uid;
	else
		local gid = math.floor(sender_uid);
		strGid = tostring(gid);
	end

	if tonumber(strGid) == tonumber(DataMgr.roleData.uid) then
		--log("receive chat from me");
		return;
	end;

	if chat_type == LobbyChatSystem.channelCorpsBargain then
		Bargain_Logic.OnGetNewMessage();
	end

	-- 聊天室性能优化
	if chat_type == LobbyChatSystem.channelChatRoom then
		local thisClock = os.time();
		if thisClock - LobbyChatSystem.chatRoomLastMsgTime < 1.1 then
			LobbyChatSystem.chatRoomMsgCounter = LobbyChatSystem.chatRoomMsgCounter + 1;
			if LobbyChatSystem.chatRoomMsgMaxLimit <= LobbyChatSystem.chatRoomMsgCounter then
				--log("msg abandon" .. chat_content.text);
				return;
			end
			-- 进战斗就让消息过去，返回大厅在加载缓存的聊天室消息
			if false == LobbyChatSystem.chatEnterFight then
				-- 加到队列里
				local msg = {};
				msg.chat_type = chat_type;
				msg.sender_name = sender_name;
				msg.msg_id = msg_id;
				msg.chat_content = chat_content;
				msg.sender_uid = sender_uid;
                msg.roleNation = nation;
				table.insert(LobbyChatSystem.chatBufferList, msg);
				LobbyChatSystem.ChangeTickBuffer();
				return;
			end
		else
			LobbyChatSystem.chatRoomLastMsgTime = thisClock;
			LobbyChatSystem.chatRoomMsgCounter = 0;
		end
		LobbyChatSystem.chat_true_notify(chat_type, sender_name, msg_id, chat_content, sender_uid, -1, nation)
	elseif chat_type == LobbyChatSystem.channelCorps then
		local msg = {};
		msg.chat_type = chat_type;
		msg.sender_name = sender_name;
		msg.msg_id = msg_id;
		msg.chat_content = chat_content;
		msg.sender_uid = sender_uid;
		msg.zone_id = -1;
		msg.roleNation = nation;
		table.insert(LobbyChatSystem.chatBufferList, msg);
		LobbyChatSystem.ChangeTickBuffer();
	else
		LobbyChatSystem.chat_true_notify(chat_type, sender_name, msg_id, chat_content, sender_uid, -1, nation)
	end
end

--[[
	gid (string),
	sender_name (string),
	chat_content (string),
	self_msg (bool)
]]

function LobbyChatSystem.on_friend_msg(str_gid, str_sender_gid, sender_name, voice_file, voice_length, chat_content, self_msg, nation, other, avatarData)
	chatTodayDate = os.date("%Y-%m-%d");

	str_gid = FuncUtil:StrTrim(str_gid);

	local thisMsg = {};
	thisMsg.msgChannel = LobbyChatSystem.channelPrivate;
	if other ~= nil and other.msg_type ~= nil then
		thisMsg.msgType = other.msg_type;
	else
		thisMsg.msgType = LobbyChatSystem.chatMsgType;
	end
	thisMsg.uid = str_gid;
	thisMsg.name = sender_name;
	thisMsg.msg = chat_content;
	thisMsg.selfMsg = self_msg;
	thisMsg.voiceMsgId = voice_file;
	thisMsg.voiceMsgTime = voice_length;
	thisMsg.roomId = "";
	thisMsg.BP_STRUCT_AvatarData = avatarData;
	if other ~= nil then
		if thisMsg.msgType == LobbyChatSystem.bargainMessageType then
			thisMsg.BP_STRUCT_BargainHelpMessage = other;
		else
			thisMsg.BP_STRUCT_ShareAchievementInfo = other;
			thisMsg.BP_STRUCT_ShareAchievementInfo.owner_player_name = sender_name;
		end
	end

	LobbyChatSystem.chatNewestFriendChat = str_gid;

	LobbyChatSystem.STATIC_MESSAGE_COUNTER = LobbyChatSystem.STATIC_MESSAGE_COUNTER + 1;
	thisMsg.level = LobbyChatSystem.STATIC_MESSAGE_COUNTER;

	--国籍
	thisMsg.roleNation = nation;
	LobbyChatSystem.on_friend_lobby_msg(str_gid, str_sender_gid, thisMsg);
	if "" == voice_file then
		LobbyChatSystem.on_friend_fight_msg(str_gid, str_sender_gid, thisMsg);
	end;
end

function LobbyChatSystem.on_friend_lobby_msg(str_gid, str_sender_gid, thisMsg)
	--local refMsg = LobbyChatSystem.GetFriendChatItem(str_gid);
	local refMsg = LobbyChatSystem.friendChatList[str_gid];
	if nil == refMsg then
		refMsg = {};
		refMsg.gid = str_gid;
		refMsg.newMessageCount = 0;
		refMsg.lastMsgSendTime = 0;
		refMsg.messageList = { };
		--table.insert(LobbyChatSystem.friendChatList, refMsg);
		LobbyChatSystem.friendChatList[str_gid] = refMsg;
	end

	local thisTime = os.time();
	local diffTime = thisTime - refMsg.lastMsgSendTime;
	if diffTime > 300 then
		thisMsg.msgSendTime = os.date("%H:%M");
	else
		thisMsg.msgSendTime = "";
	end

	thisMsg.msgSendDate = os.date("%Y-%m-%d");

	refMsg.lastMsgSendTime = os.time();

	if ((BP_ChannelType == LobbyChatSystem.channelPrivate) and (FuncUtil:StrTrim(BP_SelectedFriendGID) == str_gid) and (true == LobbyChatSystem.chatWndOpen)) 
		or (DataMgr.roleData.uid == str_sender_gid) then
		refMsg.newMessageCount = 0;
	elseif (LobbyChatSystem.chatSelectedFriendInFight == str_gid) and (true == LobbyChatSystem.chatEnterFight) then
		refMsg.newMessageCount = 0;
	else
		refMsg.newMessageCount = refMsg.newMessageCount + 1;
	end

	if #refMsg.messageList >= LobbyChatSystem.MAX_FRIEND_MESSAGE_CACHE_NUM then
		table.remove(refMsg.messageList, 1);		

		if BP_ChannelType == LobbyChatSystem.channelPrivate
				and FuncUtil:StrTrim(BP_SelectedFriendGID) == str_gid
				and LobbyChatSystem.chatWndOpen then
			LobbyChatLogic.RemoveMsgById(0)
	end
		--log("friend count over size");
	end

	table.insert(refMsg.messageList, thisMsg);

	LobbyChatSystem.on_notify_friend_unread(str_gid, refMsg.newMessageCount);
	local profile = ProfileMgr.GetPlayerDataByUid(str_sender_gid)
	if profile then
		thisMsg.BP_STRUCT_AvatarData.MaxSegment = FuncUtil.GetCurMaxSegementLevel(profile.segment_info)
	end
	LobbyChatSystem.on_notify_friend_new_chat(thisMsg, str_gid, thisMsg.name, thisMsg.msg);
end

function LobbyChatSystem.on_friend_fight_msg(str_gid, str_sender_gid, thisMsg)
	if false == LobbyChatSystem.chatEnterFight then
		return;
	end

	local refMsg = LobbyChatSystem.fightFriendChatList[str_gid];
	if nil == refMsg then
		refMsg = {};
		refMsg.gid = str_gid;
		refMsg.newMessageCount = 0;
		refMsg.lastMsgSendTime = 0;
		refMsg.messageList = { };
		LobbyChatSystem.fightFriendChatList[str_gid] = refMsg;
	end

	if LobbyChatSystem.chatSelectedFriendInFight == str_gid then
		refMsg.newMessageCount = 0;
	else
		refMsg.newMessageCount = refMsg.newMessageCount + 1;
	end

	if #refMsg.messageList >= LobbyChatSystem.MAX_FRIEND_MESSAGE_CACHE_NUM then
		table.remove(refMsg.messageList, 1);		
		--log("friend count over size");
	end

	table.insert(refMsg.messageList, thisMsg);

	LobbyChatSystem.on_notify_fight_friend_unread(str_gid);
	LobbyChatSystem.on_notify_fight_friend_chat(str_gid, thisMsg);
end

--[[
	过滤接口
]]

function LobbyChatSystem.filter_text_req(text, context)
	if nil == text or "" == text then
		return;
	end

	if nil == context or "" == context then
		return;
	end

	NetUtil.SendPkg("filter_text_req", text, context);
end

function LobbyChatSystem.filter_text_rsp(filter_text, context)
	if nil == context or "" == context then
		return;
	end
	log("filter_text_rsp filter_text, context:" ..filter_text .. context)
	IngameChat:on_filter_finish(filter_text, context);
end

--[[
	战斗内私聊接口
]]
function LobbyChatSystem.fight_send_msg(str_receiver_gid, content)
	LobbyChatSystem.on_chat_req(str_receiver_gid, LobbyChatSystem.channelPrivate, content, "");
end

function LobbyChatSystem.on_enter_fight_chat(str_gid)
	LobbyChatSystem.chatSelectedFriendInFight = str_gid;

	local refMsg = LobbyChatSystem.friendChatList[str_gid];
	if nil ~= refMsg then
		refMsg.newMessageCount = 0;
	end

	refMsg = LobbyChatSystem.fightFriendChatList[str_gid];
	if nil ~= refMsg then
		refMsg.newMessageCount = 0;
	end

	LobbyChatSystem.on_notify_fight_total_unread();
end

function LobbyChatSystem.on_quit_fight_chat()
	LobbyChatSystem.chatSelectedFriendInFight = "";
end

function LobbyChatSystem.on_notify_fight_friend_unread(str_gid, unread_count)
	LobbyChatSystem.on_notify_fight_total_unread();
	--[[ blablabla 刷新某个好友未读数量]]
end

function LobbyChatSystem.on_notify_fight_friend_chat(str_gid, this_msg)
	--[[
	消息格式
	thisMsg.msgChannel = LobbyChatSystem.channelPrivate;
	thisMsg.msgType = LobbyChatSystem.chatMsgType;
	thisMsg.uid = str_gid;
	thisMsg.name = sender_name;
	thisMsg.msg = chat_content;	
	thisMsg.selfMsg = self_msg;	
	thisMsg.voiceMsgId = voice_file;
	thisMsg.voiceMsgTime = voice_length;
	thisMsg.roomId = "";
	]]
	--[[ blablabla 通知战斗内新消息 ]]
	IngameChat:on_notify_fight_friend_chat(str_gid, this_msg);
end

function LobbyChatSystem.on_notify_fight_total_unread()
	local unreadCount = 0;
	for k, v in pairs(LobbyChatSystem.fightFriendChatList) do
		unreadCount = unreadCount + v.newMessageCount;
	end
	--[[ blablabla 刷新所有好友未读数量]]
end

--[[
	end of 战斗内私聊接口
]]

--[[
	预约相关
]]
function LobbyChatSystem.on_reserve_friend_req(str_gid)
	if nil == str_gid or "" == str_gid then
		return;
	end

	local reservingData = LobbyChatSystem.friendReservingList[str_gid];
	if nil == reservingData then
		--log("friend is reserved add reserving");
		local dat = {};
		dat.gid = str_gid;
		dat.time = os.time();
		LobbyChatSystem.friendReservingList[str_gid] = dat;
	else
		reservingData.time = os.time();
	end

	NetUtil.SendPkg("appointment_game_friend_req", tonumber(str_gid));
end

function LobbyChatSystem.on_clear_reserving(str_gid)
	LobbyChatSystem.friendReservingList[str_gid] = nil;
end

function LobbyChatSystem.on_reserve_require_notify(num_uid)
	local str_gid = tostring(num_uid);
	--log("on_reserve_require_notify " .. str_gid);
	--[[
		blablabla 处理战斗内预约相关
	]]

	local friendData = FriendSystem.GetFriendDataByGID(num_uid)
	if nil == friendData then
		return;
	end
	IngameChat:on_reserve_require_notify(str_gid, friendData.nickName);

	-- 测试：
	-- LobbyChatSystem.on_reserve_reply_req(str_gid, true);

	--LobbyChatSystem.on_reservation_from_lobby_notify(FriendSystem.GetFriendUidList());
end

--[[
	b_reply: true, false
]]
function LobbyChatSystem.on_reserve_reply_req(str_uid, b_reply)
	if nil == str_uid or "" == str_uid then
		--log("on_reserve_reply_req return" .. str_uid);
		return;
	end

	local reply = 0;
	if b_reply then
		reply = 1;
		ClientSendBAReport(BP_BA_LOBBY_RESERVATION, 1);	--1=同意
	else
		ClientSendBAReport(BP_BA_LOBBY_RESERVATION, 2);	--2=拒绝
	end

	--log("on_reserve_reply_req " .. str_uid);

	NetUtil.SendPkg("appointment_game_friend_answer", tonumber(str_uid), reply);
end

function LobbyChatSystem.IsReserved(str_gid)
	local contains = false;
	for i = 1, #LobbyChatSystem.friendReservedInFight do
		if LobbyChatSystem.friendReservedInFight[i] == str_gid then
			contains = true;
			break;
		end
	end

	return contains;
end

function LobbyChatSystem.on_reserve_reply_notify(num_uid, result)
	local str_gid = tostring(num_uid);
	--log("on_reserve_reply_notify " .. str_gid);

	local friendData = FriendSystem.GetFriendDataByGID(num_uid);
	-- 拼一下
	if nil == friendData then
		log("empty friend data when reserve _reply");
		return;
	end

	if 1 == result then
		--log("friend is reserved");
		local contains = LobbyChatSystem.IsReserved(str_gid);
		if false == contains then
			table.insert(LobbyChatSystem.friendReservedInFight, str_gid);
		end

		TeamUPFriendUI.OnFriendReserved(str_gid);
	end

	local msg = "";
	if 1 == result then
		msg = string.format(DataMgr.GetMsgByID(110110), friendData.nickName);
	else
		msg = string.format(DataMgr.GetMsgByID(110109), friendData.nickName);
	end

	CommonRightNotifyUI.ShowNotify(msg, nil);
end

function LobbyChatSystem.on_reserve_friend_game_end_notify(num_uid)
	local friendData = FriendSystem.GetFriendDataByGID(num_uid);
	if nil == friendData then
		log("empty friend data when reserve friend_game_end");
		return;
	end

	local index = 0;
	for i = 1, #LobbyChatSystem.friendReservedInFight do
		if tostring(num_uid) == LobbyChatSystem.friendReservedInFight[i] then
			index = i;
			break;
		end
	end

	if 0 ~= index then
		table.remove(LobbyChatSystem.friendReservedInFight, index);
	end

	local msg = string.format(DataMgr.GetMsgByID(110111), friendData.nickName);
	CommonRightNotifyUI.ShowNotify(msg, nil);
end

function LobbyChatSystem.on_reservation_from_lobby_notify(appointment_friend_list)
	--log("on_reservation_from_lobby_notify");
	local listLength = #appointment_friend_list;
	if 0 == listLength then
		log("on_reservation_from_lobby_notify empty list");
		return;
	end

	local friendsName = "";
	for i = 1, listLength do
		local friendData = FriendSystem.GetFriendDataByGID(appointment_friend_list[i]);
		if nil ~= friendData then
			--friendsName = friendsName .. string.format(DataMgr.GetMsgByID(110113), friendData.nickName);
			friendsName = friendsName .. friendData.nickName;
			if i ~= listLength then
				friendsName = friendsName .. ",";
			end
		end
	end

	--local msg = DataMgr.GetMsgByID(110112);
	--msg = msg .. friendsName;
	--msg = msg ..DataMgr.GetMsgByID(110114);
	local  msg = FuncUtil.LocalizeResFormat(4052, friendsName);
	CommonRightNotifyUI.ShowNotify(msg, nil);
end

--[[
	end of 预约相关
]]

--[[
	msg (msg struct)
	sender_uid (string)
	sender_name (string)
	msg_content (string)
]]
function LobbyChatSystem.on_notify_friend_new_chat(msg, sender_uid, sender_name, msg_content)
	LobbyChatLogic.NotifyFriendNewChat(msg, sender_uid, sender_name, msg_content)
end

--[[
	sender_uid (string),
	message_count (number)
]]
function LobbyChatSystem.on_notify_friend_unread(sender_uid, message_count)
	LobbyChatSystem.RefreshTotalUnread();
	LobbyChatLogic.RefreshUnreadList(sender_uid, message_count);
end

function LobbyChatSystem.on_teamup_info_changed(eventType, eventID, vars)

	if eventID == EVENTID_TEAMUP_TEAMINFO_SYNC then
		if nil ~= TeamUpSystem.TeamInfo then
			local isTeamup = false;
			if nil ~= TeamUpSystem.TeamInfo.player_count then
				isTeamup = TeamUpSystem.TeamInfo.player_count > 1;
			end

			LobbyChatLogic.SetIsTeamUp(isTeamup);
			LobbyChatEntranceUI.SetIsTeamUp(isTeamup);
			GlobalChatVoice.SetIsTeamup(isTeamup);
		end
	end

end

function LobbyChatSystem.on_backto_login(eventType, eventID, vars)
	if eventType ~= EVENTTYPE_LOGIN then
      return;
    end

	log("back to login");

	if eventID == EVENTID_BACKLOGIN then
		LobbyChatSystem.chatFriendBufferList = {};
		LobbyChatSystem.chatBufferList = {};
		LobbyChatSystem.chatRoomBufferList = {};
		LobbyChatSystem.friendChatList = {};
		LobbyChatLogic.chatRoomBufferList = {};
		LobbyChatLogic.chatRoomFightNewMsg = 0;
		LobbyChatLogic.chatCorpsBufferList = {};
		LobbyChatLogic.chatCorpsFightNewMsg = 0;
		GlobalChatVoice.ClearRoleInfo();
		LobbyChatLogic:Release();
		BP_ChatEntranceNewSender = "";
		BP_ChatEntranceNewMsg = "";
		BP_ChatEntranceNewChannel = 0;
		BP_ChatEntrance_New_Crops_Num = 0;
		BP_CorpsNewMessageCount = 0;
    end
end

-------------------------chat room send client to server-----------------

--创建频道
function LobbyChatSystem.create_channel_req(name, need_key, key)
	log("create_channel_req, name = " .. name .. ", need_key = " .. tostring(need_key) .. ", key = " .. key);
	NetUtil.SendPkg("create_channel_req", name, need_key, key);
end

--查找频道
function LobbyChatSystem.query_channel_req(channel_id)
	log("query_channel_req channel_id = " .. channel_id);
	NetUtil.SendPkg("query_channel_req", channel_id);
end

--获取玩家自己的频道列表
function LobbyChatSystem.get_channel_list_req()
	log("get_channel_list_req");
	NetUtil.SendPkg("get_channel_list_req");
end

--加入频道
function LobbyChatSystem.join_channel_req(channel_id, key)
	log("join_channel_req channel_id = " .. channel_id .. ", key = " .. key);
	NetUtil.SendPkg("join_channel_req", channel_id, key);
end

--退出频道
function LobbyChatSystem.exit_channel_req(channel_id)
	log("exit_channel_req channel_id = " .. channel_id);
	NetUtil.SendPkg("exit_channel_req", channel_id);
end

--收藏频道
function LobbyChatSystem.collect_channel_req(channel_id)
	log("collect_channel_req channel_id = " .. channel_id);
	NetUtil.SendPkg("collect_channel_req", channel_id);
end

--设置/修改频道
function LobbyChatSystem.change_channel_req(channel_id, channel_name, need_key, channel_key)
	log("change_channel_req");
	NetUtil.SendPkg("change_channel_req", channel_id, channel_name, need_key, channel_key);
end

--删除频道
function LobbyChatSystem.delete_channel_req(channel_id)
	log("delete_channel_req channel_id = " .. channel_id);
	NetUtil.SendPkg("delete_channel_req", channel_id);
end



--取消收藏频道
function LobbyChatSystem.cancel_collect_channel_req(channel_id)
	log("cancel_collect_channel_req");
	NetUtil.SendPkg("cancel_collect_channel_req", channel_id);
end


function LobbyChatSystem.send_chatroom_profile_req(list)
	--log("LobbyChatSystem.send_chatroom_profile_req");
    NetUtil.SendPkg("batch_get_profile_req", "", list, BP_PROFILE_MSG_TYPE_CHATROOM);
end
function LobbyChatSystem.send_chatroom_status_req(list)
	--log("LobbyChatSystem.send_chatroom_status_req");
	local cb = "ChatRoomStatus";
	NetUtil.SendPkg("batch_get_group_and_online_req",cb,list);
end

function LobbyChatSystem.send_open_chat_ui(isopen)
	--log("LobbyChatSystem.send_open_chat_ui:" .. tostring(isopen));
	NetUtil.SendPkg("open_chat_ui", isopen);
end

-------------------------chat room send server to client-----------------

--1. 创建频道
function LobbyChatSystem.create_channel_rsp(ok, reason, channel_id, channel)
	log("create_channel_rsp "
		.. " ok = " .. tostring(ok)
		.. " , reason = " .. tostring(reason)
		.. " , channel_id = "
		.. tostring(channel_id)
	);
	if (ok) then
		--log_tree("channel", channel);
		LobbyChatSystem.myChannel = channel;
		LobbyChatroomLogic.UpdateMyChannel(true);
		LobbyChatroomLogic.CloseCreateOrSetRoomPanel();
	else
		LobbyChatSystem.ShowErrorMsg(reason);
	end
end


--查找频道
function LobbyChatSystem.query_channel_rsp(channel_id, channel)
	log("LobbyChatSystem.query_channel_rsp");
end

--[[
LogNula: LuaLog: └─ 10088
LogNula: LuaLog:    ├─ channel_info
LogNula: LuaLog:    │  ├─ member_num: 1
LogNula: LuaLog:    │  ├─ channel_name: "test"
LogNula: LuaLog:    │  ├─ last_update_time: 1513324272
LogNula: LuaLog:    │  ├─ channel_need_key: true
LogNula: LuaLog:    │  └─ channel_owner: 410000001
LogNula: LuaLog:    └─ is_collect: true
]]
--获取玩家自己的频道列表
function LobbyChatSystem.get_channel_list_rsp(channel_list)

	--log("get_channel_list_rsp");
	--log_tree("get_channel_list_rsp", channel_list);

	LobbyChatSystem.channelList = channel_list;
	LobbyChatroomLogic.UpdateChannelList();
end
--[[
LogNula: LuaLog: channel
LogNula: LuaLog: ├─ members
LogNula: LuaLog: │  └─ 1: 410000001
LogNula: LuaLog: └─ channel_info
LogNula: LuaLog:    ├─ channel_need_key: true
LogNula: LuaLog:    ├─ channel_name: "test"
LogNula: LuaLog:    ├─ last_update_time: 1513326300
LogNula: LuaLog:    ├─ channel_owner: 410000001
LogNula: LuaLog:    └─ member_num: 2
]]
--加入频道
function LobbyChatSystem.join_channel_rsp(channel_id, ok, reason, channel)
	-- log("join_channel_rsp");
	--log_tree("channel", channel);
	if (ok) then
		LobbyChatSystem.myChannel = channel;
		LobbyChatroomLogic.UpdateMyChannel(true);
		LobbyChatroomLogic.CloseChatRoomPassword();
		LobbyChatSystem.chatRoomPasswordContainer[tostring(channel_id)] = BP_ChatRoom_SearchRoomPassword;
	else
		if (channel_id ~= nil) then
			if (tostring(reason) == "passwd-not-correct" and LobbyChatSystem.chatRoomQueryPassword) then
				LobbyChatSystem.chatRoomQueryPassword = false;
				LobbyChatSystem.chatRoomPasswordContainer[tostring(channel_id)] = nil;
				EventOpenChatRoomPassword();
				return;
			-- elseif tostring(reason) == "chatchannel-is-full" then	频道满了
			elseif tostring(reason) == "lite-global-shield" then	-- lite和全球版隔离
			    DataMgr.ShowNoticeByID("5046");
				return;
			end
		end
		log("fail to join room, reason = " .. reason);
		--DataMgr.ShowNoticeByString("fail to join room , reason = " .. reason);
		LobbyChatSystem.ShowErrorMsg(reason);
		if (tostring(reason) == "chatchannel-not-exist") then
			LobbyChatSystem.get_channel_list_req();
		end
	end
end

--退出频道
function LobbyChatSystem.exit_channel_rsp(channel_id, ok, reason)
	--log("exit_channel_rsp");
	if (ok) then
		LobbyChatroomLogic.ClearChatRoomData();
		LobbyChatroomLogic.RefreshChatRoom();
		LobbyChatSystem.get_channel_list_req();
	else
		log("fail to exit channel, reason = " .. reason);
		--DataMgr.ShowNoticeByString("fail to exit channel reason = " .. reason);
		LobbyChatSystem.ShowErrorMsg(reason);
	end
end

--收藏频道
function LobbyChatSystem.collect_channel_rsp(channel_id, ok)
	--log("collect_channel_rsp channel_id = " .. channel_id .. " ok = " .. tostring(ok));

	LobbyChatroomLogic.OnCollectStateChange();

	if (ok) then
		LobbyChatroomLogic.UpdateChannelMarkState(channel_id, true);
		DataMgr.ShowNoticeByID(106066);
	else
		log("fail to collect channel");
		--DataMgr.ShowNoticeByString("fail to collect channel");
		--LobbyChatSystem.ShowErrorMsg(reason);
		DataMgr.ShowNoticeByID(106045);
	end
end

--设置/修改频道
function LobbyChatSystem.change_channel_rsp(channel_id, ok, reason, channel)
	--log("change_channel_rsp channel_id = " .. channel_id .. " ok = " .. tostring(ok));
	--log_tree("channel", channel);

	if (ok) then
		if (LobbyChatSystem.myChannel ~= nil) then
			local members = LobbyChatSystem.myChannel.members;
			LobbyChatSystem.myChannel = channel;
			LobbyChatSystem.myChannel.members = members;

			LobbyChatroomLogic.UpdateMyChannel(false);
			LobbyChatroomLogic.CloseCreateOrSetRoomPanel();
		end
	else
		log("fail to change channel, reason = " .. reason);
		--DataMgr.ShowNoticeByString("fail to change channel, reason = " .. reason);
		LobbyChatSystem.ShowErrorMsg(reason);
	end
end

--删除频道
function LobbyChatSystem.delete_channel_rsp(channel_id, ok, reason)
	--log("delete_channel_rsp");	
	if (ok) then
		LobbyChatroomLogic.ClearChatRoomData();
		LobbyChatSystem.get_channel_list_req();
	else
		log("fail to remove channel, reason = " .. reason);
		--DataMgr.ShowNoticeByString("fail to remove channel, reason = " .. reason);
		LobbyChatSystem.ShowErrorMsg(reason);
	end
end

function LobbyChatSystem.update_channel_info(channel_id, channel)
	--log("update_channel_info channel_id = " .. channel_id);
	--log_tree("channel", channel);

	if (LobbyChatSystem.myChannel ~= nil and LobbyChatSystem.myChannel.channel_info ~= nil and channel ~= nil and channel.channel_info ~= nil) then
		LobbyChatSystem.myChannel.channel_info = channel.channel_info;
		LobbyChatroomLogic.UpdateMyChannel(false);
	end
end

--type = 1 JOIN   加入
--type = 2 EXIT	退出
--type = 3 DEL	删除(uid为0)
--更新频道成员
function LobbyChatSystem.update_channel_member(channel_id, uid, type)
	--log("update_channel_member channel_id = " .. channel_id .. ", uid = " .. tostring(uid) .. ", type = " .. tostring(type));
	if (LobbyChatSystem.myChannel ~= nil and LobbyChatSystem.myChannel.members ~= nil and LobbyChatSystem.myChannel.channel_info ~= nil) then
		local memberCount = #LobbyChatSystem.myChannel.members;
		local memberIndex = -1;
		if (memberCount > 0) then
			for i = 1, memberCount, 1 do
				if (tostring(LobbyChatSystem.myChannel.members[i]) == tostring(uid)) then
					memberIndex = i;
				end
			end
		end

		if (type == 1) then
			if (memberIndex == -1) then
				table.insert(LobbyChatSystem.myChannel.members, uid);
				LobbyChatSystem.myChannel.channel_info.member_num = #LobbyChatSystem.myChannel.members;
				LobbyChatroomLogic.AddOnePlayer(tostring(uid));
			end
			--[[
			if (LobbyChatSystem.myChannel.members ~= nil) then
				LobbyChatSystem.myChannel.channel_info.member_num = #LobbyChatSystem.myChannel.members;
			end
			LobbyChatroomLogic.UpdateMyChannel(false);
			]]
		elseif (type == 2) then
			if (memberIndex ~= -1) then
				local member_num = #LobbyChatSystem.myChannel.members;
				table.remove(LobbyChatSystem.myChannel.members, memberIndex);
				LobbyChatSystem.myChannel.channel_info.member_num = (member_num - 1);
				LobbyChatroomLogic.RemoveOnePlayer(memberIndex);
			end
			--[[
			if (LobbyChatSystem.myChannel.members ~= nil) then
				LobbyChatSystem.myChannel.channel_info.member_num = #LobbyChatSystem.myChannel.members;
			end
			LobbyChatroomLogic.UpdateMyChannel(false);
			]]
		elseif (type == 3) then
			if (LobbyChatSystem.myChannel ~= nil and LobbyChatSystem.myChannel.channel_info ~= nil) then
				local channelName = LobbyChatSystem.myChannel.channel_info.channel_name;
				DataMgr.ShowNoticeByString(string.format(DataMgr.GetMsgByID(106055), channelName)); --聊天室被解散
			end
			LobbyChatroomLogic.ClearChatRoomData();
			LobbyChatSystem.get_channel_list_req();
		end
	end
end


function LobbyChatSystem.ParseUpassInfo(upassInfo)
	local upassIsBuy = false;
	local upassShow = false;

	if upassInfo.is_buy == 0 then
			upassIsBuy = false;
		else
			upassIsBuy = true;
		end

	if upassInfo.switch == nil then
		upassShow = false;
	else
		upassShow = upassInfo.switch.ui or false;
	end

	return upassIsBuy, upassShow;
end


--取消收藏频道
function LobbyChatSystem.cancel_collect_channel_rsp(channel_id, ok)
	--log("cancel_collect_channel_rsp channel_id = " .. channel_id .. ", ok = " .. tostring(ok));

	LobbyChatroomLogic.OnCollectStateChange();

	if (ok) then
		LobbyChatroomLogic.UpdateChannelMarkState(channel_id, false);
		DataMgr.ShowNoticeByID(106067);
	else
		log("fail to cancel collect channel");
		DataMgr.ShowNoticeByID(106046);
		--DataMgr.ShowNoticeByString("fail to cancel collect channel");
		--LobbyChatSystem.ShowErrorMsg(reason);
	end
end

function LobbyChatSystem.ShowErrorMsg(reason)
	if (reason ~= nil) then
		if (tostring(reason) == "name-too-long") then --名字太长
			DataMgr.ShowNoticeByID(106028);
		elseif (tostring(reason) == "key-too-long") then	--密码太长
			DataMgr.ShowNoticeByID(106029);
		elseif (tostring(reason) == "key-too-short") then	--密码太短
			DataMgr.ShowNoticeByID(106030);
		elseif (tostring(reason) == "have-dirty-in-name") then	--名字中含有脏字
			DataMgr.ShowNoticeByID(106031);
		elseif (tostring(reason) == "chatchannel_exist") then	--频道已存在
			DataMgr.ShowNoticeByID(106032);
		elseif (tostring(reason) == "create-channel-exceed-limit") then	--创建的频道超出限制
			DataMgr.ShowNoticeByID(106033);
		elseif (tostring(reason) == "channel-not-exists") then	--当前尚未进入频道
			DataMgr.ShowNoticeByID(106034);
		elseif (tostring(reason) == "chatchannel-not-exist") then	--频道不存在
			DataMgr.ShowNoticeByID(106035);
		elseif (tostring(reason) == "db_error") then		--DB错误
			DataMgr.ShowNoticeByID(106036);
		elseif (tostring(reason) == "chatchannel-is-full") then	--频道人员已满
			DataMgr.ShowNoticeByID(106037);
		elseif (tostring(reason) == "passwd-not-correct") then	--频道密码不对
			DataMgr.ShowNoticeByID(106038);
		elseif (tostring(reason) == "not-channel-owner") then	--频道不是自己所创建的
			DataMgr.ShowNoticeByID(106039);
		elseif (tostring(reason) == "announcement-too-long") then	--公告内容太长了
			DataMgr.ShowNoticeByID(106073);
		elseif (tostring(reason) == "have-dirty-in-announcement") then	--公告中含有脏字
			DataMgr.ShowNoticeByID(106074);
		else
			log("unknown error " .. tostring(reason));
		end
	end
end


--[[
LogNula: LuaLog: role_basic_info_list
LogNula: LuaLog: └─ 410000358
LogNula: LuaLog:    ├─ vipLevel: ""
LogNula: LuaLog:    ├─ segment_info
LogNula: LuaLog:    │  ├─ 1: 1
LogNula: LuaLog:    │  ├─ 2: 1
LogNula: LuaLog:    │  └─ 3: 1
LogNula: LuaLog:    ├─ platName: "宁"
LogNula: LuaLog:    ├─ level: 1
LogNula: LuaLog:    ├─ lastLoginTime: 1513665918
LogNula: LuaLog:    ├─ picUrl: "http://q.qlogo.cn/qqapp/1106467070/C1E162B0B7786CCF551EA5935D8AE1EB/40"
LogNula: LuaLog:    ├─ lastOnlineTime: 1513665918
LogNula: LuaLog:    ├─ ladder: 0
LogNula: LuaLog:    ├─ nickName: "jack1219"
LogNula: LuaLog:    ├─ sex: 1
LogNula: LuaLog:    ├─ bitmap: 0
LogNula: LuaLog:    ├─ signature: ""
LogNula: LuaLog:    ├─ exp: 0
LogNula: LuaLog:    ├─ rankdata
LogNula: LuaLog:    │  ├─ squad
LogNula: LuaLog:    │  │  ├─ win_rating: 1000
LogNula: LuaLog:    │  │  ├─ kill_rating: 1000
LogNula: LuaLog:    │  │  ├─ rank_rating: 1200
LogNula: LuaLog:    │  │  ├─ win_num: 0
LogNula: LuaLog:    │  │  ├─ playtime: 0
LogNula: LuaLog:    │  │  ├─ kill_num: 0
LogNula: LuaLog:    │  │  ├─ kd: 0
LogNula: LuaLog:    │  │  ├─ win_ratio: 0
LogNula: LuaLog:    │  │  └─ max_kill: 0
LogNula: LuaLog:    │  ├─ total_rank_rating: 3600
LogNula: LuaLog:    │  ├─ solo
LogNula: LuaLog:    │  │  ├─ max_kill: 0
LogNula: LuaLog:    │  │  ├─ kill_rating: 1000
LogNula: LuaLog:    │  │  ├─ rank_rating: 1200
LogNula: LuaLog:    │  │  ├─ win_num: 0
LogNula: LuaLog:    │  │  ├─ playtime: 0
LogNula: LuaLog:    │  │  ├─ kill_num: 0
LogNula: LuaLog:    │  │  ├─ win_ratio: 0
LogNula: LuaLog:    │  │  ├─ kd: 0
LogNula: LuaLog:    │  │  ├─ win_rating: 1000
LogNula: LuaLog:    │  │  └─ top10_count: 0
LogNula: LuaLog:    │  └─ duo
LogNula: LuaLog:    │     ├─ win_rating: 1000
LogNula: LuaLog:    │     ├─ kill_rating: 1000
LogNula: LuaLog:    │     ├─ rank_rating: 1200
LogNula: LuaLog:    │     ├─ win_num: 0
LogNula: LuaLog:    │     ├─ playtime: 0
LogNula: LuaLog:    │     ├─ kill_num: 0
LogNula: LuaLog:    │     ├─ kd: 0
LogNula: LuaLog:    │     ├─ win_ratio: 0
LogNula: LuaLog:    │     └─ max_kill: 0
LogNula: LuaLog:    └─ city: ""
LogGCloud: [2017-12-19 14:45:36 893] | In
]]
function LobbyChatSystem.on_chatroom_profile_rsp(listType, res, role_basic_info_list, systemType)

	if BP_PROFILE_MSG_TYPE_CHATROOM ~= systemType then
		return;
	end

	if "ok" ~= res then
		return;
	end

	log("LobbyChatSystem.on_chatroom_profile_rsp");
end
--[[
LogNula: LuaLog: infos
LogNula: LuaLog: └─ 410000358
LogNula: LuaLog:    ├─ teamState: 0
LogNula: LuaLog:    ├─ online: 1
LogNula: LuaLog:    ├─ timeSinceGameBegin: 0
LogNula: LuaLog:    ├─ currentTeamAmount: 1
LogNula: LuaLog:    └─ maxTeamAmount: 4
]]
function LobbyChatSystem.on_chatroom_status_rsp(cb, res, infos)
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
	if cb ~= "ChatRoomStatus" then
		log("no ChatRoomStatus");
		return;
	end
	log("LobbyChatSystem.on_chatroom_status_rsp");

	if res =="ok" then
		if infos ~= nil then
			for k,v in pairs(infos) do

				local PlayerStatu = {};
				PlayerStatu.teamState = v.teamState;
				PlayerStatu.teamId = v.teamId;
				PlayerStatu.currentTeamAmount = v.currentTeamAmount;
				PlayerStatu.maxTeamAmount = v.maxTeamAmount;
				PlayerStatu.timeSinceGameBegin = v.timeSinceGameBegin;
				PlayerStatu.online = v.online;

				LobbyChatSystem.chatRoomStatusDict[tostring(k)] = PlayerStatu;

			end
		end
		LobbyChatroomLogic.UpdateChannelStatus();
	end
end

function LobbyChatSystem.notify_update_channel_member_state(uid, channel_id, team_state, channel)
	--log("notify_update_channel_member_state " .. uid .. ", channel_id = " .. channel_id .. ", team_state = " .. team_state);
	if (channel ~= nil) then
		--log_tree("channel", channel);
	end
	LobbyChatroomLogic.OnTeamStateChange(uid, channel_id, team_state)

end

lastFetchLangList = {};	-- 最近一次获取话题的参数
--获取话题列表
function LobbyChatSystem.topic_fetch_list_req(langs)
	-- log("ChatLanguageDataList.length"..tostring(#ChatLanguageDataList));
	local langList = {};
	if type(langs) == "table" then
		if #BP_ChatLanguageDataList == 0 then
			return;
		end
		for k1,v1 in pairs(langs) do
			for k2,v2 in pairs(BP_ChatLanguageDataList) do
				if v1 == v2.langName then
					langList[k1] = v2.id;
				end
			end
		end
	else
		langList = {langs};
	end
	LobbyChatSystem.topic_fetch_list_id_req(langList);
end
function LobbyChatSystem.topic_fetch_list_id_req(languageIDs)
	NetUtil.SendPkg("topic_flat_list_req", languageIDs);
	lastFetchLangList = languageIDs;
end


-- 返回话题列表 Version2
-- @param list 话题列表(二级列表变成了一级列表):
-- topic_fetch_list_req
function LobbyChatSystem.topic_flat_list_rsp(msg, list)
	--log_tree("list", list);

	-- 当玩家切换话题语言时，默认选择切换后语言下对应的话题频道（比如原本是第三个话题，切换后也在第三个话题）
	-- http://tapd.oa.com/20360302/prong/stories/view/1020360302062841539
	local oldSelectIndex;
	local newSelectTopicId;
	for index, item in ipairs(BP_ARRAY_TopicList) do
		if item.id == BP_Current_TopicId then
			oldSelectIndex = index;
			break;
		end
	end

	BP_ARRAY_TopicList = {};
	BP_ARRAY_TopicTypeList = {};
	BP_STRUCT_WorldChannelInfo = {};
	-- LobbyChatLogic.Local_ARRAY_DataList = {};
	BP_ARRAY_TopicRedPointList = {};
	if msg == "ok" then
		if type(list) == "table" then
	    	-- table.sort(list , function(a,b) return (GetTableValueIndex(lastFetchLangList, a.lang_id) <= GetTableValueIndex(lastFetchLangList, b.lang_id)) or (a.order < b.order) end );
	    	table.sort(list , CompareLang);
	    	for k, v in pairs(list) do
		    	local item = {};
	    		item.id = v.id;
	    		-- item.typeName = v.name;
		    	item.name = v.name;
		    	item.lang_id = v.lang_id;
		    	table.insert(BP_ARRAY_TopicList, item);

	    		--根据话题频道创建数据字典
	    		-- LobbyChatLogic.Local_ARRAY_DataList[item.id] = {};
		    	--创建小红点提示初始化数据
		    	local redPointItem = {};
	    		redPointItem.topicId = v.id;
	    		redPointItem.num = 0;
		    	table.insert(BP_ARRAY_TopicRedPointList, redPointItem);
		    end
			--LobbyChatLogic.Local_ARRAY_DataList[BP_WorldChannelID] = {};

			if oldSelectIndex then
				local newItem = BP_ARRAY_TopicList[oldSelectIndex]
				if newItem then
					newSelectTopicId = newItem.id;
				elseif next(BP_ARRAY_TopicList) then
					newSelectTopicId = BP_ARRAY_TopicList[1].id;
				end
			else
				newSelectTopicId = "world_Channel"
			end

	    	LobbyChatLogic.TopicListIsReady(newSelectTopicId);
	    	-- log_tree("BP_ARRAY_TopicList", BP_ARRAY_TopicList);
	    	-- log_tree("BP_ARRAY_TopicTypeList", BP_ARRAY_TopicTypeList);
	    	-- log_tree("Local_ARRAY_DataList", LobbyChatLogic.Local_ARRAY_DataList);
	    end
	else
		LobbyChatLogic.TopicListIsReady();
	end
end

-- 获取channelType(世界频道的话题要特殊处理)
function LobbyChatSystem.GetChannelType(channelType, topicID)
	-- log("LobbyChatSystem.GetChannelType "..tostring(channelType).."  "..tostring(topicID).."  "..tostring(LobbyChatSystem.channelWorld))
	if tostring(channelType) ~= tostring(LobbyChatSystem.channelWorld) or topicID == BP_WorldChannelID or BP_ARRAY_TopicList == nil or #BP_ARRAY_TopicList < 1 then
		return channelType;
	end

	local currentTopicLangId = BP_ARRAY_TopicList[1].lang_id;
    for i,v in ipairs(BP_ARRAY_TopicList) do
    	if v.id == topicID then
    		currentTopicLangId = v.lang_id;
    		break;
    	end
    end
    if lastFetchLangList ~= nil and #lastFetchLangList >= 1 and lastFetchLangList[1] == currentTopicLangId then
    	return LobbyChatSystem.channelTopic;
    else
    	return LobbyChatSystem.channelTopic2;
    end
	return channelType;
end

-- 获取table中一个value的下标
function GetTableValueIndex(t, v0)
	for k, v in pairs(t) do
		if v0 == v then
			return tonumber(k);
		end
	end
	return 0;
end

-- 对比话题
function CompareLang(a, b)

	local c1 = GetTableValueIndex(lastFetchLangList, a.lang_id) ~= GetTableValueIndex(lastFetchLangList, b.lang_id);
	if c1 then
		return GetTableValueIndex(lastFetchLangList, a.lang_id) <= GetTableValueIndex(lastFetchLangList, b.lang_id);
	else
		return a.order < b.order;
	end
	-- return (GetTableValueIndex(lastFetchLangList, a.lang_id) <= GetTableValueIndex(lastFetchLangList, b.lang_id)) or (a.order < b.order);
end

--订阅话题请求
function LobbyChatSystem.topic_subscribe_req(tid)
	NetUtil.SendPkg("topic_subscribe_req" , tid);
end

--订阅话题回包
function LobbyChatSystem.topic_subscribe_rsp(tid , msg)
	--log("订阅话题回包")
	if msg == "ok" then
		-- todo
		LobbyChatLogic.RefreshWorldChannelMsg();
		--LobbyChatLogic.isChangeTopic = true;
	else
		DataMgr.ShowNoticeByID(4724);
	end
end

--取消订阅
function LobbyChatSystem.topic_unsubscribe_req()
	NetUtil.SendPkg("topic_unsubscribe_req");
end

--取消订阅回包
function LobbyChatSystem.topic_unsubscribe_rsp(tid, msg)
	if msg == "ok" then
	else
		--DataMgr.ShowNoticeByID(4725);
	end
end

-- 聊天拉取语言信息列表
function LobbyChatSystem.topic_fetch_lang_list_req()
	NetUtil.SendPkg("topic_fetch_lang_list_req");
end

-- 聊天语言数据
BP_ChatLanguageDataList = {};

function LobbyChatSystem.topic_fetch_lang_list_rsp(list, timeSpan)
	BP_ShowSwitchTopicLanguageTimeSpan = timeSpan;
	-- log_tree("list", list);
	if type(list) == "table" then
		for k, v in pairs(list) do
			v.id = k;
		end
		table.sort(list , function(a,b) return a.id < b.id end );
		--log_tree("list", list);
		local isFind = false;
		BP_ARRAY_LanguageNameList = {};
		LobbyChatLogic.Local_ARRAY_LanguageDataList = {};
		BP_ChatLanguageDataList = {};
		for k, v in pairs(list) do
			local item = {};
			item.id = k;
			item.name = v.lang;
			item.langName = v.lang_name;
			table.insert(BP_ChatLanguageDataList, item);
			LobbyChatLogic.Local_ARRAY_LanguageDataList[v.lang_name] = k;
			table.insert(BP_ARRAY_LanguageNameList, v.lang_name);
			if v.lang ~= nil and string.find(v.lang, Client.GetCurrentLanguage()) ~= nil and isFind == false then
				BP_TopicLanguage = #BP_ARRAY_LanguageNameList - 1;
				isFind = true;
			end
		end
		--log_tree("BP_ARRAY_LanguageDataList", BP_ARRAY_LANGUAGENAMELIST);
		--log_tree("LobbyChatLogic.Local_ARRAY_LanguageDataList", LobbyChatLogic.Local_ARRAY_LanguageDataList);
		--log_tree("BP_ChatLanguageDataList", BP_ChatLanguageDataList);
		LobbyChatLogic.TopicLanguageListReady();
		ChatLanguageSelect.Refresh();
	end
end

function LobbyChatSystem.topic_send_at_notify(send_uid, chat_content)
	--log("LobbyChatSystem.topic_send_at_notify")
	LobbyChatLogic.UpdateRedPoint(chat_content.topic,1,false);
end

function LobbyChatSystem.team_recruit_info_rsp(recvSameLanguage)
	LobbyChatSystem.recvSameLanguage = recvSameLanguage;
end

function LobbyChatSystem.set_recv_other_language_req(sameLanguage)
	NetUtil.SendPkg("set_recv_other_language_req", sameLanguage);
end

function LobbyChatSystem.set_recv_other_language_rsp(msg, recvSameLanguage)
	if msg =="ok" then
		--log("set_recv_other_language_rsp : "..tostring(recvSameLanguage));
		LobbyChatSystem.recvSameLanguage = recvSameLanguage;
		LobbyChatLogic.RefreshLanguageState()
	end
end

-- sami 拉取离线好友消息
function LobbyChatSystem.req_get_offline_chat_msg()
	--log("LobbyChatSystem.req_get_offline_chat_msg")
	NetUtil.SendPkg("get_offline_chat_msg_req");
end

-- 拉取离线好友消息回复
function LobbyChatSystem.on_get_offline_chat_msg(msg)
	--log("LobbyChatSystem.on_get_offline_chat_msg")
	--log_tree("msg = ", msg)
	LobbyChatSystem.resOfflineChatMsg = msg
	EventSystem:postEvent(EVENTTYPE_CHAT, EVENTTYPE_CHAT_OFFLINE_CHAT_MSG)
end

-- 拉取离线好友消息数量
function LobbyChatSystem.req_get_offline_chat_msg_num()
	--log("LobbyChatSystem.req_get_offline_chat_msg_num")
	NetUtil.SendPkg("get_offline_chat_msg_count_req");
end

-- 拉取离线好友消息数量回复
function LobbyChatSystem.on_get_offline_chat_msg_count(msg, count)
	--log("LobbyChatSystem.on_get_offline_chat_msg_count " ..msg .." " ..count)
	if msg =="ok" then
		LobbyChatSystem.resOfflineChatMsgNum = count

		BP_FriendNewMessageCount = count;
		LuaClassObj.HandleUIMessage(bp_chat_main, "OnNotifyFriendTotalUnread");
		BP_ChatFriendNewMsgCount = count;
		LuaClassObj.HandleUIMessage(bp_chat_entrance, "YourFriendCalledYou");

		EventSystem:postEvent(EVENTTYPE_CHAT, EVENTTYPE_CHAT_OFFLINE_CHAT_MSG_NUM)
	end
end



--[[网络回调]]--
s2c["chat_req"] = LobbyChatSystem.on_chat_req;
s2c["chat_rsp"] = LobbyChatSystem.on_chat_rsp;
s2c["chat_notify"] = LobbyChatSystem.chat_notify;
s2c["chat_merge_notify"] = LobbyChatSystem.chat_merge_notify;
s2c["chat_clear_msg"] = LobbyChatSystem.on_clear_msg;
s2c["report_info"] = LobbyChatSystem.on_report_rsp;
s2c["filter_text_rsp"] = LobbyChatSystem.filter_text_rsp;
s2c["corps_recruit_rsp"] = LobbyChatSystem.on_chat_corps_recruit_rsp;

s2c["appointment_game_friend_notify"] = LobbyChatSystem.on_reserve_require_notify;
s2c["appointment_game_friend_res"] = LobbyChatSystem.on_reserve_reply_notify;
s2c["appointment_friend_game_end"] = LobbyChatSystem.on_reserve_friend_game_end_notify;
s2c["notify_appointment_friend_list"] = LobbyChatSystem.on_reservation_from_lobby_notify;


s2c["create_channel_rsp"] = LobbyChatSystem.create_channel_rsp;			--创建频道
s2c["query_channel_rsp"] = LobbyChatSystem.query_channel_rsp;			--查找频道
s2c["get_channel_list_rsp"] = LobbyChatSystem.get_channel_list_rsp;		--获取玩家自己的频道列表
s2c["join_channel_rsp"] = LobbyChatSystem.join_channel_rsp;				--加入频道
s2c["exit_channel_rsp"] = LobbyChatSystem.exit_channel_rsp;				--退出频道
s2c["collect_channel_rsp"] = LobbyChatSystem.collect_channel_rsp; 		--收藏频道
s2c["change_channel_rsp"] = LobbyChatSystem.change_channel_rsp;			--设置/修改频道
s2c["delete_channel_rsp"] = LobbyChatSystem.delete_channel_rsp;			--删除频道
s2c["update_channel_member"] = LobbyChatSystem.update_channel_member;	--更新频道成员
s2c["cancel_collect_channel_rsp"] = LobbyChatSystem.cancel_collect_channel_rsp;	--取消收藏频道
s2c["notify_update_channel_member_state"] = LobbyChatSystem.notify_update_channel_member_state;	--频道成员组队状态变化
s2c["update_channel_info"] = LobbyChatSystem.update_channel_info;		--修改频道时,通知频道基本信息


s2c["topic_subscribe_rsp"] = LobbyChatSystem.topic_subscribe_rsp;
s2c["topic_unsubscribe_rsp"] = LobbyChatSystem.topic_unsubscribe_rsp;
s2c["topic_fetch_lang_list_rsp"] = LobbyChatSystem.topic_fetch_lang_list_rsp;
s2c["topic_send_at_notify"] = LobbyChatSystem.topic_send_at_notify;
s2c["topic_flat_list_rsp"] = LobbyChatSystem.topic_flat_list_rsp;
s2c["team_recruit_info_rsp"] = LobbyChatSystem.team_recruit_info_rsp;			-- 组队招募初始信息
s2c["set_recv_other_language_rsp"]=LobbyChatSystem.set_recv_other_language_rsp;	-- 组队招募语言修改回调
s2c["get_offline_chat_msg_rsp"]=LobbyChatSystem.on_get_offline_chat_msg;		-- 拉取离线好友消息列表
s2c["get_offline_chat_msg_count_rsp"]=LobbyChatSystem.on_get_offline_chat_msg_count;	-- 拉取离线好友消息数量

