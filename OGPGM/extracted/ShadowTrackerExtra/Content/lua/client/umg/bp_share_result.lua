--[[
	结算分享页面 2017-12-12
--]]

ShareResultUI = ShareResultUI or {

}

-- 根据玩家排名来获取不同的bg
BP_PlayerRank = 1;
--
BP_PlayerCount = 100;
--
BP_KillNum = 0;
--
BP_ShareResultTeamNum = 0;
--
BP_PlayerIcon = "";
--
BP_PlayerName = "LightSpeed";
--
BP_ModeKillInfo = "";
--
BP_ShareImagePath = "";

BP_LoginChannel = 0;

BP_SHARE_RESULT_TYPE = 1;  --1游戏名次分享，2游戏数据分享

BP_IsShowingBriefDetail = true; -- 是否显示简略信息

BP_Terminator = "";

BP_ARRAY_ShouldShowPlayerListDetail = {true, true, true, true}; --是否显示某个玩家的信息

BP_ARRAY_AlreadyUpvoteList = {false, false, false, false}; --是否已经对该玩家点赞

BP_ShareResult_FamousId = 1;

BP_ShareResult_SelectedTitle = 1;

BP_ShareResult_TeamShowSingle = false;


--只在战斗中拉起--
function bp_share_result_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_share_result,
		{
			{Path="/Game/BluePrints/ControlInput/ResultsshareUI/ShareBP/ShareResult_UIBP.ShareResult_UIBP_C", Container="Default", ZOrder=BP_ENUM_UI_Share_Game_Result_ZORDER},
		},
		{"Fighting"},
		false,
		false,
		true
	);
end	 


function EventShareResult_ShowUI_Push()
	BP_PlayerName = BP_myname;
	BP_KillNum = BP_mykill;
	BP_ShareResultTeamNum = BP_STRUCT_BattleResultData.max_game_num;
	BP_PlayerCount = BP_STRUCT_BattleResultData.TotalPlayerCount;
	BP_ShareResult_FamousId = BP_STRUCT_BattleResultData.famous_id;

	if BP_ShareResult_FamousId == nil or BP_ShareResult_FamousId == 0 then
		BP_ShareResult_FamousId = 1;
	end

	local msg = "";
	--单人结算和组队排名是两个字段,多人旁觀后先退出也只顯示單人
	if BP_ShareResult_TeamShowSingle then
		BP_PlayerRank = BP_STRUCT_BattleResultData.person_rank;
	else
		BP_PlayerRank = BP_STRUCT_BattleResultData.team_rank;
	end
	
	if BP_ShareResultTeamNum == 1 then
		msg = Client.GetTableData("LocalizeRes", "993001").TextValue;
	end

	if BP_ShareResultTeamNum == 2 then
		msg = Client.GetTableData("LocalizeRes", "993002").TextValue;
	end	

	if BP_ShareResultTeamNum == 4 then
		msg = Client.GetTableData("LocalizeRes", "993003").TextValue;
	end

	if BattleResultUI.IsDroiyanMode() then
		local ssMode = Client.GetTableData("LocalizeRes", "993005").TextValue;
		msg = ssMode .. msg;
	else
		local ssMode = Client.GetTableData("LocalizeRes", "993004").TextValue;
		msg = ssMode .. msg;
	end

	--取结算的战斗模式名称--
	BP_ModeKillInfo = BP_TeamModeName;
	ShareResultUI.ShowUI();
end


--分享成功的回调
local function OnResultsShareSucessEventHandler(eventType, eventID, vars)

	log("********result share call back *********");

	if eventType ~= EVENTTYPE_SHARE then
		return;
	end	

	local hasApp = DataMgr.HasInstallPlatApp();
	if hasApp ==  true then
		LuaClassObj.HandleUIMessage(bp_share_result, "UIHide");	
	end
	
	log("********result share success, hide share result ui *********");
	EventSystem:unregistEvent(EVENTTYPE_SHARE, EVENTID_SHARE_SUCESSFUL, OnResultsShareSucessEventHandler);
end

--显示UI 
--参数依次为116001 116002
function ShareResultUI.ShowUI()
	LuaClassObj.HandleDynamicCreation(bp_share_result);
	BP_LoginChannel = Client.GetLoginChannel(NetInterface);
	LuaClassObj.HandleUIMessage(bp_share_result, "UIShow");	

	if BP_SHARE_RESULT_TYPE == 2 then
		ShareUI:SetShareInfo(5);
	else
		ShareUI:SetShareInfo(4);
	end

	log("----share results ----");

	EventSystem:registEvent(EVENTTYPE_SHARE, EVENTID_SHARE_SUCESSFUL, OnResultsShareSucessEventHandler);

end


--关闭UI
function ShareResultUI.HideUI()
	LuaClassObj.HandleUIMessage(bp_share_result, "UIHide");	
end

--保存本地
function EventShareResult_BtnSave()
	LuaClassObj.HandleUIMessage(bp_share_result, "SaveLocalImage");	
end

--名次分享
local  function ShareReqRankResult(channel_type)
	ShareMgr.ShareSuccReq(4, channel_type);
end

--战绩分享
local  function ShareReqBattleResult(channel_type)
	ShareMgr.ShareSuccReq(5, channel_type);
end  

--截图
function EventShareResult_BtnCaptureScreen()
	
end

function EventShareResultPanelClosed()
	BattleResultUI.EnableTickSwitch();
end


function EventShareResultVariable_Push()
	-- body
	log(BP_ShareImagePath);
end

--分享facebook 复用QQ
function EventShareResultClickFacebookBtn()	
	log("[HHF]EventShareResultClickFacebookBtn");
	if Client.IsInstallQQ(NetInterface) == false then 
		--你还没有安装Facebook，无法使用此功能
		DataMgr.ShowNoticeByID(4005);
		return;
	end
		
	ShareMgr:shareQQWithPhoto(MEDIA_TAG_SHARE_RESULT, "", BP_ShareImagePath, ShareType.Moment);
	
	ClientSendBAReport(BP_BA_SHARE_WX_ZONE_COUNT, 0);
	ClientSendBAReport(BP_BA_SHARE_SHAREBTN, 0);
	
	if BP_SHARE_RESULT_TYPE == 2 then
		ClientSendBAReport(BP_BA_SHARE_GRADE, 0);
		ShareReqBattleResult(BP_BA_SHARE_TWITTER);		
	elseif BP_SHARE_RESULT_TYPE == 1 then
		ShareReqRankResult(BP_BA_SHARE_TWITTER);
	end
	
end

--分享twitter
function EventShareResultClickTwitterBtn()	
	log("[HHF]EventShareResultClickTwitterBtn");
	if Client.IsInstallTwitter(NetInterface) == false then 
		--你还没有安装twitter，无法使用此功能
		--DataMgr.ShowNoticeByID(4062);
		--return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_RESULT, BP_ShareImagePath, "", "", BP_ENUM_PLAYFORM_TWITTER);
	
	ClientSendBAReport(BP_BA_SHARE_WX_ZONE_COUNT, 0);
	ClientSendBAReport(BP_BA_SHARE_SHAREBTN, 0);
	
	if BP_SHARE_RESULT_TYPE == 2 then
		ClientSendBAReport(BP_BA_SHARE_GRADE, 0);
		ShareReqBattleResult(BP_BA_SHARE_TWITTER);		
	elseif BP_SHARE_RESULT_TYPE == 1 then
		ShareReqRankResult(BP_BA_SHARE_TWITTER);
	end
end

--分享微信朋友圈
function EventShareResultClickWXZoneBtn()	
	log("[HHF]EventShareResultClickWXZoneBtn");
	if Client.IsInstallWX(NetInterface) == false then 
		--你还没有安装微信，无法使用此功能
		DataMgr.ShowNoticeByID(110126);
		return;
	end

	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_RESULT, BP_ShareImagePath, "", "", BP_ENUM_PLAYFORM_WX);

	ClientSendBAReport(BP_BA_SHARE_WX_ZONE_COUNT, 0);
	ClientSendBAReport(BP_BA_SHARE_SHAREBTN, 0);

	if BP_SHARE_RESULT_TYPE == 2 then
		ClientSendBAReport(BP_BA_SHARE_GRADE, 0);
		ShareReqBattleResult();		
	elseif BP_SHARE_RESULT_TYPE == 1 then
		ShareReqRankResult();
	end
end

--分享VK
function EventShareResultClickVKBtn()	
	log("[HHF]EventShareResultClickVKBtn");
	if Client.IsInstallVK(NetInterface) == false then 
		--你还没有安装VK，无法使用此功能
		DataMgr.ShowNoticeByID(4310);
		return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_RESULT, BP_ShareImagePath, "", "", BP_ENUM_PLAYFORM_VK);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_VK_COUNT, 0);
	ShareReqRankResult(BP_BA_SHARE_VK);
end

--分享Line
function EventShareResultClickLineBtn()	
	log("[HHF]EventShareResultClickLineBtn");
	if Client.IsInstallLine(NetInterface) == false then 
		--你还没有安装Line，无法使用此功能
		DataMgr.ShowNoticeByID(4985);
		return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_RESULT, BP_ShareImagePath, "", "", BP_ENUM_PLAYFORM_LINE);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_LINE_COUNT, 0);
	ShareReqRankResult(BP_BA_SHARE_LINE);
end

--分享QQ
function EventShareResultClickQQByiTOPBtn()	
	log("EventShareResultClickQQByiTOPBtn");
	if Client.IsInstallQQByiTOP(NetInterface) == false then 
		--你还没有安装QQ，无法使用此功能
		DataMgr.ShowNoticeByID(110125);
		return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_RESULT, BP_ShareImagePath, "", "", BP_ENUM_PLAYFORM_QQByiTOP);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_QQByiTOP_COUNT, 0);
	ShareReqRankResult(BP_BA_SHARE_QQByiTOP);
end

