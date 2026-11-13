--[[
    仓库使用、仓库分解、军团商店购买二次操作框
--]]
CommonUseItemsUI = CommonUseItemsUI or {}

-- 对话框类型
BP_Common_Use_Items_DlgType = 1;

-- ID
BP_Common_Use_Items_resID = 0;

-- 使用数量
BP_Common_Use_Items_UseCount = 0;

-- 名字
BP_Common_Use_Items_Name = "";

-- 总数
BP_Common_Use_Items_Amount = 0;

-- 描述
BP_Common_Use_Items_Desc = "";

-- 掉落
BP_Common_Use_Items_DropItem_ID = 0;
BP_Common_Use_Items_DropCount = "";

BP_Common_Buy_Items_CostItemId = 0;
BP_Common_Buy_Items_Cost = 0;

BP_Common_HasLimitTime = false;

BP_Common_Buy_Items_CorpPosition = 0;
BP_Common_Buy_Items_CorpPositionName = "";   -- 职位要求:{n}
BP_Common_Buy_Items_TimeCD = "";
BP_Common_Buy_Items_CdNumByDay = 0;


CommonUseItemsUI.operationCallbackFunc = nil;

-- 长描述tipsID
BP_Common_Use_Items_LongDescID = 0;

function bp_common_use_items_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_common_use_items,
        {{Path = "/Game/UMG/UI_Logic/Common/Common_Use_Items_BP.Common_Use_Items_BP_c", Container = "Default", ZOrder = BP_ENUM_UI_COMMON_USEITEMS}},
        {"Lobby"},
        false,
        false,
        true);
end

-- 点击确定
function EventCommonUseItemsOnOkClick()
    if CommonUseItemsUI.operationCallbackFunc then
        CommonUseItemsUI.operationCallbackFunc(BP_Common_Use_Items_UseCount);
        CommonUseItemsUI.operationCallbackFunc = nil;
        return;
    end
    if BP_Common_Use_Items_DlgType == 1 then
        WardrobeSystem.wardrobe_use_item_req(BP_GLOBAL_USE_ITEM, BP_Common_Use_Items_UseCount);
    elseif BP_Common_Use_Items_DlgType == 2 then
        DecomposeSystem.SendDecomposeMsg(BP_GLOBAL_USE_ITEM, BP_Common_Use_Items_UseCount);
    elseif BP_Common_Use_Items_DlgType == 3 then
        CorpsShopSystem.BuyShopItemReq(BP_Common_Use_Items_UseCount);
    end
end

-- 点击设置个数
function EventCommonUpdateUseCount()
    CommonUseItemsUI.UpdateUseCount(true, BP_Common_Use_Items_UseCount);
end

function CommonUseItemsUI.ShowUseItem(itemData, itemCfg)
    CommonUseItemsUI.DoShowUI(1, itemData.count, itemCfg);
    BP_Common_Use_Items_Desc = itemCfg.ItemDesc;
    -- log_tree("CommonUseItemsUI.ShowUseItem itemCfg", itemCfg)
    CommonUseItemsUI.RefreshUI();
end

local decomposeRspCallBack = nil;
function CommonUseItemsUI.OnDecomposeCfgRsp()
    if decomposeRspCallBack then
        decomposeRspCallBack();
        decomposeRspCallBack = nil;
    end
end

function CommonUseItemsUI.ShowDecomposeItem(itemCfg, itemCount, bIsLimitTimeItem)
    local itemDecomposeCfg = DecomposeSystem.GetItemDecomposeInfo(itemCfg.ItemID);--Client.GetTableData("ItemDecompose", itemCfg.ItemID);
    if not itemDecomposeCfg then
        decomposeRspCallBack = 
            function()
                CommonUseItemsUI.ShowDecomposeItem(itemCfg, itemCount, bIsLimitTimeItem);
            end;
        return;
    end

    CommonUseItemsUI.DoShowUI(2, itemCount, itemCfg);
    
    if bIsLimitTimeItem then
        BP_Common_Use_Items_DropItem_ID = itemDecomposeCfg.timing_dst_item_id
    else
        BP_Common_Use_Items_DropItem_ID = itemDecomposeCfg.new_dst_item_id;
    end

    if BP_Common_Use_Items_DropItem_ID == 0 then
        BP_Common_Use_Items_DropItem_ID = itemDecomposeCfg.dst_item_id;
    end

    CommonUseItemsUI.UpdateUseCount(false, 1);
    CommonUseItemsUI.RefreshUI()
end

function CommonUseItemsUI.ShowBuyCorpsShopItem(costItemId, costNum, maxCount , itemCfg, func, corpPosition_limit, time_cd, limit_buy_cd_num_by_day)
    log("CommonUseItemsUI.ShowBuyCorpsShopItem");
    BP_Common_Buy_Items_CostItemId = costItemId or 1000;
    BP_Common_Buy_Items_Cost = costNum or 0;
    CommonUseItemsUI.operationCallbackFunc = func;
    BP_Common_Use_Items_DropItem_ID = itemCfg.ItemID;
    BP_Common_Buy_Items_CorpPosition = corpPosition_limit;
   
    local positionId = 410008;     -- 团员
    if corpPosition_limit == 1 then
        positionId = 410005;        -- 团长
    elseif corpPosition_limit == 2 then
        positionId = 410006;        -- 副团长
    elseif corpPosition_limit == 3 then
        positionId = 410007;        -- 精英
    end
    
    local positionName = FuncUtil.GetLocalizeResStr(positionId);
    BP_Common_Buy_Items_CorpPositionName = FuncUtil.LocalizeResFormat(6435, positionName);  -- 职位要求:{0}
    
    BP_Common_Buy_Items_TimeCD = FuncUtil.TimeFormatExtNoZero(time_cd);
    BP_Common_Buy_Items_CdNumByDay = limit_buy_cd_num_by_day;
    CommonUseItemsUI.DoShowUI(3, maxCount, itemCfg);
    CommonUseItemsUI.UpdateUseCount(false, 1);
    CommonUseItemsUI.RefreshUI();
end

--计算剩余小时数
function CommonUseItemsUI.GetRemainTimeHours(expireTS)
    local remainTime = expireTS - FuncUtil.GetServerTimeInSec();

    if remainTime <= 0 then
        remainTime = 1;
    end

    local hour = math.ceil(remainTime * WardrobeUI.secToHour);

    return hour;
end

--计算限时物品分解得到的金币数
function CommonUseItemsUI.CalcuTimeLimitItemCost(itemDecomposeCfg, count, itemData)
    if itemDecomposeCfg == nil then
        return;
    end

    if itemData == nil then
        return;
    end

    local remainTime = CommonUseItemsUI.GetRemainTimeHours(itemData.expireTS);
    --if remainTime > 999 * 24 then
    --    remainTime = 999 * 24;
    --end

    if itemDecomposeCfg.timing_item_ratio ~= nil then
        BP_Common_Use_Items_DropCount = string.format("%d", math.ceil((itemDecomposeCfg.timing_item_ratio / 1000) * count * remainTime));  
    end
end

--计算非限时物品分解得到的服饰币数
function CommonUseItemsUI.CalcuNormalItemCost(itemDecomposeCfg, count, itemData)
    if itemDecomposeCfg == nil then
        return;
    end
    -- 当前版本中MinCount和MaxCount是一致的，按照@akamongcui(崔冠成)的需求，先改成固定数量的显示
    -- http://tapd.oa.com/iGameInternational/bugtrace/bugs/view?bug_id=1020360302063976961
    if itemDecomposeCfg.new_dst_item_id ~= 0 then
        --if itemDecomposeCfg.NewMinCount == itemDecomposeCfg.NewMaxCount then
        BP_Common_Use_Items_DropCount = string.format("%d", itemDecomposeCfg.new_max_count*count);
        -- else
        --     BP_Common_Use_Items_DropCount = string.format("%d ~ %d", itemDecomposeCfg.new_min_count*count, itemDecomposeCfg.new_max_count*count);
        -- end
    else
        --if itemDecomposeCfg.MinCount == itemDecomposeCfg.max_count then
        BP_Common_Use_Items_DropCount = string.format("%d", itemDecomposeCfg.max_count*count);
        -- else
        --     BP_Common_Use_Items_DropCount = string.format("%d ~ %d", itemDecomposeCfg.min_count*count, itemDecomposeCfg.max_count*count);
        -- end
    end
end

function CommonUseItemsUI.UpdateUseCount(refreshUI, count)
    if BP_Common_Use_Items_DlgType == 2 then
        local itemDecomposeCfg = DecomposeSystem.GetItemDecomposeInfo(BP_Common_Use_Items_resID);--Client.GetTableData("ItemDecompose", BP_Common_Use_Items_resID);

        if not itemDecomposeCfg then
            decomposeRspCallBack = 
                function()
                    CommonUseItemsUI.UpdateUseCount(refreshUI, count);
                end
            return;
        end

        --[[
        -- 当前版本中MinCount和MaxCount是一致的，按照@akamongcui(崔冠成)的需求，先改成固定数量的显示
        -- http://tapd.oa.com/iGameInternational/bugtrace/bugs/view?bug_id=1020360302063976961
        local temp = itemDecomposeCfg.MaxCount*count
        BP_Common_Use_Items_DropCount = tostring(temp);
        -- BP_Common_Use_Items_DropCount = string.format("%d ~ %d", itemDecomposeCfg.MinCount*count, itemDecomposeCfg.MaxCount*count);
        ]]

        if BP_STRUCT_WardrobeClickedItemData == nil then
            return;
        end

        local itemData = DataMgr.GetHallDepotItemDataByInsID(BP_STRUCT_WardrobeClickedItemData.ins_id);

        if not itemData then
            return;
        end

        if itemData.expireTS > 0 then
            CommonUseItemsUI.CalcuTimeLimitItemCost(itemDecomposeCfg, count, itemData);
        else
            CommonUseItemsUI.CalcuNormalItemCost(itemDecomposeCfg, count, itemData);
        end

        if refreshUI then
            LuaClassObj.HandleUIMessage(bp_common_use_items, "UpdateDropCount");
        end
    elseif BP_Common_Use_Items_DlgType == 3 then
        BP_Common_Use_Items_DropCount = tostring(BP_Common_Buy_Items_Cost * count);
        if refreshUI then
            LuaClassObj.HandleUIMessage(bp_common_use_items, "UpdateDropCount");
        end
    end
end

--[[
    dlgType：类型; 1-使用；2-分解；3-购买
    count；数量
    itemCfg：item配置
--]]
function CommonUseItemsUI.DoShowUI(dlgType, count, itemCfg)
    log("CommonUseItemsUI.DoShowUI");
    LuaClassObj.HandleDynamicCreation(bp_common_use_items);

    BP_Common_Use_Items_LongDescID = itemCfg.LongDescID;

    BP_Common_Use_Items_DlgType = dlgType;
    BP_Common_Use_Items_resID = itemCfg.ItemID;
    BP_Common_Use_Items_Name = string.format(itemCfg.ItemName, BP_STRUCT_CorpsSummary.str_name) ;
    BP_Common_Use_Items_Amount = count;
    
    if BP_Common_Use_Items_DlgType == 2 then
        local itemData = DataMgr.GetHallDepotItemDataByInsID(BP_STRUCT_WardrobeClickedItemData.ins_id);
        if itemData then
            if itemData.expireTS > 0 then
                BP_Common_Use_Items_Name = itemCfg.ItemName..ItemDecomposeUI.GetRemainTimeDays(itemData.expireTS);
                BP_Common_HasLimitTime = true;
            else
                BP_Common_Use_Items_Name = itemCfg.ItemName;
                BP_Common_HasLimitTime = false;
            end
        end
    end
end

function CommonUseItemsUI.RefreshUI()
    LuaClassObj.HandleUIMessage(bp_common_use_items, "UIShow");
    UIManager.Show(eUIType.eCommonUseItemsUI);
end

--超出最大上限
function EventCommonUseItemBeyondMax()
    --[[
    if BP_Common_Use_Items_DlgType == 3 then
        ShowNotice(421010);
    end
    ]]
end


function EventCommonUseItem_Close()
    UIManager.Hide(eUIType.eCommonUseItemsUI);
end

