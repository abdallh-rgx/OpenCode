-- 订阅主界面

local UI_Subscribe_Buy = {}

function UI_Subscribe_Buy:ctor()
    --这里可以做些数据初始化工作

end

function UI_Subscribe_Buy:OnInitialize()
    UI_Subscribe_Buy.__super.OnInitialize(self)
    --在这里做些初始化工作
end

function UI_Subscribe_Buy:RegistEvents()
    UI_Subscribe_Buy.__super.RegistEvents(self)
    -- 在这里注册事件
    self:AddOnClickedEvent("Button_close", self.CloseSubscribeUI, self)
    self:AddOnClickedEvent("Button_buy_Normal", self.On_Click_Buy_Normal, self)
    self:AddOnClickedEvent("Button_buy_Super", self.On_Click_Buy_Super, self)
    self:AddOnClickedEvent("Button_rule", self.On_Click_Help, self)

    self:AddCommonEvent(EVENTTYPE_SUBSCRIBE, EVENTID_SUBSCRIBE_Buy_Succeed, self.CloseSubscribeUI, self)
end

function UI_Subscribe_Buy:UnRegistEvents()

    -- 在这里反注册事件
    UI_Subscribe_Buy.__super.UnRegistEvents(self)
end

function UI_Subscribe_Buy:OnPostInitialize()
    --OnPostInitialize在OnInitialize、RegistEvents之后，有需要在RegistEvents后初始化的工作写这里

    UI_Subscribe_Buy.__super.OnPostInitialize(self)
    log_tree("NewSubscribeSystem._SuperInfo._InfoList", NewSubscribeSystem._SuperInfo._InfoList)
    for i, v in pairs(NewSubscribeSystem._SuperInfo._InfoList) do
        local childItem = slua.loadUI("/Game/UMG/UI_BP/Lobby_Store_Int/Lobby_Store_Member0115_slot1_UIBP.Lobby_Store_Member0115_slot1_UIBP")
        if childItem then
            self.UIRoot.WrapBox_Super_Describe:AddChild(childItem)
            childItem.TextBlock_PLUSInfo:SetText(v.Describe)
        end
    end

    for i, v in pairs(NewSubscribeSystem._NormalInfo._InfoList) do
        local childItem = slua.loadUI("/Game/UMG/UI_BP/Lobby_Store_Int/Lobby_Store_Member0115_slot2_UIBP.Lobby_Store_Member0115_slot2_UIBP")
        if childItem then
            self.UIRoot.WrapBox_1:AddChild(childItem)
            childItem.TextBlock_10:SetText(v.Describe)
        end
    end
    NewSubscribeSystem.LoadPrice()
    self:RefreshPrice()
    log_tree("NewSubscribeSystem._SuperInfo._DropAwardList",NewSubscribeSystem._SuperInfo._DropAwardList)
    for i, v in pairs(NewSubscribeSystem._SuperInfo._DropAwardList) do
        local childItem = slua.loadUI("/Game/UMG/UI_BP/Lobby_Store_Int/Lobby_Store_Member_item02_UIBP.Lobby_Store_Member_item02_UIBP")
        if childItem then
            self.UIRoot.WrapBox_SuperHighAward:AddChild(childItem)
            childItem:UISHOW(v.itemid,v.itemnum)
        end
    end
end

-- 仅在需要监听状态变化时写这个函数
--[[function UI_Subscribe_Buy:OnModeSwitch(preStatus, currentStatus)
end
]]
function UI_Subscribe_Buy:Close()
    --todo这里做些消耗回收动作，注意UI_Subscribe.__super.Close(self)一定要写在最后，遵循先进后出原则
    UI_Subscribe_Buy.__super.Close(self)
end

function UI_Subscribe_Buy:CloseSubscribeUI()
    self:PlayAudio(require("client.slua.config.sound").close);
    local uiManager = require("ui.manager");
    if uiManager then
        uiManager.CloseUI(uiManager.UI_Config.ui_subscribe_buy)

    end

end

function UI_Subscribe_Buy:RefreshPrice()
    --高级会员 firstmonth_superpriceoldprice	旧价格
    --高级会员  firstmonth_superprice	价格
    self.UIRoot.firstmonth_normal_price:SetText(NewSubscribeSystem.Get_Price(NewSubscribeSystem.ENUM_SubId.Normal))
    self.UIRoot.firstmonth_superprice:SetText(NewSubscribeSystem.Get_First_Month_Price())
    if NewSubscribeSystem.Get_First_Month_Price() == "" then
        --说明没有首月折扣
        self.UIRoot.super_discount:SetVisibility(UEnums.ESlateVisibility.Collapsed)
        self.UIRoot.TextBlock_3:SetVisibility(UEnums.ESlateVisibility.Collapsed)
        self.UIRoot.firstmonth_superprice:SetText(NewSubscribeSystem.Get_Price(NewSubscribeSystem.ENUM_SubId.Super))

    else
        self.UIRoot.super_discount:SetVisibility(UEnums.ESlateVisibility.Visible)
        self.UIRoot.firstmonth_superprice:SetText(NewSubscribeSystem.Get_First_Month_Price())
        self.UIRoot.firstmonth_superpriceoldprice:SetText(NewSubscribeSystem.Get_Price(NewSubscribeSystem.ENUM_SubId.Super))
        self.UIRoot.TextBlock_3:SetVisibility(UEnums.ESlateVisibility.Visible)
    end
end

function UI_Subscribe_Buy:On_Click_Buy_Normal()

    local uiManager = require("ui.manager")
    if uiManager then
        uiManager.ShowUI(uiManager.UI_Config.ui_subscribe_confirm_buy,NewSubscribeSystem.ENUM_SubId.Normal)
    end

    self:PlayAudio(require("client.slua.config.sound").confirm);
end

function UI_Subscribe_Buy:On_Click_Buy_Super()
    local uiManager = require("ui.manager")
    if uiManager then
        uiManager.ShowUI(uiManager.UI_Config.ui_subscribe_confirm_buy,NewSubscribeSystem.ENUM_SubId.Super)
    end

    self:PlayAudio(require("client.slua.config.sound").confirm);
end

function UI_Subscribe_Buy:On_Click_Help()
    local title = FuncUtil.GetLocalizeResStr("6371")
    local content = FuncUtil.GetLocalizeResStr("6372")
    PopUpNoticeUI.ShowMessageBox(title, content);
    self:PlayAudio(require("client.slua.config.sound").confirm);
end

local class = require("class")
local ui_base = require("ui.base")
local CUISubscribe = class(ui_base, nil, UI_Subscribe_Buy)
return CUISubscribe