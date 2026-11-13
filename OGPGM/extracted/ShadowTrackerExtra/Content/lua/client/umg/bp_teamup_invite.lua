--组队邀请UI
TeamUpInviteUI = TeamUpInviteUI or
{
	
}

TeamUp_Invite_Apply_Type = 0; 	--0是邀请，1是申请，2是房间邀请
TeamUp_Inviter_Name = "";		--邀请我组队的好友名字
TeamUp_Applyer_Name = "";		--申请加入的玩家名字
TeamUp_Count_Down = 10;			--倒计时5秒自动拒绝

TEAMUP_INVITE_TIP = "";
TEAMUP_APPLY_TIP = "";
TEAMUP_INVITE_TIMEOUT_TIP = "";
TEAMUP_APPLY_TIMEOUT_TIP = "";
TeamUp_Auto_Refuse = false;		--是否自动拒绝邀请/申请
--点击邀请头像ID
BP_TopTip_ClickHeadID = "";

TeamUp_Invite_GameType = 1;  --1普通，2天命圈,3第一人称

--邀请组队提示框显示头像相关信息
BP_STRUCT_TopTipProfileInfo = 
{
	gid="",
	nickName = "",
	level = 0,
    picUrl = "",
    vipLevel = 0,
    ladder = 0,
    platName = "",
	sex = 0,
	segment_info_solo = 0;-- 段位数据
	segment_info_duo = 0;
	segment_info_squad = 0;
	cur_avatar_box_id = 0; --头像框
	history_max_segment_level = 0;
	remarks_name="";--备注名称，有备注名称表示备注名称，无备注表示平台名称
}
--拒绝的消息
BP_TopTipApplyMessage = "";

--拒绝消息结构,默认3条
BP_STRUCT_TopTipRefuseInfo = 
{
	refuseInfo = "";
}
BP_ARRAY_TopTipRefuseInfos =
{
	BP_STRUCT_TopTipRefuseInfo = _G.BP_STRUCT_TopTipRefuseInfo;
}


function bp_teamup_invite_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_teamup_invite,
    {
    	{Path="/Game/UMG/UI_Logic/Lobby/Lobby_InviteRoomTipsLogic_BP.Lobby_InviteRoomTipsLogic_BP_C", Container="Top", ZOrder=BP_ENUM_UI_COMMON_ITEMTIPS_ZORDER + 1}
    },
    {"Lobby", "Fighting"},
    false,
	false,
	true
    );
end

--切换场景
function bp_teamup_invite_OnModeSwitched(gamestatus)
	if string.lower(gamestatus) == "fighting" then
		LuaClassObj.HandleUIMessage(bp_teamup_invite, "Hide");
	end
end

function TeamUpInviteUI.Init()
	TEAMUP_INVITE_TIP = DataMgr.GetMsgByID(110005);		--邀请您组队
	TEAMUP_APPLY_TIP = DataMgr.GetMsgByID(110010);		--申请加入组队
	TEAMUP_INVITE_TIMEOUT_TIP = DataMgr.GetMsgByID(110006);	--5分钟内忽略该玩家邀请
	TEAMUP_APPLY_TIMEOUT_TIP = DataMgr.GetMsgByID(110015);	--5分钟内忽略该玩家邀请
end

--初始化拒绝消息提示内容
function TeamUpInviteUI.InitTopTipsInfo()
	BP_ARRAY_TopTipRefuseInfos = {};
	local tips = DataMgr.GetMsgByID(117077); --"不好意思，现在不方便。";
	table.insert( BP_ARRAY_TopTipRefuseInfos, {refuseInfo = tips});
	local tips = DataMgr.GetMsgByID(117078);--"请稍等一下";
	table.insert( BP_ARRAY_TopTipRefuseInfos, {refuseInfo = tips});
	local tips = DataMgr.GetMsgByID(117079);--"不好意思，现在不方便，晚点再约。";
	table.insert( BP_ARRAY_TopTipRefuseInfos, {refuseInfo = tips});
end


function TeamUpInviteUI.ShowInvite()
	if not GetWindowOBState() then
		--军团战模式
		if TeamUp_Invite_GameType == 4 then
			TEAMUP_INVITE_TIP = DataMgr.GetMsgByID(412048);		--邀请您加入军团演习
		end

		log("EVENTID_TEAMUP_GET_INVITE");
		TeamUp_Invite_Apply_Type = 0;
		--TeamUp_Inviter_Name = TeamUpSystem.GetMemberName(TeamUpSystem.Inviter);
		TeamUp_Auto_Refuse = false;				
		TeamUpInviteUI.ReReuseInfoNickName();
		
		TeamUpInviteUI.UpdateTopTipRemarkName();
		LuaClassObj.HandleDynamicCreation(bp_teamup_invite);
		LuaClassObj.HandleUIMessage(bp_teamup_invite, "ShowTopTip");
	end
end

function TeamUpInviteUI.ShowApply()
	if not GetWindowOBState() then
		log("EVNETID_TEAMUP_APPLY_JOIN");
		TeamUp_Invite_Apply_Type = 1;
		TeamUp_Auto_Refuse = false;				
		TeamUpInviteUI.ReReuseInfoNickName();
		TeamUpInviteUI.UpdateTopTipRemarkName();

		LuaClassObj.HandleDynamicCreation(bp_teamup_invite);
		LuaClassObj.HandleUIMessage(bp_teamup_invite, "ShowTopTip");
	end
end


function TeamUpInviteUI.ReReuseInfoNickName(strTip)
	if strTip == nil or strTip == "" then
		--默认提示
		strTip = DataMgr.GetMsgByID(117077);-- "不好意思，现在不方便。";
	end	
	local nickName = DataMgr.roleData.nickName;
	local middleStr = DataMgr.GetMsgByID(117080); --"婉拒了您，并表示：";
	local refuse = strTip;
	BP_TopTipApplyMessage = "";
	BP_TopTipApplyMessage = tostring(nickName)..tostring(middleStr)..tostring(refuse);
end

function TeamUpInviteUI.SetRoomInviteTipsInfo()
	log("TeamUpInviteUI.SetRoomInviteTipsInfo");
	TeamUp_Invite_Apply_Type = 2;
	TeamUp_Auto_Refuse = false;				
	TeamUpInviteUI.ReReuseInfoNickName();
	TeamUpInviteUI.UpdateTopTipRemarkName();
	
	LuaClassObj.HandleDynamicCreation(bp_teamup_invite);
	LuaClassObj.HandleUIMessage(bp_teamup_invite, "ShowTopTip");
end

function TeamUpInviteUI.CloseInviteApplyPanel()
	if (TeamUpSystem.InviteApplyShowing) then
		
		if (TeamUpSystem.InviteApplyShowType == 0) then
			TeamUpSystem.team_invite_reply("autoRefuseOnTeamChange", tonumber(TeamUpSystem.Inviter), tonumber(TeamUpSystem.InviterTeamID));
		elseif (TeamUpSystem.InviteApplyShowType == 1) then
			TeamUpSystem.team_apply_reply("autoRefuseOnTeamChange", tonumber(TeamUpSystem.ApplyerID), tonumber(TeamUpSystem.ApplyerTeamID));
		elseif (TeamUpSystem.InviteApplyShowType == 2) then
			TeamUpSystem.room_invite_reply("autoRefuseOnTeamChange", tonumber(TeamUpSystem.InviterRoomID), tonumber(TeamUpSystem.Inviter));
		end
		
		TeamUpSystem.InviteApplyShowing = false;
		--LuaClassObj.HandleUIMessage(bp_teamup_invite, "HideInviteApplyPanel");
	end
end


function EventTeamUpSelectRefuseInfo()
	log("EventTeamUpSelectRefuseInfo"..tostring(BP_TopTipApplyMessage))
	TeamUpInviteUI.ReReuseInfoNickName(BP_TopTipApplyMessage);
end


--回复收到的组队邀请 --同意入队
function EventTeamUpInviteAgree()
	---如果在战斗中，退到大厅
	local curStatus = string.lower(LuaClassObj.GetGameStatus(bp_lobby));
	if curStatus == "fighting" then
		if BP_IsReceiveResult then
			TeamUpSystem.room_invite_reply("ok", TeamUpSystem.InviterRoomID, TeamUpSystem.Inviter);
			TeamUpSystem.InviteApplyShowing = false;
			TeamUpSystem.CheckNextInviteApply()
			log("--结算界面点接受,退回到大厅 ---");
			LoadingUI:Init();
			SettingUI:Hide();
			LobbySystem.ReturnToLobby();
		else
			LuaClassObj.HandleUIMessage(bp_teamup_invite, "InvitePermitBackToLobby");
		end
	else
		TeamUpSystem.room_invite_reply("ok", TeamUpSystem.InviterRoomID, TeamUpSystem.Inviter);
	end
	--cole 房间邀请跳转bug
	EventCloseUnknowPass()
	EventClosePDDSystemUI()
	EventStartCloseMallSystem()
	AllianceUI:CloseTeamMainPanel()
	WarZoneRankUI.CloseUI()
	RoleInfoUI.BtnCloseRoleInfo()
	LevelUpSystem.ClosePveLevelupPanel()
	PopUpNoticeUI:OnClickCloseUI()
	ArmoryUI.CloseUI()
	ItemUpgradeUI.Hide();
	CreateRoleUI.ClosePanel();
	ItemUpgradeUI.jumpViewCloseCallBack = nil;
	SupplyMainUI.CloseUI();
	StoreMainUI.CloseUI();
	LeagueGameTreasureBoxUI.Hide(false);

	local ItemPrewViewSystem = require("client.slua.logic.item_preview.logic_itemPreview")
	ItemPrewViewSystem.CloseItemPreviewPanel();
end

function TeamUpInviteApplyPermitImpl()
	log("EventTeamUpInviteApplyPermit");
	
	if (TeamUp_Invite_Apply_Type == 0) then
		TeamUpSystem.team_invite_reply("ok", TeamUpSystem.Inviter, TeamUpSystem.InviterTeamID);
		
	elseif (TeamUp_Invite_Apply_Type == 1) then
		TeamUpSystem.team_apply_reply("ok", TeamUpSystem.ApplyerID, TeamUpSystem.ApplyerTeamID);
		
	elseif (TeamUp_Invite_Apply_Type == 2) then
		TeamUpSystem.room_invite_reply("ok", TeamUpSystem.InviterRoomID, TeamUpSystem.Inviter);
		
	end

	TeamUpSystem.InviteApplyShowing = false;
	TeamUpSystem.CheckNextInviteApply()
end

function EventInvitePermitFromWatchingBackToLobby()
	local function confirmClick()
		TeamUpInviteApplyPermitImpl();

		TeamUpSystem.InviteApplyShowing = false;
		TeamUpSystem.CheckNextInviteApply()

		log("--好友观战中同意组队邀请,退回到大厅 ---");
		LoadingUI:Init();
		SettingUI:Hide();
		NetUtil.SendPkg("leave_battle_watch");
		LobbySystem.ReturnToLobby();
	end

	CommonMessageBoxUI:ShowPanel(2, Client.GetTableData("LocalizeRes", "101001").TextValue, Client.GetTableData("LocalizeRes", "110149").TextValue, confirmClick);
end

--主动拒绝和被动拒绝入口
function TeamUpInviteUI.ApplyRefuse(extendInfo)
	--log_tree("aaaaaaaaaa",extendInfo);
	--extend_info={reply_type=1(主动回复) or 2(被动回复), refuseMsgInfo = "",主动拒绝信息}

	if (TeamUp_Invite_Apply_Type == 0) then
		TeamUpSystem.team_invite_reply("refuse", TeamUpSystem.Inviter, TeamUpSystem.InviterTeamID, "", extendInfo);
		if (TeamUp_Auto_Refuse == true) then
			TeamUpSystem.AutoRefuseInviterMap[TeamUpSystem.Inviter] = FuncUtil.GetServerTimeInSec();
		end

	elseif (TeamUp_Invite_Apply_Type == 1) then
		TeamUpSystem.team_apply_reply("refuse", TeamUpSystem.ApplyerID, TeamUpSystem.ApplyerTeamID, extendInfo);
		if (TeamUp_Auto_Refuse == true) then
			TeamUpSystem.AutoRefuseApplyerMap[TeamUpSystem.ApplyerID] = FuncUtil.GetServerTimeInSec();
		end
	
	elseif (TeamUp_Invite_Apply_Type == 2) then
		TeamUpSystem.room_invite_reply("refuse", TeamUpSystem.InviterRoomID, TeamUpSystem.Inviter, "", extendInfo);
		if (TeamUp_Auto_Refuse == true) then
			TeamUpSystem.AutoRefuseInviterMap[TeamUpSystem.Inviter] = FuncUtil.GetServerTimeInSec();
		end
	end
	TeamUpSystem.InviteApplyShowing = false;
	TeamUpSystem.CheckNextInviteApply();

end


--倒计时结束自动拒绝
function EventTeamUpInviteApplyAutoRefuse()
	--extend_info={reply_type=1(主动回复) or 2(被动回复), }
	local extendInfo = {};
	extendInfo.reply_type = 2;
	--自动拒绝用refuse
	TeamUpInviteUI.ApplyRefuse(extendInfo);
end

--拒绝收到的组队邀请 --主动拒绝
function EventTeamUpInviteApplyRefuse()	
	log("EventTeamUpInviteApplyRefuse"..tostring(TeamUp_Invite_Apply_Type).."BP_TopTipApplyMessage:"..tostring(BP_TopTipApplyMessage));

	local extendInfo = {};
	extendInfo.reply_type = 1;
	extendInfo.refuseMsgInfo = tostring(BP_TopTipApplyMessage);
	--主动拒绝用refuseactive
	TeamUpInviteUI.ApplyRefuse(extendInfo);

end

function EventTeamUpClickHead()
	local curStatus = string.lower(LuaClassObj.GetGameStatus(bp_lobby));
	if curStatus == "lobby" then  
		log("EventTeamUpClickHead"..BP_TopTip_ClickHeadID);	
		RoleInfoSystem.Enter(BP_TopTip_ClickHeadID);	
		RoleInfoUI.Init();
	end
end

function EventRemoveAllInviteByCurInviter()
	TeamUpSystem.RemoveAllRoomInvite()
end

function EventFetchInfo()
	
end

function TeamUpInviteUI.UpdateTopTipRemarkName()
	local uid = 0;
	if TeamUp_Invite_Apply_Type == 0 then
		uid = TeamUpSystem.Inviter;
	elseif TeamUp_Invite_Apply_Type == 1 then
		uid = TeamUpSystem.ApplyerID;
	elseif TeamUp_Invite_Apply_Type == 2 then
		uid = TeamUpSystem.Inviter;
	end

	--拉取平台昵称回调
	local function getRemarNameCallBack(listinfo)
		--log("getRemarNameCallBack"..tostring(uid));
		--log_tree("getRemarNameCallBack",listinfo);
		local count = #listinfo;
		if count == 0 then
			return;
		end

		--图像框显示逻辑
		BP_STRUCT_TopTipProfileInfo.gid= listinfo[1].uid;
		BP_STRUCT_TopTipProfileInfo.level = listinfo[1].level;
		BP_STRUCT_TopTipProfileInfo.picUrl = listinfo[1].picUrl;
		BP_STRUCT_TopTipProfileInfo.vipLevel = listinfo[1].vipLevel;
		BP_STRUCT_TopTipProfileInfo.platName = listinfo[1].platName;
		BP_STRUCT_TopTipProfileInfo.sex = listinfo[1].sex;
		BP_STRUCT_TopTipProfileInfo.segment_info_solo = listinfo[1].segment_info[1];-- 段位数据
		BP_STRUCT_TopTipProfileInfo.segment_info_duo = listinfo[1].segment_info[2];
		BP_STRUCT_TopTipProfileInfo.segment_info_squad = listinfo[1].segment_info[3];
		BP_STRUCT_TopTipProfileInfo.cur_avatar_box_id = listinfo[1].cur_avatar_box_id; --头像框		

		local platName =  listinfo[1].platName;
		local nickName = listinfo[1].nickName;
		local isFriend = FriendSystem.IsPlatFriend(listinfo[1].uid);
		--log("isFriend"..tostring(isFriend));
		if isFriend == false then	
			if nickName ~= nil and nickName ~= "" then
				--非好友不显示平台名字和备注名字,只显示昵称
				if TeamUp_Invite_Apply_Type == 0 then
					TeamUp_Inviter_Name = nickName;
				elseif TeamUp_Invite_Apply_Type == 1 then
					TeamUp_Applyer_Name = nickName;
				elseif TeamUp_Invite_Apply_Type == 2 then
					TeamUp_Inviter_Name = nickName;
				end				
			end	
			LuaClassObj.HandleUIMessage(bp_teamup_invite, "RefreshInfo");
			return;
		end 
		
		--如果是好友，先取remark备注名字，如果没有再取平台名
		local remarkName = "";
		local curGID = listinfo[1].uid;
		local friendData = FriendSystem.GetFriendDataByGID(tonumber(curGID));
		--log_tree("friendData",friendData);
		if friendData ~= nil and friendData.remarks_name ~= nil then
			remarkName = friendData.remarks_name;
		end

		if remarkName ~= "" then
			log("111111111"..nickName.."--"..platName);	
			--重新组合下名字
			if TeamUp_Invite_Apply_Type == 0 then
				TeamUp_Inviter_Name = nickName;--.."("..remarkName..")";
			elseif TeamUp_Invite_Apply_Type == 1 then
				TeamUp_Applyer_Name = nickName;--.."("..remarkName..")";
			elseif TeamUp_Invite_Apply_Type == 2 then
				TeamUp_Inviter_Name = nickName;--.."("..remarkName..")";
			end	
		else
			--log("22222222222");
			if platName ~= nil and platName ~= "" and nickName ~= nil and nickName ~= ""  then		
				log("22222222222"..nickName.."--"..platName);		
				--重新组合下名字
				if TeamUp_Invite_Apply_Type == 0 then
					TeamUp_Inviter_Name = nickName;--.."("..platName..")";
				elseif TeamUp_Invite_Apply_Type == 1 then
					TeamUp_Applyer_Name = nickName;--.."("..platName..")";
				elseif TeamUp_Invite_Apply_Type == 2 then
					TeamUp_Inviter_Name = nickName;--.."("..platName..")";
				end		
				
			end	
		end

		LuaClassObj.HandleUIMessage(bp_teamup_invite, "RefreshInfo");
		


	end 

	--请求概要信息
	if uid ~= 0 then
		ProfileMgr.GetProfile(tonumber(uid), getRemarNameCallBack, false);
	end

end

