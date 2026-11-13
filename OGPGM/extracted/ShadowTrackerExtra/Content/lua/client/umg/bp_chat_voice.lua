GlobalChatVoice = GlobalChatVoice or
{
	VOICE_PROCEDURE_INIT = "init";
	VOICE_PROCEDURE_UNINIT = "uninit";
	VOICE_PROCEDURE_JOIN = "join";

	voiceChatMode = -1;
	voiceIsInited = false;
	
	voiceErrHandle = 0;
	voiceErrMaxHandle = 2;	
	
	voiceTickRetryHandle = 0;
	voiceTickMaxRetryHandle = 4;
	
	voiceOpenMic = false;
	voiceOpenSpeaker = false;
	voiceEnterBackground = false;
	voiceRetryFailed = false;
	
	voiceLobbyMemberId = "";
	voiceEnterRoomId = "";
	voiceBufferRoomId = "";
	voiceLobbyRoomId = "";
	voiceGameRoomId = "";
	voiceOperationLock = false;
	voiceOperationLockTimer = 0;
	
	voiceServiceId = "hello";

	--重连次数
	GvoiceReEnterRoomMaxCount=100;
	--重连延迟时间
	GvoiceReEnterDuration=60;
	
	voiceTeamOperationList = 
	{
	};
	
	-- OPERATION ERROR CODE
	GVOICE_OPERR_PMSMIC_ERR = 12291;	-- 0x3003 	android
	GVOICE_OPERR_PMSMIC_ERR2 = 20481;	-- 0x5001	ios
	GVOICE_OPERR_GVOICE_SERVICE_ERR = 12292;
	GVOICE_OPERR_UPLOAD_ERR = 12293;	-- 0x3005
	GVOICE_OPERR_HTTP_BUSY = 12294;		-- 0x3006
	GVOICE_OPERR_DOWNLOAD_ERR = 12295;	-- 0x3007
	GVOICE_OPERR_TOTEXTPROCESSING_ERR = 28673;	-- 0x07001
	GVOICE_OPERR_CHANGEMODE_ERR = 4102;	-- 0x1006
	GVOICE_OPERR_ALREADYINROOM_ERR = 8200;	-- 0x2008	
	
	-- COMPLETE ERROR CODE
	GVOICE_JOINROOM_SUCC = 1;
	GVOICE_JOINROOM_TIMEOUT = 2;
	GVOICE_JOINROOM_SVRERROR = 3;
	
	GVOICE_COMPLETE_ERR = 5;
	
	GVOICE_QUITROOM_SUCC = 6;
	GVOICE_MESSAGE_KEY_SUCC = 7;
	
	GVOICE_UPLOAD_SUCC = 11;
	GVOICE_UPLOAD_ERROR = 12;
	
	GVOICE_DOWNLOAD_ERROR = 14;
	
	GVOICE_STT_ERR = 16;
	GVOICE_STT_ERR2 = 17;
}

BP_GlobalChatvoiceMicOpened = false;
BP_GlobalChatvoiceSpeakerOpened = false;

BP_GlobalChatvoiceIsTeamup = false;

BP_GlobalChatvoiceRecordSuccess = false;

BP_GlobalChatvoiceCurrentRole = "";
BP_GlobalChatvoiceCurrentRoom = "";
BP_GlobalChatvoiceCurrentMode = -1;
BP_GlobalChatvoiceCurrentStage = "";
BP_GlobalChatvoiceDefaultOpenTeam = true;

-- �������
BP_GlobalChatvoiceTotalLimit = 10;
BP_GlobalChatvoiceUploadMsgId = "";
BP_GlobalChatvoiceToTextContent = "";
BP_GlobalChatvoiceUploadTime = 0;
BP_GlobalChatvoiceCurrentPlayFile = "";


BP_STRUCT_GlobalChatvoiceDownloadData = 
{
	msgContextGID = "",
	msgSenderGID = "",	
	msgLength = 0,
	msgChannel = 0,
	msgId = 0,
	fileId = "",
}

BP_ARRAY_GlobalChatvoiceDownloadList = 
{
	BP_STRUCT_GlobalChatvoiceDownloadData = _G.BP_STRUCT_GlobalChatvoiceDownloadData,
};

function bp_chat_voice_RegisterUI()
  LuaClassObj.SubUIWidgetList(bp_chat_voice,
    {{Path="/Game/UMG/UI_Logic/ChatVoice/Global_Voice.Global_Voice_C", Container="Default", ZOrder=1}},
    {"Lobby", "Fighting", "Training", "Pending"},
	true,
	bp_chat_voice_OnModeSwitched ~= nil
  );
end

function bp_chat_voice_OnModeSwitched(gamestatus)	
	local status = string.lower(gamestatus);
	GlobalChatVoice.StageChanged(status);
	-- ������׶�mic��speaker״̬�������
	if "lobby" == status then		
	else		
	end
end



--�����κ��£���ͼ��������������lua������ֵͬ������ͼ����
function EventChatVoiceFetchInfo()
	
end

function EventChatVoiceSetInfo_Push()
end

-- BP����mode�����
function EventChangeGVoiceMode()
	GlobalChatVoice.OnVoiceModeChange();
end

function EventClearGVoiceProcedure()
	GlobalChatVoice.OnClearVoiceProcedure();
end

function EventStopPlayGVoiceRecord()	
	GlobalChatVoice.OnStopPlayRecordFile();
end

function EventStartPlayGVoiceRecord()
	GlobalChatVoice.OnStartPlayRecordFile();
end

function EventStartGVoiceRecord()
	GlobalChatVoice.OnStartRecordVoice();
end

function EventStopGVoiceRecord()
	GlobalChatVoice.OnStopRecordVoice();
end

function EventCancelGVoiceRecord()
	GlobalChatVoice.OnCancelRecordVoice();
end

function EventUploadGVoiceRecord()
	GlobalChatVoice.OnUploadRecordVoice();
end

function EventChangeMicState()	
	log("EventChangeMicState");
	GlobalChatVoice.ChangeMicOpen(BP_GlobalChatvoiceMicOpened);
end

function EventChangeSpeakerState()
	GlobalChatVoice.ChangeSpeakerOpen(BP_GlobalChatvoiceSpeakerOpened);
end

function EventNotifyVoiceProcedureFailed()
	PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", 106014).TextValue);
end

function EventNotifyVoiceChatFailToRecord()
	PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", 106012).TextValue);
end

function EventNotifyVoiceRecordTooShort()
	PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", 106015).TextValue);
end

function EventNotifyVoiceOpenSpeaker()
	PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", 106011).TextValue);
end

function EventNotifySystemVoiceOpen()
	PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", 102100).TextValue);
end

function EventNotifySystemMicOpen()
	PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", 102101).TextValue);
end

function EventNotifySystemSpeakerOpen()
	PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", 102102).TextValue);
end

function EventNotifyDownloadFailed()
	PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", 106056).TextValue);
end

function EventNotifyRecordTooShort()
	PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", 106015).TextValue);
end

function EventChatRequestPrivacy()
	log("[CCW]EventChatRequestPrivacy  bp_chat_voice")
	local function savePrivacyAcceptStatus()
		LuaClassObj.HandleUIMessage(bp_chat_voice, "OnChatPrivacyAccepted");	
	end
	CommonMessageBoxUI:ShowPanel(2, DataMgr.GetMsgByID(102012), DataMgr.GetMsgByID(4073), savePrivacyAcceptStatus,nil,DataMgr.GetMsgByID(110036),DataMgr.GetMsgByID(110035));
end


function EventMicClickCD()
	PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", 4597).TextValue);
end

function EventTickVoiceRoom()
	if false == GlobalChatVoice.voiceIsInited then
		return;
	end	
	
	if true == GlobalChatVoice.voiceEnterBackground then
		return;
	end
	
	if true == GlobalChatVoice.voiceOperationLock then
		GlobalChatVoice.voiceOperationLockTimer = GlobalChatVoice.voiceOperationLockTimer + 1;
		
		-- ����ĳЩ����ӷ���һֱ��û�ظ������ܶ��������»�һֱlock���������һ�Σ�����������		
		if GlobalChatVoice.voiceOperationLockTimer > 2 then
			log("GlobalChatVoice.voiceOperationLockTimer");
			GlobalChatVoice.UnlockVoiceOperation();
			GlobalChatVoice.ResetVoiceOperation();
		else
			return;
		end		
	end
	
	if true == GlobalChatVoice.voiceRetryFailed then
		GlobalChatVoice.voiceTickRetryHandle = GlobalChatVoice.voiceTickRetryHandle + 1;
		if GlobalChatVoice.voiceTickRetryHandle >= GlobalChatVoice.voiceTickMaxRetryHandle then
			GlobalChatVoice.voiceTickRetryHandle = 0;
			GlobalChatVoice.ClearRetryFailure();
		end
		
		return;
	end
	
	if 0 ~= #GlobalChatVoice.voiceTeamOperationList then				
		return;
	end	
	
	local curStatus = string.lower(LuaClassObj.GetGameStatus(bp_chat_voice));
	if "lobby" == curStatus then
		if GlobalChatVoice.voiceEnterRoomId ~= GlobalChatVoice.voiceLobbyRoomId then
			GlobalChatVoice.voiceBufferRoomId = GlobalChatVoice.voiceEnterRoomId;
			GlobalChatVoice.OnJoinLobbyVoiceRoom();
		end
	elseif "fighting" == curStatus then
		if GlobalChatVoice.voiceEnterRoomId ~= GlobalChatVoice.voiceGameRoomId then
			GlobalChatVoice.voiceBufferRoomId = GlobalChatVoice.voiceEnterRoomId;
			GlobalChatVoice.OnJoinGameVoiceRoom();
		end
	end
end

function EventOnTryOpenMic()
	GlobalChatVoice.ReenterWhenOpenMic();
end

--=======================================================================--
function GlobalChatVoice.ResetEventListener()

end

function GlobalChatVoice.ResetRoleInfo(roleId, isRelogin)	
	BP_GlobalChatvoiceCurrentRole = FuncUtil:StrTrim(roleId);
	
	LuaClassObj.HandleUIMessage(bp_chat_voice, "OnResetRoleInfo");
	
	if not isRelogin then
		GlobalChatVoice.InitRoleVoice();
	else
		log("GVoice Relogin");
		
		GlobalChatVoice.QuitRoomTemp();
	end		
end

function GlobalChatVoice.ClearRoleInfo()	
	log("gvoice clear role");
	
	GlobalChatVoice.ChangeMicOpen(false);
	GlobalChatVoice.ChangeSpeakerOpen(false);		
	
	GlobalChatVoice.UninitRoleVoice();
	
	BP_GlobalChatvoiceCurrentRole = "";
	BP_GlobalChatvoiceCurrentRoom = "";
	BP_GlobalChatvoiceCurrentMode = -1;
	
	LuaClassObj.HandleUIMessage(bp_chat_voice, "OnClearRoleInfo");	
end

function GlobalChatVoice.InitRoleVoice()
	--log("gvoice init role voice");
	if true == GlobalChatVoice.voiceIsInited then
		log("gvoice already inited role");
		return;
	end
	
	GlobalChatVoice.voiceIsInited = true;
	GlobalChatVoice.OnVoiceInited();
    EventSystem:registEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN, GlobalChatVoice.WardRobeAvatarResetOpen);
    EventSystem:registEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE, GlobalChatVoice.WardRobeAvatarResetClose);

	EventSystem:registEvent(EVENTTYPE_RANK, EVENTID_WARZONE_OPEN, GlobalChatVoice.WarZoneOpen);
    EventSystem:registEvent(EVENTTYPE_RANK, EVENTID_WARZONE_CLOSE, GlobalChatVoice.WarZoneClose);
end

--[[
	�˳���¼ʱ������Ƶ�������
]]
function GlobalChatVoice.UninitRoleVoice()
	GlobalChatVoice.voiceLobbyRoomId = "";
	GlobalChatVoice.voiceLobbyMemberId = "";
	GlobalChatVoice.voiceGameRoomId = "";
	GlobalChatVoice.QuitVoiceRoom();
	GlobalChatVoice.voiceIsInited = false;		
	GlobalChatVoice.UnlockVoiceOperation()
    EventSystem:unregistEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN, GlobalChatVoice.WardRobeAvatarResetOpen);
    EventSystem:unregistEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE, GlobalChatVoice.WardRobeAvatarResetClose);

	EventSystem:unregistEvent(EVENTTYPE_RANK, EVENTID_WARZONE_OPEN, GlobalChatVoice.WarZoneOpen);
    EventSystem:unregistEvent(EVENTTYPE_RANK, EVENTID_WARZONE_CLOSE, GlobalChatVoice.WarZoneClose);
end

function GlobalChatVoice.WardRobeAvatarResetOpen()
    log("GlobalChatVoice.WardRobeAvatarResetOpen")
		LuaClassObj.HandleUIMessage(bp_chat_voice, "UIHide");	
end

function GlobalChatVoice.WardRobeAvatarResetClose()
    log("GlobalChatVoice.WardRobeAvatarResetClose")
    LuaClassObj.HandleUIMessage(bp_chat_voice, "UIShow");	
end

function GlobalChatVoice:WarZoneOpen()
    log("GlobalChatVoice.WarZoneOpen")
	LuaClassObj.HandleUIMessage(bp_chat_voice, "UIHide");
end

function GlobalChatVoice:WarZoneClose()
    log("GlobalChatVoice.WarZoneClose")
    LuaClassObj.HandleUIMessage(bp_chat_voice, "UIShow");
end

function GlobalChatVoice.StageChanged(stage)

	BP_GlobalChatvoiceCurrentStage = stage;
	LuaClassObj.HandleUIMessage(bp_chat_voice, "OnGameStageChanged");
	
	log("GVoice Stage Changed " .. stage);
	
	GlobalChatVoice.voiceTickRetryHandle = 0;
	GlobalChatVoice.UnlockVoiceOperation()
	GlobalChatVoice.ClearRetryFailure();
	GlobalChatVoice.ResetVoiceOperation();
	
	if "lobby" == stage then
		GlobalChatVoice.OnQuitGameVoiceRoom();
		GlobalChatVoice.OnJoinLobbyVoiceRoom();
	elseif "login" ~= stage and "createrole" ~= stage then
		GlobalChatVoice.QuitLobbyVoiceRoom();
		GlobalChatVoice.OnJoinGameVoiceRoom();
	end
end

function GlobalChatVoice.SetIsTeamup(isTeamup)
	BP_GlobalChatvoiceIsTeamup = isTeamup;
	LuaClassObj.HandleUIMessage(bp_chat_voice, "OnTeamStateChanged");
end

function GlobalChatVoice.ReenterWhenOpenMic()
	if true == GlobalChatVoice.voiceRetryFailed then
		GlobalChatVoice.voiceTickRetryHandle = 0;
		GlobalChatVoice.ClearRetryFailure();
		log("GlobalChatVoice.ReenterWhenOpenMic".. "  " ..  tostring(os.time()));
		GlobalChatVoice.QuitRoomTemp();
	end
end

function GlobalChatVoice.JoinLobbyVoiceRoom(room_id)	
	local leaderName = TeamUpSystem.GetMemberName(room_id);
	log("GlobalChatVoice.JoinLobbyVoiceRoom" .. " leaderName: " ..  leaderName);
	local leaderNameHash = "";	
	if "" ~= leaderName then
		leaderNameHash = Client.MD5HashAnsiString(leaderName);
		if "" ~= leaderNameHash then
			leaderNameHash = leaderNameHash .. "_";
		end
		log("GlobalChatVoice.JoinLobbyVoiceRoom" .. " leaderNameHash: " .. leaderNameHash);
	end

	local roomId = leaderNameHash .. room_id .. GlobalChatVoice.voiceServiceId;
	if GlobalChatVoice.voiceLobbyRoomId == roomId then
		return;
	end
	
	GlobalChatVoice.voiceLobbyRoomId = roomId;
	GlobalChatVoice.ClearRetryFailure();
	GlobalChatVoice.OnJoinLobbyVoiceRoom();
end

function GlobalChatVoice.QuitLobbyVoiceRoom()
	log("GVoice GlobalChatVoice.QuitLobbyVoiceRoom");
	GlobalChatVoice.voiceLobbyRoomId = "";
	GlobalChatVoice.voiceLobbyMemberId = "";
	GlobalChatVoice.OnQuitLobbyVoiceRoom();
end

function GlobalChatVoice.OnJoinLobbyVoiceRoom()			
	log("GVoice On Join Lobby Voice Room " .. GlobalChatVoice.voiceLobbyRoomId);
	
	if BP_GlobalChatvoiceCurrentStage == "lobby" then
		GlobalChatVoice.JoinVoiceRoom(GlobalChatVoice.voiceLobbyRoomId);
	end
end

function GlobalChatVoice.OnQuitLobbyVoiceRoom()
	log("GVoice On Quit Lobby Voice Room");
	
	if "lobby" == BP_GlobalChatvoiceCurrentStage then
		GlobalChatVoice.QuitVoiceRoom();
	end		
end

function GlobalChatVoice.JoinGameVoiceRoom(team_info)	
	--log_tree("GVoice Join Game Voice room team info ", team_info);
	
	GlobalChatVoice.ClearRetryFailure();
	--if LogicLobbyWatching.IsWatchingEnterGame then
	--	log("GlobalChatVoice.JoinGameVoiceRoom watchingEnterGame");
	--	GlobalChatVoice.voiceGameRoomId = "";	
	--elseif nil ~= team_info then
	if nil ~= team_info then
		local checkSum = 0;
		for i = 1, #team_info do
			checkSum = team_info[i] + checkSum;
		end
		
		local room_id = "";
		
		table.sort(team_info, function(a, b) return a > b end);
		
		if #team_info > 1 then
			room_id = tostring(checkSum);
			
			for i = 1, #team_info do
				room_id = room_id .. string.sub(tostring(team_info[i]), -4);
			end
		end
		
		log("GVoice Join Game Voice Room: " .. room_id .. " IsRoomToBattle: " .. tostring(IsRoomToBattle));
		
		if "" ~= room_id then
			GlobalChatVoice.voiceGameRoomId = room_id .. "_in_game" .. GlobalChatVoice.voiceServiceId;
		else
			GlobalChatVoice.voiceGameRoomId = "";
		end	
	elseif true == IsRoomToBattle then
		local memberList = RoomWaitingUI.GetTeamMemberInfo();
		-- ����ģʽ
		local checkSum = 0;
		for i = 1, #memberList  do
			checkSum = memberList[i] + checkSum;
		end
		
		local room_id = "";
		
		table.sort(memberList , function(a, b) return a > b end);
		
		if #memberList > 1 then
			room_id = tostring(checkSum);
			
			for i = 1, #memberList do
				room_id = room_id .. string.sub(tostring(memberList[i]), -4);
			end
		end		
		
		log_tree("GVoice RoomToBattle memberList", memberList);
		
		if "" ~= room_id then
			GlobalChatVoice.voiceGameRoomId = room_id .. "_in_game" .. GlobalChatVoice.voiceServiceId;
		else
			GlobalChatVoice.voiceGameRoomId = "";
		end
		
		log("GVoice Join Room Game Voice: " .. GlobalChatVoice.voiceGameRoomId);
	end	
	
	--GlobalChatVoice.OnJoinGameVoiceRoom();	
end

function GlobalChatVoice.OnJoinGameVoiceRoom()
	log("GVoice On Join Game Voice Room" .. GlobalChatVoice.voiceGameRoomId);	
	
	--[[if LogicLobbyWatching.IsWatchingEnterGame then
		log("GlobalChatVoice.OnJoinGameVoiceRoom watchingEnterGame");
		GlobalChatVoice.voiceGameRoomId = "";
	end
	]]--
	
	if "" ~= GlobalChatVoice.voiceGameRoomId then
		GlobalChatVoice.JoinVoiceRoom(GlobalChatVoice.voiceGameRoomId);
	else
		GlobalChatVoice.QuitVoiceRoom();
	end
		
end

function GlobalChatVoice.OnQuitGameVoiceRoom()	
	log("GVoice On Quit Game Voice Room");
	
	GlobalChatVoice.voiceGameRoomId = "";
	GlobalChatVoice.QuitVoiceRoom();	
end


--[[
	room_id (string, leader_gid when team up or specific room_id)
]]
function GlobalChatVoice.JoinVoiceRoom(room_id)	
	GlobalChatVoice.QuitVoiceRoom();
	
	log("GVoice Join Voice Room" .. room_id);
	
	local room = FuncUtil:StrTrim(tostring(room_id));
	
	if GlobalChatVoice.voiceBufferRoomId == room then
		if "" ~= room then
			log("GVoice join same room" .. room);
		end
		return;		
	end
	
	if false == GlobalChatVoice.voiceOperationLock and room == GlobalChatVoice.voiceEnterRoomId then
		GlobalChatVoice.ResetVoiceOperation();
					log("GlobalChatVoice.JoinVoiceRoom" .. GlobalChatVoice.voiceLobbyRoomId .. "  " .. GlobalChatVoice.voiceGameRoomId);
		return;	
	end
	
	GlobalChatVoice.voiceBufferRoomId = room;
	
	if not GlobalChatVoice.voiceIsInited then
		log("gvoice not inited when join team");
		return;
	end
	
	log("GlobalChatVoice.JoinVoiceRoom" .. "  " ..  tostring(os.time()));
	GlobalChatVoice.AddVoiceOperation(GlobalChatVoice.VOICE_PROCEDURE_JOIN, room, true);
	GlobalChatVoice.HandleVoiceRoomOperation();	
end

function GlobalChatVoice.QuitVoiceRoom()	
	log("GVoice Quit Voice Room");

	if false == GlobalChatVoice.voiceOperationLock and "" == GlobalChatVoice.voiceEnterRoomId then
		GlobalChatVoice.ResetVoiceOperation();
		log("GVoice Quit Voice room returned when done");
		return;
	end
	
	GlobalChatVoice.voiceBufferRoomId = "";
	
	if not GlobalChatVoice.voiceIsInited then
		log("GVoice Quit Voice Room Returned when not initialize");
		return;
	end
	
	log("GlobalChatVoice.QuitVoiceRoom 12d" .. "  " ..  tostring(os.time()));
	GlobalChatVoice.AddVoiceOperation(GlobalChatVoice.VOICE_PROCEDURE_JOIN, "", false);
	GlobalChatVoice.HandleVoiceRoomOperation();	
end

function GlobalChatVoice.QuitRoomTemp()	
	if false == GlobalChatVoice.voiceOperationLock and "" == GlobalChatVoice.voiceEnterRoomId then
		GlobalChatVoice.ResetVoiceOperation();
		GlobalChatVoice.HandleReenterVoiceRoom();
					log("GlobalChatVoice.QuitRoomTemp" .. GlobalChatVoice.voiceLobbyRoomId .. "  " .. GlobalChatVoice.voiceGameRoomId .. "  " ..  tostring(os.time()));
		return;
	end
	
	if not GlobalChatVoice.voiceIsInited then		
		return;		
	end
	
	log("GlobalChatVoice.QuitRoomTemp()	" .. "  " ..  tostring(os.time()));
	
	GlobalChatVoice.AddVoiceOperation(GlobalChatVoice.VOICE_PROCEDURE_JOIN, "", false);
	GlobalChatVoice.HandleVoiceRoomOperation();	
end

function GlobalChatVoice.QuitVoiceRoomOnDeactivate()	
	GlobalChatVoice.voiceEnterBackground = true;
	
	log("GlobalChatVoice.QuitVoiceRoomOnDeactivate" .. "  " ..  tostring(os.time()))
	GlobalChatVoice.QuitRoomTemp();	
	LobbyChatLogic.OnApplicationDeactivated();
end

function GlobalChatVoice.JoinVoiceRoomOnReactivate()	
	GlobalChatVoice.voiceEnterBackground = false;
	GlobalChatVoice.ClearRetryFailure();
	
	if false == GlobalChatVoice.voiceOperationLock and GlobalChatVoice.voiceBufferRoomId == GlobalChatVoice.voiceEnterRoomId then
		GlobalChatVoice.ResetVoiceOperation();
		log("GlobalChatVoice.JoinVoiceRoomOnReactivate11 " .. GlobalChatVoice.voiceLobbyRoomId .. "  " .. GlobalChatVoice.voiceGameRoomId .. "  " ..  tostring(os.time()));
		return;
	end
	
	if not GlobalChatVoice.voiceIsInited then		
		return;
	end
	
	if "" ~= GlobalChatVoice.voiceEnterRoomId then
		GlobalChatVoice.UnlockVoiceOperation();
		GlobalChatVoice.ResetVoiceOperation();
	end
	
	GlobalChatVoice.QuitRoomTemp();
end

function GlobalChatVoice.ChangeMicOpen(open)
	log("GlobalChatVoice.ChangeMicOpen  old GlobalChatVoice.voiceOpenMic: " .. tostring(GlobalChatVoice.voiceOpenMic) .. " old BP_GlobalChatvoiceMicOpened: " .. tostring(BP_GlobalChatvoiceMicOpened));
	GlobalChatVoice.voiceOpenMic = open;
	BP_GlobalChatvoiceMicOpened = open;
	log("GlobalChatVoice.ChangeMicOpen  new GlobalChatVoice.voiceOpenMic: " .. tostring(open) .. " new BP_GlobalChatvoiceMicOpened: " .. tostring(open));
	
	if GlobalChatVoice.voiceLobbyRoomId == GlobalChatVoice.voiceEnterRoomId then
		TeamUpSystem.ReportVoiceInfo(GlobalChatVoice.voiceLobbyMemberId, BP_GlobalChatvoiceMicOpened);
	end
	
	LuaClassObj.HandleUIMessage(bp_chat_voice, "OnVoiceMicOpenChanged");	
end

function GlobalChatVoice.ChangeSpeakerOpen(open)	
	GlobalChatVoice.voiceOpenSpeaker = open;
	BP_GlobalChatvoiceSpeakerOpened = open;
	
	LuaClassObj.HandleUIMessage(bp_chat_voice, "OnVoiceSpeakerOpenChanged");	
end

function GlobalChatVoice.ResetVoiceOperation()	
	GlobalChatVoice.voiceTeamOperationList = {};	
end

function GlobalChatVoice.AddDownloadFile(context_gid, sender_gid, channel, msg_id, msg_length, file_id)	
	BP_ARRAY_GlobalChatvoiceDownloadList = {};
		
	local downloadData = {};
	downloadData.msgContextGID = context_gid;
	downloadData.msgSenderGID = sender_gid;
	downloadData.msgChannel = channel;
	downloadData.msgId = msg_id;
	downloadData.msgLength = msg_length;
	downloadData.fileId = file_id;
	
	table.insert(BP_ARRAY_GlobalChatvoiceDownloadList, downloadData);
	
	LuaClassObj.HandleUIMessage(bp_chat_voice, "OnTryDownloadVoiceRecord");	
end

function GlobalChatVoice.AddVoiceOperation(handle_type, custom_data, operation_type)	
	if #GlobalChatVoice.voiceTeamOperationList > 0 then
		local opData = GlobalChatVoice.voiceTeamOperationList[1];
		if (handle_type == opData.type) and (custom_data == opData.customData) and (operation_type == opData.operationEnter) then
			return;
		end
	end
	
	local operation = {};
	operation.type = handle_type;
	operation.customData = custom_data;
	operation.operationEnter = operation_type;
	
	table.insert(GlobalChatVoice.voiceTeamOperationList, operation);	
end

function GlobalChatVoice.TryStartRecordVoice()
	LuaClassObj.HandleUIMessage(bp_chat_voice, "OnTryStartRecordVoice");
end

function GlobalChatVoice.TryStopRecordVoice()
	LuaClassObj.HandleUIMessage(bp_chat_voice, "OnTryStopRecordVoice");
end

function GlobalChatVoice.TryCancelRecordVoice()
	LuaClassObj.HandleUIMessage(bp_chat_voice, "OnTryCancelRecordVoice");
end

function GlobalChatVoice.TryStopPlayRecordVoice()
	LuaClassObj.HandleUIMessage(bp_chat_voice, "OnTryStopPlayRecordVoice");
end

function GlobalChatVoice.TryCloseMic()
	LuaClassObj.HandleUIMessage(bp_chat_voice, "OnTryCloseMic");
end

function GlobalChatVoice.LockVoiceOperation(room_name)
	GlobalChatVoice.voiceOperationLock = true;
	GlobalChatVoice.voiceOperationLockTimer = 0;
end

function GlobalChatVoice.UnlockVoiceOperation()
	GlobalChatVoice.voiceOperationLock = false;
	GlobalChatVoice.voiceOperationLockTimer = 0;
end

function GlobalChatVoice.HandleVoiceRoomOperation()	
	log("GVoice handle voice room operation 1");
	
	if GlobalChatVoice.CheckRetryFailed() then
		log("GVoice previous retry failed");
		return;
	end
	
	if true == GlobalChatVoice.voiceOperationLock then		
		log("GVoice handle voice room operation 2");
		return;
	end
	
	if 0 == #GlobalChatVoice.voiceTeamOperationList then
		log("GVoice handle voice room operation 3");
		return;
	end
	
	for i = 1, #GlobalChatVoice.voiceTeamOperationList do 
		local operationData = GlobalChatVoice.voiceTeamOperationList[i];		
		GlobalChatVoice.OnVoiceRoomChange(operationData.customData);
		log("gvoice lock operation " .. operationData.customData .. "  " ..  tostring(os.time()));
		GlobalChatVoice.LockVoiceOperation(operationData.customData);
		break;		
	end		
end

function GlobalChatVoice.HandleVoiceRoomAsync()
	log("gvoice GlobalChatVoice.HandleVoiceRoomAsync lock" .. tostring(GlobalChatVoice.voiceOperationLock) .. "  " ..  tostring(os.time()));
	GlobalChatVoice.UnlockVoiceOperation()
	
	log("gvoice GlobalChatVoice.HandleVoiceRoomAsync lock" .. tostring(GlobalChatVoice.voiceOperationLock) .. "  " ..  tostring(os.time()));
	GlobalChatVoice.HandleReenterVoiceRoom();
end

function GlobalChatVoice.HandleReenterVoiceRoom()
	if true == GlobalChatVoice.voiceEnterBackground then
		if "" == GlobalChatVoice.voiceEnterRoomId then
			GlobalChatVoice.ResetVoiceOperation();		
			log("GlobalChatVoice.HandleReenterVoiceRoom1 " .. GlobalChatVoice.voiceLobbyRoomId .. "  1 " .. GlobalChatVoice.voiceGameRoomId .. "  " ..  tostring(os.time()));			
		end
		
		return;
	else
		if GlobalChatVoice.voiceBufferRoomId == GlobalChatVoice.voiceEnterRoomId then
			GlobalChatVoice.UnlockVoiceOperation();
			GlobalChatVoice.ResetVoiceOperation();
			log("GlobalChatVoice.HandleReenterVoiceRoom2  " .. GlobalChatVoice.voiceLobbyRoomId .. "  2 " .. GlobalChatVoice.voiceGameRoomId .. "  " ..  tostring(os.time()));
			return;
		end
	end
	
	GlobalChatVoice.ResetVoiceOperation();
	--if 0 == #GlobalChatVoice.voiceTeamOperationList then
		if GlobalChatVoice.voiceBufferRoomId ~= GlobalChatVoice.voiceEnterRoomId then
			local opEnter = false;
			if "" == GlobalChatVoice.voiceBufferRoomId then
				opEnter = false;
			else
				opEnter = true;
			end
			
			log("GlobalChatVoice.HandleReenterVoiceRoom3  " .. tostring(GlobalChatVoice.voiceBufferRoomId) .. "  1 " .. tostring(GlobalChatVoice.voiceEnterRoomId) .. "  " ..  tostring(os.time()));
			GlobalChatVoice.AddVoiceOperation(GlobalChatVoice.VOICE_PROCEDURE_JOIN, GlobalChatVoice.voiceBufferRoomId, opEnter);
		else
			return;
		end		
	--end	
	
	log("GlobalChatVoice.HandleReenterVoiceRoom112 " .. tostring(GlobalChatVoice.voiceBufferRoomId) .. "  1 " .. tostring(GlobalChatVoice.voiceEnterRoomId) .. "  " ..  tostring(os.time()));	
	
	GlobalChatVoice.HandleVoiceRoomOperation();
end

function GlobalChatVoice.OnApplicationDeactivated()		
	LuaClassObj.HandleUIMessage(bp_chat_voice, "OnApplicationDeactivated");
	-- GlobalChatVoice.QuitVoiceRoomOnDeactivate();
end

function GlobalChatVoice.OnApplicationReactivated()		
	-- GlobalChatVoice.JoinVoiceRoomOnReactivate();
end

function GlobalChatVoice.OnVoiceInited()
	LobbyChatLogic.OnAfterVoiceInited();
	
	LuaClassObj.HandleUIMessage(bp_chat_voice, "OnGVoiceInited");
end

function GlobalChatVoice.OnVoiceUninited()
	
end

function GlobalChatVoice.OnVoiceRoomChange(roomId)	
	BP_GlobalChatvoiceCurrentRoom = roomId;	
	LuaClassObj.HandleUIMessageNoFetch(bp_chat_voice, "OnTeamVoiceRoomChanged");
	LobbyChatLogic.HandleVoiceRoomChange(roomId);
end

function GlobalChatVoice.OnVoiceModeChange()
	LuaClassObj.HandleUIMessageNoFetch(bp_chat_voice, "OnVoiceModeChanged");
end

function GlobalChatVoice.OnJoinVoiceRoomSuccess(room_name, member_id)
	if GlobalChatVoice.voiceLobbyRoomId == room_name then
		GlobalChatVoice.voiceLobbyMemberId = tostring(member_id);
		TeamUpSystem.ReportVoiceInfo(GlobalChatVoice.voiceLobbyMemberId, BP_GlobalChatvoiceMicOpened);
	end	
	
	LuaClassObj.HandleUIMessageNoFetch(bp_chat_voice, "OnJoinVoiceRoomSuccess");
end

function GlobalChatVoice.OnQuitVoiceRoomSuccess(room_name)
	LuaClassObj.HandleUIMessageNoFetch(bp_chat_voice, "OnQuitVoiceRoomSuccess");
end

function GlobalChatVoice.OnClearVoiceProcedure()
	LobbyChatLogic.OnClearVoiceProcedure();
end

function GlobalChatVoice.OnStopPlayRecordFile()
	LobbyChatLogic.OnStopPlayRecordFile();
end

function GlobalChatVoice.OnStartPlayRecordFile()
	LobbyChatLogic.OnStartPlayRecordFile();
end

function GlobalChatVoice.OnStartRecordVoice()
	LobbyChatLogic.OnStartRecordVoice();
end

function GlobalChatVoice.OnStopRecordVoice()
	LobbyChatLogic.OnStopRecordVoice();
end

function GlobalChatVoice.OnCancelRecordVoice()
	LobbyChatLogic.OnCancelRecordVoice();
end

function GlobalChatVoice.OnUploadRecordVoice()
	LobbyChatLogic.OnUploadRecordVoice();
end


function GlobalChatVoice.OnApplyMessageKeyComplete()
	LuaClassObj.HandleUIMessage(bp_chat_voice, "OnApplyMessageKeyComplete");
end

function GlobalChatVoice.OnUploadRecordFileComplete()
	LuaClassObj.HandleUIMessage(bp_chat_voice, "OnUploadRecordFileComplete");
	GlobalChatVoice.OnSpeechToTextComplete();
end

function GlobalChatVoice.OnUploadRecordFileFailed()
	LuaClassObj.HandleUIMessage(bp_chat_voice, "OnUploadRecordFileFailed");
end

function GlobalChatVoice.OnSpeechToTextComplete()
	LuaClassObj.HandleUIMessage(bp_chat_voice, "OnUploadSpeechToTextComplete");
	
	LobbyChatLogic.OnUploadToTextComplete(BP_GlobalChatvoiceToTextContent, BP_GlobalChatvoiceUploadTime, BP_GlobalChatvoiceUploadMsgId);
end

function GlobalChatVoice.OnDownloadFileComplete()
	if nil == BP_ARRAY_GlobalChatvoiceDownloadList or 0 == #BP_ARRAY_GlobalChatvoiceDownloadList then
		log("GVoice_Download Complete Undefined voice");
		return;
	end
	
	LuaClassObj.HandleUIMessage(bp_chat_voice, "OnDownloadFileComplete");
end

function GlobalChatVoice.OnRecordSuccess()
	BP_GlobalChatvoiceRecordSuccess = true;
end

function GlobalChatVoice.OnRecordFailed()
	BP_GlobalChatvoiceRecordSuccess = false;
end

function GlobalChatVoice.OnUploadSuccess()

end

function GlobalChatVoice.OnUploadFailed()
	LuaClassObj.HandleUIMessage(bp_chat_voice, "OnUploadRecordFailed");
end

function GlobalChatVoice.OnSpeechToTextSuccess()

end

function GlobalChatVoice.OnSpeechToTextFailed()
	LuaClassObj.HandleUIMessage(bp_chat_voice, "OnUploadSpeechToTextFailed");
end

function GlobalChatVoice.OnDownloadFileSuccess()

end

function GlobalChatVoice.OnDownloadFileFailed()

end

function GlobalChatVoice.OnOpenMicSuccess()
	log("GVoice_OnOpenMicSuccess");
end

function GlobalChatVoice.OnOpenMicFailed()
	log("GVoice_OnOpenMicFailed");
	GlobalChatVoice.TryCancelRecordVoice();
	GlobalChatVoice.TryCloseMic();
end

function GlobalChatVoice.OnOpenSpeakerFailed()
	LuaClassObj.HandleUIMessage(bp_chat_voice, "OnTryCloseSpeaker");
end

function GlobalChatVoice.OnMemberSpeaking(room_name, member, status)
	if room_name ~= GlobalChatVoice.voiceLobbyRoomId then
		return;
	end	
	
	if TeamUpSystem.TeamInfo == nil then
		return;
	end

	if TeamUpSystem.TeamInfo.members == nil then
		return;
	end

	for k,v in pairs(TeamUpSystem.TeamInfo.members) do
		local teamMemberInfo = v;
		if nil ~= teamMemberInfo.voice then
			if member == teamMemberInfo.voice.voice_uid then
				TeamUpUI.SetVoiceSpeaking(k, 0 ~= status);
			end
		end		
	end
end

function GlobalChatVoice.EnterLobby(isEnter)
	if isEnter then
		LuaClassObj.HandleUIMessage(bp_chat_voice, "UIShowNative");
	else
		LuaClassObj.HandleUIMessageNoFetch(bp_chat_voice, "UIHideNative");
	end
end
--[[
	GVoice Callbacks
]]

function GVoice_JoinRoomNotify(code, roomName, memberID)
	log("GVoice_JoinRoomNotify " .. tostring(code) .. "  " .. roomName .. memberID);
	
	if GlobalChatVoice.GVOICE_JOINROOM_SUCC~= code then
		GlobalChatVoice.HandleJoinRoomFailed();
	else		
		GlobalChatVoice.voiceErrHandle = 0;
		GlobalChatVoice.voiceEnterRoomId = roomName;
		BP_GlobalChatvoiceCurrentRoom = roomName;
		GlobalChatVoice.OnJoinVoiceRoomSuccess(roomName, memberID);
		GlobalChatVoice.HandleVoiceRoomAsync();
	end	
end

function GVoice_QuitRoomNotify(code, roomName)
	log("GVoice_QuitRoomNotify " .. tostring(code) .. " ".. roomName);
	
	if GlobalChatVoice.GVOICE_QUITROOM_SUCC ~= code and 8195 ~= code and 8198 ~= code then
		GlobalChatVoice.HandleQuitRoomFailed();
	else
		GlobalChatVoice.voiceErrHandle = 0;
		GlobalChatVoice.voiceEnterRoomId = "";		
		BP_GlobalChatvoiceCurrentRoom = "";
		GlobalChatVoice.UnlockVoiceOperation();
		GlobalChatVoice.OnQuitVoiceRoomSuccess();
		GlobalChatVoice.HandleVoiceRoomAsync();
	end		
end

function GVoice_JoinLbsRoomNotify(code, roomName)
	
	log("GVoice_JoinLbsRoomNotify " .. tostring(code) .. " " .. roomName);
end

function GVoice_QuitLbsRoomNotify(code, room_name)
	
	log("GVoice_QuitLbsRoomNotify " .. tostring(code) .. " " .. room_name);
end

-- GVoice
-- gvoice auth success
function GVoice_ApplyMessageKeyNotify(code)
	log("GVoice_ApplyMessageKeyNotify " .. code);
	
	if code == GlobalChatVoice.GVOICE_MESSAGE_KEY_SUCC then
		GlobalChatVoice.OnApplyMessageKeyComplete();
	else
		
	end	
end

-- Upload notify
function GVoice_UploadFileNotify(code, filePath, fileID)
	if GlobalChatVoice.GVOICE_UPLOAD_ERROR == code then
		log("GVoice_UploadFileNotify Failed code=" .. code);
		
	else
		log("GVoice_UploadFileNotify code=" .. code .. " filePath=" .. filePath .. " fileID=" .. fileID);
		BP_GlobalChatvoiceUploadMsgId = fileID;
		GlobalChatVoice.OnUploadRecordFileComplete();
	end	
end

function GVoice_SpeechToTextNotify(code, fileID, result)
	if GlobalChatVoice.GVOICE_STT_ERR == code or GlobalChatVoice.GVOICE_STT_ERR2 == code then
		log("GVoice_SpeechToTextNotify failed code=" .. tostring(code) .. " fileID=" .. tostring(fileID));
		GlobalChatVoice.OnSpeechToTextFailed();
		return;
	end
	
	if nil == result then
		result = "";
	end
	
	log("GVoice_SpeechToTextNotify code=" .. tostring(code) .. " fileID=" .. tostring(fileID) .. " result=" .. result);
	
	BP_GlobalChatvoiceToTextContent = result;
	GlobalChatVoice.OnSpeechToTextComplete();
end

function GVoice_DownLoadFileNotify(code, filePath, fileID)
	log("GVoice_DownLoadFileNotify " .. tostring(code) .. filePath .. tostring(fileID));
	
	GlobalChatVoice.OnDownloadFileComplete();
end

-- OPERATION NOTIFY

function GVoice_SetAppInfoFailed(code, user_id)
	log("GVoice_SetAppInfoFailed " .. tostring(code) .. " user_id " .. user_id);
	if GlobalChatVoice.GVOICE_OPERR_GVOICE_SERVICE_ERR == code then
		PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", 106049).TextValue);
	else
		PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", 106050).TextValue .. tostring(code));
	end
end

function GVoice_RecordSuccess()
	log("GVoice_RecordSuccess");
	GlobalChatVoice.OnRecordSuccess();
end

function GVoice_RecordFailed(code)
	log("GVoice_RecordFailed " .. tostring(code));
	
	if (GlobalChatVoice.GVOICE_OPERR_PMSMIC_ERR == code) or (GlobalChatVoice.GVOICE_OPERR_PMSMIC_ERR2 == code) then
		PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", 106048).TextValue)--(Client.GetTableData("LocalizeRes", 106048).TextValue);
	elseif GlobalChatVoice.GVOICE_OPERR_HTTP_BUSY == code then
		PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", 106049).TextValue);--(Client.GetTableData("LocalizeRes", 106049).TextValue);
	elseif GlobalChatVoice.GVOICE_OPERR_GVOICE_SERVICE_ERR == code then
		PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", 106049).TextValue);
	else
		PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", 106050).TextValue .. tostring(code));--(Client.GetTableData("LocalizeRes", 106050).TextValue);
	end
		
	GlobalChatVoice.OnRecordFailed();	
end

function GVoice_UploadSuccess()
	GlobalChatVoice.OnUploadSuccess();
end

function GVoice_UploadFailed(code)
	log("GVoice_UploadFailed " .. tostring(code));
	
	if GlobalChatVoice.GVOICE_OPERR_UPLOAD_ERR == code then
		PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", 106048).TextValue)--(Client.GetTableData("LocalizeRes", 106051).TextValue);
	elseif GlobalChatVoice.GVOICE_OPERR_HTTP_BUSY == code then
		PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", 106049).TextValue);--(Client.GetTableData("LocalizeRes", 106049).TextValue);
	elseif GlobalChatVoice.GVOICE_OPERR_CHANGEMODE_ERR == code then
		
	elseif GlobalChatVoice.GVOICE_OPERR_GVOICE_SERVICE_ERR == code then
		PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", 106049).TextValue);
	else
		PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", 106050).TextValue .. tostring(code));--(Client.GetTableData("LocalizeRes", 106050).TextValue);
	end
	
	GlobalChatVoice.OnUploadFailed();
end	

function GVoice_SpeechToTextSuccess()
	GlobalChatVoice.OnSpeechToTextSuccess();	
end

function GVoice_SpeechToTextFailed(code)
	log("GVoice_SpeechToTextFailed " .. tostring(code));
	
	if GlobalChatVoice.GVOICE_OPERR_HTTP_BUSY == code then
		PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", 106049).TextValue);--(Client.GetTableData("LocalizeRes", 106049).TextValue);
	elseif GlobalChatVoice.GVOICE_OPERR_TOTEXTPROCESSING_ERR == code then
		
	elseif GlobalChatVoice.GVOICE_OPERR_CHANGEMODE_ERR == code then
		
	elseif GlobalChatVoice.GVOICE_OPERR_GVOICE_SERVICE_ERR == code then
		PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", 106049).TextValue);
	else
		PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", 106050).TextValue .. tostring(code));--(Client.GetTableData("LocalizeRes", 106050).TextValue);
	end	
	
	GlobalChatVoice.OnSpeechToTextFailed();
end

function GVoice_DownloadFileSuccess()
	GlobalChatVoice.OnDownloadFileSuccess();
end

function GVoice_DownloadFileFailed(code)
	log("GVoice_DownloadFileFailed " .. tostring(code));
	
	if GlobalChatVoice.GVOICE_OPERR_HTTP_BUSY == code then
		PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", 106049).TextValue);--(Client.GetTableData("LocalizeRes", 106049).TextValue);
	elseif GlobalChatVoice.GVOICE_OPERR_CHANGEMODE_ERR == code then
		
	elseif GlobalChatVoice.GVOICE_OPERR_GVOICE_SERVICE_ERR == code then
		PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", 106049).TextValue);
	else
		PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", 106050).TextValue .. tostring(code));--(Client.GetTableData("LocalizeRes", 106050).TextValue);
	end
	
	GlobalChatVoice.OnDownloadFileFailed();
end

function GVoice_PlayFileSuccess()

end

function GVoice_PlayFileFailed(code)
	log("GVoice_PlayFileFailed " .. tostring(code));	
end

function GVoice_OpenSpeakerSuccess()
	log("GVoice_OpenSpeakerSuccess");
end

function GVoice_OpenSpeakerFailed(code)
	log("GVoice_OpenSpeakerFailed " .. tostring(code));
	GlobalChatVoice.OnOpenSpeakerFailed();
end

function GVoice_CloseSpeakerSuccess()
	log("GVoice_CloseSpeakerSuccess");
end

function GVoice_CloseSpeakerFailed(code)
	log("GVoice_CloseSpeakerFailed " .. tostring(code));
end

function GVoice_CloseMicSuccess()
	log("GVoice_CloseMicSuccess");
end

function GVoice_CloseMicFailed(code)
	log("GVoice_CloseMicFailed " .. tostring(code));
end

function GVoice_OpenMicSuccess()
	GlobalChatVoice.OnOpenMicSuccess();
end

function GVoice_OpenMicFailed(code)
	log("GVoice_OpenMicFailed " .. tostring(code));
	
	if (GlobalChatVoice.GVOICE_OPERR_PMSMIC_ERR == code) or (GlobalChatVoice.GVOICE_OPERR_PMSMIC_ERR2 == code) then
		PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", 106048).TextValue)--(Client.GetTableData("LocalizeRes", 106048).TextValue);
	elseif GlobalChatVoice.GVOICE_OPERR_GVOICE_SERVICE_ERR == code then
		PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", 106049).TextValue);
	else
		PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", 106050).TextValue .. tostring(code));
	end
	
	GlobalChatVoice.OnOpenMicFailed();
end

function GlobalChatVoice.HandleJoinRoomSuccess(roomName, memberID)
	GlobalChatVoice.voiceErrHandle = 0;
	GlobalChatVoice.voiceEnterRoomId = roomName;
	BP_GlobalChatvoiceCurrentRoom = roomName;
	GlobalChatVoice.OnJoinVoiceRoomSuccess(roomName, memberID);
	GlobalChatVoice.HandleVoiceRoomAsync();
end

function GlobalChatVoice.HandleJoinRoomFailed()
	GlobalChatVoice.voiceErrHandle = GlobalChatVoice.voiceErrHandle + 1;
	
	if GlobalChatVoice.CheckRetryFailed() then
		return;
	end
	
	log("GlobalChatVoice.HandleJoinRoomFailed" .. "  " ..  tostring(os.time()));
	
	GlobalChatVoice.UnlockVoiceOperation()
	GlobalChatVoice.HandleVoiceRoomOperation();
end

function GlobalChatVoice.HandleQuitRoomFailed()
	log("GlobalChatVoice.HandleQuitRoomFailed()" .. "  " ..  tostring(os.time()));	
	GlobalChatVoice.voiceErrHandle = GlobalChatVoice.voiceErrHandle + 1;
	
	if GlobalChatVoice.CheckRetryFailed() then
		log("GlobalChatVoice.HandleQuitRoomFailed()2" .. "  " ..  tostring(os.time()));
		return;
	end
	
	GlobalChatVoice.UnlockVoiceOperation()
	GlobalChatVoice.HandleReenterVoiceRoom()
end

function GlobalChatVoice.CheckRetryFailed()
	if GlobalChatVoice.voiceErrHandle >= GlobalChatVoice.voiceErrMaxHandle then
		log("GVoice_Try Redo Failed");
		GlobalChatVoice.voiceErrHandle = 0;
		GlobalChatVoice.UnlockVoiceOperation()
		GlobalChatVoice.voiceIsInited = true;
		GlobalChatVoice.voiceRetryFailed = true;
		GlobalChatVoice.ResetVoiceOperation();
		return true;
	else
		return false;
	end
end

function GlobalChatVoice.ClearRetryFailure()
	log("gvoice ClearRetryFailure");
	GlobalChatVoice.voiceErrHandle = 0;
	GlobalChatVoice.voiceRetryFailed = false;
end

function GVoice_JoinRoomFailed(code)
	log("GVoice_JoinRoomFailed " .. tostring(code) .. tostring(GlobalChatVoice.voiceOperationLock));
	
	if GlobalChatVoice.GVOICE_OPERR_ALREADYINROOM_ERR == code then		
		GlobalChatVoice.HandleJoinRoomSuccess(GlobalChatVoice.voiceBufferRoomId, GlobalChatVoice.voiceLobbyMemberId);
	elseif 8194 == code then
		GlobalChatVoice.UnlockVoiceOperation()
		GlobalChatVoice.ResetVoiceOperation();
		GlobalChatVoice.voiceEnterRoomId = GlobalChatVoice.voiceBufferRoomId;
		BP_GlobalChatvoiceCurrentRoom = GlobalChatVoice.voiceEnterRoomId;
		GlobalChatVoice.QuitRoomTemp();
	else
		GlobalChatVoice.HandleJoinRoomFailed();
	end	
end

function GVoice_QuitRoomFailed(code)
	log("GVoice_QuitRoomFailed " .. tostring(code));
	
	if code == 8195 or code == 8198 then
		GlobalChatVoice.voiceErrHandle = GlobalChatVoice.voiceErrHandle + 1;	
		if GlobalChatVoice.CheckRetryFailed() then
			return;
		end
		
		GlobalChatVoice.voiceEnterRoomId = "";		
		BP_GlobalChatvoiceCurrentRoom = "";
		GlobalChatVoice.UnlockVoiceOperation();
		GlobalChatVoice.OnQuitVoiceRoomSuccess();
		GlobalChatVoice.HandleVoiceRoomAsync();
	else
		log("GVoice_QuitRoomFailed handle HandleQuitRoomFailed" .. "  " ..  tostring(os.time()));
		GlobalChatVoice.HandleQuitRoomFailed();
	end	
end

function GVoice_OnCallGetAuthKey(code)

	log("GVoice_OnCallGetAuthKey " .. tostring(code));
end

function GVoice_JoinLbsRoomFailed(code)

	log("GVoice_JoinLbsRoomFailed " .. tostring(code));
end

function GVoice_QuitLbsRoomFailed(code)
	log("GVoice_QuitLbsRoomFailed " .. tostring(code));
end

function GVoice_MemberIsSpeakingNotify(room_name, member, status)
	--log("GVoice_MemberIsSpeakingNotify " .. room_name .. " " .. tostring(member) .. " " .. tostring(status))
	GlobalChatVoice.OnMemberSpeaking(room_name, member, status);
end

function GVoice_ImSpeakingNotify(member, status)	
	local curStatus = string.lower(LuaClassObj.GetGameStatus(bp_chat_voice));
	if "lobby" ~= curStatus then
		return;
	end
	
	if GlobalChatVoice.voiceLobbyRoomId ~= GlobalChatVoice.voiceEnterRoomId then
		return;
	end	

	TeamUpUI.SetVoiceSpeaking(BP_GlobalChatvoiceCurrentRole, 0 ~= status);
end

function GVoice_ReportVoiceTimeToServer(totalTalkingTime, totalGamingTime)
	log("----report player voice time: talkingTime = " .. tostring(totalTalkingTime).." --gameTime = "..tostring(totalGamingTime));
	NetUtil.SendPkg("report_game_activity", totalTalkingTime, totalGamingTime);
end

function GVoice_StatusUpdatedNotify(room_name, member_id)
	log("GVoice_StatusUpdatedNotify " .. room_name .. "  " ..  tostring(os.time()));
	
	local curStatus = string.lower(LuaClassObj.GetGameStatus(bp_chat_voice));
	if "lobby" == curStatus and room_name == GlobalChatVoice.voiceLobbyRoomId then
		log("GVoice_StatusUpdatedNotify1111" .. "  " ..  tostring(os.time()))
		--GlobalChatVoice.QuitRoomTemp();
	elseif "fighting" == curStatus and room_name == GlobalChatVoice.voiceGameRoomId then
		--GlobalChatVoice.QuitRoomTemp();
	else
		log("GVoice_StatusUpdatedNotify other status " .. room_name .. " lobby room " .. GlobalChatVoice.voiceLobbyRoomId .. " game room " .. GlobalChatVoice.voiceGameRoomId);
		log("GVoice_StatusUpdatedNotify error stage " .. curStatus);
	end
	
	GlobalChatVoice.voiceEnterRoomId = room_name;		
	BP_GlobalChatvoiceCurrentRoom = room_name;
	
	GlobalChatVoice.UnlockVoiceOperation();
	GlobalChatVoice.ResetVoiceOperation();
	GlobalChatVoice.QuitRoomTemp();
end

function GVoice_SetAppInfoSuccess(user_id, game_id)
	log("GVoice_SetAppInfoSuccess");
	if nil ~= game_id then
		GlobalChatVoice.voiceServiceId = game_id;
	end
end

function GVoice_SetAppInfoFailed(code, user_id)
	log("GVoice_SetAppInfoFailed" .. tostring(code));
end

function GVoice_GetReconnectInfo()
	log("GVoice_GetReconnectInfo");

	local data = {};
    data["GvoiceReEnterRoomMaxCount"] = tostring(GlobalChatVoice.GvoiceReEnterRoomMaxCount);
    data["GvoiceReEnterDuration"] = tostring(GlobalChatVoice.GvoiceReEnterDuration);

    Client.GetGvoiceReconnectInfo(GameFrontendHUD, data)
end

function GVoice_OnMuteSwitchResult(code)
	log("GVoice_OnMuteSwitchResult" .. tostring(code));
	if code == 1 then
		PopUpNoticeUI.ShowNewNotice(FuncUtil.GetLocalizeResStr(6403));
	end
end

function GVoice_EnableGvoice(enable)
	log("GVoice_EnableGvoice" .. tostring(enable));
	Client.EnableGvoice(GameFrontendHUD, enable)
end