--[[
  模拟器检测
]]--

EmulatorSystem =  EmulatorSystem or {
	timer = 0,
	timeLength = 180,--目前时间间隔为3分钟
	waitWhiteListForShowTip = false,
	emulatorCheckData = nil,
	white_simulator_list = nil,
}

EmulatorSystem.EmulatorTestMark = false;

--如果是手机局中被检测为模拟器，则被踢出对局
function EmulatorSystem.Tick(DeltaTime)	
	--登录后开始检测
	if (LoginSystem.isInitLogin == true) then

		EmulatorSystem.timer = EmulatorSystem.timer + DeltaTime;
		if (EmulatorSystem.timer >= EmulatorSystem.timeLength) then
			EmulatorSystem.timer = 0;
			local emulatorName = Client.GetEmulatorName();
			if EmulatorSystem.EmulatorTestMark then
			  emulatorName = "test";
			end
			local isEmulator = EmulatorSystem.IsEmulator(emulatorName);
			log("EmulatorSystem.Tick() isEmulator = " .. tostring(isEmulator));
			DataMgr.roleData.isEmulator = isEmulator;
			--如果检测是模拟器，通知服务器
			if (isEmulator == true) then
				EmulatorSystem.OnEmulatorStatusChange(isEmulator, emulatorName);
			else
				--如果检测是外设手柄或键鼠，通知服务器
				local deviceType = EmulatorSystem.CheckBLEDeviceType();
				if (deviceType ~= 0) then
					log("EmulatorSystem.CheckBLEDeviceType() deviceType = " .. tostring(deviceType));
					NetUtil.SendPkg("report_simulator_check", deviceType, emulatorName);
				end
			end
		end
	end
end

--测试用指令，设置为模拟器
function EmulatorSystem.BeEmulator()
	EmulatorSystem.OnEmulatorStatusChange(true,"test");
end

--如果检测是模拟器，通知服务器
function EmulatorSystem.OnEmulatorStatusChange(isEmulator, emulatorName)
	
	log("OnEmulatorStatusChange isEmulator = " .. tostring(isEmulator) .. " emulatorName = " .. tostring(emulatorName));

	if isEmulator == true then
		log("report_simulator_check simulatorValue = 1");
		NetUtil.SendPkg("report_simulator_check", 1, emulatorName);
	end
end

--服务器通知，如果是手机局中被检测为模拟器，则被踢出对局
function EmulatorSystem.notify_kick_out_game(reason)
	log("notify_kick_out_game reason = " .. tostring(reason));

	local title = Client.GetTableData("LocalizeRes", "101001").TextValue;	
	local text = "";	
	
	if ("simulator_not_allow_in_mobile" == reason) then
		text = Client.GetTableData("LocalizeRes", "101721").TextValue;
	end

	local curStatus = string.lower(LuaClassObj.GetGameStatus(bp_lobby));
	if curStatus == "fighting" then
		CommonMessageBoxUI:ShowPanel(1, title, text, EmulatorSystem.ReturnToLobby);
	end
end

--判断是否外设手柄或者外设键鼠
function EmulatorSystem.CheckBLEDeviceType()
	--此版本不做外设判断
	--[[
	local bleDeviceType = BLESystem.BLEDeviceType; --0是无外设，1是BLEType_Keyboard，2是BLEType_Joystick
	if (bleDeviceType == 1) then
		return 2;--2是外设键鼠
	elseif(bleDeviceType == 2) then
		return 3; --3是外设手柄
	elseif(bleDeviceType ~= 0) then
		return 2;
	end
	]]
	return 0;
end

--[[
--蓝牙手柄/键鼠连接状态变化
function EmulatorSystem.HandleBLEDeviceChange()
	local emulatorName = Client.GetEmulatorName();
	local isEmulator = EmulatorSystem.IsEmulator(emulatorName);
	LobbyUI.DoCheckBLETip(isEmulator);
	if (isEmulator == false) then
		
		local deviceType = EmulatorSystem.CheckBLEDeviceType();
		log("EmulatorSystem.HandleBLEDeviceChange simulatorValue = " .. tostring(deviceType));
		NetUtil.SendPkg("report_simulator_check", deviceType, emulatorName);
	end
end
]]--
function EmulatorSystem.get_emulators_cfg_req()
	log("get_emulators_cfg_req");
	NetUtil.SendPkg("get_emulators_cfg_req");
end

function EmulatorSystem.get_emulators_cfg_res(emulators_check_table, white_simulator_list)
	log("get_emulators_cfg_res");
	--log_tree("emulators_check_table", emulators_check_table);
	--log_tree("white_simulator_list", white_simulator_list);

	EmulatorSystem.white_simulator_list = white_simulator_list;
	EmulatorSystem.ConvertEmulatorCheckData(emulators_check_table);
	EmulatorSystem.CheckSpecialEmulator();
	if (EmulatorSystem.waitWhiteListForShowTip) then
		EmulatorSystem.waitWhiteListForShowTip = false;
        log("got white_simulator_list, waitWhiteListForShowTip is true");
		LobbyUI.CheckEmulatorTip();
	end
	--log_tree("EmulatorSystem.emulatorCheckData", EmulatorSystem.emulatorCheckData);
end

function EmulatorSystem.ConvertEmulatorCheckData(emulators_check_table)
	EmulatorSystem.emulatorCheckData = {};
	if (emulators_check_table ~= nil) then
		for k, v in pairs(emulators_check_table) do
			local emulator = {};
			emulator["name"] = tostring(k);
			emulator["paths"] = v;
			table.insert(EmulatorSystem.emulatorCheckData, emulator);
		end
	end
end

function EmulatorSystem.CheckSpecialEmulator()
	local emulatorName = Client.GetEmulatorName();
	local isEmulator = EmulatorSystem.IsEmulator(emulatorName);
	if isEmulator == false then
		local findEmulatorRet, findEmulatorName = emulator_scanner.find_emulator();
		if findEmulatorRet == true then
			isEmulator = true;
			emulatorName = tostring(findEmulatorName);
			log("emulator_scanner.find_emulator return true, and emulator name is " .. tostring(findEmulatorName));
		else
			log("emulator_scanner.find_emulator return false");
			--解决绕过腾讯助手模拟器检测的问题，增加systemhardware判断逻辑
			local isSpecialEmulator = EmulatorSystem.IsSpecialEmulator(tostring(DeviceOSInfo.InfoList.SystemHardware));
			log("isSpecialEmulator = " .. tostring(isSpecialEmulator));
			if (isSpecialEmulator == true) then
				isEmulator = true;
				emulatorName = tostring(DeviceOSInfo.InfoList.SystemHardware);
			end
		end
	end

	if (isEmulator == true) then
		log("EmulatorSystem.CheckSpecialEmulator report_simulator_check simulatorValue = 1");
		if (DataMgr ~= nil and DataMgr.roleData ~= nil) then
			DataMgr.roleData.isEmulator = true;
		end
		log("report_simulator_check 1");
		NetUtil.SendPkg("report_simulator_check", 1, emulatorName);
	end
end

function EmulatorSystem.GetEmulatorName()
	local emulatorName = Client.GetEmulatorName();
	local isEmulator = EmulatorSystem.IsEmulator(emulatorName);
	if isEmulator == true then
		return emulatorName;
	end

	local findEmulatorRet, findEmulatorName = emulator_scanner.find_emulator();
	if findEmulatorRet == true then
		isEmulator = true;
		return findEmulatorName;
	else
		--解决绕过腾讯助手模拟器检测的问题，增加systemhardware判断逻辑
		local isSpecialEmulator = EmulatorSystem.IsSpecialEmulator(tostring(DeviceOSInfo.InfoList.SystemHardware));
		log("isSpecialEmulator = " .. tostring(isSpecialEmulator));
		if (isSpecialEmulator == true) then
			isEmulator = true;
			return tostring(DeviceOSInfo.InfoList.SystemHardware);
		end
	end
	return "NoEmulator";
end

--解决绕过腾讯助手模拟器检测的问题，增加systemhardware判断逻辑
function EmulatorSystem.IsSpecialEmulator(myDevice)
	if (GlobalSpecialEmulatorList ~= nil) then
		for k, v in pairs(GlobalSpecialEmulatorList) do
			if (tostring(myDevice) == tostring(v)) then
				log("LoginSystem.IsSpecialEmulator() = true, myDevice = " .. tostring(myDevice));
				return true;
			end
		end
	else
		log("GlobalSpecialEmulatorList is nil");
	end
	return false;
end

--返回大厅
function EmulatorSystem.ReturnToLobby()
	log("EmulatorSystem.ReturnToLobby");
	LobbySystem.ReturnToLobby();
end

function EmulatorSystem.IsEmulator(emulatorName)
	return emulatorName ~= "NoEmulator";
end

--是否是腾讯模拟器
function EmulatorSystem.is_tencent_simulator(simulator_name)
	local isEmulator = EmulatorSystem.IsEmulator(simulator_name);
	if (isEmulator) then
		if (EmulatorSystem.white_simulator_list) then
			if not simulator_name then
				return false;
			end
			--local string = string;
			for key, _ in pairs(EmulatorSystem.white_simulator_list) do
				local pos = string.find(simulator_name, key, 1, true);
				--log("pos = " .. tostring(pos));
				if pos then
					return true;
				end
			end
			--log("white emulator not found");
			return false;
		else
			log("white_simulator_list is nil");
			return true;
		end
	else
		return false;
	end
end

s2c["notify_kick_out_game"] = EmulatorSystem.notify_kick_out_game; --如果是手机局中被检测为模拟器，则被踢出对局
s2c["get_emulators_cfg_res"] = EmulatorSystem.get_emulators_cfg_res; 