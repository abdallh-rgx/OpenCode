--称号分享和获得UI
ShareAliasUI = ShareAliasUI or
{
	hasAliasToShow = false;
	canShowAlias = false;
	isShowingGetAliasUI = false;
}

BP_STRUCT_ShareAlias_AliasInfo = 
{
	aliasIconUrl = "",
	aliasIconUrlBig = "",
	aliasTitle = "",
	aliasDesc = "",
	aliasQuality = 0,
	aliasNation = "",
	aliasGetTime = "",
	aliasType = 0,
};
--图片分享保存的路径
BP_ShareAlias_ImagePath = "";


function bp_share_alias_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_share_alias,
		{		
			{Path="/Game/UMG/UI_BP/RoleInfo/Title_Get_UIBP.Title_Get_UIBP_C", Container="Top", ZOrder=BP_ENUM_UI_LEVEL_UP_ZORDER},
			{Path="/Game/UMG/UI_Logic/Share/Share_Alias_LogicBP.Share_Alias_LogicBP_C", Container="Top", ZOrder=BP_ENUM_UI_SHARE_RANK_ZORDER},
		},
		{"Lobby"},
		false,
		false,
		true
	);

	EventSystem:registEvent(EVENTTYPE_LOBBY, EVNETID_ITEM_GET_DONE, ShareAliasUI.ShowGetAliasUI);
	EventSystem:registEvent(EVENTTYPE_LOGIN, EVENTID_BACKLOGIN, ShareAliasUI.OnLogOut);
end

local function ShareReq(channel_type)
	ShareMgr.ShareSuccReq(7, channel_type);
end 

local function OnShareSucessEventHandler(eventType, eventID, vars)

	local hasApp = DataMgr.HasInstallPlatApp();
	if hasApp ==  true then
		LuaClassObj.HandleUIMessage(bp_share_alias, "UIHide");	
	end	
end

function EventGotoAliasManagement()
	BP_Current_CheckBox = 0; --默认选中个人称号项
	RoleInfoShowInfoUI.Show();
end

function EventGetAliasUIHide()
	ShareAliasUI.isShowingGetAliasUI = false
	LobbySystem.PopNextUI();
	--跳转bug
	EventTaskHideUI()
end

function ShareAliasUI.OnLogOut()
	log("ShareAliasUI.OnLogOut");
	ShareAliasUI.hasAliasToShow = false;
end

function ShareAliasUI.AddAliasInfo(alias_id, alias_info) -- 现将数据存起来，等待时机展示
	local cfg = Client.GetTableData("AliasCfg", alias_id);

	if cfg ~= nil then
		BP_STRUCT_ShareAlias_AliasInfo.aliasIconUrl = cfg.AliasIconPath;
		BP_STRUCT_ShareAlias_AliasInfo.aliasIconUrlBig = cfg.AliasIconPathBig;
		BP_STRUCT_ShareAlias_AliasInfo.aliasTitle = FuncUtil:Gen_title(alias_id, alias_info.rank);
		BP_STRUCT_ShareAlias_AliasInfo.aliasQuality = cfg.AliasQuality;
		BP_STRUCT_ShareAlias_AliasInfo.aliasDesc = cfg.AliasDesc;
		BP_STRUCT_ShareAlias_AliasInfo.aliasNation = alias_info.nation;
		BP_STRUCT_ShareAlias_AliasInfo.aliasGetTime = os.date('%Y.%m.%d', alias_info.receive_time);
		BP_STRUCT_ShareAlias_AliasInfo.aliasType = cfg.AliasType;

		ShareAliasUI.hasAliasToShow = true;

		if cfg.AliasType == 1 and ShareAliasUI.isShowingGetAliasUI == false then -- 战区称号直接展示获得界面
			ShareAliasUI.isShowingGetAliasUI = true;
			ShareAliasUI.ShowGetAliasUI()
		end
	end
end

function ShareAliasUI.ShowGetAliasUI()
	
	if ShareAliasUI.hasAliasToShow == true and (ShareAliasUI.canShowAlias == true or BP_STRUCT_ShareAlias_AliasInfo.aliasType == 2) then 
		log("ShareAliasUI.ShowGetAliasUI")
		LuaClassObj.HandleDynamicCreation(bp_share_alias);
		LuaClassObj.HandleUIMessage(bp_share_alias, "UIShowGetAlias");

		ShareAliasUI.hasAliasToShow = false;
	else
		LobbySystem.PopNextUI();
	end
end

function EventShowShareAliasUI()
	LuaClassObj.HandleDynamicCreation(bp_share_alias);
	LuaClassObj.HandleUIMessage(bp_share_alias, "UIShowShareAlias");
end

function ShareAliasUI:ShowSharePanel()
	LuaClassObj.HandleDynamicCreation(bp_share_alias);
	ShareUI:SetShareInfo(14);
	BP_STRUCT_ShareAlias_AliasInfo = {};
	BP_STRUCT_ShareLevelUp_ShareInfo.levelUpName = BP_RankName;
	BP_STRUCT_ShareLevelUp_ShareInfo.levelUpBgPath = BP_RankBgPath;
	BP_STRUCT_ShareLevelUp_ShareInfo.levelUpFgPath = BP_RankFgPath;
	EventSystem:registEvent(EVENTTYPE_SHARE, EVENTID_SHARE_SUCESSFUL, OnShareSucessEventHandler);
	LuaClassObj.HandleUIMessage(bp_share_alias, "UIShow");
end

--分享facebook 复用QQ
function EventAliasShareClickFacebookBtn()	
	log("[HHF]EventLevelUpShareClickFacebookBtn");
	if Client.IsInstallQQ(NetInterface) == false then 
		--你还没有安装Facebook，无法使用此功能
		DataMgr.ShowNoticeByID(4005);
		return;
	end
		
	ShareMgr:shareQQWithPhoto(MEDIA_TAG_SHARE_CHIJI, "", BP_ShareAlias_ImagePath, ShareType.Moment);
	ClientSendBAReport(BP_BA_SHARE_QQSPACE, 0);
	ShareReq(BP_BA_SHARE_FACEBOOK);
end

--分享twitter
function EventAliasShareClickTwitterBtn()	
	log("[HHF]EventLevelUpShareClickTwitterBtn");
	if Client.IsInstallTwitter(NetInterface) == false then 
		--你还没有安装twitter，无法使用此功能
		--DataMgr.ShowNoticeByID(4062);
		--return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_ShareAlias_ImagePath, "", "", BP_ENUM_PLAYFORM_TWITTER);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_TW_COUNT, 0);
	ShareReq(BP_BA_SHARE_TWITTER);
end

--分享微信朋友圈
function EventAliasShareClickWXZoneBtn()	
	log("[HHF]EventLevelUpShareClickWXZoneBtn");
	if Client.IsInstallWX(NetInterface) == false then 
		--你还没有安装微信，无法使用此功能
		DataMgr.ShowNoticeByID(110126);
		return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_ShareAlias_ImagePath, "", "", BP_ENUM_PLAYFORM_WX);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_WX_ZONE_COUNT, 0);
	ShareReq(BP_BA_SHARE_WX_ZONE);
end

--分享VK
function EventAliasShareClickVKBtn()	
	log("[HHF]EventLevelUpShareClickVKBtn");
	if Client.IsInstallVK(NetInterface) == false then 
		--你还没有安装VK，无法使用此功能
		DataMgr.ShowNoticeByID(4310);
		return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_ShareAlias_ImagePath, "", "", BP_ENUM_PLAYFORM_VK);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_VK_COUNT, 0);
	ShareReq(BP_BA_SHARE_VK);
end

--分享Line
function EventAliasShareClickLineBtn()	
	log("[HHF]EventLevelUpShareClickLineBtn");
	if Client.IsInstallLine(NetInterface) == false then 
		--你还没有安装Line，无法使用此功能
		DataMgr.ShowNoticeByID(4985);
		return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_ShareAlias_ImagePath, "", "", BP_ENUM_PLAYFORM_LINE);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_LINE_COUNT, 0);
	ShareReq(BP_BA_SHARE_LINE);
end

--分享QQ
function EventAliasShareClickQQByiTOPBtn()	
	log("EventAliasShareClickQQByiTOPBtn");
	if Client.IsInstallQQByiTOP(NetInterface) == false then 
		--你还没有安装QQ，无法使用此功能
		DataMgr.ShowNoticeByID(110125);
		return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_ShareAlias_ImagePath, "", "", BP_ENUM_PLAYFORM_QQByiTOP);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_QQByiTOP_COUNT, 0);
	ShareReq(BP_BA_SHARE_QQByiTOP);
end

function EventShareAliasHide()
	EventSystem:unregistEvent(EVENTTYPE_SHARE, EVENTID_SHARE_SUCESSFUL, OnShareSucessEventHandler);
end

function EventShareAlias_Push()
end

function EventFetchInfo()
end

-- 登录时检测是否要弹
function ShareAliasUI.CheckPopUI()
	ShareAliasUI.canShowAlias = true;
	ShareAliasUI.ShowGetAliasUI() -- 恭喜获得称号
end
