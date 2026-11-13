--鸡友回归任务
TaskBackflowUI = TaskBackflowUI or 
{
	isShow = false;
	ShowBlock = false;
}

BP_TaskBackflowActiveNum = 0


BP_TaskBackflowHasRedPoint = false

BP_STRUCT_TaskBackflowDropItem = 
{
	DropItemID =0,
	DropItemNum  =0,
	DropItemSort = 0
}

BP_ARRAY_TaskBackflowCurrDropList = 
{
	BP_STRUCT_TaskBackflowDropItem = BP_STRUCT_TaskBackflowDropItem
}

BP_STRUCT_TaskBackflowData = 
{
	id =0,
	status = "",
	progress = 0,
	BP_ARRAY_TaskBackflowCurrDropList = BP_ARRAY_TaskBackflowCurrDropList
}

BP_STRUCT_TaskBackflowCategory = 
{
	reddot = false,
	BP_ARRAY_TaskBackflow = 
	{
		BP_STRUCT_TaskBackflowData = BP_STRUCT_TaskBackflowData
	},

	--当当天任务尚未开启时的变量
	isOpen = false,
	title = "",
	BP_ARRAY_TaskDayAwardList = 
	{
		BP_STRUCT_TaskBackflowDropItem = BP_STRUCT_TaskBackflowDropItem
	},
}

BP_ARRAY_TaskBackflowInfos = 
{
	BP_STRUCT_TaskBackflowCategory = BP_STRUCT_TaskBackflowCategory
}

BP_STRUCT_TaskBackflowActiveAwardInfo = 
{
	id =0,
	tableID =0,
	value = 0,
	status = ""
}

BP_ARRAY_TaskBackflowActiveAwardInfos = 
{
	BP_STRUCT_TaskBackflowActiveAwardInfo = BP_STRUCT_TaskBackflowActiveAwardInfo
}

-- 用于同步lua参数
BP_TaskBackflowCurrentOperateTaskId = 0
BP_TaskBackflowCurrentOperateAwardId = 0


BP_STRUCT_TaskBackflowActiveAwardItem = {
	BP_ARRAY_TaskBackflowFixItemList = {
		BP_STRUCT_TaskBackflowDropItem = BP_STRUCT_TaskBackflowDropItem
	},
	BP_ARRAY_TaskBackflowRandomItemList = {
		BP_STRUCT_TaskBackflowDropItem = BP_STRUCT_TaskBackflowDropItem
	}
}


BP_TaskBackflowCurrentCategoryID = 0

local UIState = {
	["PROGRESS"] = "PROGRESS",
	["DONE"] = "DONE",
	["AWARDED"] = "AWARDED",
}
local TaskState = {
	["PROGRESS"] = 0,
	["DONE"] = 1,
	["AWARDED"] = 2
}
local AwardState = {
	["UNDONE"] = 0,
	["DONE"] = 1
}

--注册Widget
function bp_task_backflow_RegisterUI()
  	LuaClassObj.SubUIWidgetList(bp_task_backflow,
    {{Path="/Game/UMG/UI_Logic/Task/TaskBackflow_BP.TaskBackflow_BP_C", Container="Default", ZOrder=BP_ENUM_UI_TASK_ZORDER + 1}},
    {"Lobby"},
	false,
	false,
	true
  	);

	BP_ARRAY_TaskBackflowCurrDropList = {}
	BP_ARRAY_TaskBackflowInfos = {}
	BP_ARRAY_TaskBackflowActiveAwardInfos = {}
	BP_STRUCT_TaskBackflowActiveAwardItem = {}
	TaskUI.RegisterPanelDelegate(TaskUI.BackflowTask, TaskBackflowUI.ShowUI, TaskBackflowUI.CloseUI);
	EventSystem:registEvent(EVENTTYPE_TASK, EVENTID_DATAMGR_BACKFLOWTASK_CHANGE, TaskBackflowUI.ServerUpdateData)
end

local function SortTask()
	for _,taskCate in pairs(BP_ARRAY_TaskBackflowInfos) do
		table.sort(taskCate.BP_ARRAY_TaskBackflow, function(a, b)
			local function getSortValue(info)
				if (info.status == UIState["DONE"]) then
					return 3
				elseif info.status == UIState["PROGRESS"] then
					return 2
				else
					return 1
				end
			end
			local sortValue1 = getSortValue(a)
			local sortValue2 = getSortValue(b)
			if sortValue1 == sortValue2 then
				return a.sort < b.sort
			else
				return getSortValue(a) > getSortValue(b)
			end
		end)
	end
end 

function TaskBackflowUI.GetTaskRedDot()
	if BP_ARRAY_TaskBackflowInfos == nil or #BP_ARRAY_TaskBackflowInfos == 0 then
		return false 
	end
	
	BP_TaskBackflowHasRedPoint = false
	for _,taskCategory in pairs(BP_ARRAY_TaskBackflowInfos) do 
		if taskCategory.reddot == true then
			BP_TaskBackflowHasRedPoint = true
			return BP_TaskBackflowHasRedPoint
		end
	end

	for _,awardInfo in ipairs(BP_ARRAY_TaskBackflowActiveAwardInfos) do
		if awardInfo.status == UIState["DONE"] then
			BP_TaskBackflowHasRedPoint =  true break
		end
	end
	return BP_TaskBackflowHasRedPoint
end

local function getTaskUIState(status,cond,current)
	if status == TaskState["PROGRESS"] then
		return UIState["PROGRESS"]
	elseif status == TaskState["DONE"] then
		return UIState["DONE"]
	elseif status == TaskState["AWARDED"] then
		return UIState["AWARDED"]
	end

	return UIState["PROGRESS"]
end


local function InitDayAwardList()
	for dayID,list in pairs(BP_ARRAY_TaskBackflowInfos) do 
		local curDay = DataMgr.RejoinTaskData.total_login_day
		-- curDay = 3;
		if dayID <= curDay then 
			list.isOpen = true
		else
			--只有未开启才需要这些数据
			list.isOpen = false

			local taskID = 0
			local awardMap = {}
			for _,info in pairs(list.BP_ARRAY_TaskBackflow) do
				for _,drop in pairs(info.BP_ARRAY_TaskBackflowCurrDropList) do 
					if awardMap[drop.DropItemID] ~= nil then
						awardMap[drop.DropItemID] = awardMap[drop.DropItemID] + drop.DropItemNum
					else
						awardMap[drop.DropItemID] = drop.DropItemNum
					end
				end
				taskID = info.id
			end
			
			list.BP_ARRAY_TaskDayAwardList = {}
			for id,awardNum in pairs(awardMap) do
				table.insert(list.BP_ARRAY_TaskDayAwardList,{DropItemID = id,	DropItemNum = awardNum,DropItemSort = 0})
			end
			local tableTaskInfo = Client.GetTableData("RejoinTask", taskID)
			--log_tree("tableTaskInfo",tableTaskInfo)
			if tableTaskInfo ~= nil then
				list.title = FuncUtil.LocalizeResFormat("430209",dayID,tableTaskInfo.Rejoin_GroupName)
				list.title = string.gsub(list.title, "{0}", tostring(tableTaskInfo.Rejoin_GroupName)); 		
			end
			
		end
	end
	 --log_tree("InitDayAwardList" , BP_ARRAY_TaskBackflowInfos)
end

function TaskBackflowUI.ServerUpdateData()
	log("TaskBackflowUI.ServerUpdateData")
	TaskBackflowUI.RefreshTaskInfo()
	TaskBackflowUI.RefreshAwradInfo()

	--更新界面
	if TaskBackflowUI.isShow then 
	LuaClassObj.HandleUIMessage(bp_task_backflow, "UpdatePanel")
	end

end

function TaskBackflowUI.RefreshTaskInfo()
	log("TaskBackflowUI.RefreshTaskInfo")
	BP_ARRAY_TaskBackflowInfos = {}
	local taskData = DataMgr.RejoinTaskData
    local taskTable = Client.GetTable(FuncUtil.GetWithRegion("RejoinTask", "RejoinTask_JK", "RejoinTask_JK"))
	log_tree("taskTable zino",taskTable)
	for tableid, tableTaskInfo in pairs(taskTable) do
		if tableTaskInfo.Group ~= 0 then
			local taskCate = BP_ARRAY_TaskBackflowInfos[tableTaskInfo.Group]
			if taskCate == nil then
				taskCate = 
				{
					reddot = false,
					BP_ARRAY_TaskBackflow = {},

					isOpen = false,
					title = "",
					BP_ARRAY_TaskDayAwardList = {},
				}
				BP_ARRAY_TaskBackflowInfos[tableTaskInfo.Group] = taskCate
			end

			local hasData = false
			for taskId,taskServerData in pairs(taskData.task_regular) do
				if tonumber(taskId) == tonumber(tableid) then
					hasData = true
					local uiStatus = getTaskUIState(taskServerData.status,tableTaskInfo.Cond,taskServerData.progress)
                    local drop_util = require("client.common.drop_util")
					table.insert(taskCate.BP_ARRAY_TaskBackflow, 
					{
						id = taskId,
						status = uiStatus,
						progress = taskServerData.progress,
						sort = tableTaskInfo.Order,
						BP_ARRAY_TaskBackflowCurrDropList = drop_util.GetDropsList({tableTaskInfo.previewDropID})
					})
					
					if uiStatus == UIState["DONE"] then
						taskCate.reddot = true
					end
					break
				end
			end

			if hasData == false then
                local drop_util = require("client.common.drop_util")
				table.insert(taskCate.BP_ARRAY_TaskBackflow, 
				{
					id = tableid,
					status = UIState["PROGRESS"],
					progress = 0,
					sort = tableTaskInfo.Order,
					BP_ARRAY_TaskBackflowCurrDropList = drop_util.GetDropsList({tableTaskInfo.previewDropID})
				})
				-- log_tree("GetDropsList", taskCate.BP_ARRAY_TaskBackflow.BP_ARRAY_TaskBackflowCurrDropList);
				taskCate.reddot = false
			end
		end


	end
	SortTask()
	InitDayAwardList()

	-- TaskUI.UpdateBackflowRedPoint()
	-- log_tree("TaskBackflowUI.RefreshTaskInfo" , BP_ARRAY_TaskBackflowInfos)
	-- UpdateLobbyCorpsRedDot(CorpsMgr.HasRedDot("lobby"))
end


local function getAwardUIState(awardId, awardInfo, cond, current)
	if awardInfo.status == 0 then
		if cond <= current then
			return UIState["DONE"]
		else
			return UIState["PROGRESS"]
		end
	elseif awardInfo.status == 1 then
		return UIState["AWARDED"]
	end
	return UIState["PROGRESS"]
end

-- 顶上进度宝箱
function TaskBackflowUI.RefreshAwradInfo()
	local awardData = DataMgr.RejoinTaskData.taskActiveness
	if awardData == nil or awardData.value == nil then
		return
	end
	BP_TaskBackflowActiveNum = awardData.value
	BP_ARRAY_TaskBackflowActiveAwardInfos = {}

    local tbActiveData = Client.GetTable(FuncUtil.GetWithRegion("RejoinActivity", "RejoinActivity_JK", "RejoinActivity_JK"))

	for awardId,awardInfo in pairs(awardData.list) do
		for _, tableAwardInfo in pairs(tbActiveData) do
			if tableAwardInfo.ID == awardId then
				local status = getAwardUIState(awardId, awardInfo, tableAwardInfo.Cond, BP_TaskBackflowActiveNum)
				table.insert(BP_ARRAY_TaskBackflowActiveAwardInfos, 
				{
					id = awardId,
					tableID = tableAwardInfo.Key,
					value = tableAwardInfo.Cond,
					status = status
				})
			end
		end
	end

	table.sort(BP_ARRAY_TaskBackflowActiveAwardInfos, function(a, b)
		return a.value < b.value
	end)

	TaskUI.UpdateBackflowRedPoint()
	-- UpdateLobbyCorpsRedDot(CorpsMgr.HasRedDot("lobby"))
	if TaskBackflowUI.isShow then 
		LuaClassObj.HandleUIMessage(bp_task_backflow, "UpdateActiveness")
	end
end

function TaskBackflowUI.TaskGetAward(taskId, itemList)
	log("TaskBackflowUI.TaskGetAward taskID:" .. taskId)
	-- CommonItemGetUI:ShowPanel(itemList)
	TaskBackflowUI.RefreshTaskInfo()
	BP_TaskBackflowCurrentOperateTaskId = taskId
	LuaClassObj.HandleUIMessage(bp_task_backflow, "UpdatePanel")
end

function TaskBackflowUI.ActivenessGetAward(awardId, itemList)
	CommonItemGetUI:ShowPanel(itemList)
	TaskBackflowUI.RefreshAwradInfo()
	BP_TaskBackflowCurrentOperateAwardId = awardId
end


function EventTaskBackflowGetActivenessReward_Push()
	local activenessInfo = DataMgr.RejoinTaskData.taskActiveness.list[BP_TaskBackflowCurrentOperateAwardId]
	if activenessInfo == nil then
		log("[ERROR : activeness not found ID ]" .. BP_TaskBackflowCurrentOperateAwardId)
		return
	end
	if activenessInfo.status == AwardState["AWARDED"] then
		ShowNotice(108013)
		return
	end
	ComeBackMgr.rejoin_chest_get_award_req(BP_TaskBackflowCurrentOperateAwardId)
end

function EventTaskBackflowGetReward_Push()
	local taskInfo = DataMgr.RejoinTaskData.task_regular[BP_TaskBackflowCurrentOperateTaskId]
	if taskInfo == nil then
		log("[ERROR : task not found ID ]" .. BP_TaskBackflowCurrentOperateTaskId)
		return
	end
	if taskInfo.status == TaskState["AWARDED"] then
		ShowNotice(108013)
		return
	end
	ComeBackMgr.rejoin_task_get_award_req(BP_TaskBackflowCurrentOperateTaskId)
end

function EventTaskBackflowShowRewardDetailPopup_Push()
	log("$$EventTaskBackflowShowRewardDetailPopup_Push")
	local  dropID = 1
	local titleStr = ""
	log("BP_TaskBackflowCurrentOperateAwardId "..BP_TaskBackflowCurrentOperateAwardId)
    local tbActiveInfo = Client.GetTableData(FuncUtil.GetWithRegion("RejoinActivity", "RejoinActivity_JK", "RejoinActivity_JK"),BP_TaskBackflowCurrentOperateAwardId)
	if tbActiveInfo == nil then
		log("[ERROR : TaskBackflowActive not found ID ]" .. BP_TaskBackflowCurrentOperateAwardId)
		return
	end
	-- BP_ARRAY_TaskBackflowActiveAwardInfos
	log_tree("tbActiveInfo",tbActiveInfo)
	dropID = tbActiveInfo.DropID
	titleStr = tbActiveInfo.BoxTitleName
	--log("zino test " .. titleStr)
	-- dropID = 610071;
	CommonTreasureBoxPopup:showPanelByDropId(dropID)
	CommonTreasureBoxPopup:SetTitleString(Client.GetTableData("LocalizeRes", titleStr).TextValue)
end

function EventTaskBackflowGenTaskRewardData_Push()
	local tableTaskInfo = Client.GetTableData("RejoinTask", BP_TaskBackflowCurrentOperateTaskId)
	if tableTaskInfo == nil then
		log("task table data not found - taskId: " .. BP_TaskBackflowCurrentOperateTaskId)
		return
	end
	-- log("$$EventTaskBackflowGenTaskRewardData_Push" .. tableTaskInfo.DropID)
    local drop_util = require("client.common.drop_util")
	BP_ARRAY_TaskBackflowCurrDropList = drop_util.GetDropsList({tableTaskInfo.previewDropID})
end

function EventTaskBackflowGoTo_Push()
	local tableTaskInfo = Client.GetTableData("RejoinTask", BP_TaskBackflowCurrentOperateTaskId)
	if tableTaskInfo == nil then
		log("task table data not found - taskId: " .. BP_TaskBackflowCurrentOperateTaskId)
		return
	end

	if tableTaskInfo.JumpTo == "game://?module=1002000" then
		LobbyUI.CloseOtherMenu()
	end

	if tableTaskInfo.JumpTo == "game://?module=1002800" then
		EventOnClickCorps()
	else
		GlobalData:JumpUrl(tableTaskInfo.JumpTo)
	end

	-- TaskBackflowUI.CloseUI();
	EventTaskHideUI();
end

function EventTaskBackflowClickAwarded_Push()
	ShowNotice(108013)
end

function EventTsakBackflowClickedTab()
	-- body
end

local DelayRefresh = nil;
function TaskBackflowUI.ShowUI()
	log("TaskBackflowUI.ShowUI")
	--local starttime = sandbox.GetTime()

	TaskBackflowUI.isShow = true
	BP_TaskBackflowCurrentCategoryID = 0
	LuaClassObj.HandleDynamicCreation(bp_task_backflow)
	
	if nil ~= DelayRefresh then
		Timer.RemoveTimer(DelayRefresh);
		DelayRefresh = nil;
	end
	DelayRefresh = Timer.InsertTimer(0.1,RefreshTaskBackFlowData,false,false);

	--TaskBackflowUI.RefreshTaskInfo()
	--TaskBackflowUI.RefreshAwradInfo()
	LuaClassObj.HandleUIMessage(bp_task_backflow, "ShowUI")
	UIManager.Show(eUIType.eTaskBackFlowUI)
	-- ClientSendBAReport(BP_BA_CORPS_TASK, 0);

	--local endtime = sandbox.GetTime()

	--print("TaskBackflowUI.ShowUI cost time=", endtime - starttime)
end

function RefreshTaskBackFlowData()
	TaskBackflowUI.RefreshTaskInfo()
	TaskBackflowUI.RefreshAwradInfo()

	--更新界面
	if TaskBackflowUI.isShow then 
		LuaClassObj.HandleUIMessage(bp_task_backflow, "UpdatePanel")
	end
end

function TaskBackflowUI.CloseUI()
	log("TaskBackflowUI.CloseUI")
	TaskBackflowUI.isShow = false
	UIManager.Hide(eUIType.eTaskBackFlowUI)
	LuaClassObj.HandleUIMessage(bp_task_backflow, "CloseUI")
end


function EventTaskBackflowShowHelpPopup()
	PopUpNoticeUI.ShowMessageBox(FuncUtil.GetLocalizeResStr(430210), DataMgr.GetMultiLineMsgByID(430211))
end