--个人信息页面中展开信息UI

RoleInfoShowInfoUI = RoleInfoShowInfoUI or
{
	CurrentChangeState = 1; --小红点隐藏状态，如果是0表示是预览称号，1表示默认状态和使用称号，1会刷新界面。
	isNeedGuide = false;
	bShow = false;
}

BP_Current_CheckBox = -1; --当前选中项，0表示个人称号，1表示国家旗帜，2表示头像，3表示头像框
BP_ShowInfo_ShowPersonalTitleReddot = false; -- 个人称号小红点
BP_ShowInfo_ShowHeadportraitReddot = false; -- 头像小红点
BP_ShowInfo_ShowHeadportraitFrameReddot = false; -- 头像框小红点

--注册Widget
function bp_lobby_roleinfo_showinformation_RegisterUI()
	log("bp_lobby_roleinfo_showinformation_RegisterUI")
	LuaClassObj.SubUIWidgetList(bp_lobby_roleinfo_showinformation,
		{{Path="/Game/UMG/UI_Logic/Lobby/Lobby_RoleInfo_ShowInformation_BP.Lobby_RoleInfo_ShowInformation_BP_C", Container="Default", ZOrder=BP_ENUM_UI_ROLEINFO_ZORDER+20}},
		{"Lobby"},
		false,
		false,
		true
	);
end


function RoleInfoShowInfoUI.Show()
	log("RoleInfoShowInfoUI.Show")
	LuaClassObj.HandleDynamicCreation(bp_lobby_roleinfo_showinformation);
	LuaClassObj.HandleUIMessage(bp_lobby_roleinfo_showinformation, "ShowUI");
	UIManager.Show(eUIType.eRoleInfoShowInformation)
	RoleInfoShowInfoUI.bShow = true;

	if BP_Current_CheckBox == 2 then
		UIManager.Show(eUIType.eHeadportrait)
	elseif BP_Current_CheckBox == 3 then
		UIManager.Show(eUIType.eAvatarframe)
	elseif BP_Current_CheckBox == 4 then
		UIManager.Show(eUIType.ePersonSpaceSecrecySettingUI)
	end
end


function RoleInfoShowInfoUI.Hide()
	log("RoleInfoShowInfoUI Hide");
	RoleInfoShowInfoUI.bShow = false;
	UIManager.Hide(eUIType.eRoleInfoShowInformation)
	LuaClassObj.HandleUIMessage(bp_lobby_roleinfo_showinformation, "HideUI");
	RoleInfoAliasUI.BP_ALIAS_OPEN_TYPE = 0; -- 重置个人称号界面类型为大厅类型
end

function RoleInfoShowInfoUI.SafeHide()
	if RoleInfoShowInfoUI.bShow then
		RoleInfoShowInfoUI.Hide();
	end
end

function EventHideShowInfoWidget()
	log("EventHideShowInfoWidget");
	RoleInfoShowInfoUI.Hide();
end

-- 个人称号
function EventShowPersonalTitle()
	log("EventShowPersonalTitle");
	RoleInfoAliasUI.BP_ALIAS_OPEN_TYPE = 1;
	RoleInfoAliasUI.Init();
end

-- 国家旗帜
function EventShowCountryareaFlag()
	log("EventShowCountryareaFlag");
	CountryareaUI.ShowFromRoleInfo();
end

-- 切换头像
function EventRoleInfoShowReplaceHeadportrait()
	log("EventRoleInfoShowReplaceHeadportrait");
	RoleInfoHeadportraitUI.Show();
	RoleInfoHeadportraitSystem.Init();
end

-- 切换头像框
function EventRoleInfoShowReplaceHeadportraitFrame()
	log("EventRoleInfoShowReplaceHeadportraitFrame");
	RoleInfoAvatarFrameSystem.Enter();
	RoleInfoAvatarFrameUI.Init();
end

-- 切换个人空间隐私设置
function EventShowPersonSpaceSececy()
	log("EventShowPersonSpaceSececy");
	PersonSpaceSecrecySettingUI.ShowUI()
end

-- 隐藏所有界面
function EventRoleInfoHideAllView()
	log("EventRoleInfoHideAllView");
	-- 隐藏个人称号界面
	RoleInfoAliasUI.Hide()
	-- 隐藏旗帜选择界面
	CountryareaUI.HideUI2()
	-- 隐藏头像选择界面
	RoleInfoHeadportraitUI.HideUI()
	-- 隐藏头像框选择界面
	RoleInfoAvatarFrameUI.HideUI()

	PersonSpaceSecrecySettingUI.HideUI()
end

-- 更新菜单栏按钮红点
function EventRefreshMenuReddot()
    BP_ShowInfo_ShowPersonalTitleReddot = RoleInfoAliasSystem.hasRedpoint(); -- 个人称号小红点
    BP_ShowInfo_ShowHeadportraitReddot = RoleInfoHeadportraitSystem.HaveNewHeadportrait(); -- 头像小红点
    BP_ShowInfo_ShowHeadportraitFrameReddot = RoleInfoAvatarFrameSystem.HaveNew(); -- 头像框小红点
	log("[LLB]EventRefreshMenuReddot, BP_ShowInfo_ShowPersonalTitleReddot = " .. tostring(BP_ShowInfo_ShowPersonalTitleReddot));
	log("[LLB]EventRefreshMenuReddot, BP_ShowInfo_ShowHeadportraitReddot = " .. tostring(BP_ShowInfo_ShowHeadportraitReddot));
	log("[LLB]EventRefreshMenuReddot, BP_ShowInfo_ShowHeadportraitFrameReddot = " .. tostring(BP_ShowInfo_ShowHeadportraitFrameReddot));
end
