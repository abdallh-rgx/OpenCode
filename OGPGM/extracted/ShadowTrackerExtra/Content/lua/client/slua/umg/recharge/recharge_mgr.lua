local UI_RechargeMgr ={}
local KismetTextLibrary = import("KismetTextLibrary");
local index = 0;
local uiManager = require("ui.manager");

function UI_RechargeMgr:ctor(selfType, new)
    --todo: 这里可以做些数据初始化工作
end

function UI_RechargeMgr:OnInitialize()
    UI_RechargeMgr.__super.OnInitialize(self)
    index = 0;
    --todo: 在这里做些初始化工作
end

function UI_RechargeMgr:RegistEvents()
    UI_RechargeMgr.__super.RegistEvents(self)
    self:AddOnClickedEvent("rechargeButton", self.OnClickRecharge, self);
    self:AddOnClickedEvent("purchaseButton", self.OnClickPurchase, self);
    self:AddOnClickedEvent("closeButton", self.OnClickClose, self);
    self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_TICKET_CHANGE, self.RefreshUC, self);
    --self:AddCommonEvent(EVENTTYPE_SHARE, EVENTID_UPDATE_LEVELUPUI, self.OnShare, self);
    --todo: 在这里注册事件
end

function UI_RechargeMgr:UnRegistEvents()
    --todo: 在这里反注册事件
    UI_RechargeMgr.__super.UnRegistEvents(self)
end

function UI_RechargeMgr:OnClickRecharge()
    if index == 0 then
        return;
    end
    index = 0;
    self:SelectWidgetIndex(index)
    self:HideAll();
    RechargeJKUI:Init();
    
    --为了保持层级需要重新show
    uiManager.ShowUI(uiManager.UI_Config.recharge_mgr);
end

function UI_RechargeMgr:RefreshUC()
    self.UIRoot.TextBlock_UC:SetText(DataMgr.ticket);
end

--监听andriod返回键
function UI_RechargeMgr:AndriodBack()
    self:OnClickClose();
end

function UI_RechargeMgr:OnClickPurchase()
    if index == 1 then
        return;
    end
    index = 1;
    self:SelectWidgetIndex(index)
    self:HideAll();

    self.UIRoot.RedPointPurchase:SetVisibility(UEnums.ESlateVisibility.Collapsed)
    
    uiManager.ShowUI(uiManager.UI_Config.recharge_purchase);
    
    --为了保持层级需要重新show
    uiManager.ShowUI(uiManager.UI_Config.recharge_mgr);
end
function UI_RechargeMgr:OnClickClose()
    self:HideAll()
    uiManager.CloseUI(uiManager.UI_Config.recharge_mgr);
end
--隐藏所有其他界面
function UI_RechargeMgr:HideAll()
    LuaClassObj.HandleUIMessage(bp_rechargeJK, "UIHide");
    uiManager.HideUI(uiManager.UI_Config.recharge_purchase);
end

function UI_RechargeMgr:SelectWidgetIndex(widgetIndex)
    self.UIRoot.purchaseSwitch:SetActiveWidgetIndex(0);
    self.UIRoot.rechargeSwitch:SetActiveWidgetIndex(0);

    if widgetIndex == 0 then
        self.UIRoot.purchaseSwitch:SetActiveWidgetIndex(1);
        
    elseif widgetIndex == 1 then
        self.UIRoot.rechargeSwitch:SetActiveWidgetIndex(1);
    else
        self.UIRoot.purchaseSwitch:SetActiveWidgetIndex(1);
    end

end

function UI_RechargeMgr:OnPostInitialize()
    UI_RechargeMgr.__super.OnPostInitialize(self)

    --todo: OnPostInitialize在OnInitialize、RegistEvents之后，有需要在RegistEvents后初始化的工作写这里
    self:InitUI();
end

-- 仅在需要监听状态变化时写这个函数
--[[function UI_Template:OnModeSwitch(preStatus, currentStatus)
    
end
]]

function UI_RechargeMgr:Close()
    --todo: 这里做些消耗回收动作，注意UI_Template.__super.Close(self)一定要写在最后，遵循先进后出原则

    UI_RechargeMgr.__super.Close(self)
end

function UI_RechargeMgr:InitUI()
    self:SetUI();
end

--是否显示右边页签部分的UI，目前仅韩国会有直购系统
function UI_RechargeMgr:CanShowRightUI()
    local strRegion = Client.GetPublishRegion();
    if strRegion == "JAPAN" or strRegion == "KOREA" then
        if LoginSystem.ip_region == "KR" then
            return true;
        end
    end
    return false;
end

function UI_RechargeMgr:SetUI()
    self:SelectWidgetIndex(0);
    self.UIRoot.TextBlock_UC:SetText(DataMgr.ticket);

    if self:CanShowRightUI() then
        self.UIRoot.CanvasPanel:SetVisibility(UEnums.ESlateVisibility.Visible)
        RechargePurchaseSystem.CheckNeedShowRedDot();
        if RechargePurchaseSystem.NeedShowRedDot then
            self.UIRoot.RedPointPurchase:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        else
            self.UIRoot.RedPointPurchase:SetVisibility(UEnums.ESlateVisibility.Collapsed)
        end
    else
        self.UIRoot.CanvasPanel:SetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
end



local class = require("class")
local ui_base = require("ui.base")
local CUIRechargeMgr = class(ui_base, nil, UI_RechargeMgr)

return CUIRechargeMgr