
function firsttimetips_warmode_RegisterUI(self)
	InGameUIManager.SubUIWidgetList(self,
	{
		{Path="/Game/BluePrints/ControlInput/IngameFirstTimeTips/FirstTimeTips_war_FPP.FirstTimeTips_war_FPP_C", Container="Default", ZOrder=BP_ENUM_UI_RANK_ZORDER},
	},
	{"Fighting",},
	false,
	true,
	true
	);
end

WARMODE_TIPSUI = WARMODE_TIPSUI or {} 

function WARMODE_TIPSUI:ShowWarModeTips()
	if firsttimetips_warmode then
		InGameUIManager.HandleDynamicCreation(firsttimetips_warmode);
		InGameUIManager.HandleUIMessage(firsttimetips_warmode, "Show");
	end
end 

function WARMODE_TIPSUI:HideWarModeTips()
	if (firsttimetips_warmode) then
		InGameUIManager.HandleUIMessage(firsttimetips_warmode, "Hide");
		InGameUIManager.HandleDynamicDestroy(firsttimetips_warmode);
	end
end 