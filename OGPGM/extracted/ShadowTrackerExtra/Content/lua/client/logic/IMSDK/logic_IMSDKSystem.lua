
--[[
 IMSDK逻辑
]]--

IMSDKSystem = IMSDKSystem or
{
	timer = {};
}

--启动 超时定时器 1快速登录 2登录 3绑定 4分享
function IMSDKSystem.StartIMSDKTimer(IMSDKOperType)
	log("StartIMSDKTimer IMSDKOperType：" .. tostring(IMSDKOperType));
	ConnectionWaitingUI:Show();
	--快速登录
	if IMSDKOperType == 1 then
		AuthorizationUI.QuickLoginWaiting();
		IMSDKSystem.timer = Timer.InsertTimer(16, IMSDKSystem.IMSDKLoginTimeOut, false, true);
	--登录
	elseif IMSDKOperType == 2 then
		IMSDKSystem.timer = Timer.InsertTimer(16, IMSDKSystem.IMSDKLoginTimeOut, false, true);		
	--绑定
	elseif IMSDKOperType == 3 then
		IMSDKSystem.timer = Timer.InsertTimer(16, IMSDKSystem.IMSDKBindTimeOut, false, true);
	--分享
	else
		--FB要上传图片，所以等待时间更久
		if BP_Share_Platform == BP_ENUM_PLAYFORM_QQ then
			IMSDKSystem.timer = Timer.InsertTimer(60, IMSDKSystem.IMSDKShareTimeOut, false, true);
		else
			IMSDKSystem.timer = Timer.InsertTimer(6, IMSDKSystem.IMSDKShareTimeOut, false, true);
		end
	end
end

--停止 超时定时器 1快速登录 2登录 3绑定 4分享
function IMSDKSystem.StopIMSDKTimer() 
	log("StopIMSDKTimer");
	ConnectionWaitingUI:Hide();
	if IMSDKSystem.timer ~= nil then
		log("StopIMSDKTimer RemoveTimer IMSDKSystem.timer");
		Timer.RemoveTimer(IMSDKSystem.timer);
	end	
end

--快速登录/登录 超时处理 
function IMSDKSystem.IMSDKLoginTimeOut()
	log("IMSDKLoginTimeOut");
	Client.ClearChannelID(NetInterface);
	LuaClassObj.HandleUIMessage(bp_authorization, "showButtons");
	--GC特殊提示：你的Game Center帐号未启用。请进入手机设置，登陆Game Center帐号
	local GCloudChannelID = Client.GetLoginChannel(NetInterface);
	if GCloudChannelID == 40 then
		DataMgr.ShowNoticeByID(4188);
	end
end

--绑定 超时处理 
function IMSDKSystem.IMSDKBindTimeOut()
	log("IMSDKBindTimeOut");
	ConnectionWaitingUI:Hide();
	--GC特殊提示：你的Game Center帐号未启用。请进入手机设置，登陆Game Center帐号
	if BP_BindChannel == 2 then
		DataMgr.ShowNoticeByID(4188);
	end
end

--分享 超时处理 
function IMSDKSystem.IMSDKShareTimeOut()
	log("IMSDKShareTimeOut");
	ConnectionWaitingUI:Hide();
end