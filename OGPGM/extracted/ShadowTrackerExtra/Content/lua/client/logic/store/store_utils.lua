--sami 商城公共接口函数
StoreFuncUtils = {
	NewFlagAvailableTime = 7 * 24 * 3600,   -- New标记有效期7天

	DiscountType_NONE = 0,-- 没有折扣
	DiscountType_DISCOUNT_ACTIVITY = 1,-- 折扣活动
	DiscountType_VIP = 2,-- 订阅折扣

	CheckMoneyBtnType = {
		NIL = nil,
		Cancel = 0,
		OK = 1,
		Pay = 2,
	},
}


-- 点击充值uc按钮
function StoreFuncUtils.OnClickAddUC()
	RechargeUI:Init()
end

-- 获取货币信息
function StoreFuncUtils.GetMoneyInfo()
	local info = {}
	info.nGold = DataMgr.gold or 0
	info.nUC = DataMgr.ticket or 0
	info.nZhupai = DataMgr.fp_token or 0
	info.nSilver = DataMgr.diamond or 0
	info.nGoldChip = DataMgr.gold_chip or 0

	local region = Client.GetPublishRegion();
	if region == "JAPAN" or region == "KOREA" then
		info.bShowZhupai = true
	else
		info.bShowZhupai = false
	end
	return info
end

--获取兑换货币信息
function StoreFuncUtils.GetExchangeMoneyInfo(data)
    if data == nil then
        return nil
    end
    local uc = StoreSystem.label_price_type_uc
    local silver = StoreSystem.label_price_type_chip
    for k,v in pairs(data) do
        if v[6] == silver then
            return {type=v[6], num=v[1], discount=v[2] or 0}
        end
    end
    for k,v in pairs(data) do
        if v[6] ~= silver then
            return {type=v[6], num=v[1], discount=v[2] or 0}
        end
    end
    return nil
end

--获取第一货币最大价格
function StoreFuncUtils.GetFirstPriceNumMax(data)
	if data == nil then
		return 0
	end
	--log_tree("GetFirstPriceNumMax data=", data)

	local firstType = -1
	local firstMax = 0
	for k,v in pairs(data) do
		if firstType == -1 then
			firstType = v[6]
			firstMax = v[1]
		else
			if firstType == v[6] then
				if firstMax < v[1] then
					firstMax = v[1]
				end
			else
				return firstMax
			end
		end
	end
	return firstMax
end

function StoreFuncUtils.GetFirstPriceNumMax2(data)
	--log_tree("GetFirstPriceNumMax2=", data)
	if data == nil then
		return 0
	end
	local maxPrice = 0
	for k,v in pairs(data) do
		for kk,vv in pairs(v) do
			if maxPrice < vv.Price then
				maxPrice = vv.Price
			end
		end
	end
	return maxPrice
end

function StoreFuncUtils.GetPriceNumMax(data, selectType)
	if data == nil then
		return 0
	end

	local selectType = selectType or -1
	local selectMax = 0
	for k,v in pairs(data) do
		if selectType == -1 then
			selectType = v[6]
			selectMax = v[1]
		elseif selectType == v[6] then
			if selectMax < v[1] then
				selectMax = v[1]
			end
		end
	end
	return selectMax
end

local PetSystem = require("client.slua.logic.pet.logic_pet");
function StoreFuncUtils.HasItem(itemId, colorID, patternID)
	colorID = colorID or 0
	patternID = patternID or 0
	local ItemList = DataMgr.GetHallDepotItemListByResID(itemId)
	for i,v in pairs(ItemList) do
		if v.resID == itemId and (v.colorID == nil or v.colorID == colorID) and (v.patternID == nil or v.patternID == patternID) then
			if v.validHours ~= nil and v.validHours > 0 then
				--限时物品不能算拥有;
			else
				return true;
			end
		end
	end
	-- 头像
	if StoreFuncUtils.HasHeadPortrait(itemId) == true then
		return true;
	end
	------ 头像框
	--if StoreFuncUtils.HasAvatarFrame(itemId) == true then
	--	return true;
	--end
	-- 宠物
	if StoreFuncUtils.IsPetItemID(itemId) == true then
		if PetSystem.HasPet(itemId) then
			return true;
		end
	end
	return false;
end

-- 是否拥有头像
function StoreFuncUtils.HasHeadPortrait(itemId)
	log("RoleInfoHeadportraitSystem.HasHeadPortrait itemId = "..tostring(itemId))
	log_tree("RoleInfoHeadportraitSystem.HeadportraitListUnClear", RoleInfoHeadportraitSystem.HeadportraitListUnClear)
	if RoleInfoHeadportraitSystem.HasHeadPortrait(itemId) == true then
		return true;
	end
	return false;
end

-- 是否拥有头像框
function StoreFuncUtils.HasAvatarFrame(itemId)
	log("RoleInfoHeadportraitSystem.HasHeadPortrait itemId = "..tostring(itemId))
	log_tree("RoleInfoAvatarFrameSystem.AvartarFrameListUnClear", RoleInfoAvatarFrameSystem.AvartarFrameListUnClear)
	-- 头像框数据
	if RoleInfoAvatarFrameSystem.HasAvatarFrame(itemId) == true then
		return true;
	end
	return false;
end

function StoreFuncUtils.get_money_type_and_price(id, is_first_money, shopInfo, time_valid_index)
	local node = shopInfo

	local money_type = node.money1_type
	local money_price = node.money1_price
	if is_first_money == 1 then
		money_type = node.money1_type
		if not time_valid_index or time_valid_index == 1 then
			money_price = node.money1_price
		elseif time_valid_index == 2 then
			money_price = node.money1_price2
		elseif time_valid_index == 3 then
			money_price = node.money1_price3
		end
	else
		money_type = node.money2_type
		if not time_valid_index or time_valid_index == 1 then
			money_price = node.money2_price
		elseif time_valid_index == 2 then
			money_price = node.money2_price2
		elseif time_valid_index == 3 then
			money_price = node.money2_price3
		end
	end

	local now = FuncUtil.GetServerTimeInSec();
	if node.permanet_discount_begin_time ~= 0 and node.permanet_discount_begin_time ~= "" then
		local start_tm = node.permanet_discount_begin_time;
		if now >= start_tm then
			if  is_first_money ~= 1 then
				money_price = node.permanet_discount_price2
			else
				money_price = node.permanet_discount_price1
			end
		end
	end

	-- 限时折扣必须同时配置开始、结束时间，才算生效
	if node.timelimit_discount_begin_time ~= "" and node.timelimit_discount_begin_time ~= 0 and node.timelimit_discount_end_time ~= "" and node.timelimit_discount_end_time ~= 0 then
		local start_tm = node.timelimit_discount_begin_time
		local end_tm = node.timelimit_discount_end_time
		if now >= start_tm and now <= end_tm then
			if is_first_money ~= 1 then
				money_price = node.timelimit_discount_price2
			else
				money_price = node.timelimit_discount_price1
			end
		end
	end

	return money_type, money_price
end

function StoreFuncUtils.MoneyTypeToChinaMoneyType(moneyType)
	if moneyType == 0 then
		return 1000;
	elseif moneyType == 1 then
		return 1001;
	elseif moneyType == 2 then
		return 1006;
	end
	return moneyType;
end

local function localText(id)
	local data = Client.GetTableData("LocalizeRes",id);
	if data then
		return data.TextValue
	end
	return ""
end

function StoreFuncUtils.GetMoneyName(money_type)
	local money_name = ""
	local itm_cfg = Client.GetTableData("Item", money_type)
	if itm_cfg then
		return itm_cfg.ItemName
	end
	return money_name
end

--检查货币是否充足 callback参数说明 参数1=true充足，false不够，参数2=nil无，0取消，1确定，2前往
function StoreFuncUtils.CheckMoneyIsEnough(money_type, money_price, callback)
	local money_name = StoreFuncUtils.GetMoneyName(money_type)
	if money_type == 1000 then
		--金币
		if money_price > DataMgr.gold then
			local str = string.format("%s不足", money_name)
			CommonMessageBoxUI:ShowPanel(1, localText(101001), str,
										 function() callback(false, StoreFuncUtils.CheckMoneyBtnType.OK) end);
		else
			callback(true)
		end
	elseif money_type == 1001 then
		--钻石
		local ticket_name = StoreFuncUtils.GetMoneyName(1006)
		if money_price > DataMgr.diamond then
			--1点券=1钻石
			local now_ticket = DataMgr.ticket
			local need_diamond = money_price - DataMgr.diamond
			--如果是钻石不足，判断点券是否充足
			if need_diamond <= now_ticket then
				--可以用点券补足
				local str = string.format(localText(501051), money_name, need_diamond, ticket_name)
				CommonMessageBoxUI:ShowPanel(2, localText(101001), str,
											 function()
												 callback(true, StoreFuncUtils.CheckMoneyBtnType.OK)
											 end,
											 function()
												 callback(true, StoreFuncUtils.CheckMoneyBtnType.Cancel)
											 end);
				return
			end
			local str = string.format(localText(501052), money_name)
			CommonMessageBoxUI:ShowPanel(2, localText(101001), str,
										 function()
											 callback(false, StoreFuncUtils.CheckMoneyBtnType.Pay)
											 RechargeUI:Init();
										 end,
										 function()
											 callback(false, StoreFuncUtils.CheckMoneyBtnType.Cancel)
										 end);
		else
			callback(true)
		end
	elseif money_type == 1006 then
		--点券
		if money_price > DataMgr.ticket then
			local str = string.format(localText(501052), money_name)
			CommonMessageBoxUI:ShowPanel(2, localText(101001), str,
										 function()
											 callback(false, StoreFuncUtils.CheckMoneyBtnType.Pay)
											 RechargeUI:Init();
										 end,
										 function()
											 callback(false, StoreFuncUtils.CheckMoneyBtnType.Cancel)
										 end);
		else
			callback(true)
		end
	end
end

function StoreFuncUtils.ChinaMoneyTypeToMoneyType(moneyType)
	if moneyType == 1000 then
		return 0;
	elseif moneyType == 1001 then
		return 1;
	elseif moneyType == 1006 then
		return 2;
	end
	return moneyType;
end

function StoreFuncUtils.GetBuySource()
	local Buy_Source = 2
	if StoreRecommendPage.isShow then
		Buy_Source = 1
	end

	return Buy_Source
end

---PriceList = {
---    {
---        Type = 0,
---        Price = 100,
---        Num = 0,
---    },
---    ...
---}


---CouponDiscountPrice 代金券折扣价格
function StoreFuncUtils.CheckMoney(PriceList,CouponDiscountPrice)
	local goldToPurchase = 0		-- BP
	local diamondToPurchase = 0		-- SF
	local ticketToPurchase = 0		-- UC
	for i, v in pairs(PriceList) do
		if v.Type == 0 then
			goldToPurchase = goldToPurchase + v.Price * v.Num
		end
		if v.Type == 1 then
			diamondToPurchase = diamondToPurchase + v.Price * v.Num
		end
		if v.Type == 2 then
			ticketToPurchase = ticketToPurchase + v.Price * v.Num
		end
	end

	if goldToPurchase > DataMgr.gold then
		DataMgr.ShowNoticeByID(502024);
		return false
	end
	if CouponDiscountPrice then
		ticketToPurchase = ticketToPurchase - CouponDiscountPrice
	end
	if ticketToPurchase > DataMgr.ticket then
		local str = Client.GetTableData("LocalizeRes", "101001").TextValue;
		local tip = Client.GetTableData("LocalizeRes", "4300").TextValue;
		CommonMessageBoxUI:ShowPanel(2, str, tip, function()
			RechargeUI:Init();
			return true;
		end);
		return false
	end
	if diamondToPurchase > DataMgr.diamond then
		DataMgr.ShowNoticeByID(4457);
		return false
	end

	return true
end

function StoreFuncUtils.IsWithCount(itemType)
	local IsWithCount = true
	if itemType == 1 or itemType == 4 or itemType == 5 or itemType == 8 or itemType == 9 or itemType == 200 or itemType == 500 then
		IsWithCount = false
	end

	return IsWithCount
end

function StoreFuncUtils.GetBuyInfo(ItemId)
	local BuyInfo = {
		daily_buy_cnt = 0,
		week_buy_cnt = 0,
		permanet_buy_cnt = 0,
	}
	if StoreSystem.buy_info and StoreSystem.buy_info[ItemId] then
		BuyInfo.daily_buy_cnt    = StoreSystem.buy_info[ItemId].daily_buy_cnt or 0
		BuyInfo.week_buy_cnt     = StoreSystem.buy_info[ItemId].week_buy_cnt or 0
		BuyInfo.permanet_buy_cnt = StoreSystem.buy_info[ItemId].permanet_buy_cnt or 0
	end
	return BuyInfo
end

function StoreFuncUtils.ConvertToShopInfo(ItemData, TabId, SubId)
	-- ShopInfo结构
	local ShopInfo = {
		valid_hours1 = 0,		-- 有效时间1
		valid_hours2 = 0,		-- 有效时间2
		valid_hours3 = 0,		-- 有效时间3
		valid2_hours1 = 0,
		valid2_hours2 = 0,
		valid2_hours3 = 0,
		money1_price2 = 0,		-- 货币1价格1
		money1_price3 = 0,		-- 货币1价格2
		money2_type = 0,		-- 货币1价格3
		money2_price = 0,
		money2_price2 = 0,
		money2_price3 = 0,
		item_id = 0,
		id = 0,
		name = "",
		gift_open = false,
		off_rate = 0,
		title_hot = false,
		title_new = false,
		item_count = 1,
		shop_rank = 0,
		timelimit_off_rate = 0,
		timelimit_discount_begin_time = 0,
		daily_buy_limit = 0,
		week_buy_limit = 0,
		permanet_buy_limit = 0,

		--NewData
		tab_id = 0,
		sub_id = 0,

		--Unknown
		timelimit_discount_end_time = 0,
		timelimit_discount_price1 = 0,
		timelimit_discount_price2 = 0,
		permanet_discount_begin_time = 0,
		permanet_discount_price1 = 0,
		permanet_discount_price2 = 0,
		voucher = {},
		sale_begin_time = 0,
		sale_end_time = 0,
		show_limit_time = 0,

		--Useless
		page = 0,
		icon_name = "",
		item_type = 0,
		item_tips = "",
		category = 0,
		valid_time = 1,
		item_sub_type = 0,

        is_vip_item = 0,
	}

	-- 将新协议中的时限、价格、货币类型转换成旧协议的格式
	local PriceList = ItemData[StoreSystem.label_item_index_price_list];
	if PriceList and next(PriceList) then
		local validHourIdx1, validHourIdx2 = 1, 1;
		local firstType = PriceList[1][StoreSystem.label_price_index_price_type];
		local priceKey = "";
		for i, v in ipairs(PriceList) do
			if v[StoreSystem.label_price_index_price_type] == firstType then
				ShopInfo["valid_hours" .. validHourIdx1] = v[StoreSystem.label_price_index_valid_hours];
				if validHourIdx1 == 1 then
					ShopInfo.money1_type = v[StoreSystem.label_price_index_price_type];
					priceKey = "money1_price";
				else
					priceKey = "money1_price" .. validHourIdx1;
				end
				validHourIdx1 = validHourIdx1 + 1;
			else
				ShopInfo["valid2_hours" .. validHourIdx2] = v[StoreSystem.label_price_index_valid_hours];
				if validHourIdx2 == 1 then
					ShopInfo.money2_type = v[StoreSystem.label_price_index_price_type];
					priceKey = "money2_price";
				else
					priceKey = "money2_price" .. validHourIdx2;
				end
				validHourIdx2 = validHourIdx2 + 1;
			end

			if v[StoreSystem.label_price_index_one_discount_price] and v[StoreSystem.label_price_index_one_discount_price] > 0 then
				ShopInfo[priceKey] = v[StoreSystem.label_price_index_one_discount_price];
			else
				ShopInfo[priceKey] = v[StoreSystem.label_price_index_one_original_price];
			end
		end
	end


	-- 剩余属性
	ShopInfo.item_id = ItemData[StoreSystem.label_item_index_id]
	ShopInfo.id = ItemData[StoreSystem.label_item_index_market_id]

	if ItemData[StoreSystem.label_item_index_can_gift] then
		ShopInfo.bCanBeGift = true
	end

	ShopInfo.off_rate = ItemData[StoreSystem.label_item_index_up_value]
	if ItemData[StoreSystem.label_item_index_hot_or_new] == 1 then
		ShopInfo.title_hot = true
	elseif ItemData[StoreSystem.label_item_index_hot_or_new] == 2 then
		ShopInfo.title_new = true
	end

	ShopInfo.item_count = ItemData[StoreSystem.label_item_index_count] or 0

	local LimitInfo = ItemData[StoreSystem.label_item_index_buy_limit]

	if LimitInfo then
		ShopInfo.daily_buy_limit = LimitInfo[StoreSystem.label_buy_limit_type_daily] or 0
		ShopInfo.week_buy_limit = LimitInfo[StoreSystem.label_buy_limit_type_week] or 0
		ShopInfo.permanet_buy_limit = LimitInfo[StoreSystem.label_buy_limit_type_permanent] or 0
	end

	--NewData
	ShopInfo.tab_id = TabId
	ShopInfo.sub_id = SubId

	--Unknown
	ShopInfo.timelimit_off_rate = 0
	ShopInfo.timelimit_discount_begin_time = 0
	ShopInfo.timelimit_discount_end_time = 0
	ShopInfo.timelimit_discount_price1 = 0
	ShopInfo.timelimit_discount_price2 = 0
	ShopInfo.permanet_discount_begin_time = 0
	ShopInfo.permanet_discount_price1 = 0
	ShopInfo.permanet_discount_price2 = 0
	ShopInfo.voucher = {}
	ShopInfo.sale_begin_time = 0
	ShopInfo.sale_end_time = 0
	ShopInfo.show_limit_time = 0

	--Useless
	ShopInfo.name = ""
	ShopInfo.shop_rank = 0
	ShopInfo.page = 0
	ShopInfo.icon_name = ""
	ShopInfo.item_type = 0
	ShopInfo.item_tips = ""
	ShopInfo.category = 0
	ShopInfo.valid_time = 1
	ShopInfo.item_sub_type = 0

    ShopInfo.is_vip_item = ItemData[StoreSystem.label_item_index_vip] or 0;

	return ShopInfo
end

-- 蓝图调用
function StoreFuncUtils.GetJumpIdByJumpInfo(ItemInfo)
	if string.find(ItemInfo, "module=10003") then
		return 2
	elseif string.find(ItemInfo, "module=20001") then
		local params = FuncUtil:ParseURLParams(ItemInfo);
		local itemId = tonumber(params["itemId"]);
		local chestItemId = JumpUtils.GetJumpToChestItemId(itemId);
		if chestItemId ~= -1 then
			return 4
		else
			return 0
		end
	elseif JumpUtils.IsGameJumpUrl(ItemInfo) then
		return 3
	end
	local ItemId = tostring(ItemInfo)
	local jumpInfo = JumpUtils.FindJumpInfo(tonumber(ItemId), JumpUtils.MODEL_ID_STORE)
	if jumpInfo == nil then
		log_warning("jumpInfo is nil")
		return 0
	end
	local jumpModuleId = jumpInfo.moduleId
	if jumpModuleId == JumpUtils.MODEL_ID_SUPPLY then
		return 1
	end
	if jumpModuleId == JumpUtils.MODEL_ID_PASS then
		return 2
	end
	return 0
end

function StoreFuncUtils.JumpToPass(info)
	if UIManager.GetUI(eUIType.eStoreMainUI) then
		JumpUtils.JumpReal(JumpUtils.MODEL_ID_STORE, JumpUtils.MODEL_ID_PASS, info)
	elseif UIManager.GetUI(eUIType.eSupplyMainUI) then
		JumpUtils.JumpReal(JumpUtils.MODEL_ID_SUPPLY, JumpUtils.MODEL_ID_PASS, info)
	else
		JumpUtils.JumpReal(JumpUtils.MODEL_ID_LOBBY, JumpUtils.MODEL_ID_PASS, info)
	end
end

function StoreFuncUtils.Jump(JumpInfo)
	--清除跳转来源
	if StoreMainUI.jumpInfo ~= nil then
		StoreMainUI.jumpInfo.FromUIType = nil
	end

	local thisJumpInfo = tostring(JumpInfo)
	if string.find(thisJumpInfo, "module=10003") then
		--跳转pass
		local params = FuncUtil:ParseURLParams(thisJumpInfo);
		local tab1 = tonumber(params["Tab1"]);
		local itemId = tonumber(params["itemId"]);
		local info = {}
		info.moduleId = JumpUtils.MODEL_ID_PASS
		info.itemId = itemId
		info.Tab1 = tab1
		StoreFuncUtils.JumpToPass(info)
	elseif string.find(thisJumpInfo, "module=20001") then
		--跳转礼包
		local params = FuncUtil:ParseURLParams(thisJumpInfo);
		local itemId = tonumber(params["itemId"]);
		local chestItemId = JumpUtils.GetJumpToChestItemId(itemId);
		if chestItemId ~= -1 then
			JumpUtils.JumpAll(JumpUtils.MODEL_ID_STORE, chestItemId);
		end
	elseif JumpUtils.IsGameJumpUrl(thisJumpInfo) then
		if UIManager.GetUI(eUIType.eStorePreviewPage) then
			StorePreviewUI.ForceClose()
		end
		ItemUpgradeUI.jumpViewCloseCallBack = nil;
        StoreMainUI.CloseUI();
		GlobalData:JumpUrl(thisJumpInfo)

	else
		if UIManager.GetUI(eUIType.eStorePreviewPage) then
			local info = JumpUtils.FindJumpInfo(tonumber(thisJumpInfo), JumpUtils.MODEL_ID_STORE)
			if info == nil then
				log_warning("Jump Info is nil")
				return
			end
			JumpUtils.JumpReal(JumpUtils.MODEL_ID_FULL_PREVIEW, info.moduleId, info)
		else
			JumpUtils.Jump(JumpUtils.MODEL_ID_STORE, tonumber(thisJumpInfo))
		end
	end
end

function StoreFuncUtils.JumpFirst(JumpInfo, moduleId)
	local thisJumpInfo = tostring(JumpInfo);
	if JumpUtils.IsGameJumpUrl(thisJumpInfo) then
		ItemUpgradeUI.jumpViewCloseCallBack = nil;
		StoreMainUI.CloseUI();
		GlobalData:JumpUrl(thisJumpInfo);
	else
		JumpUtils.JumpFirst(moduleId, tonumber(thisJumpInfo));
	end
end

function StoreFuncUtils.JumpAll(JumpInfo)
	local thisJumpInfo = tostring(JumpInfo)
	if JumpUtils.IsGameJumpUrl(thisJumpInfo) then
		ItemUpgradeUI.jumpViewCloseCallBack = nil;
		StoreMainUI.CloseUI();
		GlobalData:JumpUrl(thisJumpInfo)
	else
		JumpUtils.JumpAll(JumpUtils.MODEL_ID_STORE, tonumber(thisJumpInfo))
	end
end

function StoreFuncUtils.IsPossessed(ItemId, ColorId, PatternId)
	log("ItemId " ..tostring(ItemId))
	local cfg = Client.GetTableData("Item", ItemId)
	local IsWithCount = StoreFuncUtils.IsWithCount(cfg.ItemType)
	if not IsWithCount then
		local colorID = ColorId or 0
		local patternId = PatternId or 0
		return StoreFuncUtils.HasItem(ItemId, colorID, patternId)
	end
	return false
end

function StoreFuncUtils.IsSoldOut(ItemId, DayLimit, WeekLimit, PermanentLimit)
	local itemBuyInfo = StoreFuncUtils.GetBuyInfo(ItemId)
	if DayLimit and DayLimit > 0 and itemBuyInfo.daily_buy_cnt >= DayLimit then
		return true
	end
	if WeekLimit and WeekLimit > 0 and itemBuyInfo.week_buy_cnt >= WeekLimit then
		return true
	end
	if PermanentLimit and PermanentLimit > 0 and itemBuyInfo.permanet_buy_cnt >= PermanentLimit then
		return true
	end

	return false
end

function StoreFuncUtils.JumpToItemUpgrade(itemID)
	log("EventMallSystemClickJumpToItemUpgrade itemID:"..itemID)
	local itemCfg = Client.GetTableData("Item", itemID);
	if itemCfg ~= nil then
		--if UIManager.GetUI(eUIType.eStorePreviewPage) ~= nil then
		--	StorePreviewUI.ForceClose();
		--end
		EventStartCloseMallSystem();
		ItemUpgradeUI.jumpViewCloseCallBack = nil;

		local func = nil
		local openSupply = false;
		local openStore = false;
		local openPreview = false;

		openSupply = SupplyMainUI.bShow == true;--UIManager.GetUI(eUIType.eSupplyMainUI) ~= nil;
		openStore = StoreMainUI.bShow == true;--UIManager.GetUI(eUIType.eStoreMainUI) ~= nil;
		openPreview = StorePreviewUI.bShow == true;--UIManager.GetUI(eUIType.eStorePreviewPage) ~= nil;

		if openSupply then
			SupplyMainUI.UIOnlyHideAll();
		end
		if openStore then
			StoreMainUI.UIOnlyHideAll();
		end
		if openPreview then
			StorePreviewUI.UIOnlyHideAll();
		end

		if openSupply then
			ModelDisplayer.Store(ModelDisplayer.KEY_SUPPLY_MAIN_UI);
			ModelDisplayer.Destroy();
		elseif openStore then
			ModelDisplayer.Store(ModelDisplayer.KEY_STORE_MAIN_UI);
			ModelDisplayer.Destroy();
		elseif openPreview then
			ModelDisplayer.Store(ModelDisplayer.KEY_STORE_PREVIEW_UI);
			ModelDisplayer.Destroy();
		end

		func = function()
			if openStore then
				if openSupply then
					SupplyMainUI.UIOnlyShowAll();
				else
					StoreMainUI.UIOnlyShowAll();
				end
			else
				if openSupply then
					SupplyMainUI.UIOnlyShowAll();
				end
			end
			if openPreview then
				StoreMainUI.UIOnlyShowAll();
				StoreMainUI.UIOnlyHide(true);
				StorePreviewUI.UIOnlyShowAll();
			end

			if openSupply then
				ModelDisplayer.Init();
				ModelDisplayer.Restore(ModelDisplayer.KEY_SUPPLY_MAIN_UI);
			elseif openStore then
				ModelDisplayer.Init();
				ModelDisplayer.Restore(ModelDisplayer.KEY_STORE_MAIN_UI);
			elseif openPreview then
				ModelDisplayer.Init();
				ModelDisplayer.Restore(ModelDisplayer.KEY_STORE_PREVIEW_UI);
			end
			--JumpUtils.JumpAllByToModelId(JumpUtils.MODEL_ID_LOBBY, itemID, JumpUtils.MODEL_ID_SUPPLY);
		end
		if func ~= nil then
			ItemUpgradeUI.SetCloseCallBack(func);
		end
		local UpgradeItemShowID = itemID;

		--if UIManager.GetUI(eUIType.eStorePreviewPage) ~= nil then
		--	StorePreviewUI.ForceClose();
		--end
		--EventStartCloseMallSystem();
		--ItemUpgradeUI.jumpViewCloseCallBack = nil;
		--SupplyMainUI.CloseUI();
		--StoreMainUI.CloseUI();
		store_item_upgrade_system.HideAnimation()

		ItemUpgradeUI.ShowByItemID(UpgradeItemShowID);
	end
end

function StoreFuncUtils.IsPetItemID(itemID)
	local itemCfg = Client.GetTableData("Item", itemID);
	if itemCfg ~= nil then
		return itemCfg.ItemType == 500;
	end
	return false;
end

function StoreFuncUtils.IsParachuteItemID(itemID)
	local itemCfg = Client.GetTableData("Item", itemID);
	if itemCfg ~= nil then
		return itemCfg.ItemType == 4 and itemCfg.ItemSubType == 701;
	end
	return false;
end

function StoreFuncUtils.OnClickJumpToPetMain()
	if UIManager.GetUI(eUIType.eStoreMainUI) then
		StoreMainUI.CloseUI();
	end
	if UIManager.GetUI(eUIType.eSupplyMainUI) then
		SupplyMainUI.CloseUI();
	end

	local ui_manager = require("ui.manager");
	if ui_manager then
		ui_manager.ShowUI(ui_manager.UI_Config.pet_main);
	end
end

function StoreFuncUtils.CheckIsChest(itemID)
	local itemCfg = Client.GetTableData("Item", itemID);
	if itemCfg ~= nil then
		return itemCfg.ItemType == 15 and itemCfg.ItemSubType == 1503;
	end
	return false;
end

function StoreFuncUtils.IsWeapon(itemID)
	local itemCfg = Client.GetTableData("Item", itemID);
	if itemCfg ~= nil then
		return itemCfg.ItemType == 1;
	end
	return false;
end

function StoreFuncUtils.PurchaseItem(ShopInfo, selectedMoneyType)
	local BuyInfo = StoreFuncUtils.GetBuyInfo(ShopInfo.id);
	local cfg = Client.GetTableData("Item", ShopInfo.item_id);

	if StoreFuncUtils.IsWithCount(cfg.ItemType) then
		MallBuyItemWithCountUI:Init();
		MallBuyItemWithCountUI.SetData(ShopInfo, BuyInfo, nil, nil, StoreSystem.store_version);
	else
		StoreBuyUI:Init();
		StoreBuyUI.SetData(ShopInfo, BuyInfo, nil, nil, StoreSystem.store_version, selectedMoneyType);
	end
end

function StoreFuncUtils.SendGift(ShopInfo)
	local data = ShopInfo;
	local resItem = Client.GetTableData("Item", data.item_id);
	local moneyType, moneyPrice = StoreFuncUtils.get_money_type_and_price(data.id, 1, data);

	local itemBuyInfo = StoreFuncUtils.GetBuyInfo(ShopInfo.id);
	-- 购买数量
	local buyNum = 1000000;
	local limitType = 1;
	if (ShopInfo.daily_buy_limit > 0 or ShopInfo.week_buy_limit > 0 or ShopInfo.permanet_buy_limit > 0) then
		if itemBuyInfo ~= nil then
			if (ShopInfo.daily_buy_limit > 0) then
				buyNum = math.min(buyNum, ShopInfo.daily_buy_limit - itemBuyInfo.daily_buy_cnt);
				limitType = 1;
			end
			if (ShopInfo.week_buy_limit > 0) then
				buyNum = math.min(buyNum, ShopInfo.week_buy_limit - itemBuyInfo.week_buy_cnt);
				limitType = 2;
			end
			if (ShopInfo.permanet_buy_limit > 0) then
				buyNum = math.min(buyNum, ShopInfo.permanet_buy_limit - itemBuyInfo.permanet_buy_cnt);
				limitType = 3;
			end
		end
	end

	if buyNum <= 0 then
		local tips = FuncUtil.GetLocalizeResStr(6654);
		PopUpNoticeUI.ShowNewNotice(tips);
		return;
	end

	local name = FuncUtil.GetItemName(resItem.ItemName, nil, nil);
	local Info = {};
	Info.data = data
	Info.name = name;
	Info.colorID = 0;
	Info.patternID = 0;
	Info.colorPatternCost = 0;
	Info.money_type = StoreFuncUtils.MoneyTypeToChinaMoneyType(moneyType);

	ShopGiftWithDayUI.ShowWithData(Info);
end

function StoreFuncUtils.GetDiscountTimePeriodStr(startTime, endTime)
	local startDate = os.date("!*t", startTime);
	local endDate = os.date("!*t", endTime);

	local startTimeStr = string.format("%d.%d", startDate.month, startDate.day);
	local endTimeStr = string.format("%d.%d", endDate.month, endDate.day);
	local timeStr = string.format("%s-%s", startTimeStr, endTimeStr);

	return FuncUtil.LocalizeResFormat("6732", timeStr);
end

-- vip》折扣》热卖
function StoreFuncUtils.GetItemLeftTopTagsQueue(tagDisCount, tagHot, tagVip)
	tagDisCount = tagDisCount or false;
	tagHot = tagHot or false;
	tagVip = tagVip or false;
	if NewSubscribeSystem.GetIsPrimeOpen() == false then
		tagVip = false;
	end
	if tagVip then
		return false, false, true;
	end
	if tagDisCount then
		return true, false, false;
	end
	if tagHot then
		return false, true, false;
	end
	return false, false, false;
end

-- 特殊图标》NEW
function StoreFuncUtils.GetItemRightTopTagsQueue(tagNew, tagSpecialIcon)
	tagNew = tagNew or false;
	tagSpecialIcon = tagSpecialIcon or false;
	if tagSpecialIcon then
		return false, true;
	end
	if tagNew then
		return true, false;
	end
	return false, false;
end

function StoreFuncUtils.CheckIsHot(data)
	local startTime = data[StoreSystem.label_item_index_hot_begin] or 0;
	if startTime == 0 then
		startTime = data[StoreSystem.label_item_index_start_time];
	end
	local endTime = data[StoreSystem.label_item_index_hot_end] or 0;
	if endTime == 0 then
		endTime = data[StoreSystem.label_item_index_time_limit];
	end
	local serverTime = FuncUtil.GetServerTimeInSec();
	return data[StoreSystem.label_item_index_hot_or_new] ~= 0 and
			serverTime >= startTime and
			serverTime < endTime;
end

function StoreFuncUtils.CheckIsNew(data)
	--log_tree("StoreFuncUtils.CheckIsNew", data);
	local isNew = data[StoreSystem.label_item_index_show_new] or 0;
	local marketId = data[StoreSystem.label_item_index_market_id] or 0;
	local startTime = data[StoreSystem.label_item_index_start_time] or 0
	if isNew == 1 and StoreSystem.CheckHasRecordNewTag(marketId) == false and startTime ~= 0 and FuncUtil.GetServerTimeInSec() - startTime < StoreFuncUtils.NewFlagAvailableTime then
		return true;
	end
	return false;
end

function StoreFuncUtils.CheckNeedShowSaleEndTime(data)
	local showSaleEndTimeHour = data[StoreSystem.label_item_index_cout_down_time] or 0;
	local saleEndTime = data[StoreSystem.label_item_index_time_limit] or 0;
	if data[StoreSystem.label_item_index_show_time_limit] == 1 then
		if showSaleEndTimeHour == 0 or FuncUtil.GetServerTimeInSec() >= saleEndTime - showSaleEndTimeHour * 3600 and FuncUtil.GetServerTimeInSec() < saleEndTime then
			return true;
		else
			return false;
		end
	else
		return false;
	end
end

function StoreFuncUtils.GetMonthDayStr(time)
	return os.date(FuncUtil.GetLocalizeResStr(410058), time)
end

function StoreFuncUtils.CalculateLowestByCurrency(price)
	--log_tree("[HHF]StoreFuncUtils.CalculateLowestByCurrency, price = ", price, "[HHF]");
	local currency = {};
	for i, v in ipairs(price) do
		if #currency == 0 or currency[#currency] ~= v.currency then
			table.insert(currency, v.currency);
		end
	end

	local priceTypeList = {
		StoreSystem.label_price_type_bp,
		StoreSystem.label_price_type_chip,
		StoreSystem.label_price_type_uc,
		StoreSystem.label_price_type_fp,
		StoreSystem.label_price_type_exchage,
		StoreSystem.label_price_type_gold_chip,
	};
	for i, v in ipairs(priceTypeList) do
		local isExist = false;
		for ii, vv in ipairs(currency) do
			if v == vv then
				isExist = true;
				break;
			end
		end
		if not isExist then
			table.insert(currency, v);
		end
	end
	--log_tree("[edward][bp_store_clothes] priceTypeList", currency);

	local result = {};
	for i, v in ipairs(currency) do
		local lowest = {};
		lowest.currency = v;
		lowest.price = 0;
		lowest.original = 0;
		for ii, vv in ipairs(price) do
			if vv.currency == lowest.currency then
				if lowest.price == 0 then
					lowest.price = vv.original;
					lowest.original = vv.original;
					if vv.discount > 0 then
						lowest.price = vv.discount;
					end
				else
					if vv.discount > 0 then
						if vv.discount < lowest.price then
							lowest.price = vv.discount;
							lowest.original = vv.original;
						end
					else
						if vv.original < lowest.price then
							lowest.price = vv.original;
							lowest.original = vv.original;
						end
					end
				end
			end
		end
		table.insert(result, lowest);
	end
	--log_tree("[HHF]StoreClothesUI.CalculateLowestByCurrency, result = ", result, "[HHF]");
	return result;
end

function StoreFuncUtils.GetTwoValidPriceForShow(price)
	local currency = {};
	table.insert(currency, StoreSystem.label_price_type_bp);
	table.insert(currency, StoreSystem.label_price_type_chip);
	table.insert(currency, StoreSystem.label_price_type_uc);
	table.insert(currency, StoreSystem.label_price_type_fp);
	table.insert(currency, StoreSystem.label_price_type_exchage);
	table.insert(currency, StoreSystem.label_price_type_gold_chip);

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

function StoreFuncUtils.GetDiscountTimePeriodStr(startTime, endTime)
	local startDate = os.date("!*t", startTime);
	local endDate = os.date("!*t", endTime);

	local startTimeStr = string.format("%d.%d", startDate.month, startDate.day);
	local endTimeStr = string.format("%d.%d", endDate.month, endDate.day);
	local timeStr = string.format("%s-%s", startTimeStr, endTimeStr);

	return FuncUtil.LocalizeResFormat("6732", timeStr);
end

function StoreFuncUtils.IsValidPrice(vipFlag, priceType)
	if not NewSubscribeSystem.GetIsPrimeOpen() and vipFlag == 1 and priceType == StoreSystem.label_price_type_bp then
		return false;
	end
	return true;
end

function StoreFuncUtils.SortPriceListByType(a, b, priceListKey, priceType)
	local idx_a, idx_b;
	for i, v in ipairs(a[priceListKey]) do
		if v.currency == priceType then
			idx_a = i;
			break;
		end
	end
	for i, v in ipairs(b[priceListKey]) do
		if v.currency == priceType then
			idx_b = i;
			break;
		end
	end
	if a[priceListKey][idx_a].price == b[priceListKey][idx_b].price then
		return StoreFuncUtils.DefaultSortAlgorithm(a, b);
	else
		if a[priceListKey][idx_a].price == 0 then
			return false;
		elseif b[priceListKey][idx_b].price == 0 then
			return true;
		else
			return a[priceListKey][idx_a].price < b[priceListKey][idx_b].price;
		end
	end
end

function StoreFuncUtils.DefaultSortAlgorithm(a, b)
	if a.item_have == b.item_have then
		if a.item_sort == b.item_sort then
			--if a.item_new == b.item_new then
			if a.item_startTime == b.item_startTime then
				if a.discount_for_sort == b.discount_for_sort then
					if a.item_hot == b.item_hot then
						if a.item_quality == b.item_quality then
							return a.item_shopID > b.item_shopID;
						else
							return a.item_quality > b.item_quality;
						end
					else
						return a.item_hot or (not b.item_hot);
					end
				else
					return a.discount_for_sort > b.discount_for_sort;
				end
			else
				return a.item_startTime > b.item_startTime;
			end
			--else
			--	return a.item_new or (not b.item_new);
			--end
		else
			return a.item_sort > b.item_sort;
		end
	else
		return b.item_have;
	end
end

-- 显示商城已显示的二级窗口
function StoreFuncUtils.HideVisibleDialog()
	if UIManager.GetUI(eUIType.eStoreBuy) then
		StoreBuyUI:Release()
	end
	if UIManager.GetUI(eUIType.eShopGiftWithDay) then
		EventShopGiftWithDayUIClickClose()
	end
	if UIManager.GetUI(eUIType.eMallBuyWithCount) then
		MallBuyItemWithCountUI:Release()
	end
	if UIManager.GetUI(eUIType.eStoreBindPhone) then
		EventStoreBindPhone_Close()
	end
	if UIManager.GetUI(eUIType.eRechargeUI) then
		LuaClassObj.HandleUIMessageNoFetch(bp_recharge, "UIHIde")
	end
    if UIManager.GetUI(eUIType.eStoreChestPage) then
        StoreChestUI.Hide()
    end
	if UIManager.GetUI(eUIType.eStorePriceSelect) then
		StorePriceSelect_UI.Hide()
	end
	if UnknowPassLevelUp.isShowing then
		UnknowPassLevelUp.HideUI();
	end
	if Rate_Panel_UI.isShow then
		Rate_Panel_UI.Hide()
	end
	if OpenBoxtUI.isShow == true then
		OpenBoxtUI.Close()
	end
	local ui_manager = require("ui.manager");
	if ui_manager.IsUIShow(ui_manager.UI_Config.ui_subscribe) then
		ui_manager.CloseUI(ui_manager.UI_Config.ui_subscribe);
	end
	if ui_manager.IsUIShow(ui_manager.UI_Config.ui_subscribe_buy) then
		ui_manager.CloseUI(ui_manager.UI_Config.ui_subscribe_buy);
	end
    CommonMessageBoxUI:HideAllMessageBox()
end