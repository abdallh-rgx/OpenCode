PersonSpaceSecrecySettingUI = PersonSpaceSecrecySettingUI or
        {
            ChangedSwitchs = {},
            TimeHandle = nil,
            UIRoot = nil,
        }

BP_STRUCT_PersonSpaceSecrecySetting_Switch = 
{
    relation = 0,
    isVisible = false,
}


BP_ARRAY_PersonSpaceSecrecySetting_Switch = 
{
    BP_STRUCT_PersonSpaceSecrecySetting_Switch = _G.BP_STRUCT_PersonSpaceSecrecySetting_Switch
}

function bp_person_space_secrecy_setting_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_person_space_secrecy_setting,
            {{Path = "/Game/UMG/UI_Logic/PersonSpace/PersonSpace_SecrecySetting_BP.PersonSpace_SecrecySetting_BP_C", Container = "Default", ZOrder = BP_ENUM_UI_ROLEINFO_ZORDER + 10}},
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

local function PersonSpaceSecrecySettingUI_UIRoot()
    return UIUtil.GetWidgetByLogicName("bp_person_space_secrecy_setting")
end

function PersonSpaceSecrecySettingUI.ShowUI()
    LuaClassObj.HandleDynamicCreation(bp_person_space_secrecy_setting);
    LuaClassObj.HandleUIMessage(bp_person_space_secrecy_setting, "UIShow");
    UIManager.Show(eUIType.ePersonSpaceSecrecySettingUI)

    EventSystem:registEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_SWITCH_UPDATE, PersonSpaceSecrecySettingUI.OnSecrecySettingUpdate);
    EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_UPDATE_NEWBIE_STATUS, PersonSpaceSecrecySettingUI.OnUpdateNewbieStatus);

    EventSystem:registEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_GET_POPULARITY_RSP, PersonSpaceSecrecySettingUI.RefreshPopularitySwitch);


    PersonSpaceSystem.get_intimacy_relation_visible_req()

    PersonSpaceSecrecySettingUI.OnSecrecySettingUpdate()
    PersonSpaceSecrecySettingUI.ChangedSwitchs = {}

    PersonSpaceSecrecySettingUI.OnUpdateNewbieStatus()

    PersonSpaceSecrecySettingUI.InitPopularitySwitch()
end

function PersonSpaceSecrecySettingUI.InitPopularitySwitch()
    local UIRoot = PersonSpaceSecrecySettingUI_UIRoot()
    if UIRoot == nil then
        return
    end

    local secrecyUI = UIRoot.Lobby_RoleInfo_Secrecy_Popup_UIBP
    secrecyUI.Button_1.OnClicked:Clear()
    secrecyUI.Button_1.OnClicked:Add(function()
        local PopularitySystem = GetRoleInfoPopularitySystem()
        PopularitySystem.show_popularity_detail_req(not PopularitySystem.IsShowDetail)

        local util = require("ui.util")
        local sound_config = require("client.slua.config.sound")

        util.PlayAudio(sound_config.click, PersonSpaceSecrecySettingUI_UIRoot())
    end)

    PersonSpaceSecrecySettingUI.RefreshPopularitySwitch()
end

function PersonSpaceSecrecySettingUI.RefreshPopularitySwitch()
    local UIRoot = PersonSpaceSecrecySettingUI_UIRoot()
    if UIRoot == nil then
        return
    end

    local secrecyUI = UIRoot.Lobby_RoleInfo_Secrecy_Popup_UIBP
    local PopularitySystem = GetRoleInfoPopularitySystem()

    secrecyUI.HorizontalBox_13:SetVisibility(UIUtil.BoolToVisible(not PopularitySystem.IsShowDetail))
    secrecyUI.HorizontalBox_14:SetVisibility(UIUtil.BoolToVisible(PopularitySystem.IsShowDetail))
end

function PersonSpaceSecrecySettingUI.HideUI()
    if not UIManager.GetUI(eUIType.ePersonSpaceSecrecySettingUI) then
        return
    end
    UIManager.Hide(eUIType.ePersonSpaceSecrecySettingUI)

    EventSystem:unregistEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_SWITCH_UPDATE, PersonSpaceSecrecySettingUI.OnSecrecySettingUpdate);
    EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_UPDATE_NEWBIE_STATUS, PersonSpaceSecrecySettingUI.OnUpdateNewbieStatus);

    EventSystem:unregistEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_GET_POPULARITY_RSP, PersonSpaceSecrecySettingUI.RefreshPopularitySwitch);


    LuaClassObj.HandleUIMessageNoFetch(bp_person_space_secrecy_setting, "UIHide");

    PersonSpaceRelationshipUI.OnUpdateNewbieStatus()

    PersonSpaceSecrecySettingUI.SendReq()

    local UIRoot = PersonSpaceSecrecySettingUI_UIRoot()
    if UIRoot ~= nil then
        local secrecyUI = UIRoot.Lobby_RoleInfo_Secrecy_Popup_UIBP
        secrecyUI.Button_1.OnClicked:Clear()
    end
end

function PersonSpaceSecrecySettingUI.OnSecrecySettingUpdate()
    BP_ARRAY_PersonSpaceSecrecySetting_Switch = {}
    local relations = {0, 1, 2, 3 ,4}
    for i, _relation in ipairs(relations) do
        local _isVisible = PersonSpaceMainUI.GetSwitchVisible(_relation)
        table.insert(BP_ARRAY_PersonSpaceSecrecySetting_Switch, {relation = _relation, isVisible = _isVisible})
    end
    PersonSpaceSecrecySettingUI.RefreshUI()
end

function PersonSpaceSecrecySettingUI.OnUpdateNewbieStatus()
    LuaClassObj.HandleUIMessageNoFetch(bp_person_space_secrecy_setting, "OnUpdateNewbieStatus");
end

function PersonSpaceSecrecySettingUI.RefreshUI()
    LuaClassObj.HandleUIMessage(bp_person_space_secrecy_setting, "RefreshUI");
end

function PersonSpaceSecrecySettingUI.HasGuide()
    local value = DataMgr.GetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_INTIMACY_RELATION, PersonSpaceGuideType.SecrecySetting)
    if value == nil or (value ~= PersonSpaceSecrecySettingProgress.Switch) then
        return true
    else
        return false
    end
end

function PersonSpaceSecrecySettingUI.SetHasGuide()
    DataMgr.SetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_INTIMACY_RELATION, PersonSpaceGuideType.SecrecySetting, PersonSpaceSecrecySettingProgress.Switch)
    PersonSpaceSecrecySettingUI.OnUpdateNewbieStatus()
end

function PersonSpaceSecrecySettingUI.SendReq()
    if not next(PersonSpaceSecrecySettingUI.ChangedSwitchs) then
        return
    end
    local sends = {}
    for i, relation in pairs(PersonSpaceSecrecySettingUI.ChangedSwitchs) do
        sends[relation] = PersonSpaceSystem.VisibleSwitchs[relation]
    end
    PersonSpaceSystem.set_intimacy_relation_visible_req(sends)
end

function EventPersonSpaceSecrecySettingUI_GuideClick()
    if PersonSpaceSecrecySettingUI.HasGuide() then
        PersonSpaceSecrecySettingUI.SetHasGuide()
    end
    PersonSpaceSecrecySettingUI.OnUpdateNewbieStatus()
end


function EventPersonSpaceSecrecySettingUI_HideUI()
    PersonSpaceSecrecySettingUI.HideUI()
end

BP_PersonSpaceSecrecySetting_Click_Relation = 0
function EventPersonSpaceSecrecySettingUI_ChangeVisible()
    local clickRelation = BP_PersonSpaceSecrecySetting_Click_Relation
    local currVisible = PersonSpaceMainUI.GetSwitchVisible(clickRelation)
    
    log_tree("ChangeVisible VisibleSwitchs", PersonSpaceSystem.VisibleSwitchs)
    PersonSpaceSystem.VisibleSwitchs[clickRelation] = not currVisible
    

    log_tree("after ChangeVisible VisibleSwitchs", PersonSpaceSystem.VisibleSwitchs)
    
    log("PersonSpaceSecrecySettingUI.ChangeVisible relation:" .. tostring(clickRelation) .. ",currVisible:" .. tostring(currVisible))

    BP_ARRAY_PersonSpaceSecrecySetting_Switch[clickRelation + 1].isVisible = not currVisible

    log_tree("BP_ARRAY_PersonSpaceSecrecySetting_Switch", BP_ARRAY_PersonSpaceSecrecySetting_Switch)
    PersonSpaceSecrecySettingUI.RefreshUI()

    if FuncUtil.Find(PersonSpaceSecrecySettingUI.ChangedSwitchs, clickRelation) == -1 then
        table.insert(PersonSpaceSecrecySettingUI.ChangedSwitchs, clickRelation)
    end

    if PersonSpaceSecrecySettingUI.TimeHandle then
        Timer.RemoveTimer(PersonSpaceSecrecySettingUI.TimeHandle)
    end

    PersonSpaceSecrecySettingUI.TimeHandle = Timer.InsertTimer(3, function()
        PersonSpaceSecrecySettingUI.SendReq()
    end, false)
end



