--拾取设置界面

SettingPickupUI = SettingPickupUI or 
{
	
}

--注册widget
function bp_setting_pickup_RegisterUI()
  LuaClassObj.SubUIWidgetList(bp_setting_pickup,
    {{Path="/Game/UMG/UI_BP/Setting/Setting_Pickup_UIBP.Setting_Pickup_UIBP_C", Container="Default", ZOrder = 60}},
    {"Lobby", "Fighting"},
	false,
	false,
	true
  );
end

function SettingPickupUI:Init()
	LuaClassObj.HandleDynamicCreation(bp_setting_pickup);
	LuaClassObj.HandleUIMessage(bp_setting_pickup, "InitUI");
end

function SettingPickupUI:Hide()
	LuaClassObj.HandleUIMessage(bp_setting_pickup, "UIHide");
end