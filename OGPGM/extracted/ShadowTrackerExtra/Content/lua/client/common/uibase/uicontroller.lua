
--sami UI面板类型
eUIType = eUIType or { }

--UI面板类表
UIController = UIController or
{
    uiTypeMap = {};
}

--sami 界面初始化
function UIController.Init()
    --界面枚举类型
    eUIType =
    {
        eNone = 0,
        eMessageBoxUI = 1000,
        --pass相关
        eUnknowPassUI = 2001,
        eUnknowPassAwardUI = 2002,
        eUnknowPassMissionUI = 2003,
        eUnknowPassExchangeUI = 2004,
        eUnknowPassBuyUI = 2005,
        eUnknowPassIntroduceUI = 2006,
        eUnknowPassShowAwardUI = 2007,
        eUnknowPassExchangeConfirmUI = 2008,
        eUnknowPassIntroduceUI = 2009,
        eUnknowPassTreasureBoxUI = 2010,
        eUnknowPassLevelUpUI = 2011,
        eUnknowPassMissionUI = 2012,
        eUnknowPassNewbieUI = 2013,
        eUnknowPassShowOrdinaryAwardUI = 2014,
        eUnknowPassChooseAwardUI = 2015,
        eUnknowPassMissionAwardAllUI = 2016,
        eUnknowPassRankUI = 2017,
        --充值相关
        eRechargeUI = 3001,
        eSubscribeUI = 3002,
        eRechargeJKUI = 3003,
        --军团相关
        eCorpsBaseUI = 4001,
        eCorpsOwnHomeUI = 4002,
        eCorpsOwnInfoUI = 4003,
        eCorpsShopUI = 4004,
        eCorpsRankUI = 4005,
        eCorpsWelfareUI = 4006,
        eCorpsTrainingUI = 4007,
        eCorpsTrainingRankUI = 4008,
        eCorpsRankAwardUI = 4009,
        eCorpsUI = 4010,
        eCorpsSuggestionUI = 4011,
        eCorpsCreateUI = 4012,
        eCorpsIconSelectUI = 4013,
        eCorpsInvitationUI = 4014,
        eCorpsAppointUI = 4015,
        eCorpsApplyListUI = 4016,
        eCorpsManagerUI = 4017,
        eCorpsChoosetitleUI = 4018,
        eCorpsAutoInviteUI = 4019,
        eCorpsWelfareReceiveUI = 4020,
        eCorpsWelfareRedEnvelopes = 4021,
        eCommonUseItemsUI = 5001,
        eAllianceRecruitUI = 6001,
        
        --个人信息相关
        eRoleInfoUI = 7001,
        eRoleInfoHistoryUI = 7002,
        eRoleInfoHistoryDetailUI = 7003,
        eRoleInfoBigAvatarUI = 7004,
        eRoleInfoSelectAchievementUI = 7005,
        eAchievementScoreAwardUI = 7006,
        eSharePersonUI = 7007,
        eRoleInfoCorpsUI = 7008,
        eRoleInfoAliasUI = 7009,
        eRoleInfoShowInformation = 7010,
       
        ePersonSpaceMainUI = 7012,
        eRoleInfoAchievementUI = 7013,
        eRoleInfoSegmentUI = 7014,
        eRoleInfoCombatUI = 7015,
        eRoleInfoCardPopupUI = 7016,
        eCoupleAvatarMgrUI = 7017,
        ePersonSpaceRelationshipUI = 7018,
        ePersonSpaceSecrecySettingUI = 7019,
        ePersonSpacePartnerSettingUI = 7020,
        
        eComplaintUI = 8001,
        eRoleInfoTagUI = 8002,
        
        --任务相关
        eTaskUI = 9001,
        eAchievementDetailUI = 9002,
        eShareAchievementUI = 9003,
        eAchievementUI = 9004,
        eTaskBackFlowUI = 9005,
        --商城相关
        eStoreUI = 10001,
        eMallBuy = 10002,
        eStoreBuy = 10003,
        eShopGift = 10004,
        eShopGiftWithDay = 10005,
        eShopGiftPacket = 10006,
        eMallPageDIY = 10007,
        eMallBuyWithCount = 10008,
        eStorePriceSelect = 10009,
        eCoupons = 10010,
        
        -- 锦标赛
        eIndiaChampionShipMain = 11001;
        eIndiaChampionShipIntroduce = 11002;
        eIndiaChampionShipPopUp = 11003;
        eIndiaChampionShipHistoryRecord = 11004;
	
        --新版商城
        eStoreMainUI = 12001,
        eStoreRecommendPage = 12002,
        eStoreExchangePage = 12003,
        eStoreClothesPage = 12004,
        eStorePurchasePopUpValidHour = 12005,
        eStoreWeaponPage = 12006,
        eStorePropPage = 12007,
        eStoreVehiclePage = 12008,
        eStorePreviewPage = 12009,
        eStoreBindPhone = 12010,
        eStoreChestPage = 12011,
        eStoreJumpToChest = 12012,
        
        --新版补给
        eSupplyMainUI = 13001,
        eSupplyActivityUI = 13002,
        eSupplyValuableUI = 13003,
        eSupplyNormalUI = 13004,

        -- 个人信息面板
        -- eRoleInfoBase = 14001,
        eRoleinfoAlias = 14002,
        eCountryarea = 14003,
        eHeadportrait = 14004,
        eAvatarframe = 14005,

        -- 外显升级
        eItemUpgrade = 15001,

        -- 聊天相关
        eChatShareAchievement = 16001,
        eChatRecruit = 16002,
        eChatRoom = 16003,
        eChatShareAchievementShow = 16004,
        eChatEmoji = 16005,


        --查看别人的战队
        eAllianceForRoleInfo = 17001,
        eAlliance = 17002,                  --查看战队
        eAllianceCompetitionShop = 17003,
        eLeagueGameFinalChampion = 17004,   --线上赛冠军
        eLeagueGameIntroduce = 17005,       --线上赛介绍
        
        --排行榜相关
        eWarZoneRankUI = 18001,
        
        eRegionStrongerRankUI = 18002,
        eCountryStrongerRankUI = 18003,
        eWarZoneMedalChooseUI = 18004,
        
        --房间相关
        eRoomWaitingUI = 19001, --等待房间
        eRoomUI = 19002, --房间列表
        eRoomCreateUI = 19003, --房间创建
        
        --邮件
        eMailUI = 20001,
        eShopGiftMsgCenter = 20002,
        eShopGiftViewUI = 20003,

        --物品使用弹窗
        eCommonItemListUI = 21001,
        
        --聊天
        eChatMain = 22001,
        eChatEmoji = 22002,
        eChatLanguageSelect = 22003,   -- 聊天同语言选择
        
        --组队选图界面
        eTemaupMatchInfo = 23001,
        eMatchLanguageSelect = 23002,   -- 组队同语言选择
        eTeamupMapTips = 23003,         -- 选图界面，副本前缀词tips弹窗

        eTreasureBoxPopUp = 24001,  --每日任务里的宝箱
        eTheFirstCharge = 24002,  --首充

        eRatePanel = 25001, --概率界面

        --弹窗相关
        eEightDayUI = 26001,

        eShareWarZoneTitletUI = 27001,
    }

    --[[ui界面参数说明
        UIType - 界面枚举类型
        ui - 界面句柄
        uiNum - 界面绑定蓝图数
        BModule - 是否模态
        BModel3D - 是否有3D模型展示
        depth - 初始层级
        bShow - 显示情况
    ]]
    UIController.uiTypeMap =
    {
        { UIType = eUIType.eUnknowPassUI; ui = bp_unknow_pass; uiClass = UnknowPassUI; uiNum = 2; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eUnknowPassAwardUI; ui = bp_unknow_pass_award; uiClass = UnknowPassAwardUI; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eUnknowPassMissionUI; ui = bp_unknow_pass_mission; uiClass = UnknowPassAwardUI; uiNum = 2; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eUnknowPassExchangeUI; ui = bp_unknow_pass_exchange; uiClass = UnknowPassExchangeUI ; uiNum = 2; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eUnknowPassBuyUI; ui = bp_unknow_pass_buy; uiClass = UnknowPassBuy ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eUnknowPassIntroduceUI; ui = bp_unknow_pass_introduce; uiClass = UnknowPassIntroduceUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eUnknowPassShowAwardUI; ui = bp_unknow_pass_show_award; uiClass = UnknowPassShowAward ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eUnknowPassExchangeConfirmUI; ui = bp_unknow_pass_exchange_confirm; uiClass = UnknowPassExchangeConfirm ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eUnknowPassIntroduceUI; ui = bp_unknow_pass_introduce; uiClass = UnknowPassIntroduceUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eUnknowPassTreasureBoxUI; ui = bp_unknow_pass_treasurebox; uiClass = UnknowPassTreasureBoxUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eUnknowPassLevelUpUI; ui = bp_unknow_pass_levelup; uiClass = UnknowPassLevelUp ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eUnknowPassMissionUI; ui = bp_unknow_pass_mission; uiClass = UnknowPassMissionUI ; uiNum = 2; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eUnknowPassNewbieUI; ui = bp_unknow_pass_newbie; uiClass = UnknowPassMissionUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eUnknowPassShowOrdinaryAwardUI; ui = bp_unknow_pass_show_ordinary_award; uiClass = UnknowPassShowOrdinaryAward ;uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eUnknowPassChooseAwardUI; ui = bp_unknow_pass_choose_award; uiNum = 1; uiClass = UnknowPassChooseAwardUI ;BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eUnknowPassMissionAwardAllUI; ui = bp_unknow_pass_mission_award_all; uiNum = 1; uiClass = UnknowPassMissionAwardAllUI ;BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eUnknowPassRankUI; ui = bp_unknow_pass_rank; uiNum = 1; uiClass = UnknowPassRankUI ;BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eRechargeUI; ui = bp_recharge; uiClass = RechargeUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eSubscribeUI; ui = bp_subscribe; uiClass = SubscribeUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eRechargeJKUI; ui = bp_rechargeJK; uiClass = RechargeJKUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        
        { UIType = eUIType.eCorpsBaseUI; ui = bp_corps_base; uiClass = CorpsBaseUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eCorpsOwnHomeUI; ui = bp_corps_own_homepage; uiClass = CorpsOwnHomePageUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eCorpsOwnInfoUI; ui = bp_corps_own_info; uiClass = CorpsOwnInfoUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eCorpsShopUI; ui = bp_corps_shop; uiClass = CorpsShopUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eCorpsRankUI; ui = bp_corps_rank; uiClass = CorpsRankUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eCorpsWelfareUI; ui = bp_corps_Welfare; uiClass = CorpsWelfareUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eCorpsTrainingUI; ui = bp_corps_training; uiClass = CorpsTrainingUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eCorpsTrainingRankUI; ui = bp_corps_training_rank; uiClass = CorpsTrainingRankUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eCorpsRankAwardUI; ui = bp_corps_rank_award; uiClass = CorpsRankAwardUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eCorpsUI; ui = bp_corps; uiClass = CorpsUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eCorpsSuggestionUI; ui = bp_corps_suggestion; uiClass = CorpsSuggestionUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eCorpsCreateUI; ui = bp_corps_create; uiClass = CorpsCreateUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eCorpsIconSelectUI; ui = bp_corps_icon_select; uiClass = CorpsIconSelectUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eCorpsInvitationUI; ui = bp_corps_Invitation; uiClass = CorpsInvitationUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eCorpsAppointUI; ui = bp_corps_appoint; uiClass = CorpsAppointUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eCorpsApplyListUI; ui = bp_corps_apply_list; uiClass = CorpsApplyListUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eCorpsManagerUI; ui = bp_corps_manager; uiClass = CorpsManagerUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eCorpsChoosetitleUI; ui = bp_roleinfo_corpalias; uiClass = RoleInfoCorpAlias ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eCorpsAutoInviteUI; ui = bp_corps_auto_invite; uiClass = CorpsAutoInviteUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eCorpsWelfareReceiveUI; ui = bp_corps_WelfareReceive; uiClass = CorpsWelfareReceiveUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eCorpsWelfareRedEnvelopes; ui = bp_corps_WelfareRedEnvelopes; uiClass = CorpsWelfareRedEnvelopesUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };

        --个人信息相关
        { UIType = eUIType.eCommonUseItemsUI; ui = bp_common_use_items; uiClass = CommonUseItemsUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eAllianceRecruitUI; ui = bp_alliance_recruit; uiClass = AllianceRecruitUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eRoleInfoUI; ui = bp_roleinfo; uiClass = RoleInfoUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eRoleInfoHistoryUI; ui = bp_roleinfo_history; uiClass = RoleInfoHistoryUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eRoleInfoHistoryDetailUI; ui = bp_roleinfo_historydetail; uiClass = RoleInfoHistoryDetailUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eRoleInfoBigAvatarUI; ui = bp_roleinfo_bigavatar; uiClass =  RoleInfoBigAvatarUI; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eRoleInfoSelectAchievementUI; ui = bp_roleinfo_select_achievement; uiClass = SelectAchievementUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eAchievementScoreAwardUI; ui = bp_roleinfo_achievement_score_award; uiClass = AchievementScoreAwardUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eSharePersonUI; ui = bp_share_person; uiClass = SharePersonUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eRoleInfoCorpsUI; ui = bp_roleinfo_corps; uiClass = RoleInfoCorps ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eRoleInfoAliasUI; ui = bp_roleinfo_alias; uiClass = RoleInfoAliasUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eRoleInfoShowInformation; ui = bp_lobby_roleinfo_showinformation; uiClass = RoleInfoShowInfoUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eRoleInfoTagUI; ui = bp_roleinfo_tag; uiClass = RoleInfoTagUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };

        --个人空间
        --{ UIType = eUIType.ePersonSpaceMainUI; ui = bp_person_space_main; uiClass = PersonSpaceMainUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.ePersonSpaceMainUI; ui = bp_person_space_main; uiClass = PersonSpaceMainUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eRoleInfoAchievementUI; ui = bp_roleinfo_achievement; uiClass = RoleInfoAchievementUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eRoleInfoSegmentUI; ui = bp_roleinfo_segment; uiClass = RoleInfoSegmentUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eRoleInfoCombatUI; ui = bp_roleinfo_combat; uiClass = RoleInfoCombatUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eRoleInfoCardPopupUI; ui = bp_roleinfo_card_popup; uiClass = RoleInfoCardPopupUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eCoupleAvatarMgrUI; ui = bp_couple_avatar_mgr; uiClass = CoupleAvatarMgrUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.ePersonSpaceRelationshipUI; ui = bp_person_space_relationship; uiClass = PersonSpaceRelationshipUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.ePersonSpaceSecrecySettingUI; ui = bp_person_space_secrecy_setting; uiClass = PersonSpaceSecrecySettingUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.ePersonSpacePartnerSettingUI; ui = bp_person_space_partner_setting; uiClass = PersonSpacePartnerSettingUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };


        { UIType = eUIType.eComplaintUI; ui = bp_complaint; uiClass = ComplaintUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eTaskUI; ui = bp_task; uiClass = TaskUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eAchievementDetailUI; ui = bp_achievement_detail; uiClass = AchievementDetailUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eShareAchievementUI; ui = bp_share_achievement; uiClass = ShareAchievementShareUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eAchievementUI; ui = bp_achievement; uiClass = AchievementTaskUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eTaskBackFlowUI; ui = bp_task_backflow; uiClass = TaskBackflowUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };

        { UIType = eUIType.eStoreUI; ui = bp_mall_system_2; uiClass = MallSystemUI_2 ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = true; depth = 100; bShow = false; };
        { UIType = eUIType.eMallBuy; ui = bp_mall_buy_item; uiClass = MallBuyItemUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eStoreBuy; ui = bp_store_buy; uiClass = StoreBuyUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eShopGift; ui = bp_shop_gift; uiClass = ShopGiftUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eShopGiftWithDay; ui = bp_shop_gift_with_day; uiClass = ShopGiftWithDayUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eShopGiftPacket; ui = bp_shop_gift_packet; uiClass = ShopGiftPacketUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eMallPageDIY; ui = bp_mall_page_diy; uiClass = MallPageDiyUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eMallBuyWithCount; ui = bp_mall_buy_item_with_count; uiClass = MallBuyItemWithCountUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eStorePriceSelect; ui = bp_store_price_select; uiClass = StorePriceSelect_UI; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eCoupons; ui = bp_coupons; uiClass = CouponsUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };

        --新版商城
        { UIType = eUIType.eStoreMainUI; ui = bp_store_main; uiClass = StoreMainUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eStoreRecommendPage; ui = bp_store_recommend_page; uiClass = StoreRecommendPage ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = true; depth = 100; bShow = false; };
        { UIType = eUIType.eStoreExchangePage; ui = bp_store_exchange; uiClass = StoreExchangeUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = true; depth = 100; bShow = false; };
        { UIType = eUIType.eStoreClothesPage; ui = bp_store_clothes; uiClass = StoreClothesUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eStorePurchasePopUpValidHour; ui = bp_store_purchase_popup_valid_hour; uiClass = nil ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eStoreWeaponPage; ui = bp_store_weapon; uiClass = StoreWeaponUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eStorePropPage; ui = bp_store_prop; uiClass = StorePropUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eStoreVehiclePage; ui = bp_store_vehicle; uiClass = StoreVehicleUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eStorePreviewPage; ui = bp_store_preview; uiClass = StorePreviewUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eStoreChestPage; ui = bp_store_chest; uiClass = StoreChestUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eStoreBindPhone; ui = bp_store_bind_phone; uiClass = StoreBindPhoneUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eStoreJumpToChest; ui = bp_store_jump_to_chest; uiClass = StoreJumpToChestUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };

        --新版补给
        { UIType = eUIType.eSupplyMainUI; ui = bp_supply_main; uiClass = SupplyMainUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eSupplyActivityUI; ui = bp_store_activity_supply; uiClass = StoreActivitySupply_UI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eSupplyValuableUI; ui = bp_store_valuable_supply; uiClass = StoreValuableSupply_UI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eSupplyNormalUI; ui = bp_store_normal_supply; uiClass = StoreNormalSupply_UI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        
        -- { UIType = eUIType.eRoleInfoBase; ui = bp_lobby_roleinfo_showinformation; uiClass =  ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eRoleinfoAlias; ui = bp_roleinfo_alias; uiClass = RoleInfoAliasUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eCountryarea; ui = bp_countryarea; uiClass = CountryareaUI ; uiNum = 2; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eHeadportrait; ui = bp_roleinfo_headportrait; uiClass = RoleInfoHeadportraitUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eAvatarframe; ui = bp_roleinfo_avatarframe; uiClass = RoleInfoAvatarFrameUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        
        { UIType = eUIType.eItemUpgrade; ui = bp_item_upgrade; uiClass = ItemUpgradeUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };

        { UIType = eUIType.eChatShareAchievementShow; ui = bp_chat_share_achievement_show; uiClass = ChatShareAchievementShow ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eChatRecruit; ui = bp_recruit; uiClass = RecruitUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eChatRoom; ui = bp_chat_room; uiClass = LobbyChatroomLogic; uiNum = 3; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eChatShareAchievement; ui = bp_chat_share_achievement; uiClass = ChatShareAchievement ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eChatEmoji; ui = bp_chat_emoji; uiClass = LobbyChatEmojiLogic ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };

        

        { UIType = eUIType.eAllianceForRoleInfo; ui = bp_allianceForRoleInfo; uiClass = AllianceRoleInfoUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eAlliance; ui = bp_alliance; uiNum = 4; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eAllianceCompetitionShop; ui = bp_alliance_competition_shop; uiClass = AllianceCompetitionShopUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };

        
        --排行榜相关
        { UIType = eUIType.eWarZoneRankUI; ui = bp_warzone_rank; uiClass = WarZoneRankUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eRegionStrongerRankUI; ui = bp_regionstrongerrank; uiClass = RegionStrongerRankUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eCountryStrongerRankUI; ui = bp_countrystrongerrank; uiClass = CountryStrongerRankUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eWarZoneMedalChooseUI; ui = bp_warzone_medalchoose; uiClass = WarZoneMedalChooseUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        
        -- 锦标赛
        { UIType = eUIType.eIndiaChampionShipMain; ui = bp_india_championship; uiClass = IndiaCompetitionUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eIndiaChampionShipIntroduce; ui = bp_india_champion_introduce; uiClass = IndiaCompetitionIntroduceUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eIndiaChampionShipPopUp; ui = bp_india_sign_up; uiClass = IndiaSignUpUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        
        -- 线上赛
        { UIType = eUIType.eLeagueGameFinalChampion; ui = bp_leagueGame_FinalChampion; uiClass = LeagueGameFinalChampionUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eIndiaChampionShipHistoryRecord; ui = bp_india_champion_history_record; uiClass = IndiaCompetitionHistoryRecordUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eLeagueGameIntroduce; ui = bp_leagueGame_introduce; uiClass = LeagueGameIntroduceUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };


        --房间
        { UIType = eUIType.eRoomWaitingUI; ui = bp_room_waiting; uiClass = RoomWaitingUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eRoomUI; ui = bp_room; uiClass = RoomUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eRoomCreateUI; ui = bp_room_create; uiClass = RoomCreateUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };

        
        --邮件
        { UIType = eUIType.eMailUI; ui = bp_mail; uiClass = MailUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eShopGiftMsgCenter; ui = bp_shop_gift_msgcenter; uiClass = ShopGiftMsgCenter ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eShopGiftViewUI; ui = bp_shop_gift_view; uiClass = ShopGiftViewUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };

        --通用物品列表
        { UIType = eUIType.eCommonItemListUI; ui = bp_common_item_list; uiClass = CommonItemListUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        --slua新界面部分
        --{ UIType = eUIType.eSluaMessageBoxUI; ui = "lobby_activity.anniversary_messageBox"; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        
        --聊天
        { UIType = eUIType.eChatMain; ui = bp_chat_main; uiClass = LobbyChatLogic ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eChatEmoji; ui = bp_chat_emoji; uiClass = LobbyChatEmojiLogic ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eChatLanguageSelect; ui = bp_chat_language_select; uiClass = ChatLanguageSelect ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };

        --组队选图界面
        { UIType = eUIType.eTemaupMatchInfo; ui = bp_teamup_match_info; uiClass = TeamUpMatchInfoUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eMatchLanguageSelect; ui = bp_match_language_select; uiClass = MatchLanguageSelect ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eTeamupMapTips; ui = bp_teamup_map_tips; uiClass = TeamUpMapTipsUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };

        { UIType = eUIType.eTheFirstCharge; ui = bp_thefirstcharge; uiClass = TheFirstChargeUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        --每日任务宝箱
        { UIType = eUIType.eTreasureBoxPopUp; ui = bp_common_treasurebox_popup; uiClass = CommonTreasureBoxPopup ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };
        { UIType = eUIType.eRatePanel; ui = bp_rate_panel; uiClass = Rate_Panel_UI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };

        { UIType = eUIType.eEightDayUI; ui = bp_eightday; uiClass = EightDayUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };

        { UIType = eUIType.eShareWarZoneTitletUI; ui = bp_share_warzone_title; uiClass = ShareWarZoneTitletUI ; uiNum = 1; BModule = true; BFullMode = true; BModel3D = false; depth = 100; bShow = false; };

    }
end

return UIController