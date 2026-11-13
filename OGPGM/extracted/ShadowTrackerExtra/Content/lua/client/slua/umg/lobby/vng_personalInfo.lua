local UI_VNG_PersonalInfo = {}
local KismetSystemLibrary = nil

--[[
变量名，顺位及检查需求
name    -姓名：玩家名字至少填入6个字符
id      -身份证：身份证长度需在9位以上
mail    -邮箱：邮箱需带@符号
phone   -手机号码：手机号码需在10位以上
address -地址：地址需至少填入6个字符
]]

local infoArray = {};--个人信息数组，分别对应上述顺位
local legalArray = {};--是否检查合法
local haveRetry = false;
local timer;

function UI_VNG_PersonalInfo:ctor()
    --todo: 这里可以做些数据初始化工作
    KismetSystemLibrary = import("KismetSystemLibrary");
end

function UI_VNG_PersonalInfo:OnInitialize()
    UI_VNG_PersonalInfo.__super.OnInitialize(self)
    --todo: 在这里做些初始化工作
end

function UI_VNG_PersonalInfo:RegistEvents()
    UI_VNG_PersonalInfo.__super.RegistEvents(self)
    self:AddOnClickedEvent("Button_Confirm", self.OnClickComfirm, self)
    --todo: 在这里注册事件
end

function UI_VNG_PersonalInfo:UnRegistEvents()
    --todo: 在这里反注册事件
    UI_VNG_PersonalInfo.__super.UnRegistEvents(self)
end

function UI_VNG_PersonalInfo:OnPostInitialize()
    UI_VNG_PersonalInfo.__super.OnPostInitialize(self)

    --todo: OnPostInitialize在OnInitialize、RegistEvents之后，有需要在RegistEvents后初始化的工作写这里
    self:InitUI();
end

-- 仅在需要监听状态变化时写这个函数
function UI_VNG_PersonalInfo:OnModeSwitch(preStatus, currentStatus)
    if string.lower(currentStatus) ~= "lobby" then
        local uiManager = require("ui.manager");
        if uiManager then
            uiManager.HideUI(uiManager.UI_Config.vng_personalInfo)
        end
    end
end

function UI_VNG_PersonalInfo:Close()
    --todo: 这里做些消耗回收动作，注意UI_Template.__super.Close(self)一定要写在最后，遵循先进后出原则

    UI_VNG_PersonalInfo.__super.Close(self)
end

function UI_VNG_PersonalInfo:AndriodBack()
    EventAndroidQuitGame()
end

function UI_VNG_PersonalInfo:InitUI()
    log_error(" UI_VNG_PersonalInfo:InitUI");
    for i = 0,4 do
        local titleMsg = Client.GetTableData("LocalizeRes", 6863 + i).TextValue;
        local errorMsg = Client.GetTableData("LocalizeRes", 6868 + i).TextValue;
        local titleWidget = self:GetControlByName("info_item_" .. i .. "." .. "Text_title");
        local errorWidget = self:GetControlByName("info_item_" .. i .. "." .. "Text_error");
        titleWidget:SetText(titleMsg);
        errorWidget:SetText(errorMsg)
        self:SetIsError(i,false);
    end
end

function UI_VNG_PersonalInfo:OnClickComfirm()
    infoArray = {};
    local allCorrect = true;
    for i = 0,4 do
        local textWidget = self:GetControlByName("info_item_" .. i .. "." .. "EditableText");
        if textWidget ~= nil then
            local text = textWidget:GetText();
            --防止超长，电话截取11位，其他函数截254位
            if i == 3 then
                text = string.sub(text,1,11)
            else
                text = string.sub(text,1,254);
            end
            infoArray[i] = text;
            local isLegal = self:CheckInfo(i,text);
            legalArray[i] = isLegal;
            self:SetIsError(i,not isLegal)
            if isLegal == false then
                allCorrect = false
            end
        end
    end

    --如果正确填写信息，则发请求给服务器
    if allCorrect then
        local funcHide = function()
            log("UI_VNG_PersonalInfo:OnClickComfirm funcHide haveRetry : ".. tostring(haveRetry));
            if haveRetry == false then
                haveRetry = true;
                ConnectionWaitingUI:Hide();
                ShowNotice(301235);
            else
                local uiManager = require("ui.manager");
                if uiManager then
                    uiManager.HideUI(uiManager.UI_Config.vng_personalInfo)
                end
            end
        end

        timer = Timer.InsertTimer(5, funcHide, false, false)
        
        ConnectionWaitingUI:Show();
        slua_GameFrontendHUD:VNGPostPersonalInfo(DataMgr.roleData.openID,infoArray[0],infoArray[1],infoArray[2],infoArray[3],infoArray[4]);
    end
end

function UI_VNG_PersonalInfo:OnPostInfoFailed()
    log("UI_VNG_PersonalInfo:OnPostInfoFailed haveRetry : ".. tostring(haveRetry));
    if timer ~= nil then
        Timer.RemoveTimer(timer)
    end
    ConnectionWaitingUI:Hide();
    if haveRetry == false then
        haveRetry = true;
        ConnectionWaitingUI:Hide();
        ShowNotice(301235);
    else
        local uiManager = require("ui.manager");
        if uiManager then
            uiManager.HideUI(uiManager.UI_Config.vng_personalInfo)
        end
    end
end

function UI_VNG_PersonalInfo:OnPostInfoSuccessed()
    log("UI_VNG_PersonalInfo:OnPostInfoSuccessed haveRetry : ".. tostring(haveRetry));
    if timer ~= nil then
        Timer.RemoveTimer(timer)
    end
    ConnectionWaitingUI:Hide();
    NetUtil.SendPkg("set_vietnam_user_info_extrying_req");
    local uiManager = require("ui.manager");
    if uiManager then
        uiManager.HideUI(uiManager.UI_Config.vng_personalInfo)
    end
end

function UI_VNG_PersonalInfo:CheckInfo(index,text)
    if text == nil then
        return false;
    end
    if index == 0  or index == 4 then
        if #text >= 6 then
            return true;
        else
            return false;
        end
    elseif index == 1 then
        if #text >= 9 then
            return true;
        else
            return false;
        end
    elseif index == 2 then
        if string.find(text,"@") ~= nil then
            return true;
        else
            return false;
        end
    elseif index == 3 then
        if #text >= 10 then
            return true;
        else
            return false;
        end
    end
    return false;
end

function UI_VNG_PersonalInfo:SetIsError(index,isError)
    local bgWidget = self:GetControlByName("info_item_" .. index .. "." .. "Image_bg")
    if bgWidget == nil then
        log_error("UI_VNG_PersonalInfo:SetIsError bgWidget is nil");
        return
    end
    if isError then
        bgWidget:SetColorAndOpacity(FSlateColor(FLinearColor(1, 0, 0, 1)));
    else
        bgWidget:SetColorAndOpacity(FSlateColor(FLinearColor(1, 1, 1, 1)));
    end
    
    local errorImage = self:GetControlByName("info_item_" .. index .. "." .. "Image_error")
    if errorImage == nil then
        log_error("UI_VNG_PersonalInfo:SetIsError errorImage is nil");
        return
    end
    if isError then
        errorImage:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible);
    else
        errorImage:SetVisibility(UEnums.ESlateVisibility.Collapsed);
    end

    local errorText = self:GetControlByName("info_item_" .. index .. "." .. "Text_error")
    if errorText == nil then
        log_error("UI_VNG_PersonalInfo:SetIsError errorText is nil");
        return
    end
    if isError then
        errorText:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible);
    else
        errorText:SetVisibility(UEnums.ESlateVisibility.Collapsed);
    end
end
 
local class = require("class")
local ui_base = require("ui.base")
local CUI_VNG_PersonalInfo = class(ui_base, nil, UI_VNG_PersonalInfo)

return CUI_VNG_PersonalInfo