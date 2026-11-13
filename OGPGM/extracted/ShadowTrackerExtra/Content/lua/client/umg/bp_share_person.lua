--[[
	分享 个人 2017-12-12
--]]

SharePersonUI = SharePersonUI or {
	typeShare = 0; 
}

BP_SharePersonPath = "";

--个人战绩总数据（单人1，双人2，组队3, 总体4）
BP_STRUCT_SharePersonInfo =
{
	roleUid = "",
	headIconUrl = "",
	gender = 0,
	nickName = "",
	mordelStr = "",
	
	role_allmatchnum = "",		--总场数
	role_winnum = "",
	role_toptennum = "",
	role_killnum = "",
	role_kd = "",
	role_critrate = "",
	
	role_sum = "", --分数
	role_grade = "", --grade就是0-8的评级图片
	
	role_SegmentScore = 0, --段位分
	role_SegmentLevel = 0, --段位分
	ShortModelStr = "", --简短的模式：单人，双人，四人
	ShootTypeStr = "", --第三人称，第一人称
};


function bp_share_person_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_share_person,
		{		
			{Path="/Game/UMG/UI_Logic/Share/Share_PersonLogicBP.Share_PersonLogicBP_C", Container="Default", ZOrder=BP_ENUM_UI_Share_PersonInfo},
		},
		{"Lobby"},
		false, 
		false,
		true
	);
end	 

--组织数据
function SharePersonUI.ContructData()
	BP_STRUCT_SharePersonInfo = {};	
	local perInfo =  RoleInfoUI.GetShareData();
	--log_tree("SharePersonUIContructData", perInfo);
	if perInfo ~= nil then
		BP_STRUCT_SharePersonInfo.role_allmatchnum = perInfo.role_allmatchnum;
		BP_STRUCT_SharePersonInfo.role_winnum = perInfo.role_winnum;
		BP_STRUCT_SharePersonInfo.role_toptennum = perInfo.role_toptennum;
		BP_STRUCT_SharePersonInfo.role_killnum = perInfo.role_killnum;
		BP_STRUCT_SharePersonInfo.role_kd = perInfo.role_kd;
		BP_STRUCT_SharePersonInfo.role_critrate = perInfo.role_critrate;
	end
	
	local gradeInfo =   RoleInfoUI.GetShareGradeData();
	--log_tree("SharePersonUIContructData", gradeInfo);
	if gradeInfo ~= nil then
		BP_STRUCT_SharePersonInfo.role_sum = gradeInfo.sum_score;--分数
		BP_STRUCT_SharePersonInfo.role_grade = gradeInfo.grade;--grade就是0-8的评级图片
	end
	
	BP_STRUCT_SharePersonInfo.roleUid = DataMgr.roleData.uid;
	BP_STRUCT_SharePersonInfo.headIconUrl = DataMgr.roleData.headIconUrl;
	BP_STRUCT_SharePersonInfo.gender = DataMgr.roleData.gender;
	BP_STRUCT_SharePersonInfo.nickName = DataMgr.roleData.nickName;	
	BP_STRUCT_SharePersonInfo.mordelStr = ""
	if SharePersonUI.shootType == ShootType["TPPType"] then
		--BP_STRUCT_SharePersonInfo.mordelStr = "经典(第三人称)"
		BP_STRUCT_SharePersonInfo.mordelStr = Client.GetTableData("LocalizeRes", "100040").TextValue

		BP_STRUCT_SharePersonInfo.ShootTypeStr = Client.GetTableData("LocalizeRes", "100054").TextValue
	elseif SharePersonUI.shootType == ShootType["FPPType"] then
		--BP_STRUCT_SharePersonInfo.mordelStr = "经典(第一人称)"
		BP_STRUCT_SharePersonInfo.ShootTypeStr = Client.GetTableData("LocalizeRes", "100053").TextValue
		BP_STRUCT_SharePersonInfo.mordelStr = Client.GetTableData("LocalizeRes", "100050").TextValue
	end
	if SharePersonUI.typeShare == 1 then
		--BP_STRUCT_SharePersonInfo.mordelStr = "经典(第三\一人称)-单人模式"
		local modelStr = Client.GetTableData("LocalizeRes", "993048").TextValue
		BP_STRUCT_SharePersonInfo.ShortModelStr = modelStr
		BP_STRUCT_SharePersonInfo.mordelStr = BP_STRUCT_SharePersonInfo.mordelStr .. modelStr
	elseif SharePersonUI.typeShare == 2 then
		--BP_STRUCT_SharePersonInfo.mordelStr = "经典(第三\一人称)-双人模式"
		local modelStr= Client.GetTableData("LocalizeRes", "993049").TextValue
		BP_STRUCT_SharePersonInfo.ShortModelStr = modelStr
		BP_STRUCT_SharePersonInfo.mordelStr = BP_STRUCT_SharePersonInfo.mordelStr .. modelStr
	elseif SharePersonUI.typeShare == 3 then
		--BP_STRUCT_SharePersonInfo.mordelStr = "经典(第三\一人称)-四人模式"
		local modelStr= Client.GetTableData("LocalizeRes", "993050").TextValue
		BP_STRUCT_SharePersonInfo.ShortModelStr = modelStr
		BP_STRUCT_SharePersonInfo.mordelStr = BP_STRUCT_SharePersonInfo.mordelStr .. modelStr
	end

	BP_STRUCT_SharePersonInfo.role_SegmentScore = RoleInfoUI.GetShareSegmentScore()
	BP_STRUCT_SharePersonInfo.role_SegmentLevel = RoleInfoUI.GetShareSegmentLevel()
	
	--log_tree("SharePersonUIContructData struct", BP_STRUCT_SharePersonInfo);
end

local  function ShareReqPerson(channel_type)
	ShareMgr.ShareSuccReq(3, channel_type);
end 

local function OnShareSucessEventHandler(eventType, eventID, vars)

	if eventType ~= EVENTTYPE_SHARE then
		return;
	end	

	local hasApp = DataMgr.HasInstallPlatApp();
	if hasApp ==  true then
		LuaClassObj.HandleUIMessage(bp_share_person, "UIHide");	
	end
	
	EventSystem:unregistEvent(EVENTTYPE_SHARE, EVENTID_SHARE_SUCESSFUL, OnShareSucessEventHandler);
end


--显示UI 
function SharePersonUI.ShowUI(typeShare, shootType)
	LuaClassObj.HandleDynamicCreation(bp_share_person);
	ShareUI:SetShareInfo(3);
	EventSystem:registEvent(EVENTTYPE_SHARE, EVENTID_SHARE_SUCESSFUL, OnShareSucessEventHandler);

	SharePersonUI.typeShare = typeShare;	
	SharePersonUI.shootType = shootType;
	
	SharePersonUI.ContructData();
	LuaClassObj.HandleUIMessage(bp_share_person, "UIShow");	
	UIManager.Show(eUIType.eSharePersonUI)
	ClientSendBAReport(BP_BA_SHARE_MAINPANEL, 0);
end


--关闭UI
function EventHideUI()
	UIManager.Hide(eUIType.eSharePersonUI)
	LuaClassObj.HandleUIMessage(bp_share_person, "UIHide");	
end


function EventSharePerson_Push()
	--蓝图变量同步给lua
end

function EventSharePersonFetchInfo()
	--lua变量同步蓝图
end


--分享facebook 复用QQ
function EventPersonShareClickFacebookBtn()	
	log("[HHF]EventPersonShareClickFacebookBtn");
	if Client.IsInstallQQ(NetInterface) == false then 
		--你还没有安装Facebook，无法使用此功能
		DataMgr.ShowNoticeByID(4005);
		return;
	end
		
	ShareMgr:shareQQWithPhoto(MEDIA_TAG_SHARE_CHIJI, "", BP_SharePersonPath, ShareType.Moment);
	ClientSendBAReport(BP_BA_SHARE_QQSPACE, 0);
	ShareReqPerson(BP_BA_SHARE_FACEBOOK);
end

--分享twitter
function EventPersonShareClickTwitterBtn()	
	log("[HHF]EventPersonShareClickTwitterBtn");
	if Client.IsInstallTwitter(NetInterface) == false then 
		--你还没有安装twitter，无法使用此功能
		--DataMgr.ShowNoticeByID(4062);
		--return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_SharePersonPath, "", "", BP_ENUM_PLAYFORM_TWITTER);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_TW_COUNT, 0);
	ShareReqPerson(BP_BA_SHARE_TWITTER);
end

--分享微信朋友圈
function EventPersonShareClickWXZoneBtn()	
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
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_SharePersonPath, "", "", BP_ENUM_PLAYFORM_WX);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_WX_ZONE_COUNT, 0);
	ShareReqPerson(BP_BA_SHARE_WX_ZONE);
end

--分享VK
function EventPersonShareClickVKBtn()	
	log("[HHF]EventPersonShareClickVKBtn");
	if Client.IsInstallVK(NetInterface) == false then 
		--你还没有安装VK，无法使用此功能
		DataMgr.ShowNoticeByID(4310);
		return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_SharePersonPath, "", "", BP_ENUM_PLAYFORM_VK);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_VK_COUNT, 0);
	ShareReqPerson(BP_BA_SHARE_VK);
end

--分享Line
function EventPersonShareClickLineBtn()	
	log("[HHF]EventPersonShareClickLineBtn");
	if Client.IsInstallLine(NetInterface) == false then 
		--你还没有安装Line，无法使用此功能
		DataMgr.ShowNoticeByID(4985);
		return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_SharePersonPath, "", "", BP_ENUM_PLAYFORM_LINE);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_LINE_COUNT, 0);
	ShareReqPerson(BP_BA_SHARE_LINE);
end

--分享QQ
function EventPersonShareClickQQByiTOPBtn()	
	log("EventPersonShareClickQQByiTOPBtn");
	if Client.IsInstallQQByiTOP(NetInterface) == false then 
		--你还没有安装QQ，无法使用此功能
		DataMgr.ShowNoticeByID(110125);
		return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_SharePersonPath, "", "", BP_ENUM_PLAYFORM_QQByiTOP);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_QQByiTOP_COUNT, 0);
	ShareReqPerson(BP_BA_SHARE_QQByiTOP);
end

--分享More
function EventPersonShareClickMoreBtn()	
	log("[HHF]EventPersonShareClickMoreBtn");
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_SharePersonPath, "", "", BP_ENUM_PLAYFORM_MORE);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_MORE_COUNT, 0);
	ShareReqPerson(BP_BA_SHARE_MORE);
end
