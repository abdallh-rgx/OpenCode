local UI_Anniversary_ExchangeConfirm ={}

local AnniversaryActivitySystem = require("client.slua.logic.lobby_activity.logic_anniversary_activity")

local exchangeTimes = 1;

function UI_Anniversary_ExchangeConfirm:ctor(selfType, id)
    --todo: 这里可以做些数据初始化工作
    self.exchangeId = id;
end

function UI_Anniversary_ExchangeConfirm:OnInitialize()
    UI_Anniversary_ExchangeConfirm.__super.OnInitialize(self)

    --todo: 在这里做些初始化工作
    exchangeTimes = 1;
end

function UI_Anniversary_ExchangeConfirm:RegistEvents()
    UI_Anniversary_ExchangeConfirm.__super.RegistEvents(self)

    self:AddOnClickedEvent("Button_CloseUI", AnniversaryActivitySystem.CloseExchangeConfirm, self);

    self:AddOnClickedEvent("Button_Exchange", self.OnClickExchange, self);

    self:AddOnClickedEvent("Button_Add", self.OnClickAdd, self);

    self:AddOnClickedEvent("Button_Sub", self.OnClickSub, self);

    self:AddOnClickedEvent("Button_Max", self.OnClickMax, self);

    --todo: 在这里注册事件
end

function UI_Anniversary_ExchangeConfirm:UnRegistEvents()
    --todo: 在这里反注册事件
    UI_Anniversary_ExchangeConfirm.__super.UnRegistEvents(self)
end

function UI_Anniversary_ExchangeConfirm:OnPostInitialize()
    UI_Anniversary_ExchangeConfirm.__super.OnPostInitialize(self)

    --todo: OnPostInitialize在OnInitialize、RegistEvents之后，有需要在RegistEvents后初始化的工作写这里
    self:InitUI();
end

-- 仅在需要监听状态变化时写这个函数
--[[function UI_Template:OnModeSwitch(preStatus, currentStatus)
    
end
]]

function UI_Anniversary_ExchangeConfirm:Close()
    --todo: 这里做些消耗回收动作，注意UI_Template.__super.Close(self)一定要写在最后，遵循先进后出原则

    UI_Anniversary_ExchangeConfirm.__super.Close(self)
end

function UI_Anniversary_ExchangeConfirm:InitUI()
    local config = AnniversaryActivitySystem.ExchangeInfoConfig[self.exchangeId];
    local itemConfig = config.exchange[1];

    self.UIRoot.item:SetBlackBg(true);
    self.UIRoot.item:SetIconAndQualityWithGender(itemConfig.id, 0);
    self.UIRoot.item:SetCountText(itemConfig.num);
    self:SetContent();
    local itemCfg = Client.GetTableData("Item", itemConfig.id);
    self.UIRoot.Text_Name:SetText(itemCfg.ItemName);
    self.UIRoot.Text_Desc:SetText(itemCfg.ItemDesc);
end

function UI_Anniversary_ExchangeConfirm:SetExchangeCount()
    local config = AnniversaryActivitySystem.ExchangeInfoConfig[self.exchangeId];
    local times = 0;
    if AnniversaryActivitySystem.ExchangConditon and AnniversaryActivitySystem.ExchangConditon[self.exchangeId] then
        times = AnniversaryActivitySystem.ExchangConditon[self.exchangeId];
    end
    
    local str = GlobalData.GetLocalizeStringWithNum(6413, 0, tostring(exchangeTimes), tostring(config.limit_times - times));
    self.UIRoot.Text_CanExchangeCount:SetText(str);
end

function UI_Anniversary_ExchangeConfirm:SetContent()
    local config = AnniversaryActivitySystem.ExchangeInfoConfig[self.exchangeId];
    self.UIRoot.Text_Count:SetText(tostring(exchangeTimes));
    local cost = config.cost_num * exchangeTimes;
    self.UIRoot.Text_Price:SetText(tostring(cost));
    self:SetExchangeCount();
end

function UI_Anniversary_ExchangeConfirm:OnClickExchange()
    AnniversaryActivitySystem.take_exchange_of_anniversary_activity_req(self.exchangeId, exchangeTimes);
end

function UI_Anniversary_ExchangeConfirm:OnClickAdd()
    local config = AnniversaryActivitySystem.ExchangeInfoConfig[self.exchangeId];
    if exchangeTimes < config.limit_times then
        exchangeTimes = exchangeTimes + 1;
        self:SetContent();
    end
end

function UI_Anniversary_ExchangeConfirm:OnClickSub()
    if exchangeTimes > 1 then
        exchangeTimes = exchangeTimes - 1;
        self:SetContent();
    end
end

function UI_Anniversary_ExchangeConfirm:OnClickMax()
    local config = AnniversaryActivitySystem.ExchangeInfoConfig[self.exchangeId];
    local times = 0;
    if AnniversaryActivitySystem.ExchangConditon and AnniversaryActivitySystem.ExchangConditon[self.exchangeId] then
        times = AnniversaryActivitySystem.ExchangConditon[self.exchangeId];
    end
    exchangeTimes = config.limit_times - times;
    self:SetContent();
end

local class = require("class")
local ui_base = require("ui.base")
local CUIAnniversary_ExchangeConfirm = class(ui_base, nil, UI_Anniversary_ExchangeConfirm)

return CUIAnniversary_ExchangeConfirm