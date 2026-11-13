local UIBase = {}

function UIBase:ctor(selfType, ...)
	self.UIRoot = false
	self.closed = false
	
    self.childWindows = {}
    self.onCloseEvent = false
    self.containerName = ""
    
    self._controlEvents = {}
    self._commonEvents = {}

    self._times = {}
    
	self._isShow = false
end

function UIBase:Init(path, containerName, zOrder)
    print("UIBase:Init")
    assert(type(path) == "string" and type(containerName) == "string" and type(zOrder) == "number")
    self.UIRoot = slua.loadUI(path)
    self.containerName = containerName
    
    if containerName ~= "" then
        local game_frontend_hud = require "game_frontend_hud"
        game_frontend_hud.AddToContainer(containerName, self.UIRoot, zOrder)
    end

    self:OnInitialize()
    self:RegistEvents()
    self:OnPostInitialize()
end

function UIBase:OnInitialize()
end

function UIBase:RegistEvents()
end

function UIBase:UnRegistEvents()
    for name, events in pairs(self._controlEvents) do
        local control = self:GetControlByName(name)
        for eventName, delegate in pairs(events) do
            control[eventName]:Clear()
        end
        self._controlEvents[name] = nil
    end

    require("client.common.event.event_system")
    for eventType, events in pairs(self._commonEvents) do
        for eventID, eventFunc in pairs(events) do
            EventSystem:unregistEvent(eventType, eventID, eventFunc)
        end
        self._commonEvents[eventType] = nil
    end
end

function UIBase:OnPostInitialize()
end

-- 专门给UI蓝图嵌套子UI蓝图的情况使用
function UIBase:InitWithParentWidget(parentWindow, widget)
    self.UIRoot = widget
    
    self:OnInitialize()
    self:RegistEvents()
    self:OnPostInitialize()
    
    parentWindow:AddChildWindow(self)
end

function UIBase:InitScrollBox(widget)
    local CLoopScrollBox = require("ui.component.loop_scroll_box")
    local subWindow = CLoopScrollBox()
    subWindow:InitWithParentWidget(self, widget)
    return subWindow
end

function UIBase:GetControlByName(name, root)
    local control = root
    if not control then
        control = self.UIRoot
    end
    if name ~= "" then
        if string.find(name, ".") ~= -1 then
            string.gsub(name, "([^.]*)", function (c)
                control = control[c]
            end)
        else
            control = self.UIRoot[name]
        end
    end
    return control
end

function UIBase:AddOnClickedEvent(controlName, handleFunc, ...)
    return self:AddControlEvent(controlName, "OnClicked", handleFunc, ...)
end

function UIBase:RemoveOnClickedEvent(controlName)
    return self:RemoveControlEvent(controlName, "OnClicked")
end

function UIBase:AddOnPressedEvent(controlName, handleFunc, ...)
    return self:AddControlEvent(controlName, "OnPressed", handleFunc, ...)
end

function UIBase:RemoveOnPressedEvent(controlName)
    return self:RemoveControlEvent(controlName, "OnPressed")
end

function UIBase:AddOnReleasedEvent(controlName, handleFunc, ...)
    return self:AddControlEvent(controlName, "OnReleased", handleFunc, ...)
end

function UIBase:RemoveOnReleasedEvent(controlName)
    return self:RemoveControlEvent(controlName, "OnReleased")
end

function UIBase:AddOnCheckStateChangedEvent(controlName, handleFunc, ...)
    return self:AddControlEvent(controlName, "OnCheckStateChanged", handleFunc, ...)
end

function UIBase:RemoveOnCheckStateChangedEvent(controlName)
    return self:RemoveControlEvent(controlName, "OnCheckStateChanged")
end

function UIBase:AddOnTextChangedEvent(controlName, handleFunc, ...)
    return self:AddControlEvent(controlName, "OnTextChanged", handleFunc, ...)
end

function UIBase:RemoveOnTextChangedEvent(controlName)
    return self:RemoveControlEvent(controlName, "OnTextChanged")
end

function UIBase:AddControlEvent(controlName, eventName, handleFunc, ...)
    local control = self:GetControlByName(controlName)
    assert(control, string.format("找不到名字为[%s]的控件", controlName))
    local eventDelegate = control[eventName]
    assert(eventDelegate, string.format("控件[%s]找不到名字为[%s]的事件", controlName, eventName))
    local controlEvents = self._controlEvents[controlName]
    if not controlEvents then
        controlEvents = {}
        self._controlEvents[controlName] = controlEvents
    end
    local funcDelegate = controlEvents[eventName]
    if funcDelegate then
        if eventDelegate.Remove then
            eventDelegate:Remove(funcDelegate)
        else
            eventDelegate:Clear()
        end
    end

    local common = require("ui.common")
    local args = table.pack(...)
    if eventDelegate.Add then
        controlEvents[eventName] = eventDelegate:Add(function (...)
            common.CallCombinationArgs(handleFunc, args, ...)
        end)
    else
        controlEvents[eventName] = eventDelegate:Bind(function (...)
            common.CallCombinationArgs(handleFunc, args, ...)
        end)
    end

    return true
end

function UIBase:RemoveControlEvent(controlName, eventName)
    local control = self:GetControlByName(controlName)
    local eventDelegate = control[eventName]
    
    local controlEvents = self._controlEvents[controlName]
    local onClickedDelegate = controlEvents[eventName]
    if onClickedDelegate then
        if eventDelegate.Remove then
            eventDelegate:Remove(onClickedDelegate)
        else
            eventDelegate:Clear()
        end
        controlEvents[eventName] = nil
        return true
    end

    return false
end

function UIBase:AddCommonEvent(eventType, eventID, handleFunc, ...)
    assert(type(eventType) == "number" and type(eventID) == "number" and type(handleFunc) == "function")
    local events = self._commonEvents[eventType]
    if not events then
        events = {}
        self._commonEvents[eventType] = events
    end

    require("client.common.event.event_system")
    local eventFunc = events[eventID]
    if eventFunc then
        EventSystem:unregistEvent(eventType, eventID, eventFunc)
    end

    local common = require("ui.common")
    local args = table.pack(...)
    local FuncWrap = function(...)
        common.CallCombinationArgs(handleFunc, args, ...)
    end
    events[eventID] = FuncWrap
    return EventSystem:registEvent(eventType, eventID, FuncWrap)
end

function UIBase:RemoveCommonEvent(eventType, eventID)
    assert(type(eventType) == "number" and type(eventID) == "number")
    local events = self._commonEvents[eventType]
    if not events then
        log_error(string.format("Can't remove event because eventType's[%s] events not found", eventType))
        return
    end

    local eventFunc = events[eventID]
    if not eventFunc then
        log_error(string.format("Can't remove event because event not found for eventType[%s], eventID[%s]", eventType, eventID))
        return
    end
    require("client.common.event.event_system")
    return EventSystem:unregistEvent(eventType, eventID, eventFunc)
end

function UIBase:AddTimer(delay, func)
    local time_ticker = require("client.time_ticker")
    local handle = time_ticker.AddTimer(delay, func)
    self._times[handle] = true
    return handle
end

function UIBase:RemoveTimer(handle)
    local time_ticker = require("client.time_ticker")
    time_ticker.RemoveTimer(handle)
    self._times[handle] = nil
    return true
end

function UIBase:RemoveAllTimer()
    local time_ticker = require("client.time_ticker")
    for handle, _ in pairs(self._times) do
        time_ticker.RemoveTimer(handle)
        self._times[handle] = nil
    end
end

-- visiblility's function
function UIBase:Show()
	self:SetVisibility(UEnums.ESlateVisibility.Visible)
end

function UIBase:Hide()
	self:SetVisibility(UEnums.ESlateVisibility.Hidden)
end

function UIBase:Collapsed()
    self:SetVisibility(UEnums.ESlateVisibility.Collapsed)
end

function UIBase:HitTestInvisible()
    self:SetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
end

function UIBase:SelfHitTestInvisible()
    self:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
end

function UIBase:GetVisibility()
    return self.UIRoot:GetVisibility()
end

function UIBase:SetVisibility(InVisibility)
	self.UIRoot:SetVisibility(InVisibility)
    local ESlateVisibility = UEnums.ESlateVisibility

    local isShow = (InVisibility == ESlateVisibility.Visible or
                    InVisibility == ESlateVisibility.HitTestInvisible or
                    InVisibility == ESlateVisibility.SelfHitTestInvisible)
    self:_UpdateShow(isShow)
end

function UIBase:_UpdateShow(isShow)
    if self._isShow ~= isShow then
        self._isShow = isShow
        if isShow then
            self:OnShow()
        else
            self:OnHide()
        end
    end
end

function UIBase:IsShow()
    return self._isShow
end

function UIBase:OnShow()

end

function UIBase:OnHide()

end

function UIBase:SetWidgetVisible(widget, visible, isButton)

    if type(widget) == "string" then
        widget = self:GetControlByName(widget)
    end

    if widget == nil then
        assert(widget == nil, "widget == nil")
        return
    end

    assert(self.UIRoot ~= widget, "Not allow set UIRoot's visibility by call UIBase:SetWidgetVisible")
    if visible then
        if isButton then
            widget:SetVisibility(UEnums.ESlateVisibility.Visible)
        else
            widget:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        end
    else
        widget:SetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
end

-- Anchors/Offsets etc.
function UIBase:SetAnchors(minX, minY, maxX, maxY)
    assert(self.UIRoot ~= nil, "Must load ui before call SetAnchors")
    local anchors = FAnchors(minX, minY, maxX, maxY)
    self.UIRoot.Slot:SetAnchors(anchors)
end

function UIBase:SetOffsets(left, top, right, bottom)
    assert(self.UIRoot ~= nil, "Must load ui before call SetOffsets")
    local margin = FMargin(left, top, right, bottom)
    self.UIRoot.Slot:SetOffsets(margin)
end

-- child window
function UIBase:AttachChildWindow(panelName, childWindow)
	childWindow:_SetCloseEvent(self._OnChildWindowClose, self)
    table.insert(self.childWindows, childWindow)
    
    self.UIRoot[panelName]:AddChild(childWindow.UIRoot)
end

function UIBase:AddChildWindow(childWindow)
    childWindow:_SetCloseEvent(self._OnChildWindowClose, self)
    table.insert(self.childWindows, childWindow)
end

function UIBase:_OnChildWindowClose(childWindow)
	for k, v in pairs(self.childWindows) do
		if v == childWindow then
			table.remove(self.childWindows, k)
			break
		end
	end
end

function UIBase:PlayAudio(audioPath)
    local util = require("ui.util")
    util.PlayAudio(audioPath, self.UIRoot)
end

function UIBase:_SetCloseEvent(func, ...)
	self.onCloseEvent = {func = func, args = table.pack(...)}
end

function UIBase:_ClearCloseEvent()
	self.onCloseEvent = false
end

function UIBase:Close()
	self.closed = true

    self:RemoveAllTimer()
    self:_UpdateShow(false)

	if self.onCloseEvent then
        local common = require("ui.common")
        local args = self.onCloseEvent.args
        common.CallCombinationArgs(self.onCloseEvent.func, args, self)
        self.onCloseEvent = false
	end
	
    if self.UIRoot then
        self:UnRegistEvents()

        local childCount = #self.childWindows
        for i = childCount, 1, -1 do
            self.childWindows[i]:_ClearCloseEvent()
			self.childWindows[i]:Close()
		end
        self.childWindows = {}
        
        local containerName = self.containerName
        if containerName ~= "" then
            local game_frontend_hud = require "game_frontend_hud"
            game_frontend_hud.RemoveFromContainer(containerName, self.UIRoot)
        end

        self.UIRoot:ConditionalBeginDestroy()
        self.UIRoot = false
	end
end

local class = require("class")
local object = require("object")
local CUIBase = class(object, nil, UIBase)

return CUIBase