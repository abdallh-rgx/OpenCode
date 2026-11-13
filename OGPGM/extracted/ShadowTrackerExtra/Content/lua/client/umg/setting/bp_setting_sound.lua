--一设置界面

SettingSoundUI = SettingSoundUI or 
{
	
}

--注册widget
function bp_setting_sound_RegisterUI()
  LuaClassObj.SubUIWidgetList(bp_setting_sound,
    {{Path="/Game/UMG/UI_BP/Setting/Setting_Sound_UIBP.Setting_Sound_UIBP_C", Container="Default", ZOrder = 60}},
    {"Lobby", "Fighting"},
	false,
	false,
	true
  );
end

function SettingSoundUI:Init()
	LuaClassObj.HandleDynamicCreation(bp_setting_sound);
	LuaClassObj.HandleUIMessage(bp_setting_sound, "InitUI");
end

function SettingSoundUI:Hide()
	LuaClassObj.HandleUIMessage(bp_setting_sound, "UIHide");
end