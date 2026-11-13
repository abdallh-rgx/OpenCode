CorpsApplyListUI = CorpsApplyListUI or
{
    isOnlyShow = true,
};

BP_Corps_ApplyList_ShowType = 1;

BP_STRUCT_BASE_INFO = {
    strUid = "",
    Name = "",
    Level = 1,
    Sex = 1,
    RankIntegralLevel = 1,
    IconUrl = "",
    IconFrameID  = 1,
    lastOnlineTimeStr = "",

    -- 绝地通行证
    upass_is_buy = 0, --是否购买(1为已购买，0为未购买)
    upass_is_show = 0, --是否显示(1为显示，0为不显示)
    --国籍
    nation = "",
}

BP_STRUCT_CorpsApplyList_ItemData =
{
    BP_STRUCT_BASE_INFO = _G.BP_STRUCT_BASE_INFO,
    RecommendFriendName = "",
};

-- 申请列表
BP_ARRAY_Corps_ApplyList = {BP_STRUCT_CorpsApplyList_ItemData = _G.BP_STRUCT_CorpsApplyList_ItemData};
BP_Corps_ApplyList_OptionID = "";

-- 头像
BP_CorpsApplyList_PlayerDetailUID = "";

function CorpsApplyListUI.OnUpdateApplyListUI(eventType, eventID, applyList)
    CorpsApplyListUILogic.OnUpdateApplyListUI(applyList);
end

function bp_corps_apply_list_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_corps_apply_list,
        {{Path = "/Game/UMG/UI_Logic/Corps/CorpsApplyList_BP.CorpsApplyList_BP_C", Container = "Default", ZOrder = BP_ENUM_UI_CORPS_INFO_ZORDER + 2}},
        {"Lobby"},
        false,
        false,
        true);

    EventSystem:registEvent(EVENTTYPE_CORPS, EVENTID_CORPS_GET_APPLY_LIST, CorpsApplyListUI.OnUpdateApplyListUI);
end

function EventCorpsApplyListClose()
    CorpsApplyListUILogic.HideUI();
end

-- 接受成员申请
function EventCorpsOnClickAgreeMemberJoin()
    CorpsApplyListUILogic.OnClickAgree(BP_Corps_ApplyList_OptionID);
end

-- 拒绝成员申请
function EventCorpsOnClickRefuseMemberJoin()
    CorpsApplyListUILogic.OnClickRefuse(BP_Corps_ApplyList_OptionID);
end

-- 点击头像
function EventCorpsOnClickPlayerDetail()
    RoleInfoSystem.Enter(BP_CorpsApplyList_PlayerDetailUID);
    RoleInfoUI.Init(false, RoleInfoOpenFromType.CorpsApplyList);
end

function CorpsApplyListUI.ChangeIsOnlyShow(isOnlyShow)
    log("CorpsBaseUI.ChangeIsOnlyShow:" .. tostring(isOnlyShow))
    CorpsApplyListUI.isOnlyShow = isOnlyShow
    if CorpsApplyListUI.isOnlyShow then
        LuaClassObj.HandleUIMessageNoFetch(bp_corps_apply_list, "UIOnlyShow");
    else
        LuaClassObj.HandleUIMessageNoFetch(bp_corps_apply_list, "UIOnlyHide");
    end
end

function CorpsApplyListUI.GetStatus()
    log("CorpsBaseUI.GetStatus:" .. tostring(CorpsApplyListUI.isOnlyShow))
    return {isOnlyShow = CorpsApplyListUI.isOnlyShow}
end

function CorpsApplyListUI.RecoverStatus(status)
    if status and status.isOnlyShow ~= nil then
        log("CorpsApplyListUI.RecoverStatus:" .. tostring(status.isOnlyShow))
        CorpsApplyListUI.ChangeIsOnlyShow(status.isOnlyShow)
    end

end