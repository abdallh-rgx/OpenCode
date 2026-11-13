MallPageDiyUI = MallPageDiyUI or
{
	isShowing = false,
	dataList = {},
}

BP_STRUCT_Mall_Page_Diy_SuitInfo = 
{
	shopID = 0,
	itemID = 0,
	quality = 0,
	shop_rank = 0,
	sale_begin_time = 0,
	limitCount = 0,
}

BP_ARRAY_Mall_Page_Diy_SuitInfo = 
{
	BP_STRUCT_Mall_Page_Diy_SuitInfo = _G.BP_STRUCT_Mall_Page_Diy_SuitInfo,
}

BP_Mall_Page_Diy_Select_Suit_Item_Index = 0;

-------------
BP_Diy_Color_Select_Index = 0;

BP_STRUCT_Diy_Color_Config = 
{
	ID = 0,
	ItemID = 0,
	Name = "",
	ColorR = 0,
	ColorG = 0,
	ColorB = 0,
	Cost = 0,
	BPUrl = "",
}

BP_ARRAY_Diy_Color_Config = 
{
	BP_STRUCT_Diy_Color_Config = _G.BP_STRUCT_Diy_Color_Config,
}


BP_Diy_Mall_Hot_Point_2rd_IsShow = false;
BP_ARRAY_Diy_Mall_HOT_2rdTab =
{
    id = 0;
}

BP_ARRAY_Diy_Mall_Has_Seed_Items =
{
    id = 0;
}
-------------
BP_Diy_Pattern_Select_Index = 0;

BP_STRUCT_Diy_Pattern_Config = 
{
	ID = 0,
	ItemID = 0,
	Cost = 0,
	BPUrl = "",
	Icon = "",
	Name = "",
}

BP_ARRAY_Diy_Pattern_Config = 
{
	BP_STRUCT_Diy_Pattern_Config = _G.BP_STRUCT_Diy_Pattern_Config,
}

BP_Mall_Page_Diy_Second_Page_Index = 0;

local lastSelectSuitItemIndex = 0;
local lastSelectColorIndex = 0;
local lastSelectPatternIndex = 0;
--注册Widget
function bp_mall_page_diy_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_mall_page_diy,
		{{Path="/Game/UMG/UI_LOGIC/Lobby_Store/Store_2/Store_Diy_Suit_BP.Store_Diy_Suit_BP_C", Container="Default", ZOrder=0}},
		{"MallSystem", "Lobby"},
		false,
		false
	);
end

function MallPageDiyUI.Init()
	--请求数据
	BP_ARRAY_Diy_Color_Config = {};
	BP_ARRAY_Diy_Pattern_Config = {};
	DiySuitSystem.Init();
	--注册回调

	LuaClassObj.HandleDynamicCreation(bp_mall_page_diy);
end

function EventSetInfo_Push()

end

function EventSyncData()

end

local function SortList(a, b)
	return a.ID < b.ID;
end

function MallPageDiyUI.GetColorConfig(id)
	BP_ARRAY_Diy_Color_Config = DiySuitSystem.GetConfigByItemID("DiySuitColorConfig", id)
	table.sort(BP_ARRAY_Diy_Color_Config, SortList);
end

--
function MallPageDiyUI.GetPatternConfig(id)
	BP_ARRAY_Diy_Pattern_Config = DiySuitSystem.GetConfigByItemID("DiySuitPatternConfig", id)
	table.sort(BP_ARRAY_Diy_Pattern_Config, SortList);
end

function MallPageDiyUI.Release()
	MallPageDiyUI.Hide();
	MallPageDiyUI.isShowing = false;

	MallSystemUI_2.ForceRevertAvatar()
end

function MallPageDiyUI.Show(startSecondIndex, setFirstSelectShopId)
	MallPageDiyUI.ResetData();
 	MallSystemUI_2.SetEquipBG(0)
 	MallSystemUI_2.ShowWeapon(0,0,false)
 	MallSystemUI_2:RevertAvatar()
	MallSystemUI_2.StopEmoteAction()
	 
	startSecondIndex = 1;--只有一页
	BP_Mall_Page_Diy_Second_Page_Index = startSecondIndex;

	LuaClassObj.HandleUIMessage(bp_mall_page_diy, "UIShow");
	UIManager.Show(eUIType.eMallPageDIY)
	MallPageDiyUI.SetClickTab();
end

function MallPageDiyUI.Hide(isRelease)
	MallPageDiyUI.ResetData();
	UIManager.Hide(eUIType.eMallPageDIY)
	LuaClassObj.HandleUIMessage(bp_mall_page_diy, "UIHide");
	MallSystemUI_2.HideSex();
end

function MallPageDiyUI.ResetData()
	lastSelectSuitItemIndex = 1;
	lastSelectColorIndex = 1;
	lastSelectPatternIndex = 1;
	BP_Mall_Page_Diy_Select_Suit_Item_Index = 1;
	BP_Diy_Color_Select_Index = 1;
	BP_Diy_Pattern_Select_Index = 1;
end

function MallPageDiyUI.GetSuitDataList(pageIndex)
	if MallPageDiyUI.dataList ~= nil then
		return MallPageDiyUI.dataList[pageIndex] or {};
	end
	return {};
end

function MallPageDiyUI.UpdateList(pageIndex, dataList, tabInfo, curGetTime,curGetTime2,setFirstSelectShopId)
	MallPageDiyUI.dataList = dataList or {};
	MallPageDiyUI.UpdateSuitItemList();

	MallPageDiyUI.SetSelectSuitInfo();
	LuaClassObj.HandleUIMessage(bp_mall_page_diy, "UpdateSuitList");
	LuaClassObj.HandleUIMessage(bp_mall_page_diy, "UpdateColorList");
	LuaClassObj.HandleUIMessage(bp_mall_page_diy, "UpdatePatternList");

	MallPageDiyUI.UpdateAvatar();
	LuaClassObj.HandleUIMessage(bp_mall_page_diy, "UpdatePrice");
	MallSystemUI_2.ShowSex();
end

function MallPageDiyUI.UpdateSuitItemList()
	BP_ARRAY_Mall_Page_Diy_SuitInfo = {};
	local suitItemList = MallPageDiyUI.GetSuitDataList(BP_Mall_Page_Diy_Second_Page_Index);
	for k,v in pairs(suitItemList) do
		local suitItem = MallPageDiyUI.MaketDataToSuitItemData(v);
		table.insert(BP_ARRAY_Mall_Page_Diy_SuitInfo, suitItem);
	end
	MallSystemUI_2.SortList(BP_ARRAY_Mall_Page_Diy_SuitInfo, 0);
end

function MallPageDiyUI.MaketDataToSuitItemData(marketData)
	local resItem = Client.GetTableData("Item",marketData.item_id);
	if resItem == nil then
		log("no itemCfg :" .. marketData.item_id)
		return nil;
	end
	local selectColorCfg = MallPageDiyUI.GetSelectColorCfg();
	local selectPatternCfg = MallPageDiyUI.GetSelectPatternCfg();
	-- 注意字段不要缺失，以免排序出问题
	local data = MallSystemUI_2.MarketData2ItemData(marketData, selectColorCfg and selectColorCfg.ID or 0, selectPatternCfg and selectPatternCfg.ID or 0);
	local suitItemData = 
	{
		shopID = data.shopID,
		itemID = data.itemID,
		quality = data.quality,
		shop_rank = data.shop_rank,
		sale_begin_time = data.sale_begin_time,
		limitCount = data.limitCount,
		priceType = data.priceType,
		price = data.price,
	}
	return suitItemData;
end

function MallPageDiyUI.UpdateAvatar()
	MallSystemUI_2:RevertAvatar();
	local selectColorCfg = MallPageDiyUI.GetSelectColorCfg();
	local selectPatternCfg = MallPageDiyUI.GetSelectPatternCfg();
	MallSystemUI_2.ShowItem(BP_STRUCT_Mall_Page_Diy_SuitInfo.itemID, nil, selectColorCfg and selectColorCfg.ID or 0, selectPatternCfg and selectPatternCfg.ID or 0);
end

function MallPageDiyUI.OnClickSuitItem(selectIndex)
	if lastSelectSuitItemIndex == selectIndex then
		log("lastSelectSuitItemIndex == selectIndex")
		return false;
	end
	if lastSelectSuitItemIndex ~= 0 then
		log("lastSelectSuitItemIndex ~= 0")
		LuaClassObj.HandleUIMessage(bp_mall_page_diy, "ClearCurSelectSuitItem");
		lastSelectSuitItemIndex = 0;
	end
	if selectIndex > 0 then
		lastSelectSuitItemIndex = selectIndex;

		BP_Mall_Page_Diy_Select_Suit_Item_Index = selectIndex;
		BP_Diy_Color_Select_Index = 1;
		BP_Diy_Pattern_Select_Index = 1;

		MallPageDiyUI.SetSelectSuitInfo();
		LuaClassObj.HandleUIMessage(bp_mall_page_diy, "UpdateColorList");
		LuaClassObj.HandleUIMessage(bp_mall_page_diy, "UpdatePatternList");

		MallPageDiyUI.UpdateAvatar();
		LuaClassObj.HandleUIMessage(bp_mall_page_diy, "UpdatePrice");
		return true;
	end
	return false;
end

function MallPageDiyUI.OnClickColorItem(selectIndex)
	if lastSelectColorIndex == selectIndex then
		return false;
	end
	if lastSelectColorIndex ~= 0 then
		LuaClassObj.HandleUIMessage(bp_mall_page_diy, "ClearCurSelectColorItem");
		lastSelectColorIndex = 0;
	end
	if selectIndex > 0 then
		lastSelectColorIndex = selectIndex;
		BP_Diy_Color_Select_Index = selectIndex;

		MallPageDiyUI.UpdateAvatar();
		LuaClassObj.HandleUIMessage(bp_mall_page_diy, "UpdatePrice");
		return true;
	end
	return false;
end

function MallPageDiyUI.OnClickPatternItem(selectIndex)
	log("MallPageDiyUI.OnClickPatternItem selectIndex:"..tostring(selectIndex));
	if lastSelectPatternIndex == selectIndex then
		return false;
	end
	if lastSelectPatternIndex ~= 0 then
		LuaClassObj.HandleUIMessage(bp_mall_page_diy, "ClearCurSelectPatternItem");
		lastSelectPatternIndex = 0;
	end
	if selectIndex > 0 then
		lastSelectPatternIndex = selectIndex;
		BP_Diy_Pattern_Select_Index = selectIndex;

		MallPageDiyUI.UpdateAvatar();
		LuaClassObj.HandleUIMessage(bp_mall_page_diy, "UpdatePrice");
		return true;
	end
	return false;
end

function MallPageDiyUI.SetSelectSuitInfo()
	if BP_Mall_Page_Diy_Select_Suit_Item_Index <= #BP_ARRAY_Mall_Page_Diy_SuitInfo then
		BP_STRUCT_Mall_Page_Diy_SuitInfo = BP_ARRAY_Mall_Page_Diy_SuitInfo[BP_Mall_Page_Diy_Select_Suit_Item_Index];
	end
end

function MallPageDiyUI.GetSelectColorCfg()
	if BP_Diy_Color_Select_Index <= #BP_ARRAY_Diy_Color_Config then
		return BP_ARRAY_Diy_Color_Config[BP_Diy_Color_Select_Index];
	end
end

function MallPageDiyUI.GetCurBuyPrice()
	local price = 0;
	if BP_STRUCT_Mall_Page_Diy_SuitInfo then
		price = price + BP_STRUCT_Mall_Page_Diy_SuitInfo.price;
	end
	local selectColorCfg = MallPageDiyUI.GetSelectColorCfg();
	if selectColorCfg then
		price = price + selectColorCfg.Cost;
	end
	local selectPatternCfg = MallPageDiyUI.GetSelectPatternCfg();
	if selectPatternCfg then
		price = price + selectPatternCfg.Cost;
	end
	log("MallPageDiyUI.GetCurBuyPrice price:"..tostring(price))
	return price;
end

function MallPageDiyUI.GetSelectPatternCfg()
	if BP_Diy_Pattern_Select_Index <= #BP_ARRAY_Diy_Pattern_Config then
		return BP_ARRAY_Diy_Pattern_Config[BP_Diy_Pattern_Select_Index];
	end
end

function MallPageDiyUI.DiyBuyItem()
	if BP_STRUCT_Mall_Page_Diy_SuitInfo == nil then
		log("BP_STRUCT_Mall_Page_Diy_SuitInfo = nil!");
		return;
	end
	if BP_STRUCT_Mall_Page_Diy_SuitInfo.limitCount <= 0 then
		DataMgr.ShowNoticeByID(4639);
		return;
	end

	local selectColorCfg = MallPageDiyUI.GetSelectColorCfg();
	local selectPatternCfg = MallPageDiyUI.GetSelectPatternCfg();
	if selectColorCfg == nil or selectPatternCfg == nil then
		return;
	end
	if MallSystemUI_2.IsHasItem(BP_STRUCT_Mall_Page_Diy_SuitInfo.itemID, selectColorCfg.ID, selectPatternCfg.ID) == true then
        CommonMessageBoxUI:ShowPanel(2, 
            Client.GetTableData("LocalizeRes", "101001").TextValue, 
            Client.GetTableData("LocalizeRes", "6046").TextValue,
            function()
                MallSystemUI_2.OpenBuySingleItemWin(BP_STRUCT_Mall_Page_Diy_SuitInfo.shopID, selectColorCfg.ID, selectPatternCfg.ID);
            end
        )
	else
		MallSystemUI_2.OpenBuySingleItemWin(BP_STRUCT_Mall_Page_Diy_SuitInfo.shopID, selectColorCfg.ID, selectPatternCfg.ID);
	end
end

function MallPageDiyUI.SendItem()
	if BP_STRUCT_Mall_Page_Diy_SuitInfo == nil then
		log("BP_STRUCT_Mall_Page_Diy_SuitInfo = nil!");
		return;
	end
	local selectColorCfg = MallPageDiyUI.GetSelectColorCfg();
	local selectPatternCfg = MallPageDiyUI.GetSelectPatternCfg();
	if selectColorCfg == nil or selectPatternCfg == nil then
		return;
	end
	MallSystemUI_2.MallSendShopItem(BP_STRUCT_Mall_Page_Diy_SuitInfo.shopID, selectColorCfg.ID, selectPatternCfg.ID);
end

function MallPageDiyUI.GetHotState(firstTab, dataList, tabInfo)
	local isNew = false;
	local secondTab = 1--tabInfo["B_table_ID" .. i];
	isNew =  isNew or MallPageDiyUI.GetTab2HotState(firstTab, secondTab, false);
	return isNew;
end

function MallPageDiyUI.GetTab2HotState(firstTab, secondTab, isGetSecond)
	local allDict = MallSystem.GetMallSimpleInfoDict(); 

	if allDict ~= nil and allDict[firstTab] ~= nil and allDict[firstTab][secondTab] ~= nil then
		local curDict = allDict[firstTab][secondTab];
		BP_ARRAY_Diy_Mall_HOT_2rdTab = curDict;
		LuaClassObj.HandleUIMessage(bp_mall_page_diy, "LuaGetTab2Hot");
		if BP_Diy_Mall_Hot_Point_2rd_IsShow then
			BP_Diy_Mall_2_Second_Hot_IsShow = true;
			return true;
		end
	end
	BP_Diy_Mall_2_Second_Hot_IsShow = false;
	return false;
end

function MallPageDiyUI.SetClickTab()
	local firstTab = DIY_SUIT_INDEX;
	local secondTab = 1;
	local allDict = MallSystem.GetMallSimpleInfoDict(); 
	local dataList = nil;
	if allDict ~= nil and allDict[firstTab] ~= nil and allDict[firstTab][secondTab] ~= nil then
		dataList = allDict[firstTab][secondTab];
	end
	if dataList == nil then
		return;
	end
	local temp = {};
	for i,v in pairs(dataList) do
		table.insert(temp, v);
	end
	BP_ARRAY_Diy_Mall_Has_Seed_Items = temp;
	LuaClassObj.HandleUIMessage(bp_mall_page_diy, "LuaSetHasSeeItems");
	MallSystemUI_2.UpdateFirstTabHotState();
end