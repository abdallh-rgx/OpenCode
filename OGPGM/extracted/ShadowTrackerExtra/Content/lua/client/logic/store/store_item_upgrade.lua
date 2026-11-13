--商城外显升级system


store_item_upgrade_system = 
{
	module = 
	{
		none = 0,
		weapon = 1,
		normal_supply = 2,
		activity_supply = 3,
		valuable_supply = 4,
		weapon_preview = 5,
		notpreview = 6,		--从预览退出专用
	},

	tag = 
	{
		lowest = 1,
		max    = 2,
	}
}
store_item_upgrade_system.CachedItemUpgradeConfig = {}	--缓存升级表
store_item_upgrade_system.CurrentItemID = 0				--当前选择ID
store_item_upgrade_system.MaxLevel = 0
store_item_upgrade_system.CurrentModele = store_item_upgrade_system.module.none				--当前模块枚举

store_item_upgrade_system.SavedLastModelItemID = 0		--进preview之前 先存一下当前正在展示的模型ID
store_item_upgrade_system.curTag = 0					--当前的列表

--功能开关
function store_item_upgrade_system.IsOpen()
	-- body
	return LobbyUI:CheckLobbyMenuOpen(BP_ENUM_STORE_LEVEL_UP,false)
end

--初始化数据
function store_item_upgrade_system.Init()
	-- body
	store_item_upgrade_system.CacheItemUpgradeConfig()
end

--做清理逻辑时候调用
function store_item_upgrade_system.Clear()
	-- body
end

--Set CurrentModele
function store_item_upgrade_system.SetCurrentModele(module)
	-- body
	log("SetCurrentModele. " .. tostring(module))
	store_item_upgrade_system.CurrentModele = module
	store_item_upgrade_system.curTag = 0	--初始化TAG
end

--Get CurrentModele
function store_item_upgrade_system.GetCurrentModele()
	-- body
	log("GetCurrentModele. " .. tostring(store_item_upgrade_system.CurrentModele))
	return store_item_upgrade_system.CurrentModele
end

--登录之后cached 1次所有 特性控制表数据
function store_item_upgrade_system.CacheItemUpgradeConfig()
	-- body
	local itemUpgradeCfgs = Client.GetTable("ItemUpgradeConfig")
	for id, cfg in pairs(itemUpgradeCfgs) do
		store_item_upgrade_system.CachedItemUpgradeConfig[cfg.ItemID] = cfg
	end
	log_tree("store_item_upgrade_system.CachedItemUpgradeConfig",store_item_upgrade_system.CachedItemUpgradeConfig)
end


--Set 当前需要展示的物品ID
--从模块当中分别获取对应的点击ID
--MaxorLowest : true 为max false 为Lowest
--是高级别显示的时候 要展示最高级别物品ID
function store_item_upgrade_system.SetCurrentItemID(moduleID,itemid,MaxorLowest)
	-- body
	log("zino itemid : "..tostring(itemid))
	log("zino moduleID : "..tostring(moduleID))
	if moduleID == store_item_upgrade_system.module.weapon then	--商城武器页签的
		if itemid > 0 then
			if MaxorLowest then
				store_item_upgrade_system.CurrentItemID = ItemUpgradeSystem.GetMaxLevelItem(itemid)
				log("store_item_upgrade_system.CurrentItemID: "..tostring(store_item_upgrade_system.CurrentItemID))
			else
				store_item_upgrade_system.CurrentItemID = itemid
			end
		else
			log("store_item_upgrade_system illegal condition")
		end

	elseif moduleID == store_item_upgrade_system.module.normal_supply then	--礼包页签的
		if itemid > 0 then
			if MaxorLowest then
				store_item_upgrade_system.CurrentItemID = ItemUpgradeSystem.GetMaxLevelItem(itemid)
				log("store_item_upgrade_system.CurrentItemID: "..tostring(store_item_upgrade_system.CurrentItemID))
			else
				store_item_upgrade_system.CurrentItemID = itemid
			end
		else
			log("store_item_upgrade_system illegal condition")
		end
	elseif moduleID == store_item_upgrade_system.module.activity_supply then	--礼包页签的
		if itemid > 0 then
			if MaxorLowest then
				store_item_upgrade_system.CurrentItemID = ItemUpgradeSystem.GetMaxLevelItem(itemid)
				log("store_item_upgrade_system.CurrentItemID: "..tostring(store_item_upgrade_system.CurrentItemID))
			else
				store_item_upgrade_system.CurrentItemID = itemid
			end
		else
			log("store_item_upgrade_system illegal condition")
		end
	elseif moduleID == store_item_upgrade_system.module.valuable_supply then	--礼包页签的
		-- body
		if itemid > 0 then
			if MaxorLowest then
				store_item_upgrade_system.CurrentItemID = ItemUpgradeSystem.GetMaxLevelItem(itemid)
				log("store_item_upgrade_system.CurrentItemID: "..tostring(store_item_upgrade_system.CurrentItemID))
			else
				store_item_upgrade_system.CurrentItemID = itemid
			end
		else
			log("store_item_upgrade_system illegal condition")
		end
	elseif moduleID == store_item_upgrade_system.module.weapon_preview then
		if itemid > 0 then
			if MaxorLowest then
				store_item_upgrade_system.CurrentItemID = ItemUpgradeSystem.GetMaxLevelItem(itemid)
				log("store_item_upgrade_system.CurrentItemID: "..tostring(store_item_upgrade_system.CurrentItemID))
			else
				store_item_upgrade_system.CurrentItemID = itemid
			end
		else
			log("store_item_upgrade_system illegal condition")
		end

	end
end


--得到当前需要展示的物品ID
function store_item_upgrade_system.GetCurrentItemID()
	-- body
	log("store_item_upgrade_system.GetCurrentItemID : " .. tostring(store_item_upgrade_system.CurrentItemID))
	return store_item_upgrade_system.CurrentItemID
end

--蓝图里调用的方法
--点击低等级武器
function store_item_upgrade_system.OnClickedLowLevel(ModuleID,itemid)
	-- body
	if store_item_upgrade_system.curTag == store_item_upgrade_system.tag.lowest then
		return 
	end
	store_item_upgrade_system.curTag = store_item_upgrade_system.tag.lowest
	store_item_upgrade_system.SetCurrentItemID(ModuleID,itemid)	
	StoreMainUI.OnSelectedItem(store_item_upgrade_system.GetCurrentItemID(), 0, 0, true);
	store_item_upgrade_system.HideAnimation()
	if ModuleID == store_item_upgrade_system.module.weapon then		--武器地方特写

		BP_Current_StoreLevelUp_ItemID = store_item_upgrade_system.GetCurrentItemID()
		LuaClassObj.HandleUIMessageNoFetch(bp_store_weapon, "ShowFeatures");		--特性展示需要
	end

	if ModuleID == store_item_upgrade_system.module.valuable_supply then		--BOX地方特写

		BP_STORE_VALUABLE_SUPPLY_LEVELUP_ITEMID = store_item_upgrade_system.GetCurrentItemID()
		LuaClassObj.HandleUIMessageNoFetch(bp_store_valuable_supply, "ShowFeaturesByLevelUp");		--特性展示需要
	end

	if ModuleID == store_item_upgrade_system.module.activity_supply then		--BOX地方特写

		BP_STORE_ACTIVITY_SUPPLY_LEVELUP_ITEMID = store_item_upgrade_system.GetCurrentItemID()
		LuaClassObj.HandleUIMessageNoFetch(bp_store_activity_supply, "ShowFeaturesByLevelUp");		--特性展示需要
	end

	if ModuleID == store_item_upgrade_system.module.normal_supply then		--BOX地方特写

		BP_STORE_NORMAL_SUPPLY_LEVELUP_ITEMID = store_item_upgrade_system.GetCurrentItemID()
		LuaClassObj.HandleUIMessageNoFetch(bp_store_normal_supply, "ShowFeaturesByLevelUp");		--特性展示需要
	end

end

--蓝图里调用的方法
--点击最高等级武器
function store_item_upgrade_system.OnClickedMaxLevel(ModuleID,itemid)
	-- body
	log("ModuleID : " .. ModuleID)
	log("itemid " ..tostring(itemid))
	if store_item_upgrade_system.curTag == store_item_upgrade_system.tag.max then
		return 
	end
	store_item_upgrade_system.curTag = store_item_upgrade_system.tag.max
	store_item_upgrade_system.SetCurrentItemID(ModuleID,itemid,true)
	StoreMainUI.OnSelectedItem(store_item_upgrade_system.GetCurrentItemID(), 0, 0, true)

	if ModuleID == store_item_upgrade_system.module.weapon then		--武器地方特写

		BP_Current_StoreLevelUp_ItemID = store_item_upgrade_system.GetCurrentItemID()	
		LuaClassObj.HandleUIMessageNoFetch(bp_store_weapon, "ShowFeatures");	--特性展示需要
	end

	if ModuleID == store_item_upgrade_system.module.valuable_supply then		--BOX地方特写

		BP_STORE_VALUABLE_SUPPLY_LEVELUP_ITEMID = store_item_upgrade_system.GetCurrentItemID()
		LuaClassObj.HandleUIMessageNoFetch(bp_store_valuable_supply, "ShowFeaturesByLevelUp");		--特性展示需要
	end

	if ModuleID == store_item_upgrade_system.module.activity_supply then		--BOX地方特写

		BP_STORE_ACTIVITY_SUPPLY_LEVELUP_ITEMID = store_item_upgrade_system.GetCurrentItemID()
		LuaClassObj.HandleUIMessageNoFetch(bp_store_activity_supply, "ShowFeaturesByLevelUp")		--特性展示需要
	end

	if ModuleID == store_item_upgrade_system.module.normal_supply then		--BOX地方特写

		BP_STORE_NORMAL_SUPPLY_LEVELUP_ITEMID = store_item_upgrade_system.GetCurrentItemID()
		LuaClassObj.HandleUIMessageNoFetch(bp_store_normal_supply, "ShowFeaturesByLevelUp");		--特性展示需要
	end


end

--是否显示切换的BUTTON
--特性表有这个ID 和外观升级表有这个ID true
--顺便设置下Maxlevel 给蓝图读
function store_item_upgrade_system.isShowButton(itemid)
	-- body
	if not store_item_upgrade_system.IsOpen() then	--面板开关没有打开 不显示按钮
		log("store_item_upgrade_system.isShowButton false")
		return false
	end
	if store_item_upgrade_system.module.weapon_preview == store_item_upgrade_system.GetCurrentModele() then
		log("store_item_upgrade_system.isShowButton false")
		return false
	end

	if not (store_item_upgrade_system.module.weapon == store_item_upgrade_system.GetCurrentModele()) and
	not MultipleAvatar.HasEquiped(itemid, 0, 0) then
		log("store_item_upgrade_system.HasEquiped false")
		return false
	end

	if StoreCollectionWrappedUI == StoreMainUI.curShowUI then
		log("[HHF]store_item_upgrade_system.isShowButton, CollectionUI hide levelup btn");
		return false;
	end

	local maxitemid = ItemUpgradeSystem.GetMaxLevelItem(itemid)
	if store_item_upgrade_system.CachedItemUpgradeConfig[maxitemid] then
		store_item_upgrade_system.SetMaxLevel(store_item_upgrade_system.CachedItemUpgradeConfig[maxitemid].Level)
			log("store_item_upgrade_system.isShowButton true")
			store_item_upgrade_system.curTag = store_item_upgrade_system.tag.lowest --页签状态默认为lowest
		return true
	end
	log("store_item_upgrade_system.isShowButton false")
	return false
end

--最大等级
function store_item_upgrade_system.SetMaxLevel(level)
	-- body
	log("zino level "..tostring(level))
	store_item_upgrade_system.MaxLevel = level
end

--最大等级
function store_item_upgrade_system.GetMaxLevel()
	-- body
	return store_item_upgrade_system.MaxLevel
end


--隐藏播报动画
function store_item_upgrade_system.HideAnimation()
	-- body
	if store_item_upgrade_system.GetCurrentModele() == store_item_upgrade_system.module.weapon then
		StoreWeaponUI.OnDeadBoxRestore()
	elseif store_item_upgrade_system.GetCurrentModele() == store_item_upgrade_system.module.activity_supply then
		StoreActivitySupply_UI.OnDeadBoxRestore()
	elseif store_item_upgrade_system.GetCurrentModele() == store_item_upgrade_system.module.valuable_supply then
		StoreValuableSupply_UI.OnDeadBoxRestore()
	elseif store_item_upgrade_system.GetCurrentModele() == store_item_upgrade_system.module.normal_supply then
		StoreNormalSupply_UI.OnDeadBoxRestore()
	end
end


--给预览用
function store_item_upgrade_system.GetPreviewID(curitemid)
	-- bodyItemUpgradeSystem.GetMaxLevelItem(itemid)
	local maxid = ItemUpgradeSystem.GetMaxLevelItem(curitemid)
	if maxid then
		if maxid == store_item_upgrade_system.GetCurrentItemID() then	--说明要返回最大的ID
			return maxid
		end
	else
		return curitemid
	end
	return curitemid
end

--Set priview 用的 进全屏之前的ID
function store_item_upgrade_system.SetSavedLastModelItemID(itemid)
	-- body
	store_item_upgrade_system.SavedLastModelItemID = itemid
end

--Get priview 用的 进全屏之前的ID
function store_item_upgrade_system.GetSavedLastModelItemID()
	-- body
	return store_item_upgrade_system.SavedLastModelItemID
end