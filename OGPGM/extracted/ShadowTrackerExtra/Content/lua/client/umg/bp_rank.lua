RankUI = RankUI or 
{
	isShowing = false;
};

--注册Widget
function bp_rank_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_rank,
		{{Path="/Game/UMG/UI_BP/Rank/Rank_BP.Rank_BP_C", Container="Default", ZOrder=BP_ENUM_UI_RANK_ZORDER}},
		{"Lobby"},
		false,
            bp_rank_OnModeSwitched ~= nil,
		true
	);
    EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_RANK, RankUI.OnJumpUrl);
	LuaClassObj.SubShowHideEvent(bp_rank, { "Rank_BP_C" });
end

local function localText(id)
    local data = Client.GetTableData("LocalizeRes",id);
    if data then
        return data.TextValue
    end
    return ""
end

function EventRankFetchInfo()

end

local uid2idx = {}
--sum总分榜 win胜利榜 beat击败榜 total综合榜
BP_RankSelectType = "sum";
--single单人 double双人 team组队
BP_RankSelectMemberType = "single";
--all全区 friend好友
BP_RankRegionType = "all";

-- total累计, week本周
BP_RankPeriodType = "total";

BP_ARRAY_RankZoneList ={0 };

--排行榜信息(定义结构体：当且仅当以BP_STRUCT_开头的table能作为结构体给蓝图访问)
BP_STRUCT_RankInfo =
{
	no = 0,
    uid = "",
	score = 0,
    name = "",              --名称
    nation = "",            --国籍
    url = "",               --头像
    level = 0,              --等级
    city = "",              --地点
    gender = 0,             --性别
    content1 = "",
    content2 = "",
    content3 = "",
    uishow = false, --upass
    is_buy = 0, --upass
    segment = 0,            --段位
    cur_avatar_box_id = 0,  --头像框
	startup_type = 0,--启动类型
	qq_vip = 0,--qq会员
    aliasId = 0,
    aliasTitle = "",
    aliasNation = "",
};

--排行榜信息(定义结构体数组：当且仅当以BP_ARRAY_开头的table能作为数组给蓝图访问)
BP_ARRAY_RankList = 
{
	BP_STRUCT_RankInfo = _G.BP_STRUCT_RankInfo, --定义结构体数组，这种写法要作为规范规定下来
};

BP_STRUCT_RankInfoMe =
{
    BP_STRUCT_RankInfo = _G.BP_STRUCT_RankInfo,
};

BP_RankInfoSelfBelow1wDisplay = ""

local function RankEventHandler(eventType, eventID, vars)
    if eventType ~= EVENTTYPE_RANK then
		return;
	end
	--列表更新
	if eventID == EVENTID_RANK_UPDATE_LIST then
		--log("EVENTID_RANK_UPDATE_LIST");
        BP_RankSelectType = RankSystem.RankSelectType;
        BP_RankSelectMemberType = RankSystem.RankSelectMemberType;
        BP_RankRegionType = RankSystem.RankRegionType;
        BP_RankPeriodType = RankSystem.RankPeriodType;

		RankUI.RefreshUI();
    elseif eventID == EVENTID_RANK_UPDATE_SELF then
        --log("EVENTID_RANK_UPDATE_SELF");
		RankUI.RefreshSelf();
    elseif eventID == EVENTID_RANK_UPDATE_ITEM then
        --log("EVENTID_RANK_UPDATE_ITEM");
        RankUI.UpdateItem(vars)
	end
end

function bp_rank_OnModeSwitched(gamestatus)
    if string.lower(gamestatus) == "lobby" then
        log("bp_rank_OnModeSwitched")
        RankSystem.RankSelectType = "sum"
        RankSystem.RankRegionType = "all"
        RankSystem.RankSelectMemberType = "single"
    end
end

function RankUI.OnJumpUrl()
    -- body
    log("[TAL]=== 跳转到排行榜界面");
    EventEnterRank();  
end

function RankUI.Init()

	LuaClassObj.HandleDynamicCreation(bp_rank);
    log("RankUI.Init")
    
    --sum总分榜 win胜利榜 beat击败榜 total综合榜
    BP_RankSelectType = RankSystem.RankSelectType;
    --single单人 double双人 team组队
    BP_RankSelectMemberType = RankSystem.RankSelectMemberType;
    --all全区 friend好友
    BP_RankRegionType = RankSystem.RankRegionType;

    BP_RankPeriodType = RankSystem.RankPeriodType

    BP_ARRAY_RankRole = {};
    BP_ARRAY_RankRoleInfoList = {};
    EventSystem:registEvent(EVENTTYPE_RANK, EVENTID_RANK_UPDATE_LIST, RankEventHandler);
    EventSystem:registEvent(EVENTTYPE_RANK, EVENTID_RANK_UPDATE_SELF, RankEventHandler);
    EventSystem:registEvent(EVENTTYPE_RANK, EVENTID_RANK_UPDATE_ITEM, RankEventHandler);
	EventSystem:registEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN, RankUI.WardRobeAvatarResetOpen);
    EventSystem:registEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE, RankUI.WardRobeAvatarResetClose);
	
    LuaClassObj.HandleUIMessageNoFetch(bp_rank, "ShowUI");
	RankUI.isShowing = true;
	
    --RankSystem.ReqFetchRankData(true);
    --RankSystem.ReqFetchRankData(true, BP_Back_ShowRankZoneId);
    --RankSystem.ReqFriendRankRole(BP_Back_ShowRankZoneId);
end

function RankUI.Release()
	log("RankUI.Release")
	EventSystem:unregistEvent(EVENTTYPE_RANK, EVENTID_RANK_UPDATE_LIST, RankEventHandler);
    EventSystem:unregistEvent(EVENTTYPE_RANK, EVENTID_RANK_UPDATE_SELF, RankEventHandler);
    EventSystem:unregistEvent(EVENTTYPE_RANK, EVENTID_RANK_UPDATE_ITEM, RankEventHandler);
	EventSystem:unregistEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN, RankUI.WardRobeAvatarResetOpen);
    EventSystem:unregistEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE, RankUI.WardRobeAvatarResetClose);
end

function RankUI.RefreshUI()
    BP_ARRAY_RankList = {};
    uid2idx = {}
    --local max_num = 10000
    for i,v in ipairs(RankSystem.RankInfoList) do
        --if i > max_num then
        --    break
        --end
        local itm = FuncUtil:CopyTable(v)
        table.insert(BP_ARRAY_RankList, itm)
        uid2idx[v.uid] = i
    end
    --log_tree("BP_ARRAY_RankList", BP_ARRAY_RankList);
    LuaClassObj.HandleUIMessageNoFetch(bp_rank, "RefreshUI");
    RankSystem.QueryRankRoleInfoByIdxFrom = 1;
    RankSystem.QueryRankRoleInfoByScroll();
end

function RankUI.RefreshSelf()
    if RankSystem.RankRegionType == "friend" then
        BP_RankInfoSelfBelow1wDisplay = RankSystem.RankInfoSelf.no;
    end
    BP_STRUCT_RankInfoMe =
    {
        BP_STRUCT_RankInfo = FuncUtil:CopyTable(RankSystem.RankInfoSelf)
    };
    LuaClassObj.HandleUIMessage(bp_rank, "RefreshSelf");
end

BP_STRUCT_RankUpdateItemInfo =
{
    BP_STRUCT_RankInfo = _G.BP_STRUCT_RankInfo,
};
BP_RankUpdateIdx = 0
function RankUI.UpdateItem(itm)
    local idx = uid2idx[itm.uid]    
    for i,v in ipairs(BP_ARRAY_RankList) do
        if v.uid == itm.uid then
            BP_ARRAY_RankList[i] = FuncUtil:CopyTable(itm)
            BP_RankUpdateIdx = idx-1
        LuaClassObj.HandleUIMessageNoFetch(bp_rank, "UpdateItem");
            return
        end
    end
end

--sami 个人信息角色开关处理
function RankUI.WardRobeAvatarResetOpen()
    log("RankUI.WardRobeAvatarResetOpen")
	if(RankUI.isShowing == true) then
		LuaClassObj.HandleUIMessage(bp_rank, "OnlyHideUI");
		RankUI.isShowing = false;
	end
end

function RankUI.WardRobeAvatarResetClose()
    log("RankUI.WardRobeAvatarResetClose")
	if RankUI.isShowing == false and MallSystemUI_2.isBackingFromRoleUI == false then
		LuaClassObj.HandleUIMessage(bp_rank, "OnlyShowUI");
		RankUI.isShowing = true;
	end
end

-- 蓝图申请列表数据
function EventQueryRank()
    log("BP_RankRegionType："..BP_RankRegionType.." BP_RankSelectType："..BP_RankSelectType.." BP_RankSelectMemberType："..BP_RankSelectMemberType)
    BP_ARRAY_RankList = {};
    uid2idx = {}
    RankUI.RefreshUI();
    local bQueryFriend = BP_RankRegionType ~= "all";-- 选区导致这里全区和好友不是互斥的关系，所以要这么判断！(RankSystem.RankRegionType ~= BP_RankRegionType)
    RankSystem.RankRegionType = BP_RankRegionType;
    RankSystem.RankSelectType = BP_RankSelectType;
    RankSystem.RankSelectMemberType = BP_RankSelectMemberType;
    RankSystem.RankPeriodType = BP_RankPeriodType
   -- RankSystem.ReqFetchRankData(bQueryFriend);
     --if BP_Back_ShowRankZoneId > 0 then
        log("EventQueryRank - "..BP_Back_ShowRankZoneId);
        RankSystem.ReqFetchRankData(bQueryFriend, BP_Back_ShowRankZoneId);
        
    --end
end

--请求数据
BP_RankScrollPos = 0
function EventRankScrollPos()
    log("EventRankScrollPos="..BP_RankScrollPos)
    RankSystem.QueryRankRoleInfoByIdxFrom = BP_RankScrollPos;
    RankSystem.QueryRankRoleInfoByScroll()
end

--关闭界面
function EventRankClose()
    RankSystem.Release()
    RankUI.Release()
    LuaClassObj.HandleUIMessageNoFetch(bp_rank, "HideUI");
	RankUI.isShowing = false;
end

--打开个人信息
BP_RankShowRoleUid = ""
function EventRankShowRole()
    log("EventRankShowRole")
    RoleInfoSystem.Enter(BP_RankShowRoleUid);
    RoleInfoUI.Init(false, RoleInfoOpenFromType.RankUI);
end

--显示帮助
BP_RankShowHelpContent = ""
function EventRankShowHelp()
    log("EventRankShowHelp")
    if BP_RankSelectType == "sum" or BP_RankSelectType == "fpp_sum" then
        BP_RankShowHelpContent = string.format("%s\n\n%s\n\n%s\n\n%s", localText(103001), localText(103002), localText(103003), localText(103007));
    elseif BP_RankSelectType == "win" or BP_RankSelectType == "fpp_win" then
        BP_RankShowHelpContent = string.format("%s\n\n%s\n\n%s\n\n%s", localText(103003), localText(103004), localText(103005), localText(103006));
    elseif BP_RankSelectType == "beat" or BP_RankSelectType == "fpp_beat" then
        BP_RankShowHelpContent = string.format("%s\n\n%s\n\n%s\n\n%s", localText(103007), localText(103008), localText(103009), localText(103010));
    else
        BP_RankShowHelpContent = string.format("%s\n\n%s\n\n%s\n\n%s", localText(103011), localText(103012), localText(103013), localText(103014));
    end
    if BP_RankShowHelpContent == nil then
        BP_RankShowHelpContent = "";
    end
    LuaClassObj.HandleUIMessageNoFetch(bp_rank, "ShowHelp");
end

--测试数据
function EventTestRank()
    RankSystem.ReqRankRoleInfo(121321);
end


BP_Rank_IsUPassOpened = false;
function EventIsUPassRankOpened()
    if LobbySystem.LobbyMenuOpenStatus[BP_ENUM_LOBBY_MENU_UNKNOW_PASS] == nil then
        BP_Rank_IsUPassOpened = true;
    else
        if LobbySystem.LobbyMenuOpenStatus[BP_ENUM_LOBBY_MENU_UNKNOW_PASS].is_open == 0 then
            BP_Rank_IsUPassOpened = false;
        else
            BP_Rank_IsUPassOpened = true;
        end
    end
end

function EventRankGetZoneList()
	log("EventRankGetZoneList");
    BP_ARRAY_RankZoneList = DataMgr.AllZoneList;
end


BP_Back_ShowRankZoneId  = 0;
function EventRank_Push()
    log("BP_Back_ShowRankZoneId = "..BP_Back_ShowRankZoneId);
    EventQueryRank();
end