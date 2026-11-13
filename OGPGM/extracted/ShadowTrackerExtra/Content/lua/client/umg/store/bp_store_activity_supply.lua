-- 活动补给UI模块
StoreActivitySupply_UI = StoreActivitySupply_UI or 
{
	isInit = false,
	isShow = false,
	needJump = false,
	needUpdateItemList = false,-- 性能优化：
}

-- BP-LUA结构定义 BEGIN--
-- 当前宝箱是数据(有同类结构，修改需要全局搜索并且同步)
BP_STRUCT_STORE_ACTIVITY_SUPPLY_ITEM = 
{
	product_id = 0,	-- 商品ID
	item_id = 0,	-- 物品ID

	product_desc_id = 0,	-- 物品描述(本地化表)
	product_type = 0,	-- 商品类型
	product_sub_type = 0,	-- 商品子类型

	product_gold_price = 0,	-- 金币价格
	product_sort = 1,	-- 排序
	price_type = 0,		-- 价格类型

	--orgin_ticket_price = 0,	--TP原始价格（折前价格，蓝图暂时不需要）
	ticket_price = 0,-- TP最终价格（折后价格）

	fp_token_price = 0,--炸猪令牌价格
	is_fp_token_valid = false,--是否可用炸猪令牌购买

	end_time = 0,	-- 宝箱结束时间

	is_cur_season = 0,  -- 勇者令积分
	gender = 0,		-- 显示性别	

	key_item_id = 0, -- 开启道具ID
	key_number = 0, -- 道具数量
	have_item_number = 0, -- 拥有道具的数量

	ten_price = 0,			-- 十连抽价格

	is_rate_up = false,		-- 概率是否提升
	rate_up_end_time = 0,	-- 概率提升时间结束点

	home_page_tex_path = "",	-- 首页路径
	item_list_tex_path = "",	-- 详情底图路径
	poster_path = "",			-- 海报

	icon_tex_path = "",			-- 宝箱路径

	lowest_rounds = 0,			-- 必开极品剩余次数

	ten_origin_price = 0,			-- 十连抽UC原价
	is_discount = false,			-- 单抽是否打折
	discount_number = 0,			-- 单抽折扣
	discount_total_count = 0,		-- 单抽折扣次数
	discount_use_count = 0,			-- 单抽已消耗折扣次数
	discount_next_number = 0,		-- 单抽下一次折扣
	discount_next_start_time = 0,	-- 单抽下一次折扣时间

	is_discount_ten = false,			-- 十连抽是否打折
	discount_number_ten = 0,			-- 十连抽折扣
	discount_total_count_ten = 0,		-- 十连抽折扣次数
	discount_use_count_ten = 0,			-- 十连抽已消耗折扣次数
	discount_next_number_ten = 0,		-- 十连抽下一次折扣
	discount_next_start_time_ten = 0,	-- 十连抽下一次折扣时间

	discount_type = 0,					-- 折扣类型

	vip_type = 0,						-- vip类型
	vip_discount = 0,					-- vip折扣
	test_value = 0,						-- 解决报错

	--drop_rate = {},			-- 展示掉率列表（lua中使用，所以不需要在这里定义）
	--preview_items = {},		-- 预览穿着（lua中使用，所以不需要在这里定义）
}

-- 具体掉落物结构(有同类结构，修改需要全局搜索并且同步)
BP_STRUCT_STORE_ACTIVITY_SUPPLY_DROP_ITEM =
{
	DropIndex = 0,		-- 物品索引ID
	DropItemID = 0,		-- 物品ID
	DropItemNum = 0,	-- 物品数量
	DropItemSort = 1,	-- 物品排序ID
	DropRate_f = 1,		-- 最终概率
	rate_up_end_time = 0,	-- 概率提升时间结束点
	drop_type = 0,			-- 物品掉落分类
	is_equiped = false,     -- 是否已装备
	is_hot = false,			-- 是否热卖
	is_new = false,			-- 是否新品
	expression_id = 0,		-- 红装表情ID
	is_limit_time = true,	-- 是否限时
	limit_end_time = 0,		-- 限时时间
}

-- 复用式结构
BP_STRUCT_STORE_ACTIVITY_SUPPLY_REUSE_ITEM =
{
	item_type = 0,-- 1:标题 2:物品列表（1-3个）
	title_name_text = "",-- item_type = 1时用
	BP_ARRAY_ITEM_LIST = { BP_STRUCT_STORE_ACTIVITY_SUPPLY_DROP_ITEM = _G.BP_STRUCT_STORE_ACTIVITY_SUPPLY_DROP_ITEM },-- BP_ARRAY_STORE_ACTIVITY_SUPPLY_ITEM_LIST的索引
}
-- BP-LUA结构定义 END--
--==========================
-- BP-LUA字段定义 BEGIN--
-- 复用式结构列表
BP_ARRAY_STORE_ACTIVITY_SUPPLY_REUSE_ITEM_LIST = 
{
	BP_STRUCT_STORE_ACTIVITY_SUPPLY_REUSE_ITEM = _G.BP_STRUCT_STORE_ACTIVITY_SUPPLY_REUSE_ITEM,
}

-- 实际物品数据列表
BP_ARRAY_STORE_ACTIVITY_SUPPLY_DROP_ITEM_LIST = 
{
	BP_STRUCT_STORE_ACTIVITY_SUPPLY_DROP_ITEM = _G.BP_STRUCT_STORE_ACTIVITY_SUPPLY_DROP_ITEM,
}

-- 页签（首页 1/详情 2）
BP_STORE_ACTIVITY_SUPPLY_PAGE = 1;

BP_STORE_ACTIVITY_SUPPLY_EXPRESSION_ID = 0;
-- 当前补给ID
BP_STORE_ACTIVITY_SUPPLY_SUPPLY_ID = 0;
-- 选中物品索引
BP_STORE_ACTIVITY_SUPPLY_SELECT_INDEX = -1;
-- 选中物品ID
BP_STORE_ACTIVITY_SUPPLY_SELECT_ITEM_ID = -1;
-- 当前性别
BP_STORE_ACTIVITY_SUPPLY_SEX = 0;
-- 用于跳转到指定reuse item的索引
BP_STORE_ACTIVITY_JUMP_IDX = -1;
-- 是否显示表情按钮
BP_STORE_ACTIVITY_SHOW_EMOTION_BTN = false;
-- 是否显示tips(第一次打开时显示)
BP_STORE_ACTIVITY_SHOW_GUIDE_TIPS = false;
-- 持枪状态记录
BP_STORE_ACTIVITY_DisplayType = 1;
-- 是否显示持枪按钮
BP_STORE_ACTIVITY_SHOW_DiplayType_BTN = false;
--升级物品展示用
BP_STORE_ACTIVITY_SUPPLY_LEVELUP_ITEMID = -1;
--死亡盒子展示用
BP_STORE_ACTIVITY_CurrentDeadboxPath = ""
-- 打折活动时间
BP_STORE_ACTIVITY_SUPPLY_DISCOUNT_TIME_PERIOD = "";
-- 打折活动帮助按钮位置
BP_STRUCT_STORE_ACTIVITY_SUPPLY_DISCOUNT_HELP_POS = { x = 0, y = 0};
-- BP-LUA字段定义 END--

function bp_store_activity_supply_RegisterUI()
    log("bp_store_activity_supply_RegisterUI");

	LuaClassObj.SubUIWidgetList(bp_store_activity_supply,
		{{Path="/Game/UMG/UI_Logic/Store/Supply/Supply_Activity_BP.Supply_Activity_BP_C", Container="Default", ZOrder=0}},
      	{"Lobby"},
	  	false,
	  	false,
	    true
    );
end

-- 初始化接口（框架调用）
function StoreActivitySupply_UI.Init()
	log("StoreActivitySupply_UI.Init")
	if StoreActivitySupply_UI.isInit == true then
		return;
	end
	BP_STORE_ACTIVITY_SUPPLY_SELECT_ITEM_ID = -1;
	BP_STORE_ACTIVITY_SUPPLY_LEVELUP_ITEMID = -1;
	BP_STORE_ACTIVITY_SUPPLY_SELECT_INDEX = -1;
	StoreActivitySupply_UI.isInit = true;
end

-- 释放接口（框架调用）
function StoreActivitySupply_UI.Release()
	if not StoreActivitySupply_UI.isInit then
		return;
	end
	StoreActivitySupply_UI.isInit = false;
end

-- 打开接口（框架调用）
function StoreActivitySupply_UI.Show(supplyID, page)
	log("StoreActivitySupply_UI.Show");
	StoreActivitySupply_UI.Init();

    BP_STORE_ACTIVITY_SUPPLY_SUPPLY_ID = supplyID;
	BP_STORE_ACTIVITY_SHOW_DiplayType_BTN = false;
	StoreActivitySupply_UI.isShow = true;
	BP_STORE_ACTIVITY_DisplayType = 1;
	BP_STORE_ACTIVITY_SUPPLY_PAGE = page or 1;

	BP_STORE_ACTIVITY_SUPPLY_SEX = MultipleAvatar.ShowingAvatarSextype;

	StoreActivitySupply_UI.RegistEvent();
	LuaClassObj.HandleDynamicCreation(bp_store_activity_supply);
	LuaClassObj.HandleUIMessageNoFetch(bp_store_activity_supply, "Init");
	LuaClassObj.HandleUIMessageNoFetch(bp_store_activity_supply, "ShowUI");
	if UIManager.GetUI(eUIType.eSupplyActivityUI) == nil then
		UIManager.Show(eUIType.eSupplyActivityUI);
		UIManager.Show(eUIType.eSupplyMainUI);
		if UIManager.GetUI(eUIType.eCorpsWelfareRedEnvelopes) ~= nil then
			UIManager.Show(eUIType.eCorpsWelfareRedEnvelopes)
		end
	end
	StoreActivitySupply_UI.UpdateView();
	StoreActivitySupply_UI.CheckShowGuideTips();
end

function StoreActivitySupply_UI.UIOnlyShow()
	StoreActivitySupply_UI.isShow = true;
	LobbyCameraManager.SwitchCamera(LobbyCameraManager.store_supply)
	LuaClassObj.HandleUIMessageNoFetch(bp_store_activity_supply, "OnlyShowUI");
end

function StoreActivitySupply_UI.UIOnlyHide()
	StoreActivitySupply_UI.isShow = false;
	StoreActivitySupply_UI.OnDeadBoxRestore()
	LuaClassObj.HandleUIMessageNoFetch(bp_store_activity_supply, "OnlyHideUI");
end

-- 关闭接口（框架调用）
function StoreActivitySupply_UI.Hide()
	if UIManager.GetUI(eUIType.eSupplyActivityUI) == nil then
		return
	end
	log("StoreActivitySupply_UI.Hide")
	StoreActivitySupply_UI.isShow = false;
	StoreActivitySupply_UI.OnDeadBoxRestore()
	StoreActivitySupply_UI.UnRegistEvent();

	LuaClassObj.HandleUIMessageNoFetch(bp_store_activity_supply, "HideUI");
	UIManager.Hide(eUIType.eSupplyActivityUI)
end

-- 注册事件（界面打开时）
function StoreActivitySupply_UI.RegistEvent()
	EventSystem:registEvent(EVENTTYPE_STORE_DATA, EVENTID_SUPPLY_DATA, StoreActivitySupply_UI.OnSupplyDataUpdate);
	EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_DATA_CHANGE, StoreActivitySupply_UI.OnBagItemChange);
	EventSystem:registEvent(EVENTTYPE_STORE_DATA, EVENTID_SHOP_PRICE_LIST_CHANGE, StoreActivitySupply_UI.OnBagItemChange);
	EventSystem:registEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_ONCLICK_LEVELUPPREVIEW, StoreActivitySupply_UI.OnClickUpgradeLevelBtn);
	EventSystem:registEvent(EVENTTYPE_ACTIVITY, EVENTID_SUPPLY_DISCOUNT_UPDATE, StoreActivitySupply_UI.OnBagItemChange);
	EventSystem:registEvent(EVENTTYPE_ACTIVITY, EVNETID_DATAMGR_ACTIVITY_CHANGE, StoreActivitySupply_UI.OnBagItemChange);
	EventSystem:registEvent(EVENTTYPE_SUBSCRIBE, EVENTID_SUBSCRIBE_GET_STATUS_DATA, StoreActivitySupply_UI.OnBagItemChange);
end

-- 反注册事件（界面关闭时）
function StoreActivitySupply_UI.UnRegistEvent()
	EventSystem:unregistEvent(EVENTTYPE_STORE_DATA, EVENTID_SUPPLY_DATA, StoreActivitySupply_UI.OnSupplyDataUpdate);
	EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_DATA_CHANGE, StoreActivitySupply_UI.OnBagItemChange);
	EventSystem:unregistEvent(EVENTTYPE_STORE_DATA, EVENTID_SHOP_PRICE_LIST_CHANGE, StoreActivitySupply_UI.OnBagItemChange);
	EventSystem:unregistEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_ONCLICK_LEVELUPPREVIEW, StoreActivitySupply_UI.OnClickUpgradeLevelBtn);
	EventSystem:unregistEvent(EVENTTYPE_ACTIVITY, EVENTID_SUPPLY_DISCOUNT_UPDATE, StoreActivitySupply_UI.OnBagItemChange);
	EventSystem:unregistEvent(EVENTTYPE_ACTIVITY, EVNETID_DATAMGR_ACTIVITY_CHANGE, StoreActivitySupply_UI.OnBagItemChange);
	EventSystem:unregistEvent(EVENTTYPE_SUBSCRIBE, EVENTID_SUBSCRIBE_GET_STATUS_DATA, StoreActivitySupply_UI.OnBagItemChange);
end

-- 跳转接口（框架调用）
function StoreActivitySupply_UI.JumpTo(supplyID, jumpInfo)
	StoreActivitySupply_UI.needJump = true;
	StoreActivitySupply_UI.jumpInfo = jumpInfo;
 	StoreActivitySupply_UI.Show(supplyID, 2);
	LuaClassObj.HandleUIMessageNoFetch(bp_store_activity_supply, "UpdateShowView")
end

-- 收到补给详情数据
function StoreActivitySupply_UI.OnSupplyDataUpdate(event_type, event_id, data)
	if data.tab_type ~= StoreSystem.supply_tab or data.tab_id ~= BP_STORE_ACTIVITY_SUPPLY_SUPPLY_ID then
		return;
	end
	if StoreActivitySupply_UI.isShow == false then
		return;
	end
	--log_tree("StoreActivitySupply_UI.OnSupplyDataUpdate", data);
	-- 刷新数据
	StoreActivitySupply_UI.UpdateData();
	-- 刷新表情按钮
	StoreActivitySupply_UI.UpdateEmotionBtn();
	-- 刷新武器人物切换按钮
	StoreActivitySupply_UI.UpdateDisplayType();
	-- 设置跳转idx（有可能为-1）
	if BP_STORE_ACTIVITY_SUPPLY_PAGE ~= 1 then
		if StoreActivitySupply_UI.needJump then
			BP_STORE_ACTIVITY_JUMP_IDX = StoreActivitySupply_UI.GetJumpReuseItemIdxByItemID(BP_STORE_ACTIVITY_SUPPLY_SELECT_ITEM_ID);
		end
	end

	store_item_upgrade_system.SetCurrentModele(store_item_upgrade_system.module.activity_supply)
	-- 刷新列表
	if BP_STORE_ACTIVITY_SUPPLY_PAGE ~= 1 then
		LuaClassObj.HandleUIMessageNoFetch(bp_store_activity_supply, "UpdateList");
		StoreActivitySupply_UI.needUpdateItemList = false;
	end
	-- 刷新购买按钮
	LuaClassObj.HandleUIMessageNoFetch(bp_store_activity_supply, "UpdateBuyItemGroup");
	-- 更新积分显示
	LuaClassObj.HandleUIMessageNoFetch(bp_store_activity_supply, "UpdateViewWhenShow");
	---- 刷新最低出极品的购买次数
	--LuaClassObj.HandleUIMessageNoFetch(bp_store_activity_supply, "UpdateRoundText");
	---- 更新积分显示
	--LuaClassObj.HandleUIMessageNoFetch(bp_store_activity_supply, "UpdateScore");
	---- 刷新剩余时间
	--LuaClassObj.HandleUIMessageNoFetch(bp_store_activity_supply, "UpdateEndTime");
	---- 刷新首页图
	--LuaClassObj.HandleUIMessageNoFetch(bp_store_activity_supply, "LoadItemListBgTexture");
	---- 刷新详情底图
	--LuaClassObj.HandleUIMessageNoFetch(bp_store_activity_supply, "LoadHomePageTexture");
	---- 刷新海报
	--LuaClassObj.HandleUIMessageNoFetch(bp_store_activity_supply, "LoadPosterTexture");
	---- 刷新补给箱ICON
	--LuaClassObj.HandleUIMessageNoFetch(bp_store_activity_supply, "UpdateBoxIcon");
	---- 刷新性别按钮
	--LuaClassObj.HandleUIMessageNoFetch(bp_store_activity_supply, "UpdateSexBtn");
	---- 刷新物品详情
	--LuaClassObj.HandleUIMessageNoFetch(bp_store_activity_supply, "UpdateItemDetail");
	-- 更新积分显示
	LuaClassObj.HandleUIMessageNoFetch(bp_store_activity_supply, "UpdateScore");
	-- 更新积分显示
	LuaClassObj.HandleUIMessageNoFetch(bp_store_activity_supply, "UpdateShowView");
	-- 刷新折扣活动时间
	LuaClassObj.HandleUIMessageNoFetch(bp_store_activity_supply, "UpdateDiscountActivityTime");

	if BP_STORE_ACTIVITY_SUPPLY_PAGE ~= 1 then
		BP_STORE_ACTIVITY_JUMP_IDX = -1;
		StoreActivitySupply_UI.needJump = false;
	end
end

-- 刷新方法
function StoreActivitySupply_UI.UpdateView()
	StoreSystem.GetTabData(StoreSystem.supply_tab, BP_STORE_ACTIVITY_SUPPLY_SUPPLY_ID);
end

-- 判断是否显示引导tips
function StoreActivitySupply_UI.CheckShowGuideTips()
	if DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_ACTIVITY_SHOP, 1) == true then
		BP_STORE_ACTIVITY_SHOW_GUIDE_TIPS = true;
	else
		BP_STORE_ACTIVITY_SHOW_GUIDE_TIPS = false;
	end
	-- 更新tips显示
	LuaClassObj.HandleUIMessageNoFetch(bp_store_activity_supply, "UpdateGuideTips");
end

function StoreActivitySupply_UI.OnBagItemChange(event_type, event_id)
	if event_id == EVENTID_SUBSCRIBE_GET_STATUS_DATA then
		log("StoreActivitySupply_UI.OnBagItemChange EVENTID_SUBSCRIBE_GET_STATUS_DATA");
	end
	-- 刷新数据
	StoreActivitySupply_UI.UpdateSupplyData();
	-- -- 刷新模型, 放这里因为有上下文关系
	-- StoreActivitySupply_UI.UpdateItemList();
	-- StoreActivitySupply_UI.UpdateAvatar();
	-- if BP_STORE_ACTIVITY_SUPPLY_SELECT_ITEM_ID ~= -1 then
	-- end
	-- StoreActivitySupply_UI.UpdateItemList();
	-- 刷新购买按钮
	LuaClassObj.HandleUIMessageNoFetch(bp_store_activity_supply, "UpdateBuyItemGroup");
	-- 刷新折扣活动时间
	LuaClassObj.HandleUIMessageNoFetch(bp_store_activity_supply, "UpdateDiscountActivityTime");
end

-- 刷新相关数据
function StoreActivitySupply_UI.UpdateData()
	StoreActivitySupply_UI.needUpdateItemList = true;
	StoreActivitySupply_UI.UpdateSupplyData();
	-- 刷新模型, 放这里因为有上下文关系
	StoreActivitySupply_UI.UpdateItemList();
	-- 检查是否需要选中物品
	StoreActivitySupply_UI.CheckToSelectItem();
	StoreActivitySupply_UI.UpdateAvatar();
	if StoreActivitySupply_UI.needJump and StoreActivitySupply_UI.jumpInfo then
		BP_STORE_ACTIVITY_SUPPLY_SELECT_ITEM_ID = StoreActivitySupply_UI.jumpInfo.itemId;
		BP_STORE_ACTIVITY_SUPPLY_LEVELUP_ITEMID = StoreActivitySupply_UI.jumpInfo.itemId;
		StoreActivitySupply_UI.GetItemIndexByID();
		StoreActivitySupply_UI.jumpInfo = nil;
	end
	if BP_STORE_ACTIVITY_SUPPLY_SELECT_ITEM_ID ~= -1 then
		local needPlaySound = OpenBoxtUI.isShow == false;
		SupplyMainUI.OnSelectedItem(BP_STORE_ACTIVITY_SUPPLY_SELECT_ITEM_ID, 0, 0, true, needPlaySound);
	else
		ModelDisplayer.SetShowtype(ModelDisplayer.SHOWTYPE_AVATAR);
	end
	StoreActivitySupply_UI.UpdateItemList();
end

-- 设置选中INDEX
function StoreActivitySupply_UI.GetItemIndexByID()
	for i,v in ipairs(BP_ARRAY_STORE_ACTIVITY_SUPPLY_DROP_ITEM_LIST) do
		if v.DropItemID == BP_STORE_ACTIVITY_SUPPLY_SELECT_ITEM_ID then
			BP_STORE_ACTIVITY_SUPPLY_SELECT_INDEX = i;
			break;
		end
	end
end

-- 检查是否需要选中物品
function StoreActivitySupply_UI.CheckToSelectItem()
	if StoreActivitySupply_UI.needJump == false then
		local preview_items = BP_STRUCT_STORE_ACTIVITY_SUPPLY_ITEM.preview_items;
		if preview_items ~= nil and next(preview_items) ~= nil then
			for _, itemID in ipairs(preview_items) do
				for _, dropInfo in ipairs(BP_ARRAY_STORE_ACTIVITY_SUPPLY_DROP_ITEM_LIST) do
					if dropInfo.DropItemID == itemID then
						BP_STORE_ACTIVITY_SUPPLY_SELECT_ITEM_ID = itemID;
						BP_STORE_ACTIVITY_SUPPLY_LEVELUP_ITEMID = itemID;
						StoreActivitySupply_UI.GetItemIndexByID();
						return;
					end
				end
			end
		end
		BP_STORE_ACTIVITY_SUPPLY_SELECT_ITEM_ID = -1;
		BP_STORE_ACTIVITY_SUPPLY_SELECT_INDEX = -1;
	end
end

-- 刷新页面相关数据
function StoreActivitySupply_UI.UpdateSupplyData()
	-- 页面数据
	local data = StoreSystem.supply_data[BP_STORE_ACTIVITY_SUPPLY_SUPPLY_ID];

	if data ~= nil then
		local item = SupplyMainUI.MakeSupplyInfo(data);
		-- 单抽
		SupplyMainUI.UpdateSupplyOneDiscountInfoByVip(item);
		local activityTimeStr_1 = SupplyMainUI.UpdateSupplyOneDiscountInfo(item);
		-- 10连抽
		local activityTimeStr_10 = SupplyMainUI.UpdateSupplyTenDiscountInfo(item);

		BP_STRUCT_STORE_ACTIVITY_SUPPLY_ITEM = item;
		BP_STORE_ACTIVITY_SUPPLY_DISCOUNT_TIME_PERIOD = "";
		if activityTimeStr_10 then
			BP_STORE_ACTIVITY_SUPPLY_DISCOUNT_TIME_PERIOD = activityTimeStr_10;
		end
		if activityTimeStr_1 then
			BP_STORE_ACTIVITY_SUPPLY_DISCOUNT_TIME_PERIOD = activityTimeStr_1;
		end

		EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_UPDATE_OPEN_BOX_PANEL, item);
	end
end

-- 页面道具数据
function StoreActivitySupply_UI.UpdateItemList()
	local data = StoreSystem.supply_data[BP_STORE_ACTIVITY_SUPPLY_SUPPLY_ID];
	if data ~= nil then
		StoreActivitySupply_UI.UpdateDropList(data[StoreSystem.label_shop_index_item_list]);
	end
end

-- 刷新avatar
function StoreActivitySupply_UI.UpdateAvatar()
	local supplyItem = BP_STRUCT_STORE_ACTIVITY_SUPPLY_ITEM;

	-- 切换性别
	if supplyItem.gender ~= nil and supplyItem.gender ~= 0 and BP_STORE_ACTIVITY_SUPPLY_SEX ~= supplyItem.gender then
		BP_STORE_ACTIVITY_SUPPLY_SEX = supplyItem.gender;
		SupplyMainUI.ShowSex(BP_STORE_ACTIVITY_SUPPLY_SEX);
	end

	--if StoreActivitySupply_UI.needJump == false then
		MultipleAvatar.ClearEquipments({LobbyAvatar.EQUIPMENT_SUBTYPE_HAIR});
	--end

	-- 穿上推荐衣服
	if supplyItem.preview_items ~= nil then
		for _, itemID in ipairs(supplyItem.preview_items) do
			if BP_STORE_ACTIVITY_SUPPLY_SELECT_ITEM_ID ~= itemID then
				SupplyMainUI.OnSelectedItem(itemID, 0, 0, true, false);
			end
		end
	end
end

-- 刷新武器人物切换按钮
function StoreActivitySupply_UI.UpdateDisplayType()
	BP_STORE_ACTIVITY_SHOW_DiplayType_BTN = StoreFuncUtils.IsWeapon(BP_STORE_ACTIVITY_SUPPLY_SELECT_ITEM_ID);
	if not BP_STORE_ACTIVITY_SHOW_DiplayType_BTN then
		BP_STORE_ACTIVITY_DisplayType = 1;
	end
	LuaClassObj.HandleUIMessageNoFetch(bp_store_activity_supply, "UpdateDisplayType");
end

-- 刷新表情按钮
function StoreActivitySupply_UI.UpdateEmotionBtn()
	local emotionID = SupplyMainUI.GetEmotionIDByItemID(BP_ARRAY_STORE_ACTIVITY_SUPPLY_DROP_ITEM_LIST, BP_STORE_ACTIVITY_SUPPLY_SELECT_ITEM_ID);
	BP_STORE_ACTIVITY_SHOW_EMOTION_BTN = emotionID ~= 0 and MultipleAvatar.HasEquiped(BP_STORE_ACTIVITY_SUPPLY_SELECT_ITEM_ID, 0, 0) == true;
	LuaClassObj.HandleUIMessageNoFetch(bp_store_activity_supply, "UpdateEmotionBtn");
end

-- 切换高级和1级枪
function StoreActivitySupply_UI.OnClickUpgradeLevelBtn(event_type, event_id, isMaxLevel)
	StoreActivitySupply_UI.UpdateItemList();
	LuaClassObj.HandleUIMessageNoFetch(bp_store_activity_supply, "UpdateListBySelect");
end

-- 点击物品
function EventStoreActivitySupplyOnClickItem()
	log("EventStoreActivitySupplyOnClickItem BP_STORE_ACTIVITY_SUPPLY_SELECT_ITEM_ID"..BP_STORE_ACTIVITY_SUPPLY_SELECT_ITEM_ID)
	StoreActivitySupply_UI.OnDeadBoxRestore()
	StoreActivitySupply_UI.UpdateDisplayType();
	SupplyMainUI.OnSelectedItem(BP_STORE_ACTIVITY_SUPPLY_SELECT_ITEM_ID, 0, 0, false, true);
	StoreActivitySupply_UI.UpdateItemList();
	StoreActivitySupply_UI.UpdateEmotionBtn();
	LuaClassObj.HandleUIMessageNoFetch(bp_store_activity_supply, "UpdateAfterClickItem");
	--LuaClassObj.HandleUIMessageNoFetch(bp_store_activity_supply, "UpdateItemDetail");
	--LuaClassObj.HandleUIMessageNoFetch(bp_store_activity_supply, "UpdateListBySelect");
	-- 刷新性别按钮
	--LuaClassObj.HandleUIMessageNoFetch(bp_store_activity_supply, "UpdateSexBtn");
end


-- 点击播放人物特定表情
function EventStoreActivitySupplyOnClickPlayEmotion()
	log("EventStoreActivitySupplyOnClickPlayEmotion")
	--local emotionID = SupplyMainUI.GetEmotionIDByItemID(BP_ARRAY_STORE_ACTIVITY_SUPPLY_DROP_ITEM_LIST, BP_STORE_ACTIVITY_SUPPLY_SELECT_ITEM_ID);
	local emotionID = BP_STORE_ACTIVITY_SUPPLY_EXPRESSION_ID;
	if emotionID ~= 0 and MultipleAvatar.HasEquiped(BP_STORE_ACTIVITY_SUPPLY_SELECT_ITEM_ID, 0, 0) == true then
		SupplyMainUI.PlayAvatarEmotion(emotionID);
	end
end

-- 点击切换性别
function EventStoreActivitySupplyOnClickChangeSex()
	SupplyMainUI.SwitchSex();
	LobbyUI.StopEmotionSound();
	BP_STORE_ACTIVITY_SUPPLY_SEX = MultipleAvatar.ShowingAvatarSextype;
	log("EventStoreActivitySupplyOnClickChangeSex "..tostring(BP_STORE_ACTIVITY_SUPPLY_SEX))
	-- 刷新性别按钮
	LuaClassObj.HandleUIMessageNoFetch(bp_store_activity_supply, "UpdateSexBtn");
end

-- 点击切换2D/3D展示
function EventStoreActivitySupplyOnClickShowMode()
	GemReportUtils.ReportBtnClickEvent(GemReportUtils.SubEventName_SupplyClick2D3D)
end

-- 单抽
function EventStoreActivitySupplyOnClickBuyOne()
	log("EventStoreActivitySupplyOnClickBuyOne");
	SupplyMainUI.RequestBuySupplyBox(BP_STRUCT_STORE_ACTIVITY_SUPPLY_ITEM);
end

-- 10连抽
function EventStoreActivitySupplyOnClickBuyTen()
	log("EventStoreActivitySupplyOnClickBuyTen");
	SupplyMainUI.RequestBuyTenSupplyBox(BP_STRUCT_STORE_ACTIVITY_SUPPLY_ITEM);
end

-- 展示掉落概率
function EventStoreActivitySupplyOnClickShowRate()
	local supplyItem = BP_STRUCT_STORE_ACTIVITY_SUPPLY_ITEM;
    if supplyItem ~= nil and #supplyItem.drop_rate > 0 then
        Rate_Panel_UI.Show(supplyItem.drop_rate);
    end
end

function EventStoreActivityOnClickChangeWeaponDisplayType()
	log("EventStoreActivityOnClickChangeWeaponDisplayType, before DisplayType = " .. tostring(BP_STORE_ACTIVITY_DisplayType));
	if BP_STORE_ACTIVITY_DisplayType == 0 then
		BP_STORE_ACTIVITY_DisplayType = 1;
		ModelDisplayer.SetShowtype(ModelDisplayer.SHOWTYPE_AVATAR);
	else
		BP_STORE_ACTIVITY_DisplayType = 0;
		ModelDisplayer.SetShowtype(ModelDisplayer.SHOWTYPE_WEAPON_MODEL);
	end
	log("[HHF]EventOnClickChangeStoreWeaponDisplayType,  after DisplayType = " .. tostring(BP_STORE_ACTIVITY_DisplayType));

	LuaClassObj.HandleUIMessageNoFetch(bp_store_activity_supply, "UpdateDisplayType");
end

-- 点击首页，包括tips
function EventStoreActivitySupplyOnClickHomePage()
	GemReportUtils.ReportBtnClickEvent(GemReportUtils.SubEventName_SupplyDropInfo)
	if BP_STORE_ACTIVITY_SHOW_GUIDE_TIPS then
		DataMgr.SetNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_ACTIVITY_SHOP, 1);
		StoreActivitySupply_UI.CheckShowGuideTips();
	end
end

-- 切换页
function EventStoreActivitySupplyOnSwitchPage()
	log("BP_STORE_ACTIVITY_SUPPLY_PAGE = "..tostring(BP_STORE_ACTIVITY_SUPPLY_PAGE))
	if BP_STORE_ACTIVITY_SUPPLY_PAGE ~= 1 then
		if StoreActivitySupply_UI.needJump then
			BP_STORE_ACTIVITY_JUMP_IDX = StoreActivitySupply_UI.GetJumpReuseItemIdxByItemID(BP_STORE_ACTIVITY_SUPPLY_SELECT_ITEM_ID);
		end

		if StoreActivitySupply_UI.needUpdateItemList == true or BP_STORE_ACTIVITY_JUMP_IDX ~= -1 then
			LuaClassObj.HandleUIMessageNoFetch(bp_store_activity_supply, "UpdateList");
			--LuaClassObj.HandleUIMessageNoFetch(bp_store_activity_supply, "UpdateEndTime");
			StoreActivitySupply_UI.needUpdateItemList = false;
		end

		BP_STORE_ACTIVITY_JUMP_IDX = -1;
		StoreActivitySupply_UI.needJump = false;
	end
end

-- 处理掉落物品列表
function StoreActivitySupply_UI.UpdateDropList(list)
	--log_tree("StoreActivitySupply_UI.UpdateDropList", list);
	BP_ARRAY_STORE_ACTIVITY_SUPPLY_DROP_ITEM_LIST = {};

	local dataList = {};
	for k, v in pairs(list) do
		dataList[#dataList + 1] = SupplyMainUI.MakeSupplyDropInfo(v);
	end

	BP_ARRAY_STORE_ACTIVITY_SUPPLY_REUSE_ITEM_LIST = {};
	local map = {};
	local mapKeyList = {};
	-- 分类
	for i,v in ipairs(dataList) do
		if map[v.drop_type] == nil then
			map[v.drop_type] = {};
			mapKeyList[#mapKeyList + 1] = v.drop_type;
		end
		local list = map[v.drop_type];
		list[#list + 1] = v;
	end

	-- 排序
	for k,v in pairs(map) do
		table.sort(v, 
			function(a,b)
				local aTime = a.rate_up_end_time or 0
				aTime = aTime - FuncUtil.GetServerTimeInSec();
				local bTime = b.rate_up_end_time or 0
				bTime = bTime - FuncUtil.GetServerTimeInSec();
				if aTime > 0 and bTime > 0 then
					return a.DropItemSort > b.DropItemSort;
				elseif aTime > 0 and bTime <= 0 then
					return true;
				elseif aTime <= 0 and bTime > 0 then
					return false;
				else
					return a.DropItemSort > b.DropItemSort;
				end
			end);
	end
	table.sort(mapKeyList, 
		function(a,b)
			return a < b;
		end);

	-- 
	for i,drop_type in ipairs(mapKeyList) do
		local cfg = Client.GetTableData("LocalizeRes",drop_type);
		BP_ARRAY_STORE_ACTIVITY_SUPPLY_REUSE_ITEM_LIST[#BP_ARRAY_STORE_ACTIVITY_SUPPLY_REUSE_ITEM_LIST + 1] = 
			{
				item_type = 1, 
				title_name_text = cfg and cfg.TextValue or "";--tostring(drop_type),
			}

		local reuseItem = nil;
		local cnt = 4;
		for _, info in ipairs(map[drop_type]) do
			local index = #BP_ARRAY_STORE_ACTIVITY_SUPPLY_DROP_ITEM_LIST + 1;
			BP_ARRAY_STORE_ACTIVITY_SUPPLY_DROP_ITEM_LIST[index] = info;

			if cnt > 3 then
				reuseItem = 
				{
					item_type = 2,
					BP_ARRAY_ITEM_LIST = {},
				}
				BP_ARRAY_STORE_ACTIVITY_SUPPLY_REUSE_ITEM_LIST[#BP_ARRAY_STORE_ACTIVITY_SUPPLY_REUSE_ITEM_LIST + 1] = reuseItem;
				cnt = 1;
			end
			info.DropIndex = index;
			reuseItem.BP_ARRAY_ITEM_LIST[cnt] = info;
			cnt = cnt + 1;
		end
	end
end

function StoreActivitySupply_UI.GetJumpReuseItemIdxByItemID(itemID)
	if itemID ~= -1 then
		for i,reuseItemData in ipairs(BP_ARRAY_STORE_ACTIVITY_SUPPLY_REUSE_ITEM_LIST) do
			if reuseItemData.BP_ARRAY_ITEM_LIST ~= nil then
				for _,itemData in ipairs(reuseItemData.BP_ARRAY_ITEM_LIST) do
					if itemData.DropItemID == itemID then
						return i - 1;
					end
				end
			end
		end
	end
	return -1;
end

-- 测试数据 -----------------
function StoreActivitySupply_UI.TestData()
	BP_ARRAY_STORE_ACTIVITY_SUPPLY_DROP_ITEM_LIST = {};

	local dataList = {};
	table.insert(dataList, StoreActivitySupply_UI.TestMakeData(1510527, 4951)); 
	table.insert(dataList, StoreActivitySupply_UI.TestMakeData(1510528, 4951)); 
	table.insert(dataList, StoreActivitySupply_UI.TestMakeData(1510529, 4951)); 
	table.insert(dataList, StoreActivitySupply_UI.TestMakeData(1510526, 4951)); 
	table.insert(dataList, StoreActivitySupply_UI.TestMakeData(1510525, 4952)); 
	table.insert(dataList, StoreActivitySupply_UI.TestMakeData(1510524, 4952)); 
	table.insert(dataList, StoreActivitySupply_UI.TestMakeData(1510523, 4952)); 
	table.insert(dataList, StoreActivitySupply_UI.TestMakeData(1510601, 4952)); 
	table.insert(dataList, StoreActivitySupply_UI.TestMakeData(1510602, 4952)); 
	table.insert(dataList, StoreActivitySupply_UI.TestMakeData(1510603, 4952)); 
	table.insert(dataList, StoreActivitySupply_UI.TestMakeData(1510604, 4952)); 

	BP_ARRAY_STORE_ACTIVITY_SUPPLY_REUSE_ITEM_LIST = {};
	local map = {};
	local mapKeyList = {};
	-- 分类
	for i,v in ipairs(dataList) do
		if map[v.drop_type] == nil then
			map[v.drop_type] = {};
			mapKeyList[#mapKeyList + 1] = v.drop_type;
		end
		local list = map[v.drop_type];
		list[#list + 1] = v;
	end

	-- 排序
	for k,v in pairs(map) do
		table.sort(v, 
			function(a,b)
				return a.DropItemSort > b.DropItemSort;
			end);
	end
	table.sort(mapKeyList, 
		function(a,b)
			return a < b;
		end);

	-- 
	for i,drop_type in ipairs(mapKeyList) do
		BP_ARRAY_STORE_ACTIVITY_SUPPLY_REUSE_ITEM_LIST[#BP_ARRAY_STORE_ACTIVITY_SUPPLY_REUSE_ITEM_LIST + 1] = 
			{
				item_type = 1, 
				title_name_text = Client.GetTableData("LocalizeRes",drop_type).TextValue,
			}

		local reuseItem = nil;
		local cnt = 4;
		for _, info in ipairs(map[drop_type]) do
			local index = #BP_ARRAY_STORE_ACTIVITY_SUPPLY_DROP_ITEM_LIST + 1;
			BP_ARRAY_STORE_ACTIVITY_SUPPLY_DROP_ITEM_LIST[index] = info;

			if cnt > 3 then
				reuseItem = 
				{
					item_type = 2,
					BP_ARRAY_ITEM_LIST = {},
				}
				BP_ARRAY_STORE_ACTIVITY_SUPPLY_REUSE_ITEM_LIST[#BP_ARRAY_STORE_ACTIVITY_SUPPLY_REUSE_ITEM_LIST + 1] = reuseItem;
				cnt = 1;
			end
			reuseItem.BP_ARRAY_ITEM_LIST[cnt] = info;
			cnt = cnt + 1;
		end
	end


end

function StoreActivitySupply_UI.TestMakeData(id, type)
	local item = {};
	for k,v in pairs(BP_STRUCT_STORE_ACTIVITY_SUPPLY_DROP_ITEM) do
		item[k] = v;
	end
	item.DropItemID = id;
	item.drop_type = 4951;
	return item;
end

function EventOnClickActivitySupplyDeadBox()
	log("[HHF]StoreActivitySupply_UI, deadBoxTimer = " .. tostring(StoreActivitySupply_UI.deadBoxTimer))
	if StoreActivitySupply_UI.deadBoxTimer == nil then
		StoreActivitySupply_UI.deadBoxHandler = SceneExtraModel.Create(BP_STORE_ACTIVITY_CurrentDeadboxPath);
		if StoreActivitySupply_UI.deadBoxHandler ~= nil then
			StoreActivitySupply_UI.deadBoxHandler:SetPosition(-70, -434, -14438);

			ModelDisplayer.Hide();
			StoreActivitySupply_UI.oldDisplayType = BP_StoreWeapon_DisplayType;
			StoreActivitySupply_UI.deadBoxTimer = Timer.InsertTimer(3, StoreActivitySupply_UI.OnDeadBoxRestore, false);

			BP_STORE_ACTIVITY_SHOW_DiplayType_BTN = false		--播放动画的时候隐藏那个切换DISPLAY按钮
			LuaClassObj.HandleUIMessageNoFetch(bp_store_activity_supply, "UpdateDisplayType")
		else
			log("[HHF]EventOnClickStoreWeaponDeadBox, SceneExtraModel.Create failed.");
		end
	end
end

function StoreActivitySupply_UI.OnDeadBoxRestore()
	log("[HHF]StoreActivitySupply_UI.OnDeadBoxRestore, deadBoxTimer = " .. tostring(StoreWeaponUI.deadBoxTimer));
	if StoreActivitySupply_UI.deadBoxTimer ~= nil then
		Timer.RemoveTimer(StoreActivitySupply_UI.deadBoxTimer);
		StoreActivitySupply_UI.deadBoxTimer = nil;

		if StoreActivitySupply_UI.deadBoxHandler ~= nil then
			StoreActivitySupply_UI.deadBoxHandler:Destroy();
		end
		ModelDisplayer.Show();
		StoreActivitySupply_UI.UpdateDisplayType()	--结束时候再来判断一遍是否显示那个切换DISPLAY按钮 
	end
end

function EventShowDiscountHelpTips()
	local tipsStr = FuncUtil.LocalizeResFormat("6743");
	CommonHelpTipsUI:ShowPanelStr(tipsStr, BP_STRUCT_STORE_ACTIVITY_SUPPLY_DISCOUNT_HELP_POS);
end
