
-- 进入此模式就会加载的ui
local uiConfig = 
{
	-- {Path="/Game/BluePrints/PVE/UMG/PVEVPBoss.PVEVPBoss_C", Container="Default", ZOrder=BP_ENUM_UI_RANK_ZORDER},
	{Path="/Game/BluePrints/PVE/UMG/PVEMonster_Health_UIBP.PVEMonster_Health_UIBP_C", Container="Default", ZOrder=BP_ENUM_UI_RANK_ZORDER},
	{Path="/Game/BluePrints/PVE/UMG/PVEMonsterWarning_BP.PVEMonsterWarning_BP_C", Container="Default", ZOrder=BP_ENUM_UI_RANK_ZORDER},
	-- {Path="/Game/BluePrints/PVE/UMG/PVEWeatherInfo_UIBP.PVEWeatherInfo_UIBP_C", Container="Default", ZOrder=0},
	{Path="/Game/BluePrints/PVE/UMG/PVE_KillMonsterNumPanel_UIBP.PVE_KillMonsterNumPanel_UIBP_C", Container="Default", ZOrder=BP_ENUM_UI_RANK_ZORDER},	
	--{Path="/Game/BluePrints/PVE/UMG/PVEVictoryCountDown_UIBP.PVEVictoryCountDown_UIBP_C", Container="Default", ZOrder=BP_ENUM_UI_RANK_ZORDER},
	{Path="/Game/BluePrints/PVE/UMG/BP_PoisonFog_UIBP.BP_PoisonFog_UIBP_C", Container="Default", ZOrder=BP_ENUM_UI_RANK_ZORDER},
	{Path="/Game/BluePrints/PVE/UMG/ElitesCountDown_UIBP.ElitesCountDown_UIBP_C", Container="Default", ZOrder=BP_ENUM_UI_RANK_ZORDER},
}

function pvevpmode_RegisterUI(self)
	InGameUIManager.SubUIWidgetList(self, uiConfig, {"Fighting"}, false, true, true)
end

function pvevpmode_InitUI()
	if pvevpmode then
		InGameUIManager.HandleDynamicCreation(pvevpmode)
		InGameUIManager.HandleUIMessage(pvevpmode, "Show")
	end
end

function pvevpmode_HideUI()
	if pvevpmode then
		InGameUIManager.HandleUIMessage(pvevpmode, "WarningHide")
		InGameUIManager.HandleUIMessage(pvevpmode, "Hide")
		InGameUIManager.HandleDynamicDestroy(pvevpmode)
	end
end

function pvevpmode_ShowUI()
	if pvevpmode then
		InGameUIManager.HandleDynamicCreation(pvevpmode)
		InGameUIManager.HandleUIMessage(pvevpmode, "Show")
		InGameUIManager.HandleUIMessage(pvevpmode, "WarningShow")
	end
end
