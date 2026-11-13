--军衔分享UI
ShareLevelUpUI = ShareLevelUpUI or
{

}

BP_STRUCT_ShareLevelUp_ShareInfo = 
{
	levelUpName = "",
	levelUpBgPath = "",
	levelUpFgPath = "",
};

--图片分享保存的路径
BP_ShareLevelUp_ImagePath = "";

function bp_share_levelup_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_share_levelup,
		{		
			{Path="/Game/UMG/UI_Logic/Share/Share_LevelUp_BP.Share_LevelUp_BP_C", Container="Top", ZOrder=BP_ENUM_UI_SHARE_RANK_ZORDER},
		},
		{"Lobby","Fighting"},
		false,
		false,
		true
	);
end

local function ShareReq(channel_type)
	ShareMgr.ShareSuccReq(7, channel_type);
end 

local function OnShareSucessEventHandler(eventType, eventID, vars)

	local hasApp = DataMgr.HasInstallPlatApp();
	if hasApp ==  true then
		LuaClassObj.HandleUIMessage(bp_share_levelup, "UIHide");	
	end	
end

function ShareLevelUpUI:ShowSharePanel()
	LuaClassObj.HandleDynamicCreation(bp_share_levelup);
	ShareUI:SetShareInfo(6);
	local rankConfig = Client.GetTableData("MilitaryRankLevel", DataMgr.roleData.level);
	BP_STRUCT_ShareLevelUp_ShareInfo = {};
	BP_STRUCT_ShareLevelUp_ShareInfo.levelUpName = rankConfig.MilitaryRankName;
	BP_STRUCT_ShareLevelUp_ShareInfo.levelUpBgPath = rankConfig.MilitaryRankTypeIconPath;
	BP_STRUCT_ShareLevelUp_ShareInfo.levelUpFgPath = rankConfig.MilitaryRankBigIconPath;
	EventSystem:registEvent(EVENTTYPE_SHARE, EVENTID_SHARE_SUCESSFUL, OnShareSucessEventHandler);
	LuaClassObj.HandleUIMessage(bp_share_levelup, "UIShow");
end

--分享facebook 复用QQ
function EventLevelUpShareClickFacebookBtn()	
	log("[HHF]EventLevelUpShareClickFacebookBtn");
	if Client.IsInstallQQ(NetInterface) == false then 
		--你还没有安装Facebook，无法使用此功能
		DataMgr.ShowNoticeByID(4005);
		return;
	end
		
	ShareMgr:shareQQWithPhoto(MEDIA_TAG_SHARE_CHIJI, "", BP_ShareLevelUp_ImagePath, ShareType.Moment);
	ClientSendBAReport(BP_BA_SHARE_QQSPACE, 0);
	ShareReq(BP_BA_SHARE_FACEBOOK);
end

--分享twitter
function EventLevelUpShareClickTwitterBtn()	
	log("[HHF]EventLevelUpShareClickTwitterBtn");
	if Client.IsInstallTwitter(NetInterface) == false then 
		--你还没有安装twitter，无法使用此功能
		--DataMgr.ShowNoticeByID(4062);
		--return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_ShareLevelUp_ImagePath, "", "", BP_ENUM_PLAYFORM_TWITTER);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_TW_COUNT, 0);
	ShareReq(BP_BA_SHARE_TWITTER);
end

--分享微信朋友圈
function EventLevelUpShareClickWXZoneBtn()	
	log("[HHF]EventLevelUpShareClickWXZoneBtn");
	if Client.IsInstallWX(NetInterface) == false then 
		--你还没有安装微信，无法使用此功能
		DataMgr.ShowNoticeByID(110126);
		return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_ShareLevelUp_ImagePath, "", "", BP_ENUM_PLAYFORM_WX);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_WX_ZONE_COUNT, 0);
	ShareReq(BP_BA_SHARE_WX_ZONE);
end

--分享VK
function EventLevelUpShareClickVKBtn()	
	log("[HHF]EventLevelUpShareClickVKBtn");
	if Client.IsInstallVK(NetInterface) == false then 
		--你还没有安装VK，无法使用此功能
		DataMgr.ShowNoticeByID(4310);
		return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_ShareLevelUp_ImagePath, "", "", BP_ENUM_PLAYFORM_VK);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_VK_COUNT, 0);
	ShareReq(BP_BA_SHARE_VK);
end

--分享Line
function EventLevelUpShareClickLineBtn()	
	log("[HHF]EventLevelUpShareClickLineBtn");
	if Client.IsInstallLine(NetInterface) == false then 
		--你还没有安装Line，无法使用此功能
		DataMgr.ShowNoticeByID(4985);
		return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_ShareLevelUp_ImagePath, "", "", BP_ENUM_PLAYFORM_LINE);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_LINE_COUNT, 0);
	ShareReq(BP_BA_SHARE_LINE);
end

--分享QQ
function EventLevelUpShareClickQQByiTOPBtn()	
	log("EventLevelUpShareClickQQByiTOPBtn");
	if Client.IsInstallQQByiTOP(NetInterface) == false then 
		--你还没有安装QQ，无法使用此功能
		DataMgr.ShowNoticeByID(110125);
		return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_ShareLevelUp_ImagePath, "", "", BP_ENUM_PLAYFORM_QQByiTOP);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_QQByiTOP_COUNT, 0);
	ShareReq(BP_BA_SHARE_QQByiTOP);
end

function EventShareLevelUpHide()
	EventSystem:unregistEvent(EVENTTYPE_SHARE, EVENTID_SHARE_SUCESSFUL, OnShareSucessEventHandler);
end

function EventSetInfo_Push()
end

function EventFetchInfo()
end