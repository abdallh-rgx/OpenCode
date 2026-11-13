--一设置界面

SettingBindMoreUI = SettingBindMoreUI or 
{
	
}

--注册widget
function bp_setting_bind_more_RegisterUI()
  LuaClassObj.SubUIWidgetList(bp_setting_bind_more,
    {{Path="/Game/UMG/UI_BP/Setting/item/Setting_BindChoice_Panel.Setting_BindChoice_Panel_C", Container="Default", ZOrder = 61}},
    {"Lobby"},
	false,
	false,
	true
  );
end

function SettingBindMoreUI:Init()
	log("9999999999")
	LuaClassObj.HandleDynamicCreation(bp_setting_bind_more);
	LuaClassObj.HandleUIMessage(bp_setting_bind_more, "InitUI");
end

function SettingBindMoreUI:Hide()
	LuaClassObj.HandleUIMessage(bp_setting_bind_more, "UIHide");
end