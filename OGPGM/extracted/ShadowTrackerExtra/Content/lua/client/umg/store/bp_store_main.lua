-- sami 新版商城主界面UI
StoreMainUI = StoreMainUI or
{
	tabInfoList = {},
	pageMap = {},
	firstPageId1 = 0,
	firstPageId2 = 0,
	curShowUI = nil,
	jumpInfo = nil,
	defaultTexture = "/Game/UMG/Texture/StoreUI/Lobby011_BG.Lobby011_BG",
	emotionTimer = nil,
	curEmotionCdTime = 0,
	curEmotionId = 0,
    bShow = false,
	onOpenFinishCallback = nil,
	preSceneBgUrl = "",
}



--页签数据
BP_STRUCT_StoreMain_TabInfo =
{
	nIndex = 0,		--数组下标
	nTabLv = 0,		--tab级别1级，2级
	bOpenSub = false,	--是否展开子页签
	nTab1Id = 0,		--tab 1级id
	nTab2Id = 0,		--tab 2级id
	nSubTabNum = 0,		--子页签数量
	tabName = "",		--1级tab名字
	tabIcon = "",		--2级tab图标路径
	BgUrl = "",			--背景Url
	bSelected = false,	--是否选中
	bRedDot = false,	--是否红点
	bLastTab2 = false,	--是否最后一个二级页签
}
BP_ARRAY_StoreMain_TabInfo_List =
{
	BP_STRUCT_StoreMain_TabInfo = _G.BP_STRUCT_StoreMain_TabInfo;
}
--当前选择页签下标
BP_StoreMain_Tab_Select_Index = 0

--货币信息
BP_STRUCT_StoreMain_MoneyInfo =
{
	nGold = 0,
	nUC = 0,
	nZhupai = 0,
	nSilver = 0,
	nGoldChip = 0,
	bShowZhupai = false,
}
--是否需要跳回初始位置
BP_StoreMain_Is_Jump_To_First = false
--需要显示的页签下标
BP_StoreMain_Tab_Need_Show_Index = 0;
--补给是否有红点
BP_STORE_MAIN_SUPPLY_HAVE_RED_DOT = false;


--注册Widget
function bp_store_main_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_store_main,
        {{Path="/Game/UMG/UI_Logic/Store/Store/StoreMainLogicUI_BP.StoreMainLogicUI_BP_C", Container="Default", ZOrder=0}},
        {"Lobby"},
        false, 
	false,
        true
    );
end


--sami 初始化显示
function StoreMainUI.Init(para)
    log("StoreMainUI.Init")
	if para then
		para.bValid = true
	end
	StoreMainUI.jumpInfo = para
	StoreMainUI.onOpenFinishCallback = nil
	BP_StoreMain_Is_Jump_To_First = true
	
	--hide 所有的主界面
	EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN);
	--PanelOpenCloseAnimSystem.OpenView("EventEnterMallSystem", "EventExitMallSystem");

	LuaClassObj.HandleDynamicCreation(bp_store_main);
	LuaClassObj.HandleUIMessageNoFetch(bp_store_main, "UIShow");
	UIManager.Show(eUIType.eStoreMainUI)
    StoreMainUI.bShow = true
	BP_StoreMain_Tab_Select_Index = 0
	StoreMainUI.curShowUI = nil

	EventSystem:registEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_LIST, StoreMainUI.OnTabListInfo);
	EventSystem:registEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_BUY, StoreMainUI.OnPurchase)
	EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_TICKET_CHANGE, StoreMainUI.On_UC_Gold_Change)
	EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_GOLD_CHANGE, StoreMainUI.On_UC_Gold_Change)
	EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_DIAMOND_CHANGE, StoreMainUI.On_UC_Gold_Change)
	EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_GOLD_CHIP_CHANGE, StoreMainUI.On_UC_Gold_Change)
	EventSystem:registEvent(EVENTTYPE_NEXTDAY, EVENTID_NEXTDAY_ZERO, StoreMainUI.OnNextDayZeroCome)

	local bRet = StoreMainUI.UIOnlyShowAll();
	if bRet == false then
		StoreMainUI.TryNotifyChangeScene(StoreMainUI.preSceneBgUrl)
	end
	LuaClassObj.HandleUIMessageNoFetch(bp_store_main, "StartInitUI");

	if FuncUtil:CountTable(StoreSystem.global_collection_num) == 0 then
		StoreSystem.get_global_market_collect_data_req();
	end
end

function StoreMainUI.SetOpenFinishCallback(func)
	StoreMainUI.onOpenFinishCallback = func
end

function StoreMainUI.UIOnlyShowAll()
	log("StoreMainUI.UIOnlyShowAll");
	LobbyCameraManager.SwitchCamera(10112)
	LobbySceneManager.ChangeLight(LobbySceneManager.LIGHT_MALL_AVATAR)
	LobbySceneManager.ShowMesh(LobbySceneManager.MALL_MESH_LobbyBgMesh)
	LuaClassObj.HandleUIMessageNoFetch(bp_store_main, "UIOnlyShow");
	StoreMainUI.bShow = true

	for k,v in pairs(StoreMainUI.pageMap) do
		if StoreMainUI.curShowUI ~= nil and v ~= StoreMainUI.curShowUI and v.UIOnlyHide ~= nil then
			v.UIOnlyHide();
		end
	end
	
	local bRet = false
	if StoreMainUI.curShowUI and StoreMainUI.curShowUI.UIOnlyShow then
		local tabInfo = BP_ARRAY_StoreMain_TabInfo_List[BP_StoreMain_Tab_Select_Index + 1]
		if tabInfo == nil then
			return bRet
		end
		StoreMainUI.TryNotifyChangeScene(tabInfo.BgUrl)
		StoreMainUI.curShowUI.UIOnlyShow()
		bRet = true
	end

	EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN);
	return bRet
end

function StoreMainUI.UIOnlyHideAll()
	log("StoreMainUI.UIOnlyHideAll")
	if StoreMainUI.curShowUI and StoreMainUI.curShowUI.UIOnlyHide then
		StoreMainUI.curShowUI.UIOnlyHide()
	end

	StoreMainUI.StopLoopEmotion()
	LuaClassObj.HandleUIMessageNoFetch(bp_store_main, "UIOnlyHide");
	StoreMainUI.bShow = false
end

function StoreMainUI.UIOnlyShow(skipRestore)
	log("StoreMainUI.UIOnlyShow")
	-- 新增补给按钮红点
	BP_STORE_MAIN_SUPPLY_HAVE_RED_DOT = StoreRedDotModel.HasStoreSupplyRedDot();

	LuaClassObj.HandleUIMessageNoFetch(bp_store_main, "UIOnlyShow");
    StoreMainUI.bShow = true

	if skipRestore == true then

	else
		ModelDisplayer.Init();
		ModelDisplayer.Restore(ModelDisplayer.KEY_STORE_MAIN_UI);
	end

	if StoreMainUI.curShowUI and StoreMainUI.curShowUI.UIOnlyShow then
		local tabInfo = BP_ARRAY_StoreMain_TabInfo_List[BP_StoreMain_Tab_Select_Index + 1]
		if tabInfo == nil then
			return
		end
		StoreMainUI.TryNotifyChangeScene(tabInfo.BgUrl)
		StoreMainUI.curShowUI.UIOnlyShow()
	end
end

function StoreMainUI.UIOnlyHide(skipRestore)
	log("StoreMainUI.UIOnlyHide")
	if StoreMainUI.curShowUI and StoreMainUI.curShowUI.UIOnlyHide then
		StoreMainUI.curShowUI.UIOnlyHide()
	end

	StoreMainUI.StopLoopEmotion()
	if skipRestore == true then

	else
		ModelDisplayer.Store(ModelDisplayer.KEY_STORE_MAIN_UI);
	end

	LuaClassObj.HandleUIMessageNoFetch(bp_store_main, "UIOnlyHide");
    StoreMainUI.bShow = false
end

function StoreMainUI.GetPageByType(nTab1Id)
	local uiMap = 
	{
		[StoreSystem.Page_ID_Recommend] = StoreRecommendPage,
		[StoreSystem.Page_ID_Cloth] = StoreClothesUI,
		[StoreSystem.Page_ID_Weapon] = StoreWeaponUI,
		[StoreSystem.Page_ID_Car] = StoreVehicleUI,
		[StoreSystem.Page_ID_Item] = StorePropUI,
		[StoreSystem.Page_ID_Exchange] = StoreExchangeUI,
		[StoreSystem.Page_ID_Collect] = StoreCollectionWrappedUI,
		[StoreSystem.Page_ID_Parachute] = StoreOtherUI,
	}
	local ui = uiMap[nTab1Id]
	return ui
end


--初始化人物穿着
function StoreMainUI.InitAvatar()
	local WearingInfo = {}
	for i, v in pairs(DataMgr.rolewear) do
		local cfg = DataMgr.GetHallDepotItemDataByInsID(v)
		local ThisWearing = { itemID = cfg.resID,colorID = 0,patternID = 0 }
		table.insert(WearingInfo, ThisWearing)
	end
	ModelDisplayer.Init(WearingInfo)
end

function StoreMainUI.OnSelectedItem(ItemId, ColorId, PatternId, ForceEquip)
	log("xx ItemId="..ItemId)
	MultipleAvatar.StopAction()
	ModelDisplayer.Display(ItemId, ColorId, PatternId, ForceEquip)

	StoreMainUI.LoopEmotionByItemId(ItemId)
end

function StoreMainUI.LoopEmotionByItemId(ItemId)
	StoreMainUI.StopLoopEmotion()
	LobbyUI.StopEmotionSound()

	local cfg = Client.GetTableData("Item", ItemId)
	if cfg and cfg.RedEmotionId and cfg.RedEmotionId > 0 and cfg.RedEmotionPlayCD and cfg.RedEmotionPlayCD > 0 then
		local bEquip = MultipleAvatar.HasEquiped(ItemId)
		if bEquip then
			StoreMainUI.curEmotionCdTime = cfg.RedEmotionPlayCD
			StoreMainUI.curEmotionId     = cfg.RedEmotionId
			StoreMainUI.OnPlayAvatarEmotion(StoreMainUI.curEmotionId)
			StoreMainUI.emotionTimer     = Timer.InsertTimer(StoreMainUI.curEmotionCdTime, function()
				StoreMainUI.OnPlayAvatarEmotion(StoreMainUI.curEmotionId)
			end, true)
		end
	end
end

function StoreMainUI.ResetEmotionTimer()
	log("StoreMainUI.ResetEmotionTimer()")
	StoreMainUI.StopLoopEmotion()

	StoreMainUI.emotionTimer = Timer.InsertTimer(StoreMainUI.curEmotionCdTime, function()
		StoreMainUI.OnPlayAvatarEmotion(StoreMainUI.curEmotionId)
	end, true)
end

function StoreMainUI.StopLoopEmotion()
	if StoreMainUI.emotionTimer then
		Timer.RemoveTimer(StoreMainUI.emotionTimer)
		StoreMainUI.emotionTimer = nil
	end
end

function StoreMainUI.GetAvatarEquipments()
	return MultipleAvatar.ShowingAvatar:GetEquipments()
end

function StoreMainUI.AvatarIsMale()
	local SexType = MultipleAvatar.ShowingAvatarSextype
	if SexType == LobbyAvatar.SEX_MALE then
		return true
	else
		return false
	end
end

function StoreMainUI.GetSex()
	local SexType = MultipleAvatar.ShowingAvatarSextype or 1
	if SexType == LobbyAvatar.SEX_MALE then
		return 1
	else
		return 2
	end
end

function StoreMainUI.SwitchSex()
	MultipleAvatar.SwitchSex()
end

--测试tab列表
function StoreMainUI.TestData()
	StoreMainUI.tabInfoList = {}
	for i = 0,5,1 do
		local tabLv1 = {}
		tabLv1.nIndex = i
		tabLv1.nTabId = (i + 1)
		tabLv1.tabName = "tab"..i;
		tabLv1.bRedDot = false
		tabLv1.bOpenSub = false
		tabLv1.bSelected = false
		tabLv1.subTabList = {}

		if i == 1 or i == 2 then
			for j = 0,5,1 do
				local tabLv2 = {}
				tabLv2.nIndex = j
				tabLv2.nTabId = (j + 1)
				--tabLv2.tabIcon = "/Game/Arts/UI/TableIcons/ItemIcon/Currency/Task_icon_xp_128.Task_icon_xp_128"
				tabLv2.tabIcon = "/Game/UMG/Texture/Lobby_NoAtlas/Store_Int/shop_qiangxie_0005.shop_qiangxie_0005"
				tabLv2.bSelected = false
				tabLv2.bRedDot = false
				table.insert(tabLv1.subTabList, tabLv2)
			end
		end
		table.insert(StoreMainUI.tabInfoList, tabLv1)
	end
end

--展开特定tab子页签
function StoreMainUI.ExpandTabList(tab1Id, tab2Id)
	if tab2Id == 0 then
		return
	end
	local bFind = false
	local tabLen = #StoreMainUI.tabInfoList
	for i = 1, tabLen, 1 do
		--1级
		local tabLv1 = StoreMainUI.tabInfoList[i]
		if tabLv1.nTabId == tab1Id then
			local tab2Len = #tabLv1.subTabList
			for j = 1, tab2Len, 1 do
				--2级
				local tabLv2 = tabLv1.subTabList[j]
				if tabLv2.nTabId == tab2Id then
					log("xx 1")
					bFind = true
					break
				end
			end
			--展开此页签
			if bFind then
				tabLv1.bOpenSub = true
			end
			break
		end
	end
end

--计算页签红点
function StoreMainUI.UpdateTabListRedDot()
	local allReddotNum = 0
	local tabLen = #StoreMainUI.tabInfoList
	for i = 1, tabLen, 1 do
		local tabLv1 = StoreMainUI.tabInfoList[i]
		local tab2Len = #tabLv1.subTabList
		if tab2Len == 0 then
			tabLv1.bRedDot = StoreRedDotModel.HasRedDot(tabLv1.nTabId, 0, false)
			if tabLv1.bRedDot then
				allReddotNum = allReddotNum + 1
			end
		else
			local redNum = 0
			for j = 1, tab2Len, 1 do
				local tabLv2 = tabLv1.subTabList[j]
				tabLv2.bRedDot = StoreRedDotModel.HasRedDot(tabLv1.nTabId, tabLv2.nTabId, false)
				if tabLv2.bRedDot then
					redNum = redNum + 1
				end
			end
			tabLv1.bRedDot = redNum > 0
			allReddotNum = allReddotNum + redNum
		end
	end
	return allReddotNum
end

--生成显示tablist
function StoreMainUI.InitShowTabListData()
	BP_ARRAY_StoreMain_TabInfo_List = {}
	local tabLen = #StoreMainUI.tabInfoList
	
	for i = 0, tabLen-1, 1 do
		local tabLv1 = StoreMainUI.tabInfoList[i+1]
		local info = {}
		info.nIndex = #BP_ARRAY_StoreMain_TabInfo_List
		info.nTabLv = 1
		info.bOpenSub = tabLv1.bOpenSub
		info.nTab1Id = tabLv1.nTabId
		info.nTab2Id = 0
		info.BgUrl = tabLv1.BgUrl
		info.nSubTabNum = tabLv1.nSubTabNum
		info.tabName = tabLv1.tabName
		info.tabIcon = ""
		info.bSelected = tabLv1.bSelected
		info.bRedDot = tabLv1.bRedDot
		info.bLastTab2 = false
		table.insert(BP_ARRAY_StoreMain_TabInfo_List, info)

		if info.bOpenSub then
			for j = 0, #tabLv1.subTabList-1, 1 do
				local tabLv2 = tabLv1.subTabList[j+1]
				info = {}
				info.nIndex = #BP_ARRAY_StoreMain_TabInfo_List
				info.nTabLv = 2
				info.bOpenSub = false
				info.nTab1Id = tabLv1.nTabId
				info.nTab2Id = tabLv2.nTabId
				info.tabName = ""
				info.tabIcon = tabLv2.tabIcon
				info.bSelected = tabLv2.bSelected
				info.bRedDot = tabLv2.bRedDot
				info.bLastTab2 = (j == #tabLv1.subTabList - 1)
				table.insert(BP_ARRAY_StoreMain_TabInfo_List, info)
			end
		end
	end
	--log_tree("BP_ARRAY_StoreMain_TabInfo_List=",BP_ARRAY_StoreMain_TabInfo_List)
end

--收缩列表
function StoreMainUI.FoldTabList(exceptTab1Id)
	local bFold = false
	local tabLen = #StoreMainUI.tabInfoList
	for i = 0, tabLen-1, 1 do
		local tabLv1 = StoreMainUI.tabInfoList[i+1]
		if tabLv1.nTabId == exceptTab1Id then
			--none
		else
			if tabLv1.bOpenSub and #tabLv1.subTabList > 0 then
				bFold = true
			end
			tabLv1.bOpenSub = false
		end
	end
	return bFold
end

--计算tabIndex
function StoreMainUI.GetShowTabIndex(tabInfo)
	if tabInfo == nil then
		return 0
	end
	local tabLen = #BP_ARRAY_StoreMain_TabInfo_List
	for i = 0, tabLen-1, 1 do
		local info = BP_ARRAY_StoreMain_TabInfo_List[i+1]
		if info.nTab1Id == tabInfo.nTab1Id and info.nTab2Id == tabInfo.nTab2Id then
			return i
		end
	end
	return 0
end

function StoreMainUI.GetShowTabEndIndex()
	local selectIndex = BP_StoreMain_Tab_Select_Index;
	local info = BP_ARRAY_StoreMain_TabInfo_List[selectIndex + 1];
	if info.nTab2Id ~= 0 then
		return selectIndex;
	end

	info = StoreMainUI.tabInfoList[selectIndex + 1];
	if info.bOpenSub then
		return selectIndex + #info.subTabList;
	else
		return selectIndex;
	end
end

--处理点击tab时列表数据更新
function StoreMainUI.UpdateTabListDataWhenClickTab(bRealClick)
	local tbInfo = BP_ARRAY_StoreMain_TabInfo_List[BP_StoreMain_Tab_Select_Index + 1]
	if tbInfo == nil then
		return
	end
	--log_tree("tbInfo=", tbInfo)
	local tabLen = #StoreMainUI.tabInfoList
	for i = 0, tabLen-1, 1 do
		local tabLv1 = StoreMainUI.tabInfoList[i+1]
		if tabLv1.nTabId == tbInfo.nTab1Id then
			tabLv1.bSelected = true
			if tbInfo.nTab2Id == 0 then
				--点中一级页签
				local bOpenSub1 = false
				if tabLv1.bOpenSub then
					tabLv1.bOpenSub = false
				else
					tabLv1.bOpenSub = true
					bOpenSub1 = true
				end

				for j = 0, #tabLv1.subTabList-1, 1 do
					local tabLv2 = tabLv1.subTabList[j+1]
					if tabLv2.nTabId == tbInfo.nTab2Id then
						tabLv2.bSelected = true
					else
						if bOpenSub1 then
							tabLv2.bSelected = true
							bOpenSub1 = false
						else
							tabLv2.bSelected = false
						end
					end
				end
			else
				for j = 0, #tabLv1.subTabList-1, 1 do
					local tabLv2 = tabLv1.subTabList[j+1]
					if tabLv2.nTabId == tbInfo.nTab2Id then
						tabLv2.bSelected = true
					else
						tabLv2.bSelected = false
					end
				end
			end

		else
			tabLv1.bSelected = false

			for j = 0, #tabLv1.subTabList-1, 1 do
				local tabLv2 = tabLv1.subTabList[j+1]
				tabLv2.bSelected = false
			end
		end
	end
	if bRealClick then
		BP_StoreMain_Is_Jump_To_First = StoreMainUI.FoldTabList(tbInfo.nTab1Id)
	else
		BP_StoreMain_Is_Jump_To_First = true
	end
	StoreMainUI.UpdateTabListRedDot()
	--log_tree("StoreMainUI.tabInfoList=", StoreMainUI.tabInfoList)
end

function StoreMainUI.UpdateData()
	BP_STRUCT_StoreMain_MoneyInfo = StoreFuncUtils.GetMoneyInfo()
end

function StoreMainUI.UpdateUI()
	StoreMainUI.UpdateData()
	LuaClassObj.HandleUIMessageNoFetch(bp_store_main, "UpdateUI");
end

function StoreMainUI.Release()
    log("StoreMainUI.Release")
end

-- 移至StoreFuncUtils，使日韩版12.0的商城代码解耦
--function StoreMainUI.PurchaseItem(ShopInfo)
--	local BuyInfo = StoreFuncUtils.GetBuyInfo(ShopInfo.id)
--	local cfg = Client.GetTableData("Item", ShopInfo.item_id)
--
--	if StoreFuncUtils.IsWithCount(cfg.ItemType) then
--		MallBuyItemWithCountUI:Init()
--		MallBuyItemWithCountUI.SetData(ShopInfo, BuyInfo, nil, nil, StoreSystem.store_version)
--	else
--		StoreBuyUI:Init()
--		StoreBuyUI.SetData(ShopInfo, BuyInfo, nil, nil, StoreSystem.store_version)
--	end
--end
--
--function StoreMainUI.SendGift(ShopInfo)
--	local data = ShopInfo;
--	local resItem = Client.GetTableData("Item", data.item_id);
--	local moneyType, moneyPrice = StoreFuncUtils.get_money_type_and_price(data.id, 1, data);
--
--	local itemBuyInfo = StoreFuncUtils.GetBuyInfo(ShopInfo.id)
--	-- 购买数量
--	local buyNum = 1000000;
--	local limitType = 1;
--	if (ShopInfo.daily_buy_limit > 0 or ShopInfo.week_buy_limit > 0 or ShopInfo.permanet_buy_limit > 0) then
--		if itemBuyInfo ~= nil then
--			if (ShopInfo.daily_buy_limit > 0) then
--				buyNum = math.min(buyNum, ShopInfo.daily_buy_limit - itemBuyInfo.daily_buy_cnt);
--				limitType = 1;
--			end
--			if (ShopInfo.week_buy_limit > 0) then
--				buyNum = math.min(buyNum, ShopInfo.week_buy_limit - itemBuyInfo.week_buy_cnt);
--				limitType = 2;
--			end
--			if (ShopInfo.permanet_buy_limit > 0) then
--				buyNum = math.min(buyNum, ShopInfo.permanet_buy_limit - itemBuyInfo.permanet_buy_cnt);
--				limitType = 3;
--			end
--		end
--	end
--	local name = FuncUtil.GetItemName(resItem.ItemName, nil, nil)
--	local Info = {};
--	Info.data = data
--	Info.name = name;
--	Info.colorID = 0;
--	Info.patternID = 0;
--	Info.colorPatternCost = 0;
--	Info.money_type = StoreFuncUtils.MoneyTypeToChinaMoneyType(moneyType)
--
--	ShopGiftWithDayUI.ShowWithData(Info)
--end

--处理StoreMainUI的层级
function ShowStoreMainUI()
	UIManager.Show(eUIType.eStoreMainUI)
end

--关闭所有页签
function StoreMainUI.HideAllPage()
	for k,v in pairs(StoreMainUI.pageMap) do
		v.Hide()
	end
	StoreMainUI.pageMap = {}
end

-- 点击关闭按钮
function EventStoreMainUI_Close()
	StoreMainUI.CloseUI();
 
	EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTTYPE_CHECK_BACK_TO_VIEW, true);
end

-- 点击关闭按钮
function StoreMainUI.CloseUI()
	log("EventStoreMainUI_Close")
	StoreMainUI.CLearTimer();
	--关闭瓢字提示
	if UIManager.GetUI(eUIType.eSupplyMainUI)==nil then
		MultipleAvatar.EnableLobbyPutonEvent(false, nil)
	end
	StoreMainUI.HideAllPage()

	EventSystem:unregistEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_LIST, StoreMainUI.OnTabListInfo);
	EventSystem:unregistEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_BUY, StoreMainUI.OnPurchase)
	EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_TICKET_CHANGE, StoreMainUI.On_UC_Gold_Change)
	EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_GOLD_CHANGE, StoreMainUI.On_UC_Gold_Change)
	EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_DIAMOND_CHANGE, StoreMainUI.On_UC_Gold_Change)
	EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_GOLD_CHIP_CHANGE, StoreMainUI.On_UC_Gold_Change)
	EventSystem:unregistEvent(EVENTTYPE_NEXTDAY, EVENTID_NEXTDAY_ZERO, StoreMainUI.OnNextDayZeroCome)
	UIManager.Hide(eUIType.eStoreMainUI)
	StoreMainUI.bShow = false
	LuaClassObj.HandleUIMessageNoFetch(bp_store_main, "UIHide");

	EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE);
	LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "UIShowFromMall");

	StoreJumpToChestUI.Hide();
	LobbyUI.StopEmotionSound()
	StoreMainUI.StopLoopEmotion()
	ModelDisplayer.Destroy()
	LobbySceneManager.ChangeLight(LobbySceneManager.LIGHT_LOBBY)
	--处理跳转来源
	StoreMainUI.PostProcessJump()
end

--处理跳转来源
function StoreMainUI.PostProcessJump()
	if StoreMainUI.jumpInfo ~= nil and StoreMainUI.jumpInfo.FromUIType then
		--宠物
		if StoreMainUI.jumpInfo.FromUIType == JumpUtils.MODEL_ID_PET then
			local ui_manager = require("ui.manager");
			if ui_manager then
				ui_manager.ShowUI(ui_manager.UI_Config.pet_main)
			end
            StoreMainUI.jumpInfo.FromUIType = nil;
		end
	end
end

function EventStoreMainUI_Start_InitUI_1()
	log("EventStoreMainUI_Start_InitUI_1")
	StoreIndiaUtils.ReqH5Market()
	StoreMainUI.InitAvatar()
	--开启瓢字提示
	MultipleAvatar.EnableLobbyPutonEvent(true, nil)
end

function EventStoreMainUI_Start_InitUI_2()
	log("EventStoreMainUI_Start_InitUI_2")
	StoreSystem.GetTabList(StoreSystem.store_tab)
end

function EventStoreMainUI_Start_InitUI_3()
	log("EventStoreMainUI_Start_InitUI_3")
	StoreSystem.get_market_buy_info_req_v3()
	JumpUtils.RequestJumpMapInfo()
	LobbySceneManager.SetMallWeaponParticalVisiable(false)
end

-- 点击切换页签按钮
function EventStoreMainUI_Click_Tab()
	log("BP_StoreMain_Tab_Select_Index="..BP_StoreMain_Tab_Select_Index)
	if UIUtil.CanClickNow(ClickFrequencyLimit.StoreTab) == false then
		return;
	end

	local tabInfo = BP_ARRAY_StoreMain_TabInfo_List[BP_StoreMain_Tab_Select_Index + 1]
	if tabInfo == nil then
		return
	end
    --停止红装表情
    LobbyUI.StopEmotionSound()
    StoreMainUI.StopLoopEmotion()
    
	StoreRedDotModel.SetRedDotMap(tabInfo.nTab1Id, tabInfo.nTab2Id, false)
	StoreRedDotModel.SetTabNewbie(tabInfo.nTab1Id, tabInfo.nTab2Id, false)
	StoreMainUI.UpdateTabListDataWhenClickTab(true)
	StoreMainUI.InitShowTabListData()
	BP_StoreMain_Tab_Select_Index = StoreMainUI.GetShowTabIndex(tabInfo)
	LuaClassObj.HandleUIMessageNoFetch(bp_store_main, "UpdateTab");

	BP_StoreMain_Tab_Need_Show_Index = StoreMainUI.GetShowTabEndIndex();
	LuaClassObj.HandleUIMessageNoFetch(bp_store_main, "JumpToNeedShowTab");

	StoreMainUI.curShowUI = nil
	--首先隐藏
	for k,v in pairs(StoreMainUI.pageMap) do
		if k == tabInfo.nTab1Id then
			--
		else
			v.Hide()
		end
	end
	-- 隐藏宝箱跳转ui
	StoreJumpToChestUI.Hide()
	--再显示
	for k,v in pairs(StoreMainUI.pageMap) do
		if k == tabInfo.nTab1Id then
			StoreMainUI.curShowUI = v
			if tabInfo.nTab2Id == 0 then
				local id2 = StoreMainUI.GetFirstSubTabId(tabInfo.nTab1Id)
				if StoreMainUI.jumpInfo and StoreMainUI.jumpInfo.bValid then
					v.Show(tabInfo.nTab1Id, id2, StoreMainUI.jumpInfo)
				else
					v.Show(tabInfo.nTab1Id, id2)
				end
				v.UIOnlyShow();
			else
				if StoreMainUI.jumpInfo and StoreMainUI.jumpInfo.bValid then
					v.Show(tabInfo.nTab1Id, tabInfo.nTab2Id, StoreMainUI.jumpInfo)
				else
					v.Show(tabInfo.nTab1Id, tabInfo.nTab2Id)
				end
				v.UIOnlyShow();
			end
		else
			--
		end
	end
	if StoreMainUI.jumpInfo then
		StoreMainUI.jumpInfo.bValid = false
	end
end

-- 点击充值uc按钮
function EventStoreMainUI_Click_AddUC()
	log("EventStoreMainUI_Click_AddUC")
	RechargeUI:Init()
end

-- 点击补给按钮
function EventStoreMainUI_Click_Supply()
	log("EventStoreMainUI_Click_Supply")
	if not LobbyUI:CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_NEW_SUPPLY, false) then
		return
	end
	StoreMainUI.UIOnlyHide()
 	SupplyMainUI.Init(1);
end

function StoreMainUI.InitTabListInfo()
	log("[HHF]StoreMainUI.InitTabListInfo");
	local tbList = StoreSystem.store_data.store_list
	if tbList == nil then
		return
	end
	local tabList = {}
	for k,v in pairs(tbList) do
		table.insert(tabList, v)
	end	
	--log_tree("StoreMainUI.OnTabListInfo tabList = ", tabList)
	table.sort(tabList, function(left, right)
		if left[StoreSystem.label_market_index_rank] >= right[StoreSystem.label_market_index_rank] then
			return false
		else
			return true
		end
	end)

	local bFirstTab1 = true
	local bFirstTab2 = true
	StoreMainUI.firstPageId1 = 0
	StoreMainUI.firstPageId2 = 0
	StoreMainUI.tabInfoList = {}

	for k,v in pairs(tabList) do
		local tabLv1 = {}
		tabLv1.nTabId = v[StoreSystem.label_market_index_id]
		local tabNameId = v[StoreSystem.label_market_index_name]
		local cfg = Client.GetTableData("LocalizeRes", tabNameId)
		tabLv1.tabName = cfg.TextValue
		tabLv1.bOpenSub = false
		if bFirstTab1 then
			tabLv1.bSelected = true
			StoreMainUI.firstPageId1 = v[StoreSystem.label_market_index_id]
			bFirstTab1 = false
		else
			tabLv1.bSelected = false
		end
		tabLv1.BgUrl = v[StoreSystem.label_market_index_big_bg] or ""
		
		--二级子页签
		tabLv1.subTabList = {}
		local subList = v[StoreSystem.label_market_index_sub_list]
		if subList then
			local subList2 = {}
			for kk,vv in pairs(subList) do
				table.insert(subList2, {tabId=kk,iconId=vv})
			end
			subList = subList2
			table.sort(subList, function(left, right)
				if left.tabId >= right.tabId then
					return false
				else
					return true
				end
			end)
			
			for kk,vv in pairs(subList) do
				local tabLv2 = {}
				tabLv2.nIndex = 0
				tabLv2.nTabId = vv.tabId
				local cfg2 = Client.GetTableData("StoreTabIconConfig", vv.iconId)
				if cfg2 then
					tabLv2.tabIcon = cfg2.tabIcon
				else
					tabLv2.tabIcon = ""
				end
				
				
				if bFirstTab2 then
					tabLv2.bSelected = true
					StoreMainUI.firstPageId2 = vv.tabId
					bFirstTab2 = false
				else
					tabLv2.bSelected = false
				end
				table.insert(tabLv1.subTabList, tabLv2)
			end
		end
		tabLv1.nSubTabNum = #tabLv1.subTabList
		bFirstTab1 = false
		bFirstTab2 = false
		table.insert(StoreMainUI.tabInfoList, tabLv1)
	end

	return tabList;
end

--解析后台tab列表数据
function StoreMainUI.OnTabListInfo(res)
	if not UIManager.GetUI(eUIType.eStoreMainUI) or StoreMainUI.bShow == false then
		return
	end
	local tabList = StoreMainUI.InitTabListInfo();
	if tabList == nil then
		return
	end

	StoreMainUI.UpdateTabListRedDot()

	--跳转进入
	if StoreMainUI.jumpInfo and StoreMainUI.jumpInfo.bValid then
		StoreMainUI.ExpandTabList(StoreMainUI.jumpInfo.Tab1, StoreMainUI.jumpInfo.Tab2)
		StoreMainUI.InitShowTabListData()
		BP_StoreMain_Tab_Select_Index = StoreMainUI.GetTabIndexFromTabId(StoreMainUI.jumpInfo.Tab1, StoreMainUI.jumpInfo.Tab2)
		StoreMainUI.UpdateTabListDataWhenClickTab(false)
		StoreMainUI.InitShowTabListData()

		StoreMainUI.HideAllPage()
		for k,v in pairs(tabList) do
			StoreMainUI.pageMap[v[StoreSystem.label_market_index_id]] = StoreMainUI.GetPageByType(v[StoreSystem.label_market_index_id])
		end
		StoreMainUI.UpdateData();
		StoreMainUI.UpdateUI()

		local tabInfo = BP_ARRAY_StoreMain_TabInfo_List[BP_StoreMain_Tab_Select_Index + 1]
		if tabInfo == nil then
			return
		end
		--显示

		for k,v in pairs(StoreMainUI.pageMap) do
			if k == tabInfo.nTab1Id then
				StoreMainUI.curShowUI = v
				if tabInfo.nTab2Id == 0 then
					local id2 = StoreMainUI.GetFirstSubTabId(tabInfo.nTab1Id)
					v.Show(tabInfo.nTab1Id, id2, StoreMainUI.jumpInfo)
					v.UIOnlyShow();
				else
					v.Show(tabInfo.nTab1Id, tabInfo.nTab2Id, StoreMainUI.jumpInfo)
					v.UIOnlyShow();
				end
			else
				--
			end
		end
		StoreMainUI.jumpInfo.bValid = false		
	else
		StoreMainUI.InitShowTabListData()
		StoreMainUI.UpdateUI()

		--初始化页签page
		StoreMainUI.HideAllPage()
		for k,v in pairs(tabList) do
			StoreMainUI.pageMap[v[StoreSystem.label_market_index_id]] = StoreMainUI.GetPageByType(v[StoreSystem.label_market_index_id])
		end
		--默认显示第一页
		for k,v in pairs(StoreMainUI.pageMap) do
			if k == StoreMainUI.firstPageId1 then
				StoreMainUI.curShowUI = v
				v.Show(StoreMainUI.firstPageId1, StoreMainUI.firstPageId2)
				v.UIOnlyShow();
			else
				--
			end
		end
		
		--关闭购买
		StoreFuncUtils.HideVisibleDialog();
	end

	--协议回报后关闭大厅
	EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN);

	if StoreMainUI.onOpenFinishCallback then
		StoreMainUI.onOpenFinishCallback()
	end

	if UIManager.GetUI(eUIType.eTheFirstCharge) then
		UIManager.Show(eUIType.eTheFirstCharge);
	end
end

function StoreMainUI.UpdateBgUrl(PageId, Url)
	log("StoreMainUI.UpdateBgUrl: PageId = " .. PageId .. ", Url = " .. tostring(Url))
	if Url and Url ~= "" then
		for i, v in pairs(BP_ARRAY_StoreMain_TabInfo_List) do
			if v.nTab1Id == PageId then
				v.BgUrl = Url
			end
		end
	end

	if StoreMainUI.pageMap[PageId] == StoreMainUI.curShowUI then
		StoreMainUI.TryNotifyChangeScene(Url)
	end
end

function StoreMainUI.TryNotifyChangeScene(Url)
	StoreMainUI.preSceneBgUrl = Url
	local Page = StoreMainUI.curShowUI
	if Page and Page.ChangeScene and type(Page.ChangeScene) == "function" then
		Page.ChangeScene(Url)
	else
		--更改背景
		if Url and Url ~= "" then
			LobbySceneManager.ChangeMallSceneTexture(Url)
		else
			LobbySceneManager.ChangeMallSceneTexture(StoreMainUI.defaultTexture)
		end
	end
end

function StoreMainUI.GetTabIndexFromTabId(tab1Id, tab2Id)
	for i=1,#BP_ARRAY_StoreMain_TabInfo_List,1 do
		if BP_ARRAY_StoreMain_TabInfo_List[i].nTab1Id == tab1Id and BP_ARRAY_StoreMain_TabInfo_List[i].nTab2Id == tab2Id then
			return i-1
		end
	end
	return 0
end

-- 获取第一个子页签数据
function StoreMainUI.GetFirstSubTabId(nTab1Id)
	for k,v in pairs(StoreMainUI.tabInfoList) do
		if v.nTabId == nTab1Id then
			if #v.subTabList <= 0 then
				return 0
			else
				log("xx v.subTabList[1].nTabId="..v.subTabList[1].nTabId)
				return v.subTabList[1].nTabId
			end
			break
		end
	end
	return 0
end


--UC变化
function StoreMainUI.On_UC_Gold_Change()
	StoreMainUI.UpdateData();
	LuaClassObj.HandleUIMessageNoFetch(bp_store_main, "FreshUCGold");
end

--UTC0跨天后1分钟重新请求购买信息数据
function StoreMainUI.OnNextDayZeroCome()
	log("StoreMainUI.OnNextDayZeroCome");
	StoreMainUI.CLearTimer();
	StoreMainUI.timerGetBuyInfo = Timer.InsertTimer(30,
														function()
																		log("timer StoreSystem.get_market_buy_info_req_v3");
																		StoreSystem.get_market_buy_info_req_v3()
																	end,
																false);
end

function StoreMainUI.CLearTimer()
	if StoreMainUI.timerGetBuyInfo ~= nil then
		Timer.RemoveTimer(StoreMainUI.timerGetBuyInfo);
		StoreMainUI.timerGetBuyInfo = nil;
	end
end

function StoreMainUI.PlayAvatarEmotion(EmotionId)
	StoreMainUI.ResetEmotionTimer()
	StoreMainUI.OnPlayAvatarEmotion(EmotionId)
end

function StoreMainUI.OnPlayAvatarEmotion(EmotionId)
	MultipleAvatar.PlayAction(EmotionId)
	LobbyUI.PlayEmotionSound(EmotionId, 1, 0, DataMgr.roleData.uid, 2)
end

function StoreMainUI.OnPurchase(eventType, eventID, vars)
	local market_id = vars.market_id
	local info = vars.info
	--
	--local itemList = {
	--	id = info[StoreSystem.label_buy_rsp_item_id],
	--	shop_id = market_id,
	--	count = info[StoreSystem.label_buy_rsp_item_count],
	--	time_limit = info[StoreSystem.label_buy_rsp_item_valid],
	--	pattern = 0,
	--	color = 0,
	--}
	local itemInfoList = {}
	for i, v in pairs(info) do
		if StoreFuncUtils.CheckIsChest(v[StoreSystem.label_buy_rsp_item_id]) == false then
			local itemData = {
				res_id = v[StoreSystem.label_buy_rsp_item_id];
				count = v[StoreSystem.label_buy_rsp_item_count];
				valid_hours = v[StoreSystem.label_buy_rsp_item_valid];
				expire_ts = 0;
				color_id = 0;
				pattern_id = 0;
			};
			table.insert(itemInfoList, itemData);
		end
	end
	if #itemInfoList > 0 then
		CommonItemGetUI:ShowPanel(itemInfoList);
	end

	EventSystem:postEvent(EVENTTYPE_MALL, EVENTID_MALL_BUY_RESULT, { true,itemInfoList });
end


--跳转 大厅到商城
function StoreMainUI.JumpFromLobbyToStore(para)
	if not LobbyUI:CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_MALL) then
		BP_Lobby_MenuOpen = false
		return
	end
	BP_Lobby_MenuOpen = true;
	WardrobeUI.isShowing = false;
	StoreMainUI.Init(para)
	OpenBoxtUI.SetOpenBoxBackCamera(3);
	ClientSendBAReport(BP_ENUM_LOBBY_MENU_MALL, 0);
end

--跳转 宠物到商城
function StoreMainUI.JumpFromPetToStore(para)
	if not LobbyUI:CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_MALL) then
		BP_Lobby_MenuOpen = false
		return
	end
	BP_Lobby_MenuOpen = true;
	WardrobeUI.isShowing = false;
	para.FromUIType = JumpUtils.MODEL_ID_PET
	StoreMainUI.Init(para)
	OpenBoxtUI.SetOpenBoxBackCamera(3);
end

--跳转 商城到商城
function StoreMainUI.JumpFromStoreToStore(para)
	local region = Client.GetPublishRegion();
	if region == "JAPAN" or region == "KOREA" then
		SupplyMainUI.JumpFromSupplyToSupply(para);
	else
		StoreMainUI.jumpInfo = para
		StoreMainUI.ExpandTabList(StoreMainUI.jumpInfo.Tab1, StoreMainUI.jumpInfo.Tab2)
		StoreMainUI.InitShowTabListData()
		BP_StoreMain_Tab_Select_Index = StoreMainUI.GetTabIndexFromTabId(StoreMainUI.jumpInfo.Tab1, StoreMainUI.jumpInfo.Tab2)
		EventStoreMainUI_Click_Tab()
	end
end

--收藏界面用slua实现，包装一层方便原有框架调用。
StoreCollectionWrappedUI = StoreCollectionWrappedUI or {
	bShowing = false,
	tab_id = 0,
	subTab_id = 0,
	jump_info = nil,
	bRestore = false,
}

function StoreCollectionWrappedUI.Show(tab_id, subTab_id, jump_info)
	StoreCollectionWrappedUI.tab_id = tab_id;
	StoreCollectionWrappedUI.subTab_id = subTab_id;
	StoreCollectionWrappedUI.jump_info = jump_info;
	StoreCollectionWrappedUI.bRestore = false;
	local ui_manager = require("ui.manager");
	ui_manager.ShowUI(ui_manager.UI_Config.store_collection);
end

function StoreCollectionWrappedUI.JumpTo(tab_id, jump_info)
	StoreCollectionWrappedUI.tab_id = tab_id;
	StoreCollectionWrappedUI.subTab_id = 0;
	StoreCollectionWrappedUI.jump_info = jump_info;
	StoreCollectionWrappedUI.bRestore = false;
	local ui_manager = require("ui.manager");
	ui_manager.ShowUI(ui_manager.UI_Config.store_collection);
end

function StoreCollectionWrappedUI.Hide()
	local ui_manager = require("ui.manager");
	ui_manager.CloseUI(ui_manager.UI_Config.store_collection);
end

function StoreCollectionWrappedUI.UIOnlyShow()
	StoreCollectionWrappedUI.bRestore = true;
	local ui_manager = require("ui.manager");
	ui_manager.ShowUI(ui_manager.UI_Config.store_collection);
end

function StoreCollectionWrappedUI.UIOnlyHide()
	local ui_manager = require("ui.manager");
	ui_manager.HideUI(ui_manager.UI_Config.store_collection);
end
--


StoreOtherUI = StoreOtherUI or {
	bShowing = false,
	tab_id = 0,
	subTab_id = 0,
	jump_info = nil,
	bRestore = false,
}
function StoreOtherUI.Show(tab_id, subTab_id, jump_info)
	log(debug.traceback())
	log("StoreOtherUI.tab_id .. " ..tostring(tab_id))
	log("StoreOtherUI.subTab_id "..tostring(subTab_id) )
	log("StoreOtherUI.jump_info " .. tostring(jump_info))

	if jump_info ~= nil and jump_info.itemId ~= nil then
		if StoreFuncUtils.IsPetItemID(jump_info.itemId) then
			subTab_id = StoreSystem.label_subtype_pet;
		elseif StoreFuncUtils.IsParachuteItemID(jump_info.itemId) then
			subTab_id = StoreSystem.label_subtype_parachute;
		end
	end

	StoreOtherUI.tab_id = tab_id;
	StoreOtherUI.subTab_id = subTab_id;
	StoreOtherUI.jump_info = jump_info;
	StoreOtherUI.bRestore = false;
	log("store_other_show")
	if subTab_id == StoreSystem.label_subtype_pet then
		local ui_manager = require("ui.manager");
		ui_manager.CloseUI(ui_manager.UI_Config.store_other_parachute);
		ui_manager.ShowUI(ui_manager.UI_Config.store_other_pet);
	elseif subTab_id == StoreSystem.label_subtype_parachute then
		local ui_manager = require("ui.manager")
		if ui_manager then
			ui_manager.CloseUI(ui_manager.UI_Config.store_other_pet);
			ui_manager.ShowUI(ui_manager.UI_Config.store_other_parachute)
		end
	end
end

function StoreOtherUI.Hide()
	log("HIDE OTHERS")
	local ui_manager = require("ui.manager");
	if StoreOtherUI.subTab_id == StoreSystem.label_subtype_pet then
		ui_manager.CloseUI(ui_manager.UI_Config.store_other_pet);
	elseif StoreOtherUI.subTab_id == StoreSystem.label_subtype_parachute then
		ui_manager.CloseUI(ui_manager.UI_Config.store_other_parachute);
	end
end

function StoreOtherUI.UIOnlyShow()
	StoreOtherUI.bRestore = true;
	local ui_manager = require("ui.manager");
	if StoreOtherUI.subTab_id == StoreSystem.label_subtype_pet then
		ui_manager.ShowUI(ui_manager.UI_Config.store_other_pet);
	elseif StoreOtherUI.subTab_id == StoreSystem.label_subtype_parachute then
		ui_manager.ShowUI(ui_manager.UI_Config.store_other_parachute);
	end
end

function StoreOtherUI.UIOnlyHide()
	local ui_manager = require("ui.manager");
	if StoreOtherUI.subTab_id == StoreSystem.label_subtype_pet then
		ui_manager.HideUI(ui_manager.UI_Config.store_other_pet);
	elseif StoreOtherUI.subTab_id == StoreSystem.label_subtype_parachute then
		ui_manager.HideUI(ui_manager.UI_Config.store_other_parachute);
	end
end
