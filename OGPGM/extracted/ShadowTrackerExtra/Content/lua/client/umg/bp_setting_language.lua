--[[
	分享 2017-12-12
--]]
BP_IsInLoginPanel = false;

SettingLanguageUI = SettingLanguageUI or {

}

function bp_setting_language_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_setting_language,		
    	{
			{Path="/Game/UMG/UI_BP/Setting/Setting_language02_UIBP.Setting_language02_UIBP_C", Container="Default", ZOrder = 50},
			{Path="/Game/UMG/UI_BP/Login/Authorization_BP.Authorization_BP_C", Container="Default", ZOrder=0}
		},
		{"Login","CreateRole"},
		false,
		false,
		true
	);
end	 

--显示UI 
function SettingLanguageUI.ShowUI()	
	BP_IsInLoginPanel = false;
	--LuaClassObj.HandleUIMessage(bp_setting_language, "UIShow");	
	LuaClassObj.HandleDynamicCreation(bp_setting_language);
	LuaClassObj.HandleUIMessage(bp_setting_language, "UIShow");
end

--显示UI 
function SettingLanguageUI.ShowUIInLoginPanel()
	BP_IsInLoginPanel = true;
	--LuaClassObj.HandleUIMessage(bp_setting_language, "UIShow");	
	LuaClassObj.HandleDynamicCreation(bp_setting_language);
	LuaClassObj.HandleUIMessage(bp_setting_language, "UIShow");
end


--关闭UI
function EventHideUI()
	LuaClassObj.HandleUIMessage(bp_setting_language, "UIHide");	
end

--rainpan:刷新登录UI 设置语言后，日韩/全球有些UI变化
function EventRefreshAuthorization_BP()
	log("bp_setting_language EventRefreshAuthorization_BP");
	LuaClassObj.HandleUIMessage(bp_authorization, "RefreshLoginBtn");		
end