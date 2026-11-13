---代金券功能
---UI展示
---zimingwang
CouponsUI = CouponsUI or {
	isShowing = false;
}
BP_Buy_MONEY_NUM = 0;
BP_Buy_MONEY_1_NUM = 0;
BP_Buy_DIAMOND_NUM = 0;
-- 商品物品结构
BP_STRUCT_Buy_Coupons_Item_Info = 
{
	shopID = 0,                   -- shopID
	itemID = 0,                   -- 物品ID
	count  = 0,                   -- 物品数量
	quality = 0,                  -- 物品品质
	itemName = "",                -- 物品名称
	priceType = 0,                -- 货币类型
	price = 0,                    -- 原始价格
	isGet = false,                    -- 是否拥有
	limitNum = 0,				  --限购次数
	limitType = 1,					--限购类型
	isCanSend = false,                    -- 是否能赠送
	colorID = 0,
	patternID = 0,
};

BP_ARRAY_Buy_List = 
{
	BP_STRUCT_Buy_Coupons_Item_Info = _G.BP_STRUCT_Buy_Coupons_Item_Info, --定义结构体数组，这种写法要作为规范规定下来
};

BP_STRUCT_Coupon = 
{
	itemID = 0,
	price = 0,

}
BP_ARRAY_Cur_Coupons_List = 
{
	BP_STRUCT_Coupon = _G.BP_STRUCT_Coupon,
}

BP_CurOldPrice = 0; --折扣前价格
BP_CurNewPrice = 0;	--折扣后价格
BP_Count_Buy = 1;	--购买数量默认1
BP_IsShowMutiBuy = false;	--控制是否显示批量购买
BP_CurClickedItemID = 0;
OldSinglePrice = 0;		--原来单价
BP_CurClickedIndex = 0;	--点击第几个代金券

local curInfo = nil;
local curBuyInfo = nil;
local curShopInfo = nil;
local curVersion = nil;
local Curvoucher = 0;

--注册Widget
function bp_coupons_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_coupons,
	{{Path="/Game/UMG/UI_Logic/Shop/Coupons_Logic_BP.Coupons_Logic_BP_C", Container="Default", ZOrder=47},
	},
	{"Lobby"},
	false,
	true
	);
end
function bp_coupons_OnModeSwitched(gamestatus)
	log("bp_coupons_OnModeSwitched gamestatus = " .. gamestatus);
	status = string.lower(gamestatus);
	if status == "lobby" then
		if CouponsUI.isShowing == true then
			--hide
			CouponsUI.ClearData()
		end

		CouponsUI.isShowing = false;
	end

	-- 回到登录场景清数据
    if string.lower(gamestatus) == "login" then
        CouponsUI.ClearData()
    end

end
function CouponsUI.Init()
	-- body
	log("CouponsUI Init");
	BP_Count_Buy = 1
	CouponsUI.isShowing = true;
	LuaClassObj.HandleDynamicCreation(bp_coupons);
end

--初始化数据给UI显示调用
function CouponsUI.SetData(shopInfo, buyInfo, colorID, patternID, version)
	-- body
	BP_Buy_MONEY_1_NUM = DataMgr.diamond
	BP_ARRAY_Cur_Coupons_List = {}
	for i=1, #shopInfo.voucher do
		local tempprice = CouponsSystem.GetDisCountValueByID(shopInfo.voucher[i])
		local temp = {itemID = shopInfo.voucher[i],price = tempprice}
		if CouponsSystem.IsHasThisCoupon(shopInfo.voucher[i]) then
			table.insert(BP_ARRAY_Cur_Coupons_List, temp)
		end
	end
	if BP_ARRAY_Cur_Coupons_List and #BP_ARRAY_Cur_Coupons_List > 0 then
		local data = shopInfo;
		local resItem = Client.GetTableData("Item",data.item_id);
		local isGet = MallSystemUI_2.IsHasItem(data.item_id, colorID, patternID);
		local moneyType,moneyPrice = MallSystemUI_2.get_money_type_and_price(data.id, 1, data);
		local colorPatternCost = MallSystemUI_2.get_color_and_pattern_cost(colorID, patternID);
		curVersion = version;

		-- 购买数量
		local itemBuyInfo = buyInfo;
		local buyNum = 1000000;
		local limitType = 1;
		if (shopInfo.daily_buy_limit > 0 or shopInfo.week_buy_limit > 0 or shopInfo.permanet_buy_limit > 0) then
			if itemBuyInfo ~= nil then
				if (shopInfo.daily_buy_limit > 0) then
					buyNum = math.min(buyNum, shopInfo.daily_buy_limit - itemBuyInfo.daily_buy_cnt);
					limitType = 1;
				end
				if (shopInfo.week_buy_limit > 0) then
					buyNum = math.min(buyNum, shopInfo.week_buy_limit - itemBuyInfo.week_buy_cnt);
					limitType = 2;
				end
				if (shopInfo.permanet_buy_limit > 0) then
					buyNum = math.min(buyNum, shopInfo.permanet_buy_limit - itemBuyInfo.permanet_buy_cnt);
					limitType = 3;
				end
			end
		end
		local limitCount = buyNum;
		local limitType = limitType;
		
		local tempBuyInfo = {
					shopID = data.id;
					itemID = data.item_id;
					count = data.item_count;
					quality = resItem.ItemQuality;
					itemName = resItem.ItemName;
					priceType = moneyType;
					price = moneyPrice + colorPatternCost;
					isGet = isGet;
					limitNum = limitCount;
					limitType = limitType;
					isCanSend = data.gift_open == 1;
					colorID = colorID or 0;
					patternID = patternID or 0;
		};
		
		BP_CurOldPrice = tempBuyInfo.price
		OldSinglePrice = BP_CurOldPrice
		BP_ARRAY_Buy_List = {tempBuyInfo};
		curBuyInfo = buyInfo;
		curShopInfo = shopInfo;
		curInfo = tempBuyInfo;
		if resItem.ItemType == 15 or resItem.ItemType == 21 then
			BP_IsShowMutiBuy = true
		else
			BP_IsShowMutiBuy = false
		end
		BP_CurClickedIndex = #BP_ARRAY_Cur_Coupons_List
		LuaClassObj.HandleUIMessage(bp_coupons, "UIShow");
		UIManager.Show(eUIType.eCoupons)
		LuaClassObj.HandleUIMessage(bp_coupons, "LuaUpdateUI");
		CouponsUI.SetDefaultClick();
	end
end

function CouponsUI.SetDefaultClick()
	local tempitemcouponsid = BP_ARRAY_Cur_Coupons_List[#BP_ARRAY_Cur_Coupons_List].itemID
	BP_CurClickedItemID = tempitemcouponsid
	log("zino BP_CurClickedItemID  " .. BP_CurClickedItemID)
	if #BP_ARRAY_Cur_Coupons_List == 1 then
		EventClickCoupon1()
	elseif #BP_ARRAY_Cur_Coupons_List == 2 then
		EventClickCoupon2()
	elseif #BP_ARRAY_Cur_Coupons_List == 3 then
		EventClickCoupon3()
	end
end

function CouponsUI.ClearData( ... )
	-- body
	BP_CurOldPrice = 0; --折扣前价格
	BP_CurNewPrice = 0;	--折扣后价格
	BP_Count_Buy = 1;	--购买数量默认1
	BP_IsShowMutiBuy = false;	--控制是否显示批量购买
	OldSinglePrice = 0;		--原来单价
	UIManager.Hide(eUIType.eCoupons)
	LuaClassObj.HandleUIMessage(bp_coupons, "UIHide");
	CouponsUI.isShowing = false;
end
function EventHideUI( ... )
	-- body
	CouponsUI.isShowing = false;
end
--点击代金券事件
function EventClickCoupon1( ... )
	BP_CurClickedIndex = 1
	BP_CurNewPrice = BP_CurOldPrice - BP_ARRAY_Cur_Coupons_List[1].price
	if BP_CurNewPrice < 0 then 
		BP_CurNewPrice = 0
	end 
	Curvoucher = BP_ARRAY_Cur_Coupons_List[1].itemID
	log("zino BP_ARRAY_Cur_Coupons_List[1].itemID " .. BP_ARRAY_Cur_Coupons_List[1].itemID)
	LuaClassObj.HandleUIMessage(bp_coupons, "UISetCurPrice");
	LuaClassObj.HandleUIMessage(bp_coupons, "UIChooseSelection");
	
end
function EventClickCoupon2( ... )
	BP_CurClickedIndex = 2
	BP_CurNewPrice = BP_CurOldPrice - BP_ARRAY_Cur_Coupons_List[2].price
	if BP_CurNewPrice < 0 then 
		BP_CurNewPrice = 0
	end 
	Curvoucher = BP_ARRAY_Cur_Coupons_List[2].itemID
	log("zino BP_ARRAY_Cur_Coupons_List[2].itemID " .. BP_ARRAY_Cur_Coupons_List[2].itemID)
	LuaClassObj.HandleUIMessage(bp_coupons, "UISetCurPrice");
	LuaClassObj.HandleUIMessage(bp_coupons, "UIChooseSelection");
end
function EventClickCoupon3( ... )
	BP_CurClickedIndex = 3
	BP_CurNewPrice = BP_CurOldPrice - BP_ARRAY_Cur_Coupons_List[3].price
	if BP_CurNewPrice < 0 then 
		BP_CurNewPrice = 0
	end 
	Curvoucher = BP_ARRAY_Cur_Coupons_List[3].itemID
	log("zino BP_ARRAY_Cur_Coupons_List[3].itemID " .. BP_ARRAY_Cur_Coupons_List[3].itemID)
	LuaClassObj.HandleUIMessage(bp_coupons, "UISetCurPrice");
	LuaClassObj.HandleUIMessage(bp_coupons, "UIChooseSelection");
end
function EventClickMallBuy()
	if Curvoucher then
		log("zino Curvoucher " .. Curvoucher)
	end
	if BP_IsShowMutiBuy then	--批量购买
		if BP_Count_Buy > curInfo.limitNum then
			if curInfo.limitType == 1 then
				DataMgr.ShowNoticeByID(4350);
			elseif curInfo.limitType == 2 then
				DataMgr.ShowNoticeByID(4351);
			elseif curInfo.limitType == 3 then
				DataMgr.ShowNoticeByID(4352);
			end
			return;
		end
		local dict = {};
		table.insert(dict,{id = curInfo.shopID,num = BP_Count_Buy,shopInfo = curShopInfo, buyInfo = curBuyInfo, colorID = curInfo.colorID, patternID = curInfo.patternID});
		MallSystemUI_2.BuyShopItems(dict,curVersion,Curvoucher);
		MallBuyItemWithCountUI:Release()
	else
		if 1 > curInfo.limitNum then
			if curInfo.limitType == 1 then
				DataMgr.ShowNoticeByID(4350);
			elseif curInfo.limitType == 2 then
				DataMgr.ShowNoticeByID(4351);
			elseif curInfo.limitType == 3 then
				DataMgr.ShowNoticeByID(4352);
			end
			return;
		end
		local dict = {};
		table.insert(dict,{id = curInfo.shopID,num = 1, shopInfo = curShopInfo, buyInfo = curBuyInfo, colorID = curInfo.colorID, patternID = curInfo.patternID});
		MallSystemUI_2.BuyShopItems(dict,curVersion,Curvoucher);
	end
	CouponsUI.ClearData();
end
--点击增加购买数量，要刷新价格
function EventClickAdd()
	BP_Count_Buy = BP_Count_Buy + 1
	BP_CurOldPrice = BP_CurOldPrice + OldSinglePrice
	local tempprice = CouponsSystem.GetDisCountValueByID(BP_CurClickedItemID)
	BP_CurNewPrice = BP_CurOldPrice - tempprice  --加一个原价
	if BP_CurNewPrice < 0 then
		BP_CurNewPrice = 0
	end
	LuaClassObj.HandleUIMessage(bp_coupons, "UIRefreshBuyNum");
end

function EventClickAdd10()
	-- body
	BP_Count_Buy = BP_Count_Buy + 10
	BP_CurOldPrice = BP_CurOldPrice + 10*OldSinglePrice
	local tempprice = CouponsSystem.GetDisCountValueByID(BP_CurClickedItemID)
	BP_CurNewPrice = BP_CurOldPrice - tempprice --加10个原价
	if BP_CurNewPrice < 0 then
		BP_CurNewPrice = 0
	end
	LuaClassObj.HandleUIMessage(bp_coupons, "UIRefreshBuyNum");
end

function EventClickDecrease()
	-- body
	if BP_Count_Buy > 1 then
		-- body
		BP_CurOldPrice = BP_CurOldPrice - OldSinglePrice 
		local tempprice = CouponsSystem.GetDisCountValueByID(BP_CurClickedItemID)
		BP_CurNewPrice = BP_CurOldPrice - tempprice  --减去1个原价
		if BP_CurNewPrice < 0 then
			BP_CurNewPrice = 0
		end
		BP_Count_Buy = BP_Count_Buy -1
		LuaClassObj.HandleUIMessage(bp_coupons, "UIRefreshBuyNum");
	end
end