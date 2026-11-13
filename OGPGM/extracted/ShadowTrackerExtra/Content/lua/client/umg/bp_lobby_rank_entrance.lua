-- 大厅排行榜入口UI
LobbyRankEntranceUI = LobbyRankEntranceUI or
{

}

--注册Widget
function bp_lobby_rank_entrance_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_lobby_rank_entrance,
        {{Path="/Game/UMG/UI_Logic/Lobby/Lobby_Rank_Entrance_BP.Lobby_Rank_Entrance_BP_C", Container="Default", ZOrder=50}},
        {"Lobby"},
        false,
        false,
        true
    );
end

--初始化显示
function LobbyRankEntranceUI.Init()	
    log("LobbyRankEntranceUI.Init")
	LuaClassObj.HandleDynamicCreation(bp_lobby_rank_entrance);
    LuaClassObj.HandleUIMessage(bp_lobby_rank_entrance, "UIShow");
end

function LobbyRankEntranceUI.Release()
    log("LobbyRankEntranceUI.Release")
end


--打开排行榜界面
function EventLobbyRankEntranceEnterRank()
	log("Enter Rank");
    if not LobbyUI:CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_RANK) then
        BP_Lobby_MenuOpen = false
        return
    end
    LuaClassObj.HandleUIMessage(bp_lobby, "CloseOtherMenu");

    BP_Lobby_MenuOpen = true
	RankSystem.Enter();
	RankUI.Init();

    ClientSendBAReport(BP_BA_LOBBY_RANK_PANEL, 0);
end

--sami 打开战区界面
function EventLobbyRankEntranceEnterWarzone()
    log("Enter WarZoneRank");
    -- 面板开关检查
    if not LobbyUI:CheckLobbyMenuOpen(BP_ENUM_WARZONE_MAIN) then
        return
    end

    --GlobalData.SetGlobalConfigBooleanValue(WarZoneRankSystem.IsOpendWarZone, true);
    --UpdateLobbyRankRedDot();
    LuaClassObj.HandleUIMessage(bp_lobby, "CloseOtherMenu");
    LuaClassObj.HandleUIMessage(bp_global, "SwitchWarzoneCamera");

    --Hide所有的主界面
    log("EventEnterWarzone RestoreMenu");
    EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN);
    LobbyUI:ShowLobbyPlayer(false);

    EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_WARZONE_OPEN);

    WarZoneRankSystem.Enter();
    WarZoneRankUI.Init();

end

function EventLobbyRankEntranceEnterIndia()
    --条件判定
    IndiaCompetitionUI:Show()
end