MallSystemUI_2 = MallSystemUI_2 or
{
	isShowing = false;
	isBackingFromRoleUI = false;
	--角色在商城大厅里
	isMallCamera = false;
	isRoleInMall = false;
	weaponShowType = 1;
	showItemId = 0;
	weaponID = 0;
	--播放表情timer
	nPlayEmotionTimerId = 0;
	nLastPlayEmotionTime = 0;
	isFromLeague = 2; --0表示赛事报名，1表示赛事信息
	isClickClose = false;
}

MallSystemUI_2.MALL_DEFAULT_AVATAR_X = 25
MallSystemUI_2.MALL_RECOMMEND_AVATAR_X = -50
BP_Mall_2_AVATAR_X = MallSystemUI_2.MALL_DEFAULT_AVATAR_X

BP_STRUCT_AvatarInfo = 
{
    resID = 401999,
    colorID = 0,
    patternID = 0,
}

BP_ARRAY_AvatarList = 
{
    BP_STRUCT_AvatarInfo = _G.BP_STRUCT_AvatarInfo,
}

--商城角色
BP_STRUCT_MallSpawnPlayerData =
{
	gid = "",
	sex = 1,
	headId = 401999,
	index = 1,
	BP_ARRAY_AvatarList = _G.BP_ARRAY_AvatarList,
}

--头盔 护甲 背包 skin
BP_STRUCT_MallSpecialSkinData =
{
	bagSkin = 0,
	helmetSkin = 0,
	armorSkin = 0
}
--从大厅到商城or商城到大厅0
BP_MallSytem2_To_Lobby = 0;

BP_Mall_2_Refesh_Time = 0;
BP_Mall_2_Refesh_Time2 = 0;
BP_MALL_2_Cur_Refesh_Time = 0;

BP_Mall_First_Tab_Id = 0;

BP_Mall_2_Control_Btns_IsShow = false;

BP_MALL_MONEY_NUM = 0;
BP_MALL_MONEY_1_NUM = 0;
BP_MALL_DIAMOND_NUM = 0;
BP_MALL_FP_TOKEN_NUM = 0;

BP_Mall_2_Equip_ResID = 0;
--显示的itemid
BP_MALL_2_SHOW_ITEM_ID = 0;

BP_Mall_Hot_Point_FirstTab = 0;
BP_Mall_Hot_Point_IsShow = false;

--商城标签(定义结构体：当且仅当以BP_STRUCT_开头的table能作为结构体给蓝图访问)
BP_STRUCT_Mall_First_Tab_Info =
{
	id = 0,
	name = "",
	icon = "",
};
BP_ARRAY_Mall_First_Tab_List =
{
	BP_STRUCT_Mall_First_Tab_Info = _G.BP_STRUCT_Mall_First_Tab_Info;
}

-- --一系列需要预览的avatar
-- BP_ARRAY_Mall_Preview_Item_List =
-- {
-- 	Mall_Preview_ItemID = 0;
-- }

-- avatar变更信息
BP_STRUCT_Mall_AvatarChange =
{
    resId = 0,
    colorID = 0,
    patternID = 0,
}

--选中itemid
BP_Mall_Select_Item_Id = 0;
BP_Mall_Select_Item_Id_Limite = 0;
BP_Mall_Select_Item_IsCanSend = false;
BP_Mall_Cur_Select_SHOP_ID = 0;
BP_Mall_Cur_Select_SHOP_IsSellOut = false;
BP_Mall_Cur_Select_SHOP_SellType = 0;
BP_Mall_Cur_Select_SHOP_SellType2 = 0;
BP_Mall_Cur_Select_SHOP_Price = 0;
BP_Mall_Cur_Select_SHOP_Price2 = 0;
BP_Mall_Cur_Select_Item_Weared = false;

BP_MALL_WEAPON_AVATOR_STATE = 1;--枪械模型模式

BP_MALL_CURRENT_PREVIEW_SEX = 0;--当前预览的性别

BP_MALL_DEFAULT_PREVIEW_SEX = 0;--默认性别

--BP_Mall_Cur_Avatar_ResID = 0;

BP_Mall_Black_Bg_IsShow = false;
BP_Mall_SelectBtn_IsShow = false;

BP_Mall_PrimeShopItemTag = 0;	--订阅物品标识用于显示 0:非订阅物品 1：普通订阅物品 2：高级订阅物品
BP_Mall_CurPrimeStatus = 0;		--当前订阅状态NONE = 0没订阅 NormalStatus = 1普通订阅会员SuperStatus = 2,高级订阅会员BothStatus = 3,全部订阅
--商城子页面跳转相关
BP_Tab1_Number = 1;
local bIsJump = false;
local tab1 = 0;
local tab2 = 0;


local isGetTabInfo = false;
local isGetBuyInfo = false;
local itemInfoDict = nil;
local itemInfoIdDict = nil;
local setFirstSelectShopId = 0;
local page_list = nil;
local pageResDict = nil;
local buyInfo = nil;
local pageClassDict = nil;
local curPage = nil;
local curPageIndex = nil;
local selectShopItemDict = nil;
local isPlayOverStartMovie = false;
local isFirstSetPage = false;
BP_MallUIOpenFromRoleUI = false;
BP_MALL_SYSTEM_IS_SELECT_UPGRADE_ITEM = false;

GIFT_BOX_INDEX = 12;
SHOP_BOX_INDEX = 14;
DIY_SUIT_INDEX = 19;

Recommend_NEW_INDEX = 20;

local isInitTab = false;

--跳转子页签的协议为 game://?module=1003200&Tab1=3&Tab2=2&selectShopId=23001
--具体用法
--BP_Global_Url = "game://?module=1003200&Tab1=3&Tab2=5&selectShopId=23001"
--EventJumpUrl();
local isForceTab2 = false
local function JumpMallChild(eventType, eventID, vars)
	--老版商城跳转
	if StoreSystem.IsUseNewStore() then
		local function jumpToStore(param)
			local region = Client.GetPublishRegion();
			if region == "JAPAN" or region == "KOREA" then
				SupplyMainUI.JumpFromLobbyToSupply(param);
			else
				StoreMainUI.JumpFromLobbyToStore(param)
			end
		end

		if vars ~= nil then
			local itemId = vars.itemId or 0
			if itemId == 0 then
				local Tab1 = vars.Tab1 or 0
				if Tab1 == 0 then
					return
				else
					local para = {}
					para.Tab1 = tonumber(Tab1)
					para.Tab2 = 0

					jumpToStore(para);
				end
			else
				--没有跳转信息，去到对应页签
				if vars.Tab1 ~= nil and tonumber(vars.Tab1) == StoreSystem.Page_ID_Collect then
					local para = {}
					para.Tab1 = tonumber(vars.Tab1);
					para.Tab2 = 0;
					para.itemId = vars.itemId and tonumber(vars.itemId) or 0;
					para.bValid = true;

					jumpToStore(para);
				else
					local info = JumpUtils.FindJumpInfoAll(itemId)
					if info == nil then
						local para = {}
						para.Tab1 = 0
						para.Tab2 = 0

						jumpToStore(para);
					else
						JumpUtils.JumpAll(JumpUtils.MODEL_ID_LOBBY, itemId)
					end
				end
			end
		end
	else
		if vars ~= nil and vars.Tab1 ~= nil and vars.Tab2 ~= nil then
			--log_tree("xzx8 vars = ", vars);
			bIsJump = true;
			tab1 = tonumber(vars.Tab1)
			tab2 = tonumber(vars.Tab2)

			if vars.selectShopId ~= nil then
				setFirstSelectShopId = tonumber(vars.selectShopId);
			else
				setFirstSelectShopId = 0
			end

			if vars.isForceTab2 ~= nil then
				isForceTab2 = vars.isForceTab2
			else
				isForceTab2 = false
			end
		end
		--是否从个人信息UI跳转
		if(vars ~= nil and vars.isOpenFromRoleUI ~= nil) then
			BP_MallUIOpenFromRoleUI = vars.isOpenFromRoleUI;
		else
			BP_MallUIOpenFromRoleUI = false;
		end

		if(vars ~= nil and vars.isFromLeague ~= nil) then
			MallSystemUI_2.isFromLeague = vars.isFromLeague;
		else
			MallSystemUI_2.isFromLeague = 2;
		end
		EventOpenMallSystem();
	end
end

--bp_task.lua中打开bp宝箱
function MallSystemUI_2.TaskJumpBPBox()
	local bpBoxIndex = SHOP_BOX_INDEX;
	local bpBoxId  = ShopSystem.GoldBoxIndex;
	local url = "game://?module="..BP_ENUM_MODULE_MALL_CHILD.."&Tab1="..bpBoxIndex.."&Tab2="..bpBoxId
	--log("xzx bpBoxUrl = "..url)
	GlobalData:JumpUrl(url);
end

--BP_Global_Url = "game://?module=1003400&id=12345" 
local boxid = 0;
local function JumpMallBox(eventType, eventID, vars)
	if vars ~= nil and vars.targetPlayModel ~= nil then
		for k,v in pairs(ShopSystem.ItemInfoList) do
			if v.play_modle == vars.targetPlayModel then
				bIsJump = true;
				boxid = tonumber(k);

				tab1 = SHOP_BOX_INDEX;
				tab2 = boxid;
				--log("JumpMallBox find targetPlayModel : " .. vars.targetPlayModel .. "||shopID: " .. k);
				EventOpenMallSystem();
				return;
			end
		end
	end

	if vars ~= nil and vars.id ~= nil then
		bIsJump = true;
		boxid = tonumber(vars.id);

		tab1 =  SHOP_BOX_INDEX;
		tab2 = boxid;

		EventOpenMallSystem();
	end
end

local function ChildJumpChild(eventType, eventID, vars)
	if vars ~= nil and vars.Tab1 ~= nil and vars.Tab2 ~= nil then
		--log_tree("xzx8 vars = ", vars);
		bIsJump = true;
		tab1 = tonumber(vars.Tab1)
		tab2 = tonumber(vars.Tab2)
		
		if vars.selectShopId ~= nil then
			setFirstSelectShopId = tonumber(vars.selectShopId);
			
		else
			setFirstSelectShopId = 0
		end
	end
	LuaClassObj.HandleUIMessage(bp_mall_system_2, "InitTabBtn");
	LuaClassObj.HandleUIMessage(bp_mall_system_2, "UpdateTabList");
end


function bp_mall_system_2_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_mall_system_2,
	{
		{Path="/Game/UMG/UI_Logic/Lobby_Store/Store_2/Lobby_MallSystem_Logic_2_BP.Lobby_MallSystem_Logic_2_BP_C", Container="Default", ZOrder=0}
	--{Path="/Game/UMG/UI_BP/Lobby/Lobby_MallSystemAnim_2_UIBP.Lobby_MallSystemAnim_2_UIBP_C", Container="Default", ZOrder=BP_ENUM_UI_COMMON_ITEM_GET_ZORDER}
	},
	{"Lobby"},
	false,
	true
	);

	EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_MALL, MallSystemUI_2.OnJumpUrl);
	EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_MALL_CHILD, JumpMallChild);
	EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_MALL_BOX, JumpMallBox);
	EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_MALL_CHILD_JUMP_CHILD, ChildJumpChild);
	
	pageClassDict = {};
	pageClassDict[11] = MallSaleUI;
	pageClassDict[GIFT_BOX_INDEX] = StoreGiftBox_UI;
	pageClassDict[13] = MallPageCommonUI_2;
	pageClassDict[SHOP_BOX_INDEX] = StoreBox_UI;
	pageClassDict[15] = MallPageCommonUI_2;
	pageClassDict[16] = MallPageCommonUI_2;
	pageClassDict[17] = MallPageCommonUI_2;
	pageClassDict[18] = MallPageCommonUI_2;
	pageClassDict[DIY_SUIT_INDEX] = MallPageDiyUI;
	pageClassDict[Recommend_NEW_INDEX] = MallRecommendUI;
end

function bp_mall_system_2_OnModeSwitched(gamestatus)
	log("bp_mall_system_2_OnModeSwitched gamestatus = " .. gamestatus);
	status = string.lower(gamestatus);
	if status == "lobby" then
		if MallSystemUI_2.isShowing == true then
			--hide
			UIManager.Hide(eUIType.eStoreUI)
			LuaClassObj.HandleUIMessage(bp_mall_system_2, "UIHideMallSystem");
			MallSystemUI_2:Release();
		end

		MallSystemUI_2.isShowing = false;
		OpenBoxtUI.isShow = false;
		BP_MallSytem2_To_Lobby = 0;
	else
		BP_MallSytem2_To_Lobby = 0;
	end

	-- 回到登录场景清数据
    if string.lower(gamestatus) == "login" then
		
		if MallSystemUI_2.isShowing == true then
			MallSystemUI_2:ReleaseData();			
		end
		MallSystem.Release();
		OpenBoxtUI.isShow = false;
    end

end

-- 登出、重连返回登录清除数据
local function ReleaseAllData(eventType, eventID, vars)
    log("ReleaseAllData "..eventType)
	if eventType ~= EVENTTYPE_LOGIN then
		return;
	end

	if eventID == EVENTID_BACKLOGIN then
        MallSystemUI_2:ReleaseData();
	end
end

local function PlayerDataChange(eventType, eventID, vars)
	if eventType ~= EVENTTYPE_DATA_MGR then
		return;
	end

    -- 更新数据
    MallSystemUI_2:RefreshPlayerData();
end

local function InitTabList(eventType, eventID, vars)
	if isInitTab then
		return;
	end
	--log("UpdateTabList "..eventType)
	if eventType ~= EVENTTYPE_MALL then
		return;
	end

	if eventID == EVENTID_MALL_TAB_RES_UPDATE then
		isGetTabInfo = true;
		pageResDict = vars[1];
		--当礼包没有需要关闭tab
		for i,v in pairs(pageResDict) do
			if i == GIFT_BOX_INDEX and #ShopSystem.BoxGiftList == 0 then
				v.isOpen = 0;
			end
		end
		
		--距离刷新时间
		BP_Mall_2_Refesh_Time = vars[2];
		BP_Mall_2_Refesh_Time2 = vars[3];
		--log("EVENTID_MALL_TAB_RES_UPDATE :" .. BP_Mall_2_Refesh_Time);
		--log("EVENTID_MALL_TAB_RES_UPDATE2 :" .. BP_Mall_2_Refesh_Time2);
		LuaClassObj.HandleUIMessage(bp_mall_system_2, "SetRefeshMallRun");
		
	elseif eventID == EVENTID_MALL_BUY_INFO_UPDATE then
		isGetBuyInfo = true;
		buyInfo = vars;
	end

	if isGetTabInfo and isGetBuyInfo then
		isInitTab = true;
		LuaClassObj.HandleUIMessage(bp_mall_system_2, "UpdateTabList");
	end
end

local function OnGetPageItemInfo(eventType, eventID, vars )
	local page = vars[1];
	local list = vars[2];
	local dict = {};
	local page1Id = nil;
	local page2Id = nil;
	for i,v in pairs(list) do
		page2Id = v.page % 100;
		if dict[page2Id] == nil then
			dict[page2Id] = {};
		end
		dict[page2Id][v.id] = v;
		itemInfoIdDict[v.id] = v;
		--新增:代金券商品ID 缓存
		if v.voucher and next(v.voucher)then
			log_tree("zino v.voucher", v.voucher);
			Logic_ARRAY_CouponsMallID[v.id] = v.voucher		
		end
	end
	itemInfoDict[page] = dict;
	-- log_tree("OnGetPageItemInfo1",list);
	-- log_tree("OnGetPageItemInfo2",itemInfoIdDict);
	-- log_tree("OnGetPageItemInfo3",itemInfoDict);


	EventMallUpdateTabInfo();
end

local function OnBuyInfoChange(eventType, eventID, vars)
	if buyInfo == nil then
		return;
	end
	local tempList = {};
	for i,v in pairs(vars) do
		buyInfo[i] = v;
		local itemInfo = itemInfoIdDict[i];
		if itemInfo ~= nil then
			table.insert(tempList, itemInfo);
		end
	end
	local pageCls = MallSystemUI_2.GetCurClass(BP_Mall_First_Tab_Id)
	if pageCls ~= nil and pageCls.DynamicUpdate ~= nil then
		pageCls.DynamicUpdate(tempList);
	end
	MallSystemUI_2.SelectEquip(BP_Mall_Cur_Select_SHOP_ID, false)
end

local function OnMallBuySuc(eventType, eventID, vars)
	local isSuc = vars[1];
	local itemList = vars[2];
	if isSuc then
		local tempList = {};
		for i,v in pairs(itemList) do
			local shopId = v.shop_id;
			local itemInfo = itemInfoIdDict[shopId];
			if itemInfo ~= nil then
				table.insert(tempList, itemInfo);
			end
		end
		local pageCls = MallSystemUI_2.GetCurClass(BP_Mall_First_Tab_Id)
		if pageCls ~= nil and pageCls.DynamicUpdate ~= nil then
			pageCls.DynamicUpdate(tempList);
		end
	end
	MallSystemUI_2.SelectEquip(BP_Mall_Cur_Select_SHOP_ID, false)
end

local function OnMonthCardChange(eventType, eventID, vars)
end

local function OnTeamInfoChange(eventType, eventID, vars)
	EventStartCloseMallSystem();
end

local function localText(id)
    local data = Client.GetTableData("LocalizeRes",id);
    if data then
        return data.TextValue
    end
    return ""
end


local function OnShopBoxCountUpdate(eventType, eventID, vars)
	local len = vars;
	--log("OnShopBoxCountUpdate:" .. len);
	shopBox2rdNum = len;
	LuaClassObj.HandleUIMessage(bp_mall_system, "RefreshChangeTab");
end

local function OnLoginSuccess(evenType, eventID, isRelogin)
	if isRelogin then
		if MallSystemUI_2.isShowing == true then
			--reconnect success
			MallSystemUI_2.UpdateStoreData();
		end
	end
end

function MallSystemUI_2.UpdateStoreData()
	local currentOpenedUI = Client.GetCurrentOpenedUI();
	if currentOpenedUI == "OpenBox_BP_C" then
		OpenBoxtUI.HidePanel();
		log("[HHF]MallSystemUI_2.UpdateStoreData, StoreInfo have updated, Close OpenBox.")
	end

	for i,v in pairs(pageClassDict) do
		if v.Release ~= nil then
			v.Release();
		end
	end
	MallSystemUI_2:RefreshPlayerData();
	isFirstSetPage = true;
	isGetTabInfo = false;
	isGetBuyInfo = false;
	itemInfoDict = {};
	itemInfoIdDict = {};
	selectShopItemDict = {};
	MallSystem.Enter();
	MallSystemUI_2.SetBalckBgShow(false);
	isInitTab = false;
	curPage = nil
end

function MallSystemUI_2:Init()

	if MallSystemUI_2.isShowing then
		return;
	end
	BP_MALL_CURRENT_PREVIEW_SEX = DataMgr.avatarData.gamegender;
	BP_MALL_DEFAULT_PREVIEW_SEX = DataMgr.avatarData.gamegender;
	BP_MallSytem2_To_Lobby = 1;
	--log("MallSystemUI_2 Init");
	MallSystemUI_2.isShowing = true;
	--hide 所有的主界面
	EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN);
	
	--LuaClassObj.HandleUIMessage(bp_mall_system_2, "UIShowMallAvatarAni");
	PanelOpenCloseAnimSystem.OpenView("EventEnterMallSystem", "EventExitMallSystem");
	LuaClassObj.HandleUIMessage(bp_mall_system_2, "SwitchCameraMall");
	
	MallSystemUI_2.isMallCamera = true;
	MallSystemUI_2.isRoleInMall = true;
	
	
	
	--log("DataMgr.avatarData.gamegender = "..tostring(DataMgr.avatarData.gamegender));
end

--初始化在这写
function MallSystemUI_2:Show()
	LuaClassObj.HandleDynamicCreation(bp_mall_system_2);

	-- 请求下玩家头像数据，因为有道商品需要标识已拥有，而头像数据不在仓库里，
	-- 所以这里单独请求
	RoleInfoHeadportraitSystem.get_headportrait_list();
	--log("MallSystemUI_2 Show");
	--avatar数据
	MallSystemUI_2.currentWearPreviewMap = {};
	MallSystemUI_2.currentWearBackpackMap = {};
	MallSystemUI_2:CreateMyself();
	--移动角色到商城
	--LuaClassObj.HandleUIMessage(bp_lobby, "EndLobbyToMall");
	LuaClassObj.HandleUIMessage(bp_mall_system_2, "UIShow");
	UIManager.Show(eUIType.eStoreUI)

	MallSystemUI_2.isMallCamera = true;
	MallSystemUI_2.isRoleInMall = true;	
	
	MallSystemUI_2:RefreshPlayerData();

	EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_GOLD_CHANGE, PlayerDataChange);
	EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_TICKET_CHANGE, PlayerDataChange);
	EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_FP_TOKEN_CHANGE, PlayerDataChange);
	EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_DIAMOND_CHANGE, PlayerDataChange);
	EventSystem:registEvent(EVENTTYPE_LOGIN, EVENTID_BACKLOGIN, ReleaseAllData);
    EventSystem:registEvent(EVENTTYPE_LOGIN, EVENTID_LOGIN_SUCCESS, OnLoginSuccess);
	EventSystem:registEvent(EVENTTYPE_MALL, EVENTID_MALL_TAB_RES_UPDATE, InitTabList);
	EventSystem:registEvent(EVENTTYPE_MALL, EVENTID_MALL_BUY_INFO_UPDATE, InitTabList);
	EventSystem:registEvent(EVENTTYPE_MALL, EVENTID_MALL_BUY_INFO_CHANGE, OnBuyInfoChange);
	EventSystem:registEvent(EVENTTYPE_MALL, EVENTID_MALL_PAGE_ITEM_INFO_UPDATE, OnGetPageItemInfo);
	EventSystem:registEvent(EVENTTYPE_MALL, EVENTID_MALL_BUY_RESULT, OnMallBuySuc);
	EventSystem:registEvent(EVENTTYPE_MALL, EVENTID_MALL_MONTH_CARD_REFRESH_HOT, OnMonthCardChange);
	-- EventSystem:registEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_SYNC, OnTeamInfoChange);
	
	LuaClassObj.HandleUIMessage(bp_mall_system_2, "HideAllPlayer");
	
	isFirstSetPage = true;
	isGetTabInfo = false;
	isGetBuyInfo = false;
	itemInfoDict = {};
	itemInfoIdDict = {};
	selectShopItemDict = {};
	MallSystem.Enter();
	MallSystemUI_2.SetBalckBgShow(false);

	isInitTab = false;

end

function ShowOldStoreMainUI()
	UIManager.Show(eUIType.eStoreUI)
end

function MallSystemUI_2:Release()
	for i,v in pairs(pageClassDict) do
		if v.Release ~= nil then
			v.Release();
		end
		if v.Hide ~= nil then
			v.Hide();
		end
	end

	BP_MALL_WEAPON_AVATOR_STATE = 1;
	curPageIndex = nil;
	curPage = nil;
	itemInfoDict = nil;
	itemInfoIdDict = nil;
	page_list = nil;
	buyInfo = nil;
	MallSystemUI_2.isShowing = false;
	MallSystemUI_2.isRoleInMall = false;
	--[[MallSystemUI_2:RevertAvatar();
		
	local weaponID = DataMgr.GetCurrentWeaponID();
	if weaponID == 0 then
		LobbyUI:UnEquipWeapon(DataMgr.roleData.uid);
	else
		LobbyUI:EquipWeapon(DataMgr.roleData.uid,weaponID);
	end--]]
	
	LuaClassObj.HandleUIMessage(bp_mall_system_2, "DestroyPlayers");
	
	MallSystemWeaponModelHandler:DestroyWeaponShowActor();
	
	EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_GOLD_CHANGE, PlayerDataChange);
	EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_TICKET_CHANGE, PlayerDataChange);
	EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_FP_TOKEN_CHANGE, PlayerDataChange);
	EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_DIAMOND_CHANGE, PlayerDataChange);
	EventSystem:unregistEvent(EVENTTYPE_LOGIN, EVENTID_BACKLOGIN, ReleaseAllData);
    EventSystem:unregistEvent(EVENTTYPE_LOGIN, EVENTID_LOGIN_SUCCESS, OnLoginSuccess);
	EventSystem:unregistEvent(EVENTTYPE_MALL, EVENTID_MALL_TAB_RES_UPDATE, InitTabList);
	EventSystem:unregistEvent(EVENTTYPE_MALL, EVENTID_MALL_BUY_INFO_UPDATE, InitTabList);
	EventSystem:unregistEvent(EVENTTYPE_MALL, EVENTID_MALL_BUY_INFO_CHANGE, OnBuyInfoChange);
	EventSystem:unregistEvent(EVENTTYPE_MALL, EVENTID_MALL_PAGE_ITEM_INFO_UPDATE, OnGetPageItemInfo);
	EventSystem:unregistEvent(EVENTTYPE_MALL, EVENTID_MALL_BUY_RESULT, OnMallBuySuc);
	EventSystem:unregistEvent(EVENTTYPE_MALL, EVENTID_MALL_MONTH_CARD_REFRESH_HOT, OnMonthCardChange);
	-- EventSystem:unregistEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_SYNC, OnTeamInfoChange);
	-- EventSystem:unregistEvent(EVENTTYPE_MALL, EVENTID_MALL_UPDATE_BOX_COUNT, OnShopBoxCountUpdate);
	-- 这里清除下头像数据，因为进来时请求过
	RoleInfoHeadportraitSystem.Release();
	MallSystem.ClearBuyRecord();
end

function MallSystemUI_2:ReleaseData()
	MallSystemUI_2:Release();
end

function MallSystemUI_2:OnJumpUrl()
	log("[TAL]跳转到真商城界面");
	EventOpenMallSystem()
end

-- 更新玩家数据
function MallSystemUI_2:RefreshPlayerData()
	BP_MALL_MONEY_NUM = DataMgr.gold;
	BP_MALL_MONEY_1_NUM = DataMgr.diamond;
	BP_MALL_DIAMOND_NUM = DataMgr.ticket;
	BP_MALL_FP_TOKEN_NUM = DataMgr.fp_token;

    LuaClassObj.HandleUIMessage(bp_mall_system_2, "UpdatePlayerData");
end

function MallSystemUI_2.GetCurClass(firstTab)
	return pageClassDict[firstTab];
end

function MallSystemUI_2.GetPageDatas(firstTab)
	if itemInfoDict == nil or itemInfoDict[firstTab] == nil then
		return {};
	end
	return itemInfoDict[firstTab];
end

function MallSystemUI_2.GetShopInfoByShopId(shopId)
	return itemInfoIdDict[shopId];
end

function MallSystemUI_2.GetSencondTabInfo(firstTab)
	if pageResDict == nil or pageResDict[firstTab] == nil then
		return {};
	end
	return pageResDict[firstTab];
end

function MallSystemUI_2.CheckFirstTabIsExited(firstTab)
	return pageResDict[firstTab] ~= nil;
end


function MallSystemUI_2.HideEquipDescript()
	LuaClassObj.HandleUIMessage(bp_mall_system_2, "HideEquipDescript");
end

function MallSystemUI_2.SetWeaponShowState(status)
	BP_MALL_WEAPON_AVATOR_STATE = status;
end

--isTakeOff 是否需要选中但不脱下（特殊需求。。）
function MallSystemUI_2.SelectEquip(shopId, isTakeOff)
	if DIY_SUIT_INDEX == BP_Mall_First_Tab_Id or Recommend_NEW_INDEX == BP_Mall_First_Tab_Id then
		return
	end
	log("MallSystemUI_2.SelectEquip：" .. shopId)
	BP_Mall_Cur_Select_SHOP_ID = shopId;
	local marketData = itemInfoIdDict[shopId];
	if marketData == nil then
		log("MallSystemUI_2.SelectEquip,no marketData");
		return;
	end
	local resItem = Client.GetTableData("Item",marketData.item_id);
	if resItem == nil then
		log("MallSystemUI_2.SelectEquip,no resItem");
		return;
	end
	local shopItemData = MallSystemUI_2.MarketData2ItemData(marketData);
	local pageCls = MallSystemUI_2.GetCurClass(BP_Mall_First_Tab_Id)
	local isAvator = resItem.ItemType == 4 and math.floor(resItem.ItemSubType / 100) == 4;
	local isNoShow = false;
	if MallSystemUI_2.GetCurClass(BP_Mall_First_Tab_Id) == MallPageCommonUI_2 then
		MallSystemUI_2.HideSex()
	end
	
	-- 统一切换回人物显示模式
	MallSystemUI_2.SwitchWeaponShowType(0)
		
	--记录可穿戴数据，供多个购买使用
	if isAvator  then
		--如果已经试穿则脱下
		isNoShow = shopId == selectShopItemDict[resItem.ItemSubType] and isTakeOff == false;
		if shopId == selectShopItemDict[resItem.ItemSubType] and isTakeOff then
			selectShopItemDict[resItem.ItemSubType] = nil;
			if pageCls ~= nil and pageCls.SetEquip ~= nil then
				pageCls.SetEquip(shopId, false);
			end
		else
			if selectShopItemDict[resItem.ItemSubType] ~= nil then
				if pageCls ~= nil and pageCls.SetEquip ~= nil then
					pageCls.SetEquip(selectShopItemDict[resItem.ItemSubType], false);
				end
			end
			selectShopItemDict[resItem.ItemSubType] = shopId;
			if pageCls ~= nil and pageCls.SetEquip ~= nil then
				pageCls.SetEquip(selectShopItemDict[resItem.ItemSubType], true);
			end
		end

		if MallSystemUI_2.GetCurClass(BP_Mall_First_Tab_Id) == MallPageCommonUI_2 then
			MallSystemUI_2.ShowSex()
		end
		
	elseif resItem.ItemType == 4 and math.floor(resItem.ItemSubType / 100) == 7 then
		
	elseif resItem.ItemType == 8 and resItem.ItemSubType == 801 then--飞机
		
	elseif resItem.ItemType == 15 and resItem.ItemSubType == 1501 then--宝箱
		
	elseif resItem.ItemType == 22 then--表情
		
	else
		
	end
	--购买成功后的特殊刷新
	if isTakeOff == false and pageCls ~= nil and pageCls.SetItemSelect ~= nil then
		pageCls.SetItemSelect();
	end
	if not isNoShow then
		MallSystemUI_2.ShowItem(marketData.item_id);
	end
	
	BP_Mall_Select_Item_Id = marketData.item_id;
	BP_Mall_Select_Item_Id_Limite = shopItemData.limitCount;
	BP_Mall_Select_Item_IsCanSend = shopItemData.isCanSend;
	BP_Mall_Cur_Select_SHOP_IsSellOut = shopItemData.limitCount <= 0; 
	BP_Mall_Cur_Select_SHOP_SellType = shopItemData.moneyType;
	BP_Mall_Cur_Select_SHOP_SellType2 = shopItemData.moneyType2;
	BP_Mall_Cur_Select_SHOP_Price = shopItemData.moneyPrice;
	BP_Mall_Cur_Select_SHOP_Price2 = shopItemData.moneyPrice2;
	BP_Mall_Cur_Select_Item_Weared = MallSystemUI_2:IsWear(BP_Mall_Select_Item_Id)
	
	if resItem.ItemType == 1 then
		BP_MALL_WEAPON_AVATOR_STATE = 1;
	end
	--订阅添加
	log("shopItemData.PrimeItemStatus ".. tostring(shopItemData.PrimeItemStatus))
	if shopItemData.PrimeItemStatus > 0 then 
		BP_Mall_PrimeShopItemTag = shopItemData.PrimeItemStatus
	else
		BP_Mall_PrimeShopItemTag = 0
	end
	BP_Mall_CurPrimeStatus = NewSubscribeSystem.GetSubStatus()
	LuaClassObj.HandleUIMessage(bp_mall_system_2, "HideEquipDescript");
	LuaClassObj.HandleUIMessage(bp_mall_system_2, "LuaShowSelectShopItem");
		
end

function MallSystemUI_2.UpdateSelectItemDes()
	local shopId = BP_Mall_Cur_Select_SHOP_ID;
	if BP_Mall_Cur_Select_SHOP_ID <= 0 then
		return;
	end
	local marketData = itemInfoIdDict[shopId];
	if marketData == nil then
		log("MallSystemUI_2.SelectEquip,no marketData");
		return;
	end
	local shopItemData = MallSystemUI_2.MarketData2ItemData(marketData);
	BP_Mall_Select_Item_Id = marketData.item_id;
	BP_Mall_Select_Item_Id_Limite = shopItemData.limitCount;
	BP_Mall_Select_Item_IsCanSend = shopItemData.isCanSend;
	BP_Mall_Cur_Select_SHOP_IsSellOut = shopItemData.limitCount <= 0; 
	BP_Mall_Cur_Select_SHOP_SellType = shopItemData.moneyType;
	BP_Mall_Cur_Select_SHOP_Price = shopItemData.moneyPrice;
	--订阅标识
	log("shopItemData.PrimeItemStatus ".. tostring(shopItemData.PrimeItemStatus))
	if shopItemData.PrimeItemStatus > 0 then 
		BP_Mall_PrimeShopItemTag = shopItemData.PrimeItemStatus
	else
		BP_Mall_PrimeShopItemTag = 0
	end
	BP_Mall_CurPrimeStatus = NewSubscribeSystem.GetSubStatus()
	LuaClassObj.HandleUIMessage(bp_mall_system_2, "LuaShowSelectShopItem");
end

function MallSystemUI_2.MarketData2ItemData(marketData, colorID, patternID)
	colorID = colorID or 0;
	patternID = patternID or 0;
	local resItem = Client.GetTableData("Item",marketData.item_id);
	if resItem == nil then
		log("no itemCfg :" .. marketData.item_id)
		return nil;
	end
	-- 购买数量
	local itemBuyInfo = MallSystemUI_2.GetItemBuyInfo(marketData.id);
	local buyNum = 1000000;
	local limitType = 1;
	if (marketData.daily_buy_limit > 0 or marketData.week_buy_limit > 0 or marketData.permanet_buy_limit > 0) then
		if itemBuyInfo ~= nil then
			if (marketData.daily_buy_limit > 0) then
				buyNum = math.min(buyNum, marketData.daily_buy_limit - itemBuyInfo.daily_buy_cnt);
				limitType = 1;
			end
			if (marketData.week_buy_limit > 0) then
				buyNum = math.min(buyNum, marketData.week_buy_limit - itemBuyInfo.week_buy_cnt);
				limitType = 2;
			end
			if (marketData.permanet_buy_limit > 0) then
				buyNum = math.min(buyNum, marketData.permanet_buy_limit - itemBuyInfo.permanet_buy_cnt);
				limitType = 3;
			end
		end
	end
	--实际价钱个类型
	local moneyType,moneyPrice = MallSystemUI_2.get_money_type_and_price(marketData.id, 1, marketData);
	local moneyType2,moneyPrice2 = MallSystemUI_2.get_money_type_and_price(marketData.id, 0, marketData);
	local serverTime = FuncUtil.GetServerTimeInSec();
	local item = {
			shopID = marketData.id;
			itemID = marketData.item_id;
			count = marketData.item_count;
			quality = resItem.ItemQuality;
			limitCount = buyNum;
			itemName = resItem.ItemName;
			itemIcon = (marketData.icon_name ~= nil and marketData.icon_name ~= "") and marketData.icon_name or resItem.ItemSmallIcon;
			isNew = marketData.title_new == 1;
			isHot = marketData.title_hot == 1;
			priceType = marketData.money1_type;
			price = marketData.money1_price;
			discountPrice = marketData.permanet_discount_price1;
			discountLimitPrice = marketData.timelimit_discount_price1;
			discountLimitStartTime = marketData.timelimit_discount_begin_time - serverTime;
			discountLimitEndTime = marketData.timelimit_discount_end_time - serverTime;
			saleLimitTime = marketData.sale_end_time - serverTime;
			discount = marketData.off_rate;
			isLimit = marketData.sale_begin_time ~= 0 and marketData.sale_end_time ~= 0 and marketData.show_limit_time ~= 0;
			isDiscountLimit = marketData.timelimit_discount_begin_time ~= 0 and marketData.timelimit_discount_end_time ~= 0;
			discountLimit = marketData.timelimit_off_rate;
			isEquip = MallSystemUI_2.IsSelectEquip(marketData.id);
			isSelect = false;
			isGet = MallSystemUI_2.IsHasItem(marketData.item_id, colorID, patternID);
			isCanSend = marketData.gift_open == 1;

			--排序相关
			shop_rank = marketData.shop_rank;
			sale_begin_time = marketData.sale_begin_time;
			limitType = limitType;
			moneyType = moneyType;
			moneyPrice = moneyPrice;
			moneyType2 = moneyType2;
			moneyPrice2 = moneyPrice2;
			itemType = resItem.ItemType;
			specialIcon = resItem.SpecialIcon;
		};

	local now = FuncUtil.GetServerTimeInSec();

	if marketData.permanet_discount_begin_time == 0 or now < marketData.permanet_discount_begin_time then
		--log("mickey:" .. now);
		item.discount = 0;
	end
	
	--代金券添加
	if marketData.voucher and next(marketData.voucher) then
		item.isUseCoupons = true
	end
	--订阅添加
	if marketData.isnormalPrime then 
		item.PrimeItemStatus = 1
	
	elseif marketData.isPlusPrime then 
		item.PrimeItemStatus = 2
	else
		item.PrimeItemStatus = 0
	end	
	item.CurPrimeStatus = NewSubscribeSystem.GetSubStatus()
	return item;
end

function MallSystemUI_2.GetItemBuyInfo(shopId)
	if buyInfo == nil then
		return;
	end
	if buyInfo[shopId] == nil then
		buyInfo[shopId] = {
			daily_buy_cnt = 0;
			week_buy_cnt = 0;
			permanet_buy_cnt = 0;
		};
	end
	return buyInfo[shopId];
end

function MallSystemUI_2.get_money_type_and_price(id, is_first_money, shopInfo, time_valid_index)
    local node = shopInfo == nil and itemInfoIdDict[id] or shopInfo;

	local money_type = node.money1_type
	local money_price = node.money1_price
	if is_first_money == 1 then
		money_type = node.money1_type
		if not time_valid_index or time_valid_index == 1 then
			money_price = node.money1_price
		elseif time_valid_index == 2 then
			money_price = node.money1_price2
		elseif time_valid_index == 3 then
			money_price = node.money1_price3
		end
	else
		money_type = node.money2_type
		if not time_valid_index or time_valid_index == 1 then
			money_price = node.money2_price
		elseif time_valid_index == 2 then
			money_price = node.money2_price2
		elseif time_valid_index == 3 then
			money_price = node.money2_price3
		end
	end

    local now = FuncUtil.GetServerTimeInSec();
    if node.permanet_discount_begin_time ~= 0 and node.permanet_discount_begin_time ~= "" then
        local start_tm = node.permanet_discount_begin_time;
        if now >= start_tm then
            if  is_first_money ~= 1 then
                money_price = node.permanet_discount_price2
            else
                money_price = node.permanet_discount_price1
            end
        end
    end

	    -- 限时折扣必须同时配置开始、结束时间，才算生效
    if node.timelimit_discount_begin_time ~= "" and node.timelimit_discount_begin_time ~= 0 and node.timelimit_discount_end_time ~= "" and node.timelimit_discount_end_time ~= 0 then
        local start_tm = node.timelimit_discount_begin_time
        local end_tm = node.timelimit_discount_end_time
        if now >= start_tm and now <= end_tm then
            if is_first_money ~= 1 then
                money_price = node.timelimit_discount_price2
            else
                money_price = node.timelimit_discount_price1
            end
        end
    end

	return money_type, money_price
end

function MallSystemUI_2.get_color_and_pattern_cost(colorID, patternID)
	local cost = 0;

	log("get_color_and_pattern_cost  colorID, patternID:  "..tostring(colorID)..",  "..tostring(patternID))
	if (colorID == nil or colorID == 0) and (patternID == nil or patternID == 0) then
		return cost;
	end
	local colorCfg = Client.GetTableData("DiySuitColorConfig",colorID);
	if colorCfg ~= nil then
		cost = cost + colorCfg.Cost;
	else
		log("colorCfg = nil")
	end

	local patternCfg = Client.GetTableData("DiySuitPatternConfig",patternID);
	if patternCfg ~= nil then
		cost = cost + patternCfg.Cost;
	else
		log("patternCfg = nil")
	end
	log("cost---"..tostring(cost))
	return cost;
end

function MallSystemUI_2.IsSelectEquip(shopId)
	local marketData = itemInfoIdDict[shopId];
	if marketData == nil then
		return false;
	end
	local resItem = Client.GetTableData("Item",marketData.item_id);
	if resItem == nil then
		return false;
	end
	return selectShopItemDict[resItem.ItemSubType] == shopId;
end

function MallSystemUI_2.IsHasItem(itemId, colorID, patternID)
	for i,v in pairs(DataMgr.arrayHallDepotItemInfo) do
		if v.resID == itemId and (v.colorID == nil or v.colorID == colorID) and (v.patternID == nil or v.patternID == patternID) then
			return true;
		end
	end
	-- 头像数据
	if RoleInfoHeadportraitSystem.HeadportraitList[tostring(itemId)] then
		return true;
	end
	if MallSystem.IsInBuyRecord(itemId, colorID, patternID) then
		return true;
	end
	return false;
end

function MallSystemUI_2.IsIgnoreTab1(tab1)
	return tab1 == DIY_SUIT_INDEX;
end

function MallSystemUI_2.SortList(dataList, sortType)
	log("zino whatsortType " .. tostring(sortType))
	if sortType == 0 then
		table.sort(dataList, function (a, b)
			if a.shop_rank == b.shop_rank then
				if a.quality == b.quality then
					if a.sale_begin_time == b.sale_begin_tim then
						return a.shopID > b.shopID;
					else
						return a.sale_begin_time > b.sale_begin_time;
					end
				else
					return a.quality > b.quality;
				end
			else
				return a.shop_rank > b.shop_rank;
			end
		end);
		--上架升
	elseif sortType == 1 then
		table.sort(dataList, function (a, b)
			return a.sale_begin_time > b.sale_begin_time;
		end);
		--上架降
	elseif sortType == 2 then
		table.sort(dataList, function (a, b)
			return a.sale_begin_time < b.sale_begin_time;
		end);
		--价格升
	elseif sortType == 3 then
		table.sort(dataList, function (a, b)
			return a.moneyPrice > b.moneyPrice;
		end);
		--价格降
	elseif sortType == 4 then
		table.sort(dataList, function (a, b)
			return a.moneyPrice < b.moneyPrice;
		end);
		--品质升
	elseif sortType == 5 then
		table.sort(dataList, function (a, b)
			return a.quality > b.quality;
		end);
		--品质降
	elseif sortType == 6 then
		table.sort(dataList, function (a, b)
			return a.quality < b.quality;
		end);
	end
end

function MallSystemUI_2.OpenBuySingleItemWin(shopId, colorID, patternID, itemInfo, version)
	log("zino shopid : " .. shopId)
	log("colorID, patternID"..tostring(colorID)..",  "..tostring(patternID))
	local data = itemInfo or itemInfoIdDict[shopId];
	if data == nil then
		return;
	end

	--log_tree("OpenBuySingleItemWin：",data)
	
	local resItem = Client.GetTableData("Item",data.item_id);
	local buyInfo = MallSystemUI_2.GetItemBuyInfo(shopId);
	--策划规定的类型
	if resItem.ItemType == 15 or resItem.ItemType == 21 or resItem.ItemType == 26 then
		MallBuyItemWithCountUI:Init();
		MallBuyItemWithCountUI.SetData(data,buyInfo,colorID,patternID, version);
	else
		if MallSystemUI_2.GetCurClass(BP_Mall_First_Tab_Id) == MallPageDiyUI then
			MallBuyItemUI:Init();
			MallBuyItemUI.SetData(data, buyInfo, colorID, patternID, version);
		else
			StoreBuyUI:Init();
			StoreBuyUI.SetData(data, buyInfo, colorID, patternID, version);
		end
	end

end

function MallSystemUI_2.MallSendShopItem(shopId, colorID, patternID, marketInfo)
	local shopInfo = marketInfo or MallSystemUI_2.GetShopInfoByShopId(shopId);
	local buyInfo = MallSystemUI_2.GetItemBuyInfo(shopId);
	MallSystemUI_2.SendShopItem(shopInfo,buyInfo, colorID, patternID);
end

--赠送(全局)
function MallSystemUI_2.SendShopItem(shopInfo,buyInfo,colorID,patternID)
	local data = shopInfo;
	local resItem = Client.GetTableData("Item",data.item_id);
	local isGet = MallSystemUI_2.IsHasItem(data.item_id, colorID, patternID);
	local moneyType,moneyPrice = MallSystemUI_2.get_money_type_and_price(data.id, 1, data);

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
	--[[if 1 > limitCount then
		if limitType == 1 then
			DataMgr.ShowNoticeByID(4350);
		elseif limitType == 2 then
			DataMgr.ShowNoticeByID(4351);
		elseif limitType == 3 then
			DataMgr.ShowNoticeByID(4352);
		end
		return;
	end]]--
	ShopGiftUI:ShowGiftPanel (data, moneyType, FuncUtil.GetItemName(resItem.ItemName, colorID, patternID), colorID, patternID);
end

function MallSystemUI_2.GetFirstTabHotPointState(firstTab)
	local cls =  MallSystemUI_2.GetCurClass(firstTab);
	local dataList = MallSystemUI_2.GetPageDatas(firstTab)
	local tabInfo = MallSystemUI_2.GetSencondTabInfo(firstTab);
	if cls ~= nil and cls.GetHotState ~= nil then
		return cls.GetHotState(firstTab, dataList, tabInfo);
	end
	return false;
end

function MallSystemUI_2.UpdateFirstTabHotState()
	LuaClassObj.HandleUIMessage(bp_mall_system_2, "UpdateFirstHot")
end


function EventMall2OpenDiamondUI()
	RechargeUI:Init();
end


-- 创建自己的模型
function MallSystemUI_2:CreateMyself()
	local rolewear = {}
	--WardrobeSystem.UpdateInvalidWearInfo(nil);
	
	for k,v in pairs(DataMgr.rolewear) do
		local itemData = DataMgr.GetHallDepotItemDataByInsID(v);
		if itemData ~= nil then
			table.insert(rolewear, LobbyUI.CreateClientAvatarWearInfo(itemData.resID, itemData.colorID, itemData.patternID));
			MallSystemUI_2:AddToWearInfo(itemData.itemSubType, itemData.insID, itemData.resID, itemData.colorID, itemData.patternID, false);	-- 添加到穿戴信息
		end
	end
	MallSystemUI_2:SpawnPlayer(rolewear);
	--先脱掉所有的装备
		

	--[[local avatarSt = 
	{
		gamegender = DataMgr.avatarData.gamegender,
		headid = DataMgr.avatarData.headid,
		hairid = DataMgr.avatarData.hairid
	}

	local playerData =
	{
		avatar = avatarSt,
		index = BP_LobbyPlayerNum,
		BP_ARRAY_AvatarList = rolewear
	}
	
	MallSystemUI_2:SpawnPlayer(playerData);--]]

end
--新建一个角色
function MallSystemUI_2:SpawnPlayer(rolewear)

	log("MallSystemUI_2 spawnPlayer " )

	BP_STRUCT_MallSpawnPlayerData =
	{
		gid = tostring(DataMgr.roleData.uid),
		sex = DataMgr.avatarData.gamegender,
		headId = DataMgr.avatarData.headid,
		index = BP_LobbyPlayerNum,
		BP_ARRAY_AvatarList = rolewear
	}

	BP_STRUCT_MallSpawnPlayerData.sex = BP_STRUCT_MallSpawnPlayerData.sex - 1;
	
	table.insert(BP_STRUCT_MallSpawnPlayerData.BP_ARRAY_AvatarList, LobbyUI.CreateClientAvatarWearInfo(DataMgr.avatarData.hairid,0,0));
end

function MallSystemUI_2:AddToWearInfo(itemSubType, itemInsID, itemResID, colorID, patternID, needUpdatePlayerData)
	log("MallSystemUI_2:AddToWearInfo " .. itemSubType .." " .. itemInsID .. " " .. itemResID);
	MallSystemUI_2.currentWearPreviewMap[itemSubType] = {insID = tostring(itemInsID), resID = itemResID, colorID = colorID or 0, patternID = patternID or 0}; -- 记录预览数据
	
	--[[needUpdatePlayerData = needUpdatePlayerData or true;
	if needUpdatePlayerData then
		BP_STRUCT_MallSpawnPlayerData.BP_ARRAY_AvatarList = {};
		for k,v in pairs(MallSystemUI_2.currentWearPreviewMap) do			
			table.insert(BP_STRUCT_MallSpawnPlayerData.BP_ARRAY_AvatarList, v.resID);
		end
		table.insert(BP_STRUCT_MallSpawnPlayerData.BP_ARRAY_AvatarList, DataMgr.avatarData.hairid);
	end	--]]
end

--sami 是否穿上
function MallSystemUI_2:IsWear(itemId)
	--log("MallSystemUI_2:IsWear itemId = " ..itemId)
	for k,v in pairs(MallSystemUI_2.currentWearPreviewMap) do
		if v.resID == itemId then
			return true
		end
	end
	return false
end
function MallSystemUI_2.AvatarChange(res_id, open, color_id, pattern_id)
	 -- For fix the Bug, recreate model when puton special equipment.!!!!!!
	 log("ssssssssssssss1"..tostring(open).." id "..res_id)
	if open == true 
	and (res_id == 1405063 or res_id == 1405065)
	then

		LuaClassObj.HandleUIMessageNoFetch(bp_mall_system_2, "RecreateAvatar")

		local colorID = BP_STRUCT_Mall_AvatarChange.colorID;
		local patternID = BP_STRUCT_Mall_AvatarChange.patternID;

		for k,v in pairs(MallSystemUI_2.currentWearPreviewMap) do
			-- log("ssssssssssssss1==="..v.resID)
			-- if v.resID ~= res_id then
				-- log("res_id = " .. tostring(res_id));
				-- if not v.resID or v.resID <= 0 then
				-- 	return;
				-- end

--[[				LogNula: LuaLog:     v
LogNula: LuaLog:     ├─ resID: 403017
LogNula: LuaLog:     ├─ colorID: 0
LogNula: LuaLog:     ├─ insID: "6652103347287359574"
LogNula: LuaLog:     └─ patternID: 0--]]

				-- log_tree("v",v)

				BP_STRUCT_Mall_AvatarChange = 
				{
				    resId = v.resID,
				    colorID = v.colorID or 0,
				    patternID = v.patternID or 0,
				}

				log("ssssssssssssss==="..v.resID)
				LuaClassObj.HandleUIMessage(bp_mall_system_2, "PutOnAvatar")
				-- MallSystemUI_2.AvatarChange(v.resID, true, colorID, patternID, false);
			-- end
		end

		BP_STRUCT_Mall_AvatarChange = 
		{
		    resId = res_id,
		    colorID = 0,
		    patternID = 0,
		}
		log("ssssssssssssss==="..res_id)
		-- log("ssssssssssssss==="..v.resID)
		LuaClassObj.HandleUIMessage(bp_mall_system_2, "PutOnAvatar")

		return
	end
	-- ====================================================================

	log("res_id = " .. tostring(res_id));
	if not res_id or res_id <= 0 then
		return;
	end

	BP_STRUCT_Mall_AvatarChange = 
	{
	    resId = res_id,
	    colorID = color_id or 0,
	    patternID = pattern_id or 0,
	}
	-- BP_Mall_Cur_Avatar_ResID = res_id;
	log("res_id = " .. tostring(res_id).." BP_Mall_Cur_Avatar_ResID = " .. tostring(BP_STRUCT_AvatarChange.resId));

	if open then
		 LuaClassObj.HandleUIMessage(bp_mall_system_2, "PutOnAvatar")
	 else
		 LuaClassObj.HandleUIMessage(bp_mall_system_2, "PutOffAvatar")
	 end
end

function MallSystemUI_2:HasWearSubType(itemSubType)
	for k,v in pairs(DataMgr.rolewear) do
		local itemInfo = DataMgr.GetHallDepotItemDataByInsID(v);
		if itemInfo ~= nil and itemInfo.itemSubType == itemSubType then
			return true;
		end
	end

	return false;
end
--切换应该显示的角色
function MallSystemUI_2.SwitchShowPlayer(sex)
	log("===MallSystemUI_2.SwitchShowPlayer")
	if tonumber(sex) == BP_MALL_CURRENT_PREVIEW_SEX then
		--不做任何修改
	else
		--隐藏 当前角色 展示需要预览的角色
		if sex == DataMgr.avatarData.gamegender then
			LuaClassObj.HandleUIMessage(bp_mall_system_2, "ShowDefaultPlayer");
		else
			LuaClassObj.HandleUIMessage(bp_mall_system_2, "ShowOppositePlayer");
		end		
	end
	
	BP_MALL_CURRENT_PREVIEW_SEX = sex;
	LuaClassObj.HandleUIMessage(bp_mall_system_2, "UpdateSexButton");
end

-- 还原性别
function MallSystemUI_2.ResetSex()
	MallSystemUI_2.SwitchPlayerSex(BP_MALL_DEFAULT_PREVIEW_SEX);
end

-- 显示性别按钮
function MallSystemUI_2.ShowSex()
	LuaClassObj.HandleUIMessage(bp_mall_system_2, "ShowSex");
end

-- 隐藏性别按钮
function MallSystemUI_2.HideSex()
	LuaClassObj.HandleUIMessage(bp_mall_system_2, "HideSex");
end


function MallSystemUI_2.SwitchPlayerSex(sex)
	log("===MallSystemUI_2.SwitchPlayerSex")
	--切换性别，停止声音
	BP_Lobby_Play_Sound_Uid = tostring(DataMgr.roleData.uid);
	LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "StopPlaySoundFromPath");
	
	if (sex == nil) then
		sex = 1;
		if (sex == BP_MALL_CURRENT_PREVIEW_SEX) then
			sex = 2;
		end
	end

	MallSystemUI_2.SwitchShowPlayer(sex);

	local colorID = BP_STRUCT_Mall_AvatarChange.colorID;
	local patternID = BP_STRUCT_Mall_AvatarChange.patternID;

	for k,v in pairs(MallSystemUI_2.currentWearPreviewMap) do
		MallSystemUI_2.AvatarChange(v.resID, true, colorID, patternID);
	end

	--log("mickey:" .. MallSystemUI_2.weaponID);

	if (MallSystemUI_2.weaponID ~= nil and MallSystemUI_2.weaponID ~= 0) then
		MallSystemUI_2.ShowWeapon(MallSystemUI_2.weaponID);
	end
end

function MallSystemUI_2.ShowItemList(itemList,sex)
	MallSystemUI_2.ShowWeapon(0);
	MallSystemUI_2:SetEquipBG(0);
	--不同性别 需要做处理
	if (sex ~= nil and sex ~= 0) then
		MallSystemUI_2.SwitchShowPlayer(sex);
	end
	
	for k,v in pairs(itemList) do
		
		local resItem = Client.GetTableData("Item", v);
		if resItem ~= nil then
			if resItem.ItemType == 1 then
				MallSystemUI_2.ShowWeapon(v, 0, true);
			else
				MallSystemUI_2:ShowAvatarItem(v);
			end
		end	
	end	
end

function MallSystemUI_2.GetItemShowSex(itemList)
	for k,v in pairs(itemList) do
		local resItem = Client.GetTableData("Item", v);
		if resItem ~= nil and resItem.ShowSexInMall ~= nil then
			if resItem.ShowSexInMall >= 0 and resItem.ShowSexInMall <= 2 then
				return resItem.ShowSexInMall;
			end
		end	
	end
	return 0;
end

function MallSystemUI_2.ShowItem(itemid, toSex, colorID, patternID)
	--log("MallSystemUI_2.ShowItem(itemid,toSex)".. tostring(itemid) .. " " .. tostring(toSex) );
	local resItem = Client.GetTableData("Item", itemid);
	if resItem == nil then
		return 0;
	end	
	local showSex = true;
	--不同性别 需要做处理

	local sex = toSex;
	if resItem.ShowSexInMall ~= nil and resItem.ShowSexInMall >= 0 and resItem.ShowSexInMall <= 2 then
		sex = resItem.ShowSexInMall;
	end
	if (sex ~= nil and sex ~= 0) then
		MallSystemUI_2.SwitchShowPlayer(sex);
	end
	--local beforeItemid = MallSystemUI_2.showItemId ;
	MallSystemUI_2.showItemId = itemid;
	--log("resItem.itemid" .. itemid);
	--log("resItem.ItemType" .. resItem.ItemType);
	--log("resItem.ItemSubType" .. resItem.ItemSubType);
	BP_MALL_SYSTEM_IS_SELECT_UPGRADE_ITEM = ItemUpgradeSystem.CheckCanUpgrade(itemid);
	-- MallSystemUI_2.SwitchWeaponShowType(0)

	if (resItem.ItemType == 8) or (resItem.ItemType == 9) then
		MallSystemUI_2:SetEquipBG(0);

		showSex = false;
		MallSystemWeaponModelHandler:Init();
		MallSystemWeaponModelHandler:ShowWeaponByResId(itemid, true, true, true, false, false)
		LuaClassObj.HandleUIMessage(bp_mall_system_2, "HideAllPlayer")
		
	elseif ((resItem.ItemType == 4 and resItem.ItemSubType == 701) or 
		--(resItem.ItemType == 8 and resItem.ItemSubType == 801) or 
		--(resItem.ItemType == 15 and resItem.ItemSubType == 1501) or
		resItem.ItemType == 15 or
		resItem.ItemType == 6 or resItem.ItemType == 8 or resItem.ItemType == 9 or
		resItem.ItemType == 16 or resItem.ItemType == 19 or resItem.ItemType == 20 or 
		resItem.ItemType == 21 or resItem.ItemType == 100 or resItem.ItemType == 200 or
		resItem.ItemType == 26
		) then
		showSex = false;
		MallSystemUI_2:SetEquipBG(itemid);	

	elseif (resItem.ItemType == 1) then	
		MallSystemUI_2:SetEquipBG(0);

		local beforeItemid = MallSystemUI_2.weaponID ;
		if itemid ~= MallSystemUI_2.weaponID then
			MallSystemUI_2.ShowWeapon(itemid, MallSystemUI_2.weaponShowType, true);
		else
			MallSystemUI_2.ShowWeapon(0, MallSystemUI_2.weaponShowType, true);
		end
		
		return beforeItemid, showSex;
	elseif resItem.ItemType == 22 then--表情		
		MallSystemUI_2:SetEquipBG(0);
		MallSystemUI_2.ShowWeapon(0);
		MallSystemUI_2.DoEmoteAction(itemid);
	else
		-- log("=========================123")
		MallSystemUI_2:SetEquipBG(0);
		MallSystemUI_2.SwitchWeaponShowType(0)
		LuaClassObj.HandleUIMessage(bp_mall_system_2, "ShowCurrentPlayer");	
		MallSystemWeaponModelHandler:HideWeapon()
		-- MallSystemUI_2.ShowWeapon(BP_MallSystem_WeaponStatusChange_WeaponResId, MallSystemUI_2.weaponShowType, true);
		-- MallSystemUI_2.ShowWeapon(0);
		return MallSystemUI_2:ShowAvatarItem(itemid, colorID, patternID), showSex;
	end
	return itemid, showSex;
end



function MallSystemUI_2:ShowAvatarItem(res_id, color_id, pattern_id)
	color_id = color_id or 0;
	pattern_id = pattern_id or 0;
	local itemInfo = Client.GetTableData("Item", res_id);
	--查看道具是否在身上
	if itemInfo ~= nil then
		log("ClickAvatarItem itemInfo.itemSubType = "..itemInfo.ItemSubType.."itemInfo.itemSubType = "..itemInfo.ItemSubType);
		--头盔 背包 防弹衣 取真实id
		if itemInfo.ItemSubType == 504 or itemInfo.ItemSubType == 505 or itemInfo.ItemSubType == 505 then
			local itemMappingCfg = Client.GetTableData("BackpackMapping", res_id)
						
			if itemMappingCfg ~= nil then
				
				MallSystemUI_2.currentWearBackpackMap[itemMappingCfg.SkinItemIDLv3] = res_id;
				res_id = itemMappingCfg.SkinItemIDLv3;				
			end
		else
			--脱了。。。
			
			
				
		end
		
		
		local wearInfo = MallSystemUI_2.currentWearPreviewMap[itemInfo.ItemSubType];

		if wearInfo == nil then
			log("wearInfo == nil");
			MallSystemUI_2.AvatarChange(res_id,true, color_id, pattern_id);
			MallSystemUI_2:AddToWearInfo(itemInfo.ItemSubType, 0, res_id, color_id, pattern_id);
		elseif res_id ==  wearInfo.resID then
			--换回正常的穿着
			local defaultItemData = nil;
			--不需要穿回大厅的衣服了
			for k,v in pairs(DataMgr.rolewear) do
				local itemData = DataMgr.GetHallDepotItemDataByInsID(v);
				--log("defaultItemData itemData.itemSubType = "..itemInfo.ItemSubType.."itemInfo.itemSubType = "..itemInfo.ItemSubType);
				if itemData ~= nil and itemData.itemSubType == itemInfo.ItemSubType then

					defaultItemData = itemData;
					break;
				end
			end

			if defaultItemData == nil then
				MallSystemUI_2.AvatarChange(res_id,false);

				MallSystemUI_2:AddToWearInfo(itemInfo.ItemSubType, 0, 0, 0, 0);	-- 添加到穿戴信息

			elseif defaultItemData.resID ~= res_id or defaultItemData.colorID ~= color_id or defaultItemData.patternID ~= pattern_id then

				MallSystemUI_2.AvatarChange(res_id,false);

				MallSystemUI_2.AvatarChange(defaultItemData.resID,true, color_id, pattern_id);

				MallSystemUI_2:AddToWearInfo(defaultItemData.itemSubType, defaultItemData.insID, defaultItemData.resID, color_id, pattern_id);	-- 添加到穿戴信息
			end
			if MallSystemUI_2.currentWearBackpackMap[wearInfo.resID] ~= nil then
				return MallSystemUI_2.currentWearBackpackMap[wearInfo.resID];
			end
			return wearInfo.resID;
		else
			if wearInfo.resID ~= 0 then
				MallSystemUI_2.AvatarChange(wearInfo.resID, false);
			end


			MallSystemUI_2.AvatarChange(res_id, true, color_id, pattern_id);

			MallSystemUI_2:AddToWearInfo(itemInfo.ItemSubType, 0, res_id, color_id, pattern_id);
			if MallSystemUI_2.currentWearBackpackMap[wearInfo.resID] ~= nil then
				return MallSystemUI_2.currentWearBackpackMap[wearInfo.resID];
			end
			return wearInfo.resID;
		end
	end
	return 0;
end

--脱掉所有的衣服
function MallSystemUI_2:PutoffAllCloth()
	-- 还原真实穿戴
	--[[for k,v in pairs(DataMgr.rolewear) do
		local itemInfo = DataMgr.GetHallDepotItemDataByInsID(v);
		if itemInfo ~= nil then
			local wearInfo = tmpWearPreviewMap[itemInfo.itemSubType];
			
			MallSystemUI_2.AvatarChange(itemInfo.resID, false);
		end
	end
	--]]
	if MallSystemUI_2.currentWearPreviewMap == nil then
		return;
	end
	-- 脱下实际未穿戴
	for k,v in pairs(MallSystemUI_2.currentWearPreviewMap) do
		MallSystemUI_2.AvatarChange(v.resID, false);
	end
	MallSystemUI_2.currentWearPreviewMap = {};
end

-- 补丁。。。修复切页签还带武器用
function MallSystemUI_2.ForceRevertAvatar()
	EventMallRefreshMultBuy()
	MallSystemUI_2.SetEquipBG(0)
	MallSystemUI_2.ShowWeapon(0,0,false)
	MallSystemUI_2:RevertAvatar()
	MallSystemUI_2.StopEmoteAction()
	MallSystemUI_2:UnEquipWeapon()

	MallSystemUI_2.showItemId = 0
end

function MallSystemUI_2:RevertAvatar()
	log("revert avatar!!");
	 MallSystemUI_2.EnableRoleRotate();
	-- log_tree("WardrobeUI.RevertAvatar rolewear", DataMgr.rolewear);
	--WardrobeSystem.UpdateInvalidWearInfo()
	--[[if MallSystemUI_2.currentWearPreviewMap == nil then
		return;
	end
	-- 脱下实际未穿戴
	for k,v in pairs(MallSystemUI_2.currentWearPreviewMap) do
		MallSystemUI_2.AvatarChange(v.resID, false);
	end
	MallSystemUI_2.currentWearPreviewMap = {};
	--LuaClassObj.HandleUIMessage(bp_mall_system_2, "PutOffAllCloth");
	--]]
	
	if MallSystemUI_2.currentWearPreviewMap == nil then
		return;
	end
	local tmpWearPreviewMap = MallSystemUI_2.currentWearPreviewMap;
	MallSystemUI_2.currentWearPreviewMap = {};
	-- 还原真实穿戴
	for k,v in pairs(DataMgr.rolewear) do
		local itemInfo = DataMgr.GetHallDepotItemDataByInsID(v);
		if itemInfo ~= nil then
			local wearInfo = tmpWearPreviewMap[itemInfo.itemSubType];
			if wearInfo ~= nil and (wearInfo.resID ~= itemInfo.resID or wearInfo.colorID ~= itemInfo.colorID or wearInfo.patternID ~= itemInfo.patternID) then
				MallSystemUI_2.AvatarChange(itemInfo.resID, true, itemInfo.colorID, itemInfo.patternID);
			end
			MallSystemUI_2:AddToWearInfo(itemInfo.itemSubType, itemInfo.insID, itemInfo.resID, itemInfo.colorID, itemInfo.patternID);
		end
	end

	-- 脱下实际未穿戴
	for k,v in pairs(tmpWearPreviewMap) do
		if not MallSystemUI_2:HasWearSubType(k) then
			-- log("WardrobeUI.RevertAvatar putdown "..v.resID);
			MallSystemUI_2.AvatarChange(v.resID, false);
		end
	end
end

--  showWeaponType 0 是持枪 1 是 只看枪
function MallSystemUI_2.ShowWeapon(res_id,showWeaponType,needOffset,isNotEquip)
	log(debug.traceback())
	MallSystemWeaponModelHandler:Init();
	log("----------res_id == "..tostring(res_id).." BP_Mall_ShowWeaponType = "..tostring(showWeaponType) );	
	if isNotEquip ~= true then
		MallSystemUI_2.weaponID = res_id;	
	end

	-- MallSystemUI_2.showItemId = res_id;

	if showWeaponType == 1 then
		if BP_MallSytem2_To_Lobby == 1 then
			if res_id ~= 0 then				
				MallSystemWeaponModelHandler:ShowWeaponByResId(res_id,true,true,needOffset, true, true);			
				MallSystemUI_2.isMallCamera = false;
			else
				MallSystemWeaponModelHandler:DestroyWeaponShowActor();
			end	
			
		end
		--隐藏角色
	
		LuaClassObj.HandleUIMessage(bp_mall_system_2, "HideAllPlayer");
		LuaClassObj.HandleUIMessage(bp_mall_system_2, "SetWeaponLightProperty")
		--LuaClassObj.HandleUIMessage(bp_lobby, "StartMallToLobby");
		MallSystemUI_2.isRoleInMall = false;	
		
	else
		--显示角色
		if BP_MallSytem2_To_Lobby == 1 then
			
			LuaClassObj.HandleUIMessage(bp_mall_system_2, "ShowCurrentPlayer");	
			MallSystemUI_2.isRoleInMall = true;	
			if OpenBoxtUI.isShow == false and MallSystemUI_2.isMallCamera == false and MallRecommendUI.isShowing == false then		
				LuaClassObj.HandleUIMessage(bp_mall_system_2, "SwitchCameraMall");
				MallSystemUI_2.isMallCamera = true;
			end
			
			--隐藏武器
			MallSystemWeaponModelHandler:HideWeapon();
		end
		
		
		LuaClassObj.HandleUIMessage(bp_mall_system_2, "SetHumanLightProperty")
		
		if res_id ~= 0 then
			MallSystemUI_2:EquipWeapon( res_id);
		else
			MallSystemUI_2:UnEquipWeapon();
		end		
	end
	
end
function MallSystemUI_2.HideWeapon()
	log("hide weapon 2" );	
	log("BP_MallSytem2_To_Lobby = "..tostring(BP_MallSytem2_To_Lobby));	
	--移动角色到商城
	if BP_MallSytem2_To_Lobby == 1 then
		
		LuaClassObj.HandleUIMessage(bp_mall_system_2, "ShowCurrentPlayer");	
		MallSystemUI_2.isRoleInMall = true;	
		if OpenBoxtUI.isShow == false and MallSystemUI_2.isMallCamera == false and MallRecommendUI.isShowing == false then		
			LuaClassObj.HandleUIMessage(bp_mall_system_2, "SwitchCameraMall");	
			MallSystemUI_2.isMallCamera = true;		
		end
		
		--隐藏武器
		MallSystemWeaponModelHandler:HideWeapon();
	end

	LobbyUI:UnEquipWeapon(DataMgr.roleData.uid);	
end
--切换展示武器的类型
function MallSystemUI_2.SwitchWeaponShowType(weapontype)
	MallSystemUI_2.weaponShowType = weapontype;
	log("MallSystemUI_2.showItemId"..tostring(MallSystemUI_2.showItemId));
	-- if MallSystemUI_2.showItemId == 0 then
	-- 	MallSystemUI_2.ShowWeapon(MallSystemUI_2.showItemId, MallSystemUI_2.weaponShowType, true);	
	-- 	MallSystemUI_2:SetEquipBG(0);
	-- 	return
	-- end

	local resItem = Client.GetTableData("Item", MallSystemUI_2.showItemId);
	if resItem == nil then
		return;
	end	
	if (resItem.ItemType == 1) then	
		if weapontype == 1 then
			MallSystemUI_2.ShowWeapon(MallSystemUI_2.showItemId, MallSystemUI_2.weaponShowType, true, true);	
			MallSystemUI_2:SetEquipBG(0);
		else
			MallSystemUI_2.ShowWeapon(MallSystemUI_2.weaponID, MallSystemUI_2.weaponShowType, true);	
			MallSystemUI_2:SetEquipBG(0);
		end
	end
	--MallSystemUI_2.ShowItem(MallSystemUI_2.showItemId);
end

BP_MallSystem_WeaponStatusChange_WeaponResId = 0

-- 人物装载武器接口 --
function MallSystemUI_2:EquipWeapon(weaponResId)
 	log("MallSystemUI_2:EquipWeapon"..weaponResId);
	BP_MallSystem_WeaponStatusChange_WeaponResId = weaponResId
    LuaClassObj.HandleUIMessageNoFetch(bp_mall_system_2, "EquipWeapon");

end

function MallSystemUI_2:UnEquipWeapon()
	log("MallSystemUI_2:UnEquipWeapon");
	BP_MallSystem_WeaponStatusChange_WeaponResId = 0
	MallSystemUI_2.weaponID = 0
    LuaClassObj.HandleUIMessageNoFetch(bp_mall_system_2, "UnEquipWeapon");
end


function MallSystemUI_2.DisableRoleRotate()
	LuaClassObj.HandleUIMessageNoFetch(bp_mall_system_2, "DisableRoleRotate");
end
function MallSystemUI_2.EnableRoleRotate()
	LuaClassObj.HandleUIMessageNoFetch(bp_mall_system_2, "EnableRoleRotate");
end

--全局
function MallSystemUI_2.BuyShopItems(shopInfoDict, curVersion,voucher)
	log_tree("shopInfoDict ", shopInfoDict);
	local tempDict = {};
	local moneyNum = 0;
	local money1Num = 0;--兑换积分
	local diamondNum = 0;
	for i,v in ipairs(shopInfoDict) do
		local shopId = v.id;
		local num = v.num;
		local itemInfo = v.shopInfo;
		if itemInfo ~= nil then
			local priceType,price = MallSystemUI_2.get_money_type_and_price(shopId, 1, itemInfo);
			local colorPatternCost = MallSystemUI_2.get_color_and_pattern_cost(v.colorID, v.patternID);
			log("num:"..tostring(num))
			if priceType == 2 then
				diamondNum = diamondNum + (price  + colorPatternCost) * num;
			elseif priceType == 0 then
				moneyNum = moneyNum + (price + colorPatternCost) * num;
			elseif priceType == 1 then
				money1Num = money1Num + (price + colorPatternCost) * num;
			end
			local info = {
				shopitem_id = itemInfo.id;
				first_money = 1;
				price = (price + colorPatternCost) * num;
				item_id = itemInfo.item_id;
				num = num;
				color = v.colorID;
				pattern = v.patternID;
				source = MallSystem.Buy_Source or 2;
			};
			table.insert(tempDict, info);
		end
	end
	if moneyNum > DataMgr.gold then
		DataMgr.ShowNoticeByID(9910227);
		return;
	end
	if diamondNum > DataMgr.ticket then
		local str = Client.GetTableData("LocalizeRes", "101001").TextValue;
		local tip = Client.GetTableData("LocalizeRes", "4300").TextValue;
		CommonMessageBoxUI:ShowPanel(2, str, tip, function()
			RechargeUI:Init();
			MallBuyItemUI:Release();
			return true;
		end);
		return;
	end
	if money1Num > DataMgr.diamond then
		DataMgr.ShowNoticeByID(4457);
		return;
	end
	log_tree("BuyShopItems", tempDict);
	MallSystem.BatchBuyReq(tempDict,curVersion,voucher);
end

function MallSystemUI_2.BuyShopItems2(shopInfoDict, curVersion,voucher)
	--log_tree("shopInfoDict ", shopInfoDict);
	local tempDict = {};
	local moneyNum = 0;
	local money1Num = 0;--兑换积分
	local diamondNum = 0;
	for i,v in ipairs(shopInfoDict) do
		local shopId = v.id;
		local num = v.num;
		local itemInfo = v.shopInfo;
		if itemInfo ~= nil then
			local priceType,price = MallSystemUI_2.get_money_type_and_price(shopId, v.first_money, itemInfo, v.time_valid_index);
			local colorPatternCost = MallSystemUI_2.get_color_and_pattern_cost(v.colorID, v.patternID);
			if priceType == 2 then
				diamondNum = diamondNum + (price  + colorPatternCost) * num;
			elseif priceType == 0 then
				moneyNum = moneyNum + (price + colorPatternCost) * num;
			elseif priceType == 1 then
				money1Num = money1Num + (price + colorPatternCost) * num;
			end
			local info = {
				shopitem_id = itemInfo.id,
				first_money = v.first_money,
				time_valid_index = v.time_valid_index,
				price = (price + colorPatternCost) * num,
				item_id = itemInfo.item_id,
				num = num,
				color = v.colorID,
				pattern = v.patternID,
				source = MallSystem.Buy_Source or 2,
			};
			table.insert(tempDict, info);
		end
	end
	if moneyNum > DataMgr.gold then
		DataMgr.ShowNoticeByID(9910227);
		return;
	end
	if diamondNum > DataMgr.ticket then
		local str = Client.GetTableData("LocalizeRes", "101001").TextValue;
		local tip = Client.GetTableData("LocalizeRes", "4300").TextValue;
		CommonMessageBoxUI:ShowPanel(2, str, tip, function()
			RechargeUI:Init();
			MallBuyItemUI:Release();
			return true;
		end);
		return;
	end
	if money1Num > DataMgr.diamond then
		DataMgr.ShowNoticeByID(4457);
		return;
	end
	log_tree("BuyShopItems", tempDict);
	MallSystem.BatchBuyReq(tempDict,curVersion,voucher);
end

function MallSystemUI_2:SetEquipBG(res_id)
	BP_Mall_2_Equip_ResID = res_id;
	LuaClassObj.HandleUIMessage(bp_mall_system_2, "UpdateEquipBG");
	if res_id ~= 0 then
		LuaClassObj.HandleUIMessage(bp_mall_system_2, "HideAllPlayer");
		MallSystemWeaponModelHandler:HideWeapon();
	end
end
--做表情动作
BP_Mall_ShowEmoteAction_EmoteResId = 0
function MallSystemUI_2.DoEmoteAction(res_id)

	BP_Mall_ShowEmoteAction_EmoteResId = res_id
	LuaClassObj.HandleUIMessageNoFetch(bp_mall_system_2, "ShowEmoteAction");

	--播放声音
	local myUid = DataMgr.roleData.uid;
	local sex = ProfileMgr.GetRoleSexByUid(myUid)
	LobbyUI.PlayEmotionSound(res_id, BP_MALL_DEFAULT_PREVIEW_SEX, 0, myUid, 2)
end

function MallSystemUI_2.StopEmoteAction()
	LuaClassObj.HandleUIMessageNoFetch(bp_mall_system_2, "StopEmoteAction");
end

function MallSystemUI_2.HideAllContent()
	LuaClassObj.HandleUIMessage(bp_mall_system_2, "HideAllPlayer");
	MallSystemWeaponModelHandler:HideWeapon();
	MallSystemUI_2:SetEquipBG(0);
end


--从开箱子回到商城
function MallSystemUI_2.RevertFromBox()
	log("MallSystemUI_2.isShowing"..tostring(MallSystemUI_2.isShowing).." MallSystemUI_2.isRoleInMall"..tostring(MallSystemUI_2.isRoleInMall));
	--[[if MallSystemUI_2.isShowing == true and MallSystemUI_2.isRoleInMall == true then
		LuaClassObj.HandleUIMessage(bp_lobby, "EndLobbyToMall");
	end--]]
end

function MallSystemUI_2.PutonPreviewAvator()
	if selectShopItemDict == nil then
		return;
	end
	for i,shopId in pairs(selectShopItemDict) do
		local marketData = itemInfoIdDict[shopId];
		if marketData ~= nil then
			MallSystemUI_2.ShowItem(marketData.item_id);
		end
	end
end

--从开箱子回到商城
function MallSystemUI_2.SetBalckBgShow(isShow)
	BP_Mall_Black_Bg_IsShow = isShow;
	LuaClassObj.HandleUIMessage(bp_mall_system_2, "luaSetBalckBgShow");
end

-- 改变角色位置
function MallSystemUI_2.SetAvatarX(value)
	BP_Mall_2_AVATAR_X = value;
	LuaClassObj.HandleUIMessageNoFetch(bp_mall_system_2, "UpdateMallTransform")
	-- LuaClassObj.HandleUIMessage(bp_mall_system_2, "ShowCurrentPlayer")
end

function EventSetInfo_Push()
end

function EventFetchInfo()
end

--延迟穿衣服
--[[function EventDelayShowCloth()
	if MallSystemUI_2.isShowing == true then
		
	end
end--]]

--进入商城系统
function EventEnterMallSystem()
	log("EventEnterMallSystem");

	MallSystemUI_2:Show();
	MallSystemUI_2.SetItemBGFillPosVisible(false)
end
--完全退出商城系统
function EventExitMallSystem()
	MallSystemUI_2.isShowing = false;
	log("EventExitMallSystem");
	EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE);
	LuaClassObj.HandleUIMessage(bp_lobby, "UIShowFromMall");
	--跳转回赛事
	if MallSystemUI_2.isFromLeague >= 0 and MallSystemUI_2.isFromLeague < 2 then
		if LeagueGameSystem.StageId == LeagueGameSystem.LEAGUE_STAGE_ENROLL then
			LeagueGameSignUpUI.SetVisible()
		else
			LeagueGameLeagueInfoUI.SetVisible()
		end
		MallSystemUI_2.isFromLeague = 2;
	end
	EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTTYPE_CHECK_BACK_TO_VIEW, MallSystemUI_2.isClickClose);
	MallSystemUI_2.isClickClose = false;
end
--退出
function EventStartCloseMallSystem()
	if MallSystemUI_2.isShowing == false then
		return;
	end
	MallSystemUI_2.isShowing = false;
	EventMallSystemStopPlayRedEmtion()
	
	--关闭赠送界面
	EventGiftUIClose()
	MallSystemUI_2.SwitchShowPlayer(BP_MALL_DEFAULT_PREVIEW_SEX);
	log("EventStartCloseMallSystem");
	BP_MallSytem2_To_Lobby = 0;
	--EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN);
	--移动角色到大厅
	EventFadeIn();
	--LuaClassObj.HandleUIMessage(bp_lobby, "StartMallToLobby");
	--LuaClassObj.HandleUIMessage(bp_mall_system_2, "UIShowMallAvatarAni");
	PanelOpenCloseAnimSystem.CloseView();
	UIManager.Hide(eUIType.eStoreUI)
	LuaClassObj.HandleUIMessage(bp_mall_system_2, "UIHideMallSystem");
	MallSystemUI_2:Release();

	--是否需要回退到个人信息界面
	log("EventStartCloseMallSystem BP_MallUIOpenFromRoleUI = " ..tostring(BP_MallUIOpenFromRoleUI));
	if(BP_MallUIOpenFromRoleUI) then
		--延迟跳转
		MallSystemUI_2.isBackingFromRoleUI = true;
        BP_MallUIOpenFromRoleUI = false;
	end

end

--对mallpagetab信息进行排序
function EventMallSortTabListInfo()
	BP_ARRAY_Mall_First_Tab_List = {};
	if pageResDict == nil then
		log("no pageResDict");
		return;
	end
	local arrDict = {};
	log_tree("pageResDict ",pageResDict);
	for i,v in pairs(pageResDict) do
		if v.isOpen == 1 then
			table.insert(arrDict, {id = i, name = localText(v.A_table_name1), icon = v.A_table_icon1, sortValue = v.rank});
		end
	end
	table.sort(arrDict,function (a,b)
		return a.sortValue < b.sortValue;
	end)
	BP_ARRAY_Mall_First_Tab_List = arrDict;
	--log_tree("EventMallSortTabListInfo ",BP_ARRAY_Mall_First_Tab_List);
	
	--跳转子页面相关
	if bIsJump == true then
		for i, v in pairs(BP_ARRAY_Mall_First_Tab_List) do
			if tab1 == v.id then
				BP_Tab1_Number = i
			end
		end

		if BP_Tab1_Number == 0 then
			bIsJump = false
		end
	else
		BP_Tab1_Number = 1
	end
end

function EventMallUpdateTabInfo()
	log("xx EventMallUpdateTabInfo stop uid="..DataMgr.roleData.uid)
	BP_Lobby_Play_Sound_Uid = tostring(DataMgr.roleData.uid);
	LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "StopPlaySoundFromPath");
	
	if MallSystemUI_2.GetCurClass(BP_Mall_First_Tab_Id) ~= MallPageCommonUI_2 and 
			MallSystemUI_2.GetCurClass(BP_Mall_First_Tab_Id) ~= MallPageDiyUI and
			itemInfoDict[BP_Mall_First_Tab_Id] ~= MallRecommendUI and
			itemInfoDict[BP_Mall_First_Tab_Id] == nil then
		itemInfoDict[BP_Mall_First_Tab_Id] = {};
	end
	if itemInfoDict[BP_Mall_First_Tab_Id] == nil then
		MallSystem.GetPageDetailReq(BP_Mall_First_Tab_Id);
		return;
	end
	local pageCls = MallSystemUI_2.GetCurClass(BP_Mall_First_Tab_Id);
	if pageCls == nil then
		log("no page Class:" .. BP_Mall_First_Tab_Id );
		return;
	end
		
	if isFirstSetPage then
		isFirstSetPage = false;
		if pageCls ~= MallSaleUI and pageCls ~= MallRecommendUI then
			LuaClassObj.HandleUIMessage(bp_mall_system_2, "ShowCurrentPlayer");
		end
	end
	local dataList = MallSystemUI_2.GetPageDatas(BP_Mall_First_Tab_Id)
	local tabInfo = MallSystemUI_2.GetSencondTabInfo(BP_Mall_First_Tab_Id);
	local pageIndex = BP_Mall_First_Tab_Id;
	local isNeedUpdate = pageIndex ~= curPageIndex;
	curPageIndex = pageIndex;
	if isNeedUpdate then
		LuaClassObj.HandleUIMessage(bp_mall_system_2, "HideEquipDescript");
	end
	local refreshTime2 = BP_Mall_2_Refesh_Time2 - (BP_Mall_2_Refesh_Time - BP_MALL_2_Cur_Refesh_Time);
	--等于-1标识没配，不显示时间
	if BP_Mall_2_Refesh_Time2 == -1 then
		refreshTime2 = -1;
	end
	if pageCls == curPage then
		if isNeedUpdate and pageCls.UpdateList ~= nil then
			pageCls.UpdateList(pageIndex,dataList,tabInfo,BP_MALL_2_Cur_Refesh_Time,refreshTime2,setFirstSelectShopId);
			setFirstSelectShopId = 0;
		end
		return;
	end
	if curPage ~= nil and curPage.Hide ~= nil then
		curPage.Hide();
	end
	curPage = pageCls;
	
	--外部跳转相关
	local startSecondeIndex = 0;
	if bIsJump then
		if isForceTab2 == true then
			startSecondeIndex = tab2;
		else
			startSecondeIndex = MallSystemUI_2.HandleTab2(pageCls, tabInfo);
		end
		
		bIsJump = false;
	end
	
	if pageCls.Init ~= nil then
		pageCls.Init();
	end
	if pageCls.Show ~= nil then
		pageCls.Show(startSecondeIndex, setFirstSelectShopId);
	end
	if isPlayOverStartMovie == false and pageCls.PlayShow ~= nil then
		pageCls.PlayShow();
		isPlayOverStartMovie = true;
	end
	if isNeedUpdate and pageCls.UpdateList ~= nil then
		pageCls.UpdateList(pageIndex, dataList,tabInfo, BP_MALL_2_Cur_Refesh_Time,refreshTime2,setFirstSelectShopId);
		setFirstSelectShopId = 0;
	end
end

--鉴于商城每个子类的.show(id)函数中，id所代表含义的各不一致，此处统一处理
function MallSystemUI_2.HandleTab2(pageClass, tabInfo)
	local ans = 0
	if pageClass == MallSaleUI then --跳转推荐,没有.show()函数
		--do nothing
	elseif pageClass == StoreGiftBox_UI then--跳转礼包, ans从0开始, tab2为礼包id
		ans = ShopSystem.GetGiftBoxIndex(tab2)
	elseif pageClass == MallPageCommonUI_2 then--跳转外观等, ans从1开始, tab2为二级页签名字id, 如(外观, 裤子), 此时tab2 = 4667
		for i = 1,tabInfo.B_table_number do
			if tabInfo["B_table_name" .. i ] == tab2 then
				ans = tabInfo["B_table_ID" .. i];
				break
			end
		end
	elseif pageClass == StoreBox_UI then--跳转补给(宝箱), ans为箱子id, tab2为宝箱id
		ans = tab2;
	end
	
	return ans;
end

function MallSystemUI_2.SetItemBGFillPosVisible(isVisible)
    if isVisible == true then
        LuaClassObj.HandleUIMessageNoFetch(bp_mall_system_2, "ShowBGFillPosition")
    else
        LuaClassObj.HandleUIMessageNoFetch(bp_mall_system_2, "HideBGFillPosition")
    end
end

function EventMallSelectEquip()
	MallSystemUI_2.SelectEquip(BP_Mall_Cur_Select_SHOP_ID);
end

--显示应该显示的item
function EventShowClickItem()	
	log(tostring(BP_MALL_2_SHOW_ITEM_ID));
	MallSystemUI_2.ShowItem(BP_MALL_2_SHOW_ITEM_ID);
end

function EventLobbyWeapon2ChangeAvatorState()
	MallSystemUI_2.SwitchWeaponShowType(BP_MALL_WEAPON_AVATOR_STATE);
end

function EventMallRefreshMultBuy()
	for i,shopId in pairs(selectShopItemDict) do
		local marketData = itemInfoIdDict[shopId];
		if marketData ~= nil then
			MallSystemUI_2.ShowItem(marketData.item_id);
		end
	end
	selectShopItemDict = {};
end

function EventMall2BuyItem()
	if BP_Mall_Cur_Select_SHOP_IsSellOut then
		DataMgr.ShowNoticeByID(4639);
		return;
	end
	--是订阅商品并且是非订阅玩家
	if BP_Mall_CurPrimeStatus < BP_Mall_PrimeShopItemTag then
		GlobalData:JumpUrl(string.format("game://?module=%d", BP_ENUM_MODULE_PRIME))
		EventStartCloseMallSystem()
		return
	end
	MallSystemUI_2.OpenBuySingleItemWin(BP_Mall_Cur_Select_SHOP_ID);
end

function EventMallSendSelectItem()
	MallSystemUI_2.MallSendShopItem(BP_Mall_Cur_Select_SHOP_ID);
end
function EventMallChangeAvatar()
	local itemlist = {1504000001};
	MallSystemUI_2.ShowItemList(itemlist,0);
end

-- 切换性别显示
function EventSwitchPlayerSex()
	log("EventSwitchPlayerSex")
	MallSystemUI_2.SwitchPlayerSex();
end

function EventMall2GetFirstTabHotPointState()
	BP_Mall_Hot_Point_IsShow = MallSystemUI_2.GetFirstTabHotPointState(BP_Mall_Hot_Point_FirstTab);
end

function EventMallSystemClickButtonClose()
	MallSystemUI_2.isClickClose = true;
	EventStartCloseMallSystem();
end

function EventStartCloseMallSystemforAndroidBack()
	MallSystemUI_2.isClickClose = true;
	EventStartCloseMallSystem();
end

--sami 点击红装表情动画播放按钮
function EventMallSystemClickRedEmtion()
	log("EventMallSystemClickRedEmtion")
	if os.time() - MallSystemUI_2.nLastPlayEmotionTime < 5 then
		ShowNotice(120178);
		return
	end
	MallSystemUI_2.nLastPlayEmotionTime = os.time()
	
	EventMallSystemStartPlayRedEmtion()
end
--启动播放表情定时器
function EventMallSystemStartPlayRedEmtion()
	local itemId = BP_Mall_Select_Item_Id
	local cfg = Client.GetTableData("Item", itemId)
	if cfg == nil or cfg.RedEmotionId == 0 or cfg.RedEmotionPlayCD <= 0 then
		return
	end
	
	EventMallSystemStopPlayRedEmtion()
	
	if MallSystemUI_2:IsWear(itemId) then
		MallSystemUI_2.DoEmoteAction(cfg.RedEmotionId)
	end
		
	MallSystemUI_2.nPlayEmotionTimerId = Timer.InsertTimer(cfg.RedEmotionPlayCD, function()
		EventMallSystemClickRedEmtion()
	end, true, false)
end
--停止播放表情定时器
function EventMallSystemStopPlayRedEmtion()
	if MallSystemUI_2.nPlayEmotionTimerId ~= 0 then
		Timer.RemoveTimer(MallSystemUI_2.nPlayEmotionTimerId)
		MallSystemUI_2.nPlayEmotionTimerId = 0
	end

	log("xx EventMallSystemStopPlayRedEmtion stop uid="..DataMgr.roleData.uid)
	BP_Lobby_Play_Sound_Uid = tostring(DataMgr.roleData.uid);
	LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "StopPlaySoundFromPath");
end

function EventMallSystemClickJumpToItemUpgrade()
	log("EventMallSystemClickJumpToItemUpgrade")
	local itemCfg = Client.GetTableData("Item", MallSystemUI_2.showItemId);
	if itemCfg ~= nil then
		ItemUpgradeUI.mallSystemCallBack = nil;
		local UpgradeItemShowID = MallSystemUI_2.showItemId
		EventStartCloseMallSystem();
		ItemUpgradeUI.ShowByItemID(UpgradeItemShowID);
	end
end