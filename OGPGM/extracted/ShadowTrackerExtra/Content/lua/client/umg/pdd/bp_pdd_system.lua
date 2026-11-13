-- added by haifenghe, 2018/09/11

PDD_System_UI = PDD_System_UI or {
	bShowing = false,
	tabBargain = 1,
	showShopID = 0,

	defaultWear = {},
	currentWear = {},

	type_Avatar = 0,
	type_Backpack = 1,

	type_GeneralItem = 2,
	type_Weapon = 3,
	type_Vehicle = 4,
	type_Expression = 5,
	type_TreasureChest = 6,

	continueFaceSlap = false,
}


BP_PDDSystem_CurrentUC = 0;
BP_PDDSystem_Rules = "";
BP_PDDSystem_SaveFileName = "";

BP_PDDSystem_UserNodeDiscount = 0;
BP_PDDSystem_UserNodeOrderid = 0;

BP_STRUCT_CurrentEquipmentInfo = {
	itemID = 0,
	colorID = 0,
	patternID = 0,
	itemType = 0,
}

BP_ARRAY_AvatarList = {
	BP_STRUCT_CurrentEquipmentInfo = _G.BP_STRUCT_CurrentEquipmentInfo, 
}

BP_STRUCT_PDDSystemPlayerData = {
	gid = "",
	sex = 1,
	headId = 401999,
	index = 1,
	BP_ARRAY_AvatarList = _G.BP_ARRAY_AvatarList,
}

BP_ARRAY_PDDSystem_HaveBargainedOrderList = {
	0,
}

BP_ARRAY_PDDSystem_HaveShowedBargainItemList = {
	0,
}

BP_ARRAY_PDDSystem_ItemListBargainedToFree = {
	0,
}

--拼多多本地缓存的需要拉取状态的黑名单列表
BP_ARRAY_PDDSystem_BatchCacheBlackList = 
{
	0,
}

--好友订单列表
BP_ARRAY_PDDSystem_FriendShareOrderList =
{
	0,
}

--战友订单列表
BP_ARRAY_PDDSystem_CorpsShareOrderList =
{
	0,
}

--拼多多本地缓存的拼多多期数
BP_PDDSystem_BatchCacheBlackListVersion = 0;

BP_PDDSystem_PreShowBargainIndex = 0;
BP_PDDSystem_PreBuyBargainIndex = 0;
BP_PDDSystem_BargainAllPopup = false;

local _avatar = nil
--分享列表是否显示红点
BP_PDDSystem_InviteRedDot = false;



function bp_pdd_system_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_pdd_system,
		{
			{Path="/Game/UMG/UI_Logic/PDDSystem/PDD_System_Logic_BP.PDD_System_Logic_BP_C", Container="Default", ZOrder=BP_ENUM_UI_PDD_SYSTEM+1},
			{Path="/Game/UMG/UI_BP/Bargain/Bargained_Rule_UIBP.Bargained_Rule_UIBP_C", Container="Default", ZOrder=BP_ENUM_UI_PDD_SYSTEM+10}
		},
		{"Lobby"},
		false,
		bp_pdd_system_OnModeSwitched ~= nil,
		true
	);
end

function bp_pdd_system_OnModeSwitched(gamestatus)
	log("[HHF]bp_pdd_system_OnModeSwitched gamestatus = " .. tostring(gamestatus));
	status = string.lower(gamestatus);
	if status ~= "lobby" then
		if PDD_System_UI.bShowing == true then
			LuaClassObj.HandleUIMessage(bp_pdd_system, "UIHide");
			PDD_System_UI.Release();
		end
    end
	
	if status == "login" then
		BP_STRUCT_BargainSystemUI_StateInfo = {};
		BP_BargainSystemUI_InviteRedDot = false;
		BargainSystemUI_StateInfo_Map = {};
		BP_ARRAY_BargainSystemUI_StateInfo = {};
		BP_ARRAY_PDDSystem_CorpsShareOrderList = {};
		BP_ARRAY_PDDSystem_FriendShareOrderList = {};
	end
end

function PDD_System_UI.OnJumpToPDDSystem(eventType, eventID, vars)
	log("[HHF]PDD_System_UI.OnJumpToPDDSystem, vars.tab1 = " .. tostring(vars.tab1) .. ", vars.itemID = " .. tostring(vars.itemID) .. ", can_show = " .. tostring(PDD_System_Logic.can_show));
	if PDD_System_Logic.can_show ~= true then
		PopUpNoticeUI.ShowNewNotice(FuncUtil.GetLocalizeResStr("120106"));
		return;
	end
	PDD_System_UI.Show(tonumber(vars.tab1), tonumber(vars.itemID));
end

function PDD_System_UI.Show(tab, shopID, continueFaceSlap)
	log("[HHF]PDD_System_UI.Show, tab = " .. tostring(tab) .. ", shopID = " .. tostring(shopID) .. ", continueFaceSlap = " .. tostring(continueFaceSlap));
	--修改光照
	LobbySceneManager.ChangeLight(LobbySceneManager.LIGHT_MALL_AVATAR)
	PDD_System_UI.continueFaceSlap = continueFaceSlap;

	PDD_System_UI.InitPlayerEquipmentData();
	BP_PDDSystem_CurrentUC = DataMgr.ticket;

	if tab == nil or tab == PDD_System_UI.tabBargain then
		if Bargain_Logic.GetSystemOpenState() == Bargain_System_UI.haveEnded then
			BP_ARRAY_PDDSystem_HaveBargainedOrderList = {};
			BP_ARRAY_PDDSystem_ItemListBargainedToFree = {};
			BP_ARRAY_PDDSystem_HaveShowedBargainItemList = {};
			LuaClassObj.HandleDynamicCreation(bp_pdd_system);
			PDD_System_UI.SavePDDSaveGames();

			PDD_System_UI.showShopID = shopID;
			PDD_System_Logic.pdd_bargain_get_activity_req(true);
		else
			PDD_System_UI.ShowBargain(shopID);
		end
	end
    --EventSystem:registEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_SYNC, PDD_System_UI.OnTeamInfoChange);
end

function PDD_System_UI.ShowBargain(shopID)
	log("[HHF]PDD_System_UI.ShowBargain");
	EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN);
	LuaClassObj.HandleDynamicCreation(bp_pdd_system);
	LuaClassObj.HandleUIMessage(bp_pdd_system, "UIShow");
	LobbySceneManager.ShowMesh(LobbySceneManager.MALL_MESH_LobbyBgMesh)
	
    if _avatar ~= nil then
    	_avatar:Destroy()
    end

	local showPosition = {}
	showPosition.x = -60
	showPosition.y = -383
	showPosition.z = -14348
	_avatar = GenderAvatar.CreateMyself(showPosition)
	_avatar:PutoffSubtype(LobbyAvatar.EQUIPMENT_SUBTYPE_WEAPON)

	Bargain_System_UI.Show(shopID);

	PDD_System_UI.UpdateBargainLobbyReddotCache();
	BP_PDDSystem_Rules = FuncUtil.GetLocalizeResStr(6278);
	PDD_System_UI.bShowing = true;
end

function PDD_System_UI.ShowRules()
	log("[HHF]PDD_System_UI.ShowRules");
	--LuaClassObj.HandleUIMessage(bp_pdd_system, "UIShowRules");
	local title = FuncUtil.GetLocalizeResStr(6067);
	local context = FuncUtil.GetLocalizeResStr(6278);
	PopUpNoticeUI.ShowMessageBox(title, context);
end

function PDD_System_UI.OnTeamInfoChange(eventType, eventID, vars)
	log("[HHF]PDD_System_UI.OnTeamInfoChange, eventType = " .. tostring(eventType) .. ", eventID = " .. tostring(eventID) .. ", vars = " .. tostring(vars));

	if PDD_System_UI.bShowing == true then
		PDD_System_UI.Hide();
	end

	PDD_System_UI.HideRules();

	Bargain_Detail_UI.Hide();
	Bargain_Detail_UI.HideBuyDialog();
	Bargain_Detail_UI.HideHistoryDialog();
	Bargain_Detail_UI.HideFirstDialog();
end

function PDD_System_UI.InitLocalData()
	log("[HHF]PDD_System_UI.InitLocalData");

	if PDD_System_UI.bShowing == true then
		log("PDD_System_UI.InitLocalData isShow NoNeedInit");
		return;
	end
	
	LuaClassObj.HandleDynamicCreation(bp_pdd_system);

	BP_PDDSystem_SaveFileName = "PDDSave_" .. DataMgr.roleData.uid;
    BP_BargainDetail_SaveFileName = "PDDSave_" .. DataMgr.roleData.uid;
	BP_PDDSystem_BargainAllPopup = false;
	BP_PDDSystem_PreBuyBargainIndex = 0;
	BP_PDDSystem_PreShowBargainIndex = 0;
	BP_PDDSystem_BatchCacheBlackListVersion = 0;
	BP_ARRAY_PDDSystem_HaveBargainedOrderList = {};
	BP_ARRAY_PDDSystem_ItemListBargainedToFree = {};
	BP_ARRAY_PDDSystem_HaveShowedBargainItemList = {};
	BP_ARRAY_PDDSystem_BatchCacheBlackList = {};
    BP_ARRAY_BargainSystemUI_StateInfo = {};
	LuaClassObj.HandleUIMessage(bp_pdd_system, "LoadPDDSaveGames");
end

--是否已被砍价
function PDD_System_UI.HaveBargainedByOrderID(orderid)
	local result = false;
	for k, v in pairs(BP_ARRAY_PDDSystem_HaveBargainedOrderList) do
		if v == orderid then
			result = true;
			break;
		end
	end

	log("[HHF]PDD_System_UI.HaveBargainedByOrderID, orderid = " .. tostring(orderid) .. ", result = " .. tostring(result));
	return result;
end

function PDD_System_UI.UpdateBargainedOrderList(orderid)
	local have = false;
	for k, v in pairs(BP_ARRAY_PDDSystem_HaveBargainedOrderList) do
		if v == orderid then
			have = true;
			break;
		end
	end

	if have == false then
		table.insert(BP_ARRAY_PDDSystem_HaveBargainedOrderList, orderid);
	end

	log("[HHF]PDD_System_UI.UpdateBargainedOrderList, orderid = " .. tostring(orderid) .. ", have = " .. tostring(have));
end

function PDD_System_UI.NeedShowBargainMyTabReddot()
	if FuncUtil:CountTable(BP_ARRAY_PDDSystem_ItemListBargainedToFree) > 0 then
		--log("[HHF]PDD_System_UI.NeedShowBargainMyTabReddot, return true");
		return true;
	else
		--log("[HHF]PDD_System_UI.NeedShowBargainMyTabReddot, return false");
		return false;
	end
end


--是否显示红点
function PDD_System_UI.NeedShowReddot()
	if FuncUtil:CountTable(BP_ARRAY_PDDSystem_ItemListBargainedToFree) > 0 then
		--log_tree("[HHFTEST]BP_ARRAY_PDDSystem_ItemListBargainedToFree = ", BP_ARRAY_PDDSystem_ItemListBargainedToFree, "[HHFTEST]");
		log("[HHF]PDD_System_UI.NeedShowReddot,BP_ARRAY_PDDSystem_ItemListBargainedToFree more than 0, return true");
		return true;
	elseif BP_PDDSystem_InviteRedDot == true then
		log("PDD_System_UI.NeedShowReddot, BP_PDDSystem_InviteRedDot is true");
		return true;
	else
		local showReddot = false;
		if PDD_System_Logic.can_show then
			if BP_PDDSystem_PreShowBargainIndex ~= PDD_System_Logic.pddSystem_Time.index then
				showReddot = true;
			end
		end
		log("[HHF]PDD_System_UI.NeedShowReddot, BP_PDDSystem_PreShowBargainIndex = " .. tostring(BP_PDDSystem_PreShowBargainIndex) .. 
			", showReddot = " .. tostring(showReddot));

		local buyReddot = false;
		if PDD_System_Logic.can_buy then
			if BP_PDDSystem_PreBuyBargainIndex ~= PDD_System_Logic.pddSystem_Time.index then
				buyReddot = true;
			end
		end
		log("[HHF]PDD_System_UI.NeedShowReddot, BP_PDDSystem_PreBuyBargainIndex = " .. tostring(BP_PDDSystem_PreBuyBargainIndex) .. 
			", buyReddot = " .. tostring(buyReddot));

		return showReddot or buyReddot;
	end
end

function PDD_System_UI.UpdateBargainLobbyReddotCache()
	log("[HHF]PDD_System_UI.UpdateBargainLobbyReddotCache");
	if PDD_System_Logic.can_buy then
		BP_PDDSystem_PreBuyBargainIndex = PDD_System_Logic.pddSystem_Time.index;
	end

	if PDD_System_Logic.can_show then
		BP_PDDSystem_PreShowBargainIndex = PDD_System_Logic.pddSystem_Time.index;
	end
end

function PDD_System_UI.UpdateUCAfterBuy()
	log("[HHF]PDD_System_UI.UpdateUCAfterBuy, DataMgr.ticket = " .. tostring(DataMgr.ticket));
	BP_PDDSystem_CurrentUC = DataMgr.ticket;
	
	if PDD_System_UI.bShowing == true then
		LuaClassObj.HandleUIMessage(bp_pdd_system, "SetData");
	end
end

--砍到免费订单红点
function PDD_System_UI.UpdateBargainNotifyReddotCache(add, orderid)
	log("[HHF]PDD_System_UI.UpdateBargainNotifyReddotCache, new free orderid = " .. tostring(orderid) .. ", add = " .. tostring(add));
	local have = false;
	local index = 0;
	for k, v in pairs(BP_ARRAY_PDDSystem_ItemListBargainedToFree) do
		if v == orderid then
			index = k;
			have = true;
			break;
		end
	end

	if add == true then
		if have == false then
			table.insert(BP_ARRAY_PDDSystem_ItemListBargainedToFree, orderid);
			LobbyUI.UpdatePDDSystemReddot();
		end
	else
		if have == true then
			table.remove(BP_ARRAY_PDDSystem_ItemListBargainedToFree, index);
			LobbyUI.UpdatePDDSystemReddot();
		end
	end
end

function PDD_System_UI.IsDirectBargainItem(item_id)
	if BP_PDDSystem_BargainAllPopup == true then
		log("[HHF]PDD_System_UI.IsDirectBargainItem, BP_PDDSystem_BargainAllPopup = true");
		return false;
	else
		for k, v in pairs(BP_ARRAY_PDDSystem_HaveShowedBargainItemList) do
			if v == item_id then
				log("[HHF]PDD_System_UI.IsDirectBargainItem, true when item_id = " .. tostring(item_id));
				return true;
			end
		end

		log("[HHF]PDD_System_UI.IsDirectBargainItem, false when item_id = " .. tostring(item_id));
		return false;
	end
end

function PDD_System_UI.UpdateDirectBargainItemList(item_id)
	log("[HHF]PDD_System_UI.UpdateDirectBargainItemList, item_id = ".. tostring(item_id));
	local have = false;
	for k, v in pairs(BP_ARRAY_PDDSystem_HaveShowedBargainItemList) do
		if v == item_id then
			have = true;
			break;
		end
	end

	if have == false then
		table.insert(BP_ARRAY_PDDSystem_HaveShowedBargainItemList, item_id);
		log("[HHF]PDD_System_UI.UpdateDirectBargainItemList, insert item_id = ".. tostring(item_id) .. " success");
	end
end

function PDD_System_UI.GetBargainDetailCheckState()
	if BP_PDDSystem_BargainAllPopup == true then
		log("[HHF]PDD_System_UI.GetBargainDetailCheckState, return false");
		return false;
	else
		log("[HHF]PDD_System_UI.GetBargainDetailCheckState, return true");
		return true;
	end
end

function PDD_System_UI.UpdateDirectBargainCheckState(check)
	if check == true then
		BP_PDDSystem_BargainAllPopup = false;
	else
		BP_PDDSystem_BargainAllPopup = true;
	end
	log("[HHF]PDD_System_UI.UpdateDirectBargainCheckState, BP_PDDSystem_BargainAllPopup = " .. tostring(BP_PDDSystem_BargainAllPopup));
end

function PDD_System_UI.InitPlayerEquipmentData()
	PDD_System_UI.defaultWear = {};
	PDD_System_UI.currentWear = {};

	local rolewear = {};
	for k, v in pairs(DataMgr.rolewear) do
		local itemData = DataMgr.GetHallDepotItemDataByInsID(v);
		if itemData ~= nil then
			--log_tree("[HHFTEST]PDD_System_UI.InitPlayerEquipmentData, itemData = ", itemData, "[HHFTEST]");
			local wearInfo = {};
			wearInfo.itemID = itemData.resID;
			wearInfo.colorID = itemData.colorID or 0;
			wearInfo.patternID = itemData.patternID or 0;
			table.insert(rolewear, wearInfo);
			PDD_System_UI.AddToWearInfo(itemData.itemSubType, wearInfo, true);
		end
	end
	table.insert(rolewear, {itemID = DataMgr.avatarData.hairid, colorID = 0, patternID = 0,});

	BP_STRUCT_PDDSystemPlayerData =
	{
		gid = tostring(DataMgr.roleData.uid),
		sex = DataMgr.avatarData.gamegender,
		headId = DataMgr.avatarData.headid,
		index = BP_LobbyPlayerNum,
		BP_ARRAY_AvatarList = rolewear,
	}
	--log_tree("[HHFTEST]PDD_System_UI:InitPlayerEquipmentData, BP_STRUCT_PDDSystemPlayerData = ", BP_STRUCT_PDDSystemPlayerData, "[HHFTEST]");
end

function PDD_System_UI.AddToWearInfo(itemSubType, wearInfo, bDefault)
	log("[HHF]PDD_System_UI.AddToWearInfo, itemSubType = " .. tostring(itemSubType) .. ", wearInfo = " .. tostring(wearInfo) .. ", bDefault = " .. tostring(bDefault));
	PDD_System_UI.currentWear[itemSubType] = wearInfo;
	if bDefault == true then
		PDD_System_UI.defaultWear[itemSubType] = wearInfo;
	else
		if wearInfo == nil then
			PDD_System_UI.currentWear[itemSubType] = PDD_System_UI.defaultWear[itemSubType];
		end
	end

	--log_tree("[HHFTEST]PDD_System_UI.AddToWearInfo, PDD_System_UI.defaultWear = ", PDD_System_UI.defaultWear, "[HHFTEST]");
	--log_tree("[HHFTEST]PDD_System_UI.AddToWearInfo, PDD_System_UI.currentWear = ", PDD_System_UI.currentWear, "[HHFTEST]");

	return PDD_System_UI.defaultWear[itemSubType];
end

function PDD_System_UI.Hide()
	log("[HHF]PDD_System_UI.Hide");
	Bargain_System_UI.Hide();
	LuaClassObj.HandleUIMessage(bp_pdd_system, "UIHide");
	if _avatar ~= nil then
		_avatar:Destroy()
	end

	if PDD_System_UI.bShowing == true then
		PDD_System_UI.bShowing = false;
		if Bargain_Logic.GetSystemOpenState() == Bargain_System_UI.haveEnded then
			BP_ARRAY_PDDSystem_HaveBargainedOrderList = {};
			BP_ARRAY_PDDSystem_ItemListBargainedToFree = {};
			BP_ARRAY_PDDSystem_HaveShowedBargainItemList = {};
			PDD_System_UI.SavePDDSaveGames();

			PDD_System_Logic.pdd_bargain_get_activity_req();
		else
			PDD_System_UI.SavePDDSaveGames();
		end

		EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE);
		--EventSystem:unregistEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_SYNC, PDD_System_UI.OnTeamInfoChange);
		LuaClassObj.HandleUIMessage(bp_lobby, "ReturnToLobbyFromPDD");
		LobbyUI.UpdatePDDSystemReddot();
	end
end

function PDD_System_UI.HideRules()
	log("[HHF]PDD_System_UI.HideRules");
	LuaClassObj.HandleUIMessage(bp_pdd_system, "UIHideRules");
end

function PDD_System_UI.PutOnClothes(wearInfo)
	log("[HHF]PDD_System_UI.PutOnClothes, itemType = " .. tostring(wearInfo.itemType) ..
		", itemID = " .. tostring(wearInfo.itemID));
	
	LuaClassObj.HandleUIMessage(bp_pdd_system, "HideGeneralItem");
	LuaClassObj.HandleUIMessage(bp_pdd_system, "HideEquipment");
	
	BP_STRUCT_CurrentEquipmentInfo = wearInfo;
	PDD_System_UI.AddToWearInfo(wearInfo.itemType, wearInfo);
	-- LuaClassObj.HandleUIMessage(bp_pdd_system, "PutOnClothes");
	_avatar:PutonOrPutoff(wearInfo.itemID)
	_avatar:ShowAvatar()
end

function PDD_System_UI.PutOffClothes(wearInfo);
	LuaClassObj.HandleUIMessage(bp_pdd_system, "HideGeneralItem");
	LuaClassObj.HandleUIMessage(bp_pdd_system, "HideEquipment");
	
	BP_STRUCT_CurrentEquipmentInfo = wearInfo;
	local default = PDD_System_UI.AddToWearInfo(wearInfo.itemType, nil);
	log("[HHF]PDD_System_UI.PutOffClothes, itemType = " .. tostring(wearInfo.itemType) ..
		", itemID = " .. tostring(wearInfo.itemID) .. ", default = " .. tostring(default))
	if default ~= nil then
		BP_STRUCT_CurrentEquipmentInfo = default;
		_avatar:PutonOrPutoff(wearInfo.itemID)
	else
		LuaClassObj.HandleUIMessage(bp_pdd_system, "PutOffClothes");
		_avatar:PutonOrPutoff(wearInfo.itemID)
	end

	_avatar:ShowAvatar()
end

function PDD_System_UI.EquipWeapon(wearInfo)
	log("[HHF]PDD_System_UI.EquipWeapon, itemType = " .. tostring(wearInfo.itemType) ..
		", itemID = " .. tostring(wearInfo.itemID));
	BP_STRUCT_CurrentEquipmentInfo = wearInfo;
	PDD_System_UI.AddToWearInfo(wearInfo.itemType, wearInfo);
	-- LuaClassObj.HandleUIMessage(bp_pdd_system, "EquipWeapon");
	_avatar:PutonOrPutoff(wearInfo.itemID)
	_avatar:ShowAvatar()
end

function PDD_System_UI.UnequipWeapon(wearInfo)
	BP_STRUCT_CurrentEquipmentInfo = wearInfo;
	local default = PDD_System_UI.AddToWearInfo(wearInfo.itemType, nil);
	log("[HHF]PDD_System_UI.UnequipWeapon, itemType = " .. tostring(wearInfo.itemType) ..
		", itemID = " .. tostring(wearInfo.itemID) .. ", default = " .. tostring(default))
	if default ~= nil then
		BP_STRUCT_CurrentEquipmentInfo = default;
		-- LuaClassObj.HandleUIMessage(bp_pdd_system, "EquipWeapon");
		_avatar:PutonOrPutoff(wearInfo.itemID)
	else
		-- LuaClassObj.HandleUIMessage(bp_pdd_system, "UnequipWeapon");
		_avatar:PutonOrPutoff(wearInfo.itemID)
	end
	_avatar:ShowAvatar()
end

function PDD_System_UI.ShowEquipment(itemInfo)
	log("[HHF]PDD_System_UI.ShowEquipment, itemType = " .. tostring(itemInfo.itemType) ..
		", itemID = " .. tostring(itemInfo.itemID));
	BP_STRUCT_CurrentEquipmentInfo = itemInfo;

	_avatar:HideAvatar()
	LuaClassObj.HandleUIMessage(bp_pdd_system, "ShowEquipment");
end

function PDD_System_UI.ShowGeneralItem(itemInfo)
	log("[HHF]PDD_System_UI.ShowGeneralItem, itemType = " .. tostring(itemInfo.itemType) ..
		", itemID = " .. tostring(itemInfo.itemID));
	BP_STRUCT_CurrentEquipmentInfo = itemInfo;

	_avatar:HideAvatar()
	LuaClassObj.HandleUIMessage(bp_pdd_system, "ShowGeneralItem");
end

function PDD_System_UI.DoAction(itemInfo)
	log("[HHF]PDD_System_UI.DoAction, itemType = " .. tostring(itemInfo.itemType) ..
			", itemID = " .. tostring(itemInfo.itemID));

	BP_STRUCT_CurrentEquipmentInfo = itemInfo;
	-- LuaClassObj.HandleUIMessage(bp_pdd_system, "DoAction");
	_avatar:ShowAvatar()
	_avatar:PlayAction(itemInfo.itemID)

	local myUid = DataMgr.roleData.uid;
	local sex = ProfileMgr.GetRoleSexByUid(myUid)
	LobbyUI.PlayEmotionSound(itemInfo.itemID, sex, 0, myUid, 2);

end

function PDD_System_UI.SaveUserNodeInfo()
    LuaClassObj.HandleUIMessage(bp_pdd_system, "SaveUserNodeInfo");
end

function PDD_System_UI.Release()
	log("[HHF]PDD_System_UI.Release");
	PDD_System_Logic.ResetData();
	Bargain_System_UI.Release();
	PDD_System_UI.bShowing = false;
end

function PDD_System_UI.SavePDDSaveGames()
	log("[HHF]PDD_System_UI.SavePDDSaveGames");
	LuaClassObj.HandleDynamicCreation(bp_pdd_system);
	BP_PDDSystem_SaveFileName = "PDDSave_" .. DataMgr.roleData.uid;
    BP_BargainDetail_SaveFileName = "PDDSave_" .. DataMgr.roleData.uid;
	LuaClassObj.HandleUIMessage(bp_pdd_system, "SavePDDSaveGames");
end

function EventClosePDDSystemUI()
	log("[HHF]EventClosePDDSystemUI");
	PDD_System_UI.Hide();
	Bargain_Detail_UI.HideFirstDialog();
	if PDD_System_UI.continueFaceSlap == true then
		FaceSlapSystem.UninterruptableFinallyShow();
	end
end

function EventOnClickPDDSystemRules()
	log("[HHF]EventOnClickPDDSystemRules");
	PDD_System_UI.ShowRules();
end

function EventClosePDDSystemRules()
	log("[HHF]EventClosePDDSystemRules");
	PDD_System_UI.HideRules();
end

function EventFetchPDDSystemInfo()
	log("[HHF]EventFetchPDDSystemInfo");
end

function EventOnClickPDDChargeTicket()
	log("[HHF]EventOnClickPDDChargeTicket");
	RechargeUI:Init();
end
