-- 军团UI

CorpsBaseUI = CorpsBaseUI or {
	isShow = false;
	isOnlyShow = true;
	isVisible = false;
	selectedIndex = 1;

	showFunctionMapping = {};
	hideFunctionMapping = {};
	animFunctionMapping = {};

	PageMain = 1;			-- 主页
	PageBaseInfo = 2;		-- 信息
	PageMission = 3;		-- 任务
	PageMall = 4;			-- 商城
	PageRank = 5;			-- 排行
	PageWelfare = 6;		-- 福利
	PageMerit = 7;			-- 功勋墙
	PageCompetition = 8;	-- 练习赛
	PageMax = 8;
}

BP_CorpsBase_SelectedIndex = 1;

BP_Array_CorpsBaseUI_RedPoint = {false};

BP_Array_CorpsBaseUI_ShowTab = {true};

--注册Widget
function bp_corps_base_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_corps_base,
		{{Path="/Game/UMG/UI_Logic/Corps/Corps_Logic_BP.Corps_Logic_BP_C", Container="Default", ZOrder=BP_ENUM_UI_OWN_CORPS_ZORDER}},
		{"Lobby"},
		false,
		nil ~= bp_corps_base_OnModeSwitched,
		true
	);

	LuaClassObj.SubShowHideEvent(bp_corps_base, { "Corps_Logic_BP_C" });

	EventSystem:registEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_APPLYLIST, CorpsBaseUI.UpdateRedPoint);
	EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_CORPS, CorpsBaseUI.JumpIn);
end

function bp_corps_base_OnModeSwitched(gamestatus)
	CorpsBaseUI.isShow = false;
	CorpsBaseUI.isVisible = false;
	CorpsBaseUI.selectedIndex = 1;
end

function CorpsBaseUI.JumpIn(eventType, eventID, vars)
	log("$$CorpsBaseUI.JumpIn")
	if CorpsBaseUI.isShow == false then
		CorpsBaseUI.Init()
	end

	if vars and vars.id then
		if CorpsBaseUI.isShow then
			CorpsMgr.SendCorpsDataReq();
			CorpsBaseUI.JumpToPage(tonumber(vars.id))
		end
	else
		log("$$CorpsBaseUI.JumpIn error")
	end
end

--[[
	下标：CorpsUI.PageXXX
	打开界面回调（Creation&&Show）
	关闭界面回调
	打开界面动画回调
]]

function CorpsBaseUI.RegisterCallBacks(index, show_func, hide_func, anim_func)
	log("CorpsBaseUI.RegisterCallBacks index ="..index)
	if nil ~= show_func then
		CorpsBaseUI.showFunctionMapping[index] = show_func;
	end

	if nil ~= hide_func then
		CorpsBaseUI.hideFunctionMapping[index] = hide_func;
	end

	if nil ~= anim_func then
		CorpsBaseUI.animFunctionMapping[index] = anim_func;
	end
end

function CorpsBaseUI.Init()
	
	if DataMgr.corpsInfo.id == 0 then
		ShowNotice(411008);
		return;
	end

	log("CorpsBaseUI.Init");
	CorpsBaseUI.isShow = true;
	CorpsBaseUI.ChangeIsOnlyShow(true)
	--[[
	TeamUPFriendUI.HideFriendListBtn();
	local IsShow = TeamUPFriendUI.GetTeamUPFriendIsShow();
	if IsShow == true then
		TeamUPFriendUI.SetTeamUPFriendIsShow(false);
		TeamUPFriendUI.HidePanel();
	end
	]]

	BP_Array_CorpsBaseUI_RedPoint = {};
    for i=1, CorpsBaseUI.PageCompetition do
        BP_Array_CorpsBaseUI_RedPoint[i] = false;
    end

	-- CorpsBaseUI.UpdateRedPoint();
	LuaClassObj.HandleUIMessage(bp_corps_base, "UnCheckButton");
	CorpsBaseUI.HideSelectedPage(CorpsBaseUI.selectedIndex);
	BP_CorpsBase_SelectedIndex = 1;
	CorpsBaseUI.selectedIndex = 1;
	LuaClassObj.HandleDynamicCreation(bp_corps_base);
	LuaClassObj.HandleUIMessage(bp_corps_base, "ShowUI");
	UIManager.Show(eUIType.eCorpsBaseUI);
	EventCorpsOnAfterShow();
	-- CorpsMgr.SendCorpsDataReq(true)
	-- CorpsMgr.TaskGetDataReq() --测试用
	CorpsRankSystem.SendGetMyRankData(101)
	EventSystem:registEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_CORPS_ID, CorpsBaseUI.OnCorpsIDUpdate);
end

-- 用于福利界面，show一次，防止和主界面出现层级错误
function CorpsBaseUI.JustShowUI()
	LuaClassObj.HandleUIMessageNoFetch(bp_corps_base, "JustShow");	-- show一次，防止和主界面出现层级错误
end

function CorpsBaseUI.HideUI()
	EventCorpsClose();
end

-- 暂时先不要调用这个release，其他function的注册都是在_RegisterUI中 清掉会有问题了
function CorpsBaseUI.Release()
	log("CorpsBaseUI.Release");
	CorpsBaseUI.isVisible = false;
	LobbyChatEntranceUI.SetInCorps(false);
	showFunctionMapping = {};
	hideFunctionMapping = {};
	animFunctionMapping = {};
end

function CorpsBaseUI.ShowSelectedPage(index)
	log("CorpsBaseUI.ShowSelectedPage " .. tostring(index));

	if nil ~= CorpsBaseUI.showFunctionMapping[index] then
		CorpsBaseUI.showFunctionMapping[index]();
	end
end

function CorpsBaseUI.HideSelectedPage(index)
	log("CorpsBaseUI.HideSelectedPage" .. tostring(index));

	if nil ~= CorpsBaseUI.hideFunctionMapping[index] then
		CorpsBaseUI.hideFunctionMapping[index]();
	end
end
--用于跳转至对应page，包括设置对应checkButton状态
function CorpsBaseUI.JumpToPage(index)
	log("CorpsBaseUI.JumpToPage")
	local oldIndex = CorpsBaseUI.selectedIndex;
	CorpsBaseUI.HideSelectedPage(oldIndex);
	LuaClassObj.HandleUIMessage(bp_corps_base, "UnCheckButton");

	BP_CorpsBase_SelectedIndex = index;
	CorpsBaseUI.selectedIndex = index;
	LuaClassObj.HandleUIMessage(bp_corps_base, "CheckButton");
	CorpsBaseUI.ShowSelectedPage(CorpsBaseUI.selectedIndex);
end

function CorpsBaseUI.PlayStartupAnimation(index)
	log("CorpsBaseUI.PlayStartupAnimation" .. tostring(index));
	
	if nil ~= CorpsBaseUI.animFunctionMapping[index] then
		CorpsBaseUI.animFunctionMapping[index]();
	end
end

--关闭界面
function EventCorpsClose()
		log("EventCorpsClose");
	if false == CorpsBaseUI.isShow then
		return;
	end

	--[[
	local isInRoomWaiting = RoomWaitingUI.IsShow;
	if isInRoomWaiting == false then
		TeamUPFriendUI.ShowFriendListBtn();
	end
	]]
	
	CorpsBaseUI.isShow = false;	
	BP_CorpsHomepageShowAnimation = true
	CorpsBaseUI.HideSelectedPage(CorpsBaseUI.selectedIndex);
	CorpsBaseUI.selectedIndex = CorpsBaseUI.PageMain;
	BP_CorpsBase_SelectedIndex = CorpsBaseUI.PageMain;
	UIManager.Hide(eUIType.eCorpsBaseUI);
    LuaClassObj.HandleUIMessage(bp_corps_base, "HideUI");
	EventSystem:unregistEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_CORPS_ID, CorpsBaseUI.OnCorpsIDUpdate);
	CorpsManagerUILogic.HideUI();
	if CorpsMgr.isJumpFromMall then
		MallSystem.OpenUIWithLastState();
		CorpsMgr.isJumpFromMall = false;
	end
end

function EventOnSelectIndex()
	log("EventOnSelectIndex")
	local oldIndex = CorpsBaseUI.selectedIndex;
	CorpsBaseUI.HideSelectedPage(oldIndex);
	
	CorpsBaseUI.selectedIndex = BP_CorpsBase_SelectedIndex;
	CorpsBaseUI.ShowSelectedPage(CorpsBaseUI.selectedIndex);
end

function EventCorpsOnAfterShow()
	CorpsBaseUI.isVisible = true;	
	CorpsBaseUI.ShowSelectedPage(CorpsBaseUI.selectedIndex);
	CorpsBaseUI.PlayStartupAnimation(CorpsBaseUI.selectedIndex);
	CorpsBaseUI.UpdateRedPoint();
	--LobbyChatEntranceUI.SetInCorps(true);
	
	for i=1,CorpsBaseUI.PageMax do
		BP_Array_CorpsBaseUI_ShowTab[i] = false;
	end

	CorpsBaseUI.SetShowTab(CorpsBaseUI.PageMain, BP_ENUM_CORPS_UI_MAIN);
	CorpsBaseUI.SetShowTab(CorpsBaseUI.PageBaseInfo, BP_ENUM_CORPS_UI_BASE_INFO);
	CorpsBaseUI.SetShowTab(CorpsBaseUI.PageMission, BP_ENUM_CORPS_UI_MISSION);
	CorpsBaseUI.SetShowTab(CorpsBaseUI.PageMall, BP_ENUM_CORPS_UI_MALL);
	CorpsBaseUI.SetShowTab(CorpsBaseUI.PageRank, BP_ENUM_CORPS_UI_RANK);
	CorpsBaseUI.SetShowTab(CorpsBaseUI.PageWelfare, BP_ENUM_CORPS_UI_WELFARE);
	CorpsBaseUI.SetShowTab(CorpsBaseUI.PageMerit, BP_ENUM_CORPS_UI_MERIT);
	CorpsBaseUI.SetShowTab(CorpsBaseUI.PageCompetition, BP_ENUM_CORPS_UI_COMPETITION);

	LuaClassObj.HandleUIMessage(bp_corps_base, "UpdateAfterShow");

end

function CorpsBaseUI.SetShowTab(page, switchID)
	local switch = LobbySystem.LobbyMenuOpenStatus[switchID];
	BP_Array_CorpsBaseUI_ShowTab[page] = not switch or switch.is_open == 1;
end

function EventOnAfterHide()
	CorpsBaseUI.HideSelectedPage(CorpsBaseUI.selectedIndex);
	LuaClassObj.HandleUIMessage(bp_corps_base, "UnCheckButton");
	CorpsBaseUI.isVisible = false;
	LobbyChatEntranceUI.SetInCorps(false);
	CorpsUI.CheckReOpenRoleInfo();
end

function CorpsBaseUI.UpdateRedPoint()
	if not CorpsBaseUI.isShow then
		return
	end
	-- 更新信息小红点
	BP_Array_CorpsBaseUI_RedPoint[CorpsBaseUI.PageMain] = CorpsMgr.HasRedDot("home_panel");
	BP_Array_CorpsBaseUI_RedPoint[CorpsBaseUI.PageBaseInfo] = CorpsMgr.HasRedDot("info_panel");
	BP_Array_CorpsBaseUI_RedPoint[CorpsBaseUI.PageMall] = CorpsMgr.HasRedDot("store_panel");
	BP_Array_CorpsBaseUI_RedPoint[CorpsBaseUI.PageMission] = CorpsTaskUI.GetTaskRedDot();
	BP_Array_CorpsBaseUI_RedPoint[CorpsBaseUI.PageRank] = Is_Corps_Rank_Have_Award;
	BP_Array_CorpsBaseUI_RedPoint[CorpsBaseUI.PageWelfare] = Is_Corps_Welfare_Have_Receive;
	LuaClassObj.HandleUIMessage(bp_corps_base, "UpdateRedPoint");
	UpdateLobbyCorpsRedDot(CorpsMgr.HasRedDot("lobby"));
end

function CorpsBaseUI.OnCorpsIDUpdate()
	if DataMgr.corpsInfo.id == 0 then
		log("CorpsBaseUI.OnCorpsIDUpdate");
		EventCorpsClose();
		PopUpNoticeUI:Hide()
		ShowNotice(410017);
	end
end

function CorpsBaseUI.ChangeIsOnlyShow(isOnlyShow)
	log("CorpsBaseUI.ChangeIsOnlyShow:" .. tostring(isOnlyShow))
	CorpsBaseUI.isOnlyShow = isOnlyShow
	if CorpsBaseUI.isOnlyShow then
		LuaClassObj.HandleUIMessageNoFetch(bp_corps_base, "UIOnlyShow");
	else
		LuaClassObj.HandleUIMessageNoFetch(bp_corps_base, "UIOnlyHide");
	end
end

function CorpsBaseUI.GetStatus()
	log("CorpsBaseUI.GetStatus:" .. tostring(CorpsBaseUI.isOnlyShow))
	return {isOnlyShow = CorpsBaseUI.isOnlyShow}
end

function CorpsBaseUI.RecoverStatus(status)
	if status and status.isOnlyShow ~= nil then
		log("CorpsBaseUI.RecoverStatus:" .. tostring(status.isOnlyShow))
		CorpsBaseUI.ChangeIsOnlyShow(status.isOnlyShow)
	end
	
end