--自带定时器和滑动的消息框
local UI_Common_MessageBox_Timer = {
    onClickOkCallback = nil;
    onClickCancelCallback = nil;
}

local KismetSystemLibrary = nil
local time_ticker = require("client.time_ticker")
local timer = nil;


function UI_Common_MessageBox_Timer:ctor()
    --todo: 这里可以做些数据初始化工作
    KismetSystemLibrary = import("KismetSystemLibrary");
end

function UI_Common_MessageBox_Timer:OnInitialize()
    UI_Common_MessageBox_Timer.__super.OnInitialize(self)
    --todo: 在这里做些初始化工作
end

function UI_Common_MessageBox_Timer:RegistEvents()
    UI_Common_MessageBox_Timer.__super.RegistEvents(self)
    
    self:AddOnClickedEvent("Button_OK",self.OnClickOK,self);
    self:AddOnClickedEvent("Button_Cancel",self.OnClickCancel,self);
end

function UI_Common_MessageBox_Timer:UnRegistEvents()
    --todo: 在这里反注册事件
    UI_Common_MessageBox_Timer.__super.UnRegistEvents(self)
end

function UI_Common_MessageBox_Timer:OnPostInitialize()
    UI_Common_MessageBox_Timer.__super.OnPostInitialize(self)
    
    --todo: OnPostInitialize在OnInitialize、RegistEvents之后，有需要在RegistEvents后初始化的工作写这里
end

function UI_Common_MessageBox_Timer:Close()
    --todo: 这里做些消耗回收动作，注意UI_Template.__super.Close(self)一定要写在最后，遵循先进后出原则
    
    -- 销毁定时器
    if timer ~= nil then
        time_ticker.RemoveTimer(timer)
    end
    UI_Common_MessageBox_Timer.__super.Close(self)
end

function UI_Common_MessageBox_Timer:InitUI()
    
end

function UI_Common_MessageBox_Timer:AndriodBack()
    EventAndroidQuitGame()
end

--参数分别为：标题，内容，点击ok回调，点击cancel回调，ok按钮文字，cancel按钮文字，定时器回调
function UI_Common_MessageBox_Timer:SetShowInfo(title, msg, clickOkCallback, clickCancelCallback, btnOK, btnCancel,timerCallback)
    log("UI_Common_MessageBox_Timer:SetShowInfo");
    self.UIRoot.TextBlock_Title:SetText(title);
    self.UIRoot.TextBlock_Content:SetText(msg);
    self.UIRoot.TextBlock_Cancel:SetText(btnCancel);
    self.UIRoot.TextBlock_OK:SetText(btnOK);
    self.UIRoot.TextBlock_Title:SetText(title);
    
    self.onClickOkCallback = clickOkCallback;
    self.onClickCancelCallback = clickCancelCallback;
    
    if timerCallback ~= nil then
        log("timerCallback begin!");
        -- 延迟1秒执行
        timer = time_ticker.AddTimer(1, function ()
            for i = 1, 10000 do
                timerCallback();
                coroutine.yield(1) --停顿一秒
            end
        end)
    end
end

function UI_Common_MessageBox_Timer:OnClickOK()
    if self.onClickOkCallback ~= nil then
        self.onClickOkCallback();
    end
end

function UI_Common_MessageBox_Timer:OnClickCancel()
    if self.onClickCancelCallback ~= nil then
        self.onClickCancelCallback();
    end
end

function UI_Common_MessageBox_Timer:UpdateContentText(content)
    self.UIRoot.TextBlock_Content:SetText(content);
end

function UI_Common_MessageBox_Timer:UpdateCancelText(cancel)
    self.UIRoot.TextBlock_Cancel:SetText(cancel);
end

local class = require("class")
local ui_base = require("ui.base")
local CUI_Common_MessageBox_Timer = class(ui_base, nil, UI_Common_MessageBox_Timer)

return CUI_Common_MessageBox_Timer