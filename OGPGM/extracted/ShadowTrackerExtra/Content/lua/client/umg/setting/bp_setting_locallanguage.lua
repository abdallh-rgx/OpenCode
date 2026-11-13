--设置界面

SettingLocalLanguageUI = SettingLocalLanguageUI or 
{
	
}

--注册widget
function bp_setting_locallanguage_RegisterUI()
  LuaClassObj.SubUIWidgetList(bp_setting_locallanguage,
    {{Path="/Game/UMG/UI_BP/Setting/Setting_language_UIBP.Setting_language_UIBP_C", Container="Default", ZOrder = 60}},
    {"Lobby", "Fighting"},
	false,
	false,
	true
  );
end

function SettingLocalLanguageUI:Init()
	LuaClassObj.HandleDynamicCreation(bp_setting_locallanguage);
	LuaClassObj.HandleUIMessage(bp_setting_locallanguage, "InitUI");
end

function SettingLocalLanguageUI:Hide()
	LuaClassObj.HandleUIMessage(bp_setting_locallanguage, "UIHide");
end

-- 聊天语言设置
function EventChatLanguageSelect()
	ChatLanguageSelect.Show();
end

-- 匹配语言设置
function EventMatchLanguageSelect()
	local sameLanguageType  = false;
	if DataMgr.MatchLanguage then
		sameLanguageType = DataMgr.MatchLanguage.only_match or false;
	end
	MatchLanguageSelect.SetAsMatchInfoType(sameLanguageType);
	MatchLanguageSelect.Show();
end