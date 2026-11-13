--[[
	每日分享 2017-12-16
--]]

ShareDayFinalyShareUI = ShareDayFinalyShareUI or {
	 
}

BP_ShareDayFinalyNick = ""; --人物昵称
BP_ShareDayFinalySologan = "绝地求生：刺激战场等你来战！";
BP_ShareDayFinalyPath = ""; --截图图片路径
BP_ShareDayFinalyUrl = ""; --人物头像


function bp_share_dayfinaly_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_share_dayfinaly,
		{
			{Path="/Game/UMG/UI_Logic/Share/Share_DayFinalyLogicBP.Share_DayFinalyLogicBP_C", Container="Default", ZOrder=BP_ENUM_UI_Share_Day_Fianly_ZORDER},
		},
		{"Lobby"},
		false,
		false,
		true
	);
	
	EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_SHARE, ShareDayFinalyShareUI.ShowUI);
end	

function EventShareDayFinaly_Push()
	--蓝图变量同步给lua
end

function EventShareDayFinalyFetchInfo()
	--lua变量同步蓝图
end

local function OnShareSucessEventHandler(eventType, eventID, vars)

	if eventType ~= EVENTTYPE_SHARE then
		return;
	end	

	local hasApp = DataMgr.HasInstallPlatApp();
	if hasApp ==  true then
		LuaClassObj.HandleUIMessage(bp_share_dayfinaly, "UIHide");	
	end
	
	EventSystem:unregistEvent(EVENTTYPE_SHARE, EVENTID_SHARE_SUCESSFUL, OnShareSucessEventHandler);
end


--显示UI 
function ShareDayFinalyShareUI.ShowUI()		
	LuaClassObj.HandleDynamicCreation(bp_share_dayfinaly);
	EventSystem:registEvent(EVENTTYPE_SHARE, EVENTID_SHARE_SUCESSFUL, OnShareSucessEventHandler);
	if DataMgr.roleData ~= nil then
		BP_ShareDayFinalyNick = DataMgr.roleData.nickName;
		BP_ShareDayFinalyUrl = DataMgr.roleData.headIconUrl;
	end

	LuaClassObj.HandleUIMessage(bp_share_dayfinaly, "UIShow");	
	ClientSendBAReport(BP_BA_SHARE_MAINPANEL, 0);
end

local  function ShareReqDay(channel_type)
	ShareMgr.ShareSuccReq(2, channel_type);
end 

--保存本地
function EventClickBtnSave()
	log("bp_share_dayfinaly clickSaveLoc");
	
end

--分享facebook 复用QQ
function EventDayShareClickFacebookBtn()	
	log("[HHF]EventDayShareClickFacebookBtn");
	if Client.IsInstallQQ(NetInterface) == false then 
		--你还没有安装Facebook，无法使用此功能
		DataMgr.ShowNoticeByID(4005);
		return;
	end
		
	ShareMgr:shareQQWithPhoto(MEDIA_TAG_SHARE_CHIJI, "", BP_ShareDayFinalyPath, ShareType.Moment);
	ClientSendBAReport(BP_BA_SHARE_QQSPACE, 0);
	ShareReqDay(BP_BA_SHARE_FACEBOOK);
end

--分享twitter
function EventDayShareClickTwitterBtn()	
	log("[HHF]EventDayShareClickTwitterBtn");
	if Client.IsInstallTwitter(NetInterface) == false then 
		--你还没有安装twitter，无法使用此功能
		--DataMgr.ShowNoticeByID(4062);
		--return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_ShareDayFinalyPath, "", "", BP_ENUM_PLAYFORM_TWITTER);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_TW_COUNT, 0);
	ShareReqDay(BP_BA_SHARE_TWITTER);
end

--分享微信朋友圈
function EventDayShareClickWXZoneBtn()	
	log("[HHF]EventDayShareClickWXZoneBtn");
	if Client.IsInstallWX(NetInterface) == false then 
		--你还没有安装微信，无法使用此功能
		DataMgr.ShowNoticeByID(110126);
		return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_ShareDayFinalyPath, "", "", BP_ENUM_PLAYFORM_WX);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_WX_ZONE_COUNT, 0);
	ShareReqDay(BP_BA_SHARE_WX_ZONE);
end

--分享VK
function EventDayShareClickVKBtn()	
	log("[HHF]EventDayShareClickVKBtn");
	if Client.IsInstallVK(NetInterface) == false then 
		--你还没有安装VK，无法使用此功能
		DataMgr.ShowNoticeByID(4310);
		return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_ShareDayFinalyPath, "", "", BP_ENUM_PLAYFORM_VK);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_VK_COUNT, 0);
	ShareReqDay(BP_BA_SHARE_VK);
end

--分享Line
function EventDayShareClickLineBtn()	
	log("[HHF]EventDayShareClickLineBtn");
	if Client.IsInstallLine(NetInterface) == false then 
		--你还没有安装Line，无法使用此功能
		DataMgr.ShowNoticeByID(4985);
		return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_ShareDayFinalyPath, "", "", BP_ENUM_PLAYFORM_LINE);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_LINE_COUNT, 0);
	ShareReqDay(BP_BA_SHARE_LINE);
end

--分享QQ
function EventDayShareClickQQByiTOPBtn()	
	log("EventDayShareClickQQByiTOPBtn");
	if Client.IsInstallQQByiTOP(NetInterface) == false then 
		--你还没有安装QQ，无法使用此功能
		DataMgr.ShowNoticeByID(110125);
		return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_ShareDayFinalyPath, "", "", BP_ENUM_PLAYFORM_QQByiTOP);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_QQByiTOP_COUNT, 0);
	ShareReqDay(BP_BA_SHARE_QQByiTOP);
end


