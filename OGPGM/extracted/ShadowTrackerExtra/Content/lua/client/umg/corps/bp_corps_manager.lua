CorpsManagerUI = CorpsManagerUI or {}

BP_STRUCT_CorpsManager_PanelData =
{
    isAcceptApply = true,           -- 是否接受申请
    isNeedApproval = true,          -- 是否需要审批
    joinLevel = 0,                  -- 申请最低等级 无限制填1
    joinSegment = 0,                -- 申请最低段位 无限制填1 对应段位表
};

BP_CorpsManager_IconID = 0;
BP_CorpsManager_IconText = "";
BP_CorpsManager_IconColourId = 0;
BP_STRUCT_CorpsManager_PanelInfo = _G.BP_STRUCT_CorpsManager_PanelData;

BP_ARRAY_CorpsManager_LevelOption = {""};
BP_ARRAY_CorpsManager_SegmentOption = {""};

function bp_corps_manager_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_corps_manager,
        {{Path = "/Game/UMG/UI_Logic/Corps/CorpsManager_BP.CorpsManager_BP_C", Container = "Default", ZOrder = BP_ENUM_UI_CORPS_ZORDER + 2}},
        {"Lobby"},
        false,
        false,
        true);
end

-- 关闭
function EventCorpsManagerOnClickClose()
    CorpsManagerUILogic.HideUI();
end

-- 点击确定
function EventCorpsManagerOnClickConfirm()
    -- log_tree("EventCorpsManagerOnClickConfirm BP_STRUCT_CorpsManager_PanelInfo", BP_STRUCT_CorpsManager_PanelInfo)
    CorpsManagerUILogic.OnClickOK();
end

-- 点击更换icon
function EventCorpsManagerOnClickChangeIcon()
    BP_CorpsIconCurUseId = DataMgr.corpsInfo.icon;
    BP_CorpsCurIconText = DataMgr.corpsInfo.icon_text
    BP_CorpsCurIconColourId = DataMgr.corpsInfo.icon_text_colour
    CorpsIconSelectUI.ShowUI(CorpsIconSelectUI.openFromType_CorpsManager);
end