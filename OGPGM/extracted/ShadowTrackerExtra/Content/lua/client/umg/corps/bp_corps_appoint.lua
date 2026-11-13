CorpsAppointUI = CorpsAppointUI or
{
    memberID = 0,
    isShow = false,
}

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

BP_STRUCT_CorpsAppoint_ListItemData =
{
    BP_STRUCT_BASE_INFO = _G.BP_STRUCT_BASE_INFO,
    AppointType = 0,
    WeekContrActive = 0,
    SeasonContrActive = 0,

    WeekCorpsWarCount = 0,
    SeasonCorpsWarCount = 0,
}

BP_STRUCT_CorpsAppoint_PanelData =
{
    BP_STRUCT_CorpsAppoint_ListItemData = _G.BP_STRUCT_CorpsAppoint_ListItemData
};

BP_ARRAY_CorpsAppoint_PositionCount = {0}

BP_ARRAY_CorpsAppoint_PositionCountMax = {0}

BP_CorpsAppoint_ChangeType = 0;

function bp_corps_appoint_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_corps_appoint,
        {{Path = "/Game/UMG/UI_Logic/Corps/CorpsAppoint_BP.CorpsAppoint_BP_C", Container = "Default", ZOrder = BP_ENUM_UI_CORPS_ZORDER + 2}},
        {"Lobby"},
        false,
        false,
        true);
end

function EventCorpsAppointOnClickClose()
    CorpsAppointUI.HideUI();
end

function CorpsAppointUI.ShowUI(member)
    -- log_tree("CorpsAppointUI.ShowUI member", member);
    CorpsAppointUI.isShow = true;
    CorpsAppointUI.memberID = member.id;

    local baseInfo = member.BP_STRUCT_BASE_INFO;

    LuaClassObj.HandleDynamicCreation(bp_corps_appoint);

    local data = BP_STRUCT_CorpsAppoint_PanelData.BP_STRUCT_CorpsAppoint_ListItemData;
    data.BP_STRUCT_BASE_INFO = baseInfo;
    data.AppointType = member.position;
    data.WeekContrActive = member.week_active;
    data.SeasonContrActive = member.season_active;

    local levelCfg = Client.GetTableData("CorpsLevel", DataMgr.corpsInfo.level);
    -- log("CorpsAppointUI.ShowUI DataMgr.corpsInfo.level "..DataMgr.corpsInfo.level);
    -- log_tree("CorpsAppointUI.ShowUI levelCfg", levelCfg);
    if levelCfg == nil then
        return;
    end

    BP_ARRAY_CorpsAppoint_PositionCount = {};
    BP_ARRAY_CorpsAppoint_PositionCount[1] = CorpsAppointUI.GetMemberCount(2);
    BP_ARRAY_CorpsAppoint_PositionCount[2] = CorpsAppointUI.GetMemberCount(3);
    BP_ARRAY_CorpsAppoint_PositionCount[3] = CorpsAppointUI.GetMemberCount(11);

    BP_ARRAY_CorpsAppoint_PositionCountMax = {};
    BP_ARRAY_CorpsAppoint_PositionCountMax[1] = levelCfg.SecondCommanderLimit;
    BP_ARRAY_CorpsAppoint_PositionCountMax[2] = levelCfg.EliteLimit;
    BP_ARRAY_CorpsAppoint_PositionCountMax[3] = levelCfg.MemberLimit - levelCfg.EliteLimit - levelCfg.SecondCommanderLimit - 1;

    LuaClassObj.HandleUIMessage(bp_corps_appoint, "ShowUI");
    UIManager.Show(eUIType.eCorpsAppointUI)

    EventSystem:registEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_CORPS_ID, CorpsAppointUI.OnUpdateCorpsID);
end

function CorpsAppointUI.OnUpdateCorpsID()
    if DataMgr.corpsInfo.id == 0 then
        CorpsAppointUI.HideUI();
    end
end

function CorpsAppointUI.GetMemberCount(position)
    local count = 0;
    for i,v in ipairs(DataMgr.corpsInfo.corpsMemberList) do
        if v.position == position then
            count = count + 1;
        end
    end

    return count;
end

function CorpsAppointUI.HideUI()
    CorpsAppointUI.isShow = false;
    UIManager.Hide(eUIType.eCorpsAppointUI)
    LuaClassObj.HandleUIMessage(bp_corps_appoint, "HideUI");
    EventSystem:unregistEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_CORPS_ID, CorpsAppointUI.OnUpdateCorpsID);
end

function EventCorpsAppointOnClickConfirm()
    local member = CorpsMemberSystem.FindMemberByID(CorpsAppointUI.memberID);
    if member == nil then
        return;
    end

    local function onClickOK()
        if BP_CorpsAppoint_ChangeType == member.position then
            ShowNotice(410001);
        else
            CorpsMemberSystem.SendAppoint(CorpsAppointUI.memberID, BP_CorpsAppoint_ChangeType);
        end
    end

    if BP_CorpsAppoint_ChangeType == 1 then
        -- log_tree("EventCorpsAppointOnClickConfirm member", member);
        local msg = FuncUtil.LocalizeResFormat("410038", member.BP_STRUCT_BASE_INFO.Name);
        local titile = FuncUtil.GetLocalizeResStr("101001");
        CommonMessageBoxUI:ShowPanel(2, titile, msg, onClickOK);
    else
        onClickOK();
    end
end