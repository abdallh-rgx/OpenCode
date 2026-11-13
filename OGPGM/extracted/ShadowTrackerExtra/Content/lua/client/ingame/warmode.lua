
function warmode_RegisterUI(self)

	InGameUIManager.SubUIWidgetList(self,
		{
			{Path="/Game/BluePrints/ControlInput/Wmode/WmodeUI_BP.WmodeUI_BP_C", Container="Default", ZOrder=BP_ENUM_UI_RANK_ZORDER},
		},
		{"Fighting",},
		false,
		true,
		true
		);
end
		
WarModeUI = WarmodeUI or {}

function WarModeUI:EnterWarMode()
	if warmode then
		InGameUIManager.HandleDynamicCreation(warmode);
		InGameUIManager.HandleUIMessage(warmode, "ShowWarModeUI");
	end
end

