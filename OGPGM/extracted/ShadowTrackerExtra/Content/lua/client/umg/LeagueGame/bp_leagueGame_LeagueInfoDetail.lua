--赛季信息
LeagueGameLeagueInfoDetailUI = LeagueGameLeagueInfoDetailUI or {

}

--排行信息
BP_STRUCT_GameLeagueInfoRankInfo = {
	rank = 0,	--排名
	name = "",	--战队名字
	icon = 0,	--队旗icon
	score = 0,	--积分
	win = 0,	--吃鸡数
	kill = 0, 	--击杀数
	groupId = 0,--小组ID
	group_rank_no = 0,--分组排行
}

BP_ARRAY_GameLeagueInfoRankInfoDetailList = {
	BP_STRUCT_GameLeagueInfoRankInfo = _G.BP_STRUCT_GameLeagueInfoRankInfo;
}

BP_GameLeagueInfoRankInfoDetail_Mode = "";
BP_GameLeagueInfoRankInfoDetail_Zone = "";


--注册Widget
function bp_leagueGame_LeagueInfoDetail_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_leagueGame_LeagueInfoDetail,
        {{Path="/Game/UMG/UI_Logic/LeagueGame/LeagueGame_LeagueInfoDetail_BP.LeagueGame_LeagueInfoDetail_BP_C", Container="Default", ZOrder=BP_ENUM_UI_LEAGUEGAME_LOBBY+3}},
        {"Lobby"},
        false,
        false,
        true
    );
end


function LeagueGameLeagueInfoDetailUI.Init(zoneid, stageid, modeid, groupId, roundId, zoneName, modeName)
	BP_GameLeagueInfoRankInfoDetail_Zone = zoneName;
	BP_GameLeagueInfoRankInfoDetail_Mode = modeName;
	LeagueGameLeagueInfoDetailUI.GetRankInfoDetail(zoneid, stageid, modeid, groupId, roundId);
end

function LeagueGameLeagueInfoDetailUI.Release()

end

function LeagueGameLeagueInfoDetailUI.GetRankInfoDetail(zoneid, stageid, modeid, groupId, roundId)
	LeagueGameLeagueInfo.league_battle_situation_req(zoneid, stageid, modeid, groupId, roundId);
end

function LeagueGameLeagueInfoDetailUI.SetData()
	BP_ARRAY_GameLeagueInfoRankInfoDetailList = {};
	if LeagueGameLeagueInfo.Situation_detail then
		for k, v in pairs(LeagueGameLeagueInfo.Situation_detail) do
			local item = {}
			if v.battle_res then
				item.score = v.battle_res.score;
				item.rank = v.battle_res.team_rank;
				item.kill = 0;
				if v.battle_res.kill then
					for _k, _v in pairs(v.battle_res.kill) do
						item.kill = item.kill + _v;	
					end
				end
			end
			if v.team_summary then
				if not v.team_summary.name then
					v.team_summary.name = Client.GetTableData("LocalizeRes", 6241).TextValue;
				end
				item.name = v.team_summary.name;
				if not v.team_summary.team_flag then
					v.team_summary.team_flag = 1;
				end
				item.icon = v.team_summary.team_flag;
			end
			table.insert(BP_ARRAY_GameLeagueInfoRankInfoDetailList, item);
		end
	end
	if BP_ARRAY_GameLeagueInfoRankInfoDetailList and #BP_ARRAY_GameLeagueInfoRankInfoDetailList > 0 then
		table.sort(BP_ARRAY_GameLeagueInfoRankInfoDetailList, function(a, b) return a.rank < b.rank end);
	end
	LeagueGameLeagueInfoDetailUI.Show();
end


function LeagueGameLeagueInfoDetailUI.Show()
	LuaClassObj.HandleDynamicCreation(bp_leagueGame_LeagueInfoDetail);
 	LuaClassObj.HandleUIMessage(bp_leagueGame_LeagueInfoDetail, "UIShow");
end

function LeagueGameLeagueInfoDetailUI.Hide()
 	LuaClassObj.HandleUIMessageNoFetch(bp_leagueGame_LeagueInfoDetail, "UIHide");
end


