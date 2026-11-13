--rain 宠物主界面
local PetSystem = require("client.slua.logic.pet.logic_pet")
local UI_Pet_Rename = {}

function UI_Pet_Rename:ctor()
    self.nCurPetID = 0
    self.strNewName = ""
end

function UI_Pet_Rename:OnInitialize()
    UI_Pet_Rename.__super.OnInitialize(self)

end

function UI_Pet_Rename:RegistEvents()
    UI_Pet_Rename.__super.RegistEvents(self)

    self:AddCommonEvent(EVENTTYPE_PET, EVENTID_PET_Rename, self.OnRspRename, self)

    self:AddOnClickedEvent("BtnClose", self.CloseUI, self);
    self:AddOnClickedEvent("Btn_Confirm", self.OnClickedConfirm, self);

    self:AddOnTextChangedEvent("EditableText_NewName", self.OnTextChangedNewName, self)
end

function UI_Pet_Rename:UnRegistEvents()
    --todo: 在这里反注册事件
    UI_Pet_Rename.__super.UnRegistEvents(self)
end

function UI_Pet_Rename:OnPostInitialize()
    UI_Pet_Rename.__super.OnPostInitialize(self)
end

-- 仅在需要监听状态变化时写这个函数
--[[function UI_Template:OnModeSwitch(preStatus, currentStatus)
    
end
]]

function UI_Pet_Rename:Close()
    --todo: 这里做些消耗回收动作，注意UI_Template.__super.Close(self)一定要写在最后，遵循先进后出原则
    UI_Pet_Rename.__super.Close(self)
end

function UI_Pet_Rename:CloseUI()
    self:PlayAudio(require("client.slua.config.sound").close);

    local ui_manager = require("ui.manager");
    if ui_manager then
        ui_manager.CloseUI(ui_manager.UI_Config.pet_rename)
    end
end

function UI_Pet_Rename:SetData(petID)
    self.nCurPetID = petID
    self:InitUI()
end

function UI_Pet_Rename:InitUI()
    local petData = PetSystem.GetPetDataByPetID(self.nCurPetID)
    if petData == nil then
        log("UI_Pet_Rename:InitUI petData is nil")
        return
    end

    --是否第一次改名
    if petData.name ~= nil then
        local cardCnt = 0
        local cardData = DataMgr.GetHallDepotItemDataByResID(1601005)
        if cardData ~= nil then
            cardCnt = cardData.count
        end

        local cardTips = FuncUtil.LocalizeResFormat( "6830", cardCnt, 1);
        self.UIRoot.Text_CardCnt:SetText(cardTips)
        self.UIRoot.WidgetSwitcherCard:SetActiveWidgetIndex(1)
    else
        self.UIRoot.WidgetSwitcherCard:SetActiveWidgetIndex(0)
    end
end

function UI_Pet_Rename:OnClickedConfirm()
    self:PlayAudio(require("client.slua.config.sound").click);

    --道具不足
    local petData = PetSystem.GetPetDataByPetID(self.nCurPetID)
    if petData == nil then
        log("UI_Pet_Rename:OnClickedConfirm petData is nil")
        return
    end
    if petData.name ~= nil then
        local cardData = DataMgr.GetHallDepotItemDataByResID(1601005)
        if cardData == nil or cardData.count == 0 then
            CommonMessageBoxUI:ShowPanel(2, FuncUtil.LocalizeResFormat("5077"),
                    FuncUtil.LocalizeResFormat("6406"),
                    function()
                        local ui_manager = require("ui.manager");
                        if ui_manager then
                            ui_manager.HideUI(ui_manager.UI_Config.pet_rename)
                            ui_manager.HideUI(ui_manager.UI_Config.pet_main)
                        end
                        JumpUtils.JumpAll(JumpUtils.MODEL_ID_PET, 1601005)
                    end
            )
            return
        end

    end

    PetSystem.pet_reanme_req(self.nCurPetID, self.strNewName)
end

function UI_Pet_Rename:OnTextChangedNewName(text)
    text = FuncUtil:StrTrim(text);
    _, _, self.strNewName = FuncUtil:CheckName(text,true, 14)
    self.UIRoot.EditableText_NewName:SetText(self.strNewName)
end

function UI_Pet_Rename:OnRspRename()
    ShowNotice(530014)
    self:CloseUI()
end

local class = require("class")
local ui_base = require("ui.base")
local CUIPet_Rename = class(ui_base, nil, UI_Pet_Rename)

return CUIPet_Rename