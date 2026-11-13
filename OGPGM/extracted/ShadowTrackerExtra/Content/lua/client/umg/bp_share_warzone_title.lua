--[[
	分享战区称号
--]]

ShareWarZoneTitletUI = ShareWarZoneTitletUI or {
 bIsShow = false;
}

BP_ShareWarZoneTitle_Success = true
BP_ShareWarZoneTitle_Str = ""
BP_ShareWarZoneTitle_Id = 0
BP_ShareWarZoneTitle_KillTxt = ""
BP_ShareWarZoneTitle_KillNum = 0
BP_ShareWarZoneTitle_IconPath = ""
BP_ShareWarZoneTitle_PetalPath = ""
BP_ShareWarZoneTitle_RankName = ""
BP_ShareWarZoneTitle_FailTxt = ""
BP_ShareWarZoneTitle_Type = 1 -- 1 战区榜；2 好友榜;3 街区榜
BP_ShareWarZoneTitle_RankStr = ""
BP_ShareWarzoneTitle_ImagePath = ""


function bp_share_warzone_title_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_share_warzone_title,
		{
			{Path="/Game/UMG/UI_Logic/WarZone/ShareWarZoneTitle_BP.ShareWarZoneTitle_BP_C", Container="Default", ZOrder=BP_ENUM_UI_ROLEINFO_ZORDER+2},
		},
		{"Lobby"},
		false,
		false,
		true
	);
end

--分享成功的回调
local function OnWarZoneTitleShareSucessEventHandler(eventType, eventID, vars)

	log("********result warzone title share call back *********");
	if eventType ~= EVENTTYPE_SHARE then
		return;
	end	

	local hasApp = DataMgr.HasInstallPlatApp();
	if hasApp ==  true then
		LuaClassObj.HandleUIMessage(bp_share_warzone_title, "UIHide");	
	end
	
	log("********result warzone title share success, hide title share ui *********");
	EventSystem:unregistEvent(EVENTTYPE_SHARE, EVENTID_SHARE_SUCESSFUL, OnWarZoneTitleShareSucessEventHandler);
end

--[[蓝图打开分享界面，但调用之前一定要在蓝图上设置
	BP_ShareWarZoneTitle_Success = succ
	BP_ShareWarZoneTitle_Str = titleStr
	BP_ShareWarZoneTitle_IconPath = titleIconPath
	BP_ShareWarZoneTitle_TotalKill = totalKill
	BP_ShareWarZoneTitle_NeedKillLeastNum = needKillLeastNum
]]--
function EventShowShareWarZoneTitleUI_Push()
	ShareWarZoneTitletUI.ShowUI();
	EventSystem:registEvent(EVENTTYPE_SHARE, EVENTID_SHARE_SUCESSFUL, OnWarZoneTitleShareSucessEventHandler);
end

function EventShareWarZoneTitle_Push()
	
end


local function ShareReq(channel_type)
	ShareMgr.ShareSuccReq(11, channel_type);
end 


--分享facebook 复用QQ
function EventWarzoneTitleShareClickFacebookBtn()	
	log("[HHF]EventWarzoneTitleShareClickFacebookBtn");
	if Client.IsInstallQQ(NetInterface) == false then 
		--你还没有安装Facebook，无法使用此功能
		DataMgr.ShowNoticeByID(4005);
		return;
	end
		
	ShareMgr:shareQQWithPhoto(MEDIA_TAG_SHARE_CHIJI, "", BP_ShareWarzoneTitle_ImagePath, ShareType.Moment);
	ClientSendBAReport(BP_BA_SHARE_QQSPACE, 0);
	ShareReq(BP_BA_SHARE_FACEBOOK);
end

--分享twitter
function EventWarzoneTitleShareClickTwitterBtn()	
	log("[HHF]EventWarzoneTitleShareClickTwitterBtn");
	if Client.IsInstallTwitter(NetInterface) == false then 
		--你还没有安装twitter，无法使用此功能
		--DataMgr.ShowNoticeByID(4062);
		--return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_ShareWarzoneTitle_ImagePath, "", "", BP_ENUM_PLAYFORM_TWITTER);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_TW_COUNT, 0);
	ShareReq(BP_BA_SHARE_TWITTER);
end

--分享微信朋友圈
function EventWarzoneTitleShareClickWXZoneBtn()	
	log("[HHF]EventWarzoneTitleShareClickWXZoneBtn");
	if Client.IsInstallWX(NetInterface) == false then 
		--你还没有安装微信，无法使用此功能
		DataMgr.ShowNoticeByID(110126);
		return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_ShareWarzoneTitle_ImagePath, "", "", BP_ENUM_PLAYFORM_WX);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_WX_ZONE_COUNT, 0);
	ShareReq(BP_BA_SHARE_WX_ZONE);
end

--分享VK
function EventWarzoneTitleShareClickVKBtn()	
	log("[HHF]EventWarzoneTitleShareClickVKBtn");
	if Client.IsInstallVK(NetInterface) == false then 
		--你还没有安装VK，无法使用此功能
		DataMgr.ShowNoticeByID(4310);
		return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_ShareWarzoneTitle_ImagePath, "", "", BP_ENUM_PLAYFORM_VK);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_VK_COUNT, 0);
	ShareReq(BP_BA_SHARE_VK);
end

--分享Line
function EventWarzoneTitleShareClickLineBtn() 
    log("[HHF]EventWarzoneTitleShareClickLineBtn");
    if Client.IsInstallLine(NetInterface) == false then 
        --你还没有安装Line，无法使用此功能
        DataMgr.ShowNoticeByID(4985);
        return;
    end
    
    ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_ShareWarzoneTitle_ImagePath, "", "", BP_ENUM_PLAYFORM_LINE);
    --上报给后台做统计
    ClientSendBAReport(BP_BA_SHARE_LINE_COUNT, 0);
    ShareReq(BP_BA_SHARE_LINE);
end

--分享QQ
function EventWarzoneTitleShareClickQQByiTOPBtn()	
	log("EventWarzoneTitleShareClickQQByiTOPBtn");
	if Client.IsInstallQQByiTOP(NetInterface) == false then 
		--你还没有安装QQ，无法使用此功能
		DataMgr.ShowNoticeByID(110125);
		return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_ShareWarzoneTitle_ImagePath, "", "", BP_ENUM_PLAYFORM_QQByiTOP);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_QQByiTOP_COUNT, 0);
	ShareReq(BP_BA_SHARE_QQByiTOP);
end

local function get_kill_num_from_record(rankId)
    local config = Client.GetTableData("lbsranktypetable", rankId);
	local killRecord = DataMgr.lbs_warzone_info.lbs_warzone_record;
	if config ~= nil and killRecord ~= nil then
		local var_str = config.score_var
		local recordNum = killRecord[var_str]
		if recordNum ~= nil then
			return recordNum
		end
	end
	return 0
end

local function get_kill_txt( succ, rankId, lbsType)
    local config = Client.GetTableData("lbsranktypetable", rankId);
	local txt = ""
	local fail_txt = ""
	if config ~= nil then
		txt = config.display_desc..":"
		if lbsType == 1 then
			fail_txt = ""; --FuncUtil.LocalizeResFormat("120181", rankInfo.display_desc)
		elseif lbsType == 2 then
			fail_txt = ""; --FuncUtil.LocalizeResFormat("120182", rankInfo.display_desc)
		elseif lbsType == 3 then
			fail_txt = ""; --FuncUtil.LocalizeResFormat("120180", rankInfo.display_desc)
		end
	end

	if succ == false then
		txt = Client.GetTableData("LocalizeRes", "4940").TextValue ..txt
	end
	return txt, fail_txt
end

-- lua层打开分享界面
-- killTotalNum:击杀、吃鸡、空投等等次数，成功界面上显示，nil则分享界面自己请求
-- needKillLeastNum：最低上榜击杀、吃鸡、空投等等次数，失败界面上显示，succ=false时必须传入
-- lbsType ：1 战区榜；2 好友榜;3 街区榜; 0 称号
function ShareWarZoneTitletUI.Enter(succ, rankId, titleStr, rankStr,titleIconPath, titlePetalPath, killTotalNum, needKillLeastNum, lbsType)
	BP_ShareWarZoneTitle_Type = lbsType or 1
	titleStr = titleStr or ""
	rankId = rankId or 0
	titleIconPath = titleIconPath or ""
	titlePetalPath = titlePetalPath or ""
	needKillLeastNum = needKillLeastNum or -1

	BP_ShareWarZoneTitle_Success = succ
	BP_ShareWarZoneTitle_Str = titleStr
	BP_ShareWarZoneTitle_RankStr = rankStr
	BP_ShareWarZoneTitle_Id = rankId
	BP_ShareWarZoneTitle_IconPath = titleIconPath
	BP_ShareWarZoneTitle_PetalPath = titlePetalPath
    local config = Client.GetTableData("lbsranktypetable", rankId);
	BP_ShareWarZoneTitle_RankName = config and config.rank_name or ""
	BP_ShareWarZoneTitle_FailTxt = "很遗憾，以你当前的".."".."，未能进入该街区前十，不要气馁继续加油"

	local killNum = killTotalNum or 0
	if succ then
		if killTotalNum == nil then
			killNum = get_kill_num_from_record(rankId)
		end
	else
		killNum = needKillLeastNum
	end
	BP_ShareWarZoneTitle_KillNum = killNum
	BP_ShareWarZoneTitle_KillTxt, BP_ShareWarZoneTitle_FailTxt = get_kill_txt(succ, rankId, lbsType)
	ShareWarZoneTitletUI.ShowUI();
	ShareWarZoneTitletUI.SetShareInfo(lbsType)
	EventSystem:registEvent(EVENTTYPE_SHARE, EVENTID_SHARE_SUCESSFUL, OnWarZoneTitleShareSucessEventHandler);

	if succ == true and killNum <= 0 then
		--说明没有击杀数据，需要额外请求
		--RoleInfoSystem.get_role_lbs_battle_info_req(DataMgr.roleData.uid)
	end
end

function ShareWarZoneTitletUI.SetShareInfo(lbsType)
	log("ShareWarZoneTitletUI.SetShareType" .. lbsType)
	local index = 0 
	if lbsType == 0 then 
		index = 17
	elseif lbsType == 1 then
		index = 15
	elseif lbsType == 2 then
		index = 18
	elseif lbsType == 3 then
		index = 16
	end
	if index ~= 0 then  
		ShareUI:SetShareInfo(index);
		log("ShareWarZoneTitletUI--ShareUI:SetShareInfo" .. index)
	end
end

-- 数据更新时刷新，为了客户端缺少总击杀数设计
function ShareWarZoneTitletUI.RefreshTotalKillData()
	if ShareWarZoneTitletUI.bIsShow == false then return end
	if BP_ShareWarZoneTitle_Success == false then return end

	local totalKill = get_kill_num_from_record(BP_ShareWarZoneTitle_Id)
	log("ShareWarZoneTitletUI.RefreshTotalKillData:"..totalKill);
	BP_ShareWarZoneTitle_TotalKill = totalKill
	LuaClassObj.HandleUIMessage(bp_share_warzone_title, "RefreshUI");
end

--显示UI内部接口
function ShareWarZoneTitletUI.ShowUI()
	log("ShareWarZoneTitletUI ShowUI")
	ShareWarZoneTitletUI.bIsShow = true;
	LuaClassObj.HandleDynamicCreation(bp_share_warzone_title);
	LuaClassObj.HandleUIMessage(bp_share_warzone_title, "ShowUI");

	UIManager.Show(eUIType.eShareWarZoneTitletUI)
end

--关闭UI
function ShareWarZoneTitletUI.HideUI()
	ShareWarZoneTitletUI.bIsShow = false;
	LuaClassObj.HandleUIMessage(bp_share_warzone_title, "HideUI");

	UIManager.Hide(eUIType.eShareWarZoneTitletUI)
end