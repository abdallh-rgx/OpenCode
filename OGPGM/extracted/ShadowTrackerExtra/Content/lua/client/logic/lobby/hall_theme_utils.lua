-- sami 大厅主题背景
HallThemeUtils = HallThemeUtils or
{
    --背包拓展定义
    knapsack_ext_min = 0,
    knapsack_ext_weapon_skin = 1,
    knapsack_ext_vst_skin = 2,
    knapsack_ext_background = 3,
    knapsack_ext_max = 4,
    defaultThemeItemId = 202408001,

    show_pos_background = 101,
    show_pos_vst_type = 102,
    show_pos_vst_skin = 103,
    

    --默认载具类型
    default_vehicle_list =
    {
        [901] = 1901001, --两轮摩托
        [902] = 1902001, --三轮摩托
        [903] = 1903001, --dacia轿车
        [904] = 1904001, --minibus
        [905] = 1905001, --皮卡
        [906] = 1906001, --带顶皮卡
        [907] = 1907001, --buggy 越野车
        [908] = 1908001, --普通UAZ吉普车
        [909] = 1909001, --布篷UAZ吉普车
        [910] = 1910001, --敞篷UAZ吉普2
        [911] = 1911001, --PG117船
        [912] = 1912001, --摩托艇
        [913] = 1913001, --空投UAZ吉普车
        [914] = 1914001, --Mirado跑车
        [915] = 1915001, --Mirado敞篷跑车
    },
    default_vehicle_map = {},
    
    --roleData数据
    resRoleData = {},
    --主题仓库数据
    themeBagInfo = {},
    
    --时装背包下标
    nUseWearBagIndex = 1,
    --我的主题id
    homeThemeItemId = 0,
    homeThemeInstId = 0,
    --我的载具id
    themeVehicleId = 0,
    themeVehicleInstId = 0,
    --载具显示开关
    themeVehicleShow = false,
    --当前显示模式
    themeShowMode = 0, -- 0-自己,1-个人空间，2-组队
    --当前显示玩家数据
    curShowAvatarData = nil,
    --当前组队信息
    curTeamInfo = nil,
}




--背包道具类型
eItemType = 
{
    eHallThemeItem = 202,   --主题背景道具
}


--接收服务器下发个人信息数据
function HallThemeUtils.OnRecvRoleData(res)
    log("HallThemeUtils.OnRecvRoleData")
    HallThemeUtils.default_vehicle_map = {}
    for k,v in pairs(HallThemeUtils.default_vehicle_list) do
        HallThemeUtils.default_vehicle_map[v] = 1
    end
    HallThemeUtils.resRoleData = res
    HallThemeUtils.themeBagInfo = res.all_knapsack_ext_info
    HallThemeUtils.nUseWearBagIndex = HallThemeUtils.resRoleData.use_rolewear or 1
    HallThemeUtils.homeThemeItemId = HallThemeUtils.GetMyHallThemeItemId()
    HallThemeUtils.themeVehicleId = HallThemeUtils.GetThemeVehicleId(true)

    ArmorySystem.get_weapon_skin_list(ArmorySystem.ENUM_REQ_Wardrobe);
end

-- 获取我的主题道具id (ret:number)
function HallThemeUtils.GetMyHallThemeItemId()
    log("HallThemeUtils.GetMyHallThemeItemId")
    if HallThemeUtils.themeBagInfo == nil or HallThemeUtils.themeBagInfo[HallThemeUtils.nUseWearBagIndex] == nil then
        return 0
    end
    local info = HallThemeUtils.themeBagInfo[HallThemeUtils.nUseWearBagIndex][HallThemeUtils.knapsack_ext_background]
    if info == nil then
        return 0
    end
    HallThemeUtils.homeThemeInstId = info.instid or 0

    local itemInfo = DataMgr.GetHallDepotItemDataByInsID(info.instid)
    if itemInfo == nil then
        return 0
    end
    return itemInfo.resID
end

-- 获取我的主题载具id (ret:number)
function HallThemeUtils.GetThemeVehicleId(bFromRole)
    local info = HallThemeUtils.themeBagInfo
    if info == nil then
        return 0
    end
    if info[HallThemeUtils.nUseWearBagIndex] == nil then
        return 0
    end
    local info2 = info[HallThemeUtils.nUseWearBagIndex][HallThemeUtils.knapsack_ext_vst_skin]
    if info2 == nil then
        return 0
    end
    HallThemeUtils.themeVehicleShow = info2.is_show or false
    HallThemeUtils.themeVehicleInstId = info2.instid or 0

    local resId = 0
    if bFromRole then
        local dept = HallThemeUtils.resRoleData.depot
        if dept == nil or dept.items == nil or dept.items[info2.instid] == nil then
            return 0
        end
        resId = dept.items[info2.instid].res_id or 0
    else
        local itemInfo = DataMgr.GetHallDepotItemDataByInsID(info2.instid)
        if itemInfo == nil then
            return 0
        end
        resId = itemInfo.resID
    end
    log("HallThemeUtils.GetThemeVehicleId resId = "..resId)
    return resId
end

-- 获取我的主题相关道具id (ret:number)
function HallThemeUtils.GetThemeRelateItemId(tag, bFromRole)
    local info = HallThemeUtils.themeBagInfo
    if info == nil then
        return 0
    end
    if info[HallThemeUtils.nUseWearBagIndex] == nil then
        return 0
    end
    local info2 = info[HallThemeUtils.nUseWearBagIndex][tag]
    if info2 == nil then
        return 0
    end
    local resId = 0
    if bFromRole then
        local dept = HallThemeUtils.resRoleData.depot
        if dept == nil or dept.items == nil or dept.items[info2.instid] == nil then
            return 0
        end
        resId = dept.items[info2.instid].res_id or 0
    else
        local itemInfo = DataMgr.GetHallDepotItemDataByInsID(info2.instid)
        if itemInfo == nil then
            return 0
        end
        resId = itemInfo.resID
    end
    log("HallThemeUtils.GetThemeRelateItemId tag = "..tag..",resId = "..resId)
    return resId
end

function HallThemeUtils.GetThemeSkinId()
    local cfg = Client.GetTableData("HallThemeItem", HallThemeUtils.homeThemeItemId)
    if cfg == nil then
        return 0
    end
    log("HallThemeUtils.GetThemeSkinId = "..cfg.skinId)
    return tonumber(cfg.skinId)
end

function HallThemeUtils.IsWeaponWear(instId)
    log("HallThemeUtils IsWeaponWear "..instId)
    local info = HallThemeUtils.themeBagInfo[HallThemeUtils.nUseWearBagIndex]
    if info == nil then
        return false
    end
    if info[HallThemeUtils.knapsack_ext_weapon_skin] and 
            tostring(info[HallThemeUtils.knapsack_ext_weapon_skin].instid) == tostring(instId) then
        return true
    end
    return false
end

function HallThemeUtils.GetUsedItemCount(instId, tagId)
    local info = HallThemeUtils.themeBagInfo
    if info == nil then
        return 0
    end
    local itemInfo = DataMgr.GetHallDepotItemDataByInsID(instId)
    if itemInfo == nil then
        return 0
    end
    if tagId == HallThemeUtils.knapsack_ext_background and itemInfo.resID == HallThemeUtils.defaultThemeItemId then
        return 0
    end
    if tagId == HallThemeUtils.knapsack_ext_vst_skin and HallThemeUtils.IsDefaultVehicle(itemInfo.resID) then
        return 0
    end
    local count = 0
    for k,v in pairs(info) do
        if v[tagId] and tostring(v[tagId].instid) == tostring(instId) then
            count = count + 1
        end
    end
    if count > itemInfo.count then
        count = itemInfo.count
    end
    --log("instId="..instId..", count="..count) 
    return count
end

function HallThemeUtils.HasTeam()
    if HallThemeUtils.curTeamInfo == nil then
        return false
    end
    local playerCount = HallThemeUtils.curTeamInfo.player_count or 0
    return playerCount >= 2 
end

--获取仓库主题道具列表
--[[ret:list
    res_id: 403017
    expire_ts: 1578501298
    instid: 6649518678811344995
    count: 1
    isnew: 1
    use_flag: 0
    valid_hours: 168
]]
function HallThemeUtils.GetHallItemList()
    log("HallThemeUtils.GetHallItemList")
    if HallThemeUtils.resRoleData == nil or HallThemeUtils.resRoleData.depot == nil then
        return nil
    end
    local items = HallThemeUtils.resRoleData.depot.items
    if items == nil then
        return nil
    end
    local itemList = {}
    for k,v in pairs(items) do
        local itemId = v.res_id
        local cfg = DataMgr.WardrobeItemList[itemId];
        if(cfg == nil) then
            cfg = Client.GetTableData("Item", itemId);
            DataMgr.WardrobeItemList[itemId] = cfg
        end
        if cfg and cfg.ItemType == eItemType.eHallThemeItem then
            table.insert(itemList, v)
        end
    end
    --log_tree("itemList = ", itemList)
    return itemList
end

--穿戴主题
function HallThemeUtils.PutOnHallTheme(instId)
    log("HallThemeUtils.PutOnHallTheme instId = "..instId)
    WardrobeSystem.wardrobe_puton_req(instId)
end

--处理穿戴协议
function HallThemeUtils.ProcPutOnHallTheme(putOnItem, putOffItem)
    if putOnItem == nil then
        return
    end
    HallThemeUtils.homeThemeItemId = putOnItem.res_id or 0
    HallThemeUtils.homeThemeInstId = putOnItem.instid or 0
    
    --处理主题切换
    HallThemeUtils.ShowTheme()
    HallThemeUtils.ShowThemeVehicle()

    --更新背包数据
    local itemInfo = HallThemeUtils.themeBagInfo[HallThemeUtils.nUseWearBagIndex][HallThemeUtils.knapsack_ext_background]
    if itemInfo then
        itemInfo.instid = putOnItem.instid
    end
    
end

function HallThemeUtils.GetWeaponInstId(bagIndex)
    if HallThemeUtils.themeBagInfo[bagIndex] and HallThemeUtils.themeBagInfo[bagIndex][1] then
        return HallThemeUtils.themeBagInfo[bagIndex][1].instid
    else
        return 0
    end
end

function HallThemeUtils.LogoutWeapon()
    log("HallThemeUtils w1="..HallThemeUtils.GetWeaponInstId(1)..",w2="..HallThemeUtils.GetWeaponInstId(2)..",w3="..HallThemeUtils.GetWeaponInstId(3))
end

--处理穿戴载具
function HallThemeUtils.ProcPutOnVehicle(putOnItem, putOffItem)
    if putOnItem == nil then
        return
    end
    HallThemeUtils.themeVehicleId = putOnItem.res_id or 0
    HallThemeUtils.themeVehicleInstId = putOnItem.instid or 0
    HallThemeUtils.ShowThemeVehicle()

    --更新背包数据
    local itemInfo = HallThemeUtils.themeBagInfo[HallThemeUtils.nUseWearBagIndex][HallThemeUtils.knapsack_ext_vst_skin]
    if itemInfo then
        itemInfo.instid = putOnItem.instid
    end
end

--处理穿戴枪械皮肤 weapon_id:101004 instanceID:6667703836735439313
function HallThemeUtils.ProcGunInstall(weapon_id, instanceID)
    local itemInfo = HallThemeUtils.themeBagInfo[HallThemeUtils.nUseWearBagIndex][HallThemeUtils.knapsack_ext_weapon_skin]
    if itemInfo then
        itemInfo.instid = instanceID
    end
    WardrobeUI.UpdateSelectItem();
    HallThemeUtils.LogoutWeapon()
    --log_tree("HallThemeUtils.themeBagInfo 1 = ", HallThemeUtils.themeBagInfo)
end
function HallThemeUtils.ProcGunUnInstall(weapon_id)
    local itemInfo = HallThemeUtils.themeBagInfo[HallThemeUtils.nUseWearBagIndex][HallThemeUtils.knapsack_ext_weapon_skin]
    if itemInfo then
        itemInfo.instid = 0
    end
    WardrobeUI.UpdateSelectItem();
    HallThemeUtils.LogoutWeapon()
    --log_tree("HallThemeUtils.themeBagInfo 2 = ", HallThemeUtils.themeBagInfo)
end
function HallThemeUtils.ProcGunWear(weapon_id, new_skin_id)
    if new_skin_id == 0 then
        HallThemeUtils.ProcGunUnInstall(weapon_id)
    else
        HallThemeUtils.ProcGunInstall(weapon_id, new_skin_id)
    end

    if ArmorySystem.rsp_list.install_list[weapon_id] ~= nil then
        ArmorySystem.rsp_list.install_list[weapon_id].skin_id = new_skin_id
    end
    WardrobeSystem.UpdateCurrentGunAvatar(weapon_id, new_skin_id);
    
end


function HallThemeUtils.ProcSwitchUseWearBag(index)
    log("HallThemeUtils.ProcSwitchUseWearBag index = "..index)
    HallThemeUtils.nUseWearBagIndex = index
    HallThemeUtils.homeThemeItemId = HallThemeUtils.GetMyHallThemeItemId()
    HallThemeUtils.themeVehicleId = HallThemeUtils.GetThemeVehicleId(false)
    HallThemeUtils.themeVehicleShow = HallThemeUtils.themeBagInfo[HallThemeUtils.nUseWearBagIndex][2].is_show
    
    --主题载具显示
    HallThemeUtils.ShowTheme()
    HallThemeUtils.ShowThemeVehicle()
    --todo shuaxin
    --LuaClassObj.HandleUIMessageNoFetch(bp_wardrobe, "UpdateCheckBoxShowInHall");
end

function HallThemeUtils.ProcSwitchSpaceUseWearBag(index)
    log("HallThemeUtils.ProcSwitchSpaceUseWearBag index = "..index)
    HallThemeUtils.ShowTheme()
    HallThemeUtils.ShowThemeVehicle()
end

function HallThemeUtils.ProcRoleWearState(all_knapsack_ext_info, pspace_rolewear_index)
    if all_knapsack_ext_info == nil then
        return
    end
    HallThemeUtils.themeBagInfo = all_knapsack_ext_info
    --主题载具显示
    HallThemeUtils.ShowTheme()
    HallThemeUtils.ShowThemeVehicle()
end

function HallThemeUtils.GetThemeSkinIdByItemId(itemId)
    local cfg = Client.GetTableData("HallThemeItem", itemId)
    if cfg then
        return tonumber(cfg.skinId)
    end
    return 0
end

function HallThemeUtils.GetTeamLeaderThemItemId()
    if HallThemeUtils.curTeamInfo == nil then
        return 0
    end
    local leader = HallThemeUtils.curTeamInfo.leader
    for k,v in pairs(HallThemeUtils.curTeamInfo.members) do
        if k == leader then
            local itemId = v.background or 0
            return itemId
        end
    end
    return 0
end
function HallThemeUtils.GetTeamLeaderThemSkin()
    if HallThemeUtils.curTeamInfo == nil then
        return 0
    end
    local leader = HallThemeUtils.curTeamInfo.leader
    for k,v in pairs(HallThemeUtils.curTeamInfo.members) do
        if k == leader then
            local itemId = v.background or 0
            return HallThemeUtils.GetThemeSkinIdByItemId(itemId)
        end
    end
    return 0
end
function HallThemeUtils.GetTeamLeaderVehicle()
    if HallThemeUtils.curTeamInfo == nil then
        return 0
    end
    local leader = HallThemeUtils.curTeamInfo.leader
    for k,v in pairs(HallThemeUtils.curTeamInfo.members) do
        if k == leader then
            local itemId = v.vst_info.skin_id or 0
            return itemId
        end
    end
    return 0
end

function HallThemeUtils.GetCurShowThemeItemId()
    local itemId = 0
    if HallThemeUtils.themeShowMode == 0 then
        itemId = HallThemeUtils.homeThemeItemId
    elseif HallThemeUtils.themeShowMode == 1 then
        if tonumber(HallThemeUtils.curShowAvatarData.uid) == tonumber(DataMgr.roleData.uid) then
            itemId = HallThemeUtils.GetSpaceThemeRelateItemId(HallThemeUtils.knapsack_ext_background)
        else
            if HallThemeUtils.curShowAvatarData.wear_ext[101] then
                itemId = HallThemeUtils.curShowAvatarData.wear_ext[101][1] or 0
            end
        end
    else
        if HallThemeUtils.curTeamInfo then
            local leader = HallThemeUtils.curTeamInfo.leader
            if tonumber(leader) == tonumber(DataMgr.roleData.uid) then
                itemId = HallThemeUtils.homeThemeItemId
            else
                itemId = HallThemeUtils.GetTeamLeaderThemItemId()
            end
        end
    end
    return itemId
end
function HallThemeUtils.GetCurShowThemeSkinId()
    local itemId = HallThemeUtils.GetCurShowThemeItemId()
    if itemId == 0 then
        return 0
    end
    local skinId = HallThemeUtils.GetThemeSkinIdByItemId(itemId)
    return skinId
end

function HallThemeUtils.GetSpaceThemeRelateItemId(tag)
    log("HallThemeUtils .pspace_rolewear_index"..DataMgr.pspace_rolewear_index)
    
    local info = HallThemeUtils.themeBagInfo
    if info == nil then
        return 0
    end
    if info[DataMgr.pspace_rolewear_index] == nil then
        return 0
    end
    local info2 = info[DataMgr.pspace_rolewear_index][tag]
    if info2 == nil or info2.is_show == false then
        return 0
    end
    local resId = 0
    local itemInfo = DataMgr.GetHallDepotItemDataByInsID(info2.instid)
    if itemInfo == nil then
        return 0
    end
    resId = itemInfo.resID
    log("HallThemeUtils.GetSpaceThemeRelateItemId tag = "..tag..",resId = "..resId)
    return resId
end

--更新显示大厅主题
function HallThemeUtils.ShowTheme()
    local skinId = 0
    if HallThemeUtils.themeShowMode == 0 then
        skinId = HallThemeUtils.GetThemeSkinId()
    elseif HallThemeUtils.themeShowMode == 1 then
        if tonumber(HallThemeUtils.curShowAvatarData.uid) == tonumber(DataMgr.roleData.uid) then
            local themItemId = HallThemeUtils.GetSpaceThemeRelateItemId(HallThemeUtils.knapsack_ext_background)
            skinId = HallThemeUtils.GetThemeSkinIdByItemId(themItemId)
        else
            if HallThemeUtils.curShowAvatarData.wear_ext[101] then
                local themItemId = 0
                if HallThemeUtils.curShowAvatarData.bshow then
                    themItemId = HallThemeUtils.curShowAvatarData.wear_ext[101][1] or 0
                else
                    themItemId = 202408001
                end
                skinId = HallThemeUtils.GetThemeSkinIdByItemId(themItemId)
            end
        end
    else
        if HallThemeUtils.curTeamInfo then
            local leader = HallThemeUtils.curTeamInfo.leader
            if tonumber(leader) == tonumber(DataMgr.roleData.uid) then
                skinId = HallThemeUtils.GetThemeSkinId()
            else
                skinId = HallThemeUtils.GetTeamLeaderThemSkin()
            end
        end
    end
    if skinId == 0 then
        return
    end
    log("HallThemeUtils ShowTheme skinId = "..skinId)
    GlobalData.SwitchLobbySkin(tonumber(skinId))
end

--更新显示大厅载具
function HallThemeUtils.ShowThemeVehicle()
    log("HallThemeUtils.ShowThemeVehicle themeVehicleId = "..HallThemeUtils.themeVehicleId)
    local itemId = 0
    if HallThemeUtils.themeShowMode == 0 then
        --大厅模式
        if HallThemeUtils.themeVehicleShow then
            itemId = HallThemeUtils.themeVehicleId
        end
    elseif HallThemeUtils.themeShowMode == 1 then
        --个人空间
        if tonumber(HallThemeUtils.curShowAvatarData.uid) == tonumber(DataMgr.roleData.uid) then
            --自己
            itemId = HallThemeUtils.GetSpaceThemeRelateItemId(HallThemeUtils.knapsack_ext_vst_skin)
        else
            --别人
            if HallThemeUtils.curShowAvatarData.wear_ext[103] then
                if HallThemeUtils.curShowAvatarData.bshow then
                    itemId = HallThemeUtils.curShowAvatarData.wear_ext[103][1] or 0
                end
            end
        end
    else
        --组队模式
        local leader = HallThemeUtils.curTeamInfo.leader
        if tonumber(leader) == tonumber(DataMgr.roleData.uid) then
            if HallThemeUtils.themeVehicleShow then
                itemId = HallThemeUtils.themeVehicleId
            end
        else
            itemId = HallThemeUtils.GetTeamLeaderVehicle()
        end
    end

    if itemId == 0 then
        LobbySceneManager.CreateHallVehicle(0, 0)
    else
        local themeItemId = HallThemeUtils.GetCurShowThemeItemId()
        LobbySceneManager.CreateHallVehicle(themeItemId, itemId)
    end
end

--设置载具大厅可见
function HallThemeUtils.set_knapsack_pos_show_req(bShow)
    NetUtil.SendPriorityPkg(false, "set_knapsack_show_rsp", "set_knapsack_pos_show_req", 
            HallThemeUtils.knapsack_ext_vst_skin, bShow)
end

function HallThemeUtils.set_knapsack_show_rsp(res, bShow)
    log("HallThemeUtils.set_knapsack_show_rsp res = "..res)
    if res ~= 0 then
        --ShowNotice(100)
        return
    end
    HallThemeUtils.themeVehicleShow = bShow
    HallThemeUtils.themeBagInfo[HallThemeUtils.nUseWearBagIndex][2].is_show = bShow
    
    log("HallThemeUtils bShow = "..tostring(bShow))
    HallThemeUtils.ShowThemeVehicle()
end

--是否勾选
function HallThemeUtils.GetCheckBoxShowInHallSts()
    return HallThemeUtils.themeVehicleShow
end

function HallThemeUtils.SwitchShowMode(showMode, roleData, teamInfo)
    log("HallThemeUtils.SwitchShowMode = "..showMode)
    HallThemeUtils.curShowAvatarData = roleData
    HallThemeUtils.themeShowMode = showMode
    HallThemeUtils.curTeamInfo = teamInfo
    HallThemeUtils.ShowTheme()
    HallThemeUtils.ShowThemeVehicle()
end

function HallThemeUtils.ProcEnterRoleSpace(roleData)
    HallThemeUtils.SwitchShowMode(1, roleData, HallThemeUtils.curTeamInfo)
end
function HallThemeUtils.ProcLeaveRoleSpace()
    if HallThemeUtils.HasTeam() then
        HallThemeUtils.SwitchShowMode(2, nil, HallThemeUtils.curTeamInfo)
    else
        HallThemeUtils.SwitchShowMode(0)
    end
end
function HallThemeUtils.ProcEnterTeam(teamInfo)
    HallThemeUtils.curTeamInfo = teamInfo
    if HallThemeUtils.themeShowMode == 1 then
        --do none
    else
        HallThemeUtils.SwitchShowMode(2, nil, HallThemeUtils.curTeamInfo)
    end
end
function HallThemeUtils.ProcLeaveTeam()
    HallThemeUtils.curTeamInfo = nil
    if HallThemeUtils.themeShowMode == 1 then
        --do none
    else
        HallThemeUtils.SwitchShowMode(0)
    end
end

function HallThemeUtils.ProcTeamUpdateWear(op_uid, knapsack_ext_info)
    log("HallThemeUtils.ProcTeamUpdateWear op_uid="..op_uid)
    if tonumber(op_uid) == tonumber(DataMgr.roleData.uid) then
        return
    end
    if knapsack_ext_info then
        local uid = op_uid
        if HallThemeUtils.curTeamInfo and HallThemeUtils.curTeamInfo.members then
            for k,v in pairs(HallThemeUtils.curTeamInfo.members) do
                if k == uid then
                    if knapsack_ext_info.weapon_wear_info then
                        v.weapon_wear_info.weapon_id = knapsack_ext_info.weapon_wear_info.weapon_id
                        v.weapon_wear_info.skin_id = knapsack_ext_info.weapon_wear_info.skin_id
                    else
                        v.weapon_wear_info.weapon_id = 0
                        v.weapon_wear_info.skin_id = 0
                    end
                    local mermberInfo = TeamUpSystem.GetMemberInfo(uid);
                    if (mermberInfo ~= nil) then
                        mermberInfo.weapon_wear_info = v.weapon_wear_info
                        TeamUpSystem.OnMemberWeaponChange(uid);
                    end
                    
                    v.vst_info.skin_id = knapsack_ext_info.vst_skin.skin_id
                    v.vst_info.vst_type = knapsack_ext_info.vst_skin.vst_type
                    v.background = knapsack_ext_info.background
                    break
                end
            end
        end
    end
    HallThemeUtils.ShowTheme()
    HallThemeUtils.ShowThemeVehicle()
end
function HallThemeUtils.ProcTeamInfoChange(param)
    log("HallThemeUtils.ProcTeamInfoChange")
    if param and param.uid then
        local uid = param.uid
        if HallThemeUtils.curTeamInfo and HallThemeUtils.curTeamInfo.members then
            for k,v in pairs(HallThemeUtils.curTeamInfo.members) do
                if k == uid then
                    if param.vst_info then
                        v.vst_info.skin_id = param.vst_info.skin_id
                        v.vst_info.vst_type = param.vst_info.vst_type
                    elseif param.background then
                        v.background = param.background
                    end
                    break
                end
            end
        end
    end
    HallThemeUtils.ShowTheme()
    HallThemeUtils.ShowThemeVehicle()
end

--处理切换时装背包时，枪械，载具的装备状态，仓库页签图标的显示
function HallThemeUtils.notify_skin_list_chg(type_name, param_key, param_val, bagIndex)
    log("HallThemeUtils.notify_skin_list_chg type_name="..type_name..",param_key="..param_key..",param_val="..param_val..",bagIndex="..bagIndex)
    if type_name == "weapon_skin" then
        local info = HallThemeUtils.themeBagInfo[bagIndex][1]
        if info == nil then
            info = 
            {
                is_show = true,
                instid = 0,
                relat_param = 0,
            }
            HallThemeUtils.themeBagInfo[bagIndex][1] = info
        end
        info.relat_param = param_key
        info.instid = param_val

        local itemInfo = DataMgr.GetHallDepotItemDataByInsID(param_val)
        if itemInfo == nil then
            --脱下枪
            BP_Wardrobe_GunSkinUID = 0
            if param_key == 0 then
                if ArmorySystem.rsp_list.install_list[BP_Wardrobe_GunID] ~= nil then
                    ArmorySystem.rsp_list.install_list[BP_Wardrobe_GunID].skin_id = 0
                end
                WardrobeSystem.UpdateCurrentGunAvatar(BP_Wardrobe_GunID, param_val);
                BP_Wardrobe_GunID = 0
                WardrobeSystem.PutOffGunAvatar()
            else
                BP_Wardrobe_GunID = param_key
                BP_Wardrobe_GunSkinUID = param_val
                if ArmorySystem.rsp_list.install_list[param_key] ~= nil then
                    ArmorySystem.rsp_list.install_list[param_key].skin_id = 0
                end
                WardrobeSystem.UpdateCurrentGunAvatar(param_key, param_val);
            end
        else
            BP_Wardrobe_GunID = param_key
            BP_Wardrobe_GunSkinUID = param_val
            if ArmorySystem.rsp_list.install_list[param_key] ~= nil then
                ArmorySystem.rsp_list.install_list[param_key].skin_id = param_val
            end
            WardrobeSystem.UpdateCurrentGunAvatar(param_key, param_val);
        end
        HallThemeUtils.LogoutWeapon()
    elseif type_name == "vst_skin" then
        local vst_type = param_key
        local vst_skin = param_val
        --none
    end
end

function HallThemeUtils.IsDefaultVehicle(itemId)
    if HallThemeUtils.default_vehicle_map[itemId] then
        return true
    else
        return false
    end
end

s2c["set_knapsack_show_rsp"] = HallThemeUtils.set_knapsack_show_rsp;
s2c["notify_skin_list_chg"] = HallThemeUtils.notify_skin_list_chg;


