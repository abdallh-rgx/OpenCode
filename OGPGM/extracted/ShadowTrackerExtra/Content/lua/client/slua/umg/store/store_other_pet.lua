local PetSystem = require("client.slua.logic.pet.logic_pet");
local StorePetUI = {};

function StorePetUI:ctor()
    log("[HHF]StorePetUI:ctor");
    --todo: 这里可以做些数据初始化工作

    self.bShowing = false;
    self.rawData = {};
    self.rawItemInfo = {};
    self.arrayPetItemList = {};
    self.currentItemInfo = {};
end

function StorePetUI:OnInitialize()
    log("[HHF]StorePetUI:OnInitialize");
    StorePetUI.__super.OnInitialize(self);

    --todo: 在这里做些初始化工作
    self.ScrollGrid = self:InitScrollBox(self.UIRoot.LoopScrollGrid_0);
end

function StorePetUI:RegistEvents()
    log("[HHF]StorePetUI:RegistEvents");
    StorePetUI.__super.RegistEvents(self)

    --todo: 在这里注册事件
    self.ScrollGrid:SetRefreshItemCallback(self.OnRefreshItem, self);
    self.ScrollGrid:AddItemEvent("Store_Fashion_Item_01_UIBP.Button_0", "OnClicked", self.OnClickItem, self);

    --self:AddControlEvent("Store_SexSwitchBtn_C_0", "EventDispatchClickBtn", self.OnClickSexBtn, self);
    --self:AddControlEvent("Store_Collection_Btn", "OnClickCollectItem", self.OnClickCollectBtn, self);
    --self:AddControlEvent("Button_8", "OnClicked", self.OnClickAvatarSwitchBtn, self);
    self:AddControlEvent("Store_Purchase_Btn", "OnClickPurchase", self.OnClickBuyBtn, self);
    self:AddControlEvent("Store_Send_Btn", "OnClickSend", self.OnClickSendBtn, self);
    self:AddControlEvent("Store_Collection_Btn", "OnClickCollectItem", self.OnClickCollectBtn, self);
    --self:AddControlEvent("StoreItem_DetailInfo_Logic_BP.Button_6", "OnClicked", self.OnClickPetDetail, self);

    self:AddCommonEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_DATA, self.OnDataReady, self);
    self:AddCommonEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_COLLECT, self.OnCollectedResult, self);
    self:AddCommonEvent(EVENTTYPE_PET, EVENTID_PET_Change, self.OnPetDataChanged, self);
end

function StorePetUI:OnRefreshItem(widget, index)
    --log("[HHF]StorePetUI:OnRefreshItem, index = " .. tostring(index));
    local itemData = self.ScrollGrid:GetItemData(index);
    local itemWidget = widget.Store_Fashion_Item_01_UIBP;

    widget:SetData(
        itemData.item_id,
        itemData.item_shopID,
        itemData.item_icon,
        itemData.item_num,
        itemData.item_new,
        itemData.item_hot,
        itemData.item_discount,
        itemData.item_leftTime,
        itemData.item_quality,
        itemData.item_equiped,
        itemData.item_selected,
        itemData.item_have,
        itemData.item_showLeft,
        itemData.item_vip,
        itemData.item_showLeftIcon,
        itemData.item_showSpecialIcon);
end

function StorePetUI:OnClickItem(widget, index)
    local itemData = self.ScrollGrid:GetItemData(index);
    log("[HHF]StorePetUI:OnClickItem, index = " .. tostring(index) .. ", itemID = " .. tostring(itemData.item_id));
    local equiped = MultipleAvatar.HasPetEquiped(itemData.item_id);
    log("[HHF]StorePetUI:OnClickItem, before click equiped = " .. tostring(equiped));
    local bForce = widget == nil;
    StoreMainUI.OnSelectedItem(itemData.item_id, 0, 0, bForce);
    --self.currentDisplayType = self:GetDisplayTypeByItemType(itemData);--ModelDisplayer.GetShowtype();--
    equiped = MultipleAvatar.HasPetEquiped(itemData.item_id);
    log("[HHF]StorePetUI:OnClickItem,  after click equiped = " .. tostring(equiped));

    for k, v in pairs(self.arrayPetItemList) do
        if k == index then
            self.arrayPetItemList[k].item_selected = true;
            self.arrayPetItemList[k].item_equiped = equiped;

            -- 点击后new消失
            if v.item_new == true then
                StoreSystem.CheckRecordNewTag(v.item_shopID);
                local showNew, showSpecialIcon = StoreFuncUtils.GetItemRightTopTagsQueue(
                    false,
                    v.item_specialIcon ~= "");
                v.item_new = showNew;
                v.item_showSpecialIcon = showSpecialIcon;
            end
        else
            self.arrayPetItemList[k].item_selected = false;
            self.arrayPetItemList[k].item_equiped = MultipleAvatar.HasEquiped(v.item_id, 0, 0);
        end
    end

    self.ScrollGrid:RefreshAllItems(self.arrayPetItemList);
    self.ScrollGrid:Select(index);

    self:UpdateDetailInfo(widget, index);

    local key = StoreSystem.label_market_index_market_list;
    self.rawItemInfo = self.rawData[key][itemData.item_shopID];
    self.currentItemInfo = itemData;
    self:PlayAudio(require("client.slua.config.sound").confirm);
end

function StorePetUI:OnClickBuyBtn()
    log("[HHF]StorePetUI:OnClickBuyBtn");
    local shopInfo = StoreFuncUtils.ConvertToShopInfo(self.rawItemInfo, StoreOtherUI.tab_id, StoreOtherUI.subTab_id);
    StoreFuncUtils.PurchaseItem(shopInfo);
end

function StorePetUI:OnClickSendBtn()
    log("[HHF]StorePetUI:OnClickSendBtn");
    local shopInfo = StoreFuncUtils.ConvertToShopInfo(self.rawItemInfo, StoreOtherUI.tab_id, StoreOtherUI.subTab_id);
    StoreFuncUtils.SendGift(shopInfo);
end

function StorePetUI:OnClickCollectBtn(collected)
    log("[HHF]StorePetUI:OnClickCollectBtn");
    if UIUtil.CanClickNow(ClickFrequencyLimit.StoreCollectionBtn) == false then
        return;
    end

    if collected == true then
        StoreSystem.cancel_market_collect_by_item_req(self.currentItemInfo.item_id);
    else
        StoreSystem.add_market_collect_by_item_req(self.currentItemInfo.item_id, StoreSystem.market_collect_source_market);
    end
end

function StorePetUI:OnClickPetDetail()
    log("[HHF]StorePetUI:OnClickPetDetail");
    StoreMainUI.CloseUI();

    local ui_manager = require("ui.manager");
    if ui_manager then
        ui_manager.ShowUI(ui_manager.UI_Config.pet_main);
    end
end

function StorePetUI:OnClickAvatarSwitchBtn()
    log("[HHF]StorePetUI:OnClickAvatarSwitchBtn");
    if self.currentDisplayType == ModelDisplayer.SHOWTYPE_AVATAR then
        self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(1);
        ModelDisplayer.SetShowtype(ModelDisplayer.SHOWTYPE_WEAPON_MODEL);
        self.currentDisplayType = ModelDisplayer.SHOWTYPE_WEAPON_MODEL;
    else
        self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(0);
        ModelDisplayer.SetShowtype(ModelDisplayer.SHOWTYPE_AVATAR);
        self.currentDisplayType = ModelDisplayer.SHOWTYPE_AVATAR;
    end
end

function StorePetUI:OnClickSexBtn()
    log("[HHF]StorePetUI:OnClickSexBtn, before click sex = " .. tostring(self.currentSex));
    MultipleAvatar.SwitchSex();
    self.currentSex = MultipleAvatar.ShowingAvatarSextype;
    log("[HHF]StorePetUI:OnClickSexBtn,  after click sex = " .. tostring(self.currentSex));
    self.UIRoot.Store_SexSwitchBtn_C_0:SetData(self.currentSex == LobbyAvatar.SEX_MALE, 0);
end

function StorePetUI:OnCollectedResult(eventType, eventID, notify)
    log("[HHF]StorePetUI:OnCollectedResult, notify = " .. tostring(notify));
    local item_id = self.currentItemInfo.item_id;
    local result = StoreSystem.IsCollectedByItemID(item_id);
    log("[HHF]StorePetUI:OnCollectedResult, result = " .. tostring(result));
    if result == true then
        if StoreSystem.global_collection_num[item_id] == nil then
            StoreSystem.global_collection_num[item_id] = 1;
        else
            StoreSystem.global_collection_num[item_id] = StoreSystem.global_collection_num[item_id] + 1;
        end
    else
        StoreSystem.global_collection_num[item_id] = StoreSystem.global_collection_num[item_id] - 1;
    end

    self.currentItemInfo.item_collected = result;
    self.currentItemInfo.item_collected_num = StoreSystem.global_collection_num[item_id];
    self.UIRoot.Store_Collection_Btn:SetData(self.currentItemInfo.item_collected, self.currentItemInfo.item_collected_num);
end

function StorePetUI:OnPetDataChanged()
    log("[HHF]StorePetUI:OnPetDataChanged");
    self.currentItemInfo.item_have = PetSystem.HasPet(self.currentItemInfo.item_id);
    local itemData = self.currentItemInfo;
    local showPrice = StoreFuncUtils.GetTwoValidPriceForShow(itemData.item_lowestPrice);
    self.UIRoot.Store_Purchase_Btn:SetData(
        showPrice[1].currency,
        showPrice[1].original,
        showPrice[1].price,
        showPrice[2].currency,
        showPrice[2].original,
        showPrice[2].price,
        itemData.item_jump,
        StoreFuncUtils.IsSoldOut(itemData.item_id, itemData.dayLimit, itemData.weekLimit, itemData.permanentLimit),
        itemData.item_have,
        itemData.priceNumMax);
end

function StorePetUI:UpdateDetailInfo(widget, index)
    log("[HHF]StorePetUI:UpdateDetailInfo");
    local itemData = self.ScrollGrid:GetItemData(index);

    self.UIRoot.StoreItem_DetailInfo_Logic_BP:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible);
    self.UIRoot.StoreItem_DetailInfo_Logic_BP:SetDetailInfo(
        itemData.item_name,
        itemData.item_quality,
        itemData.item_desc,
        itemData.item_id,
        itemData.item_storeDetailImage, 0, 0, 0, 0,
        itemData.item_saleEndTime);
    self.UIRoot.StoreItem_DetailInfo_Logic_BP.HorizontalBox_2:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible);

    self.UIRoot.Store_Purchase_Btn:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible);
    local showPrice = StoreFuncUtils.GetTwoValidPriceForShow(itemData.item_lowestPrice);
    self.UIRoot.Store_Purchase_Btn:SetData(
        showPrice[1].currency,
        showPrice[1].original,
        showPrice[1].price,
        showPrice[2].currency,
        showPrice[2].original,
        showPrice[2].price,
        itemData.item_jump,
        StoreFuncUtils.IsSoldOut(itemData.item_id, itemData.dayLimit, itemData.weekLimit, itemData.permanentLimit),
        itemData.item_have,
        itemData.priceNumMax);

    if itemData.item_gift == 0 then
        self.UIRoot.presentPanel:SetVisibility(UEnums.ESlateVisibility.Collapsed);
    else
        self.UIRoot.presentPanel:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible);
    end

    self.UIRoot.collectPanel:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible);
    self.UIRoot.Store_Collection_Btn:SetData(itemData.item_collected, itemData.item_collected_num);

    --self.UIRoot.collectPanel:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible);
    --self.UIRoot.Store_Collection_Btn:SetData(true, itemData.collected_number);
end

function StorePetUI:OnPostInitialize()
    StorePetUI.__super.OnPostInitialize(self);

    --todo: OnPostInitialize在OnInitialize、RegistEvents之后，有需要在RegistEvents后初始化的工作写这里
    UIUtil.SetAdaptation(self.UIRoot.CanvasPanel_15);
    StoreSystem.GetTabData(StoreSystem.store_tab, StoreOtherUI.tab_id);

    log("[HHF]StorePetUI:OnPostInitialize, #self.arrayPetItemList == 0");
    self.ScrollGrid:SetData(self.arrayPetItemList);

    self:HideAllDetailInfo();
    ModelDisplayer.SetShowtype(ModelDisplayer.SHOWTYPE_AVATAR);
    self.currentDisplayType = ModelDisplayer.SHOWTYPE_AVATAR;
    self.currentSex = MultipleAvatar.ShowingAvatarSextype;
    --self.UIRoot.WidgetSwitcher_1:SetActiveWidgetIndex(0);
    --self.UIRoot.Store_SexSwitchBtn_C_0:SetData(self.currentSex == LobbyAvatar.SEX_MALE, 0);

    self.leftTimeTimer = self:AddTimer(0, function()
        self:OnRefreshLeftTime();
    end);

    if #self.arrayPetItemList > 0 then
        self:ChooseTheFirstOrSpecifiedOne();
    end
end

function StorePetUI:ChooseTheFirstOrSpecifiedOne()
    log("[HHF]StorePetUI:ChooseTheFirstOrSpecifiedOne");
    if StoreOtherUI.jump_info ~= nil then
        for k, v in pairs(self.arrayPetItemList) do
            if v.item_id == StoreOtherUI.jump_info.itemId then
                self:OnClickItem(nil, k);
                self.ScrollGrid:ScrollToItem(k);
                break;
            end
        end

        StoreOtherUI.jump_info = nil;
    else
        self:OnClickItem(nil, 1);
        self.ScrollGrid:ScrollToItem(1);
    end
end

function StorePetUI:OnDataReady(eventType, eventID, param)
    log_tree("[HHF]StorePetUI:OnDataReady, param = ", param, "[HHF]");
    if param ~= nil and param.tab_type == StoreSystem.store_tab and param.tab_id == StoreOtherUI.tab_id then
        self:SetData(param.data);
        --self:UpdateEquipedAndSelectedState();
    else
        log("[HHF]StorePetUI:OnDataReady, param = nil");
    end
end

function StorePetUI:SetData(info)
    self.rawData = info;

    local key = StoreSystem.label_market_index_market_list;
    for k, v in pairs(info[key]) do
        local item = self:GenerateStorePetItemData(k, v);
        if item ~= nil then
            if item.item_endTime ~= 0 and item.item_leftTime <= 0 then
                log("[HHF]StorePetUI:SetData, itemID = " .. tostring(item.item_id) .. " has expired.");
            else
                table.insert(self.arrayPetItemList, item);
            end
        end
    end

    log_tree("[HHF]StorePetUI:SetData, after dataList = ", self.arrayPetItemList, "[HHF]");

    if self.bShowing == true then
        log("[HHF]self.arrayPetItemList.length = " .. tostring(FuncUtil:CountTable(self.arrayPetItemList)));
        self.ScrollGrid:SetData(self.arrayPetItemList);

        if #self.arrayPetItemList > 0 then
            self:ChooseTheFirstOrSpecifiedOne();
        end
    end
end

function StorePetUI:GenerateStorePetItemData(k, v)
    local itemID = v[StoreSystem.label_item_index_id];
    local itemInfo = Client.GetTableData("Item", itemID);
    if itemInfo ~= nil and itemInfo.ItemType == 500 then
        local item = {};
        item.item_shopID = k;
        item.item_id = itemID;
        item.item_name = itemInfo.ItemName;
        item.item_desc = itemInfo.ItemDesc;
        --item.item_position = itemInfo.WardrobeTab;
        item.item_specialIcon = itemInfo.SpecialIcon;
        item.item_icon = itemInfo.ItemSmallIcon;
        item.item_quality = itemInfo.ItemQuality;
        item.item_storeDetailImage = itemInfo.StoreDetailImage;
        item.item_num = v[StoreSystem.label_item_index_count] or 1;
        item.item_sort = v[StoreSystem.label_item_index_rank] or 0;
        item.item_jump = v[StoreSystem.label_item_index_skip_path] or tostring(itemID);
        item.item_startTime = v[StoreSystem.label_item_index_start_time] or 0;
        item.item_collected = StoreSystem.IsCollectedByItemID(itemID);
        item.item_collected_num = StoreSystem.global_collection_num[itemID] or 0;

        --[[
        if v[StoreSystem.label_item_index_hot_or_new] == 1 then
            item.item_hot = true;
            item.item_new = false;
        elseif v[StoreSystem.label_item_index_hot_or_new] == 2 then
            if FuncUtil.GetServerTimeInSec() - item.item_startTime > StoreFuncUtils.NewFlagAvailableTime then
                item.item_hot = false;
                item.item_new = false;
            else
                item.item_hot = false;
                item.item_new = true;
            end
        else
            item.item_hot = false;
            item.item_new = false;
        end
        --]]

        item.item_price = {};
        item.item_lowestPrice = {};
        local price = v[StoreSystem.label_item_index_price_list];
        if type(price) == "table" then
            for key, value in pairs(price) do
                local temp = {};
                temp.currency = value[StoreSystem.label_price_index_price_type];
                temp.duration = value[StoreSystem.label_price_index_valid_hours] or 0;
                temp.original = value[StoreSystem.label_price_index_one_original_price] or 0;
                temp.discount = value[StoreSystem.label_price_index_one_discount_price] or 0;
                table.insert(item.item_price, temp);
            end

            item.item_lowestPrice = StoreFuncUtils.CalculateLowestByCurrency(item.item_price);
        end
        item.priceNumMax = StoreFuncUtils.GetFirstPriceNumMax(price);

        item.item_equiped = false;
        item.item_selected = false;
        item.item_have = PetSystem.HasPet(item.item_id);

        item.item_gift = v[StoreSystem.label_item_index_can_gift] or 0;
        item.item_endTime = v[StoreSystem.label_item_index_time_limit] or 0;
        if item.item_endTime ~= 0 then
            item.item_leftTime = item.item_endTime - FuncUtil.GetServerTimeInSec();
        else
            item.item_leftTime = 0;
        end
        --[[
        if v[StoreSystem.label_item_index_show_time_limit] == 1 then
            item.item_showLeft = true;
        else
            item.item_showLeft = false;
        end
        --]]
        item.item_showLeft = StoreFuncUtils.CheckNeedShowSaleEndTime(v);
        item.item_showLeftIcon = v[StoreSystem.label_item_index_show_time_limit] == 1;
        if item.item_showLeftIcon == true then
            item.item_saleEndTime = item.item_endTime;
        else
            item.item_saleEndTime = 0;
        end

        local discount = v[StoreSystem.label_item_index_discount] or 0;
        local showDiscount, showHot, showVip = StoreFuncUtils.GetItemLeftTopTagsQueue(
            discount ~= 0,
            StoreFuncUtils.CheckIsHot(v) == true,
            v[StoreSystem.label_item_index_vip] == 1);
        if showDiscount == false then
            discount = 0;
        end
        item.item_hot = showHot;
        item.item_vip = showVip;

        local discount = v[StoreSystem.label_item_index_discount];
        if discount ~= nil and discount ~= 0 then
            item.item_discount = "-" .. tostring(discount) .. "%";
        else
            item.item_discount = "";
        end

        local showNew, showSpecialIcon = StoreFuncUtils.GetItemRightTopTagsQueue(
            StoreFuncUtils.CheckIsNew(v) == true, --and serverTime - item.item_startTime > StoreFuncUtils.NewFlagAvailableTime,
            item.item_specialIcon ~= "");
        item.item_new = showNew;
        item.item_showSpecialIcon = showSpecialIcon;

        local limitPurchaseKey = StoreSystem.label_item_index_buy_limit;
        local limitPurchaseInfo = v[limitPurchaseKey];
        if limitPurchaseInfo ~= nil then
            item.dayLimit = limitPurchaseInfo[StoreSystem.label_buy_limit_type_daily] or 0;
            item.weekLimit = limitPurchaseInfo[StoreSystem.label_buy_limit_type_week] or 0;
            item.permanentLimit = limitPurchaseInfo[StoreSystem.label_buy_limit_type_permanent] or 0;
        else
            item.dayLimit = 0;
            item.weekLimit = 0;
            item.permanentLimit = 0;
        end

        return item;
    else
        log("[HHF]StorePetUI:GenerateStorePetItemData, Not found itemID = " .. tostring(itemID) .. " in Item table");
        return nil;
    end
end

function StorePetUI:OnShow()
    log("[HHF]StorePetUI:OnShow");
    self.bShowing = true;

    if self.currentItemInfo ~= nil and self.currentItemInfo.item_equiped == true then
        StoreMainUI.OnSelectedItem(self.currentItemInfo.item_id, 0, 0, true);
    end
end

function StorePetUI:HideAllDetailInfo()
    log("[HHF]StorePetUI:HideAllDetailInfo");
    self.UIRoot.StoreItem_DetailInfo_Logic_BP:SetVisibility(UEnums.ESlateVisibility.Collapsed);
    self.UIRoot.Button_8:SetVisibility(UEnums.ESlateVisibility.Collapsed);
    self.UIRoot.Store_Purchase_Btn:SetVisibility(UEnums.ESlateVisibility.Collapsed);
    self.UIRoot.presentPanel:SetVisibility(UEnums.ESlateVisibility.Collapsed);
    self.UIRoot.collectPanel:SetVisibility(UEnums.ESlateVisibility.Collapsed);
    self.UIRoot.CanvasPanel_6:SetVisibility(UEnums.ESlateVisibility.Collapsed);
end

function StorePetUI:OnRefreshLeftTime()
    while true do
        coroutine.yield(1);

        if self.bShowing == true then
            local needDelete = {};
            local needUpdate = false;
            for k, v in pairs(self.arrayPetItemList) do
                if v.item_endTime ~= 0 then
                    v.item_leftTime = v.item_endTime - FuncUtil.GetServerTimeInSec();
                    if v.item_leftTime > 0 then
                        needUpdate = true;
                    end

                    if v.item_leftTime <= 0 then
                        table.insert(needDelete, k);
                    end
                else
                    v.item_leftTime = 0;
                end
            end

            if #needDelete > 0 then
                for k, v in pairs(needDelete) do
                    for i = v, #self.arrayPetItemList do
                        self.arrayPetItemList[i] = self.arrayPetItemList[i + 1];
                    end
                end
                self.ScrollGrid:SetData(self.arrayPetItemList);
                self:HideAllDetailInfo();
            else
                if needUpdate == true then
                    self.ScrollGrid:RefreshAllItems(self.arrayPetItemList);
                end
            end
        end
    end
end

function StorePetUI:Close()
    log("[HHF]StorePetUI:Close");
    --todo: 这里做些消耗回收动作，注意StorePetUI.__super.Close(self)一定要写在最后，遵循先进后出原则
    if self.leftTimeTimer ~= nil then
        self:RemoveTimer(self.leftTimeTimer);
        self.leftTimeTimer = nil;
    end

    StorePetUI.__super.Close(self);
end

--界面隐藏时触发
function StorePetUI:OnHide()
    log("[HHF]StorePetUI:OnHide");
    self.bShowing = false;

    if self.currentItemInfo ~= nil and self.currentItemInfo.item_equiped == true then
        StoreMainUI.OnSelectedItem(self.currentItemInfo.item_id, 0, 0, false);
    end
end

function StorePetUI:UnRegistEvents()
    log("[HHF]StorePetUI:UnRegistEvents");
    --todo: 在这里反注册事件

    StorePetUI.__super.UnRegistEvents(self);
end

--仅在需要监听状态变化时写这个函数
function StorePetUI:OnModeSwitch(preStatus, currentStatus)
    log("[HHF]StorePetUI:OnModeSwitch");
end

local class = require("class");
local ui_base = require("ui.base");
local CStorePetUI = class(ui_base, nil, StorePetUI);

return CStorePetUI;
