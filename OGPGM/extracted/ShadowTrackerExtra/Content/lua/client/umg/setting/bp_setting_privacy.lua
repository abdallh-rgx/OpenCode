--设置界面

SettingPrivacyUI = SettingPrivacyUI or 
{
	
}

--注册widget
function bp_setting_privacy_RegisterUI()
  LuaClassObj.SubUIWidgetList(bp_setting_privacy,
    {{Path="/Game/UMG/UI_BP/Setting/setting_Privacy_UIBP.setting_Privacy_UIBP_C", Container="Default", ZOrder = 60}},
    {"Lobby", "Fighting"},
	false,
	false,
	true
  );
end

function SettingPrivacyUI:Init()
	LuaClassObj.HandleDynamicCreation(bp_setting_privacy);
	LuaClassObj.HandleUIMessage(bp_setting_privacy, "InitUI");
end

function SettingPrivacyUI:Hide()
	LuaClassObj.HandleUIMessage(bp_setting_privacy, "UIHide");
end