-- 极品补给UI模块
StoreValuableSupply_UI = StoreValuableSupply_UI or 
{
	isInit = false,
	isShow = false,
	needJump = false,
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
BP_STRUCT_STORE_VALUABLE_SUPPLY_REUSE_ITEM =
{
	item_type = 0,-- 1:底图+物品 2:物品（1-3个）
	bg_texture_path = "",
	rate_up_end_time = 0, -- 概率结束时间
	BP_ARRAY_ITEM_LIST = { BP_STRUCT_STORE_ACTIVITY_SUPPLY_DROP_ITEM = _G.BP_STRUCT_STORE_ACTIVITY_SUPPLY_DROP_ITEM },
}
-- BP-LUA结构定义 END--
--==========================
-- BP-LUA字段定义 BEGIN--
-- 复用式结构列表
BP_ARRAY_STORE_VALUABLE_SUPPLY_REUSE_ITEM_LIST = 
{
	BP_STRUCT_STORE_VALUABLE_SUPPLY_REUSE_ITEM = _G.BP_STRUCT_STORE_VALUABLE_SUPPLY_REUSE_ITEM,
}

-- 实际物品数据列表
BP_ARRAY_STORE_VALUABLE_SUPPLY_DROP_ITEM_LIST = 
{
	BP_STRUCT_STORE_ACTIVITY_SUPPLY_DROP_ITEM = _G.BP_STRUCT_STORE_ACTIVITY_SUPPLY_DROP_ITEM,
}

BP_STORE_VALUABLE_SUPPLY_EXPRESSION_ID = 0;
-- 当前补给ID
BP_STORE_VALUABLE_SUPPLY_SUPPLY_ID = 0;
-- 选中物品索引
BP_STORE_VALUABLE_SUPPLY_SELECT_INDEX = -1;
-- 选中物品ID
BP_STORE_VALUABLE_SUPPLY_SELECT_ITEM_ID = -1;
-- 当前性别
BP_STORE_VALUABLE_SUPPLY_SEX = 1;
-- 用于跳转到指定reuse item的索引
BP_STORE_VALUABLE_JUMP_IDX = -1;
-- 是否显示表情按钮
BP_STORE_VALUABLE_SHOW_EMOTION_BTN = false;
-- 持枪状态记录
BP_STORE_VALUABLE_DisplayType = 1;
-- 是否显示持枪按钮
BP_STORE_VALUABLE_SHOW_DiplayType_BTN = false;
--升级物品展示用
BP_STORE_VALUABLE_SUPPLY_LEVELUP_ITEMID = -1;
--死亡盒子展示用
BP_STORE_VALUABLE_CurrentDeadboxPath = ""
-- 打折活动时间
BP_STORE_ACTIVITY_SUPPLY_DISCOUNT_TIME_PERIOD = "";
-- 打折活动帮助按钮位置
BP_STRUCT_STORE_ACTIVITY_SUPPLY_DISCOUNT_HELP_POS = { x = 0, y = 0};
-- BP-LUA字段定义 END--

function bp_store_valuable_supply_RegisterUI()
    log("bp_store_valuable_supply_RegisterUI");

	LuaClassObj.SubUIWidgetList(bp_store_valuable_supply,
		{{Path="/Game/UMG/UI_Logic/Store/Supply/Supply_Valuable_BP.Supply_Valuable_BP_C", Container="Default", ZOrder=0}},
      	{"Lobby"},
	  	false,
	  	false,
	    true
    );
end

-- 初始化接口（框架调用）
function StoreValuableSupply_UI.Init()
	if StoreValuableSupply_UI.isInit then
		return;
	end
	BP_STORE_VALUABLE_SUPPLY_SELECT_ITEM_ID = -1;
	BP_STORE_VALUABLE_SUPPLY_LEVELUP_ITEMID = -1
	BP_STORE_VALUABLE_SUPPLY_SELECT_INDEX = -1;
	StoreValuableSupply_UI.isInit = true;
end

-- 释放接口（框架调用）
function StoreValuableSupply_UI.Release()
	if not StoreValuableSupply_UI.isInit then
		return;
	end
	StoreValuableSupply_UI.isInit = false;
end

-- 打开接口（框架调用）
function StoreValuableSupply_UI.Show(supplyID)
	StoreValuableSupply_UI.Init();

	StoreValuableSupply_UI.isShow = true;
	BP_STORE_VALUABLE_SUPPLY_SUPPLY_ID = supplyID;
	BP_STORE_VALUABLE_SHOW_DiplayType_BTN = false;
	BP_STORE_VALUABLE_DisplayType = 1;
	BP_STORE_VALUABLE_SUPPLY_SEX = MultipleAvatar.ShowingAvatarSextype;

	StoreValuableSupply_UI.RegistEvent();

	LuaClassObj.HandleDynamicCreation(bp_store_valuable_supply);
	LuaClassObj.HandleUIMessageNoFetch(bp_store_valuable_supply, "Init");
	LuaClassObj.HandleUIMessageNoFetch(bp_store_valuable_supply, "ShowUI");
	if UIManager.GetUI(eUIType.eSupplyValuableUI) == nil then
		UIManager.Show(eUIType.eSupplyValuableUI);
		UIManager.Show(eUIType.eSupplyMainUI);
		if UIManager.GetUI(eUIType.eCorpsWelfareRedEnvelopes) ~= nil then
			UIManager.Show(eUIType.eCorpsWelfareRedEnvelopes)
		end
	end
	StoreValuableSupply_UI.UpdateView();
end

function StoreValuableSupply_UI.UIOnlyShow()
	StoreValuableSupply_UI.isShow = true;
	LobbyCameraManager.SwitchCamera(LobbyCameraManager.store_supply)
	LuaClassObj.HandleUIMessageNoFetch(bp_store_valuable_supply, "OnlyShowUI");
end

function StoreValuableSupply_UI.UIOnlyHide()
	StoreValuableSupply_UI.isShow = false;
	StoreValuableSupply_UI.OnDeadBoxRestore()
	LuaClassObj.HandleUIMessageNoFetch(bp_store_valuable_supply, "OnlyHideUI");
end

-- 关闭接口（框架调用）
function StoreValuableSupply_UI.Hide()
	if UIManager.GetUI(eUIType.eSupplyValuableUI) == nil then
		return
	end
	StoreValuableSupply_UI.isShow = false;
	StoreValuableSupply_UI.OnDeadBoxRestore()
	StoreValuableSupply_UI.UnRegistEvent();
	
	LuaClassObj.HandleUIMessageNoFetch(bp_store_valuable_supply, "HideUI");
	UIManager.Hide(eUIType.eSupplyValuableUI)
end

-- 注册事件（界面打开时）
function StoreValuableSupply_UI.RegistEvent()
	EventSystem:registEvent(EVENTTYPE_STORE_DATA, EVENTID_SUPPLY_DATA, StoreValuableSupply_UI.OnSupplyDataUpdate);
	EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_DATA_CHANGE, StoreValuableSupply_UI.OnBagItemChange);
	EventSystem:registEvent(EVENTTYPE_STORE_DATA, EVENTID_SHOP_PRICE_LIST_CHANGE, StoreValuableSupply_UI.OnBagItemChange);
	EventSystem:registEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_ONCLICK_LEVELUPPREVIEW, StoreValuableSupply_UI.OnClickUpgradeLevelBtn);
	EventSystem:registEvent(EVENTTYPE_ACTIVITY, EVENTID_SUPPLY_DISCOUNT_UPDATE, StoreValuableSupply_UI.OnBagItemChange);
	EventSystem:registEvent(EVENTTYPE_ACTIVITY, EVNETID_DATAMGR_ACTIVITY_CHANGE, StoreValuableSupply_UI.OnBagItemChange);
	EventSystem:registEvent(EVENTTYPE_SUBSCRIBE, EVENTID_SUBSCRIBE_GET_STATUS_DATA, StoreValuableSupply_UI.OnBagItemChange);
end

-- 反注册事件（界面关闭时）
function StoreValuableSupply_UI.UnRegistEvent()
	EventSystem:unregistEvent(EVENTTYPE_STORE_DATA, EVENTID_SUPPLY_DATA, StoreValuableSupply_UI.OnSupplyDataUpdate);
	EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_DATA_CHANGE, StoreValuableSupply_UI.OnBagItemChange);
	EventSystem:unregistEvent(EVENTTYPE_STORE_DATA, EVENTID_SHOP_PRICE_LIST_CHANGE, StoreValuableSupply_UI.OnBagItemChange);
	EventSystem:unregistEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_ONCLICK_LEVELUPPREVIEW, StoreValuableSupply_UI.OnClickUpgradeLevelBtn);
	EventSystem:unregistEvent(EVENTTYPE_ACTIVITY, EVENTID_SUPPLY_DISCOUNT_UPDATE, StoreValuableSupply_UI.OnBagItemChange);
	EventSystem:unregistEvent(EVENTTYPE_ACTIVITY, EVNETID_DATAMGR_ACTIVITY_CHANGE, StoreValuableSupply_UI.OnBagItemChange);
	EventSystem:unregistEvent(EVENTTYPE_SUBSCRIBE, EVENTID_SUBSCRIBE_GET_STATUS_DATA, StoreValuableSupply_UI.OnBagItemChange);
end

-- 跳转接口（框架调用）
function StoreValuableSupply_UI.JumpTo(supplyID, jumpInfo)
	StoreValuableSupply_UI.needJump = true;
	StoreValuableSupply_UI.jumpInfo = jumpInfo;
 	StoreValuableSupply_UI.Show(supplyID);
end

-- 收到补给详情数据
function StoreValuableSupply_UI.OnSupplyDataUpdate(event_type, event_id, data)
	if data.tab_type ~= StoreSystem.supply_tab or data.tab_id ~= BP_STORE_VALUABLE_SUPPLY_SUPPLY_ID then
		return;
	end
	if StoreValuableSupply_UI.isShow == false then
		return;
	end
	-- 刷新数据
	StoreValuableSupply_UI.UpdateData();
	-- 刷新表情按钮
	StoreValuableSupply_UI.UpdateEmotionBtn();
	-- 刷新武器人物切换按钮
	StoreValuableSupply_UI.UpdateDisplayType();
	-- 设置跳转idx（有可能为-1）
	if StoreValuableSupply_UI.needJump then
		BP_STORE_VALUABLE_JUMP_IDX = StoreValuableSupply_UI.GetJumpReuseItemIdxByItemID(BP_STORE_VALUABLE_SUPPLY_SELECT_ITEM_ID);
	end

	store_item_upgrade_system.SetCurrentModele(store_item_upgrade_system.module.valuable_supply)

	-- 刷新列表
	LuaClassObj.HandleUIMessageNoFetch(bp_store_valuable_supply, "UpdateList");
	-- 统一刷新逻辑
	LuaClassObj.HandleUIMessageNoFetch(bp_store_valuable_supply, "UpdateViewWhenShow");
	-- 刷新购买按钮
	LuaClassObj.HandleUIMessageNoFetch(bp_store_valuable_supply, "UpdateBuyItemGroup");
	-- 刷新首页图
	--LuaClassObj.HandleUIMessageNoFetch(bp_store_valuable_supply, "LoadItemListBgTexture");
	-- 刷新剩余时间
	--LuaClassObj.HandleUIMessageNoFetch(bp_store_valuable_supply, "UpdateEndTime");
	-- 刷新补给箱ICON
	--LuaClassObj.HandleUIMessageNoFetch(bp_store_valuable_supply, "UpdateBoxIcon");
	-- 刷新最低出极品的购买次数
	--LuaClassObj.HandleUIMessageNoFetch(bp_store_valuable_supply, "UpdateRoundText");
	-- 刷新物品详情
	-- LuaClassObj.HandleUIMessageNoFetch(bp_store_valuable_supply, "UpdateItemDetail");
	-- 更新积分显示
	-- LuaClassObj.HandleUIMessageNoFetch(bp_store_valuable_supply, "UpdateScore");
	-- 刷新性别按钮
	-- LuaClassObj.HandleUIMessageNoFetch(bp_store_valuable_supply, "UpdateSexBtn");
	-- 刷新折扣活动时间
	LuaClassObj.HandleUIMessageNoFetch(bp_store_valuable_supply, "UpdateDiscountActivityTime");
	BP_STORE_VALUABLE_JUMP_IDX = -1;

	StoreValuableSupply_UI.needJump = false;
end

-- 刷新方法
function StoreValuableSupply_UI.UpdateView()
	StoreSystem.GetTabData(StoreSystem.supply_tab, BP_STORE_VALUABLE_SUPPLY_SUPPLY_ID);
end


function StoreValuableSupply_UI.OnBagItemChange(event_type, event_id)
	if event_id == EVENTID_SUBSCRIBE_GET_STATUS_DATA then
		log("StoreActivitySupply_UI.OnBagItemChange EVENTID_SUBSCRIBE_GET_STATUS_DATA");
	end
	-- 刷新数据
	StoreValuableSupply_UI.UpdateSupplyData();
	log_tree("StoreValuableSupply_UI.OnBagItemChange BP_STRUCT_STORE_ACTIVITY_SUPPLY_ITEM", BP_STRUCT_STORE_ACTIVITY_SUPPLY_ITEM)
	-- -- 刷新模型，放这里是因为有上下文关系
	-- StoreValuableSupply_UI.UpdateItemList();
	-- StoreValuableSupply_UI.UpdateAvatar();
	-- if BP_STORE_VALUABLE_SUPPLY_SELECT_ITEM_ID ~= -1 then
	-- end
	-- StoreValuableSupply_UI.UpdateItemList();
	-- 刷新购买按钮
	LuaClassObj.HandleUIMessageNoFetch(bp_store_valuable_supply, "UpdateBuyItemGroup");
	-- 刷新折扣活动时间
	LuaClassObj.HandleUIMessageNoFetch(bp_store_valuable_supply, "UpdateDiscountActivityTime");
end

-- 刷新相关数据
function StoreValuableSupply_UI.UpdateData()
	StoreValuableSupply_UI.UpdateSupplyData();
	-- 刷新模型，放这里是因为有上下文关系
	StoreValuableSupply_UI.UpdateItemList();
	-- 检查是否需要选中物品
	StoreValuableSupply_UI.CheckToSelectItem();
	StoreValuableSupply_UI.UpdateAvatar();
	if StoreValuableSupply_UI.needJump and StoreValuableSupply_UI.jumpInfo then
		BP_STORE_VALUABLE_SUPPLY_SELECT_ITEM_ID = StoreValuableSupply_UI.jumpInfo.itemId;
		BP_STORE_VALUABLE_SUPPLY_LEVELUP_ITEMID = StoreValuableSupply_UI.jumpInfo.itemId;
		StoreValuableSupply_UI.GetItemIndexByID();
		StoreValuableSupply_UI.jumpInfo = nil;
	end

	if BP_STORE_VALUABLE_SUPPLY_SELECT_ITEM_ID ~= -1 then
		local needPlaySound = OpenBoxtUI.isShow == false;
		SupplyMainUI.OnSelectedItem(BP_STORE_VALUABLE_SUPPLY_SELECT_ITEM_ID, 0, 0, true, needPlaySound);
	else
		ModelDisplayer.SetShowtype(ModelDisplayer.SHOWTYPE_AVATAR);
	end
	StoreValuableSupply_UI.UpdateItemList();
end

-- 设置选中INDEX
function StoreValuableSupply_UI.GetItemIndexByID()
	for i,v in ipairs(BP_ARRAY_STORE_VALUABLE_SUPPLY_DROP_ITEM_LIST) do
		if v.DropItemID == BP_STORE_VALUABLE_SUPPLY_SELECT_ITEM_ID then
			BP_STORE_VALUABLE_SUPPLY_SELECT_INDEX = i;
			break;
		end
	end
end

-- 检查是否需要选中物品
function StoreValuableSupply_UI.CheckToSelectItem()
	if StoreValuableSupply_UI.needJump == false then
		local preview_items = BP_STRUCT_STORE_ACTIVITY_SUPPLY_ITEM.preview_items;
		if preview_items ~= nil and next(preview_items) ~= nil then
			for _, itemID in ipairs(preview_items) do
				for __, dropInfo in ipairs(BP_ARRAY_STORE_VALUABLE_SUPPLY_DROP_ITEM_LIST) do
					if dropInfo.DropItemID == itemID then
						BP_STORE_VALUABLE_SUPPLY_SELECT_ITEM_ID = itemID;
						BP_STORE_VALUABLE_SUPPLY_LEVELUP_ITEMID = itemID
						StoreValuableSupply_UI.GetItemIndexByID();
						return;
					end
				end
			end
		end
		BP_STORE_VALUABLE_SUPPLY_SELECT_ITEM_ID = -1;
		BP_STORE_VALUABLE_SUPPLY_SELECT_INDEX = -1;
	end
end

-- 刷新页面相关数据
function StoreValuableSupply_UI.UpdateSupplyData()
	-- 页面数据
	local data = StoreSystem.supply_data[BP_STORE_VALUABLE_SUPPLY_SUPPLY_ID];
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
function StoreValuableSupply_UI.UpdateItemList()
	local data = StoreSystem.supply_data[BP_STORE_VALUABLE_SUPPLY_SUPPLY_ID];
	if data ~= nil then
		StoreValuableSupply_UI.UpdateDropList(data[StoreSystem.label_shop_index_item_list]);
	end
end

-- 刷新avatar
function StoreValuableSupply_UI.UpdateAvatar()
	local supplyItem = BP_STRUCT_STORE_ACTIVITY_SUPPLY_ITEM;

	-- 切换性别
	if supplyItem.gender ~= nil and supplyItem.gender ~= 0 and BP_STORE_VALUABLE_SUPPLY_SEX ~= supplyItem.gender then
		BP_STORE_VALUABLE_SUPPLY_SEX = supplyItem.gender;
		SupplyMainUI.ShowSex(BP_STORE_VALUABLE_SUPPLY_SEX);
	end

	--if StoreValuableSupply_UI.needJump == false then
		MultipleAvatar.ClearEquipments({LobbyAvatar.EQUIPMENT_SUBTYPE_HAIR});
	--end

	-- 穿上推荐衣服
	if supplyItem.preview_items ~= nil then
		for _, itemID in ipairs(supplyItem.preview_items) do
			if BP_STORE_VALUABLE_SUPPLY_SELECT_ITEM_ID ~= itemID then
				SupplyMainUI.OnSelectedItem(itemID, 0, 0, true, false);
			end
		end
	end
end

-- 刷新武器人物切换按钮
function StoreValuableSupply_UI.UpdateDisplayType()
	BP_STORE_VALUABLE_SHOW_DiplayType_BTN = StoreFuncUtils.IsWeapon(BP_STORE_VALUABLE_SUPPLY_SELECT_ITEM_ID);
	if not BP_STORE_VALUABLE_SHOW_DiplayType_BTN then
		BP_STORE_VALUABLE_DisplayType = 1
	end
	LuaClassObj.HandleUIMessageNoFetch(bp_store_valuable_supply, "UpdateDisplayType");
end


-- 刷新表情按钮
function StoreValuableSupply_UI.UpdateEmotionBtn()
	local emotionID = SupplyMainUI.GetEmotionIDByItemID(BP_ARRAY_STORE_VALUABLE_SUPPLY_DROP_ITEM_LIST, BP_STORE_VALUABLE_SUPPLY_SELECT_ITEM_ID);
	BP_STORE_VALUABLE_SHOW_EMOTION_BTN = emotionID ~= 0 and MultipleAvatar.HasEquiped(BP_STORE_VALUABLE_SUPPLY_SELECT_ITEM_ID, 0, 0) == true;
	LuaClassObj.HandleUIMessageNoFetch(bp_store_valuable_supply, "UpdateEmotionBtn");
end

-- 切换高级和1级枪
function StoreValuableSupply_UI.OnClickUpgradeLevelBtn(event_type, event_id, isMaxLevel)
	StoreValuableSupply_UI.UpdateItemList();
	LuaClassObj.HandleUIMessageNoFetch(bp_store_valuable_supply, "UpdateListBySelect");
end

-- 点击
function EventStoreValuableSupplyOnClickItem()
	log(":BP_STORE_VALUABLE_SUPPLY_SELECT_ITEM_ID"..BP_STORE_VALUABLE_SUPPLY_SELECT_ITEM_ID)
	StoreValuableSupply_UI.OnDeadBoxRestore()
	StoreValuableSupply_UI.UpdateDisplayType();
	SupplyMainUI.OnSelectedItem(BP_STORE_VALUABLE_SUPPLY_SELECT_ITEM_ID, 0, 0, false, true);
	StoreValuableSupply_UI.UpdateItemList();
	StoreValuableSupply_UI.UpdateEmotionBtn();
	LuaClassObj.HandleUIMessageNoFetch(bp_store_valuable_supply, "UpdateAfterClickItem");
	-- LuaClassObj.HandleUIMessageNoFetch(bp_store_valuable_supply, "UpdateItemDetail");
	-- LuaClassObj.HandleUIMessageNoFetch(bp_store_valuable_supply, "UpdateListBySelect");
	-- -- 刷新性别按钮
	-- LuaClassObj.HandleUIMessageNoFetch(bp_store_valuable_supply, "UpdateSexBtn");
end

-- 点击播放人物特定表情动作
function EventStoreValuableSupplyOnClickPlayEmotion()
	--local emotionID = SupplyMainUI.GetEmotionIDByItemID(BP_ARRAY_STORE_VALUABLE_SUPPLY_DROP_ITEM_LIST, BP_STORE_VALUABLE_SUPPLY_SELECT_ITEM_ID);
	local emotionID = BP_STORE_VALUABLE_SUPPLY_EXPRESSION_ID;
	if emotionID ~= 0 then
		SupplyMainUI.PlayAvatarEmotion(emotionID);
	end
end

-- 点击切换性别
function EventStoreValuableSupplyOnClickChangeSex()
	SupplyMainUI.SwitchSex();
	LobbyUI.StopEmotionSound();
	BP_STORE_VALUABLE_SUPPLY_SEX = MultipleAvatar.ShowingAvatarSextype;

	-- 刷新性别按钮
	LuaClassObj.HandleUIMessageNoFetch(bp_store_valuable_supply, "UpdateSexBtn");
end

-- 点击切换2D/3D展示
function EventStoreValuableSupplyOnClickShowMode()

end

-- 单抽
function EventStoreValuableSupplyOnClickBuyOne()
	log("EventStoreValuableSupplyOnClickBuyOne");
	SupplyMainUI.RequestBuySupplyBox(BP_STRUCT_STORE_ACTIVITY_SUPPLY_ITEM);
end

-- 10连抽
function EventStoreValuableSupplyOnClickBuyTen()
	log("EventStoreValuableSupplyOnClickBuyTen");
	SupplyMainUI.RequestBuyTenSupplyBox(BP_STRUCT_STORE_ACTIVITY_SUPPLY_ITEM);
end

-- 展示掉落概率
function EventStoreValuableSupplyOnClickShowRate()
	local supplyItem = BP_STRUCT_STORE_ACTIVITY_SUPPLY_ITEM;
    if supplyItem ~= nil and #supplyItem.drop_rate > 0 then
        Rate_Panel_UI.Show(supplyItem.drop_rate);
    end
end

function EventStoreValuableOnClickChangeWeaponDisplayType()
	log("EventStoreValuableOnClickChangeWeaponDisplayType, before DisplayType = " .. tostring(BP_STORE_VALUABLE_DisplayType));
	if BP_STORE_VALUABLE_DisplayType == 0 then
		BP_STORE_VALUABLE_DisplayType = 1;
		ModelDisplayer.SetShowtype(ModelDisplayer.SHOWTYPE_AVATAR);
	else
		BP_STORE_VALUABLE_DisplayType = 0;
		ModelDisplayer.SetShowtype(ModelDisplayer.SHOWTYPE_WEAPON_MODEL);
	end
	log("EventStoreValuableOnClickChangeWeaponDisplayType,  after DisplayType = " .. tostring(BP_STORE_VALUABLE_DisplayType));

	LuaClassObj.HandleUIMessageNoFetch(bp_store_valuable_supply, "UpdateDisplayType");
	
end

-- 处理掉落物品列表
function StoreValuableSupply_UI.UpdateDropList(list)
	BP_ARRAY_STORE_VALUABLE_SUPPLY_DROP_ITEM_LIST = {};

	local dataList = {};
	for k, v in pairs(list) do
		dataList[#dataList + 1] = SupplyMainUI.MakeSupplyDropInfo(v);
	end

	-- 排序
	table.sort(dataList, 
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
		end)

	-- 处理真正展示数据
	BP_ARRAY_STORE_VALUABLE_SUPPLY_REUSE_ITEM_LIST = {};
	for i, v in ipairs(dataList) do
		local index = math.ceil(i / 3) + 1;
		if i == 1 then
			BP_ARRAY_STORE_VALUABLE_SUPPLY_REUSE_ITEM_LIST[1] = {
				item_type = 1;
				rate_up_end_time = BP_STRUCT_STORE_ACTIVITY_SUPPLY_ITEM.rate_up_end_time;
				bg_texture_path = BP_STRUCT_STORE_ACTIVITY_SUPPLY_ITEM.item_list_tex_path;
			}
		end
		local data = BP_ARRAY_STORE_VALUABLE_SUPPLY_REUSE_ITEM_LIST[index];
		if data == nil then
			data = {};
			data.item_type = 2;
			data.rate_up_end_time = 0;
			data.bg_texture_path = "";
			data.BP_ARRAY_ITEM_LIST = {};
			BP_ARRAY_STORE_VALUABLE_SUPPLY_REUSE_ITEM_LIST[index] = data;
		end
		data.BP_ARRAY_ITEM_LIST[#data.BP_ARRAY_ITEM_LIST + 1] = v;
		v.DropIndex = i;
		BP_ARRAY_STORE_VALUABLE_SUPPLY_DROP_ITEM_LIST[i] = v
	end
end


function StoreValuableSupply_UI.GetJumpReuseItemIdxByItemID(itemID)
	if itemID ~= -1 then
		for i,reuseItemData in ipairs(BP_ARRAY_STORE_VALUABLE_SUPPLY_REUSE_ITEM_LIST) do
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
function StoreValuableSupply_UI.TestData()
	BP_ARRAY_STORE_VALUABLE_SUPPLY_DROP_ITEM_LIST = {};

	local dataList = {};
	table.insert(dataList, StoreValuableSupply_UI.TestMakeData(1510527)); 
	table.insert(dataList, StoreValuableSupply_UI.TestMakeData(1510528)); 
	table.insert(dataList, StoreValuableSupply_UI.TestMakeData(1510529)); 
	table.insert(dataList, StoreValuableSupply_UI.TestMakeData(1510526)); 
	table.insert(dataList, StoreValuableSupply_UI.TestMakeData(1510525)); 
	table.insert(dataList, StoreValuableSupply_UI.TestMakeData(1510524)); 
	table.insert(dataList, StoreValuableSupply_UI.TestMakeData(1510523)); 
	table.insert(dataList, StoreValuableSupply_UI.TestMakeData(1510601)); 
	table.insert(dataList, StoreValuableSupply_UI.TestMakeData(1510602)); 
	table.insert(dataList, StoreValuableSupply_UI.TestMakeData(1510603)); 
	table.insert(dataList, StoreValuableSupply_UI.TestMakeData(1510604)); 

	-- 排序
	table.sort(dataList, 
		function(a,b)
			return a.DropItemSort < b.DropItemSort;
		end)

	-- 处理真正展示数据
	BP_ARRAY_STORE_VALUABLE_SUPPLY_REUSE_ITEM_LIST = {};
	for i, v in ipairs(dataList) do
		local index = math.ceil(i / 3);
		if i <= 9 then
			index = math.ceil(i / 9);
		end
		log("BP_ARRAY_STORE_VALUABLE_SUPPLY_REUSE_ITEM_LIST index = "..tostring(index))
		local data = BP_ARRAY_STORE_VALUABLE_SUPPLY_REUSE_ITEM_LIST[index];
		if data == nil then
			data = {};
			if index == 1 then
				data.item_type = 1;
				data.bg_texture_path = "/Game/UMG/Texture/Lobby_NoAtlas/Store_Int/Supply_bg_02.Supply_bg_02_C";
			else
				data.item_type = 2;
			end
			data.BP_ARRAY_ITEM_LIST = {};
			BP_ARRAY_STORE_VALUABLE_SUPPLY_REUSE_ITEM_LIST[index] = data;
		end

		data.BP_ARRAY_ITEM_LIST[#data.BP_ARRAY_ITEM_LIST + 1] = v;
		BP_ARRAY_STORE_VALUABLE_SUPPLY_DROP_ITEM_LIST[i] = v;
	end
end

function StoreValuableSupply_UI.TestMakeData(id)
	local item = {};
	for k,v in pairs(BP_STRUCT_STORE_ACTIVITY_SUPPLY_DROP_ITEM) do
		item[k] = v;
	end
	item.DropItemID = id;
	return item;
end

function EventOnClickActivityvaluableDeadBox()
	log("[HHF]StoreValuableSupply_UI, deadBoxTimer = " .. tostring(StoreValuableSupply_UI.deadBoxTimer))
	if StoreValuableSupply_UI.deadBoxTimer == nil then
		StoreValuableSupply_UI.deadBoxHandler = SceneExtraModel.Create(BP_STORE_VALUABLE_CurrentDeadboxPath);
		if StoreValuableSupply_UI.deadBoxHandler ~= nil then
			StoreValuableSupply_UI.deadBoxHandler:SetPosition(-70, -434, -14438);

			ModelDisplayer.Hide();
			StoreValuableSupply_UI.oldDisplayType = BP_StoreWeapon_DisplayType;
			StoreValuableSupply_UI.deadBoxTimer = Timer.InsertTimer(3, StoreValuableSupply_UI.OnDeadBoxRestore, false);

			BP_STORE_VALUABLE_SHOW_DiplayType_BTN = false		--播放动画的时候隐藏那个切换DISPLAY按钮
			LuaClassObj.HandleUIMessageNoFetch(bp_store_valuable_supply, "UpdateDisplayType")
		else
			log("[HHF]EventOnClickStoreWeaponDeadBox, SceneExtraModel.Create failed.");
		end
	end
end

function StoreValuableSupply_UI.OnDeadBoxRestore()
	log("[HHF]StoreValuableSupply_UI.OnDeadBoxRestore, deadBoxTimer = " .. tostring(StoreValuableSupply_UI.deadBoxTimer));
	if StoreValuableSupply_UI.deadBoxTimer ~= nil then
		Timer.RemoveTimer(StoreValuableSupply_UI.deadBoxTimer);
		StoreValuableSupply_UI.deadBoxTimer = nil;

		if StoreValuableSupply_UI.deadBoxHandler ~= nil then
			StoreValuableSupply_UI.deadBoxHandler:Destroy();
		end
		ModelDisplayer.Show();

		StoreValuableSupply_UI.UpdateDisplayType()	--结束时候再来判断一遍是否显示那个切换DISPLAY按钮
	end
end

function EventShowDiscountHelpTips()
	local tipsStr = FuncUtil.LocalizeResFormat("6743");
	CommonHelpTipsUI:ShowPanelStr(tipsStr, BP_STRUCT_STORE_ACTIVITY_SUPPLY_DISCOUNT_HELP_POS);
end