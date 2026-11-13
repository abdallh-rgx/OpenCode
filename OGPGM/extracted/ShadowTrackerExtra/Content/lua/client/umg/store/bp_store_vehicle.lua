StoreVehicleUI = StoreVehicleUI or {
	bShowing = false,
	tab_id = 0,
	subTab_id = 0,
	jump_info = nil,

	rawData = {},
	rawItemInfo = {},

	allDataList = {},
	genreDataList = {},

	vehicleSkinID = 1100000000,
}

BP_STRUCT_StoreVehicle_ItemPrice = {
	currency = 0,
	duration = 0,
	original = 0,
	discount = 0,
}

BP_ARRAY_StoreVehicle_ItemPrice = {
	BP_STRUCT_StoreVehicle_ItemPrice = _G.BP_STRUCT_StoreVehicle_ItemPrice,
}

BP_STRUCT_StoreVehicle_LowestPrice = {
	currency = 0,
	price = 0,
	original = 0,
}

BP_ARRAY_StoreVehicle_LowestPrice =
{
	BP_STRUCT_StoreVehicle_LowestPrice = _G.BP_STRUCT_StoreVehicle_LowestPrice,
}

BP_STRUCT_StoreVehicle_ItemInfo = {
	item_shopID = 0,
	item_id = 0,
	item_name = "",
	item_desc = "",
	item_type = 0,
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

	item_gift = 0,          -- 是否可赠送
	item_endTime = 0,       -- 限时结束时间，不限时用0
	item_leftTime = 0,      -- 剩余时间
	item_discount = "",     -- 显示折扣
	item_recommend = false, -- 是否推荐
	item_startTime = 0,     -- 上架时间，排序用
	item_showLeft = true,   -- 显示剩余时间
	item_showLeftIcon = true,   -- 显示剩余时间ICON
	item_showSpecialIcon = true, -- 显示特殊图标
	priceNumMax = 0,
	
	BP_ARRAY_StoreVehicle_ItemPrice = _G.BP_ARRAY_StoreVehicle_ItemPrice,
	BP_ARRAY_StoreVehicle_LowestPrice = _G.BP_ARRAY_StoreVehicle_LowestPrice,
}

BP_ARRAY_StoreVehicle_ShowItemList = {
	BP_STRUCT_StoreVehicle_ItemInfo = _G.BP_STRUCT_StoreVehicle_ItemInfo,
}

BP_ARRAY_StoreVehicle_FilterList = {
	filter_name = "",
}

BP_ARRAY_StoreVehicle_VehicleGenreList = {
	genre_name = "",
}

BP_StoreVehicle_CurrentFilterID = 1;
BP_StoreVehicle_CurrentClickItemID = 0;
BP_STRUCT_StoreVehicle_CurrentItemInfo = {
	item_index = 1,
	item_shopID = 0,
	item_id = 0,
	item_name = "",
	item_desc = "",
	item_quality = 0,
	item_gift = 0,
	item_jump = "",
	item_festivalImage = "",
	item_collected = false,
	item_collected_num = 0,

	item_have = false,
	item_soldOut = false,
	priceNumMax = 0,		--价格数量上限
	item_saleEndTime = 0,	--下架时间
	BP_ARRAY_StoreVehicle_LowestPrice = _G.BP_ARRAY_StoreVehicle_LowestPrice,
}

BP_StoreVehicle_CurrentGenreID = 1;

function bp_store_vehicle_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_store_vehicle,
		{
			{Path="/Game/UMG/UI_Logic/Store/Store/StoreVehicle_Logic_BP.StoreVehicle_Logic_BP_C", Container="Default", ZOrder=99}
		},
		{"Lobby"},
		false,
		false,
		true
	);
end

function StoreVehicleUI.Show(tab_id, subTab_id, jump_info)
	local sameTab = StoreVehicleUI.subTab_id == subTab_id;
	log("[HHF]StoreVehicleUI.Show, tab_id = " .. tostring(tab_id) .. ", subTab_id = " .. tostring(subTab_id) .. ", sameTab = " .. tostring(sameTab));
	--log_tree("[HHF]StoreVehicleUI.Show, jump_info = ", jump_info, "[HHF]");
	StoreVehicleUI.tab_id = tab_id;
	StoreVehicleUI.subTab_id = subTab_id;
	StoreVehicleUI.jump_info = jump_info;

	if StoreVehicleUI.bShowing == false then
		StoreVehicleUI.bShowing = true;
		LobbyCameraManager.SwitchCamera(LobbyCameraManager.store_vehicle)
		LobbySceneManager.SetMallWeaponParticalVisiable(true);
		EventSystem:registEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_DATA, StoreVehicleUI.OnDataReady);
		EventSystem:registEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_COLLECT, StoreVehicleUI.OnCollectedResult);
		EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_DATA_CHANGE, StoreVehicleUI.OnItemDataChange);
		StoreVehicleUI.ReleaseData();
		StoreVehicleUI.SetFilterList();
		StoreSystem.GetTabData(StoreSystem.store_tab, tab_id);
	else
		if sameTab == false then
			StoreVehicleUI.FilterItemByGenre();
			LuaClassObj.HandleUIMessageNoFetch(bp_store_vehicle, "ReloadItemList");
			StoreVehicleUI.ChooseTheFirstOneInDefault();
		end
	end
end

function StoreVehicleUI.ChangeScene(BgUrl)
	LobbySceneManager.ChangeMallSceneMaterial(10)
end

function StoreVehicleUI.ReleaseData()
	log("[HHF]StoreVehicleUI.ReleaseData");
	BP_ARRAY_StoreVehicle_FilterList = {};
	BP_ARRAY_StoreVehicle_VehicleGenreList = {};

	StoreVehicleUI.rawData = {};
	StoreVehicleUI.rawItemInfo = {};
	StoreVehicleUI.allDataList = {};
	StoreVehicleUI.genreDataList = {};
	BP_ARRAY_StoreVehicle_ShowItemList = {};
end

function StoreVehicleUI.SetFilterList()
	BP_ARRAY_StoreVehicle_FilterList = {};
	table.insert(BP_ARRAY_StoreVehicle_FilterList, FuncUtil.GetLocalizeResStr(6482));
	table.insert(BP_ARRAY_StoreVehicle_FilterList, FuncUtil.GetLocalizeResStr(6483));
	table.insert(BP_ARRAY_StoreVehicle_FilterList, FuncUtil.GetLocalizeResStr(6484));
	table.insert(BP_ARRAY_StoreVehicle_FilterList, FuncUtil.GetLocalizeResStr(6485));
	table.insert(BP_ARRAY_StoreVehicle_FilterList, FuncUtil.GetLocalizeResStr(6486));
	table.insert(BP_ARRAY_StoreVehicle_FilterList, FuncUtil.GetLocalizeResStr(6487));
	table.insert(BP_ARRAY_StoreVehicle_FilterList, FuncUtil.GetLocalizeResStr(6488));
	--log_tree("[HHF]StoreVehicleUI.SetFilterList, FilterList = ", BP_ARRAY_StoreVehicle_FilterList, "[HHF]");
	BP_StoreVehicle_CurrentFilterID = 1;

	BP_ARRAY_StoreVehicle_VehicleGenreList = {};
	table.insert(BP_ARRAY_StoreVehicle_VehicleGenreList, FuncUtil.GetLocalizeResStr(4462));
	--log_tree("[HHF]StoreVehicleUI.SetFilterList, VehicleGenreList = ", BP_ARRAY_StoreVehicle_VehicleGenreList, "[HHF]");
	BP_StoreVehicle_CurrentGenreID = 1;
end

function StoreVehicleUI.OnDataReady(eventType, eventID, param)
	--log_tree("[HHF]StoreVehicleUI.OnDataReady, param = ", param, "[HHF]");
	if param ~= nil and param.tab_type == StoreSystem.store_tab and param.tab_id == StoreVehicleUI.tab_id then
		StoreVehicleUI.SetData(param.data);
		StoreVehicleUI.FilterItemByGenre();
		LuaClassObj.HandleDynamicCreation(bp_store_vehicle);
		LuaClassObj.HandleUIMessageNoFetch(bp_store_vehicle, "SetData");
		LuaClassObj.HandleUIMessageNoFetch(bp_store_vehicle, "ReloadItemList");
		LuaClassObj.HandleUIMessageNoFetch(bp_store_vehicle, "ShowUI");
		UIManager.Show(eUIType.eStoreVehiclePage);

		if StoreVehicleUI.jump_info ~= nil then
			BP_StoreVehicle_CurrentClickItemID = StoreVehicleUI.jump_info.itemId;
			StoreVehicleUI.SelectItem(StoreVehicleUI.jump_info.itemId);
			LuaClassObj.HandleUIMessageNoFetch(bp_store_vehicle, "JumpToSelect");
			StoreVehicleUI.jump_info = nil;

			ModelDisplayer.SetShowtype(ModelDisplayer.SHOWTYPE_MODEL);
		else
			StoreVehicleUI.ChooseTheFirstOneInDefault();
		end
	else
		log("[HHF]StoreVehicleUI.OnDataReady, param = nil and return.");
		StoreVehicleUI.Hide();
	end
end

function StoreVehicleUI.SetData(info)
	StoreVehicleUI.rawData = info;

	local key = StoreSystem.label_market_index_market_list;
	for k, v in pairs(info[key]) do
		local item = StoreVehicleUI.GenerateStoreVehicleItemData(k, v);
		if item ~= nil then
			if item.item_endTime ~= 0 and item.item_leftTime <= 0 then
				log("[HHF]StoreVehicleUI.SetData, itemID = " .. tostring(item.item_id) .. " has expired.");
			else
				--table.insert(StoreVehicleUI.allDataList, item);
				StoreVehicleUI.allDataList[item.item_shopID] = item;
			end
		end
	end

	--log_tree("[HHF]StoreVehicleUI.SetData, after dataList = ", StoreVehicleUI.allDataList, "[HHF]");
end

function StoreVehicleUI.GenerateStoreVehicleItemData(k, v)
	local itemID = v[StoreSystem.label_item_index_id];
	local itemInfo = Client.GetTableData("Item", itemID);
	if itemInfo ~= nil then
		local item = {};
		item.item_shopID = k;
		item.item_id = itemID;
		item.item_name = itemInfo.ItemName;
		item.item_desc = itemInfo.ItemDesc;
		item.item_type = itemInfo.ItemSubType;
		item.item_icon = itemInfo.ItemBigIcon;
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

		item.BP_ARRAY_StoreVehicle_ItemPrice = {};
		item.BP_ARRAY_StoreVehicle_LowestPrice = {};
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
					table.insert(item.BP_ARRAY_StoreVehicle_ItemPrice, temp);

					if firstPriceType == -1 then
						firstPriceType = value[StoreSystem.label_price_index_price_type];
					end
				end
			end

			item.BP_ARRAY_StoreVehicle_LowestPrice = StoreFuncUtils.CalculateLowestByCurrency(item.BP_ARRAY_StoreVehicle_ItemPrice);
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
			discount = 0;
		end
		item.item_hot = showHot;
		item.item_vip = showVip;

		if discount ~= 0 then
			item.item_discount = "-" .. tostring(discount) .. "%";
		else
			item.item_discount = "";
		end

		local showNew, showSpecialIcon = StoreFuncUtils.GetItemRightTopTagsQueue(
				StoreFuncUtils.CheckIsNew(v) == true,-- and FuncUtil.GetServerTimeInSec() - item.item_startTime > StoreFuncUtils.NewFlagAvailableTime,
				itemInfo.SpecialIcon ~= "");
		item.item_new = showNew;
		log("item.item_new = "..tostring(item.item_new))
		item.item_showSpecialIcon = showSpecialIcon;

		item.item_recommend = false;

		return item;
	else
		log("[HHF]StoreVehicleUI.GenerateStoreVehicleItemData, Not found itemID = " .. tostring(itemID) .. " in Item table");
		return nil;
	end
end

function StoreVehicleUI.UpdateLeftTime()
	if StoreVehicleUI.bShowing == true then
		local needDelete = {};
		local needUpdate = false;
		for k, v in pairs(BP_ARRAY_StoreVehicle_ShowItemList) do
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
			local selected = false;
			for k, v in pairs(needDelete) do
				if v == BP_STRUCT_StoreVehicle_CurrentItemInfo.item_index then
					selected = true;
				end
				StoreVehicleUI.allDataList[BP_ARRAY_StoreVehicle_ShowItemList[v].item_shopID] = nil;
				StoreVehicleUI.genreDataList[BP_ARRAY_StoreVehicle_ShowItemList[v].item_shopID] = nil;
				table.remove(BP_ARRAY_StoreVehicle_ShowItemList, v);
			end
			LuaClassObj.HandleUIMessageNoFetch(bp_store_vehicle, "ReloadItemList");
			if selected == true then
				StoreVehicleUI.ChooseTheFirstOneInDefault();
			end
		else
			if needUpdate == true then
				LuaClassObj.HandleUIMessageNoFetch(bp_store_vehicle, "UpdateItemList");
			end
		end
	end
end

function StoreVehicleUI.FilterItemByGenre()
	if BP_StoreVehicle_CurrentGenreID > 0 and BP_StoreVehicle_CurrentGenreID <= #BP_ARRAY_StoreVehicle_VehicleGenreList then
		local filter = BP_ARRAY_StoreVehicle_VehicleGenreList[BP_StoreVehicle_CurrentGenreID];
		StoreVehicleUI.genreDataList = {};
		for k, v in pairs(StoreVehicleUI.allDataList) do
			if filter == FuncUtil.GetLocalizeResStr(6482) then                  -- 全部
				--table.insert(StoreVehicleUI.genreDataList, v);
				StoreVehicleUI.genreDataList[k] = v;
			elseif filter == StoreVehicleUI.GetVehicleGenreByID(v.item_id) then -- 型号
				--table.insert(StoreVehicleUI.genreDataList, v);
				StoreVehicleUI.genreDataList[k] = v;
			end
		end

		log("[HHF]StoreVehicleUI.FilterItemByGenre, filterIndex = " .. tostring(BP_StoreVehicle_CurrentGenreID) .. ", filterName = " .. tostring(filter));
		StoreVehicleUI.FilterItemByIndex();
	else
		log("[HHF]StoreVehicleUI.FilterItemByGenre, out of bounds, index = " .. tostring(BP_StoreVehicle_CurrentGenreID) ..
			", length = " .. tostring(#BP_ARRAY_StoreVehicle_VehicleGenreList));
	end
end

function StoreVehicleUI.GetVehicleGenreByID(id)
	local oldID = id;
	local genre = "";
	if id > StoreVehicleUI.vehicleSkinID then
		id = math.floor(id / 1000);
		id = id % 1000000;

		local itemInfo = Client.GetTableData("Item", id);
		if itemInfo and itemInfo.ItemType == 1 then
			genre = itemInfo.ArmorySimpleDesc;
		end
	end
	log("[HHF]StoreVehicleUI.GetVehicleGenreByID, id = " .. tostring(oldID) .. ", genre = " .. tostring(genre));
	return genre;
end

function StoreVehicleUI.FilterItemByIndex()
	if BP_StoreVehicle_CurrentFilterID > 0 and
		BP_StoreVehicle_CurrentFilterID <= #BP_ARRAY_StoreVehicle_FilterList then
		BP_ARRAY_StoreVehicle_ShowItemList = {};
		local filter = BP_ARRAY_StoreVehicle_FilterList[BP_StoreVehicle_CurrentFilterID];
		for k, v in pairs(StoreVehicleUI.genreDataList) do
			if filter == FuncUtil.GetLocalizeResStr(6482) then              -- 全部
				table.insert(BP_ARRAY_StoreVehicle_ShowItemList, v);
			elseif filter == FuncUtil.GetLocalizeResStr(6483) then          -- 已拥有
				if v.item_have == true then
					table.insert(BP_ARRAY_StoreVehicle_ShowItemList, v);
				end
			elseif filter == FuncUtil.GetLocalizeResStr(6484) then          -- 未拥有
				if v.item_have == false then
					table.insert(BP_ARRAY_StoreVehicle_ShowItemList, v);
				end
			elseif filter == FuncUtil.GetLocalizeResStr(6485) then          -- 可赠送
				if v.item_gift == 1 then
					table.insert(BP_ARRAY_StoreVehicle_ShowItemList, v);
				end
			elseif filter == FuncUtil.GetLocalizeResStr(6486) then          -- 银碎片价格排序
				table.insert(BP_ARRAY_StoreVehicle_ShowItemList, v);
			elseif filter == FuncUtil.GetLocalizeResStr(6487) then          -- UC价格排序
				table.insert(BP_ARRAY_StoreVehicle_ShowItemList, v);
			elseif filter == FuncUtil.GetLocalizeResStr(6488) then          -- 金币片价格排序
				table.insert(BP_ARRAY_StoreVehicle_ShowItemList, v);
			end
		end

		log("[HHF]StoreVehicleUI.FilterItemByIndex, filterIndex = " .. tostring(BP_StoreVehicle_CurrentFilterID) .. ", filterName = " .. tostring(filter));
		StoreVehicleUI.SortItemListByFilter(filter);
	else
		log("[HHF]StoreVehicleUI.FilterItemByIndex, out of bounds, index = " .. tostring(BP_StoreVehicle_CurrentFilterID) ..
			", length = " .. tostring(#BP_ARRAY_StoreVehicle_FilterList));
	end
	--log_tree("[HHF]StoreVehicleUI.FilterItemByIndex, ShowItemList = ", BP_ARRAY_StoreVehicle_ShowItemList, "[HHF]");
end

function StoreVehicleUI.SortItemListByFilter(filter)
	log("[HHF]StoreVehicleUI.SortItemListByFilter");
	if #BP_ARRAY_StoreVehicle_ShowItemList > 1 then
		if filter == FuncUtil.GetLocalizeResStr(6482) then              -- 全部
			table.sort(BP_ARRAY_StoreVehicle_ShowItemList,
				function(a, b)
					return StoreFuncUtils.DefaultSortAlgorithm(a, b);
				end);
		elseif filter == FuncUtil.GetLocalizeResStr(6483) then          -- 已拥有
			table.sort(BP_ARRAY_StoreVehicle_ShowItemList,
				function(a, b)
					return StoreFuncUtils.DefaultSortAlgorithm(a, b);
				end);
		elseif filter == FuncUtil.GetLocalizeResStr(6484) then          -- 未拥有
			table.sort(BP_ARRAY_StoreVehicle_ShowItemList,
				function(a, b)
					return StoreFuncUtils.DefaultSortAlgorithm(a, b);
				end);
		elseif filter == FuncUtil.GetLocalizeResStr(6485) then          -- 可赠送
			table.sort(BP_ARRAY_StoreVehicle_ShowItemList,
				function(a, b)
					return StoreFuncUtils.DefaultSortAlgorithm(a, b);
				end);
		elseif filter == FuncUtil.GetLocalizeResStr(6486) then          -- 银碎片价格排序
			table.sort(BP_ARRAY_StoreVehicle_ShowItemList,
				function(a, b)
					return StoreFuncUtils.SortPriceListByType(a, b, "BP_ARRAY_StoreVehicle_LowestPrice", StoreSystem.label_price_type_chip);
				end);
		elseif filter == FuncUtil.GetLocalizeResStr(6487) then          -- UC价格排序
			table.sort(BP_ARRAY_StoreVehicle_ShowItemList,
				function(a, b)
					return StoreFuncUtils.SortPriceListByType(a, b, "BP_ARRAY_StoreVehicle_LowestPrice", StoreSystem.label_price_type_uc);
				end);
		elseif filter == FuncUtil.GetLocalizeResStr(6488) then          -- 金币片价格排序
			table.sort(BP_ARRAY_StoreVehicle_ShowItemList,
				function(a, b)
					return StoreFuncUtils.SortPriceListByType(a, b, "BP_ARRAY_StoreVehicle_LowestPrice", StoreSystem.label_price_type_bp);
				end);
		elseif filter == FuncUtil.GetLocalizeResStr(6787) then          -- 金碎片价格排序
			table.sort(BP_ARRAY_StoreClothes_ShowItemList,
				function(a, b)
					return StoreFuncUtils.SortPriceListByType(a, b, "BP_ARRAY_StoreVehicle_LowestPrice", StoreSystem.label_price_type_gold_chip);
				end);
		end
	end
end

function StoreVehicleUI.SelectItem(item_id)
	log("[HHF]StoreVehicleUI.SelectItem, item_id = " .. tostring(item_id));
	StoreMainUI.OnSelectedItem(item_id, 0, 0);
	for k, v in pairs(BP_ARRAY_StoreVehicle_ShowItemList) do
		if v.item_id == item_id then
			v.item_selected = true;
			BP_STRUCT_StoreVehicle_CurrentItemInfo.item_index = k;
			BP_STRUCT_StoreVehicle_CurrentItemInfo.item_shopID = v.item_shopID;
			BP_STRUCT_StoreVehicle_CurrentItemInfo.item_id = v.item_id;
			BP_STRUCT_StoreVehicle_CurrentItemInfo.item_name = v.item_name;
			BP_STRUCT_StoreVehicle_CurrentItemInfo.item_desc = v.item_desc;
			BP_STRUCT_StoreVehicle_CurrentItemInfo.item_quality = v.item_quality;
			BP_STRUCT_StoreVehicle_CurrentItemInfo.item_gift = v.item_gift;
			BP_STRUCT_StoreVehicle_CurrentItemInfo.item_have = v.item_have;
			BP_STRUCT_StoreVehicle_CurrentItemInfo.item_festivalImage = v.item_festivalImage;
			BP_STRUCT_StoreVehicle_CurrentItemInfo.item_jump = v.item_jump ~= "" and v.item_jump or tostring(v.item_id);
			BP_STRUCT_StoreVehicle_CurrentItemInfo.item_collected = v.item_collected;
			BP_STRUCT_StoreVehicle_CurrentItemInfo.item_collected_num = v.item_collected_num;
			BP_STRUCT_StoreVehicle_CurrentItemInfo.BP_ARRAY_StoreVehicle_LowestPrice = StoreFuncUtils.GetTwoValidPriceForShow(v.BP_ARRAY_StoreVehicle_LowestPrice);
			BP_STRUCT_StoreVehicle_CurrentItemInfo.priceNumMax = v.priceNumMax
			if v.item_showLeftIcon == true then
				BP_STRUCT_StoreVehicle_CurrentItemInfo.item_saleEndTime = v.item_endTime;
			else
				BP_STRUCT_StoreVehicle_CurrentItemInfo.item_saleEndTime = 0;
			end

			local key = StoreSystem.label_market_index_market_list;
			StoreVehicleUI.rawItemInfo = StoreVehicleUI.rawData[key][v.item_shopID];
			--log_tree("[HHF]EventOnClickStoreVehicleItem, rawItemInfo = ", StoreVehicleUI.rawItemInfo, "[HHF]");
			local dayLimit = 0;
			local weekLimit = 0;
			local permanentLimit = 0;
			local limitPurchaseKey = StoreSystem.label_item_index_buy_limit;
			local limitPurchaseInfo = StoreVehicleUI.rawItemInfo[limitPurchaseKey];
			if limitPurchaseInfo ~= nil then
				dayLimit = limitPurchaseInfo[StoreSystem.label_buy_limit_type_daily] or 0;
				weekLimit = limitPurchaseInfo[StoreSystem.label_buy_limit_type_week] or 0;
				permanentLimit = limitPurchaseInfo[StoreSystem.label_buy_limit_type_permanent] or 0;
			end
			BP_STRUCT_StoreVehicle_CurrentItemInfo.item_soldOut = StoreFuncUtils.IsSoldOut(v.item_id, dayLimit, weekLimit, permanentLimit);
		else
			v.item_selected = false;
		end
	end

	LuaClassObj.HandleUIMessageNoFetch(bp_store_vehicle, "UpdateItemList");
	LuaClassObj.HandleUIMessageNoFetch(bp_store_vehicle, "UpdateItemDetailInfo");
	StoreJumpToChestUI.CheckToShow(item_id);
end

function StoreVehicleUI.ChooseTheFirstOneInDefault()
	if BP_ARRAY_StoreVehicle_ShowItemList[1] ~= nil then
		log("[HHF]StoreVehicleUI.ChooseTheFirstOneInDefault");
		BP_StoreVehicle_CurrentClickItemID = BP_ARRAY_StoreVehicle_ShowItemList[1].item_id;
		StoreVehicleUI.SelectItem(BP_StoreVehicle_CurrentClickItemID);
		ModelDisplayer.SetShowtype(ModelDisplayer.SHOWTYPE_MODEL);
	else
		log("[HHF]StoreVehicleUI.ChooseTheFirstOneInDefault, but is empty.");
	end
end

function StoreVehicleUI.OnItemDataChange(eventType, eventID, vars)
	--log_tree("[HHF]StoreVehicleUI.OnItemDataChange, vars = ", vars, "[HHF]");
	local have = StoreFuncUtils.HasItem(BP_StoreVehicle_CurrentClickItemID, 0, 0);
	if have == true then
		BP_STRUCT_StoreVehicle_CurrentItemInfo.item_have = true;
		local key = BP_STRUCT_StoreVehicle_CurrentItemInfo.item_index;
		local shopID = BP_STRUCT_StoreVehicle_CurrentItemInfo.item_shopID;
		BP_ARRAY_StoreVehicle_ShowItemList[key].item_have = true;
		StoreVehicleUI.genreDataList[shopID].item_have = true;
		StoreVehicleUI.allDataList[shopID].item_have = true;

		LuaClassObj.HandleUIMessageNoFetch(bp_store_vehicle, "UpdateItemList");
		LuaClassObj.HandleUIMessageNoFetch(bp_store_vehicle, "UpdateItemDetailInfo");

		local priceInfo = {};
		priceInfo.PriceType1 = BP_STRUCT_StoreVehicle_CurrentItemInfo.BP_ARRAY_StoreVehicle_LowestPrice[1].currency;
		priceInfo.PriceNum1 = BP_STRUCT_StoreVehicle_CurrentItemInfo.BP_ARRAY_StoreVehicle_LowestPrice[1].original;
		priceInfo.DiscountNum1 = BP_STRUCT_StoreVehicle_CurrentItemInfo.BP_ARRAY_StoreVehicle_LowestPrice[1].price;
		priceInfo.PriceType2 = BP_STRUCT_StoreVehicle_CurrentItemInfo.BP_ARRAY_StoreVehicle_LowestPrice[2].currency;
		priceInfo.PriceNum2 = BP_STRUCT_StoreVehicle_CurrentItemInfo.BP_ARRAY_StoreVehicle_LowestPrice[2].original;
		priceInfo.DiscountNum2 = BP_STRUCT_StoreVehicle_CurrentItemInfo.BP_ARRAY_StoreVehicle_LowestPrice[2].price;
		priceInfo.isSoldOut = BP_STRUCT_StoreVehicle_CurrentItemInfo.item_soldOut;
		priceInfo.isHaveItem = BP_STRUCT_StoreVehicle_CurrentItemInfo.item_have;
		priceInfo.priceNumMax = BP_STRUCT_StoreVehicle_CurrentItemInfo.priceNumMax;
		priceInfo.saleEndTime = BP_STRUCT_StoreVehicle_CurrentItemInfo.item_saleEndTime;
		StorePreviewUI.RefreshView(priceInfo);
	end
end

function StoreVehicleUI.OnCollectedResult()
	local item_id = BP_StoreVehicle_CurrentClickItemID;
	local result = StoreSystem.IsCollectedByItemID(item_id);
	log("[HHF]StoreVehicleUI.OnCollectedResult, result = " .. tostring(result));
	if result == true then
		if StoreSystem.global_collection_num[item_id] == nil then
			StoreSystem.global_collection_num[item_id] = 1;
		else
			StoreSystem.global_collection_num[item_id] = StoreSystem.global_collection_num[item_id] + 1;
		end
	else
		StoreSystem.global_collection_num[item_id] = StoreSystem.global_collection_num[item_id] - 1;
	end
	BP_STRUCT_StoreVehicle_CurrentItemInfo.item_collected = result;
	BP_STRUCT_StoreVehicle_CurrentItemInfo.item_collected_num = StoreSystem.global_collection_num[item_id];
	local key = BP_STRUCT_StoreVehicle_CurrentItemInfo.item_index;
	local shopID = BP_STRUCT_StoreVehicle_CurrentItemInfo.item_shopID;
	BP_ARRAY_StoreVehicle_ShowItemList[key].item_collected = result;
	BP_ARRAY_StoreVehicle_ShowItemList[key].item_collected_num = StoreSystem.global_collection_num[item_id];
	StoreVehicleUI.genreDataList[shopID].item_collected = result;
	StoreVehicleUI.genreDataList[shopID].item_collected_num = StoreSystem.global_collection_num[item_id];
	StoreVehicleUI.allDataList[shopID].item_collected = result;
	StoreVehicleUI.allDataList[shopID].item_collected_num = StoreSystem.global_collection_num[item_id];

	LuaClassObj.HandleUIMessageNoFetch(bp_store_vehicle, "UpdateItemDetailInfo");
end

function StoreVehicleUI.Hide()
	log("[HHF]StoreVehicleUI.Hide");
	if StoreVehicleUI.bShowing == true then
		EventSystem:unregistEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_DATA, StoreVehicleUI.OnDataReady);
		EventSystem:unregistEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_COLLECT, StoreVehicleUI.OnCollectedResult);
		EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_DATA_CHANGE, StoreVehicleUI.OnItemDataChange);
		LuaClassObj.HandleUIMessageNoFetch(bp_store_vehicle, "HideUI");
		UIManager.Hide(eUIType.eStoreVehiclePage);
		StoreVehicleUI.bShowing = false;

		LobbySceneManager.SetMallWeaponParticalVisiable(false);
	end
end

function StoreVehicleUI.UIOnlyShow()
	log("[HHF]StoreVehicleUI.UIOnlyShow");
	LobbyCameraManager.SwitchCamera(LobbyCameraManager.store_vehicle)
	LuaClassObj.HandleUIMessageNoFetch(bp_store_vehicle, "OnlyShowUI");
	StoreJumpToChestUI.CheckToShow(BP_StoreVehicle_CurrentClickItemID);
end

function StoreVehicleUI.UIOnlyHide()
	log("[HHF]StoreVehicleUI.UIOnlyHide");
	LuaClassObj.HandleUIMessageNoFetch(bp_store_vehicle, "OnlyHideUI");
	StoreJumpToChestUI.Hide();
end

function StoreVehicleUI.ShowPreviousOne()
	local currentIndex = BP_STRUCT_StoreVehicle_CurrentItemInfo.item_index;
	local previousIndex = BP_STRUCT_StoreVehicle_CurrentItemInfo.item_index;
	if previousIndex > 1 then
		previousIndex = previousIndex - 1;
	else
		previousIndex = #BP_ARRAY_StoreVehicle_ShowItemList;
	end
	log("[HHF]StoreVehicleUI.ShowPreviousOne, previousIndex = " .. tostring(previousIndex) .. ", currentIndex = " .. tostring(currentIndex));

	BP_StoreVehicle_CurrentClickItemID = BP_ARRAY_StoreVehicle_ShowItemList[previousIndex].item_id;
	StoreVehicleUI.SelectItem(BP_StoreVehicle_CurrentClickItemID);

	local itemInfo = {};
	itemInfo.item_id = BP_STRUCT_StoreVehicle_CurrentItemInfo.item_id;
	itemInfo.item_gift = BP_STRUCT_StoreVehicle_CurrentItemInfo.item_gift;
	itemInfo.item_killBroadcast = false;
	itemInfo.item_jump = BP_STRUCT_StoreVehicle_CurrentItemInfo.item_jump;
	itemInfo.saleEndTime = BP_STRUCT_StoreVehicle_CurrentItemInfo.item_saleEndTime;
	itemInfo.item_collected = BP_STRUCT_StoreVehicle_CurrentItemInfo.item_collected;
	itemInfo.item_collected_num = BP_STRUCT_StoreVehicle_CurrentItemInfo.item_collected_num;

	local priceInfo = {};
	priceInfo.PriceType1 = BP_STRUCT_StoreVehicle_CurrentItemInfo.BP_ARRAY_StoreVehicle_LowestPrice[1].currency;
	priceInfo.PriceNum1 = BP_STRUCT_StoreVehicle_CurrentItemInfo.BP_ARRAY_StoreVehicle_LowestPrice[1].original;
	priceInfo.DiscountNum1 = BP_STRUCT_StoreVehicle_CurrentItemInfo.BP_ARRAY_StoreVehicle_LowestPrice[1].price;
	priceInfo.PriceType2 = BP_STRUCT_StoreVehicle_CurrentItemInfo.BP_ARRAY_StoreVehicle_LowestPrice[2].currency;
	priceInfo.PriceNum2 = BP_STRUCT_StoreVehicle_CurrentItemInfo.BP_ARRAY_StoreVehicle_LowestPrice[2].original;
	priceInfo.DiscountNum2 = BP_STRUCT_StoreVehicle_CurrentItemInfo.BP_ARRAY_StoreVehicle_LowestPrice[2].price;
	priceInfo.isSoldOut = BP_STRUCT_StoreVehicle_CurrentItemInfo.item_soldOut;
	priceInfo.isHaveItem = BP_STRUCT_StoreVehicle_CurrentItemInfo.item_have;
	priceInfo.priceNumMax = BP_STRUCT_StoreVehicle_CurrentItemInfo.priceNumMax;

	return itemInfo, priceInfo, EventOnClickPurchaseStoreVehicle, EventOnClickSendStoreVehicle;
end

function StoreVehicleUI.ShowNextOne()
	local currentIndex = BP_STRUCT_StoreVehicle_CurrentItemInfo.item_index;
	local nextIndex = BP_STRUCT_StoreVehicle_CurrentItemInfo.item_index;
	if nextIndex < #BP_ARRAY_StoreVehicle_ShowItemList then
		nextIndex = nextIndex + 1;
	else
		nextIndex = 1;
	end
	log("[HHF]StoreVehicleUI.ShowPreviousOne, currentIndex = " .. tostring(currentIndex) .. ", nextIndex = " .. tostring(nextIndex));

	BP_StoreVehicle_CurrentClickItemID = BP_ARRAY_StoreVehicle_ShowItemList[nextIndex].item_id;
	StoreVehicleUI.SelectItem(BP_StoreVehicle_CurrentClickItemID);

	local itemInfo = {};
	itemInfo.item_id = BP_STRUCT_StoreVehicle_CurrentItemInfo.item_id;
	itemInfo.item_gift = BP_STRUCT_StoreVehicle_CurrentItemInfo.item_gift;
	itemInfo.item_killBroadcast = false;
	itemInfo.item_jump = BP_STRUCT_StoreVehicle_CurrentItemInfo.item_jump;
	itemInfo.saleEndTime = BP_STRUCT_StoreVehicle_CurrentItemInfo.item_saleEndTime;
	itemInfo.item_collected = BP_STRUCT_StoreVehicle_CurrentItemInfo.item_collected;
	itemInfo.item_collected_num = BP_STRUCT_StoreVehicle_CurrentItemInfo.item_collected_num;

	local priceInfo = {};
	priceInfo.PriceType1 = BP_STRUCT_StoreVehicle_CurrentItemInfo.BP_ARRAY_StoreVehicle_LowestPrice[1].currency;
	priceInfo.PriceNum1 = BP_STRUCT_StoreVehicle_CurrentItemInfo.BP_ARRAY_StoreVehicle_LowestPrice[1].original;
	priceInfo.DiscountNum1 = BP_STRUCT_StoreVehicle_CurrentItemInfo.BP_ARRAY_StoreVehicle_LowestPrice[1].price;
	priceInfo.PriceType2 = BP_STRUCT_StoreVehicle_CurrentItemInfo.BP_ARRAY_StoreVehicle_LowestPrice[2].currency;
	priceInfo.PriceNum2 = BP_STRUCT_StoreVehicle_CurrentItemInfo.BP_ARRAY_StoreVehicle_LowestPrice[2].original;
	priceInfo.DiscountNum2 = BP_STRUCT_StoreVehicle_CurrentItemInfo.BP_ARRAY_StoreVehicle_LowestPrice[2].price;
	priceInfo.isSoldOut = BP_STRUCT_StoreVehicle_CurrentItemInfo.item_soldOut;
	priceInfo.isHaveItem = BP_STRUCT_StoreVehicle_CurrentItemInfo.item_have;
	priceInfo.priceNumMax = BP_STRUCT_StoreVehicle_CurrentItemInfo.priceNumMax;

	return itemInfo, priceInfo, EventOnClickPurchaseStoreVehicle, EventOnClickSendStoreVehicle;
end

function EventCloseStoreVehicleUI()
	log("[HHF]EventCloseStoreVehicleUI");
	StoreVehicleUI.Hide();
end

function EventFilterStoreVehicleItemByGenre()
	log("[HHF]EventFilterStoreVehicleItemByGenre");
	StoreVehicleUI.FilterItemByGenre();
	LuaClassObj.HandleUIMessageNoFetch(bp_store_vehicle, "ReloadItemList");
end

function EventFilterStoreVehicleItemByIndex()
	log("[HHF]EventFilterStoreVehicleItemByIndex");
	StoreVehicleUI.FilterItemByIndex();
	LuaClassObj.HandleUIMessageNoFetch(bp_store_vehicle, "ReloadItemList");
end

function EventOnClickStoreVehicleItem()
	log("[HHF]EventOnClickStoreVehicleItem, item_id = " .. tostring(BP_StoreVehicle_CurrentClickItemID));
	if BP_StoreVehicle_CurrentClickItemID ~= BP_STRUCT_StoreVehicle_CurrentItemInfo.item_id then
		StoreVehicleUI.SelectItem(BP_StoreVehicle_CurrentClickItemID);
	end
	StoreVehicleUI.CheckToUpdateNewTag(BP_StoreVehicle_CurrentClickItemID);
	--StoreJumpToChestUI.CheckToShow(BP_StoreVehicle_CurrentClickItemID);
end

function StoreVehicleUI.CheckToUpdateNewTag(item_id)
	for k, v in pairs(BP_ARRAY_StoreVehicle_ShowItemList) do
		if v.item_id == item_id then
			if v.item_new == true then
				local itemInfo = Client.GetTableData("Item", v.item_id);
				if itemInfo ~= nil then
					StoreSystem.CheckRecordNewTag(v.item_shopID);
					local showNew, showSpecialIcon = StoreFuncUtils.GetItemRightTopTagsQueue(
							false,
							itemInfo.SpecialIcon ~= "");
					v.item_new = showNew;
					v.item_showSpecialIcon = showSpecialIcon
					LuaClassObj.HandleUIMessageNoFetch(bp_store_vehicle, "UpdateItemList");
				end
			end
		end
	end
end

function StoreVehicleUI.GetTwoValidPriceForShow(price)
	local currency = {};
	table.insert(currency, StoreSystem.label_price_type_bp);
	table.insert(currency, StoreSystem.label_price_type_chip);
	table.insert(currency, StoreSystem.label_price_type_uc);

	local result = {};
	for k, v in pairs(currency) do
		if price[v] ~= nil and price[v].price > 0 then
			table.insert(result, price[v]);
		end
	end

	while #result < 2 do
		local temp = {};
		temp.currency = -1;
		temp.price = 0;
		temp.original = 0;
		table.insert(result, temp);
	end

	return result;
end

function EventOnClickPurchaseStoreVehicle()
	local shopInfo = StoreFuncUtils.ConvertToShopInfo(StoreVehicleUI.rawItemInfo, StoreVehicleUI.tab_id, StoreVehicleUI.subTab_id);
	--log_tree("[HHF]EventOnClickPurchaseStoreVehicle, ShopInfo = ", shopInfo, "[HHF]");
	StoreFuncUtils.PurchaseItem(shopInfo);
end

function EventOnClickSendStoreVehicle()
	local shopInfo = StoreFuncUtils.ConvertToShopInfo(StoreVehicleUI.rawItemInfo, StoreVehicleUI.tab_id, StoreVehicleUI.subTab_id);
	--log_tree("[HHF]EventOnClickSendStoreVehicle, shopInfo = ", shopInfo, "[HHF]");
	StoreFuncUtils.SendGift(shopInfo);
end

function EventOnClickStoreVehicleFullScreen()
	log("[HHF]EventOnClickStoreVehicleFullScreen");
	GemReportUtils.ReportBtnClickEvent(GemReportUtils.SubEventName_CarPreview)
	StoreVehicleUI.SwitchToFullScreen();
end

function StoreVehicleUI.SwitchToFullScreen()
	log("[HHF]StoreVehicleUI.SwitchToFullScreen");
	local itemInfo = {};
	itemInfo.item_id = BP_STRUCT_StoreVehicle_CurrentItemInfo.item_id;
	itemInfo.item_gift = BP_STRUCT_StoreVehicle_CurrentItemInfo.item_gift;
	itemInfo.item_killBroadcast = false;
	itemInfo.item_jump = BP_STRUCT_StoreVehicle_CurrentItemInfo.item_jump;
	itemInfo.saleEndTime = BP_STRUCT_StoreVehicle_CurrentItemInfo.item_saleEndTime;
	itemInfo.item_collected = BP_STRUCT_StoreVehicle_CurrentItemInfo.item_collected;
	itemInfo.item_collected_num = BP_STRUCT_StoreVehicle_CurrentItemInfo.item_collected_num;

	local priceInfo = {};
	priceInfo.PriceType1 = BP_STRUCT_StoreVehicle_CurrentItemInfo.BP_ARRAY_StoreVehicle_LowestPrice[1].currency;
	priceInfo.PriceNum1 = BP_STRUCT_StoreVehicle_CurrentItemInfo.BP_ARRAY_StoreVehicle_LowestPrice[1].original;
	priceInfo.DiscountNum1 = BP_STRUCT_StoreVehicle_CurrentItemInfo.BP_ARRAY_StoreVehicle_LowestPrice[1].price;
	priceInfo.PriceType2 = BP_STRUCT_StoreVehicle_CurrentItemInfo.BP_ARRAY_StoreVehicle_LowestPrice[2].currency;
	priceInfo.PriceNum2 = BP_STRUCT_StoreVehicle_CurrentItemInfo.BP_ARRAY_StoreVehicle_LowestPrice[2].original;
	priceInfo.DiscountNum2 = BP_STRUCT_StoreVehicle_CurrentItemInfo.BP_ARRAY_StoreVehicle_LowestPrice[2].price;
	priceInfo.isSoldOut = BP_STRUCT_StoreVehicle_CurrentItemInfo.item_soldOut;
	priceInfo.isHaveItem = BP_STRUCT_StoreVehicle_CurrentItemInfo.item_have;
	priceInfo.priceNumMax = BP_STRUCT_StoreVehicle_CurrentItemInfo.priceNumMax;

	StorePreviewUI.Show(itemInfo,
		priceInfo,
		EventOnClickPurchaseStoreVehicle,
		EventOnClickSendStoreVehicle,
		StoreVehicleUI.ShowPreviousOne,
		StoreVehicleUI.ShowNextOne);
end

function EventOnClickStoreVehicleResetRotation()
	log("[HHF]EventOnClickStoreVehicleResetRotation");
	ModelDisplayer.Display(BP_StoreVehicle_CurrentClickItemID, 0, 0);
end

function EventOnClickCollectVehicle()
	log("[HHF]EventOnClickCollectVehicle");
	if UIUtil.CanClickNow(ClickFrequencyLimit.StoreCollectionBtn) == false then
		return;
	end

	if BP_STRUCT_StoreVehicle_CurrentItemInfo.item_collected then
		StoreSystem.cancel_market_collect_by_item_req(BP_StoreVehicle_CurrentClickItemID);
	else
		StoreSystem.add_market_collect_by_item_req(BP_StoreVehicle_CurrentClickItemID, StoreSystem.market_collect_source_market);
	end
end
