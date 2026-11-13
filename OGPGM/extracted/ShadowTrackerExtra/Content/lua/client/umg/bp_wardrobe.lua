local wardrobeSubType_Parachute = 701
local wardrobeSubType_Plane = 801
local wardrobeMainTab_Vehicle = 9

local quickMessageWindow = nil

--仓库UI
WardrobeUI = WardrobeUI or
{
	tabStringToType = nil,
	tabTypeToString = nil,

	mainTabToSubTabArray = {};
	
	isShowing = false,
	isPlayingOutAnim = false,
	needShowRedPoint = false,
	
	redPointTabType = {},

	currentWearPreviewMap = {},
	wearPreviewInfo = {insID = "", resID = 0},

	defaultParachuteResID = 0,

	secToHour = 1 / 3600,
	hourToDay = 1 / 24,

	pageTypeMask = {1, 2, 4},
	saveIsShowing = false,
	
	reviseNameCardId = 1601002, --改名卡id
	reviseCorpsCardId = 1601003, --军团改名卡id
	--shaojiItemId = 1602008, --烧鸡道具
	useType = {15, 16, 21, 26},
	activeSubType = {400, 406},--激活子类型

	RolewearIndexTwoUnlockConfigID = 1,
	RolewearIndexThreeUnlockConfigID = 2,
	RolewearIndexFourUnlockConfigID = 3,

	isUnlockingRolewear = false,

	checkShowJumpToExchangeCB = {},

	decomposeItemSubType = {401, 402, 403, 404, 405, wardrobeSubType_Parachute, 1602, 101, 102, 103, 104, 105, 106, 107, 108,
	504, 505, 801, 901, 902, 903, 904, 905, 906, 907, 908, 909, 910, 911, 912, 913, 914, 915, 918, 1604},

	wardrobeTabType_emoj = 8,
	wardrobeTabType_gun = 9,

	wardrobeSubType_Hat = 401,	--帽子
	wardrobeSubType_Bag = 504,  -- 背包
	wardrobeSubType_Helmet = 505,  -- 头盔
	wardrobeSubType_Armor = 506,  -- 防弹衣
    wardrobeTabType_quickmessage = 1901, -- 快捷语音
	wardrobeEquipmentSubType = {504, 505, 506},
	wardrobeEquipmentTabString = {},

	countryFlagCardId = 1702009, -- 旗帜卡id

	timeOffset = 1000000000, --为了防止时间戳在蓝图里越界，这里减一个常数
	
	--红装-表情tb
	redEmotionTb = {},

	isShowVoiceGuild = false,
	isShowNewBee = false,

}

--仓库物品信息(定义结构体：当且仅当以BP_STRUCT_开头的table能作为结构体给蓝图访问)
--仓库格子数据
BP_STRUCT_WardrobeItemInfo =
{
    ins_id = "",
	res_id = 0,
    count = 0,
	is_using = false,
	is_new = false,
	is_selected = false,
	is_sourcebook = false, -- 是否为图鉴
	validHours = 0,
	expireTS = 0,
	itemSubType = 0,
	itemQuality = 0,
	color_id = 0,
	pattern_id = 0,

	use_count = 0,
	is_isolated = false; -- 是否为服务器隔离
};

-- 时装背包解锁的时间类型
BP_RolewearUnlockConfigID = 0;

-- 当前时间戳
BP_CurrnetTimeStamp = 0;

BP_RolewearRPPopupType = 0; -- 弹出的RP说明弹窗的类型，0是未解锁的相关说明，1是成功解锁的通知，2是解锁后的有效期提示

--时装背包解锁信息
BP_STRUCT_RolewearUnlockCostInfo = 
{
	ID = 0;
	time = 0;
	uc_cost = 0;
	bp_cost = 0;
};

BP_ARRAY_RolewearUnlockCostInfo = 
{
	BP_STRUCT_RolewearUnlockCostInfo = _G.BP_STRUCT_RolewearUnlockCostInfo, 
};

--仓库物品信息列表(定义结构体数组：当且仅当以BP_ARRAY_开头的table能作为数组给蓝图访问)
-- 当前页签的item列表
BP_ARRAY_WardrobeItemList = 
{
	BP_STRUCT_WardrobeItemInfo = _G.BP_STRUCT_WardrobeItemInfo, --定义结构体数组，这种写法要作为规范规定下来
};

BP_ARRAY_Wardrobe_SourceBookItemList =
{
	BP_STRUCT_WardrobeItemInfo = _G.BP_STRUCT_WardrobeItemInfo, --定义结构体数组，这种写法要作为规范规定下来
};

-- 当前页签类型
BP_CurTabType = 0;
-- 大页签类型
BP_CurPageTabType = 0;
-- 时装背包的index
BP_RolewearTabIndex = 1;

BP_UnlockedRolewearTabIndex = 1

-- 时装背包的开启状态 0是未解锁，-1是可以解锁，-2是已解锁
BP_ARRAY_RolewearState = {0, 0, 0, 0};

-- 时装背包的解锁类型，0是默认解锁，2是消耗金币/UC，3是依赖物品（RP）
BP_ARRAY_RolewearUnlockType = {0, 0, 0, 0};

-- RP弹窗展示的物品ID
BP_ARRAY_RPPopupDisplayItem = {1405096,1402132,2203801,1101008014,1405098,1501000045,1903018,2203101,1405100,1405097};



-- 仓库金币数值
BP_WardrobeGold = "";

-- 仓库钻石数值（银碎片）
BP_WardrobeDiamond = "";

-- 仓库金碎片数值
BP_WardrobeGoldChip = "";

-- 卖出的item的insID
BP_Sell_id = "";

-- 变化的item数据
BP_STRUCT_WardrobeChangedItemData = _G.BP_STRUCT_WardrobeItemInfo;
-- 点击的item数据
BP_STRUCT_WardrobeClickedItemData = _G.BP_STRUCT_WardrobeItemInfo;

-- 点击的item数据
-- BP_ClickItemInsID = "";
-- BP_ClickItemUsingState = false;

-- tabIcon变化信息
-- BP_ChangeTabType = 0;
-- BP_ChangeTabIcon = 0;

-- 用于数值通讯的大页签tab类型
BP_ChangePageTabType = 0;

-- BP_LastPageType = 0;
-- 需要显示小红点的tab类型
-- BP_LastTabType = 0;

-- 需要跳转的物品ID
BP_WARDROBE_Jump_Item_resID = 0;

-- 显示的背景ID
BP_Wardrobe_BG_resID = 0;
-- 是否显示装备中
BP_Wardrobe_BG_showPutOn = true;

-- 显示的剩余时间
BP_String_Wardrobe_RemainTime = "";
BP_Wardrobe_RemainTime = 0;
BP_Wardrobe_IsShowUseButton = false;
BP_Wardrobe_UseButtonText = "使用";

-- BP_PageRedPointMask = 0;
-- BP_TabRedPointMask = 0;

BP_ARRAY_Wardrobe_PageRedPoint = {0};
BP_ARRAY_Wardrobe_TabRedPoint = {0};

-- 页签显示数据
local curTabIcon = {};
BP_STRUCT_CurPageTabIconData =
{
	id = 0;  -- 小页签id
	item_res_id = 0;  -- 当前页签对应的物品
}
BP_ARRAY_CurPageTabIcon =
{
	BP_STRUCT_CurPageTabIconData = _G.BP_STRUCT_CurPageTabIconData, --定义结构体数组，这种写法要作为规范规定下来
};

BP_Wardrobe_DecomposeItemInsID = "";

BP_Wardrobe_ComposeItemInsID = "";

BP_Wardrobe_ComposeItem_NeedNum = 0;
BP_Wardrobe_ComposeItem_CurNum = 0;

BP_Wardrobe_IsShowDecomposeButton = false;

BP_Wardrobe_IsShowComposeButton = false;

BP_Wardrobe_IsShowJumpToExchange = false;

BP_Wardrobe_IsShowJumpToShop = true;

BP_Wardrobe_EquipEmoj_ResId = 0;

BP_Wardrobe_EquipEmoj_InsId = "";

BP_Wardrobe_EquipmentDefaultLable = ""

BP_Wardrobe_IsShowUpgradeButton = false;

BP_Wardrobe_UpgradeItem_Is_Max_Level = false;

BP_Wardrobe_ItemUpgrade_Entrace_RedPoint = false;-- 研究所红点

BP_Wardrobe_Item_Upgrade_IsShow_Mask = false;	--

BP_Wardrobe_Item_Upgrade_Entrance_Open = false;

BP_Wardrobe_ResetAvatar_RedPoint = false; -- 重置外观红点

BP_Wardrobe_Pet_RedPoint = false; --宠物红点

--sami 是否可以使用红装表情
BP_Wardrobe_RedEmotion_Check_ItemId = 0
BP_Wardrobe_RedEmotion_Check_Result = false
-- 装备等级Label
BP_STRUCT_WardrobeEquipmentLabel =
{
	level_one = "";
	level_two = "";
	level_three = "";
}

-- 装备等级
BP_STRUCT_WardrobeEquipmentLevel =
{
	bag = 3,  -- 背包
	helmet = 3,  -- 头盔
	armor = 3,  -- 防弹衣
}

--仓库物品信息(定义结构体：当且仅当以BP_STRUCT_开头的table能作为结构体给蓝图访问)
--仓库页签定义
BP_STRUCT_WardrobePage =
{
    id = 0;  -- 小页签id
    page_id = 0; -- 大页签
    change_icon = true;  -- 是否需要改变页签
    index = 0;
};

BP_ARRAY_WardrobePageList = 
{
	BP_STRUCT_WardrobePage = _G.BP_STRUCT_WardrobePage, --定义结构体数组，这种写法要作为规范规定下来
};

BP_ARRAY_VehicleTabList =
{
	BP_STRUCT_WardrobePage = _G.BP_STRUCT_WardrobePage,
};

WardrobeUI.LAST_REQ_MALL_TIME = 0;

--sami 控件状态-是否大厅显示载具
BP_Wardrobe_CheckBox_Show_In_Hall_Sts = false;


--仓库页签定义结束
BP_Wardrobe_IsPetShow = false;

function WardrobeUI.InitTabMap(type, string)
	WardrobeUI.tabTypeToString[type] = string;
	WardrobeUI.tabStringToType[string] = type;
end

local UI_SEND_BUTTON_SWITCH_ID = 70003; -- 赠送按钮的开关配置
local function CheckFuncSwitch(funcID)
    local switch = LobbySystem.LobbyMenuOpenStatus[funcID];
    if switch ~= nil and switch.is_open == 1 then
        return true;
	end
    return false;
end

function WardrobeUI.InitPageList()
	-- Tab1 服装
	local page = 0;
	page = BP_ENUM_WardrobePageType_Avatar;
	BP_ARRAY_WardrobePageList = {}
	table.insert(BP_ARRAY_WardrobePageList, {id = 0, page_id = page, change_icon=true, index=0})
	table.insert(BP_ARRAY_WardrobePageList, {id = 15, page_id = page, change_icon=true, index=1})
	table.insert(BP_ARRAY_WardrobePageList, {id = 1, page_id = page, change_icon=true, index=2})
	table.insert(BP_ARRAY_WardrobePageList, {id = 2, page_id = page, change_icon=true, index=3})
	table.insert(BP_ARRAY_WardrobePageList, {id = 3, page_id = page, change_icon=true, index=4})
	table.insert(BP_ARRAY_WardrobePageList, {id = 4, page_id = page, change_icon=true, index=5})
	table.insert(BP_ARRAY_WardrobePageList, {id = 5, page_id = page, change_icon=true, index=6})
	table.insert(BP_ARRAY_WardrobePageList, {id = 202, page_id = page, change_icon=true, index=7})
	
	-- Tab2 枪械
	page = BP_ENUM_WardrobePageType_Gun;

	-- Tab3 载具
	page = BP_ENUM_WardrobePageType_Vehicle;
	table.insert(BP_ARRAY_WardrobePageList, {id = 901, page_id = page, change_icon=true, index=0})
	table.insert(BP_ARRAY_WardrobePageList, {id = 902, page_id = page, change_icon=true, index=1})
	table.insert(BP_ARRAY_WardrobePageList, {id = 903, page_id = page, change_icon=true, index=2})
	table.insert(BP_ARRAY_WardrobePageList, {id = 904, page_id = page, change_icon=true, index=3})
	table.insert(BP_ARRAY_WardrobePageList, {id = 905, page_id = page, change_icon=true, index=4})
	table.insert(BP_ARRAY_WardrobePageList, {id = 906, page_id = page, change_icon=true, index=5})
	table.insert(BP_ARRAY_WardrobePageList, {id = 907, page_id = page, change_icon=true, index=6})
	table.insert(BP_ARRAY_WardrobePageList, {id = 908, page_id = page, change_icon=true, index=7})
	table.insert(BP_ARRAY_WardrobePageList, {id = 909, page_id = page, change_icon=true, index=8})
	table.insert(BP_ARRAY_WardrobePageList, {id = 910, page_id = page, change_icon=true, index=9})
	table.insert(BP_ARRAY_WardrobePageList, {id = 911, page_id = page, change_icon=true, index=10})
	table.insert(BP_ARRAY_WardrobePageList, {id = 912, page_id = page, change_icon=true, index=11})
	table.insert(BP_ARRAY_WardrobePageList, {id = 913, page_id = page, change_icon=true, index=12})
	table.insert(BP_ARRAY_WardrobePageList, {id = 914, page_id = page, change_icon=true, index=13})
	table.insert(BP_ARRAY_WardrobePageList, {id = 915, page_id = page, change_icon=true, index=14})
	--table.insert(BP_ARRAY_WardrobePageList, {id = 916, page_id = page, change_icon=true, index=15})
	--table.insert(BP_ARRAY_WardrobePageList, {id = 917, page_id = page, change_icon=true, index=16})
	table.insert(BP_ARRAY_WardrobePageList, {id = 918, page_id = page, change_icon=true, index=17})

	BP_ARRAY_VehicleTabList = {}
	table.insert(BP_ARRAY_VehicleTabList, {id = 901, page_id = page, change_icon=true, index=0})
	table.insert(BP_ARRAY_VehicleTabList, {id = 902, page_id = page, change_icon=true, index=1})
	table.insert(BP_ARRAY_VehicleTabList, {id = 903, page_id = page, change_icon=true, index=2})
	table.insert(BP_ARRAY_VehicleTabList, {id = 904, page_id = page, change_icon=true, index=3})
	table.insert(BP_ARRAY_VehicleTabList, {id = 905, page_id = page, change_icon=true, index=4})
	table.insert(BP_ARRAY_VehicleTabList, {id = 906, page_id = page, change_icon=true, index=5})
	table.insert(BP_ARRAY_VehicleTabList, {id = 907, page_id = page, change_icon=true, index=6})
	table.insert(BP_ARRAY_VehicleTabList, {id = 908, page_id = page, change_icon=true, index=7})
	table.insert(BP_ARRAY_VehicleTabList, {id = 909, page_id = page, change_icon=true, index=8})
	table.insert(BP_ARRAY_VehicleTabList, {id = 910, page_id = page, change_icon=true, index=9})
	table.insert(BP_ARRAY_VehicleTabList, {id = 911, page_id = page, change_icon=true, index=10})
	table.insert(BP_ARRAY_VehicleTabList, {id = 912, page_id = page, change_icon=true, index=11})
	table.insert(BP_ARRAY_VehicleTabList, {id = 913, page_id = page, change_icon=true, index=12})
	table.insert(BP_ARRAY_VehicleTabList, {id = 914, page_id = page, change_icon=true, index=13})
	table.insert(BP_ARRAY_VehicleTabList, {id = 915, page_id = page, change_icon=true, index=14})
	--table.insert(BP_ARRAY_VehicleTabList, {id = 916, page_id = page, change_icon=true, index=15})
	--table.insert(BP_ARRAY_VehicleTabList, {id = 917, page_id = page, change_icon=true, index=16})
	table.insert(BP_ARRAY_VehicleTabList, {id = 918, page_id = page, change_icon=true, index=17})

	-- Tab4 Parachute
	page = BP_ENUM_WardrobePageType_Parachute;
	table.insert(BP_ARRAY_WardrobePageList, {id = 7, page_id = page, change_icon=true, index=0})
	table.insert(BP_ARRAY_WardrobePageList, {id = 8, page_id = page, change_icon=true, index=1})
	table.insert(BP_ARRAY_WardrobePageList, {id = 16, page_id = page, change_icon=true, index=2})
	table.insert(BP_ARRAY_WardrobePageList, {id = 504, page_id = page, change_icon=true, index=3})
	table.insert(BP_ARRAY_WardrobePageList, {id = 505, page_id = page, change_icon=true, index=4})
	-- table.insert(BP_ARRAY_WardrobePageList, {id = 506, page_id = page, change_icon=false, index=5})
	table.insert(BP_ARRAY_WardrobePageList, {id = 1901, page_id = page, change_icon=true, index=5})

	-- Tab5 Tools
	page = BP_ENUM_WardrobePageType_Tools;
	table.insert(BP_ARRAY_WardrobePageList, {id = 6, page_id = page, change_icon=true, index=0})
end

function bp_wardrobe_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_wardrobe,
		{
			{Path="/Game/UMG/UI_Logic/Wardrobe/Wardrobe_BP.Wardrobe_BP_C", Container="Default", ZOrder=BP_ENUM_UI_WARDROBE_ZORDER},
			{Path="/Game/UMG/UI_BP/Wardrobe/Wardrobe_Buy_Item.Wardrobe_Buy_Item_C", Container="Default", ZOrder=100},
			{Path="/Game/UMG/UI_BP/Wardrobe/Wardrobe_RP_UIBP.Wardrobe_RP_UIBP_C", Container="Default", ZOrder=100}
		},
		{"Lobby"},
		false,
		bp_wardrobe_OnModeSwitched ~= nil,
		false
	);
	
	BP_STRUCT_WardrobeChangedItemData = {};
	BP_STRUCT_WardrobeClickedItemData = {};
	BP_ARRAY_Wardrobe_GunType = {};

	WardrobeUI.tabTypeToString = {};
	WardrobeUI.tabStringToType = {};
	WardrobeUI.wardrobeEquipmentTabString = {BP_ENUM_wardrobeTabString_bag, BP_ENUM_wardrobeTabString_helmet, BP_ENUM_wardrobeTabString_armor};

	WardrobeUI.InitTabMap(0, BP_ENUM_wardrobeTabString_all)
	WardrobeUI.InitTabMap(1, BP_ENUM_wardrobeTabString_head)
	WardrobeUI.InitTabMap(2, BP_ENUM_wardrobeTabString_face)
	WardrobeUI.InitTabMap(3, BP_ENUM_wardrobeTabString_clothes)
	WardrobeUI.InitTabMap(4, BP_ENUM_wardrobeTabString_trousers)
	WardrobeUI.InitTabMap(5, BP_ENUM_wardrobeTabString_shoes)
	WardrobeUI.InitTabMap(6, BP_ENUM_wardrobeTabString_items)
	WardrobeUI.InitTabMap(7, BP_ENUM_wardrobeTabString_parachute)
	WardrobeUI.InitTabMap(8, BP_ENUM_wardrobeTabString_emoj)
	WardrobeUI.InitTabMap(15, BP_ENUM_wardrobeTabString_suit)
	WardrobeUI.InitTabMap(16, BP_ENUM_wardrobeTabString_plane)
	WardrobeUI.InitTabMap(202, BP_ENUM_wardrobeTabString_hallTheme)
	WardrobeUI.InitTabMap(504, BP_ENUM_wardrobeTabString_bag)
	WardrobeUI.InitTabMap(505, BP_ENUM_wardrobeTabString_helmet)
	WardrobeUI.InitTabMap(506, BP_ENUM_wardrobeTabString_armor)
	WardrobeUI.InitTabMap(901, BP_ENUM_wardrobeTabString_vehicle_Motorbike)
	WardrobeUI.InitTabMap(902, BP_ENUM_wardrobeTabString_vehicle_Motorbike_SideCart)
	WardrobeUI.InitTabMap(903, BP_ENUM_wardrobeTabString_vehicle_Dacia)
	WardrobeUI.InitTabMap(904, BP_ENUM_wardrobeTabString_vehicle_MiniBus)
	WardrobeUI.InitTabMap(905, BP_ENUM_wardrobeTabString_vehicle_PickUp)
	WardrobeUI.InitTabMap(906, BP_ENUM_wardrobeTabString_vehicle_PickUp_1)
	WardrobeUI.InitTabMap(907, BP_ENUM_wardrobeTabString_vehicle_Buggy_0)
	WardrobeUI.InitTabMap(908, BP_ENUM_wardrobeTabString_vehicle_UAZ_0)
	WardrobeUI.InitTabMap(909, BP_ENUM_wardrobeTabString_vehicle_UAZ_1)
	WardrobeUI.InitTabMap(910, BP_ENUM_wardrobeTabString_vehicle_UAZ_2)
	WardrobeUI.InitTabMap(911, BP_ENUM_wardrobeTabString_vehicle_PG117)
	WardrobeUI.InitTabMap(912, BP_ENUM_wardrobeTabString_vehicle_Aquarail)
	WardrobeUI.InitTabMap(913, BP_ENUM_wardrobeTabString_vehicle_UAZ_3)
	WardrobeUI.InitTabMap(914, BP_ENUM_wardrobeTabString_vehicle_SportsCar_0)
	WardrobeUI.InitTabMap(915, BP_ENUM_wardrobeTabString_vehicle_SportsCar_1)
	WardrobeUI.InitTabMap(916, BP_ENUM_wardrobeTabString_vehicle_FootboardMotor)
	WardrobeUI.InitTabMap(917, BP_ENUM_wardrobeTabString_vehicle_RosnyPickUp)
	WardrobeUI.InitTabMap(918, BP_ENUM_wardrobeTabString_vehicle_SnowMotorbike)

	WardrobeUI.InitTabMap(WardrobeUI.wardrobeTabType_gun, BP_ENUM_wardrobeTabString_gun)
	WardrobeUI.InitTabMap(WardrobeUI.wardrobeTabType_quickmessage, BP_ENUM_wardrobeTabString_quickmessage)

	WardrobeUI.mainTabToSubTabArray =
	{
		[BP_ENUM_WardrobePageType_Avatar] = {BP_ENUM_wardrobeTabString_head, BP_ENUM_wardrobeTabString_face, BP_ENUM_wardrobeTabString_clothes, BP_ENUM_wardrobeTabString_trousers, BP_ENUM_wardrobeTabString_shoes,BP_ENUM_wardrobeTabString_suit},
		[BP_ENUM_WardrobePageType_Parachute] = {BP_ENUM_wardrobeTabString_parachute, BP_ENUM_wardrobeTabString_emoj,BP_ENUM_wardrobeTabString_plane, },
		[BP_ENUM_WardrobePageType_Tools] = {BP_ENUM_wardrobeTabString_items},--BP_ENUM_wardrobeTabString_quickmessage, },
		[BP_ENUM_WardrobePageType_Gun] = {BP_ENUM_wardrobeTabString_gun},
	};

	WardrobeUI.checkShowJumpToExchangeCB[BP_ENUM_MODULE_ACTIVITY] = WardrobeUI.IsActivityEnable;

	EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_WARDROBE, WardrobeUI.Show);

	WardrobeUI.InitPageList();
end

function bp_wardrobe_OnModeSwitched(gamestatus)
	--log("bp_wardrobe_OnModeSwitched" .. gamestatus);
	if string.lower(gamestatus) == "lobby" then
		WardrobeUI:Init();
		WardrobeSystem.hasGunSkinList = false;
    else
    	if string.lower(gamestatus) == "login" then-- 保证每次小退重登时会请求数据
    		WardrobeUI.LAST_REQ_MALL_TIME = 0;
    	end
        WardrobeUI.isShowing = false;
        WardrobeUI.saveIsShowing = false;
	end
end

function WardrobeUI.GetWardrobeTabType(tabString)
	return WardrobeUI.tabStringToType[tabString];
end

function WardrobeEventHandler(eventType, eventID, vars)
    --log("WardrobeEventHandler:" .. eventID);
	
    if eventID == EVENTID_DATAMGR_GOLD_CHANGE then
		if LuaClassObj and WardrobeUI.isShowing then
			WardrobeUI.UpdateGoldStr(true);
		end
	elseif eventID == EVENTID_DATAMGR_HALL_DEPOT_ADD_NEW then
		--WardrobeUI.needShowRedPoint = true;
		--log_tree("vars", vars);
		local itemCfg = {};
		for k,v in pairs(vars) do		
			itemCfg = Client.GetTableData("Item", v.res_id);
			if itemCfg then
				-- 更新仓库页签红点			
				if itemCfg.WardrobeMainTab == BP_ENUM_WardrobePageType_Avatar then
					local tabType = WardrobeUI.tabStringToType[itemCfg.WardrobeTab]
					if tabType ~= nil then
						-- 时装
						WardrobeUI:UpdatePanelRedPoint(true, BP_ENUM_WardrobePageType_Avatar, tabType);
					end
				elseif itemCfg.WardrobeMainTab == BP_ENUM_WardrobePageType_Parachute then
					local tabType = WardrobeUI.tabStringToType[itemCfg.WardrobeTab]
					if tabType ~= nil then
						-- 物品
						WardrobeUI:UpdatePanelRedPoint(true, BP_ENUM_WardrobePageType_Parachute, tabType);
					end
				elseif itemCfg.WardrobeMainTab == BP_ENUM_WardrobePageType_Tools then
					-- 道具
					local item = DataMgr.GetHallDepotItemCountByResID(itemCfg.ItemID)
					if item == nil or item == 0 then
						WardrobeUI:UpdatePanelRedPoint(false, BP_ENUM_WardrobePageType_Tools, 6);
					else
						WardrobeUI:UpdatePanelRedPoint(true, BP_ENUM_WardrobePageType_Tools, 6);
					end
					-- 当前物品是道具时，刷新面板
					if WardrobeUI.isShowing and BP_CurPageTabType == BP_ENUM_WardrobePageType_Tools then
						WardrobeUI.UpdateItemList();
					end
				elseif itemCfg.WardrobeMainTab == BP_ENUM_WardrobePageType_Gun then
					-- 枪械小红点
					if itemCfg.WardrobeTab == BP_ENUM_wardrobeTabString_gun then
						WardrobeSystem.AddGunHotDotBySkin(itemCfg.ItemID);
					end
				elseif itemCfg.WardrobeMainTab == BP_ENUM_WardrobePageType_Vehicle then
					local tabType = WardrobeUI.tabStringToType[itemCfg.WardrobeTab]
					if tabType ~= nil then
						--表情相关 载具皮肤红点
						WardrobeUI:UpdatePanelRedPoint(true, BP_ENUM_WardrobePageType_Vehicle, tabType);
					end
				end
			end
		end		
	elseif eventID == EVENTID_BACKLOGIN then
		-- 清理数据
		WardrobeSystem.skinHotDotMap = {};
		WardrobeUI.redPointTabType = {};
        WardrobeUI:Hide();
    end
end


function WardrobeUI:Init()
	--log("WardrobeUI Init");
    EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_GOLD_CHANGE, WardrobeEventHandler);	
    EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_ADD_NEW, WardrobeEventHandler);	
    EventSystem:registEvent(EVENTTYPE_LOGIN, EVENTID_BACKLOGIN, WardrobeEventHandler);	
    EventSystem:registEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN, WardrobeUI.WardRobeAvatarResetOpen);
    EventSystem:registEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE, WardrobeUI.WardRobeAvatarResetClose);
    EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_DIAMOND_CHANGE, WardrobeUI.OnDiamondUpdate);
    EventSystem:registEvent(EVENTTYPE_MOTION, EVENTID_MOTION_UPDATE_SLOT_LIST, WardrobeSystem.RefreshEmojSlotsUI);
    --EventSystem:registEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_ITEM_DECOMPOSE, WardrobeUI.OnDecomposeItemInfoRsp);
	EventSystem:registEvent(EVENTTYPE_ITEM_UPGRADE, EVENTID_ITEM_UPGRADE_RED_POINT_DATA_CHANGE, WardrobeUI.OnRedPointInfoUpdate);
	EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_AVATAR_ACTIVATE, WardrobeUI.RefreshResetAvatarRedPoint);
	EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_GOLD_CHIP_CHANGE, WardrobeUI.OnGoldChipUpdate);
	EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_UPDATE_NEWBIE_STATUS, WardrobeUI.OnUpdateNewbieStatus);

end

function WardrobeUI:Release()
    --log("WardrobeUI Release");
	EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_GOLD_CHANGE, WardrobeEventHandler);
    EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_ADD_NEW, WardrobeEventHandler);	
    EventSystem:unregistEvent(EVENTTYPE_LOGIN, EVENTID_BACKLOGIN, WardrobeEventHandler);	
	EventSystem:unregistEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN, WardrobeUI.WardRobeAvatarResetOpen);
	EventSystem:unregistEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE, WardrobeUI.WardRobeAvatarResetClose);
	EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_DIAMOND_CHANGE, WardrobeUI.OnDiamondUpdate);
    EventSystem:unregistEvent(EVENTTYPE_MOTION, EVENTID_MOTION_UPDATE_SLOT_LIST, WardrobeSystem.RefreshEmojSlotsUI);
    --EventSystem:unregistEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_ITEM_DECOMPOSE, WardrobeUI.OnDecomposeItemInfoRsp);
	EventSystem:unregistEvent(EVENTTYPE_ITEM_UPGRADE, EVENTID_ITEM_UPGRADE_RED_POINT_DATA_CHANGE, WardrobeUI.OnRedPointInfoUpdate);
	EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_AVATAR_ACTIVATE, WardrobeUI.RefreshResetAvatarRedPoint);
	EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_GOLD_CHIP_CHANGE, WardrobeUI.OnGoldChipUpdate);
	EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_UPDATE_NEWBIE_STATUS, WardrobeUI.OnUpdateNewbieStatus);
	WardrobeUI.isShowing = false;
	SubItemsCreated = false;
end


function WardrobeUI:WardRobeAvatarResetOpen()
    --log("WardrobeUI.WardRobeAvatarResetOpen")
    WardrobeUI.saveIsShowing = WardrobeUI.isShowing;
    WardrobeUI.isShowing = false;
    LuaClassObj.HandleUIMessage(bp_wardrobe, "UIHideNative");
    EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_CLOSE);
end

function WardrobeUI:WardRobeAvatarResetClose()
    --log("WardrobeUI.WardRobeAvatarResetClose")
    
    if WardrobeUI.saveIsShowing then
        -- 恢复实际未穿戴
        for k,v in pairs(WardrobeUI.currentWearPreviewMap) do
            if k ~= wardrobeSubType_Parachute then
                --log("WardrobeUI.RevertAvatar puton "..v.resID);
                LobbyUI:AvatarChange(LobbyUI:CreateAvatarChangeData(DataMgr.roleData.uid, v.resID, v.colorID, v.patternID), true);
            end
        end
    
    	WardrobeUI.isShowing = true;
    	LuaClassObj.HandleUIMessage(bp_wardrobe, "UIShowNative");
   end
end

function WardrobeUI.SetIsPlayingOutAnim(playing)
	WardrobeUI.isPlayingOutAnim = playing;
end

--仓库打开关闭动画是否在播放
function WardrobeUI.GetWardrobeIsPlayingOutAnim()
	return WardrobeUI.isPlayingOutAnim;
end

function WardrobeUI.RefreshPetRedPoint()
	local PlayerPrefsSystem = require("client.tools.playerprefs")
	local redPoint = PlayerPrefsSystem.LoadFileToTable(PlayerPrefsSystem.ePlayerPrefsType.ePetRedPoint, true)
	if redPoint == nil then
		BP_Wardrobe_Pet_RedPoint = true
	else
		BP_Wardrobe_Pet_RedPoint = redPoint.NeedShowPetRedPoint
	end

	LuaClassObj.HandleUIMessageNoFetch(bp_wardrobe, "RefreshPetRedPoint");

	redPoint = {}
	redPoint.NeedShowPetRedPoint = BP_Wardrobe_Pet_RedPoint

	PlayerPrefsSystem.SaveTableToFile(redPoint, PlayerPrefsSystem.ePlayerPrefsType.ePetRedPoint, true)

	WardrobeSystem.UpdateLobbyHotDot()
end

function EventRecordPetRedPoint()
	if BP_Wardrobe_Pet_RedPoint then
		BP_Wardrobe_Pet_RedPoint = false

		local redPoint = {}
		redPoint.NeedShowPetRedPoint = false

		local PlayerPrefsSystem = require("client.tools.playerprefs")
		PlayerPrefsSystem.SaveTableToFile(redPoint, PlayerPrefsSystem.ePlayerPrefsType.ePetRedPoint, true)
	end
end

-- 打开仓库面板
function WardrobeUI:Show(isjumptoitempage)
	--设置宠物开关
    BP_Wardrobe_IsPetShow = FuncUtil.GetPetSwitch()

	--宠物红点
	WardrobeUI.RefreshPetRedPoint()

	local curTime = FuncUtil.GetServerTimeInSec()

	-- 每隔5分钟重新请求一次商店简约数据
	if curTime - WardrobeUI.LAST_REQ_MALL_TIME > 300 then
		MallSystem.GetMallAllItemsSimpleInfo()
		WardrobeUI.LAST_REQ_MALL_TIME = curTime
	end
	
	if WardrobeUI.isShowing or WardrobeUI.isPlayingOutAnim then
		return;
	end
	TeamUPFriendUI.WardRobeAvatarResetOpen();
	LobbyChatEntranceUI.ForceSetVisibility(false);
	ExpressionUI.WardRobeAvatarResetOpen();
	--log("WardrobeUI Show");
	WardrobeUI.isShowing = true;

	-- 脱下avata过时时装
	WardrobeUI.PutOffTimeOutWear();

	WardrobeUI.RevertAvatar();
	-- 默认时装页签
	BP_CurTabType = 0;
	BP_CurPageTabType = BP_ENUM_WardrobePageType_Avatar;
	BP_RolewearTabIndex = DataMgr.use_rolewear or 1;
	WardrobeUI.isUnlockingRolewear = false
	WardrobeUI.InitEquipmentLevel()

	BP_CurrnetTimeStamp = FuncUtil.GetServerTimeInSec() - WardrobeUI.timeOffset;
	BP_ARRAY_RolewearState = {0, 0, 0, 0};
	for i = 1, #BP_ARRAY_RolewearState do  
        if DataMgr.rolewear_state[i] ~= nil then
        	BP_ARRAY_RolewearState[i] = DataMgr.rolewear_state[i];

        	if BP_ARRAY_RolewearState[i] > WardrobeUI.timeOffset then 
        		BP_ARRAY_RolewearState[i] = BP_ARRAY_RolewearState[i] - WardrobeUI.timeOffset;
        	end
        end
    end

    --log_tree("BP_ARRAY_RolewearUnlockType ", BP_ARRAY_RolewearUnlockType);

	-- 页签开关
	local switchInfo = LobbySystem.LobbyMenuOpenStatus[BP_ENUM_WARDROBE_UI_WEAPON];
	if switchInfo ~= nil then
		BP_Wardrobe_GunTab_Toogle = switchInfo.is_open == 1
	else
		BP_Wardrobe_GunTab_Toogle = false;
	end

	WardrobeUI.UpdateGoldStr(false);
	WardrobeUI.UpdateDiamondStr(false);
	WardrobeUI.UpdateGoldChipStr(false);
	-- 打开面板
	-- 更新tabIcon
	
	WardrobeUI.InitCurrentWearPreviewMap();

    LuaClassObj.HandleUIMessageNoFetch(bp_wardrobe, "UIShow");


    --log_tree("BP_ARRAY_RolewearState ", BP_ARRAY_RolewearState);

    BP_ARRAY_RolewearUnlockType = {0, 0, 0, 0};
    for i = 2, #BP_ARRAY_RolewearUnlockType do
        local unlockType = Client.GetTableData("UnlockTypeConfig", tostring(i - 1)).unlockType;
        if unlockType ~= nil then
            BP_ARRAY_RolewearUnlockType[i] = unlockType;
            if not DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_WARDROBE, 2) then
                if unlockType == 3 and BP_ARRAY_RolewearState[i] == -3 then --RP背包可以开启
                    WardrobeUI.ShowRolewearRPPopup()
                end
            end

        end
    end

	--log_tree("WardrobeUI:Show WardrobeUI.currentWearPreviewMap", WardrobeUI.currentWearPreviewMap);
		
    --LuaClassObj.HandleUIMessage(bp_lobby, "SwitchCamera_OpenMenu");
    LobbyUI:SwitchToTeamorMenuCamera(true)
	TeamUpUI.OnCameraSwitch();
	WardrobeUI.RefreshOtherRedPoint();
    EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_OPEN);
    WardrobeUI.UpdateItemUpgradeView();
	WardrobeUI.RefreshResetAvatarRedPoint();

	TeamAvatarManager.EnablePutonEvent(tostring(DataMgr.roleData.uid), true)

	if isjumptoitempage then
		LuaClassObj.HandleUIMessageNoFetch(bp_wardrobe, "JumpToItemPage");
	end
	EventSystem:registEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_ITEM_DECOMPOSE, WardrobeUI.OnDecomposeItemInfoRsp);


end

-- 背包引导，优先级低于语音包
function EventCheckShowNewbieGuide()
	--print("** check pack", UnknowPassSystem.Season > 2)
	WardrobeUI.isShowNewBee = false
	log("EventCheckShowNewbieGuide")
    local bUIAutoTest = Client.IsUIAutoTest();
	if DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_WARDROBE, 2) and UnknowPassSystem.Season > 2 and 
			not DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_WARDROBE, 3) and not bUIAutoTest
	then
		WardrobeUI.isShowNewBee = true
    	LuaClassObj.HandleUIMessage(bp_wardrobe, "ShowNewbieTips");
    end
end

function EventHideWardrobeNewbieTips()
	DataMgr.SetNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_WARDROBE, 2)
	WardrobeUI.ShowRolewearRPPopup();
end


function EventShowRolewearBuyUI()
	WardrobeUI.isUnlockingRolewear = false;
	local unlockConfigListStr = "";
	if BP_RolewearTabIndex == 2 then
		unlockConfigListStr = Client.GetTableData("UnlockTypeConfig", tostring(WardrobeUI.RolewearIndexTwoUnlockConfigID)).params;
	elseif BP_RolewearTabIndex == 3 then
		unlockConfigListStr = Client.GetTableData("UnlockTypeConfig", tostring(WardrobeUI.RolewearIndexThreeUnlockConfigID)).params;
	elseif BP_RolewearTabIndex == 4 then
		unlockConfigListStr = Client.GetTableData("UnlockTypeConfig", tostring(WardrobeUI.RolewearIndexFourUnlockConfigID)).params;
	end
	
	local unlockConfigList = string.split(unlockConfigListStr, ";");

	--log_tree("EventShowRolewearBuyUI unlockConfigList:",unlockConfigList);
			
	BP_ARRAY_RolewearUnlockCostInfo = {};
	
	for k,v in pairs(unlockConfigList) do
		local unlockCost = Client.GetTableData("UnlockCostConfig", v);	
		local rolewearUnlockCostInfo = {};
		table.insert(BP_ARRAY_RolewearUnlockCostInfo,
		{
			ID = unlockCost.ID,
			time = unlockCost.time,
			uc_cost = unlockCost.ucCost,
			bp_cost = unlockCost.bpCost,
		});
	end

	BP_CurrnetTimeStamp = FuncUtil.GetServerTimeInSec() - WardrobeUI.timeOffset;

	LuaClassObj.HandleUIMessage(bp_wardrobe, "ShowRolewearBuyUI");
end

function EventShowRolewearRPUnlockTips()
	WardrobeUI.ShowRolewearRPPopup();
end

function EventShowRolewearHelp()
	PopUpNoticeUI.ShowMessageBox(Client.GetTableData("LocalizeRes", "4731").TextValue,Client.GetTableData("LocalizeRes", "4796").TextValue);
end

function EventUnlockRolewearIndex()
	--log("EventUnlockRolewearIndex BP_RolewearUnlockConfigID:"..BP_RolewearUnlockConfigID.." BP_RolewearTabIndex:"..BP_RolewearTabIndex);
	if BP_ARRAY_RolewearState[BP_RolewearTabIndex] ~= nil then

		WardrobeSystem.unlock_rolewear_req(BP_RolewearTabIndex, BP_RolewearUnlockConfigID);
	end
end

function WardrobeUI.OnRolewearUnlocked(index, change_idx, timestamp)
	if timestamp > FuncUtil.GetServerTimeInSec() or timestamp == -2 then
		if DataMgr.rolewear_array[index] == nil then
			DataMgr.rolewear_array[index] = {};
		end

		BP_UnlockedRolewearTabIndex = index;

		if BP_ARRAY_RolewearState[index] ~= nil then

			DataMgr.rolewear_state[index] = timestamp;
			BP_ARRAY_RolewearState[index] = timestamp;

			if BP_ARRAY_RolewearState[index] > WardrobeUI.timeOffset then 
        		BP_ARRAY_RolewearState[index] = BP_ARRAY_RolewearState[index] - WardrobeUI.timeOffset;
        	end

			BP_CurrnetTimeStamp = FuncUtil.GetServerTimeInSec() - WardrobeUI.timeOffset;

			if WardrobeUI.isUnlockingRolewear == false then
				DataMgr.ShowNoticeByID("4789");
				LuaClassObj.HandleUIMessage(bp_wardrobe, "RefreshRolewearTabState");	
			else
				LuaClassObj.HandleUIMessage(bp_wardrobe, "OnRolewearUnlocked");	
			end
			WardrobeUI.isUnlockingRolewear = false;
		end
	else
		log("WardrobeUI.OnRolewearUnlocked invalid timestamp")
	end
end

function EventSelectRolewearIndex()
	WardrobeUI.isUnlockingRolewear = false;
	if BP_ARRAY_RolewearState[BP_RolewearTabIndex] ~= nil then
		if BP_ARRAY_RolewearState[BP_RolewearTabIndex] == -2 or BP_ARRAY_RolewearState[BP_RolewearTabIndex] > 0 then
			-- 已开启，请求更换页签
			WardrobeSystem.select_use_rolewear_req(BP_RolewearTabIndex);

		elseif BP_ARRAY_RolewearState[BP_RolewearTabIndex] == -1 then --可以购买开启	
			EventShowRolewearBuyUI();
			WardrobeUI.isUnlockingRolewear = true;
		elseif BP_ARRAY_RolewearState[BP_RolewearTabIndex] == -3 then  --RP满足条件可以开启
			WardrobeUI.isUnlockingRolewear = true;
 			WardrobeSystem.unlock_rolewear_req(BP_RolewearTabIndex);
		elseif BP_ARRAY_RolewearState[BP_RolewearTabIndex] == 0 and BP_RolewearTabIndex == 4 and UnknowPassSystem.Season > 2 then 
			local unlockType = BP_ARRAY_RolewearUnlockType[BP_RolewearTabIndex];
			if unlockType == 3 then --依赖RP物品解锁
				WardrobeUI.ShowRolewearRPPopup();
			end
			
		else
			DataMgr.ShowNoticeByID("116009");	
		end
	else
		DataMgr.ShowNoticeByID("116009");
	end
	--log("Current Timestamp "..FuncUtil.GetServerTimeInSec())
end

function WardrobeUI.ShowRolewearRPPopup()
	BP_RolewearRPPopupType = -1;
	local state = BP_ARRAY_RolewearState[4];
	if state ~= nil then
		if state == 0 then 
			BP_RolewearRPPopupType = 0;
		elseif state == -3 then
			WardrobeUI.isUnlockingRolewear = true;
			BP_RolewearRPPopupType = 1;
		elseif state == -2 then
			BP_RolewearRPPopupType = 2;
		end
	end

	if BP_RolewearRPPopupType >= 0 then
		LuaClassObj.HandleUIMessage(bp_wardrobe, "ShowRolewearRPPopupUI");
	else
		log("WardrobeUI.ShowRolewearRPPopup BP_RolewearRPPopupType is invalid");
	end
end

function EventWardrobeGotoRPPanel()
	LobbyUI.EnterUnknowPass();
end

function EventUnlockRPRolewear()
	WardrobeSystem.unlock_rolewear_req(4);
end

function WardrobeUI.OnSelectUseRolewearSuccess(index)
	BP_RolewearTabIndex = index;
	DataMgr.use_rolewear = index;
	--log("WardrobeUI.OnSelectUseRolewearSuccess index:"..index);

	HallThemeUtils.ProcSwitchUseWearBag(index)

	local str = DataMgr.GetMsgByID(4769);
	local showTip = "";
	if index == 4 then
		showTip = string.format(str, "RP");
	else
		showTip = string.format(str, tonumber(index));
	end

	--弹出提示，背包切换成功
	DataMgr.ShowNoticeByString(showTip);

	LuaClassObj.HandleUIMessage(bp_wardrobe, "RefreshRolewearTabState");
	
	--重置PreviewMap之前必须先脱下当前的
	for k,v in pairs(WardrobeUI.currentWearPreviewMap) do
		if math.floor(k / 100) == 4 then
			LobbyUI:AvatarChange(LobbyUI:CreateAvatarChangeData(DataMgr.roleData.uid, v.resID), false);
		end
	end
	
	WardrobeUI.InitCurrentWearPreviewMap();

	-- 脱下实际未穿戴
	for k,v in pairs(WardrobeUI.currentWearPreviewMap) do
		if math.floor(k / 100) == 4 then
			LobbyUI:AvatarChange(LobbyUI:CreateAvatarChangeData(DataMgr.roleData.uid, v.resID), false);
		end
	end

	DataMgr.rolewear = DataMgr.GetRolewearByIndex(BP_RolewearTabIndex);

	--log("WardrobeUI.OnSelectUseRolewearSuccess BP_RolewearTabIndex:"..BP_RolewearTabIndex);

	WardrobeUI.InitCurrentWearPreviewMap();

	-- 换上新的穿戴
	for k,v in pairs(WardrobeUI.currentWearPreviewMap) do
		if math.floor(k / 100) == 4  then
			LobbyUI:AvatarChange(LobbyUI:CreateAvatarChangeData(DataMgr.roleData.uid, v.resID, v.colorID, v.patternID), true);
			if(k == WardrobeUI.wardrobeSubType_Hat) then
				WardrobeSystem.depot_set_head_show_req(v.insID);
			end
		end
	end

	EventChangeWardrodbeTab();

end

function WardrobeUI.OnRolewearStateUpdated(rolewear_state, rolewear, use_rolewear)
	DataMgr.rolewear_state = rolewear_state;
	DataMgr.rolewear_array = rolewear;
	

	BP_ARRAY_RolewearState = {0, 0, 0, 0};
	for i = 1, #BP_ARRAY_RolewearState do  
        if DataMgr.rolewear_state[i] ~= nil then
        	BP_ARRAY_RolewearState[i] = DataMgr.rolewear_state[i];

        	if BP_ARRAY_RolewearState[i] > WardrobeUI.timeOffset then 
        		BP_ARRAY_RolewearState[i] = BP_ARRAY_RolewearState[i] - WardrobeUI.timeOffset;
        	end
        end
    end

    if DataMgr.use_rolewear == use_rolewear then
		BP_RolewearTabIndex = use_rolewear
    	LuaClassObj.HandleUIMessage(bp_wardrobe, "RefreshRolewearTabState");	
    else
    	DataMgr.use_rolewear = use_rolewear;
		BP_RolewearTabIndex = DataMgr.use_rolewear or 1;
		DataMgr.rolewear = DataMgr.GetRolewearByIndex(DataMgr.use_rolewear);
    	WardrobeUI.OnSelectUseRolewearSuccess(use_rolewear)
    end
end

function WardrobeUI.InitCurrentWearPreviewMap()
	------------------- 请对比SVN提交记录，旧的初始化方式遍历太多次arrayHallDepotItemInfo，好坑的设计---------------------------
	------------------- 仓库是一个很大的Table，先使用下面的方式只遍历一次，类似的代码应该有很多，有待优化--------------------
	WardrobeUI.currentWearPreviewMap = {}
	for k, itemData in pairs(DataMgr.arrayHallDepotItemInfo) do
		-- 衣服
		if (DataMgr.rolewear ~= nil) then
			if FuncUtil.Find(DataMgr.rolewear, itemData.insID) >= 0 then
				WardrobeUI.AddToWearInfo(itemData.itemSubType, itemData.insID, itemData.resID, itemData.colorID, itemData.patternID);	-- 添加到穿戴信息
			end
		end

		-- 降落伞
		if DataMgr.parachute == itemData.insID then
			WardrobeUI.AddToWearInfo(itemData.itemSubType, itemData.insID, itemData.resID, 0, 0);	-- 添加到穿戴信息
		end

		-- 飞机
		if DataMgr.planeSkinInsID == itemData.insID then
			WardrobeUI.AddToWearInfo(itemData.itemSubType, itemData.insID, itemData.resID, 0, 0);	-- 添加到穿戴信息
		end

		-- 背包/头盔/防弹衣
		if (DataMgr.equipmentSkinInsIDTable ~= nil) then
		 	if FuncUtil.Find(DataMgr.equipmentSkinInsIDTable, itemData.insID) >= 0 then
				local resID = WardrobeUI:GetEquipmentItemIDBySkinInsID(itemData.itemSubType, itemData.insID)
				WardrobeUI.AddToWearInfo(itemData.itemSubType, itemData.insID, resID);	-- 添加到穿戴信息
		 	end
		end

		-- 载具
		if (DataMgr.vehicleSkinInsIDTable ~= nil) then
			if FuncUtil.Find(DataMgr.vehicleSkinInsIDTable, itemData.insID) >= 0 then
				WardrobeUI.AddToWearInfo(itemData.itemSubType, itemData.insID, itemData.resID, 0, 0);	-- 添加到穿戴信息
			end
		end
	end
end

function WardrobeUI.PutOffTimeOutWear()
	local putOff = {}
	WardrobeSystem.UpdateInvalidWearInfo(putOff);

	local itemData;
	for i,v in ipairs(putOff) do
		itemData = DataMgr.GetHallDepotItemDataByInsID(v);
		WardrobeSystem.wardrobe_put_down_req(v, false);

		if itemData ~= nil then
			LobbyUI:AvatarChange(LobbyUI:CreateAvatarChangeData(DataMgr.roleData.uid, itemData.resID), false);
		end
	end

	if #putOff > 0 then
		WardrobeUI.UpdateAllTabIcon();
	end

	if DataMgr.Weapon_ID ~= 0 then
		itemData = DataMgr.GetHallDepotItemDataByInsID(DataMgr.Weapon_Skin_InsID)
		if itemData and not DataMgr.IsValidTime(itemData.expireTS) then
			WardrobeSystem.PutOnGunAvatar(DataMgr.Weapon_ID);
	    end
	end
end

function WardrobeUI.AddToWearInfo(itemSubType, itemInsID, itemResID, colorID, patternID)
	WardrobeUI.currentWearPreviewMap[itemSubType] = {insID = tostring(itemInsID), resID = itemResID, colorID = colorID or 0, patternID = patternID or 0}; -- 记录预览数据
end

function WardrobeUI.InitEquipmentLevel()
	BP_STRUCT_WardrobeEquipmentLevel.bag = DataMgr.bag_level;
	BP_STRUCT_WardrobeEquipmentLevel.helmet = DataMgr.helmet_level;
end

-- 关闭仓库面板
function WardrobeUI:Hide()
	if WardrobeUI.isShowing then
		EventShowSomeUIInWardrobeUI();
	    --log("WardrobeUI Hide");
	    LuaClassObj.HandleUIMessage(bp_wardrobe, "UIHide");
	    --LuaClassObj.HandleUIMessage(bp_lobby, "SwitchCamera_CloseMenu");
	    LobbyUI:SwitchToMainCamera(true)
		TeamUpUI.OnCameraSwitch();

		TeamAvatarManager.EnablePutonEvent(tostring(DataMgr.roleData.uid), false)
		EventSystem:unregistEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_ITEM_DECOMPOSE, WardrobeUI.OnDecomposeItemInfoRsp);
	end
end

function EventShowSomeUIInWardrobeUI()
	TeamUPFriendUI.WardRobeAvatarResetClose();

	-- 防止军团聊天显示
	if CorpsBaseUI.isShow == false then
		LobbyChatEntranceUI.ForceSetVisibility(true);
	end
	
	ExpressionUI.WardRobeAvatarResetClose();
end

function WardrobeUI.GetGoldNumStr(num)
	local result = ""
	if num >= 100000000 then
		result = FuncUtil.LocalizeResFormat("9910131",  math.floor(num / 10000));
	else
		result = tostring(num);
	end

	return result;
end

-- 更新仓库上的金币显示
function WardrobeUI.UpdateGoldStr(isRefresh)
	BP_WardrobeGold = WardrobeUI.GetGoldNumStr(DataMgr.gold)

	if isRefresh then
		LuaClassObj.HandleUIMessageNoFetch(bp_wardrobe, "UpdateGold");
	end
end

-- 更新仓库
function WardrobeUI:UpdatePutOnData(putOnItem, putDownItem)

	--log_tree("WardrobeUI:UpdatePutOnData putOnItem", putOnItem);
	if putOnItem ~= nil then
		local itemCfg = Client.GetTableData("Item", putOnItem.res_id);
		if itemCfg ~= nil then
			local wearInfo = WardrobeUI.currentWearPreviewMap[itemCfg.ItemSubType];
			-- log_tree("WardrobeUI:UpdatePutOnData "..itemCfg.ItemSubType, wearInfo);
			if wearInfo ~= nil then
				putDownItem = WardrobeUI.CreatePutOnInfo(tostring(wearInfo.insID), wearInfo.resID);
			end
		end
	end
	--log_tree("WardrobeUI:UpdatePutOnData putDownItem", putDownItem);

	if putDownItem then	
		local insID = tostring(putDownItem.instid);
		BP_STRUCT_WardrobeChangedItemData.ins_id = insID;
		BP_STRUCT_WardrobeChangedItemData.res_id = putDownItem.res_id;
		BP_STRUCT_WardrobeChangedItemData.count = putDownItem.count;
		BP_STRUCT_WardrobeChangedItemData.is_using = false;
		BP_STRUCT_WardrobeChangedItemData.is_selected = false;
		BP_STRUCT_WardrobeChangedItemData.is_new = false;
		BP_STRUCT_WardrobeChangedItemData.is_isolated = WardrobeSystem.IsItemIsolated( putDownItem.res_id );
		BP_STRUCT_WardrobeChangedItemData.color_id = putDownItem.color or 0;
		BP_STRUCT_WardrobeChangedItemData.pattern_id = putDownItem.pattern or 0;

		BP_STRUCT_WardrobeChangedItemData.use_count = WardrobeUI.GetUseCount(insID);

		local itemCfg = Client.GetTableData("Item", putDownItem.res_id);
		if itemCfg ~= nil then
			WardrobeUI.currentWearPreviewMap[itemCfg.ItemSubType] = nil;
		end
		
		-- log_tree("WardrobeUI:UpdatePutOnData BP_STRUCT_WardrobeChangedItemData1", BP_STRUCT_WardrobeChangedItemData);
		-- log_tree("WardrobeUI:UpdatePutOnData currentWearPreviewMap", WardrobeUI.currentWearPreviewMap);
		LuaClassObj.HandleUIMessageNoFetch(bp_wardrobe, "UpdateOneItem");
	end
	
	if putOnItem then		
		local insID = tostring(putOnItem.instid);
		BP_STRUCT_WardrobeChangedItemData.ins_id = insID;
		BP_STRUCT_WardrobeChangedItemData.res_id = putOnItem.res_id;
		BP_STRUCT_WardrobeChangedItemData.count = putOnItem.count;
		local insData = DataMgr.GetHallDepotItemDataByInsID(insID);
		if insData and insData.mainTabType == BP_ENUM_WardrobePageType_Vehicle then
			BP_STRUCT_WardrobeChangedItemData.is_using = false;
		else
			BP_STRUCT_WardrobeChangedItemData.is_using = true;
		end
		BP_STRUCT_WardrobeChangedItemData.is_selected = true;
		BP_STRUCT_WardrobeChangedItemData.is_new = false;
		BP_STRUCT_WardrobeChangedItemData.color_id = putOnItem.color or 0;
		BP_STRUCT_WardrobeChangedItemData.pattern_id = putOnItem.pattern or 0;

		BP_STRUCT_WardrobeChangedItemData.use_count = WardrobeUI.GetUseCount(insID);
		BP_STRUCT_WardrobeChangedItemData.is_isolated = WardrobeSystem.IsItemIsolated( putOnItem.res_id );


		-- log_tree("WardrobeUI:UpdatePutOnData putOnItem", BP_STRUCT_WardrobeChangedItemData);
		local itemCfg = Client.GetTableData("Item", putOnItem.res_id);

		if itemCfg then
			if putOnItem.instid ~= "" then
				WardrobeUI.UpdateAllTabIcon();
			end

			WardrobeUI.UpdateBG(itemCfg, insID ~= "");
		end

		if itemCfg ~= nil then
			WardrobeUI.AddToWearInfo(itemCfg.ItemSubType, putOnItem.instid, putOnItem.res_id, putOnItem.color, putOnItem.pattern);
		end
		
		-- log_tree("WardrobeUI:UpdatePutOnData BP_STRUCT_WardrobeChangedItemData2", BP_STRUCT_WardrobeChangedItemData);
		-- log_tree("WardrobeUI:UpdatePutOnData currentWearPreviewMap", WardrobeUI.currentWearPreviewMap);
		LuaClassObj.HandleUIMessageNoFetch(bp_wardrobe, "UpdateOneItem");
	end
end

function WardrobeUI.DoUpdateOneItem(itemData, count, isUsing, isSelected, isNew)
	itemData.count = count;
	itemData.is_using = isUsing;
	itemData.is_selected = isSelected;
	itemData.is_new = isNew;

	local insData = DataMgr.GetHallDepotItemDataByInsID(itemData.ins_id);
	if insData ~= nil then
		insData.isNew = isNew;

		BP_STRUCT_WardrobeChangedItemData.ins_id = itemData.ins_id;
		BP_STRUCT_WardrobeChangedItemData.res_id = itemData.res_id;
		BP_STRUCT_WardrobeChangedItemData.count = count;
		if insData.mainTabType == BP_ENUM_WardrobePageType_Tools or insData.mainTabType == BP_ENUM_WardrobePageType_Vehicle then
			BP_STRUCT_WardrobeChangedItemData.is_using = false;
		else
			BP_STRUCT_WardrobeChangedItemData.is_using = isUsing;
		end
		BP_STRUCT_WardrobeChangedItemData.is_selected = isSelected;
		BP_STRUCT_WardrobeChangedItemData.is_new = isNew;
		BP_STRUCT_WardrobeChangedItemData.is_isolated = WardrobeSystem.IsItemIsolated( itemData.res_id );
		BP_STRUCT_WardrobeChangedItemData.color_id = itemData.color_id or 0;
		BP_STRUCT_WardrobeChangedItemData.pattern_id = itemData.pattern_id or 0;
		BP_STRUCT_WardrobeChangedItemData.use_count = WardrobeUI.GetUseCount(itemData.ins_id);

		-- log_tree("WardrobeUI.DoUpdateOneItem BP_STRUCT_WardrobeChangedItemData", BP_STRUCT_WardrobeChangedItemData);
		LuaClassObj.HandleUIMessageNoFetch(bp_wardrobe, "UpdateOneItem");
	end
end

-- 更新仓库页穿脱表现
function WardrobeUI:UpdatePutDownData(putDownItem)
	if putDownItem then
		BP_STRUCT_WardrobeChangedItemData.ins_id = putDownItem.instid;
		BP_STRUCT_WardrobeChangedItemData.res_id = putDownItem.res_id;
		BP_STRUCT_WardrobeChangedItemData.count = putDownItem.count;
		
		BP_STRUCT_WardrobeChangedItemData.is_using = false;
		BP_STRUCT_WardrobeChangedItemData.is_selected = true;
		BP_STRUCT_WardrobeChangedItemData.is_new = false;
		BP_STRUCT_WardrobeChangedItemData.color_id = putDownItem.color_id or 0;
		BP_STRUCT_WardrobeChangedItemData.pattern_id = putDownItem.pattern_id or 0;

		BP_STRUCT_WardrobeChangedItemData.use_count = WardrobeUI.GetUseCount(putDownItem.instid);
		BP_STRUCT_WardrobeChangedItemData.is_isolated = WardrobeSystem.IsItemIsolated( putDownItem.res_id );

				
		local itemDataCfg = Client.GetTableData("Item", putDownItem.res_id);

		if itemDataCfg then
			WardrobeUI.currentWearPreviewMap[itemDataCfg.ItemSubType] = nil;
			WardrobeUI.UpdateAllTabIcon();
		end
		
		-- log_tree("WardrobeUI:UpdatePutDownData BP_STRUCT_WardrobeChangedItemData", BP_STRUCT_WardrobeChangedItemData);
		LuaClassObj.HandleUIMessageNoFetch(bp_wardrobe, "UpdateOneItem");
	end		
end

-- 移除大页签下的小红点
function WardrobeUI.RemovePageRedPoint(lastPage, curPage)
	if lastPage == curPage then
		return;
	end

	local v = nil;
	for i=1,#WardrobeUI.redPointTabType do
		v = WardrobeUI.redPointTabType[i];
		if v and v.pageType == lastPage then
			table.remove(WardrobeUI.redPointTabType, i);
		end
	end
end

-- 移除当前不需要显示小红点的页签
function WardrobeUI.UpdatePanelRedPointCommon(isShow, pageType, tabType)
	if pageType ~= -1 and tabType ~= -1 then
		--log("WardrobeUI.UpdatePanelRedPointCommon "..tostring(isShow)..", "..pageType..", "..tabType);
		-- log_tree("WardrobeUI:UpdatePanelRedPoint WardrobeUI.redPointTabType", WardrobeUI.redPointTabType);

		-- 查找小红点所在下标
		local curIndex = -1;
		for i,v in ipairs(WardrobeUI.redPointTabType) do
			if v.pageType == pageType and v.tabType == tabType then
				curIndex = i;
				break;
			end
		end

		-- 根据添加或移除逻辑处理
		if isShow then
			if curIndex == -1 then
				WardrobeUI.ShowRedPoint(pageType, tabType);
			end
		else
			if curIndex ~= -1 then
				table.remove(WardrobeUI.redPointTabType, curIndex);
			end
		end
	end

	-- 更新大厅小红点
	if pageType == BP_ENUM_WardrobePageType_Gun and tabType == WardrobeUI.wardrobeTabType_gun then
		WardrobeSystem.ShowLobbyHotDot(isShow)
	else
		WardrobeSystem.UpdateLobbyHotDot();
	end

	WardrobeUI.RefreshRedPoint()
end

function WardrobeUI:UpdatePanelRedPoint(isShow, pageType, tabType)
	if pageType == BP_ENUM_WardrobePageType_Gun and tabType == WardrobeUI.wardrobeTabType_gun then
		return;
	end

	WardrobeUI.UpdatePanelRedPointCommon(isShow, pageType, tabType)
end

function WardrobeUI.UpdatePanelRedPointForGun(isShow)
	log("WardrobeUI.UpdatePanelRedPointForGun isShow "..tostring(isShow));
	WardrobeUI.UpdatePanelRedPointCommon(isShow, BP_ENUM_WardrobePageType_Gun, WardrobeUI.wardrobeTabType_gun)
end

function WardrobeUI.RefreshRedPoint()
	if not WardrobeUI.isShowing then
		return;
	end

    -- 标记各级页签掩码
	WardrobeUI.UpdatePageTabRedPointMask(BP_CurPageTabType);
	-- log_tree("WardrobeUI:RefreshRedPoint redPoint", WardrobeUI.redPointTabType);
	-- log_tree("WardrobeUI:RefreshRedPoint BP_ARRAY_Wardrobe_PageRedPoint ", BP_ARRAY_Wardrobe_PageRedPoint);
	-- log_tree("WardrobeUI:RefreshRedPoint BP_ARRAY_Wardrobe_TabRedPoint ", BP_ARRAY_Wardrobe_TabRedPoint);

	if BP_CurPageTabType ~= BP_ENUM_WardrobePageType_Gun then
		if WardrobeUI.isShowing then
			LuaClassObj.HandleUIMessageNoFetch(bp_wardrobe, "UpdateAllRedPoint");
		end
	else
		if WardrobeUI.isShowing then
			LuaClassObj.HandleUIMessageNoFetch(bp_wardrobe, "UpdateGunListRedPoint");
		end
	end
end

function WardrobeUI.RefreshOtherRedPoint()
	-- if not WardrobeUI.isShowing then
	-- 	return;
	-- end
	-- 更新研究所入口红点
	BP_Wardrobe_ItemUpgrade_Entrace_RedPoint = ItemUpgradeSystem.NeedShowRedPoint();
	LuaClassObj.HandleUIMessageNoFetch(bp_wardrobe, "UpdateOtherRedPoint");
end

function WardrobeUI.IsValidTime(serverTime, itemTime)
	return itemTime == 0 or itemTime == nil or itemTime > serverTime;
end

function WardrobeUI.RemoveCurTabInvalidRedPoint()
	local isListEmpty = true;
	local serverTime = FuncUtil.GetServerTimeInSec();
	for i,v in ipairs(BP_ARRAY_WardrobeItemList) do
		if v ~= nil and v.count > 0 and WardrobeUI.IsValidTime(serverTime, v.expireTS) then
			isListEmpty = false;
			break;
		end
	end

	log("WardrobeUI.RemoveCurTabInvalidRedPoint isListEmpty "..tostring(isListEmpty));
	if isListEmpty then
		WardrobeUI:UpdatePanelRedPoint(false, BP_CurPageTabType, BP_CurTabType);
	end
end

function WardrobeUI.UpdatePageTabRedPointMask(curPage)
	log("WardrobeUI.UpdatePageTabRedPointMask curPage = "..curPage);
	BP_ARRAY_Wardrobe_PageRedPoint = {}

	-- 这里区分一下枪的小红点
	if curPage ~= BP_ENUM_WardrobePageType_Gun then
		BP_ARRAY_Wardrobe_TabRedPoint = {};
		for i,v in ipairs(WardrobeUI.redPointTabType) do
			table.insert(BP_ARRAY_Wardrobe_PageRedPoint, v.pageType)

			if v.pageType == curPage then
				table.insert(BP_ARRAY_Wardrobe_TabRedPoint, v.tabType)
			end
		end
	else
		for i,v in ipairs(WardrobeUI.redPointTabType) do
			table.insert(BP_ARRAY_Wardrobe_PageRedPoint, v.pageType)
		end

		WardrobeSystem.UpdateGunListRedPoint();
	end
end

function WardrobeUI.ShowRedPoint(pageType, tabType)
	log("WardrobeUI.ShowRedPoint pageType = "..pageType.." 		tabType = "..tabType);
	table.insert(WardrobeUI.redPointTabType, {pageType = pageType, tabType = tabType});
end

-- 判断是否需要触发快捷消息引导
function WardrobeUI.CheckNeedQuickMsgGuide(CheckQuickMsgGuide)
	log("CheckNeedQuickMsgGuide")
	WardrobeUI.isShowVoiceGuild = false
	local bUIAutoTest = Client.IsUIAutoTest();
	if CheckQuickMsgGuide and not bUIAutoTest then
		local newbie = DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_WARDROBE, 3);
		if newbie then
			WardrobeUI.isShowVoiceGuild = true
			WardrobeUI.StartQuickMsgGuide(1)
		end
	end
end

local function ShowMask(Mask)
	Mask:SetVisibility(UEnums.ESlateVisibility.Visible)
end

local function HideMask(Mask)
	Mask:SetVisibility(UEnums.ESlateVisibility.Collapsed)
end

-- 12.0 Show QuickMsgGuide (switch by clicking on the mask which is used to darken background)
function WardrobeUI.StartQuickMsgGuide(step)
	print("StartQuickMsgGuide", step)
	local Mask
	local Wardrobe = UIUtil.GetWidgetByName("bp_wardrobe", "Wardrobe_BP")
	if step <= 2 then
		Mask  = Wardrobe.Wardrobe_UIBP.Button_ItemUpgrade_GuideMask
	else
		Mask = quickMessageWindow.UIRoot.Button_GuideMask
	end
	if step == 1 then
		Wardrobe.Wardrobe_UIBP.CKNewbieTips:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
		Wardrobe.Wardrobe_UIBP.CKNewbieTips1:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
	elseif step == 2 then
		Wardrobe.Wardrobe_UIBP.CKNewbieTips:SetVisibility(UEnums.ESlateVisibility.Collapsed)
		Wardrobe.Wardrobe_UIBP.CKNewbieTips1:SetVisibility(UEnums.ESlateVisibility.Collapsed)
		Wardrobe.Wardrobe_UIBP.CKNewbieTips2:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
	elseif step == 3 then
		Wardrobe.Wardrobe_UIBP.CKNewbieTips2:SetVisibility(UEnums.ESlateVisibility.Collapsed)
		quickMessageWindow.UIRoot.RouletteNewbieTips:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
		quickMessageWindow.UIRoot.Button_GuideMask:SetVisibility(UEnums.ESlateVisibility.Visible)
	elseif step == 4 then
		quickMessageWindow.UIRoot.RouletteNewbieTips:SetVisibility(UEnums.ESlateVisibility.Collapsed)
		DataMgr.SetNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_WARDROBE, 3);
		return
	else
		quickMessageWindow.UIRoot.RouletteDragNewbieTips:SetVisibility(UEnums.ESlateVisibility.Collapsed)
	end
	ShowMask(Mask)
	Mask.OnClicked:Clear()
	Mask.OnClicked:Add(function()
		HideMask(Mask)
		ExecuteQuickMsgGuideOperation(step)
		WardrobeUI.StartQuickMsgGuide(step+1)
	end)
end

-- Specify and execute corresponding BluePrint function during each step of QuickMsgGuide
function ExecuteQuickMsgGuideOperation(step)
	local functionList =
	{
		"OnClickDropDown", -- 打开战备页面
		"OpenQuickMsgPanel",  -- 打开快捷消息页面
		"NotExistFunction",   -- 第三步无需执行蓝图函数
		"OnClickClose", 	  -- 关闭仓库
	}
	if step <= 2 then
		LuaClassObj.HandleUIMessageNoFetch(bp_wardrobe, functionList[step])
	end
end

function WardrobeUI.OnUpdateNewbieStatus()
	log("WardrobeUI.OnUpdateNewbieStatus");
	local newbie = DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_WARDROBE, 3)
	local LobbyLogic = UIUtil.GetWidgetByName("bp_lobby", "Lobby_Logic_BP")
	if newbie then
		--print("** Show tips above Wardrobe button")
		LobbyLogic.Lobby_BP.WardroNewbieTips:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible);
	else
		--print("** Hide tips above Wardrobe button")
		LobbyLogic.Lobby_BP.WardroNewbieTips:SetVisibility(UEnums.ESlateVisibility.Collapsed);
	end
end

function WardrobeUI.CheckNeedItemUpgradeGuide(checkItemUpgradeGuide)
	-- UI自动化测试不触发引导
	if checkItemUpgradeGuide then
		local bUIAutoTest = Client.IsUIAutoTest();

		if LobbyUI:CheckLobbyMenuOpen(BP_ENUM_ITEM_UPGRADE, false) == false or bUIAutoTest then
			BP_Wardrobe_Item_Upgrade_IsShow_Mask = false;
		else
			if DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_ITEM_UPGRADE, 1) == true then
				BP_Wardrobe_Item_Upgrade_IsShow_Mask = true;
				ItemUpgradeUI.StartGuide();
			end
		end
	end
	LuaClassObj.HandleUIMessageNoFetch(bp_wardrobe, "UpdateItemUpgradeGuideView");
end

-- 更新物品售卖返回的物品刷新
function WardrobeUI:UpdateItemData(itemData)
	if WardrobeUI.isShowing and itemData then
		local insID = tostring(itemData.instid);
		local isCurrentSelected = insID == BP_STRUCT_WardrobeClickedItemData.ins_id and itemData.res_id == BP_STRUCT_WardrobeClickedItemData.res_id;
		local insData = DataMgr.GetHallDepotItemDataByInsID(itemData.ins_id);
		if insData ~= nil then
			if insData.mainTabType == BP_ENUM_WardrobePageType_Tools then
				BP_STRUCT_WardrobeChangedItemData.is_using = false;
			else
				BP_STRUCT_WardrobeChangedItemData.is_using = isCurrentSelected;
			end
		end
		BP_STRUCT_WardrobeChangedItemData.ins_id = insID;
		BP_STRUCT_WardrobeChangedItemData.res_id = itemData.res_id;
		BP_STRUCT_WardrobeChangedItemData.is_new = (itemData.isnew == 1);
		BP_STRUCT_WardrobeChangedItemData.count = itemData.count;
		BP_STRUCT_WardrobeChangedItemData.is_selected = isCurrentSelected;
		BP_STRUCT_WardrobeChangedItemData.is_isolated = WardrobeSystem.IsItemIsolated( itemData.res_id );
		BP_STRUCT_WardrobeChangedItemData.color_id = itemData.color_id or 0;
		BP_STRUCT_WardrobeChangedItemData.pattern_id = itemData.pattern_id or 0;

		if BP_CurPageTabType == BP_ENUM_WardrobePageType_Avatar then
			if itemData.count == 0 then
				local itemDataCfg = Client.GetTableData("Item", itemData.res_id);
				if itemDataCfg then
					if itemDataCfg.WardrobeMainTab == BP_ENUM_WardrobePageType_Avatar then
						WardrobeUI.UpdateAllTabIcon();
					end
				end
			end
		end

		for i,v in ipairs(BP_ARRAY_WardrobeItemList) do
			if v.ins_id == tostring(itemData.instid) then
				v.count = itemData.count;
				break;
			end
		end
		
		-- log_tree("WardrobeUI:UpdateItemData BP_STRUCT_WardrobeClickedItemData", BP_STRUCT_WardrobeClickedItemData);
		-- log_tree("WardrobeUI:UpdateItemData BP_STRUCT_WardrobeChangedItemData", BP_STRUCT_WardrobeChangedItemData);
		LuaClassObj.HandleUIMessageNoFetch(bp_wardrobe, "UpdateOneItem");

		WardrobeUI.RemoveCurTabInvalidRedPoint();
	end
end

function WardrobeUI._CloseQuickMessageWindow()
	WardrobeUI._HideQuickMessageWindow()

	if quickMessageWindow then
		quickMessageWindow:Close()
		quickMessageWindow = nil
	end
end

-- 关闭仓库回调
function EventHideWardrodbe()
	if not WardrobeUI.isShowing then
		return;
	end
	
	-- EventWardrobeHideTabRedPoint();

	--LuaClassObj.HandleUIMessage(bp_lobby, "SwitchCamera_CloseMenu");
	WardrobeUI:UpdatePanelRedPoint(false, BP_CurPageTabType, BP_CurTabType);
    LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "ResetBtnSprites");
	TeamUpUI.OnCameraSwitch();
	
	WardrobeUI.isShowing = false;
			
    EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_CLOSE);
    WardrobeUI.RevertAvatar();
    WardrobeUI.saveIsShowing = false;
    LobbyUI:SwitchToMainCamera(true)
    EventShowSomeUIInWardrobeUI();

	WardrobeUI._CloseQuickMessageWindow()
end

-- 卖物品
function EventWardrobeSell()
	log("EventWardrobeSell: "..BP_Sell_id);
    --WardrobeSystem.wardrobe_sell_req(BP_Sell_id, 1);
	
	local itemData;
	local itemCfg;
	for k,v in pairs(DataMgr.arrayHallDepotItemInfo) do
		--log_tree("v", v);
		--log(type(v.insID)..", "..type(BP_Sell_id));
		if v.insID == BP_Sell_id then
			itemData = v;			
			itemCfg = Client.GetTableData("Item", v.resID);
			break;
		end		
	end
	--log_tree("itemData", itemData);
	
	if itemData and itemCfg then
		--local tip = string.format("是否以<img src=\"GoldImage\"/><MessageGoldColor>%s</>出售<MessageProductColor>%s</>?", itemCfg.SellPrice, itemCfg.ItemName);
		local tip = string.format(Client.GetTableData("LocalizeRes", "301306").TextValue, itemCfg.SellPrice, itemCfg.ItemName);
		tip = (string.gsub(tip, "\'", "\"")); 
		CommonMessageBoxUI:ShowPanel(2, Client.GetTableData("LocalizeRes", "301307").TextValue, tip, 
		function()
			WardrobeSystem.wardrobe_sell_req(BP_Sell_id, 1);
			return true;
		end
		);
	end
end

-- 点击item
function EventWardrobeClickItem()
	if not BP_STRUCT_WardrobeClickedItemData.is_sourcebook then
		local _, hasGet = DecomposeSystem.GetItemDecomposeInfo(BP_STRUCT_WardrobeClickedItemData.res_id);--Client.GetTableData("ItemDecompose", BP_STRUCT_WardrobeClickedItemData.res_id);
		if not hasGet then
			return;
		end
	end

	BP_String_Wardrobe_RemainTime = "";
	BP_Wardrobe_RemainTime = 0;
	BP_Wardrobe_IsShowUseButton = false;
	BP_Wardrobe_IsShowDecomposeButton = false;
	BP_Wardrobe_IsShowJumpToExchange = false;
	BP_Wardrobe_IsShowSendButton = false;
	BP_Wardrobe_IsShowComposeButton = false;
	BP_Wardrobe_IsShowJumpToShop = false;
	BP_Wardrobe_IsShowUpgradeButton = false;

	--log_tree("EventWardrobeClickItem BP_STRUCT_WardrobeClickedItemData", BP_STRUCT_WardrobeClickedItemData);

	if BP_STRUCT_WardrobeClickedItemData.is_sourcebook then
		log("Current Item Is SourceBook");
		WardrobeUI.SetCanShowJumpToShop();
		WardrobeUI.ClickSourceBookItem();
	else
		local itemInstID = BP_STRUCT_WardrobeClickedItemData.ins_id;
		local itemInst = DataMgr.GetHallDepotItemDataByInsID(BP_STRUCT_WardrobeClickedItemData.ins_id);
		if BP_STRUCT_WardrobeClickedItemData.is_new then
			-- 取消物品new标签
			WardrobeSystem.wardrobe_change_item_new_status(itemInstID);
		end

		if itemInst ~= nil then
			local itemCfg = Client.GetTableData("Item", itemInst.resID)
			WardrobeUI.ClickByItemCfg(itemCfg, itemInstID);

			-- 都没有button显示的时候，显示可赠送
			if CheckFuncSwitch(UI_SEND_BUTTON_SWITCH_ID) then
				if itemCfg and not (BP_Wardrobe_IsShowUseButton or BP_Wardrobe_IsShowDecomposeButton or BP_Wardrobe_IsShowJumpToExchange or BP_Wardrobe_IsShowComposeButton) then
					if Client.GetTableData("ItemSendFriend", itemInst.resID) ~= nil then
						BP_Wardrobe_IsShowSendButton = true;
					end
				end
			else
				log("开关关闭 "..tostring(UI_SEND_BUTTON_SWITCH_ID))
			end
		end
	end
end

function WardrobeUI.ClickByItemCfg(itemCfg, instID)
	log("WardrobeUI.ClickByItemCfg")

	if itemCfg == nil then
		return;
	end

	if itemCfg.WardrobeMainTab == BP_ENUM_WardrobePageType_Avatar or itemCfg.WardrobeMainTab == BP_ENUM_WardrobePageType_Parachute then
		if itemCfg.WardrobeTab == BP_ENUM_wardrobeTabString_emoj then
			WardrobeUI.UpdateSelectEmoj();
			WardrobeSystem.PlayMotion(itemCfg.ItemID);
		elseif itemCfg.WardrobeTab == BP_ENUM_wardrobeTabString_hallTheme then
			HallThemeUtils.PutOnHallTheme(instID)
		else
			WardrobeUI.ClickAvatarItem();
		end

		WardrobeUI.UpdateRemainTimeString();
		WardrobeUI.UpdateShowUpgradeButton();
		WardrobeUI.UpdateShowDecomposeButton();
		WardrobeUI.UpdateShowComposeButton();
	elseif itemCfg.WardrobeMainTab == BP_ENUM_WardrobePageType_Tools then
		WardrobeUI.ClickToolItem();
	elseif itemCfg.WardrobeMainTab == BP_ENUM_WardrobePageType_Gun then
		-- 点了枪的皮肤
		if itemCfg.WardrobeTab == BP_ENUM_wardrobeTabString_gun then
			WardrobeSystem.OnClickGunSkin();
		end

		WardrobeUI.UpdateRemainTimeString();
		WardrobeUI.UpdateShowUpgradeButton();
		WardrobeUI.UpdateShowDecomposeButton();
		WardrobeUI.UpdateShowComposeButton();
	elseif itemCfg.WardrobeMainTab == BP_ENUM_WardrobePageType_Vehicle then
		-- 点击载具的涂装
		WardrobeUI.UpdateRemainTimeString();
		WardrobeUI.UpdateShowUpgradeButton();
		WardrobeUI.UpdateShowDecomposeButton();
		WardrobeUI.ClickVehicleItem();
	end
end

-- 跳转
function EventWardrobeClickJump()
	log("EventWardrobeClickJump");
	if BP_WARDROBE_Jump_Item_resID == 0 then
		return;
	end

	local itemInfo = Client.GetTableData("Item", BP_WARDROBE_Jump_Item_resID);
	if itemInfo ~= nil then
	    BP_Global_Url = itemInfo.JumpUrl;
	    EventJumpUrl();
	end
end

-- 跳转兑换
function EventWardrobeClickJumpToExchange()
	log("EventWardrobeClickJump");
	if BP_WARDROBE_Jump_Item_resID == 0 then
		return;
	end

	local itemInfo = Client.GetTableData("Item", BP_WARDROBE_Jump_Item_resID);
	if itemInfo ~= nil then
	    BP_Global_Url = itemInfo.JumpExchangeUrl;
	    EventJumpUrl();
	end
end

function EventWardrobeClickJumpToShop()
	log("EventWardrobeClickJumpToShop");
	local itemId = BP_STRUCT_WardrobeClickedItemData.res_id
	if StoreSystem.IsUseNewStore() then
		WardrobeUI:Hide();
		JumpUtils.JumpAll(JumpUtils.MODEL_ID_LOBBY, itemId)
		return;
	end
	local shopInfo = MallSystem.getTabInfoByItemID(itemId)
	if(shopInfo == nil) then
		log("shopInfo is nil , itemID is :"..itemId);
		return;
	end
	local tap1 = shopInfo.first_tab
	local tap2 = shopInfo.second_tab

	local params = {
		["Tab1"] = tap1,
		["Tab2"] = tap2,
		["isForceTab2"] = true,
		["itemId"] = itemId,
	};
	if shopInfo.shop_id ~= nil and shopInfo.shop_id ~= 0 then
		params.selectShopId = shopInfo.shop_id
	else
		params.selectShopId = itemId
	end
	WardrobeUI:Hide();
	EventSystem:postEvent(EVENTTYPE_URL, BP_ENUM_MODULE_MALL_CHILD, params)
end

-- 分解
function EventWardrobeClickDecomposeItem()
	if BP_Wardrobe_DecomposeItemInsID == "" then
		return;
	end

    log("EventWardrobeClickDecomposeItem item "..BP_Wardrobe_DecomposeItemInsID);
    local itemData = DataMgr.GetHallDepotItemDataByInsID(BP_Wardrobe_DecomposeItemInsID)
    if not itemData then
        return;
    end

    -- 最后一件不能分解
	if itemData.mainTabType ~= BP_ENUM_WardrobePageType_Tools and itemData.count <= 1 then
		if itemData.expireTS <= 0 then
			ShowNotice(9910119);
			return;
		end
    end

    -- 该物品已全部使用，无法分解！
    if itemData.mainTabType ~= BP_ENUM_WardrobePageType_Tools and itemData.count <= WardrobeUI.GetUseCount(itemData.insID) and itemData.expireTS == 0 then
    	ShowNotice(4809);
    	return;
    end

    local itemCfg = Client.GetTableData("Item", itemData.resID);
    if not itemCfg then
        return;
    end
	
	if itemData.expireTS > 0 and itemData.expireTS < FuncUtil.GetServerTimeInSec() then
		CommonMessageBoxUI:ShowPanel(1, 
		Client.GetTableData("LocalizeRes", "101001").TextValue, 
		FuncUtil.GetLocalizeResStr(9910101),
		function()
			WardrobeUI.RefreshCurrentTab();
		end
	);
		return;
	end

    BP_GLOBAL_USE_ITEM = BP_Wardrobe_DecomposeItemInsID;

    local bIsLimitTimeItem = itemData.expireTS > 0;
    if itemData.mainTabType == BP_ENUM_WardrobePageType_Tools or itemData.expireTS > 0 then
    	CommonUseItemsUI.ShowDecomposeItem(itemCfg, itemData.count, bIsLimitTimeItem);
	else
    	CommonUseItemsUI.ShowDecomposeItem(itemCfg, itemData.count - math.max(1, WardrobeUI.GetUseCount(itemData.insID)), bIsLimitTimeItem);
	end
end

-- 合成
function EventWardrobeClickComposeItem()
	if BP_Wardrobe_ComposeItemInsID == "" then
		return;
	end

    log("EventWardrobeClickComposeItem item "..BP_Wardrobe_ComposeItemInsID);
    local itemData = DataMgr.GetHallDepotItemDataByInsID(BP_Wardrobe_ComposeItemInsID)
    if not itemData then
        return;
    end
	--log_tree("BP_Wardrobe_ComposeItemInsID",itemData);
	local itemComposeCfg = Client.GetTableData("ItemCompose", itemData.resID);
	if not itemComposeCfg then
		return;
	end
	
	if itemData.count < itemComposeCfg.needNum then
    	ShowNotice(4716);
    	return;
    end


    BP_GLOBAL_USE_ITEM = BP_Wardrobe_ComposeItemInsID;
	
	WardrobeSystem.on_item_compose(tonumber(BP_Wardrobe_ComposeItemInsID), 1)
end

function EventWardrobeUpdateComposeNum()
	if BP_Wardrobe_ComposeItemInsID == "" then
		return;
	end

    local itemData = DataMgr.GetHallDepotItemDataByInsID(BP_Wardrobe_ComposeItemInsID)
    if not itemData then
        return;
    end
	--log_tree("BP_Wardrobe_ComposeItemInsID",itemData);
	local itemComposeCfg = Client.GetTableData("ItemCompose", itemData.resID);
	if not itemComposeCfg then
		return;
	end
	BP_Wardrobe_ComposeItem_NeedNum = itemComposeCfg.needNum;
	BP_Wardrobe_ComposeItem_CurNum = itemData.count;
end

function WardrobeUI.GetWearPreviewInfoByResID(resID)
	local itemCfg = Client.GetTableData("Item", BP_STRUCT_WardrobeClickedItemData.res_id);
	if itemCfg ~= nil then
		return WardrobeUI.currentWearPreviewMap[itemCfg.ItemSubType];
	end

	return nil;
end

function WardrobeUI.ClickAvatarItem()
	-- log_tree("WardrobeUI.ClickAvatarItem：", BP_STRUCT_WardrobeClickedItemData);
	local itemInstID = BP_STRUCT_WardrobeClickedItemData.ins_id;

	if BP_CurPageTabType == BP_ENUM_WardrobePageType_Avatar or BP_CurPageTabType == BP_ENUM_WardrobePageType_Parachute then
		-- 如果点击的和实际穿戴的是同一件，则比较UI预览的物件
		local isWear = false;
		for k,v in pairs(DataMgr.rolewear) do
			if BP_STRUCT_WardrobeClickedItemData.ins_id == v then
				isWear = true;
				break;
			end
		end

		-- 如果装备的是降落伞
		local isParachute = false;
		if BP_STRUCT_WardrobeClickedItemData.ins_id == DataMgr.parachute then
			isWear = true;
			isParachute = true;
		end

		local isPlane = false
		if BP_STRUCT_WardrobeClickedItemData.ins_id == DataMgr.planeSkinInsID then
			isWear = true;
			isPlane = true;
		end

		local putonByClient = false;
		if isWear then
			local wearInfo = WardrobeUI.GetWearPreviewInfoByResID(BP_STRUCT_WardrobeClickedItemData.res_id);
			if wearInfo ~= nil then
				-- 如果已经存在预览信息，判断一下预览的信息和当前点击的是否同一件，是则做后面的处理，不是则直接换上
				if wearInfo.insID ~= BP_STRUCT_WardrobeClickedItemData.ins_id and wearInfo.resID ~= BP_STRUCT_WardrobeClickedItemData.res_id then
					putonByClient = true;
				end
			end
		end

		if putonByClient then
			local putonInfo = WardrobeUI.CreatePutOnInfo(BP_STRUCT_WardrobeClickedItemData.ins_id, BP_STRUCT_WardrobeClickedItemData.res_id);
			WardrobeUI.PutOnPreview(BP_STRUCT_WardrobeClickedItemData.ins_id, BP_STRUCT_WardrobeClickedItemData.res_id);
		elseif not putonByClient and isWear and (isParachute or isPlane) then
			WardrobeUI.UpdateSelectItem();
		else
			if BP_STRUCT_WardrobeClickedItemData.is_using then
				local itemCfg = Client.GetTableData("Item", BP_STRUCT_WardrobeClickedItemData.res_id);
				if itemCfg.WardrobeMainTab == BP_ENUM_WardrobePageType_Avatar then
					-- 请求脱时装
					log("EventWardrobeClickItem PutDown insID:"..itemInstID);
					WardrobeSystem.wardrobe_put_down_req(itemInstID, true);
				end
				if itemCfg.WardrobeMainTab == BP_ENUM_WardrobePageType_Parachute then
					if FuncUtil.Find(WardrobeUI.wardrobeEquipmentTabString, itemCfg.WardrobeTab) >= 0 then
						-- 请求脱时装
						log("EventWardrobeClickItem PutDown(Equipment) insID:"..itemInstID);
						WardrobeSystem.wardrobe_put_down_req(itemInstID, true);
					end
				end
			else
				-- 请求穿时装
				log("EventWardrobeClickItem PutOn insID:"..itemInstID);
				WardrobeSystem.wardrobe_puton_req(itemInstID);
			end
		end
	end
end

function WardrobeUI.ClickSourceBookItem()
	-- log_tree("WardrobeUI.ClickSourceBookItem：", BP_STRUCT_WardrobeClickedItemData);
	if BP_STRUCT_WardrobeClickedItemData.is_using then
		log("WardrobeUI.ClickSourceBookItem puton default");
		local itemCfg = Client.GetTableData("Item", BP_STRUCT_WardrobeClickedItemData.res_id);
		if itemCfg == nil then
			return;
		end

		local itemData = WardrobeUI.GetRealWearInstance(itemCfg.WardrobeMainTab, itemCfg.ItemSubType);
		if itemData == nil then
			-- 这里没有拿到真实的穿戴，把原来的穿戴脱下
			log("WardrobeUI.ClickSourceBookItem putoff");
			local wearInfo = WardrobeUI.currentWearPreviewMap[itemCfg.ItemSubType];
			if wearInfo ~= nil then
				LobbyUI:AvatarChange(LobbyUI:CreateAvatarChangeData(DataMgr.roleData.uid, wearInfo.resID), false);
				local oldInfo = WardrobeUI.CreatePutOnInfo(wearInfo.insID, wearInfo.resID);
				WardrobeUI:UpdatePutDownData(oldInfo);
			end
		else
			WardrobeUI.PutOnPreview(itemData.insID, itemData.resID);
		end
	else
		-- log_tree("WardrobeUI.ClickSourceBookItem puton", BP_STRUCT_WardrobeClickedItemData);
		if BP_STRUCT_WardrobeClickedItemData ~= nil then
			WardrobeUI.PutOnPreview(BP_STRUCT_WardrobeClickedItemData.ins_id, BP_STRUCT_WardrobeClickedItemData.res_id);
		end
	end
end

function WardrobeUI.UpdateSelectEmoj()
	local isChange;
	local needRefresh = false;
	for i,v in ipairs(BP_ARRAY_WardrobeItemList) do
		isChange = false;
		if v.is_selected then
			v.is_selected = false;
			isChange = true;
		end

		if v.ins_id == BP_STRUCT_WardrobeClickedItemData.ins_id and v.res_id == BP_STRUCT_WardrobeClickedItemData.res_id then
			v.is_selected = true;
			isChange = true;
		end

		if isChange then
			-- log_tree("WardrobeUI.UpdateSelectItem updateItem", v);
			WardrobeUI.DoUpdateOneItem(v, v.count, v.is_using, v.is_selected, false);
		end

		if not WardrobeUI.IsValidTime(FuncUtil.GetServerTimeInSec(), v.expireTS) then
			log("[yyc] emoj expireTS: "..v.expireTS.."  serverTime:"..FuncUtil.GetServerTimeInSec());
			needRefresh = true;
		end
	end

	if needRefresh then
		WardrobeUI.RefreshCurrentTab();
	end
end

function WardrobeUI.UpdateSelectItem()
	-- log_tree("WardrobeUI.UpdateSelectItem BP_STRUCT_WardrobeClickedItemData", BP_STRUCT_WardrobeClickedItemData);
	local isChange;
	for i,v in ipairs(BP_ARRAY_WardrobeItemList) do
		isChange = false;
		if v.is_using or v.is_selected then
			v.is_using = false;
			v.is_selected = false;
			isChange = true;
		end

		if v.ins_id == BP_STRUCT_WardrobeClickedItemData.ins_id and v.res_id == BP_STRUCT_WardrobeClickedItemData.res_id then
			v.is_using = true;
			v.is_selected = true;
			isChange = true;
		end

		if isChange then
			-- log_tree("WardrobeUI.UpdateSelectItem updateItem", v);
			WardrobeUI.DoUpdateOneItem(v, v.count, v.is_using, v.is_selected, false);
		end
	end
end

function WardrobeUI.ClickToolItem()
	--log("WardrobeUI.ClickToolItem");
	WardrobeUI.UpdateSelectItem();
	WardrobeUI.UpdateRemainTimeString();
	WardrobeUI.UpdateShowUpgradeButton();
	WardrobeUI.UpdateShowDecomposeButton();
	WardrobeUI.UpdateShowJumpToExchange();
	WardrobeUI.UpdateShowComposeButton();
end

function WardrobeUI.ClickVehicleItem()
	--log("WardrobeUI.ClickVehicleItem"..tostring(BP_STRUCT_WardrobeClickedItemData.res_id));
	--log("WardrobeUI.ClickVehicleItemInsID"..tostring(BP_STRUCT_WardrobeClickedItemData.ins_id));
	-- log_tree("[LLP]WardrobeUI.ClickVehicleItem", DataMgr.vehicleSkinInsIDTable);
	local itemInstID = BP_STRUCT_WardrobeClickedItemData.ins_id;
	if BP_CurPageTabType == BP_ENUM_WardrobePageType_Vehicle then
		local isWear = false;
		for k,v in pairs(DataMgr.vehicleSkinInsIDTable) do
			if BP_STRUCT_WardrobeClickedItemData.ins_id == v then
				isWear = true;
				break;
			end
		end
		--载具可以一直使用
		WardrobeUI.UpdateSelectItem();
		if not BP_STRUCT_WardrobeClickedItemData.is_using then
			-- 请求穿时装
			log("EventWardrobeClickVehicleItem PutOn resID:"..tostring(BP_STRUCT_WardrobeClickedItemData.res_id));
			log("EventWardrobeClickVehicleItem PutOn insID:"..itemInstID);
			if HallThemeUtils.themeVehicleId ~= BP_STRUCT_WardrobeClickedItemData.res_id then
				WardrobeSystem.wardrobe_puton_req(itemInstID);
			end
		end
	end
end

function WardrobeUI.GetRealWearInstance(pageType, itemSubType)
	if pageType == BP_ENUM_WardrobePageType_Avatar then
		local itemData = nil;
		for k,v in pairs(DataMgr.rolewear) do
			itemData = DataMgr.GetHallDepotItemDataByInsID(v);
			if itemData and itemData.mainTabType == pageType and itemData.itemSubType == itemSubType then
				return itemData;
			end
		end
		return nil;
	elseif pageType == BP_ENUM_WardrobePageType_Parachute then
		if itemSubType == wardrobeSubType_Parachute then
			return DataMgr.GetHallDepotItemDataByInsID(DataMgr.parachute);
		end
	end
end

function WardrobeUI.PutOnPreview(insID, resID)
	log("itemCfgitemCfgitemCfg "..insID.." "..resID);
	local itemCfg = Client.GetTableData("Item", resID);
	if itemCfg ~= nil then
		-- 记录新的穿戴
		local newWearInfo = WardrobeUI.CreatePutOnInfo(insID, resID);
		WardrobeUI:UpdatePutOnData(newWearInfo, nil);

		-- 更换穿戴
		if itemCfg.WardrobeMainTab == BP_ENUM_WardrobePageType_Avatar then
			BP_IsWardrobePutOnAvatar = true;
			LobbyUI:AvatarChange(LobbyUI:CreateAvatarChangeData(DataMgr.roleData.uid, resID), true);
		end

		WardrobeUI.UpdateBG(itemCfg, insID ~= "");
	end
end

function WardrobeUI.UpdateBG(itemCfg, showPutOn)
	if itemCfg then
		-- 隔离状态下，降落伞/飞机/载具背景替换成默认id
		local bIsolated = WardrobeSystem.IsItemIsolated(itemCfg.ItemID)

		if itemCfg.ItemSubType == wardrobeSubType_Parachute and itemCfg.Preview ~= "" then
			if bIsolated then
				BP_Wardrobe_BG_resID = DataMgr.defaultParachuteResID
			else
				BP_Wardrobe_BG_resID = itemCfg.ItemID;
			end
		elseif (itemCfg.ItemSubType == wardrobeSubType_Plane) and itemCfg.Preview ~= "" then
			if bIsolated then
				BP_Wardrobe_BG_resID = DataMgr.defaultPlaneSkinResID
			else
				BP_Wardrobe_BG_resID = itemCfg.ItemID;
			end
		elseif (itemCfg.ItemType == wardrobeMainTab_Vehicle) and itemCfg.Preview ~= "" then
			if bIsolated then
				local itemCfg = Client.GetTableData("Item", itemCfg.ItemID);
				BP_Wardrobe_BG_resID = DataMgr.defaultVehicleSkinResIDTable[itemCfg.ItemSubType]
			else
				BP_Wardrobe_BG_resID = itemCfg.ItemID;
			end
		end
	else
		BP_Wardrobe_BG_resID = 0;
	end
	BP_Wardrobe_BG_showPutOn = showPutOn;
	LuaClassObj.HandleUIMessageNoFetch(bp_wardrobe, "UpdateBG");
end

function WardrobeUI.CreatePutOnInfo(insID, resID)
	local result = nil;
	-- log("WardrobeUI.CreatePutOnInfo :"..insID.." "..resID);
	if insID ~= "" then
		local itemIns = DataMgr.GetHallDepotItemDataByInsID(insID);
		-- log_tree("WardrobeUI.CreatePutOnInfo "..insID, DataMgr.arrayHallDepotItemInfo);
		if itemIns ~= nil then
			result = {instid = insID, res_id = itemIns.resID, count = itemIns.count};
		end
	else
		result = {instid = "", res_id = resID, count = 0};
	end
	return result;
end

-- 切换小页签
function EventChangeWardrodbeTab()
	WardrobeUI.RefreshCurrentTab();
end

function WardrobeUI._ShowQuickMessageWindow()
	if quickMessageWindow then
		quickMessageWindow:SelfHitTestInvisible()
	else
		local BusinessHelper = import("BusinessHelper")
		local ui_manager = require("ui.manager")
		local setting_quickmessage_config = ui_manager.UI_Config.setting_quickmessage
		if setting_quickmessage_config.uiStat then
			BusinessHelper.StartUIStat(setting_quickmessage_config.uiStat.name)
		end

		local setting_quickmessage = require("client.slua.umg.setting.setting_quickmessage")
		quickMessageWindow = setting_quickmessage()
		quickMessageWindow:Init(setting_quickmessage_config.path, "", 0)
		quickMessageWindow:SelfHitTestInvisible()

		-- attach to Wardrobe_BP.Wardrobe_UIBP.CanvasPanel_2
		local Wardrobe_BP = UIUtil.GetWidgetByName("bp_wardrobe", "Wardrobe_BP")
		Wardrobe_BP.Wardrobe_UIBP.CanvasPanel_2:AddChild(quickMessageWindow.UIRoot)
		quickMessageWindow:SetAnchors(0, 0, 1, 1)
		quickMessageWindow:SetOffsets(0, 0, 0, 0)

		if setting_quickmessage_config.uiStat then
			BusinessHelper.StopUIStat(setting_quickmessage_config.uiStat.name, true)
		end
	end
end

function WardrobeUI._HideQuickMessageWindow()
	if quickMessageWindow then
		quickMessageWindow:Collapsed()
	end
end

function WardrobeUI.RefreshCurrentTab()
	BP_Wardrobe_BG_resID = 0;
    log("EventChangeWardrodbeTab page:"..BP_CurPageTabType..", tab:"..BP_CurTabType..", rolewear index:"..BP_RolewearTabIndex);
	BP_ARRAY_Wardrobe_SourceBookItemList = {}
	BP_ARRAY_Wardrobe_Emoj_Slots = {};
	BP_ARRAY_Wardrobe_GunResInfoList = {};

	-- 刷新大厅人物背包/头盔/防弹衣的穿戴
	if BP_CurPageTabType == BP_ENUM_WardrobePageType_Parachute and FuncUtil.Find(WardrobeUI.wardrobeEquipmentSubType, BP_CurTabType) >= 0 then
		WardrobeUI.CheckPutoffHatAvatar()
		WardrobeUI:PutOnHelmetEquipmentAvatar();
		WardrobeUI:PutOnBagEquipmentAvatar();
		WardrobeUI:ShowEquipmentLevelPanel();
	else
		--WardrobeUI:PutOffEquipmentAvatar();
		WardrobeUI:HideEquipmentLevelPanel();
	end

	WardrobeUI._HideQuickMessageWindow()

	if BP_CurPageTabType == BP_ENUM_WardrobePageType_Avatar then
		-- 切换到时装
		WardrobeUI.UpdateAllTabIcon(true);
		WardrobeUI:UpdateAvatarList();
	elseif BP_CurPageTabType == BP_ENUM_WardrobePageType_Tools then
		-- 切换到道具
		WardrobeUI.UpdateAllTabIcon(true);
		WardrobeUI:UpdateItemList();
	elseif BP_CurPageTabType == BP_ENUM_WardrobePageType_Parachute then
		-- 切换到降落伞
		if BP_CurTabType == WardrobeUI.wardrobeTabType_emoj then
			WardrobeSystem.RefreshEmojSlotsUI(false)
        end
		if BP_CurTabType == WardrobeUI.wardrobeTabType_quickmessage then
			WardrobeUI._ShowQuickMessageWindow()
		end
		WardrobeUI.UpdateAllTabIcon(true);
		WardrobeUI:UpdateAvatarList();
	elseif BP_CurPageTabType == BP_ENUM_WardrobePageType_Gun then
		-- 切换到枪械
		if BP_CurTabType == WardrobeUI.wardrobeTabType_gun then
			WardrobeSystem.GetGunSkinListReq();
		end
		--EventWardrobeGunTypeChanged()
	elseif BP_CurPageTabType == BP_ENUM_WardrobePageType_Vehicle then
		-- 切换到载具
		WardrobeUI.UpdateAllTabIcon(true);
		WardrobeUI:UpdateVehicleList();
	end

	-- 枪械小红点要在回包处理
    -- log("EventChangeWardrodbeTab lastPage:"..BP_LastPageType..", lastTab:"..BP_LastTabType);
    -- WardrobeUI.RemovePageRedPoint(BP_LastPageType, BP_CurPageTabType);
	WardrobeUI:UpdatePanelRedPoint(false, BP_CurPageTabType, BP_CurTabType);
	WardrobeUI.RemoveCurTabInvalidRedPoint();
end

-- 更新载具页签
function WardrobeUI:UpdateVehicleList()
	local tabString = WardrobeUI.tabTypeToString[BP_CurTabType];
	local serverTime = FuncUtil.GetServerTimeInSec();
	--log("WardrobeUI.UpdateVehicleList BP_CurTabType "..BP_CurTabType);
	--log("WardrobeUI.UpdateVehicleList tabString "..tostring(tabString));
	BP_ARRAY_WardrobeItemList = {};
	-- log_tree("[LLP]WardrobeUI:UpdateVehicleList", DataMgr.arrayHallDepotItemInfo);
	local isWear = false;
	for k,v in pairs(DataMgr.arrayHallDepotItemInfo) do
		if v.mainTabType == BP_ENUM_WardrobePageType_Vehicle and (v.expireTS == 0 or v.expireTS > serverTime) then
			--log_tree("v:", v);
			local itemCfg = Client.GetTableData("Item", v.resID);
			if itemCfg and itemCfg.WardrobeTab == tabString then

				isWear = false;
				wearInfo = WardrobeUI.currentWearPreviewMap[v.itemSubType];
				if wearInfo ~= nil then
					isWear = wearInfo.insID == v.insID and wearInfo.resID == v.resID;
				end

				if isWear then
					WardrobeUI.UpdateBG(itemCfg, v.insID ~= "")
				end

				local use_count_local = WardrobeUI.GetUseCount(v.insID);
				table.insert(BP_ARRAY_WardrobeItemList,
				{
					ins_id = v.insID,
					res_id = v.resID,
					count = v.count,
					use_count = use_count_local,
					is_using = false,
					is_new = v.isNew,
					is_selected = isWear,
					is_sourcebook = false,
					itemQuality = v.itemQuality,
					validHours = v.validHours,
					expireTS = v.expireTS,
					color_id = 0,
					pattern_id = 0,
					index = #BP_ARRAY_WardrobeItemList,
					is_isolated = WardrobeSystem.IsItemIsolated( v.resID ),
				});
			end
		end
	end

	local defaultId = DataMgr.defaultVehicleSkinResIDTable[BP_CurTabType];
	table.sort(BP_ARRAY_WardrobeItemList,
	function(a, b)
		local aHasTime = a.expireTS ~= 0;
		local bHasTime = b.expireTS ~= 0;

		if a.res_id == defaultId or b.res_id == defaultId then
			return a.res_id == defaultId
		elseif a.is_selected ~= b.is_selected then
			return a.is_selected;
		elseif a.is_new ~= b.is_new then
			return a.is_new;
		elseif aHasTime ~= bHasTime then
			return bHasTime;
		elseif a.itemQuality ~= b.itemQuality then
			return a.itemQuality > b.itemQuality;
		else
			return false;
		end
	end);

	--log_tree("WardrobeUI:UpdateVehicleList", BP_ARRAY_WardrobeItemList);
	LuaClassObj.HandleUIMessage(bp_wardrobe, "UpdateView");
end

-- 更新道具页签
function WardrobeUI:UpdateItemList()
	-- log("WardrobeUI:UpdateItemList");
	-- local itemSubType = 1502;
	local serverTime = FuncUtil.GetServerTimeInSec();
	BP_ARRAY_WardrobeItemList = {};
	for k,v in pairs(DataMgr.arrayHallDepotItemInfo) do
		if v.mainTabType == BP_ENUM_WardrobePageType_Tools and (v.expireTS == 0 or v.expireTS > serverTime) then
			--log_tree("v:", v);
			local use_count_local = WardrobeUI.GetUseCount(v.insID);
			table.insert(BP_ARRAY_WardrobeItemList,
			{
				ins_id = v.insID,
				res_id = v.resID,
				count = v.count,
				use_count = use_count_local,
				is_using = false,
				is_new = v.isNew,
				is_selected = false,
				is_sourcebook = false,
				validHours = v.validHours,
				expireTS = v.expireTS,
				color_id = v.colorID or 0,
				pattern_id = v.patternID or 0,
				index = #BP_ARRAY_WardrobeItemList,
				is_isolated = WardrobeSystem.IsItemIsolated( v.resID ),
			});
		end
	end
	--log_tree("UpdateItemList", BP_ARRAY_WardrobeItemList);

	table.sort(BP_ARRAY_WardrobeItemList,
	function(a, b)
		local aHasTime = a.expireTS ~= 0;
		local bHasTime = b.expireTS ~= 0;

		if a.is_new ~= b.is_new then
			return a.is_new;
		elseif aHasTime ~= bHasTime then
			return bHasTime;
		else
			return false;
		end
	end);

	LuaClassObj.HandleUIMessage(bp_wardrobe, "UpdateView");
end

function WardrobeUI.GetTabTypeBySubType(tabType)
	local itemSubType = 0;
	for k,v in pairs(WardrobeUI.structTabAndItemTypeRelationship) do
		if v.tabType == tabType then
			itemSubType = v.itemType;
			break;
		end
	end

	return itemSubType;
end

function WardrobeUI.UpdateItemUpgradeView()
	BP_Wardrobe_Item_Upgrade_Entrance_Open = LobbyUI:CheckLobbyMenuOpen(BP_ENUM_ITEM_UPGRADE, false);

    LuaClassObj.HandleUIMessageNoFetch(bp_wardrobe, "UpdateItemUpgradeEntrance");
end

-- 刷新当前时装页签
function WardrobeUI:UpdateAvatarList()
    --log("WardrobeUI:UpdateAvatarList BP_CurTabType"..BP_CurTabType);

    --log("BP_CurTabType:"..BP_CurTabType..", itemSubType:"..itemSubType);
    --log_tree("DataMgr.arrayHallDepotItemInfo:"DataMgr.arrayHallDepotItemInfo);
	local tabString = WardrobeUI.tabTypeToString[BP_CurTabType];
    WardrobeUI.UpdateElementList(tabString);
end

function WardrobeUI.UpdateElementList(tabString)
	log("WardrobeUI.UpdateElementList BP_CurPageTabType "..BP_CurPageTabType);
	log("WardrobeUI.UpdateElementList tabString "..tostring(tabString));
	if(tabString == BP_ENUM_wardrobeTabString_items) then
		WardrobeUI.UpdateItemList();
		return;
	end
	local isWear = false;
	local itemInfo = nil;
	local wearInfo = nil;
	BP_ARRAY_WardrobeItemList = {};
	local itemResIDMap = {}	-- 当前页签map
	--log_tree("WardrobeUI:UpdateAvatarList currentWearPreviewMap", WardrobeUI.currentWearPreviewMap)
	local serverTime = FuncUtil.GetServerTimeInSec();
	for k,v in pairs(DataMgr.arrayHallDepotItemInfo) do
		local itemCfg = DataMgr.WardrobeItemList[v.resID];
		if(itemCfg == nil) then
			itemCfg = Client.GetTableData("Item", v.resID);
		end
		if itemCfg and v.mainTabType == BP_CurPageTabType and (tabString == BP_ENUM_wardrobeTabString_all or itemCfg.WardrobeTab == tabString) and (v.expireTS == 0 or v.expireTS > serverTime) then
			-- log_tree("v:", v);

			isWear = false;			
			if itemCfg.ItemType == eItemType.eHallThemeItem then
				--主题
				isWear = HallThemeUtils.homeThemeItemId == v.resID
			else
				--普通服装
				wearInfo = WardrobeUI.currentWearPreviewMap[v.itemSubType];
				if wearInfo ~= nil then
					if FuncUtil.Find(WardrobeUI.wardrobeEquipmentSubType, v.itemSubType) >= 0 then
						isWear = wearInfo.insID == v.insID;  -- 背包/头盔/防弹衣，仓库里面是装备皮肤，穿到身上ResID又是单独的物品，因此特殊判断
					else
						isWear = wearInfo.insID == v.insID and wearInfo.resID == v.resID;
					end
				end
			end

			if isWear and (itemCfg.WardrobeTab == BP_ENUM_wardrobeTabString_parachute or itemCfg.WardrobeTab == BP_ENUM_wardrobeTabString_plane) then
				WardrobeUI.UpdateBG(itemCfg, v.insID ~= "")
			end

			-- log(string.format("WardrobeUI:UpdateAvatarList insID=%s resId=%s isWear=%s", tostring(v.insID), tostring(v.resID), tostring(isWear)))

			local use_count_local =  WardrobeUI.GetUseCount(v.insID)

			itemInfo =
			{
				ins_id = v.insID,
				res_id = v.resID,
				count = v.count,
				use_count = use_count_local,
				is_using = isWear,
				is_new = v.isNew,
				is_selected = false,
				is_sourcebook = false,
				validHours = v.validHours,
				expireTS = v.expireTS,
				itemSubType = v.itemSubType,
				itemQuality = v.itemQuality,
				color_id = v.colorID or 0,
				pattern_id = v.patternID or 0,
				is_isolated = WardrobeSystem.IsItemIsolated( v.resID ),
			};
			table.insert(BP_ARRAY_WardrobeItemList, itemInfo);

			itemResIDMap[v.resID] = itemInfo;
		end
	end

	local sortFunc = WardrobeUI.SortCommonItem;
	if tabString == BP_ENUM_wardrobeTabString_emoj then
		sortFunc = WardrobeUI.SortItemWithoutType;
	end

	-- log_tree("BP_ARRAY_WardrobeItemList", BP_ARRAY_WardrobeItemList);
	table.sort(BP_ARRAY_WardrobeItemList, sortFunc);

	for i,v in ipairs(BP_ARRAY_WardrobeItemList) do
		v.index = i - 1;
	end

	WardrobeUI.UpdateSourceBook(BP_CurPageTabType, tabString, itemResIDMap);
	--log_tree("BP_ARRAY_WardrobeItemList", BP_ARRAY_WardrobeItemList);
    LuaClassObj.HandleUIMessageNoFetch(bp_wardrobe, "UpdateView");
    if BP_CurPageTabType == BP_ENUM_WardrobePageType_Gun then
    	WardrobeUI.RefreshCurrentTab();
    end
end

function WardrobeUI.GetUseCount(insID)
	local use_count_local = 0;
	local itemInfo = DataMgr.GetHallDepotItemDataByInsID(insID)
	if itemInfo == nil then
		return 0
	end
	local cfg = Client.GetTableData("Item", itemInfo.resID)
	if cfg == nil then
		return 0
	end
	if cfg.ItemType == eItemType.eHallThemeItem then
		--主题道具使用次数
		use_count_local = HallThemeUtils.GetUsedItemCount(insID, HallThemeUtils.knapsack_ext_background)
	elseif cfg.ItemType == 9 then
		--载具使用次数
		use_count_local = HallThemeUtils.GetUsedItemCount(insID, HallThemeUtils.knapsack_ext_vst_skin)
	elseif cfg.ItemType == 1 then
		--枪械使用次数
		use_count_local = HallThemeUtils.GetUsedItemCount(insID, HallThemeUtils.knapsack_ext_weapon_skin)
	else
		for k1,v1 in pairs(DataMgr.rolewear_array) do
			for k2, v2 in pairs(v1) do
				if tostring(v2) == tostring(insID) then
					use_count_local = use_count_local + 1;
				end
			end
		end
	end
	return use_count_local;
end

function WardrobeUI.SortCommonItem(a, b)
	local aHasTime = a.expireTS ~= 0;
	local bHasTime = b.expireTS ~= 0;
	
	if a.res_id == DataMgr.defaultParachuteResID or b.res_id == DataMgr.defaultParachuteResID then
		return a.res_id == DataMgr.defaultParachuteResID;
	elseif a.res_id == DataMgr.defaultPlaneSkinResID or b.res_id == DataMgr.defaultPlaneSkinResID then
		return a.res_id == DataMgr.defaultPlaneSkinResID;
	elseif a.is_using ~= b.is_using then
		return a.is_using;
	elseif a.is_new ~= b.is_new then
		return a.is_new;
	elseif aHasTime ~= bHasTime then
		return bHasTime;
	elseif a.itemSubType ~= b.itemSubType then
		return a.itemSubType < b.itemSubType;
	elseif a.itemQuality ~= b.itemQuality then
		return a.itemQuality > b.itemQuality;
	elseif a.res_id ~= b.res_id then
		return a.res_id < b.res_id;
	elseif a.expireTS ~= b.expireTS then
		return a.expireTS < b.expireTS;
	else
		return false;
	end
end

function WardrobeUI.SortItemWithoutType(a, b)
	local aHasTime = a.expireTS ~= 0;
	local bHasTime = b.expireTS ~= 0;

	if a.res_id == DataMgr.defaultParachuteResID or b.res_id == DataMgr.defaultParachuteResID then
		return a.res_id == DataMgr.defaultParachuteResID;
	elseif a.res_id == DataMgr.defaultPlaneSkinResID or b.res_id == DataMgr.defaultPlaneSkinResID then
		return a.res_id == DataMgr.defaultPlaneSkinResID;
	elseif a.is_selected ~= b.is_selected then
		return a.is_selected;
	elseif a.is_new ~= b.is_new then
		return a.is_new;
	elseif aHasTime ~= bHasTime then
		return bHasTime;
	elseif a.itemQuality ~= b.itemQuality then
		return a.itemQuality > b.itemQuality;
	elseif a.res_id ~= b.res_id then
		return a.res_id < b.res_id;
	elseif a.expireTS ~= b.expireTS then
		return a.expireTS < b.expireTS;
	else
		return false;
	end
end

function WardrobeUI.UpdateSourceBook(wardrobeMainTab, tabString, itemResIDMap)
	tabString = tabString or BP_ENUM_wardrobeTabString_all;

	local curTypeSourceBook = DataMgr.mapSourceBookInfo[wardrobeMainTab];
	if curTypeSourceBook == nil then
		return;
	end

	local subTabArray = WardrobeUI.mainTabToSubTabArray[wardrobeMainTab];
	if subTabArray == nil then
		return;
	end

	-- 填充图鉴列表
	local sourceBookItemArray = nil;
	for i,v in ipairs(subTabArray) do
		-- log_tree("sourceBookItemArray "..tabString, sourceBookItemArray);
		if tabString == BP_ENUM_wardrobeTabString_all or v == tabString then
			sourceBookItemArray = curTypeSourceBook[v];
			if sourceBookItemArray ~= nil then
				for i,v in ipairs(sourceBookItemArray) do
					-- 如果不在仓库中，放到图鉴中
					local itemInfo = itemResIDMap[v.resID];
					if not itemInfo then
						WardrobeUI.AddToSourceBook(v);
					end
				end
			end
		end
	end
	--log_tree("BP_ARRAY_Wardrobe_SourceBookItemList", BP_ARRAY_Wardrobe_SourceBookItemList);
end

function WardrobeUI.AddToSourceBook(tableInfo)
	local wearInfo = WardrobeUI.currentWearPreviewMap[tableInfo.itemSubType];

	local info =
	{
		ins_id = "",
		res_id = tableInfo.resID,
		count = 0,
		is_new = false,
		is_selected = false,
		is_sourcebook = true,
		color_id = 0,
		pattern_id = 0,
	};
	info.is_using = wearInfo ~= nil and wearInfo.insID == "" and wearInfo.resID == tableInfo.resID;

	if info.is_using then
		local itemCfg = DataMgr.WardrobeItemList[info.res_id];
		if(itemCfg == nil) then
			itemCfg = Client.GetTableData("Item", info.res_id);
		end
		WardrobeUI.UpdateBG(itemCfg, false);
	end

	--cole 这里增加针对商城数据的筛选
	if JumpUtils.FindJumpInfoAll(tableInfo.resID) then
		table.insert(BP_ARRAY_Wardrobe_SourceBookItemList, info);
	end
end

function WardrobeUI.HasWearSubType(itemSubType)
	for k,v in pairs(DataMgr.rolewear) do
		local itemInfo = DataMgr.GetHallDepotItemDataByInsID(v);
		if itemInfo ~= nil and itemInfo.itemSubType == itemSubType then
			return true;
		end
	end

	for _, v in pairs(DataMgr.equipmentSkinInsIDTable) do
		local itemInfo = DataMgr.GetHallDepotItemDataByInsID(v);
		if itemInfo ~= nil and itemInfo.itemSubType == itemSubType then
			return true;
		end
	end

	return false;
end

function WardrobeUI.RevertAvatar()
	--log("WardrobeUI.RevertAvatar")

	-- log_tree("WardrobeUI.RevertAvatar rolewear", DataMgr.rolewear);
	WardrobeSystem.UpdateInvalidWearInfo()

	-- 还原真实穿戴(处理带帽子还是头盔)
	for k,v in pairs(DataMgr.rolewear) do
		local itemInfo = DataMgr.GetHallDepotItemDataByInsID(v);
		if itemInfo ~= nil then
			local wearInfo = WardrobeUI.currentWearPreviewMap[itemInfo.itemSubType];
			if wearInfo ~= nil and wearInfo.insID ~= itemInfo.insID then
				---- log_tree("WardrobeUI.RevertAvatar wearInfo", wearInfo);
				--if(itemInfo.itemSubType == WardrobeUI.wardrobeSubType_Hat) then
				--	if(itemInfo.insID == DataMgr.head_show) then
				--		LobbyUI:AvatarChange(LobbyUI:CreateAvatarChangeData(DataMgr.roleData.uid, itemInfo.resID, itemInfo.colorID, itemInfo.patternID), true);
				--	end
				--else
				--	LobbyUI:AvatarChange(LobbyUI:CreateAvatarChangeData(DataMgr.roleData.uid, itemInfo.resID, itemInfo.colorID, itemInfo.patternID), true);
				--end
				LobbyUI:AvatarChange(LobbyUI:CreateAvatarChangeData(DataMgr.roleData.uid, itemInfo.resID, itemInfo.colorID, itemInfo.patternID), true);
			end
		end
	end

	-- 穿背包
	WardrobeUI:PutOnOneEquipmentAvatar(DataMgr.BagSkinTableIndex, DataMgr.equipmentSkinInsIDTable[DataMgr.BagSkinTableIndex]);
	
	--穿头盔
	if(DataMgr.head_show == DataMgr.equipmentSkinInsIDTable[DataMgr.HelmetSkinTableIndex]) then
		local itemResID = WardrobeUI:GetEquipmentItemIDBySkinInsID(DataMgr.HelmetSkinTableIndex, DataMgr.head_show);
		LobbyUI:AvatarChange(LobbyUI:CreateAvatarChangeData(DataMgr.roleData.uid, itemResID, 0, 0), true);
	end

	-- 脱下实际未穿戴
	for k,v in pairs(WardrobeUI.currentWearPreviewMap) do
		if not WardrobeUI.HasWearSubType(k) then
			-- log("WardrobeUI.RevertAvatar putdown "..v.resID);
			LobbyUI:AvatarChange(LobbyUI:CreateAvatarChangeData(DataMgr.roleData.uid, v.resID), false);
		end
	end

	-- log_tree("WardrobeUI.RevertAvatar currentWearPreviewMap", WardrobeUI.currentWearPreviewMap);
    WardrobeUI.currentWearPreviewMap = {}

    -- 还原持枪
    if DataMgr.Weapon_ID == 0 then
    	WardrobeSystem.PutOffGunAvatar();
    end
end

function WardrobeUI:ShowEquipmentLevelPanel()
	log("WardrobeUI:ShowEquipmentLevelPanel"..BP_CurTabType);
	local level = WardrobeUI:GetEquipmentItemShowLevel(BP_CurTabType);
	if BP_CurTabType == WardrobeUI.wardrobeSubType_Bag then
		BP_STRUCT_WardrobeEquipmentLabel = 
		{
			level_one = Client.GetTableData("LocalizeRes", "4780").TextValue;
			level_two = Client.GetTableData("LocalizeRes", "4781").TextValue;
			level_three = Client.GetTableData("LocalizeRes", "4782").TextValue;
		}
	elseif BP_CurTabType == WardrobeUI.wardrobeSubType_Helmet then
		BP_STRUCT_WardrobeEquipmentLabel = 
		{
			level_one = Client.GetTableData("LocalizeRes", "4783").TextValue;
			level_two = Client.GetTableData("LocalizeRes", "4784").TextValue;
			level_three = Client.GetTableData("LocalizeRes", "4785").TextValue;
		}
	elseif BP_CurTabType == WardrobeUI.wardrobeSubType_Armor then
		BP_STRUCT_WardrobeEquipmentLabel = 
		{
			level_one = Client.GetTableData("LocalizeRes", "4780").TextValue;
			level_two = Client.GetTableData("LocalizeRes", "4781").TextValue;
			level_three = Client.GetTableData("LocalizeRes", "4782").TextValue;
		}
	end
	BP_Wardrobe_EquipmentDefaultLable = WardrobeUI:GetEquipmentLevelLabel(level)
	LuaClassObj.HandleUIMessage(bp_wardrobe, "ShowEquipmentLevelPanel");
end

function WardrobeUI:GetEquipmentLevelLabel(level)
	if level == 1 then
		return BP_STRUCT_WardrobeEquipmentLabel.level_one;
	elseif level == 2 then
		return BP_STRUCT_WardrobeEquipmentLabel.level_two;
	elseif level == 3 then
		return BP_STRUCT_WardrobeEquipmentLabel.level_three;
	else
		return BP_STRUCT_WardrobeEquipmentLabel.level_three;
	end
end

function WardrobeUI:HideEquipmentLevelPanel()
	--log("WardrobeUI:HideEquipmentLevelPanel");
	LuaClassObj.HandleUIMessage(bp_wardrobe, "HideEquipmentLevelPanel");
end

function WardrobeUI:PutOnEquipmentAvatar()
	--log("WardrobeUI:PutOnEquipmentAvatar");
	-- log_tree("WardrobeUI:PutOnEquipmentAvatar", DataMgr.equipmentSkinInsIDTable);
	for k, v in pairs(DataMgr.equipmentSkinInsIDTable) do
		WardrobeUI:PutOnOneEquipmentAvatar(k, v);
	end
end

function WardrobeUI:PutOnOneEquipmentAvatar(itemSubType, itemInsID)
	local itemResID = WardrobeUI:GetEquipmentItemIDBySkinInsID(itemSubType, itemInsID);
	local itemInfo = DataMgr.GetHallDepotItemDataByInsID(itemInsID);
	if itemResID >= 0 then
		local wearInfo = WardrobeUI.currentWearPreviewMap[itemSubType];
		if wearInfo == nil or wearInfo.insID ~= itemInsID then
			--log("WardrobeUI.PutOnOneEquipmentAvatar itemResID"..itemResID);
			--log_tree("WardrobeUI.PutOnOneEquipmentAvatar wearInfo", wearInfo);
			WardrobeUI.AddToWearInfo(itemSubType, itemInsID, itemResID, itemInfo and itemInfo.colorID or 0, itemInfo and itemInfo.patternID or 0);
		end
		LobbyUI:AvatarChange(LobbyUI:CreateAvatarChangeData(DataMgr.roleData.uid, itemResID, 0, 0), true);
	end
end

function WardrobeUI:PutOffEquipmentAvatar()
	--log("WardrobeUI:PutOffEquipmentAvatar");
	for k, v in pairs(DataMgr.equipmentSkinInsIDTable) do
		WardrobeUI:PutOffOneEquipmentAvatar(k, v);
	end
end

function WardrobeUI:PutOffHelmetEquipmentAvatar()
	log("PutOffHelmetEquipmentAvatar");
	for k, v in pairs(DataMgr.equipmentSkinInsIDTable) do
		if(k == DataMgr.HelmetSkinTableIndex) then
			WardrobeUI:PutOffOneEquipmentAvatar(k, v, false);
			return;
		end
	end
end

function WardrobeUI:PutOnHelmetEquipmentAvatar()
	--log_tree("DataMgr.equipmentSkinInsIDTable", DataMgr.equipmentSkinInsIDTable);
	for k, v in pairs(DataMgr.equipmentSkinInsIDTable) do
		if(k == DataMgr.HelmetSkinTableIndex) then
			WardrobeUI:PutOnOneEquipmentAvatar(k, v);
			local itemCfg = DataMgr.GetHallDepotItemDataByInsID(v);
			if(itemCfg ~= nil) then
				WardrobeSystem.depot_set_head_show_req(itemCfg.insID);
			end
			return;
		end
	end
end

function WardrobeUI:PutOnBagEquipmentAvatar()
	for k, v in pairs(DataMgr.equipmentSkinInsIDTable) do
		if(k == DataMgr.BagSkinTableIndex) then
			WardrobeUI:PutOnOneEquipmentAvatar(k, v);
			return;
		end
	end
end

function WardrobeUI:PutOffOneEquipmentAvatar(itemSubType, itemInsID, needClearWearInfo)
	local itemResID = WardrobeUI:GetEquipmentItemIDBySkinInsID(itemSubType, itemInsID);
	if itemResID >= 0 then
		local wearInfo = WardrobeUI.currentWearPreviewMap[itemSubType];
		log_tree("wearInfo", wearInfo);
		log_tree("WardrobeUI.currentWearPreviewMap", WardrobeUI.currentWearPreviewMap)
		if wearInfo ~= nil and wearInfo.insID == itemInsID then
			log("WardrobeUI.PutOffOneEquipmentAvatar itemResID"..itemResID);
			log_tree("WardrobeUI.PutOffOneEquipmentAvatar wearInfo", wearInfo);
			if(needClearWearInfo) then
				WardrobeUI.currentWearPreviewMap[itemSubType] = nil;
				if itemSubType == DataMgr.HelmetSkinTableIndex then
					WardrobeSystem.depot_set_head_show_req(0);
				end
			end
			LobbyUI:AvatarChange(LobbyUI:CreateAvatarChangeData(DataMgr.roleData.uid, itemResID), false);
		end
	end
end

function WardrobeUI:GetEquipmentItemIDBySkinInsID(itemSubType, itemInsID)
	local level = WardrobeUI:GetEquipmentItemShowLevel(itemSubType)
	local itemInfo = DataMgr.GetHallDepotItemDataByInsID(itemInsID);
	if itemInfo ~= nil then
		--log("WardrobeUI:GetEquipmentItemIDBySkinInsID"..itemInfo.resID)
		itemMappingCfg = Client.GetTableData("BackpackMapping", itemInfo.resID)
		--log_tree("WardrobeUI:GetEquipmentItemIDBySkinInsID", itemMappingCfg)
		if itemMappingCfg ~= nil then
			if level == 1 then
				return itemMappingCfg.SkinItemIDLv1;
			elseif level == 2 then
				return itemMappingCfg.SkinItemIDLv2;
			elseif level == 3 then
				return itemMappingCfg.SkinItemIDLv3;
			end
		end
	end
	return -1;
end

function WardrobeUI:GetEquipmentItemShowLevel(itemSubType)
	if itemSubType == WardrobeUI.wardrobeSubType_Bag then
		return BP_STRUCT_WardrobeEquipmentLevel.bag;
	elseif itemSubType == WardrobeUI.wardrobeSubType_Helmet then
		return BP_STRUCT_WardrobeEquipmentLevel.helmet;
	elseif itemSubType == WardrobeUI.wardrobeSubType_Armor then
		return BP_STRUCT_WardrobeEquipmentLevel.armor;
	else
		return 3;
	end
end

-- 点击装备等级
function EventWardrobeClickEquipmentLevel()
	log("EventWardrobeClickEquipmentLevel CurTabType:"..BP_CurTabType);
	local itemSubType = BP_CurTabType;
	wearInfo = WardrobeUI.currentWearPreviewMap[itemSubType];
	if wearInfo ~= nil then
		WardrobeSystem.depot_set_skin_info_req(BP_STRUCT_WardrobeEquipmentLevel.bag, BP_STRUCT_WardrobeEquipmentLevel.helmet)
	end
end

function WardrobeUI.IsUseType(itemType)
	for i,v in ipairs(WardrobeUI.useType) do
		if itemType == v then
			return true;
		end
	end

	return false;
end

function WardrobeUI.IsActiveSubType(itemSubType)
	for i,v in ipairs(WardrobeUI.activeSubType) do
		if itemSubType == v then
			return true;
		end
	end

	return false;
end

function WardrobeUI.UpdateRemainTimeString()
	BP_Wardrobe_IsShowUseButton = false;
	-- log_tree("WardrobeUI.UpdateRemainTimeString BP_STRUCT_WardrobeClickedItemData", BP_STRUCT_WardrobeClickedItemData);
	if BP_STRUCT_WardrobeClickedItemData == nil then
		return;
	end

	local itemData = DataMgr.GetHallDepotItemDataByInsID(BP_STRUCT_WardrobeClickedItemData.ins_id);
	if not itemData then
		return;
	end

	local isUseType = WardrobeUI.IsUseType(itemData.itemType);
	if itemData.itemType == 16 and itemData.itemSubType == 1602 then
		isUseType = ShopSystem.GetShopItemInfoByKeyItemId(itemData.resID) ~= nil;
	end
	-- log_tree("WardrobeUI.UpdateRemainTimeString itemData", itemData);
	if itemData.expireTS == 0 then
		WardrobeUI.SetShowUseButton(isUseType, itemData);
		return;
	end

	local remainTime = itemData.expireTS - FuncUtil.GetServerTimeInSec();
	-- log("WardrobeUI.UpdateRemainTimeString remainTime="..remainTime);
	if remainTime <= 0 then
		WardrobeUI.SetShowUseButton(false, itemData);
		BP_String_Wardrobe_RemainTime = FuncUtil.GetLocalizeResStr(9910111);
	else
		BP_Wardrobe_RemainTime = remainTime / 3600;

		-- 计算天数和小时数
		local timeStr = WardrobeSystem.GetRemainTimeStr(itemData.expireTS)

		if timeStr and timeStr ~= "" then
			BP_String_Wardrobe_RemainTime = FuncUtil.LocalizeResFormat(9910106, timeStr);
		end
		WardrobeUI.SetShowUseButton(isUseType, itemData);
	end
end

function WardrobeUI.SetShowUseButton(showUseButton, itemData)
	log("button WardrobeUI.SetShowUseButton")
	BP_Wardrobe_UseButtonText = "使用";
	
	--sami 烧鸡可以使用 roxy生化夺宝可以使用
	local AnniversaryActivitySystem = require("client.slua.logic.lobby_activity.logic_anniversary_activity")
	if itemData.resID == WardrobeSystem.GetShaoJiItemId() or LuckyUnbackUI.IsLuckyUnbackVoucher(itemData.resID) 
			or itemData.resID == AnniversaryActivitySystem.TicketId then
		BP_Wardrobe_IsShowUseButton = true
		return
	end

	if itemData.resID == BioChemicalUI.GetVoucherItemId() then
		BP_Wardrobe_IsShowUseButton = true
		return
	end
	
	--purple 周年碎片只有在活动开启期间才能使用
	if itemData.resID == AnniversaryActivitySystem.DebrisID then
		if not LobbyUI.AnniversaryActivityIsOpen() then
			BP_Wardrobe_IsShowUseButton = false;
			return;
			
		end 
	end
	BP_Wardrobe_IsShowUseButton = showUseButton;
	
	if not showUseButton then
		--还要检查是否显示激活
		local isActiveSubType = WardrobeUI.IsActiveSubType(itemData.itemSubType);
		BP_Wardrobe_IsShowUseButton = isActiveSubType;
		if BP_Wardrobe_IsShowUseButton then
			BP_Wardrobe_UseButtonText = "激活";
		end
	end
end

function WardrobeUI.UpdateShowDecomposeButton()
	log("WardrobeUI.UpdateShowDecomposeButton");
	if BP_Wardrobe_IsShowUseButton then
		return;
	end
	
	
	--是否是限时物品
	--[[
	local itemData = DataMgr.GetHallDepotItemDataByInsID(BP_STRUCT_WardrobeClickedItemData.ins_id);
	if not itemData or itemData.expireTS > 0 then
		return;
	end
	]]--
	
	--sami 烧鸡不能分解
	if BP_STRUCT_WardrobeClickedItemData.res_id == WardrobeSystem.GetShaoJiItemId() then
		BP_Wardrobe_IsShowDecomposeButton = false
		return
	end

	if ItemUpgradeSystem.CheckCanUpgrade(BP_STRUCT_WardrobeClickedItemData.res_id) == true then
		BP_Wardrobe_IsShowDecomposeButton = false
		return
	end

	local itemCfg = Client.GetTableData("Item", BP_STRUCT_WardrobeClickedItemData.res_id);
	if not itemCfg or itemCfg.SellPrice ~= 0 then
		return;
	end

	if FuncUtil.Find(WardrobeUI.decomposeItemSubType, itemCfg.ItemSubType) < 0 then
		return;
	end

	local decomposeInfo = DecomposeSystem.GetItemDecomposeInfo(BP_STRUCT_WardrobeClickedItemData.res_id);--Client.GetTableData("ItemDecompose", BP_STRUCT_WardrobeClickedItemData.res_id);
	if not decomposeInfo then
		return;
	end
	local itemData = DataMgr.GetHallDepotItemDataByInsID(BP_STRUCT_WardrobeClickedItemData.ins_id);

	if not itemData then
		return;
	end

	if itemData.expireTS > 0 then
		if decomposeInfo.timing_dst_item_id == nil or decomposeInfo.timing_item_ratio == nil or decomposeInfo.timing_dst_item_id == 0 then
			return;
		end
	end

	if decomposeInfo.new_dst_item_id and decomposeInfo.new_dst_item_id ~= 0 then
		BP_Wardrobe_IsShowDecomposeButton = true;
	end

	log("WardrobeUI.UpdateShowDecomposeButton BP_Wardrobe_IsShowDecomposeButton "..tostring(BP_Wardrobe_IsShowDecomposeButton));
end

function WardrobeUI.UpdateShowJumpToExchange()
	log("WardrobeUI.UpdateShowJumpToExchange")
	if BP_Wardrobe_IsShowDecomposeButton or BP_Wardrobe_IsShowUpgradeButton then
		return;
	end

	local itemCfg = Client.GetTableData("Item", BP_STRUCT_WardrobeClickedItemData.res_id);
	if not itemCfg then
		return;
	end

	if itemCfg.JumpExchangeUrl == "" then
		return;
	end

	local params = FuncUtil:ParseURLParams(itemCfg.JumpExchangeUrl);
	local moduleId = tonumber(params["module"]);
	local cb = WardrobeUI.checkShowJumpToExchangeCB[moduleId];
	if cb ~= nil then
		BP_Wardrobe_IsShowJumpToExchange = cb(params)
	end
end

function WardrobeUI.UpdateShowComposeButton()
	log("WardrobeUI.UpdateShowComposeButton");
	if BP_Wardrobe_IsShowJumpToExchange then
		return;
	end

	local itemComposeCfg = Client.GetTableData("ItemCompose", BP_STRUCT_WardrobeClickedItemData.res_id);
	if not itemComposeCfg then
		return;
	end

	BP_Wardrobe_IsShowComposeButton = true;

	log("WardrobeUI.UpdateShowComposeButton BP_Wardrobe_IsShowComposeButton "..tostring(BP_Wardrobe_IsShowComposeButton));
end

function WardrobeUI.UpdateShowUpgradeButton()
	-- 外观可升级道具不能分解
	if LobbyUI:CheckLobbyMenuOpen(BP_ENUM_ITEM_UPGRADE, false) == false or ItemUpgradeSystem.CheckCanUpgrade(BP_STRUCT_WardrobeClickedItemData.res_id) == false or ItemUpgradeSystem.IsItemEffectMaxLevel(BP_STRUCT_WardrobeClickedItemData.res_id) then
		log("ItemUpgradeSystem.CheckCanUpgrade(BP_STRUCT_WardrobeClickedItemData.res_id) == false---"..tostring(BP_STRUCT_WardrobeClickedItemData.res_id))
		BP_Wardrobe_IsShowUpgradeButton = false;
		return;
	end
	BP_Wardrobe_IsShowUpgradeButton = true;
	BP_Wardrobe_UpgradeItem_Is_Max_Level = ItemUpgradeSystem.IsItemEffectMaxLevel(BP_STRUCT_WardrobeClickedItemData.res_id);
end

function WardrobeUI.IsActivityEnable(params)
	local id = params["id"];
	if id == nil then
		return false;
	end

	id = tonumber(id)

	-- log("WardrobeUI.IsActivityEnable id "..id);
	-- log_tree("WardrobeUI.IsActivityEnable DataMgr.activity.activityMap", DataMgr.activity.activityMap)
	local activityData = DataMgr.activity.activityMap[id];
	-- log_tree("WardrobeUI.IsActivityEnable activityData", activityData)

	return activityData ~= nil;
end

function WardrobeUI.UpdateTime()
	if WardrobeUI.isShowing then
		BP_String_Wardrobe_RemainTime = "";
		BP_Wardrobe_RemainTime = 0;
		WardrobeUI.UpdateRemainTimeString()
		LuaClassObj.HandleUIMessage(bp_wardrobe, "UpdateTime");
	end
end

function WardrobeUI.UpdateAllTabIcon(noRefresh)
	if not WardrobeUI.isShowing then
		return;
	end

	curTabIcon = {}
	for k, v in pairs(BP_ARRAY_WardrobePageList) do
		if BP_CurPageTabType == v.page_id then
			curTabIcon[v.id] = {id = v.id, item_res_id = 0};
		end
	end

	if BP_CurPageTabType == BP_ENUM_WardrobePageType_Avatar then
		-- log_tree("WardrobeUI.UpdateAllTabIcon DataMgr.rolewear", DataMgr.rolewear);
		for i, v in ipairs(DataMgr.rolewear) do
			--log("DataMgr.rolewear ".. v);
			WardrobeUI.AddTabIcon(v);
		end
		WardrobeUI.AddTabIcon(HallThemeUtils.homeThemeInstId);
	elseif BP_CurPageTabType == BP_ENUM_WardrobePageType_Parachute then
		WardrobeUI.AddTabIcon(DataMgr.parachute);
		WardrobeUI.AddTabIcon(DataMgr.planeSkinInsID);
		for i, v in pairs(DataMgr.equipmentSkinInsIDTable) do
			WardrobeUI.AddTabIcon(v);
		end
	elseif BP_CurPageTabType == BP_ENUM_WardrobePageType_Vehicle then
		for i, v in pairs(DataMgr.vehicleSkinInsIDTable) do
			WardrobeUI.AddTabIcon(v);
		end
	end

	BP_ARRAY_CurPageTabIcon = {}
	for k, v in pairs(curTabIcon) do
		table.insert(BP_ARRAY_CurPageTabIcon, v);
	end

	--对载具页签按id大小排序
	if(BP_CurPageTabType == BP_ENUM_WardrobePageType_Vehicle) then
		table.sort(BP_ARRAY_CurPageTabIcon, function (a, b) return a.id < b.id end)
		log_tree("QPP=============================", BP_ARRAY_CurPageTabIcon)
	end

	-- log_tree("WardrobeUI.UpdateAllTabIcon BP_ARRAY_CurPageTabIcon", BP_ARRAY_CurPageTabIcon);
	if next(BP_ARRAY_CurPageTabIcon) ~= nil and not noRefresh then
		LuaClassObj.HandleUIMessageNoFetch(bp_wardrobe, "UpdateTabIcon");
	end
end

function WardrobeUI.AddTabIcon(insID)
	if not insID then
		return;
	end
	local itemData = DataMgr.GetHallDepotItemDataByInsID(insID);
	--log_tree("wearItem", itemData);

	if itemData then
		local itemCfg = Client.GetTableData("Item", itemData.resID)
		if itemCfg then
			local tab = WardrobeUI.tabStringToType[itemCfg.WardrobeTab];
			if tab ~= nil then
				-- 隔离下，tab页签的图标为默认图标
				if WardrobeSystem.IsItemIsolated(itemData.resID) then
					local defaultResID;
					if itemCfg.ItemSubType == wardrobeSubType_Parachute then
						defaultResID = DataMgr.defaultParachuteResID

					elseif (itemCfg.ItemType == wardrobeSubType_Plane) then
						defaultResID = DataMgr.defaultPlaneSkinResID

					elseif (itemCfg.ItemType == wardrobeMainTab_Vehicle) then
						defaultResID = DataMgr.defaultVehicleSkinResIDTable[itemCfg.ItemSubType]

					end
					curTabIcon[tab] = {id = tab, item_res_id = defaultResID};
				else
					curTabIcon[tab] = {id = tab, item_res_id = itemData.resID};
				end
			end
		end
	end
end

function WardrobeUI.OnDiamondUpdate()
	WardrobeUI.UpdateDiamondStr(true);
end

function WardrobeUI.OnGoldChipUpdate()
	WardrobeUI.UpdateGoldChipStr(true);
end

function WardrobeUI.OnDecomposeItemInfoRsp()
	log("OnDecomposeItemInfoRsp")
	if WardrobeUI.isShowing == true then
		local itemInst = DataMgr.GetHallDepotItemDataByInsID(BP_STRUCT_WardrobeClickedItemData.ins_id);
		if itemInst ~= nil then
			EventWardrobeClickItem();
			LuaClassObj.HandleUIMessage(bp_wardrobe, "ShowTipPanel");
		end
	end
end

function WardrobeUI.OnRedPointInfoUpdate()
	log("WardrobeUI.OnRedPointInfoUpdate")
	WardrobeSystem.UpdateLobbyHotDot();
	WardrobeUI.RefreshOtherRedPoint();
end

function WardrobeUI.UpdateDiamondStr(isRefresh)
	BP_WardrobeDiamond = WardrobeUI.GetGoldNumStr(DataMgr.diamond)

	if isRefresh then
		LuaClassObj.HandleUIMessageNoFetch(bp_wardrobe, "UpdateDiamond");
	end
end

function WardrobeUI.UpdateGoldChipStr(isRefresh)
	BP_WardrobeGoldChip = WardrobeUI.GetGoldNumStr(DataMgr.gold_chip)

	if isRefresh then
		LuaClassObj.HandleUIMessageNoFetch(bp_wardrobe, "UpdateGoldChip");
	end
end

function WardrobeUI.CheckPutOffHelmetAvatar(itemCfg)
	log("itemCfg.WardrobeTab".. itemCfg.WardrobeTab);
	if(itemCfg.WardrobeTab == BP_ENUM_wardrobeTabString_head) then
		WardrobeUI:PutOffHelmetEquipmentAvatar()
	end
end

function WardrobeUI.CheckPutoffHatAvatar(itemCfg)
	if(itemCfg == nil or itemCfg.WardrobeTab == BP_ENUM_wardrobeTabString_helmet) then
		if(DataMgr.equipmentSkinInsIDTable[DataMgr.HelmetSkinTableIndex] == "") then
			return;
		end
		local wearInfo = WardrobeUI.currentWearPreviewMap[WardrobeUI.wardrobeSubType_Hat];
		if(wearInfo ~= nil) then
			LobbyUI:AvatarChange(LobbyUI:CreateAvatarChangeData(DataMgr.roleData.uid, wearInfo.resID), false);
		end
	end
end

function EventWardrobeOnClickBatchDecompose()
	log("EventWardrobeOnClickBatchDecompose");
	log("BP_CurPageTabType " ..tostring(BP_CurPageTabType))
	ItemDecomposeUI.Show(BP_CurPageTabType);
end

function EventWardrobeOnClickItemUpgrade()
	log("EventWardrobeOnClickItemUpgrade");
 	WardrobeUI:Hide();
	ItemUpgradeUI.Show();
end

function EventWardrobeOnClickUseItem()
	local itemData = DataMgr.GetHallDepotItemDataByInsID(BP_STRUCT_WardrobeClickedItemData.ins_id);
	if not itemData then
		return;
	end
	log("EventWardrobeOnClickUseItem:"..tostring(itemData.itemType))
	if itemData.itemType == 16 and itemData.itemSubType == 1602 then
		local shopBoxItem = ShopSystem.GetShopItemInfoByKeyItemId(BP_STRUCT_WardrobeClickedItemData.res_id);

		if StoreSystem.IsUseNewStore() then--新商城
			if shopBoxItem and shopBoxItem[StoreSystem.label_shop_index_id] then
				local pageId = shopBoxItem[StoreSystem.label_shop_index_id];
				-- 跳转新商城补给
				WardrobeUI:Hide();
				JumpUtils.JumpFromLobbyToSupply(pageId);
				return;
			end
		else
			if shopBoxItem and shopBoxItem.product_id ~= 0 then
				local params = {
					["id"] = shopBoxItem.product_id,
				};
				EventSystem:postEvent(EVENTTYPE_URL, BP_ENUM_MODULE_MALL_BOX, params);
				return;
			end
		end
	elseif itemData.itemType == 26 and itemData.itemSubType == 2601 then-- 外显升级材料道具，点击使用跳转到外显升级界面
		WardrobeUI:Hide();
		ItemUpgradeUI.Show();
		return;
	elseif itemData.itemType == 16 and itemData.itemSubType == 1605 then -- 跳到宠物界面
		EventOpenPetMain()
		return
	end
	LuaClassObj.HandleUIMessageNoFetch(bp_wardrobe, "CommonUseItem");

end

function EventWardrobeOnClickItemUpgradeGuideMask()
	LuaClassObj.HandleUIMessageNoFetch(bp_wardrobe, "UpdateItemUpgradeGuideView");
 	WardrobeUI:Hide();
	ItemUpgradeUI.Show();
end


-----------------表情相关----------
-- 表情槽位最大数
BP_Wardrobe_Emoj_Slots_Max = 0;

-- 表情槽位
BP_ARRAY_Wardrobe_Emoj_Slots = {""}

-- 操作的表情
BP_Wardrobe_Op_Emoj = "";

-- 操作的槽位
BP_Wardrobe_Op_Emoj_Slot = 0; -- 从0开始

BP_Wardrobe_keep_GunID = 0; --记录上一次拿的枪械id

-- 刷新表情槽数据
function EventWardrobeRefreshEmojSlots()
	WardrobeSystem.RefreshEmojSlotsUI()

	if #BP_ARRAY_Wardrobe_Emoj_Slots ~= #DataMgr.MotionSlotList then
		DataMgr.sync_motion_info_req(false);
	end
end

-- 装备表情
function EventWardrobeEquipEmoj()
	log("[yyc] EventWardrobeEquipEmoj");
	for i,v in ipairs(BP_ARRAY_WardrobeItemList) do
		log("[yyc] item ins_id"..v.ins_id.."    res_id"..v.res_id);
		if v.ins_id == BP_Wardrobe_EquipEmoj_InsId and v.res_id == BP_Wardrobe_EquipEmoj_ResId then
			if not WardrobeUI.IsValidTime(FuncUtil.GetServerTimeInSec(), v.expireTS) then
				log("[yyc] EquipEmoj time is not valid");
				WardrobeUI.RefreshCurrentTab();
				return;
			else
				break;
			end
		end
	end

	WardrobeSystem.EquipMotion(BP_Wardrobe_Op_Emoj, BP_Wardrobe_Op_Emoj_Slot+1);
end

-- 移除表情
function EventWardrobeUnequipEmoj()
	WardrobeSystem.unequip_motion_req(BP_Wardrobe_Op_Emoj, BP_Wardrobe_Op_Emoj_Slot+1);
end

-- 播放表情
function EventWardrobePlayEmoj()
	log("EventWardrobePlayEmoj BP_Wardrobe_Op_Emoj "..BP_Wardrobe_Op_Emoj);
	local itemInst = DataMgr.GetHallDepotItemDataByInsID(BP_Wardrobe_Op_Emoj);
	if itemInst == nil then
		return;
	end

	WardrobeSystem.PlayMotion(itemInst.resID);
end

-- 点击升级按钮
function EventWardrobeClickUpgradeBtn()
	log("EventWardrobeClickUpgradeBtn");
 	WardrobeUI:Hide();
 	if BP_STRUCT_WardrobeClickedItemData ~= nil then
		ItemUpgradeUI.ShowByItemID(BP_STRUCT_WardrobeClickedItemData.res_id);
	end
end
----------------枪械皮肤相关----------------

-- 选中枪械
BP_Wardrobe_GunID = 0;

-- 选中皮肤
BP_Wardrobe_GunSkinUID = "";

-- 选中枪械类型
BP_Wardrobe_CurrentGunType = 1;

-- 点击枪械
BP_Wardrobe_ClickGun = 0;

-- 点击皮肤
BP_Wardrobe_ClickGunSkin = "";

-- 是否已装备枪械
BP_Wardrobe_PutOnCurrentGun = false;

-- 枪械结构
BP_STRUCT_Wardrobe_GunResInfo =
{
	resID = 0,
	skinResID = 0,
	total_count = 0,	--拥有总数
	use_count = 0,		--使用数量
}

-- 枪械列表
BP_ARRAY_Wardrobe_GunResInfoList = {BP_STRUCT_Wardrobe_GunResInfo = _G.BP_STRUCT_Wardrobe_GunResInfo}

-- 枪械类型
BP_ARRAY_Wardrobe_GunType = {""}

-- 枪械主页签开关
BP_Wardrobe_GunTab_Toogle = false;

-- 枪械状态更新
BP_STRUCT_Wardrobe_Changed_GunResInfo = _G.BP_STRUCT_Wardrobe_GunResInfo;

function EventWardrobeClickGun()
	WardrobeSystem.OnClickGun()
end

function EventWardrobeOnPutOnGunStateChange()
	WardrobeSystem.OnPutOnStateChange();
end

WardrobeUI.isGunTypeChange = false
function EventWardrobeGunTypeChanged()
	WardrobeUI.isGunTypeChange = true
	WardrobeSystem.UpdateGunList(BP_Wardrobe_CurrentGunType);
end

-- 赠送道具给好友（世界杯活动）
BP_Wardrobe_IsShowSendButton = false;
BP_Wardrobe_SendItemResID = 0; -- Wardrobe_BP里点击按钮时设置
function EventWardropClickSendItem()
	log("EventWardropClickSendItem "..tostring(BP_Wardrobe_IsShowSendButton)..","..BP_Wardrobe_SendItemResID..","..BP_Wardrobe_RemainTime);
	if not BP_Wardrobe_IsShowSendButton then
		return;
	end
	-- 打开赠送好友界面
	if BP_STRUCT_WardrobeClickedItemData ~= nil and 
		BP_STRUCT_WardrobeClickedItemData.res_id == BP_Wardrobe_SendItemResID and
		BP_STRUCT_WardrobeClickedItemData.count > 0 then
		LobbyFriendUI:OpenSendSelectFriend(BP_Wardrobe_SendItemResID, BP_STRUCT_WardrobeClickedItemData.count, BP_Wardrobe_RemainTime);
	end
end

-- 为了解引用
BP_Wardrobe_EmojiSelectIndex = 0;
function EventWardrobeShowEmojSelect()
	LuaClassObj.HandleUIMessageNoFetch(bp_wardrobe, "ShowEmojiSelected");
end

function EventWardrobeHideEmojSelect()
	LuaClassObj.HandleUIMessageNoFetch(bp_wardrobe, "HideEmojiSelected");
end

function EventWardrobeClickIsolatedItem( )
    -- 该物品在当前服务器不可使用
    DataMgr.ShowNoticeByID(4987);
end

--sami 获取红装表情所属的衣服id
function WardrobeUI.GetRedEmotionClothId(redEmotionId)
	if WardrobeUI.redEmotionTb[redEmotionId] ~= nil then
		return WardrobeUI.redEmotionTb[redEmotionId]
	end
	local cfg = Client.GetTableData("Item", redEmotionId);
	if cfg and cfg.RedEmotionFlag > 0 then
		WardrobeUI.redEmotionTb[redEmotionId] = cfg.RedEmotionFlag
		return cfg.RedEmotionFlag
	end
	WardrobeUI.redEmotionTb[redEmotionId] = 0
	return 0
end

--sami 是否可以使用红装表情
function WardrobeUI.CheckCanUseRedEmotion(redEmotionId)
	log("WardrobeUI.CheckCanUseRedEmotion redEmotionId = "..redEmotionId)
	local redClothItemId = WardrobeUI.GetRedEmotionClothId(redEmotionId)
	if redClothItemId == 0 then
		log("WardrobeUI.CheckCanUseRedEmotion redClothItemId = 0")
		return false
	end
	for k,v in pairs(DataMgr.rolewear) do
		local itemInfo = DataMgr.GetHallDepotItemDataByInsID(v);
		if itemInfo ~= nil and itemInfo.resID == redClothItemId then
			log("WardrobeUI.CheckCanUseRedEmotion itemInfo.resID == redClothItemId")
			return false
		end
	end
	log("WardrobeUI.CheckCanUseRedEmotion ret true")
	return true
end
function EventWardrobeCheckCanUseRedEmotion()
	BP_Wardrobe_RedEmotion_Check_Result = WardrobeUI.CheckCanUseRedEmotion(BP_Wardrobe_RedEmotion_Check_ItemId)
end

--sami 不能使用红装
function EventWardrobeCannotUseRedEmotion()
	DataMgr.ShowNoticeByID(6014);
end

-- 判断商品是否在商城内
function WardrobeUI.SetCanShowJumpToShop()
	
	log("SetCanShowJumpToShop, resID :".. BP_STRUCT_WardrobeClickedItemData.res_id);
	local itemId = BP_STRUCT_WardrobeClickedItemData.res_id;
	if StoreSystem.IsUseNewStore() then
		local jumpInfo = JumpUtils.FindJumpInfoAll(itemId);
		if jumpInfo then
			BP_Wardrobe_IsShowJumpToShop = true;
		else
			BP_Wardrobe_IsShowJumpToShop = false;
		end
		return;
	end
	local shopInfo = MallSystem.getTabInfoByItemID(itemId);
	if shopInfo ~= nil then
		BP_Wardrobe_IsShowJumpToShop = true;
		log("BP_Wardrobe_IsShowJumpToShop true");
		log_tree("ShopInfo: ", shopInfo);
		return;
	end
	log("BP_Wardrobe_IsShowJumpToShop false");
	BP_Wardrobe_IsShowJumpToShop = false;
end

function WardrobeUI.RefreshResetAvatarRedPoint()
	BP_Wardrobe_ResetAvatar_RedPoint = false
	if next(DataMgr.avatarData.activate_avatar_list) ~= nil then
		for k,v in pairs(DataMgr.avatarData.activate_avatar_list) do
			if not BP_Wardrobe_ResetAvatar_RedPoint and v == 1 then
				BP_Wardrobe_ResetAvatar_RedPoint = true
			end
		end
	end
	LuaClassObj.HandleUIMessage(bp_wardrobe, "RefreshResetAvatarRedPoint");
end

function EventOpenCreateRoleAvatarResetPanel()
	WardrobeSystem.UpdateLobbyHotDot();
	LobbySystem.SendDefaultWearInfoReq();
	EventOpenAvatarResetPanel()
end

function EventOpenPetMain()
	local PetSystem = require("client.slua.logic.pet.logic_pet")
	PetSystem.InitPetFromTable()
	PetSystem.isReadyToShowPetMain = true
	PetSystem.get_pet_data_req()

	ClientSendBAReport(BP_ENUM_MODULE_PET_ENTER, 0);
end
----------------标签相关----------------
BP_WARDROBE_TAG_DES1 = "";
BP_WARDROBE_TAG_DES2 = "";
BP_WARDROBE_TAG_DES3 = "";

BP_WARDROBE_TAG_NAME1 = "";
BP_WARDROBE_TAG_NAME2 = "";
BP_WARDROBE_TAG_NAME3 = "";

BP_WARDROBE_TAG_PIC1 = "";
BP_WARDROBE_TAG_PIC2 = "";
BP_WARDROBE_TAG_PIC3 = "";

function EventClickTagOne()
	TagDetailUI.ShowUI(BP_WARDROBE_TAG_NAME1, BP_WARDROBE_TAG_PIC1, BP_WARDROBE_TAG_DES1);
end

function EventClickTagTwo()
	log("BP_WARDROBE_TAG_DES2".. BP_WARDROBE_TAG_DES2);
	TagDetailUI.ShowUI(BP_WARDROBE_TAG_NAME2, BP_WARDROBE_TAG_PIC2, BP_WARDROBE_TAG_DES2);
end

function EventClickTagThree()
	log("BP_WARDROBE_TAG_DES3".. BP_WARDROBE_TAG_DES3);
	TagDetailUI.ShowUI(BP_WARDROBE_TAG_NAME3, BP_WARDROBE_TAG_PIC3, BP_WARDROBE_TAG_DES3);
end

function EventHideTagDetailUI()
	TagDetailUI.HideUI();
end

--sami 处理chexkbox是否大厅显示载具点击
function EventWardrobeUI_CheckBoxShowInHallClick()
    log("xx EventWardrobeUI_CheckBoxShowInHallClick sts = "..tostring(BP_Wardrobe_CheckBox_Show_In_Hall_Sts))
    HallThemeUtils.set_knapsack_pos_show_req(BP_Wardrobe_CheckBox_Show_In_Hall_Sts)
    
    if BP_Wardrobe_CheckBox_Show_In_Hall_Sts then
    
        
    else
        
        
    end
end

--是否可以显示checkbox
function WardrobeUI.CanShowCheckBoxShowInHall()
    if BP_CurPageTabType == BP_ENUM_WardrobePageType_Vehicle then
        return true
    else
        return false
    end
end

