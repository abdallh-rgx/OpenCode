VersionUpdate = VersionUpdate or {
}

--注册Widget
function bp_versionupdate_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_versionupdate,
    {
    {Path="/Game/UMG/UI_BP/Login/Login_Update_UIBP.Login_Update_UIBP_C", Container="Default", ZOrder=2000}
    },
    {"Login"},
    false,
    false
	);
	
	EventSystem:registEvent(EVENTTYPE_LOGIN,EVENTID_BACKLOGIN, VersionUpdate.OnBackLogin);
	EventSystem:registEvent(EVENTTYPE_NETWORK, EVENTID_LOBBY_SERVER_CONNECT_SUCCESS, VersionUpdate.OnConnectServerSuccess);
end

BP_CurStage = "updating";
BP_IsExamin = false;
BP_CurPercent = 100;
BP_CDNLoaderUrl = "";
BP_CDNLoaderType = 0;
BP_CDNLoaderSavedDir = "";
BP_CDNNeedBreakpointContinualTransfer = false;
BP_ShaderCompileCurPercent = 0;

VersionUpdate.CancelCount = 0;
VersionUpdate.tempTips = "";
VersionUpdate.delayTimerID = 0;
VersionUpdate.hasRetried712 = false;
VersionUpdate.reported71X = 0; --上报了71X
VersionUpdate.reported71XConnectLobbySuccess = false; --71X后如果成功连接大厅，则上报
VersionUpdate.IgnoredVersionForGrayResourceUpdate = "";--灰度更新跳过的资源版本号(资源推荐更新取消时使用)

BP_STRUCT_VersionUpdateInfo =
{
    isAppUpdating="1",
    isNeedUpdating="1",
    isForcedUpdating="1",
    versionString="0.1.0.0",
    needDownloadSize_f=0, --以M为单位
    versionDescrition="desc",
    userDefineStr="",
    isUsingDolphinUpdate="1",
    isUsingCDNUpdate="0",
}

function VersionUpdate.OnBackLogin()
	--重置GCloud 71X上报流程
	VersionUpdate.hasRetried712 = false;
	VersionUpdate.reported71X = 0;
	VersionUpdate.reported71XConnectLobbySuccess = false;
end

function VersionUpdate.OnConnectServerSuccess()
	--连大厅服务器成功
	if VersionUpdate.reported71X ~= 0 and VersionUpdate.reported71XConnectLobbySuccess == false then
		VersionUpdate.reported71XConnectLobbySuccess = true;

		local param = 
		{
			error_code = tostring(VersionUpdate.reported71X);
			type = "2";--能进入大厅
		};
		log("71X can enter lobby");
		Client.GEMReportEvent(GameFrontendHUD, "71XButHasNet", param);
	end
end

function EventFetchInfo()
	
end

function VersionUpdate.Init()
	log("[HHF]VersionUpdate.Init, BP_VersionUpdateInfo = " .. tostring(BP_VersionUpdateInfo));
    if BP_VersionUpdateInfo then
        BP_VersionUpdateInfo.isForcedUpdating = "0"
    end
end

function VersionUpdate.IsJapanOrKorea()
	local region = Client.GetPublishRegion();
    if region == "JAPAN" or region == "KOREA" then
    	return true;
    else
    	return false;
    end
end

function VersionUpdate.IsNewVersionOfJKResource()
	--return true;
	---[[
	if VersionUpdate.IsJapanOrKorea() and 
	   BP_VersionUpdateInfo.isAppUpdating == "2" then
    	log("[HHF]VersionUpdate.IsNewVersionOfJKResource, return true");
		return true;
	else
    	log("[HHF]VersionUpdate.IsNewVersionOfJKResource, return false");
		return false;
	end 
	--]]
end

function VersionUpdate.OnNoticeUpdate(Info)
    BP_VersionUpdateInfo = Info
	BP_STRUCT_VersionUpdateInfo = Info
	
    BP_VersionUpdateInfo.needDownloadSize_f = tonumber(Info.needDownloadSize) / 1048576
	BP_STRUCT_VersionUpdateInfo.needDownloadSize_f = tonumber(Info.needDownloadSize) / 1048576
	
	--log_tree("BP_VersionUpdateInfo",BP_VersionUpdateInfo)
	
	log("[HHF]VersionUpdate.OnNoticeUpdate, isAppUpdating = " .. tostring(BP_VersionUpdateInfo.isAppUpdating))
	log("[HHF]VersionUpdate.OnNoticeUpdate, isNeedUpdating = " .. tostring(BP_VersionUpdateInfo.isNeedUpdating))
	log("[HHF]VersionUpdate.OnNoticeUpdate, isForcedUpdating = " .. tostring(BP_VersionUpdateInfo.isForcedUpdating))
	log("[HHF]VersionUpdate.OnNoticeUpdate, versionString = " .. tostring(BP_VersionUpdateInfo.versionString))
	log("[HHF]VersionUpdate.OnNoticeUpdate, needDownloadSize_f = " .. tostring(BP_VersionUpdateInfo.needDownloadSize_f))
	log("[HHF]VersionUpdate.OnNoticeUpdate, versionDescrition = " .. tostring(BP_VersionUpdateInfo.versionDescrition))
	log("[HHF]VersionUpdate.OnNoticeUpdate, userDefineStr = " .. tostring(BP_VersionUpdateInfo.userDefineStr))
	log("[HHF]VersionUpdate.OnNoticeUpdate, isGrayUpdate = " .. tostring(BP_VersionUpdateInfo.isGrayUpdate))
--[[
	if BP_VersionUpdateInfo.isNeedUpdating == "1" then
		IMSDKNoticeUI.ShowNoticeBeforeUpdate();
	else
		VersionUpdate.TriggerUpdateAfterNotice();
	end
end

function VersionUpdate.TriggerUpdateAfterNotice()
	log("[HHF]VersionUpdate.TriggerUpdateAfterNotice");
--]]
	if BP_VersionUpdateInfo.isGrayUpdate == "1" and BP_VersionUpdateInfo.isAppUpdating == "2" then
		if string.len(BP_VersionUpdateInfo.versionString)>0 and VersionUpdate.IgnoredVersionForGrayResourceUpdate == BP_VersionUpdateInfo.versionString then
			Client.DisableRepairResource(GameFrontendHUD);--禁用白名单更新时修复
			VersionUpdate.CancelUpdate();
			VersionUpdate.IgnoredVersionForGrayResourceUpdate = "";
			return;
		end

		if string.len(VersionUpdate.IgnoredVersionForGrayResourceUpdate)>0 then
			VersionUpdate.IgnoredVersionForGrayResourceUpdate = "";
		end
	end

	local tips = ""
	-- 版本更新
	if (BP_VersionUpdateInfo.isAppUpdating == "2" and BP_VersionUpdateInfo.needDownloadSize_f > 0)then -- (BP_VersionUpdateInfo.isAppUpdating == "1" and BP_VersionUpdateInfo.needDownloadSize_f > 0) or
		--  android and ios资源更新
		local msgConfig = Client.GetTableData("LocalizeRes",201004)
		if msgConfig then
			tips = string.format(msgConfig.TextValue, BP_VersionUpdateInfo.needDownloadSize_f)
		end
	elseif BP_VersionUpdateInfo.isAppUpdating == "1"  then --and BP_VersionUpdateInfo.needDownloadSize_f <= 0
		-- android版本更新 or ios版本更新
		local msgConfig = Client.GetTableData("LocalizeRes",201005)
		if msgConfig then
			tips = msgConfig.TextValue
		end
	end
	
	local IsDownloadingBasePatchForJK = false;
	--没有wifi的情况
    if not Client.HasActiveWifi() then
		if BP_VersionUpdateInfo.isAppUpdating == "2" and BP_VersionUpdateInfo.needDownloadSize_f <= 2 then
			--资源包大小，小于2M，不确认，直接更新
			log("[HHF]VersionUpdate.OnNoticeUpdate, new version of the resource, <= 2MB");
			LuaClassObj.HandleUIMessage(bp_versionupdate, "NoWifiStartUpdate");
		else
			if Client.IsSplitMiniPakVersion() == true and BP_VersionUpdateInfo.isAppUpdating == "2" then
				IsDownloadingBasePatchForJK = true;
			else
				--资源更新，提示下载的大小
				local title = ""
				local msgConfig = Client.GetTableData("LocalizeRes",201001)
				if msgConfig then
					title = msgConfig.TextValue
				end
				
				local okLabel = ""
				local okConfig = Client.GetTableData("LocalizeRes",201003)
				if okConfig then
					okLabel = okConfig.TextValue
				end
				
				local cancelLabel = ""
				local cancelConfig = Client.GetTableData("LocalizeRes",110035)
				if cancelConfig then
					cancelLabel = cancelConfig.TextValue
				end
				
				local warning = ""
				if BP_VersionUpdateInfo ~= nil and BP_VersionUpdateInfo.isForcedUpdating == "1" then
					local warningConfig = Client.GetTableData("LocalizeRes",201022)
					if warningConfig then
						warning = warningConfig.TextValue
					end
				end
				
				CommonMessageBoxUI:ShowPanel(2,title,tips..warning,
				function()


					local bCEVersion = Client.IsCEVersion() ;

					if not bCEVersion then
						--确认更新
						--若是程序更新，则调用CancelUpdate
						if BP_VersionUpdateInfo.isAppUpdating == "1"  then
							log("[HHF]VersionUpdate.OnNoticeUpdate, new version of the App, Call DolphinCancelUpdate");
							VersionUpdate.DolphinCancelUpdate();
						end
					end


					log("[HHF]VersionUpdate.OnNoticeUpdate, new version of the resource, > 2MB");
					LuaClassObj.HandleUIMessage(bp_versionupdate, "NoWifiStartUpdate");
				end,

				function()
					if BP_VersionUpdateInfo.isForcedUpdating == "1" then
						log("[HHF]VersionUpdate.OnNoticeUpdate, isForcedUpdating = 1, clicked cancel, Call quitGame");
						
						VersionUpdate.DolphinCancelUpdate();
						LuaClassObj.HandleUIMessage(bp_global, "quitGame");
					else
						if BP_VersionUpdateInfo.isAppUpdating == "2" then
							VersionUpdate.DisableResourceRepairAndGrayUpdate();
						end
						log("[HHF]VersionUpdate.OnNoticeUpdate, isForcedUpdating = 0, clicked cancel, Call CancelUpdate");
						VersionUpdate.CancelUpdate();
					end
				end,
				okLabel,
				cancelLabel
				);
			end
		end
    end
	LuaClassObj.HandleUIMessage(bp_versionupdate, "ShowUpdateUI");
	if IsDownloadingBasePatchForJK then
		log("[HHF]VersionUpdate.OnNoticeUpdate, new version of the resource, > 2MB, Show confirm dialog(JK)");
		LuaClassObj.HandleUIMessage(bp_versionupdate, "ConfirmDownloadForJK");
	else
		if Client.IsSplitMiniPakVersion() == true and BP_VersionUpdateInfo.isAppUpdating == "2" and
		   BP_VersionUpdateInfo.needDownloadSize_f > 2 then
			LuaClassObj.HandleUIMessage(bp_versionupdate, "ShowLunBoImages");
		end
	end
end

function VersionUpdate.StartGrayUpdate(funcCallBack)
    VersionUpdate.GrayUpdate = true;
    if funcCallBack ~= nil then
        VersionUpdate.CallBackOnUpdateEnd = funcCallBack;
    end
    --开始灰度更新，显示更新UI
    if Client.StartGrayUpdate(GameFrontendHUD) then
        LuaClassObj.HandleUIMessage(bp_versionupdate, "GrayShowWaiting");
	else
		if VersionUpdate.CallBackOnUpdateEnd ~= nil then 
    		log("skip gray update call CallBackOnUpdateEnd");
			VersionUpdate.CallBackOnUpdateEnd(); --跳过灰度要执行回调
		end
    end
    
    VersionUpdate.AlreadyGrayUpdate = true;
end

--songGT ver devide，更新完成，处理一下初始化逻辑
function VersionUpdate.igame_download_finish_init_process()
	log("songGT igame_download_finish_init_process")
	-- body
	--FuncUtil:InitConfigs()
	--LobbyUI:ReleaseData()
	--RefluxTrainingAwardUI.InitData()
end

function VersionUpdate.CancelUpdate()
    --调蓝图的CancelUpdate最终会调到下面的VersionUpdate.OnFinishUpdate()函数
    --就能执行到LuaClassObj.HandleUIMessage(bp_authorization, "doAuthorization");
	LuaClassObj.HandleUIMessage(bp_versionupdate, "CancelUpdate")

	--songGT ver devide，更新完成，处理一下初始化逻辑
	VersionUpdate.igame_download_finish_init_process()
end

function VersionUpdate.DolphinCancelUpdate()
	LuaClassObj.HandleUIMessage(bp_versionupdate, "DolphinCancelUpdate");
end

function VersionUpdate.OnFinishUpdate()
	--取消更新会关闭更新界面，导致shader预编译黑屏，因此如果有更新则不进行shader预编译
	if BP_VersionUpdateInfo ~= nil and BP_VersionUpdateInfo.isNeedUpdating == "1" then
		VersionUpdate.AfterFinishUpdate();
	else
		ShaderPreCompileSystem.OnFinishUpdate();
	end
    --VersionUpdate.AfterFinishUpdate();
end

function VersionUpdate.AfterFinishUpdate()
    --隐藏更新界面
    log("versionupdate onfinishupdate")
    LuaClassObj.HandleUIMessage(bp_versionupdate, "Hide");
    
    --正常更新结束,开始鉴权;灰度更新则不用
    if not (VersionUpdate.GrayUpdate) then
    	log("not gray update, doAuthorization")
		LuaClassObj.HandleUIMessage(bp_authorization, "doAuthorization");
	end
	
	-- 灰度更新结束后再初始化puffer
	if VersionUpdate.GrayUpdate or Client.isSkipUpdateByRepair(GameFrontendHUD)  or Client.IsUpdateSkip(GameFrontendHUD) then
		log("update finish puffer here")
		Client.InitializePuffer(GameFrontendHUD, false, 3, 5, 20*1024*1024);
		log("update finish PreFetch Start")
		-- 以下三个接口均有分别的内部开关
		-- 清理拷贝出来的文件
		GCPufferDownloader.ClearPreFetchFiles(Puffer);
		-- 从包里预先搞一部分 pak 出来，配置文件里控制拷哪些
		GCPufferDownloader.PreFetchPakFiles(Puffer);
		-- 将拷贝出来的低于包版本号的 PreFetch 文件进行转换，至少有一个被转换时重新挂载
		if GCPufferDownloader.ConvertPreFetchFiles(Puffer) then
			GCPufferDownloader.RemountPakFiles(PufferDownloader);
		end
	end
    
    --回调
    if (VersionUpdate.CallBackOnUpdateEnd) then
    	log("gray update, do CallBackOnUpdateEnd");
        VersionUpdate.CallBackOnUpdateEnd();
    end
    VersionUpdate.GrayUpdate = false;
    VersionUpdate.CallBackOnUpdateEnd = nil;
	
	--刷新界面里显示的版本号
	if not (VersionUpdate.GrayUpdate) then
		log("finishupdate refreshgameversion")
		LuaClassObj.HandleUIMessage(bp_authorization, "RefreshGameVersion")
	end

	Client.ReportEventLoadingCompleted();

	--songGT ver devide，更新完成，处理一下初始化逻辑
	VersionUpdate.igame_download_finish_init_process()
end

function VersionUpdate.DisableResourceRepairAndGrayUpdate()
	--取消了 资源包推荐更新时 关闭资源修复、灰度更新同版本的patch;否则会额外弹出四次更新提示(3次是修复时弹出，1次是灰度时弹出)
	if BP_VersionUpdateInfo ~= nil and BP_VersionUpdateInfo.versionString ~= nil and BP_VersionUpdateInfo.isGrayUpdate ~= nil and BP_VersionUpdateInfo.isGrayUpdate ~= "1" then
		VersionUpdate.IgnoredVersionForGrayResourceUpdate = BP_VersionUpdateInfo.versionString;--跳过该版本的灰度更新
		log("disable gray resource update " .. VersionUpdate.IgnoredVersionForGrayResourceUpdate);
	end

	Client.DisableRepairResource(GameFrontendHUD);
end

function VersionUpdate.WifiResourceUpdate()
	--  android and ios资源更新
	local msgConfig = Client.GetTableData("LocalizeRes",5092)
	local tips = ""
	if msgConfig then
		tips = string.format(msgConfig.TextValue, BP_VersionUpdateInfo.needDownloadSize_f)
	end


	if BP_VersionUpdateInfo.isForcedUpdating == "1" or (BP_VersionUpdateInfo.isAppUpdating == "2" and BP_VersionUpdateInfo.needDownloadSize_f <= 2) then
		--资源包大小，小于2M，不确认，直接更新
		log("VersionUpdate.WifiResourceUpdate, new version of the resource, <= 2MB");
		LuaClassObj.HandleUIMessage(bp_versionupdate, "StartUpdate");
	else

		--资源更新，提示下载的大小
		local title = ""
		local msgConfig = Client.GetTableData("LocalizeRes",201001)
		if msgConfig then
			title = msgConfig.TextValue
		end
		
		local okLabel = ""
		local okConfig = Client.GetTableData("LocalizeRes",201003)
		if okConfig then
			okLabel = okConfig.TextValue
		end
		
		local cancelLabel = ""
		local cancelConfig = Client.GetTableData("LocalizeRes",110035)
		if cancelConfig then
			cancelLabel = cancelConfig.TextValue
		end
		
		local warning = ""
		if BP_VersionUpdateInfo ~= nil and BP_VersionUpdateInfo.isForcedUpdating == "1" then
			local warningConfig = Client.GetTableData("LocalizeRes",201022)
			if warningConfig then
				warning = warningConfig.TextValue
			end
		end

		CommonMessageBoxUI:ShowPanel(2,title,tips..warning,
		function()
			LuaClassObj.HandleUIMessage(bp_versionupdate, "StartUpdate");
		end,

		function()
			if BP_VersionUpdateInfo.isForcedUpdating == "1" then
				VersionUpdate.DolphinCancelUpdate();
				LuaClassObj.HandleUIMessage(bp_global, "quitGame");
			else
				VersionUpdate.DisableResourceRepairAndGrayUpdate();
				log("VersionUpdate.WifiResourceUpdate cancel update.");
				VersionUpdate.CancelUpdate();
			end
		end,
		okLabel,
		cancelLabel
		);
	end
end

function EventWifiNotifyIOSAppUpdate_Push()
    log("BP_VersionUpdateInfo isAppUpdating"..tostring(BP_VersionUpdateInfo.isAppUpdating))
    log("BP_VersionUpdateInfo isNeedUpdating"..tostring(BP_VersionUpdateInfo.isNeedUpdating))
	
	if BP_VersionUpdateInfo.isNeedUpdating == "1" then
		-- 版本更新
		if BP_VersionUpdateInfo.isAppUpdating == "1" then
			log("wifi ios app update")
			
			local title = ""
			local msgConfig = Client.GetTableData("LocalizeRes",201001)
			if msgConfig then
				title = msgConfig.TextValue
			end
			
			local okLabel = ""
			local okConfig = Client.GetTableData("LocalizeRes",201003)
			if okConfig then
				okLabel = okConfig.TextValue
			end
		
			local cancelLabel = ""
			local cancelConfig = Client.GetTableData("LocalizeRes",110035)
			if cancelConfig then
				cancelLabel = cancelConfig.TextValue
			end
			
			local contentStr1 = ""
			local contentStr1Config = Client.GetTableData("LocalizeRes",201005)
			if contentStr1Config then
				contentStr1 = contentStr1Config.TextValue
			end
			
			local contentStr2 = ""
			local contentStr2Config = Client.GetTableData("LocalizeRes",201006)
			if contentStr2Config then
				contentStr2 = contentStr2Config.TextValue
			end
			
			local warning = ""
			if BP_VersionUpdateInfo ~= nil and BP_VersionUpdateInfo.isForcedUpdating == "1" then
				local warningConfig = Client.GetTableData("LocalizeRes",201022)
				if warningConfig then
					warning = warningConfig.TextValue
				end
			end
		
			CommonMessageBoxUI:ShowPanel(2,title,contentStr1..warning,
			function()
                log("wifi ios app update confirm")
				
				VersionUpdate.DolphinCancelUpdate();
				if(BP_VersionUpdateInfo.isUsingDolphinUpdate == "1") then
					GDolphinUpdater.Install(Dolphin);
				end
				
				-- ios点击跳转后弹窗
				if BP_VersionUpdateInfo.isForcedUpdating == "1" then
					CommonMessageBoxUI:ShowPanel(1,title,contentStr2,
					function()
						VersionUpdate.OnClickJumpToAppStore()
					end);
				end
			end,
			function()
                log("wifi ios app update cancel")
				
				if BP_VersionUpdateInfo.isForcedUpdating == "1" then
					log("BP_VersionUpdateInfo.isForcedUpdating:1 click cancel quitGame")
					
					VersionUpdate.DolphinCancelUpdate();
					LuaClassObj.HandleUIMessage(bp_global, "quitGame");
				else
					log("BP_VersionUpdateInfo.isForcedUpdating:0 click cancel cancel update")
					
					VersionUpdate.CancelUpdate();
					log("VersionUpdate.CancelUpdate--EventWifiNotifyIOSAppUpdate_Push")
				end
			end,
			okLabel,
			cancelLabel
		);
		elseif BP_VersionUpdateInfo.isAppUpdating == "2" then
			VersionUpdate.WifiResourceUpdate();
		end
	end
end

function EventWifiNotifyAndroidAppUpdate_Push()
	log("EventWifiNotifyAndroidAppUpdate_Push")
	
	if BP_VersionUpdateInfo.isNeedUpdating == "1" then
		local tips = ""
		if BP_VersionUpdateInfo.isAppUpdating == "1" then
			-- 版本更新
			log("wifi android app update")
			
			local title = ""
			local msgConfig = Client.GetTableData("LocalizeRes",201001)
			if msgConfig then
				title = msgConfig.TextValue
			end
			
			local okLabel = ""
			local okConfig = Client.GetTableData("LocalizeRes",201003)
			if okConfig then
				okLabel = okConfig.TextValue
			end
		
			local cancelLabel = ""
			local cancelConfig = Client.GetTableData("LocalizeRes",110035)
			if cancelConfig then
				cancelLabel = cancelConfig.TextValue
			end
			
			local contentConfig = Client.GetTableData("LocalizeRes",201005)
			if contentConfig then
				tips = contentConfig.TextValue
			end
			
            local contentStr2 = ""
			local contentStr2Config = Client.GetTableData("LocalizeRes",201030) --"请跳转至GooglePlay下载全新版本"
			if Client.GetAOSSHOP() == 'Samsung' then
				contentStr2Config = Client.GetTableData("LocalizeRes", 4598) --"请跳转至三星商店下载全新版本"
			elseif Client.GetAOSSHOP() == 'Amazon' then
				contentStr2Config = Client.GetTableData("LocalizeRes", 5202) --"请跳转至亚马逊商店下载全新版本"
			end	
			if contentStr2Config then
				contentStr2 = contentStr2Config.TextValue
			end
            
			local warning = ""
			if BP_VersionUpdateInfo ~= nil and BP_VersionUpdateInfo.isForcedUpdating == "1" then
				local warningConfig = Client.GetTableData("LocalizeRes",201022)
				if warningConfig then
					warning = warningConfig.TextValue
				end
			end


			CommonMessageBoxUI:ShowPanel(2,title,tips..warning,
			--[[
            function()
				log("wifi android app update confirm")
				LuaClassObj.HandleUIMessage(bp_versionupdate, "StartUpdate")
			end,
            ]]
            
            function()
                log("wifi android app update confirm")
				
				local bCEVersion = Client.IsCEVersion() ;

				if bCEVersion then
					LuaClassObj.HandleUIMessage(bp_versionupdate, "StartUpdate")
				else
					VersionUpdate.DolphinCancelUpdate();
					if(BP_VersionUpdateInfo.isUsingDolphinUpdate == "1") then					
						GDolphinUpdater.Install(Dolphin);
					end

					-- Android点击跳转后弹窗
					if BP_VersionUpdateInfo.isForcedUpdating == "1" then
						CommonMessageBoxUI:ShowPanel(1,title,contentStr2,
						function()
							VersionUpdate.OnClickJumpToGooglePlay()
						end);
					end
				end
			end,
            
			function()
				log("wifi android app update cancel")
				if BP_VersionUpdateInfo.isForcedUpdating == "1" then
					log("BP_VersionUpdateInfo.isForcedUpdating:1 click cancel quitGame")
					
					VersionUpdate.DolphinCancelUpdate();
					LuaClassObj.HandleUIMessage(bp_global, "quitGame");
				else
					log("BP_VersionUpdateInfo.isForcedUpdating:0 click cancel cancel update")
					VersionUpdate.CancelUpdate();
				end
			end,
			okLabel,
			cancelLabel
			);
		elseif BP_VersionUpdateInfo.isAppUpdating == "2" then
			VersionUpdate.WifiResourceUpdate();
		end
	end
end

function EventNoWifiNotifyIOSAppUpdate_Push()
	log("[HHF]EventNoWifiNotifyIOSAppUpdate_Push, Without WiFi");
	if BP_VersionUpdateInfo.isNeedUpdating == "1" then
		if BP_VersionUpdateInfo.isAppUpdating == "1" then
            log("[HHF]EventNoWifiNotifyIOSAppUpdate_Push, isNeedUpdating = 1, isAppUpdating = 1, jump to appstore")
			
			local title = ""
			local msgConfig = Client.GetTableData("LocalizeRes",201001)
			if msgConfig then
				title = msgConfig.TextValue
			end
			
			local contentStr = ""
			local contentConfig = Client.GetTableData("LocalizeRes",201006)
			if contentConfig then
				contentStr = contentConfig.TextValue
			end
			
			GDolphinUpdater.Install(Dolphin);

			if BP_VersionUpdateInfo.isForcedUpdating == "1" then
				CommonMessageBoxUI:ShowPanel(1,title,contentStr,
				function()
					VersionUpdate.OnClickJumpToAppStore()
				end);
			end
			
		elseif BP_VersionUpdateInfo.isAppUpdating == "2" then
            log("[HHF]EventNoWifiNotifyIOSAppUpdate_Push, isNeedUpdating = 1, isAppUpdating = 2, call StartUpdate");

			--VersionUpdate.ShowNoEnoughSpaceTips();
			LuaClassObj.HandleUIMessage(bp_versionupdate, "StartUpdate");
		end
	end
end

function VersionUpdate.ShowNoEnoughSpaceTips()
	local space = Client.GetDeviceFreeSpace();
	local size = BP_VersionUpdateInfo.needDownloadSize_f;
	if size < space or string.lower(Client.GetDevicePlatformName()) == "windows" then
	else
		local notice = FuncUtil.GetLocalizeResStr(4179);
		PopUpNoticeUI.ShowNewNotice(notice);
	end
	log("[HHF]VersionUpdate.ShowNoEnoughSpaceTips, size = " .. tostring(size) .. ", space = " .. tostring(space));
end

function VersionUpdate.OnClickJumpToAppStore()
	local title = ""
	local msgConfig = Client.GetTableData("LocalizeRes",201001)
	if msgConfig then
		title = msgConfig.TextValue
	end
			
	local contentStr = ""
	local contentConfig = Client.GetTableData("LocalizeRes",201006)
	if contentConfig then
		contentStr = contentConfig.TextValue
	end

	if(BP_VersionUpdateInfo.isUsingDolphinUpdate == "1") then
		GDolphinUpdater.Install(Dolphin)
	end

	Timer.InsertTimer(0.01, function()
	CommonMessageBoxUI:ShowPanel(1,title,contentStr,
	function()
		VersionUpdate.OnClickJumpToAppStore()
	end);
	end, false, false);
end

-- Android无wifi 更新app
function EventNoWifiNotifyAndroidAppUpdate_Push()
	log("[HHF]EventNoWifiNotifyAndroidAppUpdate_Push, Without WiFi");
	
	if BP_VersionUpdateInfo.isNeedUpdating == "1" then
		if BP_VersionUpdateInfo.isAppUpdating == "1" then
            log("[HHF]EventNoWifiNotifyAndroidAppUpdate_Push, isNeedUpdating = 1, isAppUpdating = 1, jump to googleplay")
			
			local title = ""
			local msgConfig = Client.GetTableData("LocalizeRes",201001)
			if msgConfig then
				title = msgConfig.TextValue
			end
			
			local contentStr = ""
			local contentConfig = Client.GetTableData("LocalizeRes",201030)
			if Client.GetAOSSHOP() == 'Samsung' then
				contentConfig = Client.GetTableData("LocalizeRes", 4598) --"请跳转至三星商店下载全新版本"
			elseif Client.GetAOSSHOP() == 'Amazon' then
				contentConfig = Client.GetTableData("LocalizeRes", 5202) --"请跳转至亚马逊商店下载全新版本"
			end	

			if contentConfig then
				contentStr = contentConfig.TextValue
			end


			local bCEVersion = Client.IsCEVersion() ;

			if bCEVersion then
				LuaClassObj.HandleUIMessage(bp_versionupdate, "StartUpdate")
			else
				if(BP_VersionUpdateInfo.isUsingDolphinUpdate == "1") then
					GDolphinUpdater.Install(Dolphin);
				end

				if BP_VersionUpdateInfo.isForcedUpdating == "1" then
					CommonMessageBoxUI:ShowPanel(1,title,contentStr,
					function()
						VersionUpdate.OnClickJumpToGooglePlay()
					end);
				end
			end
			

			
		elseif BP_VersionUpdateInfo.isAppUpdating == "2" then
            log("[HHF]EventNoWifiNotifyAndroidAppUpdate_Push, isNeedUpdating = 1, isAppUpdating = 2, call StartUpdate");
			
			--VersionUpdate.ShowNoEnoughSpaceTips();
			LuaClassObj.HandleUIMessage(bp_versionupdate, "StartUpdate");
		end
	end
end

-- 国际化跳转googleplay
function VersionUpdate.OnClickJumpToGooglePlay()
    local title = ""
	local msgConfig = Client.GetTableData("LocalizeRes",201001)
	if msgConfig then
		title = msgConfig.TextValue
	end
			
	local contentStr = ""
	local contentConfig = Client.GetTableData("LocalizeRes",201030)  -- "请跳转至GooglePlay下载全新版本"
	if Client.GetAOSSHOP() == 'Samsung' then
		contentConfig = Client.GetTableData("LocalizeRes", 4598) --"请跳转至三星商店下载全新版本"
	elseif Client.GetAOSSHOP() == 'Amazon' then
		contentConfig = Client.GetTableData("LocalizeRes", 5202) --"请跳转亚马逊商店下载全新版本"
	end	

	if contentConfig then
		contentStr = contentConfig.TextValue
	end

	if(BP_VersionUpdateInfo.isUsingDolphinUpdate == "1") then
		GDolphinUpdater.Install(Dolphin)
	end

	Timer.InsertTimer(0.01, function()
	CommonMessageBoxUI:ShowPanel(1,title,contentStr,
	function()
		VersionUpdate.OnClickJumpToGooglePlay()
	end);
	end, false, false);
end


--windows端(默认全忽略)
function EventWindowsAppUpdate()
    if BP_VersionUpdateInfo.isNeedUpdating == "1" then
		local tips = ""
		if BP_VersionUpdateInfo.isAppUpdating == "1" then
			--忽略大版本更新
			VersionUpdate.CancelUpdate();
		elseif BP_VersionUpdateInfo.isAppUpdating == "2" then
			--忽略资源更新
			VersionUpdate.CancelUpdate();
		end
    else
        VersionUpdate.CancelUpdate();
	end
end

function VersionUpdate.OnRestartGame()
	local title = ""
	local msgConfig = Client.GetTableData("LocalizeRes",201007)
	if msgConfig then
		title = msgConfig.TextValue
	end
	
	local content = ""
	local contentConfig = Client.GetTableData("LocalizeRes",201008)
	if contentConfig then
		content = contentConfig.TextValue
	end
	
	LuaClassObj.HandleUIMessage(bp_versionupdate, "OnFinished");
    CommonMessageBoxUI:ShowPanel(1,title, content,
		function()
		    --退出游戏
		    LuaClassObj.HandleUIMessage(bp_global, "quitGame");
	end);
end

function VersionUpdate.OnRepairOverMaxTime()
	local title = ""
	local msgConfig = Client.GetTableData("LocalizeRes",201001)
	if msgConfig then
		title = msgConfig.TextValue
	end
	
	local content = ""
	local contentConfig = Client.GetTableData("LocalizeRes",5049) -- 更新文件损坏，请联系客服或重启客户端重试
	if contentConfig then
		content = contentConfig.TextValue
	end
	
	local helpLabel = ""
	local helpConfig = Client.GetTableData("LocalizeRes",4539) -- 帮助
	if helpConfig then
		helpLabel = helpConfig.TextValue
	end

	local exitLabel = ""
	local exitConfig = Client.GetTableData("LocalizeRes",4486) -- 退出
	if exitConfig then
		exitLabel = exitConfig.TextValue
	end

	LuaClassObj.HandleUIMessage(bp_versionupdate, "OnFinished");
    CommonMessageBoxUI:ShowPanel(2,title, content,
		function()
		    --退出游戏
		    LuaClassObj.HandleUIMessage(bp_global, "quitGame");
		end,
		function()
			VersionUpdate.delayTimerID = Timer.InsertTimer(1, 
				function()
					Timer.RemoveTimer(VersionUpdate.delayTimerID );
					VersionUpdate.OnRepairOverMaxTime();
				end,
			false, true);
			Client.HelpshiftShowConversion();
		end,
		exitLabel,
		helpLabel
	);
end

-- android拉起apk安装
function VersionUpdate.OnReadyToInstallApp()
	local title = ""
	local msgConfig = Client.GetTableData("LocalizeRes",201001)
	if msgConfig then
		title = msgConfig.TextValue
	end
	
	local content = ""
	local contentConfig = Client.GetTableData("LocalizeRes",201009)
	if contentConfig then
		content = contentConfig.TextValue
	end
	
	LuaClassObj.HandleUIMessage(bp_versionupdate, "OnFinished");
	
	log("GDolphinUpdater.Install")
	GDolphinUpdater.Install(Dolphin)
	CommonMessageBoxUI:ShowPanel(1,title,content,
		function()
			log("GDolphinUpdater.Install2")
			
			VersionUpdate.OnClickInstallApp()
		end);
end

function VersionUpdate.OnClickInstallApp()
	local title = ""
	local msgConfig = Client.GetTableData("LocalizeRes",201001)
	if msgConfig then
		title = msgConfig.TextValue
	end
	
	local content = ""
	local contentConfig = Client.GetTableData("LocalizeRes",201009)
	if contentConfig then
		content = contentConfig.TextValue
	end
	
	log("GDolphinUpdater.OnClickInstallApp")
	GDolphinUpdater.Install(Dolphin)
	CommonMessageBoxUI:ShowPanel(1,title,content,
		function()
			log("GDolphinUpdater.OnClickInstallApp2")
			
			VersionUpdate.OnClickInstallApp()
	end);
end

function VersionUpdate.OnUpdateProcess(curStage)
	log("onupdateprocess"..tostring(curStage))
    if 69 == curStage or 71 == curStage then
        BP_CurStage = "GetingVerInfo" --正在检查更新
	elseif 70 == curStage then
		BP_CurStage = "StartUpdateApk"--开始更新安装包
	elseif 74 == curStage or 75 == curStage or 76 == curStage or 77 == curStage or 79== curStage then
		BP_CurStage = "CheckingValidity"--正在校验安装包合法性
    elseif 95 == curStage then
        BP_CurStage = "Extraing"--正在解压
    elseif 78 == curStage then
		BP_CurStage = "ApkUpdateMergeDiff"--正在合并安装包（合并过程不会使用网络流量）：
	elseif 91 == curStage then
		BP_CurStage = "SourceUpdateDownloadList"--正在更新下载列表
	elseif 92 == curStage then
		BP_CurStage = "SourcePrepareUpdate"--准备更新资源
	elseif 93 == curStage then
		BP_CurStage = "SourceAnalyseDiff"--正在分析资源包差异
	elseif 99 == curStage then
		BP_CurStage = "Success"--更新完毕，正在为您加载资源
	else
        BP_CurStage = "Downloading"--正在下载：
    end
    --刷新进度条
    LuaClassObj.HandleUIMessage(bp_versionupdate, "RefreshProgress");
end

function VersionUpdate.OnNoticeUpdateError(errorCode)
	log("OnNoticeUpdateError"..tostring(errorCode))
	local code = tonumber(errorCode)
	local tips = ""
	local can_ignore=true;

	if code == 689045511 or code == 689045510 or code == 353501190 or code == 353435649 or code == 353501191 or code == 353502185 or code == 353501240 or code == 353501600 or code == 353501588 or code == 353501587 or code == 353501236 or
	code == 353501207 or code == 353502189 or code == 353501202 or code == 353502085 or code == 353501684 or code == 353501584 or code == 353501687 or code == 353501598 or code == 353501212 or
	code == 353501686 or code == 353501585 or code == 353501219 or code == 689045908 or code == 689045556 or code == 554827782 or code == 554827832 or code == 554827828 or code == 554828180 or
	code == 554762241 or code == 554828781 or code == 554827783 or code == 154140673 or code == 154140674 or code == 154140675 or (code >= 154140677 and code <= 154140697) or
	code == 154140711 or code == 154140712 or code == 87031824 or code == 420610452 or code == 154140706 or code == 353501185 or code == 154140713 or code == 154140714 or code == 154140715 or 
	code == 154140716 or code == 154140719 or code == 154140720	then
		local msgConfig = Client.GetTableData("LocalizeRes",201010)
		if msgConfig then
			tips = string.format(msgConfig.TextValue,tostring(errorCode))
		end

        can_ignore = false
		
		-- 作为容灾处理，如果在712错误下已经重试过一次，但是任然无法连接，则让用户跳过更新直接进入游戏
		if code == 154140712 or code == 154140713 or code == 154140714 or code == 154140715 or code == 154140716 or code == 154140719 then

			if VersionUpdate.hasRetried712 then
				if VersionUpdate.reported71X == 0 then
					VersionUpdate.reported71X = code;

					-- 只有下载过首包才存在跳过的情况
					if Client.HasDownloadedBasePak() then
						local param = 
						{
							current_version = Client.GetAppVersion() or "0.0.0.0";
							error_code = tostring(code);
						};
						log("[GEMReport]712skip Report curversion=BP_STRUCT_VersionUpdateInfo.versionString or '0.0.0.0' =>" .. tostring(param.current_version));
						Client.GEMReportEvent(GameFrontendHUD, "GCloud712Skip", param);
					end

					local isNetReachable = Client.IsNetworkReachable();
					if isNetReachable == true then
						local param = 
						{
							error_code = tostring(VersionUpdate.reported71X);
							type = "1";--Network reachable
						};
						log("71X but net is reachable");
						Client.GEMReportEvent(GameFrontendHUD, "71XButHasNet", param);
					end
				end

				--cdn update start
				VersionUpdater.dolphinUpdaterErrorCode = code;
				if VersionUpdater.StartCDNUpdate(code) then
					return;
				end
				--cdn update end

				--VersionUpdate.StartDownloadContentFromCDN("https://filecdn.igamecj.com/pubg/trunk/global/ios/config.json", 0, "", false)
				
				-- 只有下载过首包的玩家才会放过，否则没有大厅资源放过会跪掉
				if Client.HasDownloadedBasePak() then
					can_ignore = true;
				end
				-- 玩家登录时候还会检查一次更新，所以不重置712变量
				-- VersionUpdate.hasRetried712 = false;

				-- 如果没下载首包，补一个弹窗不跳过
				if not Client.HasDownloadedBasePak() then
					VersionUpdate.ShowRetryDownloadPanel(tips);
				end
			else
				VersionUpdate.hasRetried712 = true;
				VersionUpdate.ShowRetryDownloadPanel(tips)
			end
		else
			VersionUpdate.ShowRetryDownloadPanel(tips)
		end

	elseif code == 355471270 or code == 355467269 or code == 355469265 or code == 691011599 or code == 556793868 or code == 556793861 or code == 691011598 then
		local msgConfig = Client.GetTableData("LocalizeRes",201011)
		if msgConfig then
			tips = string.format(msgConfig.TextValue,tostring(errorCode))
		end
        can_ignore = false
		
		VersionUpdate.ShowRetryDownloadPanel(tips)
	elseif code == 353697820 or code == 555745297 or code == 689963036 or code == 689242140 then
		local msgConfig = Client.GetTableData("LocalizeRes",201012)
		if msgConfig then
			tips = string.format(msgConfig.TextValue,tostring(errorCode))
		end
        can_ignore = false
		
		VersionUpdate.ShowCofirmPanel(tips)
	elseif code == 688914441 or code == 556793859 or code == 288358404 or (code >= 422576129 and code <= 422576148) or (code >= 420478976 and code <= 421527551) or (code >= 489684993 and code <= 489685003) or 
	(code >= 487587840 and code <= 488636415) or (code >= 87031809 and code <= 87031821) or code == 87031823 or code == 691011591 or code == 691011585 then
		local msgConfig = Client.GetTableData("LocalizeRes",201012)
		if msgConfig then
			tips = string.format(msgConfig.TextValue,tostring(errorCode))
		end
        can_ignore = false
		
		VersionUpdate.ShowRetryDownloadPanel(tips)
	elseif code == 154140709 or code == 154140688 then
		local msgConfig = Client.GetTableData("LocalizeRes",201013)
		if msgConfig then
			tips = string.format(msgConfig.TextValue,tostring(errorCode))
		end
		
		--VersionUpdate.ShowCofirmPanel(tips)
	elseif code == 353697796 or code == 353697914 or code == 353697822 or code == 353697794 or code == 353697797 or code == 353697805 or code == 556793857 or code == 555745310 or code == 556793874 or code == 289407004 or 
	code == 289406980 or code == 289406993 or code == 289407098 or code == 289407085 or code == 288358406 or code == 289407006 or code == 289407071 or code == 691011585 then
		local msgConfig = Client.GetTableData("LocalizeRes",201014)
		if msgConfig then
			tips = string.format(msgConfig.TextValue,tostring(errorCode))
		end
		
		can_ignore = false
		VersionUpdate.ShowCofirmPanel(tips)
	elseif code == 555745308 or code == 555024412 then
		local msgConfig = Client.GetTableData("LocalizeRes",201032)
		if msgConfig then
			tips = string.format(msgConfig.TextValue,tostring(errorCode))
		end
		
		can_ignore = false
		VersionUpdate.ShowCofirmPanelLowMem(tips)
	elseif code == 554828179 then
		local msgConfig = Client.GetTableData("LocalizeRes",5060)
		if msgConfig then
			tips = string.format(msgConfig.TextValue,tostring(errorCode))  .. "(" .. tostring(code) .. ")"
		end
		
		can_ignore = false
		VersionUpdate.ShowCountDownRetryPanel(tips, 60);
	else
		local msgConfig = Client.GetTableData("LocalizeRes",201015)
		if msgConfig then
			tips = string.format(msgConfig.TextValue,tostring(errorCode))
		end
		
		can_ignore = false
		VersionUpdate.ShowCofirmPanel(tips)
		--[[(code >=355467264 and code <= 356515839) or code == 288358400 or code == 288358401 or code == 288358402 or code == 288358403 or code == 288358405 or (code >= 287309824 and code <= 288358399) or code == 154140676 or 
	code == 87031822 or code == 556793868 or code == 691011591 or code == 694288387--]]
	end
	
    if can_ignore then
        ---对某些“错误码”宽容一点，仅仅更新流程的错误就阻止游戏对谁都没好处，蜂拥的来联系工作人员就更惨了。
        GDolphinUpdater.FinishUpdate(Dolphin);
        return;
    end
end

function VersionUpdate.ShowRetryDownloadPanel(tips)
	log("showretrydownloadpanel"..tips)
	VersionUpdate.tempTips = tips;

	local title = ""
	local msgConfig = Client.GetTableData("LocalizeRes",201001)
	if msgConfig then
		title = msgConfig.TextValue
	end
	
	local okLabel = ""
	local okConfig = Client.GetTableData("LocalizeRes",201002)
	if okConfig then
		okLabel = okConfig.TextValue
	end
		
	local cancelLabel = ""
	local cancelConfig = Client.GetTableData("LocalizeRes",4539) -- 帮助
	if cancelConfig then
		cancelLabel = cancelConfig.TextValue
	end
	
	local warning = ""
	--[[ 取消按钮修改为帮助按钮，不需要添加点击取消退出游戏的提示
	if (BP_VersionUpdateInfo ~= nil and BP_VersionUpdateInfo.isForcedUpdating == "1") or BP_VersionUpdateInfo == nil then
		local warningConfig = Client.GetTableData("LocalizeRes",201022)
		if warningConfig then
			warning = warningConfig.TextValue
		end
	end
	--]]
	CommonMessageBoxUI:ShowPanel(2,title,tips..warning,	VersionUpdate.ClickRetryBtn, VersionUpdate.ClickCancelBtn, okLabel, cancelLabel);
end

function VersionUpdate.ShowCountDownRetryPanel(tips, countdownTime, interval)
	if interval == nil then
		interval = 1;
	end

	log("showretrydownloadpanel"..tips)
	VersionUpdate.tempTips = tips;

	local title = ""
	local msgConfig = Client.GetTableData("LocalizeRes",201001)
	if msgConfig then
		title = msgConfig.TextValue
	end
	
	local okLabel = ""
	local okConfig = Client.GetTableData("LocalizeRes",201002)
	if okConfig then
		okLabel = okConfig.TextValue
	end


	VersionUpdate.CountDownRetryRefreshedTime = os.time();
	VersionUpdate.CountDownRetryRefreshPassedTime = 0;
	LuaClassObj.HandleUIMessage(bp_common_messagebox_panel, "DisableOKBtn");
	CommonMessageBoxUI:ShowTimerPanel(1, title, tips .. "\n" .. tostring(countdownTime),
		VersionUpdate.ClickRetryBtn, -- retry function
		nil, okLabel, nil,
		function() -- timer & refresh function
			VersionUpdate.CountDownRetryRefreshPassedTime = VersionUpdate.CountDownRetryRefreshPassedTime + os.time() - VersionUpdate.CountDownRetryRefreshedTime;
			if countdownTime > 0 and VersionUpdate.CountDownRetryRefreshPassedTime > 1 then
				VersionUpdate.CountDownRetryRefreshPassedTime = VersionUpdate.CountDownRetryRefreshPassedTime - 1;
				countdownTime = countdownTime - 1;
				CommonMessageBoxUI:UpdateMsg(tips .. "\n" .. tostring(countdownTime));
			end

			if countdownTime == 0 then
				CommonMessageBoxUI:UpdateMsg(tips);
				LuaClassObj.HandleUIMessage(bp_common_messagebox_panel, "EnableOKBtn");
			end
		end
	);
end

function VersionUpdate.ClickRetryBtn()
	log("showretrydownloadpanel retrydownload")
			
	LuaClassObj.HandleUIMessage(bp_versionupdate, "RetryDownload")
end

function VersionUpdate.ClickCancelBtn()
	VersionUpdate.CancelCount = VersionUpdate.CancelCount + 1;
	log("showretrydownloadpanel cancelupdate")
	if BP_VersionUpdateInfo ~= nil then
		if BP_VersionUpdateInfo.isForcedUpdating == "1" then
			VersionUpdate.ConfirmClickCancelBtn();
		else
			log("BP_VersionUpdateInfo.isForcedUpdating:0 click cancel cancel update")
			VersionUpdate.CancelCount = 0;
			VersionUpdate.CancelUpdate();
			log("VersionUpdate.CancelUpdate--VersionUpdate.ClickCancelBtn")
		end
	else
		log("BP_VersionUpdateInfo is nil: click cancel quitGame")
		VersionUpdate.ConfirmClickCancelBtn();
	end
end

function VersionUpdate.ConfirmClickCancelBtn()
	if VersionUpdate.CancelCount == 5 then
		LuaClassObj.HandleUIMessage(bp_global, "quitGame");
	elseif VersionUpdate.CancelCount >= 1 then
		Client.HelpshiftShowConversion();
		VersionUpdate.delayTimerID = Timer.InsertTimer(2, VersionUpdate.DelayShowView, false, true);
	end
end

function VersionUpdate.DelayShowView()
	VersionUpdate.ShowRetryDownloadPanel(VersionUpdate.tempTips);
	Timer.RemoveTimer(VersionUpdate.delayTimerID );
end


function VersionUpdate.ShowCofirmPanel(tips)
	log("showcofirmpanel"..tips)
	
	local title = ""
	local msgConfig = Client.GetTableData("LocalizeRes",201001)
	if msgConfig then
		title = msgConfig.TextValue
	end
	
	local warning = ""
	if (BP_VersionUpdateInfo ~= nil and BP_VersionUpdateInfo.isForcedUpdating == "1") or BP_VersionUpdateInfo == nil then
		local warningConfig = Client.GetTableData("LocalizeRes",201022)
		if warningConfig then
			warning = warningConfig.TextValue
		end
	end

	local cancelLabel = FuncUtil.GetLocalizeResStr(110035);
	CommonMessageBoxUI:ShowPanel(1,title,tips..warning,
		function()
			log("showcofirmpanel cancelupdate")
			
			if BP_VersionUpdateInfo ~= nil then
				if BP_VersionUpdateInfo.isForcedUpdating == "1" then
					log("BP_VersionUpdateInfo.isForcedUpdating:1 click cancel quitGame")
					
					LuaClassObj.HandleUIMessage(bp_global, "quitGame");
				else
					log("BP_VersionUpdateInfo.isForcedUpdating:0 click cancel cancel update")
					VersionUpdate.CancelUpdate();
				end
			else
				log("BP_VersionUpdateInfo is nil: show cofirmpanel click cancel cancel update")
				LuaClassObj.HandleUIMessage(bp_global, "quitGame");
			end
		end,
		nil,
		cancelLabel,
		nil);
end

function VersionUpdate.ShowCofirmPanelLowMem(tips)
	log("showcofirmpanel"..tips)
	
	local title = ""
	local msgConfig = Client.GetTableData("LocalizeRes",201001)
	if msgConfig then
		title = msgConfig.TextValue
	end
	
	local warning = ""
	local warningConfig = Client.GetTableData("LocalizeRes",201022)
    if warningConfig then
        warning = warningConfig.TextValue
    end

	local cancelLabel = FuncUtil.GetLocalizeResStr(110035);
	CommonMessageBoxUI:ShowPanel(1,title,tips..warning,
		function()
			log("showcofirmpanel cancelupdate")
			
			LuaClassObj.HandleUIMessage(bp_global, "quitGame");
		end,
		nil,
		cancelLabel,
		nil);
end

-- 无网络环境下点击重试按钮
function VersionUpdate.RetryUpdateNoConnection()
	log("VersionUpdate.RetryUpdateNoConnection")
	
	local content = ""
	local contentConfig = Client.GetTableData("LocalizeRes",201016)
	if contentConfig then
		content = contentConfig.TextValue
	end
	
	VersionUpdate.ShowRetryDownloadPanel(content)
end

-- 无连接时点击开始更新，弹出提示框当前网络无连接
function EventNoConnectionStartUpdate_Push()
	log("EventNoConnectionStartUpdate_Push")
	
	VersionUpdate.RetryUpdateNoConnection()
end

function EventConfirmUpdateForJKVersion()
	log("[HHF]VersionUpdate.EventConfirmUpdateForJKVersion, new version of the resource, > 2MB");
	LuaClassObj.HandleUIMessage(bp_versionupdate, "NoWifiStartUpdate");
end

function EventCancelUpdateForJKVersion()
	log("[HHF]EventCancelUpdateForJKVersion");
	if BP_VersionUpdateInfo.isForcedUpdating == "1" then
		log("[HHF]VersionUpdate.EventCancelUpdateForJKVersion, isForcedUpdating = 1, clicked cancel, Call quitGame");
		VersionUpdate.DolphinCancelUpdate();
		LuaClassObj.HandleUIMessage(bp_global, "quitGame");
	else
		VersionUpdate.DisableResourceRepairAndGrayUpdate();
		log("[HHF]VersionUpdate.EventCancelUpdateForJKVersion, isForcedUpdating = 0, clicked cancel, Call CancelUpdate");
		VersionUpdate.CancelUpdate();
	end
end

--更新shader预编译进度
function EventShaderCompileProgress()
	ShaderPreCompileSystem.HandleTimer(0.2);
end

function VersionUpdate.StartDownloadContentFromCDN(Url, loaderType, savedDir, needBreakpointContinualTransfer, bDelayToRelaod)
	BP_CDNLoaderUrl = Url;
	BP_CDNLoaderType = loaderType;
	BP_CDNLoaderSavedDir = savedDir;
	BP_CDNNeedBreakpointContinualTransfer = needBreakpointContinualTransfer;
	log("StartDownloadPatchFromCDN,url: "..Url.." loaderType: "..loaderType.." savedDir: "..savedDir.." needBreakpointContinualTransfer: "..tostring(needBreakpointContinualTransfer).." bDelayToRelaod: "..tostring(bDelayToRelaod))
	if bDelayToRelaod then
		local funcCall = function()
			LuaClassObj.HandleUIMessage(bp_versionupdate, "StartDownloadCDNContent");            
        end
        log("delay StartDownloadCDNContent,delay: "..VersionUpdater.cdndownload_retryDelayTime);
        -- 延时下载
        Timer.InsertTimer(VersionUpdater.cdndownload_retryDelayTime, funcCall,false, false);
	else
        log("StartDownloadCDNContent immediately");
		LuaClassObj.HandleUIMessage(bp_versionupdate, "StartDownloadCDNContent");
	end
end