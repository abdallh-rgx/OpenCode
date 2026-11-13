--[[	
    刺激盛宴分享 nanneli
--]]
ShareExcitingPartyUI = ShareExcitingPartyUI or {
	
}

BP_ShareExcitingPartyPath = ""

--分享的的数据
BP_STRUCT_ShareExcitingPartyInfo =
{
	shareIndex = 0, 
	shareNum = ""
}

-- 这个分享UI,zorder要比跑马灯高
function bp_share_exciting_party_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_share_exciting_party,
	{		
		{Path = "/Game/UMG/UI_Logic/Share/Share_ExcitingPartyBP.Share_ExcitingPartyBP_C", Container = "Default", ZOrder = BP_ENUM_UI_SCROLLMSG_ZORDER + 5},
	},
	{"Lobby"},
	false,
	false
	);
end	

local function OnShareSucessEventHandler(eventType, eventID, vars)
	
	if eventType ~= EVENTTYPE_SHARE then
		return;
	end	
	
	EventExcitingPartyHideUI()	
    
    -- if eventType == EVENTTYPE_SHARE and eventID == EVENTID_SHARE_SUCESSFUL then
	-- 	if vars and vars[1] == 1 and vars[2] == MEDIA_TAG_SHARE_EXCITING_PARTY then
	-- 		log("ShareExcitingPartyUI.OnShareSucessEventHandler   success")
	-- 		UIExcitingParty.SendGetAward()
	-- 	end
	-- end
end



--显示UI 
function ShareExcitingPartyUI.ShowUI(awardInfo)
	EventSystem:registEvent(EVENTTYPE_SHARE, EVENTID_SHARE_SUCESSFUL, OnShareSucessEventHandler);
	
	BP_STRUCT_ShareExcitingPartyInfo.shareIndex = awardInfo.itemIdx  
	BP_STRUCT_ShareExcitingPartyInfo.shareNum = awardInfo.shareNum 

	LuaClassObj.HandleUIMessage(bp_share_exciting_party, "UIShow")
	LuaClassObj.HandleUIMessage(bp_share_exciting_party, "UpdateContent")
	-- ClientSendBAReport(BP_BA_SHARE_MAINPANEL, 0);
end



--关闭UI
function EventExcitingPartyHideUI()
    log("EventExcitingPartyHideUI")
    EventSystem:unregistEvent(EVENTTYPE_SHARE, EVENTID_SHARE_SUCESSFUL, OnShareSucessEventHandler) 

    local hasApp = DataMgr.HasInstallPlatApp();
	if hasApp ==  true then
		LuaClassObj.HandleUIMessage(bp_share_exciting_party, "UIHide");	
	end
	
end


function EventShareExcitingParty_Push()
	--蓝图变量同步给lua
end

function EventShareExcitingPartyFetchInfo()
	--lua变量同步蓝图
end

local function ShareReqExcitingParty(channel_type)
	ShareMgr.ShareSuccReq(8, channel_type)
end 

--分享facebook 复用QQ
function EventExcitingPartyShareClickFacebookBtn()	
	log("[HHF]EventExcitingPartyShareClickFacebookBtn");
	if Client.IsInstallQQ(NetInterface) == false then 
		--你还没有安装Facebook，无法使用此功能
		DataMgr.ShowNoticeByID(4005);
		return;
	end
		
	ShareMgr:shareQQWithPhoto(MEDIA_TAG_SHARE_CHIJI, "", BP_ShareExcitingPartyPath, ShareType.Moment);
	ClientSendBAReport(BP_BA_SHARE_QQSPACE, 0);
	ShareReqExcitingParty(BP_BA_SHARE_FACEBOOK);
end

--分享twitter
function EventExcitingPartyShareClickTwitterBtn()	
	log("[HHF]EventExcitingPartyShareClickTwitterBtn");
	if Client.IsInstallTwitter(NetInterface) == false then 
		--你还没有安装twitter，无法使用此功能
		--DataMgr.ShowNoticeByID(4062);
		--return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_ShareExcitingPartyPath, "", "", BP_ENUM_PLAYFORM_TWITTER);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_TW_COUNT, 0);
	ShareReqExcitingParty(BP_BA_SHARE_TWITTER);
end

--分享微信朋友圈
function EventExcitingPartyShareClickWXZoneBtn()	
	log("[HHF]EventExcitingPartyShareClickWXZoneBtn");
	if Client.IsInstallWX(NetInterface) == false then 
		--你还没有安装微信，无法使用此功能
		DataMgr.ShowNoticeByID(110126);
		return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_ShareExcitingPartyPath, "", "", BP_ENUM_PLAYFORM_WX);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_WX_ZONE_COUNT, 0);
	ShareReqExcitingParty(BP_BA_SHARE_WX_ZONE);
end

--分享VK
function EventExcitingPartyShareClickVKBtn()	
	log("[HHF]EventExcitingPartyShareClickVKBtn");
	if Client.IsInstallVK(NetInterface) == false then 
		--你还没有安装VK，无法使用此功能
		DataMgr.ShowNoticeByID(4310);
		return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_ShareExcitingPartyPath, "", "", BP_ENUM_PLAYFORM_VK);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_VK_COUNT, 0);
	ShareReqExcitingParty(BP_BA_SHARE_VK);
end

--分享Line
function EventExcitingPartyShareClickLineBtn()	
	log("[HHF]EventExcitingPartyShareClickLineBtn");
	if Client.IsInstallLine(NetInterface) == false then 
		--你还没有安装Line，无法使用此功能
		DataMgr.ShowNoticeByID(4985);
		return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_ShareExcitingPartyPath, "", "", BP_ENUM_PLAYFORM_LINE);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_LINE_COUNT, 0);
	ShareReqExcitingParty(BP_BA_SHARE_LINE);
end

--分享QQ
function EventExcitingPartyShareClickQQByiTOPBtn()	
	log("EventExcitingPartyShareClickQQByiTOPBtn");
	if Client.IsInstallQQByiTOP(NetInterface) == false then 
		--你还没有安装QQ，无法使用此功能
		DataMgr.ShowNoticeByID(110125);
		return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_ShareExcitingPartyPath, "", "", BP_ENUM_PLAYFORM_QQByiTOP);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_QQByiTOP_COUNT, 0);
	ShareReqExcitingParty(BP_BA_SHARE_QQByiTOP);
end

