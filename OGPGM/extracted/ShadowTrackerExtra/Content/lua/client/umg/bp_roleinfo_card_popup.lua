--个人信息管理UI
RoleInfoCardPopupUI = RoleInfoCardPopupUI or
{
	IsShow = false,
}

--注册widget
function bp_roleinfo_card_popup_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_roleinfo_card_popup,
			{{Path="/Game/UMG/UI_Logic/PersonSpace/RoleInfo_Card_Popup_BP.RoleInfo_Card_Popup_BP_C", Container="Default", ZOrder = BP_ENUM_UI_ROLEINFO_ZORDER + 15}},
			{"Lobby"},
			false,
			false,
			true
	);
end


function RoleInfoCardPopupUI.ShowUI()
	log("RoleInfoCardPopupUI.ShowUI")
	EventCheckCardTab()
	LuaClassObj.HandleDynamicCreation(bp_roleinfo_card_popup)
	LuaClassObj.HandleUIMessageNoFetch(bp_roleinfo_card_popup, "UIShow")

	UIManager.Show(eUIType.eRoleInfoCardPopupUI)
	
	RoleInfoCardPopupUI.IsShow = true
	RoleInfoCardPopupUI.UpdateRoleInfo()
end

function RoleInfoCardPopupUI.HideUI()
	RoleInfoCardPopupUI.IsShow = false
	log("RoleInfoCardPopupUI.HideUI")

	UIManager.Hide(eUIType.eRoleInfoCardPopupUI)
	LuaClassObj.HandleUIMessageNoFetch(bp_roleinfo_card_popup, "UIHide")
end

function RoleInfoCardPopupUI.UpdateRoleInfo()
	LuaClassObj.HandleUIMessageNoFetch(bp_roleinfo_card_popup, "UpdateCard")
end

function RoleInfoCardPopupUI.UpdateCard()
	LuaClassObj.HandleUIMessage(bp_roleinfo_card_popup, "UpdateCard")
end

function RoleInfoCardPopupUI.SetEmptyData()
	LuaClassObj.HandleUIMessageNoFetch(bp_roleinfo_card_popup, "SetEmptyData")
end

function EventRoleInfoCardPopupUI_HideUI()
	RoleInfoCardPopupUI.HideUI()
end
