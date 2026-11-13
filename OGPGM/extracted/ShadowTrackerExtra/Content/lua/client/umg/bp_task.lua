TaskUI = TaskUI or
{
	isShow = false,

	DailyTask = 1,--日常任务
	LevelTask = 2,--成长任务
	BackflowTask =5--回归任务
}
-- 当前活跃
BP_TaskActiveNum = 0
BP_TaskWeekActiveNum = 0
-- 同步物品掉落列表
BP_STRUCT_TaskDropItem = {
	DropItemID = 0, 
	DropItemNum = 0, 
	DropItemSort = 0,
	DropItemTime = 0
}
BP_ARRAY_CurrentDropList = {
	BP_STRUCT_TaskDropItem = BP_STRUCT_TaskDropItem
}
-- 当前任务列表
BP_STRUCT_TaskInfo = {
	id = 0,
	status = "",
	progress = 0,
	subtype = 0, --子任务类型
	BP_ARRAY_CurrentDropList = BP_ARRAY_CurrentDropList
}

BP_STRUCT_TaskCategory = {
	name = "",
	reddot = false,
	BP_ARRAY_Task = {
		BP_STRUCT_TaskInfo = BP_STRUCT_TaskInfo
	}
}
BP_ARRAY_TaskInfos = {
	BP_STRUCT_TaskCategory = BP_STRUCT_TaskCategory
}
-- 活跃礼包信息
BP_STRUCT_ActiveAwardInfo = {
	id = 0,
	value = 0,
	status = ""
}
BP_ARRAY_ActiveAwardInfos = {
	BP_STRUCT_ActiveAwardInfo = BP_STRUCT_ActiveAwardInfo
}

BP_ARRAY_WeekActiveAwardInfos = {
	BP_STRUCT_ActiveAwardInfo = BP_STRUCT_ActiveAwardInfo
}

-- 成长任务
BP_STRUCT_LevelTaskInfo = {
	level = 0,
	level_status = 0,
	progress1=1,
	task1_status=0,
	progress2=1,
	task2_status=0
}
BP_STRUCT_LevelTaskInfos = {
	isIOSCheck = false,
	isTourist = false,
	currentLevel = 0,
	reddot = false,
	BP_ARRAY_LevelTask = {
		BP_STRUCT_LevelTaskInfo = BP_STRUCT_LevelTaskInfo
	},
	BP_ARRAY_SpecialDropList = {
		BP_STRUCT_TaskDropItem = BP_STRUCT_TaskDropItem
	}
}

--周任务
BP_STRUCT_WeekTask_Condition = {
	index = 1,
	cnd = 0,
	status = 0,
	dropId = 0,
}

BP_STRUCT_WeekTaskInfo = {
	weekTaskId = 0,
	progress = 0,
	totalStage = 1,
	BP_ARRAY_WeekTaskStatus = {
		BP_STRUCT_WeekTask_Condition = BP_STRUCT_WeekTask_Condition
	}
}

BP_ARRAY_WeekTaskInfos = {
	BP_STRUCT_WeekTaskInfo = BP_STRUCT_WeekTaskInfo
}
BP_CurrentWeekTaskId = 0
BP_CurrentWeekTaskStageIndex = 1
BP_CurrentWeekTask_DayOfWeek = 1

-- 数据刷新时间
BP_RefreshTaskTimeLast = 0
BP_RefreshAwardTimeLast = 0
BP_RefreshWeekAwardTimeLast = 0

-- 用于同步lua参数
BP_CurrentOperateTaskId = 0
BP_CurrentOperateAwardId = 0
BP_STRUCT_CurrentOperateLevelTask = {
	level = 0,
	id = 0 --0 等级任务, 1 成长任务1 , 2 成长任务2
}
BP_CurrentOperateDropId = 0
BP_TaskLevelDoneCount = ""

BP_STRUCT_ActiveAwardItem = {
	BP_ARRAY_FixItemList = {
		BP_STRUCT_TaskDropItem = BP_STRUCT_TaskDropItem
	},
	BP_ARRAY_RandomItemList = {
		BP_STRUCT_TaskDropItem = BP_STRUCT_TaskDropItem
	}
}

BP_TASK_ToggleIndex = 0 --要打开的页签index

--为了方便以后的拓展，之前的打开界面方式不改，以后用代理的方式，从回归任务开始
BP_Task_CurrentToggleID = 0
local m_currentToggleID = 0
local m_panelFunctionDelegateList =
{
	[1] = {nil,nil}, -- 每日任务
	[2] = {nil,nil}, -- 成长任务
	[3] = {nil,nil}, -- 每周任务
	[4] = {nil,nil}, -- 个人成就
	[5] = {nil,nil}, --回归任务
}

-- 红点
BP_Array_TaskUI_RedPoint = {false,false,false,false,false};

-- 回流
BP_Task_BackflowTaskIsOpen = false

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
local inlobby = false

local TaskDrop = {}
local LevelDrop = {}

local lastTimeClickAd = 0;

--注册Widget
function bp_task_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_task,
		{{Path="/Game/UMG/UI_Logic/Task/Task_BP.Task_BP_C", Container="Default", ZOrder=BP_ENUM_UI_TASK_ZORDER}},
		{"Lobby"},
		false,
		true,
		true
	);
	BP_ARRAY_TaskInfos = {}
	BP_ARRAY_ActiveAwardInfos = {}
	BP_ARRAY_WeekActiveAwardInfos = {}
	BP_STRUCT_ActiveAwardItem = {}
	BP_STRUCT_LevelTaskInfos = {}



	EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_TASK, EventTaskShowUI);
	EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVENESS_CHANGE, TaskUI.RefreshAwradInfo)
	EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_TASK_CHANGE, TaskUI.RefreshTaskInfo)
	EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_WEEK_TASK_CHANGE, TaskUI.RefreshWeekTaskInfo)

	--EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_TASK, EventTaskHideUI);
	--EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVENESS_CHANGE, TaskUI.RefreshAwradInfo)
	--EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_TASK_CHANGE, TaskUI.UpdateTaskPanel)
	EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_LEVLE_TASK_CHANGE, TaskUI.UpdateLevelTaskPanel)
    EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_ROLE_LEVEL_CHANGE, TaskUI.UpdateLevelTaskPanel);
end

function bp_task_OnModeSwitched(gamestatus)
	if string.lower(gamestatus) ~= "lobby" then
		inlobby = false
		if true == TaskUI.isShow then
			LuaClassObj.HandleDynamicDestroy();
			TaskUI.isShow = false;
		end
	else
		inlobby = true
		if false == TaskUI.isShow then
		LuaClassObj.HandleDynamicCreation(bp_task);
		TaskUI.isShow = true;
		end
	end
end

local function SortTask()
	for _,taskCate in pairs(BP_ARRAY_TaskInfos) do
		table.sort(taskCate.BP_ARRAY_Task, function(a, b)
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

local function GetLevelTaskRedDot()
	for _, levelTaskInfo in pairs(BP_STRUCT_LevelTaskInfos.BP_ARRAY_LevelTask) do
		if levelTaskInfo.level_status == TaskState["DONE"]
		or levelTaskInfo.task1_status == TaskState["DONE"]
		or levelTaskInfo.task2_status == TaskState["DONE"] then
			return true
		end
	end

	return false
end

function TaskUI.GetTaskRedDot()
	for _, taskInfo in ipairs(BP_ARRAY_TaskInfos) do
		if taskInfo.reddot then
			return true
		end
	end

	for _,awardInfo in ipairs(BP_ARRAY_ActiveAwardInfos) do
		if awardInfo.status == UIState["DONE"] then
			return true
		end
	end

	for _,awardInfo in ipairs(BP_ARRAY_WeekActiveAwardInfos) do
		if awardInfo.status == UIState["DONE"] then
			return true
		end
	end

	if BP_STRUCT_LevelTaskInfos.reddot then
		return true
	end

	if TaskUI.GetWeekTaskRedDot() then
		return true
	end

	if TaskUI.GetAchievementRedDot() then
		return true
	end

	if DataMgr.RejoinTaskData.is_open then
		if TaskBackflowUI.GetTaskRedDot() then 
			return true
		end
	end

	return false
end

function TaskUI.GetWeekTaskRedDot()
	for _, v in pairs(BP_ARRAY_WeekTaskInfos) do
		for _, info in pairs(v.BP_ARRAY_WeekTaskStatus) do
			if info.status == 1 then
				return true
			end
		end
	end

	return false
end

function TaskUI.GetAchievementRedDot()
	return AchievementSystem.HasRedpoint();
end

function TaskUI.RefreshLobbyTaskRedDot()
	UpdateLobbyTaskRedDot(TaskUI.GetTaskRedDot());
end

local function getTaskUIState(status)
	if status == TaskState["PROGRESS"] then
		return UIState["PROGRESS"]
	elseif status == TaskState["DONE"] then
		return UIState["DONE"]
	elseif status == TaskState["AWARDED"] then
		return UIState["AWARDED"]
	end

	return UIState["PROGRESS"]
end

function TaskUI.RefreshTaskInfo()
	local taskData = DataMgr.taskData
	BP_ARRAY_TaskInfos = {}
	BP_RefreshTaskTimeLast = taskData.daily_update_time
	local taskExisted = false
	
	--看广告需要满足两个条件，1后台下发广告开关为true，2满足GMS版本满足规定要求（大于12.0.1）
	local canShowAdvetiseTask = false;
	if BP_Global_AdvertiseNeedShowtask then
		local IMSDKHelper = import("IMSDKHelper")
		if IMSDKHelper.GetIsAdvertiseVaild() then
			canShowAdvetiseTask = true;
		end
	end
	
	for taskId,taskInfo in pairs(taskData.list) do
		local tableTaskInfo = Client.GetTableData("Task", taskId)
		if tableTaskInfo ~= nil then
			local taskCate = BP_ARRAY_TaskInfos[tableTaskInfo.TaskCategory]
			if taskCate == nil then
				taskCate = {
					name = tableTaskInfo.TaskCategoryDesc or "NONE",
					reddot = false,
					BP_ARRAY_Task = {}
				}
				BP_ARRAY_TaskInfos[tableTaskInfo.TaskCategory] = taskCate
				log(tableTaskInfo.TaskCategory)
			end

			if TaskDrop[taskId] == nil then
				local drop_util = require("client.common.drop_util")
				TaskDrop[taskId] = drop_util.GetDropsListForTask({tableTaskInfo.DropID})
			end

			--当前广告开关关闭时，广告任务不加入任务list
			if tableTaskInfo.TaskSubtype == 121 and canShowAdvetiseTask == false then
				log("TaskUI.RefreshTaskInfo ad is skip. BP_Global_AdvertiseNeedShowtask = " .. tostring(BP_Global_AdvertiseNeedShowtask));
			else
				table.insert(taskCate.BP_ARRAY_Task, {
					id = taskId,
					status = getTaskUIState(taskInfo.status),
					progress = taskInfo.progress,
					sort = tableTaskInfo.Sort,
					subtype = tableTaskInfo.TaskSubtype,
					BP_ARRAY_CurrentDropList = TaskDrop[taskId]
				})
			end


				if taskInfo.status == TaskState["DONE"] then
					taskCate.reddot = true
				taskExisted = true
			end
		end

	end

	if taskExisted == true then
		LuaClassObj.HandleUIMessageNoFetch(bp_task, "ShowGetAllBtn")
	else
		LuaClassObj.HandleUIMessageNoFetch(bp_task, "HideGetAllBtn")
	end
	SortTask()
	UpdateLobbyTaskRedDot(TaskUI.GetTaskRedDot())
end

function TaskUI.RefreshWeekTaskInfo()
	BP_ARRAY_WeekTaskInfos = {}

	local data = DataMgr.weekTaskData.week_list
	for id, v in pairs(data) do
		local tb = {progress = v.progress, totalStage = v.totalStage, weekTaskId = id}
		tb.BP_ARRAY_WeekTaskStatus = {}
		for index, detail in pairs(v.detail) do
			table.insert(tb.BP_ARRAY_WeekTaskStatus, {cnd = detail.cndId, status = detail.status, dropId = detail.dropId, index = index})
		end
		table.sort(tb.BP_ARRAY_WeekTaskStatus, function(a, b)
			return a.cnd < b.cnd
		end)

		table.insert(BP_ARRAY_WeekTaskInfos, tb)
	end

	UpdateLobbyTaskRedDot(TaskUI.GetTaskRedDot())
	-- log_tree("[yyc] TaskUI.RefreshWeekTaskInfo ", BP_ARRAY_WeekTaskInfos)
end

local function getAwardUIState(awardId, awardInfo, cond, current)
	if awardInfo.status == AwardState["UNDONE"] then
		if cond <= current then
			return UIState["DONE"]
		else
			return UIState["PROGRESS"]
		end
	else
		return UIState["AWARDED"]
	end
end

function TaskUI.GetTaskActiveTableName()
    local region = Client.GetPublishRegion();
    if region == "JAPAN" or region == "KOREA" then
        log("TaskUI.GetTaskActiveTableName, region = JK, load TaskActiveJK");
        return "TaskActiveJK";
    else
        log("TaskUI.GetTaskActiveTableName, region = GL, load TaskActive");
        return "TaskActive";
    end
end

function TaskUI.RefreshAwradInfo()
	local awardData = DataMgr.activeness
	
	if awardData == nil then
		return
	end
	BP_RefreshAwardTimeLast = awardData.daily_update_time
	BP_RefreshWeekAwardTimeLast = awardData.week_update_time
	BP_TaskActiveNum = awardData.value
	BP_TaskWeekActiveNum = awardData.week_value
	
	BP_ARRAY_ActiveAwardInfos = {}
	BP_ARRAY_WeekActiveAwardInfos = {}
	local taskActiveName = TaskUI.GetTaskActiveTableName()
	for awardId,awardInfo in pairs(awardData.list) do
		local tableAwardInfo = Client.GetTableData(taskActiveName, awardId)
		local status = getAwardUIState(awardId, awardInfo, tableAwardInfo.Cond, BP_TaskActiveNum)
		table.insert(BP_ARRAY_ActiveAwardInfos, {
			id = awardId,
			value = tableAwardInfo.Cond,
			status = status
		})
	end

	for awardId, awardInfo in pairs(awardData.week_list) do
		local tableAwardInfo = Client.GetTableData(taskActiveName, awardId)
		local status = getAwardUIState(awardId, awardInfo, tableAwardInfo.Cond, BP_TaskWeekActiveNum)
		table.insert(BP_ARRAY_WeekActiveAwardInfos, {
			id = awardId,
			value = tableAwardInfo.Cond,
			status = status
		})
	end

	table.sort(BP_ARRAY_ActiveAwardInfos, function(a, b)
		return a.value < b.value
	end)
	table.sort(BP_ARRAY_WeekActiveAwardInfos, function(a, b)
		return a.value < b.value
	end)

	UpdateLobbyTaskRedDot(TaskUI.GetTaskRedDot())
	--log_tree("xzx9 activeInfos", BP_ARRAY_ActiveAwardInfos)
end

function TaskUI.RefreshLevelTaskInfo()
	BP_STRUCT_LevelTaskInfos = {}
	BP_STRUCT_LevelTaskInfos.currentLevel = DataMgr.roleData.level
	BP_STRUCT_LevelTaskInfos.BP_ARRAY_LevelTask = {}

	BP_STRUCT_LevelTaskInfos.isIOSCheck = GlobalData:IsIOSCheck()
	--BP_STRUCT_LevelTaskInfos.isIOSCheck = false
	BP_STRUCT_LevelTaskInfos.isTourist = Client.GetLoginChannel(NetInterface) == BP_ENUM_PLAYFORM_TOURIST
	--BP_STRUCT_LevelTaskInfos.isTourist = false

	if DataMgr.levelTask then
		for level,info in pairs(DataMgr.levelTask.list) do
			BP_STRUCT_LevelTaskInfos.BP_ARRAY_LevelTask[level] = info
			info.level = level
		end
	end

	--log_tree("xzx9 levelTaskInfo, before", BP_STRUCT_LevelTaskInfos)
	--针对游客模式和IOSCheck版本模式下的任务完成的逻辑
	--（游客模式下，有些任务不显示，但是只要显示了的任务都完成了，就应该显示该等级下，任务全部完成了）
	if BP_STRUCT_LevelTaskInfos.isTourist == true or 
		BP_STRUCT_LevelTaskInfos.isIOSCheck == true then
		--log("xzx9 here")
		for j, tmpinfo in pairs(BP_STRUCT_LevelTaskInfos.BP_ARRAY_LevelTask) do
			local tableInfo = Client.GetTableData("LevelTask", j)
			if tableInfo ~= nil then
				if tableInfo.IOSSwitch1 == 0 or tableInfo.TouristSwitch1 == 0 then
					if tableInfo.Task1Cond ~= 0 then 
						if (tableInfo.TouristSwitch1 == 0 and BP_STRUCT_LevelTaskInfos.isTourist == true) or
							(tableInfo.IOSSwitch1 == 0 and BP_STRUCT_LevelTaskInfos.isIOSCheck == true) then
								tmpinfo.task1_status = 2
						end
					end
				end

				if tableInfo.IOSSwitch2 == 0 or tableInfo.TouristSwitch2 == 0 then
					if tableInfo.Task2Cond ~= 0 then 
						if (tableInfo.TouristSwitch2 == 0 and BP_STRUCT_LevelTaskInfos.isTourist == true) or
							(tableInfo.IOSSwitch2 == 0 and BP_STRUCT_LevelTaskInfos.isIOSCheck == true) then
								tmpinfo.task2_status = 2
						end
					end
				end
			end
		end
	end

	BP_STRUCT_LevelTaskInfos.BP_ARRAY_SpecialDropList = {}

	for i = 1, 10 do
		local level = i * 10
		local levelTaskInfo = Client.GetTableData("LevelTask", level)
		
		if levelTaskInfo ~= nil then

			if LevelDrop[i] == nil then
                local drop_util = require("client.common.drop_util")
				LevelDrop[i] = drop_util.GetDropsListForTask({levelTaskInfo.Task1Award})
			end

			if #(LevelDrop[i]) > 0 then
				table.insert(BP_STRUCT_LevelTaskInfos.BP_ARRAY_SpecialDropList, LevelDrop[i][1])
			end
		end
	end
	BP_STRUCT_LevelTaskInfos.reddot = GetLevelTaskRedDot()
	--log_tree("levelTaskInfo, after", BP_STRUCT_LevelTaskInfos)
	
	local levelDoneCount = 0
	for j, tmpinfo in pairs(BP_STRUCT_LevelTaskInfos.BP_ARRAY_LevelTask)  do
		if tmpinfo.level_status == TaskState["DONE"]  then
			levelDoneCount = levelDoneCount + 1
		end

		if tmpinfo.task1_status == TaskState["DONE"]  then
			levelDoneCount = levelDoneCount + 1
		end

		if tmpinfo.task2_status == TaskState["DONE"]  then
			levelDoneCount = levelDoneCount + 1
		end

	end

	local data = Client.GetTableData("LocalizeRes",4978)
	local content
	if data == nil then
		BP_TaskLevelDoneCount = "没有找到4978LocalizeRes"
	else
		content = data.TextValue
		BP_TaskLevelDoneCount = string.format(content, levelDoneCount)
	end

	LuaClassObj.HandleUIMessage(bp_task, "setLevelTaskDoneCount")
	UpdateLobbyTaskRedDot(TaskUI.GetTaskRedDot())
end

function TaskUI.TaskGetAward(taskId, itemList)
	CommonItemGetUI:ShowPanel(itemList)
	TaskUI.RefreshTaskInfo()
	SortTask()
	BP_CurrentOperateTaskId = taskId
	LuaClassObj.HandleUIMessage(bp_task, "UpdatePanel")
end

function TaskUI.TaskGetAllAward()
	TaskUI.RefreshTaskInfo()
	SortTask()
	--BP_CurrentOperateTaskId = taskId
	LuaClassObj.HandleUIMessage(bp_task, "UpdatePanel")
end

function TaskUI.ActivenessGetAward(awardId, itemList)
	CommonItemGetUI:ShowPanel(itemList)
	TaskUI.RefreshAwradInfo()
	BP_CurrentOperateAwardId = awardId
	LuaClassObj.HandleUIMessage(bp_task, "UpdateActiveness")
end

function TaskUI.LevelTaskGetAward(level, id, itemList)
	--表格还未配置，下行代码运行会出错，导致不能刷新，表格配置完成后，再去除注释
	CommonItemGetUI:ShowPanel(itemList)
	TaskUI.RefreshLevelTaskInfo()
	BP_STRUCT_CurrentOperateLevelTask = {level = level, id = id}
	LuaClassObj.HandleUIMessage(bp_task, "UpdatePanel")
end

function TaskUI.UpdateTaskPanelNoData()
	log("TaskUI.UpdateTaskPanelNoData"..tostring(TaskUI.isShow)..tostring(inlobby))
	if TaskUI.isShow == true and inlobby then
		LuaClassObj.HandleUIMessage(bp_task, "UpdatePanel")
	end
end

function TaskUI.UpdateTaskPanel()
	TaskUI.RefreshTaskInfo()
	SortTask()
	if inlobby then
		LuaClassObj.HandleUIMessage(bp_task, "UpdatePanel")
	end
end

function TaskUI.UpdateLevelTaskPanel()
	TaskUI.RefreshLevelTaskInfo()
	if inlobby then
		TaskBackflowUI.ShowBlock = true
		LuaClassObj.HandleUIMessage(bp_task, "UpdatePanel")
	end
end

function TaskUI.UpdateWeekTaskPanel()
	TaskUI.RefreshWeekTaskInfo()
	if inlobby then
		LuaClassObj.HandleUIMessage(bp_task, "UpdatePanel")
	end
end

function TaskUI.OpenTaskWithIndex(index)
	BP_TASK_ToggleIndex = index
	EventTaskShowUI()
	LuaClassObj.HandleUIMessage(bp_task, "SetToggleIndex")
end

function EventTaskFinishTask_Push()
	local taskInfo = DataMgr.taskData.list[BP_CurrentOperateTaskId]
	if taskInfo == nil then
		log("[ERROR : task not found ID ]" .. BP_CurrentOperateTaskId)
		return
	end
	if taskInfo.status == TaskState["AWARDED"] then
		ShowNotice(108013)
		return
	end
	TaskSystem.Req_TaskGetAward(BP_CurrentOperateTaskId)
end

function EventTaskGetAllAward()
	NetUtil.SendPkg("task_get_all_award_req")
end

--点击获取奖励（任务完成，没有领取）
function EventTaskGetReward_Push()
	local activenessInfo = DataMgr.activeness.list[BP_CurrentOperateAwardId]
	activenessInfo = activenessInfo or DataMgr.activeness.week_list[BP_CurrentOperateAwardId]
	if activenessInfo == nil then
		log("[ERROR : activeness not found ID ]" .. BP_CurrentOperateAwardId)
		return
	end
	if activenessInfo.status == AwardState["DONE"] then
		ShowNotice(108013)
		return
	end
	TaskSystem.Req_ActivenessGetAward(BP_CurrentOperateAwardId)
end

--显示奖励内容（任务没有完成，活跃度没有达到）
function EventTaskShowRewardDetailPopup_Push()
	CommonTreasureBoxPopup:ShowPanel(BP_CurrentOperateAwardId)
	local taskActiveName = TaskUI.GetTaskActiveTableName()
	local tableAwardInfo = Client.GetTableData(taskActiveName, BP_CurrentOperateAwardId)
	if tableAwardInfo == nil then
		return
	end
	CommonTreasureBoxPopup:SetTitleString(Client.GetTableData("LocalizeRes", tableAwardInfo.BoxTitleName).TextValue)
end

function EventLevelTaskShowRewardDetailPopup_Push()
	CommonTreasureBoxPopup:showPanelByDropId(BP_CurrentOperateAwardId)
	CommonTreasureBoxPopup:SetTitleString(Client.GetTableData("LocalizeRes", "108033").TextValue)
end

function EventTestAddProgress_Push()
end

function EventTaskGetTaskReward_Push()
	local tableTaskInfo = Client.GetTableData("Task", BP_CurrentOperateTaskId)
	if tableTaskInfo == nil then
		log("task table data not found - taskId: " .. BP_CurrentOperateTaskId)
		return
	end
    local drop_util = require("client.common.drop_util")
	BP_ARRAY_CurrentDropList = drop_util.GetDropsList({tableTaskInfo.DropID})
end

function EventGetDropsList_Push()
    local drop_util = require("client.common.drop_util")
	BP_ARRAY_CurrentDropList = drop_util.GetDropsList({BP_CurrentOperateDropId})
end

local DelayRefresh = nil;
function EventTaskShowUI()

	if false == TaskUI.isShow then
		LuaClassObj.HandleDynamicCreation(bp_task);
	end
	TaskUI.isShow = true;
	BP_Task_BackflowTaskIsOpen = DataMgr.RejoinTaskData.is_open and LobbySystem.IsLabelSwitchOpen(BP_ENUM_COME_BACK_TASK)
	if nil ~= DelayRefresh then
		Timer.RemoveTimer(DelayRefresh);
		DelayRefresh = nil;
	end
	
	DelayRefresh = Timer.InsertTimer(0.1,RefreshData,false,false);	
	-- log_tree("==========BP_ARRAY_SpecialDropList====", BP_STRUCT_LevelTaskInfos.BP_ARRAY_SpecialDropList)
	LuaClassObj.HandleUIMessage(bp_task, "UIShow")
	UIManager.Show(eUIType.eTaskUI)
	TaskUI.ShowSelf()

	EventSystem:registEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN, TaskUI.HideSelf);
	EventSystem:registEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE, TaskUI.ShowSelf);
end

function RefreshData()
	TaskUI.RefreshTaskInfo()
	TaskUI.RefreshAwradInfo()
	TaskUI.RefreshLevelTaskInfo()
	AchievementSystem.get_achievement_summary_req(tonumber(DataMgr.roleData.uid));

	LuaClassObj.HandleUIMessage(bp_task, "UpdatePanel")
	TaskBackflowUI.RefreshTaskInfo()
	TaskUI.UpdateBackflowRedPoint()
end

function EventTaskHideUI()
	LuaClassObj.HandleUIMessage(bp_task, "UIClose")
	TaskUI.ClosePanel()
end

function TaskUI.ShowSelf()
	TaskUI.isShow = true;
	local bp = UIUtil.GetWidgetByName("bp_task", "Task_BP")
	if bp then
		bp:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible);
	end
	--LuaClassObj.HandleUIMessage(bp_task, "ShowSelf")
end

function TaskUI.HideSelf()
	TaskUI.isShow = false;
	local bp = UIUtil.GetWidgetByName("bp_task", "Task_BP")
	if bp then
		bp:SetVisibility(UEnums.ESlateVisibility.Collapsed);
	end
	--LuaClassObj.HandleUIMessage(bp_task, "HideSelf")
end

function EventTaskOnUIClose()
	if UIManager.GetUI(eUIType.eAchievementDetailUI) then
		LuaClassObj.HandleUIMessageNoFetch(bp_achievement_detail, "OnCloseBtnClick");
	end
	
	UIManager.Hide(eUIType.eTaskUI)
	TaskUI.isShow = false;
	-- CommonTreasureBoxPopup:ClosePanelWithoutSound()
	TaskUI.ClosePanel();
	BP_TASK_ToggleIndex = 0;

	EventSystem:unregistEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN, TaskUI.HideSelf);
	EventSystem:unregistEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE, TaskUI.ShowSelf);
end

--若关闭当前界面跳转到个人信息页面时刷新成就分数
function EventUpdateRoleInfoAchievementScore()
	if RoleInfoUI.IsShow then
		LuaClassObj.HandleUIMessageNoFetch(bp_roleinfo, "UpdateAchievementScore")

		local CurrPage = GetRoleInfoPageByIndex(BP_CurrRoleInfoPageIndex)
		if CurrPage and CurrPage.UpdateAchievementScore then
			CurrPage.UpdateAchievementScore()
		end
	end
end


function EventTaskGoTo_Push()
	local tableTaskInfo = Client.GetTableData("Task", BP_CurrentOperateTaskId)
	if tableTaskInfo == nil then
		log("task table data not found - taskId: " .. BP_CurrentOperateTaskId)
		return
	end
	if tableTaskInfo.JumpTo == "WX_PECULIAR" then
		EventShowPlatWXStartup()
	elseif tableTaskInfo.JumpTo == "QQ_PECULIAR" then
		EventShowPlatQQStartup()
	elseif tableTaskInfo.JumpTo == "BP_ENUM_MODULE_AD" then
		--广告任务不需要跳转对应module，直接弹出广告
		log("bp_task EventTaskGoTo_Push TryShowAdvertise");
		--防止频繁点击加载广告，添加保险
		if FuncUtil.GetServerTimeInSec() - lastTimeClickAd > 5 then
			LuaClassObj.HandleUIMessage(bp_task, "TryShowAdvertise");
			lastTimeClickAd = FuncUtil.GetServerTimeInSec();
		else
			EventTaskLoadAdvetiseError();
		end
		return;
	else
		if _G[tableTaskInfo.JumpTo] ~= nil then
			
			if _G[tableTaskInfo.JumpTo] ~= BP_ENUM_MODULE_SHARE then
				LobbyUI.CloseOtherMenu()
			end

			if _G[tableTaskInfo.JumpTo] == BP_ENUM_MODULE_SHOP then
				--GlobalData:JumpUrl("game://?module=1003200&Tab1=6&Tab2=100")
                if StoreSystem.IsUseNewStore() then
                    JumpUtils.JumpFromLobbyToSupply(0)
                else
                    MallSystemUI_2.TaskJumpBPBox();
                end
			else
				GlobalData:JumpUrl("game://?module=" .. _G[tableTaskInfo.JumpTo])
			end
			--GlobalData:JumpUrl("game://?module=" .. _G[tableTaskInfo.JumpTo])
		end
	end
end

function EventLevelTaskGoto_Push()
	local levelTaskInfo = Client.GetTableData("LevelTask", BP_STRUCT_CurrentOperateLevelTask.level)
	if BP_STRUCT_CurrentOperateLevelTask.id == 0 then  
		GlobalData:JumpUrl("game://?module=" .. BP_ENUM_MODULE_LOBBY)
	elseif BP_STRUCT_CurrentOperateLevelTask.id == 1 then
		if _G[levelTaskInfo.JumpTo1] ~= nil then
			if _G[levelTaskInfo.JumpTo1] ~= BP_ENUM_MODULE_SHARE then
				LobbyUI.CloseOtherMenu()
			end
			--GlobalData:JumpUrl("game://?module=" .. _G[levelTaskInfo.JumpTo1])
			if _G[levelTaskInfo.JumpTo1] == BP_ENUM_MODULE_SHOP then
				--GlobalData:JumpUrl("game://?module=1003200&Tab1=6&Tab2=100")
				if StoreSystem.IsUseNewStore() then
					JumpUtils.JumpFromLobbyToSupply(0)
				else
					MallSystemUI_2.TaskJumpBPBox();
				end
			else
				GlobalData:JumpUrl("game://?module=" .. _G[levelTaskInfo.JumpTo1])
			end
		end
	elseif BP_STRUCT_CurrentOperateLevelTask.id == 2 then
		if _G[levelTaskInfo.JumpTo2] ~= nil then
			if _G[levelTaskInfo.JumpTo2] ~= BP_ENUM_MODULE_SHARE then
				LobbyUI.CloseOtherMenu()
			end
			--GlobalData:JumpUrl("game://?module=" .. _G[levelTaskInfo.JumpTo2])
			if _G[levelTaskInfo.JumpTo2] == BP_ENUM_MODULE_SHOP then
				--GlobalData:JumpUrl("game://?module=1003200&Tab1=6&Tab2=100")
				if StoreSystem.IsUseNewStore() then
					JumpUtils.JumpFromLobbyToSupply(0)
				else
					MallSystemUI_2.TaskJumpBPBox();
				end
			else
				GlobalData:JumpUrl("game://?module=" .. _G[levelTaskInfo.JumpTo2])
			end
		end
	end
	
end

function EventWeekTaskGoto_Push()
	local tableTaskInfo = Client.GetTableData("WeekTask", BP_CurrentWeekTaskId)
	if tableTaskInfo == nil then
		log("WeekTask table data not found - taskId: " .. BP_CurrentWeekTaskId)
		return
	end
	if tableTaskInfo.JumpTo == "WX_PECULIAR" then
		EventShowPlatWXStartup()
	elseif tableTaskInfo.JumpTo == "QQ_PECULIAR" then
		EventShowPlatQQStartup()
	else
		if _G[tableTaskInfo.JumpTo] ~= nil then
			if _G[tableTaskInfo.JumpTo] ~= BP_ENUM_MODULE_SHARE then
				LobbyUI.CloseOtherMenu()
			end

			if _G[tableTaskInfo.JumpTo] == BP_ENUM_MODULE_SHOP then
				--GlobalData:JumpUrl("game://?module=1003200&Tab1=6&Tab2=100")
				if StoreSystem.IsUseNewStore() then
					JumpUtils.JumpFromLobbyToSupply(0)
				else
					MallSystemUI_2.TaskJumpBPBox();
				end
			else
				GlobalData:JumpUrl("game://?module=" .. _G[tableTaskInfo.JumpTo])
			end
			--GlobalData:JumpUrl("game://?module=" .. _G[tableTaskInfo.JumpTo])
		end
	end
end

function EventGetWeekAward_Push()
	log("[yyc] BP_CurrentWeekTaskStageIndex:"..BP_CurrentWeekTaskStageIndex.." BP_CurrentWeekTaskId:"..BP_CurrentWeekTaskId)
	TaskSystem.Req_WeekTaskGetAward(BP_CurrentWeekTaskId, BP_CurrentWeekTaskStageIndex)
end

function EventGetAllWeekAward_Push()
	log("[yyc] EventGetAllWeekAward_Push")
	TaskSystem.Req_WeekTaskGetAward(BP_CurrentWeekTaskId, nil)
end

function EventLevelTaskGetAward_Push()
	log("====================EventLevelTaskGetAward_Push " .. BP_STRUCT_CurrentOperateLevelTask.level .. " " .. BP_STRUCT_CurrentOperateLevelTask.id)
	TaskSystem.Req_LevelTaskGetAward(BP_STRUCT_CurrentOperateLevelTask.level, BP_STRUCT_CurrentOperateLevelTask.id)
end

function EventOneKeyLevelTaskGetAward_Push()
	TaskSystem.Req_OnekeyLevelTaskGetAward()
end


-- 直接显示“活跃度奖励已经领取”
function EventTaskClickAwarded_Push()
	ShowNotice(108013)
end

--广告未加载时，提示广告加载失败
function EventTaskLoadAdvetiseError()
	ShowNotice(6506)
end

function TaskUI.OnekeyLevelTaskGetAward(arrayItemData)
	TaskUI.RefreshLevelTaskInfo()
	LuaClassObj.HandleUIMessage(bp_task, "UpdatePanel")
	CommonItemGetUI:ShowBatchPanel(arrayItemData)
end

-- BP_ChatShareAchievementId = 0;
-- 从聊天窗口的成就分享跳转而来
function TaskUI.FromChatShareAchievement(id, groupId)
	-- BP_ChatShareAchievementId = id;
	LuaClassObj.HandleUIMessage(bp_task, "JumpFromChatShareAchievement");
	AchievementTaskUI.FromChatShareAchievement(id, groupId);
end

function EventTaskOnToggleClicked()
	if TaskBackflowUI.ShowBlock then
		TaskBackflowUI.ShowBlock = false
		return
	end
	TaskUI.ClosePanel()
	TaskUI.OpenPanel(BP_Task_CurrentToggleID)
end

function TaskUI.JumpToPage(index)
	BP_Task_CurrentToggleID = index
	LuaClassObj.HandleUIMessage(bp_task, "SelectOpenPanel")
end

function TaskUI.RegisterPanelDelegate(index , openFuction, closeFunction)
	if index <= #m_panelFunctionDelegateList then
		m_panelFunctionDelegateList[index][1] = openFuction
		m_panelFunctionDelegateList[index][2] = closeFunction
	end
end

function TaskUI.OpenPanel(index)
	log("TaskUI.OpenPanel" .. index)
	m_currentToggleID = index

	--为了方便以后的拓展，之前的打开界面方式不改，以后用代理的方式，从回归任务开始
	if m_currentToggleID >= 3 and #m_panelFunctionDelegateList >= m_currentToggleID then 
		if m_panelFunctionDelegateList[m_currentToggleID][1] ~= nil then
			m_panelFunctionDelegateList[m_currentToggleID][1]()
		end
	end
end

function TaskUI.ClosePanel()
	log("TaskUI.ClosePanel")
	--为了方便以后的拓展，之前的打开界面方式不改，以后用代理的方式，从回归任务开始
	if m_currentToggleID >= 3 and #m_panelFunctionDelegateList >= m_currentToggleID then 
		if m_panelFunctionDelegateList[m_currentToggleID][2] ~= nil then
			m_panelFunctionDelegateList[m_currentToggleID][2]()

		end
	end
end

-- 刷新回流tab的红点
function TaskUI.UpdateBackflowRedPoint()
	--log("TaskUI.UpdateBackflowRedPoint "..tostring(TaskUI.isShow))
	UpdateLobbyTaskRedDot(TaskUI.GetTaskRedDot())

	if not TaskUI.isShow then
		return
	end
	-- -- 更新信息小红点
	BP_Array_TaskUI_RedPoint[TaskUI.BackflowTask] = TaskBackflowUI.GetTaskRedDot();
	-- BP_TASK_TAB_BACK_FLOW_RED_POINT = false;
	-- local backflowReds = TaskBackflowUI.GetTaskRedDot();
	-- if backflowReds ~= nil then
	-- 	for k,v in ipairs(backflowReds) do
	-- 		log("XZF 306 "..tostring(k).."  "..tostring(v))
	-- 		BP_TASK_TAB_BACK_FLOW_RED_POINT = BP_TASK_TAB_BACK_FLOW_RED_POINT and v;
	-- 	end
	-- end
	-- BP_Array_TaskUI_RedPoint[TaskUI.BackflowTask] = TaskBackflowUI.GetTaskRedDot()
	--log_tree("XZF 306", TaskBackflowUI.GetTaskRedDot());
	--log_tree("XZF 305", BP_Array_TaskUI_RedPoint);

	LuaClassObj.HandleUIMessage(bp_task, "UpdateRedPoint");
end

function EventTaskBPShowLoading()
	ConnectionWaitingUI:Show()
end

function EventTaskBPHideLoading()
	ConnectionWaitingUI:Hide()
end

function EventTaskBPHideAchievePop()
	if UIManager.GetUI(eUIType.eAchievementDetailUI) and AchievementDetailUI.isJumpFromChat == false then
		LuaClassObj.HandleUIMessageNoFetch(bp_achievement_detail, "OnCloseBtnClick");
	end
end