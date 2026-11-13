-- 礼包
StoreGiftBox_UI = StoreGiftBox_UI or {
	
};

--要开启的宝箱ID
BP_Store_GiftBox_Buy_Item_ID = 0;

-- 点击的掉落物品
BP_Store_GiftBox_Select_Drop_ID = 0;

-- 当前服务器时间
BP_Store_GiftBox_Time = 0;

-- 穿着使用的临时ID
BP_Store_GiftBox_Equip_Item_ID = 0;

-- 开始显示的标签
BP_Store_GiftBox_Start_index = 0;

--物品信息(和bp_Shop结构一致,需要一起修改)
BP_STRUCT_Store_GiftBox_ItemInfo =
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
	lowest_rounds = 0,
	max_config_rounds = 0,
	start_time = 0,
	end_time = 0,
	is_cur_season = 0,  -- 勇者令积分
	got_num = 0,
};

--物品信息列表(定义结构体数组：当且仅当以BP_ARRAY_开头的table能作为数组给蓝图访问)
BP_ARRAY_Store_Gift_Box_ItemList = 
{
	BP_STRUCT_Store_GiftBox_ItemInfo = _G.BP_STRUCT_Store_GiftBox_ItemInfo, --定义结构体数组，这种写法要作为规范规定下来
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
	DropRate_f = 1;			-- 最终概率
	rate_up_end_time = 0;	-- 概率提升时间结束点
};

--要查看的商品可能掉落的物品列表
BP_ARRAY_Store_GiftBox_DropList =
{
	BP_STRUCT_Store_DropInfo = _G.BP_STRUCT_Store_DropInfo,
};

-- 小红点
BP_ARRAY_Store_GiftBox_Hot_Point = 
{
	new = 0;
};

BP_Store_GiftBox_JumpIndex = 0

local IsUpdateTabList = false;
--注册Widget
function bp_store_gift_box_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_store_gift_box,
		{{Path="/Game/UMG/UI_LOGIC/Lobby_Store/Store_2/Store_Gift_Box_BP.Store_Gift_Box_BP_C", Container="Default", ZOrder=BP_ENUM_UI_SHOP_ZORDER}},
		{"Lobby"},
		false,
		false,
		true
	);
end

-- 初始化开宝箱界面数据
function StoreGiftBox_UI.Init()
	log("StoreGiftBox_UI.Init");
	if (StoreGiftBox_UI.inited) then
		return;
	end

	LuaClassObj.HandleDynamicCreation(bp_store_gift_box);

	ShopSystem.shop_itemlist_req(17);
	BP_ARRAY_Store_Gift_Box_ItemList = {};
	StoreGiftBox_UI.DropList = {};
	StoreGiftBox_UI.SelectBoxID = 0;
	-- 购买限制
	StoreGiftBox_UI.LimitInfo = {};

	EventSystem:registEvent(EVENTTYPE_SHOP, EVENTID_SHOP_GIFT_BOX_LIST, StoreGiftBox_UI.ShopEventHandler);
	EventSystem:registEvent(EVENTTYPE_SHOP, EVENTID_SHOP_ITEM_CONTENT, StoreGiftBox_UI.ShopItemContentEventHandler);
	EventSystem:registEvent(EVENTTYPE_SHOP, EVENTID_SHOP_GIFT_LIMIT_UPDATE, StoreGiftBox_UI.ShopItemUpdate);

	BP_Store_GiftBox_Start_index = 0;
	BP_Store_GiftBox_Select_Drop_ID = 0;
	BP_Store_GiftBox_Equip_Item_ID = 0;
	BP_Store_GiftBox_Start_index = 0;

	StoreGiftBox_UI.inited = true;
end

-- 释放资源
function StoreGiftBox_UI.Release()
	log("StoreGiftBox_UI.Release");
	LuaClassObj.HandleUIMessage(bp_store_gift_box, "UIHide");
	
	EventSystem:unregistEvent(EVENTTYPE_SHOP, EVENTID_SHOP_GIFT_BOX_LIST, StoreGiftBox_UI.ShopEventHandler);
	EventSystem:unregistEvent(EVENTTYPE_SHOP, EVENTID_SHOP_ITEM_CONTENT, StoreGiftBox_UI.ShopItemContentEventHandler);
	EventSystem:unregistEvent(EVENTTYPE_SHOP, EVENTID_SHOP_GIFT_LIMIT_UPDATE, StoreGiftBox_UI.ShopItemUpdate);
	IsUpdateTabList = false;
	StoreGiftBox_UI.inited = false;
end

-- 显示界面
local tempItemId = 0

function StoreGiftBox_UI.Show(boxID,itemId)
	MallSystemUI_2.SetEquipBG(0)
	MallSystemUI_2.ShowWeapon(0,0,false)
	MallSystemUI_2:RevertAvatar()
	MallSystemUI_2.StopEmoteAction()
	
	BP_Store_GiftBox_JumpIndex = 0
	tempItemId = itemId or 0

	if (boxID ~= nil and boxID ~= 0) then
		log("StoreGiftBox_UI.Show boxID：" .. boxID);
		StoreGiftBox_UI.SelectBoxID = boxID;
		if (#BP_ARRAY_Store_Gift_Box_ItemList > 0 and ShopSystem.ItemInfoList[boxID] ~= nil) then
			for i,v in ipairs(BP_ARRAY_Store_Gift_Box_ItemList) do
				if (v.product_id == boxID) then
					BP_Store_GiftBox_Start_index = i - 1
				end
			end
		end
	end

	-- log("StoreGiftBox_UI.Show startIndex "..startIndex);
	-- log_tree("BP_ARRAY_Store_Gift_Box_ItemList",BP_ARRAY_Store_Gift_Box_ItemList)
	-- if (startIndex ~= nil) then
	-- 	-- for i,box in ipairs(BP_ARRAY_Store_Gift_Box_ItemList) do
	-- 	-- 	-- print(i,v)
	-- 	-- 	if box.
	-- 	-- end
	-- 	BP_Store_GiftBox_Start_index = startIndex;
	-- end

	StoreGiftBox_UI.showType = 0;
	MallSystemUI_2.SwitchWeaponShowType(StoreGiftBox_UI.showType);
	LuaClassObj.HandleUIMessage(bp_store_gift_box, "UIShow");

	if (#BP_ARRAY_Store_Gift_Box_ItemList > 0) then
		StoreGiftBox_UI.ShowBoxAvatar();

		local itemData = ShopSystem.GiftBoxList[BP_Store_GiftBox_Buy_Item_ID];
		for i,v in ipairs(itemData.preview_items) do
			BP_Store_GiftBox_Equip_Item_ID = v;
			LuaClassObj.HandleUIMessage(bp_store_gift_box, "EquipItem");
		end
	end
	if IsUpdateTabList then
		MallSystemUI_2.ShowSex();
	end
end

-- 关闭界面
function StoreGiftBox_UI.Hide()
	log("StoreGiftBox_UI.Hide");
	MallSystemUI_2.HideSex();
	MallSystemUI_2.ResetSex();
	MallSystemUI_2:RevertAvatar();
	LuaClassObj.HandleUIMessage(bp_store_gift_box, "UIHide");
end

-- 显示小红点信息
function StoreGiftBox_UI.GetHotState()
	log("StoreGiftBox_UI.GetHotState");
	--log_tree("BP_ARRAY_LobbyStoreGiftBoxHotPoint", BP_ARRAY_LobbyStoreGiftBoxHotPoint);
	for i,v in ipairs(BP_ARRAY_LobbyStoreGiftBoxHotPoint) do
		if (v == 1) then
			return true;
		end
	end

	return false;
end

-- 收到商店回包
function StoreGiftBox_UI.ShopEventHandler(eventType, eventID, vars)
	log("StoreGiftBox_UI.ShopEventHandler:" .. eventType);
	log("StoreGiftBox_UI.ShopEventHandler:" .. eventID);
	StoreGiftBox_UI.InitItemList();

	BP_Store_GiftBox_Time = FuncUtil.GetServerTimeInSec();

	LuaClassObj.HandleUIMessage(bp_store_gift_box, "UpdateShopItemList");

	--StoreGiftBox_UI.ShowBoxAvatar();

	-- 小红点
	BP_ARRAY_Store_GiftBox_Hot_Point = BP_ARRAY_LobbyStoreGiftBoxHotPoint;
	LuaClassObj.HandleUIMessage(bp_store_gift_box, "UpdateHotPoint");

	IsUpdateTabList = true;
	MallSystemUI_2.ShowSex();
end

-- 初始化商店列表
function StoreGiftBox_UI.InitItemList()
	BP_ARRAY_Store_Gift_Box_ItemList = {};

	-- 这里设置宝箱数据
	for k,v in pairs(ShopSystem.GiftBoxList) do
		table.insert(BP_ARRAY_Store_Gift_Box_ItemList, v);
	end

	table.sort(BP_ARRAY_Store_Gift_Box_ItemList, function(a, b)
		return a.product_sort > b.product_sort;
	end);

	-- StoreGiftBox_UI.SelectBoxID = boxID;
	-- if (#BP_ARRAY_Store_Gift_Box_ItemList > 0 and ShopSystem.ItemInfoList[boxID] ~= nil) then
	-- 	for i,v in ipairs(BP_ARRAY_Store_Gift_Box_ItemList) do
	-- 		if (v.product_id == boxID) then
	-- 			BP_Store_GiftBox_Start_index = i
	-- 		end
	-- 	end
	-- end

	if (StoreGiftBox_UI.SelectBoxID ~= 0) then
		for i,v in ipairs(BP_ARRAY_Store_Gift_Box_ItemList) do
			if (v.product_id == StoreGiftBox_UI.SelectBoxID) then
				BP_Store_GiftBox_Start_index = i - 1;
				break;
			end
		end
	end

	--log_tree("BP_ARRAY_Store_Gift_Box_ItemList", BP_ARRAY_Store_Gift_Box_ItemList);
end

-- 获得物品掉落列表事件
function StoreGiftBox_UI.ShopItemContentEventHandler(eventType, eventID, data)
	log("StoreGiftBox_UI.ShopItemContentEventHandler");
	local id = data[1];
	if (ShopSystem.GiftBoxList[id] == nil) then
		return;
	end
	StoreGiftBox_UI.DropList[id] = data[2];

	log("BP_Store_GiftBox_Buy_Item_ID" .. BP_Store_GiftBox_Buy_Item_ID);
	if (BP_Store_GiftBox_Buy_Item_ID ~= id) then
		return;
	end

	BP_ARRAY_Store_GiftBox_DropList = data[2];

	table.sort(BP_ARRAY_Store_GiftBox_DropList, function(a, b)
		return a.DropItemSort > b.DropItemSort;
	end);

	log_tree("BP_ARRAY_Store_GiftBox_DropList", BP_ARRAY_Store_GiftBox_DropList);
	LuaClassObj.HandleUIMessage(bp_store_gift_box, "UpdateDropItemList");
	
	-- 显示默认穿戴
	local itemData = ShopSystem.GiftBoxList[BP_Store_GiftBox_Buy_Item_ID];
	for i,v in ipairs(itemData.preview_items) do
		BP_Store_GiftBox_Equip_Item_ID = v;
		LuaClassObj.HandleUIMessage(bp_store_gift_box, "EquipItem");
	end
	--StoreGiftBox_UI.UpdateDropUsed();
	-- 跳转处理
	if tempItemId ~= 0 then
		log("=================跳转处理 "..BP_Store_GiftBox_Select_Drop_ID)
		-- 滑动到指定位置
		for i,v in ipairs(BP_ARRAY_Store_GiftBox_DropList) do
			if v.DropItemID == tempItemId then
				BP_Store_GiftBox_JumpIndex = i
			end
		end		
		log("==================BP_Store_GiftBox_JumpIndex "..BP_Store_GiftBox_JumpIndex)
		LuaClassObj.HandleUIMessage(bp_store_box, "JumpToItem");
		-- 

		local lastID = BP_Store_GiftBox_Select_Drop_ID
		BP_Store_GiftBox_Select_Drop_ID = tempItemId
		EventStoreGiftBoxDropItemSelect()
		LuaClassObj.HandleUIMessage(bp_store_gift_box, "SelectItemByItemID");
		BP_Store_Box_Equip_Item_ID = BP_Store_GiftBox_Select_Drop_ID;
		LuaClassObj.HandleUIMessage(bp_store_gift_box, "EquipItem");

		BP_Store_GiftBox_Select_Drop_ID = lastID
		tempItemId = 0
	end
	MallSystemUI_2.ShowSex();
end


-- 价格有更新
function StoreGiftBox_UI.ShopItemUpdate(id)
	StoreGiftBox_UI.InitItemList();

	LuaClassObj.HandleUIMessage(bp_store_gift_box, "UpdateItem");
end

-- 宝箱默认装备
function StoreGiftBox_UI.ShowBoxAvatar()
	log("StoreGiftBox_UI.ShowBoxAvatar");
	log("EventBoxSelect:" .. BP_Store_GiftBox_Buy_Item_ID);
	local itemData = ShopSystem.GiftBoxList[BP_Store_GiftBox_Buy_Item_ID];
	--log_tree("itemData.preview_items", itemData.preview_items);
	MallSystemUI_2:RevertAvatar();

	--for i,v in ipairs(itemData.preview_items) do
	--	 MallSystemUI_2.ShowItem(v, itemData.gender);
	--end
	MallSystemUI_2.ShowItemList(itemData.preview_items, itemData.gender);

	if (itemData.act ~= nil and itemData.act ~= 0) then
		MallSystemUI_2.ShowItem(itemData.act, itemData.gender);
		MallSystemUI_2.DisableRoleRotate();
	end
	
end


-- 拉取掉落列表
function EventGiftBoxSelect()
	log("EventBoxSelect:" .. BP_Store_GiftBox_Buy_Item_ID);
	if (StoreGiftBox_UI.DropList ~= nil and next(StoreGiftBox_UI.DropList) ~= nil and StoreGiftBox_UI.DropList[BP_Store_GiftBox_Buy_Item_ID] ~= nil) then
		StoreGiftBox_UI.ShopItemContentEventHandler(nil, nil, {BP_Store_GiftBox_Buy_Item_ID, StoreGiftBox_UI.DropList[BP_Store_GiftBox_Buy_Item_ID]});
	else
		ShopSystem.shop_item_content_req(BP_Store_GiftBox_Buy_Item_ID);
	end

	-- 小红点
	for i,v in ipairs(BP_ARRAY_Store_Gift_Box_ItemList) do
		if (v.product_id == BP_Store_GiftBox_Buy_Item_ID) then
			if (BP_ARRAY_LobbyStoreGiftBoxHotPoint ~= nil and BP_ARRAY_LobbyStoreGiftBoxHotPoint[i] == 1) then
				--log_tree("BP_ARRAY_LobbyStoreGiftBoxHotPoint:", BP_ARRAY_LobbyStoreGiftBoxHotPoint);
				BP_ARRAY_LobbyStoreGiftBoxHotPoint[i] = 0;
				--log_tree("BP_ARRAY_LobbyStoreGiftBoxHotPoint:", BP_ARRAY_LobbyStoreGiftBoxHotPoint);
				MallSystemUI_2.UpdateFirstTabHotState();
			end
			break;
		end
	end
end

-- 申请打开宝箱,其实是购买宝箱商品
function EventRequestBuyGiftBox()
	log("Buy_Item_ID:" .. BP_Store_GiftBox_Buy_Item_ID);
	local itemData = ShopSystem.GiftBoxList[BP_Store_GiftBox_Buy_Item_ID];
	--log_tree("itemData", itemData);
	local strBuy = Client.GetTableData("LocalizeRes", "301185").TextValue;
	local tip = "";
	if (itemData.price_type == 0) then
		if (itemData.product_gold_price <= DataMgr.gold) then
			tip = FuncUtil.GetLocalizeResStr("301186");
		else
			tip = FuncUtil.GetLocalizeResStr("4827");
		end
	else
		if (itemData.ticket_price <= DataMgr.ticket) then
			tip = FuncUtil.GetLocalizeResStr("301372");
		else
			tip = FuncUtil.GetLocalizeResStr("4826");
		end
	end
	tip = (string.gsub(tip, "\'", "\""));
	if (itemData.price_type == 2) then
		tip = FuncUtil.LocalizeResFormatByStr(tip, itemData.ticket_price, itemData.pruduct_name);
	else
		tip = FuncUtil.LocalizeResFormatByStr(tip, itemData.product_gold_price, itemData.pruduct_name);
	end

	log("buyItem: " .. tip);
	CommonMessageBoxUI:ShowPanel(2, strBuy, tip, function()
		local buyItemData = {[BP_Store_GiftBox_Buy_Item_ID] = {count=1, moneytype=itemData.price_type, gold_price=itemData.product_gold_price, ticket_price=itemData.ticket_price}};
		ShopSystem.shop_buy_req(buyItemData);
		return true;
	end);
end

-- 显示宝箱装备
function EventShowStoreGiftBoxAvatar()
	log("EventShowStoreGiftBoxAvatar");
	StoreGiftBox_UI.ShowBoxAvatar();
end

-- 点击试穿衣服
function EventStoreGiftBoxDropItemSelect()
	log("BP_Store_GiftBox_Select_Drop_ID:" .. BP_Store_GiftBox_Select_Drop_ID);
	if (BP_Store_GiftBox_Select_Drop_ID == 0) then
		return;
	end

	local data = ShopSystem.GiftBoxList[BP_Store_GiftBox_Buy_Item_ID];
	local tempID, showSex = MallSystemUI_2.ShowItem(BP_Store_GiftBox_Select_Drop_ID, data.gender);
	if (tempID ~= nil and tempID ~= 0) then
		BP_Store_GiftBox_Equip_Item_ID = tempID;
		LuaClassObj.HandleUIMessage(bp_store_gift_box, "UnEquipItem");
	end
	if showSex then
		MallSystemUI_2.ShowSex();
	else
		MallSystemUI_2.HideSex();
	end
end

-- 切换显示类型
function EventStoreGiftBoxSwitchShowType()
	if (StoreGiftBox_UI.showType == 0) then
		StoreGiftBox_UI.showType = 1;
	else
		StoreGiftBox_UI.showType = 0;
	end
	log("StoreGiftBox_UI.showType" .. StoreGiftBox_UI.showType);
	MallSystemUI_2.SwitchWeaponShowType(StoreGiftBox_UI.showType);
end

function EventSetInfo_Push()
end

function EventFetchInfo()
end