-- 新版商城兑换页签UI
StorePropUI = StorePropUI or
{
	TabId = 0;
	SubId = 0;
	jumpInfo = nil;
	itemMap = {};
}

--兑换数据
BP_STRUCT_StoreProp_ItemInfo =
{
	nIndex = 0,		--数组下标
	marketId = 0,	--商品ID
	itemId = 0,		--道具id
	itemName = "",		--名称
	itemQuality = 0,	--品质
	itemDes = "",		--描述
	storeDetailImage = "",	-- 名字背景
	bNew = false,			-- New标志
	bHot = false,			-- Hot标志
	bVip = false,			-- 会员标志
	bShowDiscount = false,	-- 显示折扣标志
	Time = "",				-- 物品时间字符串标志
	FestivalIconUrl = "",	-- 节日标志Url
	Discount_f = 0.0,		-- 折扣
	bRateUp = false,		-- 是否概率上升
	RateUpEndTime = 0,		-- 概率上升结束时间
	RateUpRate_f = 0.0,		-- 概率上升量
	isEnableCoupon = false,	-- 是否可使用折扣券
	bEquip = false,			-- 是否已穿上
	ExpressionId = 0,	--表情id
	priceType = 0,      --价格类型
	priceIcon = "",		--价格图标
	priceNum = 0,		--价格数量
	originalPrice = 0,	--原价
	priceNumMax = 0,	--价格数量上限
	bSelected = false,	--是否选中
	limitBuyType = 1,	--限购类型
	limitBuyNum = 1,	--限购数量
	hasBuyNum = 0,	--已购买次数
	canSendGift = 0,	--是否可赠送
	isSoldOut = false, 	-- 是否售罄
	endTime = 0,		--下架时间
	needShowEndTime = false,	--是否需要显示下架时间
	needShowEndTimeIcon = false,	--是否需要显示下架时间ICON
	buyCount = 0,			--显示数量
	isProssessed = false,	--已拥有
	showSpecialIcon = false, --是否显示特殊图标
	saleEndTime = 0,		--下架时间 显示用select_item
	jumpInfo = "0",			--跳转字段
	item_collected = false,
	item_collected_num = 0,
	--endTimeUtc = 0,		--下架时间UTC(仅lua用)
	--itemSubType = 0,		--类型(仅lua用)
	--itemSort = 0,		--排序值(仅lua用
	--itemStartTime = 0,	--上架时间
	-- rateList = {},	-- 掉落品质概率（只在lua用，无需生成结构）
	--discountForShow = "", --仅用作显示的折扣
}

BP_ARRAY_StoreProp_ItemInfo_List =
{
	BP_STRUCT_StoreProp_ItemInfo = _G.BP_STRUCT_StoreProp_ItemInfo;
}

--当前选择下标
BP_StoreProp_Select_Index = 0;
--是否为礼包
BP_StoreProp_Is_Chest = false;

--注册Widget
function bp_store_prop_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_store_prop,
        {{Path="/Game/UMG/UI_Logic/Store/Store/StorePropLogicUI_BP.StorePropLogicUI_BP_C", Container="Default", ZOrder=0}},
        {"Lobby"},
        false,
		false,
        true
    );
end


--更新数据
function StorePropUI.UpdateData()
	local pageData = StoreSystem.store_data[StoreSystem.Page_ID_Item];
	if pageData == nil then
		log("StorePropUI.UpdateData pageData == nil")
		StoreSystem.GetTabData(StoreSystem.store_tab, StoreSystem.Page_ID_Item);
		return
	end
	--log_tree("StorePropUI.OnPageInfo pageData = ", pageData)
	local itemList = pageData[3];
	if itemList == nil then
		return
	end
	--log_tree("StorePropUI.OnPageInfo itemList = ", itemList)

	BP_ARRAY_StoreProp_ItemInfo_List = {};
	StorePropUI.itemMap = {};
	local i = 0
	local icon_silver = Client.GetTableData("Item", 1001).ItemSmallIcon
	local icon_uc = Client.GetTableData("Item", 1006).ItemSmallIcon
	local icon_gold = Client.GetTableData("Item", 1000).ItemSmallIcon
	local icon_goldChip = Client.GetTableData("Item", 1104).ItemSmallIcon
	local serverTime = FuncUtil.GetServerTimeInSec();

	for k,v in pairs(itemList) do
		local item = {}
		local itemId = StoreSystem.label_item_index_id
		local cfg = Client.GetTableData("Item", v[itemId]);
		if cfg == nil then
			return
		end
		item.nIndex = i
		item.marketId = v[StoreSystem.label_item_index_market_id];
		item.itemId = v[itemId]

		--item.bNew = v[StoreSystem.label_item_index_show_new] == 1

		item.Time = ""
		item.FestivalIconUrl = cfg.SpecialIcon;
		item.Discount_f = v[StoreSystem.label_item_index_discount] or 0;
		item.bRateUp = false
		item.RateUpEndTime = 0
		item.RateUpRate_f = 0
		item.isEnableCoupon = false
		item.itemName = cfg.ItemName;
		item.itemSubType = cfg.ItemSubType
		item.itemQuality = cfg.ItemQuality;
		item.storeDetailImage = cfg.StoreDetailImage;
		item.itemDes = cfg.ItemDesc;
		item.canSendGift = v[StoreSystem.label_item_index_can_gift];
		item.rateList = v[StoreSystem.label_item_index_rate];
		item.rateType = v[StoreSystem.label_item_index_show_rate_type];
		item.itemSort = v[StoreSystem.label_item_index_rank];
		item.itemStartTime = v[StoreSystem.label_item_index_start_time];
		item.endTimeUtc = v[StoreSystem.label_item_index_time_limit] or 0;
		item.buyCount = v[StoreSystem.label_item_index_count] or 0;
		item.item_collected = StoreSystem.IsCollectedByItemID(item.itemId);
		item.item_collected_num = StoreSystem.global_collection_num[item.itemId] or 0;

		local discount = v[StoreSystem.label_item_index_discount];
		if discount ~= nil and discount ~= 0 then
			item.discountForShow = tostring(discount) .. "%";
		else
			item.discountForShow = "";
		end

		-- 若跳转地址不为空则是URL 若跳转地址为空串则是物品ID
		if v[StoreSystem.label_item_index_skip_path] and v[StoreSystem.label_item_index_skip_path] ~= "" then
			item.jumpInfo = tostring(v[StoreSystem.label_item_index_skip_path])
		else
			item.jumpInfo = tostring(v[StoreSystem.label_item_index_id])
		end

		-- 礼包物品已拥有字段设置再请求礼包信息之后会覆盖
		-- 头像框
		if cfg.ItemType == 20 then
			item.isProssessed = StoreFuncUtils.HasAvatarFrame(v[StoreSystem.label_item_index_id])
		elseif cfg.ItemType == 200 then
			item.isProssessed = StoreFuncUtils.HasHeadPortrait(v[StoreSystem.label_item_index_id])
		elseif StoreFuncUtils.IsPetItemID(item.itemId) then
			local PetSystem = require("client.slua.logic.pet.logic_pet");
			item.isProssessed = PetSystem.HasPet(item.itemId);
		else
			log(cfg.ItemName)
			item.isProssessed = false;
		end

		item.discount_for_sort = v[StoreSystem.label_item_index_discount] or 0;
		local showDiscount, showHot, showVip = StoreFuncUtils.GetItemLeftTopTagsQueue(
				item.Discount_f ~= 0,
				StoreFuncUtils.CheckIsHot(v) == true,
				v[StoreSystem.label_item_index_vip] == 1);
		if showDiscount == false then
			item.Discount_f = 0.0
		end
		item.bHot = showHot;
		item.bVip = showVip;

		local showNew, showSpecialIcon = StoreFuncUtils.GetItemRightTopTagsQueue(
				StoreFuncUtils.CheckIsNew(v) == true,
				cfg.SpecialIcon ~= "");
		item.bNew = showNew;
		item.showSpecialIcon = showSpecialIcon;

		if item.buyCount == 1 then-- 1不显示
			item.buyCount = 0;
		end
		if item.endTimeUtc ~= 0 then
			item.endTime = item.endTimeUtc - serverTime;
		else
			item.endTime = 0;
		end

		if cfg.itemType == 18 then --单条快捷语音
			local ActorVoiceSystem = require("client.slua.logic.actor_voice.logic_actor_voice")
			if ActorVoiceSystem.CheckIsVoiceUnLock(cfg.itemSubType) then
				item.isProssessed = true
			end
		elseif cfg.itemType == 19 then --快捷语音包
			local ActorVoiceSystem = require("client.slua.logic.actor_voice.logic_actor_voice")
            if ActorVoiceSystem.CheckIsActorValidByItemID(item.itemId) then
                item.isProssessed = true
            end
		end

		--if v[StoreSystem.label_item_index_show_time_limit] ~= nil and v[StoreSystem.label_item_index_show_time_limit] == 1 then
		--	item.needShowEndTime = true;
		--else
		--	item.needShowEndTime = false;
		--end

		item.needShowEndTime = StoreFuncUtils.CheckNeedShowSaleEndTime(v);
		item.needShowEndTimeIcon = v[StoreSystem.label_item_index_show_time_limit] == 1;

		if item.needShowEndTimeIcon == true then
			item.saleEndTime = item.endTimeUtc;
		else
			item.saleEndTime = 0;
		end

		--兑换货币
		local priceInfo = StoreFuncUtils.GetExchangeMoneyInfo(v[StoreSystem.label_item_index_price_list])
		if priceInfo ~= nil then
			item.priceType = priceInfo.type
			if priceInfo.type == 1 then
				--银碎片
				item.priceIcon = icon_silver
			elseif priceInfo.type == 0 then
				item.priceIcon = icon_gold;
			elseif priceInfo.type == 103 then
				item.priceIcon = icon_goldChip;
			else
			--uc
				item.priceIcon = icon_uc
			end
			if priceInfo.discount ~= nil and priceInfo.discount ~= 0 then-- 有折扣价
				item.priceNum = priceInfo.discount;
				item.originalPrice = priceInfo.num;

				if StoreFuncUtils.CheckIsChest(item.itemId) and
					StoreSystem.chest_info[item.marketId] ~= nil and
					StoreSystem.chest_info[item.marketId].totalDerateNum ~= nil then
					item.priceNum = item.priceNum - StoreSystem.chest_info[item.marketId].totalDerateNum;
				end
			else
				item.priceNum = priceInfo.num;
				item.originalPrice = 0;

				if StoreFuncUtils.CheckIsChest(item.itemId) and
					StoreSystem.chest_info[item.marketId] ~= nil and
					StoreSystem.chest_info[item.marketId].totalDerateNum ~= nil then
					item.originalPrice = item.priceNum;
					item.priceNum = item.priceNum - StoreSystem.chest_info[item.marketId].totalDerateNum;
				end
			end
		else
			log("bp_store_prop StorePropUI.UpdateData priceInfo = nil");
		end
		item.priceNumMax = 0--StoreFuncUtils.GetFirstPriceNumMax(v[StoreSystem.label_item_index_price_list])
		item.ExpressionId = v[StoreSystem.label_item_index_expression_id] or 0
		--item.bSelected = BP_StoreProp_Select_Index == i
		item.bEquip = MultipleAvatar.HasEquiped(v[itemId])
		local limitData = v[StoreSystem.label_item_index_buy_limit]
		if limitData then
			for limitType, limitCnt in pairs(limitData) do
				item.limitBuyType = limitType;
				item.limitBuyNum = limitCnt;
				local buyInfo = StoreFuncUtils.GetBuyInfo(item.marketId);
				if StoreSystem.label_buy_limit_type_daily == limitType then --每日限购
					item.hasBuyNum = buyInfo and buyInfo.daily_buy_cnt or 0;
				elseif StoreSystem.label_buy_limit_type_week == limitType then --每周限购
					item.hasBuyNum = buyInfo and buyInfo.week_buy_cnt or 0;
				elseif StoreSystem.label_buy_limit_type_permanent == limitType then --永久限购
					item.hasBuyNum = buyInfo and buyInfo.permanet_buy_cnt or 0;
				end
				break;
			end
			item.isSoldOut = StoreFuncUtils.IsSoldOut(item.marketId, limitData[StoreSystem.label_buy_limit_type_daily],
																	limitData[StoreSystem.label_buy_limit_type_week],
																	limitData[StoreSystem.label_buy_limit_type_permanent]);
		end

		if item.endTimeUtc ~= 0 and item.endTime <= 0 then
			--已过期
		else
			StorePropUI.itemMap[item.marketId] = v;
			i = i + 1;
			table.insert(BP_ARRAY_StoreProp_ItemInfo_List, item);
		end
	end


	--排序
	table.sort(BP_ARRAY_StoreProp_ItemInfo_List, function(left, right)
		if left.itemSort ~= right.itemSort then
			return left.itemSort > right.itemSort;
		else
			--if left.bNew == true and right.bNew == false then
			--	return true
			--elseif left.bNew == false and right.bNew == true then
			--	return false
			--else
				if left.itemStartTime ~= right.itemStartTime then
					return left.itemStartTime > right.itemStartTime;
				else
					if left.discount_for_sort ~= right.discount_for_sort then
						return left.discount_for_sort > right.discount_for_sort
					else
						if left.bHot == true and right.bHot == false then
							return true
						elseif left.bHot == false and right.bHot == true then
							return false
						else
							if left.itemQuality ~= right.itemQuality then
								return left.itemQuality > right.itemQuality;
							else
								if left.marketId ~= right.marketId then
									return left.marketId > right.marketId;
								else
									if left.nIndex ~= right.nIndex then
										return left.nIndex < right.nIndex;
									else
										return false;
									end
								end
							end
						end
					end
				end
			--end
		end
	end)

	for i,item in ipairs(BP_ARRAY_StoreProp_ItemInfo_List) do
		item.bSelected = (BP_StoreProp_Select_Index + 1) == i
	end

	local curSelectItem = StorePropUI.GetCurSelectItem();
	if curSelectItem ~= nil then
		BP_StoreProp_Is_Chest = StoreFuncUtils.CheckIsChest(curSelectItem.itemId);
	end
end

-- 显示
function StorePropUI.Show(tabId, subTabId, jumpInfo)
	if UIManager.GetUI(eUIType.eStorePropPage) then
		return
	end
	StorePropUI.jumpInfo = jumpInfo;
	ModelDisplayer.Hide();
	log("StorePropUI.Show")
	BP_StoreProp_Select_Index = 0;
	LuaClassObj.HandleDynamicCreation(bp_store_prop);
	LuaClassObj.HandleUIMessageNoFetch(bp_store_prop, "UIShow");
	UIManager.Show(eUIType.eStorePropPage);
	if GlobalData.IsJapanOrKorea() then
		UIManager.Show(eUIType.eSupplyMainUI);
	end

	EventSystem:registEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_DATA, StorePropUI.OnPageInfo);
	EventSystem:registEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_COLLECT, StorePropUI.OnCollectedResult);
	EventSystem:registEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_BUY_INFO_CHANGE, StorePropUI.OnBuyInfoChange);
	EventSystem:registEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_CHEST_IS_PROSSESSED, StorePropUI.UpdatePriceBtn);
	EventSystem:registEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_HEAD_INFO, StorePropUI.OnHeadPortraitDataUpdate);
	EventSystem:registEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_AVATAR_PORTRAIT, StorePropUI.OnHeadPortraitDataUpdate);
    EventSystem:registEvent(EVENTTYPE_ACTOR_VOICE, EVENTID_ACTOR_VOICE_ACTOR_CHANGE, EventStorePropUI_Click_Item)
    EventSystem:registEvent(EVENTTYPE_ACTOR_VOICE, EVENTID_ACTOR_VOICE_OWN_MESSAGE_CHANGAE, EventStorePropUI_Click_Item)
	StoreSystem.GetTabData(StoreSystem.store_tab, StoreSystem.Page_ID_Item);

	local PropUI = UIUtil.GetWidgetByName("bp_store_prop", "StorePropLogicUI_BP")
	StorePropUI.onClickItemDelegates = {}
	StorePropUI.onCreateItemDelegate = PropUI.Store_Prop_UIBP.ReuseList_C_3.OnCreateItem:Add(function (widget)
		local clickDelegate = widget.StoreItem_BP_01.OnClickItemCallBack:Add(StorePropUI.OnClickItem)
		table.insert(StorePropUI.onClickItemDelegates, {eventDelegate = widget.StoreItem_BP_01.OnClickItemCallBack, funcDelegate = clickDelegate})
	end)
end

function StorePropUI.OnClickItem(itemID)
	local PropUI = UIUtil.GetWidgetByName("bp_store_prop", "StorePropLogicUI_BP")
	local itemData = Client.GetTableData("Item", itemID)

	local ActorVoiceSystem = require("client.slua.logic.actor_voice.logic_actor_voice")

	if itemData.ItemType == 18 then -- 单条快捷语音
		local key = itemData.ItemSubType
		ActorVoiceSystem.PlaySound(key, PropUI)
	else
		ActorVoiceSystem.StopSound()
	end
end

function StorePropUI.UpdatePriceBtn(eventType, eventID, data)
	local curSelectItem = StorePropUI.GetCurSelectItem();
	if curSelectItem ~= nil then
		local id = data[1];
		local isProssessed = data[2]
		log("StorePropUI.UpdatePriceBtn"..tostring(isProssessed))
		if curSelectItem.itemId == id then
			curSelectItem.isProssessed = isProssessed;
			if curSelectItem.originalPrice == 0 then
				curSelectItem.originalPrice = curSelectItem.priceNum;
			end
			curSelectItem.priceNum = data[3];
			LuaClassObj.HandleUIMessageNoFetch(bp_store_prop, "UpdatePriceBtn");
		end
	end
end

-- 关闭
function StorePropUI.Hide()
	if UIManager.GetUI(eUIType.eStorePropPage) == nil then
		return
	end
	log("StorePropUI.Hide")
	EventSystem:unregistEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_DATA, StorePropUI.OnPageInfo);
	EventSystem:unregistEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_COLLECT, StorePropUI.OnCollectedResult);
	EventSystem:unregistEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_BUY_INFO_CHANGE, StorePropUI.OnBuyInfoChange);
	EventSystem:unregistEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_CHEST_IS_PROSSESSED, StorePropUI.UpdatePriceBtn);
	EventSystem:unregistEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_HEAD_INFO, StorePropUI.OnHeadPortraitDataUpdate);
	EventSystem:unregistEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_AVATAR_PORTRAIT, StorePropUI.OnHeadPortraitDataUpdate);
    EventSystem:unregistEvent(EVENTTYPE_ACTOR_VOICE, EVENTID_ACTOR_VOICE_ACTOR_CHANGE, EventStorePropUI_Click_Item)
    EventSystem:unregistEvent(EVENTTYPE_ACTOR_VOICE, EVENTID_ACTOR_VOICE_OWN_MESSAGE_CHANGAE, EventStorePropUI_Click_Item)
	StoreChestUI.Hide();
	LuaClassObj.HandleUIMessageNoFetch(bp_store_prop, "UIHide");
	UIManager.Hide(eUIType.eStorePropPage)
	ModelDisplayer.Show();

	local PropUI = UIUtil.GetWidgetByName("bp_store_prop", "StorePropLogicUI_BP")
	PropUI.Store_Prop_UIBP.ReuseList_C_3.OnCreateItem:Remove(StorePropUI.onCreateItemDelegate)
	StorePropUI.onCreateItemDelegate = nil

	for _, v in pairs(StorePropUI.onClickItemDelegates) do
		v.eventDelegate:Remove(v.funcDelegate)
	end
	StorePropUI.onClickItemDelegates = {}

	local ActorVoiceSystem = require("client.slua.logic.actor_voice.logic_actor_voice")
	ActorVoiceSystem.StopSound()
end


function StorePropUI.UpdateUI()
	LuaClassObj.HandleUIMessageNoFetch(bp_store_prop, "UpdateUI");
	EventStorePropUI_Click_Item();
end

function StorePropUI.Release()
    log("StorePropUI.Release")
end

function StorePropUI.UpdateLeftTime()
	if UIManager.GetUI(eUIType.eStorePropPage) ~= nil then
		local needDelete = {};
		local needUpdate = false;
		local serverTime = FuncUtil.GetServerTimeInSec();
		for k, v in pairs(BP_ARRAY_StoreProp_ItemInfo_List) do
			if v.endTimeUtc ~= nil and v.endTimeUtc ~= 0 and v.endTimeUtc >= serverTime then
				v.endTime = v.endTimeUtc - serverTime;
				if v.endTime > 0 then
					needUpdate = true;
				end
				if v.endTime <= 0 then
					table.insert(needDelete, k);
				end
			else
				v.endTime = 0;
			end
		end

		if #needDelete > 0 then
			-- local selected = false;
			-- for k, v in pairs(needDelete) do
			-- 	if v == BP_StoreProp_Select_Index then
			-- 		selected = true;
			-- 	end
			-- 	--StorePropUI.UpdateUI();
			-- end
			-- if selected == true then
			-- 	BP_StoreProp_Select_Index = 0
			-- end
			log(" StorePropUI.UpdateLeftTime UpdateUI");
			StorePropUI.UpdateData();
			StorePropUI.UpdateUI();
		else
			if needUpdate == true then
				LuaClassObj.HandleUIMessageNoFetch(bp_store_prop, "UpdateVisibleItem");
			end
		end
	end
end

function StorePropUI.SelectedItem(index)
	local item = BP_ARRAY_StoreProp_ItemInfo_List[BP_StoreProp_Select_Index + 1]
	if item == nil then
		return
	end
	ModelDisplayer.Display(item.itemId, 0, 0)
end

-- 点击道具格子按钮
function EventStorePropUI_Click_Item()
	-- StorePropUI.SelectedItem(BP_StoreProp_Select_Index)
	local item = BP_ARRAY_StoreProp_ItemInfo_List[BP_StoreProp_Select_Index + 1];
	if item == nil then
		return
	end
	if item.bNew == true then
		StoreSystem.CheckRecordNewTag(item.marketId);
	end
	StorePropUI.UpdateData()
	LuaClassObj.HandleUIMessageNoFetch(bp_store_prop, "UpdateVisibleItem");
	LuaClassObj.HandleUIMessageNoFetch(bp_store_prop, "UpdateDesc");
	LuaClassObj.HandleUIMessageNoFetch(bp_store_prop, "UpdateSendBtn");
	LuaClassObj.HandleUIMessageNoFetch(bp_store_prop, "UpdateCollectBtn");
end

function StorePropUI.OnPageInfo(eventType, eventID, data)
	log("StorePropUI.OnPageInfo-------")
	if StoreSystem.Page_ID_Item ~= data.tab_id then
		return;
	end
	StorePropUI.TabId = data.tab_id or 0
	StorePropUI.SubId = data.sub_id or 0

	if StorePropUI.jumpInfo then
		StorePropUI.UpdateData()
		BP_StoreProp_Select_Index = StorePropUI.GetItemIndex(StorePropUI.jumpInfo.itemId)
		StorePropUI.UpdateData()
		StorePropUI.UpdateUI()
		-- StorePropUI.SelectedItem(BP_StoreExchange_Select_Index)
		LuaClassObj.HandleUIMessageNoFetch(bp_store_prop, "JumpToSelect")
	else
		StorePropUI.UpdateData()
		StorePropUI.UpdateUI()
	end
end

function StorePropUI.OnHeadPortraitDataUpdate()
	StorePropUI.UpdateData();
	LuaClassObj.HandleUIMessageNoFetch(bp_store_prop, "UpdateVisibleItem");
	LuaClassObj.HandleUIMessageNoFetch(bp_store_prop, "UpdateDesc");
	LuaClassObj.HandleUIMessageNoFetch(bp_store_prop, "UpdateSendBtn");
end

function StorePropUI.OnBuyInfoChange()
	log("StorePropUI.OnBuyInfoChange");
	--StorePropUI.UpdateData();
	--StorePropUI.UpdateUI();
	EventStorePropUI_Click_Item();
end

function StorePropUI.OnCollectedResult()
	log("[HHF]StorePropUI.OnCollectedResult");
	local itemInfo = StorePropUI.GetCurSelectItem();
	local item_id = itemInfo.itemId;
	local result = StoreSystem.IsCollectedByItemID(item_id);
	log("[HHF]StorePropUI.OnCollectedResult, result = " .. tostring(result));
	if result == true then
		if StoreSystem.global_collection_num[item_id] == nil then
			StoreSystem.global_collection_num[item_id] = 1;
		else
			StoreSystem.global_collection_num[item_id] = StoreSystem.global_collection_num[item_id] + 1;
		end
	else
		StoreSystem.global_collection_num[item_id] = StoreSystem.global_collection_num[item_id] - 1;
	end
	itemInfo.item_collected_num = StoreSystem.global_collection_num[item_id];
	itemInfo.item_collected = result;
	LuaClassObj.HandleUIMessageNoFetch(bp_store_prop, "UpdateCollectBtn");
end

function StorePropUI.UIOnlyShow()
	LuaClassObj.HandleUIMessageNoFetch(bp_store_prop, "UIOnlyShow");
	LuaClassObj.HandleUIMessageNoFetch(bp_store_prop, "UpdateDesc");
end

function StorePropUI.UIOnlyHide()
	LuaClassObj.HandleUIMessageNoFetch(bp_store_prop, "UIOnlyHide");
	EventStorePropUIHideChestDetail();
end

function EventStorePropUI_Click_Buy()
	log("EventStorePropUI_Click_Buy")
	local item = BP_ARRAY_StoreProp_ItemInfo_List[BP_StoreProp_Select_Index + 1];
	if item == nil then
		return
	end
	local buyInfo = StorePropUI.itemMap[item.marketId];
	if buyInfo == nil then
		return
	end
	local shopInfo = StoreFuncUtils.ConvertToShopInfo(buyInfo, StoreSystem.Page_ID_Item, 0)
	if shopInfo == nil then
		return
	end
	-- log_tree("EventStorePropUI_Click_Buy", shopInfo)
	if StoreFuncUtils.CheckIsChest(shopInfo.item_id) then
		StoreChestUI.BuyItem(shopInfo)
	else
		StoreFuncUtils.PurchaseItem(shopInfo);
	end
end

function EventStorePropUIOnClickSend()
	log("EventStorePropUIOnClickSend")
	local item = BP_ARRAY_StoreProp_ItemInfo_List[BP_StoreProp_Select_Index + 1];
	if item == nil then
		return
	end
	local buyInfo = StorePropUI.itemMap[item.marketId];
	if buyInfo == nil then
		return
	end
	local ShopInfo = StoreFuncUtils.ConvertToShopInfo(buyInfo, StoreSystem.Page_ID_Item, 0);
	StoreFuncUtils.SendGift(ShopInfo);
end

function StorePropUI.GetItemIndex(itemId)
	for i=1,#BP_ARRAY_StoreProp_ItemInfo_List,1 do
		if BP_ARRAY_StoreProp_ItemInfo_List[i].itemId == itemId then
			return i-1
		end
	end
	return 0
end

function StorePropUI.GetCurSelectItem()
	return BP_ARRAY_StoreProp_ItemInfo_List[BP_StoreProp_Select_Index + 1];
end

function EventStorePropUIShowChestDetail()
	local selectItem = StorePropUI.GetCurSelectItem();
	if selectItem ~= nil then
		StoreChestUI.ShowChestInfo(selectItem);
	end
end

function EventStorePropUIHideChestDetail()
	StoreChestUI.Hide();
end

function EventOnClickCollectProp()
	log("[HHF]EventOnClickCollectProp");
	if UIUtil.CanClickNow(ClickFrequencyLimit.StoreCollectionBtn) == false then
		return;
	end

	local itemInfo = StorePropUI.GetCurSelectItem();
	if itemInfo.item_collected then
		StoreSystem.cancel_market_collect_by_item_req(itemInfo.itemId);
	else
		StoreSystem.add_market_collect_by_item_req(itemInfo.itemId, StoreSystem.market_collect_source_market);
	end
end

-- 跳转接口（框架调用）
function StorePropUI.JumpTo(pageID, jumpInfo)
	StorePropUI.Show(pageID, 0, jumpInfo)
end
