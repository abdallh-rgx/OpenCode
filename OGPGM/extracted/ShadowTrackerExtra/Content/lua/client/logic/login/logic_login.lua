
--[[
 登录相关逻辑
]]--

LoginSystem = LoginSystem or
{
	isConnectingGate = false;
	isConnectedGate = false;
	
	isConnectingLobby = false;
	isConnectedLobby = false;
	
	loginType = 0;
	
	-- 是否是重新登录
	isRelogin = false;
	
	-- 是否登录到大厅
	isInitLogin = false;
	
	-- 是否被踢
	hasKickOut = false;
	
	-- 是否登出
	hasLogout = false;
	
	-- 是否在切换账号
	isSwitchingAccount = false;

	-- 是排队进的游戏
	isInWaiting = false;
	-- 是否手Q游戏中心进入
	isFromQQGameCenter = false;
	
	-- 是否WX游戏中心进入
	isFromWXGameCenter = false;
	
    -- 直连开关 改到..\config\global.lua中去了，有问题找waynedong.
    
	--设置直连服务器，目前分游客、手Q、微信
	direct_login_server_list = {};
	--日韩单独分开，构建不同的直连服务器 
	direct_login_server_list_jk = {};
	--CE单独分开，构建不同的直连服务器 
	direct_login_server_list_ce = {};
  

	loginLobbyInfo = {};
	
	wakeupinfo = nil;
	extendInfo = {};

	loginLobbyUrlArray = {};
	loginLobbyIndex = 0,
    
    --成长守护被踢10秒倒计时踢回登录界面
	kickoutCountdown = 0,
	
	ip_region = "",

	continent = 0;

	commonSwitch = {}; -- 通用功能开关

	nation_switch = {},
	lastLogoutTime = 0,

	loginTimer = nil;
}

--新手引导
BeginnerGuideSystem = BeginnerGuideSystem or
{
	playerExperienceGrade = 0;							--玩家经验类型0为新手，数值越大经验等级越高
	finishedGuide = {};									--已完成的条目
}

---- 【注意注意注意】： 现在iOS提审已经不需要修改这个字段了，iOSCheck开关已经改到GCloud自定义字符串控制了, 以后没特殊情况，提审不需要修改这个文件了哇。-- waynedong
---- 【注意注意注意】： 现在iOS提审已经不需要修改这个字段了，iOSCheck开关已经改到GCloud自定义字符串控制了, 以后没特殊情况，提审不需要修改这个文件了哇。-- waynedong
---- 【注意注意注意】： 现在iOS提审已经不需要修改这个字段了，iOSCheck开关已经改到GCloud自定义字符串控制了, 以后没特殊情况，提审不需要修改这个文件了哇。-- waynedong

-- 全球正式服
LoginSystem.direct_login_server_list    = {channelInfo = "北美正式服", name = "北美正式服", addr = {"tcp://lobby.igamecj.com:17500","tcp://public.igamecj.com:35000","tcp://49.51.235.24:17500"}, status = 0, tab = 0};
-- 日韩正式服
LoginSystem.direct_login_server_list_jk = {channelInfo = "日韩正式服", name = "日韩正式服", addr = {"tcp://krlobby.igamecj.com:17500","tcp://krpublic.igamecj.com:8088","tcp://119.28.145.130:17500"}, status = 0, tab = 0};
--越南正式服
LoginSystem.direct_login_server_list_vng = {channelInfo = "越南正式服", name = "越南正式服", addr = {"tcp://vnglobby.igamecj.com:17500","tcp://vngpublic.igamecj.com:35000","tcp://49.51.67.224:17500"}, status = 0, tab = 0};
--台湾正式服
LoginSystem.direct_login_server_list_tw = {channelInfo = "台湾正式服", name = "台湾正式服", addr = {"tcp://twlobby.igamecj.com:17500","tcp://twpublic.igamecj.com:8088","tcp://49.51.67.151:17500"}, status = 0, tab = 0};

-- CE
LoginSystem.direct_login_server_list_ce = {channelInfo = "北美先游服", name = "北美先游服", addr = {"tcp://tlobby.igamecj.com:17500"}, status = 0, tab = 0};

--越南首次标志位
LoginSystem.IsFirstInVietnam = false;
--选择转移越南服
LoginSystem.IsChooseVietnam = false;


function LoginSystem.SetDirectLoginServer()

	-- iOS提审状态默认连提审服
	if GlobalData:IsIOSCheck() then
		LoginSystem.direct_login_server_list 	= {channelInfo = "全球提审服", name = "全球提审服", addr = {"tcp://apple4.igamecj.com:17500"}, status = 0, tab = 0};
		LoginSystem.direct_login_server_list_jk = {channelInfo = "日韩提审服", name = "日韩提审服", addr = {"tcp://kr-ios2.igamecj.com:17500"}, status = 0, tab = 0};
		LoginSystem.direct_login_server_list_vng ={channelInfo = "越南提审服", name = "越南提审服", addr = {"tcp://apple2.igamecj.com:17500"}, status = 0, tab = 0};
		LoginSystem.direct_login_server_list_tw = {channelInfo = "台湾提审服", name = "台湾提审服", addr = {"tcp://49.51.194.119:17500"}, status = 0, tab = 0};
	else
	-- 发布版本直连正式服
		LoginSystem.direct_login_server_list 	= {channelInfo = "全球正式服", name = "全球正式服", addr = {"tcp://lobby.igamecj.com:17500","tcp://public.igamecj.com:35000","tcp://49.51.235.24:17500"}, status = 0, tab = 0};
		LoginSystem.direct_login_server_list_jk = {channelInfo = "日韩正式服", name = "日韩正式服", addr = {"tcp://krlobby.igamecj.com:17500","tcp://krpublic.igamecj.com:8088","tcp://119.28.145.130:17500"}, status = 0, tab = 0};
		LoginSystem.direct_login_server_list_vng= {channelInfo = "越南正式服", name = "越南正式服", addr = {"tcp://vnglobby.igamecj.com:17500","tcp://vngpublic.igamecj.com:35000","tcp://49.51.67.224:17500"}, status = 0, tab = 0};
		LoginSystem.direct_login_server_list_tw = {channelInfo = "台湾正式服", name = "台湾正式服", addr = {"tcp://twlobby.igamecj.com:17500","tcp://twpublic.igamecj.com:8088","tcp://49.51.67.151:17500"}, status = 0, tab = 0};

	end

	-- CE
	--LoginSystem.direct_login_server_list_ce = {channelInfo = "日韩先游服", name = "日韩先游服", addr = {"tcp://krlobbyt.igamecj.com:17500"}, status = 0, tab = 0};
	LoginSystem.direct_login_server_list_ce 	= {channelInfo = "北美先游服", name = "北美先游服", addr = {"tcp://tlobby.igamecj.com:17500"}, status = 0, tab = 0};
	
	--log_tree("LoginSystem.direct_login_server_list = ", LoginSystem.direct_login_server_list.addr)
	--log_tree("LoginSystem.direct_login_server_list_jk= ", LoginSystem.direct_login_server_list_jk.addr)
	--log_tree("LoginSystem.direct_login_server_list_ce = ",LoginSystem.direct_login_server_list_ce.addr)
end

function LoginSystem.connectGateway(addrArray, addrID)
	if (addrArray == nil) or (#addrArray == 0) then
		return;
	end

	LoginSystem.loginLobbyUrlArray = addrArray;
	LoginSystem.loginLobbyIndex = 1;
	log("addrArray length: " .. #addrArray);

    --新的登录流程,不走网关,直接连大厅URL
    LoginSystem.loginLobbyInfo.Url = addrArray[1];
    LoginSystem.loginLobbyInfo.AddrID = addrID;
    LoginSystem.connectLobby();

--[[
	log("connectGateway = "..gate);
	 
	local function onConnected(eventType, eventID, vars)
		if eventType == EVENTTYPE_NETWORK and eventID == EVENTID_CONNECTED then
		
			local isConnected = vars[1];
			local reason  = vars[2];
			log("onConnected ".."reason = "..reason);

			LoginSystem.isConnectingGate = false;
			if isConnected then
				LoginSystem.isConnectedGate = true;
				
				LoginSystem.reqLobby();
				
				EventSystem:unregistEvent(EVENTTYPE_NETWORK, EVENTID_CONNECTED, onConnected);
			else
				log("connecting gate = "..gate.."failed for reason = "..reason);
			end
		end
	end
	EventSystem:registEvent(EVENTTYPE_NETWORK, EVENTID_CONNECTED, onConnected);


	NetUtil.ConnectToURL(gate);
	LoginSystem.isConnectingGate = true;
--]]
end

function LoginSystem.reconnectGateway()
	-- return true if have other option, by yarswang
	if(LoginSystem.loginLobbyIndex < #LoginSystem.loginLobbyUrlArray) then
		log("try reconnect");
		LoginSystem.loginLobbyIndex = LoginSystem.loginLobbyIndex + 1;
    	LoginSystem.loginLobbyInfo.Url = LoginSystem.loginLobbyUrlArray[LoginSystem.loginLobbyIndex];
    	LoginSystem.connectLobby();
		return true;
	end
	--or return false, by yarswang
	return false;
end

function LoginSystem.reqLobby()
	log("query lobby info--");
	LoginSystem.loginLobbyInfo.Ver = "1.0";
	NetUtil.SendPkg("query_lobby_info", LoginSystem.loginLobbyInfo.Ver);
end


function LoginSystem.connectLobby()
	local lobbyUrl = LoginSystem.loginLobbyInfo;
	log("lobby url = " .. LoginSystem.loginLobbyInfo.Url.."url id = ".. LoginSystem.loginLobbyInfo.AddrID);
	if not LoginSystem.loginLobbyInfo.Url or LoginSystem.loginLobbyInfo.Url == "" then
		return;
	end
		
	-- 停止游戏心跳，开启连接心跳
	NetUtil.connectionTick = true;
	NetUtil.gameTick = false;	

	-- 显示菊花
	ConnectionWaitingUI:Show();
	-- 记录时间
	NetUtil.SendTime = os.time();
	
	-- 发起连接
	NetUtil.ConnectToURL(LoginSystem.loginLobbyInfo.Url);
	Client.SetGameSrvID(GameFrontendHUD, LoginSystem.loginLobbyInfo.AddrID);
end

function LoginSystem.getStartUpType()
	local startup_type = BP_ENUM_STARTUPTYPE_COMM;
	if LoginSystem.isFromQQGameCenter then
		startup_type = BP_ENUM_STARTUPTYPE_QQGAME;
	elseif LoginSystem.isFromWXGameCenter then
		startup_type = BP_ENUM_STARTUPTYPE_WXGAME;
	end
	
	return startup_type;
end

function LoginSystem.reqLoginLobby(isRelogin)
    log("jaysun [Login process] LoginSystem.reqLoginLobby isRelogin:"..tostring(isRelogin));

	if LoginSystem.loginLobbyInfo == nil then
	log("LoginSystem.reqLoginLobby failed");
		return;
	end

	local ext_info = {
		--function c2s.login(ss, ver, device_info, startup_type, ext_info)
		--ext_info = {invite_info=sss, relogin=xxx, ...};
		relogin = isRelogin;
		ob_version = GetWindowOBState(),
	}
	
	NetUtil.StartCheckLoginRsp();
	
	LoginSystem.isRelogin = isRelogin;
	
    local ver = Client.GetAppVersion();
	
    --local emulatorName = Client.GetEmulatorName();
    --log("LoginSystem.emulatorName = " .. emulatorName);

	local isEmulator = Client.IsEmulator();
	log("IsEmulator:"..tostring(isEmulator));
	local device_type = isEmulator == true and 1 or 0;

	--local device_type = 0;
	
	log(string.format("LoginSystem send login %s, %s, %s", tostring(isRelogin), ver, device_type));
    --后台需要统计一些本地设备、系统信息
    DeviceOSInfo.getDeviceOSInfo();

	local emulatorName = Client.GetEmulatorName();
    DeviceOSInfo.InfoList.EmulatorName = emulatorName;
    log(string.format("LoginSystem EmulatorName %s", DeviceOSInfo.InfoList.EmulatorName));
	--启动来源要给后台
	local startup_type = LoginSystem.getStartUpType();
	local channelID = Client.GetInstallChannelID(NetInterface);
	local registerchannelID = Client.GetRegisterChannelID(NetInterface);
	log(string.format("reqLoginLobby channelID = %s, registerchannelID = %s", tostring(channelID), tostring(registerchannelID)));
    -- 初始化是否外发渠道
    local info = Client.GetTableData("ChannelInfo", tostring(channelID))
    if info and info.IsExternal == 1 then
        BP_IS_EXTERNAL_CHANNEL = true;
    else
        BP_IS_EXTERNAL_CHANNEL = false;
    end
    log(string.format("BP_IS_EXTERNAL_CHANNEL = %s", tostring(BP_IS_EXTERNAL_CHANNEL)))
	
	local currentTime = os.date("%Y-%m-%d %H:%M:%S", os.time());
	local timezone = Client.GetLocalTimezone();
	local language = Client.GetCurrentLanguage();
	local payPF = Client.GetMidasPF();
	
	-- 登录时上报所属商店渠道AOSSHOP信息
	local aosShopIndex = 0;
	local aosShop = Client.GetAOSSHOP();
	if string.lower(Client.GetDevicePlatformName()) == "android" then
		if aosShop == 'Google' then
			aosShopIndex = 0;
		elseif aosShop == 'Samsung' then
			aosShopIndex = 1;
		elseif aosShop == 'ThirdPartyPayment' then
			aosShopIndex = 2;
		elseif aosShop == 'Amazon' then
			aosShopIndex = 3;
		elseif aosShop == 'Simulator' then
			aosShopIndex = 4;
		end
	else
		aosShopIndex = 1000;
		aosShop = "NonAndroid";
	end
	
	log(string.format("AOSSHOP = %s, aosIndex = %d", tostring(aosShop),aosShopIndex));	
	
	local appVersion = Client.GetApplicationVersion();
	log("LoginSystem.reqLoginLobby version = " .. appVersion)

	--登录大厅有可能超时，先弹一个loading，等大厅回包之后，再干掉，否则20秒后自动干掉
	LoginSystem.RemoveLoginTimer();
	LoginSystem.loginTimer = Timer.InsertTimer(20, LoginSystem.LoginTimeOut, false, true);
	ConnectionWaitingUI:Show();

	NetUtil.SendPkg("login", ver, DeviceOSInfo.InfoList, startup_type, ext_info, device_type, channelID, registerchannelID, currentTime, language, timezone, payPF, aosShopIndex, appVersion);--LoginSystem.loginLobbyInfo.Ver, LoginSystem.loginLobbyInfo.Key
end

function LoginSystem.RemoveLoginTimer()
	ConnectionWaitingUI:Hide();
    if LoginSystem.loginTimer ~= nil then
		Timer.RemoveTimer(LoginSystem.loginTimer);
		LoginSystem.loginTimer = nil;
	end	
end

function LoginSystem.LoginTimeOut()
	local title = Client.GetTableData("LocalizeRes", "101001").TextValue
	local text = Client.GetTableData("LocalizeRes", "301228").TextValue
	CommonMessageBoxUI:ShowPanel(1, title, text, LoginSystem.backLogin, nil);
end

function LoginSystem.OpenPGUrl()
    LuaClassObj.HandleUIMessage(bp_global, "OpenPGUrl");
end

function LoginSystem.banLoginOKCallback()
	LoginSystem.sendLogout();

    local strRegion = Client.GetPublishRegion();
	if strRegion == "JAPAN" then
		Client.OpenURL("https://pubgmobile.jp/terms.html");		
	elseif strRegion == "KOREA" then
		Client.OpenURL("https://cafe.naver.com/battlegroundsmobile/6804");
	else
		Client.OpenURL("https://game.qq.com/contract_en.shtml");
	end
end

function LoginSystem.banLoginCancelCallback()
	LoginSystem.sendLogout();
    LuaClassObj.HandleUIMessage(bp_global, "ShowHelpshiftConversion");
end

function LoginSystem.on_login_failed(conn_idx, reason, banInfo, banTime)
	log("login_failed " .. conn_idx .. " " .. reason);

	--记录登录失败时间
	LoginProtectUtils.RecordLoginFailTime()
    
	-- 关闭登录重试逻辑
	NetUtil.StopCheckLoginRsp();
    
	LoginSystem.hasLogout = true;
	
	LoginSystem.isInitLogin = false;
	NetUtil.gameTick = false;
	NetUtil.connectionTick = false;
	
	-- 关闭连接
	NetUtil.Disconnect();
		
    LoginSystem.RemoveLoginTimer();
	
	Client.GEMReportEnterLobbyEvent(GameFrontendHUD, false, "kick out by server,"..reason);

    local title = Client.GetTableData("LocalizeRes", "101001").TextValue
    local text = Client.GetTableData("LocalizeRes", "101703").TextValue .. reason
    
    if (reason == "not-in-open-time") then
		-- 不在开放的时间
        text = Client.GetTableData("LocalizeRes", "101702").TextValue;
    elseif ( reason == "not-in-white-list") then
		-- 不在白名单
        text = Client.GetTableData("LocalizeRes", "101704").TextValue;
        --text = "尊敬的特种兵：\n        你暂未获得本次测试的体验资格，请留意官方最新公告。";
        textPG = Client.GetTableData("LocalizeRes", "110034").TextValue;
        CommonMessageBoxUI:ShowPanel(2, title, text, LoginSystem.OpenPGUrl, nil ,textPG, nil);
		--有登录态，需要刷新登录界面
		LuaClassObj.HandleUIMessage(bp_authorization, "showAuthorizationUI");
		LuaClassObj.HandleUIMessage(bp_login, "UIHide");
        return
    elseif ( reason == "activation-code-not-exists" or reason == "need-activation-code") then
        text = Client.GetTableData("LocalizeRes", "101704").TextValue;
        --text = "尊敬的特种兵：\n        你暂未获得本次测试的体验资格，请留意官方最新公告。";
		textPG = Client.GetTableData("LocalizeRes", "110034").TextValue;
        CommonMessageBoxUI:ShowPanel(2, title, text, LoginSystem.OpenPGUrl, nil ,textPG, nil);
		--有登录态，需要刷新登录界面
		LuaClassObj.HandleUIMessage(bp_authorization, "showAuthorizationUI");
		LuaClassObj.HandleUIMessage(bp_login, "UIHide");
		return;
    elseif ( reason == "ban-login") then
        local date = os.date("%Y-%m-%d %H:%M:%S", banTime);
        local textvalue = Client.GetTableData("LocalizeRes", "115007").TextValue;
		local textvalue2 = Client.GetTableData("LocalizeRes", "4999").TextValue;
		if Client.GetPublishRegion() == "VNG" then
			textvalue2 = Client.GetTableData("LocalizeRes", "16020").TextValue;
		end
        text = string.format(textvalue, banInfo.."\n", date)
		text = text .. "\n" .. textvalue2
		local btnOK = Client.GetTableData("LocalizeRes", "4003").TextValue;
		local btnCancel = Client.GetTableData("LocalizeRes", "4004").TextValue;
		CommonMessageBoxUI:ShowPanel(2, title, text, LoginSystem.banLoginCancelCallback, LoginSystem.banLoginOKCallback, btnCancel, btnOK)
        return;
    elseif ( reason == "aas_ban") then
        local timevalue = Client.GetTableData("LocalizeRes", "115005").TextValue;
        local date = os.date(timevalue, banTime);
        local textvalue = Client.GetTableData("LocalizeRes", "115011").TextValue;
        text = string.format(textvalue, date)
        CommonMessageBoxUI:ShowPanel(1, title, text, LoginSystem.backLogin, nil);
        return;
    elseif ( reason == "low-version") then
        text = Client.GetTableData("LocalizeRes", "101706").TextValue;
		-- CommonMessageBoxUI:ShowPanel(1, title, text, QuitGame, nil);

		local cancelLabel = ""
		local cancelConfig = Client.GetTableData("LocalizeRes",4539) -- 帮助
		if cancelConfig then
			cancelLabel = cancelConfig.TextValue
		end

		local helpCallback = function()
			Client.HelpshiftShowFAQsWithInfo();
		end

		CommonMessageBoxUI:ShowPanel(2, title, text, QuitGame, helpCallback, nil, cancelLabel);
        return;
    elseif ( reason == "low-version-diff") then
        text = Client.GetTableData("LocalizeRes", "101707").TextValue;
        CommonMessageBoxUI:ShowPanel(1, title, text, LoginSystem.backLogin, nil);
        return;
    elseif ( reason == "not-same-device") then --跟alan确认，该错误码已废弃.
		CommonMessageBoxUI:ShowPanel(1, title, "尊敬的特种兵： \n        首测期间每个账号仅可在同一台手机上登录，请更换首次注册手机后登录体验游戏。感谢你的理解和支持！", LoginSystem.backLogin, nil);
		return;
	elseif (reason == "register-exceed-limit") then
        local tips = DataMgr.GetMultiLineMsgByID(101708);
		CommonMessageBoxUI:ShowPanel(1, title, tips, LoginSystem.backLogin, nil);
		return;
	elseif (reason == "device-in-blacklist") then
		local function RefuseCallBack()
	        LuaClassObj.HandleUIMessage(bp_global, "quitGame");
	    end
		--local tips = "尊敬的特种兵：\n        《绝地求生：刺激战场》为腾讯与PUBG联合出品，虚幻4引擎研发，致力于完美还原端游体验的正版手游。根据设备检测结果，此机型暂未支持，后续将开放更多机型适配，建议更换设备后运行游戏。感谢您的支持和理解！";;
        local tips = DataMgr.GetMultiLineMsgByID(101716);
        CommonMessageBoxUI:ShowPanel(1, title, tips, RefuseCallBack, RefuseCallBack);
		return;
	elseif (reason == "idip-kick-out") then
        text = Client.GetTableData("LocalizeRes", "115006").TextValue;
        CommonMessageBoxUI:ShowTimerPanel(1, title, text, LoginSystem.sendLogout, nil, nil, nil, LoginSystem.kickoutCountdownTimerCallback);
        return;
	elseif (reason == "Vietnam-user-in-M") then
        text = Client.GetTableData("LocalizeRes", "6300").TextValue;
        CommonMessageBoxUI:ShowTimerPanel(1, title, text, LoginSystem.sendLogout, nil, nil, nil, LoginSystem.kickoutCountdownTimerCallback);
        return;
    end
    
    --登录失败，要给一个强烈的提示，点击返回登录界面
	CommonMessageBoxUI:ShowPanel(1, title, text, LoginSystem.backLogin, nil);
end

function LoginSystem.EnterPlayerCreate()
	log("enter PlayerCreate");
    BP_InitPercent = 20
    BP_LoadingTo = 0
    LoadingUI:Init();
    --进入创建角色场景
    LuaClassObj.HandleUIMessage(bp_global, "EnterCreateRole");
end

function LoginSystem.on_sync_lobby_info(ret, addr, key, hotfix)
	--sandbox.Log(Log, string.format("sync_lobby_info ret=%s ip=%s ,key = %s, hotfix=%s", ret, addr, key, hotfix));
	sandbox.LogNormal("sync_lobby_info ret="..ret..",ip="..addr..",key="..key..",hotfix="..hotfix);

	if ret == "ok" then
		LoginSystem.loginLobbyInfo =  
			{ 
				Url = addr,
				Key = key,
				Hotfix = hotfix,
			}

		--if (hotfix ~= nil and hotfix ~= "") then
			--dostring(hotfix)
		--end
		
		--log_tree("LoginSystem.loginLobbyInfo", LoginSystem.loginLobbyInfo);
		
		LoginSystem.connectLobby();
	else
		log("sync_lobby_info not ok:" .. ret);
	end
end

function LoginSystem.on_redirect(url)
    LoginSystem.loginLobbyInfo.Url = url;
    LoginSystem.connectLobby();
end

--成长守护等被踢10秒后回登录界面
function LoginSystem.kickoutCountdownTimerCallback()
    log("LoginSystem.kickoutCountdownTimerCallback" .. LoginSystem.kickoutCountdown);
    LoginSystem.kickoutCountdown = LoginSystem.kickoutCountdown + 1;
    if(LoginSystem.kickoutCountdown > 9) then
        LoginSystem.kickoutCountdown = 0;
    	CommonMessageBoxUI:HideAllMessageBox();
        LoginSystem.backLogin();
    end
end

-- 被踢响应
function LoginSystem.on_kickout(msg, banInfo, banTime)
    log("on_kickout " .. msg);
    LoginSystem.hasKickOut = true;
    
	-- 关闭连接
	NetUtil.Disconnect();
	
	-- 关闭菊花
	LoginSystem.RemoveLoginTimer();
	
	-- modify by rainpan 2018/04/23 被踢，清空登录态
	Client.ClearChannelID(NetInterface);
	
    local title = Client.GetTableData("LocalizeRes", "101001").TextValue;
    local text = Client.GetTableData("LocalizeRes", "111018").TextValue;
    if(msg == "not-in-open-time") then
        text = Client.GetTableData("LocalizeRes", "101702").TextValue;
        CommonMessageBoxUI:ShowTimerPanel(1, title, text, LoginSystem.backLogin, nil, nil, nil, LoginSystem.kickoutCountdownTimerCallback);
        return;
    elseif (msg == "ban-login" or msg == "parents_ban") then
        --LoginSystem.sendLogout();
        if(banTime == -1) then
            CommonMessageBoxUI:ShowTimerPanel(1, title, banInfo, LoginSystem.backLogin, nil, nil, nil, LoginSystem.kickoutCountdownTimerCallback);
        else
            local timevalue = Client.GetTableData("LocalizeRes", "115005").TextValue;
            local date = os.date(timevalue, banTime);
            local textvalue = Client.GetTableData("LocalizeRes", "115007").TextValue;
            text = string.format(textvalue, banInfo.."\n", date)
            CommonMessageBoxUI:ShowTimerPanel(1, title, text, LoginSystem.sendLogout, nil, nil, nil, LoginSystem.kickoutCountdownTimerCallback);
        end
        return;
    elseif (msg == "idip-kick-out") then
        --LoginSystem.sendLogout();
        text = Client.GetTableData("LocalizeRes", "115006").TextValue;
        CommonMessageBoxUI:ShowTimerPanel(1, title, text, LoginSystem.sendLogout, nil, nil, nil, LoginSystem.kickoutCountdownTimerCallback);
        return;
    elseif (msg == "aas_once_force_rest") then
        --{reachTime=xxx,restTime=xxx}
        local a = banInfo.reachTime / 3600;
        local b = math.floor(banInfo.restTime / 60);
        local notice = Client.GetTableData("LocalizeRes", "115004").TextValue;
        text = string.format(notice, a, b)
        CommonMessageBoxUI:ShowTimerPanel(1, title, text, LoginSystem.backLogin, nil, nil, nil, LoginSystem.kickoutCountdownTimerCallback);
        return;
    elseif (msg == "aas_acc_force_rest") then
        --{reachTime=xxx,restTime=xxx}
        local a = banInfo.reachTime / 3600;
        local b = math.floor(banInfo.restTime / 60);
        local notice = Client.GetTableData("LocalizeRes", "115004").TextValue;
        text = string.format(notice, a, b)
        CommonMessageBoxUI:ShowTimerPanel(1, title, text, LoginSystem.backLogin, nil, nil, nil, LoginSystem.kickoutCountdownTimerCallback);
        return;
    elseif (msg == "aas_acc_ban") then
        --banInfo={endTime=xxx}
        local timevalue = Client.GetTableData("LocalizeRes", "115005").TextValue;
        local date = os.date(timevalue, banInfo.endTime);
        local textvalue = Client.GetTableData("LocalizeRes", "115011").TextValue;
        text = string.format(textvalue, date)
        CommonMessageBoxUI:ShowTimerPanel(1, title, text, LoginSystem.backLogin, nil, nil, nil, LoginSystem.kickoutCountdownTimerCallback);
        return;
    elseif (msg == "aas_acc_curfew") then
        text = Client.GetTableData("LocalizeRes", "115010").TextValue;
        CommonMessageBoxUI:ShowTimerPanel(1, title, text, LoginSystem.backLogin, nil, nil, nil, LoginSystem.kickoutCountdownTimerCallback);
        return;
    elseif ( msg == "login-in-other-device") then
        CommonMessageBoxUI:ShowTimerPanel(1, title, text, LoginSystem.backLogin, nil, nil, nil, LoginSystem.kickoutCountdownTimerCallback);
        return;
    elseif ( msg == "gdpr_deleting") then
    	text = Client.GetTableData("LocalizeRes", "4367").TextValue;
    	CommonMessageBoxUI:ShowTimerPanel(1, title, text, LoginSystem.backLogin, nil, nil, nil, LoginSystem.kickoutCountdownTimerCallback);
    end
    CommonMessageBoxUI:ShowPanel(1, title, text, LoginSystem.backLogin);
end

function LoginSystem.on_logout(msg)
	log("on_logout " .. msg);	
	
	-- 显示Loading
    BP_LoadingTo = 0
	LoadingUI:Init();
	
	LoginSystem.hasLogout = true;
	
	LoginSystem.isInitLogin = false;
	NetUtil.gameTick = false;
	NetUtil.connectionTick = false;
	
	-- 返回登录 关闭loading
	LoginSystem.backLogin();		
		
    Client.Logout(NetInterface);
	
	-- 关闭连接
	NetUtil.Disconnect();
end

function LoginSystem.sendLogin(loginType)	
	log("gavin LoginSystem.sendLogin "..tostring(loginType));
    
	LoginSystem.hasLogout = false;
	LoginSystem.loginType = loginType;
	
	IMSDKSystem.StartIMSDKTimer(2);
	
	Client.Login(NetInterface, loginType);
end

-- rainpan: 自动登录
function LoginSystem.quickLogin()	
	local isForceAppUpdating = false;
	if BP_VersionUpdateInfo ~= nil and BP_VersionUpdateInfo.isNeedUpdating ~= nil and BP_VersionUpdateInfo.isAppUpdating ~= nil and BP_VersionUpdateInfo.isForcedUpdating ~= nil and BP_VersionUpdateInfo.isNeedUpdating == "1" and BP_VersionUpdateInfo.isAppUpdating == "1" and BP_VersionUpdateInfo.isForcedUpdating == "1" then
		isForceAppUpdating = true;
	end

	--强更不自动登录
	if not isForceAppUpdating then
		log("gavin LoginSystem.quickLogin");
	
		Client.QuickLogin(NetInterface);
	end
end

function LoginSystem.sendLogout(reason)
	log("LoginSystem.sendLogout !!!!");
	DeviceOSInfo.getDeviceOSInfo();
	NetUtil.SendPkg("logout", DeviceOSInfo.InfoList);	
	
	-- 关闭连接返回登录
	LoginSystem.backLogin(reason);
	
    Client.Logout(NetInterface);
end

function LoginSystem.sendLogoutWithoutLogoutAccount(reason)
	log("LoginSystem.sendLogoutWithoutLogoutAccount !!!!");
	DeviceOSInfo.getDeviceOSInfo();
	NetUtil.SendPkg("logout", DeviceOSInfo.InfoList);	
	
	-- 关闭连接返回登录
	LoginSystem.backLogin(reason);	
	
    --Client.Logout(NetInterface);
end

--返回到登入界面
--reason 1:异账号登陆
function LoginSystem.backLogin(reason)
    log("jaysun [Login process] LoginSystem.backLogin");
    --各个系统要自己清理，界面要关闭
    EventSystem:postEvent(EVENTTYPE_LOGIN, EVENTID_BACKLOGIN);
	
    --跳转到登录
	local curStatus = string.lower(LuaClassObj.GetGameStatus(bp_login));
	if curStatus ~= "login" then
		LuaClassObj.HandleUIMessage(bp_global, "EnterLogin");
	end
	
	if reason ~= 1 then
		LoginSystem.isFromQQGameCenter = false; 
		LoginSystem.isFromWXGameCenter = false;
	end
	
	LoginSystem.hasLogout = true;
	LoginSystem.isInitLogin = false;
	LoginSystem.hasKickOut = false;
	NetUtil.gameTick = false;
	NetUtil.connectionTick = false;

	--关闭潘多拉
	PandoraSystem.Release();
	
    --重新刷界面
    LuaClassObj.HandleUIMessage(bp_login, "UIHide");
	LuaClassObj.HandleUIMessage(bp_authorization, "hideAuthorizationUI");
	LuaClassObj.HandleUIMessage(bp_authorization, "showAuthorizationUI");
    LuaClassObj.HandleUIMessage(bp_authorization, "showButtons");
	LuaClassObj.HandleUIMessage(bp_versionupdate, "Hide");
	
	-- 关闭菊花
	LoginSystem.RemoveLoginTimer();
	
	-- 关闭Loading
	LoadingUI.RefreshLoadPercent(1);
	
	-- 关闭所有提示框
	CommonMessageBoxUI:HideAllMessageBox();

	--清理profile数据
	ProfileMgr.ResetProfileData();
	-- 关闭连接
	NetUtil.Disconnect();
end


function LoginSystem.enableLoginButton()
    LuaClassObj.HandleUIMessage(bp_login, "EnableLoginButton");
end

function LoginSystem.GetRegionNoByCountryNo(country)
	log("[HHF]LoginSystem.GetRegionNoByCountryNo, country = " .. country)
	local data = Client.GetTableData("RegionNo", country)
	if data then
		log("[HHF]LoginSystem.GetRegionNoByCountryNo, region = " .. tostring(data.region));
		Client.SetRegionNoByLua(NetInterface, data.region);
	else
		log("[HHF]LoginSystem.GetRegionNoByCountryNo, not found country")
		Client.SetRegionNoByLua(NetInterface, 0);--如果没有找到该地区，默认为全球
	end
end

--快速登录，包括异帐号处理
--wakeupinfo见GCloudQuickLoginServiceObserver的OnWakeupNotify
function LoginSystem.OnQuickLogin(wakeupinfo)
	if wakeupinfo["roominfo"] ~= nil then
		log("QRCode OnQuickLogin")
		-- 房间的信息是单独的，在QuickLogin后到达
		local roominfo = wakeupinfo["roominfo"];
		local roompwpos = string.find(roominfo, "rmpw");
		local roomttpos = string.find(roominfo, "t:");
		
		if RoomSystem.QRCodeRoomInfo == nil then
			RoomSystem.QRCodeRoomInfo = {};
		end;
		
		RoomSystem.QRCodeRoomInfo.game_roomid = string.sub(roominfo, 6, roompwpos - 2);
		if roomttpos == nil then
			RoomSystem.QRCodeRoomInfo.game_roompw = string.sub(roominfo, roompwpos+5, -1);
			RoomSystem.QRCodeRoomInfo.game_roomtime = 0;
		else
			RoomSystem.QRCodeRoomInfo.game_roompw = string.sub(roominfo, roompwpos+5, roomttpos - 2);
			RoomSystem.QRCodeRoomInfo.game_roomtime = string.sub(roominfo, roomttpos+2, -1);
		end;
		
		local nNow = math.floor(os.time() / 60);
		local QRCodeTime = tonumber(RoomSystem.QRCodeRoomInfo.game_roomtime);
		if nNow > ( QRCodeTime + 360 ) then
			log("QRCode Expired");
			RoomSystem.QRCodeRoomInfo = nil;
			-- 二维码失效
			DataMgr.ShowNoticeByID(110131);
			return;
		end;
		
		ClientSendBAReport(BP_BA_SHARE_ROOMQRCODE, 0);  -- 扫二维码登录房间
		
		if wakeupinfo["roominfoImm"] ~= nil and wakeupinfo["roominfoImm"] == "true" then
			RoomUI.OnQuickJoinRoom(RoomSystem.QRCodeRoomInfo);
		end;
		return;
	end;
	local state = math.floor(tonumber(wakeupinfo["Base_State"]));
	log("state".. tostring(state));
	local platform = math.floor(tonumber(wakeupinfo["Base_Platform"]));
	log("platform".. tostring(platform));
	--log_tree("wakeupinfo", wakeupinfo);
	LoginSystem.wakeupinfo = wakeupinfo;
	LoginSystem.CheckWakeupInfo();
	if state == 2 then
		--异帐号处理
		local toLoginPlatform = "";
		local currentLoginPlatform = "";
		if platform == BP_ENUM_PLAYFORM_WX then
			--toLoginPlatform = "微信";
			toLoginPlatform = Client.GetTableData("LocalizeRes", "101012").TextValue;
		elseif platform == BP_ENUM_PLAYFORM_QQ then
			--toLoginPlatform = "QQ";
			toLoginPlatform = Client.GetTableData("LocalizeRes", "301288").TextValue;
		end
		if BP_Platform == BP_ENUM_PLAYFORM_WX then
			--currentLoginPlatform = "微信";
			currentLoginPlatform = Client.GetTableData("LocalizeRes", "101012").TextValue;
		elseif BP_Platform == BP_ENUM_PLAYFORM_QQ then
			--currentLoginPlatform = "QQ";
			currentLoginPlatform = Client.GetTableData("LocalizeRes", "301288").TextValue;
		end
		--local tip = string.format("此%s帐号与当前游戏登录的帐号不一致，是否切换帐号？", toLoginPlatform);
		local tip = string.format(Client.GetTableData("LocalizeRes", "301138").TextValue, toLoginPlatform);
		CommonMessageBoxUI:ShowPanel(2, Client.GetTableData("LocalizeRes", "301137").TextValue, tip, function()
			Client.SwitchUser(NetInterface, true);
			LoginSystem.sendLogout(1);
		end);
	end
end

function LoginSystem.on_notify_game_rest_remind(isAcc, reachTime)
    log("on_notify_game_rest_remind "..isAcc.." "..reachTime)
    local title = Client.GetTableData("LocalizeRes", "101001").TextValue;
    local a = reachTime / 3600;
    if( isAcc == 1) then
        local notice = Client.GetTableData("LocalizeRes", "115001").TextValue;
        local text = string.format(notice, a);
        CommonMessageBoxUI:ShowPanel(1, title, text);
    else
        local notice = Client.GetTableData("LocalizeRes", "115002").TextValue;
        local text = string.format(notice, a);
        CommonMessageBoxUI:ShowPanel(1, title, text);
    end
end

function LoginSystem.on_notify_game_rest_force(isAcc, reachTime, restTime)
    log("on_notify_game_rest_force "..isAcc.." "..reachTime.." "..restTime)
    
    local title = Client.GetTableData("LocalizeRes", "101001").TextValue;
    local a = reachTime / 3600;
    local b = math.floor(restTime / 60);
    
    if( isAcc == 1) then
        local notice = Client.GetTableData("LocalizeRes", "115003").TextValue;
        local text = string.format(notice, a, b)
        CommonMessageBoxUI:ShowPanel(1, title, text, LoginSystem.backLogin);
    else
        local notice = Client.GetTableData("LocalizeRes", "115004").TextValue;
        local text = string.format(notice, a, b)
        CommonMessageBoxUI:ShowPanel(1, title, text, LoginSystem.backLogin);
    end
end

function LoginSystem.on_notify_game_aas_ban(banEndTime)
    log("notify_game_aas_ban "..banEndTime)
    local title = Client.GetTableData("LocalizeRes", "101001").TextValue;
    local timevalue = Client.GetTableData("LocalizeRes", "115005").TextValue;
    local date = os.date(timevalue, banEndTime);
    local textvalue = Client.GetTableData("LocalizeRes", "115011").TextValue;
    local text = string.format(textvalue, date)
    CommonMessageBoxUI:ShowPanel(1, title, text, LoginSystem.backLogin);
end

function LoginSystem.CheckWakeupInfo()
	if LoginSystem.wakeupinfo == nil then
		log("CheckWakeupInfo:LoginSystem.wakeupinfo == nil");
		return;
	end

	local wakeupinfo = LoginSystem.wakeupinfo
	
	--登陆来源检查
	LoginSystem.isFromQQGameCenter = false; 
	if wakeupinfo["launchfrom"] ~= nil and wakeupinfo["launchfrom"] == "sq_gamecenter" then
		LoginSystem.isFromQQGameCenter = true;
	end
	
	LoginSystem.isFromWXGameCenter = false
	if wakeupinfo["Base_OpenId"] ~= nil and wakeupinfo["Base_OpenId"] ~= "" and wakeupinfo["Base_MessageExt"] == "WX_GameCenter" then
		LoginSystem.isFromWXGameCenter = true;
	end
	
	local platform = math.floor(tonumber(wakeupinfo["Base_Platform"]));
	local extinfo = nil;
	if platform == BP_ENUM_PLAYFORM_WX then
		log("CheckWakeupInfo:BP_ENUM_PLAYFORM_WX");
		if wakeupinfo["Base_MessageExt"] ~= nil and wakeupinfo["Base_MessageExt"] ~= "" then
			log("MessageExt" .. tostring(wakeupinfo["Base_MessageExt"]));
			extinfo = wakeupinfo["Base_MessageExt"];
		end
	elseif platform == BP_ENUM_PLAYFORM_QQ then
		log("CheckWakeupInfo:BP_ENUM_PLAYFORM_QQ");
		if wakeupinfo["gamedata"] ~= nil and wakeupinfo["gamedata"] ~= "" then
			log("gamedata" .. tostring(wakeupinfo["gamedata"]));
			extinfo = wakeupinfo["gamedata"];
		end
	end

	if extinfo ~= nil then
		local decodedstr = FuncUtil:DecodeURI(extinfo);
		local decodedXML = FuncUtil:DecodeXML(decodedstr);
		local gamedata = json.decode (decodedXML);
		--保存透传数据供外部使用
		LoginSystem.extendInfo = gamedata;
		LoginSystem.CheckWakeupDataForTeamup();
	else
		LoginSystem.extendInfo = {};
	end
	
	LoginSystem.wakeupinfo = nil;
end

-- 检查是否平台拉起组队
function LoginSystem.CheckWakeupDataForTeamup()
	local gamedata = LoginSystem.extendInfo;
	if string.lower(LuaClassObj.GetGameStatus(bp_lobby)) == "lobby" and gamedata ~= nil and type(gamedata) == "table" then 
		if gamedata.team_roleid ~= nil and gamedata.team_teamid ~= nil then
			TeamUpSystem.JoinTeamByChat(tonumber(gamedata.team_roleid), tonumber(gamedata.team_teamid), "plat-invite");
		end
		LoginSystem.extendInfo = {};
	end
end

--收到服务器3秒重连问题
function LoginSystem.on_login_next(msg)   
	log("on_login_next"); 
	ConnectionWaitingUI:Show();
	if (msg == "Please try after 3 second") then
		log("Timer.InsertTimer(3, LoginSystem.OnLoginNextCallBack, false)");
		Timer.InsertTimer(3, LoginSystem.OnLoginNextCallBack, false);
	end
end

function LoginSystem.on_login_rsp(ip_region, nation_switch, continent, commonSwitch, pingSvrPars)
	log("LoginSystem: login_rsp ip_region=".. ip_region);

	--发登录协议的时候，弹出了loading，需要这里把它干掉。
	LoginSystem.RemoveLoginTimer();
	
	LoginSystem.ip_region = ip_region;

	log("LoginSystem: continent = ".. continent);
	LoginSystem.continent = continent;

	-- 自定义布局是否开启Json格式
	Client.SetUIElemLayoutJsonConfigSwitch(GameFrontendHUD, true)
	BP_UIElemLayout_UseJsonConfig = true
	-- 请求设置界面数据
	SettingSystem.query_custom_setting(1);

	log("LoginSystem: LoginSystem.commonSwitch.ReportBugSwitch = ".. tostring(LoginSystem.commonSwitch.ReportBugSwitch));
	if (commonSwitch ~= nil) then
		log_tree("LoginSystem: commonSwitch", commonSwitch);
		LoginSystem.commonSwitch = commonSwitch;
		Client.SetVoiceSwitch(GameFrontendHUD,
				LoginSystem.commonSwitch.FirstVoicePopupSwitch,
				LoginSystem.commonSwitch.EUGDPRFunctionSwitch,
				LoginSystem.commonSwitch.EUGDPRSettingSwitch);
		Client.SetSelfieSwitch(GameFrontendHUD, LoginSystem.commonSwitch.SelfieInBattleSwitch);
		Client.SetReportBugSwitch(GameFrontendHUD, LoginSystem.commonSwitch.ReportBugSwitch);
		if LoginSystem.commonSwitch.IceThemeSwitch then
			BP_Lobby_BgIceThemeSwitch = LoginSystem.commonSwitch.IceThemeSwitch;
		end
		if LoginSystem.commonSwitch.ResidentEvilThemeSwitch then
			BP_Lobby_BgResidentEvilThemeSwitch = LoginSystem.commonSwitch.ResidentEvilThemeSwitch;
		end
		if LoginSystem.commonSwitch.AnniversaryThemeSwitch then
			BP_Lobby_BgAnniversaryThemeSwitch = LoginSystem.commonSwitch.AnniversaryThemeSwitch;
		end
		if LoginSystem.commonSwitch.NewRewardPictureSwitch then
			BP_Lobby_BgAnniversaryGetSwitch =  LoginSystem.commonSwitch.NewRewardPictureSwitch;
		end

		if LoginSystem.commonSwitch.GEMUpdateEnable then
			GemReportUtils.CanReportLobbyEvent = LoginSystem.commonSwitch.GEMUpdateEnable;
		end

		Client.InitializeLaggingReporter(GameFrontendHUD, LoginSystem.commonSwitch.LagContextEnable);
	end
	--log("BP_IsInLobby.." .. tostring(BP_IsInLobby));
	--LobbyUI.SetLobbySkin();

	if (nation_switch ~= nil) then -- 兼容下老版本
		LoginSystem.nation_switch = nation_switch;
		LoginSystem.nation_switch.updated = true;
		Client.SetNationSwitch(GameFrontendHUD,
							   LoginSystem.nation_switch.NationAllSwitch,
							   LoginSystem.nation_switch.NationBattleSwitch,
							   LoginSystem.nation_switch.NationRankSwitch)
	end

    local strRegion = Client.GetPublishRegion();
	if strRegion == "JAPAN" or strRegion == "KOREA"  then
		local iTOP_country_no = Client.GetIPRegion();
		local same_with_gamesvr = false;
		if( (ip_region == "JP" and iTOP_country_no == 392) or (ip_region == "KR" and iTOP_country_no == 410)) then
			same_with_gamesvr = true;
		end
		local iTOPLbsDelay = Client.GetiTOPLbsDelay();
		
		local iTOPLbsEvent = 
		{
			success = tostring(iTOP_country_no ~= 0),
			country_no = tostring(iTOP_country_no),
			sameWithGameServer = tostring(same_with_gamesvr),
			delay = tostring(iTOPLbsDelay),
		};
		
		Client.GEMReportEvent(GameFrontendHUD, "iTOPLbs", iTOPLbsEvent);
		log("LoginSystem.login_rsp report lbs to GEM: success" .. tostring(iTOPLbsEvent.success));
		log("LoginSystem.login_rsp report lbs to GEM: country_no" .. tostring(iTOPLbsEvent.country_no));
		log("LoginSystem.login_rsp report lbs to GEM: sameWithGameServer" .. tostring(iTOPLbsEvent.sameWithGameServer));
		log("LoginSystem.login_rsp report lbs to GEM: delay" .. tostring(iTOPLbsEvent.delay));

		if(iTOP_country_no == 0) then
			local gamesvr_country_no = 0;
			if(ip_region == "JP") then
				gamesvr_country_no = 392;
			end

			if(ip_region == "KR") then
				gamesvr_country_no = 410;
			end
			Client.SetIPRegion(gamesvr_country_no);
		end
	end

	LoginSystem.ReportLocalResourcePakGEM();

	TeamUpUI.OnGetUDPPingIntervalTime(pingSvrPars);
end

--sami 服务器通知上次玩家离线时间
function LoginSystem.on_notify_last_logout_time(lastLogoutTime)
	LoginSystem.lastLogoutTime = lastLogoutTime
	log("LoginSystem.on_notify_last_logout_time " ..tostring(lastLogoutTime))
end

function LoginSystem.ReportLocalResourcePakGEM()
	local patternList = {
		K0 = "map_savagemain_" .. Client.GetApplicationVersion() .. ".pak";
		K1 = "map_desert_" .. Client.GetApplicationVersion() .. ".pak";
		K2 = "map_dihorotok_" .. Client.GetApplicationVersion() .. ".pak";
		K3 = "res_comml_" .. Client.GetApplicationVersion() .. ".pak";
		K4 = "^res_comml_%d+%.%d+%.%d+%.%d+%.prefetch$";
	}

	local param = 
	{
		SubEvent = "UserLocalResources",
		-- K0 = savagemain
		K0 = "false",
		-- K1 = desert
		K1 = "false",
		-- K2 = dihorotok
		K2 = "false",
		-- K3 = res_comml
		K3 = "false",
		-- K4 = res_comml_prefetch
		K4 = "false"
	};

	local ret = GCPufferDownloader.ReturnLocalFiles(PufferDownloader.DOWNLOAD_DIR_RELATIVE, "");
	for idx, filename in pairs(ret) do
		for key, pattern in pairs(patternList) do
			if string.match(filename, pattern) then
				param[key] = tostring(true);
			end
		end
	end


	log("LoginSystem.ReportLocalResourcePakGEM" ..
		"\n           ReportLocalResourcePakGEM savage: " .. tostring(param.K0) .. 
		"\n           ReportLocalResourcePakGEM desert: " .. tostring(param.K1) ..
		"\n           ReportLocalResourcePakGEM dihoro: " .. tostring(param.K2) ..
		"\n           ReportLocalResourcePakGEM res_comml: " .. tostring(param.K3) ..
		"\n           ReportLocalResourcePakGEM res_comml_prefetch: " .. tostring(param.K4));
	
	Client.GEMReportEvent(GameFrontendHUD, "PufferEvent", param);
end

--3秒结束后，重连
function LoginSystem.OnLoginNextCallBack()
	log("LoginSystem.OnLoginNextCallBack");
	ConnectionWaitingUI:Hide();
	if (LoginSystem.isInitLogin == false) then
		log("LoginSystem.reqLoginLobby(false)");
		LoginSystem.reqLoginLobby(false);
	end
end

function LoginSystem.NeedShowFirstInVietnam()
	log("LoginSystem.NeedShowFirstInVietnam");
	LoginSystem.IsFirstInVietnam = true;
end

--全球玩家第一次进越南提示
function LoginSystem.ShowFirstInVietnam()
	log("LoginSystem.ShowFirstInVietnam");
    
	local title = Client.GetTableData("LocalizeRes",101001).TextValue;
	local exitLabel = Client.GetTableData("LocalizeRes",4486).TextValue;
	local okLabel = Client.GetTableData("LocalizeRes",110036).TextValue;
	
	local tips = Client.GetTableData("LocalizeRes",16018).TextValue;
	
	local countdownTime = 60;
	LoginSystem.CountDownRetryRefreshedTime = os.time();
	LoginSystem.CountDownRetryRefreshPassedTime = 0;
	
	local timeString = FuncUtil.LocalizeResFormat("16019", countdownTime)
	local cancelString = exitLabel .. "(" .. countdownTime .. ")";
	
	local uiManager = require("ui.manager");
	local message_box = uiManager.ShowUI(uiManager.UI_Config.common_messagebox_timer)
	message_box.UIRoot.Slot:SetZOrder(151)
	message_box:SetShowInfo(title, tips .. "\n" .. tostring(timeString),
		LoginSystem.ClickContinue, -- retry function
		LoginSystem.ClickLogoutBtn, okLabel, cancelString,
		function() -- timer & refresh function
			LoginSystem.CountDownRetryRefreshPassedTime = LoginSystem.CountDownRetryRefreshPassedTime + os.time() - LoginSystem.CountDownRetryRefreshedTime;
			if countdownTime > 0 and LoginSystem.CountDownRetryRefreshPassedTime > 1 then
				LoginSystem.CountDownRetryRefreshPassedTime = LoginSystem.CountDownRetryRefreshPassedTime - 1;
				countdownTime = countdownTime - 1;
				--xx秒
				local timeString = FuncUtil.LocalizeResFormat("16019", countdownTime);
				local cancelString = exitLabel .. "(" .. countdownTime .. ")";
				message_box:UpdateContentText(tips .. "\n" .. timeString);
				message_box:UpdateCancelText(cancelString);
			end

			if countdownTime == 0 or LoginSystem.IsFirstInVietnam == false then
				uiManager.HideUI(uiManager.UI_Config.common_messagebox_timer)
				if LoginSystem.IsChooseVietnam == false then
					LoginSystem.ClickLogoutBtn();
				end
			end
		end
	);
end

function LoginSystem.ClickLogoutBtn()
	log("LoginSystem.ClickLogoutBtn");
	LoginSystem.IsFirstInVietnam = false;
	LoginSystem.sendLogout();
end

function LoginSystem.ClickContinue()
	log("LoginSystem.ClickContinue");
	LoginSystem.IsChooseVietnam = true;
	LoginSystem.IsFirstInVietnam = false;
	NetUtil.SendPkg("set_vietnam_user_req");
end

function LoginSystem.OnSetVietnamUser(res)
	if res ~= nil then
		log("LoginSystem.OnSetVietnamUser : " .. res);
	end
end

--新手引导，收到服务器查询已完成任务的回调
function BeginnerGuideSystem.on_get_fresher_info_rsp(fresher_info)
	--log_tree("on_get_fresher_info_rsp", fresher_info)
	TARRAY_PlayerFinishedGuideList = {}
	for k,v in pairs(fresher_info) do
		local data = {}
		data.guideID = k
		data.finishedCounts = v
		
		table.insert(TARRAY_PlayerFinishedGuideList, data)
	end
	--log_tree("PlayerFinishedGuideList", TARRAY_PlayerFinishedGuideList)
	local player_level = DataMgr.roleData.level;
	local player_fresher_type = DataMgr.fresher_type;
    
    log("get_fresher_info_rsp player_fresher_type"..tostring(player_fresher_type))
    log("get_fresher_info_rsp DataMgr.fresher_type"..tostring(DataMgr.fresher_type))
	IngameBeginnerGuide:on_retrive_finished_guide_finish(TARRAY_PlayerFinishedGuideList, player_level, player_fresher_type);
end

function BeginnerGuideSystem.send_refresher_info_req()
	log("get_fresher_info_rsp request player finished guide list--");
	NetUtil.SendPkg("get_fresher_info_req");
end
function BeginnerGuideSystem.send_record_finished_guide_req(guide_id)
	log("get_fresher_info_rsp request record finished guide --");
	NetUtil.SendPkg("set_fresher_info_req", guide_id);
end
--[[网络回调]]--
s2c["login_failed"] = LoginSystem.on_login_failed;
s2c["sync_lobby_info"] = LoginSystem.on_sync_lobby_info;
s2c["redirect"] = LoginSystem.on_redirect;

s2c["kickout"] = LoginSystem.on_kickout;
s2c["logout_rsp"] = LoginSystem.on_logout;

s2c["notify_game_rest_remind"] = LoginSystem.on_notify_game_rest_remind;
s2c["notify_game_rest_force"] = LoginSystem.on_notify_game_rest_force;
s2c["notify_game_aas_ban"] = LoginSystem.on_notify_game_aas_ban;

s2c["login_next"] = LoginSystem.on_login_next;

s2c["login_rsp"] = LoginSystem.on_login_rsp;
s2c["send_last_logout_time"] = LoginSystem.on_notify_last_logout_time;

s2c["get_fresher_info_rsp"] = BeginnerGuideSystem.on_get_fresher_info_rsp;

s2c["need_show_first_in_vietnam"] = LoginSystem.NeedShowFirstInVietnam;

s2c["set_vietnam_user_rsp"] = LoginSystem.OnSetVietnamUser;



--[[
连接后,客户端发送: c2s.login(ver), 其中ver是客户端版本号,
如果登录异常,会返回消息: s2c.login_failed(reason),可能的原因有角色被冻结之类的.
另外,也可能会返回消息要求客户端重定向到别的服务器,比如: s2c.redirect(url), 如果收到此消息,客户端应该断开连接,到指定的url重连登录.
成功则继续往下.
--]]
