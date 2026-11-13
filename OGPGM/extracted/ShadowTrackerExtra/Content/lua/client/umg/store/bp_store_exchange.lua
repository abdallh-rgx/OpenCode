-- sami 新版商城兑换页签UI
StoreExchangeUI = StoreExchangeUI or
{
	itemMap = {},
	jumpInfo = nil,
}



--兑换数据
BP_STRUCT_StoreExchange_ItemInfo =
{
	nIndex = 0,		--数组下标
	itemId = 0,		--道具id
	shopId = 0,		--商品id
	itemName = "",		--名称
	ItemSubType = 0,		--类型
	itemQuality = 0,	--品质
	itemDes = "",		--描述
    FestivalImage = "",
	bNew = false,			-- New标志
	bHot = false,			-- Hot标志
	Time = "",				-- 物品时间字符串标志
	item_endTime = 0,
	item_leftTime = 0,
	item_showLeftTimeIcon = false,
	FestivalIconUrl = "",	-- 节日标志Url
	showSpecialIcon = false,	--是否显示节日标志
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
	priceNumMax = 0,			--价格数量上限
	originalPrice = 0,		--原价
	bCanSendGift = false,	--是否可以赠送
	bSelected = false,	--是否选中
    needShowEndTime = false,	--是否需要显示下架时间
    limitBuyType = 1,	--限购类型
    limitBuyNum = 1,	--限购数量
    hasBuyNum = 0,	--已购买次数
    isSoldOut = false, 	-- 是否售罄
	item_collected = false,
	item_collected_num = 0,
	bVip = false,		--是否显示VIP
	--itemSort = 0,		--排序值(仅lua用)
	--itemStartTime = 0,	--上架时间
}
BP_ARRAY_StoreExchange_ItemInfo_List =
{
	BP_STRUCT_StoreExchange_ItemInfo = _G.BP_STRUCT_StoreExchange_ItemInfo;
}
--当前选择下标
BP_StoreExchange_Select_Index = -1
BP_StoreExchange_Sex = 1
--当前是否拥有该道具
BP_StoreExchange_HasItem = false
-- 持枪状态记录 0-显示武器，1-显示人物
BP_StoreExchange_DisplayType = 1;
-- 是否显示持枪按钮
BP_StoreExchange_SHOW_DiplayType_BTN = false;


--注册Widget
function bp_store_exchange_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_store_exchange,
        {{Path="/Game/UMG/UI_Logic/Store/Store/StoreExchangeLogicUI_BP.StoreExchangeLogicUI_BP_C", Container="Default", ZOrder=0}},
        {"Lobby"},
        false,
        false,
        true
    );
end


--更新数据
function StoreExchangeUI.UpdateData()
	local pageData = StoreSystem.store_data[StoreSystem.Page_ID_Exchange]
	if pageData == nil then
		return
	end
	--log_tree("StoreExchangeUI.OnPageInfo pageData = ", pageData)
	local itemList = pageData[StoreSystem.label_market_index_market_list]
	if itemList == nil then
		return
	end
	BP_ARRAY_StoreExchange_ItemInfo_List = {}
	local i = 0
	local icon_silver = Client.GetTableData("Item", 1001).ItemSmallIcon
	local icon_gold_chip = Client.GetTableData("Item", 1104).ItemSmallIcon
	local icon_uc = Client.GetTableData("Item", 1006).ItemSmallIcon
	for k,v in pairs(itemList) do
		local item = {}
		local cfg = Client.GetTableData("Item", v[StoreSystem.label_item_index_id]);
		if cfg == nil then
			return
		end
		item.nIndex = i
		item.itemId = v[StoreSystem.label_item_index_id]
		item.shopId = k
		item.FestivalIconUrl = cfg.SpecialIcon;
		item.isEnableCoupon = false
		item.itemName = cfg.ItemName;
		item.itemType = cfg.ItemType;
		item.itemSubType = cfg.ItemSubType
		item.itemQuality = cfg.ItemQuality;
		item.itemDes = cfg.ItemDesc;
        item.FestivalImage = cfg.StoreDetailImage;
	
		item.itemSort = v[StoreSystem.label_item_index_rank] or 0;
		item.item_collected = StoreSystem.IsCollectedByItemID(item.itemId);
		item.item_collected_num = StoreSystem.global_collection_num[item.itemId] or 0;
		
		item.itemStartTime = v[StoreSystem.label_item_index_start_time] or 0;
		item.item_position = cfg.WardrobeTab;
		
		--if v[StoreSystem.label_item_index_hot_or_new] == 1 then
		--	item.bHot = true
		--	item.bNew = false
		--elseif v[StoreSystem.label_item_index_hot_or_new] == 2 then
		--	item.bHot = false
		--	item.bNew = true
		--end
		item.Time = v[StoreSystem.label_item_index_up_time] or ""

		item.item_endTime = v[StoreSystem.label_item_index_time_limit] or 0;
		if item.item_endTime ~= 0 then
			item.item_leftTime = item.item_endTime - FuncUtil.GetServerTimeInSec();
		else
			item.item_leftTime = 0;
		end
		
		item.Discount_f = v[StoreSystem.label_item_index_discount] or 0.0
		local showDiscount, showHot, showVip = StoreFuncUtils.GetItemLeftTopTagsQueue(
				item.Discount_f ~= 0,
				StoreFuncUtils.CheckIsHot(v) == true,
				v[StoreSystem.label_item_index_vip] == 1);
		if showDiscount == false then
			item.Discount_f = 0.0;
		end
		item.bHot = showHot;
		item.bVip = showVip;

		local showNew, showSpecialIcon = StoreFuncUtils.GetItemRightTopTagsQueue(
				StoreFuncUtils.CheckIsNew(v) == true,
				cfg.SpecialIcon ~= "");
		item.bNew = showNew;
		item.showSpecialIcon = showSpecialIcon;


		if v[StoreSystem.label_item_index_up_time] and v[StoreSystem.label_item_index_up_time] > 0 then
			item.bRateUp = true
			item.RateUpEndTime = tostring(v[StoreSystem.label_item_index_up_time])
			item.RateUpRate_f = v[StoreSystem.label_item_index_up_value]
		else
			item.bRateUp = false
			item.RateUpEndTime = 0
			item.RateUpRate_f = 0
		end

		--兑换货币
		local priceInfo = StoreFuncUtils.GetExchangeMoneyInfo(v[StoreSystem.label_item_index_price_list])
		if priceInfo then
			item.priceType = priceInfo.type;
			if priceInfo.type == StoreSystem.label_price_type_chip then
				--银碎片
				item.priceIcon = icon_silver
			elseif priceInfo.type == StoreSystem.label_price_type_gold_chip then
				--金碎片
				item.priceIcon = icon_gold_chip
			else
				--uc
				item.priceIcon = icon_uc
			end
			if priceInfo.discount ~= 0 then-- 有折扣价
				item.priceNum = priceInfo.discount;
				item.originalPrice = priceInfo.num;
			else
				item.priceNum = priceInfo.num;
				item.originalPrice = 0;
			end
		end
		item.priceNumMax = StoreFuncUtils.GetFirstPriceNumMax(v[StoreSystem.label_item_index_price_list])
		item.ExpressionId = v[StoreSystem.label_item_index_expression_id] or 0

		item.bEquip = MultipleAvatar.HasEquiped(v[StoreSystem.label_item_index_id])
		if v[StoreSystem.label_item_index_can_gift] and v[StoreSystem.label_item_index_can_gift]>0 then
			item.bCanSendGift = true
		else
			item.bCanSendGift = false
		end
        
        --if v[StoreSystem.label_item_index_show_time_limit] ~= nil and v[StoreSystem.label_item_index_show_time_limit] == 1 then
        --    item.needShowEndTime = true;
        --else
        --    item.needShowEndTime = false;
        --end

		item.needShowEndTime = StoreFuncUtils.CheckNeedShowSaleEndTime(v);
		item.item_showLeftTimeIcon = v[StoreSystem.label_item_index_show_time_limit] == 1;
        
        local limitData = v[StoreSystem.label_item_index_buy_limit]
        if limitData then
            for limitType, limitCnt in pairs(limitData) do
                item.limitBuyType = limitType;
                item.limitBuyNum = limitCnt;
                local buyInfo = StoreFuncUtils.GetBuyInfo(item.shopId);
                if StoreSystem.label_buy_limit_type_daily == limitType then --每日限购
                    item.hasBuyNum = buyInfo and buyInfo.daily_buy_cnt or 0;
                elseif StoreSystem.label_buy_limit_type_week == limitType then --每周限购
                    item.hasBuyNum = buyInfo and buyInfo.week_buy_cnt or 0;
                elseif StoreSystem.label_buy_limit_type_permanent == limitType then --永久限购
                    item.hasBuyNum = buyInfo and buyInfo.permanet_buy_cnt or 0;
                end
                break;
            end
            item.isSoldOut = StoreFuncUtils.IsSoldOut(item.shopId, limitData[StoreSystem.label_buy_limit_type_daily],
                    limitData[StoreSystem.label_buy_limit_type_week],
                    limitData[StoreSystem.label_buy_limit_type_permanent]);
        end
        

		if item.item_endTime ~= 0 and item.item_leftTime <= 0 then
			--已过期
		else
			i = i + 1
			StoreExchangeUI.itemMap[item.shopId] = v
			table.insert(BP_ARRAY_StoreExchange_ItemInfo_List, item)	
		end
	end

	--排序(兑换页签的排序，做一下额外处理吧，金碎片后优先武器、载具，然后套装，然后再和原来一样直接排序--by kennyshi)
	table.sort(BP_ARRAY_StoreExchange_ItemInfo_List, function(left, right)
		if left.priceType ~= right.priceType then
			if left.priceType == 103 and right.priceType ~= 103 then
				return true
			elseif left.priceType ~= 103 and right.priceType == 103 then
				return false
			else
				return false
			end
		else
			local leftSortNum = StoreExchangeUI.GetSortNum(left);
			local rightSortNum = StoreExchangeUI.GetSortNum(right);
			if leftSortNum < rightSortNum then
				return true
			elseif leftSortNum > rightSortNum then
				return false
			else
				if left.itemQuality < right.itemQuality then
					return false
				elseif left.itemQuality > right.itemQuality then
					return true
				else
					return left.shopId < right.shopId
				end
			end
		end
	end)

	--设置选中
	i = 0
	for k,v in pairs(BP_ARRAY_StoreExchange_ItemInfo_List) do
		v.bSelected = BP_StoreExchange_Select_Index == i
		i = i + 1
	end
	--log_tree("BP_ARRAY_StoreExchange_ItemInfo_List = ", BP_ARRAY_StoreExchange_ItemInfo_List)

	if GlobalData.IsJapanOrKorea() then
		BP_StoreExchange_Sex = SupplyMainUI.GetSex();
	else
		BP_StoreExchange_Sex = StoreMainUI.GetSex();
	end
end
--金碎片下的排序值
local sortNumMap = {[1] = -10, [9] = -9, ["套装"] = -8};
function StoreExchangeUI.GetSortNum(data)
	if sortNumMap[data.itemType] ~= nil then
		return sortNumMap[data.itemType];
	end
	if sortNumMap[data.item_position] ~= nil then
		return sortNumMap[data.item_position];
	end
	return data.itemSubType;
end

--更新倒计时
function StoreExchangeUI.UpdateLeftTime()
	if UIManager.GetUI(eUIType.eStoreExchangePage) == nil then
		return
	end
	local needDelete = {};
	local needUpdate = false;
	local serverTime = FuncUtil.GetServerTimeInSec();
	for k, v in pairs(BP_ARRAY_StoreExchange_ItemInfo_List) do
		if v.item_endTime ~= 0 and v.item_endTime >= serverTime then
			v.item_leftTime = v.item_endTime - serverTime;
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
		BP_StoreExchange_Select_Index = -1
		StoreExchangeUI.UpdateData()
		StoreExchangeUI.UpdateUI()
	else
		if needUpdate == true then
			LuaClassObj.HandleUIMessageNoFetch(bp_store_exchange, "UpdateVisibleItem");
		end
	end
end

-- 显示
function StoreExchangeUI.Show(nTab1Id, nTab2Id, jumpInfo)
	if UIManager.GetUI(eUIType.eStoreExchangePage) then
		return
	end
	log("StoreExchangeUI.Show")
    LobbyCameraManager.SwitchCamera(LobbyCameraManager.store_exchange)
	StoreExchangeUI.jumpInfo = jumpInfo
    BP_StoreExchange_SHOW_DiplayType_BTN = false
    
	LuaClassObj.HandleDynamicCreation(bp_store_exchange);
	LuaClassObj.HandleUIMessageNoFetch(bp_store_exchange, "UIShow");
	UIManager.Show(eUIType.eStoreExchangePage)
	if GlobalData.IsJapanOrKorea() then
		UIManager.Show(eUIType.eSupplyMainUI);
	end

	EventSystem:registEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_DATA, StoreExchangeUI.OnPageInfo);
	EventSystem:registEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_COLLECT, StoreExchangeUI.OnCollectedResult);
	EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_DATA_CHANGE, StoreExchangeUI.OnItemChange);
	EventSystem:registEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_BUY_INFO_CHANGE, StoreExchangeUI.OnBuyInfoChange);
	
	StoreSystem.GetTabData(StoreSystem.store_tab, StoreSystem.Page_ID_Exchange)
end

-- 关闭
function StoreExchangeUI.Hide()
	if UIManager.GetUI(eUIType.eStoreExchangePage) == nil then
		return
	end
	log("StoreExchangeUI.Hide")
	EventSystem:unregistEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_DATA, StoreExchangeUI.OnPageInfo);
	EventSystem:unregistEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_COLLECT, StoreExchangeUI.OnCollectedResult);
	EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_DATA_CHANGE, StoreExchangeUI.OnItemChange);
	EventSystem:unregistEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_BUY_INFO_CHANGE, StoreExchangeUI.OnBuyInfoChange);
	UIManager.Hide(eUIType.eStoreExchangePage)
	LuaClassObj.HandleUIMessageNoFetch(bp_store_exchange, "UIHide");
end

function StoreExchangeUI.UIOnlyShow()
    LobbyCameraManager.SwitchCamera(LobbyCameraManager.store_exchange)
	LuaClassObj.HandleUIMessageNoFetch(bp_store_exchange, "UIOnlyShow");
end

function StoreExchangeUI.UIOnlyHide()
	LuaClassObj.HandleUIMessageNoFetch(bp_store_exchange, "UIOnlyHide");
end

-- 跳转接口（框架调用）
function StoreExchangeUI.JumpTo(pageID, jumpInfo)
	StoreExchangeUI.Show(pageID, 0, jumpInfo)
end


function StoreExchangeUI.UpdateUI()
	LuaClassObj.HandleUIMessageNoFetch(bp_store_exchange, "UpdateUI");
end

function StoreExchangeUI.Release()
    log("StoreExchangeUI.Release")
end

function StoreExchangeUI.SelectedItem(index, bForceEquip)
	if BP_StoreExchange_Select_Index < 0 then
		ModelDisplayer.SetShowtype(ModelDisplayer.SHOWTYPE_AVATAR)
		return
	end
	local item = BP_ARRAY_StoreExchange_ItemInfo_List[BP_StoreExchange_Select_Index + 1]
	if item == nil then
		return
	end

	-- 点击后new消失
	if item.bNew == true then
		local itemInfo = Client.GetTableData("Item", item.itemId);
		if itemInfo ~= nil then
			StoreSystem.CheckRecordNewTag(item.shopId);

			local showNew, showSpecialIcon = StoreFuncUtils.GetItemRightTopTagsQueue(
					false,
					itemInfo.SpecialIcon ~= "");
			item.bNew = showNew;
			item.showSpecialIcon = showSpecialIcon;
		end
	end

	BP_StoreExchange_HasItem = StoreFuncUtils.IsPossessed(item.itemId, 0, 0);

	if bForceEquip and not MultipleAvatar.HasEquiped(item.itemId) or not bForceEquip then
		if GlobalData.IsJapanOrKorea() then
			SupplyMainUI.OnSelectedItem(item.itemId, 0, 0, false, true);
		else
			StoreMainUI.OnSelectedItem(item.itemId, 0, 0);
		end
	end
	
    BP_StoreExchange_SHOW_DiplayType_BTN = StoreFuncUtils.IsWeapon(item.itemId)--  and MultipleAvatar.HasEquiped(item.itemId)
    if not BP_StoreExchange_SHOW_DiplayType_BTN then
        BP_StoreExchange_DisplayType = 1
    end
end

-- 点击道具格子按钮
function EventStoreExchangeUI_Click_Item()
	log("BP_StoreExchange_Select_Index="..BP_StoreExchange_Select_Index)
	StoreExchangeUI.SelectedItem(BP_StoreExchange_Select_Index, false)
	StoreExchangeUI.UpdateData()
	LuaClassObj.HandleUIMessageNoFetch(bp_store_exchange, "UpdateVisibleItem");
	LuaClassObj.HandleUIMessageNoFetch(bp_store_exchange, "ShowFeatures");
end

--点击格子里面的价格
function EventStoreExchangeUI_Click_Buy()
	log("BP_StoreExchange_Select_Index="..BP_StoreExchange_Select_Index)
	StoreExchangeUI.SelectedItem(BP_StoreExchange_Select_Index, false)
	StoreExchangeUI.UpdateData()
	LuaClassObj.HandleUIMessageNoFetch(bp_store_exchange, "UpdateVisibleItem");
	--LuaClassObj.HandleUIMessageNoFetch(bp_store_exchange, "ShowFeatures");
	--ShowNotice(4036)
end

-- 点击购买按钮
function EventStoreExchangeUI_Click_BuyItem()
	log("EventStoreExchangeUI_Click_Buy")
	local item = BP_ARRAY_StoreExchange_ItemInfo_List[BP_StoreExchange_Select_Index + 1]
	if item == nil then
		return
	end
	local buyInfo = StoreExchangeUI.itemMap[item.shopId]
	if buyInfo == nil then
		return
	end
	local shopInfo = StoreFuncUtils.ConvertToShopInfo(buyInfo, StoreSystem.Page_ID_Exchange, 0)
	if shopInfo == nil then
		return
	end
	
	local priceType = item.priceType
	if item.priceType == StoreSystem.label_price_type_chip then
		priceType = StoreSystem.label_price_type_chip
	elseif item.priceType == StoreSystem.label_price_type_gold_chip then
		priceType = StoreSystem.label_price_type_gold_chip
	end
	StoreFuncUtils.PurchaseItem(shopInfo, priceType);
end

--点击赠送
function EventStoreExchangeUI_Click_SendItem()
	log("EventStoreExchangeUI_Click_SendItem")
	local item = BP_ARRAY_StoreExchange_ItemInfo_List[BP_StoreExchange_Select_Index + 1]
	if item == nil then
		return
	end
	local buyInfo = StoreExchangeUI.itemMap[item.shopId]
	if buyInfo == nil then
		return
	end
	local shopInfo = StoreFuncUtils.ConvertToShopInfo(buyInfo, StoreSystem.Page_ID_Exchange, 0)
	if shopInfo == nil then
		return
	end
	StoreFuncUtils.SendGift(shopInfo)
end

-- 点击sex按钮
function EventStoreExchangeUI_Click_Sex()
	log("EventStoreExchangeUI_Click_Sex")
	if GlobalData.IsJapanOrKorea() then
		SupplyMainUI.SwitchSex();
		BP_StoreExchange_Sex = SupplyMainUI.GetSex();
	else
		StoreMainUI.SwitchSex();
		BP_StoreExchange_Sex = StoreMainUI.GetSex();
	end
	LuaClassObj.HandleUIMessageNoFetch(bp_store_exchange, "UpdateSexBtn")
end

-- 点击红装表情播放按钮
function EventStoreExchangeUI_Click_Emotion()
    log("EventStoreExchangeUI_Click_Emotion")
    local item = BP_ARRAY_StoreExchange_ItemInfo_List[BP_StoreExchange_Select_Index + 1]
    if item == nil then
        return
    end
	if GlobalData.IsJapanOrKorea() then
		SupplyMainUI.PlayAvatarEmotion(item.ExpressionId);
	else
		StoreMainUI.PlayAvatarEmotion(item.ExpressionId);
	end
end


function EventStoreExchangeUI_ClickChangeWeapon()
    if BP_StoreExchange_DisplayType == 0 then
        BP_StoreExchange_DisplayType = 1;
        ModelDisplayer.SetShowtype(ModelDisplayer.SHOWTYPE_AVATAR);
    else
        BP_StoreExchange_DisplayType = 0;
        ModelDisplayer.SetShowtype(ModelDisplayer.SHOWTYPE_WEAPON_MODEL);
    end
    LuaClassObj.HandleUIMessageNoFetch(bp_store_exchange, "UpdateDisplayType");
end


function StoreExchangeUI.GetItemIndex(itemId)
	for i=1,#BP_ARRAY_StoreExchange_ItemInfo_List,1 do
		if BP_ARRAY_StoreExchange_ItemInfo_List[i].itemId == itemId then
			return i-1
		end
	end
	return 0
end

function StoreExchangeUI.OnPageInfo(eventType, eventID, res)
	if res.tab_type ~= StoreSystem.store_tab or res.tab_id ~= StoreSystem.Page_ID_Exchange then
		return
	end
	if StoreExchangeUI.jumpInfo then
		StoreExchangeUI.UpdateData()
		BP_StoreExchange_Select_Index = StoreExchangeUI.GetItemIndex(StoreExchangeUI.jumpInfo.itemId)
		StoreExchangeUI.SelectedItem(BP_StoreExchange_Select_Index, true)
		StoreExchangeUI.UpdateData()
		StoreExchangeUI.UpdateUI()
		LuaClassObj.HandleUIMessageNoFetch(bp_store_exchange, "JumpToSelect")
		StoreExchangeUI.jumpInfo = nil
	else
		BP_StoreExchange_Select_Index = -1
		StoreExchangeUI.SelectedItem(BP_StoreExchange_Select_Index, false)
		StoreExchangeUI.UpdateData()
		StoreExchangeUI.UpdateUI()
	end
end

--购买成功，刷新
function StoreExchangeUI.OnItemChange()
	if BP_StoreExchange_Select_Index < 0 then
		return
	end
	local item = BP_ARRAY_StoreExchange_ItemInfo_List[BP_StoreExchange_Select_Index + 1]
	if item == nil then
		return
	end
    StoreExchangeUI.UpdateData()
	BP_StoreExchange_HasItem = StoreFuncUtils.IsPossessed(item.itemId, 0, 0);
	LuaClassObj.HandleUIMessageNoFetch(bp_store_exchange, "UpdateVisibleItem");
end

function StoreExchangeUI.OnBuyInfoChange()
	log("[HHF]StoreExchangeUI.OnBuyInfoChange");
	if BP_StoreExchange_Select_Index < 0 then
		return
	end
	local item = BP_ARRAY_StoreExchange_ItemInfo_List[BP_StoreExchange_Select_Index + 1]
	if item == nil then
		return
	end

	local buyInfo = StoreFuncUtils.GetBuyInfo(item.shopId);
	if StoreSystem.label_buy_limit_type_daily == item.limitBuyType then --每日限购
		item.hasBuyNum = buyInfo and buyInfo.daily_buy_cnt or 0;
	elseif StoreSystem.label_buy_limit_type_week == item.limitBuyType then --每周限购
		item.hasBuyNum = buyInfo and buyInfo.week_buy_cnt or 0;
	elseif StoreSystem.label_buy_limit_type_permanent == item.limitBuyType then --永久限购
		item.hasBuyNum = buyInfo and buyInfo.permanet_buy_cnt or 0;
	end

	LuaClassObj.HandleUIMessageNoFetch(bp_store_exchange, "UpdateItemDes");

	local pageData = StoreSystem.store_data[StoreSystem.Page_ID_Exchange]
	if pageData == nil then
		return
	end

	local itemList = pageData[StoreSystem.label_market_index_market_list]
	if itemList == nil then
		return
	end

	local value = itemList[item.shopId];
	if value ~= nil then
		local limitData = value[StoreSystem.label_item_index_buy_limit];
		if limitData ~= nil then
			item.isSoldOut = StoreFuncUtils.IsSoldOut(item.shopId, limitData[StoreSystem.label_buy_limit_type_daily],
				limitData[StoreSystem.label_buy_limit_type_week],
				limitData[StoreSystem.label_buy_limit_type_permanent]);

			LuaClassObj.HandleUIMessageNoFetch(bp_store_exchange, "UpdateBuyBtn");
		end
	end
end

function StoreExchangeUI.OnCollectedResult()
	log("[HHF]StoreExchangeUI.OnCollectedResult");
	local itemInfo = BP_ARRAY_StoreExchange_ItemInfo_List[BP_StoreExchange_Select_Index + 1]
	if itemInfo == nil then
		return
	end

	local item_id = itemInfo.itemId;
	local result = StoreSystem.IsCollectedByItemID(item_id);
	log("[HHF]StoreExchangeUI.OnCollectedResult, result = " .. tostring(result));
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
	LuaClassObj.HandleUIMessageNoFetch(bp_store_exchange, "UpdateCollectBtn");
end

function EventOnClickCollectExchange()
	log("[HHF]EventOnClickCollectProp");
	if UIUtil.CanClickNow(ClickFrequencyLimit.StoreCollectionBtn) == false then
		return;
	end

	local itemInfo = BP_ARRAY_StoreExchange_ItemInfo_List[BP_StoreExchange_Select_Index + 1]
	if itemInfo == nil then
		return
	end

	if itemInfo.item_collected then
		StoreSystem.cancel_market_collect_by_item_req(itemInfo.itemId);
	else
		StoreSystem.add_market_collect_by_item_req(itemInfo.itemId, StoreSystem.market_collect_source_market);
	end
end
