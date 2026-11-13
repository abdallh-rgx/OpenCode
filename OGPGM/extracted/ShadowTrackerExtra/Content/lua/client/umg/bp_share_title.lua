--[[
	结算分享称号页面 2017-12-12
--]]

ShareResultTitletUI = ShareResultTitletUI or {
	titleShared = false;
}


BP_ShareTitle_SelectedTitle = 1;
--只在战斗中拉起--
function bp_share_title_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_share_title,
		{
			{Path="/Game/BluePrints/ControlInput/ResultsshareUI/ShareBP/ShareResultTitle_UIBP.ShareResultTitle_UIBP_C", Container="Default", ZOrder=BP_ENUM_UI_Share_Game_Result_ZORDER},
		},
		{"Fighting"},
		false,
		false,
		true
	);
end

--分享成功的回调
local function OnTitleShareSucessEventHandler(eventType, eventID, vars)

	log("********result title share call back *********");
	if eventType ~= EVENTTYPE_SHARE then
		return;
	end	

	local hasApp = DataMgr.HasInstallPlatApp();
	if hasApp ==  true then
		LuaClassObj.HandleUIMessage(bp_share_title, "UIHide");	
	end
	
	log("********result title share success, hide title share ui *********");
	EventSystem:unregistEvent(EVENTTYPE_SHARE, EVENTID_SHARE_SUCESSFUL, OnTitleShareSucessEventHandler);
end


function EventShowShareResultTitleUI_Push()
	ShareUI:SetShareInfo(13);
	ShareResultTitletUI.ShowUI();
	EventSystem:registEvent(EVENTTYPE_SHARE, EVENTID_SHARE_SUCESSFUL, OnTitleShareSucessEventHandler);
end

--显示UI 
--参数依次为116001 116002
function ShareResultTitletUI.ShowUI()
	LuaClassObj.HandleDynamicCreation(bp_share_title);

	LuaClassObj.HandleUIMessage(bp_share_title, "UIShow");
end

--关闭UI
function ShareResultTitletUI.HideUI()
	LuaClassObj.HandleUIMessage(bp_share_title, "UIHide");	
end