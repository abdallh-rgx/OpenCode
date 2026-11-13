local UI_RechargePurchase ={}
local KismetTextLibrary = import("KismetTextLibrary");
local updateTimer ;
local isScrollViewInited = false;

function UI_RechargePurchase:ctor(selfType, new)
    
end

function UI_RechargePurchase:OnInitialize()
    UI_RechargePurchase.__super.OnInitialize(self)
    self.ScrollView = self:InitScrollBox(self.UIRoot.ScrollView);
    updateTimer = Timer.InsertTimer(1, function ()
        self.ScrollView:RefreshAllItems()
    end, true, false);
    
    --todo: 在这里做些初始化工作
end

function UI_RechargePurchase:RegistEvents()
    UI_RechargePurchase.__super.RegistEvents(self)
    self:AddCommonEvent(EVENTTYPE_RECHARGE, EVENTID_RECHARGE_PURCHASE_INFO_CHANGE, self.SetScrollViewData, self);
    self.ScrollView:AddItemEvent("Button_Background","OnClicked", self.OnClickItemBackground, self);
    self.ScrollView:AddItemEvent("Button_Buy","OnClicked", self.OnClickItemBuy, self);
    self.ScrollView:AddItemEvent("Button_rate","OnClicked", self.OnClickRate, self);
    
    self.ScrollView:SetRefreshItemCallback(self.OnRefreshPurchaseItem, self)
    --todo: 在这里注册事件
end

function UI_RechargePurchase:UnRegistEvents()
    --todo: 在这里反注册事件
    
    UI_RechargePurchase.__super.UnRegistEvents(self)
end

function UI_RechargePurchase:OnPostInitialize()
    UI_RechargePurchase.__super.OnPostInitialize(self)

    --todo: OnPostInitialize在OnInitialize、RegistEvents之后，有需要在RegistEvents后初始化的工作写这里
    isScrollViewInited = false;
    self:InitUI();
end

function UI_RechargePurchase:OnRefreshPurchaseItem(widget, index)
    local info = RechargePurchaseSystem.RechargeInfoArray[index];
    if info == nil then
        log_error("OnRefreshPurchaseItem item is nil ,index = " .. index);
        return;
    end
    if info.endTime < NetUtil.GetCurServerTime() then
        log_tree("UI_RechargePurchase:OnRefreshPurchaseItem oneItem time out!!" ,info);
        table.remove(RechargePurchaseSystem.RechargeInfoArray,index);
        self:SetScrollViewData()
        return;
    end
    --widget:SetItem(info);
    local BusinessHelper = import("BusinessHelper")
    if string.match(string.lower(info.iconPath),"http") ~= nil then
        widget:StartDownloadImage(info.iconPath);
    else
        local iconImage = BusinessHelper.UIGetResWithPath(info.iconPath);
        widget.Image_BG:SetBrushFromTexture(iconImage, false);
    end
    if info.name == nil then
        log_error("UI_RechargePurchase:OnRefreshPurchaseItem name is nil!");
        log_tree("info:",info);
    end
    widget.TextBlock_Time:SetText(UI_RechargePurchase:GetTimeString(info));
    widget.TextBlock_Price:SetText(info.price);
    
    --0为不限购
    if info.num == 0 then
        widget.RichTextBlock_Limit:SetVisibility(UEnums.ESlateVisibility.Hidden);
    else
        widget.RichTextBlock_Limit:SetVisibility(UEnums.ESlateVisibility.Visible);
        widget.RichTextBlock_Limit:SetText(GlobalData.GetLocalizeStringWithNum(6750, 0,  info.num - info.leftnum, info.num));
    end
    --当活动时间配置超过10年，则认为是永久物品，否则限时物品显示倒计时
    if info.endTime - NetUtil.GetCurServerTime()>= 3600*24*365*10 then
        widget.Panel_Time:SetVisibility(UEnums.ESlateVisibility.Collapsed);
    else
        widget.Panel_Time:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible);
        widget.TextBlock_Time:SetText(self:GetTimeString(info));
    end
    --根据是否存在概率url来决定是否显示概率按钮
    if info.rateUrl == nil or info.rateUrl == "" then
        widget.Button_Probability:SetVisibility(UEnums.ESlateVisibility.Hidden);
    else
        widget.Button_Probability:SetVisibility(UEnums.ESlateVisibility.Visible);
    end

    if info.tag >=0 and info.tag <=2 then
        widget.Switcher_Tag:SetActiveWidgetIndex(info.tag)
    else
        widget.Switcher_Tag:SetActiveWidgetIndex(0)
    end

    if info.num ~=0 and info.leftnum > 0 then
        widget.Switcher_Sell:SetActiveWidgetIndex(0)
    else
        widget.Switcher_Sell:SetActiveWidgetIndex(1)
    end
    
    --根据售卖类型显示价格
    if info.purchaseType == RechargePurchaseSystem.purchase_type_cash then
        widget.TextBlock_price:SetText("₩" .. info.price)
        widget.Image_UC:SetVisibility(UEnums.ESlateVisibility.Collapsed);
    else
        widget.TextBlock_price:SetText(info.price)
        widget.Image_UC:SetVisibility(UEnums.ESlateVisibility.Visible);
    end
        
    -- 设置选中状态
    if index == self.ScrollView:GetSelectIndex() then
        widget.Image_Selected:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    else
        widget.Image_Selected:SetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
end




function UI_RechargePurchase:GetTimeString(info)
    local time = info.endTime - NetUtil.GetCurServerTime();
    local hour = time // 3600 ;
    local timeString = "";
    
    if hour >= 24 then
        local day = math.modf(hour / 24);
        timeString = GlobalData.GetLocalizeStringWithNum(4409, 0, day);
    else
        local minute = time % 3600 // 60;
        local second = time % 60;
        timeString = hour .. ":" .. minute .. ":" .. second;
    end

    return timeString;
end

function UI_RechargePurchase:OnClickItemBackground(widget, index)
    RechargePurchaseSystem.SelectedRechargeInfo = RechargePurchaseSystem.RechargeInfoArray[index];
    self.ScrollView:Select(index)
    RechargePurchaseSystem.SelectedId = RechargePurchaseSystem.SelectedRechargeInfo.activityId;
    log("UI_RechargePurchase.OnClickItemBackground index:".. index);
    log_tree("UI_RechargePurchase.OnClickItemBackground info:",RechargePurchaseSystem.SelectedRechargeInfo);
    --弹出礼包界面
    local uiManager = require("ui.manager");
    uiManager.ShowUI(uiManager.UI_Config.recharge_purchasePopup);
end

function UI_RechargePurchase:OnClickItemBuy(widget, index)
    RechargePurchaseSystem.SelectedRechargeInfo = RechargePurchaseSystem.RechargeInfoArray[index];
    RechargePurchaseSystem.SelectedNumber = 1;
    log_tree("UI_RechargePurchase.OnClickItemBuy info:",RechargePurchaseSystem.SelectedRechargeInfo);
    self.ScrollView:Select(index)
    RechargePurchaseSystem.SelectedId = RechargePurchaseSystem.SelectedRechargeInfo.activityId;

    RechargePurchaseSystem.PurchaseSelectedItem()
end

function UI_RechargePurchase:OnClickRate(widget, index)
    local info = RechargePurchaseSystem.RechargeInfoArray[index];
    if info == nil or info.rateUrl == nil then
        Client.OpenURL("https://cafe.naver.com/battlegroundsmobile/3", true)
    else
        Client.OpenURL(info.rateUrl, true)
    end
end

function UI_RechargePurchase:Close()
    --todo: 这里做些消耗回收动作，注意UI_Template.__super.Close(self)一定要写在最后，遵循先进后出原则
    Timer.RemoveTimer(updateTimer);
    UI_RechargePurchase.__super.Close(self)
end

function UI_RechargePurchase:InitUI()
    self:SetScrollViewData();
    if #RechargePurchaseSystem.RechargeInfoArray == 0 then
        self.UIRoot.PanelNothing:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible);
    else
        self.UIRoot.PanelNothing:SetVisibility(UEnums.ESlateVisibility.Collapsed);
    end
    --刷新红点信息
    RechargePurchaseSystem.RefreshRedDotInfo()
    self:SetLawUI()
end

--设置法律相关信息
function UI_RechargePurchase:SetLawUI()
    local strRegion = Client.GetPublishRegion()
    if strRegion == "KOREA" then
        self.UIRoot.CanvasPanel_Law2:SetVisibility(UEnums.ESlateVisibility.Visible)
        self.UIRoot.TextLaw2:SetText(GlobalData.GetLocalizeStringWithNum(4508, 0));
        self.UIRoot.TextLaw:SetText("청약철회 규정");
    elseif strRegion == "JAPAN" then
        self.UIRoot.CanvasPanel_Law2:SetVisibility(UEnums.ESlateVisibility.Collapsed)
        self.UIRoot.TextLaw:SetText("特定商取引法・資金決済法に基づく表記");
    end
    self:AddOnClickedEvent("Button_Law", self.OnClickLaw, self)
end

function UI_RechargePurchase:AndriodBack()
    local uiManager = require("ui.manager");
    if uiManager then
        uiManager.CloseUI(uiManager.UI_Config.recharge_mgr);
        uiManager.CloseUI(uiManager.UI_Config.recharge_purchase);
    end
end

function UI_RechargePurchase:SetScrollViewData()
    log_tree("UI_RechargePurchase:SetScrollViewData data:",RechargePurchaseSystem.RechargeInfoArray);
    if isScrollViewInited then
        self.ScrollView:RefreshAllItems(RechargePurchaseSystem.RechargeInfoArray)
    else
        self.ScrollView:SetData(RechargePurchaseSystem.RechargeInfoArray)
        isScrollViewInited = true;
    end
end

function UI_RechargePurchase:OnClickLaw()
    Client.OpenURL("http://cafe.naver.com/battlegroundsmobile/17158", true)
end

local class = require("class")
local ui_base = require("ui.base")
local CUIRechargePurchase = class(ui_base, nil, UI_RechargePurchase)

return CUIRechargePurchase