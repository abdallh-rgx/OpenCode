-- 商城货币类型选择界面
StorePriceSelect_UI = StorePriceSelect_UI or {
    boxId = 0,
    boxInfo = {},
    isTen = false,
};

BP_StorePrice_Select_Type = 0;
BP_StoreSelPrice_TICKET = 0; --uc价格
BP_StoreSelPrice_FP_TOKEN = 0; --炸猪令牌价格

--注册Widget
function bp_store_price_select_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_store_price_select,
        {{Path = "/Game/UMG/UI_BP/Lobby_Store_Int/Store_2/Store_PriceType_UIBP.Store_PriceType_UIBP_C", Container = "Default", ZOrder = BP_ENUM_UI_SHOP_ZORDER + 1}},
        {"Lobby"},
        false,
        false,
        true
    );
end

function StorePriceSelect_UI.Show(boxId, ticketPrice, tokenPrice)
    log("[yyc] torePriceSelect_UI.Show")
    StorePriceSelect_UI.boxId = boxId or 0
    BP_StoreSelPrice_TICKET = ticketPrice or 0
    BP_StoreSelPrice_FP_TOKEN = tokenPrice or 0
    LuaClassObj.HandleDynamicCreation(bp_store_price_select)
    LuaClassObj.HandleUIMessage(bp_store_price_select, "ShowUI")
    UIManager.Show(eUIType.eStorePriceSelect)
end

function StorePriceSelect_UI.ShowByInfo(boxInfo, ticketPrice, tokenPrice, isTen)
    log("[edward][bp_store_price_select] StorePriceSelect_UI.ShowByInfo");
    StorePriceSelect_UI.boxInfo = boxInfo;
    BP_StoreSelPrice_TICKET = ticketPrice or 0;
    BP_StoreSelPrice_FP_TOKEN = tokenPrice or 0;
    StorePriceSelect_UI.isTen = isTen or false;
    LuaClassObj.HandleDynamicCreation(bp_store_price_select);
    LuaClassObj.HandleUIMessage(bp_store_price_select, "ShowUI");
    UIManager.Show(eUIType.eStorePriceSelect);
end

function StorePriceSelect_UI.Hide()
    log("[yyc] torePriceSelect_UI.Hide")
    UIManager.Hide(eUIType.eStorePriceSelect)
    LuaClassObj.HandleUIMessage(bp_store_price_select, "HideUI")
end

function EventSelectPriceType_Push()
    log("[yyc] EventSelectPriceType "..tostring(BP_StorePrice_Select_Type))
    --StoreBox_UI.PriceTypeSelect(StorePriceSelect_UI.boxId)

    -- 目前只有单抽
    if StorePriceSelect_UI.isTen then
        SupplyMainUI.RequestBuyTenSupplyBox(StorePriceSelect_UI.boxInfo, true);
    else
        SupplyMainUI.RequestBuySupplyBox(StorePriceSelect_UI.boxInfo, true, BP_StorePrice_Select_Type, true);
    end
end

function EventFetchInfo()
end
