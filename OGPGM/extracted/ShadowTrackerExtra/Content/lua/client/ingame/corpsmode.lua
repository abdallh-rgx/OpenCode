
function corpsmode_RegisterUI(self)
	InGameUIManager.SubUIWidgetList(corpsmode,
		{
			{Path="/Game/BluePrints/ControlInput/CorpsMode/ZD_CorpsMode_UIBP.ZD_CorpsMode_UIBP_C", Container="Default", ZOrder=BP_ENUM_UI_RANK_ZORDER},
		},
		{"Fighting"},
		false,
		true,
		true
		);

end

CORPSMODEUI = CROPSMODEUI or {}

function CORPSMODEUI:CORPSMODEUI_DynamicCreateUI()
	InGameUIManager.HandleDynamicCreation(corpsmode);
	InGameUIManager.HandleUIMessage(corpsmode, "ShowCorpsModeUI");
end