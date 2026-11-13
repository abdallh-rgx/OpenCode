local RoleInfoPopularityUI = {}
local RoleInfoPopularitySystem = require("client.slua.logic.person_space.logic_roleinfo_popularity")

local PopularityTabType = {
    ContriList = 1,
    RecentList = 2,
}

function RoleInfoPopularityUI:ctor(selfType, tabType)

    log("RoleInfoPopularityUI:ctor:" .. tostring(tabType))
    self.tabType = tabType or PopularityTabType.ContriList
end

function RoleInfoPopularityUI:OnInitialize()
    RoleInfoPopularityUI.__super.OnInitialize(self)

    self.ContriScrollBox = self:InitScrollBox(self.UIRoot["LoopScrollBox_0"])

    self.RecentScrollBox = self:InitScrollBox(self.UIRoot["LoopScrollBox_1"])
end

function RoleInfoPopularityUI:RefreshReddot()
    local isShowReddot = RoleInfoSystem.IsSelf() and RoleInfoPopularitySystem.IsShowReddot
    self.UIRoot["Image_RedDot"]:SetVisibility(UIUtil.BoolToVisible(isShowReddot))
end

function RoleInfoPopularityUI:RefreshUI()
    self.UIRoot["TextBlock_3"]:SetText(tostring(RoleInfoPopularitySystem.TotalPopularity))

    local isShow = RoleInfoSystem.IsSelf() or RoleInfoPopularitySystem.IsShowDetail
    self.UIRoot["CanvasPanel_1"]:SetVisibility(UIUtil.BoolToVisible(isShow))
    self.UIRoot["CanvasPanel_2"]:SetVisibility(UIUtil.BoolToVisible(not isShow))

    self:RefreshReddot()
    self:RefreshTap()
    self:RefreshPopularityItems()
end

function RoleInfoPopularityUI:RefreshTap()
    local CheckBox_ContriList = self.UIRoot["CheckBox_ContriList"]
    local CheckBox_RecentList = self.UIRoot["CheckBox_RecentList"]
    local TextBlock_ContriList = self.UIRoot["TextBlock_ContriList"]
    local TextBlock_RecentList = self.UIRoot["TextBlock_RecentList"]

    local blackColor = FSlateColor(FLinearColor(0.025187, 0.025187, 0.025187, 1))
    local whiteColor = FSlateColor(FLinearColor(1, 1, 1, 1))

    if self.tabType == PopularityTabType.ContriList then
        CheckBox_ContriList:SetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
        CheckBox_RecentList:SetVisibility(UEnums.ESlateVisibility.Visible)

        CheckBox_ContriList:SetIsChecked(true)
        CheckBox_RecentList:SetIsChecked(false)

        TextBlock_ContriList:SetColorAndOpacity(blackColor)

        TextBlock_RecentList:SetColorAndOpacity(whiteColor)
    else
        CheckBox_ContriList:SetVisibility(UEnums.ESlateVisibility.Visible)
        CheckBox_RecentList:SetVisibility(UEnums.ESlateVisibility.HitTestInvisible)

        CheckBox_ContriList:SetIsChecked(false)
        CheckBox_RecentList:SetIsChecked(true)

        TextBlock_ContriList:SetColorAndOpacity(whiteColor)
        TextBlock_RecentList:SetColorAndOpacity(blackColor)
    end
end


function RoleInfoPopularityUI:RegistEvents()
    RoleInfoPopularityUI.__super.RegistEvents(self)
    --todo: 在这里注册事件


    self:AddControlEvent("CheckBox_ContriList", "OnCheckStateChanged", function(IsChecked)
        log("self.tabType")
        if self.tabType == PopularityTabType.RecentList then
            if IsChecked then
                self.tabType = PopularityTabType.ContriList
                self:ClearPopularityItems()

                self:PopularityInfoReq()

                self:RefreshTap()

                local sound_config = require("client.slua.config.sound")
                self:PlayAudio(sound_config.switch);
            end
        end
    end);

    self:AddControlEvent("CheckBox_RecentList", "OnCheckStateChanged",function(IsChecked)
        log("self.tabType")
        if self.tabType == PopularityTabType.ContriList then
            if IsChecked then
                self.tabType = PopularityTabType.RecentList
                self:ClearPopularityItems()
                self:PopularityInfoReq()
                self:RefreshTap()

                if RoleInfoPopularitySystem.IsShowReddot and RoleInfoSystem.IsSelf() then
                    RoleInfoPopularitySystem.close_popularity_reddot_req()
                end

                local sound_config = require("client.slua.config.sound")
                self:PlayAudio(sound_config.switch);
            end
        end
    end)

    self:AddCommonEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_GET_POPULARITY_RSP, RoleInfoPopularityUI.GetPopularityRsp, self);
    self:AddCommonEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_GET_POPULARITY_DEVOTE_RANK_PROFILE, RoleInfoPopularityUI.RefreshUI, self);
    self:AddCommonEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_GET_POPULARITY_LAST_TREND_PROFILE, RoleInfoPopularityUI.RefreshUI, self);
    self:AddCommonEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_CLOSE_REDDOT_RSP, RoleInfoPopularityUI.RefreshReddot, self);
    self:AddCommonEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_PSPACE_SEND_GIFT_RSP, RoleInfoPopularityUI.GetPopularityRsp, self);



    self:AddOnClickedEvent("BtnClose", function()
        local ui_manager = require("ui.manager")
        if ui_manager then
            ui_manager.CloseUI(ui_manager.UI_Config.roleinfo_popularity)
        end
    end)

    self.ContriScrollBox:SetRefreshItemCallback(RoleInfoPopularityUI.OnUpdatePopularityItem, self)
    self.ContriScrollBox:AddItemEvent("Common_Avatar_BP_C_0", "OnClickItemCallback", self.OnClickItem, self)


    self.RecentScrollBox:SetRefreshItemCallback(RoleInfoPopularityUI.OnUpdatePopularityItem, self)
    self.RecentScrollBox:AddItemEvent("Common_Avatar_BP_C_0", "OnClickItemCallback", self.OnClickItem, self)



    self:AddOnClickedEvent("Button_0", function()
        local title = DataMgr.GetMsgByID(6827)
        local content = DataMgr.GetMsgByID(6826)
        PopUpNoticeUI.ShowMessageBox(title, content);

        --local content = FuncUtil.GetLocalizeResStr("6372")
        --PopUpNoticeUI.ShowMessageBox(title, content);
    end)

end


local  RoleInfoPopularityUI_Static = {}
function RoleInfoPopularityUI_Static.HideUI()
    local ui_manager = require("ui.manager")
    if ui_manager then
        ui_manager.CloseUI(ui_manager.UI_Config.roleinfo_popularity)
    end
end

function RoleInfoPopularityUI_Static.ShowUI(tabType)
    local ui_manager = require("ui.manager")
    if ui_manager then
        log("RoleInfoPopularityUI_Static:" .. tostring(tabType))
        ui_manager.ShowUI(ui_manager.UI_Config.roleinfo_popularity, tabType)
    end
end

--此界面是打开的话,如果收到这个回包,需要刷新profile
function RoleInfoPopularityUI:GetPopularityRsp()
    self:PopularityInfoReq()
end

function RoleInfoPopularityUI:OnUpdatePopularityItem(PopularityItem, idx)
    local info
    if self.tabType == PopularityTabType.ContriList then
        local infos = RoleInfoPopularitySystem.PopularityContriList
        info = infos[idx]
    else
        local infos = RoleInfoPopularitySystem.PopularityRecentList
        info = infos[idx]
    end
    log_tree("OnUpdatePopularityItem", info)

    if not info.sex then --没有获取到profile
        return
    end
    PopularityItem.Common_Avatar_BP_C_0:InitView(3, info.gid, info.picUrl,
            tonumber(info.sex) + 1, info.cur_avatar_box_id, info.level, false, "")

    if info.upass_is_show ~= 0  then
        PopularityItem.WidgetSwitcher_1:SetVisibility(UIUtil.BoolToVisible(true))
        PopularityItem.WidgetSwitcher_1:SetActiveWidgetIndex(info.upass_is_buy == 0 and 1 or 0)
    else
        PopularityItem.WidgetSwitcher_1:SetVisibility(UIUtil.BoolToVisible(false))
    end

    PopularityItem.PlayerName:SetText(info.nickName)
    PopularityItem.Common_RankIntegralLevel_Style_Small_UIBP_C_0:SetRankInteral(info.segment_info_max, PopularityItem.RankLevel)

    UIUtil.UpdateNationImage(PopularityItem.Image_11, info.roleNation)

    if self.tabType == PopularityTabType.ContriList then

        PopularityItem.WidgetSwitcher_0:SetActiveWidgetIndex(idx == 1 and 0 or 1)
        PopularityItem.TextBlock_0:SetText(tostring(idx))
        PopularityItem.TextBlock_2:SetText(tostring(idx ))

        PopularityItem.TextBlock_3:SetText(info.devote)
    else
        local date = os.date("!%Y/%m/%d %H:%M:%S", info.datetime);
        PopularityItem.TextBlock_0:SetText(date)
    end

end

function RoleInfoPopularityUI:OnClickItem(itemWidget, index, uid)
    log("OnClickItem:" .. tostring(uid) .. ",itemWidget:" .. tostring(itemWidget) .. ",index:" .. tostring(index))
    local levelUID = RoleInfoSystem.CurShowPlayerInfoUid

    local sound_config = require("client.slua.config.sound")
    self:PlayAudio(sound_config.click);
    --
    RoleInfoPopularityUI_Static.HideUI()

    RoleInfoUI.HideUI(false)

    RoleInfoSystem.Enter(uid)
    RoleInfoUI.Init(true, RoleInfoOpenFromType.PersonSpace, {uid = levelUID, IsShowPopularity = true, tabType = self.tabType})
end

function RoleInfoPopularityUI:ClearPopularityItems()
    if self.tabType == PopularityTabType.ContriList then
        self.ContriScrollBox:SetData({})
    else
        self.RecentScrollBox:SetData({})
    end
end

function RoleInfoPopularityUI:RefreshPopularityItems()
    log("RefreshPopularityItems:" .. tostring(self.tabType))
    if self.tabType == PopularityTabType.ContriList then
        local Infos = RoleInfoPopularitySystem.PopularityContriList


        self.ContriScrollBox:SelfHitTestInvisible()
        self.RecentScrollBox:Collapsed()

        self.ContriScrollBox:SetData(Infos)

        self.UIRoot["CanvasPanel_10"]:SetVisibility(UIUtil.BoolToVisible(#Infos == 0, false))
    else
        local Infos = RoleInfoPopularitySystem.PopularityRecentList

        self.ContriScrollBox:Collapsed()
        self.RecentScrollBox:SelfHitTestInvisible()

        self.RecentScrollBox:SetData(Infos)

        self.UIRoot["CanvasPanel_10"]:SetVisibility(UIUtil.BoolToVisible(#Infos == 0, false))
    end

end

function RoleInfoPopularityUI:UnRegistEvents()
    --todo: 在这里反注册事件
    RoleInfoPopularityUI.__super.UnRegistEvents(self)
end

function RoleInfoPopularityUI:PopularityInfoReq()

    local uid = RoleInfoPopularitySystem.CurrUid
    if self.tabType == PopularityTabType.ContriList then
        RoleInfoPopularitySystem.get_popularity_devote_rank_profile(uid)
    else
        RoleInfoPopularitySystem.get_popularity_last_trend_profile(uid)
    end
end


function RoleInfoPopularityUI:OnPostInitialize()
    RoleInfoPopularityUI.__super.OnPostInitialize(self)
    --todo: OnPostInitialize在OnInitialize、RegistEvents之后，有需要在RegistEvents后初始化的工作写这里
    self:ClearPopularityItems()
    self:RefreshTap()

    --self:RefreshUI()
    --self:PopularityInfoReq()
    RoleInfoPopularitySystem.get_popularity_req(RoleInfoPopularitySystem.CurrUid)
end

function RoleInfoPopularityUI:Close()
    self:ClearPopularityItems()

    --todo: 这里做些消耗回收动作，注意UI_Template.__super.Close(self)一定要写在最后，遵循先进后出原则
    RoleInfoPopularityUI.__super.Close(self)
end

local class = require("class")
local ui_base = require("ui.base")
local CRoleInfoPopularityUI = class(ui_base, RoleInfoPopularityUI_Static, RoleInfoPopularityUI)

return CRoleInfoPopularityUI