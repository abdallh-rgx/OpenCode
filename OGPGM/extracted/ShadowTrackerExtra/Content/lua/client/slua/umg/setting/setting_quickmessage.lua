--[[
    系统设置——快捷语音UI
    create by rainpan 2018/12/11
]]

local UI_Setting_QuickMessage = {}

local switchQuickMessageWidgetList =
{
    "CanvasPanel_close1",
    "CanvasPanel_",
    "Image_Bg2",
    "HorizontalBox_Wardrobe_Clothes",
    "VerticalBox_Wardrobe_Gun",
    "Button_ItemUpgrade_GuideMask",
}

local Enum_ForSelectMsgType = {
    Unknow = 0,
    Tactics = 1,
    Marching = 2,
    Exchange = 3,
}

local Enum_SelectVoiceMode = {
    Roulette = 0,
    List = 1,
}

local ActorVoiceSystem = require("client.slua.logic.actor_voice.logic_actor_voice")

local selectVoiceMode = Enum_SelectVoiceMode.Roulette;
local isDragOpen = false;--拖拽功能开关
local isSelectMode = false;

function UI_Setting_QuickMessage:ctor()
    self.settingConfig = {}

    self.currentSelectActorID = 0
    self.currentSelectType = Enum_ForSelectMsgType.Unknow

    self.currentVoiceDatas = {
        --[[key = 0, unLock = false]]
    }
    self.currentSelectVoiceDatas = {
        --[[key = 0]]
        --[[actorID = 0]]
    }
    --轮盘语音数据
    self.currentSelectWheelVoiceDatas = {
        --[[key = 0]]
        --[[actorID = 0]]
    }
    
    --当前选择的语音
    self.selectItem = {
        --[[key = 0]]
        --[[actorID = 0]]
    }
    
    self.wheelItemList = {
        
    }
end

function UI_Setting_QuickMessage:OnInitialize()
    UI_Setting_QuickMessage.__super.OnInitialize(self)

    self.scrollBoxSelectMsg = self:InitScrollBox(self.UIRoot.ScrollBoxSelectMsg)
    self.scrollBoxActorVoice = self:InitScrollBox(self.UIRoot.ScrollBoxActorVoice)
    self.scrollBoxActor = self:InitScrollBox(self.UIRoot.LoopScrollBox_0)

    self:SetWidgetVisible(self.UIRoot.RouletteNewbieTips, false)
    self:SetWidgetVisible(self.UIRoot.RouletteDragNewbieTips, false)
    self:SetWidgetVisible(self.UIRoot.ComboBoxVoiceActor, false)
end

function UI_Setting_QuickMessage:RegistEvents()
    UI_Setting_QuickMessage.__super.RegistEvents(self)

    self:AddOnClickedEvent("ButTactical", self.OnChangeSelectType, self, Enum_ForSelectMsgType.Tactics)
    self:AddOnClickedEvent("Buttoncarrythrough", self.OnChangeSelectType, self, Enum_ForSelectMsgType.Marching)
    self:AddOnClickedEvent("Butexchange", self.OnChangeSelectType, self, Enum_ForSelectMsgType.Exchange)

    self:AddOnClickedEvent("Button_Roulette", self.OnChangeSelectVoiceMode, self, Enum_SelectVoiceMode.Roulette)
    self:AddOnClickedEvent("Button_List", self.OnChangeSelectVoiceMode, self, Enum_SelectVoiceMode.List)

    self:AddOnClickedEvent("Button_QDefault", self.ResetSelectList, self)
    self:AddOnClickedEvent("Button_Get", self.TryGetVoiceItem, self)

    self:AddOnClickedEvent("Button_Quickreplace", self.OnClickReplace, self)
    self:AddOnClickedEvent("Button_QCancel", self.OnClickCancel, self)
    self:AddOnClickedEvent("Button_QSure", self.OnClickConfirm, self)

--[[    self:AddControlEvent("ComboBoxVoiceActor", "OnSelectItem", self.OnSelectActor, self)
    self:AddControlEvent("ComboBoxVoiceActor", "OnRefreshItem", self.OnRefreshActorListItem, self)
    self:AddControlEvent("ComboBoxVoiceActor", "OnOpening", self.OnOpenComboBox, self)]]
    self.scrollBoxActor:SetRefreshItemCallback(self.OnRefreshActorListItem, self)
    self.scrollBoxActor:AddItemEvent("Button_ItemSelf", "OnClicked", self.OnSelectActor, self)

    self:AddControlEvent("Checkbox_Own", "OnCheckStateChanged", self.OnCheckOwnVoice, self)

    self.scrollBoxActorVoice:SetRefreshItemCallback(self.OnRefreshVoiceItem, self)
    self.scrollBoxActorVoice:AddItemEvent("Btn_ItemSelf", "OnMouseButtonUpEvent", self.OnClickVoiceItem, self)
    self.scrollBoxActorVoice:AddItemEvent("Button_Play", "OnClicked", self.OnPlayVoiceItem, self)

    self.scrollBoxSelectMsg:SetRefreshItemCallback(self.OnRefreshSelectedVoiceItem, self)
    self.scrollBoxSelectMsg:AddItemEvent("Button_Play", "OnClicked", self.OnPlaySelectVoiceItem, self)
    self.scrollBoxSelectMsg:AddItemEvent("Btn_ItemSelf", "OnMouseButtonUpEvent", self.OnClickSelectVoiceItem, self)
    self.scrollBoxSelectMsg:AddItemEvent("Button_Delete", "OnClicked", self.DeleteSelectedMsg, self)
    self.scrollBoxSelectMsg:AddItemEvent("Button_Add","OnClicked",self.SetMsgContent,self);

    self:AddCommonEvent(EVENTTYPE_ACTOR_VOICE, EVENTID_ACTOR_VOICE_ACTOR_CHANGE, self.OnActorChnange, self)
    self:AddCommonEvent(EVENTTYPE_ACTOR_VOICE, EVENTID_ACTOR_VOICE_OWN_MESSAGE_CHANGAE, self.OnVoiceChange, self)

    self:AddOnCheckStateChangedEvent("ToggleActor", self.OpenOrCloseActorList, self)
    self:AddOnClickedEvent("Button_1", function ()
        self.UIRoot.ToggleActor:SetCheckedState(UEnums.ECheckBoxState.Unchecked)
        self:OpenOrCloseActorList(false)
    end)
end

function UI_Setting_QuickMessage:UnRegistEvents()
    --todo: 在这里反注册事件

    UI_Setting_QuickMessage.__super.UnRegistEvents(self)
end

function UI_Setting_QuickMessage:InitSelectList()
    self.currentSelectVoiceDatas = {};
    for i,j in ipairs(ActorVoiceSystem.GetSelectedActorList()) do
        table.insert(self.currentSelectVoiceDatas,{key = j , actorID = j // 100000}) 
    end
    
    self.currentSelectWheelVoiceDatas = {};
    for i,j in ipairs(ActorVoiceSystem.GetSelectedWheelActorList()) do
        table.insert(self.currentSelectWheelVoiceDatas,{key = j, actorID = j // 100000})
    end
end

function UI_Setting_QuickMessage:OnPostInitialize()
    UI_Setting_QuickMessage.__super.OnPostInitialize(self)
--[[    local actorList = ActorVoiceSystem.GetActorList()
    for i, _ in pairs(actorList) do
        self.UIRoot.ComboBoxVoiceActor:AddOption(tostring(i))
    end]]
    local actorList = {}
    for i = 1, #ActorVoiceSystem.GetActorList() do
        table.insert(actorList, ActorVoiceSystem.GetActorVoiceInfoList(i))
    end

    slua_GameFrontendHUD:BeginModifyUserSettings()
    self.settingConfig = slua_GameFrontendHUD:GetUserSettings()
    
    self.scrollBoxActor:SetData(actorList)
    
	self:InitWheelView()
    self:InitSelectList();
    self:OnSelectActor(nil, 1)
    self:OnChangeSelectType(Enum_ForSelectMsgType.Tactics)
    
    self.scrollBoxSelectMsg:SetData(self.currentSelectVoiceDatas)
    
    self:SetWidgetVisible(self.UIRoot.Image_Hint, (not self.settingConfig.HaveShowActorHint) and #actorList > 1)
end

-- 仅在需要监听状态变化时写这个函数
--[[function UI_Template:OnModeSwitch(preStatus, currentStatus)
    
end
]]
function UI_Setting_QuickMessage:Close()
    --todo: 这里做些消耗回收动作，注意UI_Template.__super.Close(self)一定要写在最后，遵循先进后出原则

    UI_Setting_QuickMessage.__super.Close(self)
end

function UI_Setting_QuickMessage:OnChangeSelectType(selectType)
    self:SetCurrentVoiceDatas(self.currentSelectActorID, selectType)
    self.UIRoot.WidgetSwitcher_but:SetActiveWidgetIndex(selectType - 1)
    local sound_config = require("client.slua.config.sound")
    self:PlayAudio(sound_config.click)
end

--左侧切换操作方式时刷新item，也可直接用此方法来刷新左侧
function UI_Setting_QuickMessage:OnChangeSelectVoiceMode(selectType)
    self.UIRoot.WidgetSwitcher_SelectVoiceMode:SetActiveWidgetIndex(selectType)
    self.UIRoot.WidgetSwitcher_ML:SetActiveWidgetIndex(selectType)

    selectVoiceMode = selectType;
    if selectVoiceMode == Enum_SelectVoiceMode.List then
        self.scrollBoxSelectMsg:RefreshAllItems(self.currentSelectVoiceDatas)
    elseif selectVoiceMode == Enum_SelectVoiceMode.Roulette then
        self:RefreshWheelView();
    end

    local sound_config = require("client.slua.config.sound")
    self:PlayAudio(sound_config.click)
end

function UI_Setting_QuickMessage:OnSelectActor(widget, selectActorIndex)
    local actorLit = ActorVoiceSystem.GetActorList()
    local actorID = actorLit[tonumber(selectActorIndex)]
    self:SetCurrentVoiceDatas(actorID, self.currentSelectType)
    self:RefreshCurrentActor(actorID)

    self.UIRoot.ToggleActor:SetCheckedState(UEnums.ECheckBoxState.Unchecked)
    self:OpenOrCloseActorList(false)

    self.scrollBoxActor:Select(selectActorIndex)
end

function UI_Setting_QuickMessage:RefreshCurrentActor(actorID)
    --todo: set current actor name and image
    local voiceActorData = Client.GetTableData("VoiceActorCfg", actorID)
    if voiceActorData.ActorItemID ~= 0 then
        local itemCfg = Client.GetTableData("Item", voiceActorData.ActorItemID)
        local util = require("ui.util")
        util.SetTexture(self.UIRoot.Image_Head, itemCfg.ItemSmallIcon)

        local actorName = ActorVoiceSystem.GetActorName(actorID)
        print("actorName:", actorName, actorID)
        self.UIRoot.TextBlock_SelectedActor:SetText(actorName or "")

        self:SetWidgetVisible(self.UIRoot.Image_CurrentActorLock, not ActorVoiceSystem.CheckIsActorValid(actorID))
    end
end

function UI_Setting_QuickMessage:SetCurrentVoiceDatas(actorID, selectType, forceUpdate)
    if (actorID == self.currentSelectActorID and selectType == self.currentSelectType) and not forceUpdate then
        return
    end
    
    self.currentSelectActorID = actorID
    self.currentSelectType = selectType
    self:RefreshCurrentVoiceDatas(actorID, selectType)
    self.scrollBoxActorVoice:SetData(self.currentVoiceDatas)

    self.scrollBoxActorVoice:Deselect()
    self:SetWidgetVisible(self.UIRoot.Button_Get, false)
end

function UI_Setting_QuickMessage:RefreshCurrentVoiceDatas(actorID, selectType)
    self.currentVoiceDatas = {}

    local checkOwn = self.UIRoot.Checkbox_Own:IsChecked()
    
    local voiceList = ActorVoiceSystem.GetVoiceListByActorIDAndType(actorID, selectType)
    if voiceList then
        for _, key in pairs(voiceList) do
            if not (checkOwn and not ActorVoiceSystem.CheckIsVoiceUnLock(key)) then --检查已拥有语音
                local voiceItemData = {}
                voiceItemData.key = key
                voiceItemData.unLock = ActorVoiceSystem.CheckIsVoiceUnLock(key)

                table.insert(self.currentVoiceDatas, voiceItemData)
            end
        end
    end
end

function UI_Setting_QuickMessage:OnRefreshActorListItem(widget, index)
    local actorVoice = ActorVoiceSystem.GetActorVoiceInfoList(index)
    local itemCfg = Client.GetTableData("Item", actorVoice.ActorItemID)
    if itemCfg then
        local util = require("ui.util")
        local quality = itemCfg.ItemQuality - 1
        local QualityResPath = '/Game/UMG/Texture/Atlas/ItemLevelUI/Frames/T_item_icon_quality_'..quality..'_png'
        util.SetTexture(widget.Image_0, itemCfg.ItemSmallIcon)
        util.SetTexture(widget.Image_Icon_Quality_Bottom, QualityResPath)
        widget.TextBlock_Desc:SetText(itemCfg.ItemDesc)
    end

    local actorName = ActorVoiceSystem.GetActorName(actorVoice.ActorID)
    widget.TextBlock_Name:SetText(actorName)

    local selectedIndex = self.scrollBoxActor:GetSelectIndex()--self.UIRoot.ComboBoxVoiceActor:GetSelectedOption()
    self:SetWidgetVisible(widget.Image_Select, selectedIndex == index)
end
--[[
function UI_Setting_QuickMessage:OnOpenComboBox()
    if self.UIRoot.Image_Hint:IsVisible() then
        self:SetWidgetVisible(self.UIRoot.Image_Hint, false)
        self.settingConfig.HaveShowActorHint = false
        slua_GameFrontendHUD:FinishModifyUserSettings()
    end
end]]

function UI_Setting_QuickMessage:OnCheckOwnVoice(isCheck)
    self:SetCurrentVoiceDatas(self.currentSelectActorID, self.currentSelectType, true)
end

function UI_Setting_QuickMessage:ResetSelectList()
    local gameplayStatics = import("GamePlayStatics")
    local classSettingConfig = slua.loadClass("/Game/Blueprints/Config/SettingConfig.SettingConfig")
    local saveGameObject = gameplayStatics.CreateSaveGameObject(classSettingConfig)
    if saveGameObject == nil then
        sandbox.logError("UI_Setting_QuickMessage:ResetSelectList CreateSaveGameObject is nil")
        return
    end

    if selectVoiceMode == Enum_SelectVoiceMode.List then
        local quickMsgIDList = saveGameObject.PlayerChatQuickTextIDList
        if quickMsgIDList == nil then
            sandbox.logError("UI_Setting_QuickMessage:ResetSelectList quickMsgIDList is nil")
            return
        end
        if self.settingConfig.PlayerChatQuickTextIDList then
            self.settingConfig.PlayerChatQuickTextIDList:Clear()

            for i = 0, quickMsgIDList:Num() - 1 do
                self.settingConfig.PlayerChatQuickTextIDList:Add(quickMsgIDList:Get(i))
            end
        else
            self.settingConfig.PlayerChatQuickTextIDList = slua.Array(UEnums.EPropertyClass.Int)
        end
    end

    if selectVoiceMode == Enum_SelectVoiceMode.Roulette then
        local wheelMsgIDList = saveGameObject.PlayerWheelChatQuickTextIDList;
        if wheelMsgIDList == nil then
            sandbox.logError("UI_Setting_QuickMessage:ResetSelectList wheelMsgIDList is nil")
            return
        else
            if self.settingConfig.PlayerWheelChatQuickTextIDList then
                self.settingConfig.PlayerWheelChatQuickTextIDList:Clear()

                for i = 0, wheelMsgIDList:Num() - 1 do
                    self.settingConfig.PlayerWheelChatQuickTextIDList:Add(wheelMsgIDList:Get(i))
                end
            else
                self.settingConfig.PlayerWheelChatQuickTextIDList = slua.Array(UEnums.EPropertyClass.Int)
            end
        end
    end

    slua_GameFrontendHUD:FinishModifyUserSettings()

    ActorVoiceSystem.UploadPlayerQuickMsgList();

    self:InitSelectList()
    self:OnChangeSelectVoiceMode(selectVoiceMode)

    SettingUI:ShowQuickMsgBackToDefaultMsg()

end

function UI_Setting_QuickMessage:TryGetVoiceItem()
    local index = self.scrollBoxActorVoice:GetSelectIndex()
    if index ~= 0 then
        local voiceData = self.scrollBoxActorVoice:GetItemData(index)

        EventHideWardrodbe()

        GlobalData:JumpByTypeID(voiceData.key, 1)
    end
end

function UI_Setting_QuickMessage:OnRefreshVoiceItem(widget, index)
    local voiceData = self.currentVoiceDatas[index]

    local msgID = ActorVoiceSystem.GetMessageIDByKey(voiceData.key)
    local desc = DataMgr.GetMsgByIDForBattleText(msgID)
    widget.RichTextBlock:SetText(desc)

    local math = require("math")
    widget.WidgetSwitcher_0:SetActiveWidgetIndex(math.fmod(index, 2))

    self:SetWidgetVisible(widget.Image_Lock, not voiceData.unLock)
    self:SetWidgetVisible(widget.Image_New, ActorVoiceSystem.CheckIsVoiceNew(voiceData.key))
    self:SetWidgetVisible(widget.Image_Select, self.scrollBoxActorVoice:GetSelectIndex() == index)
end

function UI_Setting_QuickMessage:OnClickVoiceItem(widget, index)
    local voiceData = self.currentVoiceDatas[index]
    self.selectItem = {key = voiceData.key,actorID = voiceData.key // 100000};
    if JumpUtils.FindJumpInfoAll(voiceData.key) then
        self:SetWidgetVisible(self.UIRoot.Button_Get, not voiceData.unLock, true)
    end
    self:OnPlayVoiceItem(widget,index);

    ActorVoiceSystem.ReadVoice(voiceData.key)
    self.scrollBoxActorVoice:Select(index)
end

function UI_Setting_QuickMessage:OnPlayVoiceItem(widget, index)
    local voiceData = self.currentVoiceDatas[index]
    self:PlayActorVoice(widget, voiceData.key)
end

function UI_Setting_QuickMessage:OnPlaySelectVoiceItem(widget, index)
    local voiceData = self.currentSelectVoiceDatas[index]
    if voiceData.key ~= 0 then
        self:PlayActorVoice(widget, voiceData.key)
    end
end

function UI_Setting_QuickMessage:OnClickSelectVoiceItem(widget, index)
    self.scrollBoxSelectMsg:Select(index)
    self:OnPlaySelectVoiceItem(widget,index);
end

function UI_Setting_QuickMessage:OnDeleteSelectVoiceItem(widget, index)
    local voiceData = self.currentSelectVoiceDatas[index]
    voiceData.key = 0
    voiceData.actorID = 0
    
    self.scrollBoxSelectMsg:RefreshItem(widget, voiceData)
end

function UI_Setting_QuickMessage:OnRefreshSelectedVoiceItem(widget, index)
    local voiceData = self.currentSelectVoiceDatas[index]
    if voiceData.key ~= 0 then
        widget.WidgetSwitcher_AddOrRemove:SetActiveWidgetIndex(1)
        local msgID = ActorVoiceSystem.GetMessageIDByKey(voiceData.key)

        local desc = DataMgr.GetMsgByIDForBattleText(msgID)
        widget.RichTextBlock:SetText(desc)
    
        local actorName = ActorVoiceSystem.GetActorName(voiceData.actorID)
        widget.TextBlock_Actor:SetText(actorName)

        self:SetWidgetVisible(widget.Image_Play, true)
        self:SetWidgetVisible(widget.Button_Play, true, true)
    else
        widget.WidgetSwitcher_AddOrRemove:SetActiveWidgetIndex(0)

        widget.RichTextBlock:SetText("")
        widget.TextBlock_Actor:SetText("")

        self:SetWidgetVisible(widget.Button_Play, false, true)
        self:SetWidgetVisible(widget.Image_Play, false)
    end

    self:SetWidgetVisible(widget.WidgetSwitcher_AddOrRemove,isSelectMode)
    
    local math = require("math")
    widget.WidgetSwitcher_BG:SetActiveWidgetIndex(math.fmod(index, 2))
end

function UI_Setting_QuickMessage:OnActorChnange()
    self:RefreshCurrentVoiceDatas(self.currentSelectActorID, self.currentSelectType)
    self.scrollBoxActorVoice:RefreshAllItems(self.currentVoiceDatas)

    self.scrollBoxActorVoice:Deselect()
    self:SetWidgetVisible(self.UIRoot.Button_Get, false)
end

function UI_Setting_QuickMessage:OnVoiceChange()
    self:OnActorChnange()
end

function UI_Setting_QuickMessage:OpenOrCloseActorList(IsChecked)
    if IsChecked then
        self:SetWidgetVisible(self.UIRoot.LoopScrollBox_0, true)
        self:SetWidgetVisible(self.UIRoot.TextBlock_PlaySoundHint, false)
        self.UIRoot.Button_1:SetVisibility(UEnums.ESlateVisibility.Visible)
        self.UIRoot.ArrowUp:SetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
        self.UIRoot.ArrowDown:SetVisibility(UEnums.ESlateVisibility.Collapsed)
        self.UIRoot.WidgetSwitcher_MR:SetActiveWidgetIndex(1)

        self.UIRoot.CanvasPanel_BG.Slot:SetOffsets(FMargin(0, 0, 0, 0))
    else
        self:SetWidgetVisible(self.UIRoot.LoopScrollBox_0, false)
        self:SetWidgetVisible(self.UIRoot.TextBlock_PlaySoundHint, true)
        self.UIRoot.Button_1:SetVisibility(UEnums.ESlateVisibility.Collapsed)
        self.UIRoot.ArrowUp:SetVisibility(UEnums.ESlateVisibility.Collapsed)
        self.UIRoot.ArrowDown:SetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
        self.UIRoot.WidgetSwitcher_MR:SetActiveWidgetIndex(0)

        self.UIRoot.CanvasPanel_BG.Slot:SetOffsets(FMargin(0, 0, 0, 60))
    end

    if self.UIRoot.Image_Hint:IsVisible() then
        self:SetWidgetVisible(self.UIRoot.Image_Hint, false)
        self.settingConfig.HaveShowActorHint = true
        slua_GameFrontendHUD:FinishModifyUserSettings()
    end

    local sound_config = require("client.slua.config.sound")
    self:PlayAudio(sound_config.click)
end

function UI_Setting_QuickMessage:PlayActorVoice(widget, key)
    ActorVoiceSystem.PlaySound(key, self.UIRoot)
end

function UI_Setting_QuickMessage:OnShow()
    local Wardrobe_BP = UIUtil.GetWidgetByName("bp_wardrobe", "Wardrobe_BP")
    local Wardrobe_UIBP = Wardrobe_BP.Wardrobe_UIBP

    self.switchWardrobeWidgetTag = {}

    for _, widgetName in pairs(switchQuickMessageWidgetList) do
        local widget = Wardrobe_UIBP[widgetName]
        if widget then
            self.switchWardrobeWidgetTag[widgetName] = widget:GetVisibility()
            --print(widgetName, self.switchWardrobeWidgetTag[widgetName])
            widget:SetVisibility(UEnums.ESlateVisibility.Collapsed)
        end
    end
    self:ChangeSelectMode(false);
    Wardrobe_UIBP.Image_40:SetVisibility(UEnums.ESlateVisibility.Visible)
end

function UI_Setting_QuickMessage:OnHide()
    local Wardrobe_BP = UIUtil.GetWidgetByName("bp_wardrobe", "Wardrobe_BP")
    local Wardrobe_UIBP = Wardrobe_BP.Wardrobe_UIBP

    for widgetName, visibility in pairs(self.switchWardrobeWidgetTag) do
        local widget = Wardrobe_UIBP[widgetName]
        if widget then
            --print("OnHide ", widgetName, visibility )
            widget:SetVisibility(visibility)
        end
    end

    Wardrobe_UIBP.Image_40:SetVisibility(UEnums.ESlateVisibility.Collapsed)
end

--初始化轮盘界面相关数据
function UI_Setting_QuickMessage:InitWheelView()
    log(" UI_Setting_QuickMessage:InitWheelView ");
    self.wheelItemList = {};
    for index =1,8 do
        local name = "Wheelitem_0" .. index;
        local widget = self.UIRoot[name];
        if widget ~= nil then
            table.insert(self.wheelItemList,widget);
            --slua通过.可以访问当前蓝图的子蓝图中的控件，注册事件一定要是self
            self:AddOnClickedEvent(name .. ".Button_Delete",self.OnClickWheelDelect,self,index);
            self:AddOnClickedEvent(name .. ".Button_ItemSelf",self.OnClickWheelItem,self,index);
            self:AddOnClickedEvent(name .. ".Button_Add",self.OnClickWheelAdd,self,index);
            --注册OnDrop事件
            self:AddControlEvent(name,"OnItemDropEvent",self.OnItemDrop,self);
            self:AddControlEvent(name,"OnDragStart",self.OnItemDrop,self);
            widget.DragDropItem:RegisterDrag(2,0,0,tostring(index));
            widget.DragDropItem:SetDragEnable(isDragOpen);
            widget.DragDropItem:SetEnable(isDragOpen);
            
        else
            log_error("UI_Setting_QuickMessage:InitWheelView widget nil , name : " .. name);
        end
    end
end

--刷新轮盘界面的item
function UI_Setting_QuickMessage:RefreshWheelView()
    log("UI_Setting_QuickMessage:RefreshWheelView")
    for index,widget in ipairs(self.wheelItemList) do
        local info = self.currentSelectWheelVoiceDatas[index]
        if info ~= nil and info ~= {} and info.key ~= 0 then
            widget.ContentId = info.key;
            widget.ActorId = info.actorID;
            
            local ActorName = ActorVoiceSystem.GetActorName(info.actorID)
            widget.TextBlock_Actor:SetText(ActorName)
            local msgID = ActorVoiceSystem.GetMessageIDByKey(info.key)
            local MsgContent = DataMgr.GetMsgByIDForBattleText(msgID)
            widget.TextBlock_Content:SetText(MsgContent)
            
            widget.Switcher_Select:SetActiveWidgetIndex(0);
            widget.Switcher_Add:SetActiveWidgetIndex(1);
        else
            widget.TextBlock_Actor:SetText("")
            widget.TextBlock_Content:SetText("")
            widget.Switcher_Select:SetActiveWidgetIndex(0);
            widget.Switcher_Add:SetActiveWidgetIndex(0);
            widget.ContentId = 0;
            widget.ActorId = 0;
        end
        if isSelectMode then
            widget.Switcher_Add:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        else
            widget.Switcher_Add:SetVisibility(UEnums.ESlateVisibility.Collapsed)
        end
        widget.Index = index;
    end
end

--点击删除键
function UI_Setting_QuickMessage:OnClickWheelDelect(index)
    local widget = self.wheelItemList[index];
    self:DeleteSelectedMsg(widget,index);
end

--点击添加键
function UI_Setting_QuickMessage:OnClickWheelAdd(index)
    local widget = self.wheelItemList[index];
    self:SetMsgContent(widget,index);
end

--点击轮盘的item
function UI_Setting_QuickMessage:OnClickWheelItem(index)
    log("UI_Setting_QuickMessage:OnClickWheelItem index" .. index);
    local voiceData = self.currentSelectWheelVoiceDatas[index]
    local widget = self.wheelItemList[index];
    
    if voiceData.key ~= 0 then
        self:PlayActorVoice(widget, voiceData.key)
    end
end

--初始化拖动时UI
function UI_Setting_QuickMessage:OnDragReadyToShape(item,widget,dragDropOperation)
    log("UI_Setting_QuickMessage:OnDragReadyToShape")
    local dragIndex;
    if dragDropOperation ~= nil and dragDropOperation.DragExtendData ~= nil then
        dragIndex = dragDropOperation.DragExtendData;
    else
        log_error("UI_Setting_QuickMessage:OnDragReadyToShape Null error");
        return;
    end
    log("UI_Setting_QuickMessage:OnDragReadyToShape index = " .. dragIndex);
    local voiceData = UI_Setting_QuickMessage:GetDataByIndex(tonumber(dragIndex));
    log_tree("UI_Setting_QuickMessage:OnDragReadyToShape voiceData",voiceData);

    item.WidgetSwitcher_AddOrRemove:SetActiveWidgetIndex(1)
    local msgID = ActorVoiceSystem.GetMessageIDByKey(voiceData.key)
    local desc = DataMgr.GetMsgByIDForBattleText(msgID)
    item.RichTextBlock:SetText(desc)
    local actorName = ActorVoiceSystem.GetActorName(voiceData.actorID)
    item.TextBlock_Actor:SetText(actorName)

    self:SetWidgetVisible(item.NodePlayBtn, false)
    self:SetWidgetVisible(item.WidgetSwitcher_AddOrRemove, false)
end

function UI_Setting_QuickMessage:OnItemDrop(dragDropOperation,widget)
    log("UI_Setting_QuickMessage:OnItemDrop")
    local dragIndex;
    if dragDropOperation ~= nil and dragDropOperation.DragExtendData ~= nil then
        dragIndex = dragDropOperation.DragExtendData;
    else
        log_error("UI_Setting_QuickMessage:OnDropSuccess dragDropOperation Null error");
        return;
    end

    if widget == nil or widget.Index == nil then
        log_error("UI_Setting_QuickMessage:OnDropSuccess widget Null error");
        return;
    end
    
    local dropIndex = widget.Index;
    
    --小于0说明是从右侧拖到左侧，直接将左侧原本的id覆盖即可
    if dragIndex < 0 then
        local data = UI_Setting_QuickMessage:GetDataByIndex(dragIndex);
        
    --大于0说明是左侧拖到左侧，交换两个item的位置即可
    elseif dragIndex > 0 then
        
    end
    
end

--交换item的位置
function UI_Setting_QuickMessage:ExchangeItem(indexA,indexB)
    log("UI_Setting_QuickMessage:ExchangeItem indexA: " .. indexA .. "|| indexB : " .. indexB);
    if selectVoiceMode == Enum_SelectVoiceMode.List then
        local tempData = self.currentSelectVoiceDatas[indexA];
        self.currentSelectVoiceDatas[indexA] = self.currentSelectVoiceDatas[indexB];
        self.currentSelectVoiceDatas[indexB] = tempData;
        
        self.scrollBoxSelectMsg:SetData(self.currentSelectVoiceDatas)
    elseif selectVoiceMode == Enum_SelectVoiceMode.Roulette then
        local tempData = self.currentSelectWheelVoiceDatas[indexA];
        self.currentSelectWheelVoiceDatas[indexA] = self.currentSelectWheelVoiceDatas[indexB];
        self.currentSelectWheelVoiceDatas[indexB] = tempData;
        
        self:RefreshWheelView();
    end
end

function UI_Setting_QuickMessage:GetDataByIndex(index)
    if index < 0 then
        return self.currentVoiceDatas[-index];
    end
    
    if selectVoiceMode == Enum_SelectVoiceMode.List then
        return self.currentSelectVoiceDatas[index];
    elseif selectVoiceMode == Enum_SelectVoiceMode.Roulette then
        return self.currentSelectWheelVoiceDatas[index];
    end
end

function UI_Setting_QuickMessage:OnClickCancel()
    self:ChangeSelectMode(false);
    self:InitSelectList()
    self:OnChangeSelectVoiceMode(selectVoiceMode);
end

function UI_Setting_QuickMessage:OnClickConfirm()
    self:ChangeSelectMode(false);
    SettingUI.ShowQuickMsgModifiedSuccess()

    for i, v in pairs(self.currentSelectVoiceDatas) do
        self.settingConfig.PlayerChatQuickTextIDList:Set(i - 1, v.key)
    end

    for i,v in pairs(self.currentSelectWheelVoiceDatas) do
        self.settingConfig.PlayerWheelChatQuickTextIDList:Set(i - 1, v.key)
    end
    
    slua_GameFrontendHUD:FinishModifyUserSettings()
    ActorVoiceSystem.UploadPlayerQuickMsgList()
end

function UI_Setting_QuickMessage:OnClickReplace()
    self:ChangeSelectMode(true);
end


--打开或关闭选择模式
function UI_Setting_QuickMessage:ChangeSelectMode(isOpen)
    isSelectMode = isOpen;
    if isOpen then
        self.UIRoot.Button_QSure:SetVisibility(UEnums.ESlateVisibility.Visible)
        self.UIRoot.Button_Quickreplace:SetVisibility(UEnums.ESlateVisibility.Collapsed)
        self.UIRoot.Button_QCancel:SetVisibility(UEnums.ESlateVisibility.Visible)
    else
        self.UIRoot.Button_QSure:SetVisibility(UEnums.ESlateVisibility.Collapsed)
        self.UIRoot.Button_Quickreplace:SetVisibility(UEnums.ESlateVisibility.Visible)
        self.UIRoot.Button_QCancel:SetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
    --刷新左侧界面
    self:OnChangeSelectVoiceMode(selectVoiceMode)
end

function UI_Setting_QuickMessage:DeleteSelectedMsg(widget, index)
    local itemData = self:GetDataByIndex(index)
    itemData.key = 0
    itemData.actorID = 0
    self:OnChangeSelectVoiceMode(selectVoiceMode)
end

function UI_Setting_QuickMessage:SetMsgContent(widget, index)
    log("UI_Setting_QuickMessage:SetMsgContent , key:" , self.selectItem.key);
    local itemData = self:GetDataByIndex(index)
    if self.selectItem.key ~= nil and self.selectItem.key ~= 0 then
        if self:CanSetCurrentSelectedItem(self.selectItem.key) then
            if ActorVoiceSystem.CheckIsVoiceUnLock(self.selectItem.key) then
                itemData.key = self.selectItem.key
                itemData.actorID = self.selectItem.actorID
                self:OnChangeSelectVoiceMode(selectVoiceMode)
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

function UI_Setting_QuickMessage:CanSetCurrentSelectedItem(SelectedID)
    local list;
    if selectVoiceMode == Enum_SelectVoiceMode.List then
        list = self.currentSelectVoiceDatas;
    elseif selectVoiceMode == Enum_SelectVoiceMode.Roulette then
        list = self.currentSelectWheelVoiceDatas;
    end
    
    for i, v in pairs(list) do
        if v.key == SelectedID then
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
