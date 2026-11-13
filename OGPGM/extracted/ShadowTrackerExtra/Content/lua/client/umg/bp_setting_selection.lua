
SettingSelectionUI = SettingSelectionUI or 
{
    MaxItemCount = 3,
    MaxNameLength = 10,
    InputChange1 = false,
    InputChange2 = false,
    CheckInputReason = "",
    CheckInputReasonForClose = "CheckInputReasonForClose",
    CheckInputReasonForUse = "CheckInputReasonForUse",
}

BP_STRUCT_SettingSelectionItemData =
{
    LayoutName = "",    --布局名字
    IsEmpty = false,    --服务器是否有数据
    IsUse = false,      --是否在使用中
    Index = 1,          --序号
    Config = nil,       --布局数据
};

BP_ARRAY_SettingSelectionItemList = 
{
	BP_STRUCT_SettingSelectionItemData = _G.BP_STRUCT_SettingSelectionItemData,
};


BP_SettingSelection_SpellInput = "";

BP_Setting_SelectInputName1 = "";
BP_Setting_SelectInputName2 = "";

BP_Setting_SelectCheckIndex = 0;
BP_Setting_SelectCheckName = "";

function bp_setting_selection_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_setting_selection,
        {
            {Path="/Game/UMG/UI_BP/Setting/item/Setting_Selection_LogicBP.Setting_Selection_LogicBP_C", Container="Top", ZOrder=BP_ENUM_UI_SETTING_LAYOUT_ZORDER + 1},
        },
        {"Lobby", "Fighting"},
        false,
        false,
        true
    );
end

function EventFetchInfo()
	
end

function SettingSelectionUI.Show()
    log("SettingSelectionUI.Show");
	LuaClassObj.HandleDynamicCreation(bp_setting_selection);
    LuaClassObj.HandleUIMessage(bp_setting_selection, "UIShow");   
    SettingSelectionUI.UpdateData();
end

function SettingSelectionUI.UpdateData()

    log("SettingSelectionUI.UpdateData");
    --log_tree("SettingSystem.LayoutData", SettingSystem.LayoutData);
    BP_ARRAY_SettingSelectionItemList = {};

    if (SettingSystem.LayoutData == nil) then
        SettingSystem.LayoutData = {};
    end
    if (SettingSystem.LayoutData.DataMap == nil) then
        SettingSystem.LayoutData.DataMap = {};
    end
    local useIndex = SettingSystem.LayoutData.UseIndex == nil and 1 or SettingSystem.LayoutData.UseIndex;
    for i = 1, SettingSelectionUI.MaxItemCount, 1 do 
        local data = SettingSystem.LayoutData.DataMap[i];
        local itemData = {};
        itemData.Index = i;
       
        if i == 3 then
            -- albinliao 大手版布局
            itemData.LayoutName = DataMgr.GetMsgByID(6319); -- 大手
        else            
            itemData.LayoutName = DataMgr.GetMsgByID(110420 + i);
        end

        if (data ~= nil) then
            itemData.IsEmpty = false;
            itemData.Config = data.Config;
        else
            itemData.IsEmpty = true;
            itemData.Config = nil;
        end

        itemData.IsUse = (useIndex == i);

        if (itemData.IsUse == true) then
            BP_Setting_SelectLayoutName = itemData.LayoutName;
        end
        table.insert(BP_ARRAY_SettingSelectionItemList, itemData);
    end

    BP_Setting_SelectLayoutIndex = useIndex
    BP_Setting_SelectLayoutName = BP_ARRAY_SettingSelectionItemList[useIndex].LayoutName;
    --log_tree("BP_ARRAY_SettingSelectionItemList", BP_ARRAY_SettingSelectionItemList);
    LuaClassObj.HandleUIMessage(bp_setting_selection, "UpdateData");
end

--检查上传名字
function EventSettingSelectionCheckName()
    SettingSelectionUI.UpdateInputName1(SettingSelectionUI.CheckInputReasonForUse);
end

function SettingSelectionUI.OnDirtyNameCheckOK()
    log("SettingSelectionUI.OnDirtyNameCheckOK");
    
    if (SettingSystem.CheckNameReason == SettingSystem.CheckNameReasonRenameItem1) then
        SettingSelectionUI.InputChange1 = true;
        SettingSelectionUI.UpdateInputName2();
    elseif (SettingSystem.CheckNameReason == SettingSystem.CheckNameReasonRenameItem2) then
        SettingSelectionUI.InputChange2 = true;
        SettingSelectionUI.OnFinishInputNameCheck();
    end
end

function SettingSelectionUI.OnDirtyNameCheckFail()
    if (SettingSystem.CheckNameReason == SettingSystem.CheckNameReasonRenameItem1) then
        if (SettingSelectionUI.CheckInputReason == SettingSelectionUI.CheckInputReasonForUse and BP_Setting_SelectCheckIndex == 1) then
            return;
        end
        SettingSelectionUI.InputChange1 = false;
        SettingSelectionUI.UpdateInputName2();
    elseif (SettingSystem.CheckNameReason == SettingSystem.CheckNameReasonRenameItem2) then
        if (SettingSelectionUI.CheckInputReason == SettingSelectionUI.CheckInputReasonForUse and BP_Setting_SelectCheckIndex == 2) then
            return;
        end
        SettingSelectionUI.InputChange2 = false;
        SettingSelectionUI.OnFinishInputNameCheck();
    end
end

function SettingSelectionUI.UpdateInputName1(reason)
    
    SettingSelectionUI.CheckInputReason = reason;

    SettingSelectionUI.InputChange1 = false;
    SettingSelectionUI.InputChange2 = false;

    local isEmpty = BP_Setting_SelectInputName1 == nil or string.len(BP_Setting_SelectInputName1) == 0;
    if (isEmpty == false and BP_Setting_SelectInputName1 ~= BP_ARRAY_SettingSelectionItemList[1].LayoutName) then
        SettingSystem.dirty_name_check_req(BP_Setting_SelectInputName1, SettingSystem.CheckNameReasonRenameItem1);
    else
        if (SettingSelectionUI.CheckInputReason == SettingSelectionUI.CheckInputReasonForUse and BP_Setting_SelectCheckIndex == 1 and isEmpty == true) then
            DataMgr.ShowNoticeByID(110407);
            return;
        end
        SettingSelectionUI.InputChange1 = false;
        SettingSelectionUI.UpdateInputName2();
    end
end

function SettingSelectionUI.UpdateInputName2()
    local isEmpty = BP_Setting_SelectInputName2 == nil or string.len(BP_Setting_SelectInputName2) == 0;
    if (isEmpty == false and BP_Setting_SelectInputName2 ~= BP_ARRAY_SettingSelectionItemList[2].LayoutName) then
        SettingSystem.dirty_name_check_req(BP_Setting_SelectInputName2, SettingSystem.CheckNameReasonRenameItem2);
    else
        if (SettingSelectionUI.CheckInputReason == SettingSelectionUI.CheckInputReasonForUse and BP_Setting_SelectCheckIndex == 2 and isEmpty == true) then
            DataMgr.ShowNoticeByID(110407);
            return;
        end
        SettingSelectionUI.InputChange2 = false;
        SettingSelectionUI.OnFinishInputNameCheck()
    end
end

function SettingSelectionUI.OnFinishInputNameCheck()
    if (SettingSelectionUI.InputChange1 == true or SettingSelectionUI.InputChange2 == true) then
       
        local UploadData = FuncUtil:CopyTable(SettingSystem.LayoutData);
        if (UploadData.DataMap == nil) then
            log("SettingSelectionUI.HandleUpload UploadData.DataMap == nil");
            UploadData.DataMap = {};
        end

        if (SettingSelectionUI.InputChange1 == true) then
            if (SettingSelectionUI.InputChange2 == true and BP_Setting_SelectInputName1 ~= BP_Setting_SelectInputName2 or 
                SettingSelectionUI.InputChange2 == false and BP_Setting_SelectInputName1 ~= BP_ARRAY_SettingSelectionItemList[2].LayoutName) then

                    BP_ARRAY_SettingSelectionItemList[1].LayoutName = BP_Setting_SelectInputName1;            
                    local data = {};
                    data.Config = UploadData.DataMap[1] ~= nil and UploadData.DataMap[1].Config or nil;
                    data.DeviceName = DeviceOSInfo.InfoList.DeviceName;
                    data.LayoutName = BP_Setting_SelectInputName1;
                    data.Index = 1;    
                    UploadData.DataMap[1] = data;
            else
                if (SettingSelectionUI.CheckInputReason == SettingSelectionUI.CheckInputReasonForUse) then
                    DataMgr.ShowNoticeByID(110414);
                    return;
                end
            end
        end
        if (SettingSelectionUI.InputChange2 == true) then
            if (SettingSelectionUI.InputChange1 == true and BP_Setting_SelectInputName2 ~= BP_Setting_SelectInputName1 or
                SettingSelectionUI.InputChange1 == false and BP_Setting_SelectInputName2 ~= BP_ARRAY_SettingSelectionItemList[1].LayoutName) then

                    BP_ARRAY_SettingSelectionItemList[2].LayoutName = BP_Setting_SelectInputName2;
                    local data = {};
                    data.Config = UploadData.DataMap[2] ~= nil and UploadData.DataMap[2].Config or nil;
                    data.DeviceName = DeviceOSInfo.InfoList.DeviceName;
                    data.LayoutName = BP_Setting_SelectInputName2;
                    data.Index = 2;    
                    UploadData.DataMap[2] = data;
            else
                if (SettingSelectionUI.CheckInputReason == SettingSelectionUI.CheckInputReasonForUse) then
                    DataMgr.ShowNoticeByID(110414);
                    return;
                end
            end
        end
        if (SettingSelectionUI.CheckInputReason == SettingSelectionUI.CheckInputReasonForUse) then
            UploadData.UseIndex = BP_Setting_SelectCheckIndex;
            BP_Setting_SelectLayoutIndex = BP_Setting_SelectCheckIndex;
            BP_Setting_SelectLayoutName = BP_Setting_SelectCheckName;
            if (UploadData.DataMap == nil or UploadData.DataMap[UploadData.UseIndex] == nil) then
                log("SettingSystem.LayoutData.DataMap[newIndex] is nil");
                SettingSelectionUI.UseConfig(nil);
            else
                local config = UploadData.DataMap[UploadData.UseIndex].Config;
                SettingSelectionUI.UseConfig(config);
            end
        end
        SettingSystem.UploadData = UploadData;
        log("OnFinishInputNameCheck save_custom_setting 1");
        SettingSystem.save_custom_setting(UploadData, " ", 2, 0);
    else
        if (SettingSelectionUI.CheckInputReason == SettingSelectionUI.CheckInputReasonForUse) then
            --log_tree("UploadData before:", SettingSystem.LayoutData)
            local UploadData = FuncUtil:CopyTable(SettingSystem.LayoutData);
            if (UploadData.DataMap == nil) then
                log("SettingSelectionUI.HandleUpload UploadData.DataMap == nil");
                UploadData.DataMap = {};
            end
            log_tree("UploadData:", UploadData)
            UploadData.UseIndex = BP_Setting_SelectCheckIndex;
            BP_Setting_SelectLayoutIndex = BP_Setting_SelectCheckIndex;
            BP_Setting_SelectLayoutName = BP_Setting_SelectCheckName;
            SettingSystem.UploadData = UploadData;

            log("OnFinishInputNameCheck save_custom_setting 2");
            SettingSystem.save_custom_setting(UploadData, " ", 2, 0);

            if (UploadData.DataMap == nil or UploadData.DataMap[UploadData.UseIndex] == nil) then
                log("SettingSystem.LayoutData.DataMap[newIndex] is nil");
                SettingSelectionUI.UseConfig(nil);
            else
                local config = UploadData.DataMap[UploadData.UseIndex].Config;
                SettingSelectionUI.UseConfig(config);
            end
        end
    end
end

function SettingSelectionUI.UseCloudSelection()
    log("EventTryDownloadSaveData index = " .. tostring(BP_Setting_SelectLayoutIndex) .. ", name = " .. tostring(BP_Setting_SelectLayoutName));
    if (SettingSystem.LayoutData == nil or SettingSystem.LayoutData.DataMap == nil or SettingSystem.LayoutData.DataMap[BP_Setting_SelectLayoutIndex] == nil) then
        log("SettingSystem.LayoutData.DataMap[BP_Setting_SelectLayoutIndex] is nil");
        SettingSelectionUI.UseConfig(nil);
    else
        local config = SettingSystem.LayoutData.DataMap[BP_Setting_SelectLayoutIndex].Config;
        SettingSelectionUI.UseConfig(config);
    end
end

function SettingSelectionUI.UseConfig(config)
    --log_tree("use config", config);
    if (config ~= nil) then
        if BP_UIElemLayout_UseJsonConfig then
            -- rain 自定义战斗面板重构
            local str = Client.ZLIBDecompress(config.CompressedData, config.CompressedSize, config.UnCompressedFileSize);
            --判断云配置是否sav文件，而版本已经是新版本
            local uielemLayout = json.decode(str)
            if uielemLayout == nil then
                if (config.CompressedData ~= nil) then
                    Client.SaveSavFile(config.CompressedData, "UIElemLayout_Download", config.CompressedSize, config.UnCompressedFileSize);
                    log("Save sav file. UncompressedFileSize:"..tostring(config.UnCompressedFileSize)..", CompressedSize:"..tostring(config.CompressedSize));
                else
                    log("SettingSelectionUI.UseConfig, config.CompressedData is nil.");
                end
            else
                Client.SaveStringToFile(str, "SaveGames/UIElemLayout_Download.json")
            end
        else
            if (config.CompressedData ~= nil) then
                Client.SaveSavFile(config.CompressedData, "UIElemLayout_Download", config.CompressedSize, config.UnCompressedFileSize);
                log("Save sav file. UncompressedFileSize:"..tostring(config.UnCompressedFileSize)..", CompressedSize:"..tostring(config.CompressedSize));
            else
                log("SettingSelectionUI.UseConfig, config.CompressedData is nil.");
            end
        end
        log("SettingSelectionUI OnDownloadSuccess");
        LuaClassObj.HandleUIMessage(bp_setting_uielem, "OnDownloadDataSuccess");
    else
        log("SettingSelectionUI.UseConfig. config is nil");
        LuaClassObj.HandleUIMessage(bp_setting_uielem, "OnDownloadDataFailed");
    end
end

--上传配置
function EventSettingSelectionUpload()
    local config
    if BP_UIElemLayout_UseJsonConfig then
        -- rain 自定义战斗面板重构
        config = SettingSystem.GetCurrentConfigByJson()
    else
        config = SettingSystem.GetCurrentConfig();
    end

    local newIndex = BP_Setting_SelectLayoutIndex;
    local newName = BP_Setting_SelectLayoutName;
    SettingSelectionUI.HandleUpload(newIndex, newName, config);
end

function SettingSelectionUI.HandleUpload(newIndex, newName, config)
    --log_tree("upload config " .. tostring(newName), config);
    log("SettingSelectionUI.HandleUpload newIndex = " .. tostring(newIndex) .. ", newName = " .. tostring(newName))
    local UploadData = FuncUtil:CopyTable(SettingSystem.LayoutData);
    if (UploadData.DataMap == nil) then
        log("SettingSelectionUI.HandleUpload UploadData.DataMap == nil");
        UploadData.DataMap = {};
    end

    local data = {};
    data.Config = config;
    data.DeviceName = DeviceOSInfo.InfoList.DeviceName;
    data.LayoutName = newName;
    data.Index = newIndex;
    UploadData.UseIndex = newIndex;

    UploadData.DataMap[newIndex] = data;
    SettingSystem.UploadData = UploadData;
    log_tree("SettingSelectionUI.HandleUpload", UploadData)
	SettingSystem.save_custom_setting(UploadData, newName, 1, 0);
end

function SettingSelectionUI.OnUploadSuccess()
    log("SettingSelectionUI.OnUploadSuccess");
    SettingSystem.LayoutData = SettingSystem.UploadData;
    SettingSelectionUI.UpdateData();

    log("OnSelectChangeHandle BP_Setting_SelectLayoutName = " .. tostring(BP_Setting_SelectLayoutName) .. ", BP_Setting_SelectLayoutIndex = " .. tostring(BP_Setting_SelectLayoutIndex));
    LuaClassObj.HandleUIMessage(bp_setting_uielem, "OnSelectChangeHandle");  
end

function EventSettingSelectionCheckInput()
	BP_SettingSelection_SpellInput = string.gsub(BP_SettingSelection_SpellInput,"%s","");
    _ , _ , BP_SettingSelection_SpellInput = FuncUtil:CheckName(BP_SettingSelection_SpellInput, false, SettingSelectionUI.MaxNameLength, 2);
end

function EventSettingSelectionCheckInputChange()
    SettingSelectionUI.UpdateInputName1(SettingSelectionUI.CheckInputReasonForClose);
end
