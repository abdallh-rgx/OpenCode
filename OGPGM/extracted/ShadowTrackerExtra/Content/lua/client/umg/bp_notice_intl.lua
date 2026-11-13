----公告UI
IMSDKNoticeUI = IMSDKNoticeUI or
{
	haveShowedNoticeBeforeLogin = false,
	haveShowedNoticeAfterLogin = false,

	DefaultNumOfNeedShow = 2,
	JKTimer = nil,
	JKInterval = 6,
}

BP_Enum_IMSDKNotice_Type =
{
	Alert = 0,
	Scroll = 1,
	All = 2,
};

BP_Enum_IMSDKNotice_Scene =
{
	UPDATE_SCENE_NOTICE = "1",				-- 更新公告（更新前弹窗）
	MAINTENANCE_NOTICE_BEFORE_LOGIN = "2",	-- 强制更新（登录前弹窗）
	COMMON_SCENE_BEFORE_LOGIN = "3",		-- 非强制更新（登录前弹窗）
	SLAP_SCENE_AFTER_LOGIN = "4",			-- 普通公告（登录后弹窗）
};

BP_Enum_IMSDKContent_Type = {
	type_text = "1",
	type_image = "2",
	type_web = "3",
}

--拍脸图需要用的数据结构，有的暂时没用到
BP_STRUCT_FNoticeInfo =
{
	index = 0,			    --索引做轮播需要
	MsgId = "",			    --公告ID
	MsgContentType = "",    --公告内容类型
	MsgTitle = "", 		    --公告标题
	MsgContent = "", 	    --公告内容
	MsgUrl = "",		    --公告跳转链接
	PicPath = "",		    --图片路径
	LoginTimes = "",	    --登陆次数
	MsgExtracontent = "",   --附加字段
	MsgvalidHour = "",      --生效时间
	MsgpauseHour = "",	    --点击后的冷却时间
	TimeStamp = "",		    --时间戳
	ThumbNail = "",         --缩略图url
}

--全部的拍脸图数据信息
BP_ARRAY_AllNoticeInfoArray =
{
	BP_STRUCT_FNoticeInfo = _G.BP_STRUCT_FNoticeInfo,
}

--可以显示的拍脸图数据信息
BP_ARRAY_ShowNoticeInfoArray =
{
	BP_STRUCT_FNoticeInfo = _G.BP_STRUCT_FNoticeInfo,
}

--公告索引
BP_IMSDKNotice_Index = 0;
BP_IMSDKNotice_Type = BP_Enum_IMSDKNotice_Type.All;
BP_IMSDKNotice_Scene = BP_Enum_IMSDKNotice_Scene.MAINTENANCE_NOTICE_BEFORE_LOGIN;

--当前索引到的公告ID和本地存的时间戳
BP_ClickedNoticeID = "";
BP_ClickedNoticeTimeStamp = "";

--本地存的上次展示拍脸图ID
BP_PreShowedNoticeID = 0;
--今日登录次数
BP_LoginTimesToday = 0;

BP_IMSDKCheckBox_State = false;

--GEM打点上报统计用
BP_CurrentClickStatus = false


--注册Widget
function bp_notice_intl_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_notice_intl,
		{
			{Path="/Game/UMG/UI_LOGIC/Common/Common_IMSDKNotice_Panel_BP.Common_IMSDKNotice_Panel_BP_C", Container="Default", ZOrder=BP_ENUM_UI_NOTICE_ZORDER},
			{Path="/Game/UMG/UI_LOGIC/Notice/Slap_IMSDKNotice_BP.Slap_IMSDKNotice_BP_C", Container="Default", ZOrder=BP_ENUM_UI_NOTICE_ZORDER},
			{Path="/Game/UMG/UI_LOGIC/Notice/JKNoticeAfterLogin_Logic_BP.JKNoticeAfterLogin_Logic_BP_C", Container="Default", ZOrder=BP_ENUM_UI_NOTICE_ZORDER},
		},
		{"Login", "Lobby"},
		false,
		false,
		true);

	EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_ITOPNOTICE, IMSDKNoticeUI.OnJumpUrl);
end

function IMSDKNoticeUI.ShowNoticeBeforeUpdate()
	if IMSDKNoticeUI.hasShowedNoticeBeforeUpdate == true then
		return;
	end

	IMSDKNoticeUI.hasShowedNoticeBeforeUpdate = true;
	local haveReceived = Client.HaveReceivedNoticeCallback();
	if haveReceived == true then
		log("[HHF]IMSDKNoticeUI.ShowNoticeBeforeUpdate, haveReceived = " .. tostring(haveReceived));
		IMSDKNoticeUI.ShowNoticeBeforeUpdateImpl();
	else
		log("[HHF]IMSDKNoticeUI.ShowNoticeBeforeUpdate, haveReceived = " .. tostring(haveReceived) .. ", and set a timer.");
		IMSDKNoticeUI.timer = Timer.InsertTimer(3, IMSDKNoticeUI.ShowNoticeBeforeUpdateImpl, false);
	end
end

function IMSDKNoticeUI.ShowNoticeBeforeUpdateImpl()
	if IMSDKNoticeUI.timer ~= nil then
		Timer.RemoveTimer(IMSDKNoticeUI.timer);
		IMSDKNoticeUI.timer = nil;
	end

	BP_IMSDKNotice_Index = 0;
	BP_IMSDKNotice_Type = BP_Enum_IMSDKNotice_Type.All;
	BP_IMSDKNotice_Scene = BP_Enum_IMSDKNotice_Scene.UPDATE_SCENE_NOTICE;

	local hasNotice = Client.HasNotice(BP_IMSDKNotice_Type, BP_IMSDKNotice_Scene);
	log("[HHF]IMSDKNoticeUI.ShowNoticeBeforeUpdateImpl, hasNotice = " .. tostring(hasNotice));
end

function IMSDKNoticeUI.ShowNoticeBeforeLogin()
	if GlobalData:IsIOSCheck() then
		log("[HHF]IMSDKNoticeUI.ShowNoticeBeforeLogin, IsIOSCheck() = true, and abort");
		return;
	end

	LuaClassObj.HandleDynamicCreation(bp_notice_intl);
	LuaClassObj.HandleUIMessageNoFetch(bp_notice_intl, "GetLoginTimesToday");

	BP_IMSDKNotice_Type = BP_Enum_IMSDKNotice_Type.All;
	BP_IMSDKNotice_Scene = BP_Enum_IMSDKNotice_Scene.MAINTENANCE_NOTICE_BEFORE_LOGIN;
	local hasNotice = Client.HasNotice(BP_IMSDKNotice_Type, BP_IMSDKNotice_Scene);

	if hasNotice == true then
		log("[HHF]IMSDKNoticeUI.ShowNoticeBeforeLogin, have maintenance notice");
		LuaClassObj.HandleUIMessage(bp_notice_intl, "ShowMaintenanceNotice");
	else
		log("[HHF]IMSDKNoticeUI.ShowNoticeBeforeLogin, haveShowedNoticeBeforeLogin = " .. tostring(IMSDKNoticeUI.haveShowedNoticeBeforeLogin));
		if IMSDKNoticeUI.haveShowedNoticeBeforeLogin == true then
			return;
		end

		BP_ARRAY_AllNoticeInfoArray = {};
		BP_ARRAY_ShowNoticeInfoArray = {};

		BP_IMSDKNotice_Index = 0;
		BP_IMSDKNotice_Type = BP_Enum_IMSDKNotice_Type.All;
		BP_IMSDKNotice_Scene = BP_Enum_IMSDKNotice_Scene.COMMON_SCENE_BEFORE_LOGIN;
		hasNotice = Client.HasNotice(BP_IMSDKNotice_Type, BP_IMSDKNotice_Scene);

		if hasNotice == true then
			log("[HHF]IMSDKNoticeUI.ShowNoticeBeforeLogin, have general notice");
			LuaClassObj.HandleUIMessage(bp_notice_intl, "GetAllNoticesInfoByScene");
			IMSDKNoticeUI.FilterNotice();

			if #BP_ARRAY_ShowNoticeInfoArray > 0 then
				IMSDKNoticeUI.ShowNextOrQuitNotice();
			else
				IMSDKNoticeUI.FinishNoticeGoToNextStep();
			end
		else
			IMSDKNoticeUI.FinishNoticeGoToNextStep();
		end
	end
end

function IMSDKNoticeUI.ShouldSlap()
	if not LobbySystem.CheckOpen(BP_ENUM_EXAMINE_UI_ITOP_NOTIFY) then
		log("[HHF]IMSDKNoticeUI.ShouldSlap, CheckOpen(BP_ENUM_EXAMINE_UI_ITOP_NOTIFY) = false, return false");
		return false;
	end

	if IMSDKNoticeUI.haveShowedNoticeAfterLogin then
		log("[HHF]IMSDKNoticeUI.ShouldSlap, IMSDKNoticeUI.haveShowedNoticeAfterLogin = true, return false");
		return false;
	end

	local strRegion = Client.GetPublishRegion();
	if strRegion == "JAPAN" or strRegion == "KOREA" then
		local timeStamp = GlobalData.GetGlobalConfigIntValue("NoShowSlapTimeStamp");
		local currStamp = FuncUtil.GetServerTimeInSec();
		if math.floor(timeStamp / 86400) == math.floor(currStamp / 86400) then
			log("[HHF]IMSDKNoticeUI.ShouldSlap, JK not show again today, return false");
			return false;
		end
	end

	log("[HHF]IMSDKNoticeUI.ShouldSlap, return true");
	return true;
end

function IMSDKNoticeUI.OnJumpUrl(eventType, eventID, vars)
	log("[HHF]IMSDKNoticeUI.OnJumpUrl, eventType = " .. tostring(eventType) ..
		", eventID = " .. tostring(eventID) ..
		", vars = " .. tostring(vars));

	IMSDKNoticeUI.ShowNoticeAfterLogin();
end

function IMSDKNoticeUI.ShowNoticeAfterLogin()
	BP_IMSDKNotice_Type = BP_Enum_IMSDKNotice_Type.All;
	BP_IMSDKNotice_Scene = BP_Enum_IMSDKNotice_Scene.SLAP_SCENE_AFTER_LOGIN;
	local hasNotice = Client.HasNotice(BP_IMSDKNotice_Type, BP_IMSDKNotice_Scene);
	log("[HHF]IMSDKNoticeUI.ShowNoticeAfterLogin, hasNotice = " .. tostring(hasNotice));

	if hasNotice == true then
		local curStatus = string.lower(LuaClassObj.GetGameStatus(bp_global));
		if curStatus == "lobby" then
            local ui_manager = require("ui.manager")
			local currentOpenedUI = ui_manager.GetCurrentOpenedUI()
			if currentOpenedUI == "RoomWaiting_BP_C" then
				log("[HHF]IMSDKNoticeUI.ShowNoticeAfterLogin, in RoomWaiting over.");
				return;
			end
		end

		LuaClassObj.HandleDynamicCreation(bp_notice_intl);
		BP_ARRAY_AllNoticeInfoArray = {};
		BP_ARRAY_ShowNoticeInfoArray = {};

		BP_IMSDKNotice_Index = 0;
		BP_IMSDKNotice_Type = BP_Enum_IMSDKNotice_Type.All;
		BP_IMSDKNotice_Scene = BP_Enum_IMSDKNotice_Scene.SLAP_SCENE_AFTER_LOGIN;
		LuaClassObj.HandleUIMessage(bp_notice_intl, "GetAllNoticesInfoByScene");
		IMSDKNoticeUI.FilterNotice();

		if #BP_ARRAY_ShowNoticeInfoArray > 0 then
			local strRegion = Client.GetPublishRegion();
			if strRegion == "JAPAN" or strRegion == "KOREA" then
				IMSDKNoticeUI.ShowJPKRNoticeAfterLogin();
			else
				IMSDKNoticeUI.ShowNextOrQuitNotice();
			end
		else
			IMSDKNoticeUI.FinishNoticeGoToNextStep();
		end
	else
		IMSDKNoticeUI.FinishNoticeGoToNextStep();
	end
end

function IMSDKNoticeUI.FilterNotice()
	if BP_IMSDKNotice_Scene == BP_Enum_IMSDKNotice_Scene.MAINTENANCE_NOTICE_BEFORE_LOGIN then
		BP_ARRAY_ShowNoticeInfoArray = FuncUtil:CopyTable(BP_ARRAY_AllNoticeInfoArray);
	else
		local strRegion = Client.GetPublishRegion();
		if strRegion == "JAPAN" or strRegion == "KOREA" then
			log("[HHF]IMSDKNoticeUI.FilterNotice, BP_LoginTimesToday = " .. tostring(BP_LoginTimesToday));

			for i = 1, #BP_ARRAY_AllNoticeInfoArray do
				local v = BP_ARRAY_AllNoticeInfoArray[i];
				IMSDKNoticeUI.ParseMsgExtraCond(v);
				if IMSDKNoticeUI.CanShowThisTimeForJK(v) == true then
					local notice = FuncUtil:CopyTable(v);
					table.insert(BP_ARRAY_ShowNoticeInfoArray, notice);
				end
			end
		else
			LuaClassObj.HandleUIMessage(bp_notice_intl, "GetAllClickedNoticeIDAndTimestamp");
			LuaClassObj.HandleUIMessage(bp_notice_intl, "GetPreShowedNoticeID");
			log("[HHF]IMSDKNoticeUI.FilterNotice, BP_PreShowedNoticeID = " .. tostring(BP_PreShowedNoticeID) ..
				", BP_LoginTimesToday = " .. tostring(BP_LoginTimesToday));

			local preIndex = 0;
			if BP_PreShowedNoticeID > 0 then
				for k, v in pairs(BP_ARRAY_AllNoticeInfoArray) do
					if v.MsgId == tostring(BP_PreShowedNoticeID) then
						preIndex = k;
						break;
					end
				end
			end

			for i = preIndex + 1, #BP_ARRAY_AllNoticeInfoArray do
				local v = BP_ARRAY_AllNoticeInfoArray[i];
				IMSDKNoticeUI.ParseMsgExtraCond(v);
				if #BP_ARRAY_ShowNoticeInfoArray < IMSDKNoticeUI.DefaultNumOfNeedShow and
					IMSDKNoticeUI.CanShowThisTimeForGlobal(v) == true then
					local notice = FuncUtil:CopyTable(v);
					table.insert(BP_ARRAY_ShowNoticeInfoArray, notice);
				end
			end

			for j = 1, preIndex do
				local v = BP_ARRAY_AllNoticeInfoArray[j];
				IMSDKNoticeUI.ParseMsgExtraCond(v);
				if #BP_ARRAY_ShowNoticeInfoArray < IMSDKNoticeUI.DefaultNumOfNeedShow and
					IMSDKNoticeUI.CanShowThisTimeForGlobal(v) == true then
					local notice = FuncUtil:CopyTable(v);
					table.insert(BP_ARRAY_ShowNoticeInfoArray, notice);
				end
			end
		end
	end
	log("[HHF]IMSDKNoticeUI.FilterNotice, before = " .. tostring(#BP_ARRAY_AllNoticeInfoArray) .. ", after = " .. tostring(#BP_ARRAY_ShowNoticeInfoArray));
end

function IMSDKNoticeUI.ParseMsgExtraCond(notice)
	log("[HHF]IMSDKNoticeUI.ParseMsgExtraCond, notice.MsgExtracontent = " .. tostring(notice.MsgExtracontent));
	if notice.MsgExtracontent then
		local extraCondTable = json.decode(notice.MsgExtracontent)
		if extraCondTable then
			--log_tree("[HHFTEST]IMSDKNoticeUI.ParseMsgExtraCond, condtable = ", extraCondTable, "[HHFTEST]");
			notice.LoginTimes = extraCondTable["loginTimes"] or "";
			notice.MsgvalidHour = extraCondTable["validTime"] or "";
			notice.MsgpauseHour = extraCondTable["pauseTime"] or "";
			notice.ThumbNail = extraCondTable["thumbNail"] or "";
		end
	end
end

function IMSDKNoticeUI.CanShowThisTimeForGlobal(notice)
	if LobbySystem.isNewPlayer == true then
		if #BP_ARRAY_ShowNoticeInfoArray > 0 then
			log("[HHF]IMSDKNoticeUI.CanShowThisTime, new player only one, return false.");
			return false;
		else
			return true;
		end
	else
		if notice.LoginTimes ~= "" then
			if tonumber(notice.LoginTimes) < tonumber(BP_LoginTimesToday) then
				log("[HHF]IMSDKNoticeUI.CanShowThisTime, notice.ID = " .. tostring(notice.MsgId) ..
					", notice.LoginTimes = " .. tostring(notice.LoginTimes) .. " < " .. tostring(BP_LoginTimesToday) .. " = BP_LoginTimesToday, return false.");
				return false;
			end
		end

		if notice.MsgvalidHour ~= "" and string.len(notice.MsgvalidHour) == 8 then
			local starttimeStr = string.format("%s:%s:00", string.sub(notice.MsgvalidHour, 1, 2), string.sub(notice.MsgvalidHour, 3, 4));
			local endTimeStr = string.format("%s:%s:00", string.sub(notice.MsgvalidHour, 5, 6), string.sub(notice.MsgvalidHour, 7, 8));
			local curTime = FuncUtil.GetServerTimeInSec();
			local curDayStr = os.date('!%Y-%m-%d', curTime);
			starttimeStr = curDayStr .. " " .. starttimeStr;
			endTimeStr = curDayStr .. " " .. endTimeStr;
			local startTime = TimeUtil.TimeStringToUnixstamp(starttimeStr);
			local endTime = TimeUtil.TimeStringToUnixstamp(endTimeStr);
			if curTime < startTime or endTime < curTime then
				log("[HHF]IMSDKNoticeUI.CanShowThisTime, notice.ID = " .. tostring(notice.MsgId) ..
					", curTime = " .. tostring(curTime) .. " not in notice valid hour [" .. tostring(startTime) .. ", " .. tostring(endTime) .."], return false.");
				return false;
			else
				log("[HHF]IMSDKNoticeUI.CanShowThisTime, notice.ID = " .. tostring(notice.MsgId) ..
					", " .. tostring(startTime) .. " <= " .. tostring(curTime) .. " <= " .. tostring(endTime));
			end
		end

		if notice.MsgpauseHour ~= "" and notice.TimeStamp ~= "" then
			local curTime = FuncUtil.GetServerTimeInSec();
			local validTime = tonumber(notice.MsgpauseHour) * 3600;
			if curTime < tonumber(notice.TimeStamp) + validTime then
				log("[HHF]IMSDKNoticeUI.CanShowThisTime, notice.ID = " .. tostring(notice.MsgId) ..
					", curTime = " .. tostring(curTime) .. " < " .. tostring(notice.TimeStamp) .. "(preClick) + " .. tostring(validTime) .. "(pauseTime), return false.");
				return false;
			end
		end
	end

	return true;
end

function IMSDKNoticeUI.CanShowThisTimeForJK(notice)
	if notice.LoginTimes ~= "" then
		if tonumber(notice.LoginTimes) < tonumber(BP_LoginTimesToday) then
			log("[HHF]IMSDKNoticeUI.CanShowThisTime, notice.ID = " .. tostring(notice.MsgId) ..
				", notice.LoginTimes = " .. tostring(notice.LoginTimes) .. " < " .. tostring(BP_LoginTimesToday) .. " = BP_LoginTimesToday, return false.");
			return false;
		end
	end

	return true;
end

function IMSDKNoticeUI.ShowNextOrQuitNotice()
	BP_IMSDKNotice_Index = BP_IMSDKNotice_Index + 1;
	log("[HHF]IMSDKNoticeUI.ShowNextOrQuitNotice, set BP_IMSDKNotice_Index = " .. tostring(BP_IMSDKNotice_Index) ..
		" = " .. tostring(BP_IMSDKNotice_Index-1) .. " + 1.");
	if BP_IMSDKNotice_Index <= #BP_ARRAY_ShowNoticeInfoArray then
		local currentNotice = BP_ARRAY_ShowNoticeInfoArray[BP_IMSDKNotice_Index];
		--log_tree("[HHFTEST]IMSDKNoticeUI.ShowNextOrQuitNotice, currentNotice = ", currentNotice, "[HHFTEST]");
		if currentNotice.MsgContentType == BP_Enum_IMSDKContent_Type.type_text then
			LuaClassObj.HandleUIMessage(bp_notice_intl, "ShowCommonNotice");
		elseif currentNotice.MsgContentType == BP_Enum_IMSDKContent_Type.type_image then
			LuaClassObj.HandleUIMessage(bp_notice_intl, "ShowSlapNotice");
		else
			log("[HHF]IMSDKNoticeUI.ShowNextOrQuitNotice, not support MsgContentType = " .. tostring(currentNotice.MsgContentType));
			IMSDKNoticeUI.FinishNoticeGoToNextStep();
		end
	else
		IMSDKNoticeUI.FinishNoticeGoToNextStep();
	end
end

function IMSDKNoticeUI.FinishNoticeGoToNextStep()
	log("[HHF]FinishNoticeGoToNextStep, BP_IMSDKNotice_Scene = " .. tostring(BP_IMSDKNotice_Scene));
	if BP_IMSDKNotice_Scene == BP_Enum_IMSDKNotice_Scene.UPDATE_SCENE_NOTICE then
		VersionUpdate.TriggerUpdateAfterNotice();
	elseif BP_IMSDKNotice_Scene == BP_Enum_IMSDKNotice_Scene.COMMON_SCENE_BEFORE_LOGIN then
		--登录前公告结束，进行自动登录流程
		IMSDKNoticeUI.haveShowedNoticeBeforeLogin = true;
		AuthorizationUI.ContinueAutoLogin();
	elseif BP_IMSDKNotice_Scene == BP_Enum_IMSDKNotice_Scene.SLAP_SCENE_AFTER_LOGIN then
		--打脸图结束，进行后续操作
		IMSDKNoticeUI.haveShowedNoticeAfterLogin = true;
		BP_ARRAY_ShowNoticeInfoArray = {};
		FaceSlapSystem.ShowNext(BP_ENUM_MODULE_ITOPNOTICE);
	end
end

function IMSDKNoticeUI.ShowJPKRNoticeAfterLogin()
	log("[HHF]ShowJPKRNoticeAfterLogin");
	LuaClassObj.HandleUIMessage(bp_notice_intl, "ShowJKNoticeAfterLogin");
	IMSDKNoticeUI.ShowNextJKNotice();
	IMSDKNoticeUI.JKTimer = Timer.InsertTimer(IMSDKNoticeUI.JKInterval, IMSDKNoticeUI.ShowNextJKNotice, true);
end

function IMSDKNoticeUI.ShowNextJKNotice()
	BP_IMSDKNotice_Index = BP_IMSDKNotice_Index + 1;
	if BP_IMSDKNotice_Index > #BP_ARRAY_ShowNoticeInfoArray then
		BP_IMSDKNotice_Index = 1;
	end

	log("[HHF]IMSDKNoticeUI.ShowNextJKNotice, BP_IMSDKNotice_Index = " .. tostring(BP_IMSDKNotice_Index) .. " = " .. tostring(BP_IMSDKNotice_Index-1) .. " + 1.");
	local currentNotice = BP_ARRAY_ShowNoticeInfoArray[BP_IMSDKNotice_Index];
	--log_tree("[HHFTEST]IMSDKNoticeUI.ShowNextJKNotice, currentNotice = ", currentNotice, "[HHFTEST]");
	LuaClassObj.HandleUIMessage(bp_notice_intl, "ShowNextJKNotice");
end

function IMSDKNoticeUI.OnlyCloseUI()
	log("[HHF]IMSDKNoticeUI.OnlyCloseUI");
	LuaClassObj.HandleUIMessage(bp_notice_intl, "HideCommonNotice");
	LuaClassObj.HandleUIMessage(bp_notice_intl, "HideSlapNotice");
	LuaClassObj.HandleUIMessage(bp_notice_intl, "HideJKNotice");

	if IMSDKNoticeUI.JKTimer ~= nil then
		Timer.RemoveTimer(IMSDKNoticeUI.JKTimer);
		IMSDKNoticeUI.JKTimer = nil;
	end

	--IMSDKNoticeUI.haveShowedNoticeAfterLogin = true;
end

function IMSDKNoticeUI.Release()
	log("[HHF]IMSDKNoticeUI.Release");

	local strRegion = Client.GetPublishRegion();
	if strRegion == "JAPAN" or strRegion == "KOREA" then
		IMSDKNoticeUI.haveShowedNoticeAfterLogin = false;
	end

	if IMSDKNoticeUI.JKTimer ~= nil then
		Timer.RemoveTimer(IMSDKNoticeUI.JKTimer);
		IMSDKNoticeUI.JKTimer = nil;
	end
end

function IMSDKNoticeUI.OnHyperLinkClicked(MetaData)
	local url = MetaData["url"];
	GlobalData:JumpUrl(url);
end

function IMSDKNoticeUI.GetLoginTimesToday()
	return BP_LoginTimesToday;
end

function EventOnClickJKOneNoticeItem()
	log("[HHF]EventOnClickJKOneNoticeItem, BP_IMSDKNotice_Index = " .. tostring(BP_IMSDKNotice_Index));

	if IMSDKNoticeUI.JKTimer ~= nil then
		Timer.RemoveTimer(IMSDKNoticeUI.JKTimer);
		IMSDKNoticeUI.JKTimer = nil;
	end

	IMSDKNoticeUI.ShowNextJKNotice();

	IMSDKNoticeUI.JKTimer = Timer.InsertTimer(IMSDKNoticeUI.JKInterval, IMSDKNoticeUI.ShowNextJKNotice, true);
end

function EventOnClickJKNextNotice()
	log("[HHF]EventOnClickJKNextNotice");
	IMSDKNoticeUI.ShowNextJKNotice();
end

function EventOnClickJKPreviousNotice()
	log("[HHF]EventOnClickJKOneNoticeItem, BP_IMSDKNotice_Index = " .. tostring(BP_IMSDKNotice_Index));
	BP_IMSDKNotice_Index = BP_IMSDKNotice_Index - 2;
	if BP_IMSDKNotice_Index < 0 then
		BP_IMSDKNotice_Index = #BP_ARRAY_ShowNoticeInfoArray - 1;
	end
	IMSDKNoticeUI.ShowNextJKNotice();
end

function EventSyncOneNoticeClickTimeInfo()
	log("[HHF]EventSyncOneNoticeClickTimeInfo, BP_ClickedNoticeID = " .. tostring(BP_ClickedNoticeID) ..
		", BP_ClickedNoticeTimeStamp = " .. tostring(BP_ClickedNoticeTimeStamp));
	for k, v in pairs(BP_ARRAY_AllNoticeInfoArray) do
		if v.MsgId == BP_ClickedNoticeID then
			v.TimeStamp = BP_ClickedNoticeTimeStamp;
			break;
		end
	end
end

function EventCloseCurrentNotice()
	log("[HHF]EventCloseCurrentNotice");
	IMSDKNoticeUI.ShowNextOrQuitNotice();
end

function EventCloseJKNotice()
	log("[HHF]EventCloseJKNotice");

	if IMSDKNoticeUI.JKTimer ~= nil then
		Timer.RemoveTimer(IMSDKNoticeUI.JKTimer);
		IMSDKNoticeUI.JKTimer = nil;
	end

	IMSDKNoticeUI.FinishNoticeGoToNextStep();
end

function EventSaveSlapCheckState()
	log("[HHF]EventSaveSlapCheckState, BP_IMSDKCheckBox_State = " .. tostring(BP_IMSDKCheckBox_State));
	if BP_IMSDKCheckBox_State then
		local timeStamp = FuncUtil.GetServerTimeInSec();
		GlobalData.SetGlobalConfigData("NoShowSlapTimeStamp", timeStamp , 0);
	else
		GlobalData.SetGlobalConfigData("NoShowSlapTimeStamp", 0, 0);
	end
end

function EventGemReport()
	if BP_ARRAY_ShowNoticeInfoArray[BP_IMSDKNotice_Index] then
		local cur_faceid = BP_ARRAY_ShowNoticeInfoArray[BP_IMSDKNotice_Index].MsgId
		if cur_faceid then
			if BP_CurrentClickStatus then
				GemReportUtils.ReportEventDelay(GemReportUtils.EventName_CommonEvent , GemReportUtils.SubEventName_FaceSlap, cur_faceid, 1)
				BP_CurrentClickStatus = false
			else
				GemReportUtils.ReportEventDelay(GemReportUtils.EventName_CommonEvent , GemReportUtils.SubEventName_FaceSlap, cur_faceid, 0)
			end
		end
	end
end

function EventSetInfo_Push()
end

function EventFetchInfo()
end
