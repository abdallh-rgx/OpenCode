AllianceCompetitionShareUI = AllianceCompetitionShareUI or {}

BP_AllianceShareAdvancePath = ""
BP_AllianceShare_RankImgIndex = 0

BP_STRUCT_AllianceCompetitionShareInfo = {
    TeamName = "",
    TeamGuidon = "",
    ContentText = "",
    RankText = "",
    DateText = ""
}

function bp_alliance_competition_sharepage_RegisterUI()
    LuaClassObj.SubUIWidgetList(
        bp_alliance_competition_sharepage,
        {
            {
                Path = "/Game/UMG/UI_Logic/Share/Alliance_Competition_Share_LogicBP.Alliance_Competition_Share_LogicBP_C",
                Container = "Top",
                ZOrder = BP_ENUM_UI_LEAGUEGAME_LOBBY
            }
        },
        {"Lobby"},
        false,
        false,
        true
    )
end

local function ShareReqPerson(channel_type)
    ShareMgr.ShareSuccReq(14, channel_type)
end

local function OnShareSucessEventHandler(eventType, eventID, vars)
    if eventType ~= EVENTTYPE_SHARE then
        return
    end

    local hasApp = DataMgr.HasInstallPlatApp()
    if hasApp == true then
        LuaClassObj.HandleUIMessageNoFetch(bp_alliance_competition_sharepage, "UIHide")
    end

    EventSystem:unregistEvent(EVENTTYPE_SHARE, EVENTID_SHARE_SUCESSFUL, OnShareSucessEventHandler)
end

function AllianceCompetitionShareUI.Show()
    LuaClassObj.HandleDynamicCreation(bp_alliance_competition_sharepage)
    BP_STRUCT_AllianceCompetitionShareInfo.TeamName = BP_STRUCT_AllianceInfo.name
    BP_STRUCT_AllianceCompetitionShareInfo.TeamGuidon = AllianceCompetitionSystem.getGuidonUrl()
    BP_STRUCT_AllianceCompetitionShareInfo.ContentText = AllianceCompetitionSystem.getShareRankContentText()
    BP_STRUCT_AllianceCompetitionShareInfo.RankText = tostring(AllianceCompetitionSystem.MaxCompetitionRank)
    BP_STRUCT_AllianceCompetitionShareInfo.DateText = os.date("%Y.%m.%d", AllianceCompetitionSystem.MaxCompetitionObtainTime)

    -- log_tree("============",BP_STRUCT_AllianceCompetitionShareInfo,"AllianceCompetitionSystem")
    LuaClassObj.HandleUIMessageNoFetch(bp_alliance_competition_sharepage, "UIShow")

    if AllianceCompetitionSystem.MaxCompetitionStageId == AllianceCompetitionSystem.FirstStep.GROUP_MATCH then
        BP_AllianceShare_RankImgIndex = 2
    end

    if AllianceCompetitionSystem.MaxCompetitionStageId == AllianceCompetitionSystem.FirstStep.ZONE_FINAL_MATCH then
        if AllianceCompetitionSystem.MaxCompetitionRank == 1 then
            BP_AllianceShare_RankImgIndex = 0
        else
            BP_AllianceShare_RankImgIndex = 1
        end
    end
    LuaClassObj.HandleUIMessageNoFetch(bp_alliance_competition_sharepage, "UpdateRankImg")
end

function AllianceCompetitionShareUI.Hide()
    LuaClassObj.HandleUIMessageNoFetchNoFetch(bp_alliance_competition_sharepage, "UIHide")
    EventSystem:unregistEvent(EVENTTYPE_SHARE, EVENTID_SHARE_SUCESSFUL, OnShareSucessEventHandler)
end

--关闭
function EventAllianceCompetitionShareAdvanceHideUI()
    AllianceCompetitionShareUI.Hide()
end

--分享facebook 复用QQ
function EventAllianceCompetitionShareAdvanceClickFacebookBtn()
    log("[HHF]EventPersonShareClickFacebookBtn")
    if Client.IsInstallQQ(NetInterface) == false then
        --你还没有安装Facebook，无法使用此功能
        DataMgr.ShowNoticeByID(4005)
        return
    end

    ShareMgr:shareQQWithPhoto(MEDIA_TAG_SHARE_CHIJI, "", BP_AllianceShareAdvancePath, ShareType.Moment)
    ClientSendBAReport(BP_BA_SHARE_QQSPACE, 0)
    ShareReqPerson(BP_BA_SHARE_FACEBOOK)
end

--分享twitter
function EventAllianceCompetitionShareAdvanceClickTwitterBtn()
    log("[HHF]EventPersonShareClickTwitterBtn")
    if Client.IsInstallTwitter(NetInterface) == false then
    --你还没有安装twitter，无法使用此功能
    --DataMgr.ShowNoticeByID(4062);
    --return;
    end

    ShareMgr:shareWithPhotoByChannel(
        MEDIA_TAG_SHARE_CHIJI,
        BP_AllianceShareAdvancePath,
        "",
        "",
        BP_ENUM_PLAYFORM_TWITTER
    )
    --上报给后台做统计
    ClientSendBAReport(BP_BA_SHARE_TW_COUNT, 0)
    ShareReqPerson(BP_BA_SHARE_TWITTER)
end

--分享微信朋友圈
function EventAllianceCompetitionShareAdvanceClickWXZoneBtn()
    log("[HHF]EventPersonShareClickWXZoneBtn")
    if Client.IsInstallWX(NetInterface) == false then
        --你还没有安装微信，无法使用此功能
        DataMgr.ShowNoticeByID(110126)
        return
    end

    --[[
  --个人战绩3
  if ShareMgr.CanShareByType(3) == false then
      return;
  end
  ShareMgr.SetShareLimit(3);
  --]]
    ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_AllianceShareAdvancePath, "", "", BP_ENUM_PLAYFORM_WX)
    --上报给后台做统计
    ClientSendBAReport(BP_BA_SHARE_WX_ZONE_COUNT, 0)
    ShareReqPerson(BP_BA_SHARE_WX_ZONE)
end

--分享VK
function EventAllianceCompetitionShareAdvanceClickVKBtn()
    log("[HHF]EventPersonShareClickVKBtn")
    if Client.IsInstallVK(NetInterface) == false then
        --你还没有安装VK，无法使用此功能
        DataMgr.ShowNoticeByID(4310)
        return
    end

    ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_AllianceShareAdvancePath, "", "", BP_ENUM_PLAYFORM_VK)
    --上报给后台做统计
    ClientSendBAReport(BP_BA_SHARE_VK_COUNT, 0)
    ShareReqPerson(BP_BA_SHARE_VK)
end

--分享Line
function EventAllianceCompetitionShareAdvanceClickLineBtn()
    log("[HHF]EventPersonShareClickLineBtn")
    if Client.IsInstallLine(NetInterface) == false then
        --你还没有安装Line，无法使用此功能
        DataMgr.ShowNoticeByID(4985)
        return
    end

    ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_AllianceShareAdvancePath, "", "", BP_ENUM_PLAYFORM_LINE)
    --上报给后台做统计
    ClientSendBAReport(BP_BA_SHARE_LINE_COUNT, 0)
    ShareReqPerson(BP_BA_SHARE_LINE)
end

--分享More
function EventAllianceCompetitionShareAdvanceClickMoreBtn()
    log("[HHF]EventPersonShareClickMoreBtn")

    ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_AllianceShareAdvancePath, "", "", BP_ENUM_PLAYFORM_MORE)
    --上报给后台做统计
    ClientSendBAReport(BP_BA_SHARE_MORE_COUNT, 0)
    ShareReqPerson(BP_BA_SHARE_MORE)
end

--分享QQ
function EventAllianceCompetitionShareAdvanceClickQQByiTOPBtn()	
	log("EventAllianceCompetitionShareAdvanceClickQQByiTOPBtn");
	if Client.IsInstallQQByiTOP(NetInterface) == false then 
		--你还没有安装QQ，无法使用此功能
		DataMgr.ShowNoticeByID(110125);
		return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_AllianceShareAdvancePath, "", "", BP_ENUM_PLAYFORM_QQByiTOP);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_QQByiTOP_COUNT, 0);
	ShareReqPerson(BP_BA_SHARE_QQByiTOP);
end