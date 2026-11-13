-- 军团排行ui

CorpsRankUI = CorpsRankUI or {
	isOnlyShow = true,
}


-- 军团uin信息
BP_STRUCT_CorpsUinInfo = 
{
	corps_id = 0,
};

-- 军团uin列表
BP_ARRAY_Corps_RankUinList = 
{
	BP_STRUCT_CorpsUinInfo = _G.BP_STRUCT_CorpsUinInfo,
};

-- 军团概要信息
BP_STRUCT_CorpsRankInfo = 
{
	corps_id = 0,
    icon = 0,
    name = "",
    members_cnt = 0,
    max_cnt = 0,
    level = 0,
    award_id = 0,
    award_num = 0,
    score = 0,
};

-- 军团概要信息列表,一次最多传递n个,防止卡顿
BP_ARRAY_Corps_RankInfoList = 
{
	BP_STRUCT_CorpsRankInfo = _G.BP_STRUCT_CorpsRankInfo,
};

BP_STRUCT_MyCorpsRankNum = 0
BP_STRUCT_MyCorpsRankNumPro = 0
BP_STRUCT_MyCorpsRankInfo = _G.BP_STRUCT_CorpsRankInfo

--当前传送id
BP_Corps_Rank_Trans_Begin_Index = 0
BP_Corps_Rank_Trans_End_Index = 0

--当前选中类型id
BP_Crops_Rank_Now_Type = 0

BP_Corps_Rank_Current_ID = 0

-- 注册Widget
function bp_corps_rank_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_corps_rank,
    	{{Path="/Game/UMG/UI_Logic/Corps/CorpsRank_BP.CorpsRank_BP_C", Container="Default", ZOrder = BP_ENUM_UI_OWN_CORPS_ZORDER + 1}},
    	{"Lobby"},
		false,
		false,
		true
  	);

  	CorpsBaseUI.RegisterCallBacks(CorpsBaseUI.PageRank, EventCorpsRankShowUI,EventCorpsRankHideUI);
end

local function CorpsRankEventHandler(eventType, eventID, vars)
	if eventType ~= EVENTTYPE_CORPS then
		return;
	end
	--列表更新
	if eventID == EVENTID_CORPS_RANK_GET_UIN then
        CorpsRankUI.InitList();
	end

	if eventID == EVENTID_CORPS_RANK_GET_INFO then
        CorpsRankUI.UpdateList();
	end

	if eventID == EVENTID_CORPS_RANK_GET_MY_INFO then
        CorpsRankUI.UpdateSelfRankInfo()
	end
end

function CorpsRankUI.Init()
	EventSystem:registEvent(EVENTTYPE_CORPS, EVENTID_CORPS_RANK_GET_UIN, CorpsRankEventHandler);
    EventSystem:registEvent(EVENTTYPE_CORPS, EVENTID_CORPS_RANK_GET_INFO, CorpsRankEventHandler);
    EventSystem:registEvent(EVENTTYPE_CORPS, EVENTID_CORPS_RANK_GET_MY_INFO, CorpsRankEventHandler);
	CorpsRankSystem.Init();
end

function CorpsRankUI.Release()
	EventSystem:unregistEvent(EVENTTYPE_CORPS, EVENTID_CORPS_RANK_GET_UIN, CorpsRankEventHandler);
	EventSystem:unregistEvent(EVENTTYPE_CORPS, EVENTID_CORPS_RANK_GET_INFO, CorpsRankEventHandler);
	EventSystem:unregistEvent(EVENTTYPE_CORPS, EVENTID_CORPS_RANK_GET_MY_INFO, CorpsRankEventHandler);
	CorpsRankSystem.Release();
end

function CorpsRankUI.InitList()
	log("CorpsRankUI.InitList()")
	BP_ARRAY_Corps_RankUinList = {}

	if BP_Crops_Rank_Now_Type == 0 then
		for k,v in pairs(CorpsWeekRankList) do
			if v and v.uid then
				local corp_info = {}
				corp_info.corps_id = tonumber(v.uid)
				BP_ARRAY_Corps_RankUinList[v.rank_no] = corp_info
			end
		end
	else
		for k,v in pairs(CorpsSeasonRankList) do
			if v and v.uid then
				local corp_info = {}
				corp_info.corps_id = tonumber(v.uid)
				BP_ARRAY_Corps_RankUinList[v.rank_no] = corp_info
			end
		end
	end

	LuaClassObj.HandleUIMessage(bp_corps_rank, "InitRankList");

	CorpsRankSystem.SendGetRankAward(102)
	CorpsRankSystem.SendGetMyRankData(101)

	--隐藏小红点
	Is_Corps_Rank_Have_Award = false
	EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_APPLYLIST);

end

function CorpsRankUI.UpdateList()
	BP_ARRAY_Corps_RankInfoList = {}
	local defaultName = FuncUtil.LocalizeResFormat(6881);
	if BP_Crops_Rank_Now_Type == 0 then
		for i=BP_Corps_Rank_Trans_Begin_Index,BP_Corps_Rank_Trans_End_Index do
			if CorpsWeekRankList[i] then
				local v = {}
				if CorpsRankInfoList[tonumber(CorpsWeekRankList[i].uid)] then
					v = CorpsRankInfoList[tonumber(CorpsWeekRankList[i].uid)]
				else
		            v.name = defaultName;
		            v.max_cnt = 0
		            v.corps_id = tonumber(CorpsWeekRankList[i].uid)
		            v.icon = 0
		            v.members_cnt = 0
		            v.level = 0
				end
				v.award_id = 0
				v.award_num = 0
				v.score = CorpsWeekRankList[i].score
				local cfg = CorpsRankSystem.GetRankAwardCfg( i )
				if cfg then
					v.award_id = cfg.WeekAwardID
					v.award_num = cfg.WeekAwardNum
				end
				BP_ARRAY_Corps_RankInfoList[#BP_ARRAY_Corps_RankInfoList + 1] = v
			end
		end
	else
		for i=BP_Corps_Rank_Trans_Begin_Index,BP_Corps_Rank_Trans_End_Index do
			if CorpsSeasonRankList[i] then
				local v = {}
				if CorpsRankInfoList[tonumber(CorpsSeasonRankList[i].uid)] then
					v = CorpsRankInfoList[tonumber(CorpsSeasonRankList[i].uid)]
				else
					v.name = defaultName;
		            v.max_cnt = 0
		            v.corps_id = tonumber(CorpsSeasonRankList[i].uid)
		            v.icon = 0
		            v.members_cnt = 0
		            v.level = 0
				end
				v.award_id = 0
				v.award_num = 0
				v.score = CorpsSeasonRankList[i].score
				local cfg = CorpsRankSystem.GetRankAwardCfg( i )
				if cfg then
					if cfg.SeasonAwardNum2 > 0 then
						v.award_id = cfg.SeasonAwardID2
						v.award_num = cfg.SeasonAwardNum2
					else
						v.award_id = cfg.SeasonAwardID1
						v.award_num = cfg.SeasonAwardNum1
					end
				end

				BP_ARRAY_Corps_RankInfoList[#BP_ARRAY_Corps_RankInfoList + 1] = v
			end
		end
	end

	--log_tree("BP_ARRAY_Corps_RankInfoList =",BP_ARRAY_Corps_RankInfoList)
	LuaClassObj.HandleUIMessage(bp_corps_rank, "UpdateRankList");
end

function EventCorpsRankShowUI()	
	log("EventCorpsRankShowUI");
	CorpsRankUI.Init();
	LuaClassObj.HandleDynamicCreation(bp_corps_rank);
	LuaClassObj.HandleUIMessage(bp_corps_rank, "UIShow");
	UIManager.Show(eUIType.eCorpsRankUI)
	CorpsRankUI.ChangeIsOnlyShow(true)
end

function EventCorpsRankTypeChange()
	log("EventCorpsRankTypeChange() BP_Crops_Rank_Now_Type ="..BP_Crops_Rank_Now_Type)
	if BP_Crops_Rank_Now_Type == 0 then
		CorpsRankSystem.SendGetWeekRankData()

		--数据上报
		ClientSendBAReport(BP_BA_CORP_RANK_WEEK, 0);
	else
		CorpsRankSystem.SendGetSeasonRankData()
		--数据上报
		ClientSendBAReport(BP_BA_CORP_RANK_SEASON, 0);
	end

	CorpsRankUI.UpdateSelfRankInfo()
end

function CorpsRankUI.UpdateSelfRankInfo()
	--自己的军团信息

	local week_info, season_info = CorpsRankSystem.GetMyRankInfo()
	local my_score = 0
	if BP_Crops_Rank_Now_Type == 0 then
		BP_STRUCT_MyCorpsRankNum = week_info.rank_no
		BP_STRUCT_MyCorpsRankNumPro = week_info.rank_rate
		my_score = week_info.score
	else
		BP_STRUCT_MyCorpsRankNum = season_info.rank_no
		BP_STRUCT_MyCorpsRankNumPro = season_info.rank_rate
		my_score = season_info.score
	end

	local week_award_cfg, season_award_cfg = CorpsRankSystem.GetMyCorpsAwardInfo()
	local temp_award_id,temp_award_num
	if BP_Crops_Rank_Now_Type == 0 then
		if week_award_cfg then
			temp_award_id = week_award_cfg.WeekAwardID
			temp_award_num = week_award_cfg.WeekAwardNum
		end
	else
		if season_award_cfg then
			if season_award_cfg.SeasonAwardNum2 == 0 then
				temp_award_id = season_award_cfg.SeasonAwardID1
				temp_award_num = season_award_cfg.SeasonAwardNum1
			else
				temp_award_id = season_award_cfg.SeasonAwardID2
				temp_award_num = season_award_cfg.SeasonAwardNum2
			end
		end
	end

	local levelCfg = Client.GetTableData("CorpsLevel", DataMgr.corpsInfo.level);

	BP_STRUCT_MyCorpsRankInfo = 
	{
		corps_id = DataMgr.corpsInfo.id,
	    icon = DataMgr.corpsInfo.icon,
	    name = DataMgr.corpsInfo.name,
	    members_cnt = DataMgr.corpsInfo.memberNum,--#DataMgr.corpsInfo.corpsMemberList,
	    max_cnt = levelCfg.MemberLimit or 0,
	    level = DataMgr.corpsInfo.level,
	    award_id = temp_award_id,
	    award_num = temp_award_num,
	    score = my_score,
	}
	LuaClassObj.HandleUIMessage(bp_corps_rank, "UpdateSelfRankInfo");
end

--获取下一批排行信息
function EventCorpsRankGetNextInfo()

	log(" BP_Corps_Rank_Trans_Begin_Index ====="..BP_Corps_Rank_Trans_Begin_Index)
	log(" BP_Corps_Rank_Trans_End_Index ====="..BP_Corps_Rank_Trans_End_Index)

    CorpsRankSystem.SendGetRankInfoData(BP_Corps_Rank_Trans_Begin_Index, BP_Corps_Rank_Trans_End_Index, BP_Crops_Rank_Now_Type == 0)
end

function EventCorpsRankHideUI()
	log("EventCorpsRankHideUI");
	CorpsRankUI.Release();
	UIManager.Hide(eUIType.eCorpsRankUI)
	LuaClassObj.HandleUIMessage(bp_corps_rank, "UIHide");
end

function EventCorpsRankShowCorpsDetails()
	log("EventCorpsRankShowCorpsDetails");
	CorpsInvitationUI.RequestShowUI(BP_Corps_Rank_Current_ID, CorpsInvitationUI.isNoButton)
		-- CorpsInvitationUI.RequestShowUI(BP_Corps_Rank_Current_ID, 1)

end

function CorpsRankUI.ChangeIsOnlyShow(isOnlyShow)
	log("CorpsRankUI.ChangeIsOnlyShow:" .. tostring(isOnlyShow))
	CorpsRankUI.isOnlyShow = isOnlyShow
	if CorpsRankUI.isOnlyShow then
		LuaClassObj.HandleUIMessageNoFetch(bp_corps_rank, "UIOnlyShow");
	else
		LuaClassObj.HandleUIMessageNoFetch(bp_corps_rank, "UIOnlyHide");
	end
end

function CorpsRankUI.GetStatus()
	log("CorpsRankUI.GetStatus:" .. tostring(CorpsRankUI.isOnlyShow))
	return {isOnlyShow = CorpsRankUI.isOnlyShow}
end

function CorpsRankUI.RecoverStatus(status)
	if status and status.isOnlyShow ~= nil then
		log("CorpsRankUI.RecoverStatus:" .. tostring(status.isOnlyShow))
		CorpsRankUI.ChangeIsOnlyShow(status.isOnlyShow)
	end

end