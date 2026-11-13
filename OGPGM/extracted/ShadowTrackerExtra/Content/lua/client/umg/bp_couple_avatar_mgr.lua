CoupleAvatarMgrUI = CoupleAvatarMgrUI or --合影展示Avatar管理
{
    avatars = {},
    openFrom = 0,
    pawnContainer = nil, 
}

BP_STRUCT_Couple_Avatar_Pos = 
{
    X_f = 0, --x坐标
    Y_f = 0,
    Z_f = 0,
}

CoupleAvatarPosType =
{
    Left = 0,
    Right = 1,
}

CoupleAvatarSelfSexType =
{
    Male = 0,
    Female = 1,
}

CoupleAvatarFriendSexType =
{
    Male = 0,
    Female = 1,
}

local AvatarHeight = 89.5

Couple_Avatar_Pos_Config =
{
    [CoupleAvatarSelfSexType.Male] =
    {
        [CoupleAvatarFriendSexType.Male]  =
        {
            [CoupleAvatarPosType.Left] = {X_f = -75, Y_f = 0.0, Z_f = AvatarHeight},
            [CoupleAvatarPosType.Right] = {X_f = -10, Y_f = -25, Z_f = AvatarHeight}
        },

        [CoupleAvatarFriendSexType.Female]  =
        {
            [CoupleAvatarPosType.Left] = {X_f = -75, Y_f = 0.0, Z_f = AvatarHeight},
            [CoupleAvatarPosType.Right] = {X_f = -30, Y_f = -10, Z_f = AvatarHeight}
        }
    },
    [CoupleAvatarSelfSexType.Female] =
    {
        [CoupleAvatarFriendSexType.Male]  =
        {
            [CoupleAvatarPosType.Left] = {X_f = -75, Y_f = 0.0, Z_f = AvatarHeight},
            [CoupleAvatarPosType.Right] = {X_f = -27, Y_f = -13, Z_f = AvatarHeight}
        },

        [CoupleAvatarFriendSexType.Female]  =
        {
            [CoupleAvatarPosType.Left] = {X_f = -75, Y_f = 0.0, Z_f = AvatarHeight},
            [CoupleAvatarPosType.Right] = {X_f = -25, Y_f = -10, Z_f = AvatarHeight}
        }
    },
}

Couple_Avatar_Pos_Single_Config = {X_f = -45, Y_f = 0.0, Z_f = AvatarHeight}

local Couple_Avatar_Pos_Hide_Config = {X_f = 0, Y_f = 0.0, Z_f = 1000}
--Couple_Avatar_Pos_CameraAdapt_Offset = 
--{
--    [0] = {X_f = -50, Y_f = 0.0, Z_f = 91.0},
--    [1] = {X_f = -50, Y_f = 0.0, Z_f = 91.0},
--    [2] = {X_f = -50, Y_f = 0.0, Z_f = 91.0},
--}

Couple_Avatar_OffSet_Config = {
    {X_f=-828.477417 + 25 - Couple_Avatar_Pos_Single_Config.X_f, Y_f = 1043.836182 - Couple_Avatar_Pos_Single_Config.Y_f, Z_f = -5623 - Couple_Avatar_Pos_Single_Config.Z_f},
    {X_f=-45.300003 - Couple_Avatar_Pos_Single_Config.X_f, Y_f = -383.500000 - Couple_Avatar_Pos_Single_Config.Y_f, Z_f = -14347.000000 - Couple_Avatar_Pos_Single_Config.Z_f},
}

--展示信息
BP_STRUCT_Couple_AvatarShowInfo =
{
    AvatarPos_UseExist_BP_STRUCT_Couple_Avatar_Pos = {}, --使用战区排行榜数据结构
    IsRight = false, --自己是否站在右边
    IsFriendMale = false, --朋友的性别
    HasFriend = false, --是否有朋友
    IsSelf = false, --是否是自己
    WearData_UseExist_BP_STRUCT_WarZoneRank_PlayerData = {}, --使用战区排行榜数据结构
    halfHeight = 0
}

BP_STRUCT_FriendBasicInfo = 
{
    IsGet = false,
    RelationShip = 1,
    IsShowInfo = true,
    PersonalBasicInfo_UseExist_BP_STRUCT_PersonalBasicInfo = {}, --个人基本信息
}

BP_Array_Couple_AvatarShowInfo =
{
    BP_STRUCT_Couple_AvatarShowInfo = _G.BP_STRUCT_Couple_AvatarShowInfo
}

CoupleAvatarMgrUIOpenFrom = 
{
    FromWarRank = 0,
    FromRoleInfo = 1,
    FromUpass = 2,
}

function bp_couple_avatar_mgr_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_couple_avatar_mgr,
            {{Path = "/Game/UMG/UI_Logic/PersonSpace/CoupleAvatar_BP.CoupleAvatar_BP_C", Container = "Default", ZOrder = BP_ENUM_UI_ROLEINFO_ZORDER }},
            {"Lobby"},
            false,
            false,
            true
    );
end

--自己默认站在左边，朋友站在右边
--如果自己与朋友是异性，那么女性站在右边，男性站在左边
function CoupleAvatarMgrUI.SelectPos(SelfSex, FriendSex)
    if SelfSex + FriendSex == 1 then --表示男女组合，由于男女组合只有 女男动作
        local Pos = Couple_Avatar_Pos_Config[CoupleAvatarSelfSexType.Female][CoupleAvatarFriendSexType.Male]
        if SelfSex == CoupleAvatarSelfSexType.Female then
            return CoupleAvatarPosType.Right,Pos[CoupleAvatarPosType.Right], CoupleAvatarPosType.Left, Pos[CoupleAvatarPosType.Left]
        else
            return CoupleAvatarPosType.Left,Pos[CoupleAvatarPosType.Left], CoupleAvatarPosType.Right,Pos[CoupleAvatarPosType.Right]
        end
    end
    local Pos = Couple_Avatar_Pos_Config[SelfSex][FriendSex]
    return CoupleAvatarPosType.Left,Pos[CoupleAvatarPosType.Left], CoupleAvatarPosType.Right,Pos[CoupleAvatarPosType.Right]
end

function CoupleAvatarMgrUI.ShowUI(openFrom)
    LuaClassObj.HandleDynamicCreation(bp_couple_avatar_mgr);
    LuaClassObj.HandleUIMessageNoFetch(bp_couple_avatar_mgr, "UIShow");
    
    CoupleAvatarMgrUI.openFrom = openFrom or CoupleAvatarMgrUIOpenFrom.FromRoleInfo
    
    UIManager.Show(eUIType.eCoupleAvatarMgrUI)
    
    BP_STRUCT_FriendBasicInfo = {}
    BP_STRUCT_FriendBasicInfo.IsGet = false
    BP_STRUCT_FriendBasicInfo.IsShowInfo = true

    CoupleAvatarMgrUI.DestroyAvatars() --如果有未销毁的，销毁

    log("CoupleAvatarMgrUI.ShowUI")
    LuaClassObj.HandleUIMessageNoFetch(bp_couple_avatar_mgr, "UpdateAvatarInfo");
end

--从角色数据获取穿戴数据
function CoupleAvatarMgrUI.GetWearDataFromRoleData(roleData)

    local WearData = {} --BP_STRUCT_WarZoneRank_PlayerData
    local wear_ext = roleData.pspace_wear_ext  or {};
    --性别
    WearData.sex = roleData.gender - 1;
    --头
    WearData.headid = wear_ext[9] and wear_ext[9][1] or nil;

    WearData.pet_info = roleData.pet_info or nil
    --着装
    WearData.BP_ARRAY_AvatarList = {}
    local weaponResId = 0;
    local weaponSkinId = 0;
    for k,v in pairs(wear_ext) do
        --服装
        if k >= 1 and k <= 5 or k == 10 then
            table.insert(WearData.BP_ARRAY_AvatarList, LobbyUI.MakeClientAvatarWearInfo(v));
        end
        --武器
        if k == 13 then
            weaponResId = v[1] or 0;
        end
        if k == 14 then
            weaponSkinId = v[1] or 0;
        end
        --log("LobbyUI:CreateRoleInfoPlayer " ..v[1])
    end


    --log_tree("beforerolewear ", WearData.BP_ARRAY_AvatarList);
    local skin_info = roleData.skin_info or {0, 0, 0, 1, 1};
    local head_show = skin_info.head_show or 0;
    local bag_skin = skin_info.bag_skin or 0;
    local helmet_skin = skin_info.helmet_skin or 0;
    local bag_level = skin_info.bag_level or 1;
    local helmet_level = skin_info.helmet_level or 1;
    if(head_show == helmet_skin or head_show == 0) then
        local head = wear_ext[1];
        if(head ~= nil) then
            for i, v in pairs(WearData.BP_ARRAY_AvatarList) do
                if(v.resID == head[1]) then
                    v.resID = 0;
                end
            end
        end
    else
        head_show = 0;
    end

    if(head_show ~= 0) then
        head_show = DataMgr.GetEquipmentItemIDByResID(helmet_level, head_show);
    end

    WearData.weaponResId = weaponResId
    WearData.weaponSkinId = weaponSkinId
    WearData.headShow = head_show
    WearData.bagSkinInsId = DataMgr.GetEquipmentItemIDByResID(bag_level, bag_skin) or 0
    
    --log_tree("rolewear ", WearData.BP_ARRAY_AvatarList);
    
    return WearData
end

function CoupleAvatarMgrUI.UpdateAvatar(roleData, friendRoleData, offset)
    if roleData == nil then
        return
    end

    if friendRoleData == nil then

        log("CoupleAvatarMgrUI.UpdateAvatar friendRoleData == nil")
        
        local wearData = CoupleAvatarMgrUI.GetWearDataFromRoleData(roleData)
        CoupleAvatarMgrUI._UpdateAvatar(wearData, nil, offset)
    else
        log("CoupleAvatarMgrUI.UpdateAvatar friendRoleData ~= nil")
        local wearData = CoupleAvatarMgrUI.GetWearDataFromRoleData(roleData)
        local friendWearData = CoupleAvatarMgrUI.GetWearDataFromRoleData(friendRoleData)

        BP_STRUCT_FriendBasicInfo.RelationShip = 1
        if roleData.partner_info and roleData.partner_info.relation then
            if roleData.partner_info.relation >= 1 and roleData.partner_info.relation <= 4 then
                BP_STRUCT_FriendBasicInfo.RelationShip = roleData.partner_info.relation
            end
        end
        
        CoupleAvatarMgrUI._UpdateAvatar(wearData, friendWearData, offset)
    end
end

function CoupleAvatarMgrUI._ApplyOffset(AvatarPos, offset)
    if offset and  Couple_Avatar_OffSet_Config[offset] then
        local Avatar_OffSet = Couple_Avatar_OffSet_Config[offset]
        AvatarPos.X_f = AvatarPos.X_f + Avatar_OffSet.X_f
        AvatarPos.Y_f = AvatarPos.Y_f + Avatar_OffSet.Y_f
        AvatarPos.Z_f = AvatarPos.Z_f + Avatar_OffSet.Z_f
    end
end

function CoupleAvatarMgrUI._MakeAvatarShowInfo(wearData, friendWearData, offset)
    BP_Array_Couple_AvatarShowInfo = {}

    --log_tree("wearData", wearData)

    if wearData == nil then
        return
    end

    local selfSex = wearData.sex
    if friendWearData == nil then
        local Couple_AvatarShowInfo = {}
        Couple_AvatarShowInfo.AvatarPos = FuncUtil:CopyTable(Couple_Avatar_Pos_Single_Config)
        CoupleAvatarMgrUI._ApplyOffset(Couple_AvatarShowInfo.AvatarPos, offset)

        Couple_AvatarShowInfo.IsRight = false
        Couple_AvatarShowInfo.IsFriendMale = false



        Couple_AvatarShowInfo.HasFriend = false
        Couple_AvatarShowInfo.IsSelf = true
        Couple_AvatarShowInfo.WearData = wearData
        table.insert(BP_Array_Couple_AvatarShowInfo, Couple_AvatarShowInfo)
    else
        local friendSex = friendWearData.sex

        local Couple_AvatarShowInfo = {}

        local SelfPosType, SelfPos, FriendPosType, FriendPos = CoupleAvatarMgrUI.SelectPos(selfSex, friendSex)
        Couple_AvatarShowInfo.AvatarPos = FuncUtil:CopyTable(SelfPos)

        --log_tree("_ApplyOffset SelfPos:", SelfPos)
        --log_tree("_ApplyOffset:", Couple_AvatarShowInfo.AvatarPos)

        CoupleAvatarMgrUI._ApplyOffset(Couple_AvatarShowInfo.AvatarPos, offset)
        Couple_AvatarShowInfo.IsRight = SelfPosType == CoupleAvatarPosType.Right
        Couple_AvatarShowInfo.IsFriendMale = friendSex == CoupleAvatarFriendSexType.Male
        Couple_AvatarShowInfo.HasFriend = true
        Couple_AvatarShowInfo.IsSelf = true
        Couple_AvatarShowInfo.WearData = wearData
        table.insert(BP_Array_Couple_AvatarShowInfo, Couple_AvatarShowInfo)

        local Couple_AvatarShowInfo2 = {}
        Couple_AvatarShowInfo2.AvatarPos = FuncUtil:CopyTable(FriendPos)
        CoupleAvatarMgrUI._ApplyOffset(Couple_AvatarShowInfo2.AvatarPos, offset)
        Couple_AvatarShowInfo2.IsRight = FriendPosType == CoupleAvatarPosType.Right
        Couple_AvatarShowInfo2.IsFriendMale = selfSex == CoupleAvatarSelfSexType.Male
        Couple_AvatarShowInfo2.HasFriend = true
        Couple_AvatarShowInfo2.IsSelf = false
        Couple_AvatarShowInfo2.WearData = friendWearData
        table.insert(BP_Array_Couple_AvatarShowInfo, Couple_AvatarShowInfo2)
    end
    log_tree("BP_Array_Couple_AvatarShowInfo:" , BP_Array_Couple_AvatarShowInfo)
end

function CoupleAvatarMgrUI._GetAvatar(index, euqipments)

    local avatar = CoupleAvatarMgrUI.avatars[index]

    if avatar ~= nil and ((avatar:getSex() ~= euqipments.sex + 1) or avatar:getHeadID() ~= euqipments.headid) then
        avatar:EnableRecyclable(false)
        avatar:Destroy()
        avatar = nil
        CoupleAvatarMgrUI.avatars[index] = nil
    end

    if avatar == nil then
        if euqipments.sex == 1 then
            log("create SEX_FEMALE")
            avatar = LobbyAvatar.Create(LobbyAvatar.SEX_FEMALE, euqipments.headid)
        else
            log("create SEX_MALE")
            avatar = LobbyAvatar.Create(LobbyAvatar.SEX_MALE, euqipments.headid)
        end

    end

    CoupleAvatarMgrUI.avatars[index] = avatar
    return avatar
end

function CoupleAvatarMgrUI._CreatePet(avatar, pet_info)
    if not pet_info or pet_info.id == 0  then
        avatar:DestroyPet()
    else
        local PetSystem = require("client.slua.logic.pet.logic_pet")

        local petLevel = PetSystem.GetPetLevelByExp(pet_info.id, pet_info.exp)
        local pet = avatar:GetPet()
        if pet then
            if pet:GetPetTypeID() ~= pet_info.id or pet:GetLevel() ~= petLevel then
                avatar:DestroyPet()
                avatar:CreatePet(pet_info.id, petLevel)
            end
        else
            avatar:CreatePet(pet_info.id, petLevel)
        end
        pet = avatar:GetPet()

        if pet then
            if pet_info.name then
                pet:SetName(pet_info.name)
            else
                local itemInfo = Client.GetTableData("Item", pet_info.id);
                if itemInfo ~= nil then
                    pet:SetName(itemInfo.ItemName)
                end
            end
        end

    end
end

function CoupleAvatarMgrUI._UpdateAvatar(wearData, friendWearData, offset)
    log("CoupleAvatarMgrUI.UpdateAvatar")

    if wearData == nil then
        return
    end

    CoupleAvatarMgrUI._MakeAvatarShowInfo(wearData, friendWearData, offset)

    CoupleAvatarMgrUI.HideAvatars()

    for i,v in ipairs(BP_Array_Couple_AvatarShowInfo) do
        local euqipments = v.WearData

        local avatar = CoupleAvatarMgrUI._GetAvatar(i, euqipments)

        CoupleAvatarMgrUI._CreatePet(avatar, euqipments.pet_info)

        ----reset -------
        avatar:DetachFromPawnContainer()
        avatar:EnableHatHelmetMutex(false)
        avatar:EnableLobbyShowItem(false)
        avatar:ClearEquipments()
        avatar:SetCanRotate(true)
        ----reset -------

        local pos = v.AvatarPos
        avatar:SetPosition(pos.X_f, pos.Y_f, pos.Z_f)


        if CoupleAvatarMgrUI.openFrom == CoupleAvatarMgrUIOpenFrom.FromRoleInfo or
                CoupleAvatarMgrUI.openFrom == CoupleAvatarMgrUIOpenFrom.FromUpass then
            if friendWearData == nil then
                if euqipments.weaponSkinId ~= 0 then
                    avatar:PutonEquipment(euqipments.weaponSkinId)
                elseif euqipments.weaponResId ~= 0 then
                    avatar:PutonEquipment(euqipments.weaponResId)
                end
            end

            if  euqipments.headShow ~= 0 then
                avatar:PutonEquipment(euqipments.headShow)
            end

            if euqipments.bagSkinInsId ~= 0 then
                avatar:PutonEquipment(euqipments.bagSkinInsId)
            end
        end

        for i,equipmentInfo in ipairs(euqipments.BP_ARRAY_AvatarList) do
           avatar:PutonEquipment(equipmentInfo.resID, equipmentInfo.colorID, equipmentInfo.patternID)
        end

        avatar:ClearFriendData() --先清除数据状态,然后再设置才可以
        if friendWearData ~= nil then
            avatar:SetFriendData(euqipments.sex == 0, v.IsRight, v.IsFriendMale)
        end

        v.halfHeight = avatar:GetHalfheight()
    end

    if #BP_Array_Couple_AvatarShowInfo >= 2 then
        CoupleAvatarMgrUI._ToBeCouple()
    else
        CoupleAvatarMgrUI._ToBeSimlpe()
    end

    -- LuaClassObj.HandleUIMessageNoFetch(bp_couple_avatar_mgr, "UpdateAvatar");

    LuaClassObj.HandleUIMessageNoFetch(bp_couple_avatar_mgr, "UpdateAvatarInfo");
end

function CoupleAvatarMgrUI._ToBeSimlpe()
    if CoupleAvatarMgrUI.pawnContainer ~= nil then
        for i, avatar in ipairs(CoupleAvatarMgrUI.avatars) do
            avatar:DetachFromPawnContainer()
        end
        CoupleAvatarMgrUI.pawnContainer:SetCanRotate(false)
    end
end

--成为一对,旋转是一体的
function CoupleAvatarMgrUI._ToBeCouple()
    if CoupleAvatarMgrUI.pawnContainer == nil then
        CoupleAvatarMgrUI.pawnContainer = LobbyPawnContainer.Create()
    end

    local pos = CoupleAvatarMgrUI.GetCoupleMiddlePos()
    local radius = CoupleAvatarMgrUI.GetCoupleRadius()

    CoupleAvatarMgrUI.pawnContainer:SetPosition(pos.x, pos.y, pos.z)

    if radius ~= 0 then
        CoupleAvatarMgrUI.pawnContainer:SetRadius(radius)
    end

    CoupleAvatarMgrUI.pawnContainer:SetRotation(0, 0, 0) --清空固有的旋转,在avatar attach时,设置旋转为0,0,0 可以生效
    for i, avatar in ipairs(CoupleAvatarMgrUI.avatars) do
        avatar:AttachToPawnContainer(CoupleAvatarMgrUI.pawnContainer)
        avatar:SetCanRotate(false)
        avatar:SetRotation(0, 0, 0)
    end

    CoupleAvatarMgrUI.pawnContainer:SetRotation(0, 0, -15)
    CoupleAvatarMgrUI.pawnContainer:SetCanRotate(true)

end

function CoupleAvatarMgrUI.GetCoupleMiddlePos()
    local pos = {x = 0, y = 0, z = 0}
    if #CoupleAvatarMgrUI.avatars >= 2 then
        local avatar1 = CoupleAvatarMgrUI.avatars[1]
        local avatar2 = CoupleAvatarMgrUI.avatars[2]
        local pos1 = avatar1:GetPosition()
        local pos2 = avatar2:GetPosition()

        pos.x = (pos1.x + pos2.x) / 2
        pos.y = (pos1.y + pos2.y) / 2
        pos.z = (pos1.z + pos2.z) / 2
    end
    
    return pos
end

function CoupleAvatarMgrUI.GetCoupleRadius()
    local radius = 0
    if #CoupleAvatarMgrUI.avatars >= 2 then
        local avatar1 = CoupleAvatarMgrUI.avatars[1]
        local avatar2 = CoupleAvatarMgrUI.avatars[2]
        local pos1 = avatar1:GetPosition()
        local pos2 = avatar2:GetPosition()

        local radius1 = avatar1:GetRadius()
        local radius2 = avatar2:GetRadius()

        local dist = math.sqrt((pos1.x - pos2.x) ^ 2  + (pos1.y - pos2.y) ^ 2 + (pos1.z - pos2.z) ^ 2)

        radius = (dist - radius1 - radius2)/2 + radius1 + radius2
    end
    
    return radius
end

function CoupleAvatarMgrUI.UpdateAvatarInfo(ProfileInfo)
    --log_tree("ProfileInfo", ProfileInfo);
    local creditValue = 100
    if ProfileInfo.credit ~= nil then
        creditValue = ProfileInfo.credit
    end
    local corpsID = 0
    if ProfileInfo.corps_id ~= nil then
        corpsID = ProfileInfo.corps_id
    end

    local PersonalBasicInfo =
    {
        role_name = ProfileInfo.nickName,
        role_id = ProfileInfo.uid,
        role_sex = ProfileInfo.sex - 1,
        role_nation = ProfileInfo.nation,
        role_image = ProfileInfo.picUrl,
        role_upvote = ProfileInfo.upvote or 0,
        role_curlevel = "",
        role_nextlevel = "",
        role_curexpnum = ProfileInfo.exp,
        role_needexpnum = "",
        role_sign = ProfileInfo.signature,
        role_startup_type = GetSafeNumber(ProfileInfo.startup_type),
        role_qqvip = GetSafeNumber(ProfileInfo.qq_vip),
        role_credit = GetSafeNumber(creditValue),
        role_corpsid = corpsID,
        role_upassIsBuy = ProfileInfo.upass.is_buy,
        role_upassUiShow = (ProfileInfo.upass.switch.ui == true) and 1 or 0,
        role_upassLevel = ProfileInfo.upass.level,
        role_aliasId = ProfileInfo.alias.id,
        role_aliasTitle = ProfileInfo.alias.title,
        role_aliasNation = ProfileInfo.alias.nation,
        role_aliasReceiveTime = 0,
        role_aliasExpireTime = 0,
        role_corpAliasId = ProfileInfo.corp_alias_id,
        role_carteamId = ProfileInfo.carteam_id,
    };

    RoleInfoSystem.SetElementToString(PersonalBasicInfo);
    PersonalBasicInfo["role_avatar_frame"] = tonumber(ProfileInfo.cur_avatar_box_id);

    BP_STRUCT_FriendBasicInfo.PersonalBasicInfo = PersonalBasicInfo
    BP_STRUCT_FriendBasicInfo.IsGet = true
    
    log("CoupleAvatarMgrUI.UpdateAvatarInfo" .. tostring(ProfileInfo.uid))
    LuaClassObj.HandleUIMessageNoFetch(bp_couple_avatar_mgr, "UpdateAvatarInfo");
end


function CoupleAvatarMgrUI.OpenAvatarInfo(IsOpen)
    BP_STRUCT_FriendBasicInfo.IsShowInfo = IsOpen
    LuaClassObj.HandleUIMessageNoFetch(bp_couple_avatar_mgr, "UpdateAvatarInfo");
end

function CoupleAvatarMgrUI.HideUI()

    UIManager.Hide(eUIType.eCoupleAvatarMgrUI)
    
    LuaClassObj.HandleUIMessageNoFetch(bp_couple_avatar_mgr, "UIHide");
    -- LuaClassObj.HandleUIMessageNoFetch(bp_couple_avatar_mgr, "DestroyAvatar");
    CoupleAvatarMgrUI.DestroyAvatars()

    CoupleAvatarMgrUI.DestroyPawnContainer()
end

function CoupleAvatarMgrUI.DestroyPawnContainer()
    if CoupleAvatarMgrUI.pawnContainer then
        CoupleAvatarMgrUI.pawnContainer:Destroy()
        CoupleAvatarMgrUI.pawnContainer = nil
    end
end

function CoupleAvatarMgrUI.ResetFriendBasicInfo()
    BP_STRUCT_FriendBasicInfo.IsGet = false
end

function CoupleAvatarMgrUI.HideAvatars()
    log("CoupleAvatarMgrUI.HideAvatars")
    for i, avatar in ipairs(CoupleAvatarMgrUI.avatars) do
        --先隐藏位置
        avatar:SetPosition(Couple_Avatar_Pos_Hide_Config.X_f, Couple_Avatar_Pos_Hide_Config.Y_f, Couple_Avatar_Pos_Hide_Config.Z_f)
    end
end

function CoupleAvatarMgrUI.DestroyAvatars()
    BP_STRUCT_FriendBasicInfo.IsGet = false
    
    for k,v in pairs(CoupleAvatarMgrUI.avatars) do
        v:EnableRecyclable(false)
        v:Destroy()
    end
    CoupleAvatarMgrUI.avatars = {}
end

BP_CoupleAvatarMgrUI_CLICK_UID = ""
function EventCoupleAvatarMgrUI_JumpToRoleInfo()
    local levelUID = nil
    
    if CoupleAvatarMgrUI.openFrom == CoupleAvatarMgrUIOpenFrom.FromRoleInfo then
        levelUID = RoleInfoSystem.CurShowPlayerInfoUid
        RoleInfoUI.HideUI(false)
    end
    
    RoleInfoSystem.Enter(BP_CoupleAvatarMgrUI_CLICK_UID)

    if CoupleAvatarMgrUI.openFrom == CoupleAvatarMgrUIOpenFrom.FromRoleInfo then
        RoleInfoUI.Init(true,RoleInfoOpenFromType.PersonSpace, {uid = levelUID})
    else
        RoleInfoUI.Init(true, RoleInfoOpenFromType.WarZoneRank);
    end
end 