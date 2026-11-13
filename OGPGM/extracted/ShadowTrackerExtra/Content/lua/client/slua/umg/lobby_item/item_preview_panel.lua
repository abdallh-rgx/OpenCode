local ItemPreviewPanel ={}

local ItemPreviewSystem = require("client.slua.logic.item_preview.logic_itemPreview");

function ItemPreviewPanel:ctor(selfType, itemID)
    --todo: 这里可以做些数据初始化工作
    self.itemCfg = Client.GetTableData("Item", itemID);
    log_tree("'itemCfg", self.itemCfg);
end

function ItemPreviewPanel:OnInitialize()
    ItemPreviewPanel.__super.OnInitialize(self)
    self:SetContent();
    self:SetSwitchButton();
    self:SetPicture();
    --todo: 在这里做些初始化工作
end

function ItemPreviewPanel:RegistEvents()
    ItemPreviewPanel.__super.RegistEvents(self)
    self:AddOnClickedEvent("btn_close", self.OnBtnCloseClick, self);

    self:AddOnClickedEvent("Button_3", self.OnBtnSwitchClick, self);
    --todo: 在这里注册事件
    
end

function ItemPreviewPanel:UnRegistEvents()
    --todo: 在这里反注册事件

    ItemPreviewPanel.__super.UnRegistEvents(self)
end

function ItemPreviewPanel:OnPostInitialize()
    ItemPreviewPanel.__super.OnPostInitialize(self)

    --todo: OnPostInitialize在OnInitialize、RegistEvents之后，有需要在RegistEvents后初始化的工作写这里
end

-- 仅在需要监听状态变化时写这个函数
--[[function UI_Template:OnModeSwitch(preStatus, currentStatus)
    
end
]]

--界面显示时触发
function ItemPreviewPanel:OnShow()
end

--界面隐藏时触发
function ItemPreviewPanel:OnHide()
end

function ItemPreviewPanel:Close()
    --todo: 这里做些消耗回收动作，注意UI_Template.__super.Close(self)一定要写在最后，遵循先进后出原则
    local widget = UIUtil.GetWidgetByName("bp_createrole", "Lobby_AvatarAnim_UIBP")
    widget:UIShowFromItemPreview(false, 0);
    ModelDisplayer.Destroy();
    ItemPreviewPanel.__super.Close(self)
    local itemPreviewSystem = require("client.slua.logic.item_preview.logic_itemPreview");
    itemPreviewSystem.isShow = false;

end

function ItemPreviewPanel:OnBtnCloseClick()
    self:PlayAudio(require("client.slua.config.sound").close);
    local ui_manager = require("ui.manager");
    if ui_manager then
        ui_manager.CloseUI(ui_manager.UI_Config.itempreview_panel)
    end
end

function ItemPreviewPanel:OnBtnSwitchClick()
    ---@type WidgetSwitcher
    self:PlayAudio(require("client.slua.config.sound").click);

    local switcher = self.UIRoot.WidgetSwitcher_5
    local index = switcher:GetActiveWidgetIndex();
    if index == 0 then
        switcher:SetActiveWidgetIndex(1);
        ItemPreviewSystem.ChangeToAvatar();
    else
        switcher:SetActiveWidgetIndex(0)
        ItemPreviewSystem.ChangeToWeapon(self.itemCfg.itemID);
    end
end

function ItemPreviewPanel:SetSwitchButton()
    if self.itemCfg.ItemType == 1 then
        self.UIRoot.WidgetSwitcher_5:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible);
    else
        self.UIRoot.WidgetSwitcher_5:SetVisibility(UEnums.ESlateVisibility.Collapsed);
    end
end

function ItemPreviewPanel:SetContent()
    local itemCfg = self.itemCfg;
    self.UIRoot.Text_Type:SetText(self.itemCfg.PreviewDisplay);
    self.UIRoot.StoreItem_DetailInfo_Logic_BP:SetDetailInfo(itemCfg.ItemName, itemCfg.ItemQuality, itemCfg.ItemDesc, 0, itemCfg.StoreDetailImage, 0, 0, 0, 0, 0);
end

function ItemPreviewPanel:SetPicture()
    ---@type Image
    local icon = self.UIRoot.Texture_Icon
    if self.itemCfg.ItemType == 4 and self.itemCfg.ItemSubType == 701 then
        icon:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible);
        local util = require("ui.util");
        util.SetTexture(icon, self.itemCfg.ItemBigIcon);
    else
        icon:SetVisibility(UEnums.ESlateVisibility.Collapsed);
    end
end

local class = require("class")
local ui_base = require("ui.base")
local CUIItemPreview = class(ui_base, nil, ItemPreviewPanel)

return CUIItemPreview