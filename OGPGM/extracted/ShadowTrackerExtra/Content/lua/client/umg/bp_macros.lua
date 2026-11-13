--全局宏定义
Macros = Macros or
{
}

--注册Widget
function bp_macros_RegisterUI()
    --jaysun。某开发起个名字为bp_,导致_RegisterUI确实，C++调用会有warning。而且bp_macros，会有很多BP_数据在蓝图和lua同步。
    --nothing to do。为了消除warning日志

end

--玩家游戏性别
BP_ENUM_GENDER_MALE = 1;
BP_ENUM_GENDER_FEMALE = 2;

--平台定义
BP_ENUM_PLAYFORM_MORE = 0;			--More
BP_ENUM_PLAYFORM_WX = 1;			--微信
BP_ENUM_PLAYFORM_QQ = 2;			--QQ->Facebook
BP_ENUM_PLAYFORM_TOURIST = 5;		--Guest
BP_ENUM_PLAYFORM_GAMECENTER = 40  	--GameCenter 
BP_ENUM_PLAYFORM_GOOGLEPLAY = 41  	--GooglePlay 
BP_ENUM_PLAYFORM_TWITTER = 42  		--Twitter 
BP_ENUM_PLAYFORM_VK = 43;			--vk 
BP_ENUM_PLAYFORM_LINE = 44;			--Line 
BP_ENUM_PLAYFORM_QQByiTOP = 45;     --qq

BP_ENUM_IMSDK_CHANNEL_FACEBOOK = 1;			 
BP_ENUM_IMSDK_CHANNEL_GAMECENTER = 2;			 
BP_ENUM_IMSDK_CHANNEL_GOOGLEPLAY = 3;		 
BP_ENUM_IMSDK_CHANNEL_WECHAT = 4;			
BP_ENUM_IMSDK_CHANNEL_GUEST = 5;
BP_ENUM_IMSDK_CHANNEL_VK = 14; 
BP_ENUM_IMSDK_CHANNEL_TWITTER = 35;  	
BP_ENUM_IMSDK_CHANNEL_LINE = 36;  
BP_ENUM_IMSDK_CHANNEL_QQ = 31;

--启动类型 0:普通 1：手Q游戏中心 2: 微信游戏中心
BP_ENUM_STARTUPTYPE_COMM = 0;
BP_ENUM_STARTUPTYPE_QQGAME = 1;
BP_ENUM_STARTUPTYPE_WXGAME = 2;

--登录失败尝试限制
BP_ENUM_LOGINLIMIT_COUNT1 = 3;
BP_ENUM_LOGINLIMIT_COUNT2 = 6;
BP_ENUM_LOGINLIMIT_TIME1 = 10;
BP_ENUM_LOGINLIMIT_TIME2 = 300;

--ui层级
BP_ENUM_UI_TEAMUP_MODEL_ZORDER = 10;	-- 模式选择页面
BP_ENUM_UI_SELECTMAP_ZORDER = 100;		-- 模式地图选择页面
BP_ENUM_UI_SELECTMATCHINFO_ZORDER = 100;
BP_ENUM_UI_DIRECT_PURCHASE_ZORDER = 40;	-- 直购
BP_ENUM_UI_SHOP_ZORDER = 42;
BP_ENUM_UI_DIRECT_PRUCHASE_ZORDER = 50;
BP_ENUM_UI_ResetRole = 40
BP_ENUM_UI_WARDROBE_ZORDER = 41;
BP_ENUM_UI_TASK_ZORDER = 100;
BP_ENUM_UI_ACTIVITY_ZORDER = 42;
BP_ENUM_UI_UISetting_ZORDER = 45;	--设置界面
BP_ENUM_UI_FRIEND_ZORDER = 50;
BP_ENUM_UI_MAIL_ZORDER = 42;
BP_ENUM_UI_RANK_ZORDER = 42;
BP_ENUM_UI_SEASON_ZORDER = 42;
BP_ENUM_UI_SEASON_REVIEW_ZORDER = 43;
BP_ENUM_UI_WARZONE_RANK_ZORDER = 43;
BP_ENUM_UI_WARZONE_STRONGER_RANK_ZORDER = 44;
BP_ENUM_UI_RECHARGE_ZORDER = 70;
BP_ENUM_UI_ALLIANCE_ZORDER = 38;
BP_ENUM_UI_ROOM_LIST_ZORDER = 35;
BP_ENUM_UI_ROOM_WAITING_ZORDER = 45;
BP_ENUM_UI_CHAT_ENTRANCE_ZORDER = 37;
BP_ENUM_UI_CHAT_ZORDER = 39;
BP_ENUM_UI_COME_BACK_ZORDER = 40;
BP_ENUM_UI_CHAT_TOPIC_LANGUAGE_ZORDER = 40;
BP_ENUM_UI_CHAT_SHARE_ZORDER = 42;
BP_ENUM_UI_CHAT_LANGUAGE_SELECT = 101;	--选择第二语言
BP_ENUM_UI_OFFICIAL_INFO = 41;
BP_ENUM_UI_RECRUIT_ZORDER = 45;
BP_ENUM_UI_Alliance_Recruit = 46; --车队招募和申请列表
BP_ENUM_UI_Share_Day_ZORDER = 50;
BP_ENUM_UI_PROMOTION_ZORDER = 50;
BP_ENUM_UI_REFLUX_TRAINING_ZORDER = 50;
BP_ENUM_UI_REFLUX_TRAINING_AWARD_ZORDER = 60;
BP_ENUM_UI_FACETEAM_ZORDER = 51;
BP_ENUM_UI_OFFICIAL_INFO = 51;
BP_ENUM_UI_PDD_SYSTEM = 40;
BP_ENUM_UI_Share_HonorWall_ZORDER = 100;
BP_ENUM_UI_Share_Day_Fianly_ZORDER = 101;
BP_ENUM_UI_Share_cjhb_ZORDER = 111;	--春节红包
BP_ENUM_UI_SHare_normal_cjhb_ZORDER = 112;	--吃鸡红包
BP_ENUM_UI_Share_Achievement_ZORDER = 113;	--个人成就
BP_ENUM_UI_Share_SeasonResult_ZORDER = 113;	--赛季结果分享
BP_ENUM_UI_AllRedPacket_ZORDER = 53;
BP_ENUM_UI_Share_Game_Result_ZORDER = 60;	--结算结分享
BP_ENUM_UI_Share_PersonInfo = 101;
BP_ENUM_UI_NOTICEBOX_ZORDER = 80;
BP_ENUM_UI_NOTICE_ZORDER = 39;
BP_ENUM_UI_SIGNIN_ZORDER = 49;
BP_ENUM_UI_EIGHTDAY_ZORDER = 50;
BP_ENUM_UI_BINDFB_ZORDER = 51;
BP_ENUM_UI_THEFIRSTCHARGE_ZORDER = 51; --首充有礼
BP_ENUM_UI_ACTIVITYINVITETEAM_ZORDER = 51;--组队邀请活动
BP_ENUM_UI_HALLOWEEN_VEHICLE_ZORDER = 49;--万圣节载具升级
BP_ENUM_UI_ICE_LUCKY_ZORDER = 51;--冰雪节幸运夺宝
BP_ENUM_UI_SCROLLMSG_ZORDER = 98;    -- 跑马灯
BP_ENUM_UI_ROLEINFO_ZORDER = 99;
BP_ENUM_UI_COMMON_ITEM_LIST_ZORDER = 100; -- 通用物品列表
BP_ENUM_UI_COMMON_ITEM_GET_ZORDER = 103;
BP_ENUM_UI_OPEN_BOX_ZORDER = 100;
BP_ENUM_UI_GOOD_ITEM_GET_ZORDER = 104;
BP_ENUM_UI_LEVEL_UP_ZORDER = 105;
BP_ENUM_UI_SHARE_ITEM_ZORDER = 110;
BP_ENUM_UI_SHARE_RANK_ZORDER = 110;
BP_ENUM_UI_COMMON_RIGHT_NOTIFY_ZORDER = 190;
BP_ENUM_UI_APPRAISE_ZORDER = 191;
BP_ENUM_UI_RECONNECT_WAITING_ZORDER = 199;
BP_ENUM_UI_COMMON_MESSAGEBOX_ZORDER = 200;
BP_ENUM_UI_LIVE_BROADCAST_ZORDER = 999;

BP_ENUM_UI_OB_RESULT_TITLE_ZORDER = 42;
BP_ENUM_UI_OB_RESULT_TITLE_MORE_DETAIL_ZORDER = 50;

BP_ENUM_UI_COMMON_ITEMTIPS_ZORDER = 9999
BP_ENUM_UI_TEAMUP_INVITE_ZORDER = 190;

BP_ENUM_UI_SHAREAWARD_ZORDER = 47;
BP_ENUM_UI_LOBBY_PLATFORM_ZORDER = 150;
BP_ENUM_UI_ACTIVITY_GROUP_ZORDER = 999;
BP_ENUM_UI_SHOPLIMIT_ZORDER = 30;
BP_ENUM_UI_REVISE_NAME = 100;
BP_ENUM_UI_COMMON_USEITEMS = 150;
BP_ENUM_UI_OWN_CORPS_ZORDER = 39;
BP_ENUM_UI_CORPS_HOMEPAGE_ZORDER = 40;
BP_ENUM_UI_CORPS_INFO_ZORDER = 40;
BP_ENUM_UI_CORPS_ZORDER = 42;
BP_ENUM_UI_CORPS_Invitation = 44;
BP_ENUM_UI_CORPS_AUTO_INVITE_ZORDER = 44;
BP_ENUM_UI_CORPS_ModifyAnnouncement = 99;
BP_ENUM_UI_BLOCK_ZORDER = 10000;
BP_ENUM_UI_UNKNKOW_PASS_ZORDER = 103;
BP_ENUM_UI_UNKNKOW_PASS_POPUP_ZORDER = 104;
BP_ENUM_UI_COMMON_TREASUREBOXPOPUP_ZORDER = 104;
BP_ENUM_UI_SETTING_LAYOUT_ZORDER = 60;
BP_ENUM_UI_WEFLARE_SHARE_TIP = 900;
BP_ENUM_UI_LEAGUEGAME_LOBBY = 39;
BP_ENUM_UI_URGENT_NOTICE_BOX = 40;
BP_ENUM_UI_LOBBY_LEAGUEGAME_ENTRANCE = 50;
-- TOP layer
BP_ENUM_TOP_UI_DEVICE_NOTICE_ZORDER = 0;
BP_ENUM_TOP_UI_NEWER_GUIDE_ZORDER = 5;
BP_ENUM_UI_SHARE_PANDORA_ZORDER = 55; --潘多拉分享

--AVATAR部件
BP_ENUM_AVATAR_HEAD = 400;
BP_ENUM_AVATAR_FACE = 402;
BP_ENUM_AVATAR_CLOTH = 403;
BP_ENUM_AVATAR_PANT = 404;
BP_ENUM_AVATAR_SHOE = 405;
BP_ENUM_AVATAR_HAIR = 406;

--商城商品类型
BP_ENUM_SHOP_TYPE_AVATAR = 4;
BP_ENUM_SHOP_TYPE_CHEST = 10;

--商城商品子类型
BP_ENUM_SHOP_SUB_TYPE_HEAD = 1;
BP_ENUM_SHOP_SUB_TYPE_FACE = 1;

--需要获取概要数据的系统（根据post的类型各系统自行处理概要数据）
BP_PROFILE_MSG_TYPE_FRIEND = 1001;
BP_PROFILE_MSG_TYPE_RANK = 1002;
BP_PROFILE_MSG_TYPE_ROLEINFO = 1003;
BP_PROFILE_MSG_TYPE_CHATROOM = 1004;

--需要获取战绩数据的系统
BP_COMBAT_MSG_TYPE_ROLEINFO = 2001;
BP_COMBAT_MSG_TYPE_SEASON = 2002;
--测试宏
BP_ENUM_TEST = "TEST";

-- 大厅面板ID
BP_ENUM_LOBBY_MENU_RANK = 10001;
BP_ENUM_LOBBY_MENU_WARDROBE = 10002;
BP_ENUM_LOBBY_MENU_SHOP = 10003;
BP_ENUM_LOBBY_MENU_FRIEND = 10004;
BP_ENUM_LOBBY_MENU_MAIL = 10005;
BP_ENUM_LOBBY_MENU_SETTING = 10006;
BP_ENUM_LOBBY_MENU_WORLDVIEW = 10007;
BP_ENUM_LOBBY_MENU_HELP = 10008;
BP_ENUM_LOBBY_MENU_CHAT = 10009;
BP_ENUM_LOBBY_MENU_ALLIANCE = 10010;
BP_ENUM_LOBBY_MENU_SEASON = 10011;
BP_ENUM_LOBBY_MENU_ROOM = 10012;
BP_ENUM_LOBBY_MENU_TEACHING = 10013;
BP_ENUM_LOBBY_MENU_TASK = 10014;
BP_ENUM_LOBBY_MENU_ACTIVITY = 10015;
BP_ENUM_LOBBY_MENU_ROLE_INFO = 10017;
BP_ENUM_LOBBY_MENU_BROADCAST = 10018; -- 直播
BP_ENUM_LOBBY_MENU_CORPS = 10019;
BP_ENUM_LOBBY_MENU_FPP = 10020;
BP_ENUM_LOBBY_MENU_ARMORY = 10021;
BP_ENUM_LOBBY_MENU_WATCHING = 10022;
BP_ENUM_LOBBY_MENU_WATCHING_PRIVACY = 10023;
BP_ENUM_LOBBY_MENU_WATCHER_LIST = 10024;
BP_ENUM_LOBBY_MENU_WATCHING_BATTLE_BASEINFO = 10028;
BP_ENUM_LOBBY_MENU_WATCHING_BATTLE_DETAILBTN = 10029;
BP_ENUM_LOBBY_MENU_WATCHING_INVITE = 10032; --举报推荐开启


BP_ENUM_LOBBY_MENU_MALL = 10501;--商城系統
BP_ENUM_LOBBY_MENU_ENCHARGE = 10502;--充值
BP_ENUM_LOBBY_MENU_SHOP_BOX = 10503;--开箱子
BP_ENUM_LOBBY_MENU_PURCHASE = 10504;--直购
BP_ENUM_LOBBY_MENU_PURCHASE_BOX = 10505;--直购宝箱
BP_ENUM_LOBBY_MENU_PURCHASE_MONTH_CARD = 10506;--月卡
BP_ENUM_LOBBY_MENU_UNKNOW_PASS = 10600;--绝地通行证系統
BP_ENUM_LOBBY_MENU_WATCH_CHAIN = 10027; -- 观战链
BP_ENUM_LOBBY_MENU_PDD_SYSTEM = 10700;--拼多多系统
BP_ENUM_LOBBY_MENU_SUBSCRIBE_SYSTEM = 10703;--订阅系统
BP_ENUM_LOBBY_MENU_LEAGUEGAME_SYSTEM = 10800;--赛事系统
BP_ENUM_LOBBY_MENU_LEAGUEGAME_BROADCAST = 10801;--赛事直播入口
BP_ENUM_LOBBY_MENU_LEAGUEGAME_JUMPMALL = 10802;--赛事跳转商城
BP_ENUM_LOBBY_MENU_LEAGUEGAME_SCHEDULE = 10803;--赛事规则
BP_ENUM_LOBBY_MENU_LEAGUEGAME_BROADCASTONLINE = 10804;--赛事线上赛直播入口
BP_ENUM_LOBBY_MENU_LEAGUEGAME_SEAMATCHDETAIL = 10805;--赛事海选赛时间详情
BP_ENUM_LOBBY_MENU_INDIA_CHAMPIONSHIP_SYSTEM = 10806;--印度锦标赛
BP_ENUM_LOBBY_MENU_NEW_SUPPLY = 120002;	--新版补给
BP_ENUM_STORE_LEVEL_UP = 120003;	--新版商城内升级显示
BP_ENUM_TEAMUP_ENTER = 80006       --生存入口

-- 战斗胜利时刻
BP_ENUM_BATTLE_WINNER_TIME = 10601;--绝地通行证系統

-- 战斗命中反馈
BP_ENUM_SURVIVE_COMBAT_HIT_FEEDBACK = 10100;
--QQ
BP_ENUM_LOBBY_MENU_PLATFORM_ACTIVITYBTNLIST = 20001;
BP_ENUM_LOBBY_MENU_PLATFORM_QQ_COMMUNITY = 20002;
BP_ENUM_LOBBY_MENU_PLATFORM_QQ_GAMEGROUP = 20003;
BP_ENUM_LOBBY_MENU_PLATFORM_QQVIP = 20004;
BP_ENUM_LOBBY_MENU_PLATFORM_QQ_START = 20005;
BP_ENUM_LOBBY_MENU_PLATFORM_QQ_LIVE = 20006;
BP_ENUM_LOBBY_MENU_PLATFORM_QQ_ESPORTS = 20007;
BP_ENUM_LOBBY_MENU_PLATFORM_QQ_XINYUE = 20008;
BP_ENUM_LOBBY_MENU_PLATFORM_QQ_LIULIANG = 20009;
BP_ENUM_LOBBY_MENU_PLATFORM_GIFTCENTER = 20010;
BP_ENUM_LOBBY_MENU_PLATFORM_QQ_HUATIQUAN = 20011;
--WX
BP_ENUM_LOBBY_MENU_PLATFORM_WX_COMMUNITY = 20012;
BP_ENUM_LOBBY_MENU_PLATFORM_WX_GAMEGROUP = 20013;
BP_ENUM_LOBBY_MENU_PLATFORM_WX_START = 20014;
BP_ENUM_LOBBY_MENU_PLATFORM_WX_LIVE = 20015;
BP_ENUM_LOBBY_MENU_PLATFORM_WX_ESPORTS = 20016;
BP_ENUM_LOBBY_MENU_PLATFORM_WX_XINYUE = 20017;
BP_ENUM_LOBBY_MENU_PLATFORM_WX_LIULIANG = 20018;
BP_ENUM_LOBBY_MENU_PLATFORM_WX_HUATIQUAN = 20019;

-- 军团主面板按钮ID
BP_ENUM_CORPS_UI_MAIN 			= 30001;
BP_ENUM_CORPS_UI_BASE_INFO 		= 30002;
BP_ENUM_CORPS_UI_MISSION 		= 30003;
BP_ENUM_CORPS_UI_MALL	 		= 30004;
BP_ENUM_CORPS_UI_RANK 			= 30005;
BP_ENUM_CORPS_UI_MERIT 			= 30006;
BP_ENUM_CORPS_UI_COMPETITION 	= 30007;
BP_ENUM_CORPS_UI_TRAINING		= 30008;
BP_ENUM_CORPS_UI_RECRUIT		= 30009;
BP_ENUM_CORPS_UI_GROUP			= 30010;
BP_ENUM_CORPS_UI_PLATFORMINVITE = 30011;
BP_ENUM_CORPS_UI_WELFARE		= 30012;

-- 提审屏蔽
BP_ENUM_EXAMINE_UI_WEAK_SIGNUP	= 50001;	--周签到
BP_ENUM_EXAMINE_UI_EIGHT_DAY	= 50002;	--新兵8天
BP_ENUM_EXAMINE_UI_NEWS_NOTIFY	= 50003;	--news通知
BP_ENUM_EXAMINE_UI_ITOP_NOTIFY	= 50004;	--拍脸图公告
--50005被 礼物赠送功能开关占用
BP_ENUM_EXAMINE_UI_COME_BACK	= 50006;	--回流玩家


-- 绝地战区开关ID
BP_ENUM_WARZONE_MAIN = 70005
-- 排行榜总入口开关
BP_ENUM_LOBBY_MENU_NEW_RANK = 70004
-- 房主观战入口开关
BP_ENUM_ANCHOR_OB = 70014
-- 线上赛事开关
BP_ENUM_ONLINE_EVENT = 70015

--个人空间关系界面
BP_ENUM_PERSONSPACE_PARTNERSETTING = 70020

--宠物总开关ID
BP_ENUM_PET_SWITCH = 70019

-- 战区面板ID
-- BP_ENUM_WARZONE_RANK = 90002
-- BP_ENUM_WARZONE_FRIEND_RANK = 90003
-- BP_ENUM_WARZONE_STREET_RANK = 90004
BP_ENUM_WARZONE_SHARE = 90005
BP_ENUM_WARZONE_TOP_RANK = 90006
BP_ENUM_WARZONE_CHINA_TOP_RANK = 90007
BP_ENUM_WARZONE_TITLE = 90008
BP_ENUM_WARZONE_LOCATE_UI = 90009
BP_ENUM_WARZONE_PLAYERNUM = 90010

-- 仓库面板开关
BP_ENUM_WARDROBE_UI_WEAPON = 31001;

-- 回流系统开关表
BP_ENUM_COME_BACK_LOGIN_AWARD = 32001
BP_ENUM_COME_BACK_NOTIFY_FRIENDS = 32002
BP_ENUM_COME_BACK_FIRST_GAME = 32003
BP_ENUM_COME_BACK_TASK = 32004

--结算的攻略按钮id
BP_ENUM_BATTLERESULT_STRATEGYBTN = 40001;

--是否开启潘多拉功能
BP_ENUM_PANDORA_OPEN = 60003;


BP_ENUM_LOBBY_MENU_PLATFORM_TOURIST_LIVE = 20020;
BP_ENUM_LOBBY_MENU_ROLEIFNO_CREDITPOINT = 20028;
-- 从哪里加好友
BP_ENUM_ADD_FRIEND_FROM_FRIEND_SEARCH = 20001;
BP_ENUM_ADD_FRIEND_FROM_CHAT = 20002;
BP_ENUM_ADD_FRIEND_FROM_TEAM = 20003;
BP_ENUM_ADD_FRIEND_FROM_ROLE_INFO = 20004;
BP_ENUM_ADD_FRIEND_FROM_BATTLE_RESULT = 20005;
BP_ENUM_ADD_FRIEND_FROM_ALLIANCE = 20006;
BP_ENUM_ADD_FRIEND_FROM_CORPS = 20007;
BP_ENUM_ADD_FRIEND_FROM_TEAMRECRUIT = 20008;

-- 下面补充国内合漏的
BP_ENUM_ADD_FRIEND_FROM_FRIEND_RECENTTEAMMATE = 20009;
BP_ENUM_ADD_FRIEND_FROM_FRIEND_NEARBY = 20010;
BP_ENUM_ADD_FRIEND_FROM_OB_PLAYER_INFO = 20011;

BP_ENUM_LOBBY_MENU_MATCHINFO_SAME_LANGUAGE = 910001;	-- 组队匹配同语言显示

BP_ENUM_VNG_OPENMARK = 80002;

-- 外显升级
BP_ENUM_ITEM_UPGRADE = 120001;	-- 外显升级开关

--模块ID
BP_ENUM_MODULE_LOBBY = 1000000;
BP_ENUM_MODULE_RANK = 1000100;
BP_ENUM_MODULE_WARDROBE = 1000200;
BP_ENUM_MODULE_SHOP = 1000300;
BP_ENUM_MODULE_FRIEND = 1000400;
BP_ENUM_MODULE_MAIL = 1000500;
BP_ENUM_MODULE_SETTING = 1000600;
BP_ENUM_MODULE_WORLDVIEW = 1000700;
BP_ENUM_MODULE_TASK = 1000800;
BP_ENUM_MODULE_WEEK_SIGNUP = 1000900;   --7天
BP_ENUM_MODULE_EIGHT_DAY = 1001000;     --8天
BP_ENUM_MODULE_STARTER_PACK = 1001010;  --Starter pack
BP_ENUM_MODULE_SHARE = 1001100;
BP_ENUM_MODULE_TEAM = 1001200;
BP_ENUM_MODULE_ACTIVITY = 1001300;		--活动中心
BP_ENUM_MODULE_PROMOTION = 1001400;
BP_ENUM_MODULE_EXCITING_FEAST = 1001500;--刺激盛宴
BP_ENUM_MODULE_COLLECT_EQUIPMENT = 1001600;--收集装备
BP_ENUM_MODULE_FRONTIER_AWARD = 1001700;--先锋好礼
BP_ENUM_MODULE_SHARE_AWARD = 1001800;--分享有礼
BP_ENUM_MODULE_OPENSERVICE_CARNIVAL = 1001900;--开服狂欢
BP_ENUM_MODULE_INVITE_FRIEND = 1002000;
BP_ENUM_MODULE_BIND_FACEBOOK = 1002100;
BP_ENUM_MODULE_THEFIRSTCHARGE = 1002200; -- 首充
BP_ENUM_MODULE_THEFIRSTCHARGE_SEASON = 1002201; -- 赛季首冲
BP_ENUM_MODULE_ROLEINFO = 1002300; --个人资料
BP_ENUM_MODULE_RECHARGE = 1002400;--充值
BP_ENUM_MODULE_MALL = 1002500; --商城
BP_ENUM_MODULE_BUY_UNKNOW_PASS = 1002501; --绝地通行证购买
BP_ENUM_MODULE_UNKNOW_PASS = 1002502; --绝地通行证主界面
BP_ENUM_MODULE_INVITE_FB_FRIEND = 1002600; --邀请FB好友
BP_ENUM_MODULE_SEASON = 1002700; --赛季
BP_ENUM_MODULE_NEWTEACHING = 1002800; --新兵教学
BP_ENUM_MODULE_CORPS_INVITE = 1002900; -- 军团邀请界面
BP_ENUM_MODULE_CORPS_CENTER = 1003000; -- 军团列表和创建
BP_ENUM_MODULE_FACE_TEAM = 20025 --面对面开黑
BP_ENUM_MODULE_ALLIANCE_MAIN_PANEL = 1002900; --战队主面板
BP_ENUM_MODULE_CHAT = 1003000; --聊天室
BP_ENUM_MODULE_INVITEJOIN = 1003100; --邀请离线好友组队
BP_ENUM_MODULE_MALL_CHILD = 1003200; --商城子页面
BP_ENUM_MODULE_MALL_CHILD_JUMP_CHILD = 1003201; --商城子页面调子页面
BP_ENUM_MODULE_CORPS = 1003300;  --军团
BP_ENUM_MODULE_MALL_BOX = 1003400; --商城宝箱页面
BP_ENUM_MUDULE_OFFICER_TRAINING = 1003500;   ---- 军团训练营UI
BP_ENUM_MODULE_CORPS_TRAINING = 1003700; --军团特训
BP_ENUM_MODULE_REFLUX = 1004000; -- 好友召回
BP_ENUM_MODULE_LOBBY_CORPS = 1004200; -- 大厅军团界面
BP_ENUM_MODULE_CALLBACK = 1004900 -- 召回界面
BP_ENUM_MODULE_BUY_UPASS_ACT = 1005000 --购买通行证活动
BP_ENUM_MODULE_MONTH_CARD = 1005001 --月卡活动
BP_ENUM_MODULE_REWARD_PKG = 1005002 --奖赏包活动
BP_ENUM_MODULE_ACTIVITY_INVITE_TEAM = 1005003 --组队邀请活动
BP_ENUM_MODULE_ACTIVITY_HALLOWEEN_VEHICLE= 1005004 --载具升级活动
BP_ENUM_MODULE_ACTIVITY_ICE_LUCKY= 1005005 --冰雪节幸运夺宝
BP_ENUM_MODULE_ACTIVITY_SHAO_JI = 1006001	--烧鸡活动
BP_ENUM_MODULE_BLACK_FRIDAY = 1006002	--黑五活动
BP_ENUM_MODULE_BIOCHEMICAL_LUCKY = 1006003   --生化夺宝
BP_ENUM_MODULE_ANNIVERSARY = 1006004 --周年夺宝
BP_ENUM_MODULE_DISCOUNT_FEVER = 1006005 --特惠派对
BP_ENUM_MODULE_LUCKY_UNBACK = 1006006 --不放回抽奖模板
BP_ENUM_MODULE_COME_BACK = 1006100	--玩家回流
BP_ENUM_MODULE_PDD_BARGAIN = 1007000	--拼多多砍价订单详情页
BP_ENUM_MODULE_LEAGUEGAME = 1007001		--赛事
BP_ENUM_MODULE_PDD = 1007100   --拼多多系统
BP_ENUM_MODULE_ITOPNOTICE = 1008000		--登录后的iTOP公告
BP_ENUM_MODULE_PRIME = 1008100			 --订阅
BP_ENUM_MODULE_ITEM_UPGRADE = 1009000	--外显升级
BP_ENUM_MODULE_PANDORA_COllECTION = 1005600; --潘多拉活动:活动集合页
BP_ENUM_MODULE_ANTIADDCTION = 1005700;	--防沉迷弹窗
BP_ENUM_MODULE_INDIACOMP = 1008200;	--印度锦标赛
BP_ENUM_MODULE_PANDORA = 9000000; -- 9000000 为潘多拉活动起始id, >9000000的潘多拉占用其他系统不要使用，避免重复冲突

--宠物tlog
BP_ENUM_MODULE_PET_ENTER = 1100000 -- 进入宠物界面
BP_ENUM_MODULE_PET_PLAYACTION = 1100001 -- 点击动作

-- 平台功能ID
BP_ENUM_PLAYFORM_XINYUE = 100001
BP_ENUM_PLAYFORM_HUATIQUAN = 100002

--ingame ui zorder
BP_ENUM_UI_BATTLE_MAIN_ZORDER = 50;

-- s2c协议调用无错误
NetErrorCode_NONE = "ok"

ActivityType = {
	--zinotag 活动类型
	["NONE"] = 0,--活动类型开始 
	["NEW_PLAYER"] = 1,--新兵报道    
	["LOGIN"] = 2,--限时登录活动 
	["TOTAL_LOGIN"] = 3,--累计登录 条件: cond: "1" 不需要数量,
	["UPDATE_VER"] = 4,--更新版本  条件：cond: "222" 不需要数量
	["BATTLEROUND"] = 5,--单人/组队完成局数 
	["BATTLEFIRST"] = 6,--单人/组队吃鸡 
    --[[ 条件: cond: "1,2", 第一个表示 战斗类型(0 任意战斗，1 单人，2 双人，3 四人模式), 第二个表示 次数.
    对应other字段: battle_round ]]
    --[[ 条件: cond: "1, 2,3", 第一个表示 战斗类型(0 任意战斗，1 单人，2 双人，3 四人模式),     第二个表示 次数 第三个表示进入前x名
    对应other字段: battle_first ]]
	["SHARE"] = 7,--指定分享 条件: cond: "1, 2", 第一个表示 分享类型(), 第二个表示 次数
    --[[ 对应other字段: share	]]
	["ITEM_EXCHANGE"] = 8,--道具兑换
	["SPRING_REDPACKET"] = 9,--春节拼多多活动
	["GROUP"] = 10,--普通的组活动，没有奖励，只是用来显示而已
	["GROUP_EXCITE"] = 11,--刺激盛典活动
	["COLLECT_EQUIPMENT"] = 12,--收集装备活动
    ["ACTIVITY_TYPE_LINK"] = 13,--链接类活动，跳转到网页
    ["PROMOTOR"] = 14,--推广员活动类型
	["DECISIVE_BATTLEROUND"] = 17,  --决战天命圈之之单人/组队完成局数 
	["DECISIVE_BATTLEFIRST"] = 18, --决战天命圈之单人/组队进入xx名
	["CONSUME_GOLD"] = 19, -- 累计花费金币活动
	["OBTAIN_SEGMENT"] = 20, -- 获得段位活动
	["ONLINE_TIME"] = 21, -- 累计游戏在线时间XX分钟
	["KILL_CNT"] = 22, -- 累计淘汰XX人
	["SURVIVAL_TIME"] = 23, -- 累计存活时间超过XX分钟
	["SHARE_AWARD"] = 26, -- 累计分享
	["INVITEFBFRIENDS"] = 28, -- 邀请Facebook好友
	["QUESTION"] = 29, -- 新手3级调查问卷
	["NEW_KILL_CNT"] = 30,-- 新版累计淘汰XX人
	["NEW_SURVIVAL_TIME"] = 31,-- 新版累计存活时间超过XX分钟
	["FRIEND_RECALL"] = 33, --军官训练营
	["FRIEND_RECALL_REFLUX"] = 34, --好友召回
	["BIND_SEND_GIFT"] = 35, --绑定有礼
	["JOIN_CORPS"] = 36, --首次加入军团
	["BATTLE_CORPS"] = 37, --军团组队
	["VALUE_CORPS"] = 38, --军团活跃值
	["ACTIVITY_TYPE_CONSUME_UC"] = 39, -- 累计花费UC活动
	["CONSUME_UC"] = 40, --累积充值获取UC	
	["CONSUME_RP"] = 41, --累积获取RP
	["BUY_UPASS_ACTIVITY"] = 42, --购买通行证活动
	["IMAGES_GROUP"] = 43, -- 日韩图片集活动
	["FIRST_RECHARGE_ADD"] = 44, --首充+折扣
	["ACTIVITY_TYPE_BUY_CHEST"] = 45, -- 累计获取箱子活动
	["IMAGES_GROUP_SUB"] = 46, -- 日韩图片集活动之子活动
	["WelFARE_REWARD_PKG"] = 47, -- 奖赏包，直购礼包活动
	["INVITE_TEAM"] = 49, -- 组队邀请活动
	["THROWCANDY"] = 51,	--出生岛扔糖果活动
	["GET_ITEM_DO"] = 52,	--固定商品获得并完成行为
	["H5_REWARD"] = 55,  --H5页面点击获得奖励
	["ACTIVITY_TYPE_BATTLE_COLLECT"] = 56,  --战斗内收集物品
	["LEVEL_UP_REWARD"] = 57,	--升级得奖励活动
	["QUESTIONNAIRE"] = 60, 	--调查问卷
	["DISCOUNTFEVER"] = 61, 	--特惠派对
	["BIOCHEMICAL_Battle"] = 62, --生化模式战斗活动
	["BIOCHEMICAL_KILL_ZOMBIE"] = 63, --生化模式杀僵尸活动
	["ACTIVITY_TYPE_KRJP_PURCHASE"] = 64, --日韩直购，本质是统一的非开宝箱购买
	["SUPPLY_BUY_ONE"] = 65, --补给单抽折扣活动
	["SUPPLY_BUY_TEN"] = 66, --补给十连抽折扣活动
	["STARTER_PACK_US"] = 67, -- starter pack for US version , 活动显示表用了这个ID
	["LUCKYUNBACK_SURPRISE"] = 69, -- 不放回抽奖彩蛋
	["PVE_ALIVE"] = 70, --在PVE模式累计存活
	["PVE_EVALUATION"] = 71, ---PVE模式评价
	["FIRST_RECHARGE"] = 30001, -- 首充有礼
	["UPDATE_RP"] = 40001, -- 升级RP
	["HALLOWEEN_VEHICLE"] = 70001, -- 载具升级
	["HALLOWEEN_VEHICLE_KR"] = 70002, --载具升级(日韩)
	["ICE_LUCKY_GEM"] = 90001, -- 冰雪节幸运夺宝
	["ANNIVERSARY"] = 90101,	--周年夺宝
	["ANNIVERSARY_KR"] = 90102,	--周年夺宝日韩
}

----需要在活动中心显示的活动类型白名单
ActivityTypeInActivtyPage =
{
	[ActivityType["LOGIN"]] = true,
	[ActivityType["TOTAL_LOGIN"]] = true,
	[ActivityType["UPDATE_VER"]] = true,
	[ActivityType["BATTLEROUND"]] = true,
	[ActivityType["BATTLEFIRST"]] = true,
	[ActivityType["SHARE"]] = true,
	[ActivityType["ITEM_EXCHANGE"]] = true,
	[ActivityType["GROUP"]] = true,
	[ActivityType["ACTIVITY_TYPE_LINK"]] = true,
	[ActivityType["DECISIVE_BATTLEROUND"]] = true,
	[ActivityType["DECISIVE_BATTLEFIRST"]] = true,
	[ActivityType["CONSUME_GOLD"]] = true,
	[ActivityType["OBTAIN_SEGMENT"]] = true,
	[ActivityType["ONLINE_TIME"]] = true,
	[ActivityType["KILL_CNT"]] = true,
	[ActivityType["SURVIVAL_TIME"]] = true,
	[ActivityType["QUESTION"]] = true,
	[ActivityType["NEW_KILL_CNT"]] = true,
	[ActivityType["NEW_SURVIVAL_TIME"]] = true,
	[ActivityType["JOIN_CORPS"]] = true,
	[ActivityType["BATTLE_CORPS"]] = true,
	[ActivityType["VALUE_CORPS"]] = true,
	[ActivityType["ACTIVITY_TYPE_CONSUME_UC"]] = true,
	[ActivityType["IMAGES_GROUP"]] = true,
	[ActivityType["CONSUME_UC"]] = true,
	[ActivityType["CONSUME_RP"]] = true,
	[ActivityType["ACTIVITY_TYPE_BUY_CHEST"]] = true,
	[ActivityType["THROWCANDY"]] = true,
	[ActivityType["GET_ITEM_DO"]] = true,
	[ActivityType["ACTIVITY_TYPE_BATTLE_COLLECT"]] = true,
	[ActivityType["LEVEL_UP_REWARD"]] = true,
	[ActivityType["QUESTIONNAIRE"]] = true,
	[ActivityType["H5_REWARD"]] = true,
	[ActivityType["BIOCHEMICAL_Battle"]] = true,
	[ActivityType["BIOCHEMICAL_KILL_ZOMBIE"]] = true,
	[ActivityType["PVE_ALIVE"]] = true;
	[ActivityType["PVE_EVALUATION"]] = true;
}




------ 经分需求 按钮ID定义 ------
-- 大厅
---- 大厅各按钮
BP_BA_LOBBY_QQTRIBE = 10001                   --打开QQ部落
BP_BA_LOBBY_WXGAMEGROUP = 10002               --打开微信圈子
BP_BA_LOBBY_FIVEDAY = 10003                   --五天乐按钮
BP_BA_LOBBY_ACTIVITY_CENTER = 10004                   --活动中心
BP_BA_LOBBY_COMMUNITY = 10005                   --社区
BP_BA_LOBBY_QQ_VIP = 10006                   --QQ会员
BP_BA_LOBBY_QQ_START = 10007                   --QQ启动
BP_BA_LOBBY_WX_START = 10008                   --微信启动
BP_BA_LOBBY_LIVE = 10009                   --直播
BP_BA_LOBBY_QQ_DIANJING = 10010                   --企鹅点击
BP_BA_LOBBY_WX_DIANJING = 10011                   --微信电竞
BP_BA_LOBBY_XINYUE = 10012                   --心悦
BP_BA_LOBBY_LIULIANG = 10013                   --流量包
BP_BA_LOBBY_LIBAO = 10014                   --礼包中心
BP_BA_LOBBY_HUATIQUAN = 10015                   --话题圈
BP_BA_LOBBY_RANK_PANEL = 10016                   --排行
BP_BA_LOBBY_WARDROBE_PANEL = 10017                   --仓库
BP_BA_LOBBY_SHOP_PANEL = 10018                   --补给
BP_BA_LOBBY_FRIEND_PANEL = 10019                   --好友
BP_BA_LOBBY_MAIL_PANEL = 10020                   --邮件
BP_BA_LOBBY_SETTING_PANEL = 10021                   --设置
BP_BA_LOBBY_WORLDVIEW_PANEL = 10022                   --世界观
BP_BA_LOBBY_GUIDE_PANEL = 10023                   --帮助
BP_BA_LOBBY_ALLIANCE_PANEL = 10024                   --战队
BP_BA_LOBBY_TASK_PANEL = 10025                   --任务
BP_BA_LOBBY_SEASON_PANEL = 10026                   --赛季
BP_BA_LOBBY_ROOM_PANEL = 10027                  --房间模式入口
BP_BA_LOBBY_NEWERGUIDE_PANEL = 10028                   --新兵教学入口
BP_BA_LOBBY_CHAT_PANEL = 10029                   --聊天入口
BP_BA_LOBBY_MALL_PANEL = 10030				  --真商城入口
BP_BA_LOBBY_CHOOSE_ZONE_ACCESS = 10031			--点“开始游戏”按钮
BP_BA_LOBBY_MATCH_INFO = 10032					--点“选择模式的”按钮
BP_BA_LOBBY_ADD_FRIEND = 10033					--点“好友列表”按钮
BP_BA_LOBBY_FRIEND_LIST = 10034					--点“邀请0/0”按钮
BP_BA_LOBBY_FRIEND_LIST_INVITE2 = 10035			--点“邀请0/0”打开列表中的“邀请组队按钮
BP_BA_LOBBY_OPEN_ENCHARGE_1 = 10036				--点右上角金币旁的“氪金”按钮
BP_BA_LOBBY_OPEN_ENCHARGE_2 = 10037				--点右侧“氪金”按钮
BP_BA_LOBBY_FIRST_ENCHARGE = 10038				--点右侧“首充”按钮
-- BP_BA_LOBBY_UNKNOW_PASS = 10039					--点右侧“RP”按钮
BP_BA_LOBBY_ACTIVITY_BANNER = 10040				--点右下角“活动Banner”
BP_BA_LOBBY_ACTIVITY_SNEAK = 10041				--点右下角“活动Banner隐藏”
BP_BA_LOBBY_FRIEND_LIST_INVITE1 = 10042			--点大厅左下角“邀请组队”按钮
BP_BA_LOBBY_AIRSHOP_OPEN = 10043				--空投商城从弹出框点击进入
BP_BA_LOBBY_AIRSHOP_OPEN_FROM_LOBBY = 10044		--空投商城从大厅进入
BP_BA_LOBBY_RESERVATION = 10045					--好友预约功能：0=邀请好友处的“预约” 1=同意 2=拒绝 3=发送方一起游戏 4=接受方一起游戏 5=观战好友 6=观战好友时的“预约”
BP_BA_LOBBY_FRIEND_LIST_INVITE3 = 10046			--点组队邀请活动里的邀请按钮
BP_BA_LOBBY_INVITE_FRIEND = 10047				--点左下角邀请组队按钮

---- 分享
BP_BA_SHARE_FACEBOOK = 2					  --分享到Facebook
BP_BA_SHARE_TWITTER = 3						  --分享到Twitter
BP_BA_SHARE_VK = 4						  	  --分享到VK
BP_BA_SHARE_WX_ZONE = 5				          --分享到WX朋友圈
BP_BA_SHARE_LINE = 6				          --分享到Line
BP_BA_SHARE_MORE = 7				          --分享到Line
BP_BA_SHARE_QQByiTOP = 8					  --分享到QQ

BP_BA_SHARE_ITEMPANEL =10101                  --分享物品页面打开次数        
BP_BA_SHARE_BATTLEGRADEPAENL =10102           --分享战绩页面打开次数        
BP_BA_SHARE_GAMEPROPAGANDAPANEL =10103        --分享游戏宣传图页面打开次数  
BP_BA_SHARE_MAINPANEL =10104                  --分享面板打开次数
BP_BA_SHARE_SHAREBTN =10105                   --分享面板上的分享按钮点击次数
BP_BA_SHARE_ITEM =10106                       --分享物品次数                
BP_BA_SHARE_GRADE =10107                      --分享战绩次数                
BP_BA_SHARE_GAMEPROPAGANDA =10108             --分享游戏宣传图次数                            
BP_BA_SHARE_WXFRIEND =10111                   --分享到微信好友              
BP_BA_SHARE_QQFRIEND =10112                   --分享到QQ好友次数            
BP_BA_SHARE_WXGAMEGROUP =10113                --分享到游戏圈次数
BP_BA_SHARE_QQTRIBE =10114                    --分享到部落次数

BP_BA_SHARE_QQSPACE =10110                    --分享到Facebook次数，复用QQ  
BP_BA_SHARE_TW_COUNT =10109                   --分享到Twitter次数   
BP_BA_SHARE_WX_ZONE_COUNT =10115              --分享到微信朋友圈次数
BP_BA_SHARE_VK_COUNT =10116                   --分享到VK次数
BP_BA_SHARE_LINE_COUNT =10117                 --分享到Line次数
BP_BA_SHARE_MORE_COUNT =10118                 --分享到More次数
BP_BA_SHARE_QQByiTOP_COUNT = 10119            --分享到QQ次数

BP_BA_SHARE_ROOMQRCODE =10301                 --房间二维码扫描次数
BP_BA_SHARE_ROOMREFASH =10302                 --房间刷新次数
BP_BA_CORP_RANK_WEEK = 10039            --军团周榜
BP_BA_CORP_RANK_SEASON = 10040            --军团赛季榜
BP_BA_LOBBY_RESERVATION = 10042			--好友预约功能：0=邀请好友处的“预约” 1=同意 2=拒绝 3=发送方一起游戏 4=接受方一起游戏 5=观战好友 6=观战好友时的“预约”
BP_BA_SHARE_LEAGUEGAME_REASON  = 10043	--赛季分享reason



--新手训练
BP_BA_NEWTEACHING_CLICK_1 = 10201			  --点击标签“玩法介绍”
BP_BA_NEWTEACHING_CLICK_2 = 10202			  --点击标签“基础操作”
BP_BA_NEWTEACHING_CLICK_3 = 10203			  --点击标签“跳伞操作”
BP_BA_NEWTEACHING_CLICK_4 = 10204			  --点击标签“背包操作”
BP_BA_NEWTEACHING_CLICK_5 = 10205			  --点击标签“射击操作”
BP_BA_NEWTEACHING_CLICK_6 = 10206			  --点击标签“投掷物操作”
BP_BA_NEWTEACHING_CLICK_7 = 10207			  --点击标签“药品使用”
BP_BA_NEWTEACHING_CLICK_8 = 10208			  --点击标签“载具操作”
BP_BA_NEWTEACHING_CLICK_9 = 10209			  --点击标签“游泳操作”


BP_BA_START_GAME = 10401                      --点击标签“进入游戏”
BP_BA_SELECT_FACE = 10402                     --点击标签“选择脸型”
BP_BA_SELECT_HAIR = 10403                     --点击标签“选择发型”
BP_BA_SELECT_COLOR = 10404                    --点击标签“选择颜色”
BP_BA_SELECT_SEX = 10405                      --点击标签“选择性别”
BP_BA_SELECT_NAME = 10406                     --点击标签“选择名字”
BP_BA_SELECT_LAN = 10407                      --点击标签“选择语言”
BP_BA_LOG_OUT = 10408                         --点击标签“点击logout”
BP_BA_CREATE = 10409                          --点击标签“点击创建”
BP_BA_SELECT_ROOKIE = 10410                   --点击标签“熟悉度rookie”
BP_BA_SELECT_EXPERIENCED = 10411              --点击标签“熟悉度experienced”
BP_BA_SELECT_PRO = 10412                      --点击标签“熟悉度pro”
BP_BA_FAMILIAR_OK = 10413                    --点击标签“熟悉度界面ok”
BP_BA_EIGHT_DAYS = 10414                      --点击标签“8days签到”
BP_BA_EIGHT_DAYS_AWARD_OK = 10415             --点击标签“点击弹出奖励的OK”
BP_BA_EIGHT_DAYS_CLOSE = 10416                --点击标签“关闭8days签到”
BP_BA_WEEK_LOGIN = 10417                      --点击标签“周签到”
BP_BA_WEEK_LOGIN_AWARD_OK = 10418             --点击标签“周签到弹出奖励的OK”
BP_BA_WEEK_LOGIN_CLOSE = 10419                --点击标签“关闭周签到”
BP_BA_ROLE_INFO_TAB = 10420             	  --点击标签“个人信息-角色”
BP_BA_ROLE_INFO_JUMP_SHOP = 10421             --点击跳转商城
BP_BA_SELECT_REGION = 10422                   --点击标签“选择地区”
BP_BA_SELECT_REGION_OK = 10423                --点击“选择地区标签的确定按钮”
BP_BA_SELECT_COUNTRY_FLAG = 10424                --点击“选择旗帜”
BP_BA_CLICK_NEWS = 10425                      --点击lobby界面的news按钮
---- 打脸图
BP_BA_SLAP_URLGO = 10426                      --打脸图超链跳转
BP_BA_SLAP_SYSTEMGO = 10427                   --打脸系统内跳转
BP_BA_CLICK_ROLE_INFO_TITLE = 10428           --个人详情中点击查看称号

BP_BA_WEEK_SHOW = 10429						  --周签到展示
BP_BA_WEEK_SIGN_CLICK = 10430				  --周签到点击签到
BP_BA_WEEK_JUMP = 10431						  --活动中心跳转到周签到

--召回任务
BP_BA_FRD_RECALL_ACT_CLICK = 10450		      --召回任务

--通行证
BP_BA_UNKNOWPASS_COURCE_CONFIRM = 10508       --点击通行证教程确定
-- 军团精分ID   
BP_BA_CORPS_TASK = 10601					  --点击页签-军团任务
BP_BA_CORPS_SHOP = 10602					  --点击页签-军团商店
BP_BA_CORPS_TRAINING = 10603				  --打开军团特训面板
BP_BA_CORPS_HOMEPAGE = 10604				  --打开军团主页
BP_BA_CORPS_REMIND_GROUP = 10605		      --点击提醒建群
BP_BA_CORPS_INVITE_FRIEND = 10606			  --点击邀请好友
BP_BA_CORPS_INVITE_NEARBY = 10607			  --点击邀请附近的人
BP_BA_CORPS_INVITE_RECENT = 10608			  --点击邀请最近的人
BP_BA_CORPS_INVITE_ARMY = 10609			  	  --点击邀请战队成员

-- 成就界面查看
BP_BA_ACHIEVEMENT_SELF = 10701			  	  --查看自己成就信息
BP_BA_ACHIEVEMENT_OTHER = 10702			  	  --查看别人成就信息
BP_BA_ACHIEVEMENT_FLOAT_TIP = 10703           --通过浮窗查看自己成就信息
BP_BA_ACHIEVEMENT_TASK = 10704                --通过任务查看自己成就信息

BP_BA_STORE_SALE_ITEM = 10705                --商城点击某个Banner

--大厅皮肤和背景音乐打点
BP_BA_LOBBY_SKINID_COUNT = 10800				  --大厅皮肤打点
BP_BA_LOBBY_BGMID_COUNT = 10801					  --大厅背景音乐	

-- 商店
BP_BA_MALL_RECOMMEND_SHOW_POSTER = 10901					  -- 商店推荐页打开海报


--个人信息页签类型
RoleInfoLabelType =
{
	BasicInfo = 1,
	PersonalCombat = 2,
	Intimate = 3,
	HistoryCombat = 4,
	Card = 5,
	HonourWall = 6,
	Achievement = 7,
	RelationShip = 8,
}

-- 一键建群前缀
GroupTypePerfix = {
	["CORPS"] = "j",
}

ServerZoneId = {
	["ONLINE"] = 1, -- 外网服务器, nil也是外网服务器
	["TEST"] = 90, -- 公网主干 || 所有测试环境 || 预发布
	["PRE"] = 101, -- 先游服
}

--国际化选区
BP_ENUM_INTL_ROLEINFO_REFRESH_TYPE_DEFAULT = 1
BP_ENUM_INTL_ROLEINFO_REFRESH_TYPE_BASIC_ZONECHANGED = 2


--射击类型
ShootType =
{
	TPPType = 1,
	FPPType = 2,
}

SceneType = 
{
    AvatarReset = 1,
    Armory = 2,
    Market = 3,
}

--成就分组
BP_ENUM_ACHIEVEMENT_GROUP_MISC = 1 --综合
BP_ENUM_ACHIEVEMENT_GROUP_GROW = 2 --成长
BP_ENUM_ACHIEVEMENT_GROUP_FRIEND = 3 --社交
BP_ENUM_ACHIEVEMENT_GROUP_MAP = 4 --荣誉
BP_ENUM_ACHIEVEMENT_GROUP_BATTLE = 5 --战场
BP_ENUM_ACHIEVEMENT_GROUP_GOODS = 6 --藏品
BP_ENUM_ACHIEVEMENT_GROUP_EVENT = 7 --光辉事迹
--成就状态
BP_ENUM_ACHIEVEMENT_STATE_NOT_FINISH = 1 --未完成
BP_ENUM_ACHIEVEMENT_STATE_FINISH_GET_AWARD = 2 --完成领取奖励
BP_ENUM_ACHIEVEMENT_STATE_FINISH_NO_AWARD = 3 --完成未领取奖励
--成就显示类型
BP_ENUM_ACHIEVEMENT_SHOW_TYPE_SINGLE_CND = 1 --单个条件成就
BP_ENUM_ACHIEVEMENT_SHOW_TYPE_MULTI_LV = 2 --多阶成就
BP_ENUM_ACHIEVEMENT_SHOW_TYPE_MULTI_CND = 3 --单阶多任务成就
BP_ENUM_ACHIEVEMENT_SHOW_TYPE_COLLECT = 4 --单阶收集套装成就
BP_ENUM_ACHIEVEMENT_SHOW_TYPE_MULTI_CND_ONCE = 5 --单阶多任务并行成就(只有一次的条件)
BP_ENUM_ACHIEVEMENT_SHOW_TYPE_SINGLE_NO_PROCESS = 6 --单个条件成就,没有进度
BP_ENUM_ACHIEVEMENT_SHOW_TYPE_RANK = 7 --段位类型的成就显示

-- 仓库枚举
BP_ENUM_wardrobeTabString_default = ""

BP_ENUM_wardrobeTabString_all = ""  -- 0
BP_ENUM_wardrobeTabString_head = "头部" -- 1
BP_ENUM_wardrobeTabString_face = "脸部" -- 2
BP_ENUM_wardrobeTabString_clothes = "衣服" -- 3
BP_ENUM_wardrobeTabString_trousers = "裤子" -- 4
BP_ENUM_wardrobeTabString_shoes = "鞋子" -- 5
BP_ENUM_wardrobeTabString_items = "物品" -- 6
BP_ENUM_wardrobeTabString_parachute = "降落伞" -- 7
BP_ENUM_wardrobeTabString_emoj = "动作" -- 8
BP_ENUM_wardrobeTabString_gun = "枪械" -- 9
BP_ENUM_wardrobeTabString_suit = "套装" -- 15
BP_ENUM_wardrobeTabString_plane = "飞机" -- 16
BP_ENUM_wardrobeTabString_hallTheme = "背景" -- 202
BP_ENUM_wardrobeTabString_bag = "背包" -- 504
BP_ENUM_wardrobeTabString_helmet = "头盔" -- 505
BP_ENUM_wardrobeTabString_armor = "防弹衣" -- 506
BP_ENUM_wardrobeTabString_quickmessage = "快捷语音" -- 1901

BP_ENUM_wardrobeTabString_vehicle_Motorbike = "摩托车" -- 901
BP_ENUM_wardrobeTabString_vehicle_Motorbike_SideCart = "三轮车" -- 902
BP_ENUM_wardrobeTabString_vehicle_Dacia = "小车" -- 903
BP_ENUM_wardrobeTabString_vehicle_MiniBus = "巴士" -- 904
BP_ENUM_wardrobeTabString_vehicle_PickUp = "皮卡" -- 905
BP_ENUM_wardrobeTabString_vehicle_PickUp_1 = "带顶皮卡" -- 906
BP_ENUM_wardrobeTabString_vehicle_Buggy_0 = "buggy" -- 907
BP_ENUM_wardrobeTabString_vehicle_UAZ_0 = "普通吉普车" -- 908
BP_ENUM_wardrobeTabString_vehicle_UAZ_1 = "布篷吉普车" -- 909
BP_ENUM_wardrobeTabString_vehicle_UAZ_2 = "敞篷吉普车" -- 910
BP_ENUM_wardrobeTabString_vehicle_PG117 = "船" -- 911
BP_ENUM_wardrobeTabString_vehicle_Aquarail = "摩托艇" -- 912
BP_ENUM_wardrobeTabString_vehicle_UAZ_3 = "空投UAZ吉普车" -- 913
BP_ENUM_wardrobeTabString_vehicle_SportsCar_0 = "Mirado跑车" --914
BP_ENUM_wardrobeTabString_vehicle_SportsCar_1 = "Mirado敞篷跑车" --915
BP_ENUM_wardrobeTabString_vehicle_FootboardMotor = "踏板摩托" -- 916
BP_ENUM_wardrobeTabString_vehicle_RosnyPickUp = "罗尼皮卡" -- 917
BP_ENUM_wardrobeTabString_vehicle_SnowMotorbike = "雪地摩托" -- 918

BP_ENUM_WardrobePageType_Avatar = 1
BP_ENUM_WardrobePageType_Tools = 3
BP_ENUM_WardrobePageType_Gun = 4
BP_ENUM_WardrobePageType_Parachute = 5
BP_ENUM_WardrobePageType_Vehicle = 6

---- 房卡相关
RoomModeType = {
	ALL = 0,
	JingDian = 1,
	ZhanZheng = 2,
	JiSuZhanChang = 3,
	JujiTeXun = 4,
	CiJiDuiJue = 5,
	JingJI = 6
}

-- 房卡子ID到模式映射
RoomCardSubType2Mode = {
	[2401] = RoomModeType.ALL,
	[2402] = RoomModeType.JingDian,
	[2403] = RoomModeType.ZhanZheng,
	[2404] = RoomModeType.JiSuZhanChang,
	[2405] = RoomModeType.JujiTeXun,
	[2406] = RoomModeType.CiJiDuiJue,
	[2407] = RoomModeType.JingJI,
}

-- 模式到房卡子ID映射
Mode2RoomCardSubType = {
	[RoomModeType.ALL] = 			2401,
	[RoomModeType.JingDian] = 		2402,
	[RoomModeType.ZhanZheng] = 		2403,
	[RoomModeType.JiSuZhanChang] = 	2404,
	[RoomModeType.JujiTeXun] = 		2405,
	[RoomModeType.CiJiDuiJue] = 	2406,
	[RoomModeType.JingJI] = 		2407,
}

-- 模式开关ID
Mode2SwithID = {
	[RoomModeType.JingDian] = 		110001,
	[RoomModeType.ZhanZheng] = 		110002,
	[RoomModeType.JiSuZhanChang] = 	110003,
	[RoomModeType.JujiTeXun] = 		110004,
	[RoomModeType.CiJiDuiJue] = 	110005,
	[RoomModeType.JingJI] = 		110006,
}

--潘多拉平台定义
PANDORA_PLAYFORM =
{
	[BP_ENUM_PLAYFORM_MORE] = "more",			--More
	[BP_ENUM_PLAYFORM_WX] = "Weixin",			--wechat
	[BP_ENUM_PLAYFORM_QQ] = "Facebook",			--QQ->Facebook
	[BP_ENUM_PLAYFORM_TOURIST] = "Guest",		--Guest
	[BP_ENUM_PLAYFORM_GAMECENTER] = "Apple" , 	--GameCenter 
	[BP_ENUM_PLAYFORM_GOOGLEPLAY] = "Google",  	--GooglePlay 
	[BP_ENUM_PLAYFORM_TWITTER] = "TWITTER",  		--Twitter 
	[BP_ENUM_PLAYFORM_VK] = "VK",			--vk 
	[BP_ENUM_PLAYFORM_LINE] = "LINE",			--Line 
	[BP_ENUM_PLAYFORM_QQByiTOP] = "QQ",     --qq
}