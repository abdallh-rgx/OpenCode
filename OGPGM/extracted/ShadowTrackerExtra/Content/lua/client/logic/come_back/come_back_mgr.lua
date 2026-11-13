ComeBackMgr = ComeBackMgr or
{
    TaskType_Special = 1,
    TaskType_Regular = 2,

    TaskSubType_LoginGift = 1,
    TaskSubType_NotifyMyFriends = 2,
    TaskSubType_FirstGameGift = 3,

    TaskTable = {},
    TaskSubTypeTable = {},
}

function ComeBackMgr.InitTaskTable()
    log("ComeBackMgr.InitTaskTable")

    local taskTable = Client.GetTable(FuncUtil.GetWithRegion("RejoinTask", "RejoinTask_JK", "RejoinTask_JK"))
    -- log_tree("ComeBackMgr.InitTaskTable taskTable", taskTable)
    ComeBackMgr.TaskTable = {}
    ComeBackMgr.TaskSubTypeTable = {}
    for k,v in pairs(taskTable) do
        local typeMap = ComeBackMgr.TaskTable[v.Type]
        if typeMap == nil then
            typeMap = {}
            ComeBackMgr.TaskTable[v.Type] = typeMap
        end

        local group = typeMap[v.Group]
        if group == nil then
            group = {}
            typeMap[v.Group] = group;
        end

        table.insert(group, v);

        if v.SubType > 0 then
            local subTypeArray = ComeBackMgr.TaskSubTypeTable[v.SubType]
            if subTypeArray == nil then
                subTypeArray = {}
                ComeBackMgr.TaskSubTypeTable[v.SubType] = subTypeArray
            end
            table.insert(subTypeArray, v);
        end
    end

    -- log_tree("ComeBackMgr.InitTaskTable ComeBackMgr.TaskTable", ComeBackMgr.TaskTable)
    -- log_tree("ComeBackMgr.InitTaskTable ComeBackMgr.TaskSubTypeTable", ComeBackMgr.TaskSubTypeTable)
end

function ComeBackMgr.ResetData()
    -- DataMgr.RejoinTaskData.is_open = false;

    -- --测试数据
    -- local testData =
    -- {
    --     is_open = true,
    --     total_login_day = 3,
    --     last_login_time = 0,
    --     task_special =
    --     {
    --         list =
    --         {
    --             [1000001] = {progress=0, status=0},
    --             [1000002] = {progress=0, status=0},
    --             [1000003] = {progress=0, status=0},
    --         }
    --     },
    --     task_regular =
    --     {
    --         list =
    --         {
    --             [2010001] = {progress=0, status=0},
    --             [2010002] = {progress=0, status=1},
    --             [2010003] = {progress=0, status=0},
    --             [2010004] = {progress=0, status=0},
    --             [2010005] = {progress=0, status=0},
    --             [2020001] = {progress=0, status=0},
    --             [2020002] = {progress=0, status=0},
    --             [2020003] = {progress=0, status=0},
    --             [2020004] = {progress=0, status=0},
    --             [2020005] = {progress=0, status=0},
    --             [2030001] = {progress=0, status=0},
    --             [2030002] = {progress=0, status=0},
    --             [2030003] = {progress=0, status=0},
    --             [2030004] = {progress=0, status=0},
    --             [2030005] = {progress=0, status=0},
    --             [2040001] = {progress=0, status=0},
    --             [2040002] = {progress=0, status=0},
    --             [2040003] = {progress=0, status=0},
    --             [2040004] = {progress=0, status=0},
    --             [2040005] = {progress=0, status=0},
    --             [2050001] = {progress=0, status=0},
    --             [2050002] = {progress=0, status=0},
    --             [2050003] = {progress=0, status=0},
    --             [2050004] = {progress=0, status=0},
    --             [2050005] = {progress=0, status=0},
    --         }
    --     },
    --     activeness =
    --     {
    --         value = 100,
    --     },
    --     chest_award_list = {0, 0, 0},
    -- };

    -- ComeBackMgr.InitData(testData)
end

function ComeBackMgr.InitData(rejoinData)
    if rejoinData == nil or rejoinData.is_open == false then
        DataMgr.RejoinTaskData.is_open = false;
        EventSystem:postLobbyEvent(EVENTTYPE_TASK, EVENTID_DATAMGR_BACKFLOWTASK_CHANGE)
        return;
    end

    log("ComeBackMgr.InitData")
    -- log_tree("ComeBackMgr.InitData rejoinData", rejoinData);
    DataMgr.RejoinTaskData.is_open = rejoinData.is_open;
    DataMgr.RejoinTaskData.total_login_day = rejoinData.total_login_day or 1;
    DataMgr.RejoinTaskData.last_login_time = rejoinData.last_login_time or 0;
    DataMgr.RejoinTaskData.rejoin_start_time = rejoinData.rejoin_start_time or 0;
    DataMgr.RejoinTaskData.task_special = ComeBackMgr.TaskDataToMap(rejoinData.task_special)
    DataMgr.RejoinTaskData.task_regular = ComeBackMgr.TaskDataToMap(rejoinData.task_regular)
    DataMgr.RejoinTaskData.taskActiveness.value = rejoinData.activeness.value or 0;
    DataMgr.RejoinTaskData.taskActiveness.list = ComeBackMgr.InitTaskActivenessData(rejoinData.chest_award_list)

    DataMgr.RejoinTaskData.activeness = rejoinData.activeness or 0;
    DataMgr.RejoinTaskData.last_refresh_time = rejoinData.last_refresh_time or 0;
    DataMgr.RejoinTaskData.rejoin_num = rejoinData.rejoin_num or 0;
    DataMgr.RejoinTaskData.chest_award_list = rejoinData.chest_award_list or {};

    EventSystem:postLobbyEvent(EVENTTYPE_TASK, EVENTID_DATAMGR_BACKFLOWTASK_CHANGE)

end

function ComeBackMgr.UpdateData(rejoinData)
    if not rejoinData then
        return;
    end

    log("ComeBackMgr.UpdateData")
    -- log_tree("ComeBackMgr.InitData rejoinData", rejoinData);
    DataMgr.RejoinTaskData.is_open = rejoinData.is_open and rejoinData.is_open or DataMgr.RejoinTaskData.is_open;
    DataMgr.RejoinTaskData.total_login_day = rejoinData.total_login_day and rejoinData.total_login_day or DataMgr.RejoinTaskData.total_login_day;
    DataMgr.RejoinTaskData.last_login_time = rejoinData.last_login_time and rejoinData.last_login_time or DataMgr.RejoinTaskData.last_login_time;
    DataMgr.RejoinTaskData.rejoin_start_time = rejoinData.rejoin_start_time and rejoinData.rejoin_start_time or DataMgr.RejoinTaskData.rejoin_start_time;
    DataMgr.RejoinTaskData.taskActiveness.value = (rejoinData.activeness and rejoinData.activeness.value) and rejoinData.activeness.value or DataMgr.RejoinTaskData.taskActiveness.value;

    if rejoinData.task_special ~= nil then
        for k,v in pairs(rejoinData.task_special.list) do 
            if DataMgr.RejoinTaskData.task_special[k] ~= nil then 
                DataMgr.RejoinTaskData.task_special[k] = v
            end
        end
    end

    if rejoinData.task_regular ~= nil then
        for k,v in pairs(rejoinData.task_regular.list) do 
            if DataMgr.RejoinTaskData.task_regular[k] ~= nil then 
                DataMgr.RejoinTaskData.task_regular[k] = v
            end
        end
    end

    if rejoinData.chest_award_list ~= nil then
        for i=1,#rejoinData.chest_award_list,1 do 
            if DataMgr.RejoinTaskData.taskActiveness.list[i] ~= nil then
                DataMgr.RejoinTaskData.taskActiveness.list[i] = rejoinData.chest_award_list[i]
            end
        end
    end

    EventSystem:postLobbyEvent(EVENTTYPE_TASK, EVENTID_DATAMGR_BACKFLOWTASK_CHANGE)

end

function ComeBackMgr.InitTaskActivenessData(list)
    local newList = {}

    if list ~= nil then
        for i=1,#list,1 do
            log("ComeBackMgr.InitTaskActivenessData" .. list[i])
            newList[i] = {status = list[i]}
        end
    end

    return newList
end

function ComeBackMgr.TaskDataToMap(taskData)
    local result ={}
    if taskData and taskData.list then
        for k,v in pairs(taskData.list) do
            result[k] =
            {
                progress = v.progress or 0,
                status = v.status or 0,
            };
        end
    end
    return result;
end

function ComeBackMgr.SortByOrder(a, b)
    return a.Order < b.Order;
end

-- 获取任务数组
function ComeBackMgr.GetTaskArray(type, group)
    local typeMap = ComeBackMgr.TaskTable[type]
    if typeMap == nil then
        return {};
    end

    local arrayGroup = typeMap[group]
    return arrayGroup or {};
end

-- 获取已排序的数据
function ComeBackMgr.GetSortedTaskArray(type, group)
    local arrayGroup = ComeBackMgr.GetTaskArray(type, group)
    if arrayGroup ~= nil then
        table.sort(arrayGroup, ComeBackMgr.SortByOrder)
    end
    return arrayGroup;
end

-- 通过子类型获取任务
function ComeBackMgr.GetTaskBySubType(subType)
    local array = ComeBackMgr.TaskSubTypeTable[subType]
    if array == nil then
        array = {}
    end
    return array;
end

-- 获取子类型的第一个任务
function ComeBackMgr.GetFirstTaskBySubType(subType)
    local dataArray = ComeBackMgr.GetTaskBySubType(subType);
    if not dataArray or #dataArray == 0 then
        -- log("ComeBackMgr.GetFirstTaskBySubType 1")
        return nil;
    end

    return dataArray[1]
end

-- 通过任务id获取任务实例数据
function ComeBackMgr.GetTaskInsByTaskID(taskID)
    return DataMgr.RejoinTaskData.task_special[taskID];
end

-- 领取任务
function ComeBackMgr.rejoin_task_get_award_req(taskID)
    log("ComeBackMgr.rejoin_task_get_award_req taskID "..taskID)
    NetUtil.SendPriorityPkg(false, "rejoin_task_get_award_res", "rejoin_task_get_award_req", taskID)
end

function ComeBackMgr.rejoin_task_get_award_res(res, taskID, itemList)
    log("ComeBackMgr.rejoin_task_get_award_res res "..tostring(res))
    log("ComeBackMgr.rejoin_task_get_award_res taskID "..tostring(taskID))

    if res == "ok" then
        if itemList ~= nil and #itemList > 0 then
            CommonItemGetUI:ShowPanel(itemList);
        end

        if taskID ~= nil then

            local taskCfg = Client.GetTableData("RejoinTask", taskID);
            --log_tree("ComeBackMgr.rejoin_task_get_award_res id " , taskCfg)
            if taskCfg == nil then
                log("Error: task config can't find ID :" .. taskID)
                return;
            end

            -- log("ComeBackMgr.rejoin_task_get_award_res taskCfg", taskCfg)

            if taskCfg.Type == ComeBackMgr.TaskType_Special then
                -- 客户端自动设置任务状态
                ComeBackMgr.FinishSpecialTask(taskCfg)
            elseif taskCfg.Type == ComeBackMgr.TaskType_Regular then
                -- 客户端自动设置任务状态
                local taskData = DataMgr.RejoinTaskData.task_regular[taskID]
                if taskData == nil then
                    log("Error: task data can't find ID :" .. taskID)
                    return
                end
                taskData.status = 2
                TaskBackflowUI.TaskGetAward(taskID, itemList)
            end
        end
        if TaskUI.isShow then
            TaskUI.UpdateBackflowRedPoint();
        end
    elseif res ~= nil then
        ShowNotice(res)

        if taskID ~= nil then
            local taskCfg = Client.GetTableData("RejoinTask", taskID);
            if taskCfg ~= nil then
                ComeBackMgr.FinishSpecialTask(taskCfg)
            end
        end
    end
end

function ComeBackMgr.FinishSpecialTask(taskCfg)
    if taskCfg == nil then
        return
    end

    if taskCfg.Type == ComeBackMgr.TaskType_Special then
        -- 客户端自动设置任务状态
        local taskData = DataMgr.RejoinTaskData.task_special[taskCfg.ID]
        if taskData == nil then
            -- log_tree("ComeBackMgr.rejoin_task_get_award_res DataMgr.RejoinTaskData.task_special", DataMgr.RejoinTaskData.task_special)
            log("Error: task data can't find ID :" .. taskCfg.ID)
            return
        end
        taskData.status = 2
        ComeBackSystem.OnTaskFinished(taskCfg)
    end
end

-- 查询任务
function ComeBackMgr.rejoin_task_query_req(isWaitting)
    if isWaitting then
        NetUtil.SendPriorityPkg(false, "rejoin_task_notify", "rejoin_task_query_req")
    else
        NetUtil.SendPkg("rejoin_task_query_req")
    end
end

-- 通知任务转态变化
function ComeBackMgr.rejoin_task_notify(is_all, rejoin_task)
    -- log_tree("ComeBackMgr.rejoin_task_notify rejoin_task", rejoin_task)
    if is_all then
        log("ComeBackMgr.rejoin_task_notify is all")
        ComeBackMgr.InitData(rejoin_task)
    else
        log("ComeBackMgr.rejoin_task_notify is not all")
        ComeBackMgr.UpdateData(rejoin_task)
    end
end

function ComeBackMgr.rejoin_chest_get_award_req(chest_id)
    NetUtil.SendPriorityPkg(false, "rejoin_chest_get_award_res", "rejoin_chest_get_award_req", chest_id)
end

function ComeBackMgr.rejoin_chest_get_award_res(ret, chest_id, itemlist)
    if ret == NetErrorCode_NONE then
        -- 客户端自动设置任务状态
        local rewardData = DataMgr.RejoinTaskData.taskActiveness.list[chest_id]
        if rewardData == nil then
            log("Error: reward data can't find ID :" .. chest_id)
            return
        end
        rewardData.status = 1

        TaskBackflowUI.ActivenessGetAward(chest_id, itemlist)
    else
        ShowNotice(ret)
    end
end

s2c["rejoin_task_get_award_res"] = ComeBackMgr.rejoin_task_get_award_res
s2c["rejoin_task_notify"] = ComeBackMgr.rejoin_task_notify
s2c["rejoin_chest_get_award_res"] = ComeBackMgr.rejoin_chest_get_award_res