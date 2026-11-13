_G.GameplayCallbacks = GameplayCallbacks or {};

local PlayerState = {};
PlayerState.PreLogin = "PreLogin";
PlayerState.Login = "Login";
PlayerState.Online = "Online";
PlayerState.Logout = "Logout";
PlayerState.ConnectionLost = "ConnectionLost";
PlayerState.ConnectionTimeout = "ConnectionTimeout";

local MatchState = {};
MatchState.WaitingToStart = "WaitingToStart";
MatchState.InProgress = "InProgress";



function GameplayCallbacks.OnPostLoadMap()
	sandbox.LogNormal(string.format("OnPostLoadMap"));

	NetUtil.SendPacket(MsgToLobby.load_player_info);
end

function GameplayCallbacks.OnPlayerStateChanged(UID, InPlayerState, bPureWatcher, bIsSafeExit)
	sandbox.LogNormal(string.format("OnPlayerStateChanged UID=[%d] PlayerState=[%s]", UID, InPlayerState));

	if string.lower(InPlayerState) == "cheatdetected" then
		NetUtil.SendPacket(MsgToLobby.report_unrealnet_exception, GameID, UID, "CheatDetected", "");
	end

	local reason = "";
	if string.lower(InPlayerState) == "logout" or
		string.lower(InPlayerState) == "exited"
	then
		reason = "exit";
	elseif string.lower(InPlayerState) == "connectionexception" or string.lower(InPlayerState) == "cheatdetected" then
		reason = "lost";
	elseif string.lower(InPlayerState) == "connectiontimeout" then
		reason = "timeout";
	end

	if string.len(reason) > 0 then

		if bPureWatcher then
			sandbox.LogNormal(string.format("send watch_player_exit UID=[%d] reason=[%s]", UID, reason));
			NetUtil.SendPacket(MsgToLobby.watch_player_exit, UID, reason);
		else
			sandbox.LogNormal(string.format("send player_exit UID=[%d] reason=[%s] bIsSafeExit=[%s]", UID, reason, tostring(bIsSafeExit)));
			NetUtil.SendPacket(MsgToLobby.player_exit, UID, reason, bIsSafeExit);
		end

		GameplayCallbacks.SendClientStats(UID);
	end
end

function GameplayCallbacks.OnCharacterStateChanged(UID, InCharacterState)
	sandbox.LogNormal(string.format("OnCharacterStateChanged UID=[%d] CharacterState=[%s]", UID, InCharacterState));

	-- TODO

end

function GameplayCallbacks.OnGameModeStateChanged(InGameModeState)
	sandbox.LogNormal(string.format("OnGameModeStateChanged GameModeState=[%s]", InGameModeState));

	-- TODO

end

function GameplayCallbacks.OnPlayerNetConnectionClosed(GameID, UID, Reason, ErrorMessage)
	sandbox.LogNormal(string.format("OnPlayerNetConnectionClosed GameID=[%d] UID=[%d] Reason=[%s] ErrorMessage=[%s]", GameID, UID, Reason, ErrorMessage));

	local reason = "PlayerNetConnectionClosed";
	local message = string.format("Reason=[%s] ErrorMessage=[%s]", Reason, ErrorMessage);

	NetUtil.SendPacket(MsgToLobby.report_unrealnet_exception, GameID, UID, reason, message);
end

function GameplayCallbacks.OnShutdownAfterError(GameID)
	sandbox.LogNormal(string.format("OnShutdownAfterError GameID=[%d]", GameID));

	NetUtil.SendPacket(MsgToLobby.shutdown_after_error, GameID);
end

function GameplayCallbacks.OnPlayerDestroyed(UID)
	sandbox.LogNormal(string.format("OnPlayerDestroyed UID=[%d]", UID));

	NetUtil.SendPacket(MsgToLobby.player_destroy, UID);
end



function GameplayCallbacks.SendClientStats(UID)
	sandbox.LogNormal(string.format("SendClientStats UID=[%d]", UID));

	local stats = Server.GetPlayerStats(DSUtils, UID);
	clientAddr = stats.ClientAddr;
	localAddr = stats.LocalAddr;
	avgPing = stats.AvgPing;
	maxPing = stats.MaxPing;
	highPingPercent = stats.HighPingPercent;

	NetUtil.SendPacket(MsgToLobby.report_unrealnet_clientstats, GameID, ModeID, UID, clientAddr, localAddr, avgPing, maxPing, highPingPercent);
end

function GameplayCallbacks.SendServerAvgTickDelta(AvgTickDelta)
	sandbox.LogNormal("SendServerAvgTickDelta");

	NetUtil.SendPacket(MsgToLobby.report_serverstat_avgtickdelta, AvgTickDelta);
end



function GameplayCallbacks.SendGameOver()
	sandbox.LogNormal(string.format("SendGameOver"));
	local WeaponReport = Server.GetWeaponReport(DSUtils);
	log_tree("WeaponReport", WeaponReport);
	NetUtil.SendPacket("ReportHitFlow", WeaponReport);

	local GameDataMining = Server.GetGameDataMining(DSUtils);
	--log_tree("GameDataMining", GameDataMining);
    NetUtil.SendPacket("ReportGameDataMining", GameDataMining);

    local WatchGamePlayerInfoClickFlows = Server.GetWatchGamePlayerInfoClickFlows(DSUtils);
	log_tree("WatchGamePlayerInfoClickFlows", WatchGamePlayerInfoClickFlows);
	if WatchGamePlayerInfoClickFlows ~= nil then
		NetUtil.SendPacket("SendWatchClickLog", WatchGamePlayerInfoClickFlows);
	end

    local GameEndReport = Server.GetGameEndReportCache(DSUtils);
    
    if GameEndReport ~= nil then
    	log_tree("GameEndReport", GameEndReport);
    end

	NetUtil.SendPacket("game_over", GameEndReport);

	local GenerateMonsterFlow = Server.GetGenerateMonsterFlow(DSUtils);
	if GenerateMonsterFlow ~= nil then
    	log_tree("GenerateMonsterFlow", GenerateMonsterFlow);
    end
	NetUtil.SendPacket("ReportGenerateMonsterFlow", GenerateMonsterFlow);
end

function GameplayCallbacks.SendPlayerBattleResult(UID)
	sandbox.LogNormal(string.format("SendPlayerBattleResult UID=[%d]", UID));

	local result = Server.GetPlayerBattleResultData(DSUtils, UID);
	log_tree("PlayerBattleResult", result);

	NetUtil.SendPacket("game_result", UID, result);
end

function GameplayCallbacks.SendTeamBattleResult(TeamID)
	sandbox.LogNormal(string.format("SendTeamBattleResult TeamID=[%d]", TeamID));

	local UIDList = Server.GetUIDListByTeamID(DSUtils, TeamID);
	log_tree("UIDList", UIDList);

	local result = Server.GetTeamBattleResultData(DSUtils, TeamID);
	
	log_tree("TeamBattleResult", result);

	NetUtil.SendPacket("game_team_result", TeamID, UIDList, result);
end

function GameplayCallbacks.SendPlayerBattleResultToObserver(UID)
	sandbox.LogNormal(string.format("SendPlayerBattleResultToObserver UID=[%d]", UID));

	local OBUIDList = Server.GetOBUIDList(DSUtils);
    log_tree("OBUIDList", OBUIDList);
	NetUtil.SendPacket("game_result_ob", OBUIDList, UID);
end

function GameplayCallbacks.SendTeamBattleResultToObserver(TeamID)
	sandbox.LogNormal(string.format("SendTeamBattleResultToObserver TeamID=[%d]", TeamID));

    local OBUIDList = Server.GetOBUIDList(DSUtils);
	local UIDList = Server.GetUIDListByTeamID(DSUtils, TeamID);
	local UID = UIDList[1];
    log_tree(UID .. " to OBUIDList", OBUIDList);
	NetUtil.SendPacket("game_result_ob", OBUIDList, UID);
end

function GameplayCallbacks.SendGameStopJoin()
	sandbox.LogNormal(string.format("SendGameStopJoin"));
	NetUtil.SendPacket("game_stop_join");
end

function GameplayCallbacks.SendGameStart()
	sandbox.LogNormal(string.format("SendGameStart"));
	NetUtil.SendPacket("game_start");
end

function GameplayCallbacks.SendHeartBeat(PlayerNum, RealAiNum, MonsterNum)
	--sandbox.LogNormal(string.format("SendHeartBeat"));
	NetUtil.SendPacket("heartbeat", PlayerNum, RealAiNum, MonsterNum);
end

function GameplayCallbacks.EnterWatchChain(UID)
    sandbox.LogNormal("EnterWatchChain uid="..UID);
    NetUtil.SendPacket("enter_watch_chain", UID);
end

function GameplayCallbacks.SendPlayerUseItem(UID, resid, count)
    sandbox.LogNormal(string.format("SendPlayerUseItem, UID:%d resid:%d count:%d", UID, resid, count));
    NetUtil.SendPacket("use_item_req", UID, resid, count);
end
-- 安全日志相关 start

function GameplayCallbacks.ReportGameStartFlow()
	local securyLog = Server.GetGameStartFlowCache(DSUtils);
	--log_tree("ReportGameStartFlow", securyLog);
	NetUtil.SendPacket("ReportGameStartFlow", securyLog);
end

function GameplayCallbacks.ReportJumpFlow()
	local securyLog = Server.GetJumpFlowCache(DSUtils);
	--log_tree("ReportJumpFlow", securyLog);
	NetUtil.SendPacket("ReportJumpFlow", securyLog);
end

function GameplayCallbacks.ReportCircleFlow()
	local securyLog = Server.GetCircleFlowCache(DSUtils);
	--log_tree("ReportCircleFlow", securyLog);
	NetUtil.SendPacket("ReportCircleFlow", securyLog);
end

function GameplayCallbacks.ReportGameEndFlow()
	local securyLog = Server.GetGameEndFlowCache(DSUtils);
	--log_tree("ReportGameEndFlow", securyLog);
	NetUtil.SendPacket("ReportGameEndFlow", securyLog);
end

function GameplayCallbacks.ReportAimFlow()
	local securyLog = Server.GetAimFlowCache(DSUtils);
	--log_tree("ReportAimFlow", securyLog);
	NetUtil.SendPacket("ReportAimFlow", securyLog);
end

function GameplayCallbacks.ReportAttackFlow()
	local securyLog = Server.GetAttackFlowCache(DSUtils);
	--log_tree("ReportAttackFlow", securyLog);
	NetUtil.SendPacket("ReportAttackFlow", securyLog);
end

function GameplayCallbacks.ReportHurtFlow()
	local securyLog = Server.GetHurtFlowCache(DSUtils);
	--log_tree("ReportHurtFlow", securyLog);
	NetUtil.SendPacket("ReportHurtFlow", securyLog);
end

function GameplayCallbacks.ReportCommonInfo(uid, tableName, content)
	sandbox.LogNormal(string.format("ReportCommonInfo, uid:%d tableName:%s, content:%s", uid, tableName, content));
	NetUtil.SendPacket("report_common_info", tableName, uid, content);
end

function GameplayCallbacks.ReportPlayerBehavior()
	local securyLog = Server.GetPlayerBehaviorFlowCache(DSUtils);
	--log_tree("ReportPlayerBehavior", securyLog);
	NetUtil.SendPacket("ReportPlayerBehavior", securyLog);
end

function GameplayCallbacks.ReportPlayerMoveRoute()
	local securyLog = Server.GetPlayerRouteFlowCache(DSUtils);
	--log_tree("ReportPlayerMoveRoute", securyLog);
	NetUtil.SendPacket("ReportPlayerMoveRoute", securyLog);
end

function GameplayCallbacks.ReportFireArms()
	local securyLog = Server.GetSecPlayerKillFlowCache(DSUtils);
	--log_tree("ReportFireArms", securyLog);
	NetUtil.SendPacket("ReportFireArms", securyLog);
end

function GameplayCallbacks.ReportVerifyInfoFlow()
	local securyLog = Server.GetVerifyInfoFlowCache(DSUtils);
	--log_tree("ReportVerifyInfoFlow", securyLog);
	NetUtil.SendPacket("ReportVerifyInfoFlow", securyLog);
end

--Client setting config
function GameplayCallbacks.ReportGameSetting()
	local securyLog = Server.GetGameSettingCache(DSUtils);
	--log_tree("ReportGameSetting", securyLog);
	NetUtil.SendPacket("ReportGameSetting", securyLog);
end

function GameplayCallbacks.ReportGvoiceTeamCreate()
	local securyLog = Server.GetGvoiceTeamCreateCache(DSUtils);
	log_tree("ReportGvoiceTeamCreate", securyLog);
	NetUtil.SendPacket("ReportGvoiceTeamCreate", securyLog);
end

function GameplayCallbacks.ReportGvoiceTeamQuit()
	local securyLog = Server.GetGvoiceTeamQuitCache(DSUtils);
	log_tree("ReportGvoiceTeamQuit", securyLog);
	NetUtil.SendPacket("ReportGvoiceTeamQuit", securyLog);
end
-- 安全日志相关 end

function GameplayCallbacks.GetPicUrlByOpenId(inopenid)
    local ret = "";
	sandbox.LogNormal("GameplayCallbacks.GetPicUrlByOpenId inopenid=" .. inopenid);
	
	local dataTable = _G.ClubLogo;
    if dataTable and dataTable[inopenid] then
        local data = dataTable[inopenid];
        ret = data or "";
	end
	
    sandbox.LogNormal("GameplayCallbacks.GetPicUrlByOpenId ret=" .. (ret or ""));
    return ret;
end

sandbox.LogNormal("GameplayCallbacks.lua imported");
