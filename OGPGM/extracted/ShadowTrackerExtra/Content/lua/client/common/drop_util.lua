local M = {}

local DatasGroupByDropID = nil

local function InitCache()
    collectgarbage("collect")
    local pre = collectgarbage("count")
    
    DatasGroupByDropID = {}
    local dropTable = Client.GetTable("Drop")
    for _,dropInfo in pairs(dropTable) do
        local dropID = dropInfo.DropID
        local dropIDTables = DatasGroupByDropID[dropID]
        if not dropIDTables then
            dropIDTables = {}
            DatasGroupByDropID[dropID] = dropIDTables
        end
        table.insert(dropIDTables, dropInfo)
    end
    
    collectgarbage("collect")
    local next = collectgarbage("count")
    print("drop_util memory:", next - pre)
end

function M.GetByDropID(dropID)
    if DatasGroupByDropID == nil then
        InitCache()
    end
    
    local datas = DatasGroupByDropID[dropID]
    if not datas then
        datas = {}
    end
    
    return datas
end

function M.ReleaseCache()
    DatasGroupByDropID = nil
    collectgarbage("collect")
     do
        local KismetSystemLibrary = import("KismetSystemLibrary")
        KismetSystemLibrary.CollectGarbage()
    end    
    collectgarbage("collect")
    log("Clear all lua property cache and function cache end");
end

--获得单个掉落方案id所有的物品信息（不去重）
function M.GetDropList(dropId)
    local result = {}
    --先读取掉落方案
    local drop_util = require("client.common.drop_util")
    local drops = drop_util.GetByDropID(dropId)
    
    for _,dropInfo in pairs(drops) do        
        --再去读掉落映射
        local dropMapping = Client.GetTableData("DropMapping", dropInfo.DropMappingID)
        if dropMapping ~= nil then
            local DropItemID
            if DataMgr.avatarData.gamegender == 2 then
                DropItemID = dropMapping.DropItemFemaleID
            else
                DropItemID = dropMapping.DropItemMaleID
            end
            local one = {}
            one.DropItemID = DropItemID
            one.DropItemNum = dropInfo.DropItemNum
            one.DropItemSort = dropInfo.DropItemSort
            one.DropItemTime = dropInfo.DropItemTime         
            one.Hours = dropMapping.DropItemTime
            one.Desc = dropInfo.Desc
            one.DropMoney = dropMapping.DropMoney
            --log_tree("################",dropMapping)
            table.insert(result, one)
        end
    end
    table.sort(result, function(a, b)
        return a.DropItemSort > b.DropItemSort
    end)
    return result
end

--获得多个掉落方案所有的物品信息（去重）
function M.GetDropsList(dropIds)
    local result = {}
    --先读取掉落方案
    local drop_util = require("client.common.drop_util")
    --log_tree(dropTable)
    for _,dropId in pairs(dropIds) do
        local drops = drop_util.GetByDropID(dropId)
        for _,dropInfo in pairs(drops) do
            --再去读掉落映射
            local dropMapping = Client.GetTableData("DropMapping", dropInfo.DropMappingID)
            if dropMapping ~= nil then
                local DropItemID
                if DataMgr.avatarData.gamegender == 2 then
                    DropItemID = dropMapping.DropItemFemaleID
                else
                    DropItemID = dropMapping.DropItemMaleID
                end
                local one = {}
                one.DropItemID = DropItemID
                one.DropItemNum = dropInfo.DropItemNum
                one.DropItemSort = dropInfo.DropItemSort
                one.DropItemTime = dropMapping.DropItemTime
                one.DropItemWeight = dropInfo.Weight
                --考虑重复
                local add = true
                for _,item in pairs(result) do
                    if one.DropItemID == item.DropItemID and one.DropItemNum == item.DropItemNum and one.DropItemTime == item.DropItemTime then
                        add = false
                        break
                    end
                end
                if add then
                    table.insert(result, one)
                end
            end
        end
    end
    table.sort(result, function(a, b)
        return a.DropItemSort > b.DropItemSort
    end)
    return result
end

--针对任务系统的卡顿问题,特此为之
--dropTable为掉落方案
function M.GetDropsListForTask(dropIds)
    local result = {}

    local drop_util = require("client.common.drop_util")
    for _,dropId in pairs(dropIds) do
        local drops = drop_util.GetByDropID(dropId)
        for _,dropInfo in pairs(drops) do
            --再去读掉落映射
            local dropMapping = Client.GetTableData("DropMapping", dropInfo.DropMappingID)             
            if dropMapping ~= nil then
                local DropItemID
                if DataMgr.avatarData.gamegender == 2 then
                    DropItemID = dropMapping.DropItemFemaleID
                else
                    DropItemID = dropMapping.DropItemMaleID
                end
                local one = {}
                one.DropItemID = DropItemID
                one.DropItemNum = dropInfo.DropItemNum
                one.DropItemSort = dropInfo.DropItemSort
                one.DropItemTime = dropMapping.DropItemTime
                one.DropItemWeight = dropInfo.Weight
                --考虑重复
                local add = true
                for _,item in pairs(result) do
                    if one.DropItemID == item.DropItemID and one.DropItemNum == item.DropItemNum and one.DropItemTime == item.DropItemTime then
                        add = false
                        break
                    end
                end
                if add then
                    table.insert(result, one)
                end
            end
        end
    end
    table.sort(result, function(a, b)
        return a.DropItemSort > b.DropItemSort
    end)
    return result
end

return M