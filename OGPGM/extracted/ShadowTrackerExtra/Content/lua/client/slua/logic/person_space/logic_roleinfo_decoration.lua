local RoleInfoDecorationSystem =
{
    WearInfos = nil,
    RolewearStateArr = nil,
    RolewearCurrnetTimeStamp = nil,
    RolewearUnlockTypeArr = nil,
    RolewearTabSelectIndex = 1,

    HasInDecoration = false,
}

function RoleInfoDecorationSystem.enter()

    RoleInfoDecorationSystem.HasInDecoration = true
    RoleInfoDecorationSystem.WearInfos = nil

    RoleInfoSystem.get_avatar_show_req(RoleInfoSystem.CurShowPlayerInfoUid, AvatarShowSource.FromPersonSpace)

    RoleInfoDecorationSystem.UpdateRolewearState()
end

function RoleInfoDecorationSystem.UpdateRolewearState()
    local RolewearStateArr = {0, 0, 0, 0};
    for i = 1, #RolewearStateArr do
        if DataMgr.rolewear_state[i]  ~= nil then
            RolewearStateArr[i] = DataMgr.rolewear_state[i];
            if RolewearStateArr[i] > WardrobeUI.timeOffset then
                RolewearStateArr[i] = RolewearStateArr[i] - WardrobeUI.timeOffset;
            end
        end
    end
    RoleInfoDecorationSystem.RolewearStateArr =RolewearStateArr

    RoleInfoDecorationSystem.RolewearTabSelectIndex = DataMgr.pspace_rolewear_index or 1;

    local RolewearUnlockTypeArr = {0, 0, 0, 0}
    for i = 2, #RolewearUnlockTypeArr do
        local unlockType = Client.GetTableData("UnlockTypeConfig", tostring(i - 1)).unlockType;
        if unlockType ~= nil then
            RolewearUnlockTypeArr[i] = unlockType;
        end
    end
    RoleInfoDecorationSystem.RolewearUnlockTypeArr = RolewearUnlockTypeArr

    RoleInfoDecorationSystem.RolewearCurrnetTimeStamp = FuncUtil.GetServerTimeInSec() - WardrobeUI.timeOffset;

    EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_ROLEWEAR_UPDATE);
end


function RoleInfoDecorationSystem.leave()
    RoleInfoDecorationSystem.HasInDecoration = false
end

function RoleInfoDecorationSystem.MakeCollectInfos(needUpdate)
    local collectInfos = {}
    local infos = RoleInfoDecorationSystem.MakeWearInfos()

    for i, info in ipairs(infos) do
        if info.resID ~= 0 then
            table.insert(collectInfos, RoleInfoDecorationSystem.GetCollectInfo(i, needUpdate))
        end
    end
    return collectInfos
end

function RoleInfoDecorationSystem.GetCollectInfo(index, needUpdate)
    local infos = RoleInfoDecorationSystem.MakeWearInfos()
    local info = infos[index]

    --log_tree("infos", infos)
    --log("GetCollectInfo:" .. tostring(index))
    if not needUpdate and info.collectInfo then
        return info.collectInfo
    end

    local collectInfo = {}
    collectInfo.WearInfo = info
    collectInfo.IsOwned = StoreFuncUtils.HasItem(info.resID)
    collectInfo.IsCollected = StoreSystem.IsCollectedByItemID(info.resID)
    collectInfo.IsSelected = not collectInfo.IsOwned and not collectInfo.IsCollected

    info.collectInfo = collectInfo

    return collectInfo
end

function RoleInfoDecorationSystem.MakeWearInfos()
    if RoleInfoDecorationSystem.WearInfos ~= nil then
        return RoleInfoDecorationSystem.WearInfos
    end

    local WearInfos = {}

    local function AddDefaultWearInfo()
        if #WearInfos < 6 then
            for i = 1, 6 - #WearInfos do
                table.insert(WearInfos, LobbyUI.MakeClientAvatarWearInfo(nil))
            end
        end
    end

    RoleInfoDecorationSystem.WearInfos = WearInfos

    --当前玩家数据
    local roleUid = tonumber(RoleInfoSystem.CurShowPlayerInfoUid);
    local roleData = ProfileMgr.GetRoleInfoDataByUid(roleUid);
    log("roleUid " ..roleUid);
    if nil == roleData then
        log("no player info")

        AddDefaultWearInfo()
        return WearInfos;
    end

    if not RoleInfoSystem.IsSelf() and not roleData.bshow then
        AddDefaultWearInfo()
        return WearInfos;
    end

    local wearRes = roleData.pspace_wear_ext or {};

    local function MakeClientAvatarWearInfo(wearSkinType, wearResType)
        local wearInfo = nil
        if nil ~= wearRes[wearSkinType] and wearRes[wearSkinType][1] ~= 0 then
            wearInfo = LobbyUI.MakeClientAvatarWearInfo(wearRes[wearSkinType]);--wearRes[1] and wearRes[1][1] or 0;
        elseif wearResType and nil ~= wearRes[wearResType]  and wearRes[wearResType][1] ~= 0 then
            wearInfo = LobbyUI.MakeClientAvatarWearInfo(wearRes[wearResType]);
        else
            --wearInfo = LobbyUI.MakeClientAvatarWearInfo(nil);
        end

        if wearInfo ~= nil then
            table.insert(WearInfos, wearInfo)
        end

        return wearInfo ~= nil
    end

    log_tree("roleData.skin_info", roleData.skin_info)
    local skin_info = roleData.skin_info or {0, 0, 0, 1, 1};
    local head_show = skin_info.head_show or 0;
    local helmet_level = skin_info.helmet_level or 1;
    local helmet_skin = skin_info.helmet_skin or 0;
    local bag_skin = skin_info.bag_skin or 0;
    local bag_level = skin_info.bag_level or 1;

    if(head_show ~= helmet_skin) then
        head_show = 0;
    end

    if(head_show ~= 0) then
        head_show = DataMgr.GetEquipmentItemIDByResID(helmet_level, head_show);
    end

    if head_show ~= 0 then
        table.insert(WearInfos, { resID = head_show, colorID = 0, patternID = 0 })
    else
        MakeClientAvatarWearInfo(WearResType.head)
    end

    MakeClientAvatarWearInfo(WearResType.face)
    MakeClientAvatarWearInfo(WearResType.clothes)
    MakeClientAvatarWearInfo(WearResType.pants)
    MakeClientAvatarWearInfo(WearResType.shoes)

    local bagSkinInsId = DataMgr.GetEquipmentItemIDByResID(bag_level, bag_skin) or 0

    if bagSkinInsId ~= 0 then
        table.insert(WearInfos, { resID = bagSkinInsId, colorID = 0, patternID = 0 })
    end

    MakeClientAvatarWearInfo(WearResType.weapon_skin, WearResType.weapon_type)

    --roleData.client_ver = "0.11.5"
    --
    --roleData.pspace_wear_ext[101] = nil
    --roleData.pspace_wear_ext[102] = nil
    --roleData.pspace_wear_ext[103] = nil

    local hasBackground = MakeClientAvatarWearInfo(WearResType.background)
    local has_vst = MakeClientAvatarWearInfo(WearResType.vst_skin, WearResType.vst_type)


    if not RoleInfoSystem.IsSelf() then
        --如果是11.5版本.也就是小于12版本的,添加默认的
        if FuncUtil.CompareVersion(roleData.client_ver, "0.12.0") == -1 then
            if not hasBackground then
                table.insert(WearInfos, { resID = 202408001, colorID = 0, patternID = 0 })
            end

            if not has_vst then
                table.insert(WearInfos, { resID = 1908001, colorID = 0, patternID = 0 })
            end
        end
    end

    local pet_info = roleData.pet_info or nil

    if pet_info then
        table.insert(WearInfos, { resID = pet_info.id, colorID = 0, patternID = 0 })
    end

    AddDefaultWearInfo()
    return WearInfos
end

function RoleInfoDecorationSystem.select_use_pspace_rolewear_rsp(res, index, pspace_wear_ext)
    log("RoleInfoDecorationSystem.select_use_pspace_rolewear_rsp res:" .. tostring(res) .. ",index:" .. tostring(index))

    --9910108 表示切换了一个锁住的,有可能是刚过期的,也会回传所有的数据
    local errCodeIsLocked = 9910108 --锁住了
    local errCodeIsSame = 9910110 -- 是相同的
    if res ~= 0 and res ~= errCodeIsLocked and res ~= errCodeIsSame then
        return
    end
    local str = DataMgr.GetMsgByID(4769);
    local showTip = "";
    if index == 4 then
        showTip = string.format(str, "RP");
    else
        showTip = string.format(str, tonumber(index));
    end

    
    --弹出提示，背包切换成功
    DataMgr.ShowNoticeByString(showTip);

    if pspace_wear_ext then
        ProfileMgr.UpdatePspaceWearByUid(RoleInfoSystem.CurShowPlayerInfoUid, pspace_wear_ext)
    end

    DataMgr.pspace_rolewear_index = index
    RoleInfoDecorationSystem.RolewearTabSelectIndex = index;

    RoleInfoDecorationSystem.WearInfos = nil

    HallThemeUtils.ProcSwitchSpaceUseWearBag(index)

    EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_ROLEWEAR_UPDATE);
    EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_SELECT_USE_PSPACE_ROLEWEAR_RSP);
    EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_WARZONE_UPDATE_AVATAR, RoleInfoSystem.CurShowPlayerInfoUid)
end

function RoleInfoDecorationSystem.select_use_pspace_rolewear(index)
    log("select_use_pspace_rolewear:" .. tostring(index))
    NetUtil.SendPkg("select_use_pspace_rolewear", index)
end

return RoleInfoDecorationSystem