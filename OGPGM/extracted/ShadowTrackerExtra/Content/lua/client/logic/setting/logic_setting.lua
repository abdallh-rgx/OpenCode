
SettingSystem = SettingSystem or 
{
	LayoutData = {},	--布局数据
	UploadData = {},	--上传的布局
	CheckNameReason = "",	--检查敏感词的系统
	CheckNameReasonRenameItem1 = "RenameItem1",	--使用布局
	CheckNameReasonRenameItem2 = "RenameItem2",	--使用布局
}

function SettingSystem.GetCurrentConfig()
	--获取当前数据
	log(BP_Setting_LoadUIElemFileName)
	local config = Client.LoadSavFile(BP_Setting_LoadUIElemFileName);
	if (config ~= nil) then
		log("Load sav file. UncompressedFileSize:"..tostring(config.UnCompressedFileSize)..", CompressedSize:"..tostring(config.CompressedSize))
	else
		log("Load sav file. config is nil");
	end
	--log_tree("setting_info", config);
	return config;
end

--获取自定义战斗面板JSON配置，且压缩
function SettingSystem.GetCurrentConfigByJson()
	log(BP_Setting_LoadUIElemFileName)
	local fullFileName = string.format("SaveGames/%s.json", BP_Setting_LoadUIElemFileName)

	local str = Client.LoadFileToString(fullFileName);
	local table = json.decode(str)
	local config = Client.ZLIBCompress(str)

	-- rain 自定义战斗面板重构
	--local test = Client.ZLIBDecompress(config.CompressedData, config.CompressedSize, config.UnCompressedFileSize);
	--local str = json.encode(config)
	--Client.SaveStringToFile(test, "SaveGames/UIElemLayout_Download.json")

	if (config ~= nil) then
		log("Load sav file. UncompressedFileSize:"..", CompressedSize:"..tostring(config.CompressedSize))
	else
		log("Load sav file. config is nil");
	end
	--log_tree("setting_info", config);
	return config;
end

function SettingSystem.query_custom_setting(slotType)
	-- slotType等于1时代表请求settingConfig数据
	log("query_custom_setting");
	NetUtil.SendPkg("query_custom_setting", slotType);
end
	
function SettingSystem.dirty_name_check_req(newName, reason)
	SettingSystem.CheckNameReason = reason;
	log("dirty_name_check_req newName = " .. tostring(newName) .. ", reason = " .. tostring(reason));
	NetUtil.SendPkg("dirty_name_check_req", newName);
end

function SettingSystem.save_custom_setting(setting_info, newName, operType, slotType)
	-- slotType等于1时代表上传settingConfig数据
	log("save_custom_setting slotType = " .. tostring(slotType));
	--log_tree("setting_info", setting_info);
	NetUtil.SendPkg("save_custom_setting", setting_info, operType, slotType);	
end

function SettingSystem.dirty_name_check_rsp(result)
	log("dirty_name_check_rsp result = " .. tostring(result));
	if (tostring(result) == "ok") then
		SettingSelectionUI.OnDirtyNameCheckOK();
	elseif (tostring(result) == "411019") then
		DataMgr.ShowNoticeByID(411019);--检测到敏感词，请重新输入（只能输入汉字、字母或数字）
	else
		DataMgr.ShowNoticeByID(411019);
	end
	if (tostring(result) ~= "ok") then
		SettingSelectionUI.OnDirtyNameCheckFail();
	end
end

function SettingSystem.sync_custom_setting(setting_info, slotType)
	-- slotType等于1时代表同步settingConfig数据
	log("sync_custom_setting");
	--log_tree("setting_info", setting_info);	
	if (setting_info == nil) then
		log("setting_info is nil");
		setting_info = {};
	end
	if slotType ~= 1 then
		SettingSystem.LayoutData = setting_info;
		SettingSelectionUI.UpdateData();
		SettingUIElemUI.OnQueryCustomSettingHandle();
	elseif slotType == 1 then
		if setting_info.Config ~= nil then
			log("sync_custom_setting slotType");
			local config = setting_info.Config 
			SettingSystem.UseSettingConfig(config)
	    end
	end
end

function SettingSystem.save_custom_setting_rsp(result, operType, slotType)
	-- slotType等于1时代表上传settingConfig数据
	log("save_custom_setting_rsp result = " .. tostring(result) .. " operType = " .. tostring(operType) .. " slotType = " .. tostring(slotType));
	if slotType ~= 1 then
		if (tostring(result) == "ok") then
			if operType == 1 then
				DataMgr.ShowNoticeByID(110412);--上传布局成功
			end
			SettingSelectionUI.OnUploadSuccess();
		elseif (tostring(result) == "411019") then
			DataMgr.ShowNoticeByID(411019);--检测到敏感词，请重新输入（只能输入汉字、字母或数字）
		else
			DataMgr.ShowNoticeByID(110413);--上传布局失败
		end
	elseif slotType == 1 then
		if (tostring(result) == "ok") then
			log("upload settingconfig success!")
		else
			log("upload settingconfig failed!")
		end
	end
end


-- albin 将从云端下载的设置界面数据保存为SettingConfig_Slot.sav到savegame目录, 并设置界面数据(更新灵敏度和拾取设置界面)
function SettingSystem.UseSettingConfig(config)
    log("SettingSystem.UseSettingConfig");
    -- log_tree("SettingSystem.UseSettingConfig use config", config);
    if (config ~= nil) then
        if (config.CompressedData ~= nil) then
            Client.SaveSavFile(config.CompressedData, "SettingConfig_Slot", config.CompressedSize, config.UnCompressedFileSize);
            log("Save sav file. UncompressedFileSize:"..tostring(config.UnCompressedFileSize)..", CompressedSize:"..tostring(config.CompressedSize));
        else
            log("SettingSystem.UseSettingConfig, config.CompressedData is nil.");
        end
        log("SettingSystem.UseSettingConfig OnDownloadSuccess");

        -- 应用下载数据
		LuaClassObj.HandleUIMessage(bp_lobby, "LoadSettingConfigFromSlot");
    else
        log("SettingSystem.UseSettingConfig. config is nil");
    end
end

-- 根据设置的异形屏类型返回配置的参数
function SettingSystem.GetShapedScreenParam()
	local type = GlobalData.GetGlobalConfigIntValue("ShapedScreenType");
	if(type ~= 0) then
		log("ShapedScreenType : " .. tostring(type));
		local param;
		if(type == 1) then
			param = "0,0,0,0";
		elseif type == 2 then
			param = "30,0,30,0";
		elseif type == 3 then
			param = "50,0,50,0";
		else
			param ="0,0,0,0";
			log("no match shaped screen , type is : " .. tostring(type));
		end
		log("param : " .. param);
		return param;
	else
		log("ShapedScreenType is Nil");
		return nil
	end
end

s2c["sync_custom_setting"] = SettingSystem.sync_custom_setting	--同步设置信息
s2c["save_custom_setting_rsp"] = SettingSystem.save_custom_setting_rsp	--保存设置信息
s2c["dirty_name_check_rsp"] = SettingSystem.dirty_name_check_rsp	--检查敏感词








