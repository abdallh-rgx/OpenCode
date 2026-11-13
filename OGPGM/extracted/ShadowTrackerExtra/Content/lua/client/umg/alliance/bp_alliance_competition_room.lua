--[[
	战队赛房间UI
--]]

-- BP_STRUCT_AllianceCompetitionRoom_MatchingTime = 0

AllianceCompetitionRoomUI = AllianceCompetitionRoomUI or {}
AllianceCompetitionRoomUI.isShowing = false

BP_AllianceCompetition_IsMatching = false

-- 队员信息缓存，用于更新位置信息，服务端数据
AllianceCompetitionRoomUI.memberInfos = {}

-- 位置坐标索引
BP_STRUCT_AllianceCompetitionRoom_Pos_Index = 0
-- 位置是否有人
BP_STRUCT_AllianceCompetitionRoom_Pos_Index_Filled = false

BP_STRUCT_AllianceCompetitionRoom_PlayerInfo = {
	player_id = "",
	name = "",
	iconUrl = "",
	frame_level = 0,
	isLeader = true,
}

BP_STRUCT_AllianceCompetitionRoom_BaseInfo = {
	title = "海选赛",
	tip = "第一轮已经开启",
	teamName = "战队名字",
	roundTxt = "第一轮",
	modTxt = "第三人称",
	areaTxt = "北美",

	OperationKickStr = "踢出房间",
	OperationChangeHostStr = "转让房主",

	GuidonUrl = ""
}

-- 位置上的实际信息, 存放类型为BP_STRUCT_AllianceCompetitionRoom_PlayerInfo
AllianceCompetitionRoomUI.posInfo = {}

-- 当前头像信息
BP_STRUCT_AllianceCompetitionRoom_Curernt_TeamUpMenuInfo = _G.BP_STRUCT_AllianceCompetitionRoom_PlayerInfo

-- 被操作人员ID
BP_STRUCT_AllianceCompetitionRoom_OperateId = ""

AllianceCompetitionRoomUI.POS_MAX_COUNT = 4
AllianceCompetitionRoomUI.CAN_STATRT_COUNT = 2

--注册Widget
function bp_alliance_competition_room_RegisterUI()
	-- BP_ENUM_UI_ALLIANCE_ZORDER + 2
	LuaClassObj.SubUIWidgetList(bp_alliance_competition_room,
		{
			{Path="/Game/UMG/UI_Logic/Lobby_Team/LobbyTeam_Competition_Room_LogicBP.LobbyTeam_Competition_Room_LogicBP_C", Container="Default", ZOrder=45},
		},
		{"Lobby"},
		false,
		false,
		true
	);
end

function AllianceCompetitionRoomUI.Show()
	if AllianceCompetitionRoomUI.isShowing == false then
		AllianceCompetitionRoomUI.isShowing = true

		BP_AllianceCompetition_IsMatching = false

		LuaClassObj.HandleDynamicCreation(bp_alliance_competition_room)
		LuaClassObj.HandleUIMessageNoFetch(bp_alliance_competition_room, "UIShow")

		AllianceCompetitionRoomUI.InitUI()
		AllianceCompetitionRoomUI.UpdateAllPos()
	end

	AllianceCompetitionSystem.FormatCompetitionData()
	AllianceCompetitionRoomUI.UpdateUI()
	AllianceCompetitionRoomUI.UpdateMembers()
end

function AllianceCompetitionRoomUI.Hide()
	if AllianceCompetitionRoomUI.isShowing == false then
		return
	end

	AllianceCompetitionRoomUI.isShowing = false
	LuaClassObj.HandleUIMessageNoFetch(bp_alliance_competition_room, "UIHide")
end

function AllianceCompetitionRoomUI.CheckToQuick()
	if AllianceCompetitionRoomUI.isShowing == false then return end
	
	AllianceCompetitionSystem.FormatCompetitionData()
	AllianceCompetitionSystem.log("AllianceCompetitionSystem.FirstStepID "..AllianceCompetitionSystem.FirstStepID)
	if AllianceCompetitionSystem.FirstStepID ~= AllianceCompetitionSystem.FirstStep.FIRST_MATCH then
		AllianceCompetitionSystem.log("auto quick room")
		AllianceCompetitionSystemHandler.reqQuickRoom()
		return
	end

	AllianceCompetitionRoomUI.UpdateUI()
end

function AllianceCompetitionRoomUI.InitUI()
	AllianceCompetitionSystem.log(AllianceCompetitionRoomUI.POS_MAX_COUNT)
	AllianceCompetitionRoomUI.memberInfos = {}
	AllianceCompetitionRoomUI.posInfo = {}

	for i = 1, AllianceCompetitionRoomUI.POS_MAX_COUNT do
		AllianceCompetitionRoomUI.posInfo[i] = 0
	end
end

function AllianceCompetitionRoomUI.UpdateUI()
	BP_STRUCT_AllianceCompetitionRoom_BaseInfo.teamName = BP_STRUCT_AllianceInfo.name
	BP_STRUCT_AllianceCompetitionRoom_BaseInfo.title = AllianceCompetitionSystem.getStageName(AllianceCompetitionSystem.FirstStep.FIRST_MATCH)
	BP_STRUCT_AllianceCompetitionRoom_BaseInfo.tip = AllianceCompetitionSystem.getRoomTip()
	BP_STRUCT_AllianceCompetitionRoom_BaseInfo.roundTxt = AllianceCompetitionSystem.getRoundName(AllianceCompetitionSystem.ThirdStepID)
	BP_STRUCT_AllianceCompetitionRoom_BaseInfo.modTxt = AllianceCompetitionSystem.getMyModeName()
	BP_STRUCT_AllianceCompetitionRoom_BaseInfo.areaTxt = AllianceCompetitionSystem.getMyAreaName()

	BP_STRUCT_AllianceCompetitionRoom_BaseInfo.OperationKickStr = Client.GetTableData("LocalizeRes",6228).TextValue
	BP_STRUCT_AllianceCompetitionRoom_BaseInfo.OperationChangeHostStr = Client.GetTableData("LocalizeRes",6229).TextValue

	BP_STRUCT_AllianceCompetitionRoom_BaseInfo.GuidonUrl = AllianceCompetitionSystem.getGuidonUrl()
	-- 更新通用UI信息
	LuaClassObj.HandleUIMessageNoFetch(bp_alliance_competition_room, "UpdatePanel")
end

-- 刷新所有位置
function AllianceCompetitionRoomUI.UpdateAllPos()
	-- 更新队长
	for i = 1, AllianceCompetitionRoomUI.POS_MAX_COUNT do
		local pinfo = AllianceCompetitionRoomUI.posInfo[i]
		if pinfo ~= 0 then
			local pid = pinfo.player_id
			AllianceCompetitionSystem.log("pid "..pid)
			pinfo.isLeader = (pid == tostring(TeamUpSystem.TeamInfo.leader))
		end
	end

	-- 更新UI布局
	for i = 1, AllianceCompetitionRoomUI.POS_MAX_COUNT do
		AllianceCompetitionRoomUI.UpdatePosByIndex(i)
	end
end

-- 通过index更新位置UI
function AllianceCompetitionRoomUI.UpdatePosByIndex(index)
	BP_STRUCT_AllianceCompetitionRoom_Pos_Index = index

	-- 更新位置是否有人
	EventAllianceCompetitionRoomPosHasPlayer()

	if AllianceCompetitionRoomUI.posInfo[index] == 0 then
		-- 设置空UI
	else
		EventAllianceCompetitionRoomGetPosPlayer()
		-- 设置实际UI
	end

	LuaClassObj.HandleUIMessageNoFetch(bp_alliance_competition_room, "UpdatePlayer")
end

-- 更新成员位置
function AllianceCompetitionRoomUI.UpdateMembers()
	if AllianceCompetitionRoomUI.isShowing == false then
		return
	end

	local oldMembers = AllianceCompetitionRoomUI.memberInfos
	local newMembers = TeamUpSystem.TeamInfo.members
	local addMembersIds = {}

	log_tree("oldMembers",oldMembers)
	log_tree("newMembers",newMembers)

	-- 容错，兼容有可能在玩家A锁屏后，玩家BCD没有收到取消匹配情况
	local membersHasChanged = false

	-- 处理离线玩家
	for id,info in pairs(oldMembers) do
		if newMembers[id] == nil then
			AllianceCompetitionRoomUI.removeMember(id)
			membersHasChanged = true
		end
	end

	-- 处理加入玩家
	for id,info in pairs(newMembers) do
		if oldMembers[id] == nil then
			AllianceCompetitionRoomUI.AddMember(id)
			table.insert(addMembersIds, id)
			membersHasChanged = true
		end
	end

	-- 替换玩家信息
	AllianceCompetitionRoomUI.memberInfos = newMembers

	log_tree("addMembersIds",addMembersIds)
	if #addMembersIds == 0 then
		log_tree("AllianceCompetitionRoomUI.posInfo",AllianceCompetitionRoomUI.posInfo)
		AllianceCompetitionRoomUI.UpdateAllPos()
	else
		ProfileMgr.GetProfileList(addMembersIds,AllianceCompetitionRoomUI.OngetProfiles)
	end

	if AllianceCompetitionRoomUI._getMemberCount() < AllianceCompetitionRoomUI.CAN_STATRT_COUNT then
		LuaClassObj.HandleUIMessageNoFetch(bp_alliance_competition_room, "SetEnterDisable")
	else
		LuaClassObj.HandleUIMessageNoFetch(bp_alliance_competition_room, "SetEnterEnable")
	end

	-- 容错，兼容有可能在玩家A锁屏后，玩家BCD没有收到取消匹配情况
	if membersHasChanged == true and BP_AllianceCompetition_IsMatching == true then
		AllianceCompetitionRoomUI.onCancel()
		AllianceCompetitionSystemHandler.reqQuickRoom()
	end
end

function AllianceCompetitionRoomUI.OngetProfiles(profiles)
	log_tree("AllianceCompetitionRoomUI.posInfo",AllianceCompetitionRoomUI.posInfo)
	log_tree("profiles",profiles)
	for i,pf in ipairs(profiles) do
		local pid = tostring(pf.uid)

		for i = 1, AllianceCompetitionRoomUI.POS_MAX_COUNT do
			local pinfo = AllianceCompetitionRoomUI.posInfo[i]
			if pinfo ~= 0 then
				local posId = AllianceCompetitionRoomUI.posInfo[i].player_id
				if pid == tostring(posId) then
					local info = {}

					-- 在这里搞一下info
					info.player_id = pid
					info.name = pf.nickName
					info.iconUrl =  pf.picUrl
					info.isLeader = (pid == tostring(TeamUpSystem.TeamInfo.leader))
					info.frame_level = pf.cur_avatar_box_id

					AllianceCompetitionRoomUI.posInfo[i] = info
				end
			end
		end
	end
	
	log_tree("AllianceCompetitionRoomUI.posInfo",AllianceCompetitionRoomUI.posInfo)
	AllianceCompetitionRoomUI.UpdateAllPos()
end

-- 成员加入房间
function AllianceCompetitionRoomUI.AddMember(playerId)
	local index = 0
	for i = 1, AllianceCompetitionRoomUI.POS_MAX_COUNT do
		if AllianceCompetitionRoomUI.posInfo[i] == 0 then
			index = i
			local a={}
			a.player_id = playerId
			AllianceCompetitionRoomUI.posInfo[i] = a
			break
		end
	end
end

-- 成员退出房间
function AllianceCompetitionRoomUI.removeMember(playerId)
	local index = 0

	for i = 1, AllianceCompetitionRoomUI.POS_MAX_COUNT do
		local teamInfo = AllianceCompetitionRoomUI.posInfo[i]
		if teamInfo ~= 0 then
			if tonumber(teamInfo.player_id) == tonumber(playerId) then
				AllianceCompetitionRoomUI.posInfo[i] = 0
				index = i
				break
			end
		end
	end
end

-- 获取当前参与人数
function AllianceCompetitionRoomUI._getMemberCount()
	local count = 0
	for i = 1, AllianceCompetitionRoomUI.POS_MAX_COUNT do
		if AllianceCompetitionRoomUI.posInfo[i] ~= 0 then
			count = count + 1
		end
	end

	return count
end

-- 通过位置后去判断位置是否有人
function EventAllianceCompetitionRoomPosHasPlayer()
	AllianceCompetitionSystem.log("EventAllianceCompetitionRoomHasPlayer "..BP_STRUCT_AllianceCompetitionRoom_Pos_Index)

	if AllianceCompetitionRoomUI.posInfo[BP_STRUCT_AllianceCompetitionRoom_Pos_Index] == 0 then
		BP_STRUCT_AllianceCompetitionRoom_Pos_Index_Filled = false
		log("false")
	else
		BP_STRUCT_AllianceCompetitionRoom_Pos_Index_Filled = true
		log("true")
	end
end

-- 通过位置获取player信息
function EventAllianceCompetitionRoomGetPosPlayer()
	AllianceCompetitionSystem.log("EventAllianceCompetitionRoomHasPlayer "..BP_STRUCT_AllianceCompetitionRoom_Pos_Index)
	AllianceCompetitionSystem.log_tree("BP_STRUCT_AllianceCompetitionRoom_Curernt_TeamUpMenuInfo ",BP_STRUCT_AllianceCompetitionRoom_Curernt_TeamUpMenuInfo)
	BP_STRUCT_AllianceCompetitionRoom_Curernt_TeamUpMenuInfo = AllianceCompetitionRoomUI.posInfo[BP_STRUCT_AllianceCompetitionRoom_Pos_Index]
end

-- 点击开始按钮
function EventAllianceCompetitionClickStart()
	if AllianceCompetitionRoomUI.isLeader() == false then
		DataMgr.ShowNoticeByID(6242)
		return 
	end

	AllianceCompetitionSystem.log("EventAllianceCompetitionClickStart")
 	NetUtil.SendPkg("league_match_req", AllianceCompetitionSystem.Mode, false, {AllianceCompetitionSystem.SubMode})
end

-- 正式开始匹配处理
function AllianceCompetitionRoomUI.onStartMatch()
	BP_AllianceCompetition_IsMatching = true

	LuaClassObj.HandleUIMessageNoFetch(bp_alliance_competition_room, "StopCountdown")--容错处理

	LuaClassObj.HandleUIMessageNoFetch(bp_alliance_competition_room, "StartCountdown")
end

-- 点击取消按钮
function EventAllianceCompetitionClickCancel()
	if AllianceCompetitionRoomUI.isLeader() == false then 
		DataMgr.ShowNoticeByID(6271)
		return 
	end

	AllianceCompetitionSystem.log("EventAllianceCompetitionClickCancel")
	LobbySystem.on_match_cancel_req()
end

-- 取消回调
function AllianceCompetitionRoomUI.onCancel()
	if AllianceCompetitionRoomUI.isShowing == false then
		return
	end
	
	BP_AllianceCompetition_IsMatching = false
	LuaClassObj.HandleUIMessageNoFetch(bp_alliance_competition_room, "StopCountdown")
end

-- 点击关闭按钮
function EventAllianceCompetitionClickCloseBtn()
	if BP_AllianceCompetition_IsMatching == true then 
		DataMgr.ShowNoticeByID(6244)
		return 
	end
	
	local text = ""
	if AllianceCompetitionRoomUI._getMemberCount() > 1 then
		text = FuncUtil.GetLocalizeResStr("6238")
	else
		text = FuncUtil.GetLocalizeResStr("6239")
	end

	CommonMessageBoxUI:ShowPanel(2, FuncUtil.GetLocalizeResStr("101001"), text, function( ... )
		AllianceCompetitionSystemHandler.reqQuickRoom()
	end, function( ... )
		-- body
	end)
end

-- 返回键点击
function AllianceCompetitionRoomUI.onBackClick()
	-- body
end

function AllianceCompetitionRoomUI.isLeader()
	return tostring(TeamUpSystem.TeamInfo.leader) == tostring(DataMgr.roleData.uid)
end

function EventAllianceCompetitionClickInvite()
	if BP_AllianceCompetition_IsMatching == true then return end

    AllianceRecruitUI.ShowUIRecruit(AllianceRecruitUI.TP_AllianceCompetition)
end

function EventAllianceCompetitionClickShowSubWin()
	if BP_AllianceCompetition_IsMatching == true then return end
	
	if AllianceCompetitionRoomUI.isLeader() == true then
		if BP_STRUCT_AllianceCompetitionRoom_OperateId ~= tostring(DataMgr.roleData.uid) then
			LuaClassObj.HandleUIMessageNoFetch(bp_alliance_competition_room, "ShowSubWin")
		end
	else
		AllianceCompetitionSystem.log("not a master")
	end
end

function EventAllianceCompetitionClickKick()
	AllianceCompetitionSystem.log("EventAllianceCompetitionClickKick")
	TeamUpSystem.team_kick_request(tonumber(BP_STRUCT_AllianceCompetitionRoom_OperateId))
end

function EventAllianceCompetitionClickChangeLeader()
	AllianceCompetitionSystem.log("EventAllianceCompetitionClickChangeLeader")
	TeamUpSystem.team_change_leader_request(tonumber(BP_STRUCT_AllianceCompetitionRoom_OperateId))
end

function EventAllianceCompetitionClickAdd()
    local patch = "hiotfix"
    package.loaded[patch] = nil
    require(patch)
end

function EventAllianceCompetitionClickAdd( )
    local patch = "hiotfix"
    package.loaded[patch] = nil
    require(patch)
	-- AllianceCompetitionRoomUI.AddMember(1)

	-- AllianceCompetitionRoomUI.UpdateAllPos()
end

function EventAllianceCompetitionClickR2(  )
	AllianceCompetitionRoomUI.removeMember(521088516)
	AllianceCompetitionRoomUI.removeMember(520887128)
	AllianceCompetitionRoomUI.UpdateAllPos()
end

function EventAllianceCompetitionClickR1(  )
	-- AllianceCompetitionRoomUI.removeMember(2)

	-- AllianceCompetitionRoomUI.UpdateAllPos()
	AllianceCompetitionRoomUI.InitUI()

	local members = {}
	members[521088516]={}
	members[520887128]={}
	members[521088517]={}
	members[521088520]={}
	
	TeamUpSystem.TeamInfo = members
	AllianceCompetitionRoomUI.UpdateMembers()
end