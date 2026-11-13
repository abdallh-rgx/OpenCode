--开黑豪礼-邀请列表

RefluxTrainingListUI = RefluxTrainingListUI or 
{
	isShow = false;

	YouInvitedPanel = 1, -- 你邀请的人
	InvitedYouPanel = 2, -- 邀请你的人
}

BP_RefluxTrainingListData = 
{
	uid = "",
	name = "",
	segmentLebel = 0,
	sex = 0,
	iconUrl = "",
	iconBoxID = 0,
	level =0,
	online = 0,
	teamState = 0,
	currentTeamCount = 0,
	maxTeamCount = 0,
}

BP_ARRAY_BP_RefluxTrainingListDataList = 
{
	BP_RefluxTrainingListData = _G.BP_RefluxTrainingListData
}

BP_RefluxTrainingListCurrentID = ""

BP_RefluxTrainingListCurrentPanelIndex = RefluxTrainingListUI.YouInvitedPanel

function bp_reflux_training_list_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_reflux_training_list,
		{{Path="/Game/UMG/UI_Logic/RefluxTraining/RefluxTrainingPlayerList_BP.RefluxTrainingPlayerList_BP_C", Container="Default", ZOrder=BP_ENUM_UI_REFLUX_TRAINING_AWARD_ZORDER}},
		{"Lobby"},
		false,		
		false,
		false
	);

end	

function RefluxTrainingListUI.ShowUI(panelIndex, uidList)
	--profile数据是异步的，需要先打开界面再更新数据
	log("[HHF]RefluxTrainingListUI.ShowUI, panelIndex = " .. panelIndex .. ", uidList.num = " .. FuncUtil:CountTable(uidList));
	BP_RefluxTrainingListCurrentPanelIndex = panelIndex
	RefluxTrainingListUI.isOpen = true
	LuaClassObj.HandleUIMessage(bp_reflux_training_list, "UIShow");
	RefluxMgr.GetProfileList(uidList , RefluxTrainingListUI.OnGetListProfileDataDone)
end

function RefluxTrainingListUI.OnGetListProfileDataDone(role_basic_info_list)
	log("[HHF]RefluxTrainingListUI.OnGetListProfileDataDone, role_basic_info_list.num = " .. FuncUtil:CountTable(role_basic_info_list));
	--log_tree("[HHFTEST]RefluxTrainingListUI.OnGetListProfileDataDone, role_basic_info_list = ", role_basic_info_list, "[HHFTEST]");
	RefluxTrainingListUI.InitDataList(role_basic_info_list)

	if RefluxTrainingListUI.isOpen then 
		RefluxTrainingListUI.UpdatePanel()
	end
end

function RefluxTrainingListUI.InitDataList(role_basic_info_list)
	log("[HHF]RefluxTrainingListUI.InitDataList, role_basic_info_list.num = " .. FuncUtil:CountTable(role_basic_info_list));
	BP_ARRAY_BP_RefluxTrainingListDataList = {}
	for k, v in pairs(role_basic_info_list) do
		local profileData = {}
		profileData.uid = tostring(math.floor(v.uid))
		profileData.name = v.nickName
		profileData.segmentLebel = v.cur_max_segment_level
		profileData.sex = v.sex
		profileData.iconUrl = v.picUrl
		profileData.iconBoxID = v.cur_avatar_box_id
		profileData.level = v.level
		profileData.online = v.online
		profileData.teamState = v.teamState
		profileData.currentTeamCount = v.currentTeamAmount
		profileData.maxTeamCount = v.maxTeamAmount

		table.insert(BP_ARRAY_BP_RefluxTrainingListDataList, profileData);  
	end
end

function RefluxTrainingListUI.UpdatePanel()
	log("[HHF]RefluxTrainingListUI.UpdatePanel");
	LuaClassObj.HandleUIMessage(bp_reflux_training_list, "UpdatePanel");
end

function RefluxTrainingListUI.CloseUI()
	log("[HHF]RefluxTrainingListUI.CloseUI");
	RefluxTrainingListUI.isOpen = false
	LuaClassObj.HandleUIMessage(bp_reflux_training_list, "UIClose");
end

function EventRefluxTrainingListUIClose()
	log("[HHF]EventRefluxTrainingListUIClose");
	RefluxTrainingListUI.CloseUI()
end

function RefluxTrainingListUI.Release()
	log("[HHF]RefluxTrainingListUI.Release");
end


function EventRefluxTrainingListInviteButtonClicked()
	log("[HHF]EventRefluxTrainingListInviteButtonClicked, CurrentID = " .. tostring(BP_RefluxTrainingListCurrentID));
	TeamUpSystem.team_invite_request(tonumber(BP_RefluxTrainingListCurrentID));
end

function EventRefluxTrainingListJoinButtonClicked()
	log("[HHF]EventRefluxTrainingListJoinButtonClicked, CurrentID = " .. tostring(BP_RefluxTrainingListCurrentID));	
	TeamUpSystem.team_apply_request(tonumber(BP_RefluxTrainingListCurrentID));
end

function EventRefluxTrainingListHeadIconClicked()
	log("[HHF]EventRefluxTrainingListHeadIconClicked, currentID = " .. tostring(BP_RefluxTrainingListCurrentID));
	RoleInfoSystem.Enter(BP_RefluxTrainingListCurrentID);
	RoleInfoUI.Init();

	ProfileMgr.GetProfile(tostring(BP_RefluxTrainingListCurrentID), RefluxTrainingListUI.OnItemChange, true);
end

function RefluxTrainingListUI.OnItemChange(list)
	log("[HHF]RefluxTrainingListUI.OnItemChange, list.num = " .. FuncUtil:CountTable(list));
	-- log("AllianceRecruitUIOnRecruitItemChange");
	-- local listCount = #list;
	-- if listCount > 0 then
	-- 	local profile = list[1];
	-- 	for i=1, #_Alliance_RecruitList do
	-- 		local v = _Alliance_RecruitList[i];
	-- 		if tostring(profile.uid) == tostring(v.gid) then
	-- 			v = AllianceRecruitUI.CopyBaseInfo(v, profile);
	-- 			BP_Alliance_UpdateInnerIndex = i-1;
	-- 			log("AllianceRecruitUI.OnRecruitItemChange BP_Alliance_UpdateInnerIndex = " .. BP_Alliance_UpdateInnerIndex);
	-- 			LuaClassObj.HandleUIMessage(bp_alliance_recruit, "UpdateRecruitOneSync");
	-- 		end
	-- 	end
	-- end
end