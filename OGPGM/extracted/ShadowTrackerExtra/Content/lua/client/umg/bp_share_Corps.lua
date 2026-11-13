--[[
	结算分享军团页面 2018-8-14
--]]

ShareCorpstUI = ShareCorpstUI or {
	corpsShared = false;
}

BP_ShareCorps_TabIndex = 0;

--只在战斗中拉起--
function bp_share_Corps_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_share_Corps,
		{
			{Path="/Game/BluePrints/ControlInput/ResultsshareUI/ShareBP/ShareCorps_UIBP.ShareCorps_UIBP_C", Container="Default", ZOrder=BP_ENUM_UI_Share_Game_Result_ZORDER},
		},
		{"Fighting"},
		false,
		false,
		true
	);
end

--分享成功的回调
local function OnCorpsShareSucessEventHandler(eventType, eventID, vars)

	log("********result corps share call back *********");
	if eventType ~= EVENTTYPE_SHARE then
		return;
	end	

	local hasApp = DataMgr.HasInstallPlatApp();
	if hasApp ==  true then
		LuaClassObj.HandleUIMessage(bp_share_Corps, "UIHide");	
	end
	
	log("********result corps share success, hide corps share ui *********");
	EventSystem:unregistEvent(EVENTTYPE_SHARE, EVENTID_SHARE_SUCESSFUL, OnCorpsShareSucessEventHandler);
end


function EventShowShareResultCorpsUI_Push()
	if BP_ShareCorps_TabIndex == 0 then
		ShareUI:SetShareInfo(25);
	elseif BP_ShareCorps_TabIndex == 1 then
		ShareUI:SetShareInfo(26);
	elseif BP_ShareCorps_TabIndex == 2 then
		ShareUI:SetShareInfo(27);
	end
	ShareCorpstUI.ShowUI();
	EventSystem:registEvent(EVENTTYPE_SHARE, EVENTID_SHARE_SUCESSFUL, OnCorpsShareSucessEventHandler);
end

--显示UI 
--参数依次为116001 116002
function ShareCorpstUI.ShowUI()
	LuaClassObj.HandleDynamicCreation(bp_share_Corps);

	LuaClassObj.HandleUIMessage(bp_share_Corps, "UIShow");
end

--关闭UI
function ShareCorpstUI.HideUI()
	LuaClassObj.HandleUIMessage(bp_share_Corps, "UIHide");	
end