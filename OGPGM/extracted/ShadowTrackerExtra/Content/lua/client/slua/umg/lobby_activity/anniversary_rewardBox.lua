local UI_Anniversary_RewardBox ={}

local AnniversaryActivitySystem = require("client.slua.logic.lobby_activity.logic_anniversary_activity")

function UI_Anniversary_RewardBox:ctor(selfType, id)
    --todo: 这里可以做些数据初始化工作
    self.boxID = id;
    self.config = AnniversaryActivitySystem.StageAwardConfig[id];
end

function UI_Anniversary_RewardBox:OnInitialize()
    UI_Anniversary_RewardBox.__super.OnInitialize(self)

    --todo: 在这里做些初始化工作
    self:SetItems();
    self:SetText();
    self:SetButtonState();
end

function UI_Anniversary_RewardBox:RegistEvents()
    UI_Anniversary_RewardBox.__super.RegistEvents(self)

    self:AddOnClickedEvent("Button_Close", AnniversaryActivitySystem.CloseRewardBox, self);

    self:AddOnClickedEvent("Button_OK", self.OnClaimButtonClick, self);

    for i = 1, 3 do
        
        self:AddControlEvent("icon" .. tostring(i) .. ".Button_item", "OnPressed", self.OnPressTips, self, i);

        self:AddControlEvent("icon" .. tostring(i) .. ".Button_item", "OnReleased", self.OnReleaseTips, self); 
    end

    --todo: 在这里注册事件
end

function UI_Anniversary_RewardBox:UnRegistEvents()
    --todo: 在这里反注册事件

    UI_Anniversary_RewardBox.__super.UnRegistEvents(self)
end

function UI_Anniversary_RewardBox:OnPostInitialize()
    UI_Anniversary_RewardBox.__super.OnPostInitialize(self)

    --todo: OnPostInitialize在OnInitialize、RegistEvents之后，有需要在RegistEvents后初始化的工作写这里
end

-- 仅在需要监听状态变化时写这个函数
--[[function UI_Template:OnModeSwitch(preStatus, currentStatus)
    
end
]]

function UI_Anniversary_RewardBox:Close()
    --todo: 这里做些消耗回收动作，注意UI_Template.__super.Close(self)一定要写在最后，遵循先进后出原则

    UI_Anniversary_RewardBox.__super.Close(self)
end

function UI_Anniversary_RewardBox:SetItems()
    for i = 1, 3 do
        local item = self.UIRoot["item" .. i];
        item:SetVisibility(UEnums.ESlateVisibility.Hidden);
    end

    for i, v in ipairs(self.config.award) do
        local item = self.UIRoot["item" .. i];
        item:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible);
        local icon = self.UIRoot["icon" .. i];
        icon:SetBlackBg(true);
        icon:SetIconAndQualityWithGender(v.id, 0);
        icon:SetCountText(v.num);
    end
end

function UI_Anniversary_RewardBox:OnPressTips(index)
    local config = self.config.award[index];
    if config then
        local item = self.UIRoot["icon" .. tostring(index)];
        local GlobalUIFunctionLibrary = slua.loadClass("/Game/UMG/UI_Utility/GlobalUIFunctionLibrary.GlobalUIFunctionLibrary");
        GlobalUIFunctionLibrary.ShowItemTipsByButton(tonumber(config.id), item.Button_item, 0, 0, true, self.UIRoot);
    end
end

function UI_Anniversary_RewardBox:OnReleaseTips()
    local GlobalUIFunctionLibrary = slua.loadClass("/Game/UMG/UI_Utility/GlobalUIFunctionLibrary.GlobalUIFunctionLibrary");
    GlobalUIFunctionLibrary.CloseItemTips(self.UIRoot);
end

function UI_Anniversary_RewardBox:SetText()
    local condition = self.config.cond;
    local current;
    if AnniversaryActivitySystem.TotalSnatchTimes < condition then
        current = AnniversaryActivitySystem.TotalSnatchTimes;
    else
        current = condition;
    end
    local str = GlobalData.GetLocalizeStringWithNum(6159, 0, tostring(condition), tostring(current), tostring(condition));
    self.UIRoot.Text_Content:SetText(str);
end

function UI_Anniversary_RewardBox:SetButtonState()
    if AnniversaryActivitySystem.StageAwardStageCondition[self.boxID] == 1 then
        self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(0);
    else
        self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(1);
    end 
end

function UI_Anniversary_RewardBox:OnClaimButtonClick()
    AnniversaryActivitySystem.take_award_of_anniversary_stage_award_req(self.boxID);
end

local class = require("class")
local ui_base = require("ui.base")
local CUIAnniversary_RewardBox = class(ui_base, nil, UI_Anniversary_RewardBox)

return CUIAnniversary_RewardBox