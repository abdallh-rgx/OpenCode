local M = {}

local LuaScrollBox ={}

function LuaScrollBox:ctor()
    self.OnRefreshItemEvent = nil
    
    self.itemWidgetIndexMap = {}
    self.itemEvents = {}
    self.itemWidgetDelegates = {}
    
    self._data = {}
    
    self._selectIndex = 0
    self.started = false
end

function LuaScrollBox:RegistEvents()
    LuaScrollBox.__super.RegistEvents(self)
    
    self:AddControlEvent("", "OnRefreshItem", self._OnRefreshItem, self)
    self:AddControlEvent("", "OnItemCreated", self._OnItemCreated, self)
end

function LuaScrollBox:UnRegistEvents()
    --todo: 在这里反注册事件
    
    LuaScrollBox.__super.UnRegistEvents(self)
end

function LuaScrollBox:OnInitialize()
    LuaScrollBox.__super.OnInitialize(self)
    
    self.UIRoot.OnUserScrolled:Add(function (offset)
        self:UserScrolled(offset)
    end)
end

function LuaScrollBox:AddItemEvent(controlName, eventName, handleFunc, ...)
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

function LuaScrollBox:_OnRefreshItem(widget, index)
    -- c++与lua下标起始不一样
    index = index + 1
    self.itemWidgetIndexMap[widget] = index
    
    local func = self.OnRefreshItemEvent
    if func then
        func(widget, index)
    end
end

function LuaScrollBox:_OnItemCreated(widget, index)
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

function LuaScrollBox:SetRefreshItemCallback(callback, ...)
    local args = table.pack(...)
    local common = require("ui.common")
    self.OnRefreshItemEvent = function (...)
        common.CallCombinationArgs(callback, args, ...)
    end
end

function LuaScrollBox:_ClearEvents()
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

function LuaScrollBox:Close()
    --todo: 这里做些消耗回收动作，注意UI_LoopScrollBox.__super.Close(self)一定要写在最后，遵循先进后出原则
    self.UIRoot.OnUserScrolled:Clear() 
    self:_ClearEvents()
    self._data = {}

    LuaScrollBox.__super.Close(self)
end

function LuaScrollBox:SetData(arrayData)
    assert(self.OnRefreshItemEvent ~= nil, "Must set call UI_LoopScrollBox:SetRefreshItemCallback before InitData!")
    self._data = arrayData
    self._selectIndex = 0
    self:ScrollToItem(1)
    --self.UIRoot:SetItemCount(#arrayData)
    self:SetItemCount(#arrayData)
end

function LuaScrollBox:GetItemCount()
    return #self._data
end

function LuaScrollBox:GetItemData(index)
    assert(index > 0)
    return self._data[index]
end

function LuaScrollBox:AppendItem(itemData)
    table.insert(self._data, itemData)
    
    local index = #self._data
    -- c++与lua下标起始不一样
    --self.UIRoot:InsertItem(index - 1)
    self:_InsertItem(index - 1)
end

function LuaScrollBox:InsertItem(index, itemData)
    assert(index > 0)
    table.insert(self._data, index, itemData)
    
    if self._selectIndex ~= 0 and self._selectIndex >= index then
        self._selectIndex = self._selectIndex + 1
    end
    
    -- c++与lua下标起始不一样
    --self.UIRoot:InsertItem(index - 1)
    self:_InsertItem(index - 1)
end

function LuaScrollBox:RemoveItem(index)
    assert(index > 0 and index <= #self._data, string.format("index[%d] out of range[1..%d]", index, #self._data))
    table.remove(self._data, index)
    
    if self._selectIndex == index then
        self._selectIndex = 0
    end
    if self._selectIndex ~= 0 and self._selectIndex > index then
        self._selectIndex = self._selectIndex - 1
    end
    
    -- c++与lua下标起始不一样
    --self.UIRoot:RemoveItem(index - 1)
    self:_RemoveItem(index - 1)
end

function LuaScrollBox:RefreshItem(index, itemData)
    assert(index > 0 and #self._data >= index)
    self._data[index] = itemData
    -- c++与lua下标起始不一样
    self.UIRoot:RefreshItem(index - 1)
end

function LuaScrollBox:RefreshAllItems(newData)
    if newData then
        assert(#self._data == #newData)
        self._data = newData
    end
    self.UIRoot:RefreshAllItems()
end

function LuaScrollBox:ScrollToItem(Index)
    assert(Index > 0)
    -- c++与lua下标起始不一样
    --self.UIRoot:ScrollToItem(index - 1)
    Index = Index - 1
    
    if not self.UIRoot.bViewSizeInit then
        self.UIRoot.ScrollToIndex = Index
        return
    end
    
    local Offset = 0
    if Index > 0 then
        Offset = self.UIRoot:GetItemOffset(Index)
    end
    local ContantSize = self.UIRoot:GetContentSize(self.UIRoot.ItemCount)
    local CurrentViewSize = self.UIRoot:GetViewSize()
    
    local ViewOffset = 0
    if self.UIRoot.Orientation == UEnums.EOrientation.Orient_Vertical then
		ViewOffset = CurrentViewSize.Y
	else
		ViewOffset = CurrentViewSize.X;
	end
    local function Clamp(t, min, max)
        if t < min then
            return min
        elseif t > max then
            return max
        else
            return t
        end
    end
    local math = require("math")
    Offset = Clamp(Offset, 0, math.max(ContantSize - ViewOffset, 0))
    self.UIRoot:SetScrollOffset(Offset)
    self:UserScrolled(Offset)
end

function LuaScrollBox:Select(index)
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

function LuaScrollBox:Deselect()
    if self._selectIndex > 0 then
        local preSelectIndex = self._selectIndex
        self._selectIndex = 0
        self.UIRoot:RefreshItem(preSelectIndex - 1)
    end
end

function LuaScrollBox:GetSelectIndex()
    return self._selectIndex
end

--[[
CPP implement
]]
function LuaScrollBox:OnStart()
    self.started = true

    local Count = self.UIRoot.ItemCount
    self.UIRoot.ItemCount = 0
    
    self:SetItemCount(Count)
end

function LuaScrollBox:UserScrolled(CurrentOffset)
    if not self.started and self.UIRoot.bViewSizeInit then
        self:OnStart()
        return
    end
    
    local preStartIndex = self.UIRoot.ItemStartIndex
    local preEndIndex = self.UIRoot.ItemEndIndex
    
    local ItemStartIndex, ItemEndIndex = self.UIRoot:GetBeginEndIndex(CurrentOffset, 0, 0)
    self.UIRoot.ItemStartIndex, self.UIRoot.ItemEndIndex = ItemStartIndex, ItemEndIndex
    
    local math = require("math")
    -- 回收头部Item
    for i = preStartIndex, math.min(ItemStartIndex, preEndIndex + 1) - 1 do
        self.UIRoot:ReleaseItem(i)
    end
    
    -- 回收尾部Item
    for  i = math.max(ItemEndIndex + 1, preStartIndex), preEndIndex do
        self.UIRoot:ReleaseItem(i)
    end
    
    -- 刷新头部Item
    for i = math.max(ItemStartIndex, 0), math.min(preStartIndex, ItemEndIndex + 1) - 1 do
        self.UIRoot:RequireOneWidget(i)
    end
    
    -- 刷新尾部Item
    for i = math.max(preEndIndex + 1, ItemStartIndex), math.min(ItemEndIndex + 1, self.UIRoot.ItemCount) - 1 do
        self.UIRoot:RequireOneWidget(i)
    end
end

function LuaScrollBox:SetItemCount(Count)
    local PreItemCount = self.UIRoot.ItemCount
    self.UIRoot.ItemCount = Count
    
    if not self.UIRoot:UpdateContentSize(self.UIRoot.ItemCount) then
        return false
    end
    
    local Offset = self.UIRoot:GetScrollOffset()
    print("LuaScrollBox:SetItemCount", Offset)
    local ItemStartIndex, ItemEndIndex = self.UIRoot:GetBeginEndIndex(Offset, 0, 0)
    self.UIRoot.ItemStartIndex, self.UIRoot.ItemEndIndex = ItemStartIndex, ItemEndIndex
    
    local DeltaCount = Count - PreItemCount
    local math = require("math")
    if DeltaCount > 0 then
        local Start = math.max(PreItemCount, ItemStartIndex)
        local End = math.min(Count, ItemEndIndex + 1)
        
        for i = Start, End - 1 do
            self.UIRoot:RequireOneWidget(i)
        end
        
        for i = ItemStartIndex, Start - 1 do
            self.UIRoot:RefreshItem(i)
        end
    else
        local Start = math.max(Count, ItemEndIndex + 1)
        local End = math.min(PreItemCount, self.UIRoot.CurrentItems:Num())
        
        for i = Start, End - 1 do
            self.UIRoot:ReleaseItem(i)
        end
        
        -- 刷新Item
		for i = ItemStartIndex, ItemEndIndex do
			self.UIRoot:RefreshItem(i)
		end
    end
    
    return true
end

function LuaScrollBox:_InsertItem(Index)
    assert(Index <= self.UIRoot.ItemCount)
    self.UIRoot.ItemCount = self.UIRoot.ItemCount + 1
    if not self.UIRoot:UpdateContentSize(self.UIRoot.ItemCount) then
        return
    end
    
    local ItemStartIndex, ItemEndIndex = self.UIRoot:GetBeginEndIndex(self.UIRoot:GetScrollOffset(), 0, 0)
    self.UIRoot.ItemStartIndex, self.UIRoot.ItemEndIndex = ItemStartIndex, ItemEndIndex
    local Count = self.UIRoot.ItemCount
    local PreItemCount = Count - 1
    local math = require("math")
    local Start = math.max(PreItemCount, ItemStartIndex)
    local End = math.min(Count, ItemEndIndex + 1)
    for i = Start, End - 1 do
        self.UIRoot:RequireOneWidget(i)
    end
    local BeginIndex = ItemStartIndex
    local EndIndex = ItemEndIndex
    for i = math.max(Index, BeginIndex), math.min(EndIndex + 1, Start) - 1 do
        self.UIRoot:RefreshItem(i)
    end
end

function LuaScrollBox:_RemoveItem(Index)
    local ItemCount = self.UIRoot.ItemCount
    assert(Index < ItemCount)
    ItemCount = ItemCount - 1
    self.UIRoot.ItemCount = ItemCount
    if not self.UIRoot:UpdateContentSize(ItemCount) then
        return
    end
    local ContantSize = self.UIRoot:GetContentSize(ItemCount)
    local CurrentViewSize = self.UIRoot:GetViewSize()
    local ViewOffset = 0
    if self.UIRoot.Orientation == UEnums.EOrientation.Orient_Vertical then
		ViewOffset = CurrentViewSize.Y
	else
		ViewOffset = CurrentViewSize.X;
	end
    local ScrollOffset = self.UIRoot:GetScrollOffset()
    if ScrollOffset > ContantSize - ViewOffset then
        local BeginIndex, EndIndex = self.UIRoot:GetBeginEndIndex(ScrollOffset, 0, 0)
		self:ScrollToItem(BeginIndex + 1)
    end
    
    local BeginIndex, EndIndex = self.UIRoot:GetBeginEndIndex(self.UIRoot:GetScrollOffset(), 0, 0)
    self.UIRoot.ItemStartIndex, self.UIRoot.ItemEndIndex = BeginIndex, EndIndex
    local math = require("math")
    for i = math.max(Index, BeginIndex), EndIndex do
        self.UIRoot:RefreshItem(i)
    end
end

local class = require("class")
local ui_base = require("ui.base")
local CLuaScrollBox = class(ui_base, nil, LuaScrollBox)

return CLuaScrollBox