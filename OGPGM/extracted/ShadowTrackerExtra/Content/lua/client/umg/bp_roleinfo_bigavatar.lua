--大头像UI
RoleInfoBigAvatarUI = RoleInfoBigAvatarUI or
{
}

BP_RoleInfoBigAvatar_URL = ""
BP_RoleInfoBigAvatar_SEX = 0

--注册Widget
function bp_roleinfo_bigavatar_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_roleinfo_bigavatar,
		{{Path="/Game/UMG/UI_BP/RoleInfo/Lobby_RoleInfo_BigAvatar_UIBP.Lobby_RoleInfo_BigAvatar_UIBP_C", Container="Default", ZOrder=BP_ENUM_UI_ROLEINFO_ZORDER+2}},
		{"Lobby"},
		false,
		false,
		true
	);
end

function RoleInfoBigAvatarUI.Show(url,sex)
    LuaClassObj.HandleDynamicCreation(bp_roleinfo_bigavatar);
    BP_RoleInfoBigAvatar_URL = url
    BP_RoleInfoBigAvatar_SEX = sex
    RoleInfoBigAvatarUI.URLModify()
    LuaClassObj.HandleUIMessage(bp_roleinfo_bigavatar, "ShowUI");
	UIManager.Show(eUIType.eRoleInfoBigAvatarUI)
end

function RoleInfoBigAvatarUI.URLModify()
	if string.find(BP_RoleInfoBigAvatar_URL, "facebook") ~= nil then
		BP_RoleInfoBigAvatar_URL = string.gsub(BP_RoleInfoBigAvatar_URL, "width=100", "width=640");
		BP_RoleInfoBigAvatar_URL = string.gsub(BP_RoleInfoBigAvatar_URL, "height=100", "height=640");
	elseif string.find(BP_RoleInfoBigAvatar_URL, "twimg") ~= nil then
		BP_RoleInfoBigAvatar_URL = string.gsub(BP_RoleInfoBigAvatar_URL, "_normal", "");
	elseif string.find(BP_RoleInfoBigAvatar_URL, "wx.qlogo.cn") ~= nil then
		BP_RoleInfoBigAvatar_URL = string.gsub(BP_RoleInfoBigAvatar_URL, "/132", "/0");
	elseif string.find(BP_RoleInfoBigAvatar_URL, "googleusercontent") ~= nil then
		BP_RoleInfoBigAvatar_URL = string.gsub(BP_RoleInfoBigAvatar_URL, "sz=50", "sz=640");
	end
	--log("RoleInfoBigAvatarUI.URLModify:" .. BP_RoleInfoBigAvatar_URL);
end

function EventRoleInfoBigAvatar_Hide()
	UIManager.Hide(eUIType.eRoleInfoBigAvatarUI)
end

