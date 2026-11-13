
InviteJoinTeamUI = InviteJoinTeamUI or 
{
	InviteBySMS = "sms";
	InviteByMessenger = "messenger";
	InviteByWhatsapp = "whatsapp";
	InviteBySystem = "system";
	InviteByLine = "line";
}

BP_IJT_IsInstallMessenger = false;

function bp_invite_join_team_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_invite_join_team,
		{
			{Path="/Game/UMG/UI_BP/Common/Common_Invite_UIBP.Common_Invite_UIBP_C", Container="Default", ZOrder=BP_ENUM_UI_FACETEAM_ZORDER},
		},
		{"Lobby"},
		false,
        false,
		true
	);
end

function InviteJoinTeamUI.ShowUI()
	--CE邀请组队点击无效
	if Client.IsCEVersion() == false then
		LuaClassObj.HandleDynamicCreation(bp_invite_join_team);
		LuaClassObj.HandleUIMessage(bp_invite_join_team, "ShowUI");
	end
end

function InviteJoinTeamUI.CloseUI()
	log("[HHF]InviteJoinTeamUI.CloseUI");
	LuaClassObj.HandleUIMessage(bp_invite_join_team, "CloseUI");
end

function InviteJoinTeamUI.ConfirmClick(channel)
	log("[HHF]InviteJoinTeamUI.ConfirmClick, channel = " .. tostring(channel));
	FriendSystem.invite_offline_friend_req(channel);
end

function EventCloseInviteJoinTeamUI()
	log("[HHF]EventCloseInviteJoinTeamUI");
	InviteJoinTeamUI.CloseUI();
end

function EventInviteJoinBySMS()
	log("[HHF]EventInviteJoinBySMS");
	InviteJoinTeamUI.ConfirmClick(InviteJoinTeamUI.InviteBySMS);
end

function EventInviteJoinByMessenger()
	log("[HHF]EventInviteJoinByMessenger");
	if Client.IsInstallMessenger(NetInterface) == false then
		DataMgr.ShowNoticeByID(4466);
		return
	end
	
	InviteJoinTeamUI.ConfirmClick(InviteJoinTeamUI.InviteByMessenger);
end

function EventInviteJoinByWhatsApp()
	log("[HHF]EventInviteJoinByWhatsApp");
	if Client.IsInstallWhatsapp(NetInterface) == false then
		DataMgr.ShowNoticeByID(4714);
		return
	end
	
	InviteJoinTeamUI.ConfirmClick(InviteJoinTeamUI.InviteByWhatsapp);
end

function EventInviteJoinBySystem()
	log("[HHF]EventInviteJoinBySystem");	
	InviteJoinTeamUI.ConfirmClick(InviteJoinTeamUI.InviteBySystem);
end

function EventIJTIsInstallMessenger()
	BP_IJT_IsInstallMessenger = Client.IsInstallMessenger(NetInterface);
	log("[HHF]EventIJTIsInstallMessenger, BP_IJT_IsInstallMessenger = " .. tostring(BP_IJT_IsInstallMessenger));
end

function EventInviteJoinByLine()
	log("[HHF]EventInviteJoinByLine");	
	InviteJoinTeamUI.ConfirmClick(InviteJoinTeamUI.InviteByLine);
end

function EventFetchInfo()
	
end