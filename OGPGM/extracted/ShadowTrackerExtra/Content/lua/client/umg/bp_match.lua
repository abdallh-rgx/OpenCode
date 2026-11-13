--匹配界面弹窗
MatchPopupUI = MatchPopupUI or 
{	
}

BP_Estimate_time = 0;
BP_PlayerStatus = 1;
BP_IsTeamLeader = true;
local MatchPopup_NoticeShowed = true;

BP_MatchPopUI_CurLevel = "";	--当前是哪个level（lobby or login etc.）
-- 国际化选服
BP_IsChooingZoneAccess = true;

--弱引导特效是否显示
BP_Teamup_Show_WeakGuide = false;

-- 大厅皮肤id
BP_Match_Cur_Lobby_Skin_Id = 0;

--同语言设置
BP_MatchPopup_SameLanguage = false;
BP_MatchPopup_LanguageSelect1 = "";
BP_MatchPopup_LanguageSelect2 = "";

local MatchPopup_MatchZoneList = {};

BP_MatchPopup_Match_SwitchServer_Time = 10;			-- 跨服匹配的时间
local MatchPopup_IsSwitchServerShowed = false;		-- 判断是否已经弹出跨服匹配
local MatchPopup_Max_ping = 500;					-- 跨服匹配时最大过滤ping值
local MatchPopup_IsSwitchServerShowing = false;		-- 跨服界面是否正在显示	
BP_MatchPopup_IsSwitchServerSuccess = false;		-- 跨服匹配成功	
local MatchPopup_IsTeamLeader = true;				-- 是否是队长

BP_MatchPopup_Match_Last_Time = 0;					-- 从点击开始匹配已经过去的时间
local UpdateTimer = nil;							-- 时间更新timer
local MatchPopup_Limit_Time = 400;					-- 匹配最长限制时间
BP_MatchPopup_LinePos = 0;
BP_MatchPopup_LineSpeed_Min = 0;
BP_MatchPopup_LineSpeed_Max = 0;
--注册widget
function bp_match_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_match,
		{{Path="/Game/UMG/UI_BP/Match/MatchPopup_BP.MatchPopup_BP_C", Container="Default", ZOrder=15}},
		{"Lobby"},
		false,
		bp_match_OnModeSwitched ~= nil
	);

	EventSystem:registEvent(EVENTTYPE_LOBBY_SKIN, EVENTID_LOBBY_SKIN_CHANGE_SEC, MatchPopupUI.OnSetLobbySkinId);
end

function EventFetchInfo()	 
end


--跳转到Lobby
function bp_match_OnModeSwitched(gamestatus)
	BP_MatchPopUI_CurLevel = string.lower(gamestatus);
	if string.lower(gamestatus) == "lobby" then
        --拉起匹配UI--
		MatchPopupUI:Init();
		LanguageSelectSystem.Init();
        if LobbySystem.isInMatch == true then
        	MatchPopupUI.ResetWhenReconnected(NetUtil.GetCurServerTime() - LobbySystem.beginMatchTime);
        end
	end
end

-- 数据重新设置,初始化、开始匹配、匹配成功、取消匹配均会调用
local function ResetData()
	MatchPopup_IsSwitchServerShowing = false;
	BP_MatchPopup_IsSwitchServerSuccess = false;
	BP_MatchPopup_Match_Last_Time = 0;
	MatchPopup_NoticeShowed = true;
	if BP_MatchPopup_Match_SwitchServer_Time <= 0 then
		MatchPopup_IsSwitchServerShowed = true;
	else
		MatchPopup_IsSwitchServerShowed = false;
	end
end

function MatchPopupUI:Init()
	log("MatchPopupUI:Init UIShow");
	LuaClassObj.HandleUIMessage(bp_match, "UIShow");
	ResetData();
	BP_Teamup_Show_WeakGuide = DataMgr.roleData.level <= 3 and not DataMgr.team_up_has_weak_guide;
	EventSystem:registEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_SYNC, MatchPopupUI.MatchUIEventHandler);
	EventSystem:registEvent(EVENTTYPE_NETWORK, EVENTID_LOBBY_SERVER_CONNECT_FAILED, MatchPopupUI.MatchUIEventHandler);
	EventSystem:registEvent(EVENTTYPE_LOGIN, EVENTID_BACKLOGIN, MatchPopupUI.MatchUIEventHandler);
	EventSystem:registEvent(EVENTTYPE_LOGIN, EVENTID_LOGIN_SUCCESS, MatchPopupUI.MatchUIEventHandler);
    EventSystem:registEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN, MatchPopupUI.WardRobeAvatarResetOpen);
    EventSystem:registEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE, MatchPopupUI.WardRobeAvatarResetClose);
end

function MatchPopupUI:Release()
	EventSystem:unregistEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_SYNC, MatchPopupUI.MatchUIEventHandler);
	EventSystem:unregistEvent(EVENTTYPE_NETWORK, EVENTID_LOBBY_SERVER_CONNECT_FAILED, MatchPopupUI.MatchUIEventHandler);
	EventSystem:unregistEvent(EVENTTYPE_LOGIN, EVENTID_BACKLOGIN, MatchPopupUI.MatchUIEventHandler);
	EventSystem:unregistEvent(EVENTTYPE_LOGIN, EVENTID_LOGIN_SUCCESS, MatchPopupUI.MatchUIEventHandler);
    EventSystem:unregistEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN, MatchPopupUI.WardRobeAvatarResetOpen);
    EventSystem:unregistEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE, MatchPopupUI.WardRobeAvatarResetClose);
end

function MatchPopupUI.MatchUIEventHandler(eventType, eventID, vars)
	if eventID == EVENTID_TEAMUP_TEAMINFO_SYNC then
		MatchPopupUI.UpdateState();
	end

	if eventType == EVENTTYPE_NETWORK then
		if eventID == EVENTID_LOBBY_SERVER_CONNECT_FAILED then
			log("大厅连接断开,匹配计时暂停");
			LuaClassObj.HandleUIMessage(bp_match, "StopTimeCounting");
		end	
	end

	if eventType == EVENTTYPE_LOGIN then
		if eventID == EVENTID_BACKLOGIN  or  eventID == EVENTID_LOGIN_SUCCESS then
			if eventID == EVENTID_BACKLOGIN then
				log("----back to login-----");
			end

			if eventID == EVENTID_LOGIN_SUCCESS then
				log("----login(or reconnected log in)-----");
			end
			--判断一下上一次是否是在匹配状态，不是的话没必要刷状态，也没必要刷UI--
			if LobbySystem.isInMatch then
				log("----clear last match state by login msg-----");
				MatchPopupUI.OnMatchCancel();
				LobbySystem.ResetMatchInfo();
			end	
		end
	end
end

local _match_line_show = false;
-- 定时器刷新显示函数,主要是开始匹配用来刷新显示时间用
local function UpdateTimeFunc()
	BP_MatchPopup_Match_Last_Time = BP_MatchPopup_Match_Last_Time + 1;
	if false == MatchPopup_NoticeShowed and  BP_MatchPopup_Match_Last_Time > MatchPopup_Limit_Time and not _match_line_show then
		MatchPopupUI.ShowMatchFailedNotice();
	end
	
	if MatchPopup_IsTeamLeader then	-- 队长才会弹出跨服匹配选择界面
		if false == MatchPopup_IsSwitchServerShowed and BP_MatchPopup_Match_Last_Time > BP_MatchPopup_Match_SwitchServer_Time  then	-- 开始跨服匹配
			LuaClassObj.HandleUIMessageNoFetch(bp_match, "ShowSwitchServerPanel");
			MatchPopup_IsSwitchServerShowed = true;
			MatchPopup_IsSwitchServerShowing = true;
		end
	
		-- 跨服界面正在显示，需要刷新跨服界面的时间
		if MatchPopup_IsSwitchServerShowing then
			LuaClassObj.HandleUIMessageNoFetch(bp_match, "UpdateSwitchServerPanel");
		end
	end
	LuaClassObj.HandleUIMessageNoFetch(bp_match, "UpdateShowTime");
end

-- 增加刷新定时器
local function AddUpdateTimer(lTime)
	MatchPopup_IsTeamLeader = TeamUpSystem.IsTeamLeader();
	if nil == UpdateTimer then
		BP_MatchPopup_Match_Last_Time = lTime;
		UpdateTimer = Timer.InsertTimer(1, UpdateTimeFunc, true, true);
	end
end

-- 取消刷新时间定时器
local function RemoveUpdateTimer()
	if nil ~= UpdateTimer then
		Timer.RemoveTimer(UpdateTimer);
		UpdateTimer = nil;
	end
end

-- 第一、第二语言修改
function MatchPopupUI.SetLanguageSet()
	if nil ~= DataMgr.MatchLanguage then
		BP_MatchPopup_SameLanguage = DataMgr.MatchLanguage.only_match;
		BP_MatchPopup_LanguageSelect2 = LanguageSelectSystem.secondDefautLanguageName;	-- 第二语言默认为空
		for i,v in ipairs(BP_ChatLanguageDataList) do
			if v.id == DataMgr.MatchLanguage[1] then
				BP_MatchPopup_LanguageSelect1 = v.langName;
			end
			if v.id == DataMgr.MatchLanguage[2] then
				BP_MatchPopup_LanguageSelect2 = v.langName;
			end
		end
		log("BP_MatchPopup_SameLanguage .." .. tostring(BP_MatchPopup_SameLanguage));
	end
end

-- 同语言匹配
function MatchPopupUI.SetSameLanguage(isSameLanguage)
	BP_MatchPopup_SameLanguage = isSameLanguage;
    log("BP_MatchPopup_SameLanguage1 .." .. tostring(BP_MatchPopup_SameLanguage));
end

function MatchPopupUI:Hide()
	LuaClassObj.HandleUIMessage(bp_match, "UIHide");
	RemoveUpdateTimer();
end

function MatchPopupUI.WardRobeAvatarResetOpen()
	LuaClassObj.HandleUIMessageNoFetch(bp_match, "UIHideNative");
end

function MatchPopupUI.WardRobeAvatarResetClose()
	--当打开商城的时候 不显示
	if MallSystemUI_2.isShowing == false then
		LuaClassObj.HandleUIMessageNoFetch(bp_match, "UIShowNative");
	end	
end

function EventIsChoosingZoneAccess_Push()
	log("EventIsChoosingZoneAccess_Push, BP_IsChooingZoneAccess = "..tostring(BP_IsChooingZoneAccess));
end

--如果是非队长，这里实际走的是准备协议，美术把按钮做在了一起--
function EventStartMatch()
	if IndiaChampionShipLogic.LobbyMatchCheck() then
		log("EventStartMatch Return by IndiaChampionShipLogic")
		return
	end
	MatchPopupUI.StartMatch()
end

function MatchPopupUI.StartMatch()
	-- 关闭邀请组队展开面板
	EventHideFriendMenu()
	ResetData();

	-- 停止弱引导
	BP_Teamup_Show_WeakGuide = false;
	DataMgr.team_up_has_weak_guide = true;
	MatchPopupUI.StopWeakGuideImmediately();

	log("点击开始匹配");
	LuaClassObj.HandleUIMessage(bp_teamup_model, "ChangeMatchBtnSelectedFalse");
	if BP_IsChooingZoneAccess then
		OkStartMatchCallback();
	else
		textTitle = Client.GetTableData("LocalizeRes", "101001").TextValue; --提示--
		textMsg =  Client.GetTableData("LocalizeRes", "1011").TextValue; --当前所选服务器存在网络问题，会有较高延迟或无法匹配，建议选择其他服务器，是否继续？--
		CommonMessageBoxUI:ShowPanel(2, textTitle, textMsg, OkStartMatchCallback, CancelStartMatchCallback);
		-- CommonMessageBoxUI:ShowPanel(2, "提示", "当前所选服务器存在网络问题，会有较高延迟或无法匹配，建议选择其他服务器，是否继续？", OkStartMatchCallback, CancelStartMatchCallback);
	end
end

function OkStartMatchCallback()
    log("ok, 开始匹配");
    MatchPopup_NoticeShowed = false;
	BattleResult.IgnoreDSError = false;
	LobbySystem.on_start_match_req();
end

function CancelStartMatchCallback()
    log("no, 取消匹配");
    LuaClassObj.HandleUIMessage(bp_teamup, "OpenExpandPanel");
end
    
--非队长的取消准备事件
function EventCancelReady()
	LobbySystem.change_status_req();
end

-- 队长开始匹配申请,用于跨服匹配用
local function OnMatchSwitchServerConfirm()
	-- 为了便于策划配置,时间未0的情况直接不开始跨服匹配,非队长不会显示确认的弹窗
	if BP_MatchPopup_Match_SwitchServer_Time <= 0  or false == MatchPopup_IsTeamLeader then		
		MatchPopup_IsSwitchServerShowed = true;
	else 
		MatchPopup_IsSwitchServerShowed = false;
	end
end

-- 开始匹配，正在匹配中，组队情况下队员获取队长的语言设置回调
function MatchPopupUI.OnStartMathSuccess(matchLang)
	log_tree("MatchPopupUI.OnMathSuccess, matchLang", matchLang);
	if TeamUpSystem.IsTeamLeader() == false then
		BP_MatchPopup_SameLanguage = matchLang.only_match;
		BP_MatchPopup_LanguageSelect2 = LanguageSelectSystem.secondDefautLanguageName;	-- 第二语言默认为空
		for i,v in ipairs(BP_ChatLanguageDataList) do
			if v.id == matchLang[1] then
				BP_MatchPopup_LanguageSelect1 = v.langName;
			end
			if v.id == matchLang[2] then
				BP_MatchPopup_LanguageSelect2 = v.langName;
			end	
		end
	else
		BP_MatchPopup_SameLanguage = BP_MatchPopup_SameLanguage and BP_TeamUpMatchInfo_AutoMatch;
	end

	-- 单人模式、模式和人数一样不显示语言匹配,从组队信息中获取当前队伍人数
	if BP_TeamUpModel_PlayerNum == 1 or TeamUpSystem.GetTeamPlayCount() == BP_TeamUpModel_PlayerNum then
		BP_MatchPopup_SameLanguage = false;
	end
	OnMatchSwitchServerConfirm();
	LuaClassObj.HandleUIMessage(bp_match, "ShowLanguageMatch");	
end

function MatchPopupUI.OnMatchCancel()
	AllianceCompetitionRoomUI.onCancel()
	
	log("OnMatchCancel InitMatchState");
	LuaClassObj.HandleUIMessage(bp_match, "InitMatchState");
	ResetData();
	RemoveUpdateTimer();
end

--更新按钮的状态
function MatchPopupUI.UpdateState()
	log("UpdateState InitMatchState");
	BP_PlayerStatus = TeamUpSystem.GetMyStatus();
	BP_IsTeamLeader = TeamUpSystem.IsTeamLeader();

	if LobbySystem.isInMatch == false then
		LuaClassObj.HandleUIMessage(bp_match, "InitMatchState");
		ResetData();
		RemoveUpdateTimer();
		AllianceCompetitionRoomUI.onCancel();
	end
	--准备也要隐藏空投
	--if BP_PlayerStatus == 1 then --ready
		--LuaClassObj.HandleUIMessage(bp_lobby, "UIHideAirDropEntrance")
	--end

	-- if BP_PlayerStatus == 2 then --unready
	-- 	LuaClassObj.HandleUIMessage(bp_lobby, "UIShowAirDropEntrance")
	-- end
end

function EventCancelMatch()
	LobbySystem.on_match_cancel_req();
	ResetData();
	RemoveUpdateTimer();
end

--拉起界面后显示剩余时间,开始计时
function MatchPopupUI.RefreshRemainTime(estimate_time)
	-- 添加容错处理
	if estimate_time <= 0 or estimate_time >= 3600 then
		estimate_time = 3600
	end
	
	BP_Estimate_time = estimate_time;
	-- BP_Estimate_time = 138;
	log("RefreshRemainTime RefreshMatchingInfo");
	LuaClassObj.HandleUIMessage(bp_match, "RefreshMatchingInfo");
	AddUpdateTimer(BP_MatchPopup_Match_Last_Time);
end

function MatchPopupUI.ResetWhenReconnected(lTime)
	LuaClassObj.HandleUIMessage(bp_match, "ResetWhenReconnected");
	AddUpdateTimer(lTime);
end

function MatchPopupUI.ShowMatchFailedNotice()
	--local title = "提示";
	--local content = "未找到玩家，是否继续匹配?";
    local title = Client.GetTableData("LocalizeRes", "101001").TextValue	
    local content = Client.GetTableData("LocalizeRes", "301169").TextValue
	CommonMessageBoxUI:ShowPanel(2, title, content, MatchPopupUI.NoticeSureCallback, MatchPopupUI.NoticeCancelCallback);
	MatchPopup_NoticeShowed = true;
end

function MatchPopupUI.NoticeSureCallback()
	log("继续等待匹配");
end

function MatchPopupUI.NoticeCancelCallback()
	log("超时取消匹配");
	LobbySystem.on_match_cancel_req();
end

function MatchPopupUI.ShowMatchSuccess()
	if MatchPopup_NoticeShowed then
		LuaClassObj.HandleUIMessage(bp_common_messagebox_panel, "UIHide");
	end
	
	RemoveUpdateTimer();
	ResetData();
	log("SetAsMatchSuccess");
	LuaClassObj.HandleUIMessage(bp_match, "SetAsMatchSuccess");
end

function MatchPopupUI.OnApplicationDeactive()
	log("---切后台，匹配状态先不要切换--");
end

function MatchPopupUI.OnApplicationReactive()
	log("---match ui receive application reactive message---");

	if LobbySystem.isInMatch then
		log("---reset match waiting time when reactive---");
		MatchPopupUI.ResetWhenReconnected(NetUtil.GetCurServerTime() - LobbySystem.beginMatchTime);
	end

	if BP_MatchPopUI_CurLevel == "lobby" then
		--查询匹配状态只在大厅的时候去请求--
		LobbySystem.QueryMatchStatus();
	end
end

function MatchPopupUI:Release()
end

function MatchPopupUI.ShowWeakGuideImmediately()
	BP_Teamup_Show_WeakGuide = true;
	LuaClassObj.HandleUIMessageNoFetch(bp_match, "ShowWeakGuideImmediately");
end

function MatchPopupUI.StopWeakGuideImmediately()
	BP_Teamup_Show_WeakGuide = false;
	LuaClassObj.HandleUIMessageNoFetch(bp_match, "ShowWeakGuideImmediately");
end

-- 根据皮肤设置按钮样式
function MatchPopupUI.OnSetLobbySkinId(eventType, eventID, skinid)
	local bUIAutoTest = Client.IsUIAutoTest();
	if bUIAutoTest then
		skinId = 10004
	end
	
	BP_Match_Cur_Lobby_Skin_Id = skinid;
	LuaClassObj.HandleUIMessage(bp_match, "OnSwitchSkin");
end

-- 开始跨服匹配申请
function EventMatchStartSwitchServer()	
	--所有分区进行排序
	local zoneList = {};
    local delayList = {};
	for i,v in pairs(TeamUpSystem.ChooseZoneList) do
		local delay = Client.GetServerDelay(v.tpingsvr_ip)	
        log("zoneid:"..v.zone_id.." delay:"..delay);
		if delay <= MatchPopup_Max_ping then			-- 过滤掉延迟超过阈值的区		
				local minIndex = #delayList + 1;
				for index, zoneDelay in pairs(delayList) do
					if delay < zoneDelay then
						minIndex = index;
                        break;
					end
				end
				table.insert(zoneList, minIndex, v.zone_id);
                table.insert(delayList, minIndex, delay);
		end
	end
	log_tree("zoneList", zoneList)
    log_tree("delayList", delayList)
	NetUtil.SendPkg("on_match_across_zone_req", zoneList);
	BP_MatchPopup_IsSwitchServerSuccess = false;
	MatchPopup_IsSwitchServerShowing = false;
end

-- 跨服匹配协议回调
-- wrong_state not_leader invalid_zone_seq not_found already
function MatchPopupUI.on_match_across_zone_res(msg)
	log("on_match_across_zone_res:"..tostring(msg));
	if msg == "ok" then
		BP_MatchPopup_IsSwitchServerSuccess = true;
		LuaClassObj.HandleUIMessage(bp_match, "OnSwitchServerShowTips");
	end
end

-- 取消跨服匹配申请
function EventMatchCancelSwitchServer()	
	MatchPopup_IsSwitchServerShowing = false;
end

-- 登录匹配相关参数回包
function MatchPopupUI.SetMatchParam(cross_time, cross_max_ping, zoneList)
	log("MatchPopupUI.SetMatchParam, cross_time:"..tostring(cross_time).." cross_max_ping:"..tostring(cross_max_ping));
	BP_MatchPopup_Match_SwitchServer_Time = cross_time or 0;
	if BP_MatchPopup_Match_SwitchServer_Time <= 0 then
		MatchPopup_IsSwitchServerShowed = true;
	end
	if nil ~= cross_max_ping and cross_max_ping > 0 then 
		MatchPopup_Max_ping = cross_max_ping;
	end
	MatchPopup_MatchZoneList = zoneList;
	MatchPopupUI.SetMatchParamByZoneList()
end

-- 使用后台下发的Zone表进行登录匹配参数选择
function MatchPopupUI.SetMatchParamByZoneList()
	if MatchPopup_MatchZoneList ~= nil and MatchPopup_MatchZoneList[TeamUpSystem.ChooseZoneId] then
		local temp = MatchPopup_MatchZoneList[LobbySystem.matchZone];
		log_tree("||||MatchPopup_MatchZoneList ",temp)
		MatchPopup_Max_ping = temp.cross_zone_max_ping;
		BP_MatchPopup_Match_SwitchServer_Time = temp.cross_zone_time_s;
		log("MatchPopupUI.SetMatchParamByZoneList ZoneId : " .. LobbySystem.matchZone .. "|| MatchPopup_Max_ping = " .. MatchPopup_Max_ping .. "|| BP_MatchPopup_Match_SwitchServer_Time = " .. tostring(BP_MatchPopup_Match_SwitchServer_Time))
	end
end

function MatchPopupUI.CheckWaitingState(line_pos, line_speed)
	if not line_pos or not line_speed or line_pos <=0 then
		_match_line_show = false
		return
	end
	_match_line_show = true
	BP_MatchPopup_LinePos = line_pos;
	local _range = math.ceil(line_speed/10)
	BP_MatchPopup_LineSpeed_Min = line_speed - _range < 0 and 0 or line_speed - _range;
	BP_MatchPopup_LineSpeed_Max = line_speed + _range < 0 and 0 or line_speed + _range;
	LuaClassObj.HandleUIMessage(bp_match, "ShowWaitingLinePanel");
end

--[[网络回调]]--
s2c = s2c or {};
s2c["on_match_across_zone_res"] = MatchPopupUI.on_match_across_zone_res;	-- 跨服匹配