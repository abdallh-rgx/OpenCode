ItemUpgradeEffectShowSystem = ItemUpgradeEffectShowSystem or
{
	isInit = false,
}

BP_STRUCT_AvatarInfo = 
{
    resID = 401999,
    colorID = 0,
    patternID = 0,
}

-- avartar当前穿着数据
BP_ARRAY_AvatarInfoList = 
{
	BP_STRUCT_AvatarInfo = _G.BP_STRUCT_AvatarInfo;
}

-- avartar 数据
BP_STRUCT_ItemUpgradeSpawnPlayerData = 
{
	gid = "",
	sex = 1,
	headId = 401999,
	index = 1,
	BP_ARRAY_AvatarInfoList = _G.BP_ARRAY_AvatarInfoList,
}

BP_ItemUpgrade_EffectShow_Effect_ID = 0;		-- 效果ID 
BP_ItemUpgrade_EffectShow_Item_ID = 0;			-- 选中物品ID

function bp_itemupgrade_effect_show_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_itemupgrade_effect_show,
        {{Path="/Game/UMG/UI_Logic/Wardrobe/ItemUpgrade_Effect_Show_BP.ItemUpgrade_Effect_Show_BP_C", Container="Default", ZOrder=0}},
        {"Lobby"},
        false,
        false,
        true
    );
end

function EventFetchInfo()

end

function ItemUpgradeEffectShowSystem.Init()
	if ItemUpgradeEffectShowSystem.isInit == false then
		LuaClassObj.HandleDynamicCreation(bp_itemupgrade_effect_show);
		LuaClassObj.HandleUIMessageNoFetch(bp_itemupgrade_effect_show, "Init");
		LuaClassObj.HandleUIMessageNoFetch(bp_itemupgrade_effect_show, "UIShow");
		ItemUpgradeEffectShowSystem.isInit = true;
	end
end

function ItemUpgradeEffectShowSystem.Release()
	if ItemUpgradeEffectShowSystem.isInit == true then
		ItemUpgradeEffectShowSystem.isInit = false;
		ItemUpgradeEffectShowSystem.ClearAll();
		LuaClassObj.HandleUIMessageNoFetch(bp_itemupgrade_effect_show, "UIHide");
	end
end

function ItemUpgradeEffectShowSystem.ClearAll()
	LuaClassObj.HandleUIMessageNoFetch(bp_itemupgrade_effect_show, "ClearAll");
end

function ItemUpgradeEffectShowSystem.HideAll()
	LuaClassObj.HandleUIMessageNoFetch(bp_itemupgrade_effect_show, "HideAll");
end
-------------效果展示-------------------
function ItemUpgradeEffectShowSystem.ShowEffect(weaponID, effectID)
	BP_ItemUpgrade_EffectShow_Item_ID = weaponID;
	BP_ItemUpgrade_EffectShow_Effect_ID = effectID;
	LuaClassObj.HandleUIMessageNoFetch(bp_itemupgrade_effect_show, "ShowEffect");
end