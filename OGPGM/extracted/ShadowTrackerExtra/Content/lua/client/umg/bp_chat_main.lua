LobbyChatLogic = LobbyChatLogic or 
{
	chatBackGroundProfile = false;	
	chatProfileBufferReq = {};
	chatProfileWorldBufferReq = {};
	chatRoomBufferList = {};
	chatCorpsBufferList = {};

	HeadDataList = {};
	HeadDataIndex = 1;	--聊天头像数据索引
	
	chatRoomFightNewMsg = 0;
	chatCorpsFightNewMsg = 0;
	isShowing = false;
	lastCorpsId = 0;
	lastCorpsRecruitClicked = 0;
	lastCorpsDataReceived = 0;
	isShowSwitchTopicLanguage = true;

	--话题聊天数据key，value的保存方式，只存lua，不存蓝图，每次切换刷一次数据
	Local_ARRAY_DataList = {
		
	};

	Local_ARRAY_LanguageDataList = {
		
	};

	--@玩家的ID list
	Local_ARRAY_SelectPlayerList = {
		
	};
	timeForRefresh = 0.2;
	timeRecord = 0;
	--needRefreshUI = false;
	IsRefreshWorldChannelMsg = false;
	--主要用于压力测试的时候 服务器会取全服第一个玩家的数据进行模拟发送
	--并且返回确认消息，这个会频繁刷新客户端从而导致刚登陆的名字字母序排名靠前的玩家有很明显的卡顿，这个优化主要是针对内网测试的
	sendRspRateSpeedControl = 0;
	
	--是否加入军团离线缓存数据
	bAddCropsOfflineChatMsg = false;

	bTopicListIsReady = false	--话题列表是否已获取
}

BP_ChatMainValid = false;
BP_ChatMainFirstShow = false;
BP_ChatMainShown = false;
BP_ReceiverName = "光速小子";
BP_ReceiverGID = "";
BP_ChatContent = "hello world";
BP_ChatInputContent = "";
BP_ChatInputFilteredContent = "";
BP_ChannelTitleName = "";
BP_ChannelType = 2;
BP_SelectedFriendGID = "";
BP_ChatSelectedGID = "";
BP_ChatSelectedGender = nil

BP_WorldNewMessageCount = 0;
BP_FriendNewMessageCount = 0;
BP_TeamNewMessageCount = 0;
BP_LocalLanguageMessageCount = 0;
BP_TeamRecruitMessageCount = 0;
BP_ChatRoomNewMessageCount = 0;
BP_CorpsNewMessageCount = 0;

BP_ChatOnlineFriendCout = 0;
BP_ChatTotalFriendCount = 0;

BP_ChatMyGID = "";
BP_ChatIsInCorps = false;
BP_ChatCorpsNotice = "";
BP_ChatIsTeamUp = false;
BP_ChatTickBufferList = false;
BP_ChatTodayDate = "";
BP_ChatHoverGID = "";
BP_ChatHoverContent = "";
BP_ChatHoverName = "";
BP_ChatMainClearGID = "";
BP_ChatMsgType = 1;

-- 离线语音相关
BP_ChatVoiceBan = 0;
BP_ChatVoiceTotalLimit = 10;
BP_ChatVoiceUploadMsgId = "";
BP_ChatVoiceToTextContent = "";
BP_ChatVoiceUploadTime = 0;
BP_ChatVoicePlayFileId = "";
BP_ChatVoiceMode = -1;

BP_ChatVoiceDownloadFileId = "";
BP_ChatVoiceDownloadChannel = 0;
BP_ChatVoiceDownloadMsgId = 0;
BP_ChatVoiceDownloadOwnerGid = "";
BP_ChatVoiceDownloadMsgLength = 0;

BP_ChatVoiceTeamRoom = "";

BP_ChatVoiceOpenMic = false;
BP_ChatVoiceOpenSpeaker = false;

BP_ChatHoverIsPullBlack = false;
BP_ChatHoverIsFriend = false;

BP_ChatProfileRspGid = "";
BP_ChatProfileRspUrl = "";
BP_ChatProfileRspNickName = "";
BP_ChatProfileRspGender = 0;
BP_ChatProfileRspLevel = 0;
BP_ChatProfileRspMaxSegment = 0;
BP_ChatProfileRspAvatarBox = 0;
BP_ChatProfileRspUpassIsBuy = false;
BP_ChatProfileRspUpassShow = false;
BP_ChatProfileRspAliasId = 0;
BP_ChatProfileRspAliasTitle = "";
BP_ChatProfileRspAliasNation = "";
BP_ChatProfileRspRoleNation = "";

BP_ChatProfileReqGid = "";
BP_ChatRecruitJoinGid = "";
BP_ChatRecruitTeamID = "";
BP_ChatShowHelpContent = "";
BP_ChatMainMyRoomId = "0";
BP_ChatEmojiClickItem = 0;

BP_ChatMsgID = 0; --所有消息ID

BP_ChatTranslateChannel = 0;
BP_ChatTranslateID = 0;
BP_ChatTranslateText = "";
BP_ChatLanguageFrom = "";

BP_ChatPrivacyAccepted = false;
BP_ChatPrivacyCurVersion = "";
BP_GameVersion = "";

BP_RecruitVoiceState = true;
BP_RecruitSameLanguageState = true; --组队招募相同语言
--zino兼容老服务器的聊天信息判定
BP_IsOldVersion = false;

BP_OpenChatPanelFromRoom = false;	-- 从房间内的按钮打开招募

--成就
BP_STRUCT_ShareAchievementInfo =
{
    id = 0,
    img_url = "",
    big_img_url = "",
    des = "",
    title = "",
    state = 1,
    finish_time = "",
    finish_time_row = 0,
    award_id = 0,
    award_num = 0,
    award2_id = 0,
    award2_num = 0,
    group_id = 1,
    group_title = "",
    group_num = 1,
    total_process = 1,
    cur_process = 0,
    cnd_num = 1,
    score = 0,
    param_des = "",
    update_time = 0,
    owner_player_name = "",
};

BP_STRUCT_BargainHelpMessage = {
	channel = 0,
	msg_type = 0,
	owner_id = "",
	cur_orderid = 0,
	shop_id = 0,
	have_bargained = false,

	item_id = 0,
	quality = 0,
	ori_price = 0,
	cur_price = 0,
	description = "",
}

--头像信息
BP_STRUCT_AvatarData = {
	Gid = "",
	Url = "",
	Level = 0,
	NickName = "",
	AvatarBox = 0,
	AliasId = 0,
	AliasTitle = "",
	AliasNation = "",
	RoleNation = "",
	MaxSegment = 0,
	UpassIsBuy = false,
	UpassShow = false,
}

BP_STRUCT_ChatMessageSingleData =
{
	uid = "",
	icon = "",	--头像url
	name = "",
	gender = 0,
	msg = "",
	msgChannel = 0,	--聊天频道
	msgType = 0,	--消息类型
	msgSendTime = "",
	msgSendDate = "",
	level = 1,		--先用level做增量id
	voiceMsgId = "",
	voiceMsgTime = 0,
	roomId = "",
	roomType = "",
	selfMsg = false,
	zoneId = -1,	--战区id
	zoneText = "",	--战区名字
	zoneIp = "",	--战区ip
	upassIsBuy = false,	--是否购买了通行证
	upassShow = false,	--是否展示
	roleNation = "",    --发送者国籍
    selfNation = "",    --自己的国籍
    aliasId = 0,
    aliasTitle = "",
    aliasNation = "",
    voiceType = 0,

	BP_STRUCT_AvatarData = _G.BP_STRUCT_AvatarData, --头像信息
    BP_STRUCT_ShareAchievementInfo = _G.BP_STRUCT_ShareAchievementInfo,	--成就分享
    BP_STRUCT_BargainHelpMessage = _G.BP_STRUCT_BargainHelpMessage,
}

BP_STRUCT_ChatBriefFriendData =
{
	gid="",
	nickName = "",
	level = 0,
    picUrl = "",
    vipLevel = 0,
    ladder = 0,
    platName = "",
    sex = 0,
	online = 1, -- 0为离线，1为在线
    lastOnlineTime = 0,
	teamState = 0, -- 0为空闲，1为组队中（组队中提供当前队伍人数，队伍最大可容纳人数，队伍id）,2为已开局状态（需已开局时间数据）
	currentTeamAmount = 1, -- 当前队伍人数
	maxTeamAmount = 4, -- 队伍最大可容纳人数
	teamId = 0, -- 队伍id
	timeSinceGameBegin = 0, -- 已开局时间
    op=0, --邀请列表里面的操作
    applyMsg="", --邀请列表里面的留言
	militaryRank = "",
	segment_info_solo = 0,
	segment_info_duo = 0,
	segment_info_squad = 0,
	cur_avatar_box_id = 0,
	upassIsBuy = false,	--是否购买了通行证
	upassShow = false,	--是否展示
	roleNation = "",    --国籍
	aliasId = 0,
	aliasTitle = "",
	aliasNation = "",
	aliasNation = "",
}

BP_STRUCT_ChatUnreadMsgCount =
{
	gid = "",
	nickName = "",
	unreadCount = 0,
}

BP_STRUCT_ChatVoiceDownloadData =
{
	msgGid = 0,
	msgChannel = 0,
	msgId = 0,
	fileId = "",
}

-- 语言+映射
BP_STRUCT_LanguageData =
{
	id = 0,
	name = "",
	langName = "",
}

-- 语言+映射
BP_ARRAY_LanguageDataList =
{
	BP_STRUCT_LanguageData = _G.BP_STRUCT_LanguageData,
};

-- 世界聊天记录
BP_ARRAY_WorldChatList =
{
	BP_STRUCT_ChatMessageSingleData = _G.BP_STRUCT_ChatMessageSingleData,
};

-- 语种聊天记录
BP_ARRAY_LocalLanguageChatList =
{
	BP_STRUCT_ChatMessageSingleData = _G.BP_STRUCT_ChatMessageSingleData,
}

-- 好友聊天记录
BP_ARRAY_FriendChatList =
{
	BP_STRUCT_ChatMessageSingleData = _G.BP_STRUCT_ChatMessageSingleData,
};

-- 队友聊天记录
BP_ARRAY_TeamChatList =
{
	BP_STRUCT_ChatMessageSingleData = _G.BP_STRUCT_ChatMessageSingleData,
};

BP_ARRAY_ChatroomChatList =
{
	BP_STRUCT_ChatMessageSingleData = _G.BP_STRUCT_ChatMessageSingleData,
};

-- 军团聊天记录
BP_ARRAY_CorpsChatList =
{
	BP_STRUCT_ChatMessageSingleData = _G.BP_STRUCT_ChatMessageSingleData,
};


--招募信息
BP_ARRAY_TeamRecruitList =
{
	BP_STRUCT_ChatMessageSingleData = _G.BP_STRUCT_ChatMessageSingleData,
}

-- 访问最新的消息记录数据
BP_ARRAY_NewChatList =
{
	BP_STRUCT_ChatMessageSingleData = _G.BP_STRUCT_ChatMessageSingleData,
};

-- 消息未读记录
BP_ARRAY_ChatFriendUnreadList =
{
	BP_STRUCT_ChatUnreadMsgCount = _G.BP_STRUCT_ChatUnreadMsgCount,
};

-- 好友列表
BP_ARRAY_ChatFriendList =
{
	BP_STRUCT_ChatBriefFriendData = _G.BP_STRUCT_ChatBriefFriendData,
};

-- 离线语音下载列表
BP_ARRAY_ChatVoiceDownloadList =
{
	BP_STRUCT_ChatVoiceDownloadData = _G.BP_STRUCT_ChatVoiceDownloadData,
};




-- 话题列表结构
BP_STRUCT_TopicItemData = {
	id = "",
	name = "",
	typeName = "",
	lang_id = 0,
}
--话题列表
BP_ARRAY_TopicList = {
	BP_STRUCT_TopicItemData = _G.BP_STRUCT_TopicItemData;
}

--话题大类
BP_ARRAY_TopicTypeList = {
	"",
}
---当前话题的ID，用于数据同步
BP_Current_TopicId = "";

--世界聊天频道
BP_WorldChannelID = "world_Channel";

--当前话题语言
BP_TopicLanguage = 0;

--可选择语言列表
BP_ARRAY_LanguageNameList = {
	"",
}

--@玩家的ID list
BP_ARRAY_SelectPlayerList = {
	id = 0,
}

--话题红点提示结构
BP_STRUCT_TopicRedPointData = {
	topicId = "",
	num = 0,
}

--话题红点list
BP_ARRAY_TopicRedPointList = {
	BP_STRUCT_TopicRedPointData = _G.BP_STRUCT_TopicRedPointData;
}

--当前小红点数量
BP_CurrentRedPoint_Number = 0;


--翻译协议
BP_SubscriptionKey = ""
BP_StoredAccessToken = ""
BP_TranslateContent = ""

BP_MAP_GetAccessTokenHeaders = {
	["Ocp-Apim-Subscription-Key"] = "07c1ba6329884d97bd7cb4ca462ed425"
}
BP_STRUCT_GetAccessToken = {
	URL = "https://api.cognitive.microsoft.com/sts/v1.0/issueToken",
	Verb = "POST",
	Content = "",
}
BP_MAP_DetectHeaders = {
	["Authorization"] = "",
	["Content-Type"] = "application/json",
}
BP_STRUCT_Detect = {
	URL = "https://api.cognitive.microsofttranslator.com/detect?api-version=3.0",
	Verb = "POST",
	Content = "",
}
BP_MAP_TranslateHeaders = {
	["Authorization"] = "",
	["Content-Type"] = "application/json",
}
BP_STRUCT_Translate = {
	URL = "",
	URLOrigin = "https://api.cognitive.microsofttranslator.com/translate?api-version=3.0",
	Verb = "POST",
	Content = "",
}
BP_STRUCT_ReuseItemData = {
	DataLevel = 0,
	IsOrigin = true,
	TranslateContent = "",
	TranslateFromText = "",
}
BP_ARRAY_ReuseItemData = {
	BP_STRUCT_ReuseItemData = _G.BP_STRUCT_ReuseItemData
}

BP_ToRemoveMsgId = -1;	--删除ReuseList中某个ID的消息
BP_ToGetMsgId = -1;		--获取当前频道中某个ID的消息
BP_ToDoReuseItemDataId = -1;	--需要操作的ReuseItem的ID
--用于获取单条数据（避免获取整个列表）
BP_ARRAY_ToGetMsg = {
	BP_STRUCT_ChatMessageSingleData = _G.BP_STRUCT_ChatMessageSingleData,
}
BP_ARRAY_ToDoReuseItemData = {
	BP_STRUCT_ReuseItemData = _G.BP_STRUCT_ReuseItemData
}

--注册Widget
function bp_chat_main_RegisterUI()

  LuaClassObj.SubUIWidgetList(bp_chat_main,
    {
		{Path="/Game/UMG/UI_Logic/LobbyChat/ChatMain_BP.ChatMain_BP_C", Container="Default", ZOrder=BP_ENUM_UI_CHAT_ZORDER}
	},
    {"Lobby"},
	false,
	bp_chat_main_OnModeSwitched ~= nil,
	true,
	true
  );

  EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_CHAT, LobbyChatLogic.OpenUI);

end

--不做任何事，蓝图里调这个函数将把lua变量的值同步给蓝图变量
function EventFetchInfo()

end

function EventSyncBp2Lua_Push()
end

function EventUpdateSubscriptionKey_Push()
	BP_MAP_GetAccessTokenHeaders["Ocp-Apim-Subscription-Key"] = BP_SubscriptionKey
end

function EventUpdateTranslateContent_Push()
	-- 表情处理
	local Text = LobbyChatLogic.ConvertTextWithEmoji(BP_TranslateContent)

	BP_STRUCT_Detect["Content"] = Text
	BP_STRUCT_Translate["Content"] = Text
end

function bp_chat_main_OnModeSwitched(gamestatus)
	local curStatus = string.lower(gamestatus);
	if "lobby" == curStatus then
		--log("lobbyChat Init");
		--LobbyChatLogic:Init()
	else
		--log("lobbyChat Release");

		if "fighting" == curStatus then
			LobbyChatLogic.chatRoomFightNewMsg = BP_ChatRoomNewMessageCount;
		end

		LobbyChatLogic:Release()
	end
end

function LobbyChatLogic:PreInit()
	BP_ChannelType = LobbyChatSystem.channelWorld;
	BP_ChatMyGID = DataMgr.roleData.uid;
	BP_ChatVoiceMode = LobbyChatSystem.voiceChatMode;
	BP_ChatVoiceOpenMic = LobbyChatSystem.voiceOpenMic;
	BP_ChatVoiceOpenSpeaker = LobbyChatSystem.voiceOpenSpeaker;
	BP_ChatRoomNewMessageCount = LobbyChatLogic.chatRoomFightNewMsg;
	LobbyChatLogic.chatRoomFightNewMsg = 0;
end

function LobbyChatLogic:Init()
	if false == BP_ChatMainValid then
		LuaClassObj.HandleDynamicCreation(bp_chat_main);

		BP_ChatMainValid = true;
		BP_ChannelType = LobbyChatSystem.channelWorld;
		BP_ChatMyGID = DataMgr.roleData.uid;
		BP_ChatVoiceMode = LobbyChatSystem.voiceChatMode;
		BP_ChatVoiceOpenMic = LobbyChatSystem.voiceOpenMic;
		BP_ChatVoiceOpenSpeaker = LobbyChatSystem.voiceOpenSpeaker;
		BP_GameVersion = Client.GetAppVersion();
		LobbyChatSystem.get_channel_list_req();

		LobbyChatLogic.InitChangeRoomTipsData()

		LobbyChatLogic.InitFriendUnreadList();

  		-- LobbyChatSystem.topic_fetch_list_req(BP_TopicLanguage);
		LobbyChatLogic.InitCorpsChatList();

		--默认世界聊天
		BP_Current_TopicId = BP_WorldChannelID;

		LuaClassObj.HandleUIMessage(bp_chat_main, "UIInit");
		LobbyChatLogic.RefreshLanguageState();
	end

	--房间等待时层级问题
	if RoomWaitingUI.IsShow then
		LuaClassObj.SetWidgetZorder(bp_chat_main,0,48)
	else
		LuaClassObj.RestoreWidgetZorder(bp_chat_main,0)
	end
end

function LobbyChatLogic:Release()
	BP_ChannelType = LobbyChatSystem.channelInvalid;
	BP_SelectedFriendGID = "";
	BP_ChatVoiceMode = -1;
	BP_ChatTickBufferList = false;
	BP_ChatVoiceOpenMic = false;
	BP_ChatVoiceOpenSpeaker = false;
	LobbyChatSystem.voiceChatMode = -1;
	BP_ChatIsInCorps = false;
	BP_ChatCorpsNotice = "";

	BP_WorldNewMessageCount = 0;
	BP_FriendNewMessageCount = 0;
	BP_TeamNewMessageCount = 0;
	BP_LocalLanguageMessageCount = 0;
	BP_ChatRoomNewMessageCount = 0;
	BP_TeamRecruitMessageCount = 0;
	BP_ToRemoveMsgId = -1;
	BP_ToGetMsgId = -1;
	BP_ToDoReuseItemDataId = -1;

	BP_ARRAY_WorldChatList = {};
	BP_ARRAY_FriendChatList = {};
	BP_ARRAY_LocalLanguageChatList = {};
	BP_ARRAY_TeamChatList = {};
	BP_ARRAY_ChatroomChatList = {};
	BP_ARRAY_NewChatList = {};
	BP_ARRAY_ChatFriendUnreadList = {};
	BP_ARRAY_ChatFriendList = {};
	BP_ARRAY_ChatVoiceDownloadList = {};
	BP_ARRAY_TeamRecruitList = {};
	BP_ARRAY_ToGetMsg = {};
	BP_ARRAY_ToDoReuseItemData = {};

	LobbyChatroomLogic.ClearChatRoomData();
	LobbyChatroomLogic.Release();
	LobbyChatEmojiLogic.Release();

	LobbyChatLogic.chatBackGroundProfile = false;
	LobbyChatLogic.chatProfileBufferReq = {};
	LobbyChatLogic.chatProfileWorldBufferReq = {};
	LobbyChatLogic.Local_ARRAY_LanguageDataList = {};
	LobbyChatLogic.Local_ARRAY_DataList = {};
	LobbyChatLogic.ChangeRoomTipsData = {}
	BP_ARRAY_TopicList = {};
	BP_ARRAY_LanguageNameList = {};
	BP_ARRAY_TopicRedPointList = {};
	BP_TopicLanguage = 0;
	LobbyChatLogic.IsRefreshWorldChannelMsg = false;
	LobbyChatLogic.HeadDataList = {};
	LobbyChatLogic.HeadDataIndex = 1
	LobbyChatLogic.bTopicListIsReady = false;
	if BP_ChatMainValid then
		BP_ChatMainValid = false;

		LuaClassObj.HandleUIMessage(bp_chat_main, "OnRefreshMsgBufferState");
		LuaClassObj.HandleUIMessage(bp_chat_main, "UIRelease");
	end
	BP_RecruitSameLanguageState = false;
	LobbyChatLogic.StopTimer();
	LobbyChatLogic.StopRoomRecruitTimer();

	--房间等待时层级问题
	if RoomWaitingUI.IsShow then
		LuaClassObj.SetWidgetZorder(bp_chat_main,0,48)
	else
		LuaClassObj.RestoreWidgetZorder(bp_chat_main,0)
	end
end

--[[
	Events
]]

function LobbyChatLogic.OnTeamupInfoChanged(eventType, eventID, vars)
	if eventID == EVENTID_TEAMUP_TEAMINFO_SYNC then
		if nil ~= TeamUpSystem.TeamInfo then
			local isTeamup = TeamUpSystem.TeamInfo.player_count > 1;
			LobbyChatLogic.SetIsTeamUp(isTeamup);
			LobbyChatEntranceUI.SetIsTeamUp(isTeamup);
		end
	end
end

--[[
	msg (struct)
	sender_uid (string)
	sender_name (string)
	msg_content (string)
]]
function LobbyChatLogic.NotifyFriendNewChat(msg, sender_uid, sender_name, msg_content)
	if BP_ChatMainValid then
		if BP_SelectedFriendGID == sender_uid
				and BP_ChannelType == LobbyChatSystem.channelPrivate then
			BP_ARRAY_NewChatList = nil;
			BP_ARRAY_NewChatList = {};
			table.insert(BP_ARRAY_NewChatList, msg);
			BP_ARRAY_FriendChatList = LobbyChatSystem.friendChatList[sender_uid].messageList
			LuaClassObj.HandleUIMessageNoFetch(bp_chat_main, "OnReceiveFriendChatMsg");
		end
	end
end

--[[
	sender_uid (string)
	message_count (number)
]]

function LobbyChatLogic.RefreshUnreadList(sender_uid, message_count)
	if not BP_ChatMainValid then
		return;
	end

	local existItem = false;
	for i = 1, #BP_ARRAY_ChatFriendUnreadList do
		local unread = BP_ARRAY_ChatFriendUnreadList[i];
		if FuncUtil:StrTrim(unread.gid) == sender_uid then
			unread.unreadCount = message_count;
			existItem = true;
			break;
		end
	end

	if not existItem then
		local unreadData = {};
		unreadData.gid = sender_uid;
		unreadData.unreadCount = message_count;
		table.insert(BP_ARRAY_ChatFriendUnreadList, unreadData);
	end

	LuaClassObj.HandleUIMessage(bp_chat_main, "OnNotifyChatUnread");
end

function LobbyChatLogic.RefreshFriendTotalUnread()
	if not BP_ChatMainValid then
		return;
	end

	local unreadCount = 0;
	for k,v in pairs(LobbyChatSystem.friendChatList) do
		unreadCount = unreadCount + v.newMessageCount;
	end

	BP_FriendNewMessageCount = unreadCount;

	LuaClassObj.HandleUIMessage(bp_chat_main, "OnNotifyFriendTotalUnread");
end

function LobbyChatLogic.InitFriendUnreadList()
	if not BP_ChatMainValid then
		return;
	end

	BP_ARRAY_ChatFriendUnreadList = {};

	for k,v in pairs(LobbyChatSystem.friendChatList) do
		local unreadData = {};
		unreadData.gid = k;
		unreadData.unreadCount = v.newMessageCount;
		table.insert(BP_ARRAY_ChatFriendUnreadList, unreadData);
	end
end

-- 获取指定好友的消息未读数量
function LobbyChatLogic.GetFriendUnreadNum(gid)
	for k,v in pairs(BP_ARRAY_ChatFriendUnreadList) do
		if tonumber(v.gid) == tonumber(gid) then
			return v.unreadCount
		end
	end
	return 0
end

function LobbyChatLogic.InitChatRoomChatList()
	if not BP_ChatMainValid then
		return;
	end

	if ("0" ~= BP_ChatMainMyRoomId) and (""~= BP_ChatMainMyRoomId) then
		--log("InitChatRoomChatList " .. BP_ChatMainMyRoomId);

		BP_ARRAY_ChatroomChatList = {};

		for i = 1, #LobbyChatLogic.chatRoomBufferList do
			local buff = LobbyChatLogic.chatRoomBufferList[i];
			table.insert(BP_ARRAY_ChatroomChatList, buff);
		end

		LuaClassObj.HandleUIMessage(bp_chat_main, "InitChatRoomBuffer");
	end
end

function LobbyChatLogic.ClearChatRoomChatList()
	if not BP_ChatMainValid then
		return;
	end

	BP_ARRAY_ChatroomChatList = {};
	LobbyChatLogic.chatRoomBufferList = {};

	LuaClassObj.HandleUIMessageNoFetch(bp_chat_main, "InitChatRoomBuffer");
	LuaClassObj.HandleUIMessageNoFetch(bp_chat_main, "RefreshChatRoom");
end


function LobbyChatLogic.InitCorpsChatList()
	if not BP_ChatMainValid then
		return;
	end

	BP_ARRAY_CorpsChatList = {};

	if 0 ~= DataMgr.corpsInfo.id then
		for i = 1, #LobbyChatLogic.chatCorpsBufferList do
			local buff = LobbyChatLogic.chatCorpsBufferList[i];
			table.insert(BP_ARRAY_CorpsChatList, buff);
		end
	end

	LuaClassObj.HandleUIMessageNoFetch(bp_chat_main, "InitCorpsBuffer");
end


function LobbyChatLogic.ClearCorpsChatList()
	if not BP_ChatMainValid then
		return;
	end

	BP_ARRAY_CorpsChatList = {};
	LobbyChatLogic.chatCorpsBufferList = {};
	LuaClassObj.HandleUIMessageNoFetch(bp_chat_main, "InitCorpsBuffer");
end



function LobbyChatLogic.OpenUI()
	if not LobbyChatSystem.canOpenChatWnd then
		return;
	end
	if false == BP_ChatMainValid then
		LobbyChatLogic:Init();
	end
	LobbyChatLogic.bTopicListIsReady = false;

	if BP_ChatMainValid then
		if not BP_ChatMainFirstShow then
			BP_ChatMainFirstShow = true;
			if BP_ChatIsTeamUp then
				--BP_ChannelType = LobbyChatSystem.channelTeam;
			end
		end

		LuaClassObj.HandleUIMessage(bp_chat_main, "UIShow");
		UIManager.Show(eUIType.eChatMain);
		if UIManager.GetUI(eUIType.eChatRoom) then
			UIManager.Show(eUIType.eChatRoom)
		end

		LobbyChatLogic.RefreshFriendTotalUnread();
		FriendSystem.batchGetTeamInfoList();

		--log("LobbyChatLogic UIShow");
	end
  	LobbyChatSystem.topic_fetch_lang_list_req();

	--sami 打开聊天，拉取离线消息
	LobbyChatSystem.req_get_offline_chat_msg()
	EventSystem:registEvent(EVENTTYPE_CHAT, EVENTTYPE_CHAT_OFFLINE_CHAT_MSG, LobbyChatLogic.OnOfflineChatMsg);
	--军团数据
	if LobbyChatLogic.bAddCropsOfflineChatMsg == false then
		CorpsMgr.SendCorpsDataReq();
	end
end

function EventHideChatNewbieTips()
	DataMgr.SetNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_CHAT, 1)
end

function LobbyChatLogic.OpenChannel(channel_type)
	if not LobbyChatSystem.canOpenChatWnd then
		return;
	end

	if false == BP_ChatMainValid then
		LobbyChatLogic:Init();
	end

	BP_ChannelType = channel_type;
	LuaClassObj.HandleUIMessageNoFetch(bp_chat_main, "UIShow");
	UIManager.Show(eUIType.eChatMain);
	LobbyChatLogic.RefreshFriendTotalUnread();
	FriendSystem.batchGetTeamInfoList(true);

	LobbyChatSystem.req_get_offline_chat_msg()
	EventSystem:registEvent(EVENTTYPE_CHAT, EVENTTYPE_CHAT_OFFLINE_CHAT_MSG, LobbyChatLogic.OnOfflineChatMsg);
end

function LobbyChatLogic.CloseUI()
	if not (BP_ChatMainValid or BP_ChatMainShown) then
		return;
	end

	EventSystem:unregistEvent(EVENTTYPE_CHAT, EVENTTYPE_CHAT_OFFLINE_CHAT_MSG, LobbyChatLogic.OnOfflineChatMsg);

	EventHideChatMainWnd();

	LuaClassObj.HandleUIMessage(bp_chat_main, "UIHide");
	UIManager.Hide(eUIType.eChatMain);
	--log("LobbyChatLogic UIHide");

end

--sami显示聊天
function EventShowLobbyChat()
	--log("LobbyChatLogic.EventShowLobbyChat")
	EventSystem:registEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN, LobbyChatLogic.WardRobeAvatarResetOpen);
    EventSystem:registEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE, LobbyChatLogic.WardRobeAvatarResetClose);
	LobbyChatLogic.isShowing = true;
	LobbyChatSystem.send_open_chat_ui(true);
	if BP_Current_TopicId ~= "" then
		if BP_Current_TopicId ~= "world_Channel" then
		LobbyChatSystem.topic_subscribe_req(BP_Current_TopicId);
	end
end
end

--隐藏聊天
function EventHideLobbyChat()
	--log("LobbyChatLogic.EventHideLobbyChat")
	EventSystem:unregistEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN, LobbyChatLogic.WardRobeAvatarResetOpen);
    EventSystem:unregistEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE, LobbyChatLogic.WardRobeAvatarResetClose);
	LobbyChatLogic.isShowing = false;
	LobbyChatSystem.send_open_chat_ui(false);
	if BP_Current_TopicId ~= nil and BP_Current_TopicId ~= "world_Channel" then
		LobbyChatSystem.topic_unsubscribe_req();
	end
--好友聊天返回bug补丁
	if not RoomWaitingUI.IsShow and not RoomUI.IsShow then
		LuaClassObj.HandleUIMessage(bp_teamup_friend, "ShowBtnPanel");
	end
	LuaClassObj.HandleUIMessage(bp_expression, "UIShowNative")
end

--sami 个人信息角色开关处理
function LobbyChatLogic.WardRobeAvatarResetOpen()
    --log("LobbyChatLogic.WardRobeAvatarResetOpen")
	if(LobbyChatLogic.isShowing == true) then
		LuaClassObj.HandleUIMessage(bp_chat_main, "HideSelf");
		LobbyChatLogic.isShowing = false;
	end
end

function LobbyChatLogic.WardRobeAvatarResetClose()
    --log("LobbyChatLogic.WardRobeAvatarResetClose")
	if LobbyChatLogic.isShowing == false then
		LuaClassObj.HandleUIMessage(bp_chat_main, "ShowSelf")
		LobbyChatLogic.isShowing = true;
	end
end

--[[
	gid: string
]]
function LobbyChatLogic.ChatWithFriend(gid)
	BP_SelectedFriendGID = gid;
	LobbyChatEntranceUI.OpenChatUI();
	Timer.InsertTimer(0.3, LobbyChatLogic.DelayMessage, false);
end

function LobbyChatLogic.DelayMessage()
	LuaClassObj.HandleUIMessage(bp_chat_main, "ScrollToFriend");
end

function LobbyChatLogic.OpenCorpsTab()
	LobbyChatLogic.OpenChannel(LobbyChatSystem.channelCorps);
	LobbyChatLogic.OnCorpsDataChanged();
end


function LobbyChatLogic.SetIsTeamUp(teamUp)
	BP_ChatIsTeamUp = teamUp;

	if false == teamUp then
		BP_ARRAY_TeamChatList = {};
		BP_TeamNewMessageCount = 0;
	end

	if BP_ChatMainValid then
		LuaClassObj.HandleUIMessage(bp_chat_main, "TeamStateChanged");
	end
end

function LobbyChatLogic.OnSendMsgSuccess(msg_id)

	if not BP_ChatMainValid or not BP_ChatMainShown then
		return;
	end

	if LobbyChatLogic.ndRspRateSpeedControl == 0 then
		LobbyChatLogic.endRspRateSpeedControl = os.time();
	end

	if os.time() - LobbyChatLogic.sendRspRateSpeedControl < 2 then
		return;
	end
	LobbyChatLogic.sendRspRateSpeedControl = os.time();
	if "" == msg_id then
		LuaClassObj.HandleUIMessage(bp_chat_main, "OnSendMsgComplete");
	else
		LuaClassObj.HandleUIMessage(bp_chat_main, "OnSendVoiceComplete");
	end
end

function LobbyChatLogic.DeleteFriend(uid)
	if not BP_ChatMainValid then
		return;
	end

	--log("ChatMain Delete Friend 1");

	if BP_SelectedFriendGID == uid then
		--log("ChatMain Delete Friend ");

		LuaClassObj.HandleUIMessage(bp_chat_main, "OnDeleteSelectedFriend");
		BP_SelectedFriendGID = "";
	end
end

function LobbyChatLogic.ClearSomeonesMsg(uid)
	BP_ChatMainClearGID = tostring(uid);

	for i = #BP_ARRAY_WorldChatList, 1, -1 do
		local buf = BP_ARRAY_WorldChatList[i];
		if buf.sender_uid == uid then
			table.remove(BP_ARRAY_WorldChatList, i);
			if BP_ChannelType == LobbyChatSystem.channelWorld then
				LobbyChatLogic.RemoveMsgById(i - 1)
			end
		end
	end

	for i = #BP_ARRAY_LocalLanguageChatList, 1, -1 do
		local buf = BP_ARRAY_LocalLanguageChatList[i];
		if buf.sender_uid == uid then
			table.remove(BP_ARRAY_LocalLanguageChatList, i);
			if BP_ChannelType == LobbyChatSystem.channelLocalLanguage then
				LobbyChatLogic.RemoveMsgById(i - 1)
			end
		end
	end

	for i = #BP_ARRAY_TeamChatList, 1, -1 do
		local buf = BP_ARRAY_TeamChatList[i];
		if buf.sender_uid == uid then
			table.remove(BP_ARRAY_TeamChatList, i);
			if BP_ChannelType == LobbyChatSystem.channelTeam then
				LobbyChatLogic.RemoveMsgById(i - 1)
			end
		end
	end

	for i = #BP_ARRAY_ChatroomChatList, 1, -1 do
		local buf = BP_ARRAY_ChatroomChatList[i];
		if buf.sender_uid == uid then
			table.remove(BP_ARRAY_ChatroomChatList, i);
			if BP_ChannelType == LobbyChatSystem.channelChatRoom then
				LobbyChatLogic.RemoveMsgById(i - 1)
			end
		end
	end

	for i = #BP_ARRAY_TeamRecruitList, 1, -1 do
		local buf = BP_ARRAY_TeamRecruitList[i];
		if buf.sender_uid == uid then
			table.remove(BP_ARRAY_TeamRecruitList, i);
			if BP_ChannelType == LobbyChatSystem.channelTeamRecruit then
				LobbyChatLogic.RemoveMsgById(i - 1)
			end
		end
	end

	for i = #BP_ARRAY_CorpsChatList, 1, -1 do
		local buf = BP_ARRAY_CorpsChatList[i];
		if buf.sender_uid == uid then
			table.remove(BP_ARRAY_CorpsChatList, i);
			if BP_ChannelType == LobbyChatSystem.channelCorps then
				LobbyChatLogic.RemoveMsgById(i - 1)
			end
		end
	end


	BP_WorldNewMessageCount = 0;
	BP_TeamNewMessageCount = 0;
	BP_ChatRoomNewMessageCount = 0;
	BP_LocalLanguageMessageCount = 0;
	BP_FriendNewMessageCount = 0;
	BP_TeamRecruitMessageCount = 0;
	BP_CorpsNewMessageCount = 0;


	if not BP_ChatMainValid then
		return;
	end

	if BP_ChannelType ~= LobbyChatSystem.channelWorld
			and	BP_ChannelType ~= LobbyChatSystem.channelCorps then
		LuaClassObj.HandleUIMessage(bp_chat_main, "ClearSomeonesMsg");
	end
end

function LobbyChatLogic.AddCorpsRecruit(msg_channel, msg_type, sender_uid, sender_name, self_msg, corps_data)
	-- 军团招募需显示 名称，等级，成员信息，地区，点击需要军团Id
	-- 复用原有字段表示以上内容，
	-- icon 表示 军团名
	-- voiceMsgTime 表示 军团level
	-- voicemsgId 表示 军团id
	-- roomId 表示 军团成员信息
	-- roomType 表示 地区信息
	local msg = {};
	msg.name = sender_name;
	msg.msgChannel = msg_channel;
	msg.msgType = msg_type;
	msg.msg = "";
	msg.uid = sender_uid;
	msg.selfMsg = self_msg;
	msg.icon = corps_data.corpsName;
	msg.voiceMsgId = corps_data.corpsId;
	msg.voiceMsgTime = corps_data.corpsLevel;
	msg.roomId = corps_data.corpsMember;
	msg.roomType = corps_data.corpsCity;
	msg.msgSendTime = corps_data.corpsIcon;

	LobbyChatSystem.STATIC_MESSAGE_COUNTER = LobbyChatSystem.STATIC_MESSAGE_COUNTER + 1;
	msg.level = LobbyChatSystem.STATIC_MESSAGE_COUNTER;

	BP_ARRAY_NewChatList = nil;
	BP_ARRAY_NewChatList =
	{
	};

	table.insert(BP_ARRAY_NewChatList, msg);

	if msg_channel == LobbyChatSystem.channelWorld then
		if #BP_ARRAY_WorldChatList >=  LobbyChatSystem.MAX_MESSAGE_CACHE_NUM  then
			table.remove(BP_ARRAY_WorldChatList, 1);
			if BP_ChannelType == LobbyChatSystem.channelWorld then
				LobbyChatLogic.RemoveMsgById(0)
			end
		end

		table.insert(BP_ARRAY_WorldChatList, msg);

		if msg_channel ~= BP_ChannelType then
			BP_WorldNewMessageCount = BP_WorldNewMessageCount + 1;
		end
	end

	if not BP_ChatMainValid then
		return;
	end

	LuaClassObj.HandleUIMessageNoFetch(bp_chat_main, "OnReceiveChatMsg");
	LuaClassObj.HandleUIMessageNoFetch(bp_chat_main, "OnRefreshUnread");
end


--[[
	msg_channel (number)
	sender_name (string)
	voice_file (string)
	voice_length (number)
	chat_content (string)
	sender_uid (string)
	self_msg (bool)
]]
function LobbyChatLogic.AddNewChat(msg_channel, msg_type, sender_name, voice_file, voice_length, chat_content, sender_uid, self_msg, team_id, zone_id, game_model_type, nation, VoiceType, topic, other, avatarData, map_data)
	--zinotag addnewchat的地方
	log("LobbyChatLogic.AddNewChat..");
	--构造聊天数据结构--
	local msg = {};
    msg.name = sender_name;
	msg.msgChannel = msg_channel;
	msg.msgType = msg_type;
	msg.msg = chat_content;
	msg.uid = sender_uid;
	msg.selfMsg = self_msg;
	msg.voiceMsgId = voice_file;
	msg.voiceMsgTime = voice_length;
	msg.roomId = team_id; --保存招募用的teamID,目前使用roomId是因为这个字段以前没人用，就复用了
	msg.zoneId = zone_id;
	msg.game_model_type = game_model_type;
	msg.BP_STRUCT_AvatarData = avatarData;
	if other ~= nil then
        if msg.msgType == LobbyChatSystem.bargainMessageType then

			if sender_uid == DataMgr.roleData.uid then
				return;
			end
            cur_orderid = other.cur_orderid;
            --整合新砍价结构，其他逻辑在状态信息处理
            BP_ARRAY_PDDSystem_CorpsShareOrderList[cur_orderid] = other.owner_id;

            if BargainSystemUI_StateInfo_Map[cur_orderid] == nil then
                BargainSystemUI_StateInfo_Map[cur_orderid] = {};
            end

            BargainSystemUI_StateInfo_Map[cur_orderid].headicon_url = avatarData.url;
            BargainSystemUI_StateInfo_Map[cur_orderid].name = msg.name;
            BargainSystemUI_StateInfo_Map[cur_orderid].id = other.cur_orderid;
            BargainSystemUI_StateInfo_Map[cur_orderid].uid = other.ownerid;
			BargainSystemUI_StateInfo_Map[cur_orderid].itemid = other.item_id;
			BargainSystemUI_StateInfo_Map[cur_orderid].shopid = other.shop_id;
            BargainSystemUI_StateInfo_Map[cur_orderid].frame_level = avatarData.AvatarBox;
            return;
			
            --msg.BP_STRUCT_BargainHelpMessage = other;
            --log_tree("[HHFTEST]LobbyChatLogic.AddNewChat, msg.BP_STRUCT_BargainHelpMessage = ", msg.BP_STRUCT_BargainHelpMessage, "[HHFTEST]");
        else
            msg.BP_STRUCT_ShareAchievementInfo = other;
            msg.BP_STRUCT_ShareAchievementInfo.owner_player_name = sender_name;
            
            end
	end
	if msg.zoneId == nil or msg.zoneId == "" then
		msg.zoneId = TeamUpSystem.ChooseZoneId
	end

	--取当前zone ip
	local zoneIp = "";
	for i,v in pairs(TeamUpSystem.ChooseZoneList) do
		if v.zone_id == msg.zoneId then
			zoneIp = v.tpingsvr_ip;
		end
	end

	msg.zoneIp = zoneIp;

	local zoneCfg = Client.GetTableData("ZoneConfig", msg.zoneId);
	if zoneCfg ~= nil then
		msg.zoneText = zoneCfg.NameInChinese;
	end

	LobbyChatSystem.STATIC_MESSAGE_COUNTER = LobbyChatSystem.STATIC_MESSAGE_COUNTER + 1;
	msg.level = LobbyChatSystem.STATIC_MESSAGE_COUNTER;
    msg.roleNation = nation;
    msg.selfNation = ProfileMgr.GetRoleNationByUid(DataMgr.roleData.uid);

	BP_ARRAY_NewChatList = nil;
	BP_ARRAY_NewChatList =
	{
	};
	--话题消息处理
	if msg_channel == LobbyChatSystem.channelWorld or msg_channel == LobbyChatSystem.channelTopic or msg_channel == LobbyChatSystem.channelTopic2 then
		msg.msg = FuncUtil.GetResultChatMsg(chat_content, {selectPlayer={},topicList={}});
	end


	--[[
	if #BP_ARRAY_NewChatList >= LobbyChatSystem.MAX_MESSAGE_CACHE_NUM then
		table.remove(BP_ARRAY_NewChatList,1);
	end
	]]

	-- 组队招募,自身延迟比较高时,过滤掉其他人发的招募信息
	if msg_channel == LobbyChatSystem.channelTeamRecruit and false == self_msg then
		local serveryDelay = Client.GetServerDelay(zoneIp);
		log("chat servery ip:"..tostring(zoneIp).." delay:"..tostring(serveryDelay).." maxDelay:"..tostring(LobbyChatSystem.maxTeamRecruitDelayTime));
		if serveryDelay > LobbyChatSystem.maxTeamRecruitDelayTime then
			return
		end
	end

	table.insert(BP_ARRAY_NewChatList, msg);
	--log_tree("BP_ARRAY_NewChatList zinotest", BP_ARRAY_NewChatList);

	local curStatus = string.lower(LuaClassObj.GetGameStatus(bp_chat_main));
	if "lobby" ~= curStatus then
		if msg_channel == LobbyChatSystem.channelChatRoom then
			if #LobbyChatLogic.chatRoomBufferList >= LobbyChatSystem.MAX_MESSAGE_CHATROOM_HISTORY_CACHE then
				table.remove(LobbyChatLogic.chatRoomBufferList, 1);
			end

			table.insert(LobbyChatLogic.chatRoomBufferList, msg);
			LobbyChatLogic.chatRoomFightNewMsg = LobbyChatLogic.chatRoomFightNewMsg + 1;
		elseif msg_channel == LobbyChatSystem.channelCorps then
			if #LobbyChatLogic.chatCorpsBufferList >= LobbyChatSystem.MAX_CORPS_MESSAGE_CACHE_NUM then
				table.remove(LobbyChatLogic.chatCorpsBufferList, 1);
			end
			table.insert(LobbyChatLogic.chatCorpsBufferList, msg);
		end

		return;
	end

	if msg_channel == LobbyChatSystem.channelWorld or msg_channel == LobbyChatSystem.channelTopic or msg_channel == LobbyChatSystem.channelTopic2 then
		if topic == nil then
			topic = "world_Channel"
		end
		if BP_Current_TopicId == "" then
			BP_Current_TopicId = topic;
		end
		if not LobbyChatLogic.Local_ARRAY_DataList[topic] then
			LobbyChatLogic.Local_ARRAY_DataList[topic] = {};
		end
		if #LobbyChatLogic.Local_ARRAY_DataList[topic] >= LobbyChatSystem.MAX_MESSAGE_TOPIC_NUM then
			--log("#LobbyChatLogic.Local_ARRAY_DataList[topic].." .. #LobbyChatLogic.Local_ARRAY_DataList[topic]);
			--log("LobbyChatLogic.topic.." .. topic);
			table.remove(LobbyChatLogic.Local_ARRAY_DataList[topic], 1);
			if BP_ChannelType == LobbyChatSystem.channelWorld
					and BP_Current_TopicId == topic then
				LobbyChatLogic.RemoveMsgById(0)
			end
		end
		msg.msgChannel = LobbyChatSystem.channelWorld;
		msg_channel = LobbyChatSystem.channelWorld
		table.insert(LobbyChatLogic.Local_ARRAY_DataList[topic], msg);
		if msg_channel ~= BP_ChannelType then
			BP_WorldNewMessageCount = BP_WorldNewMessageCount + 1;
		end

		BP_ARRAY_WorldChatList = LobbyChatLogic.Local_ARRAY_DataList[BP_Current_TopicId] or {};

		--log_tree("xxxxxxxxxxxxxxxxxx:AddNewChat:", BP_ARRAY_WorldChatList)
		--log("BP_Current_TopicId.." .. BP_Current_TopicId);
		--log_tree("Local_ARRAY_DataList", LobbyChatLogic.Local_ARRAY_DataList);
		--log_tree("BP_ARRAY_WorldChatList", BP_ARRAY_WorldChatList);
		--[[
		if msg_channel == LobbyChatSystem.channelWorld then
			if #BP_ARRAY_WorldChatList >=  LobbyChatSystem.MAX_MESSAGE_CACHE_NUM  then
				table.remove(BP_ARRAY_WorldChatList, 1);
			end

			table.insert(BP_ARRAY_WorldChatList, msg);

			if msg_channel ~= BP_ChannelType then
				BP_WorldNewMessageCount = BP_WorldNewMessageCount + 1;
			end
		end
		]]
	elseif msg_channel == LobbyChatSystem.channelLocalLanguage then
		if #BP_ARRAY_LocalLanguageChatList >= LobbyChatSystem.MAX_MESSAGE_CACHE_NUM  then
			table.remove(BP_ARRAY_LocalLanguageChatList, 1);
			if BP_ChannelType == LobbyChatSystem.channelLocalLanguage then
				LobbyChatLogic.RemoveMsgById(0)
			end
		end

		table.insert(BP_ARRAY_LocalLanguageChatList, msg);

		if msg_channel ~= BP_ChannelType then
			BP_LocalLanguageMessageCount = BP_LocalLanguageMessageCount + 1;
		end
	elseif msg_channel == LobbyChatSystem.channelTeam then
		if #BP_ARRAY_TeamChatList >= LobbyChatSystem.MAX_MESSAGE_CACHE_NUM then
			table.remove(BP_ARRAY_TeamChatList, 1);
			if BP_ChannelType == LobbyChatSystem.channelTeam then
				LobbyChatLogic.RemoveMsgById(0)
			end
		end

		table.insert(BP_ARRAY_TeamChatList, msg);

		if msg_channel ~= BP_ChannelType then
			BP_TeamNewMessageCount = BP_TeamNewMessageCount + 1;
		end
	elseif msg_channel == LobbyChatSystem.channelChatRoom then
		if #BP_ARRAY_ChatroomChatList >= LobbyChatSystem.MAX_MESSAGE_CACHE_NUM then
			table.remove(BP_ARRAY_ChatroomChatList, 1);
			--if BP_ChannelType == LobbyChatSystem.channelChatRoom then
			--	LobbyChatLogic.RemoveMsgById(0)
			--end
			end

		if #LobbyChatLogic.chatRoomBufferList >= LobbyChatSystem.MAX_MESSAGE_CHATROOM_HISTORY_CACHE then
			table.remove(LobbyChatLogic.chatRoomBufferList, 1);
		end

		table.insert(BP_ARRAY_ChatroomChatList, msg);
		table.insert(LobbyChatLogic.chatRoomBufferList, msg);
		--log("chat main " .. tostring(msg_channel) .. " " .. BP_ChatMainMyRoomId);

		if ((msg_channel ~= BP_ChannelType) or (false == BP_ChatMainShown)) and ("0" ~= BP_ChatMainMyRoomId) then
			BP_ChatRoomNewMessageCount = BP_ChatRoomNewMessageCount + 1;
		end
	elseif msg_channel == LobbyChatSystem.channelTeamRecruit then
		if #BP_ARRAY_TeamRecruitList >= LobbyChatSystem.MAX_TEAM_RECRUIT_CACHE_NUM then
			table.remove(BP_ARRAY_TeamRecruitList, 1);
			if BP_ChannelType == LobbyChatSystem.channelTeamRecruit then
				LobbyChatLogic.RemoveMsgById(0)
			end
		end
		if VoiceType ~= nil then
			msg.voiceType = VoiceType;
		end
		--log("LobbyChatSystem.channelTeamRecruit" .. tostring(VoiceType));
		--log("LobbyChatSystem.channelTeamRecruit" .. tostring(BP_RecruitVoiceState));
		--log("LobbyChatSystem.channelTeamRecruit" .. tostring(msg.voiceType));
		if VoiceType ~= nil and VoiceType == 2 and BP_RecruitVoiceState == true then
			--麦克风 消息过滤不显示
			table.remove(BP_ARRAY_NewChatList, 1);
		else
			if msg_type == LobbyChatSystem.teamRecruitMsgType then		-- 组队招募,拼接显示消息，房间招募已经提前拼接
				if map_data then
					msg.msg, msg.voiceMsgId = FuncUtil.TeamRecruitMap(msg.msg, map_data);-- 组队招募使用voiceMsgId，来传递mapdata
				else
					msg.msg = FuncUtil.DeCodeTeamRecruitMsg(msg.msg);					
				end
				table.insert(BP_ARRAY_TeamRecruitList, msg);
			end
		end
		if msg_channel ~= BP_ChannelType then
			BP_TeamRecruitMessageCount = BP_TeamRecruitMessageCount + 1;
		end
	elseif msg_channel == LobbyChatSystem.channelCorps then
		if #BP_ARRAY_CorpsChatList >= LobbyChatSystem.MAX_CORPS_MESSAGE_CACHE_NUM then
			table.remove(BP_ARRAY_CorpsChatList, 1);
			if BP_ChannelType == LobbyChatSystem.channelCorps then
				LobbyChatLogic.RemoveMsgById(0)
			end
		end

		if #LobbyChatLogic.chatCorpsBufferList >= LobbyChatSystem.MAX_MESSAGE_CHATROOM_HISTORY_CACHE then
			table.remove(LobbyChatLogic.chatCorpsBufferList, 1);
		end

		table.insert(BP_ARRAY_CorpsChatList, msg);
		table.insert(LobbyChatLogic.chatCorpsBufferList, msg);

		if msg_channel ~= BP_ChannelType then
			BP_CorpsNewMessageCount = BP_CorpsNewMessageCount + 1;
		end

		BP_ChatEntrance_New_Crops_Num = BP_ChatEntrance_New_Crops_Num + 1
		LuaClassObj.HandleUIMessage(bp_chat_entrance, "YourFriendCalledYou");
	end

	if not BP_ChatMainValid then
		return;
	end

	if LobbyChatLogic.IsReceiveMsg(msg_channel, topic) then
		LuaClassObj.HandleUIMessageNoFetch(bp_chat_main, "OnReceiveChatMsg");
	end

	LuaClassObj.HandleUIMessageNoFetch(bp_chat_main, "OnRefreshUnread");
end

function LobbyChatLogic.IsReceiveMsg(msg_channel, topic)
	--
	-- 消息频道为世界、组队招募、军团频道时，如果聊天界面不打开则不添加消息
	-- 打开聊天界面后：
	--
	-- 消息频道为世界频道、话题频道、话题频道2时， 以下条件符合其一不添加消息：
	-- 1、当前频道不是世界频道；
	-- 2、消息话题不是当前话题；
	-- 3、正在刷新消息。
	--
	-- 消息频道为组队招募时， 以下条件符合其一不添加消息：
	-- 1、当前频道不是组队招募。
	--
	-- 消息频道为军团或军团砍价频道时，以下条件符合其一不添加消息：
	-- 1、当前频道不是军团频道。
	--
	-- PS：好友频道不在此处理
	--
	local IsReceiveMsg = true
	if msg_channel == LobbyChatSystem.channelWorld
			or msg_channel == LobbyChatSystem.channelTopic
			or msg_channel == LobbyChatSystem.channelTopic2
			or msg_channel == LobbyChatSystem.channelPrivate
			or msg_channel == LobbyChatSystem.channelTeamRecruit
			or msg_channel == LobbyChatSystem.channelCorps
			or msg_channel == LobbyChatSystem.channelCorpsBargain then
		if not LobbyChatLogic.isShowing then
			log("在世界、组队招募、军团频道时，如果聊天界面不打开则不添加消息", "martinhtma")
			IsReceiveMsg = false
		end

		if msg_channel == LobbyChatSystem.channelWorld
				or msg_channel == LobbyChatSystem.channelTopic
				or msg_channel == LobbyChatSystem.channelTopic2 then
			log("消息频道为世界频道、话题频道、话题频道2时", "martinhtma")

			if BP_ChannelType ~= LobbyChatSystem.channelWorld then
				log("1、当前频道不是世界频道；", "martinhtma")
				IsReceiveMsg = false
			else
				if topic ~= BP_Current_TopicId
						or LobbyChatLogic.IsRefreshWorldChannelMsg then
					log("2、消息话题不是当前话题；3、正在刷新消息。", "martinhtma")
					IsReceiveMsg = false
				end
			end

		elseif msg_channel == LobbyChatSystem.channelTeamRecruit then
			log("消息频道为组队招募时", "martinhtma")
			if BP_ChannelType ~= LobbyChatSystem.channelTeamRecruit then
				log("1、当前频道不是组队招募。", "martinhtma")
				IsReceiveMsg = false
			end

		elseif msg_channel == LobbyChatSystem.channelCorps
					or msg_channel == LobbyChatSystem.channelCorpsBargain then
			log("消息频道为军团或军团砍价频道时", "martinhtma")
			if BP_ChannelType ~= LobbyChatSystem.channelCorps then
				log("1、当前频道不是军团频道。", "martinhtma")
				IsReceiveMsg = false
			end
		end
	end

	log("LobbyChatLogic.IsReceiveMsg: " .. tostring(IsReceiveMsg), "martinhtma")
	return IsReceiveMsg
end

function LobbyChatLogic.RefreshFriendState()
	if not BP_ChatMainValid then
		return;
	end

	-- EventFetchFriendData();

	LuaClassObj.HandleUIMessage(bp_chat_main, "OnFriendStateChanged");
end

function LobbyChatLogic.RefreshVoiceMode()
	if not BP_ChatMainValid then
		return;
	end

	BP_ChatVoiceMode = LobbyChatSystem.voiceChatMode;
end

function LobbyChatLogic.RefreshMicOpen()
	BP_ChatVoiceOpenMic = LobbyChatSystem.voiceOpenMic;
	BP_ChatVoiceTeamRoom = LobbyChatSystem.voiceEnterRoomId;

	if not BP_ChatMainValid then
		return;
	end

	LuaClassObj.HandleUIMessage(bp_chat_main, "OnVoiceMicOpenChanged");
end

function LobbyChatLogic.RefreshSpeakerOpen()
	if not BP_ChatMainValid then
		return;
	end

	BP_ChatVoiceOpenSpeaker = LobbyChatSystem.voiceOpenSpeaker;
	BP_ChatVoiceTeamRoom = LobbyChatSystem.voiceEnterRoomId;

	LuaClassObj.HandleUIMessage(bp_chat_main, "OnVoiceSpeakerOpenChanged");
end
function LobbyChatLogic.RefreshProfileData(profile)
	if not BP_ChatMainValid then
		return;
	end

	--local friendData = FriendSystem.GetFriendDataByGID(tonumber(profile.gid));
	--if nil ~= friendData then
	--	return;
	--end
	BP_ChatProfileRspGid = profile.gid;
	BP_ChatProfileRspUrl = profile.url;
	BP_ChatProfileRspGender = profile.gender;
	BP_ChatProfileRspNickName = profile.nickName;
	BP_ChatProfileRspLevel = profile.level;
	BP_ChatProfileRspMaxSegment = profile.segmentMax;
	BP_ChatProfileRspAvatarBox = profile.avatarBox;
	BP_ChatProfileRspUpassIsBuy = profile.upassIsBuy or false;
	BP_ChatProfileRspUpassShow = profile.upassShow or false;
	BP_ChatProfileRspAliasId = profile.aliasId;
	BP_ChatProfileRspAliasTitle = profile.aliasTitle;
	BP_ChatProfileRspAliasNation = profile.aliasNation;
	BP_ChatProfileRspRoleNation = profile.roleNation;
	LuaClassObj.HandleUIMessage(bp_chat_main, "OnGetProfileInfo");
	LuaClassObj.HandleUIMessage(bp_chat_main, "onGetUnknowPassProfile");
end

function LobbyChatLogic.HandleVoiceRoomChange(room_name)
	if not BP_ChatMainValid then
		return;
	end

	BP_ChatVoiceTeamRoom = room_name;
	LuaClassObj.HandleUIMessage(bp_chat_main, "OnTeamVoiceRoomChanged");
end

function LobbyChatLogic.OnAfterVoiceInited()
	if not BP_ChatMainValid then
		return;
	end

	LuaClassObj.HandleUIMessage(bp_chat_main, "OnVoiceInited");
end

function LobbyChatLogic.OnJoinRoomSuccess()
	if not BP_ChatMainValid then
		return;
	end

	LuaClassObj.HandleUIMessage(bp_chat_main, "OnJoinRoomSuccess");
end

function LobbyChatLogic.OnQuitRoomSuccess()
	if not BP_ChatMainValid then
		return;
	end

	LuaClassObj.HandleUIMessage(bp_chat_main, "OnQuitRoomSuccess");
end

function LobbyChatLogic.OnClearVoiceProcedure()
	if not BP_ChatMainValid then
		return;
	end

	LuaClassObj.HandleUIMessage(bp_chat_main, "OnClearVoiceProcedure");
end

function LobbyChatLogic.OnStopPlayRecordFile()
	if not BP_ChatMainValid then
		return;
	end

	LuaClassObj.HandleUIMessage(bp_chat_main, "OnStopPlayRecordFile");
end

function LobbyChatLogic.OnStartPlayRecordFile()
	if not BP_ChatMainValid then
		return;
	end

	LuaClassObj.HandleUIMessage(bp_chat_main, "OnStartPlayRecordFile");
end

function LobbyChatLogic.OnStartRecordVoice()

    --log("LobbyChatLogic.OnStartRecordVoice()");
	if not BP_ChatMainValid then
		return;
	end

	LuaClassObj.HandleUIMessage(bp_chat_main, "OnStartRecordVoice");
end

function LobbyChatLogic.OnStopRecordVoice()
	if not BP_ChatMainValid then
		return;
	end

	LuaClassObj.HandleUIMessage(bp_chat_main, "OnStopRecordVoice");
end

function LobbyChatLogic.OnCancelRecordVoice()
	if not BP_ChatMainValid then
		return;
	end

	LuaClassObj.HandleUIMessage(bp_chat_main, "OnCancelVoiceRecord");
end

function LobbyChatLogic.OnUploadRecordVoice()
	if not BP_ChatMainValid then
		return;
	end

	LuaClassObj.HandleUIMessage(bp_chat_main, "OnUploadRecordVoice");
end

function LobbyChatLogic.OnUploadToTextComplete(content, length, msg_id)
	if not BP_ChatMainValid then
		return;
	end

	BP_ChatContent = content;
	BP_ChatVoiceUploadTime = length;
	BP_ChatVoiceUploadMsgId = msg_id;

	--log("upload to text complete .. " .. tostring(length));

	LuaClassObj.HandleUIMessage(bp_chat_main, "OnSpeechToTextComplete");
end

function LobbyChatLogic.OnApplicationDeactivated()
	if not BP_ChatMainValid then
		return;
	end

	LuaClassObj.HandleUIMessage(bp_chat_main, "OnApplicationDeactivated");
end

function LobbyChatLogic.OnRefreshTeamupState()

end

function LobbyChatLogic.CheckHasRightToCreateOrJoinRoom()
	local roomOpenLvStr = DataMgr.GetChatRoomOpenLv();
	local roomOpenLv = roomOpenLvStr == nil and 0 or tonumber(roomOpenLvStr);

	local satisfyLevel = DataMgr.roleData.level >= roomOpenLv;
	if (not satisfyLevel) then
		DataMgr.ShowNoticeByID(106059);
		return false;
	end
	return true;
end

function LobbyChatLogic.CheckHasRightToChat()
	local worldOpenLvStr = DataMgr.GetChatWordOpenLv();
	local worldOpenLv = worldOpenLvStr == nil and 0 or tonumber(worldOpenLvStr);
	if (BP_ChannelType == LobbyChatSystem.channelWorld) then
		local satisfyLevel = DataMgr.roleData.level >= worldOpenLv;
		if (not satisfyLevel) then
			DataMgr.ShowNoticeByID(106017);
			return false;
		end
	elseif (BP_ChannelType == LobbyChatSystem.channelChatRoom) then
		if (BP_ChatMainMyRoomId == "0") then
			DataMgr.ShowNoticeByID(106057);
			return false;
		end
	end
	return true;
end

function LobbyChatLogic.UpdateTeamupMenu(team_state, online)
	if not BP_ChatMainValid then
		return;
	end;

	if 1 == online then
		if 0 == team_state then
			LuaClassObj.HandleUIMessage(bp_chat_main, "OnTeamupStateCanInvice");
		elseif 1 == team_state then
			LuaClassObj.HandleUIMessage(bp_chat_main, "OnTeamupStateCanJoin");
		elseif 2 == team_state then
			LuaClassObj.HandleUIMessage(bp_chat_main, "OnTeamupStateCanInvice");
		end
	end
end

function LobbyChatLogic.OnShowChatroomList()
	LuaClassObj.HandleUIMessage(bp_chat_main, "OnShowChatroomList");
end

function LobbyChatLogic.OnShowMyChatroom()
	LuaClassObj.HandleUIMessage(bp_chat_main, "OnShowMyChatroom");
end

function LobbyChatLogic.ShowHover()
	LuaClassObj.HandleUIMessage(bp_chat_main, "ShowHover");
end

function LobbyChatLogic.HideHover()
	LuaClassObj.HandleUIMessage(bp_chat_main, "HideHover");
end

function LobbyChatLogic.OnEmojiItemClicked(index)
	BP_ChatEmojiClickItem = index;
	LuaClassObj.HandleUIMessage(bp_chat_main, "OnEmojiItemClicked");
end

function LobbyChatLogic.RefreshChatRoom()
	LuaClassObj.HandleUIMessage(bp_chat_main, "RefreshChatRoom");
end

function LobbyChatLogic.ReprofileBaseInfo()
	if false == BP_ChatMainShown then
		return;
	end

	LobbyChatLogic.chatBackGroundProfile = true;
end

function LobbyChatLogic.Tick(currentTick,deltatime)
	if LobbyChatLogic.timeRecord == 0 then
		LobbyChatLogic.timeRecord = currentTick;
	end

	if LobbyChatLogic.timeRecord + LobbyChatLogic.timeForRefresh < currentTick then
		LobbyChatLogic.timeRecord = currentTick;
		if  LobbyChatLogic.IsRefreshWorldChannelMsg == false then
			 	EventPopMessageBuffer();
		end
	end

	if true == BP_ChatEntranceValid and BP_ChatMainShown == false and BP_ChatEntranceNewMsg ~= "" then
		   LuaClassObj.HandleUIMessage(bp_chat_entrance, "YouHaveANewMsg");
	end
	LobbyChatLogic.ReprofileTimerTick();
end

function LobbyChatLogic.ReprofileTimerTick()
	if false == LobbyChatLogic.chatBackGroundProfile then
		return;
	end

	if BP_ChannelType == LobbyChatLogic.channelInvalid or false == BP_ChatMainShown then
		LobbyChatLogic.chatBackGroundProfile = false;
		return;
	end

	if BP_ChannelType == LobbyChatSystem.channelWorld then
		if 0 == #LobbyChatLogic.chatProfileWorldBufferReq then
			LobbyChatLogic.chatBackGroundProfile = false;
			return;
		end
	else
		if 0 == #LobbyChatLogic.chatProfileBufferReq then
			LobbyChatLogic.chatBackGroundProfile = false;
			return;
		end
	end

	if BP_ChannelType == LobbyChatSystem.channelWorld then
		local gid = LobbyChatLogic.chatProfileWorldBufferReq[1];
		LobbyChatSystem.on_profile_req(gid);
		table.remove(LobbyChatLogic.chatProfileWorldBufferReq, 1);
	else
		local gid = LobbyChatLogic.chatProfileBufferReq[1];
		LobbyChatSystem.on_profile_req(gid);
		table.remove(LobbyChatLogic.chatProfileBufferReq, 1);
	end
end


--查找招募聊天信息
function LobbyChatLogic.GetRecruitChatDataByMsgId(msgID)
	--log("BP_ARRAY_ChatroomChatList"..msgID);
	--log_tree("GetRecruitChatDataByMsgId",BP_ARRAY_WorldChatList);
	--log_tree("GetRecruitChatDataByMsgId",BP_ARRAY_LocalLanguageChatList);
	--log_tree("GetRecruitChatDataByMsgId",BP_ARRAY_ChatroomChatList);

	if BP_ChannelType == LobbyChatSystem.channelWorld then
		for k,v in pairs(BP_ARRAY_WorldChatList) do
			--log("ddddd"..tostring(v.level))
			if v.level ~= nil and tonumber(v.level) == tonumber(msgID) then
				return v;
			end
		end
	elseif BP_ChannelType == LobbyChatSystem.channelLocalLanguage then
		for k,v in pairs(BP_ARRAY_LocalLanguageChatList) do
			--log("ddddd"..tostring(v.level))
			if v.level ~= nil and tonumber(v.level) == tonumber(msgID) then
				return v;
			end
		end

	elseif BP_ChannelType  == LobbyChatSystem.channelChatRoom then
		for k,v in pairs(BP_ARRAY_ChatroomChatList) do
			if v.level ~= nil and tonumber(v.level) == tonumber(msgID) then
				return v;
			end
		end
	end

	return nil;
end

function LobbyChatLogic.OnCorpsDataChanged()
	if LobbyChatLogic.lastCorpsId ~= DataMgr.corpsInfo.id then
		LobbyChatLogic.lastCorpsId = DataMgr.corpsInfo.id;
		--LobbyChatLogic.ClearCorpsChatList();
		--if 0 == DataMgr.corpsInfo.id then
		--log("Corps Id Changed last:" .. tostring(LobbyChatLogic.lastCorpsId) .. " current:" .. DataMgr.corpsInfo.id);
		LobbyChatSystem.QuitCorps();
		--end
	end

	BP_ChatIsInCorps = CorpsMgr.IsInCorps();
	BP_ChatCorpsNotice = "";

	if nil ~= DataMgr.corpsInfo and nil ~= DataMgr.corpsInfo.announcement then
		BP_ChatCorpsNotice = Client.GetTableData("LocalizeRes", 410065).TextValue .. DataMgr.corpsInfo.announcement;
	end

	--log("Update Corps Data " .. BP_ChatCorpsNotice .. tostring(BP_ChatIsInCorps));
	--log_tree("LobbyChatLogic.OnCorpsDataChanged()", DataMgr.corpsInfo);

	LuaClassObj.HandleUIMessageNoFetch(bp_chat_main, "OnCorpsStateChanged");
end

function LobbyChatLogic.OnQuitCorps()
	LobbyChatLogic.HideHover();
	LobbyChatLogic.chatCorpsBufferList = {};
	BP_ARRAY_CorpsChatList = {};
	BP_CorpsNewMessageCount = 0;
	LuaClassObj.HandleUIMessageNoFetch(bp_chat_main, "OnQuitCorps");
end

function EventPopMessageBuffer()
	LobbyChatSystem.PopBufferList();
end

--构造Avatar数据
function LobbyChatLogic.GetHeadData(senderuid,sender_name,sendernation,contentdata)
	local headdata = {}
	local uid = tostring(math.floor(senderuid))
	if uid == DataMgr.roleData.uid then
		headdata.Gid = BP_ChatMyGID;
		headdata.Url = DataMgr.roleData.headIconUrl;
		headdata.Level = DataMgr.roleData.level;
		headdata.NickName = DataMgr.roleData.nickName;
		headdata.AvatarBox = DataMgr.roleData.cur_avatar_box_id;
		headdata.AliasId = DataMgr.roleData.alias.id;
		headdata.AliasTitle = DataMgr.roleData.alias.title;
		headdata.AliasNation = DataMgr.roleData.alias.nation;
		headdata.RoleNation = DataMgr.roleData.nation;
		headdata.MaxSegment = DataMgr.GetMaxRankLevel();
		headdata.UpassIsBuy = UnknowPassSystem.IsBuyElite or false;
		headdata.UpassShow = UnknowPassSystem.switch.ui or false;
	else
		headdata.Gid = tostring(math.floor(senderuid));
		headdata.Url = contentdata.url;
		headdata.NickName = sender_name;
		headdata.AvatarBox = contentdata.avatarBox;
		headdata.AliasId = contentdata.aliasid;
		headdata.AliasTitle = FuncUtil:Gen_title(contentdata.aliasid, contentdata.aliarank);
		headdata.AliasNation = contentdata.aliasnation;
		headdata.Level = contentdata.level;

		headdata.RoleNation = sendernation;
		if contentdata.segment_info then
			headdata.MaxSegment = contentdata.segment_info;
		else
			local profile = ProfileMgr.GetPlayerDataByUid(uid)
			if profile then
				headdata.MaxSegment = FuncUtil.GetCurMaxSegementLevel(profile.segment_info)
			end
		end
		
		headdata.UpassShow = true;
		if contentdata.upass ~= nil then
			if contentdata.upass.is_buy ~= nil then
				headdata.UpassIsBuy = true;
			else
				headdata.UpassIsBuy = false;
			end
			if contentdata.upass.switch_battle_title ~= nil then
				headdata.UpassShow = false;
			end
		end
	end
	return headdata
end

function EventGetProfile()
	--zinotag eventgetprofile
	if "" == BP_ChatProfileReqGid then
		return;
	end

	if BP_ChatMainShown then
		if BP_ChatProfileReqGid == BP_ChatMyGID then

			local profileData = {};
			profileData.gid = BP_ChatMyGID;
			profileData.url = DataMgr.roleData.headIconUrl;
			profileData.nickName = DataMgr.roleData.nickName;
			profileData.gender = DataMgr.roleData.gender;
			profileData.level = DataMgr.roleData.level;
			profileData.segmentSolo = DataMgr.roleData.segment.solo;
			profileData.segmentDuo = DataMgr.roleData.segment.double;
			profileData.segmentSquad = DataMgr.roleData.segment.team;
			profileData.segmentMax = DataMgr.GetMaxRankLevel();--math.max(profileData.segmentSolo, profileData.segmentDuo, profileData.segmentSquad);
			profileData.avatarBox = DataMgr.roleData.cur_avatar_box_id;
			profileData.upassIsBuy = UnknowPassSystem.IsBuyElite or false;
			profileData.upassShow = UnknowPassSystem.switch.ui or false;
			profileData.roleNation = DataMgr.roleData.nation;
			profileData.aliasId = DataMgr.roleData.alias.id;
			profileData.aliasTitle = DataMgr.roleData.alias.title;
			profileData.aliasNation = DataMgr.roleData.alias.nation;
			--log(string.format("yyc, mygid case, upassIsBuy = %s , upassShow = %s ", profileData.upassIsBuy, profileData.upassShow));
			table.insert(LobbyChatSystem.chatProfileInfoList, profileData);

			LobbyChatLogic.RefreshProfileData(profileData);
			return;
		else
			local friendData = FriendSystem.GetFriendDataByGID(tonumber(BP_ChatProfileReqGid));
			if nil ~= friendData then
				local profileData = {};
				profileData.gid = BP_ChatProfileReqGid;
				profileData.url = friendData.picUrl;
				profileData.nickName = friendData.nickName;
				profileData.gender = friendData.sex;
				profileData.level = friendData.level;
				profileData.segmentSolo = friendData.segment_info_solo;
				profileData.segmentDuo = friendData.segment_info_duo;
				profileData.segmentSquad = friendData.segment_info_squad;
				profileData.segmentMax = math.max(profileData.segmentSolo, profileData.segmentDuo, profileData.segmentSquad);
				profileData.avatarBox = friendData.cur_avatar_box_id;

				if friendData.upass_is_buy == 0 then
					profileData.upassIsBuy = false;
				else
					profileData.upassIsBuy = true;
				end

				if friendData.upass_is_show == 0 then
					profileData.upassShow = false;
				else
					profileData.upassShow = true;
				end
				profileData.aliasId = friendData.aliasId;
				profileData.aliasTitle = friendData.aliasTitle;
				profileData.aliasNation = friendData.aliasNation;

				--log(string.format("yyc, friend data case, upassIsBuy = %s , upassShow = %s ", profileData.upassIsBuy, profileData.upassShow));
				table.insert(LobbyChatSystem.chatProfileInfoList, profileData);

				LobbyChatLogic.RefreshProfileData(profileData);
				return;
			end
		end
		LobbyChatSystem.on_profile_req(BP_ChatProfileReqGid);
	else
		if BP_ChannelType == LobbyChatSystem.channelWorld then
			if BP_ChatProfileReqGid ~= BP_ChatMyGID then
				local contains = false;
				for i = 1, #LobbyChatLogic.chatProfileWorldBufferReq do
					if BP_ChatProfileReqGid == LobbyChatLogic.chatProfileWorldBufferReq[i] then
						return;
					end
				end

				if #LobbyChatLogic.chatProfileWorldBufferReq > 5 then
					table.remove(LobbyChatLogic.chatProfileWorldBufferReq, 1);
				end

				table.insert(LobbyChatLogic.chatProfileWorldBufferReq, BP_ChatProfileReqGid);
			end
		else
			if BP_ChatProfileReqGid ~= BP_ChatMyGID then
				for i = 1, #LobbyChatLogic.chatProfileBufferReq do
					if BP_ChatProfileReqGid == LobbyChatLogic.chatProfileBufferReq[i] then
						return;
					end
				end

				if #LobbyChatLogic.chatProfileBufferReq > 10 then
					table.remove(LobbyChatLogic.chatProfileBufferReq, 1);
				end

				table.insert(LobbyChatLogic.chatProfileBufferReq, BP_ChatProfileReqGid);
			end
		end
	end
end

function EventSwitchToFriendChat()
	local msgData = LobbyChatSystem.friendChatList[BP_SelectedFriendGID];
	--local msgData = LobbyChatSystem.GetFriendChatItem(BP_SelectedFriendGID);
	if nil == msgData then
		return;
	end

	msgData.newMessageCount = 0;
	LobbyChatSystem.on_notify_friend_unread(BP_SelectedFriendGID, 0);
	-- TODO entrance notify unread
end

function EventTryStartRecordVoice()
	if not BP_ChatMainValid then
		return;
	end

	GlobalChatVoice.TryStartRecordVoice();
end

function EventTryStopRecordVoice()
	if not BP_ChatMainValid then
		return;
	end

	GlobalChatVoice.TryStopRecordVoice();
end

function EventTryCancelRecordVoice()
	if not BP_ChatMainValid then
		return;
	end

	GlobalChatVoice.TryCancelRecordVoice();
end

function EventTryStopPlayRecordVoice()
	if not BP_ChatMainValid then
		return;
	end

	GlobalChatVoice.TryStopPlayRecordVoice();
end

function EventInputChatMsg()
	if not BP_ChatMainValid then
		return;
	end

	local content = BP_ChatInputContent;
	_, _, content = FuncUtil:CheckName(BP_ChatInputContent);

	BP_ChatInputFilteredContent = content;

	LuaClassObj.HandleUIMessage(bp_chat_main, "OnInputTextFiltered");
end

function EventSendChatMsg()
	if not BP_ChatMainValid then
		--log("send msg chat main not valid");
		return;
	end

	local satisfy = LobbyChatLogic.CheckHasRightToChat();
	if (not satisfy) then
		--log("send msg has no right to chat");
		return;
	end

	--sandbox.LogNormal(string.format("send msg [%d][%s][%s]", BP_ChannelType, BP_SelectedFriendGID, BP_ChatContent));

	local content = BP_ChatContent;
	_, _, content = FuncUtil:CheckName(BP_ChatContent);

	if "" == content then
		EventNotifyNoText();
		return;
	end
	--local content = BP_ChatContent;
	local topicList = {};
	local data = {selectPlayer={},topicList={}};
	local channelType = BP_ChannelType;
	if BP_ChannelType == LobbyChatSystem.channelWorld then
		content = FuncUtil.GetResultChatMsg(BP_ChatContent, data);
		--log("EventSendChatMsg...", content);
		--log_tree("EventSendChatMsg", topicList);
		--log_tree("EventSendChatMsg", selectPlayerList);
		--聊天发送内容不处理
		content = BP_ChatContent;
	    -- log_tree("BP_ARRAY_TopicList", BP_ARRAY_TopicList);
	    -- 第一语言100第二语言101处理
	    channelType = LobbyChatSystem.GetChannelType(BP_ChannelType, BP_Current_TopicId);
	end

	--log("channelTypechannelTypechannelType.." .. channelType);
	--log("EventSendChatMsg.." .. content);
	if (BP_ChannelType == LobbyChatSystem.channelChatRoom) and ("0" ~= BP_ChatMainMyRoomId) and (""~= BP_ChatMainMyRoomId) then
		LobbyChatSystem.on_chat_req(tonumber(BP_ChatMainMyRoomId), BP_ChannelType, BP_ChatContent, "");
	else
		LobbyChatSystem.on_chat_req(tonumber(BP_ReceiverGID), channelType, content, BP_Current_TopicId, data.selectPlayer, data.topicList);
		if BP_ChannelType == LobbyChatSystem.channelWorld then
			LobbyChatLogic.Local_ARRAY_SelectPlayerList = {};
		end
	end
end

function EventSendChatVoiceMsg()
	if not BP_ChatMainValid then
		return;
	end

	local satisfy = LobbyChatLogic.CheckHasRightToChat();
	if (not satisfy) then
		return;
	end
	local channelType = BP_ChannelType;

	--sandbox.LogNormal(string.format("send voice msg [%d][%s][%s]", BP_ChannelType, BP_SelectedFriendGID, BP_ChatContent));

	if (BP_ChannelType == LobbyChatSystem.channelChatRoom) and ("0" ~= BP_ChatMainMyRoomId) and (""~= BP_ChatMainMyRoomId) then
		LobbyChatSystem.on_voice_chat_req(tonumber(BP_ChatMainMyRoomId), BP_ChannelType, BP_ChatVoiceUploadMsgId, BP_ChatVoiceUploadTime, BP_ChatContent, BP_Current_TopicId);
	else
		if BP_ChannelType == LobbyChatSystem.channelWorld then
			if BP_Current_TopicId ~= "world_Channel" then
				channelType = LobbyChatSystem.channelTopic;
			end
		end
		LobbyChatSystem.on_voice_chat_req(tonumber(BP_ReceiverGID), channelType, BP_ChatVoiceUploadMsgId, BP_ChatVoiceUploadTime, BP_ChatContent, BP_Current_TopicId);
	end
end

function EventHideChatMainWnd()
	if not LobbyChatSystem.canOpenChatWnd then
		return;
	end

	if not BP_ChatMainValid then
		return;
	end

	BP_ChatMainShown = false;
	LobbyChatEntranceUI:Init()
end

function EventFetchFriendData()
	if not BP_ChatMainValid then
		return;
	end

	BP_ARRAY_ChatFriendList = nil;
	BP_ARRAY_ChatFriendList = {};
	BP_ARRAY_ChatFriendList = FriendSystem.SortFriendList();

	--好友排序，根据未读消息数量进行排序
	table.sort(BP_ARRAY_ChatFriendList, function(a, b)
		local chatNum1 = LobbyChatLogic.GetFriendUnreadNum(a.gid)
		local chatNum2 = LobbyChatLogic.GetFriendUnreadNum(b.gid)
		if a.online > b.online then
			return true
		elseif a.online < b.online then
			return false
		else
			if chatNum1 > chatNum2 then
				return true
			elseif chatNum1 < chatNum2 then
				return false
			else
				return tonumber(a.gid) > tonumber(b.gid)
			end
		end
	end)
	--log_tree("BP_ARRAY_ChatFriendList 2 = ", BP_ARRAY_ChatFriendList)

	if nil == BP_ARRAY_ChatFriendList then
		sandbox.LogNormal("!!!!!!!!!!!!!!!!!!!empty friend list !!!!!!!!!!!!!!!!");
		return;
	end

	BP_ChatOnlineFriendCout = 0;
	BP_ChatTotalFriendCount = #BP_ARRAY_ChatFriendList;
	for i = 1, BP_ChatTotalFriendCount do
		local friendInfo = BP_ARRAY_ChatFriendList[i];
		if friendInfo.online == 1 then
			BP_ChatOnlineFriendCout = BP_ChatOnlineFriendCout + 1;
		end
		if friendInfo.upass_is_buy == 0 then
			BP_ARRAY_ChatFriendList[i].upassIsBuy = false;
		else
			BP_ARRAY_ChatFriendList[i].upassIsBuy = true;
		end

		if friendInfo.upass_is_show == 0 then
			BP_ARRAY_ChatFriendList[i].upassShow = false;
		else
			BP_ARRAY_ChatFriendList[i].upassShow = true;
		end
	end

	LuaClassObj.HandleUIMessageNoFetch(bp_chat_main, "RefreshFriendList");
end

function EventNotifyFriendChatRequireSelect()
	PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", 106019).TextValue);
end

function EventNotifyOutofTextRange()
	PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", 100006).TextValue);
end

function EventNotifyVoiceChatFailToRecord()
	PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", 106012).TextValue);
end

function EventNotifyVoiceRecordTooShort()
	PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", 106015).TextValue);
end

function EventNotifyNoText()
	PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", 106018).TextValue);
end

function EventChangeVoiceChatMode()
end

function EventChangeChannelType()
	--log("chat main " .. tostring(BP_ChatMainShown))
	if BP_ChannelType == LobbyChatSystem.channelWorld then
		BP_WorldNewMessageCount = 0;
	elseif BP_ChannelType == LobbyChatSystem.channelTeam then
		BP_TeamNewMessageCount = 0;
	elseif BP_ChannelType == LobbyChatSystem.channelLocalLanguage then
		BP_LocalLanguageMessageCount = 0;
	elseif BP_ChannelType == LobbyChatSystem.channelPrivate then
		FriendSystem.CheckFetchFriendList();
	elseif BP_ChannelType == LobbyChatSystem.channelChatRoom then
		LobbyChatroomLogic.Show();

		if true == BP_ChatMainShown then
			BP_ChatRoomNewMessageCount = 0;
		end
		LobbyChatSystem.get_channel_list_req();	--切页签则重新读取
	elseif BP_ChannelType == LobbyChatSystem.channelTeamRecruit then
		BP_TeamRecruitMessageCount = 0;
	elseif BP_ChannelType == LobbyChatSystem.channelCorps or BP_ChannelType == LobbyChatSystem.channelCorpsBargain then
		BP_CorpsNewMessageCount = 0;
		-- jaysunzhu 2018.10.8 --story=63172285 【IGame0.9.0版本】前台“拉取好友在线状态”请求量优化
		--if os.time() - LobbyChatLogic.lastCorpsDataReceived > 10 then
		--	LobbyChatLogic.lastCorpsDataReceived = os.time();
		--	if 0 ~= DataMgr.corpsInfo.id then
		--		CorpsMgr.SendCorpsDataReq();
		--	end
		--end

		if 0 ~= DataMgr.corpsInfo.id then
			-- LobbyChatLogic.InitCorpsChatList();
		end

		LobbyChatSystem.ChangeCorpsData();

	end

	if BP_ChannelType ~= LobbyChatSystem.channelChatRoom then
		LobbyChatroomLogic.Hide();
	end

	--if BP_ChannelType == LobbyChatSystem.channelCorps
	--	or BP_ChannelType == LobbyChatSystem.channelWorld then
	--		LuaClassObj.HandleUIMessageNoFetch(bp_chat_main, "ScrollReuseListToEnd")
	--end

	LuaClassObj.HandleUIMessageNoFetch(bp_chat_main, "OnRefreshUnread");
	LobbyChatEntranceUI.RefreshChatroomUnread(BP_ChatRoomNewMessageCount);

	LobbyChatLogic.ReprofileBaseInfo();
	--log("chat main unread " .. tostrig(BP_ChatRoomNewMessageCount))
end

function EventCheckTodayDate()
	BP_ChatTodayDate = os.date("%Y-%m-%d");
end

function EventCheckBlackList()
	BP_ChatHoverIsPullBlack = false;

	if "" == BP_ChatSelectedGID then
		return;
	end

	BP_ChatHoverIsPullBlack = FriendSystem.IsPulBlack(BP_ChatSelectedGID);
end

function EventCheckFriendList()
	BP_ChatHoverIsFriend = false;

	if "" == BP_ChatSelectedGID then
		return;
	end

	BP_ChatHoverIsFriend = FriendSystem.IsMyFriend(BP_ChatSelectedGID);
	--[[
	if nil == BP_ARRAY_ChatFriendList or 0 == #BP_ARRAY_ChatFriendList then
		return;
	end

	for i = 1, #BP_ARRAY_ChatFriendList do
		local friendData = BP_ARRAY_ChatFriendList[i];
		if friendData.gid == BP_ChatSelectedGID then
			BP_ChatHoverIsFriend = true;
			return;
		end
	end]]
end

function EventShowEmoji()
	LobbyChatEmojiLogic.Show()
end

function EventHideEmoji()
	LobbyChatEmojiLogic.Hide()
end

function EventShowHover()
	LobbyChatroomLogic.OnChatMainShowHover();
end

function EventHideHover()

end

function EventHoverShowFriendInfo()
	if "" == BP_ChatSelectedGID then
		return;
	end
	--log("EventHoverShowFriendInfo");
	ProfileMgr.GetProfile(tonumber(BP_ChatSelectedGID), LobbyChatSystem.ProfileCallBack);
	RoleInfoSystem.Enter(BP_ChatSelectedGID);
	RoleInfoUI.Init(true, RoleInfoOpenFromType.LobbyChat);
end

function EventHoverAddFriend()
	if "" == BP_ChatSelectedGID then
		return;
	end

	local msgId = 2;
	local fromType = BP_ENUM_ADD_FRIEND_FROM_CHAT;
	if LobbyChatSystem.channelCorps == BP_ChannelType or LobbyChatSystem.channelCorpsBargain == BP_ChannelType then
		fromType = BP_ENUM_ADD_FRIEND_FROM_CORPS;
		msgId = 20;
		if 1 == BP_ChatSelectedGender then
			msgId = 19;
		end
	elseif LobbyChatSystem.channelChatRoom == BP_ChannelType then
		msgId = 4;
		if 1 == BP_ChatSelectedGender then
			msgId = 3;
		end
	elseif LobbyChatSystem.channelTeamRecruit == BP_ChannelType then
		fromType = BP_ENUM_ADD_FRIEND_FROM_TEAMRECRUIT;
		msgId = 36;
		if 1 == BP_ChatSelectedGender then
			msgId = 35;
		end
	else
		if 1 == BP_ChatSelectedGender then
			msgId = 1;
		end
	end

	FriendSystem.AddFriend(BP_ChatSelectedGID,fromType, msgId);
end

function EventHoverBlockTarget()
	if "" == BP_ChatSelectedGID then
		return;
	end

	if true == BP_ChatHoverIsPullBlack then
		DataMgr.ShowNoticeByID(106065);
	else
		FriendSystem.AddBlack(BP_ChatSelectedGID);
	end
end

function EventHoverInviteTeam()
	if "" == BP_ChatHoverGID then
		return;
	end

	TeamUpSystem.team_invite_request(tonumber(BP_ChatHoverGID));

end

function EventHoverJoinTeam()
	if "" == BP_ChatHoverGID then
		return;
	end

	TeamUpSystem.team_apply_request(tonumber(BP_ChatHoverGID));
end

function EventHoverReportTarget()
	if "" == BP_ChatHoverGID or "" == BP_ChatHoverContent or "" == BP_ChatHoverName then
		--log("report target" .. BP_ChatHoverGID .. BP_ChatHoverContent.. BP_ChatHoverName );
		return;
	end

	LobbyChatSystem.on_report_req(BP_ChatHoverGID, BP_ChatHoverName, BP_ChatHoverContent);
end

function EventRecruitMember()
	--log("EventRecruitMember:"..BP_ChatRecruitJoinGid.."--temid:"..BP_ChatRecruitTeamID)
	if "" == BP_ChatRecruitJoinGid then
		return;
	end

	if "" == BP_ChatRecruitTeamID then
		return;
	end

	if BP_ChatMsgType == LobbyChatSystem.roomRecruitMsgType then
		RoomUpSystem.JoinRoomReq(BP_ChatRecruitTeamID)
	else
		local src = "normal";
		if BP_ChannelType == LobbyChatSystem.channelWorld then
			src="world-chat";
		elseif BP_ChannelType == LobbyChatSystem.channelChatRoom then
			src="channel-chat";
		end

		local chatData =  LobbyChatLogic.GetRecruitChatDataByMsgId(BP_ChatMsgID);

		if chatData ~= nil and chatData.game_model_type ~= nil then

			-- 天命圈！！！！！！！
			if tonumber(chatData.game_model_type) == 2 then

				local isNeedShow = TeamUpUI.NeedShowDestinyLimit();
				if isNeedShow == true then
					--弹出提示
					TeamUpUI.ShowDestinyLimit(isNeedShow);
					return;
				end

			end
			--第一人称
			if tonumber(chatData.game_model_type) == 3 then
				local isNeedShow = TeamUpUI.NeedShowFirstPersonLimit();
				if isNeedShow == true then
					--弹出提示
					TeamUpUI.ShowFirstPersonLimit();
					return;
				end
			end
		end

		-- 组队招募频道，当所有地图pve等级大于玩家等级，提示不能进入加入
		if BP_ChannelType == LobbyChatSystem.channelTeamRecruit then
			for k,v in pairs(BP_ARRAY_TeamRecruitList) do
				if v.level ~= nil and tonumber(v.level) == tonumber(BP_ChatMsgID) and nil ~= v.voiceMsgId then
					if false == FuncUtil.LevelEnough(v.voiceMsgId) then
						DataMgr.ShowNoticeByID(6817);
						return;
					end
					break;
				end
			end
		end

		TeamUpSystem.JoinTeamByChat(BP_ChatRecruitJoinGid,BP_ChatRecruitTeamID, src);
		--JoinTeamByChat();
	end
end

function EventClickCorpsRecruit()
	if "" == BP_ChatRecruitJoinGid then
		return;
	end

	local thisTime = os.time();
	if thisTime - LobbyChatLogic.lastCorpsRecruitClicked < 5 then
		DataMgr.ShowNoticeByID(110092);
		return;
	end

	-- log_tree("EventClickCorpsRecruit BP_ChatRecruitJoinGid "..BP_ChatRecruitJoinGid)
	-- CorpsMgr.get_corps_summary_req(tonumber(BP_ChatRecruitJoinGid));
	CorpsInvitationUI.RequestShowUI(tonumber(BP_ChatRecruitJoinGid), CorpsInvitationUI.isShowApply);
end

function EventClickCorpsGoto()
	LobbyChatLogic.CloseUI();
	LobbySystem.OpenCorpsUI();
end

function EventOpenRecruitPanel()
	RecruitUI.ShowUI();
end

function EventClickFriendItem()
	if not BP_ChatMainValid then
		return;
	end

	if false == BP_ChatMainShown then
		return;
	end

	--log("friend chat click .. " .. BP_SelectedFriendGID);

	local msgData = LobbyChatSystem.friendChatList[FuncUtil:StrTrim(BP_SelectedFriendGID)];
	--local msgData = LobbyChatSystem.friendChatList[BP_SelectedFriendGID];
	--local msgData = LobbyChatSystem.GetFriendChatItem(BP_SelectedFriendGID);
	if nil ~= msgData then
		msgData.newMessageCount = 0;
		BP_ARRAY_FriendChatList = FuncUtil:CopyTable(msgData.messageList);
	else
		BP_ARRAY_FriendChatList = {};
	end

	LobbyChatLogic.RefreshUnreadList(BP_SelectedFriendGID, 0);
	LobbyChatSystem.RefreshTotalUnread();
end

function EventDownloadVoiceFile()
	if not BP_ChatMainValid then
		return;
	end

	GlobalChatVoice.AddDownloadFile(BP_ChatVoiceDownloadOwnerGid, "", BP_ChatVoiceDownloadChannel,
		BP_ChatVoiceDownloadMsgId, BP_ChatVoiceDownloadMsgLength, BP_ChatVoiceDownloadFileId);
end

function EventAchieveVoiceRoom()
	BP_ChatVoiceTeamRoom = LobbyChatSystem.voiceEnterRoomId;
end

function EventInitJoinRoom()
end

function EventOnAfterShowWnd()
	LobbyChatSystem.chatWndOpen = true;
	BP_ChatMainShown = true;
	TeamUpSystem.recv_stau_request(true);

	if BP_ChannelType == LobbyChatSystem.channelChatRoom then
		LobbyChatroomLogic.Show()
	end

	LobbyChatLogic.ReprofileBaseInfo();
	-- EventClickFriendItem();
end

function EventOnAfterHideWnd()
	LobbyChatSystem.chatWndOpen = false;

	TeamUpSystem.recv_stau_request(false);

	LobbyChatroomLogic.Hide();
	LobbyChatEmojiLogic.Hide();
end

function EventRequireHoverTeamup()
	if "" == BP_ChatHoverGID then
		return;
	end

	TeamUpSystem.stange_all_status_request(BP_ChatHoverGID);
end

function EventChatRequestPrivacy()
	local function savePrivacyAcceptStatus()
		BP_ChatPrivacyCurVersion = BP_GameVersion;
		LuaClassObj.HandleUIMessage(bp_chat_main, "OnChatPrivacyAccepted");

	end

	CommonMessageBoxUI:ShowPanel(2, DataMgr.GetMsgByID(102012), DataMgr.GetMsgByID(4074), savePrivacyAcceptStatus,nil,DataMgr.GetMsgByID(110036),DataMgr.GetMsgByID(110035));
end

function LobbyChatLogic.ConvertTextWithEmoji(src)
	local dst = src;
	for emoji in string.gmatch(src, "<img src=\"Emoji1_22_%d+\"/>") do
		local bgStr = "<img src=\"Emoji1_22_"
		local edStr = "\"/>"
		local i = string.find(emoji, bgStr)
		i = i + #bgStr
		local j = string.find(emoji, edStr)
		local num = string.sub(emoji, i, j - 1)
		dst = string.gsub(dst, emoji, "<" .. num .. ">", 1);
	end
	return dst
end

function LobbyChatLogic.RevertTextWithEmoji(src)
	local dst = src;
	for emoji in string.gmatch(src, "<%d+>") do
		local num = string.match(emoji, "%d+");
		dst = string.gsub(dst, "<" .. num .. ">", "<img src=\"Emoji1_22_" .. num .. "\"/>", 1);
	end
	return dst
end

function LobbyChatLogic.OnGetAccessToken(Token)
	BP_MAP_DetectHeaders["Authorization"] = Token
	BP_MAP_TranslateHeaders["Authorization"] = Token
	LuaClassObj.HandleUIMessage(bp_chat_main, "OnGetAccessToken");
end

function LobbyChatLogic.OnDetect(From, _)
	--翻译到第一语言
	local FirstLanguage = {}
	FirstLanguage.id = 0
	FirstLanguage.name = ""
	for i, v in ipairs(BP_ChatLanguageDataList) do
		if v.id == DataMgr.FirstSecondLanguage[1] then
			FirstLanguage = v
			if FirstLanguage.id == 103 then
				FirstLanguage.name = "zh-TW"
			end
			break
		end
	end
	BP_STRUCT_Translate.URL = BP_STRUCT_Translate.URLOrigin .. "&from=" .. From .. "&to=" .. FirstLanguage.name
	LuaClassObj.HandleUIMessage(bp_chat_main, "OnDetect")
end

function LobbyChatLogic.OnTranslate(ChatChannel, ChatId, LanguageFrom, Text)
    BP_ChatTranslateChannel = ChatChannel;
    BP_ChatTranslateID = ChatId;
	BP_ChatLanguageFrom = LanguageFrom;
	if BP_ChatTranslateChannel == LobbyChatSystem.channelWorld then
		BP_ChatTranslateText = FuncUtil.GetResultChatMsg(Text, {selectPlayer={},topicList={}});
	else
		BP_ChatTranslateText = Text;
	end

	-- 表情还原
	BP_ChatTranslateText = LobbyChatLogic.RevertTextWithEmoji(BP_ChatTranslateText)

	LuaClassObj.HandleUIMessage(bp_chat_main, "OnTranslate");
end

function LobbyChatLogic.SetTranslateContent(Content)
end

function LobbyChatLogic.TopicListIsReady(newSelectTopicId)
	LuaClassObj.HandleUIMessage(bp_chat_main, "InitTopic");
	LobbyChatLogic.bTopicListIsReady = true
	if newSelectTopicId then
		BP_Current_TopicId = newSelectTopicId;
		--BP_Current_TopicId = "world_Channel"
		EventCheckTopic();
	end
end

function EventCheckTopic()
	if BP_Current_TopicId ~= "" and LobbyChatLogic.bTopicListIsReady then
		if BP_Current_TopicId == "world_Channel" then
			--世界聊天，后台不处理，因为数据一直有收客户端自己切频道，这里只需要取消订阅
			LobbyChatSystem.topic_unsubscribe_req();
			BP_ARRAY_WorldChatList = LobbyChatLogic.Local_ARRAY_DataList[BP_Current_TopicId] or {};
			LuaClassObj.HandleUIMessage(bp_chat_main, "HideSwitchTopicLanguage")
			LobbyChatLogic.RefreshWorldChannelMsg();
		else
		--	if  LobbyChatLogic.IsRefreshWorldChannelMsg  == true then
		--		-- BP_ARRAY_WorldChatList = {};
		--		BP_ARRAY_WorldChatList = LobbyChatLogic.Local_ARRAY_DataList[BP_Current_TopicId] or {};
		--		LuaClassObj.HandleUIMessage(bp_chat_main, "RefreshWorldChannelMsg");
		--		LobbyChatLogic.IsRefreshWorldChannelMsg  = false;
		--		--log_tree("xxxxxxxxxxxxxxxxx:IsRefreWorldChannelMsg: ",BP_ARRAY_WorldChatList)
		--	end
			LobbyChatSystem.topic_subscribe_req(BP_Current_TopicId);
			if LobbyChatLogic.isShowSwitchTopicLanguage then
				LuaClassObj.HandleUIMessage(bp_chat_main, "ShowSwitchTopicLanguage")
			end
		end
		LobbyChatLogic.UpdateRedPoint(BP_Current_TopicId, 0, true);
	end
end

-- 是否需要显示 选第二语言顶栏
BP_NeedShowSwitchTopicLanguage = true;
-- 展示第二语言栏的事件间隔
BP_ShowSwitchTopicLanguageTimeSpan = 0;

function EventOnClickSwitchTopicLanguage( )
	LobbyChatLogic.isShowSwitchTopicLanguage = true
	-- ChatTopicLanguage.ShowUI()
	ChatLanguageSelect.Show();
	ChatLanguageSelect.ShowTips();
end

function EventOnClickNotSwitchTopicLanguage( )
	LobbyChatLogic.isShowSwitchTopicLanguage = false
end

function LobbyChatLogic.TopicLanguageListReady()
	EventOnTopicLanguageChange();

    local bUIAutoTest = Client.IsUIAutoTest();
	if DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_CHAT, 1) and not bUIAutoTest then
    	LuaClassObj.HandleUIMessage(bp_chat_main, "ShowNewbieTips");
    end

	BP_ARRAY_LanguageDataList = BP_ChatLanguageDataList;
   	LuaClassObj.HandleUIMessage(bp_chat_main, "RefreshSecondLanguageData");
end

function EventOnTopicLanguageChange()
	local id = LobbyChatLogic.Local_ARRAY_LanguageDataList[BP_ARRAY_LanguageNameList[BP_TopicLanguage+1]];
	--log("EventOnTopicLanguageChange.." .. id);
	-- if id ~= nil then
	-- 	LobbyChatSystem.topic_fetch_list_req(id);
	-- end
end

function LobbyChatLogic.RefreshWorldChannelMsg()
	--log("Refresh worldChannel Msg!!!!!"..tostring(LobbyChatLogic.IsRefreshWorldChannelMsg));
	if BP_ChannelType ~= LobbyChatSystem.channelWorld
			or LobbyChatLogic.IsRefreshWorldChannelMsg == true then
		return;
	end
	LobbyChatLogic.IsRefreshWorldChannelMsg = true;
	BP_ARRAY_WorldChatList = LobbyChatLogic.Local_ARRAY_DataList[BP_Current_TopicId] or {};
	--log_tree("xxxxxxxxxxxxxxxxx:LobbyChatLogic.RefreshWorldChannelMsg: ",BP_ARRAY_WorldChatList)
	--log("LobbyChatLogic.RefreshWorldChannelMsg.." .. #BP_ARRAY_WorldChatList);
	LuaClassObj.HandleUIMessage(bp_chat_main, "RefreshWorldChannelMsg");
end

function EventShowWorldTopicIntorduce()
    PopUpNoticeUI.ShowMessageBox(Client.GetTableData("LocalizeRes", "4763").TextValue,Client.GetTableData("LocalizeRes", "4764").TextValue);
end


function EventOnSelectPlayer()
	--log("EventOnSelectPlayer..BP_ChatHoverGID.." .. BP_ChatHoverGID);
	--log("EventOnSelectPlayer..BP_ChatHoverName.." .. BP_ChatHoverName);
	local item = {}
	item.gid = BP_ChatHoverGID;
	item.name = BP_ChatHoverName;
	table.insert(LobbyChatLogic.Local_ARRAY_SelectPlayerList, item);
end

function LobbyChatLogic.UpdateRedPoint(topicId, num, isClear)
	BP_CurrentRedPoint_Number = 0;
	for k, v in pairs(BP_ARRAY_TopicRedPointList) do
		if v.topicId == topicId then
			if isClear then
				v.num = num;
			else
				v.num = v.num + 1;
			end
			--当前频道正打开，不提示
			if topicId == BP_Current_TopicId then
				v.num = 0;
			end
		end
		BP_CurrentRedPoint_Number = BP_CurrentRedPoint_Number + v.num;
	end
	LuaClassObj.HandleUIMessage(bp_chat_main, "UpdateTopicRedPoint");
end

function EventOnCheckRecruitVoiceState()
	if BP_RecruitVoiceState == true then
		for i = #BP_ARRAY_TeamRecruitList, 1, -1 do
			local buf = BP_ARRAY_TeamRecruitList[i];
			if buf.voiceType == 2 then
				table.remove(BP_ARRAY_TeamRecruitList, i);
				if BP_ChannelType == LobbyChatSystem.channelTeamRecruit then
					LobbyChatLogic.RemoveMsgById(i - 1)
				end
			end
		end
		LuaClassObj.HandleUIMessageNoFetch(bp_chat_main, "RefresTeamRecruitListlMsg");
	end
end

function EventSetRefreshWorldChannelStart()
	LobbyChatLogic.IsRefreshWorldChannelMsg = true;
end

function EventRefreshWorldChannelMsgEnd()
	LobbyChatLogic.IsRefreshWorldChannelMsg = false;
end

--分享按钮
function EventShowChatShare()
	-- log("EventShowChatShare");
	ChatShareAchievement.Show();

	BP_AchievementShareSelectPlayer = 0;
	BP_AchievementShareTopicList = {};
	if (BP_ChannelType == LobbyChatSystem.channelChatRoom) and ("0" ~= BP_ChatMainMyRoomId) and (""~= BP_ChatMainMyRoomId) then
		BP_AchievementShareReceiverId = tonumber(BP_ChatMainMyRoomId);
	else
		BP_AchievementShareReceiverId = tonumber(BP_ReceiverGID);
		local data = {selectPlayer={},topicList={}};
		if BP_ChannelType == LobbyChatSystem.channelWorld then
			content = FuncUtil.GetResultChatMsg(BP_ChatContent, data);
			BP_AchievementShareSelectPlayer = data.selectPlayer;
			BP_AchievementShareTopicList = data.topicList;
		end
	end

	BP_AchievementShareChannel = BP_ChannelType;
	BP_AchievementShareTopicId = BP_Current_TopicId;
end

BP_ShareAchievementPositionX = 0;	--显示位置
--分享详情
function EventShowChatShareIntroduce()
	-- log("Share "..tostring(BP_ShareAchievementItemId));

	BP_STRUCT_ChatShareAchievementInfoShow = BP_STRUCT_ShareAchievementInfo;

	ChatShareAchievementShow.ShowData(BP_ShareAchievementPositionX);
end

-- 选中要显示话题的语言（第二语言）
-- 根据选中的语言获取话题列表
function EventGetTopicList()
	-- log_tree("BP_ARRAY_LanguageNameList ", BP_ARRAY_LanguageNameList);
	-- log_tree("DataMgr.FirstSecondLanguage", DataMgr.FirstSecondLanguage);
	-- log("Share "..tostring(BP_ShareAchievementItemId));
	if  DataMgr.FirstSecondLanguage ~= nil then
		LobbyChatSystem.topic_fetch_list_id_req(DataMgr.FirstSecondLanguage);
	end
end

NeedShowChangeWorldChannelTip = false;
BP_ChangeWorldChannelTipName = "";
-- 需要展示切换世界频道提示
function EventShowChangeWorldChannelTip()
	--log("xxxxxxxxxxxxxxxxxxxxxxxxx:"..tostring(BP_Current_TopicId))
	--log(debug.traceback())
	NeedShowChangeWorldChannelTip = true;
	local roomName = "";
	if BP_Current_TopicId == "world_Channel" then
		roomName = FuncUtil.GetLocalizeResStr("4736");
	else
		for k,v in pairs(BP_ARRAY_TopicList) do
			if v.id == BP_Current_TopicId then
				roomName = v.name;
				break;
			end
		end
	end
	BP_ChangeWorldChannelTipName = string.format(FuncUtil.GetLocalizeResStr("5030"), "#"..roomName);

	if NeedShowChangeWorldChannelTip == true then
		local data = LobbyChatLogic.ChangeRoomTipsData
		data.msg = BP_ChangeWorldChannelTipName
		if BP_Current_TopicId == "" then
			BP_Current_TopicId = "world_Channel"
		end
		if not LobbyChatLogic.Local_ARRAY_DataList[BP_Current_TopicId] then
			LobbyChatLogic.Local_ARRAY_DataList[BP_Current_TopicId] = {}
		end

		for k, v in pairs(LobbyChatLogic.Local_ARRAY_DataList[BP_Current_TopicId]) do
			if v.msgType == LobbyChatSystem.changeRoomTipsMsgType then
				table.remove(LobbyChatLogic.Local_ARRAY_DataList[BP_Current_TopicId], k)
				break
			end
		end

		table.insert(LobbyChatLogic.Local_ARRAY_DataList[BP_Current_TopicId], data)
	end
	BP_ARRAY_WorldChatList = LobbyChatLogic.Local_ARRAY_DataList[BP_Current_TopicId]
	--LuaClassObj.HandleUIMessageNoFetch(bp_chat_main,"RefreshReuseList")
end

-- 第二语言修改，更新话题
function LobbyChatLogic.OnSecondLanguageChange()
	LuaClassObj.HandleUIMessage(bp_chat_main, "RefreshSecondLanguageData");
end

-- 组队招募相同语言状态修改
function EventSameLanguageStateChange()
	if LobbyChatLogic.SameLanguageTimer ~= nil then
		PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", "120164").TextValue);
	else
		local sameLanguage = not BP_RecruitSameLanguageState;
		LobbyChatSystem.set_recv_other_language_req(sameLanguage);
		LobbyChatLogic.StartTimer();
	end
end

function LobbyChatLogic.StartTimer()
	LobbyChatLogic.StopTimer();
	LobbyChatLogic.SameLanguageTimer = Timer.InsertTimer(2, LobbyChatLogic.StopTimer, false);
end

function LobbyChatLogic.StopTimer()
	if LobbyChatLogic.SameLanguageTimer ~= nil then
		Timer.RemoveTimer(LobbyChatLogic.SameLanguageTimer);
		LobbyChatLogic.SameLanguageTimer = nil;
	end
end

-- 等组队招募相同语言服务器回包，同步修改蓝图显示
function LobbyChatLogic.RefreshLanguageState()
	BP_RecruitSameLanguageState = LobbyChatSystem.recvSameLanguage;
	LuaClassObj.HandleUIMessage(bp_chat_main, "RefreshSameLanguageState");
end

--sami 增加好友离线缓存消息
function LobbyChatLogic.OnOfflineChatMsg()
	log("LobbyChatLogic.OnOfflineChatMsg")
	local msgList = LobbyChatSystem.resOfflineChatMsg
	if msgList == nil then
		return
	end
	local IsRefreshAll = false
	if #msgList > 10 then
		IsRefreshAll = true
	end
	for k, v in pairs(msgList) do
		local gid = v.receiver_uid
		local sendGid = v.send_uid
		local chatData = v

		local msg = {}
		msg.chat_type = chatData.chat_type;
		msg.sender_name = chatData.sender_name;
		msg.msg_id = chatData.msg_id;
		msg.chat_content = chatData.chat_content;
		msg.sender_uid = chatData.send_uid;
		msg.zone_id = chatData.zone_id;
		msg.roleNation = chatData.nation;
		if IsRefreshAll then
			LobbyChatSystem.chat_true_notify(msg.chat_type, msg.sender_name, msg.msg_id, msg.chat_content, msg.sender_uid, msg.roleNation)
		else
			table.insert(LobbyChatSystem.chatFriendBufferList, msg)
		end
	end
	--log_tree("xxxxxxxxxxxxxxxxx:LobbyChatSystem.chatFriendBufferList",LobbyChatSystem.chatFriendBufferList)
end

-- sami 增加军团离线缓存消息
function LobbyChatLogic.AddOfflineCorpsChatMsg(corpsData)
	log("LobbyChatLogic.AddOfflineCorpsChatMsg")
	if LobbyChatLogic.bAddCropsOfflineChatMsg then
		return
	end	
	LobbyChatLogic.bAddCropsOfflineChatMsg = true
	if corpsData == nil or (corpsData.chat_data == nil and corpsData.pdd_data == nil) then
		return
	end	
	
	local num = 0;
	local chatDataList = {};
	local uidMap = {}
	local uidList = {}
	
	local msgList = corpsData.chat_data
	if msgList ~= nil then
		for k, v in pairs(msgList) do
			local bSelfMsg = (tonumber(v.send_uid) == tonumber(DataMgr.roleData.uid))
			v.data.text = LobbyChatSystem.ReplaceEmoji(v.data.text);

			local avatarData = LobbyChatLogic.GetHeadData(v.send_uid,v.sender_name,v.nation,v.data)
			local msg = {}
			msg.Type = 0
			msg.chat_type = v.chat_type
			msg.msgType = v.data.msgType
			msg.sender_name = v.sender_name
			msg.voice = v.data.voice
			msg.voiceLength = v.data.voiceLength
			msg.text = v.data.text
			msg.send_uid = v.send_uid
			msg.bSelfMsg = bSelfMsg
			msg.nation = v.nation
			msg.topic = v.data.topic
			msg.other = v.data.other
			msg.create_time = v.create_time
			msg.avatarData = avatarData

			table.insert(chatDataList, msg)

			local profile = ProfileMgr.GetPlayerDataByUid(v.send_uid)
			if profile == nil then
				uidMap[v.send_uid] = 1
			end

			if v.create_time > LoginSystem.lastLogoutTime then
				num = num + 1
			end
		end
	end
	--log_tree("msgList = ", msgList)
	
	-- 拼多多离线消息
	local pinList = corpsData.pdd_data
	if pinList ~= nil then
		for k, v in pairs(pinList) do
			local bSelfMsg = (tonumber(v.data.other.owner_id) == tonumber(DataMgr.roleData.uid))
			local senderName = ""
			if v.sender_name ~= nil then
				senderName = v.sender_name
			end
			v.data.other.have_bargained = PDD_System_UI.HaveBargainedByOrderID(v.data.other.cur_orderid);
			v.data.other.description = Bargain_Detail_UI.GetDescForChat(v.data.other.channel, v.data.other.item_id, v.data.other.ori_price, v.data.other.description);
			local avatarData = LobbyChatLogic.GetHeadData(v.send_uid,v.sender_name,v.nation,v.data)

			local msg = {}
			msg.Type = 1
			msg.chat_type = 25
			msg.msgType = v.data.msgType
			msg.sender_name = senderName
			msg.voice = ""
			msg.voiceLength = 0
			msg.text = v.data.other.description
			msg.send_uid = v.data.other.owner_id
			msg.bSelfMsg = bSelfMsg
			msg.nation = v.nation
			msg.topic = ""
			msg.other = v.data.other
			msg.create_time = v.create_time
			msg.avatarData = avatarData

			table.insert(chatDataList, msg)

			
			if v.create_time > LoginSystem.lastLogoutTime then
				BP_PDDSystem_InviteRedDot = true;
				EventShowPDDSystemReddot();
				LobbyUI.UpdatePDDSystemReddot();
			end

			local profile = ProfileMgr.GetPlayerDataByUid(v.send_uid)
			if profile == nil then
				uidMap[v.send_uid] = 1
			end
			
            --[[
			if v.create_time > LoginSystem.lastLogoutTime then
				num = num + 1
			end
			]]
		end
	end	
	--log_tree("pinList = ", pinList)
	
	--排序
	table.sort(chatDataList, function(a, b)
		return a.create_time < b.create_time
	end)
	
	
	--增加缓存消息
	for k, v in pairs(chatDataList) do
		LobbyChatLogic.AddNewChat(v.chat_type, v.msgType, v.sender_name, v.voice, v.voiceLength, 
			v.text, v.send_uid, v.bSelfMsg, "", "", "", v.nation, 0, v.topic, v.other, v.avatarData);
	end
	
	--log_tree("chatDataList = ", chatDataList)
	BP_CorpsNewMessageCount = num
	BP_ChatEntrance_New_Crops_Num = num
	--log("BP_CorpsNewMessageCount = "..BP_ChatEntrance_New_Crops_Num)
	
	LuaClassObj.HandleUIMessage(bp_chat_entrance, "YourFriendCalledYou");	
	
	LobbyChatSystem.ChangeTickBuffer();

	for k,v in pairs(uidMap) do
		table.insert(uidList, k)
	end
	ProfileMgr.GetProfileList(uidList)
end

function EventChatMainClearCorpsChatList()
	log("EventChatMainClearCorpsChatList")
	BP_ARRAY_CorpsChatList = {}
end


-- 房间招募
function EventRoomRecruit()
	log("--------EventRoomRecruit");
	if LobbyChatLogic.RoomRecruitTimer ~= nil then	--cd中
		PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", "120164").TextValue);
	else
		LobbyChatLogic.StartRoomRecruitTimer();
		if  BP_IsRoomOwner then			
			RoomUpSystem.RoomRecruitReq();
		else	--不是房主, 发送tips
			PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", "110098").TextValue);			
		end	
	end
end

-- 房间招募定时器按钮
function LobbyChatLogic.StartRoomRecruitTimer()	
	LobbyChatLogic.StopTimer();
	LobbyChatLogic.RoomRecruitTimer = Timer.InsertTimer(2, LobbyChatLogic.StopRoomRecruitTimer, false);
end

function LobbyChatLogic.StopRoomRecruitTimer()
	if LobbyChatLogic.RoomRecruitTimer ~= nil then
		Timer.RemoveTimer(LobbyChatLogic.RoomRecruitTimer);
		LobbyChatLogic.RoomRecruitTimer = nil;
	end
end

BP_Chat_BargainClickChannel = 0;
BP_Chat_BargainClickOwnerID = "";
BP_Chat_BargainClickOwnername = "";
BP_Chat_BargainClickOrderID = 0;
BP_Chat_BargainClickItemID = 0;
BP_Chat_BargainClickMSGID = 0;

function EventOnClickBargainInfo()
	log("[HHF]EventOnClickBargainInfo, BP_Chat_BargainClickChannel = " .. tostring(BP_Chat_BargainClickChannel) ..
		", BP_Chat_BargainClickOwnerID = " .. tostring(BP_Chat_BargainClickOwnerID) .. 
		", BP_Chat_BargainClickOwnername = " .. tostring(BP_Chat_BargainClickOwnername) .. 
		", BP_Chat_BargainClickOrderID = " .. tostring(BP_Chat_BargainClickOrderID) ..
		", BP_Chat_BargainClickItemID = " .. tostring(BP_Chat_BargainClickItemID) .. 
		", BP_Chat_BargainClickMSGID = " .. tostring(BP_Chat_BargainClickMSGID));
	Bargain_Detail_UI.ShowDetailAfterClickChat(BP_Chat_BargainClickChannel, BP_Chat_BargainClickOwnerID, BP_Chat_BargainClickOwnername, BP_Chat_BargainClickOrderID, BP_Chat_BargainClickItemID);
end

function LobbyChatLogic.UpdateBargainOrderState()
	log("[HHF]LobbyChatLogic.UpdateBargainOrderState");
	LuaClassObj.HandleUIMessage(bp_chat_main, "UpdateBargainOrderState");

	local msgData = LobbyChatSystem.friendChatList[FuncUtil:StrTrim(BP_Chat_BargainClickOwnerID)];
	if msgData ~= nil then
		for k, v in pairs(msgData.messageList) do
			if v.BP_STRUCT_BargainHelpMessage.cur_orderid == BP_Chat_BargainClickOrderID then
				log("[HHF]LobbyChatLogic.UpdateBargainOrderState, set friendUID = " .. tostring(BP_Chat_BargainClickOwnerID) .. ", msgID = " .. tostring(v.level) .. " have_bargained = true");
				v.BP_STRUCT_BargainHelpMessage.have_bargained = true;
				break;
			end
		end
	end

	for k, v in pairs(BP_ARRAY_CorpsChatList) do
		if v.BP_STRUCT_BargainHelpMessage.cur_orderid == BP_Chat_BargainClickOrderID then
			log("[HHF]LobbyChatLogic.UpdateBargainOrderState, set corpsMsgID = " .. tostring(v.level) .. " have_bargained = true");
			v.BP_STRUCT_BargainHelpMessage.have_bargained = true;
			break;
		end
	end
end

function LobbyChatLogic.RemoveMsgById(id)
	if LobbyChatLogic.isShowing then
		BP_ToRemoveMsgId = id
		LuaClassObj.HandleUIMessageNoFetch(bp_chat_main, "RemoveMsgById")
		if id < 0 then
			log("LobbyChatLogic.RemoveMsgById:Id error!!!")
		end
		--LuaClassObj.HandleUIMessageNoFetch(bp_chat_main, "RefreshReuseList")
	end
end

function LobbyChatLogic.InitChangeRoomTipsData()
	LobbyChatLogic.ChangeRoomTipsData = DeepCopy(BP_STRUCT_ChatMessageSingleData)
	local data = LobbyChatLogic.ChangeRoomTipsData
	data.msgType = LobbyChatSystem.changeRoomTipsMsgType
	--log_tree("xxxxxxxxxxxxxxxxxxx:InitChangeRoomTipsData:",LobbyChatLogic.ChangeRoomTipsData)
end

--更新军团聊天消息列表
function LobbyChatLogic.UpdateCorpsChatList()
	log("LobbyChatLogic.UpdateCorpsChatList")
	for k,v in pairs(BP_ARRAY_CorpsChatList) do
		local avatar = v.BP_STRUCT_AvatarData
		local profile = ProfileMgr.GetPlayerDataByUid(v.uid)
		if profile then
			avatar.MaxSegment = FuncUtil.GetCurMaxSegementLevel(profile.segment_info)
		end
	end
end

function EventGetMsgByIdFromCurChannel()
	local id = BP_ToGetMsgId
	local msg = {}
	if BP_ChannelType == LobbyChatSystem.channelWorld then
		msg = LobbyChatLogic.Local_ARRAY_DataList[BP_Current_TopicId][id]
	elseif BP_ChannelType == LobbyChatSystem.channelCorps then
		msg = BP_ARRAY_CorpsChatList[id]
	elseif BP_ChannelType == LobbyChatSystem.channelPrivate then
		msg = BP_ARRAY_FriendChatList[id]
	elseif BP_ChannelType == LobbyChatSystem.channelTeamRecruit then
		msg = BP_ARRAY_TeamRecruitList[id]
	end
	BP_ARRAY_ToGetMsg = {}
	table.insert(BP_ARRAY_ToGetMsg, msg)
end

function EventGetReuseItemDataById()
	local id = BP_ToDoReuseItemDataId
	local ReuseItemData = BP_ARRAY_ReuseItemData[id]
	BP_ARRAY_ToDoReuseItemData = {}
	table.insert(BP_ARRAY_ToDoReuseItemData, ReuseItemData)
end

function EventSetReuseItemDataById()
	local id = BP_ToDoReuseItemDataId
	local ReuseItemData = BP_ARRAY_ToDoReuseItemData[1]
	BP_ARRAY_ReuseItemData[id] = ReuseItemData
	BP_ARRAY_ToDoReuseItemData = {}
end
