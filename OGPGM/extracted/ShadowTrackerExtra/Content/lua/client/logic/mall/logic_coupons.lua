---代金券功能
---逻辑处理和数据交互
---zimingwang
CouponsSystem = CouponsSystem or {}
--可使用代金券的商城物品ID列表;
Logic_ARRAY_CouponsMallID = {}

--从登陆sync info 中缓存出代金券ID对应折扣信息 数据
CouponsSystem.CachedShopCouponsInfo = {}

--全部代金券idList
CouponsSystem.AllCouponsIDList = {}

--注册Event
function CouponsSystem.RegistEvent()
    -- body
    EventSystem:registEvent(EVENTTYPE_STORE_DATA, EVENTID_SUPPLY_DATA, CouponsSystem.OnSupplyDataUpdate)
end

-- 反注册事件
function CouponsSystem.UnRegistEvent()
    EventSystem:unregistEvent(EVENTTYPE_STORE_DATA, EVENTID_SUPPLY_DATA, CouponsSystem.OnSupplyDataUpdate)
end

--收到商城Data
function CouponsSystem.OnSupplyDataUpdate(shopdata)
    -- body
    if shopdata then
        for i, v in pairs(shopdata) do
            if i == StoreSystem.label_market_index_market_list then
                for shopid, vv in pairs(v) do
                    --有代金券数据的话，插进
                    if vv[StoreSystem.label_item_index_voucher] and next(vv[StoreSystem.label_item_index_voucher]) then
                        Logic_ARRAY_CouponsMallID[shopid] = vv[StoreSystem.label_item_index_voucher]
                    end
                end
            end
        end
    end
end

--从登陆sync info 中缓存出代金券ID对应折扣信息
--顺便拿到全部代金券id List
function CouponsSystem.CacheShopCouPonsInfo(couponinfo)
    -- body
    CouponsSystem.AllCouponsIDList = {}

    log_tree("couponinfo", couponinfo)
    CouponsSystem.CachedShopCouponsInfo = couponinfo
    for k, v in pairs(CouponsSystem.CachedShopCouponsInfo) do
        table.insert(CouponsSystem.AllCouponsIDList, k) --获取全部代金券IDLIS
    end
end

--根据代金券ID得到折扣价格

function CouponsSystem.GetDisCountValueByID(id)
    -- body
    for k, v in pairs(CouponsSystem.CachedShopCouponsInfo) do
        if k == id then
            return v
        end
    end
    --没找到对应信息 安全处理返回-1
    return -1
end

--是否是代金券ID
function CouponsSystem.IsCouponID(id)
    -- body
    --log_tree("AllCouponsIDList",CouponsSystem.AllCouponsIDList)
    for k, v in pairs(CouponsSystem.AllCouponsIDList) do
        if id == v then
            return true
        end
    end

    return false
end

--是否能够展示代金券
--条件
--1、玩家拥有该代金券
--2、该商品配置了该代金券
function CouponsSystem.IsCouPonsShopItem(shopid)
    -- body
    log_tree("Logic_ARRAY_CouponsMallID", Logic_ARRAY_CouponsMallID)
    log("zino shopid  " .. shopid)
    local iscouldShow = false
    local playerowncouponIDList = CouponsSystem.GetPlayerHasCoupons()

    if not playerowncouponIDList and not next(playerowncouponIDList) then --玩家没有代金券直接返回nil
        return false
    else
        for k, v in pairs(playerowncouponIDList) do
            if Logic_ARRAY_CouponsMallID[shopid] then
                for kk, vv in pairs(Logic_ARRAY_CouponsMallID[shopid]) do
                    if v == vv then --玩家拥有的代金券和商品配置的代金券相符
                        log("true---------------------------------------------------")
                        return true
                    end
                end
            else
                return false
            end
        end
    end
end

--1、获取展示可用的代金券 Array List
--2、同时获取索引对应的代金券价格
function CouponsSystem.Get_Cur_Coupon_CouldUse_List(shopid)
    -- body
    local CouponDataList = {} --数据List
    local playerowncouponIDList = CouponsSystem.GetPlayerHasCoupons()
    for k, v in pairs(playerowncouponIDList) do
        if Logic_ARRAY_CouponsMallID[shopid] then
            for kk, vv in pairs(Logic_ARRAY_CouponsMallID[shopid]) do
                if v == vv then --玩家拥有的代金券和商品配置的代金券相符
                    log("true---------------------------------------------------")
                    local price = CouponsSystem.GetDisCountValueByID(vv) --得到折扣价格
                    --待续 ...
                    --搞个本地化 富文本 然后把价格传进string  传到Describe_List里
                    local describe = FuncUtil.LocalizeResFormat(6611, price)
                    local tempCouponData = {
                        ID = vv,
                        discount = price,
                        describe = describe
                    }
                    table.insert(CouponDataList, tempCouponData)
                end
            end
        end
    end
    if #CouponDataList > 0 then --有代金券数据
        local firstData = {
            ID = 0,
            discount = 0,
            describe = FuncUtil.LocalizeResFormat(6653)
        }
        table.insert(CouponDataList, 1, firstData) --补充在第一个 不用代金券
	end
	
    table.sort(
        CouponDataList,
        function(a, b)
            -- body
            return a.discount < b.discount
        end
    )
    return CouponDataList
end
--拿到商品ID 对应的代金券IDLIST
function CouponsSystem.FindCoupon(shopid)
    for i, v in ipairs(Logic_ARRAY_CouponsMallID) do
        if shopid == i then
            return v
        end
    end
end

-- 返回玩家拥有的代金券
--从仓库数据中校验拥有的代金券
function CouponsSystem.GetPlayerHasCoupons()
    local OwnCoupons = {}
    --log_tree("DataMgr.arrayHallDepotItemInfo", DataMgr.arrayHallDepotItemInfo);
    DataMgr.GetValidHallDepotItemDataByInsID()
    for k, v in pairs(DataMgr.arrayHallDepotItemInfo) do --从仓库数据中校验拥有的代金券
        if CouponsSystem.IsCouponID(v.resID) and DataMgr.IsValidTime(v.expireTS) then
            table.insert(OwnCoupons, v.resID)
        end
    end

    --log_tree("zino OwnCoupons ", OwnCoupons);
    return OwnCoupons
end

--玩家是否有这个代金券
function CouponsSystem.IsHasThisCoupon(couponItemID)
    -- body
    local tempOwnCoupons = CouponsSystem.GetPlayerHasCoupons()
    if tempOwnCoupons and #tempOwnCoupons > 0 then
        for i, v in pairs(tempOwnCoupons) do
            if v == couponItemID then
                return true
            end
        end
    end
    return false
end
