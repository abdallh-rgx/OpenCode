local Anniversary_exchangeStore ={}

local AnniversaryActivitySystem = require("client.slua.logic.lobby_activity.logic_anniversary_activity")

local KismetSystemLibrary = nil

local ItemList = {};

function Anniversary_exchangeStore:ctor()
    --todo: 这里可以做些数据初始化工作
    KismetSystemLibrary = import("KismetSystemLibrary");
end

function Anniversary_exchangeStore:OnInitialize()
    Anniversary_exchangeStore.__super.OnInitialize(self)

    --todo: 在这里做些初始化工作
    self:InitItemsWidget();
end

function Anniversary_exchangeStore:RegistEvents()
    Anniversary_exchangeStore.__super.RegistEvents(self)

    --todo: 在这里注册事件
    self:AddOnClickedEvent("Button_close", AnniversaryActivitySystem.CloseExchangeStore, self);

    self:AddOnClickedEvent("Button_help", AnniversaryActivitySystem.OpenPopNotice, self);

    for i, v in ipairs(ItemList) do
        self:AddControlEvent(KismetSystemLibrary.GetObjectName(v.button_tips), "OnPressed", self.OnButtonTipsPress, self, i);
        self:AddControlEvent(KismetSystemLibrary.GetObjectName(v.button_tips), "OnReleased", self.OnButtonTipsRelease, self, i);
        self:AddOnClickedEvent(KismetSystemLibrary.GetObjectName(v.button_exchange), self.OnClickExchange, self, i);
    end
    
    self.OnExchange = function()
        self:SetItems();
    end
    
    EventSystem:registEvent(EVENTTYPE_ACTIVITY, EVENTID_ANNIVERSARY_EXCHANGE, self.OnExchange);
end

function Anniversary_exchangeStore:UnRegistEvents()
    --todo: 在这里反注册事件
    EventSystem:unregistEvent(EVENTTYPE_ACTIVITY, EVENTID_ANNIVERSARY_EXCHANGE, self.OnExchange);
    Anniversary_exchangeStore.__super.UnRegistEvents(self)
end

function Anniversary_exchangeStore:OnPostInitialize()
    Anniversary_exchangeStore.__super.OnPostInitialize(self)

    --todo: OnPostInitialize在OnInitialize、RegistEvents之后，有需要在RegistEvents后初始化的工作写这里
    self:SetItems();
end

-- 仅在需要监听状态变化时写这个函数
--[[function UI_Template:OnModeSwitch(preStatus, currentStatus)
    
end
]]

function Anniversary_exchangeStore:Close()
    --todo: 这里做些消耗回收动作，注意UI_Template.__super.Close(self)一定要写在最后，遵循先进后出原则
    
    Anniversary_exchangeStore.__super.Close(self)
end

function Anniversary_exchangeStore:InitItemsWidget()
    ItemList = {};
    local item1 = 
    {
        button_tips = self.UIRoot.Button_1_up,
        button_exchange = self.UIRoot.Button_1_down,
        switcher_hasExchange = self.UIRoot.WidgetSwitcher_0,
        text_itemName = self.UIRoot.Text_ItemName1,
        switcher_hasEnough = self.UIRoot.WidgetSwitcher_1,
        image_mask = self.UIRoot.Image_Invalid01,
        text_costBlue = self.UIRoot.TextRed_1,
        text_costRed = self.UIRoot.TextBlue_1,
        text_progress = self.UIRoot.Text_Progress01;
    }
    table.insert(ItemList, item1);
    
    local item2 = 
    {
        button_tips = self.UIRoot.Button_2_up,
        button_exchange = self.UIRoot.Button_2_down,
        switcher_hasExchange = self.UIRoot.WidgetSwitcher_2,
        text_itemName = self.UIRoot.Text_ItemName2,
        switcher_hasEnough = self.UIRoot.WidgetSwitcher_3,
        image_mask = self.UIRoot.Image_Invalid02,
        text_costBlue = self.UIRoot.TextRed_2,
        text_costRed = self.UIRoot.TextBlue_2,
        text_progress = self.UIRoot.Text_Progress02;
    }
    table.insert(ItemList, item2);

    local item3 =
    {
        button_tips = self.UIRoot.Button_3_up,
        button_exchange = self.UIRoot.Button_3_down,
        switcher_hasExchange = self.UIRoot.WidgetSwitcher_4,
        text_itemName = self.UIRoot.Text_ItemName3,
        switcher_hasEnough = self.UIRoot.WidgetSwitcher_5,
        image_mask = self.UIRoot.Image_Invalid03,
        text_costBlue = self.UIRoot.TextRed_3,
        text_costRed = self.UIRoot.TextBlue_3,
        text_progress = self.UIRoot.Text_Progress03;
    }
    table.insert(ItemList, item3);

    local item4 =
    {
        button_tips = self.UIRoot.Button_4_up,
        button_exchange = self.UIRoot.Button_4_down,
        switcher_hasExchange = self.UIRoot.WidgetSwitcher_6,
        text_itemName = self.UIRoot.Text_ItemName4,
        switcher_hasEnough = self.UIRoot.WidgetSwitcher_7,
        image_mask = self.UIRoot.Image_Invalid04,
        text_costBlue = self.UIRoot.TextRed_4,
        text_costRed = self.UIRoot.TextBlue_4,
        text_progress = self.UIRoot.Text_Progress4;
    }
    table.insert(ItemList, item4);

    local item5 =
    {
        button_tips = self.UIRoot.Button_5_up,
        button_exchange = self.UIRoot.Button_5_down,
        switcher_hasExchange = self.UIRoot.WidgetSwitcher_8,
        text_itemName = self.UIRoot.Text_ItemName5,
        switcher_hasEnough = self.UIRoot.WidgetSwitcher_9,
        image_mask = self.UIRoot.Image_Invalid05,
        text_costBlue = self.UIRoot.TextRed_5,
        text_costRed = self.UIRoot.TextBlue_5,
        text_progress = self.UIRoot.Text_Progress5;
    }
    table.insert(ItemList, item5);

    local item6 =
    {
        button_tips = self.UIRoot.Button_6_up,
        button_exchange = self.UIRoot.Button_6_down,
        switcher_hasExchange = self.UIRoot.WidgetSwitcher_10,
        text_itemName = self.UIRoot.Text_ItemName6,
        switcher_hasEnough = self.UIRoot.WidgetSwitcher_11,
        image_mask = self.UIRoot.Image_Invalid06,
        text_costBlue = self.UIRoot.TextRed_6,
        text_costRed = self.UIRoot.TextBlue_6,
        text_progress = self.UIRoot.Text_Progress6;
    }
    table.insert(ItemList, item6);

    local item7 =
    {
        button_tips = self.UIRoot.Button_7_up,
        button_exchange = self.UIRoot.Button_7_down,
        switcher_hasExchange = self.UIRoot.WidgetSwitcher_12,
        text_itemName = self.UIRoot.Text_ItemName7,
        switcher_hasEnough = self.UIRoot.WidgetSwitcher_13,
        image_mask = self.UIRoot.Image_Invalid07,
        text_costBlue = self.UIRoot.TextRed_7,
        text_costRed = self.UIRoot.TextBlue_7,
        text_progress = self.UIRoot.Text_Progress7;
    }
    table.insert(ItemList, item7);

    local item8 =
    {
        button_tips = self.UIRoot.Button_8_up,
        button_exchange = self.UIRoot.Button_8_down,
        switcher_hasExchange = self.UIRoot.WidgetSwitcher_14,
        text_itemName = self.UIRoot.Text_ItemName8,
        switcher_hasEnough = self.UIRoot.WidgetSwitcher_15,
        image_mask = self.UIRoot.Image_Invalid08,
        text_costBlue = self.UIRoot.TextRed_8,
        text_costRed = self.UIRoot.TextBlue_8,
        text_progress = self.UIRoot.Text_Progress8;
    }
    table.insert(ItemList, item8);

    local item9 =
    {
        button_tips = self.UIRoot.Button_9_up,
        button_exchange = self.UIRoot.Button_9_down,
        switcher_hasExchange = self.UIRoot.WidgetSwitcher_16,
        text_itemName = self.UIRoot.Text_ItemName9,
        switcher_hasEnough = self.UIRoot.WidgetSwitcher_17,
        image_mask = self.UIRoot.Image_Invalid09,
        text_costBlue = self.UIRoot.TextRed_9,
        text_costRed = self.UIRoot.TextBlue_9,
        text_progress = self.UIRoot.Text_Progress9;
    }
    table.insert(ItemList, item9);
    
    local item10 = 
    {
        button_tips = self.UIRoot.Button_10_up,
        button_exchange = self.UIRoot.Button_10_down,
        switcher_hasExchange = self.UIRoot.WidgetSwitcher_19,
        text_itemName = self.UIRoot.Text_ItemName10,
        switcher_hasEnough = self.UIRoot.WidgetSwitcher_18,
        image_mask = self.UIRoot.Image_Invalid10,
        text_costBlue = self.UIRoot.TextRed_10,
        text_costRed = self.UIRoot.TextBlue_10,
        text_progress = self.UIRoot.Text_Progress10;
    }
    table.insert(ItemList, item10);
end

function Anniversary_exchangeStore:SetItems()
    local config = AnniversaryActivitySystem.ExchangeInfoConfig;
    local condition = AnniversaryActivitySystem.ExchangConditon;
    for i, v in ipairs(config) do
        local item = ItemList[i];
        if item then
            if condition[i] and condition[i] >= v.limit_times then
                item.image_mask:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
                item.switcher_hasExchange:SetActiveWidgetIndex(1);
                if item.text_progress then
                    local current = condition[i] or 0;
                    log("current " .. tostring(current));
                    item.text_progress:SetText(tostring(current) .. "/" .. tostring(v.limit_times));
                end
            else
                item.image_mask:SetVisibility(UEnums.ESlateVisibility.Hidden)
                item.switcher_hasExchange:SetActiveWidgetIndex(0);
                item.text_costBlue:SetText(config[i].cost_num);
                item.text_costRed:SetText(config[i].cost_num);
                if AnniversaryActivitySystem.GetDebrisItemCount() >= v.cost_num then
                    item.switcher_hasEnough:SetActiveWidgetIndex(1);
                else
                    item.switcher_hasEnough:SetActiveWidgetIndex(0);
                end
                if item.text_progress then
                    local current = condition[i] or 0;
                    log("current " .. tostring(current));
                    item.text_progress:SetText(tostring(current) .. "/" .. tostring(v.limit_times));
                end
            end
        end
        --if condition[1] and condition[1] >= config[1].limit_times and condition[10] and condition[10] >= config[10].limit_times  then
        --    ItemList[1].image_mask:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        --else
        --    ItemList[1].image_mask:SetVisibility(UEnums.ESlateVisibility.Hidden)
        --end
    end
    
    local count = AnniversaryActivitySystem.GetDebrisItemCount();
    self.UIRoot.Text_Debris:SetText(tostring(count));
    self.UIRoot.Text_DebrisBlue:SetText(tostring(count));
    if count == 0 then
        self.UIRoot.WidgetSwitcher_price:SetActiveWidgetIndex(0);
    else
        self.UIRoot.WidgetSwitcher_price:SetActiveWidgetIndex(1);
    end
end

function Anniversary_exchangeStore:OnButtonTipsPress(id)
    log("OnButtonTipsPress");
    local item = ItemList[id];
    local config = AnniversaryActivitySystem.ExchangeInfoConfig;
    local GlobalUIFunctionLibrary = slua.loadClass("/Game/UMG/UI_Utility/GlobalUIFunctionLibrary.GlobalUIFunctionLibrary");
    GlobalUIFunctionLibrary.ShowItemTipsByButton(config[id].exchange[1].id, item.button_tips, 0, 0, true, self.UIRoot);
end

function Anniversary_exchangeStore:OnButtonTipsRelease(id)
    log("OnButtonTipsRelease");
    local GlobalUIFunctionLibrary = slua.loadClass("/Game/UMG/UI_Utility/GlobalUIFunctionLibrary.GlobalUIFunctionLibrary");
    GlobalUIFunctionLibrary.CloseItemTips(self.UIRoot);
end

function Anniversary_exchangeStore:OnClickExchange(id)
    AnniversaryActivitySystem.OpenExchangeConfirm(id);
end

local class = require("class")
local ui_base = require("ui.base")
local CAnniversary_exchangeStore = class(ui_base, nil, Anniversary_exchangeStore)

return CAnniversary_exchangeStore