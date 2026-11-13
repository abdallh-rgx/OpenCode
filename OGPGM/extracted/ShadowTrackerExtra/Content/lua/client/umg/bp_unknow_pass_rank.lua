-- RP排行榜
UnknowPassRankUI = UnknowPassRankUI or
{
    isOnlyShow = true;
}

--排行榜信息(定义结构体：当且仅当以BP_STRUCT_开头的table能作为结构体给蓝图访问)
BP_STRUCT_UnknowpassRankInfo =
{
    no = 0,
    uid = "",
    level = 0,              --等级
    name = "",              --名称
    nation = "",            --国籍
    head_icon_url = "",     --头像
    segment = 0,            --段位
    cur_avatar_box_id = 0,  --头像框
    gender = 0,             -- 性别
    score = 0,              -- pass总积分
    pass_level = 0,         -- pass等级
    is_buy = 0,             --是否购买
    show_icon = false,      --是否显示图标
    vaild = false;          --是否需要刷新
};

--排行榜信息(定义结构体数组：当且仅当以BP_ARRAY_开头的table能作为数组给蓝图访问)
BP_ARRAY_UnknowpassRankList =
{
    BP_STRUCT_UnknowpassRankInfo = _G.BP_STRUCT_UnknowpassRankInfo, --定义结构体数组，这种写法要作为规范规定下来
};

BP_STRUCT_UnknowpassRankInfoMe =
{
    BP_STRUCT_UnknowpassRankInfo = _G.BP_STRUCT_UnknowpassRankInfo,
};

BP_STRUCT_UnknowpassRankInfoCurrent =
{
    BP_STRUCT_UnknowpassRankInfo = _G.BP_STRUCT_UnknowpassRankInfo,
};

BP_UnknowpassRankSelfBelow1wDisplay = "";
BP_UnknowPassRankUpdateIdx = 0
BP_UnknowPassRank_NoSelect = true;

BP_UnknowPass_Rank_SeasonName = "";
BP_UnknowPass_Rank_SeasonTime = "";

--当前玩家的称号信息
BP_STRUCT_UnknowPass_Rank_Alias_Info =
{
    aliasId = 0,
    roleNation = "",
    quality = 0,
    pathUrl = "",
    title = "",
}

--请求数据
BP_UnknowPassRankScrollPos = 0

local uid2idx = {}

function bp_unknow_pass_rank_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_unknow_pass_rank,
    {
        {Path="/Game/UMG/UI_Logic/UnknowPass/UnknowPass_Rank_Logic_BP.UnknowPass_Rank_Logic_BP_C", Container="Default", ZOrder=0}
    }, 
    {"UnknowPass","Lobby"}, 
    false, 
    false, 
    true
    );
end

function UnknowPassRankUI.Show()
    UnknowPassSystem.HideAvatar();
    BP_UnknowPassRank_NoSelect = true;
    LuaClassObj.HandleDynamicCreation(bp_unknow_pass_rank);
    LuaClassObj.HandleUIMessage(bp_unknow_pass_rank, "UIShow");
    UIManager.Show(eUIType.eUnknowPassRankUI);
    CoupleAvatarMgrUI.ShowUI(CoupleAvatarMgrUIOpenFrom.FromUpass)
    UnknowPassRankUI.ChangeIsOnlyShow(true)
    EventSystem:registEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_RANK_UPDATE_LIST, UnknowPassRankUI.RankEventHandler);
    EventSystem:registEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_RANK_UPDATE_SELF, UnknowPassRankUI.RankEventHandler);
    EventSystem:registEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_RANK_UPDATE_ITEM, UnknowPassRankUI.RankEventHandler);
    EventSystem:registEvent(EVENTTYPE_RANK, EVENTID_WARZONE_UPDATE_AVATAR, UnknowPassRankUI.UpdateAvatarEventHandler)
    LastRankShowAvatarUid = "";
end

function UnknowPassRankUI.Hide()

    UIManager.Hide(eUIType.eUnknowPassRankUI);

    LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass_rank, "UIHide");
    CoupleAvatarMgrUI.DestroyAvatars();
    EventSystem:unregistEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_RANK_UPDATE_LIST, UnknowPassRankUI.RankEventHandler);
    EventSystem:unregistEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_RANK_UPDATE_SELF, UnknowPassRankUI.RankEventHandler);
    EventSystem:unregistEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_RANK_UPDATE_ITEM, UnknowPassRankUI.RankEventHandler);
    EventSystem:unregistEvent(EVENTTYPE_RANK, EVENTID_WARZONE_UPDATE_AVATAR, UnknowPassRankUI.UpdateAvatarEventHandler)
end

function UnknowPassRankUI.Init()
    RankSystem.Enter();
    UnknowPassRankSystem.Enter()
    BP_UnknowPassRankUpdateIdx = 0;
    LastRankShowAvatarUid = "";
end

-- 切换到全区
function EventUnknowPassRankAllZoneButtonOnClicked()
    UnknowPassRankSystem.SwitchShowPanel(false);
end

-- 切换到好友
function EventUnknowPassRankFriendButtonOnClicked()
    UnknowPassRankSystem.SwitchShowPanel(true);
    GemReportUtils.ReportBtnClickEvent(GemReportUtils.SubEventName_PassRankFriend)
end

function UnknowPassRankUI.RankEventHandler(eventType, eventID, item)
    if eventID == EVENTID_RANK_UPDATE_LIST then
        log("EVENTID_RANK_UPDATE_LIST");
        UnknowPassRankUI.UpdateList();
    elseif eventID == EVENTID_RANK_UPDATE_SELF then
        log("EVENTID_RANK_UPDATE_SELF");
        UnknowPassRankUI.UpdateSelf()
       
    elseif eventID == EVENTID_RANK_UPDATE_ITEM then
        log("EVENTID_RANK_UPDATE_ITEM");
        UnknowPassRankUI.UpdateItem(item)
    end
end

function UnknowPassRankUI.UpdateSelf()
    local selfInfo =  UnknowPassRankSystem.ConvertToRankInfo(RankSystem.RankInfoSelf)
    selfInfo.pass_level = UnknowPassSystem.Level;
    BP_STRUCT_UnknowpassRankInfoMe =
    {
        BP_STRUCT_UnknowpassRankInfo = selfInfo;
    };
    LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass_rank, "RefreshSelf");
end

function UnknowPassRankUI.UpdateList()
    BP_ARRAY_UnknowpassRankList = {};
    uid2idx = {}
    for i,v in ipairs(RankSystem.RankInfoList) do
        local itm = UnknowPassRankSystem.ConvertToRankInfo(v)
        table.insert(BP_ARRAY_UnknowpassRankList, itm)
        uid2idx[v.uid] = i
    end
    RankSystem.QueryRankRoleInfoByIdxFrom = 1;
    LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass_rank, "RefreshList");
end

function UnknowPassRankUI.UpdateItem(itm)
    local idx = uid2idx[itm.uid]
    for i,v in ipairs(BP_ARRAY_UnknowpassRankList) do
        if v.uid == itm.uid then
            local item = UnknowPassRankSystem.ConvertToRankInfo(itm);
            BP_ARRAY_UnknowpassRankList[i] = item;
            BP_UnknowPassRankUpdateIdx = idx-1
            BP_STRUCT_UnknowpassRankInfoCurrent =
            {
                BP_STRUCT_UnknowpassRankInfo = item;
            };
            LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass_rank, "RefreshItem");
            return
        end
    end
end

function UnknowPassRankUI.UpdateAvatarEventHandler(eventType, eventID, uid)
    if UnknowPassRankUI.isOnlyShow then
        uid = tonumber(uid)
        local roleData = ProfileMgr.GetRoleInfoDataByUid(uid);
        if roleData == nil then
            return
        end

        local SelectUID_roleData = ProfileMgr.GetRoleInfoDataByUid(uid);
        if SelectUID_roleData.bshow then
            CoupleAvatarMgrUI.UpdateAvatar(SelectUID_roleData, nil, 2)
            LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass_rank, "HideNoAvatarDetail");
        else
            CoupleAvatarMgrUI.DestroyAvatars();
            LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass_rank, "ShowNoAvatarDetail");
        end
        BP_UnknowPassRank_NoSelect = false;
        
    end
end

function UnknowPassRankUI.ChangeIsOnlyShow(isOnlyShow)
    log("UnknowPassRankUI.ChangeIsOnlyShow:" .. tostring(isOnlyShow))
    UnknowPassRankUI.isOnlyShow = isOnlyShow
    if UnknowPassRankUI.isOnlyShow then
        LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass_rank, "UIOnlyShow");
    else
        LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass_rank, "UIOnlyHide");
    end
end

function UnknowPassRankUI.GetStatus()
    log("UnknowPassRankUI.GetStatus:" .. tostring(UnknowPassRankUI.isOnlyShow))
    return {isOnlyShow = UnknowPassRankUI.isOnlyShow}
end

function UnknowPassRankUI.RecoverStatus(status)
    if status and status.isOnlyShow ~= nil then
        log("UnknowPassRankUI.RecoverStatus:" .. tostring(status.isOnlyShow))
        UnknowPassRankUI.ChangeIsOnlyShow(status.isOnlyShow)
        if status.isOnlyShow == true then
            ProfileMgr.get_avatar_show_req(BP_UnknowPassRankShowAvatarUid, AvatarShowSource.FromOther);
            CoupleAvatarMgrUI.ShowUI(CoupleAvatarMgrUIOpenFrom.FromUpass)
        end
    end
end

--打开个人信息
BP_UnknowPassRankShowRoleUid = ""
function EventUnknowPassRankShowRole()
    RoleInfoSystem.Enter(BP_UnknowPassRankShowRoleUid);
    RoleInfoUI.Init(false, RoleInfoOpenFromType.Upass);
end

-- 滚动时拉取rp排行榜
function EventUnknowPassRankScrollPos()
    log("EventRankScrollPos="..BP_UnknowPassRankScrollPos)
    RankSystem.QueryRankRoleInfoByIdxFrom = BP_UnknowPassRankScrollPos;
    RankSystem.QueryRankRoleInfoByScroll()
end

--显示其他人物
BP_UnknowPassRankShowAvatarUid = "";
LastRankShowAvatarUid = "";
function EventUnknowPassRankShowOtherAvatar()
    if BP_UnknowPassRankShowAvatarUid ~=  LastRankShowAvatarUid then
        ProfileMgr.get_avatar_show_req(BP_UnknowPassRankShowAvatarUid, AvatarShowSource.FromOther);
        UnknowPassRankUI.UpdateCurrentRoleAliasInfo();
        ProfileMgr.GetProfile(BP_UnknowPassRankShowAvatarUid, function(profileList)
            UnknowPassRankUI.UpdateCurrentRoleAliasInfo();
        end, false);
        LastRankShowAvatarUid = BP_UnknowPassRankShowAvatarUid;
    end
end

--获取当前玩家的称号信息
function UnknowPassRankUI.UpdateCurrentRoleAliasInfo()
    if BP_UnknowPassRankShowAvatarUid == "" then
        BP_STRUCT_UnknowPass_Rank_Alias_Info.aliasId = 0
    else
        BP_STRUCT_UnknowPass_Rank_Alias_Info.aliasId = 0
        local profileInfo = ProfileMgr.GetPlayerDataByUid(tonumber(BP_UnknowPassRankShowAvatarUid));
        if tonumber(BP_UnknowPassRankShowAvatarUid) == tonumber(DataMgr.roleData.uid) then
            profileInfo = DataMgr.roleData
            log_tree("DataMgr.roleData ", DataMgr.roleData)
        end
        log_tree("profileInfo", profileInfo)
        if nil ~= profileInfo and nil ~= profileInfo.alias then
            BP_STRUCT_UnknowPass_Rank_Alias_Info.aliasId = profileInfo.alias.id
            BP_STRUCT_UnknowPass_Rank_Alias_Info.title = profileInfo.alias.title
            BP_STRUCT_UnknowPass_Rank_Alias_Info.roleNation = profileInfo.alias.nation
        end
        local cfg = Client.GetTableData("AliasCfg", BP_STRUCT_UnknowPass_Rank_Alias_Info.aliasId)
        if cfg then
            BP_STRUCT_UnknowPass_Rank_Alias_Info.quality = cfg.AliasQuality
            BP_STRUCT_UnknowPass_Rank_Alias_Info.pathUrl = cfg.AliasIconPath
        end
    end
    log_tree("BP_STRUCT_UnknowPass_Rank_Alias_Info", BP_STRUCT_UnknowPass_Rank_Alias_Info)
    LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass_rank, "FreshCurrentRoleAliasInfo");
end