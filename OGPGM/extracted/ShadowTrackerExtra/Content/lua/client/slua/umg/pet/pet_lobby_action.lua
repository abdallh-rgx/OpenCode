--rain 宠物获取途径
local PetSystem = require("client.slua.logic.pet.logic_pet")
local UI_Pet_Lobby_Action = {}

function UI_Pet_Lobby_Action:ctor()
    --todo: 这里可以做些数据初始化工作

    self.nCurPetID = 0
    self.nCurPetActionID = 0
    self.ArrayActionList = {}
end

function UI_Pet_Lobby_Action:OnInitialize()
    UI_Pet_Lobby_Action.__super.OnInitialize(self)

    UIUtil.SetAdaptation(self.UIRoot.CanvasPanel_Root);

    self.LSGActionList = self:InitScrollBox(self.UIRoot.LSG_ActionList)
end

function UI_Pet_Lobby_Action:RegistEvents()
    UI_Pet_Lobby_Action.__super.RegistEvents(self)

    self:AddCommonEvent(EVENTTYPE_PET, EVENTID_PET_PlayAction, self.OnRspPlayAction, self)
    self:AddCommonEvent(EVENTTYPE_PET, EVENTID_PET_HideLobbyActionList, self.HideActionList, self)

    self:AddOnClickedEvent("BtnClose", self.OnClickedHideActionList, self);
    self:AddOnClickedEvent("BtnPetAction", self.OnClickedShowActionList, self);

    self.LSGActionList:SetRefreshItemCallback(self.OnRefreshActionListItem, self)
    self.LSGActionList:AddItemEvent("Btn_PlayAction", "OnClicked", self.OnClickedActionItem, self)
end

function UI_Pet_Lobby_Action:UnRegistEvents()
    --todo: 在这里反注册事件
    UI_Pet_Lobby_Action.__super.UnRegistEvents(self)
end

function UI_Pet_Lobby_Action:OnPostInitialize()
    UI_Pet_Lobby_Action.__super.OnPostInitialize(self)

    --todo: OnPostInitialize在OnInitialize、RegistEvents之后，有需要在RegistEvents后初始化的工作写这里
end

-- 仅在需要监听状态变化时写这个函数
--function UI_Pet_Lobby_Action:OnModeSwitch(preStatus, currentStatus)
--end

function UI_Pet_Lobby_Action:Close()
    --todo: 这里做些消耗回收动作，注意UI_Template.__super.Close(self)一定要写在最后，遵循先进后出原则
    UI_Pet_Lobby_Action.__super.Close(self)
	
	local time_ticker = require("client.time_ticker")
	time_ticker.AddTimer(1, function()
		collectgarbage("collect")
		do
			local KismetSystemLibrary = import("KismetSystemLibrary")
			KismetSystemLibrary.CollectGarbage()
		end
		collectgarbage("collect")
	end)
end

function UI_Pet_Lobby_Action:OnShow()
    self:InitActionList()

    self.UIRoot.CP_PetAction:SetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.WS_PetAction:SetActiveWidgetIndex(0)

    self.UIRoot.Slot:SetZOrder(36)
end

function UI_Pet_Lobby_Action:HideActionList()
    self.UIRoot.CP_PetAction:SetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.WS_PetAction:SetActiveWidgetIndex(0)
end

function UI_Pet_Lobby_Action:OnClickedShowActionList()
    LuaClassObj.HandleUIMessageNoFetch(bp_expression, "UIHide")

    if PetSystem.MyPetInfo == nil or  PetSystem.MyPetInfo.equip_pet_id == nil or PetSystem.MyPetInfo.equip_pet_id == 0 then
        ShowNotice(530006);
    else
        self:ShowActionList()
    end
end

function UI_Pet_Lobby_Action:OnClickedHideActionList()
    self:PlayAudio(require("client.slua.config.sound").close);

    self:HideActionList()
	
end

function UI_Pet_Lobby_Action:ShowActionList()
    self.UIRoot.CP_PetAction:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot.WS_PetAction:SetActiveWidgetIndex(1)
    self:PlayAudio(require("client.slua.config.sound").click);
end

function UI_Pet_Lobby_Action:InitActionList()
    self.ArrayActionList = {}

    if PetSystem.MyPetInfo == nil then
        log("UI_Pet_Lobby_Action:InitActionList PetSystem.MyPetInfo == nil")
        return
    end

    self.nCurPetID = PetSystem.MyPetInfo.equip_pet_id

    if self.nCurPetID == 0 then
        log("UI_Pet_Lobby_Action:InitActionList equip_pet_id = 0")
        return
    end

    for i, v in pairs(PetSystem.PetActionCfg) do
        if self.nCurPetID == v.PetID then
            local actionItemData = {}
            actionItemData.PetID = v.PetID
            actionItemData.PetActionID = v.PetActionID
            actionItemData.NeedLevel = PetSystem.GetUnlockActionNeedLevel(v.PetID, v.PetActionID)
            actionItemData.PetActionIcon = v.PetActionIcon
            --是否预览 是才展示在大厅中
            if v.ShowInLobby == 1 then
                table.insert(self.ArrayActionList, actionItemData)
            end
        end
    end

    self.LSGActionList:SetData(self.ArrayActionList)
end

function UI_Pet_Lobby_Action:OnRefreshActionListItem(widget, index)
    local itemData = self.LSGActionList:GetItemData(index)

    --解锁所需等级
    local strLevel = FuncUtil.LocalizeResFormat( "6417", itemData.NeedLevel);
    widget.Text_NeedLevel:SetText(strLevel)

    --图标
    local util = require("ui.util")
    util.SetTexture(widget.ImgActionIcon, itemData.PetActionIcon)

    if PetSystem.IsActionUnLock(self.nCurPetID, itemData.PetActionID) then
        widget.CP_PetActionLock:SetVisibility(UEnums.ESlateVisibility.Collapsed)

        local white = FSlateColor(FLinearColor(0.2, 0.2, 0.2, 1))
        widget.Text_NeedLevel:SetColorAndOpacity(white)

        widget.ImgActionIcon:SetColorAndOpacity(FSlateColor(FLinearColor(1, 1, 1, 1)))
    else
        widget.CP_PetActionLock:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)

        local red = FSlateColor(FLinearColor(1, 0, 0, 1))
        widget.Text_NeedLevel:SetColorAndOpacity(red)

        widget.ImgActionIcon:SetColorAndOpacity(FSlateColor(FLinearColor(1, 1, 1, 0.3)))
    end

    --选中状态
    if itemData.PetActionID == self.nCurPetActionID then
        widget.ImgSelected:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    else
        widget.ImgSelected:SetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
end

function UI_Pet_Lobby_Action:OnClickedActionItem(widget, index)
    local itemData = self.LSGActionList:GetItemData(index)

    self.nCurPetActionID = itemData.PetActionID
    self.LSGActionList:RefreshAllItems(self.ArrayActionList)

    PetSystem.pet_action_req(itemData.PetActionID)
    self:PlayAudio(require("client.slua.config.sound").click);
    ClientSendBAReport(BP_ENUM_MODULE_PET_PLAYACTION, 0);
end

function UI_Pet_Lobby_Action:OnRspPlayAction(eventType, eventID, petData)
    --MultipleAvatar.StopPetAction()

    --MultipleAvatar.PlayPetAction(petData.PetActionID)
end

function UI_Pet_Lobby_Action:PlayStartEnterAnimation()
    self.UIRoot:PlayAnimation(self.UIRoot.DX_Transitions_StartEnter, 0, 1, 0, 1);
end

function UI_Pet_Lobby_Action:PlayEnterAnimation()
    self.UIRoot:PlayAnimation(self.UIRoot.DX_Transitions_Enter, 0, 1, 0, 1);
end

local class = require("class")
local ui_base = require("ui.base")
local CUIPet_LObby_Action = class(ui_base, nil, UI_Pet_Lobby_Action)

return CUIPet_LObby_Action