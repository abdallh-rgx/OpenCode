local M = {}
local UI_Config = require("client.slua.config.base_config")
M.UI_Config = UI_Config

local ESlateVisibility      = UEnums.ESlateVisibility
local Visible               = ESlateVisibility.Visible
local Hidden                = ESlateVisibility.Hidden
local Collapsed             = ESlateVisibility.Collapsed
local HitTestInvisible      = ESlateVisibility.HitTestInvisible
local SelfHitTestInvisible  = ESlateVisibility.SelfHitTestInvisible

local DefaultShowVisibility = SelfHitTestInvisible
local DefaultHideVisibility = Collapsed
local DefaultContainerName = UIContainers.Default

local UI_Source_Path = "client.slua.umg."
local UI_Instances = {}         -- 单例ui实例列表, key为模块名, value为ui实例
local moduleToConfig = {}       -- ui模块名到config的映射表

local MAX_HIDDEN_COUNT = 2
local MIN_HIDDEN_COUNT = 2
local UI_HiddenInstances = {}   -- 被隐藏起来的UI

local StatusMapping = {}
local PreStatus = "None"

local UI_TYPE_START_NUM = 1000000

local function InitConfig()
    for _, status in pairs(GameStatus) do
        local statusWindowsName = {}
        StatusMapping[status] = statusWindowsName

        local statusModules = require("client.slua.config.status."..string.lower(status))
        for _, configName in pairs(statusModules) do
            -- 只对单例ui有效
            assert(UI_Config[configName] ~= nil, string.format("UI_Config[%s] is nil!", configName))
            if not (UI_Config[configName].isSingleton == false) then
                table.insert(statusWindowsName, configName)
            end
        end
    end
    end

local function OnUIModeSwitch(gameStatus)
    if gameStatus == PreStatus then
        return
    end

    for _, uiInstance in pairs(UI_Instances) do
        if uiInstance.OnModeSwitch then
            uiInstance:OnModeSwitch(PreStatus, gameStatus)
        end
    end

    for moduleName, _ in pairs(UI_Instances) do
        local config = moduleToConfig[moduleName]
        -- 由于部分UI需求，重新打开
        if not (config.closeOnSwitch == false) then
            M.CloseUI(config)
        end
        --M.CloseUI(config)
    end

    local currentStatusMap = StatusMapping[gameStatus]
    if currentStatusMap then
        for _, configName in pairs(currentStatusMap) do
            M.ShowUI(UI_Config[configName])
        end
    end
    require("client.common.event.event_system");
    EventSystem:postEvent(EVENTTYPE_STATE, EVENTID_ONGAMESTATECHANGE, { pre = PreStatus, current = gameStatus});
    PreStatus = gameStatus
end

local AndroidBackUIStack = {
    --[[
    {newStyle = false, name=""},
    {newStyle = true, name=""},
    ]]
}

local AndroidBackUIMap = {}

local function CheckAndRemoveHiddenUI()
    if #UI_HiddenInstances > MAX_HIDDEN_COUNT then
        local name = table.remove(UI_HiddenInstances, 1)
        local config = moduleToConfig[name]
        M.CloseUI(config)
    end

    --print("IsNeedClearHiddenUI:", Client.IsNeedClearHiddenUI(GameFrontendHUD))
    if Client.IsNeedClearHiddenUI(GameFrontendHUD) then
        while #UI_HiddenInstances > MIN_HIDDEN_COUNT do
            local name = table.remove(UI_HiddenInstances, 1)
            local config = moduleToConfig[name]
            M.CloseUI(config)
        end
    end
end

local function OnWidgetShow(className)
    require("client.umg.bp_lobby")
    if AndroidBackUIMap[className] or not _ValidPopUI[className] then
        return
    end

    table.insert(AndroidBackUIStack, {newStyle = false, name = className})
    AndroidBackUIMap[className] = true

    CheckAndRemoveHiddenUI()
end

local function OnUIOrWidgetHide(name)
    if not AndroidBackUIMap[name] then
        return
    end

    local len = #AndroidBackUIStack
    for i = len, 1, -1 do
        local v = AndroidBackUIStack[i]
        if v.name == name then
            table.remove(AndroidBackUIStack, i)
            AndroidBackUIMap[name] = nil
            return
        end
    end
end

local function OnWidgetHide(className)
    OnUIOrWidgetHide(className)
end

local function FindHiddenUIByName(name)
    for i, v in pairs(UI_HiddenInstances) do
        if v == name then
            return i
        end
    end
end

local function OnUIShow(name)
    if AndroidBackUIMap[name] then
        return
    end

    local config = moduleToConfig[name]
    if config and (not (config.isAndroidBack == false)) then
        table.insert(AndroidBackUIStack, {newStyle = true, name = name})
        AndroidBackUIMap[name] = true
    end

    local index = FindHiddenUIByName(name)
    if index then
        table.remove(UI_HiddenInstances, index)
    end

    CheckAndRemoveHiddenUI()
end

local function OnUIHide(name)
    OnUIOrWidgetHide(name)

    if UI_Instances[name] and not FindHiddenUIByName(name) then
        table.insert(UI_HiddenInstances, name)
    end
end

function M.ShowUI(config, ...)
    local ui = nil
    assert(config ~= nil)
    local name = config.moduleName

    if config.isWindowsOBHide and GetWindowOBState() then
        print("Do not show UI in Windows OB: "..name)
        return
    end

    print("Open slua ui: "..name)
    if not (config.isSingleton == false) then
        -- 判断单例ui是否已经存在
        ui = UI_Instances[name]
        if not ui then
            local BusinessHelper = import("BusinessHelper")
            local uiStatName = config.keyName
            if config.uiStat then
                uiStatName = config.uiStat.name
            end
            if uiStatName then
                BusinessHelper.StartUIStat(uiStatName)
            end

            local UIClass = require(UI_Source_Path..name)
            ui = UIClass(...)
            ui:Init(config.path, config.containerName or DefaultContainerName, config.zOrder or 0)

            UI_Instances[name] = ui

            if uiStatName then
                BusinessHelper.StopUIStat(uiStatName, true)
            end
        end

        OnUIShow(name)
    else
        -- 非单例ui每次Show都创建
        local UIClass = require(UI_Source_Path..name)
        ui = UIClass(...)
        ui:Init(config.path, config.containerName or DefaultContainerName, config.zOrder or 0)
    end

    local UIManager = require("client.common.uibase.uimanager")
    UIManager.ShowSluaUI(config.UIType, ui.UIRoot)

    ui:SetVisibility(config.showVisibility or DefaultShowVisibility)

    return ui -- 不推荐在其他地方持有ui实例，尽量用local变量引用它（也不能在模块的local中引用）
end

function M.AndriodBack(config)
    assert(config ~= nil)
    local name = config.moduleName
    print("AndriodBack slua ui: "..name)
    local ui = UI_Instances[name]
    if ui then
        if ui.AndriodBack then
            ui:AndriodBack()
        else
            M.HideUI(config)
        end
    end
end

function M.HideUI(config)
    assert(config ~= nil)
    local name = config.moduleName
    print("Hide slua ui: "..name)
    local ui = UI_Instances[name]
    if ui then
        if not (config.closeOnHide == false) then
            M.CloseUI(config)
        else
            ui:SetVisibility(config.hideVisibility or DefaultHideVisibility)
            OnUIHide(name)
        end
    end
end

function M.CloseUI(config)
    assert(config ~= nil)
    local name = config.moduleName
    print("Close slua ui: "..name)
    local ui = UI_Instances[name]
    if ui then
        ui:Close()
        UI_Instances[name] = nil

        OnUIHide(name)

        local index = FindHiddenUIByName(name)
        if index then
            table.remove(UI_HiddenInstances, index)
        end
    end
    UIManager.HideSluaUI(config.UIType)
end

function M.ClearUIStack()
    AndroidBackUIStack = {}
    AndroidBackUIMap = {}
end

-- 不推荐在其他地方持有ui实例，尽量用local变量引用它
function M.GetUI(config)
    assert(config ~= nil)
    local name = config.moduleName
    local ui = UI_Instances[name]
    return ui
end

function M.IsUIShow(config)
    local ui = M.GetUI(config)
    if ui then
        return ui:IsShow()
    end

    return false
end

function M.GetCurrentOpenedUI()
    local lastIdx = #AndroidBackUIStack
    if lastIdx > 0 then
        return AndroidBackUIStack[lastIdx].name
    end

    return ""
end

function M._InitUITypeMap()
    local uicontroller = require("client.common.uibase.uicontroller")
    uicontroller.Init()

    local uiTypeMap = uicontroller.uiTypeMap
    local index = 0
    moduleToConfig = {}
    for name, config in pairs(M.UI_Config) do
        index = index + 1
        local uiEnumType = UI_TYPE_START_NUM + index
        eUIType[name] = uiEnumType

        local moduleName = config.moduleName
        table.insert(uiTypeMap, {UIType = uiEnumType; ui = moduleName; uiNum = 1; BModule = true; depth = 100; bShow = false;})
        config.UIType = uiEnumType
        assert(moduleToConfig[moduleName] == nil, string.format("Duplicate module name[%s]!", moduleName))
        config.keyName = name
        moduleToConfig[moduleName] = config
    end
end

local function OnAndroidBack()
    local uiInfo = AndroidBackUIStack[#AndroidBackUIStack]

    if uiInfo then
        if uiInfo.newStyle then
            local config = moduleToConfig[uiInfo.name]
            M.AndriodBack(config)
        else
            require("client.umg.bp_lobby")
            local closeFunc = _ValidPopUI[uiInfo.name]
            closeFunc()
        end
    else
        require("client.umg.bp_global")
        EventAndroidQuitGame();
    end
end

local UAEUserWidget = import("UAEUserWidget")
local OnWidgetShowDelegate = slua.createDelegate(OnWidgetShow)
local OnWidgetHideDelegate = slua.createDelegate(OnWidgetHide)
local OnClearUIStackDelegate = slua.createDelegate(M.ClearUIStack)
UAEUserWidget.SetOnWidgetShow(OnWidgetShowDelegate)
UAEUserWidget.SetOnWidgetHide(OnWidgetHideDelegate)
UAEUserWidget.SetOnClearUIStack(OnClearUIStackDelegate)

-- hold delegates prevent gc
M._delegates = {}
table.insert(M._delegates, OnWidgetShowDelegate)
table.insert(M._delegates, OnWidgetHideDelegate)
table.insert(M._delegates, OnClearUIStackDelegate)

require("client.common.event.event_system")
EventSystem:registEvent(EVENTTYPE_LOBBY, EVENTID_ANDROID_BACK, OnAndroidBack)

InitConfig()

local game_frontend_hud = require("game_frontend_hud")
game_frontend_hud.SetGameStatusListener(OnUIModeSwitch)

return M