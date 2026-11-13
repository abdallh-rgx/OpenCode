--个人战绩
RoleInfoCombatUI = RoleInfoCombatUI or
{
	
}

--注册widget
function bp_roleinfo_combat_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_roleinfo_combat,
			{{Path="/Game/UMG/UI_Logic/RoleInfo/RoleInfo_Combat_BP.RoleInfo_Combat_BP_C", Container="Default", ZOrder = BP_ENUM_UI_ROLEINFO_ZORDER + 10}},
			{"Lobby"},
			false,
			false,
			true
	);
end


function RoleInfoCombatUI.ShowUI()
	log("RoleInfoCombatUI.ShowUI")	
	LuaClassObj.HandleDynamicCreation(bp_roleinfo_combat)
	LuaClassObj.HandleUIMessageNoFetch(bp_roleinfo_combat, "UIShow")

	UIManager.Show(eUIType.eRoleInfoCombatUI)
	RoleInfoCombatUI.UpdateRoleInfo()

	RoleInfoUI.RequestBattleInfo()
end

function RoleInfoCombatUI.HideUI()
	log("RoleInfoCombatUI.HideUI")
	UIManager.Hide(eUIType.eRoleInfoCombatUI)
	LuaClassObj.HandleUIMessageNoFetch(bp_roleinfo_combat, "UIHide")
end

function RoleInfoCombatUI.UpdateRoleInfo()
	LuaClassObj.HandleUIMessage(bp_roleinfo_combat, "RefreshBattleInfo")
end

function RoleInfoCombatUI.SetShareBtnState()
	LuaClassObj.HandleUIMessage(bp_roleinfo_combat, "SetShareBtnState")
end

function RoleInfoCombatUI.SetSeasonCombatInfo()
	LuaClassObj.HandleUIMessage(bp_roleinfo_combat, "SetSeasonCombatInfo")
end
