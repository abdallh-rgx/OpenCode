CommonTouchTipsUI = CommonTouchTipsUI or {}


--手动输入状态下，输入点击位置或者按钮位置，panel再计算摆放
BP_STRUCT_CommonTouchTips_Pos = { x = 0,y = 0}

BP_CommonTouchTips_Text = ""
BP_CommonTouchTitle_Text = "";

-- 注册面板
function bp_common_touchtips_panel_RegisterUI()
	log("CommonTouchTipsUI:bp_common_touchtips_panel_RegisterUI");
	LuaClassObj.SubUIWidgetList(bp_common_touchtips_panel,
		{{Path="/Game/UMG/UI_Logic/Common/Common_TouchTips_PanelLogic_BP.Common_TouchTips_PanelLogic_BP_C", Container="Top", ZOrder=BP_ENUM_UI_COMMON_ITEMTIPS_ZORDER}},
		{"Lobby"},
		false,
		false
	);	
end

function CommonTouchTipsUI.ShowPanel(title,str,pos)
	BP_CommonTouchTips_Text = str;
	BP_CommonTouchTitle_Text = title;
	BP_STRUCT_CommonTouchTips_Pos = pos;
	log("CommonTouchTipsUI:"..tostring(str))
	LuaClassObj.HandleUIMessage(bp_common_touchtips_panel, "UIShow");
end

function CommonTouchTipsUI.ClosePanel()
	LuaClassObj.HandleUIMessage(bp_common_touchtips_panel, "UIClose")
end


