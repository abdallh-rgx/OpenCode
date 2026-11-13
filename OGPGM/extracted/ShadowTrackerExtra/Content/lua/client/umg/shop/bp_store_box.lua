-- 商城开宝箱界面重构
StoreBox_UI = StoreBox_UI or 
{

};

--要开启的宝箱ID
BP_Store_Box_Buy_Item_ID = 0;

-- 第一次显示的页签
BP_Store_Box_Start_index = 0;

-- 当前拥有的炸猪令牌数量
BP_Store_FP_TOKEN_NUM = 0;
--使用选择的货币类型购买
BP_Store_USE_SELECT_PRICE_TYPE = false;

--物品信息(和bp_Shop结构一致,需要一起修改)
BP_STRUCT_StoreBox_ItemInfo =
{
	product_id = 0,
	item_id = 0,
	pruduct_name = "商品名",
	product_desc = "商品描述",
	product_type = 0,
	product_sub_type = 0,
	product_gold_price = 0,
	product_sort = 1,
	item_icon = "",
	price_type = 0,
	ticket_price = 0,
	fp_token_price = 0,--炸猪令牌价格
	is_fp_token_valid = false,--是否可用炸猪令牌购买
	lowest_rounds = 0,
	max_config_rounds = 0,
	start_time = 0,
	end_time = 0,
	is_cur_season = 0,  -- 勇者令积分
	gender = 0,
	key_item_id = 0, -- 开启道具ID
	key_number = 0, -- 道具数量
	have_item_number = 0, -- 拥有道具的数量
	ten_price = 0,
	is_rate_up = false,		-- 概率是否提升
	rate_up_end_time = 0,	-- 概率提升时间结束点
};

--物品信息列表(定义结构体数组：当且仅当以BP_ARRAY_开头的table能作为数组给蓝图访问)
BP_ARRAY_Store_Box_ItemList = 
{
	BP_STRUCT_StoreBox_ItemInfo = _G.BP_STRUCT_StoreBox_ItemInfo, --定义结构体数组，这种写法要作为规范规定下来
};

-- 宝箱掉落数据结构
BP_STRUCT_Store_DropInfo =
{
	DropItemID = 0,
	DropItemNum = 0,
	DropItemTime = 0,
	DropItemSort = 1,
	DropRate_f = 1,		-- 最终概率
	rate_up_end_time = 0,	-- 概率提升时间结束点
};

--要查看的商品可能掉落的物品列表
BP_ARRAY_Store_Box_DropList =
{
	BP_STRUCT_Store_DropInfo = _G.BP_STRUCT_Store_DropInfo,
};

-- 小红点
BP_ARRAY_Store_Box_Hot_Point = 
{
	new = 0;
};
BP_SoreBox_Cur_Select_Item_Weared = false;

BP_STORE_BOX_IS_SELECT_UPGRADE_ITEM = false;



local IsUpdateTabList = false;

--注册Widget
function bp_store_box_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_store_box,
		{{Path="/Game/UMG/UI_LOGIC/Lobby_Store/Store_2/Store_Box_BP2.Store_Box_BP2_C", Container="Default", ZOrder=BP_ENUM_UI_SHOP_ZORDER}},
		{"Lobby"},
		false,
		false,
		true
	);
end

-- 初始化开宝箱界面数据
function StoreBox_UI.Init()
	log("StoreBox_UI.Init");

	LuaClassObj.HandleDynamicCreation(bp_store_box);
	
	if (StoreBox_UI.inited) then
		StoreBox_UI.InitItemList();
		LuaClassObj.HandleUIMessage(bp_store_box, "UpdateShopItemList");
		LuaClassObj.HandleUIMessage(bp_store_box, "UpdateHotPoint");
		IsUpdateTabList = true;
		
		return;
	end

	ShopSystem.shop_itemlist_req(16);

	BP_ARRAY_Store_Box_ItemList = {};
	StoreBox_UI.DropList = {};
	StoreBox_UI.SelectBoxID = 0;
	-- 当前装备在身上的物品ID，BP币载具等不放入此列表
	StoreBox_UI.EquipItemIDs = {};
	StoreBox_UI.SelectItemID = 0;
	StoreBox_UI.SelectItemIndex = 0;

	--EventSystem:registEvent(EVENTTYPE_SHOP, EVENTID_SHOP_UPDATE_LIST, StoreBox_UI.ShopEventHandler);
	EventSystem:registEvent(EVENTTYPE_SHOP, EVENTID_SHOP_ITEM_CONTENT, StoreBox_UI.ShopItemContentEventHandler);
	EventSystem:registEvent(EVENTTYPE_SHOP, EVENTID_SHOP_TIME_OUT, StoreBox_UI.ShopItemTimeOut);
	EventSystem:registEvent(EVENTTYPE_SHOP, EVENTID_SHOP_PRICE_UPDATE, StoreBox_UI.ShopItemPriceUpdate);
	EventSystem:registEvent(EVENTTYPE_SHOP, EVENTID_SHOP_ITEM_KEY_UPDATE, StoreBox_UI.ShopKeyItemUpdate);

	BP_Store_Box_Start_index = 0;

	StoreBox_UI.inited = true;
end

-- 释放资源
function StoreBox_UI.Release()
	log("StoreBox_UI.Release");
	MallSystemUI_2.ForceRevertAvatar()

	LuaClassObj.HandleUIMessage(bp_store_box, "UIHide");
	
	--EventSystem:unregistEvent(EVENTTYPE_SHOP, EVENTID_SHOP_UPDATE_LIST, StoreBox_UI.ShopEventHandler);
	EventSystem:unregistEvent(EVENTTYPE_SHOP, EVENTID_SHOP_ITEM_CONTENT, StoreBox_UI.ShopItemContentEventHandler);
	EventSystem:unregistEvent(EVENTTYPE_SHOP, EVENTID_SHOP_TIME_OUT, StoreBox_UI.ShopItemTimeOut);
	EventSystem:unregistEvent(EVENTTYPE_SHOP, EVENTID_SHOP_PRICE_UPDATE, StoreBox_UI.ShopItemPriceUpdate);
	EventSystem:unregistEvent(EVENTTYPE_SHOP, EVENTID_SHOP_ITEM_KEY_UPDATE, StoreBox_UI.ShopKeyItemUpdate);
	IsUpdateTabList = false;
	StoreBox_UI.inited = false;
end

-- 显示界面
local tempItemId = 0

function StoreBox_UI.Show(boxID, shopid)
	MallSystemUI_2.ForceRevertAvatar()
	
	tempItemId = shopid or 0

	EventSystem:registEvent(EVENTTYPE_SHOP, EVENTID_SHOP_UPDATE_LIST, StoreBox_UI.ShopEventHandler);
	if (boxID ~= nil and boxID ~= 0) then
		log("StoreBox_UI.Show boxID：" .. boxID);
		StoreBox_UI.SelectBoxID = boxID;
		if (#BP_ARRAY_Store_Box_ItemList > 0 and ShopSystem.ItemInfoList[boxID] ~= nil) then
			BP_Store_Box_Buy_Item_ID = boxID;
			LuaClassObj.HandleUIMessage(bp_store_box, "UpdateSelectBox");
		end
	end

	StoreBox_UI.showType = 0;
	MallSystemUI_2.SwitchWeaponShowType(StoreBox_UI.showType);
	LuaClassObj.HandleUIMessage(bp_store_box, "UIShow");
	LuaClassObj.HandleUIMessage(bp_store_box, "UpdateBoxServerTime");

	if (#BP_ARRAY_Store_Box_ItemList > 0) then
		StoreBox_UI.ShowBoxAvatar();
	end
	if IsUpdateTabList then
		MallSystemUI_2.ShowSex();
	end
end

-- 关闭界面
function StoreBox_UI.Hide()
	log("StoreBox_UI.Hide");
	-- MallSystemUI_2.HideSex();
	-- MallSystemUI_2.ResetSex();
	-- MallSystemUI_2:RevertAvatar();
	-- MallSystemUI_2.PutonPreviewAvator();
	EventSystem:unregistEvent(EVENTTYPE_SHOP, EVENTID_SHOP_UPDATE_LIST, StoreBox_UI.ShopEventHandler);
	MallSystemUI_2.ForceRevertAvatar()

	LuaClassObj.HandleUIMessage(bp_store_box, "UIHide");
end

-- 显示小红点信息
function StoreBox_UI.GetHotState()
	log("StoreBox_UI.GetHotState");
	--log_tree("BP_ARRAY_LobbyStoreBoxHotPoint", BP_ARRAY_LobbyStoreBoxHotPoint);
	for i,v in ipairs(BP_ARRAY_LobbyStoreBoxHotPoint) do
		if (v == 1) then
			return true;
		end
	end

	return false;
end

-- 收到商店回包
function StoreBox_UI.ShopEventHandler(eventType, eventID, vars)
	log("StoreBox_UI.ShopEventHandler:" .. eventType);
	log("StoreBox_UI.ShopEventHandler:" .. eventID);
	StoreBox_UI.InitItemList();

	LuaClassObj.HandleUIMessage(bp_store_box, "UpdateShopItemList");

	-- 小红点
	BP_ARRAY_Store_Box_Hot_Point = BP_ARRAY_LobbyStoreBoxHotPoint;
	LuaClassObj.HandleUIMessage(bp_store_box, "UpdateHotPoint");
	IsUpdateTabList = true;
	--StoreBox_UI.ShowBoxAvatar();
	MallSystemUI_2.ShowSex();
end

-- 初始化商店列表
function StoreBox_UI.InitItemList()
	BP_ARRAY_Store_Box_ItemList = {};

	BP_Store_FP_TOKEN_NUM = DataMgr.fp_token;
	-- 这里设置宝箱数据
	for k,v in pairs(ShopSystem.ItemInfoList) do
		v.have_item_number = 0;
		if (v.key_item_id > 0) then
			--v.have_item_number = DataMgr.GetHallDepotItemDataByInsID(v.key_item_id);
			--log("mickey:" .. v.have_item_number);
			local itemData = DataMgr.GetHallDepotItemDataByResID(v.key_item_id);
			if (itemData ~= nil) then
				v.have_item_number = itemData.count;
			end
		end

		table.insert(BP_ARRAY_Store_Box_ItemList, v);
	end
	
	local largeTime = 0
	local product_id = 0
	for i, item in ipairs(BP_ARRAY_Store_Box_ItemList) do
		if item.start_time > largeTime then
			largeTime = item.start_time
			product_id = item.product_id
		end
		
		--log("InitItemList0:" .. item.pruduct_name .. "," .. tostring(item.product_id).. "," .. FuncUtil.FormatTime4(item.start_time))
	end
	
	--如果最新的宝箱时间大于30天，则按照product_sort来排序，否则取最新上架的宝箱，排在第一位
	if FuncUtil.GetServerTimeInSec() - largeTime > 30 * 24 * 3600 then

		--log("InitItemList1:" .. tostring(largeTime) .. "," .. tostring((FuncUtil.GetServerTimeInSec() - largeTime)/(24 * 3600)));
		table.sort(BP_ARRAY_Store_Box_ItemList, function(a, b)
			return a.product_sort > b.product_sort;
		end);
	else
		--log("InitItemList2:"  .. tostring(largeTime) .. "," .. tostring(product_id) .. ",".. tostring((FuncUtil.GetServerTimeInSec() - largeTime)/(24 * 3600)));
		table.sort(BP_ARRAY_Store_Box_ItemList, function(a, b)
			if product_id == a.product_id then
				return true
			end

			if product_id == b.product_id then
				return false
			end
			return  a.product_sort > b.product_sort;
		end);
	end

	--for i, item in ipairs(BP_ARRAY_Store_Box_ItemList) do
	--	log("InitItemList3:" .. item.pruduct_name .. "," .. tostring(item.product_id))
	--end

	if (StoreBox_UI.SelectBoxID ~= 0) then
		log("StoreBox_UI.SelectBoxID:" .. StoreBox_UI.SelectBoxID);
		for i,v in ipairs(BP_ARRAY_Store_Box_ItemList) do
			if (v.product_id == StoreBox_UI.SelectBoxID) then
				BP_Store_Box_Start_index = i - 1;
				break;
			end
		end
	end

	-- log_tree("BP_ARRAY_Store_Box_ItemList", BP_ARRAY_Store_Box_ItemList);
end

function StoreBox_UI.Init_Store_Box_DropList(Store_Box_DropList, list)
	for i, v in ipairs(list) do
		local item = v;
		if v.DropChance ~= nil and v.old_chance ~= nil and v.DropChance ~= 0 and v.old_chance ~= 0 then
			item.DropRate_f = math.ceil(v.DropChance / v.old_chance * 100);
		else
			item.DropRate_f = 1;
		end
		table.insert(Store_Box_DropList, item);
	end

	table.sort(Store_Box_DropList, function(a, b)
		local aTime = a.rate_up_end_time or 0
		aTime = aTime - FuncUtil.GetServerTimeInSec();
		local bTime = b.rate_up_end_time or 0
		bTime = bTime - FuncUtil.GetServerTimeInSec();
		if aTime > 0 and bTime > 0 then
			return a.DropItemSort > b.DropItemSort;
		elseif aTime > 0 and bTime <= 0 then
			return true;
		elseif aTime <= 0 and bTime > 0 then
			return false;
		else
			return a.DropItemSort > b.DropItemSort;
		end
	end);
end
-- 获得物品掉落列表事件
function StoreBox_UI.ShopItemContentEventHandler(eventType, eventID, data)
	log("StoreBox_UI.ShopItemContentEventHandler");
	local id = data[1];
	if (ShopSystem.ItemInfoList[id] == nil) then
		return;
	end

	StoreBox_UI.DropList[id] = data[2];
	log("BP_Store_Box_Buy_Item_ID" .. BP_Store_Box_Buy_Item_ID);
	if (BP_Store_Box_Buy_Item_ID ~= id) then
		return;
	end

	local list = data[2];

	BP_ARRAY_Store_Box_DropList = {}

	StoreBox_UI.Init_Store_Box_DropList(BP_ARRAY_Store_Box_DropList, list)

	-- BP_ARRAY_Store_Box_DropList = data[2];

	-- table.sort(BP_ARRAY_Store_Box_DropList, function(a, b)
	-- 	return a.DropItemSort > b.DropItemSort;
	-- end);

	--log_tree("BP_ARRAY_Store_Box_DropList", BP_ARRAY_Store_Box_DropList);
	-- 显示默认穿戴
	StoreBox_UI.EquipItemIDs = {};
	local itemData = ShopSystem.ItemInfoList[BP_Store_Box_Buy_Item_ID];
	for i,v in ipairs(itemData.preview_items) do
		StoreBox_UI.EquipItemIDs[v] = v;
	end

	-- 跳转处理
	if tempItemId > 0 then
		-- 滑动到指定位置
		for i,v in ipairs(BP_ARRAY_Store_Box_DropList) do
			if v.DropItemID == tempItemId then
				StoreBox_UI.SelectItemIndex = i;
				StoreBox_UI.SelectItemID = v.DropItemID;
				break;
			end
		end
		tempItemId = 0
	else
		StoreBox_UI.SelectItemIndex = 0;
		StoreBox_UI.SelectItemID = 0;
	end
	-- 最后才是更新显示列表
	LuaClassObj.HandleUIMessage(bp_store_box, "UpdateDropItemList");
	MallSystemUI_2.ShowSex();
end

-- 当前宝箱已过期
function StoreBox_UI.ShopItemTimeOut()
	LuaClassObj.HandleUIMessage(bp_store_box, "UpdateBoxServerTime");
	LuaClassObj.HandleUIMessage(bp_store_box, "UpdateBoxTime");
end

-- 价格有更新
function StoreBox_UI.ShopItemPriceUpdate()
	StoreBox_UI.InitItemList();

	LuaClassObj.HandleUIMessage(bp_store_box, "UpdatePrice");
end

-- 开启道具数量更新
function StoreBox_UI.ShopKeyItemUpdate()
	StoreBox_UI.InitItemList();

	LuaClassObj.HandleUIMessage(bp_store_box, "UpdatePrice");
end

-- 日韩版UC箱子购买成功后Adjust打点
function StoreBox_UI.ReportEventUCBox()
	LuaClassObj.HandleUIMessage(bp_store_box, "ReportEventUCBox");
end

-- 宝箱默认装备
function StoreBox_UI.ShowBoxAvatar()
	log("StoreBox_UI.ShowBoxAvatar=====");
	log("EventBoxSelect:" .. BP_Store_Box_Buy_Item_ID);
	local itemData = ShopSystem.ItemInfoList[BP_Store_Box_Buy_Item_ID];
	--log_tree("itemData.preview_items", itemData.preview_items);
	MallSystemUI_2:RevertAvatar();

	--for i,v in ipairs(itemData.preview_items) do
	--	 MallSystemUI_2.ShowItem(v, itemData.gender);
	--end
	MallSystemUI_2.ShowItemList(itemData.preview_items, itemData.gender);

	if (itemData.act ~= nil and itemData.act ~= 0) then
		MallSystemUI_2.ShowItem(itemData.act, itemData.gender);
		BP_STORE_BOX_IS_SELECT_UPGRADE_ITEM = BP_MALL_SYSTEM_IS_SELECT_UPGRADE_ITEM;
		MallSystemUI_2.DisableRoleRotate();
	end
	
end

-- 更新保底次数
function StoreBox_UI.UpdateLowestRounds(shopid, lowest_rounds, max_config_rounds)
	--log_tree("BP_ARRAY_Shop_Box_ItemList", BP_ARRAY_Shop_Box_ItemList);
	for i,v in ipairs(BP_ARRAY_Store_Box_ItemList) do
		if (v.product_id == shopid) then
			v.lowest_rounds = lowest_rounds;
			v.max_config_rounds = max_config_rounds;
			break;
		end
	end

	log("BP_Store_Box_Buy_Item_ID" .. BP_Store_Box_Buy_Item_ID);
	if (shopid == BP_Store_Box_Buy_Item_ID) then
		LuaClassObj.HandleUIMessage(bp_store_box, "UpdateRounds");
	end
end

function StoreBox_UI.PriceTypeSelect(boxId)
	BP_Store_USE_SELECT_PRICE_TYPE = true;
	StoreBox_UI.RequestBuyStoreBox(boxId)
end

function EventShowStorePriceSelect()
	log("EventShowStorePriceSelect");
	StorePriceSelect_UI.Show(BP_Store_Box_Buy_Item_ID);
end

-- 显示宝箱装备
function EventShowStoreBoxAvatar()
	log("EventShowStoreBoxAvatar");
	EventMallSystemStopPlayRedEmtion()
	StoreBox_UI.ShowBoxAvatar();
end


-- 拉取掉落列表
function EventStoreBoxSelect()
	log("EventBoxSelect:" .. BP_Store_Box_Buy_Item_ID);
	if (StoreBox_UI.DropList ~= nil and next(StoreBox_UI.DropList) ~= nil and StoreBox_UI.DropList[BP_Store_Box_Buy_Item_ID] ~= nil) then
		StoreBox_UI.ShopItemContentEventHandler(nil, nil, {BP_Store_Box_Buy_Item_ID, StoreBox_UI.DropList[BP_Store_Box_Buy_Item_ID]});
	else
		ShopSystem.shop_item_content_req(BP_Store_Box_Buy_Item_ID);
	end

	-- 小红点
	for i,v in ipairs(BP_ARRAY_Store_Box_ItemList) do
		if (v.product_id == BP_Store_Box_Buy_Item_ID) then
			if (BP_ARRAY_LobbyStoreBoxHotPoint ~= nil and BP_ARRAY_LobbyStoreBoxHotPoint[i] == 1) then
				--log_tree("BP_ARRAY_LobbyStoreBoxHotPoint:", BP_ARRAY_LobbyStoreBoxHotPoint);
				BP_ARRAY_LobbyStoreBoxHotPoint[i] = 0;
				--log_tree("BP_ARRAY_LobbyStoreBoxHotPoint:", BP_ARRAY_LobbyStoreBoxHotPoint);
				MallSystemUI_2.UpdateFirstTabHotState();
			end
			break;
		end
	end

end

-- 申请打开宝箱,其实是购买宝箱商品
function EventRequestBuyStoreBox()
	StoreBox_UI.RequestBuyStoreBox(BP_Store_Box_Buy_Item_ID)
end
-- 申请打开宝箱,其实是购买宝箱商品
function StoreBox_UI.RequestBuyStoreBox(boxId)
	log("Buy_Item_ID:" .. boxId);
	local itemData = ShopSystem.ItemInfoList[boxId];
	local buyItemData = {[boxId] = {count=1, moneytype=itemData.price_type, gold_price=itemData.product_gold_price, 
                                    ticket_price=itemData.ticket_price, fp_token_price=itemData.fp_token_price, source = MallSystem.Buy_Source or 2; is_cur_season = itemData.is_cur_season; }};
	log_tree("itemData", itemData);

	-- 道具足够直接购买
	if (itemData.key_item_id > 0 and itemData.have_item_number >= itemData.key_number) then
		ShopSystem.shop_buy_req(buyItemData);
		return;
	end

	-- 使用选择的货币类型购买
	if BP_Store_USE_SELECT_PRICE_TYPE then
		BP_Store_USE_SELECT_PRICE_TYPE = false;
		buyItemData[boxId].moneytype = BP_StorePrice_Select_Type;
		ShopSystem.shop_buy_req(buyItemData);
		return;
	else
		local canUseTicket = false;
		if itemData.ticket_price <= DataMgr.ticket and itemData.price_type == 2 then
			canUseTicket = true;
		end

		local canUseGold = false;
		if itemData.product_gold_price <= DataMgr.gold and itemData.price_type == 0 then
			canUseGold = true;
		end

		local canUseFpToken = false;
		log("[yyc] fp_token num = "..tostring(DataMgr.fp_token));
		if itemData.is_fp_token_valid and itemData.fp_token_price <= DataMgr.fp_token then
			canUseFpToken = true;
		end

		--如果uc和炸猪令牌都可以使用，弹出选择窗口
		if canUseTicket and canUseFpToken then
			StorePriceSelect_UI.Show(boxId, itemData.ticket_price, itemData.fp_token_price);
			return;
		end

		if not canUseTicket and not canUseGold and canUseFpToken then
			buyItemData[boxId].moneytype = 102;--炸猪令牌
		end
	end

	local priceType = buyItemData[boxId].moneytype;
	local strBuy = Client.GetTableData("LocalizeRes", "301185").TextValue;
	local tip = "";
	if (priceType == 0) then
		if (itemData.product_gold_price <= DataMgr.gold) then
			tip = FuncUtil.GetLocalizeResStr("301186");
		else
			tip = FuncUtil.GetLocalizeResStr("4827");
		end
	elseif priceType == 102 then--炸猪令牌
		tip = FuncUtil.GetLocalizeResStr("4983");
	else
		if (itemData.ticket_price <= DataMgr.ticket) then
			tip = FuncUtil.GetLocalizeResStr("301372");
		else
			tip = FuncUtil.GetLocalizeResStr("4826");
		end
	end
	tip = (string.gsub(tip, "\'", "\""));
	if (priceType == 2) then
		tip = FuncUtil.LocalizeResFormatByStr(tip, itemData.ticket_price, itemData.pruduct_name);
	elseif priceType == 102 then
		tip = FuncUtil.LocalizeResFormatByStr(tip, itemData.fp_token_price, itemData.pruduct_name);
	else
		tip = FuncUtil.LocalizeResFormatByStr(tip, itemData.product_gold_price, itemData.pruduct_name);
	end

	log("buyItem: " .. tip);
	CommonMessageBoxUI:ShowPanel(2, strBuy, tip, function()
		ShopSystem.shop_buy_req(buyItemData);
		return true;
	end);

	--GlobalData:JumpUrl("game://?module=10505");
end

-- 申请打开宝箱,其实是购买宝箱商品
function EventRequestBuyTenStoreBox()
	StoreBox_UI.RequestBuyTenStoreBox(BP_Store_Box_Buy_Item_ID)
end

-- 申请打开宝箱,其实是购买宝箱商品
function StoreBox_UI.RequestBuyTenStoreBox(boxId)
	log("Buy_Item_ID:" .. boxId);
	local itemData = ShopSystem.ItemInfoList[boxId];
	local buyItemData = {[boxId] = {count=10, moneytype=itemData.price_type, gold_price=itemData.product_gold_price, 
                                    ticket_price=itemData.ticket_price, source = MallSystem.Buy_Source or 2; is_cur_season = itemData.is_cur_season; }};
	-- 道具足够直接购买
	if (itemData.key_item_id > 0 and itemData.have_item_number >= itemData.key_number * 10) then
		ShopSystem.shop_buy_req(buyItemData);
		return;
	end
	
	local strBuy = Client.GetTableData("LocalizeRes", "301185").TextValue;
	local tip = "";
	if (itemData.price_type == 0) then
		if (itemData.ten_price <= DataMgr.gold) then
			tip = FuncUtil.GetLocalizeResStr("301186");
		else
			tip = FuncUtil.GetLocalizeResStr("4827");
		end
	else
		if (itemData.ten_price <= DataMgr.ticket) then
			tip = FuncUtil.GetLocalizeResStr("301372");
		else
			tip = FuncUtil.GetLocalizeResStr("4826");
		end
	end
	tip = (string.gsub(tip, "\'", "\""));
	tip = FuncUtil.LocalizeResFormatByStr(tip, itemData.ten_price, itemData.pruduct_name);

	log("buyItem: " .. tip);
	CommonMessageBoxUI:ShowPanel(2, strBuy, tip, function()
		
		ShopSystem.shop_buy_req(buyItemData);
		return true;
	end);
end

-- 显示掉落概率
function EventStoreBoxShowRatePanel()
	local data = ShopSystem.ItemInfoList[BP_Store_Box_Buy_Item_ID];
	if (data == nil) then
		return;
	end

	if #data.drop_rate > 0 then
		Rate_Panel_UI.Show(data.drop_rate);
	end
end

-- 切换显示类型
function EventStoreBoxSwitchShowType()
	if (StoreBox_UI.showType == 0) then
		StoreBox_UI.showType = 1;
	else
		StoreBox_UI.showType = 0;
	end
	log("StoreBox_UI.showType" .. StoreBox_UI.showType);
	MallSystemUI_2.SwitchWeaponShowType(StoreBox_UI.showType);
end

function EventSetInfo_Push()
end

function EventFetchInfo()
end

----------------------------------------------------------
-- 蓝图调用lua
----------------------------------------------------------
-- 获取当前选中的物品
function StoreBox_UI.B2LGetSelectItemInfo()
	--返回itemId和index(传给蓝图需要-1)
	return StoreBox_UI.SelectItemID, (StoreBox_UI.SelectItemIndex-1);
end

-- 当前物品是否有装备
function StoreBox_UI.B2LIsEquip(itemId)
	if not StoreBox_UI.EquipItemIDs or 
	   not StoreBox_UI.EquipItemIDs[itemId] then
		return false;
	end
	return true;
end

--  点击选中物品 ----  展示且装备物品
function StoreBox_UI.B2LDropItemClick(itemId, index)
	log("StoreBox_UI.B2LDropItemClick:" .. tostring(itemId));
	if itemId == 0 then
		return;
	end

	StoreBox_UI.showType = 0;
	MallSystemUI_2.SwitchWeaponShowType(StoreBox_UI.showType);
	
	StoreBox_UI.SelectItemID = itemId;
	StoreBox_UI.SelectItemIndex = index+1;--lua的索引加1

	local data = ShopSystem.ItemInfoList[BP_Store_Box_Buy_Item_ID];
	if not data then
		log("data is nil");
		return;
	end
	local tempID,showSex = MallSystemUI_2.ShowItem(itemId, data.gender);
	
	BP_STORE_BOX_IS_SELECT_UPGRADE_ITEM = BP_MALL_SYSTEM_IS_SELECT_UPGRADE_ITEM;
	--sami 注意，一定放在上面代码下面
	BP_SoreBox_Cur_Select_Item_Weared = MallSystemUI_2:IsWear(StoreBox_UI.SelectItemID)
	
	if (tempID ~= nil and tempID ~= 0) then
		-- 如果前者是同类型的装备，则取下的前者，返回前者的ID
		log("tempID" .. tempID);
		StoreBox_UI.EquipItemIDs[itemId] = itemId;
		StoreBox_UI.EquipItemIDs[tempID] = nil;
	else
		-- 之前没有装备同类型的，直接装上
		StoreBox_UI.EquipItemIDs[itemId] = itemId;
	end
	if showSex then
		MallSystemUI_2.ShowSex();
	else
		MallSystemUI_2.HideSex();
	end
end


--sami 点击红装表情动画播放按钮
function EventStoreBoxClickRedEmtion()
	log("EventStoreBoxClickRedEmtion")
	if os.time() - MallSystemUI_2.nLastPlayEmotionTime < 5 then
		ShowNotice(120178);
		return
	end
	MallSystemUI_2.nLastPlayEmotionTime = os.time()
	
	EventStoreBoxStartPlayRedEmtion()
end
--启动播放表情定时器
function EventStoreBoxStartPlayRedEmtion()
	local itemId = StoreBox_UI.SelectItemID
	local cfg = Client.GetTableData("Item", itemId)
	if cfg == nil or cfg.RedEmotionId == 0 or cfg.RedEmotionPlayCD <= 0 then
		return
	end
	
	EventMallSystemStopPlayRedEmtion()
	
	if MallSystemUI_2:IsWear(itemId) then
		MallSystemUI_2.DoEmoteAction(cfg.RedEmotionId)
	end
	
	
	
	MallSystemUI_2.nPlayEmotionTimerId = Timer.InsertTimer(cfg.RedEmotionPlayCD, function()
		EventStoreBoxClickRedEmtion()
	end, true, false)
end
--停止播放表情定时器
function EventStoreBoxStopPlayRedEmtion()
	EventMallSystemStopPlayRedEmtion()
end

function EventStoreBoxClickJumpToItemUpgrade()
	--local itemData = ShopSystem.ItemInfoList[BP_Store_Box_Buy_Item_ID];
	--log("EventMallSystemClickJumpToItemUpgrade!!!!!!!!!!!!!!!"..itemData.act)
	if (MallSystemUI_2.showItemId ~= nil and MallSystemUI_2.showItemId ~= 0) then
	local itemCfg = Client.GetTableData("Item", MallSystemUI_2.showItemId);
		if itemCfg ~= nil then
			ItemUpgradeUI.mallSystemCallBack = nil;
			local UpgradeItemShowID = MallSystemUI_2.showItemId
			EventStartCloseMallSystem();
			ItemUpgradeUI.ShowByItemID(UpgradeItemShowID);
		end
	end
end