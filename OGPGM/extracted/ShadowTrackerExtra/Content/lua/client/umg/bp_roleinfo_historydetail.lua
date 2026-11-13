--个人信息历史战绩详情UI
RoleInfoHistoryDetailUI = RoleInfoHistoryDetailUI or
{
	ReportComplaintTeamList = {};
	IsShow = false;
}

--注册Widget
function bp_roleinfo_historydetail_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_roleinfo_historydetail,
		{{Path="/Game/UMG/UI_Logic/RoleInfo/RoleInfo_HistoryDetail_BP.RoleInfo_HistoryDetail_BP_C", Container="Default", ZOrder=BP_ENUM_UI_ROLEINFO_ZORDER+10}},
		{"Lobby"},
		false,
		false,
		true
	);
    

    EventSystem:registEvent(EVENTTYPE_BIND_INTL, EVENTID_VERSION_UPDATE_IOS_CHECK, RoleInfoHistoryDetailUI.HandleIOSCheck);

end

function RoleInfoHistoryDetailUI.HandleIOSCheck()
	-- body
    if GlobalData:IsIOSCheck() then
        LuaClassObj.SubCollapseWidgetList(bp_roleinfo_historydetail,
            "RoleInfo_HistoryDetail_BP_C",
            {
                "Overlay_ShareBtn",
                "FlauntBox",
                "Overlay_ShareTips",
            }
        );
        LuaClassObj.HandleCollapseWidgetList(bp_roleinfo_historydetail, "RoleInfo_HistoryDetail_BP_C");
    end
    
end

--历史战绩详情数据(定义结构体：当且仅当以BP_STRUCT_开头的table能作为结构体给蓝图访问)
BP_STRUCT_RoleInfoHistoryRecordDetail =
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
	is_segment_protect = false,		--是否段位保护
	murder_name = "",				--杀我的人名字
	murder_isAI = false,			--杀我的人是否是AI
};

--历史战绩详情队员数据
BP_STRUCT_RoleInfoHistoryTeammateInfo =
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
	is_friend = false,				--是否是自己好友
};

--历史战绩雷达详情数据
BP_STRUCT_RoleInfoHistoryRadarInfo =
{
	survive_score = "",
	kill_score = "",
	supply_score = "",
	hurt_score = "",
	support_score = "",
};

--历史战绩被查看玩家基本信息
BP_STRUCT_RoleInfoHistoryRoleBasicInfo =
{
	role_name = "",
	role_id = "",
	role_sex = 0,
	role_image = "",
	role_avatar_frame = 0,
};

--历史战绩详情队员数据列表(定义结构体数组：当且仅当以BP_ARRAY_开头的table能作为数组给蓝图访问)
BP_ARRAY_RoleInfoHistoryTeammateInfoList =
{
	BP_STRUCT_RoleInfoHistoryTeammateInfo=_G.BP_STRUCT_RoleInfoHistoryTeammateInfo, --定义结构体数组，这种写法要作为规范规定下来
};

BP_HistoryDetail_SelfID = "";
BP_HistoryDetail_SelfName = "";
BP_HistoryDetail_AddFriendUID = "";
BP_HistoryDetail_AddFriendGender = 0;
BP_HistoryDetail_SelfIconURL = "";
BP_HistoryDetail_SelfFrameLevel = 0;
BP_HistoryDetail_SelfGender = 0;
BP_HistoryDetail_TodayShareNum = 0;
BP_HistoryDetail_ShareGold = false;				--每日首分享是否金币奖励
BP_HistoryDetail_SegmentProtectTips = "";

function RoleInfoHistoryDetailUI.Init()
	log("RoleInfoHistoryDetailUI Init");
	LuaClassObj.HandleDynamicCreation(bp_roleinfo_historydetail);
	
	BP_HistoryDetail_SelfID = DataMgr.roleData.uid;
	BP_HistoryDetail_SelfName = DataMgr.roleData.nickName;
	BP_HistoryDetail_SelfIconURL = DataMgr.roleData.headIconUrl;
	BP_HistoryDetail_SelfFrameLevel = DataMgr.roleData.cur_avatar_box_id;
	BP_HistoryDetail_SelfGender = DataMgr.roleData.gender;
	BP_HistoryDetail_TodayShareNum = RoleInfoHistoryDetailUI.GetShareNum();
	BP_HistoryDetail_ShareGold = ShareAwardMgr.IsAllAwardHasGet();
	if BP_HistoryDetail_SegmentProtectTips == "" then
		BP_HistoryDetail_SegmentProtectTips = DataMgr.GetMultiLineMsgByID(105011);
	end
	
	RoleInfoHistoryDetailUI.ReportComplaintTeamList = {};
	
	RoleInfoHistoryDetailUI.UnifyAllData();
	RoleInfoHistoryDetailUI.UpdateHistoryDetail();
end

function RoleInfoHistoryDetailUI.Release()
	log("RoleInfoHistoryDetailUI Release");
	BP_HistoryDetail_SelfID = "";
	BP_HistoryDetail_SelfName = "";
	BP_HistoryDetail_SelfIconURL = "";
	BP_HistoryDetail_SelfFrameLevel = 0;
	BP_HistoryDetail_SelfGender = 0;
	BP_HistoryDetail_TodayShareNum = 0;
	BP_HistoryDetail_ShareGold = false;
	
	RoleInfoHistoryDetailUI.IsShow = false;
	
	RoleInfoHistoryDetailUI.ReportComplaintTeamList = {};
end

function RoleInfoHistoryDetailUI.Hide()
	log("RoleInfoHistoryDetailUI Hide");
end

function RoleInfoHistoryDetailUI.UnifyAllData()
	log("RoleInfoHistoryDetailUI UnifyAllData");
	
	BP_STRUCT_RoleInfoHistoryRecordDetail = {};
	BP_STRUCT_RoleInfoHistoryRecordDetail = FuncUtil:CopyTable(RoleInfoHistoryDetailSystem.HistoryRecordDetail);
	-- log_tree("BP_STRUCT_RoleInfoHistoryRecordDetail=", BP_STRUCT_RoleInfoHistoryRecordDetail);
	
	BP_ARRAY_RoleInfoHistoryTeammateInfoList = {};
	for i=1,#RoleInfoHistoryDetailSystem.HistoryTeammateInfoList do
		BP_ARRAY_RoleInfoHistoryTeammateInfoList[i] = FuncUtil:CopyTable(RoleInfoHistoryDetailSystem.HistoryTeammateInfoList[i]);
	end
	-- log_tree("BP_ARRAY_RoleInfoHistoryTeammateInfoList=", BP_ARRAY_RoleInfoHistoryTeammateInfoList);
	
	BP_STRUCT_RoleInfoHistoryRadarInfo = {};
	BP_STRUCT_RoleInfoHistoryRadarInfo = FuncUtil:CopyTable(RoleInfoHistoryDetailSystem.HistoryRadarInfo);
	-- log_tree("BP_STRUCT_RoleInfoHistoryRadarInfo", BP_STRUCT_RoleInfoHistoryRadarInfo);
	
	BP_STRUCT_RoleInfoHistoryRoleBasicInfo = {};
	local role_info = RoleInfoUI.RoleInfoToHistoryDetail();
	BP_STRUCT_RoleInfoHistoryRoleBasicInfo = FuncUtil:CopyTable(role_info);
	-- log_tree("BP_STRUCT_RoleInfoHistoryRoleBasicInfo", BP_STRUCT_RoleInfoHistoryRoleBasicInfo);
end

function RoleInfoHistoryDetailUI.UpdateHistoryDetail()
	log("RoleInfoHistoryDetailUI UpdateHistoryDetail");
	
	if LuaClassObj ~= nil then
		LuaClassObj.HandleUIMessage(bp_roleinfo_historydetail, "UIShow");
		UIManager.Show(eUIType.eRoleInfoHistoryDetailUI)
	end
end

function RoleInfoHistoryDetailUI.GetShareNum()
	if ShareAwardMgr.IsTodayShareDone() then
		return 1;
	else
		return 0;
	end
end

function RoleInfoHistoryDetailUI.UpdateShareUI()
	BP_HistoryDetail_TodayShareNum = RoleInfoHistoryDetailUI.GetShareNum();
	BP_HistoryDetail_ShareGold = ShareAwardMgr.IsAllAwardHasGet();
	LuaClassObj.HandleUIMessage(bp_roleinfo_historydetail, "SetShareBtnState");
	log("BP_HistoryDetail_TodayShareNum = "..BP_HistoryDetail_TodayShareNum);
	if BP_HistoryDetail_ShareGold then
		log("BP_HistoryDetail_ShareGold = true");
	else
		log("BP_HistoryDetail_ShareGold = false");
	end
end

function RoleInfoHistoryDetailUI.GetTeamMateListToComplaint()
	log("RoleInfoHistoryDetailUI GetTeamMateListToComplaint");
	
	RoleInfoHistoryDetailUI.ReportComplaintTeamList = {};
	for k,v in pairs(BP_ARRAY_RoleInfoHistoryTeammateInfoList) do
		local teamItem = {};
		if v.name ~= nil then
			teamItem.Name = v.name;
		end
		table.insert(RoleInfoHistoryDetailUI.ReportComplaintTeamList, teamItem);
	end
	ComplaintUI:CacheTeamMateList(RoleInfoHistoryDetailUI.ReportComplaintTeamList);
end

function RoleInfoHistoryDetailUI.GetIsShow()
	-- log("RoleInfoHistoryDetailUI GetIsShow");
	
	return RoleInfoHistoryDetailUI.IsShow;
end

function RoleInfoHistoryDetailUI.GetPlayerNums()
	-- log("RoleInfoHistoryDetailUI GetPlayerNums");
	
	return BP_STRUCT_RoleInfoHistoryRecordDetail.total_player_count;
end

function RoleInfoHistoryDetailUI.GetBattleID()
	-- log("RoleInfoHistoryDetailUI GetBattleID");
	
	return BP_STRUCT_RoleInfoHistoryRecordDetail.battle_id;
end





function EventRoleInfoHistoryDetailRelease()
	RoleInfoHistoryDetailUI.Release();
end

function EventRoleInfoHistoryShareResults()
	ShareHistoryResultsUI:ShowSharePanel();
end

function EventRoleInfoHistoryShareRanking()
	ShareHistoryRankingUI:ShowSharePanel();
end

function EventRoleInfoHistoryDetailAddFriend()
	log("EventRoleInfoHistoryDetailAddFriend");
	log("BP_HistoryDetail_AddFriendUID = "..BP_HistoryDetail_AddFriendUID);
	log("BP_HistoryDetail_AddFriendGender = "..BP_HistoryDetail_AddFriendGender);
	-- if BP_HistoryDetail_AddFriendGender == 1 then
	FriendSystem.AddFriend(BP_HistoryDetail_AddFriendUID, BP_ENUM_ADD_FRIEND_FROM_ROLE_INFO,9);
	-- elseif BP_HistoryDetail_AddFriendGender == 2 then
	-- 	FriendSystem.AddFriend(BP_HistoryDetail_AddFriendUID, BP_ENUM_ADD_FRIEND_FROM_ROLE_INFO,10);
	-- end
end

function EventRoleInfoHistoryDetailReport()
	log("EventRoleInfoHistoryDetailReport");
	local MyName = "";
	for k,v in pairs(BP_ARRAY_RoleInfoHistoryTeammateInfoList) do
		if v.uid == BP_HistoryDetail_SelfID then
			MyName = v.name;
			break;
		end
	end
	
	ComplaintUI:CacheEnemyInfo(BP_STRUCT_RoleInfoHistoryRecordDetail.murder_name, BP_STRUCT_RoleInfoHistoryRecordDetail.murder_isAI, MyName);
	ComplaintUI:Init();
end

function EventRoleInfoHistoryDetail_Hide()
	UIManager.Hide(eUIType.eRoleInfoHistoryDetailUI)
end







