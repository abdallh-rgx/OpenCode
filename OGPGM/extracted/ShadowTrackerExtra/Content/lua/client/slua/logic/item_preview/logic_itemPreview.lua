local ItemPrewViewSystem = 
{
    
};
local function HandleAvatar(itemID)
    local WearingInfo = {}
    for i, v in pairs(DataMgr.rolewear) do
        local cfg = DataMgr.GetHallDepotItemDataByInsID(v)
        local ThisWearing = { itemID = cfg.resID,colorID = 0,patternID = 0 }
        table.insert(WearingInfo, ThisWearing)
    end

    local bagID = WardrobeUI:GetEquipmentItemIDBySkinInsID(DataMgr.BagSkinTableIndex, DataMgr.equipmentSkinInsIDTable[DataMgr.BagSkinTableIndex])
    local bagInfo = {itemID = bagID,colorID = 0,patternID = 0 };
    local helmetID = WardrobeUI:GetEquipmentItemIDBySkinInsID(DataMgr.HelmetSkinTableIndex, DataMgr.equipmentSkinInsIDTable[DataMgr.HelmetSkinTableIndex]);
    local helmetInfo = {itemID = helmetID,colorID = 0,patternID = 0 };
    table.insert(WearingInfo, bagInfo);
    table.insert(WearingInfo, helmetInfo);


    ModelDisplayer.Init(WearingInfo)
    ModelDisplayer.Display(itemID, 0, 0, true);

    if ModelDisplayer.GetShowtype() == ModelDisplayer.SHOWTYPE_MODEL then
    EditorRuntime.ShowMallFullScreen(itemID, 10108, 0)
    end

    local itemCfg = Client.GetTableData("Item", itemID);

    if itemCfg.ItemType == 1 then

        ItemPrewViewSystem.ChangeToWeapon(itemID);
    elseif itemCfg.ItemType == 22 then
        --LobbyUI:ShowEmoteAction(DataMgr.roleData.uid, itemID, nil, nil, 1);
        LobbyUI.PlayEmotionSound(itemID, DataMgr.roleData.gender, nil, DataMgr.roleData.uid, 1)
    end

    if itemCfg.RedEmotionId ~= 0 then
        ModelDisplayer.Display(itemCfg.RedEmotionId, 0, 0, true);
        LobbyUI.PlayEmotionSound(itemCfg.RedEmotionId, DataMgr.roleData.gender, nil, DataMgr.roleData.uid, 1)
    end

    MultipleAvatar.SetShowPosition(25, -383, -14350)
    end

function ItemPrewViewSystem.PlayAnimation(itemID)
    log("OpenItemPreviewPanel")
    local isShow = ItemPrewViewSystem.IsNeedShow(itemID);
    if not isShow then
        return;
    end
    EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN);
    LobbyCameraManager.SwitchCamera(10108);
    LobbySceneManager.ShowMesh(LobbySceneManager.MALL_MESH_LobbyBgMesh);
    LobbySceneManager.ChangeMallSceneMaterial(11)
    LobbySceneManager.ChangeLight(LobbySceneManager.LIGHT_MALL_AVATAR)
    LuaClassObj.HandleDynamicCreation(bp_createrole);

    local widget = UIUtil.GetWidgetByName("bp_createrole", "Lobby_AvatarAnim_UIBP")
    widget:UIShowFromItemPreview(true, itemID);
end

function ItemPrewViewSystem.OpenItemPreviewPanel(itemID)
    HandleAvatar(itemID)
    local ui_manager = require("ui.manager");
    if ui_manager then
        ItemPrewViewSystem.isShow = true;
        ui_manager.ShowUI(ui_manager.UI_Config.itempreview_panel, itemID)
    end
end

function ItemPrewViewSystem.CloseItemPreviewPanel()
    local ui_manager = require("ui.manager");
    if ui_manager then
        ItemPrewViewSystem.isShow = false;
        ui_manager.CloseUI(ui_manager.UI_Config.itempreview_panel)
    end
end

function ItemPrewViewSystem.ChangeToWeapon(itemID)
    log("ChangeToWeapon ")
    ModelDisplayer.SetShowtype(ModelDisplayer.SHOWTYPE_WEAPON_MODEL);
    EditorRuntime.ShowMallFullScreen(itemID, 10108, 0)
end

function ItemPrewViewSystem.ChangeToAvatar()
    log("ChangeToAvatar")
    ModelDisplayer.SetShowtype(ModelDisplayer.SHOWTYPE_AVATAR);
    LobbyCameraManager.SwitchCamera(10108)
end

function ItemPrewViewSystem.ChangeSex()
    MultipleAvatar.SwitchSex()
end

function ItemPrewViewSystem.IsNeedShow(itemID)

    local isShow = false;
    local itemCfg = Client.GetTableData("Item", itemID);
    if itemCfg == nil then
        return isShow;
    end
    if itemCfg.ItemType == 1 or itemCfg.ItemType == 4 or itemCfg.ItemType == 9 then
        isShow = true;
    end

    if itemCfg.ItemType == 5 and itemCfg.ItemSubType == 504 then
        isShow = true;
    end

    if itemCfg.ItemType == 5 and itemCfg.ItemSubType == 505 then
        isShow = true;
    end

    if itemCfg.ItemType == 8 and itemCfg.ItemSubType == 801 then
        isShow = true;
    end

    if itemCfg.ItemType == 22 then
        isShow = true;
    end

    if itemCfg.ItemType == 500 then
        isShow = true;
    end

    return isShow;
    
end
return ItemPrewViewSystem;