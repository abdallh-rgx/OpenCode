StoreClothesUI = StoreClothesUI or {
	bShowing = false,
	tab_id = 0,
	subTab_id = 0,
	jump_info = nil,

	rawData = {},
	rawItemInfo = {},

	allDataList = {},
	tabDataList = {},

	tabIDMap = {},
}

BP_STRUCT_StoreClothes_ItemPrice = {
	currency = 0,
	duration = 0,
	original = 0,
	discount = 0,
}

BP_ARRAY_StoreClothes_ItemPrice = {
	BP_STRUCT_StoreClothes_ItemPrice = _G.BP_STRUCT_StoreClothes_ItemPrice,
}

BP_STRUCT_StoreClothes_LowestPrice = {
	currency = 0,
	price = 0,
	original = 0,
}

BP_ARRAY_StoreClothes_LowestPrice =
{
	BP_STRUCT_StoreClothes_LowestPrice = _G.BP_STRUCT_StoreClothes_LowestPrice,
}

BP_STRUCT_StoreClothes_ItemInfo = {
	item_shopID = 0,
	item_id = 0,
	item_name = "",
	item_desc = "",
	item_position = "",
	item_icon = "",
	item_quality = 0,
	item_num = 0,
	item_sort = 0,
	item_hot = false,
	item_new = false,
	item_vip = false,
	item_equiped = false,
	item_selected = false,
	item_have = false,
	item_jump = "",
	item_festivalImage = "",

	item_collected = false,
	item_collected_num = 0,
	item_gift = 0,          -- 是否可赠送，0不可赠送，1可赠送
	item_endTime = 0,       -- 限时结束时间，不限时用0
	item_leftTime = 0,      -- 剩余时间
	item_discount = "",     -- 显示折扣
	item_expression = 0,    -- 红装表情ID
	item_startTime = 0,     -- 上架时间，排序用
	item_showLeft = true,   -- 显示剩余时间
	item_showLeftIcon = true,   -- 显示剩余时间Icon
	item_showSpecialIcon = true, -- 显示特殊图标
	priceNumMax = 0,			--价格数量上限
	BP_ARRAY_StoreClothes_ItemPrice = _G.BP_ARRAY_StoreClothes_ItemPrice,
	BP_ARRAY_StoreClothes_LowestPrice = _G.BP_ARRAY_StoreClothes_LowestPrice,
}

BP_ARRAY_StoreClothes_ShowItemList = {
	BP_STRUCT_StoreClothes_ItemInfo = _G.BP_STRUCT_StoreClothes_ItemInfo,
}

BP_ARRAY_StoreClothes_FilterList = {
	filter_name = "",
}

BP_StoreClothes_CurrentFilterID = 1;
BP_StoreClothes_CurrentSex = 1;
BP_StoreClothes_CurrentClickItemID = 0;
BP_StoreClothes_CurrentClickShopID = 0;
BP_StoreClothes_CurrentClickExpressionID = 0;
BP_STRUCT_StoreClothes_CurrentItemInfo = {
	item_index = 1,
	item_shopID = 0,
	item_id = 0,
	item_name = "",
	item_desc = "",
	item_quality = 0,
	item_expression = 0,
	item_gift = 0,
	item_jump = "",
	item_festivalImage = "",
	item_equiped = false,
	item_collected = false,
	item_collected_num = 0,

	item_have = false,
	item_soldOut = false,
	priceNumMax = 0,			--价格数量上限
	item_saleEndTime = 0,	--下架时间
	BP_ARRAY_StoreClothes_LowestPrice = _G.BP_ARRAY_StoreClothes_LowestPrice,
}

function bp_store_clothes_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_store_clothes,
		{
			{Path="/Game/UMG/UI_Logic/Store/Store_Clothes_Logic_BP.Store_Clothes_Logic_BP_C", Container="Default", ZOrder=9}
		},
		{"Lobby"},
		false,
		false,
		true
	);
end

function StoreClothesUI.Show(tab_id, subTab_id, jump_info)
	local sameTab = StoreClothesUI.subTab_id == subTab_id;
	log("[HHF]StoreClothesUI.Show, tab_id = " .. tostring(tab_id) .. ", subTab_id = " .. tostring(subTab_id) .. ", sameTab = " .. tostring(sameTab));
	--log_tree("[HHF]StoreClothesUI.Show, jump_info = ", jump_info, "[HHF]");
	StoreClothesUI.tab_id = tab_id;
	StoreClothesUI.subTab_id = subTab_id;
	StoreClothesUI.jump_info = jump_info;
	ModelDisplayer.SetShowtype(ModelDisplayer.SHOWTYPE_AVATAR);

	LobbyCameraManager.SwitchCamera(LobbyCameraManager.store_clothes)

	if StoreClothesUI.bShowing == false then
		StoreClothesUI.bShowing = true;
		EventSystem:registEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_DATA, StoreClothesUI.OnDataReady);
		EventSystem:registEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_COLLECT, StoreClothesUI.OnCollectedResult);
		EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_DATA_CHANGE, StoreClothesUI.OnItemDataChange);
		StoreClothesUI.ReleaseData();
		StoreClothesUI.SetTabMapAndFilterList();
		StoreSystem.GetTabData(StoreSystem.store_tab, tab_id);
	else
		if sameTab == false then
			StoreClothesUI.SwitchItemBySubTab();
			StoreClothesUI.FilterItemByIndex();
			StoreClothesUI.UpdateEquipedAndSelectedState();
			LuaClassObj.HandleUIMessageNoFetch(bp_store_clothes, "ReloadItemList");
		end
	end
end

function StoreClothesUI.ReleaseData()
	log("[HHF]StoreClothesUI.ReleaseData");
	StoreClothesUI.rawData = {};
	StoreClothesUI.tabIDMap = {};
	BP_ARRAY_StoreClothes_FilterList = {};
	StoreClothesUI.allDataList = {};
	StoreClothesUI.tabDataList = {};
	BP_ARRAY_StoreClothes_ShowItemList = {};
end

function StoreClothesUI.SetTabMapAndFilterList()
	StoreClothesUI.tabIDMap = {};
	StoreClothesUI.tabIDMap[StoreSystem.label_subtype_suit] = "套装";
	StoreClothesUI.tabIDMap[StoreSystem.label_subtype_head] = "头部";
	StoreClothesUI.tabIDMap[StoreSystem.label_subtype_face] = "脸部";
	StoreClothesUI.tabIDMap[StoreSystem.label_subtype_clothes] = "衣服";
	StoreClothesUI.tabIDMap[StoreSystem.label_subtype_pants] = "裤子";
	StoreClothesUI.tabIDMap[StoreSystem.label_subtype_shoes] = "鞋子";
	StoreClothesUI.tabIDMap[StoreSystem.label_subtype_parachute] = "降落伞";
	--log_tree("[HHF]StoreClothesUI.SetTabMapAndFilterList, tabIDMap = ", StoreClothesUI.tabIDMap, "[HHF]");

	BP_ARRAY_StoreClothes_FilterList = {};
	table.insert(BP_ARRAY_StoreClothes_FilterList, FuncUtil.GetLocalizeResStr(6482));
	table.insert(BP_ARRAY_StoreClothes_FilterList, FuncUtil.GetLocalizeResStr(6483));
	table.insert(BP_ARRAY_StoreClothes_FilterList, FuncUtil.GetLocalizeResStr(6484));
	table.insert(BP_ARRAY_StoreClothes_FilterList, FuncUtil.GetLocalizeResStr(6485));
	table.insert(BP_ARRAY_StoreClothes_FilterList, FuncUtil.GetLocalizeResStr(6486));
	table.insert(BP_ARRAY_StoreClothes_FilterList, FuncUtil.GetLocalizeResStr(6487));
	table.insert(BP_ARRAY_StoreClothes_FilterList, FuncUtil.GetLocalizeResStr(6488));
	--log_tree("[HHF]StoreClothesUI.SetTabMapAndFilterList, FilterList = ", BP_ARRAY_StoreClothes_FilterList, "[HHF]");
	BP_StoreClothes_CurrentFilterID = 1;
end

function StoreClothesUI.OnDataReady(eventType, eventID, param)
	--log_tree("[HHF]StoreClothesUI.OnDataReady, param = ", param, "[HHF]");
	if param ~= nil and param.tab_type == StoreSystem.store_tab and param.tab_id == StoreClothesUI.tab_id then
		StoreClothesUI.SetData(param.data);
		StoreClothesUI.SwitchItemBySubTab();
		StoreClothesUI.FilterItemByIndex();
		StoreClothesUI.UpdateEquipedAndSelectedState()
		LuaClassObj.HandleDynamicCreation(bp_store_clothes);
		LuaClassObj.HandleUIMessageNoFetch(bp_store_clothes, "SetData");
		LuaClassObj.HandleUIMessageNoFetch(bp_store_clothes, "ReloadItemList");
		LuaClassObj.HandleUIMessageNoFetch(bp_store_clothes, "ShowUI");
		UIManager.Show(eUIType.eStoreClothesPage);

		if StoreClothesUI.jump_info ~= nil then
			BP_StoreClothes_CurrentClickItemID = StoreClothesUI.jump_info.itemId;
			StoreClothesUI.SelectItem(StoreClothesUI.jump_info.itemId, 0, true);
			LuaClassObj.HandleUIMessageNoFetch(bp_store_clothes, "JumpToSelect");
			StoreClothesUI.jump_info = nil;
		end
	else
		log("[HHF]StoreClothesUI.OnDataReady, param = nil and return.");
		StoreClothesUI.Hide();
	end
end

function StoreClothesUI.SetData(info)
	StoreClothesUI.rawData = info;

	local key = StoreSystem.label_market_index_market_list;
	for k, v in pairs(info[key]) do
		local item = StoreClothesUI.GenerateStoreClothesItemData(k, v);
		if item ~= nil then
			if item.item_endTime ~= 0 and item.item_leftTime <= 0 then
				log("[HHF]StoreClothesUI.SetData, itemID = " .. tostring(item.item_id) .. " has expired.");
			else
				--table.insert(StoreClothesUI.allDataList, item);
				StoreClothesUI.allDataList[item.item_shopID] = item;
			end
		end
	end

	BP_StoreClothes_CurrentSex = MultipleAvatar.ShowingAvatarSextype;
	log("[HHF]StoreClothesUI.SetData, current sex = " .. tostring(BP_StoreClothes_CurrentSex));
	--log_tree("[HHF]StoreClothesUI.SetData, after dataList = ", StoreClothesUI.allDataList, "[HHF]");
end

function StoreClothesUI.GenerateStoreClothesItemData(k, v)
	local itemID = v[StoreSystem.label_item_index_id];
	local itemInfo = Client.GetTableData("Item", itemID);
	local serverTime = FuncUtil.GetServerTimeInSec();
	if itemInfo ~= nil then
		local item = {};
		item.item_shopID = k;
		item.item_id = itemID;
		item.item_name = itemInfo.ItemName;
		item.item_desc = itemInfo.ItemDesc;
		item.item_position = itemInfo.WardrobeTab;
		item.item_icon = itemInfo.ItemSmallIcon;
		item.item_quality = itemInfo.ItemQuality;
		item.item_festivalImage = itemInfo.StoreDetailImage;
		item.item_num = v[StoreSystem.label_item_index_count] or 1;
		item.item_sort = v[StoreSystem.label_item_index_rank] or 0;
		item.item_jump = v[StoreSystem.label_item_index_skip_path] or "";
		item.item_startTime = v[StoreSystem.label_item_index_start_time] or 0;
		item.item_collected = StoreSystem.IsCollectedByItemID(itemID);
		item.item_collected_num = StoreSystem.global_collection_num[itemID] or 0;

		--if v[StoreSystem.label_item_index_hot_or_new] == 1 then
		--	item.item_hot = true;
		--	item.item_new = false;
		--elseif v[StoreSystem.label_item_index_hot_or_new] == 2 then
		--	if FuncUtil.GetServerTimeInSec() - item.item_startTime > StoreFuncUtils.NewFlagAvailableTime then
		--		item.item_hot = false;
		--		item.item_new = false;
		--	else
		--		item.item_hot = false;
		--		item.item_new = true;
		--	end
		--else
		--	item.item_hot = false;
		--	item.item_new = false;
		--end

		--if v[StoreSystem.label_item_index_hot_or_new] == 2 and serverTime - item.item_startTime > StoreFuncUtils.NewFlagAvailableTime then
		--	item.item_new = true;
		--else
		--	item.item_new = false;
		--end

		item.BP_ARRAY_StoreClothes_ItemPrice = {};
		item.BP_ARRAY_StoreClothes_LowestPrice = {};
		local price = v[StoreSystem.label_item_index_price_list];
		local firstPriceType = -1;
		if type(price) == "table" then
			for key, value in pairs(price) do
				if StoreFuncUtils.IsValidPrice(v[StoreSystem.label_item_index_vip], value[StoreSystem.label_price_index_price_type]) then
					local temp = {};
					temp.currency = value[StoreSystem.label_price_index_price_type];
					temp.duration = value[StoreSystem.label_price_index_valid_hours] or 0;
					temp.original = value[StoreSystem.label_price_index_one_original_price] or 0;
					temp.discount = value[StoreSystem.label_price_index_one_discount_price] or 0;
					table.insert(item.BP_ARRAY_StoreClothes_ItemPrice, temp);
					
					if firstPriceType == -1 then
						firstPriceType = value[StoreSystem.label_price_index_price_type];
					end
				end
			end

			item.BP_ARRAY_StoreClothes_LowestPrice = StoreFuncUtils.CalculateLowestByCurrency(item.BP_ARRAY_StoreClothes_ItemPrice);
		end
		item.priceNumMax = StoreFuncUtils.GetPriceNumMax(price, firstPriceType);

		item.item_equiped = false;
		item.item_selected = false;
		item.item_have = StoreFuncUtils.HasItem(item.item_id, 0, 0);

		item.item_gift = v[StoreSystem.label_item_index_can_gift] or 0;
		item.item_endTime = v[StoreSystem.label_item_index_time_limit] or 0;
		if item.item_endTime ~= 0 then
			item.item_leftTime = item.item_endTime - FuncUtil.GetServerTimeInSec();
		else
			item.item_leftTime = 0;
		end
		--if v[StoreSystem.label_item_index_show_time_limit] == 1 then
		--	item.item_showLeft = true;
		--else
		--	item.item_showLeft = false;
		--end

		item.item_showLeft = StoreFuncUtils.CheckNeedShowSaleEndTime(v);
		item.item_showLeftIcon = v[StoreSystem.label_item_index_show_time_limit] == 1;

		local discount = v[StoreSystem.label_item_index_discount] or 0;
		item.discount_for_sort = discount;
		local showDiscount, showHot, showVip = StoreFuncUtils.GetItemLeftTopTagsQueue(
				discount ~= 0,
				StoreFuncUtils.CheckIsHot(v) == true,
				v[StoreSystem.label_item_index_vip] == 1);
		if showDiscount == false then
			discount = 0.0;
		end
		item.item_hot = showHot;
		item.item_vip = showVip;
		local discount = v[StoreSystem.label_item_index_discount];
		if discount ~= nil and discount ~= 0 then
			item.item_discount = "-" .. tostring(discount) .. "%";
		else
			item.item_discount = "";
		end

		local showNew, showSpecialIcon = StoreFuncUtils.GetItemRightTopTagsQueue(
				StoreFuncUtils.CheckIsNew(v) == true, --and serverTime - item.item_startTime > StoreFuncUtils.NewFlagAvailableTime,
				itemInfo.SpecialIcon ~= "");
		item.item_new = showNew;
		item.item_showSpecialIcon = showSpecialIcon;

		item.item_expression = v[StoreSystem.label_item_index_expression_id] or 0;

		return item;
	else
		log("[HHF]StoreClothesUI.GenerateStoreClothesItemData, Not found itemID = " .. tostring(itemID) .. " in Item table");
		return nil;
	end
end
function StoreClothesUI.UpdateLeftTime()
	if StoreClothesUI.bShowing == true then
		local needDelete = {};
		local needUpdate = false;
		for k, v in pairs(BP_ARRAY_StoreClothes_ShowItemList) do
			if v.item_endTime ~= 0 then
				v.item_leftTime = v.item_endTime - FuncUtil.GetServerTimeInSec();
				if v.item_leftTime > 0 then
					needUpdate = true;
				end

				if v.item_leftTime <= 0 then
					table.insert(needDelete, k);
				end
			else
				v.item_leftTime = 0;
			end
		end

		if #needDelete > 0 then
			for k, v in pairs(needDelete) do
				StoreClothesUI.allDataList[BP_ARRAY_StoreClothes_ShowItemList[v].item_shopID] = nil;
				StoreClothesUI.tabDataList[BP_ARRAY_StoreClothes_ShowItemList[v].item_shopID] = nil;
				table.remove(BP_ARRAY_StoreClothes_ShowItemList, v);
			end
			LuaClassObj.HandleUIMessageNoFetch(bp_store_clothes, "ReloadItemList");
		else
			if needUpdate == true then
				LuaClassObj.HandleUIMessageNoFetch(bp_store_clothes, "UpdateItemList");
			end
		end
	end
end

function StoreClothesUI.UpdateEquipedAndSelectedState()
	log("[HHF]StoreClothesUI.UpdateEquipedAndSelectedState");
	for k, v in pairs(BP_ARRAY_StoreClothes_ShowItemList) do
		v.item_selected = false;
		v.item_equiped = MultipleAvatar.HasEquiped(v.item_id, 0, 0);
	end
end

function StoreClothesUI.SwitchItemBySubTab()
	log("[HHF]StoreClothesUI.SwitchItemBySubTab, subTab_id = " .. tostring(StoreClothesUI.subTab_id) .. ", subTab_name = " .. tostring(StoreClothesUI.tabIDMap[StoreClothesUI.subTab_id]));
	StoreClothesUI.tabDataList = {};
	for k, v in pairs(StoreClothesUI.allDataList) do
		if v.item_position == StoreClothesUI.tabIDMap[StoreClothesUI.subTab_id] then
			--table.insert(StoreClothesUI.tabDataList, v);
			StoreClothesUI.tabDataList[k] = v;
		end
	end
	--log_tree("[HHF]StoreClothesUI.SwitchItemBySubTab, TabItemList = ", StoreClothesUI.tabDataList, "[HHF]");
end

function StoreClothesUI.FilterItemByIndex()
	if BP_StoreClothes_CurrentFilterID > 0 and
		BP_StoreClothes_CurrentFilterID <= #BP_ARRAY_StoreClothes_FilterList then
		BP_ARRAY_StoreClothes_ShowItemList = {};
		local filter = BP_ARRAY_StoreClothes_FilterList[BP_StoreClothes_CurrentFilterID];
		for k, v in pairs(StoreClothesUI.tabDataList) do
			if filter == FuncUtil.GetLocalizeResStr(6482) then              -- 全部
				table.insert(BP_ARRAY_StoreClothes_ShowItemList, v);
			elseif filter == FuncUtil.GetLocalizeResStr(6483) then          -- 已拥有
				if v.item_have == true then
					table.insert(BP_ARRAY_StoreClothes_ShowItemList, v);
				end
			elseif filter == FuncUtil.GetLocalizeResStr(6484) then          -- 未拥有
				if v.item_have == false then
					table.insert(BP_ARRAY_StoreClothes_ShowItemList, v);
				end
			elseif filter == FuncUtil.GetLocalizeResStr(6485) then          -- 可赠送
				if v.item_gift == 1 then
					table.insert(BP_ARRAY_StoreClothes_ShowItemList, v);
				end
			elseif filter == FuncUtil.GetLocalizeResStr(6486) then          -- 银碎片价格排序
				table.insert(BP_ARRAY_StoreClothes_ShowItemList, v);
			elseif filter == FuncUtil.GetLocalizeResStr(6487) then          -- UC价格排序
				table.insert(BP_ARRAY_StoreClothes_ShowItemList, v);
			elseif filter == FuncUtil.GetLocalizeResStr(6488) then          -- 金币片价格排序
				table.insert(BP_ARRAY_StoreClothes_ShowItemList, v);
			elseif filter == FuncUtil.GetLocalizeResStr(6787) then          -- 金碎片价格排序
				table.insert(BP_ARRAY_StoreClothes_ShowItemList, v);
			end
		end

		log("[HHF]StoreClothesUI.FilterItemByIndex, filterIndex = " .. tostring(BP_StoreClothes_CurrentFilterID) .. ", filterName = " .. tostring(filter));
		StoreClothesUI.SortItemListByFilter(filter);
	else
		log("[HHF]StoreClothesUI.FilterItemByIndex, out of bounds, index = " .. tostring(BP_StoreClothes_CurrentFilterID) ..
			", length = " .. tostring(#BP_ARRAY_StoreClothes_FilterList));
	end
	--log_tree("[HHF]StoreClothesUI.FilterItemByIndex, ShowItemList = ", BP_ARRAY_StoreClothes_ShowItemList, "[HHF]");
end

function StoreClothesUI.SortItemListByFilter(filter)
	log("[HHF]StoreClothesUI.SortItemListByFilter");
	if #BP_ARRAY_StoreClothes_ShowItemList > 1 then
		if filter == FuncUtil.GetLocalizeResStr(6482) then              -- 全部
			table.sort(BP_ARRAY_StoreClothes_ShowItemList,
				function(a, b)
					return StoreFuncUtils.DefaultSortAlgorithm(a, b);
				end);
		elseif filter == FuncUtil.GetLocalizeResStr(6483) then          -- 已拥有
			table.sort(BP_ARRAY_StoreClothes_ShowItemList,
				function(a, b)
					return StoreFuncUtils.DefaultSortAlgorithm(a, b);
				end);
		elseif filter == FuncUtil.GetLocalizeResStr(6484) then          -- 未拥有
			table.sort(BP_ARRAY_StoreClothes_ShowItemList,
				function(a, b)
					return StoreFuncUtils.DefaultSortAlgorithm(a, b);
				end);
		elseif filter == FuncUtil.GetLocalizeResStr(6485) then          -- 可赠送
			table.sort(BP_ARRAY_StoreClothes_ShowItemList,
				function(a, b)
					return StoreFuncUtils.DefaultSortAlgorithm(a, b);
				end);
		elseif filter == FuncUtil.GetLocalizeResStr(6486) then          -- 银碎片价格排序
			table.sort(BP_ARRAY_StoreClothes_ShowItemList,
				function(a, b)
					return StoreFuncUtils.SortPriceListByType(a, b, "BP_ARRAY_StoreClothes_LowestPrice", StoreSystem.label_price_type_chip);
				end);
		elseif filter == FuncUtil.GetLocalizeResStr(6487) then          -- UC价格排序
			table.sort(BP_ARRAY_StoreClothes_ShowItemList,
				function(a, b)
					return StoreFuncUtils.SortPriceListByType(a, b, "BP_ARRAY_StoreClothes_LowestPrice", StoreSystem.label_price_type_uc);
				end);
		elseif filter == FuncUtil.GetLocalizeResStr(6488) then          -- 金币片价格排序
			table.sort(BP_ARRAY_StoreClothes_ShowItemList,
				function(a, b)
					return StoreFuncUtils.SortPriceListByType(a, b, "BP_ARRAY_StoreClothes_LowestPrice", StoreSystem.label_price_type_bp);
				end);
		elseif filter == FuncUtil.GetLocalizeResStr(6787) then          -- 金碎片价格排序
			table.sort(BP_ARRAY_StoreClothes_ShowItemList,
				function(a, b)
					return StoreFuncUtils.SortPriceListByType(a, b, "BP_ARRAY_StoreClothes_LowestPrice", StoreSystem.label_price_type_gold_chip);
				end);
		end
	end
end

function StoreClothesUI.SelectItem(item_id, shop_id, bForceEquip)
	log("[HHF]StoreClothesUI.SelectItem, item_id = " .. tostring(item_id));
	local equiped = MultipleAvatar.HasEquiped(item_id, 0, 0);
	log("[HHF]StoreClothesUI.SelectItem, before click equiped = " .. tostring(equiped));
	StoreMainUI.OnSelectedItem(item_id, 0, 0, bForceEquip);
	equiped = MultipleAvatar.HasEquiped(item_id, 0, 0);
	log("[HHF]StoreClothesUI.SelectItem,  after click equiped = " .. tostring(equiped));

	for k, v in pairs(BP_ARRAY_StoreClothes_ShowItemList) do
		if v.item_id == item_id and (shop_id == 0 or shop_id == v.item_shopID) then
			v.item_selected = true;
			v.item_equiped = equiped;

			-- 点击后new消失
			if v.item_new == true then
				local itemInfo = Client.GetTableData("Item", item_id);
				if itemInfo ~= nil then
					log("v.item_shopID = "..v.item_shopID)
					StoreSystem.CheckRecordNewTag(v.item_shopID);
					local showNew, showSpecialIcon = StoreFuncUtils.GetItemRightTopTagsQueue(
							false,
							itemInfo.SpecialIcon ~= "");
					v.item_new = showNew;
					v.item_showSpecialIcon = showSpecialIcon;
				end
			end

			BP_STRUCT_StoreClothes_CurrentItemInfo.item_index = k;
			BP_STRUCT_StoreClothes_CurrentItemInfo.item_shopID = v.item_shopID;
			BP_STRUCT_StoreClothes_CurrentItemInfo.item_id = v.item_id;
			BP_STRUCT_StoreClothes_CurrentItemInfo.item_name = v.item_name;
			BP_STRUCT_StoreClothes_CurrentItemInfo.item_desc = v.item_desc;
			BP_STRUCT_StoreClothes_CurrentItemInfo.item_quality = v.item_quality;
			BP_STRUCT_StoreClothes_CurrentItemInfo.item_gift = v.item_gift;
			BP_STRUCT_StoreClothes_CurrentItemInfo.item_equiped = v.item_equiped;
			BP_STRUCT_StoreClothes_CurrentItemInfo.item_expression = v.item_equiped and v.item_expression or 0;
			BP_STRUCT_StoreClothes_CurrentItemInfo.item_have = v.item_have;
			BP_STRUCT_StoreClothes_CurrentItemInfo.item_festivalImage = v.item_festivalImage;
			BP_STRUCT_StoreClothes_CurrentItemInfo.item_collected = v.item_collected;
			BP_STRUCT_StoreClothes_CurrentItemInfo.item_collected_num = v.item_collected_num;
			BP_STRUCT_StoreClothes_CurrentItemInfo.item_jump = v.item_jump ~= "" and v.item_jump or tostring(v.item_id);
			BP_STRUCT_StoreClothes_CurrentItemInfo.BP_ARRAY_StoreClothes_LowestPrice = StoreFuncUtils.GetTwoValidPriceForShow(v.BP_ARRAY_StoreClothes_LowestPrice);
			BP_STRUCT_StoreClothes_CurrentItemInfo.priceNumMax = v.priceNumMax
			if v.item_showLeftIcon == true then
				BP_STRUCT_StoreClothes_CurrentItemInfo.item_saleEndTime = v.item_endTime;
			else
				BP_STRUCT_StoreClothes_CurrentItemInfo.item_saleEndTime = 0;
			end
			
			local key = StoreSystem.label_market_index_market_list;
			StoreClothesUI.rawItemInfo = StoreClothesUI.rawData[key][v.item_shopID];
			--log_tree("[HHF]StoreClothesUI.SelectItem, rawItemInfo = ", StoreClothesUI.rawItemInfo, "[HHF]");
			local dayLimit = 0;
			local weekLimit = 0;
			local permanentLimit = 0;
			local limitPurchaseKey = StoreSystem.label_item_index_buy_limit;
			local limitPurchaseInfo = StoreClothesUI.rawItemInfo[limitPurchaseKey];
			if limitPurchaseInfo ~= nil then
				dayLimit = limitPurchaseInfo[StoreSystem.label_buy_limit_type_daily] or 0;
				weekLimit = limitPurchaseInfo[StoreSystem.label_buy_limit_type_week] or 0;
				permanentLimit = limitPurchaseInfo[StoreSystem.label_buy_limit_type_permanent] or 0;
			end
			BP_STRUCT_StoreClothes_CurrentItemInfo.item_soldOut = StoreFuncUtils.IsSoldOut(v.item_id, dayLimit, weekLimit, permanentLimit);
		else
			v.item_selected = false;
			v.item_equiped = MultipleAvatar.HasEquiped(v.item_id, 0, 0);
		end
	end

	LuaClassObj.HandleUIMessageNoFetch(bp_store_clothes, "UpdateItemList");
	LuaClassObj.HandleUIMessageNoFetch(bp_store_clothes, "UpdateItemDetailInfo");

	if BP_StoreClothes_CurrentSex ~= MultipleAvatar.ShowingAvatarSextype then
		BP_StoreClothes_CurrentSex = MultipleAvatar.ShowingAvatarSextype;
		log("[HHF]StoreClothesUI.SelectItem,  after select sex = " .. tostring(BP_StoreClothes_CurrentSex));
		LuaClassObj.HandleUIMessageNoFetch(bp_store_clothes, "UpdateShowSex");
	end
end

function StoreClothesUI.OnItemDataChange(eventType, eventID, vars)
	--log_tree("[HHF]StoreClothesUI.OnItemDataChange, vars = ", vars, "[HHF]");
	local have = StoreFuncUtils.HasItem(BP_StoreClothes_CurrentClickItemID, 0, 0);
	if have == true then
		BP_STRUCT_StoreClothes_CurrentItemInfo.item_have = true;
		local key = BP_STRUCT_StoreClothes_CurrentItemInfo.item_index;
		local shopID = BP_STRUCT_StoreClothes_CurrentItemInfo.item_shopID;
		BP_ARRAY_StoreClothes_ShowItemList[key].item_have = true;
		StoreClothesUI.tabDataList[shopID].item_have = true;
		StoreClothesUI.allDataList[shopID].item_have = true;

		LuaClassObj.HandleUIMessageNoFetch(bp_store_clothes, "UpdateItemList");
		LuaClassObj.HandleUIMessageNoFetch(bp_store_clothes, "UpdateItemDetailInfo");
	end
end

function StoreClothesUI.Hide()
	log("[HHF]StoreClothesUI.Hide");
	if StoreClothesUI.bShowing == true then
		EventSystem:unregistEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_DATA, StoreClothesUI.OnDataReady);
		EventSystem:unregistEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_COLLECT, StoreClothesUI.OnCollectedResult);
		EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_DATA_CHANGE, StoreClothesUI.OnItemDataChange);
		LuaClassObj.HandleUIMessageNoFetch(bp_store_clothes, "HideUI");
		UIManager.Hide(eUIType.eStoreClothesPage);
		StoreClothesUI.bShowing = false;
	end
end

function StoreClothesUI.UIOnlyShow()
	log("[HHF]StoreClothesUI.UIOnlyShow");
	LobbyCameraManager.SwitchCamera(LobbyCameraManager.store_clothes)
	LuaClassObj.HandleUIMessageNoFetch(bp_store_clothes, "OnlyShowUI");
	StoreJumpToChestUI.CheckToShow(BP_StoreClothes_CurrentClickItemID);
end

function StoreClothesUI.UIOnlyHide()
	log("[HHF]StoreClothesUI.UIOnlyHide");
	LuaClassObj.HandleUIMessageNoFetch(bp_store_clothes, "OnlyHideUI");
	StoreJumpToChestUI.Hide();
end

function StoreClothesUI.OnCollectedResult()
	local item_id = BP_StoreClothes_CurrentClickItemID;
	local result = StoreSystem.IsCollectedByItemID(item_id);
	log("[HHF]StoreClothesUI.OnCollectedResult, result = " .. tostring(result));
	if result == true then
		if StoreSystem.global_collection_num[item_id] == nil then
			StoreSystem.global_collection_num[item_id] = 1;
		else
			StoreSystem.global_collection_num[item_id] = StoreSystem.global_collection_num[item_id] + 1;
		end
	else
		StoreSystem.global_collection_num[item_id] = StoreSystem.global_collection_num[item_id] - 1;
	end
	BP_STRUCT_StoreClothes_CurrentItemInfo.item_collected = result;
	BP_STRUCT_StoreClothes_CurrentItemInfo.item_collected_num = StoreSystem.global_collection_num[item_id];
	local key = BP_STRUCT_StoreClothes_CurrentItemInfo.item_index;
	local shopID = BP_STRUCT_StoreClothes_CurrentItemInfo.item_shopID;
	BP_ARRAY_StoreClothes_ShowItemList[key].item_collected = result;
	BP_ARRAY_StoreClothes_ShowItemList[key].item_collected_num = StoreSystem.global_collection_num[item_id];
	StoreClothesUI.tabDataList[shopID].item_collected = result;
	StoreClothesUI.tabDataList[shopID].item_collected_num = StoreSystem.global_collection_num[item_id];
	StoreClothesUI.allDataList[shopID].item_collected = result;
	StoreClothesUI.allDataList[shopID].item_collected_num = StoreSystem.global_collection_num[item_id];

	LuaClassObj.HandleUIMessageNoFetch(bp_store_clothes, "UpdateItemDetailInfo");
end

function EventCloseStoreClothesUI()
	log("[HHF]EventCloseStoreClothesUI");
	StoreClothesUI.Hide();
end

function EventFilterStoreClothesItemByIndex()
	log("[HHF]EventFilterStoreClothesItemByIndex");
	GemReportUtils.ReportBtnClickEvent(GemReportUtils.SubEventName_ClothFilter, BP_StoreClothes_CurrentFilterID)
	StoreClothesUI.FilterItemByIndex();
	LuaClassObj.HandleUIMessageNoFetch(bp_store_clothes, "ReloadItemList");
end

function EventOnClickStoreClothesItem()
	log("[HHF]EventOnClickStoreClothesItem, item_id = " .. tostring(BP_StoreClothes_CurrentClickItemID) .. ", shop_id = " .. tostring(BP_StoreClothes_CurrentClickShopID));
	StoreClothesUI.SelectItem(BP_StoreClothes_CurrentClickItemID, BP_StoreClothes_CurrentClickShopID);
	StoreJumpToChestUI.CheckToShow(BP_StoreClothes_CurrentClickItemID);
end

function EventOnClickChangeStoreClothesSex()
	log("[HHF]EventOnClickStoreClothesItem, before click sex = " .. tostring(BP_StoreClothes_CurrentSex));
	MultipleAvatar.SwitchSex();
	BP_StoreClothes_CurrentSex = MultipleAvatar.ShowingAvatarSextype;
	log("[HHF]EventOnClickStoreClothesItem,  after click sex = " .. tostring(BP_StoreClothes_CurrentSex));
	LuaClassObj.HandleUIMessageNoFetch(bp_store_clothes, "UpdateShowSex");
end

function EventOnClickStoreClothesExpression()
	local expressionID = BP_StoreClothes_CurrentClickExpressionID;
	log("[HHF]EventOnClickStoreClothesExpression, expressionID = " .. tostring(expressionID));
	if expressionID ~= 0 then
		StoreMainUI.PlayAvatarEmotion(expressionID);
		StoreMainUI.ResetEmotionTimer();
	end
end

function EventOnClickPurchaseStoreClothes()
	local shopInfo = StoreFuncUtils.ConvertToShopInfo(StoreClothesUI.rawItemInfo, StoreClothesUI.tab_id, StoreClothesUI.subTab_id);
	--log_tree("[HHF]EventOnClickPurchaseStoreClothes, ShopInfo = ", shopInfo, "[HHF]");
	StoreFuncUtils.PurchaseItem(shopInfo);
end

function EventOnClickSendStoreClothes()
	local shopInfo = StoreFuncUtils.ConvertToShopInfo(StoreClothesUI.rawItemInfo, StoreClothesUI.tab_id, StoreClothesUI.subTab_id);
	--log_tree("[HHF]EventOnClickSendStoreClothes, shopInfo = ", shopInfo, "[HHF]");
	StoreFuncUtils.SendGift(shopInfo);
end

function EventOnClickCollectClothes()
	log("[HHF]EventOnClickCollectClothes");
	if UIUtil.CanClickNow(ClickFrequencyLimit.StoreCollectionBtn) == false then
		return;
	end

	if BP_STRUCT_StoreClothes_CurrentItemInfo.item_collected then
		StoreSystem.cancel_market_collect_by_item_req(BP_StoreClothes_CurrentClickItemID);
	else
		StoreSystem.add_market_collect_by_item_req(BP_StoreClothes_CurrentClickItemID, StoreSystem.market_collect_source_market);
	end
end
