--赛事报名
LeagueGameTipsUI = LeagueGameTipsUI or {

}
BP_LeagueGameTips_MatchDate = "";
BP_LeagueGameTips_MatchTime = "";
--注册Widget
function bp_leagueGame_tips_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_leagueGame_tips,
        {{Path="/Game/UMG/UI_BP/LeagueGame/LeagueGame_lobby_Tips_UIBP.LeagueGame_lobby_Tips_UIBP_C", Container="Default", ZOrder=BP_ENUM_UI_LEAGUEGAME_LOBBY+10}},
        {"Lobby"},
        false,
        false,
        true
    );
end


function LeagueGameTipsUI.Init()	
    log("LeagueGameTipsUI.Init");
	LeagueGameTipsUI.SetData();
	LeagueGameTipsUI.Show();
end

function LeagueGameTipsUI.Show()
	LuaClassObj.HandleDynamicCreation(bp_leagueGame_tips);
	LuaClassObj.HandleUIMessage(bp_leagueGame_tips, "UIShow");
end

function LeagueGameTipsUI.Hide()
	LuaClassObj.HandleUIMessage(bp_leagueGame_tips, "UIHide");
end

function LeagueGameTipsUI.Release()
    log("LeagueGameTipsUI.Release");
end

function LeagueGameTipsUI.SetData()
	local IsCal = false
	if LeagueGameSystem.signUpState == 1 or LeagueGameSystem.signUpState == 2 then
		if LeagueGameSystem.StageId == LeagueGameSystem.LEAGUE_STAGE_FIRST_MATCH then
			IsCal = true
		end
	end

	local DateStr = ""
	local TimeStr = ""

	if IsCal then
		local Mode = AllianceCompetitionSystem.Mode
		local Zone = AllianceCompetitionSystem.Zone

		local MatchInfo = LeagueGameSystem.LeagueTimeTable[BP_LeagueGame_Stage][Mode][Zone]
		local MatchNum = #MatchInfo.match_time

		local SepCount = 0
		local SepNum = 1
		local MatchDate = {}
		local MatchesTimestamp = MatchInfo.vaild_match_time_slot
		if LeagueGameSystem.StageId == LeagueGameSystem.LEAGUE_STAGE_GROUP_MATCH then
			-- 小组赛只显示自己小组的场次
			local BeginTimestamp = MatchesTimestamp[BP_LeagueInfo_SelfGroupId]
			local BeginTime = os.date("*t", BeginTimestamp)
			local Str = string.format("%d.%d", BeginTime.month, BeginTime.day)
			table.insert(MatchDate, Str)
		else
			-- 其他阶段显示所有场次
			for k, v in ipairs(MatchesTimestamp) do
				local BeginTimestamp = v[1]
				local BeginTime = os.date("*t", BeginTimestamp)
				local Str = string.format("%d.%d", BeginTime.month, BeginTime.day)

				-- 计算分隔符和换行符
				if (k - 1) % MatchNum == 0 then
					table.insert(MatchDate, Str)

					if SepCount < SepNum then
						table.insert(MatchDate, "/")
						SepCount = SepCount + 1
					else
						table.insert(MatchDate, "\n")
						SepCount = 0
					end
				end
			end
			-- 把最后一个添加的分隔符或换行符删除
			table.remove(MatchDate, #MatchDate)
		end

		DateStr = table.concat(MatchDate)

		SepCount = 0
		SepNum = 1
		local MatchTime = {}
		for i = 1, MatchNum do
			local MatchTimestamp = MatchesTimestamp[i]
			local BeginTimestamp = MatchTimestamp[1]
			local BeginTime = os.date("*t", BeginTimestamp)
			local Str = string.format("%02d:%02d", BeginTime.hour, BeginTime.min)
			table.insert(MatchTime, Str)

			-- 计算分隔符和换行符
			if SepCount < SepNum then
				table.insert(MatchTime, " ")
				SepCount = SepCount + 1
			else
				table.insert(MatchTime, "\n")
				SepCount = 0
			end
		end
		-- 把最后一个添加的分隔符或换行符删除
		table.remove(MatchTime, #MatchTime)

		TimeStr = table.concat(MatchTime)
	end

	BP_LeagueGameTips_MatchDate = DateStr
	BP_LeagueGameTips_MatchTime = TimeStr
	log("DateStr\n" .. BP_LeagueGameTips_MatchDate, "martinhtma")
	log("TimeStr\n" .. BP_LeagueGameTips_MatchTime, "martinhtma")
end


