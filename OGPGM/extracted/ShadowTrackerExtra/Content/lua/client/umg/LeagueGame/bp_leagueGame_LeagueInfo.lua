--赛季信息
LeagueGameLeagueInfoUI = LeagueGameLeagueInfoUI or {
	ARRAY_RankInfoList = {},
	zoneIdList = {},
	IsEnableToShow = true,
	IsNeedSelecetSelf = false,
	IsInit = false,
}

--模式ID
BP_LeagueInfo_ModeId = 0;
--阶段ID
BP_LeagueInfo_StageId = 0;
--大区index
BP_LeagueInfo_ZoneId = 0;
--组序号（1 - 5）
BP_LeagueInfo_Team = 0;
--轮序号
BP_LeagueInfo_Round = 0;

--对阵信息
BP_STRUCT_GameLeagueInfoGroupInfo = {
	name = "",		--战队名字
	icon = 0,		--队旗icon
	teamid = "",		--战队ID
}

BP_ARRAY_GameLeagueInfoGroupInfoList0 = {
	BP_STRUCT_GameLeagueInfoGroupInfo = _G.BP_STRUCT_GameLeagueInfoGroupInfo;
}

BP_ARRAY_GameLeagueInfoGroupInfoList1 = {
	BP_STRUCT_GameLeagueInfoGroupInfo = _G.BP_STRUCT_GameLeagueInfoGroupInfo;
}

--排行信息
BP_STRUCT_GameLeagueInfoRankInfo = {
	rank = 0,	--排名
	name = "",	--战队名字
	icon = 1,	--队旗icon
	score = 0,	--积分
	win = 0,	--吃鸡数
	kill = 0, 	--击杀数
	groupId = 0,--小组ID 
	group_rank_no = 0,--分组排行
}


BP_ARRAY_GameLeagueInfoRankInfoList = {
	BP_STRUCT_GameLeagueInfoRankInfo = _G.BP_STRUCT_GameLeagueInfoRankInfo;
}

BP_ARRAY_GameLeagueInfoRankInfoListA = {
	BP_STRUCT_GameLeagueInfoRankInfo = _G.BP_STRUCT_GameLeagueInfoRankInfo;
}

BP_ARRAY_GameLeagueInfoRankInfoListB = {
	BP_STRUCT_GameLeagueInfoRankInfo = _G.BP_STRUCT_GameLeagueInfoRankInfo;
}

BP_ARRAY_GameLeagueInfoRankInfoListC = {
	BP_STRUCT_GameLeagueInfoRankInfo = _G.BP_STRUCT_GameLeagueInfoRankInfo;
}

BP_ARRAY_GameLeagueInfoRankInfoListD = {
	BP_STRUCT_GameLeagueInfoRankInfo = _G.BP_STRUCT_GameLeagueInfoRankInfo;
}

BP_ARRAY_GameLeagueInfoRankInfoListE = {
	BP_STRUCT_GameLeagueInfoRankInfo = _G.BP_STRUCT_GameLeagueInfoRankInfo;
}

--战况信息
BP_STRUCT_GameLeagueInfoSummaryInfo = {
	name = "",
	icon = 0,
	roundId = 0,	--第几轮
	groupId = 0,
    teamRank = 0,
}

BP_ARRAY_GameLeagueInfoSummaryInfoList = {
	BP_STRUCT_GameLeagueInfoSummaryInfo = _G.BP_STRUCT_GameLeagueInfoSummaryInfo;
}

--队伍选择
BP_ARRAY_GameLeagueInfoTeamNameList = {
	name = "",
}

--模式选择
BP_ARRAY_GameLeagueInfoModeSelect = {
	name = "",
}

--区服选择
BP_ARRAY_GameLeagueInfoZoneSelect = {
	name = "",
}

--当前选择的tab index
BP_CurrentLeagueInfoSelectTab_index = 0;

--当前选择模式的index
BP_CurrentLeagueInfoSelectModel_index = 0;

--我的戰隊信息
BP_STRUCT_GameLeagueInfoSelfTeamInfo = {
	rank = 0,
	name = "",
	score = 0,
	icon = 0,
	kill = 0,
}

--概要查看详情的groupId,
BP_CurrentLeagueInfoGroupId = 0;
--概要查看详情的roundId,
BP_CurrentLeagueInfoRoundId = 0;


BP_GameLeagueInfo_SignUpState = 0;	-- 设置报名状态

BP_GameLeagueInfo_SelfTeamId = "";	--	自己的战队ID

BP_LeagueInfo_SelfGroupId = 0	-- 自己的组别ID

BP_LeagueInfo_IsAdvance = false;	--保存是否晋级

local _preShowCallback
local _postShowCallback

--注册Widget
function bp_leagueGame_LeagueInfo_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_leagueGame_LeagueInfo,
        {{Path="/Game/UMG/UI_Logic/LeagueGame/LeagueGame_LeagueInfo_BP.LeagueGame_LeagueInfo_BP_C", Container="Default", ZOrder=BP_ENUM_UI_LEAGUEGAME_LOBBY+2}},
        {"Lobby"},
        false,
		bp_leagueGame_LeagueInfo_OnModeSwitched ~= nil,
        true
    );
end

function bp_leagueGame_LeagueInfo_OnModeSwitched(gamestatus)
	log("bp_leagueGame_LeagueInfo_OnModeSwitched gamestatus = " .. gamestatus);
	if string.lower(gamestatus) == "lobby" then
		
	elseif string.lower(gamestatus) == "fighting" then
		LeagueGameLeagueInfoUI.Release()
        --LeagueGameSystem.ResetData()
        LeagueGameLeagueInfo.ResetData()
	elseif string.lower(gamestatus) == "login" then
		LeagueGameLeagueInfoUI.Release()
		--LeagueGameSystem.ResetData()
		LeagueGameLeagueInfo.ResetData()
	end
end

function LeagueGameLeagueInfoUI.Init(preShowCallback, postShowCallback)
	_preShowCallback = preShowCallback
	_postShowCallback = postShowCallback

	EventSystem:registEvent(EVENTTYPE_LEAGUEGAME, EVENTID_LEAGUEGAME_RANKDATE_UPDATE, LeagueGameLeagueInfoUI.SetRankInfoData);

	BP_LeagueInfo_ModeId = LeagueGameSystem.LEAGUE_TPP_MODE;
	BP_CurrentLeagueInfoSelectModel_index = 0;
	BP_LeagueInfo_StageId = LeagueGameSystem.StageId;
	BP_LeagueInfo_ZoneId = 0;
	BP_LeagueInfo_Team = 1;
	BP_LeagueInfo_SelfGroupId = 0
	LeagueGameLeagueInfoUI.SelfTeamInfo = {}
	LeagueGameLeagueInfoUI.IsNeedSelecetSelf = true;
	BP_GameLeagueInfo_SignUpState = LeagueGameSystem.signUpState;
	LeagueGameLeagueInfoUI.SetData();
	LeagueGameLeagueInfoUI.SetTeamName();
	if BP_LeagueInfo_StageId == LeagueGameSystem.LEAGUE_STAGE_FIRST_MATCH then
		--海选赛
		BP_CurrentLeagueInfoSelectTab_index = 2;
		LeagueGameLeagueInfoUI.GetRankInfo();
	else
		--总决赛没有分组，只有一组
		if BP_LeagueInfo_StageId == LeagueGameSystem.LEAGUE_STAGE_ZONE_FINAL_MATCH then
			BP_LeagueInfo_Team = 1;
		end
		--小组赛，总决赛
		LeagueGameLeagueInfoUI.GetGroupInfo();
		LeagueGameLeagueInfoUI.GetRankInfo();
		if BP_CurrentLeagueInfoSelectTab_index == 1 then
			LeagueGameLeagueInfoUI.GetSummaryInfo();
		end
		if LeagueGameLeagueInfoUI.IsInit == false then
			BP_CurrentLeagueInfoSelectTab_index = 0;
		end
	end

	--报名状态
	if BP_GameLeagueInfo_SignUpState == 1 then
		--判断是否晋级
		if LeagueGameSystem.StageId >= LeagueGameSystem.LEAGUE_STAGE_FIRST_MATCH
				and LeagueGameSystem.StageId <= LeagueGameSystem.LEAGUE_STAGE_ZONE_FINAL_MATCH then
			if LeagueGameSystem.Ispromote == false
					and LeagueGameSystem.StageId > LeagueGameSystem.LEAGUE_STAGE_FIRST_MATCH then
				BP_LeagueInfo_IsAdvance = false;
			else
				BP_LeagueInfo_IsAdvance = true;
			end
		end
	end
	
	
	local stage = LeagueGameLeagueInfoUI.GetRankStageReq();

	--初始化請求
	if stage == LeagueGameSystem.LEAGUE_STAGE_FIRST_MATCH then
		LeagueGameLeagueInfo.get_carteam_league_rank_no_req(LeagueGameLeagueInfoUI.zoneIdList[BP_LeagueInfo_ZoneId + 1], stage, BP_LeagueInfo_ModeId, LeagueGameLeagueInfo.rank_type_league_score);
	end

	LeagueGameLeagueInfoUI.IsInit = true
end

function LeagueGameLeagueInfoUI.Release()
	EventSystem:unregistEvent(EVENTTYPE_LEAGUEGAME, EVENTID_LEAGUEGAME_RANKDATE_UPDATE, LeagueGameLeagueInfoUI.SetRankInfoData);
	LeagueGameLeagueInfoUI.IsInit = false
end

--当stage为分区决赛之后和清榜阶段之前时，用决赛的stage拉取数据
function LeagueGameLeagueInfoUI.GetRankStageReq()
	local StageReq = BP_LeagueInfo_StageId;
	if BP_LeagueInfo_StageId == LeagueGameSystem.LEAGUE_STAGE_GLOBAL_FINAL_MATCH or BP_LeagueInfo_StageId == LeagueGameSystem.LEAGUE_STAGE_REWARD then
		StageReq = LeagueGameSystem.LEAGUE_STAGE_ZONE_FINAL_MATCH;
	end
	return StageReq;
end

function LeagueGameLeagueInfoUI.GetGroupInfo()
	log("BP_LeagueInfo_ZoneId .." .. BP_LeagueInfo_ZoneId)
	log("BP_LeagueInfo_StageId .." .. BP_LeagueInfo_StageId)
	log("BP_LeagueInfo_ModeId .." .. BP_LeagueInfo_ModeId)
	local stage = LeagueGameLeagueInfoUI.GetRankStageReq();
	LeagueGameLeagueInfo.league_group_req(LeagueGameLeagueInfoUI.zoneIdList[BP_LeagueInfo_ZoneId+1], stage, BP_LeagueInfo_ModeId);
end

function LeagueGameLeagueInfoUI.GetRankInfo()
	log("BP_LeagueInfo_ZoneId .." .. BP_LeagueInfo_ZoneId)
	log("BP_LeagueInfo_StageId .." .. BP_LeagueInfo_StageId)
	log("BP_LeagueInfo_ModeId .." .. BP_LeagueInfo_ModeId)
	log("LeagueGameLeagueInfo.rank_type_league_score .." .. LeagueGameLeagueInfo.rank_type_league_score)
	local stage = LeagueGameLeagueInfoUI.GetRankStageReq();
	LeagueGameLeagueInfo.league_rank_info_req(LeagueGameLeagueInfoUI.zoneIdList[BP_LeagueInfo_ZoneId+1], stage, BP_LeagueInfo_ModeId, LeagueGameLeagueInfo.rank_type_league_score);
end

function LeagueGameLeagueInfoUI.GetSummaryInfo()
	log("BP_LeagueInfo_ZoneId .." .. BP_LeagueInfo_ZoneId)
	log("BP_LeagueInfo_StageId .." .. BP_LeagueInfo_StageId)
	log("BP_LeagueInfo_ModeId .." .. BP_LeagueInfo_ModeId)
	local stage = LeagueGameLeagueInfoUI.GetRankStageReq();
	LeagueGameLeagueInfo.league_battle_situation_summary_req(LeagueGameLeagueInfoUI.zoneIdList[BP_LeagueInfo_ZoneId+1], stage, BP_LeagueInfo_ModeId);
end

function LeagueGameLeagueInfoUI.SetData()
	BP_ARRAY_GameLeagueInfoModeSelect = {};
	--设置模式下拉
	table.insert(BP_ARRAY_GameLeagueInfoModeSelect, Client.GetTableData("LocalizeRes", 100054).TextValue);	--第三人称
	table.insert(BP_ARRAY_GameLeagueInfoModeSelect, Client.GetTableData("LocalizeRes", 100053).TextValue);	--第一人称
	--设置区服下拉
	if LeagueGameSystem.signUpInfo.zoneList then
		LeagueGameLeagueInfoUI.zoneIdList = {};
		BP_ARRAY_GameLeagueInfoZoneSelect = {};
		for k, zoneId in pairs(LeagueGameSystem.signUpInfo.zoneList) do
			table.insert(LeagueGameLeagueInfoUI.zoneIdList, zoneId);
			local zoneCfg = Client.GetTableData("ZoneConfig", zoneId);
			if zoneCfg ~= nil then
				table.insert(BP_ARRAY_GameLeagueInfoZoneSelect, zoneCfg.NameInChinese);
			end
		end
	end
	BP_GameLeagueInfo_SelfTeamId = BP_STRUCT_AllianceInfo.aid or "";
	if LeagueGameSystem.apply_info then
		BP_LeagueInfo_ModeId = LeagueGameSystem.apply_info.apply_mode;
		if BP_LeagueInfo_ModeId == LeagueGameSystem.LEAGUE_TPP_MODE then
			BP_CurrentLeagueInfoSelectModel_index = 0;
		else
			BP_CurrentLeagueInfoSelectModel_index = 1;
		end
		if LeagueGameLeagueInfoUI.zoneIdList then
			for _k, _v in pairs(LeagueGameLeagueInfoUI.zoneIdList) do
				if _v == LeagueGameSystem.apply_info.apply_zone then
					BP_LeagueInfo_ZoneId = _k - 1;
				end
			end
		end
	end
end

function LeagueGameLeagueInfoUI.SetRankInfoData()
	if BP_LeagueInfo_StageId <  LeagueGameSystem.LEAGUE_STAGE_TOP_CLEAR then
		LeagueGameLeagueInfoUI.ARRAY_RankInfoList = {};
		BP_STRUCT_GameLeagueInfoRankInfo = {};
		BP_ARRAY_GameLeagueInfoRankInfoList = {};
		if LeagueGameLeagueInfo.Rank_info then
			for k,v in pairs(LeagueGameLeagueInfo.Rank_info) do
				local item = {};
				item.rank = v.rank;
				if not v.team_summary.name then
					v.team_summary.name = Client.GetTableData("LocalizeRes", 6241).TextValue;
				end
				if not v.team_summary.team_flag then
					v.team_summary.team_flag = 1;
				else
					v.team_summary.team_flag = tonumber(v.team_summary.team_flag);
				end
				if not v.team_summary.team_flag then
					v.team_summary.team_flag = 1;
				end
				item.name = v.team_summary.name;
				item.icon = v.team_summary.team_flag;
				item.score = v.sum_score;
				item.win = v.sum_final_win;
				local kill = 0
				if not v.sum_kill then
					kill = 0;
				else
					for _k, _v in pairs(v.sum_kill) do
						kill = kill + _v;
					end
				end
				item.kill = kill;
				item.groupId = v.group_id;
				item.group_rank_no = v.group_rank_no;
				table.insert(LeagueGameLeagueInfoUI.ARRAY_RankInfoList, item);
				--设置自己的信息
				if tostring(v.team_id) == tostring(BP_STRUCT_AllianceInfo.aid) then
					LeagueGameLeagueInfoUI.SelfTeamInfo = item
				end
			end
		end
		if BP_LeagueInfo_StageId == LeagueGameSystem.LEAGUE_STAGE_FIRST_MATCH then
			--海选赛
			BP_ARRAY_GameLeagueInfoRankInfoList = LeagueGameLeagueInfoUI.ARRAY_RankInfoList;
			--log_tree("BP_ARRAY_GameLeagueInfoRankInfoList", BP_ARRAY_GameLeagueInfoRankInfoList);
			--[[
			BP_ARRAY_GameLeagueInfoRankInfoList0 = {};
			BP_ARRAY_GameLeagueInfoRankInfoList1 = {};
			for kk, vv in pairs(LeagueGameLeagueInfoUI.ARRAY_RankInfoList) do
				if math.fmod(vv.rank, 2) == 1 then
					table.insert(BP_ARRAY_GameLeagueInfoRankInfoList0, vv);
				else
					table.insert(BP_ARRAY_GameLeagueInfoRankInfoList1, vv);
				end
			end
			]]
		elseif BP_LeagueInfo_StageId == LeagueGameSystem.LEAGUE_STAGE_GROUP_MATCH then
			--小组赛
			BP_ARRAY_GameLeagueInfoRankInfoList = {};
			for _k, _v in pairs(LeagueGameLeagueInfoUI.ARRAY_RankInfoList) do
				if _v.groupId == BP_LeagueInfo_Team then
					table.insert(BP_ARRAY_GameLeagueInfoRankInfoList, _v);
				end
			end
			LeagueGameLeagueInfoUI.SetLeagueInfoSelfTeamInfo()
		elseif BP_LeagueInfo_StageId >= LeagueGameSystem.LEAGUE_STAGE_ZONE_FINAL_MATCH and BP_LeagueInfo_StageId < LeagueGameSystem.LEAGUE_STAGE_TOP_CLEAR  then
			--总决赛
			BP_ARRAY_GameLeagueInfoRankInfoList = {};
			for _k, _v in pairs(LeagueGameLeagueInfoUI.ARRAY_RankInfoList) do
				if _v.groupId == BP_LeagueInfo_Team then
					table.insert(BP_ARRAY_GameLeagueInfoRankInfoList, _v);
				end
			end
			LeagueGameLeagueInfoUI.SetLeagueInfoSelfTeamInfo()
		end

		--log_tree("BP_ARRAY_GameLeagueInfoRankInfoList", BP_ARRAY_GameLeagueInfoRankInfoList);
		LeagueGameLeagueInfoUI.Show();
	end
end

function LeagueGameLeagueInfoUI.SetSelfGroupId()
	local id = 0
	if LeagueGameLeagueInfo.GroupInfo then
		for _k, _v in pairs(LeagueGameLeagueInfo.GroupInfo) do
			if tostring(_k) == BP_STRUCT_AllianceInfo.aid then
				id = _v.group_id;
			end
		end
	end
	BP_LeagueInfo_SelfGroupId = tonumber(id)
end

function LeagueGameLeagueInfoUI.SetInitGroupId()
	if BP_LeagueInfo_SelfGroupId < 1 then
		BP_LeagueInfo_Team = 1
	else
		BP_LeagueInfo_Team = BP_LeagueInfo_SelfGroupId
	end
end

function LeagueGameLeagueInfoUI.SetGroupData()
	BP_ARRAY_GameLeagueInfoGroupInfoList0 = {};
	BP_ARRAY_GameLeagueInfoGroupInfoList1 = {};
	if LeagueGameLeagueInfoUI.IsNeedSelecetSelf then
		-- 要先设置自己的组别才能设置初始显示的组别
		LeagueGameLeagueInfoUI.SetSelfGroupId()
		LeagueGameLeagueInfoUI.SetInitGroupId()

		LeagueGameLeagueInfoUI.IsNeedSelecetSelf = false;
	end
	
	if LeagueGameLeagueInfo.Group_info then
		local teamInfo = LeagueGameLeagueInfo.Group_info[BP_LeagueInfo_Team];
		--log_tree("teamInfo", teamInfo);
		if teamInfo then
			for k, v in pairs(teamInfo) do
				local item = {};
				if not v.name then
					v.name = Client.GetTableData("LocalizeRes", 6241).TextValue;
				end
				item.name = v.name;
				if not v.team_flag then
					v.team_flag = 1;
				else
					v.team_flag = tonumber(v.team_flag);
				end
				if not v.team_flag then
					v.team_flag = 1;
				end

				item.icon = v.team_flag; 
				item.teamid = tostring(v.team_id);
				--log("item.teamid .." .. item.teamid);
				if math.fmod(v.seat_id, 2) == 1 then
					table.insert(BP_ARRAY_GameLeagueInfoGroupInfoList0, item);
				else
					table.insert(BP_ARRAY_GameLeagueInfoGroupInfoList1, item);
				end
			end
		end
	end
	--log_tree("BP_ARRAY_GameLeagueInfoGroupInfoList0", BP_ARRAY_GameLeagueInfoGroupInfoList0);
	--log_tree("BP_ARRAY_GameLeagueInfoGroupInfoList1", BP_ARRAY_GameLeagueInfoGroupInfoList1);
	LeagueGameLeagueInfoUI.Show();
end

function LeagueGameLeagueInfoUI.SetSummaryData()
	BP_ARRAY_GameLeagueInfoSummaryInfoList = {}
	log_tree("LeagueGameLeagueInfo.Situation_summary", LeagueGameLeagueInfo.Situation_summary);
	if LeagueGameLeagueInfo.Situation_summary then
		for k, v in pairs(LeagueGameLeagueInfo.Situation_summary) do
			for _k, _v in pairs(v) do
				if _v.group_id == BP_LeagueInfo_Team then
					local item = {};
					item.groupId = _v.group_id;
					item.roundId = _v.round_id;
					if not _v.team_summary.name then
						_v.team_summary.name = Client.GetTableData("LocalizeRes", 6241).TextValue;
					end
					item.name = _v.team_summary.name;
					if not _v.team_summary.team_flag then
						_v.team_summary.team_flag = 1;
					else
						_v.team_summary.team_flag = tonumber(_v.team_summary.team_flag);
					end
					if not _v.team_summary.team_flag then
						_v.team_summary.team_flag = 1;
					end
					item.icon = _v.team_summary.team_flag;

                    item.teamRank = 1;
                    if _v.battle_res then
                        if _v.battle_res.team_rank then
                            item.teamRank = _v.battle_res.team_rank;
                        end
                    end
					--log_tree("itemitemitemitem",item )
					table.insert(BP_ARRAY_GameLeagueInfoSummaryInfoList, item);
				end
			end
		end
	end
	--log_tree("BP_ARRAY_GameLeagueInfoSummaryInfoList", BP_ARRAY_GameLeagueInfoSummaryInfoList);
	LeagueGameLeagueInfoUI.Show();
end

function LeagueGameLeagueInfoUI.Show()
	LuaClassObj.HandleDynamicCreation(bp_leagueGame_LeagueInfo);

	if LeagueGameLeagueInfoUI.IsEnableToShow then
		if _preShowCallback ~= nil and type(_preShowCallback) == "function" then
			_preShowCallback()
		end
		_preShowCallback = nil

		EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN);
		-- LobbyUI:ShowLobbyPlayer(false);
		LeagueGameLobbyUI.Show_CallBack();
		LuaClassObj.HandleUIMessage(bp_leagueGame_LeagueInfo, "UIShow");

		if _postShowCallback ~= nil and type(_postShowCallback) == "function" then
			_postShowCallback()
		end
		_postShowCallback = nil
	end
end

function LeagueGameLeagueInfoUI.Hide()
 	LuaClassObj.HandleUIMessageNoFetch(bp_leagueGame_LeagueInfo, "UIHide");
end

function LeagueGameLeagueInfoUI.SetTeamName()
	BP_ARRAY_GameLeagueInfoTeamNameList = {};
	for id=6033,6037 do
		local data = Client.GetTableData("LocalizeRes",id);
        if data then
           table.insert(BP_ARRAY_GameLeagueInfoTeamNameList, data.TextValue); 
        end
	end
	--log_tree("BP_ARRAY_GameLeagueInfoTeamNameList", BP_ARRAY_GameLeagueInfoTeamNameList);
end


function LeagueGameLeagueInfoUI.SetLeagueInfoSelfTeamInfo()
	log_tree("LeagueGameSystem.competing_info", LeagueGameSystem.competing_info);
	BP_STRUCT_GameLeagueInfoSelfTeamInfo.rank = 0
	BP_STRUCT_GameLeagueInfoSelfTeamInfo.score = 0
	BP_STRUCT_GameLeagueInfoSelfTeamInfo.kill = 0

	local stage = LeagueGameLeagueInfoUI.GetRankStageReq()
	if stage == LeagueGameSystem.LEAGUE_STAGE_FIRST_MATCH then
		BP_STRUCT_GameLeagueInfoSelfTeamInfo.rank = LeagueGameLeagueInfo.rank_no;
		if LeagueGameSystem.competing_info ~= nil and LeagueGameSystem.competing_info[BP_LeagueInfo_StageId] then
			log(LeagueGameSystem.competing_info[BP_LeagueInfo_StageId].score)
			BP_STRUCT_GameLeagueInfoSelfTeamInfo.score = LeagueGameSystem.competing_info[BP_LeagueInfo_StageId].score or 0;
			if LeagueGameSystem.competing_info[BP_LeagueInfo_StageId].game_res then
				local kill = 0;
				for k, v in pairs(LeagueGameSystem.competing_info[BP_LeagueInfo_StageId].game_res) do
					if v.kill then
						for _k, _v in pairs(v.kill) do
							kill = kill + _v;
						end
					end
				end
				BP_STRUCT_GameLeagueInfoSelfTeamInfo.kill = kill;
			else
				BP_STRUCT_GameLeagueInfoSelfTeamInfo.kill = 0;
			end
		end
	else
		if LeagueGameLeagueInfoUI.SelfTeamInfo then
			if stage == LeagueGameSystem.LEAGUE_STAGE_GROUP_MATCH then
				BP_STRUCT_GameLeagueInfoSelfTeamInfo.rank = LeagueGameLeagueInfoUI.SelfTeamInfo.group_rank_no or 0
				log("xxxxxxxxxxxxxxxxx:LeagueGameLeagueInfoUI.SelfTeamInfo.group_rank_no: "..tostring(LeagueGameLeagueInfoUI.SelfTeamInfo.group_rank_no))
			else
				BP_STRUCT_GameLeagueInfoSelfTeamInfo.rank = LeagueGameLeagueInfoUI.SelfTeamInfo.rank or 0
				log("xxxxxxxxxxxxxxxxx:LeagueGameLeagueInfoUI.SelfTeamInfo.rank: "..tostring(LeagueGameLeagueInfoUI.SelfTeamInfo.rank))
			end
			log("xxxxxxxxxxxxxxxxx:BP_STRUCT_GameLeagueInfoSelfTeamInfo.rank: "..tostring(BP_STRUCT_GameLeagueInfoSelfTeamInfo.rank))
			BP_STRUCT_GameLeagueInfoSelfTeamInfo.score = LeagueGameLeagueInfoUI.SelfTeamInfo.score or 0
			BP_STRUCT_GameLeagueInfoSelfTeamInfo.kill = LeagueGameLeagueInfoUI.SelfTeamInfo.kill or 0
		end
	end

	BP_STRUCT_GameLeagueInfoSelfTeamInfo.name = BP_STRUCT_AllianceInfo.name;
	AllianceCompetitionSystem.getGuidonUrl();
  	BP_STRUCT_GameLeagueInfoSelfTeamInfo.icon = AllianceCompetitionSystem.GuidonId;
  	--log_tree("BP_STRUCT_GameLeagueInfoSelfTeamInfo", BP_STRUCT_GameLeagueInfoSelfTeamInfo);
 	LuaClassObj.HandleUIMessage(bp_leagueGame_LeagueInfo, "UpdateSelfTeam");
end

function LeagueGameLeagueInfoUI.SetInvisible()
	LeagueGameLeagueInfoUI.IsEnableToShow = false

	LuaClassObj.HandleUIMessage(bp_leagueGame_lobby, "UIHide");
	LuaClassObj.HandleUIMessage(bp_leagueGame_LeagueInfo, "UIHide");
end

function LeagueGameLeagueInfoUI.SetVisible()
	LeagueGameLeagueInfoUI.IsEnableToShow = true

	LeagueGameLeagueInfoUI.Show()
end

--对战信息
function EventLeagueInfoSelectGroup()
	LeagueGameLeagueInfoUI.GetGroupInfo();
end

--显示战况概要
function EventLeagueInfoSelectSummary()
	LeagueGameLeagueInfoUI.GetSummaryInfo();
end

--排行信息
function EventLeagueInfoSelectRank()
	LeagueGameLeagueInfoUI.GetRankInfo();
end


--排行信息详情
function EventLeagueInfoSelectRankDetail()
	
end

--分组信息选择组
function EventLeagueInfoMatchSelectTeam()
	if BP_CurrentLeagueInfoSelectTab_index == 0 then
		LeagueGameLeagueInfoUI.SetGroupData();
	elseif BP_CurrentLeagueInfoSelectTab_index == 1 then
		LeagueGameLeagueInfoUI.SetSummaryData();
	elseif BP_CurrentLeagueInfoSelectTab_index == 2 then
		LeagueGameLeagueInfoUI.GetRankInfo();	
	end
end

--选择模式
function EventLeagueInfoSelectMode()
	log("BP_CurrentLeagueInfoSelectTab_index .." .. BP_CurrentLeagueInfoSelectTab_index);
	if BP_CurrentLeagueInfoSelectTab_index == 0 then
		LeagueGameLeagueInfoUI.GetGroupInfo();
	elseif BP_CurrentLeagueInfoSelectTab_index == 1 then
		LeagueGameLeagueInfoUI.GetSummaryInfo();	
	elseif BP_CurrentLeagueInfoSelectTab_index == 2 then
		LeagueGameLeagueInfoUI.GetRankInfo();
	end
end

--选择zone
function EventLeagueInfoSelectZone()
	log("BP_CurrentLeagueInfoSelectTab_index .." .. BP_CurrentLeagueInfoSelectTab_index);
	if BP_CurrentLeagueInfoSelectTab_index == 0 then
		LeagueGameLeagueInfoUI.GetGroupInfo();
	elseif BP_CurrentLeagueInfoSelectTab_index == 1 then
		LeagueGameLeagueInfoUI.GetSummaryInfo();	
	elseif BP_CurrentLeagueInfoSelectTab_index == 2 then
		LeagueGameLeagueInfoUI.GetRankInfo();	
	end
end

--tab切换
function EventLeagueInfoTabSelectChange()
	if BP_CurrentLeagueInfoSelectTab_index == 0 then
		LeagueGameLeagueInfoUI.GetGroupInfo();
	elseif BP_CurrentLeagueInfoSelectTab_index == 1 then
		LeagueGameLeagueInfoUI.GetSummaryInfo();	
	elseif BP_CurrentLeagueInfoSelectTab_index == 2 then
		LeagueGameLeagueInfoUI.GetRankInfo();	
	end
end

--点击Item查看详情
function EventLeagueInfoTeamRankDetail()
	--log("BP_CurrentLeagueInfoGroupId.." .. BP_CurrentLeagueInfoGroupId);
	--log("BP_CurrentLeagueInfoRoundId.." .. BP_CurrentLeagueInfoRoundId);
	--log("BP_CurrentLeagueInfoSelectModel_index.." .. BP_CurrentLeagueInfoSelectModel_index);
	--log("zone.." .. BP_ARRAY_GameLeagueInfoZoneSelect[BP_LeagueInfo_ZoneId+1]);
	--log("mode.." .. BP_ARRAY_GameLeagueInfoModeSelect[BP_CurrentLeagueInfoSelectModel_index+1]);
	--log("BP_LeagueInfo_ZoneId.." .. BP_LeagueInfo_ZoneId);
	--log("BP_LeagueInfo_StageId.." .. BP_LeagueInfo_StageId);
	--log("BP_LeagueInfo_ModeId.." .. BP_LeagueInfo_ModeId);
	local zoneName = BP_ARRAY_GameLeagueInfoZoneSelect[BP_LeagueInfo_ZoneId+1];
	local modeName = BP_ARRAY_GameLeagueInfoModeSelect[BP_CurrentLeagueInfoSelectModel_index+1];
	local stage = LeagueGameLeagueInfoUI.GetRankStageReq();
	LeagueGameLeagueInfoDetailUI.Init(LeagueGameLeagueInfoUI.zoneIdList[BP_LeagueInfo_ZoneId+1], stage, BP_LeagueInfo_ModeId, BP_CurrentLeagueInfoGroupId, BP_CurrentLeagueInfoRoundId, zoneName, modeName);
end

function EventLeagueInfoHide()
	LeagueGameLeagueInfoUI.Hide();
	EventLeagueGameLobbyHideUI();
	
  	EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE)
  	LuaClassObj.HandleUIMessage(bp_lobby, "UIShowFromMall");
    -- LobbyUI:ShowLobbyPlayer(true);
	EventSystem:unregistEvent(EVENTTYPE_LEAGUEGAME, EVENTID_LEAGUEGAME_RANKDATE_UPDATE, LeagueGameLeagueInfoUI.SetRankInfoData);
end


function EventLeagueInfoBtnShare()
	if BP_STRUCT_GameLeagueInfoSelfTeamInfo.rank > 0 or BP_STRUCT_GameLeagueInfoSelfTeamInfo.score > 0 then
		LeagueGameShareLeagueInfoUI.Init(BP_STRUCT_GameLeagueInfoSelfTeamInfo.name, BP_STRUCT_GameLeagueInfoSelfTeamInfo.icon,BP_STRUCT_GameLeagueInfoSelfTeamInfo.rank,BP_STRUCT_GameLeagueInfoSelfTeamInfo.score,BP_STRUCT_GameLeagueInfoSelfTeamInfo.kill);
	else
		if BP_LeagueInfo_StageId > LeagueGameSystem.LEAGUE_STAGE_FIRST_MATCH and BP_LeagueInfo_StageId < LeagueGameSystem.LEAGUE_STAGE_GLOBAL_FINAL_MATCH then
			LeagueGameShareAdvanceUI.Init(BP_LeagueInfo_StageId);
		end
	end
end