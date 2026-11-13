-- 军团训练营UI
OfficerTrainingUI = OfficerTrainingUI or 
{
	isShow = false,
	HaveClickOpen = false,
}

-- 当前任务列表
BP_STRUCT_OfficerTrainingInfo = {
	id = 0,
	progress = 0,
	sort = 0,
}

BP_ARRAY_OfficerTrainingInfos = {
	BP_STRUCT_OfficerTrainingInfo = BP_STRUCT_OfficerTrainingInfo
}

-- 宝箱信息
BP_STRUCT_OfficerTrainingBoxInfo = {
	id = 0,
	status = "",
	first = 0, -- 0  首次拉取 1非首次拉取
	sort = 0,
}

BP_ARRAY_OfficerTrainingBoxInfos = {
	BP_STRUCT_OfficerTrainingBoxInfo = BP_STRUCT_OfficerTrainingBoxInfo
}

-- 用于同步lua参数
BP_CurrentOperateOfficerTrainingId = 0
BP_CurrentOperateOfficerTrainingBoxId = 0

BP_OfficerTrainingTipsString = ""

local m_ruleTitleStr = ""
local m_ruleContentStr = ""

BP_OfficerTrainingItemCount = 0


--注册Widget
function bp_officer_training_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_officer_training,
		{{Path="/Game/UMG/UI_Logic/OfficerTraining/OfficerTraining_BP.OfficerTraining_BP_C", Container="Default", ZOrder=BP_ENUM_UI_REFLUX_TRAINING_ZORDER + 1}},
		{"Lobby"},
		false,
		false,
		true
	);
	BP_ARRAY_OfficerTrainingInfos = {}
	BP_ARRAY_OfficerTrainingBoxInfos = {}

	EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MUDULE_OFFICER_TRAINING, OfficerTrainingUI.OnOpenUrl);
	-- EventSystem:registEvent(EVENTTYPE_DATA_MGR, BP_ENUM_MUDULE_OFFICER_TRAINING, TaskUI.RefreshAwradInfo)
	RefluxTrainingUI.RegisterPanelEvent(RefluxTrainingUI.OfficerTrainingPanel , OfficerTrainingUI.ShowUI, OfficerTrainingUI.HideUI)
end

function OfficerTrainingUI.ShowUI()
	log("[HHF]OfficerTrainingUI.ShowUI")
	OfficerTrainingUI.HaveClickOpen = true;
	OfficerTrainingSystem.ClickedOpenDataUpload() --数据收集

	local activityData = DataMgr.GetActivityByType(ActivityType.FRIEND_RECALL) 
	if activityData then
		BP_OfficerTrainingTipsString = activityData.Desc --string.format(HELP_TEXT, PlatFormStr[BP_Platform], PlatFormStr[BP_Platform]) 
		m_ruleTitleStr = activityData.Title
		m_ruleContentStr = activityData.Detail
	else
		log("[HHF]OfficerTrainingUI.ShowUI, could not found activityData by type = " .. ActivityType.FRIEND_RECALL)
	end

	OfficerTrainingUI.GetItemCount()
	OfficerTrainingSystem.GetData(OfficerTrainingUI.OnDataReceivedDone)
end

function OfficerTrainingUI.GetItemCount()
	local count = 0
	local itemData = DataMgr.GetHallDepotItemDataByResID(1602034)
	if itemData ~= nil then
		count = itemData.count
	else
		log("[HHF]OfficerTrainingUI.GetItemCount, could not found item id = 1602034")
	end
	BP_OfficerTrainingItemCount = count
	log("[HHF]OfficerTrainingUI.GetItemCount, BP_OfficerTrainingItemCount = " .. BP_OfficerTrainingItemCount)
end

function OfficerTrainingUI.OnDataReceivedDone()
	log("[HHF]OfficerTrainingUI.OnDataReceivedDone")
	if OfficerTrainingUI.HaveClickOpen == true then
		OfficerTrainingUI.HaveClickOpen = false;
		OfficerTrainingUI.isShow = true
		LuaClassObj.HandleDynamicCreation(bp_officer_training);
		LuaClassObj.HandleUIMessage(bp_officer_training, "ShowUI")
	end
end

function OfficerTrainingUI.UpdateOneTask(index)
	log("[HHF]OfficerTrainingUI.UpdateOneTask, index = " .. index)
	BP_CurrentOperateOfficerTrainingId = index - 1
	OfficerTrainingUI.GetItemCount()
	LuaClassObj.HandleUIMessage(bp_officer_training, "UpdateOneTask")
end

function OfficerTrainingUI.ActivenessGetAward(awardId, itemList)
	log("[HHF]OfficerTrainingUI.ActivenessGetAward, awardId = " .. awardId .. ", itemList.num = " .. FuncUtil:CountTable(itemList))
	CommonItemGetUI:ShowPanelWithCallback(itemList, OfficerTrainingUI.OnAwardGot, false)
	BP_CurrentOperateAwardId = awardId
end

function OfficerTrainingUI.OnAwardGot()
	log("[HHF]OfficerTrainingUI.OnAwardGot")
	OfficerTrainingSystem.GetData(OfficerTrainingUI.OnUpdateDataDone)
end

function OfficerTrainingUI.OnUpdateDataDone()
	log("[HHF]OfficerTrainingUI.OnUpdateDataDone")
	OfficerTrainingUI.GetItemCount()
	LuaClassObj.HandleUIMessage(bp_officer_training, "UpdatePanel")
end

function OfficerTrainingUI.HideUI()
	log("[HHF]OfficerTrainingUI.HideUI")
	OfficerTrainingUI.HaveClickOpen = false;
	OfficerTrainingUI.isShow = false
	LuaClassObj.HandleUIMessage(bp_officer_training, "CloseUI")
end

function EventOfficerTrainingUIClose()
	log("[HHF]EventOfficerTrainingUIClose")
	OfficerTrainingUI.HideUI()
end

function EventOfficerTrainingOnGetAward()
	log("[HHF]EventOfficerTrainingOnGetAward")
	OfficerTrainingSystem.GetAwardReq(BP_CurrentOperateOfficerTrainingBoxId)
end

function EventOfficerTrainingOnGotAward()
	-- ShowNotice(108013)
end

--显示箱子详情
function EventOfficerTrainingOnShowAward()
	log("[HHF]EventOfficerTrainingOnShowAward, boxid = " .. BP_CurrentOperateOfficerTrainingBoxId)
	local taskInfo = Client.GetTableData("FriendCallbackTask", BP_CurrentOperateOfficerTrainingBoxId)
	if taskInfo == nil  then
		log("[HHF]EventOfficerTrainingOnShowAward, GetTableData = nil by id = " .. BP_CurrentOperateOfficerTrainingBoxId)
		return 
	end

	local tableAwardInfo = Client.GetTableData("FriendCallbackTaskAward", taskInfo.TreasureID)
	if tableAwardInfo == nil then 
		log("[HHF]EventOfficerTrainingOnShowAward, GetTableData = nil by id = " .. taskInfo.TreasureID)
		return 
	end

	CommonTreasureBoxPopup:showPanelByDropId(tableAwardInfo.DropID)
	CommonTreasureBoxPopup:SetTitleString(Client.GetTableData("LocalizeRes", tableAwardInfo.BoxTitleName).TextValue)
end

function OfficerTrainingUI.OnOpenUrl()
	log("[HHF]OfficerTrainingUI.OnOpenUrl")
	if OfficerTrainingUI.isShow == false then
		OfficerTrainingUI.ShowUI()
	else
	end
end

function EventOfficerTrainingOnRuleBtnClicked()
	log("[HHF]EventOfficerTrainingOnRuleBtnClicked")
	PopUpNoticeUI.ShowMessageBox(m_ruleTitleStr,m_ruleContentStr)
end

function EventOfficerTrainingOnChangeTaskClicked()
	log("[HHF]EventOfficerTrainingOnChangeTaskClicked, itemcount = " .. BP_OfficerTrainingItemCount)
	if BP_OfficerTrainingItemCount > 0 then
		OfficerTrainingSystem.ChangeTask();
	else
		ShowNotice(4716);
	end
end