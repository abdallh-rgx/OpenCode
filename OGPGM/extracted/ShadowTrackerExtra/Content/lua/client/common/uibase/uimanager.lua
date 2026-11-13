

--sami UI面板管理器
UIManager = UIManager or 
{
    uiMap = {};
    uiShowStack = {};
    uiHandlerMap = {};
    uiStatusStack = {}; --UI快照 
}
--[[

uiStatusStack = 
{
  {
    triggerUIType = eUIType.eWarZoneRankUI --触发的UIType, 
    Data = 
    {
        {UIType = eUIType.eWarZoneRankUI, IsOnlyShow = false}, --状态
        {UIType = eUIType.eWarZoneRankUI2, IsOnlyShow = false} --状态  
    }
  },
  {
    triggerUIType = eUIType.eWarZoneRankUI2 --触发的UIType, 
    Data = 
    {
        {UIType = eUIType.eWarZoneRankUI, IsOnlyShow = false}, --状态
        {UIType = eUIType.eWarZoneRankUI2, IsOnlyShow = false} --状态  
    }
  }
}

]]

--sami 初始化
function UIManager.Init()
    log("UIManager.Init()")
    
    UIManager.uiMap = {}
    UIManager.uiShowStack = XList.Alloc();
    UIManager.uiHandlerMap = {};
    
    local ui_manager = require("ui.manager")
    ui_manager._InitUITypeMap()
    
    for k,v in pairs(UIController.uiTypeMap) do
        UIManager.RegisterUI(v)
    end
end

--注册UI
function UIManager.RegisterUI(uiInfo)
    UIManager.uiHandlerMap[uiInfo.UIType] = uiInfo
end

--增加UI
function UIManager.AddUI(uiInfo)
    if uiInfo.UIType == eUIType.None or UIManager.uiMap[uiInfo.UIType] ~= nil then
        return
    end
    UIManager.uiMap[uiInfo.UIType] = uiInfo
end

--移除UI
function UIManager.RemoveUI(uiInfo)
    if uiInfo.UIType == eUIType.None or UIManager.uiMap[uiInfo.UIType] == nil then
        return
    end
    UIManager.uiMap[uiInfo.UIType] = nil
end

--获取UI
function UIManager.GetUI(uiType)
    if uiType == eUIType.None or UIManager.uiMap[uiType] == nil then
        return nil
    end
    return UIManager.uiMap[uiType]
end

--从显示栈移除ui
function UIManager.RemoveUIFromStack(uiInfo)
    if uiInfo.UIType == eUIType.None then
        return
    end
    
    local len = XList.Len(UIManager.uiShowStack)
    for index = len, 1, -1 do
        if UIManager.uiShowStack[index] == uiInfo then
            XList.Remove(UIManager.uiShowStack, index)
            break
        end
    end
end

--改变所有提供ChangeIsOnlyShow接口的UI状态
--此调用会执行UIManager.Show中的所有界面
function UIManager.ChangeIsOnlyShow(IsOnlyShow)
    local topStatus = UIManager.uiStatusStack[#UIManager.uiStatusStack]
    if topStatus == nil then
        return
    end
    
    for i, data in ipairs(topStatus.status) do
        local ui = UIManager.GetUI(data.UIType)
        if ui and ui.uiClass and ui.uiClass.ChangeIsOnlyShow then
            ui.uiClass.ChangeIsOnlyShow(IsOnlyShow)
        end
    end
end

function UIManager.PushStatus(triggerUIType) -- 压入快照
    log("RecoverStatus:topStatus.triggerUIType:" .. tostring(triggerUIType))

    local allStatus = {}
    allStatus.triggerUIType = triggerUIType
    allStatus.status = {}
    for i, info in ipairs(UIManager.uiShowStack) do
        if info.uiClass and info.uiClass.GetStatus then
            local uiStatus = info.uiClass.GetStatus()
            uiStatus.UIType = info.UIType
            table.insert(allStatus.status, uiStatus)
        end
    end 
    table.insert(UIManager.uiStatusStack, allStatus)
end

function UIManager.RecoverStatus(triggerUIType) -- 恢复快照
    local topStatus = UIManager.uiStatusStack[#UIManager.uiStatusStack]
    if topStatus == nil then
        return
    end

    log("RecoverStatus:topStatus.triggerUIType:" .. tostring(topStatus.triggerUIType) .. ",RecoverStatus:" .. tostring(triggerUIType))

    if topStatus.triggerUIType ~= triggerUIType then
        log("RecoverStatus:different")
    end

    for i, data in ipairs(topStatus.status) do
        local ui = UIManager.GetUI(data.UIType)
        if ui and ui.uiClass and ui.uiClass.RecoverStatus then
            ui.uiClass.RecoverStatus(data)
        end
    end
end

--处理UI显示
function UIManager.OnShowUI(uiInfo, sLuaUI)
    log("UIManager.OnShowUI uiType="..uiInfo.UIType)
    local ui = UIManager.GetUI(uiInfo.UIType)
    if ui ~= nil then
        return
    end
    UIManager.AddUI(uiInfo)
    
    if uiInfo.BModule == true then
        UIManager.RemoveUIFromStack(uiInfo)
        UIManager.AutoPanelDepth(uiInfo, sLuaUI)
        XList.Add(UIManager.uiShowStack, uiInfo)

        local num = XList.Len(UIManager.uiShowStack)
        log("UIManager.OnShowUI UIManager.uiShowStack len = "..num)
        for index = 1, num, 1 do
            log("UIManager.OnShowUI for each depth = "..UIManager.uiShowStack[index].depth)
        end
    else
        --do none
    end
end

--处理UI关闭
function UIManager.OnHideUI(uiInfo)
    log("UIManager.OnHideUI uiType="..uiInfo.UIType)
    local ui = UIManager.GetUI(uiInfo.UIType)
    if ui == nil then
        return
    end
    UIManager.RemoveUI(uiInfo);

    --非模态界面，直接删除
    if uiInfo.BModule == false then
        --do none
    else
        UIManager.RemoveUIFromStack(uiInfo)
    end

    local num = XList.Len(UIManager.uiShowStack)
    log("UIManager.OnHideUI UIManager.uiShowStack len = "..num)
    for index = 1, num, 1 do
        log("UIManager.OnHideUI for each depth = "..UIManager.uiShowStack[index].depth)
    end
end

--获取顶层UI
function UIManager.GetTopUI()
    local num = XList.Len(UIManager.uiShowStack)
    if num <= 0 then
        return nil;
    end
    return UIManager.uiShowStack[num - 1]
end

--调整UI层级
function UIManager.AutoPanelDepth(uiInfo, sLuaUI)
    local depth = 100
    local num = XList.Len(UIManager.uiShowStack)
    
    if num > 0 then
        depth = UIManager.uiShowStack[num].depth + 100
    end
    log("UIManager.AutoPanelDepth depth = "..depth)
    uiInfo.depth = depth

    if type(uiInfo.ui)=="string" then
        if sLuaUI then
            local slot = sLuaUI.Slot
            if slot == nil then
                return
            end
            slot:SetZOrder(depth)
        end
    else
        for i = 0, uiInfo.uiNum -1, 1 do
            LuaClassObj.SetWidgetZorder(uiInfo.ui, i, depth + i * 10)
        end
    end
end

--显示UI
function UIManager.Show(uiType, sLuaUI)
    if uiType == nil then
        --log(debug.traceback())
        return
    end
    log("UIManager.Show uiType="..uiType)
    local uiInfo = UIManager.uiHandlerMap[uiType]
    if uiInfo == nil then
        return
    end
    if uiInfo.bShow then
        UIManager.RemoveUIFromStack(uiInfo)
        UIManager.AutoPanelDepth(uiInfo, sLuaUI)
        XList.Add(UIManager.uiShowStack, uiInfo)
        return
    end
    uiInfo.bShow = true
    UIManager.OnShowUI(uiInfo, sLuaUI);
end

function UIManager.ShowSluaUI(uiType, sLuaUI)
    UIManager.Show(uiType, sLuaUI)
end

--关闭UI
function UIManager.Hide(uiType)
    if uiType == nil then
        --log(debug.traceback())
        return
    end
    log("UIManager.Hide uiType="..uiType)
    local uiInfo = UIManager.uiHandlerMap[uiType]
    if uiInfo == nil then
        return
    end
    if uiInfo.bShow == false then
        return
    end
    uiInfo.bShow = false
    UIManager.OnHideUI(uiInfo);
end

function UIManager.HideSluaUI(uiType)
    UIManager.Hide(uiType)
end

return UIManager