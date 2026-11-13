local UI_Starterpack_MessageBox ={}

function UI_Starterpack_MessageBox:ctor(selfType, callback, title, content, buttonConfirm, buttonGoback)
    --todo: 这里可以做些数据初始化工作
    --self.ClickOKCallback = callback;
    self.ClickOKCallback = callback;
    self.Title = title;
    self.Content = content;
    self.btnRefuse = buttonConfirm;
    self.btnGoback = buttonGoback;
end

function UI_Starterpack_MessageBox:OnInitialize()
    UI_Starterpack_MessageBox.__super.OnInitialize(self)

    --todo: 在这里做些初始化工作
end

function UI_Starterpack_MessageBox:RegistEvents()
    UI_Starterpack_MessageBox.__super.RegistEvents(self)
    
    --self:AddOnClickedEvent("Button_OK", self.OnClickOK, self);

    self:AddOnClickedEvent("Button_Refuse", self.OnClickRefuse, self);

    self:AddOnClickedEvent("Button_GoBack", self.OnClickGoBack, self);
    --todo: 在这里注册事件
end

function UI_Starterpack_MessageBox:UnRegistEvents()
    --todo: 在这里反注册事件

    UI_Starterpack_MessageBox.__super.UnRegistEvents(self)
end

function UI_Starterpack_MessageBox:OnPostInitialize()
    UI_Starterpack_MessageBox.__super.OnPostInitialize(self)

    --todo: OnPostInitialize在OnInitialize、RegistEvents之后，有需要在RegistEvents后初始化的工作写这里
    self:SetTitileAndContent();
end

-- 仅在需要监听状态变化时写这个函数
--[[function UI_Template:OnModeSwitch(preStatus, currentStatus)
    
end
]]

function UI_Starterpack_MessageBox:Close()
    --todo: 这里做些消耗回收动作，注意UI_Template.__super.Close(self)一定要写在最后，遵循先进后出原则
    UI_Starterpack_MessageBox.__super.Close(self)
end

function UI_Starterpack_MessageBox:OnClickOK()
    if self.ClickOKCallback then
        self.ClickOKCallback()
    end
    self.OnClickGoBack();
end

function UI_Starterpack_MessageBox:OnClickRefuse()
    if self.ClickOKCallback then
        self.ClickOKCallback()
    end
    self.OnClickGoBack();
    --[[
    local ui_manager = require("ui.manager");
	if ui_manager then
		ui_manager.CloseUI(ui_manager.UI_Config.starterPack_messageBox)
    end
    ]]
end

function UI_Starterpack_MessageBox.OnClickGoBack()
    local ui_manager = require("ui.manager");
	if ui_manager then
		ui_manager.CloseUI(ui_manager.UI_Config.starterPack_messageBox)
	end
    --local finalOfferPopup = require("client.slua.logic.lobby_activity.logic_anniversary_activity")
    --AnniversaryActivitySystem.CloseCheckMessageBox();
end

function UI_Starterpack_MessageBox:SetTitileAndContent()
    --[[
    local KismetTextLibrary = import("KismetTextLibrary");
    self.UIRoot.Text_Content:SetText(KismetTextLibrary.Conv_StringToText(self.Content));
    self.UIRoot.Text_Title:SetText(KismetTextLibrary.Conv_StringToText(self.Title));
    self.UIRoot.Text_Content:SetText(KismetTextLibrary.Conv_StringToText(self.btnConfirm));
    self.UIRoot.Text_Title:SetText(KismetTextLibrary.Conv_StringToText(self.btnGoback));
    ]]
    self.UIRoot.Text_Content:SetText(self.Content);
    self.UIRoot.Text_Title:SetText(self.Title);
    self.UIRoot.Text_cancel:SetText(self.btnRefuse);
    self.UIRoot.Text_ok:SetText(self.btnGoback);
end

local class = require("class")
local ui_base = require("ui.base")
local CUIStarterpack_MessageBox = class(ui_base, nil, UI_Starterpack_MessageBox)

return CUIStarterpack_MessageBox