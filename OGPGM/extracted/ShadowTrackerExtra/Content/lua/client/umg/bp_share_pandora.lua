--潘多拉分享
PandoraShareUI = PandoraShareUI or {
	Share_Reason = "",
	Share_SendFlag = "",
}

BP_SharePandora_ShareImg = "";

function bp_share_pandora_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_share_pandora,
		{
			{Path="/Game/UMG/UI_Logic/Share/Share_PandoraLogicBP.Share_PandoraLogicBP_C", Container="Top", ZOrder=BP_ENUM_UI_SHARE_PANDORA_ZORDER},
		},
		{"Lobby"},
		false,
		false,
		true
	);
end

local function OnShareSucessEventHandler(eventType, eventID, vars)

	if eventType ~= EVENTTYPE_SHARE then
		return;
	end	

	local hasApp = DataMgr.HasInstallPlatApp();
	if hasApp ==  true then
		LuaClassObj.HandleUIMessage(bp_share_pandora, "UIHide");	
	end
	
	EventSystem:unregistEvent(EVENTTYPE_SHARE, EVENTID_SHARE_SUCESSFUL, OnShareSucessEventHandler);
end

--显示UI 
function PandoraShareUI.ShowUI(data)
    log("PandoraShareUI.ShowUI")
    if data == nil or data.imagePath == nil or data.imagePath == "" then
        log("PandoraShareUI.ShowUI imagepath empty.")
        return;
	end
	
	PandoraShareUI.Share_Reason = data.content;
	PandoraShareUI.Share_SendFlag = data.isSend;

	LuaClassObj.HandleDynamicCreation(bp_share_pandora);
	ShareUI:SetShareInfo(30);
	EventSystem:registEvent(EVENTTYPE_SHARE, EVENTID_SHARE_SUCESSFUL, OnShareSucessEventHandler);

	log("PandoraShareUI img="..data.imagePath);
	BP_SharePandora_ShareImg = data.imagePath;

	LuaClassObj.HandleUIMessage(bp_share_pandora, "UIShow");	
	--ClientSendBAReport(BP_BA_SHARE_MAINPANEL, 0);
end

function PandoraShareUI.ShareOk()
	if PandoraShareUI.Share_SendFlag == "1" then
		local jsonStr = "{\"type\":\"SendGolds\",\"content\":\""..PandoraShareUI.Share_Reason.."\"}";
		--log("PandoraShareUI.ShareOk "..jsonStr);
		PandoraSystem.SendCmd(jsonStr);
	end
	--PandoraShareUI.Share_Reason = "";
end


--分享facebook 复用QQ
function EventPandoraShareClickFacebookBtn()	
	log("[HHF]EventPandoraShareClickFacebookBtn");
	if Client.IsInstallQQ(NetInterface) == false then 
		--你还没有安装Facebook，无法使用此功能
		DataMgr.ShowNoticeByID(4005);
		return;
	end
		
	ShareMgr:shareQQWithPhoto(MEDIA_TAG_SHARE_CHIJI, PandoraShareUI.Share_Reason, BP_SharePandora_ShareImg, ShareType.Moment);
	ClientSendBAReport(BP_BA_SHARE_QQSPACE, 0);
	PandoraShareUI.ShareReq(BP_BA_SHARE_FACEBOOK);
	PandoraShareUI.ShareOk();
end

--分享twitter
function EventPandoraShareClickTwitterBtn()	
	log("[HHF]EventPandoraShareClickTwitterBtn");
	if Client.IsInstallTwitter(NetInterface) == false then 
		--你还没有安装twitter，无法使用此功能
		--DataMgr.ShowNoticeByID(4062);
		--return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_SharePandora_ShareImg, PandoraShareUI.Share_Reason, "", BP_ENUM_PLAYFORM_TWITTER);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_TW_COUNT, 0);
	PandoraShareUI.ShareReq(BP_BA_SHARE_TWITTER);
	PandoraShareUI.ShareOk();
end

--分享微信朋友圈
function EventPandoraShareClickWXZoneBtn()	
	log("[HHF]EventPandoraShareClickWXZoneBtn");
	if Client.IsInstallWX(NetInterface) == false then 
		--你还没有安装微信，无法使用此功能
		DataMgr.ShowNoticeByID(110126);
		return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_SharePandora_ShareImg, PandoraShareUI.Share_Reason, "", BP_ENUM_PLAYFORM_WX);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_WX_ZONE_COUNT, 0);
	PandoraShareUI.ShareReq(BP_BA_SHARE_WX_ZONE);
	PandoraShareUI.ShareOk();
end

--分享VK
function EventPandoraShareClickVKBtn()	
	log("[HHF]EventPandoraShareClickVKBtn");
	if Client.IsInstallVK(NetInterface) == false then 
		--你还没有安装VK，无法使用此功能
		DataMgr.ShowNoticeByID(4310);
		return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_SharePandora_ShareImg, PandoraShareUI.Share_Reason, "", BP_ENUM_PLAYFORM_VK);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_VK_COUNT, 0);
	PandoraShareUI.ShareReq(BP_BA_SHARE_VK);
	PandoraShareUI.ShareOk();
end

--分享Line
function EventPandoraShareClickLineBtn()	
	log("[HHF]EventPandoraShareClickLineBtn");
	if Client.IsInstallLine(NetInterface) == false then 
		--你还没有安装Line，无法使用此功能
		DataMgr.ShowNoticeByID(4985);
		return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_SharePandora_ShareImg, PandoraShareUI.Share_Reason, "", BP_ENUM_PLAYFORM_LINE);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_LINE_COUNT, 0);
	PandoraShareUI.ShareReq(BP_BA_SHARE_LINE);
	PandoraShareUI.ShareOk();
end

--分享QQ
function EventPandoraShareClickQQByiTOPBtn()	
	log("EventPandoraShareClickQQByiTOPBtn");
	if Client.IsInstallQQByiTOP(NetInterface) == false then 
		--你还没有安装QQ，无法使用此功能
		DataMgr.ShowNoticeByID(110125);
		return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_SharePandora_ShareImg, PandoraShareUI.Share_Reason, "", BP_ENUM_PLAYFORM_QQByiTOP);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_QQByiTOP_COUNT, 0);
	PandoraShareUI.ShareReq(BP_BA_SHARE_QQByiTOP);
	PandoraShareUI.ShareOk();
end

function PandoraShareUI.ShareReq(channel_type)
  ShareMgr.ShareSuccReq(16, channel_type);
end

function EventPandoraSetInfo_Push()
end

function EventPandoraFetchInfo()
end