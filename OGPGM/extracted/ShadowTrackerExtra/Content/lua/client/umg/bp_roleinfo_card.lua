--个人信息管理UI
RoleInfoCardUI = RoleInfoCardUI or
{
	
}

--注册widget
function bp_roleinfo_card_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_roleinfo_card,
			{{Path="/Game/UMG/UI_Logic/RoleInfo/RoleInfo_Card_BP.RoleInfo_Card_BP_C", Container="Default", ZOrder = BP_ENUM_UI_ROLEINFO_ZORDER + 10}},
			{"Lobby"},
			false,
			false,
			true
	);
end


function RoleInfoCardUI.ShowUI()
	log("RoleInfoCardUI.ShowUI")	
	LuaClassObj.HandleDynamicCreation(bp_roleinfo_card)
	LuaClassObj.HandleUIMessageNoFetch(bp_roleinfo_card, "UIShow")

	RoleInfoCardUI.UpdateRoleInfo()
end

function RoleInfoCardUI.HideUI()
	log("RoleInfoCardUI.HideUI")
	LuaClassObj.HandleUIMessageNoFetch(bp_roleinfo_card, "UIHide")
end

function RoleInfoCardUI.UpdateRoleInfo()
	LuaClassObj.HandleUIMessageNoFetch(bp_roleinfo_card, "UpdateCard")
end

function RoleInfoCardUI.UpdateCard()
	LuaClassObj.HandleUIMessage(bp_roleinfo_card, "UpdateCard")
end

function RoleInfoCardUI.SetEmptyData()
	LuaClassObj.HandleUIMessageNoFetch(bp_roleinfo_card, "SetEmptyData")
end

function RoleInfoCardUI.UpdateRoleNationInfo()
	LuaClassObj.HandleUIMessage(bp_roleinfo_card, "UpdateRoleNationInfo")
end

function RoleInfoCardUI.SetSignInfo()
	LuaClassObj.HandleUIMessageNoFetch(bp_roleinfo_card, "SetSignInfo")
end

function RoleInfoCardUI.UpdateAvatar()
	LuaClassObj.HandleUIMessageNoFetch(bp_roleinfo_card, "UpdateAvatar")
end



