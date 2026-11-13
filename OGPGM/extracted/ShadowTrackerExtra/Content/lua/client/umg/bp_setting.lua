--设置界面

SettingUI = SettingUI or 
{
	bShow = false,
	bAutoBind = false,
}

--设置界面区分大厅和游戏内--
BP_IsInLobby = false;
BP_IsInGame = false;
BP_CurSettingPage = 1;
BP_UrlStr1 = "http://game.qq.com/contract.shtml";
BP_UrlStr2 = "http://www.tencent.com/en-us/zc/privacypolicy.shtml";
BP_UrlStr3 = "http://www.tencent.com/en-us/zc/termsofservice.shtml";
--韩：年龄等级分类链接
BP_GradeSeparation_UrlStr = "https://www.grac.or.kr/Institution/EtcForm01.aspx";
--绑定的社交平台渠道（FB 1 GC 2 GP3 TW 6）
BP_BindChannel = 0;
BP_BindRetCode = 0;
BP_BindThirdRetCode = 0;

--iTOP绑定事件
BP_Setting_IMSDKNotifyEvent=0;
--账号系统通用提示框确认按钮回调
BP_Setting_IMSDKTipMsgBtnOKEvent=0;

--登陆平台（微信，手Q）
BP_LoginChannel = 1;
BP_CanShowVideoSetting = true;

BP_SettingPlayerLevel = 0;
BP_SettingFresherType = 0;
BP_DiyLimitLevel = 0;
BP_SettingCanShowHistory = true;
BP_SettingShowWatchingFlag = 1; -- 设置界面内的开 or 关, 0表示禁止1表示允许
BP_SettingIsWatchingOpen = true; -- 面板开关表中配置是否开启设置项
BP_SettingCanShowRole = true;

BP_SettingFirstLoginStrChannel = "";
BP_SettingSecondLoginStrChannel = "";

BP_SettingMaxLoginTypeNum = 5;

-- 战斗内观战
BP_SettingBattleWatchingDetailOpen = true -- 观战界面允许他人查看段位功能是否开启
BP_SettingBattleWatchingDetailFlag = 1 -- 观战界面允许他人查看段位开 or 关, 0表示禁止1表示允许

--第二帐号绑定开关:全球和日韩
BP_OPEN_SECOND_BIND_GLOBAL = 1;
BP_OPEN_SECOND_BIND_JK = 1;


--page index
BP_SettingIndexBasic = 1;
BP_SettingIndexPicture = 2;
BP_SettingIndexOperate = 3;
BP_SettingIndexVehicle = 4;
BP_SettingIndexSensibility = 5;
BP_SettingIndexPickup = 6;
BP_SettingIndexSound = 7;
BP_SettingIndexPrivacy = 9;
BP_SettingIndexLanguage = 10;
BP_SettingIndexVideo = 11;
BP_SettingIndexSubsciption = 12;	--pubg have not got
BP_SettingIndexMirrativ = 13;
BP_SettingIndexOBS = 14;
BP_SettingIndexInfoBinding = 15;    --个人信息绑定
BP_SettingIndexAimingMirrior = 16;

--信鸽推送开关，默认日韩开启，全球关闭
BP_SHOW_XGPUSH_OFF_GLOBAL = 0;
BP_SHOW_XGPUSH_OFF_JK = 1;
BP_XGPUSH_OFF_TIP_CODE = 0;--文字ID


--logic page num
BP_SettingSelectedPage = 1;
BP_SettingCurrentOpenPage = 0;

BP_krjp_del_account_left_time = 0;
BP_KRJPDelAccountSwitch = false;


---惩罚机制开关
BP_SettingCanShowEscapeNotice = false;

-- 排序后的登录类型列表, 空就是没有
BP_ARRAY_SettingLoginTypeOrderList =
{
    "",
    "",
    "",
    "",
    "",
}

BP_Unknow_Pass_Switch_UI = true;
-- BP_Unknow_Pass_Switch_Battle_Title = true;
BP_Unknow_Pass_Switch_Battle_Show = true;
BP_JP_Mirrativ_Show = true;

--大厅皮肤和背景音乐开关
BP_SettingLobbySkinID = 0;
BP_SettingLobbyBgmID = 0;
BP_SettingLobbyIsShowChristmas = false;

--异形屏枚举（1普通，2圆角，3刘海）
BP_ShapedScreenType = 0;

--异形屏当前设置界面选择的枚举（还没点确定点的临时变量）
BP_ShapedScreenCurrentSelectType = 0;

--helpshift请求间隔时间
HelpshiftRequestCD = 300;
HelpshiftLastRequestTime = 0;

--注册widget
function bp_setting_RegisterUI()
  LuaClassObj.SubUIWidgetList(bp_setting,
    {{Path="/Game/UMG/UI_BP/Setting/Setting_UIBP.Setting_UIBP_C", Container="Default", ZOrder = 50}},
    {"Lobby", "Fighting"},
	false,
	bp_setting_OnModeSwitched ~= nil,
	true
  );
  --[[
  if GlobalData:IsIOSCheck() then
        LuaClassObj.SubCollapseWidgetList(bp_setting,
            "Setting_UIBP_C",
            {
                "Overlay_CustomerServiceFather",
            }
        );
    end
]]
    EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_SETTING, SettingUI.OnJumpUrl);
	EventSystem:registEvent(EVENTID_NET_ROLE_INFO_RSP, BP_ENUM_MODULE_SETTING, SettingUI.OnGetRoleInfoRsp);
end



--跳转到Lobby
function bp_setting_OnModeSwitched(gamestatus)
	if string.lower(gamestatus) == "lobby" then
		BP_IsInLobby = true;
		BP_IsInGame = false;
	elseif string.lower(gamestatus) == "fighting" then
		BP_IsInLobby = false;
		BP_IsInGame = true;
	end

	--log("bp_setting_OnModeSwitched"..BP_IsInGame);
	if string.lower(gamestatus) == "login" and LoginSystem.hasLogout then
        SettingUI:Hide()
    end
end

--通用的开关类按钮--
function EventClickSwitchButton()
	-- body
end

function EventFetchInfo()
	 
end

function SettingUI.CloseOtherLobbyMenus()
	EventLeaveLobby()
	if BP_Lobby_OpenShoporWardrobe == false then
		EventHideScrollMsg()
	end
end

local timerCaChe = nil;
function SettingUI:Init()
	--log("songGT  SettingUI:Init")
	BP_LoginChannel = Client.GetLoginChannel(NetInterface);
	-- 这个判定不对
	-- if GlobalData:IsPlatformTourist() then
	-- 	log("GlobalData:IsPlatformTourist,BP_CanShowVideoSetting false")
	-- 	BP_CanShowVideoSetting = false;
	-- end
	if GlobalData:IsIOSCheck() then
		log("GlobalData:IsIOSCheck,BP_CanShowVideoSetting false")
		BP_CanShowVideoSetting = false;
	end
	BP_CanShowVideoSetting = false;
	
	BP_SettingPlayerLevel = DataMgr.roleData.level;

	BP_krjp_del_account_left_time = DataMgr.krjp_del_account_left_time;
	if LoginSystem.commonSwitch ~= nil and LoginSystem.commonSwitch.KRJPDelAccountSwitch ~= nil then
		BP_KRJPDelAccountSwitch = LoginSystem.commonSwitch.KRJPDelAccountSwitch;
	end

	--BP_SettingFresherType = DataMgr.fresher_type;
	-- 观战相关设置
	self:InitWatchingInfo()
	--if nil ~= timerCaChe then
	--	Timer.RemoveTimer(timerCaChe);
	--	timerCaChe = nil;
	--end
	--timerCaChe = Timer.InsertTimer(0.1,WaitShow,false,false);
	WaitShow()
	--SettingUI.bAutoBind = false;
end

function WaitShow()
	SettingUI.CloseOtherLobbyMenus()
    LuaClassObj.HandleDynamicCreation(bp_setting);
	LuaClassObj.HandleUIMessage(bp_setting, "UIShow");
	SettingUI.bShow = true;
	-- 向服务器拉取查看历史战绩设置
	SettingUI.get_role_privacy_rsp(true);
	SettingUI.get_role_privacy();

	--查看绑定界面是否展示
	NetUtil.SendPkg("get_account_bind_req")
	
	--sami 刷新开关数据
	local myUid = DataMgr.roleData.uid;
	local playerInfo = ProfileMgr.GetRoleInfoDataByUid(myUid);
	if playerInfo ~= nil then
		SettingUI:UpdateSwitchShowRole();
		log("SettingUI:Init UpdateSwitchShowRole ");
	end
    ProfileMgr.get_avatar_show_req(myUid, AvatarShowSource.FromOther);
	
	LobbyChatSystem.topic_fetch_lang_list_req();
end

function SettingUI.OnJumpUrl(eventType, eventID, vars)
	log("[HHF]SettingUI.OnJumpUrl, eventType = " .. tostring(eventType) .. ", enentID = " .. tostring(eventID) .. ", vars" .. tostring(vars));
	--log_tree("vars = ", vars);

	if not LobbyUI:CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_SETTING) then
        BP_Lobby_MenuOpen = false
        log("[HHF]SettingUI.OnJumpUrl, BP_Lobby_MenuOpen = false");
        return
    end

    if vars.source ~= nil and vars.source == "bindfacebook" then
    	--EventSettingPanelAskBindAccountMsgBox();
	    SettingUI.bAutoBind = true;
    else
        SettingUI.bAutoBind = false;
    end

    BP_Lobby_MenuOpen = true
    SettingUI:Init();
    ClientSendBAReport(BP_BA_LOBBY_SETTING_PANEL, 0);
end

function SettingUI.AutoBindFacebook()
	log("[HHF]SettingUI.AutoBindFacebook, SettingUI.bAutoBind = " .. tostring(SettingUI.bAutoBind));
	if SettingUI.bAutoBind == true then
		SettingUI.bAutoBind = false;
		EventSettingPanelAskBindAccountMsgBox();
	end
end

function EventHelpshiftShowConversation()
	--log("helpshift show conversation");
	Client.HelpshiftShowConversion();
end

function EventHelpshiftSetRedPoints()
	--Lobby_Logic_BP的RefreshTimer中调用此函数的间隔为5秒
	HelpshiftLastRequestTime = HelpshiftLastRequestTime + 5;
	if HelpshiftLastRequestTime > HelpshiftRequestCD then
		HelpshiftLastRequestTime = 0;
		log("EventHelpshiftSetRedPoints Request helpshift")
		Client.HelpshiftRequestUnreadMessagesCount();
	end
	-- 上边是个异步调用，下一次调用本函数下边的值才会更新。不影响逻辑
	local count = Client.HelpshiftGetUnreadMessgesCount();
	if count ~= 0 then
		--log("helpshift red on");
		LobbyUI:LobbyRedPointUpdate(BP_ENUM_LOBBY_MENU_SETTING, true);
		LuaClassObj.HandleUIMessage(bp_setting, "TurnOnHelpRedPoint");
	else
		EventHelpshiftClearRedPoints();
	end
end

function EventHelpshiftClearRedPoints()
	--log("helpshift red clear");
	Client.HelpshiftClearUnreadMessgesCount();
	local ActorVoiceSystem = require("client.slua.logic.actor_voice.logic_actor_voice")
	if ActorVoiceSystem.GetNewActorID() == 0 then
		LobbyUI:LobbyRedPointUpdate(BP_ENUM_LOBBY_MENU_SETTING, false);
	end
end

function EventRefreshSettingRedPoint()
	LobbyUI:LobbyRedPointUpdate(BP_ENUM_LOBBY_MENU_SETTING, false);
end

function EventHideAllSettingPanel()
	SettingUI:Hide();
end

function EventShowBackToLobbyNotice()
	local function confirmClick()
		log("--游戏内,退出回到大厅 ---");
        BP_LoadingTo = 0
		LoadingUI:Init();
		SettingUI:Hide();
		--游戏中退出到大厅，请求退出游戏--
		NetUtil.SendPkg("giveup_enter_game");
		Client.ReturnToLobby(GameFrontendHUD);
	end

	if BP_SettingCanShowEscapeNotice then 
		local timeN = tonumber(DataMgr.GetSystemConfig("EscapeTipChangeNum"));
		log("*********EscapeTipChangeNum = " ..tostring(timeN));
		log("*********current_escape_time = "..tostring(LobbySystem.forcedExitGameTimes));

		--> 110152
		if LobbySystem.forcedExitGameTimes >= timeN then
			CommonMessageBoxUI:ShowPanel(2, Client.GetTableData("LocalizeRes", "101001").TextValue, Client.GetTableData("LocalizeRes", "110152").TextValue, confirmClick);
		else
			CommonMessageBoxUI:ShowPanel(2, Client.GetTableData("LocalizeRes", "101001").TextValue, Client.GetTableData("LocalizeRes", "110140").TextValue, confirmClick);
		end
	else
		CommonMessageBoxUI:ShowPanel(2, Client.GetTableData("LocalizeRes", "101001").TextValue, Client.GetTableData("LocalizeRes", "110140").TextValue, confirmClick);
	end
end

function EventShowNoticeFromObserveToLobby()
	local function confirmClick()
		log("--观战,退出回到大厅 ---");
        BP_LoadingTo = 0
		LoadingUI:Init();
		SettingUI:Hide();
		--观战中退出到大厅，请求退出观战--
		RoomSystem.leave_room_battle_watch()
		NetUtil.SendPkg("giveup_enter_game");
		Client.ReturnToLobby(GameFrontendHUD);
	end

	CommonMessageBoxUI:ShowPanel(2, Client.GetTableData("LocalizeRes", "101001").TextValue, Client.GetTableData("LocalizeRes", "110140").TextValue, confirmClick);
end

function EventHideAllNoticeFromObserveToLobby()
	log("--观战,退出回到大厅 关闭弹窗---");
	CommonMessageBoxUI:HideAllMessageBox();
end

function EventShowNoticeFromWatchingBackToLobby()
	local function confirmClick()
		log("--观战,退回到大厅 ---");
        BP_LoadingTo = 0
		LoadingUI:Init();
		SettingUI:Hide();
		--观战中退回到大厅，请求退出好友观战--
		NetUtil.SendPkg("leave_battle_watch");
		LobbySystem.ReturnToLobby();
	end

	CommonMessageBoxUI:ShowPanel(2, Client.GetTableData("LocalizeRes", "101001").TextValue, Client.GetTableData("LocalizeRes", "110148").TextValue, confirmClick);
end

function EventShowBackToLobbyFromTrainingNotice()
	local function confirmClick()
		log("--训练场,退出回到大厅 ---");
        BP_LoadingTo = 0
		LoadingUI:Init();
		SettingUI:Hide();
		--游戏中退出到大厅，请求退出游戏--
		NetUtil.SendPkg("giveup_enter_game");
		LobbySystem.ReturnToLobby();
	end

	CommonMessageBoxUI:ShowPanel(2, Client.GetTableData("LocalizeRes", "101001").TextValue, Client.GetTableData("LocalizeRes", "110140").TextValue, confirmClick);
end

function EventShowLogOutNoticce()
    local function LogOut()
        log("...log out from settingUI...");       
        SettingUI:Hide();
		LobbyChatLogic.bAddCropsOfflineChatMsg = false;
        LoginSystem.sendLogout();
    end

    CommonMessageBoxUI:ShowPanel(2, Client.GetTableData("LocalizeRes", "102012").TextValue, Client.GetTableData("LocalizeRes", "111019").TextValue, LogOut);
end

function EventChatRequestPrivacyInSetting()
	local function savePrivacyAcceptStatus()
		LuaClassObj.HandleUIMessage(bp_setting, "OnChatPrivacyAccepted");	
	end
	CommonMessageBoxUI:ShowPanel(2, DataMgr.GetMsgByID(102012), DataMgr.GetMsgByID(4073), savePrivacyAcceptStatus,nil,DataMgr.GetMsgByID(110036),DataMgr.GetMsgByID(110035));
end

--确认更改画面品质的提示
function EventSettingConfirmModifyArtQuality_Push()
	log("---set art quality--");
	local content = Client.GetTableData("LocalizeRes", "116005").TextValue;
	CommonMessageBoxUI:ShowPanel(1, Client.GetTableData("LocalizeRes", "101001").TextValue, content);
end

--低配手机不能更改到高清画质提示
function EventSettingCannotSetHigherQuality_Push()
	log("---can not set art quality--");
	local content = Client.GetTableData("LocalizeRes", "116006").TextValue;
	CommonMessageBoxUI:ShowPanel(1, Client.GetTableData("LocalizeRes", "101001").TextValue, content);
end


function EventSettingCannotSetHigherFps_Push()
	PopUpNoticeUI:Init();
	--CommonMessageBoxUI:ShowPanel(1, Client.GetTableData("LocalizeRes", "101001").TextValue, "您的设备不能支持更高的帧率");
	CommonMessageBoxUI:ShowPanel(1, Client.GetTableData("LocalizeRes", "101001").TextValue, Client.GetTableData("LocalizeRes", "301182").TextValue);
end

--当前画面设置不能设置该帧率(画质更改未生效导致)
function EventSettingCurPicSettingNotSupportThisFps()
	PopUpNoticeUI:Init();
	local content = Client.GetTableData("LocalizeRes", "116013").TextValue;
	PopUpNoticeUI.ShowNewNotice(content);
end

function EventSettingShowConfirmModifyFps()
	CommonMessageBoxUI:ShowPanel(1, Client.GetTableData("LocalizeRes", "101001").TextValue, Client.GetTableData("LocalizeRes", "116007").TextValue);
end

function EventSettingNotSupportHDR()
	CommonMessageBoxUI:ShowPanel(1, Client.GetTableData("LocalizeRes", "101001").TextValue, Client.GetTableData("LocalizeRes", "116006").TextValue);
end

function EventSettingShowConfirmModifyHDR()
	CommonMessageBoxUI:ShowPanel(1, Client.GetTableData("LocalizeRes", "101001").TextValue, Client.GetTableData("LocalizeRes", "116008").TextValue);
end

function EventSettingShowUIElemUI()
	log("EventSettingShowUIElemUI")
	SettingUIElemUI.Show();
end

--超高清画质未开放
function EventSettingNoticeHighestArtClosed()
	CommonMessageBoxUI:ShowPanel(1, Client.GetTableData("LocalizeRes", "101001").TextValue, Client.GetTableData("LocalizeRes", "116009").TextValue);
end

function SettingUI:Release()

end

function SettingUI:Hide()
	if true == SettingUI.bShow then
		--rainpan 目前只有快捷语音界面slua重构，为了优化内存，在关闭设置界面时，应该销毁子界面快捷语音
		local ui_manager = require("ui.manager")
		ui_manager.CloseUI(ui_manager.UI_Config.setting_quickmessage)

		LuaClassObj.HandleUIMessage(bp_setting, "UIHide");
		SettingUI.bShow = false;
	end
end

--local language = Client.GetCurrentLanguage(); // 待shuzhilu提交语言设置
--NetUtil.SendPkg("set_lang_req", language);

function SettingUI:Release()
end

function SettingUI.get_role_privacy()
 	RoleInfoSystem.get_role_privacy();
end

function SettingUI.get_role_privacy_rsp(privacy)
	if privacy~= nil then
		SettingUI:SetCanShowHistory(privacy)
	else
		SettingUI:SetCanShowHistory(true)
	end
end

function SettingUI.HideInfoBindTab()
	LuaClassObj.HandleUIMessageNoFetch(bp_setting, "HideInfoBindTab");
end

function SettingUI.ShowInfoBindTab()
	LuaClassObj.HandleUIMessageNoFetch(bp_setting, "ShowInfoBindTab");
end

function SettingUI:SetCanShowHistory(canShow)
	local privacy = true
	if canShow ~= nil then
		privacy = canShow
	end
	BP_SettingCanShowHistory = privacy
	SettingBasicUI:FreshRoleHistoryPrivacySetting(BP_SettingCanShowHistory)
end

function SettingUI:InitWatchingInfo()
	-- 观战开关是否开启了
	BP_SettingIsWatchingOpen = LogicLobbyWatching.IsWatchingPrivacyOpen() and LogicLobbyWatching.IsWatchingOpen()
	-- 是否设置了不允许观战
	BP_SettingShowWatchingFlag = DataMgr.IsEnableWatch()

	if _isInLobby then
		BP_SettingBattleWatchingDetailOpen = LogicLobbyWatching.IsWatchingBattleBaseInfoSettingOpen()
	else
		BP_SettingBattleWatchingDetailOpen = false
	end

	BP_SettingBattleWatchingDetailFlag = DataMgr.IsCanWatchBaseInfoIngame()

	BP_SettingBattleWatchingInviteOpen = LogicLobbyWatching.IsWatchingInviteOpen()

	BP_SettingBattleWatchingInviteSetting = DataMgr.GetCanWatchInvite()
end

function EventSettingSendCanShowWatching()
	-- 直接设置状态, 因为后台是异步的
	DataMgr.SetEnableWatch(BP_SettingShowWatchingFlag)
	
	-- 通知给后台
    LogicLobbyWatching.send_show_watching(BP_SettingShowWatchingFlag)
end

function EventSettingSendCanShowBattleWatchingDetail()
	DataMgr.SetCanWatchBaseInfoIngame(BP_SettingBattleWatchingDetailFlag)
	--通知给后台
	LogicLobbyWatching.send_show_battle_watching_detail(BP_SettingBattleWatchingDetailFlag)
end

--switch  = {ui = true, battle_title = true, battle_show = true}
function SettingUI:SetUnknowPassSwitch(switch)
	if (switch == nil) then
		switch = {};
	end
	BP_Unknow_Pass_Switch_UI = switch.ui or false;
	-- BP_Unknow_Pass_Switch_Battle_Title = switch.battle_title or false;
	BP_Unknow_Pass_Switch_Battle_Show = switch.battle_show or false;
	LuaClassObj.HandleUIMessage(bp_setting, "FreshUnknowPassSwitchSetting");
end

function SettingUI.OnGetRoleInfoRsp()
    SettingUI:UpdateSwitchShowRole();
end

--sami 刷新界面-是否允许查看角色
function SettingUI:UpdateSwitchShowRole()
	--玩家自己数据
	local roleUid = DataMgr.roleData.uid;
	local playerInfo = ProfileMgr.GetRoleInfoDataByUid(roleUid);
	if(nil == playerInfo) then
		return;
	end
	--更新界面
	BP_SettingCanShowRole = playerInfo.bshow;
	LuaClassObj.HandleUIMessage(bp_setting_basic, "UpdateSwitchShowRoleSetting");
end

-- albin 上传本地设置界面数据SettingConfig_Slot.sav到云端
function SettingUI.UploadSettingConfig()
    local newName = "SettingConfig_Slot";
	local config = Client.LoadSavFile(newName);

	if (config == nil) then
		log("SettingUI.UploadSettingConfig--Can not load SettingConfig_Slot!");
		return;
	end

    local setting_info = {};
    setting_info.Config = config;
    local slotType = 1
	SettingSystem.save_custom_setting(setting_info, newName, 1, slotType);
end

function EventSettingSendUnknowPassSwitch()
    UnknowPassSystem:upass_change_switch_req(BP_Unknow_Pass_Switch_UI, BP_Unknow_Pass_Switch_UI, BP_Unknow_Pass_Switch_Battle_Show);
end

function EventSettingSendCanShowHistory()
    RoleInfoHistorySystem.send_show_history(BP_SettingCanShowHistory)
end

--sami 发送协议-允许他人查看个人形象
function EventSettingSendCanShowRole()
	local bshow = not(BP_SettingCanShowRole);
	log("EventSettingSendCanShowRole BP_SettingCanShowRole " ..tostring(bshow));

    ProfileMgr.send_show_role(bshow);
end

function EventOpenKefuUrl()
	KefuSystem.OpenSettingKefuURL();
end

function EventTurnonMomentRecord()
	log("EventTurnonMomentRecord fail ,show notice")
	--打开精彩视频开关
	local str = DataMgr.GetMsgByID(890008);
	ShowNotice(str);
end

function EventTurnonManualRecord()
	log("EventTurnonManualRecord fail ,show notice")
	local str = DataMgr.GetMsgByID(890007);
	ShowNotice(str);
end

--Setting_PickUp_UIBP AutoPickUp closed
function EventInformAutoPickUpClosed()
	log("EventInformAutoPickUpClosed ,show notice")
	local str = DataMgr.GetMsgByID(116015);
	ShowNotice(str);
end
--Setting_PickUp_UIBP PickUp Num set to zero
function EventInformPickUpNumZero()
	log("EventInformAutoPickUpClosed ,show notice")
	local str = DataMgr.GetMsgByID(116014);
	ShowNotice(str);
end

--Setting_PickUp_UIBP reset
function EventConfirmPickUpResetMsg()
	PopUpNoticeUI:Init();
	local function clickOkCallback()
		   LuaClassObj.HandleUIMessage(bp_setting_pickup, "ConfirmReset");
	end

	if Client.IsPVEMode(GameFrontendHUD) then
		CommonMessageBoxUI:ShowPanel(2, Client.GetTableData("LocalizeRes", "101001").TextValue, Client.GetTableData("LocalizeRes", "116017").TextValue, clickOkCallback, nil);
	else
		CommonMessageBoxUI:ShowPanel(2, Client.GetTableData("LocalizeRes", "101001").TextValue, Client.GetTableData("LocalizeRes", "116016").TextValue, clickOkCallback, nil);
	end
end

function EventShowMyRecordVideos()
	log("EventShowMyRecordVideos fail ,show notice")
	local str = DataMgr.GetMsgByID(890009);
	ShowNotice(str);
end

function SettingUI:ShowNoQuickMsgSelected()
	PopUpNoticeUI:Init();
	--PopUpNoticeUI.ShowNewNotice("请在右侧先选择待填入的消息");
	local content = Client.GetTableData("LocalizeRes", "301190").TextValue;
	PopUpNoticeUI.ShowNewNotice(content);
end
--
function SettingUI:ShowDuplactedMsgSelected()
	PopUpNoticeUI:Init();
	--PopUpNoticeUI.ShowNewNotice("已经有相同的消息填入了");
	local content = Client.GetTableData("LocalizeRes", "301191").TextValue;
	PopUpNoticeUI.ShowNewNotice(content);
end

function SettingUI:ShowInvalidMsgSelected()
	PopUpNoticeUI:Init();
	--PopUpNoticeUI.ShowNewNotice("未解锁该声优，无法填入");
	local content = Client.GetTableData("LocalizeRes", "4638").TextValue;
	PopUpNoticeUI.ShowNewNotice(content);
end

function SettingUI.ShowQuickMsgModifiedSuccess()
	PopUpNoticeUI:Init();
	--PopUpNoticeUI.ShowNewNotice("修改成功");
	local content = Client.GetTableData("LocalizeRes", "301192").TextValue;
	PopUpNoticeUI.ShowNewNotice(content);
end

--301340
function EventShowDiyLimitLevelNotice_Push()
	PopUpNoticeUI:Init();
	local  content = string.format(Client.GetTableData("LocalizeRes", "301340").TextValue, BP_DiyLimitLevel);
	CommonMessageBoxUI:ShowPanel(1, Client.GetTableData("LocalizeRes", "101001").TextValue, content);
end

--116011
function SettingUI.ShowQuickMsgBackToDefaultMsg()
	PopUpNoticeUI:Init();
	local  content = string.format(Client.GetTableData("LocalizeRes", "116011").TextValue, BP_DiyLimitLevel);
	CommonMessageBoxUI:ShowPanel(1, Client.GetTableData("LocalizeRes", "101001").TextValue, content);
end

function EventShowWaitingUI()
	log("show");
	ConnectionWaitingUI:Show();
end

function EventHideWaitingUI()
	log("hide");
	ConnectionWaitingUI:Hide();
end

function EventSendLanguageSettingToServer()
	log("--上报语言设置---");
	local language = Client.GetCurrentLanguage();
	NetUtil.SendPkg("set_lang_req", language);
end

function EventShowLogOutNoticceForSettingLanguage()
    local function LogOut()

        log("...log out from EventShowLogOutNoticceForSettingLanguage...");
        LuaClassObj.HandleUIMessage(bp_setting_locallanguage, "LogOutWhenSettingLanguage");
		LobbyChatLogic.bAddCropsOfflineChatMsg = false
    end

    CommonMessageBoxUI:ShowPanel(2, Client.GetTableData("LocalizeRes", "102012").TextValue, Client.GetTableData("LocalizeRes", "4015").TextValue, LogOut);
end

function EventLogOutForSettingLanguage()
	log("...log out from setting language...");       
    SettingUI:Hide();
	LoginSystem.sendLogoutWithoutLogoutAccount();
end

--imsdk fb setting panel control
function EventSettingPanelRegistIMSDKEvents()
	log("Bind Main EventSettingPanelRegistIMSDKEvents");
	EventSystem:registEvent(EVENTTYPE_BIND_INTL,EVENTID_INTL_BIND_NOTIFY,OnSettingPanelIMSDKNotify);
end

function EventSettingPanelUnRegistIMSDKEvents()
	log("Bind Main EventSettingPanelUnRegistIMSDKEvents");
	EventSystem:unregistEvent(EVENTTYPE_BIND_INTL,EVENTID_INTL_BIND_NOTIFY,OnSettingPanelIMSDKNotify);
end

--绑定 启动IMSDK超时定时器
function EventStartIMSDKBindTimer()
	log("EventStartIMSDKBindTimer");
	IMSDKSystem.StartIMSDKTimer(3);
end

function EventSettingPanelShowConnectingUI()
	ConnectionWaitingUI:Show();
end

function EventSettingPanelHideConnectingUI()
	ConnectionWaitingUI:Hide();
end

-- 下方按钮逻辑
function EventSettingPanelDelectAccount()
	SettingGDPRUI:AskForDeleteAccount();
end

function EventSettingPanelPrivicy()
	SettingGDPRUI:AskForPrivacyPolicy();
end

function EventSettingPanelEUGDPR()
	SettingGDPRUI:AskForEUGDPR();
end

function EventSettingPanelParentAllow()
	SettingGDPRUI:AskForParentAllow();
end

--打开客服超链接
function SettingUI.OpenCustomerService()
	LuaClassObj.HandleUIMessage(bp_setting, "OnClickCustomerService");
end

function OnSettingPanelIMSDKNotify(eventType, eventID, vars)
	log("Bind Main OnSettingPanelIMSDKNotify");
	BP_Setting_IMSDKNotifyEvent = vars;

	--绑定FB事件
	if vars == 2 then
		EventSettingPanelHideConnectingUI();
	end

	LuaClassObj.HandleUIMessage(bp_setting_basic,"OnSettingPanelIMSDKNotify");
end

--询问是否绑定社交帐号
function EventSettingPanelAskBindAccountMsgBox()
	local msgTitle = FuncUtil.GetLocalizeResStr("4045");
	local strBindName = SettingUI.GetNameByImsdkChannel(BP_BindChannel);
	local strLoginName = SettingUI.GetNameByGCloudChannel(BP_LoginChannel);
	log("EventSettingPanelAskBindAccountMsgBox BP_BindChannel=" .. BP_BindChannel.." strBindName="..strBindName.." BP_LoginChannel="..BP_LoginChannel.." strLoginName="..strLoginName.." BP_Platform="..BP_Platform);

	local msgContent = string.format(DataMgr.GetMultiLineMsgByID(4454), strBindName);
	--非Guest登录，说明已经绑定一个了
	if BP_LoginChannel ~= BP_ENUM_PLAYFORM_TOURIST then
		msgContent = string.format(DataMgr.GetMultiLineMsgByID(4451), strLoginName, strBindName);
	end

	local function clickOKCallback()
		log("[HHF]clickOKCallback");
		BP_Setting_IMSDKTipMsgBtnOKEvent = 1;
		LuaClassObj.HandleUIMessage(bp_setting_basic,"IMSDKTipMsgButtonOKEvent");
	end
	--不弹二次确认，直接拉起授权
	--CommonMessageBoxUI:ShowPanel(2,msgTitle, msgContent, clickOKCallback);
	clickOKCallback();
end

--绑定成功提示
function EventSettingPanelShowTipMsgBindSuccess()
	local msgTitle = FuncUtil.GetLocalizeResStr("4045");
	local strBindName = SettingUI.GetNameByImsdkChannel(BP_BindChannel);
	log("EventSettingPanelShowTipMsgBindSuccess BP_BindChannel=" .. BP_BindChannel.." strBindName="..strBindName.." BP_LoginChannel="..BP_LoginChannel.." BP_Platform="..BP_Platform);

	local msgContent = string.format(DataMgr.GetMultiLineMsgByID(4455), strBindName);
	--非Guest登录，说明已经绑定一个了
	if BP_LoginChannel ~= BP_ENUM_PLAYFORM_TOURIST then
		msgContent = string.format(DataMgr.GetMultiLineMsgByID(4452), strBindName);
	end

	local function clickOKCallback()
		if BP_LoginChannel == BP_ENUM_PLAYFORM_TOURIST then
			log("EventSettingPanelShowTipMsgBindSuccess clickOKCallback IMSDKRefreshBindUI BP_ENUM_PLAYFORM_TOURIST BP_LoginChannel=" .. BP_LoginChannel);
			--重新登录
			LuaClassObj.HandleUIMessage(bp_setting_basic, "UIHideWhenBindSucc");
			LoginSystem.sendLogoutWithoutLogoutAccount();
		else
			--只刷新UI
			log("EventSettingPanelShowTipMsgBindSuccess clickOKCallback IMSDKRefreshBindUI IMSDKRefreshBindUI BP_LoginChannel=" .. BP_LoginChannel);
			LuaClassObj.HandleUIMessage(bp_setting_basic, "RefreshBindInfo");
		end
	end
	CommonMessageBoxUI:ShowPanel(1,msgTitle, msgContent,clickOKCallback);
end

--绑定失败提示
function EventSettingPanelShowTipMsgBindFail()
	log("Bind Main EventSettingPanelShowTipMsgBindFBFail"..",BP_BindChannel="..BP_BindChannel..",BP_BindRetCode="..BP_BindRetCode..",BP_BindThirdRetCode="..BP_BindThirdRetCode);
	local msgTitle = FuncUtil.GetLocalizeResStr("4045");
	local msgContent = SettingUI.GetNoticeByThirdCode();
	
	CommonMessageBoxUI:ShowPanel(1,msgTitle, msgContent);
end

--绑定失败，该账号已绑定其他角色，询问玩家是否返回登录界面
function EventSettingPanelAskAlreadyBindFB()
	local msgTitle = FuncUtil.GetLocalizeResStr("4045");
	local strBindName = SettingUI.GetNameByImsdkChannel(BP_BindChannel);
	log("EventSettingPanelAskAlreadyBindFB BP_BindChannel=" .. BP_BindChannel.." strBindName="..strBindName.." BP_LoginChannel="..BP_LoginChannel.." BP_Platform="..BP_Platform);

	local msgContent = string.format(DataMgr.GetMultiLineMsgByID(4456), strBindName, strBindName, strBindName);
	--非Guest登录，说明已经绑定一个了
	if BP_LoginChannel ~= BP_ENUM_PLAYFORM_TOURIST then
		msgContent = string.format(DataMgr.GetMultiLineMsgByID(4453), strBindName);
	end

	local function clickOKCallback()
		if BP_LoginChannel == BP_ENUM_PLAYFORM_TOURIST then
			--重新登录
			SettingUI:Hide();
			LoginSystem.sendLogout();
		end
	end
	CommonMessageBoxUI:ShowPanel(1, msgTitle, msgContent, clickOKCallback);
end

-- modify by rainpan 2018/04/30 日版显示用户协议
function EventShowUserAgreement()
	log("EventShowUserAgreement");

	local strRegion = Client.GetPublishRegion();
	
	if strRegion == "JAPAN" then
		PopUpNoticeUI.ShowMessageBox(LongTxt.UserAgreement_title_jp, LongTxt.UserAgreement_content_jp);
	elseif strRegion == "KOREA" then
		PopUpNoticeUI.ShowMessageBox(LongTxt.UserAgreement_title_kr, LongTxt.UserAgreement_content_kr);
	else
		PopUpNoticeUI.ShowMessageBox(LongTxt.service_title_en, LongTxt.service_content_en);		
	end

end

function EventSetBindFB_Push()

end

--imsdk fb setting panel control end

-- 日韩版添加
-- GC登录超时提示，引导玩家去手机设置里登录GameCenter
function EventGCLoginTimeOut()
    log("bp_setting EventGCLoginTimeOut")

    ConnectionWaitingUI:Hide();
    
    local title = "";
    local msg = Client.GetTableData("LocalizeRes", "4142").TextValue;
    CommonMessageBoxUI:ShowPanel(1, title, msg);
end


function SettingUI.GetNoticeByThirdCode()

	local notice = FuncUtil.GetLocalizeResStr("4048");

	if BP_BindRetCode == 9999 then
		--GP登录底层报错情况比较复杂，对关键错误码，给出友好提示  --modify byron
		if BP_BindThirdRetCode == 16 then
			notice = FuncUtil.GetLocalizeResStr(4178);--google play services unavailable
		elseif BP_BindThirdRetCode == 1500 then
			notice = FuncUtil.GetLocalizeResStr(4179);--no external storage is mounted
		elseif BP_BindThirdRetCode == 5 then
			notice = FuncUtil.GetLocalizeResStr(4180);--invalid account name specified
		elseif BP_BindThirdRetCode == 20 then
			notice = FuncUtil.GetLocalizeResStr(4181);--profile is restricted
		elseif BP_BindThirdRetCode == 3 or BP_BindThirdRetCode == 9 then
			notice = FuncUtil.GetLocalizeResStr(4182);--version of google play services unavailable
		elseif BP_BindThirdRetCode == 1 then
			notice = FuncUtil.GetLocalizeResStr(4183);--google play services is missing
		elseif BP_BindThirdRetCode == 2 then
			notice = FuncUtil.GetLocalizeResStr(4184);--version of google play services is out of date
		end	
	end
	if BP_BindRetCode == 701 then
		notice = FuncUtil.GetLocalizeResStr(4188);--check Setting->GameCenter
	end
	return notice;
end

--根据imsdk channelid，获取渠道字符串
function SettingUI.GetNameByImsdkChannel(channel)

	local strName = "Guest";
	if channel == BP_ENUM_IMSDK_CHANNEL_FACEBOOK then
		strName = "Facebook";
	elseif channel == BP_ENUM_IMSDK_CHANNEL_GAMECENTER then
		strName = "GameCenter";	
	elseif channel == BP_ENUM_IMSDK_CHANNEL_GOOGLEPLAY then
		strName = "GooglePlay";	
	elseif channel == BP_ENUM_IMSDK_CHANNEL_WECHAT then
		strName = "WeChat";	
	elseif channel == BP_ENUM_IMSDK_CHANNEL_GUEST then
		strName = "Guest";	
	elseif channel == BP_ENUM_IMSDK_CHANNEL_VK then
		strName = "VK";	
	elseif channel == BP_ENUM_IMSDK_CHANNEL_TWITTER then
		strName = "Twitter";	
	elseif channel == BP_ENUM_IMSDK_CHANNEL_LINE then
		strName = "Line";	
	elseif channel == BP_ENUM_IMSDK_CHANNEL_QQ then
		strName = "QQ";
	end

	return strName;
end

--根据gcloud channelid，获取渠道字符串
function SettingUI.GetNameByGCloudChannel(channel)

	local strName = "Guest";
	if channel == BP_ENUM_PLAYFORM_QQ then
		strName = "Facebook";
	elseif channel == BP_ENUM_PLAYFORM_GAMECENTER then
		strName = "GameCenter";	
	elseif channel == BP_ENUM_PLAYFORM_GOOGLEPLAY then
		strName = "GooglePlay";	
	elseif channel == BP_ENUM_PLAYFORM_WX then
		strName = "WeChat";	
	elseif channel == BP_ENUM_PLAYFORM_TOURIST then
		strName = "Guest";	
	elseif channel == BP_ENUM_PLAYFORM_VK then
		strName = "VK";	
	elseif channel == BP_ENUM_PLAYFORM_TWITTER then
		strName = "Twitter";	
	elseif channel == BP_ENUM_PLAYFORM_LINE then
		strName = "Line";	
	elseif channel == BP_ENUM_PLAYFORM_QQByiTOP then
		strName = "QQ";
	end

	return strName;
end

function ShowVoice_SwitchToSpeakerAll()
	PopUpNoticeUI:Init();
	local content = Client.GetTableData("LocalizeRes", "600001").TextValue;
	PopUpNoticeUI.ShowNewNotice(content);
end

function ShowVoice_SwitchToSpeakerTeam()
	PopUpNoticeUI:Init();
	local content = Client.GetTableData("LocalizeRes", "600002").TextValue;
	PopUpNoticeUI.ShowNewNotice(content);
end

function ShowVoice_SwitchToSpeakerClosed()
	PopUpNoticeUI:Init();
	local content = Client.GetTableData("LocalizeRes", "600003").TextValue;
	PopUpNoticeUI.ShowNewNotice(content);
end

function ShowVoice_SwitchToMicophoneAll()
	PopUpNoticeUI:Init();
	local content = Client.GetTableData("LocalizeRes", "600004").TextValue;
	PopUpNoticeUI.ShowNewNotice(content);
end

function ShowVoice_SwitchToMicophoneTeam()
	PopUpNoticeUI:Init();
	local content = Client.GetTableData("LocalizeRes", "600005").TextValue;
	PopUpNoticeUI.ShowNewNotice(content);
end

function ShowVoice_SwitchToInterphoneAll()
	PopUpNoticeUI:Init();
	local content = Client.GetTableData("LocalizeRes", "600012").TextValue;
	PopUpNoticeUI.ShowNewNotice(content);
end

function ShowVoice_SwitchToInterphoneTeam()
	PopUpNoticeUI:Init();
	local content = Client.GetTableData("LocalizeRes", "600011").TextValue;
	PopUpNoticeUI.ShowNewNotice(content);
end

function ShowVoice_SwitchToMicophoneClosed()
	PopUpNoticeUI:Init();
	local content = Client.GetTableData("LocalizeRes", "600006").TextValue;
	PopUpNoticeUI.ShowNewNotice(content);
end

-- 获取登录类型配置
function EventSettingGetLoginTypeList()

	BP_ARRAY_SettingLoginTypeOrderList = FuncUtil.GetLoginTypeList(BP_ARRAY_SettingLoginTypeOrderList);

end

function EventShowNotInstallWechatMsg()
    local title = "";
    local msg = Client.GetTableData("LocalizeRes", "110126").TextValue;
    CommonMessageBoxUI:ShowPanel(1, title, msg);
end

function EventShowNotInstallVkMsg()
    local title = "";
    local msg = Client.GetTableData("LocalizeRes", "4303").TextValue;
    CommonMessageBoxUI:ShowPanel(1, title, msg);
end

-- 日版展示UC货币详情
function EventSettingShowCurrentTicket()
    -- 总点券
    local ticket = DataMgr.ticket or 0;
    -- 无偿点券
    local gen_ticket = DataMgr.gen_ticket or 0;
    -- 有尝点券
    local pay_ticket = ticket - gen_ticket;
    -- 容错
    if (pay_ticket < 0) then
        pay_ticket = 0;
    end

    log("[HHF]EventSettingShowCurrentTicket, ticket=" .. tostring(ticket) .. " gen_ticket=" .. tostring(gen_ticket) .. " pay_ticket=" .. tostring(pay_ticket));

    local msgTitle = FuncUtil.GetLocalizeResStr("4444");
    local msgContent = FuncUtil.LocalizeResFormat("4424", tostring(pay_ticket), tostring(gen_ticket));

    CommonMessageBoxUI:ShowPanel(1, msgTitle, msgContent);
end


function EventRefreshSettingParameter_Push()

end

---------------------------------------------------------------------setting panel split beg beg beg beg beg beg beg beg
function EventHideLastOpennedPage()
	log("songGT BP_SettingCurrentOpenPage: "..BP_SettingCurrentOpenPage)

	if BP_SettingCurrentOpenPage == BP_SettingIndexBasic then
		SettingBasicUI:Hide();
	elseif BP_SettingCurrentOpenPage == BP_SettingIndexPicture then
		SettingPictureUI:Hide()
	elseif BP_SettingCurrentOpenPage == BP_SettingIndexOperate then
		SettingOperateUI:Hide()
	elseif BP_SettingCurrentOpenPage == BP_SettingIndexVehicle then
		SettingVehicleUI:Hide();
	elseif BP_SettingCurrentOpenPage == BP_SettingIndexVideo then
		SettingVideoUI:Hide();
	elseif BP_SettingCurrentOpenPage == BP_SettingIndexSound then
		SettingSoundUI:Hide();
	elseif BP_SettingCurrentOpenPage == BP_SettingIndexPrivacy then
		SettingPrivacyUI:Hide();
	elseif BP_SettingCurrentOpenPage == BP_SettingIndexSensibility then
		SettingSensibilityUI:Hide();
	elseif BP_SettingCurrentOpenPage == BP_SettingIndexPickup then
		SettingPickupUI:Hide();
	elseif BP_SettingCurrentOpenPage == BP_SettingIndexSubsciption then
		SettingSubscriptionUI:Hide();
	elseif BP_SettingCurrentOpenPage == BP_SettingIndexLanguage then
		SettingLocalLanguageUI:Hide();
	elseif BP_SettingCurrentOpenPage == BP_SettingIndexMirrativ then
		SettingMirrativUI:Hide();
	elseif BP_SettingCurrentOpenPage == BP_SettingIndexOBS then
		SettingOBSUI:Hide()
	elseif BP_SettingCurrentOpenPage == BP_SettingIndexInfoBinding then
		SettingInformationUI:Hide()
	elseif BP_SettingCurrentOpenPage == BP_SettingIndexAimingMirrior then
		SettingAimingMirrorUI:Hide();
	end
end

function EventShowSelectedPage()
	log("songGT BP_SettingSelectedPage: "..BP_SettingSelectedPage)
	if BP_SettingSelectedPage == BP_SettingIndexBasic then
		SettingBasicUI:Init();
	elseif BP_SettingSelectedPage == BP_SettingIndexPicture then
		SettingPictureUI:Init();
	elseif BP_SettingSelectedPage == BP_SettingIndexOperate then
		SettingOperateUI:Init();
	elseif BP_SettingSelectedPage == BP_SettingIndexVehicle then
		SettingVehicleUI:Init();
	elseif BP_SettingSelectedPage == BP_SettingIndexVideo then
		SettingVideoUI:Init();
	elseif BP_SettingSelectedPage == BP_SettingIndexSound then
		SettingSoundUI:Init();
	elseif BP_SettingSelectedPage == BP_SettingIndexPrivacy then
		SettingPrivacyUI:Init();
	elseif BP_SettingSelectedPage == BP_SettingIndexSensibility then
		SettingSensibilityUI:Init();
	elseif BP_SettingSelectedPage == BP_SettingIndexPickup then
		SettingPickupUI:Init();
	elseif BP_SettingSelectedPage == BP_SettingIndexSubsciption then
		SettingSubscriptionUI:Init();
	elseif BP_SettingSelectedPage == BP_SettingIndexLanguage then
		SettingLocalLanguageUI:Init();
	elseif BP_SettingSelectedPage == BP_SettingIndexMirrativ then
		SettingMirrativUI:Init();
	elseif BP_SettingSelectedPage == BP_SettingIndexOBS then
		log("hps show obs ui: " ..BP_SettingSelectedPage)
		SettingOBSUI:Init()
	elseif BP_SettingSelectedPage == BP_SettingIndexInfoBinding then
		SettingInformationUI:Init()
	elseif BP_SettingSelectedPage == BP_SettingIndexAimingMirrior then
		SettingAimingMirrorUI:Init();
	end

	BP_SettingCurrentOpenPage = BP_SettingSelectedPage;
end


function EventShowSettingBindMore1()
	SettingBindMoreUI:Init()
end

function EventHideSettingBindMore1()
	SettingBindMoreUI:Hide()
end

function EventShowXGPushOpenTip()
	local strRegion = Client.GetPublishRegion();
	local msgConfig = Client.GetTableData("LocalizeRes", BP_XGPUSH_OFF_TIP_CODE);
	--log("EventShowXGPushOpenTip strRegion: "..strRegion.." BP_XGPUSH_OFF_TIP_CODE:"..BP_XGPUSH_OFF_TIP_CODE.." msgConfig:"..msgConfig.TextValue);
	if BP_XGPUSH_OFF_TIP_CODE == 116009 then
		if msgConfig then
			DataMgr.ShowNoticeByString(msgConfig.TextValue);
		end
	else
		-- jaysunzhu dominicwang 信鸽功能只有韩国、全球有。vng和日本是没有的。以下是特殊用法，正确用法参考http://tapd.oa.com/iGameInternational/markdown_wikis/view/#1020360302008071849
		if strRegion == "KOREA" or strRegion == "GLOBAL" or strRegion == "TW" then
			if msgConfig then
				local dateFormat = Client.GetTableData("LocalizeRes", "110070").TextValue;
				--local strTime = string.format("%s", os.date("%Y年%m月%d日", actData.StartTime));
	    		local strTime = string.format("%s", os.date(dateFormat, FuncUtil.GetServerTimeInSec()));
				DataMgr.ShowNoticeByString(string.format(msgConfig.TextValue, strTime));
			end
		end
	end
end

function EventSettingSetLobbySkinIDToNotify()
	log("EventSettingSetLobbySkinIDToNotify.."..BP_SettingLobbySkinID);
	GlobalData.SwitchLobbySkin(BP_SettingLobbySkinID);
end

function EventShowOBBackToLobbyNotice()
	EventShowBackToLobbyNotice()
end

-- 上传设置数据到云端
function EventUploadSettingConfigToCloud()
	log("EventUploadSettingConfigToCloud")
	SettingUI.UploadSettingConfig();
end

-- 保存异形屏设置到本地
function EventSaveShapedScreenToLoacl()
	log("BP_ShapedScreenType" .. tostring(BP_ShapedScreenType));
	GlobalData.SetGlobalConfigIntValue("ShapedScreenType", BP_ShapedScreenType);
end

function EventChangeShapedScreenConfirm()
	if BP_ShapedScreenCurrentSelectType ~= 2 and BP_ShapedScreenCurrentSelectType ~= 3 then
		log("BP_ShapedScreenType " .. tostring(BP_ShapedScreenType));
		SettingPictureUI:OnClickConfirm();
		return;
	end
	if(DataMgr.uiRectOffset ~= nil and DataMgr.uiRectOffset ~= "") then
		local param = string.split(DataMgr.uiRectOffset, ",");
		if tonumber(param[1]) < 30 then
			log("config is not shaped screen");
			local contentMsg = Client.GetTableData("LocalizeRes",7000).TextValue;
			local titleMsg = Client.GetTableData("LocalizeRes",101001).TextValue;
			local okMsg = Client.GetTableData("LocalizeRes",7001).TextValue;
			local cancleMsg = Client.GetTableData("LocalizeRes",7002).TextValue;
			CommonMessageBoxUI:ShowPanel(2, titleMsg, contentMsg, function()
				log("click confirm");
				SettingPictureUI:OnClickConfirm();
			end, function()
				log("click cancle");
				SettingPictureUI:OnClickCancle();
			end, okMsg, cancleMsg);
		else
			SettingPictureUI:OnClickConfirm();
		end
	end
end

-- 重置异形屏设置到服务器下发的数据
function EventResetShapedScreen()
	if(DataMgr.uiRectOffset ~= nil and DataMgr.uiRectOffset ~= "") then
		Client.SetUIRectOffset(DataMgr.uiRectOffset);
	end
end

---------------------------------------------------------------------setting panel split end end end end end end end