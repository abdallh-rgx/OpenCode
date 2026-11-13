local UI_Anniversary_Actvity = {}
local KismetSystemLibrary = nil
local isUCDrawOne;  --是否UC抽
local isUCDrawTen; --是否UC5连抽
local treasureBoxCanGetList = {};   --可领取图片
local treasureBoxHasGetList = {};   --已领取图片
local treasureBoxDrawTimesTextList = {};    --抽取次数
local treasureBoxButton = {};   --宝箱按钮
local drawTenStage = 1;
local debrisCountCache = 0; --界面缓存的周年碎片数量
local isStop = false;   --待机动画是否暂停
local isCanClickButton = true;  --能否点击按钮
local stopAnimation = 
{
    startTime = 0,
    index = 1,
}

local ItemAnimationIndex = 
{
    [0] = 1.65 + 0.05;
    [1] = 0 + 0.05;
    [2] = 0.15 + 0.05;
    [3] = 0.3 + 0.05;
    [4] = 0.45 + 0.05;
    [5] = 0.6 + 0.05;
    [6] = 0.75 + 0.05;
    [7] = 0.9 + 0.05;
    [8] = 1.05 + 0.05;
    [9] = 1.2 + 0.05;
    [10] = 1.35 + 0.05;
    [11] = 1.5 + 0.05;
    [12] = 1.65 + 0.05;
}

local AnniversaryActivitySystem = require("client.slua.logic.lobby_activity.logic_anniversary_activity")

function UI_Anniversary_Actvity:ctor()
    --todo: 这里可以做些数据初始化工作
    KismetSystemLibrary = import("KismetSystemLibrary");
    isUCDrawOne = true;
    isUCDrawTen = true;
    isStop = false;
    isCanClickButton = true;
end

function UI_Anniversary_Actvity:OnInitialize()
    UI_Anniversary_Actvity.__super.OnInitialize(self)
    self:InitTreatureBox();
    --todo: 在这里做些初始化工作
end

function UI_Anniversary_Actvity:RegistEvents()
    UI_Anniversary_Actvity.__super.RegistEvents(self)

    --todo: 在这里注册事件
    self:AddOnClickedEvent("Button_close", AnniversaryActivitySystem.CloseMainUI, self);

    self:AddOnClickedEvent("Button_1time", self.OnClickDrawOne, self);

    self:AddOnClickedEvent("Button_5times", self.OnClickDrawTen, self);

    self:AddOnClickedEvent("Button_1", function()
        if isCanClickButton then
            AnniversaryActivitySystem.OpenExchangeStore();
        end
    end);

    self:AddOnClickedEvent("Button_help", function()
        if  isCanClickButton then
            AnniversaryActivitySystem.OpenPopNotice();
        end
    end);

    self:AddOnClickedEvent("Button_Stop", self.OnClickStopAnimation, self);
    
    self:AddOnClickedEvent("Button_ShowTips", self.OnClickRateButton, self);

    self:AddControlEvent("Check_ShowAniamtion", "OnCheckStateChanged", self.OnCheckStateChanged, self);

    self:AddControlEvent("CheckBox_10", "OnCheckStateChanged", self.OnCheckDrawTenChanged, self);

    for i = 1, 12 do
        self:AddControlEvent("Button_0" .. i, "OnPressed", self.OnPressTips, self, i);
        self:AddControlEvent("Button_0" .. i, "OnReleased", self.OnReleaseTips, self);
    end
    
    for i, v in ipairs(treasureBoxButton) do
        self:AddOnClickedEvent(KismetSystemLibrary.GetObjectName(v), self.OnClickTreasureBox, self, i);
    end
    
    self:AddCommonEvent(EVENTTYPE_ACTIVITY, EVENTID_ANNIVERSARY_COST_CHANGE, function()
        self:SetUCText();
        self:SetTicketText();
        self:SetDrawBoxButton();
    end)

    self:AddCommonEvent(EVENTTYPE_ACTIVITY, EVENTID_ANNIVERSARY_DARW_TEN_ANIMATION, self.PlayDrawTenAniamtionOneTurn, self)

    self:AddCommonEvent(EVENTTYPE_ACTIVITY, EVENTID_ANNIVERSARY_DARW_ONE_ANIMATION, self.PlayDrawOneAnimationStart, self)
    
    self:AddCommonEvent(EVENTTYPE_ACTIVITY, EVENTID_ANNIVERSARY_DRAW_STAGE_AWARD, function()
        self:SetTreatureBox();
        self:SetDebrisCount();
    end)

    self:AddCommonEvent(EVENTTYPE_ACTIVITY, EVENTID_ANNIVERSARY_EXCHANGE, self.SetDebrisCount, self);
end

function UI_Anniversary_Actvity:UnRegistEvents()
    --todo: 在这里反注册事件
    UI_Anniversary_Actvity.__super.UnRegistEvents(self)
end

function UI_Anniversary_Actvity:OnPostInitialize()
    UI_Anniversary_Actvity.__super.OnPostInitialize(self)

    --todo: OnPostInitialize在OnInitialize、RegistEvents之后，有需要在RegistEvents后初始化的工作写这里
    self:InitUI();
end

-- 仅在需要监听状态变化时写这个函数
--[[function UI_Template:OnModeSwitch(preStatus, currentStatus)
    
end
]]

function UI_Anniversary_Actvity:Close()
    --todo: 这里做些消耗回收动作，注意UI_Template.__super.Close(self)一定要写在最后，遵循先进后出原则

    UI_Anniversary_Actvity.__super.Close(self)
end

function UI_Anniversary_Actvity:InitUI()
    log("Init UI");
    self:SetUCText();
    self:SetTicketText();
    self:SetDrawBoxButton();
    self:SetDebrisCount();
    self:SetTime();
    self:SetTreatureBox();
    self:PlayIdleAnimation();
    self:HideItemBox();
    self:SetShowAniamtionCheckBox();
end

function UI_Anniversary_Actvity:SetUCText()
    log("SetUCText")
    self.UIRoot.Text_UCNum:SetText(tostring(DataMgr.ticket));
    self.UIRoot.Text_UCNumBlue:SetText(tostring(DataMgr.ticket));
    if DataMgr.ticket == 0 then
        self.UIRoot.WidgetSwitcher_UC:SetActiveWidgetIndex(0);
    else
        self.UIRoot.WidgetSwitcher_UC:SetActiveWidgetIndex(1);
    end
end

function UI_Anniversary_Actvity:SetTicketText()
    log("SetTicketText")
    local ticketNum = tostring(AnniversaryActivitySystem.GetTicketCount());
    self.UIRoot.Text_TicketNum:SetText(ticketNum);
    self.UIRoot.Text_TicketNumBlue:SetText(ticketNum);
    if AnniversaryActivitySystem.GetTicketCount() == 0 then
        self.UIRoot.WidgetSwitcher_Ticket:SetActiveWidgetIndex(0);
    else
        self.UIRoot.WidgetSwitcher_Ticket:SetActiveWidgetIndex(1);
    end
end

function UI_Anniversary_Actvity:SetDrawBoxButton()
    log("SetDrawBoxButton");
    local ticketCount = AnniversaryActivitySystem.GetTicketCount();
    log("ticketCount: " .. ticketCount);
    if ticketCount < AnniversaryActivitySystem.SnatchTicket[1] then
        local drawOneCount = tostring(AnniversaryActivitySystem.SnatchUC[1]);
        self.UIRoot.Text_DrawOneCost:SetText(drawOneCount);
        self.UIRoot.Text_DrawOneCost_Invalid:SetText(drawOneCount);
        
        local drawFiveCount = tostring(AnniversaryActivitySystem.SnatchUC[2]);
        self.UIRoot.Text_DrawFiveCost:SetText(drawFiveCount);
        self.UIRoot.Text_DrawFiveCost_Invalid:SetText(drawFiveCount);
        
        isUCDrawOne = true;
        isUCDrawTen = true

        self.UIRoot.WidgetSwitcher_DrawOne:SetActiveWidgetIndex(0);
        self.UIRoot.WidgetSwitcher_DrawTen:SetActiveWidgetIndex(0);

        if AnniversaryActivitySystem.SnatchUC[1] > DataMgr.ticket then
            self.UIRoot.WidgetSwitcher_DrawOne_UCEnough:SetActiveWidgetIndex(1);
        else
            self.UIRoot.WidgetSwitcher_DrawOne_UCEnough:SetActiveWidgetIndex(0);
        end

        if AnniversaryActivitySystem.SnatchUC[2] > DataMgr.ticket then
            self.UIRoot.WidgetSwitcher_DrawTen_UCEnough:SetActiveWidgetIndex(1);
        else
            self.UIRoot.WidgetSwitcher_DrawTen_UCEnough:SetActiveWidgetIndex(0);
        end
        
    elseif ticketCount >= AnniversaryActivitySystem.SnatchTicket[1] and ticketCount < AnniversaryActivitySystem.SnatchTicket[2] then
        local drawOneCount = tostring(AnniversaryActivitySystem.SnatchTicket[1]);
        self.UIRoot.Text_DrawOne_TicketCost:SetText(drawOneCount);
        
        local drawFiveCount = tostring(AnniversaryActivitySystem.SnatchUC[2]);
        self.UIRoot.Text_DrawFiveCost:SetText(drawFiveCount);
        self.UIRoot.Text_DrawFiveCost_Invalid:SetText(drawFiveCount);
        
        isUCDrawOne = false;
        isUCDrawTen = true;

        self.UIRoot.WidgetSwitcher_DrawOne:SetActiveWidgetIndex(1);
        self.UIRoot.WidgetSwitcher_DrawTen:SetActiveWidgetIndex(0);
        
        if AnniversaryActivitySystem.SnatchUC[2] > DataMgr.ticket then
            self.UIRoot.WidgetSwitcher_DrawTen_UCEnough:SetActiveWidgetIndex(1);
        else
            self.UIRoot.WidgetSwitcher_DrawTen_UCEnough:SetActiveWidgetIndex(0);
        end
        
        
    elseif ticketCount >= AnniversaryActivitySystem.SnatchTicket[2] then
        self.UIRoot.Text_DrawOne_TicketCost:SetText(tostring(AnniversaryActivitySystem.SnatchTicket[1]));
        self.UIRoot.Text_DrawTen_TicketCost:SetText(tostring(AnniversaryActivitySystem.SnatchTicket[2]));
        
        isUCDrawOne = false;
        isUCDrawTen = false;

        self.UIRoot.WidgetSwitcher_DrawOne:SetActiveWidgetIndex(1);
        self.UIRoot.WidgetSwitcher_DrawTen:SetActiveWidgetIndex(1);
    end
end

function UI_Anniversary_Actvity:SetTime()
    log("SetTime");
    local startTime, stopTime = AnniversaryActivitySystem.GetActivityTime();
    local beginTime = os.date("!%Y/%m/%d", startTime)
    local endTime = os.date("!%Y/%m/%d", stopTime)
    
    log("beginTime: " .. beginTime);
    log("endTime: " .. endTime);
    local timeStr = beginTime .. "-" .. endTime;
    log("timeStr: " .. timeStr);
    self.UIRoot.Text_Time:SetText(timeStr);
end

function UI_Anniversary_Actvity:SetDebrisCount()
    local count = AnniversaryActivitySystem.GetDebrisItemCount();
    debrisCountCache = count;
    log("SetDebrisCount" .. count);
    self.UIRoot.Text_Debris:SetText(count);
    self.UIRoot.Text_DebrisAni:SetText(count);
end

function UI_Anniversary_Actvity:InitTreatureBox()
    treasureBoxCanGetList = {};
    treasureBoxHasGetList = {};
    treasureBoxDrawTimesTextList = {};
    treasureBoxButton = {};
    
    table.insert(treasureBoxCanGetList, self.UIRoot.Image_bright001);
    table.insert(treasureBoxCanGetList, self.UIRoot.Image_bright002);
    table.insert(treasureBoxCanGetList, self.UIRoot.Image_bright003);
    table.insert(treasureBoxCanGetList, self.UIRoot.Image_bright004);
    table.insert(treasureBoxCanGetList, self.UIRoot.Image_bright005);

    table.insert(treasureBoxHasGetList, self.UIRoot.Image_get001);
    table.insert(treasureBoxHasGetList, self.UIRoot.Image_get002);
    table.insert(treasureBoxHasGetList, self.UIRoot.Image_get003);
    table.insert(treasureBoxHasGetList, self.UIRoot.Image_get004);
    table.insert(treasureBoxHasGetList, self.UIRoot.Image_get005);

    table.insert(treasureBoxDrawTimesTextList, self.UIRoot.Text_DrawTimes001);
    table.insert(treasureBoxDrawTimesTextList, self.UIRoot.Text_DrawTimes002);
    table.insert(treasureBoxDrawTimesTextList, self.UIRoot.Text_DrawTimes003);
    table.insert(treasureBoxDrawTimesTextList, self.UIRoot.Text_DrawTimes004);
    table.insert(treasureBoxDrawTimesTextList, self.UIRoot.Text_DrawTimes005);

    table.insert(treasureBoxButton, self.UIRoot.Button_001);
    table.insert(treasureBoxButton, self.UIRoot.Button_002);
    table.insert(treasureBoxButton, self.UIRoot.Button_003);
    table.insert(treasureBoxButton, self.UIRoot.Button_004);
    table.insert(treasureBoxButton, self.UIRoot.Button_005);
end

function UI_Anniversary_Actvity:SetTreatureBox()
    log("SetTreatureBox")
    local boxCondition = AnniversaryActivitySystem.StageAwardStageCondition;
    for i, v in ipairs(boxCondition) do
        if v == 0 or v == "0" then
            treasureBoxCanGetList[i]:SetVisibility(UEnums.ESlateVisibility.Collapsed);
            treasureBoxHasGetList[i]:SetVisibility(UEnums.ESlateVisibility.Collapsed);
        elseif v == 1 or v == "1" then
            treasureBoxCanGetList[i]:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible);
            treasureBoxHasGetList[i]:SetVisibility(UEnums.ESlateVisibility.Collapsed);
        elseif v == 2 or v == "2" then
            treasureBoxCanGetList[i]:SetVisibility(UEnums.ESlateVisibility.Collapsed);
            treasureBoxHasGetList[i]:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible);
        end
    end
    
    local boxConfig = AnniversaryActivitySystem.StageAwardConfig;
    for i, v in ipairs(boxConfig) do
        treasureBoxDrawTimesTextList[i]:SetText(v.cond);
    end
    
    self.UIRoot.Text_TotalDraw:SetText(AnniversaryActivitySystem.TotalSnatchTimes);
end

function UI_Anniversary_Actvity:OnClickTreasureBox(id)
    if not isCanClickButton then
        return;
    end
    log_tree("AnniversaryActivitySystem.StageAwardConfig", AnniversaryActivitySystem.StageAwardConfig[id]);
    AnniversaryActivitySystem.OpenRewardBox(id);
end

function UI_Anniversary_Actvity:OnClickDrawOne()
    log("OnClickDrawOne");
    if not isCanClickButton then
        return;
    end
    if isUCDrawOne then
        local title = FuncUtil.GetLocalizeResStr("301185");
        local content = GlobalData.GetLocalizeStringWithNum(6149, 1, tostring(AnniversaryActivitySystem.SnatchUC[1]), "1")
        --CommonMessageBoxUI:ShowPanel(2, strBuy, tip,  UI_Anniversary_Actvity.DrawOne);
        AnniversaryActivitySystem.OpenCheckMessageBox(UI_Anniversary_Actvity.DrawOne, title, content);
    else
        AnniversaryActivitySystem.anniversary_activity_have_draw_req(3)
    end
end

function UI_Anniversary_Actvity:OnClickDrawTen()
    log("OnClickDrawTen");
    if not isCanClickButton then
        return;
    end
    --self:PlayDrawOneAnimationStart();
    drawTenStage = 1;
    if isUCDrawTen then
        local title = FuncUtil.GetLocalizeResStr("301185");
        local content = GlobalData.GetLocalizeStringWithNum(6149, 1, tostring(AnniversaryActivitySystem.SnatchUC[2]), "10")
        AnniversaryActivitySystem.OpenCheckMessageBox(UI_Anniversary_Actvity.DrawTen, title, content);
    else
        AnniversaryActivitySystem.anniversary_activity_have_draw_req(4)
    end
end

function UI_Anniversary_Actvity:OnClickStopAnimation()
    log("OnClickStopAnimation")
    if not isCanClickButton then
        return;
    end
    stopAnimation.startTime, stopAnimation.index = self:GetAnimationStartTimeAndIndex();
    if isStop then
        self:PlayIdleAnimation();
    else
        log("true")
        self:PauseIdleAniamtion();
    end
end

function UI_Anniversary_Actvity.DrawOne()
    if isUCDrawOne then
        AnniversaryActivitySystem.anniversary_activity_have_draw_req(1)
    else
        AnniversaryActivitySystem.anniversary_activity_have_draw_req(3)
    end
end

function UI_Anniversary_Actvity.DrawTen()
    if isUCDrawTen then
        AnniversaryActivitySystem.anniversary_activity_have_draw_req(2)
    else
        AnniversaryActivitySystem.anniversary_activity_have_draw_req(4)
    end
end

function UI_Anniversary_Actvity:ShowItem()
    local CommonItemFunctionLibrary = slua.loadClass("/Game/UMG/UI_Logic/Common/CommonItemFunctionLibrary.CommonItemFunctionLibrary");
    local item = AnniversaryActivitySystem.DropItemConfig[AnniversaryActivitySystem.DropList[drawTenStage]];
    local ui = self.UIRoot["Common_Item_Style2_UIBP_" .. drawTenStage];
    ui:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible);
    ui:InitItem();
    CommonItemFunctionLibrary.SetItemIconAndQuality(item.itemId, 0, ui.Common_Item_ALL_UIBP.Image_Icon_Quality_Bottom, 
            ui.Common_Item_ALL_UIBP.Image_Quality_Bg, ui.Common_Item_ALL_UIBP.Image_Icon, ui.Common_Item_ALL_UIBP.SpecialIcon, self.UIRoot);

    CommonItemFunctionLibrary.SetCountText(item.itemCount, ui.Common_Item_ALL_UIBP.Count, self.UIRoot);
    
    if item.itemId == AnniversaryActivitySystem.DebrisID then
        self:PlayDebrisAnimation(item.itemCount);
    end
end

function UI_Anniversary_Actvity:OnPressTips(id)
    local config = AnniversaryActivitySystem.DropItemConfig[id];
    log_tree("config =======", config);
    if config then
        local GlobalUIFunctionLibrary = slua.loadClass("/Game/UMG/UI_Utility/GlobalUIFunctionLibrary.GlobalUIFunctionLibrary");
        local button = self.UIRoot["Button_0" .. id];
        GlobalUIFunctionLibrary.ShowItemTipsByButton(tonumber(config.itemId), button, 0, 0, true, self.UIRoot);
    end
end

function UI_Anniversary_Actvity:OnReleaseTips()
    log("OnButtonTipsRelease");
    local GlobalUIFunctionLibrary = slua.loadClass("/Game/UMG/UI_Utility/GlobalUIFunctionLibrary.GlobalUIFunctionLibrary");
    GlobalUIFunctionLibrary.CloseItemTips(self.UIRoot);
end

function UI_Anniversary_Actvity:HideItemBox()
    for i = 1, 10 do
        local item = self.UIRoot["Common_Item_Style2_UIBP_" .. i];
        item:SetVisibility(UEnums.ESlateVisibility.Collapsed);
    end
    self.UIRoot.itemBox:SetVisibility(UEnums.ESlateVisibility.Collapsed);
end

function UI_Anniversary_Actvity:ShowAllItem()
    local CommonItemFunctionLibrary = slua.loadClass("/Game/UMG/UI_Logic/Common/CommonItemFunctionLibrary.CommonItemFunctionLibrary");
    for i = 1, 10 do
        local item = AnniversaryActivitySystem.DropItemConfig[AnniversaryActivitySystem.DropList[i]];
        local ui = self.UIRoot["Common_Item_Style2_UIBP_" .. i];
        ui:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible);
        ui:InitItem();
        CommonItemFunctionLibrary.SetItemIconAndQuality(item.itemId, 0, ui.Common_Item_ALL_UIBP.Image_Icon_Quality_Bottom,
                ui.Common_Item_ALL_UIBP.Image_Quality_Bg, ui.Common_Item_ALL_UIBP.Image_Icon, ui.Common_Item_ALL_UIBP.SpecialIcon, self.UIRoot);

        CommonItemFunctionLibrary.SetCountText(item.itemCount, ui.Common_Item_ALL_UIBP.Count, self.UIRoot);
    end
end

function UI_Anniversary_Actvity:ShowItemBox()
    self.UIRoot.itemBox:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible);
    self.UIRoot.Check_ShowAniamtion:SetVisibility(UEnums.ESlateVisibility.Hidden);
    self.UIRoot.CheckBox_10:SetCheckedState(0);
    self:PlayItemsFlyInAniamtion();
end

function UI_Anniversary_Actvity:SetShowAniamtionCheckBox()
    self.UIRoot.Check_ShowAniamtion:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible);
    if AnniversaryActivitySystem.IsShowAniamtion then
        self.UIRoot.Check_ShowAniamtion:SetCheckedState(0);
    else
        self.UIRoot.Check_ShowAniamtion:SetCheckedState(1);
    end
end

function UI_Anniversary_Actvity:OnCheckStateChanged(isChecked)
    if self.UIRoot.Check_ShowAniamtion:GetCheckedState() == 1 then
        AnniversaryActivitySystem.IsShowAniamtion = false
        print("AnniversaryActivitySystem.IsShowAniamtion", AnniversaryActivitySystem.IsShowAniamtion);
    else
        AnniversaryActivitySystem.IsShowAniamtion = true;
        print("AnniversaryActivitySystem.IsShowAniamtion", AnniversaryActivitySystem.IsShowAniamtion);
    end
end

function UI_Anniversary_Actvity:OnCheckDrawTenChanged(isChecked)
    if self.UIRoot.CheckBox_10:GetCheckedState() == 1 then
        AnniversaryActivitySystem.IsShowAniamtion = false;
        self:StopAniamtion();
        AnniversaryActivitySystem.ShowItemGetPanel();
        self:PlayIdleAnimation();
        self:HideItemBox();
        self:SetDebrisCount();
        self:SetShowAniamtionCheckBox();
        self:SetTreatureBox();
        isCanClickButton = true;
        return;
    end
end

function UI_Anniversary_Actvity:OnClickRateButton()
    if not isCanClickButton then
        return;
    end
    local strRegion = Client.GetPublishRegion();
    if strRegion == "KOREA" or strRegion == "JAPAN" then
        local language = Client.GetCurrentLanguage();
        if language == "Ja" then
            Client.OpenURL("https://pubgmobile.jp/wanderer.html", true)
        elseif language == "Ko" then
            Client.OpenURL("https://cafe.naver.com/battlegroundsmobile/3", true)
        else
            Client.OpenURL("https://pubgmobile.jp/wanderer_EN.html", true)
        end
    else
        --todo:替换成正式的概率
        local RateStr = "0,0,0,0,97.20%,2.50%,,0.30%"
        local rate = Rate_Panel_UI.StrSplit(RateStr, ",")
        Rate_Panel_UI.Show(rate, 6153);
    end
end

-----------------------------------------------抽奖动画--------------------------------------------------------------

function UI_Anniversary_Actvity:PlayIdleAnimation()
    log("PlayIdleAnimation");
    isStop = false;
    local startTime = self:GetAnimationStartTimeAndIndex();
    self.UIRoot:PlayAnimationTo(self.UIRoot.NewAnimation_light, startTime, 0, 999, 0, 0.15);
end

function UI_Anniversary_Actvity:PlayDebrisAnimation(itemCount)
    log("PlayDebrisAnimation");
    debrisCountCache = debrisCountCache + itemCount;
    self.UIRoot.Text_Debris:SetText(debrisCountCache);
    self.UIRoot.Text_DebrisAni:SetText(debrisCountCache);
    self.UIRoot:PlayAnimation(self.UIRoot.NewAnimation_suipian, 0, 1, 0, 1);
end

function UI_Anniversary_Actvity:PlayItemsFlyInAniamtion()
    log("PlayItemsFlyInAniamtion");
    self.UIRoot:PlayAnimation(self.UIRoot.NewAnimation_item, 0, 1, 0, 1);
end

function UI_Anniversary_Actvity:StopAniamtion()
    self.UIRoot:StopAnimation(self.UIRoot.NewAnimation_item);
end

function UI_Anniversary_Actvity:PauseIdleAniamtion()
    log("PauseIdleAniamtion")
    isStop = true;
    local startTime = self:GetAnimationStartTimeAndIndex();
    self.UIRoot:PlayAnimationTo(self.UIRoot.NewAnimation_light, startTime, 0, 999, 0, 0);
end

function UI_Anniversary_Actvity:GetAnimationStartTimeAndIndex()
    local currentAniTime = self.UIRoot:GetAnimationCurrentTime(self.UIRoot.NewAnimation_light);
    log("currentAniTime is .. :" .. currentAniTime);
    local index = math.floor(currentAniTime / 0.15) + 1;
    if(index > 12) then -- 会有超出整个动画长度一点点的情况出现
        index = 12;
    end
    log("index is : " .. index);
    log("ItemAnimationIndex[index] is .. " .. ItemAnimationIndex[index]);
    return ItemAnimationIndex[index], index;
end

function UI_Anniversary_Actvity:PlayDrawOneAnimationStart()
    log("PlayDrawOneAnimationStart");
    --self:RemoveControlEvent("NewAnimation_light", "OnAnimationFinished");
    if AnniversaryActivitySystem.IsShowAniamtion == false then
        print("AnniversaryActivitySystem.IsShowAniamtion", AnniversaryActivitySystem.IsShowAniamtion);
        self:OnDrawOneAnimationFinished(true);
        return;
    end
    self.UIRoot.Check_ShowAniamtion:SetVisibility(UEnums.ESlateVisibility.Hidden);
    
    local startTime, index;
    if isStop then
        startTime = stopAnimation.startTime;
        index = stopAnimation.index;
    end
    startTime, index = self:GetAnimationStartTimeAndIndex();
    local endTime = ItemAnimationIndex[(index + 3) % 12];
    --self.UIRoot.NewAnimation_light:BindEventToOnAnimationFinished()
    self:AddControlEvent("NewAnimation_light", "OnAnimationFinished", self.PlayDrawOneAnimationLoop, self);
    self.UIRoot:PlayAnimationTo(self.UIRoot.NewAnimation_light, startTime, endTime, 1, 0, 0.5);
    self.UIRoot.WidgetSwitcher_eff:SetActiveWidgetIndex(1);
    isCanClickButton = false;
end

function UI_Anniversary_Actvity:PlayDrawOneAnimationLoop()
    log("PlayDrawOneAnimationLoop");
    --self:RemoveControlEvent("NewAnimation_light", "OnAnimationFinished");
    local startTime, index = self:GetAnimationStartTimeAndIndex(); 
    local index = AnniversaryActivitySystem.DropList[1];    --直到最后5个前，高速转动
    log("DropIndex is : " .. index);
    if index > 5 then
        local endTime = ItemAnimationIndex[index - 5];
        self.UIRoot:PlayAnimationTo(self.UIRoot.NewAnimation_light, startTime, endTime, 3, 0, 2.5);
    else
        local endTime = ItemAnimationIndex[index + 12 - 5];
        self.UIRoot:PlayAnimationTo(self.UIRoot.NewAnimation_light, startTime, endTime, 3, 0, 2.5);
    end
    self:AddControlEvent("NewAnimation_light", "OnAnimationFinished", self.PlayDrawOneAnimationEnd, self);
end

function UI_Anniversary_Actvity:PlayDrawOneAnimationEnd()
    log("PlayDrawOneAnimationEnd");
    --self:RemoveControlEvent("NewAnimation_light", "OnAnimationFinished");
    local startTime, oldIndex = self:GetAnimationStartTimeAndIndex();
    local index = AnniversaryActivitySystem.DropList[1];
    log("DropIndex is : " .. index);
    local endTime = ItemAnimationIndex[index];
    log("startTime : " .. startTime);
    log("endTime : " .. endTime);
    local round;
    if index > 5 then
        round = 1;
    else
        round = 2;
    end
    self.UIRoot:PlayAnimationTo(self.UIRoot.NewAnimation_light, startTime, endTime, round, 0, 0.3);
    self:AddControlEvent("NewAnimation_light", "OnAnimationFinished", self.OnDrawOneAnimationFinished, self);
end

function UI_Anniversary_Actvity:OnDrawOneAnimationFinished(isJumpAnimation)
    if AnniversaryActivitySystem.DropItemConfig[AnniversaryActivitySystem.DropList[1]].itemId == AnniversaryActivitySystem.DebrisID then
        self:PlayDebrisAnimation(AnniversaryActivitySystem.DropItemConfig[AnniversaryActivitySystem.DropList[1]].itemCount);
    end

    self:SetTreatureBox();
    if isJumpAnimation then
        AnniversaryActivitySystem.ShowItemGetPanel();
        self:SetDebrisCount();
        self:PlayIdleAnimation();
        self.UIRoot.Check_ShowAniamtion:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible);
        isCanClickButton = true;
        return;
    end
    
    self:StopAniamtion();
    self.UIRoot.WidgetSwitcher_eff:SetActiveWidgetIndex(0);
    local image = self.UIRoot["Image_eff" .. AnniversaryActivitySystem.DropList[1]];
    self:AddTimer(0.5, function ()
        image:SetVisibility(UEnums.ESlateVisibility.Hidden)
        coroutine.yield(0.5)
        image:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        coroutine.yield(0.5)
        image:SetVisibility(UEnums.ESlateVisibility.Hidden)
        coroutine.yield(0.5)

        image:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)

        AnniversaryActivitySystem.ShowItemGetPanel();
        self:SetDebrisCount();
        self:PlayIdleAnimation();
        self.UIRoot.Check_ShowAniamtion:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible);
        isCanClickButton = true;
    end)
end

function UI_Anniversary_Actvity:PlayDrawTenAniamtionOneTurn()
    log("=================PlayDrawTenAniamtionOneTurn")
    if AnniversaryActivitySystem.IsShowAniamtion == false then   --如果跳过动画
        --self:ShowAllItem();
        AnniversaryActivitySystem.ShowItemGetPanel();
        self:PlayIdleAnimation();
        self:SetDebrisCount();
        self:HideItemBox();
        self:SetTreatureBox();
        return;
    end
    local startTime, oldIndex;
    if drawTenStage == 1 then   --10连抽第一次
        self:ShowItemBox();
        self.UIRoot.WidgetSwitcher_eff:SetActiveWidgetIndex(1);
        if isStop then
            startTime = stopAnimation.startTime;
            oldIndex = stopAnimation.index;
        end
        isCanClickButton = false;
        startTime, oldIndex = self:GetAnimationStartTimeAndIndex();
    else
        oldIndex = AnniversaryActivitySystem.DropList[drawTenStage - 1]
        startTime = ItemAnimationIndex[oldIndex];
    end
    local newIndex = AnniversaryActivitySystem.DropList[drawTenStage];
    if not newIndex then    --10连抽最后一次
        AnniversaryActivitySystem.ShowItemGetPanel();
        self:RemoveControlEvent("NewAnimation_light", "OnAnimationFinished");
        self:PlayIdleAnimation();
        self:SetDebrisCount();
        self:HideItemBox();
        self:SetShowAniamtionCheckBox();
        self:SetTreatureBox();
        self.UIRoot.WidgetSwitcher_eff:SetActiveWidgetIndex(0);
        isCanClickButton = true;
        return;
    end

    log("PlayDrawTenAniamtionOneTurn, stage is : " .. drawTenStage);
    
    local endTime = ItemAnimationIndex[newIndex];
    local round;
    if newIndex > oldIndex then
        round = 3;
        self.UIRoot:PlayAnimationTo(self.UIRoot.NewAnimation_light, startTime, endTime, round, 0, 3.5);
    else
        round = 4;
        self.UIRoot:PlayAnimationTo(self.UIRoot.NewAnimation_light, startTime, endTime, round, 0, 3.5);
    end
    self:AddControlEvent("NewAnimation_light", "OnAnimationFinished", self.OnPlayDrawTenAniamtionOneTurnFinished, self);
end

function UI_Anniversary_Actvity:OnPlayDrawTenAniamtionOneTurnFinished()
    self:ShowItem();
    drawTenStage = drawTenStage + 1;
    Timer.InsertTimer(0.7, function () self:PlayDrawTenAniamtionOneTurn(); end, 
            false, true)
end



local class = require("class")
local ui_base = require("ui.base")
local CUIAnniversary_Actvity = class(ui_base, nil, UI_Anniversary_Actvity)

return CUIAnniversary_Actvity