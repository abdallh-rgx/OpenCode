
function observe_RegisterUI(self)
  
  InGameUIManager.SubUIWidgetList(self,
    {
		{Path="/Game/BluePrints/UI/OBUI/OBUI_UIBP.OBUI_UIBP_C", Container="Default", ZOrder=BP_ENUM_UI_RANK_ZORDER},
		{Path="/Game/BluePrints/UI/OBUI/OB_AirDropList_BP.OB_AirDropList_BP_C", Container="Default", ZOrder=BP_ENUM_UI_RANK_ZORDER},
		{Path="/Game/BluePrints/ControlInput/ResultsshareUI/ResultsOB/ResultsOB_UIBP.ResultsOB_UIBP_C", Container="Default", ZOrder=BP_ENUM_UI_RANK_ZORDER},
	},
    {"Fighting",},
	false,
	true,
	true
	);
end

ObserverUI = ObserverUI or {}

function ObserverUI.EnterOvserving()
	if observe then
		InGameUIManager.HandleDynamicCreation(observe);
		InGameUIManager.HandleUIMessage(observe, "ShowOBUI");
	end
	if ingame then
		InGameUIManager.HandleUIMessage(ingame, "EnterSpectatingStatus");
		InGameUIManager.HandleUIMessage(ingame, "EnterObserverStatus");
	end
end