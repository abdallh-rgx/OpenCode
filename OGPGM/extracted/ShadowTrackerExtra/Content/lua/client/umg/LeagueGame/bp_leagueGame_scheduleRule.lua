--赛程规则
LeagueGameScheduleRuleUI = LeagueGameScheduleRuleUI or {
	
}


BP_LeagueGameScheduleRule_StageID = 0;

BP_LeagueGameScheduleRule_MatchTime1 = "";
BP_LeagueGameScheduleRule_MatchTime2 = "";
BP_LeagueGameScheduleRule_MatchInfo = "";

BP_LeagueGameScheduleRule_CurrentStageName = "";
BP_LeagueGameScheduleRule_CurrentShowStage = 0;


--比赛形式text
BP_LeagueGameScheduleRule_MatchModus = "";
--参赛步骤
BP_LeagueGameScheduleRule_MatchStep = "";
--积分规则
BP_LeagueGameScheduleRule_MatchIntegralRule = "";
--条件title
BP_LeagueGameScheduleRule_MatchConditionsTitle = "";
--条件text
BP_LeagueGameScheduleRule_MatchConditionsText = "";


BP_LeagueGameScheduleRule_MapName = "";

BP_LeagueGameScheduleRule_From = 0; 		-- 打开来源，0报名界面，1赛事界面

--注册Widget
function bp_leagueGame_scheduleRule_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_leagueGame_scheduleRule,
        {{Path="/Game/UMG/UI_Logic/LeagueGame/LeagueGame_scheduleRule_BP.LeagueGame_scheduleRule_BP_C", Container="Default", ZOrder=BP_ENUM_UI_LEAGUEGAME_LOBBY+3}},
        {"Lobby"},
        false,
        false,
        true
    );
end

function LeagueGameScheduleRuleUI.Init(stage, from)
	BP_LeagueGameScheduleRule_CurrentShowStage = stage;
	BP_LeagueGameScheduleRule_From = from;
	LeagueGameScheduleRuleUI.SetData();
	LeagueGameScheduleRuleUI.Show();
	LeagueGameScheduleRuleUI.ShowTab();
end

function LeagueGameScheduleRuleUI.Release()

end

function LeagueGameScheduleRuleUI.SetData()
	BP_LeagueGameScheduleRule_StageID = LeagueGameSystem.StageId;

	for _k,_v in pairs(LeagueGameSystem.signUpInfo.sub_mode) do
		local IsFpp = Client.GetTableData("BTMode", _v).IsFpp;
		local MapId = Client.GetTableData("BTMode", _v).MapID;
		local mapName = Client.GetTableData("Map", MapId).WatchingName;
		BP_LeagueGameScheduleRule_MapName = mapName;
	end

	if BP_LeagueGameScheduleRule_CurrentShowStage == LeagueGameSystem.LEAGUE_STAGE_FIRST_MATCH then

		BP_LeagueGameScheduleRule_CurrentStageName = Client.GetTableData("LocalizeRes", "6049").TextValue;
		BP_LeagueGameScheduleRule_MatchInfo = string.gsub(Client.GetTableData("LocalizeRes", 6279).TextValue, "{0}", #LeagueGameSystem.LeagueTimeTable[BP_LeagueGameScheduleRule_CurrentShowStage][LeagueGameSystem.LEAGUE_TPP_MODE][1].match_time);
		BP_LeagueGameScheduleRule_MatchTime1 = LeagueGameSystem.LeagueDateTable[BP_LeagueGameScheduleRule_CurrentShowStage].client_show[1];
		BP_LeagueGameScheduleRule_MatchTime2 = LeagueGameSystem.LeagueDateTable[BP_LeagueGameScheduleRule_CurrentShowStage].client_show[2];

		BP_LeagueGameScheduleRule_MatchModus = FuncUtil.LocalizeResFormat(6074, BP_LeagueGameScheduleRule_MapName);
		BP_LeagueGameScheduleRule_MatchStep = Client.GetTableData("LocalizeRes", "6076").TextValue;
		BP_LeagueGameScheduleRule_MatchIntegralRule = Client.GetTableData("LocalizeRes", "6078").TextValue .. Client.GetTableData("LocalizeRes", "6192").TextValue;
		BP_LeagueGameScheduleRule_MatchConditionsTitle = Client.GetTableData("LocalizeRes", "6070").TextValue;
		BP_LeagueGameScheduleRule_MatchConditionsText = Client.GetTableData("LocalizeRes", "6071").TextValue;

	elseif BP_LeagueGameScheduleRule_CurrentShowStage == LeagueGameSystem.LEAGUE_STAGE_GROUP_MATCH then

		BP_LeagueGameScheduleRule_CurrentStageName = Client.GetTableData("LocalizeRes", "6050").TextValue;
		BP_LeagueGameScheduleRule_MatchInfo = string.gsub(Client.GetTableData("LocalizeRes", 6279).TextValue, "{0}", #LeagueGameSystem.LeagueTimeTable[BP_LeagueGameScheduleRule_CurrentShowStage][LeagueGameSystem.LEAGUE_TPP_MODE][1].match_time);
		BP_LeagueGameScheduleRule_MatchTime1 = LeagueGameSystem.LeagueDateTable[BP_LeagueGameScheduleRule_CurrentShowStage].client_show[1];

		BP_LeagueGameScheduleRule_MatchModus = FuncUtil.LocalizeResFormat(6079, BP_LeagueGameScheduleRule_MapName);
		BP_LeagueGameScheduleRule_MatchStep = Client.GetTableData("LocalizeRes", "6080").TextValue;
		BP_LeagueGameScheduleRule_MatchIntegralRule = Client.GetTableData("LocalizeRes", "6078").TextValue .. Client.GetTableData("LocalizeRes", "6192").TextValue;
		BP_LeagueGameScheduleRule_MatchConditionsTitle = Client.GetTableData("LocalizeRes", "6070").TextValue;
		BP_LeagueGameScheduleRule_MatchConditionsText = Client.GetTableData("LocalizeRes", "6087").TextValue;

	elseif BP_LeagueGameScheduleRule_CurrentShowStage == LeagueGameSystem.LEAGUE_STAGE_ZONE_FINAL_MATCH then

		BP_LeagueGameScheduleRule_CurrentStageName = Client.GetTableData("LocalizeRes", "6051").TextValue;
		BP_LeagueGameScheduleRule_MatchInfo = string.gsub(Client.GetTableData("LocalizeRes", 6279).TextValue, "{0}", #LeagueGameSystem.LeagueTimeTable[BP_LeagueGameScheduleRule_CurrentShowStage][LeagueGameSystem.LEAGUE_TPP_MODE][1].match_time);
		BP_LeagueGameScheduleRule_MatchTime1 = LeagueGameSystem.LeagueDateTable[BP_LeagueGameScheduleRule_CurrentShowStage].client_show[1];

		BP_LeagueGameScheduleRule_MatchModus = FuncUtil.LocalizeResFormat(6088, BP_LeagueGameScheduleRule_MapName);
		BP_LeagueGameScheduleRule_MatchStep = Client.GetTableData("LocalizeRes", "6080").TextValue;
		BP_LeagueGameScheduleRule_MatchIntegralRule = Client.GetTableData("LocalizeRes", "6078").TextValue .. Client.GetTableData("LocalizeRes", "6192").TextValue;
		BP_LeagueGameScheduleRule_MatchConditionsTitle = Client.GetTableData("LocalizeRes", "6090").TextValue;
		BP_LeagueGameScheduleRule_MatchConditionsText = Client.GetTableData("LocalizeRes", "6091").TextValue;
	end
end

function LeagueGameScheduleRuleUI.Show()
  LuaClassObj.HandleDynamicCreation(bp_leagueGame_scheduleRule);
  LuaClassObj.HandleUIMessage(bp_leagueGame_scheduleRule, "UIShow");
end

function LeagueGameScheduleRuleUI.ShowTab()
  LuaClassObj.HandleUIMessage(bp_leagueGame_scheduleRule, "ShowTab");
end

function LeagueGameScheduleRuleUI.Hide()
  LuaClassObj.HandleUIMessageNoFetch(bp_leagueGame_scheduleRule, "UIHide");
end

function EventLeagueGameScheduleRuleHide()
	LeagueGameScheduleRuleUI.Hide();
end

function EventLeagueGameScheduleRuleScoreDetail()
	PopUpNoticeUI.ShowMessageBox(Client.GetTableData("LocalizeRes", "6047").TextValue,Client.GetTableData("LocalizeRes", "6048").TextValue);
end


function EventLeagueGameScheduleRuleShowTab()
	LeagueGameScheduleRuleUI.SetData();
	LeagueGameScheduleRuleUI.Show();
	LeagueGameScheduleRuleUI.ShowTab();
end

