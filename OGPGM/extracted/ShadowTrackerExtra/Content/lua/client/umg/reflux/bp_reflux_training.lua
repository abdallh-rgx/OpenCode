RefluxTrainingUI = RefluxTrainingUI or {
	isOpen = false,

	invitedYouList = {},
	youInvitedList = {},

	RefluxPanel = 1,
	OfficerTrainingPanel = 2,
}


BP_RefluxTrainingUI_Checkbox_ID = 0
local curId = 0
local OpenList = 
{
	[1] = {nil,nil}, -- 召回界面
	[2] = {nil,nil}, -- 任务界面
}

BP_RefluxTrainingUI_InvitedYouCount = 0
BP_RefluxTrainingUI_YouInvitedCount = 0

--注册Widget
function bp_reflux_training_RegisterUI()
  LuaClassObj.SubUIWidgetList(bp_reflux_training,
    {{Path="/Game/UMG/UI_Logic/RefluxTraining/RefluxTraining_BP.RefluxTraining_BP_C", Container="Default", ZOrder=BP_ENUM_UI_REFLUX_TRAINING_ZORDER}},
    {"Lobby"},
	false,
	false,
	false
  );
	
  	-- EventSystem:registEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_CORPS_ID, CorpsUI.OnReceivedJoinCorps)
  	EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_CALLBACK, RefluxTrainingUI.JumpUrl)
end

function RefluxTrainingUI.RegisterPanelEvent(index , openFuction, closeFunction)
	if index <= #OpenList then
		OpenList[index][1] = openFuction
		OpenList[index][2] = closeFunction
	end
end

function RefluxTrainingUI.JumpUrl(type, moduleID, params)
	log("[HHF]RefluxTrainingUI.JumpUrl, type = " .. tostring(type) .. ", moduleID = " .. tostring(moduleID) .. ", params = " .. tostring(params));
	local strRegion = Client.GetPublishRegion();
	if strRegion == "GLOBAL" then
		local idStr = params["id"];
		if idStr ~= nil then
			local id = tonumber(idStr);
			RefluxTrainingUI.InitByPanel(id);
		else
			RefluxTrainingUI.Init()
		end
	else
		log("[HHF]RefluxTrainingUI.JumpUrl, Region = " .. tostring(strRegion));
	end
end

function RefluxTrainingUI.InitByPanel(index)
	log("[HHF]RefluxTrainingUI.InitByPanel, index = " .. tostring(index));
	RefluxTrainingUI.isOpen = true
	LuaClassObj.HandleDynamicCreation(bp_reflux_training);
	LuaClassObj.HandleUIMessage(bp_reflux_training, "UIShow");

	RefluxTrainingUI.OpenPanel(index)
end

function RefluxTrainingUI.OpenPanel(index)
	log("[HHF]RefluxTrainingUI.OpenPanel, index = " .. index);
	--log_tree("[HHFTEST]RefluxTrainingUI.OpenPanel, OpenList = ", OpenList, "[HHFTEST]")
	curId = index
	if OpenList[curId][1] ~= nil then
		OpenList[curId][1]()
	else
		log("[HHF]RefluxTrainingUI.OpenPanel, OpenList[" .. curId .. "][1] = nil");
	end
end

function RefluxTrainingUI.ClosePanel()
	log("[HHF]RefluxTrainingUI.ClosePanel");
	--[[if curId ~= 0 then
		if OpenList[curId][2] ~= nil then
			OpenList[curId][2]()
		end
	end--]]

	if OpenList[1][2] ~= nil then
		OpenList[1][2]()
	end

	if OpenList[2][2] ~= nil then
		OpenList[2][2]()
	end
end

function RefluxTrainingUI.Init()
	log("[HHF]RefluxTrainingUI.Init");
	RefluxTrainingUI.InitByPanel(RefluxTrainingUI.RefluxPanel)
	RefluxTrainingUI.UpdateRedPoint();
end

function RefluxTrainingUI.UpdateRedPoint()
	-- BP_CorpsUI_Has_New_IvitedCorps = CorpsMgr.HasRedDot("invited_corps");
	-- LuaClassObj.HandleUIMessageNoFetch("UpdateRedPoint");
end

function RefluxTrainingUI.Release()
	log("[HHF]RefluxTrainingUI.Release");
end

function RefluxTrainingUI.RecordListData(num, recall_list)
	log("[HHF]RefluxTrainingUI.RecordListData")
	--RefluxTrainingUI.invitedYouList = invite_list
	RefluxTrainingUI.youInvitedList = recall_list

	--BP_RefluxTrainingUI_InvitedYouCount = #invite_list
	BP_RefluxTrainingUI_YouInvitedCount = num;
	LuaClassObj.HandleUIMessage(bp_reflux_training, "UpdatePanel");
end

function EventRefluxTrainingUIClickToggle_Push()
	log("[HHF]EventRefluxTrainingUIClickToggle_Push, checkbox_ID = " .. tostring(BP_RefluxTrainingUI_Checkbox_ID));
	RefluxTrainingUI.ClosePanel()
	RefluxTrainingUI.OpenPanel(BP_RefluxTrainingUI_Checkbox_ID)
end

--关闭界面
function EventOnRefluxTrainingUIClose()
	log("[HHF]EventOnRefluxTrainingUIClose");

	RefluxTrainingUI.isOpen = false
    RefluxTrainingUI.Release()
	RefluxTrainingUI.ClosePanel()
	curId = 0
	LuaClassObj.HandleUIMessage(bp_reflux_training, "UIClose");
end

function EventRefluxTrainingUIClickedInvitedYouButton()
	log("[HHF]EventRefluxTrainingUIClickedInvitedYouButton")
	RefluxTrainingListUI.ShowUI(RefluxTrainingListUI.InvitedYouPanel, RefluxTrainingUI.invitedYouList)
end

function EventRefluxTrainingUIClickedYouInvitedButton()
	log("[HHF]EventRefluxTrainingUIClickedYouInvitedButton")
	RefluxTrainingListUI.ShowUI(RefluxTrainingListUI.YouInvitedPanel, RefluxTrainingUI.youInvitedList)
end
