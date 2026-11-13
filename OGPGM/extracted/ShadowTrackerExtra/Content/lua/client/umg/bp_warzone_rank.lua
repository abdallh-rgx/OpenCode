WarZoneRankUI = WarZoneRankUI or {
    StreetZoneCdTimer = nil,
    LbsRankTypeIdArr = nil,
    HasEnterFlag = nil,
    isShow = false,
    isShowing = false,
    IntimacyFriendUid = {},-- 亲密好友映射
};

--注册Widget
function bp_warzone_rank_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_warzone_rank,
        {{Path = "/Game/UMG/UI_Logic/WarZone/WarZoneRank_BP.WarZoneRank_BP_C", Container = "Default", ZOrder = BP_ENUM_UI_WARZONE_RANK_ZORDER}},
        {"Lobby"},
        false,
        bp_warzone_rank_OnModeSwitched ~= nil,
        true
    );
end

function bp_warzone_rank_OnModeSwitched(gamestatus)
    local curStatus = string.lower(gamestatus);
    if "lobby" == curStatus then
        BP_WarZoneStreetPkIndex = -1
        WarZoneRankSystem.ClearStreetZoneInfo();
    else
        BP_WarZoneStreetPkIndex = -1
        WarZoneRankSystem.ClearStreetZoneInfo();
    end
end

-- lbs_rank_type_table ID
BP_WarZoneRankSelectType = 1;

BP_WarZoneRank_PlayerNumShowStatus = false

--排行榜信息(定义结构体：当且仅当以BP_STRUCT_开头的table能作为结构体给蓝图访问)
BP_STRUCT_WarZoneRankInfo =
{
    no = 0,
    uid = "",
    score = 0,

    name = "",              --名称
    url = "",               --头像
    level = 0,              --等级
    gender = 0,             --性别
    segment = 0,            --段位
    cur_avatar_box_id = 0,  --头像框
    startup_type = 0,--启动类型
    qq_vip = 0,--qq会员
    showWarZone = true,
    content1 = "",
    content2 = "",
    content3 = "",
};

--排行榜信息(定义结构体数组：当且仅当以BP_ARRAY_开头的table能作为数组给蓝图访问)
BP_ARRAY_WarZoneRankList =
{
    BP_STRUCT_WarZoneRankInfo = _G.BP_STRUCT_WarZoneRankInfo, --定义结构体数组，这种写法要作为规范规定下来
};

BP_STRUCT_WarZoneRankInfoMe =
{
    BP_STRUCT_WarZoneRankInfo = _G.BP_STRUCT_WarZoneRankInfo,
};

--主角信息
BP_STRUCT_MainAvatarInfo =
{
    isDataGet = false, --数据是否已经获取了
    BP_STRUCT_WarZoneRankInfo = _G.BP_STRUCT_WarZoneRankInfo,
};

--亲密好友信息
BP_STRUCT_FriendAvatarInfo =
{
    isDataGet = false,--数据是否已经获取了
    BP_STRUCT_WarZoneRankInfo = _G.BP_STRUCT_WarZoneRankInfo,
};

--sami 全球大区数据
BP_STRUCT_GlobalAreaInfo =
{
    ID=100000, Level=2, WarzoneContinentName="北美服", ContinentId=100000, WarzoneCountry="北美服", CountryFlag="NA", CountryKey="NA"
}
BP_ARRAY_GlobalAreaList =
{
    BP_STRUCT_GlobalAreaInfo = _G.BP_STRUCT_GlobalAreaInfo,
};
BP_STRUCT_GlobalContinentInfo =
{
    ID=1, ContinentName="亚洲"
}
BP_ARRAY_GlobalContinentList =
{
    BP_STRUCT_GlobalContinentInfo = _G.BP_STRUCT_GlobalContinentInfo,
};
BP_STRUCT_GlobalCountryInfo =
{
    ID=1001, Level=1, WarzoneContinentName="亚洲", ContinentId=1, WarzoneCountry="阿联酋", CountryFlag="AE", CountryKey="UAE"
}
BP_ARRAY_GlobalCountryList =
{
    BP_STRUCT_GlobalCountryInfo = _G.BP_STRUCT_GlobalCountryInfo,
};
--当前选择的数据
BP_CurSelectAreaId = 1;
BP_CurSelectContinentId = 0;
BP_CurSelectCountryId = 0;
--我的数据
BP_MySelectAreaId = 0;
BP_MySelectContinentId = 0;
BP_MySelectCountryId = 0;

--新手引导标记
BP_Warzone_Newbie_Status1 = false;
BP_Warzone_Newbie_Status2 = false;
BP_Warzone_Newbie_Status3 = false;

--段位最低要求提示
BP_Warzone_DuanWeiTips = "";

--我的排名标题类型
BP_Warzone_MyRankTipIndex = 0;
--列表为空的提示文本
BP_Warzone_RankListEmptyTips = "";
BP_Warzone_MyTopRankArea = 0;
BP_Warzone_MyTopTips = "";

--当前玩家的称号信息
BP_STRUCT_Warzone_Rank_Alias_Info =
{
	uid = "",
	aliasId = 0,
    roleNation = "",
	quality = 0,
	pathUrl = "",
	title = "",
}



BP_STRUCT_WarZoneMedalInfo =
{
    id = 1,
    rank_name = "单挑王者",
    order = 1,
    score_var = "solo_king_num",
    display_desc = "吃鸡次数",
    min_segment_id = 305,
    icon_path="/Game/Arts/UI/TableIcons/WarzonerankTitle/ZQ_icon_xunzhang_gangqiangwang.ZQ_icon_xunzhang_gangqiangwang", pedal_path="/Game/Arts/UI/TableIcons/WarzonerankTitle/ZQ_icon_xunzhang_jinse.ZQ_icon_xunzhang_jinse"
}

BP_STRUCT_AvatarInfo = 
{
    resID = 401999,
    colorID = 0,
    patternID = 0,
}

BP_ARRAY_AvatarList = 
{
    BP_STRUCT_AvatarInfo = _G.BP_STRUCT_AvatarInfo,
}

BP_STRUCT_WarZoneRank_PlayerData =
{
    gid = "",
    sex = 1,
    headid = 401999,
    --hairid = 1,
    BP_ARRAY_AvatarList = _G.BP_ARRAY_AvatarList,
    BP_ARRAY_FeatureList = {
        0,
    },
    weapon = 0
}

function EventWarZoneRankClose()
    log("EventWarZoneRankClose")
    UIManager.Hide(eUIType.eWarZoneRankUI)

    CoupleAvatarMgrUI.HideUI()
    
    WarZoneRankSystem.Release()
    WarZoneRankUI.Release()
    LuaClassObj.HandleUIMessageNoFetch(bp_warzone_rank, "HideUI");
    LuaClassObj.HandleUIMessage(bp_lobby, "DelRolePlayer")

	--恢复 所有的主界面
	EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE);
	LuaClassObj.HandleUIMessage(bp_lobby, "UIShowFromMall");
    LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "StartMallToLobby")
    
    LobbyUI:ShowLobbyPlayer(true);
    --LobbyUI:ResetAllPlayerAvatar();
end

function WarZoneRankUI.CloseUI()
    LuaClassObj.HandleUIMessage(bp_warzone_rank, "DestroyAvatar");
    EventWarZoneRankClose()
end

function WarZoneRankUI.OnCloseByLobby()
	WarZoneRankUI.Release()
    LuaClassObj.HandleUIMessageNoFetch(bp_warzone_rank, "HideUI");
end

BP_WarZoneRankScrollPos = 0
function EventWarZoneRankScrollPos()
    log("EventWarZoneRankScrollPos " .. tostring(BP_WarZoneRankScrollPos));
    if BP_WarZoneRank_Tab == 1 or BP_WarZoneRank_Tab == 2 then
        WarZoneRankSystem.QueryRoleInfoStart = BP_WarZoneRankScrollPos;
        WarZoneRankSystem.QueryRankRoleInfoByScroll(BP_WarZoneRank_Tab)
    end
end

BP_WarZoneRankSelectItemUid = ""
function EventWarZoneSelectItem()
    log("EventWarZoneSelectItem " .. tostring(BP_WarZoneRankSelectItemUid));
    local SelectItemUid = tonumber(BP_WarZoneRankSelectItemUid)

    CoupleAvatarMgrUI.DestroyAvatars()
    --CoupleAvatarMgrUI.ResetFriendBasicInfo()
    
    WarZoneRankSystem.GetRoleAvatarWearReq(SelectItemUid, AvatarShowSource.FromWarRegion)

    BP_ARRAY_WarZoneRank_PlayerData = {}
    
    local IntimacyFriendUid = WarZoneRankUI.IntimacyFriendUid[SelectItemUid] or 0
    if IntimacyFriendUid ~= 0 then
        WarZoneRankSystem.GetRoleAvatarWearReq(IntimacyFriendUid, AvatarShowSource.FromPartner)
    end

    --在获取穿戴后再获取avatar信息
    
	ProfileMgr.GetProfile(SelectItemUid, function(profileList)
		WarZoneRankUI.UpdateCurrentRoleAliasInfo();
	end, false);

    LuaClassObj.HandleUIMessageNoFetch(bp_warzone_rank, "UpdateAvatarInfo");
end

--亲密好友的Id
--BP_WarZoneRankSelectItemIntimacyUid = ""
--function WarZoneRankUI.IntimacyFriendAvatarWearReq() --亲密好友穿戴请求
--    WarZoneRankSystem.GetRoleAvatarWearReq(tonumber(BP_WarZoneRankSelectItemIntimacyUid))
--
--    --ProfileMgr.GetProfile(tonumber(BP_WarZoneRankSelectItemIntimacyUid), function(profileList)
--    --    WarZoneRankUI.UpdateCurrentRoleAliasInfo();
--    --end, false);
--end
--
--function WarZoneRankUI.GetIntimacyFriendUidRsp() --亲密好友穿戴请求
--
--    WarZoneRankUI.IntimacyFriendUid[BP_WarZoneRankSelectItemUid] = 510002653
--    WarZoneRankSystem.GetRoleAvatarWearReq(510002653)
--end

function WarZoneRankUI.UpdateAvatar(uid)
    if not WarZoneRankUI.isShowing then
        return 
    end
    uid = tonumber(uid)
    local SelectItemUid = tonumber(BP_WarZoneRankSelectItemUid)
    log("WarZoneRankUI.UpdateAvatar" .. tostring(uid))
    if uid == SelectItemUid or WarZoneRankUI.IntimacyFriendUid[SelectItemUid] == uid then
        local roleData = ProfileMgr.GetRoleInfoDataByUid(uid);
        if roleData == nil then
            return
        end
        
        --log_tree("roleData", roleData)

        WarZoneRankUI.IntimacyFriendUid[uid] = 0
        if roleData.partner_info and roleData.partner_info.partner_uid then
            WarZoneRankUI.IntimacyFriendUid[uid] = tonumber(roleData.partner_info.partner_uid)
        end
        --{partnet_uid = partner_uid, relation = relation}
        -- = tonumber(roleData.partner_uid or 0)
        --end
        local IntimacyFriendUid = WarZoneRankUI.IntimacyFriendUid[SelectItemUid] or 0
        
        log("IntimacyFriendUid:" .. IntimacyFriendUid)
        if uid == SelectItemUid and
                uid ~= IntimacyFriendUid and
                IntimacyFriendUid ~= 0 then
            WarZoneRankSystem.GetRoleAvatarWearReq(IntimacyFriendUid, AvatarShowSource.FromPartner)

            ProfileMgr.GetProfile(IntimacyFriendUid, function(listInfo)
                local ProfileInfo = {};
                for k,v in pairs(listInfo) do
                    --v.uid = k;
                    table.insert(ProfileInfo, v);
                end

                if #ProfileInfo >= 1 then
                    CoupleAvatarMgrUI.UpdateAvatarInfo(ProfileInfo[1])
                end
            end, false);
        end

        local SelectUID_roleData = ProfileMgr.GetRoleInfoDataByUid(SelectItemUid);
        local SelectUID_IntimacyFriend_roleData = ProfileMgr.GetRoleInfoDataByUid(IntimacyFriendUid);
        CoupleAvatarMgrUI.UpdateAvatar(SelectUID_roleData, SelectUID_IntimacyFriend_roleData, 1)
        
        log("WarZoneRankUI.UpdateAvatar2:" .. tostring(SelectItemUid) .. ", " .. IntimacyFriendUid)
    end
end

local function RequestList()
    log("RequestList")

    -- 战区排行
    if BP_WarZoneRank_Tab == 1 then
        WarZoneRankUI.RequestWarZoneRankList()
    -- 好友排行
    elseif BP_WarZoneRank_Tab == 2 then
        WarZoneRankUI.RequestFriendRankList()
    end
end

BP_WarZoneRank_Tab = 1
function EventWarZoneChangeRankTab()
    log("BP_WarZoneRank_Tab = " ..BP_WarZoneRank_Tab);
	BP_WarZoneRankSelectItemUid = ""
	WarZoneRankUI.UpdateCurrentRoleAliasInfo()
    RequestList();
    WarZoneRankSystem.UpdateRankSelf()
end

--重新拉取当前排行榜列表数据
function EventWarZoneRequestRankList()
    RequestList();
    WarZoneRankSystem.UpdateRankSelf()
end

-- 选择类型
function EventWarZoneChangeType()
    if BP_WarZoneRankSelectID == 0 then
        log("BP_WarZoneRankSelectID == 0");
        return
    end

    --log_tree("RefreshMedal BP_ARRAY_WarZoneRankList = ", BP_ARRAY_WarZoneRankList);
    LuaClassObj.HandleUIMessageNoFetch(bp_warzone_rank, "RefreshMedal");
    RequestList()
    WarZoneRankSystem.UpdateRankSelf()
end

-- 省 市 区
BP_WarZoneRankSelectID = 100000;
-- 是否显示战区强者按钮
BP_ShowRegionStrongerBtn = true;
function EventWarZoneRankSelectID()
    if BP_WarZoneRankSelectID == 0 then
        log("BP_WarZoneRankSelectID == 0");
        return
    end
    WarZoneRankUI.IsShowRegionStrongerBtn();
    RequestList();
end

function WarZoneRankUI.IsShowRegionStrongerBtn()

end

-- 自己的省 市 区
BP_WarZoneRankSelectID_Me = 440305

function WarZoneRankUI.RequestWarZoneRankList()
    WarZoneRankSystem.client_data.rank_type = BP_STRUCT_WarZoneMedalInfo.id;
    WarZoneRankSystem.client_data.rank_id = BP_CurSelectCountryId;
    WarZoneRankSystem.GetWarZoneRankListReq();
end

function WarZoneRankUI.RequestFriendRankList()
      WarZoneRankSystem.client_data.rank_type = BP_STRUCT_WarZoneMedalInfo.id;
--    WarZoneRankSystem.client_data.rank_id = 0;
    WarZoneRankSystem.GetWarZoneFriendListReq();
end

local function WarZoneRankEventHandler(eventType, eventID, vars)
    if eventType ~= EVENTTYPE_RANK then
        return;
    end
    if eventID == EVENTID_WARZONE_RANK_UPDATE_LIST then
        WarZoneRankUI.RefreshUI();
    elseif eventID == EVENTID_WARZONE_RANK_UPDATE_SELF then
        WarZoneRankUI.RefreshSelf();
    elseif eventID == EVENTID_WARZONE_RANK_UPDATE_ITEM then
        WarZoneRankUI.UpdateItem(vars)
    elseif eventID == EVENTID_WARZONE_RANK_LIST_COUNT then
        WarZoneRankUI.UpdateListCount(vars)
    elseif eventID == EVENTID_WARZONE_UPDATE_AVATAR then
        WarZoneRankUI.UpdateAvatar(vars)
    end
end

function WarZoneRankUI.OnUpdateNewbieStatus()
    BP_Warzone_Newbie_Status1 = DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_WARZONE, 1);
    BP_Warzone_Newbie_Status2 = DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_WARZONE, 2);
    BP_Warzone_Newbie_Status3 = DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_WARZONE, 3);
    LuaClassObj.HandleUIMessageNoFetch(bp_warzone_rank, "RefreshNewbieStatus");
end


--sami 获取区域列表
function WarZoneRankUI.GetAreaList()
    BP_ARRAY_GlobalAreaList = {};
    for k,v in pairs(Client.GetTable("GlobalCountryCfg")) do
	    if v.Level == 3 then
		    table.insert(BP_ARRAY_GlobalAreaList, v);
	    end
    end
    table.sort(BP_ARRAY_GlobalAreaList,
	    function(a,b)
		    return (a.ID < b.ID)
    end);
end
--获取大洲列表
function WarZoneRankUI.GetContinentList()
    BP_ARRAY_GlobalContinentList = {};

    for k,v in pairs(Client.GetTable("GlobalContinentCfg")) do
		table.insert(BP_ARRAY_GlobalContinentList, v);
    end
    table.sort(BP_ARRAY_GlobalContinentList,
	    function(a,b)
            if a.ID == BP_MySelectContinentId then
                return true
            elseif b.ID == BP_MySelectContinentId then
                return false
            end
		    return (a.ID < b.ID)
    end);
end
--获取选择大洲的国家列表
function WarZoneRankUI.GetCountryList()
    if BP_CurSelectContinentId == 0 then
        return;
    end
    BP_ARRAY_GlobalCountryList= {};
    for k,v in pairs(Client.GetTable("GlobalCountryCfg")) do
	    if v.ContinentId == BP_CurSelectContinentId and v.Level == 1 then
		    table.insert(BP_ARRAY_GlobalCountryList, v);
	    end
    end
    table.sort(BP_ARRAY_GlobalCountryList,
	    function(a,b)
            if a.ID == BP_MySelectCountryId then
                return true
            elseif b.ID == BP_MySelectCountryId then
                return false
            end
		    return ( string.lower(a.CountryKey) < string.lower(b.CountryKey) )
    end);
end
--重新计算国家列表
function EventGetCurCountryList()
    WarZoneRankUI.GetCountryList();
    if #BP_ARRAY_GlobalCountryList > 0 then
        BP_CurSelectCountryId = BP_ARRAY_GlobalCountryList[1].ID;
    end
end


function WarZoneRankUI.GetDuanWeiTips()
    local fmt = Client.GetTableData("LocalizeRes", "4776").TextValue;
    local id = BP_STRUCT_WarZoneMedalInfo.id;
    local cfg = Client.GetTableData("lbsranktypetable", id);
    local minSeg = cfg.min_segment_id;
    local cfg2 = Client.GetTableData("RankIntegralLevel", minSeg);
    local name = cfg2.Name;
    local str = string.format(fmt, name);
    log("WarZoneRankUI.GetDuanWeiTips = " ..str);
    return str;
end


function WarZoneRankUI.GetContinentCountryInfo(uid)
    local roleNation = ProfileMgr.GetRoleNationByUid(uid);
    if roleNation == "" then
        log("WarZoneRankUI.GetContinentCountryInfo roleNation nil "..uid)
        return nil;
    end
    local cfgCountry = nil;
    for k,v in pairs(Client.GetTable("GlobalCountryCfg")) do
        if v.CountryFlag == roleNation then
            cfgCountry = v;
            break;
        end
    end
    if cfgCountry == nil then
        return nil;
    end
    return {continentId = cfgCountry.ContinentId; countryId = cfgCountry.ID};
end

--sami 战区排行榜界面初始化入口
function WarZoneRankUI.Init()
    log("WarZoneRankUI Init");

    UIManager.Show(eUIType.eWarZoneRankUI)
    CoupleAvatarMgrUI.ShowUI(CoupleAvatarMgrUIOpenFrom.FromWarRank)

    --战区功能开关
    local openStatus = LobbySystem.LobbyMenuOpenStatus[BP_ENUM_WARZONE_PLAYERNUM]
    BP_WarZoneRank_PlayerNumShowStatus = (openStatus ~= nil and openStatus.is_open == 1) or false;
    --sami war
    BP_WarZoneRank_PlayerNumShowStatus = true;

    --获取大洲数据，国家数据，默认选中
    local info = WarZoneRankUI.GetContinentCountryInfo(DataMgr.roleData.uid);
    if info == nil then
        BP_MySelectContinentId = 0
        BP_MySelectCountryId = 0
    else
        BP_MySelectContinentId = info.continentId;
        BP_MySelectCountryId = info.countryId;
        BP_CurSelectContinentId = info.continentId;
        BP_CurSelectCountryId = info.countryId;
    end

    BP_CurSelectAreaId = 1;
    WarZoneRankUI.GetAreaList();
    WarZoneRankUI.GetContinentList();
    WarZoneRankUI.GetCountryList();

    WarZoneRankUI.isShow = true;
    BP_WarZoneRank_Tab = 1;
    WarZoneRankUI.isShowing = true;


    -- 首次进入，展示优先级最高的勋章；非首次，展示上次选择的
    if WarZoneRankUI.HasEnterFlag then
        BP_WarZoneRankSelectType = WarZoneRankSystem.client_data.rank_type;
    else
        WarZoneRankUI.HasEnterFlag = true;
        --sami war
        --BP_WarZoneRankSelectType = WarZoneRankSystem.GetFirstMedal();
    end

    BP_WarZoneRankSelectID = WarZoneRankSystem.client_data.rank_id;

    if DataMgr.lbs_warzone_info ~= nil then
        BP_WarZoneRankSelectID_Me = DataMgr.lbs_warzone_info.warzone_id
    else
        BP_WarZoneRankSelectID_Me = 440305
    end

    BP_WarZoneRankSelectItemUid = ""

    WarZoneRankUI.IntimacyFriendUid = {}
    --sami war
    --WarZoneRankUI.IsShowRegionStrongerBtn();
    local config = Client.GetTableData("lbsranktypetable", BP_WarZoneRankSelectType);
    BP_STRUCT_WarZoneMedalInfo = FuncUtil:CopyTable(config);
    BP_Warzone_DuanWeiTips = WarZoneRankUI.GetDuanWeiTips();
	
    LuaClassObj.HandleDynamicCreation(bp_warzone_rank);

    EventSystem:registEvent(EVENTTYPE_RANK, EVENTID_WARZONE_RANK_UPDATE_LIST, WarZoneRankEventHandler);
    EventSystem:registEvent(EVENTTYPE_RANK, EVENTID_WARZONE_RANK_UPDATE_SELF, WarZoneRankEventHandler);
    EventSystem:registEvent(EVENTTYPE_RANK, EVENTID_WARZONE_RANK_UPDATE_ITEM, WarZoneRankEventHandler);
    EventSystem:registEvent(EVENTTYPE_RANK, EVENTID_WARZONE_RANK_LIST_COUNT, WarZoneRankEventHandler);
    EventSystem:registEvent(EVENTTYPE_RANK, EVENTID_WARZONE_UPDATE_AVATAR, WarZoneRankEventHandler)
    EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_UPDATE_NEWBIE_STATUS, WarZoneRankUI.OnUpdateNewbieStatus);
    EventSystem:registEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN, WarZoneRankUI.WardRobeAvatarResetOpen);
    EventSystem:registEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE, WarZoneRankUI.WardRobeAvatarResetClose);
    EventSystem:registEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_WARZONE_BATTLE_INFO, WarZoneRankUI.OnWarzoneBattleInfo);

    --log_tree("ShowUI BP_ARRAY_WarZoneRankList = ", BP_ARRAY_WarZoneRankList);
    LuaClassObj.HandleUIMessageNoFetch(bp_warzone_rank, "ShowUI");
	WarZoneRankUI.UpdateCurrentRoleAliasInfo()

    --请求新手引导信息
	DataMgr.InitNewbieGuide();
    RoleInfoSystem.get_role_lbs_battle_info_req(DataMgr.roleData.uid);

    --sami war
    --WarZoneRankUI.CheckSysSwtich()

    --WarZoneRankSystem.GetWarZoneRankListReq();
    --WarZoneRankUI.RequestWarZoneRankList()
end

function WarZoneRankUI.CheckSysSwtich()
    local openStatus = LobbySystem.LobbyMenuOpenStatus[BP_ENUM_WARZONE_SHARE]
    local isShow = openStatus ~= nil and openStatus.is_open == 1;
    if isShow then
        LuaClassObj.HandleUIMessageNoFetch(bp_warzone_rank, "ShowShareBtn");
    else
        LuaClassObj.HandleUIMessageNoFetch(bp_warzone_rank, "HideShareBtn");
    end

    openStatus = LobbySystem.LobbyMenuOpenStatus[BP_ENUM_WARZONE_TOP_RANK]
    isShow = openStatus ~= nil and openStatus.is_open == 1;
    if isShow then
        LuaClassObj.HandleUIMessageNoFetch(bp_warzone_rank, "ShowRegionTopBtn");
    else
        LuaClassObj.HandleUIMessageNoFetch(bp_warzone_rank, "HideRegionTopBtn");
    end

    openStatus = LobbySystem.LobbyMenuOpenStatus[BP_ENUM_WARZONE_CHINA_TOP_RANK]
    isShow = openStatus ~= nil and openStatus.is_open == 1;
    if isShow then
        LuaClassObj.HandleUIMessageNoFetch(bp_warzone_rank, "ShowTopBtn");
    else
        LuaClassObj.HandleUIMessageNoFetch(bp_warzone_rank, "HideTopBtn");
    end

    openStatus = LobbySystem.LobbyMenuOpenStatus[BP_ENUM_WARZONE_LOCATE_UI]
    isShow = openStatus ~= nil and openStatus.is_open == 1;
    if isShow then
        LuaClassObj.HandleUIMessageNoFetch(bp_warzone_rank, "ShowLocateBtn");
    else
        LuaClassObj.HandleUIMessageNoFetch(bp_warzone_rank, "HideLocateBtn");
    end
end

function WarZoneRankUI.Release()
    log("WarZoneRankUI Release");

    EventSystem:unregistEvent(EVENTTYPE_RANK, EVENTID_WARZONE_RANK_UPDATE_LIST, WarZoneRankEventHandler);
    EventSystem:unregistEvent(EVENTTYPE_RANK, EVENTID_WARZONE_RANK_UPDATE_SELF, WarZoneRankEventHandler);
    EventSystem:unregistEvent(EVENTTYPE_RANK, EVENTID_WARZONE_RANK_UPDATE_ITEM, WarZoneRankEventHandler);
    EventSystem:unregistEvent(EVENTTYPE_RANK, EVENTID_WARZONE_RANK_LIST_COUNT, WarZoneRankEventHandler);
    EventSystem:unregistEvent(EVENTTYPE_RANK, EVENTID_WARZONE_UPDATE_AVATAR, WarZoneRankEventHandler)
    EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_UPDATE_NEWBIE_STATUS, WarZoneRankUI.OnUpdateNewbieStatus);
    EventSystem:unregistEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN, WarZoneRankUI.WardRobeAvatarResetOpen);
    EventSystem:unregistEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE, WarZoneRankUI.WardRobeAvatarResetClose);
    EventSystem:unregistEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_WARZONE_BATTLE_INFO, WarZoneRankUI.OnWarzoneBattleInfo);

    WarZoneRankUI.isShow = false
    WarZoneRankUI.isShowing = false;
    EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_WARZONE_CLOSE)
end

function WarZoneRankUI.RefreshUI()
    uid2idx = {}
    if BP_WarZoneRank_Tab == 1 then
        BP_ARRAY_WarZoneRankList = {}
        for i, v in ipairs(WarZoneRankSystem.RankInfoList) do
            local itm = FuncUtil:CopyTable(v)
            table.insert(BP_ARRAY_WarZoneRankList, itm)
            uid2idx[v.uid] = i
        end
        if #BP_ARRAY_WarZoneRankList == 0 then
            BP_Warzone_RankListEmptyTips = Client.GetTableData("LocalizeRes", 4790).TextValue;
        end

        WarZoneRankSystem.QueryRoleInfoStart = 1;
        WarZoneRankSystem.QueryRankRoleInfoByScroll(BP_WarZoneRank_Tab);
    elseif BP_WarZoneRank_Tab == 2 then
        BP_ARRAY_WarZoneRankList = {}
        for i, v in ipairs(WarZoneRankSystem.FriendRankInfoList) do
            local itm = FuncUtil:CopyTable(v)
            table.insert(BP_ARRAY_WarZoneRankList, itm)
            uid2idx[v.uid] = i
        end
        if #BP_ARRAY_WarZoneRankList == 0 then
            BP_Warzone_RankListEmptyTips = Client.GetTableData("LocalizeRes", 4791).TextValue;
        end
    end
    BP_STRUCT_WarZoneRankInfoMe.BP_STRUCT_WarZoneRankInfo = FuncUtil:CopyTable(WarZoneRankSystem.MyRankInfo)


    --log_tree("BP_ARRAY_WarZoneRankList = ", BP_ARRAY_WarZoneRankList);
    WarZoneRankUI.UpdateMyTopTips();
    LuaClassObj.HandleUIMessageNoFetch(bp_warzone_rank, "RefreshUI");
end

function WarZoneRankUI.FreshAll()
    log("WarZoneRankUI FreashAll");

    --获取大洲数据，国家数据，默认选中
    local info = WarZoneRankUI.GetContinentCountryInfo(DataMgr.roleData.uid);
    if info == nil then
        BP_MySelectContinentId = 0
        BP_MySelectCountryId = 0
    else
        BP_MySelectContinentId = info.continentId;
        BP_MySelectCountryId = info.countryId;
        BP_CurSelectContinentId = info.continentId;
        BP_CurSelectCountryId = info.countryId;
    end

    BP_CurSelectAreaId = 1;
    WarZoneRankUI.GetAreaList();
    WarZoneRankUI.GetContinentList();
    WarZoneRankUI.GetCountryList();

    BP_WarZoneRankSelectID = WarZoneRankSystem.client_data.rank_id;

    if DataMgr.lbs_warzone_info ~= nil then
        BP_WarZoneRankSelectID_Me = DataMgr.lbs_warzone_info.warzone_id
    else
        BP_WarZoneRankSelectID_Me = 440305
    end

    BP_WarZoneRankSelectItemUid = ""
    
    local config = Client.GetTableData("lbsranktypetable", BP_WarZoneRankSelectType);
    BP_STRUCT_WarZoneMedalInfo = FuncUtil:CopyTable(config);
    BP_Warzone_DuanWeiTips = WarZoneRankUI.GetDuanWeiTips();


    --log_tree("ShowUI BP_ARRAY_WarZoneRankList = ", BP_ARRAY_WarZoneRankList);
    LuaClassObj.HandleUIMessageNoFetch(bp_warzone_rank, "ShowUI");
	WarZoneRankUI.UpdateCurrentRoleAliasInfo()

    --请求新手引导信息
	DataMgr.InitNewbieGuide();
    RoleInfoSystem.get_role_lbs_battle_info_req(DataMgr.roleData.uid);
end

BP_STRUCT_WarZoneRankUpdateItemInfo =
{
    BP_STRUCT_WarZoneRankInfo = _G.BP_STRUCT_WarZoneRankInfo,
};
BP_WarZoneRankUpdateIdx = 0
function WarZoneRankUI.UpdateItem(vars)
    local tab, itm = vars[1], vars[2]
    if tab ~= BP_WarZoneRank_Tab then
        return
    end
    --log("WarZoneRankUI UpdateItem");
    local idx = uid2idx and uid2idx[itm.uid]
    if idx ~= nil then
        BP_ARRAY_WarZoneRankList[idx] = FuncUtil:CopyTable(itm)
        BP_WarZoneRankUpdateIdx = idx - 1


        BP_ARRAY_WarZoneRankList[idx].segment = itm.segment;

        --log_tree("UpdateItem BP_ARRAY_WarZoneRankList = ", BP_ARRAY_WarZoneRankList);

        LuaClassObj.HandleUIMessageNoFetch(bp_warzone_rank, "UpdateItem");

       
    end
    
end

BP_WarZoneRankListCount = 0
function WarZoneRankUI.UpdateListCount(bundle)
    if BP_WarZoneRankSelectID == bundle.id then
        BP_WarZoneRankListCount = bundle.count

        --log_tree("UpdateCount BP_ARRAY_WarZoneRankList = ", BP_ARRAY_WarZoneRankList);

        LuaClassObj.HandleUIMessageNoFetch(bp_warzone_rank, "UpdateCount");
    end
end

--打开个人信息
BP_WarZoneRankShowRoleUid = ""
function EventWarZoneRankShowRole()
    log("EventWarZoneRankShowRole uid = " ..BP_WarZoneRankShowRoleUid);
    if BP_WarZoneRank_Tab == 1 then
        ProfileMgr.GetProfileList({tonumber(BP_WarZoneRankShowRoleUid)}, function(profileList)
            log("EventWarZoneRankShowRole GetProfileList");
            local roleProfile = profileList[1]
            if roleProfile == nil or BP_WarZoneRankShowRoleUid == tostring(DataMgr.roleData.uid) then
                RoleInfoSystem.Enter(BP_WarZoneRankShowRoleUid);
                RoleInfoUI.Init(true, RoleInfoOpenFromType.WarZoneRank);
            else
                --if roleProfile.showWa rZone then
                RoleInfoSystem.Enter(BP_WarZoneRankShowRoleUid);
                RoleInfoUI.Init(true, RoleInfoOpenFromType.WarZoneRank);
                --end
            end
        end)
    else
        RoleInfoSystem.Enter(BP_WarZoneRankShowRoleUid);
        RoleInfoUI.Init(true, RoleInfoOpenFromType.WarZoneRank);
    end
end

--sami 个人信息角色开关处理
function WarZoneRankUI.WardRobeAvatarResetOpen()
    log("WarZoneRankUI.WardRobeAvatarResetOpen")
	if(WarZoneRankUI.isShowing == true) then
		LuaClassObj.HandleUIMessage(bp_warzone_rank, "HideSelf");
        GlobalData.SwitchSceneCameraByIndex(10001);
		WarZoneRankUI.isShowing = false;

        CoupleAvatarMgrUI.OpenAvatarInfo(false)
	end
end

function WarZoneRankUI.WardRobeAvatarResetClose()
    log("WarZoneRankUI.WardRobeAvatarResetClose")
	if WarZoneRankUI.isShowing == false then
		LuaClassObj.HandleUIMessage(bp_warzone_rank, "ShowSelf")
        GlobalData.SwitchSceneCameraByIndex(10106);
		WarZoneRankUI.isShowing = true;

        if UIManager.GetUI(eUIType.eCoupleAvatarMgrUI) == nil then --显示亲密partner信息
            CoupleAvatarMgrUI.ShowUI(CoupleAvatarMgrUIOpenFrom.FromWarRank)
        end
        CoupleAvatarMgrUI.OpenAvatarInfo(true)
        if BP_WarZoneRankSelectItemUid ~= "" then
            EventWarZoneSelectItem()
        end
	end
end

--获取当前玩家的称号信息
function WarZoneRankUI.UpdateCurrentRoleAliasInfo()
	if BP_WarZoneRankSelectItemUid == "" then
		BP_STRUCT_Warzone_Rank_Alias_Info.aliasId = 0
	else
		BP_STRUCT_Warzone_Rank_Alias_Info.uid = BP_WarZoneRankSelectItemUid;
		BP_STRUCT_Warzone_Rank_Alias_Info.aliasId = 0
		local profileInfo = ProfileMgr.GetPlayerDataByUid(tonumber(BP_WarZoneRankSelectItemUid));
		if tonumber(BP_WarZoneRankSelectItemUid) == tonumber(DataMgr.roleData.uid) then
			profileInfo = DataMgr.roleData
			log_tree("DataMgr.roleData ", DataMgr.roleData)
		end
		log_tree("profileInfo", profileInfo)
		if nil ~= profileInfo and nil ~= profileInfo.alias then
			BP_STRUCT_Warzone_Rank_Alias_Info.aliasId = profileInfo.alias.id
			BP_STRUCT_Warzone_Rank_Alias_Info.title = profileInfo.alias.title
			BP_STRUCT_Warzone_Rank_Alias_Info.roleNation = profileInfo.alias.nation
		end
		local cfg = Client.GetTableData("AliasCfg", BP_STRUCT_Warzone_Rank_Alias_Info.aliasId)
		if cfg then
			BP_STRUCT_Warzone_Rank_Alias_Info.quality = cfg.AliasQuality
			BP_STRUCT_Warzone_Rank_Alias_Info.pathUrl = cfg.AliasIconPath
		end
	end
	log_tree("BP_STRUCT_Warzone_Rank_Alias_Info", BP_STRUCT_Warzone_Rank_Alias_Info)
	LuaClassObj.HandleUIMessageNoFetch(bp_warzone_rank, "FreshCurrentRoleAliasInfo");
end

function WarZoneRankUI.GetTableMax(tb)
    local maxVal = 0;
    for k, v in pairs(tb) do
        if v > maxVal then
            maxVal = v;
        end
    end
    return maxVal;
end

function WarZoneRankUI.OnWarzoneBattleInfo()
    WarZoneRankSystem.UpdateRankSelf();

end

--地区强者榜
function EventOpenRegionStrongerUI()
    RegionStrongerRankUI.Init();
    RegionStrongerRankUI.Enter();
end

--地区强者榜
function EventOpenCountryStrongerUI()
    CountryStrongerRankUI.Init();
    CountryStrongerRankUI.Enter();

    if DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_WARZONE, 2) then
    	DataMgr.SetNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_WARZONE, 2);
    end
end

function EventShowMedalChoose()
    log("ShowMedalChoose");
    WarZoneMedalChooseUI.Init();

    if DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_WARZONE, 1) then
    	DataMgr.SetNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_WARZONE, 1);
    end
end

function WarZoneRankUI.UpdateMyTopTips()
    if BP_WarZoneRank_Tab == 1 and BP_Warzone_MyTopRankArea > 0 then
        local fmt = Client.GetTableData("LocalizeRes", "4945").TextValue;
        local areaName = Client.GetTableData("GlobalCountryCfg", BP_Warzone_MyTopRankArea).WarzoneCountry;
        BP_Warzone_MyTopTips = string.format(fmt, areaName);
    else
        BP_Warzone_MyTopTips = "";
    end
end

function WarZoneRankUI.RefreshSelf()
    if BP_WarZoneRank_Tab == 1 and (BP_MySelectContinentId ~= BP_CurSelectContinentId or BP_MySelectCountryId ~= BP_CurSelectCountryId) then
        BP_Warzone_MyRankTipIndex = 1;
    else
        BP_Warzone_MyRankTipIndex = 0;
    end
    WarZoneRankUI.UpdateMyTopTips();
    LuaClassObj.HandleUIMessageNoFetch(bp_warzone_rank, "RefreshSelf");
end

local function GetFriendShareTitleStr()
    local titleStr = Client.GetTableData("LocalizeRes", "4941").TextValue;
    local fmt = Client.GetTableData("LocalizeRes", "4942").TextValue;
    local rankStr =  string.format(fmt, WarZoneRankSystem.MyRankInfo.no);
    log("GetFriendShareTitleStr rankStr = " ..rankStr)
    return titleStr , rankStr
end

-- 需要填充succ, rank_id, warzone_title, needKillLeastNum（succ=false时需要填充）,killNum可选填充
function EventShareWarZoneTitle( )
    --log_tree("BP_ARRAY_WarZoneRankList = ", BP_ARRAY_WarZoneRankList);
    --log_tree("MyRankInfo = ", WarZoneRankSystem.MyRankInfo);

    local succ = false --失败还是成功
    local min_score = BP_ARRAY_WarZoneRankList[1] and BP_ARRAY_WarZoneRankList[1].score or 1
    for i, v in ipairs(BP_ARRAY_WarZoneRankList) do
        if v.uid == WarZoneRankSystem.MyRankInfo.uid then
            succ = true;
        end
        if v.score < min_score then
            min_score = v.score
        end
    end
    local rank_id = BP_WarZoneRankSelectType --排行榜id，就是lbsranktable的key
    local warzone_title = {warzone_id = BP_WarZoneRankSelectID, rank_id = rank_id, rank_no = WarZoneRankSystem.MyRankInfo.no} --称号的数据，key必须这样，到时候改value即可，warzone_id是chinacitytable的key，rank_no是第几名
    
    local titleStr , rankStr = ""
    if BP_WarZoneRank_Tab == 1 then 
        titleStr, rankStr = WarZoneTitleSystem.GetShareTitleRankStr(warzone_title)
    elseif BP_WarZoneRank_Tab == 2 then 
        titleStr, rankStr = GetFriendShareTitleStr()
    end

    local config = Client.GetTableData("lbsranktypetable", BP_WarZoneRankSelectType)
    local iconPath = config.icon_path
    local petalPath = config.pedal_path
    local killNum = WarZoneRankSystem.MyRankInfo.score --可以这里传入，如果这里保持nil，则分享界面自己请求数据
    local needKillLeastNum = 0 --失败分享时需要传入的最低上榜数据

    -- 失败才需要传入最低上榜的参数(击杀/吃鸡/空投等次数)，并且必须传入
    if succ == false then
        local listCount = #BP_ARRAY_WarZoneRankList
        if listCount >= 10 then
            needKillLeastNum = min_score
        else
            needKillLeastNum = 1
        end
    end

    ShareWarZoneTitletUI.Enter(succ, rank_id, titleStr, rankStr, iconPath, petalPath, killNum, needKillLeastNum,BP_WarZoneRank_Tab);
end


--显示帮助
function EventWarZoneRuleButtonClick()
    local title = Client.GetTableData("LocalizeRes", 4902).TextValue
    local fmt = Client.GetTableData("LocalizeRes", 4900).TextValue..Client.GetTableData("LocalizeRes", 4901).TextValue
    fmt = string.gsub(fmt, "\\n", "\n")

    local id = BP_STRUCT_WarZoneMedalInfo.id;
    local cfg = Client.GetTableData("lbsranktypetable", id);
    local minSeg = cfg.min_segment_id;
    local cfg2 = Client.GetTableData("RankIntegralLevel", minSeg);
    local name = cfg2.Name;

    local context = string.format(fmt, name);

    PopUpNoticeUI.ShowMessageBox(title, context)
    if DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_WARZONE, 3) then
    	DataMgr.SetNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_WARZONE, 3);
    end
end


BP_WarZoneStreetPkIndex = -1
BP_WarZoneStreetCdTime = ""
BP_WarZoneStreetLastLocationTime = -1
BP_ARRAY_WarZoneStreetNameList =
{
    street_name = "",
};

local tmp_around_info = {}

-- 显示附近街区列表
function EventWarZoneLBSShowStreetList( )

end

function EventWarZoneNeedRefreshStreetList( )

end

-- 选择某个街区
function EventWarZoneSelectOneStreet( )

end

function EventWarZoneLBSCantShareButtonClick()
    ShowNotice(120179)
end

function EventWarZoneClickTooFastClick()
    ShowNotice(120178)
end