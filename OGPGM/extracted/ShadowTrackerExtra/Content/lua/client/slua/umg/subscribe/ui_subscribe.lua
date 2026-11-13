-- 订阅主界面

local UI_Subscribe =
{
    isshowing = false,
    time_ticker = nil,  --时间倒计时 计时器
    Show_time = nil,    --1S后显示倒计时时间
    left_time = 0,      --剩余时间
    slot =      --UI 槽位 界面打开时候 赋值 结束销毁
    {

    }

}



function UI_Subscribe:ctor()
    --这里可以做些数据初始化工作
    self.slot = {}
    UI_Subscribe.isshowing = true
end

function UI_Subscribe:OnInitialize()
    UI_Subscribe.__super.OnInitialize(self)
    --在这里做些初始化工作
    log("UI_Subscribe:OnInitialize")

end

function UI_Subscribe:RegistEvents()
    UI_Subscribe.__super.RegistEvents(self)
    -- 在这里注册事件

    self:AddOnClickedEvent("Button_CloseUI", self.CloseSubscribeUI, self)
    self:AddOnClickedEvent("Button_buy_Normal", self.BuyNormal, self)
    self:AddOnClickedEvent("Button_Buy_Super", self.BuySuper, self)
    self:AddOnClickedEvent("Button_Help", self.ClickHelp, self)
    self:AddOnClickedEvent("Button_rule", self.ClickHelp, self)
    self:AddOnClickedEvent("BothHelp", self.ClickHelp, self)


    self:AddCommonEvent(EVENTTYPE_SUBSCRIBE, EVENTID_SUBSCRIBE_GET_UC_DATA, self.OnReciveGetUCDATA, self)
    self:AddCommonEvent(EVENTTYPE_SUBSCRIBE, EVENTID_SUBSCRIBE_GET_RP_DATA, self.OnReciveRPDATA, self)
    self:AddCommonEvent(EVENTTYPE_SUBSCRIBE, EVENTID_SUBSCRIBE_GET_AWARD, self.OnReciveGetAwardDATA, self)
    self:AddCommonEvent(EVENTTYPE_SUBSCRIBE, EVENTID_SUBSCRIBE_JUMP, self.CloseSubscribeUI, self)
    self:AddCommonEvent(EVENTTYPE_SUBSCRIBE, EVENTID_SUBSCRIBE_DAILYSHOP_DATA, self.OnReciveDailyBuyData, self)
    self:AddCommonEvent(EVENTTYPE_SUBSCRIBE, EVENTID_SUBSCRIBE_GET_STATUS_DATA, self.DataChanged)

    self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_TICKET_CHANGE, self.Set_Money, self)

end

function UI_Subscribe:UnRegistEvents()

    -- 在这里反注册事件

    UI_Subscribe.__super.UnRegistEvents(self)
   -- EventSystem:unregistEvent(EVENTTYPE_SUBSCRIBE, EVENTID_SUBSCRIBE_GET_UC_DATA, self.OnReciveGetUCDATA)
end

function UI_Subscribe:OnPostInitialize()
    UI_Subscribe.__super.OnPostInitialize(self)
    --OnPostInitialize在OnInitialize、RegistEvents之后，有需要在RegistEvents后初始化的工作写这里
    --self:SetFunction()
    self:SetByStatus()

    self:SetFunctionUI()

    self:SetTickTime()

    self:Set_Money()

    JumpUtils.RequestJumpMapInfo()      --steveou 要求打开界面调这个
end

-- 仅在需要监听状态变化时写这个函数
--[[function UI_Subscribe:OnModeSwitch(preStatus, currentStatus)
end
]]
function UI_Subscribe:Close()
    --todo这里做些消耗回收动作，注意UI_Subscribe.__super.Close(self)一定要写在最后，遵循先进后出原则
    UI_Subscribe.__super.Close(self)
    self.slot = {}
    -- 销毁定时器
    if UI_Subscribe.time_ticker then
        Timer.RemoveTimer(UI_Subscribe.time_ticker)
    end
    if UI_Subscribe.Show_time then
        Timer.RemoveTimer(UI_Subscribe.Show_time)
    end
    UI_Subscribe.isshowing = false

end

function UI_Subscribe:SetTickTime()
    UI_Subscribe.left_time = FuncUtil.getTodayTimeStamp()
    UI_Subscribe.Show_time = Timer.InsertTimer(1, function ()
        self.UIRoot.TickTime:SetVisibility(UEnums.ESlateVisibility.Visible)
    end,false,false)

    UI_Subscribe.time_ticker = Timer.InsertTimer(1, function ()
        UI_Subscribe.left_time = UI_Subscribe.left_time - 1
        local time_text = FuncUtil.FormatTimeCountDown2(UI_Subscribe.left_time)
        time_text = FuncUtil.LocalizeResFormat(6784,time_text)
        self.UIRoot.TickTime:SetText(time_text)
    end,true,true)
end

function UI_Subscribe:CloseSubscribeUI()
    self:PlayAudio(require("client.slua.config.sound").close)
    local uiManager = require("ui.manager");
    if uiManager then
        uiManager.CloseUI(uiManager.UI_Config.ui_subscribe)
    end
end

function UI_Subscribe:BuyNormal()
    self:PlayAudio(require("client.slua.config.sound").confirm);
    local uiManager = require("ui.manager")
    if uiManager then
        uiManager.ShowUI(uiManager.UI_Config.ui_subscribe_confirm_buy,NewSubscribeSystem.ENUM_SubId.Normal)
    end

end

function UI_Subscribe:BuySuper()


    self:PlayAudio(require("client.slua.config.sound").confirm);
    local uiManager = require("ui.manager")
    if uiManager then
        uiManager.ShowUI(uiManager.UI_Config.ui_subscribe_confirm_buy,NewSubscribeSystem.ENUM_SubId.Super)
    end
end

function UI_Subscribe:ClickHelp()
    self:PlayAudio(require("client.slua.config.sound").confirm);
    local title = FuncUtil.GetLocalizeResStr("6371")
    local content = FuncUtil.GetLocalizeResStr("6372")
    PopUpNoticeUI.ShowMessageBox(title, content);
end

function UI_Subscribe:Set_Money()
    log("zino prime ui money " .. DataMgr.ticket)
    self.UIRoot.UCNum:SetText(tostring(DataMgr.ticket))
    self.UIRoot.GoldNum:SetText(tostring(DataMgr.gold))
    self.UIRoot.TextBlock_Super_Describe:SetText(FuncUtil.GetLocalizeResStr(6786))
    self.UIRoot.TextBlock_normal_describe:SetText(FuncUtil.GetLocalizeResStr(6785))

end

function UI_Subscribe:SetShowPrice(type)
    if type == NewSubscribeSystem.ENUM_SubId.Normal then
        self.UIRoot.firstmonth_normalprice:SetText(NewSubscribeSystem.Get_Price(NewSubscribeSystem.ENUM_SubId.Normal))
    end

    if type == NewSubscribeSystem.ENUM_SubId.Super then
        if NewSubscribeSystem.Get_First_Month_Price() == "" then
            --说明没有首月折扣
            self.UIRoot.super_discount:SetVisibility(UEnums.ESlateVisibility.Collapsed)
            self.UIRoot.firstmonth_superprice:SetText(NewSubscribeSystem.Get_Price(NewSubscribeSystem.ENUM_SubId.Super))

        else
            self.UIRoot.super_discount:SetVisibility(UEnums.ESlateVisibility.Visible)
            self.UIRoot.firstmonth_superprice:SetText(NewSubscribeSystem.Get_First_Month_Price())
            self.UIRoot.firstmonth_superpriceoldprice:SetText(NewSubscribeSystem.Get_Price(NewSubscribeSystem.ENUM_SubId.Super))
        end
    end
end

--根据订阅状态设置左侧栏和顶部栏
function UI_Subscribe:SetByStatus()
    if NewSubscribeSystem.GetSubStatus() == NewSubscribeSystem.ENUM_SubStatus.NormalStatus then
        self.UIRoot.WidgetSwitcher_left:SetVisibility(UEnums.ESlateVisibility.Visible)
        self.UIRoot.WidgetSwitcher_left:SetActiveWidgetIndex(1)
        self.UIRoot.WidgetSwitcher_Top:SetActiveWidgetIndex(0)
        NewSubscribeSystem.LoadPrice()
        self:SetShowPrice(NewSubscribeSystem.ENUM_SubId.Super)
        --log_tree("NewSubscribeSystem._NormalInfo._InfoList",NewSubscribeSystem._NormalInfo._InfoList)



    elseif NewSubscribeSystem.GetSubStatus() == NewSubscribeSystem.ENUM_SubStatus.SuperStatus then
        self.UIRoot.WidgetSwitcher_left:SetVisibility(UEnums.ESlateVisibility.Visible)
        self.UIRoot.WidgetSwitcher_left:SetActiveWidgetIndex(0)
        self.UIRoot.WidgetSwitcher_Top:SetActiveWidgetIndex(1)
        NewSubscribeSystem.LoadPrice()
        self:SetShowPrice(NewSubscribeSystem.ENUM_SubId.Normal)

    elseif NewSubscribeSystem.GetSubStatus() == NewSubscribeSystem.ENUM_SubStatus.BothStatus then
        self.UIRoot.WidgetSwitcher_left:SetVisibility(UEnums.ESlateVisibility.Collapsed)
        self.UIRoot.ScaleBox_both:SetVisibility(UEnums.ESlateVisibility.Hidden)
        self.UIRoot.WidgetSwitcher_Top:SetActiveWidgetIndex(2)
    end

end

function UI_Subscribe:SetFunctionUI()
    log_tree("NewSubscribeSystem._SuperInfo._InfoList",NewSubscribeSystem._SuperInfo._InfoList)
    for i, v in pairs(NewSubscribeSystem._SuperInfo._InfoList) do
        if i == NewSubscribeSystem.ENUM_SubInfoID.EVERYDAY_GET_UC then
            self:Handle_Get_UC()
        end
        if i == NewSubscribeSystem.ENUM_SubInfoID.DISCOUNT_BOX then
            self:Handle_Go_Supply()
        end
        if i == NewSubscribeSystem.ENUM_SubInfoID.EXTRA_RP_SCORE then
            self:Handle_UPASS()
        end
        if i == NewSubscribeSystem.ENUM_SubInfoID.SHOP_BUY then
            self:Handle_BP_BUY()
        end
        if i == NewSubscribeSystem.ENUM_SubInfoID.DISCOUNT_ITEM then
            self:Handle_DisCount_Buy()
        end

    end

    self:Handle_Take_Award()

end

function UI_Subscribe:CreateUIObject(SubFuncID)
    local ChildItemClass = require("client.slua.umg.subscribe.ui_subscribe_subFunc")
    local childItem = ChildItemClass(SubFuncID)
    if childItem then
        self.slot[SubFuncID] = childItem
        childItem:Init("/Game/UMG/UI_BP/Lobby_Store_Int/Lobby_Store_Member0115_item_UIBP.Lobby_Store_Member0115_item_UIBP", "", 0)
        self:AttachChildWindow("WrapBox_6",childItem)
        return childItem
    end
end

--单独创建领取奖励object
function UI_Subscribe:CreateUIObject_GetAward()
    local ChildItemClass = require("client.slua.umg.subscribe.ui_subscribe_getaward")
    local childItem = ChildItemClass()
    if childItem then
        self.slot[NewSubscribeSystem.ENUM_SubInfoID.Get_Award] = childItem
        childItem:Init("/Game/UMG/UI_BP/Lobby_Store_Int/Lobby_Store_Member0115_item02_UIBP.Lobby_Store_Member0115_item02_UIBP", "", 0)
        self:AttachChildWindow("WrapBox_6",childItem)
        return childItem
    end
end

--处理1001 每日领取UC UI界面
function UI_Subscribe:Handle_Get_UC()

    local data = NewSubscribeSystem._NormalInfo._InfoList[NewSubscribeSystem.ENUM_SubInfoID.EVERYDAY_GET_UC]
    if data then
        local childItem = self:CreateUIObject(NewSubscribeSystem.ENUM_SubInfoID.EVERYDAY_GET_UC)
        if childItem then


            childItem.UIRoot.WidgetSwitcher_rightup:SetActiveWidgetIndex(0)

            local currentStatus = NewSubscribeSystem.GetSubStatus()
            if currentStatus == NewSubscribeSystem.ENUM_SubStatus.NormalStatus then
                childItem.UIRoot.Name:SetText(FuncUtil.GetLocalizeResStr(6822))
            else
                if data.Name then
                    childItem.UIRoot.Name:SetText(data.Name)
                end
            end


            childItem.UIRoot.WidgetSwitcher_down:SetActiveWidgetIndex(1)
            childItem.UIRoot.GetNum:SetVisibility(UEnums.ESlateVisibility.Visible)
            childItem.UIRoot.GetNum:SetText(tostring(NewSubscribeSystem.GetShowNum()))

            local everyDayGetTimes = NewSubscribeSystem.Get_EveryDay_Times_Buy_Status(currentStatus)
            if everyDayGetTimes and everyDayGetTimes > 1 then
                log("need to lingqu :" .. tostring(everyDayGetTimes) )
                childItem.UIRoot.WidgetSwitcher_rightup:SetVisibility(UEnums.ESlateVisibility.Visible)
                childItem.UIRoot.ButtonDescribe:SetText(FuncUtil.GetLocalizeResStr(6174))
                childItem.UIRoot.num:SetText(tostring(everyDayGetTimes - 1))
            elseif everyDayGetTimes == 1 then
                childItem.UIRoot.WidgetSwitcher_rightup:SetVisibility(UEnums.ESlateVisibility.Collapsed)
                childItem.UIRoot.ButtonDescribe:SetText(FuncUtil.GetLocalizeResStr(6174))
            else
                childItem.UIRoot.WidgetSwitcher_down:SetActiveWidgetIndex(2)
                childItem.UIRoot.ButtonSoldDescribe:SetText(FuncUtil.GetLocalizeResStr(6162))
                childItem.UIRoot.WidgetSwitcher_rightup:SetVisibility(UEnums.ESlateVisibility.Collapsed)
                childItem.UIRoot.WidgetSwitcher_down:SetActiveWidgetIndex(2)

            end

        end
    end

end

--1002 BP直购
function UI_Subscribe:Handle_BP_BUY()
    local data = NewSubscribeSystem._SuperInfo._InfoList[NewSubscribeSystem.ENUM_SubInfoID.SHOP_BUY]
    if data then
        local childItem = self:CreateUIObject(NewSubscribeSystem.ENUM_SubInfoID.SHOP_BUY)
        if childItem then
            if data.Name then
                childItem.UIRoot.Name:SetText(data.Name)
            end
            local BusinessHelper = import("BusinessHelper")
            local res = BusinessHelper.UIGetResWithPath("/Game/Arts/UI/TableIcons/ItemIcon/Currency/Store_Member_256_box02.Store_Member_256_box02")
            childItem.UIRoot.Image_Good:SetBrushFromTexture(res, false)

            childItem.UIRoot.WidgetSwitcher_down:SetActiveWidgetIndex(1)
            childItem.UIRoot.WidgetSwitcher_rightup:SetActiveWidgetIndex(2)
            childItem.UIRoot.ButtonDescribe:SetText(FuncUtil.GetLocalizeResStr(6779))

        end
    end
end

--处理1004 额外PASS积分领取
function UI_Subscribe:Handle_UPASS()
    local data = NewSubscribeSystem._SuperInfo._InfoList[NewSubscribeSystem.ENUM_SubInfoID.EXTRA_RP_SCORE]
    if data then
        local childItem = self:CreateUIObject(NewSubscribeSystem.ENUM_SubInfoID.EXTRA_RP_SCORE)
        if childItem then

            if data.Name then
                childItem.UIRoot.Name:SetText(data.Name)
            end
            local BusinessHelper = import("BusinessHelper")
            local res = BusinessHelper.UIGetResWithPath("/Game/Arts/UI/TableIcons/ItemIcon/Currency/Store_Member_256_badge01.Store_Member_256_badge01")
            childItem.UIRoot.Image_Good:SetBrushFromTexture(res, false)

            childItem.UIRoot.WidgetSwitcher_rightup:SetVisibility(UEnums.ESlateVisibility.Collapsed)

            local currentStatus = NewSubscribeSystem.GetSubStatus()
            if currentStatus == NewSubscribeSystem.ENUM_SubStatus.NormalStatus then
                childItem.UIRoot.panel_button:SetVisibility(UEnums.ESlateVisibility.Collapsed)
                childItem.UIRoot.CanvasPanel_Lock:SetVisibility(UEnums.ESlateVisibility.Visible)
            else
                childItem.UIRoot.WidgetSwitcher_down:SetActiveWidgetIndex(1)

                childItem.UIRoot.GetNum:SetVisibility(UEnums.ESlateVisibility.Visible)
                childItem.UIRoot.GetNum:SetText(tostring(NewSubscribeSystem.Get_UPASS_Num()))
                if NewSubscribeSystem.Get_UPASS_Is_Take() then
                    childItem.UIRoot.ButtonDescribe:SetText(FuncUtil.GetLocalizeResStr(6174))
                else
                    childItem.UIRoot.ButtonSoldDescribe:SetText(FuncUtil.GetLocalizeResStr(6175))
                    childItem.UIRoot.WidgetSwitcher_down:SetActiveWidgetIndex(2)
                end
            end

        end
    end
end

--1005 每日折扣
function UI_Subscribe:Handle_DisCount_Buy()
    local data = NewSubscribeSystem._SuperInfo._InfoList[NewSubscribeSystem.ENUM_SubInfoID.DISCOUNT_ITEM]
    if data then
        local childItem = self:CreateUIObject(NewSubscribeSystem.ENUM_SubInfoID.DISCOUNT_ITEM)
        if childItem then
            if data.Name then
                childItem.UIRoot.Name:SetText(data.Name)
            end
            local itemInfo = NewSubscribeSystem._SuperInfo._InfoList[NewSubscribeSystem.ENUM_SubInfoID.DISCOUNT_ITEM]
            if itemInfo then
                log_tree("Discount ITEM INFO ",itemInfo)
                if itemInfo.item_id then
                    local itemcfg = Client.GetTableData("Item", itemInfo.item_id)
                    if itemcfg then
                        local BusinessHelper = import("BusinessHelper")
                        if itemcfg.ItemBigIcon then
                            local res = BusinessHelper.UIGetResWithPath(itemcfg.ItemBigIcon)
                            if res then
                                childItem.UIRoot.Image_Good:SetBrushFromTexture(res, false)
                            end
                        elseif itemcfg.ItemSmallIcon then
                            local res = BusinessHelper.UIGetResWithPath(itemcfg.ItemSmallIcon)
                            if res then
                                childItem.UIRoot.Image_Good:SetBrushFromTexture(res, false)
                            end
                        end
                    end
                end
                if NewSubscribeSystem.Get_Discount_Is_Could_Buy() then
                    if itemInfo.sale_price then
                        childItem.UIRoot.SalePrice:SetText(tostring(itemInfo.sale_price))
                    end

                    if itemInfo.ori_price then
                        childItem.UIRoot.OldPrice:SetText(tostring(itemInfo.ori_price))
                    end

                else
                    childItem.UIRoot.WidgetSwitcher_down:SetActiveWidgetIndex(2)
                    childItem.UIRoot.ButtonSoldDescribe:SetText(FuncUtil.GetLocalizeResStr(4793))
                end

                if itemInfo.sale then
                    childItem.UIRoot.Discount_NUM:SetText("-"..tostring(100 - itemInfo.sale).."%")
                end
                if itemInfo.item_num then
                    childItem.UIRoot.GetNum:SetText(tostring(itemInfo.item_num))
                    childItem.UIRoot.GetNum:SetVisibility(UEnums.ESlateVisibility.Visible)
                end
            end
            local currentStatus = NewSubscribeSystem.GetSubStatus()
            if currentStatus == NewSubscribeSystem.ENUM_SubStatus.NormalStatus then
                childItem.UIRoot.panel_button:SetVisibility(UEnums.ESlateVisibility.Collapsed)
                childItem.UIRoot.WidgetSwitcher_rightup:SetVisibility(UEnums.ESlateVisibility.Collapsed)
                childItem.UIRoot.CanvasPanel_Lock:SetVisibility(UEnums.ESlateVisibility.Visible)
            else
                childItem.UIRoot.WidgetSwitcher_rightup:SetActiveWidgetIndex(1)

            end
        end
    end
end

--处理1006 补给 UI界面
function UI_Subscribe:Handle_Go_Supply()
    local data = NewSubscribeSystem._SuperInfo._InfoList[NewSubscribeSystem.ENUM_SubInfoID.DISCOUNT_BOX]
    if data then
        local childItem = self:CreateUIObject(NewSubscribeSystem.ENUM_SubInfoID.DISCOUNT_BOX)
        if childItem then
            if data.Name then
                childItem.UIRoot.Name:SetText(data.Name)
            end

            local BusinessHelper = import("BusinessHelper")
            local res = BusinessHelper.UIGetResWithPath("/Game/Arts/UI/TableIcons/ItemIcon/Currency/Store_Member_256_box01.Store_Member_256_box01")
            childItem.UIRoot.Image_Good:SetBrushFromTexture(res, false)
            local currentStatus = NewSubscribeSystem.GetSubStatus()
            if currentStatus  == NewSubscribeSystem.ENUM_SubStatus.NormalStatus then
                childItem.UIRoot.panel_button:SetVisibility(UEnums.ESlateVisibility.Collapsed)
                childItem.UIRoot.WidgetSwitcher_rightup:SetVisibility(UEnums.ESlateVisibility.Collapsed)
                childItem.UIRoot.CanvasPanel_Lock:SetVisibility(UEnums.ESlateVisibility.Visible)
            else
                childItem.UIRoot.WidgetSwitcher_down:SetActiveWidgetIndex(1)
                childItem.UIRoot.WidgetSwitcher_rightup:SetActiveWidgetIndex(1)
                childItem.UIRoot.ButtonDescribe:SetText(FuncUtil.GetLocalizeResStr(6780))

                local discountnum = NewSubscribeSystem.Get_Supply_Discount_Num()
                log("discountnum " .. tostring(discountnum))
                discountnum = math.floor(discountnum * 100)
                childItem.UIRoot.Discount_NUM:SetText("-"..tostring(100 - discountnum).."%")
                if NewSubscribeSystem._SuperInfo._redpoint then
                    childItem.UIRoot.Image_reddot:SetVisibility(UEnums.ESlateVisibility.Visible)
                    NewSubscribeSystem._SuperInfo._redpoint = false
                end
            end

        end
    end

end

--奖励领取界面

function UI_Subscribe:Handle_Take_Award()
    local childItem = self:CreateUIObject_GetAward()
    if childItem then
        local num = 1
        for i, v in pairs(NewSubscribeSystem._SuperInfo._DropAwardList) do
            local itemcfg = Client.GetTableData("Item", v.itemid)
            local BusinessHelper = import("BusinessHelper")
            if itemcfg then

                if itemcfg.ItemBigIcon then
                    local res = BusinessHelper.UIGetResWithPath(itemcfg.ItemSmallIcon)
                    if res then
                        if num == 1 then
                            childItem.UIRoot.award1:SetBrushFromTexture(res, false)
                        end
                        if num == 2 then
                            childItem.UIRoot.award2:SetBrushFromTexture(res, false)
                        end
                        if num == 3 then
                            childItem.UIRoot.award3:SetBrushFromTexture(res, false)
                        end
                        if num == 4 then
                            childItem.UIRoot.award4:SetBrushFromTexture(res, false)
                        end

                    end
                elseif itemcfg.ItemSmallIcon then

                    local res = BusinessHelper.UIGetResWithPath(itemcfg.ItemSmallIcon)
                    if res then
                        if num == 1 then
                            childItem.UIRoot.award1:SetBrushFromTexture(res, false)
                        end
                        if num == 2 then
                            childItem.UIRoot.award2:SetBrushFromTexture(res, false)
                        end
                        if num == 3 then
                            childItem.UIRoot.award3:SetBrushFromTexture(res, false)
                        end
                        if num == 4 then
                            childItem.UIRoot.award4:SetBrushFromTexture(res, false)
                        end
                    end
                end
            end
            num = num + 1
        end

        local currentStatus = NewSubscribeSystem.GetSubStatus()

        if currentStatus == NewSubscribeSystem.ENUM_SubStatus.NormalStatus then
            childItem.UIRoot.CanvasPanel_lock:SetVisibility(UEnums.ESlateVisibility.Visible)    --显示锁
        else
            local iscouldGet = NewSubscribeSystem.Get_Is_Could_Take_Award()
            if iscouldGet then
                childItem.UIRoot.Image_eff:SetVisibility(UEnums.ESlateVisibility.Visible)    --显示特效
            else
                childItem.UIRoot.Canvas_Panel_ylq:SetVisibility(UEnums.ESlateVisibility.Visible)    --显示已领取
            end
        end
    end
end

--收到每日领取UC 回包
function UI_Subscribe:OnReciveGetUCDATA()
    --if ret and number and super_times and normal_times then

    local UI_Slot_GetUC = self.slot[NewSubscribeSystem.ENUM_SubInfoID.EVERYDAY_GET_UC]
    if UI_Slot_GetUC then
        local everyDayGetTimes = NewSubscribeSystem.Get_EveryDay_Times_Buy_Status(NewSubscribeSystem.GetSubStatus())

        if  everyDayGetTimes and everyDayGetTimes > 1 then
            log("need to lingqu :" .. tostring(everyDayGetTimes) )
            UI_Slot_GetUC.UIRoot.WidgetSwitcher_rightup:SetVisibility(UEnums.ESlateVisibility.Visible)
            UI_Slot_GetUC.UIRoot.ButtonDescribe:SetText(FuncUtil.GetLocalizeResStr(6174))
            UI_Slot_GetUC.UIRoot.num:SetText(tostring(everyDayGetTimes - 1))
        elseif  everyDayGetTimes == 1 then
            log(" everyDayGetTimes == 1")
            UI_Slot_GetUC.UIRoot.WidgetSwitcher_down:SetActiveWidgetIndex(1)
            UI_Slot_GetUC.UIRoot.WidgetSwitcher_rightup:SetVisibility(UEnums.ESlateVisibility.Collapsed)
            UI_Slot_GetUC.UIRoot.ButtonDescribe:SetText(FuncUtil.GetLocalizeResStr(6174))
        else
            UI_Slot_GetUC.UIRoot.ButtonSoldDescribe:SetText(FuncUtil.GetLocalizeResStr(6175))
            UI_Slot_GetUC.UIRoot.WidgetSwitcher_rightup:SetVisibility(UEnums.ESlateVisibility.Collapsed)
            UI_Slot_GetUC.UIRoot.WidgetSwitcher_down:SetActiveWidgetIndex(2)
        end
        UI_Slot_GetUC.UIRoot.GetNum:SetText(tostring(NewSubscribeSystem.GetShowNum()))
    else
        log("illegal OnReciveGetUCDATA")
    end


end

--收到RP数据回包
function UI_Subscribe:OnReciveRPDATA()
    local UI_Slot_GetUC = self.slot[NewSubscribeSystem.ENUM_SubInfoID.EXTRA_RP_SCORE]
    if UI_Slot_GetUC then
        UI_Slot_GetUC.UIRoot.ButtonSoldDescribe:SetText(FuncUtil.GetLocalizeResStr(6175))
        UI_Slot_GetUC.UIRoot.WidgetSwitcher_down:SetActiveWidgetIndex(2)
    end
end

--收到领取奖励回包
function UI_Subscribe:OnReciveGetAwardDATA()
    local UI_Slot_Get_Award = self.slot[NewSubscribeSystem.ENUM_SubInfoID.Get_Award]
    if UI_Slot_Get_Award then
        UI_Slot_Get_Award.UIRoot.Canvas_Panel_ylq:SetVisibility(UEnums.ESlateVisibility.Visible)
        UI_Slot_Get_Award.UIRoot.Image_eff:SetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
end

function UI_Subscribe:OnReciveDailyBuyData()
    log("OnReciveDailyBuyData")
    local UI_Slot = self.slot[NewSubscribeSystem.ENUM_SubInfoID.DISCOUNT_ITEM]
    if UI_Slot then
        UI_Slot.UIRoot.WidgetSwitcher_down:SetActiveWidgetIndex(2)
        UI_Slot.UIRoot.ButtonSoldDescribe:SetText(FuncUtil.GetLocalizeResStr(4793))
    end
end

--收到刷新数据
function UI_Subscribe:DataChanged()
    log("UI_Subscribe.isshowing " .. tostring(UI_Subscribe.isshowing))
    if UI_Subscribe.isshowing then
        local uiManager = require("ui.manager")
        if uiManager then
            local uisubscribe = uiManager.GetUI(uiManager.UI_Config.ui_subscribe)
            if uisubscribe then
                log("find uisubscribe")
                uisubscribe:OnReciveGetUCDATA()

                local UI_Slot = uisubscribe.slot[NewSubscribeSystem.ENUM_SubInfoID.DISCOUNT_ITEM]      --每日物品折扣刷新
                if UI_Slot then
                    if not NewSubscribeSystem.Get_Discount_Is_Could_Buy() then
                        UI_Slot.UIRoot.WidgetSwitcher_down:SetActiveWidgetIndex(2)
                        UI_Slot.UIRoot.ButtonSoldDescribe:SetText(FuncUtil.GetLocalizeResStr(4793))
                    else

                    end
                end

                local UI_Slot_BPBUY = uisubscribe.slot[NewSubscribeSystem.ENUM_SubInfoID.DISCOUNT_BOX]  --1002 BP直购
                if UI_Slot_BPBUY then
                    if NewSubscribeSystem._SuperInfo._redpoint then
                        log("red")
                        if NewSubscribeSystem.GetSubStatus() >= NewSubscribeSystem.ENUM_SubStatus.SuperStatus then
                            UI_Slot_BPBUY.UIRoot.Image_reddot:SetVisibility(UEnums.ESlateVisibility.Visible)
                            NewSubscribeSystem._SuperInfo._redpoint = false
                        else
                            UI_Slot_BPBUY.UIRoot.Image_reddot:SetVisibility(UEnums.ESlateVisibility.Collapsed)
                        end
                    end
                end


            end
        end

    end
end

local class = require("class")
local ui_base = require("ui.base")
local CUISubscribe = class(ui_base, nil, UI_Subscribe)
return CUISubscribe