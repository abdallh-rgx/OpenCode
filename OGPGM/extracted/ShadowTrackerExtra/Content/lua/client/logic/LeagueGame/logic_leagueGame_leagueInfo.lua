LeagueGameLeagueInfo = LeagueGameLeagueInfo or {
	Group_info = {},	
	Situation_summary = {},
	Situation_detail = {},
	Rank_info = {},
	--rank_type
	rank_type_league_score = 1,                 --赛事积分
    rank_type_personal_kill = 2,                --个人击杀
    rank_type_final_win = 3,                    --吃鸡数量

    rank_no = 0,								--我的战队排行
    
    GroupInfo = {},								--分组信息

	FinalChampionData = {},						--总决赛数据

	GroupCacheTime = 300,						--小组赛-总决赛分组缓存时间
	SituationSummaryCacheTime = 60,				--小组赛-总决赛概要缓存时间
	SituationDetailCacheTime = 600,				--小组赛-总决赛详情缓存时间
	RankCacheTime = 60,							--小组赛-总决赛排行榜缓存时间
	FinalChampionTime = 3000,					--总决赛冠军缓存

	GroupPriority = 0,							--小组赛-总决赛分组缓存优先级
	SituationSummaryPriority = 1,				--小组赛-总决赛概要缓存优先级
	SituationDetailPriority = 1,				--小组赛-总决赛详情缓存优先级
	RankPriority = 0,							--小组赛-总决赛排行榜缓存优先级
	FinalChampionPriority = 0,					--总决赛缓存优先级

	Cache = {},									--Cache table存放
	CacheItemLeft = 20,							--Cache总协议数上限

	ZONE_NorthAmerica = 1,
	ZONE_Europe = 2,
	ZONE_Asia = 3,
	ZONE_SouthAmerica = 4,
	ZONE_Russia = 5,
	ZONE_KoreaJapan = 6,
}

function LeagueGameLeagueInfo.ResetData()
	LeagueGameLeagueInfo.Group_info = {}
	LeagueGameLeagueInfo.Situation_summary = {}
	LeagueGameLeagueInfo.Situation_detail = {}
	LeagueGameLeagueInfo.Rank_info = {}

	LeagueGameLeagueInfo.rank_type_league_score = 1
	LeagueGameLeagueInfo.rank_type_personal_kill = 2
	LeagueGameLeagueInfo.rank_type_final_win = 3

	LeagueGameLeagueInfo.rank_no = 0

	LeagueGameLeagueInfo.GroupInfo = {}
	LeagueGameLeagueInfo.FinalChampionData = {}

	--缓存
	LeagueGameLeagueInfo.Cache = {}
	LeagueGameLeagueInfo.CacheItemLeft = 20
end


function LeagueGameLeagueInfo.get_key_by_args(...)
	local key = ""
	for k, v in pairs({...}) do
		if k > 1 then
			key = key .. "-"
		end
		key = key .. tostring(v)
	end
	return key
end

--[[
Cache = {
	["Key"] = {
		Data = {
			...
		},
		CacheTime = 0,
		SaveTimestamp = 0,
		Priority = 0,
	},
	...
}
]]

function LeagueGameLeagueInfo.TryRemoveCacheByKey(Key)
	local cache = LeagueGameLeagueInfo.Cache[Key]
	if cache and cache.SaveTimestamp and cache.CacheTime then
		local saveTimestamp = cache.SaveTimestamp
		local curTimestamp = FuncUtil.GetServerTimeInSec()
		if saveTimestamp == nil
				or curTimestamp < saveTimestamp
				or curTimestamp > saveTimestamp + cache.CacheTime then
			LeagueGameLeagueInfo.RemoveCacheByKey(Key)
			return true
		end
	end

	return false
end

function LeagueGameLeagueInfo.RemoveCacheByKey(Key)
	if LeagueGameLeagueInfo.Cache[Key] then
		LeagueGameLeagueInfo.Cache[Key] = nil
		LeagueGameLeagueInfo.CacheItemLeft = LeagueGameLeagueInfo.CacheItemLeft + 1
	end
end

function LeagueGameLeagueInfo.GetCacheByKey(Key)
	local cache = LeagueGameLeagueInfo.Cache[Key]

	if not cache then
		return nil
	end
	if LeagueGameLeagueInfo.TryRemoveCacheByKey(Key) then
		return nil
	end

	return cache.Data
end

function LeagueGameLeagueInfo.SetCacheByKey(Key, Cache, CacheTime, Priority)
	--如果超过最大缓存数量 遍历所有缓存条目 清除超时缓存
	local ToRemoveKey = nil
	if LeagueGameLeagueInfo.CacheItemLeft <= 0 then
		for i, v in pairs(LeagueGameLeagueInfo.Cache) do
			LeagueGameLeagueInfo.TryRemoveCacheByKey(i)

			if not ToRemoveKey then
				ToRemoveKey = i
			else
				if v.Priority > LeagueGameLeagueInfo.Cache[ToRemoveKey].Priority then
					ToRemoveKey = i
				elseif v.Priority == LeagueGameLeagueInfo.Cache[ToRemoveKey].Priority
						and v.SaveTimestamp < LeagueGameLeagueInfo.Cache[ToRemoveKey].SaveTimestamp then
					ToRemoveKey = i
				end
			end
		end
	end
	--如果还是超过最大缓存数量 则清除优先级最低且最早缓存的条目
	if LeagueGameLeagueInfo.CacheItemLeft <= 0 then
		LeagueGameLeagueInfo.RemoveCacheByKey(ToRemoveKey)
	end

	--保证Data不为nil且有数据
	local flag = true
	if Cache.data then
		if type(Cache.data) == "table" then
			for i, v in pairs(Cache.data) do
				if v then
					flag = false
				end
			end
		end
		if type(Cache.data) == "string" then
			if string.len(Cache.data) > 0 then
				flag = false
			end
		end
	end
	if flag then
		return
	end
	--end

	if not CacheTime or CacheTime < 0 then
		return
	end
	if not Priority or Priority < 0 then
		--优先级最低为999999
		Priority = 999999
	end
	local cache = {}
	cache.Data = Cache
	cache.CacheTime = CacheTime
	cache.Priority = Priority
	cache.SaveTimestamp = FuncUtil.GetServerTimeInSec()
	LeagueGameLeagueInfo.Cache[Key] = cache
	LeagueGameLeagueInfo.CacheItemLeft = LeagueGameLeagueInfo.CacheItemLeft - 1
end


--对阵信息
function LeagueGameLeagueInfo.league_group_req(zone_id, stage, battle_mode)
	--NetUtil.SendPkg("league_group_req" , {zone_id = zone_id, stage = stage, battle_mode = battle_mode});

	local key = LeagueGameLeagueInfo.get_key_by_args("league_group", zone_id, stage, battle_mode)
	local cache = LeagueGameLeagueInfo.GetCacheByKey(key)
	if not cache then
		NetUtil.SendPkg("league_group_req", {zone_id = zone_id, stage = stage, battle_mode = battle_mode});
	else
		LeagueGameLeagueInfo.league_group_rsp(cache.res, cache.client_req, cache.data, true)
	end
end

--对阵信息回包
function LeagueGameLeagueInfo.league_group_rsp(res, client_req, bin_data, bCacheInfo)
	LeagueGameLeagueInfo.Group_info = {};
	if res == 0 then
		--log_tree("league_group_rsp", data);
		if bin_data then
			local data = Client.Load(LuaStateWrapper, bin_data);
			if data then
				LeagueGameLeagueInfo.GroupInfo = data;
				for k, v in pairs(data) do
					v.team_summary.seat_id = v.seat_id;
					v.team_summary.team_id = k;
					v.team_summary.group_id = v.group_id;
					if not LeagueGameLeagueInfo.Group_info[v.group_id] then
						LeagueGameLeagueInfo.Group_info[v.group_id] = {};
						table.insert(LeagueGameLeagueInfo.Group_info[v.group_id], v.team_summary);
					else
						table.insert(LeagueGameLeagueInfo.Group_info[v.group_id], v.team_summary);
					end
				end

				if not bCacheInfo then
					local key = LeagueGameLeagueInfo.get_key_by_args("league_group", client_req.zone_id, client_req.stage, client_req.battle_mode)
					local cache = {}
					cache.res = res
					cache.client_req = client_req
					cache.data = bin_data
					LeagueGameLeagueInfo.SetCacheByKey(key, cache, LeagueGameLeagueInfo.GroupCacheTime, LeagueGameLeagueInfo.GroupPriority)
				end
			end
		end
	else
		log("league_group_rsp error .. " .. res);
	end
	LeagueGameLeagueInfoUI.SetGroupData();
end

--战斗详情概要
function LeagueGameLeagueInfo.league_battle_situation_summary_req(zone_id, stage, battle_mode)
	--NetUtil.SendPkg("league_battle_situation_summary_req", {zone_id = zone_id, stage = stage, battle_mode = battle_mode});

	local key = LeagueGameLeagueInfo.get_key_by_args("league_battle_situation_summary", zone_id, stage, battle_mode)
	local cache = LeagueGameLeagueInfo.GetCacheByKey(key)
	if not cache then
		NetUtil.SendPkg("league_battle_situation_summary_req", {zone_id = zone_id, stage = stage, battle_mode = battle_mode});
	else
		LeagueGameLeagueInfo.league_battle_situation_summary_rsp(cache.res, cache.client_req, cache.data, true)
	end
end

--战斗详情概要回包
function LeagueGameLeagueInfo.league_battle_situation_summary_rsp(res, client_req, data, bCacheInfo)
	LeagueGameLeagueInfo.Situation_summary = {};
	if res == 0 then
		--log_tree("league_battle_situation_summary_rsp", data);
		if data then
			for _k, itemList in pairs(data) do
				if itemList then
					for k, v in pairs(itemList) do
						table.insert(LeagueGameLeagueInfo.Situation_summary, v);
					end
				end
			end

			if not bCacheInfo then
				local key = LeagueGameLeagueInfo.get_key_by_args("league_battle_situation_summary", client_req.zone_id, client_req.stage, client_req.battle_mode)
				local cache = {}
				cache.res = res
				cache.client_req = client_req
				cache.data = data
				LeagueGameLeagueInfo.SetCacheByKey(key, cache, LeagueGameLeagueInfo.SituationSummaryCacheTime, LeagueGameLeagueInfo.SituationSummaryPriority)
			end
		end
	else
		log("league_battle_situation_summary_rsp error .. " .. res);
	end
	LeagueGameLeagueInfoUI.SetSummaryData();
end

--战况信息详情请求
function LeagueGameLeagueInfo.league_battle_situation_req(zone_id, stage, battle_mode, group_id, round_id)
	--NetUtil.SendPkg("league_battle_situation_req", {zone_id = zone_id, stage = stage, battle_mode = battle_mode, group_id = group_id, round_id = round_id});

	local key = LeagueGameLeagueInfo.get_key_by_args("league_battle_situation", zone_id, stage, battle_mode, group_id, round_id)
	local cache = LeagueGameLeagueInfo.GetCacheByKey(key)
	if not cache then
		NetUtil.SendPkg("league_battle_situation_req", {zone_id = zone_id, stage = stage, battle_mode = battle_mode, group_id = group_id, round_id = round_id})
	else
		LeagueGameLeagueInfo.league_battle_situation_rsp(cache.res, cache.client_req, cache.data, true)
	end
end

--战况信息详情回包
function LeagueGameLeagueInfo.league_battle_situation_rsp(res, client_req, data, bCacheInfo)
	LeagueGameLeagueInfo.Situation_detail = {};
	if res == 0 then
		--log_tree("league_battle_situation_rsp", data);
		if data then
			for k, v in pairs(data) do
				table.insert(LeagueGameLeagueInfo.Situation_detail, v);
			end

			if not bCacheInfo then
				local key = LeagueGameLeagueInfo.get_key_by_args("league_battle_situation", client_req.zone_id, client_req.stage, client_req.battle_mode, client_req.group_id, client_req.round_id)
				local cache = {}
				cache.res = res
				cache.client_req = client_req
				cache.data = data
				LeagueGameLeagueInfo.SetCacheByKey(key, cache, LeagueGameLeagueInfo.SituationDetailCacheTime, LeagueGameLeagueInfo.SituationDetailPriority)
			end
		end
	else
		log("league_battle_situation_rsp error .. " .. res);
	end
	LeagueGameLeagueInfoDetailUI.SetData();
end


--排行榜信息请求
function LeagueGameLeagueInfo.league_rank_info_req(zone_id, stage, battle_mode, rank_type)
--[[	local key = LeagueGameLeagueInfo.get_key_from_args(zone_id,stage,battle_mode,rank_type)
	log("LeagueGameLeagueInfo.league_rank_info_req .." .. key)
	local curTime = FuncUtil.GetServerTimeInSec()
	if lastTime == nil
			or curTime < lastTime
			or curTime > lastTime + LeagueGameLeagueInfo.CacheTime then
		NetUtil.SendPkg("league_rank_info_req", {zone_id = zone_id, stage = stage, battle_mode = battle_mode, rank_type = rank_type});
	else
		local cache = LeagueGameLeagueInfo.CacheRankInfo[key]
		if not cache then
			log("LeagueGameLeagueInfo.league_rank_info_req: cache is nil")
		else
			LeagueGameLeagueInfo.league_rank_info_rsp(cache.res, cache.client_req, cache.data, true)
		end
	end]]
	local key = LeagueGameLeagueInfo.get_key_by_args("league_rank_info", zone_id, stage, battle_mode, rank_type)
	local cache = LeagueGameLeagueInfo.GetCacheByKey(key)
	if not cache then
		NetUtil.SendPkg("league_rank_info_req", {zone_id = zone_id, stage = stage, battle_mode = battle_mode, rank_type = rank_type});
	else
		LeagueGameLeagueInfo.league_rank_info_rsp(cache.res, cache.client_req, cache.data, true)
	end
end

--排行榜信息回包
function LeagueGameLeagueInfo.league_rank_info_rsp(res, client_req, bin_data, bCacheInfo)
	LeagueGameLeagueInfo.Rank_info = {};
	if res == 0 then
		--log_tree("league_rank_info_rsp", data);
		if bin_data then
			local data = Client.Load(LuaStateWrapper, bin_data);
			if data then
				local group_topn_rank = {};
				for k, v in ipairs(data) do
					if not v.group_id then
						v.group_id = 1;
					end
					group_topn_rank[v.group_id] = group_topn_rank[v.group_id] or {}
					local cur_group_topn_rank = group_topn_rank[v.group_id]
					cur_group_topn_rank[#cur_group_topn_rank + 1] = k
					v.group_rank_no = #cur_group_topn_rank
					v.rank = k;
					table.insert(LeagueGameLeagueInfo.Rank_info, v);
				end

				if not bCacheInfo then
					local key = LeagueGameLeagueInfo.get_key_by_args("league_rank_info", client_req.zone_id, client_req.stage, client_req.battle_mode, client_req.rank_type)
					local cache = {}
					cache.res = res
					cache.client_req = client_req
					cache.data = bin_data
					LeagueGameLeagueInfo.SetCacheByKey(key,cache,LeagueGameLeagueInfo.RankCacheTime, LeagueGameLeagueInfo.RankPriority)
				end
				--if not bCacheInfo then
				--	--缓存
				--	local cache = {}
				--	cache.res = res
				--	cache.client_req = client_req
				--	cache.data = data
				--
				--	local key = LeagueGameLeagueInfo.get_key_by_args(client_req.zone_id, client_req.stage, client_req.battle_mode, client_req.rank_type)
				--
				--	LeagueGameLeagueInfo.CacheRankInfo[key] = cache
				--	LeagueGameLeagueInfo.RankCacheTimestamp[key] = FuncUtil.GetServerTimeInSec()
				--end
			end
		end
	else
		log("league_rank_info_rsp error .. " .. res);
	end
	--log_tree("LeagueGameLeagueInfo.Rank_info", LeagueGameLeagueInfo.Rank_info);
	EventSystem:postEvent(EVENTTYPE_LEAGUEGAME, EVENTID_LEAGUEGAME_RANKDATE_UPDATE);
end


--晋级奖励请求
function LeagueGameLeagueInfo.get_league_promote_reward_req(cfg_id)
	NetUtil.SendPkg("get_league_promote_reward_req", cfg_id);
end
--[[
items
├─ 1
│  ├─ extra_cfg_id: 0
│  ├─ valid_hours: 0
│  ├─ count: 1
│  └─ resid: 2003014
├─ 2
│  ├─ extra_cfg_id: 0
│  ├─ valid_hours: 0
│  ├─ count: 1
│  └─ resid: 1801101
└─ 3
   ├─ extra_cfg_id: 0
   ├─ valid_hours: 0
   ├─ count: 1
   └─ resid: 1801102
  ]]
--晋级奖励请求回包
function LeagueGameLeagueInfo.get_league_promote_reward_rsp(res, cfg_id, item_list)
	if res == 0 then
		--log_tree("get_league_promote_reward_rsp", item_list);
		local rewardList = {};
		for k, v in pairs(item_list) do
			table.insert(rewardList, {res_id = v.resid, count = v.count});
		end
		if #rewardList > 0 then
			CommonItemGetUI:ShowPanel(rewardList);
		end
		--EventLeagueGameAdvanceHide();
	else

	end
end

-- 个人战队排行榜信息请求
function LeagueGameLeagueInfo.get_carteam_league_rank_no_req(zone_id, stage, battle_mode, rank_type)
	NetUtil.SendPkg("get_carteam_league_rank_no_req", {zone_id = zone_id, stage = stage, battle_mode = battle_mode, rank_type = rank_type});
end

function LeagueGameLeagueInfo.get_carteam_league_rank_no_rsp(res, client_req, rank_no)
	log("LeagueGameLeagueInfo.get_carteam_league_rank_no_rsp.." .. res .."----" .. rank_no)
	if res == 0 then
		LeagueGameLeagueInfo.rank_no = rank_no;
	else
		LeagueGameLeagueInfo.rank_no = 0;
	end
	LeagueGameLeagueInfoUI.SetLeagueInfoSelfTeamInfo();
end


--比赛冠军列表拉取
function LeagueGameLeagueInfo.league_final_winner_req()
	local key = LeagueGameLeagueInfo.get_key_by_args("league_final_winner_req")
	local cache = LeagueGameLeagueInfo.GetCacheByKey(key)
	if not cache then
		NetUtil.SendPkg("league_final_winner_req");
	else
		LeagueGameLeagueInfo.league_final_winner_rsp(cache.res, cache.data, true)
	end
end

--比赛冠军列表拉取回包
function LeagueGameLeagueInfo.league_final_winner_rsp(res, data, bCacheInfo)
	log_tree("LeagueGameLeagueInfo.league_final_winner_rsp", data);
	LeagueGameLeagueInfo.FinalChampionData = {};
	if res == 0 then
		if data then
			LeagueGameLeagueInfo.FinalChampionData = data;
			if not bCacheInfo then
				local key = LeagueGameLeagueInfo.get_key_by_args("league_final_winner_req")
				local cache = {}
				cache.res = res
				cache.data = data
				LeagueGameLeagueInfo.SetCacheByKey(key, cache, LeagueGameLeagueInfo.FinalChampionTime, LeagueGameLeagueInfo.FinalChampionPriority)
			end
		end
	else
		PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", res).TextValue);
	end
	LeagueGameFinalChampionUI.SetChampionMap();
end


s2c["league_group_rsp"] = LeagueGameLeagueInfo.league_group_rsp;
s2c["league_battle_situation_summary_rsp"] = LeagueGameLeagueInfo.league_battle_situation_summary_rsp;
s2c["league_battle_situation_rsp"] = LeagueGameLeagueInfo.league_battle_situation_rsp;
s2c["league_rank_info_rsp"] = LeagueGameLeagueInfo.league_rank_info_rsp;
s2c["get_league_promote_reward_rsp"] = LeagueGameLeagueInfo.get_league_promote_reward_rsp;
s2c["get_carteam_league_rank_no_rsp"] = LeagueGameLeagueInfo.get_carteam_league_rank_no_rsp;
s2c["league_final_winner_rsp"] = LeagueGameLeagueInfo.league_final_winner_rsp;