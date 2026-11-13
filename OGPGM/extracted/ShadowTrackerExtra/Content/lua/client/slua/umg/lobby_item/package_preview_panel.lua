local PackagePreviewPanel ={}

local chestDropInfoList ={}

function PackagePreviewPanel:ctor(selfType, itemID)
    self.itemID = itemID;
    --todo: 这里可以做些数据初始化工作
end

function PackagePreviewPanel:OnInitialize()
    PackagePreviewPanel.__super.OnInitialize(self)
    self.scrollbox = self:InitScrollBox(self.UIRoot.LoopScrollGrid_0)
    --todo: 在这里做些初始化工作
    self:SetWidgetVisible(self.UIRoot.RateBtn, false, true);
end

function PackagePreviewPanel:RegistEvents()
    PackagePreviewPanel.__super.RegistEvents(self)
    self:AddOnClickedEvent("Button_close", self.OnClickClose, self);
    self:AddOnClickedEvent("RateBtn", self.OnClickRateBtn, self);
    self:AddCommonEvent(EVENTTYPE_RECHARGE, EVENTID_RECHARGE_GET_CHEST_INFO, self.OnChestInfoUpdate, self);
    self.scrollbox:SetRefreshItemCallback(self.OnRefreshChestItem, self)
    --todo: 在这里注册事件
end

function PackagePreviewPanel:UnRegistEvents()
    --todo: 在这里反注册事件

    PackagePreviewPanel.__super.UnRegistEvents(self)
end

function PackagePreviewPanel:OnPostInitialize()
    PackagePreviewPanel.__super.OnPostInitialize(self)
    self:InitUI();
    --todo: OnPostInitialize在OnInitialize、RegistEvents之后，有需要在RegistEvents后初始化的工作写这里
end

-- 仅在需要监听状态变化时写这个函数
--[[function UI_Template:OnModeSwitch(preStatus, currentStatus)

end
]]

function PackagePreviewPanel:Close()
    --todo: 这里做些消耗回收动作，注意UI_Template.__super.Close(self)一定要写在最后，遵循先进后出原则

    PackagePreviewPanel.__super.Close(self)
end

function PackagePreviewPanel:InitUI()
    self.UIRoot.HorizontalBox_0:SetVisibility(UEnums.ESlateVisibility.Collapsed);
    RechargePurchaseSystem.get_content_by_chestid(self.itemID);
end

function PackagePreviewPanel:OnChestInfoUpdate(eventType, id, data)
    self.UIRoot.HorizontalBox_0:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible);
    chestDropInfoList = {};
    self.UIRoot.StoreItem_BP_01_C_0:SetInfo(self.itemID);

    local itemCfg = Client.GetTableData("Item", self.itemID);
    local showRateBtn = itemCfg.RateType and itemCfg.RateType ~= 0 or false;
    self:SetWidgetVisible(self.UIRoot.RateBtn, showRateBtn, true);
    self.UIRoot.StoreItem_DetailInfo_Logic_BP:SetDetailInfo(itemCfg.ItemName, itemCfg.ItemQuality, itemCfg.ItemDesc, 0, itemCfg.StoreDetailImage, 0, 0, 0, 0, 0);
    self.data = data;
    --log_tree("UI_RechargePurchasePopup:data",data);
    for index,data in pairs(self.data) do
        local dropData = {};
        dropData.DropItemID = data.DropItemID or 0;
        dropData.DropItemNum = data.DropItemNum or 0;
        dropData.DropRate = data.DropChance or 0;
        dropData.DropItemSort = data.DropItemSort or 0;
        dropData.limit_end_time = data.DropItemTime or 0;
        dropData.is_limit_time = dropData.limit_end_time ~= 0;
        local cfg = Client.GetTableData("Item", dropData.DropItemID);
        if dropData.limit_end_time == 0 then
            if cfg and cfg.ValidTimes and cfg.ValidTimes ~= 0 then
                dropData.limit_end_time = cfg.ValidTimes;
                dropData.is_limit_time = true;
            else
                dropData.limit_end_time = 0;
                dropData.is_limit_time = false;
            end
        end
        dropData.is_hot = false;
        dropData.is_new = false;
        dropData.is_must_drop = dropData.DropRate >= 1 --必得
        --已拥有：必得的永久物品且配置了减免的且玩家拥有的物品，会出现已拥有标记。（且该物品减免相应价格，且该物品不会发货。） 策划案原话
        dropData.is_owned = dropData.is_must_drop == true --必得
                and not dropData.is_limit_time	--永久
                and DataMgr.GetHallDepotItemDataByResID(dropData.DropItemID) ~= nil;	--已拥有
        table.insert(chestDropInfoList,dropData)
    end
    self.scrollbox:SetData(chestDropInfoList);
end

function PackagePreviewPanel:OnRefreshChestItem(widget, index)
    local chestInfo = chestDropInfoList[index];
    log("UI_RechargePurchasePopup:OnRefreshChestItem index = " .. index)
    log_tree("UI_RechargePurchasePopup:OnRefreshChestItem",chestInfo);
    widget:SetSize(81, 81);
    widget:SetInfo(chestInfo.DropItemID);
    widget:SetRateIcon(chestInfo.is_must_drop);
    widget:SetLimitTimeIcon(chestInfo.is_limit_time, chestInfo.limit_end_time);
    widget:SetCount(chestInfo.DropItemNum);
    widget:SetOwned(chestInfo.is_owned);
    widget:SetCanShowTips(true);
end

function PackagePreviewPanel:OnClickRateBtn()
    self:PlayAudio(require("client.slua.config.sound").click);
    local list = {};
    for i,v in ipairs(chestDropInfoList) do
        local data = {};
        data.itemId = v.DropItemID;
        data.rate = tostring(math.ceil(v.DropRate * 10000) / 100).."%";
        data.isLimitTime = v.is_limit_time;
        data.count = v.DropItemNum or 0;
        list[#list + 1] = data;
    end
    Rate_Panel_UI.ShowItemRate(list, 6702);
end

function PackagePreviewPanel:OnClickClose()
    self:PlayAudio(require("client.slua.config.sound").close);
    local uiManager = require("ui.manager");
    if uiManager then
        uiManager.CloseUI(uiManager.UI_Config.package_preview_panel)
    end
end

local class = require("class")
local ui_base = require("ui.base")
local CPackagePreviewPanel = class(ui_base, nil, PackagePreviewPanel)

return CPackagePreviewPanel