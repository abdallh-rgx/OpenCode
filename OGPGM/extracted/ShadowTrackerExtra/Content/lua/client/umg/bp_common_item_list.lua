CommonItemListUI = CommonItemListUI or
{
    isShow = true,
    onItemUsed = nil,
}

BP_STRUCT_CommonItemListInfo =
{
    ins_id = "",
    res_id = 0,
    itemType = 0,
    count = 0,
    is_selected = false,
    expireTS = 0,
};

BP_ARRAY_CommonItemListData = {BP_STRUCT_CommonItemListInfo = _G.BP_STRUCT_CommonItemListInfo}

BP_CommonItemList_SignleIndex = 0;
BP_CommonItemList_SelectedIndex = 0;
BP_CommonItemList_TitleString = "";

function bp_common_item_list_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_common_item_list,
        {{Path="/Game/UMG/UI_Logic/Common/Common_Item_List_BP.Common_Item_List_BP_C", Container="Default", ZOrder=BP_ENUM_UI_COMMON_ITEM_LIST_ZORDER}},
        {"Lobby"},
        false,
        false,
        true
    );
end

function CommonItemListUI.Init()
    EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_DATA_CHANGE, CommonItemListUI.UpdateAllItems)
    EventSystem:registEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_ITEM_USED, CommonItemListUI.OnItemUsed)
end

function CommonItemListUI.Release()
    EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_DATA_CHANGE, CommonItemListUI.UpdateAllItems)
    EventSystem:unregistEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_ITEM_USED, CommonItemListUI.OnItemUsed)
end

function CommonItemListUI.OnItemUsed(type, eid, args)
    if not CommonItemListUI.isShow then
        return;
    end

    if CommonItemListUI.onItemUsed then
        CommonItemListUI.onItemUsed(args);
    end
end

function CommonItemListUI.SetItemData(output, itemInfo)
    output.ins_id = itemInfo.insID;
    output.res_id = itemInfo.resID;
    output.itemType = itemInfo.itemType;
    output.count = itemInfo.count;
    output.is_selected = output.is_selected or false;
    output.expireTS = itemInfo.expireTS;
end

-- 根据类型显示
-- CommonItemListUI.ShowByTypeList(LocalizeResID or "title", {15, 21})
function CommonItemListUI.ShowByTypeList(title, typeList, onItemUsedCB)
    CommonItemListUI.ShowByCondition(title,
        function(x)
            return FuncUtil.Find(typeList, x.itemType) >= 0;
        end,
		onItemUsedCB);
end

-- 根据子类型显示
-- CommonItemListUI.ShowBySubTypeList(LocalizeResID or "title", {2103, 2104})
function CommonItemListUI.ShowBySubTypeList(title, subTypeList, onItemUsedCB)
    CommonItemListUI.ShowByCondition(title,
        function(x)
            return FuncUtil.Find(subTypeList, x.itemSubType) >= 0;
        end,
		onItemUsedCB);
end

function CommonItemListUI.ShowByCondition(title, condition, onItemUsedCB)
    if type(title) == "number" then
        BP_CommonItemList_TitleString = FuncUtil.GetLocalizeResStr(title);
    elseif type(title) == "string" then
        BP_CommonItemList_TitleString = title;
    end

    BP_CommonItemList_SelectedIndex = 1;
    CommonItemListUI.isShow = true;
    CommonItemListUI.Init()
    LuaClassObj.HandleDynamicCreation(bp_common_item_list);

    UIManager.Show(eUIType.eCommonItemListUI)
    BP_ARRAY_CommonItemListData = {}

    for i,v in pairs(DataMgr.arrayHallDepotItemInfo) do
        if condition(v) and DataMgr.IsValidTime(v.expireTS) then
            local item = {}
            CommonItemListUI.SetItemData(item, v);
            table.insert(BP_ARRAY_CommonItemListData, item);
            item.is_selected = BP_CommonItemList_SelectedIndex == #BP_ARRAY_CommonItemListData
        end
    end
    -- log_tree("CommonItemListUI.ShowByCondition BP_ARRAY_CommonItemListData", BP_ARRAY_CommonItemListData);
    CommonItemListUI.onItemUsed = onItemUsedCB;

    LuaClassObj.HandleUIMessage(bp_common_item_list, "ShowUI");
end

function CommonItemListUI.UpdateItemData(itemData)
    if not CommonItemListUI.isShow then
        return;
    end

    -- 更新Item数据
    for i,v in ipairs(BP_ARRAY_CommonItemListData) do
        if v.ins_id == itemData.ins_id then
            if itemData.count == 0 then
                table.remove(BP_ARRAY_CommonItemListData, i);
                LuaClassObj.HandleUIMessage(bp_common_item_list, "UpdateItems");
                break;
            else
                CommonItemListUI.SetItemData(v, itemData);
                CommonItemListUI.RefreshItem(i);
                break;
            end
        end
    end
end

function CommonItemListUI.RefreshItem(index)
    BP_CommonItemList_SignleIndex = index;
    LuaClassObj.HandleUIMessage(bp_common_item_list, "UpdateSingleItem");
end

function CommonItemListUI.Hide()
    UIManager.Hide(eUIType.eCommonItemListUI)
    CommonItemListUI.isShow = false;
    BP_CommonItemList_SelectedIndex = 0;
    LuaClassObj.HandleUIMessage(bp_common_item_list, "HideUI");
    CommonItemListUI.Release()
end

function EventCommonItemListClickClose()
    CommonItemListUI.Hide();
end

function EventCommonItemListOnClickItem()
    -- log("EventCommonItemListOnClickItem BP_CommonItemList_SelectedIndex "..BP_CommonItemList_SelectedIndex)
    local uiData = BP_ARRAY_CommonItemListData[BP_CommonItemList_SelectedIndex];
    -- log_tree("EventCommonItemListOnClickItem uiData", uiData)
    if uiData ~= nil then
        uiData.is_selected = true;
        CommonItemListUI.RefreshItem(BP_CommonItemList_SelectedIndex)
        for i,v in ipairs(BP_ARRAY_CommonItemListData) do
            if i ~= BP_CommonItemList_SelectedIndex and v.is_selected == true then
                v.is_selected = false;
                CommonItemListUI.RefreshItem(i)
            end
        end
    end
end

function CommonItemListUI.UpdateAllItems()
    if not CommonItemListUI.isShow then
        return;
    end

    for i=#BP_ARRAY_CommonItemListData,1,-1 do
        local uiData = BP_ARRAY_CommonItemListData[i];
        local itemData = DataMgr.GetHallDepotItemDataByInsID(uiData.ins_id);
        if itemData and itemData.count > 0 then
            CommonItemListUI.SetItemData(uiData, itemData);
        else
            table.remove(BP_ARRAY_CommonItemListData, i);
        end
    end

    LuaClassObj.HandleUIMessage(bp_common_item_list, "UpdateItems");
end