--[[
 师徒任务相关逻辑
]]--

MasterTaskSystem = MasterTaskSystem or
{

  -- currentTask,
  -- currentTaskConfig,
  currentTaskId = 0,
}



--是否有师徒任务
function MasterTaskSystem.HasTask()
    if (MasterTaskSystem.currentTaskId == 0 or MasterTaskSystem.currentTask == nil or MasterTaskSystem.currentTaskConfig == nil) then
        return false;
    end

    if (MasterTaskSystem.currentTask.status == 2) then --状态 0 未完成 1 未领取 2 已领取
        return false;
    end
    
    return true;
end

--是否有师父任务
function MasterTaskSystem.HasMasterTask()
   local hasTask = MasterTaskSystem.HasTask();
   
   if (hasTask == false) then
      return false;
   end

   return MasterTaskSystem.currentTaskConfig.TaskType == 2;
end

--是否有徒弟任务
function MasterTaskSystem.HasDiscipleTask()
   local hasTask = MasterTaskSystem.HasTask();
   
   if (hasTask == false) then
      return false;
   end

   return MasterTaskSystem.currentTaskConfig.TaskType == 1;
end

--拉取任务信息
function MasterTaskSystem.get_master_task_req()
  log("get_master_task_req");
  NetUtil.SendPkg("get_master_task_req");
end

-- 任务领奖
function MasterTaskSystem.master_task_award_req(task_id)
  log("master_task_award_req, task_id = " .. task_id);
  NetUtil.SendPkg("master_task_award_req", task_id);
end

--[[
-- res:  "ok"表示成功，其他为错误码
-- task: 任务信息, table        
        10001
        ├─award
        │ ├─ 1── --子任务1
        │ |   └─ num: 1
        │ │   └─ status: 1
        | |   └─ type: 3
        │ ├─ 2──  
        | │   └─ num: 1
        │ │   └─ status: 1
        | |   └─ type: 3
        │ └─ 3──  
        │     └─ num: 1      当前计数
        │     └─ status: 0   0 未完成  1完成
        |     └─ type: 3
        └─status:1   --状态 0 未完成 1 未领取 2 已领取

]]
--拉取任务信息
function MasterTaskSystem.get_master_task_rsp(res, task)
  log("get_master_task_rsp, res = " .. tostring(res));
  if (res == "ok") then
    --log_tree("task", task);
    MasterTaskSystem.SetCUrrentTask(task);
  else
    MasterSystem.ProtocolErroCode("master_errcode_" .. tostring(res));
  end
end

function MasterTaskSystem.SetCUrrentTask(task)
  MasterTaskSystem.currentTask = task;
  MasterTaskSystem.currentTaskId = 0;

  for k, v in pairs(task) do
    if (type(k) == "number") then
        log("k = " .. tostring(k));
        MasterTaskSystem.currentTaskId = k;
        MasterTaskSystem.currentTask = v;
        log("MasterTaskSystem.currentTaskId = " .. tostring(MasterTaskSystem.currentTaskId));
        MasterTaskSystem.currentTaskConfig = MasterTaskSystem.GetMasterTaskConfig(MasterTaskSystem.currentTaskId);
        if (MasterTaskSystem.currentTask.status == 1) then
            MasterSystem.ClientSetRedPoint(true, 1);
        elseif (MasterTaskSystem.currentTask.status == 2) then
          if (MasterTaskSystem.currentTaskConfig ~= nil and MasterTaskSystem.currentTaskConfig.BackTaskID == 0) then
            log("all task finish");
            MasterTaskSystem.currentTaskId = 0;                 
          end
          MasterSystem.ClientSetRedPoint(false, 1);
        end
    end
  end
  
  MasterTaskUI.SetCUrrentTask();
  MasterTaskUI.UpdateTask();
end

--[[
    参数：res : "ok" 表示成功，其它值为错误码
          task_id:  任务id
          finish: 0 忽略  1 完成所有徒弟任务  2 完成所有师父任务          
          itemlist: 奖励
            └─ 1
            │  ├─ valid_hours: 0
            │  ├─ count: 1
            │  ├─ expire_ts: 0
            │  └─ res_id: 404003
            │─ 2
            │  ├─ valid_hours: 0
            │  ├─ count: 1
            │  ├─ expire_ts: 0
            │  └─ res_id: 404003
    领完任务奖励后刷新任务，任务的子任务状态变化都会调用 s2c.get_master_task_rsp(res, task)   
]]

function MasterTaskSystem.master_task_award_rsp(res, task_id, finish, itemlist)
  log("master_task_award_rsp, res = " .. tostring(res) .. ", task_id = " .. tostring(task_id) .. ", finish = " .. tostring(finish));
  --log_tree("itemlist", itemlist);
  
  if (res == "ok") then
    if (#itemlist > 0) then
         local function funcGoodItem()
            if (finish ~= nil and finish ~= 0) then
                MasterFinishUI.Show(finish);
                MasterFinishUI.UpdateFinishTask();
            end
        end
        CommonItemGetUI:ShowPanelWithCallback(itemlist,funcGoodItem,true);
    end
    MasterSystem.ClientSetRedPoint(false, 1);
  else
    MasterSystem.ProtocolErroCode("master_errcode_" .. tostring(res));
  end

end

--读取本地化表的文字
function MasterTaskSystem.GetMasterTaskConfig(taskId)
  log("GetMasterTaskConfig taskId = " .. taskId);
  return Client.GetTableData("MasterTaskConfig", tonumber(taskId));
end

function MasterTaskSystem.TestTaskData()
  local task = {};
  local taskInfo = {};
  local award = {};
  table.insert(award, {num = 0, status = 0});
  table.insert(award, {num = 0, status = 0});
  table.insert(award, {num = 0, status = 0});
  taskInfo.award = award;
  taskInfo.status = 0;

  task[100001] = taskInfo;
  MasterTaskSystem.get_master_task_rsp("ok", task);
end

--协议
s2c["get_master_task_rsp"] = MasterTaskSystem.get_master_task_rsp; --拉取任务信息
s2c["master_task_award_rsp"] = MasterTaskSystem.master_task_award_rsp; --拉取任务信息
