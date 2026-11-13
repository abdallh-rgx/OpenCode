ItemUpgradeUI = ItemUpgradeUI or 
{
	isInited = false,
	isShow = false,
	maxGuideStepCount = 4,
	hasUpgraded = false,
	jumpViewCloseCallBack = nil,
	lastClickTime = 0;
	closeCallBack = nil,
	isShowUpgradeEffect = false,
}

ENUM_Item_Upgrade_Show_Model_Type =
{
	Pawn = 0,
	Weapon = 1,
}

ENUM_Item_Upgrade_Button_State =
{
	Gray = 0,
	Normal = 1,
	Go = 2,
	Hide = 3,
}

BP_STRUCT_AvatarInfo = 
{
    resID = 401999,
    colorID = 0,
    patternID = 0,
}

-- avartar当前穿着数据
BP_ARRAY_AvatarInfoList = 
{
	BP_STRUCT_AvatarInfo = _G.BP_STRUCT_AvatarInfo;
}

--角色数据
BP_STRUCT_ItemUpgradeSpawnPlayerData =
{
	gid = "",
	sex = 1,
	headId = 401999,
	index = 1,
	BP_ARRAY_AvatarInfoList = _G.BP_ARRAY_AvatarInfoList,
}

-- 效果结构
BP_STRUCT_ItemUpgrade_Effect_Item =
{
	effectID = 0,
	isUnlock = false,
}

-- 效果列表
BP_ARRAY_ItemUpgrade_Effect_List = 
{
	BP_STRUCT_ItemUpgrade_Effect_Item = _G.BP_STRUCT_ItemUpgrade_Effect_Item,
}

-- 道具结构
BP_STRUCT_ItemUpgrade_Item = 
{
	instID = "",
	resID = 0,
	itemName = "",
    quality = 0,
    count = 0,
	colorID = 0,
	patternID = 0,
	showRedPoint = false,
}

-- 道具列表
BP_ARRAY_ItemUpgrade_Item_List = 
{
	BP_STRUCT_ItemUpgrade_Item = _G.BP_STRUCT_ItemUpgrade_Item,
}

-- 页签结构
BP_STRUCT_ItemUpgrade_Page_Item = 
{
	itemType = 0,	-- 道具类型
	isRed = 0,		-- 是否显示小红点
}

-- 页签数据列表
BP_ARRAY_ItemUpgrade_Page_List = 
{
	BP_STRUCT_ItemUpgrade_Page_Item = _G.BP_STRUCT_ItemUpgrade_Page_Item,
}

-- 材料结构
BP_STRUCT_ItemUpgrade_Material_Item = 
{
	resID = 0,
    count = 0,
	needCount = 0,
	BP_ARRAY_SourceJump_List = {0}, -- 材料道具来源跳转ID
}

-- 材料数据列表item
BP_ARRAY_ItemUpgrade_Material_List = 
{
	BP_STRUCT_ItemUpgrade_Material_Item = _G.BP_STRUCT_ItemUpgrade_Material_Item,
}

-- 材料道具来源跳转ID
BP_ARRAY_ItemUpgrade_Material_Source_Jump_List = 
{
	0,
}

BP_Current_Item_Effect_Level = 1; 	-- 当前选中道具的效果等级
BP_Cur_Item_Effect_Max_Level = 1;		-- 当前选中物品最高等级
BP_Item_Res_ID = 0;		-- 选中道具ID
BP_Select_Effect_Index = -1; -- 选中效果索引
BP_Weapon_ResID = 0;		-- 选中武器ResID
BP_Cur_Show_Model_Type = 0;  -- 当前显示模型类型页签（人物/枪械）
BP_Cur_Select_Page_Index = -1;	-- 当前选中页签
BP_Show_Change_Mode_Button = true;		--是否显示切换模型按钮
BP_Button_State = 0;				-- 当前按钮状态（升级按钮）
BP_Select_Material_Index = -1;		-- 选中查看的材料资源ID
BP_Click_Source_Jump_Index = -1;		-- 点击的物品来源索引
BP_Show_Play_Effect_Button = false;		-- 是否播放效果按钮
BP_Item_Upgrade_Is_Guiding = false;		-- 是否正在指引
BP_Item_Upgrade_Current_Guide_Step = -1;			-- 当前引导步骤
BP_Play_Upgrade_Effect_Index = -1; -- 需要播放升级效果索引
BP_Play_Effect_Last_Time_f = 4;		-- 播放特效持续时间

local Item_Type_Weapon = 1;		-- 枪械
local Default_Show_Item_ID = -1;		-- 打开时默认显示的物品ID
local Default_Select_Effect_Index = -1;
local lastClickItemResID = -1;

local Click_Upgrade_Btn_CD = 2;

function bp_item_upgrade_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_item_upgrade,
		{{Path="/Game/UMG/UI_Logic/Wardrobe/ItemUpgrade_BP.ItemUpgrade_BP_C", Container="Default", ZOrder=BP_ENUM_UI_WARDROBE_ZORDER + 1}},
		{"Lobby"},
		false,
		bp_item_upgrade_OnModeSwitched ~= nil,
		true
	);

	ItemUpgradeUI.InitTabList();
    ItemUpgradeSystem.Init();

	EventSystem:registEvent(EVENTTYPE_LOBBY, EVENTTYPE_CHECK_BACK_TO_VIEW, ItemUpgradeUI.OnMallSystemClose);
	EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_ITEM_UPGRADE, ItemUpgradeUI.OnJumpUrl);
end

function bp_item_upgrade_OnModeSwitched(gamestatus)
	if string.lower(gamestatus) == "fighting" then
        ItemUpgradeUI.Hide();
    elseif string.lower(gamestatus) == "login" then
        ItemUpgradeUI.Hide();
	end
end

function EventFetchInfo()
end

function ItemUpgradeUI.Init()
	if ItemUpgradeUI.isInited == true then
		return;
	end
    ItemUpgradeUI.isInited = true;
    ItemUpgradeEffectShowSystem.Init();
    -- 初始化枪械模型展示模块
    MallSystemWeaponModelHandler:Init();
	EventSystem:registEvent(EVENTTYPE_ITEM_UPGRADE, EVENTID_ITEM_UPGRADE_UPGRADE_RSP, ItemUpgradeUI.OnUpgradeRspCallBack);
	EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_DATA_CHANGE, ItemUpgradeUI.OnHallDepotDataUpdate);
	EventSystem:registEvent(EVENTTYPE_ITEM_UPGRADE, EVENTID_ITEM_UPGRADE_RED_POINT_DATA_CHANGE, ItemUpgradeUI.OnRedPointInfoUpdate);
end

function ItemUpgradeUI.Release()
	if ItemUpgradeUI.isInited == false then
		return;
	end
    ItemUpgradeUI.isInited = false;
    ItemUpgradeEffectShowSystem.Release();

	EventSystem:unregistEvent(EVENTTYPE_ITEM_UPGRADE, EVENTID_ITEM_UPGRADE_UPGRADE_RSP, ItemUpgradeUI.OnUpgradeRspCallBack);
	EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_DATA_CHANGE, ItemUpgradeUI.OnHallDepotDataUpdate);
	EventSystem:unregistEvent(EVENTTYPE_ITEM_UPGRADE, EVENTID_ITEM_UPGRADE_RED_POINT_DATA_CHANGE, ItemUpgradeUI.OnRedPointInfoUpdate);
end

function ItemUpgradeUI.OnJumpUrl(eventType, eventID, vars)
    if vars == nil or vars.itemId == nil then
        ItemUpgradeUI.Show();
    else
        ItemUpgradeUI.ShowByItemID(tonumber(vars.itemId));
    end
end

function ItemUpgradeUI.ShowByItemID(itemID)
	if LobbyUI:CheckLobbyMenuOpen(BP_ENUM_ITEM_UPGRADE, true) == false then
		return
	end
	local itemCfg = Client.GetTableData("Item", itemID);
	if itemCfg ~= nil then
		--log("ShowByItemID:"..ItemUpgradeSystem.GetSameGroupItem(itemID))
		ItemUpgradeUI.Show(itemCfg.ItemType, ItemUpgradeSystem.GetSameGroupItem(itemID));
	end
end

function ItemUpgradeUI.Show(pageType, defaultShowItemID)
	--log("ItemUpgradeUI.Show: ")
	if LobbyUI:CheckLobbyMenuOpen(BP_ENUM_ITEM_UPGRADE, true) == false then
		return
	end
	Client.StartUIStat("仓库-研究所");
	--log("ItemUpgradeUI.Show: "..tostring(pageType))
	LuaClassObj.HandleDynamicCreation(bp_item_upgrade);

	BP_Cur_Select_Page_Index = ItemUpgradeUI.PageTypeToIndex(pageType);
	Default_Show_Item_ID = defaultShowItemID or -1;
	lastClickItemResID = -1;
	Default_Select_Effect_Index = -1
	BP_Weapon_ResID = 0;
	BP_Cur_Show_Model_Type = ENUM_Item_Upgrade_Show_Model_Type.Weapon;

	ItemUpgradeUI.Init();
	if ItemUpgradeUI.isShow == false then
		ItemUpgradeUI.isShow = true;
		EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN);
		PanelOpenCloseAnimSystem.OpenView("ItemUpgradeUI.ShowEnd", "ItemUpgradeUI.HideEnd");
		--LuaClassObj.HandleUIMessageNoFetch(bp_item_upgrade, "SwitchCamera");
		LobbyCameraManager.SwitchCamera(10116);
		LobbySceneManager.ShowMesh(LobbySceneManager.MALL_MESH_Background_Weapon_02)
		--LobbySceneManager.VisiableObjectsByTag(LobbySceneManager.MALL_MESH_LobbyBgMesh, false)
		--LobbySceneManager.VisiableObjectsByTag(LobbySceneManager.MALL_MESH_Background_Weapon_02, true)
		EventItemUpgradeUIOnClickSwitchModel();
	end
	Client.StopUIStat("仓库-研究所", true);
end

function ItemUpgradeUI.ShowEnd()
	-- 打开界面
    LuaClassObj.HandleUIMessageNoFetch(bp_item_upgrade, "UIShow");
	UIManager.Show(eUIType.eItemUpgrade);
    -- 创建模型
    ItemUpgradeUI.CreateSelfPawn();
    LuaClassObj.HandleUIMessageNoFetch(bp_item_upgrade, "ShowPawn");
    -- 刷新界面
	ItemUpgradeUI.UpdateView();
	-- 检测是否有引导
	if BP_Item_Upgrade_Is_Guiding then
		EventItemUpgradeUITryNextGuide();
	else
		LuaClassObj.HandleUIMessageNoFetch(bp_item_upgrade, "UpdateGuideView");
	end
end

function EventItemUpgradeUIHide()
	ItemUpgradeUI.Hide();
end

function ItemUpgradeUI.Hide(immediately)
	immediately = immediately or false;
	ItemUpgradeUI.Release();
	if ItemUpgradeUI.isShow then
		LobbySceneManager.ChangeLight(LobbySceneManager.LIGHT_LOBBY)
		ItemUpgradeUI.isShow = false;
	    LuaClassObj.HandleUIMessageNoFetch(bp_item_upgrade, "UIHide");
		UIManager.Hide(eUIType.eItemUpgrade);
		EventFadeIn();
		if immediately then
			ItemUpgradeUI.HideEnd();
		else
			PanelOpenCloseAnimSystem.CloseView();
		end
	    -- 删除枪械模型
	    MallSystemWeaponModelHandler:DestroyWeaponShowActor();
	    -- 删除人物模型
	    LuaClassObj.HandleUIMessageNoFetch(bp_item_upgrade, "DestroyPawn");
	end
end

function ItemUpgradeUI.HideEnd()
	EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE);
	LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "UIShowFromMall");
	--LobbySceneManager.ShowMesh(LobbySceneManager.MALL_MESH_LobbyBgMesh)

	--LobbySceneManager.VisiableObjectsByTag(LobbySceneManager.MALL_MESH_LobbyBgMesh, true)
	--LobbySceneManager.VisiableObjectsByTag(LobbySceneManager.MALL_MESH_Background_Weapon_02, false)
    if ItemUpgradeUI.closeCallBack ~= nil then
    	ItemUpgradeUI.closeCallBack();
    	ItemUpgradeUI.closeCallBack = nil;
    end
end

-- 通过页签类型获取页签索引
function ItemUpgradeUI.PageTypeToIndex(pageType)
	if pageType == nil then
		return 0;
	end
	for index, pageInfo in ipairs(BP_ARRAY_ItemUpgrade_Page_List) do
		if pageInfo.itemType == pageType then
			return index - 1; 
		end
	end
	return 0;
end

-- 创建页签数据
function ItemUpgradeUI.InitTabList()
	BP_ARRAY_ItemUpgrade_Page_List = {};
	BP_ARRAY_ItemUpgrade_Page_List[1] = { itemType = Item_Type_Weapon };	-- 枪械
end

-- 创建人物模型
function ItemUpgradeUI.CreateSelfPawn()
	ItemUpgradeUI.InitDefaultPlayerData();
    LuaClassObj.HandleUIMessageNoFetch(bp_item_upgrade, "CreateSelfPawn");
    LuaClassObj.HandleUIMessageNoFetch(bp_item_upgrade, "UpdatePawnEquipments");
    LuaClassObj.HandleUIMessageNoFetch(bp_item_upgrade, "SetHumanLightProperty");
end

-- 创建默认大厅人物外观数据
function ItemUpgradeUI.InitDefaultPlayerData()
	local rolewear = {}
	
	for k,v in pairs(DataMgr.rolewear) do
		local itemData = DataMgr.GetHallDepotItemDataByInsID(v);
		if itemData ~= nil then
			table.insert(rolewear, LobbyUI.CreateClientAvatarWearInfo(itemData.resID, itemData.colorID, itemData.patternID));
		end
	end

	BP_STRUCT_ItemUpgradeSpawnPlayerData =
	{
		gid = tostring(DataMgr.roleData.uid),
		sex = DataMgr.avatarData.gamegender - 1,
		headId = DataMgr.avatarData.headid,
		index = BP_LobbyPlayerNum,
		BP_ARRAY_AvatarInfoList = rolewear
	}
	
	table.insert(BP_STRUCT_ItemUpgradeSpawnPlayerData.BP_ARRAY_AvatarInfoList, LobbyUI.CreateClientAvatarWearInfo(DataMgr.avatarData.hairid,0,0));
end

-- 切换到人物模型
function ItemUpgradeUI.SwitchPlayerPawn()
	MallSystemWeaponModelHandler:HideWeapon();

    LuaClassObj.HandleUIMessageNoFetch(bp_item_upgrade, "ShowPawn");

    LuaClassObj.HandleUIMessageNoFetch(bp_item_upgrade, "SetHumanLightProperty");
    -- 穿戴武器
	local curSelectEffectCfg = ItemUpgradeUI.GetCurSelectEffectCfg();
	if curSelectEffectCfg ~= nil then
    	ItemUpgradeUI.TryShowWeapon(curSelectEffectCfg.resID);
    end
	-- 刷新切换模型按钮
	ItemUpgradeUI.UpdateChangeModelBtn();
end

-- 切换到枪械模型
function ItemUpgradeUI.SwitchWeapon()
    LuaClassObj.HandleUIMessageNoFetch(bp_item_upgrade, "HidePawn");

	MallSystemWeaponModelHandler:ShowWeaponByResId(BP_Weapon_ResID, true, true, true, false, true)--, 20, -15);		

    LuaClassObj.HandleUIMessageNoFetch(bp_item_upgrade, "SetWeaponLightProperty");
	-- 刷新切换模型按钮
	ItemUpgradeUI.UpdateChangeModelBtn();
end

-- 装备/显示 枪械
function ItemUpgradeUI.TryShowWeapon(resID)
	if ItemUpgradeUI.GetShowOriginModel() ==false then
		return;
	end
	local pageType = BP_ARRAY_ItemUpgrade_Page_List[BP_Cur_Select_Page_Index + 1].itemType;
	if pageType ~= Item_Type_Weapon then
		return;
	end
	BP_Weapon_ResID = resID;
	if BP_Cur_Show_Model_Type == ENUM_Item_Upgrade_Show_Model_Type.Pawn then
		-- 装备枪械
    	LuaClassObj.HandleUIMessageNoFetch(bp_item_upgrade, "EquipWeapon");
	else
		-- 显示枪械
		MallSystemWeaponModelHandler:ShowWeaponByResId(BP_Weapon_ResID, true, true, true, false, true)--, 20, -15);	
	end	
end

-- 获取当前选中的效果配置
function ItemUpgradeUI.GetCurSelectEffectCfg()
	if #BP_ARRAY_ItemUpgrade_Effect_List > 0 then
		return BP_ARRAY_ItemUpgrade_Effect_List[BP_Select_Effect_Index + 1];
	end
	return nil;
end

-- 转换item数据
function ItemUpgradeUI.CreateUpgradeItemData(cfg)
	local itemCfg = Client.GetTableData("Item", cfg.ItemID);
	local itemInfo = DataMgr.GetHallDepotItemDataByResID(cfg.ItemID)
	if itemCfg == nil then return {} end;
	if itemInfo ~= nil then
		return {
					instID = itemInfo.insID,
					resID = cfg.ItemID,
					itemName = itemCfg.ItemName,
					quality = itemInfo.itemQuality,
					count = itemInfo.count,
					colorID = itemInfo.colorID or 0,
					patternID = itemInfo.patternID or 0,
					showRedPoint = ItemUpgradeSystem.ItemNeedShowRedPoint(cfg.ItemID),
					groupID = cfg.GroupID,
				};
	else
		return {
					resID = cfg.ItemID,
					itemName = itemCfg.ItemName,
					showRedPoint = ItemUpgradeSystem.ItemNeedShowRedPoint(cfg.ItemID),
					groupID = cfg.GroupID,
				};
	end
end

-- 刷新整个界面
function ItemUpgradeUI.UpdateView()
	--ItemUpgradeUI.UpdatePageItemList();
	-- 为了触发刷新BP_Item_Res_ID
	BP_Item_Res_ID = Default_Show_Item_ID or -1;
	-- 为了触发刷新BP_Select_Effect_Index
	BP_Select_Effect_Index = Default_Select_Effect_Index or -1;
	EventItemUpgradeUIOnClickPage();
end

-- 刷新页签列表
function ItemUpgradeUI.UpdatePageItemList()
	for _, info in pairs(BP_ARRAY_ItemUpgrade_Page_List) do
		info.isRed = 0;
		if ItemUpgradeSystem.PageNeedShowRedPoint(info.itemType) == true then
			info.isRed = 1;
		end
	end
	-- 刷新列表
	LuaClassObj.HandleUIMessageNoFetch(bp_item_upgrade, "UpdatePageList");
end

-- 刷新道具列表
function ItemUpgradeUI.UpdateItemList()
	-- 获取当前道具数据
	local pageType = BP_ARRAY_ItemUpgrade_Page_List[BP_Cur_Select_Page_Index + 1].itemType;
	local itemList = ItemUpgradeSystem.GetUpgradeItemsByType(pageType);
	BP_ARRAY_ItemUpgrade_Item_List = {};
	for i,itemInfo in ipairs(itemList) do
		BP_ARRAY_ItemUpgrade_Item_List[#BP_ARRAY_ItemUpgrade_Item_List + 1] = ItemUpgradeUI.CreateUpgradeItemData(itemInfo);
	end
	table.sort(BP_ARRAY_ItemUpgrade_Item_List, 
		function(a, b)
			local aIsMax = ItemUpgradeSystem.IsItemEffectMaxLevel(a.resID);
			local bIsMax = ItemUpgradeSystem.IsItemEffectMaxLevel(b.resID);
			local aLevel = ItemUpgradeSystem.GetItemEffectLevel(a.resID);
			local bLevel = ItemUpgradeSystem.GetItemEffectLevel(b.resID);

			if aIsMax and not(bIsMax) then
				return false;
			elseif not(aIsMax) and bIsMax then
				return true;
			else
				return a.groupID < b.groupID;
			end
		end
		);
	-- 选中第一个道具
	if BP_Item_Res_ID == -1 then
		if #BP_ARRAY_ItemUpgrade_Item_List > 0 then
			BP_Item_Res_ID = BP_ARRAY_ItemUpgrade_Item_List[1].resID;
		end
	end
	-- 根据ResID刷新当前道具特效等级
	if ItemUpgradeSystem.CheckHasSameGroupItem(BP_Item_Res_ID) then
		BP_Current_Item_Effect_Level = ItemUpgradeSystem.GetItemEffectLevel(BP_Item_Res_ID);
	else
		BP_Current_Item_Effect_Level = 0;
	end
	--log("BP_Current_Item_Effect_Level:"..tostring(BP_Current_Item_Effect_Level))
	-- 刷新列表
	LuaClassObj.HandleUIMessageNoFetch(bp_item_upgrade, "UpdateItemList");
end

-- 刷新效果列表
function ItemUpgradeUI.UpdateEffectList()
	-- 获取效果列表
	BP_ARRAY_ItemUpgrade_Effect_List = ItemUpgradeSystem.GetItemUpgradeEffectList(BP_Item_Res_ID);
	BP_Cur_Item_Effect_Max_Level = #BP_ARRAY_ItemUpgrade_Effect_List;
	-- 选中当前等级效果
	if BP_Select_Effect_Index == -1 and #BP_ARRAY_ItemUpgrade_Effect_List > 0 then
		if BP_Current_Item_Effect_Level == BP_Cur_Item_Effect_Max_Level then
			BP_Select_Effect_Index = BP_Current_Item_Effect_Level - 1;-- 当前等级对应的索引
		else
			BP_Select_Effect_Index = BP_Current_Item_Effect_Level;
		end
	end

	-- 刷新按钮显示状态
	local curSelectEffect = ItemUpgradeUI.GetCurSelectEffectCfg();
	-- if ItemUpgradeSystem.IsItemEffectMaxLevel(BP_Item_Res_ID) then
	if BP_Select_Effect_Index + 1 <= BP_Current_Item_Effect_Level then
		BP_Button_State = ENUM_Item_Upgrade_Button_State.Hide;
	elseif ItemUpgradeSystem.CheckHasSameGroupItem(BP_Item_Res_ID) == false and BP_Select_Effect_Index == 0 then
		BP_Button_State = ENUM_Item_Upgrade_Button_State.Go;
	else
		BP_Button_State = ENUM_Item_Upgrade_Button_State.Gray;
		if curSelectEffect ~= nil then
			local effectLevel = ItemUpgradeSystem.GetItemEffectLevel(curSelectEffect.resID);
			if BP_Current_Item_Effect_Level ~= BP_Cur_Item_Effect_Max_Level and BP_Current_Item_Effect_Level + 1 == effectLevel then
				BP_Button_State = ENUM_Item_Upgrade_Button_State.Normal;
			end
		end
	end

	-- 刷新播放效果按钮
	EventItemUpgradeUIUpdatePlayeEffectBtn();
	-- 刷新列表
	LuaClassObj.HandleUIMessageNoFetch(bp_item_upgrade, "UpdateEffectList");
	-- 刷新升级按钮
	LuaClassObj.HandleUIMessageNoFetch(bp_item_upgrade, "UpdateUpgradeBtn");
end

-- 刷新升级材料列表
function ItemUpgradeUI.UpdateMaterialList()
	-- 获取材料列表
	BP_ARRAY_ItemUpgrade_Material_List = {};

	local curSelectEffectCfg = ItemUpgradeUI.GetCurSelectEffectCfg();
	if curSelectEffectCfg == nil then
		return;
	end

	local list = ItemUpgradeSystem.GetItemUpgradeMaterialList(curSelectEffectCfg.resID);
	for i, cfg in ipairs(list) do
		BP_ARRAY_ItemUpgrade_Material_List[#BP_ARRAY_ItemUpgrade_Material_List + 1] = {
			resID = cfg.CostItem,
			count = DataMgr.GetHallDepotItemCountByResID(cfg.CostItem),
			needCount = cfg.CostItemNum,
			BP_ARRAY_SourceJump_List = ItemUpgradeSystem.GetItemJumpTypeIDList(cfg.CostItem),
		}
	end
	-- 刷新列表
	LuaClassObj.HandleUIMessageNoFetch(bp_item_upgrade, "UpdateMaterialList");
end

-- 刷新切换模型按钮
function ItemUpgradeUI.UpdateChangeModelBtn()
	BP_Show_Change_Mode_Button = BP_Cur_Select_Page_Index == 0 and ItemUpgradeUI.GetShowOriginModel();
    -- 刷新性别按钮
    LuaClassObj.HandleUIMessageNoFetch(bp_item_upgrade, "UpdateSwitchModelButton");
end

-- 获取当前选中的效果ID
function ItemUpgradeUI.GetShowOriginModel()
	local effectCfg = ItemUpgradeUI.GetCurSelectEffectCfg();
	if effectCfg ~= nil then
		local upgradeEffectCfg = Client.GetTableData("ItemUpgradeEffectConfig", effectCfg.effectID);
		return upgradeEffectCfg ~= nil and upgradeEffectCfg.DeadBox == "" and upgradeEffectCfg.KillEffect == "" and upgradeEffectCfg.HitEffect == "" and upgradeEffectCfg.KillBroadcast == ""
	end
	return true;
end

-- 播放当前选中特效
function ItemUpgradeUI.PlayEffect(effectID)
	BP_Show_Play_Effect_Button = false;
	-- 隐藏界面本身的模型
    LuaClassObj.HandleUIMessageNoFetch(bp_item_upgrade, "HidePawn");
    MallSystemWeaponModelHandler:HideWeapon();
	-- 显示效果
	local curEffectCfg = ItemUpgradeUI.GetCurSelectEffectCfg();
	if curEffectCfg then
		ItemUpgradeEffectShowSystem.ShowEffect(curEffectCfg.resID, effectID);
	end
	-- 刷新播放效果按钮
	LuaClassObj.HandleUIMessageNoFetch(bp_item_upgrade, "UpdatePlayEffectBtn");
end
--------------------------------蓝图调用lua部分------------------------------------
-- 点击页签
function EventItemUpgradeUIOnClickPage()
	-- 刷新页签列表
	ItemUpgradeUI.UpdatePageItemList();
	-- 触发一次点击物品
	ItemUpgradeUI.SelectCurItem();
end

-- 手动点击物品
function EventItemUpgradeUIOnClickItem()
	-- 记录红点
	ItemUpgradeSystem.RecordRedPointInfo(BP_Item_Res_ID);
	if lastClickItemResID ~= BP_Item_Res_ID then
		lastClickItemResID = BP_Item_Res_ID;
		ItemUpgradeUI.SelectCurItem();
	end
end

-- 选中物品
function ItemUpgradeUI.SelectCurItem()
	-- 刷新道具列表
	ItemUpgradeUI.UpdateItemList();
	-- 触发一次点击Item
	EventItemUpgradeUIOnClickEffectItem();
	-- 刷新界面
	LuaClassObj.HandleUIMessageNoFetch(bp_item_upgrade, "UpdateNormalInfo");
end

-- 点击效果页签
function EventItemUpgradeUIOnClickEffectItem()
	--log("EventItemUpgradeUIOnClickEffectItem:"..tostring(BP_Select_Effect_Index))
	--story=63973737 【生化升级枪】-研究所展示模型时默认展示枪械
	BP_Cur_Show_Model_Type = ENUM_Item_Upgrade_Show_Model_Type.Weapon;
	-- 刷新效果列表
	ItemUpgradeUI.UpdateEffectList();
	-- 刷新材料列表
	ItemUpgradeUI.UpdateMaterialList();
	-- 刷新切换模型按钮
	ItemUpgradeUI.UpdateChangeModelBtn();

	local effectCfg = ItemUpgradeUI.GetCurSelectEffectCfg();
	if effectCfg ~= nil then
		-- 穿戴/显示武器
		ItemUpgradeUI.TryShowWeapon(effectCfg.resID);
		if ItemUpgradeUI.GetShowOriginModel() == true then
			-- 清除所有效果
			ItemUpgradeEffectShowSystem.HideAll();
			-- 显示正常外显
			EventItemUpgradeUIOnClickSwitchModel();
		else
			EventItemUpgradeUIOnClickPlayEffect();
		end
	else
		-- 清除所有效果
		ItemUpgradeEffectShowSystem.HideAll();
		-- 显示正常外显
		EventItemUpgradeUIOnClickSwitchModel();
	end

	-- 关闭tips
	LuaClassObj.HandleUIMessageNoFetch(bp_item_upgrade, "CloseAllTips");
end

-- 切换按钮
function EventItemUpgradeUIOnClickSwitchModel()
	if BP_Cur_Show_Model_Type == ENUM_Item_Upgrade_Show_Model_Type.Weapon then
		-- 切到枪械
		ItemUpgradeUI.SwitchWeapon();
	else
		-- 切到人物
		ItemUpgradeUI.SwitchPlayerPawn();
	end
end

-- 点击升级按钮
function EventItemUpgradeUIOnClickUpgrade()
	if os.time() - ItemUpgradeUI.lastClickTime < Click_Upgrade_Btn_CD then
		--DataMgr.ShowNoticeByID(6340);
		return;
	end
	ItemUpgradeUI.lastClickTime = os.time();
	if BP_Select_Effect_Index ~= BP_Current_Item_Effect_Level then
		DataMgr.ShowNoticeByID(6340);
		return;
	end
	local cfg = ItemUpgradeSystem.GetUpgradeCfg(BP_Item_Res_ID);
	if cfg ~= nil then
		-- 获取消耗列表
		local costList = ItemUpgradeSystem.GetUpgradeNextLevelCostList(BP_Item_Res_ID);
		if costList then
			local itemInfo = DataMgr.GetHallDepotItemDataByResID(BP_Item_Res_ID);
			ItemUpgradeSystem.upgrade_item_req(itemInfo.insID, cfg.GroupID, BP_Current_Item_Effect_Level + 1, costList)
		else
			log("EventItemUpgradeUIOnClickUpgrade costList = nil")
		end
	else
		log("EventItemUpgradeUIOnClickUpgrade cfg = nil")
	end
end

-- 点击跳转到商城
function EventItemUpgradeUIOnClickGo()
	local itemUpgradeJumpConfig = ItemUpgradeSystem.GetItemSourceJumpConfig(BP_Item_Res_ID);
	if itemUpgradeJumpConfig ~= nil then
		if GlobalData:CheckCanJumpByTypeID(BP_Item_Res_ID, itemUpgradeJumpConfig.JumpType1) then
			ItemUpgradeUI.SetCloseCallBack(nil);
			ItemUpgradeUI.Hide(true);
			GlobalData:JumpByTypeID(BP_Item_Res_ID, itemUpgradeJumpConfig.JumpType1);
			ItemUpgradeUI.jumpViewCloseCallBack = function() ItemUpgradeUI.Show(); end;
			return;
		end
	end
	DataMgr.ShowNoticeByID(6430);
end

-- 点击材料来源跳转
function EventItemUpgradeUIOnClickMaterialSourceJump()
	--log("EventItemUpgradeUIOnClickMaterialSourceJump")
	local selectMat = BP_ARRAY_ItemUpgrade_Material_List[BP_Select_Material_Index + 1];
	if selectMat ~= nil and BP_Click_Source_Jump_Index ~= -1 then
		local jumpTypeID = selectMat.BP_ARRAY_SourceJump_List[BP_Click_Source_Jump_Index + 1];
		if GlobalData:CheckCanJumpByTypeID(selectMat.resID, jumpTypeID) then
			ItemUpgradeUI.SetCloseCallBack(nil);
			ItemUpgradeUI.Hide(true);
			local ret = GlobalData:JumpByTypeID(selectMat.resID, jumpTypeID);
			ItemUpgradeUI.jumpViewCloseCallBack = function() ItemUpgradeUI.Show(); end;
		else
			DataMgr.ShowNoticeByID(6430);
		end
	end
end

-- 点击播放当前选中效果
function EventItemUpgradeUIOnClickPlayEffect()
	LuaClassObj.HandleUIMessageNoFetch(bp_item_upgrade, "OnPlayEffectEnd");
	local curSelectEffect = ItemUpgradeUI.GetCurSelectEffectCfg();
	if curSelectEffect ~= nil then
		if curSelectEffect ~= nil then
			if curSelectEffect.effectID ~= 1 then
				ItemUpgradeUI.PlayEffect(curSelectEffect.effectID);
			end
		end

		local effectCfg = Client.GetTableData("ItemUpgradeEffectConfig", curSelectEffect.effectID);
		if effectCfg ~= nil then
			if (effectCfg.HitEffect ~= "" or effectCfg.KillEffect ~= "") then
				BP_Play_Effect_Last_Time_f = effectCfg.EffectLastTime or 0;
				LuaClassObj.HandleUIMessageNoFetch(bp_item_upgrade, "OnPlayEffectBegin");
			end
			if effectCfg.KillBroadcast ~= "" then-- 击杀播报也需要显示武器
				BP_Weapon_ResID = curSelectEffect.resID;
				ItemUpgradeUI.SwitchWeapon();
			end
		end
	end
end

-- 刷新播放按钮
function EventItemUpgradeUIUpdatePlayeEffectBtn()
	local curSelectEffect = ItemUpgradeUI.GetCurSelectEffectCfg();
	if curSelectEffect ~= nil then
		local effectCfg = Client.GetTableData("ItemUpgradeEffectConfig", curSelectEffect.effectID);
		BP_Show_Play_Effect_Button = effectCfg ~= nil and (effectCfg.HitEffect ~= "" or effectCfg.KillEffect ~= "");-- 击中和击杀特效
	end
	-- 刷新播放效果按钮
	LuaClassObj.HandleUIMessageNoFetch(bp_item_upgrade, "UpdatePlayEffectBtn");
end

function ItemUpgradeUI.StartGuide()
	BP_Item_Upgrade_Is_Guiding = true;
	EventItemUpgradeUITryNextGuide();
end

-- 进入下一步引导
function EventItemUpgradeUITryNextGuide()
	if BP_Item_Upgrade_Current_Guide_Step < ItemUpgradeUI.maxGuideStepCount - 1 then
		BP_Item_Upgrade_Current_Guide_Step = BP_Item_Upgrade_Current_Guide_Step + 1;

		if BP_Item_Upgrade_Current_Guide_Step == 0 then

		elseif BP_Item_Upgrade_Current_Guide_Step == 1 then
			if DataMgr.GetHallDepotItemDataByResID(BP_Item_Res_ID) then
				EventItemUpgradeUITryNextGuide();--已有道具 直接跳下一步
			else
				BP_Cur_Select_Page_Index = 0;
				EventItemUpgradeUIOnClickEffectItem();
			end
		elseif BP_Item_Upgrade_Current_Guide_Step == 2 then
			BP_Select_Effect_Index = 1;--选中第二个效果
			EventItemUpgradeUIOnClickEffectItem();
		elseif BP_Item_Upgrade_Current_Guide_Step == 3 then
			-- BP_Cur_Select_Page_Index = 0;
			-- EventItemUpgradeUIOnClickEffectItem();
		end
		LuaClassObj.HandleUIMessageNoFetch(bp_item_upgrade, "UpdateGuideView");
	else
		if BP_Item_Upgrade_Is_Guiding == true then
			BP_Item_Upgrade_Is_Guiding = false;
			BP_Item_Upgrade_Current_Guide_Step = -1;
			DataMgr.SetNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_ITEM_UPGRADE, 1);
			LuaClassObj.HandleUIMessageNoFetch(bp_item_upgrade, "UpdateGuideView");
		end
	end
end
----------------消息回调-----------------
-- ret =
-- {
-- 	[1]=new_instid, #新的物品id
-- 	[2]=instid, 	#原来的物品id
-- 	[3]=group_id,   #升级物品所在的组
-- 	[4]=item_level, #升到的等级
-- 	[5]=item_cost   #消耗
-- }
function ItemUpgradeUI.OnUpgradeRspCallBack(eventType, eventID, ret)
	--log_tree("ItemUpgradeUI.OnUpgradeRspCallBack ret = ", ret);
	if ret ~= nil then
		ItemUpgradeUI.hasUpgraded = true;
		local instID = tostring(ret[1]);
		local item = DataMgr.GetHallDepotItemDataByInsID(instID);
		if item ~= nil then
			BP_Item_Res_ID = item.resID;
			-- BP_Select_Effect_Index = -1;--ItemUpgradeUI.GetEffectIndexByResID(item.resID) + 1;
			-- BP_Play_Upgrade_Effect_Index = ItemUpgradeUI.GetEffectIndexByResID(BP_Item_Res_ID);
			-- ItemUpgradeUI.SelectCurItem();
			-- BP_Play_Upgrade_Effect_Index = -1;
			ItemUpgradeUI.TryToUpdateView();
		end
	end
end

-- 物品变更
function ItemUpgradeUI.OnHallDepotDataUpdate()
	--log("ItemUpgradeUI.OnHallDepotDataUpdate")
	ItemUpgradeUI.TryToUpdateView()
	--BP_Select_Effect_Index = -1;--ItemUpgradeUI.GetEffectIndexByResID(BP_Item_Res_ID) + 1;
	--BP_Play_Upgrade_Effect_Index = ItemUpgradeUI.GetEffectIndexByResID(BP_Item_Res_ID);
	--ItemUpgradeUI.SelectCurItem();
	--BP_Play_Upgrade_Effect_Index = -1;
end

function ItemUpgradeUI.TryToUpdateView()
	if ItemUpgradeUI.hasUpgraded == true and DataMgr.GetHallDepotItemDataByResID(BP_Item_Res_ID) then
		BP_Select_Effect_Index = -1;
		BP_Play_Upgrade_Effect_Index = ItemUpgradeUI.GetEffectIndexByResID(BP_Item_Res_ID);
		ItemUpgradeUI.SelectCurItem();
		LuaClassObj.HandleUIMessageNoFetch(bp_item_upgrade, "CheckPlayUpgradeEffect");
		BP_Play_Upgrade_Effect_Index = -1;
		ItemUpgradeUI.hasUpgraded = false;
	end
end

-- 红点信息变更
function ItemUpgradeUI.OnRedPointInfoUpdate()
	ItemUpgradeUI.UpdatePageItemList();
	ItemUpgradeUI.UpdateItemList();
end

-- 通过物品ID获取对应效果特效索引
function ItemUpgradeUI.GetEffectIndexByResID(resID)
	for index, effect in ipairs(BP_ARRAY_ItemUpgrade_Effect_List) do
		if effect.resID == resID then
			return index - 1;
		end
	end
	return -1;
end

-- 商城界面关闭
function ItemUpgradeUI.OnMallSystemClose(eventType, eventID, isClickClose)
	if ItemUpgradeUI.jumpViewCloseCallBack ~= nil then
		if isClickClose == true then
			ItemUpgradeUI.jumpViewCloseCallBack();
		end
		ItemUpgradeUI.jumpViewCloseCallBack = nil;
	end
end

function ItemUpgradeUI.SetCloseCallBack(func)
	ItemUpgradeUI.closeCallBack = func;
end

function ItemUpgradeUI.AndroidBack()
	if BP_Item_Upgrade_Is_Guiding == true then
		return
	end
	if ItemUpgradeUI.isShowUpgradeEffect == true then
		LuaClassObj.HandleUIMessageNoFetch(bp_item_upgrade, "LuaCloseLevelUpgradeEffect");
		return
	end
	ItemUpgradeUI.Hide();
end

-- 设置是否正在显示升级特效
function ItemUpgradeUI.SetIsShowUpgradeEffect(show)
	ItemUpgradeUI.isShowUpgradeEffect = show;
end