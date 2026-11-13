
--面对面组队相关逻辑
FaceTeamSystem = FaceTeamSystem or 
{

}

--创建面对面组队
function FaceTeamSystem.team_code_create_req()
	log("FaceTeamSystem.team_code_create_req---")
	NetUtil.SendPriorityPkg(false, "team_code_create_res", "team_code_create_req");
end

--加入面对面组队
function FaceTeamSystem.team_code_join_req(code)
	log("FaceTeamSystem.team_code_join_req---")
	NetUtil.SendPriorityPkg(false,"team_code_join_res","team_code_join_req",code);
end

--删除组队码
function FaceTeamSystem.team_code_delete_req(code)
	log("FaceTeamSystem.team_code_delete_req  code:" .. tostring(code))
	NetUtil.SendPkg("team_code_delete_req",code);
end

--创建面对面组队回复
function FaceTeamSystem.team_code_create_res(state,code)
	log("FaceTeamSystem.team_code_create_res state:" .. tostring(state) .. "  code:".. tostring(code))
 	if(state == "ok") then
 		TeamUpSystem.SetTeamCode(code)
		EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMCODE_SYNC);
		--FaceteamUI:CloseCreateFaceTeamPanel()
	elseif(state == "already-exist") then
		DataMgr.ShowNoticeByID(4364);
	else
	end	
	EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMCODE_CREATE_RES,state);
end

--加入面对面组队回复
function FaceTeamSystem.team_code_join_res(state)
	log("FaceTeamSystem.team_code_join_res")
	--主要错误码通过team_join_respond回复
	if(state == "ok") then
		--FaceteamUI:CloseCreateFaceTeamPanel()
	else
		
	end
	EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMCODE_JOIN_RES,state);
end

--删除组队码回复
function FaceTeamSystem.team_code_delete_res(state,code)
	log("FaceTeamSystem.team_code_delete_res,state:" .. tostring(state) .. "  code:".. tostring(code))
	if(state == "ok" or state == "nil-code" or state == "timeout") then
		---
		TeamUpSystem.SetTeamCode(nil)
		EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMCODE_SYNC);
	else
		
	end
end

function FaceTeamSystem.team_code_notify(code)
	log("FaceTeamSystem.team_code_notify")
	TeamUpSystem.SetTeamCode(code)
	EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMCODE_SYNC);
end

--[[网络回调]]--

s2c["team_code_create_res"] = FaceTeamSystem.team_code_create_res; --
s2c["team_code_join_res"] = FaceTeamSystem.team_code_join_res; --加入面对面组队回复
s2c["team_code_delete_res"] = FaceTeamSystem.team_code_delete_res; --删除组队码回复
s2c["team_code_notify"] = FaceTeamSystem.team_code_notify; --密码状态变更