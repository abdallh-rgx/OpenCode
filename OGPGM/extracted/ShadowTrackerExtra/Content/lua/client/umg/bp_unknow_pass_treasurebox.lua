-- 随机宝箱奖励预览UI
UnknowPassTreasureBoxUI = UnknowPassTreasureBoxUI or
{
	isShow = false;
	previewWearInfo = {};
}


--展示宝箱名称
BP_UnknowPass_Treasure_Box_ItemId = ""
BP_UnknowPass_Treasure_Box_InstId = ""
BP_UnknowPass_Treasure_Box_Name = ""
BP_UnknowPass_Treasure_Box_Info = ""

--已有宝箱数
BP_UnknowPass_Treasure_Box_Has_Num = 0

--宝箱可开取道具信息
BP_STRUCT_UnknowPass_Treasure_Box_ItemInfo = 
{
	itemId = 0,		--物品id
	itemIcon = "",	--道具图标
	itemLevel = 0,
	itemNum = 0,
	isLocked = 0,
	sort = 0,
}
BP_ARRAY_UnknowPass_Treasure_Box_Item_List = 
{
	BP_STRUCT_UnknowPass_Treasure_Box_ItemInfo = _G.BP_STRUCT_UnknowPass_Treasure_Box_ItemInfo,
};

--当前选择格子下标
BP_UnknowPass_Treasure_Box_Cur_Select_Index = 0

--当前是否是pass开启箱子
BP_UnknowPass_Treasure_Box_Is_Open_Box = false

--前一个选择的道具id
BP_UnknowPass_Treasure_Box_PreSelect_Item_Id = 0

--注册Widget
function bp_unknow_pass_treasurebox_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_unknow_pass_treasurebox,
        {{Path="/Game/UMG/UI_Logic/UnknowPass/UnknowPass_TreasureBox_Logic_BP.UnknowPass_TreasureBox_Logic_BP_C", Container="Default", ZOrder=15}},
        {"Lobby"},
        false,
        false,
        true
    );
end

--sami 初始化显示
function UnknowPassTreasureBoxUI.Init()	
	--关闭pass相关的界面显示
    log("UnknowPassTreasureBoxUI.Init")
	if UnknowPassUI.isShowing and UnknowPassUI.isTabShow then
		LuaClassObj.HandleUIMessage(bp_unknow_pass, "HideSelf");
	end
	if UnknowPassAwardUI.isShowing == true then
		LuaClassObj.HandleUIMessage(bp_unknow_pass_award, "HideSelf");
	end
	if UnknowPassExchangeUI.isShow == true then
		LuaClassObj.HandleUIMessage(bp_unknow_pass_exchange, "HideSelf");
	end
	UnknowPassSystem.HideAvatar();
	
	--显示UI
	LuaClassObj.HandleDynamicCreation(bp_unknow_pass_treasurebox);
	LuaClassObj.HandleUIMessage(bp_unknow_pass_treasurebox, "UIShow");
	UIManager.Show(eUIType.eUnknowPassTreasureBoxUI);
	UnknowPassTreasureBoxUI.isShow = true

	if UnknowPassUI.jumpInfo then
		BP_UnknowPass_Treasure_Box_Cur_Select_Index = UnknowPassTreasureBoxUI.GetItemIndex(UnknowPassUI.jumpInfo.itemId)
		EventUnknowPassTreasureBoxSelectItem();
		LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass_treasurebox, "JumpToSelect");
		UnknowPassUI.jumpInfo = nil
	else
		--默认选中第一个道具
		BP_UnknowPass_Treasure_Box_Cur_Select_Index = 0
		EventUnknowPassTreasureBoxSelectItem()
	end
	EventSystem:registEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_ITEM_USED, UnknowPassTreasureBoxUI.OnItemUse);
end

function UnknowPassTreasureBoxUI.Release()
    log("UnknowPassTreasureBoxUI.Release")
end

function UnknowPassTreasureBoxUI.GetItemIndex(itemId)
	for i=1,#BP_ARRAY_UnknowPass_Treasure_Box_Item_List,1 do
		if BP_ARRAY_UnknowPass_Treasure_Box_Item_List[i].itemId == itemId then
			return i-1
		end
	end
	return 0
end

--设置本UI所需数据
function UnknowPassTreasureBoxUI.SetData(itemId, itemList)
	local cfg = Client.GetTableData("Item", itemId)
	if cfg == nil then
		return
	end
	BP_UnknowPass_Treasure_Box_ItemId = tostring(itemId)
	BP_UnknowPass_Treasure_Box_InstId = UnknowPassTreasureBoxUI.GetItemInstId(itemId)
	BP_UnknowPass_Treasure_Box_Name = cfg.ItemName
	log("BP_UnknowPass_Treasure_Box_Name"..BP_UnknowPass_Treasure_Box_Name)

	local fmt = Client.GetTableData("LocalizeRes", "750003").TextValue;
	BP_UnknowPass_Treasure_Box_Info = string.format(fmt, cfg.ItemName)
	log("BP_UnknowPass_Treasure_Box_Info"..BP_UnknowPass_Treasure_Box_Info)
	
	BP_ARRAY_UnknowPass_Treasure_Box_Item_List = {}
	for k, v in pairs(itemList) do
		local cfg2 = Client.GetTableData("Item", v.itemId)
		if cfg2 ~= nil then
			local info = {}
			info.itemId = v.itemId
			info.itemIcon = cfg2.ItemSmallIcon
			info.itemLevel = cfg2.ItemQuality
			info.itemNum = 1
			info.isLocked = 0
			info.sort = v.sort
			table.insert(BP_ARRAY_UnknowPass_Treasure_Box_Item_List, info)
		end
	end
	table.sort(BP_ARRAY_UnknowPass_Treasure_Box_Item_List, function(a, b)
		return a.sort > b.sort
	end)
	--log_tree("BP_ARRAY_UnknowPass_Treasure_Box_Item_List", BP_ARRAY_UnknowPass_Treasure_Box_Item_List)

	BP_UnknowPass_Treasure_Box_Has_Num = UnknowPassTreasureBoxUI.GetItemCount(itemId)
	log("BP_UnknowPass_Treasure_Box_Has_Num "..BP_UnknowPass_Treasure_Box_Has_Num)

	BP_UnknowPass_Treasure_Box_Cur_Select_Index = 0
end

function UnknowPassTreasureBoxUI.GetItemInstId(itemId)
	if DataMgr.arrayHallDepotItemInfo == nil then
		return 0
	end
	for k,v in pairs(DataMgr.arrayHallDepotItemInfo) do
		if v.resID == itemId then
			return v.insID
		end
	end
	return 0
end

--获取背包道具数量
function UnknowPassTreasureBoxUI.GetItemCount(itemId)
	if DataMgr.arrayHallDepotItemInfo == nil then
		return 0
	end
	--log_tree("UnknowPassTreasureBoxUI.GetItemInstId ", DataMgr.arrayHallDepotItemInfo)

	local count = 0
	for k,v in pairs(DataMgr.arrayHallDepotItemInfo) do
		if v.resID == itemId then
			--log_tree("v:", v);
			count = count + v.count
		end
	end
	return count
end

--关闭
function EventUnknowPassTreasureBoxClose()
	log("EventUnknowPassTreasureBoxClose")
	LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass_treasurebox, "DestroyAvatar");
    
	UnknowPassTreasureBoxUI.isShow = false
	UIManager.Hide(eUIType.eUnknowPassTreasureBoxUI);

	EventSystem:unregistEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_ITEM_USED, UnknowPassTreasureBoxUI.OnItemUse);
	
	if UnknowPassUI.isShowing and UnknowPassUI.isTabShow then
		LuaClassObj.HandleUIMessage(bp_unknow_pass, "ShowSelf");
	end
	if UnknowPassAwardUI.isShowing == true then
		LuaClassObj.HandleUIMessage(bp_unknow_pass_award, "ShowSelf");
	end
	if UnknowPassExchangeUI.isShow == true then
		LuaClassObj.HandleUIMessage(bp_unknow_pass_exchange, "ShowSelf");
	end	
	
	LuaClassObj.HandleUIMessage(bp_unknow_pass, "HideItemDes");
	LuaClassObj.HandleUIMessage(bp_unknow_pass, "HideItemDetailOnly");

	if nil ~= UIManager.GetUI(eUIType.eUnknowPassAwardUI) then
		UnknowPassSystem.ShowLeftDetailDefault();
		UnknowPassAwardUI.HideSelectItem();
	elseif nil ~= UIManager.GetUI(eUIType.eUnknowPassExchangeUI) then
		UnknowPassSystem.ShowLeftDetail(UnkonwPass_ShowLeftDetailDefaultAvatar)
		UnknowPassExchangeUI.HideSelectItem();
	end
end

--选择一个道具
function EventUnknowPassTreasureBoxSelectItem()
	log("EventUnknowPassTreasureBoxSelectItem BP_UnknowPass_Treasure_Box_Cur_Select_Index "..BP_UnknowPass_Treasure_Box_Cur_Select_Index)
	LuaClassObj.HandleUIMessage(bp_unknow_pass_treasurebox, "FreshSelectItem");

	if BP_ARRAY_UnknowPass_Treasure_Box_Item_List[BP_UnknowPass_Treasure_Box_Cur_Select_Index + 1] then
		local itemId = BP_ARRAY_UnknowPass_Treasure_Box_Item_List[BP_UnknowPass_Treasure_Box_Cur_Select_Index + 1].itemId
		UnknowPassUI.ShowItemInfo(itemId)
	end
end

function UnknowPassTreasureBoxUI.StrSplit(str, reps)
    local resultStrList = {}
    string.gsub(str, '[^'..reps..']+', function(w)
        table.insert(resultStrList,w)
    end)
    return resultStrList
end

--sami 点击规则
function EventUnknowPassTreasureBoxClickHelp()
	log("EventUnknowPassTreasureBoxClickHelp")
	local itemId = tonumber(BP_UnknowPass_Treasure_Box_ItemId)
	local tb = Client.GetTable("ShopItem")
	local showRate = ""
	for k,v in pairs(tb) do
		if v.ItemID == itemId then
			showRate = v.showRate
			break
		end
	end

	--log_tree("showRate", showRate)
	local rate = UnknowPassTreasureBoxUI.StrSplit(showRate, ";")
	--log_tree("rate", rate)
	Rate_Panel_UI.Show(rate);
end

--点击性别预览按钮
function EventUnknowPassTreasureBoxClickSwitchSex()
	log("EventUnknowPassTreasureBoxClickSwitchSex")
	EventUnknowPassClickSwitchSex();
end


--使用道具成功回包
function UnknowPassTreasureBoxUI.OnItemUse()
	BP_UnknowPass_Treasure_Box_Has_Num = UnknowPassTreasureBoxUI.GetItemCount(tonumber(BP_UnknowPass_Treasure_Box_ItemId))
	LuaClassObj.HandleUIMessage(bp_unknow_pass_treasurebox, "FreshUI");
end


