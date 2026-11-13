--商城物品购买 带数量
MallBuyItemWithCountUI =
    MallBuyItemWithCountUI or
    {
        isShowing = false
    }

-- 商品物品结构
BP_STRUCT_Buy_Item_Info = {
    shopID = 0, -- shopID
    itemID = 0, -- 物品ID
    count = 0, -- 物品数量
    quality = 0, -- 物品品质
    itemName = "", -- 物品名称
    priceType = 0, -- 货币类型
    price = 0, -- 原始价格
    isGet = false, -- 是否拥有
    limitNum = 0, --限购次数
    limitType = 1, --限购类型
    isCanSend = false, -- 是否能赠送
    colorID = 0, --颜色方案
    patternID = 0, --图案方案
    priceType2 = 0, -- 第二货币类型
    price2 = 0,     -- 第二货币价格
}

BP_ARRAY_COUPON_DESCRIBE_DATA = { --代金券描述数据
    describe = ""
}
BP_STRUCT_COUPON_DATA_single_withcount = {
    ID = 0,
    discount = 0,
    describe = ""
}

BP_ARRAY_COUPON_DATA = { --代金券数据
    BP_STRUCT_COUPON_DATA_single_withcount = _G.BP_STRUCT_COUPON_DATA_single_withcount
}
-- 商品列表
BP_ARRAY_Single_Buy_Count_List = {
    BP_STRUCT_Buy_Item_Info = _G.BP_STRUCT_Buy_Item_Info --定义结构体数组，这种写法要作为规范规定下来
}

BP_Count_Buy_Cur_Num = 0

BP_Count_Buy_MONEY_NUM = 0
BP_Count_Buy_MONEY_1_NUM = 0
BP_Count_Buy_DIAMOND_NUM = 0
BP_Count_Buy_GOLD_CHIP_NUM = 0

BP_CurrentCouponID_WithCount = 0 --当前代金券ID	会在蓝图里随点击切换变动
BP_IsShowCoupon_WithCount = false --是否可用代金券
BP_CurrentDisCount_WithCount = 0 --当前代金券的抵扣价值索引	会在蓝图里随点击切换变动

local curBuyInfo = nil
local curShopInfo = nil
local curInfo = nil
local curVersion = nil

--注册Widget
function bp_mall_buy_item_with_count_RegisterUI()
    LuaClassObj.SubUIWidgetList(
        bp_mall_buy_item_with_count,
        {
            {
                Path = "/Game/UMG/UI_Logic/Lobby_Store/Mall_Buy_Item_With_Count_BP.Mall_Buy_Item_With_Count_BP_C",
                Container = "Default",
                ZOrder = BP_ENUM_UI_RECHARGE_ZORDER
            }
        },
        {"Lobby"},
        false,
        true
    )
end

function bp_mall_buy_item_with_count_OnModeSwitched(gamestatus)
    log("bp_mall_buy_item_with_count_OnModeSwitched gamestatus = " .. gamestatus)
    status = string.lower(gamestatus)
    if status == "lobby" then
        if MallBuyItemWithCountUI.isShowing == true then
            --hide
            UIManager.Hide(eUIType.eMallBuyWithCount)
            LuaClassObj.HandleUIMessage(bp_mall_buy_item_with_count, "UIHide")
            MallBuyItemWithCountUI:Release()
        end

        MallBuyItemWithCountUI.isShowing = false
    end

    -- 回到登录场景清数据
    if string.lower(gamestatus) == "login" then
        MallBuyItemWithCountUI:ReleaseData()
    end
end

function EventMallBuyItemWithCountHide()
    MallBuyItemWithCountUI.isShowing = false
end

function MallBuyItemWithCountUI:Init()
    if MallBuyItemWithCountUI.isShowing then
        return
    end

    log("MallBuyItemWithCountUI Init")
    MallBuyItemWithCountUI.isShowing = true

    LuaClassObj.HandleDynamicCreation(bp_mall_buy_item_with_count)
    LuaClassObj.HandleUIMessage(bp_mall_buy_item_with_count, "UIShow")
    UIManager.Show(eUIType.eMallBuyWithCount)

    BP_Count_Buy_MONEY_NUM = DataMgr.gold
    BP_Count_Buy_MONEY_1_NUM = DataMgr.diamond
    BP_Count_Buy_DIAMOND_NUM = DataMgr.ticket
    BP_Count_Buy_GOLD_CHIP_NUM = DataMgr.gold_chip
    LuaClassObj.HandleUIMessage(bp_mall_buy_item_with_count, "SetMoney")
end

function MallBuyItemWithCountUI:Release()
    UIManager.Hide(eUIType.eMallBuyWithCount)
    LuaClassObj.HandleUIMessage(bp_mall_buy_item_with_count, "UIHide")
    MallBuyItemWithCountUI:ReleaseData()
end

function EventSetInfo_Push()
end

function EventFetchInfo()
end

function MallBuyItemWithCountUI:ReleaseData()
end

function MallBuyItemWithCountUI.SetData(shopInfo, buyInfo, colorID, patternID, version)
    --og_tree("shopInfo",shopInfo)
    --log_tree("buyInfo",buyInfo)
    --log(debug.traceback())
    local data = shopInfo
    local resItem = Client.GetTableData("Item", data.item_id)
    local isGet = false
    local moneyType = 0
    local moneyPrice = 0
    local colorPatternCost = 0
    if StoreSystem.IsUseNewStore() then
        isGet = StoreFuncUtils.HasItem(data.item_id, colorID, patternID)
        moneyType, moneyPrice = StoreFuncUtils.get_money_type_and_price(data.id, 1, data)
        colorPatternCost = 0
    else
        isGet = MallSystemUI_2.IsHasItem(data.item_id, colorID, patternID)
        moneyType, moneyPrice = MallSystemUI_2.get_money_type_and_price(data.id, 1, data)
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
    local limitType = limitType

    local tempBuyInfo = {
        shopID = data.id,
        itemID = data.item_id,
        count = data.item_count,
        quality = resItem.ItemQuality,
        itemName = resItem.ItemName,
        priceType = moneyType,
        price = moneyPrice + colorPatternCost,
        isGet = isGet,
        limitNum = limitCount,
        limitType = limitType,
        isCanSend = data.gift_open == 1,
        colorID = colorID or 0,
        patternID = patternID or 0
    }

    curBuyInfo = buyInfo
    curShopInfo = shopInfo
    curInfo = tempBuyInfo

    BP_ARRAY_Single_Buy_Count_List = {tempBuyInfo}

    MallBuyItemWithCountUI.InitCoupons()
    BP_IsShowCoupon_WithCount = CouponsSystem.IsCouPonsShopItem(data.id)
    if BP_IsShowCoupon_WithCount then
		BP_ARRAY_COUPON_DATA = CouponsSystem.Get_Cur_Coupon_CouldUse_List(data.id)
		BP_ARRAY_COUPON_DESCRIBE_DATA = {}
        for i, v in pairs(BP_ARRAY_COUPON_DATA) do
            table.insert(BP_ARRAY_COUPON_DESCRIBE_DATA, v.describe)
        end
        BP_CurrentDisCount_WithCount = BP_ARRAY_COUPON_DATA[#BP_ARRAY_COUPON_DATA].discount
        BP_CurrentCouponID_WithCount = BP_ARRAY_COUPON_DATA[#BP_ARRAY_COUPON_DATA].ID --初始化代金券ID
    end
	log_tree("BP_ARRAY_COUPON_DATA",BP_ARRAY_COUPON_DATA)
    LuaClassObj.HandleUIMessage(bp_mall_buy_item_with_count, "LuaSetData")
end

function EventMallSingleBuyWithCount()
    if BP_Count_Buy_Cur_Num > curInfo.limitNum then
        if curInfo.limitType == 1 then
            DataMgr.ShowNoticeByID(4350)
        elseif curInfo.limitType == 2 then
            DataMgr.ShowNoticeByID(4351)
        elseif curInfo.limitType == 3 then
            DataMgr.ShowNoticeByID(4352)
        end
        return
    end
    if StoreSystem.IsUseNewStore() then
        local checkMoney = false

        local moneyType, moneyPrice = StoreFuncUtils.get_money_type_and_price(curShopInfo.id, 1, curShopInfo)
        local PriceList = {
            {
                Type = moneyPrice,
                Price = moneyType,
                Num = BP_Count_Buy_Cur_Num
            }
        }
		if BP_CurrentCouponID_WithCount > 0 then	--有代金券使用	价格
			local couponDiscountPrice = CouponsSystem.GetDisCountValueByID(BP_CurrentCouponID_WithCount)
			if couponDiscountPrice > 0 then
				checkMoney = StoreFuncUtils.CheckMoney(PriceList,couponDiscountPrice)
			end
		else
			checkMoney = StoreFuncUtils.CheckMoney(PriceList)
		end
        if checkMoney then
            local data = MallBuyItemWithCountUI.ConvertToNewPurchaseProto()
            StoreSystem.buy_market_by_id_req(data)
        end
    else
        local dict = {}
        table.insert(
            dict,
            {
                id = curInfo.shopID,
                num = BP_Count_Buy_Cur_Num,
                shopInfo = curShopInfo,
                buyInfo = curBuyInfo,
                colorID = curInfo.colorID,
                patternID = curInfo.patternID
            }
        )
        MallSystemUI_2.BuyShopItems(dict, curVersion)
    end
    MallBuyItemWithCountUI:Release()
end

function EventMallBuyWithCountSendItem()
    if StoreSystem.IsUseNewStore() then
        --TODO:
    else
        MallSystemUI_2.SendShopItem(curShopInfo, curBuyInfo, curVersion, curInfo.colorID, curInfo.patternID)
    end
end

function MallBuyItemWithCountUI.ConvertToNewPurchaseProto()
    --log("BP_CurrentCouponID_WithCount: " .. tostring(BP_CurrentCouponID_WithCount))
    local moneyType, _ = StoreFuncUtils.get_money_type_and_price(curShopInfo.id, 1, curShopInfo)
    local Data = {}
    Data[StoreSystem.label_buy_param_id] = curShopInfo.id
    Data[StoreSystem.label_buy_param_price_type] = moneyType
    Data[StoreSystem.label_buy_param_tab_id] = curShopInfo.tab_id
    Data[StoreSystem.label_buy_param_sub_id] = curShopInfo.sub_id
    Data[StoreSystem.label_buy_param_ver] = StoreSystem.store_version
    Data[StoreSystem.label_buy_param_valid_hours] = 0
    Data[StoreSystem.label_buy_param_count] = BP_Count_Buy_Cur_Num
    if BP_CurrentCouponID_WithCount > 0 then
        Data[StoreSystem.label_buy_param_voucher] = BP_CurrentCouponID_WithCount
    end

    return Data
end

--每次打开面板 初始化代金券数据
function MallBuyItemWithCountUI.InitCoupons()
    -- body
    log("MallBuyItemWithCountUI.InitCoupons")
    BP_CurrentCouponID_WithCount = 0 --当前代金券ID	会在蓝图里随点击切换变动
    BP_IsShowCoupon_WithCount = false --是否可用代金券
    BP_CurrentDisCount_WithCount = 0 --当前代金券的抵扣价值索引	会在蓝图里随点击切换变动
end
