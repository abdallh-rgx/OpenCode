CommonHelpTipsUI = CommonHelpTipsUI or {}

BP_CommonHelpTips_StringID =0;
BP_CommonHelpTips_String = "";

--手动输入状态下，输入点击位置或者按钮位置，panel再计算摆放
BP_STRUCT_GlobalHelpTips_Pos = { x = 0,y = 0}

-- 注册面板
function bp_common_helptips_panel_RegisterUI()
	log("bp_common_helptips_panel_RegisterUI");
	LuaClassObj.SubUIWidgetList(bp_common_helptips_panel,
		{{Path="/Game/UMG/UI_Logic/Common/Common_HelpTips_Panel_BP.Common_HelpTips_Panel_BP_C", Container="Top", ZOrder=BP_ENUM_UI_COMMON_ITEMTIPS_ZORDER}},
		{"Lobby","CreateRole"},
		false,
		false
	);	
end

function CommonHelpTipsUI:ShowPanel(stringID,pos)
	BP_CommonHelpTips_StringID = stringID
    BP_STRUCT_GlobalHelpTips_Pos = pos
	LuaClassObj.HandleUIMessage(bp_common_helptips_panel, "UIShow");
end

function CommonHelpTipsUI:ShowPanelStr(str, pos)
	BP_CommonHelpTips_String = str
    BP_STRUCT_GlobalHelpTips_Pos = pos
	LuaClassObj.HandleUIMessage(bp_common_helptips_panel, "UIShowStr");
end

function CommonHelpTipsUI:ClosePanel()
	LuaClassObj.HandleUIMessage(bp_common_helptips_panel, "UIClose")
end