-- 商城预览界面
StorePreviewUI = StorePreviewUI or
{
	curItemID = 0,
	funcBuy = nil,
	funcSend = nil,
	funcGetLastOne = nil, -- 获取上一个物品的回调
	funcGetNextOne = nil, -- 获取下一个物品的回调
	lastClickTime = 0,	-- 上一次点击时间点
	clickCD = 1,		-- 点击CD
	bShow = false,
}

-- 物品信息
BP_STRUCT_Store_Preview_Item_Info = {
	item_id = 0,
	item_gift = 0,
	item_killBroadcast = false,
	item_jump = "",
	saleEndTime = 0,

	item_collected = false,
	item_collected_num = 0,
}

-- 货币信息结构
BP_STRUCT_Store_Preview_MoneyInfo = 
{
	nGold = 0,
	nUC = 0,
	nZhupai = 0,
	nSilver = 0,
	nGoldChip = 0,
	bShowZhupai = false,
}

BP_STRUCT_Store_Preview_PriceInfo = 
{
	PriceType1 = 0,
	PriceNum1 = 0,
	DiscountNum1 = 0,
	PriceType2 = 0,
	PriceNum2 = 0,
	DiscountNum2 = 0,
	isSoldOut = false,
	isHaveItem = false,
	priceNumMax = 0,
}

BP_StorePreview_CurrentDeadboxPath = ""

BP_Cur_StorePreview_LevelUP_ITEMID = 0	--升级展示用ID

--注册Widget
function bp_store_preview_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_store_preview,
        {{Path="/Game/UMG/UI_Logic/Store/Store/StorePreviewLogicUI_BP.StorePreviewLogicUI_BP_C", Container="Default", ZOrder=0}},
        {"Lobby"},
        false, 
		false,
        true
    );
end

function StorePreviewUI.Show(itemInfo, priceInfo, funcBuy, funcSend, funcGetLastOne, funcGetNextOne)
	--if UIManager.GetUI(eUIType.eStorePreviewPage) then
	--	return
	--end

	StorePreviewUI.lastClickTime = os.time();
	StorePreviewUI.RegistEvent();
	
	BP_STRUCT_Store_Preview_Item_Info = itemInfo;
	BP_Cur_StorePreview_LevelUP_ITEMID = store_item_upgrade_system.GetPreviewID(itemInfo.item_id)
	--log_tree("BP_STRUCT_Store_Preview_Item_Info", BP_STRUCT_Store_Preview_Item_Info)
	BP_STRUCT_Store_Preview_PriceInfo = priceInfo;

	StorePreviewUI.funcBuy = funcBuy;
	StorePreviewUI.funcSend = funcSend;
	StorePreviewUI.funcGetLastOne = funcGetLastOne;
	StorePreviewUI.funcGetNextOne = funcGetNextOne;
	
	log("StorePreviewUI.Show")
	-- 处理商城主页签刷新
	StoreMainUI.UIOnlyHide(false);
	-- 切换摄像机


	--EditorRuntime.ShowMallFullScreen(BP_STRUCT_Store_Preview_Item_Info.item_id, 10112);

	StorePreviewUI.HandleLevelUpPreview(itemInfo.item_id)	--因为加入了升级枪展示 和预览 

	LuaClassObj.HandleDynamicCreation(bp_store_preview);
	LuaClassObj.HandleUIMessageNoFetch(bp_store_preview, "UIShow");
	StorePreviewUI.UIOnlyShowAll();
	UIManager.Show(eUIType.eStorePreviewPage);
	StorePreviewUI.bShow = true;

	StorePreviewUI.On_UC_Gold_Change();
	StorePreviewUI.UpdateView();
end

--因为加入了升级枪展示 和预览 
function StorePreviewUI.HandleLevelUpPreview(itemid)
	-- body
	if store_item_upgrade_system.GetCurrentModele() == store_item_upgrade_system.module.weapon then		--武器模块有可能是高级枪模型 
		store_item_upgrade_system.SetSavedLastModelItemID(store_item_upgrade_system.GetCurrentItemID())	--存高级枪模型
	else
		store_item_upgrade_system.SetSavedLastModelItemID(itemid)
	end
	store_item_upgrade_system.SetCurrentModele(store_item_upgrade_system.module.weapon_preview)		--设为预览模块
	StoreMainUI.OnSelectedItem(itemid, 0, 0, true);
	BP_Cur_StorePreview_LevelUP_ITEMID = itemid
end


function StorePreviewUI.RefreshView(priceInfo)
	if not UIManager.GetUI(eUIType.eStorePreviewPage) then
		return
	end
	log("StorePreviewUI.RefreshView");

	BP_STRUCT_Store_Preview_PriceInfo = priceInfo;
	StorePreviewUI.UpdateView();
end

function StorePreviewUI.Hide()
	log("StorePreviewUI.Hide")
	StorePreviewUI.UnRegistEvent();
	StoreMainUI.UIOnlyShow(true);
	-- 还原摄像机
	LobbyCameraManager.SwitchCamera(10112);
	StorePreviewUI.OnDeadBoxRestore();
	LuaClassObj.HandleUIMessageNoFetch(bp_store_preview, "UIHide");
	UIManager.Hide(eUIType.eStorePreviewPage);
	StorePreviewUI.bShow = false;
end

function StorePreviewUI.RegistEvent()
	EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_TICKET_CHANGE, StorePreviewUI.On_UC_Gold_Change)
	EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_GOLD_CHANGE, StorePreviewUI.On_UC_Gold_Change)
	EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_DIAMOND_CHANGE, StorePreviewUI.On_UC_Gold_Change)
	EventSystem:registEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_COLLECT, StorePreviewUI.OnCollectedResult);
end

function StorePreviewUI.UnRegistEvent()
	EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_TICKET_CHANGE, StorePreviewUI.On_UC_Gold_Change)
	EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_GOLD_CHANGE, StorePreviewUI.On_UC_Gold_Change)
	EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_DIAMOND_CHANGE, StorePreviewUI.On_UC_Gold_Change)
	EventSystem:unregistEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_COLLECT, StorePreviewUI.OnCollectedResult);
end

function StorePreviewUI.OnCollectedResult()
	local item_id = BP_STRUCT_Store_Preview_Item_Info.item_id;
	local result = StoreSystem.IsCollectedByItemID(item_id);
	log("[HHF]StorePreviewUI.OnCollectedResult, result = " .. tostring(result));
	BP_STRUCT_Store_Preview_Item_Info.item_collected = result;
	BP_STRUCT_Store_Preview_Item_Info.item_collected_num = StoreSystem.global_collection_num[item_id];

	LuaClassObj.HandleUIMessageNoFetch(bp_store_preview, "UpdateCollectionState");
end

-- 刷新货币
function StorePreviewUI.On_UC_Gold_Change()
	BP_STRUCT_Store_Preview_MoneyInfo = StoreFuncUtils.GetMoneyInfo();
	LuaClassObj.HandleUIMessageNoFetch(bp_store_preview, "UpdateMoney");
end

function StorePreviewUI.UpdateView(needDisplay)
	log("StorePreviewUI UpdateView")
	if needDisplay then
		ModelDisplayer.Display(BP_STRUCT_Store_Preview_Item_Info.item_id, 0, 0, true);
	end
	LuaClassObj.HandleUIMessageNoFetch(bp_store_preview, "UpdateDesc");
end

function EventStorePreviewOnClickLastOne()
	log("StorePreviewUI EventStorePreviewOnClickLastOne")
	if os.time() - StorePreviewUI.lastClickTime >= StorePreviewUI.clickCD then
		StorePreviewUI.lastClickTime = os.time();
		GemReportUtils.ReportBtnClickEvent(GemReportUtils.SubEventName_PreviewLeft)
		if StorePreviewUI.funcGetLastOne ~= nil then
			local itemInfo, priceInfo, funcBuy, funcSend = StorePreviewUI.funcGetLastOne();
			if itemInfo ~= nil then
				StorePreviewUI.OnDeadBoxRestore();
				BP_STRUCT_Store_Preview_Item_Info = itemInfo;
				BP_Cur_StorePreview_LevelUP_ITEMID = store_item_upgrade_system.GetPreviewID(itemInfo.item_id)
				BP_STRUCT_Store_Preview_PriceInfo = priceInfo;
				StorePreviewUI.funcBuy = funcBuy;
				StorePreviewUI.funcSend = funcSend;
				StorePreviewUI.UpdateView(true);
				ModelDisplayer.Store(ModelDisplayer.KEY_STORE_MAIN_UI);
			end
		end
	end
end

function EventStorePreviewOnClickNextOne()
	log("StorePreviewUI EventStorePreviewOnClickNextOne")
	if os.time() - StorePreviewUI.lastClickTime >= StorePreviewUI.clickCD then
		StorePreviewUI.lastClickTime = os.time();
		GemReportUtils.ReportBtnClickEvent(GemReportUtils.SubEventName_PreviewRight)
		if StorePreviewUI.funcGetNextOne ~= nil then
			local itemInfo, priceInfo, funcBuy, funcSend = StorePreviewUI.funcGetNextOne();
			if itemInfo ~= nil then
				StorePreviewUI.OnDeadBoxRestore();
				BP_STRUCT_Store_Preview_Item_Info = itemInfo;
				BP_Cur_StorePreview_LevelUP_ITEMID = store_item_upgrade_system.GetPreviewID(itemInfo.item_id)
				BP_STRUCT_Store_Preview_PriceInfo = priceInfo;
				StorePreviewUI.funcBuy = funcBuy;
				StorePreviewUI.funcSend = funcSend;
				StorePreviewUI.UpdateView(true);
				ModelDisplayer.Store(ModelDisplayer.KEY_STORE_MAIN_UI);
			end
		end
	end
end

function EventStorePreviewOnClickBuy()
	log("StorePreviewUI EventStorePreviewOnClickBuy")
	if os.time() - StorePreviewUI.lastClickTime >= StorePreviewUI.clickCD then
		StorePreviewUI.lastClickTime = os.time();
		if StorePreviewUI.funcBuy ~= nil then
			StorePreviewUI.funcBuy();
		end
	end
end

function EventStorePreviewOnClickSend()
	log("StorePreviewUI EventStorePreviewOnClickSend")
	if StorePreviewUI.funcSend ~= nil then
		StorePreviewUI.funcSend();
	end
end

function EventStorePreviewOnClickClose()
	log("StorePreviewUI EventStorePreviewOnClickClose")
	if os.time() - StorePreviewUI.lastClickTime >= StorePreviewUI.clickCD then
		StorePreviewUI.lastClickTime = os.time();
		StorePreviewUI.OnDeadBoxRestore();
		StorePreviewUI.Hide();
	end

end

function StorePreviewUI.ForceClose()
	log("StorePreviewUI.ForceClose")
	StorePreviewUI.OnDeadBoxRestore();
	StorePreviewUI.Hide();
end

function StorePreviewUI.UIOnlyShowAll()
	log("StorePreviewUI.UIOnlyShowAll")
	StorePreviewUI.bShow = true;
	EditorRuntime.ShowMallFullScreen(BP_STRUCT_Store_Preview_Item_Info.item_id, 10112);
	LuaClassObj.HandleUIMessageNoFetch(bp_store_preview, "OnlyShowUI");
	store_item_upgrade_system.SetCurrentModele(store_item_upgrade_system.module.weapon_preview)
	UIManager.Show(eUIType.eStorePreviewPage);
end

function StorePreviewUI.UIOnlyHideAll()
	log("StorePreviewUI.UIOnlyHideAll")
	StorePreviewUI.bShow = false;
	LuaClassObj.HandleUIMessageNoFetch(bp_store_preview, "OnlyHideUI");
	UIManager.Hide(eUIType.eStorePreviewPage);
end

--跳转 全屏预览到补给
function StorePreviewUI.JumpFromFullPreviewToSupply(para)
	if not LobbyUI:CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_NEW_SUPPLY, false) then
		return
	end
	-- 还原摄像机
	LobbyCameraManager.SwitchCamera(10112);
	LuaClassObj.HandleUIMessageNoFetch(bp_store_preview, "UIHide");
	UIManager.Hide(eUIType.eStorePreviewPage);
	ModelDisplayer.Store(ModelDisplayer.KEY_STORE_PREVIEW_UI);
	SupplyMainUI.Init(1, para)
end

function EventOnClickStorePreviewDeadBox()
	log("[HHF]EventOnClickStorePreviewDeadBox, deadBoxTimer = " .. tostring(StorePreviewUI.deadBoxTimer) .. ", path = " .. tostring(BP_StorePreview_CurrentDeadboxPath));

	if StorePreviewUI.deadBoxTimer == nil then
		StorePreviewUI.deadBoxHandler = SceneExtraModel.Create(BP_StorePreview_CurrentDeadboxPath);
		if StorePreviewUI.deadBoxHandler ~= nil then
			StorePreviewUI.deadBoxHandler:SetPosition(-30, -434, -14438);

			ModelDisplayer.Hide();
			StorePreviewUI.oldDisplayType = BP_StoreWeapon_DisplayType;
			BP_StoreWeapon_DisplayType = 2;

			StorePreviewUI.deadBoxTimer = Timer.InsertTimer(3, StorePreviewUI.OnDeadBoxRestore, false);
		else
			log("[HHF]EventOnClickStorePreviewDeadBox, SceneExtraModel.Create failed.");
		end
	end
end

function StorePreviewUI.OnDeadBoxRestore()
	log("[HHF]StorePreviewUI.OnDeadBoxRestore, deadBoxTimer = " .. tostring(StorePreviewUI.deadBoxTimer));
	if StorePreviewUI.deadBoxTimer ~= nil then
		Timer.RemoveTimer(StorePreviewUI.deadBoxTimer);
		StorePreviewUI.deadBoxTimer = nil;

		if StorePreviewUI.deadBoxHandler ~= nil then
			StorePreviewUI.deadBoxHandler:Destroy();
		end
		ModelDisplayer.Show();
		BP_StoreWeapon_DisplayType = StorePreviewUI.oldDisplayType;
		LuaClassObj.HandleUIMessageNoFetch(bp_store_weapon, "HideDeadBox");
	end
end

function EventOnClickCollectPreview()
	log("[HHF]EventOnClickCollectPreview");
	if UIUtil.CanClickNow(ClickFrequencyLimit.StoreCollectionBtn) == false then
		return;
	end

	if BP_STRUCT_Store_Preview_Item_Info.item_collected then
		StoreSystem.cancel_market_collect_by_item_req(BP_STRUCT_Store_Preview_Item_Info.item_id);
	else
		StoreSystem.add_market_collect_by_item_req(BP_STRUCT_Store_Preview_Item_Info.item_id, StoreSystem.market_collect_source_market);
	end
end
