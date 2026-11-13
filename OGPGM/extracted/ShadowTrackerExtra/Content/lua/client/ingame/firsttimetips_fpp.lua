
function firsttimetips_fpp_RegisterUI(self)
	InGameUIManager.SubUIWidgetList(self,
	{
		{Path="/Game/BluePrints/ControlInput/IngameFirstTimeTips/FirstTimeTips_FPP.FirstTimeTips_FPP_C", Container="Default", ZOrder=BP_ENUM_UI_RANK_ZORDER},
	},
	{"Fighting",},
	false,
	true,
	true
	);
end

FPP_TPP_TIPSUI = FPP_TPP_TIPSUI or {} 

function FPP_TPP_TIPSUI:ShowFPPTips()
	if (firsttimetips_fpp) then
		InGameUIManager.HandleDynamicCreation(firsttimetips_fpp);
		InGameUIManager.HandleUIMessage(firsttimetips_fpp, "Show");
	end
end 

function FPP_TPP_TIPSUI:HideFPPTips()
	if (firsttimetips_fpp) then
		InGameUIManager.HandleUIMessage(firsttimetips_fpp, "Hide");
		InGameUIManager.HandleDynamicDestroy(firsttimetips_fpp);
	end
end 