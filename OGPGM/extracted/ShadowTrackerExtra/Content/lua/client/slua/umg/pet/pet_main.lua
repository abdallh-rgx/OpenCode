--rain 宠物主界面
local PetSystem = require("client.slua.logic.pet.logic_pet")
local UI_Pet_Main = {}

function UI_Pet_Main:ctor()
    --当前选中的宠物
    self.bJustShowPet = true
    self.nCurPetID = 0
    self.nCurLevel = 1
    self.nCurPetActionID = 0
    self.nEatFoodCnt = 1
    self.timerEatFood = nil
    --self.ArrayPetList = {}
    self.ArrayActionList = {}
    self.BigPetModel = nil
end

function UI_Pet_Main:OnInitialize()
    UI_Pet_Main.__super.OnInitialize(self)

    UIUtil.SetAdaptation(self.UIRoot.CanvasPanel_Root);

    self.LSBActionList = self:InitScrollBox(self.UIRoot.LSBActionList)
    --self.LSBPetList = self:InitScrollBox(self.UIRoot.LSBPetList)
end

function UI_Pet_Main:RegistEvents()
    UI_Pet_Main.__super.RegistEvents(self)

    --todo: 在这里注册事件
    self:AddCommonEvent(EVENTTYPE_PET, EVENTID_PET_UnequipPet_Success, self.OnRspUnequipPet, self)
    self:AddCommonEvent(EVENTTYPE_PET, EVENTID_PET_EquipPet_Success, self.OnRspEquipPet, self)
    self:AddCommonEvent(EVENTTYPE_PET, EVENTID_PET_AddExp_Success, self.OnRspAddExp, self)
    self:AddCommonEvent(EVENTTYPE_PET, EVENTID_PET_Rename, self.OnRspRename, self)
    --self:AddCommonEvent(EVENTTYPE_PET, EVENTID_PET_Change, self.OnRspAddExp, self)


    self:AddOnClickedEvent("BtnHelp", self.OnClickedHelp, self);
    self:AddOnClickedEvent("Button_Close", self.OnClickedClose, self);
    self:AddOnClickedEvent("Btn_PetAccess", self.OnClickedPetAccess, self);
    self:AddOnClickedEvent("Btn_FoodAccess", self.OnClickedFoodAccess, self);

    self.LSBActionList:SetRefreshItemCallback(self.OnRefreshActionListItem, self)
    self.LSBActionList:AddItemEvent("Btn_PlayAction", "OnClicked", self.OnClickedActionItem, self)

    --self.LSBPetList:SetRefreshItemCallback(self.OnRefreshPetListItem, self)
    --self.LSBPetList:AddItemEvent("Btn_PetItem", "OnClicked", self.OnClickedPetItem, self)

    self:AddOnClickedEvent("Btn_EquipPet", self.OnClickedEquipPet, self)
    self:AddOnClickedEvent("Btn_UnequipPet", self.OnClickedUnequipPet, self)
    self:AddOnClickedEvent("BtnRename", self.OnClickedRename, self)
    self:AddOnClickedEvent("BtnChangeToSmallPet", self.OnClickedChangeCamera, self)
    self:AddOnClickedEvent("BtnChangeToBigPet", self.OnClickedChangeCamera, self)
    self:AddOnClickedEvent("BtnShare", self.OnClickShare, self)

    self:AddOnClickedEvent("Btn_EatFood", self.OnClickedFood, self)
    self:AddOnPressedEvent("Btn_EatFood", self.OnPressedFood, self)
    self:AddOnReleasedEvent("Btn_EatFood", self.OnReleasedFood, self)

    self:AddOnClickedEvent("Btn_CloseTips1", self.OnClickedCloseTips, self)
    self:AddOnClickedEvent("Btn_CloseTips2", self.OnClickedCloseTips, self)
end

function UI_Pet_Main:UnRegistEvents()
    --todo: 在这里反注册事件
    UI_Pet_Main.__super.UnRegistEvents(self)
end

function UI_Pet_Main:OnPostInitialize()
    UI_Pet_Main.__super.OnPostInitialize(self)

    --todo: OnPostInitialize在OnInitialize、RegistEvents之后，有需要在RegistEvents后初始化的工作写这里

end

function UI_Pet_Main:Close()
    --todo: 这里做些消耗回收动作，注意UI_Template.__super.Close(self)一定要写在最后，遵循先进后出原则
    UI_Pet_Main.__super.Close(self)
end

function UI_Pet_Main:OnClickedClose()
    self:PlayAudio(require("client.slua.config.sound").close);

    local ui_manager = require("ui.manager");
    if ui_manager then
        ui_manager.CloseUI(ui_manager.UI_Config.pet_main)
    end

    WardrobeSystem.Enter(false);
end

function UI_Pet_Main:OnShow()
    self:InitUI()
end

function UI_Pet_Main:OnHide()
    --恢复大厅UI
    EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE);
    LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "UIShowFromMall");

    LobbySceneManager.ShowMesh(LobbySceneManager.MALL_MESH_LobbyBgMesh)
    LobbySceneManager.ChangeLight(LobbySceneManager.LIGHT_LOBBY)
    --LobbySceneManager.VisiableObjectsByTag(LobbySceneManager.HIDE_FX, true)

    ModelDisplayer.Destroy()
    self.BigPetModel:Destroy()
end

function UI_Pet_Main:InitUI()
    self:InitScene()
    self:InitPetTips()
    self:InitPetList()
    self:UpdateCurPet()
    self:UpdateActionList()
end

function UI_Pet_Main:InitScene()
    LobbyCameraManager.SwitchCamera(10112)

    LobbySceneManager.ShowMesh(LobbySceneManager.MALL_MESH_Background_Pat_int)
    -- 隐藏大厅周边UI
    EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN);

    --LobbySceneManager.VisiableObjectsByTag(LobbySceneManager.HIDE_FX, false)
    LobbySceneManager.ChangeLight(LobbySceneManager.LIGHT_MALL_AVATAR);
    LobbySceneManager.ChangeMallSceneTexture("/Game/Arts_Scenes/Meshs/UI/Lobby_mesh/LBS/Lobby_pet.Lobby_pet");

    ModelDisplayer.Init()
    MultipleAvatar.CopyMyEquipments()

    MultipleAvatar.SetShowPosition(5, -383, -14347.0)
end

function UI_Pet_Main:InitPetTips()
    local str = GlobalData.GetLocalizeStringWithNum( 530019);
    self.UIRoot.Text_PetTips1:SetText(str)
    str = GlobalData.GetLocalizeStringWithNum( 530020);
    self.UIRoot.Text_PetTips2:SetText(str)
    str = GlobalData.GetLocalizeStringWithNum( 530021);
    self.UIRoot.Text_PetTips3:SetText(str)

    local PlayerPrefsSystem = require("client.tools.playerprefs")
    local table = PlayerPrefsSystem.LoadFileToTable(PlayerPrefsSystem.ePlayerPrefsType.ePetTips, true)
    if table == nil then
        self.UIRoot.CP_PetTips:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    else
        local NeedShowPetTips = table.NeedShowPetTips
        if NeedShowPetTips then
            self.UIRoot.CP_PetTips:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        else
            self.UIRoot.CP_PetTips:SetVisibility(UEnums.ESlateVisibility.Collapsed)
        end
    end

    table = {}
    table.NeedShowPetTips = false

    PlayerPrefsSystem.SaveTableToFile(table, PlayerPrefsSystem.ePlayerPrefsType.ePetTips, true)
    --self.UIRoot.CP_PetTips:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
end

--初始化右侧宠物列表
function UI_Pet_Main:InitPetList()
    if PetSystem.PetCfg == nil then
        log("UI_Pet_Main:InitPetList PetSystem.PetCfg = nil")
        return
    end

    --self.ArrayPetList = {}

    for i, v in pairs(PetSystem.PetCfg) do
        if self.nCurPetID == 0 then
            self.nCurPetID = v.PetID
        end
        --local PetItemData = {}
        --PetItemData.PetID = v.PetID
        --PetItemData.PetName = v.PetName

        --table.insert(self.ArrayPetList, PetItemData)
    end

    --self.LSBPetList:SetData(self.ArrayPetList)

    --新的UI交互 后面还会改 先暂时把宠物海报和出战状态的设置放在这里
    local curPetData = PetSystem.GetPetItemCfgByPetID(self.nCurPetID)
    if curPetData == nil then
        log("UI_Pet_Main:InitPetList curPetData is nil curPetID = " .. tostring(self.nCurPetID))
        return
    end

    if curPetData.PetImage == nil or curPetData.PetImage == ""then
        return
    end

    local util = require("ui.util")
    util.SetTexture(self.UIRoot.ImgPet, curPetData.PetImage)

    --品质样色
    local itemInfo = Client.GetTableData("Item", self.nCurPetID);
    if itemInfo ~= nil and itemInfo.ItemQuality > 0 then
        local path = string.format("/Game/UMG/Texture/Atlas/ItemLevelUI/Frames/T_item_icon_quality_%d_png.T_item_icon_quality_%d_png",
                itemInfo.ItemQuality - 1, itemInfo.ItemQuality - 1)

        util.SetTexture(self.UIRoot.ImgQuality1, path)
        util.SetTexture(self.UIRoot.ImgQuality2, path)
    end

    --宠物状态
    if PetSystem.IsPetEquip(self.nCurPetID) then
        self.UIRoot.CP_EquipIcon:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    else
        self.UIRoot.CP_EquipIcon:SetVisibility(UEnums.ESlateVisibility.Collapsed)
    end

    --出战Tips
    if PetSystem.bShowEquipTips then
        self.UIRoot.PetEquipTips:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        PetSystem.bShowEquipTips = false
    else
        self.UIRoot.PetEquipTips:SetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
end

function UI_Pet_Main:UpdateCurPet()
    log("UI_Pet_Main:UpdateCurPet curPetID: " .. tostring(self.nCurPetID))
    if self.nCurPetID == 0 then
        log("UI_Pet_Main:UpdateCurPet curPetID = 0")
        return
    end
    self:UpdateCurPetModel()
    self:UpdateCurPetInfo()
    self:UpdateCurPetBtn()
    self:UpdateCurPetFood()
end

function UI_Pet_Main:UpdateCurPetModel()
    if PetSystem.HasPet(self.nCurPetID) then
        local petData = PetSystem.GetPetDataByPetID(self.nCurPetID)
        local level = PetSystem.GetPetLevelByExp(petData.id, petData.exp)
        MultipleAvatar.CreatePet(self.nCurPetID, level)
    else
        MultipleAvatar.CreatePet(self.nCurPetID, 1)
    end

    if PetSystem.HasPet(self.nCurPetID) then
        local petData = PetSystem.GetPetDataByPetID(self.nCurPetID)
        local level = PetSystem.GetPetLevelByExp(petData.id, petData.exp)
        self.BigPetModel = LobbyPet.Create(self.nCurPetID, level)
    else
        self.BigPetModel = LobbyPet.Create(self.nCurPetID, 1)
    end

    self.BigPetModel:SetPosition(0, -434, 0)
    self.BigPetModel:SetRotation(0, 0, 90)

    local cfg = Client.GetTableData("PetActionTable",50001001);
    local scale = cfg.PetActionScale/100
    self.BigPetModel:SetScale(scale,scale,scale)
    self.BigPetModel:EnableRotation(true)

    self:UpdateCurCameraMode()
end

function UI_Pet_Main:UpdateCurPetInfo(bPlayLevelAnimation)
    local curPetData = PetSystem.GetPetItemCfgByPetID(self.nCurPetID)
    if curPetData == nil then
        log("UI_Pet_Main:UpdateCurPet curPetData is nil curPetID = " .. tostring(self.nCurPetID))
        return
    end

    --当前宠物名字
    local itemInfo = Client.GetTableData("Item", self.nCurPetID);
    if itemInfo ~= nil then
        self.UIRoot.Text_CurPetName:SetText(itemInfo.ItemName)
    end

    if not PetSystem.HasPet(curPetData.PetID) then
        self.UIRoot.BtnRename:SetVisibility(UEnums.ESlateVisibility.Collapsed)

        --没有当前宠物展示默认等级
        local curPetLevelData = PetSystem.GetPetLevelItemCfg(self.nCurPetID, 1)
        if curPetLevelData == nil then
            log("UI_Pet_Main:UpdateCurPetInfo curPetLevelData is nil curPetID = " .. tostring(self.nCurPetID))
            return
        end

        local strLevel = FuncUtil.LocalizeResFormat( "6417", 1);
        self.UIRoot.Text_CurPetLevel:SetText(strLevel)
        self.UIRoot.Text_AniCurPetLevel:SetText(strLevel)
        self.UIRoot.Text_CurPetExp:SetText("0/" .. tostring(curPetLevelData.PetNeedExp))
        self.UIRoot.ProgressBar_PetExp:SetPercent(0)
    else
        self.UIRoot.BtnRename:SetVisibility(UEnums.ESlateVisibility.Visible)

        local petData = PetSystem.GetPetDataByPetID(curPetData.PetID)
        if petData ~= nil then
            --更新名字
            if petData.name ~= nil then
                self.UIRoot.Text_CurPetName:SetText(petData.name)
            end
        end

        --记录当前等级，用于宠物升级时的一些动画表现
        local curLevel = PetSystem.GetPetLevelByExp(petData.id, petData.exp)
        self.nCurLevel = curLevel

        self:UpdatePetLevelAndExp(petData.id, petData.exp, bPlayLevelAnimation)
    end
end

--刷新等级与经验条
function UI_Pet_Main:UpdatePetLevelAndExp(petID, exp, bPlayLevelAnimation)
    local curPetData = PetSystem.GetPetItemCfgByPetID(self.nCurPetID)
    if curPetData == nil then
        log("UI_Pet_Main:UpdatePetLevelAndExp curPetData is nil petID = " .. tostring(petID))
        return
    end

    local level = PetSystem.GetPetLevelByExp(petID, exp)
    if level == curPetData.PetMaxLevel then
        local str = FuncUtil.LocalizeResFormat( "4608");
        self.UIRoot.Text_CurPetLevel:SetText(str)
        self.UIRoot.Text_AniCurPetLevel:SetText(str)
        self.UIRoot.Text_CurPetExp:SetVisibility(UEnums.ESlateVisibility.Collapsed)
    else
        local strLevel = FuncUtil.LocalizeResFormat( "6417", level);
        self.UIRoot.Text_CurPetLevel:SetText(strLevel)
        self.UIRoot.Text_AniCurPetLevel:SetText(strLevel)
        self.UIRoot.Text_CurPetExp:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    end

    local curLevelExp = PetSystem.GetCurLevelExp(petID, exp)
    local curLevel = PetSystem.GetPetLevelByExp(petID, exp)
    local curPetLevelData = PetSystem.GetPetLevelItemCfg(petID, curLevel)

    local strExp = FuncUtil.LocalizeResFormat( "6830", curLevelExp, curPetLevelData.PetNeedExp);
    self.UIRoot.Text_CurPetExp:SetText(strExp)

    local percent = 0
    if curPetLevelData.PetNeedExp > 0 then
        percent = curLevelExp / curPetLevelData.PetNeedExp
    end
    self.UIRoot.ProgressBar_PetExp:SetPercent(percent)

    --经验条动画
    local posX = -50 + percent * 170
    local pos = FVector2D()
    pos.X = posX
    pos.Y = -10

    if bPlayLevelAnimation then
        self.UIRoot.UIParticle_Exp.Slot:SetPosition(pos)
        self.UIRoot.UIParticle_Exp:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        self.UIRoot:PlayAnimation(self.UIRoot.ParticleEmiteer, 0, 1, 0, 1);
    else
        self.UIRoot.UIParticle_Exp:SetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
end

function UI_Pet_Main:UpdateCurCameraMode()
    if self.bJustShowPet then
        self.UIRoot.SwitcherCamera:SetActiveWidgetIndex(0)

        MultipleAvatar.HideAvatar()
        MultipleAvatar.StopPetAction()
        self.BigPetModel:SetPosition(0, -434, -14433)
    else
        self.UIRoot.SwitcherCamera:SetActiveWidgetIndex(1)

        MultipleAvatar.ShowAvatar()
        self.BigPetModel:SetPosition(0, -434, 0)
        self.BigPetModel:StopAction()
    end

    LobbyCameraManager.LeaveCloseupView()
end

function UI_Pet_Main:UpdateCurPetBtn()
    --卸下/出战按钮
    if PetSystem.HasPet(self.nCurPetID) then
        if PetSystem.IsPetEquip(self.nCurPetID) then
            self.UIRoot.Switcher_Equip:SetActiveWidgetIndex(0)
        else
            self.UIRoot.Switcher_Equip:SetActiveWidgetIndex(1)
        end
    else
        self.UIRoot.Switcher_Equip:SetActiveWidgetIndex(2)
    end
end

function UI_Pet_Main:UpdateCurPetFood()
    local curPetData = PetSystem.GetPetItemCfgByPetID(self.nCurPetID)
    if curPetData == nil then
        log("UI_Pet_Main:UpdateCurPet curPetData is nil curPetID = " .. tostring(self.nCurPetID))
        return
    end

    --获取/升级
    if PetSystem.HasPet(self.nCurPetID) then
        self.UIRoot.CP_PetEatFood:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)

        --食物增加的经验
        local addExp = PetSystem.GetAddExpByFoodID(curPetData.Foods[1])
        local strExp = FuncUtil.LocalizeResFormat( "6852", addExp);
        self.UIRoot.Text_ProvideExp:SetText(strExp)

        --是否有食物
        local foodWardrobeData = DataMgr.GetHallDepotItemDataByResID(curPetData.Foods[1])
        if foodWardrobeData == nil or foodWardrobeData.count == 0 then--没有食物则展示+号获取
            self.UIRoot.SwitcherFood:SetActiveWidgetIndex(1)

            local str = FuncUtil.LocalizeResFormat( "6883", 0);
            self.UIRoot.RichTextFoodCnt:SetText(str)
        else--有食物则展示食物
            self.UIRoot.SwitcherFood:SetActiveWidgetIndex(0)

            local str = FuncUtil.LocalizeResFormat( "6882", foodWardrobeData.count);
            self.UIRoot.RichTextFoodCnt:SetText(str)
        end
    else
        self.UIRoot.CP_PetEatFood:SetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
end

--刷新左侧宠物动作列表
function UI_Pet_Main:UpdateActionList(animationList)
    if PetSystem.PetActionCfg == nil then
        log("UI_Pet_Main:UpdateActionList PetSystem.PetActionCfg = nil")
        return
    end

    self.ArrayActionList = {}

    for i, v in pairs(PetSystem.PetActionCfg) do
        if self.nCurPetID == v.PetID then
            local actionItemData = {}
            actionItemData.PetID = v.PetID
            actionItemData.PetActionID = v.PetActionID
            actionItemData.NeedLevel = PetSystem.GetUnlockActionNeedLevel(v.PetID, v.PetActionID)
            actionItemData.PetActionIcon = v.PetActionIcon
            actionItemData.AnimationUnlock = false
            if animationList then
                for _, v in pairs(animationList) do
                    if v == tostring(actionItemData.PetActionID) then
                        actionItemData.AnimationUnlock = true
                    end
                end
            end
            table.insert(self.ArrayActionList, actionItemData)
        end
    end

    self.LSBActionList:SetData(self.ArrayActionList)
end

--[[
function UI_Pet_Main:OnRefreshPetListItem(widget, index)
    local itemData = self.LSBPetList:GetItemData(index)
    widget.Text_PetName:SetText(itemData.PetName)

    --宠物状态
    if PetSystem.IsPetEquip(itemData.PetID) then
        widget.Text_PetState:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    else
        widget.Text_PetState:SetVisibility(UEnums.ESlateVisibility.Collapsed)
    end

    --选中状态
    if itemData.PetID == self.nCurPetID then
        widget.Img_Selected:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    else
        widget.Img_Selected:SetVisibility(UEnums.ESlateVisibility.Collapsed)
    end

    --是否解锁
    if PetSystem.HasPet(itemData.PetID) then
        widget.Img_Lock:SetVisibility(UEnums.ESlateVisibility.Collapsed)
    else
        widget.Img_Lock:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    end

    --宠物图标Img_PetIcon
    local itemInfo = Client.GetTableData("Item", itemData.PetID);
    local BusinessHelper = import("BusinessHelper");
    local bg = BusinessHelper.UIGetResWithPath(itemInfo.ItemBigIcon)
    widget.Img_PetIcon:SetBrushFromTexture(bg, false);
end
--]]

function UI_Pet_Main:OnRefreshActionListItem(widget, index)
    local itemData = self.LSBActionList:GetItemData(index)

    --解锁所需等级
    local strLevel = FuncUtil.LocalizeResFormat( "6417", itemData.NeedLevel);
    widget.Text_NeedLevel:SetText(strLevel)

    --图标
    local util = require("ui.util")
    util.SetTexture(widget.ImgActionIcon, itemData.PetActionIcon)

    if PetSystem.IsActionUnLock(self.nCurPetID, itemData.PetActionID) then
        widget.CP_PetActionLock:SetVisibility(UEnums.ESlateVisibility.Collapsed)

        local white = FSlateColor(FLinearColor(0.2, 0.2, 0.2, 1))
        widget.Text_NeedLevel:SetColorAndOpacity(white)

        widget.ImgActionIcon:SetColorAndOpacity(FSlateColor(FLinearColor(1, 1, 1, 1)))
    else
        widget.CP_PetActionLock:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)

        local red = FSlateColor(FLinearColor(1, 0, 0, 1))
        widget.Text_NeedLevel:SetColorAndOpacity(red)

        widget.ImgActionIcon:SetColorAndOpacity(FSlateColor(FLinearColor(1, 1, 1, 0.3)))
    end

    --选中状态
    if itemData.PetActionID == self.nCurPetActionID then
        widget.ImgSelected:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    else
        widget.ImgSelected:SetVisibility(UEnums.ESlateVisibility.Collapsed)
    end

    --播放解锁动画
    if itemData.AnimationUnlock and (itemData.bPlayingUnlockAni == nil or itemData.bPlayingUnlockAni == false) then
        widget.AnimationUnLock:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        self.bPlayingUnlockAni = true
        widget:PlayAnimation(widget.unlock_ani, 0, 1, 0, 1);
        self.AddTimer(1.5, function()
            itemData.AnimationUnlock = false
            itemData.bPlayingUnlockAni = false
        end)
    end
    if itemData.AnimationUnlock == false then
        widget.AnimationUnLock:SetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
end

function UI_Pet_Main:OnRspUnequipPet()
    self.UIRoot.Switcher_Equip:SetActiveWidgetIndex(1)
    self.UIRoot.CP_EquipIcon:SetVisibility(UEnums.ESlateVisibility.Collapsed)
    --self.LSBPetList:RefreshAllItems(self.ArrayPetList)
end

function UI_Pet_Main:OnRspEquipPet(eventType, eventID, petID)
    if petID == self.nCurPetID then
        self.UIRoot.Switcher_Equip:SetActiveWidgetIndex(0)
        self.UIRoot.CP_EquipIcon:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        --self.LSBPetList:RefreshAllItems(self.ArrayPetList)
    end
end

function UI_Pet_Main:OnRspAddExp(eventType, eventID, petData)
    self:AddTimer(0, function()
        --检查是否升级，升级需要播放动画
        local curLevel = PetSystem.GetPetLevelByExp(petData.PetID, petData.PetExp)
        if curLevel > self.nCurLevel then
            local strLevel = FuncUtil.LocalizeResFormat( "6417", curLevel);
            self.UIRoot.Text_CurPetLevel:SetText(strLevel)
            self.UIRoot.Text_AniCurPetLevel:SetText(strLevel)
            self.UIRoot.ProgressBar_PetExp:SetPercent(1)

            local curPetLevelData = PetSystem.GetPetLevelItemCfg(petData.PetID, self.nCurLevel)
            local strExp = FuncUtil.LocalizeResFormat( "6830", curPetLevelData.PetNeedExp, curPetLevelData.PetNeedExp);
            self.UIRoot.Text_CurPetExp:SetText(strExp)

            --隐藏经验条粒子特效
            self.UIRoot.UIParticle_Exp:SetVisibility(UEnums.ESlateVisibility.Collapsed)

            coroutine.yield(0.4)
            --满经验条流光动画
            self.UIRoot.Img_ExpFull:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
            self.UIRoot:PlayAnimation(self.UIRoot.liuguang_ani, 0, 1, 0, 1);

            --等级Lv.X动画
            coroutine.yield(0.8)
            self.UIRoot.Img_LevelUpLight:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
            self.UIRoot:PlayAnimation(self.UIRoot.LV_ani, 0, 1, 0, 1);

            --Exp+XXX动画
            coroutine.yield(0.1)
            strExp = FuncUtil.LocalizeResFormat( "6852", petData.PetAddExp);
            self.UIRoot.TxtAddExp1:SetText(strExp)
            self.UIRoot.TxtAddExp2:SetText(strExp)
            self.UIRoot.CPAniAddExp:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
            self.UIRoot:PlayAnimation(self.UIRoot.Exp_ani, 0, 1, 0, 1);

            --动作解锁动画
            local curPetLevelData = PetSystem.GetPetLevelItemCfg(petData.PetID, curLevel)
            local oldPetLevelData = PetSystem.GetPetLevelItemCfg(petData.PetID, self.nCurLevel)

            local str = string.sub(curPetLevelData.AllAction, string.len(oldPetLevelData.AllAction) + 2, string.len(curPetLevelData.AllAction))
            local allAction = string.split(str, "|")

            local index = 1
            for i1, v1 in pairs(self.ArrayActionList) do
                for _, v2 in pairs(allAction) do
                    if tostring(v1.PetActionID) == v2 then
                        v1.AnimationUnlock = true
                        if index == 1 then
                            index = i1
                        end
                    end
                end
            end
            self.LSBActionList:ScrollToItem(index)

            --动画播放隐藏特效
            coroutine.yield(0.3)
            self.UIRoot.Img_LevelUpLight:SetVisibility(UEnums.ESlateVisibility.Collapsed)
            self.UIRoot.Img_ExpFull:SetVisibility(UEnums.ESlateVisibility.Collapsed)
            self.LSBActionList:RefreshAllItems(self.ArrayActionList)
        else
            --Exp+XXX动画
            local strExp = FuncUtil.LocalizeResFormat( "6852", petData.PetAddExp);
            self.UIRoot.TxtAddExp1:SetText(strExp)
            self.UIRoot.TxtAddExp2:SetText(strExp)
            self.UIRoot.CPAniAddExp:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
            self.UIRoot:PlayAnimation(self.UIRoot.Exp_ani, 0, 1, 0, 1);
        end

        self.nEatFoodCnt = 1
        self:UpdateCurPetInfo(true)
        self:UpdateCurPetFood()

        --隐藏经验条粒子特效
        self.UIRoot.UIParticle_Exp:SetVisibility(UEnums.ESlateVisibility.Collapsed)
    end)
end

function UI_Pet_Main:OnRspRename()
   self:UpdateCurPetInfo()
end

function UI_Pet_Main:OnClickedActionItem(widget, index)
    local itemData = self.LSBActionList:GetItemData(index)

    self.nCurPetActionID = itemData.PetActionID

    if self.bJustShowPet then
        self.BigPetModel:StopAction()
        self.BigPetModel:PlayAction(itemData.PetActionID)

        if itemData.PetActionID == 50001011 then
            self.BigPetModel:SetRotation(0, 0, 90)
            LobbyCameraManager.EnterCloseupViewPosition(2, 0, -434, -14438)
        else
            LobbyCameraManager.LeaveCloseupView()
        end
    else
        MultipleAvatar.StopPetAction()
        MultipleAvatar.PlayPetAction(itemData.PetActionID)
    end

    self.LSBActionList:RefreshAllItems(self.ArrayActionList)

    self:PlayAudio(require("client.slua.config.sound").click);

    ClientSendBAReport(BP_ENUM_MODULE_PET_PLAYACTION, 0);
end

--[[
function UI_Pet_Main:OnClickedPetItem(widget, index)
    local itemData = self.LSBPetList:GetItemData(index)
    self.nCurPetID = itemData.PetID
    self:UpdateCurPet()
    self:UpdateActionList()

    --选中状态
    widget.Img_Selected:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)

    self.LSBPetList:RefreshAllItems(self.ArrayPetList)
end
--]]

function UI_Pet_Main:OnClickedEquipPet()
    PetSystem.equip_pet_req(self.nCurPetID)
    self:PlayAudio(require("client.slua.config.sound").click);
end

function UI_Pet_Main:OnClickedUnequipPet()
    PetSystem.unequip_pet_req()
    self:PlayAudio(require("client.slua.config.sound").click);
end

function UI_Pet_Main:OnClickedPetAccess()
    --[[ 改成直接跳转，而不是打开获取途径界面
    local ui_manager = require("ui.manager");
    if ui_manager then
        ui_manager.ShowUI(ui_manager.UI_Config.pet_access)
        ui_manager.GetUI(ui_manager.UI_Config.pet_access):SetData(self.nCurPetID, 0, PetSystem.Enum_AccessType.EnumPet)
    end
    --]]
    local ui_manager = require("ui.manager");
    if ui_manager then
        ui_manager.CloseUI(ui_manager.UI_Config.pet_access)
        ui_manager.HideUI(ui_manager.UI_Config.pet_main)
    end

    local curPetData = PetSystem.GetPetItemCfgByPetID(self.nCurPetID)
    if curPetData == nil then
        log("UI_Pet_Access:InitAccessList curPetData is nil curPetID = " .. tostring(self.nCurPetID))
        return
    end

    if curPetData.JumpType == PetSystem.Enum_PetJumpType.EnumJumpToStore then
        JumpUtils.JumpAll(JumpUtils.MODEL_ID_PET, curPetData.PetID)
    elseif curPetData.JumpType == PetSystem.Enum_PetJumpType.EnumJumpToSupply then
        JumpUtils.JumpAll(JumpUtils.MODEL_ID_PET, curPetData.PetID)
    else
        StoreFuncUtils.Jump(curPetData.JumpUrl)
    end

    self:PlayAudio(require("client.slua.config.sound").click);
end

function UI_Pet_Main:OnClickedFoodAccess()
    local curPetData = PetSystem.GetPetItemCfgByPetID(self.nCurPetID)
    if curPetData == nil then
        log("UI_Pet_Main:UpdateCurPet curPetData is nil curPetID = " .. tostring(self.nCurPetID))
        return
    end

    local ui_manager = require("ui.manager");
    if ui_manager then
        ui_manager.ShowUI(ui_manager.UI_Config.pet_access)
        ui_manager.GetUI(ui_manager.UI_Config.pet_access):SetData(self.nCurPetID, curPetData.Foods[1], PetSystem.Enum_AccessType.EnumFood)
    end

    self:PlayAudio(require("client.slua.config.sound").click);
end


function UI_Pet_Main:OnClickedFood()
    if self.nEatFoodCnt == 1 then
        local curPetData = PetSystem.GetPetItemCfgByPetID(self.nCurPetID)
        if curPetData == nil then
            log("UI_Pet_Main:UpdateCurPet curPetData is nil curPetID = " .. tostring(self.nCurPetID))
            return
        end

        PetSystem.pet_add_exp_req(self.nCurPetID, curPetData.Foods[1],1)
        self:PlayAudio(require("client.slua.config.sound").click);

    end
end

function UI_Pet_Main:OnPressedFood()
    self.nEatFoodCnt = 1
    self.timerEatFood = self:AddTimer(0.8, function ()
        local petData = PetSystem.GetPetDataByPetID(self.nCurPetID)
        if petData == nil then
            log("UI_Pet_Main:OnPressedFood petData is nil curPetID = " .. tostring(self.nCurPetID))
            return
        end
        local petCfg = PetSystem.GetPetItemCfgByPetID(self.nCurPetID)
        if petCfg == nil then
            log("UI_Pet_Main:OnPressedFood petCfg is nil curPetID = " .. tostring(self.nCurPetID))
            return
        end
        while true do
            coroutine.yield(0.05)
            --一次最多吃100个
            if self.nEatFoodCnt >= 99 then
                PetSystem.pet_add_exp_req(self.nCurPetID, petCfg.Foods[1], self.nEatFoodCnt)
                self.nEatFoodCnt = 0
                return
            end

            --判断粮食是否足够
            local foodWardrobeData = DataMgr.GetHallDepotItemDataByResID(petCfg.Foods[1])
            if foodWardrobeData == nil or foodWardrobeData.count == self.nEatFoodCnt then
                PetSystem.pet_add_exp_req(self.nCurPetID, petCfg.Foods[1], self.nEatFoodCnt)
                self.nEatFoodCnt = 0
                return
            end

            local addExp = PetSystem.GetAddExpByFoodID(petCfg.Foods[1])

            local oldExp = petData.exp + (self.nEatFoodCnt - 1) * addExp
            local oldLevel = PetSystem.GetPetLevelByExp(self.nCurPetID, oldExp)

            local exp = petData.exp + self.nEatFoodCnt * addExp
            local newLevel = PetSystem.GetPetLevelByExp(self.nCurPetID, exp)
            -- 判断是否升级
            if newLevel > oldLevel then
                PetSystem.pet_add_exp_req(self.nCurPetID, petCfg.Foods[1], self.nEatFoodCnt)
                self.nEatFoodCnt = 0
                return
            end

            if newLevel == petCfg.PetMaxLevel then
                local str = FuncUtil.LocalizeResFormat( "4608");
                self.UIRoot.Text_CurPetLevel:SetText(str)
                self.UIRoot.Text_AniCurPetLevel:SetText(str)
                self.UIRoot.Text_CurPetExp:SetVisibility(UEnums.ESlateVisibility.Collapsed)

                PetSystem.pet_add_exp_req(self.nCurPetID, petCfg.Foods[1], self.nEatFoodCnt)
                self.nEatFoodCnt = 0
                return
            else
                self.UIRoot.Text_CurPetExp:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)

                self.nEatFoodCnt = self.nEatFoodCnt + 1
                local str = FuncUtil.LocalizeResFormat( "6882", foodWardrobeData.count - self.nEatFoodCnt);
                self.UIRoot.RichTextFoodCnt:SetText(str)

                self:UpdatePetLevelAndExp(petData.id, exp, true)
            end

            self:PlayAudio(require("client.slua.config.sound").click);
        end
    end)
end

function UI_Pet_Main:OnReleasedFood()
    self:RemoveTimer(self.timerEatFood)

    if self.nEatFoodCnt <= 1 then
        return
    end

    local petCfg = PetSystem.GetPetItemCfgByPetID(self.nCurPetID)
    if petCfg == nil then
        log("UI_Pet_Main:OnPressedFood petCfg is nil curPetID = " .. tostring(self.nCurPetID))
        return
    end

    local foodWardrobeData = DataMgr.GetHallDepotItemDataByResID(petCfg.Foods[1])
    if self.nEatFoodCnt > foodWardrobeData.count then
        self.nEatFoodCnt = foodWardrobeData.count
    end
    PetSystem.pet_add_exp_req(self.nCurPetID, petCfg.Foods[1], self.nEatFoodCnt)
end

function UI_Pet_Main:OnClickedChangeCamera()
    self.bJustShowPet = not self.bJustShowPet
    self:UpdateCurCameraMode()

    self:PlayAudio(require("client.slua.config.sound").click);
end

function UI_Pet_Main:OnClickedRename()
    local ui_manager = require("ui.manager");
    if ui_manager then
        ui_manager.ShowUI(ui_manager.UI_Config.pet_rename)
        ui_manager.GetUI(ui_manager.UI_Config.pet_rename):SetData(self.nCurPetID)
    end

    self:PlayAudio(require("client.slua.config.sound").click);
end

function UI_Pet_Main:OnClickShare()
    local ui_manager = require("ui.manager")
    if ui_manager then
        ui_manager.ShowUI(ui_manager.UI_Config.pet_share)
        ui_manager.GetUI(ui_manager.UI_Config.pet_share):SetData(self.nCurPetID)
    end

    self:PlayAudio(require("client.slua.config.sound").click);
end

function UI_Pet_Main:OnClickedHelp()
    local title = Client.GetTableData("LocalizeRes", 6067).TextValue
    local context = Client.GetTableData("LocalizeRes", 530015).TextValue
            ..Client.GetTableData("LocalizeRes", 530016).TextValue
            ..Client.GetTableData("LocalizeRes", 530017).TextValue
            ..Client.GetTableData("LocalizeRes", 530018).TextValue

    context = string.gsub(context, "\\n", "\n")
    PopUpNoticeUI.ShowMessageBox(title, context)

    self:PlayAudio(require("client.slua.config.sound").click);
end

function UI_Pet_Main:OnClickedCloseTips()
    self.UIRoot.CP_PetTips:SetVisibility(UEnums.ESlateVisibility.Collapsed)
end

local class = require("class")
local ui_base = require("ui.base")
local CUIPet_Main = class(ui_base, nil, UI_Pet_Main)

return CUIPet_Main