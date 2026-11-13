--[[
  个人信息历史战绩详情的相关逻辑
]]--

RoleInfoHistoryDetailSystem = RoleInfoHistoryDetailSystem or
{
	HistoryRecordDetail = {};
	HistoryTeammateInfoList = {};
	HistoryRadarInfo = {};
}

function RoleInfoHistoryDetailSystem.Enter(history_record)
	log("RoleInfoHistoryDetailSystem Enter");
	RoleInfoHistoryDetailSystem.HistoryRecordDetail = {};
	RoleInfoHistoryDetailSystem.HistoryTeammateInfoList = {};
	RoleInfoHistoryDetailSystem.HistoryRadarInfo = {};
	
	RoleInfoHistoryDetailSystem.SetHistoryDetailData(history_record);
end

function RoleInfoHistoryDetailSystem.Release()
	log("RoleInfoHistoryDetailSystem Release");
	RoleInfoHistoryDetailSystem.HistoryRecordDetail = {};
	RoleInfoHistoryDetailSystem.HistoryTeammateInfoList = {};
	RoleInfoHistoryDetailSystem.HistoryRadarInfo = {};
end

function RoleInfoHistoryDetailSystem.SetHistoryDetailData(history_record)
	log("RoleInfoHistoryDetailSystem SetHistoryDetailData");
	
	log("set RoleInfoHistoryDetailSystem.HistoryRecordDetail");
	RoleInfoHistoryDetailSystem.HistoryRecordDetail =
	{
		battle_id = history_record.battle_id,
		battle_type = history_record.battle_type,
		battle_time = history_record.time,
		person_rank = history_record.person_rank,
		total_player_count = history_record.TotalPlayerCount,
		team_rank = history_record.team_rank,
		total_team_count = history_record.TotalTeamCount,
		rating = history_record.rating,
		change_rating = history_record.change_rating,
		change_kill_rating = history_record.change_kill_rating,
		change_win_rating = history_record.change_win_rating,
		segment = history_record.segment,
		reason = history_record.Reason,
		add_exp = history_record.add_exp,
		add_gold = history_record.add_gold,
		final_level = history_record.final_level,
		final_score = "0",
		reason_result = "",
		battle_typename = "",
		wisdom = "",
		is_solo = false,
		is_segment_protect = false,
	};
	if history_record.Reason == "win" then
		local data = Client.GetTableData("LocalizeRes", 301334);
		RoleInfoHistoryDetailSystem.HistoryRecordDetail["reason_result"] = data.TextValue;
	elseif history_record.Reason == "dead" then
		local data = Client.GetTableData("LocalizeRes", 301335);
		RoleInfoHistoryDetailSystem.HistoryRecordDetail["reason_result"] = data.TextValue;
	end
	
	if history_record.final_score ~= nil and type(history_record.final_score) == "number" then
		RoleInfoHistoryDetailSystem.HistoryRecordDetail["final_score"] = string.format("%.1f", history_record.final_score);
	end
	
	local match_data = Client.GetTableData("MatchModeTable", history_record.battle_type);
	if match_data ~= nil then
		local MaxTeamPlayerNum = match_data.MaxTeamPlayerNum;
		if MaxTeamPlayerNum == 1 then
			RoleInfoHistoryDetailSystem.HistoryRecordDetail["is_solo"] = true;
		end
		local function localText(id)
			if id then
				local data = Client.GetTableData("LocalizeRes",id);
				if data then
					return data.TextValue;
				end
			end
			return "";
		end
		local function get_bt(sub_mode)
			if sub_mode then
				local cfg_sub_mode = Client.GetTableData("BTMode", sub_mode);
				if cfg_sub_mode then
					return string.format("%s%s", localText(match_data.WordsToShowID), localText(cfg_sub_mode.ModeName));
				end
			end
			return "";
		end
		if type(history_record.sub_mode) == "number" then
			RoleInfoHistoryDetailSystem.HistoryRecordDetail["battle_typename"] = get_bt(history_record.sub_mode);
		else
			--老数据
			local tmp = {
				[101] = 1001,
				[102] = 1002,
				[103] = 1003,
			};
			RoleInfoHistoryDetailSystem.HistoryRecordDetail["battle_typename"] = get_bt(tmp[history_record.battle_type]);
		end
	end
	
	local wisdom_data = Client.GetTableData("ResultTips", history_record.famous_id);
	if wisdom_data ~= nil then
		RoleInfoHistoryDetailSystem.HistoryRecordDetail["wisdom"] = wisdom_data.tipsString;
	end
	
	if history_record.segment_protect ~= nil and type(history_record.segment_protect) == "boolean" then
		RoleInfoHistoryDetailSystem.HistoryRecordDetail["is_segment_protect"] = history_record.segment_protect;
		-- if history_record.segment_protect == true then
			-- log("11111111111111111111111111111111111111111111111");
		-- else
			-- log("22222222222222222222222222222222222222222222222");
		-- end
	-- else
		-- if history_record.segment_protect == nil then
			-- log("33333333333333333333333333333333333333333333333");
		-- else
			-- log("44444444444444444444444444444444444444444444444");
		-- end
	end
	
	
	
	log("set RoleInfoHistoryDetailSystem.HistoryTeammateInfoList");
	for i=1,#history_record.TeammateList do
		local teammate_info = history_record.TeammateList[i];
		RoleInfoHistoryDetailSystem.HistoryTeammateInfoList[i] =
		{
			name = teammate_info.Name,
			uid = tostring(teammate_info.UID),
			damage_amount = 0,
			assist_num = teammate_info.AssistNum,
			survive_time = "0",
			kill = teammate_info.Kill,
			heal_amount = 0,
			BP_ARRAY_TitleIDList = teammate_info.title_id,
			final_score = "0",
			is_mvp = teammate_info.IsMVP,
			gender = teammate_info.rela_sex,
			is_friend = false,
		};
		if type(teammate_info.title_id) ~= "table" then
			RoleInfoHistoryDetailSystem.HistoryTeammateInfoList[i]["BP_ARRAY_TitleIDList"] = {};
		end
		if teammate_info.IsMVP == nil then
			RoleInfoHistoryDetailSystem.HistoryTeammateInfoList[i]["is_mvp"] = false;
		end
		if teammate_info.DamageAmount ~= nil and type(teammate_info.DamageAmount) == "number" then
			RoleInfoHistoryDetailSystem.HistoryTeammateInfoList[i]["damage_amount"] = math.floor(teammate_info.DamageAmount);
		end
		if teammate_info.surviveTime ~= nil and type(teammate_info.surviveTime) == "number" then
			RoleInfoHistoryDetailSystem.HistoryTeammateInfoList[i]["survive_time"] = string.format("%.1f", teammate_info.surviveTime/60);
		end
		if teammate_info.HealAmount ~= nil and type(teammate_info.HealAmount) == "number" then
			RoleInfoHistoryDetailSystem.HistoryTeammateInfoList[i]["heal_amount"] = math.floor(teammate_info.HealAmount);
		end
		if teammate_info.FinalScore ~= nil and type(teammate_info.FinalScore) == "number" then
			RoleInfoHistoryDetailSystem.HistoryTeammateInfoList[i]["final_score"] = string.format("%.1f", teammate_info.FinalScore);
		end
		
		if tostring(teammate_info.UID) == DataMgr.roleData.uid then
			RoleInfoHistoryDetailSystem.HistoryTeammateInfoList[i]["is_friend"] = true;
		else
			for k,v in pairs(ID_INNER_FRIENDLIST) do
				if tostring(v) == tostring(teammate_info.UID) then
					RoleInfoHistoryDetailSystem.HistoryTeammateInfoList[i]["is_friend"] = true;
				end
			end
		end
	end
	
	
	
	log("set RoleInfoHistoryDetailSystem.HistoryRadarInfo");
	RoleInfoHistoryDetailSystem.HistoryRadarInfo =
	{
		survive_score = "0",
		kill_score = "0",
		supply_score = "0",
		hurt_score = "0",
		support_score = "0",
	};
	if history_record.radar.SurviveScore ~= nil and type(history_record.radar.SurviveScore) == "number" then
		RoleInfoHistoryDetailSystem.HistoryRadarInfo["survive_score"] = string.format("%.1f", history_record.radar.SurviveScore);
	end
	if history_record.radar.KillScore ~= nil and type(history_record.radar.KillScore) == "number" then
		RoleInfoHistoryDetailSystem.HistoryRadarInfo["kill_score"] = string.format("%.1f", history_record.radar.KillScore);
	end
	if history_record.radar.SupplyScore ~= nil and type(history_record.radar.SupplyScore) == "number" then
		RoleInfoHistoryDetailSystem.HistoryRadarInfo["supply_score"] = string.format("%.1f", history_record.radar.SupplyScore);
	end
	if history_record.radar.HurtScore ~= nil and type(history_record.radar.HurtScore) == "number" then
		RoleInfoHistoryDetailSystem.HistoryRadarInfo["hurt_score"] = string.format("%.1f", history_record.radar.HurtScore);
	end
	if history_record.radar.SupportScore ~= nil and type(history_record.radar.SupportScore) == "number" then
		RoleInfoHistoryDetailSystem.HistoryRadarInfo["support_score"] = string.format("%.1f", history_record.radar.SupportScore);
	end
end

















