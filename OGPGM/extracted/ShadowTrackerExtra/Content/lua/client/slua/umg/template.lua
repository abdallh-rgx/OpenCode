local UI_Template ={}

function UI_Template:ctor()
    --todo: 这里可以做些数据初始化工作
end

function UI_Template:OnInitialize()
    UI_Template.__super.OnInitialize(self)

    --todo: 在这里做些初始化工作
end

function UI_Template:RegistEvents()
    UI_Template.__super.RegistEvents(self)

    --todo: 在这里注册事件
end

function UI_Template:UnRegistEvents()
    --todo: 在这里反注册事件
    
    UI_Template.__super.UnRegistEvents(self)
end

function UI_Template:OnPostInitialize()
    UI_Template.__super.OnPostInitialize(self)
    
    --todo: OnPostInitialize在OnInitialize、RegistEvents之后，有需要在RegistEvents后初始化的工作写这里
end

-- 仅在需要监听状态变化时写这个函数
--[[function UI_Template:OnModeSwitch(preStatus, currentStatus)
    
end
]]

--界面显示时触发
function UI_Template:OnShow()

end

--界面隐藏时触发
function UI_Template:OnHide()

end

function UI_Template:Close()
    --todo: 这里做些消耗回收动作，注意UI_Template.__super.Close(self)一定要写在最后，遵循先进后出原则

    UI_Template.__super.Close(self)
end

local class = require("class")
local ui_base = require("ui.base")
local CUITemplate = class(ui_base, nil, UI_Template)

return CUITemplate