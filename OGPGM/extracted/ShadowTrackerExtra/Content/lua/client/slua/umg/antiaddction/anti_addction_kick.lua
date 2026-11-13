local AntiaddctionKickPanel ={}

function AntiaddctionKickPanel:ctor(selfType, contentMsg, popupType)
    --todo: 这里可以做些数据初始化工作
    self.contentMsg = contentMsg;
    self.popupType = popupType;
end

function AntiaddctionKickPanel:OnInitialize()
    AntiaddctionKickPanel.__super.OnInitialize(self)
    self:SetContent();
    --todo: 在这里做些初始化工作
end

function AntiaddctionKickPanel:RegistEvents()
    AntiaddctionKickPanel.__super.RegistEvents(self)
    self:AddOnClickedEvent("Button_OK", self.OnCloseBtnClick, self);
    self.OnAndroidBack = function()
        self:OnCloseBtnClick();
    end
    EventSystem:registEvent(EVENTTYPE_LOBBY, EVENTID_ANDROID_BACK, self.OnAndroidBack)
    --todo: 在这里注册事件
end

function AntiaddctionKickPanel:UnRegistEvents()
    --todo: 在这里反注册事件

    AntiaddctionKickPanel.__super.UnRegistEvents(self)
end

function AntiaddctionKickPanel:OnPostInitialize()
    AntiaddctionKickPanel.__super.OnPostInitialize(self)

    --todo: OnPostInitialize在OnInitialize、RegistEvents之后，有需要在RegistEvents后初始化的工作写这里
end

-- 仅在需要监听状态变化时写这个函数
--[[function UI_Template:OnModeSwitch(preStatus, currentStatus)
    
end
]]

function AntiaddctionKickPanel:Close()
    --todo: 这里做些消耗回收动作，注意UI_Template.__super.Close(self)一定要写在最后，遵循先进后出原则

    AntiaddctionKickPanel.__super.Close(self)
end

function AntiaddctionKickPanel:SetContent()
    self.UIRoot.UTRichTextBlock_TipsContent:SetText(self.contentMsg);
    self.UIRoot.TextBlock_WindowsTitle:SetText(FuncUtil.GetLocalizeResStr(6770));

    self.UIRoot.Button_OK:SetVisibility(UEnums.ESlateVisibility.Visible);
    self.UIRoot.Button_OK:SetIsEnabled(false);
    local str =  FuncUtil.LocalizeResFormat(4118, "3")
    self.UIRoot.TextBlock_txt:SetText(str);

    Timer.InsertTimer(1, function()
        local str =  FuncUtil.LocalizeResFormat(4118, "2")
        self.UIRoot.TextBlock_txt:SetText(str);
    end, false, false);

    Timer.InsertTimer(2, function()
        local str =  FuncUtil.LocalizeResFormat(4118, "1")
        self.UIRoot.TextBlock_txt:SetText(str);
    end, false, false);

    Timer.InsertTimer(3, function()
        local str =  FuncUtil.GetLocalizeResStr(110036);
        self.UIRoot.TextBlock_txt:SetText(str);
        self.UIRoot.Button_OK:SetIsEnabled(true);
    end, false, false);
end

function AntiaddctionKickPanel:OnCloseBtnClick()
    self:PlayAudio(require("client.slua.config.sound").click);
    if self.popupType == 1 then
        AntiaddctionSystem.CloseKickPanel();
    else
        AntiaddctionSystem.CloseKickPanel();
        LobbyChatLogic.bAddCropsOfflineChatMsg = false;
        LoginSystem.sendLogout();
    end
end

local class = require("class")
local ui_base = require("ui.base")
local CUIAntiaddctionKickPanel = class(ui_base, nil, AntiaddctionKickPanel)

return CUIAntiaddctionKickPanel