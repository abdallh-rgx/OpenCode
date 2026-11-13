-- 生化夺宝概率显示弹窗
PVE_RATE_UI = PVE_RATE_UI or
{
    isShow = false
}

--注册Widget
function bp_pve_rate_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_pve_rate,
            {{Path="/Game/UMG/UI_BP/Lobby_Store_Int/ODDS_PVE_UIBP.ODDS_PVE_UIBP_C", Container="Top", ZOrder=BP_ENUM_UI_COMMON_MESSAGEBOX_ZORDER - 1}},
            {"Lobby"},
            false,
            false,
            true
    );
end

function EventPVERateUIShow()
    LuaClassObj.HandleDynamicCreation(bp_pve_rate);
    LuaClassObj.HandleUIMessage(bp_pve_rate, "UIShow");
    Rate_Panel_UI.isShow = true
end

function EventPVERateUIHide()
    Rate_Panel_UI.isShow = false
end