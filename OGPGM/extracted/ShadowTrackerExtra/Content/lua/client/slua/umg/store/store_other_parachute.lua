local Store_Other_Parachute_UI =
{
    itemMap = {},
    priceInfo = nil,
    shopinfo = nil,
    firsttimeclick = false,
    TimerToRefresh = nil,
    left_time_List = {},
    arrayitemlist = {},
    _jumpWaitTag = false,
}

function Store_Other_Parachute_UI:ctor()
    --todo: 这里可以做些数据初始化工作
    log("Store_Other_UI:ctor()")


end

function Store_Other_Parachute_UI:OnInitialize()
    Store_Other_Parachute_UI.__super.OnInitialize(self)
    --todo: 在这里做些初始化工作
    log("Store_Other_UI:OnInitialize")
    self.ScrollGrid = self:InitScrollBox(self.UIRoot.LoopScrollGrid_0);


end

function Store_Other_Parachute_UI:RegistEvents()
    Store_Other_Parachute_UI.__super.RegistEvents(self)
    --todo: 在这里注册事件
    self.ScrollGrid:SetRefreshItemCallback(self.OnRefreshItem, self);
    self.ScrollGrid:AddItemEvent("Store_Fashion_Item_01_UIBP.Button_0", "OnClicked", self.OnClickItem, self);
    self:AddControlEvent("Store_Purchase_Btn.Btn_SinglePrice", "OnClicked", self.OnClickBuyBtn, self);
    self:AddControlEvent("Store_Purchase_Btn.Btn_MultiMoney", "OnClicked", self.OnClickBuyBtn, self);
    self:AddControlEvent("Store_Send_Btn.Button_send", "OnClicked", self.OnClickSendBtn, self);
    self:AddControlEvent("Store_Collection_Btn", "OnClickCollectItem", self.OnClickCollectBtn, self);
    self:AddCommonEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_DATA, self.OnReceivedOtherData, self);
    self:AddCommonEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_COLLECT, self.OnCollectedResult, self);
    self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_DATA_CHANGE, self.OnItemDataChange, self);

end

function Store_Other_Parachute_UI:UnRegistEvents()
    --todo: 在这里反注册事件

    Store_Other_Parachute_UI.__super.UnRegistEvents(self)
end

function Store_Other_Parachute_UI:OnPostInitialize()
    Store_Other_Parachute_UI.__super.OnPostInitialize(self)
    self:OnReceivedOtherData()
    self:ChooseTheFirstOrSpecifiedOne()
    self:SetTickTime()
    --self.firsttimeclick = true
    --self.ScrollGrid:Select(1);
end

function Store_Other_Parachute_UI:OnShow()

end

function Store_Other_Parachute_UI:OnClickItem(widget, index)
    self:PlayAudio(require("client.slua.config.sound").confirm)
    if #self.arrayitemlist > 0 then
        log(" #self.arrayitemlist " .. tostring( #self.arrayitemlist))
        self.ScrollGrid:Select(index);
    end
    for k, v in pairs(self.arrayitemlist) do
        if k == index then
            self.arrayitemlist[k].selected = true;
            --self.arrayitemlist[k].equiped = equiped;
        else
            self.arrayitemlist[k].selected = false;
            --self.arrayitemlist[k].equiped = MultipleAvatar.HasEquiped(v.item_id, 0, 0);
        end
    end


    local itemData = self.ScrollGrid:GetItemData(index);
    if itemData then
        StoreSystem.CheckRecordNewTag(itemData.item_shopID);
        if itemData.item_new then
            itemData.item_new,itemData.item_showSpecialIcon =  StoreFuncUtils.GetItemRightTopTagsQueue(
                    false, --and serverTime - item.item_startTime > StoreFuncUtils.NewFlagAvailableTime,
                    itemData.SpecialIcon ~= "");
        end
        if itemData then
            log("[HHF]Store_Other_Parachute_UI:OnClickItem, index = " .. tostring(index) .. ", itemID = " .. tostring(itemData.item_id));
            local equiped = MultipleAvatar.HasEquiped(itemData.item_id, 0, 0);
            --self.currentDisplayType = self:GetDisplayTypeByItemType(itemData);
            ModelDisplayer.SetShowtype(ModelDisplayer.SHOWTYPE_NONE);
            StoreMainUI.OnSelectedItem(itemData.item_id, 0, 0, false);
            --self.currentDisplayType = self:GetDisplayTypeByItemType(itemData);--ModelDisplayer.GetShowtype();--
            equiped = MultipleAvatar.HasEquiped(itemData.item_id, 0, 0);
            log("[HHF]Store_Other_Parachute_UI:OnClickItem,  after click equiped = " .. tostring(equiped));



            StoreRedDotModel.SetCollectionTabRedDotMap(itemData.item_id);

            self:UpdateDetailInfo(widget, index);
            self:SetShopInfo()
            self:RefreshItemPrice(itemData)
            self.ScrollGrid:RefreshAllItems(self.arrayitemlist)
        end
    end


end

function Store_Other_Parachute_UI:SetTickTime()
    Store_Other_Parachute_UI.TimerToRefresh = Timer.InsertTimer(1, function ()
        for i = 1,  self.ScrollGrid:GetItemCount() do
            local itemData = self.ScrollGrid:GetItemData(i)
            if itemData then
                if itemData.item_leftTime > 0 then
                    log(" itemdata.left_time " .. tostring( itemData.item_leftTime))
                    itemData.item_leftTime = itemData.item_leftTime - 1
                    if itemData.item_leftTime == 0 then
                        self.ScrollGrid:RemoveItem(i)
                        self:OnClickItem(nil,1)
                    end
                end
            end
        end
        self.ScrollGrid:RefreshAllItems(self.arrayitemlist)
    end,true,true)



end

function Store_Other_Parachute_UI:OnItemDataChange()

    local index = self.ScrollGrid:GetSelectIndex();
    if index then
        local itemData = self.ScrollGrid:GetItemData(index);
        if itemData then
            self:RefreshItemPrice(itemData)
        end
        self.ScrollGrid:RefreshItem(index,itemData)
    end

end

function Store_Other_Parachute_UI:ChooseTheFirstOrSpecifiedOne()
    log("[HHF]StorePetUI:ChooseTheFirstOrSpecifiedOne");
    if StoreOtherUI.jump_info ~= nil then
        if self.arrayitemlist and #self.arrayitemlist > 0 then
            for k, v in pairs(self.arrayitemlist) do
                log("v.item_id " .. tostring(v.item_id))
                log("StoreOtherUI.jump_info.itemId " .. tostring(StoreOtherUI.jump_info.itemId))
                if v.item_id == StoreOtherUI.jump_info.itemId then
                    self:OnClickItem(nil, k);
                    self.ScrollGrid:ScrollToItem(k);
                    break;
                end
            end
            StoreOtherUI.jump_info = nil;
        else
            self._jumpWaitTag = true
        end
    else
        self:OnClickItem(nil, 1);
        self.ScrollGrid:ScrollToItem(1);
    end
end

function Store_Other_Parachute_UI:RefreshItemPrice(itemData)
    local shopInfo = self:GetShopInfo()

    local priceInfo = Store_Other_Parachute_UI.priceInfo
    local type = nil
    local priceNum = 0
    local originalPrice = 0
    local issoldout = StoreFuncUtils.IsSoldOut(shopInfo.item_id, shopInfo.daily_buy_limit, shopInfo.week_buy_limit, shopInfo.permanet_buy_limit)
    local IsPossessed = StoreFuncUtils.IsPossessed(shopInfo.item_id,0,0)
    if priceInfo then
        type = priceInfo.type
        log_tree("priceInfo",priceInfo)
        if priceInfo.discount ~= 0 then-- 有折扣价
            priceNum = priceInfo.discount;
            originalPrice = priceInfo.num;
        else
            priceNum = priceInfo.num;
            originalPrice = 0;
        end
        if itemData then
            log_tree("RefreshItemPrice itemData ",itemData)
            if itemData.LowestPrice then
                itemData.LowestPrice = StoreFuncUtils.GetTwoValidPriceForShow(itemData.LowestPrice);
                log_tree(" itemData.LowestPrice", itemData.LowestPrice)
                local info1 = itemData.LowestPrice[1]
                local info2 = itemData.LowestPrice[2]

                log("itemData.item_jump " .. tostring(itemData.item_jump))
                self.UIRoot.Store_Purchase_Btn:SetData(info1.currency,info1.original,info1.price,info2.currency,info2.original,info2.price,itemData.item_jump,issoldout,IsPossessed,itemData.priceNumMax)
            end
        end
    end

end

function Store_Other_Parachute_UI:SetShopInfo()
    log("[HHF]Store_Other_UI:SetShopInfo");
    local index = self.ScrollGrid:GetSelectIndex();
    log("indexindex ".. index)
    if index then
        local itemData = self.ScrollGrid:GetItemData(index);
        if itemData and itemData.item_shopID then
            local buyInfo =  Store_Other_Parachute_UI.itemMap[itemData.item_shopID]

            if buyInfo then
                log_tree("buyInfo",buyInfo)
                local priceInfo = StoreFuncUtils.GetExchangeMoneyInfo(buyInfo[StoreSystem.label_item_index_price_list])
                if priceInfo then
                    Store_Other_Parachute_UI.priceInfo = priceInfo
                    local shopInfo = StoreFuncUtils.ConvertToShopInfo(buyInfo, StoreSystem.Page_ID_Parachute, StoreSystem.label_subtype_parachute)
                    if shopInfo then
                        Store_Other_Parachute_UI.shopinfo = shopInfo
                    end
                else
                    local shopInfo = StoreFuncUtils.ConvertToShopInfo(buyInfo, StoreSystem.Page_ID_Parachute, StoreSystem.label_subtype_parachute)
                    if shopInfo then
                        Store_Other_Parachute_UI.shopinfo = shopInfo
                    end
                end

            end
        end
    end



end

function Store_Other_Parachute_UI:GetShopInfo()
    if Store_Other_Parachute_UI.shopinfo then
        log_tree("Store_Other_Parachute_UI.shopinfo ",Store_Other_Parachute_UI.shopinfo )
        return Store_Other_Parachute_UI.shopinfo
    end
end

function Store_Other_Parachute_UI:OnClickSendBtn()
    log("OnClickSendBtn")
    local shopInfo = Store_Other_Parachute_UI:GetShopInfo()
    --log_tree("[HHF]EventOnClickSendStoreClothes, shopInfo = ", shopInfo, "[HHF]");
    StoreFuncUtils.SendGift(shopInfo);
end

function Store_Other_Parachute_UI:OnClickBuyBtn()
    log("OnClickBuyBtn")
    local shopInfo = Store_Other_Parachute_UI:GetShopInfo()
    StoreFuncUtils.PurchaseItem(shopInfo)
end

function Store_Other_Parachute_UI:OnClickCollectBtn(collected)
    log("")
    log("Store_Other_Parachute_UI OnClickCollectBtn " ..tostring(collected))
    if UIUtil.CanClickNow(ClickFrequencyLimit.StoreCollectionBtn) == false then
        return;
    end

    local index = self.ScrollGrid:GetSelectIndex();
    if index then
        local itemData = self.ScrollGrid:GetItemData(index);
        if itemData then
            if collected == true then
                StoreSystem.cancel_market_collect_by_item_req(itemData.item_id)
            else
                StoreSystem.add_market_collect_by_item_req(itemData.item_id, StoreSystem.market_collect_source_market);
            end
        end
    end

end

function Store_Other_Parachute_UI:UpdateDetailInfo(widget, index)
    log("[HHF]StoreCollectionUI:UpdateDetailInfo");
    local itemData = self.ScrollGrid:GetItemData(index);

    self.UIRoot.StoreItem_DetailInfo_Logic_BP:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible);
    self.UIRoot.StoreItem_DetailInfo_Logic_BP:SetDetailInfo(
            itemData.item_name,
            itemData.item_quality,
            itemData.item_desc,
            itemData.item_id,
            itemData.item_storeDetailImage, 0, 0, 0, 0, 0);


    if itemData.item_preview == "" then
        self.UIRoot.Image_bg:SetVisibility(UEnums.ESlateVisibility.Collapsed);
        self.UIRoot.Image_bg256:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible);
        local util = require("ui.util")
        util.SetTexture(self.UIRoot.Image_bg256, itemData.item_bigIcon)
    else
        self.UIRoot.Image_bg256:SetVisibility(UEnums.ESlateVisibility.Collapsed);
        self.UIRoot.Image_bg:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible);
        local util = require("ui.util")
        util.SetTexture(self.UIRoot.Image_bg, itemData.item_preview)
    end
    if itemData.item_gift == 0 then
        self.UIRoot.Store_Send_Btn:SetVisibility(UEnums.ESlateVisibility.Collapsed);
    else
        self.UIRoot.Store_Send_Btn:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible);
    end

    --[[
    if itemData.equiped == true then
        self.UIRoot.StoreItem_FeaturesLogic_BP:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible);
        self.UIRoot.StoreItem_FeaturesLogic_BP:SetData(itemData.item_id);
    else
        self.UIRoot.StoreItem_FeaturesLogic_BP:SetVisibility(UEnums.ESlateVisibility.Collapsed);
    end
    --]]
    self.UIRoot.presentPanel:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible);

    self.UIRoot.Store_Purchase_Btn:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible);
    self.UIRoot.Store_Collection_Btn:SetData(itemData.item_collected, itemData.item_collected_num);

    itemData.reddot = StoreSystem.NeedShowReddotByItem(itemData.item_id);
    if widget ~= nil then
        if itemData.reddot == true then
            widget.Store_Fashion_Item_01_UIBP.Image_redDot:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible);
        else
            widget.Store_Fashion_Item_01_UIBP.Image_redDot:SetVisibility(UEnums.ESlateVisibility.Collapsed);
        end
    end
end

function Store_Other_Parachute_UI:OnRefreshItem(widget, index)
    --log("Store_Other_UI:OnRefreshItem, index = " .. tostring(index))

    local itemData = self.ScrollGrid:GetItemData(index)
    if itemData then
        --log("firsttimeclick " .. tostring(self.firsttimeclick))
        widget:SetData(itemData.item_id,itemData.item_shopID,itemData.item_icon,1,itemData.item_new,itemData.item_hot,itemData.item_discount,itemData.item_leftTime,itemData.item_quality,false,false,itemData.item_have,itemData.item_showLeft,itemData.item_vip,itemData.item_showLeftIcon,itemData.item_showSpecialIcon)


        local BusinessHelper = import("BusinessHelper");
        local texture = BusinessHelper.UIGetResWithPath(itemData.item_icon);
        widget.Store_Fashion_Item_01_UIBP.Item:SetBrushFromTexture(texture, false);

        ---@type Image
        local imageQualityBar = widget.Store_Fashion_Item_01_UIBP.Label;
        if itemData.item_quality > 0 then
            imageQualityBar:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible);
            local path = "/Game/UMG/Texture/Atlas/ItemLevelUI/Frames/T_item_icon_quality_" .. tostring(itemData.item_quality-1) ..
                    "_png.T_item_icon_quality_" .. tostring(itemData.item_quality-1) .. "_png"
            local util = require("ui.util")
            util.SetTexture(imageQualityBar, path)
            ---@type Image
            local imageQuality = widget.Store_Fashion_Item_01_UIBP.Image_quality;
            if itemData.item_quality > 4 then
                imageQuality:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible);
                local path = "/Game/UMG/Texture/Atlas/Quality/Frames/T_icon_shop_0" .. tostring(itemData.item_quality-4) ..
                        "_png.T_icon_shop_0" .. tostring(itemData.item_quality-4) .. "_png"
                local util = require("ui.util")
                util.SetTexture(imageQuality, path)
            else
                imageQuality:SetVisibility(UEnums.ESlateVisibility.Collapsed);
            end
        else
            imageQualityBar:SetVisibility(UEnums.ESlateVisibility.Collapsed);
        end

        if itemData.selected == true then
            widget.Store_Fashion_Item_01_UIBP.ChooseBorder:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible);
        else
            widget.Store_Fashion_Item_01_UIBP.ChooseBorder:SetVisibility(UEnums.ESlateVisibility.Collapsed);
        end

        if itemData.equiped == true then
            widget.Store_Fashion_Item_01_UIBP.Image_Bg_Using:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible);
        else
            widget.Store_Fashion_Item_01_UIBP.Image_Bg_Using:SetVisibility(UEnums.ESlateVisibility.Collapsed);
        end

        if itemData.reddot == true then
            widget.Store_Fashion_Item_01_UIBP.Image_redDot:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible);
        else
            widget.Store_Fashion_Item_01_UIBP.Image_redDot:SetVisibility(UEnums.ESlateVisibility.Collapsed);
        end
    end

end
--收到其他页签的物品数据
function Store_Other_Parachute_UI:OnReceivedOtherData()
    local pageData = StoreSystem.store_data[StoreSystem.Page_ID_Parachute];
    if pageData == nil then
        log("Store_Other_UI.UpdateData pageData == nil")
        log("StoreSystem.store_tab " .. tostring(StoreSystem.store_tab))
        log("StoreSystem.Page_ID_Item " .. tostring(StoreSystem.Page_ID_Parachute))
        StoreSystem.GetTabData(StoreSystem.store_tab, StoreSystem.Page_ID_Parachute);
        return
    else
        --log_tree("pageData",pageData)
        self.arrayitemlist = {}
        if pageData[StoreSystem.label_market_index_market_list] then
            log_tree(" pageData[StoreSystem.label_market_index_market_list] ", pageData[StoreSystem.label_market_index_market_list] )
            Store_Other_Parachute_UI.itemMap = pageData[StoreSystem.label_market_index_market_list]
            log_tree("Store_Other_Parachute_UI.itemMap",Store_Other_Parachute_UI.itemMap)
            for i, v in pairs(pageData[StoreSystem.label_market_index_market_list]) do
                local iteminfo = self:GenerateOneItemData(i, v)
                if iteminfo then
                    if iteminfo.item_subType == 701 then
                    end
                    table.insert(self.arrayitemlist,iteminfo)
                end

            end
        end
        table.sort(self.arrayitemlist,
                function(a, b)
                    return StoreFuncUtils.DefaultSortAlgorithm(a, b);
                end)
        self.ScrollGrid:SetData(self.arrayitemlist)
        log("sadasdsadasdas")
    end
    if self._jumpWaitTag then
        log("self._jumpWaitTag")
        self:ChooseTheFirstOrSpecifiedOne()
        self._jumpWaitTag = false
    end
end

function Store_Other_Parachute_UI:OnCollectedResult(eventType, eventID, notify)
    log("[HHF]StorePetUI:OnCollectedResult, notify = " .. tostring(notify));
    local index = self.ScrollGrid:GetSelectIndex();
    if index then
        local itemData = self.ScrollGrid:GetItemData(index);
        if itemData then
            local item_id = itemData.item_id;
            local result = StoreSystem.IsCollectedByItemID(item_id);
            if result == true then
                if StoreSystem.global_collection_num[item_id] == nil then
                    StoreSystem.global_collection_num[item_id] = 1;
                else
                    StoreSystem.global_collection_num[item_id] = StoreSystem.global_collection_num[item_id] + 1;
                end
            else
                StoreSystem.global_collection_num[item_id] = StoreSystem.global_collection_num[item_id] - 1;
            end

            itemData.item_collected = result;
            itemData.item_collected_num = StoreSystem.global_collection_num[item_id];
            self.UIRoot.Store_Collection_Btn:SetData(itemData.item_collected, itemData.item_collected_num);
        end
    end
end

function Store_Other_Parachute_UI:GenerateOneItemData(k, v)
    log("Store_Other_UI:GenerateOneItemData, item_shopID = " ..  tostring(k));
    log("Store_Other_UI:GenerateOneItemData, itemid = " .. tostring(v[1]));
    local itemInfo = Client.GetTableData("Item", v[1]);
    if itemInfo then
        log("itemInfo.ItemType " ..itemInfo.ItemType )
        log("itemInfo.item_subType " ..itemInfo.ItemSubType)
        if itemInfo.ItemType == nil or itemInfo.ItemType ~= 4 or itemInfo.ItemSubType == nil or itemInfo.ItemSubType ~= 701 then
            return nil
        end
        local item = {};
        item.item_shopID = tonumber(k)
        item.item_id = v[1];
        item.item_name = itemInfo.ItemName;
        item.item_desc = itemInfo.ItemDesc;
        item.item_icon = itemInfo.ItemSmallIcon;
        item.item_quality = itemInfo.ItemQuality;
        item.item_storeDetailImage = itemInfo.StoreDetailImage;
        item.item_type = itemInfo.ItemType;
        item.item_subType = itemInfo.ItemSubType;
        item.item_bigIcon = itemInfo.ItemBigIcon;
        item.item_preview = itemInfo.Preview;
        item.item_startTime = v[StoreSystem.label_item_index_start_time] or 0;
        item.item_gift = v[StoreSystem.label_item_index_can_gift] or 0;
        if v[StoreSystem.label_item_index_skip_path] and v[StoreSystem.label_item_index_skip_path] ~= "" then
            item.item_jump = v[StoreSystem.label_item_index_skip_path]
            log(" v[StoreSystem.label_item_index_skip_path]" .. v[StoreSystem.label_item_index_skip_path] )
        else
            item.item_jump = tostring(item.item_id)
            log(" item.item_jump " .. item.item_jump)
        end

        item.reddot = StoreSystem.NeedShowReddotByItem(item.item_id);
        item.equiped = false;
        item.selected = false;
        item.item_collected = StoreSystem.IsCollectedByItemID(item.item_id);
        item.item_collected_num = StoreSystem.global_collection_num[item.item_id] or 0;
        item.collected_number = StoreSystem.global_collection_num[k] or 1;
        item.item_have = StoreFuncUtils.HasItem(item.item_id, 0, 0);
        --item.source, item.source_addr = self:GetSourceInfoByItemID(item.item_id);
        local price = v[StoreSystem.label_item_index_price_list]
        item.LowestPrice = {}
        item.Itemprice = {}
        if type(price) ==  "table" then
            for key, value in pairs(price) do
                local temp = {};
                temp.currency = value[StoreSystem.label_price_index_price_type];
                temp.duration = value[StoreSystem.label_price_index_valid_hours] or 0;
                temp.original = value[StoreSystem.label_price_index_one_original_price] or 0;
                temp.discount = value[StoreSystem.label_price_index_one_discount_price] or 0;
                table.insert(item.Itemprice, temp);
            end
        end

        item.LowestPrice = StoreFuncUtils.CalculateLowestByCurrency(item.Itemprice);
        item.priceNumMax = StoreFuncUtils.GetFirstPriceNumMax(price)

        --if v[StoreSystem.label_item_index_hot_or_new] == 1 then
        --    item.item_hot = true;
        --    item.item_new = false;
        --elseif v[StoreSystem.label_item_index_hot_or_new] == 2 then
        --    if FuncUtil.GetServerTimeInSec() - item.item_startTime > StoreFuncUtils.NewFlagAvailableTime then
        --        item.item_hot = false;
        --        item.item_new = false;
        --    else
        --        item.item_hot = false;
        --        item.item_new = true;
        --    end
        --else
        --    item.item_hot = false;
        --    item.item_new = false;
        --end
        --local discount = v[StoreSystem.label_item_index_discount];
        --if discount ~= nil and discount ~= 0 then
        --    item.item_discount = "-" .. tostring(discount) .. "%";
        --else
        --    item.item_discount = "";
        --end
        --
        item.item_endTime = v[StoreSystem.label_item_index_time_limit] or 0;
        if item.item_endTime ~= 0 then
            item.item_leftTime = item.item_endTime - FuncUtil.GetServerTimeInSec();
            log("item.item_leftTime " ..item.item_leftTime)
        else
            item.item_leftTime = 0;
        end
        --if v[StoreSystem.label_item_index_show_time_limit] == 1 then
        --    item.item_showLeft = true;
        --else
        --    item.item_showLeft = false;
        --end

        item.item_showLeft = StoreFuncUtils.CheckNeedShowSaleEndTime(v);
        item.item_showLeftIcon = v[StoreSystem.label_item_index_show_time_limit] == 1
        item.item_sort = v[StoreSystem.label_item_index_rank]
        local discount = v[StoreSystem.label_item_index_discount] or 0;
        item.discount_for_sort = discount;
        local showDiscount, showHot, showVip = StoreFuncUtils.GetItemLeftTopTagsQueue(
                discount ~= 0,
                StoreFuncUtils.CheckIsHot(v) == true,
                v[StoreSystem.label_item_index_vip] == 1);
        if showDiscount == false then
            discount = 0.0;
        end
        item.item_hot = showHot;
        log("item.item_hot " .. tostring(item.item_hot))
        item.item_vip = showVip;
        local discount = v[StoreSystem.label_item_index_discount];
        if discount ~= nil and discount ~= 0 then
            item.item_discount = "-" .. tostring(discount) .. "%";
        else
            item.item_discount = "";
        end

        local showNew, showSpecialIcon = StoreFuncUtils.GetItemRightTopTagsQueue(
                StoreFuncUtils.CheckIsNew(v) == true, --and serverTime - item.item_startTime > StoreFuncUtils.NewFlagAvailableTime,
                itemInfo.SpecialIcon ~= "");
        item.item_new = showNew;
        item.item_showSpecialIcon = showSpecialIcon;
        item.SpecialIcon = itemInfo.SpecialIcon
        return item;
    else
        log("Store_Other_UI.GenerateStoreClothesItemData, Not found itemID = " .. tostring(v[1]) .. " in Item table");
        return nil;
    end
end

--界面隐藏时触发
function Store_Other_Parachute_UI:OnHide()

end

function Store_Other_Parachute_UI:Close()
    --todo: 这里做些消耗回收动作，注意Store_Other_UI.__super.Close(self)一定要写在最后，遵循先进后出原则

    if Store_Other_Parachute_UI.TimerToRefresh then
        Timer.RemoveTimer(Store_Other_Parachute_UI.TimerToRefresh)
    end
    Store_Other_Parachute_UI.__super.Close(self)
end

local class = require("class")
local ui_base = require("ui.base")
local CUITemplate = class(ui_base, nil, Store_Other_Parachute_UI)

return CUITemplate