--[[
    武器模型操作接口
]]

MallSystemWeaponModelHandler = MallSystemWeaponModelHandler or
{
	isInit = false;
}

-- 当前展示中的武器id
BP_MallWeapon_Cur_Show_Weapon_Resid = 0
BP_MallWeapon_Cur_Show_Weapon_Skin = false
BP_MallWeapon_Cur_Show_Weapon_Need_ResetRotation = false
BP_MallWeapon_Cur_Show_Weapon_Need_Offset = false;
BP_MallWeapon_Cur_Show_Need_X_rotation = true

BP_MallWeapon_Cur_Show_Extra_X_Offset = 0 --额外的X 方向Offset
BP_MallWeapon_Cur_Show_Extra_Z_Offset = 0 --额外的Y 方向Offset

BP_MallWeapon_Cur_Show_Weapon_Need_AutoRotate = false
    
BP_MallWeapon_Cur_Show_Weapon_Need_RotateBack = false

-- 当前装配/卸下配件id
BP_MallWeapon_Cur_Equipment_Resid = 0

BP_Array_MallWeapon_PutOnEquipment_Resid_List = 
{
    0,
}

BP_MallWeapon_isRecommend = false

BP_MallWeapon_CameraId = 0

BP_MallWeapon_HasEditorConfig = false

BP_Array_MallWeapon_AdaptPosition = {
    0,
}

local _isForceResetRotation = false

--注册Widget bp_mall_weapon_model_handler
function bp_mall_weapon_model_handler_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_mall_weapon_model_handler,
        {{Path="/Game/UMG/UI_Logic/Lobby_Store/Mall_Weapon_Model_Handler_BP.Mall_Weapon_Model_Handler_BP_C", Container="Default", ZOrder=0}},
        {"Lobby"},
        false,
        false,
        true
    );
end

function MallSystemWeaponModelHandler:Init()
	if MallSystemWeaponModelHandler.isInit == false then
		log("MallSystemWeaponModelHandler:Init()")
		LuaClassObj.HandleDynamicCreation(bp_mall_weapon_model_handler);
		LuaClassObj.HandleUIMessage(bp_mall_weapon_model_handler, "MallWeaponModelHandlerInit");
		MallSystemWeaponModelHandler.isInit = true;
	else
		log("MallSystemWeaponModelHandler has been inited")
	end
    
end

-- 删除武器展示Actor
function MallSystemWeaponModelHandler:DestroyWeaponShowActor()
    BP_MallWeapon_Cur_Show_Weapon_Resid = nil
    _isForceResetRotation = false
	MallSystemWeaponModelHandler.isInit = false;
    log("MallSystemWeaponModelHandler:DestroyWeaponShowActor()")
    LuaClassObj.HandleUIMessage(bp_mall_weapon_model_handler, "DestroyMallWeaponShowActor");
end

function MallSystemWeaponModelHandler:SetForceResetRotation(isForce)
    _isForceResetRotation = isForce
end

function MallSystemWeaponModelHandler.GetShowingId()
    return BP_MallWeapon_Cur_Show_Weapon_Resid
end

function MallSystemWeaponModelHandler.SetCameraID(id)
    BP_MallWeapon_CameraId = id
end

-- 创建或切换武器
function MallSystemWeaponModelHandler:ShowWeaponByResId(resId, isSkin, needResetRotation, needOffset, needAutoRotate, needRotateBack, ExtraXOffset, ExtraZOffset)
    log("MallSystemWeaponModelHandler:ShowWeaponByResId : "..tostring(resId)..tostring(isSkin)..tostring(needResetRotation))
    log("MallSystemWeaponModelHandler:ShowWeaponByResId BP_MallWeapon_Cur_Show_Weapon_Resid : "..tostring(BP_MallWeapon_Cur_Show_Weapon_Resid))
    if resId == nil or resId == 0 then
        log("MallSystemWeaponModelHandler:ShowWeaponByResId Invalid Resid")
        return
    end
    
    --if resId == BP_MallWeapon_Cur_Show_Weapon_Resid then
    --    log("MallSystemWeaponModelHandler:ShowWeaponByResId Resid is Same to old!")
    --    return
    --end

    BP_MallWeapon_Cur_Show_Weapon_Skin = isSkin or false
    BP_MallWeapon_Cur_Show_Weapon_Need_ResetRotation = needResetRotation or false
	--BP_MallWeapon_Cur_Show_Weapon_Need_ResetRotation = true;
    BP_MallWeapon_Cur_Show_Weapon_Resid = resId
    BP_MallWeapon_Cur_Show_Weapon_Need_Offset = needOffset or false;

    BP_MallWeapon_Cur_Show_Weapon_Need_AutoRotate = needAutoRotate or false

    BP_MallWeapon_Cur_Show_Weapon_Need_RotateBack = needRotateBack or false
    if _isForceResetRotation == true then
        BP_MallWeapon_Cur_Show_Weapon_Need_RotateBack = true
    end

    BP_MallWeapon_Cur_Show_Extra_X_Offset = ExtraXOffset or 0

    BP_MallWeapon_Cur_Show_Extra_Z_Offset = ExtraZOffset or 0

    BP_MallWeapon_isRecommend = false
    -- BP_MallWeapon_CameraId = 10108

    if UIManager.GetUI(eUIType.eItemUpgrade) == nil then
    if StoreSystem.IsUseNewStore() then
            --if StoreMainUI.bShow == true or MallEditorUI.isShowing == true or SupplyMainUI.bShow == true then
            if UIManager.GetUI(eUIType.eSupplyMainUI) ~= nil or MallEditorUI.isShowing == true or UIManager.GetUI(eUIType.eStoreMainUI) ~= nil then
            BP_MallWeapon_Cur_Show_Extra_X_Offset = 0
            BP_MallWeapon_isRecommend = true
            -- BP_MallWeapon_CameraId = 10112;
        end
    else
        if MallRecommendUI.isShowing == true or MallEditorUI.isShowing == true then
            BP_MallWeapon_Cur_Show_Extra_X_Offset = 0
            BP_MallWeapon_isRecommend = true
            -- BP_MallWeapon_CameraId = 10112
            end
        end
    end
    
    log("BP_MallWeapon_CameraId "..BP_MallWeapon_CameraId)
    BP_MallWeapon_Cur_Show_Need_X_rotation = true

    -- for editor scale by the old code crash
    BP_MallWeapon_HasEditorConfig = false
    local editorConfig = EditorRuntime.GetAdaptConfig(resId, BP_MallWeapon_CameraId)
    if editorConfig ~= nil then
        BP_MallWeapon_HasEditorConfig = true

        BP_Array_MallWeapon_AdaptPosition = {
            0, 0, 0, 
            0, 0, 0, 
            editorConfig.modelsx, editorConfig.modelsy, editorConfig.modelsz
        }

        LuaClassObj.HandleUIMessageNoFetch(bp_mall_weapon_model_handler, "SetAdaptModelScale")
    end

    log("MallSystemWeaponModelHandler:ShowWeaponByResId : after"..tostring(BP_MallWeapon_Cur_Show_Weapon_Resid)..tostring(BP_MallWeapon_Cur_Show_Weapon_Skin)..tostring(BP_MallWeapon_Cur_Show_Weapon_Need_ResetRotation))
    LuaClassObj.HandleUIMessage(bp_mall_weapon_model_handler, "ShowWeaponByResId");
    
    -- VSS 装四倍
    --if resId == VSS_Item_Id then
        --MallSystemWeaponModelHandler:PutonEquipmentByResId(VSS_Sight_Item_Id)
    --end

    EditorRuntime.ShowMallModelAdapt(resId, BP_MallWeapon_CameraId)
    MallSystemWeaponModelHandler.ShowDebug(false)
end

function MallSystemWeaponModelHandler:HideWeapon()
    MallSystemWeaponModelHandler.SetPosition(0, 0, 0)
end

function MallSystemWeaponModelHandler:ShowWeapon()
    EditorRuntime.ShowMallModelAdapt(BP_MallWeapon_Cur_Show_Weapon_Resid, BP_MallWeapon_CameraId)
end

-- 装备配件
function MallSystemWeaponModelHandler:PutonEquipmentByResId(resId)
    log("MallSystemWeaponModelHandler:PutonEquipmentByResId : "..tostring(resId))
    if resId == nil or resId == 0 then
        log("MallSystemWeaponModelHandler:PutonEquipmentByResId Invalid Resid")
        return
    end
    
    BP_MallWeapon_Cur_Equipment_Resid = resId
    LuaClassObj.HandleUIMessageNoFetch(bp_mall_weapon_model_handler, "PutonEquipmentByResId");
end

-- 卸下配件
function MallSystemWeaponModelHandler:PutoffEquipmentByResId(resId)
    log("MallSystemWeaponModelHandler:PutoffEquipmentByResId : "..tostring(resId))
    if resId == nil or resId == 0 then
        log("MallSystemWeaponModelHandler:PutoffEquipmentByResId Invalid Resid")
        return
    end
    
    BP_MallWeapon_Cur_Equipment_Resid = resId
    LuaClassObj.HandleUIMessageNoFetch(bp_mall_weapon_model_handler, "PutoffEquipmentByResId");
end

-- 卸下全部配件
function MallSystemWeaponModelHandler:PutoffAllEquipment(curWeaponId)
    log("MallSystemWeaponModelHandler:PutoffAllEquipment"..tostring(curWeaponId))
    MallSystemWeaponModelHandler:ShowWeaponByResId(curWeaponId, false, false)
end

-- 切换相机
function MallSystemWeaponModelHandler:SwitchToArmoryMainCamera()
    log("MallSystemWeaponModelHandler:SwitchToArmoryMainCamera()")
    LuaClassObj.HandleUIMessageNoFetch(bp_mall_weapon_model_handler, "SwitchArmoryMainCamera");
end

-- 穿皮肤
function MallSystemWeaponModelHandler:EquipSkin(skinId)
    MallSystemWeaponModelHandler:ShowWeaponByResId(skinId, true, false)
    MallSystemWeaponModelHandler:PutonAlreadyOnEquipment()
end

-- 卸皮肤
function MallSystemWeaponModelHandler:UnEquipSkin(weaponId)
    MallSystemWeaponModelHandler:ShowWeaponByResId(weaponId, false, false)
    MallSystemWeaponModelHandler:PutonAlreadyOnEquipment()
end

-- 装备已有配件
function MallSystemWeaponModelHandler:PutonAlreadyOnEquipment()
    log("MallSystemWeaponModelHandler:PutonAlreadyOnEquipment()")
    BP_Array_MallWeapon_PutOnEquipment_Resid_List = {}
    for k,v in pairs(ArmoryUI.EquipShortHandData) do
        table.insert(BP_Array_MallWeapon_PutOnEquipment_Resid_List, v.ShortHandID)
    end
    LuaClassObj.HandleUIMessageNoFetch(bp_mall_weapon_model_handler, "PutonEquipmentByResIdList");
end

function MallSystemWeaponModelHandler.SetPosition(x, y, z)
    BP_Array_MallWeapon_AdaptPosition[1] = x
    BP_Array_MallWeapon_AdaptPosition[2] = y
    BP_Array_MallWeapon_AdaptPosition[3] = z

    LuaClassObj.HandleUIMessageNoFetch(bp_mall_weapon_model_handler, "SetAdaptPosition")
end

function MallSystemWeaponModelHandler.SetAdaptPosition(px, py, pz, mx, my, mz, msx, msy, msz)
    BP_Array_MallWeapon_AdaptPosition = {}
    table.insert(BP_Array_MallWeapon_AdaptPosition, px)
    table.insert(BP_Array_MallWeapon_AdaptPosition, py)
    table.insert(BP_Array_MallWeapon_AdaptPosition, pz)
    
    table.insert(BP_Array_MallWeapon_AdaptPosition, mx)
    table.insert(BP_Array_MallWeapon_AdaptPosition, my)
    table.insert(BP_Array_MallWeapon_AdaptPosition, mz)

    table.insert(BP_Array_MallWeapon_AdaptPosition, msx)
    table.insert(BP_Array_MallWeapon_AdaptPosition, msy)
    table.insert(BP_Array_MallWeapon_AdaptPosition, msz)

    LuaClassObj.HandleUIMessageNoFetch(bp_mall_weapon_model_handler, "SetAdaptPosition")
end

function MallSystemWeaponModelHandler.ShowDebug(isShow)
    isShow = isShow or false

    if isShow == true then
        LuaClassObj.HandleUIMessageNoFetch(bp_mall_weapon_model_handler, "ShowEditorBall")
    else
        LuaClassObj.HandleUIMessageNoFetch(bp_mall_weapon_model_handler, "HideEditorBall")
    end
end

function EventSetInfo_Push()
end

function EventFetchInfo()
end
