--商城
MallSystem = MallSystem or
{
	ItemCache = nil;
	GetShopItemInfoByIdReqCallback = nil;
	Version = 0;
	TableItem = {
		id = 0, 									-- 商品id, 								!!!必填
		name = "", 									-- 商品名称, 							默认读物品表中的名字
		category = "", 								-- 商品归类, 							默认为""
		page = "",									-- 商品分页, 							默认为请求中的page
		send_client = 1,							-- 此条商品是否下发给前台, 				默认为1
		sort = 0,									-- 商品排序, 							默认为0
		icon = "",									-- 商品图标, 							默认读物品表中的icon
		money_type = 1001,							-- 货币类型,							默认为钻石
		money_price = 0,							-- 货币价格,							默认为0
		money_price2 = 0,							-- 货币价格2,							默认为0
		money_price3 = 0,							-- 货币价格3,							默认为0
		item_id = 0,								-- 物品ID,								默认为0
		item_time_limit = 0,						-- 物品时限,							默认为0
		item_time_limit2 = 0,						-- 物品时限2,							默认为0
		item_time_limit3 = 0,						-- 物品时限3,							默认为0
		sale_begin_time = 0,						-- 上架时间(UTC时间),					默认为0
		sale_end_time = 0,							-- 下架时间(UTC时间),					默认为0
		personal_buy_limit = 0,						-- 角色限购次数,						默认为0
		global_buy_limit = 0,						-- 全局限购次数,						默认为0
		is_hot = 0,									-- 是否热卖,							默认为0
		timelimit_discount_begin_time = 0,			-- 限时折扣起始时间(UTC时间,没有则为0),	默认为0
		timelimit_discount_end_time = 0,			-- 限时折扣结束时间(UTC时间,没有则为0),	默认为0
		timelimit_discount_count_limit = 0,		    -- 限时折扣数量限制,					默认为0
		timelimit_discount_price = 0,				-- 限时折扣价格,						默认为0
		timelimit_discount_price2 = 0,				-- 限时折扣价格2,						默认为0
		timelimit_discount_price3 = 0,				-- 限时折扣价格3,						默认为0
		timelimit_discount_show_discount = 0, 	    -- 限时折扣显示折扣,					默认为0
		give_type = "item",							-- 发货类型,							默认为"item"
		is_expire = 0,								-- 是否时限商品,						默认为0
		can_present = 0, 							-- 是否可赠送,							默认为0
		item_extra_id = 0,							-- 物品修正ID,							默认为0
		is_new = 0,									-- 是否新品,							默认为0
	};
	CheckMoneyBtnType = {
        NIL = nil,
        Cancel = 0,
        OK = 1,
        Pay = 2,
    };
	OnSellItemListDic = {};
    -- 主页签信息 {[11],[12],[13]}
    TabInfos = {};
    -- 进入商城后，购买的道具ID记录
    BuyItemIdRecord = {};
    -- 月卡信息------------------------
    monthCardInfo = 
    {
        cfg = 
        {  
            configPrice = "",     --直购配置表里的价格
            productPriceDesc = "",--用于显示用的价格
            awardOnOffUC = 0,     --一次性领取的UC
            awardItemId = 1101,      --每天可领取的道具ID
            awardDailyNum = 1,    --每天可领取的道具数量
            awardTotalNum = 30,    --总共可领取的道具数量
            totalTimes = 30,        --总共可领取的次数 
            midasProductId = 0,   --直购月卡productId
            midasPrice = "",      --米大师价格
            midasCountry = "",    --米大师购买国家
            midasCurrency = "",   --购买国家货币符号
            midasPayItem = 1,     -- 米大师购买数量
        },
        data = 
        {
            buyFlag = false, -- 是否已购买
            getTodayEnabled = false,-- 今日是否可领取
            getAwradTimes = 0, -- 领取次数
            lackOfTimes = 0,    -- 剩余次数
        },
    };
    -- 奖赏包，真购信息------------------
    rewardPkgInfo = 
    {
        configPrice = "",     --直购配置表里的价格
        productPriceDesc = "",--用于显示用的价格
        actEndTime = 0,       --活动截止时间
        midasProductId = 0,   --直购月卡productId
        midasPrice = "",      --米大师价格
        midasCountry = "",    --米大师购买国家
        midasCurrency = "",   --购买国家货币符号
        midasPayItem = 1,     --米大师购买数量
        --[[ [1]={itemId=1,itemNum=2} [2]={itemId=2,itemNum=2} ]]
        rewardItems = {},
        discount = 1,        -- 折扣
        item_id = 0,         -- 礼包的id        
    },
    ---------------------------------

    recommendBannerInfo = 
    {
        
    },
    recommendPosterInfo = 
    {
        
    },
    recommendBoxInfo = 
    {
        icon_name = "http://www.pubgmobile.com/event/pics/recommend/recommend2.png",
        shop_id = 10624,
        box_info = {},--请求得到的宝箱数据，略
    },
    recommendItemsInfo = 
    {
        new_market_id = {310071,310072,710010},
        hot_market_id = {710001,310069,310070},
        market_list = {},--商城表信息
        itemId2ShopId = {},
    },
    recommendBoxMainInfo = 
    {
        
    },
    recommendMarketVersion = 0,
    --购买源，是否是从推荐页购买的，如果是，则为1 ，否则为2
    Buy_Source = 2,
}

-- 商城主页签
G_SHOP_TAB_LIMIT_TIME = 13;

local lastVersion = nil;
local mallSimpleInfoDict = nil;
local reqNum = 0;
local cacheItemInfo = {};

local function localText(id)
    local data = Client.GetTableData("LocalizeRes",id);
    if data then
        return data.TextValue
    end
    return ""
end

function MallSystem.Enter()
	log("MallSystem enter");
	lastVersion = 0;
	MallSystem.GetBuyInfoReq();
	MallSystem.Get2rdVerPageListReq()
	MallSystem.GetShopIdListReq();
	

end

function MallSystem.Release()
	log("MallSystem Release");
	MallSystem.ResetItemCache()
end

function MallSystem.GetItemCountInBag(item_id)
    --只记录永久物品
    if MallSystem.ItemCache == nil then
        MallSystem.ItemCache = {}
        for k,v in pairs(DataMgr.arrayHallDepotItemInfo) do
            if v.expireTS == 0 then
                local num = MallSystem.ItemCache[v.resID]
                if num then
                    num = num + v.count
                else
                    num = v.count
                end
                MallSystem.ItemCache[v.resID] = num
            end
        end
    end
    local count = MallSystem.ItemCache[item_id]

	-- --暂时置空。。。。
	-- MallSystem.ItemCache = nil

    if count then
        return count
    end
    return 0
end

function MallSystem.HasItemInBag(item_id)
    return MallSystem.GetItemCountInBag(item_id) > 0
end

function MallSystem.ResetItemCache()
    MallSystem.ItemCache = nil
end

function MallSystem.IsMoneyEnough(money_type, money_price)
    local itm_cfg = Client.GetTableData("Item", money_type)
    if money_type == 1000 then
        if money_price > DataMgr.gold then
            return false
        end
        return true
    elseif money_type == 1001 then
         if money_price > DataMgr.diamond then
            return false
        end
        return true
    elseif money_type == 1006 then
         if money_price > DataMgr.ticket then
            return false
         end
         return true
    else
        local count = MallSystem.GetItemCountInBag(money_type)
        if money_price > count then
            return false
        end
        return true
    end
end

--获取货币名
function MallSystem.GetMoneyName(money_type)
    local money_name = ""
    local itm_cfg = Client.GetTableData("Item", money_type)
    if itm_cfg then
        return itm_cfg.ItemName
    end
    return money_name
end

function MallSystem.CheckIfOpen(id)
    if LobbySystem.LobbyMenuOpenStatus[id] == nil then
        return true
    end
    if LobbySystem.LobbyMenuOpenStatus[id].is_open == 0 then
        return false
    else
        return true
    end
end

--检查货币是否充足 callback参数说明 参数1=true充足，false不够，参数2=nil无，0取消，1确定，2前往
function MallSystem.CheckMoneyIsEnough(money_type, money_price, callback)
    local money_name = MallSystem.GetMoneyName(money_type)
    if money_type == 1000 then
    --金币
        if money_price > DataMgr.gold then
            local str = string.format("%s不足", money_name)
            CommonMessageBoxUI:ShowPanel(1, localText(101001), str,
                function() callback(false, 1) end);
        else
            callback(true)
        end
    elseif money_type == 1001 then
    --钻石
        local ticket_name = MallSystem.GetMoneyName(1006)
        if money_price > DataMgr.diamond then
            --1点券=1钻石
            if MallSystem.CheckIfOpen(50004) then
                local now_ticket = DataMgr.ticket
                local need_diamond = money_price - DataMgr.diamond
                --如果是钻石不足，判断点券是否充足
                if need_diamond <= now_ticket then
                    --可以用点券补足
                    local str = string.format(localText(501051), money_name, need_diamond, ticket_name)
                    CommonMessageBoxUI:ShowPanel(2, localText(101001), str,
                        function()
                            callback(true, 1)
                        end,
                        function()
                            callback(true, 0)
                        end);
                    return
                end
                local str = string.format(localText(501052), money_name)
                CommonMessageBoxUI:ShowPanel(2, localText(101001), str,
                    function()
                        callback(false, 2)
                        RechargeUI:Init();
                    end,
                    function()
                        callback(false, 0)
                    end);
            else
                local str = string.format("%s不足", money_name)
                CommonMessageBoxUI:ShowPanel(1, localText(101001), str,
                    function() callback(false, 1) end);
            end
        else
            callback(true)
        end
    elseif money_type == 1006 then
    --点券
        if money_price > DataMgr.ticket then
            local str = string.format(localText(501052), money_name)
            CommonMessageBoxUI:ShowPanel(2, localText(101001), str,
                function()
                    callback(false, 2)
                    RechargeUI:Init();
                end,
                function()
                    callback(false, 0)
                end);
        else
            callback(true)
        end
    else
    --其他货币
        local count = MallSystem.GetItemCountInBag(money_type)
        if money_price > count then
            local str = string.format("%s不足", money_name)
            CommonMessageBoxUI:ShowPanel(1, localText(101001), str,
                function() callback(false, 1) end);
        end
        callback(true)
    end
end


function MallSystem.GetMallSimpleInfoDict()
    return mallSimpleInfoDict;
end

--获取永久物品的id, 暂时没有考虑限量物品
function MallSystem.GetProductForeverPrice(productTbl)
    local ForeverPrice = 0
    local DiscountPrice = 0
    -- is_expire == 1是限时道具
    if productTbl.is_expire == 1 then
        local itemTimeLimit = { productTbl.item_time_limit, productTbl.item_time_limit2,  productTbl.item_time_limit3 }
        local itemMoneyPrice = { productTbl.money_price, productTbl.money_price2, productTbl.money_price3 }
        local itemDiscountPrice = { productTbl.timelimit_discount_price, productTbl.timelimit_discount_price2, productTbl.timelimit_discount_price3 }

        local foreverIdx = 1
        for i = 1, #itemTimeLimit do
            -- -1是永久物品
            if itemTimeLimit[i] == -1 then
                foreverIdx = i
                break
            end
        end
        ForeverPrice = itemMoneyPrice[foreverIdx]
        DiscountPrice = itemDiscountPrice[foreverIdx]
    else
        ForeverPrice = productTbl.money_price
        DiscountPrice = productTbl.timelimit_discount_price
    end

    local isDiscount = MallSystem.IsDiscount(productTbl)

    if isDiscount then
        return DiscountPrice, ForeverPrice
    end

    return ForeverPrice, ForeverPrice
end

--获取物品是否折扣期
function MallSystem.IsDiscount(itm_svr)
    local now_time = FuncUtil.GetServerTimeInSec()
    if itm_svr.timelimit_discount_price <= 0 then
        return false
    end
    local max_time = false
    if itm_svr.timelimit_discount_end_time == 0 then
        max_time = true
    end
    if now_time >= itm_svr.timelimit_discount_begin_time and (max_time or now_time <= itm_svr.timelimit_discount_end_time) then
        return true
    else
        return false
    end
end

--把货币类型转换为物品表id
function MallSystem.MoneyTypeToChinaMoneyType(moneyType)
    if moneyType == 0 then
        return 1000;
    elseif moneyType == 1 then
        return 1001;
    elseif moneyType == 2 then
        return 1006;
    end
    return moneyType;
end

--把物品表id转换为货币类型
function MallSystem.ChinaMoneyTypeToMoneyType(moneyType)
    if moneyType == 1000 then
        return 0;
    elseif moneyType == 1001 then
        return 1;
    elseif moneyType == 1006 then
        return 2;
    end
    return moneyType;
end

--sami 获取出售商品道具shopId
function MallSystem.GetShopId(page, itemId)
    log("MallSystem.GetShopId page = " ..page ..", itemId = " ..itemId);
    local itemList = MallSystem.OnSellItemListDic[page];
    --log_tree("itemList ", itemList);
    if(itemList == nil) then
        return 0;
    end
    for i,v in ipairs(itemList) do
        if(tonumber(v.item_id) == tonumber(itemId)) then
            return v.id;
        end
    end
    return 0;
end

-- 获取出售商品道具tab2
function MallSystem.GetShopTab2(page, itemId)
    log("MallSystem.GetShopTab2 page = " ..page ..", itemId = " ..itemId);
    local itemList = MallSystem.OnSellItemListDic[page];
    --log_tree("itemList ", itemList);
    if(itemList == nil) then
        return 0;
    end
    for i,v in ipairs(itemList) do
        if(tonumber(v.item_id) == tonumber(itemId)) then
            return v.page % 10;
        end
    end
    return 0;
end


function MallSystem.GetMonthCardInfo()
    return MallSystem.monthCardInfo;
end

function MallSystem.GetRewardPkgInfo()
    return MallSystem.rewardPkgInfo;
end

-- 这个页签是否开启
function MallSystem.IsTabOpen(tab)
    if MallSystem.TabInfos then
        local info = MallSystem.TabInfos[tab];
        if info and info.isOpen and info.isOpen == 1 then
            return true;
        end
    end 
    return false;
end

function MallSystem.IsMysteryTab(firTab, secTab)
    if firTab == G_SHOP_TAB_LIMIT_TIME then
        if secTab == 1 or secTab == 2 then
            return true;
        end
    end
    return false;
end

-- 是否在购买记录里
function MallSystem.IsInBuyRecord(itemId, colorID, patternID)
    colorID = colorID or 0;
    patternID = patternID or 0;
    if not MallSystem.BuyItemIdRecord or 
       not (MallSystem.BuyItemIdRecord[itemId] and MallSystem.BuyItemIdRecord[itemId].colorID == colorID and MallSystem.BuyItemIdRecord[itemId].patternID == patternID) then
        return false;
    end
    return true;
end

function MallSystem.ClearBuyRecord()
    MallSystem.BuyItemIdRecord = {};
end

------------------------------------------------------------------
------------------------------------------------------------------
-- 服务器相关 start
------------------------------------------------------------------


--拉取商城购买详细信息
function MallSystem.GetBuyInfoReq()
	log("get_igame_market_buy_info_req");
	NetUtil.SendPriorityPkg(false, "get_market_buy_info_rsp", "get_igame_market_buy_info_req");
end

--拉取商城购买详细信息响应
function MallSystem.GetBuyInfoRsp(list, isAll)
	log("get_market_buy_info_rsp :" .. isAll);

	--log_tree("list", list);

	if isAll == 1 then
		EventSystem:postEvent(EVENTTYPE_MALL, EVENTID_MALL_BUY_INFO_UPDATE,list);
	else
		EventSystem:postEvent(EVENTTYPE_MALL, EVENTID_MALL_BUY_INFO_CHANGE,list);
	end

end


--获取某页签商品信息列表
function MallSystem.GetPageDetailReq(page)
    if StoreSystem.IsUseNewStore() then
        return
    end
	log("get_igame_market_page_detail_req:" .. page);
	NetUtil.SendPriorityPkg(false, "get_igame_market_page_detail_rsp", "get_igame_market_page_detail_req", page, 0);
end

--获取某页签商品信息列表响应
--prime_shoplist        新增普通订阅list
--primeplus_shoplist    新增高级订阅list
function MallSystem.GetPageDetailRsp(res, page, version, list,prime_shoplist,primeplus_shoplist)
    log("get_igame_market_page_detail_rsp : page = " ..page .." " ..res);
    --log_tree("zino listlist",list)
    if res ~= "ok" then
        DataMgr.ShowNoticeByID(res);
        return;
    end
	lastVersion = version;
	MallSystem.Version = version;

	--sami 保存商城出售道具列表信息
    --log_tree("mall item list", list);
    ----------------------------------------------------订阅系统插入Start-------------------------------------
    if NewSubscribeSystem.GetIsPrimeOpen() then
        if prime_shoplist then 
            log_tree("zino prime_shoplist",prime_shoplist)
            for k,v in pairs(prime_shoplist) do
                -- body
                v.page = 1301
                v.isnormalPrime = true
                table.insert(list,v)
            end    
        end
        if primeplus_shoplist then 
            log_tree("zino primeplus_shoplist",primeplus_shoplist)
            for k,v in pairs(primeplus_shoplist) do
                -- body
                v.page = 1301
                v.isPlusPrime = true
                table.insert(list,v)
            end    
        end
    end

    ----------------------------------------------------订阅系统插入END-------------------------------------
	MallSystem.OnSellItemListDic[page] = list;
	EventSystem:postEvent(EVENTTYPE_MALL, EVENTID_MALL_PAGE_ITEM_INFO_UPDATE,{page,list});
end

function MallSystem.HandleReqNum()
    reqNum = reqNum + 1;
end

--商品购买
function MallSystem.BatchBuyReq(list,curVersion,voucher)
	log("igame_market_batch_buy_req :" .. tostring(curVersion));
	reqNum = reqNum + 1;
	NetUtil.SendPriorityPkg(false, "igame_market_batch_buy_rsp", "igame_market_batch_buy_req", list, curVersion == nil and lastVersion or curVersion, voucher);
end

--商品购买响应
function MallSystem.BatchBuyRsp(res, itemList)
	log("igame_market_batch_buy_rsp :" .. res);
	--log_tree("itemList",itemList);
	reqNum = reqNum - 1;
    if res == "ok" then
		MallSystem.ResetItemCache();
			for i,v in ipairs(itemList) do
				local itemData = {
					res_id = v.id;
					count = v.count;
					valid_hours = v.time_limit;
					expire_ts = 0;
                    color_id = v.color;
                    pattern_id = v.pattern;
				};
				table.insert(cacheItemInfo, itemData);
				local resItem = Client.GetTableData("Item",v.id);
				if resItem ~= nil and resItem.ItemType == 1 then
					local resWeaponAvator = Client.GetTableData("WeaponSkinMapping",v.id);
					local resWeaponItem = Client.GetTableData("Item",resWeaponAvator.WeaponID);
					--DataMgr.ShowNoticeByString(FuncUtil.LocalizeResFormat("4471", resItem.ItemName,resWeaponItem.ItemName));--需求变更不用装备，所以提示去掉
				end
                -- 记录已购买的道具Id
                MallSystem.BuyItemIdRecord[v.id] = {id = v.id, colorID = v.color or 0, patternID = v.pattern or 0};
			end
			if reqNum == 0 then
				CommonItemGetUI:ShowPanel(cacheItemInfo);
				cacheItemInfo = {};
			end


		EventSystem:postEvent(EVENTTYPE_MALL, EVENTID_MALL_BUY_RESULT, {true,itemList});
    else
		EventSystem:postEvent(EVENTTYPE_MALL, EVENTID_MALL_BUY_RESULT, {false});

       if res == 9910225 then--
            local title = Client.GetTableData("LocalizeRes", "101001").TextValue;
            local tip = Client.GetTableData("LocalizeRes", "4119").TextValue;
            CommonMessageBoxUI:ShowPanel(2, title, tip, function()
                    RechargeUI:Init();
                return true;
            end);
       else
            DataMgr.ShowNoticeByID(res);
       end
    end
end


function MallSystem.GetDirectBuyInfoReq()
	log("igame_get_direct_buy_info");
	NetUtil.SendPriorityPkg(false, "igame_get_direct_buy_info_rsp", "igame_get_direct_buy_info");
end

-- 直购回包信息
function MallSystem.GetDirectBuyInfoRsp(res, list)
	log("igame_get_direct_buy_info_rsp" .. res);
	--log_tree("list", list);
	if res ~= "ok" then
        DataMgr.ShowNoticeByID(res);
        return;
    end
	EventSystem:postEvent(EVENTTYPE_MALL, EVENTID_MALL_DIRECT_BUY_INFO, list);
end

-- 拉取掉落列表
function MallSystem.DirectBuyContentReq(id)
	log("igame_market_direct_buy_content_req");
	NetUtil.SendPriorityPkg(false, "igame_market_direct_buy_content_rsp", "igame_market_direct_buy_content_req", id);
end

-- 直购掉落列表
function MallSystem.DirectBuyContentRsp(res, content, id)
	if res ~= "ok" then
        DataMgr.ShowNoticeByID(res);
        return;
    end
	EventSystem:postEvent(EVENTTYPE_MALL, EVENTID_MALL_GET_DROP_LIST, {id, content});
end

-- 直购成功回包
function MallSystem.DirectBuyResultNotify(res, id, limit_num)
	if res ~= "ok" then
        DataMgr.ShowNoticeByID(res);
        return;
    end
	Direct_Purchase_UI.BuyGoodsNotify(id, limit_num);

    --新手礼包直购的处理
    StarterPackSystem.DirectBuyResultNotify(res, id, limit_num)
end

-- 获取月卡相关信息
function MallSystem.GetMonthCardInfoReq()
    log("MallSystem.GetMonthCardInfoReq");
    NetUtil.SendPkg("get_month_card_info");
end

-- 月卡相关信息返回
function MallSystem.GetMonthCardInfoRsp(res, svrCardinfo)
    if res ~= "ok" then
        DataMgr.ShowNoticeByID(res);
        return;
    end

    local cardInfoCfg = MallSystem.monthCardInfo.cfg; 
    local cardInfoData = MallSystem.monthCardInfo.data;
    MallSystem.ParseMonthCardParam(svrCardinfo.cfg.parm2, cardInfoCfg);

    local itemContent = svrCardinfo.cfg.item_content;
    if itemContent and #itemContent > 1 then
        local dropCfg = itemContent[1];
        cardInfoCfg.awardItemId = dropCfg.DropItemID;
        cardInfoCfg.awardDailyNum = dropCfg.DropItemNum;
        cardInfoCfg.awardTotalNum = cardInfoCfg.totalDay * dropCfg.DropItemNum;
    end
    
    cardInfoCfg.midasProductId = svrCardinfo.cfg.productid;
    cardInfoCfg.midasCurrency = svrCardinfo.cfg.curency_unit;
    cardInfoCfg.midasCountry = svrCardinfo.cfg.country;
    cardInfoCfg.midasPayItem = svrCardinfo.cfg.payItem;
    cardInfoCfg.midasPrice = svrCardinfo.cfg.midasPrice;

    if not svrCardinfo.data then
        -- 为空则表示没购买月卡
        cardInfoData.buyFlag = false;
    else
        if svrCardinfo.can_buy then
            cardInfoData.buyFlag = false;
        else
            cardInfoData.buyFlag = true;
        end
        cardInfoData.lackOfTimes = svrCardinfo.data.times;
        cardInfoData.getAwradTimes = cardInfoCfg.totalTimes - svrCardinfo.data.times;
        cardInfoData.getTodayEnabled = svrCardinfo.data.flag;
    end
    --用于显示用的价格
    cardInfoCfg.configPrice = svrCardinfo.cfg.price;
    cardInfoCfg.productPriceDesc = MidasManager.GetPriceByProductId(cardInfoCfg.midasProductId,
                                                                    cardInfoCfg.midasCurrency,
                                                                    "", true);
    --print_r(svrCardinfo);
    EventSystem:postEvent(EVENTTYPE_MALL, EVENTID_MALL_MONTH_CARD_INFO);
end

function MallSystem.ParseMonthCardParam(param, cfg)
    strs = string.split(param, ",");
    if strs and #strs >= 5 then
        cfg.awardOnOffUC = tonumber(strs[1]);
        cfg.totalDay = tonumber(strs[5]);
    end
    return 0;
end

-- 领取月卡每日奖励的请求
function MallSystem.GetMonthCardDailyAwardReq()
    log("take_month_card_daily_award");
    NetUtil.SendPkg("take_month_card_daily_award");
end

-- 领取月卡每日奖励的返回
function MallSystem.GetMonthCardDailyAwardRsp(res, svrCardData)
    if res ~= "ok" then
        DataMgr.ShowNoticeByID(res);
        return;
    end
    -- log("MallSystem.GetMonthCardDailyAwardRsp------------------");
    
    if not svrCardData then
        return;
    end
    local cardInfoCfg = MallSystem.monthCardInfo.cfg;
    local cardInfoData = MallSystem.monthCardInfo.data; 
    cardInfoData.buyFlag = true;
    cardInfoData.lackOfTimes = svrCardData.times;
    cardInfoData.getAwradTimes = cardInfoCfg.totalTimes - svrCardData.times;
    cardInfoData.getTodayEnabled = svrCardData.flag or false;
    EventSystem:postEvent(EVENTTYPE_MALL, EVENTID_MALL_MONTH_CARD_INFO);
end

-- 月卡购买成功后主动通知
function MallSystem.NotifyMonthCardInfo(res, svrCardData)
    log("MallSystem.NotifyMonthCardInfo----------------------");
    MallSystem.GetMonthCardDailyAwardRsp(res, svrCardData);
end

-- 获取对应的直购表信息
function MallSystem.GetDirectPurchaseInfoReq(itemId)
    log("query_direct_buy_info:"..tostring(itemId));
    --NetUtil.SendPkg("query_direct_buy_info", itemId);
    NetUtil.SendPriorityPkg(false, "query_direct_buy_info_rsp", "query_direct_buy_info", itemId);
end

--保存批量拉取的直购结构
function MallSystem.GetDirectPurchaseInfoListRsp(res, info)
    if res ~= "ok" then
        DataMgr.ShowNoticeByID(res);
        return;
    end
    log("MallSystem.GetDirectPurchaseInfoListRsp");
    for k,v in pairs(info) do
        local rewardPkgInfo = {};

        rewardPkgInfo.midasProductId = v.productid;
        rewardPkgInfo.midasCountry = v.country;
        rewardPkgInfo.midasCurrency = v.curency_unit;
        rewardPkgInfo.midasPrice = v.midasPrice;
        rewardPkgInfo.midasPayItem = v.payItem;
        rewardPkgInfo.discount = v.discount;             -- 折扣
        rewardPkgInfo.item_id = v.item_id;

        rewardPkgInfo.rewardItems = {};
        if v.parm2 and v.parm2 ~= "" then
            -- 充值返的UC
            local returnUC = MallSystem.ParseDirectPurchaseParam(v.parm2);
            if returnUC > 0 then
                rewardPkgInfo.rewardItems[1] = {itemId = 1006, itemNum = returnUC};
            end
        end
        for index, item in ipairs(v.item_content) do
            rewardPkgInfo.rewardItems[#rewardPkgInfo.rewardItems+1] =
            {itemId = item.DropItemID, itemNum = item.DropItemNum};
        end

        rewardPkgInfo.configPrice = v.price;
        rewardPkgInfo.productPriceDesc = MidasManager.GetPriceByProductId(rewardPkgInfo.midasProductId,
                rewardPkgInfo.midasCurrency,
                "", true);
    end

    EventSystem:postEvent(EVENTTYPE_MALL, EVENTID_MALL_REWARD_PKG_INFO);
end

function MallSystem.GetDirectPurchaseInfoRsp(res, info)
    if res ~= "ok" then
        DataMgr.ShowNoticeByID(res);
        return;
    end

    log("MallSystem.GetDirectPurchaseInfoRsp");
    local rewardPkgInfo = MallSystem.rewardPkgInfo;

    rewardPkgInfo.midasProductId = info.productid;
    rewardPkgInfo.midasCountry = info.country;
    rewardPkgInfo.midasCurrency = info.curency_unit;
    rewardPkgInfo.midasPrice = info.midasPrice;
    rewardPkgInfo.midasPayItem = info.payItem;
    rewardPkgInfo.discount = info.discount;             -- 折扣
    rewardPkgInfo.item_id = info.item_id;

    rewardPkgInfo.rewardItems = {};
    if info.parm2 and info.parm2 ~= "" then
        -- 充值返的UC
        local returnUC = MallSystem.ParseDirectPurchaseParam(info.parm2);
        if returnUC > 0 then
            rewardPkgInfo.rewardItems[1] = {itemId = 1006, itemNum = returnUC};
        end
    end
    for index, item in ipairs(info.item_content) do
        rewardPkgInfo.rewardItems[#rewardPkgInfo.rewardItems+1] = 
                {itemId = item.DropItemID, itemNum = item.DropItemNum};
    end

    rewardPkgInfo.configPrice = info.price;
    rewardPkgInfo.productPriceDesc = MidasManager.GetPriceByProductId(rewardPkgInfo.midasProductId,
                                                                      rewardPkgInfo.midasCurrency,
                                                                      "", true);
    EventSystem:postEvent(EVENTTYPE_MALL, EVENTID_MALL_REWARD_PKG_INFO);

    --新手礼包直购的处理
    StarterPackSystem.GetDirectPurchaseInfoRsp(res, info)
end

function MallSystem.ParseDirectPurchaseParam(param)
    strs = string.split(param, ",");
    if strs and #strs >= 1 then
        return tonumber(strs[1]);
    end
    return 0;
end

function MallSystem.NewItemData(itm_svr)
    local itm = FuncUtil:CopyTable(MallSystem.TableItem)
    if type(itm_svr) == "table" then
        if itm_svr.item_id then
            local cfg = Client.GetTableData("Item", itm_svr.item_id)
            if cfg then
                itm.name = cfg.ItemName
            end
        end
        for k,v in pairs(itm_svr) do
            itm[k] = v
        end
    end
    return itm
end

-- 拉取单个商品信息
function MallSystem.GetShopItemInfoByIdReq(id, callback)
    if StoreSystem.IsUseNewStore() then
        return
    end
    log("MallSystem.get_market_shopitem_info_by_id_req call")
    MallSystem.GetShopItemInfoByIdReqCallback = callback
    NetUtil.SendPriorityPkg(false, "get_market_shopitem_info_by_id_rsp", "get_market_shopitem_info_by_id_req", id)
end

function MallSystem.GetShopItemInfoByIdRsp(res, info, version)
    log("get_market_shopitem_info_by_id_rsp res="..res)
    if res ~= "ok" or not info then
        -- local str = "商品无效，该商品可能已经下架"
        CommonMessageBoxUI:ShowPanel(1, localText(101001), localText(res))
    end

    MallSystem.Version = version
    local itm = MallSystem.NewItemData(info)
    -- MallSystem.TableData[itm.id] = itm

    local productTbl = {}
    productTbl.id = itm.id
    productTbl.name = itm.name
    productTbl.money_type = itm.money_type
    productTbl.item_id = itm.item_id
    local disPrice, oriPrice = MallSystem.GetProductForeverPrice(itm)
    productTbl.discount_price = disPrice
    productTbl.money_price = oriPrice

    if MallSystem.GetShopItemInfoByIdReqCallback then
        MallSystem.GetShopItemInfoByIdReqCallback(productTbl)
    end
end

--拉取商城所有商品简要信息
function MallSystem.GetShopIdListReq()
    if StoreSystem.IsUseNewStore() then
        return
    end
    log("MallSystem.igame_market_get_shop_id_list call")
    NetUtil.SendPriorityPkg(false, "igame_market_get_shop_id_list_rsp", "igame_market_get_shop_id_list", "0.7.0")--兼容老版本加个version
end


--拉取商城所有商品简要信息(额外附带所有商城)

-- LogNula: LuaLog: ├─ 95
-- LogNula: LuaLog: │  ├─ id: 330013
-- LogNula: LuaLog: │  ├─ page: 1303
-- LogNula: LuaLog: │  └─ item_id: 405031
-- LogNula: LuaLog: ├─ 96
-- LogNula: LuaLog: │  ├─ id: 310009
-- LogNula: LuaLog: │  ├─ page: 1301
-- LogNula: LuaLog: │  └─ item_id: 1400230
-- LogNula: LuaLog: └─ 97
-- LogNula: LuaLog:    ├─ id: 320031
-- LogNula: LuaLog:    ├─ page: 1301
-- LogNula: LuaLog:    └─ item_id: 401031
local tapInfo = {}

function MallSystem.GetMallAllItemsSimpleInfo()
    if StoreSystem.IsUseNewStore() then
        return
    end
    log("MallSystem.igame_market_get_all_sell_item_page_info call")
    NetUtil.SendPriorityPkg(false, "igame_market_get_all_sell_item_page_info_rsp", "igame_market_get_all_sell_item_page_info")--兼容老版本加个version
end

function MallSystem.GetMallAllItemsSimpleInfoRsp(res, list)
    if res  ~= "ok" then
        DataMgr.ShowNoticeByID(res);
        return;
    end

    -- 记录tab数据，用来通过itemID获取商品ID
    tapInfo = list
    -- 
     --log_tree("======list",list)
end

function MallSystem.getTabInfoByItemID(itemID)
    --log("MallSystem.getTabInfoByItemID(itemID) " .. itemID)
    --log_tree("tapInfo=====",tapInfo)
    for i,v in ipairs(tapInfo) do
        if v.item_id == itemID then
            return v
        end
    end

    return nil
end

function MallSystem.GetShopIdListRsp(res, list)
    log("igame_market_get_shop_id_list_rsp:" .. res)
    if res  ~= "ok" then
        DataMgr.ShowNoticeByID(res);
        return;
    end

    --log_tree("zino_list",list);
	mallSimpleInfoDict = {};
	local tab1 = nil;
	local tab2 = nil;
	for i,v in ipairs(list) do
		tab1 = math.floor(v.page/100);
		tab2 = v.page%100;

            local tab1Infos = mallSimpleInfoDict[tab1];
            if not tab1Infos then
                tab1Infos = {};
                mallSimpleInfoDict[tab1] = tab1Infos;
            end
            local tab2Infos = tab1Infos[tab2];
            if not tab2Infos then
                tab2Infos = {};
                tab1Infos[tab2] = tab2Infos;
            end
        if not MallSystem.IsTabOpen(tab1) or
           MallSystem.IsMysteryTab(tab1, tab2) then
            -- 没开启的或限时的页签不计入
        else
            table.insert(tab2Infos, v.id);
        end
    end
    for k,v in pairs(mallSimpleInfoDict) do
    --log("zino mallSimpleInfoDict key "..k)
    end
    --log_tree("zino mallSimpleInfoDict",mallSimpleInfoDict)
	EventSystem:postEvent(EVENTTYPE_MALL, EVENTID_MALL_GET_ALL_SIMPLE_INFO);
end



--------------------------------------新版商城--------------------------------------------
--获取tab列表配置
function MallSystem.Get2rdVerPageListReq()
    if StoreSystem.IsUseNewStore() then
        return
    end
	log("igame_market_get_2rdVer_page_list");
	NetUtil.SendPriorityPkg(false, "igame_market_get_2rdVer_page_list_rsp", "igame_market_get_2rdVer_page_list");
end

--获取tab列表配置响应
function MallSystem.Get2rdVerPageListRsp(res, page_list, wait_to_refresh_time, wait_to_refresh_time2)
	log("igame_market_get_2rdVer_page_list_rsp: " .. res);
    if res ~= "ok" then
        DataMgr.ShowNoticeByID(res);
        return;
    end
    --log_tree("page_list ", page_list);
    MallSystem.TabInfos = page_list;
    --刷新列表信息
	EventSystem:postEvent(EVENTTYPE_MALL, EVENTID_MALL_TAB_RES_UPDATE,{page_list,wait_to_refresh_time,wait_to_refresh_time2});
end

---------------------------------------------------------------------------
-- 服务器相关 end
---------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- 商店跳转用数据
-- function MallSystem.GetMallAllItemsSimpleInfoLazy()
--     MallSystem.GetMallAllItemsSimpleInfo()
-- end

function MallSystem.JumpToMall(itemId)
    log("MallSystem.JumpToMall itemID"..itemId)

    local shopInfo = MallSystem.getTabInfoByItemID(itemId)
    if shopInfo == nil then
        CommonMessageBoxUI:ShowPanel(1, localText(101001), "商品没有上架")
        return
    end

    local tap1 = shopInfo.first_tab
    local tap2 = shopInfo.second_tab

    local params = {
        ["Tab1"] = tap1,
        ["Tab2"] = tap2,
        ["isForceTab2"] = true,
        ["itemId"] = itemId,
    };
    if shopInfo.shop_id ~= nil and shopInfo.shop_id ~= 0 then
        params.selectShopId = shopInfo.shop_id
    else
        params.selectShopId = itemId
    end

    EventSystem:postEvent(EVENTTYPE_URL, BP_ENUM_MODULE_MALL_CHILD, params)
end

local mallSystemUILastFirstTab = 0;
local mallSystemUILastSecondTab = 0;

function MallSystem.OpenUIWithLastState()
    local params = {
            ["Tab1"] = mallSystemUILastFirstTab,
            ["Tab2"] = mallSystemUILastSecondTab,
            ["isForceTab2"] = true,
        };
    EventSystem:postEvent(EVENTTYPE_URL, BP_ENUM_MODULE_MALL_CHILD, params)
end

function MallSystem.SetMallSystemUIFirstTab(tab)
    mallSystemUILastFirstTab = tab;
end

function MallSystem.SetMallSystemUISecondTab(tab)
    mallSystemUILastSecondTab = tab;
end

-- 开箱获得烧鸡道具弹出提示
function MallSystem.on_notify_open_chest_present(resid, count)
	log("MallSystem.on_notify_open_chest_present resid="..resid.." count="..count)
	local fmt = Client.GetTableData("LocalizeRes", 6190).TextValue;
	local str = string.format(fmt, count);
	PopUpNoticeUI.ShowFastNoticeQueue(str)
end


-- 

-- get recommend 
function MallSystem.igame_market_get_banner_show_req()
    log("MallSystem.igame_market_get_banner_show_req")
    NetUtil.SendPkg("igame_market_get_banner_show_req")
end

function MallSystem.igame_market_get_banner_show_rsp(error_code, valid_banner_table, ret_valid_banner_info, valid_market_info, market_version)
    log("MallSystem.igame_market_get_banner_show_rsp error_code "..error_code)
    log_tree("valid_banner_table ", valid_banner_table)
    log_tree("ret_valid_banner_info ", ret_valid_banner_info)
    log_tree("valid_market_info ", valid_market_info)

    if MallRecommendUI.isShowing == false then 
        return 
    end

    if error_code ~= 0 then
        DataMgr.ShowNoticeByID(error_code)

        MallRecommendUI.ShowRoot(false)
        return
    end

    MallRecommendUI.ShowRoot(true)

    
    MallSystem.recommendCurrentShowType = 0
    MallSystem.recommendBannerInfo = {}
    MallSystem.recommendPosterInfo = {}
    MallSystem.recommendBoxInfo = {}
    MallSystem.recommendItemsInfo = {}
    MallSystem.recommendBoxMainInfo = {}
    MallSystem.recommendMarketVersion = market_version
    -- local temp = {}
    -- temp.pos = 1
    -- temp.tag = 0
    -- temp.priority = 1
    -- temp.TemplateID = 3
    -- temp.TemplateNo = 4
    -- temp.good_id = "game://?module=1003201&Tab1=19&Tab2=6029"
    -- temp.title = ""
    -- temp.icon_name = "http://www.pubgmobile.com/event/pics/banner/banner971.png"

--     LogNula: LuaLog: ├─ 1
-- LogNula: LuaLog: │  ├─ hot_market_id: ""
-- LogNula: LuaLog: │  ├─ banner_type: 1
-- LogNula: LuaLog: │  ├─ shop_id: 0
-- LogNula: LuaLog: │  ├─ good_id: "game://?module=1003201&Tab1=14&Tab2=10507"
-- LogNula: LuaLog: │  ├─ icon_name: "http://www.pubgmobile.com/event/pics/banner/banner24.png"
-- LogNula: LuaLog: │  ├─ new_market_id: ""
-- LogNula: LuaLog: │  └─ img_path: ""
    for key, value in pairs(valid_banner_table) do
        BP_MallRecommendUI_SceneMatId = value.scene_id
		BP_MallRecommendUI_SceneImgUrl = value.scene_img
    end
    
    log("BP_MallRecommendUI_SceneMatId"..BP_MallRecommendUI_SceneMatId)
    local bannerPriority = 1
    for index, info in pairs(ret_valid_banner_info) do
        local infoType = tonumber(info.banner_type)

        if infoType == MallRecommendUI.PAGE_SHOWTYPE_BANNER then
            local bannerInfo = {}
            bannerInfo.pos = 1
            bannerInfo.tag = 0
            bannerInfo.TemplateID = 3
            bannerInfo.TemplateNo = 4
            bannerInfo.good_id = info.good_id
            bannerInfo.title = ""
            bannerInfo.icon_name = info.icon_name

            bannerInfo.priority = bannerPriority
            bannerPriority = bannerPriority + 1

            table.insert(MallSystem.recommendBannerInfo, bannerInfo)
        end

        if infoType == MallRecommendUI.PAGE_SHOWTYPE_BOX then
            MallSystem.recommendPosterInfo.img_path = info.img_path
            local box_info =  valid_market_info.shop_list[info.shop_id]
            MallSystem.recommendBoxMainInfo.icon_name = info.icon_name
            MallSystem.recommendBoxMainInfo.shop_id = info.shop_id
            --重复利用原有宝箱界面数据结构
            if box_info then
                ShopSystem.updateItemInfo(info.shop_id, box_info)
            end

        end

        if infoType == MallRecommendUI.PAGE_SHOWTYPE_ITEM then
            MallSystem.recommendItemsInfo.new_market_id = string.split(info.new_market_id, ",")
            MallSystem.recommendItemsInfo.hot_market_id = string.split(info.hot_market_id, ",")

            --log_tree("info.new_market_id ", type(info.new_market_id))
            --log_tree("MallSystem.new_market_id ", MallSystem.recommendItemsInfo.new_market_id)
            --log_tree("MallSystem.hot_market_id ", MallSystem.recommendItemsInfo.hot_market_id)
            
            MallSystem.recommendItemsInfo.market_list = valid_market_info.market_list
            MallSystem.recommendItemsInfo.itemId2ShopId = {}
            for i, v in pairs(MallSystem.recommendItemsInfo.market_list) do
                MallSystem.recommendItemsInfo.itemId2ShopId[v.item_id] = v.id
            end
        end

        if infoType > MallSystem.recommendCurrentShowType then
            MallSystem.recommendCurrentShowType = infoType
        end

    end

    log("MallSystem.recommendCurrentShowType "..MallSystem.recommendCurrentShowType)
    if MallSystem.recommendCurrentShowType == MallRecommendUI.PAGE_SHOWTYPE_BOX then
        for key, value in pairs(valid_market_info.shop_list) do
            MallSystem.recommendBoxInfo = value
            MallSystem.recommendBoxInfo.shop_id = key
            break
        end
    end

    MallRecommendUI.onPacketRespone()
end

s2c["igame_market_get_banner_show_rsp"] = MallSystem.igame_market_get_banner_show_rsp
-- 

--[[网络回调]]--
s2c["get_market_buy_info_rsp"] = MallSystem.GetBuyInfoRsp;
s2c["get_igame_market_page_detail_rsp"] = MallSystem.GetPageDetailRsp;
s2c["igame_market_batch_buy_rsp"] = MallSystem.BatchBuyRsp;
s2c["igame_get_direct_buy_info_rsp"] = MallSystem.GetDirectBuyInfoRsp;
s2c["igame_direct_buy_result_notify"] = MallSystem.DirectBuyResultNotify;
s2c["igame_market_direct_buy_content_rsp"] = MallSystem.DirectBuyContentRsp;
s2c["get_market_shopitem_info_by_id_rsp"] = MallSystem.GetShopItemInfoByIdRsp;
s2c["igame_market_get_shop_id_list_rsp"] = MallSystem.GetShopIdListRsp;

--新版商城
s2c["igame_market_get_2rdVer_page_list_rsp"] = MallSystem.Get2rdVerPageListRsp;

-- 直购月卡相关
s2c["get_month_card_info_rsp"] = MallSystem.GetMonthCardInfoRsp;
s2c["take_month_card_daily_award_rsp"] = MallSystem.GetMonthCardDailyAwardRsp;
s2c["notify_month_card_info"] = MallSystem.NotifyMonthCardInfo;
s2c["query_direct_buy_info_rsp"] = MallSystem.GetDirectPurchaseInfoRsp;

s2c["igame_market_get_all_sell_item_page_info_rsp"] = MallSystem.GetMallAllItemsSimpleInfoRsp;

s2c["activity_after_shop_buy_present_notify"] = MallSystem.on_notify_open_chest_present;
