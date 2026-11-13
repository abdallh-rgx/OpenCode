StoreJumpToChestUI = StoreJumpToChestUI or
{
	isShow = false;
	chestItemId = -1,
	itemId = -1,
}

-- 描述
BP_STORE_JUMP_TO_CHEST_DESC = "";

function bp_store_jump_to_chest_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_store_jump_to_chest,
		{{Path="/Game/UMG/UI_Logic/Store/Comm/Store_Jump_To_Chest_BP.Store_Jump_To_Chest_BP_C", Container="Default", ZOrder=0}},
      	{"Lobby"},
	  	false,
	  	false,
	    true
    );
    log("bp_store_jump_to_chest_RegisterUI")
end

function StoreJumpToChestUI.CheckToShow(itemId)
	log("StoreJumpToChestUI.CheckToShow itemId:"..tostring(itemId))
	local chestItemId = JumpUtils.GetJumpToChestItemId(itemId);
	if chestItemId ~= -1 then
		StoreJumpToChestUI.Show(chestItemId, itemId);
	else
		StoreJumpToChestUI.Hide();
	end
end

function StoreJumpToChestUI.IsNeedShow(itemId)
	log("[edward][bp_store_jump_to_chest] StoreJumpToChestUI.IsNeedShow itemId:"..tostring(itemId));
	local chestItemId = JumpUtils.GetJumpToChestItemId(itemId);
	if chestItemId ~= -1 then
		StoreJumpToChestUI.Show(chestItemId, itemId);
		return true;
	else
		StoreJumpToChestUI.Hide();
		return false;
	end
end

function StoreJumpToChestUI.Show(chestItemId, itemId)
	log("StoreJumpToChestUI.Show")
	StoreJumpToChestUI.isShow = true;
	StoreJumpToChestUI.chestItemId = chestItemId;
	StoreJumpToChestUI.itemId = itemId;
	LuaClassObj.HandleDynamicCreation(bp_store_jump_to_chest);
	LuaClassObj.HandleUIMessageNoFetch(bp_store_jump_to_chest, "UIShow");

	local desc = FuncUtil.GetLocalizeResStr("6644")
	local chestItemCfg = Client.GetTableData("Item", chestItemId);
	if chestItemCfg ~= nil then
		BP_STORE_JUMP_TO_CHEST_DESC = FuncUtil.LocalizeResFormatByStr(desc, chestItemCfg.ItemName);
	end
	LuaClassObj.HandleUIMessageNoFetch(bp_store_jump_to_chest, "UpdateDesc");
	UIManager.Show(eUIType.eStoreJumpToChest);
end

function StoreJumpToChestUI.Hide()
	if not StoreJumpToChestUI.isShow then
		return;
	end
	LuaClassObj.HandleUIMessageNoFetch(bp_store_jump_to_chest, "UIHide");
	UIManager.Hide(eUIType.eStoreJumpToChest);
end

function EventStoreJumpToChestClickJump()
	if StoreJumpToChestUI.chestItemId ~= -1 then
		JumpUtils.JumpAll(JumpUtils.MODEL_ID_STORE, StoreJumpToChestUI.chestItemId);
		StoreJumpToChestUI.Hide();
	else
		log("EventStoreJumpToChestClickJumpm StoreJumpToChestUI.itemId:"..tostring(StoreJumpToChestUI.itemId));
	end
end