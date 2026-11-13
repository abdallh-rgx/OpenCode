-- 外显升级模块
ItemUpgradeSystem = ItemUpgradeSystem or
{
	isInit = false;
	itemUpgradeConfigsKeyByGroupID = {};	-- 缓存ItemUpgradeConfig表数据，Key为GroupID
	itemUpgradeConfigsKeyByItemID = {};  -- 缓存ItemUpgradeConfig表数据，Key为ItemID
	itemUpgradeConfigsKeyByItemType = {};
	itemUpgradeMaterialList = {};		-- 缓存ItemUpgradeConfig中材料数据，Key为ItemID, Value为材料数据

	itemShowRedPointInfoMap = {};		-- 可升级界面中物品今天最后一次点击的时间，key：GroupID， value：{needShow, }
}

function ItemUpgradeSystem.Init()
	log("ItemUpgradeSystem.Init() start");
	if ItemUpgradeSystem.isInit == true then
		return;
	end
	ItemUpgradeSystem.isInit = true;

    -- 需要按等级降序排列
    local sortFunc = function(a,b)
    	return a.Level < b.Level;
	end

	ItemUpgradeSystem.itemUpgradeConfigsKeyByGroupID = {};
	ItemUpgradeSystem.itemUpgradeConfigsKeyByItemID = {};
	ItemUpgradeSystem.itemUpgradeConfigsKeyByItemType = {};

    local itemUpgradeCfgs = Client.GetTable("ItemUpgradeConfig");
    for id, cfg in pairs(itemUpgradeCfgs) do
    	if ItemUpgradeSystem.itemUpgradeConfigsKeyByGroupID[cfg.GroupID] == nil then
	    	ItemUpgradeSystem.itemUpgradeConfigsKeyByGroupID[cfg.GroupID] = {}
	    end
	    table.insert(ItemUpgradeSystem.itemUpgradeConfigsKeyByGroupID[cfg.GroupID], cfg);

	    ItemUpgradeSystem.itemUpgradeConfigsKeyByItemID[cfg.ItemID] = cfg;

		local itemCfg = Client.GetTableData("Item", cfg.ItemID);
		if itemCfg ~= nil then
			if ItemUpgradeSystem.itemUpgradeConfigsKeyByItemType[itemCfg.ItemType] == nil then
				ItemUpgradeSystem.itemUpgradeConfigsKeyByItemType[itemCfg.ItemType] = {};
			end
			if ItemUpgradeSystem.itemUpgradeConfigsKeyByItemType[itemCfg.ItemType][cfg.GroupID] == nil then
				ItemUpgradeSystem.itemUpgradeConfigsKeyByItemType[itemCfg.ItemType][cfg.GroupID] = {};
			end
			table.insert(ItemUpgradeSystem.itemUpgradeConfigsKeyByItemType[itemCfg.ItemType][cfg.GroupID], cfg);
		end
    end

    -- 需要按等级降序排列
    for groupId, list in pairs(ItemUpgradeSystem.itemUpgradeConfigsKeyByGroupID) do
    	table.sort(list, sortFunc);
    end
    for itemType, Groups in pairs(ItemUpgradeSystem.itemUpgradeConfigsKeyByItemType) do
    	for groupId, list in pairs(Groups) do
    		table.sort(list, sortFunc);
    	end
    end 

    ItemUpgradeSystem.InitUpgradeMaterialList();


	EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_DATA_INIT, ItemUpgradeSystem.OnDepotDataUpdate);
	EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_DATA_CHANGE, ItemUpgradeSystem.OnDepotDataUpdate);
	if DataMgrInit then
		ItemUpgradeSystem.OnDepotDataUpdate();
	end

	log("ItemUpgradeSystem.Init() finish");
end

-- 仓库数据更新
function ItemUpgradeSystem.OnDepotDataUpdate()
	local hasChange = false;
	for itemID, cfg in pairs(ItemUpgradeSystem.itemUpgradeConfigsKeyByItemID) do
		local itemInfo = DataMgr.GetHallDepotItemDataByResID(itemID);
		if itemInfo ~= nil then
			if ItemUpgradeSystem.itemShowRedPointInfoMap[itemID] == nil or ItemUpgradeSystem.itemShowRedPointInfoMap[itemID].needShow == true then
				local canUpgrade = ItemUpgradeSystem.CheckCanUpgradeToNextLevel(itemID);
				ItemUpgradeSystem.itemShowRedPointInfoMap[itemID] = {needShow = canUpgrade, enoughMat = canUpgrade};
				hasChange = true;
			else
				local info = ItemUpgradeSystem.itemShowRedPointInfoMap[itemID];
				if info.enoughMat == false and ItemUpgradeSystem.CheckCanUpgradeToNextLevel(itemID) == true then
					info.needShow = true;
					info.enoughMat = true;
					hasChange = true;
				end
			end
		else
			if ItemUpgradeSystem.itemShowRedPointInfoMap[itemID] ~= nil then
				ItemUpgradeSystem.itemShowRedPointInfoMap[itemID].needShow = false;
				hasChange = true;
			end
		end
	end
	if hasChange then
		EventSystem:postEvent(EVENTTYPE_ITEM_UPGRADE, EVENTID_ITEM_UPGRADE_RED_POINT_DATA_CHANGE);
	end
end

-- 记录红点信息
function ItemUpgradeSystem.RecordRedPointInfo(itemID)
	if ItemUpgradeSystem.itemShowRedPointInfoMap[itemID] ~= nil and ItemUpgradeSystem.itemShowRedPointInfoMap[itemID].needShow ~= false then
		ItemUpgradeSystem.itemShowRedPointInfoMap[itemID].needShow = false;
		EventSystem:postEvent(EVENTTYPE_ITEM_UPGRADE, EVENTID_ITEM_UPGRADE_RED_POINT_DATA_CHANGE);
	end
end

-- 物品是否有需要显示红点
function ItemUpgradeSystem.ItemNeedShowRedPoint(itemID)
	if ItemUpgradeSystem.itemShowRedPointInfoMap[itemID] ~= nil then
		return ItemUpgradeSystem.itemShowRedPointInfoMap[itemID].needShow;
	end
	return false;
end

-- 页签是否有需要显示红点
function ItemUpgradeSystem.PageNeedShowRedPoint(itemType)
	for itemID, info in pairs(ItemUpgradeSystem.itemShowRedPointInfoMap) do
		if info.needShow == true then
			local itemCfg = Client.GetTableData("Item", itemID);
			if itemCfg ~= nil and itemCfg.ItemType == itemType then
				return true;
			end
		end
	end
	return false;
end

-- 是否有需要显示红点
function ItemUpgradeSystem.NeedShowRedPoint()
	for itemID, info in pairs(ItemUpgradeSystem.itemShowRedPointInfoMap) do
		if info.needShow == true then
			return true;
		end
	end
	return false;
end

function ItemUpgradeSystem.Release()
	if ItemUpgradeSystem.isInit == false then
		return;
	end
	ItemUpgradeSystem.isInit = false;
	ItemUpgradeSystem.itemUpgradeConfigsKeyByGroupID = {};
	ItemUpgradeSystem.itemUpgradeConfigsKeyByItemID = {};
	ItemUpgradeSystem.itemUpgradeConfigsKeyByItemType = {};
	ItemUpgradeSystem.itemUpgradeMaterialList = {};
end

function ItemUpgradeSystem.CreateMaterialList(cfg)
	local index = 1;
	local keyItem = "CostItem"..index;
	local keyNum = "CostItemNum"..index;
	local list = {};
	while cfg[keyItem] ~= nil and cfg[keyItem] ~= 0 and cfg[keyNum] ~= nil and cfg[keyNum] ~= 0 do
		list[index] = {};

		list[index]["CostItem"] = cfg[keyItem];
		list[index]["CostItemNum"] = cfg[keyNum];

		index = index + 1;
		keyItem = "CostItem"..index;
		keyNum = "CostItemNum"..index;
	end
	return list
end

-- 构建升级材料数据
function ItemUpgradeSystem.InitUpgradeMaterialList()
	ItemUpgradeSystem.itemUpgradeMaterialList = {};
	for itemID, cfg in pairs(ItemUpgradeSystem.itemUpgradeConfigsKeyByItemID) do
		ItemUpgradeSystem.itemUpgradeMaterialList[itemID] = ItemUpgradeSystem.CreateMaterialList(cfg);
	end
end

-- 通过组ID返回组数据
function ItemUpgradeSystem.GetUpgradeGroupByID(groupID)
	return ItemUpgradeSystem.itemUpgradeConfigsKeyByGroupID[groupID];
end

-- 通过道具ID获取配置数据
function ItemUpgradeSystem.GetUpgradeCfg(itemID)
	return ItemUpgradeSystem.itemUpgradeConfigsKeyByItemID[itemID];
end

-- 通过道具ID返回对应组数据列表
function ItemUpgradeSystem.GetUpgradeGroupByItemID(itemID)
	local cfg = ItemUpgradeSystem.GetUpgradeCfg(itemID);
	if cfg then
		return ItemUpgradeSystem.GetUpgradeGroupByID(cfg.GroupID);
	end
	return {};
end

-- 根据物品ID获取对应下一级物品ID
function ItemUpgradeSystem.GetNextUpgradeItemID(resID)
	local groupList = ItemUpgradeSystem.GetUpgradeGroupByItemID(resID);
	local nextLevel = ItemUpgradeSystem.GetItemEffectLevel(resID) + 1;
	for _, cfg in ipairs(groupList) do
		if cfg.Level == nextLevel then
			return cfg.ItemID;
		end
	end
	return -1;
end

-- 判断道具是否可以升级
function ItemUpgradeSystem.CheckCanUpgrade(itemID)
	if StoreCollectionWrappedUI == StoreMainUI.curShowUI then
		log("[HHF]ItemUpgradeSystem.CheckCanUpgrade, CollectionUI hide upgrade btn");
		return false;
	else
		return LobbyUI:CheckLobbyMenuOpen(BP_ENUM_ITEM_UPGRADE, false) == true and ItemUpgradeSystem.GetUpgradeCfg(itemID) ~= nil;
	end
end

-- 获取物品的效果等级
function ItemUpgradeSystem.GetItemEffectLevel(itemID)
	local cfg = ItemUpgradeSystem.GetUpgradeCfg(itemID);
	if cfg then
		return cfg.Level;
	end
	return 0;
end

-- 判断是否最高等级效果物品
function ItemUpgradeSystem.IsItemEffectMaxLevel(ItemID)
	return ItemUpgradeSystem.GetNextUpgradeItemID(ItemID) == -1;
end

-- 获取可升级的物品
function ItemUpgradeSystem.GetUpgradeItemsByType(itemType)
	local itemList = {};
	if ItemUpgradeSystem.itemUpgradeConfigsKeyByItemType[itemType] ~= nil then
	    for groupID, cfgs in pairs(ItemUpgradeSystem.itemUpgradeConfigsKeyByItemType[itemType]) do
	    	itemList[#itemList + 1] = cfgs[1];
	    	for i = #cfgs, 1, -1 do
	    		if DataMgr.GetHallDepotItemDataByResID(cfgs[i].ItemID) ~= nil then
	    			itemList[#itemList] = cfgs[i];
	    			break;
	    		end
	    	end
	    end
	else
		log("ItemUpgradeSystem.itemUpgradeConfigsKeyByItemType[itemType] = nil, itemType = "..tostring(itemType));
	end
	if #itemList == 0 then
		log("ItemUpgradeSystem.GetUpgradeItemsByType #itemList = 0");
	end
    return itemList;
end

-- 获取各级特效列表
function ItemUpgradeSystem.GetItemUpgradeEffectList(resID)
	local list = {};
	local cfgs = ItemUpgradeSystem.GetUpgradeGroupByItemID(resID);
	if cfgs ~= nil then
		for _, cfg in ipairs(cfgs) do
			list[#list + 1] = 
			{
				resID = cfg.ItemID,
				effectID = cfg.EffectID,
				isUnlock = ItemUpgradeSystem.CheckHasSameGroupItem(cfg.ItemID) == true and cfg.Level <= BP_Current_Item_Effect_Level,
			};
		end
	end
	return list;
end

-- 获取升级材料列表
function ItemUpgradeSystem.GetItemUpgradeMaterialList(resID)
	return ItemUpgradeSystem.itemUpgradeMaterialList[resID] or {};
end

-- 获取升下一级的材料花费
function ItemUpgradeSystem.GetUpgradeNextLevelCostList(resID)
	local nextItemID = ItemUpgradeSystem.GetNextUpgradeItemID(resID);
	local list = ItemUpgradeSystem.GetItemUpgradeMaterialList(nextItemID);
	if list ~= nil then
		local costList = {};
		for _, costCfg in ipairs(list) do
			local needNum = costCfg.CostItemNum;
			local itemList = DataMgr.GetHallDepotItemListByResID(costCfg.CostItem)
			for _, item in ipairs(itemList) do
				if item.count >= needNum then
					costList[item.insID] = needNum;
					needNum = 0;
				else
					costList[item.insID] = item.count;
					needNum = needNum - item.count;
				end
				if needNum == 0 then
					break;
				end
			end
		end
		return costList;
	end
	return nil;
end

-- 判断是否满足升下一级材料花费
function ItemUpgradeSystem.CheckCanUpgradeToNextLevel(resID)
	local nextItemID = ItemUpgradeSystem.GetNextUpgradeItemID(resID);
	local list = ItemUpgradeSystem.GetItemUpgradeMaterialList(nextItemID);
	if next(list) ~= nil then
		local costList = {};
		for _, costCfg in ipairs(list) do
			local needNum = costCfg.CostItemNum;
			local itemList = DataMgr.GetHallDepotItemListByResID(costCfg.CostItem)
			for _, item in ipairs(itemList) do
				if item.count >= needNum then
					needNum = 0;
				else
					needNum = needNum - item.count;
				end
			end
			if needNum > 0 then
				return false;
			end
		end
	else
		return false;
	end
	return true;
end

-- 获取物品来源跳转配置
function ItemUpgradeSystem.GetItemSourceJumpConfig(itemID)
	local strRegion = Client.GetPublishRegion()
    if strRegion == "KOREA" or strRegion == "JAPAN" then
        return Client.GetTableData("ItemSourceJumpJKConfig", itemID);
    else
    	return Client.GetTableData("ItemSourceJumpConfig", itemID);
    end
end

-- 获取物品来源的跳转ID
function ItemUpgradeSystem.GetItemJumpTypeIDList(itemID)
	local list = {};
	local itemJumpCfg = ItemUpgradeSystem.GetItemSourceJumpConfig(itemID);
	if itemJumpCfg ~= nil then
		local index = 1;
		local key = "JumpType"..tostring(index);
		while itemJumpCfg[key] ~= nil and itemJumpCfg[key] ~= 0 do
			if GlobalData:CheckCanJumpByTypeID(itemID, itemJumpCfg[key]) then
				list[#list + 1] = itemJumpCfg[key];
			end
			index = index + 1;
			key = "JumpType"..tostring(index);
		end
	end
	return list;
end

-- 判断是否拥有同一组ID的物品
function ItemUpgradeSystem.CheckHasSameGroupItem(resID)
	local groupList = ItemUpgradeSystem.GetUpgradeGroupByItemID(resID);
	for _, cfg in ipairs(groupList) do
		if DataMgr.GetHallDepotItemDataByResID(cfg.ItemID) ~= nil then
			return true;
		end
	end
	return false;
end

-- 根据ID获取当前拥有同组的物品ID
function ItemUpgradeSystem.GetSameGroupItem(resID)
	local groupList = ItemUpgradeSystem.GetUpgradeGroupByItemID(resID);
	for _, cfg in ipairs(groupList) do
		if DataMgr.GetHallDepotItemDataByResID(cfg.ItemID) ~= nil then
			return cfg.ItemID;
		end
	end
	if #groupList > 0 then
		return groupList[1].ItemID
	end
	return -1;
end

-- 根据道具ID获取可升级的最高级别道具ID
function ItemUpgradeSystem.GetMaxLevelItem(itemID)
	if ItemUpgradeSystem.GetUpgradeCfg(itemID) ~= nil then
		local list = ItemUpgradeSystem.GetUpgradeGroupByItemID(itemID);
		if list ~= nil then
			return list[#list].ItemID;
		end
	end
	return -1;
end

-------------------------协议部分-------------------------------------
-- 请求升级道具（由前台决定用哪些消耗道具，后台只做校验）
function ItemUpgradeSystem.upgrade_item_req(instid, group_id, item_level, item_cost)
	log("ItemUpgradeSystem.upgrade_item_req");
	log_tree("ItemUpgradeSystem.upgrade_item_req item_cost = ", item_cost);
	log("ItemUpgradeSystem.upgrade_item_req item_level = "..tostring(item_level));
	NetUtil.SendPriorityPkg(true, "upgrade_item_rsp", "upgrade_item_req", instid, group_id, item_level, item_cost);
end

-- 升级道具回包
-- ret =
-- {
-- 	[1]=new_instid, #新的物品id
-- 	[2]=instid, 	#原来的物品id
-- 	[3]=group_id,   #升级物品所在的组
-- 	[4]=item_level, #升到的等级
-- 	[5]=item_cost   #消耗
-- }
function ItemUpgradeSystem.upgrade_item_rsp(error_code, ret)
	log("ItemUpgradeSystem.upgrade_item_rsp error_code = "..tostring(error_code));
	log_tree("ItemUpgradeSystem.upgrade_item_rsp ret = ", ret);
	if error_code ~= 0 then
		DataMgr.ShowNoticeByID(error_code);
		return;
	end
	EventSystem:postEvent(EVENTTYPE_ITEM_UPGRADE, EVENTID_ITEM_UPGRADE_UPGRADE_RSP, ret);
end

--[[网络回调]]--
s2c["upgrade_item_rsp"] = ItemUpgradeSystem.upgrade_item_rsp;