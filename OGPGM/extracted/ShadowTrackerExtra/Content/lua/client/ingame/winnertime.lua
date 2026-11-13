function winnertime_RegisterUI(self)

	InGameUIManager.SubUIWidgetList(self,
		{
			{Path="/Game/BluePrints/ControlInput/ResultsshareUI/Results_PoseQuit_BP.Results_PoseQuit_BP_C", Container="Default", ZOrder=BP_ENUM_UI_RANK_ZORDER},
		},
		{"Fighting",},
		false,
		true,
		true
	);
end

WinnerTime = WinnerTime or {}

function WinnerTime:EnterWinnerTime()
	log("WinnerTime:EnterWinnerTime");
	InGameUIManager.HandleDynamicCreation(winnertime);
	InGameUIManager.HandleUIMessage(winnertime, "ShowWinnerTimeUI");
end

function EventUploadFaceClick()
    NetUtil.SendPkg("report_settle_accounts", g_game_id, 0);
	log("EventUploadFaceClick");
end