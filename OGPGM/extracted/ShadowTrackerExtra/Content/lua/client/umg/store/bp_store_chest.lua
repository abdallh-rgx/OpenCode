StoreChestUI = StoreChestUI or
{
	marketId = 0,
	jumpId = -1,
}

-- 礼包信息
BP_STRUCT_STORE_CHEST_CHEST_INFO = 
{
	marketId = 0,		-- 商品ID
	itemId = 0,			-- 道具ID
	priceType = 0,		-- 价格类型
	priceNum = 0,		-- 原价
	discountNum = 0,	-- 折扣价
	finalPriceNum = 0,	-- 最终价（算上缄口的价格）
	limitBuyType = 0,		-- 限购类型
	limitBuyNum = 0,		-- 限购数量
	hasBuyNum = 0,			-- 已购买次数
	saleEndTime = 0,		-- 下架时间
	discountForShow = "",   -- 显示折扣
	is_owned = false,       -- 是否已拥有
	isSoldOut = false,      -- 是否售完
}

-- 礼包内物品信息
BP_STRUCT_STORE_CHEST_DROP_INFO =
{
	DropItemID = 0,		-- 物品ID
	DropItemNum = 0,	-- 物品数量
	DropItemSort = 1,	-- 物品排序ID
	DropRate = 1,		-- 抽取概率
	derateNum = 0,		-- 减免价格
	is_must_drop = false,		-- 是否必得
	is_limit_time = false,		-- 是否限时
	limit_end_time = 0,			--限时时长
	is_hot = false,			-- 是否热卖
	is_new = false,			-- 是否新品
	is_owned = false,		-- 是否已拥有
	showSpecialIcon = false,	--显示特殊图标
	specialIconPath = "",		--特殊图标路径
}

-- 礼包内物品列表
BP_ARRAY_STORE_CHEST_DROP_INFO = 
{
	BP_STRUCT_STORE_CHEST_DROP_INFO = _G.BP_STRUCT_STORE_CHEST_DROP_INFO;
}

-- 礼包道具列表选中物品ID
BP_STORE_CHEST_ITEM_SELECT_ITEM_ID = -1;
-- 是否有概率
BP_STORE_CHEST_HAS_RATE = false;

function bp_store_chest_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_store_chest,
		{{Path="/Game/UMG/UI_Logic/Store/Comm/Store_Chest_Info_BP.Store_Chest_Info_BP_C", Container="Default", ZOrder=0}},
      	{"Lobby"},
	  	false,
	  	false,
	    true
    );
    log("bp_store_chest_RegisterUI")
end

function StoreChestUI.RegisterEvent()
	EventSystem:registEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_CHEST_INFO, StoreChestUI.OnChestInfoUpdate);
	EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_DATA_CHANGE, StoreChestUI.OnItemDataChange);
end

function StoreChestUI.UnRegisterEvent()
	EventSystem:unregistEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_CHEST_INFO, StoreChestUI.OnChestInfoUpdate);
	EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_DATA_CHANGE, StoreChestUI.OnItemDataChange);
end

-- 刷新数据，外部调用
function StoreChestUI.ShowChestInfo(data)
	BP_STRUCT_STORE_CHEST_CHEST_INFO = nil;
	if data == nil then
		log("StoreChestUI.ShowChestInfo data = nil")
		return;
	end
	StoreChestUI.RegisterEvent();
	BP_STORE_CHEST_ITEM_SELECT_ITEM_ID = -1;

	StoreChestUI.data = data;

	BP_STORE_CHEST_HAS_RATE = StoreChestUI.data.rateType == 1 or (data.rateList ~= nil and next(data.rateList) ~= nil);
	
	log("StoreChestUI.ShowChestInfo");
	LuaClassObj.HandleDynamicCreation(bp_store_chest);
	LuaClassObj.HandleUIMessageNoFetch(bp_store_chest, "UIShow");

	StoreSystem.GetChestInfo(StoreChestUI.data.marketId);

	if UIManager.GetUI(eUIType.eStoreChestPage) == nil then
		UIManager.Show(eUIType.eStoreChestPage);
	end
	-- if UIManager.GetUI(eUIType.eShopGiftWithDay) then
	-- 	UIManager.Show(eUIType.eShopGiftWithDay)
	-- end
end

function StoreChestUI.Hide()
	LuaClassObj.HandleUIMessageNoFetch(bp_store_chest, "UIHide");
	StoreChestUI.UnRegisterEvent();
	UIManager.Hide(eUIType.eStoreChestPage);
end

-- 回包刷新数据
function StoreChestUI.OnChestInfoUpdate(event_type, event_id, data)
	log("StoreChestUI.OnChestInfoUpdate")
	--if data.marketId ~= StoreChestUI.marketId then
	--	return;
	--end

	StoreChestUI.serverData = data;

	if StoreChestUI.jumpId ~= -1 then
		BP_STORE_CHEST_ITEM_SELECT_ITEM_ID = StoreChestUI.jumpId;
		StoreChestUI.jumpId = -1;
	end
	StoreChestUI.UnRegisterEvent();
	StoreChestUI.UpdateChestDropList(data.info);
	StoreChestUI.UpdateChestInfo();
	local hasOwn = StoreChestUI.CheckAllHasOwned();
	EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_CHEST_IS_PROSSESSED, {BP_STRUCT_STORE_CHEST_CHEST_INFO.itemId, hasOwn, BP_STRUCT_STORE_CHEST_CHEST_INFO.finalPriceNum});

	LuaClassObj.HandleUIMessageNoFetch(bp_store_chest, "UpdateList");
	LuaClassObj.HandleUIMessageNoFetch(bp_store_chest, "SetInfo");
end

function StoreChestUI.OnItemDataChange(eventType, eventID, vars)
	log("[HHF]StoreChestUI.OnItemDataChange");
	StoreChestUI.UpdateChestDropList(StoreChestUI.serverData.info);
	StoreChestUI.UpdateChestInfo();
	local hasOwn = StoreChestUI.CheckAllHasOwned();
	EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_CHEST_IS_PROSSESSED, {BP_STRUCT_STORE_CHEST_CHEST_INFO.itemId, hasOwn, BP_STRUCT_STORE_CHEST_CHEST_INFO.finalPriceNum});

	LuaClassObj.HandleUIMessageNoFetch(bp_store_chest, "UpdateList");
	LuaClassObj.HandleUIMessageNoFetch(bp_store_chest, "SetInfo");
end

function StoreChestUI.UpdateChestDropList(list)
	BP_ARRAY_STORE_CHEST_DROP_INFO = {};
	for i,v in ipairs(list) do
		BP_ARRAY_STORE_CHEST_DROP_INFO[#BP_ARRAY_STORE_CHEST_DROP_INFO + 1] = StoreChestUI.MakeChestDropInfo(v);
	end
	table.sort(BP_ARRAY_STORE_CHEST_DROP_INFO, function(left,right)
		if left.DropItemSort ~= right.DropItemSort then
			return left.DropItemSort > right.DropItemSort;
		else
			return false;
		end
	end)
end

function StoreChestUI.CheckAllHasOwned()
	local isAllOwned = true;
	for i,v in ipairs(BP_ARRAY_STORE_CHEST_DROP_INFO) do
		if v.is_owned == false then
			isAllOwned = false;
			break;
		end
	end
	return isAllOwned;
end

-- function StoreChestUI.JumpTo(itemID)
-- 	StoreChestUI.jumpId = itemID;
-- 	StoreChestUI.ShowChestInfo(StoreChestUI.data);
-- end

-- 创建礼包内单个物品数据
function StoreChestUI.MakeChestDropInfo(data)
	local dropData = {};
	PetSystem = require("client.slua.logic.pet.logic_pet");
	dropData.DropItemID = data[StoreSystem.label_drop_index_item_id] or data.DropItemID;
	dropData.DropItemNum = data[StoreSystem.label_drop_index_item_num] or 0;
	dropData.DropRate = data[StoreSystem.label_drop_index_chance];
	dropData.DropItemSort = data[StoreSystem.label_drop_index_item_sort] or 0;
	dropData.is_limit_time = data[StoreSystem.label_drop_index_item_time] > 0
	dropData.limit_end_time = data[StoreSystem.label_drop_index_item_time] or 0;
	local cfg = Client.GetTableData("Item", dropData.DropItemID);
	if dropData.is_limit_time == false then
		if cfg and cfg.ValidTimes and cfg.ValidTimes ~= 0 then
			dropData.is_limit_time = true;
			dropData.limit_end_time = cfg.ValidTimes;
		end
	end
	if cfg then
		dropData.specialIconPath = cfg.SpecialIcon;
	end
	dropData.derateNum = data[StoreSystem.label_drop_index_return_money];
	local _, showHot, _ = StoreFuncUtils.GetItemLeftTopTagsQueue(false,false, false);
	dropData.is_hot = showHot;
	dropData.is_new = false;

	local showNew, showSpecialIcon = StoreFuncUtils.GetItemRightTopTagsQueue(
			false,
			cfg.SpecialIcon ~= "");
	dropData.is_new = showNew;
	dropData.showSpecialIcon = showSpecialIcon;

	dropData.is_must_drop = dropData.DropRate >= 1 --必得
	--已拥有：必得的永久物品且配置了减免的且玩家拥有的物品，会出现已拥有标记。（且该物品减免相应价格，且该物品不会发货。） 策划案原话
	dropData.is_owned = dropData.is_must_drop == true --必得 
					and not dropData.is_limit_time	--永久
					and dropData.derateNum > 0	--减免
					and (DataMgr.GetHallDepotItemDataByResID(dropData.DropItemID) ~= nil or PetSystem.HasPet(dropData.DropItemID) == true);	--已拥有
	--log_tree("SupplyMainUI.MakeSupplyDropInfo", dropData)
	--log("SupplyMainUI.MakeSupplyDropInfo 2"..tostring(DataMgr.GetHallDepotItemDataByResID(dropData.DropItemID)))

	return dropData;
end

function StoreChestUI.UpdateChestInfo()
	local oldTotalDerateNum = 0;
	if StoreSystem.chest_info[StoreChestUI.data.marketId] ~= nil then
		oldTotalDerateNum = StoreSystem.chest_info[StoreChestUI.data.marketId].totalDerateNum or 0;
	end

	BP_STRUCT_STORE_CHEST_CHEST_INFO = 
	{
		marketId = StoreChestUI.data.marketId,		-- 商品ID
		itemId = StoreChestUI.data.itemId,			-- 道具ID
		priceType = StoreChestUI.data.priceType,		-- 价格类型
		priceNum = StoreChestUI.data.originalPrice,		-- 原价
		discountNum = StoreChestUI.data.priceNum + oldTotalDerateNum,	-- 折扣价
		finalPriceNum = math.max(0, StoreChestUI.data.priceNum + oldTotalDerateNum - StoreChestUI.CalcTotalDerateNum()),	-- 最终价（算上缄口的价格）
		discountForShow = StoreChestUI.data.discountForShow,

		limitBuyType = StoreChestUI.data.limitBuyType or 0,
		limitBuyNum = StoreChestUI.data.limitBuyNum,
		hasBuyNum = StoreChestUI.data.hasBuyNum,
		saleEndTime = StoreChestUI.data.saleEndTime,
		is_owned = StoreChestUI.CheckAllHasOwned(),
		isSoldOut = StoreChestUI.data.isSoldOut,
	};

	if BP_STRUCT_STORE_CHEST_CHEST_INFO.is_owned == true then
		BP_STRUCT_STORE_CHEST_CHEST_INFO.finalPriceNum = 0;
	end

	log_tree("BP_STRUCT_STORE_CHEST_CHEST_INFO", BP_STRUCT_STORE_CHEST_CHEST_INFO)
	if StoreSystem.chest_info[StoreChestUI.data.marketId] ~= nil then
		StoreSystem.chest_info[StoreChestUI.data.marketId].totalDerateNum = StoreChestUI.CalcTotalDerateNum();
	end
	log("finalPriceNum = "..tostring(BP_STRUCT_STORE_CHEST_CHEST_INFO.finalPriceNum))
end

-- 计算减免掉的价格总数
function StoreChestUI.CalcTotalDerateNum()
	local totalDerateNum = 0;
	for i,dropData in ipairs(BP_ARRAY_STORE_CHEST_DROP_INFO) do
		if dropData.is_owned then-- 配了减免的
			if StoreFuncUtils.IsPetItemID(dropData.DropItemID) then
				totalDerateNum = totalDerateNum + dropData.derateNum;
			else
				local itemList = DataMgr.GetHallDepotItemListByResID(dropData.DropItemID);
				for j, item in ipairs(itemList) do
					if item.expireTS == nil or item.expireTS == 0 then
						totalDerateNum = totalDerateNum + dropData.derateNum;
					end
				end
			end
		end
	end
	return totalDerateNum;
end

function StoreChestUI.BuyItem(shopInfo)
	if BP_STRUCT_STORE_CHEST_CHEST_INFO == nil then
		return;
	end
	--log_tree("StoreChestUI.BuyItem", BP_STRUCT_STORE_CHEST_CHEST_INFO)
	shopInfo.money1_price = BP_STRUCT_STORE_CHEST_CHEST_INFO.finalPriceNum;
	StoreFuncUtils.PurchaseItem(shopInfo)
end

-- 点击道具ICON
function EventStoreChestUIOnClickItem()
	StoreChestUI.UpdateChestDropList(StoreChestUI.serverData.info);
	LuaClassObj.HandleUIMessageNoFetch(bp_store_chest, "UpdateList");
end

-- 点击查看概率
function EventStoreChestUIOnClickRate()
	--log_tree("EventStoreChestUIOnClickRate", StoreChestUI.data);
	if StoreChestUI.data.rateType == 1 then-- 掉落品质概率
		local list = {};
		for i,v in ipairs(BP_ARRAY_STORE_CHEST_DROP_INFO) do
			local data = {};
			data.itemId = v.DropItemID;
			data.rate = tostring(math.ceil(v.DropRate * 10000) / 100).."%";
			data.limitEndTime = v.limit_end_time;
			data.count = v.DropItemNum or 0
			list[#list + 1] = data;
		end
		Rate_Panel_UI.ShowItemRate(list, 6702);
	else-- 掉落物品概率
		Rate_Panel_UI.Show(StoreChestUI.data.rateList, 6701);
	end
end