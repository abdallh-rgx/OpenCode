--[[
    武器模型操作接口
]]

WeaponModelHandler = WeaponModelHandler or {}

-- 当前展示中的武器id
BP_Armory_Cur_Show_Weapon_Resid = 0
BP_Armory_Cur_Show_Weapon_Skin = false
BP_Armory_Cur_Show_Weapon_Need_ResetRotation = false
-- 当前装配/卸下配件id
BP_Armory_Cur_Equipment_Resid = 0

BP_Array_Armory_PutOnEquipment_Resid_List = 
{
    0,
}
VSS_Item_Id = 103005
VSS_Sight_Item_Id = 203011

--注册Widget
function bp_weapon_model_handler_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_weapon_model_handler,
        {{Path="/Game/UMG/UI_Logic/Armory/Armory_Model_Handler_BP.Armory_Model_Handler_BP_C", Container="Default", ZOrder=0}},
        {"Lobby"},
        false,
        false,
        true
    );
end

function WeaponModelHandler:Init()
    log("WeaponModelHandler:Init()")
    LuaClassObj.HandleDynamicCreation(bp_weapon_model_handler);
    LuaClassObj.HandleUIMessageNoFetch(bp_weapon_model_handler, "ArmoryModelHandlerInit");
end

-- 删除武器展示Actor
function WeaponModelHandler:DestroyWeaponShowActor()
    log("WeaponModelHandler:DestroyWeaponShowActor()")
    LuaClassObj.HandleUIMessageNoFetch(bp_weapon_model_handler, "DestroyModelShowActor");
end

function WeaponModelHandler:ResetCamera()
    local cfg = Client.GetTableData("ArmoryCameraSetting", BP_Armory_Cur_Show_Weapon_Resid)
    LobbyCameraManager.SwitchCamera(cfg.MainCameraIndex)
end

-- 创建或切换武器
function WeaponModelHandler:ShowWeaponByResId(resId, isSkin, needResetRotation)
    log("WeaponModelHandler:ShowWeaponByResId : "..tostring(resId)..tostring(isSkin)..tostring(needResetRotation))
    if resId == nil or resId == 0 then
        log("WeaponModelHandler:ShowWeaponByResId Invalid Resid")
        return
    end
    
    BP_Armory_Cur_Show_Weapon_Skin = isSkin or false
    BP_Armory_Cur_Show_Weapon_Need_ResetRotation = needResetRotation or false
    BP_Armory_Cur_Show_Weapon_Resid = resId
    
    log("WeaponModelHandler:ShowWeaponByResId : after"..tostring(BP_Armory_Cur_Show_Weapon_Skin)..tostring(BP_Armory_Cur_Show_Weapon_Need_ResetRotation))
    LuaClassObj.HandleUIMessageNoFetch(bp_weapon_model_handler, "ShowWeaponByResId");
    
    -- VSS 装四倍
    --if resId == VSS_Item_Id then
        --WeaponModelHandler:PutonEquipmentByResId(VSS_Sight_Item_Id)
    --end
end

-- 装备配件
function WeaponModelHandler:PutonEquipmentByResId(resId)
    log("WeaponModelHandler:PutonEquipmentByResId : "..tostring(resId))
    if resId == nil or resId == 0 then
        log("WeaponModelHandler:PutonEquipmentByResId Invalid Resid")
        return
    end
    
    BP_Armory_Cur_Equipment_Resid = resId
    LuaClassObj.HandleUIMessageNoFetch(bp_weapon_model_handler, "PutonEquipmentByResId");
end

-- 卸下配件
function WeaponModelHandler:PutoffEquipmentByResId(resId)
    log("WeaponModelHandler:PutoffEquipmentByResId : "..tostring(resId))
    if resId == nil or resId == 0 then
        log("WeaponModelHandler:PutoffEquipmentByResId Invalid Resid")
        return
    end
    
    BP_Armory_Cur_Equipment_Resid = resId
    LuaClassObj.HandleUIMessageNoFetch(bp_weapon_model_handler, "PutoffEquipmentByResId");
end

-- 卸下全部配件
function WeaponModelHandler:PutoffAllEquipment(curWeaponId)
    log("WeaponModelHandler:PutoffAllEquipment"..tostring(curWeaponId))
    WeaponModelHandler:ShowWeaponByResId(curWeaponId, false, true)
end

-- 切换相机
function WeaponModelHandler:SwitchToArmoryMainCamera()
    log("WeaponModelHandler:SwitchToArmoryMainCamera()")
    LuaClassObj.HandleUIMessageNoFetch(bp_weapon_model_handler, "SwitchArmoryMainCamera");
end

-- 穿皮肤
function WeaponModelHandler:EquipSkin(skinId)
    WeaponModelHandler:ShowWeaponByResId(skinId, true, true)
    WeaponModelHandler:PutonAlreadyOnEquipment()
end

-- 卸皮肤
function WeaponModelHandler:UnEquipSkin(weaponId)
    WeaponModelHandler:ShowWeaponByResId(weaponId, false, true)
    WeaponModelHandler:PutonAlreadyOnEquipment()
end

-- 装备已有配件
function WeaponModelHandler:PutonAlreadyOnEquipment()
    log("WeaponModelHandler:PutonAlreadyOnEquipment()")
    BP_Array_Armory_PutOnEquipment_Resid_List = {}
    for k,v in pairs(ArmoryUI.EquipShortHandData) do
        table.insert(BP_Array_Armory_PutOnEquipment_Resid_List, v.ShortHandID)
    end
    LuaClassObj.HandleUIMessageNoFetch(bp_weapon_model_handler, "PutonEquipmentByResIdList");
end

