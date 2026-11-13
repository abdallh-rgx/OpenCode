--[[
	军团商店UI
--]]

CorpsShopUI = CorpsShopUI or 
{

};

--服装
BP_STRUCT_CorpsShopClothingInfo = 
{
	sort_id = 0,
	item_id = 0,
	consume_corps_money = 0,
	unlock_corps_level = 0,
	limit_buy_num = 0,
	has_buy_num = 0,
	limit_buy_cd_num_by_day = 0,
	limit_buy_item_num_by_day = 0,
	permanet_limit_buy_num = 0,
	position_limit = 0,
	time_cd = 0,
};
--头像
BP_STRUCT_CorpsShopHeadpotraitInfo = 
{
	sort_id = 0,
	item_id = 0,
	consume_corps_money = 0,
	unlock_corps_level = 0,
	limit_buy_num = 0,
	has_buy_num = 0,
	limit_buy_cd_num_by_day = 0,
	limit_buy_item_num_by_day = 0,
	permanet_limit_buy_num = 0,
	position_limit = 0,
	time_cd = 0,
};
--服装商品列表
BP_ARRAY_CorpsShopClothingInfoList = 
{
	BP_STRUCT_CorpsShopClothingInfo = _G.BP_STRUCT_CorpsShopClothingInfo;
};
--头像商品列表
BP_ARRAY_CorpsShopHeadpotraitInfoList = 
{
	BP_STRUCT_CorpsShopHeadpotraitInfo = _G.BP_STRUCT_CorpsShopHeadpotraitInfo;
};

BP_CorpsShop_Level = 0;
BP_CorpsShop_Money = 0;
BP_CorpsPosition = 0;

BP_CorpsShopCurrentSelectPageIdx = 0;
BP_CorpsShopCurrentBuyShopItemId = 0;
BP_CorpsShopCurrentBuyShopItemNum = 0;
BP_CorpsShopCurrentClickShopItemId = 0;

-- 注册Widget
function bp_corps_shop_RegisterUI()
	log("bp_corps_shop_RegisterUI")
	LuaClassObj.SubUIWidgetList(bp_corps_shop,
    	{{Path="/Game/UMG/UI_Logic/Corps/Corps_Shop_Logic_BP.Corps_Shop_Logic_BP_C", Container="Default", ZOrder = BP_ENUM_UI_OWN_CORPS_ZORDER + 1}},
    	{"Lobby"},
		false,
		false,
		true
  	);
  	CorpsBaseUI.RegisterCallBacks(CorpsBaseUI.PageMall, CorpsShopUI.ShowUI, CorpsShopUI.CloseUI);
  	EventSystem:registEvent(EVENTTYPE_LOGIN, EVENTID_BACKLOGIN, CorpsShopUI.OnLogOut);
  	EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_CORPS_MONEY_CHANGE, CorpsShopUI.Refresh);
  	EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_CORPS_ACTIVENESS_CHANGE, CorpsShopUI.OnCorpsNewLevel);
end

function CorpsShopUI.Init()
	CorpsShopSystem.Init();
	BP_CorpsShop_Level = DataMgr.corpsInfo.level;
	BP_CorpsShop_Money = DataMgr.corps_money;
	BP_CorpsPosition = DataMgr.corpsInfo.selfMember.position;
    CorpsShopSystem.GetShopDataReq(CorpsShopSystem.CurrentShopHasStr, CorpsShopSystem.icon_change_time);
    CorpsShopSystem.GetShopLimitBuyReq();
end

function CorpsShopUI.Release()
	BP_CorpsShopCurrentSelectPageIdx = 0;
	BP_CorpsShopCurrentBuyShopItemId = 0;
	BP_CorpsShopCurrentBuyShopItemNum = 0;
	BP_CorpsShopCurrentClickShopItemId = 0;
	CorpsShopSystem.Release();
end

function CorpsShopUI.OnLogOut()
	log("CorpsShopUI.OnLogOut");
	--登出
	CorpsShopSystem.ClearData();
end

function EventCorpsShopUIFetchInfo_Push()

end

function EventFetchInfo()

end

function CorpsShopUI.UpdateRedPoint()
	--设置军团商店小红点数据
	BP_Global_CorpsShopLevelForRedPiont = DataMgr.corpsInfo.level;
	if bp_global then
		LuaClassObj.HandleUIMessage(bp_global, "SetCorpsShopRedPoint");
	end
	CorpsBaseUI.UpdateRedPoint();
end

--军团升级了。
function CorpsShopUI.OnCorpsNewLevel()
	log("CorpsShopUI.OnCorpsNewLevel")
	if DataMgr.corpsInfo.level > BP_Global_CorpsShopLevelForRedPiont then
		CorpsBaseUI.UpdateRedPoint();
		CorpsShopUI.Refresh();
	end
end

function CorpsShopUI.ShowUI()
	CorpsShopUI.UpdateRedPoint();
	CorpsShopUI.Init();
	-- log_tree("CorpsShopUI.ShowUI corpsShopClothingTable", BP_ARRAY_CorpsShopClothingInfoList);
	-- log_tree("CorpsShopUI.ShowUI corpsShopHeadportraitTable", BP_ARRAY_CorpsShopHeadpotraitInfoList);
	LuaClassObj.HandleDynamicCreation(bp_corps_shop);
	LuaClassObj.HandleUIMessage(bp_corps_shop, "UIShow");
	UIManager.Show(eUIType.eCorpsShopUI);
	ClientSendBAReport(BP_BA_CORPS_SHOP, 0);
end

function CorpsShopUI.CloseUI()
	CorpsShopUI.Release();
	if bp_corps_shop then
		UIManager.Hide(eUIType.eCorpsShopUI);
		LuaClassObj.HandleUIMessage(bp_corps_shop, "UIHide");
	end
end

function CorpsShopUI.Refresh()
	log("CorpsShopUI.Refresh");
	log(DataMgr.corps_money)
	BP_CorpsShop_Level = DataMgr.corpsInfo.level;
	BP_CorpsShop_Money = DataMgr.corps_money;
	if bp_corps_shop then
		LuaClassObj.HandleUIMessage(bp_corps_shop, "Refresh");
	end
end

function EventSwitchToClothingPage()
	BP_CorpsShopCurrentSelectPageIdx = CorpsShopSystem.ShopItemType.Clothing;
end

function EventSwitchToHeadpotraitPage()
	BP_CorpsShopCurrentSelectPageIdx = CorpsShopSystem.ShopItemType.Headpotrait;
end

function EventBuyCorpsShopItem()
	log("EventBuyCorpsShopItem  item_id:" .. BP_CorpsShopCurrentBuyShopItemId);
	local info = CorpsShopSystem.GetItemInfoById(BP_CorpsShopCurrentBuyShopItemId);
	if (not info) then
		return
	end
	--[[
	local leftNum = info.limit_buy_num - info.has_buy_num;
	if leftNum <= 0 then
		ShowNotice(421010);
		return;
	end
	]]
	-- log_tree("info",info);
	--[[
	if (info.consume_corps_money > BP_CorpsShop_Money) then
		CorpsShopSystem.ShowNotEnoughMoneyBox();
	else
	]]
		local itemCfg = Client.GetTableData("Item", BP_CorpsShopCurrentBuyShopItemId);
	    if not itemCfg then
	        return;
	    end
	    local leftNum = 0;
	    if info.limit_buy_num > 0 then
	    	leftNum = info.limit_buy_num - info.has_buy_num;
	    elseif info.limit_buy_cd_num_by_day > 0 then
	    	leftNum = info.limit_buy_item_num_by_day - info.has_buy_num;
	    elseif info.permanet_limit_buy_num > 0 then
	    	leftNum = info.permanet_limit_buy_num - info.has_buy_num;
	    else
	    	leftNum = -1; --如果三个都不大于0，就表示无限制
	    end

		--log_tree("EventBuyCorpsShopItem", info)
		--log("EventBuyCorpsShopItem  leftNum:" .. leftNum)
		CommonUseItemsUI.ShowBuyCorpsShopItem(1009, info.consume_corps_money, leftNum, itemCfg, CorpsShopSystem.BuyShopItemReq, info.position_limit, info.time_cd, info.limit_buy_cd_num_by_day);
	--end
end

function EventClickShowBaoxiangDrop()
	log("EventClickShowBaoxiangDrop  item_id:" .. BP_CorpsShopCurrentClickShopItemId);
	local chestDropTable = Client.GetTable("ChestDrop");
	local dropId = nil;
	local titleStr = ""
	for _,chestDrop in pairs(chestDropTable) do
		if chestDrop.ChestID == BP_CorpsShopCurrentClickShopItemId then
			dropId = chestDrop.DropID;
		end
	end
	local ditemCfg  = Client.GetTableData("Item",BP_CorpsShopCurrentClickShopItemId);
	if ditemCfg then
		titleStr = ditemCfg.ItemName
	end
	CommonTreasureBoxPopup:showPanelByDropId(dropId);
	CommonTreasureBoxPopup:SetTitleString(titleStr)
	BP_CorpsShopCurrentClickShopItemId = 0;
end