--一设置界面

SettingSubscriptionUI = SettingSubscriptionUI or 
{
	
}

--注册widget
function bp_setting_subscription_RegisterUI()
  LuaClassObj.SubUIWidgetList(bp_setting_subscription,
    {{Path="/Game/UMG/UI_BP/Setting/Setting_subscription_UIBP.Setting_subscription_UIBP_C", Container="Default", ZOrder = 60}},
    {"Lobby"},
	false,
	false,
	true
  );
end

function SettingSubscriptionUI:Init()
	LuaClassObj.HandleDynamicCreation(bp_setting_subscription);
	LuaClassObj.HandleUIMessage(bp_setting_subscription, "InitUI");
end

function SettingSubscriptionUI:Hide()
	LuaClassObj.HandleUIMessage(bp_setting_subscription, "UIHide");
end