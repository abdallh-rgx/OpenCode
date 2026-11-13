local M = {}

local UI_LoopScrollBox ={}

function UI_LoopScrollBox:ctor()
    self.OnRefreshItemEvent = nil
    
    self.itemWidgetIndexMap = {}
    self.itemEvents = {}
    self.itemWidgetDelegates = {}
    
    self._data = {}
    
    self._selectIndex = 0
end

function UI_LoopScrollBox:RegistEvents()
    UI_LoopScrollBox.__super.RegistEvents(self)
    
    self:AddControlEvent("", "OnRefreshItem", self._OnRefreshItem, self)
    self:AddControlEvent("", "OnItemCreated", self._OnItemCreated, self)
end

function UI_LoopScrollBox:UnRegistEvents()
    --todo: 在这里反注册事件
    
    UI_LoopScrollBox.__super.UnRegistEvents(self)
end

function UI_LoopScrollBox:OnInitialize()
    UI_LoopScrollBox.__super.OnInitialize(self)
end

function UI_LoopScrollBox:SetItemTypeByPath(classPath)
    assert(#self._data == 0, "Must call UI_LoopScrollBox:SetItemTypeByPath before UI_LoopScrollBox:SetData!")
    local itemType = slua.loadClass(classPath)
    self.UIRoot.ItemType = itemType
end

-- 如果是LoopScrollBox，只需传一个参数
-- 如果是LoopScrollGrid，需要传两个参数
function UI_LoopScrollBox:SetItemSize(x, y)
    assert(#self._data == 0, "Must call UI_LoopScrollBox:SetItemSize before UI_LoopScrollBox:SetData!")
    if type(self.UIRoot.ItemSize) == "number" then
        self.UIRoot.ItemSize = x
    else
        self.UIRoot.ItemSize = FVector2(x, y)
    end
end

-- 如果是LoopScrollBox，只需传一个参数
-- 如果是LoopScrollGrid，需要传两个参数
function UI_LoopScrollBox:SetPadding(x, y)
    assert(#self._data == 0, "Must call UI_LoopScrollBox:SetPadding before UI_LoopScrollBox:SetData!")
    if type(self.UIRoot.ItemSize) == "number" then
        self.UIRoot.Padding = x
    else
        self.UIRoot.Padding = FVector2(x, y)
    end
end

function UI_LoopScrollBox:AddItemEvent(controlName, eventName, handleFunc, ...)
    local events = self.itemEvents[controlName]
    if not events then
        events = {}
        self.itemEvents[controlName] = events
    end
    
    local args = table.pack(...)
    local common = require("ui.common")
    events[eventName] = function (...)
        common.CallCombinationArgs(handleFunc, args, ...)
    end
end

function UI_LoopScrollBox:_OnRefreshItem(widget, index)
    -- c++与lua下标起始不一样
    index = index + 1
    self.itemWidgetIndexMap[widget] = index
    
    local func = self.OnRefreshItemEvent
    if func then
        func(widget, index)
    end
end

function UI_LoopScrollBox:_OnItemCreated(widget, index)
    -- c++与lua下标起始不一样
    index = index + 1
    self.itemWidgetIndexMap[widget] = index
    
    local controlEvents = {}
    self.itemWidgetDelegates[widget] = controlEvents
    
    for controlName, events in pairs(self.itemEvents) do
        local control = self:GetControlByName(controlName, widget)
        assert(control ~= nil, string.format("control is nil! controlName：[%s]", controlName))

        for eventName, func in pairs(events) do
            assert(control ~= nil, string.format("control is nil! controlName：[%s] EventName: [%s]", controlName, eventName))
            local eventDelegate = control[eventName]
            assert(eventDelegate ~= nil, string.format("eventDelegate is nil! controlName：[%s] EventName: [%s]", controlName, eventName))
            if eventDelegate.Add then
                local delegate = eventDelegate:Add(function (...)
                    func(widget, self.itemWidgetIndexMap[widget], ...)
                end)
                controlEvents[eventName] = delegate
            else
                local delegate = eventDelegate:Bind(function (...)
                    func(widget, self.itemWidgetIndexMap[widget], ...)
                end)
                controlEvents[eventName] = delegate
            end
        end
    end
end

function UI_LoopScrollBox:SetRefreshItemCallback(callback, ...)
    local args = table.pack(...)
    local common = require("ui.common")
    self.OnRefreshItemEvent = function (...)
        common.CallCombinationArgs(callback, args, ...)
    end
end

function UI_LoopScrollBox:_ClearEvents()
    for widget, controlEvents in pairs(self.itemWidgetDelegates) do
        for controlName, events in pairs(self.itemEvents) do
            local control = self:GetControlByName(controlName, widget)
            for eventName, func in pairs(events) do
                local eventDelegate = control[eventName]
                eventDelegate:Clear()
            end
        end
    end
    
    self.itemWidgetIndexMap = {}
    self.itemEvents = {}
    self.itemWidgetDelegates = {}
    
    self.OnRefreshItemEvent = nil
end

function UI_LoopScrollBox:Close()
    --todo: 这里做些消耗回收动作，注意UI_LoopScrollBox.__super.Close(self)一定要写在最后，遵循先进后出原则
    self:_ClearEvents()
    self._data = {}

    UI_LoopScrollBox.__super.Close(self)
end

function UI_LoopScrollBox:SetData(arrayData)
    assert(self.OnRefreshItemEvent ~= nil, "Must set call UI_LoopScrollBox:SetRefreshItemCallback before InitData!")
    self._data = arrayData
    self._selectIndex = 0
    self:ScrollToItem(1)
    self.UIRoot:SetItemCount(#arrayData)
end

function UI_LoopScrollBox:GetItemCount()
    return #self._data
end

function UI_LoopScrollBox:GetItemData(index)
    assert(index > 0)
    return self._data[index]
end

function UI_LoopScrollBox:AppendItem(itemData)
    table.insert(self._data, itemData)
    
    local index = #self._data
    -- c++与lua下标起始不一样
    self.UIRoot:InsertItem(index - 1)
end

function UI_LoopScrollBox:InsertItem(index, itemData)
    assert(index > 0)
    table.insert(self._data, index, itemData)
    
    if self._selectIndex ~= 0 and self._selectIndex >= index then
        self._selectIndex = self._selectIndex + 1
    end
    
    -- c++与lua下标起始不一样
    self.UIRoot:InsertItem(index - 1)
end

function UI_LoopScrollBox:RemoveItem(index)
    assert(index > 0 and index <= #self._data, string.format("index[%d] out of range[1..%d]", index, #self._data))
    table.remove(self._data, index)
    
    if self._selectIndex == index then
        self._selectIndex = 0
    end
    if self._selectIndex ~= 0 and self._selectIndex > index then
        self._selectIndex = self._selectIndex - 1
    end
    
    -- c++与lua下标起始不一样
    self.UIRoot:RemoveItem(index - 1)
end

function UI_LoopScrollBox:RefreshItem(index, itemData)
    assert(index > 0 and #self._data >= index)
    self._data[index] = itemData
    -- c++与lua下标起始不一样
    self.UIRoot:RefreshItem(index - 1)
end

function UI_LoopScrollBox:RefreshAllItems(newData)
    if newData then
        assert(#self._data == #newData)
        self._data = newData
    end
    self.UIRoot:RefreshAllItems()
end

function UI_LoopScrollBox:ScrollToItem(index)
    assert(index > 0)
    -- c++与lua下标起始不一样
    self.UIRoot:ScrollToItem(index - 1)
end

function UI_LoopScrollBox:Select(index)
    assert(index > 0 and #self._data >= index)
    if self._selectIndex ~= index then
        local preSelectIndex = self._selectIndex
        self._selectIndex = index
        if preSelectIndex > 0 then
            -- 刷新非选中状态
            self.UIRoot:RefreshItem(preSelectIndex - 1)
        end
        self.UIRoot:RefreshItem(index - 1)
    end
end

function UI_LoopScrollBox:Deselect()
    if self._selectIndex > 0 then
        local preSelectIndex = self._selectIndex
        self._selectIndex = 0
        self.UIRoot:RefreshItem(preSelectIndex - 1)
    end
end

function UI_LoopScrollBox:GetSelectIndex()
    return self._selectIndex
end

local class = require("class")
local ui_base = require("ui.base")
local CUILoopScrollBox = class(ui_base, nil, UI_LoopScrollBox)

return CUILoopScrollBox