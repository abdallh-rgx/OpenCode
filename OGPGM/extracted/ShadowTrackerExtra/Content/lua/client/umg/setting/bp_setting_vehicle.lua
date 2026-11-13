--一设置界面

SettingVehicleUI = SettingVehicleUI or 
{
	
}

BP_IsInLobby_VehicleSetting = false;

--注册widget
function bp_setting_vehicle_RegisterUI()
  LuaClassObj.SubUIWidgetList(bp_setting_vehicle,
    {{Path="/Game/UMG/UI_BP/Setting/Setting_Vehicle_UIBP.Setting_Vehicle_UIBP_C", Container="Default", ZOrder = 60}},
    {"Lobby", "Fighting"},
	false,
	false,
	true
  );
end

--跳转到Lobby
function bp_setting_vehicle_OnModeSwitched(gamestatus)
	if string.lower(gamestatus) == "lobby" then
		BP_IsInLobby_VehicleSetting = true;
	else
		BP_IsInLobby_VehicleSetting = false;
	end
end

function SettingVehicleUI:Init()
	LuaClassObj.HandleDynamicCreation(bp_setting_vehicle);
	LuaClassObj.HandleUIMessage(bp_setting_vehicle, "InitUI");
end

function SettingVehicleUI:Hide()
	LuaClassObj.HandleUIMessage(bp_setting_vehicle, "UIHide");
end