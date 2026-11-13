-- sami 新版补给主界面UI
SupplyMainUI = SupplyMainUI or
{
	subPage = { StoreActivitySupply_UI, StoreValuableSupply_UI, StoreNormalSupply_UI },
	openType = 0,
	lastTabSelectIndex = -1,

	-- 上一次购买的补给数据(开箱子动画用)
	lastBuyInfo = {},
	-- 上一次购买补给的信息（发送购买协议给后台用的数据）
	lastBuyItemData = {},
	lastSupplyData = {},
	--跳转信息
	jumpInfo = nil,
	-- 刷新下架宝箱计时器
	timerSupplyTimeout = nil,
	--是否来源于跳转
	bFromJump = false,
	bChangePage = false,
	bShow = false,
}
 

--页签数据
BP_STRUCT_SupplyMain_TabInfo =
{
	nIndex = 0,		--数组下标
	nTabId = 0,		--tabID
	tabName = "",	--tab名字
	bSelected = false,	--是否选中
	bUpFlag = false,	--是否有up的标记
	bRedDot = false,	--是否有红点
	iconPath = "",		--页签背景
	leftBgPath = "",	--左侧大背景
	nUIType = 0,		--界面类型
	bDiscount = false,	--是否有折扣
	bFree = false,		--是否有免费折扣
	--endTime = 0,		--补给箱下架时间（仅在lua使用）
	--rateUpEndTime = 0,--概率up结束时间（仅在lua使用）
}
BP_ARRAY_SupplyMain_TabInfo_List =
{
	BP_STRUCT_SupplyMain_TabInfo = _G.BP_STRUCT_SupplyMain_TabInfo;
}

--当前选择页签下标
BP_SupplyMain_Tab_Select_Index = 0;

--货币信息
BP_STRUCT_SupplyMain_MoneyInfo =
{
	nGold = 0,
	nUC = 0,
	nZhupai = 0,
	nSilver = 0,
	nGoldChip = 0,
	bShowZhupai = false,
}

function bp_supply_main_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_supply_main,
        {{Path="/Game/UMG/UI_Logic/Store/Supply/SupplyMainLogicUI_BP.SupplyMainLogicUI_BP_C", Container="Default", ZOrder=0}},
        {"Lobby"},
        false,
        false,
        true
    );
end


--sami 初始化显示，0-大厅入口，1-商城入口
function SupplyMainUI.Init(openType, jumpInfo)
    log("SupplyMainUI.Init")
	SupplyMainUI.jumpInfo = jumpInfo
	if jumpInfo then
		SupplyMainUI.bFromJump = true
	else
		SupplyMainUI.bFromJump = false
	end
	SupplyMainUI.bChangePage = false

	if openType == 0 then
        if GlobalData.IsJapanOrKorea() then
            GemReportUtils.ReportBtnClickEvent(GemReportUtils.SubEventName_LobbyClickStore_JK);
        else
            GemReportUtils.ReportBtnClickEvent(GemReportUtils.SubEventName_LobbyClickSupply);
        end
	else
		GemReportUtils.ReportBtnClickEvent(GemReportUtils.SubEventName_StoreClickSupply);
	end

	-- 日韩商城添加道具和兑换页签
	if GlobalData.IsJapanOrKorea() then
		table.insert(SupplyMainUI.subPage, StorePropUI);
		table.insert(SupplyMainUI.subPage, StoreExchangeUI);
		table.insert(SupplyMainUI.subPage, StoreCollectionWrappedUI);
		EventSystem:registEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_BUY, SupplyMainUI.OnPurchase);
	end
	
	EventSystem:registEvent(EVENTTYPE_STORE_DATA, EVENTID_SUPPLY_LIST, SupplyMainUI.OnSupplyTabListUpdate);
	SupplyMainUI.openType = openType
	SupplyMainUI.lastTabSelectIndex = -1;
	BP_SupplyMain_Tab_Select_Index = 0;
	LobbySceneManager.ShowMesh(LobbySceneManager.MALL_MESH_LobbyBgMesh)

	LuaClassObj.HandleDynamicCreation(bp_supply_main);
	LuaClassObj.HandleUIMessageNoFetch(bp_supply_main, "UIShow");
	UIManager.Show(eUIType.eSupplyMainUI)
	SupplyMainUI.bShow = true;
	if openType == 0 then
        --story=64163085 【商城镜头】-商城镜头调整
		--if GlobalData.IsJapanOrKorea() then
			LobbyCameraManager.SwitchCamera(10115)
		--else
		--	LobbyCameraManager.SwitchCamera(10112);
		--end
		LobbySceneManager.ChangeLight(LobbySceneManager.LIGHT_MALL_AVATAR);
		LobbySceneManager.ChangeMallSceneTexture(StoreMainUI.defaultTexture);
	end
	EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN);
	
	EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_TICKET_CHANGE, SupplyMainUI.On_UC_Gold_Change);
	EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_GOLD_CHANGE, SupplyMainUI.On_UC_Gold_Change);
	EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_DIAMOND_CHANGE, SupplyMainUI.On_UC_Gold_Change);
	EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_FP_TOKEN_CHANGE, SupplyMainUI.On_UC_Gold_Change);
	EventSystem:registEvent(EVENTTYPE_STORE_DATA, EVENTID_SUPPLY_BUY, SupplyMainUI.OnBuyCallBack);
	EventSystem:registEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_OPEN_BOX_PANEL, SupplyMainUI.OnOpenBoxPanelShow);
	EventSystem:registEvent(EVENTTYPE_ACTIVITY, EVENTID_SUPPLY_DISCOUNT_UPDATE, SupplyMainUI.OnTabDiscountUpdate);
	EventSystem:registEvent(EVENTTYPE_ACTIVITY, EVNETID_DATAMGR_ACTIVITY_CHANGE, SupplyMainUI.OnTabDiscountUpdate);

	LuaClassObj.HandleUIMessageNoFetch(bp_supply_main, "StartInitUI");
	SupplyMainUI.UIOnlyShowAll()
end

function EventSupplyMainUI_Start_InitUI_1()
	log("EventSupplyMainUI_Start_InitUI_1")
	--【【商城改版】试穿优化】 http://tapd.oa.com/iGameInternational/prong/stories/view/1020360302064013583
	-- 需要继承商城着装，防止在商城切换到补给时，着装被重置
	if SupplyMainUI.openType == 0 then
		SupplyMainUI.InitAvatar();
		--开启瓢字提示
		MultipleAvatar.EnableLobbyPutonEvent(true, nil)
	end
end

function EventSupplyMainUI_Start_InitUI_2()
	log("EventSupplyMainUI_Start_InitUI_2")
	StoreSystem.GetTabList(StoreSystem.supply_tab);
end

function EventSupplyMainUI_Start_InitUI_3()
	log("EventSupplyMainUI_Start_InitUI_3")
	SupplyMainUI.CheckUpdateSupplyHasTimeout();
	if GlobalData.IsJapanOrKorea() then
		StoreSystem.get_market_buy_info_req_v3()
		JumpUtils.RequestJumpMapInfo()
	end
end

--初始化人物穿着
function SupplyMainUI.InitAvatar()
	local WearingInfo = {}
	for i, v in pairs(DataMgr.rolewear) do
		local cfg = DataMgr.GetHallDepotItemDataByInsID(v)
		local ThisWearing = { itemID = cfg.resID,colorID = 0,patternID = 0 }
		table.insert(WearingInfo, ThisWearing)
	end
	ModelDisplayer.Init(WearingInfo)
end

-- 选中一个物品
function SupplyMainUI.OnSelectedItem(ItemId, ColorId, PatternId, needCheckPutOn, bPlaySound)
	MultipleAvatar.StopAction()
	if not needCheckPutOn or MultipleAvatar.HasEquiped(ItemId, ColorId, PatternId) == false then
		ModelDisplayer.Display(ItemId, ColorId, PatternId)
	else
		ModelDisplayer.Display(ItemId, ColorId, PatternId, true)
	end
    if bPlaySound then
        SupplyMainUI.LoopEmotionByItemId(ItemId);
    end
end

function SupplyMainUI.PlayAvatarEmotion(EmotionId)
	SupplyMainUI.ResetEmotionTimer()
	SupplyMainUI.OnPlayAvatarEmotion(EmotionId)
end

function SupplyMainUI.OnPlayAvatarEmotion(EmotionId)
	MultipleAvatar.PlayAction(EmotionId)
	LobbyUI.PlayEmotionSound(EmotionId, 1, 0, DataMgr.roleData.uid, 2)
end

function SupplyMainUI.LoopEmotionByItemId(ItemId)
	SupplyMainUI.StopLoopEmotion()
    LobbyUI.StopEmotionSound()

	local cfg = Client.GetTableData("Item", ItemId)
	if cfg and cfg.RedEmotionId and cfg.RedEmotionId > 0 and cfg.RedEmotionPlayCD and cfg.RedEmotionPlayCD > 0 then
		local bEquip = MultipleAvatar.HasEquiped(ItemId)
		if bEquip then
			SupplyMainUI.curEmotionCdTime = cfg.RedEmotionPlayCD;
			SupplyMainUI.curEmotionId     = cfg.RedEmotionId
			SupplyMainUI.OnPlayAvatarEmotion(SupplyMainUI.curEmotionId)
			SupplyMainUI.emotionTimer     = Timer.InsertTimer(SupplyMainUI.curEmotionCdTime or 0, function()
				SupplyMainUI.OnPlayAvatarEmotion(SupplyMainUI.curEmotionId)
			end, true)
		end
	end
end

function SupplyMainUI.ResetEmotionTimer()
	log("StoreMainUI.ResetEmotionTimer()")
	SupplyMainUI.StopLoopEmotion()

	SupplyMainUI.emotionTimer = Timer.InsertTimer(SupplyMainUI.curEmotionCdTime or 0, function()
		SupplyMainUI.OnPlayAvatarEmotion(SupplyMainUI.curEmotionId)
	end, true)
end

function SupplyMainUI.StopLoopEmotion()
	if SupplyMainUI.emotionTimer then
		Timer.RemoveTimer(SupplyMainUI.emotionTimer)
		SupplyMainUI.emotionTimer = nil
	end
end

-- 获取当前avatar穿着列表
function SupplyMainUI.GetAvatarEquipments()
	return MultipleAvatar.ShowingAvatar:GetEquipments()
end

-- 是否为男性
function SupplyMainUI.GetCurSexType()
	local SexType = MultipleAvatar.ShowingAvatarSextype
	if SexType == LobbyAvatar.SEX_MALE then
		return true
	else
		return false
	end
end

function SupplyMainUI.GetSex()
	if SupplyMainUI.GetCurSexType() then
		return 1;
	else
		return 2;
	end
end

-- 切换性别
function SupplyMainUI.SwitchSex()
	MultipleAvatar.SwitchSex()
end

-- 切换指定性别
function SupplyMainUI.ShowSex(sex)
	MultipleAvatar.ShowSex(sex);
end

function SupplyMainUI.UpdateData()
	--设置数据
	local tabMap = StoreSystem.supply_data.supply_list;
	if tabMap == nil then
		return;
	end

	-- 页签的折扣数据
	local tabDiscountNumList = SupplyMainUI.GetTabDiscountNum();

	local tabIdList = {};
	local serverTime = FuncUtil.GetServerTimeInSec();
	for k,v in pairs(tabMap) do
		if v[StoreSystem.label_shop_index_end_time] == nil or v[StoreSystem.label_shop_index_end_time] == 0 or v[StoreSystem.label_shop_index_end_time] > serverTime then
			tabIdList[#tabIdList + 1] = v;
		end
	end
	table.sort(tabIdList, 
		function(a, b)
			return a[StoreSystem.label_shop_index_sort] > b[StoreSystem.label_shop_index_sort];
		end);
	BP_ARRAY_SupplyMain_TabInfo_List = {}
	for i,v in ipairs(tabIdList) do
		local bpIndex = i - 1;
		local info = {}
		local supplyItemID = v[StoreSystem.label_shop_index_item_id];
		local itemCfg = Client.GetTableData("item", supplyItemID);
		if itemCfg ~= nil then 
			info.tabName = itemCfg.ItemName;
		else
			info.tabName = "unknow id "..tostring(supplyItemID);
		end
		info.nIndex = bpIndex;
		info.nTabId = v[StoreSystem.label_shop_index_id];
		info.bSelected = (BP_SupplyMain_Tab_Select_Index==bpIndex);
		info.bUpFlag = v[StoreSystem.label_shop_index_up_end_time] > 0 and v[StoreSystem.label_shop_index_up_end_time] > serverTime;--v[StoreSystem.label_shop_index_is_rate_up];
		info.bRedDot = StoreRedDotModel.HasRedDot(info.nTabId, 0, true);
		info.nUIType = v[StoreSystem.label_shop_index_mode];
		info.iconPath = v[StoreSystem.label_shop_index_tab_bg];
		info.leftBgPath = v[StoreSystem.label_shop_index_img_bg] or "";
		info.endTime = v[StoreSystem.label_shop_index_end_time];
		info.rateUpEndTime = v[StoreSystem.label_shop_index_up_end_time] or 0;
		if info.rateUpEndTime ~= 0 and info.rateUpEndTime < serverTime then
			info.rateUpEndTime = 0;
		end

		for kk, vv in pairs(tabDiscountNumList) do
			if kk == info.nTabId then
				info.bDiscount = true;
				if vv == 100 then
					info.bFree = true;
				end
				break;
			end
		end
		table.insert(BP_ARRAY_SupplyMain_TabInfo_List, info)
	end
	--log_tree("SupplyMainUI.UpdateData", BP_ARRAY_SupplyMain_TabInfo_List)

	BP_STRUCT_SupplyMain_MoneyInfo = StoreFuncUtils.GetMoneyInfo()

	if GlobalData.IsJapanOrKorea() then
		local tabMap = StoreSystem.store_data.store_list;
		if tabMap == nil then
			return;
		end

		local function MakeOtherTabInfo(otherTabId)
			local sys = StoreSystem;
			for k, v in pairs(tabMap) do
				local tabId = v[sys.label_market_index_id];
				if tabId == otherTabId then
					local info = {}
					local bpIndex = #BP_ARRAY_SupplyMain_TabInfo_List;
					local tabNameId = v[sys.label_market_index_name];
					local cfg = Client.GetTableData("LocalizeRes", tabNameId);
					info.tabName = cfg.TextValue;
					info.nIndex = bpIndex;
					info.nTabId = tabId;
					info.bSelected = BP_SupplyMain_Tab_Select_Index == bpIndex;
					info.bUpFlag = false;
					info.bRedDot = StoreRedDotModel.HasRedDot(info.nTabId, 0, false);
					if tabId == sys.Page_ID_Item then
						info.nUIType = 4;
					elseif tabId == sys.Page_ID_Exchange then
						info.nUIType = 5;
					elseif tabId == sys.Page_ID_Collect then
						info.nUIType = 6;
					end
					info.iconPath = "";
					info.leftBgPath = "";
					info.endTime = 0;
					info.rateUpEndTime = 0;
					table.insert(BP_ARRAY_SupplyMain_TabInfo_List, info)
				end
			end
		end

		MakeOtherTabInfo(StoreSystem.Page_ID_Item);
		MakeOtherTabInfo(StoreSystem.Page_ID_Exchange);
		MakeOtherTabInfo(StoreSystem.Page_ID_Collect);
	end
end

function SupplyMainUI.GetTabRedDotNum()
	local sys = StoreSystem;
	local tabMap = sys.supply_data.supply_list;
	if tabMap == nil then
		return 0;
	end
	local tabIdList = {};
	local serverTime = FuncUtil.GetServerTimeInSec();
	for k,v in pairs(tabMap) do
		if v[sys.label_shop_index_end_time] == nil or v[sys.label_shop_index_end_time] == 0 or v[sys.label_shop_index_end_time] > serverTime then
			tabIdList[#tabIdList + 1] = v;
		end
	end
	local redDotNum = 0
	for i,v in ipairs(tabIdList) do
		local nTabId = v[sys.label_shop_index_id];
		local bRedDot = StoreRedDotModel.HasRedDot(nTabId, 0, true);
		if bRedDot then
			redDotNum = redDotNum + 1
		end
	end

	if GlobalData.IsJapanOrKorea() then
		tabMap = sys.store_data.store_list;
		tabIdList = {};
		if tabMap then
			for k, v in pairs(tabMap) do
				local tabId = v[sys.label_market_index_id];
				if tabId == sys.Page_ID_Item
					or tabId == sys.Page_ID_Exchange then

					local bRedDot = StoreRedDotModel.HasRedDot(tabId, 0, false);
					if bRedDot then
						redDotNum = redDotNum + 1;
					end
				end
			end
		end
	end

	return redDotNum;
end

function SupplyMainUI.OnSupplyTabListUpdate(eventType, eventID, data)
	if SupplyMainUI.bShow == false or UIManager.GetUI(eUIType.eSupplyMainUI) == nil then
		return
	end
	if data.tab_type == StoreSystem.supply_tab then-- 页签数据

		--关闭成就
		if UIManager.GetUI(eUIType.eAchievementDetailUI) then
			LuaClassObj.HandleUIMessageNoFetch(bp_achievement_detail, "OnCloseBtnClick");
		end

		if UIManager.GetUI(eUIType.eTaskUI) then
			LuaClassObj.HandleUIMessageNoFetch(bp_task, "UIClose");
		end

	    --停止红装表情
	    LobbyUI.StopEmotionSound();
	    SupplyMainUI.StopLoopEmotion();
	    MultipleAvatar.StopAction();

		SupplyMainUI.UpdateUI();
		EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN);

		--关闭购买
		StoreFuncUtils.HideVisibleDialog();
	end
end


function SupplyMainUI.GetTabIndex(nTabId)
	for i = 1,#BP_ARRAY_SupplyMain_TabInfo_List,1 do
		if BP_ARRAY_SupplyMain_TabInfo_List[i].nTabId == nTabId then
			return i-1
		end
	end
	return 0
end

function SupplyMainUI.UpdateUI()
	if UIManager.GetUI(eUIType.eSupplyMainUI) == nil then
		return
	end
	if SupplyMainUI.jumpInfo then
		SupplyMainUI.UpdateData();
		BP_SupplyMain_Tab_Select_Index = SupplyMainUI.GetTabIndex(SupplyMainUI.jumpInfo.Tab1)
		SupplyMainUI.UpdateData();
	else
		SupplyMainUI.UpdateData();
		if BP_ARRAY_SupplyMain_TabInfo_List[BP_SupplyMain_Tab_Select_Index + 1] == nil then
			BP_SupplyMain_Tab_Select_Index = 0;
			SupplyMainUI.lastTabSelectIndex = -1
		end
		--SupplyMainUI.UpdateData();
	end
	
	LuaClassObj.HandleUIMessageNoFetch(bp_supply_main, "UpdateUI");
	--SupplyMainUI.ShowCurSelectPage();
	SupplyMainUI.UpdateSceneBgTexture();

	if SupplyMainUI.jumpInfo then
		local pageUI, supplyID = SupplyMainUI.GetPageUI();
		if pageUI ~= nil and pageUI.JumpTo then
			pageUI.JumpTo(supplyID, SupplyMainUI.jumpInfo);
			if SupplyMainUI.bShow == true then
				pageUI.UIOnlyShow();
			end
		end
		SupplyMainUI.jumpInfo = nil;
	else
		SupplyMainUI.HideAllPage();
		SupplyMainUI.ShowCurSelectPage();
	end
	--if UIManager.GetUI(eUIType.eRechargeUI) then
	--	LuaClassObj.HandleUIMessageNoFetch(bp_recharge, "UIHIde");
	--end
end

function SupplyMainUI.Release()
    log("SupplyMainUI.Release")

	for i,v in ipairs(SupplyMainUI.subPage) do
		if v.Hide ~= nil then
			v.Hide();
		end
	end
    for i,v in ipairs(SupplyMainUI.subPage) do
		if v.Release ~= nil then
			v.Release();
		end
	end
	if SupplyMainUI.timerSupplyTimeout ~= nil then
		Timer.RemoveTimer(SupplyMainUI.timerSupplyTimeout);
		SupplyMainUI.timerSupplyTimeout = nil;
	end
end

--跳转 商城到补给
function SupplyMainUI.JumpFromStoreToSupply(para)
	local region = Client.GetPublishRegion();
	if region == "JAPAN" or region == "KOREA" then
		SupplyMainUI.JumpFromSupplyToSupply(para);
	else
		if not LobbyUI:CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_NEW_SUPPLY, false) then
			return
		end
		StoreMainUI.UIOnlyHide()
		SupplyMainUI.Init(1, para)
	end
end

function SupplyMainUI.JumpFromSupplyToSupply(para)
	SupplyMainUI.jumpInfo = para
	BP_SupplyMain_Tab_Select_Index = SupplyMainUI.GetTabIndexFromTabId(SupplyMainUI.jumpInfo.Tab1, SupplyMainUI.jumpInfo.Tab2)
	EventSupplyMainUI_Click_Tab()
end

function SupplyMainUI.JumpFromLobbyToSupply(para)
	if not LobbyUI:CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_NEW_SUPPLY, false) then
		return
	end
	SupplyMainUI.Init(0, para)
    --播放消失动画
    OpenBoxtUI.SetOpenBoxBackCamera(3);
end

-- 宠物跳转到补给
function SupplyMainUI.JumpFromPetToSupply(para)
	SupplyMainUI.Init(0, para)
    OpenBoxtUI.SetOpenBoxBackCamera(3);
end

function SupplyMainUI.UIOnlyShowAll()
	SupplyMainUI.bShow = true;
	LobbyCameraManager.SwitchCamera(10112);
	LobbySceneManager.ChangeLight(LobbySceneManager.LIGHT_MALL_AVATAR);
	LobbySceneManager.ShowMesh(LobbySceneManager.MALL_MESH_LobbyBgMesh);
	for _, page in pairs(SupplyMainUI.subPage) do
		if page ~= nil and page.UIOnlyShow ~= nil then
			page.UIOnlyHide();
		end
	end
	for i,info in ipairs(BP_ARRAY_SupplyMain_TabInfo_List) do
		if BP_SupplyMain_Tab_Select_Index + 1 == i then
			local uiType = info.nUIType;
			local pageUI = SupplyMainUI.subPage[uiType]
			if pageUI ~= nil and pageUI.UIOnlyShow ~= nil then
				pageUI.UIOnlyShow();
				break;
			end
		end
	end
	SupplyMainUI.UpdateSceneBgTexture();
	LuaClassObj.HandleUIMessageNoFetch(bp_supply_main, "OnlyShowUI");
	EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN);
end

function SupplyMainUI.UIOnlyHideAll()
	--local pageUI, supplyID = SupplyMainUI.GetPageUI();
	--if pageUI ~= nil and pageUI.UIOnlyHide ~= nil then
	--	pageUI.UIOnlyHide();
	--end
	for _, pageUI in pairs(SupplyMainUI.subPage) do
		if pageUI ~= nil and pageUI.UIOnlyHide ~= nil then
			pageUI.UIOnlyHide();
		end
	end
	SupplyMainUI.bShow = false;
	LuaClassObj.HandleUIMessageNoFetch(bp_supply_main, "OnlyHideUI");
end

-- 点击关闭按钮
function EventSupplyMainUI_Close()
	log("EventSupplyMainUI_Close")
	if UIManager.GetUI(eUIType.eSupplyMainUI) == nil then
		return
	end
	SupplyMainUI.CloseUI();
	if SupplyMainUI.openType == 0 then

		EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTTYPE_CHECK_BACK_TO_VIEW, true);
		LobbySceneManager.ChangeLight(LobbySceneManager.LIGHT_LOBBY);
	elseif SupplyMainUI.openType == 1 then
		store_item_upgrade_system.SetCurrentModele(store_item_upgrade_system.module.weapon)
	end;
end

function SupplyMainUI.CloseUI()
	if UIManager.GetUI(eUIType.eSupplyMainUI) == nil then
		return
	end
	--关闭瓢字提示
	if UIManager.GetUI(eUIType.eStoreMainUI)==nil then
		MultipleAvatar.EnableLobbyPutonEvent(false, nil)
	end
	BP_SupplyMain_Tab_Select_Index = 0;
	SupplyMainUI.UpdateSceneBgTexture();
	EventSystem:unregistEvent(EVENTTYPE_STORE_DATA, EVENTID_SUPPLY_LIST, SupplyMainUI.OnSupplyTabListUpdate);
	EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_TICKET_CHANGE, SupplyMainUI.On_UC_Gold_Change);
	EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_GOLD_CHANGE, SupplyMainUI.On_UC_Gold_Change);
	EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_DIAMOND_CHANGE, SupplyMainUI.On_UC_Gold_Change);
	EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_FP_TOKEN_CHANGE, SupplyMainUI.On_UC_Gold_Change);
	EventSystem:unregistEvent(EVENTTYPE_STORE_DATA, EVENTID_SUPPLY_BUY, SupplyMainUI.OnBuyCallBack);
	EventSystem:unregistEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_OPEN_BOX_PANEL, SupplyMainUI.OnOpenBoxPanelShow);
	--EventSystem:unregistEvent(EVENTTYPE_ACTIVITY, EVENTID_ACTIVITY_INFO, ActivtyShaoJiUI.OnActInfo);
	EventSystem:unregistEvent(EVENTTYPE_ACTIVITY, EVENTID_SUPPLY_DISCOUNT_UPDATE, SupplyMainUI.OnTabDiscountUpdate);
	EventSystem:unregistEvent(EVENTTYPE_ACTIVITY, EVNETID_DATAMGR_ACTIVITY_CHANGE, SupplyMainUI.OnTabDiscountUpdate);

	UIManager.Hide(eUIType.eSupplyMainUI)
	SupplyMainUI.bShow = false;
	LuaClassObj.HandleUIMessageNoFetch(bp_supply_main, "UIHide");
    --停止红装表情
    LobbyUI.StopEmotionSound();
    SupplyMainUI.StopLoopEmotion();
    MultipleAvatar.StopAction();

	SupplyMainUI.Release();

	ModelDisplayer.Destroy()

	if SupplyMainUI.openType == 0 then
		EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE);
		LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "UIShowFromMall");
	else
		StoreMainUI.UIOnlyShow()
	end
end

-- 点击切换页签按钮
function EventSupplyMainUI_Click_Tab()
	log("EventSupplyMainUI_Click_Tab")
	local tabMap = StoreSystem.supply_data.supply_list;
	if tabMap == nil then
		StoreSystem.GetTabList(StoreSystem.supply_tab);
		return;
	end
	local selectIndex = BP_SupplyMain_Tab_Select_Index + 1;
	local tabInfo = BP_ARRAY_SupplyMain_TabInfo_List[selectIndex];
	if tabInfo == nil then
		return
	end

	if tabInfo.nTabId == StoreSystem.Page_ID_Item or tabInfo.nTabId == StoreSystem.Page_ID_Exchange then
		StoreRedDotModel.SetRedDotMap(tabInfo.nTabId, 0, false);
		StoreRedDotModel.SetTabNewbie(tabInfo.nTabId, 0, false);
	else
		StoreRedDotModel.SetRedDotMap(tabInfo.nTabId, 0, true);
		StoreRedDotModel.SetTabNewbie(tabInfo.nTabId, 0, true);
	end

	--选中同一个页签
	if SupplyMainUI.lastTabSelectIndex == BP_SupplyMain_Tab_Select_Index then
		SupplyMainUI.UpdateData();
		LuaClassObj.HandleUIMessageNoFetch(bp_supply_main, "FreshVisibleTab");
		return;
	else
	    --停止红装表情
	    LobbyUI.StopEmotionSound();
	    SupplyMainUI.StopLoopEmotion();
	    MultipleAvatar.StopAction();
	end

	SupplyMainUI.lastTabSelectIndex = BP_SupplyMain_Tab_Select_Index;
	SupplyMainUI.UpdateData()
	LuaClassObj.HandleUIMessageNoFetch(bp_supply_main, "FreshVisibleTab");
	SupplyMainUI.HideAllPage();
	SupplyMainUI.ShowCurSelectPage();
	SupplyMainUI.UpdateSceneBgTexture();
	SupplyMainUI.bChangePage = true
end

-- 点击充值uc按钮
function EventSupplyMainUI_Click_AddUC()
	log("EventSupplyMainUI_Click_AddUC")
	RechargeUI:Init()
end

-- 打开当前选中页签界面
function SupplyMainUI.HideAllPage()
	for i,v in ipairs(SupplyMainUI.subPage) do
		if v.Hide ~= nil then
			v.Hide();
		end
	end
end

-- 打开当前选中页签界面
function SupplyMainUI.ShowCurSelectPage()
	local pageUI, supplyID = SupplyMainUI.GetPageUI();
	log("SupplyMainUI.ShowCurSelectPage pageUI = "..tostring(pageUI).." supplyID = "..tostring(supplyID))
	if pageUI ~= nil and pageUI.Show ~= nil then
		if SupplyMainUI.jumpInfo then
			if pageUI.JumpTo then
				pageUI.JumpTo(supplyID, SupplyMainUI.jumpInfo);
			else
				pageUI.Show(supplyID, 0, SupplyMainUI.jumpInfo);
			end
			SupplyMainUI.jumpInfo = nil;
		else
			pageUI.Show(supplyID);
		end
		if SupplyMainUI.bShow == true then
			pageUI.UIOnlyShow();
		end
	else
		SupplyMainUI.HideAllPage();
	end
end

-- 获取具体页签模块
function SupplyMainUI.GetPageUI()
	local tabInfo = BP_ARRAY_SupplyMain_TabInfo_List[BP_SupplyMain_Tab_Select_Index + 1];
	if tabInfo ~= nil then
		local uiType = tabInfo.nUIType;
		return SupplyMainUI.subPage[uiType] or nil, tabInfo.nTabId;
	else
		return nil, nil;
	end
end

-- 获取当前选中补给商城ID
function SupplyMainUI.GetCurBuyShopID()
	if BP_STRUCT_STORE_ACTIVITY_SUPPLY_ITEM ~= nil then
		return BP_STRUCT_STORE_ACTIVITY_SUPPLY_ITEM.product_id;
	end
	return 0;
end

-- 检查当前购买过的补给在点击再次购买时是否还存在
function SupplyMainUI.CheckHasSupply()
	if SupplyMainUI.lastBuyInfo ~= nil then
		local tabMap = StoreSystem.supply_data.supply_list;
		--log_tree("tabMap", tabMap);
		--log_tree("SupplyMainUI.lastBuyInfo", SupplyMainUI.lastBuyInfo);
		for _, tabInfo in pairs(tabMap) do
			for supplyShopID, buyInfo in pairs(SupplyMainUI.lastBuyInfo) do
				if tabInfo[StoreSystem.label_shop_index_id] == supplyShopID then
					return true;
				end
				break;
			end
		end
	end
	return false;
end
--------------------------------------
-- 申请打开宝箱,其实是购买宝箱商品（10连抽）
function SupplyMainUI.RequestBuyTenSupplyBox(supplyData, dontNeedDoubleCheck)
    log("Buy_Item_ID:" .. supplyData.product_id);
	--log_tree("supplyData", supplyData);
	dontNeedDoubleCheck = dontNeedDoubleCheck or false;
	local buyItemData = {
		[1] = supplyData.product_id,
		[3] = supplyData.price_type,
		[6] = StoreSystem.supply_version,
		[8] = 10,
		[10] = supplyData.ten_price
	};
	--log_tree("buyItemData", buyItemData);
	-- 上一次购买的补给数据(开箱子动画用)
	local buyItemDataUseByClient = {[supplyData.product_id] = supplyData};

	-- 道具足够直接购买
	if not (supplyData.is_discount_ten and supplyData.price_type == 2 and supplyData.ten_price == 0) then
		if supplyData.key_item_id > 0 and supplyData.have_item_number >= supplyData.key_number * 10 then
			buyItemData[3] = StoreSystem.label_price_type_exchage;
			SupplyMainUI.lastBuyInfo = buyItemDataUseByClient;
			SupplyMainUI.lastBuyItemData = buyItemData;
			SupplyMainUI.lastSupplyData = supplyData
			StoreSystem.buy_shop_by_id_req(buyItemData);
			--上报
			SupplyMainUI.ReportBuyEvent(true, true, supplyData.item_id)
			return;
		end
	end

	local strBuy = Client.GetTableData("LocalizeRes", "301185").TextValue;
	local tip = "";
	if (supplyData.price_type == 0) then
		if (supplyData.ten_price <= DataMgr.gold) then
			tip = FuncUtil.GetLocalizeResStr("301186");
		else
			tip = FuncUtil.GetLocalizeResStr("4827");
		end
	else
		if (supplyData.ten_price <= DataMgr.ticket) then
			tip = FuncUtil.GetLocalizeResStr("301372");
		else
			tip = FuncUtil.GetLocalizeResStr("4826");
		end
	end
	tip = (string.gsub(tip, "\'", "\""));
	local supplyCfg = Client.GetTableData("Item", supplyData.item_id);
	if supplyCfg ~= nil then
		tip = FuncUtil.LocalizeResFormatByStr(tip, supplyData.ten_price, supplyCfg.ItemName);
	end

	log("buyItem: " .. tip);
	local buyFuc = function()
		if supplyData.price_type == 0 then-- 金币
			if (supplyData.ten_price > DataMgr.gold) then
				DataMgr.ShowMessageBoxByID(502024);
				return;
			end
		elseif supplyData.price_type == 2 then-- UC
			if (supplyData.ten_price > DataMgr.ticket) then
				--StoreSystem.ShowTipsByErrorCode(StoreSystem.error_code_uc_not_enough);
				-- 打开充值界面
				local title = Client.GetTableData("LocalizeRes", "101001").TextValue;
				local tip = Client.GetTableData("LocalizeRes", "4119").TextValue;
				CommonMessageBoxUI:ShowPanel(2, title, tip, function()
						RechargeUI:Init();
					return true;
				end);
				return;
			end
		end
		SupplyMainUI.lastBuyInfo = buyItemDataUseByClient;
		SupplyMainUI.lastBuyItemData = buyItemData;
		SupplyMainUI.lastSupplyData = supplyData
		StoreSystem.buy_shop_by_id_req(buyItemData);
		--上报
		if supplyData.price_type == 2 then
			SupplyMainUI.ReportBuyEvent(false, true, supplyData.item_id)
		end
		return true;
	end

	if supplyData.ten_price == 0 then
		dontNeedDoubleCheck = true;
	end

	if not dontNeedDoubleCheck then
		CommonMessageBoxUI:ShowPanel(2, strBuy, tip, buyFuc);
	else
		buyFuc();
	end
end

-- 申请打开宝箱,其实是购买宝箱商品 (单抽)
function SupplyMainUI.RequestBuySupplyBox(supplyData, isUseSelectPriceType, selectPriceType, dontNeedDoubleCheck)
	log("Buy_Item_ID:" .. supplyData.product_id)
	--log_tree("supplyData", supplyData);
	dontNeedDoubleCheck = dontNeedDoubleCheck or false;
	local buyItemData = {
		[1] = supplyData.product_id,
		[3] = supplyData.price_type,
		[6] = StoreSystem.supply_version,
		[8] = 1,
		[10] = supplyData.ticket_price
	};
	local buyItemDataUseByClient = {[supplyData.product_id] = supplyData};

	-- 道具足够直接购买
	if not (supplyData.is_discount and supplyData.price_type == 2 and supplyData.ticket_price == 0) then
		if (supplyData.key_item_id > 0 and supplyData.have_item_number >= supplyData.key_number) then
			buyItemData[3] = StoreSystem.label_price_type_exchage;
			SupplyMainUI.lastBuyInfo = buyItemDataUseByClient;
			SupplyMainUI.lastBuyItemData = buyItemData;
			SupplyMainUI.lastSupplyData = supplyData
			StoreSystem.buy_shop_by_id_req(buyItemData);
			--上报
			SupplyMainUI.ReportBuyEvent(true, false, supplyData.item_id)
			return;
		end
	end

	-- 使用选择的货币类型购买
	if isUseSelectPriceType then
		supplyData.price_type = selectPriceType;
		buyItemData[3] = selectPriceType;

		if (selectPriceType == 2) then
			buyItemData[10] = supplyData.ticket_price;
			if DataMgr.ticket < supplyData.ticket_price then--uc不足
                -- 打开充值界面
                local title = Client.GetTableData("LocalizeRes", "101001").TextValue;
                local tip = Client.GetTableData("LocalizeRes", "4119").TextValue;
                CommonMessageBoxUI:ShowPanel(2, title, tip, function()
                    RechargeUI:Init();
                    return true;
                end);
				return;
			end
		elseif selectPriceType == 102 then
			buyItemData[10] = supplyData.fp_token_price;
			if DataMgr.fp_token < supplyData.fp_token_price then
			    StoreSystem.ShowTipsByErrorCode(StoreSystem.error_code_fp_not_enough);
			    return;
			end
		elseif selectPriceType == 0 then--金币不足
			buyItemData[10] = supplyData.product_gold_price;
			if DataMgr.gold < supplyData.product_gold_price then
			    DataMgr.ShowMessageBoxByID(502024);
			    return;
			end
		end
		SupplyMainUI.lastBuyInfo = buyItemDataUseByClient;
		SupplyMainUI.lastBuyItemData = buyItemData;
		SupplyMainUI.lastSupplyData = supplyData
		StoreSystem.buy_shop_by_id_req(buyItemData);
		--上报
		if selectPriceType == 2 then
			SupplyMainUI.ReportBuyEvent(false, false, supplyData.item_id)
		end
		return;
	else
		local canUseTicket = false;
		if supplyData.ticket_price <= DataMgr.ticket and supplyData.price_type == 2 then
			canUseTicket = true;
		end

		local canUseGold = false;
		if supplyData.product_gold_price <= DataMgr.gold and supplyData.price_type == 0 then
			canUseGold = true;
		end

		local canUseFpToken = false;
		log("[yyc] fp_token num = "..tostring(DataMgr.fp_token));
		if supplyData.is_fp_token_valid and supplyData.fp_token_price <= DataMgr.fp_token then
			canUseFpToken = true;
		end

		--如果uc和炸猪令牌都可以使用，弹出选择窗口
		if canUseTicket and canUseFpToken and not (supplyData.is_discount and supplyData.price_type == 2 and supplyData.ticket_price == 0) then
			StorePriceSelect_UI.ShowByInfo(supplyData, supplyData.ticket_price, supplyData.fp_token_price);
			return;
		end

		if not canUseTicket and not canUseGold and canUseFpToken then
			buyItemData[3] = 102;--炸猪令牌
			supplyData.price_type = 102;
		end
	end

	local priceType = buyItemData[3];
	local strBuy = Client.GetTableData("LocalizeRes", "301185").TextValue;
	local tip = "";
	if (priceType == 0) then-- 金币
		if (supplyData.product_gold_price <= DataMgr.gold) then
			tip = FuncUtil.GetLocalizeResStr("301186");
		else
			tip = FuncUtil.GetLocalizeResStr("4827");
		end

		buyItemData[10] = supplyData.product_gold_price;
		if supplyData.product_gold_price == 0 then
			dontNeedDoubleCheck = true;
		end
	elseif priceType == 102 then--炸猪令牌
		tip = FuncUtil.GetLocalizeResStr("4983");

		buyItemData[10] = supplyData.fp_token_price;
		if supplyData.fp_token_price == 0 then
			dontNeedDoubleCheck = true;
		end
	elseif priceType == 2 then-- uc
		if (supplyData.ticket_price <= DataMgr.ticket) then
			tip = FuncUtil.GetLocalizeResStr("301372");
		else
			tip = FuncUtil.GetLocalizeResStr("4826");
		end

		buyItemData[10] = supplyData.ticket_price;
		if supplyData.ticket_price == 0 then
			dontNeedDoubleCheck = true;
		end
	end
	tip = (string.gsub(tip, "\'", "\""));
	local supplyCfg = Client.GetTableData("Item", supplyData.item_id);
	if supplyCfg ~= nil then
		if (priceType == 2) then
			tip = FuncUtil.LocalizeResFormatByStr(tip, supplyData.ticket_price, supplyCfg.ItemName);
		elseif priceType == 102 then
			tip = FuncUtil.LocalizeResFormatByStr(tip, supplyData.fp_token_price, supplyCfg.ItemName);
		elseif priceType == 0 then
			tip = FuncUtil.LocalizeResFormatByStr(tip, supplyData.product_gold_price, supplyCfg.ItemName);
		end
	end

	local buyFunc = function()
		if (priceType == 2) then
			if DataMgr.ticket < supplyData.ticket_price then--uc不足
				 --StoreSystem.ShowTipsByErrorCode(StoreSystem.error_code_uc_not_enough);
				-- 打开充值界面
				local title = Client.GetTableData("LocalizeRes", "101001").TextValue;
				local tip = Client.GetTableData("LocalizeRes", "4119").TextValue;
				CommonMessageBoxUI:ShowPanel(2, title, tip, function()
						RechargeUI:Init();
					return true;
				end);
				return;
			end
		elseif priceType == 102 then--金币不足
			if DataMgr.fp_token < supplyData.fp_token_price then
				 StoreSystem.ShowTipsByErrorCode(StoreSystem.error_code_fp_not_enough);
				 return;
			end
		elseif priceType == 0 then
			if DataMgr.gold < supplyData.product_gold_price then
				 DataMgr.ShowMessageBoxByID(502024);
				 return;
			end
		end
		SupplyMainUI.lastBuyInfo = buyItemDataUseByClient;
		SupplyMainUI.lastBuyItemData = buyItemData;
		SupplyMainUI.lastSupplyData = supplyData
		StoreSystem.buy_shop_by_id_req(buyItemData);

		--上报
		if priceType == 2 then
			SupplyMainUI.ReportBuyEvent(false, false, supplyData.item_id)
		end
		return true;
	end

	if not dontNeedDoubleCheck then
		CommonMessageBoxUI:ShowPanel(2, strBuy, tip, buyFunc);
	else
		buyFunc();
	end

	--GlobalData:JumpUrl("game://?module=10505");
end

--UC变化
function SupplyMainUI.On_UC_Gold_Change()
	SupplyMainUI.UpdateData()
	LuaClassObj.HandleUIMessageNoFetch(bp_supply_main, "FreshUCGold");
end

-- 购买回包
function SupplyMainUI.OnBuyCallBack(eventType, eventID, shop_id, info)

end

-- 打开开箱界面时，需要停止红装表情和音效
function SupplyMainUI.OnOpenBoxPanelShow()
	if UIManager.GetUI(eUIType.eSupplyMainUI) then
		--停止红装表情
		LobbyUI.StopEmotionSound();
		SupplyMainUI.StopLoopEmotion();
		MultipleAvatar.StopAction();
	end
end

-- 创建补给箱数据
function SupplyMainUI.MakeSupplyInfo(data)
	local item = {};
	item.product_id = data[StoreSystem.label_shop_index_id];
	item.item_id = data[StoreSystem.label_shop_index_item_id];
	item.product_sort = data[StoreSystem.label_shop_index_sort];
	item.end_time = data[StoreSystem.label_shop_index_detail_end_time];
	item.home_page_tex_path = data[StoreSystem.label_shop_index_home_bg] or "";
	item.item_list_tex_path = data[StoreSystem.label_shop_index_banner] or "";
	-- 补给箱图标
	item.icon_tex_path = data[StoreSystem.label_shop_index_icon] or "";
	-- 默认性别
	item.gender = data[StoreSystem.label_shop_index_gender] or 0;
	-- 积分奖励
	item.is_cur_season = data[StoreSystem.label_shop_index_upass_score] or 0;
	-- label_shop_index_left_count_best
	item.lowest_rounds = data[StoreSystem.label_shop_index_left_count_best] or 30;
	-- 掉率（无需传到本模块蓝图）
	item.drop_rate = data[StoreSystem.label_shop_index_drop_rate_list] or {};
	-- 概率UP
	item.is_rate_up = data[StoreSystem.label_shop_index_is_rate_up] or false;
	item.rate_up_end_time = data[StoreSystem.label_shop_index_show_up_end_time] or 0;
	-- 海报
	item.poster_path = data[StoreSystem.label_shop_index_img] or "";
	-- vip类型
	item.vip_type = data[StoreSystem.label_shop_index_vip] or 0;
	-- 折扣类型（默认没有，后面有逻辑修改这个字段）
	item.discount_type = StoreFuncUtils.DiscountType_NONE;
	item.is_discount = false;
	item.discount_number = 0;

	-- 十连抽价格(默认值)
	item.ten_price = 0;
	item.orgin_ticket_price = 0;
	item.ticket_price = 0;
	item.product_gold_price = 0;
	item.fp_token_price = 0;
	-- 十连抽UC原价
	item.ten_origin_price = 0;
	local priceData = data[StoreSystem.label_shop_index_price_list];
	for _, info in ipairs(priceData) do
		local priceType = info[StoreSystem.label_price_index_price_type];
		local priceOneOrigin = info[StoreSystem.label_price_index_one_original_price];-- 单抽原价
		local priceTenDiscount = info[StoreSystem.label_price_index_ten_discount_price];-- 十连抽折扣价
		if priceType == StoreSystem.label_price_type_uc then--uc币
			item.orgin_ticket_price = priceOneOrigin or 0;-- 用于计算折扣用
			item.ticket_price = priceOneOrigin or 0;-- 用于显示逻辑用
			item.ten_price = priceTenDiscount or 0;
			item.ten_origin_price = priceOneOrigin * 10;
			item.price_type = priceType;
		elseif priceType == StoreSystem.label_price_type_bp then--金币
			item.product_gold_price = priceOneOrigin or 0;
			item.ten_price = priceTenDiscount or 0;
			item.ten_origin_price = priceOneOrigin * 10;
			item.price_type = priceType;
		elseif priceType == StoreSystem.label_price_type_fp then--炸猪令牌
			item.fp_token_price = priceOneOrigin or 0;
		end
	end

	item.is_fp_token_valid = item.fp_token_price ~= 0;

	-- 可用兑换物品，暂时只支持一个
	item.key_item_id = 0;
	item.key_number = 0;
	local keyItemData = data[StoreSystem.label_shop_index_exchange_list] or {};
	for k,v in pairs(keyItemData) do
		item.key_item_id = k;
		item.key_number = v;
		item.have_item_number = DataMgr.GetHallDepotItemCountByResID(k);
		break;
	end
	-- 预览服装
	item.preview_items = data[StoreSystem.label_shop_index_preview_items];

	--log_tree("SupplyMainUI.MakeSupplyInfo---",item);
	return item;
end

-- 创建补给箱内单个物品数据
function SupplyMainUI.MakeSupplyDropInfo(data)
	local dropData = {};
	--log_tree("SupplyMainUI.MakeSupplyDropInfo", data);
	dropData.DropItemID = data[StoreSystem.label_drop_index_item_id] or data.DropItemID;
	dropData.DropItemNum = data[StoreSystem.label_drop_index_item_num] or 0;
	local oldChance = data[StoreSystem.label_drop_index_old_chance] or 0;
	if oldChance ~= 0 then
		dropData.DropRate_f = math.ceil(data[StoreSystem.label_drop_index_chance] / oldChance * 100);
	else
		dropData.DropRate_f = 100;
	end
	dropData.rate_up_end_time = data[StoreSystem.label_drop_index_up_end_time] or 0;
	dropData.DropItemSort = data[StoreSystem.label_drop_index_item_sort] or 0;
	dropData.drop_type = data[StoreSystem.label_drop_index_item_type] or data.DropType;-- 4951;
	dropData.is_equiped = MultipleAvatar.HasEquiped(dropData.DropItemID);
	dropData.is_hot = false;
	dropData.is_new = false;
	dropData.expression_id = data[StoreSystem.label_drop_index_expression_id] or 0;

	dropData.is_limit_time = data[StoreSystem.label_drop_index_item_time] > 0
	dropData.limit_end_time = data[StoreSystem.label_drop_index_item_time] or 0;
	local cfg = Client.GetTableData("Item", dropData.DropItemID);
	if dropData.is_limit_time == false then
		if cfg and cfg.ValidTimes and cfg.ValidTimes ~= 0 then
			dropData.is_limit_time = true;
			dropData.limit_end_time = cfg.ValidTimes;
		end
	end

	return dropData;
end

-- 通过物品ID查找补给列表中的表情ID
function SupplyMainUI.GetEmotionIDByItemID(dropItemList, itemID)
	for i,v in ipairs(dropItemList) do
		if v.DropItemID == itemID then
			return v.expression_id or 0;
		end
	end
	return 0;
end

-- 刷新场景图片
function SupplyMainUI.UpdateSceneBgTexture()
	local info = BP_ARRAY_SupplyMain_TabInfo_List[BP_SupplyMain_Tab_Select_Index + 1];
	if info and info.leftBgPath ~= nil and info.leftBgPath ~= "" then
		LobbySceneManager.ChangeMallSceneTexture(info.leftBgPath);
	else
		LobbySceneManager.ChangeMallSceneTexture(StoreMainUI.defaultTexture);
	end
end

function SupplyMainUI.CheckUpdateSupplyHasTimeout()
	local checkFunc = function()
		if BP_ARRAY_SupplyMain_TabInfo_List ~= nil then
			local tabMap = StoreSystem.supply_data.supply_list;
			if tabMap == nil then
				log("SupplyMainUI.CheckUpdateSupplyHasTimeout tabMap == nil, StoreSystem.GetTabList(StoreSystem.supply_tab)")
				StoreSystem.GetTabList(StoreSystem.supply_tab);
			else
				local serverTime = FuncUtil.GetServerTimeInSec();
				for i,v in ipairs(BP_ARRAY_SupplyMain_TabInfo_List) do
					if (v.endTime ~= nil and v.endTime ~= 0 and v.endTime < serverTime) then
						SupplyMainUI.lastTabSelectIndex = -1;
						BP_SupplyMain_Tab_Select_Index = 0;
						SupplyMainUI.UpdateUI();
						break;
					end
					if (v.rateUpEndTime ~= nil and v.rateUpEndTime ~= 0 and v.rateUpEndTime < serverTime) then
						SupplyMainUI.UpdateUI();
						break;
					end
				end
			end
		end
	end
	if SupplyMainUI.timerSupplyTimeout ~= nil then
		Timer.RemoveTimer(SupplyMainUI.timerSupplyTimeout);
		SupplyMainUI.timerSupplyTimeout = nil;
	end
	SupplyMainUI.timerSupplyTimeout = Timer.InsertTimer(5, checkFunc, true, true);
end

function SupplyMainUI.IsOpen()
	if not LobbyUI:CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_NEW_SUPPLY, false) then
		return false
	end
	return true
end

--购买上报
function SupplyMainUI.ReportBuyEvent(bItem, bTen, itemId)
	if SupplyMainUI.bFromJump == false then
		return
	end
	local name = ""
	if SupplyMainUI.bChangePage then
		if bItem then
			name = GemReportUtils.SubEventName_JumpBuySupplyChangePageItem
		else
			name = GemReportUtils.SubEventName_JumpBuySupplyChangePageUC
		end
	else
		if bItem then
			name = GemReportUtils.SubEventName_JumpBuySupplyNoChangePageItem
		else
			name = GemReportUtils.SubEventName_JumpBuySupplyNoChangePageUC
		end
	end
	local para1 = 1
	if bTen then
		para1 = 10
	end
	GemReportUtils.ReportEventImmediate(GemReportUtils.EventName_JumpBuyEvent, name, para1, itemId)
end

-- 更新单抽折扣数据
function SupplyMainUI.UpdateSupplyOneDiscountInfo(supplyItem)
	local args = SupplyMainUI.GetSupplyDiscountInfo(supplyItem, ActivityType["SUPPLY_BUY_ONE"]);

	local activityTimeStr = args[1];
	supplyItem.discount_total_count = args[4];
	supplyItem.discount_use_count = args[5];
	supplyItem.discount_next_number = args[6];
	supplyItem.discount_next_start_time = args[7];

	local discount = args[3];
	if discount > 0 then
		local price =  math.ceil(supplyItem.orgin_ticket_price * (100 - discount) / 100);
		if price < supplyItem.ticket_price then
			supplyItem.ticket_price = price;--math.ceil(supplyItem.ticket_price * (100 - supplyItem.discount_number) / 100);
			supplyItem.discount_type = StoreFuncUtils.DiscountType_DISCOUNT_ACTIVITY;
			supplyItem.is_discount = args[2];
			supplyItem.discount_number = args[3];
		end
	else
		if supplyItem.discount_type == StoreFuncUtils.DiscountType_NONE and supplyItem.discount_next_number > 0 and supplyItem.discount_next_start_time > 0 then
			supplyItem.discount_type = StoreFuncUtils.DiscountType_DISCOUNT_ACTIVITY;
			supplyItem.is_discount = args[2];
			supplyItem.discount_number = args[3];
		end
	end

	return activityTimeStr;
end

-- 根据订阅状态更新单抽折扣数据
function SupplyMainUI.UpdateSupplyOneDiscountInfoByVip(supplyItem)
	log_tree("SupplyMainUI.UpdateSupplyOneDiscountInfoByVip", supplyItem)
	local res = NewSubscribeSystem.Get_Supply_Status() or false;
	--log("NewSubscribeSystem.Get_Supply_Status() = "..tostring(res))
	if supplyItem.vip_type ~= 0 and NewSubscribeSystem.Get_Supply_Status() == true then
		local vipDiscount = NewSubscribeSystem.Get_Supply_Discount_Num();
		local vipDiscountPrice = math.ceil(vipDiscount * supplyItem.orgin_ticket_price);
		if vipDiscountPrice < supplyItem.ticket_price then
			supplyItem.discount_type = StoreFuncUtils.DiscountType_VIP;
			supplyItem.ticket_price = vipDiscountPrice;
			supplyItem.is_discount = true;
			supplyItem.discount_number = (1 - vipDiscount) * 100;
		end
	end
end

-- 更新十连抽折扣数据
function SupplyMainUI.UpdateSupplyTenDiscountInfo(supplyItem)
	local args = SupplyMainUI.GetSupplyDiscountInfo(supplyItem, ActivityType["SUPPLY_BUY_TEN"]);

	local activityTimeStr = args[1];
	supplyItem.is_discount_ten = args[2];
	supplyItem.discount_number_ten = args[3];
	supplyItem.discount_total_count_ten = args[4];
	supplyItem.discount_use_count_ten = args[5];
	supplyItem.discount_next_number_ten = args[6];
	supplyItem.discount_next_start_time_ten = args[7];

	if supplyItem.discount_number_ten > 0 then
		supplyItem.ten_price = math.ceil(supplyItem.ten_origin_price * (100 - supplyItem.discount_number_ten) / 100);
	end

	return activityTimeStr;
end

-- 获取折扣数据
function SupplyMainUI.GetSupplyDiscountInfo(supplyItem, actType)
	local activityTimeStr;
    local isActive = false;
	local isDiscount = false;
	local discountNumber = 0;
	local totalCount = 0;
	local useCount = 0;
	local nextDiscountNum = 0;
	local nextStartTime = 0;

	local sys = StoreSystem;
	local openCount = 0;
	local freeCount = 0;
	local discountCount = 0;
	local validDays = 0;

    local function GetNextStartTime(startTime, timeGap)
        if startTime == nil or timeGap == nil then
            return 0;
        end

        local serverTime = FuncUtil.GetServerTimeInSec();
        local lastResetTime = math.floor(startTime / 86400) * 86400;
        while lastResetTime < serverTime do
            lastResetTime = lastResetTime + timeGap * 86400;
        end
        return lastResetTime;
    end

	for k, v in pairs(DataMgr.activity.data) do
		if v and v.Type and v.Type == actType then
			--log_tree("[edward][bp_supply_main] ", v);
			for ii, vv in ipairs(v.List) do
				local args = string.split(vv.Condition, ",");
				for iii, vvv in ipairs(args) do
					args[iii] = tonumber(vvv);
				end

				if args[sys.label_discount_activity_product_id] == supplyItem.product_id then
					if args[sys.label_discount_activity_start_index] == 1 then
						nextDiscountNum = args[sys.label_discount_activity_number];
						validDays = args[sys.label_discount_activity_valid_days];
						if validDays and validDays == 0 then
							validDays = 30;
						end
					end

					if v.other.open_count and v.other.open_count[args[sys.label_discount_activity_product_id]] then
						openCount = v.other.open_count[args[sys.label_discount_activity_product_id]];
					else
						openCount = 0;
					end

                    if v.other.last_reset_time and v.other.last_reset_time[args[sys.label_discount_activity_product_id]] then
                        nextStartTime = v.other.last_reset_time[args[sys.label_discount_activity_product_id]] + validDays * 86400;
                    else
                        nextStartTime = GetNextStartTime(v.StartTime, validDays);
                    end

					if not isDiscount and openCount < args[sys.label_discount_activity_end_index] then
						isDiscount = true;
						discountNumber = args[sys.label_discount_activity_number];
						--if args[sys.label_discount_activity_number] == 100 then
						--	break;
						--end
					end

					discountCount = discountCount + args[sys.label_discount_activity_end_index] - args[sys.label_discount_activity_start_index] + 1;

					--if args[sys.label_discount_activity_number] == 100 then
					--	freeCount = freeCount + args[sys.label_discount_activity_end_index] - args[sys.label_discount_activity_start_index] + 1;
					--end
                    isActive = true;
				end
			end

			if discountNumber > 0 then
				--totalCount = discountCount - freeCount;
				--useCount = openCount - freeCount;
                totalCount = discountCount;
                useCount = openCount;
				nextDiscountNum = 0;
			elseif discountNumber == 0 then
				if nextStartTime >= v.EndTime then
					nextDiscountNum = 0;
				end
			end

            if isActive then
                isDiscount = true;
                activityTimeStr = StoreFuncUtils.GetDiscountTimePeriodStr(v.StartTime, v.EndTime);
            end
		end
	end

	return {activityTimeStr, isDiscount, discountNumber, totalCount, useCount, nextDiscountNum, nextStartTime};
end

-- 获取页签的折扣数据
function SupplyMainUI.GetTabDiscountNum()
	local tabDiscountNumList = {};

	local sys = StoreSystem;
	local openCount = 0;
	local currProductID = 0;

	for k, v in pairs(DataMgr.activity.data) do
		if v and v.Type and (v.Type == ActivityType["SUPPLY_BUY_ONE"] or v.Type == ActivityType["SUPPLY_BUY_TEN"]) then
			for ii, vv in ipairs(v.List) do
				local args = string.split(vv.Condition, ",");
				for iii, vvv in ipairs(args) do
					args[iii] = tonumber(vvv);
				end

				currProductID = args[sys.label_discount_activity_product_id];
				if v.other.open_count and v.other.open_count[currProductID] then
					openCount = v.other.open_count[currProductID]
				else
					openCount = 0;
				end

				if not tabDiscountNumList[currProductID] then
					tabDiscountNumList[currProductID] = 0;
				end

				if openCount < args[sys.label_discount_activity_end_index] and openCount + 1 >= args[sys.label_discount_activity_start_index] then
					if args[sys.label_discount_activity_number] == 100 then
						tabDiscountNumList[currProductID] = args[sys.label_discount_activity_number];
					end
				end
			end
		end
	end

	--log_tree("[edward][bp_supply_main] ", tabDiscountNumList);
	return tabDiscountNumList;
end

function SupplyMainUI.OnTabDiscountUpdate()
	SupplyMainUI.UpdateData();
	LuaClassObj.HandleUIMessageNoFetch(bp_supply_main, "UpdateUI");
end


function SupplyMainUI.GetTabDiscountRedDotNum()
	local tabDiscountNumList = SupplyMainUI.GetTabDiscountNum();

	local redDotNum = 0;
	for i, v in pairs(tabDiscountNumList) do
		redDotNum = redDotNum + 1;
	end

	return redDotNum;
end

---------- 日韩版本 道具和兑换页签 购买处理 ----------------
function SupplyMainUI.OnPurchase(eventType, eventID, vars)
	local info = vars.info;

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

function SupplyMainUI.GetTabIndexFromTabId(tab1Id, tab2Id)
	for i=1,#BP_ARRAY_SupplyMain_TabInfo_List,1 do
		if BP_ARRAY_SupplyMain_TabInfo_List[i].nTabId == tab1Id then
			return i-1
		end
	end
	return 0
end

---------- 日韩版本 道具和兑换页签 购买处理 end --------------
