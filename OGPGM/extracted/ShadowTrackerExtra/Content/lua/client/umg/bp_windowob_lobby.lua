WindowOBLobbyUI = WindowOBLobbyUI or {}

BP_STRUCT_AvatarInfo = 
{
    resID = 401999,
    colorID = 0,
    patternID = 0,
}

BP_ARRAY_AvatarList = 
{
    BP_STRUCT_AvatarInfo = _G.BP_STRUCT_AvatarInfo,
}

BP_STRUCT_OBLobbySpawnPlayerData =
{
    gid = "",
    sex = 1,
    headId = 401999,
    index = 0,
    BP_ARRAY_AvatarList = _G.BP_ARRAY_AvatarList,
	weaponId = 0,
	weaponSkinId = 0,
}

BP_STRUCT_OBPlayerData = 
{
	name = "",
	level = 0,
	gender = 1,
	icon = "",
	frame = 0,
	uid = ""
}

function bp_windowob_lobby_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_windowob_lobby,
        {{Path="/Game/UMG/UI_Logic/Lobby_OB/LobbyOB_BP.LobbyOB_BP_C", Container="Default", ZOrder=2}},
        {"Lobby"},
        false,
        bp_windowob_lobby_OnModeSwitched ~= nil,
		true
    );
end

function bp_windowob_lobby_OnModeSwitched(gamestatus)
	if string.lower(gamestatus) == "lobby" then
		if not GetWindowOBState() then
			return
		end

		LuaClassObj.HandleDynamicCreation(bp_windowob_lobby)
        LuaClassObj.HandleUIMessage(bp_windowob_lobby, "UIShow")


        if (DataMgrInit) then
            WindowOBLobbyUI:RefreshPlayerData()
            log_tree("lht", GlobalData)
			-- GlobalData.ResetLobbySkinStatus()
			GlobalData.SwitchLobbySkin(10004)
            --WindowOBLobbyUI:CreateMyself()
        end
	end
end

-- 更新玩家数据
function WindowOBLobbyUI:RefreshPlayerData()
	BP_STRUCT_OBPlayerData = 
	{
		name = DataMgr.roleData.nickName,
		level = DataMgr.roleData.level,
		gender = DataMgr.avatarData.gamegender,
		icon = DataMgr.roleData.headIconUrl,
		frame = DataMgr.roleData.cur_avatar_box_id,
		uid = DataMgr.roleData.uid
	}
    LuaClassObj.HandleUIMessage(bp_windowob_lobby, "InitPlayerData")
end

-- 创建自己的模型
function WindowOBLobbyUI:CreateMyself()
    local rolewear = {}
    WardrobeSystem.UpdateInvalidWearInfo(nil);

    for k,v in pairs(DataMgr.rolewear) do
        if (DataMgr.GetHallDepotItemDataByInsID(v) ~= nil) then
        	local itemInfo = DataMgr.GetHallDepotItemDataByInsID(v);
            table.insert(rolewear, LobbyUI.CreateClientAvatarWearInfo(itemInfo.resID, itemInfo.colorID, itemInfo.patternID));	
        end
	end

    local avatarSt = {
        gamegender = DataMgr.avatarData.gamegender,
        headid = DataMgr.avatarData.headid,
        hairid = DataMgr.avatarData.hairid
    }

    BP_STRUCT_OBLobbySpawnPlayerData =
    {
        gid = tostring(DataMgr.roleData.uid or 0),
        sex = avatarSt.gamegender or 1,
        headId = avatarSt.headid or 401999,
        index = BP_LobbyPlayerNum,
        BP_ARRAY_AvatarList = rolewear or {},
		weaponId = DataMgr.GetCurrentWeaponID() or 0,
		weaponSkinId = 0,
    }
    
	local switchInfo = 0
	if LobbySystem.LobbyMenuOpenStatus[BP_ENUM_WARDROBE_UI_WEAPON] then
		switchInfo = LobbySystem.LobbyMenuOpenStatus[BP_ENUM_WARDROBE_UI_WEAPON].is_open or 0;
	end
	if switchInfo == 0 then
		log("LobbyUI:SpawnPlayer weapon Not Open")
		BP_STRUCT_OBLobbySpawnPlayerData.weaponId = 0
	end
	
    BP_STRUCT_OBLobbySpawnPlayerData.sex = BP_STRUCT_OBLobbySpawnPlayerData.sex - 1
    table.insert(BP_STRUCT_OBLobbySpawnPlayerData.BP_ARRAY_AvatarList, LobbyUI.CreateClientAvatarWearInfo(avatarSt.hairid,0,0))

    LuaClassObj.HandleUIMessage(bp_windowob_lobby, "SpawnPlayer")
end


function EventOBEnterRoom()
	log("EventClickRoom_Push");
	if TeamUp_Is_Matching then
		ShowNotice("取消匹配"); --匹配中无法设置
		LobbySystem.change_status_req();
		LobbySystem.on_match_cancel_req();
		return;
	end
	
	if TeamUpSystem.TeamInfo and TeamUpSystem.TeamInfo.player_count and TeamUpSystem.TeamInfo.player_count > 1 then
		ShowNotice("取消组队"); --请先退出组队
		TeamUpSystem.team_quit_request(TeamUpSystem.TeamInfo.id);
		return;
	end
	
	RoomUI:Init();
	RoomSystem.Enter();
end

function EventOBEnterSetting()
	EventEnterConfig()
end