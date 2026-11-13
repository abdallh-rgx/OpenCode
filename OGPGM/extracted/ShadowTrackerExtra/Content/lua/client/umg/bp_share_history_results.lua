--分享历史结算数据
ShareHistoryResultsUI = ShareHistoryResultsUI or
{

}

--与BP_STRUCT_RoleInfoHistoryRecordDetail相同
BP_STRUCT_ShareHistoryResults_DetailInfo =
{
	battle_id = 0,
	battle_type = 0,
	battle_time = 0,
	person_rank = 0,				--单人模式排名
	total_player_count = 0,			--单人模式总人数
	team_rank = 0,					--多人模式排名
	total_team_count = 0,			--多人模式总人数
	rating = 0,
	change_rating = 0,				--总积分变化
	change_kill_rating = 0,			--击败积分变化
	change_win_rating = 0,			--生存积分变化
	segment = 0,
	reason = "",					--win or dead
	add_exp = 0,					--增加经验
	add_gold = 0,					--增加金币
	final_level = "",				--评价分数
	final_score = "",				--单排取这里分数，小数
	reason_result = "",				--输赢结果显示
	battle_typename = "",			--战斗模式
	wisdom = "",					--名言
	is_solo = false,				--是否单人模式
};

--与BP_STRUCT_RoleInfoHistoryRadarInfo相同
BP_STRUCT_ShareHistoryResults_RadarInfo =
{
	survive_score = "",
	kill_score = "",
	supply_score = "",
	hurt_score = "",
	support_score = "",
};

--与BP_STRUCT_RoleInfoHistoryTeammateInfo相同，多了一些数据
BP_STRUCT_ShareHistoryResults_TeammateInfo =
{
	name = "",
	uid = "",
	damage_amount = 0,				--伤害值，小数转整数
	assist_num = 0,					--救援数
	survive_time = "",				--生存时间，给的秒转分钟
	kill = 0,						--击败数
	heal_amount = 0,				--治疗量，小数转整数
	BP_ARRAY_TitleIDList =			--狗牌列表
	{
		title_id = 0,
	},
	final_score = "",				--多排取这里分数，小数转一位
	is_mvp = false,					--是否mvip
	gender = 0,						--性别
	
	is_myself = false,				--是否自己
};

--与BP_ARRAY_RoleInfoHistoryTeammateInfoList相同
BP_ARRAY_ShareHistoryResults_TeammateInfoList =
{
	BP_STRUCT_ShareHistoryResults_TeammateInfo=_G.BP_STRUCT_ShareHistoryResults_TeammateInfo, --定义结构体数组，这种写法要作为规范规定下来
};

BP_ShareHistoryResultsPath = "";

function bp_share_history_results_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_share_history_results,
		{
			{Path="/Game/UMG/UI_Logic/Share/Share_History_Results_BP.Share_History_Results_BP_C", Container="Top", ZOrder=BP_ENUM_UI_SHARE_RANK_ZORDER},
		},
		{"Lobby"},
		false,
		false,
		true
	);
end	 

local  function ShareReqPerson(channel_type)
	ShareMgr.ShareSuccReq(5, channel_type);
end 

local function OnShareSucessEventHandler(eventType, eventID, vars)
    local hasApp = DataMgr.HasInstallPlatApp();
	if hasApp ==  true then
		LuaClassObj.HandleUIMessage(bp_share_history_results, "UIHide");	
	end
	EventSystem:unregistEvent(EVENTTYPE_SHARE, EVENTID_SHARE_SUCESSFUL, OnShareSucessEventHandler);
end

function ShareHistoryResultsUI:ShowSharePanel()
	LuaClassObj.HandleDynamicCreation(bp_share_history_results);
	ShareUI:SetShareInfo(5);
	BP_STRUCT_ShareHistoryResults_DetailInfo = BP_STRUCT_RoleInfoHistoryRecordDetail;
	BP_STRUCT_ShareHistoryResults_RadarInfo = BP_STRUCT_RoleInfoHistoryRadarInfo;
	BP_ARRAY_ShareHistoryResults_TeammateInfoList = {};
	for k,v in pairs(BP_ARRAY_RoleInfoHistoryTeammateInfoList) do
		if v.uid == BP_HistoryDetail_SelfID then
			v.is_myself = true;
		else
			v.is_myself = false;
		end
		table.insert(BP_ARRAY_ShareHistoryResults_TeammateInfoList, v);
	end
	EventSystem:registEvent(EVENTTYPE_SHARE, EVENTID_SHARE_SUCESSFUL, OnShareSucessEventHandler);
	LuaClassObj.HandleUIMessage(bp_share_history_results, "UIShow");
end

function EventShareHistoryResultsHide()
	EventSystem:unregistEvent(EVENTTYPE_SHARE, EVENTID_SHARE_SUCESSFUL, OnShareSucessEventHandler);
end

function EventSetInfo_Push()
end

function EventFetchInfo()
end


--分享facebook 复用QQ
function EventResultsShareClickFacebookBtn()	
	log("[HHF]EventResultsShareClickFacebookBtn");
	if Client.IsInstallQQ(NetInterface) == false then 
		--你还没有安装Facebook，无法使用此功能
		DataMgr.ShowNoticeByID(4005);
		return;
	end
		
	ShareMgr:shareQQWithPhoto(MEDIA_TAG_SHARE_CHIJI, "", BP_ShareHistoryResultsPath, ShareType.Moment);
	ClientSendBAReport(BP_BA_SHARE_QQSPACE, 0);
	ShareReqPerson(BP_BA_SHARE_FACEBOOK);
end

--分享twitter
function EventResultsShareClickTwitterBtn()	
	log("[HHF]EventResultsShareClickTwitterBtn");
	if Client.IsInstallTwitter(NetInterface) == false then 
		--你还没有安装twitter，无法使用此功能
		--DataMgr.ShowNoticeByID(4062);
		--return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_ShareHistoryResultsPath, "", "", BP_ENUM_PLAYFORM_TWITTER);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_TW_COUNT, 0);
	ShareReqPerson(BP_BA_SHARE_TWITTER);
end

--分享微信朋友圈
function EventResultsShareClickWXZoneBtn()	
	log("[HHF]EventResultsShareClickWXZoneBtn");
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
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_ShareHistoryResultsPath, "", "", BP_ENUM_PLAYFORM_WX);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_WX_ZONE_COUNT, 0);
	ShareReqPerson(BP_BA_SHARE_WX_ZONE);
end

--分享VK
function EventResultsShareClickVKBtn()	
	log("[HHF]EventResultsShareClickVKBtn");
	if Client.IsInstallVK(NetInterface) == false then 
		--你还没有安装VK，无法使用此功能
		DataMgr.ShowNoticeByID(4310);
		return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_ShareHistoryResultsPath, "", "", BP_ENUM_PLAYFORM_VK);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_VK_COUNT, 0);
	ShareReqPerson(BP_BA_SHARE_VK);
end

--分享Line
function EventResultsShareClickLineBtn()	
	log("[HHF]EventResultsShareClickLineBtn");
	if Client.IsInstallLine(NetInterface) == false then 
		--你还没有安装Line，无法使用此功能
		DataMgr.ShowNoticeByID(4985);
		return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_ShareHistoryResultsPath, "", "", BP_ENUM_PLAYFORM_LINE);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_LINE_COUNT, 0);
	ShareReqPerson(BP_BA_SHARE_LINE);
end

--分享QQ
function EventResultsShareClickQQByiTOPBtn()	
	log("EventResultsShareClickQQByiTOPBtn");
	if Client.IsInstallQQByiTOP(NetInterface) == false then 
		--你还没有安装QQ，无法使用此功能
		DataMgr.ShowNoticeByID(110125);
		return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_ShareHistoryResultsPath, "", "", BP_ENUM_PLAYFORM_QQByiTOP);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_QQByiTOP_COUNT, 0);
	ShareReqPerson(BP_BA_SHARE_QQByiTOP);
end