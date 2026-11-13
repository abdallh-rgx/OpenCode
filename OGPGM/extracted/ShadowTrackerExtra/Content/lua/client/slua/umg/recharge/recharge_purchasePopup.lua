local UI_RechargePurchasePopup ={}
local chestDropInfoList = {};
local popupInfo = {};


function UI_RechargePurchasePopup:ctor(selfType, new)
    --todo: 这里可以做些数据初始化工作
end

function UI_RechargePurchasePopup:OnInitialize()
    UI_RechargePurchasePopup.__super.OnInitialize(self)
    self.ScrollView = self:InitScrollBox(self.UIRoot.ScrollView);
    --todo: 在这里做些初始化工作
end

function UI_RechargePurchasePopup:RegistEvents()
    UI_RechargePurchasePopup.__super.RegistEvents(self)
    self:AddOnClickedEvent("Button_law", self.OnClickLaw, self)
    self:AddOnClickedEvent("Button_buy", self.OnClickPurchase, self)
    self:AddOnClickedEvent("Button_plus", self.OnClickPlus, self)
    self:AddOnClickedEvent("Button_minus", self.OnClickMinus, self)
    self:AddOnClickedEvent("Button_close", self.OnClickClose, self)
    
    self.ScrollView:SetRefreshItemCallback(self.OnRefreshChestItem, self)
    
    self:AddCommonEvent(EVENTTYPE_RECHARGE, EVENTID_RECHARGE_GET_CHEST_INFO, self.OnChestInfoUpdate, self);
    self:AddCommonEvent(EVENTTYPE_RECHARGE, EVENTID_RECHARGE_PURCHASE_INFO_CHANGE, self.InitUI, self);
    --todo: 在这里注册事件
end

function UI_RechargePurchasePopup:UnRegistEvents()
    --todo: 在这里反注册事件
    UI_RechargePurchasePopup.__super.UnRegistEvents(self)
end


function UI_RechargePurchasePopup:OnClickPurchase()
    if popupInfo.endTime < NetUtil.GetCurServerTime() then
        --弹出错误提示
        log_error("UI_RechargePurchasePopup:OnClickPurchase time out!")
        return;
    end
    RechargePurchaseSystem.PurchaseSelectedItem()
end

function UI_RechargePurchasePopup:OnClickLaw()
    Client.OpenURL("http://cafe.naver.com/battlegroundsmobile/17158", true)
end

function UI_RechargePurchasePopup:OnClickPlus()
    RechargePurchaseSystem.SelectedNumber = RechargePurchaseSystem.SelectedNumber + 1;
    if  RechargePurchaseSystem.SelectedRechargeInfo.num ~= 0 and RechargePurchaseSystem.SelectedNumber > RechargePurchaseSystem.SelectedRechargeInfo.leftnum then
        RechargePurchaseSystem.SelectedNumber = RechargePurchaseSystem.SelectedRechargeInfo.leftnum
    end
    self:SetSelectedNumberInfo()
end

function UI_RechargePurchasePopup:OnClickMinus()
    RechargePurchaseSystem.SelectedNumber = RechargePurchaseSystem.SelectedNumber - 1;
    if RechargePurchaseSystem.SelectedNumber < 0 then
        RechargePurchaseSystem.SelectedNumber = 0;
    elseif RechargePurchaseSystem.SelectedNumber < 1 then
        RechargePurchaseSystem.SelectedNumber = 1;
    end
    
    self:SetSelectedNumberInfo()
end

function UI_RechargePurchasePopup:OnClickClose()
    RechargePurchaseSystem.SelectedNumber = 1;
    local uiManager = require("ui.manager");
    uiManager.HideUI(uiManager.UI_Config.recharge_purchasePopup);
end

function UI_RechargePurchasePopup:OnPostInitialize()
    UI_RechargePurchasePopup.__super.OnPostInitialize(self)

    --todo: OnPostInitialize在OnInitialize、RegistEvents之后，有需要在RegistEvents后初始化的工作写这里
    self:InitUI();
end

-- 仅在需要监听状态变化时写这个函数
--[[function UI_Template:OnModeSwitch(preStatus, currentStatus)
    
end
]]

function UI_RechargePurchasePopup:Close()
    --todo: 这里做些消耗回收动作，注意UI_Template.__super.Close(self)一定要写在最后，遵循先进后出原则

    UI_RechargePurchasePopup.__super.Close(self)
end

function UI_RechargePurchasePopup:InitUI()
    if RechargePurchaseSystem.SelectedRechargeInfo == nil then
        log_error("UI_RechargePurchasePopup:InitUI info is null");
        return;
    end
    popupInfo = RechargePurchaseSystem.SelectedRechargeInfo;
    self:SetUI();
    RechargePurchaseSystem.GetSelectedChestInfo();
end

function UI_RechargePurchasePopup:SetUI()
    --self.ScrollView:SetData(RechargePurchaseSystem.ChestInfoList)

    local info = RechargePurchaseSystem.SelectedRechargeInfo;
    RechargePurchaseSystem.SelectedNumber = 1;
    if info.num ~= 0 and info.leftnum == 0 then
        RechargePurchaseSystem.SelectedNumber = 0;
        self.UIRoot.Switcher_Buy:SetActiveWidgetIndex(1);
    else
        self.UIRoot.Switcher_Buy:SetActiveWidgetIndex(0);
    end
    if info.num == 0 then
        self.UIRoot.TextBlock_limit:SetVisibility(UEnums.ESlateVisibility.Hidden);
    else
        self.UIRoot.TextBlock_limit:SetVisibility(UEnums.ESlateVisibility.Visible);
        self.UIRoot.TextBlock_limit:SetText(GlobalData.GetLocalizeStringWithNum(6750, 0,info.num - info.leftnum, info.num))
    end
    self:SetSelectedNumberInfo();
end

function UI_RechargePurchasePopup:OnRefreshChestItem(widget, index)
    local chestInfo = chestDropInfoList[index];
    log("UI_RechargePurchasePopup:OnRefreshChestItem index = " .. index)
    log_tree("UI_RechargePurchasePopup:OnRefreshChestItem",chestInfo);
    widget:SetInfo(chestInfo.DropItemID);
    widget:SetRateIcon(chestInfo.is_must_drop)
    widget:SetLimitTimeIcon(chestInfo.is_limit_time,chestInfo.DropItemTime);
    widget:SetCount(chestInfo.DropItemNum)
    widget:SetOwned(chestInfo.is_owned)
    widget.canShowTips = true;
end

function UI_RechargePurchasePopup:SetSelectedNumberInfo()
    self.UIRoot.TextBlock_Num:SetText(RechargePurchaseSystem.SelectedNumber)
    if RechargePurchaseSystem.SelectedNumber == 0 or RechargePurchaseSystem.SelectedNumber == 1 then
        self.UIRoot.Button_minus:SetVisibility(UEnums.ESlateVisibility.Hidden);
    else
        self.UIRoot.Button_minus:SetVisibility(UEnums.ESlateVisibility.Visible);
    end
    
    if RechargePurchaseSystem.SelectedRechargeInfo.num ~= 0 and RechargePurchaseSystem.SelectedNumber >= RechargePurchaseSystem.SelectedRechargeInfo.leftnum then
        self.UIRoot.Button_plus:SetVisibility(UEnums.ESlateVisibility.Hidden);
    else
        self.UIRoot.Button_plus:SetVisibility(UEnums.ESlateVisibility.Visible);
    end
    
    if RechargePurchaseSystem.SelectedRechargeInfo.purchaseType == RechargePurchaseSystem.purchase_type_cash then
        self.UIRoot.TextBlock_price:SetText("₩" .. RechargePurchaseSystem.SelectedRechargeInfo.price * RechargePurchaseSystem.SelectedNumber)
        self.UIRoot.Panel_Num:SetVisibility(UEnums.ESlateVisibility.Hidden);
        self.UIRoot.Image_uc:SetVisibility(UEnums.ESlateVisibility.Collapsed);
    else
        self.UIRoot.TextBlock_price:SetText(RechargePurchaseSystem.SelectedRechargeInfo.price * RechargePurchaseSystem.SelectedNumber)
        self.UIRoot.Panel_Num:SetVisibility(UEnums.ESlateVisibility.Visible);
        self.UIRoot.Image_uc:SetVisibility(UEnums.ESlateVisibility.Visible);
    end
end
-- 回包刷新数据
function UI_RechargePurchasePopup:OnChestInfoUpdate()
    if RechargePurchaseSystem.SelectedRechargeInfo == nil then
        log_error("UI_RechargePurchasePopup:OnChestInfoUpdate info is null");
        return;
    end
    local chestId = RechargePurchaseSystem.SelectedRechargeInfo.itemId;
    local dataList =  RechargePurchaseSystem.ChestInfoList[chestId];
    log_tree("UI_RechargePurchasePopup.OnChestInfoUpdate info :",dataList)
    chestDropInfoList = {};
    for index,data in pairs(dataList) do
        local dropData = {};
        dropData.DropItemID = data.DropItemID or 0;
        dropData.DropItemNum = data.DropItemNum or 0;
        dropData.DropRate = data.DropChance or 0;
        dropData.DropItemSort = data.DropItemSort or 0;
        dropData.DropItemTime = data.DropItemTime or 0;
        if dropData.DropItemTime == 0 then
            local cfg = Client.GetTableData("Item", dropData.DropItemID);
            if cfg and cfg.ValidTimes and cfg.ValidTimes ~= 0 then
                dropData.DropItemTime = cfg.ValidTimes;
            end
        end
        if dropData.DropItemTime ~= 0 then
            dropData.is_limit_time = true;
        else
            dropData.is_limit_time = false;
        end
        dropData.is_hot = false;
        dropData.is_new = false;
        dropData.is_must_drop = dropData.DropRate >= 1 --必得
        --与策划沟通此处无需显示已拥有
        dropData.is_owned = false;
        table.insert(chestDropInfoList,dropData)
    end

    table.sort(chestDropInfoList,function (a,b)
        return a.DropItemSort > b.DropItemSort;
    end)

    self.ScrollView:SetData(chestDropInfoList);
end


local class = require("class")
local ui_base = require("ui.base")
local CUIRechargePurchase_Popup = class(ui_base, nil, UI_RechargePurchasePopup)

return CUIRechargePurchase_Popup