OfficerTrainingSystem = OfficerTrainingSystem or {}

GetDataDelegate = nil

local function getTaskUIState(status)
	log("[HHF]getTaskUIState, status = " .. status);
	if status == 0 then
		return "PROGRESS"
	elseif status == 1 then
		return "DONE"
	end

	return "PROGRESS"
end


local function getAwardUIState(id, status)
	log("[HHF]getAwardUIState, id = " .. id .. ", status = " .. status);
	if status == 0 then
		if tostring(DataMgr.OfficerTrainingData.CurID) == tostring(id) then
			return "PROGRESS"
		else
			return "LOCK"
		end
	elseif status == 1 then
		return "DONE"
	elseif status == 2 then
		return "AWARDED"
	-- elseif status == 3 then
	-- 	return "LOCK"
	end

	return "PROGRESS"
end

function OfficerTrainingSystem.GetData(del)
	log("[HHF]OfficerTrainingSystem.GetData, Send friend_recall_get_activity_req");
	GetDataDelegate = del
    NetUtil.SendPriorityPkg(false, "friend_recall_get_activity_rsp", "friend_recall_get_activity_req");
end

function OfficerTrainingSystem.OnGetData(res, type, act)
	log("[HHF]OfficerTrainingSystem.OnGetData, received friend_recall_get_activity_rsp, res = " .. tostring(res) .. ", type = " .. tostring(type) .. ", act.num = " .. FuncUtil:CountTable(act));
	--log_tree("[HHFTEST]OfficerTrainingSystem.OnGetData, act = ", act, "[HHFTEST]");
	if res == "ok" then 
		DataMgr.UpdateOfficerTrainingData(act, type)
		OfficerTrainingSystem.UpdateUIData()
        if GetDataDelegate ~= nil then
        	GetDataDelegate()
		end
	else
		ShowNotice(res);
		-- DataMgr.ShowNoticeByString("获取宝箱失败")
	end
end

function OfficerTrainingSystem.UpdateUIData()
	log("[HHF]OfficerTrainingSystem.UpdateUIData");
	BP_ARRAY_OfficerTrainingInfos = {}
	BP_ARRAY_OfficerTrainingBoxInfos = {}
	local taskData = DataMgr.OfficerTrainingData.taskList
	for key, task in pairs(taskData) do 
		table.insert(BP_ARRAY_OfficerTrainingInfos,
		{
			id = key,
			progress = task.progress,
			sort = task.sort
		})
	end

	local boxData = DataMgr.OfficerTrainingData.awardList
	for key, box in pairs(boxData) do
		table.insert(BP_ARRAY_OfficerTrainingBoxInfos,
		{
			id = key,
			status = getAwardUIState(key, box.status),
			first = box.first,
			sort = box.sort,
		})
	end

	table.sort(BP_ARRAY_OfficerTrainingInfos, function(a, b)
        return a.sort < b.sort
        end)
	--log_tree("[HHFTEST]OfficerTrainingSystem.UpdateUIData, BP_ARRAY_OfficerTrainingInfos = ", act, "[HHFTEST]")

	table.sort(BP_ARRAY_OfficerTrainingBoxInfos, function(a, b)
        return a.sort < b.sort
        end)
	--log_tree("[HHFTEST]OfficerTrainingSystem.UpdateUIData, BP_ARRAY_OfficerTrainingBoxInfos = ", act, "[HHFTEST]")

	BP_CurrentOperateOfficerTrainingBoxId = DataMgr.OfficerTrainingData.CurID
end

function OfficerTrainingSystem.GetAwardReq(rewardId)
	log("[HHF]OfficerTrainingSystem.GetAwardReq, rewardId = " .. rewardId);
    NetUtil.SendPriorityPkg(false,"friend_recall_activity_award_rsp","friend_recall_activity_award_req", rewardId)
end

function OfficerTrainingSystem.OnGetAwardReq(res, actid, itemlist)
	log("[HHF]OfficerTrainingSystem.OnGetAwardReq received friend_recall_activity_award_rsp, res = " .. tostring(res) .. ", actid = " .. tostring(actid) .. ", itemlist.num = " .. FuncUtil.CountTable(itemlist));
	if res == "ok" then 
		-- DataMgr.ShowNoticeByString("获取宝箱成功")

		-- 客户端自动设置任务状态
		-- local rewardData = DataMgr.corpsActiveness.list[chest_id]
		-- if rewardData == nil then
		-- 	log("Error: reward data can't find ID :" .. chest_id)
		-- 	return
		-- end
        -- rewardData.status = 2

		OfficerTrainingUI.ActivenessGetAward(actid, itemlist)
        -- CorpsBaseUI.UpdateRedPoint()
	else
		ShowNotice(res);
		-- DataMgr.ShowNoticeByString("获取宝箱失败")
	end
end

function OfficerTrainingSystem.OnUpdateTaskData(act)
	log("[HHF]OfficerTrainingSystem.OnUpdateTaskData, received friend_recall_one_activity_notify, act = " .. tostring(act));
	--log_tree("[HHFTEST]OfficerTrainingSystem.OnUpdateTaskData, received friend_recall_one_activity_notify, act = ", act, "[HHFTEST]");
 	-- DataMgr.ShowNoticeByString("获取数据成功")

	DataMgr.UpdateOfficerTrainingTaskList(act)
	OfficerTrainingSystem.UpdateUIData()
end

function OfficerTrainingSystem.ClickedOpenDataUpload()	
    ClientSendBAReport(BP_BA_FRD_RECALL_ACT_CLICK, 0);
end

function OfficerTrainingSystem.ChangeTask()
	log("[HHF]OfficerTrainingSystem.ChangeTask, Send replace_frd_recall_sub_act_req");
    NetUtil.SendPriorityPkg(false, "replace_frd_recall_sub_act_rsp", "replace_frd_recall_sub_act_req")
end

function OfficerTrainingSystem.OnChangeTask(res, act_id, ext_info)
	log("[HHF]OfficerTrainingSystem.OnChangeTask, res = " .. tostring(res) .. ", act_id = " .. tostring(act_id) .. ", ext_info = " .. tostring(ext_info));
	--log_tree("[HHFTEST]OfficerTrainingSystem.OnChangeTask, ext_info = ", ext_info, "[HHFTEST]");
	local listIndex = 0
	if res == "ok" then 
		for index, data in ipairs(BP_ARRAY_OfficerTrainingInfos) do
			if data.id == ext_info.old_idx then
				listIndex = index
			end
		end
		log("[HHF]OfficerTrainingSystem.OnChangeTask, listIndex = " .. listIndex);
		DataMgr.ChangeOfficerTrainingTaskData(ext_info.old_idx, ext_info.new_idx, listIndex)
		OfficerTrainingSystem.UpdateUIData()
		OfficerTrainingUI.UpdateOneTask(listIndex)
	elseif res ~= nil then
		ShowNotice(res);
	end
end

s2c["friend_recall_activity_award_rsp"] = OfficerTrainingSystem.OnGetAwardReq;
s2c["friend_recall_get_activity_rsp"] = OfficerTrainingSystem.OnGetData;
s2c["friend_recall_one_activity_notify"] = OfficerTrainingSystem.OnUpdateTaskData;
s2c["replace_frd_recall_sub_act_rsp"] = OfficerTrainingSystem.OnChangeTask;