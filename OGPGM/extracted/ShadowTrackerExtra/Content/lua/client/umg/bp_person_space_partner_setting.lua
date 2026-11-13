PersonSpacePartnerSettingUI = PersonSpacePartnerSettingUI or
        {
        }

PersonSpacePartnerSetting_PageIndex = 
{
    Apply = 0,
    Invite = 1,
}
BP_PersonSpacePartnerSetting_PageIndex = 0

--申请
BP_ARRAY_PersonSpacePartner_ApplyData =
{
    tmp_UseExist_BP_STRUCT_PersonSpace_IntimacyFriend = {}
}
--邀请
BP_ARRAY_PersonSpacePartner_InviteData =
{
    tmp_UseExist_BP_STRUCT_PersonSpace_IntimacyFriend = {}
}

BP_InviteTapRedpointShow = false

function bp_person_space_partner_setting_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_person_space_partner_setting,
            {{Path = "/Game/UMG/UI_Logic/PersonSpace/PersonSpace_PartnerSetting_BP.PersonSpace_PartnerSetting_BP_C", Container = "Default", ZOrder = BP_ENUM_UI_ROLEINFO_ZORDER + 10}},
            {"Lobby"},
            false,
            false,
            true
    );
end


function PersonSpacePartnerSettingUI.ShowUI(PageIndex)
    LuaClassObj.HandleDynamicCreation(bp_person_space_partner_setting);
    LuaClassObj.HandleUIMessage(bp_person_space_partner_setting, "UIShow");
    UIManager.Show(eUIType.ePersonSpacePartnerSettingUI)

    BP_PersonSpacePartnerSetting_PageIndex = PageIndex or PersonSpacePartnerSetting_PageIndex.Apply

    EventSystem:registEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_INTIMACY_DATA_UPDATE, PersonSpacePartnerSettingUI.OnIntimacyDataUpdate);
    EventSystem:registEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_PARTNER_SETTING_UPDATE, PersonSpacePartnerSettingUI.OnIntimacyDataUpdate);
    EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_UPDATE_NEWBIE_STATUS, PersonSpacePartnerSettingUI.OnUpdateNewbieStatus);
    EventSystem:registEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_REDDOT_UPDATE, PersonSpacePartnerSettingUI.RefreshInviteRedpoint);

    PersonSpacePartnerSettingUI.OnIntimacyDataUpdate()

    if BP_PersonSpacePartnerSetting_PageIndex == PersonSpacePartnerSetting_PageIndex.Apply then
        EventPersonSpacePartner_ShowApply()
    else
        EventPersonSpacePartner_ShowInvite()
    end

    PersonSpaceSystem.get_intimacy_relation_req()

    PersonSpacePartnerSettingUI.OnUpdateNewbieStatus()

    PersonSpacePartnerSettingUI.RefreshInviteRedpoint()
end

function PersonSpacePartnerSettingUI.RefreshInviteRedpoint()
    BP_InviteTapRedpointShow = PersonSpaceSystem.HasRelationshipInviteRedpoint()

    BP_ApplyTapRedpointShow = PersonSpaceSystem.HasIntimacyReddot(PersonSpaceReddotType.REDOT_NEW_INTIMACY_PARTNER_APPLY)
    log("PersonSpacePartnerSettingUI.RefreshInviteRedpoint:" .. tostring(BP_InviteTapRedpointShow))
    LuaClassObj.HandleUIMessage(bp_person_space_partner_setting, "RefreshInviteRedpoint");
end

function PersonSpacePartnerSettingUI.OnIntimacyDataUpdate()
    BP_ARRAY_PersonSpacePartner_ApplyData = {}
    BP_ARRAY_PersonSpacePartner_InviteData = {}

    local sent_request_list = PersonSpaceSystem.IntimacyPartnerData.sent_request_list
    local wait_confirm_list = PersonSpaceSystem.IntimacyPartnerData.wait_confirm_list

    if sent_request_list then
        for i, data in pairs(PersonSpaceSystem.FriendIntimacyDatas) do
            if data.intimacy >= PersonSpaceSystem.PartnerIntimacyLimit then
                table.insert(BP_ARRAY_PersonSpacePartner_ApplyData, data)
            end
        end
        table.sort(BP_ARRAY_PersonSpacePartner_ApplyData, function (a, b)
            local aScore = 0
            local bScore = 0
            if tonumber(a.gid) == PersonSpaceSystem.IntimacyPartnerData.partner_uid then
                aScore = aScore + 1000
            end

            if tonumber(b.gid) == PersonSpaceSystem.IntimacyPartnerData.partner_uid then
                bScore = bScore + 1000
            end

            if sent_request_list[tonumber(a.gid)] then
                aScore = aScore + 100--是否申请了
            end

            if sent_request_list[tonumber(b.gid)] then
                bScore = bScore + 100--是否申请了
            end

            if a.intimacy > b.intimacy then
                aScore = aScore + 10
            end

            if b.intimacy > a.intimacy then
                bScore = bScore + 10
            end
                
            return aScore > bScore
        end)
        for k,data in ipairs(BP_ARRAY_PersonSpacePartner_ApplyData) do
            data.isPartner = (tonumber(data.gid) == tonumber(PersonSpaceSystem.IntimacyPartnerData.partner_uid))--是否是拍档
            if sent_request_list[tonumber(data.gid)] then --是否申请了
                data.isApplyed = true
            else
                data.isApplyed = false
            end
        end
    end

    if wait_confirm_list then
        for uid, v in pairs(wait_confirm_list) do
            local data = PersonSpaceSystem.GetFriendIntimacyDataByUID(uid)
            if data then
                table.insert(BP_ARRAY_PersonSpacePartner_InviteData, data)
            end
        end

        table.sort(BP_ARRAY_PersonSpacePartner_InviteData, function (a, b)
            return a.intimacy > b.intimacy
        end)
    end
    
    log_tree("BP_ARRAY_PersonSpacePartner_ApplyData", BP_ARRAY_PersonSpacePartner_ApplyData)
    log_tree("BP_ARRAY_PersonSpacePartner_InviteData", BP_ARRAY_PersonSpacePartner_InviteData)
    PersonSpacePartnerSettingUI.RefreshUI()
end

function PersonSpacePartnerSettingUI.HideUI()
    if not UIManager.GetUI(eUIType.ePersonSpacePartnerSettingUI) then
        return
    end
    
    EventSystem:unregistEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_INTIMACY_DATA_UPDATE, PersonSpacePartnerSettingUI.OnIntimacyDataUpdate);
    EventSystem:unregistEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_PARTNER_SETTING_UPDATE, PersonSpacePartnerSettingUI.OnIntimacyDataUpdate);
    EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_UPDATE_NEWBIE_STATUS, PersonSpacePartnerSettingUI.OnUpdateNewbieStatus);
    EventSystem:unregistEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_REDDOT_UPDATE, PersonSpacePartnerSettingUI.RefreshInviteRedpoint);

    UIManager.Hide(eUIType.ePersonSpacePartnerSettingUI)
    LuaClassObj.HandleUIMessageNoFetch(bp_person_space_partner_setting, "UIHide");

    PersonSpaceRelationshipUI.OnUpdateNewbieStatus()

    CommonMessageBoxUI.HideAllMessageBox() --防止自己被强制关闭时，关闭上面的弹窗
end

function PersonSpacePartnerSettingUI.OnUpdateNewbieStatus()
    LuaClassObj.HandleUIMessage(bp_person_space_partner_setting, "OnUpdateNewbieStatus");
end

function PersonSpacePartnerSettingUI.RefreshUI()
    LuaClassObj.HandleUIMessage(bp_person_space_partner_setting, "RefreshUI");
end


function PersonSpacePartnerSettingUI.HasGuide()
    local maxIntimacy = 0
    for i, IntimacyFriend in ipairs(PersonSpaceSystem.FriendIntimacyDatas) do
        maxIntimacy = math.max(IntimacyFriend.intimacy or 0, maxIntimacy)
    end

    if maxIntimacy < PersonSpaceSystem.PartnerIntimacyLimit then
        return false
    end
    
    local value = DataMgr.GetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_INTIMACY_RELATION, PersonSpaceGuideType.PartnerSetting)
    log("PersonSpacePartnerSettingUI.HasGuide:" .. tostring(value))
    if value == nil or (value ~= PersonSpacePartnerSettingProgress.Apply) then
        return true
    else
        return false
    end
end

function PersonSpacePartnerSettingUI.SetHasGuide()
    DataMgr.SetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_INTIMACY_RELATION, PersonSpaceGuideType.PartnerSetting, PersonSpacePartnerSettingProgress.Apply)
    PersonSpacePartnerSettingUI.OnUpdateNewbieStatus()
end

function EventPersonSpacePartnerSettingUI_GuideClick()
    if PersonSpacePartnerSettingUI.HasGuide() then
        PersonSpacePartnerSettingUI.SetHasGuide()
    end
    PersonSpacePartnerSettingUI.OnUpdateNewbieStatus()
end

function EventPersonSpacePartnerSettingUI_HideUI()
    PersonSpacePartnerSettingUI.HideUI()
end


function EventPersonSpacePartner_ShowApply()
    BP_PersonSpacePartnerSetting_PageIndex = PersonSpacePartnerSetting_PageIndex.Apply
    LuaClassObj.HandleUIMessageNoFetch(bp_person_space_partner_setting, "ChangePage");

    if PersonSpaceSystem.HasIntimacyReddot(PersonSpaceReddotType.REDOT_NEW_INTIMACY_PARTNER_AVAILABLE) then
        PersonSpaceSystem.remove_intimacy_reddot(PersonSpaceReddotType.REDOT_NEW_INTIMACY_PARTNER_AVAILABLE)
    end
end

function EventPersonSpacePartner_ShowInvite()
    BP_PersonSpacePartnerSetting_PageIndex = PersonSpacePartnerSetting_PageIndex.Invite
    LuaClassObj.HandleUIMessageNoFetch(bp_person_space_partner_setting, "ChangePage");

    if PersonSpaceSystem.HasIntimacyReddot(PersonSpaceReddotType.REDOT_NEW_INTIMACY_PARTNER_APPLY) then
        PersonSpaceSystem.remove_intimacy_reddot(PersonSpaceReddotType.REDOT_NEW_INTIMACY_PARTNER_APPLY)
    end
end

BP_PERSONSPACEPARTNER_CLICK_UID = ""
function EventPersonSpacePartner_ClickAvatar()
    local levelUID = RoleInfoSystem.CurShowPlayerInfoUid
    log("EventPersonSpacePartner_ClickAvatar:"..tostring(BP_PERSONSPACEPARTNER_CLICK_UID))
    PersonSpaceRelationshipUI.HideUI()
    PersonSpacePartnerSettingUI.HideUI()
    RoleInfoUI.HideUI(false)

    RoleInfoSystem.Enter(BP_PERSONSPACEPARTNER_CLICK_UID)
    RoleInfoUI.Init(true, RoleInfoOpenFromType.PersonSpace, {uid = levelUID, IsShowRelation = true, SettingPageIndex = BP_PersonSpacePartnerSetting_PageIndex})
end

--申请拍档
function EventPersonSpacePartner_ApplyClick()
    log("EventPersonSpacePartner_ApplyClick:"..tostring(BP_PERSONSPACEPARTNER_CLICK_UID) .. ",partner_uid:" .. PersonSpaceSystem.IntimacyPartnerData.partner_uid)
    if tonumber(PersonSpaceSystem.IntimacyPartnerData.partner_uid) ~= 0 then
        local tip = FuncUtil.GetLocalizeResStr("6608"); -- 你只能同时拥有一位搭对好友，请先移除已建立的搭对关系
        local promptTip = FuncUtil.GetLocalizeResStr("101001");
        CommonMessageBoxUI:ShowPanel(1, promptTip, tip,  function() end)
        return
    end
    
    --log_tree("CancelApplyList", PersonSpaceSystem.CancelApplyList)
    if PersonSpaceSystem.CancelApplyList[tonumber(BP_PERSONSPACEPARTNER_CLICK_UID)] then
        local remainTime = FuncUtil.GetServerTimeInSec() - PersonSpaceSystem.CancelApplyList[tonumber(BP_PERSONSPACEPARTNER_CLICK_UID)]

        log("remainTime:" .. remainTime)
        if remainTime < PersonSpaceSystem.AgainApplyTimeInterval then

            local tips = GlobalData.GetLocalizeStringWithNum(6612, 0, math.ceil(PersonSpaceSystem.AgainApplyTimeInterval - remainTime));

            --local tips = FuncUtil.LocalizeResFormat("6612", math.ceil(PersonSpaceSystem.AgainApplyTimeInterval - remainTime))
            ShowNotice(tips)
            return
        end
    end
    
    if tonumber(BP_PERSONSPACEPARTNER_CLICK_UID) ~= tonumber(PersonSpaceSystem.IntimacyPartnerData.partner_uid) then
        PersonSpaceSystem.make_intimacy_partner_req(tonumber(BP_PERSONSPACEPARTNER_CLICK_UID)) 
    end
end

--解散拍档
function EventPersonSpacePartner_BreakClick()
    log("EventPersonSpacePartner_BreakClick:"..tostring(BP_PERSONSPACEPARTNER_CLICK_UID) .. ",partner_uid:" .. PersonSpaceSystem.IntimacyPartnerData.partner_uid)
    if tonumber(BP_PERSONSPACEPARTNER_CLICK_UID) == tonumber(PersonSpaceSystem.IntimacyPartnerData.partner_uid) then

        local data = PersonSpaceSystem.GetFriendIntimacyDataByUID(BP_PERSONSPACEPARTNER_CLICK_UID)
        
        --log_tree("data", data)
        local nickname = data and data.nickName or ""
        local tip = FuncUtil.LocalizeResFormat("6607", nickname); -- 你只能同时拥有一位搭对好友，请先移除已建立的搭对关系
        local promptTip = FuncUtil.GetLocalizeResStr("101001");
        CommonMessageBoxUI:ShowPanel(2, promptTip, tip,  function()
            PersonSpaceSystem.release_intimacy_partner_req(tonumber(BP_PERSONSPACEPARTNER_CLICK_UID))
        end)
    end
end

--撤销申请
function EventPersonSpacePartner_CancleClick()
    log("EventPersonSpacePartner_CancleClick:"..tostring(BP_PERSONSPACEPARTNER_CLICK_UID) .. ",partner_uid:" .. PersonSpaceSystem.IntimacyPartnerData.partner_uid)
    --if tonumber(BP_PERSONSPACEPARTNER_CLICK_UID) ~= tonumber(PersonSpaceSystem.IntimacyPartnerData.partner_uid) then
        PersonSpaceSystem.cancle_make_intimacy_partner_req(tonumber(BP_PERSONSPACEPARTNER_CLICK_UID))
    --end
end

--同意邀请
function EventPersonSpacePartner_AgreeClick()
    log("EventPersonSpacePartner_AgreeClick:"..tostring(BP_PERSONSPACEPARTNER_CLICK_UID) .. ",partner_uid:" .. PersonSpaceSystem.IntimacyPartnerData.partner_uid)
    if tonumber(PersonSpaceSystem.IntimacyPartnerData.partner_uid) ~= 0 then
        local tip = FuncUtil.GetLocalizeResStr("6608"); -- 你只能同时拥有一位搭对好友，请先移除已建立的搭对关系
        local promptTip = FuncUtil.GetLocalizeResStr("101001");
        CommonMessageBoxUI:ShowPanel(1, promptTip, tip,  function() end)
        return
    end
    
    if tonumber(BP_PERSONSPACEPARTNER_CLICK_UID) ~= tonumber(PersonSpaceSystem.IntimacyPartnerData.partner_uid) then
        PersonSpaceSystem.agree_make_intimacy_partner_req(tonumber(BP_PERSONSPACEPARTNER_CLICK_UID))
    end
end
--忽略邀请
function EventPersonSpacePartner_RefuseClick()
    log("EventPersonSpacePartner_RefuseClick:"..tostring(BP_PERSONSPACEPARTNER_CLICK_UID) .. ",partner_uid:" .. PersonSpaceSystem.IntimacyPartnerData.partner_uid)
    --if tonumber(BP_PERSONSPACEPARTNER_CLICK_UID) ~= tonumber(PersonSpaceSystem.IntimacyPartnerData.partner_uid) then
        PersonSpaceSystem.refuse_make_intimacy_partner_req(tonumber(BP_PERSONSPACEPARTNER_CLICK_UID))
   -- end
end


