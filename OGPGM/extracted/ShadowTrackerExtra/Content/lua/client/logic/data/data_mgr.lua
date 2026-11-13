-- 通用数据

struct_RoleAttri =
{
	attr_type_exp = 1,			-- 经验
	attr_type_level = 2,		-- 等级
	attr_type_gold = 3,			-- 金币
	attr_type_diamond = 4,		-- 钻石
	attr_type_signature = 5,	-- 签名
	attr_type_segment = 6,		-- 段位
	attr_type_ticket = 7 ,		-- 点券
	attr_type_gen_ticket = 8,	-- 无偿点券
	attr_type_corpsmoney = 98,	-- 军团币
	attr_type_nation = 30,		-- 段位
	attr_type_credit = 9,       -- 信誉分
	attr_type_season_id = 13,     -- 赛季
	attr_type_fp_token = 100,   -- 炸猪令牌
	attr_type_gold_chip = 101,	-- 金碎片
	attr_type_pve_exp = 31,     -- pve 经验
	attr_type_pve_level = 32,   -- pve 等级
}

struct_SegmentType =
{
	segment_type_solo = "solo",
	segment_type_double = "duo",
	segment_type_team = "squad",
	segment_type_fppsolo = "fppsolo",
	segment_type_fppdouble = "fppduo",
	segment_type_fppteam = "fppsquad",
}

enum_SegmentType =
{
	solo = 1,
	double = 2,
	team = 3,
	fpp_solo = 4,
	fpp_double = 5,
	fpp_team = 6,
}

indexCacheTable = {}
tableForResIdSearch = {}
--------------------------------------------------------------------
-- 所有的数据赋值必须通过mgr的set方法赋值，保障数据变更入口唯一
--------------------------------------------------------------------
DataMgr = DataMgr or
{
	-------------------------------------- 以下是人物基本属性 --------------------------------------
	roleData = 
	{
		openID = 0,
		uid = "",
		level = 0,
		nation = "",
		roleExp = 0,
		nickName = "",
		gender = 0,		-- 平台性别
		headIconUrl = "",
		signature = "",	-- 个人签名
		segment = {},	-- 段位  solo-单人  double-双人  team-组队
		qq_vip = 0, --qq会员 0 无会员 1 普通会员 2 超级会员
        cur_avatar_box_id = 0,  --头像框
        allzoneSegment = {}, -- 二维数组：allzoneSegment[zone_id][type]： 第一维是分区zoneId，第二维存放当前区的segment（solo-单人  double-双人  team-组队）
        eugdpr = {}, -- GDPR 结构体
		history_max_segment_level = 0, --历史最高段位
        credit = 0,
        enableWatch = 1,        -- 是否允许观战
        watch_privacy = 1,      --战斗内观战是否可以查看个人信息
        upvote = 0,				-- 点赞数
		rankData = {},	-- 个人排行榜详情数据
		upass = {}, --个人绝地令牌数据
		alias = {}, --称号数据
		corps_alias_data = {},
		carteamId = 0,
	},
		
	gold = 0,

	ticket = 0, 	--点券

	fp_token = 0,	--炸猪令牌

	gen_ticket = 0, -- 无偿点券

	gold_chip = 0,	--金碎片
	
	anchor = 0,		--主播(1为主播，其他为非主播)
	
	modify_name_time = 0, --改名时间
	
	last_modify_nation_time = 0,  -- 修改旗帜时间
	last_modify_nation_item_time = 0,  -- 使用旗帜卡修改旗帜时间

	registertime = 0, --注册时间

	-------------------------------------- 以下是人物当前穿戴数据 --------------------------------------
	avatarData=
	{
		headid = 0,
        hairid = 0,
		beardid = 0,
		beardcolorid = 0,
		gamegender = 0,		-- 游戏内角色性别
		avatar_list = {},	--avatar列表，每一项为avatar_id:expire_time
		activate_avatar_list = {},--激活的avatar列表，用来显示用
	},
	
	rolewear = {}, --insID数组
	rolewear_array = {}, -- 多套时装的数组
	rolewear_state = {}, -- 时装仓库的状态
	use_rolewear = 1,  -- 当前使用的时装仓库

	defaultParachuteResID = 0, -- 默认降落伞配置ID
	defaultParachuteInsID = "",
	parachute = "", -- instID,降落伞

	defaultPlaneSkinResID = 1801101, -- 默认飞机配置ID
	defaultPlaneSkinInsID = "",
	planeSkinInsID = "", -- instID,飞机
	head_show = 0, -- 用于大厅显示的头部物品ID（帽子或者头盔）

	-- 背包/头盔/载具皮肤
	-- by purple 这里的实例ID是字符串，用的时候注意判断需不需要转成number！
	equipmentSkinInsIDTable = 
	{
		[504] = "",
		[505] = "",
		[506] = "",
	};

	BagSkinTableIndex = 504,
	HelmetSkinTableIndex = 505,

	-- 载具的默认配置(考虑限时皮肤到期时处理)
	defaultVehicleSkinResIDTable = 
	{
		[901] = 1901001,
		[902] = 1902001,
		[903] = 1903001,
		[904] = 1904001,
		[905] = 1905001,
		[906] = 1906001,
		[907] = 1907001,
		[908] = 1908001,
		[909] = 1909001,
		[910] = 1910001,
		[911] = 1911001,
		[912] = 1912001,
		[913] = 1913001,
		[914] = 1914001,
		[915] = 1915001,
		[916] = 1916001,
		[917] = 1917001,
		[918] = 1918001,
	};
	defaultVehicleSkinInsIDTable = 
	{
		[1901001] = "",
		[1902001] = "",
		[1903001] = "",
		[1904001] = "",
		[1905001] = "",
		[1906001] = "",
		[1907001] = "",
		[1908001] = "",
		[1909001] = "",
		[1910001] = "",
		[1911001] = "",
		[1912001] = "",
		[1913001] = "",
		[1914001] = "",
		[1915001] = "",
		[1916001] = "",
		[1917001] = "",
		[1918001] = "",
	};
	vehicleSkinInsIDTable = {},
	
	-------------------------------------- 以下是大厅仓库数据 --------------------------------------
	arrayHallDepotItemInfo = 
	{		
		item = 
		{
			insID = "",
			resID = 0,
			count = 0,		
			isNew = false,
			
			itemType = 0,
			itemSubType = 0,
			validHours = 0,
			expireTS = 0,
			mainTabType = 0,
			itemQuality = 0,
			
			colorID = 0,
			patternID = 0,
		},
	},
	
	mapSourceBookInfo = {},	-- 图鉴数据，结构参考arrayHallDepotItemInfo
	isMapSourceInit = false,
	-------------------------------------- 以下是登录领奖相关数据 --------------------------------------
	SignInInfo =
	{
		login_reward = {},				--登录领奖状态
		last_login_reward_remind = 0, 	--上次登录时间戳（用于首次登录领奖打脸）
	},
	
    -------------------------------------- 以下是新手数据 --------------------------------------
	fresher_type = 0,
    
	-------------------------------------- 以下是好友数据 --------------------------------------
	-------------------------------------- 以下是任务数据 --------------------------------------
	taskData = {
		daily_update_time = 0,
		list = {}	
	},

	weekTaskData = {
		week_update_time = 0,
		week_list = {},
	},
	-------------------------------------- 以下是活跃数据 --------------------------------------
	activeness = {
		daily_update_time = 0,
		value = 0,
		list = {},
		week_update_time = 0,   --服务器用来每周清除的标记
		week_value = 0, --周活跃
		week_list = {},
		["WeekActIndexMark"] = 100 --TaskActive表格中，周活跃ID从101开始，100以下为日活跃
	},

	-------------------------------------- 以下是成长任务数据 --------------------------------------
	levelTask = {
		list = {}
	},
	-------------------------------------- 以下是BAN数据 --------------------------------------
    ban = 
    {
    },
    	-------------------------------------- 以下是周签到数据 --------------------------------------
	WeekSignUpInfo =
	{
		Resign_times = 0,
		AwardState = {}
	},

	-------------------------------------- 以下是活动数据 --------------------------------------
	activity = {
		isInit = false,
		hashList = {},
		activityMap = {},
		activityListMap = {},
		activityIdMap = {}, -- [子活动]<->[父活动]
		data = {}
	},
	bulletin = {
		hashList = {},
		data = {}
	},
	
	--------------------------------------- 以下是分享领奖数据 -------------------------------------------
	ShareAwardInfo = {
		daily_share_time = 0,
		share_times  = 0,
		AwardState = {}
	},

		--------------------------------------- 活动集合页数据 -------------------------------------------
	activityGroupList = 
	{
	},
	--------------------------------------- 限时直购数据 -------------------------------------------
	shopLimit = 
	{
		hash = "",
		buyInfo = {},
		template = {}
	},
    
    -------------------------------------- 以下是选服数据--------------------------------------
    AllZoneList = {},
    --------------------------------------金币和经验加成----------------------------------------------
	doubleCard =
	{
		expCardRatePlus = 0,
		expCardExpireTime = 0,
		goldCardRatePlus = 0,
		goldCardExpireTime = 0,
	},

    ------------------------------------战区相关数据-------------------------------------------------
	lbs_warzone_info =
	{
		warzone_id = -1,--unkown
		warzone_id_update_time = 0,
		use_title = {}, --{rank_id=,rank_type=,rank_no=}
		title_map = {}, --{key:rank_id, value:{rank_id=,rank_type=,rank_no=}}
		title_update_time_map = {},--key:rank_type, value:{key:rank_id, value:times}
		rank_times_map = {},
	},

    	---------------------------------------房卡相关------------------------------------------------------
 	room_card_info =
	{
		expire_ts=0,
		rest_times=0,
	},
	room_card_info_adv =
	{
		expire_ts=0,
		rest_times=0,
	},
	room_card_info_mat =
	{
		expire_ts=0,
		rest_times=0,
	},
	
	---------------------------------------军团成员列表-----------------------------------------------
	corpsInfo =
	{
		isInit = false,
		commanderId = 0,
		secCommanderList = {},
		eliteList = {},
		memberList = {},
		selfMember = {},
		id = 0,
		exp = 0,					--军团经验
		level = 0,					--军团等级
		weekRank = 1, 				--军团本周活跃排行
		announcement = "",			--军团宣言
		name = "",  				--军团名字
		icon = 0,  					--军团图标ID
		icon_text = "",             --军团标志签名
		icon_text_colour = 0,       --军团标志签名颜色
		city = "",  					--军团所在城市
		memberNum = 0,				--军团成员数量
		leader = 0,					--军团团长

		day_active = 0,				--军团日活跃
		week_active = 0,			--军团周活跃
		season_active = 0,			--军团赛季活跃
		chest_star = 0,				--军团宝箱星级
        fund = 0,                   --军团资金

		-- 管理
		isAcceptApply = true,			-- 是否接受申请
		isNeedApproval = true,			-- 是否需要审批
		joinLevel = 0,					-- 申请最低等级 无限制填0
		joinSegment = 0,				-- 申请最低段位 无限制填0 对应段位表

		-- 成员
		corpsMemberList = {
			-- position: 1			--军团职级
			-- svr: 3876782116		--玩家id
			-- online_state: 1		--是否在线
			-- name: "test882"		--成员名字
			-- day_active: 1    	--当日活跃点
			-- week_active: 1   	--当前活跃点
			-- BP_STRUCT_BASE_INFO:			-- 头像等信息
				-- ├─ Level: 5
				-- ├─ Name: "xkx"
				-- ├─ Sex: 1
				-- ├─ RankIntegralLevel: 303
				-- ├─ IconUrl: ""
				-- ├─ strUid: "410000182"
				-- └─ IconFrameID: 2001001
		},	},

	--军团任务
	corpsTaskData = 
	{
		list = {}	
	},

	--军团活跃
	corpsActiveness = 
	{
		value = 0, --活跃度
		star = 0,--活跃星级
		list = {},
	},
	
    --这里存放的是单人 双人 四人在所有区中最高段位的数据
    --第三人称
    maxSegmentSolo=
    {
        zoneid = 0,
        SegmentLevel = 0,
    },
    maxSegmentDuo = 
    {
        zoneid = 0,
        SegmentLevel = 0,
    },
    maxSegmentSquad = 
    {
        zoneid = 0,
        SegmentLevel = 0,
    },
    --这里存放的是单人 双人 四人在所有区中最高段位的数据
    --第一人称
    maxSegmentSoloFpp=
    {
        zoneid = 0,
        SegmentLevel = 0,
    },
    maxSegmentDuoFpp = 
    {
        zoneid = 0,
        SegmentLevel = 0,
    },
    maxSegmentSquadFpp = 
    {
        zoneid = 0,
        SegmentLevel = 0,
    },

	IsEightDaySlpaed = false,
	IsGmOpen = false,
    CurUpdateZoneSegementZoneId = 0,

    jp_age = nil,
    
    -- 表情槽
	MotionSlotMax = 0,
	MotionSlotList =
	{
	},

	--------------------------------------回流玩家数据--------------------------------------	
	RejoinTaskData =
	{
		is_open = false,
		rejoin_start_time = 0,
		last_login_time = 0,
		total_login_day = 1,
		-- task_special = {[taskid1] = {progress=1, status=0}},
		task_special = {},
		task_regular = {},
		taskActiveness = 
		{
			value = 0, --活跃度
			list = {},
		},
		activeness = 0,
		last_refresh_time = 0,
		rejoin_num = 0,
		chest_award_list = {},
	},

	--保存个人战绩选择信息
	Last_ZoneId = 0,
	Last_Combat_ShootType = 0,
	Last_CombatModelType = 0,

	team_up_has_weak_guide = false;	-- 引导首战
	-- 新手引导
	--[[
	newbieGuide
	├─ 1
	│  ├─ 100030: 1
	│  └─ 100025: 25
	└─ 2
	   ├─ 200030: 1
	   └─ 200010: 11
	--]]
	newbieGuide = {},

	-- 新手引导宏定义
	NEWBIE_GUIDE_MODULE_ID_WARZONE = 1, -- 战区
	NEWBIE_GUIDE_MODULE_ID_CHAT = 2, -- 聊天
	NEWBIE_GUIDE_MODULE_ID_WARDROBE = 3, -- 仓库
	NEWBIE_GUIDE_MODULE_ID_TITLE = 4, -- 称号
	NEWBIE_GUIDE_MODULE_ID_PASS = 5, -- PASS
	NEWBIE_GUIDE_MODULE_WEEK_SIGN = 6, -- 周签到

	NEWBIE_GUIDE_MODULE_ID_LEAGUE = 7,  	-- 线上赛引导
	NEWBIE_GUIDE_MODULE_ID_SHAOJI = 8, 		-- 烧鸡活动
	NEWBIE_GUIDE_MODULE_ID_MATCH_LANG = 9,	-- 匹配第一,第二语言的新手引导	
	NEWBIE_GUIDE_MODULE_ID_BIGHAND = 10, 	-- 大手版

	NEWBIE_GUIDE_MODULE_ID_BLACK_FRIDAY = 21, 		-- 黑色星期五商业活动
	NEWBIE_GUIDE_MODULE_ID_ITEM_UPGRADE = 22,		-- 装备外显升级
	NEWBIE_GUIDE_MODULE_ID_NEW_STORE = 23,	-- 新版商城
	NEWBIE_GUIDE_MODULE_ID_ACTIVITY_SHOP = 24,	-- 新版商城活动补给页签
	NEWBIE_GUIDE_MODULE_ID_RESIDENT_EVIL = 25, 		--生化危机活动
	NEWBIE_GUIDE_MODULE_ID_LUCKYUNBACK = 26, 		--生化夺宝商业活动
	NEWBIE_GUIDE_MODULE_ID_INDIA_CHAMPIONSHIP = 28, --印度锦标赛
	NEWBIE_GUIDE_MODULE_ID_DISCOUNT_FEVER = 29,     --特惠派对系列商业活动
	NEWBIE_GUIDE_MODULE_ID_INTIMACY_RELATION = 30, ----亲密关系相关新手引导

	FirstSecondLanguage = {0,0},	-- 第一第二语言

	-- 战队商店 
	carteam_coin_count = 0, -- 战队币

	-- 战斗子模式
	sub_mode = 0,
	
	--仓库物品表缓存
	WardrobeItemList = {},

	--聊天第一第二语言
	FirstSecondLanguage = {},
	-- 匹配语言、配置数据
	MatchLanguage = {},
	
	season_id = 1,                  --赛季ID

	-- 异形屏参数
	uiRectOffset = "",
}

-- 重置数据，用于重登陆
function DataMgr.ResetData()
	log("IDataMgr.ResetData!!!!");
		-- 重置活动集合页数据
	DataMgr.ResetActGrpData()
	-- 重置任务
	DataMgr.ResetTaskData()

	-- 重置成长任务
	DataMgr.ResetLevelTaskData()

	-- 重置活跃
	DataMgr.ResetActivenessData()
	-- 重置活动
	DataMgr.ResetActivityData()
	-- 重置公告数据
	DataMgr.ResetBulletin()
	-- 重置限时直购数据
	DataMgr.ResetShopLimit()
	-- 重置军团数据
	CorpsMgr.ResetData();
	-- 重置军团数据
	DataMgr.ResetCorpsTaskData();
	-- 重置军团任务数据
	DataMgr.ResetCorpsActivenessData();
	-- 重置军团宝箱数据
	--DataMgr.ResetOfficerTrainingData();
	--重置avatar数据
	DataMgr.avatarData.avatar_list = {};
	DataMgr.avatarData.activate_avatar_list = {};
end

-- 初始化角色数据
function DataMgr.InitRoleData(roleDataTb)
	log("InitRoleData openID:" .. roleDataTb.openID .. " uid:" .. roleDataTb.uid);
	log("InitRoleData nickName:" .. roleDataTb.nickName .. " level:" .. roleDataTb.level .. " roleExp:" .. roleDataTb.roleExp .. " gender:" .. roleDataTb.gender);
	log("InitRoleData gold:" .. roleDataTb.gold);

	if roleDataTb.ticket ~= nil then
		log("InitRoleData ticket:" .. roleDataTb.ticket);
	end

	log("InitRoleData modify_name_time:".. tostring(roleDataTb.modify_name_time));
	log("InitRoleData last_modify_nation_time:".. tostring(roleDataTb.last_modify_nation_time));
	log("InitRoleData last_modify_nation_item_time:".. tostring(roleDataTb.last_modify_nation_item_time));
	log("InitRoleData registertime:".. tostring(roleDataTb.registertime));
	log("InitRoleData signature:" .. roleDataTb.signature);
	log("[HHF]DataMgr.InitRoleData, headIconUrl = " .. roleDataTb.headIconUrl);
	--log_tree("InitRoleData, eugdpr" , roleDataTb.eugdpr);
	log_tree("InitRoleData avatar:", roleDataTb.avatar);
	log_tree("InitRoleData avatar_feature_list:", roleDataTb.avatar_feature_list);
	log_tree("InitRoleData activate_avatar_list:", roleDataTb.activate_avatar_list);
	--log_tree("InitRoleData depot:", roleDataTb.depot);
	--log_tree("InitRoleData rolewear:", roleDataTb.rolewear);
	log("InitRoleData parachute:" .. roleDataTb.parachute);

	log("InitRoleData planeSkin:" .. tostring(roleDataTb.planeSkinInsID))
	log("InitRoleData bagSkin:" .. tostring(roleDataTb.bagSkinInsID))
	log("InitRoleData helmetSkin:" .. tostring(roleDataTb.helmetSkinInsID))
	log("InitRoleData headShow:" .. roleDataTb.head_show)
	log_tree("InitRoleData vehicleSkinInsIDTable:", roleDataTb.vehicleSkinInsIDTable)
	-- log_tree("InitRoleData rejoin_task:", roleDataTb.rejoin_task)
	--log_tree("InitRoleData segment:", roleDataTb.segment);
	--log_tree("InitRoleData login_reward:", roleDataTb.login_reward);
	log("InitRoleData last_login_reward_remind:" .. roleDataTb.last_login_reward_remind);
	--log_tree("InitRoleData week_signup:", roleDataTb.week_signup);
	--log_tree("InitRoleData share_award:", roleDataTb.share_award);
    log("InitRoleData fresher_type:" .. roleDataTb.fresher_type);
	if roleDataTb.wxsubscribe then
		log("InitRoleData wxsubscribe 微信订阅信息:" .. roleDataTb.wxsubscribe);
	end

	if roleDataTb.qqsubscribe then
		log("InitRoleData qqsubscribe qq订阅信息:" .. roleDataTb.qqsubscribe);
	end
	log("InitRoleData anchor:"..roleDataTb.anchor)
	
	log("InitRoleData qq_vip:" .. tostring(roleDataTb.qq_vip));

	log("InitRoleData xy_red_point:" .. tostring(roleDataTb.xy_red_point));
	log("InitRoleData corps_money:" .. tostring(roleDataTb.corps_money));

	log("InitRoleData pve_exp:" .. tostring(roleDataTb.pve_exp) .. ",pve_level:" .. tostring(roleDataTb.pve_level));


	DataMgr.ResetData();
	
	DataMgr.roleData.openID = roleDataTb.openID;
	DataMgr.roleData.uid = roleDataTb.uid;
	DataMgr.roleData.nickName = roleDataTb.nickName;
	DataMgr.roleData.nation = roleDataTb.nation;
	DataMgr.roleData.level = roleDataTb.level;
	DataMgr.roleData.roleExp = roleDataTb.roleExp;
	DataMgr.roleData.gender = roleDataTb.avatar.gamegender --roleDataTb.gender;
	DataMgr.roleData.signature = roleDataTb.signature;
	DataMgr.roleData.eugdpr = roleDataTb.eugdpr;
	DataMgr.roleData.headIconUrl = roleDataTb.headIconUrl;
    DataMgr.roleData.cur_avatar_box_id = roleDataTb.cur_avatar_box_id;
	DataMgr.roleData.qq_vip = GetSafeNumber(roleDataTb.qq_vip);
	DataMgr.roleData.xy_red_point = roleDataTb.xy_red_point;
	DataMgr.roleData.credit = roleDataTb.credit

	DataMgr.roleData.pve_exp = roleDataTb.pve_exp  --pve 经验
	DataMgr.roleData.pve_level = roleDataTb.pve_level --pve 等级

	DataMgr.roleData.enableWatch = roleDataTb.enableWatch
	DataMgr.roleData.watch_privacy = roleDataTb.watch_privacy -- 战斗内被观战他人是否可以查看段位信息
	DataMgr.roleData.enable_watch_remind = roleDataTb.enable_watch_remind
	DataMgr.roleData.isEmulator = Client.IsEmulator();

	DataMgr.roleData.alias = roleDataTb.alias;
	DataMgr.roleData.corps_alias_data = roleDataTb.corps_alias_data;
	DataMgr.roleData.carteamId = roleDataTb.carteam_id or 0;
	Client.SetPlayerBaseInfo(GameFrontendHUD, roleDataTb.openID, roleDataTb.uid, roleDataTb.nickName, roleDataTb.headIconUrl)

	--空投数据
	 if roleDataTb.luck_airdrop ~= nil then
	 	DataMgr.roleData.luck_airdrop = roleDataTb.luck_airdrop
	 end
     ------------------------------------intl modify----------------------------------------
	 DataMgr.roleData.allzoneSegment = roleDataTb.segment; 
	 
	 --log_tree("InitRoleData roleDataTb.segment____",roleDataTb.segment)
     SegmentZoneCount = #DataMgr.roleData.allzoneSegment;
    if SegmentZoneCount> 0 then
        for k, v in pairs(DataMgr.roleData.allzoneSegment) do	
            DataMgr.SetCurSegment(k) --waynedong wait check  DataMgr.roleData.segment
            break;
        end
    end
    --[[
	DataMgr.roleData.segment = 
	{
		solo = roleDataTb.segment[1],
		double = roleDataTb.segment[2],
		team = roleDataTb.segment[3],
	};]]
     ------------------------------------intl modify----------------------------------------
     
	DataMgr.UpdateTaskChange(false, roleDataTb.task)
	DataMgr.UpdateActiveChange(false, roleDataTb.activeness)

	--xzx9
	if roleDataTb.levelTask ~= nil then
		--log_tree("xzx9 DataMgr.InitRoleData succ", roleDataTb.levelTask)
		DataMgr.UpdateLevelTaskChange(false, roleDataTb.levelTask)
	else
		log("xzx9 DataMgr.InitRoleData failed")
	end
	
	
	--DataMgr.UpdateTaskChange(false, roleDataTb.task)
	--DataMgr.UpdateActiveChange(false, roleDataTb.activeness)

	DataMgr.gold = roleDataTb.gold;
	DataMgr.ticket = roleDataTb.ticket;
	DataMgr.diamond = roleDataTb.diamond;
	DataMgr.fp_token = roleDataTb.fp_token or 0;
	DataMgr.gen_ticket = roleDataTb.gen_ticket;
	DataMgr.corps_money = roleDataTb.corps_money;
	DataMgr.gold_chip = roleDataTb.gold_chip or 0;

	DataMgr.wxsubscribe = roleDataTb.wxsubscribe
	DataMgr.qqsubscribe = roleDataTb.qqsubscribe
	
	DataMgr.anchor = roleDataTb.anchor;
	DataMgr.fresher_type = roleDataTb.fresher_type;
    
	DataMgr.modify_name_time = GetSafeNumber(roleDataTb.modify_name_time);
	DataMgr.last_modify_nation_time = GetSafeNumber(roleDataTb.last_modify_nation_time);
	DataMgr.last_modify_nation_item_time = GetSafeNumber(roleDataTb.last_modify_nation_item_time);
	
	DataMgr.registertime = GetSafeNumber(roleDataTb.registertime);
	if roleDataTb.Recharge == nil then
		DataMgr.Recharge = 1;
	else
		DataMgr.Recharge = roleDataTb.Recharge; --没有充值过是1，有过充值行为以后都是0
	end		
	DataMgr.krjp_del_account_left_time = GetSafeNumber(roleDataTb.krjp_del_account_left_time);
	
	log("InitRoleData Recharge:" .. tostring(roleDataTb.Recharge).."DataMgr Recharge:" .. tostring(DataMgr.Recharge));
	-- 初始化avatar
	DataMgr.avatarData.headid = roleDataTb.avatar.headid;
	DataMgr.avatarData.gamegender = roleDataTb.avatar.gamegender;
	DataMgr.avatarData.hairid = roleDataTb.avatar.hairid;
	DataMgr.avatarData.beardid = roleDataTb.avatar.beardid or 0;
	DataMgr.avatarData.beardcolorid = roleDataTb.avatar.beardcolor or 0;
	DataMgr.avatarData.avatar_list = {};
	if roleDataTb.avatar_feature_list ~= nil then
		for k,v in pairs(roleDataTb.avatar_feature_list) do
			DataMgr.avatarData.avatar_list[k] = v;
		end
	end
	if roleDataTb.activate_avatar_list ~= nil then
		for k,v in pairs(roleDataTb.activate_avatar_list) do
			DataMgr.avatarData.activate_avatar_list[k] = v;
		end
	end

	-- 更新全局游戏性别
	GlobalData:SetGameGender(DataMgr.avatarData.gamegender);
    
	DataMgr.rolewear_array = roleDataTb.rolewear_array;
	DataMgr.rolewear_state = roleDataTb.rolewear_state;
	DataMgr.use_rolewear = roleDataTb.use_rolewear;
	DataMgr.pspace_rolewear_index = roleDataTb.pspace_rolewear_index;
	log_tree("DataMgr.rolewear_array", DataMgr.rolewear_array)

	-- 初始化时装
	DataMgr.rolewear = DataMgr.GetRolewearByIndex(roleDataTb.use_rolewear)
	log_tree("DataMgr.rolewear----", DataMgr.rolewear)

	-- 初始化降落伞数据
	local sysCfg = Client.GetTableData("SystemConfig", "DefaultParachute");
	DataMgr.defaultParachuteResID = 0;
	if sysCfg ~= nil then
		DataMgr.defaultParachuteResID = tonumber(sysCfg.ConfigValue);
	end
	DataMgr.parachute = tostring(roleDataTb.parachute);

	-- 初始化飞机涂装数据
	DataMgr.planeSkinInsID = tostring(roleDataTb.planeSkinInsID);

	-- 初始化装备涂装数据(背包/头盔/防弹衣)
	DataMgr.equipmentSkinInsIDTable[504] = roleDataTb.bagSkinInsID ~= 0 and tostring(roleDataTb.bagSkinInsID) or "";
	DataMgr.equipmentSkinInsIDTable[505] = roleDataTb.helmetSkinInsID ~= 0 and tostring(roleDataTb.helmetSkinInsID) or "";
	DataMgr.equipmentSkinInsIDTable[506] = roleDataTb.armorSkinInsID ~= 0 and tostring(roleDataTb.armorSkinInsID) or "";
	
	log("roleDataTb.head_show" .. roleDataTb.head_show)
	DataMgr.head_show = roleDataTb.head_show or 0;
	DataMgr.bag_level = roleDataTb.bag_level or 1;
	DataMgr.helmet_level = roleDataTb.helmet_level or 1;

	-- 初始化载具涂装数据
	DataMgr.InitVehicleSkinData(roleDataTb.vehicleSkinInsIDTable);
	
	-- 初始化仓库数据
	DataMgr.InitHallDepotData(roleDataTb.depot);

	-- 初始化装备数据
	DataMgr.InitWeaponData(roleDataTb.weapon_id, roleDataTb.weapon_skin_insID);
	
	--初始化登录领奖数据
	DataMgr.SignInInfo.login_reward = roleDataTb.login_reward;
	DataMgr.SignInInfo.last_login_reward_remind = roleDataTb.last_login_reward_remind;

	-- 初始化周签到数据
	DataMgr.InitWeekSignUpList(roleDataTb.week_signup);
	
	-- 初始化分享领奖数据
	if roleDataTb.share_award ~= nil then
		DataMgr.ShareAwardInfo.daily_share_time = roleDataTb.share_award.daily_share_time;
		DataMgr.ShareAwardInfo.share_times = roleDataTb.share_award.share_times;
		for k, v in pairs(roleDataTb.share_award.list) do
			DataMgr.ShareAwardInfo.AwardState[k] = v.status;
		end
		
		ShareAwardMgr.OnShareAwardInfoUpdate();
	else
		sandbox.LogError("roleDataTb.share_award == nil");
	end
	-- 初始化金币和经验加成
	DoubleCardSystem.InitData(roleDataTb.double_card);
	-- 初始化房卡
	DataMgr.InitRoomCardInfo(roleDataTb.room_cards["ordinary"]);
	DataMgr.InitRoomCardInfoAdv(roleDataTb.room_cards["advanced"])
	DataMgr.InitRoomCardInfoMat(roleDataTb.room_cards["match"])
	--log_tree("[CLL] roomcards ",roleDataTb.room_cards)

	-- 初始化回流系统
	ComeBackMgr.InitData(roleDataTb.rejoin_task)
    
    DataMgr.IsEightDaySlpaed = false;

    DataMgr.InitJPAgeInfo(roleDataTb.jp_age);

    DataMgrInit = true;   

	DataMgr.carteam_coin_count = roleDataTb.carteam_coin_count or 0;

	DataMgr.uiRectOffset = roleDataTb.uiRectOffset or "";

	DataMgr.season_id = roleDataTb.season_id or 1;
	log("******* season_id init as " .. DataMgr.season_id)
	
end

-- 根据衣橱index获取rolewear
function DataMgr.GetRolewearByIndex(index)
	local rolewear = {};
	if DataMgr.rolewear_array == nil or #DataMgr.rolewear_array == 0 then
		return rolewear;
	end

	for k,v in pairs(DataMgr.rolewear_array[index]) do
		if v ~= 0 then
			table.insert(rolewear, tostring(v));
		end
	end 
	return rolewear;
end

function DataMgr.UpdateRolewearArray(index)
	if DataMgr.rolewear_array ~= nil then
		DataMgr.rolewear_array[index] = {};

		for k,v in pairs(DataMgr.rolewear) do
			if v ~= 0 then
				table.insert(DataMgr.rolewear_array[index], tostring(v));
			end
		end 
	end
end

-- 设置当前的segment
function DataMgr.SetCurSegment(zoneId)
    -- 有数据且数据不为nil
     log("DataMgr.SetCurSegment, zoneId = "..zoneId);
    if #DataMgr.roleData.allzoneSegment > 0  and DataMgr.roleData.allzoneSegment[zoneId]~=nil then
         DataMgr.roleData.segment = 
         {
            solo     = DataMgr.roleData.allzoneSegment[zoneId][enum_SegmentType.solo],
            double = DataMgr.roleData.allzoneSegment[zoneId][enum_SegmentType.double],
            team   = DataMgr.roleData.allzoneSegment[zoneId][enum_SegmentType.team],
            fpp_solo     = DataMgr.roleData.allzoneSegment[zoneId][enum_SegmentType.fpp_solo],
            fpp_double = DataMgr.roleData.allzoneSegment[zoneId][enum_SegmentType.fpp_double],
            fpp_team   = DataMgr.roleData.allzoneSegment[zoneId][enum_SegmentType.fpp_team],
         }
    end
    --log_tree("DataMgr.roleData.segment:", DataMgr.roleData.segment);
end

-- 设置当前的segment
function DataMgr.GetSegmentByZoneId(zoneId)
     log("DataMgr.GetSegmentByZoneId, zoneId = "..zoneId);
    if #DataMgr.roleData.allzoneSegment > 0  and DataMgr.roleData.allzoneSegment[zoneId]~=nil then
         segment = 
         {
            solo     = DataMgr.roleData.allzoneSegment[zoneId][enum_SegmentType.solo],
            double = DataMgr.roleData.allzoneSegment[zoneId][enum_SegmentType.double],
            team   = DataMgr.roleData.allzoneSegment[zoneId][enum_SegmentType.team],
            fpp_solo     = DataMgr.roleData.allzoneSegment[zoneId][enum_SegmentType.fpp_solo],
            fpp_double = DataMgr.roleData.allzoneSegment[zoneId][enum_SegmentType.fpp_double],
            fpp_team   = DataMgr.roleData.allzoneSegment[zoneId][enum_SegmentType.fpp_team],
         }
          --log_tree("DataMgr.GetSegmentByZoneId:", segment);
         return segment
    end
    return nil
end

function DataMgr.InitVehicleSkinData(data)
	if data ~= nil then
		DataMgr.vehicleSkinInsIDTable = {}
		for k, v in pairs(data) do
			if v ~= 0 then
				DataMgr.vehicleSkinInsIDTable[k] = tostring(v)
			end
		end
	end
	log_tree("[LLP]DataMgr.InitVehicleSkinData", DataMgr.vehicleSkinInsIDTable)
end

function DataMgr.InitBanData(banData)
    DataMgr.ban = banData;
end

-- 更新自己的概要数据
function DataMgr.UpdateMyRoleProfileData(data, myRankData, myPassData, myAliasData, corps_alias_info)
	
	DataMgr.roleData.nickName = data.nickName;

	--做一个保护,因为profile的数据,不会实时更新,导致数据是脏的
	if data.level > DataMgr.roleData.level then
		DataMgr.roleData.level = data.level;
	end

	if data.pve_level > DataMgr.roleData.pve_level then
		DataMgr.roleData.pve_level = data.pve_level;
	end

	if data.pve_exp > DataMgr.roleData.pve_exp then
		DataMgr.roleData.pve_exp = data.pve_exp;
	end

	log("[LLP]DataMgr.UpdateMyRoleProfileData, roleDataLevel = "..DataMgr.roleData.level .. ",pve_level:"
			.. DataMgr.roleData.pve_level .. ",pve_exp:" .. tostring(DataMgr.roleData.pve_exp));
	--DataMgr.roleData.gender = roleDataTb.gender;
	--DataMgr.roleData.signature = data.signature;
	DataMgr.roleData.headIconUrl = data.picUrl;
	DataMgr.roleData.upvote = data.upvote;
	log("[HHF]DataMgr.UpdateMyRoleProfileData, headIconUrl = " .. DataMgr.roleData.headIconUrl);
    DataMgr.roleData.cur_avatar_box_id = data.cur_avatar_box_id;
	DataMgr.roleData.qq_vip = GetSafeNumber(data.qq_vip);
	--DataMgr.roleData.xy_red_point = data.xy_red_point;



    DataMgr.roleData.allzoneSegment = data.segment_info; 
    SegmentZoneCount = #DataMgr.roleData.allzoneSegment;
    if SegmentZoneCount> 0 then
        for k, v in pairs(DataMgr.roleData.allzoneSegment) do	
            DataMgr.SetCurSegment(k)
            break;
        end
    end
    --[[
	DataMgr.roleData.segment = 
	{
		solo = data.segment_info[1],
		double = data.segment_info[2],
		team = data.segment_info[3],
	};]]
	
	if myRankData then
		DataMgr.roleData.rankdata = myRankData;
		--log_tree("roleData.rankdata", DataMgr.roleData.rankdata);
	else
		log("UpdateMyRoleProfileData rankdata is empty")
	end

	--[[roleData.myPassData
	LogNula: LuaLog: ├─ is_buy: 0
	LogNula: LuaLog: ├─ score: 0
	LogNula: LuaLog: ├─ cur_season: 1
	LogNula: LuaLog: ├─ acc_update_time: 0
	LogNula: LuaLog: ├─ switch
	LogNula: LuaLog: │  ├─ battle_title: true
	LogNula: LuaLog: │  ├─ ui: true
	LogNula: LuaLog: │  └─ battle_show: true
	LogNula: LuaLog: ├─ level: 1
	LogNula: LuaLog: └─ acc_score: 0]]
	if myPassData then
		DataMgr.roleData.upass = myPassData;
		--log_tree("roleData.myPassData", DataMgr.roleData.upass);
	else
		log("UpdateMyRoleProfileData myPassData is empty")
	end	

	--[[
	alias
	LogNula: LuaLog: │  ├─ receive_time: 0
	LogNula: LuaLog: │  ├─ expire_ts: 0
	LogNula: LuaLog: │  ├─ last_modify_time: 0
	LogNula: LuaLog: │  ├─ title: ""
	LogNula: LuaLog: │  └─ id: 0
	]]
	-- 采用逐条复制的方式,防止red_point被覆盖消失
	if myAliasData then
		local redpoint = DataMgr.roleData.alias.red_point;
		DataMgr.roleData.alias = myAliasData;
		DataMgr.roleData.alias.red_point = redpoint;
		DataMgr.roleData.alias.title = FuncUtil:Gen_title(myAliasData.id, myAliasData.rank);	
		--log_tree("roleData.myAliasData", DataMgr.roleData.alias);
	else
		log("UpdateMyRoleProfileData myAliasData is empty")
	end

	if corps_alias_info then
		--军团称号ID
		if DataMgr.roleData.corps_alias_data then
			DataMgr.roleData.corps_alias_data.cur_corps_alias_id = corps_alias_info.cur_corps_alias_id;
		end
	end
	
	--log("corp_alias_id.." .. corp_alias_id);
	--log_tree("DataMgr.roleData.corps_alias_data", DataMgr.roleData.corps_alias_data);
end

-- 初始化背包数据
--请求列表返回 wardrobe_items
--    item.instid = newinstid;
--    item.res_id = resid;
--    item.use_flag = 0;
--    item.count = count;
function DataMgr.InitHallDepotData(arrayItemData)
    log("DataMgr.InitHallDepotData:");	
	--log_tree("arrayItemData", arrayItemData);
	
	DataMgr.arrayHallDepotItemInfo = {};	
	DataMgr.WardrobeItemList = {};
	indexCacheTable = {};
	tableForResIdSearch = {};
	--log_tree("itemDatas", itemDatasCfg);
		
 --    local id = 1;
	for k,v in pairs(arrayItemData) do
		--log_tree("onItem:", v);
		local itemDataCfg = Client.GetTableData("Item", v.res_id);
		--log_tree("itemDataCfg", itemDataCfg);
		if itemDataCfg then
			local itemInfo = DataMgr.AddItemToHallDepot(v, itemDataCfg);
			DataMgr.WardrobeItemList[v.res_id] = itemDataCfg;
			if itemInfo.resID == DataMgr.defaultParachuteResID then
				DataMgr.defaultParachuteInsID = itemInfo.insID;
			elseif itemInfo.resID == DataMgr.defaultPlaneSkinResID then
				DataMgr.defaultPlaneSkinInsID = itemInfo.insID;
			elseif DataMgr.defaultVehicleSkinInsIDTable[itemInfo.resID] ~= nil then
				-- log("[LLP]DataMgr.InitHallDepotData defaultVehicleSkinInsIDTable"..tostring(itemInfo.resID))
				-- log("[LLP]DataMgr.InitHallDepotData defaultVehicleSkinInsIDTable"..itemInfo.insID)
				DataMgr.defaultVehicleSkinInsIDTable[itemInfo.resID] = itemInfo.insID;
			end
		end
	end
	
	DataMgr.InitDepotMapSourceBook()
	EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_DATA_INIT);
end

function DataMgr.InitDepotMapSourceBook()
	if DataMgr.isMapSourceInit then
		return
	end
	local itemDatasCfg = Client.GetTable("Item");
	local pageType = 0;
	local strRegion = Client.GetPublishRegion();
	DataMgr.mapSourceBookInfo = {};
	for k, v in pairs(itemDatasCfg) do
		-- 初始化图鉴
		local showSourceBook = false;
		if strRegion == "JAPAN" or strRegion == "KOREA" then
			if(v.SourceBookEnable == 2 or v.SourceBookEnable == 3) then
				showSourceBook = true;
			else
				showSourceBook = false;
			end
		else
			if(v.SourceBookEnable == 1 or v.SourceBookEnable == 3) then
				showSourceBook = true;
			else
				showSourceBook = false;
			end
		end
		if showSourceBook then
			pageType = v.WardrobeMainTab or 0;
			DataMgr.mapSourceBookInfo[pageType] = DataMgr.mapSourceBookInfo[pageType] or {};
			DataMgr.mapSourceBookInfo[pageType] [v.WardrobeTab] = DataMgr.mapSourceBookInfo[pageType] [v.WardrobeTab] or {};
			
			table.insert(DataMgr.mapSourceBookInfo[pageType] [v.WardrobeTab], {
				insID = "",
				resID = v.ItemID,
				count = 0,
				isNew = false,
				
				itemType = v.ItemType,
				itemSubType = v.ItemSubType,
				itemQuality = v.ItemQuality,
				mainTabType = v.WardrobeMainTab,
				wardrobeTab = v.WardrobeTab,
			});
		end
	end

	-- 排序图鉴
	for k, v in pairs(DataMgr.mapSourceBookInfo) do
		for sk, sv in pairs(v) do
			table.sort(sv, function(a, b)
				
				if a.itemSubType ~= b.itemSubType then
					return a.itemSubType < b.itemSubType;
				elseif a.itemQuality ~= b.itemQuality then
					return a.itemQuality > b.itemQuality;
				elseif a.resID ~= b.resID then
					return a.resID < b.resID;
				else
					return false;
				end
			end);
		end
	end

	--log_tree("DataMgr.mapSourceBookInfo", DataMgr.mapSourceBookInfo);
	--log_tree("arrayHallDepotItemInfo", DataMgr.arrayHallDepotItemInfo);	
	DataMgr.isMapSourceInit = true
end


--获取avatar剩余时间
function DataMgr.GetAvatarRemainTime(avatar_id)
	--默认为已过期
	-- log("[LLP]DataMgr.GetAvatarRemainTime:"..avatar_id);
	-- log_tree("[LLP]DataMgr.GetAvatarRemainTime:", DataMgr.avatarData.avatar_list);
	local remainTime = -1;
	if DataMgr.avatarData.avatar_list[avatar_id] ~= nil then
		if DataMgr.avatarData.avatar_list[avatar_id] == 0 then
			--为0表示永久
			remainTime = 0;
		else
			remainTime = DataMgr.avatarData.avatar_list[avatar_id] - FuncUtil.GetServerTimeInSec();
			log("GetAvatarRemainTime "..tostring(avatar_id)..":"..tostring(remainTime))
			if remainTime == 0 then
				--刚好过期，设置为剩余时间1s
				remainTime = 1;
			end
		end
	end
	return remainTime;
end


-- 更新角色穿戴信息
function DataMgr.UpdateRoleWearData(putOnId, putDownId)
	local isFind = false;	
	if putOnId ~= "" then
		for k,v in pairs(DataMgr.rolewear) do
			if v == putOnId then
				isFind = true;
				v = putOnId;
				break;
			end
		end
	end
	
	if isFind == false then
		table.insert(DataMgr.rolewear, putOnId);
	end
	
	if putDownId ~= "" then
		for k,v in pairs(DataMgr.rolewear) do
			if v == putDownId then
				table.remove(DataMgr.rolewear, k);
				break;
			end
		end
	end

	DataMgr.UpdateItemNewFlag(putOnId, putDownId);

	DataMgr.UpdateRolewearArray(DataMgr.use_rolewear);
end

function DataMgr.UpdateItemNewFlag(putOnId, putDownId)
	DataMgr.ChangeHallDepotItemNewStatus(putOnId);
	DataMgr.ChangeHallDepotItemNewStatus(putDownId);
	--[[for k,v in pairs(DataMgr.arrayHallDepotItemInfo) do
		if v.insID == putOnId or v.insID == putDownId then
			v.isNew = false;
		end
	end]]--	
end

-- 更新降落伞
function DataMgr.UpdateParachute(putOnId)
	-- 先更新标志
	DataMgr.UpdateItemNewFlag(putOnId, DataMgr.parachute);
	-- 后更新穿戴信息
	DataMgr.parachute = putOnId;
 end

-- 更新飞机
function DataMgr.UpdatePlaneSkin(putOnId)
	-- 先更新标志
	DataMgr.UpdateItemNewFlag(putOnId, DataMgr.planeSkinInsID);
	-- 后更新穿戴信息
	DataMgr.planeSkinInsID = putOnId;
end

-- 更新装备皮肤
function DataMgr.UpdateEquipmentSkin(itemSubType, putOnId)
	-- log("[LLP]DataMgr.UpdateEquipmentSkin:itemSubType"..tostring(itemSubType).."putOnId"..putOnId)
	local skinInsID = DataMgr.equipmentSkinInsIDTable[itemSubType]
	if skinInsID ~= nil then
		-- 先更新标志
		DataMgr.UpdateItemNewFlag(putOnId, skinInsID);
		-- 后更新穿戴信息
		DataMgr.equipmentSkinInsIDTable[itemSubType] = putOnId;
	end
end

-- 更新载具皮肤
function DataMgr.UpdateVehicleSkin(itemSubType, putOnId)
	-- log("[LLP]DataMgr.UpdateVehicleSkin:itemSubType"..tostring(itemSubType).."putOnId"..putOnId)
	local skinInsID = DataMgr.vehicleSkinInsIDTable[itemSubType]
	if skinInsID ~= nil then
		-- 先更新标志
		DataMgr.UpdateItemNewFlag(putOnId, skinInsID);
		-- 后更新穿戴信息
		DataMgr.vehicleSkinInsIDTable[itemSubType] = putOnId;
		-- log_tree("[LLP]DataMgr.UpdateVehicleSkin:itemSubType", DataMgr.vehicleSkinInsIDTable)
	end
end

-- 变更物品new便签
function DataMgr.ChangeHallDepotItemNewStatus(insID)
	local index = indexCacheTable[insID];
	if index ~= nil then
		local val = DataMgr.arrayHallDepotItemInfo[index];
		val.isNew = false;
		DataMgr.arrayHallDepotItemInfo[index] = val;
	end
	--[[for k,v in pairs(DataMgr.arrayHallDepotItemInfo) do
		if v.insID == insID then
			v.isNew = false;
			break;
		end
	end]]--
end

-- 获取大厅仓库数据，需要控制该接口在循环中使用，仓库数据是个大字典
function DataMgr.GetHallDepotItemDataByInsID(insID)
	insID = tostring(insID);
	local index = indexCacheTable[insID];
	if index ~= nil then
	return DataMgr.arrayHallDepotItemInfo[index];
	end
	return nil;
	--[[for k,v in pairs(DataMgr.arrayHallDepotItemInfo) do
		if v.insID == insID then
			return v;
		end
	end
	return nil;]]--
end

-- 获取大厅仓库数据
function DataMgr.GetValidHallDepotItemDataByInsID(insID)
	insID = tostring(insID)
	local itemData = DataMgr.GetHallDepotItemDataByInsID(insID);
	if itemData and DataMgr.IsValidTime(itemData.expireTS) then
		return itemData;
	end
	return nil;
end

-- 获取大厅仓库数据(自定义服装可能要改) 注意根据需要增加物品过时验证 或者使用DataMgr.GetHallDepotItemDataByResIDAndValidExpireTime 函数
function DataMgr.GetHallDepotItemDataByResID(resID)
	local cacheTable = tableForResIdSearch[resID];
	if cacheTable ~= nil then
		local index = cacheTable[1];
		if index ~= nil and index >= 0 then
			return DataMgr.arrayHallDepotItemInfo[index];
		end
	end
	--[[for k,v in pairs(DataMgr.arrayHallDepotItemInfo) do
		if v.resID == resID then
			return v;
		end
	end]]--	
	--log_tree("error........................................cacheTable ",cacheTable);
	return nil;
end

--通过资源ID 获取背包或者仓库中没有过时的物品  注意:过时的物品服务器不会通知删除 需要客户端自行判断 或者使用DataMgr.GetHallDepotItemListByResIDValidExpireTime
function DataMgr.GetHallDepotItemDataByResIDAndValidExpireTime(resID)
	local cacheTable = tableForResIdSearch[resID];
	if cacheTable ~= nil then
		 for k,v in pairs(cacheTable) do
			if v ~= nil and v >=0 then
				local val = DataMgr.arrayHallDepotItemInfo[v];
				if DataMgr.IsValidTime(val.expireTS) then
				 return val;
				end
			end
		end
	end	
	--log_tree("error........................................cacheTable ",cacheTable);
	return nil;
end

--根据ResID 获取对应的实例item资源对应的列表 增加判断物品过时时间验证  DataMgr.IsValidTime(itemData.expireTS)
function DataMgr.GetHallDepotItemListByResIDValidExpireTime(resID)
	local result = {};
	local cacheTable = tableForResIdSearch[resID];
	if cacheTable ~= nil then
		for k,v in pairs(cacheTable) do
			if v ~= nil and v >=0 then
				local val = DataMgr.arrayHallDepotItemInfo[v];
				if DataMgr.IsValidTime(val.expireTS) then
				 table.insert(result,DataMgr.arrayHallDepotItemInfo[v]);
				end
			end
		end
	end
	--[[local result = {};

	for i,v in ipairs(DataMgr.arrayHallDepotItemInfo) do
		if v.resID == resID then
			table.insert(result, v);
		end
	end]]--	
	return result;
end

-- 获取大厅仓库数据(自定义服装可能要改)  使用此接口的时候需要自己判断物品过时时间  DataMgr.IsValidTime(itemData.expireTS)
function DataMgr.GetHallDepotItemListByResID(resID)
	local result = {};
	local cacheTable = tableForResIdSearch[resID];
	if cacheTable ~= nil then
		for k,v in pairs(cacheTable) do
			if v ~= nil and v >=0 then
				table.insert(result,DataMgr.arrayHallDepotItemInfo[v]);
			end
		end
	end
	--[[local result = {};

	for i,v in ipairs(DataMgr.arrayHallDepotItemInfo) do
		if v.resID == resID then
			table.insert(result, v);
		end
	end]]--
	
	return result;
end

-- 获取同一resID的道具总数量
function DataMgr.GetHallDepotItemCountByResID(resID)
	local count = 0;
	local cacheTable = tableForResIdSearch[resID];
	if cacheTable ~= nil then
		for k,v in pairs(cacheTable) do
			if v ~= nil and v >=0 then
				local item = DataMgr.arrayHallDepotItemInfo[v];
				count = count + item.count;
			end
		end
	end
	return count;
end

-- 获取最高段位信息
function DataMgr.GetMaxRankLevel()
--[[
    local maxRankLevel = DataMgr.roleData.segment.solo;
    if maxRankLevel < DataMgr.roleData.segment.double then 
        maxRankLevel = DataMgr.roleData.segment.double
    end
    
    if maxRankLevel < DataMgr.roleData.segment.team then
        maxRankLevel = DataMgr.roleData.segment.team
    end
    ]]
    DataMgr.fillMaxSegmentInfo();
    maxRankLevel =  math.max(DataMgr.maxSegmentSolo.SegmentLevel, DataMgr.maxSegmentDuo.SegmentLevel, DataMgr.maxSegmentSquad.SegmentLevel, DataMgr.maxSegmentSoloFpp.SegmentLevel, DataMgr.maxSegmentDuoFpp.SegmentLevel, DataMgr.maxSegmentSquadFpp.SegmentLevel);
    return maxRankLevel
end

-- 更新仓库数据
function DataMgr.UpdateHallDepotItemData(itemData)
	local isFind = false;
	local instId = tostring(itemData.instid);
	local v = DataMgr.GetHallDepotItemDataByInsID(instId);
	if v ~= nil then
		isFind = true;
		v.count = itemData.count;
			v.isNew = itemData.isNew;
			v.count = itemData.count;
			if v.count <= 0 then
				DataMgr.RemoveItemFromHallDepot(indexCacheTable[instId], v);
			end
	end
	--[[for k,v in pairs(DataMgr.arrayHallDepotItemInfo) do
		if v.instid == tostring(itemData.instid) then
			isFind = true;
			
			v.count = itemData.count;	
			v.isNew = itemData.isNew;	
			v.count = itemData.count;			
			
			if v.count <= 0 then
				DataMgr.RemoveItemFromHallDepot(k, v);
			end
			break;
		end
	end]]--
	
	if isFind == false and itemData.count > 0 then
		local itemDataCfg = Client.GetTableData("Item", itemData.res_id);
		if itemDataCfg ~= nil then
			DataMgr.AddItemToHallDepot(itemData, itemDataCfg);
		end
	end
end

function DataMgr.AddItemToHallDepot(itemData, itemDataCfg)
	local itemInfo =
	{
		insID = tostring(itemData.instid),
		resID = itemData.res_id,
		count = itemData.count,
		isNew = (itemData.isnew == 1),

		validHours = itemData.valid_hours or 0,
		expireTS = itemData.expire_ts or 0,

		itemType = itemDataCfg.ItemType,
		itemSubType = itemDataCfg.ItemSubType,
		mainTabType = itemDataCfg.WardrobeMainTab,
		itemQuality = itemDataCfg.ItemQuality,

		colorID = itemData.color,
		patternID = itemData.pattern,
	};
	--log_tree("add", itemInfo);
	local index = #DataMgr.arrayHallDepotItemInfo;
	index = index + 1;
	--log("index: ",index);
	indexCacheTable[itemInfo.insID]=index;
	local cacheTable = tableForResIdSearch[itemInfo.resID];
	--log_tree("before insert cache",cacheTable);
	if cacheTable ~= nil then
		local repeatindex = -1;
		for k,v in pairs(cacheTable) do
			if v == index then
				repeatindex = k;
				break;
			end
		end
		if repeatindex == -1 then
		table.insert(cacheTable,index);
		end
		--log_tree("insert index：",cacheTable);
	else
		cacheTable = {};
		table.insert(cacheTable,index);
	end
	tableForResIdSearch[itemInfo.resID] = cacheTable;
	--log_tree("after tableForResIdSearch ",tableForResIdSearch);
	--log_tree("indexCacheTable ",indexCacheTable);
	table.insert(DataMgr.arrayHallDepotItemInfo, itemInfo);
	return itemInfo;
end

function DataMgr.RemoveItemFromHallDepot(idx, itemData)
	--log_tree("before RemoveItemFromHallDepot ", DataMgr.arrayHallDepotItemInfo);
	local val = DataMgr.arrayHallDepotItemInfo[idx];
	if val ~= nil then
	indexCacheTable[val.insID] = nil;
	--删除对应的resid对应的索引(对应itemid)元素
	local cache = tableForResIdSearch[val.resID];
	local recordindex = -1;
	if cache ~= nil then
		for k,v in pairs(cache) do
			if v == idx then
				recordindex = k;
				break;
			end
		end
    end
    if recordindex >= 0 then
	    table.remove(cache,recordindex);
	    if #cache <= 0 then
	    tableForResIdSearch[val.resID] = nil;
		end
    end
    DataMgr.arrayHallDepotItemInfo[idx] = nil;
	end
	--log_tree("After RemoveItemFromHallDepot ", DataMgr.arrayHallDepotItemInfo);
end

function DataMgr.IsValidTime(time)
	time = time or 0;
	return time == 0 or time >= FuncUtil.GetServerTimeInSec();
end


function DataMgr.OnHallDepotDataNotify(changelist)
	-- log_tree("OnHallDepotDataNotify:changelist", changelist);
	-- for k,v in pairs(changelist) do
	-- 	-- print(os.date("%Y-%m-%d %H:%M:%S", 1517848234))
	-- 	if v.expire_ts then
	-- 		log("OnHallDepotDataNotify timeout:"..os.date("%Y-%m-%d %H:%M:%S", v.expire_ts))
	-- 	end
	-- end

	-- log_tree("arrayHallDepotItemInfo before", DataMgr.arrayHallDepotItemInfo);
	local hasNewItem = false;
	local isFind = false;

	local tempChangeInsMap = {}
	local tempChangeExpireTSItemMap = {}
    local tempMaxExpireTSItemMap = {}
	for k,v in pairs(changelist) do
		isFind = false;
		if v.isnew == 1 then
			hasNewItem = true;
		end
		local vindex = indexCacheTable[tostring(v.instid)];
		if vindex ~= nil then
			isFind = true;
			local  vv = DataMgr.arrayHallDepotItemInfo[vindex];
			if vv ~= nil then
		  		if v.count > 0 then
                    if v.reach_max_expire_ts ~= nil then
                        tempMaxExpireTSItemMap[v.res_id] = v.reach_max_expire_ts;
                    else
                        local changeExpireTSValue = DataMgr.GetExpireTSAddValue(vv, v);
                        if changeExpireTSValue > 0 then
                            tempChangeExpireTSItemMap[v.res_id] = changeExpireTSValue;
                        end
                    end
					vv.resID = v.res_id;
					vv.count = v.count;
					vv.isNew = (v.isnew == 1);
					vv.validHours = v.valid_hours or vv.validHours or 0;
					vv.expireTS	 = v.expire_ts or vv.expireTS or 0;
					vv.colorID = v.color;
					vv.patternID = v.pattern;
				else
					DataMgr.RemoveItemFromHallDepot(vindex, vv);
				end
			end
		end
		--[[for kk,vv in pairs(DataMgr.arrayHallDepotItemInfo) do
			if tostring(v.instid) == vv.insID then
				isFind = true;
				
				if v.count > 0 then
					vv.resID = v.res_id;
					vv.count = v.count;
					vv.isNew = (v.isnew == 1);
					vv.validHours = v.valid_hours or vv.validHours or 0;
					vv.expireTS	 = v.expire_ts or vv.expireTS or 0;
					vv.colorID = v.color;
					vv.patternID = v.pattern;
				else
					DataMgr.RemoveItemFromHallDepot(kk, vv);
				end
				
				break;
			end
		end]]--
		
		if isFind == false then
			if v.count > 0 then
				-- 新增一个物品
				local itemDataCfg = Client.GetTableData("Item", v.res_id);
				if itemDataCfg ~= nil then
					local itemData = DataMgr.AddItemToHallDepot(v, itemDataCfg);
					tempChangeInsMap[itemData.insID] = itemData;
				end
			end
		elseif isFind == true then
			WardrobeUI:UpdateItemData(v);
		end
	end

	local motionList = {}
	local motionListLen = math.max(0, DataMgr.MotionSlotMax - #DataMgr.MotionSlotList);
	if motionListLen > 0 then

		for k,v in pairs(tempChangeInsMap) do
			-- 表情自动装备
			if v.itemType == 22 then
				table.insert(motionList, v.insID);
				if #motionList >= motionListLen then
					break;
				end
			end
		end

		if #motionList > 0 then
			WardrobeSystem.equip_motion_list_req(motionList);
		end
	end

	--log_tree("arrayHallDepotItemInfo after", DataMgr.arrayHallDepotItemInfo);	
	
	--log("DataMgr.OnHallDepotDataNotify "..tostring(hasNewItem));
	if hasNewItem then
		EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_ADD_NEW, changelist);
	end

	if next(tempMaxExpireTSItemMap) ~= nil then
		DataMgr.ShowExpireTSMaxTips(tempMaxExpireTSItemMap);
	end
    if next(tempChangeExpireTSItemMap) ~= nil then
        DataMgr.ShowExpireTSChangeTips(tempChangeExpireTSItemMap);
    end
	-- 广播事件
	EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_DATA_CHANGE, changelist);
end

function DataMgr.GetExpireTSAddValue(src, dst)
	local tSrc = src.expireTS or 0;
	local tDst = dst.expire_ts or 0;
	if tSrc < tDst then
		return tDst - tSrc;
	end
	return 0;
end

function DataMgr.ShowExpireTSChangeTips(map)
	for resId, changeValue in pairs(map) do
		if changeValue > 0 then
			local cfg = Client.GetTableData("Item", resId);
			if cfg then
				-- 计算天数和小时数
				local timeStr = WardrobeSystem.GetTimeStr(changeValue)
				PopUpNoticeUI.ShowFastNoticeQueue(FuncUtil.LocalizeResFormat(6831, cfg.ItemName, timeStr));
			end
		end
	end
end

function DataMgr.ShowExpireTSMaxTips(map)
    for resId, maxValue in pairs(map) do
        if maxValue ~= nil then
            local cfg = Client.GetTableData("Item", resId);
            if cfg then
                PopUpNoticeUI.ShowFastNoticeQueue(FuncUtil.LocalizeResFormat(6859, cfg.ItemName));
            end
        end
    end
end

--更新登录领奖相关数据
function DataMgr.UpdateSignInData(period, day)
	log("DataMgr UpdateSignInData");
	if DataMgr.SignInInfo.login_reward[period] == nil then
		DataMgr.SignInInfo.login_reward[period] = {};
	end
	if DataMgr.SignInInfo.login_reward[period][day] == nil then
		DataMgr.SignInInfo.login_reward[period][day] = true;
	end
end

-- 角色属性变化通知
function DataMgr.OnRoleAttrChangeNotify(attriType, attriValue, attriTab)
	log("OnRoleAttrChangeNotify attriType:"..attriType..", attriValue:"..attriValue);
	
	if attriType == struct_RoleAttri.attr_type_gold then
		DataMgr.gold = attriValue;
		EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_GOLD_CHANGE, attriValue);
    elseif attriType == struct_RoleAttri.attr_type_ticket then
		DataMgr.ticket = attriValue;
		DataMgr.gen_ticket = attriTab.gen_ticket;
		EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_TICKET_CHANGE, attriValue);
	elseif attriType == struct_RoleAttri.attr_type_fp_token then
		DataMgr.fp_token = attriValue;
		EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_FP_TOKEN_CHANGE, attriValue);
	elseif attriType == struct_RoleAttri.attr_type_diamond then
		DataMgr.diamond = attriValue;
		EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_DIAMOND_CHANGE, attriValue);
	elseif attriType == struct_RoleAttri.attr_type_gold_chip then
		DataMgr.gold_chip = attriValue;
		EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_GOLD_CHIP_CHANGE, attriValue);
	elseif attriType == struct_RoleAttri.attr_type_nation then
		DataMgr.roleData.nation = attriValue;
	elseif attriType == struct_RoleAttri.attr_type_exp then
		DataMgr.roleData.roleExp = attriValue;
		EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_ROLE_EXP_CHANGE, attriValue);
	elseif attriType == struct_RoleAttri.attr_type_level then
        
        BP_LevelUp_OldLevel = DataMgr.roleData.level
		LevelUpSystem.OldLevel = DataMgr.roleData.level
		log("old level: " .. tostring(DataMgr.roleData.level))
		DataMgr.roleData.level = attriValue;
		log("new level: " .. tostring(attriValue))
		EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_ROLE_LEVEL_CHANGE, attriValue);
        
	elseif attriType == struct_RoleAttri.attr_type_signature then
		DataMgr.roleData.signature = attriValue;
        
	elseif attriType == struct_RoleAttri.attr_type_segment then
        
		log("Player Rank Change");
        BP_LevelUp_OldRankPoint = attriTab.old_rating
        BP_LevelUp_NewRankPoint = attriTab.new_rating
        
        UpdateZoneSegementById(attriTab.zone_id, attriTab.segment_type, attriTab.segment_value)
        BP_LevelUp_NewRankLevel = attriTab.segment_value;
        EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ROLE_RANK_CHANGE, attriValue);
        --[[
		if attriTab.segment_type == struct_SegmentType.segment_type_solo then
            
            BP_LevelUp_OldRankLevel = DataMgr.roleData.segment.solo
            
			DataMgr.roleData.segment.solo = attriTab.segment_value;
            EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_ROLE_SOLO_SEG_CHANGE, attriValue);
		elseif attriTab.segment_type == struct_SegmentType.segment_type_double then
            
            BP_LevelUp_OldRankLevel = DataMgr.roleData.segment.double
            
			DataMgr.roleData.segment.double = attriTab.segment_value;
            EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_ROLE_DOUBLE_SEG_CHANGE, attriValue);
		elseif attriTab.segment_type == struct_SegmentType.segment_type_team then
            
            BP_LevelUp_OldRankLevel = DataMgr.roleData.segment.team

			DataMgr.roleData.segment.team = attriTab.segment_value;
            EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_ROLE_TEAM_SEG_CHANGE, attriValue);
		end
        ]]
    elseif attriType == struct_RoleAttri.attr_type_corpsmoney then
    	DataMgr.corps_money = attriValue;
    	EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_CORPS_MONEY_CHANGE, attriValue);
	elseif attriType == struct_RoleAttri.attr_type_credit then
    	DataMgr.roleData.credit = attriValue;
    	EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ROLE_CREDIT, attriValue);
	elseif attriType == struct_RoleAttri.attr_type_season_id then
		DataMgr.season_id = attriValue or 1;
		log("******* season_id OnRoleAttrChangeNotify as " .. DataMgr.season_id)
	elseif attriType == struct_RoleAttri.attr_type_pve_exp then
		DataMgr.roleData.pve_exp = attriValue;

		log("******* attr_type_pve_exp OnRoleAttrChangeNotify: " .. tostring(attriValue))

		EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_PVE_EXP_CHANGE, attriValue);
	elseif attriType == struct_RoleAttri.attr_type_pve_level then
		LevelUpSystem.PveOldLevel= DataMgr.roleData.pve_level
		DataMgr.roleData.pve_level = attriValue;

		log("******* attr_type_pve_level OnRoleAttrChangeNotify old:" .. tostring(LevelUpSystem.PveOldLevel)
		.. ",new:" .. tostring(attriValue))

		EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_PVE_LEVEL_CHANGE, attriValue);
	end
end

--更新已有的segement数据 --wayendong
function UpdateZoneSegementById(zoneId, attrType, segmentValue)
        log("UpdateZoneSegementById, zoneId = "..zoneId..", attrType = "..attrType..", segmentValue = "..segmentValue )
		DataMgr.UpdateZoneSegementZoneId = zoneId
		--- 段位相关   
        -- 第三人称 ----------------------------------
        if attrType == struct_SegmentType.segment_type_solo then
            BP_LevelUp_OldRankLevel = DataMgr.roleData.allzoneSegment[zoneId][enum_SegmentType.solo];
			DataMgr.roleData.allzoneSegment[zoneId][enum_SegmentType.solo] = segmentValue;
			BP_LevelUp_RankModeType = 0
            BP_LevelUp_RankType = 1
            --EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_ROLE_SOLO_SEG_CHANGE, attriValue);
		elseif attrType == struct_SegmentType.segment_type_double then
            BP_LevelUp_OldRankLevel = DataMgr.roleData.allzoneSegment[zoneId][enum_SegmentType.double];
			DataMgr.roleData.allzoneSegment[zoneId][enum_SegmentType.double] = segmentValue
			BP_LevelUp_RankModeType = 0
            BP_LevelUp_RankType = 2
            --EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_ROLE_DOUBLE_SEG_CHANGE, attriValue);
		elseif attrType == struct_SegmentType.segment_type_team then
            BP_LevelUp_OldRankLevel = DataMgr.roleData.allzoneSegment[zoneId][enum_SegmentType.team];
			DataMgr.roleData.allzoneSegment[zoneId][enum_SegmentType.team]  = segmentValue;
			BP_LevelUp_RankModeType = 0
            BP_LevelUp_RankType = 4
            --EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_ROLE_TEAM_SEG_CHANGE, attriValue);

        -- 第一人称 ----------------------------------
		elseif attrType == struct_SegmentType.segment_type_fppsolo then
			
			BP_LevelUp_OldRankLevel = DataMgr.roleData.allzoneSegment[zoneId][enum_SegmentType.fpp_solo];
			DataMgr.roleData.allzoneSegment[zoneId][enum_SegmentType.fpp_solo] = segmentValue;
			BP_LevelUp_RankModeType = 1
            BP_LevelUp_RankType = 1

		elseif attrType == struct_SegmentType.segment_type_fppdouble then
			
			BP_LevelUp_OldRankLevel = DataMgr.roleData.allzoneSegment[zoneId][enum_SegmentType.fpp_double];
			DataMgr.roleData.allzoneSegment[zoneId][enum_SegmentType.fpp_double] = segmentValue;
			BP_LevelUp_RankModeType = 1
            BP_LevelUp_RankType = 2
            
		elseif attrType == struct_SegmentType.segment_type_fppteam then
			
			BP_LevelUp_OldRankLevel = DataMgr.roleData.allzoneSegment[zoneId][enum_SegmentType.fpp_team];
			DataMgr.roleData.allzoneSegment[zoneId][enum_SegmentType.fpp_team] = segmentValue;
			BP_LevelUp_RankModeType = 1
            BP_LevelUp_RankType = 4
		end

        --log_tree("DataMgr.roleData.allzoneSegment[zoneId]", DataMgr.roleData.allzoneSegment[zoneId]);    
end

-- 弹出通用提示框
function DataMgr.ShowMessageBoxByID(msgID)
	local msgConfig = Client.GetTableData("LocalizeRes", msgID);
	
	if msgConfig then
		--CommonMessageBoxUI:ShowPanel(1, "提示", msgConfig.TextValue, nil, nil);
		CommonMessageBoxUI:ShowPanel(1, Client.GetTableData("LocalizeRes",101001).TextValue, msgConfig.TextValue, nil, nil);
	end
end

-- 弹出通用飘字
function DataMgr.ShowNoticeByID(msgID)
	local msgConfig = Client.GetTableData("LocalizeRes", msgID);
	
	if msgConfig then
		PopUpNoticeUI.ShowNewNotice(msgConfig.TextValue);
	end
end

function DataMgr.RemoveAllNotice()
	PopUpNoticeUI.RemoveAllNotice();
end


-- 弹出通用飘字
function DataMgr.ShowNoticeQueueByID(msgID)
	local msgConfig = Client.GetTableData("LocalizeRes", msgID);
	
	if msgConfig then
		PopUpNoticeUI.ShowNewNoticeQueue(msgConfig.TextValue);
	end
end

-- 弹出通用快速飘字
function DataMgr.ShowNoticeFastQueueByID(msgID)
	local msgConfig = Client.GetTableData("LocalizeRes", msgID);
	
	if msgConfig then
		PopUpNoticeUI.ShowFastNoticeQueue(msgConfig.TextValue);
	end
end

-- 弹出通用飘字
function DataMgr.ShowNoticeByString(tipString)
	PopUpNoticeUI.ShowNewNotice(tipString);
end

--读取本地化表的文字
function DataMgr.GetMsgByID(msgID)
	local msgConfig = Client.GetTableData("LocalizeRes", msgID);	
	return (msgConfig == nil and "") or msgConfig.TextValue;
end

function DataMgr.GetMultiLineMsgByID(msgID)
	local str = DataMgr.GetMsgByID(msgID);	
	return (str == nil and "") or string.gsub(str, "\\n", "\n");
end

-- 战斗内文字表
function DataMgr.GetMsgByIDForBattleText(msgID)
	local msgConfig = Client.GetTableData("BattleText", msgID);	
	return (msgConfig == nil and "") or msgConfig.BattleTextValue;
end


-- 获取头像边框路径
function DataMgr.GetPlayerFramePath(rankIntegral)
	local path = "/Game/Arts/UI/Item_Icon/AvatarFrames/Style1/AvatarFrame_";
	local name = "Default";
	local rankIntegralCfg = Client.GetTableData("RankIntegralLevel", rankIntegral);
	if rankIntegralCfg then
		name = tostring(rankIntegralCfg.FrameID);
	end

	return path..name..".AvatarFrame_"..name;
end

-- 获取系统参数
function DataMgr.GetSystemConfig(configName)
	local msgConfig = Client.GetTableData("SystemConfig", configName);
	
	if msgConfig then
		return msgConfig.ConfigValue;
	end
	return nil;
end


-- CE需要修改的参数
function DataMgr.GetFPPOpenLevel()
	local msgConfig = Client.GetTableData("SystemConfig", "FPPOpenLevel");

	if msgConfig then
		return msgConfig.ConfigValue;
	end

	return nil;
end

-- CE需要修改的参数
function DataMgr.GetDestinyModeOpenLevel()
	local msgConfig = Client.GetTableData("SystemConfig", "DestinyModeOpenLevel");

	if msgConfig then
		return msgConfig.ConfigValue;
	end

	return nil;
end

-- CE需要修改的参数
function DataMgr.GetChatWordOpenLv()
	local msgConfig = Client.GetTableData("SystemConfig", "ChatWordOpenLv");

	if msgConfig then
		return msgConfig.ConfigValue;
	end

	return nil;
end

-- CE需要修改的参数
function DataMgr.GetChatRoomOpenLv()
	local msgConfig = Client.GetTableData("SystemConfig", "ChatRoomOpenLv");

	if msgConfig then
		return msgConfig.ConfigValue;
	end

	return nil;
end

-- 通过物品类型获取当前穿戴衣服对应的仓库物品
function DataMgr.GetWearItemByType(itemSubType)
	local itemData = nil;
	
	for k,v in pairs(DataMgr.rolewear) do
		for kk,vv in pairs(DataMgr.arrayHallDepotItemInfo) do
			if v == vv.insID and vv.itemSubType == itemSubType then
				itemData = vv;
				break;
			end
		end
		
		if itemData then
			break;
		end
	end
	
	return itemData;
end

--获取设备信息
function DataMgr.IsEmulator()
	--return true;
	log("InitRoleData isEmulator:" .. tostring(DataMgr.roleData.isEmulator));
	local result = false;
	if DataMgr.roleData ~= nil and DataMgr.roleData.isEmulator ~= nil then
		result  = DataMgr.roleData.isEmulator;
	end
	return result;
end

--是否外设
function DataMgr.IsBLE()
	--当前版本未合入外设判断，直接返回0
	return 0;
	--[[
	local bleDeviceType = BLESystem.BLEDeviceType; --0是无外设，1是BLEType_Keyboard，2是BLEType_Joystick
	local result  = (bleDeviceType ~= 0);
	return result;]]
end

-- 更新任务信息
function DataMgr.ResetTaskData()
	DataMgr.taskData = {
		daily_update_time = 0,
		list = {}	
	}
	DataMgr.taskData.daily_update_time = 3600
	local tbTaskData = Client.GetTable("Task")
	for _, tbTaskInfo in pairs(tbTaskData) do
		if tbTaskInfo.TaskType == TaskType["FIX"] then
			local flag = true
			if GlobalData:IsIOSCheck() then
				flag = flag and (tbTaskInfo.IOSCheck == 1)
			end
			if Client.GetLoginChannel(NetInterface) == BP_ENUM_PLAYFORM_TOURIST then
				flag = flag and (tbTaskInfo.TouristSwitch == 1)
			end
			if flag then
				DataMgr.taskData.list[tbTaskInfo.ID] = {status = 0, progress = 0}
			end
		end
	end
end

function DataMgr.ResetWeekTaskData()
	DataMgr.weekTaskData = {
		week_update_time = 0,
		week_list = {},
	}

	local tb = Client.GetTable("WeekTask")
	--log_tree("[yyc]", tb)
	for _, info in pairs(tb) do
		local flag = true

		-- if GlobalData:IsIOSCheck() then
		-- 	flag = flag and (info.IOSCheck == 1)
		-- end

		-- if Client.GetLoginChannel(NetInterface) == BP_ENUM_PLAYFORM_TOURIST then
		-- 	flag = flag and (info.TouristSwitch == 1)
		-- end

		if flag then
			DataMgr.weekTaskData.week_list[info.ID] = {progress = 0, totalStage = info.TotalStage, detail = {}}

			local cnds = string.split(info.Cond, ";");
			local drops = string.split(info.DropIDs, ";")
			local status = {}
			local dropIds = {}
			for i=1, #cnds do
				if cnds[i] and cnds[i] ~= "" and drops[i] and drops[i] ~= "" then
					local cnd = tonumber(cnds[i])
					DataMgr.weekTaskData.week_list[info.ID].detail[i] = {
						status = 0,
						dropId = tonumber(drops[i]),
						cndId = cnd,
					}
				end
			end
			--log_tree("[yyc] ResetWeekTaskData", DataMgr.weekTaskData)
		end
	end
end

function DataMgr.ResetActivenessData()
	DataMgr.activeness = {
		["WeekActIndexMark"] = 100,

		daily_update_time = 0,
		value = 0,
		list = {},
		week_update_time = 3600,   --服务器用来每周清除的标记
		week_value = 0, --周活跃
		week_list = {}
	}
	DataMgr.activeness.daily_update_time = 3600
	DataMgr.activeness.value = 0
	local taskActiveName = TaskUI.GetTaskActiveTableName()
	local tbActiveData = Client.GetTable(taskActiveName)
	for _, tbActiveInfo in pairs(tbActiveData) do
		if tbActiveInfo.ID < DataMgr.activeness["WeekActIndexMark"] then
			DataMgr.activeness.list[tbActiveInfo.ID] = {status = 0}
		else
			DataMgr.activeness.week_list[tbActiveInfo.ID] = {status = 0}
		end
	end
end
function DataMgr.ResetCorpsTaskData()
	DataMgr.corpsTaskData = 
	{
		list = {}	
	}
	local tbTaskData = Client.GetTable("CorpsTask")
	for _, tbTaskInfo in pairs(tbTaskData) do
		DataMgr.corpsTaskData.list[tbTaskInfo.ID] = {status = 0, progress = 0}
	end
end

function DataMgr.ResetCorpsActivenessData()
	log("$$~~~~~~~~~~~~~~~~~")
	DataMgr.corpsActiveness.list = {}

	local tbActiveData = Client.GetTable("CorpsTaskActive")
	for _, tbActiveInfo in pairs(tbActiveData) do
		if(tbActiveInfo.Star == DataMgr.corpsActiveness.star) then
			DataMgr.corpsActiveness.list[tbActiveInfo.ID] = {status = 0}
		end
	end
	-- log_tree("$$~~~" , DataMgr.corpsActiveness)
end

function DataMgr.ResetOfficerTrainingData(type)
	log("[HHF]DataMgr.ResetOfficerTrainingData, type = " .. tostring(type));
	DataMgr.OfficerTrainingData = 
	{
		taskList = {},
		awardList = {},
	}
	local officerTrainingData = Client.GetTable("FriendCallbackTask")
	for key, data in pairs(officerTrainingData) do
		if data.Type == tonumber(type) then
			-- if key ~= 2004 then --最终宝箱跳过
				DataMgr.OfficerTrainingData.awardList[key] = {first = 1, status = 0, sort = data.Sort}
			-- end
		end
	end

	DataMgr.OfficerTrainingData.CurID = 0
end

function DataMgr.UpdateOfficerTrainingData(data, type)
	DataMgr.ResetOfficerTrainingData(type)
	log("[HHF]DataMgr.UpdateOfficerTrainingData, type = " .. tostring(type));
	local taskID = data.act_ext.cur_actid
	--由于建表比较恶心，这些判断就写死了,当当前任务是最大宝箱时，取第三个任务数据
	if taskID == 2004 then
		taskID = 2003
	end

	if taskID == 1004 then 
		taskID = 1003
	end
	
	for key, task in pairs(data.act) do 
		DataMgr.OfficerTrainingData.awardList[tostring(key) ].first = task.first
		DataMgr.OfficerTrainingData.awardList[tostring(key) ].status = task.status

		if key == taskID then
			for index,subTask in pairs(task.award) do
				DataMgr.OfficerTrainingData.taskList[subTask.idx] = {progress = subTask.num, sort = index}
			end
		end
	end
	DataMgr.OfficerTrainingData.CurID = data.act_ext.cur_actid
	--log_tree("[HHFTEST]DataMgr.UpdateOfficerTrainingData, DataMgr.OfficerTrainingData = ", DataMgr.OfficerTrainingData, "[HHFTEST]")
end

function DataMgr.UpdateOfficerTrainingTaskList(data)
	log("[HHF]DataMgr.UpdateOfficerTrainingTaskList, data = " .. tostring(data));
	for _, act in pairs(data) do 
		for index,subTask in pairs(act.award) do
			DataMgr.OfficerTrainingData.taskList[subTask.idx] = {progress = subTask.num, sort = index}
		end
	end
end

function DataMgr.ChangeOfficerTrainingTaskData(lastIndex, newIndex, index)
	log("[HHF]DataMgr.ChangeOfficerTrainingTaskData, index = " .. tostring(index));
	--log_tree("[HHFTEST]DataMgr.ChangeOfficerTrainingTaskData, before taskList = " , DataMgr.OfficerTrainingData.taskList, "[HHFTEST]")
	DataMgr.OfficerTrainingData.taskList[lastIndex] = nil
	DataMgr.OfficerTrainingData.taskList[newIndex] = {progress = 0 , sort = index}
	--log_tree("[HHFTEST]DataMgr.ChangeOfficerTrainingTaskData, after taskList = " , DataMgr.OfficerTrainingData.taskList, "[HHFTEST]")
end

function DataMgr.UpdateActiveChange(isAll, active)
	if active == nil then
		sandbox.LogError("active can't be nil")
		return
	end
	if isAll then
		DataMgr.ResetActivenessData()
	end
	DataMgr.activeness.daily_update_time = active.daily_update_time
	-- 只需要更新进度，不需要更新状态
	DataMgr.activeness.value = active.value
	DataMgr.activeness.week_update_time = active.week_update_time
	DataMgr.activeness.week_value = active.week_value
	if active.list ~= nil then
		for activenessId, data in pairs(active.list) do
			DataMgr.activeness.list[activenessId] = data
		end
	end
	if active.week_list ~= nil then
		for activenessId, data in pairs(active.week_list) do
			DataMgr.activeness.week_list[activenessId] = data
		end
	end
	EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVENESS_CHANGE)
	TaskUI.RefreshAwradInfo()
end

function DataMgr.UpdateTaskChange(isAll, task)
	--log_tree("=========task change " .. (isAll and "true" or "false"), task)
	if task == nil then
		sandbox.LogError("task can't be nil")
		return
	end
	if isAll == true then
		DataMgr.ResetTaskData()
	end
	if task.daily_update_time then
		DataMgr.taskData.daily_update_time = task.daily_update_time
	end
	
	if task.list then
		for taskId,data in pairs(task.list) do
			local flag = true
			local tbTaskInfo = Client.GetTableData("Task", taskId)
	        if tbTaskInfo ~= nil then 
	            if GlobalData:IsExternalChannel() then
	                flag = flag and (tbTaskInfo.TaskType ~= TaskType["PLATFORM"])
	            end
	            if GlobalData:IsIOSCheck() then
	                flag = flag and (tbTaskInfo.IOSCheck == 1)
	            end
	            if Client.GetLoginChannel(NetInterface) == BP_ENUM_PLAYFORM_TOURIST then
	                flag = flag and (tbTaskInfo.TouristSwitch == 1)
	            end
	            if flag then
	                DataMgr.taskData.list[taskId] = data
	            end
	        end
		end
	end

	DataMgr.ResetWeekTaskData()
	if task.week_list then
		for k,v in pairs(task.week_list) do
			local d = DataMgr.weekTaskData.week_list[k]
			if d then
				d.progress = v.progress
				for index, info in pairs(d.detail) do
					d.detail[index].status = v.status[index] or 0
				end
			end
		end
		EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_WEEK_TASK_CHANGE)
	end
	
	EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_TASK_CHANGE)
	--log_tree(DataMgr.taskData)
	TaskUI.UpdateTaskPanelNoData()
end

function DataMgr.UpdateCorpsAcitveNum(res, member_info)
	if res == nil then
		sandbox.LogError("res can't be nil")
		return
	end

	if res ~= "ok" then
		ShowNotice(res)
		return
	end

	DataMgr.corpsActiveness.value = member_info.member.week_active
	DataMgr.corpsActiveness.star = member_info.corp.chest_star
	-- DataMgr.ResetCorpsActivenessData()
    -- corps data update
    DataMgr.corpsInfo.season_active = member_info.corp.season_active
    DataMgr.corpsInfo.week_active = member_info.corp.week_active
    DataMgr.corpsInfo.day_active = member_info.corp.day_active
    DataMgr.corpsInfo.exp = member_info.corp.exp
    DataMgr.corpsInfo.level = member_info.corp.level

    DataMgr.corpsInfo.selfMember.day_active = member_info.member.day_active
    DataMgr.corpsInfo.selfMember.week_active = member_info.member.week_active
    DataMgr.corpsInfo.selfMember.season_active = member_info.member.season_active

	EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_CORPS_ACTIVENESS_CHANGE)
	-- CorpsTaskUI.RefreshAwradInfo()
	-- log("$$UpdateCorpsAcitveNum ..DataMgr.corpsActiveness" .. DataMgr.corpsActiveness.star .. "::" .. DataMgr.corpsActiveness.value)

end


function DataMgr.UpdateCorpsActiveBoxChange(isAll, active)
	-- log_tree("$$$$$$UpdateCorpsActiveBoxChange" .. (isAll and "true" or "false"), active)
	if active == nil then
		sandbox.LogError("active can't be nil")
		return
	end
	if isAll then
		DataMgr.ResetCorpsActivenessData()
	end

	if active.chest_list ~= nil then
		for activenessId, data in pairs(active.chest_list) do
			DataMgr.corpsActiveness.list[activenessId] = data
			log("$$$$$$...." .. activenessId)
		end
	end
	--log_tree("$$$$$$DataMgr.corpsActiveness", DataMgr.corpsActiveness)
	EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_CORPS_ACTIVENESS_CHANGE)
	-- CorpsTaskUI.RefreshAwradInfo()
end

function DataMgr.UpdateCorpsTaskChange(isAll,task)
	-- log_tree("=========tUpdateCorpsTaskChange" .. (isAll and "true" or "false"), task)
	if task == nil then
		sandbox.LogError("task can't be nil")
		return
	end
	if isAll == true then
		DataMgr.ResetCorpsTaskData()
	end
	
	local loginChanel = Client.GetLoginChannel(NetInterface);
	for taskId,data in pairs(task.task_list) do
		DataMgr.corpsTaskData.list[taskId] = data
	end
	EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_CORPS_TASK_CHANGE)
	-- log_tree(DataMgr.corpsTaskData)
end
--成长任务 DataMgr.levelTask只在此处设置
function DataMgr.ResetLevelTaskData()
	DataMgr.levelTask = {list = {}}
end

function DataMgr.UpdateLevelTaskChange(isAll, levelTask)
	if levelTask == nil then return end
	if isAll == true then
		DataMgr.levelTask = levelTask
	else
		for level, taskInfo in pairs(levelTask.list) do
			DataMgr.levelTask.list[level] = taskInfo
		end
	end
	EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_LEVLE_TASK_CHANGE)
end

function DataMgr.TestProgress(taskId)
end

-- 周签到相关
function DataMgr.InitWeekSignUpList(week_signup)
	if week_signup ~= nil then
		for i = 1, #week_signup.list do
			local wsStatus = week_signup.list[i];
			if wsStatus ~= nil then
				DataMgr.WeekSignUpInfo.AwardState[i] = wsStatus.status;
			end
		end

		DataMgr.WeekSignUpInfo.Resign_times = week_signup.resign_times;
		WeekSignUpSystem.PostUpdateStatus();
	else
		sandbox.LogError("week_signup == nil");
	end
end

function DataMgr.UpdateWeekSignUpInfo(day, state)
	DataMgr.WeekSignUpInfo.AwardState[day] = state;
end


function DataMgr.ResetWeekSignUpInfo()
	DataMgr.WeekSignUpInfo.Resign_times = 0;
	DataMgr.WeekSignUpInfo.AwardState[1] = 1;
	local itemCount = #DataMgr.WeekSignUpInfo.AwardState;
	for i = 2, itemCount do
		DataMgr.WeekSignUpInfo.AwardState[i] = 0;
	end
end
function DataMgr.UpdateShareAwardState(id, state)
	DataMgr.ShareAwardInfo.AwardState[id] = state;
	
	ShareAwardMgr.OnShareAwardInfoUpdate();
end

function DataMgr.UpdateShareChange(share_times)
	--if DataMgr.ShareAwardInfo.share_times < share_times then
		DataMgr.ShareAwardInfo.daily_share_time = FuncUtil.GetServerTimeInSec();
	--end
	
	DataMgr.ShareAwardInfo.share_times = share_times;

	ShareAwardMgr.OnShareAwardInfoUpdate();
end

function DataMgr.SendSubscribeRet()
	-- if DataMgr.wxsubscribe and DataMgr.wxsubscribe == 1 then
	-- 	log("已经订阅")
	-- 	CommonMessageBoxUI:ShowPanel(1, "提示", "已经微信订阅", nil, nil)
	-- 	return
	-- end
	--微信订阅
	log("发送微信订阅")
	NetUtil.SendPkg("set_wxsubscribe_list_req")
end

function DataMgr.SendQQSubscribeRet()
	-- if DataMgr.qqsubscribe and DataMgr.qqsubscribe == 1 then
	-- 	log("已经qq订阅")
	-- 	CommonMessageBoxUI:ShowPanel(1, "提示", "已经qq订阅", nil, nil)
	-- 	return
	-- end
	--qq订阅
	log("发送qq订阅")
	NetUtil.SendPkg("set_qqsubscribe_list_req")
end

function DataMgr.OnSubscribeRet(result)
	if not result then
		CommonMessageBoxUI:ShowPanel(1, "提示", "微信订阅返回nil结果", nil, nil)
		return
	end
	--微信订阅回包
	log("微信订阅回包 result ="..result)

	if result == 0 then
		CommonMessageBoxUI:ShowPanel(1, "提示", "微信订阅成功", nil, nil)
		DataMgr.wxsubscribe = 1
	else
		CommonMessageBoxUI:ShowPanel(1, "提示", "微信订阅错误 错误码 = "..result, nil, nil)
	end
end

function DataMgr.OnQQSubscribeRet(result)
	if not result then
		CommonMessageBoxUI:ShowPanel(1, "提示", "QQ订阅返回nil结果", nil, nil)
		return
	end
	--qq订阅回包
	log("qq订阅回包 result ="..result)

	if result == 0 then
		CommonMessageBoxUI:ShowPanel(1, "提示", "QQ订阅成功", nil, nil)
		DataMgr.qqsubscribe = 1
	else
		CommonMessageBoxUI:ShowPanel(1, "提示", "QQ订阅错误 错误码 = "..result, nil, nil)
	end
end

--------------------------[[活动数据]]----------------------------------
-- 活动数据处理部分放在logic_activity.lua ActivitySystem中
function DataMgr.ResetActivityData()
	DataMgr.activity = {
		isInit = false,
		hashList = {},
		activityMap = {},
		activityListMap = {},
		activityIdMap = {},
		data = {}
	}

	BP_Is_Not_Login = 0;
	log("[HHF]DataMgr.ResetActivityData, Send get_activity_list_req")
	NetUtil.SendPkg("get_activity_list_req")
end

function DataMgr.ResetActGrpData()
	DataMgr.activityGroupList = 
	{
	}

	log("send pkg get_act_gather_list_req")
	ActivityGroupSystem.ReqGetActivityGroupList()
end

function DataMgr.GetActivityByType(activityType)
	for _, activity in ipairs(DataMgr.activity.data) do
		if tonumber(activity.Type) == activityType then
			return activity
		end
	end
	--log("[Error : activity not found on type " .. (activityType or "nil") .. " ]")
	return nil
end

--------------------------[[公告系统]]----------------------------------
function DataMgr.ResetBulletin()
	DataMgr.bulletin = {hashList = {}, data = {}}
    --【【协议请求量优化】登陆协议量整理和优化】 http://tapd.oa.com/iGameInternational/prong/stories/view/1020360302064176571
	--NetUtil.SendPkg("bulletin_get_hashlist_req")
end

function DataMgr.InitBulletin(ret, bulletinList)
	if ret ~= NetErrorCode_NONE then
		ShowNotice(ret)
	else
		DataMgr.bulletin.data = bulletinList
	end
	--log_tree("========initBulletin ret: " .. ret, bulletinList)
	EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_BULLETIN_CHANGE)

end

function DataMgr.InitActivityGroupDataList(dataList)
	local newDataMap = {}
	for key, groupInfo in pairs(dataList) do
		newDataMap[groupInfo.position] = newDataMap[groupInfo.position] or {}
		table.insert(newDataMap[groupInfo.position], groupInfo)
		groupInfo.id = key
	end

	DataMgr.activityGroupList= ActivityGroupSystem.SortDataList(newDataMap)
end

function DataMgr.InitHashList(ret, hashlist)
	local changeList = {}
	for id, hashCode in pairs(hashlist) do
		if DataMgr.bulletin.hashList[id] ~= hashCode then
			table.insert(changeList, id)
		end 
	end

	if #changeList > 0 then
        --【【协议请求量优化】登陆协议量整理和优化】 http://tapd.oa.com/iGameInternational/prong/stories/view/1020360302064176571
		--NetUtil.SendPkg("bulletin_get_list_req", changeList)
	end

	-- del overdue bulletin
	local delList = {}
	for id, _ in pairs(DataMgr.bulletin.hashList) do
		if hashlist[id] == nil then
			table.insert(delList, id)
		end
	end
	for _,id in ipairs(delList) do
		DataMgr.bulletin.hashList[id] = nil
	end
	if #delList > 0 then
		EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_BULLETIN_CHANGE) 
	end

	--log_tree("=======bulletin hashlist", DataMgr.bulletin.hashList)
	DataMgr.bulletin.hashList = hashlist
	--log_tree("=======new hashlist", hashlist)
end
--------------------------[[限时直购]]----------------------------------
function DataMgr.ResetShopLimit()
	DataMgr.shopLimit = {hash = "", buyInfo = {}, template = {}}
	NetUtil.SendPkg("get_direct_buy_list_req")
	NetUtil.SendPkg("get_direct_buy_info_req", {})
end

function DataMgr.InitShopLimitTemplate(template, hash)
	--log_tree("================shop limit template ", template)
	DataMgr.shopLimit.hash = hash
	DataMgr.shopLimit.template = template
	EventSystem:postEvent(EVENTTYPE_SHOPLIMIT, EVENTID_SHOPLIMIT_TEMPLATECHANGE)
end

function DataMgr.InitShopLimitRoleData(buyInfo)
	--log_tree("================shop limit role data ", buyInfo)
	DataMgr.shopLimit.buyInfo = buyInfo
	EventSystem:postEvent(EVENTTYPE_SHOPLIMIT, EVENTID_SHOPLIMIT_BUYINFOCHANGE)
end

--判断有无安装对应的平台APP
function DataMgr.HasInstallPlatApp()
	local result = true;
	if _G.BP_Platform == BP_ENUM_PLAYFORM_WX then

		if Client.IsInstallQQ(NetInterface) == false then 
			--没有安装QQ	
			result = false;
		end

	elseif _G.BP_Platform == BP_ENUM_PLAYFORM_QQ then
		
		if Client.IsInstallWX(NetInterface) == false then 
			--没有安装微信
			result = false;
		end
	end

	return result;
end

function DataMgr.GetMultiLineMsgByID(msgID)
	local str = DataMgr.GetMsgByID(msgID);
	return (str == nil and "") or string.gsub(str, "\\n", "\n");
end


---------------------------intl modify-----------------------------
-- 国际化：游戏内的选服列表zonelist同步
function DataMgr.SyncZoneList(tpingsvr_tab)

	local strRegion = Client.GetPublishRegion() ;

    DataMgr.AllZoneList ={};
    if(tpingsvr_tab ~= nil) then
		for k,v in pairs(tpingsvr_tab) do
			zone_id = v.zone_id;

			-- 日韩版日韩服排第一
			if zone_id == 6 and (strRegion == "KOREA" or strRegion == "JAPAN") then
				table.insert(DataMgr.AllZoneList, 1, zone_id);
			else
				table.insert(DataMgr.AllZoneList, zone_id);
			end
		end
	end 
    --table.insert(DataMgr.AllZoneList, 2);
    --log_tree("--- DataMgr.AllZoneList ",TeamUpSystem.ChooseZoneList);
end
 
function DataMgr.GetOneZoneList()
    for k,v in pairs(DataMgr.AllZoneList) do
        return k;
    end
    return 0;
end


function DataMgr.resetMaxSegmentInfo()
    DataMgr.maxSegmentSolo.zoneid = 0;
    DataMgr.maxSegmentSolo.SegmentLevel = 0;
    DataMgr.maxSegmentDuo.zoneid = 0;
    DataMgr.maxSegmentDuo.SegmentLevel = 0;
    DataMgr.maxSegmentSquad.zoneid = 0;
    DataMgr.maxSegmentSquad.SegmentLevel = 0;

    DataMgr.maxSegmentSoloFpp.zoneid = 0;
    DataMgr.maxSegmentSoloFpp.SegmentLevel = 0;
    DataMgr.maxSegmentDuoFpp.zoneid = 0;
    DataMgr.maxSegmentDuoFpp.SegmentLevel = 0;
    DataMgr.maxSegmentSquadFpp.zoneid = 0;
    DataMgr.maxSegmentSquadFpp.SegmentLevel = 0;
end

function DataMgr.fillMaxSegmentInfo()
    DataMgr.resetMaxSegmentInfo();  
    
    for k, v in pairs(DataMgr.roleData.allzoneSegment) do	
        if DataMgr.maxSegmentSolo.SegmentLevel < DataMgr.roleData.allzoneSegment[k][enum_SegmentType.solo] then
            DataMgr.maxSegmentSolo.zoneid = k
            DataMgr.maxSegmentSolo.SegmentLevel = DataMgr.roleData.allzoneSegment[k][enum_SegmentType.solo]
        end
        if DataMgr.maxSegmentDuo.SegmentLevel < DataMgr.roleData.allzoneSegment[k][enum_SegmentType.double] then
            DataMgr.maxSegmentDuo.zoneid = k
            DataMgr.maxSegmentDuo.SegmentLevel = DataMgr.roleData.allzoneSegment[k][enum_SegmentType.double]
        end
        if DataMgr.maxSegmentSquad.SegmentLevel < DataMgr.roleData.allzoneSegment[k][enum_SegmentType.team] then
            DataMgr.maxSegmentSquad.zoneid = k
            DataMgr.maxSegmentSquad.SegmentLevel = DataMgr.roleData.allzoneSegment[k][enum_SegmentType.team]
        end
        if DataMgr.maxSegmentSoloFpp.SegmentLevel < DataMgr.roleData.allzoneSegment[k][enum_SegmentType.fpp_solo] then
            DataMgr.maxSegmentSoloFpp.zoneid = k
            DataMgr.maxSegmentSoloFpp.SegmentLevel = DataMgr.roleData.allzoneSegment[k][enum_SegmentType.fpp_solo]
        end
        if DataMgr.maxSegmentDuoFpp.SegmentLevel < DataMgr.roleData.allzoneSegment[k][enum_SegmentType.fpp_double] then
            DataMgr.maxSegmentDuoFpp.zoneid = k
            DataMgr.maxSegmentDuoFpp.SegmentLevel = DataMgr.roleData.allzoneSegment[k][enum_SegmentType.fpp_double]
        end
        if DataMgr.maxSegmentSquadFpp.SegmentLevel < DataMgr.roleData.allzoneSegment[k][enum_SegmentType.fpp_team] then
            DataMgr.maxSegmentSquadFpp.zoneid = k
            DataMgr.maxSegmentSquadFpp.SegmentLevel = DataMgr.roleData.allzoneSegment[k][enum_SegmentType.fpp_team]
        end
	end	
	
    --log_tree("DataMgr.maxSegmentSolo",DataMgr.maxSegmentSolo );
    --log_tree("DataMgr.maxSegmentDuo",DataMgr.maxSegmentDuo );
    --log_tree("DataMgr.maxSegmentSquad",DataMgr.maxSegmentSquad );
end

-- 房卡
function DataMgr.InitRoomCardInfo(room_card_info)
	if room_card_info then
		DataMgr.room_card_info.expire_ts = room_card_info.expire_ts;
		DataMgr.room_card_info.rest_times = room_card_info.rest_times;
	else
		DataMgr.room_card_info.expire_ts = 0;
		DataMgr.room_card_info.rest_times = 0;
	end

	-- log_tree("DataMgr.InitRoomCardInfo room_card_info", room_card_info)
	-- log_tree("DataMgr.InitRoomCardInfo DataMgr.room_card_info", DataMgr.room_card_info)
end

function DataMgr.InitRoomCardInfoAdv(room_card_info_adv)
	if room_card_info_adv then
		DataMgr.room_card_info_adv.expire_ts = room_card_info_adv.expire_ts;
		DataMgr.room_card_info_adv.rest_times = room_card_info_adv.rest_times;
	else
		DataMgr.room_card_info_adv.expire_ts = 0;
		DataMgr.room_card_info_adv.rest_times = 0;
	end

	--log_tree("DataMgr.InitRoomCardInfo room_card_info", room_card_info_adv)
	--log_tree("DataMgr.InitRoomCardInfo DataMgr.room_card_info", DataMgr.room_card_info_adv)
end

function DataMgr.InitRoomCardInfoMat(room_card_info_adv)
	if room_card_info_adv then
		DataMgr.room_card_info_mat.expire_ts = room_card_info_adv.expire_ts;
		DataMgr.room_card_info_mat.rest_times = room_card_info_adv.rest_times;
	else
		DataMgr.room_card_info_mat.expire_ts = 0;
		DataMgr.room_card_info_mat.rest_times = 0;
	end

	--log_tree("DataMgr.InitRoomCardInfo room_card_info", room_card_info_adv)
	--log_tree("DataMgr.InitRoomCardInfo DataMgr.room_card_info", DataMgr.room_card_info_adv)
end

--room_card_info = {expire_ts=0 ,rest_times=0}
--item_id:物品表id
function DataMgr.sync_room_card_info(card_type, room_card_info, item_id)
	local dataExpireTs = 0;
	if card_type == nil then
		log_error("DataMgr.sync_room_card_info get nil type")
		return
	elseif card_type == "ordinary" then
		local dataExpireTs = DataMgr.room_card_info.expire_ts;
		DataMgr.InitRoomCardInfo(room_card_info)
	elseif card_type == "advanced" then
		local dataExpireTs = DataMgr.room_card_info_adv.expire_ts;
		DataMgr.InitRoomCardInfoAdv(room_card_info)
	elseif card_type == "match" then
		local dataExpireTs = DataMgr.room_card_info_mat.expire_ts;
		DataMgr.InitRoomCardInfoMat(room_card_info)
	end

	local msg = ""
	if item_id ~= 0 then
		local itemData = Client.GetTableData("Item", item_id)

		if itemData.ItemSubType == 2103 or itemData.ItemSubType == 2106 or itemData.ItemSubType == 2109 then
			local remainTime = dataExpireTs - FuncUtil.GetServerTimeInSec();
			msg = dataExpireTs>=0 and FuncUtil.LocalizeResFormat("9910124", FuncUtil.TimeFormatExtNoZero(remainTime))
				or FuncUtil.GetLocalizeResStr("5012");
		elseif itemData.ItemSubType == 2104 or itemData.ItemSubType == 2107 then
			msg = dataExpireTs>=0 and FuncUtil.LocalizeResFormat("9910125", DataMgr.room_card_info.rest_times)
					or FuncUtil.GetLocalizeResStr("5012");
		elseif itemData.ItemSubType == 2105 or itemData.ItemSubType == 2108 then
			msg = FuncUtil.GetLocalizeResStr("5012");
		end
	end

	if msg ~= "" then
		PopUpNoticeUI.ShowNewNotice(msg);
		BP_CreateRoom_Hot_Point_IsShow = true;
		RoomUI.UpdateRoomHotState()
	end
end

function DataMgr.sync_room_adv_card_info(room_card_info, item_id)
	log_tree("sync_room_card_info_adv card = ",room_card_info);
	log_tree("sync_room_card_info_adv item = ",item_id);
	DataMgr.InitRoomCardInfoAdv(room_card_info);

	local msg = ""
	if item_id ~= 0 then
		local itemData = Client.GetTableData("Item", item_id)
		local dataExpireTs = DataMgr.room_card_info_adv.expire_ts;
		if itemData.ItemSubType == 2106 then
			local remainTime = dataExpireTs - FuncUtil.GetServerTimeInSec();
			msg = dataExpireTs>=0 and FuncUtil.LocalizeResFormat("9910124", FuncUtil.TimeFormatExtNoZero(remainTime))
					or FuncUtil.GetLocalizeResStr("5012");
		elseif itemData.ItemSubType == 2107 then
			msg = dataExpireTs>=0 and FuncUtil.LocalizeResFormat("9910125", DataMgr.room_card_info_adv.rest_times)
					or FuncUtil.GetLocalizeResStr("5012");
		elseif itemData.ItemSubType == 2108 then
			msg = FuncUtil.GetLocalizeResStr("5012");
		end
	end
--TODO:等翻译之后修改
	if msg ~= "" then
		PopUpNoticeUI.ShowNewNotice(msg);
		BP_CreateRoom_Adv_Hot_Point_IsShow = true;
		RoomUI.UpdateRoomHotState()
	end
end

--------------------------[[表情]]----------------------------------
-- 请求同步表情列表
function DataMgr.sync_motion_info_req(isWaitting)
	if isWaitting then
		NetUtil.SendPriorityPkg(false, "sync_motion_info", "sync_motion_info_req");
	else
		NetUtil.SendPkg("sync_motion_info_req");
	end
end

-- 同步表情槽列表
function DataMgr.sync_motion_info(motion_info, limit)
	DataMgr.InitMotionInfo(motion_info, limit)
	EventSystem:postEvent(EVENTTYPE_MOTION, EVENTID_MOTION_UPDATE_SLOT_LIST);
end

function DataMgr.InitMotionInfo(motion_info, limit)
	log("DataMgr.InitMotionInfo limit "..tostring(limit));
	-- log_tree("DataMgr.InitMotionInfo motion_info", motion_info);

	DataMgr.MotionSlotMax = 0;
	DataMgr.MotionSlotList = {};
	if motion_info then
		DataMgr.MotionSlotMax = limit or 0;
		for i=1,motion_info.curr_count or 0 do
			DataMgr.MotionSlotList[i] = tostring(motion_info.motion_slot_list[i] or 0);
		end
	end
end

-- 获取表情物品数据
function DataMgr.GetMotionItemDatas()
	local result = {}
	for i,v in ipairs(DataMgr.MotionSlotList) do
		local itemData = DataMgr.GetValidHallDepotItemDataByInsID(v);
		if itemData then
			table.insert(result, itemData);
		end
	end

	return result;
end

-- 初始化装备数据
function DataMgr.InitWeaponData(weapon_id, skin_insID)
	-- 初始化装备数据
	DataMgr.Weapon_ID = weapon_id or 0;
	DataMgr.Weapon_Skin_InsID = tostring(skin_insID) or "";
end

-- 获取实际穿戴
function DataMgr.GetCurrentWeaponID()
	if DataMgr.Weapon_ID == 0 then
		return 0;
	end

	local weaponID = DataMgr.Weapon_ID;

	local itemData = DataMgr.GetValidHallDepotItemDataByInsID(DataMgr.Weapon_Skin_InsID);
	if itemData then
		weaponID = itemData.resID;
	end
	
	if LobbySystem.LobbyMenuOpenStatus ~= nil and LobbySystem.LobbyMenuOpenStatus[BP_ENUM_WARDROBE_UI_WEAPON] ~= nil then
		local switchInfo = LobbySystem.LobbyMenuOpenStatus[BP_ENUM_WARDROBE_UI_WEAPON].is_open or 0;
		if switchInfo == 0 then
			weaponID = 0
		end
	else
		log("error LobbySystem.LobbyMenuOpenStatus is nil");
	end
	return weaponID;
end

-- 获取大厅显示的头部物品ID（如果是帽子则为0，在时装里穿戴）
function DataMgr.GetHeadShowItemResID(resID)
	local insID = DataMgr.equipmentSkinInsIDTable[DataMgr.HelmetSkinTableIndex]
	local itemCfg = DataMgr.GetHallDepotItemDataByInsID(insID)
	if(itemCfg ~= nil) then
		if itemCfg.res_id == resID then
			log("Current HeadShow is Helment, resID is " .. resID)
			return resID;
		else
			log("Current HeadShow is Hat");
			return 0;
		end
	else
		return 0;
	end
end

function DataMgr.GetEquipmentResID(subType)
	local itemCfg = DataMgr.GetHallDepotItemDataByInsID(DataMgr.equipmentSkinInsIDTable[subType]);
	if(itemCfg) then
		log("itemCfg.res_id".. itemCfg.resID);
		return itemCfg.resID;
	end
	return 0;
end
 
function DataMgr.GetEquipmentItemIDByResID(level, itemResID)
	log("GetEquipmentItemIDByResID");
	log("level: " .. level)
	log("itemResID: " .. itemResID)
	local itemMappingCfg = Client.GetTableData("BackpackMapping", itemResID)
	log_tree("itemMappingCfg", itemMappingCfg);
	if itemMappingCfg ~= nil then
		if level == 1 then
			return itemMappingCfg.SkinItemIDLv1;
		elseif level == 2 then
			return itemMappingCfg.SkinItemIDLv2;
		elseif level == 3 then
			return itemMappingCfg.SkinItemIDLv3;
		end
	end
	return 0;
end

-- 日本版本年龄信息
function DataMgr.InitJPAgeInfo(jp_age)
	if jp_age ~= nil then
		log("IDataMgr.InitJPAgeInfo jp_age=" .. tostring(jp_age));
		DataMgr.jp_age = jp_age;
	else
		log("IDataMgr.InitJPAgeInfo jp_age=nil");
		DataMgr.jp_age = nil;
	end
end

function DataMgr.IsEnableWatch()
	return DataMgr.roleData.enableWatch
end

function DataMgr.SetEnableWatch(enable)
	DataMgr.roleData.enableWatch = enable
end

function DataMgr.SetCanWatchBaseInfoIngame(canWatch)
	DataMgr.roleData.watch_privacy = canWatch
end

function DataMgr.IsCanWatchBaseInfoIngame()
	return DataMgr.roleData.watch_privacy
end

function DataMgr.GetCanWatchInvite()
	return DataMgr.roleData.enable_watch_remind
end

--查询新手状态
function DataMgr.InitNewbieGuide()
	log("DataMgr.InitNewbieGuide");
	NetUtil.SendPkg("get_newbie_guide_req");
end

function DataMgr.SetNewbieGuide(module_id, key)
	log("DataMgr.SetNewbieGuide module_id:"..module_id.."  key:"..key);
	if DataMgr.newbieGuide[module_id] == nil then
		DataMgr.newbieGuide[module_id] = {}
	end
	DataMgr.newbieGuide[module_id][key] = 1;
	NetUtil.SendPkg("set_newbie_guide_req", module_id, key, 1);
end

function DataMgr.HaveNewbieGuide(module_id, key)
	if DataMgr.newbieGuide[module_id] ~= nil then
		local tempModule = DataMgr.newbieGuide[module_id];
		if tempModule[key] ~= nil and tempModule[key] == 1 then
			return false;
		else
			return true;
		end
	else 
		return true;
	end
end

-- 自带参数的新手引导
function DataMgr.SetNewbieGuideValue(module_id, key, val)
	log("DataMgr.SetNewbieGuide module_id:"..module_id.."  key:"..key);
	if DataMgr.newbieGuide[module_id] == nil then
		DataMgr.newbieGuide[module_id] = {};
	end
	DataMgr.newbieGuide[module_id][key] = val;
	NetUtil.SendPkg("set_newbie_guide_req", module_id, key, val);
end

-- 获取新手引导的自定义数值
function DataMgr.GetNewbieGuideValue(module_id, key)
	if DataMgr.newbieGuide[module_id] ~= nil then
		local tempModule = DataMgr.newbieGuide[module_id];
		if tempModule[key] ~= nil then
			return tempModule[key];
		end
	end
	return nil;
end

function DataMgr.on_get_newbie_guide_rsp(err_code, newbie_guide)
	log("DataMgr.on_get_newbie_guide_rsp err_code: "..err_code);
	if err_code == 0 then 
		log_tree("newbie_guide", newbie_guide);
		DataMgr.newbieGuide = newbie_guide;
        EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_UPDATE_NEWBIE_STATUS);
	end
	
    --刷新大厅新手引导状态
    LobbySystem.UpdateLobbyNewbieState();
end

function DataMgr.on_set_newbie_guide_rsp(err_code, module_id, key, value, newbie_guide)
	log("DataMgr.on_set_newbie_guide_rsp err_code: "..err_code);
	if err_code == 0 then
		log_tree("newbie_guide", newbie_guide);
		DataMgr.newbieGuide = newbie_guide;
        EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_UPDATE_NEWBIE_STATUS);
	end
end

-- 聊天第一、第二语言同步包
function DataMgr.send_player_langs(lang, maxTeamRecruitDelayTime)
	log("DataMgr.send_player_langs: "..tostring(lang[1]).." "..tostring(lang[2]).." delay: "..tostring(maxTeamRecruitDelayTime));
	DataMgr.FirstSecondLanguage = lang;
	LobbyChatSystem.maxTeamRecruitDelayTime = maxTeamRecruitDelayTime or 300;	-- 默认值设置为300
	LobbyChatSystem.topic_fetch_lang_list_req();
end

-- 匹配第一、第二语言、相关参数同步包
function DataMgr.sync_match_param(lang, cross_time, cross_max_ping, zoneList)
	log("DataMgr.sync_match_param: "..tostring(lang[1]).." "..tostring(lang[2]).." "..tostring(cross_time).." ".. tostring(cross_max_ping));
	DataMgr.MatchLanguage = lang;
	MatchPopupUI.SetMatchParam(cross_time, cross_max_ping, zoneList);
end

---------------------------intl modify-----------------------------

---------------------------战队商店-----------------------------
-- 数据变更通知
function DataMgr.carteam_coin_count_notify_chg(value, cur_carteam_coin_count, reason)
	log("DataMgr.carteam_coin_count_notify_chg: "..tostring(value).." "..tostring(cur_carteam_coin_count).."  "..tostring(reason));

	DataMgr.carteam_coin_count = cur_carteam_coin_count;
	--LeagueGameSystem.LeagueId = reason;
end
---------------------------战队商店 End-----------------------------


--------------------------[[网络通知]]----------------------------------
s2c["notify_depot_item_change"] = DataMgr.OnHallDepotDataNotify;
s2c["notify_roleattr_change"] = DataMgr.OnRoleAttrChangeNotify;
-- 任务系统
s2c["activeness_notify_chg"] = DataMgr.UpdateActiveChange
s2c["task_notify_chg"] = DataMgr.UpdateTaskChange
s2c["level_task_notify_chg"] = DataMgr.UpdateLevelTaskChange
-- 分享
s2c["share_notify_chg"] = DataMgr.UpdateShareChange
-- 活动系统

--微信订阅
s2c["set_wxsubscribe_list_res"] = DataMgr.OnSubscribeRet
s2c["set_qqsubscribe_list_res"] = DataMgr.OnQQSubscribeRet

-- 公告系统
s2c["bulletin_get_hashlist_res"] = DataMgr.InitHashList
s2c["bulletin_get_list_res"] = DataMgr.InitBulletin

--活动页
s2c["get_act_gather_list_res"] = DataMgr.InitActivityGroupDataList

--限时直购
s2c["get_direct_buy_list_res"] = DataMgr.InitShopLimitTemplate
s2c["get_direct_buy_info_res"] = DataMgr.InitShopLimitRoleData

-- 军团任务系统
s2c["corps_task_chg"] = DataMgr.UpdateCorpsTaskChange
s2c["corp_member_notify"] = DataMgr.UpdateCorpsAcitveNum;

--房卡
s2c["sync_room_card_info"] = DataMgr.sync_room_card_info
s2c["sync_room_adv_card_info"] =  DataMgr.sync_room_adv_card_info

-- 表情
s2c["sync_motion_info"] = DataMgr.sync_motion_info

-- 新手引导通用协议
s2c["get_newbie_guide_rsp"] = DataMgr.on_get_newbie_guide_rsp

-- 设置新手状态的回包
s2c["set_newbie_guide_rsp"] = DataMgr.on_set_newbie_guide_rsp

-- 聊天第二语言同步包
s2c["send_player_langs"] = DataMgr.send_player_langs

-- 匹配第一、第二语言、相关参数同步包
s2c["sync_match_param"] = DataMgr.sync_match_param;			

-- 战队商店
s2c["carteam_coin_count_notify_chg"] = DataMgr.carteam_coin_count_notify_chg