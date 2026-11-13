PersonSpaceMainUI = PersonSpaceMainUI or
        {
            IntimacyFriendUid = 0,
            SelfWearData = nil,
            FriendWearData = nil,
            isShow = false,
            IsOnlyShow = true,
            UIRoot = nil,
        }

BP_PersonSpaceMain_RelationRedpoint = false

BP_PersonSpaceMain_SwitchCameraBlendTime_f = 0.7

BP_PersonSpaceMain_IsShow_Relation = true

--是否展示Avatar
BP_PersonSpaceMain_CanShowAvatar = true

BP_PersonSpaceMain_FoldAni_Time = 0.4


function bp_person_space_main_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_person_space_main,
            {{Path = "/Game/UMG/UI_Logic/PersonSpace/PersonSpaceMain_BP.PersonSpaceMain_BP_C", Container = "Default", ZOrder = BP_ENUM_UI_ROLEINFO_ZORDER + 10}},
            {"Lobby"},
            false,
            false,
            true
    );
end

local function GetRoleInfoPopularitySystem()
    local RoleInfoPopularitySystem = require("client.slua.logic.person_space.logic_roleinfo_popularity")
    return RoleInfoPopularitySystem
end

local function PersonSpaceMainUI_UIRoot()
    return UIUtil.GetWidgetByLogicName("bp_person_space_main")
end

function PersonSpaceMainUI.ShowUI()
    log("PersonSpaceMainUI.ShowUI")

    BP_PersonSpaceMain_CanShowAvatar = true
    
    LuaClassObj.HandleDynamicCreation(bp_person_space_main);
    LuaClassObj.HandleUIMessageNoFetch(bp_person_space_main, "UIShow");

    PersonSpaceMainUI.InitPopularity()

    UIManager.Show(eUIType.ePersonSpaceMainUI)

    UIManager.Show(eUIType.eCoupleAvatarMgrUI)

    BP_PersonSpaceMain_IsShow_Relation = true --LobbyUI:CheckLobbyMenuOpen(BP_ENUM_PERSONSPACE_PARTNERSETTING)

    PersonSpaceMainUI.UnFoldMenuImmediately()


    if PersonSpaceSystem.HasIntimacyReddot(PersonSpaceReddotType.REDOT_INTIMACY_PARTNER_CHG) then
        PersonSpaceSystem.remove_intimacy_reddot(PersonSpaceReddotType.REDOT_INTIMACY_PARTNER_CHG)
    end
    
    EventSystem:registEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_REDDOT_UPDATE, PersonSpaceMainUI.RefreshRelationRedpoint);
    EventSystem:registEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_PARTNER_CHANGE, PersonSpaceMainUI.OnPartnerChange);
    EventSystem:registEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_GET_POPULARITY_RSP, PersonSpaceMainUI.GetPopularityRsp);
    EventSystem:registEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_CLOSE_REDDOT_RSP, PersonSpaceMainUI.GetPopularityRsp);
    EventSystem:registEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_PSPACE_SEND_GIFT_RSP, PersonSpaceMainUI.PlayGiftAnim);

    PersonSpaceMainUI.RefreshRelationRedpoint()

    PersonSpaceMainUI.IntimacyFriendUid = 0

    PersonSpaceMainUI.SelfWearData = nil
    PersonSpaceMainUI.FriendWearData = nil


    PersonSpaceMainUI.UpdateAchievementScore()
    
    PersonSpaceMainUI.UpdateRoleInfo()

    EventPersonSpaceMain_HideInfo()
    --0.1s 后刷新显示
    Timer.InsertTimer(0.1, EventPersonSpaceMain_ShowInfo, false, false)

    EventSystem:registEvent(EVENTTYPE_RANK, EVENTID_WARZONE_UPDATE_AVATAR, PersonSpaceMainUI.UpdateAvatarRsp)

    RoleInfoSystem.get_avatar_show_req(RoleInfoSystem.CurShowPlayerInfoUid, AvatarShowSource.FromPersonSpace)

    local RoleInfoPopularitySystem = GetRoleInfoPopularitySystem()
    RoleInfoPopularitySystem.get_popularity_req(RoleInfoSystem.CurShowPlayerInfoUid)
end

function PersonSpaceMainUI.InitPopularity()

    local UIRoot = PersonSpaceMainUI_UIRoot()
    if UIRoot == nil then
        return
    end

    local RoleInfoPopularitySystem = GetRoleInfoPopularitySystem()

    local UIBP = UIRoot.Lobby_RoleInfo_Space_UIBP
    UIBP.PopularityCount:SetVisibility(UIUtil.BoolToVisible(false))
    UIBP.Image_0:SetVisibility(UIUtil.BoolToVisible(false))

    UIBP.cannel_Tips:SetVisibility(UIUtil.BoolToVisible(false))
end

function PersonSpaceMainUI.PlayGiftAnim()
    local UIRoot = PersonSpaceMainUI_UIRoot()
    if UIRoot == nil then
        return
    end

    local RoleInfoPopularitySystem = GetRoleInfoPopularitySystem()
    local UIBP = UIRoot.Lobby_RoleInfo_Space_UIBP

    UIBP.cannel_Tips:SetVisibility(UIUtil.BoolToVisible(true))

    local str= FuncUtil.LocalizeResFormat(6828, RoleInfoPopularitySystem.AddDevote)
    UIBP.TextBlock_5:SetText(str)

    UIBP:PlayAnimation( UIBP.Tips_ani, 0, 1, 0, 1)

    UIBP.Tips_ani.OnAnimationFinished:Clear()
    UIBP.Tips_ani.OnAnimationFinished:Add(function()
        UIBP.cannel_Tips:SetVisibility(UIUtil.BoolToVisible(false))
    end)

    PersonSpaceMainUI.GetPopularityRsp()
end

function PersonSpaceMainUI.GetPopularityRsp()
    --RoleInfoPopularitySystem.TotalPopularity = total_devote
    --RoleInfoPopularitySystem.DevoteInfo = devote_info
    --RoleInfoPopularitySystem.IsShowDetail = is_show_detail
    --RoleInfoPopularitySystem.IsShowReddot = is_show_reddot or false
    log("PersonSpaceMainUI.GetPopularityRsp")
    local UIRoot = PersonSpaceMainUI_UIRoot()
    if UIRoot == nil then
        return
    end

    local RoleInfoPopularitySystem = GetRoleInfoPopularitySystem()


    local UIBP = UIRoot.Lobby_RoleInfo_Space_UIBP
    UIBP.PopularityCount:SetText(tostring(RoleInfoPopularitySystem.TotalPopularity))

    local isShowDetail = RoleInfoSystem.IsSelf() or RoleInfoPopularitySystem.IsShowDetail

    UIBP.PopularityCount:SetVisibility(UIUtil.BoolToVisible(isShowDetail))
    UIBP.Image_0:SetVisibility(UIUtil.BoolToVisible(isShowDetail))

    UIBP.PopularityItem:SetVisibility(UIUtil.BoolToVisible(true))

    local isShowReddot = RoleInfoSystem.IsSelf() and RoleInfoPopularitySystem.IsShowReddot
    UIBP.popularity_reddot:SetVisibility(UIUtil.BoolToVisible(isShowReddot))

    local giftType = RoleInfoPopularitySystem.DevoteGiftType.Gift1

    UIBP.DevoteRoot:SetVisibility(UIUtil.BoolToVisible(not RoleInfoSystem.IsSelf()))
    local index = RoleInfoPopularitySystem.CheckCanDevote(giftType) and 0 or 1
    UIBP.WidgetSwitcher_10:SetActiveWidgetIndex(index)

    UIBP.Button_2.OnClicked:Clear()
    UIBP.Button_2.OnClicked:Add(function()
        if RoleInfoPopularitySystem.CheckCanDevote(giftType) then
            RoleInfoPopularitySystem.pspace_send_gift_req(RoleInfoSystem.CurShowPlayerInfoUid, giftType)
        else
            DataMgr.ShowNoticeByID(6803)
        end

        local util = require("ui.util")
        local sound_config = require("client.slua.config.sound")

        util.PlayAudio(sound_config.click, PersonSpaceMainUI_UIRoot())

        GemReportUtils.ReportBtnClickEvent(GemReportUtils.SubEventName_PersonSpaceSendGift)
    end)
end

function PersonSpaceMainUI.OnPartnerChange()
    log("OnPartnerChange")
    CoupleAvatarMgrUI.DestroyAvatars()
    ProfileMgr.get_avatar_show_req(RoleInfoSystem.CurShowPlayerInfoUid, AvatarShowSource.FromPersonSpace);
end

function PersonSpaceMainUI.RefreshRelationRedpoint()
    BP_PersonSpaceMain_RelationRedpoint = DataMgr.roleData.uid == RoleInfoSystem.CurShowPlayerInfoUid and PersonSpaceSystem.HasIntimacyReddotAll()
    
    log("PersonSpaceMainUI.RefreshRelationRedpoint:" .. tostring(BP_PersonSpaceMain_RelationRedpoint))
    LuaClassObj.HandleUIMessageNoFetch(bp_person_space_main, "RefreshRelationRedpoint");
end

function PersonSpaceMainUI.HideUI()
    UIManager.Hide(eUIType.ePersonSpaceMainUI)

    EventSystem:unregistEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_REDDOT_UPDATE, PersonSpaceMainUI.RefreshRelationRedpoint);

    EventSystem:unregistEvent(EVENTTYPE_RANK, EVENTID_PERSONSPACE_PARTNER_CHANGE, PersonSpaceMainUI.OnPartnerChange)

    EventSystem:unregistEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_GET_POPULARITY_RSP, PersonSpaceMainUI.GetPopularityRsp);

    EventSystem:unregistEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_CLOSE_REDDOT_RSP, PersonSpaceMainUI.GetPopularityRsp);

    EventSystem:unregistEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_PSPACE_SEND_GIFT_RSP, PersonSpaceMainUI.PlayGiftAnim);

    LuaClassObj.HandleUIMessageNoFetch(bp_person_space_main, "UIHide");

    CoupleAvatarMgrUI.HideAvatars()

    --防止自己被强制关闭时，关闭上面的弹窗
    CountryareaUI.HideUI()
    if UIManager.GetUI(eUIType.ePersonSpaceRelationshipUI) then
        PersonSpaceRelationshipUI.HideUI()
    end

    if UIManager.GetUI(eUIType.eRoleInfoCardPopupUI) then
        RoleInfoCardPopupUI.HideUI()
    end

    local ui_manager = require("ui.manager")
    ui_manager.HideUI(ui_manager.UI_Config.roleinfo_popularity)

    local UIRoot = PersonSpaceMainUI_UIRoot()

    if UIRoot ~= nil then
        local UIBP = UIRoot.Lobby_RoleInfo_Space_UIBP
        UIBP.Tips_ani.OnAnimationFinished:Clear()
        UIBP.Button_2.OnClicked:Clear()
    end
end

function EventPersonSpaceMainUI_OpenPopularityUI()
    local popularity = require("client.slua.umg.person_space.roleinfo_popularity")
    popularity.ShowUI()

    local util = require("ui.util")
    local sound_config = require("client.slua.config.sound")

    util.PlayAudio(sound_config.click, PersonSpaceMainUI_UIRoot())

    GemReportUtils.ReportBtnClickEvent(GemReportUtils.SubEventName_PersonSpacePopularity)

end

function EventPersonSpaceMainUI_OpenRelationship()
    PersonSpaceRelationshipUI.ShowUI()

    GemReportUtils.ReportBtnClickEvent(GemReportUtils.SubEventName_PersonSpaceRelation)
end

function EventPersonSpaceMain_OpenCard()
    RoleInfoCardPopupUI.ShowUI()

    GemReportUtils.ReportBtnClickEvent(GemReportUtils.SubEventName_PersonSpaceFriendCard)
end

function EventPersonSpaceCreateUIFilterName()
    --BP_Sign = FuncUtil:StrTrim(BP_Sign);	--去除两头的空格
    _,_,BP_Sign = FuncUtil:CheckName(BP_Sign,nil, 60, true)
    PersonSpaceMainUI.UpdateSignature()
end

function PersonSpaceMainUI.UpdateSignature()
    LuaClassObj.HandleUIMessageNoFetch(bp_person_space_main, "UpdateSignature")
end

function PersonSpaceMainUI.UnFoldMenuImmediately()
    BP_PersonSpaceMain_SwitchCameraBlendTime_f = 0
    PersonSpaceMainUI.UnFoldMenu()
    BP_PersonSpaceMain_SwitchCameraBlendTime_f = 0.5 
end

function PersonSpaceMainUI.OnlyShowUI()
    log("PersonSpaceMainUI OnlyShowUI");
    PersonSpaceMainUI.IsOnlyShow = true;
    LuaClassObj.HandleUIMessageNoFetch(bp_person_space_main, "UIOnlyShow");

    PersonSpaceMainUI.UnFoldMenuImmediately()

end

function PersonSpaceMainUI.OnlyHideUI()
    log("PersonSpaceMainUI OnlyHideUI");
    PersonSpaceMainUI.IsOnlyShow = false;
    LuaClassObj.HandleUIMessageNoFetch(bp_person_space_main, "UIOnlyHide");
end

function PersonSpaceMainUI.UnFoldMenu()
    log("EventPersonSpaceMain_UnFoldMenu")
    LuaClassObj.HandleUIMessageNoFetch(bp_person_space_main, "SwitchCamera_OpenMenu");
end

function EventPersonSpaceMain_FoldMenu()
    log("EventPersonSpaceMain_FoldMenu")
    LuaClassObj.HandleUIMessageNoFetch(bp_person_space_main, "SwitchCamera_CloseMenu");

    GemReportUtils.ReportBtnClickEvent(GemReportUtils.SubEventName_PersonSpaceFoldAndUnfold)
end

function EventPersonSpaceMain_UnFoldMenu()
    PersonSpaceMainUI.UnFoldMenu()

    GemReportUtils.ReportBtnClickEvent(GemReportUtils.SubEventName_PersonSpaceFoldAndUnfold)
end

function EventPersonSpaceMain_HideInfo()
    log("EventPersonSpaceMain_HideInfo")
    if UIManager.GetUI(eUIType.ePersonSpaceMainUI) then
        CoupleAvatarMgrUI.OpenAvatarInfo(false)
    end
end

function EventPersonSpaceMain_ShowInfo()
    log("EventPersonSpaceMain_ShowInfo")
    if UIManager.GetUI(eUIType.ePersonSpaceMainUI) then
        CoupleAvatarMgrUI.OpenAvatarInfo(true)
    end
end


BP_PersonSpaceMain_Alliance_Icon = "";
BP_PersonSpaceMain_Alliance_HistoryStr = "";
BP_PersonSpaceMain_Alliance_TeamName = "";
BP_PersonSpaceMain_RankIndex = 0;
BP_PersonSpaceMain_IsSelf = false;
BP_PersonSpaceMain_IsSelfCarTeam = false;
--刷新玩家战队信息
function PersonSpaceMainUI.RefreshCarTeamUI()
    BP_PersonSpaceMain_RankIndex = 0;
    BP_PersonSpaceMain_Alliance_Icon = "";
    BP_PersonSpaceMain_Alliance_TeamName = Client.GetTableData("LocalizeRes",6514).TextValue;
    BP_PersonSpaceMain_Alliance_HistoryStr = "";
    --log_tree("PersonSpaceMainUI.RefreshCarTeamUI", AllianceRoleInfoUI.carteam);
    --赛事最好成绩
    if  AllianceRoleInfoUI.carteam and AllianceRoleInfoUI.carteam.league_history then
        if AllianceRoleInfoUI.carteam.league_history.best_rank then
            local list = {};
            for _k, _v in pairs(AllianceRoleInfoUI.carteam.league_history.best_rank) do
                table.insert(list, _v);
            end
            table.sort(list, function(a, b)
                return a.rank_no < b.rank_no
            end);
            AllianceRoleInfoUI.stage = 0;
            AllianceRoleInfoUI.rank = 0;
            AllianceRoleInfoUI.group_id = 0;
            if list[1].stage then
                AllianceRoleInfoUI.stage = list[1].stage;
            end
            if list[1].rank_no then
                AllianceRoleInfoUI.rank = list[1].rank_no;
            end
            if list[1].group_id then
                AllianceRoleInfoUI.group_id = list[1].group_id;
            end
            BP_PersonSpaceMain_Alliance_HistoryStr = AllianceRoleInfoUI.getTeamMainRankContentText();
        end
    end
    if AllianceRoleInfoUI.carteam and AllianceRoleInfoUI.carteam.name then
        BP_PersonSpaceMain_Alliance_TeamName = AllianceRoleInfoUI.carteam.name;
    end
    if AllianceRoleInfoUI.carteam and AllianceRoleInfoUI.carteam.leader then
        if not AllianceRoleInfoUI.carteam.team_flag then
            AllianceRoleInfoUI.carteam.team_flag = 1;
        else
            AllianceRoleInfoUI.carteam.team_flag = tonumber(AllianceRoleInfoUI.carteam.team_flag);
        end
        BP_PersonSpaceMain_Alliance_Icon = AllianceRoleInfoUI.getGuidonUrl(AllianceRoleInfoUI.carteam.team_flag);
    end

    --设置index
    if AllianceRoleInfoUI.stage == AllianceCompetitionSystem.FirstStep.GROUP_MATCH then
        BP_PersonSpaceMain_RankIndex = 2
    end
    if AllianceRoleInfoUI.stage == AllianceCompetitionSystem.FirstStep.ZONE_FINAL_MATCH then
        if AllianceRoleInfoUI.rank == 1 then
            BP_PersonSpaceMain_RankIndex = 0
        else
            BP_PersonSpaceMain_RankIndex = 1
        end
    end
    BP_PersonSpaceMain_IsSelf = false;
    if BP_SelfID == BP_STRUCT_PersonalBasicInfo.role_id then
        BP_PersonSpaceMain_IsSelf = true;
    end
    BP_PersonSpaceMain_IsSelfCarTeam = false;
    if tonumber(DataMgr.roleData.carteamId) == tonumber(BP_STRUCT_PersonalBasicInfo.role_carteamId) then
        BP_PersonSpaceMain_IsSelfCarTeam = true;
    end
    LuaClassObj.HandleUIMessageNoFetch(bp_person_space_main, "UpdateCarteamInfo");
end

function PersonSpaceMainUI.UpdateAvatarRsp(eventType, eventID, uid)
    log("PersonSpaceMainUI.UpdateAvatarRsp" .. tostring(uid))
    if UIManager.GetUI(eUIType.ePersonSpaceMainUI) == nil then
        return
    end
    if tonumber(uid) == tonumber(RoleInfoSystem.CurShowPlayerInfoUid) or PersonSpaceMainUI.IntimacyFriendUid == tonumber(uid) then
        local roleData = ProfileMgr.GetRoleInfoDataByUid(uid);
        if roleData == nil then
            return
        end

        if tonumber(uid) == tonumber(RoleInfoSystem.CurShowPlayerInfoUid) then
            BP_PersonSpaceMain_CanShowAvatar = roleData.bshow
        end

        log("PersonSpaceMainUI.BP_PersonSpaceMain_CanShowAvatar" .. tostring(BP_PersonSpaceMain_CanShowAvatar) .. ",roleData.bshow:" .. tostring(roleData.bshow))
        LuaClassObj.HandleUIMessageNoFetch(bp_person_space_main, "UpdateAvatarTips");

        if tonumber(RoleInfoSystem.CurShowPlayerInfoUid) ~= tonumber(DataMgr.roleData.uid) then
            if tonumber(uid) == tonumber(RoleInfoSystem.CurShowPlayerInfoUid) and not roleData.bshow then
                HallThemeUtils.ProcEnterRoleSpace(roleData)
                return
            end
        end


        log_tree("UpdateAvatarRsp", roleData)
        if tonumber(uid) == tonumber(RoleInfoSystem.CurShowPlayerInfoUid) then
            PersonSpaceMainUI.IntimacyFriendUid = 0
            if roleData.partner_info and roleData.partner_info.partner_uid then
                PersonSpaceMainUI.IntimacyFriendUid = roleData.partner_info.partner_uid
            end
        end

        local SelectUID_roleData = ProfileMgr.GetRoleInfoDataByUid(RoleInfoSystem.CurShowPlayerInfoUid);
        local SelectUID_IntimacyFriend_roleData = ProfileMgr.GetRoleInfoDataByUid(PersonSpaceMainUI.IntimacyFriendUid);

        --log_tree("PersonSpaceMainUI.UpdateAvatar roleData", {roleData = SelectUID_roleData, IntimacyFriend_roleData = SelectUID_IntimacyFriend_roleData})

        CoupleAvatarMgrUI.UpdateAvatar(SelectUID_roleData, SelectUID_IntimacyFriend_roleData)

        if tonumber(uid) == tonumber(RoleInfoSystem.CurShowPlayerInfoUid) and tonumber(uid) ~= PersonSpaceMainUI.IntimacyFriendUid and PersonSpaceMainUI.IntimacyFriendUid ~= 0 then
            RoleInfoSystem.get_avatar_show_req(PersonSpaceMainUI.IntimacyFriendUid, AvatarShowSource.FromPartner)
            PersonSpaceMainUI.get_Intimacy_Friend_profile_info_req(PersonSpaceMainUI.IntimacyFriendUid)
        end

        if tonumber(uid) == tonumber(RoleInfoSystem.CurShowPlayerInfoUid) then
            roleData.uid = uid
            HallThemeUtils.ProcEnterRoleSpace(roleData)
        end
    end
end

--请求玩家基本信息
function PersonSpaceMainUI.get_Intimacy_Friend_profile_info_req(uid)
    log("get_Intimacy_Friend_profile_info_req");
    ProfileMgr.GetProfileList({tonumber(uid)}, function(listInfo)
        local PersonalBasicInfo = {};
        local ProfileInfo = {};
        for k,v in pairs(listInfo) do
            --v.uid = k;
            table.insert(ProfileInfo, v);
        end

        if #ProfileInfo >= 1 then
            CoupleAvatarMgrUI.UpdateAvatarInfo(ProfileInfo[1])
        end
    end, false, false, 0);
end

function PersonSpaceMainUI.GetSwitchVisible(relation)
    local currVisible = PersonSpaceSystem.VisibleSwitchs[relation]

    if currVisible == nil then
        if relation == 0 then
            return false
        else
            return true
        end
    end

    return currVisible
end

function PersonSpaceMainUI.UpdatePveInfo()
    log("PersonSpaceMainUI.UpdatePveInfo")
    local UIRoot = PersonSpaceMainUI_UIRoot()

    if UIRoot == nil then
        return
    end

    local UIBP = UIRoot.Lobby_RoleInfo_Space_UIBP

    local strLevel = FuncUtil.LocalizeResFormat( "6417", RoleInfoSystem.PersonalBasicInfo.role_pve_levelnum);
    UIBP.TextBlock_pve_level:SetText(strLevel)
    UIBP.TextBlock_pve_exp:SetText(tostring(RoleInfoSystem.PersonalBasicInfo.role_pve_expnum) .. "/" ..
            tostring(RoleInfoSystem.PersonalBasicInfo.role_pve_needexpnum))

end


function PersonSpaceMainUI.UpdateRoleInfo()
    log("PersonSpaceMainUI.UpdateRoleInfo")
    LuaClassObj.HandleUIMessageNoFetch(bp_person_space_main, "UpdateRoleInfo");
    LuaClassObj.HandleUIMessageNoFetch(bp_person_space_main, "UpdatePlatformRight");

    PersonSpaceMainUI.FreshCorpsInfo()

    PersonSpaceMainUI.RefreshCarTeamUI()

    PersonSpaceMainUI.UpdatePveInfo()

    if RoleInfoCardPopupUI.IsShow then
        RoleInfoCardPopupUI.UpdateRoleInfo()
    end
end


function PersonSpaceMainUI.OnRoleInfoOpen()
    LuaClassObj.HandleUIMessageNoFetch(bp_person_space_main, "OnRoleInfoOpen");
end

function PersonSpaceMainUI.RefreshAttrInfo()
    LuaClassObj.HandleUIMessageNoFetch(bp_person_space_main, "RefreshAttrInfo");
end

function PersonSpaceMainUI.UpdateAvatar()
    LuaClassObj.HandleUIMessageNoFetch(bp_person_space_main, "UpdateAvatar")
end

function PersonSpaceMainUI.UpdateHeadportraitReddot()
    LuaClassObj.HandleUIMessageNoFetch(bp_person_space_main, "UpdateHeadportraitReddot")
end

function PersonSpaceMainUI.FreshCorpsInfo()
    LuaClassObj.HandleUIMessageNoFetch(bp_person_space_main, "FreshCorpsInfo")
end

function PersonSpaceMainUI.SetPersonalBasicInfo()
    LuaClassObj.HandleUIMessage(bp_person_space_main, "SetPersonalBasicInfo")
end

function PersonSpaceMainUI.UpdateAchievementScore()
    log("PersonSpaceMainUI.UpdateAchievementScore")
    LuaClassObj.HandleUIMessageNoFetch(bp_person_space_main, "UpdateAchievementScore")
end

function PersonSpaceMainUI.UpdateCarteamInfo()
    log("PersonSpaceMainUI.UpdateCarteamInfo")
    LuaClassObj.HandleUIMessageNoFetch(bp_person_space_main, "UpdateCarteamInfo")

end

function PersonSpaceMainUI.UpdateRoleNationInfo()
    LuaClassObj.HandleUIMessage(bp_person_space_main, "UpdateRoleNationInfo")
end

function PersonSpaceMainUI.SetSignInfo()
    LuaClassObj.HandleUIMessageNoFetch(bp_person_space_main, "SetSignInfo")
end

function PersonSpaceMainUI.UpdateCard()
    LuaClassObj.HandleUIMessage(bp_person_space_main, "UpdateCard")

    if RoleInfoCardPopupUI.IsShow then
        RoleInfoCardPopupUI.UpdateCard()
    end
end

function PersonSpaceMainUI.SetEmptyData()
    LuaClassObj.HandleUIMessageNoFetch(bp_person_space_main, "SetEmptyData")

    if RoleInfoCardPopupUI.IsShow then
        RoleInfoCardPopupUI.SetEmptyData()
    end
end