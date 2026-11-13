-- 尖兵补给UI模块（通用宝箱模版？）
StoreNormalSupply_UI = StoreNormalSupply_UI or 
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
-- BP-LUA结构定义 END--
--==========================
-- BP-LUA字段定义 BEGIN--
-- 实际物品数据列表
BP_ARRAY_STORE_NORMAL_SUPPLY_DROP_ITEM_LIST = 
{
	BP_STRUCT_STORE_ACTIVITY_SUPPLY_DROP_ITEM = _G.BP_STRUCT_STORE_ACTIVITY_SUPPLY_DROP_ITEM,
}

BP_STORE_NORMAL_SUPPLY_EXPRESSION_ID = 0;
-- 当前补给ID
BP_STORE_NORMAL_SUPPLY_SUPPLY_ID = 0;
-- 选中物品索引
BP_STORE_NORMAL_SUPPLY_SELECT_INDEX = -1;
-- 选中物品ID
BP_STORE_NORMAL_SUPPLY_SELECT_ITEM_ID = -1;
-- 当前性别
BP_STORE_NORMAL_SUPPLY_SEX = 0;
-- 用于跳转到指定item的索引
BP_STORE_NORMAL_JUMP_IDX = -1;
-- 是否显示表情按钮
BP_STORE_NORMAL_SHOW_EMOTION_BTN = false;
-- 持枪状态记录
BP_STORE_NORMAL_DisplayType = 1;
-- 是否显示持枪按钮
BP_STORE_NORMAL_SHOW_DiplayType_BTN = false;
--升级物品展示用
BP_STORE_NORMAL_SUPPLY_LEVELUP_ITEMID = -1
--死亡盒子展示用
BP_STORE_NORMAL_CurrentDeadboxPath = ""
-- 打折活动时间
BP_STORE_ACTIVITY_SUPPLY_DISCOUNT_TIME_PERIOD = "";
-- 打折活动帮助按钮位置
BP_STRUCT_STORE_ACTIVITY_SUPPLY_DISCOUNT_HELP_POS = { x = 0, y = 0};
-- BP-LUA字段定义 END--

function bp_store_normal_supply_RegisterUI()
    log("bp_store_normal_supply_RegisterUI");

	LuaClassObj.SubUIWidgetList(bp_store_normal_supply,
		{{Path="/Game/UMG/UI_Logic/Store/Supply/Supply_Normal_BP.Supply_Normal_BP_C", Container="Default", ZOrder=0}},
      	{"Lobby"},
	  	false,
	  	false,
	    true
    );
end

-- 初始化接口（框架调用）
function StoreNormalSupply_UI.Init()
	log("StoreNormalSupply_UI.Init")
	if StoreNormalSupply_UI.isInit == true then
		return;
	end
	BP_STORE_NORMAL_SUPPLY_SELECT_ITEM_ID = -1;
	BP_STORE_NORMAL_SUPPLY_LEVELUP_ITEMID = -1
	BP_STORE_NORMAL_SUPPLY_SELECT_INDEX = -1;
	StoreNormalSupply_UI.isInit = true;
end

-- 释放接口（框架调用）
function StoreNormalSupply_UI.Release()
	if not StoreNormalSupply_UI.isInit then
		return;
	end
	StoreNormalSupply_UI.isInit = false;
end

-- 打开接口（框架调用）
function StoreNormalSupply_UI.Show(supplyID)
	log("StoreNormalSupply_UI.Show");
	StoreNormalSupply_UI.Init();

	StoreNormalSupply_UI.isShow = true;
	BP_STORE_NORMAL_SUPPLY_SUPPLY_ID = supplyID;
	BP_STORE_NORMAL_SHOW_DiplayType_BTN = false;
	BP_STORE_NORMAL_DisplayType = 1;

	BP_STORE_NORMAL_SUPPLY_SEX = MultipleAvatar.ShowingAvatarSextype;

	StoreNormalSupply_UI.RegistEvent();

	LuaClassObj.HandleDynamicCreation(bp_store_normal_supply);
	LuaClassObj.HandleUIMessageNoFetch(bp_store_normal_supply, "Init");
	LuaClassObj.HandleUIMessageNoFetch(bp_store_normal_supply, "ShowUI");
	if UIManager.GetUI(eUIType.eSupplyNormalUI) == nil then
		UIManager.Show(eUIType.eSupplyNormalUI);
		UIManager.Show(eUIType.eSupplyMainUI);
		if UIManager.GetUI(eUIType.eCorpsWelfareRedEnvelopes) ~= nil then
			UIManager.Show(eUIType.eCorpsWelfareRedEnvelopes)
		end
	end
	StoreNormalSupply_UI.UpdateView();
end

function StoreNormalSupply_UI.UIOnlyShow()
	StoreNormalSupply_UI.isShow = true;
	LobbyCameraManager.SwitchCamera(LobbyCameraManager.store_supply)
	LuaClassObj.HandleUIMessageNoFetch(bp_store_normal_supply, "OnlyShowUI");
end

function StoreNormalSupply_UI.UIOnlyHide()
	StoreNormalSupply_UI.isShow = false;
	StoreNormalSupply_UI.OnDeadBoxRestore();
	LuaClassObj.HandleUIMessageNoFetch(bp_store_normal_supply, "OnlyHideUI");
end

-- 关闭接口（框架调用）
function StoreNormalSupply_UI.Hide()
	if UIManager.GetUI(eUIType.eSupplyNormalUI) == nil then
		return
	end
	log("StoreNormalSupply_UI.Hide")
	StoreNormalSupply_UI.isShow = false;
	StoreNormalSupply_UI.OnDeadBoxRestore()
	StoreNormalSupply_UI.UnRegistEvent();

	LuaClassObj.HandleUIMessageNoFetch(bp_store_normal_supply, "HideUI");
	UIManager.Hide(eUIType.eSupplyNormalUI)
end

-- 注册事件（界面打开时）
function StoreNormalSupply_UI.RegistEvent()
	EventSystem:registEvent(EVENTTYPE_STORE_DATA, EVENTID_SUPPLY_DATA, StoreNormalSupply_UI.OnSupplyDataUpdate);
	EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_DATA_CHANGE, StoreNormalSupply_UI.OnBagItemChange);
	EventSystem:registEvent(EVENTTYPE_STORE_DATA, EVENTID_SHOP_PRICE_LIST_CHANGE, StoreNormalSupply_UI.OnBagItemChange);
	EventSystem:registEvent(EVENTTYPE_ACTIVITY, EVENTID_SUPPLY_DISCOUNT_UPDATE, StoreNormalSupply_UI.OnBagItemChange);
	EventSystem:registEvent(EVENTTYPE_ACTIVITY, EVNETID_DATAMGR_ACTIVITY_CHANGE, StoreNormalSupply_UI.OnBagItemChange);
    EventSystem:registEvent(EVENTTYPE_SUBSCRIBE, EVENTID_SUBSCRIBE_GET_STATUS_DATA, StoreNormalSupply_UI.OnBagItemChange);
end

-- 反注册事件（界面关闭时）
function StoreNormalSupply_UI.UnRegistEvent()
	EventSystem:unregistEvent(EVENTTYPE_STORE_DATA, EVENTID_SUPPLY_DATA, StoreNormalSupply_UI.OnSupplyDataUpdate);
	EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_DATA_CHANGE, StoreNormalSupply_UI.OnBagItemChange);
	EventSystem:unregistEvent(EVENTTYPE_STORE_DATA, EVENTID_SHOP_PRICE_LIST_CHANGE, StoreNormalSupply_UI.OnBagItemChange);
	EventSystem:unregistEvent(EVENTTYPE_ACTIVITY, EVENTID_SUPPLY_DISCOUNT_UPDATE, StoreNormalSupply_UI.OnBagItemChange);
	EventSystem:unregistEvent(EVENTTYPE_ACTIVITY, EVNETID_DATAMGR_ACTIVITY_CHANGE, StoreNormalSupply_UI.OnBagItemChange);
    EventSystem:unregistEvent(EVENTTYPE_SUBSCRIBE, EVENTID_SUBSCRIBE_GET_STATUS_DATA, StoreNormalSupply_UI.OnBagItemChange);
end

-- 跳转接口（框架调用）
function StoreNormalSupply_UI.JumpTo(supplyID, jumpInfo)
	StoreNormalSupply_UI.needJump = true;
	StoreNormalSupply_UI.jumpInfo = jumpInfo;
 	StoreNormalSupply_UI.Show(supplyID);
end

-- 收到补给详情数据
function StoreNormalSupply_UI.OnSupplyDataUpdate(event_type, event_id, data)
	if data.tab_type ~= StoreSystem.supply_tab or data.tab_id ~= BP_STORE_NORMAL_SUPPLY_SUPPLY_ID then
		return;
	end
	if StoreNormalSupply_UI.isShow == false then
		return;
	end
	-- 刷新数据
	StoreNormalSupply_UI.UpdateData();
	-- 刷新表情按钮
	StoreNormalSupply_UI.UpdateEmotionBtn();
	-- 刷新武器人物切换按钮
	StoreNormalSupply_UI.UpdateDisplayType();
	-- 设置跳转idx（有可能为-1）
	if StoreNormalSupply_UI.needJump then
		BP_STORE_NORMAL_JUMP_IDX = StoreNormalSupply_UI.GetJumpItemIdxByItemID(BP_STORE_NORMAL_SUPPLY_SELECT_ITEM_ID);
	end

	store_item_upgrade_system.SetCurrentModele(store_item_upgrade_system.module.normal_supply)

	-- 刷新列表
	LuaClassObj.HandleUIMessageNoFetch(bp_store_normal_supply, "UpdateList");
	-- 刷新购买按钮
	LuaClassObj.HandleUIMessageNoFetch(bp_store_normal_supply, "UpdateBuyItemGroup");
	-- 刷新首页图
	LuaClassObj.HandleUIMessageNoFetch(bp_store_normal_supply, "LoadItemListBgTexture");
	-- 刷新详情底图
	LuaClassObj.HandleUIMessageNoFetch(bp_store_normal_supply, "LoadHomePageTexture");
	-- 刷新剩余时间
	LuaClassObj.HandleUIMessageNoFetch(bp_store_normal_supply, "UpdateEndTime");
	-- 刷新补给箱ICON
	LuaClassObj.HandleUIMessageNoFetch(bp_store_normal_supply, "UpdateBoxIcon");
	-- 刷新最低出极品的购买次数
	LuaClassObj.HandleUIMessageNoFetch(bp_store_normal_supply, "UpdateRoundText");
	-- 刷新性别按钮
	LuaClassObj.HandleUIMessageNoFetch(bp_store_normal_supply, "UpdateSexBtn");
	-- 刷新物品详情
	LuaClassObj.HandleUIMessageNoFetch(bp_store_normal_supply, "UpdateItemDetail");
	-- 更新积分显示
	LuaClassObj.HandleUIMessageNoFetch(bp_store_normal_supply, "UpdateScore");
	-- 刷新折扣活动时间
	LuaClassObj.HandleUIMessageNoFetch(bp_store_normal_supply, "UpdateDiscountActivityTime");
	BP_STORE_NORMAL_JUMP_IDX = -1;
	StoreNormalSupply_UI.needJump = false;
end

-- 刷新方法
function StoreNormalSupply_UI.UpdateView()
	StoreSystem.GetTabData(StoreSystem.supply_tab, BP_STORE_NORMAL_SUPPLY_SUPPLY_ID);
end

function StoreNormalSupply_UI.OnBagItemChange(event_type, event_id)
    if event_id == EVENTID_SUBSCRIBE_GET_STATUS_DATA then
        log("StoreActivitySupply_UI.OnBagItemChange EVENTID_SUBSCRIBE_GET_STATUS_DATA");
    end
	-- 刷新数据
	StoreNormalSupply_UI.UpdateSupplyData();
	-- -- 刷新模型，放这里是因为有上下文关系
	-- StoreNormalSupply_UI.UpdateItemList();
	-- StoreNormalSupply_UI.UpdateAvatar();
	-- if BP_STORE_NORMAL_SUPPLY_SELECT_ITEM_ID ~= -1 then
	-- end
	-- StoreNormalSupply_UI.UpdateItemList();
	-- 刷新购买按钮
	LuaClassObj.HandleUIMessageNoFetch(bp_store_normal_supply, "UpdateBuyItemGroup");
	-- 刷新折扣活动时间
	LuaClassObj.HandleUIMessageNoFetch(bp_store_normal_supply, "UpdateDiscountActivityTime");
end

-- 刷新相关数据
function StoreNormalSupply_UI.UpdateData()
	StoreNormalSupply_UI.UpdateSupplyData();
	-- 刷新模型，放这里是因为有上下文关系
	--StoreNormalSupply_UI.UpdateAvatar();
	StoreNormalSupply_UI.UpdateItemList();
	-- 检查是否需要选中物品
	StoreNormalSupply_UI.CheckToSelectItem();
	StoreNormalSupply_UI.UpdateAvatar();

	if StoreNormalSupply_UI.needJump and StoreNormalSupply_UI.jumpInfo then
		BP_STORE_NORMAL_SUPPLY_SELECT_ITEM_ID = StoreNormalSupply_UI.jumpInfo.itemId;
		BP_STORE_NORMAL_SUPPLY_LEVELUP_ITEMID = StoreNormalSupply_UI.jumpInfo.itemId;
		StoreNormalSupply_UI.GetItemIndexByID();
		StoreActivitySupply_UI.jumpInfo = nil;
	end
	if BP_STORE_NORMAL_SUPPLY_SELECT_ITEM_ID ~= -1 then
		local needPlaySound = OpenBoxtUI.isShow == false;
		SupplyMainUI.OnSelectedItem(BP_STORE_NORMAL_SUPPLY_SELECT_ITEM_ID, 0, 0, true, needPlaySound);
	else
		ModelDisplayer.SetShowtype(ModelDisplayer.SHOWTYPE_AVATAR);
	end
	StoreNormalSupply_UI.UpdateItemList();
end

-- 设置选中INDEX
function StoreNormalSupply_UI.GetItemIndexByID()
	for i,v in ipairs(BP_ARRAY_STORE_NORMAL_SUPPLY_DROP_ITEM_LIST) do
		if v.DropItemID == BP_STORE_NORMAL_SUPPLY_SELECT_ITEM_ID then
			BP_STORE_NORMAL_SUPPLY_SELECT_INDEX = i;
			break;
		end
	end
end

-- 检查是否需要选中物品
function StoreNormalSupply_UI.CheckToSelectItem()
	if StoreNormalSupply_UI.needJump == false then
		local preview_items = BP_STRUCT_STORE_ACTIVITY_SUPPLY_ITEM.preview_items;
		if preview_items ~= nil and next(preview_items) ~= nil then
			for _, itemID in ipairs(preview_items) do
				for __, dropInfo in ipairs(BP_ARRAY_STORE_NORMAL_SUPPLY_DROP_ITEM_LIST) do
					if dropInfo.DropItemID == itemID then
						BP_STORE_NORMAL_SUPPLY_SELECT_ITEM_ID = itemID;
						BP_STORE_NORMAL_SUPPLY_LEVELUP_ITEMID = itemID
						StoreNormalSupply_UI.GetItemIndexByID();
						return;
					end
				end
			end
		end
		BP_STORE_NORMAL_SUPPLY_SELECT_ITEM_ID = -1;
		BP_STORE_NORMAL_SUPPLY_SELECT_INDEX = -1;
	end
end

-- 刷新页面相关数据
function StoreNormalSupply_UI.UpdateSupplyData()
	-- 页面数据
	local data = StoreSystem.supply_data[BP_STORE_NORMAL_SUPPLY_SUPPLY_ID];
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
function StoreNormalSupply_UI.UpdateItemList()
	local data = StoreSystem.supply_data[BP_STORE_NORMAL_SUPPLY_SUPPLY_ID];
	--log_tree("StoreNormalSupply_UI.UpdateItemList", data);
	if data ~= nil then
		StoreNormalSupply_UI.UpdateDropList(data[StoreSystem.label_shop_index_item_list]);
	end
end

-- 刷新avatar
function StoreNormalSupply_UI.UpdateAvatar()
	local supplyItem = BP_STRUCT_STORE_ACTIVITY_SUPPLY_ITEM;

	-- 切换性别
	if supplyItem.gender ~= nil and supplyItem.gender ~= 0 and BP_STORE_NORMAL_SUPPLY_SEX ~= supplyItem.gender then
		BP_STORE_NORMAL_SUPPLY_SEX = supplyItem.gender;
		SupplyMainUI.ShowSex(BP_STORE_NORMAL_SUPPLY_SEX);
	end

	--if StoreNormalSupply_UI.needJump == false then
		MultipleAvatar.ClearEquipments({LobbyAvatar.EQUIPMENT_SUBTYPE_HAIR});
	--end

	-- 穿上推荐衣服
	if supplyItem.preview_items ~= nil then
		for _, itemID in ipairs(supplyItem.preview_items) do
			log("BP_STORE_NORMAL_SUPPLY_SELECT_ITEM_ID = "..BP_STORE_NORMAL_SUPPLY_SELECT_ITEM_ID)
			if itemID ~= BP_STORE_NORMAL_SUPPLY_SELECT_ITEM_ID then
				SupplyMainUI.OnSelectedItem(itemID, 0, 0, true, false);
			end
		end
	end

	--log_tree("supplyItem.preview_items", supplyItem.preview_items);
end

-- 刷新武器人物切换按钮
function StoreNormalSupply_UI.UpdateDisplayType()
	BP_STORE_NORMAL_SHOW_DiplayType_BTN = StoreFuncUtils.IsWeapon(BP_STORE_NORMAL_SUPPLY_SELECT_ITEM_ID);
	if not BP_STORE_NORMAL_SHOW_DiplayType_BTN then
		BP_STORE_NORMAL_DisplayType = 1;
	end
	LuaClassObj.HandleUIMessageNoFetch(bp_store_normal_supply, "UpdateDisplayType");
end

-- 刷新表情按钮
function StoreNormalSupply_UI.UpdateEmotionBtn()
	local emotionID = SupplyMainUI.GetEmotionIDByItemID(BP_ARRAY_STORE_NORMAL_SUPPLY_DROP_ITEM_LIST, BP_STORE_NORMAL_SUPPLY_SELECT_ITEM_ID);
	BP_STORE_NORMAL_SHOW_EMOTION_BTN = emotionID ~= 0 and MultipleAvatar.HasEquiped(BP_STORE_NORMAL_SUPPLY_SELECT_ITEM_ID, 0, 0) == true;
	LuaClassObj.HandleUIMessageNoFetch(bp_store_normal_supply, "UpdateEmotionBtn");
end

-- 点击物品
function EventStoreNormalSupplyOnClickItem()
	log("EventStoreNormalSupplyOnClickItem "..BP_STORE_NORMAL_SUPPLY_SELECT_INDEX)
    StoreNormalSupply_UI.OnDeadBoxRestore();
	StoreNormalSupply_UI.UpdateDisplayType();
	SupplyMainUI.OnSelectedItem(BP_STORE_NORMAL_SUPPLY_SELECT_ITEM_ID, 0, 0, false, true);
	StoreNormalSupply_UI.UpdateItemList();
	StoreNormalSupply_UI.UpdateEmotionBtn();
	LuaClassObj.HandleUIMessageNoFetch(bp_store_normal_supply, "UpdateItemDetail");
	LuaClassObj.HandleUIMessageNoFetch(bp_store_normal_supply, "UpdateListBySelect");
	-- 刷新性别按钮
	LuaClassObj.HandleUIMessageNoFetch(bp_store_normal_supply, "UpdateSexBtn");
end


-- 点击播放人物特定表情动作
function EventStoreNormalSupplyOnClickPlayEmotion()
	--local emotionID = SupplyMainUI.GetEmotionIDByItemID(BP_ARRAY_STORE_NORMAL_SUPPLY_DROP_ITEM_LIST2, BP_STORE_NORMAL_SUPPLY_SELECT_ITEM_ID);
	local emotionID = BP_STORE_NORMAL_SUPPLY_EXPRESSION_ID;
	if emotionID ~= 0 then
		SupplyMainUI.PlayAvatarEmotion(emotionID);
	end
end

-- 点击切换性别
function EventStoreNormalSupplyOnClickChangeSex()
	SupplyMainUI.SwitchSex();
	LobbyUI.StopEmotionSound();
	BP_STORE_NORMAL_SUPPLY_SEX = MultipleAvatar.ShowingAvatarSextype;
	log("EventStoreNormalSupplyOnClickChangeSex "..tostring(BP_STORE_NORMAL_SUPPLY_SEX))
	-- 刷新性别按钮
	LuaClassObj.HandleUIMessageNoFetch(bp_store_normal_supply, "UpdateSexBtn");
end

-- 点击切换2D/3D展示
function EventStoreNormalSupplyOnClickShowMode()

end

-- 单抽
function EventStoreNormalSupplyOnClickBuyOne()
	log("EventStoreNormalSupplyOnClickBuyOne");
	SupplyMainUI.RequestBuySupplyBox(BP_STRUCT_STORE_ACTIVITY_SUPPLY_ITEM);
end

-- 10连抽
function EventStoreNormalSupplyOnClickBuyTen()
	log("EventStoreNormalSupplyOnClickBuyTen");
	SupplyMainUI.RequestBuyTenSupplyBox(BP_STRUCT_STORE_ACTIVITY_SUPPLY_ITEM);
end

-- 展示掉落概率
function EventStoreNormalSupplyOnClickShowRate()
	local supplyItem = BP_STRUCT_STORE_ACTIVITY_SUPPLY_ITEM;
    if supplyItem ~= nil and #supplyItem.drop_rate > 0 then
        Rate_Panel_UI.Show(supplyItem.drop_rate);
    end
end

function EventStoreNormalOnClickChangeWeaponDisplayType()
	log("EventStoreNormalOnClickChangeWeaponDisplayType, before DisplayType = " .. tostring(BP_STORE_NORMAL_DisplayType));
	if BP_STORE_NORMAL_DisplayType == 0 then
		BP_STORE_NORMAL_DisplayType = 1;
		ModelDisplayer.SetShowtype(ModelDisplayer.SHOWTYPE_AVATAR);
	else
		BP_STORE_NORMAL_DisplayType = 0;
		ModelDisplayer.SetShowtype(ModelDisplayer.SHOWTYPE_WEAPON_MODEL);
	end
	log("EventStoreNormalOnClickChangeWeaponDisplayType,  after DisplayType = " .. tostring(BP_STORE_NORMAL_DisplayType));
	LuaClassObj.HandleUIMessageNoFetch(bp_store_normal_supply, "UpdateDisplayType");
end

-- 处理掉落物品列表
function StoreNormalSupply_UI.UpdateDropList(list)
	BP_ARRAY_STORE_NORMAL_SUPPLY_DROP_ITEM_LIST = {};

	for i, v in ipairs(list) do
		BP_ARRAY_STORE_NORMAL_SUPPLY_DROP_ITEM_LIST[#BP_ARRAY_STORE_NORMAL_SUPPLY_DROP_ITEM_LIST + 1] = SupplyMainUI.MakeSupplyDropInfo(v)
	end
	
	table.sort(BP_ARRAY_STORE_NORMAL_SUPPLY_DROP_ITEM_LIST, 
		function(a, b)
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

	for i, v in ipairs(BP_ARRAY_STORE_NORMAL_SUPPLY_DROP_ITEM_LIST) do
		v.DropIndex = i;
	end 
end


function StoreNormalSupply_UI.GetJumpItemIdxByItemID(itemID)
	if itemID ~= -1 then
		for i,itemData in ipairs(BP_ARRAY_STORE_NORMAL_SUPPLY_DROP_ITEM_LIST) do
			if itemData.DropItemID == itemID then
				return i - 1;
			end
		end
	end
	return -1;
end

-- 测试数据 -----------------
function StoreNormalSupply_UI.TestData()
	BP_ARRAY_STORE_NORMAL_SUPPLY_DROP_ITEM_LIST = {};

	local dataList = {};
	table.insert(BP_ARRAY_STORE_NORMAL_SUPPLY_DROP_ITEM_LIST, StoreNormalSupply_UI.TestMakeData(1510527)); 
	table.insert(BP_ARRAY_STORE_NORMAL_SUPPLY_DROP_ITEM_LIST, StoreNormalSupply_UI.TestMakeData(1510528)); 
	table.insert(BP_ARRAY_STORE_NORMAL_SUPPLY_DROP_ITEM_LIST, StoreNormalSupply_UI.TestMakeData(1510529)); 
	table.insert(BP_ARRAY_STORE_NORMAL_SUPPLY_DROP_ITEM_LIST, StoreNormalSupply_UI.TestMakeData(1510526)); 
	table.insert(BP_ARRAY_STORE_NORMAL_SUPPLY_DROP_ITEM_LIST, StoreNormalSupply_UI.TestMakeData(1510525)); 
	table.insert(BP_ARRAY_STORE_NORMAL_SUPPLY_DROP_ITEM_LIST, StoreNormalSupply_UI.TestMakeData(1510524)); 
	table.insert(BP_ARRAY_STORE_NORMAL_SUPPLY_DROP_ITEM_LIST, StoreNormalSupply_UI.TestMakeData(1510523)); 
	table.insert(BP_ARRAY_STORE_NORMAL_SUPPLY_DROP_ITEM_LIST, StoreNormalSupply_UI.TestMakeData(1510601)); 
	table.insert(BP_ARRAY_STORE_NORMAL_SUPPLY_DROP_ITEM_LIST, StoreNormalSupply_UI.TestMakeData(1510602)); 
	table.insert(BP_ARRAY_STORE_NORMAL_SUPPLY_DROP_ITEM_LIST, StoreNormalSupply_UI.TestMakeData(1510603)); 
	table.insert(BP_ARRAY_STORE_NORMAL_SUPPLY_DROP_ITEM_LIST, StoreNormalSupply_UI.TestMakeData(1510604)); 
end

function StoreNormalSupply_UI.TestMakeData(id)
	local item = {};
	for k,v in pairs(BP_STRUCT_STORE_ACTIVITY_SUPPLY_ITEM) do
		item[k] = v;
	end
	item.DropItemID = id;
	return item;
end

function EventOnClickNormalDeadBox()
	log("[edward][bp_store_normal_supply] StoreNormalSupply_UI, deadBoxTimer = " .. tostring(StoreNormalSupply_UI.deadBoxTimer));
	if StoreNormalSupply_UI.deadBoxTimer == nil then
		StoreNormalSupply_UI.deadBoxHandler = SceneExtraModel.Create(BP_STORE_NORMAL_CurrentDeadboxPath);
		if StoreNormalSupply_UI.deadBoxHandler ~= nil then
			StoreNormalSupply_UI.deadBoxHandler:SetPosition(-70, -434, -14438);

			ModelDisplayer.Hide();
			StoreNormalSupply_UI.oldDisplayType = BP_StoreWeapon_DisplayType;
			StoreNormalSupply_UI.deadBoxTimer = Timer.InsertTimer(3, StoreNormalSupply_UI.OnDeadBoxRestore, false);

			BP_STORE_NORMAL_SHOW_DiplayType_BTN = false		--播放动画的时候隐藏那个切换DISPLAY按钮
			LuaClassObj.HandleUIMessageNoFetch(bp_store_normal_supply, "UpdateDisplayType")
		else
			log("[HHF]EventOnClickStoreWeaponDeadBox, SceneExtraModel.Create failed.");
		end
	end
end

function StoreNormalSupply_UI.OnDeadBoxRestore()
	log("[HHF]StoreNormalSupply_UI.OnDeadBoxRestore, deadBoxTimer = " .. tostring(StoreNormalSupply_UI.deadBoxTimer));
	if StoreNormalSupply_UI.deadBoxTimer ~= nil then
		Timer.RemoveTimer(StoreNormalSupply_UI.deadBoxTimer);
		StoreNormalSupply_UI.deadBoxTimer = nil;

		if StoreNormalSupply_UI.deadBoxHandler ~= nil then
			StoreNormalSupply_UI.deadBoxHandler:Destroy();
		end
		ModelDisplayer.Show();

		StoreNormalSupply_UI.UpdateDisplayType()	--结束时候再来判断一遍是否显示那个切换DISPLAY按钮
	end
end
function EventShowDiscountHelpTips()
	local tipsStr = FuncUtil.LocalizeResFormat("6743");
	CommonHelpTipsUI:ShowPanelStr(tipsStr, BP_STRUCT_STORE_ACTIVITY_SUPPLY_DISCOUNT_HELP_POS);
end