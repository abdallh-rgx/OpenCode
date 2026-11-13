-- 赛季结果分享
ShareSeasonResultUI = ShareSeasonResultUI or {
}

BP_ShareSeasonResultNick = ""; --人物昵称
BP_ShareSeasonResulPath = ""; --截图图片路径
BP_ShareSeasonResultUrl = ""; --人物头像
BP_ShareSeasonPathHTTPURL = ""; --图片的网络路径

FaceBookShareTempURL = "https://share.pubgameshowtime.com/showimage.php?image={image}&title={title}&descript=Tap+the+link+to+join+me+and+we%26apos%3Bll+win+together%21&gameid={gameid}"

function bp_share_seasonResult_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_share_seasonResult,
		{
			{Path="/Game/UMG/UI_Logic/Share/Share_SeasonResultLogicBP.Share_SeasonResultLogicBP_C", Container="Default", ZOrder=BP_ENUM_UI_Share_SeasonResult_ZORDER},
		},
		{"Lobby"},
		false,
		false,
		true
	);
	
	EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_SHARE, ShareSeasonResultUI.ShowUI);
end	

function EventShareSeasonResult_Push()
	--蓝图变量同步给lua
end

function EventShareSeasonResultFetchInfo()
	--lua变量同步蓝图
end

local function OnShareSucessEventHandler(eventType, eventID, vars)
	if eventType ~= EVENTTYPE_SHARE then
		return;
	end	

	local hasApp = DataMgr.HasInstallPlatApp();
	if hasApp ==  true then
		LuaClassObj.HandleUIMessage(bp_share_seasonResult, "UIHide");	
	end
	
	EventSystem:unregistEvent(EVENTTYPE_SHARE, EVENTID_SHARE_SUCESSFUL, OnShareSucessEventHandler);
end

--显示UI 
function ShareSeasonResultUI.ShowUI()
	if DataMgr.roleData ~= nil then
		BP_ShareSeasonResultNick = DataMgr.roleData.nickName;
		BP_ShareSeasonResultUrl = DataMgr.roleData.headIconUrl;
	end
	LuaClassObj.HandleDynamicCreation(bp_share_seasonResult);
	EventSystem:registEvent(EVENTTYPE_SHARE, EVENTID_SHARE_SUCESSFUL, OnShareSucessEventHandler);
	log("Qpp ShareMgr.ShareImageURL:"..ShareMgr.ShareImageURL)
	BP_ShareSeasonPathHTTPURL = ShareMgr.ShareImageURL
	log("qpp:BP_ShareSeasonPathHTTPURL".. BP_ShareSeasonPathHTTPURL);
	LuaClassObj.HandleUIMessage(bp_share_seasonResult, "UIShow");
end

local  function ShareReqDay(channel_type)
	ShareMgr.ShareSuccReq(2, channel_type);
end 

--保存本地
function EventClickBtnSave()
	log("bp_share_seasonResult clickSaveLoc");
end

--分享facebook 复用QQ
function EventSeasonResultShareClickFacebookBtn()	
	log("[HHF]EventSeasonResultShareClickFacebookBtn");
	if Client.IsInstallQQ(NetInterface) == false then 
		--你还没有安装Facebook，无法使用此功能
		DataMgr.ShowNoticeByID(4005);
		return;
	end
		
	--ShareMgr:shareQQWithPhoto(MEDIA_TAG_SHARE_CHIJI, "", BP_ShareSeasonResulPath, ShareType.Moment);
	local str = ShareMgr.ShareImageURL;
	local start = string.find(str, "upload");
	local last = string.find(str, ".jpeg");
	str = string.sub(str, start, last + 4);
	log("Qpp FacebookFullURL:"..str);
	local result = string.gsub(FaceBookShareTempURL, "{image}", str);
	local gameID = Client.GetITopGameId()
	result = string.gsub(result, "{gameid}", gameID)
	log("Qpp FacebookResultURL:"..result);
	ShareMgr:shareFacebookH5WithPhoto(ShareMgr.ShareH5Title, result, BP_ENUM_PLAYFORM_QQ)
	--ClientSendBAReport(BP_BA_SHARE_QQSPACE, 0);
	--ShareReqDay(BP_BA_SHARE_FACEBOOK);
end

--分享twitter
function EventSeasonResultShareClickTwitterBtn()	
	log("[HHF]EventSeasonResultShareClickTwitterBtn");
	if Client.IsInstallTwitter(NetInterface) == false then 
		--你还没有安装twitter，无法使用此功能
		DataMgr.ShowNoticeByID(4062);
		return;
	end
	local str = ShareMgr.ShareImageURL;
	local start = string.find(str, "upload");
	local last = string.find(str, ".jpeg");
	str = string.sub(str, start, last + 4);
	log("Qpp FacebookFullURL:"..str);
	local result = string.gsub(FaceBookShareTempURL, "{image}", str);
	local gameID = Client.GetITopGameId()
	result = string.gsub(result, "{gameid}", gameID)
	log("Qpp Twitter:"..result);
	ShareMgr:shareFacebookH5WithPhoto(ShareMgr.ShareH5Title, result, BP_ENUM_PLAYFORM_TWITTER)
	--上报给后台做统计
	--ClientSendBAReport(BP_BA_SHARE_TW_COUNT, 0);
	--ShareReqDay(BP_BA_SHARE_TWITTER);
end

--分享微信朋友圈
function EventSeasonResultShareClickWXZoneBtn()	
	log("[HHF]EventSeasonResultShareClickWXZoneBtn");
	if Client.IsInstallWX(NetInterface) == false then 
		--你还没有安装微信，无法使用此功能
		DataMgr.ShowNoticeByID(110126);
		return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_ShareSeasonResulPath, "", "", BP_ENUM_PLAYFORM_WX);
	--上报给后台做统计
	--ClientSendBAReport(BP_BA_SHARE_WX_ZONE_COUNT, 0);
	--ShareReqDay(BP_BA_SHARE_WX_ZONE);
end

--分享VK
function EventSeasonResultShareClickVKBtn()	
	log("[HHF]EventSeasonResultShareClickVKBtn");
	if Client.IsInstallVK(NetInterface) == false then 
		--你还没有安装VK，无法使用此功能
		DataMgr.ShowNoticeByID(4310);
		return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_ShareSeasonResulPath, "", "", BP_ENUM_PLAYFORM_VK);
	--上报给后台做统计
	--ClientSendBAReport(BP_BA_SHARE_VK_COUNT, 0);
	--ShareReqDay(BP_BA_SHARE_VK);
end

--分享Line
function EventSeasonResultShareClickLineBtn()	
	log("[HHF]EventSeasonResultShareClickLineBtn");
	if Client.IsInstallLine(NetInterface) == false then 
		--你还没有安装Line，无法使用此功能
		DataMgr.ShowNoticeByID(4985);
		return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_ShareSeasonResulPath, "", "", BP_ENUM_PLAYFORM_LINE);
	--上报给后台做统计
	--ClientSendBAReport(BP_BA_SHARE_LINE_COUNT, 0);
	--ShareReq(BP_BA_SHARE_LINE);
end

--分享QQ
function EventSeasonResultShareClickQQByiTOPBtn()	
	log("EventSeasonResultShareClickQQByiTOPBtn");
	if Client.IsInstallQQByiTOP(NetInterface) == false then 
		--你还没有安装QQ，无法使用此功能
		DataMgr.ShowNoticeByID(110125);
		return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_ShareSeasonResulPath, "", "", BP_ENUM_PLAYFORM_QQByiTOP);
	--上报给后台做统计
	--ClientSendBAReport(BP_BA_SHARE_QQByiTOP_COUNT, 0);
	--ShareReq(BP_BA_SHARE_QQByiTOP);
end