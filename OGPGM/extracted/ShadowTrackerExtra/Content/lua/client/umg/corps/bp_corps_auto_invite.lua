CorpsAutoInviteUI = CorpsAutoInviteUI or {
	idList = {},
	isOnlyShow = true,
}
BP_STRUCT_BASE_INFO = {
    strUid = "",
    Name = "",
    Level = 1,
    Sex = 1,
    RankIntegralLevel = 1,
    IconUrl = "",
    IconFrameID  = 1,
    lastOnlineTimeStr = "",

    -- 绝地通行证
    upass_is_buy = 0, --是否购买(1为已购买，0为未购买)
    upass_is_show = 0, --是否显示(1为显示，0为不显示)
    --国籍
    nation = "",
}

BP_ARRAY_CorpsAutoInviteRoleInfos = {
	BP_STRUCT_BASE_INFO = BP_STRUCT_BASE_INFO
}

BP_ARRAY_CorpsAutoInviteRole = {
	roleId = ""
}
BP_CorpsAutoInvitePlayerId = ""
function bp_corps_auto_invite_RegisterUI()
 	LuaClassObj.SubUIWidgetList(bp_corps_auto_invite,
 		{{Path="/Game/UMG/UI_Logic/Corps/CorpsAutoInvite_BP.CorpsAutoInvite_BP_C", Container="Top", ZOrder=BP_ENUM_UI_CORPS_AUTO_INVITE_ZORDER}},
 		{"Lobby"},
 		false,
 		false,
 		false
 	);
end

function CorpsAutoInviteUI.ShowUI(idList)
	CorpsAutoInviteUI.idList = idList
	LuaClassObj.HandleDynamicCreation(bp_corps_auto_invite)
	LuaClassObj.HandleLobbyUIMessage(bp_corps_auto_invite, "ShowUI")
	UIManager.Show(eUIType.eCorpsAutoInviteUI)
	CorpsAutoInviteUI.UpdatePlayerInfo()

	CorpsAutoInviteUI.ChangeIsOnlyShow(true)
end

function CorpsAutoInviteUI.HideUI()
	UIManager.Hide(eUIType.eCorpsAutoInviteUI)
	LuaClassObj.HandleLobbyUIMessage(bp_corps_auto_invite, "HideUI")
end

function CorpsAutoInviteUI.UpdatePlayerInfo()
	BP_ARRAY_CorpsAutoInviteRoleInfos = {}
	CorpsMgr.GetAvatarBaseInfo(CorpsAutoInviteUI.idList, function(profileList)
		for id,profileInfo in pairs(profileList) do
			table.insert(BP_ARRAY_CorpsAutoInviteRoleInfos, profileInfo)
		end

		LuaClassObj.HandleLobbyUIMessage(bp_corps_auto_invite, "UpdateRoleInfo")
	end, true)
end

function EventCorpsAutoInviteClick()
	local selectIds = {}
	for _, idStr in ipairs(BP_ARRAY_CorpsAutoInviteRole) do
		table.insert(selectIds, tonumber(idStr))
	end
	CorpsMgr.corps_auto_invite_req(selectIds)
end

function EventCorpsAutoInviteShowPlayerInfo()
	local roleId = tonumber(BP_CorpsAutoInvitePlayerId)
    RoleInfoSystem.Enter(roleId)
    RoleInfoUI.Init()
end

function CorpsAutoInviteUI.ChangeIsOnlyShow(isOnlyShow)
	log("CorpsAutoInviteUI.ChangeIsOnlyShow:" .. tostring(isOnlyShow))
	CorpsAutoInviteUI.isOnlyShow = isOnlyShow
	if CorpsAutoInviteUI.isOnlyShow then
		LuaClassObj.HandleUIMessageNoFetch(bp_corps_auto_invite, "UIOnlyShow");
	else
		LuaClassObj.HandleUIMessageNoFetch(bp_corps_auto_invite, "UIOnlyHide");
	end
end

function CorpsAutoInviteUI.GetStatus()
	log("CorpsAutoInviteUI.GetStatus:" .. tostring(CorpsAutoInviteUI.isOnlyShow))
	return {isOnlyShow = CorpsAutoInviteUI.isOnlyShow}
end

function CorpsAutoInviteUI.RecoverStatus(status)
	if status and status.isOnlyShow ~= nil then
		log("CorpsAutoInviteUI.RecoverStatus:" .. tostring(status.isOnlyShow))
		CorpsAutoInviteUI.ChangeIsOnlyShow(status.isOnlyShow)
	end

end