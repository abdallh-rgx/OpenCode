SettingUIElemUI = SettingUIElemUI or 
{
}

BP_Setting_SelectLayoutFileName = "";
BP_Setting_SelectLayoutName = "";
BP_Setting_SelectLayoutIndex = 1;
BP_Setting_LoadUIElemFileName = "";
BP_Setting_SyncTimeTag = 0;

BP_UIElemLayout_UseJsonConfig = false;

function bp_setting_uielem_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_setting_uielem,
        {
            {Path="/Game/UMG/UI_BP/Setting/UILayout/UIElemLayout_BP.UIElemLayout_BP_C", Container="Top", ZOrder=BP_ENUM_UI_SETTING_LAYOUT_ZORDER}
        },
        {"Lobby", "Fighting"},
        false,
        false,
        true
    );
end

function EventFetchInfo()
	
end

function SettingUIElemUI.Show()
	log("SettingUIElemUI.Show");
	LuaClassObj.HandleDynamicCreation(bp_setting_uielem);
    LuaClassObj.HandleUIMessage(bp_setting_uielem, "UIShow");
    SettingSystem.query_custom_setting(0);
end

function EventShowSelectPanel()
	SettingSelectionUI.Show();
end

function EventUploadSaveData()
	EventSettingSelectionUpload();
end

--==============================--
--desc:使用某个布局
--time:2018-06-23 04:14:45
--@index:参考bp_setting_selection的BP_STRUCT_SettingSelectionItemData的Index属性
--@name:参考bp_setting_selection的BP_STRUCT_SettingSelectionItemData的LayoutName属性
--@return 
--==============================--
function EventTryDownloadSaveData()
    log("EventTryDownloadSaveData");
    SettingSelectionUI.UseCloudSelection();
end

function EventBigHandOperateRedPointChanged()
    log("EventBigHandOperateRedPointChanged");

    DataMgr.SetNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_BIGHAND, 1) -- 关闭大手版新手引导

    LuaClassObj.HandleUIMessage(bp_setting_uielem, "CheckLayoutButtonRedPoint");  
    LuaClassObj.HandleUIMessage(bp_setting_operate, "CheckOperateLayoutRedPoint");  
    LuaClassObj.HandleUIMessage(bp_setting, "CheckSettingOperateRedPoint");  
    LuaClassObj.HandleUIMessage(bp_lobby, "CheckSettingRedPoint");      
end

--==============================--
--desc:服务器返回其保存的布局信息数据。BP_ARRAY_SettingSelectionItemList
--time:2018-06-23 04:14:41
--@return 
--==============================--
function SettingUIElemUI.OnQueryCustomSettingHandle()
    LuaClassObj.HandleUIMessage(bp_setting_uielem, "OnQueryCustomSettingHandle");  
end

function LoadUIElemJsonToBPStruct(fileName)
    local fullFileName = string.format("SaveGames/%s.json", fileName)
    local str = Client.LoadFileToString(fullFileName)
    if str == nil or str == "" then
        return nil
    end

    local uielemLayout = json.decode(str)
    local gameplayStatics = import("GamePlayStatics")
    local classUIElemLayout = slua.loadClass("/Game/Blueprints/Config/UIElemLayout/BP_SAVEGAME_UIElemLayout.BP_SAVEGAME_UIElemLayout")
    local objectUIElemLayout = gameplayStatics.CreateSaveGameObject(classUIElemLayout)
    if objectUIElemLayout == nil then
        sandbox.logError("LoadUIElemJsonToBPStruct objectUIElemLayout is nil")
        return
    end

    MakeUIElemLayoutObjectDict(objectUIElemLayout.LayoutDetailDict1, uielemLayout.LayoutDetailDict1)
    MakeUIElemLayoutObjectDict(objectUIElemLayout.LayoutDetailDict2, uielemLayout.LayoutDetailDict2)
    MakeUIElemLayoutObjectDict(objectUIElemLayout.LayoutDetailDict3, uielemLayout.LayoutDetailDict3)

    objectUIElemLayout.IsDataValid1 = uielemLayout.IsDataValid1
    objectUIElemLayout.RushTriggerLength1 = uielemLayout.RushTriggerLength1
    objectUIElemLayout.IsDataValid2 = uielemLayout.IsDataValid2
    objectUIElemLayout.RushTriggerLength2 = uielemLayout.RushTriggerLength2
    objectUIElemLayout.IsDataValid3 = uielemLayout.IsDataValid3
    objectUIElemLayout.RushTriggerLength3 = uielemLayout.RushTriggerLength3

    objectUIElemLayout.TimeTag = uielemLayout.TimeTag

    objectUIElemLayout.SaveSlotName = uielemLayout.SaveSlotName

    --objectUIElemLayout.LayoutName1 = uielemLayout.LayoutName1
    --objectUIElemLayout.LayoutName2 = uielemLayout.LayoutName2
    --objectUIElemLayout.LayoutName3 = uielemLayout.LayoutName3

    return objectUIElemLayout
end

function SaveUIElemBPStructToJson(bp_SaveGame_UIElemLayout, fileName)
    if bp_SaveGame_UIElemLayout == nil then
        logError("SaveUIElemBPStructToJson bp_SaveGame_UIElemLayout is nil")
        return false
    end

    local table_SaveGame_UIElemLayout = {
        LayoutDetailDict1 = {},
        LayoutDetailDict2 = {},
        LayoutDetailDict3 = {},
    }
    log("SaveUIElemBPStructToJson", bp_SaveGame_UIElemLayout.LayoutDetailDict1:Num())

    MakeUIElemLayoutTableDict(table_SaveGame_UIElemLayout.LayoutDetailDict1, bp_SaveGame_UIElemLayout.LayoutDetailDict1)
    MakeUIElemLayoutTableDict(table_SaveGame_UIElemLayout.LayoutDetailDict2, bp_SaveGame_UIElemLayout.LayoutDetailDict2)
    MakeUIElemLayoutTableDict(table_SaveGame_UIElemLayout.LayoutDetailDict3, bp_SaveGame_UIElemLayout.LayoutDetailDict3)

    table_SaveGame_UIElemLayout.IsDataValid1 = bp_SaveGame_UIElemLayout.IsDataValid1  
    table_SaveGame_UIElemLayout.RushTriggerLength1 = bp_SaveGame_UIElemLayout.RushTriggerLength1
    table_SaveGame_UIElemLayout.IsDataValid2 = bp_SaveGame_UIElemLayout.IsDataValid2
    table_SaveGame_UIElemLayout.RushTriggerLength2 = bp_SaveGame_UIElemLayout.RushTriggerLength2
    table_SaveGame_UIElemLayout.IsDataValid3 = bp_SaveGame_UIElemLayout.IsDataValid3
    table_SaveGame_UIElemLayout.RushTriggerLength3 = bp_SaveGame_UIElemLayout.RushTriggerLength3

    table_SaveGame_UIElemLayout.TimeTag = bp_SaveGame_UIElemLayout.TimeTag

    table_SaveGame_UIElemLayout.SaveSlotName = fileName

    --table_SaveGame_UIElemLayout.LayoutName1 = bp_SaveGame_UIElemLayout.LayoutName1
    --table_SaveGame_UIElemLayout.LayoutName2 = bp_SaveGame_UIElemLayout.LayoutName2
    --table_SaveGame_UIElemLayout.LayoutName3 = bp_SaveGame_UIElemLayout.LayoutName3

    log("SaveUIElemBPStructToJson", table_SaveGame_UIElemLayout)

    local str = json.encode(table_SaveGame_UIElemLayout)
    local fullFileName = string.format("SaveGames/%s.json", fileName)
    Client.SaveStringToFile(str, fullFileName)
    return true
end

function MakeUIElemLayoutTableDict(tableDict, objectDict)
    for i, v in pairs(objectDict) do
        local uielemLayoutDetail = {}
        uielemLayoutDetail.Type = v.Type

        uielemLayoutDetail.Scale = {}
        uielemLayoutDetail.Scale.X = v.Scale.X
        uielemLayoutDetail.Scale.Y = v.Scale.Y

        uielemLayoutDetail.Opacity = v.Opacity

        uielemLayoutDetail.AnchorType = {}
        uielemLayoutDetail.AnchorType.Minimum = {}
        uielemLayoutDetail.AnchorType.Maximum = {}

        uielemLayoutDetail.AnchorType.Minimum.X = v.AnchorType.Minimum.X
        uielemLayoutDetail.AnchorType.Minimum.Y = v.AnchorType.Minimum.Y
        uielemLayoutDetail.AnchorType.Maximum.X = v.AnchorType.Maximum.X
        uielemLayoutDetail.AnchorType.Maximum.Y = v.AnchorType.Maximum.Y

        uielemLayoutDetail.RelativePos = {}
        uielemLayoutDetail.RelativePos.X = v.RelativePos.X
        uielemLayoutDetail.RelativePos.Y = v.RelativePos.Y

        uielemLayoutDetail.OriginSize = {}
        uielemLayoutDetail.OriginSize.X = v.OriginSize.X
        uielemLayoutDetail.OriginSize.Y = v.OriginSize.Y
        table.insert(tableDict, uielemLayoutDetail)
    end
end

function MakeUIElemLayoutObjectDict(objectDict, tableDict)
    for i, v in pairs(tableDict) do

        local classUIElemLayoutDetail = import("/Game/Blueprints/Config/UIElemLayout/BP_STRUCT_UIElemLayoutDetail.BP_STRUCT_UIElemLayoutDetail")
        local uiElemLayoutDetail = classUIElemLayoutDetail()

        uiElemLayoutDetail.Type = v.Type

        local scale = FVector2D()
        scale.X = v.Scale.X
        scale.Y = v.Scale.Y
        uiElemLayoutDetail.Scale = scale

        uiElemLayoutDetail.Opacity = v.Opacity

        local minimum = FVector2D()
        minimum.X = v.AnchorType.Minimum.X
        minimum.Y = v.AnchorType.Minimum.Y
        local maximum = FVector2D()
        maximum.X = v.AnchorType.Maximum.X
        maximum.Y = v.AnchorType.Maximum.Y
        local anchorType = FAnchors()
        anchorType.Minimum = minimum
        anchorType.Maximum = maximum
        uiElemLayoutDetail.AnchorType = anchorType

        local relativePos = FVector2D()
        relativePos.X = v.RelativePos.X
        relativePos.Y = v.RelativePos.Y
        uiElemLayoutDetail.RelativePos = relativePos

        local originSize = FVector2D()
        originSize.X = v.OriginSize.X
        originSize.Y = v.OriginSize.Y
        uiElemLayoutDetail.OriginSize = originSize

        objectDict:Add(v.Type, uiElemLayoutDetail)
    end
end