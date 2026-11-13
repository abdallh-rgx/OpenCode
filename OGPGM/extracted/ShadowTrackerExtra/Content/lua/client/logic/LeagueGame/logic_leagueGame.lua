LeagueGameSystem = LeagueGameSystem or {
	LeagueId = 0,								--赛事ID
	StageId = -1,								--阶段ID
	--stage的枚举
	LEAGUE_STAGE_REBORT = 1,                   	 -- 预报
	LEAGUE_STAGE_ENROLL = 2,                     -- 报名
	LEAGUE_STAGE_FIRST_MATCH = 3,                -- 海选赛
	LEAGUE_STAGE_GROUP_MATCH = 4,                -- 小组赛
	LEAGUE_STAGE_ZONE_FINAL_MATCH = 5,           -- 战区决赛
	LEAGUE_STAGE_GLOBAL_FINAL_MATCH = 6,         -- 全球决赛
	LEAGUE_STAGE_REWARD = 7,                     -- 发奖
	LEAGUE_STAGE_TOP_CLEAR = 8,                  -- 清榜
	--模式枚举
	LEAGUE_TPP_MODE = 11103,					--第三人称
	LEAGUE_FPP_MODE = 11403,					--第一人称

	apply_info = nil,							--报名信息
	competing_info = nil,						--战队赛事信息	

	--报名参赛信息
	signUpInfo = {
		zoneList = {},							--开放的大区
		sub_mode = {},							--子模式，根据模式查找比赛模式和比赛地图
	},

	signUpState = 0, 							--报名状态：0未报名；1已报名；2，未参赛；3，隐藏

	LeagueRewardListTable = {},					--阶段ID对应的奖励列表
	LeagueRewardItemCfg = {},					--奖励ID对应的物品列表

	LeagueBeginTime = 0,
	LeagueEndTime = 0,

	LeagueDateTable = {},						--赛事各阶段信息table
	LeagueTimeTable = {},						--各阶段比赛场次信息

	SignUpCostCoin = 0,							--报名花费
	Ispromote = false,							--是否晋级
	IsPopReward = false,						--是否领取晋级奖励
	EnrollCdTime = 0,							--报名CD时间
	LastCancelEnrollTime = 0,					--上一次取消报名的时间戳

	begin_time = 0,								--下一场开始时间
    end_time = 0,								--下一场匹配截止时间

    isLeagueGameConfigReq = false,				--标记config请求，解决初始化拉取不到信息的问题
    isMyStageReq = false,						--标记我的stagereq请求

    promoteStateReqFrom = 0,					--晋级状态请求来源 1,表示战队
    GameInfoReqInit = false,					--拉取标志,true表示登录拉取，仅保存数据
    GameNextTimeReqInit = false,				--拉取下一场比赛标志，true表示登录拉取，保存数据，用于小红点提示
    isNeetTipNextMatch = false,					--记录是否小红点提示下一场比赛
}


function LeagueGameSystem.Enter()
	--LeagueGameLobbyUI.init();
	if LobbySystem.LobbyMenuOpenStatus[BP_ENUM_ONLINE_EVENT].is_open == 1 then
        if LeagueGameSystem.league_process_table == nil then
			LeagueGameSystem.LeagueGameConfigReq();
			--LeagueGameSystem.LeagueGameEnrollInfoReq();
			LeagueGameSystem.LeagueGameInfoReq(true);
			--LeagueGameSystem.LeagueGamePromoteStateReq();
			LeagueGameSystem.league_next_match_time_req(true);
		end
	else
		LeagueGameSystem.isLeagueGameConfigReq = false;
	end
end

function LeagueGameSystem.ResetData()
	LeagueGameSystem.LeagueId = 0                                --赛事ID
	LeagueGameSystem.StageId = -1                                --阶段ID

	LeagueGameSystem.apply_info = nil                            --报名信息
	LeagueGameSystem.competing_info = nil                        --战队赛事信息

	--报名参赛信息
	--LeagueGameSystem.signUpInfo = {
	--	zoneList = {},--开放的大区
	--	sub_mode = {},--子模式，根据模式查找比赛模式和比赛地图
	--}

	LeagueGameSystem.signUpState = 0                            --报名状态：0未报名；1已报名；2，未参赛；3，隐藏

	LeagueGameSystem.LeagueRewardListTable = {}                    --阶段ID对应的奖励列表
	LeagueGameSystem.LeagueRewardItemCfg = {}                    --奖励ID对应的物品列表

	LeagueGameSystem.LeagueBeginTime = 0
	LeagueGameSystem.LeagueEndTime = 0

	LeagueGameSystem.LeagueDateTable = {}                        --赛事各阶段信息table
	LeagueGameSystem.LeagueTimeTable = {}                        --各阶段比赛场次信息

	LeagueGameSystem.SignUpCostCoin = 0                            --报名花费
	LeagueGameSystem.Ispromote = false                            --是否晋级
	LeagueGameSystem.IsPopReward = false                        --是否领取晋级奖励
	LeagueGameSystem.EnrollCdTime = 0							--报名CD时间
	LeagueGameSystem.LastCancelEnrollTime = 0

	LeagueGameSystem.begin_time = 0                                --下一场开始时间
	LeagueGameSystem.end_time = 0                                --下一场匹配截止时间

	LeagueGameSystem.isLeagueGameConfigReq = false                --标记config请求，解决初始化拉取不到信息的问题
	LeagueGameSystem.isMyStageReq = false                        --标记我的stagereq请求

	LeagueGameSystem.promoteStateReqFrom = 0                    --晋级状态请求来源 1表示战队
	LeagueGameSystem.GameInfoReqInit = false
	LeagueGameSystem.GameNextTimeReqInit = false
	LeagueGameSystem.isNeetTipNextMatch	= false
end

--赛事配置请求
function LeagueGameSystem.LeagueGameConfigReq()
	NetUtil.SendPkg("league_config_req");
end

--赛事配置回包
function LeagueGameSystem.LeagueGameConfigRsp(league_id, stage, league_date_table, league_time_table, league_reward_list_table, league_reward_item_cfg)
	--log_tree("league_date_table", league_date_table);
	--log_tree("league_time_table", league_time_table);
	-- 传入战队赛系统
	local serverData = {}
	serverData.league_process_table = league_date_table
	serverData.league_game_table = league_time_table
	AllianceCompetitionSystem.SetDataFromServer(serverData)

	--log_tree("league_reward_list_table", league_reward_list_table);
	--log_tree("league_reward_item_cfg", league_reward_item_cfg);
	--log("LeagueGameSystem.LeagueGameConfigRsp .." .. league_id);
	if league_id and league_id > 0 then
		LeagueGameSystem.LeagueId = league_id;
	else
		LeagueGameSystem.LeagueId = 0
		log("league_id error" .. league_id);
	end
	if stage and stage > 0 then
		LeagueGameSystem.StageId = stage;
		BP_Lobby_LeagueStage = stage;
	else
		LeagueGameSystem.StageId = 0
		log("The competition does not begin.");
	end
	if league_date_table then
		LeagueGameSystem.LeagueBeginTime = league_date_table[LeagueGameSystem.LEAGUE_STAGE_REBORT].begin_time;
		LeagueGameSystem.LeagueEndTime = league_date_table[LeagueGameSystem.LEAGUE_STAGE_REWARD].end_time;
		LeagueGameSystem.LeagueDateTable = league_date_table;
		LeagueGameSystem.SignUpCostCoin = league_date_table.enroll_consume_coin;
		LeagueGameSystem.EnrollCdTime = league_date_table.enroll_cd_time;
		
	else
		--log_tree("league_date_table error" , league_date_table);
	end

	if league_time_table then
		LeagueGameSystem.LeagueTimeTable = league_time_table;
		local signUpInfo = league_time_table[LeagueGameSystem.LEAGUE_STAGE_ZONE_FINAL_MATCH];
		if signUpInfo then
			for id, item in pairs(signUpInfo) do
				for k, v in pairs(item) do
					if not LeagueGameSystem.signUpInfo.zoneList[k] then
						LeagueGameSystem.signUpInfo.zoneList[k] = k;
					end
					if not LeagueGameSystem.signUpInfo.sub_mode[v.sub_mode] then
						LeagueGameSystem.signUpInfo.sub_mode[v.sub_mode] = v.sub_mode;
					end
				end
			end
		else
			log_tree("signUpInfo erroor" , signUpInfo);
			return;
		end
	else
		log_tree("league_time_table error" , league_time_table);
	end
	if league_reward_list_table then
		LeagueGameSystem.LeagueRewardListTable = league_reward_list_table;
	else
		log_tree("league_reward_list_table error" , league_reward_list_table);
	end

	if league_reward_item_cfg then
		LeagueGameSystem.LeagueRewardItemCfg = league_reward_item_cfg;
	else
		log_tree("league_reward_item_cfg error" , league_reward_item_cfg);
	end
	--log_tree("LeagueGameSystem.signUpInfo.zoneList", LeagueGameSystem.signUpInfo.zoneList);
	--log_tree("LeagueGameSystem.signUpInfo.sub_mode", LeagueGameSystem.signUpInfo.sub_mode);
	if LeagueGameSystem.isLeagueGameConfigReq then
		LeagueGameSystem.isLeagueGameConfigReq = false;
		LeagueGameSystem.LeagueGameStageReq()
	end
end

--晋级队伍请求,只有小组赛才有
function LeagueGameSystem.LeagueGamePromoteTeamReq(mode, zone_id)
	NetUtil.SendPkg("league_promote_team_req", mode, zone_id);
end
--晋级队伍回包
function LeagueGameSystem.LeagueGamePromoteTeamRsp(stage, mode, zone_id, teams)

end

--请求stageID
function LeagueGameSystem.LeagueGameStageReq()
	if LeagueGameSystem.StageId and LeagueGameSystem.StageId == -1 then
		-- 未初始化
		LeagueGameSystem.isLeagueGameConfigReq = true;
		LeagueGameSystem.Enter();
		log("LeagueGameSystem.LeagueGameStageReq 1")
	else
		-- 已初始化
		LeagueGameSystem.isMyStageReq = true;
		NetUtil.SendPkg("league_stage_req");
		log("LeagueGameSystem.LeagueGameStageReq 2")
	end
end

function LeagueGameSystem.LeagueGameStageRsp(stage, league_id)
	log("LeagueGameSystem.LeagueGameStageRsp league_id .. " .. tostring(league_id));
	log("LeagueGameSystem.LeagueId .." .. tostring(LeagueGameSystem.LeagueId));
	--判断是否切了新的赛季，如果是就从新拉取数据
	if league_id and league_id > 0 then
		if league_id ~= LeagueGameSystem.LeagueId and LeagueGameSystem.LeagueId > 0 then
			LeagueGameSystem.StageId = -1;
			LeagueGameSystem.LeagueGameStageReq();
			return;
		end
	end
	--正常逻辑
	if LeagueGameSystem.isMyStageReq then
		if stage and stage > 0 then
			LeagueGameSystem.StageId = stage;
			BP_Lobby_LeagueStage = stage;
			--LeagueGameLobbyUI.SetData();
			if stage >LeagueGameSystem.LEAGUE_STAGE_FIRST_MATCH then
				LeagueGameSystem.LeagueGamePromoteStateReq(0)
			else
				LeagueGameSystem.league_next_match_time_req(false);
			end
			--LeagueGameLobbyUI.Show();
		else
			LeagueGameSystem.StageId = 0
			LeagueGameLobbyUI.Show()
			BP_Lobby_LeagueStage = 0;
			log("LeagueGameStageRsp:Stage is nil! (Maybe its because the competition does not begin.)");
		end
		LeagueGameSystem.isMyStageReq = false;
	end
end

--赛事信息请求
function LeagueGameSystem.LeagueGameInfoReq(isInit)
	LeagueGameSystem.GameInfoReqInit = isInit;
	NetUtil.SendPkg("league_info_req");
end

function LeagueGameSystem.LeagueGameInfoRsp(err, league_info)
	LeagueGameSystem.signUpState = 0;
	if err == 0 then
		--log_tree("LeagueGameSystem.LeagueGameInfoRsp", league_info);
		if league_info then
			-- 设置给战队赛数据
			local serverTime = FuncUtil.GetServerTimeInSec()
			if league_info.apply_info ~= nil then
				-- 已报名
				log("league_info.apply_info ~= nil")
				AllianceCompetitionSystem.Mode = league_info.apply_info.apply_mode
				AllianceCompetitionSystem.Zone = league_info.apply_info.apply_zone

				-- 有可能回包比打开界面慢
				AllianceCompetitionRoomUI.CheckToQuick()

				if serverTime >= LeagueGameSystem.begin_time
						and serverTime < LeagueGameSystem.end_time then
					--比赛开始 显示进入比赛入口 状态为未参赛
					LeagueGameSystem.signUpState = 2
				else
					--比赛未开始 为已报名
					LeagueGameSystem.signUpState = 1;
				end
				LeagueGameSystem.apply_info = league_info.apply_info;

				--[[if LeagueGameSystem.StageId == LeagueGameSystem.LEAGUE_STAGE_ENROLL and LeagueGameSystem.GameInfoReqInit == false then
					EventSystem:postEvent(EVENTTYPE_LEAGUEGAME, EVENTID_LEAGUEGAME_CONFIG_UPDATE)
				end]]
			else
				--if serverTime > LeagueGameSystem.LeagueDateTable[LeagueGameSystem.LEAGUE_STAGE_ENROLL].end_time then
				--	--过了报名阶段无法报名 隐藏入口
				--	--LeagueGameSystem.signUpState = 3;
				--else
				LeagueGameSystem.signUpState = 0;
				AllianceCompetitionSystem.Mode = -1;
				AllianceCompetitionSystem.Zone = -1;
				LeagueGameSystem.apply_info = nil;
				--end
			end

			if league_info.competing_info ~= nil then
				LeagueGameSystem.competing_info = league_info.competing_info;
			else
				LeagueGameSystem.competing_info = nil;
			end

			if league_info.last_cancel_enroll_time ~= nil then
				LeagueGameSystem.LastCancelEnrollTime = league_info.last_cancel_enroll_time;
			else
				LeagueGameSystem.LastCancelEnrollTime = 0;
			end
		else
			LeagueGameSystem.signUpState = 0;
		end
	elseif err ~= 505001 then
		PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", err).TextValue);
	end
	if LeagueGameSystem.GameInfoReqInit == false then
		LeagueGameLobbyUI.SetData();
		LeagueGameLobbyUI.Show();
	end
end

--晋级状态请求
function LeagueGameSystem.LeagueGamePromoteStateReq(from)
	LeagueGameSystem.promoteStateReqFrom = from;
	NetUtil.SendPkg("get_league_promote_stat_req");
end
--晋级状态回包
function LeagueGameSystem.LeagueGamePromoteStateRsp(stage, is_promote, is_pop_reward)
	LeagueGameSystem.Ispromote = is_promote;
	LeagueGameSystem.IsPopReward = is_pop_reward;
	LeagueGameSystem.StageId = stage or 0;
	--检查弹出晋级领奖
	if LeagueGameSystem.Ispromote and LeagueGameSystem.IsPopReward then
		LeagueGameAdvanceUI.Init();
	end
	--战队的请求不走后面逻辑
	if LeagueGameSystem.promoteStateReqFrom ~= 1 then
		LeagueGameSystem.league_next_match_time_req(false);
	end
end


-- 请求下一场比赛的时间
function LeagueGameSystem.league_next_match_time_req(isInit)
	log("send league_next_match_time_req .. " .. tostring(isInit));
	LeagueGameSystem.GameNextTimeReqInit = isInit;
	NetUtil.SendPkg("league_next_match_time_req");
end

function LeagueGameSystem.league_next_match_time_rsp(stage, begin_time, end_time)
	log("LeagueGameSystem.league_next_match_time_rsp.." .. tostring(stage) .."----" .. tostring(begin_time) .. "----" .. tostring(end_time));
	if not begin_time then
		begin_time = 0;
	end
	if not end_time then
		end_time = 0;
	end
	if LeagueGameSystem.GameNextTimeReqInit then
		LeagueGameSystem.GetNextMatchRedTips(stage, begin_time, end_time);
		LobbyUI.CheckIsShowLeagueGameCountDown(begin_time, end_time);
	else
		LeagueGameSystem.begin_time = begin_time;
		LeagueGameSystem.end_time = end_time;
		LeagueGameSystem.LeagueGameInfoReq(false);
	end
	--LeagueGameLobbyUI.SetCountDownState();
end

function LeagueGameSystem.GetNextMatchRedTips(stage , begin_time, end_time)
	LeagueGameSystem.isNeetTipNextMatch	= false;
	if stage and begin_time and end_time then
		local timezone = Client.GetLocalTimezone();
		local serverTime = FuncUtil.GetServerTimeInSec();
		if FuncUtil.Getdaystart_by_tz(serverTime, timezone) == FuncUtil.Getdaystart_by_tz(begin_time, timezone) then
			LeagueGameSystem.isNeetTipNextMatch	= true;
    		LobbyUI:LobbyRedPointUpdate(BP_ENUM_LOBBY_MENU_BROADCAST, true);
		end
	end
end

function LeagueGameSystem.carteam_cancel_enroll_league_req()
	NetUtil.SendPkg("carteam_cancel_enroll_league_req");
end

function LeagueGameSystem.carteam_cancel_enroll_league_rsp(ok, reason, uid)
	if not ok then
		PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", reason).TextValue);
	else
		PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", 6328).TextValue);
		--LeagueGameSystem.Enter();
		LeagueGameSystem.LeagueGameInfoReq(false);
	end
end

s2c["league_config_rsp"] = LeagueGameSystem.LeagueGameConfigRsp;
--s2c["league_enroll_info_rsp"] = LeagueGameSystem.LeagueGameEnrollInfoRsp;
--s2c["league_promote_team_rsp"] = LeagueGameSystem.LeagueGamePromoteTeamRsp;
s2c["league_stage_rsp"] = LeagueGameSystem.LeagueGameStageRsp;
s2c["league_state_rsp"] = LeagueGameSystem.LeagueGameInfoRsp;
s2c["get_league_promote_stat_rsp"] = LeagueGameSystem.LeagueGamePromoteStateRsp;
s2c["league_next_match_time_rsp"] = LeagueGameSystem.league_next_match_time_rsp;
s2c["carteam_cancel_enroll_league_rsp"] = LeagueGameSystem.carteam_cancel_enroll_league_rsp;

