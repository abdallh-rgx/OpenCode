--段位分享UI
ShareRankUI = ShareRankUI or
{

}

BP_STRUCT_ShareRank_ShareInfo = 
{
	rankName = "",
	rankPointStr = "",
	rankLevel = 0,
	rankTypeName = "",
};

--图片分享保存的路径
BP_ShareRank_ImagePath = "";

function bp_share_rank_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_share_rank,
		{		
			{Path="/Game/UMG/UI_Logic/Share/Share_Rank_BP.Share_Rank_BP_C", Container="Top", ZOrder=BP_ENUM_UI_SHARE_RANK_ZORDER},
		},
		{"Lobby","Fighting"},
		false,
		false,
		true
	);
end

local function ShareReq(channel_type)
	ShareMgr.ShareSuccReq(6, channel_type);
end 

local function OnShareSucessEventHandler(eventType, eventID, vars)

    local hasApp = DataMgr.HasInstallPlatApp();
	if hasApp ==  true then
		LuaClassObj.HandleUIMessage(bp_share_rank, "UIHide");	
	end
	
end

function ShareRankUI:ShowSharePanel()
	LuaClassObj.HandleDynamicCreation(bp_share_rank);
	ShareUI:SetShareInfo(7);
	BP_STRUCT_ShareRank_ShareInfo = {};
	BP_STRUCT_ShareRank_ShareInfo.rankName = BP_LevelUp_NewRankName;
	BP_STRUCT_ShareRank_ShareInfo.rankPointStr = string.format("%d分", math.floor(BP_LevelUp_NewRankPoint));
	BP_STRUCT_ShareRank_ShareInfo.rankLevel = BP_LevelUp_NewRankLevel;
	BP_STRUCT_ShareRank_ShareInfo.rankTypeName = BP_LevelUp_RankTypeName;
	EventSystem:registEvent(EVENTTYPE_SHARE, EVENTID_SHARE_SUCESSFUL, OnShareSucessEventHandler);
	LuaClassObj.HandleUIMessage(bp_share_rank, "UIShow");
end

--保存本地/相册
function EventItemShareClickSaveLocalBtn()
	
end


--分享facebook 复用QQ
function EventRankShareClickFacebookBtn()	
	log("[HHF]EventRankShareClickFacebookBtn");
	if Client.IsInstallQQ(NetInterface) == false then 
		--你还没有安装Facebook，无法使用此功能
		DataMgr.ShowNoticeByID(4005);
		return;
	end
		
	ShareMgr:shareQQWithPhoto(MEDIA_TAG_SHARE_CHIJI, "", BP_ShareRank_ImagePath, ShareType.Moment);
	ClientSendBAReport(BP_BA_SHARE_QQSPACE, 0);
	ShareReq(BP_BA_SHARE_FACEBOOK);
end

--分享twitter
function EventRankShareClickTwitterBtn()	
	log("[HHF]EventRankShareClickTwitterBtn");
	if Client.IsInstallTwitter(NetInterface) == false then 
		--你还没有安装twitter，无法使用此功能
		--DataMgr.ShowNoticeByID(4062);
		--return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_ShareRank_ImagePath, "", "", BP_ENUM_PLAYFORM_TWITTER);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_TW_COUNT, 0);
	ShareReq(BP_BA_SHARE_TWITTER);
end

--分享微信朋友圈
function EventRankShareClickWXZoneBtn()	
	log("[HHF]EventRankShareClickWXZoneBtn");
	if Client.IsInstallWX(NetInterface) == false then 
		--你还没有安装微信，无法使用此功能
		DataMgr.ShowNoticeByID(110126);
		return;
	end
		
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_ShareRank_ImagePath, "", "", BP_ENUM_PLAYFORM_WX);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_WX_ZONE_COUNT, 0);
	ShareReq(BP_BA_SHARE_WX_ZONE);
end

--分享VK
function EventRankShareClickVKBtn()	
	log("[HHF]EventRankShareClickVKBtn");
	if Client.IsInstallVK(NetInterface) == false then 
		--你还没有安装VK，无法使用此功能
		DataMgr.ShowNoticeByID(4310);
		return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_ShareRank_ImagePath, "", "", BP_ENUM_PLAYFORM_VK);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_VK_COUNT, 0);
	ShareReq(BP_BA_SHARE_VK);
end

--分享Line
function EventRankShareClickLineBtn()	
	log("[HHF]EventRankShareClickLineBtn");
	if Client.IsInstallLine(NetInterface) == false then 
		--你还没有安装Line，无法使用此功能
		DataMgr.ShowNoticeByID(4985);
		return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_ShareRank_ImagePath, "", "", BP_ENUM_PLAYFORM_LINE);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_LINE_COUNT, 0);
	ShareReq(BP_BA_SHARE_LINE);
end

--分享QQ
function EventRankShareClickQQByiTOPBtn()	
	log("EventRankShareClickQQByiTOPBtn");
	if Client.IsInstallQQByiTOP(NetInterface) == false then 
		--你还没有安装QQ，无法使用此功能
		DataMgr.ShowNoticeByID(110125);
		return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_ShareRank_ImagePath, "", "", BP_ENUM_PLAYFORM_QQByiTOP);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_QQByiTOP_COUNT, 0);
	ShareReq(BP_BA_SHARE_QQByiTOP);
end

function EventShareRankHide()
	EventSystem:unregistEvent(EVENTTYPE_SHARE, EVENTID_SHARE_SUCESSFUL, OnShareSucessEventHandler);
end

function EventSetInfo_Push()
end

function EventFetchInfo()
end
