local UI_PopNotice ={}

function UI_PopNotice:ctor()
    --todo: 这里可以做些数据初始化工作
end

function UI_PopNotice:OnInitialize()
    UI_PopNotice.__super.OnInitialize(self)
    self:ShowTips();
    --todo: 在这里做些初始化工作
end

function UI_PopNotice:RegistEvents()
    UI_PopNotice.__super.RegistEvents(self)

    self:AddOnClickedEvent("Button_CloseUI", AnniversaryActivitySystem.ClosePopNotice, self);

    --todo: 在这里注册事件
end

function UI_PopNotice:UnRegistEvents()
    --todo: 在这里反注册事件

    UI_PopNotice.__super.UnRegistEvents(self)
end

function UI_PopNotice:OnPostInitialize()
    UI_PopNotice.__super.OnPostInitialize(self)

    --todo: OnPostInitialize在OnInitialize、RegistEvents之后，有需要在RegistEvents后初始化的工作写这里
end

-- 仅在需要监听状态变化时写这个函数
--[[function UI_Template:OnModeSwitch(preStatus, currentStatus)
    
end
]]

function UI_PopNotice:Close()
    --todo: 这里做些消耗回收动作，注意UI_Template.__super.Close(self)一定要写在最后，遵循先进后出原则

    UI_PopNotice.__super.Close(self)
end

function UI_PopNotice:ShowTips()
    --todo: 正式的本地化表key
    log("ShowTips");
    local KismetTextLibrary = import("KismetTextLibrary");
    local title = Client.GetTableData("LocalizeRes", 4726).TextValue
    local content = Client.GetTableData("LocalizeRes", 6524).TextValue
    local ftitle = KismetTextLibrary.Conv_StringToText(title);
    local fcontent = KismetTextLibrary.Conv_StringToText(content);
    self.UIRoot.TextBlock_WindowsTitle:SetText(ftitle);
    self.UIRoot.UTRichTextBlock_TipsContent:SetText(fcontent);
end

local class = require("class")
local ui_base = require("ui.base")
local CUIPopNotice = class(ui_base, nil, UI_PopNotice)

return CUIPopNotice