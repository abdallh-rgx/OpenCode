-- 随机宝箱奖励预览UI
AllianceCompetitionTreasureBoxUI = AllianceCompetitionTreasureBoxUI or
{
	isShow = false;
}

--展示宝箱名称
BP_AllianceCompetition_Treasure_Box_ItemId = ""
BP_AllianceCompetition_Treasure_Box_InstId = ""
BP_AllianceCompetition_Treasure_Box_Name = ""
BP_AllianceCompetition_Treasure_Box_Info = ""
BP_AllianceCompetition_TreasureBoxCost = 0

--已有宝箱数
BP_AllianceCompetition_Treasure_Box_Has_Num = 0

--宝箱可开取道具信息
BP_STRUCT_AllianceCompetition_Treasure_Box_ItemInfo = 
{
	itemId = 0,		--物品id
	itemIcon = "",	--道具图标
	itemLevel = 0,
	itemNum = 0,
	isLocked = 0,
}

BP_ARRAY_AllianceCompetition_Treasure_Box_Item_List = 
{
	BP_STRUCT_AllianceCompetition_Treasure_Box_ItemInfo = _G.BP_STRUCT_AllianceCompetition_Treasure_Box_ItemInfo,
};

--当前选择格子下标
BP_AllianceCompetition_Treasure_Box_Cur_Select_Index = 0

--当前是否是pass开启箱子
BP_AllianceCompetition_Treasure_Box_Is_Open_Box = false

-- 道具名字
BP_AllianceCompetition_CurItemName = ""
-- 图片路径
BP_AllianceCompetition_CurItemImage = ""

local _avatar = nil

--注册Widget
function bp_alliancecompetition_treasurebox_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_alliancecompetition_treasurebox,
        {{Path="/Game/UMG/UI_Logic/Lobby_Team/LobbyTeam_Competition_Box_LogicBP.LobbyTeam_Competition_Box_LogicBP_C", Container="Default", ZOrder=15}},
        {"Lobby"},
        false,
        false,
        true
    );
end

--sami 初始化显示
function AllianceCompetitionTreasureBoxUI.Init()	
    log("AllianceCompetitionTreasureBoxUI.Init")

	-- if AllianceUI.isShowing then
	-- 	LuaClassObj.HandleUIMessageNoFetch(bp_alliance, "SetHidden")
	-- end
		
	LuaClassObj.HandleDynamicCreation(bp_alliancecompetition_treasurebox)
	LuaClassObj.HandleUIMessageNoFetch(bp_alliancecompetition_treasurebox, "UIShow")
	LuaClassObj.HandleUIMessageNoFetch(bp_alliancecompetition_treasurebox, "UpdateItems")

	AllianceCompetitionTreasureBoxUI.isShow = true

	AllianceCompetitionShopUI.HideSelf()
	LuaClassObj.HandleUIMessageNoFetch(bp_alliancecompetition_treasurebox, "HideImage")

	AllianceUI:SetHidden()
	-- EventAllianceCompetitionTreasureBoxSelectItem()
	
	-- EventSystem:registEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_ITEM_USED, AllianceCompetitionTreasureBoxUI.OnItemUse);
end

function AllianceCompetitionTreasureBoxUI.Release()
    log("AllianceCompetitionTreasureBoxUI.Release")
end

function AllianceCompetitionTreasureBoxUI.SetData(itemId, itemList, avatar)
	log_tree("itemListitemListitemListitemList",itemList)
	local cfg = Client.GetTableData("Item", itemId)
	if cfg == nil then
		return
	end

	_avatar = avatar
	_avatar:StoreEquipments()

	BP_AllianceCompetition_Treasure_Box_ItemId = tostring(itemId)
	BP_AllianceCompetition_Treasure_Box_InstId = AllianceCompetitionTreasureBoxUI.GetItemInstId(itemId)
	BP_AllianceCompetition_Treasure_Box_Name = cfg.ItemName
	log("BP_AllianceCompetition_Treasure_Box_Name"..BP_AllianceCompetition_Treasure_Box_Name)

	-- local fmt = Client.GetTableData("LocalizeRes", "750003").TextValue;
	-- BP_AllianceCompetition_Treasure_Box_Info = string.format(fmt, cfg.ItemName)
	-- log("BP_AllianceCompetition_Treasure_Box_Info"..BP_AllianceCompetition_Treasure_Box_Info)
	
	-- 更新需要购买名字
    for i,v in ipairs(BP_ARRAY_AllianceCompetition_ShopItemInfoList) do
        if v.itemId == BP_AllianceCompetition_operateShopId then
            BP_AllianceCompetition_TreasureBoxCost = v.costScore
            break
        end
    end

	BP_ARRAY_AllianceCompetition_Treasure_Box_Item_List = {}
	for k, v in pairs(itemList) do
		local cfg2 = Client.GetTableData("Item", v)
		if cfg2 ~= nil then
			local info = {}
			info.itemId = v
			info.itemIcon = cfg2.ItemSmallIcon
			info.itemLevel = cfg2.ItemQuality
			info.itemNum = 1
			info.isLocked = 0
			table.insert(BP_ARRAY_AllianceCompetition_Treasure_Box_Item_List, info)
		end
	end
	table.sort(BP_ARRAY_AllianceCompetition_Treasure_Box_Item_List, function(a, b)
		if a.itemLevel > b.itemLevel then
			return true
		elseif a.itemLevel < b.itemLevel then
			return false
		else
			return a.itemId > b.itemId
		end
	end)
	--log_tree("BP_ARRAY_AllianceCompetition_Treasure_Box_Item_List", BP_ARRAY_AllianceCompetition_Treasure_Box_Item_List)

	BP_AllianceCompetition_Treasure_Box_Has_Num = AllianceCompetitionTreasureBoxUI.GetItemCount(itemId)
	log("BP_AllianceCompetition_Treasure_Box_Has_Num "..BP_AllianceCompetition_Treasure_Box_Has_Num)

	BP_AllianceCompetition_Treasure_Box_Cur_Select_Index = 0
end

function AllianceCompetitionTreasureBoxUI.GetItemInstId(itemId)
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


function AllianceCompetitionTreasureBoxUI.GetItemCount(itemId)
	if DataMgr.arrayHallDepotItemInfo == nil then
		return 0
	end
	--log_tree("AllianceCompetitionTreasureBoxUI.GetItemInstId ", DataMgr.arrayHallDepotItemInfo)

	local count = 0
	for k,v in pairs(DataMgr.arrayHallDepotItemInfo) do
		if v.resID == itemId then
			--log_tree("v:", v);
			count = count + v.count
		end
	end
	return count
end

function EventAllianceCompetitionTreasureBoxClose()
	log("EventAllianceCompetitionTreasureBoxClose")
	AllianceCompetitionTreasureBoxUI.isShow = false
	_avatar:RestoreEquipments()
	-- EventSystem:unregistEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_ITEM_USED, AllianceCompetitionTreasureBoxUI.OnItemUse);

	-- LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass, "HideItemDes");
	LuaClassObj.HandleUIMessageNoFetch(bp_alliancecompetition_treasurebox, "UIHide");

	AllianceCompetitionShopUI.ShowSelf()
	AllianceCompetitionShopUI.HideImage()

	AllianceUI:SetVisible()

	-- if AllianceUI.isShowing then
	-- 	LuaClassObj.HandleUIMessageNoFetch(bp_alliance, "SetVisible");
	-- end
end

function EventAllianceCompetitionBoxSelectItem()
	log("EventAllianceCompetitionTreasureBoxSelectItem BP_AllianceCompetition_Treasure_Box_Cur_Select_Index "..BP_AllianceCompetition_Treasure_Box_Cur_Select_Index)
	-- 其实是道具id
	local itemDataCfg = Client.GetTableData("Item", BP_AllianceCompetition_Treasure_Box_Cur_Select_Index)
	if itemDataCfg == nil then
		return
	end

	local showItemDetail = true;

	if itemDataCfg.ItemType == 1 then
		if itemDataCfg.ItemSubType == 801 then
			-- BP_AllianceCompetition_Show_Item_type = "tool";	--平底锅
		else
			-- BP_AllianceCompetition_Show_Item_type = "weapon";--武器
			showItemDetail = false;
			-- AllianceCompetitionShopUI.ShowItemAvatar(itemId);
		end

	elseif itemDataCfg.ItemType == 22 then
		-- BP_AllianceCompetition_Show_Item_type = "dance";--舞蹈
		showItemDetail = false;
		-- LobbyUI:ShowEmoteAction(DataMgr.roleData.uid, itemId);

	elseif itemDataCfg.ItemType == 4 and itemDataCfg.ItemSubType == 701 then
		-- BP_AllianceCompetition_Show_Item_type = "parachute";--降落伞

	elseif itemDataCfg.ItemType == 8 and itemDataCfg.ItemSubType == 801 then
		-- BP_AllianceCompetition_Show_Item_type = "aircraft";--飞机皮肤

	elseif itemDataCfg.ItemType == 5 then
		if itemDataCfg.ItemSubType == 501 or itemDataCfg.ItemSubType == 504 then
			-- BP_AllianceCompetition_Show_Item_type = "image";	--背包
			showItemDetail = false;
			-- itemId = AllianceCompetitionShopUI.ToPreviewItemId(itemId)
			-- AllianceCompetitionShopUI.ShowItemAvatar(itemId);

		elseif itemDataCfg.ItemSubType == 502 or itemDataCfg.ItemSubType == 505 then
			-- BP_AllianceCompetition_Show_Item_type = "image";	--头盔
			showItemDetail = false;
			-- itemId = AllianceCompetitionShopUI.ToPreviewItemId(itemId)
			-- AllianceCompetitionShopUI.ShowItemAvatar(itemId);
		else
			-- BP_AllianceCompetition_Show_Item_type = "tool";	--道具
		end

	elseif itemDataCfg.ItemType == 4 then
		-- BP_AllianceCompetition_Show_Item_type = "image";--形象
		showItemDetail = false;
		-- AllianceCompetitionShopUI.ShowItemAvatar(itemId);

	elseif itemDataCfg.ItemType == 9 then
		-- BP_AllianceCompetition_Show_Item_type = "car";	--载具
	else
		-- BP_AllianceCompetition_Show_Item_type = "tool";--默认为道具
	end

	log(string.format("[yyc] ShowItemInfo item type = %s", BP_AllianceCompetition_Show_Item_type));
	-- BP_AllianceCompetition_Show_Detail_ResId = itemId
	-- BP_AllianceCompetitionShopPreSelectItemId = itemId
	-- BP_AllianceCompetition_ShowAvatar = showItemDetail

	if showItemDetail == false then
		LuaClassObj.HandleUIMessageNoFetch(bp_alliancecompetition_treasurebox, "HideImage")
		
	else
		LuaClassObj.HandleUIMessageNoFetch(bp_alliancecompetition_treasurebox, "ShowImage")

	end

	BP_AllianceCompetition_CurItemName = itemDataCfg.ItemName
	BP_AllianceCompetition_CurItemImage = itemDataCfg.ItemBigIcon

	LuaClassObj.HandleUIMessageNoFetch(bp_alliancecompetition_treasurebox, "UpdateSelectedItem")
	AllianceCompetitionShopUI.ShowItemInfo(BP_AllianceCompetition_Treasure_Box_Cur_Select_Index)
end

function AllianceCompetitionTreasureBoxUI.StrSplit(str, reps)
    local resultStrList = {}
    string.gsub(str, '[^'..reps..']+', function(w)
        table.insert(resultStrList,w)
    end)
    return resultStrList
end

function EventAllianceCompetitionTreasureBoxClickHelp()
	log("EventAllianceCompetitionTreasureBoxClickHelp")
	local itemId = tonumber(BP_AllianceCompetition_Treasure_Box_ItemId)
	local tb = Client.GetTable("ShopItem")
	local showRate = ""
	for k,v in pairs(tb) do
		if v.ItemID == itemId then
			showRate = v.showRate
			break
		end
	end

	local rate = AllianceCompetitionTreasureBoxUI.StrSplit(showRate, ";")
	Rate_Panel_UI.Show(rate);
end

function EventAllianceCompetitionTreasureBoxClickBuy()
    AllianceCompetitionSystem.log("EventAllianceCompetitionTreasureBoxClickBuy BP_AllianceCompetition_Treasure_Box_ItemId "..BP_AllianceCompetition_Treasure_Box_ItemId)

    -- log_tree("ccccccc,",BP_ARRAY_AllianceCompetition_ShopItemInfoList)

    for i,v in ipairs(BP_ARRAY_AllianceCompetition_ShopItemInfoList) do
        if tonumber(v.itemId) == tonumber(BP_AllianceCompetition_Treasure_Box_ItemId) then
        	-- log_tree("ccccccc,",v)
            if v.curCount < v.maxCount then
                BP_UnknowPass_Confirm_ExchangeId = v.exchangeId
                BP_UnknowPass_Confirm_ExchangeItemId = v.itemId
				BP_UnknowPass_Confirm_Cost_ItemId = 0
				BP_UnknowPass_Confirm_Cost_ItemNum = v.costScore
				BP_UnknowPass_Confirm_BuyCount = v.curCount
				BP_UnknowPass_Confirm_Limit = v.maxCount
				
                UnknowPassExchangeConfirm.ShowUI(BP_UnknowPass_Confirm_Showtype.ALLIANCE_COMPETITION)
                
            else
                UnknowPassSystem:PopErrorMsg(502012)

            end 
            break
        end
    end
end