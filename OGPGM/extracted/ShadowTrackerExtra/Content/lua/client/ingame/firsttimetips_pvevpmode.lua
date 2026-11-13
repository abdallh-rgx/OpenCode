
function firsttimetips_pvevpmode_RegisterUI(self)
	InGameUIManager.SubUIWidgetList(self,
	{
		{Path="/Game/BluePrints/ControlInput/IngameFirstTimeTips/FirstTimeTips_PVEVP.FirstTimeTips_PVEVP_C", Container="Default", ZOrder=BP_ENUM_UI_RANK_ZORDER},
	},
	{"Fighting",},
	false,
	true,
	true
	);
end

PVEVP_TIPSUI = PVEVP_TIPSUI or {} 

function PVEVP_TIPSUI:ShowPVEVPModeTips()
	local bUIAutoTest = Client.IsUIAutoTest()
    if bUIAutoTest then
        return
    end

	if firsttimetips_pvevpmode then
		InGameUIManager.HandleDynamicCreation(firsttimetips_pvevpmode);
		InGameUIManager.HandleUIMessage(firsttimetips_pvevpmode, "Show");
	end
end

function PVEVP_TIPSUI:HidePVEVPModeTips()
	if firsttimetips_pvevpmode then
		InGameUIManager.HandleUIMessage(firsttimetips_pvevpmode, "Hide");
		InGameUIManager.HandleDynamicDestroy(firsttimetips_pvevpmode);
	end
end
