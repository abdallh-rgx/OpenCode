--商城物品购买
MallBuyItemUI = MallBuyItemUI or
{
	isShowing = false;
}
-- 商品物品结构
BP_STRUCT_Buy_Item_Info = 
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
	priceType2 = 0, 			-- 第二货币类型
	price2 = 0,     			-- 第二货币价格
};

BP_ARRAY_Single_Buy_List = 
{
	BP_STRUCT_Buy_Item_Info = _G.BP_STRUCT_Buy_Item_Info, --定义结构体数组，这种写法要作为规范规定下来
};

BP_Single_Buy_MONEY_NUM = 0;
BP_Single_Buy_MONEY_1_NUM = 0;
BP_Single_Buy_DIAMOND_NUM = 0;

BP_Single_Buy_Cur_ShopId = 0;
local curBuyInfo = nil;
local curShopInfo = nil;
local curInfo = nil;
local curVersion = nil;

--注册Widget
function bp_mall_buy_item_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_mall_buy_item,
	{{Path="/Game/UMG/UI_Logic/Lobby_Store/Mall_Buy_Item_BP.Mall_Buy_Item_BP_C", Container="Default", ZOrder=BP_ENUM_UI_RECHARGE_ZORDER},
	},
	{"Lobby"},
	false,
	true
	);

end

function bp_mall_buy_item_OnModeSwitched(gamestatus)
	log("bp_mall_buy_item_OnModeSwitched gamestatus = " .. gamestatus);
	status = string.lower(gamestatus);
	if status == "lobby" then
		if MallBuyItemUI.isShowing == true then
			--hide
			UIManager.Hide(eUIType.eMallBuy)
			LuaClassObj.HandleUIMessage(bp_mall_buy_item, "UIHide");
			MallBuyItemUI:Release();
		end

		MallBuyItemUI.isShowing = false;
	end

	-- 回到登录场景清数据
    if string.lower(gamestatus) == "login" then
        MallBuyItemUI:ReleaseData()
    end

end

function EventMallBuyItemHide()
	MallBuyItemUI.isShowing = false;
end


function MallBuyItemUI:Init()
	if MallBuyItemUI.isShowing then
		return;
	end

	log("MallBuyItemUI Init");
	MallBuyItemUI.isShowing = true;

	LuaClassObj.HandleDynamicCreation(bp_mall_buy_item);
	LuaClassObj.HandleUIMessage(bp_mall_buy_item, "UIShow");
	UIManager.Show(eUIType.eMallBuy)

	BP_Single_Buy_MONEY_NUM = DataMgr.gold;
	BP_Single_Buy_MONEY_1_NUM = DataMgr.diamond;
	BP_Single_Buy_DIAMOND_NUM = DataMgr.ticket;
	LuaClassObj.HandleUIMessage(bp_mall_buy_item, "SetMoney");
	-- --hide 所有的主界面
	-- EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN)
	-- --显示 商城的主界面 动画
	-- LuaClassObj.HandleUIMessage(bp_mall_system, "UIShowMallAvatarAni");
	-- LuaClassObj.HandleUIMessage(bp_mall_system, "SwitchCameraMall");
end

function MallBuyItemUI.SetData(shopInfo, buyInfo, colorID, patternID, version)
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
	
	
	BP_ARRAY_Single_Buy_List = {tempBuyInfo};
	curBuyInfo = buyInfo;
	curShopInfo = shopInfo;
	curInfo = tempBuyInfo;
	LuaClassObj.HandleUIMessage(bp_mall_buy_item, "LuaSetData");
end

function MallBuyItemUI:Release()
	UIManager.Hide(eUIType.eMallBuy)
	LuaClassObj.HandleUIMessage(bp_mall_buy_item, "UIHide");
	MallBuyItemUI:ReleaseData()
end


function MallBuyItemUI:ReleaseData()
end

function EventMallSingleBuy()
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
	MallSystemUI_2.BuyShopItems(dict,curVersion);
	MallBuyItemUI:Release()
end

function EventMallSingleSendItem()
	MallSystemUI_2.SendShopItem(curShopInfo,curBuyInfo,curInfo.colorID,curInfo.patternID);
	MallBuyItemUI:Release()
end
