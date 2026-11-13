
function ingame_RegisterUI(self)
  
  InGameUIManager.SubUIWidgetList(self,
    {
	{Path="/Game/BluePrints/ControlInput/MainControlPanelTochButton.MainControlPanelTochButton_C", Container="Default", ZOrder=0},
	{Path="/Game/BluePrints/ControlInput/ResultsshareUI/DeathPlayback_UIBP.DeathPlayback_UIBP_C", Container="Default", ZOrder=0},
	},
    {"Fighting", "Training"},
	false,
	true,
	false
  );
  ingame = self;
  FuncUtil:InitConfigs()
end

function ReturnToLobbyConfirm()

	local text = "<LightWhite>" .. FuncUtil.GetLocalizeResStr("110140") .. "</>";
	CommonMessageBoxUI:ShowPanel(2, FuncUtil.GetLocalizeResStr("101001"), text, ReturnToLobbyConfirm_YES, ReturnToLobbyConfirm_NO)
	
	--[[
	PopUpNoticeUI.ShowNewMessageBox({Title="确认", Content="<Red>请问是否退出战斗</>？...", 
		BP_ARRAY_Buttons={
			{ButtonText="确定", ButtonCallback="ReturnToLobbyConfirm_YES"},
			{ButtonText="取消", ButtonCallback="ReturnToLobbyConfirm_NO"},
		}
	});
	--]]
end

function ReturnToLobbyConfirm_YES()
	--
	LobbySystem.ReturnToLobby();
end

function OpenUISetting()
	SettingUI:Init();
end

function ShowOrHideSetting()
	SettingUI:ShowOrHide();
end

function ShareSelfieShowUI()
	ShareSelfieUI.ShowUI();
end

function ShareSelfieHideUI()
	ShareSelfieUI.HideUI();
end

function OpenReportBug()
	ReportBug:Init();
end

function EventIngameOpenGMMenu()
    GM_UI:ShowPanel();
end

function OpenReportComplaint()
	ComplaintUI:Init();
end

function OpenReportComplaintFromWatching()
	ComplaintUI:Init();
	Complaint_IsWatchMode = true;
end

function OpenReportComplaintInvalid()
	local InvalidStr = DataMgr.GetMsgByIDForBattleText(30022)
	DataMgr.ShowNoticeByString(InvalidStr)
	PopUpNoticeUI:Init()
end

function OpenReportComplaintInIormation()
	ComplaintUI:Init();
	ComplaintUI:SetInfoInLobby();
end


function ReturnToLobbyConfirm_NO()
	---
end

function EventLuaMemoryProfile()
	MemoryUtil:DumpLuaBaseMemory()
end

function EventLuaObjRefAnalysis()
	-- MemoryUtil:DumpLuaObjRefFile("Bag_Lv3")
    -- MemoryUtil:DumpLuaObjRefFile(_G.BP_ARRAY_AvatarBPTable)
    MemoryUtil:DumpLuaObjRefFile()
end

-- chat start
IngameChat = IngameChat or
{
}
-- 大厅向战斗内发消息
function IngameChat:on_notify_fight_friend_chat(str_gid, this_msg)
	--[[
		thisMsg.uid = str_gid;
		thisMsg.name = sender_name;
		thisMsg.msg = chat_content;	
		thisMsg.selfMsg = self_msg;	
	]]
	sandbox.LogNormal("on_friend_msg 3 sender_name:".. this_msg.name .. " says: ".. this_msg.msg);
	Client.OnNotifyFightFriendChat(GameFrontendHUD, this_msg);
end

-- 战斗内回信息
function EventSendFightChat(gid, content)
	LobbyChatSystem.fight_send_msg(gid, content);
end

-- 向大厅发送脏串
function EventSendDirtyToFilter(dirty, context)
	sandbox.LogNormal("EventSendDirtyToFilter dirty:" .. dirty);
	sandbox.LogNormal("EventSendDirtyToFilter context:" .. context);
	LobbyChatSystem.filter_text_req(dirty, context);
end

-- 大厅返回过滤串
function IngameChat:on_filter_finish(filter_text, context)
	sandbox.LogNormal("on_filter_finish:" .. filter_text);
	sandbox.LogNormal("on_filter_finish context:" .. context);
	Client.OnFilterFinish(GameFrontendHUD, context .. filter_text);
end

-- 大厅邀请
function IngameChat:on_reserve_require_notify(str_gid, str_name)
	sandbox.LogNormal("on_reserve_require str_gid:".. str_gid .. " str_name: ".. str_name);
	Client.OnInviteNextBattle(GameFrontendHUD, str_gid, str_name);
end


-- 邀请回复
function EventReplyInviteNextBattle(gid, bReply)
	if bReply then
		sandbox.LogNormal("EventReplyInviteNextBattle gid:".. gid .. " bReply: true");
	else
		sandbox.LogNormal("EventReplyInviteNextBattle gid:".. gid .. " bReply: false");
	end
	LobbyChatSystem.on_reserve_reply_req(gid, bReply);
end

-- 进入私聊
function EventEnterFightChat(str_gid)
	LobbyChatSystem.on_enter_fight_chat(str_gid)
end

function EventChatRequestPrivacyInGame()
	log("[CCW]EventChatRequestPrivacyInGame  ingame")
	local function savePrivacyAcceptStatus1()
		InGameUIManager.HandleUIMessage(ingame, "OnChatPrivacyAccepted");
		
	end
	CommonMessageBoxUI:ShowPanel(2, DataMgr.GetMsgByID(102012), DataMgr.GetMsgByID(4073), savePrivacyAcceptStatus1,nil,DataMgr.GetMsgByID(110036),DataMgr.GetMsgByID(110035));
end

-- 离开私聊
function EventQuitFightChat()
	LobbyChatSystem.on_quit_fight_chat();
end
-- chat end

-- Beginner Guide start

IngameBeginnerGuide = IngameBeginnerGuide or
{
	isOpenGuide = true;
}

function EventRetriveFinishedGuide()
	log("Send refresher info req");
	BeginnerGuideSystem.send_refresher_info_req();
end

function EventRecordGuideFinished(guide_id)
	log("Send retrive finished req");
	BeginnerGuideSystem.send_record_finished_guide_req(guide_id);
end

function IngameBeginnerGuide:on_retrive_finished_guide_finish(finished_guide, player_level, player_exp_type)
    
    log("IngameBeginnerGuide:on_retrive_finished_guide_finish"..tostring(player_exp_type))
	log_tree("finished_guide", finished_guide);
	Client.NotifyBeginnerFinishedGuideUpdated(GameFrontendHUD, IngameBeginnerGuide.isOpenGuide, finished_guide, player_level, player_exp_type);
end

-- Beginner Guide end

function ShowBattleUI()
	if LogicLobbyWatching and DataMgr then
		Client.SetShowFriendObservers(GameFrontendHUD,
		DataMgr.IsEnableWatch() and LogicLobbyWatching.IsShowWatcherList()
		);
		Client.SetCanWatchEnemy(GameFrontendHUD, LogicLobbyWatching.IsCanWatchEnemy());
	end
	
	if LobbySystem then
		Client.SetCanWatchEnemy(GameFrontendHUD, LobbySystem.IsCanWatchEnemy());
	end

	InGameUIManager.HandleUIMessage(ingame, "ShowBattleUI");

end

function EventShowAvatarZone()
	if DataMgr.roleData.showAvatarZone == nil or DataMgr.roleData.showAvatarZone == false then
		--显示
		if LobbySystem.LobbyMenuOpenStatus ~= nil and LobbySystem.LobbyMenuOpenStatus[100002] ~= nil and LobbySystem.LobbyMenuOpenStatus[100002].is_open == 0 then
			InGameUIManager.HandleUIMessage(ingame, "UIMsg_HideAvatarZone");
		else
			InGameUIManager.HandleUIMessage(ingame, "UIMsg_ShowAvatarZone");
		end;
	else
		--不显示
		InGameUIManager.HandleUIMessage(ingame, "UIMsg_HideAvatarZone");
	end
end


-- 刷新我的好友观战者信息
function IngameChat.RefreshFriendObserverDetails()
    local nameGames = Client.GetMyFriendObservers(GameFrontendHUD);
    local observerDetails = {};
    for _, name in pairs(nameGames) do
        local friendData = FriendSystem.GetFriendDataByNickname(name);
        if friendData then
            observerDetails[#observerDetails + 1] = 
            {
                PlayerName = friendData.nickName,
                Gender = friendData.sex,
            };
        else
            --[[
	    observerDetails[#observerDetails + 1] = 
            {
                PlayerName = name,
                Gender = 2,
            };
	    --]]
        end
    end
    Client.SetMyFriendObserversDetail(GameFrontendHUD, observerDetails);
end

-- 出生岛显示匹配标签
function EventCheckShowFightStyle()
	return -- albin 屏蔽出生岛显示匹配标签功能
	-- local CurPlayerLevel = DataMgr.roleData.level;
	-- local ShowLabelLevel = tonumber(DataMgr.GetSystemConfig("LabelMatchOpenLevel"));
	-- log("CurPlayerLevel "..tostring(CurPlayerLevel).."ShowLabelLevel "..tostring(ShowLabelLevel))
	-- if ShowLabelLevel then
	-- 	if(CurPlayerLevel >= ShowLabelLevel) then 
	-- 		InGameUIManager.HandleUIMessage(ingame, "UIMsg_ShowFightStyle");
	-- 	end
	-- end
end

function OnQuickMenuWatchingClicked()
    ClientSendBAReport(BP_BA_BATTLE_QUICKMENU_WATCHERLIST, 0);
end


function EventKickPlayerFromGameNotice()
	log("--游戏内, 是否踢出当前玩家 ---");
	local function confirmClick()
		log("--踢出当前玩家 ---");
		Client.ClientKickPlayerFromGame(GameFrontendHUD);
	end

	local content = Client.GetTableData("LocalizeRes", "6275").TextValue; -- "踢出游戏"
	CommonMessageBoxUI:ShowPanel(2, Client.GetTableData("LocalizeRes", "101001").TextValue, content, confirmClick);
end



--字符串分割函数
function StrSplit(str, chr)
	local result = {}
	local findIndex = 0;
	local id = 1;
	while(true)
	do
		findIndex = string.find(str, chr);
		if(findIndex == nil) then
			result[id] = str;
			break;
		end

		local subStr = string.sub(str, 0, findIndex - 1);
		str = string.sub(str, findIndex + 1);

		result[id] = subStr;
		id = id + 1;
	end
	return result;
end
 
--战斗中网络状态数据上报
--上报序号
nReportBattleNetworkStatusSequence = 0;
function ReportBattleNetworkStatus(pingInfo, isResetSequence, fpsInfo)
	--上报序号清0
	if isResetSequence == 1 then
		nReportBattleNetworkStatusSequence = 0;
	end

	--地区id-int
	local zone_id = Client.GetCurrentZoneID();
	--对局id-int
	local gameId = g_game_id;
	--网络类型-int 0 未知; 1 wifi;2 移动网络
	local networkType = 0;
	if Client.HasActiveWifi() then
		networkType = 1;
	else
		networkType = 2;
	end
	--上报序号 0,1,2,...
	local uploadSeq = nReportBattleNetworkStatusSequence;
	--网络信息
	local pinDataArr = StrSplit(pingInfo, "-");
	local avgPing = tonumber(pinDataArr[1]);			--平均延迟
	local maxPing = tonumber(pinDataArr[2]);			--最大延迟
	local minPing = tonumber(pinDataArr[3]);			--最小延迟
	local lostPackRate = tonumber(pinDataArr[4])/10000;	--丢包率,0-1
	local avgNoOutlier = tonumber(pinDataArr[5]);	--去除异常值的均值
	local stdNoOutlier = tonumber(pinDataArr[6]);	--去除异常值的方差
	local numNoOutlier = tonumber(pinDataArr[7]);	--异常值数目
	--单帧耗时信息
	local fpsDataArr = StrSplit(fpsInfo, "-");
	local fpsJitter = tonumber(fpsDataArr[1]);
	local fpsLag = tonumber(fpsDataArr[2]);
	local fpsAvgNoOutlier = tonumber(fpsDataArr[3]);
	local fpsStdNoOutlier = tonumber(fpsDataArr[4]);
	local fpsNumNoOutlier = tonumber(fpsDataArr[5]);

	--发送协议
	NetUtil.SendPkg("report_battle_ping", zone_id, gameId, networkType, uploadSeq, -- meta info
		avgPing, maxPing, minPing, lostPackRate, avgNoOutlier, stdNoOutlier, numNoOutlier, -- 网络信息
		fpsJitter, fpsLag, fpsAvgNoOutlier, fpsStdNoOutlier, fpsNumNoOutlier -- FPS 信息
	);

	nReportBattleNetworkStatusSequence = nReportBattleNetworkStatusSequence + 1;
	
	log(os.date("%Y-%m-%d %H:%M:%S") .."ReportBattleNetworkStatus" ..
		" zone_id=" ..zone_id ..",gameId=" ..gameId ..",networkType="..networkType ..",uploadSeq=" ..uploadSeq ..
		",avgPing=" ..avgPing ..",maxPing=" ..maxPing ..",minPing=" ..minPing ..",lostPackRate=" ..lostPackRate ..
		",avgNoOutlier=" .. avgNoOutlier .. ",stdNoOutlier=" .. stdNoOutlier .. ",numNoOutlier=" .. numNoOutlier ..
		",fpsJitter=".. fpsJitter .. ",fpsLag=" .. fpsLag .. ",fpsAvgNoOutlier=" .. fpsAvgNoOutlier .. ",fpsStdNoOutlier=" .. fpsStdNoOutlier, ",fpsNumNoOutlier=" .. fpsNumNoOutlier
	);
end