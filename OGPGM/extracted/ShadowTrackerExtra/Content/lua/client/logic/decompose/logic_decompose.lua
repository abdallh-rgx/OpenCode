--- Created by steveou.
---
---登陆时，批量拉取仓库中已有的物品的分解信息，在线期间有新增物品则拉取一次
--维护一个需要拉取分解信息的list，包括登录时背包已有的道具，以及新增道具，判断本地是否已有缓存分解信息，没有则记录下，然后统一在打开分解界面时判断请求（看外部是否需要，或改为有新增就拉取）
DecomposeSystem = DecomposeSystem or
{
    decomposeConfigMap = {},
    decomposeList = {}, --缓存的分解提示
    needDelay = false, --是否延迟弹出分解提示
}

function DecomposeSystem.Init()
    log("DecomposeSystem.Init", "decompose")
    EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_ADD_NEW, DecomposeSystem.OnDepotItemAdd);
    EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_DATA_INIT, DecomposeSystem.OnDepotItemInit);
end

function DecomposeSystem.CanShowGoldChip()
    --local strRegion = Client.GetPublishRegion();
    --if strRegion == "JAPAN" or strRegion == "KOREA" then
    --    return false;
    --end
    --return true;
    return false;
end

function DecomposeSystem.OnDepotItemInit(eventType, eventID)
    log("DecomposeSystem.OnDepotItemInit:" .. eventID, "decompose");
    --DecomposeSystem.ClearInfoCache();
    local needGetDecomposeInfoList = {};
    for _, v in pairs(DataMgr.arrayHallDepotItemInfo) do
        if DecomposeSystem.HasGetDecomposeInfo(v.resID) == false then
            table.insert(needGetDecomposeInfoList, v.resID);
        end
    end
    if #needGetDecomposeInfoList > 0 then
        DecomposeSystem.BatchGetListDecomposeInfo(needGetDecomposeInfoList);
    end
end

function DecomposeSystem.OnDepotItemAdd(eventType, eventID, vars)
    log("DecomposeSystem.OnDepotItemAdd:" .. eventID);

    if eventID == EVENTID_DATAMGR_HALL_DEPOT_ADD_NEW then
        --WardrobeUI.needShowRedPoint = true;
        --log_tree("vars", vars);
        local needGetDecomposeInfoList = {};
        local itemCfg = {};
        for k,v in pairs(vars) do
            itemCfg = Client.GetTableData("Item", v.res_id);
            if itemCfg then
                if v.isnew == 1 and DecomposeSystem.HasGetDecomposeInfo(v.res_id) == false then
                    table.insert(needGetDecomposeInfoList, v.res_id);
                end
            end
        end
        if #needGetDecomposeInfoList > 0 then
            DecomposeSystem.BatchGetListDecomposeInfo(needGetDecomposeInfoList);
        end
    end
end

function DecomposeSystem.HasGetDecomposeInfo(itemId)
    if DecomposeSystem.decomposeConfigMap[itemId] and DecomposeSystem.decomposeConfigMap[itemId].hasGet == true then
        return true;
    end
    return false;
end

function DecomposeSystem.GetItemDecomposeInfo(itemId)
    if DecomposeSystem.decomposeConfigMap[itemId] ~= nil then
        if DecomposeSystem.decomposeConfigMap[itemId].info ~= nil then
            return DecomposeSystem.decomposeConfigMap[itemId].info, true;
        elseif DecomposeSystem.decomposeConfigMap[itemId].hasGet then
            return nil, true;
        end
    end
    log("[otf]DecomposeSystem.GetItemDecomposeInfo nil-------------------");
    DecomposeSystem.BatchGetListDecomposeInfo({itemId});
    return nil, false;
end

function DecomposeSystem.BatchGetListDecomposeInfo(list)
    if #list > 0 then
        --log_tree("DecomposeSystem.BatchGetListDecomposeInfo list", list, "decompose");
        for i,v in ipairs(list) do
            if DecomposeSystem.decomposeConfigMap[v] == nil then
                DecomposeSystem.decomposeConfigMap[v] = {};
            end
            DecomposeSystem.decomposeConfigMap[v].hasGet = true;
        end
        NetUtil.SendPriorityPkg(false, "get_item_decompose_info_rsp", "get_item_decompose_info", list);
    end
end

-- 清空配置数据缓存
function DecomposeSystem.ClearInfoCache()
    log("DecomposeSystem.ClearInfoCache:", "decompose");
    DecomposeSystem.decomposeConfigMap = {};
end

--decomposeInfo:
--├─ new_max_count:
--├─ new_min_count:
--├─ new_dst_item_id:
--├─ min_count:
--├─ timing_item_ratio:
--├─ max_count:
--├─ dst_item_id:
--└─ timing_dst_item_id:
function DecomposeSystem.get_item_decompose_info_rsp(res, list)
    log("get_item_decompose_info_rsp res:"..tostring(res));
    if res == "ok" then
        if list then
            for k,v in pairs(list) do
                if DecomposeSystem.decomposeConfigMap[k] == nil then
                    DecomposeSystem.decomposeConfigMap[k] = {info = v, hasGet = true};
                else
                    DecomposeSystem.decomposeConfigMap[k].info = v;
                end
            end
        end
        CommonUseItemsUI.OnDecomposeCfgRsp();
        EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_ITEM_DECOMPOSE);
    elseif res ~= nil then
        ShowNotice(res);
    end
end

-- 分解配置变更时后台通知清空本地缓存
function DecomposeSystem.notify_item_decompose_table_changed(changeTime)
    log("DecomposeSystem.notify_item_decompose_table_changed")
    DecomposeSystem.ClearInfoCache();
end

-- 请求分解物品
function DecomposeSystem.SendDecomposeMsg(insID, count)
    log("DecomposeSystem.SendDecomposeMsg insID "..insID);
    --log("DecomposeSystem.SendDecomposeMsg count "..count);

    NetUtil.SendPriorityPkg(false, "on_item_decompose_rsp", "on_item_decompose", tonumber(insID), count, true);
end

-- 请求批量分解物品
function DecomposeSystem.SendBatchDecompose(decompose_items)
    log("DecomposeSystem.SendBatchDecompose");
    NetUtil.SendPriorityPkg(false, "on_batch_item_decompose_rsp", "on_batch_item_decompose_req", decompose_items);
end

-- 分解信息提示处理
function DecomposeSystem.item_decompose_notice(dropList)
    local fromItemCfg = Client.GetTableData("Item", dropList[1].from_id);
    local toItemCfg = Client.GetTableData("Item", dropList[1].res_id);
    local toCnt = tostring(dropList[1].count);
    if fromItemCfg ~= nil and toItemCfg ~= nil then
        local formatStr = Client.GetTableData("LocalizeRes", 6345).TextValue;

        formatStr = string.gsub(formatStr, "{0}", fromItemCfg.ItemName);
        formatStr = string.gsub(formatStr, "{1}", toCnt);
        formatStr = string.gsub(formatStr, "{2}", toItemCfg.ItemName);
        PopUpNoticeUI.ShowNewNotice(formatStr);
    end
end

function DecomposeSystem.delay_item_decompose_notice() --延迟弹出提示
    if DecomposeSystem.decomposeList and #DecomposeSystem.decomposeList > 0 then
        DecomposeSystem.item_decompose_notice(DecomposeSystem.decomposeList)
        DecomposeSystem.decomposeList = {}
    end
end

-- 分解结果回包
function DecomposeSystem.on_item_decompose_rsp(res, dropList)
    --log_tree("DecomposeSystem.on_item_decompose_rsp dropList", dropList);
    if res == "ok" or res == "ok-auto" then
        if dropList and #dropList > 0 then
            if res == "ok-auto" then--
                if DecomposeSystem.needDelay then
                    DecomposeSystem.decomposeList = dropList
                else
                    DecomposeSystem.item_decompose_notice(dropList)
                end
            else
                CommonItemGetUI:ShowPanel(dropList);
            end
            if WardrobeUI.isShowing then
                WardrobeUI.RefreshCurrentTab();
            end
        end
    elseif res ~= nil then
        ShowNotice(res);
    end
end

-- 批量分解回报
function DecomposeSystem.on_batch_item_decompose_rsp(res, item_list)
    log("DecomposeSystem.on_batch_item_decompose_rsp res="..tostring(res));
    if res == "ok" then
        log_tree("DecomposeSystem.on_batch_item_decompose_rsp item_list=", item_list);
        if item_list and #item_list > 0 then
            CommonItemGetUI:ShowPanel(item_list);
            --是否显示周年庆特殊界面
            for i, v in pairs(item_list) do
                if v.res_id and v.res_id == 1001 then
                    if v.count and v.count > 100 then
                        log("BP_Lobby_BgAnniversaryGetSwitch " ..tostring(BP_Lobby_BgAnniversaryGetSwitch))
                        if BP_Lobby_BgAnniversaryGetSwitch == true then
                            LuaClassObj.HandleUIMessageNoFetch(bp_common_item_get_panel, "HandleJumpToExchangeAnnual")
                        else
                            LuaClassObj.HandleUIMessageNoFetch(bp_common_item_get_panel, "HandleJumpToExchange");
                        end
                    end
                end
            end
            if WardrobeUI.isShowing then
                WardrobeUI.RefreshCurrentTab();
            end
        end

        ItemDecomposeUI.OnDecomposeOK();

    elseif res ~= nil then
        ShowNotice(res);
    end
end

s2c["get_item_decompose_info_rsp"] = DecomposeSystem.get_item_decompose_info_rsp;
s2c["on_item_decompose_rsp"] = DecomposeSystem.on_item_decompose_rsp;
s2c["on_batch_item_decompose_rsp"] = DecomposeSystem.on_batch_item_decompose_rsp;
s2c["notify_item_decompose_table_changed"] = DecomposeSystem.notify_item_decompose_table_changed;