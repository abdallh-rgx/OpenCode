--rain 宠物获取途径
local PetSystem = require("client.slua.logic.pet.logic_pet")
local UI_Pet_Access = {}

function UI_Pet_Access:ctor()
    --当前选中的宠物
    self.nCurPetID = 0
    self.nCurFoodID = 0
    self.enumAccessType = PetSystem.Enum_AccessType.EnumPet
end

function UI_Pet_Access:OnInitialize()
    UI_Pet_Access.__super.OnInitialize(self)
end

function UI_Pet_Access:RegistEvents()
    UI_Pet_Access.__super.RegistEvents(self)

    self:AddOnClickedEvent("Btn_Close", self.CloseUI, self);
    self:AddOnClickedEvent("Pet_Jump.Btn_Jump", self.OnClickedJump, self);
end

function UI_Pet_Access:UnRegistEvents()
    --todo: 在这里反注册事件
    UI_Pet_Access.__super.UnRegistEvents(self)
end

function UI_Pet_Access:OnPostInitialize()
    UI_Pet_Access.__super.OnPostInitialize(self)

    --todo: OnPostInitialize在OnInitialize、RegistEvents之后，有需要在RegistEvents后初始化的工作写这里
end

function UI_Pet_Access:Close()
    --todo: 这里做些消耗回收动作，注意UI_Template.__super.Close(self)一定要写在最后，遵循先进后出原则
    UI_Pet_Access.__super.Close(self)
end

function UI_Pet_Access:CloseUI()
    self:PlayAudio(require("client.slua.config.sound").close);

    local ui_manager = require("ui.manager");
    if ui_manager then
        ui_manager.CloseUI(ui_manager.UI_Config.pet_access)
    end
end

function UI_Pet_Access:SetData(petID, foodID, accessType)
    self.nCurPetID = petID
    self.nCurFoodID = foodID
    self.enumAccessType = accessType

    self:InitUI()
    self:InitJump()
end

function UI_Pet_Access:InitUI()
    local curPetData = PetSystem.GetPetItemCfgByPetID(self.nCurPetID)
    if curPetData == nil then
        log("UI_Pet_Access:InitUI curPetData is nil curPetID = " .. tostring(self.nCurPetID))
        return
    end

    if self.enumAccessType == PetSystem.Enum_AccessType.EnumPet then
        self.UIRoot.Text_Name:SetText(curPetData.PetName)

        if not PetSystem.HasPet(self.nCurPetID) then
            self.UIRoot.Text_PetNotAccess:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        end

        local CommonItemFunctionLibrary = slua.loadClass("/Game/UMG/UI_Logic/Common/CommonItemFunctionLibrary.CommonItemFunctionLibrary");
        local ui = self.UIRoot.Common_Item_All_UIBP
        CommonItemFunctionLibrary.SetItemIconAndQuality(curPetData.PetID, 0, ui.Image_Icon_Quality_Bottom,
                ui.Image_Quality_Bg, ui.Image_Icon, ui.SpecialIcon, self.UIRoot);
    else
        local foodInfo = Client.GetTableData("Item", self.nCurFoodID);
        if foodInfo == nil then
            log("UI_Pet_Access:InitUI nCurFoodID:" .. tostring(self.nCurFoodID))
            return
        end

        self.UIRoot.Text_Name:SetText(foodInfo.ItemName)


        local st = string.format(Client.GetTableData("LocalizeRes", "301222").TextValue, 0);
        local foodWardrobeData = DataMgr.GetHallDepotItemDataByResID(self.nCurFoodID)
        if foodWardrobeData ~= nil and foodWardrobeData.count > 0 then
            st = string.format(Client.GetTableData("LocalizeRes", "301222").TextValue, foodWardrobeData.count);
        end
        self.UIRoot.Text_FoodCnt:SetText(st)

        local CommonItemFunctionLibrary = slua.loadClass("/Game/UMG/UI_Logic/Common/CommonItemFunctionLibrary.CommonItemFunctionLibrary");
        local ui = self.UIRoot.Common_Item_All_UIBP
        CommonItemFunctionLibrary.SetItemIconAndQuality(self.nCurFoodID, 0, ui.Image_Icon_Quality_Bottom,
                ui.Image_Quality_Bg, ui.Image_Icon, ui.SpecialIcon, self.UIRoot);

        --CommonItemFunctionLibrary.SetCountText(foodCnt, ui.Common_Item_ALL_UIBP.Count, self.UIRoot);
    end
end

function UI_Pet_Access:InitJump()
    if self.enumAccessType == PetSystem.Enum_AccessType.EnumPet then
        local curPetData = PetSystem.GetPetItemCfgByPetID(self.nCurPetID)
        if curPetData == nil then
            log("UI_Pet_Access:InitAccessList curPetData is nil curPetID = " .. tostring(self.nCurPetID))
            return
        end

        if curPetData.JumpType == PetSystem.Enum_PetJumpType.EnumJumpToStore then
            self.UIRoot.Pet_Jump.Text_JumpType:SetText(Client.GetTableData("LocalizeRes", "6342").TextValue)
        elseif curPetData.JumpType == PetSystem.Enum_PetJumpType.EnumJumpToSupply then
            self.UIRoot.Pet_Jump.Text_JumpType:SetText(Client.GetTableData("LocalizeRes", "6473").TextValue)
        else
            self.UIRoot.Pet_Jump.Text_JumpType:SetText(Client.GetTableData("LocalizeRes", "502502").TextValue)
        end
    else
        self.UIRoot.Pet_Jump.Text_JumpType:SetText(Client.GetTableData("LocalizeRes", "6342").TextValue)
    end
end

function UI_Pet_Access:OnClickedJump()
    log("asdasdasd")
    self:PlayAudio(require("client.slua.config.sound").click);

    --bug=71450615 【ALL】宠物系统一期：人物+宠物 模式下跳转商城，会将宠物带进商城界面，关闭返回宠物界面后会出现两只宠物
    --bug=58799684 【ALL】商城宠物：宠物系统跳转到商城，界面混乱
    local ui_manager = require("ui.manager");
    if ui_manager then
        ui_manager.HideUI(ui_manager.UI_Config.pet_access)
        ui_manager.HideUI(ui_manager.UI_Config.pet_main)
    end

    if self.enumAccessType == PetSystem.Enum_AccessType.EnumPet then
        local curPetData = PetSystem.GetPetItemCfgByPetID(self.nCurPetID)
        if curPetData == nil then
            log("UI_Pet_Access:InitAccessList curPetData is nil curPetID = " .. tostring(self.nCurPetID))
            return
        end

        if curPetData.JumpType == PetSystem.Enum_PetJumpType.EnumJumpToStore then
            JumpUtils.JumpAll(JumpUtils.MODEL_ID_PET, curPetData.PetID)
        elseif curPetData.JumpType == PetSystem.Enum_PetJumpType.EnumJumpToSupply then
            JumpUtils.JumpAll(JumpUtils.MODEL_ID_PET, curPetData.PetID)
        else
            StoreFuncUtils.Jump(curPetData.JumpUrl)
        end
    else
        JumpUtils.JumpAll(JumpUtils.MODEL_ID_PET, self.nCurFoodID)
    end
end

local class = require("class")
local ui_base = require("ui.base")
local CUIPet_Access = class(ui_base, nil, UI_Pet_Access)

return CUIPet_Access