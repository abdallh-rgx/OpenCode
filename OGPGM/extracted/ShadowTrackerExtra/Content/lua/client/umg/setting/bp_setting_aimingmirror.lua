--一设置界面

SettingAimingMirrorUI = SettingAimingMirrorUI or 
{
	
}

--注册widget
function bp_setting_aimingmirror_RegisterUI()
  LuaClassObj.SubUIWidgetList(bp_setting_aimingmirror,
    {{Path="/Game/UMG/UI_BP/Setting/Setting_QuasiMirror_UIBP.Setting_QuasiMirror_UIBP_C", Container="Default", ZOrder = 60}},
    {"Lobby", "Fighting"},
	false,
	false,
	true
  );
end

function SettingAimingMirrorUI:Init()
	log("666666666666")
	LuaClassObj.HandleDynamicCreation(bp_setting_aimingmirror);
	LuaClassObj.HandleUIMessage(bp_setting_aimingmirror, "InitUI");
end

function SettingAimingMirrorUI:Hide()
	LuaClassObj.HandleUIMessage(bp_setting_aimingmirror, "UIHide");
end