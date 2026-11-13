--个人信息管理UI

BP_AchiTabsAnimPlayed = false

RoleInfoAchievementUI = RoleInfoAchievementUI or
{
	
}

--注册widget
function bp_roleinfo_achievement_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_roleinfo_achievement,
			{{Path="/Game/UMG/UI_Logic/RoleInfo/RoleInfo_Achievement_BP.RoleInfo_Achievement_BP_C", Container="Default", ZOrder = BP_ENUM_UI_ROLEINFO_ZORDER + 10}},
			{"Lobby"},
			false,
			false,
			true
	);
end


function RoleInfoAchievementUI.ShowUI()
	log("RoleInfoAchievementUI.ShowUI")	
	LuaClassObj.HandleDynamicCreation(bp_roleinfo_achievement)
	LuaClassObj.HandleUIMessageNoFetch(bp_roleinfo_achievement, "UIShow")

	UIManager.Show(eUIType.eRoleInfoAchievementUI)
	
	RoleInfoAchievementUI.UpdateAchievementSlots()
	RoleInfoAchievementUI.UpdateAchievementSummary()
	RoleInfoAchievementUI.UpdateAchievementScore()
	RoleInfoCardUI.UpdateRoleInfo()
end

function RoleInfoAchievementUI.HideUI()
	log("RoleInfoAchievementUI.HideUI")

	UIManager.Hide(eUIType.eRoleInfoAchievementUI)
	LuaClassObj.HandleUIMessageNoFetch(bp_roleinfo_achievement, "UIHide")
end

function RoleInfoAchievementUI.UpdateAchievementSlots()
	log("RoleInfoAchievementUI.UpdateAchievementSlots")
	LuaClassObj.HandleUIMessageNoFetch(bp_roleinfo_achievement, "UpdateAchievementSlots")
end

function RoleInfoAchievementUI.UpdateAchievementSummary()
	log("RoleInfoAchievementUI.UpdateAchievementSummary")
	LuaClassObj.HandleUIMessageNoFetch(bp_roleinfo_achievement, "UpdateAchievementSummary")
end

function RoleInfoAchievementUI.UpdateAchievementScore()
	log("RoleInfoAchievementUI.UpdateAchievementScore")
	LuaClassObj.HandleUIMessageNoFetch(bp_roleinfo_achievement, "UpdateAchievementScore")
end

function RoleInfoAchievementUI.UpdateRoleInfo()
	LuaClassObj.HandleUIMessageNoFetch(bp_roleinfo_achievement, "UpdateAchievementIsMe")
end
