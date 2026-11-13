--require("mobdebug").start("127.0.0.1")
--require('mobdebug').coro()

--[[
s2c["proto_name"] = function
or
s2c["proto_name"] = {module_name,function_name}
]]
local netProtocolMapping = {}
_G.s2c = s2c or setmetatable({}, {
	__index = function (t, k)
		local funcInfo = netProtocolMapping[k]
		-- 新的注册协议方式，写法：s2c["xxx"] = {"moduleName", "functionName"}
		local moduleName, functionName = funcInfo[1], funcInfo[2]
		local m = require(moduleName)
		assert(type(m) == "table" and type(m[functionName]) == "function",
				string.format("Can't find module[%s] function[%s] for s2c['%s']", moduleName, functionName, k))
		return m[functionName]
	end,

	__newindex = function (t,k,v)
		if type(v) == "function" then
			rawset(t,k,v) --老的写法，直接把值写入s2c
		elseif type(v) == "table" and #v == 2 then
			netProtocolMapping[k] = v
		else
			log_error(string.format("Net protocol regist error[%s]: %s", k, tostring(v)))
			local debug = require("debug")
			log_error(debug.traceback())
		end
	end
})

_G.UnrealNet = UnrealNet or {};

_G.NetUtil = NetUtil or 
{
	s2cNeedWaiting = {},
	
	--sami 网络连接事件时间打点
	tNetDisconnected = 0,
	tNetConnecting = 0,
	tNetConnected = 0,
};

-- tables exported from C++
_G.Net = _G.ScriptHelperNetInterface;
_G.Client = _G.ScriptHelperClient;

-- object pointers exported from C++
--[[
	LuaStateWrapper
	NetInterface
	GameFrontendHUD
--]]

--Connect SDK超时是15s。
NetUtil.ConnectSDKTimeOutSeconds = 15;
--Connect Lua超时是20s。在review代码时候，Lua和SDK Connect超时都是15s，处理逻辑又不在一次，存在进入两个处理逻辑时序不一致问题
NetUtil.ConnectLuaTimeOutSeconds = 20;
NetUtil.SendTime = NetUtil.SendTime or 0;
NetUtil.RecvTime = NetUtil.RecvTime or 0;

NetUtil.LobbyDelaySendTime = NetUtil.LobbyDelaySendTime or 0;
NetUtil.LobbyDelayRecvTime = NetUtil.LobbyDelayRecvTime or 0;

-- 重要请求发起时间
NetUtil.c2sTime = NetUtil.c2sTime or 0;
-- 断线重连，网络重接中tick激活标签
NetUtil.connectionTick = NetUtil.connectionTick or false;
-- 断线重连，游戏中tick激活标签
NetUtil.gameTick = NetUtil.gameTick or false;
-- 断线重连msgbox提示计数
NetUtil.showConnectionMsgTimes = NetUtil.showConnectionMsgTimes or 0;

-- 网络异常的时候尝试重连一次
NetUtil.hasTryConnectForNetworkError = NetUtil.hasTryConnectForNetworkError or false;

-- 进入战斗loading中重连等待re_enter_game
-- 在战斗中重连回来等待re_enter_game
NetUtil.checkWaitingReEnterGameNotify = NetUtil.checkWaitingReEnterGameNotify or false;
NetUtil.waitingReEnterGameStartTime = NetUtil.waitingReEnterGameStartTime or 0;

-- 战斗中大厅服务器断开后 静默重连设置
NetUtil.checkConnectingInFighting = false;
NetUtil.checkConnectingInFightingTimes = 0; -- 当前检测的次数
NetUtil.checkConnectingInFightingRandomInterval = 0;
NetUtil.waitingConnectSuccessStartTime = NetUtil.waitingConnectSuccessStartTime or 0;

-- 匹配成功后进入loading界面 等待进入战斗
NetUtil.checkEnterBattle = false;
NetUtil.waitingEnterBattleStartTime = NetUtil.waitingEnterBattleStartTime or 0;

-- 游戏中静默切换LobbyServer
NetUtil.checkLoginOtherLobbyServer = false;

-- 重登陆login重发机制
NetUtil.checkLoginRsp = NetUtil.checkLoginRsp or false;
NetUtil.checkLoginRetryTime = NetUtil.checkLoginRetryTime or 0;
NetUtil.checkBattleLoginRetryTime = NetUtil.checkBattleLoginRetryTime or 0;
NetUtil.sendLoginTime = NetUtil.sendLoginTime or 0;

-- ds服务器超时重试次数
NetUtil.dsTimeOutRetryTimes = NetUtil.dsTimeOutRetryTimes or 0;

NetUtil.CurTickTime = NetUtil.CurTickTime or 0;
NetUtil.LastTickTime = NetUtil.LastTickTime or 0;

--登录后的Midas SDK初始化调用标志
NetUtil.needInitMidasWhenLogin = NetUtil.needInitMidasWhenLogin or false;

--是否调用了不刷新UI的logout
NetUtil.noRefreshLogout = NetUtil.noRefreshLogout or false;

-- 客户端游戏结束，只针对大地图模式玩法
NetUtil.LobbyResultMonitor = NetUtil.LobbyResultMonitor or {gameover=false , gamemode="", lobbyReconnTimes=0};
NetUtil.ResultMonitorStarTime =0;
NetUtil.BResultMonitorOpen = false;
NetUtil.BBattleResultRecieved = false;
--客户端游戏结束
function OnClientGameOver()
	log("OnClientGameOver  mapMode:"..g_game_mode);

	if NetUtil.BBattleResultRecieved then
		return;
	end

	ResetResultMonitor();

	NetUtil.BResultMonitorOpen = true;
	NetUtil.ResultMonitorStarTime = os.time();
	
	NetUtil.LobbyResultMonitor.gameover = true;
	NetUtil.LobbyResultMonitor.gamemode = g_game_mode;
end	

function ResetResultMonitor()
	NetUtil.ResultMonitorStarTime =0;
	NetUtil.BResultMonitorOpen = false;
	NetUtil.LobbyResultMonitor = {gameover=false, gamemode = 0, lobbyReconnTimes=0};
	log_tree("ClientEntry ----- ResetResultMonitor", NetUtil.LobbyResultMonitor);
end

function UpdateResultMonitor()
	--log_tree("UpdateResultMonitor 1", NetUtil.LobbyResultMonitor);
	if not NetUtil.BResultMonitorOpen then 
		return;
	end

	if  not NetUtil.LobbyResultMonitor then
		return;
	end 
		
	if  not NetUtil.LobbyResultMonitor.gameover then
		return;
	end

	if os.time() - NetUtil.ResultMonitorStarTime < 2 then
		return;
	end
	NetUtil.ResultMonitorStarTime = os.time();
	NetUtil.LobbyResultMonitor.lobbyReconnTimes = NetUtil.LobbyResultMonitor.lobbyReconnTimes+1;

	-- todo filter the gamemode
	log_tree("ClientEntry ----- UpdateResultMonitor", NetUtil.LobbyResultMonitor);
	if NetUtil.LobbyResultMonitor.lobbyReconnTimes < 3 then
		return;
	end

	log("ClientEntry ----- UpdateResultMonitor  Force back to lobby");
	--弹出游戏结束提示
	local strTile =DataMgr.GetMsgByID(102012);
	-- 战斗已结束，请返回大厅
	--local strMsg = "战斗已结束，请返回大厅";
	local strMsg = Client.GetTableData("LocalizeRes",301111).TextValue;
	CommonMessageBoxUI:ShowConnectionPanel(1, strTile, strMsg, 
		function()
			-- 重新获取一下游戏状态
			curStatus = string.lower(LuaClassObj.GetGameStatus(bp_lobby));
			if curStatus == "fighting" then
				-- 打开loading
				BP_LoadingTo = 0
				LoadingUI:Init();
				-- 强行返回大厅
				Client.ReturnToLobby(GameFrontendHUD);
				
				-- 上报战斗服务器连接异常
				Client.TApmDisconnectReport(GameFrontendHUD, 17);

				local param = {};
				NetUtil.GEMReportEvent("NoConnectWhenResult", param);
			end
		end);

	ResetResultMonitor();

	return;
end

-- global tick for lua, maybe an event should be post here
function Tick(DeltaTime)
	
	NetUtil.CurTickTime = NetUtil.CurTickTime + DeltaTime;
	FuncUtil.LocalTimeTick = FuncUtil.LocalTimeTick + DeltaTime;
	if NetUtil.CurTickTime - NetUtil.LastTickTime > 5 then
		--log("ClientEntry -----  Tick Time ".. NetUtil.CurTickTime..", gameTick:"..tostring(NetUtil.gameTick)..", connectionTick:"..tostring(NetUtil.connectionTick)..", c2sTime:"..NetUtil.c2sTime..", os.clock:"..os.time()..", SendTime:"..NetUtil.SendTime..", kickout:"..tostring(LoginSystem.hasKickOut));
		NetUtil.LastTickTime = NetUtil.CurTickTime;
	end
	Timer.Tick(DeltaTime)
	NetUtil.CheckTime();
		
    NetUtil.OnTick(os.time(), DeltaTime);	
    local inBattle = LuaClassObj.InCombatState(bp_lobby)
	if inBattle == false then
		LobbyChatLogic.Tick(NetUtil.CurTickTime, DeltaTime);
		LobbyUI.Tick();
		Bargain_System_UI.Tick(DeltaTime);
		StoreSystem.Tick(DeltaTime);
	end
	
	--模拟器检测
	EmulatorSystem.Tick(DeltaTime);
	
	if HotUpdateSystem then
		HotUpdateSystem.Tick(DeltaTime);
	end
end


function NetUtil.GEMReportEvent(SubEventName, param)
	local GEM_param = {
		SubEvent = SubEventName
	};
	for i=1,#param do
		GEM_param["K" .. (i-1)] = param[i];
	end

	for k, v in pairs(GEM_param) do
		log("[BattleNetworkEvent] " .. tostring(k) .. " " .. tostring(v));
	end

	Client.GEMReportEvent(GameFrontendHUD, "BattleNetworkEvent", GEM_param);
end

-- 服务器回包
function NetUtil.DispatchPacket(msg, ... )
	if msg ~= "heart_beat" then
		log("ClientEntry ----- NetUtil.DispatchPacket:" .. msg);
	end
	
	NetDecorator.OnReceiveMsg(msg);
	local proc = s2c[msg];
	if not proc then
        log(string.format("undefined msg: %s", msg));
		return;
	end
	
	for i,v in ipairs(NetUtil.s2cNeedWaiting) do
		if v.callback == msg then
			table.remove(NetUtil.s2cNeedWaiting, i);
			
			if #NetUtil.s2cNeedWaiting == 0 then
				ConnectionWaitingUI:Hide();
				NetUtil.c2sTime = 0;
				log("ClientEntry ----- NetUtil.DispatchPacket  hide  ConnectWaitingUI");
			else
				-- 更新sendTime
				NetUtil.c2sTime = NetUtil.s2cNeedWaiting[1].sendTime;
				log("ClientEntry ----- NetUtil.DispatchPacket change c2sTime:"..NetUtil.c2sTime);
			end			
			break;
		end
	end

	--PacketCacher客户端协议缓存功能，缓存协议数据
    require("client.launcher.Extern")
	PacketCacher.getInstance():storeServerPacket(msg, ...)
	xpcall(proc, function(msg) sandbox.LogError(msg) sandbox.LogError(debug.traceback()) end, ...);
end

function NetUtil.SendTss()
	if Tss then
		TssManager.SendSkdData(Tss, LuaStateWrapper, NetInterface, "on_recv_client_data");
	end
end

--tss回包
function NetUtil.OnTssRsp(datalen, data)
	if Tss then
		TssManager.OnRecvData(Tss, datalen, data);
	end
end

local _enableCacher = true

function NetUtil.EnableCacher(value)
	_enableCacher = value
end

function NetUtil.SendPkg(...)
	local arg={...};

	--监控预警协议发送
	NetDecorator.MonitorMsg(arg[1]);
	if NetDecorator.OnSendMsg(arg[1]) then
		return
	end

	if arg[1] ~= "heart_beat" then
        log("ClientEntry ----- NetUtil.SendPkg: "..arg[1]);
	end


	
	--PacketCacher客户端协议缓存功能
	if _enableCacher == true then
	    require("client.launcher.Extern")
		if PacketCacher.getInstance():moniCall(...) == true then
			return
		end
	end

	if Client.IsConnected(NetInterface) then
		Net.SendPacket(LuaStateWrapper, NetInterface, ...);
	else
		log("ClientEntry -----  connection is failed throw pkg "..arg[1]);
	end
end


function NetUtil.SendPriorityPkg(needTryConnect, RspMsgID, ...)	
	local arg={...};
	
	--PacketCacher客户端协议缓存功能
	if _enableCacher == true then
	    require("client.launcher.Extern")
		if PacketCacher.getInstance():moniCall(...) == true then
			return
		end
	end

	if not Client.IsConnected(NetInterface) then
		log("ClientEntry -----  connection is failed throw pkg 2 "..arg[1]);
		return;
	end

	local isFind = false;
	for i,v in ipairs(NetUtil.s2cNeedWaiting) do
		if v == RspMsgID then
			-- 一个响应只储存一份
			isFind = true;	
			break;
		end
	end
	if not isFind then		
		table.insert(NetUtil.s2cNeedWaiting,
			{needTryConnect = needTryConnect, 
			callback = RspMsgID,
			sendPkg = arg[1],
			sendTime = os.time()});
	end
		
	ConnectionWaitingUI:Show();
	
	if NetUtil.c2sTime == 0 then
		NetUtil.c2sTime = os.time();
	end
	
	NetUtil.SendPkg(...);
end

function NetUtil.ConnectToURL(ip)
	
	log("jaysun [Login process] NetUtil.ConnectToURL "..ip..", time"..tostring(os.time()));
    Client.ConnectToURL(NetInterface, ip, NetUtil.ConnectSDKTimeOutSeconds);
end

function NetUtil.Disconnect()
	log("ClientEntry ----- NetUtil.Disconnect()");
	Client.Disconnect(NetInterface);
end

function NetUtil.EnterBattle(ip, port, key, name, packet_key, game_id, is_ob, ad_conf)
	log("ClientEntry ----- NetUtil.EnterBattle()");
	NetUtil.BBattleResultRecieved = false;
	-- 更新游戏国家法规资源替换表现开关
	Client.UpdatePublishRegionForBattle()
	
    Client.EnterBattle(GameFrontendHUD, ip, port, key, name, packet_key, game_id, (is_ob or false), ad_conf)
    g_game_id = game_id;
end

function NetUtil.OnConnected(isConnected, nReason)
	-- 获取当前游戏阶段
	local curStatus = string.lower(LuaClassObj.GetGameStatus(bp_lobby));	
	log("jaysun [Login process] ClientEntry -----  NetUtil.OnConnected "..tostring(isConnected)..", nReason: "..nReason..", isInitLogin:"..tostring(LoginSystem.isInitLogin));
	
	--登陆阶段连接超时后，先尝试其它可能, by yarswang
	local bKickOutSelf = LoginSystem.hasKickOut or LoginSystem.hasLogout or LoginSystem.isSwitchingAccount or NetUtil.checkLoginOtherLobbyServer;
	
	if(isConnected == false and curStatus == "login" and bKickOutSelf == false and (nReason == GCLOULD_ErrorTimeout or nReason == GCLOULD_ErrorConnectFailed or nReason == GCLOULD_ErrorInnerError)) then
		if(LoginSystem.reconnectGateway()) then
			log("ClientEntry -----  LoginSystem.reconnectGateway()")
			return;
		else
			Client.GEMReportEnterLobbyEvent(GameFrontendHUD, false, "reconnect backup server failed.");
		end
	elseif isConnected == false and bKickOutSelf == false then--主动退出的不上报
		Client.GEMReportEnterLobbyEvent(GameFrontendHUD, false, tostring(nReason));
	end
	
	-- 关闭菊花				
	if not NetUtil.checkLoginOtherLobbyServer then
		ConnectionWaitingUI:Hide();
	end
	
	if isConnected then						
		-- 异常重连成功 重置状态
		NetUtil.hasTryConnectForNetworkError = false;	
		
        -- 排队的进的游戏需关闭下面板
        if (LoginSystem.isInWaiting) then
			log("ClientEntry ----- is in LoginSystem.isInWaiting");
            CommonMessageBoxUI:HideAllMessageBox();
        end
		
		-- 关闭连接异常的消息面板
		if CommonMessageBoxUI.isShowing and CommonMessageBoxUI.isConnectionPanel then
			log("ClientEntry ----- Close ConnectionMessageBoxUI!!!!");
			CommonMessageBoxUI:HideConnectionPanel();
		end
				
		if LoginSystem.hasKickOut then
			-- 当前处理被踢状态 则不进行重连
			
			NetUtil.gameTick = false;
			NetUtil.connectionTick = false;
		else
			-- 连接成功发起login
			LoginSystem.reqLoginLobby(LoginSystem.isInitLogin);
			
			-- 停止连接心跳，开启游戏心跳
			NetUtil.connectionTick = false;
			NetUtil.gameTick = true;
						
		end
			
		-- 归零弹出提示次数
		NetUtil.showConnectionMsgTimes = 0;
		HeartBeatServerTime = NetUtil.GetCurServerTime(); -- 更新服务器时间
		NetUtil.SendTime = os.time(); 
		NetUtil.RecvTime = os.time(); 
		NetUtil.LobbyDelaySendTime = os.clock();
        NetUtil.LobbyDelayRecvTime = os.clock();
		
		-- 清空
		NetUtil.c2sTime = 0; 
		NetUtil.s2cNeedWaiting = {};
		
		-- 设置连接检查
		NetUtil.checkConnectingInFighting = false;
		NetUtil.checkConnectingInFightingTimes = 0;
		
		BP_LobbyNetworkStatus = true;
		LobbyUI:UpdateNetworkDelay();

		EventSystem:postEvent(EVENTTYPE_NETWORK, EVENTID_LOBBY_SERVER_CONNECT_SUCCESS);
	else
		--记录登录失败时间
		LoginProtectUtils.RecordLoginFailTime()
		
		log("ClientEntry ----- OnConnected Failed curStatus = "..curStatus..", url = "..LoginSystem.loginLobbyInfo.Url.." for reason = "..nReason);
		
		EventSystem:postEvent(EVENTTYPE_NETWORK, EVENTID_LOBBY_SERVER_CONNECT_FAILED);
				
		if LoginSystem.hasKickOut or LoginSystem.hasLogout or LoginSystem.isSwitchingAccount or NetUtil.checkLoginOtherLobbyServer then
			-- 如果当前处于被踢状态 不做连接异常处理
			log("ClientEntry ----- tryConnectLobby failed is in kickout or logout state! hasKickOut:"..tostring(LoginSystem.hasKickOut)..", hasLogout:"..tostring(LoginSystem.hasLogout));
			NetUtil.connectionTick = false;
			NetUtil.gameTick = false;
			return;
		end
		
		local errorMsg = FuncUtil:GetGCloudErrorMsg(nReason);
		
		-- 设置连接状态
		if curStatus == "fighting" then
			-- 战斗中不弹出任何大厅连接异常的提示
			-- 开启定时重连
			if not NetUtil.checkConnectingInFighting then
				-- 开启静默连接等待大厅连接成功
				NetUtil.checkConnectingInFighting = true;
				NetUtil.waitingConnectSuccessStartTime = os.time();
				log("ClientEntry -----  waitingConnectSuccessStartTime:"..NetUtil.waitingConnectSuccessStartTime);	
			end
		else
			-- 其他阶段
			if nReason == -1 
				or nReason == GCLOULD_ErrorNetworkException
				or nReason == GCLOULD_ErrorTimeout
				or nReason == GCLOULD_ErrorChecking
				or nReason == GCLOULD_ErrorConnectFailed then
				
				-- 连接失败，需要提示尝试重连
				if not NetUtil.hasTryConnectForNetworkError then
					log("ClientEntry ----- After Connect Failed For Newwork Try Connect One Time......");
					NetUtil.hasTryConnectForNetworkError = true;
					NetUtil.tryConnect();
				else
					-- 连接失败，等待连接心跳超时
					log("ClientEntry ----- Show ConnectingErrorMsg ......");
					NetUtil.showConnectionMsgTimes = NetUtil.showConnectionMsgTimes + 1;
					NetUtil.ShowConnectionMsgBox(NetUtil.showConnectionMsgTimes, errorMsg);	
				end			
			
			else
				-- 连接失败  关闭模态菊花
				NetUtil.connectionTick = false;
				NetUtil.gameTick = false;
		
				local strTile = DataMgr.GetMsgByID(102012);
				
				-- 只有确定
				CommonMessageBoxUI:ShowConnectionPanel(1, strTile, errorMsg, 
					function()								
						-- 登出逻辑
						LoginSystem.backLogin();
					end);				
			end

			ResetResultMonitor();
		end
	end		
	
	local param = {};
	table.insert(param, isConnected);
	table.insert(param, nReason);
	EventSystem:postEvent(EVENTTYPE_NETWORK, EVENTID_CONNECTED, param);
end

--连接状态回调
function NetUtil.OnStateChange(state, param1, param2, param3)
	log("ClientEntry ----- OnStateChange State:"..state..", Param1:"..param1..", Param2:"..param2..", Param3:"..param3);
	if state == 0 then
		log("ClientEntry ----- GCloud::Conn::kConnectorStateRunning");
		--正在运行,无需处理
	elseif state == 1 then
		log("ClientEntry ----- GCloud::Conn::kConnectorStateReconnecting.......");
		NetUtil.ProcOnConnecting()
		--正在重连,不处理
	elseif state == 2 then
		log("ClientEntry ----- GCloud::Conn::kConnectorStateReconnected isConnect:"..param1);
		NetUtil.ProcOnConnected()
		if NetUtil.CheckSpecialDeviceNetFlash() then
			log("NetUtil.OnStateChange check special device net flash")
			ConnectionWaitingUI:Hide()
		else
			-- 进入重连响应
			NetUtil.OnConnected((param1 == 0), param1);
		end
	elseif state == 3 then
		log("ClientEntry ----- GCloud::Conn::kConnectorStateStayInQueue");
		local queuePosition = param1;
		local queueLength = param2;
		local estimateTime = param3;
		log(string.format("Queue, current position:%d of total quque length:%d,estimateTime=%d", queuePosition, queueLength, estimateTime));
        
        LoginSystem.isInWaiting = true;
		NetUtil.connectionTick = false;
		NetUtil.gameTick = false;
        
		local function cancelWaiting()
            log("ClientEntry ----- cancelWaiting..")
            LoginSystem.backLogin();
        end
        local timewait = math.floor(estimateTime / 60);
        CommonMessageBoxUI:HideAllMessageBox();
		local str = Client.GetTableData("LocalizeRes",301108).TextValue;
		local str2 = Client.GetTableData("LocalizeRes",301109).TextValue;
		local str3 = Client.GetTableData("LocalizeRes",110035).TextValue;
		--local text = string.format("服务器已满，您现在正在队列中。\n        您在队列中的位置:%d\n          预计等待时间%d分钟", queuePosition, timewait);
		local text = string.format(str, queuePosition, timewait);
		--CommonMessageBoxUI:ShowPanel(1, "登录队列", text, cancelWaiting, nil, "取消");
		CommonMessageBoxUI:ShowPanel(1, str2, text, cancelWaiting, nil, str3);
	elseif state == 4 then
		log("ClientEntry ----- GCloud::Conn::kConnectorStateError ");
		NetUtil.ProcOnDisconnected()
		
		local errorCode = param1;
		log("ClientEntry ----- errorCode == "..errorCode);
		
		if errorCode == 207 or errorCode == 205 then
			log("ClientEntry ----- GCloud::Conn::kErrorSendError");
			NetUtil.OnConnected(false, 201);
		else
			if param2 == 7 then
				log("ClientEntry ----- 后台主动将客户端踢下线");
				log("ClientEntry ----- extendCodeOfGameSvr = "..param3);
			else
				log("ClientEntry ----- extend = "..param2.."extend2 = "..param3);
			end	
			
			NetUtil.OnConnected(false, errorCode);
		end
	end
end


function NetUtil.OnDisconnected(nReason)
	sandbox.LogError("NetUtil.OnDisconnected nReason：".. nReason);
	log("ClientEntry ----- NetUtil.OnDisconnected nReason：".. nReason);
end

-- tick检查逻辑
function NetUtil.CheckTime()
	
	if NetUtil.checkLoginRsp then
		-- 检查login回包
		if NetUtil.sendLoginTime > 0 and os.time() - NetUtil.sendLoginTime > 5 then
			if NetUtil.checkLoginRetryTime == 0 then
				-- 只做一次重试
				log("ClientEntry -----  checkLoginRsp timeout!! "..NetUtil.checkLoginRetryTime..", isRelogin:"..tostring(LoginSystem.isRelogin));
				LoginSystem.reqLoginLobby(LoginSystem.isRelogin);				
				NetUtil.checkLoginRetryTime = NetUtil.checkLoginRetryTime + 1;
			else
				--记录登录失败时间
				--LoginProtectUtils.RecordLoginFailTime()
			end

			-- 战斗内，检查login是否回包，如果没有则代表网络不通，再次尝试重连
			local status = string.lower(LuaClassObj.GetGameStatus(bp_lobby));		
			if status == "fighting"  then
				if NetUtil.checkBattleLoginRetryTime == 0 or NetUtil.checkBattleLoginRetryTime == 2 or NetUtil.checkBattleLoginRetryTime == 5 then
					log("ClientEntry ----- tryConnect lobby in fighting when login failed");
					NetUtil.tryConnect();
				end
				NetUtil.checkBattleLoginRetryTime = NetUtil.checkBattleLoginRetryTime + 1;
			end
		end
	end
	if NetUtil.checkEnterBattle then

		if os.time() - NetUtil.waitingEnterBattleStartTime > 60 then
			-- 关闭超时检查
			NetUtil.StopCheckEnterBattle();
			local curStatus = string.lower(LuaClassObj.GetGameStatus(bp_lobby));			
			log("ClientEntry -----  checkEnterBattle timeout!! curStatus:"..curStatus..", isWaittingEnterBattle:"..tostring(LobbySystem.isWaittingEnterBattle));			
			
			-- 关闭菊花
			ConnectionWaitingUI:Hide();
			
			if LobbySystem.isWaittingEnterBattle then							
				-- 当前在loading页面，重置匹配状态			
				LobbySystem.SetWaitingBattleFlag(false);
				-- 强行返回大厅
				Client.ReturnToLobby(GameFrontendHUD);
				-- 发起重连触发重回战斗
				LoginSystem.reqLoginLobby(true);
			end
		end
	end
	
	-- 检查在loading中断线重现逻辑
	if NetUtil.checkWaitingReEnterGameNotify then
		if os.time() - NetUtil.waitingReEnterGameStartTime > 5 then
			-- 关闭超时检查
			NetUtil.StopCheckDSActive();			
			local curStatus = string.lower(LuaClassObj.GetGameStatus(bp_lobby));			
			log("ClientEntry -----  checkWaitingReEnterGameNotify timeout!! curStatus:"..curStatus..", isWaittingEnterBattle:"..tostring(LobbySystem.isWaittingEnterBattle));			
			
			-- 关闭菊花
			ConnectionWaitingUI:Hide();
			
			if LobbySystem.isWaittingEnterBattle then
				-- 当前在loading页面，重置匹配状态			
				LobbySystem.SetWaitingBattleFlag(false);
				-- 强行返回大厅
				Client.ReturnToLobby(GameFrontendHUD);
			elseif curStatus == "fighting" and not BattleResult.IgnoreDSError then --结算后要忽略所有ds链接错误
				-- 提示
				local strTile =DataMgr.GetMsgByID(102012);
				-- 战斗已结束，请返回大厅
				--local strMsg = "战斗已结束，请返回大厅";
				local strMsg = Client.GetTableData("LocalizeRes",301111).TextValue;
				CommonMessageBoxUI:ShowConnectionPanel(1, strTile, strMsg, 
					function()
						-- 重新获取一下游戏状态
						curStatus = string.lower(LuaClassObj.GetGameStatus(bp_lobby));
						if curStatus == "fighting" then
							-- 打开loading
							BP_LoadingTo = 0
							LoadingUI:Init();
							-- 强行返回大厅
							Client.ReturnToLobby(GameFrontendHUD);
							
							-- 上报战斗服务器连接异常
							Client.TApmDisconnectReport(GameFrontendHUD, 11);
						end
					end);
			end		
		end
	end
	
	-- 战斗中大厅连接断开  间隔时间尝试重连
	if NetUtil.checkConnectingInFighting then
		local interval = 0;
		if NetUtil.checkConnectingInFightingTimes == 0 or NetUtil.checkConnectingInFightingTimes == 1 then
			interval = 5;
		elseif NetUtil.checkConnectingInFightingTimes == 2 then
			interval = 10;
		elseif NetUtil.checkConnectingInFightingTimes == 3 then
			interval = 15;
		else
			interval = NetUtil.checkConnectingInFightingRandomInterval;
		end
		if os.time() - NetUtil.waitingReEnterGameStartTime > interval then
			-- 静默重连一次,直到连上为止
			local status = string.lower(LuaClassObj.GetGameStatus(bp_lobby));
			log("ClientEntry ----- tryConnect lobby in fighting!!! curTime:"..os.time()..", startTime:"..NetUtil.waitingReEnterGameStartTime..", curStatus:"..status..", interval:"..interval);
			if not Client.IsConnected(NetInterface) and status == "fighting" then
				NetUtil.checkConnectingInFightingTimes = NetUtil.checkConnectingInFightingTimes + 1;
				NetUtil.tryConnect();
				NetUtil.checkConnectingInFightingRandomInterval = math.random(30, 40);
			else
				log("ClientEntry -----  stop checkConnectingInFighting");
				NetUtil.checkConnectingInFighting = false;
				NetUtil.waitingReEnterGameStartTime = 0;
				NetUtil.checkConnectingInFightingTimes = 0;
			end
			
			-- 更新时间
			NetUtil.waitingReEnterGameStartTime = os.time();
		end
	end

	--游戏结束后监控大厅重连情况，如果结算在6s之内没有收到的话，就会提示回到大厅
	UpdateResultMonitor();
end

function NetUtil.StopCheckLoginOtherLobbyServer()
	log("ClientEntry -----  StopCheckLoginOtherLobbyServer");
	if NetUtil.checkLoginOtherLobbyServer then
		-- 关闭菊花
		ConnectionWaitingUI:Hide();
	end
	
	NetUtil.checkLoginOtherLobbyServer = false;
end

-- 开启login回包检查
function NetUtil.StartCheckLoginRsp()

	-- 开启重试逻辑
	log("ClientEntry ----- NetUtil.StartCheckLoginRsp......");
	NetUtil.checkLoginRsp = true;
	NetUtil.sendLoginTime = os.time();
end
-- 关闭login回包检查
function NetUtil.StopCheckLoginRsp()

	log("ClientEntry ----- NetUtil.StopCheckLoginRsp!!!!!");
	NetUtil.checkLoginRsp = false;
	NetUtil.sendLoginTime = 0;
	NetUtil.checkLoginRetryTime = 0;

	if NetUtil.checkBattleLoginRetryTime > 0 then 
		local realRetryTime = 1;
		if NetUtil.checkBattleLoginRetryTime > 2 then
			realRetryTime = 2;
		elseif NetUtil.checkBattleLoginRetryTime > 5 then
			realRetryTime = 3;
		end
		local param = 
		{
			realRetryTime,
		};
		NetUtil.GEMReportEvent("ReonnectAfterLoginFail", param);
	end
	
	NetUtil.checkBattleLoginRetryTime = 0;
end
-- 开启战斗断线重连ds是否存在检查
function NetUtil.StartCheckDSActive()

	local curStatus = string.lower(LuaClassObj.GetGameStatus(bp_lobby));
	log("ClientEntry -----  StartCheckDSActive isWaittingEnterBattle: "..tostring(LobbySystem.isWaittingEnterBattle)..", curStatus: "..curStatus);
	-- 如果处于等待进入战斗的loading中			
	if (LobbySystem.isWaittingEnterBattle or curStatus == "fighting") and NetUtil.checkWaitingReEnterGameNotify == false then
		-- 开启超时检查，在loading中断开时，如果ds正在启动中（3s-4s），这时候重连回来大厅是不知道要重回战斗中的
		-- 需要客户端自行增加超时机制 强回大厅
		NetUtil.checkWaitingReEnterGameNotify = true;
		NetUtil.waitingReEnterGameStartTime = os.time();
		log("ClientEntry -----  waitingReEnterGameStartTime:"..NetUtil.waitingReEnterGameStartTime);
	end
end
-- 关闭战斗断线重连ds是否存在检查
function NetUtil.StopCheckDSActive()
	log("ClientEntry -----  StopCheckDSActive");
	NetUtil.checkWaitingReEnterGameNotify = false;
	NetUtil.waitingReEnterGameStartTime = 0;
end

-- 开启匹配成功后进入战斗的超时检查
function NetUtil.StartCheckEnterBattle()
	log("ClientEntry -----  StartCheckEnterBattle isWaittingEnterBattle: "..tostring(LobbySystem.isWaittingEnterBattle));
	-- 如果处于等待进入战斗的loading中			
	if LobbySystem.isWaittingEnterBattle then
		-- 需要客户端自行增加超时机制 强回大厅
		NetUtil.checkEnterBattle = true;
		NetUtil.waitingEnterBattleStartTime = os.time();
		log("ClientEntry -----  waitingEnterBattleStartTime:"..NetUtil.waitingEnterBattleStartTime);
	end
end
-- 关闭匹配成功后进入战斗的超时检查
function NetUtil.StopCheckEnterBattle()
	log("ClientEntry -----  StopCheckEnterBattle");
	NetUtil.checkEnterBattle = false;
	NetUtil.waitingEnterBattleStartTime = 0;
end

function NetUtil.OnTick(curTime, deltaTime)	
	if LoginSystem.hasKickOut then
		-- 被踢出游戏后不进行心跳
		return;
	end

	if NetUtil.gameTick then		
		if NetUtil.c2sTime > 0 and curTime - NetUtil.c2sTime > 7 then
			-- 请求包超过7s没有返回时，发起重连
            if #NetUtil.s2cNeedWaiting then
                log("ClientEntry ----- " .. NetUtil.s2cNeedWaiting[1].sendPkg .. " response timeout!!! curTime:" .. curTime .. ", c2sTime:" .. NetUtil.c2sTime, true);
            else
                log("ClientEntry ----- noname response timeout!!! curTime:" .. curTime .. ", c2sTime:" .. NetUtil.c2sTime, true);
            end
			--log_tree("NetUtil.s2cNeedWaiting", NetUtil.s2cNeedWaiting);
			-- 检查第一个存入的请求属性
			for i,v in ipairs(NetUtil.s2cNeedWaiting) do
				if v.needTryConnect then
					-- 需要重连
					NetUtil.tryConnect();
				else
					-- 不需要重连 并给出提示
					--DataMgr.ShowNoticeByString("服务器没有响应，请稍后再试");
					DataMgr.ShowNoticeByString(Client.GetTableData("LocalizeRes",301112).TextValue);
					-- 清空等待队列
					NetUtil.c2sTime = 0; 
					NetUtil.s2cNeedWaiting = {};
					-- 关闭菊花
					ConnectionWaitingUI:Hide();
				end
				
				break;
			end
			
			
		elseif curTime - NetUtil.SendTime >= 5 then		
			-- 每5s同步一次心跳
			NetUtil.SendTime = curTime;		
			NetUtil.LobbyDelaySendTime = os.clock()
			--local curStatus = LuaClassObj.GetGameStatus(bp_lobby);
			--log("NetUtil.OnTick "..curStatus);
			
			--if curTime - NetUtil.RecvTime > 30 then
				-- 心跳回包时间间隔超过10s时，发起重连
			--	log("ClientEntry ----- heart_beat response timeout:" .. curTime);
            --    LoginSystem.isInLobby = false;
			--	NetUtil.tryConnect();


			--else
				--log("ClientEntry ----- heart_beat req:" .. curTime);
				NetHeartBeatHandler.send_heart_beat(curTime)
			--end
            if LoginSystem.isInLobby then
                --登录成功了才每5s发一次Tss
                NetUtil.SendTss()
            end
		end		
	elseif NetUtil.connectionTick then
		--if curTime - NetUtil.SendTime > NetUtil.ConnectLuaTimeOutSeconds then		
		--	-- 连接超时20s后，弹出面板提示
		--	log("ClientEntry ----- heart_beat connectionTick timeout:" .. curTime..", SendTime:"..NetUtil.SendTime);
		--	NetUtil.showConnectionMsgTimes = NetUtil.showConnectionMsgTimes + 1;
		--	local errMsg = FuncUtil:GetGCloudErrorMsg(GCLOULD_ErrorNetworkException);
		--	NetUtil.ShowConnectionMsgBox(NetUtil.showConnectionMsgTimes, errMsg);
		--end
	end	
end

HeartBeatServerTime = 0;

-- 获取当前服务器时间
function NetUtil.GetCurServerTime()
    if HeartBeatServerTime <= 0 then
        return os.time()
    end
	return HeartBeatServerTime + os.time() - NetUtil.RecvTime;
end

-- 不停机更新通知
function NetUtil.OnChangeLobbyServerNotify()
	log("ClientEntry ----- please_relogin ~~~~~~~")
	NetUtil.checkLoginOtherLobbyServer = true;
	NetUtil.Disconnect();
	NetUtil.tryConnect();
end

-- 心跳响应
function NetUtil.OnHeartBeatRsp(key, now)
	--log("ClientEntry ----- heart_beat rsp upTime:"..key..", svrTime:"..now);	
    HeartBeatServerTime = now;
    NetUtil.RecvTime = os.time();    
    FuncUtil.SetServerTimeInSec(now);
    NetUtil.LobbyDelayRecvTime = os.clock()
    BP_LobbyNetworkDelay = math.floor((NetUtil.LobbyDelayRecvTime - NetUtil.LobbyDelaySendTime) * 1000);

	--log("heart_beat rsp upTime:"..NetUtil.LobbyDelaySendTime..", svrTime:"..NetUtil.LobbyDelayRecvTime..", networkDelay:"..BP_LobbyNetworkDelay);	
    -- 大厅网络状态标志
    if BP_LobbyNetworkDelay <= 5000 then
        BP_LobbyNetworkStatus = true
        LobbyUI:UpdateNetworkDelay()
    end
end

-- 战斗中断线重连通知
function NetUtil.OnReEnterGameNotify(ip, port, key, packet_key, game_id, res, team_info, gvoice_url, is_watch, start_to_plane, forced_exit_game_times, ad_conf)
	log("ClientEntry -----  on_re_enter_game_notify ip:"..ip..", port:"..port..", key:"..key..", game_id:"..game_id..", res:"..res);	
	--log_tree("team info on_re_enter_game_notify", team_info);
	log_tree("[LHM]NetUtil.OnReEnterGameNotify ad_conf", ad_conf);
	ResetResultMonitor();
	NetUtil.StopCheckDSActive();
	
	local curStatus = string.lower(LuaClassObj.GetGameStatus(bp_lobby));
	
	-- ds服务器当前状态
	local dsState = Client.GetUnrealNetworkStatus(GameFrontendHUD);
	-- dsState    
	log("ClientEntry -----  CurDSSeverState: "..dsState..", gameStatus: "..curStatus);
	
	local strTile = DataMgr.GetMsgByID(102012);
	local strMsg = "";	
	
	if res ~= "ok" then
		--strMsg = "您已经被淘汰，无法重回战斗";
		strMsg = Client.GetTableData("LocalizeRes",301113).TextValue;
		if res == "version_mismatch" then
			--strMsg = "版本不匹配，无法重回战斗";
			strMsg = Client.GetTableData("LocalizeRes",301114).TextValue;
		elseif res == "device_not_allow" then
			-- 您不能使用模拟器进入手机比赛，您已强制退出游戏
			strMsg = Client.GetTableData("LocalizeRes",301120).TextValue;
		elseif res == "watch_game_over" then
			strMsg = Client.GetTableData("LocalizeRes",501117).TextValue;
		elseif res == "watch_version_mismatch" then
			strMsg = Client.GetTableData("LocalizeRes",501128).TextValue;
		end

		local bUIAutoTest = Client.IsUIAutoTest();
		if bUIAutoTest then
			return
		end
		
		CommonMessageBoxUI:ShowPanel(1, strTile, strMsg, 
		function()
			curStatus = string.lower(LuaClassObj.GetGameStatus(bp_lobby));
			if curStatus == "fighting" then
				--如果在战斗中  返回大厅
                BP_LoadingTo = 0
				LoadingUI:Init();
				Client.ReturnToLobby(GameFrontendHUD);
							
				-- 上报战斗服务器连接异常
				Client.TApmDisconnectReport(GameFrontendHUD, 12);
			elseif LobbySystem.isWaittingEnterBattle then
				-- 重置匹配状态
				LobbySystem.SetWaitingBattleFlag(false);
				-- 关闭loading
				LoadingUI.RefreshLoadPercent(1);
				Client.ReturnToLobby(GameFrontendHUD);
			end
		end,
		function()
			-- 观战中，取消发送主动退出
			if is_watch then
				LogicLobbyWatching.leave_battle_watch()
			end
		end);			
		return;
	end
	
	if gvoice_url ~= nil then
		log("room_start_game_notify" .. gvoice_url);
		TeamUpSystem.SelectRegionVoiceUrl = gvoice_url
		BP_SelectRegionVoiceUrl = gvoice_url
		LuaClassObj.HandleUIMessage(bp_teamup, "UpdateVoiceUrl");
	end
	
	-- game_id 供游戏结算逻辑使用
	g_game_id = game_id;		
	
	if dsState == "Connecting" then
		-- ds在建立连接成功后会拉玩家进入战场 这时不需要发起enterbattle流程		
		log("ClientEntry -----  CurDSSeverState is Connecting  not need enter battle!! ");
		return;
	end
	
	if curStatus == "fighting" then
		-- 如果当前ds处于Online状态则不做任何处理，否则发起EnterBattle流程
		if dsState == "Online" or dsState == "RecoverableLost" then
			-- do nothing
		else
			-- 如果在战斗中则静默重进战斗
			log("ClientEntry -----  NetUtil.EnterBattle 2 dsState:"..dsState..", ip:"..ip..", port:"..port..", key:"..key);
			NetUtil.EnterBattle(ip, port, key, DataMgr.roleData.nickName, packet_key, g_game_id, false, ad_conf);
			LobbySystem.ResetMatchInfo();

			GlobalChatVoice.JoinGameVoiceRoom(team_info);
			Client.JoinLbsVoiceRoom(GameFrontendHUD, game_id, DataMgr.roleData.openID);
		end
		return;
	end	
	
    -- 大厅网络状态标志
    BP_LobbyNetworkStatus = true
    LobbyUI:UpdateNetworkDelay()
                
	local function clickOkCallback()
		-- 进入游戏
		log("ClientEntry -----  NetUtil.EnterBattle 1 ip:"..ip..", port:"..port..", key:"..key);
		--重连之后显示loading
        BP_LoadingTo = 1
		LoadingUI:Init();
		BP_LoadingTo = 0
        
		NetUtil.EnterBattle(ip, port, key, DataMgr.roleData.nickName, packet_key, g_game_id, false, ad_conf);
		LobbySystem.ResetMatchInfo();

		GlobalChatVoice.JoinGameVoiceRoom(team_info);
		Client.JoinLbsVoiceRoom(GameFrontendHUD, game_id, DataMgr.roleData.openID);
	end
	
	local function clickCancelCallback()
		-- 返回大厅，进入强制退出逻辑
		log("ClientEntry -----  giveup_enter_game curStatus:"..curStatus..", isWaittingEnterBattle:"..tostring(LobbySystem.isWaittingEnterBattle));

		-- 显式主动退出观战，不依赖ReturnToLobby的逻辑
		if is_watch then
			log("watching OnReEnterGameNotify clickCancelCallback 2 is_watch:true")
			RoomSystem.leave_room_battle_watch()
			LogicLobbyWatching.leave_battle_watch()
		else
			log("watching OnReEnterGameNotify clickCancelCallback 2 is_watch: false or nil")
		end
		
		NetUtil.SendPkg("giveup_enter_game");
		curStatus = string.lower(LuaClassObj.GetGameStatus(bp_lobby));
		if curStatus == "fighting" then
			-- 如果当前不在大厅中 则loading 然后回大厅
            BP_LoadingTo = 0
			LoadingUI:Init();
			Client.ReturnToLobby(GameFrontendHUD);
							
			-- 上报战斗服务器连接异常
			Client.TApmDisconnectReport(GameFrontendHUD, 13);
		elseif LobbySystem.isWaittingEnterBattle then
			-- 如果在战斗等待页面 则直接返回大厅
			-- 重置匹配状态
			LobbySystem.SetWaitingBattleFlag(false);
			-- 关闭loading
			LoadingUI.RefreshLoadPercent(1);
			--Client.ReturnToLobby(GameFrontendHUD);
		end
	end
	
	--是否重新进入战斗？
	if is_watch then
		strMsg =DataMgr.GetMsgByID(501129);	
	else
		local escapeTipChangeNum = DataMgr.GetSystemConfig("EscapeTipChangeNum") or 0;		
		-- 更新强退次数，当强退次数为0时，forced_exit_game_times有可能是nil
		if forced_exit_game_times ~= nil and LobbySystem then
			LobbySystem.forcedExitGameTimes = tonumber(forced_exit_game_times);
			log("ClientEntry -----  on_re_enter_game_notify forced_exit_game_times:"..forced_exit_game_times)
		end
		
		if start_to_plane == nil then
			start_to_plane = 1;
		end
		
		if tonumber(start_to_plane) == 0 and LobbySystem and LobbySystem.forcedExitGameTimes > tonumber(escapeTipChangeNum) then
			-- 是否重新进入战斗？多次放弃战斗将会临时禁止经典模式多人匹配，扣除信誉分
			strMsg =DataMgr.GetMsgByID(103018);	
		else
			-- 是否重新进入战斗？
			strMsg =DataMgr.GetMsgByID(103016);	
		end
	end

	local bUIAutoTest = Client.IsUIAutoTest();
	if bUIAutoTest then
		clickCancelCallback();
	else
		CommonMessageBoxUI:ShowPanel(2, strTile, strMsg, clickOkCallback, clickCancelCallback);	
	end
end

-- 尝试重连大厅服务器
function NetUtil.ShowConnectionMsgBox(showPanelTimes, errorMsg)
	local curStatus = string.lower(LuaClassObj.GetGameStatus(bp_lobby));
	log("ClientEntry -----  NetUtil.ShowConnectionMsgBox: "..showPanelTimes..", curStatus:"..curStatus);
        
	if curStatus == "lobby" then
		--大厅网络状态标识
		BP_LobbyNetworkStatus = false;
		LobbyUI:UpdateNetworkDelay();
	end
	
	NetUtil.connectionTick = false;
	NetUtil.gameTick = false;

	local function clickOkCallback()
		-- 再次尝试重连
		NetUtil.tryConnect();
        
        LoginSystem.enableLoginButton();
	end
	
	local function clickCancelCallback()	
		-- 登出逻辑
		LoginSystem.backLogin();
	end
	
	ConnectionWaitingUI:Hide();
	
	local strTile =DataMgr.GetMsgByID(102012);

    --strMsg = 无法连接到服务器，请检查你的网络。
	local strMsg =DataMgr.GetMsgByID(103015);		
	if showPanelTimes == 2 then
		--strMsg = "连接服务器没有响应，请稍后再试";
		strMsg = Client.GetTableData("LocalizeRes", "301226").TextValue;
	elseif showPanelTimes == 3 then
		--strMsg = "连接服务器没有响应，请确认你的网络是否正常";
		strMsg = Client.GetTableData("LocalizeRes", "301227").TextValue;
	else
		--strMsg = "连接服务器没有响应，请返回登录重试";
		strMsg = Client.GetTableData("LocalizeRes", "301228").TextValue;
	end
	
    
	if showPanelTimes < 4 then
		-- 有确定取消
		CommonMessageBoxUI:ShowConnectionPanel(2, strTile, strMsg, clickOkCallback, clickCancelCallback);
	else
		-- 只有确定
		CommonMessageBoxUI:ShowConnectionPanel(1, strTile, strMsg, clickCancelCallback);
	end
end

-- 尝试建立连接
function NetUtil.tryConnect()	
	local curStatus = string.lower(LuaClassObj.GetGameStatus(bp_lobby));	
	local lobbyInfo = LoginSystem.loginLobbyInfo;
	log("jaysun [Login process] ClientEntry -----  NetUtil.tryConnect url = " .. lobbyInfo.Url..", curStatus:"..curStatus);
	-- 停止游戏心跳，开启连接心跳
	NetUtil.connectionTick = true;
	NetUtil.gameTick = false;
	
	-- 记录时间
	NetUtil.SendTime = os.time();
	
	local isConnected = Client.IsConnected(NetInterface);
	log("ClientEntry NetUtil.tryConnect Client.IsConnected is "..tostring(isConnected));
	
	if curStatus ~= "fighting" then
		-- 显示菊花
		ConnectionWaitingUI:Show();		
	end
	
	-- 发起连接
	NetUtil.ConnectToURL(LoginSystem.loginLobbyInfo.Url);
end

function NetUtil.OnNetworkEvent(eventID, eventParam)
	log("ClientEntry -----  OnNetworkEvent: eventID = " .. eventID.." eventParam = "..eventParam);
	local curStatus = string.lower(LuaClassObj.GetGameStatus(bp_login));
    ConnectionWaitingUI:Hide();
	if eventID == 1 then
		log("authorization initialized");
	elseif eventID == 2 then 
		log("authorization login notify");
		--回包来了提前结束MSDK计时器
		IMSDKSystem.StopIMSDKTimer();
		NetUtil.noRefreshLogout = false;	
		if eventParam ~= 0 then
			-- modify by rainpan 2018.4.24 快速登录隐藏了登录按钮，登录失败展示登录按钮
			LuaClassObj.HandleUIMessage(bp_authorization, "showButtons");
			--为了安全起见，除了成功，取消，网络异常外，其他itop错误，都logout下，并且不刷新UI
			if eventParam ~= 106 and eventParam ~= 611 and eventParam ~= 701 and eventParam ~= 2 then
				NetUtil.LogoutNoRefresh();
			end
		end

		if eventParam == 0 then
			log("login ok");
            --清理登录尝试次数
			LuaClassObj.HandleUIMessage(bp_authorization, "clearLoginCount");
            local function UpdateEndCallBack()
                log("UpdateEndCallBack")
                if globalConfig.IsDirectConnect() == false then
                    log("hideAuthorizationUI")
                    
                    local channel = Client.GetLoginChannel(NetInterface);
                    log("authorization login ok, channel = " .. channel);

                    -- 需求又变了，又不用打断了，先保留吧，没准以后又要了
                    -- 如果Guest登录，截断登录流程
                    --if (channel == 5) then
                    --	LuaClassObj.HandleUIMessage(bp_authorization, "ShowGuestBindNotice");
                    	
                    --else -- 其他登录，进入下一步
                	LuaClassObj.HandleUIMessage(bp_login, "UIShow");
                    LuaClassObj.HandleUIMessage(bp_authorization, "hideAuthorizationUI");
					
                    if channel == BP_ENUM_PLAYFORM_WX and curStatus == "login" then
						DataMgr.RemoveAllNotice();
	                    DataMgr.ShowNoticeByID("101709");	--登陆授权成功
	                end
                    --end
                else
                    log("Connect to Gate Directly")
                    EventConnectToGate();
                end
				--刷新accesstoken
				if Client.IsConnected(NetInterface) and Client.GetLoginChannel(NetInterface) == BP_ENUM_PLAYFORM_WX then
					local accessToken = Client.GetAccessToken(NetInterface);
					NetUtil.SendPkg("refresh_wx_atk", accessToken);
				end
            end
            ---登录成功,开始尝试灰度更新
            ---游戏一次启动仅尝试一次
            if not VersionUpdate.AlreadyGrayUpdate then
                log("will gray update")
                VersionUpdate.StartGrayUpdate(UpdateEndCallBack)
            else
                log("no gray update")
                --无需灰度更新
                UpdateEndCallBack()
			end
			
			NetUtil.needInitMidasWhenLogin = true;
        elseif eventParam == 3 then
        	log("auth fail need retry");

			DataMgr.ShowNoticeByID("101713");	--授权失败，请您重新授权！
        elseif eventParam == 106 then
        	log("auth fail for user cancel");
        	DataMgr.ShowNoticeByID("101711");
        	--local channel = Client.GetLoginChannel(NetInterface);
        	--log("channel = " .. channel);
        	--[[
        	if channel == BP_ENUM_PLAYFORM_WX then
        		log("channel == BP_ENUM_PLAYFORM_WX");
                DataMgr.ShowNoticeByID("101711");	--您取消了授权
            elseif channel == BP_ENUM_PLAYFORM_QQ then
            	log("channel == BP_ENUM_PLAYFORM_QQ");
            	DataMgr.ShowNoticeByID("101712");	--您取消了QQ授权
            end
			]]
		--GC登录：设置里GC没登录，itop一直返回错误码2（取消鉴权）
		elseif eventParam == 701 then
			if curStatus == "login" then
				local title = DataMgr.GetMsgByID(101001);
				local notice = DataMgr.GetMsgByID(4188);
				CommonMessageBoxUI:ShowPanel(1, title, notice);
			end
		-- modify by rainpan 2018.4.21 自动登录QuickLogin 异常处理：
		-- 1001:快速登陆时无本地缓存数据
		-- 1002:快速登陆时本地数据已经过期失效
		elseif eventParam == 1001 or eventParam == 1002 then
			log("client_entry NetUtil.OnNetworkEvent QuickLogin Fail eventParam:" .. tostring(eventParam));
		elseif eventParam >= 9999 and eventParam <= 100000 then
			--为了将thirdRetCode跟imsdkRetCode合并，9999-100000这个区间，用来表示thirdRetCode
			--记录登录尝试次数
			LuaClassObj.HandleUIMessage(bp_authorization, "addLoginCount");
			local title = DataMgr.GetMsgByID(101001);
			local notice = NetUtil.GetSDKErrorNotice(eventParam);
			if curStatus == "login" then
				CommonMessageBoxUI:ShowPanel(1, title, notice);
			end
		else
			log("login failed:"..eventParam);
			--如果不是自动鉴权失败或取消鉴权需弹出提示
            if eventParam ~= -1 and eventParam ~= 6 and eventParam ~= 7 and eventParam ~= 106 and eventParam ~= 107 and eventParam ~= 109 and eventParam ~= 200 then
                --GC超时后，会在切后台回来回调一次，是异常，跳过提示
				if curStatus ~= "login" then
					return;
				end
				--记录登录尝试次数
				LuaClassObj.HandleUIMessage(bp_authorization, "addLoginCount");
				local title = DataMgr.GetMsgByID(101001);
				local notice = DataMgr.GetMsgByID(101100 + eventParam)
				CommonMessageBoxUI:ShowPanel(1, title, notice);
                return;
            end

            --记录登录尝试次数
			LuaClassObj.HandleUIMessage(bp_authorization, "addLoginCount");
			LuaClassObj.HandleUIMessage(bp_login, "UIHide");
			LuaClassObj.HandleUIMessageNoFetch(bp_authorization, "showAuthorizationUI");
            if eventParam == 7 and Client.GetDevicePlatformName() == "Windows" then
        		DataMgr.ShowNoticeByID("101710");
            end
		end
	elseif eventID == 3 then
		if NetUtil.noRefreshLogout ~= true then
			if eventParam == 0 then
				log("logout change account");
	            LoginSystem.backLogin(1);
			else
				log("logout failed");
			end
		end	
		NetUtil.noRefreshLogout = false;	
	elseif eventID == 4 then
		--回包来了提前结束MSDK计时器
		IMSDKSystem.StopIMSDKTimer()
		
		if eventParam == 0 then
			log("shared success");
			ShareMgr:onShareResult(1, "");
		else
			log("shared failed");
			ShareMgr:onShareResult(0, "");
		end
	elseif eventID == 255 then
		--国际化绑定事件
		log("received bind intl event,eventid : "..eventParam);
		--回包来了提前结束MSDK计时器
		IMSDKSystem.StopIMSDKTimer();
		
		EventSystem:postEvent(EVENTTYPE_BIND_INTL,EVENTID_INTL_BIND_NOTIFY,eventParam);
	elseif eventID == 254 then
		--连接服务器成功后刷新的绑定信息
		--回包来了提前结束MSDK计时器
		IMSDKSystem.StopIMSDKTimer();
		
		local bind_fb=0;
		local bind_gc=0;
		local bind_gp=0;
		if eventParam == 1 or eventParam == 3 or eventParam == 5 or eventParam == 7 then
			bind_fb=1;
		end
		if eventParam == 2 or eventParam == 3 or eventParam == 6 or eventParam == 7 then
			bind_gc=1;
		end
		if eventParam == 4 or eventParam == 5 or eventParam == 6 or eventParam == 7 then
			bind_gp=1;
		end

		log("received bind info,eventid : "..eventParam..",bind_fb : "..bind_fb..",bind_gc : "..bind_gc..",bind_gp : "..bind_gp);
		NetUtil.SendPkg("report_player_bind_info", bind_fb,bind_gc,bind_gp);
		EventSystem:postEvent(EVENTTYPE_BIND_INTL,EVENTID_INTL_BIND_NOTIFY,1);--notify refreshed bind info
	end
end

function NetUtil.GetSDKErrorNotice(eventParam)
	local notice = DataMgr.GetMsgByID(101205);
	--GP登录底层报错情况比较复杂，对关键错误码，给出友好提示  --modify byron
	if eventParam == 11016 then
		notice = DataMgr.GetMsgByID(4178);--google play services unavailable
	elseif eventParam == 11500 then
		notice = DataMgr.GetMsgByID(4179);--no external storage is mounted
	elseif eventParam == 11005 then
		notice = DataMgr.GetMsgByID(4180);--invalid account name specified
	elseif eventParam == 11020 then
		notice = DataMgr.GetMsgByID(4181);--profile is restricted
	elseif eventParam == 11003 then
		notice = DataMgr.GetMsgByID(4182);--version of google play services unavailable
	elseif eventParam == 11001 then
		notice = DataMgr.GetMsgByID(4183);--google play services is missing
	elseif eventParam == 11002 then
		notice = DataMgr.GetMsgByID(4184);--version of google play services is out of date
	elseif eventParam == 20002 then
		notice = DataMgr.GetMsgByID(4322);--network is flaky,or user's account has been disabled, or consent cound not be obtained
	end	
	return notice;
end


-- DS服务器连接异常通知
function NetUtil.OnDSServerConnectionErrorNotify(gameID, reason)
	log("ClientEntry -----  OnDSServerConnectionErrorNotify -------- gameID:"..gameID..", reason:"..reason..", BattleResult:"..tostring(BattleResult.IgnoreDSError));
	
	if BattleResult.IgnoreDSError then
		log("ClientEntry -----  BattleResult.IgnoreDSError return！！！！");	
		return;
	end
	
	local curStatus = string.lower(LuaClassObj.GetGameStatus(bp_lobby));
	if curStatus ~= "fighting" then
		log("ClientEntry -----  not in fighting dont show msgbox!!!"..curStatus);
		return;
	end	
	
	local strTile =DataMgr.GetMsgByID(102012);
	--local strMsg = "战斗服务器连接已断开！";
	local strMsg = Client.GetTableData("LocalizeRes", "301229").TextValue;
	if reason == "timeout" then
		--strMsg = "战斗服务器连接超时，请返回大厅！";
		strMsg = Client.GetTableData("LocalizeRes", "301230").TextValue;
	elseif reason == "active-timeout" then
		--strMsg = "战斗服务器响应超时，请返回大厅！";
		strMsg = Client.GetTableData("LocalizeRes", "301231").TextValue;
	end
	
	CommonMessageBoxUI:ShowConnectionPanel(1, strTile, strMsg, 
		function()
			--返回大厅
            BP_LoadingTo = 0
			LoadingUI:Init();
			Client.ReturnToLobby(GameFrontendHUD);
			LoginSystem.reqLoginLobby(true);
										
			-- 上报战斗服务器连接异常
			Client.TApmDisconnectReport(GameFrontendHUD, 14);
		end);
end

function NetUtil.LogOut()
    log("ClientEntry ----- NetUtil.LogOut()");
	NetUtil.SendPkg("logout");
end

function NetUtil.OnEcho(msg)	
	log(string.format("echo :%s", msg or "nil"));
end

function NetUtil.sync_time(serverTime)	
	log(string.format("sync_time :%s", os.date("%Y-%m-%d %H:%M:%S", serverTime)));
	FuncUtil.SetServerTimeInSec(serverTime);
end

function NetUtil.LogoutNoRefresh()
	--FB GP GC Tw 等SDK报错 先logout一下,不刷新UI
	NetUtil.noRefreshLogout = true;
	Client.Logout(NetInterface);
end


--处理特殊设备闪断网络
function NetUtil.ProcOnDisconnected()
	NetUtil.tNetDisconnected = os.time()
end
function NetUtil.ProcOnConnecting()
	NetUtil.tNetConnecting = os.time()
end
function NetUtil.ProcOnConnected()
	NetUtil.tNetConnected = os.time()
end
function NetUtil.CheckSpecialDeviceNetFlash()
	if NetUtil.tNetDisconnected > 0 and  NetUtil.tNetConnecting > NetUtil.tNetDisconnected and NetUtil.tNetConnected > NetUtil.tNetConnecting then
		if NetUtil.tNetConnecting - NetUtil.tNetDisconnected <= 1 and NetUtil.tNetConnected - NetUtil.tNetDisconnected <= 1 then
			--屏蔽检测
			--return true
		end
	end
	return false
end

---------------------------------------------------------------------------------------------------------
------------------------------------ 以下是ds服务器异常消息通知处理 -------------------------------------
---------------------------------------------------------------------------------------------------------

UnrealNet.NetworkStatus =
{
	Offline = "Offline",
	Connecting = "Connecting",
	Online = "Online",
	Lost = "Lost",
	RecoverableLost = "RecoverableLost"
}

UnrealNet.NetworkEvent = 
{
	-- OnRemoteHostResolved of IpConnection broadcasted
	RemoteHostResolved = "RemoteHostResolved",

	-- OnActorChannel of PlayerController called
	NetworkEstablished = "NetworkEstablished",

	-- RecentlyReceived of NetConnection broadcasted
	NetworkRecovered= "NetworkRecovered"
};

UnrealNet.NetworkException = 
{
	-- NMT_Failure received, typically player validation failed, or reconnection failed, or replication or RPC failed
	FailureReceived = "FailureReceived",

	-- connection closed, typically connection closed locally or received a close bunch from DS
	ConnectionLost = "ConnectionLost",

	-- connection timeout detected locally, triggered by NetConnection
	ConnectionTimeout = "ConnectionTimeout",

	-- connection timeout detected locally, triggered by UAENetConnection
	ConnectionLongTimeNoReceived = "ConnectionLongTimeNoReceived",

	-- timeout while connecting to DS, typically send handshake failed, or DS is down, triggered by GameFrontendHUD
	ConnectingTimeout = "ConnectingTimeout",

	-- typically player validation failed in PreLogin
	PendingConnectionFailure = "PendingConnectionFailure",

	-- a critical socket error detected locally, typically socket resource released by operating system and will never be available again
	CriticalSocketError = "CriticalSocketError",

	-- actor channel process bunch error, typically a property or RPC mismatch
	ActorChannelError = "ActorChannelError"
};

UnrealNet.FailureReceivedReason =
{
	CharacterDead = "CharacterDead",
	TeammatesAllDead = "TeammatesAllDead",
	GameOver = "GameOver",
	TrainingOver = "TrainingOver",
	CheatDetected = "CheatDetected",
	WatchedPlayerGone = "WatchedPlayerGone"
}

-- ds状态变更通知
function UnrealNet.HandleNetworkEvent(EventType, EventMessage, ...)

	EventMessage = EventMessage or "";

	-- send to lobby for statistics - burgesswang
	NetUtil.SendPkg("report_unrealnet_event", g_game_id, EventType, EventMessage);

	-- 'RemoteHostResolved' is only for reporting and statistics - burgesswang
	if EventType == UnrealNet.NetworkEvent.RemoteHostResolved then
		return;
	end

	local curStatus = string.lower(LuaClassObj.GetGameStatus(bp_lobby));
	sandbox.Log(string.format("gavins NetworkEvent %s, curstatus %s", EventType, curStatus));
	
	-- DS服务器状态变更通知
	if EventType == "NetworkEstablished" or EventType == "NetworkRecovered" then
		-- 收到ds超时重连恢复消息
		-- 关闭模态菊花
		ConnectionWaitingUI:Hide();
		
		NetUtil.dsTimeOutRetryTimes = 0;
		
		-- 关闭重回战斗检查
		NetUtil.StopCheckDSActive();
		
		if curStatus == "fighting" then
			-- 关闭所有网络异常面板
			CommonMessageBoxUI:HideAllMessageBox();
		end
	end
end

function UnrealNet.HandleNetworkException(ExceptionType, ErrorMessage, bShouldWait, ...)

	-- send to lobby for statistics - burgesswang
	NetUtil.SendPkg("report_unrealnet_exception", g_game_id, ExceptionType, ErrorMessage);

	-- 'ActorChannelError' is only for reporting and statistics - burgesswang
	if ExceptionType == UnrealNet.NetworkException.ActorChannelError then
		return;
	end

	-- training end - burgesswang
	if ExceptionType == UnrealNet.NetworkException.FailureReceived and string.find(ErrorMessage, UnrealNet.FailureReceivedReason.TrainingOver) == 1 then
		BattleResultUI.ShowTrainingOverUI();
		return;
	end
		
	sandbox.LogError(string.format("gavin NetworkFailure %s %s", ExceptionType, ErrorMessage));
	log("ClientEntry -----  NetworkFailure "..ExceptionType..", "..ErrorMessage..", "..tostring(bShouldWait)..", dsTimeOutTimes:"..NetUtil.dsTimeOutRetryTimes, true);
	
	-- 获取ds版本号
	local dsVersion = Client.GetDSVersion(GameFrontendHUD);
	-- 获取当前游戏状态
	local curStatus = string.lower(LuaClassObj.GetGameStatus(bp_lobby));
	log("ClientEntry -----  CurStatus: "..curStatus..", DSVersion: "..dsVersion);
	if curStatus == "login" then
		-- 在登录阶段不弹出ds相关异常
		return;
	end
	
	-- 默认关一下loading页面
	LoadingUI.RefreshLoadPercent(1);	

	if ExceptionType == "FailureReceived" then
		if string.find(ErrorMessage, "CharacterDead") == 1 then
			--直接显示结算 不等击杀镜头
			BattleResultUI.SetIsDirectShow(true);
		end
	end
	
	if curStatus == "fighting" and bShouldWait == true and NetUtil.dsTimeOutRetryTimes < 3 and not BattleResult.IgnoreDSError then
		-- 超时计数由ds维护 这边只接收消息做表现
		-- 不需要判断ExceptionType
		NetUtil.dsTimeOutRetryTimes = NetUtil.dsTimeOutRetryTimes + 1;
		local prompt = Client.GetTableData("LocalizeRes", "101001").TextValue;
		local msg = Client.GetTableData("LocalizeRes", "301232").TextValue;
		--CommonMessageBoxUI:ShowConnectionPanel(2, "提示", "战斗服务器响应超时，是否尝试重连？", 
		CommonMessageBoxUI:ShowConnectionPanel(2, prompt, msg, 
		function()
			--开启菊花等待ds服务器响应
			curStatus = string.lower(LuaClassObj.GetGameStatus(bp_lobby));
			-- ds服务器当前状态
			local dsState = Client.GetUnrealNetworkStatus(GameFrontendHUD);
			log("ClientEntry -----  click ds timeout panel ok! curStatus:"..curStatus..", dsState:"..dsState);
			if curStatus == "fighting" and dsState ~= UnrealNet.NetworkStatus.Online then
				ConnectionWaitingUI:Show();
			end
		end,
		function()
			-- 返回大厅
			curStatus = string.lower(LuaClassObj.GetGameStatus(bp_lobby));
			log("ClientEntry -----  click ds timeout panel cancel: "..curStatus);
			if curStatus == "fighting" then
				-- 在战斗中返回大厅
                BP_LoadingTo = 0
				LoadingUI:Init();
				Client.ReturnToLobby(GameFrontendHUD);				
				LoginSystem.reqLoginLobby(true);
				
				-- 关闭菊花
				ConnectionWaitingUI:Hide();
				
				-- 上报战斗服务器连接异常
				Client.TApmDisconnectReport(GameFrontendHUD, 15);
			end
		end);
		
		return;
	end
	
	
	-- 以下逻辑都默认ds的错误是不可恢复的  需要回到大厅
	local strTile =DataMgr.GetMsgByID(102012);
	-- 网络波动异常，与服务器失去连接。请检查您的网络连接后再次尝试！
	local strMsg = DataMgr.GetMsgByID(103017);
	local needRelogin = false;
	
	if ExceptionType == "FailureReceived" or ExceptionType == UnrealNet.NetworkException.PendingConnectionFailure then
		if string.find(ErrorMessage, "CharacterDead") == 1 then
			--strMsg = "您上一局游戏已经结束";
			strMsg = Client.GetTableData("LocalizeRes",120004).TextValue;
		elseif string.find(ErrorMessage, "TeammatesAllDead") == 1 then
			--strMsg = "您的队伍已经被淘汰";
			strMsg = Client.GetTableData("LocalizeRes",120007).TextValue;
		elseif string.find(ErrorMessage, "GameOver") == 1 then
			--strMsg = "当前战斗已结束，无法进入";
			strMsg = Client.GetTableData("LocalizeRes",301117).TextValue;
		elseif string.find(ErrorMessage, UnrealNet.FailureReceivedReason.WatchedPlayerGone) == 1 then
			--strMsg = "观战的游戏已结束";
			strMsg = Client.GetTableData("LocalizeRes",501117).TextValue;
		end
	elseif ExceptionType == "ConnectionTimeout" then
		--strMsg = "战斗服务器连接超时，请重新开始游戏";
		strMsg = Client.GetTableData("LocalizeRes",301118).TextValue;
		needRelogin = true;
	elseif ExceptionType == "ConnectingTimeout" then
		--strMsg = "战斗服务器没有响应，请稍后再试";
		strMsg = Client.GetTableData("LocalizeRes",301233).TextValue;
		needRelogin = true;		
	else
		needRelogin = true;
	end
	
    log("ClientEntry ----- NetworkFailure, IgnoreDSError -- " .. tostring(BattleResult.IgnoreDSError) .. " needRelogin -- " .. tostring(needRelogin));
    if BattleResult.IgnoreDSError then
 --为了改这个bug，http://tapd.oa.com/10168201/bugtrace/bugs/view?bug_id=1110168201055963844 删掉额外判断---
		log("ClientEntry -----  DS BattleResult.IgnoreDSError return！！！！");
		return;
	end
    
	CommonMessageBoxUI:ShowPanel(1, strTile, strMsg, 
		function()
			--返回返回大厅
			curStatus = string.lower(LuaClassObj.GetGameStatus(bp_lobby));	
			log("ClientEntry ----- sun start ReturnToLobby needRelogin: "..tostring(needRelogin)..", curStatus:"..curStatus..", isWaittingEnterBattle"..tostring(LobbySystem.isWaittingEnterBattle));		
			if curStatus == "fighting" or curStatus == "pending" or LobbySystem.isWaittingEnterBattle then
				-- 在战斗中或者在进入战斗的loading中才处理
                BP_LoadingTo = 0;
				
				-- 关闭菊花
				ConnectionWaitingUI:Hide();
				
				LoadingUI:Init();
				Client.ReturnToLobby(GameFrontendHUD);
				
				if needRelogin then
					LoginSystem.reqLoginLobby(true);
				end
							
				-- 上报战斗服务器连接异常
				Client.TApmDisconnectReport(GameFrontendHUD, 16);
			end
		end);
		
	EventSystem:postEvent(EVENTTYPE_NETWORK, EVENTID_DS_SERVER_CONNECT_FAILED);
end


s2c["re_enter_game"] = NetUtil.OnReEnterGameNotify;
s2c["on_send_client_data"] = NetUtil.OnTssRsp;
s2c["game_unusual_end"] = NetUtil.OnDSServerConnectionErrorNotify;
s2c["echo"] = NetUtil.OnEcho;
s2c["sync_time"] = NetUtil.sync_time;
s2c["please_relogin"] = NetUtil.OnChangeLobbyServerNotify;

require "client.time_ticker"
require "game_frontend_hud"
require "ui.manager"
require "client.slua.entry"
require "client.launcher.Extern"
require "client.memory_tool.memory_util"
require "client.memory_tool.MemoryReferenceInfo"