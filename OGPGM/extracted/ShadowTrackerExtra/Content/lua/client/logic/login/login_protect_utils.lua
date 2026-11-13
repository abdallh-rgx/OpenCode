--samizheng登录保护类
LoginProtectUtils = LoginProtectUtils or
{
	tbLoginInfo = 
	{
		curLoginTimes = 0,
		preLoginTime = 0,
		preLoginSucTime = 0,
	},
	loginInfoFileName = "SaveGames/loginInfoFile.json",
}


--加载登录信息文件
function LoginProtectUtils.LoadLoginInfoFile()
	local str = Client.LoadFileToString(LoginProtectUtils.loginInfoFileName)
	if str == "" then
		return
	end
	LoginProtectUtils.tbLoginInfo = json.decode(str)
end

--保存登录信息文件
function LoginProtectUtils.SaveLoginInfoFile()
	local str = json.encode(LoginProtectUtils.tbLoginInfo)
	if str == "" then
		return
	end
	Client.SaveStringToFile(str, LoginProtectUtils.loginInfoFileName)
end

--获取登录次数CD
function LoginProtectUtils.GetLoginCd(times)
	if times <= 2 then
		return 0
	elseif times <= 5 then
		return 10
	else
		return 300
	end
end

--判断是否可以点击登录
function LoginProtectUtils.CheckCanLogin()
	LoginProtectUtils.LoadLoginInfoFile()
	
	local info = LoginProtectUtils.tbLoginInfo
	local bRet = true
	local bWrite = false
	local tNow = os.time()	
	
	if info.curLoginTimes <= 0 then
		--没有登录次数
		bRet = true
		bWrite = true
		info.curLoginTimes = 1
		info.preLoginTime = tNow
	else
		local cd = LoginProtectUtils.GetLoginCd(info.curLoginTimes)
		if info.preLoginTime == 0 then
			--没有登录时间
			bRet = true
			bWrite = true
			info.curLoginTimes = 1
			info.preLoginTime = tNow
		else
			if info.preLoginTime <= info.preLoginSucTime then
				--上次登录成功
				bRet = true
				bWrite = true
				info.curLoginTimes = 1
				info.preLoginTime = tNow
			else
				--上次没有成功
				local tDis = tNow - info.preLoginTime
				if tDis < cd then
					--cd倒计时
					bRet = false
					local tips = GlobalData.GetLocalizeStringWithNum(6804, 0, tostring(cd-tDis))
					PopUpNoticeUI.ShowNewNotice(tips)
				else
					--cd完了，下一次尝试
					bRet = true
					bWrite = true
					info.curLoginTimes = info.curLoginTimes + 1
					info.preLoginTime = tNow
				end
			end
		end
	end
	if bWrite then
		LoginProtectUtils.SaveLoginInfoFile()
	end
	return bRet
end

--记录登录失败时间
function LoginProtectUtils.RecordLoginFailTime()
	local tNow = os.time()
	local info = LoginProtectUtils.tbLoginInfo
	info.preLoginTime = tNow
	LoginProtectUtils.SaveLoginInfoFile()
end

--记录登录成功
function LoginProtectUtils.RecordLoginSucTime()
	local tNow = os.time()
	local info = LoginProtectUtils.tbLoginInfo
	info.curLoginTimes = 0
	info.preLoginSucTime = tNow
	LoginProtectUtils.SaveLoginInfoFile()
end


