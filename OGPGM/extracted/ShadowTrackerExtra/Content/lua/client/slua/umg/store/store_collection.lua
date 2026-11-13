local Enum_ItemSource = {
    EnumHave = -1,
    EnumNone = 0,
    EnumStore = 1,
    EnumPDD = 2,
    EnumRP = 3,
    EnumSupply = 4,
    EnumDirect = 5,
}

local StoreCollectionUI = {};

function StoreCollectionUI:ctor()
    log("[HHF]StoreCollectionUI:ctor");
    --todo: 这里可以做些数据初始化工作

    self.currentCollectedNumber = 0;
    self.arrayCollectedItemList = {};
    if type(StoreSystem.my_collection_data) == "table" then
        self.currentCollectedNumber = StoreSystem.my_collection_data.cur_market_collect_count or 0;
        for k, v in pairs(StoreSystem.my_collection_data.market_collect_item_table) do
            table.insert(self.arrayCollectedItemList, self:GenerateOneItemData(k, v));
        end

        if #self.arrayCollectedItemList > 1 then
            table.sort(self.arrayCollectedItemList,
                function(a, b)
                    return self:DefaultSortAlgorithm(a, b);
                end);
        end
    end

    StoreSystem.get_market_collect_jump_info_req();
end

--1.有红点>无红点
--2.按品质从高到低排列
--3.按服装>枪械>载具>其他
--4.按物品ID
function StoreCollectionUI:DefaultSortAlgorithm(a, b)
    if a.reddot == b.reddot then
        if a.item_quality == b.item_quality then
            if a.sortKey == b.sortKey then
                return a.item_id < b.item_id;
            else
                return a.sortKey > b.sortKey;
            end
        else
            return a.item_quality > b.item_quality;
        end
    else
        return a.reddot;
    end
end

function StoreCollectionUI:GenerateOneItemData(k, v)
    --log("[HHF]StoreCollectionUI:GenerateOneItemData, k = " .. tostring(k));
    local itemInfo = Client.GetTableData("Item", k);
    if itemInfo ~= nil then
        local item = {};
        item.item_id = k;
        item.item_name = itemInfo.ItemName;
        item.item_desc = itemInfo.ItemDesc;
        item.item_icon = itemInfo.ItemSmallIcon;
        item.item_quality = itemInfo.ItemQuality;
        item.item_storeDetailImage = itemInfo.StoreDetailImage;
        item.item_type = itemInfo.ItemType;
        item.item_subType = itemInfo.ItemSubType;
        item.item_bigIcon = itemInfo.ItemBigIcon;
        item.item_preview = itemInfo.Preview;

        item.sortKey = self:GetSortKeyByItemType(item.item_type, item.item_subType);
        item.reddot = StoreSystem.NeedShowReddotByItem(item.item_id);
        item.equiped = false;
        item.selected = false;
        item.collected_number = StoreSystem.global_collection_num[k] or 1;
        item.have = StoreFuncUtils.HasItem(item.item_id, 0, 0);
        item.source, item.source_addr = self:GetSourceInfoByItemID(item.item_id);

        return item;
    else
        log("[HHF]StoreClothesUI.GenerateStoreClothesItemData, Not found itemID = " .. tostring(k) .. " in Item table");
        return nil;
    end
end

function StoreCollectionUI:GetSortKeyByItemType(type, subType)
    local key = 1;
    if type == 4 and math.floor(subType / 100) == 4 then     -- 服装
        key = 4;
    elseif type == 1 then                                    -- 武器
        key = 3;
    elseif type == 8 or type == 9 then                       -- 载具
        key = 2;
    else
        key = 1;
    end

    return key;
end

function StoreCollectionUI:GetDisplayTypeByItemType(itemInfo)
    local type = ModelDisplayer.SHOWTYPE_NONE;
    if itemInfo.item_type == 1 then 													      -- 武器
        type = ModelDisplayer.SHOWTYPE_WEAPON_MODEL;
    elseif itemInfo.item_type == 4 and math.floor(itemInfo.item_subType / 100) == 4 then      -- 服装
        type = ModelDisplayer.SHOWTYPE_AVATAR;
    elseif itemInfo.item_type == 5 then                                                       -- 背包（头盔）
        type = ModelDisplayer.SHOWTYPE_AVATAR;
    elseif itemInfo.item_type == 8 or itemInfo.item_type == 9 then                            -- 载具
        type = ModelDisplayer.SHOWTYPE_MODEL;
    elseif itemInfo.item_type == 22 then 											          -- 表情
        type = ModelDisplayer.SHOWTYPE_AVATAR;
    --elseif itemInfo.item_type == 4 and math.floor(itemInfo.item_subType / 100) == 7 then      -- 降落伞
    --    type = ModelDisplayer.SHOWTYPE_NONE;
    --elseif itemInfo.item_type == 15 and math.floor(itemInfo.item_subType / 100) == 15 then    -- 宝箱
    --    type = PDD_System_UI.type_TreasureChest;
    elseif itemInfo.item_type == 500 then 											          -- 宠物
        type = ModelDisplayer.SHOWTYPE_AVATAR;
    else
        type = ModelDisplayer.SHOWTYPE_NONE;
    end

    if type == ModelDisplayer.SHOWTYPE_AVATAR then
        self.UIRoot.WidgetSwitcher_1:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible);
        self.UIRoot.WidgetSwitcher_1:SetActiveWidgetIndex(0);
    elseif type == ModelDisplayer.SHOWTYPE_WEAPON_MODEL then
        self.UIRoot.WidgetSwitcher_1:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible);
        self.UIRoot.WidgetSwitcher_1:SetActiveWidgetIndex(1);
    else
        self.UIRoot.WidgetSwitcher_1:SetVisibility(UEnums.ESlateVisibility.Collapsed);
    end

    return type;
end

function StoreCollectionUI:GetSourceInfoByItemID(item_id)
    local result = Enum_ItemSource.EnumNone;
    local source_addr = "";

    if StoreFuncUtils.HasItem(item_id, 0, 0) == true then
        result = Enum_ItemSource.EnumHave;
    else
        source_addr = StoreSystem.collection_jump_info[item_id] or "";
        if source_addr ~= "" then
            local params = FuncUtil:ParseURLParams(source_addr);
            local moduleID = tonumber(params["module"]);
            if moduleID == BP_ENUM_MODULE_PDD then
                result = Enum_ItemSource.EnumPDD;
            elseif moduleID == BP_ENUM_LOBBY_MENU_PURCHASE then
                result = Enum_ItemSource.EnumDirect;
            elseif moduleID == JumpUtils.MODEL_ID_PASS then
                result = Enum_ItemSource.EnumRP;
            end
        end

        if result == Enum_ItemSource.EnumNone then
            source_addr = tostring(item_id);
            local info = JumpUtils.FindJumpInfoFirst(item_id, JumpUtils.MODEL_ID_STORE);
            if info ~= nil then
                if info.moduleId == JumpUtils.MODEL_ID_STORE then
                    if info.cant_buy ~= nil then

                    else
                        result = Enum_ItemSource.EnumStore;
                    end
                elseif info.moduleId == JumpUtils.MODEL_ID_SUPPLY then
                    result = Enum_ItemSource.EnumSupply;
                end
            end
        end
    end

    return result, source_addr;
end

function StoreCollectionUI:OnInitialize()
    log("[HHF]StoreCollectionUI:OnInitialize");
    StoreCollectionUI.__super.OnInitialize(self);

    --todo: 在这里做些初始化工作
    self.ScrollGrid = self:InitScrollBox(self.UIRoot.LoopScrollGrid_0);
    --self.UIRoot:CreateKillInfoItem();

	self.region = Client.GetPublishRegion();
	if self.region == "JAPAN" or self.region == "KOREA" then
		self:AdjustForJapanVersion();
        self.UIRoot.Image_28:SetVisibility(UEnums.ESlateVisibility.Hidden);
	end
end

function StoreCollectionUI:AdjustForJapanVersion()
	log("[HHF]StoreCollectionUI:AdjustForJapanVersion");
	---@type CanvasPanel
	local canvasPanel = self.UIRoot.itemListPanel;
	---@type CanvasPanelSlot
	local canvasPanelSlot = canvasPanel.Slot;

	local margin = FMargin(0, 65, 0, 109);
	canvasPanelSlot:SetOffsets(margin);

	local vector2D = canvasPanelSlot:GetSize();
	vector2D.X = 351;
	canvasPanelSlot:SetSize(vector2D);

	local position = canvasPanelSlot:GetPosition();
	position.X = -140;
	canvasPanelSlot:SetPosition(position);

	local gridMargin = FMargin(19, 14, 14, 14);
	self.UIRoot.LoopScrollGrid_0.Slot:SetOffsets(gridMargin);

	self.ScrollGrid.UIRoot.ItemSize = FVector2D(100, 100);
	self.ScrollGrid.UIRoot.Padding = FVector2D(6, 6);
end

function StoreCollectionUI:RegistEvents()
    log("[HHF]StoreCollectionUI:RegistEvents");
    StoreCollectionUI.__super.RegistEvents(self)

    --todo: 在这里注册事件
    self.ScrollGrid:SetRefreshItemCallback(self.OnRefreshItem, self);
    self.ScrollGrid:AddItemEvent("Store_Fashion_Item_01_UIBP.Button_0", "OnClicked", self.OnClickItem, self);

    --self:AddControlEvent("StoreItem_FeaturesLogic_BP", "OnClickStoreFeaturesBtn", self.OnClickFeatureBtn, self);
    self:AddControlEvent("Store_SexSwitchBtn_C_0", "EventDispatchClickBtn", self.OnClickSexBtn, self);

    self:AddControlEvent("buyButton", "OnClicked", self.OnClickBuyBtn, self);
    self:AddControlEvent("Store_Collection_Btn", "OnClickCollectItem", self.OnClickCollectBtn, self);
    self:AddControlEvent("Button_8", "OnClicked", self.OnClickAvatarSwitchBtn, self);
    self:AddControlEvent("BGM_Lobby", "OnCheckStateChanged", self.OnCheckStateChanged, self);

    self:AddCommonEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_COLLECT, self.OnCollectedResult, self);

    self:AddCommonEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_COLLECT_JUMPINFO, self.OnReceivedCollectedJumpInfo, self);
end

function StoreCollectionUI:OnRefreshItem(widget, index)
    --log("[HHF]StoreCollectionUI:OnRefreshItem, index = " .. tostring(index));
    local itemData = self.ScrollGrid:GetItemData(index);

    local util = require("ui.util");
    util.SetTexture(widget.Store_Fashion_Item_01_UIBP.Item, itemData.item_icon);

    ---@type Image
    local imageQualityBar = widget.Store_Fashion_Item_01_UIBP.Label;
    if itemData.item_quality > 0 then
        imageQualityBar:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible);
        local path = "/Game/UMG/Texture/Atlas/ItemLevelUI/Frames/T_item_icon_quality_" .. tostring(itemData.item_quality-1) ..
            "_png.T_item_icon_quality_" .. tostring(itemData.item_quality-1) .. "_png";
        util.SetTexture(imageQualityBar, path);

        ---@type Image
        local imageQuality = widget.Store_Fashion_Item_01_UIBP.Image_quality;
        if itemData.item_quality > 4 then
            imageQuality:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible);
            local path = "/Game/UMG/Texture/Atlas/Quality/Frames/T_icon_shop_0" .. tostring(itemData.item_quality-4) ..
                "_png.T_icon_shop_0" .. tostring(itemData.item_quality-4) .. "_png";
            util.SetTexture(imageQuality, path);
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

function StoreCollectionUI:OnSelectedItem(item_id, bForce)
    if self.region == "JAPAN" or self.region == "KOREA" then
        SupplyMainUI.OnSelectedItem(item_id, 0, 0, bForce, true);
    else
        StoreMainUI.OnSelectedItem(item_id, 0, 0, bForce);
    end
end

function StoreCollectionUI:OnClickItem(widget, index)
    local itemData = self.ScrollGrid:GetItemData(index);
    log("[HHF]StoreCollectionUI:OnClickItem, index = " .. tostring(index) .. ", itemID = " .. tostring(itemData.item_id));
    local equiped = MultipleAvatar.HasEquiped(itemData.item_id, 0, 0);
    log("[HHF]StoreCollectionUI:OnClickItem, before click equiped = " .. tostring(equiped));
    local bForce = widget == nil;
    self.currentDisplayType = self:GetDisplayTypeByItemType(itemData);
    if self.currentDisplayType == ModelDisplayer.SHOWTYPE_MODEL then
        bForce = true;
        self:OnSelectedItem(itemData.item_id, bForce);
        ModelDisplayer.SetShowtype(ModelDisplayer.SHOWTYPE_MODEL);
    elseif self.currentDisplayType == ModelDisplayer.SHOWTYPE_NONE then
        self:OnSelectedItem(itemData.item_id, bForce);
        ModelDisplayer.SetShowtype(ModelDisplayer.SHOWTYPE_NONE);
    elseif self.currentDisplayType == ModelDisplayer.SHOWTYPE_WEAPON_MODEL then
        self:OnSelectedItem(itemData.item_id, bForce);
        self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(0);
        self.currentDisplayType = ModelDisplayer.SHOWTYPE_AVATAR;
        ModelDisplayer.SetShowtype(ModelDisplayer.SHOWTYPE_AVATAR);
    else
        self:OnSelectedItem(itemData.item_id, bForce);
        self.currentDisplayType = ModelDisplayer.SHOWTYPE_AVATAR;
        ModelDisplayer.SetShowtype(ModelDisplayer.SHOWTYPE_AVATAR);
    end
    --self.currentDisplayType = self:GetDisplayTypeByItemType(itemData);--ModelDisplayer.GetShowtype();--
    equiped = MultipleAvatar.HasEquiped(itemData.item_id, 0, 0);
    log("[HHF]StoreCollectionUI:OnClickItem,  after click equiped = " .. tostring(equiped));

    for k, v in pairs(self.arrayCollectedItemList) do
        if k == index then
            self.arrayCollectedItemList[k].selected = true;
            self.arrayCollectedItemList[k].equiped = equiped;
        else
            self.arrayCollectedItemList[k].selected = false;
            self.arrayCollectedItemList[k].equiped = MultipleAvatar.HasEquiped(v.item_id, 0, 0);
        end
    end

    self.ScrollGrid:RefreshAllItems(self.arrayCollectedItemList);
    self.ScrollGrid:Select(index);

    StoreRedDotModel.SetCollectionTabRedDotMap(itemData.item_id);

    self:UpdateDetailInfo(widget, index);
    self:PlayAudio(require("client.slua.config.sound").confirm);
end

function StoreCollectionUI:OnClickAvatarSwitchBtn()
    log("[HHF]StoreCollectionUI:OnClickAvatarSwitchBtn");
    if self.currentDisplayType == ModelDisplayer.SHOWTYPE_AVATAR then
        self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(1);
        ModelDisplayer.SetShowtype(ModelDisplayer.SHOWTYPE_WEAPON_MODEL);
        self.currentDisplayType = ModelDisplayer.SHOWTYPE_WEAPON_MODEL;
    else
        self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(0);
        ModelDisplayer.SetShowtype(ModelDisplayer.SHOWTYPE_AVATAR);
        self.currentDisplayType = ModelDisplayer.SHOWTYPE_AVATAR;
    end
    self:PlayAudio(require("client.slua.config.sound").confirm);
end

function StoreCollectionUI:OnCheckStateChanged(isChecked)
    log("[HHF]StoreCollectionUI:OnCheckStateChanged, isChecked = " .. tostring(isChecked));
    if UIUtil.CanClickNow(ClickFrequencyLimit.StoreCollectionBtn) == false then
        log("[HHF][HHF]StoreCollectionUI:OnCheckStateChanged, revert!");
        self.UIRoot.BGM_Lobby:SetIsChecked(StoreSystem.GetNotifyCheckedState());
    else
        StoreSystem.set_market_collect_notify_req(isChecked);
    end
    self:PlayAudio(require("client.slua.config.sound").confirm);
end

function StoreCollectionUI:OnClickFeatureBtn(featureID, featureType, param1, param2)
    log("[HHF]StoreCollectionUI:OnClickFeatureBtn, featureID = " .. tostring(featureID) .. ", featureType = " .. tostring(featureType));
    if featureType == 2 then
        self.UIRoot:PlayKillBroadcast();
    elseif featureType == 3 then
        if param1 ~= 0 then
            StoreMainUI.PlayAvatarEmotion(param1);
            StoreMainUI.ResetEmotionTimer();
        end
    elseif featureType == 4 then
        if self.deadBoxTimer == nil then
            self.deadBoxHandler = SceneExtraModel.Create(param2);
            if self.deadBoxHandler ~= nil then
                self.deadBoxHandler:SetPosition(-70, -434, -14438);

                ModelDisplayer.Hide();
                self.oldDisplayType = self.currentDisplayType;
                self.currentDisplayType = ModelDisplayer.SHOWTYPE_NONE;

                self.deadBoxTimer = self:AddTimer(3, function()
	                self:OnDeadBoxRestore();
                end);
            else
                log("[HHF]StoreCollectionUI:OnClickFeatureBtn, SceneExtraModel.Create failed.");
            end
        end
    end
end

function StoreCollectionUI:OnClickSexBtn()
    log("[HHF]StoreCollectionUI:OnClickSexBtn, before click sex = " .. tostring(self.currentSex));
    MultipleAvatar.SwitchSex();
    self.currentSex = MultipleAvatar.ShowingAvatarSextype;
    log("[HHF]StoreCollectionUI:OnClickSexBtn,  after click sex = " .. tostring(self.currentSex));
    self.UIRoot.Store_SexSwitchBtn_C_0:SetData(self.currentSex == LobbyAvatar.SEX_MALE, 0);
end

function StoreCollectionUI:OnClickBuyBtn()
    log("[HHF]StoreCollectionUI:OnClickBuyBtn");
    self:PlayAudio(require("client.slua.config.sound").confirm);
    local index = self.ScrollGrid:GetSelectIndex();
    local itemData = self.ScrollGrid:GetItemData(index);

    if itemData.source == Enum_ItemSource.EnumPDD then
	    if self.region == "JAPAN" or self.region == "KOREA" then
		    SupplyMainUI.CloseUI();
	    else
		    StoreMainUI.CloseUI();
	    end
        GlobalData:JumpUrl(itemData.source_addr);
    elseif itemData.source == Enum_ItemSource.EnumDirect then
	    if self.region == "JAPAN" or self.region == "KOREA" then
		    SupplyMainUI.CloseUI();
	    else
		    StoreMainUI.CloseUI();
	    end
        GlobalData:JumpUrl(itemData.source_addr);
    elseif itemData.source == Enum_ItemSource.EnumStore then
        StoreFuncUtils.JumpFirst(itemData.item_id, JumpUtils.MODEL_ID_STORE);
    elseif itemData.source == Enum_ItemSource.EnumSupply then
        StoreFuncUtils.JumpFirst(itemData.item_id, JumpUtils.MODEL_ID_STORE);
    elseif itemData.source == Enum_ItemSource.EnumRP then
        StoreFuncUtils.Jump(itemData.source_addr);
    end
end

function StoreCollectionUI:OnClickCollectBtn()
    log("[HHF]StoreCollectionUI:OnClickCollectBtn");
    local index = self.ScrollGrid:GetSelectIndex();
    local itemData = self.ScrollGrid:GetItemData(index);

    local title = FuncUtil.GetLocalizeResStr(110115);
    local okLabel = FuncUtil.GetLocalizeResStr(110036);
    local cancelLabel = FuncUtil.GetLocalizeResStr(110035);
    local tips = FuncUtil.GetLocalizeResStr(6781);
    CommonMessageBoxUI:ShowPanel(2, title, tips,
        function()
            StoreSystem.cancel_market_collect_by_item_req(itemData.item_id);
        end,
        nil,
        okLabel,
        cancelLabel);
end

function StoreCollectionUI:OnCollectedResult(eventType, eventID, notify)
    log("[HHF]StoreCollectionUI:OnCollectedResult, notify = " .. tostring(notify));
    if notify == true then
        self.UIRoot.BGM_Lobby:SetIsChecked(StoreSystem.GetNotifyCheckedState());
    else
        local index = self.ScrollGrid:GetSelectIndex();
        local itemData = self.ScrollGrid:GetItemData(index);
        StoreSystem.global_collection_num[itemData.item_id] = StoreSystem.global_collection_num[itemData.item_id] - 1;
        self.ScrollGrid:RemoveItem(index);
        self:HideAllDetailInfo();
    end
end

function StoreCollectionUI:OnReceivedCollectedJumpInfo()
    log("[HHF]StoreCollectionUI:OnReceivedCollectedJumpInfo");
    for k, v in pairs(self.arrayCollectedItemList) do
        v.source, v.source_addr = self:GetSourceInfoByItemID(v.item_id);
    end

    self.ScrollGrid:RefreshAllItems();
    local index = self.ScrollGrid:GetSelectIndex();
    if index > 0 then
        self:UpdateDetailInfo(nil, index);
    end
end

function StoreCollectionUI:OnDeadBoxRestore()
    log("[HHF]StoreCollectionUI:OnDeadBoxRestore, deadBoxTimer = " .. tostring(self.deadBoxTimer));
    if self.deadBoxTimer ~= nil then
        if self.deadBoxHandler ~= nil then
            self.deadBoxHandler:Destroy();
        end
        ModelDisplayer.Show();
        self.currentDisplayType = self.oldDisplayType;

        self:RemoveTimer(self.deadBoxTimer);
        self.deadBoxTimer = nil;
    end
end

function StoreCollectionUI:UpdateDetailInfo(widget, index)
    log("[HHF]StoreCollectionUI:UpdateDetailInfo");
    local itemData = self.ScrollGrid:GetItemData(index);

    self.UIRoot.StoreItem_DetailInfo_Logic_BP:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible);
    self.UIRoot.StoreItem_DetailInfo_Logic_BP:SetDetailInfo(
        itemData.item_name,
        itemData.item_quality,
        itemData.item_desc,
        itemData.item_id,
        itemData.item_storeDetailImage,
        StoreSystem.Page_ID_Collect, 0, 0, 0, 0);

    --[[
    if itemData.equiped == true then
        self.UIRoot.StoreItem_FeaturesLogic_BP:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible);
        self.UIRoot.StoreItem_FeaturesLogic_BP:SetData(itemData.item_id);
    else
        self.UIRoot.StoreItem_FeaturesLogic_BP:SetVisibility(UEnums.ESlateVisibility.Collapsed);
    end
    --]]

    self.UIRoot.buyPanel:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible);
    self:SetButtonTextBySource(self.UIRoot.source_text, itemData.source);

    self.UIRoot.collectPanel:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible);
    self.UIRoot.Store_Collection_Btn:SetData(true, itemData.collected_number);

    if self.currentDisplayType == ModelDisplayer.SHOWTYPE_NONE then
        local util = require("ui.util");
        if itemData.item_preview == "" then
            self.UIRoot.Image_bg:SetVisibility(UEnums.ESlateVisibility.Collapsed);
            self.UIRoot.Image_bg256:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible);
            util.SetTexture(self.UIRoot.Image_bg256, itemData.item_bigIcon);
        else
            self.UIRoot.Image_bg256:SetVisibility(UEnums.ESlateVisibility.Collapsed);
            self.UIRoot.Image_bg:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible);
            util.SetTexture(self.UIRoot.Image_bg, itemData.item_preview);
        end
    else
        self.UIRoot.Image_bg:SetVisibility(UEnums.ESlateVisibility.Collapsed);
        self.UIRoot.Image_bg256:SetVisibility(UEnums.ESlateVisibility.Collapsed);
    end

    itemData.reddot = StoreSystem.NeedShowReddotByItem(itemData.item_id);
    if widget ~= nil then
        if itemData.reddot == true then
            widget.Store_Fashion_Item_01_UIBP.Image_redDot:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible);
        else
            widget.Store_Fashion_Item_01_UIBP.Image_redDot:SetVisibility(UEnums.ESlateVisibility.Collapsed);
        end
    end
end

function StoreCollectionUI:SetButtonTextBySource(widget, source)
    log("[HHF]StoreCollectionUI:SetButtonTextBySource");
    if source == Enum_ItemSource.EnumPDD then
        widget:SetText(FuncUtil.GetLocalizeResStr(6777));
        self.UIRoot.buyButton:SetIsEnabled(true);
    elseif source == Enum_ItemSource.EnumDirect then
        widget:SetText(FuncUtil.GetLocalizeResStr(6787));
        self.UIRoot.buyButton:SetIsEnabled(true);
    elseif source == Enum_ItemSource.EnumStore then
        widget:SetText(FuncUtil.GetLocalizeResStr(6776));
        self.UIRoot.buyButton:SetIsEnabled(true);
    elseif source == Enum_ItemSource.EnumSupply then
        widget:SetText(FuncUtil.GetLocalizeResStr(6473));
        self.UIRoot.buyButton:SetIsEnabled(true);
    elseif source == Enum_ItemSource.EnumRP then
        widget:SetText(FuncUtil.GetLocalizeResStr(6472));
        self.UIRoot.buyButton:SetIsEnabled(true);
    elseif source == Enum_ItemSource.EnumNone then
        widget:SetText(FuncUtil.GetLocalizeResStr(6778));
        self.UIRoot.buyButton:SetIsEnabled(false);
    elseif source == Enum_ItemSource.EnumHave then
        widget:SetText(FuncUtil.GetLocalizeResStr(6483));
        self.UIRoot.buyButton:SetIsEnabled(false);
    end
end

function StoreCollectionUI:OnPostInitialize()
    StoreCollectionUI.__super.OnPostInitialize(self);

    --todo: OnPostInitialize在OnInitialize、RegistEvents之后，有需要在RegistEvents后初始化的工作写这里
    UIUtil.SetAdaptation(self.UIRoot.CanvasPanel_15);

    log("[HHF]StoreCollectionUI:OnPostInitialize, self.arrayCollectedItemList.length = " .. tostring(FuncUtil:CountTable(self.arrayCollectedItemList)));
    self.ScrollGrid:SetData(self.arrayCollectedItemList);

    self:HideAllDetailInfo();
    ModelDisplayer.SetShowtype(ModelDisplayer.SHOWTYPE_AVATAR);
    self.currentDisplayType = ModelDisplayer.SHOWTYPE_AVATAR;
    self.currentSex = MultipleAvatar.ShowingAvatarSextype;
    self.UIRoot.WidgetSwitcher_1:SetActiveWidgetIndex(0);
    self.UIRoot.Store_SexSwitchBtn_C_0:SetData(self.currentSex == LobbyAvatar.SEX_MALE, 0);
    self.UIRoot.BGM_Lobby:SetIsChecked(StoreSystem.GetNotifyCheckedState());

    if StoreCollectionWrappedUI.jump_info ~= nil then
        log("[HHF]StoreCollectionUI:OnPostInitialize, choose the itemID = " .. tostring(StoreCollectionWrappedUI.jump_info.itemId));
        for k, v in pairs(self.arrayCollectedItemList) do
            if v.item_id == StoreCollectionWrappedUI.jump_info.itemId then
                self:OnClickItem(nil, k);
                self.ScrollGrid:ScrollToItem(k);
                break;
            end
        end

        StoreCollectionWrappedUI.jump_info = nil;
    else
        log("[HHF]StoreCollectionUI:OnPostInitialize, choose the first one");
        if #self.arrayCollectedItemList > 0 then
            self:OnClickItem(nil, 1);
            self.ScrollGrid:ScrollToItem(1);
        end
    end
end

function StoreCollectionUI:HideAllDetailInfo()
    log("[HHF]StoreCollectionUI:HideAllDetailInfo");
    self.UIRoot.StoreItem_DetailInfo_Logic_BP:SetVisibility(UEnums.ESlateVisibility.Collapsed);
    --self.UIRoot.StoreItem_FeaturesLogic_BP:SetVisibility(UEnums.ESlateVisibility.Collapsed);
    self.UIRoot.buyPanel:SetVisibility(UEnums.ESlateVisibility.Collapsed);
    self.UIRoot.collectPanel:SetVisibility(UEnums.ESlateVisibility.Collapsed);
end

function StoreCollectionUI:OnShow()
    log("[HHF]StoreCollectionUI:OnShow");
end

function StoreCollectionUI:Close()
    log("[HHF]StoreCollectionUI:Close");
    --todo: 这里做些消耗回收动作，注意StoreCollectionUI.__super.Close(self)一定要写在最后，遵循先进后出原则

    StoreCollectionUI.__super.Close(self);
end

--界面隐藏时触发
function StoreCollectionUI:OnHide()
    log("[HHF]StoreCollectionUI:OnHide");

end

function StoreCollectionUI:UnRegistEvents()
    log("[HHF]StoreCollectionUI:UnRegistEvents");
    --todo: 在这里反注册事件

    StoreCollectionUI.__super.UnRegistEvents(self);
end

--仅在需要监听状态变化时写这个函数
function StoreCollectionUI:OnModeSwitch(preStatus, currentStatus)
    log("[HHF]StoreCollectionUI:OnModeSwitch");
end

local class = require("class");
local ui_base = require("ui.base");
local CStoreCollectionUI = class(ui_base, nil, StoreCollectionUI);

return CStoreCollectionUI;
