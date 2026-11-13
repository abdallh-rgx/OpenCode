-- 大厅排行榜入口UI
LobbyLeagueGameEntranceUI = LobbyLeagueGameEntranceUI or
{
    openfrom = 0,           --打开来源，0表示自己，1表示赛事
}

--注册Widget
function bp_lobby_leaguegame_entrance_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_lobby_leaguegame_entrance,
        {{Path="/Game/UMG/UI_Logic/Lobby/Lobby_Match_Entrance_BP.Lobby_Match_Entrance_BP_C", Container="Default", ZOrder=BP_ENUM_UI_LOBBY_LEAGUEGAME_ENTRANCE}},
        {"Lobby"},
        false,
        false,
        true
    );
end

BP_LeagueGameEntranceMenuId = 0
BP_LeagueGameEntranceRedPointStatus = false

BP_LeagueGameEntranceBroadcastLeagueStage = 0;
BP_LeagueGameEntranceBroadcastRedpoint = false;

BP_LeagueGameEntranceIndiaChampionshipNewGuideStatus = false;   -- 印度线上锦标赛新手引导

BP_LeagueGameEntrance_IsShowIndiaChampionship = false;

--初始化显示
function LobbyLeagueGameEntranceUI.Init()	
    log("LobbyLeagueGameEntranceUI.Init")
    LobbyLeagueGameEntranceUI.SetData();
    BP_LeagueGameEntrance_IsShowIndiaChampionship=not IndiaChampionShipLogic.LockEnter;
	LuaClassObj.HandleDynamicCreation(bp_lobby_leaguegame_entrance);
    LuaClassObj.HandleUIMessage(bp_lobby_leaguegame_entrance, "UIShow");
    if LeagueGameSystem.isNeetTipNextMatch then
        LobbyLeagueGameEntranceUI.UpdateRedPoint(BP_ENUM_LOBBY_MENU_LEAGUEGAME_SYSTEM, true);
        LeagueGameSystem.isNeetTipNextMatch = false;
    end
    LobbyUI.HideLeagueGameCountDown();
    EventSystem:registEvent(EVENTTYPE_INDIA_COMPETITION, EVENTID_INDIA_CHAMPIONSHIP_TOURNAMENT_NEW_NOTIFY, LobbyLeagueGameEntranceUI.OnIndiaChampionshipUpdate);
    LobbyLeagueGameEntranceUI.InitIndiaChampionshipNew()
end

function LobbyLeagueGameEntranceUI.SetData()
   BP_LeagueGameEntranceBroadcastRedpoint = LobbySystem.bHaveBroadcastRedpoint;
   BP_LeagueGameEntranceBroadcastLeagueStage = LeagueGameSystem.StageId;
end

function EventLobbyLeagueGameEntranceUIHide()
    LobbyLeagueGameEntranceUI.Release();
end

function LobbyLeagueGameEntranceUI.Release()
    log("LobbyLeagueGameEntranceUI.Release")
    EventSystem:unregistEvent(EVENTTYPE_INDIA_COMPETITION, EVENTID_INDIA_CHAMPIONSHIP_TOURNAMENT_NEW_NOTIFY, LobbyLeagueGameEntranceUI.OnIndiaChampionshipUpdate);
end

--打开赛事
function EventLobbyLeagueGameEntranceEnterLeague()
	if not LobbyUI:CheckLobbyMenuOpen(BP_ENUM_ONLINE_EVENT) then
        return
    else
        LeagueGameLobbyUI.Init();
    end
    ClientSendBAReport(BP_ENUM_LOBBY_MENU_LEAGUEGAME_SYSTEM, 0);

    LuaClassObj.HandleUIMessage(bp_lobby, "CloseOtherMenu");

    LobbyLeagueGameEntranceUI.UpdateRedPoint(BP_ENUM_LOBBY_MENU_LEAGUEGAME_SYSTEM, false);
    LobbyLeagueGameEntranceUI.HideLobbyBroadcastMenuRedPoint()
end

--打开直播
function EventLobbyLeagueGameEntranceEnterBroadcast()
    LobbyLeagueGameEntranceUI.openfrom = 0;
    --通知服务器增加赛事H5跳转活动点击次数，客户端写死
    if(ActivitySystem.IsContainsH5LeagueGameActivity()) then
        local strRegion = Client.GetPublishRegion();
        if strRegion == "JAPAN" or strRegion == "KOREA" then
            ActivitySystem.Req_DealActivity(ActivtyUI.KR_H5LeagueGameActivityID, 1, 0);
        else
            ActivitySystem.Req_DealActivity(ActivtyUI.H5LeagueGameActivityID, 1, 0);
        end 
    end
    LobbyLeagueGameEntranceUI.EnterBroadcast();
end

-- 进入印度线上赛
function EventLobbyLeagueGameEntranceEnterIndia()
    IndiaCompetitionUI:Show()
    LobbyLeagueGameEntranceUI.UpdateRedPoint(BP_ENUM_LOBBY_MENU_INDIA_CHAMPIONSHIP_SYSTEM, false);
    local nowData = math.floor(FuncUtil.GetServerTimeInSec() / 86400);
    local lastData =  DataMgr.GetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_INDIA_CHAMPIONSHIP,Newbie_Guide_India_Championship_Tournament_New);
    if nil == lastData or lastData ~= nowData then
        DataMgr.SetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_INDIA_CHAMPIONSHIP,Newbie_Guide_India_Championship_Tournament_New, nowData);
    end
    IndiaChampionShipLogic.isNeedRedPoint = false;
    IndiaChampionShipLogic.tournamentHas = false;
    LobbyLeagueGameEntranceUI.HideLobbyBroadcastMenuRedPoint()    
end

function LobbyLeagueGameEntranceUI.EnterBroadcast()
    if not LobbyUI:CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_BROADCAST) then
        return
    end

    --LuaClassObj.HandleUIMessage(bp_lobby, "CloseOtherMenu");

    if TeamUpUI.IsMatching() then
        DataMgr.ShowNoticeByID(110017)
        return
    end
    --网络类型-int 0 其他; 1 wifi
    local netType = 0
    if Client.HasActiveWifi() then
        netType = 1
    end
    
    local url = string.format("https://www.pubgmobile.com/act/a20180727live/live.html?region=%d&language=%s&netType=%d",
        TeamUpSystem.ChooseZoneId,
        Client.GetCurrentLanguage(),
        netType
    )
    Client.OpenURL(url, true);
    if LobbyLeagueGameEntranceUI.openfrom == 0 then
        --log("LobbyLeagueGameEntranceUI.openfrom .." .. LobbyLeagueGameEntranceUI.openfrom)
        ClientSendBAReport(BP_ENUM_LOBBY_MENU_BROADCAST, 0);
    elseif LobbyLeagueGameEntranceUI.openfrom == 1 then
        --log("LobbyLeagueGameEntranceUI.openfrom .." .. LobbyLeagueGameEntranceUI.openfrom)
        ClientSendBAReport(BP_ENUM_LOBBY_MENU_LEAGUEGAME_BROADCAST, 0);
    end
    if LobbySystem.bHaveBroadcastRedpoint then
        LobbySystem.bHaveBroadcastRedpoint = false;
        local zoneId = TeamUpSystem.ChooseZoneId;
        GlobalData.SetGlobalConfigIntValue("broadcastRemoveRedpoint" .. zoneId, os.time());
    end
    LobbyLeagueGameEntranceUI.UpdateRedPoint(BP_ENUM_LOBBY_MENU_BROADCAST, false);
    LobbyLeagueGameEntranceUI.HideLobbyBroadcastMenuRedPoint()
end

-- 更新印度线上赛的第一次new状态
function LobbyLeagueGameEntranceUI.InitIndiaChampionshipNew()
    if not IndiaChampionShipLogic.LockEnter then
        local newbieGuide = DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_INDIA_CHAMPIONSHIP, Newbie_Guide_India_Championship_Introduce)
        if newbieGuide then
            BP_LeagueGameEntranceIndiaChampionshipNewGuideStatus = true;
            LobbyLeagueGameEntranceUI.UpdateRedPoint(BP_ENUM_LOBBY_MENU_INDIA_CHAMPIONSHIP_SYSTEM, true)
            return;
        elseif IndiaChampionShipLogic.tournamentHas then
            local timeData = DataMgr.GetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_INDIA_CHAMPIONSHIP,Newbie_Guide_India_Championship_Tournament_New);
            if timeData then
                local nowData = math.floor(FuncUtil.GetServerTimeInSec() / 86400);
                if nowData - timeData > 0 then
                    BP_LeagueGameEntranceIndiaChampionshipNewGuideStatus = false;
                    LobbyLeagueGameEntranceUI.UpdateRedPoint(BP_ENUM_LOBBY_MENU_INDIA_CHAMPIONSHIP_SYSTEM, true)
                    return;
                end
            end
        end    
    end
    LobbyLeagueGameEntranceUI.UpdateRedPoint(BP_ENUM_LOBBY_MENU_INDIA_CHAMPIONSHIP_SYSTEM, false)
end

-- 更新印度线上赛的红点状态
function LobbyLeagueGameEntranceUI.OnIndiaChampionshipUpdate()
    LobbyLeagueGameEntranceUI.UpdateRedPoint(BP_ENUM_LOBBY_MENU_INDIA_CHAMPIONSHIP_SYSTEM, true)
    LobbyUI:LobbyRedPointUpdate(BP_ENUM_LOBBY_MENU_BROADCAST, true)
end

function LobbyLeagueGameEntranceUI.UpdateRedPoint(menuId, show)
    BP_LeagueGameEntranceMenuId = menuId
    BP_LeagueGameEntranceRedPointStatus = show
    LuaClassObj.HandleUIMessage(bp_lobby_leaguegame_entrance, "UpdateRedPoint");
end

-- 大厅目录红点控制，同时受到印度赛、直播、线上赛的影响
function LobbyLeagueGameEntranceUI.HideLobbyBroadcastMenuRedPoint()
    if not LeagueGameSystem.isNeetTipNextMatch and not IndiaChampionShipLogic.isNeedRedPoint and not LobbySystem.bHaveBroadcastRedpoint then
        LobbyUI:LobbyRedPointUpdate(BP_ENUM_LOBBY_MENU_BROADCAST, false);
    end
end
