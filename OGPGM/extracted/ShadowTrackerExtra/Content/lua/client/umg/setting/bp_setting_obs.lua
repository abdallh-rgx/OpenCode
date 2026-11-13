--基础设置界面

SettingOBSUI = SettingOBSUI or 
{
	
}

--注册widget
function bp_setting_obs_RegisterUI()
  LuaClassObj.SubUIWidgetList(bp_setting_obs,
    {{Path="/Game/UMG/UI_BP/Setting/Setting_OBS_UIBP.Setting_OBS_UIBP_C", Container="Default", ZOrder = 60}},
    {"Lobby", "Fighting"},
	false,
	false,
	true
  );
end

function SettingOBSUI:Init()
	log("hps setting OBSUI init")

	LuaClassObj.HandleDynamicCreation(bp_setting_obs);
	LuaClassObj.HandleUIMessage(bp_setting_obs, "InitUI");
end

function SettingOBSUI:Hide()
	log("hps setting OBSUI hide")

	LuaClassObj.HandleUIMessage(bp_setting_obs, "UIHide");
end