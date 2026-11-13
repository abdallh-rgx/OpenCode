--个人信息管理UI
RoleInfoWearUI = RoleInfoWearUI or
		{

		}

--注册widget
function bp_roleinfo_wear_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_roleinfo_wear,
			{{Path="/Game/UMG/UI_Logic/RoleInfo/RoleInfo_Wear_BP.RoleInfo_Wear_BP_C", Container="Default", ZOrder = BP_ENUM_UI_ROLEINFO_ZORDER + 10}},
			{"Lobby"},
			false,
			false,
			true
	);
end


function RoleInfoWearUI.ShowUI()
	log("RoleInfoWearUI.ShowUI")
	LuaClassObj.HandleDynamicCreation(bp_roleinfo_wear)
	LuaClassObj.HandleUIMessageNoFetch(bp_roleinfo_wear, "UIShow")
end

function RoleInfoWearUI.HideUI()
	log("RoleInfoWearUI.HideUI")
	LuaClassObj.HandleUIMessageNoFetch(bp_roleinfo_wear, "UIHide")
end

function RoleInfoWearUI.SetPersonalRoleInfo()
	log("RoleInfoWearUI.HideUI")
	LuaClassObj.HandleUIMessageNoFetch(bp_roleinfo_wear, "SetPersonalRoleInfo")
end

function RoleInfoWearUI.UpdateAvatar()
	LuaClassObj.HandleUIMessageNoFetch(bp_roleinfo_wear, "UpdateAvatar")
end
