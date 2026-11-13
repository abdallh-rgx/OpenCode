GM_UI = GM_UI or 
{
    PathSave = "",
}

BP_gmMsg = "";
EchoMsg = "";
-- 注册面板
function bp_gm_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_gm,
        {   {Path="/Game/UMG/UI_BP/GM/GM_BP.GM_BP_C", Container="Default", ZOrder=500},
            {Path = "/Game/UMG/UI_BP/GM/BP_GM_Mini.BP_GM_Mini_C", Container = "Top", ZOrder = 500}
        },
		{"Lobby","Login","Fighting"},
		false,
		false,
		true
	);	
	
	BP_gmMsg = "";
    EchoMsg = "";
end

function GM_UI:ShowPanel()
	LuaClassObj.HandleDynamicCreation(bp_gm);
	LuaClassObj.HandleUIMessage(bp_gm, "UIShow");
end

function TestUrl(url)
    GlobalData:JumpUrl(url);
end

function GM_UI.Test()
    log("GM_UI.Test"..debug.traceback());
end

function GM_UI.ReloadModule(module)
    GM_UI.InitPackagePath()
    DoReloadLua(module)
end

function GM_UI.ReloadLua()
    GM_UI.InitPackagePath()

    for i,v in ipairs(reload_cfg.modules) do
        DoReloadLua(v);
    end
end

function DoReloadLua(moduleName)
    local reload = require("reload")
    reload.Reload({moduleName})
    log("reload module:"..moduleName);
end

function GM_UI.InitPackagePath()
    if GM_UI.PathSave == "" then
        GM_UI.PathSave = package.path;
    end

    -- 重新加载配置模块
    package.path = GM_UI.PathSave..";../../../../Survive/Source/Lua/client/config/?.lua";
    DoReloadLua("reload_cfg")

    -- 通过配置模块设置查找路径
    for i,v in ipairs(reload_cfg.dirs) do
        package.path = string.format("%s;%s", package.path, v);
    end

    package.path = package.path..";";
end


-- function EventGmSend_Push( ... )
--     -- body
--     log("SendGM:"..BP_gmMsg);
--     NetUtil.SendPkg("exec", BP_gmMsg);
-- end

function GM_UI.GetParams(targetS)
    local targetS = string.match( targetS, "%s*(.*)");
    if string.len(targetS) == 0 then
        return nil, nil;
    end

    local i, j = string.find(targetS, "(\"[^\"]+\")");
    if i ~= 1 then
        i, j = string.find(targetS, "[^ ]+");        
    end

    -- print( targetS )
    if i ~= 1 then
        sandbox.LogError("GM解析错误");
        return nil, nil;
    end

    return string.sub(targetS, i, j), string.sub(targetS, j+1);
end

function GM_UI.GetGMWordList(s)
    -- body
    local list = {};
    local result, deltaS = GM_UI.GetParams(s);
    while result ~= nil do
        table.insert( list, result );
        result, deltaS = GM_UI.GetParams(deltaS);
    end

    return list;
end

function GM_UI.TestPrint(s)
    log("GM_UI.TestPrint :"..package.cpath);
end

function GM_UI.CallString(s)
    log(string.format("call gm : %s", s))
    local func = load(s);
    local r, msg = pcall(func);
    if not r then
        sandbox.LogError(string.format("gm error :%s", msg));
    end
end

function EventGmSend_Push()
	-- local results = GM_UI:split(BP_gmMsg, " ");
	if BP_gmMsg == "recharge_pay" then
		RechargeUI.ShowUI();
		LuaClassObj.HandleUIMessage(bp_gm, "UIHide");
		return;
    elseif BP_gmMsg == "gm_delrole" then
        LobbyChatLogic.bAddCropsOfflineChatMsg = false;
    elseif BP_gmMsg == "gm_appraise" then 
		AppraiseUI.ShowUI();
		LuaClassObj.HandleUIMessage(bp_gm, "UIHide");
		return ;
    elseif BP_gmMsg == "gm_open_starterpack" then
        StarterPackSystem.GM_Command_OpenPurchase()
        return ;
    elseif BP_gmMsg == "gm_close_starterpack" then
        StarterPackSystem.GM_Command_ClosePurchase()
        return ;
	elseif BP_gmMsg == "DeviceLog" then 
		local str = "devind say: ";
		str = str.."\nDeviceName = "..tostring(DeviceOSInfo.InfoList.DeviceName);
		str = str.."\nDeviceWidth = "..tostring(DeviceOSInfo.InfoList.ScreenWidth);
		str = str.."\nDeviceHeight = "..tostring(DeviceOSInfo.InfoList.ScreenHight);
		CommonMessageBoxUI:ShowPanel(1, "提示", str);
		return ;
    elseif BP_gmMsg == "gm_reset_bubble" then
        LobbySystem.LobbyBubbleList = {}
        Client.DeleteDirectory(Client.ProjectSavedDir() .. "LobbyBubble");
        LobbySystem.ReqBubbleInfo()
        return ;
    elseif BP_gmMsg == "gm_set_emulator" then
        EmulatorSystem.OnEmulatorStatusChange(true, "test")
        EmulatorSystem.EmulatorTestMark = true;
        return;
    end
    local c = string.sub(BP_gmMsg, 1, 2);
    if string.lower(c) == "c " then
        local cmd = string.match(string.sub(BP_gmMsg, 2), "%s*(.*)");
        GM_UI.CallString(cmd);
        return;
    end

    if string.lower(c) == "s " then
        local cmd = string.match(string.sub(BP_gmMsg, 2), "%s*(.*)");
        NetUtil.SendPkg("exec", cmd);
        return;
    end
	
	local profile = string.sub(BP_gmMsg, 1, 7);
	if string.lower(profile) == "profile" then
		local uid = string.match(string.sub(BP_gmMsg, 8), "%s*(.*)");
        log("uid "..uid);
		RoleInfoSystem.Enter(uid);
		RoleInfoUI.Init();
        return;
    end
	
	local enterTraining = string.sub(BP_gmMsg, 1, 13);
	if enterTraining == "EnterTraining" then
		LuaClassObj.HandleUIMessage(bp_gm, "UIHide");
		log("GM on_match_req!!!");
		NetUtil.SendPkg("on_match_req", 301, 0, 0);
		return;
	end

    local results = GM_UI.GetGMWordList(BP_gmMsg);
	if #results == 0 then
		return;
	end
		
	local msg = results[1].."(";
	if #results > 1 then
		msg = msg..results[2];
	end
	if #results > 2 then
		msg = msg..","..results[3];
	end
	if #results > 3 then
		msg = msg..","..results[4];
	end
	if #results > 4 then
		msg = msg..","..results[5];
	end
    if #results > 5 then
        msg = msg..","..results[6];
    end
	if #results > 6 then
		msg = msg..","..results[7];
	end
	if #results > 7 then
		msg = msg..","..results[8];
	end
	if #results > 8 then
		msg = msg..","..results[9];
	end
	if #results > 9 then
		msg = msg..","..results[10];
	end	
	msg = msg..")";
	
	log("SendGM:"..msg);
	NetUtil.SendPkg("exec", msg);
end

function EventOpenPDDSystem()
    log("[HHF]EventOpenPDDSystem");
    PDD_System_UI.Show();
end

function EventOpenMallEditor()
    log("EventOpenMallEditor")
    MallEditorUI.Show()
end

function EventGmSendShowTeamUpUI()
	--打开UI
	--TeamUPFriendUI.CheckSwitch();
	--TeamUpUI.CheckSwitch();
    --ShareUI.ShowUI();
    --ArmoryUI:OpenArmoryMainUI();
    EmulatorSystem.OnEmulatorStatusChange(true);
    EmulatorSystem.EmulatorTestMark = true;
end

function EventGmShowChatEntrance()
	LobbyChatSystem.canOpenChatWnd = true;	
	LobbyChatSystem.Entry();
end

function EventGmOpenPromotor()
    -- PromotionMgr.SendGetPromotionInfo() 
    UIReflux:GetRefluxInfoAndOpenUI()
end

function EventWXUrlShare()
    log("EventWXUrlShare")
    ShareMgr:shareWechatUrlInfo(MEDIA_TAG_SHARE_CHIJI_HONGBAO,Client.GetTableData("LocalizeRes", "790014").TextValue,"www.qq.com","",ShareType.Friend);
end

function EventGmDumpLuaMemoryProfile()
    MemoryUtil:DumpLuaBaseMemory()
end

function EventGmDumpLuaMemoryRef()
    MemoryUtil:DumpLuaObjRefFile()
    -- MemoryUtil:DumpLuaObjRefFile("Bag_Lv3")
    -- MemoryUtil:DumpLuaObjRefFile(_G.BP_ARRAY_AvatarBPTable)
end

function EventGmChangeAvatarPose()
    LobbyUI:AvatarChangePose()
end

function GM_UI:split(str, d) --str是需要查分的对象 d是分界符  
    local lst = { }  
    local n = string.len(str)--长度  
    local start = 1  
    while start <= n do  
        local i = string.find(str, d, start) -- find 'next' 0  
        if i == nil then   
            table.insert(lst, string.sub(str, start, n))  
            break   
        end  
        table.insert(lst, string.sub(str, start, i-1))  
        if i == n then  
            table.insert(lst, "")  
            break  
        end  
        start = i + 1
    end  
    return lst  
end

function EventGmShowMiniWindow()
    LuaClassObj.HandleUIMessage(bp_gm, "UIShowMini")
end

function EventCollectTotalLuaMemory()
    collectgarbage("collect")
    local count = collectgarbage("count")
    count = count / 1024;
    Client.LuaSnapShot();
    local msg = "Lua总内存 : " .. string.format("%.2f", count) .. "MB";
    msg = msg .. "\n";
    msg = msg .. "Lua内存详情已生成，请查看日志";

	CommonMessageBoxUI:ShowPanel(1, "Notice", msg, nil, nil);
end

function EventGmRequestfile()
    local filename = "map_desert_0.8.0.8888.pak";--"AGP_VIA_5.00.00.0405_XPx86/_sys1.cab";
    log("puffer EventGmGetCompressedFileSize: " .. tostring(Client.GetFileSizeCompressed(GameFrontendHUD, filename)));
    PufferDownloadTaskId = Client.RequestFile(GameFrontendHUD, filename, false);
    log("puffer EventGmRequestFile: " .. tostring(PufferDownloadTaskId));
end

function EventGmGetCompressedFileSize()
    log("puffer EventGmGetCompressedFileSize: " .. tostring(Client.RequestFile(GameFrontendHUD, "map_desert_0.8.0.8888.pak")));
end

function EventGmStopTask()
    log("puffer taskID start! =========================")
    for i=1, 100 do
        log("Stop taskId: " .. tostring(i) .. "Status:" .. tostring(Client.StopTask(GameFrontendHUD, PufferDownloadTaskId)));
    end
    log("puffer taskID end! =========================")
end


--sami gm显示提示框
function gm_show_tip(id, ...)
    log("gm_show_tip " ..id);

    local arg={...};
    if arg[1] ~= nil then
        log("gm_show_tip arg:" ..arg[1]);
    end

    local msg = FuncUtil.LocalizeResFormat(id, ...);
    if(msg == "") then 
        msg = DataMgr.GetMsgByIDForBattleText(id);
        if(msg ~= "")then
            msg = string.format(msg, ...)
        end
    end
    if msg ~= "" then
        CommonMessageBoxUI:ShowPanel(1, "", msg);
    end    
end

--设置国家地区
--c gm_set_region(840)
function gm_set_region(id, ...)
    log("gm_set_region: " ..id);    
    Client.SaveStringToFile(tostring(id),"regionID.txt");
    CommonMessageBoxUI:ShowPanel(2, "region", string.format("has changed %s,quit game?", tostring(id)),
            function()
                --退出游戏
                LuaClassObj.HandleUIMessage(bp_global, "quitGame");
            end);
end

function gm_send_corps_msg(Msg, Interval)
	LobbyChatSystem.GmSendCorpsMsg = Msg
	LobbyChatSystem.GmIndex = 1
	if LobbyChatSystem.GmSendCorpsTimer then
		Timer.RemoveTimer(LobbyChatSystem.GmSendCorpsTimer)
		LobbyChatSystem.GmSendCorpsTimer = nil
	end
	local function GmFunc()
		LobbyChatSystem.on_chat_req(tonumber(""),
									8,
									LobbyChatSystem.GmSendCorpsMsg .. tostring(LobbyChatSystem.GmIndex),
									"world_Channel",
									{},
									{});
		LobbyChatSystem.GmIndex = LobbyChatSystem.GmIndex + 1
	end
	LobbyChatSystem.GmSendCorpsTimer = Timer.InsertTimer(Interval, GmFunc, true)
end

function gm_stop_send_corps_msg()
	if LobbyChatSystem.GmSendCorpsTimer then
		Timer.RemoveTimer(LobbyChatSystem.GmSendCorpsTimer)
		LobbyChatSystem.GmSendCorpsTimer = nil
	end
end

function gm_send_team_recruit_msg(Interval)
	if LobbyChatSystem.GmSendTeamRecruitTimer then
		Timer.RemoveTimer(LobbyChatSystem.GmSendTeamRecruitTimer)
		LobbyChatSystem.GmSendTeamRecruitTimer = nil
	end
	local function GmFunc()
		TeamUpSystem.team_recruit("65793-66051-0,1",
								  false,
								  false,
								  false,
								  false,
								  false,
								  true,
								  1);
	end
	LobbyChatSystem.GmSendTeamRecruitTimer = Timer.InsertTimer(Interval, GmFunc, true)
end

function gm_stop_send_team_recruit_msg()
	if LobbyChatSystem.GmSendTeamRecruitTimer then
		Timer.RemoveTimer(LobbyChatSystem.GmSendTeamRecruitTimer)
		LobbyChatSystem.GmSendTeamRecruitTimer = nil
	end
end
function EventResetDecomposeIndexTriggerTime()
    local PlayerPrefs = slua.loadClass("/Game/UMG/UI_Utility/PlayerPrefs.PlayerPrefs")
    if PlayerPrefs then
        log("PlayerPrefs.SetDecomposeIndexTriggerTime(0)")
        PlayerPrefs.SetDecomposeIndexTriggerTime(0)
    else
        log("PlayerPrefs.EventResetDecomposeIndexTriggerTime ")
    end
end