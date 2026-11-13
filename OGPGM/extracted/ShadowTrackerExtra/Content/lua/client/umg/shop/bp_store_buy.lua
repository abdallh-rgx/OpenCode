--商城物品购买
StoreBuyUI = StoreBuyUI or {
	isShowing = false
}

-- 限时信息
BP_ARRAY_Valid_Time_Info = {
	Time = "",
}
-- 价格信息
BP_ARRAY_Price = {
	price = 0,-- 物品价格
}
BP_STRUCT_Price_Info = {
	-- 类型0是BP 2是UC
	priceType = 0,-- 货币类型
	BP_ARRAY_Price = _G.BP_ARRAY_Price,
	BP_ARRAY_Valid_Time_Info = _G.BP_ARRAY_Valid_Time_Info,
}
BP_ARRAY_Price_Info = {
	BP_STRUCT_Price_Info = _G.BP_STRUCT_Price_Info
}
-- 商品物品结构
BP_STRUCT_Buy_Item2_Info = {
	shopID = 0,-- shopID
	itemID = 0,-- 物品ID
	count = 0,-- 物品数量
	quality = 0,-- 物品品质
	itemName = "",-- 物品名称

	BP_ARRAY_Price_Info = _G.BP_ARRAY_Price_Info,-- 价格信息
	--BP_ARRAY_Valid_Time_Info = _G.BP_ARRAY_Valid_Time_Info,-- 限时信息

	isGet = false,-- 是否拥有
	limitNum = 0,-- 限购次数
	limitType = 1,-- 限购类型
	isCanSend = false,-- 是否能赠送
	colorID = 0,
	patternID = 0,

	isVipItem = false,	--是否是订阅会员商品
}

BP_ARRAY_Single_Buy_List2 = {
	BP_STRUCT_Buy_Item2_Info = _G.BP_STRUCT_Buy_Item2_Info,--定义结构体数组，这种写法要作为规范规定下来
}

BP_Select_Money_Type = 0
BP_Select_Money_Price_Idx = 0
BP_Cur_Money_BP = 0
BP_Cur_Money_SF = 0
BP_Cur_Money_UC = 0
BP_Cur_Money_GoldChip = 0

BP_STRUCT_COUPON_DATA_single = 
{
	ID = 0,
	discount = 0,
	describe = "",
}

BP_ARRAY_COUPON_DATA_single= 	--代金券数据
{
	BP_STRUCT_COUPON_DATA_single = _G.BP_STRUCT_COUPON_DATA_single
}

BP_ARRAY_COUPON_Describe_DATA_single= 	--代金券描述数据
{
	describe = ""
}

BP_CurrentCouponId = 0		--当前代金券的ID	会在蓝图里随点击切换变动
BP_IsShowCoupon = false		--是否可用代金券
BP_CurrentDisCount = 0		--当前代金券的抵扣价值	会在蓝图里随点击切换变动

BP_Store_Buy_CurSubscribeStatus = 0;	--当前订阅会员状态

local curBuyInfo = nil
local curShopInfo = nil
local curInfo = nil
local curVersion = nil
local firstMoneyType = 0
local ValidMoneyType = {
	[0] = true,
	[1] = true,
	[2] = true,
	[103] = true,
}

--注册Widget
function bp_store_buy_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_store_buy,
	{{Path="/Game/UMG/UI_Logic/Lobby_Store/Store_2/Store_Buy_BP.Store_Buy_BP_C", Container="Default", ZOrder=BP_ENUM_UI_RECHARGE_ZORDER},
	},
	{"Lobby"},
	false,
	true
	)

end

function bp_store_buy_OnModeSwitched(gamestatus)
	log("bp_store_buy_OnModeSwitched gamestatus = " .. gamestatus)
	gamestatus = string.lower(gamestatus)
	if gamestatus == "lobby" then
		if StoreBuyUI.isShowing == true then
			--hide
			LuaClassObj.HandleUIMessage(bp_store_buy, "UIHide")
			StoreBuyUI:Release()
		end

		StoreBuyUI.isShowing = false
	end

	-- 回到登录场景清数据
	if string.lower(gamestatus) == "login" then
		StoreBuyUI:ReleaseData()
	end

end

--@return string
function StoreBuyUI.GetValidTimeByHour(hour)
	local str = ""
	if hour == nil or hour < 0 then
		return str
	end
	if hour == 0 then
		str = FuncUtil.GetLocalizeResStr(501059)
		return str
	end
	local days = math.floor(hour / 24)

	if days > 0 then
		str = FuncUtil.LocalizeResFormat("301153", days)
	end

	return str
end
 
function EventStoreBuyItemHide()
	StoreBuyUI.isShowing = false
end

function StoreBuyUI:Init()
	if StoreBuyUI.isShowing then
		return
	end

	log("StoreBuyUI Init")
	StoreBuyUI.isShowing = true

	BP_Cur_Money_BP = DataMgr.gold;
	BP_Cur_Money_SF = DataMgr.diamond;
	BP_Cur_Money_UC = DataMgr.ticket;
	BP_Cur_Money_GoldChip = DataMgr.gold_chip;

	LuaClassObj.HandleDynamicCreation(bp_store_buy)
	LuaClassObj.HandleUIMessage(bp_store_buy, "UIShow")
	UIManager.Show(eUIType.eStoreBuy)

	BP_Select_Money_Type = 0
	BP_Select_Money_Price_Idx = 0

	BP_Store_Buy_CurSubscribeStatus = NewSubscribeSystem.GetSubStatus();
end

local function IsValidMoneyType(type)
	return ValidMoneyType[type]
end

function StoreBuyUI.SetData(shopInfo, buyInfo, colorID, patternID, version, selectedMoneyType)
	log("StoreBuyUI.SetData")	log_tree("shopInfo",shopInfo)
	log_tree("buyInfo",buyInfo)
	BP_Select_Money_Type = 0
	BP_Select_Money_Price_Idx = 0
	local data = shopInfo
	local resItem = Client.GetTableData("Item", data.item_id)
	local isGet = false
	local colorPatternCost = 0
	if StoreSystem.IsUseNewStore() then
		isGet = StoreFuncUtils.HasItem(data.item_id, colorID, patternID)
		colorPatternCost = 0
	else
		isGet = MallSystemUI_2.IsHasItem(data.item_id, colorID, patternID)
		colorPatternCost = MallSystemUI_2.get_color_and_pattern_cost(colorID, patternID)
	end
	curVersion = version

	-- 购买数量
	local itemBuyInfo = buyInfo
	local buyNum = 1000000
	local limitType = 1
	if (shopInfo.daily_buy_limit > 0 or shopInfo.week_buy_limit > 0 or shopInfo.permanet_buy_limit > 0) then
		if itemBuyInfo ~= nil then
			if (shopInfo.daily_buy_limit > 0) then
				buyNum = math.min(buyNum, shopInfo.daily_buy_limit - itemBuyInfo.daily_buy_cnt)
				limitType = 1
			end
			if (shopInfo.week_buy_limit > 0) then
				buyNum = math.min(buyNum, shopInfo.week_buy_limit - itemBuyInfo.week_buy_cnt)
				limitType = 2
			end
			if (shopInfo.permanet_buy_limit > 0) then
				buyNum = math.min(buyNum, shopInfo.permanet_buy_limit - itemBuyInfo.permanet_buy_cnt)
				limitType = 3
			end
		end
	end
	local limitCount = buyNum

	-- 价格信息
	local PriceInfo = {}
	local priceIdx = 1
	for i = 1, 2 do
		local moneyType = -1
		local moneyPrice
		local moneyTypeIdx = i
		local Price = {}
		local ValidTime = {}

		local HasThisType = false
		for j = 1, 3 do
			local time_valid_index = j
			moneyType, moneyPrice = StoreFuncUtils.get_money_type_and_price(data.id, moneyTypeIdx, data, time_valid_index)
			if IsValidMoneyType(moneyType) and moneyPrice ~= 0 and StoreFuncUtils.IsValidPrice(data.is_vip_item, moneyType) then
				table.insert(Price, moneyPrice + colorPatternCost)
				if moneyTypeIdx == 1 then
					table.insert(ValidTime, StoreBuyUI.GetValidTimeByHour(data["valid_hours" .. time_valid_index]));
				else
					table.insert(ValidTime, StoreBuyUI.GetValidTimeByHour(data["valid2_hours" .. time_valid_index]));
				end
				HasThisType = true
			end
		end

		if HasThisType then
			PriceInfo[priceIdx] = { priceType = moneyType,BP_ARRAY_Price = Price, BP_ARRAY_Valid_Time_Info = ValidTime };
			priceIdx = priceIdx + 1;
		end
	end

	firstMoneyType = data.money1_type
	BP_Select_Money_Type = selectedMoneyType or firstMoneyType

	local isValidType = false;
	for i, v in ipairs(PriceInfo) do
		if BP_Select_Money_Type == v.priceType then
			isValidType = true;
			break;
		end
	end
	if not isValidType then
		BP_Select_Money_Type = PriceInfo[1].priceType
	end

	local tempBuyInfo = {
		shopID = data.id,
		itemID = data.item_id,
		count = data.item_count,
		quality = resItem.ItemQuality,
		itemName = resItem.ItemName,
		BP_ARRAY_Price_Info = PriceInfo,
		--BP_ARRAY_Valid_Time_Info = validTimeInfo,

		isGet = isGet,
		limitNum = limitCount,
		limitType = limitType,
		isCanSend = data.gift_open == 1,
		colorID = colorID or 0,
		patternID = patternID or 0,

		isVipItem = data.is_vip_item == 1,
	}

	BP_ARRAY_Single_Buy_List2 = { tempBuyInfo }
	curBuyInfo = buyInfo
	curShopInfo = shopInfo
	curInfo = tempBuyInfo

	StoreBuyUI.InitCoupons()
	BP_IsShowCoupon = CouponsSystem.IsCouPonsShopItem(data.id)

	if BP_IsShowCoupon then	--有代金券要显示... 	
		BP_ARRAY_COUPON_DATA_single = CouponsSystem.Get_Cur_Coupon_CouldUse_List(data.id)
		BP_ARRAY_COUPON_Describe_DATA_single = {}
		for i,v in pairs(BP_ARRAY_COUPON_DATA_single) do 
			table.insert(BP_ARRAY_COUPON_Describe_DATA_single,v.describe)
		end
		BP_CurrentDisCount = BP_ARRAY_COUPON_DATA_single[#BP_ARRAY_COUPON_DATA_single].discount	--初始化代金券折扣价格
		BP_CurrentCouponId = BP_ARRAY_COUPON_DATA_single[#BP_ARRAY_COUPON_DATA_single].ID			--初始化代金券ID
	end
	log("BP_CurrentDisCount " .. tostring(BP_CurrentDisCount))
	log_tree("BP_ARRAY_COUPON_DATA_single",BP_ARRAY_COUPON_DATA_single)
	LuaClassObj.HandleUIMessage(bp_store_buy, "LuaSetData")
end

function StoreBuyUI:Release()
	UIManager.Hide(eUIType.eStoreBuy)
	LuaClassObj.HandleUIMessage(bp_store_buy, "UIHide")
	StoreBuyUI:ReleaseData()
end

function StoreBuyUI:ReleaseData()
	StoreBuyUI.isShowing = false

	BP_ARRAY_Single_Buy_List2 = {}

	BP_Select_Money_Type = 0
	BP_Select_Money_Price_Idx = 0
end

function EventStoreSingleBuy()
	log("EventStoreSingleBuy")
	log("BP_Select_Money_Type: " .. tostring(BP_Select_Money_Type))
	if 1 > curInfo.limitNum then
		if curInfo.limitType == 1 then
			DataMgr.ShowNoticeByID(4350)
		elseif curInfo.limitType == 2 then
			DataMgr.ShowNoticeByID(4351)
		elseif curInfo.limitType == 3 then
			DataMgr.ShowNoticeByID(4352)
		end
		return
	end

	local firstMoney = 1
	if BP_Select_Money_Type ~= firstMoneyType then
		firstMoney = 2
	end

	if StoreSystem.IsUseNewStore() then
		local checkMoney = false
		local moneyId = 1
		for k,v in pairs(BP_ARRAY_Single_Buy_List2[1].BP_ARRAY_Price_Info) do
			if v.priceType == BP_Select_Money_Type then
				moneyId = k
				break
			end
		end
		
		local Price = BP_ARRAY_Single_Buy_List2[1].BP_ARRAY_Price_Info[moneyId].BP_ARRAY_Price[BP_Select_Money_Price_Idx + 1]
		local PriceList = { { Type = BP_Select_Money_Type,
							  Price = Price,
							  Num = 1 },}
		if BP_CurrentCouponId > 0 then	--有代金券使用	价格
			local couponDiscountPrice = CouponsSystem.GetDisCountValueByID(BP_CurrentCouponId)
			if couponDiscountPrice > 0 then
				checkMoney = StoreFuncUtils.CheckMoney(PriceList,couponDiscountPrice)
			end
		else
			checkMoney = StoreFuncUtils.CheckMoney(PriceList)
		end
		if checkMoney then
			local data = StoreBuyUI.ConvertToNewPurchaseProto()
			log_tree("[edward][bp_store_buy] data", data);
			StoreSystem.buy_market_by_id_req(data)
		end
	else
		local dict = {}
		table.insert(dict, { id = curInfo.shopID,
							 num = 1,
							 shopInfo = curShopInfo,
							 buyInfo = curBuyInfo,
							 colorID = curInfo.colorID,
							 patternID = curInfo.patternID,
							 time_valid_index = BP_Select_Money_Price_Idx + 1,
							 first_money = firstMoney,})
		MallSystemUI_2.BuyShopItems2(dict, curVersion)
	end
	StoreBuyUI:Release()
end

function StoreBuyUI.ConvertToNewPurchaseProto()
	log("BP_CurrentCouponId: " .. tostring(BP_CurrentCouponId))
	local validHours
	if BP_Select_Money_Type == firstMoneyType then
		validHours = {
			curShopInfo.valid_hours1,
			curShopInfo.valid_hours2,
			curShopInfo.valid_hours3,
		}
	else
		validHours = {
			curShopInfo.valid2_hours1,
			curShopInfo.valid2_hours2,
			curShopInfo.valid2_hours3,
		}
	end

	local Data = {}
	Data[StoreSystem.label_buy_param_id] = curShopInfo.id
	Data[StoreSystem.label_buy_param_price_type] = BP_Select_Money_Type
	Data[StoreSystem.label_buy_param_tab_id] = curShopInfo.tab_id
	Data[StoreSystem.label_buy_param_sub_id] = curShopInfo.sub_id
	Data[StoreSystem.label_buy_param_ver] = StoreSystem.store_version
	Data[StoreSystem.label_buy_param_valid_hours] = validHours[BP_Select_Money_Price_Idx + 1]
	Data[StoreSystem.label_buy_param_count] = 1
	if BP_CurrentCouponId > 0 then
		Data[StoreSystem.label_buy_param_voucher] = BP_CurrentCouponId
	end
	return Data


end

function StoreBuyUI.InitCoupons()
	-- body
	log("StoreBuyUI.InitCoupons")
	BP_CurrentCouponId = 0		--当前代金券的ID	会在蓝图里随点击切换变动
	BP_IsShowCoupon = false		--是否可用代金券
	BP_CurrentDisCount = 0		--当前代金券的抵扣价值索引	会在蓝图里随点击切换变动
end

function EventStoreJumpToSubscribe()
	local function JumpToSubscribe()
		log("[edward][bp_store_buy] EvnetStoreJumpToSubscribe");
		if not NewSubscribeSystem.GetIsPrimeOpen() then
			return;
		end
		StoreBuyUI.Release();
		EventSystem:postEvent(EVENTTYPE_URL, BP_ENUM_MODULE_PRIME);
	end

	local title = Client.GetTableData("LocalizeRes", "101001").TextValue;
	local tip = Client.GetTableData("LocalizeRes", "6729").TextValue;
	CommonMessageBoxUI:ShowPanel(2, title, tip, JumpToSubscribe);
end
