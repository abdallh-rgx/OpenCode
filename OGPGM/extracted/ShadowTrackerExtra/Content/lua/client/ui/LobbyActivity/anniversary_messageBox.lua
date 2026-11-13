local UI_Anniversary_MessageBox ={}

function UI_Anniversary_MessageBox:ctor(selfType, callback, title, content)
    --todo: 这里可以做些数据初始化工作
    self.ClickOKCallback = callback;
    self.Title = title;
    self.Content = content;
end

function UI_Anniversary_MessageBox:OnInitialize()
    UI_Anniversary_MessageBox.__super.OnInitialize(self)

    --todo: 在这里做些初始化工作
end

function UI_Anniversary_MessageBox:RegistEvents()
    UI_Anniversary_MessageBox.__super.RegistEvents(self)
    
    self:AddOnClickedEvent("Button_OK", self.OnClickOK, self);

    self:AddOnClickedEvent("Button_Cancel", self.OnClickClose, self);

    self:AddOnClickedEvent("Button_Close", self.OnClickClose, self);
    --todo: 在这里注册事件
end

function UI_Anniversary_MessageBox:UnRegistEvents()
    --todo: 在这里反注册事件

    UI_Anniversary_MessageBox.__super.UnRegistEvents(self)
end

function UI_Anniversary_MessageBox:OnPostInitialize()
    UI_Anniversary_MessageBox.__super.OnPostInitialize(self)

    --todo: OnPostInitialize在OnInitialize、RegistEvents之后，有需要在RegistEvents后初始化的工作写这里
    self:SetTitileAndContent();
end

-- 仅在需要监听状态变化时写这个函数
--[[function UI_Template:OnModeSwitch(preStatus, currentStatus)
    
end
]]

function UI_Anniversary_MessageBox:Close()
    --todo: 这里做些消耗回收动作，注意UI_Template.__super.Close(self)一定要写在最后，遵循先进后出原则
    UI_Anniversary_MessageBox.__super.Close(self)
end

function UI_Anniversary_MessageBox:OnClickOK()
    if self.ClickOKCallback then
        self.ClickOKCallback()
    end
    self.OnClickClose();
end

function UI_Anniversary_MessageBox.OnClickClose()
    AnniversaryActivitySystem.CloseCheckMessageBox();
end

function UI_Anniversary_MessageBox:SetTitileAndContent()
    local KismetTextLibrary = import("KismetTextLibrary");
    self.UIRoot.Text_Content:SetText(KismetTextLibrary.Conv_StringToText(self.Content));
    self.UIRoot.Text_Title:SetText(KismetTextLibrary.Conv_StringToText(self.Title));
end

local class = require("class")
local ui_base = require("ui.base")
local CUIAnniversary_MessageBox = class(ui_base, nil, UI_Anniversary_MessageBox)

return CUIAnniversary_MessageBox