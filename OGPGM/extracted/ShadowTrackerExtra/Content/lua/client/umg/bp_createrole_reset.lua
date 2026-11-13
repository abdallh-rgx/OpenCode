CreateRoleResetUI = CreateRoleResetUI or 
{
}

BP_CreateRole_Reset_ShowRedPoint = false;

  --注册Widget
function bp_createrole_reset_RegisterUI()
  LuaClassObj.SubUIWidgetList(bp_createrole_reset,
    {
     {Path="/Game/UMG/UI_BP/Lobby/Item/Lobby_ResetRole_UIBP.Lobby_ResetRole_UIBP_C", Container="Default", ZOrder=BP_ENUM_UI_ResetRole},
    },
	{"CreateRole","Lobby"},
	false,
	false,
    true
  );
  
  EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_AVATAR_ACTIVATE, CreateRoleResetUI.RefresRedPoint);
end

function CreateRoleResetUI.Show()
	LuaClassObj.HandleDynamicCreation(bp_createrole_reset);

    --LuaClassObj.HandleUIMessage(bp_createrole_reset, "UIShowResetAvatar");
end

function CreateRoleResetUI.RefresRedPoint()
	BP_CreateRole_Reset_ShowRedPoint = false
	if next(DataMgr.avatarData.activate_avatar_list) ~= nil then
		for k,v in pairs(DataMgr.avatarData.activate_avatar_list) do
			if not BP_CreateRole_Reset_ShowRedPoint and v == 1 then
				BP_CreateRole_Reset_ShowRedPoint = true
			end
		end
	end
	LuaClassObj.HandleDynamicCreation(bp_createrole_reset);
	LuaClassObj.HandleUIMessage(bp_createrole_reset, "UIRefreshRedPoint");
end

function CreateRoleResetUI.Reset()
	BP_CreateRole_Reset_ShowRedPoint = false;
	LuaClassObj.HandleDynamicCreation(bp_createrole_reset);
	LuaClassObj.HandleUIMessage(bp_createrole_reset, "UIRefreshRedPoint");
end

function EventOpenCreateRoleAvatarResetPanel()
	BP_CreateRole_Reset_ShowRedPoint = false;
	WardrobeSystem.UpdateLobbyHotDot();
	LobbySystem.SendDefaultWearInfoReq();
	LuaClassObj.HandleDynamicCreation(bp_createrole_reset);
	LuaClassObj.HandleUIMessage(bp_createrole_reset, "UIRefreshRedPoint");
    EventOpenAvatarResetPanel()
end
