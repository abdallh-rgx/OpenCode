LeagueGameShareLeagueInfoUI = LeagueGameShareLeagueInfoUI or {

}

BP_LeagueGameShareLeagueInfo = "";

BP_STRUCT_GameLeagueInfoShareTeamInfo = {
  rank = 0,
  name = "",
  score = 0,
  icon = 0,
  kill = 0,
}

BP_LeagueGameShareLeagueInfoGetTime = "";

function bp_leagueGame_shareLeagueInfo_RegisterUI()
  LuaClassObj.SubUIWidgetList(bp_leagueGame_shareLeagueInfo,
          {{Path="/Game/UMG/UI_Logic/Share/Share_LeagueGame_Info_BP.Share_LeagueGame_Info_BP_C", Container="Top", ZOrder = BP_ENUM_UI_LEAGUEGAME_LOBBY}},
          {"Lobby"},
          false,
          false,
          true
  );
end


local  function ShareReqPerson(channel_type)
  ShareMgr.ShareSuccReq(15, channel_type);
end

local function OnShareSucessEventHandler(eventType, eventID, vars)

  if eventType ~= EVENTTYPE_SHARE then
    return;
  end

  local hasApp = DataMgr.HasInstallPlatApp();
  if hasApp ==  true then
    LuaClassObj.HandleUIMessage(bp_leagueGame_shareLeagueInfo, "UIHide");
  end

  EventSystem:unregistEvent(EVENTTYPE_SHARE, EVENTID_SHARE_SUCESSFUL, OnShareSucessEventHandler);
end


function LeagueGameShareLeagueInfoUI.Init(name,icon,rank,score,kill)
  LeagueGameShareLeagueInfoUI.SetData(name,icon,rank,score,kill);
  LeagueGameShareLeagueInfoUI.Show();
end

function LeagueGameShareLeagueInfoUI.Release()

end

function LeagueGameShareLeagueInfoUI.SetData(name,icon,rank,score,kill)
  BP_STRUCT_GameLeagueInfoShareTeamInfo.name = name;
  BP_STRUCT_GameLeagueInfoShareTeamInfo.icon = icon;
  BP_STRUCT_GameLeagueInfoShareTeamInfo.rank = rank or 0;
  BP_STRUCT_GameLeagueInfoShareTeamInfo.score = score or 0;
  BP_STRUCT_GameLeagueInfoShareTeamInfo.kill = kill or 0;
  local serverTime = tostring(FuncUtil.SecToDateString(FuncUtil.GetServerTimeInSec()));
  BP_LeagueGameShareLeagueInfoGetTime = string.format(Client.GetTableData("LocalizeRes", "6363").TextValue, serverTime);
  if BP_STRUCT_GameLeagueInfoShareTeamInfo.rank < 0 then
    BP_STRUCT_GameLeagueInfoShareTeamInfo.rank = 0;
  end
end

function LeagueGameShareLeagueInfoUI.Show()
  LuaClassObj.HandleDynamicCreation(bp_leagueGame_shareLeagueInfo);
  LuaClassObj.HandleUIMessage(bp_leagueGame_shareLeagueInfo, "UIShow");
end

function LeagueGameShareLeagueInfoUI.Hide()
  LuaClassObj.HandleUIMessageNoFetch(bp_leagueGame_shareLeagueInfo, "UIHide");
  EventSystem:unregistEvent(EVENTTYPE_SHARE, EVENTID_SHARE_SUCESSFUL, OnShareSucessEventHandler);
end

--关闭
function EventLeagueGameShareLeagueInfoHideUI()
  LeagueGameShareLeagueInfoUI.Hide();
end

--分享facebook 复用QQ
function EventLeagueGameShareLeagueInfoClickFacebookBtn()
  log("[HHF]EventPersonShareClickFacebookBtn");
  if Client.IsInstallQQ(NetInterface) == false then
    --你还没有安装Facebook，无法使用此功能
    DataMgr.ShowNoticeByID(4005);
    return;
  end

  ShareMgr:shareQQWithPhoto(MEDIA_TAG_SHARE_CHIJI, "", BP_LeagueGameShareLeagueInfo, ShareType.Moment);
  ClientSendBAReport(BP_BA_SHARE_QQSPACE, BP_BA_SHARE_LEAGUEGAME_REASON);
  ShareReqPerson(BP_BA_SHARE_FACEBOOK);
end

--分享twitter
function EventLeagueGameShareLeagueInfoClickTwitterBtn()
  log("[HHF]EventPersonShareClickTwitterBtn");
  if Client.IsInstallTwitter(NetInterface) == false then
    --你还没有安装twitter，无法使用此功能
    --DataMgr.ShowNoticeByID(4062);
    --return;
  end

  ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_LeagueGameShareLeagueInfo, "", "", BP_ENUM_PLAYFORM_TWITTER);
  --上报给后台做统计
  ClientSendBAReport(BP_BA_SHARE_TW_COUNT, BP_BA_SHARE_LEAGUEGAME_REASON);
  ShareReqPerson(BP_BA_SHARE_TWITTER);
end

--分享微信朋友圈
function EventLeagueGameShareLeagueInfoClickWXZoneBtn()
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

  ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_LeagueGameShareLeagueInfo, "", "", BP_ENUM_PLAYFORM_WX);
  --上报给后台做统计
  ClientSendBAReport(BP_BA_SHARE_WX_ZONE_COUNT, BP_BA_SHARE_LEAGUEGAME_REASON);
  ShareReqPerson(BP_BA_SHARE_WX_ZONE);
end

--分享VK
function EventLeagueGameShareLeagueInfoClickVKBtn()
  log("[HHF]EventPersonShareClickVKBtn");
  if Client.IsInstallVK(NetInterface) == false then
    --你还没有安装VK，无法使用此功能
    DataMgr.ShowNoticeByID(4310);
    return;
  end

  ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_LeagueGameShareLeagueInfo, "", "", BP_ENUM_PLAYFORM_VK);
  --上报给后台做统计
  ClientSendBAReport(BP_BA_SHARE_VK_COUNT, BP_BA_SHARE_LEAGUEGAME_REASON);
  ShareReqPerson(BP_BA_SHARE_VK);
end

--分享Line
function EventLeagueGameShareLeagueInfoClickLineBtn()
  log("[HHF]EventPersonShareClickLineBtn");
  if Client.IsInstallLine(NetInterface) == false then
    --你还没有安装Line，无法使用此功能
    DataMgr.ShowNoticeByID(4985);
    return;
  end

  ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_LeagueGameShareLeagueInfo, "", "", BP_ENUM_PLAYFORM_LINE);
  --上报给后台做统计
  ClientSendBAReport(BP_BA_SHARE_LINE_COUNT, BP_BA_SHARE_LEAGUEGAME_REASON);
  ShareReqPerson(BP_BA_SHARE_LINE);
end

--分享QQ
function EventLeagueGameShareLeagueInfoClickQQByiTOPBtn()	
	log("EventLeagueGameShareLeagueInfoClickQQByiTOPBtn");
	if Client.IsInstallQQByiTOP(NetInterface) == false then 
		--你还没有安装QQ，无法使用此功能
		DataMgr.ShowNoticeByID(110125);
		return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_LeagueGameShareLeagueInfo, "", "", BP_ENUM_PLAYFORM_QQByiTOP);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_QQByiTOP_COUNT, BP_BA_SHARE_LEAGUEGAME_REASON);
	ShareReqPerson(BP_BA_SHARE_QQByiTOP);
end

--分享More
function EventLeagueGameShareLeagueInfoClickMoreBtn()
  log("[HHF]EventPersonShareClickMoreBtn");

  ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_LeagueGameShareLeagueInfo, "", "", BP_ENUM_PLAYFORM_MORE);
  --上报给后台做统计
  ClientSendBAReport(BP_BA_SHARE_MORE_COUNT, BP_BA_SHARE_LEAGUEGAME_REASON);
  ShareReqPerson(BP_BA_SHARE_MORE);
end