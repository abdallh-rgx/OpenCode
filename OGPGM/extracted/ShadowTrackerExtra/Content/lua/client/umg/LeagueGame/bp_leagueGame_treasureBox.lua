--奖励预览界面

LeagueGameTreasureBoxUI = LeagueGameTreasureBoxUI or {}

BP_STRUCT_Reward_Group = 
{
    Rank_Max = 1,
    Rank_Min = 1,
    RewardID = 1,
}

BP_STRUCT_Reward_Item = 
{
    RewardID = 1,
    itemID = 1,
    itemCount = 1,
    itemTime = 0,
}

BP_ARRAY_Reward_Group_List = 
{
    BP_STRUCT_Reward_Group = _G.BP_STRUCT_Reward_Group
}

BP_ARRAY_Reward_Item_List = 
{
    BP_STRUCT_Reward_Item = _G.BP_STRUCT_Reward_Item
}

BP_AllianceCompetitionShop_Test = 0
-- 点选的道具ID
BP_LeagueGameBoxPreSelectItemId = 0
-- 显示道具类型
BP_LeagueGameBox_Show_Item_type = ""
-- 详细道具信息
BP_LeagueGameBox_Show_Detail_ResId = 0
-- 操作的道具ID
BP_LeagueGameBox_operateShopId = 0
--操作的道具组索引
BP_LeagueGameBox_operateGroupIndex = 0
-- 展示3D模型
BP_LeagueGameBox_ShowAvatar = true;

local _avatar = nil

--注册Widget
function bp_leagueGame_treasureBox_RegisterUI()
    log("Qpp!~~~~~~~~~~~~~~~~~~~")
    LuaClassObj.SubUIWidgetList(bp_leagueGame_treasureBox,
        {{Path="/Game/UMG/UI_Logic/LeagueGame/LeagueGame_TreasureBox_BP.LeagueGame_TreasureBox_BP_C", Container="Default", ZOrder= BP_ENUM_UI_LEAGUEGAME_LOBBY + 1}},
        {"Lobby"},
        false,
        false,
        true
    );
end

function LeagueGameTreasureBoxUI.ShowUI()
    log("Qpp Enter Show UI")
    if LeagueGameSystem.StageId == LeagueGameSystem.LEAGUE_STAGE_ENROLL then
        --EventLeagueGameSignUpHide()
        LeagueGameSignUpUI.SetInvisible()
    else
        --EventLeagueInfoHide()
        LeagueGameLeagueInfoUI.SetInvisible()
    end
    LuaClassObj.HandleUIMessage(bp_lobby, "UIShowFromMall");
    -- LobbyUI:ShowLobbyPlayer(true);

    LuaClassObj.HandleDynamicCreation(bp_leagueGame_treasureBox)
    EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN)
    -- LuaClassObj.HandleUIMessage(bp_lobby, "EndLobbyToMall")
    LuaClassObj.HandleUIMessageNoFetch(bp_leagueGame_treasureBox, "UIShow")
    LuaClassObj.HandleUIMessageNoFetch(bp_leagueGame_treasureBox, "SwitchScene")
    LobbySceneManager.ShowMesh(LobbySceneManager.MALL_MESH_LobbyBgMesh)
    -- LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "ShowMallPlayer")
    LeagueGameTreasureBoxUI.SetRewardGroup()

    if _avatar ~= nil then
        _avatar:Destroy()
    end

    local showPosition = {}
    showPosition.x = -10
    showPosition.y = -383
    showPosition.z = -14347
    _avatar = GenderAvatar.CreateMyself(showPosition)
    _avatar:FixGender()
end

function LeagueGameTreasureBoxUI.Hide(isNeedShowLeague)
    EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE)
    if _avatar ~= nil then
        _avatar:Destroy()
    end
    -- LeagueGameTreasureBoxUI.ResetItemAvatar()
    -- LuaClassObj.HandleUIMessage(bp_lobby, "StartMallToLobby")
    LuaClassObj.HandleUIMessage(bp_lobby, "UIShowFromMall")
    
    LuaClassObj.HandleUIMessageNoFetch(bp_leagueGame_treasureBox, "UIHide")
    if isNeedShowLeague then
        if LeagueGameSystem.StageId == LeagueGameSystem.LEAGUE_STAGE_ENROLL then
            --LeagueGameSignUpUI.Init()
            LeagueGameSignUpUI.SetVisible()
        else
            --LeagueGameLobbyUI.Init()
            LeagueGameLeagueInfoUI.SetVisible()
        end
    end
end

function LeagueGameTreasureBoxUI.SetRewardGroup()
    local data = LeagueGameSystem.LeagueRewardListTable;
    log_tree("QppLeagueRewardListTable:", data)
    BP_ARRAY_Reward_Group_List = {}
    for _, v in pairs(data) do
        if(v.client_show ~= 0)then
            local group ={};
            group.RewardID = v.reward_id;
            group.Rank_Min = v.rank_min;
            group.Rank_Max = v.rank_max;
            table.insert(BP_ARRAY_Reward_Group_List, group); 
        end
    end
    table.sort(BP_ARRAY_Reward_Group_List, function (a, b) return a.Rank_Min < b.Rank_Min end)
    log_tree("Qpp~~~~~~~~~~~~~~~~~~~~~~~~~~~BP_ARRAY_Reward_Group_List", BP_ARRAY_Reward_Group_List)
    LeagueGameTreasureBoxUI.SetRewardItem()
end

function LeagueGameTreasureBoxUI.SetRewardItem()
    local rewardCfg = LeagueGameSystem.LeagueRewardItemCfg;
    log_tree("rewardCfg", rewardCfg)
    BP_ARRAY_Reward_Item_List = {}
    for i, v in pairs(rewardCfg) do
        log_tree("Qpp==========",v.show_reward)
        for _, j in pairs(v.show_reward) do
            local item ={}
            item.RewardID = i;
            item.itemID = j.item_id;
            item.itemCount = j.item_num;
            item.itemTime = j.item_expire_time;
            table.insert(BP_ARRAY_Reward_Item_List, item)
        end
    end
    log_tree("Qpp~~~~~~~~~~~~~~~~~~~~~~~~~~~BP_ARRAY_Reward_Item_List", BP_ARRAY_Reward_Item_List)
    log_tree("Qpp~~~~~~~~~~~~~~~~~~~~~~~~~~~BP_ARRAY_Reward_Group_List", BP_ARRAY_Reward_Group_List)
    LuaClassObj.HandleUIMessageNoFetch(bp_leagueGame_treasureBox, "UpdateRewardGroup")
end

-- 道具Id转预览展示道具Id
function LeagueGameTreasureBoxUI.ToPreviewItemId(itemId)
    local cfg = Client.GetTableData("Item", itemId);
    if nil == cfg then
        return itemId
    end
    local cfg2 = Client.GetTableData("BackpackMapping", itemId)
    if nil == cfg2 then
        return itemId
    end
    return cfg2.SkinItemIDLv3
end

function EventTreatureBoxItemClick()
    log("EventTreatureBoxItemClick BP_LeagueGameBox_operateShopId ".. BP_LeagueGameBox_operateShopId)
    LeagueGameTreasureBoxUI.ShowItemInfo(BP_LeagueGameBox_operateShopId)
    LuaClassObj.HandleUIMessageNoFetch(bp_leagueGame_treasureBox, "UpdateSelectItem")
end

function EventTreatureBoxHide()
    LeagueGameTreasureBoxUI.Hide(true);
end

---------------------------------------人物处理-----------------------------------------
-- 穿着判断
-- LeagueGameTreasureBoxUI.AVATAR_KEY = "LeagueGameTreasureBox"

-- -- 当前穿着模式
-- LeagueGameTreasureBoxUI.AVATAR_MOD_NORMAL = 1
-- LeagueGameTreasureBoxUI.AVATAR_MOD_BOX = 2

-- LeagueGameTreasureBoxUI.wearMode = LeagueGameTreasureBoxUI.AVATAR_MOD_NORMAL
-- LeagueGameTreasureBoxUI.previewWearInfo =
-- {
--     [LeagueGameTreasureBoxUI.AVATAR_MOD_NORMAL] = {},
--     [LeagueGameTreasureBoxUI.AVATAR_MOD_BOX] = {},
-- };

-- -- 预览人物装备切换
-- function LeagueGameTreasureBoxUI.SwitchWearMode(wearMode)
--     log("AllianceCompetitionShopUI.SwitchWearMode "..wearMode)

--     local wearOff = {}
--     local wearOn = {}

--     if wearMode == LeagueGameTreasureBoxUI.AVATAR_MOD_NORMAL then
--         wearOff = LeagueGameTreasureBoxUI.previewWearInfo[LeagueGameTreasureBoxUI.AVATAR_MOD_BOX]
--         wearOn = LeagueGameTreasureBoxUI.previewWearInfo[LeagueGameTreasureBoxUI.AVATAR_MOD_NORMAL]
--     else
--         wearOff = LeagueGameTreasureBoxUI.previewWearInfo[LeagueGameTreasureBoxUI.AVATAR_MOD_NORMAL]
--         wearOn = LeagueGameTreasureBoxUI.previewWearInfo[LeagueGameTreasureBoxUI.AVATAR_MOD_BOX]
--     end

--     --脱下衣服
--     for k, v in pairs(wearOff) do
--         local itemId = v.resId
--         local cfg = Client.GetTableData("Item", itemId);
--         if nil ~= cfg and cfg.ItemType == 1 then
--             LobbyUI:UnEquipWeapon(DataMgr.roleData.uid, LeagueGameTreasureBoxUI.AVATAR_KEY);
--         else
--             LobbyUI:AvatarChange(v, false, LeagueGameTreasureBoxUI.AVATAR_KEY);
--         end
--     end

--     --穿上衣服
--     for k, v in pairs(wearOn) do
--         local itemId = v.resId
--         local cfg = Client.GetTableData("Item", itemId);
--         if nil ~= cfg and cfg.ItemType == 1 then
--             LobbyUI:EquipWeapon(DataMgr.roleData.uid, itemId, 0, LeagueGameTreasureBoxUI.AVATAR_KEY);
--         else
--             LobbyUI:AvatarChange(v, true, LeagueGameTreasureBoxUI.AVATAR_KEY);
--         end
--     end

--     LeagueGameTreasureBoxUI.wearMode = wearMode
-- end

-- -- 还原人物
-- function LeagueGameTreasureBoxUI.ResetItemAvatar()
--     -- 脱下预览
--     for k,v in pairs(LeagueGameTreasureBoxUI.previewWearInfo[LeagueGameTreasureBoxUI.wearMode]) do
--         LobbyUI:AvatarChange(v, false, LeagueGameTreasureBoxUI.AVATAR_KEY);
--     end

--     -- 还原真实穿戴
--     for k,v in pairs(DataMgr.rolewear) do
--         local itemInfo = DataMgr.GetHallDepotItemDataByInsID(v);
--         if itemInfo ~= nil then
--             LobbyUI:AvatarChange(LobbyUI:CreateAvatarChangeData(DataMgr.roleData.uid, itemInfo.resID), true, LeagueGameTreasureBoxUI.AVATAR_KEY);
--         end
--     end
--     LeagueGameTreasureBoxUI.previewWearInfo[LeagueGameTreasureBoxUI.wearMode] = {}

--     --还原枪
--     local weaponId = DataMgr.GetCurrentWeaponID()
--     if weaponId == 0 then
--         LobbyUI:UnEquipWeapon(DataMgr.roleData.uid, LeagueGameTreasureBoxUI.AVATAR_KEY);
--     else
--         LobbyUI:EquipWeapon(DataMgr.roleData.uid, weaponId, 0, LeagueGameTreasureBoxUI.AVATAR_KEY);
--     end
--     --显示玩家
--     -- LuaClassObj.HandleUIMessage(bp_lobby, "ShowMallPlayer");
-- end

-- 卸载人物部分
-- function LeagueGameTreasureBoxUI.ClearPart(part)
--     local wearInfo = LeagueGameTreasureBoxUI.previewWearInfo[LeagueGameTreasureBoxUI.wearMode]
--     if wearInfo[part] then
--         LobbyUI:AvatarChange(wearInfo[part], false, LeagueGameTreasureBoxUI.AVATAR_KEY);
--         wearInfo[part] = nil;
--     end
-- end

-- 穿着服装
function LeagueGameTreasureBoxUI.ShowItemAvatar(itemId)
    _avatar:PutonOrPutoff(itemId)
    -- local itemCfg = Client.GetTableData("Item", itemId);
    -- if not itemCfg then
    --     return;
    -- end
    -- local part = itemCfg.ItemSubType
    -- local wearInfo = LeagueGameTreasureBoxUI.previewWearInfo[LeagueGameTreasureBoxUI.wearMode]

    -- if itemCfg.ItemType == 1 then --武器
    --     if wearInfo[part] then
    --         if BP_LeagueGameBoxPreSelectItemId == itemId then --连续选择两次，武器改成原来的
    --             LobbyUI:UnEquipWeapon(DataMgr.roleData.uid, LeagueGameTreasureBoxUI.AVATAR_KEY);
    --             local weaponId = DataMgr.GetCurrentWeaponID();
    --             if weaponId ~= 0 then
    --                 LobbyUI:EquipWeapon(DataMgr.roleData.uid, weaponId, 0, LeagueGameTreasureBoxUI.AVATAR_KEY);
    --             end
    --             wearInfo[part] = nil;
    --         else
    --             wearInfo[part] = LobbyUI:CreateAvatarChangeData(DataMgr.roleData.uid, itemId);
    --             LobbyUI:EquipWeapon(DataMgr.roleData.uid, itemId, 0, LeagueGameTreasureBoxUI.AVATAR_KEY);
    --         end
    --     else
    --         wearInfo[part] = LobbyUI:CreateAvatarChangeData(DataMgr.roleData.uid, itemId);
    --         LobbyUI:EquipWeapon(DataMgr.roleData.uid, itemId, 0, LeagueGameTreasureBoxUI.AVATAR_KEY);
    --     end
    -- elseif itemCfg.ItemType == 4 and part then --形象
    --     --帽子去掉头盔
    --     if itemCfg.ItemSubType == 401 then
    --         LeagueGameTreasureBoxUI.ClearPart(502)
    --         LeagueGameTreasureBoxUI.ClearPart(505)
    --     end

    --     if wearInfo[part] then
    --         if BP_LeagueGameBoxPreSelectItemId == itemId then --连续选择了两次，脱下
    --             LobbyUI:AvatarChange(wearInfo[part], false, LeagueGameTreasureBoxUI.AVATAR_KEY);
    --             wearInfo[part] = nil;
    --         else
    --             wearInfo[part] = LobbyUI:CreateAvatarChangeData(DataMgr.roleData.uid, itemId);
    --             LobbyUI:AvatarChange(wearInfo[part], true, LeagueGameTreasureBoxUI.AVATAR_KEY);
    --         end
    --     else
    --         wearInfo[part] = LobbyUI:CreateAvatarChangeData(DataMgr.roleData.uid, itemId);
    --         LobbyUI:AvatarChange(wearInfo[part], true, LeagueGameTreasureBoxUI.AVATAR_KEY);
    --     end
    -- elseif itemCfg.ItemType == 5 and part then
    --     if itemCfg.ItemSubType == 501 or itemCfg.ItemSubType == 504 then
    --         --背包
    --         if wearInfo[part] then
    --             if BP_LeagueGameBoxPreSelectItemId == itemId then --连续选择了两次，脱下
    --                 LobbyUI:AvatarChange(wearInfo[part], false, LeagueGameTreasureBoxUI.AVATAR_KEY);
    --                 wearInfo[part] = nil;
    --             else
    --                 wearInfo[part] = LobbyUI:CreateAvatarChangeData(DataMgr.roleData.uid, itemId);
    --                 LobbyUI:AvatarChange(wearInfo[part], true, LeagueGameTreasureBoxUI.AVATAR_KEY);
    --             end
    --         else
    --             wearInfo[part] = LobbyUI:CreateAvatarChangeData(DataMgr.roleData.uid, itemId);
    --             LobbyUI:AvatarChange(wearInfo[part], true, LeagueGameTreasureBoxUI.AVATAR_KEY);
    --         end
    --     elseif itemCfg.ItemSubType == 502 or itemCfg.ItemSubType == 505 then
    --         --头盔
    --         --去掉帽子
    --         LeagueGameTreasureBoxUI.ClearPart(401)

    --         if wearInfo[part] then
    --             if BP_LeagueGameBoxPreSelectItemId == itemId then --连续选择了两次，脱下
    --                 LobbyUI:AvatarChange(wearInfo[part], false, LeagueGameTreasureBoxUI.AVATAR_KEY);
    --                 wearInfo[part] = nil;
    --             else
    --                 wearInfo[part] = LobbyUI:CreateAvatarChangeData(DataMgr.roleData.uid, itemId);
    --                 LobbyUI:AvatarChange(wearInfo[part], true, LeagueGameTreasureBoxUI.AVATAR_KEY);
    --             end
    --         else
    --             wearInfo[part] = LobbyUI:CreateAvatarChangeData(DataMgr.roleData.uid, itemId);
    --             LobbyUI:AvatarChange(wearInfo[part], true, LeagueGameTreasureBoxUI.AVATAR_KEY);
    --         end
    --     else
    --         --
    --     end
    -- else
    --     --do nothing
    -- end
end

-- 点击商店道具
function LeagueGameTreasureBoxUI.ShowItemInfo(itemId)
    local itemDataCfg = Client.GetTableData("Item", itemId);
    local showItemDetail = true;

    if itemDataCfg then
        if itemDataCfg.ItemType == 1 then
            if itemDataCfg.ItemSubType == 801 then
                BP_LeagueGameBox_Show_Item_type = "tool";	--平底锅
            else
                BP_LeagueGameBox_Show_Item_type = "weapon";--武器
                showItemDetail = false;
                LeagueGameTreasureBoxUI.ShowItemAvatar(itemId);
            end

        elseif itemDataCfg.ItemType == 22 then
            BP_LeagueGameBox_Show_Item_type = "dance";--舞蹈
            showItemDetail = false;
            LobbyUI:ShowEmoteAction(DataMgr.roleData.uid, itemId, nil, nil, 1);

        elseif itemDataCfg.ItemType == 4 and itemDataCfg.ItemSubType == 701 then
            BP_LeagueGameBox_Show_Item_type = "parachute";--降落伞

        elseif itemDataCfg.ItemType == 8 and itemDataCfg.ItemSubType == 801 then
            BP_LeagueGameBox_Show_Item_type = "aircraft";--飞机皮肤

        elseif itemDataCfg.ItemType == 5 then
            if itemDataCfg.ItemSubType == 501 or itemDataCfg.ItemSubType == 504 then
                BP_LeagueGameBox_Show_Item_type = "image";	--背包
                showItemDetail = false;
                itemId = LeagueGameTreasureBoxUI.ToPreviewItemId(itemId)
                LeagueGameTreasureBoxUI.ShowItemAvatar(itemId);

            elseif itemDataCfg.ItemSubType == 502 or itemDataCfg.ItemSubType == 505 then
                BP_LeagueGameBox_Show_Item_type = "image";	--头盔
                showItemDetail = false;
                itemId = LeagueGameTreasureBoxUI.ToPreviewItemId(itemId)
                LeagueGameTreasureBoxUI.ShowItemAvatar(itemId);
            else
                BP_LeagueGameBox_Show_Item_type = "tool";	--道具
            end

        elseif itemDataCfg.ItemType == 4 then
            BP_LeagueGameBox_Show_Item_type = "image";--形象
            showItemDetail = false;
            LeagueGameTreasureBoxUI.ShowItemAvatar(itemId);

        elseif itemDataCfg.ItemType == 9 then
            BP_LeagueGameBox_Show_Item_type = "car";	--载具
        else
            BP_LeagueGameBox_Show_Item_type = "tool";--默认为道具
        end

        log(string.format("[yyc] ShowItemInfo item type = %s", BP_LeagueGameBox_Show_Item_type));
        BP_LeagueGameBox_Show_Detail_ResId = itemId;
        if showItemDetail then
            -- LuaClassObj.HandleUIMessage(bp_unknow_pass, "ShowItemDetail");
            _avatar:HideAvatar()

        else
            -- LuaClassObj.HandleUIMessage(bp_unknow_pass, "HideItemDetail");
            _avatar:ShowAvatar()
        end

        BP_LeagueGameBoxPreSelectItemId = itemId;
        BP_LeagueGameBox_ShowAvatar = showItemDetail;

        -- LuaClassObj.HandleUIMessage(bp_unknow_pass, "ShowItemDes");
    end
end

--------------------------------------------------------点选道具处理完结----------------------------------------------
