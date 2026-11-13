--基础设置界面

SettingBasicUI = SettingBasicUI or 
{
	
}

BP_BasicSettingCanShowHistory = true
--注册widget
function bp_setting_basic_RegisterUI()
  LuaClassObj.SubUIWidgetList(bp_setting_basic,
    {{Path="/Game/UMG/UI_BP/Setting/Setting_Basic_UIBP.Setting_Basic_UIBP_C", Container="Default", ZOrder = 60}},
    {"Lobby", "Fighting"},
	false,
	false,
	true
  );
end

function SettingBasicUI:Init()
	log("[HHF]SettingBasicUI:Init");
	LuaClassObj.HandleDynamicCreation(bp_setting_basic);
	LuaClassObj.HandleUIMessage(bp_setting_basic, "InitUI");
	self:FreshRoleHistoryPrivacySetting()

	SettingUI.AutoBindFacebook();
end

function SettingBasicUI:FreshRoleHistoryPrivacySetting(canShow)
	BP_BasicSettingCanShowHistory = canShow
	LuaClassObj.HandleUIMessage(bp_setting_basic, "InitBattleHistorySetting");
end

function EventSettingHistory()
	RoleInfoHistorySystem.send_show_history(BP_BasicSettingCanShowHistory)
end

function EventShowSettingBindMore()
	SettingBindMoreUI:Init()
end

function EventHideSettingBindMore()
	SettingBindMoreUI:Hide()
end

function SettingBasicUI:Hide()
	LuaClassObj.HandleUIMessage(bp_setting_basic, "UIHide");
end