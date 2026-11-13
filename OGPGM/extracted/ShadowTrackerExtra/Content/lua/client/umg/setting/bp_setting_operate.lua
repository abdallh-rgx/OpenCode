--设置界面

SettingOperateUI = SettingOperateUI or 
{
	
}

--注册widget
function bp_setting_operate_RegisterUI()
  LuaClassObj.SubUIWidgetList(bp_setting_operate,
    {{Path="/Game/UMG/UI_BP/Setting/Setting_Operate_UIBP.Setting_Operate_UIBP_C", Container="Default", ZOrder = 60}},
    {"Lobby", "Fighting"},
	false,
	false,
	true
  );
end

function SettingOperateUI:Init()
	LuaClassObj.HandleDynamicCreation(bp_setting_operate);
	LuaClassObj.HandleUIMessage(bp_setting_operate, "InitUI");
end

function SettingOperateUI:Hide()
	LuaClassObj.HandleUIMessage(bp_setting_operate, "UIHide");
end