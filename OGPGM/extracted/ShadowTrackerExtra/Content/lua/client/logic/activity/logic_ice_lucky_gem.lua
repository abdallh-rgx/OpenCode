LogicIceLuckyGem = LogicIceLuckyGem or
{
	Snatch_Result = {}, --夺宝的奖励
	Snatch_Result_Indexs = {}, --夺宝的奖励index
	Snatch_Count_Awards = {}, --次数奖励
	Snatch_Items = {},
	TicketId = 1602041,
	SnatchTicket = {8, 40}, --夺宝需要的券数量
	SnatchUC = {60, 270}, --夺宝需要的UC
	TaskInfos = {}, --任务信息
	TotalSnatchTimes = 0,
	StartTime = 0, --开始时间
	EndTime = 0, --结束时间
}

--冰雪节活动是否开启
function LogicIceLuckyGem.GetActivityTime()
	
	return LogicIceLuckyGem.StartTime, LogicIceLuckyGem.EndTime
    --local activityType = ActivityType["ICE_LUCKY_GEM"];--
    --
    --if LobbySystem.activityDisplayDataList == nil then
    --    return 0, 0
    --end
    --
    --for _, activity in ipairs(LobbySystem.activityDisplayDataList) do
    --    if activity.ActivityType == activityType then
    --    	--log("LogicIceLuckyGem.GetActivityTime:" .. activity.StartTime .. "," .. activity.EndTime)
    --        return activity.StartTimeUTC, activity.EndTimeUTC
    --        --return FuncUtil:StringTimeToUnixTime(activity.StartTime), FuncUtil:StringTimeToUnixTime(activity.EndTime)
    --    end
    --end
    --return 0, 0
end

--LogNula: LuaLog: ├─ show_info
--LogNula: LuaLog: │  ├─ stage_award
--LogNula: LuaLog: │  │  ├─ 1
--LogNula: LuaLog: │  │  │  ├─ award
--LogNula: LuaLog: │  │  │  │  └─ 1
--LogNula: LuaLog: │  │  │  │     ├─ num: 2
--LogNula: LuaLog: │  │  │  │     ├─ id: 1532001
--LogNula: LuaLog: │  │  │  │     └─ expire: 0
--LogNula: LuaLog: │  │  │  └─ cond: 20
--LogNula: LuaLog: │  ├─ draw_cost_info
--LogNula: LuaLog: │  │  ├─ 1
--LogNula: LuaLog: │  │  │  ├─ draw_times: 1
--LogNula: LuaLog: │  │  │  ├─ cost_num: 60
--LogNula: LuaLog: │  │  │  └─ cost_id: 1006
--LogNula: LuaLog: │  ├─ task_list
--LogNula: LuaLog: │  │  ├─ 1
--LogNula: LuaLog: │  │  │  ├─ award
--LogNula: LuaLog: │  │  │  │  └─ 1
--LogNula: LuaLog: │  │  │  │     ├─ num: 1
--LogNula: LuaLog: │  │  │  │     ├─ id: 1602038
--LogNula: LuaLog: │  │  │  │     └─ expire: 0
--LogNula: LuaLog: │  │  │  ├─ cond_extra: ""
--LogNula: LuaLog: │  │  │  ├─ cond
--LogNula: LuaLog: │  │  │  │  ├─ 1: 4
--LogNula: LuaLog: │  │  │  │  └─ 2: 0
--LogNula: LuaLog: │  │  │  ├─ jump_to: ""
--LogNula: LuaLog: │  │  │  └─ ice_name: "每天登录1次"
--LogNula: LuaLog: │  │  ├─ 2
--LogNula: LuaLog: │  └─ drop_items
--LogNula: LuaLog: │     ├─ 1
--LogNula: LuaLog: │     │  ├─ weight: 1000
--LogNula: LuaLog: │     │  ├─ max_num: 0
--LogNula: LuaLog: │     │  ├─ occur_times: 0
--LogNula: LuaLog: │     │  ├─ item_id: 1000
--LogNula: LuaLog: │     │  ├─ item_expire: 0
--LogNula: LuaLog: │     │  └─ item_num: 1888
--LogNula: LuaLog: │     ├─ 2
--LogNula: LuaLog: │     │  ├─ weight: 800
--LogNula: LuaLog: │     │  ├─ max_num: 0
--LogNula: LuaLog: │     │  ├─ occur_times: 1
--LogNula: LuaLog: │     │  ├─ item_id: 1001
--LogNula: LuaLog: │     │  ├─ item_expire: 0
--LogNula: LuaLog: │     │  └─ item_num: 50
--LogNula: LuaLog: ├─ task
--LogNula: LuaLog: │  ├─ 1
--LogNula: LuaLog: │  │  ├─ status: 0
--LogNula: LuaLog: │  │  └─ other
--LogNula: LuaLog: │  │     ├─ last_login_time: 1541727080
--LogNula: LuaLog: │  │     └─ total_login_days: 1
--LogNula: LuaLog: ├─ total_draw_times: 0
--LogNula: LuaLog: └─ stage_award
--LogNula: LuaLog:    ├─ 1: 0
--LogNula: LuaLog:    ├─ 2: 0
--LogNula: LuaLog:    ├─ 3: 0
function LogicIceLuckyGem.get_ice_activity_info_rsp(rs, result)
	log("LogicIceLuckyGem.rs:" .. rs)

	log_tree("LogicIceLuckyGem.result,get_ice_activity_info_rsp:",result, "test")

	if rs ~= "ok" then
		if rs == "not-open" then
			ShowNotice(4002)
		else
			ShowNotice(6148)
		end
		return
	end

	

	--BP_ARRAY_Ice_Gem_Acc_Awards = { --所有的累计奖励
	--	BP_STRUCT_Ice_Gem_Award_Status = _G.BP_STRUCT_Ice_Gem_Award_Status
	--}
	--

	--BP_STRUCT_Ice_Gem_Award_Status = {
	--	awardId = 0, --奖励id
	--	snatchCount = 0, -- 夺宝次数
	--	status = 0, --0 表示未领取，1 表示可领取 2 表示已领取
	--	targetSnatchNum = 0, -- 需要达到的次数
	--	BP_ARRAY_Ice_Gem_AccItems = _G.BP_ARRAY_Ice_Gem_AccItems --奖励的物品
	--}


	--刷新累计奖励
	LogicIceLuckyGem.Snatch_Count_Awards = {}
	for i, reward in ipairs(result.show_info.stage_award) do
		local awardStatus = {}
		local _award = {}

		for i,v in ipairs(reward.award) do
			table.insert(_award, {itemId = v.id, itemCount = v.num, index = i, itemExpireTime = v.expire})
		end

		awardStatus.BP_ARRAY_Ice_Gem_AccItems = _award
		awardStatus.awardId = i
		awardStatus.targetSnatchNum = reward.cond
		awardStatus.status = result.stage_award[i] --0 标识未完成  1 是已完成未领奖  2是已领奖

		--log("awardStatus.status:" .. lottery.award[i])
		awardStatus.snatchCount = result.total_draw_times
		table.insert(LogicIceLuckyGem.Snatch_Count_Awards, awardStatus)
	end


--设置抽奖奖励
	LogicIceLuckyGem.Snatch_Items = {}

	for i,v in ipairs(result.show_info.drop_items) do
		table.insert(LogicIceLuckyGem.Snatch_Items, {itemId = v.id, itemCount = v.num, index = i})
	end


	--设置任务信息

	LogicIceLuckyGem.TaskInfos = {}
	for i, v in ipairs(result.show_info.task_info) do
		local taskStatus = result.task[i]
		local task = {taskId = i, count = taskStatus.progress, 
					  maxCount = v.cond[1], status = taskStatus.status, jumpTo = v.jump_to, name = v.ice_name}
		table.insert(LogicIceLuckyGem.TaskInfos, task)
	end

	
	LogicIceLuckyGem.TotalSnatchTimes = result.total_draw_times
--设置抽奖花费
	local costInfo = result.show_info.draw_cost_info
	LogicIceLuckyGem.SnatchUC = {costInfo[1].cost_num, costInfo[2].cost_num} --夺宝需要的UC
	LogicIceLuckyGem.SnatchTicket = {costInfo[3].cost_num, costInfo[4].cost_num} --夺宝需要的券数量

	LogicIceLuckyGem.TicketId = costInfo[3].cost_id

	LogicIceLuckyGem.StartTime = result.show_info.start_time
	LogicIceLuckyGem.EndTime = result.show_info.end_time
	IceLuckyGemUI.on_ice_activity_info_rsp()
end


function LogicIceLuckyGem.have_draw_rsp(rs, drawInfo)
	log("LogicIceLuckyGem.have_draw_rsp,lottery " .. rs)

	log_tree("LogicIceLuckyGem.have_draw_rsp,lottery:",drawInfo,"test")

	if rs ~= "ok" then

		if rs == "not-enough" then
			--ShowNotice(502006)

			-- 打开充值界面
			local title = Client.GetTableData("LocalizeRes", "101001").TextValue;
			local tip = Client.GetTableData("LocalizeRes", "4119").TextValue;
			CommonMessageBoxUI:ShowPanel(2, title, tip, function()
					RechargeUI:Init();
					IceLuckyGemUI.HideUI(false)
				return true;
			end);
		elseif  rs == "not-open" then
			ShowNotice(4002)
		else
			ShowNotice(6148)
		end

		log("LogicIceLuckyGem.have_draw_rsp not ok")
		return
	end

    for i, awardStatus in ipairs(LogicIceLuckyGem.Snatch_Count_Awards) do
        awardStatus.status = drawInfo.stage_award[i]
		awardStatus.snatchCount = drawInfo.total_draw_times

	end
	
	LogicIceLuckyGem.TotalSnatchTimes = drawInfo.total_draw_times

    IceLuckyGemUI.RefreshSnatchAccAward()
    
	LogicIceLuckyGem.Snatch_Result_Indexs = drawInfo.droped_list
	
	LogicIceLuckyGem.Snatch_Result = {}
	for i, index in ipairs(drawInfo.droped_list) do
		local item = LogicIceLuckyGem.Snatch_Items[index]
		table.insert(LogicIceLuckyGem.Snatch_Result, item)
	end

	log_tree("Snatch_Items:", LogicIceLuckyGem.Snatch_Result,"test")

	log_tree("Snatch_Result_Indexs:", LogicIceLuckyGem.Snatch_Result_Indexs,"test")

	IceLuckyGemUI.OnSnatchAwardResult()


	--for i, awardStatus in ipairs(LogicIceLuckyGem.Snatch_Count_Awards) do
	--	awardStatus.SnatchCount = lottery.times
	--	awardStatus.status = lottery.award[i]
	--end
    --
	--BP_Ice_Gem_Snatch_Count = lottery.times
    --
	--IceFestivalLuckyGemUI.RefreshNumAward(LogicIceLuckyGem.Snatch_Count_Awards)
    --
end


function LogicIceLuckyGem.take_award_of_stage_award_rsp(rs, awards)
	log("LogicIceLuckyGem.take_award_of_stage_award_rsp :" .. rs)
    log_tree("LogicIceLuckyGem.take_award_of_stage_award_rsp,item_list:",awards, "test")

    if rs ~= "ok" then
		if rs == "not-open" then
			ShowNotice(4002)
		elseif rs == "params-invalid" then
			ShowNotice(6148)
		elseif rs == "status-invalid" then
			ShowNotice(6148)
		else
			ShowNotice(6148)
		end
		return
	end
	--local AwardTb = nil
	--
	--for i, awardStatus in ipairs(LogicIceLuckyGem.Snatch_Count_Awards) do
	--	if awardStatus.status == 1 and award[i] == 2 then
	--		GetAwardTb = awardStatus.BP_ARRAY_Ice_Gem_Items
	--	end
	--	awardStatus.status = award[i]
	--end
	--
	--IceFestivalLuckyGemUI.RefreshNumAward(LogicIceLuckyGem.Snatch_Count_Awards)


    for i, awardStatus in ipairs(LogicIceLuckyGem.Snatch_Count_Awards) do
        awardStatus.status = awards.stage_award[i]
    end

    IceLuckyGemUI.RefreshSnatchAccAward()
	--显示获奖结果
    local Result = {}
    for i,v in ipairs(awards.award) do
        table.insert(Result, {res_id = v.resid, count = v.count, valid_hours = v.itemExpireTime})
    end
    CommonItemGetUI:ShowPanel(Result);

	DecomposeSystem.delay_item_decompose_notice()
end

function LogicIceLuckyGem.take_award_of_task_rsp(rs, tasks)
	log("LogicIceLuckyGem.take_award_of_task_rsp :" .. rs)

	log_tree("LogicIceLuckyGem.take_award_of_task_rsp,item_list:",tasks, "test")


	if rs ~= "ok" then
		if rs == "not-open" then
			ShowNotice(4002)
		elseif rs == "params-invalid" then
			ShowNotice(6148)
		elseif rs == "status-invalid" then
			ShowNotice(6148)
		else
			ShowNotice(6148)
		end
		return
	end

	for i, taskInfo in ipairs(LogicIceLuckyGem.TaskInfos) do
		local taskStatus = tasks.task[i]
		taskInfo.status = taskStatus.status
		taskInfo.count = taskStatus.progress
	end
    
    IceLuckyGemUI.SetTasks()


--显示获奖结果

    local Result = {}
    for i,v in ipairs(tasks.award) do
        table.insert(Result, {res_id = v.resid, count = v.count, valid_hours = v.itemExpireTime})
    end
    CommonItemGetUI:ShowPanel(Result);

end


--领取奖励 1-uc单抽，2-uc五连抽, 3-道具单抽，4-道具五连抽
function LogicIceLuckyGem.have_draw_req(draw_type)
	log("LogicIceLuckyGem.have_draw_req,draw_type:" .. draw_type)
    NetUtil.SendPriorityPkg(false, "have_draw_rsp", "have_draw_req", draw_type);
end

--获取阶段奖励
function LogicIceLuckyGem.take_award_of_stage_award_req(award_id)
    log("LogicIceLuckyGem.take_award_of_stage_award_req,award_id：" .. award_id)
    NetUtil.SendPriorityPkg(false, "take_award_of_stage_award_rsp", "take_award_of_stage_award_req", award_id);
end

--查询活动数据
function LogicIceLuckyGem.get_ice_activity_info_req()
    log("LogicIceLuckyGem.get_ice_activity_info_req")
    NetUtil.SendPriorityPkg(false, "get_ice_activity_info_rsp", "get_ice_activity_info_req");
end

--领取任务奖励
function LogicIceLuckyGem.take_award_of_task_req(award_id)
    log("LogicIceLuckyGem.take_award_of_task_req:" .. award_id);
  	NetUtil.SendPriorityPkg(false, "take_award_of_task_rsp", "take_award_of_task_req", award_id);
end



function LogicIceLuckyGem.GetTicketCount()
	local itemData = DataMgr.GetHallDepotItemDataByResID(LogicIceLuckyGem.TicketId);
	if (itemData ~= nil) then
		return itemData.count;
	end
	return 0
end


function LogicIceLuckyGem.IsShowRedPoint()
	return not LobbyUI.HasClickIceLucky()
end

function LogicIceLuckyGem.UpdateShowRedPoint()
	LobbyUI:LobbyRedPointUpdate(BP_ENUM_MODULE_ACTIVITY_ICE_LUCKY, LogicIceLuckyGem.IsShowRedPoint());
end




--[[网络回调]]--
s2c["have_draw_rsp"]= LogicIceLuckyGem.have_draw_rsp; --抽奖回包
s2c["take_award_of_stage_award_rsp"] = LogicIceLuckyGem.take_award_of_stage_award_rsp; --载具升级结果返回
s2c["get_ice_activity_info_rsp"] = LogicIceLuckyGem.get_ice_activity_info_rsp; --查询活动数据接口
s2c["take_award_of_task_rsp"] = LogicIceLuckyGem.take_award_of_task_rsp; --查询次数奖励

