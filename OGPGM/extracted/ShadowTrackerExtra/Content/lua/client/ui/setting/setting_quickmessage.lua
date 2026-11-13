--[[
    系统设置——快捷语音UI
    create by rainpan 2018/12/11
]]

local UI_Setting_QuickMessage = {}

local Enum_ForSelectMsgType = {
    EnumTactics = 1,
    EnumMarching = 2,
    EnumExchange = 3,
}

local Struct_QuickMsgItemData =
{
    ContentID = 0,
    ActorID = 0,
    IsSelected = false,
    VBtnDelete = UEnums.ESlateVisibility.Hidden,
    VBtnSetContent = UEnums.ESlateVisibility.Hidden,
}



function UI_Setting_QuickMessage:ctor()
    self.SettingConfig = {}
    self.ArraySelectItemList =
    {
        --Struct_QuickMsgItemData = _G.Struct_QuickMsgItemData,
    }
    self.ArrayForSelectItemList =
    {
        --Struct_QuickMsgItemData = _G.Struct_QuickMsgItemData,
    }
end

function UI_Setting_QuickMessage:OnInitialize()
    UI_Setting_QuickMessage.__super.OnInitialize(self)

    self.LSBActor = self:InitScrollBox(self.UIRoot.LSBActor)
    self.LSBSelectMsg = self:InitScrollBox(self.UIRoot.LSBSelectMsg)
    self.LSBForSelectMsg = self:InitScrollBox(self.UIRoot.LSBForSelectMsg)

end

function UI_Setting_QuickMessage:RegistEvents()
    UI_Setting_QuickMessage.__super.RegistEvents(self)

    self.LSBActor:SetRefreshItemCallback(self.OnRefreshActorListItem, self)
    self.LSBActor:AddItemEvent("Button_8", "OnClicked", self.OnSelectActor, self)

    self.LSBSelectMsg:SetRefreshItemCallback(self.OnRefreshSelectListItem, self)
    self.LSBSelectMsg:AddItemEvent("Button_Delete", "OnClicked", self.DeleteSelectedMsg, self)
    self.LSBSelectMsg:AddItemEvent("Btn_SetMsgContent", "OnClicked", self.SetMsgContent, self)
    self.LSBSelectMsg:AddItemEvent("Button_Play", "OnClicked", self.PlayActorVoice, self)

    self.LSBForSelectMsg:SetRefreshItemCallback(self.OnRefreshForSelectListItem, self)
    self.LSBForSelectMsg:AddItemEvent("Btn_ItemSelf", "OnMouseButtonUpEvent", self.OnClickedItem, self)

    self:AddOnClickedEvent("ButTactical", self.OnClickedTactics, self)
    self:AddOnClickedEvent("Buttoncarrythrough", self.OnClickedMarching, self)
    self:AddOnClickedEvent("Butexchange", self.OnClickedExchange, self)

    self:AddOnClickedEvent("Button_QDefault", self.ResetSelectList, self)
    self:AddOnClickedEvent("Button_Quickreplace", self.Replace, self)
    self:AddOnClickedEvent("Button_QCancel", self.Cancel, self)
    self:AddOnClickedEvent("Button_QSure", self.Confirm, self)
    self:AddOnClickedEvent("Button_GoShop", self.JumpToShop, self)
    self:AddOnClickedEvent("Button_Buy", self.JumpToShop, self)
    
    self:AddOnClickedEvent("Button_1", self.HideActorList, self)

    self:AddOnCheckStateChangedEvent("toggleActor", self.OnCheckStateChanged, self)
end

function UI_Setting_QuickMessage:UnRegistEvents()
    --todo: 在这里反注册事件

    UI_Setting_QuickMessage.__super.UnRegistEvents(self)
end

function UI_Setting_QuickMessage:OnPostInitialize()
    UI_Setting_QuickMessage.__super.OnPostInitialize(self)


    self:InitUI()
end

-- 仅在需要监听状态变化时写这个函数
--[[function UI_Template:OnModeSwitch(preStatus, currentStatus)
    
end
]]
function UI_Setting_QuickMessage:Close()
    --todo: 这里做些消耗回收动作，注意UI_Template.__super.Close(self)一定要写在最后，遵循先进后出原则

    UI_Setting_QuickMessage.__super.Close(self)
end

function UI_Setting_QuickMessage:OnSelectActor(widget, index)
    local itemData = self.LSBActor:GetItemData(index)
    BP_Select_Actor_ID = itemData.ActorID

    self:ClearForSelectStatus()
    self:InitForSelectList(BP_Select_Type_ID)
    self:RefreshSelectActor()
    self:RefreshBuyButton()

    self.UIRoot.ToggleActor:SetCheckedState(UEnums.ECheckBoxState.Unchecked)
    self.UIRoot.Setting_ActorListMenu:SetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.Button_1:SetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.ArrowUp:SetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.ArrowDown:SetVisibility(UEnums.ESlateVisibility.Visible)
end

function UI_Setting_QuickMessage:InitUI()
    slua_GameFrontendHUD:BeginModifyUserSettings()
    self.SettingConfig = slua_GameFrontendHUD:GetUserSettings()

    self:RefreshSelectActor()
    self:InitActorList()
    self:InitSelectList()
    self:InitForSelectList(Enum_ForSelectMsgType.EnumTactics)
    self:RefreshBuyButton()

    self.UIRoot.WidgetSwitcher_but:SetActiveWidgetIndex(0)
    self.UIRoot.Button_QSure:SetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.Button_Quickreplace:SetVisibility(UEnums.ESlateVisibility.Visible)
    self.UIRoot.Button_QCancel:SetVisibility(UEnums.ESlateVisibility.Collapsed)

    if self.SettingConfig.HaveShowActorHint and #BP_ARRAY_ActorList <= 1 then
        self.UIRoot.Image_Hint:SetVisibility(UEnums.ESlateVisibility.Visible)
    else
        self.UIRoot.Image_Hint:SetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
end

function UI_Setting_QuickMessage:InitActorList()
    self.UIRoot.Setting_ActorListMenu:SetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.Button_1:SetVisibility(UEnums.ESlateVisibility.Collapsed)

    local widgetLayoutLib = import("WidgetLayoutLibrary")
    local canvasSlot = widgetLayoutLib.SlotAsCanvasSlot(self.UIRoot.LSBActor)
    local sizeY = math.min(390, #BP_ARRAY_ActorVoiceInfoList * 40)
    local vec = FVector2D(290, sizeY)
    canvasSlot:SetSize(vec)
    self.LSBActor:SetData(BP_ARRAY_ActorVoiceInfoList)
end

function UI_Setting_QuickMessage:OnRefreshActorListItem(widget, index)
    local itemData = self.LSBActor:GetItemData(index)

    if ActorVoiceSystem.CheckIsActorValid(itemData.ActorID) then
        widget.image_lock:SetVisibility(UEnums.ESlateVisibility.Collapsed)
    else
        widget.image_lock:SetVisibility(UEnums.ESlateVisibility.Visible)
    end

    local st = ActorVoiceSystem.GetActorName(itemData.ActorID)
    local ui_util = require("ui.util")
    ui_util.SetText(widget.TextBlock_Name, st)
end

function UI_Setting_QuickMessage:InitSelectList()
    self.ArraySelectItemList = {}
    local selectList = self.SettingConfig.PlayerChatQuickTextIDList
    if selectList ~= nil then
        --log("UI_Setting_QuickMessage:InitSelectList selectList length = " .. selectList:Num())
        for i = 0, selectList:Num() - 1 do
            local SelectItemData = {}
            SelectItemData.ContentID = selectList:Get(i)
            --log("UI_Setting_QuickMessage:InitSelectList selectList[i]" .. selectList:Get(i))
            SelectItemData.ActorID = selectList:Get(i) // 100000
            SelectItemData.IsSelected = false
            SelectItemData.VBtnDelete = UEnums.ESlateVisibility.Hidden
            SelectItemData.VBtnSetContent = UEnums.ESlateVisibility.Hidden
            table.insert(self.ArraySelectItemList, SelectItemData)
        end
        self.LSBSelectMsg:SetData(self.ArraySelectItemList)
    end
end

function UI_Setting_QuickMessage:OnRefreshSelectListItem(widget, index)
    local itemData = self.LSBSelectMsg:GetItemData(index)
    if itemData.ContentID ~= 0 then
        local msgID = math.fmod(itemData.ContentID, 100000)
        local st = DataMgr.GetMsgByIDForBattleText(msgID)
        local ui_util = require("ui.util")
        ui_util.SetText(widget.RichTextBlock, st)
        widget.NodeSetContentBtn:SetVisibility(UEnums.ESlateVisibility.Hidden)
        widget.NodeDeleteBtn:SetVisibility(itemData.VBtnDelete)

        widget.WidgetSwitcher_0:SetActiveWidgetIndex(0)
        widget.Btn_ItemSelf:SetVisibility(UEnums.ESlateVisibility.Collapsed)
        self:UpdateActorName(widget, index)
        widget.NodePlayBtn:SetVisibility(UEnums.ESlateVisibility.Visible)
    else
        local ui_util = require("ui.util")
        ui_util.SetText(widget.RichTextBlock, "")
        widget.NodeDeleteBtn:SetVisibility(UEnums.ESlateVisibility.Hidden) 
        widget.NodeSetContentBtn:SetVisibility(itemData.VBtnSetContent)
        widget.WidgetSwitcher_0:SetActiveWidgetIndex(0)
        widget.Btn_ItemSelf:SetVisibility(UEnums.ESlateVisibility.Collapsed)
        self:UpdateActorName(widget, index)
    end
    
end

function UI_Setting_QuickMessage:InitForSelectList(tabType)
    BP_Try_Voice.ContentID = 0
    BP_Try_Voice.ActorID = 0
    
    BP_Select_Type_ID = tabType
	if ActorVoiceSystem.ActorVoiceIDList ~= nil and ActorVoiceSystem.ActorVoiceIDList[BP_Select_Actor_ID] ~= nil then
		BP_ARRAY_SelectedVoiceIDList = ActorVoiceSystem.ActorVoiceIDList[BP_Select_Actor_ID][BP_Select_Type_ID]
	end

    -- 根据当前声优与快捷语音类型确定待选列表
    self.ArrayForSelectItemList = {}
    if BP_ARRAY_SelectedVoiceIDList ~= nil then
        for i, v in pairs(BP_ARRAY_SelectedVoiceIDList) do
            local forSelectItemData = {}
            forSelectItemData.ContentID = v
            forSelectItemData.ActorID = BP_Select_Actor_ID
            forSelectItemData.IsSelected = false
            forSelectItemData.VBtnDelete = UEnums.ESlateVisibility.Hidden
            forSelectItemData.VBtnSetContent = UEnums.ESlateVisibility.Hidden
            table.insert(self.ArrayForSelectItemList, forSelectItemData)
        end
    end
    self.LSBForSelectMsg:SetData(self.ArrayForSelectItemList)
end

function UI_Setting_QuickMessage:OnRefreshForSelectListItem(widget, index)
    local itemData = self.LSBForSelectMsg:GetItemData(index)
    if itemData.ContentID ~= 0 then
        local st = DataMgr.GetMsgByIDForBattleText(math.fmod(itemData.ContentID, 100000))
        local ui_util = require("ui.util")
        ui_util.SetText(widget.RichTextBlock, st)
        widget.NodeDeleteBtn:SetVisibility(UEnums.ESlateVisibility.Hidden)
        widget.NodeSetContentBtn:SetVisibility(UEnums.ESlateVisibility.Hidden)
        widget.WidgetSwitcher_0:SetActiveWidgetIndex(0)
        widget.Btn_ItemSelf:SetVisibility(UEnums.ESlateVisibility.Visible)
        widget.NodePlayBtn:SetVisibility(UEnums.ESlateVisibility.Collapsed)
        widget.ActorPart:SetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
end

function UI_Setting_QuickMessage:RefreshBuyButton()
    if ActorVoiceSystem.CheckIsActorValid(BP_Select_Actor_ID) then
        self.UIRoot.Button_Buy:SetVisibility(UEnums.ESlateVisibility.Collapsed)
        self.UIRoot.Button_GoShop:SetVisibility(UEnums.ESlateVisibility.Collapsed)  
    else
        local strRegion = Client.GetPublishRegion();
        if strRegion == "JAPAN" or strRegion == "KOREA" then
            self.UIRoot.Button_Buy:SetVisibility(UEnums.ESlateVisibility.Collapsed)
            self.UIRoot.Button_GoShop:SetVisibility(UEnums.ESlateVisibility.Visible)  
        else
            self.UIRoot.Button_Buy:SetVisibility(UEnums.ESlateVisibility.Visible)
            self.UIRoot.Button_GoShop:SetVisibility(UEnums.ESlateVisibility.Collapsed)  
        end
    end

end

function UI_Setting_QuickMessage:RefreshSelectActor()
    local stSelectActor = ActorVoiceSystem.GetActorName(BP_Select_Actor_ID)
    if stSelectActor ~= nil then
        local ui_util = require("ui.util")
        ui_util.SetText(self.UIRoot.TextBlock_SelectedActor, stSelectActor)
    end

    if ActorVoiceSystem.CheckIsActorValid(BP_Select_Actor_ID) then
        self.UIRoot.Image_SelectedActor:SetVisibility(UEnums.ESlateVisibility.Collapsed)
    else
        self.UIRoot.Image_SelectedActor:SetVisibility(UEnums.ESlateVisibility.Visible)
    end
end

function UI_Setting_QuickMessage:UpdateActorName(widget, index)
    local itemData = self.LSBSelectMsg:GetItemData(index)
    if itemData.ActorID == 0 then
        widget.ActorPart:SetVisibility(UEnums.ESlateVisibility.Collapsed)
        widget.NodePlayBtn:SetVisibility(UEnums.ESlateVisibility.Collapsed)
    else
        widget.ActorPart:SetVisibility(UEnums.ESlateVisibility.Visible)
        local ui_util = require("ui.util")
        for i, v in pairs(BP_ARRAY_ActorVoiceInfoList) do
            if v.ActorID == itemData.ActorID then
                ui_util.SetText(widget.TextBlock_Actor, v.ActorName)
            end
        end
    end
end

function UI_Setting_QuickMessage:ClearForSelectStatus()
    for i, v in pairs(self.ArrayForSelectItemList) do
        v.IsSelected = false
    end
    self.LSBForSelectMsg:RefreshAllItems(self.ArrayForSelectItemList)
end

function UI_Setting_QuickMessage:OnClickedTactics(widget, index)
    self:InitForSelectList(Enum_ForSelectMsgType.EnumTactics)
    self.UIRoot.WidgetSwitcher_but:SetActiveWidgetIndex(0)
end

function UI_Setting_QuickMessage:OnClickedMarching(widget, index)
    self:InitForSelectList(Enum_ForSelectMsgType.EnumMarching)
    self.UIRoot.WidgetSwitcher_but:SetActiveWidgetIndex(1)
end

function UI_Setting_QuickMessage:OnClickedExchange(widget, index)
    self:InitForSelectList(Enum_ForSelectMsgType.EnumExchange)
    self.UIRoot.WidgetSwitcher_but:SetActiveWidgetIndex(2)
end

function UI_Setting_QuickMessage:ResetItemState()
    for i, v in pairs(self.ArraySelectItemList) do
        v.VBtnDelete = UEnums.ESlateVisibility.Hidden
        v.VBtnSetContent = UEnums.ESlateVisibility.Hidden
    end
    self.LSBSelectMsg:SetData(self.ArraySelectItemList)
end

function UI_Setting_QuickMessage:ResetSelectList()
    local gameplayStatics = import("GamePlayStatics")
    local classSettingConfig = slua.loadClass("/Game/Blueprints/Config/SettingConfig.SettingConfig")
    local saveGameObject = gameplayStatics.CreateSaveGameObject(classSettingConfig)
    if saveGameObject == nil then
        sandbox.logError("UI_Setting_QuickMessage:ResetSelectList CreateSaveGameObject is nil")
        return
    end
    local quickMsgIDList = saveGameObject.PlayerChatQuickTextIDList
    if quickMsgIDList == nil then
        sandbox.logError("UI_Setting_QuickMessage:ResetSelectList quickMsgIDList is nil")
        return
    end
    self.SettingConfig.PlayerChatQuickTextIDList:Clear()
    for i = 0, quickMsgIDList:Num() - 1 do
        --log("UI_Setting_QuickMessage:ResetSelectList quickMsgIDList[i] = " .. quickMsgIDList:Get(i))
        self.SettingConfig.PlayerChatQuickTextIDList:Add(quickMsgIDList:Get(i))
        --log("UI_Setting_QuickMessage:ResetSelectList PlayerChatQuickTextIDList[i] = " .. self.SettingConfig.PlayerChatQuickTextIDList:Get(i))
    end
    --log("UI_Setting_QuickMessage:ResetSelectList self.SettingConfig.PlayerChatQuickTextIDList length = " .. self.SettingConfig.PlayerChatQuickTextIDList:Num())
    slua_GameFrontendHUD:FinishModifyUserSettings()

    self:InitSelectList()

    SettingUI:ShowQuickMsgBackToDefaultMsg()

    self.UIRoot.Button_QSure:SetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.Button_Quickreplace:SetVisibility(UEnums.ESlateVisibility.Visible)
    self.UIRoot.Button_QCancel:SetVisibility(UEnums.ESlateVisibility.Collapsed)

    self:ResetItemState()
end

function UI_Setting_QuickMessage:Replace()
    self.UIRoot.Button_QSure:SetVisibility(UEnums.ESlateVisibility.Visible)
    self.UIRoot.Button_Quickreplace:SetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.Button_QCancel:SetVisibility(UEnums.ESlateVisibility.Visible)  
    
    for i, v in pairs(self.ArraySelectItemList) do
        if v.ContentID ~= 0 then
            v.VBtnDelete = UEnums.ESlateVisibility.SelfHitTestInvisible
        else
            v.VBtnSetContent = UEnums.ESlateVisibility.Visible
        end
    end
    self.LSBSelectMsg:SetData(self.ArraySelectItemList)

    slua_GameFrontendHUD:BeginModifyUserSettings()
end

function UI_Setting_QuickMessage:Cancel(widget, index)
    self.UIRoot.Button_QSure:SetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.Button_Quickreplace:SetVisibility(UEnums.ESlateVisibility.Visible)
    self.UIRoot.Button_QCancel:SetVisibility(UEnums.ESlateVisibility.Collapsed)
    
    self:InitSelectList()
end

function UI_Setting_QuickMessage:Confirm()
    self.UIRoot.Button_QSure:SetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.Button_Quickreplace:SetVisibility(UEnums.ESlateVisibility.Visible)
    self.UIRoot.Button_QCancel:SetVisibility(UEnums.ESlateVisibility.Collapsed)
    
    SettingUI.ShowQuickMsgModifiedSuccess()
    self:ResetItemState()

    for i, v in pairs(self.ArraySelectItemList) do
        self.SettingConfig.PlayerChatQuickTextIDList:Set(i - 1, v.ContentID)
    end

    slua_GameFrontendHUD:FinishModifyUserSettings()
    ActorVoiceSystem.UploadPlayerQuickMsgList()
end

function UI_Setting_QuickMessage:HideActorList()
    self.UIRoot.ToggleActor:SetCheckedState(UEnums.ECheckBoxState.Unchecked)
    self.UIRoot.Setting_ActorListMenu:SetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.Button_1:SetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.ArrowUp:SetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.ArrowDown:SetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
end

function UI_Setting_QuickMessage:OnCheckStateChanged(IsChecked)
    if IsChecked then
        self.UIRoot.Setting_ActorListMenu:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        self.UIRoot.Button_1:SetVisibility(UEnums.ESlateVisibility.Visible)
        self.UIRoot.ArrowUp:SetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
        self.UIRoot.ArrowDown:SetVisibility(UEnums.ESlateVisibility.Collapsed)
    else
        self.UIRoot.Setting_ActorListMenu:SetVisibility(UEnums.ESlateVisibility.Collapsed)
        self.UIRoot.Button_1:SetVisibility(UEnums.ESlateVisibility.Collapsed)
        self.UIRoot.ArrowUp:SetVisibility(UEnums.ESlateVisibility.Collapsed)
        self.UIRoot.ArrowDown:SetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
    end

    if self.UIRoot.Image_Hint:IsVisible() then
        self.UIRoot.Image_Hint:SetVisibility(UEnums.ESlateVisibility.Collapsed)
        self.SettingConfig.HaveShowActorHint = true
        slua_GameFrontendHUD:FinishModifyUserSettings()
    end
end

function UI_Setting_QuickMessage:DeleteSelectedMsg(widget, index)
    local itemData = self.LSBSelectMsg:GetItemData(index)
    itemData.ContentID = 0

    local ui_util = require("ui.util")
    ui_util.SetText(widget.RichTextBlock, "")
    widget.NodeSetContentBtn:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    widget.NodeDeleteBtn:SetVisibility(UEnums.ESlateVisibility.Hidden)
    widget.ActorPart:SetVisibility(UEnums.ESlateVisibility.Collapsed)
    widget.NodePlayBtn:SetVisibility(UEnums.ESlateVisibility.Collapsed)
end

function UI_Setting_QuickMessage:SetMsgContent(widget, index) 
    local itemData = self.LSBSelectMsg:GetItemData(index)
    if BP_Try_Voice.ContentID ~= 0 then
        if self:CanSetCurrentSelectedItem(BP_Try_Voice.ContentID) then
            if ActorVoiceSystem.CheckIsActorValid(BP_Try_Voice.ActorID) then
                itemData.ContentID = BP_Try_Voice.ContentID
                itemData.ActorID = BP_Try_Voice.ActorID
                self.LSBSelectMsg:RefreshItem(index, itemData)
                widget.NodeDeleteBtn:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
            else
                SettingUI:ShowInvalidMsgSelected()
            end
        else
            SettingUI:ShowDuplactedMsgSelected()
        end
    else
        SettingUI:ShowNoQuickMsgSelected()
    end
end

function UI_Setting_QuickMessage:PlayActorVoice(widget, index, data)
    local itemData = data
    if data == nil then
        itemData = self.LSBSelectMsg:GetItemData(index)
    end
    local KismetSystemLibrary = import("KismetSystemLibrary")
    if KismetSystemLibrary.IsValid(widget.PlayerLobbyPawn) then
        widget.PlayerLobbyPawn.ChatComponent_BP:PlaySound(math.fmod(itemData.ContentID, 100000), itemData.ActorID)
    else
        local gameplayStatics = import("GamePlayStatics")
        local classLobbyPawn = slua.loadClass("/Game/Arts_PlayerBluePrints/Character_Show/BP_PlayerLobbyPawn.BP_PlayerLobbyPawn")
        local outActor = slua.Array(UEnums.EPropertyClass.Object)
        outActor = gameplayStatics.GetAllActorsOfClass(widget, classLobbyPawn, outActor)
        log("UI_Setting_QuickMessage:PlayActorVoice outActor num = ", outActor:Num())
        if outActor:Num() > 0 and KismetSystemLibrary.IsValid(outActor:Get(0)) then
            widget.PlayerLobbyPawn = outActor:Get(0)
            outActor:Get(0).ChatComponent_BP:PlaySound(math.fmod(itemData.ContentID, 100000), itemData.ActorID)
        end
    end
end

function UI_Setting_QuickMessage:OnClickedItem(widget, index)
    local itemData = self.LSBForSelectMsg:GetItemData(index)
    self:PlayActorVoice(widget, index, itemData)
    BP_Try_Voice.ContentID = itemData.ContentID
    BP_Try_Voice.ActorID = itemData.ActorID
    self:TryVoice()
    self:ClearForSelectStatus()

    local temp = itemData.IsSelected
    itemData.IsSelected =  not(temp or false)
    if itemData.IsSelected then
        widget.WidgetSwitcher_0:SetActiveWidgetIndex(1)
    else
        widget.WidgetSwitcher_0:SetActiveWidgetIndex(0)
    end
end

function UI_Setting_QuickMessage:TryVoice()
	ActorVoiceSystem.UpdatePlayerListenVoiceEvent(BP_Try_Voice.ContentID);
end

function UI_Setting_QuickMessage:JumpToShop()
    SettingUI:Hide();

    local params = {
        ["targetPlayModel"] = 9,
    };
    EventSystem:postEvent(EVENTTYPE_URL, BP_ENUM_MODULE_MALL_BOX, params);
end

function UI_Setting_QuickMessage:CanSetCurrentSelectedItem(SelectedID)
    for i, v in pairs(self.ArraySelectItemList) do
        if v.ContentID == SelectedID then
            return false
        end
    end
    return true
end

local math = require("math")
local class = require("class")
local ui_base = require("ui.base")
local CUISetting_QuickMessage = class(ui_base, nil, UI_Setting_QuickMessage)

return CUISetting_QuickMessage
