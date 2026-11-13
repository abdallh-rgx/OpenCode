-- 商城开宝箱界面UI
Direct_Purchase_UI = Direct_Purchase_UI or {
	isShowing = false;
	inited = false;
}


-- 直购信息
BP_STRUCT_Direct_Purchase_Info =
{
	id = 0,                -- 直购表ID
	product_id = "",       -- 直购ProductID
	item_id = 0,           -- 直购物品ID
	pruduct_name = "",     -- 直购物品名称
	product_desc = "",     -- 直购物品描述
	product_price = "",    -- 直购显示价格
	product_sort = 1,      -- 直购排序
	item_icon = "",        -- 直购Icon
	limit = 0,             -- 数量限制
	show_item = "",        -- 试穿物品列表
	have_buy_num = 0,      -- 已购数量
	zoneId = "",           -- 米大师区ID
	goodsZoneId = "",      -- 米大师商品分区ID
	payItem = 0,           -- 米大师购买数量
	price = 0,             -- 显示价格
	midasPrice = "",       -- 米大师物品价格
	country = "",          -- 米大师购买国家
	currency = "",         -- 购买国家货币
	end_time = 0,         -- 下架时间
};

-- 直购购买ID
BP_Direct_Purchase_Product_ID = 0;

-- 掉落物品ID
BP_Direct_Purchase_DropItem_ID = 0;

-- 直购信息列表(定义结构体数组：当且仅当以BP_ARRAY_开头的table能作为数组给蓝图访问)
BP_ARRAY_Direct_Purchase_ItemList = 
{
	BP_STRUCT_Direct_Purchase_Info = _G.BP_STRUCT_Direct_Purchase_Info, --定义结构体数组，这种写法要作为规范规定下来
};

-- 宝箱掉落数据结构
BP_STRUCT_Shop_DropInfo =
{
	DropItemID = 0,
	DropItemNum = 0,
	DropItemTime = 0,
	DropItemSort = 1;
};

BP_Direct_Purchase_Time = 0;

--要查看的商品可能掉落的物品列表
BP_ARRAY_Direct_Purchase_DropList =
{
	BP_STRUCT_Shop_DropInfo = _G.BP_STRUCT_Shop_DropInfo,
};

-- 判断日本版本是否需要年龄设置
BP_Direct_Purchasee_Need_Set_Age = false;

-- 日本版本当前年龄，默认值20岁，不限额
BP_Direct_Purchase_JPAge = 20;

--注册Widget
function bp_direct_purchase_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_direct_purchase,
		{{Path="/Game/UMG/UI_LOGIC/Lobby_Store/Direct_Purchase_BP.Direct_Purchase_BP_C", Container="Default", ZOrder=BP_ENUM_UI_DIRECT_PRUCHASE_ZORDER}},
		{"Lobby"},
		false,
		false,
		true
	);
	EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_LOBBY_MENU_PURCHASE_BOX, Direct_Purchase_UI.ShowUI);
end

function Direct_Purchase_UI.ShowUI()
	log("Direct_Purchase_UI.ShowUI");
	Direct_Purchase_UI.Init();
	Direct_Purchase_UI.Show();
end

-- 初始化开宝箱界面数据
function Direct_Purchase_UI.Init()
	log("Direct_Purchase_UI.Init:"..tostring(Direct_Purchase_UI.inited));
	if (Direct_Purchase_UI.inited) then
		return;
	end
	LuaClassObj.HandleDynamicCreation(bp_direct_purchase);

	MallSystem.GetDirectBuyInfoReq();

	EventSystem:registEvent(EVENTTYPE_MALL, EVENTID_MALL_DIRECT_BUY_INFO, Direct_Purchase_UI.DirectPurchaseInfoEventHandler);
	EventSystem:registEvent(EVENTTYPE_MALL, EVENTID_MALL_GET_DROP_LIST, Direct_Purchase_UI.GetDropList);

	Direct_Purchase_UI.DropList = {};
	Direct_Purchase_UI.waiting = false;
	Direct_Purchase_UI.inited = true;
end

-- 释放资源
function Direct_Purchase_UI.Release()
	log("Direct_Purchase_UI.Release");
	LuaClassObj.HandleUIMessage(bp_direct_purchase, "UIHide");

	EventSystem:unregistEvent(EVENTTYPE_MALL, EVENTID_MALL_DIRECT_BUY_INFO, Direct_Purchase_UI.DirectPurchaseInfoEventHandler);
	EventSystem:unregistEvent(EVENTTYPE_MALL, EVENTID_MALL_GET_DROP_LIST, Direct_Purchase_UI.GetDropList);
	EventSystem:unregistEvent(EVENTTYPE_MIDAS_NOTIFY, EVENTID_MIDAS_GET_GOODS_PRODUCT_INFO_NOTIFY, Direct_Purchase_UI.GetMidasGoodsInfo);
	EventSystem:unregistEvent(EVENTTYPE_MIDAS_NOTIFY, EVENTID_MIDAS_BUY_GOODS_NOTIFY, Direct_Purchase_UI.BuyGoodsMidasNotify);
	
	Direct_Purchase_UI.inited = false;
end

-- 显示界面
function Direct_Purchase_UI.Show()
	Direct_Purchase_UI.isShowing = true;
	log("Direct_Purchase_UI.Show");
	LuaClassObj.HandleUIMessage(bp_direct_purchase, "UIShow");

	EventSystem:registEvent(EVENTTYPE_MIDAS_NOTIFY, EVENTID_MIDAS_BUY_GOODS_NOTIFY, Direct_Purchase_UI.BuyGoodsMidasNotify);
	EventSystem:registEvent(EVENTTYPE_MIDAS_NOTIFY, EVENTID_MIDAS_GET_GOODS_PRODUCT_INFO_NOTIFY, Direct_Purchase_UI.GetMidasGoodsInfo);
end

-- 播放入场动画
function Direct_Purchase_UI.PlayShow()
	LuaClassObj.HandleUIMessage(bp_direct_purchase, "PlayShow");
end

-- 关闭界面
function Direct_Purchase_UI.Hide()
	Direct_Purchase_UI.isShowing = false;
	log("Direct_Purchase_UI.Hide");
	LuaClassObj.HandleUIMessage(bp_direct_purchase, "UIHide");
	Direct_Purchase_UI.RevertAvatar();

	EventSystem:unregistEvent(EVENTTYPE_MIDAS_NOTIFY, EVENTID_MIDAS_GET_GOODS_PRODUCT_INFO_NOTIFY, Direct_Purchase_UI.GetMidasGoodsInfo);
	EventSystem:unregistEvent(EVENTTYPE_MIDAS_NOTIFY, EVENTID_MIDAS_BUY_GOODS_NOTIFY, Direct_Purchase_UI.BuyGoodsMidasNotify);
end

-- 收到商店回包
function Direct_Purchase_UI.DirectPurchaseInfoEventHandler(eventType, eventID, vars)
	if eventType ~= EVENTTYPE_MALL then
		return;
	end
	
	if eventID == EVENTID_MALL_DIRECT_BUY_INFO then
		--BP_ARRAY_Direct_Purchase_ItemList = vars;

		--log_tree("vars", vars);

		BP_ARRAY_Direct_Purchase_ItemList = {};

		local product_ids = "";

		for k,v in pairs(vars) do
			if (FuncUtil:StringTimeToUnixTime(v.box_info.open_time) < FuncUtil.GetServerTimeInSec()) then
				local item_data = Client.GetTableData("Item", v.box_info.item_id);
				local data = {
					id = v.id,
					product_id = v.box_info.productid,
					item_id = v.box_info.item_id,
					pruduct_name = "",
					product_desc = "",
					product_price = v.box_info.price,
					product_sort = v.box_info.display_sort,
					item_icon = v.box_info.icon,
					limit = v.box_info.limit,
					show_item = v.box_info.show_item,
					have_buy_num = v.have_buy_num,
					zoneId = v.box_info.zoneID,
					goodsZoneId = v.box_info.goodsZoneId, 
					payItem = v.box_info.payItem,
					price = 99.99,
					midasPrice = v.box_info.midasPrice,
					country = v.box_info.country,
					currency = v.box_info.curency_unit,
					end_time = FuncUtil:StringTimeToUnixTime(v.box_info.end_time),
				};

				if (item_data ~= nil) then
					data.pruduct_name = item_data.ItemName;
					data.product_desc = item_data.ItemDesc;
				end

				if (product_ids == "") then
					product_ids = data.product_id;
				else
					product_ids = product_ids .. "," .. data.product_id;
				end

				table.insert(BP_ARRAY_Direct_Purchase_ItemList, data);
			end
		end

		-- 排序
		table.sort(BP_ARRAY_Direct_Purchase_ItemList, function(a, b)
			return a.product_sort < b.product_sort;
		end);

		--log_tree("BP_ARRAY_Direct_Purchase_ItemList", BP_ARRAY_Direct_Purchase_ItemList);

		--EventShowItemEquip();

		BP_Direct_Purchase_Time = FuncUtil.GetServerTimeInSec();

		LuaClassObj.HandleUIMessage(bp_direct_purchase, "InitDirectPurchaseList");

		-- 拉取米大师价格
		local isProductInfoCached,cachedProductInfoList = MidasManager.LoadCachedMidasProductInfo(product_ids);
		if isProductInfoCached == true then
			--取缓存价格
			Direct_Purchase_UI.GetMidasGoodsInfo(EVENTTYPE_MIDAS_NOTIFY, EVENTID_MIDAS_GET_GOODS_PRODUCT_INFO_NOTIFY, cachedProductInfoList);
		else
			--需要重新拉取
			EventStoreShowWaitingUI();

			log("product_ids" .. product_ids);
			Client.LoadMidasProductInfo(product_ids);

			LuaClassObj.HandleUIMessage(bp_direct_purchase, "GetGoodsInfo");
		end
		
	end
end

-- 客户端米大师回调
function Direct_Purchase_UI.BuyGoodsMidasNotify(eventType, eventID, result)
	-- 米大师失败重置按钮
	if result ~= "0" then
		EventStoreHideWaitingUI();

		LuaClassObj.HandleUIMessage(bp_direct_purchase, "BuyGoodsNotify");
	end
end

-- 拉取米大师接口回调
function Direct_Purchase_UI.GetMidasGoodsInfo(evenType, eventID, resultTable)
	log("Direct_Purchase_UI.GetMidasGoodsInfo");

	if (resultTable == nil) then
		log("拉取数据失败");
		EventStoreHideWaitingUI();
		return;
	end

	--log_tree("resultTable", resultTable);
    for k,product in pairs(resultTable) do
    	if MidasManager.ShouldShowLocalCurrency(product.currency) == false then
    		-- 不是特殊货币,直接显示配置表里美元
    		log("不是特殊货币,直接显示配置表里美元");
    		EventStoreHideWaitingUI();
    		return;
     	end

		if product.productId ~= nil and product.price ~= nil then
			for i,v in pairs(BP_ARRAY_Direct_Purchase_ItemList) do
				if (product.productId == v.product_id) then
					log("找到一个productId:" .. product.productId);
					v.product_price = product.price;
				end
			end
		end
    end
    
    LuaClassObj.HandleUIMessage(bp_direct_purchase, "UpdateDirectPurchaseList");

    LuaClassObj.HandleUIMessage(bp_direct_purchase, "GetGoodsInfoNotify");

    EventStoreHideWaitingUI();
end

-- 收到掉落列表
function Direct_Purchase_UI.GetDropList(eventType, eventID, data)
	-- 缓存数据
	Direct_Purchase_UI.DropList[data[1]] = data[2];

	if (BP_Direct_Purchase_Product_ID ~= data[1]) then
		return;
	end

	BP_ARRAY_Direct_Purchase_DropList = data[2];

	table.sort(BP_ARRAY_Direct_Purchase_DropList, function(a, b)
		return a.DropItemSort > b.DropItemSort;
	end);

	--log_tree("BP_ARRAY_Direct_Purchase_DropList", BP_ARRAY_Direct_Purchase_DropList);
	LuaClassObj.HandleUIMessage(bp_direct_purchase, "ShowDropList");

	for k,v in pairs(BP_ARRAY_Direct_Purchase_ItemList) do
		if (v.id == BP_Direct_Purchase_Product_ID) then
			local items = string.split(v.show_item, ",");
			--log_tree("v.show_item", items);
			for i,v in ipairs(items) do
				BP_Direct_Purchase_DropItem_ID = v;
				LuaClassObj.HandleUIMessage(bp_direct_purchase, "SetAvatarPart");
			end
		end
	end
	log("mickey");
	if (Direct_Purchase_UI.waiting) then
		ConnectionWaitingUI:Show();
	end
end

-- 购买成功回调
function Direct_Purchase_UI.BuyGoodsNotify(id, limit_num)
	log("Direct_Purchase_UI.BuyGoodsNotify:" .. limit_num);
	for k,v in pairs(BP_ARRAY_Direct_Purchase_ItemList) do
		if (v.id == id) then
			v.have_buy_num = limit_num;
		end
	end

	EventStoreHideWaitingUI();

	LuaClassObj.HandleUIMessage(bp_direct_purchase, "BuyGoodsNotify");

	LuaClassObj.HandleUIMessage(bp_direct_purchase, "UpdateDirectPurchaseList");
end

-- 显示装备Avatar
function Direct_Purchase_UI.EquipAvatar(itemid)

end

-- 重置装备
function Direct_Purchase_UI.RevertAvatar()

end

-- 穿装备
function EventEquipDropItemAvatar()
	log("BP_Direct_Purchase_DropItem_ID" .. BP_Direct_Purchase_DropItem_ID);
	Direct_Purchase_UI.EquipAvatar(BP_Direct_Purchase_DropItem_ID);
end

-- 试穿数据
function EventShowItemEquip()
	--[[
	log("EventShowItemEquip");
	for k,v in pairs(BP_ARRAY_Direct_Purchase_ItemList) do
		if (v.id == BP_Direct_Purchase_Product_ID) then
			local items = string.split(v.show_item, ",");
			--log_tree("v.show_item", items);
			if (#items > 0) then
				Direct_Purchase_UI.RevertAvatar();
			end
			for i,v in ipairs(items) do
				Direct_Purchase_UI.EquipAvatar(v);
			end
		end
	end

	-- 拉取列表
	log("BP_Direct_Purchase_Product_ID:" .. BP_Direct_Purchase_Product_ID);
	if (Direct_Purchase_UI.DropList[BP_Direct_Purchase_Product_ID] == nil) then
		MallSystem.DirectBuyContentReq(BP_Direct_Purchase_Product_ID);
	else
		Direct_Purchase_UI.GetDropList(nil, nil, {BP_Direct_Purchase_Product_ID, Direct_Purchase_UI.DropList[BP_Direct_Purchase_Product_ID]});
	end
	]]
end


-- 隐藏等待框
function EventStoreHideWaitingUI()
	log("EventStoreHideWaitingUI");
	Direct_Purchase_UI.waiting = false;
	ConnectionWaitingUI:Hide();
end

-- 显示等待框
function EventStoreShowWaitingUI()
	log("EventStoreShowWaitingUI");
	Direct_Purchase_UI.waiting = true;
	ConnectionWaitingUI:Show();
end

function EventSetInfo_Push()
end

function EventFetchInfo()
end

function EventDirectPurchaseGetJPAge()
    if DataMgr.jp_age ~= nil then
        BP_Direct_Purchasee_Need_Set_Age = false;
        BP_Direct_Purchase_JPAge = DataMgr.jp_age;
    else
        BP_Direct_Purchasee_Need_Set_Age = true;
    end
    log("[HHF]EventDirectPurchaseGetJPAge, BP_Direct_Purchasee_Need_Set_Age=" .. tostring(BP_Direct_Purchasee_Need_Set_Age) .. " BP_Direct_Purchase_JPAge=" .. tostring(BP_Direct_Purchase_JPAge));
end

-- 点击关闭按钮
function EventClickCloseBtn()
	Direct_Purchase_UI.Release()
end
