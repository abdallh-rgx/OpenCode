-- 订阅主界面

local UI_Subscribe_subFunc = {
    subFuncID = 0,
}

function UI_Subscribe_subFunc:ctor(selfType, subFuncID)
    --这里可以做些数据初始化工作
    if subFuncID then
        log("subFuncID " .. subFuncID)
        self.subFuncID = subFuncID
    end
end

function UI_Subscribe_subFunc:OnInitialize()
    UI_Subscribe_subFunc.__super.OnInitialize(self)
    --在这里做些初始化工作
end

function UI_Subscribe_subFunc:RegistEvents()
    UI_Subscribe_subFunc.__super.RegistEvents(self)
    -- 在这里注册事件
    self:AddOnClickedEvent("Button_Clicked", self.OnClicked, self)
end

function UI_Subscribe_subFunc:UnRegistEvents()

    -- 在这里反注册事件
    UI_Subscribe_subFunc.__super.UnRegistEvents(self)
end

function UI_Subscribe_subFunc:OnPostInitialize()
    --OnPostInitialize在OnInitialize、RegistEvents之后，有需要在RegistEvents后初始化的工作写这里
    UI_Subscribe_subFunc.__super.OnPostInitialize(self)

end
function UI_Subscribe_subFunc:Close()
    --todo这里做些消耗回收动作，注意UI_Subscribe.__super.Close(self)一定要写在最后，遵循先进后出原则
    UI_Subscribe_subFunc.__super.Close(self)
end
-- 仅在需要监听状态变化时写这个函数
--[[function UI_Subscribe_subFunc:OnModeSwitch(preStatus, currentStatus)
end
]]
function UI_Subscribe_subFunc:OnClicked()
    self:PlayAudio(require("client.slua.config.sound").confirm);
    log("Onclicked" .. tostring(self.subFuncID))
    if self.subFuncID == NewSubscribeSystem.ENUM_SubInfoID.EVERYDAY_GET_UC then
        log("Onclicked EVERYDAY_GET_UC")
        if NewSubscribeSystem.Get_Is_Valid(NewSubscribeSystem.ENUM_SubId.Normal) or NewSubscribeSystem.Get_Is_Valid(NewSubscribeSystem.ENUM_SubId.Super) then
            NetUtil.SendPkg("take_daily_uc_priv")
            return
        else
            DataMgr.ShowNoticeByID(9910111)
        end

    end

    if self.subFuncID == NewSubscribeSystem.ENUM_SubInfoID.SHOP_BUY then
        log("TryJumpFromSubscribeToStore ".. tostring(JumpUtils.TryJumpFromSubscribeToStore()))
        if not JumpUtils.TryJumpFromSubscribeToStore() then
            DataMgr.ShowNoticeByID(6796)
            return
        end
        EventSystem:postEvent(EVENTTYPE_SUBSCRIBE, EVENTID_SUBSCRIBE_JUMP)

    end

    if self.subFuncID == NewSubscribeSystem.ENUM_SubInfoID.EXTRA_RP_SCORE then
        log("Onclicked rprprprprprp")
        NetUtil.SendPkg("take_daily_rp_priv")
        return
    end

    if self.subFuncID == NewSubscribeSystem.ENUM_SubInfoID.DISCOUNT_ITEM then
        self:ShowCommonTip()
        return
    end

    if self.subFuncID == NewSubscribeSystem.ENUM_SubInfoID.DISCOUNT_BOX then
        if NewSubscribeSystem.GetSubStatus() < NewSubscribeSystem.ENUM_SubStatus.SuperStatus then
            return
        end
        if not JumpUtils.TryJumpFromSubscribeToSupply() then
            DataMgr.ShowNoticeByID(6795)
            return
        end
        EventSystem:postEvent(EVENTTYPE_SUBSCRIBE, EVENTID_SUBSCRIBE_JUMP)

    end

end
function UI_Subscribe_subFunc:ShowCommonTip()
    if not NewSubscribeSystem.Get_Discount_Is_Could_Buy() then
        DataMgr.ShowNoticeByID(4793)
        return
    end
        local strBuy = FuncUtil.GetLocalizeResStr("301185")

    local tip = ""
    local itemcfg = Client.GetTableData("Item", NewSubscribeSystem.Get_Discount_ITemID())
    local itemName = ""
    if itemcfg then
        itemName = itemcfg.ItemName or "";
    end
    local itemInfo = NewSubscribeSystem._SuperInfo._InfoList[NewSubscribeSystem.ENUM_SubInfoID.DISCOUNT_ITEM]
    if itemInfo and itemName ~= "" then
        if  itemInfo.sale_price then
            tip = FuncUtil.LocalizeResFormat("301374",tonumber(itemInfo.sale_price),itemName)
            CommonMessageBoxUI:ShowPanel(2, strBuy, tip,function()
                NetUtil.SendPkg("buy_discount_sale_item",NewSubscribeSystem.Get_uniq_id())
            end);
        end
    else
        NetUtil.SendPkg("buy_discount_sale_item",NewSubscribeSystem.Get_uniq_id())
    end
end

local class = require("class")
local ui_base = require("ui.base")
local CUISubscribe = class(ui_base, nil, UI_Subscribe_subFunc)
return CUISubscribe