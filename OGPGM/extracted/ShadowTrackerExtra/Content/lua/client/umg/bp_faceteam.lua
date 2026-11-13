
FaceteamUI = FaceteamUI or 
{
	fCode = ""
}

function bp_faceteam_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_faceteam,
		{
			{Path="/Game/UMG/UI_BP/Lobby_Team/Faceteam_LogicBP.Faceteam_LogicBP_C", Container="Default", ZOrder=BP_ENUM_UI_FACETEAM_ZORDER},
			--{Path="/Game/UMG/UI_BP/Lobby_Team/FaceteamCode_LogicBP.FaceteamCode_LogicBP_C", Container="Default", ZOrder=BP_ENUM_UI_FACETEAM_ZORDER + 1},
		},
		{"Lobby"},
		false,
        false,
		true
	);
	
	LuaClassObj.SubShowHideEvent(bp_faceteam, { "Faceteam_LogicBP_C" });
	
	--EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_FRIEND, LobbyFriendUI.Show);
end

Bp_FaceTeam_Code = ""

function bp_faceteam_OnModeSwitched(gamestatus)
	log("bp_faceteam_OnModeSwitched gamestatus = " .. gamestatus)
	if string.lower(gamestatus) == "lobby" then
        --FriendSystem.Enter()
	else
		--LobbyFriendUI:Release();
	end
end


--不做任何事，蓝图里调这个函数将把lua变量的值同步给蓝图变量
function EventFetchInfo()
	
end

--事件处理
local function FaceTeamEventHandler(eventType, eventID, vars)
	if eventType ~= EVENTTYPE_TEAMUP then
		return;
	end
	log("FaceTeamEventHandler eventType="..eventType..", eventID="..eventID);

	if eventID == EVENTID_TEAMUP_TEAMCODE_CREATE_RES then
		if vars == "ok" then
			FaceteamUI:CloseCreateFaceTeamPanel()
		end
	end

	if eventID == EVENTID_TEAMUP_TEAMCODE_JOIN_RES then
		if vars == "ok" then
			--FaceteamUI:CloseAddFaceTeamCodePanel()
			FaceteamUI:CloseCreateFaceTeamPanel()
		end
	end
end

function FaceteamUI.Init()
	EventSystem:registEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMCODE_CREATE_RES, FaceTeamEventHandler);
	EventSystem:registEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMCODE_JOIN_RES, FaceTeamEventHandler);
end

function FaceteamUI.Release()
	EventSystem:unregistEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMCODE_CREATE_RES, FaceTeamEventHandler);
	EventSystem:unregistEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMCODE_JOIN_RES, FaceTeamEventHandler);
end

--打开创建面对面开黑面板
function FaceteamUI:OpenCreateFaceTeamPanel()
	log("FaceteamUI:OpenCreateFaceTeamPanel")
	LuaClassObj.HandleDynamicCreation(bp_faceteam);
	LuaClassObj.HandleUIMessage(bp_faceteam, "ShowCreateFaceTeamPanel");
end

--关闭创建面对面开黑面板
function FaceteamUI:CloseCreateFaceTeamPanel()
	log("FaceteamUI:CloseCreateFaceTeamPanel")
	LuaClassObj.HandleUIMessage(bp_faceteam, "HideCreateFaceTeamPanel");
end


--创建队伍
function EventCreateFaceTeamCode()
	log("EventCreateFaceTeamCode")
	FaceTeamSystem.team_code_create_req()
end


--打开加入面对面密码面板
function EventOpenAddFaceTeamCodePanel()
	log("EventOpenAddFaceTeamCodePanel")
	local teamNum = TeamUpSystem.GetTeamPlayCount()
	if teamNum > 1 then
		DataMgr.ShowNoticeByID(110002)
		return
	end
	LuaClassObj.HandleUIMessage(bp_faceteam, "ShowCreateFaceTeamCodePanel");
end

--[[
--关闭加入面对面密码面板
function FaceteamUI:CloseAddFaceTeamCodePanel()
	log("FaceteamUI:CloseAddFaceTeamCodePanel")
	LuaClassObj.HandleUIMessage(bp_faceteam, "HideCreateFaceTeamCodePanel");
end
]]

function EventEnsureAddCodeTeam()
	log("FaceteamUI:EnsureCodeTeam Bp_FaceTeam_Code:" .. Bp_FaceTeam_Code)
	if Bp_FaceTeam_Code == nil or string.len(Bp_FaceTeam_Code) < 8 then
		DataMgr.ShowNoticeByID(4363);
		return
	else
		FaceTeamSystem.team_code_join_req(Bp_FaceTeam_Code)
	end
end

function EventFaceteamUIRelease()
	FaceteamUI.Release()
end