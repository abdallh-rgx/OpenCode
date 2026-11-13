UnknowPassMissionUI = UnknowPassMissionUI or
{
	IsShowDayMission = true,

	-- 周任务刷新时间戳
	weekMissionTimestamp = 0,
	weekMissionLeftTime = 0,

	weekLeftTimeRefreshTimer = nil,
	isShowing = false,
	LAST_REQ_MALL_TIME = 0,
	isNewWeek = false;	-- 新的一周
	weekIndexKey = 2537;
}


BP_UnknowPass_Mission_Season_Index = 1;

BP_UnknowPass_CurrentGetMissionTaskId = 0;
BP_UnknowPass_CurrentGetMissionWeekIndex = 1;

BP_UnknowPass_MissionWeekCurrentIndex = 1;
BP_UnknowPass_MaxMissionWeekCount = 1;

-- 是否购买通行证按钮
BP_UnknowPass_Mission_IsBuyElitePass = false;

-- 记录更新数据的时间戳，用于计算日任务倒计时
BP_UnknowPass_Mission_UpdateInfoTime = 0;

BP_UnknowPass_Mission_NotFinish = 0;  --未完成
BP_UnknowPass_Mission_Finished = 1;  --已完成
BP_UnknowPass_Mission_HasGet = 2;   --已领取

BP_UnknowPass_Mission_SeasonName = "";
BP_UnknowPass_Mission_SeasonTime = "";

BP_UnknowPass_ShowDayReddot = false;
BP_UnknowPass_ShowWeekReddot = false;

-- 周任务的刷新时间
BP_UnknowPass_Mission_WeekLeftTime = "00H 00M";
BP_UnknowPass_Mission_IsShowWeekLeftTime = true;

-- 每日任务
BP_STRUCT_UnknowPass_Day_Mission_Info =
{
	isDayReward = 0,
	title = "",
	desc = "",
	process = "0/0",
	date = "2018.6.1",
	taskId = 0,
	status = BP_UnknowPass_Mission_NotFinish,
	score = 0,
	refreshTime = 0,
	isRefreshed = false,
	leftTime = 0,   -- 剩余秒数
    immFinishItemNum = 0,
    isImmFinishItemEnough = false,
	
	--每日奖励
	dayRewardItemId1 = 0,
	dayRewardItemIcon1 = "",
	dayRewardItemCount1 = 0,
	dayRewardItemId2 = 0,
	dayRewardItemIcon2 = "",
	dayRewardItemCount2 = 0,
};

BP_STRUCT_WeekTab_Reddot_Info = 
{
	weekIndex = 1,
	showReddot = false,
}

-- 每日任务列表
BP_ARRAY_UnknowPass_Day_Mission_List = 
{
	BP_STRUCT_UnknowPass_Day_Mission_Info = _G.BP_STRUCT_UnknowPass_Day_Mission_Info,
};
BP_ARRAY_UnknowPass_Day_Reward_Mission_List = 
{
	BP_STRUCT_UnknowPass_Day_Mission_Info = _G.BP_STRUCT_UnknowPass_Day_Mission_Info,
};

-- 挑战任务
BP_STRUCT_UnknowPass_Week_Mission_Info =
{
	title = "",
	desc = "",
	process = "0/0",
	isEliteMission = false;
	taskId = 0,
	weekIndex = 0,
	status = BP_UnknowPass_Mission_NotFinish,
	score = 0,
	isOpen = false,  -- 是否开启，若选择的周数大于当前周，则不开启
	sort = 0,
    
    immFinishItemNum = 0,
    isImmFinishItemEnough = false,
};

-- 挑战任务列表
BP_ARRAY_UnknowPass_Week_Mission_List = 
{
	BP_STRUCT_UnknowPass_Week_Mission_Info = _G.BP_STRUCT_UnknowPass_Week_Mission_Info,
};

--用来快速查询周任务信息
local UnknowPassWeekMissionMap = {}

-- 周页签红点
BP_ARRAY_UnknowPass_WeekTabReddot_List =
{
	BP_STRUCT_WeekTab_Reddot_Info = _G.BP_STRUCT_WeekTab_Reddot_Info,
};

BP_UnknowPass_Mission_Box_Finish = 0 -- 本周已完成多少个
BP_UnknowPass_Mission_Box_Count = 0 -- 本周一共有多少个
BP_UnknowPass_Mission_Box_Tip = "" -- 提示文字
BP_UnknowPass_Mission_Box_Status = 0 -- 0 不可领，1 可领，2 已领

BP_UnknowPass_Mission_Daily_Reward_CanGet = ""
BP_UnknowPass_Mission_Daily_Reward_Geted = ""

BP_UnknowPass_Mission_ImmFinish_Item_Num = 0

BP_UnknowPass_Mission_All_Task_CanGet = false;

-- 注册widget
function bp_unknow_pass_mission_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_unknow_pass_mission,
	{
		{Path="/Game/UMG/UI_Logic/Lobby/UnknowPass_Mission_Logic_BP.UnknowPass_Mission_Logic_BP_C", Container="Default", ZOrder=0},
		{Path="/Game/UMG/UI_Logic/UnknowPass/UnknowPass_week_Mission_BP.UnknowPass_week_Mission_BP_C", Container="Default", ZOrder=2},
	},
	{"UnknowPass","Lobby"},
	false,
	false
	);

	EventSystem:registEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_INFO_UPDATE, UnknowPassMissionUI.OnInfoUpdate)
end

function UnknowPassMissionUI.Init()
	UnknowPassMissionUI.UpdateDayMissionList();
	UnknowPassMissionUI.InitDayMissionList();
	UnknowPassMissionUI.IsShowDayMission = true;
	BP_UnknowPass_Mission_Daily_Reward_CanGet = Client.GetTableData("LocalizeRes", 750001).TextValue;
	BP_UnknowPass_Mission_Daily_Reward_Geted = Client.GetTableData("LocalizeRes", 750002).TextValue;

	BP_UnknowPass_CurrentGetMissionWeekIndex = UnknowPassSystem.Data.cur_week_index or 1;
end

function UnknowPassMissionUI.Show()
	LuaClassObj.HandleUIMessage(bp_unknow_pass_mission, "UIShow");
	UIManager.Show(eUIType.eUnknowPassMissionUI);
	UnknowPassMissionUI.StartTimer();
	UnknowPassMissionUI.UpdateWeekLeftTime();
	UnknowPassMissionUI.isShowing = true

	local curTime = FuncUtil.GetServerTimeInSec()

	-- 每隔5分钟重新请求一次商店简约数据
	if curTime - UnknowPassMissionUI.LAST_REQ_MALL_TIME > 300 then
		MallSystem.GetMallAllItemsSimpleInfo();
		JumpUtils.RequestJumpMapInfo();
		UnknowPassMissionUI.LAST_REQ_MALL_TIME = curTime
	end
	UnknowPassMissionUI.UpdateAllMissionButton()
end

function UnknowPassMissionUI.Hide()
	UnknowPassMissionUI.isShowing = false
	UIManager.Hide(eUIType.eUnknowPassMissionUI);
	LuaClassObj.HandleUIMessage(bp_unknow_pass_mission, "UIHide");
	UnknowPassMissionUI.StopTimer();
end

function UnknowPassMissionUI.Release()
	UnknowPassMissionUI.Hide();
end

function UnknowPassMissionUI.StartTimer()
	UnknowPassMissionUI.StopTimer();

	UnknowPassMissionUI.weekLeftTimeRefreshTimer = Timer.InsertTimer(60, UnknowPassMissionUI.UpdateWeekLeftTime, true);
end

function UnknowPassMissionUI.StopTimer()
	if UnknowPassMissionUI.weekLeftTimeRefreshTimer then
		Timer.RemoveTimer(UnknowPassMissionUI.weekLeftTimeRefreshTimer);
		UnknowPassMissionUI.weekLeftTimeRefreshTimer = nil;
	end
end

function UnknowPassMissionUI.UpdateWeekLeftTime()
	local leftTime = UnknowPassMissionUI.weekMissionLeftTime - os.difftime(FuncUtil.GetServerTimeInSec(), UnknowPassMissionUI.weekMissionTimestamp);
	if leftTime > 0 then
		BP_UnknowPass_Mission_WeekLeftTime = string.format(FuncUtil.GetLocalizeResStr("301154"), math.floor(leftTime/(60*60)), math.floor(leftTime/60%60));
		BP_UnknowPass_Mission_IsShowWeekLeftTime = true;
	else
		BP_UnknowPass_Mission_IsShowWeekLeftTime = false;
	end

	LuaClassObj.HandleUIMessage(bp_unknow_pass_mission, "UpdateWeekLeftTime");
end

function UnknowPassMissionUI.GetProcess(task_cfg, task_data)
	if task_cfg and task_data then
		if task_cfg.finish_type == 2 then
			if task_data.status == BP_UnknowPass_Mission_NotFinish then
				return "0/1";
			else
				return "1/1";
			end
		else
			return string.format("%d/%d", math.floor(task_data.value), math.floor(task_cfg.finish_value));
		end
	else
		return "";
	end
end

function UnknowPassMissionUI.UpdateDayMissionList()
	log("[HHF]UnknowPassMissionUI.UpdateDayMissionList");
	UnknowPassUI.showDayAward = false;
	BP_ARRAY_UnknowPass_Day_Mission_List = {};
	
	--sami 每日奖励任务
	local rewardTask = 
	{
		isDayReward = 1,
		title = "",
		desc = "",
		process = "0/0",
		date = "2018.6.1",
		taskId = 0,
		status = BP_UnknowPass_Mission_NotFinish,
		score = 0,
		refreshTime = 0,
		isRefreshed = false,
		leftTime = 0,   -- 剩余秒数
        immFinishItemNum = 0,
        isImmFinishItemEnough = false,
		
		--每日奖励
		dayRewardItemId1 = 0,
		dayRewardItemIcon1 = "",
		dayRewardItemCount1 = 0,
		dayRewardItemId2 = 0,
		dayRewardItemIcon2 = "",
		dayRewardItemCount2 = 0,
	}
	local seasonId = UnknowPassSystem.Data.base.cur_season
	local reward = {}

	for k,v in pairs(Client.GetTable("UnknowPassDailyTaskCfg")) do
	    if v.SeasonId == seasonId then
			local item = {}
			item.id = v.ItemId
			item.count = v.ItemCount
		    table.insert(reward, item);
	    end
    end
	
	if reward[1] ~= nil then
		rewardTask.dayRewardItemId1 = reward[1].id
		local cfg = Client.GetTableData("Item", reward[1].id);
		if nil ~= cfg then
			rewardTask.dayRewardItemIcon1 = cfg.ItemSmallIcon
		end
		rewardTask.dayRewardItemCount1 = reward[1].count
	end
	if reward[2] ~= nil then
		rewardTask.dayRewardItemId2 = reward[2].id
		local cfg = Client.GetTableData("Item", reward[2].id);
		if nil ~= cfg then
			rewardTask.dayRewardItemIcon2 = cfg.ItemSmallIcon
		end
		rewardTask.dayRewardItemCount2 = reward[2].count
	end
	--完成標記
	local isToday = UnknowPassSystem.Data.daily_reward_is_today
	if isToday then
		rewardTask.status = BP_UnknowPass_Mission_HasGet
	else
		UnknowPassUI.showDayAward = true;
		rewardTask.status = BP_UnknowPass_Mission_Finished
	end
	BP_ARRAY_UnknowPass_Day_Reward_Mission_List = {}
	table.insert(BP_ARRAY_UnknowPass_Day_Reward_Mission_List, rewardTask);
	--log_tree("BP_ARRAY_UnknowPass_Day_Reward_Mission_List = ", BP_ARRAY_UnknowPass_Day_Reward_Mission_List)

	local tCurDay = math.floor(FuncUtil.GetServerTimeInSec()/(60*60*24))
	if UnknowPassUI.currentDayTime ~= tCurDay then
		UnknowPassUI.currentDayTime = tCurDay
	end
	
	-- 解析每日任务列表
	if UnknowPassSystem.Data and UnknowPassSystem.Data.daily_task then
		for taskId,task in pairs(UnknowPassSystem.Data.daily_task) do
			if task.task_cfg and task.task_data then
				local leftTime = task.task_left_time - os.difftime(FuncUtil.GetServerTimeInSec(), BP_UnknowPass_Mission_UpdateInfoTime);

				-- 每日任务界面刷新周期为1分钟，小于1分钟的任务，视为过期，不再显示
				if leftTime > 60 then
                    local taskCfg = Client.GetTableData("UnknowPassMissionCfg", taskId)
					local immFinishItemNum = taskCfg.ImmFinishItemNum or 0;
					local hasItemNum = UnknowPassTreasureBoxUI.GetItemCount(taskCfg.ImmFinishItemID)
					if taskCfg.ImmFinishItemID ~= 0 then
						BP_UnknowPass_Mission_ImmFinish_Item_Num = hasItemNum
					end

					local info =
					{
						isDayReward = 0,
						title = task.task_cfg.title,
						desc = task.task_cfg.desc,--
						process = "",
						date = string.format(FuncUtil.GetLocalizeResStr("301154"), math.floor(leftTime/(60*60)), math.floor(leftTime/60%60)),
						taskId = taskId,
						status = task.task_data.status,
						score = task.task_cfg.reward_score,
						refreshTime = task.task_data.refresh_time,
						isRefreshed = task.task_data.is_refresh ~= 0,
                        immFinishItemNum = immFinishItemNum,
                        isImmFinishItemEnough = immFinishItemNum <= hasItemNum,
                        
						--每日奖励
						dayRewardItemId1 = 0,
						dayRewardItemIcon1 = "",
						dayRewardItemCount1 = 0,
						dayRewardItemId2 = 0,
						dayRewardItemIcon2 = "",
						dayRewardItemCount2 = 0,
					};
					info.process = UnknowPassMissionUI.GetProcess(task.task_cfg, task.task_data);
					table.insert(BP_ARRAY_UnknowPass_Day_Mission_List, info);

					if task.task_data.status == BP_UnknowPass_Mission_Finished then
						UnknowPassUI.showDayAward = true;
					end
				end
			end
		end

		table.sort(BP_ARRAY_UnknowPass_Day_Mission_List, function(a, b)
			if a.isDayReward == 1 then
				if a.status == BP_UnknowPass_Mission_Finished then
					return false
				else
					return false
				end
			end
			if b.isDayReward == 1 then
				if b.status == BP_UnknowPass_Mission_Finished then
					return true
				else
					return true
				end
			end
			return a.refreshTime > b.refreshTime;
		end)
	end

	UnknowPassUI.UpdateReddot();
end


function UnknowPassMissionUI.InitDayMissionList()
	LuaClassObj.HandleUIMessage(bp_unknow_pass_mission, "InitDayMissionList");
end

-- 根据任务状态，获取排序优先级 (10000 ~ 30000)
function UnknowPassMissionUI.GetSortNumberByStatus(status)
	if status == BP_UnknowPass_Mission_HasGet then
		return 1000;
	elseif status == BP_UnknowPass_Mission_NotFinish then
		return 2000;
	elseif status == BP_UnknowPass_Mission_Finished then
		return 3000;
	else
		return 0;
	end
end

function UnknowPassMissionUI.UpdateWeekMissionList()
	BP_ARRAY_UnknowPass_Week_Mission_List = {};
    UnknowPassWeekMissionMap = {}
    
	-- 解析周任务
	if UnknowPassSystem.Data.all_week_task_cfg then
        local itemNumCaches = {}
        
		for taskId,task_cfg in pairs(UnknowPassSystem.Data.all_week_task_cfg) do
			if task_cfg and task_cfg.week_index == BP_UnknowPass_CurrentGetMissionWeekIndex then
                local taskCfg = Client.GetTableData("UnknowPassMissionCfg", taskId)
                local immFinishItemNum = taskCfg.ImmFinishItemNum
                local itemID = taskCfg.ImmFinishItemID
				if itemNumCaches[itemID] == nil then
					local hasItemNum = UnknowPassTreasureBoxUI.GetItemCount(itemID)
					if itemID ~= 0 then
						BP_UnknowPass_Mission_ImmFinish_Item_Num = hasItemNum
					end
                    itemNumCaches[itemID] = hasItemNum
                end

                local task = UnknowPassSystem.Data.week_task[taskId]
                
				local info =
				{
					title = task_cfg.title,
					desc = task_cfg.desc,
					process = "",
					taskId = taskId,
					weekIndex = task_cfg.week_index,
					status = BP_UnknowPass_Mission_NotFinish,
					score = task_cfg.reward_score,
					isEliteMission = task_cfg.is_elite_task ~= 0,
					isOpen = (task_cfg.week_index <= BP_UnknowPass_MissionWeekCurrentIndex) and (task ~= nil),
					sort = -task_cfg.sort, -- 排序规则，分数越小，越靠前，所以这里取负数
                    
                    immFinishItemNum = immFinishItemNum,
                    isImmFinishItemEnough = immFinishItemNum <= itemNumCaches[itemID],
				};
				if info.isEliteMission then
					info.sort = info.sort + 10000;
				end
				
				if info.isOpen then
					info.status = task.task_data.status;
					info.process = UnknowPassMissionUI.GetProcess(task_cfg, task.task_data);
					info.sort = info.sort + UnknowPassMissionUI.GetSortNumberByStatus(info.status);
				end
                
                UnknowPassWeekMissionMap[info.taskId] = info
				table.insert(BP_ARRAY_UnknowPass_Week_Mission_List, info);
			end
		end

		--log_tree("BP_ARRAY_UnknowPass_Week_Mission_List", BP_ARRAY_UnknowPass_Week_Mission_List)

		table.sort(BP_ARRAY_UnknowPass_Week_Mission_List, function(a, b)
			if not UnknowPassSystem.IsBuyElite then
				if a.isEliteMission and not b.isEliteMission  then
					return false
				elseif not a.isEliteMission and b.isEliteMission  then
					return true
				end
			end
			return a.sort > b.sort;
		end);
	end
	
	UnknowPassUI.UpdateReddot();
end

function UnknowPassMissionUI.InitWeekMissionList()
	LuaClassObj.HandleUIMessage(bp_unknow_pass_mission, "InitWeekMissionList");
end

function UnknowPassMissionUI.UpdateMaxWeekCount()
	BP_UnknowPass_MaxMissionWeekCount = 1;

	-- 解析周任务
	if UnknowPassSystem.Data.all_week_task_cfg then
		for taskId,task_cfg in pairs(UnknowPassSystem.Data.all_week_task_cfg) do
			if task_cfg then
				if BP_UnknowPass_MaxMissionWeekCount < task_cfg.week_index then
					BP_UnknowPass_MaxMissionWeekCount = task_cfg.week_index;
				end
			end
		end
	end
end

function RefreshWeekTabRedDot()
	BP_ARRAY_UnknowPass_WeekTabReddot_List = {}
	for i = 1, BP_UnknowPass_MaxMissionWeekCount do
		local info = {weekIndex = i, showReddot = false}
		table.insert(BP_ARRAY_UnknowPass_WeekTabReddot_List, info);
	end
	if UnknowPassSystem.Data.all_week_task_cfg then
			for i = 1,  BP_UnknowPass_MaxMissionWeekCount do
				for taskId,task_cfg in pairs(UnknowPassSystem.Data.all_week_task_cfg) do
					if task_cfg and task_cfg.week_index == i then
						local task = UnknowPassSystem.Data.week_task[taskId];
						local info = {weekIndex = 1, showReddot = false};
						local redDot = false;
						if task then
							redDot = task.task_data.status == 1 and (task_cfg.is_elite_task==0 or task_cfg.is_elite_task==1 and UnknowPassSystem.IsBuyElite)
						end
						if redDot == true then
							info.weekIndex = i;
							info.showReddot = redDot;
							BP_ARRAY_UnknowPass_WeekTabReddot_List[i] = info
							break
						end
					end
			end
		end
	end
end

function UnknowPassMissionUI.UpdateBoxInfo()
	BP_UnknowPass_Mission_Box_Finish = UnknowPassSystem.Data.base.week_finish
	BP_UnknowPass_Mission_Box_Count = UnknowPassSystem.Data.weekly_reward_cfg.task_num or 0
	if UnknowPassSystem.Data.base.week_reward_status == 0 and BP_UnknowPass_Mission_Box_Count ~= 0 and BP_UnknowPass_Mission_Box_Finish >= BP_UnknowPass_Mission_Box_Count then
		UnknowPassSystem.Data.base.week_reward_status = 1;
	end
	BP_UnknowPass_Mission_Box_Status = UnknowPassSystem.Data.base.week_reward_status;
	if BP_UnknowPass_Mission_Box_Finish > BP_UnknowPass_Mission_Box_Count then
		BP_UnknowPass_Mission_Box_Finish = BP_UnknowPass_Mission_Box_Count
	end
	BP_UnknowPass_Mission_Box_Tip = FuncUtil.LocalizeResFormat(4564, BP_UnknowPass_Mission_Box_Count)
	LuaClassObj.HandleUIMessage(bp_unknow_pass_mission, "UpdateBoxInfo");
end

-- event
function UnknowPassMissionUI.OnInfoUpdate(eventType, eventID)
	log("[HHF]UnknowPassMissionUI.OnInfoUpdate");
	BP_UnknowPass_Mission_IsBuyElitePass = UnknowPassSystem.IsBuyElite;
	BP_UnknowPass_MissionWeekCurrentIndex = UnknowPassSystem.Data.cur_week_index or 1;
	BP_UnknowPass_Mission_Season_Index = UnknowPassSystem.Season;
	BP_UnknowPass_Mission_UpdateInfoTime = FuncUtil.GetServerTimeInSec();
	UnknowPassMissionUI.weekMissionTimestamp = FuncUtil.GetServerTimeInSec();
	UnknowPassMissionUI.weekMissionLeftTime = UnknowPassSystem.Data.week_task_left_refresh_time;

	UnknowPassMissionUI.UpdateMaxWeekCount();

	UnknowPassMissionUI.UpdateBoxInfo()

	UnknowPassMissionUI.UpdateDayMissionList();
	UnknowPassMissionUI.UpdateWeekMissionList();

	if UnknowPassMissionUI.IsShowDayMission then
		UnknowPassMissionUI.InitDayMissionList();
	else
		UnknowPassMissionUI.InitWeekMissionList();
	end

	if UnknowPassUI.currentWeekTime ~= tostring(BP_UnknowPass_MissionWeekCurrentIndex) then
		UnknowPassUI.currentWeekTime = tostring(BP_UnknowPass_MissionWeekCurrentIndex);
	end
	UnknowPassUI.UpdateReddot();
	UnknowPassMissionUI.UpdateAllMissionButton();
end

-- 更新一键领取按键状态
function UnknowPassMissionUI.UpdateAllMissionButton()
	if nil ~= UIManager.GetUI(eUIType.eUnknowPassMissionUI) then
		BP_UnknowPass_Mission_All_Task_CanGet = UnknowPassUI.showDayAward or UnknowPassUI.showWeekAward;
		LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass_mission, "UpdateAllMissionButton");
	end
end

function UnknowPassMissionUI.ShowAwardList(reward_list)
	UnknowPassMissionUI.Hide();
	UnknowPassUI.HideTab();
	
	UnknowPassShowAward.HideCallBack = function()
		UnknowPassUI.ShowTab();
		UnknowPassMissionUI.Show();
	end
	UnknowPassShowAward.ShowUI(UnknowPassSystem:GetAwardList(reward_list));
end

function UnknowPassMissionUI.UpdateReddot(bShowDay, bShowWeek)
	RefreshWeekTabRedDot()
	BP_UnknowPass_ShowDayReddot = bShowDay;
	BP_UnknowPass_ShowWeekReddot = bShowWeek;
	--log("UnknowPassMissionUI.UpdateReddot, showMissionReddot = " .. tostring(bShowDay or bShowWeek));
	LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass_mission, "UpdateReddot");
end

function UnknowPassMissionUI.GetWeekAwardState()
	UnknowPassUI.showWeekAward = false;
	UnknowPassMissionUI.isNewWeek = false;
	if UnknowPassSystem.Data.all_week_task_cfg then
		for taskId,task_cfg in pairs(UnknowPassSystem.Data.all_week_task_cfg) do
			if task_cfg then
				local task = UnknowPassSystem.Data.week_task[taskId];
				if task then
					if task.task_data.status == BP_UnknowPass_Mission_Finished and (task_cfg.is_elite_task==0 or
							task_cfg.is_elite_task==1 and UnknowPassSystem.IsBuyElite) then
						UnknowPassUI.showWeekAward = true;
						break;
					end
				end
			end
		end
	end

	local id = UnknowPassIntroduceUI.GetNewPassNewbieId()
	local hasNewSeason = DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_PASS, id);
	if hasNewSeason then
		UnknowPassMissionUI.isNewWeek = true;
		-- 新赛季情况之前保存的周次信息
		DataMgr.SetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_PASS, UnknowPassMissionUI.weekIndexKey,nil);
	else
		local weekIndex = DataMgr.GetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_PASS, UnknowPassMissionUI.weekIndexKey);		
		if weekIndex ~= UnknowPassSystem.Data.cur_week_index then
			UnknowPassMissionUI.isNewWeek = true;
		end
	end
end

-- bp event

function EventFetchInfo()
	
end

-- 获取奖励
function EventUnknowPassDayMissionGetClick_Push()
	-- PopUpNoticeUI.ShowNewNotice("EventUnknowPassDayMissionGetClick_Push, " .. BP_UnknowPass_CurrentGetMissionTaskId);
	UnknowPassSystem.upass_get_daily_award_req(BP_UnknowPass_CurrentGetMissionTaskId);
end

function EventUnknowPassWeekMissionGetClick_Push()
	-- PopUpNoticeUI.ShowNewNotice(string.format("week_Push, %d, %d", BP_UnknowPass_CurrentGetMissionWeekIndex, BP_UnknowPass_CurrentGetMissionTaskId));
	UnknowPassSystem.upass_get_weekly_award_req(BP_UnknowPass_CurrentGetMissionWeekIndex, BP_UnknowPass_CurrentGetMissionTaskId);
end

function EventUnknowPassCurweekAwardGetClick_Push()
	UnknowPassSystem.upass_get_curweek_award_req()
end

-- 一键领取所有任务奖励
function EventUnknowPassAllMissionGetClick()
	UnknowPassSystem.upass_task_batch_reward_req()
	GemReportUtils.ReportBtnClickEvent(GemReportUtils.SubEventName_PassBatchGetTaskAward)
end

local function OnMissionGotoClick()
	local taskId = BP_UnknowPass_CurrentGetMissionTaskId
	local taskCfg = Client.GetTableData("UnknowPassMissionCfg", taskId)
	local needNum = taskCfg.ImmFinishItemNum;


	local title = FuncUtil.GetLocalizeResStr(5077)
	local okStr = FuncUtil.GetLocalizeResStr(110036)
	local cancelStr = FuncUtil.GetLocalizeResStr(110035)
	local content = GlobalData.GetLocalizeStringWithNum(6404, 0, tostring(needNum))
	CommonMessageBoxUI.ShowPlatformPanel(2, title, content, function ()
		if UnknowPassTreasureBoxUI.GetItemCount(taskCfg.ImmFinishItemID) >= needNum then
			NetUtil.SendPriorityPkg(false, "upass_imm_finish_task_rsp", "upass_imm_finish_task_req", taskId);
		else
			local _title = FuncUtil.GetLocalizeResStr(5077)
			local _okStr = FuncUtil.GetLocalizeResStr(110036)
			local _cancelStr = FuncUtil.GetLocalizeResStr(110035)
			local _content = FuncUtil.LocalizeResFormat(6406)

			CommonMessageBoxUI.ShowPlatformPanel(2, _title, _content, function ()
				EventCloseUnknowPass();
				local Region = Client.GetPublishRegion();
				if Region == "JAPAN" or Region == "KOREA" then
					GlobalData:JumpByTypeID(1602058, 1);
				else
					JumpUtils.Jump(JumpUtils.MODEL_ID_PASS, 1602058);
				end
				--FuncUtil.GotoBuyItemInMallSystem(17, 1602039)
			end,
					function ()
						--EventCloseUnknowPass()
					end,
					_okStr, _cancelStr)
		end
	end,
			function ()
				--EventCloseUnknowPass()
			end,
			okStr, cancelStr)

	--[[
    if UnknowPassTreasureBoxUI.GetItemCount(taskCfg.ImmFinishItemID) >= needNum then
        local title = FuncUtil.GetLocalizeResStr(5077)
        local okStr = FuncUtil.GetLocalizeResStr(110036)
        local cancelStr = FuncUtil.GetLocalizeResStr(110035)
        local content = GlobalData.GetLocalizeStringWithNum(6404, 0, tostring(needNum))
        
        CommonMessageBoxUI.ShowPlatformPanel(2, title, content, function ()
               NetUtil.SendPriorityPkg(false, "upass_imm_finish_task_rsp", "upass_imm_finish_task_req", taskId);
           end,
           function ()
               EventCloseUnknowPass()
           end,
           okStr, cancelStr)
    else
        --测试忙不过来，暂时屏蔽
        local title = FuncUtil.GetLocalizeResStr(5077)
        local okStr = FuncUtil.GetLocalizeResStr(110036)
        local cancelStr = FuncUtil.GetLocalizeResStr(110035)
        local content = FuncUtil.LocalizeResFormat(6406)
        
        CommonMessageBoxUI.ShowPlatformPanel(2, title, content, function ()
                EventCloseUnknowPass()
                FuncUtil.GotoBuyItemInMallSystem(17, 1602039)
           end,
           function ()
               EventCloseUnknowPass()
           end,
           okStr, cancelStr)
        
        EventCloseUnknowPass()
    end
    ]]
end

-- 去完成任务
function EventUnknowPassDayMissionGotoClick_Push()
	log(string.format("EventUnknowPassDayMissionGetClick_Push, %d", BP_UnknowPass_CurrentGetMissionTaskId))
    OnMissionGotoClick()
end

function EventUnknowPassWeekMissionGotoClick_Push()
	log(string.format("week_Push, %d, %d", BP_UnknowPass_CurrentGetMissionWeekIndex, BP_UnknowPass_CurrentGetMissionTaskId));
    
    local taskInfo = UnknowPassWeekMissionMap[BP_UnknowPass_CurrentGetMissionTaskId]
    --打开的任务与升级通行证 才响应
    if taskInfo.isOpen then
        if not UnknowPassSystem.IsBuyElite and taskInfo.isEliteMission then
            local title = FuncUtil.GetLocalizeResStr(5077)
            local okStr = FuncUtil.GetLocalizeResStr(110036)
            local cancelStr = FuncUtil.GetLocalizeResStr(110035)
            local content = FuncUtil.LocalizeResFormat(6407)
            
            CommonMessageBoxUI.ShowPlatformPanel(2, title, content, function ()
                    EventShowUnknowPassBuy()
               end,
               function ()
                   --EventCloseUnknowPass()
               end,
               okStr, cancelStr)
        else
            OnMissionGotoClick()
        end
    else
        EventCloseUnknowPass()
    end
end

-- 刷新每日任务
function EventUnknowPassDayMissionRefreshClick_Push()
	UnknowPassSystem.upass_refreash_daily_req(BP_UnknowPass_CurrentGetMissionTaskId);
end

-- 打开购买界面
function EventUnknowPassMissionBuyPassClick_Push()
	UnknowPassBuy.ShowUI();
end

-- 刷新任务界面
function EventUnknowPassMissionDayTabClick_Push()
	UnknowPassMissionUI.UpdateDayMissionList();
	UnknowPassMissionUI.InitDayMissionList();
	UnknowPassMissionUI.IsShowDayMission = true;

	UnknowPassUI.OnClickDayMission();
end

function EventUnknowPassMissionWeekTabClick_Push()
	-- 写入周次信息,挑战任务红点用
	local weekIndex = DataMgr.GetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_PASS, UnknowPassMissionUI.weekIndexKey);
	if weekIndex ~= UnknowPassSystem.Data.cur_week_index then
		DataMgr.SetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_PASS, UnknowPassMissionUI.weekIndexKey, UnknowPassSystem.Data.cur_week_index );
	end
	
	UnknowPassMissionUI.UpdateWeekMissionList();
	UnknowPassMissionUI.InitWeekMissionList();
	UnknowPassMissionUI.IsShowDayMission = false;
	UnknowPassUI.OnClickWeekMission();
end

-- 调整周任务周数
function EventUnknowPassMissionPrevWeekClick_Push()
	if BP_UnknowPass_CurrentGetMissionWeekIndex > 1 then
		BP_UnknowPass_CurrentGetMissionWeekIndex = BP_UnknowPass_CurrentGetMissionWeekIndex - 1;
		UnknowPassMissionUI.UpdateWeekMissionList();
		UnknowPassMissionUI.InitWeekMissionList();
	end
end

function EventUnknowPassMissionNextWeekClick_Push()
	if BP_UnknowPass_CurrentGetMissionWeekIndex < BP_UnknowPass_MaxMissionWeekCount then
		BP_UnknowPass_CurrentGetMissionWeekIndex = BP_UnknowPass_CurrentGetMissionWeekIndex + 1;
		UnknowPassMissionUI.UpdateWeekMissionList();
		UnknowPassMissionUI.InitWeekMissionList();
	end
end

function EventUnknowPassMissionBoxClick_Push()
	if UnknowPassSystem.Data.base.week_reward_status == 0 then
		-- 弹出宝箱详情
		CommonTreasureBoxPopup:ShowPanelByItemList(UnknowPassSystem.Data.weekly_reward_cfg.reward)
		CommonTreasureBoxPopup:SetTitleString(FuncUtil.GetLocalizeResStr(4600))
	elseif UnknowPassSystem.Data.base.week_reward_status == 1 then
		-- 领取宝箱
		UnknowPassSystem.upass_get_curweek_award_req()
	end
end

function EventUnknowPassMissionGetDailyRewardClick()
	UnknowPassSystem.requestGetDailyTask()
end

--sami 点击不能领取按钮
function EventUnknowPassMission_ClickCanNotGet()
	local title = FuncUtil.GetLocalizeResStr("101001");
	local tips = FuncUtil.GetLocalizeResStr("6395")
	CommonMessageBoxUI:ShowPanel(2, title, tips, function ()
		UnknowPassBuy.ShowUI();
	end)
end
