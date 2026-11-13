--[[
  个人信息的相关逻辑
]]--

RoleInfoSystem = RoleInfoSystem or
{
	--Update_Ctrl = 0;			--更新控制计数
	curseasonid = 0;
	AllSeasonIDList = {};
	PlatID = "";
	IsMaxLevel = false;
	IsFriend = false;

	RoleCombatInfoGet = {}, --角色战绩信息是否获取
	RoleBasicInfoGet = 0, --角色基本信息是否获取
	RoleHistorySeasonBattleGet = false, --个人战绩信息是否获取
	AchievementSummaryGet = 0, --成就数据是否获取
	RoleBasicInfoHasRefresh = {},--角色基本信息是否刷新
	WearDataHasRefresh = {},--穿戴信息是否刷新
	
	PersonalBasicInfo = {},
	PersonalTotalRankInfo = {},
	PersonalTotalScoreInfo = {},
	CombatTotalInfoList = {},
	CombatSurviveInfoList = {},
	CombatScoreInfoList = {},
	CombatBattleInfoList = {},
	CombatGradeInfoList = {},
	FPPPersonalTotalRankInfo = {},
	FPPPersonalTotalScoreInfo = {},
	FPPCombatTotalInfoList = {},
	FPPCombatSurviveInfoList = {},
	FPPCombatScoreInfoList = {},
	FPPCombatBattleInfoList = {},
	FPPCombatGradeInfoList = {},
	IntimateInfoList = {},
    SocialCard = {},
	HonorWallInfoList = {},
	
	CombatTotalInfo =
	{
		role_allmatchnum = 0,
		role_winnum = 0,
		role_toptennum = 0,
		role_killnum = 0,
		role_kd = 0,
		role_critrate = 0,
	},
	CombatSurviveInfo =
	{
		role_maxsurvivetime = 0,
		role_avesurvivetime = 0,
		role_maxdistance = 0,
		role_avedistance = 0,
		role_aveheal = 0,
		role_aidcount = 0,
		role_winrate = 0,
		role_toptenrate = 0,
	},
	CombatScoreInfo =
	{
		role_score = 0,
		role_killscore = 0,
		role_rankscore = 0,
	},
	CombatBattleInfo =
	{
		role_hitrate = 0,
		role_critcount = 0,
		role_maxkill = 0,
		role_maxdamage = 0,
		role_avedamage = 0,
	},
	CombatGradeInfo =
	{
		survive_score = 0,
		top1_score = 0,
		rating_score = 0,
		fight_score = 0,
		assist_score = 0,
		sum_score = 0,
		grade = 0,
	},
    CurShowPlayerInfoUid = 0,
    top1w_score = 0,
	fpp_top1w_score = 0,
	
	GetDataMaxTimes = 5,
	
	
}

-- 分数类型 需要和 apollo topn服务定义的一致
local score_type = {
    total_rating       = 1000, -- 综合总积分
    solo_total_rating  = 1001, -- 单排总积分
    solo_win_rating    = 1002, -- 单排胜利积分
    solo_kill_rating   = 1003, -- 单排击败积分
    duo_total_rating   = 2001, -- 双排总积分
    duo_win_rating     = 2002, -- 双排胜利积分
    duo_kill_rating    = 2003, -- 双排击败积分
    squad_total_rating = 3001, -- 四排总积分
    squad_win_rating   = 3002, -- 四排胜利积分
    squad_kill_rating  = 3003, -- 四排击败积分
	fpp_total_rating   = 4000, -- FPP综合总积分
};

--单双四模式类型
local model_type =
{
	solo_model = 1,
	double_model = 2,
	team_model = 3,
	all_model = 4,
};

--段位
local segment_type =
{
	solo = 1,
	double = 2,
	team = 3,
	fpp_solo = 4,
	fpp_double = 5,
	fpp_team = 6,
}

function RoleInfoSystem.Enter(uid)
	uid = tostring(uid) --转化为string
	log("RoleInfoSystem Enter");

	if UIManager.GetUI(eUIType.eRoleInfoUI) then
		RoleInfoUI.HideUI(false)
	end
    
	RoleInfoSystem.CurShowPlayerInfoUid = uid;

	BP_RoleInfo_HasGetPersonalBasicInfo = false

	BP_RoleInfoSeason_ListID = 1
	
	RoleInfoSystem.RoleCombatInfoGet = {} --角色战绩信息是否获取
	RoleInfoSystem.RoleBasicInfoGet = 0 --角色基本信息是否获取
	RoleInfoSystem.RoleHistorySeasonBattleGet = false --个人战绩信息是否获取
	RoleInfoSystem.AchievementSummaryGet = 0 -- 成就数据是否获取
	
	--RoleInfoSystem.Update_Ctrl = 0;
	RoleInfoSystem.curseasonid = 0;
	RoleInfoSystem.PlatID = "";
	RoleInfoSystem.IsMaxLevel = false;
	RoleInfoSystem.IsFriend = false;
	RoleInfoSystem.IsMaxPveLevel = false
	--RoleInfoSystem.GetDataMaxTimes = 4;
	RoleInfoSystem.SetEmpty();
	RoleInfoSystem.IsRoleFriend(uid);
    RoleInfoSystem.RequestRoleInfo();

	PersonSpaceSystem.Enter()
	--[[
	RoleInfoSystem.get_profile_info_req(uid);
	RoleInfoSystem.get_role_battle_info_req(uid);
	RoleInfoSystem.get_role_rank_info_req(uid, score_type.total_rating);
    ]]
	if uid ~= DataMgr.roleData.uid then
		RoleInfoSystem.get_role_battle_info_req(uid, BP_Back_ShowRoleInfoOfZoneId);
	else
		-- 告知服务器，用于检查时装背包过期状态
		NetUtil.SendPkg("client_in_depot"); 
	end

	local RoleInfoPopularitySystem = require("client.slua.logic.person_space.logic_roleinfo_popularity")

	RoleInfoPopularitySystem.enter(RoleInfoSystem.CurShowPlayerInfoUid)

	EventSystem:registEvent(EVENTTYPE_RANK, EVENTID_WARZONE_UPDATE_AVATAR, RoleInfoSystem.UpdateAvatarRsp)
end

function RoleInfoSystem.IsSelf()
	return tonumber(RoleInfoSystem.CurShowPlayerInfoUid) == tonumber(DataMgr.roleData.uid)
end

function RoleInfoSystem.RequestCurrSeasonBattleInfo()
	if BP_Back_ShowRoleInfoOfZoneId == 0 then
		BP_Back_ShowRoleInfoOfZoneId = DataMgr.GetOneZoneList();
	end
	local season_id = BP_ARRAY_RoleInfoSeasonIDList[BP_RoleInfoSeason_ListID];

	log("RoleInfoSystem.RequestCurrSeasonBattleInfo:" .. tostring(BP_Back_ShowRoleInfoOfZoneId) .. ",season_id:" .. tostring(season_id))

	if RoleInfoSystem.RoleCombatInfoGet.ZoneId ~= BP_Back_ShowRoleInfoOfZoneId or RoleInfoSystem.RoleCombatInfoGet.SeasonId ~= season_id then
		RoleInfoSystem.get_role_battle_info_req(RoleInfoSystem.CurShowPlayerInfoUid, BP_Back_ShowRoleInfoOfZoneId);

		RoleInfoSystem.RoleCombatInfoGet.ZoneId = BP_Back_ShowRoleInfoOfZoneId
		RoleInfoSystem.RoleCombatInfoGet.SeasonId = season_id

		RoleInfoSystem.get_role_rank_info_req(RoleInfoSystem.CurShowPlayerInfoUid, score_type.total_rating, BP_Back_ShowRoleInfoOfZoneId);

	end

	RoleInfoSystem.get_profile_info_req(RoleInfoSystem.CurShowPlayerInfoUid)

	EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_ROLEINFO);
end

function RoleInfoSystem.RequestHistorySeasonBattleInfo()
	local season_id = BP_ARRAY_RoleInfoSeasonIDList[BP_RoleInfoSeason_ListID];
	log("RequestHistorySeasonBattleInfo" .. tostring(BP_Back_ShowRoleInfoOfZoneId) .. ",season_id:" .. tostring(season_id))

	if RoleInfoSystem.RoleCombatInfoGet.ZoneId ~= BP_Back_ShowRoleInfoOfZoneId or RoleInfoSystem.RoleCombatInfoGet.SeasonId ~= season_id then
		RoleInfoSystem.RoleCombatInfoGet.ZoneId = BP_Back_ShowRoleInfoOfZoneId
		RoleInfoSystem.RoleCombatInfoGet.SeasonId = season_id
		RoleInfoSystem.get_role_history_season_battle(BP_STRUCT_PersonalBasicInfo.role_id, season_id, BP_Back_ShowRoleInfoOfZoneId);
	end
end

--请求各种信息
function RoleInfoSystem.RequestRoleInfo()

    --如果是自己需要单独拉取最后一次的战斗信息
    --if tostring(RoleInfoSystem.CurShowPlayerInfoUid) == DataMgr.roleData.uid then
    --	RoleInfoSystem.GetDataMaxTimes = 5;
    --	RoleInfoSystem.Get_last_battle_type_req();
    --end
	
    --if tostring(RoleInfoSystem.CurShowPlayerInfoUid) ~= DataMgr.roleData.uid then

	RoleInfoSystem.get_profile_info_req(RoleInfoSystem.CurShowPlayerInfoUid)
	--end
	-- 请求个人成就总览数据

	if RoleInfoSystem.AchievementSummaryGet ~= RoleInfoSystem.CurShowPlayerInfoUid then
		AchievementSystem.get_achievement_summary_req(RoleInfoSystem.CurShowPlayerInfoUid);
	else
		RoleInfoUI.RefreshSummaryUI();
	end
end

function RoleInfoSystem.Release()
	log("RoleInfoSystem Release");
	--RoleInfoSystem.Update_Ctrl = 0;
	RoleInfoSystem.CurShowPlayerInfoUid = 0
	RoleInfoSystem.curseasonid = 0;
	RoleInfoSystem.PlatID = "";
	RoleInfoSystem.IsMaxLevel = false;
	RoleInfoSystem.IsFriend = false;
	RoleInfoSystem.IsMaxPveLevel = false;

	RoleInfoSystem.PersonalBasicInfo = {};
	RoleInfoSystem.PersonalTotalRankInfo = {};
	RoleInfoSystem.PersonalTotalScoreInfo = {};
	RoleInfoSystem.CombatTotalInfoList = {};
	RoleInfoSystem.CombatSurviveInfoList = {};
	RoleInfoSystem.CombatScoreInfoList = {};
	RoleInfoSystem.CombatBattleInfoList = {};
	RoleInfoSystem.CombatGradeInfoList = {};
	RoleInfoSystem.FPPPersonalTotalRankInfo = {};
	RoleInfoSystem.FPPPersonalTotalScoreInfo = {};
	RoleInfoSystem.FPPCombatTotalInfoList = {};
	RoleInfoSystem.FPPCombatSurviveInfoList = {};
	RoleInfoSystem.FPPCombatScoreInfoList = {};
	RoleInfoSystem.FPPCombatBattleInfoList = {};
	RoleInfoSystem.FPPCombatGradeInfoList = {};
	RoleInfoSystem.IntimateInfoList = {};
	RoleInfoSystem.HonorWallInfoList = {};
	RoleInfoSystem.AllSeasonIDList = {};

	EventSystem:unregistEvent(EVENTTYPE_RANK, EVENTID_WARZONE_UPDATE_AVATAR, RoleInfoSystem.UpdateAvatarRsp)
end

function RoleInfoSystem.SetEmpty()
	log("RoleInfoSystem SetEmpty");
	
	RoleInfoSystem.PersonalBasicInfo = {};
	RoleInfoSystem.PersonalTotalRankInfo = {};
	RoleInfoSystem.PersonalTotalScoreInfo = {};
	RoleInfoSystem.CombatTotalInfoList = {};
	RoleInfoSystem.CombatSurviveInfoList = {};
	RoleInfoSystem.CombatScoreInfoList = {};
	RoleInfoSystem.CombatBattleInfoList = {};
	RoleInfoSystem.CombatGradeInfoList = {};
	RoleInfoSystem.FPPPersonalTotalRankInfo = {};
	RoleInfoSystem.FPPPersonalTotalScoreInfo = {};
	RoleInfoSystem.FPPCombatTotalInfoList = {};
	RoleInfoSystem.FPPCombatSurviveInfoList = {};
	RoleInfoSystem.FPPCombatScoreInfoList = {};
	RoleInfoSystem.FPPCombatBattleInfoList = {};
	RoleInfoSystem.FPPCombatGradeInfoList = {};
	RoleInfoSystem.HonorWallInfoList = {};
	
	RoleInfoSystem.PersonalBasicInfo =
	{
		role_name = "",
		role_id = "",
		role_sex = "",
		role_nation = "",
		role_image = "",
		role_upvote = 0,
		role_curlevel = "",
		role_nextlevel = "",
		role_curexpnum = "",
		role_needexpnum = "",
		role_sign = "",
		role_curlevelnum = 0,
		role_nextlevelnum = 0,
		role_segment_solo = 0,
		role_segment_double = 0,
		role_segment_team = 0,
		role_segment_max = 0,
		role_all_zone_segment_max = 0,
		role_startup_type = 0,
		role_qqvip = 0,
        role_avatar_frame = 0,
        all_segment_info = {},
		role_segmentFPP_solo = 0,
		role_segmentFPP_double = 0,
		role_segmentFPP_team = 0,
		role_segmentFPP_max = 0,
		role_upassIsBuy = 0,
		role_upassUiShow = 0,
		role_upassLevel = 0,  		--通行证等级

		role_pve_expnum = 0, --pve 经验
		role_pve_levelnum = 0, --pve level
		role_pve_levelname = "",
		role_pve_nextlevelname = "",
		role_pve_needexpnum = 0,

	};
	
	RoleInfoSystem.PersonalTotalRankInfo =
	{
		role_totalrank = "",
	}
	RoleInfoSystem.FPPPersonalTotalRankInfo =
	{
		role_totalrank = "",
	}
	
	RoleInfoSystem.PersonalTotalScoreInfo =
	{
		role_totalscore = 0;
	}
	RoleInfoSystem.FPPPersonalTotalScoreInfo =
	{
		role_totalscore = 0;
	}
	
	for i = 1, 4 do
		RoleInfoSystem.CombatTotalInfoList[i] =
		{
			role_allmatchnum = "",
			role_winnum = "",
			role_toptennum = "",
			role_killnum = "",
			role_kd = "",
			role_critrate = "",
		};
		RoleInfoSystem.FPPCombatTotalInfoList[i] =
		{
			role_allmatchnum = "",
			role_winnum = "",
			role_toptennum = "",
			role_killnum = "",
			role_kd = "",
			role_critrate = "",
		};
	end
	
	for i = 1, 3 do
		RoleInfoSystem.CombatSurviveInfoList[i] =
		{
			role_maxsurvivetime = "",
			role_avesurvivetime = "",
			role_maxdistance = "",
			role_avedistance = "",
			role_aveheal = "",
			role_aidcount = "",
			role_winrate = "",
			role_toptenrate = "",
		};
		RoleInfoSystem.FPPCombatSurviveInfoList[i] =
		{
			role_maxsurvivetime = "",
			role_avesurvivetime = "",
			role_maxdistance = "",
			role_avedistance = "",
			role_aveheal = "",
			role_aidcount = "",
			role_winrate = "",
			role_toptenrate = "",
		};
		
		RoleInfoSystem.CombatScoreInfoList[i] =
		{
			role_score = "",
			role_killscore = "",
			role_rankscore = "",
		};
		RoleInfoSystem.FPPCombatScoreInfoList[i] =
		{
			role_score = "",
			role_killscore = "",
			role_rankscore = "",
		};
		
		RoleInfoSystem.CombatBattleInfoList[i] =
		{
			role_hitrate = "",
			role_critcount = "",
			role_maxkill = "",
			role_maxdamage = "",
			role_avedamage = "",
		};
		RoleInfoSystem.FPPCombatBattleInfoList[i] =
		{
			role_hitrate = "",
			role_critcount = "",
			role_maxkill = "",
			role_maxdamage = "",
			role_avedamage = "",
		};
		
		RoleInfoSystem.CombatGradeInfoList[i] =
		{
			survive_score = "",
			top1_score = "",
			rating_score = "",
			fight_score = "",
			assist_score = "",
			sum_score = "",
			grade = "0",
		};
		RoleInfoSystem.FPPCombatGradeInfoList[i] =
		{
			survive_score = "",
			top1_score = "",
			rating_score = "",
			fight_score = "",
			assist_score = "",
			sum_score = "",
			grade = "0",
		};
	end
    
    RoleInfoSystem.top1w_score = 0;
	RoleInfoSystem.fpp_top1w_score = 0;
	
	RoleInfoUI.SetEmptyData();
end

function RoleInfoSystem.IsRoleFriend(uid)
	log("RoleInfoSystem IsRoleFriend");
	for k,v in pairs(ID_INNER_FRIENDLIST) do
		if tostring(v) == tostring(uid) then
			RoleInfoSystem.IsFriend = true;
			return;
		end
	end
end

--获取table长度
function RoleInfoSystem.GetTableLength(tab)
	if type(tab) ~= "table" then
		log("tab is not a table!");
		return 0;
	end
	
	local count = 0;
	for k,v in pairs(tab) do
		count = count + 1;
	end
	return count;
end

--请求玩家基本信息
function RoleInfoSystem.get_profile_info_req(uid)
	log("get_profile_info_req:" .. tostring(uid));

	if RoleInfoSystem.CurShowPlayerInfoUid == uid then
		RoleInfoSystem.PersonalBasicInfo.role_id = uid
	end
	
	local needRefresh = true
	if RoleInfoSystem.RoleBasicInfoHasRefresh[tonumber(uid)] then
		--如果已经有了rankdata了
		if tostring(uid) == DataMgr.roleData.uid and DataMgr.roleData.rankdata then
			needRefresh = false

			BP_RoleInfo_HasGetPersonalBasicInfo = true

			RoleInfoSystem.GetSelfBasicInfo();

			--log_tree("RoleInfoSystem.get_profile_info_req.PersonalBasicInfo", RoleInfoSystem.PersonalBasicInfo)

		end

		--以及缓存过rankdata了
		if tostring(uid) ~= DataMgr.roleData.uid  then
			local profile = ProfileMgr.GetPlayerDataByUid(uid)
			if profile and profile.rankdata then
				needRefresh = false

				BP_RoleInfo_HasGetPersonalBasicInfo = true

				RoleInfoSystem.get_role_basic_info_rsp({profile})
			end
		end
	end

	log("get_profile_info_req needRefresh:" .. tostring(needRefresh));
	if needRefresh then
		ProfileMgr.GetProfileList({tonumber(uid)}, function(listInfo)
			log_tree("listInfo:", listInfo)
			BP_RoleInfo_HasGetPersonalBasicInfo = true

			--profile.rankdata
			RoleInfoSystem.RoleBasicInfoHasRefresh[tonumber(uid)] = true

			local profile = ProfileMgr.GetPlayerDataByUid(uid)
			if profile and listInfo[1] then
				profile.rankdata = listInfo[1].rankdata
			end
			
			if tostring(uid) ~= DataMgr.roleData.uid then
				RoleInfoSystem.get_role_basic_info_rsp(listInfo)
			else
				RoleInfoSystem.GetSelfBasicInfo();
			end
		end, true, false, 1);
	end
end

function RoleInfoSystem.get_avatar_show_req(uid, source)
	local needReq = true
	if RoleInfoSystem.WearDataHasRefresh[tonumber(uid)] then
		local roleData = ProfileMgr.GetRoleInfoDataByUid(uid);
		if roleData ~= nil then
			EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_WARZONE_UPDATE_AVATAR, tonumber(uid));
			needReq = false
		end
	end

	log("RoleInfoSystem GetRoleAvatarWearReq " .. tostring(uid) .. ",needReq:" .. tostring(needReq))

	if needReq then
		ProfileMgr.get_avatar_show_req(uid, source);
	end
end

function RoleInfoSystem.UpdateAvatarRsp(eventType, eventID, uid)
	RoleInfoSystem.WearDataHasRefresh[tonumber(uid)] = true
end


--请求玩家排行榜信息
function RoleInfoSystem.get_role_rank_info_req(uid, rank_type, zoneId)
	log("get_role_rank_info_req, zoneId = "..zoneId);
	NetUtil.SendPriorityPkg(false, "get_one_user_rank_rsp", "get_one_user_rank", "roleinfo_tpp", zoneId, tonumber(uid), score_type.total_rating);
	NetUtil.SendPriorityPkg(false, "get_one_user_rank_rsp", "get_one_user_rank", "roleinfo_fpp", zoneId, tonumber(uid), score_type.fpp_total_rating);
end

--请求玩家战绩信息
function RoleInfoSystem.get_role_battle_info_req(uid, zoneId)
	--log("get_role_battle_info_req, zoneId = "..zoneId);
	NetUtil.SendPriorityPkg(false, "get_role_battle_info_rsp", "get_role_battle_info", tonumber(uid), nil, BP_COMBAT_MSG_TYPE_ROLEINFO, zoneId);
end

function RoleInfoSystem.get_role_lbs_battle_info_req(uid)
	log("get_role_lbs_battle_info_req");
	NetUtil.SendPriorityPkg(false, "get_role_lbs_battle_info_rsp", "get_role_lbs_battle_info", tonumber(uid), nil);
end

function RoleInfoSystem.get_role_privacy()
	NetUtil.SendPkg("get_role_privacy");
end

--请求玩家历史赛季信息
function RoleInfoSystem.get_role_history_season_battle(uid, season_id, zoneId)
	log("get_role_history_season_battle uid:" .. tostring(uid) .. ",season_id:" .. tostring(season_id) .. ",zoneId:" .. zoneId);
	NetUtil.SendPriorityPkg(false, "get_role_history_season_battle_rsp", "get_role_history_season_battle", tonumber(uid), season_id, zoneId);
end

function RoleInfoSystem.get_role_privacy_rsp(privacy)
	SettingUI.get_role_privacy_rsp(privacy);
end

--请求修改签名
function RoleInfoSystem.send_modify_roleinfo_sign()
	log("send_modify_roleinfo_sign");
	NetUtil.SendPriorityPkg(false, "modify_role_signature_respond", "modify_role_signature", BP_Sign);
end



--拉取自己的概要信息
function RoleInfoSystem.GetSelfBasicInfo()
	--if RoleInfoSystem.Update_Ctrl >= RoleInfoSystem.GetDataMaxTimes then
	--	RoleInfoSystem.Update_Ctrl = 0;
	--end
	--RoleInfoSystem.Update_Ctrl = RoleInfoSystem.Update_Ctrl + 1;
	
	
	RoleInfoSystem.PersonalBasicInfo = {};
	local corpsID = 0
	if DataMgr.corpsInfo.id ~= nil then
		corpsID = DataMgr.corpsInfo.id
	end
	log("GetSelfBasicInfo corpsid:"..tostring(DataMgr.corpsInfo.id))
	RoleInfoSystem.PersonalBasicInfo =
	{
		role_name = DataMgr.roleData.nickName,
		role_id = DataMgr.roleData.uid,
		role_sex = DataMgr.roleData.gender - 1,
		role_nation = DataMgr.roleData.nation,
		role_image = DataMgr.roleData.headIconUrl,
		role_upvote = DataMgr.roleData.upvote or 0,
		role_curlevel = "",
		role_nextlevel = "",
		role_curexpnum = DataMgr.roleData.roleExp,
		role_needexpnum = "",
		role_sign = DataMgr.roleData.signature,
		role_startup_type = BP_StartUpType,
		role_qqvip = DataMgr.roleData.qq_vip,
		role_credit = DataMgr.roleData.credit,
		role_corpsid = corpsID,
		role_upassIsBuy = DataMgr.roleData.upass.is_buy,
		role_upassUiShow = (DataMgr.roleData.upass.switch and DataMgr.roleData.upass.switch.ui == true) and 1 or 0,
		role_upassLevel = DataMgr.roleData.upass.level,
		role_aliasId = DataMgr.roleData.alias.id,
		role_aliasTitle = DataMgr.roleData.alias.title,
		role_aliasReceiveTime = DataMgr.roleData.alias.receive_time,
		role_aliasExpireTime = DataMgr.roleData.alias.expire_ts,
		role_aliasNation = DataMgr.roleData.alias.nation,
		role_corpAliasId = DataMgr.roleData.corps_alias_data.cur_corps_alias_id,
		role_carteamId = DataMgr.roleData.carteamId or 0,

		role_pve_expnum = DataMgr.roleData.pve_exp, --pve 经验
		role_pve_levelnum = DataMgr.roleData.pve_level, --pve level
		role_pve_levelname = "",
		role_pve_nextlevelname = "",
		role_pve_needexpnum = 0,

	};

	BP_RoleCorpAliasReddot = DataMgr.roleData.corps_alias_data.red_point;

	if corpsID ~= nil and tonumber(corpsID) > 0 then
		RoleInfoSystem.get_corps_summary_req(corpsID, tonumber(DataMgr.roleData.uid))
	else
		RoleInfoUI.RefreshCorpsSummary(0, {})
	end
	
	RoleInfoSystem.SetElementToString(RoleInfoSystem.PersonalBasicInfo);
	RoleInfoSystem.PersonalBasicInfo["role_curlevelnum"] = tonumber(DataMgr.roleData.level);
	RoleInfoSystem.PersonalBasicInfo["role_nextlevelnum"] = tonumber(DataMgr.roleData.level) + 1;

	--选择战绩最大的区
	if DataMgr.roleData.rankdata and BP_Back_ShowRoleInfoOfZoneId == 0 then
		log("RoleInfoSystem.GetSelfBasicInfo: ".. tostring(BP_Back_ShowRoleInfoOfZoneId));

		--log_tree("rankdata:", DataMgr.roleData.rankdata)
		local ZoneId = RoleInfoSystem.GetMaxSegmentScoreZone(DataMgr.roleData.rankdata)
		if ZoneId ~= 0 then
			BP_Back_ShowRoleInfoOfZoneId = ZoneId
		end
		log("RoleInfoSystem.GetSelfBasicInfo1: ".. tostring(BP_Back_ShowRoleInfoOfZoneId) .. ",BP_RoleInfo_CombatShootTypeID:" .. BP_RoleInfo_CombatShootTypeID);
	end
	
    --国际化：处理个人段位信息（国服的单区数据改为多区）
	RoleInfoSystem.RoleSegmentInfo();


	
    --[[
	RoleInfoSystem.PersonalBasicInfo["role_segment_solo"] = tonumber(DataMgr.roleData.segment.solo);
	RoleInfoSystem.PersonalBasicInfo["role_segment_double"] = tonumber(DataMgr.roleData.segment.double);
	RoleInfoSystem.PersonalBasicInfo["role_segment_team"] = tonumber(DataMgr.roleData.segment.team);
    RoleInfoSystem.PersonalBasicInfo["role_avatar_frame"] = tonumber(DataMgr.roleData.cur_avatar_box_id);
	if DataMgr.roleData.segment.solo > DataMgr.roleData.segment.double then
		if DataMgr.roleData.segment.solo > DataMgr.roleData.segment.team then
			RoleInfoSystem.PersonalBasicInfo["role_segment_max"] = tonumber(DataMgr.roleData.segment.solo);
		else
			RoleInfoSystem.PersonalBasicInfo["role_segment_max"] = tonumber(DataMgr.roleData.segment.team);
		end
	elseif DataMgr.roleData.segment.double > DataMgr.roleData.segment.team then
		RoleInfoSystem.PersonalBasicInfo["role_segment_max"] = tonumber(DataMgr.roleData.segment.double);
	else
		RoleInfoSystem.PersonalBasicInfo["role_segment_max"] = tonumber(DataMgr.roleData.segment.team);
	end
	]]
	local curlevel = tonumber(DataMgr.roleData.level);
	-- local curlevel = tonumber(100);
	--判断是否满级
	if curlevel >= 100 then
		local curmilitarylevel = Client.GetTableData("MilitaryRankLevel", 100);
		RoleInfoSystem.PersonalBasicInfo["role_curlevel"] = tostring(curmilitarylevel.MilitaryRankName);
		RoleInfoSystem.PersonalBasicInfo["role_curexpnum"] = "";
		RoleInfoSystem.PersonalBasicInfo["role_needexpnum"] = "";
		RoleInfoSystem.PersonalBasicInfo["role_nextlevel"] = "";
		RoleInfoSystem.PersonalBasicInfo["role_curlevelnum"] = 100;
		RoleInfoSystem.PersonalBasicInfo["role_avatar_frame"] = tonumber(DataMgr.roleData.cur_avatar_box_id);
		RoleInfoSystem.IsMaxLevel = true;
	elseif curlevel > 0 then
		local curmilitarylevel = Client.GetTableData("MilitaryRankLevel", curlevel);
		local nextmilitarylevel = Client.GetTableData("MilitaryRankLevel", curlevel + 1);
		RoleInfoSystem.PersonalBasicInfo["role_curlevel"] = tostring(curmilitarylevel.MilitaryRankName);
		RoleInfoSystem.PersonalBasicInfo["role_needexpnum"] = tostring(curmilitarylevel.Exp);
		RoleInfoSystem.PersonalBasicInfo["role_nextlevel"] = tostring(nextmilitarylevel.MilitaryRankName);
		RoleInfoSystem.PersonalBasicInfo["role_avatar_frame"] = tonumber(DataMgr.roleData.cur_avatar_box_id);
		RoleInfoSystem.IsMaxLevel = false;
	end

	local curPveLevel = tonumber(DataMgr.roleData.pve_level);
	if curPveLevel >= 100 then
		local curPveLevelItem = Client.GetTableData("PveLevel", 100);
		local PveLevelItem99 = Client.GetTableData("PveLevel", 99);
		RoleInfoSystem.PersonalBasicInfo["role_pve_levelname"] = tostring(curPveLevelItem.name);
		RoleInfoSystem.PersonalBasicInfo["role_pve_expnum"] = PveLevelItem99.Exp;
		RoleInfoSystem.PersonalBasicInfo["role_pve_needexpnum"] = PveLevelItem99.Exp;
		RoleInfoSystem.PersonalBasicInfo["role_pve_nextlevelname"] = "";
		RoleInfoSystem.PersonalBasicInfo["role_pve_levelnum"] = 100;
		RoleInfoSystem.IsMaxPveLevel = true;
	elseif curPveLevel > 0 then
		local curPveLevelItem = Client.GetTableData("PveLevel", curPveLevel);
		local nextPveLevelItem= Client.GetTableData("PveLevel", curPveLevel + 1);
		RoleInfoSystem.PersonalBasicInfo["role_pve_levelname"] = tostring(curPveLevelItem.name);
		RoleInfoSystem.PersonalBasicInfo["role_pve_needexpnum"] = tostring(curPveLevelItem.Exp);
		RoleInfoSystem.PersonalBasicInfo["role_pve_nextlevelname"] = tostring(nextPveLevelItem.name);
		RoleInfoSystem.IsMaxPveLevel = false;
	end
    
    RoleInfoSystem.SocialCard = {}
	
	--log_tree("PersonalBasicInfo:",RoleInfoSystem.PersonalBasicInfo);
	
	--if RoleInfoSystem.Update_Ctrl == RoleInfoSystem.GetDataMaxTimes then
    RoleInfoSystem.UpdateRankNo()
	RoleInfoSystem.GetPlayerCarTeamInfo(false);

	--更新玩家信息
	EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_ROLEINFO);
	--end

	--log_tree("RoleInfoSystem.GetSelfBasicInfo", RoleInfoSystem.PersonalBasicInfo);
end

--计算最大段位的区
function RoleInfoSystem.GetMaxSegmentScoreZone(rankdata)
	local MaxZone = 0
	local MaxScore = 0
	for i, ZoneInfo in pairs(TeamUpSystem.ChooseZoneList) do
		if ZoneInfo.zone_id and rankdata[ZoneInfo.zone_id] then
			local fRate = rankdata[ZoneInfo.zone_id].fpp_total_rank_rating or 0
			local Rate = rankdata[ZoneInfo.zone_id].total_rank_rating or 0

			local max = fRate > Rate and fRate or Rate
			if max > MaxScore then
				MaxScore = max
				MaxZone = ZoneInfo.zone_id
			end
		end
	end

	return MaxZone
end

-- 设置段位信息( 带段位信息的)
function RoleInfoSystem.RoleSegmentInfo()
    -- 设置查看当前zone的段位信息
    DataMgr.SetCurSegment(BP_Back_ShowRoleInfoOfZoneId);
    RoleInfoSystem.PersonalBasicInfo["role_segment_solo"] = tonumber(DataMgr.roleData.segment.solo);
	RoleInfoSystem.PersonalBasicInfo["role_segment_double"] = tonumber(DataMgr.roleData.segment.double);
	RoleInfoSystem.PersonalBasicInfo["role_segment_team"] = tonumber(DataMgr.roleData.segment.team);
	RoleInfoSystem.PersonalBasicInfo["role_avatar_frame"] = tonumber(DataMgr.roleData.cur_avatar_box_id);
	RoleInfoSystem.PersonalBasicInfo["role_segmentFPP_solo"] = tonumber(DataMgr.roleData.segment.fpp_solo);
	RoleInfoSystem.PersonalBasicInfo["role_segmentFPP_double"] = tonumber(DataMgr.roleData.segment.fpp_double);
	RoleInfoSystem.PersonalBasicInfo["role_segmentFPP_team"] = tonumber(DataMgr.roleData.segment.fpp_team);

	if DataMgr.roleData.segment.solo > DataMgr.roleData.segment.double then
		if DataMgr.roleData.segment.solo > DataMgr.roleData.segment.team then
			RoleInfoSystem.PersonalBasicInfo["role_segment_max"] = tonumber(DataMgr.roleData.segment.solo);
			RoleInfoUI.SetCombatModelTypeMax(model_type["solo_model"]);
		else
			RoleInfoSystem.PersonalBasicInfo["role_segment_max"] = tonumber(DataMgr.roleData.segment.team);
			RoleInfoUI.SetCombatModelTypeMax(model_type["team_model"]);
		end
	elseif DataMgr.roleData.segment.double > DataMgr.roleData.segment.team then
		RoleInfoSystem.PersonalBasicInfo["role_segment_max"] = tonumber(DataMgr.roleData.segment.double);
		RoleInfoUI.SetCombatModelTypeMax(model_type["double_model"]);
	else
		RoleInfoSystem.PersonalBasicInfo["role_segment_max"] = tonumber(DataMgr.roleData.segment.team);
		RoleInfoUI.SetCombatModelTypeMax(model_type["team_model"]);
	end

	if DataMgr.roleData.segment.fpp_solo > DataMgr.roleData.segment.fpp_double then
		if DataMgr.roleData.segment.fpp_solo > DataMgr.roleData.segment.fpp_team then
			RoleInfoSystem.PersonalBasicInfo["role_segmentFPP_max"] = DataMgr.roleData.segment.fpp_solo;
			if RoleInfoSystem.PersonalBasicInfo["role_segmentFPP_max"] > RoleInfoSystem.PersonalBasicInfo["role_segment_max"] then
				RoleInfoUI.SetCombatModelTypeMax(model_type["solo_model"]);
				RoleInfoUI.SetShootTypeMax(ShootType["FPPType"]);
			else
				RoleInfoUI.SetShootTypeMax(ShootType["TPPType"]);
			end
		else
			RoleInfoSystem.PersonalBasicInfo["role_segmentFPP_max"] = DataMgr.roleData.segment.fpp_team;
			if RoleInfoSystem.PersonalBasicInfo["role_segmentFPP_max"] > RoleInfoSystem.PersonalBasicInfo["role_segment_max"] then
				RoleInfoUI.SetCombatModelTypeMax(model_type["team_model"]);
				RoleInfoUI.SetShootTypeMax(ShootType["FPPType"]);
			else
				RoleInfoUI.SetShootTypeMax(ShootType["TPPType"]);
			end
		end
	elseif DataMgr.roleData.segment.fpp_double > DataMgr.roleData.segment.fpp_team then
		RoleInfoSystem.PersonalBasicInfo["role_segmentFPP_max"] = DataMgr.roleData.segment.fpp_double;
		if RoleInfoSystem.PersonalBasicInfo["role_segmentFPP_max"] > RoleInfoSystem.PersonalBasicInfo["role_segment_max"] then
			RoleInfoUI.SetCombatModelTypeMax(model_type["double_model"]);
			RoleInfoUI.SetShootTypeMax(ShootType["FPPType"]);
		else
			RoleInfoUI.SetShootTypeMax(ShootType["TPPType"]);
		end
	else
		RoleInfoSystem.PersonalBasicInfo["role_segmentFPP_max"] = DataMgr.roleData.segment.fpp_team;
		if RoleInfoSystem.PersonalBasicInfo["role_segmentFPP_max"] > RoleInfoSystem.PersonalBasicInfo["role_segment_max"] then
			RoleInfoUI.SetCombatModelTypeMax(model_type["team_model"]);
			RoleInfoUI.SetShootTypeMax(ShootType["FPPType"]);
		else
			RoleInfoUI.SetShootTypeMax(ShootType["TPPType"]);
		end
	end
	RoleInfoSystem.PersonalBasicInfo["role_all_zone_segment_max"] = DataMgr.GetMaxRankLevel()
end


--响应玩家基本信息
function RoleInfoSystem.get_role_basic_info_rsp(role_basic_info_list)

	log_tree("get_role_basic_info_rsp ret=", role_basic_info_list);
	
	--if RoleInfoSystem.Update_Ctrl >= RoleInfoSystem.GetDataMaxTimes then
	--	RoleInfoSystem.Update_Ctrl = 0;
	--end
	--RoleInfoSystem.Update_Ctrl = RoleInfoSystem.Update_Ctrl + 1;
	--log("11111111111111111111111111111111111111: "..RoleInfoSystem.Update_Ctrl);
	
	RoleInfoSystem.PersonalBasicInfo = {};
	local ProfileInfo = {};

	local index, currProfileInfo = next(role_basic_info_list)

	if currProfileInfo == nil then
		log("get_role_basic_info_rsp:nil")
		return
	end

	--log_tree("ProfileInfo", ProfileInfo);
	local creditValue = 100
	if currProfileInfo.credit ~= nil then
		creditValue = currProfileInfo.credit
	end
	local corpsID = 0
	if currProfileInfo.corps_id ~= nil then
		corpsID = currProfileInfo.corps_id
	end

	RoleInfoSystem.PersonalBasicInfo =
	{
		role_name = currProfileInfo.nickName,
		role_id = currProfileInfo.uid,
		role_sex = currProfileInfo.sex - 1,
		role_nation = currProfileInfo.nation,
		role_image = currProfileInfo.picUrl,
		role_upvote = currProfileInfo.upvote or 0,
		role_curlevel = "",
		role_nextlevel = "",
		role_curexpnum = currProfileInfo.exp,
		role_needexpnum = "",
		role_sign = currProfileInfo.signature,
		role_startup_type = GetSafeNumber(currProfileInfo.startup_type),
		role_qqvip = GetSafeNumber(currProfileInfo.qq_vip),
		role_credit = GetSafeNumber(creditValue),
		role_corpsid = corpsID,
		role_upassIsBuy = currProfileInfo.upass.is_buy,
		role_upassUiShow = (currProfileInfo.upass.switch.ui == true) and 1 or 0,
		role_upassLevel = currProfileInfo.upass.level,
		role_aliasId = currProfileInfo.alias.id,
		role_aliasTitle = currProfileInfo.alias.title,
		role_aliasNation = currProfileInfo.alias.nation,
		role_aliasReceiveTime = 0,
		role_aliasExpireTime = 0,
		role_corpAliasId = currProfileInfo.corp_alias_id,
		role_carteamId = currProfileInfo.carteam_id or 0,

		role_pve_expnum = currProfileInfo.pve_exp or 0, --pve 经验
		role_pve_levelnum = currProfileInfo.pve_level or 1, --pve level
		role_pve_levelname = "",
		role_pve_nextlevelname = "",
		role_pve_needexpnum = 0,
	};
	
	--选择战绩最大的区
	if currProfileInfo.rankdata and BP_Back_ShowRoleInfoOfZoneId == 0 then
		log("RoleInfoSystem.get_role_basic_info_rsp: ".. tostring(BP_Back_ShowRoleInfoOfZoneId) .. ",CombatShootTypeID:" .. BP_RoleInfo_CombatShootTypeID);
		local ZoneId = RoleInfoSystem.GetMaxSegmentScoreZone(currProfileInfo.rankdata)
		if ZoneId ~= 0 then
			BP_Back_ShowRoleInfoOfZoneId = ZoneId
		end
		log("RoleInfoSystem.get_role_basic_info_rsp2: " .. tostring(BP_Back_ShowRoleInfoOfZoneId) .. ",CombatShootTypeID:" .. BP_RoleInfo_CombatShootTypeID);
	end
	
	--请求军团信息
	if corpsID ~= nil and tonumber(corpsID) > 0 then
		RoleInfoSystem.get_corps_summary_req(corpsID, tonumber(currProfileInfo.uid))
	else
		RoleInfoUI.RefreshCorpsSummary(0, {})
	end
	RoleInfoSystem.SetElementToString(RoleInfoSystem.PersonalBasicInfo);
	RoleInfoSystem.PersonalBasicInfo["role_curlevelnum"] = tonumber(currProfileInfo.level);
	RoleInfoSystem.PersonalBasicInfo["role_nextlevelnum"] = tonumber(currProfileInfo.level) + 1;
	--[[
    RoleInfoSystem.PersonalBasicInfo["role_segment_solo"] = tonumber(ProfileInfo[1].segment_info[1]);
	RoleInfoSystem.PersonalBasicInfo["role_segment_double"] = tonumber(ProfileInfo[1].segment_info[2]);
	RoleInfoSystem.PersonalBasicInfo["role_segment_team"] = tonumber(ProfileInfo[1].segment_info[3]);
    RoleInfoSystem.PersonalBasicInfo["role_avatar_frame"] = tonumber(ProfileInfo[1].cur_avatar_box_id);
	if ProfileInfo[1].segment_info[1] > ProfileInfo[1].segment_info[2] then
		if ProfileInfo[1].segment_info[1] > ProfileInfo[1].segment_info[3] then
			RoleInfoSystem.PersonalBasicInfo["role_segment_max"] = tonumber(ProfileInfo[1].segment_info[1]);
		else
			RoleInfoSystem.PersonalBasicInfo["role_segment_max"] = tonumber(ProfileInfo[1].segment_info[3]);
		end
	elseif ProfileInfo[1].segment_info[2] > ProfileInfo[1].segment_info[3] then
		RoleInfoSystem.PersonalBasicInfo["role_segment_max"] = tonumber(ProfileInfo[1].segment_info[2]);
	else
		RoleInfoSystem.PersonalBasicInfo["role_segment_max"] = tonumber(ProfileInfo[1].segment_info[3]);
	end
	]]
    --RoleInfoSystem.PersonalBasicInfo["role_segment_solo"] = tonumber(ProfileInfo[1].segment_info[1]);
	--RoleInfoSystem.PersonalBasicInfo["role_segment_double"] = tonumber(ProfileInfo[1].segment_info[2]);
	--RoleInfoSystem.PersonalBasicInfo["role_segment_team"] = tonumber(ProfileInfo[1].segment_info[3]);
    ----------------------------------------------------------INTL modify ------------------------------------------------------------------
    RoleInfoSystem.PersonalBasicInfo.all_segment_info = currProfileInfo.segment_info;
    --[[
    for k, v in pairs(RoleInfoSystem.PersonalBasicInfo.all_segment_info) do
        RoleInfoSystem.PersonalBasicInfo["role_segment_solo"] = tonumber (RoleInfoSystem.PersonalBasicInfo.all_segment_info [k][1]);
        RoleInfoSystem.PersonalBasicInfo["role_segment_double"] = tonumber(RoleInfoSystem.PersonalBasicInfo.all_segment_info [k][2]);
        RoleInfoSystem.PersonalBasicInfo["role_segment_team"] = tonumber(RoleInfoSystem.PersonalBasicInfo.all_segment_info [k][3]);
        break;
    end]]
    --waynedong debug 212
   -- RoleInfoSystem.PersonalBasicInfo["role_segment_solo"],  RoleInfoSystem.PersonalBasicInfo["role_segment_double"],  RoleInfoSystem.PersonalBasicInfo["role_segment_team"] =  FuncUtil.GetMaxSegement( RoleInfoSystem.PersonalBasicInfo.all_segment_info );
    
    if RoleInfoSystem.PersonalBasicInfo.all_segment_info[BP_Back_ShowRoleInfoOfZoneId]~=nil then
        RoleInfoSystem.PersonalBasicInfo["role_segment_solo"] = tonumber (RoleInfoSystem.PersonalBasicInfo.all_segment_info [BP_Back_ShowRoleInfoOfZoneId][segment_type.solo]);
        RoleInfoSystem.PersonalBasicInfo["role_segment_double"] = tonumber(RoleInfoSystem.PersonalBasicInfo.all_segment_info [BP_Back_ShowRoleInfoOfZoneId][segment_type.double]);
        RoleInfoSystem.PersonalBasicInfo["role_segment_team"] = tonumber(RoleInfoSystem.PersonalBasicInfo.all_segment_info [BP_Back_ShowRoleInfoOfZoneId][segment_type.team]);
		RoleInfoSystem.PersonalBasicInfo["role_segmentFPP_solo"] = tonumber(RoleInfoSystem.PersonalBasicInfo.all_segment_info [BP_Back_ShowRoleInfoOfZoneId][segment_type.fpp_solo]);
		RoleInfoSystem.PersonalBasicInfo["role_segmentFPP_double"] = tonumber(RoleInfoSystem.PersonalBasicInfo.all_segment_info [BP_Back_ShowRoleInfoOfZoneId][segment_type.fpp_double]);
		RoleInfoSystem.PersonalBasicInfo["role_segmentFPP_team"] = tonumber(RoleInfoSystem.PersonalBasicInfo.all_segment_info [BP_Back_ShowRoleInfoOfZoneId][segment_type.fpp_team]);
    end
    if RoleInfoSystem.PersonalBasicInfo["role_segment_solo"] > RoleInfoSystem.PersonalBasicInfo["role_segment_double"]  then
		if RoleInfoSystem.PersonalBasicInfo["role_segment_solo"]  > RoleInfoSystem.PersonalBasicInfo["role_segment_team"] then
			RoleInfoSystem.PersonalBasicInfo["role_segment_max"] = (RoleInfoSystem.PersonalBasicInfo["role_segment_solo"] );
			RoleInfoUI.SetCombatModelTypeMax(model_type["solo_model"]);
		else
			RoleInfoSystem.PersonalBasicInfo["role_segment_max"] = (RoleInfoSystem.PersonalBasicInfo["role_segment_team"]);
			RoleInfoUI.SetCombatModelTypeMax(model_type["team_model"]);
		end
	elseif RoleInfoSystem.PersonalBasicInfo["role_segment_double"]  > RoleInfoSystem.PersonalBasicInfo["role_segment_team"] then
		RoleInfoSystem.PersonalBasicInfo["role_segment_max"] = (RoleInfoSystem.PersonalBasicInfo["role_segment_double"] );
		RoleInfoUI.SetCombatModelTypeMax(model_type["double_model"]);
	else
		RoleInfoSystem.PersonalBasicInfo["role_segment_max"] = (RoleInfoSystem.PersonalBasicInfo["role_segment_team"]);
		RoleInfoUI.SetCombatModelTypeMax(model_type["team_model"]);
	end
	if RoleInfoSystem.PersonalBasicInfo["role_segmentFPP_solo"] > RoleInfoSystem.PersonalBasicInfo["role_segmentFPP_double"] then
		if RoleInfoSystem.PersonalBasicInfo["role_segmentFPP_solo"] > RoleInfoSystem.PersonalBasicInfo["role_segmentFPP_team"] then
			RoleInfoSystem.PersonalBasicInfo["role_segmentFPP_max"] = RoleInfoSystem.PersonalBasicInfo["role_segmentFPP_solo"];
			if RoleInfoSystem.PersonalBasicInfo["role_segmentFPP_max"] > RoleInfoSystem.PersonalBasicInfo["role_segment_max"] then
				RoleInfoUI.SetCombatModelTypeMax(model_type["solo_model"]);
				RoleInfoUI.SetShootTypeMax(ShootType["FPPType"]);
			else
				RoleInfoUI.SetShootTypeMax(ShootType["TPPType"]);
			end
		else
			RoleInfoSystem.PersonalBasicInfo["role_segmentFPP_max"] = RoleInfoSystem.PersonalBasicInfo["role_segmentFPP_team"];
			if RoleInfoSystem.PersonalBasicInfo["role_segmentFPP_max"] > RoleInfoSystem.PersonalBasicInfo["role_segment_max"] then
				RoleInfoUI.SetCombatModelTypeMax(model_type["team_model"]);
				RoleInfoUI.SetShootTypeMax(ShootType["FPPType"]);
			else
				RoleInfoUI.SetShootTypeMax(ShootType["TPPType"]);
			end
		end
	elseif RoleInfoSystem.PersonalBasicInfo["role_segmentFPP_double"] > RoleInfoSystem.PersonalBasicInfo["role_segmentFPP_team"] then
		RoleInfoSystem.PersonalBasicInfo["role_segmentFPP_max"] = RoleInfoSystem.PersonalBasicInfo["role_segmentFPP_double"];
		if RoleInfoSystem.PersonalBasicInfo["role_segmentFPP_max"] > RoleInfoSystem.PersonalBasicInfo["role_segment_max"] then
			RoleInfoUI.SetCombatModelTypeMax(model_type["double_model"]);
			RoleInfoUI.SetShootTypeMax(ShootType["FPPType"]);
		else
			RoleInfoUI.SetShootTypeMax(ShootType["TPPType"]);
		end
	else
		RoleInfoSystem.PersonalBasicInfo["role_segmentFPP_max"] = RoleInfoSystem.PersonalBasicInfo["role_segmentFPP_team"];
		if RoleInfoSystem.PersonalBasicInfo["role_segmentFPP_max"] > RoleInfoSystem.PersonalBasicInfo["role_segment_max"] then
			RoleInfoUI.SetCombatModelTypeMax(model_type["team_model"]);
			RoleInfoUI.SetShootTypeMax(ShootType["FPPType"]);
		else
			RoleInfoUI.SetShootTypeMax(ShootType["TPPType"]);
		end
	end

	RoleInfoSystem.PersonalBasicInfo["role_all_zone_segment_max"] = 0;
	for _,v in pairs(RoleInfoSystem.PersonalBasicInfo.all_segment_info) do
		for _,SegmentLevel in pairs(v) do
			RoleInfoSystem.PersonalBasicInfo["role_all_zone_segment_max"] = math.max(RoleInfoSystem.PersonalBasicInfo["role_all_zone_segment_max"], SegmentLevel);
		end
	end
    -----------------------------------------------------------INTL modify -----------------------------------------------------------------
	
	local curlevel = tonumber(currProfileInfo.level);
	-- local curlevel = tonumber(100);
	--判断是否满级
	if curlevel >= 100 then
		local curmilitarylevel = Client.GetTableData("MilitaryRankLevel", 100);
		RoleInfoSystem.PersonalBasicInfo["role_curlevel"] = tostring(curmilitarylevel.MilitaryRankName);
		RoleInfoSystem.PersonalBasicInfo["role_curexpnum"] = "";
		RoleInfoSystem.PersonalBasicInfo["role_needexpnum"] = "";
		RoleInfoSystem.PersonalBasicInfo["role_nextlevel"] = "";
		RoleInfoSystem.PersonalBasicInfo["role_curlevelnum"] = 100;
		RoleInfoSystem.IsMaxLevel = true;
	elseif curlevel > 0 then
		local curmilitarylevel = Client.GetTableData("MilitaryRankLevel", curlevel);
		local nextmilitarylevel = Client.GetTableData("MilitaryRankLevel", curlevel + 1);
		RoleInfoSystem.PersonalBasicInfo["role_curlevel"] = tostring(curmilitarylevel.MilitaryRankName);
		RoleInfoSystem.PersonalBasicInfo["role_needexpnum"] = tostring(curmilitarylevel.Exp);
		RoleInfoSystem.PersonalBasicInfo["role_nextlevel"] = tostring(nextmilitarylevel.MilitaryRankName);
		RoleInfoSystem.IsMaxLevel = false;
	end

	local curPveLevel = tonumber(currProfileInfo.pve_level) or 1;
	if curPveLevel >= 100 then
		local curPveLevelItem = Client.GetTableData("PveLevel", 100);
		local PveLevelItem99 = Client.GetTableData("PveLevel", 99);
		RoleInfoSystem.PersonalBasicInfo["role_pve_levelname"] = tostring(curPveLevelItem.name);
		RoleInfoSystem.PersonalBasicInfo["role_pve_expnum"] = PveLevelItem99.pve_exp;
		RoleInfoSystem.PersonalBasicInfo["role_pve_needexpnum"] = PveLevelItem99.pve_exp;
		RoleInfoSystem.PersonalBasicInfo["role_pve_nextlevelname"] = "";
		RoleInfoSystem.PersonalBasicInfo["role_pve_levelnum"] = 100;
		RoleInfoSystem.IsMaxPveLevel = true;
	elseif curPveLevel > 0 then
		local curPveLevelItem = Client.GetTableData("PveLevel", curPveLevel);
		local nextPveLevelItem= Client.GetTableData("PveLevel", curPveLevel + 1);
		RoleInfoSystem.PersonalBasicInfo["role_pve_levelname"] = tostring(curPveLevelItem.name);
		RoleInfoSystem.PersonalBasicInfo["role_pve_needexpnum"] = tostring(curPveLevelItem.Exp or 0);
		RoleInfoSystem.PersonalBasicInfo["role_pve_nextlevelname"] = tostring(nextPveLevelItem.name);
		RoleInfoSystem.IsMaxPveLevel = false;
	end

    RoleInfoSystem.PersonalBasicInfo["role_avatar_frame"] = tonumber(currProfileInfo.cur_avatar_box_id);
	
    RoleInfoSystem.SocialCard = currProfileInfo.social_card
	
	--log_tree("PersonalBasicInfo:",RoleInfoSystem.PersonalBasicInfo);
	
	--if RoleInfoSystem.Update_Ctrl == RoleInfoSystem.GetDataMaxTimes then
    RoleInfoSystem.UpdateRankNo()

	RoleInfoSystem.GetPlayerCarTeamInfo(false);

	--更新玩家信息
		EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_ROLEINFO);
	--end

	--测试
	-- EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_ROLEINFO);
end

--响应玩家排行榜信息
function RoleInfoSystem.get_role_rank_info_rsp(client_data, res, zone_id, role_rank_info)
	--log("get_role_rank_info_rsp");
	
	--如果个人信息界面未打开的话
	if RoleInfoSystem.CurShowPlayerInfoUid == 0 then
		return 	
	end
	
	if client_data ~= "roleinfo_tpp" and client_data ~= "roleinfo_fpp" then
		return;
	end
	
	if res ~= 0 then
		log("get_role_rank_info_rsp1");
		print("Error: "..res);
		RoleInfoSystem.ProcessRankInfoError();
		return;
	end

	
    --log_tree("get_role_rank_info_rsp ret=",{client_data, res, role_rank_info});
	
	--if RoleInfoSystem.Update_Ctrl == RoleInfoSystem.GetDataMaxTimes then
	--	RoleInfoSystem.Update_Ctrl = 0;
	--end
	--RoleInfoSystem.Update_Ctrl = RoleInfoSystem.Update_Ctrl + 1;
	
	--第三人称
	if client_data == "roleinfo_tpp" then
		--log("22222222222222222222222222222222222222: "..RoleInfoSystem.Update_Ctrl);
		
		RoleInfoSystem.PersonalTotalRankInfo = {};
		
		if role_rank_info.rank_no == nil then
			--local data = Client.GetTableData("LocalizeRes", 102127);
			--local text = tostring(data.TextValue);
			local text = ""
			if type(role_rank_info.top1w) == "number" then
				RoleInfoSystem.top1w_score = role_rank_info.top1w
			end
			RoleInfoSystem.PersonalTotalRankInfo =
			{
				role_totalrank = "",
			}
		else
			RoleInfoSystem.PersonalTotalRankInfo =
			{
				role_totalrank = role_rank_info.rank_no,
			}
		end
		RoleInfoSystem.SetElementToString(RoleInfoSystem.PersonalTotalRankInfo);
	end
	
	--第一人称
	if client_data == "roleinfo_fpp" then
		--log("33333333333333333333333333333333333333: "..RoleInfoSystem.Update_Ctrl);
		
		RoleInfoSystem.FPPPersonalTotalRankInfo = {};
		
		if role_rank_info.rank_no == nil then
			--local data = Client.GetTableData("LocalizeRes", 102127);
			--local text = tostring(data.TextValue);
			local text = ""
			if type(role_rank_info.top1w) == "number" then
				RoleInfoSystem.fpp_top1w_score = role_rank_info.top1w
			end
			RoleInfoSystem.FPPPersonalTotalRankInfo =
			{
				role_totalrank = "",
			}
		else
			RoleInfoSystem.FPPPersonalTotalRankInfo =
			{
				role_totalrank = role_rank_info.rank_no,
			}
		end
		RoleInfoSystem.SetElementToString(RoleInfoSystem.FPPPersonalTotalRankInfo);
	end
	
	--if RoleInfoSystem.Update_Ctrl == RoleInfoSystem.GetDataMaxTimes then
        RoleInfoSystem.UpdateRankNo()
		--更新玩家信息
		EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_ROLEINFO);
	--end
end

--计算排名
function RoleInfoSystem.UpdateRankNo()
    if RoleInfoSystem.PersonalTotalRankInfo.role_totalrank == "" then
        local text = RankSystem.calc_topn_percentage(tonumber(RoleInfoSystem.PersonalTotalScoreInfo.role_totalscore), RoleInfoSystem.top1w_score, "total", 0)
        RoleInfoSystem.PersonalTotalRankInfo =
        {
            role_totalrank = text,
        }
    end
	if RoleInfoSystem.FPPPersonalTotalRankInfo.role_totalrank == "" then
        local text = RankSystem.calc_topn_percentage(tonumber(RoleInfoSystem.FPPPersonalTotalScoreInfo.role_totalscore), RoleInfoSystem.fpp_top1w_score, "total", 0)
        RoleInfoSystem.FPPPersonalTotalRankInfo =
        {
            role_totalrank = text,
        }
    end
end

---玩家战队相关
function RoleInfoSystem.GetPlayerCarTeamInfo(isSendByPlayer)
	log("RoleInfoUI.GetPlayerCarTeamInfo");
	RoleInfoUI.isSendByPlayer = isSendByPlayer;

	local carteamID = 0;
	if RoleInfoSystem.IsSelf() then
		log("SelfSelfSelfSelfSelfSelfSelfSelfSelf")
		carteamID = BP_STRUCT_AllianceInfo.aid or 0;
	else
		log("noSelfnoSelfnoSelfnoSelfnoSelfnoSelf")
		carteamID = RoleInfoSystem.PersonalBasicInfo.role_carteamId;
	end
	log("carteamID .." .. tostring(carteamID));
	AllianceSystem.query_others_carteam_req(tonumber(RoleInfoSystem.PersonalBasicInfo.role_id), tonumber(carteamID));
end

--响应玩家战绩信息
function RoleInfoSystem.get_role_combat_info_rsp(res, callback, optype, role_combat_info, zoneid, curseasonid, allseasonlist)
	log("get_role_combat_info_rsp curseasonid:" .. tostring(curseasonid));
	
	if optype ~= BP_COMBAT_MSG_TYPE_ROLEINFO then
		return;
	end
	
	RoleInfoSystem.curseasonid = curseasonid;
	
	if res ~= 0 then
		log("Error: "..res);
		
		RoleInfoSystem.RoleCombatInfoGet.ZoneId = -1
		RoleInfoSystem.RoleCombatInfoGet.SeasonId = -1
		
		RoleInfoSystem.ProcessCombatInfoError(curseasonid, allseasonlist);
		return;
	end
	
	-- log_tree("get_role_combat_info_rsp ret=",{res, callback, optype, role_combat_info, zoneid});
	
	--if RoleInfoSystem.Update_Ctrl >= RoleInfoSystem.GetDataMaxTimes then
	--	RoleInfoSystem.Update_Ctrl = 0;
	--end
	--RoleInfoSystem.Update_Ctrl = RoleInfoSystem.Update_Ctrl + 1;
	--log("44444444444444444444444444444444444444: "..RoleInfoSystem.Update_Ctrl);
	
	RoleInfoSystem.PersonalTotalScoreInfo = {};
	RoleInfoSystem.CombatTotalInfoList = {};
	RoleInfoSystem.CombatSurviveInfoList = {};
	RoleInfoSystem.CombatScoreInfoList = {};
	RoleInfoSystem.CombatBattleInfoList = {};
	RoleInfoSystem.CombatGradeInfoList = {};
	RoleInfoSystem.FPPPersonalTotalScoreInfo = {};
	RoleInfoSystem.FPPCombatTotalInfoList = {};
	RoleInfoSystem.FPPCombatSurviveInfoList = {};
	RoleInfoSystem.FPPCombatScoreInfoList = {};
	RoleInfoSystem.FPPCombatBattleInfoList = {};
	RoleInfoSystem.FPPCombatGradeInfoList = {};
	
	--战绩总分数据
	--第三人称
	if role_combat_info.warall.rank_rating ~= nil then
		RoleInfoSystem.PersonalTotalScoreInfo =
		{
			role_totalscore = role_combat_info.warall.rank_rating;
		}
	else
		RoleInfoSystem.PersonalTotalScoreInfo =
		{
			role_totalscore = tonumber(Client.GetTableData("LocalizeRes", 105014).TextValue);
		}
	end
	RoleInfoSystem.SetElementToString(RoleInfoSystem.PersonalTotalScoreInfo);
	--第一人称
	if role_combat_info.warall.fpp_rank_rating ~= nil then
		--log("000000000000000000000000000000000000000000000000")
		RoleInfoSystem.FPPPersonalTotalScoreInfo =
		{
			role_totalscore = role_combat_info.warall.fpp_rank_rating;
		}
	else
		-- log("999999999999999999999999999999999999999999999999")
		RoleInfoSystem.FPPPersonalTotalScoreInfo =
		{
			role_totalscore = tonumber(Client.GetTableData("LocalizeRes", 105014).TextValue);
		}
	end
	RoleInfoSystem.SetElementToString(RoleInfoSystem.FPPPersonalTotalScoreInfo);
	
	RoleInfoHistorySystem.SetCanShowHistory(role_combat_info.privacy);

	local role_info;
	local fpp_role_info;
	local length = RoleInfoSystem.GetTableLength(model_type);
	for i = 1, length do
		if i == model_type.solo_model then
			role_info = role_combat_info.warsolo;
			fpp_role_info = role_combat_info.fppsolo;
		elseif i == model_type.double_model then
			role_info = role_combat_info.warduo;
			fpp_role_info = role_combat_info.fppduo;
		elseif i == model_type.team_model then
			role_info = role_combat_info.warsquad;
			fpp_role_info = role_combat_info.fppsquad;
		elseif i == model_type.all_model then
			role_info = role_combat_info.warall;
			fpp_role_info = role_combat_info.warall;
		end
		--第三人称
		if role_info ~= nil then
			if i == model_type.all_model then
				--所有战绩综合数据
				RoleInfoSystem.CombatTotalInfoList[i] =
				{
					role_allmatchnum = role_info.game_num,
					role_winnum = role_info.win_num,
					role_toptennum = role_info.top10_count,
					role_killnum = role_info.kill_num,
					role_kd = role_info.kd,
					role_critrate = role_info.head_shot_ratio,
				};
			else
				--单人、双人、组队战绩综合数据
				RoleInfoSystem.CombatTotalInfoList[i] =
				{
					role_allmatchnum = role_info.game_num,
					role_winnum = role_info.win_num,
					role_toptennum = role_info.top10_count,
					role_killnum = role_info.kill_num,
					role_kd = role_info.kd,
					role_critrate = role_info.head_shot_ratio,
				};
				--单人、双人、组队战绩生存数据
				RoleInfoSystem.CombatSurviveInfoList[i] =
				{
					role_maxsurvivetime = role_info.max_live_time,
					role_avesurvivetime = role_info.avg_live_time,
					role_maxdistance = role_info.max_move,
					role_avedistance = role_info.avg_move,
					role_aveheal = role_info.avg_cure,
					role_aidcount = role_info.rescue_teammates,
				};
				if type(role_info.game_num) == "number" and role_info.game_num ~= 0 then
					RoleInfoSystem.CombatSurviveInfoList[i]["role_winrate"] = role_info.win_num/role_info.game_num*100;
					RoleInfoSystem.CombatSurviveInfoList[i]["role_toptenrate"] = role_info.top10_count/role_info.game_num*100;
				else
					RoleInfoSystem.CombatSurviveInfoList[i]["role_winrate"] = 0;
					RoleInfoSystem.CombatSurviveInfoList[i]["role_toptenrate"] = 0;
				end
				--单人、双人、组队战绩得分数据
				RoleInfoSystem.CombatScoreInfoList[i] =
				{
					role_score = role_info.rank_rating,
					role_killscore = role_info.kill_rating,
					role_rankscore = role_info.win_rating,
				};
				--单人、双人、组队战绩战斗数据
				RoleInfoSystem.CombatBattleInfoList[i] =
				{
					role_hitrate = role_info.avg_shot_hit_ratio,
					role_critcount = role_info.head_shot_num,
					role_maxkill = role_info.max_kill,
					role_maxdamage = role_info.max_hurt,
					role_avedamage = role_info.avg_hurt,
				};
				--单人、双人、组队战绩评级、雷达图数据
				RoleInfoSystem.CombatGradeInfoList[i] =
				{
					survive_score = role_info.survive_score,
					top1_score = role_info.top1_score,
					rating_score = role_info.rating_score,
					fight_score = role_info.fight_score,
					assist_score = role_info.assist_score,
					sum_score = role_info.sum_score,
					grade = role_info.grade,
				};
				local sgrade = role_info.grade;
				RoleInfoSystem.CombatGradeInfoList[i]["grade"] = ConvertGrade(sgrade);
			end
		end
		--第一人称
		if fpp_role_info ~= nil then
			--log("777777777777777777777777777777777777777777777777777");
			if i == model_type.all_model then
				--所有战绩综合数据
				RoleInfoSystem.FPPCombatTotalInfoList[i] =
				{
					role_allmatchnum = fpp_role_info.game_num,
					role_winnum = fpp_role_info.win_num,
					role_toptennum = fpp_role_info.top10_count,
					role_killnum = fpp_role_info.kill_num,
					role_kd = fpp_role_info.kd,
					role_critrate = fpp_role_info.head_shot_ratio,
				};
			else
				--单人、双人、组队战绩综合数据
				RoleInfoSystem.FPPCombatTotalInfoList[i] =
				{
					role_allmatchnum = fpp_role_info.game_num,
					role_winnum = fpp_role_info.win_num,
					role_toptennum = fpp_role_info.top10_count,
					role_killnum = fpp_role_info.kill_num,
					role_kd = fpp_role_info.kd,
					role_critrate = fpp_role_info.head_shot_ratio,
				};
				--单人、双人、组队战绩生存数据
				RoleInfoSystem.FPPCombatSurviveInfoList[i] =
				{
					role_maxsurvivetime = fpp_role_info.max_live_time,
					role_avesurvivetime = fpp_role_info.avg_live_time,
					role_maxdistance = fpp_role_info.max_move,
					role_avedistance = fpp_role_info.avg_move,
					role_aveheal = fpp_role_info.avg_cure,
					role_aidcount = fpp_role_info.rescue_teammates,
				};
				if type(fpp_role_info.game_num) == "number" and fpp_role_info.game_num ~= 0 then
					RoleInfoSystem.FPPCombatSurviveInfoList[i]["role_winrate"] = fpp_role_info.win_num/fpp_role_info.game_num*100;
					RoleInfoSystem.FPPCombatSurviveInfoList[i]["role_toptenrate"] = fpp_role_info.top10_count/fpp_role_info.game_num*100;
				else
					RoleInfoSystem.FPPCombatSurviveInfoList[i]["role_winrate"] = 0;
					RoleInfoSystem.FPPCombatSurviveInfoList[i]["role_toptenrate"] = 0;
				end
				--单人、双人、组队战绩得分数据
				RoleInfoSystem.FPPCombatScoreInfoList[i] =
				{
					role_score = fpp_role_info.rank_rating,
					role_killscore = fpp_role_info.kill_rating,
					role_rankscore = fpp_role_info.win_rating,
				};
				--单人、双人、组队战绩战斗数据
				RoleInfoSystem.FPPCombatBattleInfoList[i] =
				{
					role_hitrate = fpp_role_info.avg_shot_hit_ratio,
					role_critcount = fpp_role_info.head_shot_num,
					role_maxkill = fpp_role_info.max_kill,
					role_maxdamage = fpp_role_info.max_hurt,
					role_avedamage = fpp_role_info.avg_hurt,
				};
				--单人、双人、组队战绩评级、雷达图数据
				RoleInfoSystem.FPPCombatGradeInfoList[i] =
				{
					survive_score = fpp_role_info.survive_score,
					top1_score = fpp_role_info.top1_score,
					rating_score = fpp_role_info.rating_score,
					fight_score = fpp_role_info.fight_score,
					assist_score = fpp_role_info.assist_score,
					sum_score = fpp_role_info.sum_score,
					grade = fpp_role_info.grade,
				};
				local sfppgrade = fpp_role_info.grade;
				RoleInfoSystem.FPPCombatGradeInfoList[i]["grade"] = ConvertGrade(sfppgrade);
			end
		else
			-- log("888888888888888888888888888888888888888888888888888");
			if i == model_type.all_model then
				RoleInfoSystem.FPPCombatTotalInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.CombatTotalInfo);
			else
				RoleInfoSystem.FPPCombatTotalInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.CombatTotalInfo);
				RoleInfoSystem.FPPCombatSurviveInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.CombatSurviveInfo);
				RoleInfoSystem.FPPCombatScoreInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.CombatScoreInfo);
				RoleInfoSystem.FPPCombatBattleInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.CombatBattleInfo);
				RoleInfoSystem.FPPCombatGradeInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.CombatGradeInfo);
			end
		end
	end
	RoleInfoSystem.FormatCombatInfo();
	RoleInfoSystem.SetElementToString(RoleInfoSystem.CombatTotalInfoList);
	RoleInfoSystem.SetElementToString(RoleInfoSystem.CombatSurviveInfoList);
	RoleInfoSystem.SetElementToString(RoleInfoSystem.CombatScoreInfoList);
	RoleInfoSystem.SetElementToString(RoleInfoSystem.CombatBattleInfoList);
	RoleInfoSystem.SetElementToString(RoleInfoSystem.CombatGradeInfoList);
	RoleInfoSystem.SetElementToString(RoleInfoSystem.FPPCombatTotalInfoList);
	RoleInfoSystem.SetElementToString(RoleInfoSystem.FPPCombatSurviveInfoList);
	RoleInfoSystem.SetElementToString(RoleInfoSystem.FPPCombatScoreInfoList);
	RoleInfoSystem.SetElementToString(RoleInfoSystem.FPPCombatBattleInfoList);
	RoleInfoSystem.SetElementToString(RoleInfoSystem.FPPCombatGradeInfoList);
	
	log_tree("RoleInfoSystem.CombatScoreInfoList", RoleInfoSystem.CombatScoreInfoList)
	log_tree("RoleInfoSystem.FPPCombatScoreInfoList", RoleInfoSystem.FPPCombatScoreInfoList)
	
	RoleInfoSystem.AllSeasonIDList = {};
	table.insert(RoleInfoSystem.AllSeasonIDList, curseasonid);
	if allseasonlist ~= nil and type(allseasonlist) == "table" then
		table.sort(allseasonlist, function(a,b) return a < b; end);
		for k,v in pairs(allseasonlist) do
			if v ~= curseasonid then
				table.insert(RoleInfoSystem.AllSeasonIDList, v);
			end
		end
	end
	
	--if RoleInfoSystem.Update_Ctrl == RoleInfoSystem.GetDataMaxTimes then
        RoleInfoSystem.UpdateRankNo()
		--更新玩家信息
		EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_ROLEINFO);
	--end
end

--响应修改签名
function RoleInfoSystem.modify_role_signature_respond(res)
	if res == "ok" then
		--修改签名
		EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_MODIFY_SIGNINFO);
	elseif res == "signature-too-long" then
		log("Error: "..res);
		--恢复签名
		EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_TOOLONG_SIGNINFO);
	elseif res == "have-dirty-in-signature" then
		log("Error: "..res);
		--非法字符
		EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_DIRTY_SIGNINFO);
	end
end

--设置table的所有v为string类型
function RoleInfoSystem.SetElementToString(tab)
	for k, v in pairs(tab or {}) do
		if type(v) ~= "table" then
			tab[k] = tostring(v);
		else
			RoleInfoSystem.SetElementToString(v);
		end
	end
end

--格式化战绩信息
function RoleInfoSystem.FormatCombatInfo()
	log("RoleInfoSystem FormatCombatInfo");
	local length = RoleInfoSystem.GetTableLength(model_type);
	for i = 1, length do
		--格式化战绩综合数据
		--第三人称
		local totalinfo = RoleInfoSystem.CombatTotalInfoList[i];
		totalinfo["role_kd"] = string.format("%.2f", totalinfo["role_kd"]);
		totalinfo["role_critrate"] = string.format("%.1f", totalinfo["role_critrate"]*100);
		--第一人称
		local fpptotalinfo = RoleInfoSystem.FPPCombatTotalInfoList[i];
		fpptotalinfo["role_kd"] = string.format("%.2f", fpptotalinfo["role_kd"]);
		fpptotalinfo["role_critrate"] = string.format("%.1f", fpptotalinfo["role_critrate"]*100);
	end
	for i = 1, length-1 do
		--格式化战绩生成数据
		--第三人称
		local surviveinfo = RoleInfoSystem.CombatSurviveInfoList[i];
		surviveinfo["role_maxsurvivetime"] = string.format("%.1f", surviveinfo["role_maxsurvivetime"]/60);
		surviveinfo["role_avesurvivetime"] = string.format("%.1f", surviveinfo["role_avesurvivetime"]/60);
		surviveinfo["role_maxdistance"] = string.format("%.2f", surviveinfo["role_maxdistance"]/1000);
		surviveinfo["role_avedistance"] = string.format("%.2f", surviveinfo["role_avedistance"]/1000);
		surviveinfo["role_aveheal"] = string.format("%.1f", surviveinfo["role_aveheal"]);
		surviveinfo["role_winrate"] = string.format("%.1f", surviveinfo["role_winrate"]);
		surviveinfo["role_toptenrate"] = string.format("%.1f", surviveinfo["role_toptenrate"]);
		--第一人称
		local fppsurviveinfo = RoleInfoSystem.FPPCombatSurviveInfoList[i];
		fppsurviveinfo["role_maxsurvivetime"] = string.format("%.1f", fppsurviveinfo["role_maxsurvivetime"]/60);
		fppsurviveinfo["role_avesurvivetime"] = string.format("%.1f", fppsurviveinfo["role_avesurvivetime"]/60);
		fppsurviveinfo["role_maxdistance"] = string.format("%.2f", fppsurviveinfo["role_maxdistance"]/1000);
		fppsurviveinfo["role_avedistance"] = string.format("%.2f", fppsurviveinfo["role_avedistance"]/1000);
		fppsurviveinfo["role_aveheal"] = string.format("%.1f", fppsurviveinfo["role_aveheal"]);
		fppsurviveinfo["role_winrate"] = string.format("%.1f", fppsurviveinfo["role_winrate"]);
		fppsurviveinfo["role_toptenrate"] = string.format("%.1f", fppsurviveinfo["role_toptenrate"]);
		
		--格式化战绩战斗数据
		--第三人称
		local battleinfo = RoleInfoSystem.CombatBattleInfoList[i];
		battleinfo["role_hitrate"] = string.format("%.1f", battleinfo["role_hitrate"]*100);
		battleinfo["role_avedamage"] = string.format("%.1f", battleinfo["role_avedamage"]);
		battleinfo["role_maxdamage"] = string.format("%.0f", battleinfo["role_maxdamage"]);
		--第一人称
		local fppbattleinfo = RoleInfoSystem.FPPCombatBattleInfoList[i];
		fppbattleinfo["role_hitrate"] = string.format("%.1f", fppbattleinfo["role_hitrate"]*100);
		fppbattleinfo["role_avedamage"] = string.format("%.1f", fppbattleinfo["role_avedamage"]);
		fppbattleinfo["role_maxdamage"] = string.format("%.0f", fppbattleinfo["role_maxdamage"]);
		
		--格式化战绩评级、雷达图数据
		--第三人称
		local gradeinfo = RoleInfoSystem.CombatGradeInfoList[i];
		gradeinfo["survive_score"] = string.format("%.1f", gradeinfo["survive_score"]);
		gradeinfo["top1_score"] = string.format("%.1f", gradeinfo["top1_score"]);
		gradeinfo["rating_score"] = string.format("%.1f", gradeinfo["rating_score"]);
		gradeinfo["fight_score"] = string.format("%.1f", gradeinfo["fight_score"]);
		gradeinfo["assist_score"] = string.format("%.1f", gradeinfo["assist_score"]);
		gradeinfo["sum_score"] = string.format("%.1f", gradeinfo["sum_score"]);
		--第一人称
		local fppgradeinfo = RoleInfoSystem.FPPCombatGradeInfoList[i];
		fppgradeinfo["survive_score"] = string.format("%.1f", fppgradeinfo["survive_score"]);
		fppgradeinfo["top1_score"] = string.format("%.1f", fppgradeinfo["top1_score"]);
		fppgradeinfo["rating_score"] = string.format("%.1f", fppgradeinfo["rating_score"]);
		fppgradeinfo["fight_score"] = string.format("%.1f", fppgradeinfo["fight_score"]);
		fppgradeinfo["assist_score"] = string.format("%.1f", fppgradeinfo["assist_score"]);
		fppgradeinfo["sum_score"] = string.format("%.1f", fppgradeinfo["sum_score"]);
	end
end

--处理基本信息收包错误
function RoleInfoSystem.ProcessBasicInfoError()
	--if RoleInfoSystem.Update_Ctrl >= RoleInfoSystem.GetDataMaxTimes then
	--	RoleInfoSystem.Update_Ctrl = 0;
	--end
	--RoleInfoSystem.Update_Ctrl = RoleInfoSystem.Update_Ctrl + 1;
	-- log("44444444444444444444444444444444444444: "..RoleInfoSystem.Update_Ctrl);
	
	RoleInfoSystem.PersonalBasicInfo = {};
	RoleInfoSystem.PersonalBasicInfo =
	{
		role_name = "nil",
		role_id = "nil",
		role_sex = "0",
		role_nation = "nil",
		role_image = "",
		role_upvote = 0,
		role_curlevel = "",
		role_nextlevel = "",
		role_curexpnum = "0",
		role_needexpnum = "1",
		role_sign = "",
		role_curlevelnum = 0,
		role_nextlevelnum = 0,
		role_segment_solo = 0,
		role_segment_double = 0,
		role_segment_team = 0,
		role_segment_max = 0,
		role_all_zone_segment_max = 0,
		role_startup_type = 0,
		role_qqvip = 0,
        role_avatar_frame = 0,
        all_segment_info ={},
		role_credit = 0,
        role_corpsid = 0,
		role_segmentFPP_solo = 0,
		role_segmentFPP_double = 0,
		role_segmentFPP_team = 0,
		role_segmentFPP_max = 0,
		role_upassIsBuy = 0,
		role_upassLevel = 0,
		role_upassUiSwitch = false,
	};
	
	--if RoleInfoSystem.Update_Ctrl == RoleInfoSystem.GetDataMaxTimes then
		--更新玩家信息
		EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_ROLEINFO);
	--end
end

--处理排行榜信息收包错误
function RoleInfoSystem.ProcessRankInfoError()
	--if RoleInfoSystem.Update_Ctrl >= RoleInfoSystem.GetDataMaxTimes then
	--	RoleInfoSystem.Update_Ctrl = 0;
	--end
	--RoleInfoSystem.Update_Ctrl = RoleInfoSystem.Update_Ctrl + 1;
	--log("55555555555555555555555555555555555555: "..RoleInfoSystem.Update_Ctrl);
	
	RoleInfoSystem.PersonalTotalRankInfo =
	{
		role_totalrank = "",
	};
	RoleInfoSystem.FPPPersonalTotalRankInfo =
	{
		role_totalrank = "",
	};
	
	--if RoleInfoSystem.Update_Ctrl == RoleInfoSystem.GetDataMaxTimes then
		--更新玩家信息
		EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_ROLEINFO);
	--end
end

--处理战绩收包错误
function RoleInfoSystem.ProcessCombatInfoError(curseasonid, allseasonlist)
	--if RoleInfoSystem.Update_Ctrl >= RoleInfoSystem.GetDataMaxTimes then
	--	RoleInfoSystem.Update_Ctrl = 0;
	--end
	--RoleInfoSystem.Update_Ctrl = RoleInfoSystem.Update_Ctrl + 1;
	-- log("66666666666666666666666666666666666666: "..RoleInfoSystem.Update_Ctrl);
	
	RoleInfoSystem.PersonalTotalScoreInfo = {};
	RoleInfoSystem.CombatTotalInfoList = {};
	RoleInfoSystem.CombatSurviveInfoList = {};
	RoleInfoSystem.CombatScoreInfoList = {};
	RoleInfoSystem.CombatBattleInfoList = {};
	RoleInfoSystem.CombatGradeInfoList = {};
	RoleInfoSystem.FPPPersonalTotalScoreInfo = {};
	RoleInfoSystem.FPPCombatTotalInfoList = {};
	RoleInfoSystem.FPPCombatSurviveInfoList = {};
	RoleInfoSystem.FPPCombatScoreInfoList = {};
	RoleInfoSystem.FPPCombatBattleInfoList = {};
	RoleInfoSystem.FPPCombatGradeInfoList = {};
	
	RoleInfoSystem.PersonalTotalScoreInfo =
	{
		role_totalscore = 0;
	}
	RoleInfoSystem.SetElementToString(RoleInfoSystem.PersonalTotalScoreInfo);
	RoleInfoSystem.FPPPersonalTotalScoreInfo =
	{
		role_totalscore = 0;
	}
	RoleInfoSystem.SetElementToString(RoleInfoSystem.FPPPersonalTotalScoreInfo);
	
	local length = RoleInfoSystem.GetTableLength(model_type);
	for i = 1, length do
		if i == model_type.all_model then
			RoleInfoSystem.CombatTotalInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.CombatTotalInfo);
			RoleInfoSystem.FPPCombatTotalInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.CombatTotalInfo);
		else
			RoleInfoSystem.CombatTotalInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.CombatTotalInfo);
			RoleInfoSystem.CombatSurviveInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.CombatSurviveInfo);
			RoleInfoSystem.CombatScoreInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.CombatScoreInfo);
			RoleInfoSystem.CombatBattleInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.CombatBattleInfo);
			RoleInfoSystem.CombatGradeInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.CombatGradeInfo);
			RoleInfoSystem.FPPCombatTotalInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.CombatTotalInfo);
			RoleInfoSystem.FPPCombatSurviveInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.CombatSurviveInfo);
			RoleInfoSystem.FPPCombatScoreInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.CombatScoreInfo);
			RoleInfoSystem.FPPCombatBattleInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.CombatBattleInfo);
			RoleInfoSystem.FPPCombatGradeInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.CombatGradeInfo);
		end
	end
	RoleInfoSystem.FormatCombatInfo();
	RoleInfoSystem.SetElementToString(RoleInfoSystem.CombatTotalInfoList);
	RoleInfoSystem.SetElementToString(RoleInfoSystem.CombatSurviveInfoList);
	RoleInfoSystem.SetElementToString(RoleInfoSystem.CombatScoreInfoList);
	RoleInfoSystem.SetElementToString(RoleInfoSystem.CombatBattleInfoList);
	RoleInfoSystem.SetElementToString(RoleInfoSystem.CombatGradeInfoList);
	RoleInfoSystem.SetElementToString(RoleInfoSystem.FPPCombatTotalInfoList);
	RoleInfoSystem.SetElementToString(RoleInfoSystem.FPPCombatSurviveInfoList);
	RoleInfoSystem.SetElementToString(RoleInfoSystem.FPPCombatScoreInfoList);
	RoleInfoSystem.SetElementToString(RoleInfoSystem.FPPCombatBattleInfoList);
	RoleInfoSystem.SetElementToString(RoleInfoSystem.FPPCombatGradeInfoList);

	
	RoleInfoSystem.AllSeasonIDList = {};
	table.insert(RoleInfoSystem.AllSeasonIDList, curseasonid);
	if allseasonlist ~= nil and type(allseasonlist) == "table" then
		table.sort(allseasonlist, function(a,b) return a < b; end);
		for k,v in pairs(allseasonlist) do
			if v ~= curseasonid then
				table.insert(RoleInfoSystem.AllSeasonIDList, v);
			end
		end
	end
	
	--if RoleInfoSystem.Update_Ctrl == RoleInfoSystem.GetDataMaxTimes then
		--更新玩家信息
		EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_ROLEINFO);
	--end
end

--战绩清零
function RoleInfoSystem.SetElementToZero(tab)
	for k, v in pairs(tab) do
		if type(v) ~= "table" then
			tab[k] = "0";
		else
			RoleInfoSystem.SetElementToZero(v);
		end
	end
end

--转换评级
function ConvertGrade(sgrade)
	local grade = 0;
	if sgrade == "B" then
		grade = 0;
	elseif sgrade == "B+" then
		grade = 1;
	elseif sgrade == "A" then
		grade = 2;
	elseif sgrade == "A+" then
		grade = 3;
	elseif sgrade == "S" then
		grade = 4;
	elseif sgrade == "S+" then
		grade = 5;
	elseif sgrade == "SS" then
		grade = 6;
	elseif sgrade == "SS+" then
		grade = 7;
	elseif sgrade == "SSS" then
		grade = 8;
	else
		grade = 0;
	end
	return grade;
end

--请求交友名片
function RoleInfoSystem.get_social_card()
	log("get_social_card");
	NetUtil.SendPriorityPkg(false, "get_social_card_rsp", "get_social_card");
end

function RoleInfoSystem.get_social_card_rsp(ok,social_card)
    -- log_tree("get_social_card_rsp=",{ok,social_card});
    if ok == 0 then
        RoleInfoSystem.SocialCard = social_card
        EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_CARDINFO);
    else
        DataMgr.ShowMessageBoxByID(ok)
    end
end

--获取军团信息
function RoleInfoSystem.get_corps_summary_req(corpsID, uid, isWaitting)
	log("get_corps_summary_req corpsID:"..corpsID..", uid:"..uid);
	CorpsMgr.get_corps_summary_req(corpsID, uid, nil, isWaitting)
end

function RoleInfoSystem.get_corps_summary_rsp(corps_id, corps_summary)
	log("get_corps_summary_rsp receive:"..corps_id);
	log_tree("RoleInfoSystem.get_corps_summary_rsp" , corps_summary)
	RoleInfoUI.RefreshCorpsSummary(corps_id, corps_summary)
end


function RoleInfoSystem.modify_social_card()
	-- log_tree("modify_social_card=",RoleInfoSystem.SocialCard);
	log("BP_Sign = "..BP_Sign);
	NetUtil.SendPriorityPkg(false, "modify_social_card_rsp", "modify_social_card", RoleInfoSystem.SocialCard, BP_Sign);
end

function RoleInfoSystem.modify_social_card_rsp(ok,social_card,signature)
	-- log_tree("modify_social_card_rsp=",{ok,social_card});
	if ok == 0 then
        RoleInfoSystem.SocialCard = social_card;
		BP_STRUCT_PersonalBasicInfo["role_sign"] = signature;
        EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_CARDINFO);
	elseif ok == 105002 then
		BP_Sign = "";
		RoleInfoUI.SetSignInfo()
		DataMgr.ShowMessageBoxByID(ok);
		return;
	elseif ok == 105005 then
		BP_Sign = "";
		RoleInfoUI.SetSignInfo()
		local title_data = Client.GetTableData("LocalizeRes", 105004);
		local title = tostring(title_data.TextValue);
		local msg_data = Client.GetTableData("LocalizeRes", 105005);
		local msg = tostring(msg_data.TextValue);
		CommonMessageBoxUI:ShowPanel(1, title, msg, nil, nil);
		return;
	else
        DataMgr.ShowMessageBoxByID(ok);
    end
end

function RoleInfoSystem.SendModifyRoleName(strName)
	NetUtil.SendPriorityPkg(false, "modify_role_name_rsp", "modify_role_name", strName);
end

function RoleInfoSystem.modify_role_name_rsp(ok)
	log("RoleInfoSystem.modify_role_name_rsp ok="..tostring(ok));
	if ok ~= "ok" then
		if ok == "can not use last name" then
			ShowNotice(660019);
		elseif ok == "name-too-long" then
			ShowNotice(990002);
		elseif ok == "name-too-short" then
			ShowNotice(990003);
		elseif ok == "have-dirty-in-name" then
			ShowNotice(990004);
		elseif ok == "name-exist" then
			ShowNotice(990005);
		elseif ok == "no enough gold or item" then
			ShowNotice(660020);
		elseif ok == "one time per day" then
			ShowNotice(660021);
		else
			PopUpNoticeUI.ShowNewNotice(ok);
		end
		
		return;
	end
	
	ShowNotice(660022);
	
	--更新仓库
	if WardrobeUI.isShowing then
		WardrobeUI:UpdateItemList();
	end
	
	ReviseNameUI.ModifyNameOk();
	ReviseNameUI.Hide();
	
	LobbyUI:RefreshPlayerData();
	
	TeamUpSystem.on_team_change_name(DataMgr.roleData.uid, DataMgr.roleData.nickName);
	
	EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_ROLENAME);
end

--请求玩家历史赛季信息响应
function RoleInfoSystem.get_role_history_season_battle_rsp(res, battle_info)
	log("RoleInfoSystem get_role_history_season_battle_rsp");
	log_tree("battle_info", battle_info)
	if res ~= 0 then
		log("Error: "..res);
		
		RoleInfoSystem.RoleCombatInfoGet.ZoneId = -1
		RoleInfoSystem.RoleCombatInfoGet.SeasonId = -1
		
		RoleInfoSystem.ProcessSeasonCombatInfoError();
		return;
	end

	RoleInfoSystem.RoleHistorySeasonBattleGet = true
	
	RoleInfoSystem.CombatTotalInfoList = {};
	RoleInfoSystem.CombatSurviveInfoList = {};
	RoleInfoSystem.CombatScoreInfoList = {};
	RoleInfoSystem.CombatBattleInfoList = {};
	RoleInfoSystem.CombatGradeInfoList = {};
	RoleInfoSystem.FPPCombatTotalInfoList = {};
	RoleInfoSystem.FPPCombatSurviveInfoList = {};
	RoleInfoSystem.FPPCombatScoreInfoList = {};
	RoleInfoSystem.FPPCombatBattleInfoList = {};
	RoleInfoSystem.FPPCombatGradeInfoList = {};
	-- log_tree("battle_info =",battle_info);
	
	local role_info;
	local fpp_role_info;
	local length = RoleInfoSystem.GetTableLength(model_type);
	for i = 1, length do
		if i == model_type.solo_model then
			role_info = battle_info.warsolo;
			fpp_role_info = battle_info.fppsolo;
		elseif i == model_type.double_model then
			role_info = battle_info.warduo;
			fpp_role_info = battle_info.fppduo;
		elseif i == model_type.team_model then
			role_info = battle_info.warsquad;
			fpp_role_info = battle_info.fppsquad;
		elseif i == model_type.all_model then
			role_info = battle_info.warall;
			fpp_role_info = battle_info.warall;
		end
		--第三人称
		if role_info ~= nil then
			if i == model_type.all_model then
				--所有战绩综合数据
				RoleInfoSystem.CombatTotalInfoList[i] =
				{
					role_allmatchnum = role_info.game_num,
					role_winnum = role_info.win_num,
					role_toptennum = role_info.top10_count,
					role_killnum = role_info.kill_num,
					role_kd = role_info.kd,
					role_critrate = role_info.head_shot_ratio,
				};
			else
				--单人、双人、组队战绩综合数据
				RoleInfoSystem.CombatTotalInfoList[i] =
				{
					role_allmatchnum = role_info.game_num,
					role_winnum = role_info.win_num,
					role_toptennum = role_info.top10_count,
					role_killnum = role_info.kill_num,
					role_kd = role_info.kd,
					role_critrate = role_info.head_shot_ratio,
				};
				--单人、双人、组队战绩生存数据
				RoleInfoSystem.CombatSurviveInfoList[i] =
				{
					role_maxsurvivetime = role_info.max_live_time,
					role_avesurvivetime = role_info.avg_live_time,
					role_maxdistance = role_info.max_move,
					role_avedistance = role_info.avg_move,
					role_aveheal = role_info.avg_cure,
					role_aidcount = role_info.rescue_teammates,
				};
				if type(role_info.game_num) == "number" and role_info.game_num ~= 0 then
					RoleInfoSystem.CombatSurviveInfoList[i]["role_winrate"] = role_info.win_num/role_info.game_num*100;
					RoleInfoSystem.CombatSurviveInfoList[i]["role_toptenrate"] = role_info.top10_count/role_info.game_num*100;
				else
					RoleInfoSystem.CombatSurviveInfoList[i]["role_winrate"] = 0;
					RoleInfoSystem.CombatSurviveInfoList[i]["role_toptenrate"] = 0;
				end
				--单人、双人、组队战绩得分数据
				RoleInfoSystem.CombatScoreInfoList[i] =
				{
					role_score = role_info.rank_rating,
					role_killscore = role_info.kill_rating,
					role_rankscore = role_info.win_rating,
				};
				--单人、双人、组队战绩战斗数据
				RoleInfoSystem.CombatBattleInfoList[i] =
				{
					role_hitrate = role_info.avg_shot_hit_ratio,
					role_critcount = role_info.head_shot_num,
					role_maxkill = role_info.max_kill,
					role_maxdamage = role_info.max_hurt,
					role_avedamage = role_info.avg_hurt,
				};
				--单人、双人、组队战绩评级、雷达图数据
				RoleInfoSystem.CombatGradeInfoList[i] =
				{
					survive_score = role_info.survive_score,
					top1_score = role_info.top1_score,
					rating_score = role_info.rating_score,
					fight_score = role_info.fight_score,
					assist_score = role_info.assist_score,
					sum_score = role_info.sum_score,
					grade = role_info.grade,
				};
				local sgrade = role_info.grade;
				RoleInfoSystem.CombatGradeInfoList[i]["grade"] = ConvertGrade(sgrade);
			end
		else
			if i == model_type.all_model then
				RoleInfoSystem.CombatTotalInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.CombatTotalInfo);
			else
				RoleInfoSystem.CombatTotalInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.CombatTotalInfo);
				RoleInfoSystem.CombatSurviveInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.CombatSurviveInfo);
				RoleInfoSystem.CombatScoreInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.CombatScoreInfo);
				RoleInfoSystem.CombatBattleInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.CombatBattleInfo);
				RoleInfoSystem.CombatGradeInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.CombatGradeInfo);
			end
		end
		--第一人称
		if fpp_role_info ~= nil then
			if i == model_type.all_model then
				--所有战绩综合数据
				RoleInfoSystem.FPPCombatTotalInfoList[i] =
				{
					role_allmatchnum = fpp_role_info.game_num,
					role_winnum = fpp_role_info.win_num,
					role_toptennum = fpp_role_info.top10_count,
					role_killnum = fpp_role_info.kill_num,
					role_kd = fpp_role_info.kd,
					role_critrate = fpp_role_info.head_shot_ratio,
				};
			else
				--单人、双人、组队战绩综合数据
				RoleInfoSystem.FPPCombatTotalInfoList[i] =
				{
					role_allmatchnum = fpp_role_info.game_num,
					role_winnum = fpp_role_info.win_num,
					role_toptennum = fpp_role_info.top10_count,
					role_killnum = fpp_role_info.kill_num,
					role_kd = fpp_role_info.kd,
					role_critrate = fpp_role_info.head_shot_ratio,
				};
				--单人、双人、组队战绩生存数据
				RoleInfoSystem.FPPCombatSurviveInfoList[i] =
				{
					role_maxsurvivetime = fpp_role_info.max_live_time,
					role_avesurvivetime = fpp_role_info.avg_live_time,
					role_maxdistance = fpp_role_info.max_move,
					role_avedistance = fpp_role_info.avg_move,
					role_aveheal = fpp_role_info.avg_cure,
					role_aidcount = fpp_role_info.rescue_teammates,
				};
				if type(fpp_role_info.game_num) == "number" and fpp_role_info.game_num ~= 0 then
					RoleInfoSystem.FPPCombatSurviveInfoList[i]["role_winrate"] = fpp_role_info.win_num/fpp_role_info.game_num*100;
					RoleInfoSystem.FPPCombatSurviveInfoList[i]["role_toptenrate"] = fpp_role_info.top10_count/fpp_role_info.game_num*100;
				else
					RoleInfoSystem.FPPCombatSurviveInfoList[i]["role_winrate"] = 0;
					RoleInfoSystem.FPPCombatSurviveInfoList[i]["role_toptenrate"] = 0;
				end
				--单人、双人、组队战绩得分数据
				RoleInfoSystem.FPPCombatScoreInfoList[i] =
				{
					role_score = fpp_role_info.rank_rating,
					role_killscore = fpp_role_info.kill_rating,
					role_rankscore = fpp_role_info.win_rating,
				};
				--单人、双人、组队战绩战斗数据
				RoleInfoSystem.FPPCombatBattleInfoList[i] =
				{
					role_hitrate = fpp_role_info.avg_shot_hit_ratio,
					role_critcount = fpp_role_info.head_shot_num,
					role_maxkill = fpp_role_info.max_kill,
					role_maxdamage = fpp_role_info.max_hurt,
					role_avedamage = fpp_role_info.avg_hurt,
				};
				--单人、双人、组队战绩评级、雷达图数据
				RoleInfoSystem.FPPCombatGradeInfoList[i] =
				{
					survive_score = fpp_role_info.survive_score,
					top1_score = fpp_role_info.top1_score,
					rating_score = fpp_role_info.rating_score,
					fight_score = fpp_role_info.fight_score,
					assist_score = fpp_role_info.assist_score,
					sum_score = fpp_role_info.sum_score,
					grade = fpp_role_info.grade,
				};
				local sfppgrade = fpp_role_info.grade;
				RoleInfoSystem.FPPCombatGradeInfoList[i]["grade"] = ConvertGrade(sfppgrade);
			end
		else
			if i == model_type.all_model then
				RoleInfoSystem.FPPCombatTotalInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.CombatTotalInfo);
			else
				RoleInfoSystem.FPPCombatTotalInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.CombatTotalInfo);
				RoleInfoSystem.FPPCombatSurviveInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.CombatSurviveInfo);
				RoleInfoSystem.FPPCombatScoreInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.CombatScoreInfo);
				RoleInfoSystem.FPPCombatBattleInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.CombatBattleInfo);
				RoleInfoSystem.FPPCombatGradeInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.CombatGradeInfo);
			end
		end
	end
	RoleInfoSystem.FormatCombatInfo();
	RoleInfoSystem.SetElementToString(RoleInfoSystem.CombatTotalInfoList);
	RoleInfoSystem.SetElementToString(RoleInfoSystem.CombatSurviveInfoList);
	RoleInfoSystem.SetElementToString(RoleInfoSystem.CombatScoreInfoList);
	RoleInfoSystem.SetElementToString(RoleInfoSystem.CombatBattleInfoList);
	RoleInfoSystem.SetElementToString(RoleInfoSystem.CombatGradeInfoList);
	RoleInfoSystem.SetElementToString(RoleInfoSystem.FPPCombatTotalInfoList);
	RoleInfoSystem.SetElementToString(RoleInfoSystem.FPPCombatSurviveInfoList);
	RoleInfoSystem.SetElementToString(RoleInfoSystem.FPPCombatScoreInfoList);
	RoleInfoSystem.SetElementToString(RoleInfoSystem.FPPCombatBattleInfoList);
	RoleInfoSystem.SetElementToString(RoleInfoSystem.FPPCombatGradeInfoList);

	if battle_info.segment_info then
		log_tree("battle_info.segment_info", battle_info.segment_info)
		
		RoleInfoSystem.PersonalBasicInfo["role_segment_solo"] = tonumber (battle_info.segment_info[segment_type.solo]);
		RoleInfoSystem.PersonalBasicInfo["role_segment_double"] = tonumber(battle_info.segment_info[segment_type.double]);
		RoleInfoSystem.PersonalBasicInfo["role_segment_team"] = tonumber(battle_info.segment_info[segment_type.team]);
		RoleInfoSystem.PersonalBasicInfo["role_segmentFPP_solo"] = tonumber(battle_info.segment_info[segment_type.fpp_solo]);
		RoleInfoSystem.PersonalBasicInfo["role_segmentFPP_double"] = tonumber(battle_info.segment_info[segment_type.fpp_double]);
		RoleInfoSystem.PersonalBasicInfo["role_segmentFPP_team"] = tonumber(battle_info.segment_info[segment_type.fpp_team]);
	end

	--回传排行数据
	--第三人称

	RoleInfoSystem.PersonalTotalRankInfo = {};

	if battle_info.tpp_rank == nil then
		--local data = Client.GetTableData("LocalizeRes", 102127);
		--local text = tostring(data.TextValue);
		local text = ""
		if type(battle_info.tpp_refer_rating) == "number" then
			RoleInfoSystem.top1w_score = battle_info.tpp_refer_rating
		end
		RoleInfoSystem.PersonalTotalRankInfo =
		{
			role_totalrank = "",
		}
	else
		RoleInfoSystem.PersonalTotalRankInfo =
		{
			role_totalrank = battle_info.tpp_rank,
		}
	end
	RoleInfoSystem.SetElementToString(RoleInfoSystem.PersonalTotalRankInfo);

	--第一人称

	RoleInfoSystem.FPPPersonalTotalRankInfo = {};

	if battle_info.fpp_rank == nil then
		--local data = Client.GetTableData("LocalizeRes", 102127);
		--local text = tostring(data.TextValue);
		local text = ""
		if type(battle_info.fpp_refer_rating) == "number" then
			RoleInfoSystem.fpp_top1w_score = battle_info.fpp_refer_rating
		end
		RoleInfoSystem.FPPPersonalTotalRankInfo =
		{
			role_totalrank = "",
		}
	else
		RoleInfoSystem.FPPPersonalTotalRankInfo =
		{
			role_totalrank = battle_info.fpp_rank,
		}
	end
	RoleInfoSystem.SetElementToString(RoleInfoSystem.FPPPersonalTotalRankInfo);


	--战绩总分数据
	--第三人称
	if battle_info.warall.rank_rating ~= nil then
		RoleInfoSystem.PersonalTotalScoreInfo =
		{
			role_totalscore = battle_info.warall.rank_rating;
		}
	else
		RoleInfoSystem.PersonalTotalScoreInfo =
		{
			role_totalscore = tonumber(Client.GetTableData("LocalizeRes", 105014).TextValue);
		}
	end
	RoleInfoSystem.SetElementToString(RoleInfoSystem.PersonalTotalScoreInfo);
	--第一人称
	if battle_info.warall.fpp_rank_rating ~= nil then
		--log("000000000000000000000000000000000000000000000000")
		RoleInfoSystem.FPPPersonalTotalScoreInfo =
		{
			role_totalscore = battle_info.warall.fpp_rank_rating;
		}
	else
		-- log("999999999999999999999999999999999999999999999999")
		RoleInfoSystem.FPPPersonalTotalScoreInfo =
		{
			role_totalscore = tonumber(Client.GetTableData("LocalizeRes", 105014).TextValue);
		}
	end
	RoleInfoSystem.SetElementToString(RoleInfoSystem.FPPPersonalTotalScoreInfo);
	

	--if RoleInfoSystem.Update_Ctrl == RoleInfoSystem.GetDataMaxTimes then
	RoleInfoSystem.UpdateRankNo()
	EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_ROLEINFO); --这个地方需要优化
	
	EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_SEASONCOMBATINFO);
end

--处理玩家历史赛季信息收包错误
function RoleInfoSystem.ProcessSeasonCombatInfoError()
	log("RoleInfoSystem ProcessSeasonCombatInfoError");
	
	RoleInfoSystem.CombatTotalInfoList = {};
	RoleInfoSystem.CombatSurviveInfoList = {};
	RoleInfoSystem.CombatScoreInfoList = {};
	RoleInfoSystem.CombatBattleInfoList = {};
	RoleInfoSystem.CombatGradeInfoList = {};
	RoleInfoSystem.FPPCombatTotalInfoList = {};
	RoleInfoSystem.FPPCombatSurviveInfoList = {};
	RoleInfoSystem.FPPCombatScoreInfoList = {};
	RoleInfoSystem.FPPCombatBattleInfoList = {};
	RoleInfoSystem.FPPCombatGradeInfoList = {};
	
	local length = RoleInfoSystem.GetTableLength(model_type);
	for i = 1, length do
		if i == model_type.all_model then
			RoleInfoSystem.CombatTotalInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.CombatTotalInfo);
			RoleInfoSystem.FPPCombatTotalInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.CombatTotalInfo);
		else
			RoleInfoSystem.CombatTotalInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.CombatTotalInfo);
			RoleInfoSystem.CombatSurviveInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.CombatSurviveInfo);
			RoleInfoSystem.CombatScoreInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.CombatScoreInfo);
			RoleInfoSystem.CombatBattleInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.CombatBattleInfo);
			RoleInfoSystem.CombatGradeInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.CombatGradeInfo);
			RoleInfoSystem.FPPCombatTotalInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.CombatTotalInfo);
			RoleInfoSystem.FPPCombatSurviveInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.CombatSurviveInfo);
			RoleInfoSystem.FPPCombatScoreInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.CombatScoreInfo);
			RoleInfoSystem.FPPCombatBattleInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.CombatBattleInfo);
			RoleInfoSystem.FPPCombatGradeInfoList[i] = FuncUtil:CopyTable(RoleInfoSystem.CombatGradeInfo);
		end
	end
	RoleInfoSystem.FormatCombatInfo();
	RoleInfoSystem.SetElementToString(RoleInfoSystem.CombatTotalInfoList);
	RoleInfoSystem.SetElementToString(RoleInfoSystem.CombatSurviveInfoList);
	RoleInfoSystem.SetElementToString(RoleInfoSystem.CombatScoreInfoList);
	RoleInfoSystem.SetElementToString(RoleInfoSystem.CombatBattleInfoList);
	RoleInfoSystem.SetElementToString(RoleInfoSystem.CombatGradeInfoList);
	RoleInfoSystem.SetElementToString(RoleInfoSystem.FPPCombatTotalInfoList);
	RoleInfoSystem.SetElementToString(RoleInfoSystem.FPPCombatSurviveInfoList);
	RoleInfoSystem.SetElementToString(RoleInfoSystem.FPPCombatScoreInfoList);
	RoleInfoSystem.SetElementToString(RoleInfoSystem.FPPCombatBattleInfoList);
	RoleInfoSystem.SetElementToString(RoleInfoSystem.FPPCombatGradeInfoList);
	
	EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_SEASONCOMBATINFO);
end

function RoleInfoSystem.Get_last_battle_type_req()
	NetUtil.SendPkg("get_last_battle_type_req");
end

function RoleInfoSystem.get_last_battle_type_rsp( ret, last_battle )
	--log_tree("RoleInfoSystem.get_last_battle_type_rsp", last_battle);
	if Last_Combat_Get == false then
		if ret == 0  and last_battle ~= nil then
			BP_RoleInfo_CombatShootTypeID = math.floor(tonumber(last_battle.record_type / 100)); -- 401 取出4，表示第一人称，需要转换成2
			if BP_RoleInfo_CombatShootTypeID > 1 then
				BP_RoleInfo_CombatShootTypeID = 2;
			end
			--BP_RoleInfo_CombatShootTypeID = BP_Combat_ShootType;

			BP_CombatModelType = tonumber(last_battle.record_type % 100);
			--BP_CombatModelType = BP_Combat_PlayerNum;
			
			local zoneID = tonumber(last_battle.zone_id);
			---如果和默认的不相等，从新复制并且拉取最新的zone信息

			if BP_Back_ShowRoleInfoOfZoneId ~= zoneID and zoneID > 0 then
				BP_Back_ShowRoleInfoOfZoneId = zoneID;
				RoleInfoSystem.RequestRoleInfo();
				log("get_last_battle_type_rsp & RoleInfoSystem.RequestRoleInfo");
			end
		end

		DataMgr.Last_CombatModelType = BP_CombatModelType;
		DataMgr.Last_ZoneId = BP_Back_ShowRoleInfoOfZoneId;
		DataMgr.Last_Combat_ShootType = BP_RoleInfo_CombatShootTypeID;
		Last_Combat_Get = true;
	end

	--if RoleInfoSystem.Update_Ctrl >= RoleInfoSystem.GetDataMaxTimes then
	--	RoleInfoSystem.Update_Ctrl = 0;
	--end
	--RoleInfoSystem.Update_Ctrl = RoleInfoSystem.Update_Ctrl + 1;
	--if RoleInfoSystem.Update_Ctrl == RoleInfoSystem.GetDataMaxTimes then
        RoleInfoSystem.UpdateRankNo()
		--更新玩家信息
		EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_ROLEINFO);
	--end

	--log("BP_Combat_ShootType:" .. BP_Combat_ShootType);
	--log("BP_CombatModelType:" .. BP_CombatModelType);
	--log("BP_Back_ShowRoleInfoOfZoneId:" .. BP_Back_ShowRoleInfoOfZoneId);
end

function RoleInfoSystem.get_role_lbs_battle_info_rsp( ok, callback, battle_info, curr_season_index)
	--log_tree("get_role_lbs_battle_info_rsp:", {ok, callback, curr_season_index, battle_info})
	DataMgr.lbs_warzone_info.lbs_warzone_record = battle_info.lbs_warzone_info;
	EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_WARZONE_BATTLE_INFO);

	--ShareWarZoneTitletUI.RefreshTotalKillData();
end


s2c["get_role_battle_info_rsp"] = function(...)
    RoleInfoSystem.get_role_combat_info_rsp(...);
    --SeasonSystem.get_role_battle_info_rsp(...);
end
s2c["modify_role_signature_respond"] = RoleInfoSystem.modify_role_signature_respond;
--测试
s2c["get_social_card_rsp"] = RoleInfoSystem.get_social_card_rsp;
s2c["modify_social_card_rsp"] = RoleInfoSystem.modify_social_card_rsp;
s2c["modify_role_name_rsp"] = RoleInfoSystem.modify_role_name_rsp;
-- s2c["get_one_user_rank_rsp"] = RoleInfoSystem.get_role_rank_info_rsp;
s2c["get_role_privacy_rsp"] = RoleInfoSystem.get_role_privacy_rsp;
s2c["get_role_history_season_battle_rsp"] = RoleInfoSystem.get_role_history_season_battle_rsp;
--请求玩家最后一场战斗的模式和zoneID
s2c["get_last_battle_type_rsp"] = RoleInfoSystem.get_last_battle_type_rsp;
s2c["get_role_lbs_battle_info_rsp"] = RoleInfoSystem.get_role_lbs_battle_info_rsp;




