UnknowPassBuy = UnknowPassBuy or
{
    IsUIShow = false,
}

function bp_unknow_pass_buy_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_unknow_pass_buy,
    {
        {Path="/Game/UMG/UI_Logic/UnknowPass/UnknowPass_Buy_Logic_BP.UnknowPass_Buy_Logic_BP_C", Container="Default", ZOrder=BP_ENUM_UI_BINDFB_ZORDER}
    },
    {"Lobby"},
    false,
    bp_unknow_pass_buy_OnModeSwitched ~= nil,
    true);

    EventSystem:registEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_INFO_UPDATE, UnknowPassBuy.OnInfoUpdate);
end

BP_UnknowPass_Buy_Season_Index = 0;

BP_UnknowPass_Buy_SeasonName = "";
BP_UnknowPass_Buy_SeasonTime = "";
BP_UnknowPass_Buy_Can_Play_Animation = true
BP_UnknowPass_Buy_Elite_Award_Item_Id = 0;
BP_UnknowPass_Buy_Elite_Award_Item_Num = 0;

BP_STRUCT_UnknowPass_Ordinary_Pass_Info = {
    id = 0,
    price = 0,
    discountPrice = 0,
    desc1 = "",
    desc2 = "",
    expireTips = "",
}

BP_STRUCT_UnknowPass_Elite_Pass_Info = {
    id = 0,
    price = 0,
    discountPrice = 0,
    desc1 = "",
    desc2 = "",
    expireTips = "",
}

function UnknowPassBuy.ShowUI()
    UnknowPassBuy.IsUIShow = true;
	UnknowPassUI.lastBuyLevelSelectItemId = 0
	BP_UnknowPass_Buy_Can_Play_Animation = BP_UnknowPass_Can_Play_Animation
	
    LuaClassObj.HandleDynamicCreation(bp_unknow_pass_buy);
    LuaClassObj.HandleUIMessage(bp_unknow_pass_buy, "UIShow");
    UIManager.Show(eUIType.eUnknowPassBuyUI);

    --log_tree("BP_STRUCT_UnknowPass_Elite_Pass_Info", BP_STRUCT_UnknowPass_Elite_Pass_Info);
    --log_tree("BP_STRUCT_UnknowPass_Ordinary_Pass_Info", BP_STRUCT_UnknowPass_Ordinary_Pass_Info);
    EventSystem:registEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_SYNC, UnknowPassBuy.OnTeamInfoChange);
    -- 购买通行证数据为空，重新拉取购买协议
    if 0 == BP_STRUCT_UnknowPass_Elite_Pass_Info.price or 0 == BP_STRUCT_UnknowPass_Ordinary_Pass_Info.price then
        UnknowPassSystem.upass_buy_pass_list_req()
    end
end

function UnknowPassBuy.HideUI()
    UnknowPassBuy.IsUIShow = false;
    UIManager.Hide(eUIType.eUnknowPassBuyUI);
    LuaClassObj.HandleUIMessage(bp_unknow_pass_buy, "UIHide");
    EventSystem:unregistEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_SYNC, UnknowPassBuy.OnTeamInfoChange);
end

-- 更新购买信息
function UnknowPassBuy.OnUpdateBuyData(tb)
    for k,v in pairs(tb) do
        local info = {
            id = k,
            price = v.ori_price,
            discountPrice = v.discount_price,
            desc1 = v.reward_desc1,
            desc2 = v.reward_desc2,
            expireTips = v.expire_tips or "",
        }
        if v.buy_type == 1 then
            BP_STRUCT_UnknowPass_Ordinary_Pass_Info = info;
        elseif v.buy_type == 2 then
            BP_STRUCT_UnknowPass_Elite_Pass_Info = info;
            if #v.reward > 0 then
                BP_UnknowPass_Buy_Elite_Award_Item_Id = v.reward[1].item_id;
                BP_UnknowPass_Buy_Elite_Award_Item_Num = v.reward[1].item_num;
            end
        end
    end
end

function UnknowPassBuy.OnTeamInfoChange(eventType, eventID, vars)
    log("[yyc] UnknowPassBuy.OnTeamInfoChange");
    if UnknowPassBuy.IsUIShow then
        log("[yyc] UnknowPassBuy.IsUIShow");
        --UnknowPassBuy.HideUI();
    end
end

-- game event
function UnknowPassBuy.OnJumpUrl()
    UnknowPassBuy.ShowUI();
end

function UnknowPassBuy.OnInfoUpdate(evenType, eventID)
    BP_UnknowPass_Buy_Season_Index = UnknowPassSystem.Data.season_info.index;
end

-- bp event
function EventUnknowPassBuyCloseClick_Push()
	UnknowPassBuy.HideUI()
end

-- 赛季结束前一周，提示通行证即将过期
function UnknowPassBuy.IsPassNearExpire()
    local seasonEndTime = UnknowPassSystem.SeasonInfo.cfg.end_timestamp;
    return seasonEndTime - FuncUtil.GetServerTimeInSec() < 7 * 24 * 3600;
end

function UnknowPassBuy.GetBuyPassString(passNameId, price)
    local tip = string.gsub(FuncUtil.GetLocalizeResStr("301372"), "\'", "\"");
    local strUPass = FuncUtil.GetLocalizeResStr(passNameId);
    tip = string.gsub(tip, "{0}", price)
    tip = string.gsub(tip, "{1}", strUPass)
    return tip
end

function UnknowPassBuy.CheckBuyNormalPass()
    UnknowPassSystem.upass_buy_pass_req(BP_STRUCT_UnknowPass_Ordinary_Pass_Info.id);
end

function UnknowPassBuy.CheckBuySuperPass()
    UnknowPassSystem.upass_buy_pass_req(BP_STRUCT_UnknowPass_Elite_Pass_Info.id);
end

function EventNormalPassClick_Push()
    log("EventNormalPassClick_Push");
    local buyString = UnknowPassBuy.GetBuyPassString("4547", BP_STRUCT_UnknowPass_Ordinary_Pass_Info.price);
    if UnknowPassBuy.IsPassNearExpire() then
        buyString = string.format("%s\n\n\n%s", buyString, BP_STRUCT_UnknowPass_Ordinary_Pass_Info.expireTips);
    end
    CommonMessageBoxUI:ShowPanel(
        2,
        FuncUtil.GetLocalizeResStr("301185"),
        buyString, 
        UnknowPassBuy.CheckBuyNormalPass);
end

function EventSuperPassClick_Push()
    log("EventSuperPassClick_Push");
    local buyString = UnknowPassBuy.GetBuyPassString("502507", BP_STRUCT_UnknowPass_Elite_Pass_Info.discountPrice);
    if UnknowPassBuy.IsPassNearExpire() then
        buyString = string.format("%s\n\n\n%s", buyString, BP_STRUCT_UnknowPass_Elite_Pass_Info.expireTips);
    end
    CommonMessageBoxUI:ShowPanel(
        2,
        FuncUtil.GetLocalizeResStr("301185"),
        buyString,
        UnknowPassBuy.CheckBuySuperPass);
end

function EventUnknowPassRule1Click()
    log("EventUnknowPassRule1Click");
    local title = Client.GetTableData("LocalizeRes", 502507).TextValue

    local info = Client.GetTableData("UnknowPassBuyCfg", BP_STRUCT_UnknowPass_Elite_Pass_Info.id)

    local content = info.Desc1 .. "\n\n" .. info.Desc2
    PopUpNoticeUI.ShowMessageBox(title, content);
end

function EventUnknowPassRule2Click()
    log("EventUnknowPassRule2Click");
    local title = Client.GetTableData("LocalizeRes", 502508).TextValue

    local info = Client.GetTableData("UnknowPassBuyCfg", BP_STRUCT_UnknowPass_Ordinary_Pass_Info.id)


    local content = info.Desc1 .. "\n\n" .. info.Desc2

    --local content = BP_STRUCT_UnknowPass_Ordinary_Pass_Info.desc1 .. "\n\n" .. BP_STRUCT_UnknowPass_Ordinary_Pass_Info.desc2
    PopUpNoticeUI.ShowMessageBox(title, content);
end