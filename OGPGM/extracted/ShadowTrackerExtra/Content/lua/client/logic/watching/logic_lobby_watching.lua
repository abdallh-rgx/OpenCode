
LogicLobbyWatching = LogicLobbyWatching or
{
	IsWatchingPanelEnter = false, -- 是否观战面板进入的
	IsWatchingEnterGame = false, -- 是观战进入游戏
	NeedWatchingInfo = false,  --控制小程序拉起观战，第一次进入大厅不退出观战
}

-- 请求观看好友
function LogicLobbyWatching.req_enter_watching(watchFriendUID, isWinForceWatch)
	local bForceWatch = false
	if isWinForceWatch then
		bForceWatch = true
	end
	NetUtil.SendPkg("enter_battle_watch", tonumber(watchFriendUID), bForceWatch);
end

-- function CommonMessageBoxUI:ShowPanel(styleType, title, msg, clickOkCallback, clickCancelCallback, btnOK, btnCancel, isConnectionPanel, timerCallback)
function LogicLobbyWatching.enter_battle_watch(watchFriendUID, isPlatFormStartUp)
	if watchFriendUID == nil then
		-- log("watching enter_battle_watch client call watchFriendUID == nil")
		return
	end
	-- 小程序拉起观战，需要重置
	if isPlatFormStartUp then
		-- 正在观战中，不设置改状态。避免正在观战，然后又手Q拉起，然后主动退出观战，接着还会提示进入观战。
		if not LogicLobbyWatching.IsWatchingEnterGame then
			LogicLobbyWatching.NeedWatchingInfo = false
		end
	end

	-- log("watching enter_battle_watch client call watchUID:"..watchFriendUID)
	ConnectionWaitingUI:Show()

	LogicLobbyWatching.req_enter_watching(tonumber(watchFriendUID), false)
	-- NetUtil.SendPriorityPkg(false, "enter_game", "enter_battle_watch", tonumber(watchFriendUID));
	LogicLobbyWatching.IsWatchingEnterGame = true
end

function LogicLobbyWatching.SetIsWatchingPanelEnter()
	LogicLobbyWatching.IsWatchingPanelEnter = true
end

function LogicLobbyWatching.ResetWatchingInfo()
	--没进过战斗，不清理观战信息
	if not LogicLobbyWatching.NeedWatchingInfo then
		return
	end
	-- 战斗结束重新打开观战面板
	if LogicLobbyWatching.IsWatchingPanelEnter then
		EventOpenWatchingPanel()
	end

	if LogicLobbyWatching.IsWatchingEnterGame then
		LogicLobbyWatching.leave_battle_watch()
	end

	LogicLobbyWatching.Release()
end

function LogicLobbyWatching.Release()
	LogicLobbyWatching.IsWatchingEnterGame = false
	LogicLobbyWatching.IsWatchingPanelEnter = false
	ConnectionWaitingUI:Hide()
end

function LogicLobbyWatching.WatchingEnterGameCheck(enterGameFunc)
	if LogicLobbyWatching.IsWatchingEnterGame then
		-- 可能是外部拉起观战，清理下数据
   		LoginSystem.extendInfo = {}
		local titleStr = Client.GetTableData("LocalizeRes",101001).TextValue
		local tipsContent = Client.GetTableData("LocalizeRes",501124).TextValue
		-- CommonMessageBoxUI:ShowPanel(styleType, title, msg, clickOkCallback, clickCancelCallback,
		CommonMessageBoxUI:ShowPanel( 2, titleStr, tipsContent, 
			function() 
				-- 还是观战中才进入观战，否则什么都不做
				if LogicLobbyWatching.IsWatchingEnterGame then
					LobbySystem.ShowMatchSuccess()
					-- log("ReEnter watching game call not old SetAsMatchSuccess");
					enterGameFunc()
				end
			end, 
			LogicLobbyWatching.leave_battle_watch);
	else
		enterGameFunc()
	end
end

-- 主动退出观战
function LogicLobbyWatching.leave_battle_watch()
	-- log("watching leave_battle_watch client call")
	NetUtil.SendPkg("leave_battle_watch")
	LogicLobbyWatching.Release()
end

--进入观战失败时返回 成功走enter_game老协议
function LogicLobbyWatching.enter_battle_watch_failed(reason, watch_uid)
-- is_in_team 在队伍中不能观战
-- is_gameing 在游戏中不能观战
-- is_watching 已经在观战中
-- is_matching 匹配中不能观战
-- not_in_game 对方不再游戏中
-- not_online 对方不在线
-- game_over 对方游戏已经结束
-- version_mismatch 你的版本不匹配
-- to_much_watcher  当前观战的人数超过上限
-- not_download_map 没有下载将要观战的地图
   -- log("watching enter_battle_watch_failed call")

   -- 可能是外部拉起观战，清理下数据
   LoginSystem.extendInfo = {}
   -- 重置观战状态
	LogicLobbyWatching.Release()

	if reason == nil then
		-- log("LogicLobbyWatching enter_battle_watch_failed reason == nil")
		return
	end
	local removeFriendItem = false;
	
	if reason == "is_in_team" then
		LogicLobbyWatching:PopTips(501111)
	elseif reason == "is_gameing" then
		LogicLobbyWatching:PopTips(501112)
	elseif reason == "is_watching" then
		LogicLobbyWatching:PopTips(501113)
	elseif reason == "is_matching" then
		LogicLobbyWatching:PopTips(501114)
	elseif reason == "not_in_game" then
		LogicLobbyWatching:PopTips(501115)
		removeFriendItem = true
	elseif reason == "not_online" then
		LogicLobbyWatching:PopTips(501116)
		removeFriendItem = true
	elseif reason == "game_over" then
		LogicLobbyWatching:PopTips(501117)
		removeFriendItem = true
	elseif reason == "version_mismatch" then
		LogicLobbyWatching:PopTips(501118)
	elseif reason == "to_much_watcher" then
		LogicLobbyWatching:PopTips(110433)
	elseif reason == "not_watch_mode" then
		LogicLobbyWatching:PopTips(501127)
	elseif reason == "watch_is_close" then
		LogicLobbyWatching:PopTips(501125)
	elseif reason == "level_not_enough" then
		LogicLobbyWatching:PopTips(501126)
	elseif reason == "not_allow_watch" then
		LogicLobbyWatching:PopTips(501131)
		removeFriendItem = true
	elseif reason == "is_in_room_game" then
		LogicLobbyWatching:PopTips(501132)
		-- removeFriendItem = true
	elseif reason == "corps_war_not_allow_watch" then
		LogicLobbyWatching:PopTips(501133)
	elseif reason == "not_download_map" then
		LogicLobbyWatching:PopTips(501134)
	else
		-- log("watching LogicLobbyWatching enter_battle_watch_failed reason:"..reason)
	end
end

function LogicLobbyWatching:PopTips(resID)
	local ShowTips = ""
	local ResTbl = Client.GetTableData("LocalizeRes", resID)
	if ResTbl ~= nil then
		ShowTips = ResTbl.TextValue
	end

	DataMgr.ShowNoticeByString(ShowTips)
end

--被动退出观战
function LogicLobbyWatching.exit_watch_game(reason, delay_time)
-- game_over  游戏结束
-- watch_player_exit  观战对方退出了游戏
-- watch_player_result  观战对方游戏结束
-- timeout 连接超时
-- is_in_team 在队伍中不能观战
	-- 重置观战状态
	LogicLobbyWatching.Release()
	if reason == nil then
		-- log("watching LogicLobbyWatching exit_watch_game reason == nil")
		BP_WatchExitReason = "game_over";
	else
		-- log("watching exit_watch_game call.reason:"..tostring(reason))
	end
    --[[
	if reason == "game_over" then
		LobbyWatchingUI:PopTips(501117)
	elseif reason == "watch_player_exit" then
		LobbyWatchingUI:PopTips(501121)
	elseif reason == "watch_player_result" then
		LobbyWatchingUI:PopTips(501122)
	elseif reason == "timeout" then
		LobbyWatchingUI:PopTips(501123)
	else
		log("LogicLobbyWatching exit_watch_game reason:"..reason)
	end
    --]]
	BP_WatchExitReason = reason;
    BP_WatchExit_DelayTime = delay_time or 0;
	BattleResultUI.OnExitWatchGame();
end

function LogicLobbyWatching.send_show_watching(watchingFlag)
	-- log("watching send_show_watching watchingFlag:"..watchingFlag)
    NetUtil.SendPkg("set_watch_switch", watchingFlag);
end

function LogicLobbyWatching.send_show_battle_watching_detail(watchingIngameBaseInfoFlag)
	log("watching send_show_battle_watching_detail flag:"..watchingIngameBaseInfoFlag)
    NetUtil.SendPkg("set_watch_privacy", watchingIngameBaseInfoFlag);
end

function LogicLobbyWatching.IsWatchingOpenWithMsgBox()
	local cfgLevel = tonumber(DataMgr.GetSystemConfig("BattleWatchNeedLevel"))
	if cfgLevel == nil then
		cfgLevel = 5
	end

	local levelEnough = DataMgr.roleData.level >= cfgLevel
	if not levelEnough then
		LogicLobbyWatching:PopTips(501126)
        return levelEnough
	end
		
	local isopen = LobbyUI:CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_WATCHING)
	return levelEnough and isopen
end

function LogicLobbyWatching.IsWatchingBattleBaseInfoSettingOpen()
	return LobbyUI:CheckLobbyMenuOpenWithoutTips(BP_ENUM_LOBBY_MENU_WATCHING_BATTLE_BASEINFO)
end

function LogicLobbyWatching.IsWatchingBattleDetailBtnShow()
	return LobbyUI:CheckLobbyMenuOpenWithoutTips(BP_ENUM_LOBBY_MENU_WATCHING_BATTLE_DETAILBTN)
end

function LogicLobbyWatching.SetShouldBattleDetailBtnState()
	local isBattleDetailBtnOpen = LobbyUI:CheckLobbyMenuOpenWithoutTips(BP_ENUM_LOBBY_MENU_WATCHING_BATTLE_DETAILBTN)
	if isBattleDetailBtnOpen then
		-- log("watching LogicLobbyWatching.SetShouldBattleDetailBtnState true")
	else
		-- log("watching LogicLobbyWatching.SetShouldBattleDetailBtnState false")
	end
	Client.SetShouldShowWatchingDetialBtn(GameFrontendHUD, isBattleDetailBtnOpen);
end

function LogicLobbyWatching.IsWatchingPrivacyOpen()
	return LobbyUI:CheckLobbyMenuOpenWithoutTips(BP_ENUM_LOBBY_MENU_WATCHING_PRIVACY)
end

function LogicLobbyWatching.IsWatchingInviteOpen()
	return LobbyUI:CheckLobbyMenuOpenWithoutTips(BP_ENUM_LOBBY_MENU_WATCHING_INVITE)
end

function LogicLobbyWatching.IsShowWatcherList()
	local cfgLevel = tonumber(DataMgr.GetSystemConfig("BattleShowWatcherListNeedLevel"))
	if cfgLevel == nil then
		cfgLevel = 5;
	end
	local levelEnough = DataMgr.roleData.level >= cfgLevel;
	if not levelEnough then
		return levelEnough;
	end
	local showWatcherList = true
	if LobbySystem.LobbyMenuOpenStatus[BP_ENUM_LOBBY_MENU_WATCHER_LIST] ~= nil and LobbySystem.LobbyMenuOpenStatus[BP_ENUM_LOBBY_MENU_WATCHER_LIST].is_open == 0 then
		showWatcherList = false
	end
	return showWatcherList;
end

function LogicLobbyWatching.IsCanWatchEnemy()
	if LobbySystem.LobbyMenuOpenStatus[BP_ENUM_LOBBY_MENU_WATCH_CHAIN] ~= nil and LobbySystem.LobbyMenuOpenStatus[BP_ENUM_LOBBY_MENU_WATCH_CHAIN].is_open == 0 then
		return false
	end
	return true
end

function LogicLobbyWatching.IsWatchingOpen()
	local cfgLevel = tonumber(DataMgr.GetSystemConfig("BattleWatchNeedLevel"))
	if cfgLevel == nil then
		cfgLevel = 5
	end
	local levelEnough = DataMgr.roleData.level >= cfgLevel

	local isOpen = true
    if LobbySystem.LobbyMenuOpenStatus[BP_ENUM_LOBBY_MENU_WATCHING] ~= nil and LobbySystem.LobbyMenuOpenStatus[BP_ENUM_LOBBY_MENU_WATCHING].is_open == 0 then
    	isOpen = false
    	-- log("watching LogicLobbyWatching.IsWatchingOpen isOpen = false")
    end
    return levelEnough and isOpen
end

-- 需要处理错误码
-- enter_battle_watch消息，会触发大厅服务器回包on_enter_game或enter_battle_watch_failed
--[[网络回调]]--
-- s2c["enter_game"] = RoomSystem.on_enter_game;
s2c["enter_battle_watch_failed"] = LogicLobbyWatching.enter_battle_watch_failed;
s2c["exit_watch_game"] = LogicLobbyWatching.exit_watch_game; 
