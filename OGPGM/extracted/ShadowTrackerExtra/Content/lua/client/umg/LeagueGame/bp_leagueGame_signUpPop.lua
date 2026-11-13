--赛事报名
LeagueGameSignUpPopUI = LeagueGameSignUpPopUI or {

}

BP_STRUCT_ZoneItemInfo = {
	id = 0,
	zoneIp = "",
	serverDelay = 999,
}

--[[
BP_STRUCT_MapItemInfo = {
	mapID = 0,
	mapName = "",
}

BP_ARRAY_LeagueGame_SingUpPop_MapList = {
	BP_STRUCT_MapItemInfo = _G.BP_STRUCT_MapItemInfo;
}
]]
BP_ARRAY_LeagueGame_SingUpPop_ZoneListInfo = {
	BP_STRUCT_ZoneItemInfo = _G.BP_STRUCT_ZoneItemInfo;
}

BP_LeagueGame_SingUpPop_ModeFpp_Available = false;
BP_LeagueGame_SingUpPop_ModeTpp_Available = false;

BP_LeagueGame_SingUpPop_SelectMode = 0; 			-- 选择的模式
BP_LeagueGame_SingUpPop_SelectZoneID = 0; 			-- 选择的区服
BP_LeagueGame_SingUpPop_SelectMapName = "";			-- 地图名字-策划说比赛只会指定一个

BP_LeagueGame_SingUpPop_TeamName = "";    			--当前战队名字
BP_LeagueGame_SingUpPop_TeamPlayerTotal = 6;  		--当前战队成员上限
BP_LeagueGame_SingUpPop_TeamPlayerCurrent = 0;  	--当前战队成员数量
BP_LeagueGame_SingUpPop_TeamIcon = 0;     			--当前战队ICON

BP_LeagueGame_SingUpPop_Tips = ""					--报名时间提示
BP_LeagueGame_SingUpPop_Tips2 = ""					--报名时间注意提示

BP_LeagueGameSignUpPop_CostCoin = 0;				--报名花费
--注册Widget
function bp_leagueGame_signUpPop_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_leagueGame_signUpPop,
        {{Path="/Game/UMG/UI_Logic/LeagueGame/LeagueGame_SignUp_BP2.LeagueGame_SignUp_BP2_C", Container="Default", ZOrder=BP_ENUM_UI_LEAGUEGAME_LOBBY+10}},
        {"Lobby"},
        false,
        false,
        true
    );
end


function LeagueGameSignUpPopUI.Init()	
    log("LeagueGameSignUpPopUI.Init");
    LeagueGameSignUpPopUI.SetData();
    LeagueGameSignUpPopUI.Show();
end

function LeagueGameSignUpPopUI.Show()
	LuaClassObj.HandleDynamicCreation(bp_leagueGame_signUpPop);
	LuaClassObj.HandleUIMessage(bp_leagueGame_signUpPop, "UIShow");
end

function LeagueGameSignUpPopUI.Hide()
	LuaClassObj.HandleUIMessage(bp_leagueGame_signUpPop, "UIHide");
end

function LeagueGameSignUpPopUI.Release()
    log("LeagueGameSignUpPopUI.Release");
end

function LeagueGameSignUpPopUI.SetData()
	BP_ARRAY_LeagueGame_SingUpPop_ZoneListInfo = {};
	BP_ARRAY_LeagueGame_SingUpPop_ModeList = {};
	--BP_ARRAY_LeagueGame_SingUpPop_MapList = {};
	--LeagueGameSignUpPopUI.MapID = {};
	local tempZoneList = {};
	local tempMapID = {};
    for k, zoneId in pairs(LeagueGameSystem.signUpInfo.zoneList) do
		local zoneInfoItem = {};
		zoneInfoItem.id = zoneId;
		zoneInfoItem.zoneIp = "";
		zoneInfoItem.serverDelay = 999;
		for i,v in pairs(TeamUpSystem.ChooseZoneList) do
			if v.zone_id == zoneId then
				zoneInfoItem.zoneIp = v.tpingsvr_ip;
				if zoneInfoItem.zoneIp ~= "" then
					zoneInfoItem.serverDelay = Client.GetServerDelay(zoneInfoItem.zoneIp);
				end
			end
		end
		table.insert(BP_ARRAY_LeagueGame_SingUpPop_ZoneListInfo, zoneInfoItem);
		table.insert(tempZoneList, zoneInfoItem);

	end
	for _k,_v in pairs(LeagueGameSystem.signUpInfo.sub_mode) do
		local IsFpp = Client.GetTableData("BTMode", _v).IsFpp;
		local MapId = Client.GetTableData("BTMode", _v).MapID;
		local mapName = Client.GetTableData("Map", MapId).WatchingName;
		BP_LeagueGame_SingUpPop_SelectMapName = mapName;
		--[[
		local MapId = Client.GetTableData("BTMode", _v).MapID;
		local mapName = Client.GetTableData("Map", MapId).WatchingName;
		local mapItem = {};
		mapItem.mapID = MapId;
		mapItem.mapName = mapName;
		if not tempMapID[MapId] then
			tempMapID[MapId] = MapId;
			table.insert(BP_ARRAY_LeagueGame_SingUpPop_MapList, mapItem);
		end
		]]
		--设置模式可用
		if IsFpp == true then
			BP_LeagueGame_SingUpPop_ModeFpp_Available = true;
		else
			BP_LeagueGame_SingUpPop_ModeTpp_Available = true;
		end
	end
	--排序选择网络最好的推荐
	table.sort( tempZoneList, function(a, b) return a.serverDelay < b.serverDelay end );
	BP_LeagueGame_SingUpPop_SelectZoneID = tempZoneList[1].id;
	if BP_LeagueGame_SingUpPop_ModeTpp_Available then
		BP_LeagueGame_SingUpPop_SelectMode = 1;
	else
		BP_LeagueGame_SingUpPop_SelectMode = 0;
	end
	
	if BP_STRUCT_AllianceInfo and BP_STRUCT_AllianceInfo.aid and #BP_STRUCT_AllianceInfo.aid > 0 then
		BP_LeagueGame_SingUpPop_TeamName = BP_STRUCT_AllianceInfo.name;
  		BP_LeagueGame_SingUpPop_TeamPlayerCurrent = BP_STRUCT_AllianceInfo.memberNum;
		if AllianceCompetitionSystem.GuidonId == nil then
			BP_NATION_OPEN_TYPE = CountryareaUI.OPEN_TYPE_GUIDON
			local allNationCode = {};
			for k,v in pairs(Client.GetTable("GuidonConfig")) do
				table.insert(allNationCode, k)
			end

			local data = CountryareaUI.SortNationCode(allNationCode)
			AllianceCompetitionSystem.GuidonId = data[1]
		end
  		BP_LeagueGame_SingUpPop_TeamIcon = AllianceCompetitionSystem.GuidonId;
  	else
  		BP_LeagueGame_SingUpPop_TeamName = "";
  		BP_LeagueGame_SingUpPop_TeamPlayerCurrent = 0;
  		BP_LeagueGame_SingUpPop_TeamIcon = 0;
	end
	--log_tree("BP_ARRAY_LeagueGame_SingUpPop_ZoneListInfo", BP_ARRAY_LeagueGame_SingUpPop_ZoneListInfo);
	--log_tree("BP_ARRAY_LeagueGame_SingUpPop_MapList", BP_ARRAY_LeagueGame_SingUpPop_MapList);
	--log_tree("tempZoneList", tempZoneList);
	BP_LeagueGameSignUpPop_CostCoin = LeagueGameSystem.SignUpCostCoin;
	EventUpdateMatchTips()
end

function EventLeagueGameSignUpPopHide()
	LeagueGameSignUpPopUI.Hide();
end

function EventLeagueGameSignUpSend()
	CommonMessageBoxUI:ShowPanel(2, Client.GetTableData("LocalizeRes", "6031").TextValue, Client.GetTableData("LocalizeRes", "6030").TextValue, function() LeagueGameSignUpPopUI.SendSignUpInfo() end);
	log("BP_LeagueGame_SingUpPop_SelectMode..." .. BP_LeagueGame_SingUpPop_SelectMode);
	log("BP_LeagueGame_SingUpPop_SelectZoneID..." .. BP_LeagueGame_SingUpPop_SelectZoneID);
end

function LeagueGameSignUpPopUI.SendSignUpInfo()
	LeagueGameSignUpPop.SignReq(BP_LeagueGame_SingUpPop_SelectZoneID, BP_LeagueGame_SingUpPop_SelectMode);
	LeagueGameSignUpPopUI.Hide();
end

function EventUpdateMatchTips()
	local Mode = 0
	if BP_LeagueGame_SingUpPop_SelectMode == 0 then
		Mode = LeagueGameSystem.LEAGUE_FPP_MODE
	else
		Mode = LeagueGameSystem.LEAGUE_TPP_MODE
	end

	local MatchInfo = LeagueGameSystem.LeagueTimeTable[LeagueGameSystem.LEAGUE_STAGE_FIRST_MATCH][Mode][BP_LeagueGame_SingUpPop_SelectZoneID]
	local MatchNum = #MatchInfo.match_time
	local MatchTime = {}
	for i = 1, MatchNum do
		local MatchTimestamp = MatchInfo.vaild_match_time_slot[i]
		local BeginTimestamp = MatchTimestamp[1]
		local BeginTime = os.date("*t", BeginTimestamp)
		local Str = string.format("%02d:%02d;", BeginTime.hour, BeginTime.min)
		table.insert(MatchTime, Str)
	end
	local TimeStr = table.concat(MatchTime)

	local TipsPattern = Client.GetTableData("LocalizeRes", 6368).TextValue
	--BP_LeagueGame_SingUpPop_Tips = string.format(TipsPattern, TimeStr)
	BP_LeagueGame_SingUpPop_Tips = string.gsub(TipsPattern, "{0}", tostring(TimeStr));
	BP_LeagueGame_SingUpPop_Tips2 = Client.GetTableData("LocalizeRes", 6367).TextValue
end
