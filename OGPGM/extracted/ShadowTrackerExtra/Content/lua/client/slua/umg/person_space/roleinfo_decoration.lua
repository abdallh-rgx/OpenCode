local RoleInfoDecorationUI = {}
local RoleInfoDecorationUIStatic = {}
local RoleInfoDecorationSystem = require("client.slua.logic.person_space.logic_roleinfo_decoration")

--维护一份全局实例
function RoleInfoDecorationUIStatic.ShowUI()
    local ui_manager = require("ui.manager")
    if ui_manager then
        ui_manager.ShowUI(ui_manager.UI_Config.roleinfo_decoration)
        RoleInfoDecorationSystem.enter()
    end
end

function RoleInfoDecorationUIStatic.HideUI()
    local ui_manager = require("ui.manager")
    if ui_manager then
        ui_manager.CloseUI(ui_manager.UI_Config.roleinfo_decoration)
        RoleInfoDecorationSystem.leave()
    end
end


function RoleInfoDecorationUI:ctor(selfType, id)
    self.isOpenCollectAll = false
    self.isOpenDecorate = false
end

function RoleInfoDecorationUI:OpenCollectAll()

    log("RoleInfoDecorationUI:OpenCollectAll")
    self.isOpenCollectAll = true
    self:RefreshVisible()

    self:RefreshCollectStatus()

    self:PlayAudio(require("client.slua.config.sound").menu_open)
end

function RoleInfoDecorationUI:CloseCollectAll()

    log("RoleInfoDecorationUI:CloseCollectAll")
    self.isOpenCollectAll = false
    self:RefreshVisible()

    self:PlayAudio(require("client.slua.config.sound").menu_close)
end

function RoleInfoDecorationUI:RefreshVisible()

    local canSeeCollect = true
    if not RoleInfoSystem.IsSelf() then
        local roleData = ProfileMgr.GetRoleInfoDataByUid(RoleInfoSystem.CurShowPlayerInfoUid);
        if roleData then
            canSeeCollect = roleData.bshow
        end
    end

    self.UIRoot["HorizontalBox_0"]:SetVisibility(UIUtil.BoolToVisible(self.isOpenCollectAll))
    self.UIRoot["WidgetSwitcher_0"]:SetVisibility(UIUtil.BoolToVisible(canSeeCollect and not self.isOpenCollectAll))
    self.UIRoot["HorizontalBox_61"]:SetVisibility(UIUtil.BoolToVisible(not self.isOpenCollectAll))

    if self.WearScrollBox:GetSelectIndex() ~= 0 then
        local collectInfo = RoleInfoDecorationSystem.GetCollectInfo(self.WearScrollBox:GetSelectIndex())
        self.UIRoot["CanvasPanel_40"]:SetVisibility(UIUtil.BoolToVisible(not self.isOpenCollectAll and collectInfo.WearInfo.resID ~= 0))
    else
        self.UIRoot["CanvasPanel_40"]:SetVisibility(UIUtil.BoolToVisible(false))
    end
end

function RoleInfoDecorationUI:RefreshCollectStatus()
    local collectInfos = RoleInfoDecorationSystem.MakeCollectInfos()
    --local Lobby_RoleInfo_Wear_Item = slua.loadClass("/Game/UMG/UI_BP/RoleInfo/Lobby_RoleInfo_Wear_Item_01_UIBP.Lobby_RoleInfo_Wear_Item_01_UIBP");
    --self.UIRoot["ReuseList_C_0"]:Reload(#collectInfos, 110, 316, 2, Lobby_RoleInfo_Wear_Item, 0, 0)
    self.CollectScrollBox:SetData(collectInfos)
end


function RoleInfoDecorationUI:OnInitialize()
    RoleInfoDecorationUI.__super.OnInitialize(self)
    --self:RefreshWearItems()

    self.WearScrollBox = self:InitScrollBox(self.UIRoot["LoopScrollGrid_33"])

    self.CollectScrollBox = self:InitScrollBox(self.UIRoot["LoopScrollGrid_118"])

    UIUtil.SwitchSceneCameraByIndex(10004, 0)

    CoupleAvatarMgrUI.OpenAvatarInfo(false)

    self:RefreshButton()
end

function RoleInfoDecorationUI:RefreshButton()
    if RoleInfoSystem.IsSelf() then
        self.UIRoot["WidgetSwitcher_0"]:SetActiveWidgetIndex(self.isOpenDecorate and 2 or 1)
    else
        self.UIRoot["WidgetSwitcher_0"]:SetActiveWidgetIndex(0)
    end
end



function RoleInfoDecorationUI:RefreshAvatar()
    local basicInfo = RoleInfoSystem.PersonalBasicInfo

    --log_tree("basicInfo", basicInfo)
    self.UIRoot["Common_Avatar_BP_RoleInfo"]:InitView(3, basicInfo.role_id, basicInfo.role_image,
            tonumber(basicInfo.role_sex) + 1, basicInfo.role_avatar_frame, basicInfo.role_curlevelnum, false, "")

    self.UIRoot["TextBlock_PlayerNickName"]:SetText(basicInfo.role_name)
end

function RoleInfoDecorationUI:RefreshDes(collectInfo)
    local wearInfo = collectInfo.WearInfo

    self:RefreshVisible()

    if wearInfo and wearInfo.resID ~= 0 then
        local itemData = Client.GetTableData("Item", wearInfo.resID);
        local Switcher_bg = self.UIRoot["WidgetSwitcher_bg"]
        Switcher_bg:SetVisibility(UIUtil.BoolToVisible(itemData.ItemQuality >= 6))
        if itemData.ItemQuality == 6 then
            Switcher_bg:SetActiveWidgetIndex(0)
        elseif itemData.ItemQuality == 7 then
            Switcher_bg:SetActiveWidgetIndex(1)
        end
        self.UIRoot["TextBlock_Name"]:SetText(FuncUtil.GetItemName(itemData.ItemName, wearInfo.colorID, wearInfo.patternID))
        self.UIRoot["text_descript"]:SetText(itemData.ItemDesc)

        local tipsWidget = self.UIRoot["CanvasPanel_40"]

        if itemData.ItemDesc ~= "" then
            local HeightDiff = RoleInfoSystem.IsSelf() and 45 or 0

            tipsWidget.Slot:SetSize(FVector2D(190.0, 235.0 - HeightDiff))
        else
            local HeightDiff = RoleInfoSystem.IsSelf() and 52 or 0

            tipsWidget.Slot:SetSize(FVector2D(190.0, 95.0 - HeightDiff))
        end

        UIUtil.SetItemQuality(itemData.ItemQuality, self.UIRoot["qualityIcon"])

        self.UIRoot["WidgetSwitcher_1"]:SetActiveWidgetIndex(collectInfo.IsCollected and 1 or 0)

        self.UIRoot["WidgetSwitcher_1"]:SetVisibility(UIUtil.BoolToVisible(not RoleInfoSystem.IsSelf()))
        self.UIRoot["Line10"]:SetVisibility(UIUtil.BoolToVisible(not RoleInfoSystem.IsSelf()))
    end

end

function RoleInfoDecorationUI:OnCollectItemClicked(CollectItemWidget, idx)
    local collectInfo = self.CollectScrollBox:GetItemData(idx)
    collectInfo.IsSelected  = not collectInfo.IsSelected
    self:RefreshCollectSelect(CollectItemWidget, idx)
end

function RoleInfoDecorationUI:OnUpdateCollectItem(CollectItemWidget, idx)
   local collectInfo = self.CollectScrollBox:GetItemData(idx)
    local wearInfo = collectInfo.WearInfo
    self:UpdateWearItem(CollectItemWidget.Common_Item_All_UIBP, idx, wearInfo, true)

    self:RefreshCollectSelect(CollectItemWidget, idx)

    CollectItemWidget:SetIndex(idx)

    if wearInfo.resID == 0 then
        CollectItemWidget.TextBlock_0:SetText("")
    else
        local itemData = Client.GetTableData("Item", wearInfo.resID);
        CollectItemWidget.TextBlock_0:SetText(FuncUtil.GetItemName(itemData.ItemName, wearInfo.colorID, wearInfo.patternID))
        CollectItemWidget.TextBlock_2:SetVisibility(UIUtil.BoolToVisible(collectInfo.IsOwned))
        CollectItemWidget.TextBlock_3:SetVisibility(UIUtil.BoolToVisible(not collectInfo.IsOwned and collectInfo.IsCollected))
    end
end

function RoleInfoDecorationUI:RefreshCollectSelect(CollectItemWidget, idx)
    log("RefreshCollectSelect:" .. tostring(idx))
    local collectInfo = self.CollectScrollBox:GetItemData(idx)
    if collectInfo.IsOwned then
        CollectItemWidget.WidgetSwitcher_0:SetActiveWidgetIndex(1)
    else
        if collectInfo.IsSelected then
            CollectItemWidget.WidgetSwitcher_0:SetActiveWidgetIndex(0)
        else
            CollectItemWidget.WidgetSwitcher_0:SetActiveWidgetIndex(2)
        end
    end

end

function RoleInfoDecorationUI:OnWearItemClicked(itemWidget, index)
    local collectInfo = RoleInfoDecorationSystem.GetCollectInfo(index)

    if collectInfo.WearInfo.resID == 0 then
        return
    end

    self.WearScrollBox:Select(index)

    --if self.selectIndex ~= -1 then
    --
    --
    --    local item = self.UIRoot["ReuseList"]:GetItem(UIUtil.IndexLua2BP(self.selectIndex))
    --    if item then
    --        item:SetIsSelect(false)
    --    end
    --end
    --
    --self.selectIndex = idxInLua
    --
    --local item = self.UIRoot["ReuseList"]:GetItem(UIUtil.IndexLua2BP(self.selectIndex))
    --if item then
    --    item:SetIsSelect(true)
    --end

    self:RefreshDes(collectInfo)

    self:PlayAudio(require("client.slua.config.sound").click)
end

function RoleInfoDecorationUI:UpdateWearItem(CommonItemWidget, idx, wearInfo, isUseInCollcet)

    log("UpdateWearItem:" .. tostring(idx))

    CommonItemWidget:SetDefaultBg(true)
    if wearInfo.resID ~= 0 then
        local itemData = Client.GetTableData("Item", wearInfo.resID);
        CommonItemWidget:SetIconAndQuality(itemData.ItemQuality, itemData.ItemSmallIcon)
        CommonItemWidget:SetSpecialIcon(itemData.SpecialIcon)
    else
        CommonItemWidget:SetIconAndQuality(0, "")
    end

    CommonItemWidget:SetItemId(wearInfo.resID)
    CommonItemWidget:SetItemIndex(idx)


    if not isUseInCollcet then
        CommonItemWidget:SetIsSelect(self.WearScrollBox:GetSelectIndex() == idx)
    end
    -- test --
    --wearInfo.colorID = 1
    --wearInfo.patternID = 1
    --------------
    ---
    --log_tree("info", info)
    CommonItemWidget.Image_Tag1:SetVisibility(UIUtil.BoolToVisible(wearInfo.colorID ~= 0))
    if wearInfo.colorID ~= 0 then
        local ColorConfig = Client.GetTableData("DiySuitColorConfig", wearInfo.colorID);
        local color = FLinearColor(ColorConfig.ColorR / 255, ColorConfig.ColorG / 255, ColorConfig.ColorB / 255, 1)
        CommonItemWidget.Image_Tag1:SetColorAndOpacity(color)
    end

    CommonItemWidget.Image_Tag2:SetVisibility(UIUtil.BoolToVisible(wearInfo.patternID ~= 0))
    if wearInfo.patternID ~= 0 then
        local PatternConfig = Client.GetTableData("DiySuitPatternConfig", wearInfo.patternID);

        local texture = UIUtil.UIGetResWithPath(PatternConfig.Icon)

        local util = require("ui.util")
        util.SetTexture(CommonItemWidget.Image_Tag2, texture)
    end
end

function RoleInfoDecorationUI:OnUpdateWearItem(CommonItemWidget, idx)
    local wearInfo = self.WearScrollBox:GetItemData(idx)
    self:UpdateWearItem(CommonItemWidget, idx, wearInfo, false)
end

function RoleInfoDecorationUI:RegistEvents()
    RoleInfoDecorationUI.__super.RegistEvents(self)
    --todo: 在这里注册事件

    self:AddCommonEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_ROLEINFO, RoleInfoDecorationUI.UpdateRoleinfo, self);
    self:AddCommonEvent(EVENTTYPE_RANK, EVENTID_WARZONE_UPDATE_AVATAR, RoleInfoDecorationUI.UpdateAvatarRsp, self);
    self:AddCommonEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_ROLEWEAR_UPDATE, RoleInfoDecorationUI.RefreshRolewearIndexTab, self);
    self:AddCommonEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_COLLECT, RoleInfoDecorationUI.CollectRsp, self);
    self:AddCommonEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_ROLEINFO, RoleInfoDecorationUI.RefreshAvatar, self);
    self:AddCommonEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_SELECT_USE_PSPACE_ROLEWEAR_RSP, RoleInfoDecorationUI.select_use_pspace_rolewear_rsp, self);

    local tipsWidget = self.UIRoot["CanvasPanel_40"]
    tipsWidget:SetVisibility(UIUtil.BoolToVisible(false))

    --self:AddControlEvent("ReuseList", "OnUpdateItem", RoleInfoDecorationUI.OnUpdateWearItem, self)

    self.WearScrollBox:SetRefreshItemCallback(RoleInfoDecorationUI.OnUpdateWearItem, self)
    self.WearScrollBox:AddItemEvent("", "OnItemClicked", self.OnWearItemClicked, self)

    self:AddOnClickedEvent("Button_0", RoleInfoDecorationUI.OpenCollectAll, self)
    self:AddOnClickedEvent("Button_1", RoleInfoDecorationUI.DecorateClick, self)
    self:AddOnClickedEvent("Button_4", RoleInfoDecorationUI.DecorateBackClick, self)

    self:AddOnClickedEvent("Button_9", RoleInfoDecorationUI.CloseCollectAll, self)
    self:AddOnClickedEvent("Button_ok", RoleInfoDecorationUI.CollectAllClick, self)


    self.CollectScrollBox:SetRefreshItemCallback(RoleInfoDecorationUI.OnUpdateCollectItem, self)
    self.CollectScrollBox:AddItemEvent("", "OnSelectClicked", self.OnCollectItemClicked, self)

    --self:AddControlEvent("ReuseList_C_0", "OnUpdateItem", RoleInfoDecorationUI.OnUpdateCollectItem, self)

    self:AddOnClickedEvent("Button_2", RoleInfoDecorationUI.CollectOneClick, self) --收藏
    self:AddOnClickedEvent("Button_3", RoleInfoDecorationUI.CancelCollectOneClick, self) --取消收藏

    self:RegistRolewearIndexTab()
end

function RoleInfoDecorationUI:select_use_pspace_rolewear_rsp()
    self:RefreshVisible()
    self:RefreshWearItems()
end

function RoleInfoDecorationUI:CollectRsp()
    local collectInfos = RoleInfoDecorationSystem.MakeCollectInfos(true)
    if self.isOpenCollectAll then
        self:RefreshCollectStatus()
    end

    if self.WearScrollBox:GetSelectIndex() ~= 0 then
        local collectInfo = RoleInfoDecorationSystem.GetCollectInfo(self.WearScrollBox:GetSelectIndex())
        self:RefreshDes(collectInfo)
    end
end

function RoleInfoDecorationUI:CollectOneClick()
    if self.WearScrollBox:GetSelectIndex() ~= 0 then
        local wearInfos = RoleInfoDecorationSystem.MakeWearInfos()
        local info = wearInfos[self.WearScrollBox:GetSelectIndex()]
        StoreSystem.add_market_collect_by_item_req(info.resID, StoreSystem.market_collect_source_pspace)
    end

    self:PlayAudio(require("client.slua.config.sound").click)
end

function RoleInfoDecorationUI:CancelCollectOneClick()
    if self.WearScrollBox:GetSelectIndex() ~= 0 then
        local wearInfos = RoleInfoDecorationSystem.MakeWearInfos()
        local info = wearInfos[self.WearScrollBox:GetSelectIndex()]
        StoreSystem.cancel_market_collect_by_item_req(info.resID)
    end

    self:PlayAudio(require("client.slua.config.sound").click)
end

function RoleInfoDecorationUI:CollectAllClick()
    local collectInfos = RoleInfoDecorationSystem.MakeCollectInfos()

    local selectIds = {}
    for i, collectInfo in ipairs(collectInfos) do
        if collectInfo.IsSelected then
            table.insert(selectIds, collectInfo.WearInfo.resID)
        end
    end

    if #selectIds >= 1 then
        StoreSystem.batch_add_market_collect_req(selectIds, StoreSystem.market_collect_source_pspace)

        self:CloseCollectAll()
    else
        DataMgr.ShowNoticeByID(6849)
    end


    self:PlayAudio(require("client.slua.config.sound").confirm)
end

function RoleInfoDecorationUI:DecorateBackClick()
    self.isOpenDecorate = false
    self:RefreshBag()

    self:RefreshButton()

    self:PlayAudio(require("client.slua.config.sound").menu_open)
end

function RoleInfoDecorationUI:DecorateClick()
    self.isOpenDecorate = true

    self:RefreshBag()

    self:RefreshButton()

    self:PlayAudio(require("client.slua.config.sound").menu_open)
end


function RoleInfoDecorationUI:RefreshBag()
    self:SetWidgetVisible("RolewearIndexPanel", self.isOpenDecorate)
end

function RoleInfoDecorationUI:RegistRolewearIndexTab()
    local RolewearIndexTabs = self.UIRoot["CanvasPanel_9"]
    local count = RolewearIndexTabs:GetChildrenCount()
    for index = 0, count - 1 do
        self:AddControlEvent("RolewearIndexTab_UIBP_C_" .. index, "OnIndexTabClicked",function(index)

            local RolewearState = RoleInfoDecorationSystem.RolewearStateArr[index]
            if RolewearState ~= nil then
                if RolewearState == -2 or RolewearState > 0 then
                    -- 已开启，请求更换页签
                    RoleInfoDecorationSystem.select_use_pspace_rolewear(index)

                elseif RolewearState == -1 then --可以购买开启
                    DataMgr.ShowNoticeByID("6767");
                elseif RolewearState == -3 then  --RP满足条件可以开启
                    DataMgr.ShowNoticeByID("6767");
                elseif RolewearState == 0 and index == 4 and UnknowPassSystem.Season > 2 then
                    local unlockType = RoleInfoDecorationSystem.RolewearUnlockTypeArr[index];
                    if unlockType == 3 then --依赖RP物品解锁
                        --WardrobeUI.ShowRolewearRPPopup();
                        DataMgr.ShowNoticeByID("6768");
                    end

                else
                    DataMgr.ShowNoticeByID("116009");
                end
            else
                DataMgr.ShowNoticeByID("116009");
            end

            self:PlayAudio(require("client.slua.config.sound").click)
        end)
    end
end

function RoleInfoDecorationUI:RefreshRolewearIndexTab()
    log("RoleInfoDecorationUI:RefreshRolewearIndexTab")
    local RolewearIndexTabs = self.UIRoot["CanvasPanel_9"]
    local count = RolewearIndexTabs:GetChildrenCount()
    for index = 1, count do
        local child = RolewearIndexTabs:GetChildAt(index - 1)
        local isSelected = RoleInfoDecorationSystem.RolewearTabSelectIndex == index
        local state = RoleInfoDecorationSystem.RolewearStateArr[index]
        local unlockType = RoleInfoDecorationSystem.RolewearUnlockTypeArr[index]
        child:SetData(index, state, isSelected, RoleInfoDecorationSystem.RolewearCurrnetTimeStamp, unlockType)
        child.Button_RolewearAddTime:SetVisibility(UIUtil.BoolToVisible(false)) --个人空间内不显示+
        child.Image_add:SetVisibility(UIUtil.BoolToVisible(false)) --个人空间内不显示+
        child.Image_wenhao:SetVisibility(UIUtil.BoolToVisible(false)) --个人空间内不显示？
    end
end

function RoleInfoDecorationUI:RefreshWearItems()
    log("RoleInfoDecorationUI:RefreshWearItems")

    local wearInfos = RoleInfoDecorationSystem.MakeWearInfos()

    --local Common_Item_All_UIBP = slua.loadClass("/Game/UMG/UI_BP/Common/Common_Item_All_UIBP.Common_Item_All_UIBP");
    --self.UIRoot["ReuseList"]:Reload(#wearInfos, 85, 85, 2, Common_Item_All_UIBP, 0, 10)
    self.UIRoot["HorizontalBox_61"].Slot:SetPosition(FVector2D(11, 0))

    self.WearScrollBox:SetData(wearInfos)
end

--刷新外观提示
function RoleInfoDecorationUI:RefreshWearTips(isShow)

    local bShowTip = not RoleInfoSystem.IsSelf() and not isShow
    self.UIRoot["Canvas_Panel_No_Role"]:SetVisibility(UIUtil.BoolToVisible(bShowTip))

    self:RefreshVisible()
end

function RoleInfoDecorationUI:UpdateAvatarRsp(eventType, eventID, uid)
    if tonumber(uid) == tonumber(RoleInfoSystem.CurShowPlayerInfoUid) then
        local roleData = ProfileMgr.GetRoleInfoDataByUid(uid);
        if roleData == nil then
            return
        end

        if tonumber(uid) == tonumber(RoleInfoSystem.CurShowPlayerInfoUid) then
            self:RefreshWearTips(roleData.bshow)
        end

        self:RefreshWearItems()

        if tonumber(RoleInfoSystem.CurShowPlayerInfoUid) ~= tonumber(DataMgr.roleData.uid) then
            if tonumber(uid) == tonumber(RoleInfoSystem.CurShowPlayerInfoUid) and not roleData.bshow then
                return
            end
        end

        --log_tree("PersonSpaceMainUI.UpdateAvatar roleData", {roleData = SelectUID_roleData, IntimacyFriend_roleData = SelectUID_IntimacyFriend_roleData})
        CoupleAvatarMgrUI.UpdateAvatar(roleData)
    end
end

function RoleInfoDecorationUI:UpdateRoleinfo()
end

function RoleInfoDecorationUI:UnRegistEvents()
    --todo: 在这里反注册事件

    RoleInfoDecorationUI.__super.UnRegistEvents(self)
end

function RoleInfoDecorationUI:OnPostInitialize()
    RoleInfoDecorationUI.__super.OnPostInitialize(self)
    --todo: OnPostInitialize在OnInitialize、RegistEvents之后，有需要在RegistEvents后初始化的工作写这里
    UIUtil.SetAdaptation(self.UIRoot["IPX"])

    self:RefreshBag()

    RoleInfoSystem.get_profile_info_req(RoleInfoSystem.CurShowPlayerInfoUid)
end

function RoleInfoDecorationUI:Close()
    --todo: 这里做些消耗回收动作，注意UI_Template.__super.Close(self)一定要写在最后，遵循先进后出原则
    CoupleAvatarMgrUI.HideAvatars()
    RoleInfoDecorationUI.__super.Close(self)
end

--监听andriod返回键
function RoleInfoDecorationUI:AndriodBack()
    RoleInfoUI.HideUI(true)
end


local class = require("class")
local ui_base = require("ui.base")
local CRoleInfoDecorationUI = class(ui_base, RoleInfoDecorationUIStatic, RoleInfoDecorationUI)

return CRoleInfoDecorationUI