-- 军团任务UI
CorpsTaskUI = CorpsTaskUI or 
{
	isShow = false;
}

BP_CorpsTaskActiveNum = 0

BP_CorpsTaskStarNum =0

BP_CorpsTaskHasRedPoint = false

BP_STRUCT_CorpsTaskDropItem = 
{
	DropItemID =0,
	DropItemNum  =0,
	DropItemSort = 0
}

BP_ARRAY_CorpsTaskCurrDropList = 
{
	BP_STRUCT_CorpsTaskDropItem = BP_STRUCT_CorpsTaskDropItem
}

BP_STRUCT_CorpsTaskInfo = 
{
	id =0,
	status = "",
	progress = 0,
	BP_ARRAY_CorpsTaskCurrDropList = BP_ARRAY_CorpsTaskCurrDropList
}

BP_STRUCT_TaskCorpsCategory = 
{
	reddot = false,
	BP_ARRAY_TaskCorps = 
	{
		BP_STRUCT_CorpsTaskInfo = BP_STRUCT_CorpsTaskInfo
	}
}

BP_ARRAY_TaskCorpsInfos = 
{
	BP_STRUCT_TaskCorpsCategory = BP_STRUCT_TaskCorpsCategory
}

BP_STRUCT_CorpsTaskActiveAwardInfo = 
{
	id =0,
	tableID =0,
	value = 0,
	status = ""
}

BP_ARRAY_CorpsTaskActiveAwardInfos = 
{
	BP_STRUCT_CorpsTaskActiveAwardInfo = BP_STRUCT_CorpsTaskActiveAwardInfo
}

-- 用于同步lua参数
BP_CorpsTaskCurrentOperateTaskId = 0
BP_CorpsTaskCurrentOperateAwardId = 0


BP_STRUCT_CorpsTaskActiveAwardItem = {
	BP_ARRAY_CorpsTaskFixItemList = {
		BP_STRUCT_CorpsTaskDropItem = BP_STRUCT_CorpsTaskDropItem
	},
	BP_ARRAY_CorpsTaskRandomItemList = {
		BP_STRUCT_CorpsTaskDropItem = BP_STRUCT_CorpsTaskDropItem
	}
}

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
function bp_corps_task_RegisterUI()
  	LuaClassObj.SubUIWidgetList(bp_corps_task,
    {{Path="/Game/UMG/UI_Logic/Corps/CorpsTask_BP.CorpsTask_BP_C", Container="Default", ZOrder=BP_ENUM_UI_CORPS_HOMEPAGE_ZORDER +1}},
    {"Lobby"},
	false,
	false,
	true
  	);

	BP_ARRAY_CorpsTaskCurrDropList = {}
	BP_ARRAY_TaskCorpsInfos = {}
	BP_ARRAY_CorpsTaskActiveAwardInfos = {}
	BP_STRUCT_CorpsTaskActiveAwardItem = {}
	CorpsBaseUI.RegisterCallBacks(CorpsBaseUI.PageMission, CorpsTaskUI.ShowUI, CorpsTaskUI.CloseUI)
	EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_CORPS_ACTIVENESS_CHANGE, CorpsTaskUI.RefreshAwradInfo)
	EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_CORPS_TASK_CHANGE, CorpsTaskUI.RefreshTaskInfo)
	-- EventSystem:registEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_INFO, CorpsTaskUI.RefreshAwradInfo)
end

local  function  SortTask()
	for _,taskCate in pairs(BP_ARRAY_TaskCorpsInfos) do
		table.sort(taskCate.BP_ARRAY_TaskCorps, function(a, b)
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

function CorpsTaskUI.GetTaskRedDot()
	if BP_ARRAY_TaskCorpsInfos == nil or #BP_ARRAY_TaskCorpsInfos == 0 then
		return false 
	end
	
	BP_CorpsTaskHasRedPoint = false
	-- log_tree("$$~~!!!!!" , BP_ARRAY_TaskCorpsInfos[1].BP_ARRAY_TaskCorps)
	for _, taskInfo in ipairs(BP_ARRAY_TaskCorpsInfos[1].BP_ARRAY_TaskCorps) do
		if taskInfo.status == UIState["DONE"] then
			BP_CorpsTaskHasRedPoint =  true break
		end
	end

	for _,awardInfo in ipairs(BP_ARRAY_CorpsTaskActiveAwardInfos) do
		if awardInfo.status == UIState["DONE"] then
			BP_CorpsTaskHasRedPoint =  true break
		end
	end
	if BP_CorpsTaskHasRedPoint then
		log("CorpsTaskUI.GetTaskRedDot .. true")
	else
		log("CorpsTaskUI.GetTaskRedDot .. false")
	end
	return BP_CorpsTaskHasRedPoint
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

function CorpsTaskUI.RefreshTaskInfo()
	local taskData = DataMgr.corpsTaskData
	BP_ARRAY_TaskCorpsInfos = {}
    local drop_util = require("client.common.drop_util")
	for taskId,taskInfo in pairs(taskData.list) do
		local tableTaskInfo = Client.GetTableData("CorpsTask", taskId)
		if tableTaskInfo ~= nil then
			local taskCate = BP_ARRAY_TaskCorpsInfos[1]
			if taskCate == nil then
				taskCate = {
					reddot = false,
					BP_ARRAY_TaskCorps = {}
				}
				BP_ARRAY_TaskCorpsInfos[1] = taskCate
			end
			table.insert(taskCate.BP_ARRAY_TaskCorps, {
				id = taskId,
				status = getTaskUIState(taskInfo.status),
				progress = taskInfo.progress,
				sort = tableTaskInfo.Sort,
				BP_ARRAY_CorpsTaskCurrDropList = drop_util.GetDropsList({tableTaskInfo.DropID})
			})
				log("!!!!tableTaskInfo.DropID" .. tableTaskInfo.DropID)

			if taskInfo.status == TaskState["DONE"] then
				taskCate.reddot = true
			end
		end
	end
	SortTask()
	-- CorpsTaskUI.GetTaskRedDot()
	CorpsBaseUI.UpdateRedPoint()
	UpdateLobbyCorpsRedDot(CorpsMgr.HasRedDot("lobby"))
	-- log_tree("!!!!BP_ARRAY_TaskCorpsInfos" ,BP_ARRAY_TaskCorpsInfos)
end

local function getAwardUIState(awardId, awardInfo, cond, current)
	-- log("$$$$$$$$$$" .. awardInfo.status)

	if awardInfo.status == 0 then
		if cond <= current then
			return UIState["DONE"]
		else
			return UIState["PROGRESS"]
		end
	elseif awardInfo.status == 1 then
		return UIState["DONE"]
	elseif awardInfo.status == 2 then
		return UIState["AWARDED"]
	end

	-- if awardInfo.status == AwardState["UNDONE"] then
	-- 	if cond <= current then
	-- 		return UIState["DONE"]
	-- 	else
	-- 		return UIState["PROGRESS"]
	-- 	end
	-- else
	-- 	return UIState["AWARDED"]
	-- end
end

function CorpsTaskUI.RefreshAwradInfo()
	local awardData = DataMgr.corpsActiveness
	if awardData == nil or awardData.value == nil or awardData.star == nil then
		return
	end
	--log_tree("$$~~~~~" , awardData)
	BP_CorpsTaskActiveNum = awardData.value
	BP_CorpsTaskStarNum = awardData.star
	BP_ARRAY_CorpsTaskActiveAwardInfos = {}
	for awardId,awardInfo in pairs(awardData.list) do
		local tbActiveData = Client.GetTable("CorpsTaskActive")
		for _, tableAwardInfo in pairs(tbActiveData) do
			if tableAwardInfo.Star == awardData.star and tableAwardInfo.ID == awardId then
			local status = getAwardUIState(awardId, awardInfo, tableAwardInfo.ActivityNum, BP_CorpsTaskActiveNum)
			table.insert(BP_ARRAY_CorpsTaskActiveAwardInfos, 
			{
				id = awardId,
				tableID = tableAwardInfo.Key,
				value = tableAwardInfo.ActivityNum,
				status = status
			})
			end
		end
	end

	table.sort(BP_ARRAY_CorpsTaskActiveAwardInfos, function(a, b)
		return a.value < b.value
	end)

	-- CorpsTaskUI.GetTaskRedDot()
	-- UpdateLobbyTaskRedDot(CorpsTaskUI.GetTaskRedDot())-- todo chris.记得改啊这个，暂时lobby没有军团按钮
	-- chris 说的对呀
	CorpsBaseUI.UpdateRedPoint()
	UpdateLobbyCorpsRedDot(CorpsMgr.HasRedDot("lobby"))
	if CorpsTaskUI.isShow then 
		LuaClassObj.HandleUIMessage(bp_corps_task, "UpdateActiveness")
	end
	log_tree("$$CorpsTaskUI.RefreshAwradInfo" , BP_ARRAY_CorpsTaskActiveAwardInfos)
end

function CorpsTaskUI.TaskGetAward(taskId, itemList)
	CommonItemGetUI:ShowPanel(itemList)
	CorpsTaskUI.RefreshTaskInfo()
	SortTask()
	BP_CorpsTaskCurrentOperateTaskId = taskId
	LuaClassObj.HandleUIMessage(bp_corps_task, "UpdatePanel")
end

function CorpsTaskUI.ActivenessGetAward(awardId, itemList)
	CommonItemGetUI:ShowPanel(itemList)
	CorpsTaskUI.RefreshAwradInfo()
	BP_CorpsTaskCurrentOperateAwardId = awardId
	-- LuaClassObj.HandleUIMessage(bp_corps_task, "UpdateActiveness")
end


function EventCorpsTaskGetActivenessReward_Push()
	local activenessInfo = DataMgr.corpsActiveness.list[BP_CorpsTaskCurrentOperateAwardId]
	if activenessInfo == nil then
		log("[ERROR : activeness not found ID ]" .. BP_CorpsTaskCurrentOperateAwardId)
		return
	end
	if activenessInfo.status == AwardState["AWARDED"] then
		ShowNotice(108013)
		return
	end
	CorpsMgr.ActivenessGetAwardReq(BP_CorpsTaskCurrentOperateAwardId)
end

function EventCorpsTaskGetReward_Push()
	local taskInfo = DataMgr.corpsTaskData.list[BP_CorpsTaskCurrentOperateTaskId]
	if taskInfo == nil then
		log("[ERROR : task not found ID ]" .. BP_CorpsTaskCurrentOperateTaskId)
		return
	end
	if taskInfo.status == TaskState["AWARDED"] then
		ShowNotice(108013)
		return
	end
	CorpsMgr.TaskGetAwardReq(BP_CorpsTaskCurrentOperateTaskId)
end

function EventCorpsTaskShowRewardDetailPopup_Push()
	log("$$EventCorpsTaskShowRewardDetailPopup_Push")
	local  dropID = 1
	local titleStr = ""

	for _,activenessInfo in pairs(BP_ARRAY_CorpsTaskActiveAwardInfos)  do
		if activenessInfo.id == BP_CorpsTaskCurrentOperateAwardId then
			local tbActiveInfo = Client.GetTableData("CorpsTaskActive" , activenessInfo.tableID)
			if tbActiveInfo == nil then
				log("[ERROR : CorpsTaskActive not found ID ]" .. activenessInfo.tableID)
				return
			end

			dropID = tbActiveInfo.DropID
			titleStr = tbActiveInfo.BoxTitleName
		break
		end
	end
	-- local tableAwardInfo = Client.GetTableData("CorpsTaskActive", BP_CorpsTaskCurrentOperateAwardId)
	CommonTreasureBoxPopup:showPanelByDropId(dropID)
	CommonTreasureBoxPopup:SetTitleString(Client.GetTableData("LocalizeRes", titleStr).TextValue)
end

function EventCorpsTaskGenTaskRewardData_Push()
	local tableTaskInfo = Client.GetTableData("CorpsTask", BP_CorpsTaskCurrentOperateTaskId)
	if tableTaskInfo == nil then
		log("task table data not found - taskId: " .. BP_CorpsTaskCurrentOperateTaskId)
		return
	end
	-- log("$$EventCorpsTaskGenTaskRewardData_Push" .. tableTaskInfo.DropID)
    local drop_util = require("client.common.drop_util")
	BP_ARRAY_CorpsTaskCurrDropList = drop_util.GetDropsList({tableTaskInfo.DropID})
end

function EventCorpsTaskGoTo_Push()
	local tableTaskInfo = Client.GetTableData("CorpsTask", BP_CorpsTaskCurrentOperateTaskId)
	if tableTaskInfo == nil then
		log("task table data not found - taskId: " .. BP_CorpsTaskCurrentOperateTaskId)
		return
	end
	GlobalData:JumpUrl(tableTaskInfo.JumpTo)
end

function EventCorpsTaskClickAwarded_Push()
	ShowNotice(108013)
end

function CorpsTaskUI.ShowUI()
	-- log("CorpsTaskUI.ShowUI")
	CorpsTaskUI.isShow = true
	LuaClassObj.HandleDynamicCreation(bp_corps_task)
	CorpsTaskUI.RefreshTaskInfo()
	CorpsTaskUI.RefreshAwradInfo()
	LuaClassObj.HandleUIMessage(bp_corps_task, "ShowUI")

	ClientSendBAReport(BP_BA_CORPS_TASK, 0);
end

function CorpsTaskUI.CloseUI()
	-- log("CorpsTaskUI.CloseUI")
	CorpsTaskUI.isShow = false
	LuaClassObj.HandleUIMessage(bp_corps_task, "CloseUI")
end