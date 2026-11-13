TaskSystem = TaskSystem or {}

TaskType = {
	["FIX"] = 1,
	["RANDOM"] = 2,
	["PLATFORM"] = 3
}

LevelTaskId = {
	[0] = "level_status",
	[1] = "task1_status",
	[2] = "task2_status"
}

function TaskSystem.Req_TaskGetAward(taskId)
	NetUtil.SendPkg("task_get_award_req", taskId)
end

function TaskSystem.Req_ReportTaskInfo(value)
	NetUtil.SendPkg("report_task_info", value)
end

function TaskSystem.Req_ActivenessGetAward(rewardId)
	if rewardId > DataMgr.activeness["WeekActIndexMark"] then  -- 周活跃任务
		NetUtil.SendPkg("activeness_get_week_req", rewardId)
	else 													   -- 日活跃任务
		NetUtil.SendPkg("activeness_get_award_req", rewardId)
	end
end

function TaskSystem.Res_TaskGetAward(res, taskId, itemList)
	if res == NetErrorCode_NONE then
		-- 客户端自动设置任务状态
		local taskData = DataMgr.taskData.list[taskId]
		if taskData == nil then
			log("Error: task data can't find ID :" .. taskId)
			return
		end
		taskData.status = 2

		TaskUI.TaskGetAward(taskId, itemList)
	else
		ShowNotice(res)
	end
end

function TaskSystem.Res_TaskGetAllAward(res, get_award)
	log_tree("TaskSystem.Res_TaskGetAllAward", get_award)
	if res == NetErrorCode_NONE then
		-- 客户端自动设置任务状态
		if get_award == nil or next(get_award) == nil then
			return
		end
		local taskid = 0
		local totalitemlist = {}
		for k, v in ipairs(get_award) do
			taskid = get_award[k].taskid
			local itemlist = get_award[k].itemlist

			for i, j in ipairs(itemlist) do
				local isAdd = false
				for index, val in pairs(totalitemlist) do
					log("^^^^"..totalitemlist[index].count)
					if totalitemlist[index].res_id == itemlist[i].res_id then
						totalitemlist[index].count = totalitemlist[index].count + itemlist[i].count
						isAdd = true;
						break
					end
				end
				if isAdd == false then
					table.insert(totalitemlist, itemlist[i])
				end
				log_tree("totalitemlist", totalitemlist)
			end
			local taskData = DataMgr.taskData.list[taskid]
			if taskData == nil then
				log("Error: task data can't find ID :" .. taskid)
				return
			end
			taskData.status = 2
		end
		CommonItemGetUI:ShowPanel(totalitemlist)
		TaskUI.TaskGetAllAward()
	else
		ShowNotice(res)
	end
end

function TaskSystem.Res_ActivenessGetAward(res, rewardId, itemList)
	if res == NetErrorCode_NONE then
		-- 客户端自动设置任务状态
		local rewardData = DataMgr.activeness.list[rewardId]
		rewardData = rewardData or DataMgr.activeness.week_list[rewardId]
		if rewardData == nil then
			log("Error: reward data can't find ID :" .. rewardId)
			return
		end
		rewardData.status = 1

		TaskUI.ActivenessGetAward(rewardId, itemList)
	else
		ShowNotice(res)
	end
end

--领取周奖励请求
function TaskSystem.Req_WeekTaskGetAward(taskid, recvIndex)
	log("[yyc] Req_WeekTaskGetAward taskid "..taskid.." index"..tostring(recvIndex))
	NetUtil.SendPkg("task_get_weekly_award_req", taskid, recvIndex)
end

--领取周奖励回包
function TaskSystem.Res_WeekTaskGetAward(res, taskid, stage_index, itemlist)
	log("[yyc] Res_WeekTaskGetAward taskid "..taskid.." res "..res)
	log_tree("[yyc] Res_WeekTaskGetAward itemlist", itemlist)
	log_tree("[yyc] Res_WeekTaskGetAward stage_index", stage_index)
	if res == 0 then
		local awardData = {}
		for _,v in pairs(itemlist) do
			table.insert(awardData, {res_id = v.res_id, count = v.count, valid_hours = v.valid_hours,})
		end
        CommonItemGetUI:ShowPanel(awardData)

        local taskData = DataMgr.weekTaskData.week_list[taskid]
        if taskData then
        	for stageIndex, _ in pairs(stage_index) do
        		if taskData.detail[stageIndex] then
        			taskData.detail[stageIndex].status = 2
        		else
        			log("[yyc] stage index is not valid "..stageIndex)
        		end
        	end
        else
        	log("[yyc] taskid is not valid "..tostring(taskid))
        end

        TaskUI.UpdateWeekTaskPanel()
    else
    	log("[yyc] Res_WeekTaskGetAward failed res = "..res)
	end
end

--成长任务请求
function TaskSystem.Req_LevelTaskGetAward(level, id)
	NetUtil.SendPkg("level_task_get_award_req", level, id)
end
--成长任务回复
function TaskSystem.Res_LevelTaskGetAward(ret, level, id, itemList)
	
	if ret == NetErrorCode_NONE then
		local taskInfo = DataMgr.levelTask.list[level]
		if taskInfo == nil then
			sandbox.LogError("level task can not found on level : " .. (level or -1))
			return
		end

		taskInfo[LevelTaskId[id]] = 2
		-- log_tree("================Res_LevelTaskGetAward", DataMgr.levelTask)
		TaskUI.LevelTaskGetAward(level, id, itemList)
	else
		ShowNotice(ret)
	end
end

-- add by hy 20180723
-- 一键领取成长任务奖励
function TaskSystem.Req_OnekeyLevelTaskGetAward()
	-- log("============Req_OnekeyLevelTaskGetAward")
	NetUtil.SendPkg("level_task_get_all_award_req")
end

-- 一键领取成长任务奖励回复
function TaskSystem.Res_OnekeyLevelTaskGetAward(ret, parama)
	-- log("============Res_OnekeyLevelTaskGetAward")
	if ret ~= NetErrorCode_NONE then
		ShowNotice(ret)
		return
	end

	local result = {}
	for i,v in ipairs(parama) do
		local level = v[1]
		local id = v[2]
		
		local taskInfo = DataMgr.levelTask.list[level]
		if taskInfo == nil then
			sandbox.LogError("level task can not found on level : " .. (level or -1))
			return
		end

		taskInfo[LevelTaskId[id]] = 2

		table.insert(result, v[3])
	end

	-- log_tree("Res_OnekeyLevelTaskGetAward",result)
	TaskUI.OnekeyLevelTaskGetAward(result)
end

s2c["level_task_get_all_award_res"] = TaskSystem.Res_OnekeyLevelTaskGetAward
-- =======================


s2c["task_get_award_res"] = TaskSystem.Res_TaskGetAward
s2c["activeness_get_award_res"] = TaskSystem.Res_ActivenessGetAward
s2c["activeness_get_week_res"] = TaskSystem.Res_ActivenessGetAward
s2c["level_task_get_award_res"] = TaskSystem.Res_LevelTaskGetAward
s2c["task_get_weekly_award_rsp"] = TaskSystem.Res_WeekTaskGetAward
s2c["task_get_all_award_res"] = TaskSystem.Res_TaskGetAllAward

