PersonSpaceRelationshipUI = PersonSpaceRelationshipUI or
        {
        }


BP_STRUCT_PersonSpace_IntimacyFriend =
{
    gid="",
    nickName="",
    level=0,
    picUrl="",
    vipLevel=0,
    sex=0,
    signature="",--个性签名
    intimacy=0,--亲密度
    segment_info_max=0,-- 最大段位数据
    cur_avatar_box_id=0,
    relation=0,--关系类型  --(1: 基友 2: 恋人; 3: 死党; 4: 闺蜜;)

    -- 绝地通行证
    upass_is_buy = 0; --是否购买(1为已购买，0为未购买)
    upass_is_show = 0; --是否显示(1为显示，0为不显示)

    aliasId = 0;
    aliasTitle = "";
    aliasNation = "";
    roleNation = "";

    isPartner = false,--是否是拍档
    isApplyed = false,--是否已经申请
}

--亲密度数据
BP_ARRAY_PersonSpace_IntimacyFriend =
{
    BP_STRUCT_PersonSpace_IntimacyFriend = _G.BP_STRUCT_PersonSpace_IntimacyFriend,
}

--亲密开关设置；
BP_ARRAY_PersonSpaceRelationshipSetting_Switch =
{
    tmp_UseExist_BP_STRUCT_PersonSpaceSecrecySetting_Switch = {}
}

--开关状态
BP_STRUCT_PersonSpaceRelationship_SwitchStatus = 
{
    --是否所有的子开关都是关闭了
    IsAllChildSwitch_Closed = true,
    --是否有子开关是关闭的
    HasChildSwitch_Closed = true,
    --是否所有的开关都是关闭的
    IsAllSwitch_Closed = true,
}

--个人空间关系状态
BP_STRUCT_PersonSpace_RelationStatus = 
{
    curCount = 0,
    maxCount = 1,
    HasLocked = true,
    relation = 0,
    BP_ARRAY_PersonSpace_IntimacyFriend = _G.BP_ARRAY_PersonSpace_IntimacyFriend,
    Test = 0,
}

--个人空间关系状态
BP_ARRAY_PersonSpace_RelationStatus =
{
    BP_STRUCT_PersonSpace_RelationStatus = _G.BP_STRUCT_PersonSpace_RelationStatus
}

BP_PartnerSettingRedpointShow = false

BP_PartnerSettingButtonShow = false

function bp_person_space_relationship_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_person_space_relationship,
            {{Path = "/Game/UMG/UI_Logic/PersonSpace/PersonSpace_Relationship_BP.PersonSpace_Relationship_BP_C", Container = "Default", ZOrder = BP_ENUM_UI_ROLEINFO_ZORDER + 10}},
            {"Lobby"},
            false,
            false,
            true
    );
end


function PersonSpaceRelationshipUI.ShowUI()

    BP_PartnerSettingButtonShow = LobbyUI:CheckLobbyMenuOpen(BP_ENUM_PERSONSPACE_PARTNERSETTING, false)
    
    LuaClassObj.HandleDynamicCreation(bp_person_space_relationship);
    LuaClassObj.HandleUIMessage(bp_person_space_relationship, "UIShow");
    UIManager.Show(eUIType.ePersonSpaceRelationshipUI)

    PersonSpaceRelationshipUI.InitData()
    
    EventSystem:registEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_INTIMACY_DATA_UPDATE, PersonSpaceRelationshipUI.OnIntimacyDataUpdate);
    EventSystem:registEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_SWITCH_UPDATE, PersonSpaceRelationshipUI.OnSecrecySettingUpdate);
    EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_UPDATE_NEWBIE_STATUS, PersonSpaceRelationshipUI.OnUpdateNewbieStatus);

    EventSystem:registEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_REDDOT_UPDATE, PersonSpaceRelationshipUI.RefreshSettingRedpoint);
    
    if DataMgr.roleData.uid == RoleInfoSystem.CurShowPlayerInfoUid then
        PersonSpaceSystem.get_intimacy_relation_visible_req()
        PersonSpaceSystem.get_intimacy_relation_req()
    else
        PersonSpaceSystem.get_other_intimacy_relation_req(RoleInfoSystem.CurShowPlayerInfoUid)
    end

    PersonSpaceRelationshipUI.OnUpdateNewbieStatus()
    PersonSpaceRelationshipUI.RefreshSettingRedpoint()
end

function PersonSpaceRelationshipUI.InitData()
    local SwitchStatus = BP_STRUCT_PersonSpaceRelationship_SwitchStatus 
    SwitchStatus.IsAllChildSwitch_Closed = true
    SwitchStatus.IsAllSwitch_Closed = true
    SwitchStatus.HasChildSwitch_Closed = false
    
    BP_ARRAY_PersonSpace_RelationStatus = {}
    for i = 1,4,1 do
        local RelationStatus = {}
        RelationStatus.relation = i
        RelationStatus.curCount = 0
        if RelationStatus.relation == 2 then
            RelationStatus.maxCount = BP_Friend_Intimacy_Lover_MaxCount--恋人只有一个
        else
            RelationStatus.maxCount = BP_Friend_Intimacy_Other_MaxCount--其余关系数量
        end
        RelationStatus.HasLocked = true
        RelationStatus.BP_ARRAY_PersonSpace_IntimacyFriend = {}
        table.insert(BP_ARRAY_PersonSpace_RelationStatus,RelationStatus)
    end
end

function PersonSpaceRelationshipUI.RefreshSettingRedpoint()
    BP_PartnerSettingRedpointShow = DataMgr.roleData.uid == RoleInfoSystem.CurShowPlayerInfoUid and PersonSpaceSystem.HasIntimacyReddotAll()
    log("PersonSpaceRelationshipUI.RefreshSettingRedpoint:" .. tostring(BP_PartnerSettingRedpointShow))
    LuaClassObj.HandleUIMessageNoFetch(bp_person_space_relationship, "RefreshPartnerSettingRedpoint");
end

function PersonSpaceRelationshipUI.HasPartnerSettingGuide()
    --查看别人界面时，不能引导的
    if DataMgr.roleData.uid ~= RoleInfoSystem.CurShowPlayerInfoUid then
        return false
    end

    if not BP_PartnerSettingButtonShow then
        return false
    end
    
    local maxIntimacy = 0
    for i, IntimacyFriend in ipairs(PersonSpaceSystem.FriendIntimacyDatas) do
        maxIntimacy = math.max(IntimacyFriend.intimacy or 0, maxIntimacy) 
    end

    if maxIntimacy < PersonSpaceSystem.PartnerIntimacyLimit then
        return false
    end

    if UIManager.GetUI(eUIType.ePersonSpacePartnerSettingUI) then
        return false
    end

    if UIManager.GetUI(eUIType.ePersonSpaceSecrecySettingUI) then
        return false
    end
    
    local value = DataMgr.GetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_INTIMACY_RELATION, PersonSpaceGuideType.PartnerSetting)
    if value == nil or (value ~= PersonSpacePartnerSettingProgress.Apply and value ~= PersonSpacePartnerSettingProgress.Setting) then
        return true
    else
        return false
    end 
end

function PersonSpaceRelationshipUI.HasSecrecySettingGuide()
    --查看别人界面时，不能引导的
    if DataMgr.roleData.uid ~= RoleInfoSystem.CurShowPlayerInfoUid then
        return false
    end
    
    if UIManager.GetUI(eUIType.ePersonSpacePartnerSettingUI) then
        return false
    end

    if UIManager.GetUI(eUIType.ePersonSpaceSecrecySettingUI) then
        return false
    end
    
    if PersonSpaceRelationshipUI.HasPartnerSettingGuide() then
        return false
    end
    
    local value = DataMgr.GetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_INTIMACY_RELATION, PersonSpaceGuideType.SecrecySetting)
    if value == nil or (value ~= PersonSpaceSecrecySettingProgress.Setting and value ~= PersonSpaceSecrecySettingProgress.Switch) then
        return true
    else
        return false
    end
end

function PersonSpaceRelationshipUI.SetHasPartnerSettingGuide()
    log("PersonSpaceRelationshipUI.SetHasPartnerSettingGuide")
    DataMgr.SetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_INTIMACY_RELATION, PersonSpaceGuideType.PartnerSetting, PersonSpacePartnerSettingProgress.Setting)
    PersonSpaceRelationshipUI.OnUpdateNewbieStatus()
end

function PersonSpaceRelationshipUI.SetHasSecrecySettingGuide()
    log("PersonSpaceRelationshipUI.SetHasSecrecySettingGuide")
    DataMgr.SetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_INTIMACY_RELATION, PersonSpaceGuideType.SecrecySetting, PersonSpaceSecrecySettingProgress.Setting)
    PersonSpaceRelationshipUI.OnUpdateNewbieStatus()
end


function PersonSpaceRelationshipUI.OnUpdateNewbieStatus()
    LuaClassObj.HandleUIMessageNoFetch(bp_person_space_relationship, "OnUpdateNewbieStatus"); 
end

function PersonSpaceRelationshipUI.OnIntimacyDataUpdate()
    --重置玩家数据
    for i = 1,4,1 do
        local RelationStatus = BP_ARRAY_PersonSpace_RelationStatus[i]
        if RelationStatus then
            RelationStatus.BP_ARRAY_PersonSpace_IntimacyFriend = {}
            RelationStatus.curCount = 0
        end
    end
    
    for i, IntimacyFriend in ipairs(PersonSpaceSystem.FriendIntimacyDatas) do
        local RelationStatus = BP_ARRAY_PersonSpace_RelationStatus[IntimacyFriend.relation]
        if RelationStatus then
            RelationStatus.curCount = RelationStatus.curCount + 1
            table.insert(RelationStatus.BP_ARRAY_PersonSpace_IntimacyFriend, IntimacyFriend)
        end
    end

    log_tree("BP_ARRAY_PersonSpace_RelationStatus", BP_ARRAY_PersonSpace_RelationStatus)
    PersonSpaceRelationshipUI.RefreshUI()

    PersonSpaceRelationshipUI.OnUpdateNewbieStatus()
end

function PersonSpaceRelationshipUI.OnSecrecySettingUpdate()
    BP_ARRAY_PersonSpaceRelationshipSetting_Switch = {}
    local relations = {0, 1, 2, 3 ,4}
    
    local SwitchStatus = BP_STRUCT_PersonSpaceRelationship_SwitchStatus
    SwitchStatus.IsAllChildSwitch_Closed = true
    SwitchStatus.IsAllSwitch_Closed = true
    SwitchStatus.HasChildSwitch_Closed = false


    SwitchStatus.IsAllChildSwitch_Closed = true
    local _isAllVisible = PersonSpaceMainUI.GetSwitchVisible(0)
    for i, _relation in ipairs(relations) do
        local _isVisible = PersonSpaceMainUI.GetSwitchVisible(_relation)

        if _relation ~= 0 then
            SwitchStatus.IsAllChildSwitch_Closed = SwitchStatus.IsAllChildSwitch_Closed and not _isVisible
            SwitchStatus.HasChildSwitch_Closed = SwitchStatus.HasChildSwitch_Closed or not _isVisible

            local RelationStatus = BP_ARRAY_PersonSpace_RelationStatus[_relation]
            if RelationStatus then
                RelationStatus.HasLocked = not _isAllVisible or not _isVisible
            end
        end
        
        table.insert(BP_ARRAY_PersonSpaceRelationshipSetting_Switch, {relation = _relation, isVisible = _isVisible})
    end

    SwitchStatus.IsAllSwitch_Closed = SwitchStatus.IsAllChildSwitch_Closed or not PersonSpaceMainUI.GetSwitchVisible(0)

    log_tree("SwitchStatus", SwitchStatus)
    log_tree("BP_ARRAY_PersonSpace_RelationStatus", BP_ARRAY_PersonSpace_RelationStatus)
    PersonSpaceRelationshipUI.RefreshUI()
end

function PersonSpaceRelationshipUI.HideUI()
    if not UIManager.GetUI(eUIType.ePersonSpaceRelationshipUI) then
        return
    end
    
    EventSystem:unregistEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_INTIMACY_DATA_UPDATE, PersonSpaceRelationshipUI.OnIntimacyDataUpdate);
    EventSystem:unregistEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_SWITCH_UPDATE, PersonSpaceRelationshipUI.OnSecrecySettingUpdate);
    EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_UPDATE_NEWBIE_STATUS, PersonSpaceRelationshipUI.OnUpdateNewbieStatus);

    EventSystem:unregistEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_REDDOT_UPDATE, PersonSpaceRelationshipUI.RefreshSettingRedpoint);

    
    UIManager.Hide(eUIType.ePersonSpaceRelationshipUI)
    LuaClassObj.HandleUIMessageNoFetch(bp_person_space_relationship, "UIHide");

    --防止自己被强制关闭时，关闭上面的弹窗
    PersonSpaceSecrecySettingUI.HideUI()
    PersonSpacePartnerSettingUI.HideUI()
    
end

function PersonSpaceRelationshipUI.RefreshUI()
    LuaClassObj.HandleUIMessage(bp_person_space_relationship, "RefreshUI");
end

function EventPersonSpaceRelationshipUI_HideUI()
    PersonSpaceRelationshipUI.HideUI()
end

function EventPersonSpaceRelationshipUI_OpenSecrecySetting()
    PersonSpaceSecrecySettingUI.ShowUI()
end

function EventPersonSpaceRelationshipUI_OpenSecrecySetting_Guide()
    if PersonSpaceRelationshipUI.HasSecrecySettingGuide() then
        PersonSpaceRelationshipUI.SetHasSecrecySettingGuide()
    end
    PersonSpaceSecrecySettingUI.ShowUI()

    PersonSpaceRelationshipUI.OnUpdateNewbieStatus()
end

function EventPersonSpaceRelationshipUI_OpenPartnerSetting()
    PersonSpacePartnerSettingUI.ShowUI()
end

function EventPersonSpaceRelationshipUI_OpenPartnerSetting_Guide()
    if PersonSpaceRelationshipUI.HasPartnerSettingGuide() then
        PersonSpaceRelationshipUI.SetHasPartnerSettingGuide()
    end
    PersonSpacePartnerSettingUI.ShowUI()

    PersonSpaceRelationshipUI.OnUpdateNewbieStatus()
end

function EventPersonSpaceRelationshipUI_OpenTips()
    local title = FuncUtil.GetLocalizeResStr(6596);
    local context = FuncUtil.GetLocalizeResStr(6597);
    PopUpNoticeUI.ShowMessageBox(title, context)
end



BP_PERSONSPACERELATIONSHIP_CLICK_UID = ""
BP_PERSONSPACERELATIONSHIP_CLICK_Status = 0

PersonSpaceRelationshipItemStatus =
{
    Has  = 0, --有了
    Empty  = 1, --空
}

function EventPersonSpaceRelationship_ClickItem()
    log("EventPersonSpaceRelationship_ClickItem:"..tostring(BP_PERSONSPACERELATIONSHIP_CLICK_UID) .. ",Status:" .. BP_PERSONSPACERELATIONSHIP_CLICK_Status)
    
    if BP_PERSONSPACERELATIONSHIP_CLICK_Status == PersonSpaceRelationshipItemStatus.Has then
        local levelUID = RoleInfoSystem.CurShowPlayerInfoUid
        
        PersonSpaceRelationshipUI.HideUI()

        RoleInfoUI.HideUI(false)
        
        RoleInfoSystem.Enter(BP_PERSONSPACERELATIONSHIP_CLICK_UID)
        RoleInfoUI.Init(true, RoleInfoOpenFromType.PersonSpace, {uid = levelUID, IsShowRelation = true})
    end
end

function EventPersonSpaceRelationship_ClickAdd()
    local levelUID = RoleInfoSystem.CurShowPlayerInfoUid
    
    PersonSpaceRelationshipUI.HideUI()
    RoleInfoUI.HideUI(true, true)
    if LobbyUI:CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_FRIEND) then
        LobbyFriendUI:ShowRelationshipPanel(LobbyFriendUIOpenFrom.PersonSpaceRelationShip, {uid = levelUID})
    end
end



