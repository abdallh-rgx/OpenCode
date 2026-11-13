MallRecommendUI = MallRecommendUI or {}
MallRecommendUI.DropList = {} --掉落列表数据
MallRecommendUI.isShowing = false
MallRecommendUI.isPosterShowing = false
MallRecommendUI.SelectItemID = 0

MallRecommendUI.PAGE_SHOWTYPE_BANNER = 1
MallRecommendUI.PAGE_SHOWTYPE_BOX = 2
MallRecommendUI.PAGE_SHOWTYPE_ITEM = 3

MallRecommendUI.SHOW_TYPE_PLAYER = 0
MallRecommendUI.SHOW_TYPE_MODEL = 1
MallRecommendUI.showType = MallRecommendUI.SHOW_TYPE_PLAYER

MallRecommendUI.BTN_TYPE_WEAPON = 0
MallRecommendUI.BTN_TYPE_ACTION = 1
MallRecommendUI.BTN_TYPE_POSTER = 2
MallRecommendUI.BTN_TYPE_SEX = 3
MallRecommendUI.BTN_TYPE_SEX_OLD = 4

BP_MallRecommendUI_Btn_Type = 0

BP_MallRecommendUI_Jump_Url = ""
BP_MallRecommendUI_Icon_Name = ""
BP_MallRecommendUI_PosterURL = ""
BP_MallRecommendUI_SceneMatId = 7
BP_MallRecommendUI_SceneImgUrl = ""

BP_ARRAY_MallRecommendUI_BannerDataList = {
    tmp_UseExist_BP_STRUCT_MallSale_ItemInfo = {}
}

--宝箱信息
BP_ARRAY_MallRecommendUI_Store_Box_ItemList = {
    tmp_UseExist_BP_STRUCT_StoreBox_ItemInfo = {}
}

--宝箱URl
BP_MallRecommendUI_BoxURL = ""

--宝箱中物品列表
BP_ARRAY_MallRecommendUI_Store_Box_DropList = {
    tmp_UseExist_BP_STRUCT_Store_DropInfo = {}
}

--要开启的宝箱ID
BP_MallRecommendUI_Store_Box_Buy_Item_ID = -1; --如果为0的话，表示是版本不兼容的

-- 当前拥有的炸猪令牌数量
BP_MallRecommendUI_Store_FP_TOKEN_NUM = 0;

--热卖物品
BP_ARRAY_MallRecommendUI_Hot_Store_Item_List =
{
    tmp_UseExist_BP_STRUCT_Store_Item_Info = {}
};

--新品
BP_ARRAY_MallRecommendUI_New_Store_Item_List =
{
    tmp_UseExist_BP_STRUCT_Store_Item_Info = {}
};

BP_MallRecommendUI_SelectItemIndex = 0

BP_MallRecommendUI_SelectItemID = 0

BP_MallRecommendUI_SelectItem_IsCanSend = false

BP_MallRecommendUI_SelectItem_Sell_Type = 0

BP_MallRecommendUI_SelectItem_Sell_Price = 0

BP_MallRecommendUI_SelectItem_Limit_Num = 0

BP_MallRecommendUI_Cur_Select_Item_Weared = false

BP_MallRecommendUI_SelectItem_From = 0 -- 0 表示来自于宝箱，1 表示来自于热卖 2 表示来自于新品

BP_MallRecommendUI_Is_Show_Box_Content = false

BP_MallRecommendUI_DEFAULT_PREVIEW_SEX = 0

function bp_mall_recommend_RegisterUI()
    log("MallRecommendUI bp_mall_recommend_RegisterUI -------------")

    LuaClassObj.SubUIWidgetList(bp_mall_recommend,
                                {{Path="/Game/UMG/UI_Logic/Lobby_Store/Store_2/Mall_Recommend_LogicBP.Mall_Recommend_LogicBP_C", Container="Default", ZOrder=BP_ENUM_UI_SHOP_ZORDER}},
                                {"Lobby"},
                                false,
                                false,
                                true
    )
end



function MallRecommendUI.Init()
    log("MallRecommendUI Init -------------")

end

function MallRecommendUI.Show()
    log("MallRecommendUI Show -------------")
    MallRecommendUI.isShowing = true
    LuaClassObj.HandleDynamicCreation(bp_mall_recommend)

    MallRecommendUI.ResetData()

    LuaClassObj.HandleUIMessageNoFetch(bp_mall_recommend, "UIShow")

    LuaClassObj.HandleUIMessageNoFetch(bp_mall_recommend, "ShowSelectItemInfo")

    MallRecommendUI._hideBtn(MallRecommendUI.BTN_TYPE_WEAPON)
    MallRecommendUI._hideBtn(MallRecommendUI.BTN_TYPE_ACTION)
    MallRecommendUI._hideBtn(MallRecommendUI.BTN_TYPE_POSTER)
    MallRecommendUI._hideBtn(MallRecommendUI.BTN_TYPE_SEX)
    MallRecommendUI._hideBtn(MallRecommendUI.BTN_TYPE_SEX_OLD)

    MallRecommendUI.showType = MallRecommendUI.SHOW_TYPE_PLAYER
    MallSystemUI_2.SwitchWeaponShowType(MallRecommendUI.showType)

    MallSystemUI_2.HideSex()
    MallSystemUI_2.ForceRevertAvatar()
    MallSystemUI_2.SetAvatarX(MallSystemUI_2.MALL_RECOMMEND_AVATAR_X)
    MallSystemUI_2.StopEmoteAction()

    MallRecommendUI._hidePoster()

    MallRecommendUI.HideBoxItems()


    EventSystem:registEvent(EVENTTYPE_SHOP, EVENTID_SHOP_ITEM_CONTENT, MallRecommendUI.ShopItemContentEventHandler);
    MallSystem.igame_market_get_banner_show_req()

    MallSystem.Buy_Source = 1

    EventSystem:registEvent(EVENTTYPE_SHOP, EVENTID_SHOP_PRICE_UPDATE, MallRecommendUI.ShopItemPriceUpdate);
    EventSystem:registEvent(EVENTTYPE_SHOP, EVENTID_SHOP_ITEM_KEY_UPDATE, MallRecommendUI.ShopKeyItemUpdate);

    EventSystem:registEvent(EVENTTYPE_MALL, EVENTID_MALL_BUY_INFO_CHANGE, MallRecommendUI.DynamicUpdate);
    EventSystem:registEvent(EVENTTYPE_MALL, EVENTID_MALL_BUY_RESULT, MallRecommendUI.DynamicUpdate);

    MallSystemUI_2.SetItemBGFillPosVisible(true)

    MallSystemUI_2.HideEquipDescript();
    -- MallRecommendUI._switchScene(BP_MallRecommendUI_SceneMatId)
    LuaClassObj.HandleUIMessageNoFetch(bp_mall_recommend, "UseRecommendCamera")
end

function MallRecommendUI.ShowRoot(isShow)
    if isShow then
        LuaClassObj.HandleUIMessageNoFetch(bp_mall_recommend, "ShowRoot")
    else
        LuaClassObj.HandleUIMessageNoFetch(bp_mall_recommend, "HideRoot")
    end
end

function MallRecommendUI.ResetData()
    BP_MallRecommendUI_DEFAULT_PREVIEW_SEX = DataMgr.avatarData.gamegender
    MallSystemUI_2.SwitchPlayerSex(BP_MallRecommendUI_DEFAULT_PREVIEW_SEX)
    LuaClassObj.HandleUIMessageNoFetch(bp_mall_recommend, "UpdateSexButton")

    BP_ARRAY_MallRecommendUI_Store_Box_ItemList = {}
    BP_ARRAY_MallRecommendUI_Store_Box_DropList = {}
    --要开启的宝箱ID
    BP_MallRecommendUI_Store_Box_Buy_Item_ID = -1;

    -- 当前拥有的炸猪令牌数量
    BP_MallRecommendUI_Store_FP_TOKEN_NUM = 0;

    --热卖物品
    BP_ARRAY_MallRecommendUI_Hot_Store_Item_List = {}

    --新品
    BP_ARRAY_MallRecommendUI_New_Store_Item_List = {}

    BP_MallRecommendUI_SelectItemIndex = 0

    BP_MallRecommendUI_SelectItemID = 0

    BP_MallRecommendUI_Cur_Select_Item_Weared = false

    BP_MallRecommendUI_SelectItem_Limit_Num = 1000000
end

function MallRecommendUI.Hide()
    log("MallRecommendUI Hide")
    EventSystem:unregistEvent(EVENTTYPE_SHOP, EVENTID_SHOP_ITEM_CONTENT, MallRecommendUI.ShopItemContentEventHandler);
    LuaClassObj.HandleUIMessageNoFetch(bp_mall_recommend, "UIHide")
    MallRecommendUI._switchScene(3)
    MallRecommendUI.showType = MallRecommendUI.SHOW_TYPE_PLAYER
    MallSystemUI_2.SwitchWeaponShowType(MallRecommendUI.showType)

    MallRecommendUI.isShowing = false
    BP_MallWeapon_Cur_Show_Extra_X_Offset = 0

    MallSystemUI_2.SetAvatarX(MallSystemUI_2.MALL_DEFAULT_AVATAR_X)

    MallSystem.Buy_Source = 2

    EventSystem:unregistEvent(EVENTTYPE_SHOP, EVENTID_SHOP_PRICE_UPDATE, MallRecommendUI.ShopItemPriceUpdate);
    EventSystem:unregistEvent(EVENTTYPE_SHOP, EVENTID_SHOP_ITEM_KEY_UPDATE, MallRecommendUI.ShopKeyItemUpdate);

    EventSystem:unregistEvent(EVENTTYPE_MALL, EVENTID_MALL_BUY_INFO_CHANGE, MallRecommendUI.DynamicUpdate);
    EventSystem:unregistEvent(EVENTTYPE_MALL, EVENTID_MALL_BUY_RESULT, MallRecommendUI.DynamicUpdate);

    MallSystemUI_2.SetItemBGFillPosVisible(false)

    LuaClassObj.HandleUIMessageNoFetch(bp_mall_recommend, "UseMallCamera")
end

function MallRecommendUI.ShopItemPriceUpdate()
    log("MallRecommendUI.ShopItemPriceUpdate")
    --MallRecommendUI.Hide()
    MallRecommendUI._updateBox()
end

function MallRecommendUI.ShopKeyItemUpdate()
    log("MallRecommendUI.ShopKeyItemUpdate")
    --MallRecommendUI.Hide()
    MallRecommendUI._updateBox()
end

function MallRecommendUI.Release()
    log("MallRecommendUI.Release")
    --MallRecommendUI.Hide()
end

function MallRecommendUI.ShopItemContentEventHandler(eventType, eventID, data)
    log("MallRecommendUI.ShopItemContentEventHandler");
    local id = data[1];
    if (ShopSystem.ItemInfoList[id] == nil) then
        return;
    end

    MallRecommendUI.DropList[id] = data[2];
    log("MallRecommendUI_Box_Buy_Item_ID" .. BP_MallRecommendUI_Store_Box_Buy_Item_ID);
    if (BP_MallRecommendUI_Store_Box_Buy_Item_ID ~= id) then
        return;
    end

    local list = data[2];
    BP_ARRAY_MallRecommendUI_Store_Box_DropList = {}
    StoreBox_UI.Init_Store_Box_DropList(BP_ARRAY_MallRecommendUI_Store_Box_DropList, list)

    BP_MallRecommendUI_Is_Show_Box_Content = true

    LuaClassObj.HandleUIMessageNoFetch(bp_mall_recommend, "ShowBoxItems")
end

function MallRecommendUI.onPacketRespone()
    MallRecommendUI._updateBanner()
    MallRecommendUI._updateItems()
    MallRecommendUI._updateBox()
    LuaClassObj.HandleUIMessageNoFetch(bp_mall_recommend, "RefreshBoxOrItemsVisible")

    log_tree("MallSystem.recommendPosterInfo",MallSystem.recommendPosterInfo,"")
    if BP_MallRecommendUI_SceneImgUrl and BP_MallRecommendUI_SceneImgUrl ~= nil then
        MallRecommendUI._loadSceneFromCDN(BP_MallRecommendUI_SceneImgUrl)
    else
        MallRecommendUI._switchScene(BP_MallRecommendUI_SceneMatId)
    end

    if MallSystem.recommendCurrentShowType == MallRecommendUI.PAGE_SHOWTYPE_BOX then

        if MallSystem.recommendPosterInfo.img_path ~= nil and MallSystem.recommendPosterInfo.img_path ~= "" then
            MallRecommendUI._showBtn(MallRecommendUI.BTN_TYPE_POSTER)
            MallRecommendUI._updatePoster()
        end

        MallRecommendUI._showDefaultItems()
        return
    end

    -- BP_MallRecommendUI_PosterURL = "http://www.pubgmobile.com/event/pics/banner/banner12.png"
    -- LuaClassObj.HandleUIMessageNoFetch(bp_mall_recommend, "UpdatePoster")
end


function MallRecommendUI.DynamicUpdate(eventType, eventID, vars)
    log("MallRecommendUI.DynamicUpdate");
    MallRecommendUI._updateItems()
end

function MallRecommendUI._switchScene(id)
    log("BP_MallRecommendUI_SceneMatId"..BP_MallRecommendUI_SceneMatId)
    log(" MallRecommendUI._switchScene "..id)
    BP_MallRecommendUI_SceneMatId = id
    LuaClassObj.HandleUIMessageNoFetch(bp_mall_recommend, "UpdateScene")
end

function MallRecommendUI._loadSceneFromCDN(url)
    log(" MallRecommendUI._loadSceneFromCDN " .. url)
    BP_MallRecommendUI_SceneImgUrl = url
    LuaClassObj.HandleUIMessageNoFetch(bp_mall_recommend, "UpdateSceneFromCDN")
end

function MallRecommendUI._updatePoster()
    BP_MallRecommendUI_PosterURL = MallSystem.recommendPosterInfo.img_path
    log("BP_MallRecommendUI_PosterURL "..BP_MallRecommendUI_PosterURL)
    LuaClassObj.HandleUIMessageNoFetch(bp_mall_recommend, "UpdatePoster")
end

function MallRecommendUI._updateBox()
    --更新道具数量
    BP_MallRecommendUI_Store_Box_Buy_Item_ID = MallSystem.recommendBoxMainInfo.shop_id or -1

    log("MallRecommendUI._updateBox "..BP_MallRecommendUI_Store_Box_Buy_Item_ID)

    BP_MallRecommendUI_Store_FP_TOKEN_NUM = DataMgr.fp_token;
    BP_ARRAY_MallRecommendUI_Store_Box_ItemList = {}
    local InfoList = ShopSystem.ItemInfoList[BP_MallRecommendUI_Store_Box_Buy_Item_ID]
    if InfoList then
        InfoList.have_item_number = 0;
        if (InfoList.key_item_id > 0) then
            --v.have_item_number = DataMgr.GetHallDepotItemDataByInsID(v.key_item_id);
            --log("mickey:" .. v.have_item_number);
            local itemData = DataMgr.GetHallDepotItemDataByResID(InfoList.key_item_id);
            if (itemData ~= nil) then
                InfoList.have_item_number = itemData.count;
            end
        end

        --设置宝箱
        table.insert(BP_ARRAY_MallRecommendUI_Store_Box_ItemList, InfoList)
    end
    BP_MallRecommendUI_BoxURL = MallSystem.recommendBoxMainInfo.icon_name or ""
    LuaClassObj.HandleUIMessageNoFetch(bp_mall_recommend, "UpdateBox")
end

function MallRecommendUI._updateItems()
    --热卖

    BP_ARRAY_MallRecommendUI_Hot_Store_Item_List = {}
    if MallSystem.recommendItemsInfo.hot_market_id then
        for index, id in ipairs(MallSystem.recommendItemsInfo.hot_market_id) do
            local marketInfo = MallSystem.recommendItemsInfo.market_list[tonumber(id)]
            if marketInfo then
                local data = MallSystemUI_2.MarketData2ItemData(marketInfo);
                table.insert(BP_ARRAY_MallRecommendUI_Hot_Store_Item_List, data)
            end
        end
    end

    log_tree("BP_ARRAY_MallRecommendUI_Hot_Store_Item_List:", BP_ARRAY_MallRecommendUI_Hot_Store_Item_List)
    --新品
    BP_ARRAY_MallRecommendUI_New_Store_Item_List = {}
    if MallSystem.recommendItemsInfo.new_market_id then
        for index, id in ipairs(MallSystem.recommendItemsInfo.new_market_id) do
            local marketInfo = MallSystem.recommendItemsInfo.market_list[tonumber(id)]
            if marketInfo then
                local data = MallSystemUI_2.MarketData2ItemData(marketInfo);
                table.insert(BP_ARRAY_MallRecommendUI_New_Store_Item_List, data)
            end
        end
    end

    log_tree("BP_ARRAY_MallRecommendUI_New_Store_Item_List:", BP_ARRAY_MallRecommendUI_New_Store_Item_List)

    if BP_MallRecommendUI_SelectItemID == 0 then
        if #BP_ARRAY_MallRecommendUI_New_Store_Item_List > 0 then
            BP_MallRecommendUI_SelectItemIndex = 0
            BP_MallRecommendUI_SelectItem_From = 2
            BP_MallRecommendUI_SelectItemID = BP_ARRAY_MallRecommendUI_New_Store_Item_List[BP_MallRecommendUI_SelectItemIndex + 1].itemID
        elseif #BP_ARRAY_MallRecommendUI_Hot_Store_Item_List > 0 then
            BP_MallRecommendUI_SelectItemIndex = 0
            BP_MallRecommendUI_SelectItem_From = 1
            BP_MallRecommendUI_SelectItemID = BP_ARRAY_MallRecommendUI_Hot_Store_Item_List[BP_MallRecommendUI_SelectItemIndex + 1].itemID
        end
    end

    if BP_MallRecommendUI_SelectItemID > 0 then

        LuaClassObj.HandleUIMessageNoFetch(bp_mall_recommend, "SelectFirstHotOrNewItem")
        --LuaClassObj.HandleUIMessageNoFetch(bp_mall_recommend, "ShowSelectItemInfo")
        EventMallRecommendClickSingleItem()
    end

    LuaClassObj.HandleUIMessageNoFetch(bp_mall_recommend, "UpdateItems")
end

function MallRecommendUI._updateBanner()
    BP_ARRAY_MallRecommendUI_BannerDataList = {}

    for index, value in ipairs(MallSystem.recommendBannerInfo) do
        table.insert(BP_ARRAY_MallRecommendUI_BannerDataList, value)
    end

    LuaClassObj.HandleUIMessageNoFetch(bp_mall_recommend, "UpdateBanner")
end

function MallRecommendUI._showDefaultItems()
    MallSystemUI_2.ShowItemList(MallSystem.recommendBoxInfo.preview_items, MallSystem.recommendBoxInfo.gender)

    if (MallSystem.recommendBoxInfo.act ~= nil and MallSystem.recommendBoxInfo.act ~= 0) then
        MallSystemUI_2.ShowItem(MallSystem.recommendBoxInfo.act, MallSystem.recommendBoxInfo.gender)
        MallSystemUI_2.DisableRoleRotate()
    end
end

function MallRecommendUI._showBtn(btnType)
    BP_MallRecommendUI_Btn_Type = btnType
    LuaClassObj.HandleUIMessageNoFetch(bp_mall_recommend, "ShowBtnByType")
end

function MallRecommendUI._hideBtn(btnType)
    BP_MallRecommendUI_Btn_Type = btnType
    LuaClassObj.HandleUIMessageNoFetch(bp_mall_recommend, "HideBtnByType")
end

function MallRecommendUI._showPoster()
    MallRecommendUI.isPosterShowing = true
    LuaClassObj.HandleUIMessageNoFetch(bp_mall_recommend, "ShowPoster")
    ClientSendBAReport(BP_BA_MALL_RECOMMEND_SHOW_POSTER)

    -- if MallRecommendUI.showType == MallRecommendUI.SHOW_TYPE_PLAYER then
    --     LuaClassObj.HandleUIMessage(bp_mall_system_2, "HideAllPlayer")
    -- end
end

function MallRecommendUI._hidePoster()
    MallRecommendUI.isPosterShowing = false
    LuaClassObj.HandleUIMessageNoFetch(bp_mall_recommend, "HidePoster")
    -- if MallRecommendUI.showType == MallRecommendUI.SHOW_TYPE_PLAYER then
    --     LuaClassObj.HandleUIMessage(bp_mall_system_2, "ShowCurrentPlayer")
    -- end
end


-- 当前物品是否有装备
function MallRecommendUI.IsWear(itemId)
    return MallSystemUI_2:IsWear(itemId)
end

function MallRecommendUI.CheckWeaponShow()
    log("MallRecommendUI CheckWeaponShow -------------")
    local itemDataCfg = Client.GetTableData("Item", BP_MallRecommendUI_SelectItemID)
    if itemDataCfg ~= nil  then

        log("MallRecommendUI CheckWeaponShow -------------:" .. itemDataCfg.ItemType)
        if itemDataCfg.ItemType == 1 then
            MallRecommendUI._showBtn(MallRecommendUI.BTN_TYPE_WEAPON)
        else
            MallRecommendUI._hideBtn(MallRecommendUI.BTN_TYPE_WEAPON)
        end
    end
end

function EventMallRecomendClickSex()
    log("MallRecommendUI EventMallRecomendClickSex -------------")
    if BP_MallRecommendUI_DEFAULT_PREVIEW_SEX == 1 then
        BP_MallRecommendUI_DEFAULT_PREVIEW_SEX = 2
    else
        BP_MallRecommendUI_DEFAULT_PREVIEW_SEX = 1
    end

    LuaClassObj.HandleUIMessageNoFetch(bp_mall_recommend, "UpdateSexButton")
    EventSwitchPlayerSex()
end

function EventMallRecomendClickPoster()
    -- MallSystemUI_2.ShowItem(1400554)

    log("MallRecommendUI EventMallRecomendClickPoster -------------")
    if MallRecommendUI.isPosterShowing == true then
        MallRecommendUI._hidePoster()
    else
        MallRecommendUI._showPoster()
    end
end

function EventMallRecomendClickWeapon()
    log("MallRecommendUI EventMallRecomendClickWeapon -------------")
    if (MallRecommendUI.showType == MallRecommendUI.SHOW_TYPE_PLAYER) then
        MallRecommendUI.showType = MallRecommendUI.SHOW_TYPE_MODEL
    else
        MallRecommendUI.showType = MallRecommendUI.SHOW_TYPE_PLAYER
    end

    MallSystemUI_2.SwitchWeaponShowType(MallRecommendUI.showType)
end

function EventMallRecomendClickAction()
    log("MallRecommendUI EventMallRecomendClickAction -------------")
    if os.time() - MallSystemUI_2.nLastPlayEmotionTime < 5 then
        ShowNotice(120178)
        return
    end

    MallSystemUI_2.nLastPlayEmotionTime = os.time()
    EventMallRecommendStartPlayRedEmtion()
end

function EventMallRecommendStartPlayRedEmtion()
    local itemId = MallRecommendUI.SelectItemID
    local cfg = Client.GetTableData("Item", itemId)
    if cfg == nil or cfg.RedEmotionId == 0 or cfg.RedEmotionPlayCD <= 0 then
        return
    end

    EventMallSystemStopPlayRedEmtion()
    if MallSystemUI_2:IsWear(itemId) then
        MallSystemUI_2.DoEmoteAction(cfg.RedEmotionId)
    end

    MallSystemUI_2.nPlayEmotionTimerId = Timer.InsertTimer(cfg.RedEmotionPlayCD, function()
        EventMallRecomendClickAction()
    end, true, false)
end

function EventMallRecommendStopPlayRedEmtion()
    EventMallSystemStopPlayRedEmtion()
end

BP_MallRecommendUI_Jump_Url = ""
BP_MallRecommendUI_Icon_Name = ""

function EventMallRecommendClickItem()
    log("MallRecommendUI BP_MallRecommendUI_Jump_Url "..BP_MallRecommendUI_Jump_Url)
    log("MallRecommendUI BP_MallRecommendUI_Icon_Name "..BP_MallRecommendUI_Icon_Name)

    if BP_MallRecommendUI_Jump_Url ~= "" then
        local str = string.split(BP_MallRecommendUI_Icon_Name, "/");
        local pngName = tostring(str[#str]);
        ClientSendBAReport(BP_BA_STORE_SALE_ITEM, 0, pngName);

        GlobalData:JumpUrl(BP_MallRecommendUI_Jump_Url);
    end
end

function EventMallRecommendBuyStoreBox()
    log("EventMallRecommendBuyStoreBox:"..BP_MallRecommendUI_Store_Box_Buy_Item_ID)
    StoreBox_UI.RequestBuyStoreBox(BP_MallRecommendUI_Store_Box_Buy_Item_ID)
end

function EventMallRecommendBuyTenStoreBox()
    StoreBox_UI.RequestBuyTenStoreBox(BP_MallRecommendUI_Store_Box_Buy_Item_ID)
end

function EventMallRecommendBuyItem()
    log("EventMallRecommendBuyItem:"..BP_MallRecommendUI_SelectItemID)
    --log_tree("market_list", MallSystem.recommendItemsInfo.market_list)

    if MallSystem.recommendItemsInfo.itemId2ShopId then
        local shopID = MallSystem.recommendItemsInfo.itemId2ShopId[BP_MallRecommendUI_SelectItemID]
        local marketInfo = MallSystem.recommendItemsInfo.market_list[shopID]

        MallSystemUI_2.OpenBuySingleItemWin(BP_MallRecommendUI_SelectItemID, nil, nil, marketInfo, MallSystem.recommendMarketVersion);
    end
end

--点击了显示宝箱详情
function EventMallRecommendShowBoxContent()
    if MallRecommendUI.DropList[BP_MallRecommendUI_Store_Box_Buy_Item_ID]  then
        MallRecommendUI.ShopItemContentEventHandler(nil, nil, {BP_MallRecommendUI_Store_Box_Buy_Item_ID, MallRecommendUI.DropList[BP_MallRecommendUI_Store_Box_Buy_Item_ID]});
    else
        ShopSystem.shop_item_content_req(BP_MallRecommendUI_Store_Box_Buy_Item_ID);
    end
end

function MallRecommendUI.HideBoxItems()
    BP_MallRecommendUI_SelectItemIndex = 0
    BP_MallRecommendUI_SelectItemID = 0
    BP_MallRecommendUI_Is_Show_Box_Content = false
    LuaClassObj.HandleUIMessageNoFetch(bp_mall_recommend, "ShowSelectItemInfo")
    LuaClassObj.HandleUIMessageNoFetch(bp_mall_recommend, "HideBoxItems")
end

--点击了隐藏宝箱详情
function EventMallRecommendHideBoxContent()
    MallRecommendUI.HideBoxItems()
end

--显示概率详情
function EventMallRecommendShowRate()
    local data = ShopSystem.ItemInfoList[BP_MallRecommendUI_Store_Box_Buy_Item_ID];
    if (data == nil) then
        return;
    end

    if #data.drop_rate > 0 then
        Rate_Panel_UI.Show(data.drop_rate);
    end
end



function EventMallRecommendClickBoxItem()
    log("EventMallRecommendClickBoxItem:" .. BP_MallRecommendUI_SelectItemID ..
                ", BP_MallRecommendUI_SelectItem_From:" .. BP_MallRecommendUI_SelectItem_From ..
                ",BP_MallRecommendUI_SelectItemIndex:" .. BP_MallRecommendUI_SelectItemIndex);
    local _,showSex = MallSystemUI_2.ShowItem(BP_MallRecommendUI_SelectItemID);
    BP_MallRecommendUI_SelectItem_Limit_Num = 1000000
    BP_MallRecommendUI_Cur_Select_Item_Weared = MallSystemUI_2:IsWear(BP_MallRecommendUI_SelectItemID)

    MallRecommendUI.SelectItemID = BP_MallRecommendUI_SelectItemID

    LuaClassObj.HandleUIMessageNoFetch(bp_mall_recommend, "ShowSelectItemInfo")

    MallRecommendUI.CheckWeaponShow()

    if showSex == true then
        MallRecommendUI._showBtn(MallRecommendUI.BTN_TYPE_SEX_OLD)
    else
        MallRecommendUI._hideBtn(MallRecommendUI.BTN_TYPE_SEX_OLD)
    end
end

function EventMallRecommendClickSingleItem()
    log("EventMallRecommendClickSingleItem:" .. BP_MallRecommendUI_SelectItemID ..
                ", BP_MallRecommendUI_SelectItem_From:" .. BP_MallRecommendUI_SelectItem_From ..
                ",BP_MallRecommendUI_SelectItemIndex:" .. BP_MallRecommendUI_SelectItemIndex);
    local storeInfo
    if BP_MallRecommendUI_SelectItem_From == 1 then
        storeInfo = BP_ARRAY_MallRecommendUI_Hot_Store_Item_List[BP_MallRecommendUI_SelectItemIndex + 1]
    end

    if BP_MallRecommendUI_SelectItem_From == 2 then
        storeInfo = BP_ARRAY_MallRecommendUI_New_Store_Item_List[BP_MallRecommendUI_SelectItemIndex + 1]
    end

    log_tree("", BP_ARRAY_MallRecommendUI_New_Store_Item_List)

    if storeInfo == nil then
        log("EventMallRecommendClickSingleItem：storeInfo == nil")
        return
    end
    --
    --local resItem = Client.GetTableData("Item",storeInfo.item_id);
    --if resItem == nil then
    --    log("EventMallRecommendClickSingleItem,no resItem");
    --    return;
    --end

    local _,showSex = MallSystemUI_2.ShowItem(BP_MallRecommendUI_SelectItemID);

    MallRecommendUI.SelectItemID = BP_MallRecommendUI_SelectItemID

    BP_MallRecommendUI_SelectItem_Limit_Num = storeInfo.limitCount;
    BP_MallRecommendUI_SelectItem_IsCanSend = storeInfo.isCanSend;
    --BP_Mall_Cur_Select_SHOP_IsSellOut = storeInfo.limitCount <= 0;
    BP_MallRecommendUI_SelectItem_Sell_Type = storeInfo.moneyType;
    BP_MallRecommendUI_SelectItem_Sell_Price = storeInfo.moneyPrice;
    BP_MallRecommendUI_Cur_Select_Item_Weared = MallSystemUI_2:IsWear(BP_MallRecommendUI_SelectItemID)

    LuaClassObj.HandleUIMessageNoFetch(bp_mall_recommend, "ShowSelectItemInfo")

    MallRecommendUI.CheckWeaponShow()

    if showSex == true then
        MallRecommendUI._showBtn(MallRecommendUI.BTN_TYPE_SEX_OLD)
    else
        MallRecommendUI._hideBtn(MallRecommendUI.BTN_TYPE_SEX_OLD)
    end
end
--赠送礼物
function EventMallRecommendSendItem()
    log("MallRecommendUI EventMallRecommendSendItem,".. tostring(BP_MallRecommendUI_SelectItemIndex) .. tostring(BP_MallRecommendUI_SelectItemID))

    if MallSystem.recommendItemsInfo.itemId2ShopId then
        --local shopID = MallSystem.recommendItemsInfo.itemId2ShopId[BP_MallRecommendUI_SelectItemID]
        --MallSystemUI_2.MallSendShopItem
        local shopID = MallSystem.recommendItemsInfo.itemId2ShopId[BP_MallRecommendUI_SelectItemID]
        local marketInfo = MallSystem.recommendItemsInfo.market_list[shopID]

        MallSystemUI_2.MallSendShopItem(shopID, nil, nil, marketInfo);
    end
end

