--好友UI
LobbyFriendUI = LobbyFriendUI or
{
	lastClickPresentCoinTime = 0,  	----上一次金币赠送时间
	PresentCoinDeltaTime = 1,   	----赠送金币中间点击间隔时间
	
	friendProfileSlice = 5,
	isShowing = false,

	recentLike = 7,	-- 最近点赞标签

	openFrom = 0,
	openFromStatus = {}, --保存打开的状态
	jumpToRoleInfoStatus = nil, --跳转到角色信息的状态
}

LobbyFriendUIOpenFrom =
{
	Lobby = 0, --默认
	PersonSpaceRelationShip = 1, --从个人空间亲密关系
}


BP_STRUCT_FriendLiteProfile = 
{
	gid = ""
};

--好友结构的定义
BP_STRUCT_FriendProfile =
{
    gid="",
	nickName = "",
	level = 0,
	militaryRank = "";
    picUrl = "",
    vipLevel = 0,
    ladder = 0,-- 天梯
    platName = "",
    sex = 0,-- 1为男，2为女
    lastOnlineTime = 0,
	lastOnlineTimeStr = "",
	lastLoginTime = 0,
	exp = 0,
	signature = "",--个性签名
	segment_info_solo = 0,-- 段位数据
	segment_info_duo = 0,
	segment_info_squad = 0,
	history_max_segment_level = 0, --历史最高段位

	startup_type = 0,-- 启动类型
	qq_vip = 0,-- QQ会员
	
	friendType = 0,-- 好友类型（平台1、游戏内0）仅用作页签区分
	isPlatFriend = false,--是不是平台好友
	intimacy=0,--亲密度
	lastInviteTime=0,--上次邀请时间
	remarks_name="",--备注名称，有备注名称表示备注名称，无备注表示平台名称
	cur_avatar_box_id=0,
	
	bXiaoYue=0,--是否是小悦
	bNewMessage=0,--小悦是否有小红点
	
	online = 1, -- 0为离线，1为在线
	showInviteIcon = 0,
	
	relation=0,
	isInnerFriendNotPlatFriend = false,   -- 是游戏好友不是平台好友
	
	-- 申请列表
	applyMsg="", --好友申请里的留言
	createTime = 0,--好友申请的发送时间
	createTimeStr = "",
	
	-- 附近的人（大厅），好友（大厅），好友聊天
	teamState = 0, -- 0为空闲，1为组队中（组队中提供当前队伍人数，队伍最大可容纳人数，队伍id）,2为已开局状态（需已开局时间数据）
	currentTeamAmount = 1, -- 当前队伍人数
	maxTeamAmount = 4, -- 队伍最大可容纳人数
	teamId = 0, -- 队伍id
	timeSinceGameBegin = 0, -- 已开局时间
	timeSinceGameBeginStr = "",
	game_mode = 0,--0为默认模式
	gameModeStr = "",

	gameSubMode = 0, -- 子模式id(对应BTMode表),用于观战获取地图
	watchUid = 0, -- 若观战中则不为0
	enableWatch = 1,  --是否允许观战

	-- 最近组队
	endtime=0,-- 战斗结算时间
	endtimeStr="",
	rank=0, --排名
	total=0, -- 总人数
	score="", --评分
	kill=0, --淘汰人数
	mode=0, --模式
	modeStr="",	
	
	-- 平台好友 游戏好友
	lastPresentCoinTime=0,--上次赠送时间
	bPresentedCoin=0,--是否赠送过金币(0未赠送，1赠送过)
	
	-- 附近的人（好友）,附近的人（大厅）
	distance=0,
	isFriend=false,
	
	-- 添加好友搜索
	tendency=0,
	playDate=0,
	playTime=0,
	cityId=0,
	expertArea_1=0,
	expertArea_2=0,

	-- 绝地通行证
	upass_is_buy = 0; --是否购买(1为已购买，0为未购买)
	upass_is_show = 0; --是否显示(1为显示，0为不显示)
    roleNation = "";
    language = "";

    aliasId = 0;
    aliasTitle = "";
    aliasNation = "",

	-- 最近点赞
    recentLikeUID = 0;	-- 玩家UID
    recentLikeOp = 0;	-- 点赞类型 BP_STRUCT_EnumRecentLikeOp
    recentLikeTs = 0;	-- 点赞时间戳
};

BP_STRUCT_Lobby_Friend_Common_Data = 
{
	gid="",
	nickName = "",
	level = 0,
	militaryRank = "";
    picUrl = "",
    vipLevel = 0,
    ladder = 0,-- 天梯
    platName = "",
    sex = 0,-- 1为男，2为女
    lastOnlineTime = 0,
	lastOnlineTimeStr = "",
	lastLoginTime = 0,
	exp = 0,
	signature = "",--个性签名
	segment_info_solo = 0,-- 段位数据
	segment_info_duo = 0,
	segment_info_squad = 0,
	history_max_segment_level = 0, --历史最高段位

	startup_type = 0,-- 启动类型
	qq_vip = 0,-- QQ会员
	
	friendType = 0,-- 好友类型（平台1、游戏内0） 	   	
	intimacy=0,--亲密度
	lastInviteTime=0,--上次邀请时间
	remarks_name="",--备注名称，有备注名称表示备注名称，无备注表示平台名称
	cur_avatar_box_id=0,
	
	bXiaoYue=0,--是否是小悦
	bNewMessage=0,--小悦是否有小红点
	
	online = 1, -- 0为离线，1为在线
	showInviteIcon = 0,
	
	relation=0,
	isInnerFriendNotPlatFriend = false,   -- 是游戏好友不是平台好友

	-- 绝地通行证
	upass_is_buy = 0; --是否购买(1为已购买，0为未购买)
	upass_is_show = 0; --是否显示(1为显示，0为不显示)
    roleNation = "";

    language = "";

    aliasId = 0;
    aliasTitle = "";
    aliasNation = "",
}

BP_STRUCT_Lobby_Friend_Apply_Data = 
{		
	applyMsg="", --好友申请里的留言
	createTime = 0,--好友申请的发送时间
	createTimeStr = "",
	
	BP_STRUCT_Lobby_Friend_Common_Data = _G.BP_STRUCT_Lobby_Friend_Common_Data,
}

BP_STRUCT_Lobby_Friend_Search_Data = 
{
	tendency=0,
	playDate=0,
	playTime=0,
	cityId=0,
	expertArea_1=0,
	expertArea_2=0,
	
	BP_STRUCT_Lobby_Friend_Common_Data = _G.BP_STRUCT_Lobby_Friend_Common_Data,
}

BP_STRUCT_Intimacy_Data = 
{
	gid="",
	nickName="",
	level=0,
	picUrl="",
	vipLevel=0,
	sex=0,
	signature="",--个性签名
	intimacy=0,--亲密度
	segment_info_solo=0,-- 段位数据
	segment_info_duo=0,
	segment_info_squad=0,
	cur_avatar_box_id=0,
	state=0,--亲密关系状态
	param=0,--亲密状态参数
	stateSortPriority=0,--亲密关系状态优先级
	relationSortPriority=0,--亲密关系优先级

	-- 绝地通行证
	upass_is_buy = 0; --是否购买(1为已购买，0为未购买)
	upass_is_show = 0; --是否显示(1为显示，0为不显示)

	aliasId = 0;
    aliasTitle = "";
    aliasNation = "";
    roleNation = "";
};

--亲密度数据
BP_ARRAY_Intimacy_Data = 
{
	BP_STRUCT_Intimacy_Data = _G.BP_STRUCT_Intimacy_Data,
}

--每种亲密关系详细数据
BP_STRUCT_Intimacy_DetailData = 
{
	relation=0,
	relationStr="",
	curCount=0,
	maxCount=5,
};

BP_Array_Intimacy_DetailData =
{
	BP_STRUCT_Intimacy_DetailData = _G.BP_STRUCT_Intimacy_DetailData,
}

--标签搜索数据结构
BP_STRUCT_Search_Data = 
{
	labelType=0,
	labelId=0,
	labelStr="",
};

BP_Array_Search_Data = 
{
	BP_STRUCT_Search_Data = _G.BP_STRUCT_Search_Data,
}

--附近的人
BP_NearBy_Gender_Filter = 0;	--0:不限 1:男 2:女
BP_NearBy_Location_Open = true;	--false:关闭 true:开启
BP_NearBy_Empty_Tips = "";	--暂无附近的人
BP_NearBy_Empty_Tips_Location_Close = ""; --勾选上方的【开启定位】可查看附近的人
BP_NearBy_SelfUID = "";

--平台好友列表
BP_ARRAY_Plat_Friend_Profile =
{
    BP_STRUCT_FriendProfile = _G.BP_STRUCT_FriendProfile, --定义结构体数组，这种写法要作为规范规定下来
}

-- 平台精简数据
BP_ARRAY_Plat_Friend_Lite_Profile = 
{
	BP_STRUCT_FriendLiteProfile = _G.BP_STRUCT_FriendLiteProfile,
}

BP_ARRAY_Plat_Friend_Detail_Profile = 
{
	BP_STRUCT_FriendProfile = _G.BP_STRUCT_FriendProfile,
}

--游戏内好友列表
BP_ARRAY_Inner_Friend_Profile =
{
    BP_STRUCT_FriendProfile = _G.BP_STRUCT_FriendProfile,
}

-- 游戏内好友精简数据
BP_ARRAY_Inner_Friend_Lite_Profile = 
{
	BP_STRUCT_FriendLiteProfile = _G.BP_STRUCT_FriendLiteProfile,
}

BP_ARRAY_Inner_Friend_Detail_Profile = 
{
	BP_STRUCT_FriendProfile = _G.BP_STRUCT_FriendProfile,
}

--搜索好友列表
BP_ARRAY_Search_Friend_Profile =
{
    BP_STRUCT_FriendProfile = _G.BP_STRUCT_FriendProfile,
}

-- 搜索好友列表精简数据
BP_ARRAY_Search_Friend_Lite_Profile = 
{
	BP_STRUCT_FriendLiteProfile = _G.BP_STRUCT_FriendLiteProfile,
}

BP_ARRAY_Search_Friend_Detail_Profile = 
{
	BP_STRUCT_Lobby_Friend_Search_Data = _G.BP_STRUCT_Lobby_Friend_Search_Data,
}

BP_Search_Friend_Scroll_Start = 0;
BP_Search_Friend_Scroll_End = 0;

--邀请好友列表(被别人申请加为好友的)
BP_ARRAY_Apply_Friend_Profile =
{
    BP_STRUCT_FriendProfile = _G.BP_STRUCT_FriendProfile,
}

BP_ARRAY_Apply_Friend_Lite_Profile = 
{
	BP_STRUCT_FriendLiteProfile = _G.BP_STRUCT_FriendLiteProfile,
}

BP_ARRAY_Apply_Friend_Detail_Profile = 
{
	BP_STRUCT_Lobby_Friend_Apply_Data = _G.BP_STRUCT_Lobby_Friend_Apply_Data
}

--黑名单列表（从好友列表和平台列表取数据）
BP_ARRAY_Blacklist_Friend_Profile =
{
    BP_STRUCT_FriendProfile = _G.BP_STRUCT_FriendProfile,
}

BP_ARRAY_Blacklist_Friend_Lite_Profile = 
{
	BP_STRUCT_FriendLiteProfile = _G.BP_STRUCT_FriendLiteProfile,
}

BP_ARRAY_Blacklist_Friend_Detail_Profile = 
{
	BP_STRUCT_FriendProfile = _G.BP_STRUCT_FriendProfile
}

--最近组队队友
BP_ARRAY_Recent_Teammate_Profile =
{
	BP_STRUCT_FriendProfile = _G.BP_STRUCT_FriendProfile,
}

BP_ARRAY_Recent_Teammate_Lite_Profile = 
{
	BP_STRUCT_FriendLiteProfile = _G.BP_STRUCT_FriendLiteProfile,
}

BP_ARRAY_Recent_Teammate_Detail_Profile = 
{
	BP_STRUCT_FriendProfile = _G.BP_STRUCT_FriendProfile,
}

--附近的人
BP_ARRAY_Near_By_Profile =
{
	BP_STRUCT_FriendProfile = _G.BP_STRUCT_FriendProfile,
}

BP_ARRAY_Near_By_Gender_Filter_Profile =
{
	BP_STRUCT_FriendProfile = _G.BP_STRUCT_FriendProfile,
}

--最近点赞列表
BP_STRUCT_EnumRecentLikeOp =
{
    initiative=1,	-- 给别人点赞
    passive=2,		-- 被点赞
    together =3,	-- 互相点赞
}
BP_ARRAY_Recent_Like_Profile =
{
    BP_STRUCT_FriendProfile = _G.BP_STRUCT_FriendProfile,
}

function bp_lobby_friend_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_lobby_friend,
		{{Path="/Game/UMG/UI_BP/Friend/LobbyFriendList_UIBP.LobbyFriendList_UIBP_C", Container="Default", ZOrder=BP_ENUM_UI_FRIEND_ZORDER},
		{Path="/Game/UMG/UI_BP/SendFriend/SendGameFriend_UIBP.SendGameFriend_UIBP_C", Container="Default", ZOrder=BP_ENUM_UI_FRIEND_ZORDER}},
		{"Lobby"},
		false,
        bp_lobby_friend_OnModeSwitched ~= nil,
		true
	);
	
	LuaClassObj.SubShowHideEvent(bp_lobby_friend, { "LobbyFriendList_UIBP_C" });
	
	EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_FRIEND, LobbyFriendUI.Show);
	--EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_MASTER, LobbyFriendUI.OpenMaster);
end

function bp_lobby_friend_OnModeSwitched(gamestatus)
	log("bp_lobby_friend_OnModeSwitched gamestatus = " .. gamestatus)
	if string.lower(gamestatus) == "lobby" then
        FriendSystem.Enter()
	else
		LobbyFriendUI:Release();
	end
end



--不做任何事，蓝图里调这个函数将把lua变量的值同步给蓝图变量
function EventFetchInfo()
	
end

BP_Friend_Platform = 0
function LobbyFriendUI:Init(openFrom, openFromStatus)
	LobbyFriendUI.openFrom = openFrom or LobbyFriendUIOpenFrom.Lobby
	LobbyFriendUI.openFromStatus = openFromStatus or {}

	LobbyFriendUI.jumpToRoleInfoStatus = nil

	log("LobbyFriendUI Init")
	local msg = Client.GetTableData("LocalizeRes",200006)
	if msg then
		BP_Verify_DefaultWord = msg.TextValue
	end
	
	BP_NearBy_Empty_Tips = DataMgr.GetMsgByID(200060);
	BP_NearBy_Empty_Tips_Location_Close = DataMgr.GetMsgByID(200061);

	BP_FRIEND_IS_WATCHING_OPEN = LogicLobbyWatching.IsWatchingOpen();
	-- 获取当前平台
	BP_Friend_Platform = BP_Platform

	-- 赠送时不需要拉取
	if not BP_Friend_Send_Item then
		FriendSystem.CheckAndGetNearbyPersonInfo();
	end
end

function LobbyFriendUI:Release()
	log("LobbyFriendUI Release")
	BP_Friend_Is_Show = false
	BP_Friend_Send_Item = false
end

--是否已处理好友申请（点击同意按钮该值会置为true,关闭好友界面和申请界面该值会重置为false）
BP_Friend_Process_Add_Friend = false
--好友界面是否已显示
BP_Friend_Is_Show = false
function LobbyFriendUI:Show()
	log("LobbyFriendUI Show "..tostring(BP_Friend_Send_Item).." BP_Friend_Panel_Tab_Index "..BP_Friend_Panel_Tab_Index)
	LuaClassObj.HandleDynamicCreation(bp_lobby_friend)
    
	-- 处理退出批量删除好友
	BP_IsInBatchDelete = false
	FriendSystem.SortInnerFriendList(LOGIC_FRIEND_SORT_TYPE.NORMAL)
	LuaClassObj.HandleUIMessageNoFetch(bp_lobby_friend, "UpdateInnerPanel")
	
	FriendSystem.SortPlatFriendList()

    BP_NearBy_SelfUID = DataMgr.roleData.uid;

    -- 这里的QQ平台就是海外版的facebook，Wx对应海外版的Wechat
	if BP_Platform == BP_ENUM_PLAYFORM_WX or BP_Platform == BP_ENUM_PLAYFORM_QQ or BP_Platform == BP_ENUM_PLAYFORM_VK or BP_Platform == BP_ENUM_PLAYFORM_QQByiTOP then
		local strRegion = Client.GetPublishRegion()

		if BP_Friend_Send_Item then
			LuaClassObj.HandleUIMessageNoFetch(bp_lobby_friend, "UIShowSendItem")
			--需求要求日韩版且ip为日本时，使用facebook登录不显示此页签
		elseif (strRegion == "JAPAN" or strRegion == "KOREA") and  LoginSystem.ip_region == "JP" and  BP_Platform == BP_ENUM_PLAYFORM_QQ then
			LuaClassObj.HandleUIMessageNoFetch(bp_lobby_friend, "UIShow2")
		else
			LuaClassObj.HandleUIMessageNoFetch(bp_lobby_friend, "UIShow")
		end
	else  -- 游客模式，gp，gc，twitter都没有关系链
		if BP_Friend_Send_Item then
			LuaClassObj.HandleUIMessageNoFetch(bp_lobby_friend, "UIShowSendItem")
		else
			LuaClassObj.HandleUIMessageNoFetch(bp_lobby_friend, "UIShow2")
		end
	end

	LuaClassObj.HandleUIMessageNoFetch(bp_lobby_friend, "UpdateEnterBatchDeleteUIFalse")
	--更新小红点
	LobbyFriendUI.UpdateMasterRedPoint();
	
	EventSystem:registEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN, LobbyFriendUI.WardRobeAvatarResetOpen);
    EventSystem:registEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE, LobbyFriendUI.WardRobeAvatarResetClose);
	EventSystem:registEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_REDDOT_UPDATE, LobbyFriendUI.UpdateIntimacyRelationAvailable);
	
	LobbyFriendUI.isShowing = true;

	LobbyFriendUI:UpdateIntimacyRelationAvailable()
end

function LobbyFriendUI.OpenMaster()
	LobbyFriendUI:Show()
	--LuaClassObj.HandleUIMessageNoFetch(bp_lobby_friend, "ShowMasterPanel")
end

function LobbyFriendUI:Hide()
    log("LobbyFriendUI Hide")
	LuaClassObj.HandleUIMessageNoFetch(bp_lobby_friend, "UIHide")
end

function LobbyFriendUI:Jump()
	log("LobbyFriendUI Jump")
	if BP_Platform == BP_ENUM_PLAYFORM_WX or BP_Platform == BP_ENUM_PLAYFORM_QQ or BP_Platform == BP_ENUM_PLAYFORM_VK or BP_Platform == BP_ENUM_PLAYFORM_QQByiTOP then
		LuaClassObj.HandleUIMessageNoFetch(bp_lobby_friend, "UIJump")
	else
		LuaClassObj.HandleUIMessageNoFetch(bp_lobby_friend, "UIJump2")
	end
end

-- rain 观战相关
BP_FRIEND_WATCH_ID = ""
function EventLobbyFriendWatch()
	log("EventLobbyFriendWatch: BP_FRIEND_WATCH_ID = "..tostring(BP_FRIEND_WATCH_ID))
	CommonMessageBoxUI:ShowPanel(2, Client.GetTableData("LocalizeRes", "5077").TextValue,
			Client.GetTableData("LocalizeRes", "501124").TextValue,
			function()
				LogicLobbyWatching.enter_battle_watch(BP_FRIEND_WATCH_ID)
			end, nil)

end

-- 是否开启观战
BP_FRIEND_IS_WATCHING_OPEN = false;

-- 刷新观战开关
function EventCheckWatchingSwitch()
	BP_FRIEND_IS_WATCHING_OPEN = LogicLobbyWatching.IsWatchingOpen();
end

--sami隐藏好友列表
function EventHideLobbyFriendUI()
	log("TeamUPFriendUI.EventHideLobbyFriendUI")
	EventSystem:unregistEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN, LobbyFriendUI.WardRobeAvatarResetOpen);
    EventSystem:unregistEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE, LobbyFriendUI.WardRobeAvatarResetClose);
	EventSystem:unregistEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_REDDOT_UPDATE, LobbyFriendUI.UpdateIntimacyRelationAvailable);
	LobbyFriendUI.isShowing = false;

	if LobbyFriendUI.openFrom == LobbyFriendUIOpenFrom.PersonSpaceRelationShip then
		if LobbyFriendUI.openFromStatus and LobbyFriendUI.openFromStatus.uid then
			if LobbyFriendUI.jumpToRoleInfoStatus then
				if LobbyFriendUI.jumpToRoleInfoStatus.DirectOpen then
					RoleInfoUI.SetDirectOpen(LobbyFriendUI.jumpToRoleInfoStatus.DirectOpen)
				end

				RoleInfoSystem.Enter(LobbyFriendUI.jumpToRoleInfoStatus.uid)
				RoleInfoUI.Init(true, RoleInfoUI.openFrom, RoleInfoUI.openFromStatus) --延续打开

				LobbyFriendUI.jumpToRoleInfoStatus = nil
			else
				RoleInfoSystem.Enter(LobbyFriendUI.openFromStatus.uid)
				RoleInfoUI.Init(true, RoleInfoUI.openFrom, RoleInfoUI.openFromStatus) --延续打开

				RoleInfoUI.SetDirectOpen(RoleInfoLabelType.RelationShip)

			end
		end
	end
end

--sami 个人信息角色开关处理
function LobbyFriendUI.WardRobeAvatarResetOpen()
    log("LobbyFriendUI.WardRobeAvatarResetOpen")
	if(LobbyFriendUI.isShowing == true) then
		LuaClassObj.HandleUIMessage(bp_lobby_friend, "UIHideInner");
		LobbyFriendUI.isShowing = false;
	end
end

function LobbyFriendUI.WardRobeAvatarResetClose()
    log("LobbyFriendUI.WardRobeAvatarResetClose")
	if LobbyFriendUI.isShowing == false and MallSystemUI_2.isBackingFromRoleUI == false then
		LuaClassObj.HandleUIMessageNoFetch(bp_lobby_friend, "UIShow")
		LobbyFriendUI.isShowing = true;
	end
end


function LobbyFriendUI.RefreshInnerPanel()
	if BP_IsInBatchDelete == false then
		FriendSystem.SortInnerFriendList(LOGIC_FRIEND_SORT_TYPE.NORMAL)
	else
		FriendSystem.SortInnerFriendList(LOGIC_FRIEND_SORT_TYPE.LAST_ONLINE_TIME)
	end
end

function EventLobbyFriendFetchFriendList()
	log("EventLobbyFriendFetchFriendList")
    FriendSystem.FetchFriendList()
end

BP_Inner_Friend_Scroll_Start = 0;
BP_Inner_Friend_Scroll_End = 0;

function EventLobbyFriendScrollInnerList()
	 -- 赠送道具选择好友模式，不刷新平台好友列表
	if BP_Friend_Send_Item then return end
	LobbyFriendUI:UpdateInnerList();
end

function LobbyFriendUI:UpdateInnerList()
	log("LobbyFriendUI:UpdateInnerList------"..tostring(BP_Friend_Send_Item))

	local list = BP_ARRAY_Inner_Friend_Profile

	BP_ARRAY_Inner_Friend_Lite_Profile = {};
	BP_ARRAY_Inner_Friend_Detail_Profile = {};
	
	if 0 == BP_Inner_Friend_Scroll_Start and 0 == BP_Inner_Friend_Scroll_End then
		BP_Inner_Friend_Scroll_End = LobbyFriendUI.friendProfileSlice;
	end
	
	local startIndex = BP_Inner_Friend_Scroll_Start / LobbyFriendUI.friendProfileSlice;
	local endIndex = BP_Inner_Friend_Scroll_End / LobbyFriendUI.friendProfileSlice;
	
	for i = 1, #list do
		local profileData = list[i];
		table.insert(BP_ARRAY_Inner_Friend_Lite_Profile, { gid = profileData.gid });
		
		local index = i - 1;
		if (startIndex * LobbyFriendUI.friendProfileSlice <= index) and (endIndex * LobbyFriendUI.friendProfileSlice >= index) then			
			table.insert(BP_ARRAY_Inner_Friend_Detail_Profile, profileData);
		end
	end
	
	if BP_Friend_Panel_Tab_Index == 1 then
		log("LobbyFriendUI:UpdateInnerList------UpdateInnerPanel")
		LuaClassObj.HandleUIMessageNoFetch(bp_lobby_friend, "UpdateInnerPanel")
	end	
end

BP_Platform_Friend_Scroll_Start = 0;
BP_Platform_Friend_Scroll_End = 0;

function EventLobbyFriendScrollPlatList()
	 -- 赠送道具选择好友模式，不刷新好友列表
	if BP_Friend_Send_Item then return end
	LobbyFriendUI:UpdatePlatList()
end

function LobbyFriendUI:UpdatePlatList()	
	BP_ARRAY_Plat_Friend_Lite_Profile = {};
	BP_ARRAY_Plat_Friend_Detail_Profile = {};
	
	if 0 == BP_Platform_Friend_Scroll_Start and 0 == BP_Platform_Friend_Scroll_End then
		BP_Platform_Friend_Scroll_End = LobbyFriendUI.friendProfileSlice;
	end
	
	local startIndex = BP_Platform_Friend_Scroll_Start / LobbyFriendUI.friendProfileSlice;
	local endIndex = BP_Platform_Friend_Scroll_End / LobbyFriendUI.friendProfileSlice;

	for i = 1, #BP_ARRAY_Plat_Friend_Profile do
		local profileData = BP_ARRAY_Plat_Friend_Profile[i];
		table.insert(BP_ARRAY_Plat_Friend_Lite_Profile, { gid = profileData.gid });
		
		local index = i - 1;
		if (startIndex * LobbyFriendUI.friendProfileSlice <= index) and (endIndex * LobbyFriendUI.friendProfileSlice >= index) then
			table.insert(BP_ARRAY_Plat_Friend_Detail_Profile, profileData);
		end
	end
	
	if BP_Friend_Panel_Tab_Index == 0 then		
		LuaClassObj.HandleUIMessageNoFetch(bp_lobby_friend, "UpdatePlatPanel")
	end	
end

-- 判断是游戏好友不是平台好友
BP_FriendSystem_SelectedFriendNickNameAddQQFriend = ""
function EventLobbyFriendAddQQFriend()
    log("EventLobbyFriendCheckFriendInnerandPlat" .. BP_FriendSystem_SelectedFriendNickNameAddQQFriend)
    FriendSystem.get_openid_by_nickname_req(BP_FriendSystem_SelectedFriendNickNameAddQQFriend, "AddQQFriend")
end

BP_Friend_SearchName = ""
function EventLobbyFriendSearchReq()
	log("------EventLobbyFriendSearchReq "..BP_Friend_SearchName)
	FriendSystem.find_uid_by_name_req(BP_Friend_SearchName)
end

--标签搜索
BP_Friend_Search_Tendency = 0 --社交倾向
BP_Friend_Search_PlayDate = 0 --常玩日期
BP_Friend_Search_PlayTime = 0 -- 常玩时间
BP_Friend_Search_Segment = 0 -- 段位
BP_Friend_Search_Gender = 0	--性别
BP_Friend_Search_Language = 0 --语言
BP_Friend_Search_Nation = ""
BP_Friend_Search_Is_Same_City = false -- 是否同城,默认不同城

-- 搜索框为空时进行标签搜索
function EventLobbyFriendLabelSearchReq()
	-- FriendSystem.searchSocialRoleReq(BP_Friend_Search_Tendency,BP_Friend_Search_PlayDate,BP_Friend_Search_PlayTime,BP_Friend_Search_Segment,BP_Friend_Search_Gender,BP_Friend_Search_Is_Same_City)
	log("======BP_Friend_Search_Language "..tostring(BP_Friend_Search_Language))
	-- log_tree("FriendSystem.searchLanguageInfo",FriendSystem.searchLanguageInfo)
	local cond = {}
	if (BP_Friend_Search_Nation ~= "") then
		cond["nation"] = BP_Friend_Search_Nation
	end
	if BP_Friend_Search_Segment > 0 then
		cond["segment"] = BP_Friend_Search_Segment
	end

	local tranSupportCfg = FuncUtil.GetLanguageTable()
	
	if BP_Friend_Search_Language > 0 then
		local id = FriendSystem.searchLanguageInfo[BP_Friend_Search_Language + 1].labelId

		cond.language = tranSupportCfg[tostring(id)].languageCode
	end

	if (cond.language == "zh-HK") then
		cond.language = "HK"
	elseif (cond.language == "zh-TW") then
		cond.language = "TW";
	end

	-- local region = Client.GetPublishRegion();
	-- if region == "JAPAN" then
	-- 	if (BP_Friend_Search_Language == 1) then
	-- 		cond["language"] = "en"
	-- 	elseif (BP_Friend_Search_Language == 2) then
	-- 		cond["language"] = "ja"
	-- 	end
	-- elseif region == "KOREA" then
	-- 	if (BP_Friend_Search_Language == 1) then
	-- 		cond["language"] = "en"
	-- 	elseif (BP_Friend_Search_Language == 2) then
	-- 		cond["language"] = "ko"
	-- 	end
	-- else
	-- 	if (tranSupportCfg ~= nil and tranSupportCfg[tostring(BP_Friend_Search_Language - 1)] ~= nil) then
	-- 		if (BP_Friend_Search_Language > 1) then
	-- 			cond["language"] = tranSupportCfg[tostring(BP_Friend_Search_Language + 1)].languageCode;
	-- 		else
	-- 			cond["language"] = tranSupportCfg[tostring(BP_Friend_Search_Language - 1)].languageCode;
	-- 		end
	-- 		if (cond["language"] == "zh-HK") then
	-- 			cond["language"] = "HK"
	-- 		elseif (cond["language"] == "zh-TW") then
	-- 			cond["language"] = "TW";
	-- 		end
	-- 	end
	-- end

	FriendSystem.social_search_role_req(cond)
	
end

function LobbyFriendUI.CopyCommonData(lhs, rhs)
	rhs.BP_STRUCT_Lobby_Friend_Common_Data = {};
	local dat = rhs.BP_STRUCT_Lobby_Friend_Common_Data;
	dat.gid = lhs.gid;
	dat.nickName = lhs.nickName;
	dat.level = lhs.level;
	dat.militaryRank = lhs.militaryRank;
	dat.picUrl = lhs.picUrl;
	dat.vipLevel = lhs.vipLevel;
	dat.ladder = lhs.ladder;
	dat.platName = lhs.platName;
	dat.sex = lhs.sex;
	dat.lastOnlineTime = lhs.lastOnlineTime;
	dat.lastOnlineTimeStr = lhs.lastOnlineTimeStr;
	dat.lastLoginTime = lhs.lastLoginTime;
	dat.exp = lhs.exp;
	dat.signature = lhs.signature;
	dat.segment_info_solo = lhs.segment_info_solo;
	dat.segment_info_duo = lhs.segment_info_duo;
	dat.segment_info_squad = lhs.segment_info_squad;
	dat.history_max_segment_level = lhs.history_max_segment_level;
	
	dat.startup_type = lhs.startup_type;
	dat.qq_vip = lhs.qq_vip;
	
	dat.friendType = lhs.friendType;
	dat.intimacy = lhs.intimacy;
	dat.lastInviteTime = lhs.lastInviteTime;
	dat.remarks_name = lhs.remarks_name;
	dat.cur_avatar_box_id = lhs.cur_avatar_box_id;
	
	dat.bXiaoYue = lhs.bXiaoYue;
	dat.bNewMessage = lhs.bNewMessage;
	
	dat.online = lhs.online;
	dat.showInviteIcon = lhs.showInviteIcon;
	
	dat.relation = lhs.relation;
	dat.isInnerFriendNotPlatFriend = lhs.isInnerFriendNotPlatFriend;

	dat.upass_is_buy = lhs.upass_is_buy;
	dat.upass_is_show = lhs.upass_is_show;
	dat.roleNation = lhs.roleNation;
	dat.aliasId = lhs.aliasId;
	dat.aliasTitle = lhs.aliasTitle;
	dat.aliasNation = lhs.aliasNation;
	dat.language = lhs.language;
end

function LobbyFriendUI:UpdateSearchList()
	BP_ARRAY_Search_Friend_Lite_Profile = {};
	BP_ARRAY_Search_Friend_Detail_Profile = {};
	
	if 0 == BP_Search_Friend_Scroll_Start and 0 == BP_Search_Friend_Scroll_End then
		BP_Search_Friend_Scroll_End = LobbyFriendUI.friendProfileSlice;
	end
	
	local startIndex = BP_Search_Friend_Scroll_Start / LobbyFriendUI.friendProfileSlice;
	local endIndex = BP_Search_Friend_Scroll_End / LobbyFriendUI.friendProfileSlice;
	
	for i = 1, #BP_ARRAY_Search_Friend_Profile do
		local profileData = BP_ARRAY_Search_Friend_Profile[i];
		table.insert(BP_ARRAY_Search_Friend_Lite_Profile, { gid = profileData.gid });
		
		local index = i - 1;
		if (startIndex * LobbyFriendUI.friendProfileSlice <= index) and (endIndex * LobbyFriendUI.friendProfileSlice >= index) then
			local searchData = {};
			searchData.tendency = profileData.tendency;
			searchData.playDate = profileData.playDate;
			searchData.playTime = profileData.playTime;
			searchData.cityId = profileData.cityId;
			searchData.expertArea_1 = profileData.expertArea_1;
			searchData.expertArea_2 = profileData.expertArea_2;
			searchData.language = profileData.language;

			
			LobbyFriendUI.CopyCommonData(profileData, searchData);

            searchData.BP_STRUCT_Lobby_Friend_Common_Data.roleNation = ProfileMgr.GetRoleNationByUid(profileData.gid);

			table.insert(BP_ARRAY_Search_Friend_Detail_Profile, searchData);
		end
	end
	
	--log_tree("BP_ARRAY_Search_Friend_Lite_Profile ", BP_ARRAY_Search_Friend_Lite_Profile);
	--log_tree("BP_ARRAY_Search_Friend_Detail_Profile", BP_ARRAY_Search_Friend_Detail_Profile);
    --数据在BP_ARRAY_Plat_Friend_Profile
    LuaClassObj.HandleUIMessageNoFetch(bp_lobby_friend, "UpdateSearchPanel")
end

function EventLobbyFriendScrollSearchList()
	LobbyFriendUI:UpdateSearchList();
end

-- 未查找到该好友
function LobbyFriendUI:ShowSearchFailResult()
	LuaClassObj.HandleUIMessageNoFetch(bp_lobby_friend, "SearchFail")
end

--赠送金币的好友的uid
BP_FriendSystem_Present_Coin_Friend_ID=""
function EventLobbyPresentCoinReq()
	local curTime = FuncUtil.GetServerTimeInSec()
	local deltaTime = curTime - LobbyFriendUI.lastClickPresentCoinTime
	if deltaTime > LobbyFriendUI.PresentCoinDeltaTime then
		lastClickPresentCoinTime = curTime
		FriendSystem.present_friend_gold_req(tonumber(BP_FriendSystem_Present_Coin_Friend_ID),0)
	end
end

function LobbyFriendUI:SendPresentCoinSuccess()
	LuaClassObj.HandleUIMessageNoFetch(bp_lobby_friend,"SendPresentCoinSuccess")
end

function LobbyFriendUI:SendInviteSuccess()
	LuaClassObj.HandleUIMessageNoFetch(bp_lobby_friend,"SendInviteSuccess")
end

--A添加B
BP_Add_Friend_ID = ""
BP_Add_Friend_Verify = ""
BP_Verify_MaxWordCount = 35
BP_Add_Friend_Gender = 1

function EventLobbyFriendApplyReq()
	local addId = tonumber(BP_Add_Friend_ID)
	local msgId = 21
	local fromSystem = BP_ENUM_ADD_FRIEND_FROM_FRIEND_SEARCH
	if BP_Friend_Panel_Tab_Index == 2 then
		fromSystem = BP_ENUM_ADD_FRIEND_FROM_FRIEND_RECENTTEAMMATE
		if BP_Add_Friend_Gender == 1 then
			msgId = 11
		elseif BP_Add_Friend_Gender == 2 then
			msgId = 12
		end
	elseif BP_Friend_Panel_Tab_Index == 4 then
		fromSystem = BP_ENUM_ADD_FRIEND_FROM_FRIEND_NEARBY
		if BP_Add_Friend_Gender == 1 then
			msgId = 13
		elseif BP_Add_Friend_Gender == 2 then
			msgId = 14
		end
	elseif BP_Friend_Panel_Tab_Index ==  5 then
		fromSystem = BP_ENUM_ADD_FRIEND_FROM_FRIEND_SEARCH
		if BP_Add_Friend_Gender == 1 then
			msgId = 15
		elseif BP_Add_Friend_Gender == 2 then
			msgId = 16
		end
	end
	
	log("msgId"..tostring(msgId).." "..tostring(fromSystem).." "..tostring(BP_Add_Friend_Gender))
	log("BP_Add_Friend_Verify"..BP_Add_Friend_Verify)
	BP_Add_Friend_Verify = string.gsub(BP_Add_Friend_Verify,"\r","")
	BP_Add_Friend_Verify = string.gsub(BP_Add_Friend_Verify,"\n","")
	-- BP_Add_Friend_Verify = string.gsub(BP_Add_Friend_Verify,"\r","")
	-- BP_Add_Friend_Verify = string.gsub(BP_Add_Friend_Verify,"\r","")
	-- BP_Add_Friend_Verify = string.gsub(BP_Add_Friend_Verify,"\r","")
	if string.len(BP_Add_Friend_Verify) > 0 then
		if tonumber(DataMgr.roleData.uid) ~= addId then
			FriendSystem.add_inner_friend_req(addId, BP_Add_Friend_Verify,fromSystem,msgId)
		else
			DataMgr.ShowNoticeByID(200004)
		end
	else
		if tonumber(DataMgr.roleData.uid) ~= addId then
			FriendSystem.add_inner_friend_req(addId, "",fromSystem,msgId)
		else
			DataMgr.ShowNoticeByID(200004)
		end
	end
end

--B回复A是否愿意 op=1，同意；op=0,拒绝；-1 未操作
BP_RSPAdd_Friend_ID = ""
BP_RSPAdd_OP = ""
function EventLobbyFriendRespondApply()
    FriendSystem.add_inner_friend_op_req(tonumber(BP_RSPAdd_Friend_ID), tonumber(BP_RSPAdd_OP))
end

function EventLobbyFriendAddFriendReqList()
    FriendSystem.get_addfriend_reqlist_req()
end

BP_Apply_Friend_Scroll_Start = 0;
BP_Apply_Friend_Scroll_End = 0;

function EventLobbyFriendScrollApplyList()
	LobbyFriendUI.UpdateApplyList();
end

function LobbyFriendUI:UpdateApplyList()
	-- 有空整理抽一下逻辑
	BP_ARRAY_Apply_Friend_Lite_Profile = {};
	BP_ARRAY_Apply_Friend_Detail_Profile = {};
	
	if 0 == BP_Apply_Friend_Scroll_Start and 0 == BP_Apply_Friend_Scroll_End then
		BP_Apply_Friend_Scroll_End = LobbyFriendUI.friendProfileSlice;
	end
	
	local startIndex = BP_Apply_Friend_Scroll_Start / LobbyFriendUI.friendProfileSlice;
	local endIndex = BP_Apply_Friend_Scroll_End / LobbyFriendUI.friendProfileSlice;
	
	for i = 1, #BP_ARRAY_Apply_Friend_Profile do
		local profileData = BP_ARRAY_Apply_Friend_Profile[i];
		table.insert(BP_ARRAY_Apply_Friend_Lite_Profile, { gid = profileData.gid });
		
		local index = i - 1;
		if (startIndex * LobbyFriendUI.friendProfileSlice <= index) and (endIndex * LobbyFriendUI.friendProfileSlice >= index) then
			local applyData = {};
			applyData.applyMsg = profileData.applyMsg;
			applyData.createTime = profileData.createTime;
			applyData.createTimeStr = profileData.createTimeStr;
			
			LobbyFriendUI.CopyCommonData(profileData, applyData);
            applyData.BP_STRUCT_Lobby_Friend_Common_Data.roleNation = ProfileMgr.GetRoleNationByUid(profileData.gid);
			table.insert(BP_ARRAY_Apply_Friend_Detail_Profile, applyData);
		end
	end
	
    LuaClassObj.HandleUIMessageNoFetch(bp_lobby_friend, "UpdateApplyList")
end

-- 更新申请列表小红点
function LobbyFriendUI:UpdateApplyNewTips()
	LuaClassObj.HandleUIMessageNoFetch(bp_lobby_friend, "UpdateApplyNewTips")
end

--删除好友
BP_Delete_Friend_ID = ""
BP_Delete_Friend_Name = ""
function EventLobbyFriendDeleteReq()
	local msg = Client.GetTableData("LocalizeRes",200003)
	if msg then
		local str = string.format(msg.TextValue,BP_Delete_Friend_Name)
		local title = Client.GetTableData("LocalizeRes", "101001").TextValue
		CommonMessageBoxUI:ShowPanel(2,title,str,DeleteFriend,nil)
	end
end

function DeleteFriend()
	FriendSystem.del_inner_friend_req(tonumber(BP_Delete_Friend_ID))
end

-- 批量删除游戏好友
BP_ARRAY_LobbyFriendDeleteFriendIDList = {
	id = "1"
}

BP_MaxDeleteFriendCount = 50
BP_SelecterDeleteFriendCount = 0
BP_IsInBatchDelete = false

-- 刷新已选好友文字
local function updateSelectFriendCount()
	BP_SelecterDeleteFriendCount = #BP_ARRAY_LobbyFriendDeleteFriendIDList

	log("=friend==BP_SelecterDeleteFriendCount "..BP_SelecterDeleteFriendCount)
	LuaClassObj.HandleUIMessageNoFetch(bp_lobby_friend, "UpdateBatchDeleteCount");
end

-- 清空选择
local function clearSelectFriend()
	BP_Delete_Friend_ID = ""
	BP_Delete_Friend_Name = ""
	BP_ARRAY_LobbyFriendDeleteFriendIDList = {}
	updateSelectFriendCount()
end

-- 处理单个删除时候的回调问题
function LobbyFriendUI:OnOneDelete( frid )
	log("OnOneDelete "..frid)
	-- log_tree("sasdasd",BP_ARRAY_LobbyFriendDeleteFriendIDList)
	for i,v in ipairs(BP_ARRAY_LobbyFriendDeleteFriendIDList) do
		if tostring(frid) == v then
			table.remove(BP_ARRAY_LobbyFriendDeleteFriendIDList, i)
			break
		end
	end
	-- log_tree("sasdasd",BP_ARRAY_LobbyFriendDeleteFriendIDList)
	updateSelectFriendCount()
end

-- 删除回调刷新界面
function LobbyFriendUI:BatchDeleteFriendRsp(fridList)
	-- clearSelectFriend()
	EventLeaveBatchDeleteInnerFriend()
	LuaClassObj.HandleUIMessageNoFetch(bp_lobby_friend, "UpdateEnterBatchDeleteUIFalse")
end


function EventFriendOnTapChange()
	log("=friend==EventFriendOnTapChange")

	if BP_IsInBatchDelete == true then
		BP_IsInBatchDelete = false
		FriendSystem.SortInnerFriendList(LOGIC_FRIEND_SORT_TYPE.NORMAL)
		LuaClassObj.HandleUIMessageNoFetch(bp_lobby_friend, "UpdateInnerPanel")
	end
end

-- 进入批量删除游戏好友
function EventEnterBatchDeleteInnerFriend()
	log("=friend==EventEnterBatchDeleteInnerFriend")
	BP_IsInBatchDelete = true
	clearSelectFriend()

	FriendSystem.SortInnerFriendList(LOGIC_FRIEND_SORT_TYPE.LAST_ONLINE_TIME)
end

-- 离开批量删除游戏好友
function EventLeaveBatchDeleteInnerFriend()
	log("=friend==EventLeaveBatchDeleteInnerFriend")
	BP_IsInBatchDelete = false
	clearSelectFriend()

	FriendSystem.SortInnerFriendList(LOGIC_FRIEND_SORT_TYPE.NORMAL)
end

-- 选择删除游戏好友
function EventSelectBatchDeleteInnerFriend()
	local selecteUid = BP_Delete_Friend_ID
	for i,uid in ipairs(BP_ARRAY_LobbyFriendDeleteFriendIDList) do
		if selecteUid == uid then
			return
		end
	end

	table.insert(BP_ARRAY_LobbyFriendDeleteFriendIDList, BP_Delete_Friend_ID)
	updateSelectFriendCount()
	log_tree("=friend==EventSelectBatchDeleteInnerFriend",BP_ARRAY_LobbyFriendDeleteFriendIDList)
end

-- 取消选择删除游戏好友
function EventUnselectBatchDeleteInnerFriend()
	local unSelecteUid = BP_Delete_Friend_ID
	for i,uid in ipairs(BP_ARRAY_LobbyFriendDeleteFriendIDList) do
		if unSelecteUid == uid then
			table.remove(BP_ARRAY_LobbyFriendDeleteFriendIDList, i)
			break
		end
	end

	updateSelectFriendCount()
	log_tree("=friend==EventUnselectBatchDeleteInnerFriend",BP_ARRAY_LobbyFriendDeleteFriendIDList)
end

-- 批量删除好友确定
function BatchDeleteFriend()
	FriendSystem.del_inner_friend_batch_req(BP_ARRAY_LobbyFriendDeleteFriendIDList)
end
function EventConfirmBatchDeleteInnerFriend()
	log_tree("=friend==EventConfirmBatchDeleteInnerFriend",BP_ARRAY_LobbyFriendDeleteFriendIDList)

	local count = #BP_ARRAY_LobbyFriendDeleteFriendIDList
	if count == 0 then 
		DataMgr.ShowNoticeByID("5023")
		return 
	end

	local id = BP_ARRAY_LobbyFriendDeleteFriendIDList[1]
	local name = ""

	for i,profile in ipairs(BP_ARRAY_Inner_Friend_Profile) do
		-- log_tree("=friend==profile",profile)
		if tonumber(profile.gid) == id then
			name = profile.nickName
			break
		end
	end

	local data = Client.GetTableData("LocalizeRes", 4979)
	local content
	if data == nil then
		content = "确定要删除<Setting_Font03>%d</>名好友？(没配表)4979"
	else
		content = data.TextValue
	end

	content = string.format(content, count)
	local title = Client.GetTableData("LocalizeRes", "101001").TextValue

	CommonMessageBoxUI:ShowPanel(2,title,content,BatchDeleteFriend,nil)
end

-- ===============

BP_BlackList_Friend_Scroll_Start = 0;
BP_BlackList_Friend_Scroll_End = 0;

function EventLobbyFriendBlackListScroll()
	LobbyFriendUI:UpdateBlackist();
end

-- 刷新黑名单列表
function LobbyFriendUI:UpdateBlackist()
	BP_ARRAY_Blacklist_Friend_Lite_Profile = {};
	BP_ARRAY_Blacklist_Friend_Detail_Profile = {};
	
	if 0 == BP_BlackList_Friend_Scroll_Start and 0 == BP_BlackList_Friend_Scroll_End then
		BP_BlackList_Friend_Scroll_End = LobbyFriendUI.friendProfileSlice;
	end
	
	local startIndex = BP_BlackList_Friend_Scroll_Start / LobbyFriendUI.friendProfileSlice;
	local endIndex = BP_BlackList_Friend_Scroll_End / LobbyFriendUI.friendProfileSlice;
	
	for i = 1, #BP_ARRAY_Blacklist_Friend_Profile do
		local profileData = BP_ARRAY_Blacklist_Friend_Profile[i];
		table.insert(BP_ARRAY_Blacklist_Friend_Lite_Profile, { gid = profileData.gid });
		
		local index = i - 1;
		if (startIndex * LobbyFriendUI.friendProfileSlice <= index) and (endIndex * LobbyFriendUI.friendProfileSlice >= index) then
			table.insert(BP_ARRAY_Blacklist_Friend_Detail_Profile, profileData);
		end
	end
	
    LuaClassObj.HandleUIMessageNoFetch(bp_lobby_friend, "UpdateBlackList");
end

-- 请求黑名单列表
function EventLobbyFriendGetBlackListReq()
	FriendSystem.get_black_list_req()
end

-- 解除屏蔽
BP_DELETE_FRIEND_BLACK_ID = ""
BP_DELETE_FRIEND_BLACK_NAME = ""
function EventLobbyFriendDeleteBlackReq()
	local msg = Client.GetTableData("LocalizeRes",200011)
	if msg then
		local str = string.format(msg.TextValue,BP_DELETE_FRIEND_BLACK_NAME)
		local title = Client.GetTableData("LocalizeRes", "101001").TextValue
		CommonMessageBoxUI:ShowPanel(2,title,str,DeleteBlack,nil)
	end
end

function DeleteBlack()
	FriendSystem.del_black_list_req(tonumber(BP_DELETE_FRIEND_BLACK_ID))
end

-- 打开好友资料
BP_FRIEND_PROFILE_ID = ""
function EventLobbyFriendProfileReq()
	log("enter profile panel:"..tostring(BP_FRIEND_PROFILE_ID))

	--如果是从亲密关系跳转的,由于只能有一次跳转,那么必须关闭当前界面了,不能反复跳转
	if LobbyFriendUI.openFrom == LobbyFriendUIOpenFrom.PersonSpaceRelationShip then
		LobbyFriendUI.jumpToRoleInfoStatus = {uid = BP_FRIEND_PROFILE_ID}

		LobbyFriendUI:Hide()
	else
		RoleInfoSystem.Enter(BP_FRIEND_PROFILE_ID)
		RoleInfoUI.Init(true, RoleInfoOpenFromType.LobbyFriend)
		ProfileMgr.GetProfile(tostring(BP_FRIEND_PROFILE_ID), LobbyFriendUI.OnFriendStatusListChange)
	end
end

function LobbyFriendUI.OnFriendStatusListChange(list)
	log("OnFriendStatusListChange")
	local count = #list
	if (count > 0) then
		for i = 1,count,1 do
			LobbyFriendUI.OnFriendStatusChange(list[i])
		end
	end
end

BP_Friend_UpdateInnerIndex = 0
BP_Friend_UpdatePlatIndex = 0

function LobbyFriendUI.OnFriendStatusChange(profile)
	if (profile ~= nil and profile.uid ~= nil) then

		local listCount = #BP_ARRAY_Inner_Friend_Profile
		if (listCount > 0) then
			for i = 1, listCount, 1 do
				local v = BP_ARRAY_Inner_Friend_Profile[i]
				if (tostring(profile.uid) == tostring(v.gid)) then
					v = LobbyFriendUI.CopyBaseInfo(v, profile)
					BP_ARRAY_Inner_Friend_Profile[i] = v
					log("BP_ARRAY_Inner_Friend_Profile date update ")
				end
			end	
		end

		listCount = #BP_ARRAY_Plat_Friend_Profile
		if (listCount > 0) then
			for i = 1, listCount, 1 do
				local v = BP_ARRAY_Plat_Friend_Profile[i]
				if (tostring(profile.uid) == tostring(v.gid)) then
					v = LobbyFriendUI.CopyBaseInfo(v, profile)
					BP_ARRAY_Plat_Friend_Profile[i] = v
					log("BP_ARRAY_Plat_Friend_Profile date update ")
				end
			end	
		end
		
		listCount = #BP_ARRAY_Inner_Friend_Profile
		local startIndex = BP_Inner_Friend_Scroll_Start / LobbyFriendUI.friendProfileSlice;
		local endIndex = BP_Inner_Friend_Scroll_End / LobbyFriendUI.friendProfileSlice;
		
		if BP_Friend_Panel_Tab_Index == 1 then
			if (listCount > 0) then
				for i = 1, listCount, 1 do
					local v = BP_ARRAY_Inner_Friend_Profile[i]
					local index = i - 1;
					if (startIndex * LobbyFriendUI.friendProfileSlice <= index) and (endIndex * LobbyFriendUI.friendProfileSlice >= index) then			
						if (tostring(profile.uid) == tostring(v.gid)) then
							LobbyFriendUI.UpdateInnerList();
							break;
						end
					end					
				end	
			end
		end				
		
		listCount = #BP_ARRAY_Plat_Friend_Profile
		startIndex = BP_Platform_Friend_Scroll_Start / LobbyFriendUI.friendProfileSlice;
		endIndex = BP_Platform_Friend_Scroll_End / LobbyFriendUI.friendProfileSlice;
		
		if BP_Friend_Panel_Tab_Index == 0 then
			if (listCount > 0) then
				for i = 1, listCount, 1 do
					local v = BP_ARRAY_Plat_Friend_Profile[i]
					local index = i - 1;
					if (startIndex * LobbyFriendUI.friendProfileSlice <= index) and (endIndex * LobbyFriendUI.friendProfileSlice >= index) then			
						if (tostring(profile.uid) == tostring(v.gid)) then
							LobbyFriendUI.UpdatePlatList();
							break;
						end
					end					
				end	
			end
		end		

		listCount = #BP_ARRAY_All_Friend_Profile
		if (listCount > 0) then
			for i = 1, listCount, 1 do
				local v = BP_ARRAY_All_Friend_Profile[i]
				if (tostring(profile.uid) == tostring(v.gid)) then
					v = LobbyFriendUI.CopyBaseInfo(v, profile)
					BP_ARRAY_All_Friend_Profile[i] = v
					log("BP_ARRAY_All_Friend_Profile date update ")
				end
			end	
		end
	end
end

function LobbyFriendUI.CopyBaseInfo(v, profile)
	v.nickName = profile.nickName
	v.level = profile.level
	v.vipLevel = profile.vipLevel
	v.picUrl = profile.picUrl
	v.platName = profile.platName
	v.sex = profile.sex
	v.lastOnlineTime = profile.lastOnlineTime
	v.lastOnlineTimeStr = FriendSystem.FormatTime(profile.lastOnlineTime,"online")
	v.lastLoginTime = profile.lastLoginTime
	v.exp = profile.exp
	v.segment_info_solo = profile.segment_info[1]
	v.segment_info_duo = profile.segment_info[2]
	v.segment_info_squad = profile.segment_info[3]
	v.history_max_segment_level = profile.history_max_segment_level
	v.cur_avatar_box_id = profile.cur_avatar_box_id
	v.upass_is_buy, v.upass_is_show = FriendSystem.ParseUpassInfo(profile.upass);
	v.roleNation = profile.role_nation;
	v.language = profile.language;
	v.aliasId = profile.alias.id;
	v.aliasTitle = profile.alias.title;
	v.aliasNation = profile.alias.nation;
	return v
end

-- 打开聊天界面
BP_FRIEND_CHAT_ID = ""
function EventLobbyFriendChat()
	LuaClassObj.HandleUIMessageNoFetch(bp_lobby_friend, "UIHide")
	LobbyChatSystem.ChatWithFriend(BP_FRIEND_CHAT_ID)
end

BP_Recent_Teammate_ScrollStart = 0;
BP_Recent_Teammate_ScrollEnd = 0;

function EventRecentTeammateScrollApplyList()
	LobbyFriendUI:UpdateRecentTeammateList();
end

function EventGetRecentTeammateList()
	FriendSystem.fetchRecentTeammateList()
end

-- 刷新最近组队界面
function LobbyFriendUI:UpdateRecentTeammateList()
	BP_ARRAY_Recent_Teammate_Lite_Profile = {};
	BP_ARRAY_Recent_Teammate_Detail_Profile = {};
	
	if 0 == BP_Recent_Teammate_ScrollStart and 0 == BP_Recent_Teammate_Scroll_End then
		BP_Recent_Teammate_Scroll_End = LobbyFriendUI.friendProfileSlice;
	end
	
	local startIndex = BP_Recent_Teammate_ScrollStart / LobbyFriendUI.friendProfileSlice;
	local endIndex = BP_Recent_Teammate_ScrollEnd / LobbyFriendUI.friendProfileSlice;

	for i = 1, #BP_ARRAY_Recent_Teammate_Profile do
		local profileData = BP_ARRAY_Recent_Teammate_Profile[i];
		table.insert(BP_ARRAY_Recent_Teammate_Lite_Profile, { gid = profileData.gid .. tostring(profileData.endtime) });

		local index = i - 1;
		if (startIndex * LobbyFriendUI.friendProfileSlice <= index) and (endIndex * LobbyFriendUI.friendProfileSlice >= index) then			
			table.insert(BP_ARRAY_Recent_Teammate_Detail_Profile, profileData);
		end
	end
	
    LuaClassObj.HandleUIMessageNoFetch(bp_lobby_friend, "UpdateRecentTeammateList");
end

--游戏小悦URL和红点
BP_XY_API_URL = ""
function EventXYAPISetUrl()
    local url = "https://xyapi.game.qq.com/xiaoyue/service/redirect?game_id=1279&source=xy_games&login_type=msdk&partition_id=1"
    local plat_id = 0
    if BP_Platform == BP_ENUM_PLAYFORM_WX then
        plat_id = 2
    elseif BP_Platform == BP_ENUM_PLAYFORM_QQ then
        plat_id = 1
    end
    local xyapi = "";--Client.GetXY_API_Url(NetInterface)
    BP_XY_API_URL = string.format("%s%s&plat_id=%d&role_id=%d",url, xyapi, plat_id, BP_PlayerUid);
    log("BP_XY_API_URL:"..BP_XY_API_URL)
end

BP_Friend_Panel_Tab_Index = -1
function EventSetXYAPIShowRedPoint()
    BP_YXXY_RedPoint = 1
    LuaClassObj.HandleUIMessage(bp_global, "SetYXXYRedPoint")
	FriendSystem.UpdateXiaoYueRedPoint(BP_YXXY_RedPoint,BP_Friend_Panel_Tab_Index)
end

function EventSetXYAPIHideRedPoint()
    BP_YXXY_RedPoint = 0
    LuaClassObj.HandleUIMessage(bp_global, "ClearYXXYRedPoint")
	FriendSystem.UpdateXiaoYueRedPoint(BP_YXXY_RedPoint,BP_Friend_Panel_Tab_Index)
end

--请求亲密关系数据
function EventLobbyFriendIntimacyReq()
	--此处发送不需要回包红点，是因为，如果回包红点的话，由于点击之后，就要清除红点，导致红点信息被刷新掉了
	FriendSystem.getIntimacyRelationReq(false)
end

--刷新亲密关系列表
function LobbyFriendUI:UpdateIntimacyRelationPanel()
	log("updateintimacyrelationpanel")
	LuaClassObj.HandleUIMessageNoFetch(bp_lobby_friend, "UpdateIntimacyRelationPanel");
end

BP_Friend_Intimacy_Gid = ""
BP_Friend_Intimacy_Relation = 0
BP_Friend_Intimacy_Op = 0
BP_Friend_Intimacy_NickName = ""
--处理（同意或者拒绝）亲密关系建立申请
function EventLobbyFriendReplyRelationReq()
	FriendSystem.replyIntimacyRelationReq(BP_Friend_Intimacy_Gid,BP_Friend_Intimacy_Relation,BP_Friend_Intimacy_Op)
end

BP_Friend_Intimacy_Delete_Gid = ""
BP_Friend_Intimacy_Delete_Relation = 0
BP_Friend_Intimacy_Delete_NickName = ""
BP_Friend_Intimacy_Delete_State = -1
--删除亲密关系
function EventLobbyFriendDeleteRelationReq()
	if BP_Friend_Intimacy_Delete_State == 1 then
		local msg = Client.GetTableData("LocalizeRes",200057)
		if msg then
			--撤回亲密关系申请二次确认框
			local title = Client.GetTableData("LocalizeRes", "101001").TextValue
			CommonMessageBoxUI:ShowPanel(2,title,msg.TextValue,CancelBuildIntimacyRelation,nil)
		end
	elseif BP_Friend_Intimacy_Delete_State == 4 then
		local msg = Client.GetTableData("LocalizeRes",200036)
		if msg then
			--删除亲密关系申请二次确认框
			local title = Client.GetTableData("LocalizeRes", "101001").TextValue
			CommonMessageBoxUI:ShowPanel(2,title,msg.TextValue,DeleteIntimacyFriendRelation,nil)
		end
	end
end

function DeleteIntimacyFriendRelation()
	FriendSystem.deleteIntimacyRelationReq(tonumber(BP_Friend_Intimacy_Delete_Gid))
end

function CancelBuildIntimacyRelation()
	FriendSystem.cancelBuildIntimacyRelationReq(tonumber(BP_Friend_Intimacy_Delete_Gid))
end

--建立亲密关系
BP_Friend_Intimacy_Build_Gid = ""
BP_Friend_Intimacy_Build_Relation = 0
function EventLobbyFriendBuildRelationReq()
	--注意ReuseComboBox的index从0开始
	FriendSystem.buildIntimacyRelationReq(tonumber(BP_Friend_Intimacy_Build_Gid),tonumber(BP_Friend_Intimacy_Build_Relation))
end

--显示亲密关系申请小红点
BP_Friend_Intimacy_Apply_Has_New = false

--显示亲密关系申请小红点 情况2 是否有可以申请亲密关系的好友
BP_Friend_Intimacy_Relation_Available = false
function LobbyFriendUI:UpdateIntimacyApplyNewTips()
	LuaClassObj.HandleUIMessageNoFetch(bp_lobby_friend, "UpdateIntimacyApplyNewTips")
end

function LobbyFriendUI:UpdateIntimacyRelationAvailable()
	BP_Friend_Intimacy_Relation_Available = PersonSpaceSystem.HasIntimacyReddot(PersonSpaceReddotType.REDOT_NEW_INTIMACY_RELATION_AVAILABLE)

	log("LobbyFriendUI:UpdateIntimacyRelationAvailable:" .. tostring(BP_Friend_Intimacy_Relation_Available))
	LobbyFriendUI:UpdateIntimacyApplyNewTips()
end

function EventLobbyFriendRelationClick()
	if PersonSpaceSystem.HasIntimacyReddot(PersonSpaceReddotType.REDOT_NEW_INTIMACY_RELATION_AVAILABLE) then
		PersonSpaceSystem.remove_intimacy_reddot(PersonSpaceReddotType.REDOT_NEW_INTIMACY_RELATION_AVAILABLE)
	end
end


--刷新下拉框里的亲密关系数量
function LobbyFriendUI:RefreshIntimacyArray()
	LuaClassObj.HandleUIMessageNoFetch(bp_lobby_friend, "RefreshIntimacyArray")
end

--好友界面详细规则描述
function EventOpenFriendRuleDescriptionPanel()
	local titleText = DataMgr.GetMsgByID(4426)

	local showText
    if LobbySystem.LobbyMenuOpenStatus[BP_ENUM_LOBBY_MENU_PDD_SYSTEM].is_open ~= 1 then
        showText = string.format(
			"%s%s%s%s%s%s%s%s%s%s%s%s%s",
			DataMgr.GetMsgByID(4195),
			DataMgr.GetMsgByID(4196),
			DataMgr.GetMsgByID(4197),
			DataMgr.GetMsgByID(4198),
			DataMgr.GetMsgByID(4199),
			DataMgr.GetMsgByID(4200),
			DataMgr.GetMsgByID(4201),
			DataMgr.GetMsgByID(4202),
			DataMgr.GetMsgByID(4203),
			DataMgr.GetMsgByID(6715),
			DataMgr.GetMsgByID(4204),
			DataMgr.GetMsgByID(4205),
			DataMgr.GetMsgByID(4206)
		)
    else
		showText = string.format(
			"%s%s%s%s%s%s%s%s%s%s%s%s%s%s",
			DataMgr.GetMsgByID(4195),
			DataMgr.GetMsgByID(4196),
			DataMgr.GetMsgByID(4197),
			DataMgr.GetMsgByID(4198),
			DataMgr.GetMsgByID(4199),
			DataMgr.GetMsgByID(4200),
			DataMgr.GetMsgByID(4201),
			DataMgr.GetMsgByID(4202),
			DataMgr.GetMsgByID(6247),
			DataMgr.GetMsgByID(4203),
			DataMgr.GetMsgByID(6715),
			DataMgr.GetMsgByID(4204),
			DataMgr.GetMsgByID(4205),
			DataMgr.GetMsgByID(4206)
		)
    end 
	
	log(showText)
	PopUpNoticeUI.ShowMessageBox(titleText, showText)
end

--我的名片
function EventOpenMyCardPanelInFriendPanel()
	local roleUid = tonumber(DataMgr.roleData.uid)
	if roleUid > 0  then
		--如果是从亲密关系跳转过来的,那么再次回到个人空间的时候,必须关闭当前界面,不再跳回了
		if LobbyFriendUI.openFrom == LobbyFriendUIOpenFrom.PersonSpaceRelationShip then
			LobbyFriendUI.jumpToRoleInfoStatus = {DirectOpen = RoleInfoLabelType.Card, uid = DataMgr.roleData.uid}
			LobbyFriendUI:Hide()
		else
			RoleInfoUI.SetDirectOpen(RoleInfoLabelType.Card)
			RoleInfoSystem.Enter(DataMgr.roleData.uid)
			RoleInfoUI.Init(true, RoleInfoOpenFromType.LobbyFriendToCard)
		end
	end
end

--亲密关系详细规则描述
function EventOpenIntimacyDescriptionPanel()
	local titleText = DataMgr.GetMsgByID(4427)
	local showText
    if LobbySystem.LobbyMenuOpenStatus[BP_ENUM_LOBBY_MENU_PDD_SYSTEM].is_open ~= 1 then
		showText = string.format(
			"%s%s%s%s%s%s%s%s%s%s%s%s%s",
			DataMgr.GetMsgByID(4207),
			DataMgr.GetMsgByID(4208),
			DataMgr.GetMsgByID(4209),
			DataMgr.GetMsgByID(4210),
			DataMgr.GetMsgByID(4211),
			DataMgr.GetMsgByID(4212),
			DataMgr.GetMsgByID(4213),
			DataMgr.GetMsgByID(4214),
			DataMgr.GetMsgByID(4215),
			DataMgr.GetMsgByID(6715),
			DataMgr.GetMsgByID(4216),
			DataMgr.GetMsgByID(4217),
			DataMgr.GetMsgByID(4218)
		)

    else
		showText = string.format(
			"%s%s%s%s%s%s%s%s%s%s%s%s%s%s",
			DataMgr.GetMsgByID(4207),
			DataMgr.GetMsgByID(4208),
			DataMgr.GetMsgByID(4209),
			DataMgr.GetMsgByID(4210),
			DataMgr.GetMsgByID(4211),
			DataMgr.GetMsgByID(4212),
			DataMgr.GetMsgByID(4213),
			DataMgr.GetMsgByID(4214),
			DataMgr.GetMsgByID(6247),
			DataMgr.GetMsgByID(4215),
			DataMgr.GetMsgByID(6715),
			DataMgr.GetMsgByID(4216),
			DataMgr.GetMsgByID(4217),
			DataMgr.GetMsgByID(4218)
		)	
    end 
		
	PopUpNoticeUI.ShowMessageBox(titleText, showText)
end

BP_Friend_Add_Index = 0
function LobbyFriendUI:RefreshAddFriendBtnState(fromSystem,gid)
	if fromSystem == BP_ENUM_ADD_FRIEND_FROM_FRIEND_SEARCH then
		if BP_Friend_Panel_Tab_Index == 5 then
			for i = 1,#BP_ARRAY_Search_Friend_Profile,1 do
				if tonumber(gid) == tonumber(BP_ARRAY_Search_Friend_Profile[i].gid) then
					BP_Friend_Add_Index = i - 1
					log("BP_ENUM_ADD_FRIEND_FROM_FRIEND_SEARCH BP_Friend_Add_Index"..tostring(BP_Friend_Add_Index))
					LuaClassObj.HandleUIMessageNoFetch(bp_lobby_friend, "UpdateSearchPanelAddFriendBtn")
				end
			end
		end
	elseif fromSystem == BP_ENUM_ADD_FRIEND_FROM_FRIEND_RECENTTEAMMATE then
		if BP_Friend_Panel_Tab_Index == 2 then
			for i = 1,#BP_ARRAY_Recent_Teammate_Profile,1 do
				if tonumber(gid) == tonumber(BP_ARRAY_Recent_Teammate_Profile[i].gid) then
					BP_Friend_Add_Index = i - 1
					log("BP_ENUM_ADD_FRIEND_FROM_FRIEND_RECENTTEAMMATE BP_Friend_Add_Index"..tostring(BP_Friend_Add_Index))
					LuaClassObj.HandleUIMessageNoFetch(bp_lobby_friend, "UpdateRencentTeammatePanelAddFriendBtn")
				end
			end
		end
	elseif fromSystem == BP_ENUM_ADD_FRIEND_FROM_FRIEND_NEARBY then
		if BP_Friend_Panel_Tab_Index == 4 then
			for i = 1,#BP_ARRAY_Near_By_Gender_Filter_Profile,1 do
				if tonumber(gid) == tonumber(BP_ARRAY_Near_By_Gender_Filter_Profile[i].gid) then
					BP_Friend_Add_Index = i - 1
					log("BP_ENUM_ADD_FRIEND_FROM_FRIEND_NEARBY BP_Friend_Add_Index"..tostring(BP_Friend_Add_Index))
					LuaClassObj.HandleUIMessageNoFetch(bp_lobby_friend, "UpdateNearByPanelAddFriendBtn")
				end
			end
		end
	end
end

--已发送好友申请，加好友按钮灰化后点击该按钮的提示
--您已申请，请等待对方回应
function EventShowSendAddFriendRequestTips()
	DataMgr.ShowNoticeByID(200002)
end

function EventNearByOpenLocation()
	--[[
	log("EventNearByOpenLocation");
	BP_NearBy_Location_Open = true;

	log("Client.GetLocationInfo()");
	Client.GetLocationInfo(NetInterface);

	BP_Global_SelfUID = DataMgr.roleData.uid;
	BP_Global_CloseLocation = false;
	
	LuaClassObj.HandleUIMessage(bp_global, "SetCloseLocation");
	]]
end

function EventNearByCloseLocation()
	--[[
	log("EventNearByCloseLocation");
	BP_NearBy_Location_Open = false;
	
	FriendSystem.NearByClear = true;

	log("Client.CleanLocation()");
	Client.CleanLocation(NetInterface);

	BP_Global_SelfUID = DataMgr.roleData.uid;
	BP_Global_CloseLocation = true;

	LuaClassObj.HandleUIMessage(bp_global, "SetCloseLocation");
	]]
end

function EventOpenNearByPanel()
	log("EventOpenNearByPanel");
	FriendSystem.UpdateLobbyNewTips();
	FriendSystem.FetchNearByStatus();

end

function EventFetchNewNearByPersonInfoList()
	log("EventFetchNewNearByPersonInfoList");
	if (FriendSystem.ShowNearByPersonInfoArray == nil or #FriendSystem.ShowNearByPersonInfoArray == 0) then
		FriendSystem.CheckAndGetNearbyPersonInfo();
		DataMgr.ShowNoticeByID(200070);
	else
		if (FriendSystem.NearByGenderCount <= FriendSystem.NearByShowPageMaxNum) then
			DataMgr.ShowNoticeByID(200070);
		else
			FriendSystem.NearByShowPageIndex = FriendSystem.NearByShowPageIndex + 1;
			LobbyFriendUI.UpdateNearByPanel();
		end
	end
end

function LobbyFriendUI.UpdateNearByPanel()
	log("LobbyFriendUI.UpdateNearByPanel()");
	LuaClassObj.HandleUIMessageNoFetch(bp_lobby_friend, "UpdateNearByPanel");
end

function EventNearByUpdateFilterArray()
	log("EventNearByUpdateFilterArray")

	FriendSystem.NearByGenderCount = 0;
	BP_ARRAY_Near_By_Gender_Filter_Profile = {}

	if (#BP_ARRAY_Near_By_Profile > 0 and BP_NearBy_Location_Open == true) then
		
		for i = 1, #BP_ARRAY_Near_By_Profile, 1 do 

			local data = BP_ARRAY_Near_By_Profile[i];
		
			if (BP_NearBy_Gender_Filter == 0 or BP_NearBy_Gender_Filter == data.sex) then
				table.insert(BP_ARRAY_Near_By_Gender_Filter_Profile, data);

			end
		end
		
		FriendSystem.NearByGenderCount = #BP_ARRAY_Near_By_Gender_Filter_Profile;

		local beginIndex = (FriendSystem.NearByShowPageIndex - 1) * FriendSystem.NearByShowPageMaxNum + 1;
		local endIndex = FriendSystem.NearByShowPageIndex * FriendSystem.NearByShowPageMaxNum;

		if (beginIndex > #BP_ARRAY_Near_By_Gender_Filter_Profile) then
			FriendSystem.NearByShowPageIndex = 1;
			beginIndex = (FriendSystem.NearByShowPageIndex - 1) * FriendSystem.NearByShowPageMaxNum + 1;
			endIndex = FriendSystem.NearByShowPageIndex * FriendSystem.NearByShowPageMaxNum;
		end
		--log_tree("all BP_ARRAY_Near_By_Gender_Filter_Profile", BP_ARRAY_Near_By_Gender_Filter_Profile);
		local retArr = {};
		for i = beginIndex, endIndex, 1 do
			if (i <= #BP_ARRAY_Near_By_Gender_Filter_Profile) then
				table.insert(retArr, BP_ARRAY_Near_By_Gender_Filter_Profile[i]);
			else 
				break;
			end
		end
		BP_ARRAY_Near_By_Gender_Filter_Profile = retArr;
		--log_tree("after filter by index BP_ARRAY_Near_By_Gender_Filter_Profile", BP_ARRAY_Near_By_Gender_Filter_Profile);
	end
end


--- 拜师  >>>>>>>>>>>>>>>> start

	BP_LobbyFriend_Master_RedPoint = false ;

	---打开拜师面板
	function EventOpenMasterPanel()
		--MasterUI.OpenMasterPanel();
	end	

	function EventHideMasterPanel()
		--MasterUI.HideMasterPanel();
	end

	-- 师徒小红点
	function LobbyFriendUI.UpdateMasterRedPoint()
		--BP_LobbyFriend_Master_RedPoint = MasterSystem.IsRedPoint();
		--LuaClassObj.HandleUIMessageNoFetch(bp_lobby_friend, "UpdateMasterRedPoint");
	end

    -- 师徒功能未开启提示
    function EventLobbyFriendMasterNotOpen()
        --local title = Client.GetTableData("LocalizeRes", "101001").TextValue;
        --local text = Client.GetTableData("LocalizeRes", "120001").TextValue;

        --CommonMessageBoxUI:ShowPanel(1, title, text);
    end
    
---- 拜师  >>>>>>>>>>>>>>>> end


------------> 赠送道具给好友（世界杯活动） begin <------------
--显示赠送道具模式
BP_Friend_Send_Item = false
function LobbyFriendUI:OpenSendSelectFriend(itemResID, count, expireTime)
	BP_Friend_Send_Item = true
	BP_Friend_Process_Add_Friend = false
	BP_Friend_Send_Item_ResID = itemResID
	BP_Friend_Send_Item_Count = count
	BP_Friend_Send_Item_Expire = expireTime
	BP_Friend_Panel_Tab_Index = -1
	LobbyFriendUI:Init()
	LobbyFriendUI:Show()
end

BP_ARRAY_ALL_Friend_SendItem_Profile = {
	BP_STRUCT_FriendProfile = _G.BP_STRUCT_FriendProfile,
}
-- 可赠送道具好友精简数据
BP_ARRAY_SendItem_Friend_Lite_Profile = 
{
	BP_STRUCT_FriendLiteProfile = _G.BP_STRUCT_FriendLiteProfile,
}

BP_ARRAY_SendItem_Friend_Detail_Profile = 
{
	BP_STRUCT_FriendProfile = _G.BP_STRUCT_FriendProfile,
}

BP_SendItem_Friend_Scroll_Start = 0
BP_SendItem_Friend_Scroll_End = 0

-- 好友详情数据拉回来后的回调
function LobbyFriendUI:UpdateAllFriends(list)
	if list ~= nil then
		log("LobbyFriendUI:UpdateAllFriends return list "..#list)
	end
	BP_ARRAY_ALL_Friend_SendItem_Profile = list

	EventLobbyFriendSendItemList();
end

-- UIBP 中的list滚动消息来了之后回调这个
function EventLobbyFriendSendItemList()
	BP_ARRAY_SendItem_Friend_Lite_Profile = {};
	BP_ARRAY_SendItem_Friend_Detail_Profile = {};
	
	if BP_ARRAY_ALL_Friend_SendItem_Profile == nil then
		BP_SendItem_Friend_Scroll_Start = 0
		BP_SendItem_Friend_Scroll_End = 0
	else
		if 0 == BP_SendItem_Friend_Scroll_Start and 0 == BP_SendItem_Friend_Scroll_End then
			BP_SendItem_Friend_Scroll_End = LobbyFriendUI.friendProfileSlice
		end
		
		local startIndex = math.floor(BP_SendItem_Friend_Scroll_Start / LobbyFriendUI.friendProfileSlice)
		local endIndex = math.ceil(BP_SendItem_Friend_Scroll_End / LobbyFriendUI.friendProfileSlice)
		
		for i = 1, #BP_ARRAY_ALL_Friend_SendItem_Profile do
			local profileData = BP_ARRAY_ALL_Friend_SendItem_Profile[i]
			table.insert(BP_ARRAY_SendItem_Friend_Lite_Profile, { gid = profileData.gid })
			
			local index = i - 1;
			if (startIndex * LobbyFriendUI.friendProfileSlice <= index) and (endIndex * LobbyFriendUI.friendProfileSlice >= index) then			
				table.insert(BP_ARRAY_SendItem_Friend_Detail_Profile, profileData)
			end
		end
	end

	LuaClassObj.HandleUIMessageNoFetch(bp_lobby_friend, "UpdateSendItemPanel")
end

--赠送给好友的ID
BP_Friend_Send_Item_Friend_ID = ""
--赠送的道具ID
BP_Friend_Send_Item_ResID = 0
BP_Friend_Send_Item_Count = 0
BP_Friend_Send_Item_Expire = 0
function EventLobbySendItemReq()
	FriendSystem.send_friend_item_req(tonumber(BP_Friend_Send_Item_Friend_ID), BP_Friend_Send_Item_ResID, 1)
end

--赠送流程完毕，重置所有状态变量
function EventLobbySendFriendFinish()
	BP_Friend_Send_Item = false
	BP_SendItem_Friend_Scroll_Start = 0
	BP_SendItem_Friend_Scroll_End = 0
	BP_Friend_Send_Item_Friend_ID = ""
	BP_Friend_Send_Item_ResID = 0
	BP_Friend_Send_Item_Count = 0

	BP_Wardrobe_SendItemResID = 0
	BP_Wardrobe_RemainTime = 0
end

function LobbyFriendUI:SendItemSuccess()
	if BP_Friend_Send_Item_Count == 0 then
		return
	end
	BP_Friend_Send_Item_Count = BP_Friend_Send_Item_Count - 1
	log("SendItemSuccess "..BP_Friend_Send_Item_Count..","..BP_Friend_Send_Item_ResID)
	LuaClassObj.HandleUIMessageNoFetch(bp_lobby_friend, "SendItemSuccess")
end
------------> 赠送道具给好友（世界杯活动） end <------------

------------> 最近点赞 begin <------------

-- 点击左边tab（最近点赞）
function EventLobbyShowRecentLikePanel()
	FriendSystem.get_upvote_recent_req();
end

-- 服务器回复列表数据（最近点赞）,刷新列表
function LobbyFriendUI:UpdateRecentLikePanel()
	-- log_tree("BP_ARRAY_Recent_Like_Profile:", BP_ARRAY_Recent_Like_Profile);
	if LobbyFriendUI.isShowing and BP_Friend_Panel_Tab_Index == LobbyFriendUI.recentLike then
		LuaClassObj.HandleUIMessageNoFetch(bp_lobby_friend, "UpdateRecentLikePanel");
	end
end

-- 点击左边tab（最近点赞）
function LobbyFriendUI:LobbyShowRecentLikeDatas()
end
------------> 最近点赞 end <------------

--从外部打开关系界面
function LobbyFriendUI:ShowRelationshipPanel(openFrom, openFromStatus)
	LobbyFriendUI:Init(openFrom, openFromStatus);
	LobbyFriendUI:Show();
	LuaClassObj.HandleUIMessageNoFetch(bp_lobby_friend, "ShowRelationshipPanel");
end

