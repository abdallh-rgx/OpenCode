
BattleResultUI = BattleResultUI or {
	battle_id = "",
	team_id = "",
	result_time = 0,
	uid_back = 0,
	result_back = {},

}

--注册Widget
function bp_battleresult_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_battleresult,
		{
			--{Path="/Game/BluePrints/ControlInput/ResultsshareUI/Results_BP.Results_BP_C", Container="Default", ZOrder=BP_ENUM_UI_RANK_ZORDER},
			{Path="/Game/BluePrints/ControlInput/ResultsshareUI/ResultsRanking_BP.ResultsRanking_BP_C", Container="Default", ZOrder=BP_ENUM_UI_RANK_ZORDER},
			{Path="/Game/BluePrints/PVE/UMG/Results/PVEResultsRanking_BP.PVEResultsRanking_BP_C", Container="Default", ZOrder=BP_ENUM_UI_RANK_ZORDER},
			--{Path="/Game/BluePrints/ControlInput/ResultsshareUI/Shareinterface_UIBP.Shareinterface_UIBP_C", Container="Default", ZOrder=0},
			{Path="/Game/BluePrints/ControlInput/ResultsshareUI/WatchGame_UIBP.WatchGame_UIBP_C", Container="Default", ZOrder=BP_ENUM_UI_RANK_ZORDER},
			{Path="/Game/BluePrints/ControlInput/ResultsshareUI/ResultTrainingEnd_UIBP.ResultTrainingEnd_UIBP_C", Container="Default", ZOrder=BP_ENUM_UI_RANK_ZORDER},
		},
		{"Fighting"},
		false,
		true,
        true
	);


	-- 打开死亡回放功能
	Client.EnableDeathPlayback(GameFrontendHUD, true, false);

    BattleResult.ShowingExitWatchGame = false;

    EventSystem:registEvent(EVENTTYPE_BIND_INTL, EVENTID_VERSION_UPDATE_IOS_CHECK, BattleResultUI.HandleIOSCheck);
	EventSystem:registEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_INFO_UPDATE, BattleResultUI.OnGameEndTaskUpdate)
	EventSystem:registEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_COLLECT, BattleResultUI.OnCollectedResult);
end

-----------------------------------观战角色详细信息start--------------------------------------

BattleDataMatchMode = 0;

InGame_IsMyFriend = true;
Ingame_PlayerTitle = "";
Ingame_PlayerData_MatchMode = "";
Ingame_PlayerData_MatchMode_PlayerNum = "";
Ingame_OBPlayer_BattleData_UID = "";
Ingame_OBPlayer_BattleData_Mode = 0;
Ingame_CurSeasonName = "";
Ingame_CurItemId = 0;
Ingame_IsCurItemCollected = false;

function EventOBViewGetCurSeasonName()
	log("EventOBViewGetCurSeasonName season_id = "..tostring(DataMgr.season_id));
	local cfg = Client.GetTableData("SeasonInfo", DataMgr.season_id);
    if cfg then
        Ingame_CurSeasonName = cfg.SeasonName
    end
end

function EventGetIsMyFriend()
	local selfUid = 0;
	if DataMgr ~= nil and DataMgr.roleData ~= nil then	
		selfUid = tonumber(DataMgr.roleData.uid);
	end

	InGame_IsMyFriend = FriendSystem.IsMyFriend("" .. Ingame_OBPlayer_BattleData_UID);
	log("EventGetIsMyFriend InGame_IsMyFriend = "..tostring(InGame_IsMyFriend));
end

--发送加好友请求
function EventOBViewAddFriendRequest()
	log("EventOBViewAddFriendRequest start add friend  " .. tostring(Ingame_OBPlayer_BattleData_UID));		

	FriendSystem.AddFriend("" .. Ingame_OBPlayer_BattleData_UID, BP_ENUM_ADD_FRIEND_FROM_OB_PLAYER_INFO, 39);
end

--判断当前物品是否被收藏
function EventGetItemIsCollected()
	Ingame_IsCurItemCollected = StoreSystem.IsCollectedByItemID(Ingame_CurItemId);
end

--点击收藏按钮
function EventOnClickInGameCollect()
	log("EventOnClickInGameCollect");
	if StoreSystem.IsCollectedByItemID(Ingame_CurItemId) then
		StoreSystem.cancel_market_collect_by_item_req(Ingame_CurItemId);
	else
		StoreSystem.add_market_collect_by_item_req(Ingame_CurItemId, StoreSystem.market_collect_source_watch);
	end
end

function BattleResultUI.OnCollectedResult()
	log("BattleResultUI.OnCollectedResult");
	LuaClassObj.HandleUIMessage(bp_battleresult, "InitCollectButtonByItemID");
end

--获取玩家历史战斗数据匹配模式
function EventGetPlayerMatchMode()
	local MatchMode = Client.GetTableData("MatchModeTable", tostring(BattleDataMatchMode));
	if MatchMode ~= nil then
		local matchModeStringID = MatchMode.WordsToShowID;
		local Localize1 = Client.GetTableData("LocalizeRes", matchModeStringID);
		if Localize1 ~= nil then
			Ingame_PlayerData_MatchMode = Localize1.TextValue or "";
		end
		
		local playerNumStringID = MatchMode.PlayerNumStrID;
		local LocalizeNumString = Client.GetTableData("LocalizeRes", playerNumStringID);
		if LocalizeNumString ~= nil then
			Ingame_PlayerData_MatchMode_PlayerNum = LocalizeNumString.TextValue or "";
		end
	end
	log("UIIngamePlayerInfo.EventGetPlayerMatchMode [MatchMode:"..Ingame_PlayerData_MatchMode.."][PlayerNum:"..Ingame_PlayerData_MatchMode_PlayerNum.."]");
end

--观战角色战斗信息没有获取到，要重新请求
function EventGetPlayerObBattleInfo()
	local uid = tonumber(Ingame_OBPlayer_BattleData_UID);
	log("UIIngamePlayerInfo.EventGetPlayerObBattleInfo [uid:"..uid.."][mode:"..Ingame_OBPlayer_BattleData_Mode.."]");
	NetUtil.SendPkg("get_ob_battle_info_req", uid, Ingame_OBPlayer_BattleData_Mode);
end

Ingame_GetOBInfo_UID = "";
Ingame_GetOBInfo_Mode = 0;
Ingame_GetOBInfo_ValidBattleInfo = false;
Ingame_GetOBInfo_GameCount = 0;
Ingame_GetOBInfo_WinCount = 0;
Ingame_GetOBInfo_TopTenCount = 0;
Ingame_GetOBInfo_KillNum = 0;
Ingame_GetOBInfo_KDNum = "";
function BattleResultUI.OnGetOBPlayerBattleInfo(playerOBBattleInfo)
	if playerOBBattleInfo ~= nil and next(playerOBBattleInfo) ~= nil then
		Ingame_GetOBInfo_UID = tostring(playerOBBattleInfo.UID);
		Ingame_GetOBInfo_Mode = playerOBBattleInfo.BattleMode;
		Ingame_GetOBInfo_ValidBattleInfo = playerOBBattleInfo.ValidBattleInfo;
		Ingame_GetOBInfo_GameCount = playerOBBattleInfo.GameCount;
		Ingame_GetOBInfo_WinCount = playerOBBattleInfo.WinCount;
		Ingame_GetOBInfo_TopTenCount = playerOBBattleInfo.TopTenCount;
		Ingame_GetOBInfo_KillNum = playerOBBattleInfo.KillNum;
		Ingame_GetOBInfo_KDNum = tostring(playerOBBattleInfo.KDNum);
		
		log("BattleResultUI.OnGetOBPlayerBattleInfo UpdateOBPlayerBattleInfo");
		LuaClassObj.HandleUIMessage(bp_battleresult, "OnGetOBPlayerBattleInfo");
	else
		log("BattleResultUI.OnGetOBPlayerBattleInfo Invalid playerOBBattleInfo");
		log_tree("playerOBBattleInfo:", playerOBBattleInfo);
	end
end
-----------------------------------观战角色详细信息end--------------------------------------



function BattleResultUI.HandleIOSCheck()
	-- body
	if GlobalData:IsIOSCheck() then
	log("bp_battleresult_RegisterUI start");
    LuaClassObj.SubCollapseWidgetList(bp_battleresult,
        "ResultsRanking_BP_C",
		{
			"Overlay_ShareBtn",
            "FlauntBox",
            "Overlay_ShareTips",
            "Button_ShareTitle",
		}
	);
	LuaClassObj.HandleCollapseWidgetList(bp_battleresult, "ResultsRanking_BP_C");
    end
    
end


--[[
	视频录制上传数据结构
--]]
BP_STRUCT_RecordingUpload = 
{
	platform = "",--平台:"QQ"/"WX"
	openUid = "",--平台UID
	roleUid = "",--角色UID
	battleUid = "",--当局战斗UID
	killNum = 0,--击杀熟
	HeadShotNum = 0,--爆头数
	MaxKillDistane = 0,--最远击杀距离
};

--[[
	视频分享tlog
--]]
BP_STRUCT_RecordDataTLogUpload = 
{
	device_type = "",--机型
	share_channel = "",--分享渠道
};

BP_STRUCT_BTRating = 
{
    rank_rating=0,  --变化后总积分
    kill_rating=0,  --变化后击杀积分
    win_rating=0,   --变化后胜利积分
    change_rank_rating=0,  --当局总积分变化值
    change_kill_rating=0,  --当局击杀积分变化值
    change_win_rating=0,   --当局胜利积分变化值
};

--生存评分，伤害评分，支援评分，装备评分，击败评分
BP_STRUCT_RADAR =
{
	SurviveScore_f=0;
	HurtScore_f=0;
	SupportScore_f=0;
	SupplyScore_f=0;
	KillScore_f=0;
	MonsterKillScore_f=0;
	MonsterDamageScore_f=0;
	MonsterHeadShotScore_f=0;

	SurviveScore_s="";
	HurtScore_s="";
	SupportScore_s="";
	SupplyScore_s="";
	MonsterHeadShotScore_s="";	
	MonsterKillScore_s="";	
	MonsterDamageScore_s="";	
	KillScore_s="";	

	SurviveScore=0;
	HurtScore=0;
	SupportScore=0;
	SupplyScore=0;
	KillScore=0;
	MonsterKillScore=0;
	MonsterDamageScore=0;
	MonsterHeadShotScore=0;
};

BP_STRUCT_GOLD_DETAIL =
{
	up_limit=0;

    rank_gold=0;
    kill_gold=0;
    hurt_gold=0;
    watch_gold=0;

    team_add=0;
    famous_master_add=0;
    sm_add=0;
    gold_card_add=0;
    limitact_double_gold_rate=0;

    survive_gold=0; --生存金币
   	survived_gold=0; --胜利金币
   	kill_monster_gold=0; --杀怪金币
};

BP_STRUCT_EXP_DETAIL =
{
    survive_exp=0;
    kill_exp=0;
    first_exp=0;
    top10_exp=0;
    watch_exp=0;

    team_add=0;
    plat_add=0;
    qq_super_vip_add=0;
    exp_card_add=0;
    famous_master_add=0;
    sm_add=0;
    clan_add=0;
    limitact_double_exp_rate=0;

    kill_monster_exp=0; --杀怪经验
    survived_exp=0; --存活经验(时间胜利)
};

BP_STRUCT_MemBTResultData = 
{
    Name = "",
	Kill = 0,
    State = "",
    travelDistance = 0,   -- 总距离
    marchDistance=0,      -- 行走距离
	driveDistance=0,      -- 驾驶距离
    DamageAmount = 0,
   	surviveTime=0,
   	AssistNum=0,
	HeadShotNum=0,
	rescueTimes=0,
    HealAmount = 0,
    BP_ARRAY_Title_List = 
    {
    	title_id = -1,
    },         -- 称号id
    UID = "",  --  玩家ID
    rela_sex = 1, -- 玩家性别1男2女
	ShouldShowAddFriendBtn = 0, -- 0 已经是好友,不需要显示  1 正常显示  2 已经添加了,不能再点击状态

	-- 分数维度统计
	SurviveScore = 0;
	BattleScore = 0;
	SupportScore = 0;
	TravelScore = 0;
	SupplyScore = 0;
	FinalScore_f = 0;
	IsMVP = false;

	pve_total_score = 0, --总分
	KillMonsterNum = 0,
	MonsterHeadShotKilledTimes = 0,
	TotalDamageAmountToMonsters = 0,
};

BPRecordAddFriendIndex = 0; -- BP 会调用加好友的协议 这个变量记录想加哪个为好友.

BP_RecordUpvoteTeammateIndex = 0; -- BP 点赞的好友index

BP_UpvotePlayerName = ""; -- 给你点赞玩家的名字

BP_STRUCT_BattleResultData = 
{
	Reason = "",
	RemainingPlayerCount=0,
	TotalPlayerCount=100,
	RemainingTeamCount=0,
	TotalTeamCount=25,
	IsSolo=false,
	ShootWeaponShotNum=0,
	ShootWeaponShotAndHitPlayerNum=0,
	HealTimes=0,
	destroyVehicleNum=0,
	HeadShotRatio=0.2,
	add_exp=0,
	add_gold=0,
	add_vaccinum=0;
	add_carteam_coin=0, --赛事币
	rank_score=0, --赛事排名积分
	kill_score=0, --赛事击杀积分
	league_seq=0, --赛事编号
	tournament_id=0, --锦标赛编号，大于0代表是锦标赛
	battle_id=0,
	max_game_num=2,
	person_rank=1,
	team_rank=1,
	final_level="",
	is_team_result=false,
	is_last_survive=false,
	is_version_match=false,
	battle_type = 101,
	get_gold_today = 0,
	famous_id = 0,
	isobserver=false,
	is_anchor_ob = false,
	battle_owner = 0,
	sub_mode = 0,
	segment_protect=false,
	delay_time=0,			-- 延迟结算时间

    BP_ARRAY_TeammateList = 
	{
		tmp_UseExist_BP_STRUCT_MemBTResultData = {},
	},
	BP_STRUCT_BTRating = _G.BP_STRUCT_BTRating,
	BP_STRUCT_GOLD_DETAIL = _G.BP_STRUCT_GOLD_DETAIL,
	BP_STRUCT_EXP_DETAIL = _G.BP_STRUCT_EXP_DETAIL,
	BP_STRUCT_RADAR = _G.BP_STRUCT_RADAR,
};

BP_STRUCT_TeammateProfile =
{
	uid = "",
	picUrl = "",	-- 头像url
	level = 0,
	cur_avatar_box_id = 0,
};

BP_ARRAY_TeammateProfile =
{
	BP_STRUCT_TeammateProfile = _G.BP_STRUCT_TeammateProfile,
};

BP_STRUCT_AvatarInfo = 
{
	resID = 401999,
	colorID = 0,
	patternID = 0,
}

BP_ARRAY_AvatarList = 
{
	BP_STRUCT_AvatarInfo = _G.BP_STRUCT_AvatarInfo,
}

BP_STRUCT_SpawnPlayerRoleInfo =
{
    gid = "",
    sex = 1,
    headId = 401999,
    index = 1,
    weaponId = 0,
    weaponSkinId = 0,
    playerName = "",
    resultAvatarPose = 0,
	PetId = 0, --宠物id
	PetLevel = 0, --宠物等级
    BP_ARRAY_AvatarList = _G.BP_ARRAY_AvatarList,
}

-- 组队玩家个人形象列表
BP_ARRAY_TeammateRoleInfo =
{
    BP_STRUCT_SpawnPlayerRoleInfo = _G.BP_STRUCT_SpawnPlayerRoleInfo,
}

BP_STRUCT_BattleResultMyInfo =
{
	roleUid = "",
	headIconUrl = "",
	gender = 0,
	nickName = "",
	cur_avatar_box_id = 0,
};



--OB模式全部队伍结算信息
BP_ARRAY_OBBattleResult = 
{
	tmp_UseExist_BP_STRUCT_OBTeamResult = {}
}
--OB模式一个队伍结算信息
BP_STRUCT_OBTeamResult = 
{
	BP_ARRAY_OBPersonalResult =
	{
		tmp_UseExist_BP_STRUCT_OBPersonalResult = {}
	}
}
--OB模式队内单人结算信息
BP_STRUCT_OBPersonalResult = 
{
	uid = "",
	rank = 0,
	kill = 0,
	name = "",
	gender = 0
}
BP_IsShowOBGender = true
BP_myname = "12345678901234";
BP_mykill=3;

BP_mystate="";
BP_IsTodayShareDone = false;
BP_IsShareAwardGold = false;
BP_Terminator = ""; --终结者

BP_EnterSpectateMode = false;

testResult = false;

--登陆平台（微信，手Q）
BP_LoginChannel = 1;
--服务器时间秒数，供蓝图用
BP_ServerTimeSecNow = 0;

--举报界面打开与否
BP_IsReportComplaintShow = false;

--该模式是否是决战天命圈模式
BP_IsDroiyanMode = false;
BP_TeamModeName = "";

BP_DirectShow = false;

--仇人名字和是否是AI记录，因战斗回放导致数据丢失，这里缓存下
BP_BattleResultMurderName = ""
BP_BattleResultIsAI = false
BP_BattleResultIsClickReplay = false

BP_BattleResultIsIOSCheck = false;

BP_BattleResultCanShowStrategyBtn = true;
BattleResult_TeamList_ForReportComplaint = {}
BP_IsReceiveResult = false;
BP_IsShowResultPanel = false;

BP_WatchGame_TargetName = "";
BP_WatchGame_CanReservation = false;
BP_WatchGame_AcceptReservation = false;

BP_WatchGame_ReplyState = 0; -- 0 拒绝 1 同意
BP_WatchGame_ReplyTip = ""; --玩家名字七个字拒绝了你的预约
BP_WatchExitReason = "game_over";	--队友退出原因

-- 新的吃鸡结算持续时间
BP_BattleResultCakePlacementDelayTime = 40;
BP_ShouldDelayShowBattleResult = true;

-- 胜利时刻
BP_BattleResultIsEnableWinnerTime = true; -- 是否启用胜利时刻功能
BP_BattleResultWinnerFreeMoveTime = 10; -- 吃鸡玩家可以自由移动的时间
BP_BattleResultPVEWinnerFreeMoveTime = 30; -- PVE模式吃鸡玩家可以自由移动的时间
BP_BattleResultSecondWatchPlusTime = 7; -- 第二名玩家，增加的观看时长

-- 禁止战争模式下，使用胜利时刻
BP_ARRAY_BattleResultForbidWinnerTimeSubMode =
{
	1070, 1071, 1072, 1094, 1095, 1096
};

BP_BattleResultNeedShowAd = false;

--结算pass任务信息
BP_STRUCT_BattleResult_Pass_Mission_Info = 
{
	taskId = 0,		--0表示全部任务已完成
	desc = "",		--任务描述
	status = 0,		--任务完成状态，0-未完成
	weekTitle = "",	--周标题
	weekTaskNum = 0,	--周任务完成数量
	refresh_time = 0,
};

BP_MyKillMonsterNum=0;
BP_MyKillLickerNum=0;
BP_MyKillTyrantNum=0;
BP_MyKillGNum=0;

BP_MyPVETotalScore = 0; --综合评分
BP_MyPetAddExp=0; --宠物经验

BP_MyPVE_DEGREE = 0; -- PVE等级
BP_MyCurPVE_EXP = 0; -- 当前PVE经验值
BP_MyTotalPVE_EXP = 0; -- 当前PVE经验总目标值

BP_MySurviveTime_f = 0; -- 存活时间

BP_STRUCT_PVE_INFO = --PVE击杀统计
{
	NormalMonsterKillNum = 0,
	EliteMonsterKillNum = 0,
	BossKillNum = 0,
	MonsterHeadShotKilledTimes = 0,
	BeMonsterDownTimes = 0,
	TotalDamageAmountToMonsters = 0.0,
	TotalDamageAmountFromMonsters = 0.0,
};

BP_STRUCT_PVE_SCORE = --PVE得分统计
{
	MonsterKillScore = 0, --怪物击杀分
	MonsterDamageScore = 0, --怪物伤害分
	MonsterHeadShotScore = 0, --怪物爆头分

	NormalMonsterKillScore = 0, --普通怪物击杀分
	EliteMonsterKillScore = 0, --精英怪物击杀分
	BossMonsterKillScore = 0, --BOSS怪物击杀分
	TakeMonsterDamageScore = 0, -- 承受怪物伤害分
	SurviveScore = 0, --生存分
	KillScore = 0, --击杀分
};

-- ****************PVE排名数据 start ***********************

BP_STRUCT_PVEMemberData = 
{
	name = "",
	score_f = 0,
};

BP_ARRAY_PVEMembersList =
{
	BP_STRUCT_PVEMemberData = _G.BP_STRUCT_PVEMemberData,
};

BP_STRUCT_PVETeamData = 
{
	TotalScore_f = 0,	
	BP_ARRAY_PVEMembersList = _G.BP_ARRAY_PVEMembersList,
};

BP_ARRAY_PVEVictoryRankingList = 
{
	BP_STRUCT_PVETeamData = _G.BP_STRUCT_PVETeamData,
};



--发送加好友请求
function EventAddFriendRequest_Push()
	log("BattleResultUI start add friend  " .. (BPRecordAddFriendIndex + 1));		

	if BP_STRUCT_BattleResultData~=nil and BP_STRUCT_BattleResultData.BP_ARRAY_TeammateList ~=nil and
		BP_STRUCT_BattleResultData.BP_ARRAY_TeammateList[BPRecordAddFriendIndex + 1] ~=nil 
		and BPRecordAddFriendIndex > -1 then

		--log_tree("BattleResultUI v is ", BP_STRUCT_BattleResultData.BP_ARRAY_TeammateList[BPRecordAddFriendIndex + 1]);

		log("BattleResultUI send friend invite to "..BP_STRUCT_BattleResultData.BP_ARRAY_TeammateList[BPRecordAddFriendIndex + 1].UID)
		if BP_STRUCT_BattleResultData.BP_ARRAY_TeammateList[BPRecordAddFriendIndex + 1].rela_sex == 1 then
			FriendSystem.AddFriend("" .. BP_STRUCT_BattleResultData.BP_ARRAY_TeammateList[BPRecordAddFriendIndex + 1].UID, BP_ENUM_ADD_FRIEND_FROM_BATTLE_RESULT, 7) -- tostring
		else
			FriendSystem.AddFriend("" .. BP_STRUCT_BattleResultData.BP_ARRAY_TeammateList[BPRecordAddFriendIndex + 1].UID, BP_ENUM_ADD_FRIEND_FROM_BATTLE_RESULT, 8) -- tostring
		end
		--FriendSystem.AddFriend("" .. BP_STRUCT_BattleResultData.BP_ARRAY_TeammateList[BPRecordAddFriendIndex + 1].UID, BP_ENUM_ADD_FRIEND_FROM_BATTLE_RESULT) -- tostring
		BP_STRUCT_BattleResultData.BP_ARRAY_TeammateList[BPRecordAddFriendIndex + 1].ShouldShowAddFriendBtn = 2; -- clicked
	end

	if BP_STRUCT_BattleResultData == nil then
		log("BattleResultUI BP_STRUCT_BattleResultData is nil")
	elseif BP_STRUCT_BattleResultData.BP_ARRAY_TeammateList == nil then
		log("BattleResultUI BP_STRUCT_BattleResultData.BP_ARRAY_TeammateList is nil")
	elseif BP_STRUCT_BattleResultData.BP_ARRAY_TeammateList[BPRecordAddFriendIndex + 1] then
		log("battleresultui BP_STRUCT_BattleResultData.BP_ARRAY_TeammateList[BPRecordAddFriendIndex + 1] == nil")
	elseif BPRecordAddFriendIndex <= -1 then
		log("BattleResultUI index < 0 "..BPRecordAddFriendIndex)
	end

end

function EventUpvoteTeammateRequest_Push()
	log("BattleResultUI EventUpvoteTeammateRequest_Push  " .. (BP_RecordUpvoteTeammateIndex + 1));

	if BP_STRUCT_BattleResultData~=nil and BP_STRUCT_BattleResultData.BP_ARRAY_TeammateList ~=nil and
		BP_STRUCT_BattleResultData.BP_ARRAY_TeammateList[BP_RecordUpvoteTeammateIndex + 1] ~=nil 
		and BP_RecordUpvoteTeammateIndex > -1 then
		log("BattleResultUI send upvote to "..BP_STRUCT_BattleResultData.BP_ARRAY_TeammateList[BP_RecordUpvoteTeammateIndex + 1].UID);
		NetUtil.SendPkg("upvote_req", BP_STRUCT_BattleResultData.BP_ARRAY_TeammateList[BP_RecordUpvoteTeammateIndex + 1].UID);
	end
end

function BattleResultUI.ShowUpvoteTips(uid, name)
	log("BattleResultUI ShowUpvoteTips name: "..name);
	BP_UpvotePlayerName = name;
	LuaClassObj.HandleDynamicCreation(bp_battleresult);
	LuaClassObj.HandleUIMessage(bp_battleresult, "ShowUpvoteTips");
end

function BattleResultUI.UpdateShareBtnState()
	if GlobalData:IsIOSCheck() then
 		return;
 	end 
	
	BP_IsTodayShareDone = ShareAwardMgr.IsTodayShareDone();
	BP_IsShareAwardGold = ShareAwardMgr.IsAllAwardHasGet();
    LuaClassObj.HandleDynamicCreation(bp_battleresult);
	LuaClassObj.HandleUIMessage(bp_battleresult, "SetShareBtnState");
end

function BattleResultUI.FreshTeamMateListToComplaint()
	-- 举报界面记录需要举报的队友
	ComplaintUI:CacheTeamMateList(BattleResult_TeamList_ForReportComplaint)
end

-- 对队友列表进行排序，规则为：
-- 4人：剩余三人中的第二名，自己，剩余三人中的第一名，剩余三人中的第三名	
-- 3人：剩余两人中的第一名，自己，剩余两人中的第二名	
-- 2人：自己，队友	
-- 1人：自己	
function BattleResultUI.SortTeammateList(result)
	local teammateList = result.TeammateList;
	
	if result.ranklist == nil or #result.ranklist ~= #result.TeammateList then
		-- 容错，不合法的ranklist，直接返回
		return teammateList;
	end

	local outputList = {};
	local swapObject = function(obj1, obj2)
	    return obj2, obj1;
	end

	-- 按照后台给的ranklist给四个玩家排序
	for k1,v1 in pairs(result.ranklist) do
		for k2,v2 in pairs(teammateList) do
			if v2.Name == v1 then
				v2.rankIndex = k1;
			end
		end
	end
	table.sort(teammateList, function(a, b)
		return a.rankIndex < b.rankIndex;
	end);

	-- 把自己调到第一位
	for k,v in pairs(teammateList) do
		if v.Name == DataMgr.roleData.nickName then
			table.insert(outputList, 1, v);
		else
			table.insert(outputList, v);
		end
	end

	-- 分配持枪姿势，并把人物站位调整为上述顺序
	if #teammateList == 1 then
		outputList[1].resultAvatarPose = math.random(BattleResult.resultAvatarPoseNormal, BattleResult.resultAvatarPoseAim);
	end

	if #teammateList == 2 then
		outputList[1].resultAvatarPose = math.random(BattleResult.resultAvatarPoseNormal, BattleResult.resultAvatarPoseCrouch);
		outputList[2].resultAvatarPose = outputList[1].resultAvatarPose;
	end

	if #teammateList == 3 then
		outputList[3].resultAvatarPose = math.random(BattleResult.resultAvatarPoseNormal, BattleResult.resultAvatarPoseCrouch);
		outputList[2].resultAvatarPose = outputList[3].resultAvatarPose;
		outputList[1].resultAvatarPose = math.random(BattleResult.resultAvatarPoseNormal, outputList[2].resultAvatarPose);

		outputList[1], outputList[2] = swapObject(outputList[1], outputList[2]);
	end

	if #teammateList == 4 then
		outputList[4].resultAvatarPose = math.random(BattleResult.resultAvatarPoseNormal, BattleResult.resultAvatarPoseCrouch);
		outputList[3].resultAvatarPose = outputList[4].resultAvatarPose;
		outputList[2].resultAvatarPose = math.random(BattleResult.resultAvatarPoseNormal, outputList[3].resultAvatarPose);
		outputList[1].resultAvatarPose = math.random(BattleResult.resultAvatarPoseNormal, outputList[2].resultAvatarPose);

		outputList[2], outputList[3] = swapObject(outputList[2], outputList[3]);
		outputList[1], outputList[2] = swapObject(outputList[1], outputList[2]);
	end
	return outputList;
end

function BattleResultUI.InitRoleInfoList(result)
	
	local list = result.TeammateList;
	BP_ARRAY_TeammateRoleInfo = {};
	for i=1, #list do
		local rolewear = {};
		local wear_ext = list[i].wear_ext or {};
	    for k,v in pairs(wear_ext) do
	    	if k ~= 11 and k ~= 13 and k ~= 14 then --屏蔽降落伞
				table.insert(rolewear, LobbyUI.MakeClientAvatarWearInfo(v));
			end
		end
		--log_tree("rolewear ", rolewear);		

		local pet_id = 0;
		local pet_level = 0;
		if list[i].pet_id ~= nil and list[i].pet_id ~= -1 then -- 新增字段宠物id
			pet_id = list[i].pet_id;
		end

		if list[i].pet_level ~= nil then -- 新增字段宠物等级
			pet_level = list[i].pet_level;
		end

		table.insert(BP_ARRAY_TeammateRoleInfo, {
			sex = list[i].gamegender, 
			headId = wear_ext[9] and wear_ext[9][1] or 0,
			index = i - 1,
			weaponId = wear_ext[13] and wear_ext[13][1] or 0,
			weaponSkinId = wear_ext[14] and wear_ext[14][1] or 0,
			playerName = list[i].Name,
			resultAvatarPose = list[i].resultAvatarPose or 0,
			PetId = pet_id,
			PetLevel = pet_level,
			BP_ARRAY_AvatarList = rolewear,
		});
	end

	log_tree("CCW ", BP_ARRAY_TeammateRoleInfo)
end

-- 更新PVE排名数据
function BattleResultUI.UpdatePVEData(uid, result)

	--[[  **************** PVE排名数据结构 ***********************
	pve_all_teams_summary = 
	{
	    [1] = {
	        members = {
	            [1] = { name = "xxx", score = 1000, uid = 5100000 },
	            [2] = { name = "xxx", score = 800, uid = 5100000 },
	        },
	        total_score = 1800,
	    },
	    [2] = {...},
	    ...
	}
	--]]
	BP_ARRAY_PVEVictoryRankingList = {};
	if result.pve_all_teams_summary ~= nil then
		local list = result.pve_all_teams_summary;
		for i=1, #list do
			local array_members = {};
			local members_list = list[i].members or {};
			local total_score = list[i].total_score or 0;
		    for i,v in ipairs(members_list) do
		    	if v.score ~= nil then
		    		v.score_f = v.score;
		    	end
				table.insert(array_members, v);
			end			

			table.insert(BP_ARRAY_PVEVictoryRankingList, {
				TotalScore_f = total_score,
				BP_ARRAY_PVEMembersList = array_members, 
			});
		end
	end

	log_tree("BattleResultUI.UpdatePVEData BP_ARRAY_PVEVictoryRankingList=>", BP_ARRAY_PVEVictoryRankingList)

end


--显示结算界面的内容
function BattleResultUI.OnBattleResult(uid, result)
	BattleResultUI.uid_back = uid;
	BattleResultUI.result_back = result;
	BattleResultUI.battle_id = tostring(result.battle_id);
	BattleResultUI.team_id = tostring(result.team_id);
	BattleResultUI.result_time = FuncUtil.GetServerTimeInSec();
	BP_IsReceiveResult = true;

	SettingUI:Hide();	--关闭设置界面

	log("g_game_id is "..g_game_id);
	log("result.battle_id is "..result.battle_id);
	log("BattleResultUI param uid is  "..uid);
	log("result.IsKickedFromGame is ".. tostring(result.IsKickedFromGame));
	if g_game_id ~= result.battle_id then
		return;
	end

	BattleResultUI.UpdatePVEData(uid, result);

	--视频录取上传数据
	if DataMgr ~= nil and DataMgr.roleData ~= nil then
		BP_STRUCT_RecordingUpload.platform = _G.BP_Platform == BP_ENUM_PLAYFORM_QQ and "QQ" or "WX";
		BP_STRUCT_RecordingUpload.openUid = tostring(DataMgr.roleData.openID);
		BP_STRUCT_RecordingUpload.roleUid = tostring(DataMgr.roleData.uid);
		BP_STRUCT_RecordingUpload.battleUid = tostring(g_game_id);
		BP_myname = DataMgr.roleData.nickName;
		--log_tree("BP_STRUCT_RecordingUpload ",BP_STRUCT_RecordingUpload)
	end

	
	BattleResult_TeamList_ForReportComplaint = {}
	log("myname is " .. BP_myname);
	--DataMgr.roleData.level = level;

	if result.title_id_list == nil then
		result.title_id_list = {};
	end

	if result.terminator ~= nil then
		BP_Terminator = result.terminator;
	else
		BP_Terminator = "";
	end

	BP_STRUCT_PVE_SCORE.MonsterKillScore = 0; --怪物击杀分
	BP_STRUCT_PVE_SCORE.MonsterDamageScore = 0; --怪物伤害分
	BP_STRUCT_PVE_SCORE.MonsterHeadShotScore = 0; --怪物爆头分
	BP_STRUCT_PVE_SCORE.NormalMonsterKillScore = 0; --普通怪物击杀分
	BP_STRUCT_PVE_SCORE.EliteMonsterKillScore = 0; --精英怪物击杀分
	BP_STRUCT_PVE_SCORE.BossMonsterKillScore = 0; --BOSS怪物击杀分
	BP_STRUCT_PVE_SCORE.TakeMonsterDamageScore = 0; -- 承受怪物伤害分
	BP_STRUCT_PVE_SCORE.SurviveScore = 0; --生存分
	BP_STRUCT_PVE_SCORE.KillScore = 0; --击杀分

	log("result.radar result.radar");
	if result.radar ~= nil then
		if result.radar.MonsterKillScore ~= nil then
			BP_STRUCT_PVE_SCORE.MonsterKillScore = result.radar.MonsterKillScore; --怪物击杀分
		end
		if result.radar.MonsterDamageScore ~= nil then
			BP_STRUCT_PVE_SCORE.MonsterDamageScore = result.radar.MonsterDamageScore; --怪物伤害分
		end
		if result.radar.MonsterHeadShotScore ~= nil then
			BP_STRUCT_PVE_SCORE.MonsterHeadShotScore = result.radar.MonsterHeadShotScore;--怪物爆头分
		end
		if result.radar.NormalMonsterKillScore ~= nil then
			BP_STRUCT_PVE_SCORE.NormalMonsterKillScore = result.radar.NormalMonsterKillScore;--普通怪物击杀分
		end
		if result.radar.EliteMonsterKillScore ~= nil then
			BP_STRUCT_PVE_SCORE.EliteMonsterKillScore = result.radar.EliteMonsterKillScore;--精英怪物击杀分
		end
		if result.radar.BossMonsterKillScore ~= nil then
			BP_STRUCT_PVE_SCORE.BossMonsterKillScore = result.radar.BossMonsterKillScore; --BOSS怪物击杀分
		end
		if result.radar.TakeMonsterDamageScore ~= nil then
			BP_STRUCT_PVE_SCORE.TakeMonsterDamageScore = result.radar.TakeMonsterDamageScore;-- 承受怪物伤害分
		end
		if result.radar.SurviveScore ~= nil then
			BP_STRUCT_PVE_SCORE.SurviveScore = result.radar.SurviveScore;--生存分
		end
		if result.radar.KillScore ~= nil then
			BP_STRUCT_PVE_SCORE.KillScore = result.radar.KillScore;--击杀分
		end
	end

	
	BP_STRUCT_BattleResultData = result;
	BP_STRUCT_BattleResultData.BP_ARRAY_TeammateList = {};

	BP_STRUCT_BattleResultData.BP_STRUCT_BTRating = result.rating;
	BP_STRUCT_BattleResultData.BP_STRUCT_GOLD_DETAIL = {};
	BP_STRUCT_BattleResultData.BP_STRUCT_EXP_DETAIL = {};
	BP_STRUCT_BattleResultData.BP_STRUCT_RADAR = result.radar;
	BP_STRUCT_BattleResultData.IsSolo = result.max_game_num <= 1;
    BP_STRUCT_BattleResultData.max_game_num = result.max_game_num;

    -- 赛事数据初始化
	if result.league_seq == nil or result.league_seq <= 0 then
		BP_STRUCT_BattleResultData.league_seq = 0;	
	end
	if result.tournament_id == nil or result.tournament_id <= 0 then
		BP_STRUCT_BattleResultData.tournament_id = 0;
	end
	BP_STRUCT_BattleResultData.rank_score = result.rank_score or 0;
	BP_STRUCT_BattleResultData.kill_score = result.kill_score or 0;
	BP_STRUCT_BattleResultData.add_carteam_coin = result.add_carteam_coin or 0;


    local selfUid = 0;

    if DataMgr ~= nil and DataMgr.roleData ~= nil then
	    BP_STRUCT_BattleResultMyInfo.roleUid = DataMgr.roleData.uid;
		BP_STRUCT_BattleResultMyInfo.headIconUrl = DataMgr.roleData.headIconUrl;
		BP_STRUCT_BattleResultMyInfo.gender = DataMgr.roleData.gender;
		BP_STRUCT_BattleResultMyInfo.nickName = DataMgr.roleData.nickName;	
		BP_STRUCT_BattleResultMyInfo.cur_avatar_box_id = DataMgr.roleData.cur_avatar_box_id;	
		selfUid = tonumber(DataMgr.roleData.uid);
	end;

	if result.gold_detail ~= nil then
		BP_STRUCT_BattleResultData.BP_STRUCT_GOLD_DETAIL.up_limit = result.gold_detail.up_limit;
		BP_STRUCT_BattleResultData.BP_STRUCT_GOLD_DETAIL.rank_gold = result.gold_detail.rank_gold;
		BP_STRUCT_BattleResultData.BP_STRUCT_GOLD_DETAIL.kill_gold = result.gold_detail.kill_gold;
		BP_STRUCT_BattleResultData.BP_STRUCT_GOLD_DETAIL.hurt_gold = result.gold_detail.hurt_gold;
		BP_STRUCT_BattleResultData.BP_STRUCT_GOLD_DETAIL.watch_gold = result.gold_detail.watch_gold;

		BP_STRUCT_BattleResultData.BP_STRUCT_GOLD_DETAIL.team_add = result.gold_detail.team_add * 100 + 0.0001;
		BP_STRUCT_BattleResultData.BP_STRUCT_GOLD_DETAIL.famous_master_add = (result.gold_detail.famous_master_add or 0) * 100 + 0.0001;
		BP_STRUCT_BattleResultData.BP_STRUCT_GOLD_DETAIL.sm_add = (result.gold_detail.sm_add or 0) * 100 + 0.0001;
		BP_STRUCT_BattleResultData.BP_STRUCT_GOLD_DETAIL.gold_card_add = (result.gold_detail.gold_card_add or 0) * 100 + 0.0001;
		BP_STRUCT_BattleResultData.BP_STRUCT_GOLD_DETAIL.limitact_double_gold_rate = 0;
		if result.gold_detail.limitact_double_gold_rate ~= nil then
			BP_STRUCT_BattleResultData.BP_STRUCT_GOLD_DETAIL.limitact_double_gold_rate = (result.gold_detail.limitact_double_gold_rate or 0) * 100 + 0.0001;
		end

		BP_STRUCT_BattleResultData.BP_STRUCT_GOLD_DETAIL.survive_gold = result.gold_detail.survive_gold or 0;
		BP_STRUCT_BattleResultData.BP_STRUCT_GOLD_DETAIL.survived_gold = result.gold_detail.survived_gold or 0;
		BP_STRUCT_BattleResultData.BP_STRUCT_GOLD_DETAIL.kill_monster_gold = result.gold_detail.kill_monster_gold or 0;
	end;

	if result.exp_detail ~= nil then
		BP_STRUCT_BattleResultData.BP_STRUCT_EXP_DETAIL.survive_exp = result.exp_detail.survive_exp;
		BP_STRUCT_BattleResultData.BP_STRUCT_EXP_DETAIL.kill_exp = result.exp_detail.kill_exp;
		BP_STRUCT_BattleResultData.BP_STRUCT_EXP_DETAIL.first_exp = result.exp_detail.first_exp;
		BP_STRUCT_BattleResultData.BP_STRUCT_EXP_DETAIL.top10_exp = result.exp_detail.top10_exp;
		BP_STRUCT_BattleResultData.BP_STRUCT_EXP_DETAIL.watch_exp = result.exp_detail.watch_exp;

		BP_STRUCT_BattleResultData.BP_STRUCT_EXP_DETAIL.team_add = (result.exp_detail.team_add or 0) * 100 + 0.0001;
		BP_STRUCT_BattleResultData.BP_STRUCT_EXP_DETAIL.plat_add = (result.exp_detail.plat_add or 0) * 100 + 0.0001;
	    BP_STRUCT_BattleResultData.BP_STRUCT_EXP_DETAIL.qq_super_vip_add = (result.exp_detail.qq_super_vip_add or 0) * 100 + 0.0001;
	    BP_STRUCT_BattleResultData.BP_STRUCT_EXP_DETAIL.exp_card_add = (result.exp_detail.exp_card_add or 0) * 100 + 0.0001;

	    BP_STRUCT_BattleResultData.BP_STRUCT_EXP_DETAIL.famous_master_add = (result.exp_detail.famous_master_add or 0) * 100 + 0.0001;
	    BP_STRUCT_BattleResultData.BP_STRUCT_EXP_DETAIL.sm_add = (result.exp_detail.sm_add or 0) * 100 + 0.0001;
	    BP_STRUCT_BattleResultData.BP_STRUCT_EXP_DETAIL.clan_add = (result.exp_detail.clan_add or 0) * 100 + 0.0001;
	    BP_STRUCT_BattleResultData.BP_STRUCT_EXP_DETAIL.limitact_double_exp_rate = 0;
	    if result.exp_detail.limitact_double_exp_rate ~= nil then
	    	BP_STRUCT_BattleResultData.BP_STRUCT_EXP_DETAIL.limitact_double_exp_rate = (result.exp_detail.limitact_double_exp_rate or 0)* 100 + 0.0001;
	    end

		BP_STRUCT_BattleResultData.BP_STRUCT_EXP_DETAIL.kill_monster_exp = result.exp_detail.kill_monster_exp or 0;
		BP_STRUCT_BattleResultData.BP_STRUCT_EXP_DETAIL.survived_exp = result.exp_detail.survived_exp or 0;
	end;

	if result.radar ~= nil then
		BP_STRUCT_BattleResultData.BP_STRUCT_RADAR.SurviveScore_f = string.format("%.1f", result.radar.SurviveScore / 100);
		BP_STRUCT_BattleResultData.BP_STRUCT_RADAR.HurtScore_f = string.format("%.1f", result.radar.HurtScore / 100);
		BP_STRUCT_BattleResultData.BP_STRUCT_RADAR.SupportScore_f = string.format("%.1f", result.radar.SupportScore / 100);
		BP_STRUCT_BattleResultData.BP_STRUCT_RADAR.SupplyScore_f = string.format("%.1f", result.radar.SupplyScore / 100);
		BP_STRUCT_BattleResultData.BP_STRUCT_RADAR.KillScore_f = string.format("%.1f", result.radar.KillScore / 100);

		BP_STRUCT_BattleResultData.BP_STRUCT_RADAR.SurviveScore_s = string.format("%.1f", result.radar.SurviveScore);
		BP_STRUCT_BattleResultData.BP_STRUCT_RADAR.HurtScore_s = string.format("%.1f", result.radar.HurtScore);
		BP_STRUCT_BattleResultData.BP_STRUCT_RADAR.SupportScore_s = string.format("%.1f", result.radar.SupportScore);
		BP_STRUCT_BattleResultData.BP_STRUCT_RADAR.SupplyScore_s = string.format("%.1f", result.radar.SupplyScore);
		BP_STRUCT_BattleResultData.BP_STRUCT_RADAR.KillScore_s = string.format("%.1f", result.radar.KillScore);

		if result.radar.MonsterKillScore ~= nil then
			BP_STRUCT_BattleResultData.BP_STRUCT_RADAR.MonsterKillScore_f = string.format("%.1f", result.radar.MonsterKillScore / 100);
			BP_STRUCT_BattleResultData.BP_STRUCT_RADAR.MonsterKillScore_s = string.format("%.1f", result.radar.MonsterKillScore);
		end
		if result.radar.MonsterDamageScore ~= nil then
			BP_STRUCT_BattleResultData.BP_STRUCT_RADAR.MonsterDamageScore_f = string.format("%.1f", result.radar.MonsterDamageScore / 100);
			BP_STRUCT_BattleResultData.BP_STRUCT_RADAR.MonsterDamageScore_s = string.format("%.1f", result.radar.MonsterDamageScore);
		end
		if result.radar.MonsterHeadShotScore ~= nil then
			BP_STRUCT_BattleResultData.BP_STRUCT_RADAR.MonsterHeadShotScore_f = string.format("%.1f", result.radar.MonsterHeadShotScore / 100);
			BP_STRUCT_BattleResultData.BP_STRUCT_RADAR.MonsterHeadShotScore_s = string.format("%.1f", result.radar.MonsterHeadShotScore);
		end

	end;

	BP_STRUCT_BattleResultData.add_vaccinum = 0; 
	if result.SpecialCollectionList ~= nil then
		for i,v in pairs(result.SpecialCollectionList) do
			log("BattleResultUI.OnBattleResult SpecialCollectionList, i:" .. tostring(i) .. " v: " .. v.item_id );
			if v.item_id == 3001014 then --生化疫苗id
				log("BattleResultUI.OnBattleResult add_vaccinum count:" .. tostring(v.count));
				BP_STRUCT_BattleResultData.add_vaccinum = v.count;
				break
			end
		end
	end

	--log_tree("OnBattleResult result ", result);
    
	--在收到结算消息的时候赋值
	BP_IsDroiyanMode = BattleResultUI.IsDroiyanMode();
	BP_TeamModeName = GetTeamModeName();
	BP_BattleResultIsIOSCheck = GlobalData:IsIOSCheck();
	BattleResultUI.GetStrategyBtnStatus();

	if BP_STRUCT_BattleResultData.IsSolo == false then
		if BP_STRUCT_BattleResultData.is_last_survive then
			log("BattleResultUI last survive!!!!!")
			-- 最后一个死亡则直接显示队伍结算界面
			BP_EnterSpectateMode = false;
		elseif BP_STRUCT_BattleResultData.is_team_result then
			-- 非小队最后一个死亡 并且此时是队伍结算
			-- 可能需要重新刷新处理
			BP_EnterSpectateMode = false;
		else
			-- 非小队最后死亡 并且此时是个人结算         
			BP_EnterSpectateMode = true;
		end
	else
		BP_STRUCT_BattleResultData.is_last_survive = true;
		BP_EnterSpectateMode = false;
	end

	local MyDmg = 0;
	local MyHeadShotRatio = 0;
	local MyTravelDis = 0;
	local MyHeal = 0;

	BP_mykill = 0;
	BP_MyKillMonsterNum = 0;
	BP_MyKillLickerNum = 0;
	BP_MyKillTyrantNum = 0;
	BP_MyKillGNum = 0;


	-- PVE结算数据统计
	BP_MyPVETotalScore = 0; --综合评分
	BP_MyPetAddExp = 0; --宠物经验
	BP_MyPVE_ADD_EXP = 0; -- PVE经验
	BP_MyPVE_DEGREE = 0; -- PVE等级
	BP_MyCurPVE_EXP = 0; -- 当前PVE经验值
	BP_MyTotalPVE_EXP = 0; -- 当前PVE经验总目标值
	BP_MySurviveTime_f = 0; -- 存活时间

	BP_STRUCT_PVE_INFO.NormalMonsterKillNum = 0;
	BP_STRUCT_PVE_INFO.EliteMonsterKillNum = 0;
	BP_STRUCT_PVE_INFO.BossKillNum = 0;
	BP_STRUCT_PVE_INFO.MonsterHeadShotKilledTimes = 0;
	BP_STRUCT_PVE_INFO.BeMonsterDownTimes = 0;
	BP_STRUCT_PVE_INFO.TotalDamageAmountToMonsters = 0;
	BP_STRUCT_PVE_INFO.TotalDamageAmountFromMonsters = 0;

	local uidList = {};
	local MaxScore = 0;
	local MVP;

	if result.is_team_result == true then
		result.TeammateList = BattleResultUI.SortTeammateList(result);
	end

	if result.pet_add_exp ~= nil then
		BP_MyPetAddExp = result.pet_add_exp; --宠物经验
	end	

	BattleResultUI.InitRoleInfoList(result);

	local monsterType = 0;
	for k,v in pairs(result.TeammateList) do
		if v.Name == BP_myname then
			BP_mykill = v.Kill;
			BP_mystate = v.State;

			if v.surviveTime ~= nil then
				BP_MySurviveTime_f = v.surviveTime;
			end

			-- PVE数据统计
			if v.pve_total_score ~= nil then
				BP_MyPVETotalScore = v.pve_total_score; --综合评分
			end
			if v.KillMonsterNum ~= nil then
				BP_MyKillMonsterNum = v.KillMonsterNum; --击杀怪物数量
			end
			if v.MonsterID2KillNum ~= nil then
				for k,v in pairs(v.MonsterID2KillNum) do
					if k ~= nil then
						monsterType = Client.GetTableData("MonsterTable", k).MonsterType; --怪物类型
						if monsterType ~= nil then
							if 1 == monsterType then
								BP_STRUCT_PVE_INFO.NormalMonsterKillNum = BP_STRUCT_PVE_INFO.NormalMonsterKillNum + v; --普通怪击杀数量
							elseif 2 == monsterType then
								BP_STRUCT_PVE_INFO.EliteMonsterKillNum = BP_STRUCT_PVE_INFO.EliteMonsterKillNum + v; --精英怪击杀数量
							elseif 3 == monsterType or 4 == monsterType then
								BP_STRUCT_PVE_INFO.BossKillNum = BP_STRUCT_PVE_INFO.BossKillNum + v; --Boss击杀数量
							end
						end
					end
				end
			end
			if v.TotalDamageAmountToMonsters ~= nil then --对怪物的伤害总量
				BP_STRUCT_PVE_INFO.TotalDamageAmountToMonsters = v.TotalDamageAmountToMonsters;
			end
			if v.TotalDamageAmountFromMonsters ~= nil then --对怪物的承伤总量
				BP_STRUCT_PVE_INFO.TotalDamageAmountFromMonsters = v.TotalDamageAmountFromMonsters;
			end
			if v.MonsterHeadShotKilledTimes ~= nil then --怪物爆头击杀数
				BP_STRUCT_PVE_INFO.MonsterHeadShotKilledTimes = v.MonsterHeadShotKilledTimes;
			end
			if v.BeMonsterDownTimes ~= nil then  --被怪物击倒次数
				BP_STRUCT_PVE_INFO.BeMonsterDownTimes = v.BeMonsterDownTimes;
			end

		end

		if DataMgr ~= nil and DataMgr.roleData ~= nil then
			if tonumber(v.UID) ~= tonumber(DataMgr.roleData.uid) then
				table.insert(uidList, v.UID);
			end
			if DataMgr.roleData.pve_exp ~= nil then
				BP_MyCurPVE_EXP = DataMgr.roleData.pve_exp; -- 当前PVE经验值
			end
			if DataMgr.roleData.pve_level ~= nil then
				BP_MyPVE_DEGREE = DataMgr.roleData.pve_level; -- PVE等级
			end
			if BP_MyPVE_DEGREE ~= 0 then
				-- 当前PVE经验总目标值
				local tmpEXP = Client.GetTableData("PveLevel", BP_MyPVE_DEGREE).exp; --怪物类型
				if tmpEXP ~= nil then
					BP_MyTotalPVE_EXP = tmpEXP;
				end
			end
		else
			table.insert(uidList, v.UID);
		end
		

		log("BattleResultUI Name "..v.Name);
		log("BattleResultUI Kill "..v.Kill);
		log("BattleResultUI Damage "..v.DamageAmount);
		v.UID = "" .. v.UID -- 转为字符串

		v.ShouldShowAddFriendBtn = 0;
		log("BattleResultUI is solo ".. tostring(BP_STRUCT_BattleResultData.IsSolo));
		if BP_STRUCT_BattleResultData.IsSolo ~= true  -- not sole
			and FriendSystem.IsMyFriend("" .. v.UID) ~= true -- not friend
			and selfUid ~= tonumber(v.UID) then -- not self
			v.ShouldShowAddFriendBtn = 1;
			log("BattleResultUI name " .. v.Name .. " can be invited " .. v.ShouldShowAddFriendBtn .. " with id " .. v.UID);
		end

		if FriendSystem.IsMyFriend("" .. v.UID) == true then
			log("BattleResultUI FriendSystem.IsMyFriend( .. v.UID) == true ")
		end
		
		if type(v.FinalScore)=="number" then
			v.FinalScore_f = string.format("%.1f", v.FinalScore);
		else
			v.FinalScore_f = 0;
		end

		log("v.FinalScore_f :" .. type(v.FinalScore_f));

		if v.title_id_list == nil then
			v.title_id_list = {};
		end

		if v.pve_total_score == nil then -- 新增字段PVE总评分
			v.pve_total_score = 0;
		end
		
		v.BP_ARRAY_Title_List = v.title_id_list;

		table.insert(BP_STRUCT_BattleResultData.BP_ARRAY_TeammateList, v);

		--录屏参数
		if v.UID == selfUid then
			BP_STRUCT_RecordingUpload.killNum = v.Kill;
			BP_STRUCT_RecordingUpload.HeadShotNum = v.HeadShotNum;
		end

		--记录给举报
		local teamItem = {}
		if v.Name ~= nil then
			teamItem.Name = v.Name
		end
		table.insert(BattleResult_TeamList_ForReportComplaint, teamItem)
		
		--log_tree("BattleResultUI v is ", v);
	end

	if #uidList > 0 then 
		ProfileMgr.GetProfileList(uidList, BattleResultUI.ImageCallBack, true);
	else
		local list = {};
		BattleResultUI.ImageCallBack(list);
	end
	

	--log_tree("BattleResultUI.OnBattleResult", BP_STRUCT_BattleResultData);
	Client.OnBattleResult(GameFrontendHUD, BP_STRUCT_BattleResultData);
	BP_ServerTimeSecNow = FuncUtil.GetServerTimeInSec();

	-- 更新胜利时刻开关
	BP_BattleResultIsEnableWinnerTime = LobbyUI:CheckLobbyMenuOpen(BP_ENUM_BATTLE_WINNER_TIME, false);
	for i,v in ipairs(BP_ARRAY_BattleResultForbidWinnerTimeSubMode) do
		if v == BP_STRUCT_BattleResultData.sub_mode then
			BP_BattleResultIsEnableWinnerTime = false;
			break;
		end
	end

	if Client.IsTypicalMode(GameFrontendHUD) then
		BP_BattleResultIsEnableWinnerTime = false; --经典模式不启用老的吃鸡时刻
	end
    
    -- 被踢玩家不显示结算界面，直接返回大厅
    if result.IsKickedFromGame then
    	log("result.IsKickedFromGame is true !!!!!!");
		local title = Client.GetTableData("LocalizeRes", "101001").TextValue;
		local content = Client.GetTableData("LocalizeRes", "6276").TextValue; -- "您已被房主踢出游戏！"
        CommonMessageBoxUI:ShowPanel(1, title, content, LobbySystem.ReturnToLobby, nil);
		return;
    end
    LuaClassObj.HandleUIMessage(bp_battleresult, "HideSpectatingUI");
    --BP_STRUCT_BattleResultData.delay_time = 50;
	if string.lower(LuaClassObj.GetGameStatus(bp_battleresult)) ~= "fighting" then
		log("result not fighting");
	else
		BP_STRUCT_BattleResultData.delay_time = BP_BattleResultCakePlacementDelayTime;
		local rank = BP_STRUCT_BattleResultData.team_rank;
		if BP_STRUCT_BattleResultData.Reason == "win" and rank == 1 and Client.IsTypicalMode(GameFrontendHUD) and BP_STRUCT_BattleResultData.delay_time > 0 and BP_ShouldDelayShowBattleResult then
		--if rank == 1 and BP_STRUCT_BattleResultData.delay_time > 0 then
			log("Show GameOverTips UI");
			BP_BattleResultIsEnableWinnerTime = false; -- 第一名吃鸡的不启用老的胜利时刻功能
			local isTerminator = false;
			log("BP_Terminator:"..BP_Terminator.." BP_myname:"..BP_myname);
			if BP_Terminator == BP_myname then
				isTerminator = true;
			end
			ResultCountDown_DynamicCreateUI(BP_STRUCT_BattleResultData.delay_time, isTerminator);
			LuaClassObj.HandleDynamicCreation(bp_battleresult);
			LuaClassObj.HandleUIMessage(bp_battleresult, "DelayShowBattleRankingUI");
		else
			log("ShowBattleRankingUI Directly");
			LuaClassObj.HandleDynamicCreation(bp_battleresult)
			LuaClassObj.HandleUIMessage(bp_battleresult, "ShowBattleRankingUI");		
			LuaClassObj.HandleUIMessage(bp_battleresult, "ShowBattleRankingUI_PVE");
		end
	end

    --LuaClassObj.HandleDynamicCreation(bp_battleresult)
	--LuaClassObj.HandleUIMessage(bp_battleresult, "ShowBattleRankingUI");
	
	if testResult == false then
		BattleResultUI.UpdateShareBtnState();
	end
	
	--在战斗外收到了结算消息
	if string.lower(LuaClassObj.GetGameStatus(bp_battleresult)) ~= "fighting" 
	--可观战不忽略断线错误
	or BP_EnterSpectateMode
	then
		BattleResult.IgnoreDSError = false;
	else
        BattleResult.IgnoreDSError = true;

        if testResult == false then
        	NetUtil.StopCheckDSActive();
        end
    end
    log("IgnoreDSError = " .. tostring(BattleResult.IgnoreDSError));

	--sami 更新pass任务
	BattleResultUI.OnGameEndTaskUpdate()
	--设置战斗mode
	if DataMgr ~= nil then
		DataMgr.sub_mode = BP_STRUCT_BattleResultData.sub_mode;
	end
end

function EventDoIgnoreDSError_Push()
	if BattleResult ~= nil then
		BattleResult.IgnoreDSError = true;
	end
    if testResult == false then
    	NetUtil.StopCheckDSActive();
    end
end

function BattleResultUI.ImageCallBack(list)
	--log_tree("ImageCallBack:", list);
	BP_ARRAY_TeammateProfile = {};
	for i=1, #list do
		table.insert(BP_ARRAY_TeammateProfile, {
			uid = list[i].uid,
			picUrl = list[i].picUrl, 
			level = list[i].level,
			cur_avatar_box_id = list[i].cur_avatar_box_id,
			});
	end

	-- 插入自己的头像信息
	table.insert(BP_ARRAY_TeammateProfile, {
			uid = DataMgr.roleData.uid,
			picUrl = DataMgr.roleData.headIconUrl, 
			level = DataMgr.roleData.level,
			cur_avatar_box_id = DataMgr.roleData.cur_avatar_box_id,
			});
    LuaClassObj.HandleDynamicCreation(bp_battleresult);
	LuaClassObj.HandleUIMessage(bp_battleresult, "ImageCallBack");
end

function BattleResultUI.ShowBattleResultUI()
	log("BattleResultUI.ShowBattleResultUI")
	--LuaClassObj.HandleUIMessage(bp_battleresult, "ShowBattleRankingUI")
	BattleResultUI.OnBattleResult(BattleResultUI.uid_back, BattleResultUI.result_back);
	BattleResultUI.UpdateShareBtnState();
end

function BattleResultUI.HideBattleResultUI()
	log("BattleResultUI.HideBattleResultUI")
	LuaClassObj.HandleUIMessage(bp_battleresult, "HideRankingUI")
end

function BattleResultUI.ShowLoadingUI()
	log("RecordingReplay ShowLoadingUI");
	LoadingUI:Init();
end

function BattleResultUI.HideLoadingUI()
	log("RecordingReplay HideLoadingUI");
	LoadingUI.RefreshLoadPercent(1);
end

function BattleResultUI.ShowTrainingOverUI()
	log("ShowTrainingOver");
    LuaClassObj.HandleDynamicCreation(bp_battleresult);
	LuaClassObj.HandleUIMessage(bp_battleresult, "ShowTrainingOver")
end

function BattleResultUI.SetIsReportComplaintShow(IsShow)
	BP_IsReportComplaintShow = IsShow
end

function BattleResultUI.SetIsDirectShow(IsShow)
	BP_DirectShow = IsShow;
	if IsShow then
		log("SetIsDirectShow true")
	end
end

function bp_battleresult_OnModeSwitched(gamestatus)
	log("bp_battleresult_OnModeSwitched gamestatus = " .. gamestatus)
    BP_LoginChannel = Client.GetLoginChannel(NetInterface);
    --BP_IsDroiyanMode = BattleResultUI.IsDroiyanMode();
    BattleResult.ShowingExitWatchGame = false;
    BP_ShouldDelayShowBattleResult = true;
    BP_IsReceiveResult = false;
    if string.lower(gamestatus) == "fighting" then
        BattleResult.IgnoreDSError = false;
        BattleResult.BP_IsShowResultPanel = false;
       	log("BattleResultUI Set false!!!!!")
        --LuaClassObj.HandleUIMessage(bp_battleresult, "ShowSpectatingUI");
        ------------------------------
        if false then
        	g_game_id = 693163251483017251;
			local result = 
			{
				rival = "K9mdog",
				terminator = "",
				Reason = "win",
				RemainingPlayerCount=15,
				TotalPlayerCount=40,
				RemainingTeamCount=5,
				TotalTeamCount=25,
				person_rank=31,
				team_rank=1,
				add_exp=110,
				add_gold=450,
				add_vaccinum=123,
				IsSolo=false,
				add_carteam_coin=389, --赛事币
				rank_score=100, --赛事排名积分
				kill_score=200, --赛事击杀积分
				league_seq=0, --赛事编号
				tournament_id=0,
				is_last_survive=false,
				is_team_result=true,
				is_version_match=true,
				battle_type = 101,
				get_gold_today = 1234,
				max_game_num = 4,
				battle_owner = 0,
				sub_mode = 1070,
				delay_time = 60,
				battle_id = 693163251483017251,
				final_level="SSS",
				is_anchor_ob = false,
				radar =
				{
					SurviveScore_f="0.5";
					HurtScore_f="0.6";
					SupportScore_f="0.5";
					SupplyScore_f="0.8";
					KillScore_f="0.3";

					SurviveScore=50;
					HurtScore=60;
					SupportScore=50;
					SupplyScore=80;
					KillScore=30;
				},

				ranklist = {"haha22233", "12345678901234", "haha222", "七个中文七个字"},
	    		TeammateList = 
				{
					{    
			   			Name = "七个中文七个字",
			   			Kill = 1,
						State = "",
						travelDistance = 121,
	   					DamageAmount = 18.44,
	    				HealAmount = 3,
	    				surviveTime=1900,
	    				HeadShotRatio=0.4,
	    				AssistNum=1,
						HeadShotNum=1,
						rescueTimes=1,
	    				ShouldShowAddFriendBtn = 2,
	    				SurviveScore = 20,
	    				BattleScore = 0,
						SupportScore = 0,
						TravelScore = 0,
						FinalScore_f = 20.133,
						IsMVP = false,
						title_id = 1,
						rela_sex = 2,
						wear_ext = 
						{
							[9] = {401999,0,0},
							[10] = {40601001,0,0},
							[11] = {703001,0,0},
							[13] = {101004,0,0},
							[14] = {101004001,0,0},
						},
						gamegender = 1,
						title_id_list = 
						{
							22, 8, 9, 10, 11, 12, 13, 14, 15
						},
						UID = "410000206",  --  玩家ID
						pve_total_score = 118,
					},
					{    
			   			Name = "12345678901234",
			   			Kill = 3,
						State = "",
						travelDistance = 4200,
	   					DamageAmount = 500,
	    				HealAmount = 60,
	    				surviveTime=300,
	    				AssistNum=2,
						HeadShotNum=1,
						rescueTimes=1,
						HeadShotRatio=0.34,
	    				ShouldShowAddFriendBtn = 1,
	    				SurviveScore = 22.41,
	    				BattleScore = 100,
						SupportScore = 28,
						TravelScore = 78.18,
						FinalScore_f = 95.122,
						IsMVP = true,
						title_id = 1,
						rela_sex = 3,
						wear_ext = 
						{
							[9] = {401993,0,0},
							[10] = {40601001,0,0},
							[11] = {703001,0,0},
							[3] = {403014,0,0},
							[13] = {101004,0,0},
							[14] = {101004001,0,0},
							
						},
						gamegender = 0,
						UID = "210000876",  --  玩家ID
						pve_total_score = 119,
					},
					{    
			   			Name = "haha222",
			   			Kill = 1,
						State = "",
						travelDistance = 121,
	   					DamageAmount = 18.44,
	    				HealAmount = 3,
	    				surviveTime=1900,
	    				HeadShotRatio=0.4,
	    				AssistNum=1,
						HeadShotNum=1,
						rescueTimes=1,
	    				ShouldShowAddFriendBtn = 2,
	    				SurviveScore = 20,
	    				BattleScore = 0,
						SupportScore = 0,
						TravelScore = 0,
						FinalScore_f = 10.133,
						IsMVP = false,
						title_id = 1,
						rela_sex = 2,
						wear_ext = 
						{
							[9] = {401993,0,0},
							[10] = {40601001,0,0},
							[11] = {703001,0,0},
							[5] = {405012,0,0},
							[13] = {103003,0,0},
						},
						title_id_list = 
						{
							12, 13, 14, 15
						},
						gamegender = 0,
						UID = "210000371",  --  玩家ID
						pve_total_score = 120,
					},
					{    
			   			Name = "haha22233",
			   			Kill = 1,
						State = "",
						travelDistance = 121,
	   					DamageAmount = 18.44,
	    				HealAmount = 3,
	    				surviveTime=1900,
	    				HeadShotRatio=0.4,
	    				AssistNum=1,
						HeadShotNum=1,
						rescueTimes=1,
	    				ShouldShowAddFriendBtn = 2,
	    				SurviveScore = 20,
	    				BattleScore = 0,
						SupportScore = 0,
						TravelScore = 0,
						FinalScore_f = 5.133,
						IsMVP = false,
						title_id = 1,
						rela_sex = 2,
						wear_ext = 
						{
							[9] = {401994,0,0},
							[10] = {40601006,0,0},
							[11] = {703001,0,0},
							[13] = {102002,0,0},

						},
						title_id_list = 
						{
							22, 8, 9, 10, 11, 12, 13, 14, 15
						},
						gamegender = 1,
						UID = "210000371",  --  玩家ID
						pve_total_score = 113,
					}
		   		},
		   		rating =
		   		{
		   			rank_rating=1100,  --变化后总积分
	    			kill_rating=1200,  --变化后击杀积分
	    			win_rating=1300,   --变化后胜利积分
				    change_rank_rating=-100,  --当局总积分变化值
				    change_kill_rating=-300,  --当局击杀积分变化值
				    change_win_rating=-300,   --当局胜利积分变化值
		   		},
		   		gold_detail=
		   		{
		   			up_limit=5000;
		   			rank_gold=111;
	    			kill_gold=222;
	    			hurt_gold=333;
	    			team_add=44;

	    			famous_master_add=55;
	    			sm_add=66;
	    			gold_card_add=77;
	    			limitact_double_gold_rate=0.88;
		   		},
		   		exp_detail =
				{
				    survive_exp=11;
				    kill_exp=22;
				    first_exp=33;
				    top10_exp=44;
				    watch_exp=666;
				    team_add=55;
				    plat_add=66;
				    qq_super_vip_add=77;
				    exp_card_add=88;
				    famous_master_add=99;
				    sm_add=100;
				    clan_add=88;
				    limitact_double_exp_rate=0.22;
		   		}
		   	}
--[[
		   	DataMgr=
		   	{
		   		roleData=
		   		{
		   			uid="410000206";
		   			headIconUrl="";
		   			gender=2;
		   			nickName="七个中文七个字";
		   			cur_avatar_box_id=0;
		   		},
		    }
]]--
		    testResult = true;
	   		BattleResultUI.OnBattleResult(0, result);
		end
    end
end

function EventBattleResult_BackToLobby()
	log("EventBattleResult_BackToLobby");
    BattleResult.IgnoreDSError = true;
    if CommonMessageBoxUI ~= nil then
    	CommonMessageBoxUI:HidePanel();
    end
	LobbySystem.ReturnToLobby()
end

--结算倒计时开关打开
function BattleResultUI.EnableTickSwitch()
	--分享界面关闭的时候刷新一下分享tips
	BattleResultUI.UpdateShareBtnState();
    LuaClassObj.HandleDynamicCreation(bp_battleresult);
	LuaClassObj.HandleUIMessage(bp_battleresult, "EnableResultsTick");
end

--显示观战界面
function BattleResultUI.EnterSpectating()
    LuaClassObj.HandleDynamicCreation(bp_battleresult);
    LuaClassObj.HandleUIMessage(bp_battleresult, "ShowSpectatingUI");
end
--warmode显示观战界面
function BattleResultUI.WarmodeEnterSpectating()
    LuaClassObj.HandleDynamicCreation(bp_battleresult);
    LuaClassObj.HandleUIMessage(bp_battleresult, "OnEnterSpectatingInWarMode");
end

function BattleResultUI.IsDroiyanMode()
	local mode_normal = 1;	--标准匹配模式
	local mode_droiyan = 2;	--天命圈模式
	log("vvvvvvvvvvvvvvv"..tostring(BP_STRUCT_BattleResultData.battle_type));
	local cMode = math.floor(BP_STRUCT_BattleResultData.battle_type / 100);
	local flag = false;
	log("vvvvvvvvvvvvvvv"..tostring(cMode));
	if cMode == mode_droiyan then
		flag = true;
	end
	return flag;
end

Retry = false;
function EventDelayCall()
	Retry = true;
	bp_battleresult_OnModeSwitched("fighting");
end

function EventClientExitGame()
    log("EventClientExitGame")
    BattleResult.IgnoreDSError=true;
    NetUtil.StopCheckDSActive();
    NetUtil.SendPkg("giveup_enter_game");
    NetUtil.SendPkg("exit_result");
end

function EventClientFreshToComplaint()
	ComplaintUI:CacheEnemyInfo(BP_BattleResultMurderName, BP_BattleResultIsAI, BP_myname)
end

-- 不能删除，用于刷新数据
function EventClientFreshData()
end

function EventClientGetIsClickReply()
	BP_BattleResultIsClickReplay = ComplaintUI:IsClickReply()
end

function EventClientExitTraining()
    log("EventClientExitTraining")
    BattleResult.IgnoreDSError=true;
    NetUtil.StopCheckDSActive();
    NetUtil.SendPkg("giveup_enter_game");
end

function EventCloseBattleResult()
	log("EventCloseBattleResult");
	NetUtil.SendPkg("exit_result");
end

function EventShowGameJoyRecordFailNotice()
	ShowNotice(890006);
end

function EventShowGameJoyNoRecordsNotice()
	ShowNotice(890012);
end

function EventEnterAnchorObserve()
	BattleResult.enter_room_battle_watch()
end

--精彩视频分享成功
function EventGameJoyVideoShareSuccess()
	if not BP_STRUCT_RecordDataTLogUpload then
		BP_STRUCT_RecordDataTLogUpload = {};
	end
	log("BP_STRUCT_RecordDataTLogUpload share_channel.. " .. BP_STRUCT_RecordDataTLogUpload.share_channel or "");
	log("BP_STRUCT_RecordDataTLogUpload device_type.. " .. BP_STRUCT_RecordDataTLogUpload.device_type or "");
	NetUtil.SendPkg("report_video", BP_STRUCT_RecordDataTLogUpload);
end

function GetTeamModeName()
	local localStringID1 = Client.GetTableData("MatchModeTable", tostring(BP_STRUCT_BattleResultData.battle_type)).WordsToShowID;
	local msg1 = Client.GetTableData("LocalizeRes", localStringID1).TextValue;

	local localStringID2 = Client.GetTableData("BTMode", tostring(BP_STRUCT_BattleResultData.sub_mode)).ModeName;
	local msg2 = Client.GetTableData("LocalizeRes", localStringID2).TextValue;
	return msg1 .." ".. msg2;
end

function BattleResultUI.GetStrategyBtnStatus()
	BP_BattleResultCanShowStrategyBtn = true;
	if LobbySystem.LobbyMenuOpenStatus ~= nil and LobbySystem.LobbyMenuOpenStatus[BP_ENUM_BATTLERESULT_STRATEGYBTN] ~= nil then
		if LobbySystem.LobbyMenuOpenStatus[BP_ENUM_BATTLERESULT_STRATEGYBTN].is_open == 0 then
	   		BP_BattleResultCanShowStrategyBtn = false;
	   	end
   	end
end

function BattleResultUI.ShowOBBattleResult(ob_battle_result)
	log("ShowOBBattleResult");
	--忽略DS网络错误
	BattleResult.IgnoreDSError = true;
	if ob_battle_result ~= nil then
		--log_tree("ob_battle_result", ob_battle_result)		
		BP_ARRAY_OBBattleResult = {}
	
		--将所有队伍结算信息放到一个数组
		for k_team_serial_num,v_team_result in pairs(ob_battle_result) do
			--将一个队伍的个人结算信息放到一个数组
			local OBTeamResult = {}
			local OBTeamMemberResultArray = {}
			for k_personal_serial_num,v_personal_result in pairs(v_team_result) do
				local personal_result_data = {}
				personal_result_data.uid = v_personal_result.uid
				personal_result_data.rank = v_personal_result.rank
				personal_result_data.name = v_personal_result.name
				personal_result_data.kill = v_personal_result.kill
				personal_result_data.gender = v_personal_result.rela_sex
				table.insert(OBTeamMemberResultArray, personal_result_data) 
			end
			OBTeamResult.BP_ARRAY_OBPersonalResult = OBTeamMemberResultArray
			log_tree("ob_game_team_struct", OBTeamResult)
			table.insert(BP_ARRAY_OBBattleResult, OBTeamResult)
		end
	
	
		--log_tree("ob_game_result_struct", BP_ARRAY_OBBattleResult)
		--将数组排一下序并传给蓝图显示
		table.sort(BP_ARRAY_OBBattleResult, function(a, b)
			return a.BP_ARRAY_OBPersonalResult[1].rank < b.BP_ARRAY_OBPersonalResult[1].rank
		end)
		InGameUIManager.HandleUIMessage(observe, "Hide");
		InGameUIManager.HandleUIMessage(observe,"ShowOBBattleResult")
	end
end
--观战结束了
function BattleResultUI.OnExitWatchGame()
	--忽略DS网络错误
	BattleResult.IgnoreDSError = true;
    BattleResult.ShowingExitWatchGame = true;
	--显示好友观战结束的UI
    if string.lower(LuaClassObj.GetGameStatus(bp_battleresult)) == "fighting" then
        LuaClassObj.HandleDynamicCreation(bp_battleresult);
        LuaClassObj.HandleUIMessage(bp_battleresult, "OnWatchFriendBattleEnd");
    end
end

--来自ds，而不是大厅通知
function BattleResultUI.ExitWatchGame()
	if not BattleResult.ShowingExitWatchGame then
		BP_WatchExitReason = "game_over";
		BattleResultUI.OnExitWatchGame();
        LogicLobbyWatching.leave_battle_watch();
	end
end

function EventWatchGameOnSelect()
	log("WatchGameOnSelectTeammate BP_WatchGame_TargetName = " .. tostring(BP_WatchGame_TargetName));
	--log_tree("BP_ARRAY_All_Friend_Profile", BP_ARRAY_All_Friend_Profile);
	BattleResultUI.UpdateReservationState();
end
function BattleResultUI.UpdateReservationState()
	local friendData = FriendSystem.GetFriendDataByGameName(BP_WatchGame_TargetName);
	BP_WatchGame_CanReservation = friendData ~= nil and friendData.intimacy ~= nil and friendData.intimacy >= TeamUPFriendUI.minIntimacyToShowReserveBtn;

	BP_WatchGame_AcceptReservation = friendData ~= nil and friendData.uid ~= nil and LobbyChatSystem.IsReserved(friendData.uid);
	log("BP_WatchGame_CanReservation = ".. tostring(BP_WatchGame_CanReservation) .. ", BP_WatchGame_AcceptReservation = " .. tostring(BP_WatchGame_AcceptReservation));

	if (BP_WatchGame_CanReservation == true and friendData ~= nil and friendData.uid ~= nil) then
		local reservingData = LobbyChatSystem.friendReservingList[friendData.uid];
		if nil ~= reservingData then					
			log("watch game has reservation operation before");
			BP_WatchGame_CanReservation = false;
		else		
			log("watch game no reservation operation before");
			BP_WatchGame_CanReservation = true;
		end
	end
    LuaClassObj.HandleDynamicCreation(bp_battleresult);
	LuaClassObj.HandleUIMessage(bp_battleresult, "UpdateReservationState");
end

function EventResultUIGiveUpObserver()
	RoomSystem.leave_room_battle_watch();
end

--点击预约
function EventWatchGameClickReserveFriend()
	log("WatchGameOnSelectTeammate BP_WatchGame_TargetName = " .. tostring(BP_WatchGame_TargetName));
	local friendData = FriendSystem.GetFriendDataByGameName(BP_WatchGame_TargetName);
	--log_tree("friendData", friendData);
	if (friendData ~= nil and friendData.uid ~= nil) then
		PopUpNoticeUI.ShowNewNotice(string.format(DataMgr.GetMsgByID(110123), tostring(BP_WatchGame_TargetName)));
		LobbyChatSystem.on_reserve_friend_req(friendData.uid);
		BattleResultUI.UpdateReservationState();
    	ClientSendBAReport(BP_BA_LOBBY_RESERVATION, 6); --6=观战好友时的“预约”
	else
		log("watch game reservation friend data is nil");
	end
end

function EventWatchGameUpdateReservationState()
	log("EventWatchGameUpdateReserverState");
	BattleResultUI.UpdateReservationState();
end

function BattleResultUI.ShowAdvertiseButton()
	log("BattleResultUI.ShowAdvertiseButton");
	LuaClassObj.HandleUIMessage(bp_battleresult, "ShowAdvertiseButton");
end

function EventOnClickAdvertiseButton()
	AdvertiseSystem.UpdatePlayAdvertiseEvent();
end

function EventBattleResultGenerateMyHeadInfo()
    if DataMgr ~= nil and DataMgr.roleData ~= nil then
	    BP_STRUCT_BattleResultMyInfo.roleUid = DataMgr.roleData.uid;
		BP_STRUCT_BattleResultMyInfo.headIconUrl = DataMgr.roleData.headIconUrl;
		BP_STRUCT_BattleResultMyInfo.gender = DataMgr.roleData.gender;
		BP_STRUCT_BattleResultMyInfo.nickName = DataMgr.roleData.nickName;	
		BP_STRUCT_BattleResultMyInfo.cur_avatar_box_id = DataMgr.roleData.cur_avatar_box_id;
		BP_myname = DataMgr.roleData.nickName;
	end
end

function BattleResultUI.ShowReplyState(state, tip)
	log("BattleResultUI.ShowReplyState");
	BP_WatchGame_ReplyState = state; -- 0 拒绝 1 同意
	BP_WatchGame_ReplyTip = tip; --玩家名字七个字拒绝了你的预约
    LuaClassObj.HandleDynamicCreation(bp_battleresult);
	LuaClassObj.HandleUIMessage(bp_battleresult, "ShowReservationReplyState");
	BattleResultUI.UpdateReservationState();
end

function BattleResultUI.OnGameOver( game_id )
	log("BattleResultUI.OnGameOver");
	local isWin = false;
	if BP_STRUCT_BattleResultData and BP_STRUCT_BattleResultData.Reason == "win" then
		isWin = true;
	end
	log("isWin:"..tostring(isWin).."  team_rank:"..tostring(BP_STRUCT_BattleResultData.team_rank).."  BP_IsReceiveResult:"..tostring(BP_IsReceiveResult))
	if BP_IsReceiveResult and not isWin and BP_STRUCT_BattleResultData.team_rank ~= 2 then
		LuaClassObj.HandleUIMessage(bp_battleresult, "ShowGameOverResult");
		LuaClassObj.HandleUIMessage(bp_battleresult, "HideSpectatingUI");
	else
		log("No Result Received while GameOver")
	end
end

function BattleResultUI.EnterViewEnemy()
    BattleResult.IgnoreDSError = false;
end


-- 更新结算pass任务信息
function BattleResultUI.OnGameEndTaskUpdate()
	log("BattleResultUI.OnGameEndTaskUpdate")
	BP_STRUCT_BattleResult_Pass_Mission_Info = UnknowPassSystem.GetGameEndShowPassTaskInfo()
	LuaClassObj.HandleUIMessage(bp_battleresult, "UpdatePassTaskInfo");
end

function EventReturnFromLeagueBattle()
	IsRoomToBattle = false
end
