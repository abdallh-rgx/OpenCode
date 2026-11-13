SeasonReviewSystem = SeasonReviewSystem or {
	curReviewUid = "",
}

-- 开启面板必须请求数据
function SeasonReviewSystem.sendGetSeasonReviewSummy(uid)
	SeasonReviewSystem.curReviewUid = uid;
	NetUtil.SendPkg("get_season_file_summy", tonumber(uid));
end

function SeasonReviewSystem.sendGetSeasonFile(uid, seasonId, tabType)
	log("get_season_file uid:"..uid..", seasonId:"..seasonId..", tabType:"..tabType);
	NetUtil.SendPkg("get_season_file", tonumber(uid), seasonId, tabType);
end

function SeasonReviewSystem.OnGetSeasonFileSummyRsp(target_uid, season_file_summy_list)
	log("get_season_file_summy_rsp target_uid:"..target_uid..", count:"..#season_file_summy_list);	
	if tonumber(SeasonReviewSystem.curReviewUid) ~= target_uid then
		return;
	end
	
	--log_tree("season_file_summy_list", season_file_summy_list);
	
	-- test data
	--season_file_summy_list = {};
	--table.insert(season_file_summy_list, {reached_max_segment=302, mode=103});
	--table.insert(season_file_summy_list, {reached_max_segment=302, mode=102});
	--table.insert(season_file_summy_list, {reached_max_segment=701, mode=101});
	
	SeasonReviewUI.InitReviewData(season_file_summy_list);
end

function SeasonReviewSystem.OnGetSeasonFileRsp(ret, target_uid, season_id, record_type, record)
	log("get_season_file_rsp ret:"..ret..", target_uid:"..tostring(target_uid)..", season_id:"..tostring(season_id)..", record_type:"..tostring(record_type));
	if tonumber(SeasonReviewSystem.curReviewUid) ~= target_uid then
		return;
	end
	
	-- test data
	--[[
	ret = "ok";
	record = {};
	if record_type == 1 then
		record = 
		{
		total_rank_rating = 1000,
		tpp_rank = 11,
		tpp_refer_rating = 21,
		solo={ rating = 999, segment = 301, game_num = 11, win_num = 44, top10_count = 77, kd = 1},
		duo={ rating = 888, segment = 202, game_num = 22, win_num = 55, top10_count = 88, kd = 2},
		squad={ rating = 777, segment = 701, game_num = 33, win_num = 66, top10_count = 99, kd = 3},
		fpp_total_rank_rating = 2000,
		fpp_rank = 22,
		fpp_refer_rating = 33,
		fppsolo={ rating = 9999, segment = 101, game_num = 121, win_num = 434, top10_count = 717, kd = 14},
		fppduo={ rating = 8889, segment = 402, game_num = 222, win_num = 535, top10_count = 828, kd = 25},
		fppsquad={ rating = 7797, segment = 601, game_num = 313, win_num = 636, top10_count = 993, kd = 33},
	  }
	elseif record_type == 2 then
		record[21] = {num = 10};
		record[4] = {num = 11};
		record[6] = {num = 12};
		record[8] = {num = 13};
		record[5] = {num = 14};
		record[2] = {num = 15};
		record[12] = {num = 16};
		record[22] = {num = 17};
	else
		return;
	end
	]]--
	if ret == "ok" then		
		SeasonReviewUI.UpdatePageData(target_uid, season_id, record_type, record);	
	end
end

s2c["get_season_file_summy_rsp"] = SeasonReviewSystem.OnGetSeasonFileSummyRsp;
s2c["get_season_file_rsp"] = SeasonReviewSystem.OnGetSeasonFileRsp;