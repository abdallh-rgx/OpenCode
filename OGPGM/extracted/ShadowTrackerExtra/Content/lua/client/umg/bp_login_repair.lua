LoginRepairUI = LoginRepairUI or {

}

MAP_NAMES = {
    ["desert"] = "500002",
    ["savagemain"] = "500065",
    ["dihorotok"] = "500069",
}
BP_ARRAY_RepairMaps = {""};
BP_MAP_MapsExisted = {
    [""] = "", -- 名字 + 显示内容
};
BP_TexPatch_Exist = false;

function bp_login_repair_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_login_repair,		
    	{
			{Path="/Game/UMG/UI_Logic/Login/Login_Repair_LogicBP.Login_Repair_LogicBP_C", Container="Default", ZOrder = 50},
		},
		{"Login"},
		false,
		false,
		true
	);
end	 

--显示UI 
function LoginRepairUI.ShowUI()	
    --LuaClassObj.HandleUIMessage(bp_login_repair, "UIShow");	
    log("[LoginRepairUI] ShowUI")
	LuaClassObj.HandleDynamicCreation(bp_login_repair);
	LuaClassObj.HandleUIMessage(bp_login_repair, "UIShow");
end

--关闭UI
function EventHideUI()
	LuaClassObj.HandleUIMessage(bp_login_repair, "UIHide");	
end

function EventRepairDefault()
    local DefaultClearDir = {
        "Config/",
        "Logs/",
        "ImageDownload/",
        "NoticeImageDownload/",
        "UpdateInfo/",
        "TempPaks/",
    };

    for i=1,#DefaultClearDir do
        Client.DeleteDirectory(Client.ProjectSavedDir() .. DefaultClearDir[i]);
    end

    LoginRepairUI.DeleteDolphinFileinPaks();
end

-- 清理 Paks 文件夹中的 Dolphin 更新相关文件。但是忽略 5s 纹理 Patch
function LoginRepairUI.DeleteDolphinFileinPaks()	
    local ret = GCPufferDownloader.ReturnLocalFiles(PufferDownloader.DOWNLOAD_DIR_RELATIVE, "");
    local gamePatchPrefix = "game_patch_";
    local corePatchPrefix = "core_patch_";

    for idx, filename in pairs(ret) do
        local prefix = string.match(filename, "^([%a_]+).*%.pak$");
        if prefix then
            if (prefix == gamePatchPrefix or prefix == corePatchPrefix) then
                local filePath = Client.ProjectSavedDir() .. "Paks/".. filename;
                GCPufferDownloader.DeleteFile(filePath);
            end
        else
            if (not string.match( filename, "puffer")) and -- Puffer 相关文件不删除
               (not filename == "apollo_reslist.flist") and -- Dolphin 索引文件，删除后所有 Dolphin 都会在修复过程中重新下载，无法保留 TexPatch
               (not filename == "ClearFlag") then -- 地图强删功能标记文件，删除后会导致该功能重复处罚
                local filePath = Client.ProjectSavedDir() .. "Paks/".. filename;
                GCPufferDownloader.DeleteFile(filePath);
            end
        end
    end
end

function EventRepairSettingFile()
    Client.DeleteDirectory(Client.ProjectSavedDir() .. "SaveGames/");
end

function EventRepairMapFile()
    for i=1,#BP_ARRAY_RepairMaps do
        log("[EventRepairMapFile] maps:" .. tostring(BP_ARRAY_RepairMaps[i]));
        LoginRepairUI.DeleteAllPakStartWith("map_" .. BP_ARRAY_RepairMaps[i] .. "_");
    end

end

function EventRepairTexPatch()
	local ret = GCPufferDownloader.ReturnLocalFiles(PufferDownloader.DOWNLOAD_DIR_RELATIVE, "");

    for idx, filename in pairs(ret) do
        local res = string.match(filename, "^(tex_patch_)%d+%.%d+%.%d+%.%d+%.pak$");
        if res ~= nil then
            log("tes " .. tostring(res))
            LoginRepairUI.DeleteAllPakStartWith(res);
            return;
        end
    end
end

function EventRepairAll()
    -- 全干掉，威力巨大谨慎使用，用完记得重启游戏
    Client.DeleteDirectory(Client.ProjectSavedDir());
end

function EventUpdateTexPatchStatus()
	local ret = GCPufferDownloader.ReturnLocalFiles(PufferDownloader.DOWNLOAD_DIR_RELATIVE, "");

    for idx, filename in pairs(ret) do
        local res = string.match(filename, "^tex_patch_%d+%.%d+%.%d+%.%d+%.pak$");
        if res ~= nil then
            BP_TexPatch_Exist = true;
            return;
        end
    end

    BP_TexPatch_Exist = false;
end

function EventUpdateMapsStatus()
    local MAP_PREFIX = "map_";
	local ret = GCPufferDownloader.ReturnLocalFiles(PufferDownloader.DOWNLOAD_DIR_RELATIVE, "");

    local map_name_size = {};
    for idx, filename in pairs(ret) do
        local name = string.match(filename, "^map_([%a]+)_%d+%.%d+%.%d+%.%d+%.pak$");
        if name ~= nil then
            local filenameFullPath = Client.ProjectSavedDir() .. PufferDownloader.DOWNLOAD_DIR_RELATIVE .. filename;
            local size = Client.GetFileSizeOnDisk(filenameFullPath)/1024.0 + (map_name_size[name] or 0);
            map_name_size[name] = size;
        end
    end

    BP_MAP_MapsExisted = {};
    for name, size in pairs(map_name_size) do
        if MAP_NAMES[name] ~= nil then
            local targetName = Client.GetTableData("LocalizeRes", MAP_NAMES[name]).TextValue 
            BP_MAP_MapsExisted[name] = targetName .. "(" .. string.format( "%.0f", size) .. " MB)"; -- 用 key 的机制去重
            log("[EventRepairMapFile] maps:" .. tostring(name) .. tostring(size));
        else
            log("[EventRepairMapFile] error maps name:" .. tostring(name));
        end
    end
end

-- 删除同前缀的所有文件
function LoginRepairUI.DeleteAllPakStartWith(pak_prefix)
    if pak_prefix == nil then
        log("[LoginRepairUI] DeleteAllPakStartWith: pak_prefix is nil");
        return;
	end
	-- 检查本地所有的 pak 文件
	local ret = GCPufferDownloader.ReturnLocalFiles(PufferDownloader.DOWNLOAD_DIR_RELATIVE, "");

	for idx, filename in pairs(ret) do
		local prefix, localMapVersion = PufferDownloader.ParsePakName(filename);
		log("[LoginRepairUI] DeleteAllPakStartWith: parse local filename " .. filename .. " Prefix:" .. tostring(prefix) .. " versionNo " .. tostring(localMapVersion));
		if prefix ~= nil and localMapVersion ~= nil then -- 如果本地文件后缀不是 pak 会被自动忽略
			if (string.sub(prefix, 1, #pak_prefix) == pak_prefix) then
				local filePath = Client.ProjectSavedDir() .. PufferDownloader.DOWNLOAD_DIR_RELATIVE .. filename;
				GCPufferDownloader.DeleteFile(filePath);
				log("[LoginRepairUI] DeleteAllPakStartWith: delete filename " .. filePath);
			end
		end
	end
end


function EventRestartAlertAfterRepair()
    -- 下边这个函数名字起的有问题，其实就是弹窗提示退出而已
	local title = Client.GetTableData("LocalizeRes", "101001").TextValue;
    local msg = Client.GetTableData("LocalizeRes", "101714").TextValue;
    CommonMessageBoxUI:ShowPanel(1, title, msg, 
        function()
        --退出游戏
        LuaClassObj.HandleUIMessage(bp_global, "quitGame");
    end);

    local param = {};
    Client.GEMReportEvent(GameFrontendHUD, "UserRepair", param);
end

-- 用户未做任何选择时的提示
function EventShowNoChoiceHint()
    local msg = Client.GetTableData("LocalizeRes", "6646").TextValue;

	PopUpNoticeUI.ShowNewNotice(msg);
end
