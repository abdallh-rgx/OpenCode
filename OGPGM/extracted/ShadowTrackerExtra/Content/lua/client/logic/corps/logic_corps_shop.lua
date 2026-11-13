--[[
	军团商城系统
--]]

CorpsShopSystem = CorpsShopSystem or 
{
	corps_shop_item_class_clothing        =   1; --服装
	corps_shop_item_class_headportrait    =   2; --头像框
	corps_shop_item_class_alias           =   3; --军团称号
};

CorpsShopSystem.CurrentShopHasStr = "";
--[[
	商品类型
	1-衣服
	2-头像
--]]
CorpsShopSystem.ShopItemType = 
{
	Clothing = 1,
	Headpotrait = 2,
};

CorpsShopSystem.icon_change_time = 0;

function CorpsShopSystem.Init()
	log("CorpsShopSystem.Init");
end

function CorpsShopSystem.Release()
	log("CorpsShopSystem.Release");
end

function CorpsShopSystem.ClearData()
	--清理限购数据!
	-- if BP_ARRAY_CorpsShopClothingInfoList then
	-- 	for k,v in pairs(BP_ARRAY_CorpsShopClothingInfoList) do
	-- 		v.has_buy_num = 0;
	-- 	end
	-- end
	-- if BP_ARRAY_CorpsShopHeadpotraitInfoList then
	-- 	for k,v in pairs(BP_ARRAY_CorpsShopHeadpotraitInfoList) do
	-- 		v.has_buy_num = 0;
	-- 	end
	-- end
	log("CorpsShopSystem.ClearData");
	CorpsShopSystem.CurrentShopHasStr = "";
	CorpsShopSystem.icon_change_time = 0;
	BP_ARRAY_CorpsShopClothingInfoList = {};
	BP_ARRAY_CorpsShopHeadpotraitInfoList = {};
end

--是否有新解锁的商品
function CorpsShopSystem.HasNewOpenShopItem()
	--取消商城小红点提示
	--[[
	log("CorpsShopSystem.HasNewOpenShopItem .. ".. BP_Global_CorpsShopLevelForRedPiont)
	if BP_ARRAY_CorpsShopClothingInfoList then
		for k,v in pairs(BP_ARRAY_CorpsShopClothingInfoList) do
			if v.unlock_corps_level <= DataMgr.corpsInfo.level and v.unlock_corps_level > BP_Global_CorpsShopLevelForRedPiont then
				return true;
			end
		end
	end
	]]
	--[[
	if BP_ARRAY_CorpsShopHeadpotraitInfoList then
		for k,v in pairs(BP_ARRAY_CorpsShopHeadpotraitInfoList) do
			if v.unlock_corps_level <= DataMgr.corpsInfo.level and v.unlock_corps_level > BP_Global_CorpsShopLevelForRedPiont then
				return true;
			end
		end
	end
	]]
	return false;
end

function CorpsShopSystem.GetItemInfoById(itemId)
	if (BP_CorpsShopCurrentSelectPageIdx == CorpsShopSystem.ShopItemType.Clothing) then
		for k,v in pairs(BP_ARRAY_CorpsShopClothingInfoList) do
			if (v.item_id == itemId) then
				return v;
			end
		end
	elseif (BP_CorpsShopCurrentSelectPageIdx == CorpsShopSystem.ShopItemType.Headpotrait) then
		for k,v in pairs(BP_ARRAY_CorpsShopHeadpotraitInfoList) do
			if (v.item_id == itemId) then
				return v;
			end
		end
	end
end

--[[
	更新限购数据
	@itemId:物品ID
	@currentHasBuyNum:当前已购数量
--]]
function CorpsShopSystem.UpdateItemLimitNum(itemId, currentHasBuyNum)
	log("CorpsShopSystem.UpdateItemLimitNum")
	currentHasBuyNum = currentHasBuyNum or 0;
	for k,v in pairs(BP_ARRAY_CorpsShopClothingInfoList) do
		if (v.item_id == itemId) then
			v.has_buy_num = currentHasBuyNum;
			return;
		end
	end
	--[[
	for k,v in pairs(BP_ARRAY_CorpsShopHeadpotraitInfoList) do
		if (v.item_id == itemId) then
			v.has_buy_num = currentHasBuyNum;
			return;
		end
	end
	]]
end

function CorpsShopSystem.ResetItemLimitNumAndCd()
	for k,v in pairs(BP_ARRAY_CorpsShopClothingInfoList) do
		v.has_buy_num = 0;
		v.time_cd = 0;
	end
	--log_tree("CorpsShopSystem.ResetItemLimitNumAndCd", BP_ARRAY_CorpsShopClothingInfoList);
end

function CorpsShopSystem.UpdateItemLimitNumAndCd(itemId, item_limit_buy_info_by_day)
	for k,v in pairs(BP_ARRAY_CorpsShopClothingInfoList) do
		if (v.item_id == itemId) then
			v.has_buy_num = item_limit_buy_info_by_day.item_num;
			v.time_cd = item_limit_buy_info_by_day.cd_time;
			return;
		end
	end
end

function CorpsShopSystem.ShowNotEnoughMoneyBox()
	local funcConfirm = function() 
		--CorpsBaseUI.JumpToPage(CorpsBaseUI.PageMission);
		CorpsTrainingSystem.OpenTrainingUI();
	end
	CommonMessageBoxUI:ShowPanel(2, FuncUtil.GetLocalizeResStr("101001"), FuncUtil.GetLocalizeResStr("410046"), funcConfirm);
end

--[[
	sort_id->item_id>unlock_corps_level
--]]
function CorpsShopSystem.ListSort(a, b)
	if (a.sort_id ~= b.sort_id) then
		return a.sort_id < b.sort_id;
	end
	if (a.item_id ~= b.item_id) then
		return a.item_id < b.item_id;
	end
	if (a.unlock_corps_level ~= b.unlock_corps_level) then
		return a.unlock_corps_level < b.unlock_corps_level;
	end
	return false;
end


--[[
	NET
	the request of Get Shop data from Server
	@shopHashStr:the hash value of the last data from server. to avoid repeating get the shop data
--]]
function CorpsShopSystem.GetShopDataReq(shopHashStr, icon_change_time)
	log("CorpsShopSystem.GetShopDataReq");
	log(shopHashStr)
	if CorpsMgr.IsInCorps() then
		NetUtil.SendPkg("get_corps_shoplist_req", shopHashStr, icon_change_time);
	end
end
--[[
	NET
	the response of Get Shop data from Server
	@retResult："ok"
	@shopHashStr：商店表的hash, 
	@corpsShopClothingTable：商店服装配置， 
	@corpsShopHeadportraitTable：商店头像框配置，
	后面3个参数预留
--]]
function CorpsShopSystem.GetShopDataRes(retResult, shopHashStr, corps_shop_item, corps_shop_item_no_icon, icon_change_time, param1, param2, param3)
	log("CorpsShopSystem.GetShopDataRes");
	if (retResult == "ok") then
		if (shopHashStr == nil or shopHashStr == "") then
			return;
		end

		log(shopHashStr);
		-- log_tree("corpsShopHeadportraitTable", corpsShopHeadportraitTable);
		-- log_tree("corps_shop_item", corps_shop_item);
		-- log_tree("corps_shop_item_no_icon", corps_shop_item_no_icon);


		CorpsShopSystem.CurrentShopHasStr = shopHashStr;
		CorpsShopSystem.icon_change_time = icon_change_time;

		BP_ARRAY_CorpsShopClothingInfoList = {};
		local corpsShopClothingTable = corps_shop_item[CorpsShopSystem.corps_shop_item_class_clothing];
		local tempTable = corps_shop_item_no_icon[CorpsShopSystem.corps_shop_item_class_clothing];
		if tempTable ~= nil then
			for k, v in pairs(tempTable) do
				corpsShopClothingTable[k] = v;
			end
		end
		if corpsShopClothingTable ~= nil then
			for k,v in pairs(corpsShopClothingTable) do
				local clothingInfo = {}
				clothingInfo.sort_id = v.sort_id;
				clothingInfo.item_id = v.item_id;
				clothingInfo.consume_corps_money = v.consume_corps_money;
				clothingInfo.unlock_corps_level = v.unlock_corps_level;
				clothingInfo.limit_buy_num = v.limitbuy_num;
				clothingInfo.has_buy_num = 0;
				clothingInfo.limit_buy_cd_num_by_day = v.limit_buy_cd_num_by_day;
				clothingInfo.limit_buy_item_num_by_day = v.limit_buy_item_num_by_day;
				clothingInfo.permanet_limit_buy_num = v.permanet_limit_buy_num;
				clothingInfo.position_limit = v.position_limit;
				table.insert(BP_ARRAY_CorpsShopClothingInfoList, clothingInfo);
			end
		end
		if (#BP_ARRAY_CorpsShopClothingInfoList > 0) then
			table.sort(BP_ARRAY_CorpsShopClothingInfoList, CorpsShopSystem.ListSort);
		end
		--log_tree("corpsShopClothingTable", corpsShopClothingTable);

		BP_ARRAY_CorpsShopHeadpotraitInfoList = {};
		local corpsShopHeadportraitTable = corps_shop_item[CorpsShopSystem.corps_shop_item_class_headportrait];
		local tempTable1 = corps_shop_item_no_icon[CorpsShopSystem.corps_shop_item_class_headportrait];
		if tempTable1 ~= nil then
			for k, v in pairs(tempTable1) do
				corpsShopHeadportraitTable[k] = v;
			end
		end
		if corpsShopHeadportraitTable ~= nil then
			for k,v in pairs(corpsShopHeadportraitTable) do
				local headpotraitInfo = {}
				headpotraitInfo.sort_id = v.sort_id;
				headpotraitInfo.item_id = v.item_id;
				headpotraitInfo.consume_corps_money = v.consume_corps_money;
				headpotraitInfo.unlock_corps_level = v.unlock_corps_level;
				headpotraitInfo.limit_buy_num = v.limitbuy_num;
				headpotraitInfo.has_buy_num = 0;
				headpotraitInfo.limit_buy_cd_num_by_day = v.limit_buy_cd_num_by_day;
				headpotraitInfo.limit_buy_item_num_by_day = v.limit_buy_item_num_by_day;
				headpotraitInfo.permanet_limit_buy_num = v.permanet_limit_buy_num;
				headpotraitInfo.position_limit = v.position_limit;
				table.insert(BP_ARRAY_CorpsShopHeadpotraitInfoList, headpotraitInfo);
			end
		end
		if (#BP_ARRAY_CorpsShopHeadpotraitInfoList > 0) then
			table.sort(BP_ARRAY_CorpsShopHeadpotraitInfoList, CorpsShopSystem.ListSort);
		end

		CorpsBaseUI.UpdateRedPoint();

	elseif (type(retResult) == "number") then
		ShowNotice(retResult)
	end
end
--[[
	NET
	the request of buy shop item
	@itemClass：道具类别：1; --服装 2; --头像框
	@itemId：配置表的序号
	@itemNum：购买数量
--]]
function CorpsShopSystem.BuyShopItemReq(itemNum)
	log("CorpsShopSystem.BuyShopItemReq itemNum: " .. itemNum or 0);
	local info = CorpsShopSystem.GetItemInfoById(BP_CorpsShopCurrentBuyShopItemId);
	if not info then
		return
	end
	if (info.consume_corps_money * itemNum > BP_CorpsShop_Money) then
		CorpsShopSystem.ShowNotEnoughMoneyBox();
	else
		NetUtil.SendPkg("buy_corps_shopitem_req", BP_CorpsShopCurrentSelectPageIdx, BP_CorpsShopCurrentBuyShopItemId, itemNum);
	end
end
--[[
	NET
	the response of buy shop item
	@retResult："ok"
	@itemClass：道具类别：1; --服装 2; --头像框
	@itemId：配置表的序号
	@itemNum：购买数量
	@buyitemlist：购买的物品列表
	@corps_money:军团币
	@cur_item_buy_num:已购买数量
--]]
function CorpsShopSystem.BuyShopItemRes(retResult, itemClass, itemId, itemNum, buyitemlist, corps_money, cur_item_buy_num, item_limit_buy_info_by_day, item_limit_buy_info_by_permanet)
	log("CorpsShopSystem.BuyShopItemRes retResult:" .. retResult);
	if itemNum then 
		log("CorpsShopSystem.BuyShopItemRes itemNum:" .. itemNum);
	end
	if (retResult == "ok") then
	    local itemData = { res_id = itemId, count = itemNum };
	    local itemList = {};
	    table.insert(itemList, itemData);
	    CommonItemGetUI:ShowPanel(itemList);

		DataMgr.corps_money = corps_money;
		if cur_item_buy_num ~= nil then
			CorpsShopSystem.UpdateItemLimitNum(itemId, cur_item_buy_num);
		end
		if item_limit_buy_info_by_day ~= nil then
			CorpsShopSystem.UpdateItemLimitNumAndCd(itemId, item_limit_buy_info_by_day);
		end
		if item_limit_buy_info_by_permanet ~= nil then
			CorpsShopSystem.UpdateItemLimitNum(itemId, item_limit_buy_info_by_permanet);
		end
		CorpsShopUI.Refresh();
	elseif (type(retResult) == "number") then
		local noticeStr = FuncUtil.GetLocalizeResStr(retResult)
	    if noticeStr ~= "" then
	    	if itemClass then
	    		noticeStr = string.format(noticeStr, itemClass);
	    	end
	        PopUpNoticeUI.ShowNewNotice(noticeStr)
	    else
	        PopUpNoticeUI.ShowNewNotice(retResult)
	    end
	end
end

--[[
	获取商店限购数据
--]]
function CorpsShopSystem.GetShopLimitBuyReq()
	NetUtil.SendPkg("get_corps_shopitem_limitbuy_req");
end

--[[
	获取商店限购数据
	limitbuydata：
			--last_season_index 上次赛季索引
			--itemlist
				k:item_id
				v:buy_num
--]]
function CorpsShopSystem.GetShopLimitBuyRes(retResult, corps_shop_limit_but_by_season, corps_shop_limit_but_by_day, corps_shop_limit_but_by_permanet)
	log("CorpsShopSystem.GetShopLimitBuyRes retResult:" .. retResult);
	if (retResult == "ok") then
	    --log_tree("GetShopLimitBuyRes corps_shop_limit_but_by_season :", corps_shop_limit_but_by_season);
	    --log_tree("GetShopLimitBuyRes corps_shop_limit_but_by_day :", corps_shop_limit_but_by_day);
	    --log_tree("GetShopLimitBuyRes corps_shop_limit_but_by_permanet :", corps_shop_limit_but_by_permanet);

	    local lastSeasonIdx = corps_shop_limit_but_by_season.last_season_index;
	    local itemList = corps_shop_limit_but_by_season.itemlist;
		CorpsShopSystem.ResetItemLimitNumAndCd();
		if itemList and type(itemList) == "table" then
	    	for k,v in pairs(itemList) do
	    		CorpsShopSystem.UpdateItemLimitNum(k, v);
	    	end
	    end
	    if corps_shop_limit_but_by_day and type(corps_shop_limit_but_by_day) == "table" then
	    	for k,v in pairs(corps_shop_limit_but_by_day) do
	    		CorpsShopSystem.UpdateItemLimitNumAndCd(k, v);
	    	end
	    end
	    if corps_shop_limit_but_by_permanet and type(corps_shop_limit_but_by_permanet) == "table" then
	    	for k,v in pairs(corps_shop_limit_but_by_permanet) do
	    		CorpsShopSystem.UpdateItemLimitNum(k, v);
	    	end
	    end
	    CorpsShopUI.Refresh();
	elseif (type(retResult) == "number") then
		ShowNotice(retResult)
	end
end

s2c["get_corps_shoplist_res"] = CorpsShopSystem.GetShopDataRes;
s2c["buy_corps_shopitem_res"] = CorpsShopSystem.BuyShopItemRes;
s2c["get_corps_shopitem_limitbuy_res"] = CorpsShopSystem.GetShopLimitBuyRes;