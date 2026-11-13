
--[[
 商城相关逻辑
]]--

ShopSystem = ShopSystem or
{
	--可售商品总表
	ItemInfoList = {},
	--上次购买的商品id
	LastBuyInfo = {},
	--商城宝箱ID列表
	BoxList = {},
	BoxIcon = {},

	GoldBoxIndex = 0,--BP宝箱id
	JumpBoxIndex = 0, --打脸图跳转
	
	ItemPlayModleList = {},
}

function ShopSystem.Enter()
	log("ShopSystem enter"); 
	ShopSystem.shop_itemlist_req();
end

--请求物品列表
function ShopSystem.shop_itemlist_req(shopType)
	if StoreSystem.IsUseNewStore() then
		return
	end
	log("shop_itemlist_req");
	--NetUtil.SendPkg("shop_itemlist_req");
	NetUtil.SendPriorityPkg(false, "shop_itemlist_rsp", "shop_itemlist_req", shopType);
end

-- 请求商店掉落
function ShopSystem.shop_item_content_req(shopid)
	if StoreSystem.IsUseNewStore() then
		return
	end
	NetUtil.SendPriorityPkg(false, "shop_item_content_rsp", "shop_item_content_req", shopid);
end

--请求单个物品信息
function ShopSystem.get_single_shopitem(shop_item_id)
	if StoreSystem.IsUseNewStore() then
		return
	end
	log("get_single_shopitem:");
	NetUtil.SendPriorityPkg(false, "get_single_shopitem_rsp", "get_single_shopitem", shop_item_id);
end

--请求购买
function ShopSystem.shop_buy_req(itemsInfo)
	log("shop_buy_req");
	if itemsInfo == nil or next(itemsInfo) == nil then
		return;
	end
	ShopSystem.LastBuyInfo = itemsInfo;
	log_tree("itemsInfo", itemsInfo);
	NetUtil.SendPriorityPkg(false, "shop_buy_rsp", "shop_buy_req", itemsInfo);
end

-- 获取商品购买次数
function ShopSystem.get_shop_limit_info(shopId)
	NetUtil.SendPriorityPkg(false, "get_shop_limit_info_rsp", "get_shop_limit_info", shopId);
end

function ShopSystem.updateItemInfo(shopId, newItemInfo)
	-- 修改原有商店逻辑,宝箱信息全部由服务器下发

	--if shopdata ~= nil then
	--[[
    local icon;
    for _,chestDropInfo in pairs(BP_ARRAY_ChestDrop) do
        if chestDropInfo.ChestID == v.itemid then
            icon = chestDropInfo.ChestIcon;
            break;
        end
    end
    ]]
	ShopSystem.ItemInfoList[shopId] =
	{
		product_id = shopId,
		item_id = newItemInfo.itemid,
		pruduct_name = translate(newItemInfo.shop_name),
		product_desc = translate(newItemInfo.shop_desc),
		product_type = newItemInfo.shop_type,
		product_sub_type = newItemInfo.subtype,
		product_gold_price = newItemInfo.gold_price,
		product_sort = newItemInfo.display_sort,
		item_icon = newItemInfo.icon,
		price_type = newItemInfo.price_type,
		fp_token_price = newItemInfo.fp_token_price or 0,--炸猪令牌价格
		is_fp_token_valid = newItemInfo.is_fp_token_valid or false,--是否可用炸猪令牌购买
		ticket_price = newItemInfo.ticket_price,
		lowest_rounds = newItemInfo.lowest_rounds,
		max_config_rounds = newItemInfo.max_config_rounds,
		preview_items = newItemInfo.preview_items;
		drop_rate = newItemInfo.drop_rate;
		start_time = newItemInfo.begin_time;
		end_time = newItemInfo.end_time;
		icon = newItemInfo.box_icon;
		is_cur_season = newItemInfo.is_cur_season,  -- 勇者令积分、
		gender = newItemInfo.gender,--预览性别
		key_item_id = newItemInfo.key_item_id, -- 开启宝箱的道具ID 
		key_number = newItemInfo.key_number, -- 宝箱需要的数量
		ten_price = newItemInfo.ten_price,  -- 十连抽价格
		play_modle = newItemInfo.play_modle, -- 预览类型
		act = newItemInfo.act,               -- 播放动作
		is_rate_up = newItemInfo.is_rate_up,  -- 是否概率提升
		rate_up_end_time = newItemInfo.rate_up_end_time,	-- 概率提升结束时间
	};

	log_tree("updateItemInfo:", ShopSystem.ItemPlayModleList);

	log_tree("updateItemInfo1:", newItemInfo);

	ShopSystem.ItemPlayModleList[newItemInfo.itemid] = newItemInfo.play_modle;

	local itemData = Client.GetTableData("Item", newItemInfo.itemid);
	if itemData ~= nil then
		ShopSystem.ItemInfoList[shopId].pruduct_name = itemData.ItemName;
		ShopSystem.ItemInfoList[shopId].product_desc = itemData.ItemDesc;
	end
end

--获取列表响应
function ShopSystem.on_itemlist_rsp(res, itemlist, itemType)
	log("on_itemlist_rsp: " .. res);

	--log_tree("itemlist", itemlist);

     --刷新列表信息
    if res == "ok" then
    	-- 新的商城宝箱,使用原有商店协议,类型17
    	if (itemType == 17) then
    		ShopSystem.GetStoreGiftBox(itemlist);
    		return;
    	end

		ShopSystem.ItemInfoList = {};
		ShopSystem.ItemPlayModleList= {};
		
		for k,v in pairs(itemlist) do
			local shopId = tonumber(k);
			ShopSystem.updateItemInfo(shopId, v)
		end

		-- 宝箱ID列表,小红点用
		local tempList = {};
		for k,v in pairs(ShopSystem.ItemInfoList) do
			table.insert(tempList, v);
		end

		table.sort(tempList, function(a, b)
			return a.product_sort > b.product_sort;
		end);
		
		for i,v in ipairs(tempList) do 
			if v.price_type == 0 then
				ShopSystem.GoldBoxIndex = v.product_id
			end
		end

		ShopSystem.BoxList = {};
		for i,v in ipairs(tempList) do
			table.insert(ShopSystem.BoxList, v.product_id);
		end

		ShopSystem.BoxIcon = {};
		for i,v in ipairs(tempList) do
			table.insert(ShopSystem.BoxIcon, ShopSystem.ItemInfoList[v.product_id].icon);
		end
		--log_tree("ShopSystem.BoxIcon", ShopSystem.BoxIcon);
		EventSystem:postEvent(EVENTTYPE_MALL, EVENTID_MALL_UPDATE_BOX_COUNT, #ShopSystem.BoxIcon);

		--log_tree("ItemInfoList", ShopSystem.ItemInfoList);

		--更新商店蓝图数据
		EventSystem:postEvent(EVENTTYPE_SHOP, EVENTID_SHOP_UPDATE_LIST);
    else
        sandbox.LogNormal("on_itemlist_rep failed ");
    end
end

-- 收到服务器商城宝箱消息
function ShopSystem.GetStoreGiftBox(itemlist)
	ShopSystem.GiftBoxList = {};
	--log_tree("itemlist", itemlist);
	for k,v in pairs(itemlist) do
		local shopId = tonumber(k);

		ShopSystem.GiftBoxList[shopId] = 
		{
			product_id = shopId,
			item_id = v.itemid,
			pruduct_name = translate(v.shop_name),
			product_desc = translate(v.shop_desc),
			product_type = v.shop_type,
			product_sub_type = v.subtype,
			product_gold_price = v.gold_price,
			product_sort = v.display_sort,
			item_icon = v.icon,
			price_type = v.price_type,
			ticket_price = v.ticket_price,
			lowest_rounds = v.lowest_rounds,
			max_config_rounds = v.max_config_rounds,
			preview_items = v.preview_items;
			drop_rate = v.drop_rate;
			start_time = v.begin_time;
			end_time = v.end_time;
			icon = v.box_icon;
			is_cur_season = v.is_cur_season,  -- 勇者令积分
			gender = v.gender,                --预览性别
			got_num = v.item_got_num,         -- 已购买次数
			act = v.act,
		};

		local itemData = Client.GetTableData("Item", v.itemid);
		if itemData ~= nil then
			ShopSystem.GiftBoxList[shopId].pruduct_name = itemData.ItemName;
			ShopSystem.GiftBoxList[shopId].product_desc = itemData.ItemDesc;
		end
	end

    -- 宝箱ID列表,小红点用
	local tempList = {};
	for k,v in pairs(ShopSystem.GiftBoxList) do
		table.insert(tempList, v);
	end

	ShopSystem.BoxGiftList = {};
	for i,v in ipairs(tempList) do
		table.insert(ShopSystem.BoxGiftList, v.product_id);
	end

	EventSystem:postEvent(EVENTTYPE_SHOP, EVENTID_SHOP_GIFT_BOX_LIST);
end

--商城-礼包页签
--打脸图跳转礼包时调用，打脸图阶段，StoreGiftBox_UI.InitItemList()还未调用，所以在此处获取boxId对应的index
function ShopSystem.GetGiftBoxIndex(boxId)
	local ans = 0;
	local tmpGiftBox = {};

	for k,v in pairs(ShopSystem.GiftBoxList) do
		table.insert(tmpGiftBox, {id = v.product_id, sort = v.product_sort});
	end

	table.sort(tmpGiftBox, function(a, b)
		return a.sort > b.sort;
	end);

	--log_tree("xzx tmpGiftBox:", tmpGiftBox);

	for i, v in pairs(tmpGiftBox) do
		if v.id == boxId then
			log("xzx boxId = "..boxId..", i = "..i);
			ans = i - 1
			break
		end
	end
	
	return ans
end

function ShopSystem.getBoxIndex(shopid)
	log("shopid = "..shopid)
	ShopSystem.JumpBoxIndex = 0;
	if ShopSystem.BoxList ~= nil then
		log_tree("BoxList:", ShopSystem.BoxList)
		for i, v in ipairs(ShopSystem.BoxList) do
			if shopid == v then
				ShopSystem.JumpBoxIndex = i;
				return
			end
		end
	end
end

function ShopSystem.GetShopItemInfoByKeyItemId(keyItemId)
	if StoreSystem.IsUseNewStore() then
		if StoreSystem.supply_data ~= nil then
			local list = StoreSystem.supply_data.supply_list;
			if list ~= nil then
				for _,info in pairs(list) do
					local exchangeId = info[StoreSystem.label_shop_index_exchange_id];
					if exchangeId ~= nil and exchangeId == keyItemId then
						return info;
					end
				end
			end
		end
	else
		for _,itemInfo in pairs(ShopSystem.ItemInfoList) do
			if itemInfo.key_item_id == keyItemId then
				return itemInfo;
			end
		end
	end
	return nil;
end

-- 是否有概率提升的商品
function ShopSystem.HasRateUpItem()
	for k,v in pairs(ShopSystem.GiftBoxList) do
		if v.rate_up then
			return true;
		end
	end
	return false;
end

function ShopSystem.get_single_shopitem_rsp(res, shop_item)
	log("get_single_shopitem_rsp: " .. res);
	    
    if res == "ok" then
		local shopId = tonumber(shop_item.itemid);
		local iteminfo = ShopSystem.ItemInfoList[shopId];
		if iteminfo ~= nil then
			local update = iteminfo.product_gold_price ~= shop_item.gold_price;
			--价格发生变化才更新界面
			if update then
				iteminfo.product_gold_price = shop_item.gold_price;
				--更新商店蓝图数据
				EventSystem:postEvent(EVENTTYPE_SHOP, EVENTID_SHOP_PRICE_UPDATE);
			end
			if ShopUI.isBuying == true then
				--弹出购买提示框
				ShopUI:BuyItem(shopId);
			end
		end
    end
end

--购买物品响应
function ShopSystem.on_buy_rsp(res, itemlist)
    if res == "ok" then
		sandbox.LogNormal("on_buy_rsp success ");
		--拉取购买商品的id
		ShopUI.isBuying = false;
		for k,v in pairs(itemlist) do
			local shopId = tonumber(k);
			ShopSystem.get_single_shopitem(shopId);
		end
		--某些物品需要弹出获得提示
		local arrayItemData = {};
		for k,v in pairs(itemlist) do
			local shopId = tonumber(k);
			log("ShopSystem.on_buy_rsp shopid " .. tostring(shopId));
			local iteminfo = ShopSystem.ItemInfoList[shopId];
			if iteminfo ~= nil then
				local itemdata = Client.GetTableData("Item", iteminfo.item_id);
				log("ShopSystem.on_buy_rsp item_id " .. tostring(iteminfo.item_id));
				if itemdata ~= nil and itemdata.ItemSubType ~= 1501 then
					--不是商城直接购买打开的道具加入数组
					table.insert(arrayItemData, {res_id = iteminfo.item_id, count = v});
				end
				-- 日韩版UC箱子Adjust打点
				local strRegion = Client.GetPublishRegion();
				if strRegion == "JAPAN" or strRegion == "KOREA" then
					if 20002 <= shopId and shopId <= 20599 then
						StoreBox_UI.ReportEventUCBox();
					end
				end
			end
		end
		if #arrayItemData > 0 then
			CommonItemGetUI:ShowPanel(arrayItemData);
		end

		EventSystem:postEvent(EVENTTYPE_SHOP, EVENTID_SHOP_ITEM_KEY_UPDATE);
    else
		sandbox.LogNormal("on_buy_rsp failed :" .. res);
		if (res == 9910010) then
			-- 打开充值界面
			local title = Client.GetTableData("LocalizeRes", "101001").TextValue;
			local tip = Client.GetTableData("LocalizeRes", "4119").TextValue;
			CommonMessageBoxUI:ShowPanel(2, title, tip, function()
					RechargeUI:Init();
				return true;
			end);
			
		end
		if (res == 5000001) then
			-- 宝箱已下架
			EventSystem:postEvent(EVENTTYPE_SHOP, EVENTID_SHOP_TIME_OUT);
		end
		DataMgr.ShowNoticeByID(res);
    end
end

-- 新版商城开礼包
function ShopSystem.on_shop_buy_item_notify_rep(res, itemList)
	if res == "ok" then
		sandbox.LogNormal("on_shop_buy_item_notify_rep success ");
		log_tree("itemList", itemList);
		local rewardList = {};
		for k,v in pairs(itemList) do
			table.insert(rewardList, {res_id = k, count = v});
		end
		log_tree("rewardList", rewardList);
		if #rewardList > 0 then
			CommonItemGetUI:ShowPanel(rewardList);
		end
	else
		DataMgr.ShowNoticeByID(res);
	end
end

-- 次数刷新
function ShopSystem.get_shop_limit_info_rsp(res, limit, id)
	log("ShopSystem.get_shop_limit_info_rsp");
	if (ShopSystem.GiftBoxList[id] ~= nil) then
		ShopSystem.GiftBoxList[id].got_num = limit;
	end

	EventSystem:postEvent(EVENTTYPE_SHOP, EVENTID_SHOP_GIFT_LIMIT_UPDATE, id);
end



--宝箱开启响应
--[[
decompose_list = {
   [<from_item_id>] = {
   tid = <item_id>,
         cnt = <cnt>,
   }
}
--]]
function ShopSystem.on_open_chest_rsp(res, chestid, itemlist, reason, lowest_rounds, max_config_rounds ,decompose_list)
	-- decompose_list = {};
	-- for k,v in pairs(itemlist) do
	-- 	decompose_list[v.resid] = {tid = 2601001, cnt = 10};
	-- end
	log("on_open_chest_rsp: " .. res);
	log("on_open_chest_rsp: reason"..reason);
	log_tree("on_open_chest_rsp decompose_list", decompose_list);
	log_tree("on_open_chest_rsp itemlist", itemlist);

    --刷新列表信息
    if res == "ok" then
		sandbox.LogNormal("on_open_chest_rsp success ");
		
		--如果有自动分解物品，赋值给BP变量
		BP_Open_Box_DecomposeItemId = 0;
		for k,v in pairs(decompose_list)do
			for tid,cnt in pairs(v) do
				log("on_open_chest_rsp decompose item id :".. tostring(tid))
				BP_Open_Box_DecomposeItemId = tid;
				break
			end
			break
		end
		
		local arrayItemData = {};
		--log_tree("itemlist",itemlist);
		local count = 0;
		for k,v in pairs(itemlist) do
			local h = v.valid_hours or 0;
			local decomposeInfo = decompose_list[k];
			if decomposeInfo == nil then-- 没有触发自动分解
				table.insert(arrayItemData, {res_id = v.resid, count = v.count, valid_hours = h});
			else-- 触发了自动分解
				for tid, cnt in pairs(decomposeInfo) do
					table.insert(arrayItemData, {res_id = v.resid, count = v.count, valid_hours = h, to_res_id = tid, to_res_cnt = cnt});
					break;
			    end
			end
			count = count + v.count;
		end
		
		
		if reason ~= 1 then
			if BP_UnknowPass_Treasure_Box_Is_Open_Box then
				--打开通信证宝箱展示
				BP_UnknowPass_Treasure_Box_Is_Open_Box = false

				local reward_list = {};
				for k,v in pairs(itemlist) do
					local show_type = 0
					local cfg = Client.GetTableData("Item", v.resid);
					if cfg and cfg.NeedShare ~= 0 then
						show_type = cfg.NeedShare
					end
					table.insert(reward_list, {resId = v.resid, number = v.count, showType = show_type});
				end				
				UnknowPassShowAward.ShowUI(reward_list)
			else
				CommonItemGetUI:ShowPanel(arrayItemData);
			end
		else
			local boxID = SupplyMainUI.GetCurBuyShopID();
			if StoreSystem.IsUseNewStore() == false then
				boxID = BP_Store_Box_Buy_Item_ID;
			end
			if MallRecommendUI.isShowing then
				boxID = BP_MallRecommendUI_Store_Box_Buy_Item_ID;
			end
			if ShopSystem.ItemPlayModleList[chestid]~= nil then
				OpenBoxtUI:ShowPanel(arrayItemData,false,ShopSystem.ItemPlayModleList[chestid], boxID);
			else
				OpenBoxtUI:ShowPanel(arrayItemData,false,0, boxID);
			end
		end

		log("lowest_rounds:" .. lowest_rounds);

		if BP_Open_Box_DecomposeItemId > 0 then
			Timer.InsertTimer(3.0,
					function()
						CorpsWelfareRedEnvelopesUI.ShowPanel();
					end, false, false);
		end
		
    else
		sandbox.LogNormal("on_open_chest_rsp failed ");
		DataMgr.ShowNoticeByID(res);
    end
end
--10连抽宝箱开启响应
function ShopSystem.on_open_10chest_rsp(res, itemlist, decompose_list)
	-- decompose_list = {};
	-- for k,v in pairs(itemlist) do
	-- 	decompose_list[v.itemid] = {tid = 2601001, cnt = 10};
	-- end
	log("on_open_10chest_rsp: " .. res);
	log_tree("ShopSystem.on_open_10chest_rsp itemlist", itemlist);
	log_tree("ShopSystem.on_open_10chest_rsp decompose_list", decompose_list);
    --刷新列表信息
    if res == "ok" then
		sandbox.LogNormal("on_open_10chest_rsp success ");	
	
		
		local arrayItemData = {};
		log_tree("itemlist 10 ",itemlist);
		local count = 0;
		for k,v in pairs(itemlist) do
			local h = v.valid_hours or 0;
			local decomposeInfo = decompose_list[k];
			if decomposeInfo ~= nil then
				for tid, cnt in pairs(decomposeInfo) do
					table.insert(arrayItemData, {res_id = v.itemid, count = v.num, valid_hours = h, to_res_id = tid, to_res_cnt = cnt});
					break;
				end
			else
				table.insert(arrayItemData, {res_id = v.itemid, count = v.num, valid_hours = h});
			end
			count = count + v.num;
		end
		local boxID = SupplyMainUI.GetCurBuyShopID();
		if StoreSystem.IsUseNewStore() == false then
			boxID = BP_Store_Box_Buy_Item_ID;
		end
		if MallRecommendUI.isShowing then
			boxID = BP_MallRecommendUI_Store_Box_Buy_Item_ID;
		end
		OpenBoxtUI:ShowPanel(arrayItemData,true, nil, boxID);

    else
		sandbox.LogNormal("on_open_10chest_rsp failed ");
		DataMgr.ShowNoticeByID(res);
    end
end
-- 宝箱保底次数更新
function ShopSystem.on_shop_round_update_rsp(shopid, lowest_rounds, max_config_rounds)
	if (ShopSystem.ItemInfoList[shopid] ~= nil) then
		ShopSystem.ItemInfoList[shopid].lowest_rounds = lowest_rounds;
		ShopSystem.ItemInfoList[shopid].max_config_rounds = max_config_rounds;
	end

	StoreBox_UI.UpdateLowestRounds(shopid, lowest_rounds, max_config_rounds);
end

-- 收到物品掉落列表
function ShopSystem.on_shop_item_content_rsp(res, item_list, id)
	log("on_shop_item_content_rsp");
	EventSystem:postEvent(EVENTTYPE_SHOP, EVENTID_SHOP_ITEM_CONTENT, {id, item_list});
end

--[[网络回调]]--
s2c["shop_itemlist_rsp"] = ShopSystem.on_itemlist_rsp;
s2c["get_single_shopitem_rsp"] = ShopSystem.get_single_shopitem_rsp;
s2c["shop_buy_rsp"] = ShopSystem.on_buy_rsp;
s2c["open_chest_rsp"] = ShopSystem.on_open_chest_rsp;
s2c["open_chest_ten_times_nofity"] = ShopSystem.on_open_10chest_rsp;
s2c["shop_item_content_rsp"] = ShopSystem.on_shop_item_content_rsp;
s2c["shop_rounds_update_rsp"] = ShopSystem.on_shop_round_update_rsp;
s2c["shop_buy_item_notify"] = ShopSystem.on_shop_buy_item_notify_rep;
s2c["get_shop_limit_info_rsp"] = ShopSystem.get_shop_limit_info_rsp;

