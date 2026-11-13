LeagueGameShareAdvanceUI = LeagueGameShareAdvanceUI or {
  
}

BP_LeagueGameShareAdvancePath = "";
BP_LeagueGameShareAdvanceStageId = 0;

BP_LeagueGameShareAdvanceGetTime = "";
BP_LeagueGameShareAdvanceName = "";
BP_LeagueGameShareAdvanceIconId = 0;

BP_STRUCT_LeagueGameShareAdvanceMemberInfo = {
  Uid = "",
  IconUrl = "",
  nickName = "",
  IconFrameID = 0,
}

BP_ARRAY_LeagueGameShareAdvanceMemberList = {
  BP_STRUCT_LeagueGameShareAdvanceMemberInfo = _G.BP_STRUCT_LeagueGameShareAdvanceMemberInfo;
}

function bp_leagueGame_shareAdvance_RegisterUI()
  LuaClassObj.SubUIWidgetList(bp_leagueGame_shareAdvance,
    {{Path="/Game/UMG/UI_Logic/Share/Share_LeagueGame_Advance_BP.Share_LeagueGame_Advance_BP_C", Container="Top", ZOrder = BP_ENUM_UI_LEAGUEGAME_LOBBY}},
    {"Lobby"},
    false,
    false,
    true
  );
end


local  function ShareReqPerson(channel_type)
  ShareMgr.ShareSuccReq(14, channel_type);
end

local function OnShareSucessEventHandler(eventType, eventID, vars)

  if eventType ~= EVENTTYPE_SHARE then
    return;
  end

  local hasApp = DataMgr.HasInstallPlatApp();
  if hasApp ==  true then
    LuaClassObj.HandleUIMessage(bp_leagueGame_shareAdvance, "UIHide");
  end

  EventSystem:unregistEvent(EVENTTYPE_SHARE, EVENTID_SHARE_SUCESSFUL, OnShareSucessEventHandler);
end


function LeagueGameShareAdvanceUI.Init(stageID)
  BP_LeagueGameShareAdvanceStageId = stageID;
  LeagueGameShareAdvanceUI.SetData();
  LeagueGameShareAdvanceUI.Show();
end

function LeagueGameShareAdvanceUI.Release()
 
end

function LeagueGameShareAdvanceUI.SetData()
  if BP_STRUCT_AllianceInfo then
    BP_LeagueGameShareAdvanceName = BP_STRUCT_AllianceInfo.name;
    BP_LeagueGameShareAdvanceIconId = BP_STRUCT_AllianceInfo.iconId;
  end
  if not BP_LeagueGameShareAdvanceIconId or BP_LeagueGameShareAdvanceIconId <= 0 then
    BP_LeagueGameShareAdvanceIconId = 1;
  end
  local serverTime = tostring(FuncUtil.SecToDateString(FuncUtil.GetServerTimeInSec()));
  BP_LeagueGameShareAdvanceGetTime = string.format(Client.GetTableData("LocalizeRes", "6363").TextValue, serverTime);
  local memberList = {};
  if AllianceSystem.TeamMemberList then
    for k, v in pairs(AllianceSystem.TeamMemberList) do
      table.insert(memberList, k);
    end
  end
  --log_tree(" LeagueGameShareAdvanceUI.SetData", AllianceSystem.TeamMemberList);
  --log_tree("BP_ARRAY_LeagueGameShareAdvanceMemberList", memberList);
  LeagueGameShareAdvanceUI.GetMemberProfile(memberList);
end

function LeagueGameShareAdvanceUI.Show()
  LuaClassObj.HandleDynamicCreation(bp_leagueGame_shareAdvance);
  LuaClassObj.HandleUIMessage(bp_leagueGame_shareAdvance, "UIShow");
end

function LeagueGameShareAdvanceUI.Hide()
  LuaClassObj.HandleUIMessageNoFetch(bp_leagueGame_shareAdvance, "UIHide");
  EventSystem:unregistEvent(EVENTTYPE_SHARE, EVENTID_SHARE_SUCESSFUL, OnShareSucessEventHandler);
end

function LeagueGameShareAdvanceUI.GetMemberProfile(idList)
  BP_ARRAY_LeagueGameShareAdvanceMemberList = {};
  local function callback(profileList)
    for _,profileInfo in ipairs(profileList) do
      local info = {}
      info.Uid = profileInfo.uid;
      info.nickName = profileInfo.nickName;
      info.IconUrl = profileInfo.picUrl;
      info.IconFrameID = profileInfo.cur_avatar_box_id;
      --info.lastOnlineTime = profileInfo.lastOnlineTime;
      --info.lastOnlineTimeStr = FuncUtil.FormatTime(profileInfo.lastOnlineTime, "online");
      --info.nation = profileInfo.nation;
      table.insert(BP_ARRAY_LeagueGameShareAdvanceMemberList, info);
      log_tree("===============BP_ARRAY_LeagueGameShareAdvanceMemberList ", BP_ARRAY_LeagueGameShareAdvanceMemberList)
      LuaClassObj.HandleUIMessage(bp_leagueGame_shareAdvance, "ShowMemberInfo");
    end
  end
  ProfileMgr.GetProfileList(idList, callback, false, false, false, true);
end

--关闭
function EventLeagueGameShareAdvanceHideUI()
  LeagueGameShareAdvanceUI.Hide();
end

--分享facebook 复用QQ
function EventLeagueGameShareAdvanceClickFacebookBtn()
  log("[HHF]EventPersonShareClickFacebookBtn");
  if Client.IsInstallQQ(NetInterface) == false then
    --你还没有安装Facebook，无法使用此功能
    DataMgr.ShowNoticeByID(4005);
    return;
  end

  ShareMgr:shareQQWithPhoto(MEDIA_TAG_SHARE_CHIJI, "", BP_LeagueGameShareAdvancePath, ShareType.Moment);
  ClientSendBAReport(BP_BA_SHARE_QQSPACE, BP_BA_SHARE_LEAGUEGAME_REASON);
  ShareReqPerson(BP_BA_SHARE_FACEBOOK);
end

--分享twitter
function EventLeagueGameShareAdvanceClickTwitterBtn()
  log("[HHF]EventPersonShareClickTwitterBtn");
  if Client.IsInstallTwitter(NetInterface) == false then
    --你还没有安装twitter，无法使用此功能
    --DataMgr.ShowNoticeByID(4062);
    --return;
  end

  ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_LeagueGameShareAdvancePath, "", "", BP_ENUM_PLAYFORM_TWITTER);
  --上报给后台做统计
  ClientSendBAReport(BP_BA_SHARE_TW_COUNT, BP_BA_SHARE_LEAGUEGAME_REASON);
  ShareReqPerson(BP_BA_SHARE_TWITTER);
end

--分享微信朋友圈
function EventLeagueGameShareAdvanceClickWXZoneBtn()
  log("[HHF]EventPersonShareClickWXZoneBtn");
  if Client.IsInstallWX(NetInterface) == false then
    --你还没有安装微信，无法使用此功能
    DataMgr.ShowNoticeByID(110126);
    return;
  end

  --[[
  --个人战绩3
  if ShareMgr.CanShareByType(3) == false then
      return;
  end
  ShareMgr.SetShareLimit(3);
  --]]

  ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_LeagueGameShareAdvancePath, "", "", BP_ENUM_PLAYFORM_WX);
  --上报给后台做统计
  ClientSendBAReport(BP_BA_SHARE_WX_ZONE_COUNT, BP_BA_SHARE_LEAGUEGAME_REASON);
  ShareReqPerson(BP_BA_SHARE_WX_ZONE);
end

--分享VK
function EventLeagueGameShareAdvanceClickVKBtn()
  log("[HHF]EventPersonShareClickVKBtn");
  if Client.IsInstallVK(NetInterface) == false then
    --你还没有安装VK，无法使用此功能
    DataMgr.ShowNoticeByID(4310);
    return;
  end

  ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_LeagueGameShareAdvancePath, "", "", BP_ENUM_PLAYFORM_VK);
  --上报给后台做统计
  ClientSendBAReport(BP_BA_SHARE_VK_COUNT, BP_BA_SHARE_LEAGUEGAME_REASON);
  ShareReqPerson(BP_BA_SHARE_VK);
end

--分享Line
function EventLeagueGameShareAdvanceClickLineBtn()
  log("[HHF]EventPersonShareClickLineBtn");
  if Client.IsInstallLine(NetInterface) == false then
    --你还没有安装Line，无法使用此功能
    DataMgr.ShowNoticeByID(4985);
    return;
  end

  ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_LeagueGameShareAdvancePath, "", "", BP_ENUM_PLAYFORM_LINE);
  --上报给后台做统计
  ClientSendBAReport(BP_BA_SHARE_LINE_COUNT, BP_BA_SHARE_LEAGUEGAME_REASON);
  ShareReqPerson(BP_BA_SHARE_LINE);
end

--分享QQ
function EventLeagueGameShareAdvanceClickQQByiTOPBtn()	
	log("EventLeagueGameShareAdvanceClickQQByiTOPBtn");
	if Client.IsInstallQQByiTOP(NetInterface) == false then 
		--你还没有安装QQ，无法使用此功能
		DataMgr.ShowNoticeByID(110125);
		return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_LeagueGameShareAdvancePath, "", "", BP_ENUM_PLAYFORM_QQByiTOP);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_QQByiTOP_COUNT, BP_BA_SHARE_LEAGUEGAME_REASON);
	ShareReqPerson(BP_BA_SHARE_QQByiTOP);
end

--分享More
function EventLeagueGameShareAdvanceClickMoreBtn()
  log("[HHF]EventPersonShareClickMoreBtn");

  ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_LeagueGameShareAdvancePath, "", "", BP_ENUM_PLAYFORM_MORE);
  --上报给后台做统计
  ClientSendBAReport(BP_BA_SHARE_MORE_COUNT, BP_BA_SHARE_LEAGUEGAME_REASON);
  ShareReqPerson(BP_BA_SHARE_MORE);
end