UnknowPassExchangeConfirm = UnknowPassExchangeConfirm or
{
    IsUIShow = false,
}

BP_UnknowPass_Confirm_ExchangeId = 0;
BP_UnknowPass_Confirm_ExchangeItemId = 0;
BP_UnknowPass_Confirm_Cost_ItemId = 0;
BP_UnknowPass_Confirm_Cost_ItemNum = 0;
BP_UnknowPass_Confirm_BuyCount = 0;
BP_UnknowPass_Confirm_Limit = 0;

-- 界面选择的数量
BP_UnknowPass_Confirm_SelectCount = 0;

BP_UnknowPass_Confirm_Showtype = {}
BP_UnknowPass_Confirm_Showtype.RP = 0
BP_UnknowPass_Confirm_Showtype.ALLIANCE_COMPETITION = 1

BP_UnknowPass_Confirm_Showtype_ID = BP_UnknowPass_Confirm_Showtype.RP
function bp_unknow_pass_exchange_confirm_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_unknow_pass_exchange_confirm,
    {
        {Path="/Game/UMG/UI_Logic/UnknowPass/UnknowPass_Exchange_Confirm_Logic_BP.UnknowPass_Exchange_Confirm_Logic_BP_C", Container="Default", ZOrder=BP_ENUM_UI_BINDFB_ZORDER}
    },
    {"Lobby"},
    false,
    bp_unknow_pass_exchange_confirm_OnModeSwitched ~= nil,
    true);
end

function UnknowPassExchangeConfirm.ShowUI(typeID)
    EventSystem:registEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_SYNC, UnknowPassExchangeConfirm.OnTeamInfoChange);
    UnknowPassExchangeConfirm.IsUIShow = true;
    LuaClassObj.HandleDynamicCreation(bp_unknow_pass_exchange_confirm);
    LuaClassObj.HandleUIMessage(bp_unknow_pass_exchange_confirm, "UIShow");
    UIManager.Show(eUIType.eUnknowPassExchangeConfirmUI);

    if typeID == nil then
        BP_UnknowPass_Confirm_Showtype_ID = BP_UnknowPass_Confirm_Showtype.RP
        LuaClassObj.HandleUIMessage(bp_unknow_pass_exchange_confirm, "SetTypeRP")
    else
        BP_UnknowPass_Confirm_SelectCount = 1
        BP_UnknowPass_Confirm_Showtype_ID = typeID
        LuaClassObj.HandleUIMessage(bp_unknow_pass_exchange_confirm, "SetTypeAllianceCompetition")
    end

    if BP_UnknowPass_Confirm_Limit >= 5 then
        LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass_exchange_confirm, "ShowTenButton")
    else
        LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass_exchange_confirm, "HideTenButton")
    end
end

-- 数字发生变化
function EventUnknowPassExchangeCountChanged()
    if BP_UnknowPass_Confirm_Limit >= 5 then
        if BP_UnknowPass_Confirm_SelectCount == 1 then
            LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass_exchange_confirm, "DisableSub")
        elseif BP_UnknowPass_Confirm_SelectCount == BP_UnknowPass_Confirm_Limit - BP_UnknowPass_Confirm_BuyCount then
            LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass_exchange_confirm, "DisableAdd")
        else
            LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass_exchange_confirm, "ResumeButton")
        end
    end
end

function UnknowPassExchangeConfirm.HideUI()
    UnknowPassExchangeConfirm.IsUIShow = false;
    UIManager.Hide(eUIType.eUnknowPassExchangeConfirmUI);
    LuaClassObj.HandleUIMessage(bp_unknow_pass_exchange_confirm, "UIHide");
    EventSystem:unregistEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_SYNC, UnknowPassExchangeConfirm.OnTeamInfoChange);
end

function UnknowPassExchangeConfirm.OnTeamInfoChange()
    LuaClassObj.HandleUIMessage(bp_unknow_pass_exchange_confirm, "UIHide");
    EventSystem:unregistEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_SYNC, UnknowPassExchangeConfirm.OnTeamInfoChange);
end

function EventUnknowPassExchangeCloseClick_Push()
	UnknowPassExchangeConfirm.HideUI()
end

--sami 兑换道具请求
function UnknowPassExchangeConfirm.ExchangeItemReq()
    log("====UnknowPassExchangeConfirm.ExchangeItemReq")
    if BP_UnknowPass_Confirm_Showtype_ID == BP_UnknowPass_Confirm_Showtype.ALLIANCE_COMPETITION then
        AllianceCompetitionSystemHandler.carteam_coin_exchange_req(BP_UnknowPass_Confirm_ExchangeId, BP_UnknowPass_Confirm_SelectCount, BP_UnknowPass_Confirm_BuyCount)
    else
        local itemInfo = BP_ARRAY_UnknowPass_Exchange_Item_List[BP_UnknowPass_Exchange_Select_Index + 1]
        if itemInfo == nil then
            return
        end
        local cost = BP_UnknowPass_Confirm_SelectCount * BP_UnknowPass_Confirm_Cost_ItemNum;
        UnknowPassSystem.upass_exchange_req(itemInfo.exchangeId, BP_UnknowPass_Confirm_SelectCount, BP_UnknowPass_Confirm_BuyCount)
        UnknowPassUI.ReportBuyEvent(false, false, true, itemInfo.item_id)
    end
end

--点击确认兑换按钮
function EventUnknowPassExchangeConfirmClick_Push()
    log("====EventUnknowPassExchangeConfirmClick_Push")
    if BP_UnknowPass_Confirm_Showtype_ID == BP_UnknowPass_Confirm_Showtype.ALLIANCE_COMPETITION then
        --是否以%s战队币购买%s
        local fmt = FuncUtil.GetLocalizeResStr("505029");
        --购买
        local strBuy = Client.GetTableData("LocalizeRes", "301185").TextValue;
        local costStr = tostring(BP_UnknowPass_Confirm_SelectCount*BP_UnknowPass_Confirm_Cost_ItemNum)
        local cfgItem = Client.GetTableData("Item", BP_UnknowPass_Confirm_ExchangeItemId)
        if cfgItem == nil then
            return
        end

        local tip = fmt
        if BP_UnknowPass_Confirm_SelectCount > 1 then
            tip = string.format(fmt, costStr, cfgItem.ItemName .. " (" .. tostring(BP_UnknowPass_Confirm_SelectCount) .. ") ");
        else
            tip = string.format(fmt, costStr, cfgItem.ItemName);
        end
        
        CommonMessageBoxUI:ShowPanel(2, strBuy, tip, UnknowPassExchangeConfirm.ExchangeItemReq)
    else
        local itemInfo = BP_ARRAY_UnknowPass_Exchange_Item_List[BP_UnknowPass_Exchange_Select_Index + 1]
        if itemInfo == nil then
            return
        end

        local cfgItem = Client.GetTableData("Item", itemInfo.item_id)
        local cfgCostItem = Client.GetTableData("Item", itemInfo.cost_item_id)
        if cfgItem == nil or cfgCostItem == nil then
            return
        end

        --处理道具不足
        local benough = UnknowPassSystem.ProcItemNotEnough(itemInfo.cost_item_id, BP_UnknowPass_Confirm_SelectCount*BP_UnknowPass_Confirm_Cost_ItemNum)
        if benough == false then
            return
        end

        --"是否以%s购买%s"
        local fmt = FuncUtil.GetLocalizeResStr("6393");
        local tips = ""
        local costStr = string.format("%s %s",tostring(BP_UnknowPass_Confirm_SelectCount*BP_UnknowPass_Confirm_Cost_ItemNum), cfgCostItem.ItemName)
        local strBuy = Client.GetTableData("LocalizeRes", "301185").TextValue;
        local tip = fmt
        tip = string.gsub(tip, "{0}", costStr);
        tip = string.gsub(tip, "{1}", cfgItem.ItemName);
        if BP_UnknowPass_Confirm_SelectCount > 1 then
            tip = tip .." (" .. tostring(BP_UnknowPass_Confirm_SelectCount) .. ") "
        end
        CommonMessageBoxUI:ShowPanel(2, strBuy, tip, UnknowPassExchangeConfirm.ExchangeItemReq)
    end
end