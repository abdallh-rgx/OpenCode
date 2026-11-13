-- 订阅主界面

local UI_Subscribe_GetAward ={}

function UI_Subscribe_GetAward:ctor(selfType, subFuncID)
    --这里可以做些数据初始化工作

end

function UI_Subscribe_GetAward:OnInitialize()
    UI_Subscribe_GetAward
            .__super.OnInitialize(self)
    --在这里做些初始化工作
end

function UI_Subscribe_GetAward:RegistEvents()
    UI_Subscribe_GetAward
            .__super.RegistEvents(self)
    -- 在这里注册事件
    self:AddOnClickedEvent("Button_Get", self.OnClicked, self)
end

function UI_Subscribe_GetAward:UnRegistEvents()

    -- 在这里反注册事件
    UI_Subscribe_GetAward.__super.UnRegistEvents(self)
end

function UI_Subscribe_GetAward:OnPostInitialize()
    --OnPostInitialize在OnInitialize、RegistEvents之后，有需要在RegistEvents后初始化的工作写这里
    UI_Subscribe_GetAward.__super.OnPostInitialize(self)

end
function UI_Subscribe_GetAward:Close()
    --todo这里做些消耗回收动作，注意UI_Subscribe.__super.Close(self)一定要写在最后，遵循先进后出原则
    UI_Subscribe_GetAward.__super.Close(self)
end
-- 仅在需要监听状态变化时写这个函数
--[[function UI_Subscribe_GetAward
:OnModeSwitch(preStatus, currentStatus)
end
]]
function UI_Subscribe_GetAward:OnClicked()
    log("onclicked get award")
    NetUtil.SendPkg("take_first_award",SubscribeSystem.SubId.Super)
end

local class = require("class")
local ui_base = require("ui.base")
local CUISubscribe = class(ui_base, nil, UI_Subscribe_GetAward
)
return CUISubscribe