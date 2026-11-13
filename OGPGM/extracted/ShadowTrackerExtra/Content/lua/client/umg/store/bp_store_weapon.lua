StoreWeaponUI = StoreWeaponUI or {
	bShowing = false,
	tab_id = 0,
	subTab_id = 0,
	jump_info = nil,
	oldDisplayType = 0,

	rawData = {},
	rawItemInfo = {},

	allDataList = {},
	tabDataList = {},
	genreDataList = {},

	tabIDMap = {},
	allGunGenreList = {},
	genreIndexMap = {},

	weaponSkinID = 1100000000,
	deadBoxHandler = nil,
}

BP_STRUCT_StoreWeapon_ItemPrice = {
	currency = 0,
	duration = 0,
	original = 0,
	discount = 0,
}

BP_ARRAY_StoreWeapon_ItemPrice = {
	BP_STRUCT_StoreWeapon_ItemPrice = _G.BP_STRUCT_StoreWeapon_ItemPrice,
}

BP_STRUCT_StoreWeapon_LowestPrice = {
	currency = 0,
	price = 0,
	original = 0,
}

BP_ARRAY_StoreWeapon_LowestPrice =
{
	BP_STRUCT_StoreWeapon_LowestPrice = _G.BP_STRUCT_StoreWeapon_LowestPrice,
}

BP_STRUCT_StoreWeapon_ItemInfo = {
	item_shopID = 0,
	item_id = 0,
	item_name = "",
	item_desc = "",
	item_type = 0,
	item_icon = "",
	item_cdn = "",
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
	item_showLeftIcon = true,	--显示显示售卖图标
	item_showSpecialIcon = true, --显示特殊图标

	item_killBroadcast = false,
	priceNumMax = 0,			--价格数量上限
	BP_ARRAY_StoreWeapon_ItemPrice = _G.BP_ARRAY_StoreWeapon_ItemPrice,
	BP_ARRAY_StoreWeapon_LowestPrice = _G.BP_ARRAY_StoreWeapon_LowestPrice,
}

BP_ARRAY_StoreWeapon_ShowItemList = {
	BP_STRUCT_StoreWeapon_ItemInfo = _G.BP_STRUCT_StoreWeapon_ItemInfo,
}

BP_ARRAY_StoreWeapon_FilterList = {
	filter_name = "",
}

BP_ARRAY_StoreWeapon_GunGenreList = {
	genre_name = "",
}

BP_StoreWeapon_CurrentFilterID = 1;
BP_StoreWeapon_CurrentSex = 1;
BP_StoreWeapon_CurrentClickItemID = 0;
BP_STRUCT_StoreWeapon_CurrentItemInfo = {
	item_index = 1,
	item_shopID = 0,
	item_id = 0,
	item_name = "",
	item_desc = "",
	item_quality = 0,
	item_gift = 0,
	item_killBroadcast = false,
	item_index = 1,
	item_jump = "",
	item_festivalImage = "",
	item_collected = false,
	item_collected_num = 0,

	item_have = false,
	item_soldOut = false,
	priceNumMax = 0,			--价格数量上限
	item_saleEndTime = 0,	--下架时间
	BP_ARRAY_StoreWeapon_LowestPrice = _G.BP_ARRAY_StoreWeapon_LowestPrice,
}

BP_StoreWeapon_IsRecommendTab = false;
BP_StoreWeapon_CurrentGenreID = 1;
BP_StoreWeapon_DisplayType = 0; -- 0武器，1人物，2死亡盒子
BP_StoreWeapon_CurrentDeadboxPath = "";


BP_Current_StoreLevelUp_ItemID = 0	--装备升级展示用ID

function bp_store_weapon_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_store_weapon,
		{
			{Path="/Game/UMG/UI_Logic/Store/Store/StoreWeapon_Logic_BP.StoreWeapon_Logic_BP_C", Container="Default", ZOrder=99}
		},
		{"Lobby"},
		false,
		false,
		true
	);
end

function StoreWeaponUI.Show(tab_id, subTab_id, jump_info)
	local sameTab = StoreWeaponUI.subTab_id == subTab_id;
	log("[HHF]StoreWeaponUI.Show, tab_id = " .. tostring(tab_id) .. ", subTab_id = " .. tostring(subTab_id) .. ", sameTab = " .. tostring(sameTab));
	--log_tree("[HHF]StoreWeaponUI.Show, jump_info = ", jump_info, "[HHF]");
	StoreWeaponUI.tab_id = tab_id;
	StoreWeaponUI.subTab_id = subTab_id;
	StoreWeaponUI.jump_info = jump_info;


	if StoreWeaponUI.bShowing == false then
		StoreWeaponUI.bShowing = true;
		LobbyCameraManager.SwitchCamera(LobbyCameraManager.store_weapon)
		LobbySceneManager.SetMallWeaponParticalVisiable(true);
		EventSystem:registEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_DATA, StoreWeaponUI.OnDataReady);
		EventSystem:registEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_COLLECT, StoreWeaponUI.OnCollectedResult);
		EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_DATA_CHANGE, StoreWeaponUI.OnItemDataChange);
		StoreWeaponUI.ReleaseData();
		StoreWeaponUI.SetTabMapAndFilterList();
		StoreSystem.GetTabData(StoreSystem.store_tab, tab_id);
	else
		if sameTab == false then
			StoreWeaponUI.OnDeadBoxRestore();
			StoreWeaponUI.UpdateListHead();
			StoreWeaponUI.SetGenreListSelf();
			StoreWeaponUI.SwitchItemBySubTab();
			StoreWeaponUI.FilterItemByGenre();
			StoreWeaponUI.UpdateEquipedAndSelectedState();
			LuaClassObj.HandleUIMessageNoFetch(bp_store_weapon, "ReloadItemList");
			StoreWeaponUI.ChooseTheFirstOneInDefault();
		end
	end
end

function StoreWeaponUI.ChangeScene(BgUrl)
	LobbySceneManager.ChangeMallSceneMaterial(10)
end

function StoreWeaponUI.SetGenreListSelf()
	log("[HHF]StoreWeaponUI.SetGenreListSelf");
	BP_ARRAY_StoreWeapon_GunGenreList = StoreWeaponUI.allGunGenreList[StoreWeaponUI.tabIDMap[StoreWeaponUI.subTab_id]] or {};
	BP_StoreWeapon_CurrentGenreID = StoreWeaponUI.genreIndexMap[StoreWeaponUI.tabIDMap[StoreWeaponUI.subTab_id]] or 1;
	LuaClassObj.HandleUIMessageNoFetch(bp_store_weapon, "UpdateGenreList");
end

function StoreWeaponUI.ReleaseData()
	log("[HHF]StoreWeaponUI.ReleaseData");
	StoreWeaponUI.tabIDMap = {};
	StoreWeaponUI.genreIndexMap = {};
	BP_ARRAY_StoreWeapon_FilterList = {};
	BP_ARRAY_StoreWeapon_GunGenreList = {};

	StoreWeaponUI.rawData = {};
	StoreWeaponUI.rawItemInfo = {};

	StoreWeaponUI.allDataList = {};
	StoreWeaponUI.tabDataList = {};
	StoreWeaponUI.genreDataList = {};
	BP_ARRAY_StoreWeapon_ShowItemList = {};
end

function StoreWeaponUI.SetTabMapAndFilterList()
	StoreWeaponUI.tabIDMap = {};
	StoreWeaponUI.tabIDMap[StoreSystem.lable_subtype_weapon_suggest] = 100;     -- 推荐
	StoreWeaponUI.tabIDMap[StoreSystem.lable_subtype_weapon_skin_ar] = 101;     -- 突击步枪
	StoreWeaponUI.tabIDMap[StoreSystem.lable_subtype_weapon_skin_sr] = 103;     -- 狙击步枪
	StoreWeaponUI.tabIDMap[StoreSystem.lable_subtype_weapon_skin_smg] = 102;    -- 冲锋枪
	StoreWeaponUI.tabIDMap[StoreSystem.lable_subtype_weapon_skin_sog] = 104;    -- 散弹枪
	StoreWeaponUI.tabIDMap[StoreSystem.lable_subtype_weapon_skin_ciw] = 108;    -- 近战武器
	StoreWeaponUI.tabIDMap[StoreSystem.lable_subtype_weapon_skin_cb] = 107;     -- 弩
	StoreWeaponUI.tabIDMap[StoreSystem.lable_subtype_weapon_skin_mg] = 105;     -- 机枪
	StoreWeaponUI.tabIDMap[StoreSystem.lable_subtype_weapon_skin_hg] = 106;     -- 手枪
	--log_tree("[HHF]StoreWeaponUI.SetTabMapAndFilterList, tabIDMap = ", StoreWeaponUI.tabIDMap, "[HHF]");

	BP_ARRAY_StoreWeapon_FilterList = {};
	table.insert(BP_ARRAY_StoreWeapon_FilterList, FuncUtil.GetLocalizeResStr(6482));
	table.insert(BP_ARRAY_StoreWeapon_FilterList, FuncUtil.GetLocalizeResStr(6483));
	table.insert(BP_ARRAY_StoreWeapon_FilterList, FuncUtil.GetLocalizeResStr(6484));
	table.insert(BP_ARRAY_StoreWeapon_FilterList, FuncUtil.GetLocalizeResStr(6485));
	table.insert(BP_ARRAY_StoreWeapon_FilterList, FuncUtil.GetLocalizeResStr(6486));
	table.insert(BP_ARRAY_StoreWeapon_FilterList, FuncUtil.GetLocalizeResStr(6487));
	table.insert(BP_ARRAY_StoreWeapon_FilterList, FuncUtil.GetLocalizeResStr(6488));
	--log_tree("[HHF]StoreWeaponUI.SetTabMapAndFilterList, FilterList = ", BP_ARRAY_StoreWeapon_FilterList, "[HHF]");
	BP_StoreWeapon_CurrentFilterID = 1;

	StoreWeaponUI.allGunGenreList = {};
	StoreWeaponUI.allGunGenreList[StoreWeaponUI.tabIDMap[StoreSystem.lable_subtype_weapon_suggest]] = {FuncUtil.GetLocalizeResStr(4462)};     -- 推荐（全部）
	StoreWeaponUI.allGunGenreList[StoreWeaponUI.tabIDMap[StoreSystem.lable_subtype_weapon_skin_ar]] = {FuncUtil.GetLocalizeResStr(4462)};     -- 突击步枪
	StoreWeaponUI.allGunGenreList[StoreWeaponUI.tabIDMap[StoreSystem.lable_subtype_weapon_skin_sr]] = {FuncUtil.GetLocalizeResStr(4462)};     -- 狙击步枪
	StoreWeaponUI.allGunGenreList[StoreWeaponUI.tabIDMap[StoreSystem.lable_subtype_weapon_skin_smg]] = {FuncUtil.GetLocalizeResStr(4462)};    -- 冲锋枪
	StoreWeaponUI.allGunGenreList[StoreWeaponUI.tabIDMap[StoreSystem.lable_subtype_weapon_skin_sog]] = {FuncUtil.GetLocalizeResStr(4462)};    -- 散弹枪
	StoreWeaponUI.allGunGenreList[StoreWeaponUI.tabIDMap[StoreSystem.lable_subtype_weapon_skin_ciw]] = {FuncUtil.GetLocalizeResStr(4462)};    -- 近战武器
	StoreWeaponUI.allGunGenreList[StoreWeaponUI.tabIDMap[StoreSystem.lable_subtype_weapon_skin_cb]] = {FuncUtil.GetLocalizeResStr(4462)};     -- 弩
	StoreWeaponUI.allGunGenreList[StoreWeaponUI.tabIDMap[StoreSystem.lable_subtype_weapon_skin_mg]] = {FuncUtil.GetLocalizeResStr(4462)};     -- 机枪
	StoreWeaponUI.allGunGenreList[StoreWeaponUI.tabIDMap[StoreSystem.lable_subtype_weapon_skin_hg]] = {FuncUtil.GetLocalizeResStr(4462)};     -- 手枪

	local armoryTable = Client.GetTable("ArmoryConfig");
	if armoryTable ~= nil then
		for k, v in pairs(armoryTable) do
			local itemInfo = Client.GetTableData("Item", v.WeaponID);
			if itemInfo and itemInfo.ItemType == 1 then
				local genreList = StoreWeaponUI.allGunGenreList[itemInfo.ItemSubType];
				if genreList == nil then
					genreList = {};
					table.insert(genreList, itemInfo.ArmorySimpleDesc);
					StoreWeaponUI.allGunGenreList[itemInfo.ItemSubType] = genreList;
					log("[HHF]StoreWeaponUI.SetTabMapAndFilterList, why exist type = ".. tostring(itemInfo.ItemSubType));
				else
					table.insert(genreList, itemInfo.ArmorySimpleDesc);
				end

				local allList = StoreWeaponUI.allGunGenreList[StoreWeaponUI.tabIDMap[StoreSystem.lable_subtype_weapon_suggest]];
				table.insert(allList, itemInfo.ArmorySimpleDesc);
			end
		end
	end
	--log_tree("[HHF]StoreWeaponUI.SetTabMapAndFilterList, GunGenreList = ", StoreWeaponUI.allGunGenreList, "[HHF]");

	StoreWeaponUI.genreIndexMap = {};
	StoreWeaponUI.genreIndexMap[StoreWeaponUI.tabIDMap[StoreSystem.lable_subtype_weapon_suggest]] = 1;     -- 推荐（全部）
	StoreWeaponUI.genreIndexMap[StoreWeaponUI.tabIDMap[StoreSystem.lable_subtype_weapon_skin_ar]] = 1;     -- 突击步枪
	StoreWeaponUI.genreIndexMap[StoreWeaponUI.tabIDMap[StoreSystem.lable_subtype_weapon_skin_sr]] = 1;     -- 狙击步枪
	StoreWeaponUI.genreIndexMap[StoreWeaponUI.tabIDMap[StoreSystem.lable_subtype_weapon_skin_smg]] = 1;    -- 冲锋枪
	StoreWeaponUI.genreIndexMap[StoreWeaponUI.tabIDMap[StoreSystem.lable_subtype_weapon_skin_sog]] = 1;    -- 散弹枪
	StoreWeaponUI.genreIndexMap[StoreWeaponUI.tabIDMap[StoreSystem.lable_subtype_weapon_skin_ciw]] = 1;    -- 近战武器
	StoreWeaponUI.genreIndexMap[StoreWeaponUI.tabIDMap[StoreSystem.lable_subtype_weapon_skin_cb]] = 1;     -- 弩
	StoreWeaponUI.genreIndexMap[StoreWeaponUI.tabIDMap[StoreSystem.lable_subtype_weapon_skin_mg]] = 1;     -- 机枪
	StoreWeaponUI.genreIndexMap[StoreWeaponUI.tabIDMap[StoreSystem.lable_subtype_weapon_skin_hg]] = 1;     -- 手枪
end

function StoreWeaponUI.OnDataReady(eventType, eventID, param)
	--log_tree("[HHF]StoreWeaponUI.OnDataReady, param = ", param, "[HHF]");
	if param ~= nil and param.tab_type == StoreSystem.store_tab and param.tab_id == StoreWeaponUI.tab_id then
		StoreWeaponUI.SetData(param.data);
		StoreWeaponUI.UpdateListHead();
		StoreWeaponUI.SetGenreListSelf();
		StoreWeaponUI.SwitchItemBySubTab();
		StoreWeaponUI.FilterItemByGenre();
		StoreWeaponUI.UpdateEquipedAndSelectedState()
		LuaClassObj.HandleDynamicCreation(bp_store_weapon);
		LuaClassObj.HandleUIMessageNoFetch(bp_store_weapon, "SetData");
		LuaClassObj.HandleUIMessageNoFetch(bp_store_weapon, "ReloadItemList");
		LuaClassObj.HandleUIMessageNoFetch(bp_store_weapon, "ShowUI");
		UIManager.Show(eUIType.eStoreWeaponPage);

		if StoreWeaponUI.jump_info ~= nil then
			BP_StoreWeapon_CurrentClickItemID = StoreWeaponUI.jump_info.itemId;
			StoreWeaponUI.SelectItem(StoreWeaponUI.jump_info.itemId);
			LuaClassObj.HandleUIMessageNoFetch(bp_store_weapon, "JumpToSelect");
			StoreWeaponUI.jump_info = nil;

			BP_StoreWeapon_DisplayType = 0;
			ModelDisplayer.SetShowtype(ModelDisplayer.SHOWTYPE_WEAPON_MODEL);
			LuaClassObj.HandleUIMessageNoFetch(bp_store_weapon, "UpdateDisplayType");
		else
			StoreWeaponUI.ChooseTheFirstOneInDefault();
		end
	else
		log("[HHF]StoreWeaponUI.OnDataReady, param = nil and return.");
		StoreWeaponUI.Hide();
	end
end

function StoreWeaponUI.SetData(info)
	StoreWeaponUI.rawData = info;

	local key = StoreSystem.label_market_index_market_list;
	for k, v in pairs(info[key]) do
		local item = StoreWeaponUI.GenerateStoreWeaponItemData(k, v);
		if item ~= nil then
			if item.item_endTime ~= 0 and item.item_leftTime <= 0 then
				log("[HHF]StoreWeaponUI.SetData, itemID = " .. tostring(item.item_id) .. " has expired.");
			else
				--table.insert(StoreWeaponUI.allDataList, item);
				StoreWeaponUI.allDataList[item.item_shopID] = item;
			end
		end
	end

	local key1 = StoreSystem.label_market_index_banner_list;
	for k1, v1 in pairs(info[key1]) do
		local inList = false;
		for k, v in pairs(StoreWeaponUI.allDataList) do
			if v.item_shopID == v1[StoreSystem.label_item_index_market_id] then
				v.item_recommend = true;
				v.item_cdn = v1[StoreSystem.label_item_index_img_path] or "";

				local rawItemInfo = StoreWeaponUI.rawData[key][v.item_shopID];
				rawItemInfo[StoreSystem.label_item_index_img_path] = v.item_cdn;

				inList = true;
				break;
			end
		end
		if inList == false then
			--log_tree("[HHF]StoreWeaponUI.SetData, why exist in recommend but not in list. data = ", v1, "[HHF]");
		end
	end

	BP_StoreWeapon_CurrentSex = MultipleAvatar.ShowingAvatarSextype;
	store_item_upgrade_system.SetCurrentModele(store_item_upgrade_system.module.weapon)
	log("[HHF]StoreWeaponUI.SetData, current sex = " .. tostring(BP_StoreWeapon_CurrentSex));
	--log_tree("[HHF]StoreWeaponUI.SetData, after dataList = ", StoreWeaponUI.allDataList, "[HHF]");
end

function StoreWeaponUI.GenerateStoreWeaponItemData(k, v)
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
		item.item_cdn = "";
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

		item.BP_ARRAY_StoreWeapon_ItemPrice = {};
		item.BP_ARRAY_StoreWeapon_LowestPrice = {};
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
					table.insert(item.BP_ARRAY_StoreWeapon_ItemPrice, temp);

					if firstPriceType == -1 then
						firstPriceType = value[StoreSystem.label_price_index_price_type];
					end
				end
			end

			item.BP_ARRAY_StoreWeapon_LowestPrice = StoreFuncUtils.CalculateLowestByCurrency(item.BP_ARRAY_StoreWeapon_ItemPrice);
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

		item.item_recommend = false;
		item.item_killBroadcast = false;--Client.GetTableData("WeaponAvatarBattleEffect", item.item_id) ~= nil;

		return item;
	else
		log("[HHF]StoreWeaponUI.GenerateStoreWeaponItemData, Not found itemID = " .. tostring(itemID) .. " in Item table");
		return nil;
	end
end

function StoreWeaponUI.UpdateLeftTime()
	if StoreWeaponUI.bShowing == true then
		local needDelete = {};
		local needUpdate = false;
		for k, v in pairs(BP_ARRAY_StoreWeapon_ShowItemList) do
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
				if v == BP_STRUCT_StoreWeapon_CurrentItemInfo.item_index then
					selected = true;
				end
				StoreWeaponUI.allDataList[BP_ARRAY_StoreWeapon_ShowItemList[v].item_shopID] = nil;
				StoreWeaponUI.tabDataList[BP_ARRAY_StoreWeapon_ShowItemList[v].item_shopID] = nil;
				StoreWeaponUI.genreDataList[BP_ARRAY_StoreWeapon_ShowItemList[v].item_shopID] = nil;
				table.remove(BP_ARRAY_StoreWeapon_ShowItemList, v);
			end
			LuaClassObj.HandleUIMessageNoFetch(bp_store_weapon, "ReloadItemList");
			if selected == true then
				StoreWeaponUI.ChooseTheFirstOneInDefault();
			end
		else
			if needUpdate == true then
				LuaClassObj.HandleUIMessageNoFetch(bp_store_weapon, "UpdateItemList");
			end
		end
	end
end

function StoreWeaponUI.UpdateEquipedAndSelectedState()
	log("[HHF]StoreWeaponUI.UpdateEquipedAndSelectedState");
	for k, v in pairs(BP_ARRAY_StoreWeapon_ShowItemList) do
		v.item_selected = false;
		v.item_equiped = MultipleAvatar.HasEquiped(v.item_id, 0, 0);
	end
end

function StoreWeaponUI.SwitchItemBySubTab()
	log("[HHF]StoreWeaponUI.SwitchItemBySubTab, subTab_id = " .. tostring(StoreWeaponUI.subTab_id) .. ", subTab_name = " .. tostring(StoreWeaponUI.tabIDMap[StoreWeaponUI.subTab_id]));
	StoreWeaponUI.tabDataList = {};
	for k, v in pairs(StoreWeaponUI.allDataList) do
		if StoreWeaponUI.subTab_id == StoreSystem.lable_subtype_weapon_suggest then
			if v.item_recommend == true then
				--table.insert(StoreWeaponUI.tabDataList, v);
				StoreWeaponUI.tabDataList[k] = v;
			end
		else
			if v.item_type == StoreWeaponUI.tabIDMap[StoreWeaponUI.subTab_id] then
				--table.insert(StoreWeaponUI.tabDataList, v);
				StoreWeaponUI.tabDataList[k] = v;
			end
		end
	end
	--log_tree("[HHF]StoreWeaponUI.SwitchItemBySubTab, TabItemList = ", StoreWeaponUI.tabDataList, "[HHF]");
end

function StoreWeaponUI.FilterItemByGenre()
	if BP_StoreWeapon_CurrentGenreID > 0 and BP_StoreWeapon_CurrentGenreID <= #BP_ARRAY_StoreWeapon_GunGenreList then
		local filter = BP_ARRAY_StoreWeapon_GunGenreList[BP_StoreWeapon_CurrentGenreID];
		StoreWeaponUI.genreDataList = {};
		for k, v in pairs(StoreWeaponUI.tabDataList) do
			if filter == FuncUtil.GetLocalizeResStr(6482) then                  -- 全部
				--table.insert(StoreWeaponUI.genreDataList, v);
				StoreWeaponUI.genreDataList[k] = v;
			elseif filter == StoreWeaponUI.GetWeaponGenreByID(v.item_id) then   -- 型号
				--table.insert(StoreWeaponUI.genreDataList, v);
				StoreWeaponUI.genreDataList[k] = v;
			end
		end

		log("[HHF]StoreWeaponUI.FilterItemByGenre, filterIndex = " .. tostring(BP_StoreWeapon_CurrentGenreID) .. ", filterName = " .. tostring(filter));
		StoreWeaponUI.FilterItemByIndex();
	else
		log("[HHF]StoreWeaponUI.FilterItemByGenre, out of bounds, index = " .. tostring(BP_StoreWeapon_CurrentGenreID) ..
			", length = " .. tostring(#BP_ARRAY_StoreWeapon_GunGenreList));
	end
end

function StoreWeaponUI.GetWeaponGenreByID(id)
	local oldID = id;
	local genre = "";
	if id > StoreWeaponUI.weaponSkinID then
		id = math.floor(id / 1000);
		id = id % 1000000;

		local itemInfo = Client.GetTableData("Item", id);
		if itemInfo and itemInfo.ItemType == 1 then
			genre = itemInfo.ArmorySimpleDesc;
		end
	end
	log("[HHF]StoreWeaponUI.GetWeaponGenreByID, id = " .. tostring(oldID) .. ", genre = " .. tostring(genre));
	return genre;
end

function StoreWeaponUI.FilterItemByIndex()
	if BP_StoreWeapon_CurrentFilterID > 0 and
		BP_StoreWeapon_CurrentFilterID <= #BP_ARRAY_StoreWeapon_FilterList then
		BP_ARRAY_StoreWeapon_ShowItemList = {};
		local filter = BP_ARRAY_StoreWeapon_FilterList[BP_StoreWeapon_CurrentFilterID];
		for k, v in pairs(StoreWeaponUI.genreDataList) do
			if filter == FuncUtil.GetLocalizeResStr(6482) then              -- 全部
				table.insert(BP_ARRAY_StoreWeapon_ShowItemList, v);
			elseif filter == FuncUtil.GetLocalizeResStr(6483) then          -- 已拥有
				if v.item_have == true then
					table.insert(BP_ARRAY_StoreWeapon_ShowItemList, v);
				end
			elseif filter == FuncUtil.GetLocalizeResStr(6484) then          -- 未拥有
				if v.item_have == false then
					table.insert(BP_ARRAY_StoreWeapon_ShowItemList, v);
				end
			elseif filter == FuncUtil.GetLocalizeResStr(6485) then          -- 可赠送
				if v.item_gift == 1 then
					table.insert(BP_ARRAY_StoreWeapon_ShowItemList, v);
				end
			elseif filter == FuncUtil.GetLocalizeResStr(6486) then          -- 银碎片价格排序
				table.insert(BP_ARRAY_StoreWeapon_ShowItemList, v);
			elseif filter == FuncUtil.GetLocalizeResStr(6487) then          -- UC价格排序
				table.insert(BP_ARRAY_StoreWeapon_ShowItemList, v);
			elseif filter == FuncUtil.GetLocalizeResStr(6488) then          -- 金币片价格排序
				table.insert(BP_ARRAY_StoreWeapon_ShowItemList, v);
			end
		end

		log("[HHF]StoreWeaponUI.FilterItemByIndex, filterIndex = " .. tostring(BP_StoreWeapon_CurrentFilterID) .. ", filterName = " .. tostring(filter));
		StoreWeaponUI.SortItemListByFilter(filter);
	else
		log("[HHF]StoreWeaponUI.FilterItemByIndex, out of bounds, index = " .. tostring(BP_StoreWeapon_CurrentFilterID) ..
			", length = " .. tostring(#BP_ARRAY_StoreWeapon_FilterList));
	end
	--log_tree("[HHF]StoreWeaponUI.FilterItemByIndex, ShowItemList = ", BP_ARRAY_StoreWeapon_ShowItemList, "[HHF]");
end

function StoreWeaponUI.SortItemListByFilter(filter)
	log("[HHF]StoreWeaponUI.SortItemListByFilter");
	if #BP_ARRAY_StoreWeapon_ShowItemList > 1 then
		if filter == FuncUtil.GetLocalizeResStr(6482) then              -- 全部
			table.sort(BP_ARRAY_StoreWeapon_ShowItemList,
				function(a, b)
					return StoreFuncUtils.DefaultSortAlgorithm(a, b);
				end);
		elseif filter == FuncUtil.GetLocalizeResStr(6483) then          -- 已拥有
			table.sort(BP_ARRAY_StoreWeapon_ShowItemList,
				function(a, b)
					return StoreFuncUtils.DefaultSortAlgorithm(a, b);
				end);
		elseif filter == FuncUtil.GetLocalizeResStr(6484) then          -- 未拥有
			table.sort(BP_ARRAY_StoreWeapon_ShowItemList,
				function(a, b)
					return StoreFuncUtils.DefaultSortAlgorithm(a, b);
				end);
		elseif filter == FuncUtil.GetLocalizeResStr(6485) then          -- 可赠送
			table.sort(BP_ARRAY_StoreWeapon_ShowItemList,
				function(a, b)
					return StoreFuncUtils.DefaultSortAlgorithm(a, b);
				end);
		elseif filter == FuncUtil.GetLocalizeResStr(6486) then          -- 银碎片价格排序
			table.sort(BP_ARRAY_StoreWeapon_ShowItemList,
				function(a, b)
					return StoreFuncUtils.SortPriceListByType(a, b, "BP_ARRAY_StoreWeapon_LowestPrice", StoreSystem.label_price_type_chip);
				end);
		elseif filter == FuncUtil.GetLocalizeResStr(6487) then          -- UC价格排序
			table.sort(BP_ARRAY_StoreWeapon_ShowItemList,
				function(a, b)
					return StoreFuncUtils.SortPriceListByType(a, b, "BP_ARRAY_StoreWeapon_LowestPrice", StoreSystem.label_price_type_uc);
				end);
		elseif filter == FuncUtil.GetLocalizeResStr(6488) then          -- 金币片价格排序
			table.sort(BP_ARRAY_StoreWeapon_ShowItemList,
				function(a, b)
					return StoreFuncUtils.SortPriceListByType(a, b, "BP_ARRAY_StoreWeapon_LowestPrice", StoreSystem.label_price_type_bp);
				end);
		elseif filter == FuncUtil.GetLocalizeResStr(6787) then          -- 金碎片价格排序
			table.sort(BP_ARRAY_StoreClothes_ShowItemList,
				function(a, b)
					return StoreFuncUtils.SortPriceListByType(a, b, "BP_ARRAY_StoreWeapon_LowestPrice", StoreSystem.label_price_type_gold_chip);
				end);
		end
	end
end

function StoreWeaponUI.SelectItem(item_id)
	log("[HHF]StoreWeaponUI.SelectItem, item_id = " .. tostring(item_id));
	local equiped = MultipleAvatar.HasEquiped(item_id, 0, 0);
	log("[HHF]StoreWeaponUI.SelectItem, before click equiped = " .. tostring(equiped));
	store_item_upgrade_system.SetCurrentItemID(store_item_upgrade_system.module.weapon,item_id)
	StoreMainUI.OnSelectedItem(item_id, 0, 0, true);
	equiped = MultipleAvatar.HasEquiped(item_id, 0, 0);
	log("[HHF]StoreWeaponUI.SelectItem,  after click equiped = " .. tostring(equiped));
	--log_tree("BP_ARRAY_StoreWeapon_ShowItemList",BP_ARRAY_StoreWeapon_ShowItemList)
	for k, v in pairs(BP_ARRAY_StoreWeapon_ShowItemList) do
		if v.item_id == item_id then
			v.item_selected = true;
			v.item_equiped = equiped;
			BP_STRUCT_StoreWeapon_CurrentItemInfo.item_index = k;
			BP_STRUCT_StoreWeapon_CurrentItemInfo.item_shopID = v.item_shopID;
			BP_STRUCT_StoreWeapon_CurrentItemInfo.item_id = v.item_id;
			BP_STRUCT_StoreWeapon_CurrentItemInfo.item_name = v.item_name;
			BP_STRUCT_StoreWeapon_CurrentItemInfo.item_desc = v.item_desc;
			BP_STRUCT_StoreWeapon_CurrentItemInfo.item_quality = v.item_quality;
			BP_STRUCT_StoreWeapon_CurrentItemInfo.item_gift = v.item_gift;
			BP_STRUCT_StoreWeapon_CurrentItemInfo.item_have = v.item_have;
			BP_STRUCT_StoreWeapon_CurrentItemInfo.item_killBroadcast = v.item_killBroadcast;
			BP_STRUCT_StoreWeapon_CurrentItemInfo.item_festivalImage = v.item_festivalImage;
			BP_STRUCT_StoreWeapon_CurrentItemInfo.item_collected = v.item_collected;
			BP_STRUCT_StoreWeapon_CurrentItemInfo.item_collected_num = v.item_collected_num;
			BP_STRUCT_StoreWeapon_CurrentItemInfo.item_jump = v.item_jump ~= "" and v.item_jump or tostring(v.item_id);
			BP_STRUCT_StoreWeapon_CurrentItemInfo.BP_ARRAY_StoreWeapon_LowestPrice = StoreFuncUtils.GetTwoValidPriceForShow(v.BP_ARRAY_StoreWeapon_LowestPrice);
			BP_STRUCT_StoreWeapon_CurrentItemInfo.priceNumMax = v.priceNumMax
			
			local key = StoreSystem.label_market_index_market_list;
			StoreWeaponUI.rawItemInfo = StoreWeaponUI.rawData[key][v.item_shopID];
			--log_tree("[HHF]StoreWeaponUI.SelectItem, rawItemInfo = ", StoreWeaponUI.rawItemInfo, "[HHF]");
			local dayLimit = 0;
			local weekLimit = 0;
			local permanentLimit = 0;
			local limitPurchaseKey = StoreSystem.label_item_index_buy_limit;
			local limitPurchaseInfo = StoreWeaponUI.rawItemInfo[limitPurchaseKey];
			if limitPurchaseInfo ~= nil then
				dayLimit = limitPurchaseInfo[StoreSystem.label_buy_limit_type_daily] or 0;
				weekLimit = limitPurchaseInfo[StoreSystem.label_buy_limit_type_week] or 0;
				permanentLimit = limitPurchaseInfo[StoreSystem.label_buy_limit_type_permanent] or 0;
			end
			BP_STRUCT_StoreWeapon_CurrentItemInfo.item_soldOut = StoreFuncUtils.IsSoldOut(v.item_id, dayLimit, weekLimit, permanentLimit);
		else
			v.item_selected = false;
			v.item_equiped = MultipleAvatar.HasEquiped(v.item_id, 0, 0);
		end
	end

	BP_Current_StoreLevelUp_ItemID = BP_STRUCT_StoreWeapon_CurrentItemInfo.item_id	--装备升级展示用的ID

	LuaClassObj.HandleUIMessageNoFetch(bp_store_weapon, "UpdateItemList");
	LuaClassObj.HandleUIMessageNoFetch(bp_store_weapon, "UpdateItemDetailInfo");
	StoreJumpToChestUI.CheckToShow(item_id);
end

function StoreWeaponUI.ChooseTheFirstOneInDefault()
	if BP_ARRAY_StoreWeapon_ShowItemList[1] ~= nil then
		log("[HHF]StoreWeaponUI.ChooseTheFirstOneInDefault");
		BP_StoreWeapon_CurrentClickItemID = BP_ARRAY_StoreWeapon_ShowItemList[1].item_id;
		StoreWeaponUI.SelectItem(BP_StoreWeapon_CurrentClickItemID);
		BP_StoreWeapon_DisplayType = 0;
		ModelDisplayer.SetShowtype(ModelDisplayer.SHOWTYPE_WEAPON_MODEL);
		LuaClassObj.HandleUIMessageNoFetch(bp_store_weapon, "UpdateDisplayType");
	else
		log("[HHF]StoreWeaponUI.ChooseTheFirstOneInDefault, but is empty.");
	end
end

function StoreWeaponUI.UpdateListHead()
	BP_StoreWeapon_IsRecommendTab = StoreWeaponUI.subTab_id == StoreSystem.lable_subtype_weapon_suggest;
	log("[HHF]StoreWeaponUI.UpdateListHead, isRecommend = " .. tostring(BP_StoreWeapon_IsRecommendTab));
	LuaClassObj.HandleUIMessageNoFetch(bp_store_weapon, "UpdateListHead");
end

function StoreWeaponUI.OnItemDataChange(eventType, eventID, vars)
	--log_tree("[HHF]StoreWeaponUI.OnItemDataChange, vars = ", vars, "[HHF]");
	local have = StoreFuncUtils.HasItem(BP_StoreWeapon_CurrentClickItemID, 0, 0);
	if have == true then
		BP_STRUCT_StoreWeapon_CurrentItemInfo.item_have = true;
		local key = BP_STRUCT_StoreWeapon_CurrentItemInfo.item_index;
		local shopID = BP_STRUCT_StoreWeapon_CurrentItemInfo.item_shopID;
		BP_ARRAY_StoreWeapon_ShowItemList[key].item_have = true;
		StoreWeaponUI.genreDataList[shopID].item_have = true;
		StoreWeaponUI.tabDataList[shopID].item_have = true;
		StoreWeaponUI.allDataList[shopID].item_have = true;

		LuaClassObj.HandleUIMessageNoFetch(bp_store_weapon, "UpdateItemList");
		LuaClassObj.HandleUIMessageNoFetch(bp_store_weapon, "UpdateItemDetailInfo");

		local priceInfo = {};
		priceInfo.PriceType1 = BP_STRUCT_StoreWeapon_CurrentItemInfo.BP_ARRAY_StoreWeapon_LowestPrice[1].currency;
		priceInfo.PriceNum1 = BP_STRUCT_StoreWeapon_CurrentItemInfo.BP_ARRAY_StoreWeapon_LowestPrice[1].original;
		priceInfo.DiscountNum1 = BP_STRUCT_StoreWeapon_CurrentItemInfo.BP_ARRAY_StoreWeapon_LowestPrice[1].price;
		priceInfo.PriceType2 = BP_STRUCT_StoreWeapon_CurrentItemInfo.BP_ARRAY_StoreWeapon_LowestPrice[2].currency;
		priceInfo.PriceNum2 = BP_STRUCT_StoreWeapon_CurrentItemInfo.BP_ARRAY_StoreWeapon_LowestPrice[2].original;
		priceInfo.DiscountNum2 = BP_STRUCT_StoreWeapon_CurrentItemInfo.BP_ARRAY_StoreWeapon_LowestPrice[2].price;
		priceInfo.isSoldOut = BP_STRUCT_StoreWeapon_CurrentItemInfo.item_soldOut;
		priceInfo.isHaveItem = BP_STRUCT_StoreWeapon_CurrentItemInfo.item_have;
		priceInfo.priceNumMax = BP_STRUCT_StoreWeapon_CurrentItemInfo.priceNumMax;

		StorePreviewUI.RefreshView(priceInfo);
	end
end

function StoreWeaponUI.OnCollectedResult()
	local item_id = BP_StoreWeapon_CurrentClickItemID;
	local result = StoreSystem.IsCollectedByItemID(item_id);
	log("[HHF]StoreWeaponUI.OnCollectedResult, result = " .. tostring(result));
	if result == true then
		if StoreSystem.global_collection_num[item_id] == nil then
			StoreSystem.global_collection_num[item_id] = 1;
		else
			StoreSystem.global_collection_num[item_id] = StoreSystem.global_collection_num[item_id] + 1;
		end
	else
		StoreSystem.global_collection_num[item_id] = StoreSystem.global_collection_num[item_id] - 1;
	end
	BP_STRUCT_StoreWeapon_CurrentItemInfo.item_collected = result;
	BP_STRUCT_StoreWeapon_CurrentItemInfo.item_collected_num = StoreSystem.global_collection_num[item_id];
	local key = BP_STRUCT_StoreWeapon_CurrentItemInfo.item_index;
	local shopID = BP_STRUCT_StoreWeapon_CurrentItemInfo.item_shopID;
	BP_ARRAY_StoreWeapon_ShowItemList[key].item_collected = result;
	BP_ARRAY_StoreWeapon_ShowItemList[key].item_collected_num = StoreSystem.global_collection_num[item_id];
	StoreWeaponUI.genreDataList[shopID].item_collected = result;
	StoreWeaponUI.genreDataList[shopID].item_collected_num = StoreSystem.global_collection_num[item_id];
	StoreWeaponUI.tabDataList[shopID].item_collected = result;
	StoreWeaponUI.tabDataList[shopID].item_collected_num = StoreSystem.global_collection_num[item_id];
	StoreWeaponUI.allDataList[shopID].item_collected = result;
	StoreWeaponUI.allDataList[shopID].item_collected_num = StoreSystem.global_collection_num[item_id];

	LuaClassObj.HandleUIMessageNoFetch(bp_store_weapon, "UpdateItemDetailInfo");
end

function StoreWeaponUI.Hide()
	log("[HHF]StoreWeaponUI.Hide");
	if StoreWeaponUI.bShowing == true then
		EventSystem:unregistEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_DATA, StoreWeaponUI.OnDataReady);
		EventSystem:unregistEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_COLLECT, StoreWeaponUI.OnCollectedResult);
		EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_DATA_CHANGE, StoreWeaponUI.OnItemDataChange);
		LuaClassObj.HandleUIMessageNoFetch(bp_store_weapon, "HideUI");
		UIManager.Hide(eUIType.eStoreWeaponPage);
		StoreWeaponUI.bShowing = false;

		LobbySceneManager.SetMallWeaponParticalVisiable(false);

		StoreWeaponUI.OnDeadBoxRestore();

		store_item_upgrade_system.SetCurrentModele(store_item_upgrade_system.module.none)	--离开武器页签 把升级预览置为none 
	end
end

function StoreWeaponUI.UIOnlyShow()
	log("[HHF]StoreWeaponUI.UIOnlyShow");
	LobbyCameraManager.SwitchCamera(LobbyCameraManager.store_weapon)
	LuaClassObj.HandleUIMessageNoFetch(bp_store_weapon, "OnlyShowUI");
	StoreJumpToChestUI.CheckToShow(BP_StoreWeapon_CurrentClickItemID);

	--为了预览展示特写
	--StoreMainUI.OnSelectedItem(store_item_upgrade_system.GetSavedLastModelItemID(), 0, 0, true)
	store_item_upgrade_system.SetCurrentModele(store_item_upgrade_system.module.weapon)	--退出了预览 变成武器页签
	LuaClassObj.HandleUIMessageNoFetch(bp_store_weapon, "IsShowLevelUpButton");
end

function StoreWeaponUI.UIOnlyHide()
	log("[HHF]StoreWeaponUI.UIOnlyHide");
	LuaClassObj.HandleUIMessageNoFetch(bp_store_weapon, "OnlyHideUI");

	StoreWeaponUI.OnDeadBoxRestore();
	StoreJumpToChestUI.Hide();
end

function StoreWeaponUI.ShowPreviousOne()
	local currentIndex = BP_STRUCT_StoreWeapon_CurrentItemInfo.item_index;
	local previousIndex = BP_STRUCT_StoreWeapon_CurrentItemInfo.item_index;
	if previousIndex > 1 then
		previousIndex = previousIndex - 1;
	else
		previousIndex = #BP_ARRAY_StoreWeapon_ShowItemList;
	end
	log("[HHF]StoreWeaponUI.ShowPreviousOne, previousIndex = " .. tostring(previousIndex) .. ", currentIndex = " .. tostring(currentIndex));

	BP_StoreWeapon_CurrentClickItemID = BP_ARRAY_StoreWeapon_ShowItemList[previousIndex].item_id;
	store_item_upgrade_system.SetSavedLastModelItemID(BP_StoreWeapon_CurrentClickItemID)
	StoreWeaponUI.SelectItem(BP_StoreWeapon_CurrentClickItemID);

	local itemInfo = {};
	itemInfo.item_id = BP_STRUCT_StoreWeapon_CurrentItemInfo.item_id;
	itemInfo.item_gift = BP_STRUCT_StoreWeapon_CurrentItemInfo.item_gift;
	itemInfo.item_killBroadcast = BP_STRUCT_StoreWeapon_CurrentItemInfo.item_killBroadcast;
	itemInfo.item_jump = BP_STRUCT_StoreWeapon_CurrentItemInfo.item_jump;
	itemInfo.saleEndTime = BP_STRUCT_StoreWeapon_CurrentItemInfo.item_saleEndTime;
	itemInfo.item_collected = BP_STRUCT_StoreWeapon_CurrentItemInfo.item_collected;
	itemInfo.item_collected_num = BP_STRUCT_StoreWeapon_CurrentItemInfo.item_collected_num;

	local priceInfo = {};
	priceInfo.PriceType1 = BP_STRUCT_StoreWeapon_CurrentItemInfo.BP_ARRAY_StoreWeapon_LowestPrice[1].currency;
	priceInfo.PriceNum1 = BP_STRUCT_StoreWeapon_CurrentItemInfo.BP_ARRAY_StoreWeapon_LowestPrice[1].original;
	priceInfo.DiscountNum1 = BP_STRUCT_StoreWeapon_CurrentItemInfo.BP_ARRAY_StoreWeapon_LowestPrice[1].price;
	priceInfo.PriceType2 = BP_STRUCT_StoreWeapon_CurrentItemInfo.BP_ARRAY_StoreWeapon_LowestPrice[2].currency;
	priceInfo.PriceNum2 = BP_STRUCT_StoreWeapon_CurrentItemInfo.BP_ARRAY_StoreWeapon_LowestPrice[2].original;
	priceInfo.DiscountNum2 = BP_STRUCT_StoreWeapon_CurrentItemInfo.BP_ARRAY_StoreWeapon_LowestPrice[2].price;
	priceInfo.isSoldOut = BP_STRUCT_StoreWeapon_CurrentItemInfo.item_soldOut;
	priceInfo.isHaveItem = BP_STRUCT_StoreWeapon_CurrentItemInfo.item_have;
	priceInfo.priceNumMax = BP_STRUCT_StoreWeapon_CurrentItemInfo.priceNumMax;

	return itemInfo, priceInfo, EventOnClickPurchaseStoreWeapon, EventOnClickSendStoreWeapon;
end

function StoreWeaponUI.ShowNextOne()
	local currentIndex = BP_STRUCT_StoreWeapon_CurrentItemInfo.item_index;
	local nextIndex = BP_STRUCT_StoreWeapon_CurrentItemInfo.item_index;
	if nextIndex < #BP_ARRAY_StoreWeapon_ShowItemList then
		nextIndex = nextIndex + 1;
	else
		nextIndex = 1;
	end
	log("[HHF]StoreWeaponUI.ShowPreviousOne, currentIndex = " .. tostring(currentIndex) .. ", nextIndex = " .. tostring(nextIndex));

	BP_StoreWeapon_CurrentClickItemID = BP_ARRAY_StoreWeapon_ShowItemList[nextIndex].item_id;
	store_item_upgrade_system.SetSavedLastModelItemID(BP_StoreWeapon_CurrentClickItemID)
	StoreWeaponUI.SelectItem(BP_StoreWeapon_CurrentClickItemID);

	local itemInfo = {};
	itemInfo.item_id = BP_STRUCT_StoreWeapon_CurrentItemInfo.item_id;
	itemInfo.item_gift = BP_STRUCT_StoreWeapon_CurrentItemInfo.item_gift;
	itemInfo.item_killBroadcast = BP_STRUCT_StoreWeapon_CurrentItemInfo.item_killBroadcast;
	itemInfo.item_jump = BP_STRUCT_StoreWeapon_CurrentItemInfo.item_jump;
	itemInfo.saleEndTime = BP_STRUCT_StoreWeapon_CurrentItemInfo.item_saleEndTime;
	itemInfo.item_collected = BP_STRUCT_StoreWeapon_CurrentItemInfo.item_collected;
	itemInfo.item_collected_num = BP_STRUCT_StoreWeapon_CurrentItemInfo.item_collected_num;

	local priceInfo = {};
	priceInfo.PriceType1 = BP_STRUCT_StoreWeapon_CurrentItemInfo.BP_ARRAY_StoreWeapon_LowestPrice[1].currency;
	priceInfo.PriceNum1 = BP_STRUCT_StoreWeapon_CurrentItemInfo.BP_ARRAY_StoreWeapon_LowestPrice[1].original;
	priceInfo.DiscountNum1 = BP_STRUCT_StoreWeapon_CurrentItemInfo.BP_ARRAY_StoreWeapon_LowestPrice[1].price;
	priceInfo.PriceType2 = BP_STRUCT_StoreWeapon_CurrentItemInfo.BP_ARRAY_StoreWeapon_LowestPrice[2].currency;
	priceInfo.PriceNum2 = BP_STRUCT_StoreWeapon_CurrentItemInfo.BP_ARRAY_StoreWeapon_LowestPrice[2].original;
	priceInfo.DiscountNum2 = BP_STRUCT_StoreWeapon_CurrentItemInfo.BP_ARRAY_StoreWeapon_LowestPrice[2].price;
	priceInfo.isSoldOut = BP_STRUCT_StoreWeapon_CurrentItemInfo.item_soldOut;
	priceInfo.isHaveItem = BP_STRUCT_StoreWeapon_CurrentItemInfo.item_have;
	priceInfo.priceNumMax = BP_STRUCT_StoreWeapon_CurrentItemInfo.priceNumMax;

	return itemInfo, priceInfo, EventOnClickPurchaseStoreWeapon, EventOnClickSendStoreWeapon;
end

function EventCloseStoreWeaponUI()
	log("[HHF]EventCloseStoreWeaponUI");
	StoreWeaponUI.Hide();
end

function EventFilterStoreWeaponItemByGenre()
	log("[HHF]EventFilterStoreWeaponItemByGenre");
	GemReportUtils.ReportBtnClickEvent(GemReportUtils.SubEventName_WeaponFilterType, StoreWeaponUI.subTab_id*100+BP_StoreWeapon_CurrentGenreID)
	StoreWeaponUI.genreIndexMap[StoreWeaponUI.tabIDMap[StoreWeaponUI.subTab_id]] = BP_StoreWeapon_CurrentGenreID;
	StoreWeaponUI.FilterItemByGenre();
	LuaClassObj.HandleUIMessageNoFetch(bp_store_weapon, "ReloadItemList");
end

function EventFilterStoreWeaponItemByIndex()
	log("[HHF]EventFilterStoreWeaponItemByIndex");
	GemReportUtils.ReportBtnClickEvent(GemReportUtils.SubEventName_WeaponFilterIndex, BP_StoreWeapon_CurrentFilterID)
	StoreWeaponUI.FilterItemByIndex();
	LuaClassObj.HandleUIMessageNoFetch(bp_store_weapon, "ReloadItemList");
end

function EventOnClickStoreWeaponItem()
	log("[HHF]EventOnClickStoreWeaponItem, item_id = " .. tostring(BP_StoreWeapon_CurrentClickItemID));
	if BP_StoreWeapon_CurrentClickItemID ~= BP_STRUCT_StoreWeapon_CurrentItemInfo.item_id then
		StoreWeaponUI.OnDeadBoxRestore();
		StoreWeaponUI.SelectItem(BP_StoreWeapon_CurrentClickItemID);
	end
	StoreWeaponUI.CheckToUpdateNewTag(BP_StoreWeapon_CurrentClickItemID);
	--StoreJumpToChestUI.CheckToShow(BP_StoreWeapon_CurrentClickItemID);
end

function StoreWeaponUI.CheckToUpdateNewTag(item_id)
	for k, v in pairs(BP_ARRAY_StoreWeapon_ShowItemList) do
		if v.item_id == item_id then
			if v.item_new == true then
				log("StoreWeaponUI.CheckToUpdateNewTag")
				local itemInfo = Client.GetTableData("Item", v.item_id);
				if itemInfo ~= nil then
					StoreSystem.CheckRecordNewTag(v.item_shopID);
					local showNew, showSpecialIcon = StoreFuncUtils.GetItemRightTopTagsQueue(
							false,
							itemInfo.SpecialIcon ~= "");
					v.item_new = showNew;
					v.item_showSpecialIcon = showSpecialIcon;
					LuaClassObj.HandleUIMessageNoFetch(bp_store_weapon, "UpdateItemList");
				end
			end
		end
	end
end

function EventOnClickChangeStoreWeaponSex()
	log("[HHF]EventOnClickStoreWeaponItem, before click sex = " .. tostring(BP_StoreWeapon_CurrentSex));
	MultipleAvatar.SwitchSex();
	BP_StoreWeapon_CurrentSex = MultipleAvatar.ShowingAvatarSextype;
	log("[HHF]EventOnClickStoreWeaponItem,  after click sex = " .. tostring(BP_StoreWeapon_CurrentSex));
	LuaClassObj.HandleUIMessageNoFetch(bp_store_weapon, "UpdateShowSex");
end

function EventOnClickChangeStoreWeaponDisplayType()
	log("[HHF]EventOnClickChangeStoreWeaponDisplayType, before DisplayType = " .. tostring(BP_StoreWeapon_DisplayType));
	if BP_StoreWeapon_DisplayType == 0 then
		BP_StoreWeapon_DisplayType = 1;
		ModelDisplayer.SetShowtype(ModelDisplayer.SHOWTYPE_AVATAR);
	else
		BP_StoreWeapon_DisplayType = 0;
		ModelDisplayer.SetShowtype(ModelDisplayer.SHOWTYPE_WEAPON_MODEL);
	end
	log("[HHF]EventOnClickChangeStoreWeaponDisplayType,  after DisplayType = " .. tostring(BP_StoreWeapon_DisplayType));
	LuaClassObj.HandleUIMessageNoFetch(bp_store_weapon, "UpdateDisplayType");
end

function EventOnClickPurchaseStoreWeapon()
	local shopInfo = StoreFuncUtils.ConvertToShopInfo(StoreWeaponUI.rawItemInfo, StoreWeaponUI.tab_id, StoreWeaponUI.subTab_id);
	--log_tree("[HHF]EventOnClickPurchaseStoreWeapon, ShopInfo = ", shopInfo, "[HHF]");
	StoreFuncUtils.PurchaseItem(shopInfo);
end

function EventOnClickSendStoreWeapon()
	local shopInfo = StoreFuncUtils.ConvertToShopInfo(StoreWeaponUI.rawItemInfo, StoreWeaponUI.tab_id, StoreWeaponUI.subTab_id);
	--log_tree("[HHF]EventOnClickSendStoreWeapon, shopInfo = ", shopInfo, "[HHF]");
	StoreFuncUtils.SendGift(shopInfo);
end

function EventOnClickStoreWeaponFullScreen()
	log("[HHF]EventOnClickStoreWeaponFullScreen");
	StoreWeaponUI.SwitchToFullScreen();
	GemReportUtils.ReportBtnClickEvent(GemReportUtils.SubEventName_WeaponPreview)
end

function StoreWeaponUI.SwitchToFullScreen()
	log("[HHF]StoreWeaponUI.SwitchToFullScreen");
	local itemInfo = {};
	itemInfo.item_id = BP_STRUCT_StoreWeapon_CurrentItemInfo.item_id;
	itemInfo.item_gift = BP_STRUCT_StoreWeapon_CurrentItemInfo.item_gift;
	itemInfo.item_killBroadcast = BP_STRUCT_StoreWeapon_CurrentItemInfo.item_killBroadcast;
	itemInfo.item_jump = BP_STRUCT_StoreWeapon_CurrentItemInfo.item_jump;
	itemInfo.saleEndTime = BP_STRUCT_StoreWeapon_CurrentItemInfo.item_saleEndTime;
	itemInfo.item_collected = BP_STRUCT_StoreWeapon_CurrentItemInfo.item_collected;
	itemInfo.item_collected_num = BP_STRUCT_StoreWeapon_CurrentItemInfo.item_collected_num;

	local priceInfo = {};
	priceInfo.PriceType1 = BP_STRUCT_StoreWeapon_CurrentItemInfo.BP_ARRAY_StoreWeapon_LowestPrice[1].currency;
	priceInfo.PriceNum1 = BP_STRUCT_StoreWeapon_CurrentItemInfo.BP_ARRAY_StoreWeapon_LowestPrice[1].original;
	priceInfo.DiscountNum1 = BP_STRUCT_StoreWeapon_CurrentItemInfo.BP_ARRAY_StoreWeapon_LowestPrice[1].price;
	priceInfo.PriceType2 = BP_STRUCT_StoreWeapon_CurrentItemInfo.BP_ARRAY_StoreWeapon_LowestPrice[2].currency;
	priceInfo.PriceNum2 = BP_STRUCT_StoreWeapon_CurrentItemInfo.BP_ARRAY_StoreWeapon_LowestPrice[2].original;
	priceInfo.DiscountNum2 = BP_STRUCT_StoreWeapon_CurrentItemInfo.BP_ARRAY_StoreWeapon_LowestPrice[2].price;
	priceInfo.isSoldOut = BP_STRUCT_StoreWeapon_CurrentItemInfo.item_soldOut;
	priceInfo.isHaveItem = BP_STRUCT_StoreWeapon_CurrentItemInfo.item_have;
	priceInfo.priceNumMax = BP_STRUCT_StoreWeapon_CurrentItemInfo.priceNumMax;
	
	StorePreviewUI.Show(itemInfo,
		priceInfo,
		EventOnClickPurchaseStoreWeapon,
		EventOnClickSendStoreWeapon,
		StoreWeaponUI.ShowPreviousOne,
		StoreWeaponUI.ShowNextOne);
end

function EventOnClickStoreWeaponResetRotation()
	log("[HHF]EventOnClickStoreWeaponResetRotation");
	ModelDisplayer.Display(BP_StoreWeapon_CurrentClickItemID, 0, 0, true);
end

function EventOnClickStoreWeaponDeadBox()
	log("[HHF]EventOnClickStoreWeaponDeadBox, deadBoxTimer = " .. tostring(StoreWeaponUI.deadBoxTimer) .. ", path = " .. tostring(BP_StoreWeapon_CurrentDeadboxPath));

	if StoreWeaponUI.deadBoxTimer == nil then
		StoreWeaponUI.deadBoxHandler = SceneExtraModel.Create(BP_StoreWeapon_CurrentDeadboxPath);
		if StoreWeaponUI.deadBoxHandler ~= nil then
			StoreWeaponUI.deadBoxHandler:SetPosition(-70, -434, -14438);

			ModelDisplayer.Hide();
			StoreWeaponUI.oldDisplayType = BP_StoreWeapon_DisplayType;
			BP_StoreWeapon_DisplayType = 2;

			StoreWeaponUI.deadBoxTimer = Timer.InsertTimer(3, StoreWeaponUI.OnDeadBoxRestore, false);
		else
			log("[HHF]EventOnClickStoreWeaponDeadBox, SceneExtraModel.Create failed.");
		end
	end
end

function StoreWeaponUI.OnDeadBoxRestore()
	log("[HHF]StoreWeaponUI.OnDeadBoxRestore, deadBoxTimer = " .. tostring(StoreWeaponUI.deadBoxTimer));
	if StoreWeaponUI.deadBoxTimer ~= nil then
		Timer.RemoveTimer(StoreWeaponUI.deadBoxTimer);
		StoreWeaponUI.deadBoxTimer = nil;

		if StoreWeaponUI.deadBoxHandler ~= nil then
			StoreWeaponUI.deadBoxHandler:Destroy();
		end
		ModelDisplayer.Show();
		BP_StoreWeapon_DisplayType = StoreWeaponUI.oldDisplayType;
		LuaClassObj.HandleUIMessageNoFetch(bp_store_weapon, "HideDeadBox");
	end
end

function EventOnClickCollectWeapon()
	log("[HHF]EventOnClickCollectWeapon");
	if UIUtil.CanClickNow(ClickFrequencyLimit.StoreCollectionBtn) == false then
		return;
	end

	if BP_STRUCT_StoreWeapon_CurrentItemInfo.item_collected then
		StoreSystem.cancel_market_collect_by_item_req(BP_StoreWeapon_CurrentClickItemID);
	else
		StoreSystem.add_market_collect_by_item_req(BP_StoreWeapon_CurrentClickItemID, StoreSystem.market_collect_source_market);
	end
end
