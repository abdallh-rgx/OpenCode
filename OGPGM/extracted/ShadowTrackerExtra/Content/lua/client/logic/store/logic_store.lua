--这才是真正的商城，如假包换！

StoreSystem = StoreSystem or {
	store_version = 0,

	store_tab = 1,
	store_reddot = false,
	--StoreSystem.store_data[tab_id]来之StoreSystem.get_market_info_rsp的数据
	--StoreSystem.store_data.store_list来之StoreSystem.get_market_tab_list_rsp的数据
	store_data = {},

	supply_version = 0,
	supply_tab = 2,
	supply_reddot = false,
	--StoreSystem.supply_data[tab_id]来之StoreSystem.get_shop_info_rsp的数据
	--StoreSystem.supply_data.supply_list来之StoreSystem.get_shop_tab_list_rsp的数据
	supply_data = {},

	--限购信息
	buy_info = {},

	--礼包信息
	chest_info = {},

	-- “new”标签记录状态，记录是否已点击状态
	new_tag_info = nil,

    -- 记录角色uid，用于写本地缓存区分文件名用
    last_role_uid = 0,

	-- 商城页签id
	Page_ID_Recommend           = 31,	--推荐
	Page_ID_Cloth               = 32,	--服装
	Page_ID_Weapon              = 33,	--枪械
	Page_ID_Car                 = 34,	--载具
	Page_ID_Item                = 35,	--道具
	Page_ID_Exchange            = 36,	--兑换
	Page_ID_Collect             = 37,	--收藏
	Page_ID_Parachute			= 38,	--其他

	--衣服子页签
	label_subtype_suit               = 3201, --套装
	label_subtype_head               = 3202, --头部
	label_subtype_face               = 3203, --脸部
	label_subtype_clothes            = 3204, --衣服
	label_subtype_pants              = 3205, --裤子
	label_subtype_shoes              = 3206, --鞋子

	--武器子页签
	lable_subtype_weapon_suggest     = 3301, -- 推荐
	lable_subtype_weapon_skin_ar     = 3302, -- 突击步枪
	lable_subtype_weapon_skin_sr     = 3303, -- 狙击步枪
	lable_subtype_weapon_skin_smg    = 3304, -- 冲锋枪
	lable_subtype_weapon_skin_sog    = 3305, -- 散弹枪
	lable_subtype_weapon_skin_ciw    = 3306, -- 近战武器
	lable_subtype_weapon_skin_cb     = 3307, -- 弩
	lable_subtype_weapon_skin_mg     = 3308, -- 机枪
	lable_subtype_weapon_skin_hg     = 3309, -- 手枪

	label_subtype_pet   			 = 3801, --宠物
	label_subtype_parachute			 = 3802, --降落伞

	--------------------华丽的分割线--------------------

	--物品索引
	label_item_index_id                          = 1,   --物品ID
	label_item_index_count                       = 2,   --物品数量
	label_item_index_price_default               = 3,   --默认物品售价
	label_item_index_price_list                  = 4,   --物品售价列表
	label_item_index_hot_or_new                  = 5,   --右上角角标,0或者nil表示不显示,1是hot,2是new ...
	label_item_index_up_value                    = 6,   --左上角角标,up值
	label_item_index_up_time                     = 7,   --up的显示时间
	label_item_index_drop_type                   = 8,   --掉落分类
	label_item_index_rank                        = 9,   --排序
	label_item_index_special_mark                = 10,  --特殊标记,1节日
	label_item_index_time_limit                  = 11,  --下架时间
	label_item_index_can_gift                    = 12,  --是否可赠送
	label_item_index_discount                    = 13,  --折扣
	label_item_index_expression_id               = 14,  --红装表情
	label_item_index_timelimit_discount_end_time = 15,  --限时折扣结束时间
	label_item_index_img_path                    = 16,  --路径
	label_item_index_type                        = 17,  --类型
	label_item_index_skip_path                   = 18,  --跳转地址
	label_item_index_market_id                   = 19,  --商城ID
	label_item_index_buy_limit					 = 20,	--限购类型（限购信息）{type = num}
	label_item_index_start_time                  = 21,  --上架时间
	label_item_index_position                    = 22,  --推荐页物品位置,1是热卖,2是新品（不是HotNew标签）
	label_item_index_voucher                     = 23,	--代金券信息
	label_item_index_rate                        = 24,  --品质概率 （11版本需求）
	label_item_index_show_rate_type              = 25,  --显示概率的类型 （11版本需求）
	label_item_index_show_time_limit             = 26,  --是否显示显示倒计时
	label_item_index_show_new                    = 27,  --是否显示new
	label_item_index_hot_begin                   = 28,  --热卖开始时间
	label_item_index_hot_end                     = 29,  --热卖结束时间
	label_item_index_cout_down_time              = 30,  --限时销售时间
	label_item_index_vip              			 = 31,  --是否vip折扣商品

	--限购信息
	label_buy_limit_type_daily             = 1,   --每日限购
	label_buy_limit_type_week              = 2,   --每周限购
	label_buy_limit_type_permanent         = 3,   --永久限购

	--价格列表索引
	label_price_index_one_original_price = 1, --1原价
	label_price_index_one_discount_price = 2, --1折扣价
	label_price_index_ten_original_price = 3, --10连抽原价
	label_price_index_ten_discount_price = 4, --10连抽折扣价
	label_price_index_valid_hours        = 5, --时长
	label_price_index_price_type         = 6, --价格类型

	--货币类型
	label_price_type_bp               = 0,   --金币
	label_price_type_chip             = 1,   --银碎片
	label_price_type_uc               = 2,   --uc币
	label_price_type_fp               = 102,   --炸猪令牌
	label_price_type_exchage 		  = 4,	 --兑换券
	label_price_type_gold_chip        = 103,   --金碎片

	--限购信息
	label_buy_limit_type_daily             = 1,   --每日限购
	label_buy_limit_type_week              = 2,   --每周限购
	label_buy_limit_type_permanet          = 3,   --永久限购

	--------------------华丽的分割线--------------------

	--商城页签列表信息
	label_market_index_id            = 1,   --页签ID
	label_market_index_name          = 2,   --页签名称
	label_market_index_type          = 3,   --页签类型
	label_market_index_mini_bg       = 4,   --页签小背景
	label_market_index_big_bg        = 5,   --页签大背景
	label_market_index_is_open       = 6,   --页签是否开放
	label_market_index_open_time     = 7,   --页签开启时间
	label_market_index_close_time    = 8,   --页签结束时间
	label_market_index_rank          = 9,   --页签排序
	label_market_index_sub_list      = 10,  --子页签列表

	--商城页签详细信息
	label_market_index_id            = 1,  --页签ID
	label_market_index_sub_id        = 2,  --子页签ID
	label_market_index_market_list   = 3,  --商城列表
	label_market_index_banner_list   = 4,  --推荐页列表
	label_market_index_bg_img        = 5,  --页签背景图

	--------------------华丽的分割线--------------------

	--补给字段索引
	label_shop_index_id            = 1,   --补给ID
	label_shop_index_item_id       = 2,   --物品ID
	label_shop_index_sort          = 3,   --补给排序
	label_shop_index_begin_time    = 4,   --补给开始时间
	label_shop_index_end_time      = 5,   --补给结束时间
	label_shop_index_tab_bg        = 6,   --页签背景
	label_shop_index_img_bg        = 7,   --左侧大背景
	label_shop_index_mode          = 8,   --显示模式
	label_shop_index_is_rate_up    = 9,	  --是否显示概率UP
	label_shop_index_up_end_time   = 10, --概率UP结束时间
	label_shop_index_exchange_id   = 11,  --兑换物品id

	--显示模式
	label_show_mode_one           = 1,
	label_show_mode_two           = 2,
	label_show_mode_three         = 3,
	label_show_mode_count         = 4,

	--第一种显示模式
	label_shop_index_id                 = 1,   --补给ID
	label_shop_index_item_id            = 2,   --物品ID
	label_shop_index_banner             = 3,   --banner图
	label_shop_index_img                = 4,   --海报图
	label_shop_index_icon               = 5,   --宝箱icon
	label_shop_index_price_default      = 6,   --默认价格类型
	label_shop_index_price_list         = 7,   --价格列表
	label_shop_index_exchange_list      = 8,   --兑换物品列表
	--label_shop_index_recomment_list     = 9,   --推荐列表
	label_shop_index_item_list          = 10,  --物品列表
	label_shop_index_gender 	        = 11,  --默认显示的性别
	label_shop_index_upass_score        = 12,  --积分奖励
	label_shop_index_left_count_best    = 13,	--比得极品剩余次数
	label_shop_index_drop_rate_list     = 14, --掉落概率列表
	label_shop_index_preview_items      = 15, --预览穿着
	label_shop_index_home_bg            = 16,  --首页背景
	label_shop_index_detail_end_time  	= 17,  --详细页签的结束时间
	label_shop_index_show_up_end_time   = 18,  --up结束时间
	label_shop_index_vip              	= 19,  --vip类型

	-- 箱子中数据的显示模式
	label_drop_index_item_id          = 1,     -- 物品id
	label_drop_index_item_num         = 2,     -- 数量
	label_drop_index_chance           = 3,     -- 概率
	label_drop_index_item_time        = 5,     -- 限时
	label_drop_index_type             = 6,     -- 掉落方式
	label_drop_index_item_sort        = 7,     -- 排序
	label_drop_index_up_end_time      = 8,     -- up结束时间
	label_drop_index_old_chance       = 9,     -- 老概率
	label_drop_index_item_type        = 10,	   -- 掉落物品类型
	label_drop_index_expression_id 	  = 11,    -- 红装表情
	label_drop_index_return_money     = 12,	   -- 返回价值（减免价，礼包的掉落物品用）

	--------------------华丽的分割线--------------------

	-- 购买协议
	label_buy_param_id            = 1,			-- 商品id
	label_buy_param_type          = 2,			-- 商品类型
	label_buy_param_price_type    = 3,			-- 价格类型
	label_buy_param_tab_id        = 4,			-- 页签id
	label_buy_param_sub_id        = 5,			-- 子页签id
	label_buy_param_ver           = 6,			-- 版本号
	label_buy_param_valid_hours   = 7,			-- 时长
	label_buy_param_count         = 8,   		-- 数量
	label_buy_param_voucher       = 9,			-- 代金券

	--购买返回序列
	label_buy_rsp_item_id		  = 1,			-- 物品id
	label_buy_rsp_item_count 	  = 2,			-- 物品数量
	label_buy_rsp_item_valid 	  = 3,			-- 物品有效时长

	-- 错误码
	error_code_success            = 1, 			-- 购买成功
	error_code_uc_not_enough      = 2, 			-- uc不够
	error_code_bp_not_enough      = 3, 			-- bp不够
	error_code_fp_not_enough      = 4, 			-- 猪令牌不够
	error_code_config_error       = 5, 			-- 配置错误
	error_code_failed             = 6, 			-- 购买失败
	error_code_params             = 7, 			-- 参数错误
	error_code_voucher_not_enough = 8,  	  	-- 代金券不够
	error_code_silver_not_enough  = 9,   		-- 银碎片不够
	error_code_gold_not_enough    = 10,  		-- 金碎片不够
	error_code_sys_close  		  = 11,			-- 功能未开启
	error_code_not_vip			  = 12,			-- 非订阅会员

	--------------------华丽的分割线--------------------

	gift_index_uid            = 1,				-- 目标UID
	gift_index_market_id      = 2,				-- 物品的商城ID
	gift_index_buy_type       = 3,				-- 货币类型
	gift_index_market_count   = 4,				-- 物品数量
	gift_index_letter_style   = 5,				-- 信封类型
	gift_index_msg            = 6,				-- 留言
	gift_index_ver            = 7,				-- 商城版本
	gift_index_ask_index      = 8,				-- 索要ID
	gift_index_color          = 9,				--
	gift_index_pattern        = 10,				--
	gift_index_valid_hours    = 11,				-- 物品有效时长

	--------------------华丽的分割线--------------------

	currentTime = 0,
	preUpdateTime = 0,

	--------------------华丽的分割线--------------------

	-- 折扣活动数据的Condition
	label_discount_activity_product_id	= 1,	-- 商品id
	label_discount_activity_start_index	= 2,	-- 起始次数
	label_discount_activity_end_index = 3,		-- 结束次数
	label_discount_activity_number = 4,			-- 折扣
	label_discount_activity_valid_days	= 5,	-- 有效时长

	--------------------华丽的分割线--------------------
	my_collection_data = {},
	global_collection_num = {},
	collection_jump_info = {},
	collection_red_dot = {},

	current_source_type = 1,
	market_collect_source_market              = 1,       --商城
	market_collect_source_shop                = 2,       --补给
	market_collect_source_watch               = 3,       --观战
	market_collect_source_pspace              = 4,       --个人空间

	err_market_collect_success                = 0,         --收藏成功
	err_market_collect_limit_by_day           = 600001,    --每日收藏次数已达上限
	err_market_collect_limit_by_max_count     = 600002,    --收藏物品总数已达上限
	err_market_collect_item_had_collect       = 600003,    --收藏失败，物品已收藏
	err_market_collect_item_not_collect       = 600004,    --取消收藏失败，物品不在收藏中
	err_market_collect_item_not_exist         = 600005,    --收藏失败，物品不存在
	err_market_collect_item_can_not_collect   = 600006,    --收藏失败，物品不能被收藏
	err_market_collect_item_invaild_region    = 600007,    --地区不符，收藏失败

	-- 折扣活动数据的Condition
	label_discount_activity_product_id	= 1,	-- 商品id
	label_discount_activity_start_index	= 2,	-- 起始次数
	label_discount_activity_end_index = 3,		-- 结束次数
	label_discount_activity_number = 4,			-- 折扣
	label_discount_activity_valid_days	= 5,	-- 有效时长
}


--是否开启新版商城
function StoreSystem.IsUseNewStore()
	--local region = Client.GetPublishRegion();
	--if region == "JAPAN" or region == "KOREA" then
	--	return false
	--else
	--	return true
	--end
	return true;
end

function StoreSystem.Tick(deltaTime)
	StoreSystem.currentTime = StoreSystem.currentTime + deltaTime;
	if StoreSystem.currentTime - StoreSystem.preUpdateTime > 1 then
		StoreSystem.preUpdateTime = StoreSystem.currentTime;
		StoreClothesUI.UpdateLeftTime();
		StoreWeaponUI.UpdateLeftTime();
		StoreVehicleUI.UpdateLeftTime();
		StorePropUI.UpdateLeftTime();
		StoreExchangeUI.UpdateLeftTime()
	end
end

function StoreSystem.ResetData()
	log("[HHF]StoreSystem.ResetData");
	StoreSystem.store_reddot = false;
	StoreSystem.store_data = {};

	StoreSystem.supply_reddot = false;
	StoreSystem.supply_data = {};

	StoreSystem.currentTime = 0;
	StoreSystem.preUpdateTime = 0;

	StoreSystem.my_collection_data = {};
	StoreSystem.collection_red_dot = {};
	StoreSystem.global_collection_num = {};
end

function StoreSystem.ShowTipsByErrorCode(error_code)
	log("[HHF]StoreSystem.ShowTipsByErrorCode, error_code = " .. tostring(error_code));
	if error_code == StoreSystem.error_code_success then
		local tips = FuncUtil.GetLocalizeResStr(6493);
		PopUpNoticeUI.ShowNewNotice(tips);
	elseif error_code == StoreSystem.error_code_uc_not_enough then
		local tips = FuncUtil.GetLocalizeResStr(6494);
		PopUpNoticeUI.ShowNewNotice(tips);
	elseif error_code == StoreSystem.error_code_bp_not_enough then
		local tips = FuncUtil.GetLocalizeResStr(6495);
		PopUpNoticeUI.ShowNewNotice(tips);
	elseif error_code == StoreSystem.error_code_fp_not_enough then
		local tips = FuncUtil.GetLocalizeResStr(6496);
		PopUpNoticeUI.ShowNewNotice(tips);
	elseif error_code == StoreSystem.error_code_config_error then
		local tips = FuncUtil.GetLocalizeResStr(6497);
		PopUpNoticeUI.ShowNewNotice(tips);
	elseif error_code == StoreSystem.error_code_failed then
		local tips = FuncUtil.GetLocalizeResStr(6498);
		PopUpNoticeUI.ShowNewNotice(tips);
	elseif error_code == StoreSystem.error_code_params then
		local tips = FuncUtil.GetLocalizeResStr(6499);
		PopUpNoticeUI.ShowNewNotice(tips);

	elseif error_code == StoreSystem.err_market_collect_limit_by_day then
		local tips = FuncUtil.GetLocalizeResStr(6788);
		PopUpNoticeUI.ShowNewNotice(tips);
	elseif error_code == StoreSystem.err_market_collect_limit_by_max_count then
		local tips = FuncUtil.GetLocalizeResStr(6789);
		PopUpNoticeUI.ShowNewNotice(tips);
	elseif error_code == StoreSystem.err_market_collect_item_had_collect then
		local tips = FuncUtil.GetLocalizeResStr(6790);
		PopUpNoticeUI.ShowNewNotice(tips);
	elseif error_code == StoreSystem.err_market_collect_item_not_collect then
		local tips = FuncUtil.GetLocalizeResStr(6791);
		PopUpNoticeUI.ShowNewNotice(tips);
	elseif error_code == StoreSystem.err_market_collect_item_not_exist then
		local tips = FuncUtil.GetLocalizeResStr(6801);
		PopUpNoticeUI.ShowNewNotice(tips);
	elseif error_code == StoreSystem.err_market_collect_item_can_not_collect then
		local tips = FuncUtil.GetLocalizeResStr(6802);
		PopUpNoticeUI.ShowNewNotice(tips);
	elseif error_code == StoreSystem.err_market_collect_item_invaild_region then
		local tips = FuncUtil.GetLocalizeResStr(6879);
		PopUpNoticeUI.ShowNewNotice(tips);
	elseif error_code == StoreSystem.error_code_voucher_not_enough then
		local tips = FuncUtil.GetLocalizeResStr(6746);
		PopUpNoticeUI.ShowNewNotice(tips);
	elseif error_code == StoreSystem.error_code_silver_not_enough then
		local tips = FuncUtil.GetLocalizeResStr(4457);
		PopUpNoticeUI.ShowNewNotice(tips);
	elseif error_code == StoreSystem.error_code_gold_not_enough then
		local tips = FuncUtil.GetLocalizeResStr(6747);
		PopUpNoticeUI.ShowNewNotice(tips);
	elseif error_code == StoreSystem.error_code_sys_close then
		local tips = FuncUtil.GetLocalizeResStr(120001);
		PopUpNoticeUI.ShowNewNotice(tips);
	elseif error_code == StoreSystem.error_code_not_vip then
		local tips = FuncUtil.GetLocalizeResStr(6502);
		PopUpNoticeUI.ShowNewNotice(tips);
	else
		DataMgr.ShowNoticeByID(error_code);
	end
end

function StoreSystem.GetTabList(tab_type)
	if tab_type == StoreSystem.supply_tab then
		if GlobalData.IsJapanOrKorea() then
			StoreSystem.GetTabList(StoreSystem.store_tab);
		end

		if StoreSystem.supply_data.supply_list ~= nil then
			log("[HHF]StoreSystem.GetTabList, tab_type = " .. tostring(tab_type) .. ", have data and return immediately.");
			local data = {};
			data.tab_type = StoreSystem.supply_tab;
			data.data = StoreSystem.supply_data.supply_list;
			EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_SUPPLY_LIST, data);
		else
			log("[HHF]StoreSystem.GetTabList, no cache data and request server, tab_type = " .. tostring(tab_type));
			StoreSystem.get_shop_tab_list_req();
		end
	else
		if StoreSystem.store_data.store_list ~= nil then
			log("[HHF]StoreSystem.GetTabList, tab_type = " .. tostring(tab_type) .. ", have data and return immediately.");
			local data = {};
			data.tab_type = StoreSystem.store_tab;
			data.data = StoreSystem.store_data.store_list;

			if not GlobalData.IsJapanOrKorea() then
				EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_LIST, data);
			end
		else
			log("[HHF]StoreSystem.GetTabList, no cache data and request server, tab_type = " .. tostring(tab_type));
			StoreSystem.get_market_tab_list_req();
		end
	end
end

function StoreSystem.get_shop_tab_list_req()
	log("[HHF]StoreSystem.get_shop_tab_list_req, send get_shop_tab_list_req");

	NetUtil.SendPriorityPkg(false, "get_shop_tab_list_rsp", "get_shop_tab_list_req");
end

function StoreSystem.get_shop_tab_list_rsp(supply_version, supply_list)
	log("[HHF]StoreSystem.get_shop_tab_list_rsp, supply_version = " .. tostring(supply_version));
	--log_tree("[HHF]StoreSystem.get_shop_tab_list_rsp, supply_list = ", supply_list, "[HHF]")
	StoreSystem.ProcessVersion(StoreSystem.supply_tab, supply_version);

	StoreSystem.supply_data.supply_list = supply_list;
	local data = {};
	data.tab_type = StoreSystem.supply_tab;
	data.data = StoreSystem.supply_data.supply_list;
	EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_SUPPLY_LIST, data);

end

function StoreSystem.get_market_tab_list_req()
	log("[HHF]StoreSystem.get_market_tab_list_req, send get_market_tab_list_req");

	NetUtil.SendPriorityPkg(false, "get_market_tab_list_rsp", "get_market_tab_list_req");
end

function StoreSystem.get_market_tab_list_rsp(store_version, store_list)
	log("[HHF]StoreSystem.get_market_tab_list_rsp, store_version = " .. tostring(store_version));
	--log_tree("[HHF]StoreSystem.get_market_tab_list_rsp, store_list = ", store_list, "[HHF]")
	StoreSystem.ProcessVersion(StoreSystem.store_tab, store_version);

	StoreSystem.store_data.store_list = store_list;
	local data = {};
	data.tab_type = StoreSystem.store_tab;
	data.data = StoreSystem.store_data.store_list;
	if not GlobalData.IsJapanOrKorea() then
		EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_LIST, data);
	end
end

function StoreSystem.GetTabData(tab_type, tab_id)
	if tab_type == StoreSystem.supply_tab then
		if StoreSystem.supply_data[tab_id] ~= nil then
			log("[HHF]StoreSystem.GetTabData, tab_type = " .. tostring(tab_type) .. ", tab_id = " .. tostring(tab_id) .. ", have data and return immediately.");
			local data = {};
			data.tab_type = tab_type;
			data.tab_id = tab_id;
			data.data = StoreSystem.supply_data[tab_id];
			EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_SUPPLY_DATA, data);
		else
			log("[HHF]StoreSystem.GetTabData, tab_type = " .. tostring(tab_type) .. ", tab_id = " .. tostring(tab_id) .. ", no data and request server.");
			StoreSystem.get_shop_info_req(tab_id, 0);
		end
	else
		if StoreSystem.store_data[tab_id] ~= nil then
			log("[HHF]StoreSystem.GetTabData, tab_type = " .. tostring(tab_type) .. ", tab_id = " .. tostring(tab_id) .. ", have data and return immediately.");
			local data = {};
			data.tab_type = tab_type;
			data.tab_id = tab_id;
			data.data = StoreSystem.store_data[tab_id];

			EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_DATA, data);

			if not GlobalData.IsJapanOrKorea() then
				local BgUrl = StoreSystem.store_data[tab_id][StoreSystem.label_market_index_bg_img];
				StoreMainUI.UpdateBgUrl(tab_id, BgUrl);
			end
		else
			log("[HHF]StoreSystem.GetTabData, tab_type = " .. tostring(tab_type) .. ", tab_id = " .. tostring(tab_id) .. ", no data and request server.");
			StoreSystem.get_market_info_req(tab_id, 0);
		end
	end
end

function StoreSystem.get_shop_info_req(tab_id, sub_id)
	log("[HHF]StoreSystem.get_shop_info_req, tab_id = " .. tostring(tab_id) .. ", sub_id = " .. tostring(sub_id));
	--NetUtil.SendPkg("get_shop_info_req", tab_id, sub_id);
	NetUtil.SendPriorityPkg(false, "get_shop_info_rsp", "get_shop_info_req", tab_id, sub_id);
end

function StoreSystem.get_shop_info_rsp(supply_version, info)
	log("[HHF]StoreSystem.get_shop_info_rsp, supply_version = " .. tostring(supply_version));
	--log_tree("[HHF]StoreSystem.get_shop_info_rsp, info = ", info, "[HHF]");
	StoreSystem.ProcessVersion(StoreSystem.supply_tab, supply_version);

		if info ~= nil and info[StoreSystem.label_shop_index_id] ~= nil then
			local tab_id = info[StoreSystem.label_shop_index_id];
			StoreSystem.supply_data[tab_id] = info;
			local data = {};
			data.tab_type = StoreSystem.supply_tab;
			data.tab_id = tab_id;
			data.data = info;
			EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_SUPPLY_DATA, data);
			
		else
			log("[HHF]StoreSystem.get_market_info_rsp, Can't believe it!");
		end
	end

function StoreSystem.get_market_info_req(tab_id, sub_id)
	log("[HHF]StoreSystem.get_market_info_req, tab_id = " .. tostring(tab_id) .. ", sub_id = " .. tostring(sub_id));
	--NetUtil.SendPkg("get_market_info_req", tab_id, sub_id);
	NetUtil.SendPriorityPkg(false, "get_market_info_rsp", "get_market_info_req", tab_id, sub_id);
end

function StoreSystem.get_market_info_rsp(store_version, info)
	log("[HHF]StoreSystem.get_market_info_rsp, store_version = " .. tostring(store_version));
	--log_tree("[HHF]StoreSystem.get_market_info_rsp, info = ", info, "[HHF]");
	StoreSystem.ProcessVersion(StoreSystem.store_tab, store_version);

	if info ~= nil and info[StoreSystem.label_market_index_id] ~= nil then
		local tab_id = info[StoreSystem.label_market_index_id];
		StoreSystem.store_data[tab_id] = info;
		local data = {};
		data.tab_type = StoreSystem.store_tab;
		data.tab_id = tab_id;
		data.data = info;

		EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_DATA, data);
		CouponsSystem.OnSupplyDataUpdate(data.data)
		if not GlobalData.IsJapanOrKorea() then
			local BgUrl = StoreSystem.store_data[tab_id][StoreSystem.label_market_index_bg_img];
			StoreMainUI.UpdateBgUrl(tab_id, BgUrl);
		end
	else
		log("[HHF]StoreSystem.get_market_info_rsp, Can't believe it!");
	end
end

function StoreSystem.ProcessVersion(tab, version)
	log("[HHF]StoreSystem.ProcessVersion, tab = " .. tostring(tab) .. ", version = " .. tostring(version));

	if tab == StoreSystem.store_tab then
		if StoreSystem.store_version ~= version then
			log("[HHF]StoreSystem.ProcessVersion, old store_version = " .. tostring(StoreSystem.store_version) .. ", clear local cache.");
			StoreSystem.store_version = version;
			StoreSystem.store_data    = {};
			StoreSystem.store_reddot  = true;
			JumpUtils.bGetJumpMap = false;
			StoreSystem.chest_info = {};
		end
	elseif tab == StoreSystem.supply_tab then
		if StoreSystem.supply_version ~= version then
			log("[HHF]StoreSystem.ProcessVersion, old supply_version = " .. tostring(StoreSystem.supply_version) .. ", clear local cache.");
			StoreSystem.supply_version = version;
			StoreSystem.supply_data    = {};
			StoreSystem.supply_reddot  = true;
			JumpUtils.bGetJumpMap = false;
			StoreSystem.chest_info = {};
		end
	end
end

-- shop_id       = params[1]  --商城ID,或者补给箱ID
-- local market_type   = params[2]  --商品类型
-- price_type    = params[3]  --价格类型
-- tab_id        = params[4]  --页签ID
-- sub_id        = params[5]  --子页签ID
-- ver           = params[6]  --版本号
-- shop_count    = params[7]  --购买数量
-- buy_param_client_pay = params[10] --客户端显示价格（发给服务器做校验，打折活动用）
function StoreSystem.buy_shop_by_id_req(params)
	--log_tree("[HHF]StoreSystem.buy_shop_by_id_req, params = ", params, "[HHF]");
	NetUtil.SendPriorityPkg(true, "buy_shop_by_id_rsp", "buy_shop_by_id_req", params);
end

function StoreSystem.buy_shop_by_id_rsp(error_code, shop_id, info)
	log("[HHF]StoreSystem.buy_shop_by_id_rsp, error_code = " .. tostring(error_code));
	--log_tree("[HHF]StoreSystem.buy_shop_by_id_rsp, info = ", info, "[HHF]");
	if error_code == StoreSystem.error_code_success then
		EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_SUPPLY_BUY, shop_id, info);
	else
		StoreSystem.ShowTipsByErrorCode(error_code);
		if error_code == StoreSystem.error_code_uc_not_enough then-- uc不足
		    local title = Client.GetTableData("LocalizeRes", "101001").TextValue;
		    local tip = Client.GetTableData("LocalizeRes", "4119").TextValue;
		    CommonMessageBoxUI:ShowPanel(2, title, tip, function()
		            RechargeUI:Init();
		        return true;
		    end);
		end
	end
end

function StoreSystem.notice_shop_guarantee_reward(reward_items)
	log("[HHF]StoreSystem.notice_shop_guarantee_reward");
	log_tree("[HHF]StoreSystem.notice_shop_guarantee_reward, reward_items = ", reward_items, "[HHF]");

	OpenBoxtUI.NotifyMinGuaranteeInfo(reward_items);
end

function StoreSystem.receive_guarantee_reward_req(reward_items)
	log("[HHF]StoreSystem.receive_guarantee_reward_req, Send receive_guarantee_reward_req");
	log_tree("[HHF]StoreSystem.receive_guarantee_reward_req, reward_items = ", reward_items, "[HHF]");
	NetUtil.SendPriorityPkg(false, "receive_guarantee_reward_rsp", "receive_guarantee_reward_req", reward_items);
	--StoreSystem.receive_guarantee_reward_rsp(0, reward_items);
end

function StoreSystem.receive_guarantee_reward_rsp(err_code, reward_items)
	log("[HHF]StoreSystem.receive_guarantee_reward_rsp, err_code = " .. tostring(err_code));
	log_tree("[HHF]StoreSystem.receive_guarantee_reward_rsp, reward_items = ", reward_items, "[HHF]");

	if err_code == 0 then
		OpenBoxtUI.OnGetMinGuarantee();
	else
		if err_code == 9911005 then

		end
	end
end

function StoreSystem.buy_market_by_id_req(params)
	--log_tree("[HHF]StoreSystem.buy_market_by_id_req, params = ", params, "[HHF]");
	NetUtil.SendPriorityPkg(true, "buy_market_by_id_rsp", "buy_market_by_id_req", params);
end

function StoreSystem.buy_market_by_id_rsp(error_code, market_id, info)
	log("[HHF]StoreSystem.buy_market_by_id_rsp, error_code = " .. tostring(error_code));
	--log_tree("[HHF]StoreSystem.buy_market_by_id_rsp, info = ", info, "[HHF]");
	if error_code == StoreSystem.error_code_success then
		EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_BUY, { market_id = market_id,info = info });
	else
		StoreSystem.ShowTipsByErrorCode(error_code);
		if error_code == StoreSystem.error_code_uc_not_enough then
			local str = Client.GetTableData("LocalizeRes", "101001").TextValue
			local tip = Client.GetTableData("LocalizeRes", "4300").TextValue
			CommonMessageBoxUI:ShowPanel(2, str, tip, function()
				RechargeUI:Init()
				return true
			end)
		end
	end
end

function StoreSystem.sync_market_version(version, show_market_red)
	--log("[HHF]StoreSystem.sync_market_version, version = " .. tostring(version));
	log_tree("[HHF]StoreSystem.sync_market_version, version = ", version, "[HHF]");

	--接收商城红点数据
	StoreRedDotModel.OnRecvReddotRsp(show_market_red)

	StoreSystem.store_version = version[1] or 0;
	StoreSystem.supply_version = version[2] or 0;

	StoreSystem.store_data = {};
	StoreSystem.store_reddot = true;

	StoreSystem.supply_data = {};
	StoreSystem.supply_reddot = true;
	JumpUtils.bGetJumpMap = false
	log("[HHF]StoreSystem.sync_market_version, reset all data.");

	local curStatus = string.lower(LuaClassObj.GetGameStatus(bp_lobby));
	if curStatus == "lobby" then
		StoreSystem.get_market_tab_list_req();
		StoreSystem.get_shop_tab_list_req();
	end
end

function StoreSystem.get_market_buy_info_req_v3()
	log("get_market_buy_info_req_v3");
	NetUtil.SendPriorityPkg(false, "get_market_buy_info_rsp_v3", "get_market_buy_info_req_v3");
end

--拉取商城购买详细信息响应
function StoreSystem.get_market_buy_info_rsp_v3(list, isAll)
	log("get_market_buy_info_rsp_v3 :" .. isAll);

	if isAll == 1 then
		StoreSystem.buy_info = list
	else
		for i, v in pairs(list) do
			StoreSystem.buy_info[i] = v
		end
	end
	EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_BUY_INFO_CHANGE);
end

function StoreSystem.give_gift_from_market_req_v3(params)
	log("give_gift_from_market_req_v3")
	--log_tree("params", params);
	NetUtil.SendPriorityPkg(false, "give_gift_from_market_rsp_v3", "give_gift_from_market_req_v3", params)
end

function StoreSystem.give_gift_from_market_rsp_v3(error_code, askIndex)
	log("give_gift_from_market_rsp_v3: error_code = " .. error_code)

	if error_code == StoreSystem.error_code_success then
		local msg = string.format(DataMgr.GetMsgByID(501030), BP_STRUCT_Shop_GiftPack_Item_Info.pruduct_name, BP_STRUCT_Shop_GiftPack_Item_Info.toUserName);
		CommonMessageBoxUI:ShowPanel(1, DataMgr.GetMsgByID(102012), msg, ShopGiftPacketUI.HideUI, FuncUtil.GetLocalizeResStr("110036"));
		if askIndex ~= nil and askIndex > 0 then
			NetUtil.SendPkg("market_get_giftmsg_req", 12);
		end
	else
		StoreSystem.ShowTipsByErrorCode(error_code);
	end
end

function StoreSystem.update_shop_price_rsp_v3(shop_id, price_list)
	local supplyList = StoreSystem.supply_data;
	if supplyList == nil then
		return
	end
	if supplyList[shop_id] then
		supplyList[shop_id][StoreSystem.label_shop_index_price_list]  = price_list;
	end
	EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_SHOP_PRICE_LIST_CHANGE, {[1] = shop_id, [2] = price_list});
end

-- 请求礼包内容数据
function StoreSystem.GetChestInfo(market_id)
	if StoreSystem.chest_info[market_id] ~= nil then
		EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_CHEST_INFO, { marketId = market_id, info = StoreSystem.chest_info[market_id] });
	else
		StoreSystem.get_market_chest_info_req(market_id);
	end
end

-- 请求礼包内容数据
function StoreSystem.get_market_chest_info_req(market_id)
	NetUtil.SendPriorityPkg(false, "get_market_chest_info_rsp", "get_market_chest_info_req", market_id)
end

-- 礼包内容数据回包，data结构与label_shop_index_item_list对应的table相同
function StoreSystem.get_market_chest_info_rsp(res, market_id, data)
	if res ~= 0 then
		return;
	end
	--log_tree("StoreSystem.get_market_chest_info_rsp", data);
	StoreSystem.chest_info[market_id] = data;
	EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_CHEST_INFO, { marketId = market_id, info = StoreSystem.chest_info[market_id] });
end

-- 购买礼包后展示获得物品
--bug=71872543 【全量测试】邮件-礼物中心：多物品（礼包和商品）一起领取，礼包"领取"没有反馈
--领取赠送物品后，统一走market_buy_chest_item_notify（包括礼包（自动打开）和单个物品）----steveou 后台jielingyin
function StoreSystem.market_buy_chest_item_notify(res, itemList)
	if res == "ok" then
		sandbox.LogNormal("market_buy_chest_item_notify success ");
		--log_tree("itemList", itemList);
		local rewardList = {};
		itemList = StoreSystem.MergeRewardList(itemList);
		--log_tree("after merge:itemList", itemList);
		for _, v in pairs(itemList) do
			local limitTime = v.valid_hours or 0;
			if limitTime == 0 then
				local cfg = Client.GetTableData("Item", v.resid);
				if cfg and cfg.ValidTimes ~= 0 then
					limitTime = cfg.ValidTimes;
				else
					limitTime = 0;
				end
			end
			table.insert(rewardList, {res_id = v.resid, count = v.count, valid_hours = limitTime});
		end
		--log_tree("rewardList", rewardList);
		if #rewardList > 0 then
			CommonItemGetUI:ShowPanel(rewardList);
		end
	else
		DataMgr.ShowNoticeByID(res);
	end
end

-- 前台合并奖励列表 用于显示
function StoreSystem.MergeRewardList(list)
	local ret = {};
	for _,v in pairs(list) do
		local key = string.format("%d_%d", v.resid, v.valid_hours or 0);
		if ret[key] == nil then
			ret[key] = v;
		else
			--数量叠加
			ret[key].count = ret[key].count + v.count;
		end
	end
	return ret;
end

function StoreSystem.ReceivedCollectionData(data)
	log("[HHF]StoreSystem.ReceivedCollectionData, data = " .. tostring(data));
	log_tree("[HHF]StoreSystem.ReceivedCollectionData, data = ", data, "[HHF]");
	StoreSystem.my_collection_data = data;
end

function StoreSystem.IsCollectedByItemID(itemID)
	if StoreSystem.my_collection_data == nil or StoreSystem.my_collection_data.market_collect_item_table == nil then
		return false;
	else
		return StoreSystem.my_collection_data.market_collect_item_table[itemID] ~= nil;
	end
end

function StoreSystem.GetNotifyCheckedState()
	if StoreSystem.my_collection_data == nil then
		return false;
	else
		return StoreSystem.my_collection_data.is_market_collect_notify or false;
	end
end

function StoreSystem.get_global_market_collect_data_req()
	log("[HHF]StoreSystem.get_global_market_collect_data_req");
	NetUtil.SendPriorityPkg(false, "get_global_market_collect_data_rsp", "get_global_market_collect_data_req");
end

function StoreSystem.get_global_market_collect_data_rsp(global_collection_num)
	log_tree("[HHF]StoreSystem.get_global_market_collect_data_rsp, global_collection_num = ", global_collection_num, "[HHF]");
	StoreSystem.global_collection_num = global_collection_num;
end

function StoreSystem.add_market_collect_by_item_req(item_id, source_type)
	log("[HHF]StoreSystem.add_market_collect_by_item_req, item_id = " .. tostring(item_id) .. ", source_type = " .. tostring(source_type));
	StoreSystem.current_source_type = source_type;
	NetUtil.SendPriorityPkg(false, "add_market_collect_by_item_rsp", "add_market_collect_by_item_req", item_id, source_type);
end

function StoreSystem.add_market_collect_by_item_rsp(err_code, market_collect_data, source_type)
	log("[HHF]StoreSystem.add_market_collect_by_item_rsp, err_code = " .. tostring(err_code));
	if err_code == StoreSystem.err_market_collect_success then
		StoreSystem.ReceivedCollectionData(market_collect_data);
		EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_COLLECT);

		local tips
		if source_type == StoreSystem.market_collect_source_pspace then
			tips = FuncUtil.GetLocalizeResStr(6875);
		else
			tips = FuncUtil.GetLocalizeResStr(6797);
		end
		PopUpNoticeUI.ShowNewNotice(tips);

	else
		local havePopup = false;
		if err_code == StoreSystem.err_market_collect_limit_by_max_count then
			local curStatus = string.lower(LuaClassObj.GetGameStatus(bp_lobby));
			if curStatus == "lobby" and StoreSystem.current_source_type == StoreSystem.market_collect_source_market then
				local title = FuncUtil.GetLocalizeResStr(110115);
				local okLabel = FuncUtil.GetLocalizeResStr(6874);
				local cancelLabel = FuncUtil.GetLocalizeResStr(110035);
				local tips = FuncUtil.GetLocalizeResStr(6873);
				CommonMessageBoxUI:ShowPanel(2, title, tips,
					function()
						if UIManager.GetUI(eUIType.eStorePreviewPage) then
							StorePreviewUI.ForceClose();
						end
						local param = {};
						param.Tab1 = StoreSystem.Page_ID_Collect;
						param.Tab2 = 0;
						param.itemId = 0;
						param.bValid = true;
						StoreMainUI.JumpFromStoreToStore(param);
					end,
					nil,
					okLabel,
					cancelLabel);

				havePopup = true;
			end
		end

		if havePopup == false then
			StoreSystem.ShowTipsByErrorCode(err_code);
		end
	end
end

function StoreSystem.cancel_market_collect_by_item_req(item_id)
	log("[HHF]StoreSystem.cancel_market_collect_by_item_req, item_id = " .. tostring(item_id));
	NetUtil.SendPriorityPkg(false, "cancel_market_collect_by_item_rsp", "cancel_market_collect_by_item_req", item_id);
end

function StoreSystem.cancel_market_collect_by_item_rsp(err_code, market_collect_data)
	log("[HHF]StoreSystem.cancel_market_collect_by_item_rsp, err_code = " .. tostring(err_code));
	if err_code == StoreSystem.err_market_collect_success then
		StoreSystem.ReceivedCollectionData(market_collect_data);
		EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_COLLECT);
		local tips = FuncUtil.GetLocalizeResStr(6798);
		PopUpNoticeUI.ShowNewNotice(tips);
	else
		StoreSystem.ShowTipsByErrorCode(err_code);
	end
end

function StoreSystem.batch_add_market_collect_req(item_list, source_type)
	log("[HHF]StoreSystem.batch_add_market_collect_req, source_type = " .. tostring(source_type));
	log_tree("[HHF]StoreSystem.batch_add_market_collect_req, item_list = ", item_list, "[HHF]");
	StoreSystem.current_source_type = source_type;
	NetUtil.SendPriorityPkg(false, "batch_add_market_collect_rsp", "batch_add_market_collect_req", item_list, source_type);
end

function StoreSystem.batch_add_market_collect_rsp(err_code, add_item_list, market_collect_data, source_type)
	log("[HHF]StoreSystem.batch_add_market_collect_rsp, err_code = " .. tostring(err_code));
	if err_code == StoreSystem.err_market_collect_success then
		StoreSystem.ReceivedCollectionData(market_collect_data);
		EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_COLLECT);

		local tips
		if source_type == StoreSystem.market_collect_source_pspace then
			tips = FuncUtil.GetLocalizeResStr(6875);
		else
			tips = FuncUtil.GetLocalizeResStr(6797);
		end
		PopUpNoticeUI.ShowNewNotice(tips);
	else
		StoreSystem.ShowTipsByErrorCode(err_code);
	end
end

function StoreSystem.get_market_collect_jump_info_req()
	log("[HHF]StoreSystem.get_market_collect_jump_info_req");
	NetUtil.SendPriorityPkg(false, "get_market_collect_jump_info_rsp", "get_market_collect_jump_info_req");
end

function StoreSystem.get_market_collect_jump_info_rsp(market_collect_jump_info)
	log_tree("[HHF]StoreSystem.get_market_collect_jump_info_rsp, market_collect_jump_info = ", market_collect_jump_info, "[HHF]");
	StoreSystem.collection_jump_info = market_collect_jump_info;
	EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_COLLECT_JUMPINFO);
end

function StoreSystem.get_market_collect_red_point_rsp(need_red_point_table)
	log_tree("[HHF]StoreSystem.get_market_collect_red_point_rsp, need_red_point_table = ", need_red_point_table, "[HHF]");
	StoreSystem.collection_red_dot = need_red_point_table;
	if FuncUtil:CountTable(StoreSystem.collection_red_dot) > 0 then
		if StoreRedDotModel.reddotMap == nil then
			StoreRedDotModel.reddotMap = {};
		end

		if StoreRedDotModel.reddotMap[StoreRedDotModel.MODEL_ID_TAB1] == nil then
			StoreRedDotModel.reddotMap[StoreRedDotModel.MODEL_ID_TAB1] = {};
		end

		StoreRedDotModel.reddotMap[StoreRedDotModel.MODEL_ID_TAB1][StoreSystem.Page_ID_Collect] = true;
	end
end

function StoreSystem.NeedShowReddotByItem(itemID)
	return StoreSystem.collection_red_dot[itemID] ~= nil;
end

function StoreSystem.set_market_collect_notify_req(is_notify)
	log("[HHF]StoreSystem.set_market_collect_notify_req, is_notify = " .. tostring(is_notify));
	NetUtil.SendPriorityPkg(false, "set_market_collect_notify_rsp", "set_market_collect_notify_req", is_notify);
end

function StoreSystem.set_market_collect_notify_rsp(err_code, market_collect_data)
	log("[HHF]StoreSystem.set_market_collect_notify_rsp, err_code = " .. tostring(err_code));
	if err_code == StoreSystem.err_market_collect_success then
		StoreSystem.ReceivedCollectionData(market_collect_data);
		EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_COLLECT, true);
	else
		StoreSystem.ShowTipsByErrorCode(err_code);
	end
end

--加載所有商品的“新”标签数据
function StoreSystem.LoadNewTagData()
	local str = Client.LoadFileToString("SaveGames/StoreNewTagData_"..tostring(DataMgr.roleData.uid)..".json")
	log("StoreSystem.LoadNewTagData() "..str)
	if str == "" or str == nil then
		log(" str ==  or str == nil"..str)
		StoreSystem.new_tag_info = {}
		return
	end
	StoreSystem.new_tag_info = json.decode(str)
end

--保存所有商品的“新”标签数据
function StoreSystem.SaveNewTagData()
	local str = json.encode(StoreSystem.new_tag_info)
	if str == "" then
		return
	end
	StoreSystem.last_role_uid = DataMgr.roleData.uid;
	Client.SaveStringToFile(str, "SaveGames/StoreNewTagData_"..tostring(DataMgr.roleData.uid)..".json")
end

function StoreSystem.CheckHasRecordNewTag(marketId)
	if StoreSystem.new_tag_info == nil or StoreSystem.last_role_uid ~= DataMgr.roleData.uid then
		StoreSystem.LoadNewTagData();
	end
	return StoreSystem.new_tag_info[tostring(marketId)] == 1;
end

function StoreSystem.CheckRecordNewTag(marketId)
	if StoreSystem.new_tag_info == nil or StoreSystem.last_role_uid ~= DataMgr.roleData.uid then
		StoreSystem.LoadNewTagData();
	end
	if StoreSystem.new_tag_info[tostring(marketId)] == nil then
		StoreSystem.new_tag_info[tostring(marketId)] = 1;
		StoreSystem.SaveNewTagData();
		EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_NEW_DATA_CHANGE, marketId);
	end
end

s2c["get_shop_tab_list_rsp"] = StoreSystem.get_shop_tab_list_rsp;
s2c["get_market_tab_list_rsp"] = StoreSystem.get_market_tab_list_rsp;
s2c["get_shop_info_rsp"] = StoreSystem.get_shop_info_rsp;
s2c["get_market_info_rsp"] = StoreSystem.get_market_info_rsp;
s2c["buy_shop_by_id_rsp"] = StoreSystem.buy_shop_by_id_rsp;
s2c["buy_market_by_id_rsp"] = StoreSystem.buy_market_by_id_rsp;
s2c["sync_market_version"] = StoreSystem.sync_market_version;
s2c["get_market_buy_info_rsp_v3"] = StoreSystem.get_market_buy_info_rsp_v3;
s2c["give_gift_from_market_rsp_v3"] = StoreSystem.give_gift_from_market_rsp_v3;
s2c["update_shop_price_rsp_v3"] = StoreSystem.update_shop_price_rsp_v3;
s2c["get_market_chest_info_rsp"] = StoreSystem.get_market_chest_info_rsp;
s2c["market_buy_chest_item_notify"] = StoreSystem.market_buy_chest_item_notify;
s2c["get_global_market_collect_data_rsp"] = StoreSystem.get_global_market_collect_data_rsp;
s2c["add_market_collect_by_item_rsp"] = StoreSystem.add_market_collect_by_item_rsp;
s2c["cancel_market_collect_by_item_rsp"] = StoreSystem.cancel_market_collect_by_item_rsp;
s2c["batch_add_market_collect_rsp"] = StoreSystem.batch_add_market_collect_rsp;
s2c["get_market_collect_jump_info_rsp"] = StoreSystem.get_market_collect_jump_info_rsp;
s2c["get_market_collect_red_point_rsp"] = StoreSystem.get_market_collect_red_point_rsp;
s2c["set_market_collect_notify_rsp"] = StoreSystem.set_market_collect_notify_rsp;
s2c["notice_shop_guarantee_reward"] = StoreSystem.notice_shop_guarantee_reward;
s2c["receive_guarantee_reward_rsp"] = StoreSystem.receive_guarantee_reward_rsp;
