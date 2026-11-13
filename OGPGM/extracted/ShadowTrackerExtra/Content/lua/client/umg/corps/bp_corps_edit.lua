CorpsEditUI = CorpsEditUI or {}

BP_corpsAnnouncement = ""

function bp_corps_edit_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_corps_edit,
		{{Path="/Game/UMG/UI_Logic/Corps/CorpsOwnEdit_BP.CorpsOwnEdit_BP_C", Container="Default", ZOrder=BP_ENUM_UI_CORPS_ModifyAnnouncement}},
		{"Lobby"},
		false,
		false,
		true
	);
end

function EventCorpsEditShow()
	BP_corpsAnnouncement = DataMgr.corpsInfo.announcement
	LuaClassObj.HandleDynamicCreation(bp_corps_edit)
	LuaClassObj.HandleUIMessage(bp_corps_edit, "ShowUI")
end

function EventCorpsEditConfirm_Push()
	CorpsMgr.corps_change_announcement_req(BP_corpsAnnouncement)
	LuaClassObj.HandleUIMessage(bp_corps_edit, "CloseUI")
end