--个人信息管理UI
RoleInfoBaseUI = RoleInfoBaseUI or
{
	
}

--注册widget
function bp_roleinfo_base_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_roleinfo_base,
			{{Path="/Game/UMG/UI_Logic/RoleInfo/RoleInfo_Base_BP.RoleInfo_Base_BP_C", Container="Default", ZOrder = BP_ENUM_UI_ROLEINFO_ZORDER + 10}},
			{"Lobby"},
			false,
			false,
			true
	);
end


function RoleInfoBaseUI.ShowUI()
	log("RoleInfoBaseUI.ShowUI")	
	LuaClassObj.HandleDynamicCreation(bp_roleinfo_base)
	LuaClassObj.HandleUIMessageNoFetch(bp_roleinfo_base, "UIShow")
	
	RoleInfoBaseUI.UpdateRoleInfo()
end

function RoleInfoBaseUI.HideUI()
	log("RoleInfoBaseUI.HideUI")
	LuaClassObj.HandleUIMessageNoFetch(bp_roleinfo_base, "UIHide")
end

function RoleInfoBaseUI.UpdateRoleInfo()
	LuaClassObj.HandleUIMessageNoFetch(bp_roleinfo_base, "UpdateRoleInfo");
	LuaClassObj.HandleUIMessageNoFetch(bp_roleinfo_base, "UpdatePlatformRight");
	RoleInfoBaseUI.FreshCorpsInfo()
end


function RoleInfoBaseUI.OnRoleInfoOpen()
	LuaClassObj.HandleUIMessageNoFetch(bp_roleinfo_base, "OnRoleInfoOpen");
end

function RoleInfoBaseUI.RefreshAttrInfo()
	LuaClassObj.HandleUIMessageNoFetch(bp_roleinfo_base, "RefreshAttrInfo");
end

function RoleInfoBaseUI.UpdateAvatar()
	LuaClassObj.HandleUIMessageNoFetch(bp_roleinfo_base, "UpdateAvatar")
end

function RoleInfoBaseUI.UpdateHeadportraitReddot()
	LuaClassObj.HandleUIMessageNoFetch(bp_roleinfo_base, "UpdateHeadportraitReddot")
end

function RoleInfoBaseUI.FreshCorpsInfo()
	LuaClassObj.HandleUIMessageNoFetch(bp_roleinfo_base, "FreshCorpsInfo")
end

function RoleInfoBaseUI.SetPersonalBasicInfo()
	LuaClassObj.HandleUIMessage(bp_roleinfo_base, "SetPersonalBasicInfo")
end

function RoleInfoBaseUI.UpdateAchievementScore()
	log("RoleInfoBaseUI.UpdateAchievementScore")
	LuaClassObj.HandleUIMessageNoFetch(bp_roleinfo_base, "UpdateAchievementScore")
end

function RoleInfoBaseUI.UpdateCarteamInfo()
	log("RoleInfoBaseUI.UpdateCarteamInfo")
	LuaClassObj.HandleUIMessageNoFetch(bp_roleinfo_base, "UpdateCarteamInfo")
end

function RoleInfoBaseUI.UpdateRoleNationInfo()
	LuaClassObj.HandleUIMessage(bp_roleinfo_base, "UpdateRoleNationInfo")
end
