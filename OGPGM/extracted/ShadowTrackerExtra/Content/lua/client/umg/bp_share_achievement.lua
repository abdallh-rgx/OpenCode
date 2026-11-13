-- 个人成就达成领奖后分享
ShareAchievementShareUI = ShareAchievementShareUI or {
}

BP_ShareAchievementNick = ""; --人物昵称
BP_ShareAchievementPath = ""; --截图图片路径
BP_ShareAchievementUrl = ""; --人物头像

BP_ShareAchievement_ID = 0; -- 成就ID
BP_ShareAchievement_Name = ""; -- 成就名称
BP_ShareAchievement_Icon = ""; -- 成就图标
BP_ShareAchievement_Score = ""; -- 成就奖励的时间戳
--BP_ShareAchievement_Desc = ""; -- 成就的解释
BP_ShareAchievement_Group = 0; -- 成就分组
BP_ShareAchievement_GroupNum = 0; -- 成就阶数


function bp_share_achievement_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_share_achievement,
		{
			{Path="/Game/UMG/UI_Logic/Share/Share_Achievement_LogicBP.Share_Achievement_LogicBP_C", Container="Default", ZOrder=BP_ENUM_UI_Share_Achievement_ZORDER},
		},
		{"Lobby"},
		false,
		false,
		true
	);
	
	EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_SHARE, ShareAchievementShareUI.ShowUI);
end	

function EventShareAchievement_Push()
	--蓝图变量同步给lua
end

function EventShareAchievementFetchInfo()
	--lua变量同步蓝图
end

local function OnShareSucessEventHandler(eventType, eventID, vars)
	if eventType ~= EVENTTYPE_SHARE then
		return;
	end	

	local hasApp = DataMgr.HasInstallPlatApp();
	if hasApp ==  true then
		LuaClassObj.HandleUIMessage(bp_share_achievement, "UIHide");	
	end
	
	EventSystem:unregistEvent(EVENTTYPE_SHARE, EVENTID_SHARE_SUCESSFUL, OnShareSucessEventHandler);
end

--显示UI 
function ShareAchievementShareUI.ShowUI(id)
	BP_ShareAchievement_ID = id
	if BP_ShareAchievement_ID == 0 then return end

	local cfg = AchievementSystem.GetAchievementDataByID(id);
	if cfg == nil then return end

	BP_ShareAchievement_Name = cfg.Name;
	BP_ShareAchievement_Icon = cfg.BigImgUrl;
	--[[ 替换<Mall_LimitTime_Font2>{2}</>为{2}
	local formatString = string.gsub(cfg.Desc, "<.->(.-)</>", "%1");
	formatString = string.gsub(formatString, "{0}", tostring(cfg.TotalProcess));
	formatString = string.gsub(formatString, "{1}", tostring(cfg.ParamDes));
	BP_ShareAchievement_Desc = formatString;--]]
	BP_ShareAchievement_Score = FuncUtil.SecToDateString(cfg.FinishTime);
	BP_ShareAchievement_Group = cfg.GroupID;
	BP_ShareAchievement_GroupNum = cfg.MultiLvGroupNum;
	
	if DataMgr.roleData ~= nil then
		BP_ShareAchievementNick = DataMgr.roleData.nickName;
		BP_ShareAchievementUrl = DataMgr.roleData.headIconUrl;
	end

	LuaClassObj.HandleDynamicCreation(bp_share_achievement);
	EventSystem:registEvent(EVENTTYPE_SHARE, EVENTID_SHARE_SUCESSFUL, OnShareSucessEventHandler);

	LuaClassObj.HandleUIMessage(bp_share_achievement, "UIShow");
	UIManager.Show(eUIType.eShareAchievementUI)
end

local  function ShareReqDay(channel_type)
	ShareMgr.ShareSuccReq(2, channel_type);
end 

--保存本地
function EventClickBtnSave()
	log("bp_share_achievement clickSaveLoc");
end

--分享facebook 复用QQ
function EventAchievementShareClickFacebookBtn()	
	log("[HHF]EventAchievementShareClickFacebookBtn");
	if Client.IsInstallQQ(NetInterface) == false then 
		--你还没有安装Facebook，无法使用此功能
		DataMgr.ShowNoticeByID(4005);
		return;
	end
		
	ShareMgr:shareQQWithPhoto(MEDIA_TAG_SHARE_CHIJI, "", BP_ShareAchievementPath, ShareType.Moment);
	ClientSendBAReport(BP_BA_SHARE_QQSPACE, 0);
	ShareReqDay(BP_BA_SHARE_FACEBOOK);
end

--分享twitter
function EventAchievementShareClickTwitterBtn()	
	log("[HHF]EventAchievementShareClickTwitterBtn");
	if Client.IsInstallTwitter(NetInterface) == false then 
		--你还没有安装twitter，无法使用此功能
		--DataMgr.ShowNoticeByID(4062);
		--return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_ShareAchievementPath, "", "", BP_ENUM_PLAYFORM_TWITTER);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_TW_COUNT, 0);
	ShareReqDay(BP_BA_SHARE_TWITTER);
end

--分享微信朋友圈
function EventAchievementShareClickWXZoneBtn()	
	log("[HHF]EventAchievementShareClickWXZoneBtn");
	if Client.IsInstallWX(NetInterface) == false then 
		--你还没有安装微信，无法使用此功能
		DataMgr.ShowNoticeByID(110126);
		return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_ShareAchievementPath, "", "", BP_ENUM_PLAYFORM_WX);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_WX_ZONE_COUNT, 0);
	ShareReqDay(BP_BA_SHARE_WX_ZONE);
end

--分享VK
function EventAchievementShareClickVKBtn()	
	log("[HHF]EventAchievementShareClickVKBtn");
	if Client.IsInstallVK(NetInterface) == false then 
		--你还没有安装VK，无法使用此功能
		DataMgr.ShowNoticeByID(4310);
		return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_ShareAchievementPath, "", "", BP_ENUM_PLAYFORM_VK);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_VK_COUNT, 0);
	ShareReqDay(BP_BA_SHARE_VK);
end

--分享Line
function EventAchievementShareClickLineBtn()	
	log("[HHF]EventAchievementShareClickLineBtn");
	if Client.IsInstallLine(NetInterface) == false then 
		--你还没有安装Line，无法使用此功能
		DataMgr.ShowNoticeByID(4985);
		return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_ShareAchievementPath, "", "", BP_ENUM_PLAYFORM_LINE);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_LINE_COUNT, 0);
	ShareReqDay(BP_BA_SHARE_LINE);
end

--分享QQ
function EventAchievementShareClickQQByiTOPBtn()	
	log("EventAchievementShareClickQQByiTOPBtn");
	if Client.IsInstallQQByiTOP(NetInterface) == false then 
		--你还没有安装QQ，无法使用此功能
		DataMgr.ShowNoticeByID(110125);
		return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_ShareAchievementPath, "", "", BP_ENUM_PLAYFORM_QQByiTOP);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_QQByiTOP_COUNT, 0);
	ShareReqDay(BP_BA_SHARE_QQByiTOP);
end

function EventAchievementShare_Hide()
	UIManager.Hide(eUIType.eShareAchievementUI)
end


