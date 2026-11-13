-- 本文件只是负责观战推荐弹窗控制逻辑
-- 除非
WatchingInviteWndController = WatchingInviteWndController or
{
	IsFirstShow = true,
	IsPlatformStartUp = false, --是否小程序拉起观战

	ToLobbyDelayTimer = nil, --小程序拉起延迟1分钟刷新

	DelayPopUpWatchInfo = {}, --弹出的缓存信息
	HasPopUpWatchInfo = {}, --已经弹出过的
	LastPopupWatchInfoTime = 0, -- 最近收到推荐的时间
	NextInvitePopupInterval = 20, -- 两个推荐之间的时间长度
	isReconnet = false,
} 

local SameBattleDuration = 1000 -- 同一局战斗的时长 秒数

function WatchingInviteWndController.Register()
	-- 接收好友推荐观战
	EventSystem:registEvent(EVENTTYPE_LOBBY, EVENTID_POPUP_WATCHWND, WatchingInviteWndController.ReceivePopupInvite)

	-- 好友删除
	EventSystem:registEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_DELETE_SELF, WatchingInviteWndController.OnDeleteFriendSelf)
	EventSystem:registEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_DELETE, WatchingInviteWndController.OnDeleteFriend)

	--师徒关系删除
	EventSystem:registEvent(EVENTTYPE_MASTER, EVENTID_MASTER_DELETE, WatchingInviteWndController.MasterDelete)

	WatchingInviteWndController.CheckFinalFightingLogic()
end

function WatchingInviteWndController.WndOpenStop(IsStop)
	FriendCalcFinalFighting:SetIsAbleToUpdateState(not IsStop)
end

function WatchingInviteWndController.CheckFinalFightingLogic()
	local isWindows =  string.lower(Client.GetDevicePlatformName()) == "windows"
	-- 第一次进入大厅 等打脸图完成开启检查推荐
	if WatchingInviteWndController.IsFirstShow and not isWindows then
		EventSystem:registEvent(EVENTTYPE_LOBBY, EVENTID_FACE_END, WatchingInviteWndController.CheckPopFinalFighting)
	else
		-- 战斗返回大厅
		WatchingInviteWndController.CheckPopFinalFighting()
	end
end

function WatchingInviteWndController.ReconnectLogic()
	WatchingInviteWndController.ClearInviteData()
	WatchingInviteWndController.CheckFinalFightingLogic()
end

function WatchingInviteWndController.Reconnect()
	WatchingInviteWndController.isReconnet = true
	Timer.InsertTimer(5, WatchingInviteWndController.ReconnectLogic, false)
end

function WatchingInviteWndController.Clear()
	EventSystem:unregistEvent(EVENTTYPE_LOBBY, EVENTID_POPUP_WATCHWND, WatchingInviteWndController.ReceivePopupInvite)
	EventSystem:unregistEvent(EVENTTYPE_LOBBY, EVENTID_FACE_END, WatchingInviteWndController.CheckPopFinalFighting)
	EventSystem:unregistEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_DELETE_SELF, WatchingInviteWndController.OnDeleteFriendSelf)
	EventSystem:unregistEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_DELETE, WatchingInviteWndController.OnDeleteFriend)
	EventSystem:unregistEvent(EVENTTYPE_MASTER, EVENTID_MASTER_DELETE, WatchingInviteWndController.MasterDelete)

	WatchingInviteWndController.ClearInviteData()
end

function WatchingInviteWndController.OnDeleteFriendSelf(eventType, eventID, friendUID)
	WatchingInviteUI.DeleteFriendCheckHide(friendUID)
	FriendCalcFinalFighting:Update_ForceTotalData()
end

function WatchingInviteWndController.OnDeleteFriend(eventType, eventID, friendUID)
	WatchingInviteUI.DeleteFriendCheckHide(friendUID)
	FriendCalcFinalFighting:Update_ForceTotalData()
end

function WatchingInviteWndController.MasterDelete(eventType, eventID, masterID)
	WatchingInviteUI.DeleteFriendCheckHide(masterID)
	FriendCalcFinalFighting:Update_ForceTotalData()
end

-- 原则：盖不住 关掉
-- 例如：
-- 1.商城界面 盖住
-- 2.充值界面 盖住
-- 3.首充界面 关掉
-- 4.房间界面 盖住
-- 5.仓库界面 关掉
-- 6.年兽界面 关掉
-- 7.预约确认和成功界面 关掉
-- 8.组队邀请和申请界面 关掉
-- 9.匹配 关掉
-- 10.军团大厅 关掉

-- 邀请好友和聊天,选择模式界面 可以显示。

function WatchingInviteWndController.ShouldPopTips(WatchingInfo)
	--战斗或观战中
	if not _isInLobby then
		log("CalcFinalFighting not _isInLobby")
		return false
	end

	--组队中
	if TeamUpSystem.IsInTeam() then
		log("CalcFinalFighting TeamUpSystem.IsInTeam")
		return false
	end

	-- 设置不显示
	if not WatchingInviteWndController.CanShowInviteForSetting() then
		log("CalcFinalFighting not WatchingInviteWndController.CanShowInviteForSetting")
		return
	end


	-- 不显示的界面
	local ExcludeWndOpens = {FirstRechargeUI.isShowing, WardrobeUI.isShowing, ShopUI.isShow, NianMonsterUI.IsShow, CorpsGuide.IsShow, 
	                         CommonRightNotifyUI.isShowing, TeamUpInviteUI.IsShow, CorpsLobbyUI.IsShow, LobbyUI.isMoreShow, ExpressionUI.expressionShow,
	                         BP_GlobalChatvoiceOpenSpeaker, BP_GlobalChatvoiceOpenRecord}
	for i = 1, #ExcludeWndOpens do
		if ExcludeWndOpens[i] then
			log("CalcFinalFighting ExcludeWndOpens i:"..i)
			return false
		end
	end
	-- 大厅其它界面打开了
	-- if Client.GetUIStackTopPanel() ~= "" then
	-- 	return false
	-- end

	-- 最近弹出过了
	-- if WatchingInviteWndController.HasPopup(WatchingInfo) then
	-- 	return false
	-- end

	return true
end

function WatchingInviteWndController.SwitchToFightingClear()
	FirstRechargeUI.isShowing = false
	WardrobeUI.isShowing = false
	NianMonsterUI.IsShow = false
	CommonRightNotifyUI.isShowing = false
	TeamUpInviteUI.IsShow = false
	CorpsLobbyUI.IsShow = false
	WatchingInviteUI.IsShow = false
	CorpsGuide.IsShow = false
	ShopUI.isShow = false
	LobbyUI.isMoreShow = false
	ExpressionUI.expressionShow = false
	BP_GlobalChatvoiceOpenSpeaker = false
	BP_GlobalChatvoiceOpenRecord = false
	WatchingInviteWndController.isReconnet = false
end

function WatchingInviteWndController.CloseWnd()
	EventWatchingInviteClickIgnore()
end

function WatchingInviteWndController.SetIsPlatFormStartUp(platformStartUp)
	-- log("CalcFinalFighting SetIsPlatFormStartUp true")
	WatchingInviteWndController.IsPlatformStartUp = platformStartUp
end

-- 所有打脸图结束，或返回大厅，或小程序拉起，检查是否有观战
function WatchingInviteWndController.CheckPopFinalFighting()
	WatchingInviteWndController.IsFirstShow = false
	-- log("CalcFinalFighting WatchingInviteWndController.FaceEndCheck call")
	if WatchingInviteWndController.IsPlatformStartUp then
		WatchingInviteWndController.ToLobbyDelayTimer = Timer.InsertTimer(60, WatchingInviteWndController.RellayCheckPopFinalFighting, false)
		WatchingInviteWndController.IsPlatformStartUp = false
	else
		WatchingInviteWndController.ToLobbyDelayTimer = Timer.InsertTimer(5, WatchingInviteWndController.RellayCheckPopFinalFighting, false)
	end
end

function WatchingInviteWndController.RestartCalcInvite()
	-- log("CalcFinalFighting WatchingInviteWndController.RestartCalcInvite call")
	WatchingInviteWndController.RellayCheckPopFinalFighting()
end

function WatchingInviteWndController.ClearInviteData()
	-- log("CalcFinalFighting WatchingInviteWndController.ClearInviteData call")
	WatchingInviteWndController.DelayPopUpWatchInfo = {}
	WatchingInviteWndController.HasPopUpWatchInfo = {}
	FriendCalcFinalFighting:Clear()
end

function WatchingInviteWndController.RellayCheckPopFinalFighting()
	WatchingInviteWndController.ToLobbyDelayTimer = nil
	-- 设置了允许开启才开始计算
	if WatchingInviteWndController.CanShowInviteForSetting() then
		-- log("CalcFinalFighting WatchingInviteWndController.RellayCheckPopFinalFighting Begin")
		FriendCalcFinalFighting:Begin(WatchingInviteWndController.isReconnet)
		WatchingInviteWndController.isReconnet = false
	else
		-- log("CalcFinalFighting WatchingInviteWndController.CanShowInviteForSetting false")
	end
end

function WatchingInviteWndController.LobbyCheckTest()
	if Client.GetUIStackTopPanel() ~= "" then
		log("Client.GetUIStackTopPanel ~= nil")
	else
		log("Client.GetUIStackTopPanel == nil")
	end
end

function WatchingInviteWndController.AddHasPopup(watchInfo)
	local curServerTime = NetUtil.GetCurServerTime()
	WatchingInviteWndController.HasPopUpWatchInfo[watchInfo.uid] = curServerTime
end

function WatchingInviteWndController.HasPopup(watchInfo)
	SameBattleDuration = tonumber( DataMgr.GetSystemConfig("WatchForbidTimeCount") ); 
	if WatchingInviteWndController.HasPopUpWatchInfo[watchInfo.uid] then
		local curServerTime = NetUtil.GetCurServerTime()
		if curServerTime - WatchingInviteWndController.HasPopUpWatchInfo[watchInfo.uid] > SameBattleDuration then
			return false
		end
		return true
	end
	return false
end

-- Submit_PlayerData.uid = player_data.uid;
-- Submit_PlayerData.player_name = player_data.player_name;
-- Submit_PlayerData.relationship_index = player_data.relationship_index;
function WatchingInviteWndController.ReceivePopupInvite(eventType, eventID, WatchingInfo)
	-- log_tree("CalcFinalFighting ReceivePopupInvite call, WatchingInfo:", WatchingInfo)
	-- 状态，界面不满足,或者最近一局弹出过
	if not WatchingInviteWndController.ShouldPopTips(WatchingInfo) then
		return
	end

	if WatchingInviteWndController.HasPopup(WatchingInfo) then
		log("CalcFinalFighting WatchingInviteWndController.HasPopup uid:"..WatchingInfo.uid)
		return
	end

	local curServerTime = NetUtil.GetCurServerTime()
	local cfgSameteamTime = 5
	local cfgSameBattleLimit = Client.GetTableData("SystemConfig", "WatchInviteSameBattleLimit")
	if cfgSameBattleLimit ~= nil then
		cfgSameteamTime = tonumber(cfgSameBattleLimit.ConfigValue)
	end

	WatchingInfo.recvTime = curServerTime
	local cfgInviteIntervalTime = 10
	local uiAnimateShowDelay = 1
	local cfgInviteInterval = Client.GetTableData("SystemConfig", "WatchInviteInterval")
	if cfgInviteInterval ~= nil then
		cfgInviteIntervalTime = tonumber(cfgInviteInterval.ConfigValue)
	end
	local cfgInviteIntervalTimeLimit = 2*cfgInviteIntervalTime + uiAnimateShowDelay
	local twoInviteDuration = curServerTime - WatchingInviteWndController.LastPopupWatchInfoTime
	if twoInviteDuration <= cfgSameteamTime then
		-- log("CalcFinalFighting ReceivePopupInvite <= 5 WatchingInfo.player_name:"..WatchingInfo.player_name)
		return
	elseif twoInviteDuration <= cfgInviteIntervalTimeLimit or WatchingInviteUI.IsShow or #WatchingInviteWndController.DelayPopUpWatchInfo > 0 then
		-- log("CalcFinalFighting ReceivePopupInvite <= 20 Cache Invite")
		WatchingInviteWndController.DelayPopUpWatchInfo[#WatchingInviteWndController.DelayPopUpWatchInfo + 1] = WatchingInfo
		--目的是滤掉后面相同的好友局，说明DelayPopUpWatchInfo都是有效的
		WatchingInviteWndController.LastPopupWatchInfoTime = curServerTime
	else
		-- log("CalcFinalFighting ReceivePopupInvite Direct Popup")
		WatchingInviteWndController.LastPopupWatchInfoTime = curServerTime
		WatchingInviteWndController.AddHasPopup(WatchingInfo)
		WatchingInviteUI.Show(WatchingInfo)
	end
end

function WatchingInviteWndController.GetDelayInviteWatchInfo()
	if #WatchingInviteWndController.DelayPopUpWatchInfo == 0 then
		return false, nil
	end
	local watchInfo = WatchingInviteWndController.DelayPopUpWatchInfo[1]
	if not WatchingInviteWndController.ShouldPopTips(watchInfo) then
		WatchingInviteWndController.DelayPopUpWatchInfo = {}
		-- table.remove(WatchingInviteWndController.DelayPopUpWatchInfo, 1)
		-- log("CalcFinalFighting GetDelayInviteWatchInfo not ShouldPopTips")
		return false, nil
	end

	if not WatchingInviteWndController.HasPopup(WatchingInfo) then
		local watchingInfo = WatchingInviteWndController.DelayPopUpWatchInfo[1]
		WatchingInviteWndController.AddHasPopup(watchingInfo)
		return true, watchingInfo
	else
		return false, nil
	end
end

function WatchingInviteWndController.RemoveDelayInviteWatchInfo(watchInfo)
	for i = 1, #WatchingInviteWndController.DelayPopUpWatchInfo do
		if watchInfo.uid == WatchingInviteWndController.DelayPopUpWatchInfo[i].uid and watchInfo.recvTime == WatchingInviteWndController.DelayPopUpWatchInfo[i].recvTime then
			table.remove(WatchingInviteWndController.DelayPopUpWatchInfo, i)
			-- log("CalcFinalFighting RemoveDelayInviteWatchInfo size:"..tostring(#WatchingInviteWndController.DelayPopUpWatchInfo))
			return
		end
	end
end

-- 通知后台设置关闭按钮
function WatchingInviteWndController.SendWatchRemindSwitch(enable)
	NetUtil.SendPkg("set_watch_remind_switch", enable)
end

function WatchingInviteWndController.CanShowInviteForSetting()
	return LogicLobbyWatching.IsWatchingInviteOpen() and DataMgr.GetCanWatchInvite()
end

