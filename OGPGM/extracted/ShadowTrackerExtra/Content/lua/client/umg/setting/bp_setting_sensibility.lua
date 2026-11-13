--设置界面

SettingSensibilityUI = SettingSensibilityUI or 
{
	
}

--注册widget
function bp_setting_sensibility_RegisterUI()
  LuaClassObj.SubUIWidgetList(bp_setting_sensibility,
    {{Path="/Game/UMG/UI_BP/Setting/Setting_Sensibility_UIBP.Setting_Sensibility_UIBP_C", Container="Default", ZOrder = 60}},
    {"Lobby", "Fighting"},
	false,
	false,
	true
  );
end

function SettingSensibilityUI:Init()
	LuaClassObj.HandleDynamicCreation(bp_setting_sensibility);
	LuaClassObj.HandleUIMessage(bp_setting_sensibility, "InitUI");
end

function SettingSensibilityUI:Hide()
	LuaClassObj.HandleUIMessage(bp_setting_sensibility, "UIHide");
end