-- 冰雪节幸运夺宝
IceLuckyGemUI = IceLuckyGemUI or {
	SnatchItemIds2Index = {}, -- 夺宝物品与index的id
	AniSpeed = 200, --抽第一个物品的时候的
	AniSpeed2 = 200, --抽第二个物品以及之后的物品的时候
	aniEnterAngle_f = 0, --动画进入到某个奖励的角度
	AniTime = 0, --动画经过的时间
	LuckyItemCount = 0, --有多少个抽奖的物品
	AniAngleInterval = 0, --动画角度间隔
	AniAccAngle = 0, --动画已经累计的角度
	AniTargetAngle = 0, --动画目标角度
	AniLightFadeSpeed = 4, --亮光淡出速度
	AniStages = 0, -- 0,未开始 1,第一次跑大约3圈 2,奖励的表现时间 3,继续跑到下个奖励然后回到2
	AniStage1Angle = 720, --第一阶段动画需要的角度
	AniBlinkTime = 1, -- 动画闪烁的时间
	LastSnatchTime = 0, --上次抽奖的时间
	MinSnatchTime = 0.5, --最小的抽奖的间隔
	ZeroPointTimer = nil,
	LastDay = 0,
};

BP_Ice_Gem_DateTime = "" --万圣节活动时间
BP_Ice_Gem_Ignore_Ani = false --是否跳过动画
BP_Ice_Gem_Snatch_Count = 0 --累计夺宝次数

BP_Ice_Gem_Ticket_Count = 0 --夺宝券个数
BP_Ice_Gem_Ticket_Id = 1602041 --夺宝券Id

BP_Ice_Gem_Gun_Id = 1101004040 --冰枪的id

BP_Ice_Gem_Is_Show_Detail_Task = false --是否显示详细任务

BP_STRUCT_Ice_Gem_Item_Info = { --物品信息
	itemId = 0,
	itemCount = 1,
	index = 1, --在物品中的顺序
	itemExpireTime = 0,
}

BP_ARRAY_Ice_Gem_AccItems = { --物品列表
	BP_STRUCT_Ice_Gem_Item_Info = _G.BP_STRUCT_Ice_Gem_Item_Info
}

BP_Ice_Gem_Clicked_Award_Id = 0 --点击领取的奖励ID

BP_Ice_Gem_Clicked_Task_Id = 0 --点击领取的任务ID

BP_Ice_Gem_Curr_Enter_Index = 1 --当前进入的Index

BP_Ice_Gem_Blink_Speed_f = 1 --动画闪烁的速度

BP_Ice_Gem_Light_Speed_f = 1 --动画亮光的速度

BP_Ice_Gem_Curr_Result_Index = 0 --当前展示的结果indexBP_Ice_Gem_Curr_Result_Index = 0 --当前展示的结果index

BP_Ice_Gem_Max_Result_Index = 1 --需要展示的结果的总个数

BP_Ice_Gem_Curr_UC_Num = 0 --当前拥有的UC

BP_Ice_Gem_Play_Arrow_Ani = false --是否播放arrow动画

BP_Ice_Gem_Progress_Bar_Percent_f = 0 --进度条的进度，每个阶段都是不一样的

BP_STRUCT_Ice_Gem_Award_Status = {
	awardId = 0, --奖励id
	snatchCount = 0, -- 夺宝次数
	status = 0, --0 表示未领取，1 表示可领取 2 表示已领取
	targetSnatchNum = 0, -- 需要达到的次数
	BP_ARRAY_Ice_Gem_AccItems = _G.BP_ARRAY_Ice_Gem_AccItems --奖励的物品
}

BP_ARRAY_Ice_Gem_Acc_Awards = { --所有的累计奖励
	BP_STRUCT_Ice_Gem_Award_Status = _G.BP_STRUCT_Ice_Gem_Award_Status
}

BP_STRUCT_Ice_Gem_Task_Info = { --任务信息
	taskId = 0,
	count = 1, --任务已经完成的数量
	maxCount = 1, --任务需要完成的数量
	status = 0, --0 表示未完成，1 表示已完成，可领取 2 已领取奖励
	jumpTo = "",--跳转
	name = "",
}

BP_ARRAY_Ice_Gem_Tasks = {--所有的任务
	BP_STRUCT_Ice_Gem_Task_Info = _G.BP_STRUCT_Ice_Gem_Task_Info
}


BP_ARRAY_Ice_Gem_Lucky_Items = {--抽奖的奖品
	BP_STRUCT_Ice_Gem_Item_Info = _G.BP_STRUCT_Ice_Gem_Item_Info
} 

--抽奖结果，抽奖一次的，只有一个，抽奖5次就会有5个
BP_ARRAY_Ice_Gem_Lucky_Result = {
	BP_STRUCT_Ice_Gem_Item_Info = _G.BP_STRUCT_Ice_Gem_Item_Info
}

--抽奖需要的UC
BP_ARRAY_Ice_Gem_Lucky_UC = 
{
	0 --
}

--抽奖需要的Ticket
BP_ARRAY_Ice_Gem_Lucky_Ticket = 
{
	0 --
}

--动画状态信息
BP_STRUCT_Ice_Gem_Ani_Item =
{
	lightOpacity_f = 0, --亮光透明度
	lightVisible = false, --亮光可见性
	lightAniIndex = 0, --亮光动画
	blinkVisible = false, --闪烁可见性
	aniEnterAngle_f = -1, --动画进入角度
	aniEnterTime_f = -1, --动画进入时间
}

--动画状态数组
BP_ARRAY_Ice_Gem_Ani_Items =
{
	BP_STRUCT_Ice_Gem_Ani_Item = _G.BP_STRUCT_Ice_Gem_Ani_Item
}



function bp_ice_lucky_gem_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_ice_lucky_gem,
                                {{Path="/Game/UMG/UI_Logic/IceLucky/IceLucky_Snatch_BP.IceLucky_Snatch_BP_C", Container="Default", ZOrder=BP_ENUM_UI_ICE_LUCKY_ZORDER}},
                                {"Lobby"},
                                false,
                                false,
                                true);
end

--以__Hot__ 为结尾表示此函数改变后，会执行此函数
function IceLuckyGemUI.InitAniData__Hot__()
	IceLuckyGemUI.AniSpeed = 600 --抽第一个物品的时候的
	IceLuckyGemUI.AniSpeed2 = 600 --抽第二个物品以及之后的物品的时候
	IceLuckyGemUI.AniStage1Angle = 720 --第一阶段动画需要的角度
	IceLuckyGemUI.AniLightFadeSpeed = 1
	BP_Ice_Gem_Blink_Speed_f = 1 --动画闪烁的速度
	BP_Ice_Gem_Light_Speed_f = 1.1 --动画亮光的速度
end

function IceLuckyGemUI.Update(DeltaTime)

	if IceLuckyGemUI.AniStages == 0 then
		return
	end

	IceLuckyGemUI.AniTime = IceLuckyGemUI.AniTime + DeltaTime

	if IceLuckyGemUI.AniStages == 1 or IceLuckyGemUI.AniStages == 3 then
		local speed = IceLuckyGemUI.AniStages == 1 and IceLuckyGemUI.AniSpeed or IceLuckyGemUI.AniSpeed2
		IceLuckyGemUI.AniAccAngle = IceLuckyGemUI.AniAccAngle + speed * DeltaTime

		if IceLuckyGemUI.AniAccAngle >= IceLuckyGemUI.AniAngleInterval then
			IceLuckyGemUI.aniEnterAngle_f = IceLuckyGemUI.aniEnterAngle_f + IceLuckyGemUI.AniAccAngle
			IceLuckyGemUI.AniAccAngle = 0

			IceLuckyGemUI.LeaveIndex(BP_Ice_Gem_Curr_Enter_Index)
			BP_Ice_Gem_Curr_Enter_Index = BP_Ice_Gem_Curr_Enter_Index + 1
			if BP_Ice_Gem_Curr_Enter_Index > IceLuckyGemUI.LuckyItemCount then
				BP_Ice_Gem_Curr_Enter_Index = 1
			end
			IceLuckyGemUI.EnterIndex(BP_Ice_Gem_Curr_Enter_Index)

			--进入第三个阶段
			if IceLuckyGemUI.aniEnterAngle_f >= IceLuckyGemUI.AniStage1Angle - 0.01  then
				IceLuckyGemUI.AniStages = 3
			end

			if IceLuckyGemUI.AniStages == 3 then
				--到达奖励
				if BP_Ice_Gem_Curr_Enter_Index == BP_ARRAY_Ice_Gem_Lucky_Result[BP_Ice_Gem_Curr_Result_Index].index then
					IceLuckyGemUI.AniStages = 2
					IceLuckyGemUI.EnterAward(BP_Ice_Gem_Curr_Enter_Index)
				end
			end
		end
	elseif IceLuckyGemUI.AniStages == 2 then
		local Ani_Item = IceLuckyGemUI.GetAniItem(BP_Ice_Gem_Curr_Enter_Index)
		if IceLuckyGemUI.AniTime - Ani_Item.aniEnterTime_f >= IceLuckyGemUI.AniBlinkTime then
			IceLuckyGemUI.AniStages = 3
			IceLuckyGemUI.LeaveIndex()
			IceLuckyGemUI.LeaveAward()
		end
	end


	--每一帧更新状态
	for index = 1, IceLuckyGemUI.LuckyItemCount do
		IceLuckyGemUI.UpdateAni(index, DeltaTime)
	end

	if BP_Ice_Gem_Ignore_Ani then
		IceLuckyGemUI.EndAni()
	end 

	LuaClassObj.HandleUIMessageNoFetch(bp_ice_lucky_gem, "UpdateAni");
end

function IceLuckyGemUI.StartAni()
	log("IceLuckyGemUI.StartAni")
	IceLuckyGemUI.AniTime = 0
	IceLuckyGemUI.AniStages = 1
	BP_Ice_Gem_Curr_Enter_Index = 1
	
	IceLuckyGemUI.AniAccAngle = 0

	IceLuckyGemUI.aniEnterAngle_f = 0
	
	IceLuckyGemUI.ResetAni()

	IceLuckyGemUI.EnterIndex(BP_Ice_Gem_Curr_Enter_Index)
	
	LuaClassObj.HandleUIMessageNoFetch(bp_ice_lucky_gem, "PlaySnatchAwardAni");
end

function IceLuckyGemUI.EnterAward()
	log("IceLuckyGemUI.EnterAward")
	local Ani_Item = IceLuckyGemUI.GetAniItem(BP_Ice_Gem_Curr_Enter_Index)
	Ani_Item.lightVisible = false
	Ani_Item.blinkVisible = true
	LuaClassObj.HandleUIMessageNoFetch(bp_ice_lucky_gem, "StartAwardAni");
	
	if BP_Ice_Gem_Max_Result_Index == 5 then
		LuaClassObj.HandleUIMessageNoFetch(bp_ice_lucky_gem, "RefreshSnatchAward");
	end
end

function IceLuckyGemUI.LeaveAward()
	log("IceLuckyGemUI.LeaveAward")
	IceLuckyGemUI.AniAccAngle = IceLuckyGemUI.AniAngleInterval
	BP_Ice_Gem_Curr_Result_Index = BP_Ice_Gem_Curr_Result_Index + 1

	if BP_Ice_Gem_Curr_Result_Index > BP_Ice_Gem_Max_Result_Index then
		IceLuckyGemUI.EndAni()
	end
end

function IceLuckyGemUI.ResetAni()
	for index = 1, IceLuckyGemUI.LuckyItemCount do
		local Ani_Item = IceLuckyGemUI.GetAniItem(index)
		Ani_Item.lightOpacity_f = 0
		Ani_Item.lightAniIndex = 0
		Ani_Item.lightVisible = false
		Ani_Item.blinkVisible = false
		Ani_Item.aniEnterAngle_f = -1
		Ani_Item.aniEnterTime_f = -1
	end
end

function IceLuckyGemUI.EndAni()

	log("IceLuckyGemUI.EndAni")
	IceLuckyGemUI.AniStages = 0
	IceLuckyGemUI.ResetAni()

	BP_Ice_Gem_Curr_Result_Index = 0 --当前抽奖的次数    
	

	if BP_Ice_Gem_Max_Result_Index == 5 then
		LuaClassObj.HandleUIMessageNoFetch(bp_ice_lucky_gem, "RefreshSnatchAward");
	end

	LuaClassObj.HandleUIMessageNoFetch(bp_ice_lucky_gem, "PlaySnatchAwardAni");

	if IceLuckyGemUI.isShow then
		IceLuckyGemUI.ShowResult()
	else
		LuaClassObj.HandleUIMessageNoFetch(bp_ice_lucky_gem, "UpdateAni");
	end

	LuaClassObj.HandleUIMessageNoFetch(bp_ice_lucky_gem, "RefreshMask");

	BP_Ice_Gem_Max_Result_Index = 0 --最大抽奖次数

	DecomposeSystem.delay_item_decompose_notice()
end

function IceLuckyGemUI.UpdateAni(index, DeltaTime)
	local Ani_Item = IceLuckyGemUI.GetAniItem(index)
	
	--以及进入过之后
	--if Ani_Item.aniEnterTime_f >= 0 and Ani_Item.lightOpacity_f ~= 0 then
	--	local passTime = IceLuckyGemUI.AniTime - Ani_Item.aniEnterTime_f
	--	Ani_Item.lightOpacity_f = Ani_Item.lightOpacity_f - IceLuckyGemUI.AniLightFadeSpeed * DeltaTime
    --
	--	if Ani_Item.lightOpacity_f < 0 then
	--		Ani_Item.lightOpacity_f = 0
	--		Ani_Item.lightVisible = false
	--	end
	--end
end

function IceLuckyGemUI.EnterIndex()
	log("IceLuckyGemUI.EnterIndex:" .. tostring(BP_Ice_Gem_Curr_Enter_Index))
	local Ani_Item = IceLuckyGemUI.GetAniItem(BP_Ice_Gem_Curr_Enter_Index)
	Ani_Item.aniEnterAngle_f = IceLuckyGemUI.aniEnterAngle_f
	Ani_Item.aniEnterTime_f = IceLuckyGemUI.AniTime
	Ani_Item.lightOpacity_f = 1
	Ani_Item.lightVisible = true
	Ani_Item.lightAniIndex = 1


	local Ani_Item_Last_1 = IceLuckyGemUI.GetAniItem(BP_Ice_Gem_Curr_Enter_Index - 1)
	if Ani_Item_Last_1.lightAniIndex ~= 0 then
		Ani_Item_Last_1.lightAniIndex = 2
	end
	
	local Ani_Item_Last_2 = IceLuckyGemUI.GetAniItem(BP_Ice_Gem_Curr_Enter_Index - 2)
	if Ani_Item_Last_2.lightAniIndex ~= 0 then
		Ani_Item_Last_2.lightAniIndex = 3
	end
	
	local Ani_Item_Last_3 = IceLuckyGemUI.GetAniItem(BP_Ice_Gem_Curr_Enter_Index - 3)
	if Ani_Item_Last_3.lightAniIndex ~= 0 then
		Ani_Item_Last_3.lightAniIndex = 4
	end

	local Ani_Item_Last_4 = IceLuckyGemUI.GetAniItem(BP_Ice_Gem_Curr_Enter_Index - 4)
	if Ani_Item_Last_4.lightAniIndex ~= 0 then
		Ani_Item_Last_4.lightAniIndex = 0
		Ani_Item_Last_4.lightVisible = false
	end
	
	log_tree("IceLuckyGemUI.BP_ARRAY_Ice_Gem_Ani_Items:", BP_ARRAY_Ice_Gem_Ani_Items, "test")
	
	LuaClassObj.HandleUIMessageNoFetch(bp_ice_lucky_gem, "StartEnterAni");
end

function IceLuckyGemUI.LeaveIndex()

end


function IceLuckyGemUI.GetAniItem(index)
	if index > IceLuckyGemUI.LuckyItemCount then
		index = index - IceLuckyGemUI.LuckyItemCount
	end

	if index <= 0 then
		index = IceLuckyGemUI.LuckyItemCount + index
	end
	
	local Ani_Item = BP_ARRAY_Ice_Gem_Ani_Items[index]
	if not Ani_Item then
		Ani_Item = {lightOpacity_f = 0, lightVisible = false, blinkVisible = false, 
					aniEnterAngle_f = -1, aniEnterTime_f = -1}
		BP_ARRAY_Ice_Gem_Ani_Items[index] = Ani_Item
	end
	return Ani_Item
end


function IceLuckyGemUI.ShowResult()
	local Result = {}
	for i,v in ipairs(LogicIceLuckyGem.Snatch_Result) do
		table.insert(Result, {res_id = v.itemId, count = v.itemCount, valid_hours = 0})
	end
	CommonItemGetUI:ShowPanel(Result);
end

function IceLuckyGemUI.OnJumpUrl(eventType, eventID, vars)
    log("IceLuckyGemUI.OnJumpUrl");
    IceLuckyGemUI.ShowUI();
end

function IceLuckyGemUI.OnTimerNextDay()
	local dateTime = os.date("!*t", FuncUtil.GetServerTimeInSec());
	--1s后，才刷新
	if dateTime.day ~= IceLuckyGemUI.LastDay and  BP_Ice_Gem_Curr_Result_Index == 0 and dateTime.sec >= 1 then
		IceLuckyGemUI.LastDay = dateTime.day;
		LogicIceLuckyGem.get_ice_activity_info_req()
	end
end

function IceLuckyGemUI.ShowUI()
	log("IceLuckyGemUI.ShowUI")
	IceLuckyGemUI.isShow = true
	DecomposeSystem.needDelay  = true
	
	AchievementFloatTipUI.BlockingPop = true

	local dateTime = os.date("!*t", FuncUtil.GetServerTimeInSec());
	IceLuckyGemUI.LastDay = dateTime.day
	
	IceLuckyGemUI.ZeroPointTimer = Timer.InsertTimer(0.2, IceLuckyGemUI.OnTimerNextDay, true);
		
		--Timer.InsertTimer
	-- if true then
	-- 	BP_ARRAY_Ice_Gem_Lucky_Items = {}
	-- 	table.insert(BP_ARRAY_Ice_Gem_Lucky_Items, {itemId = 1400327, itemCount = 1, index = 1});
	-- 	table.insert(BP_ARRAY_Ice_Gem_Lucky_Items, {itemId = 1400329, itemCount = 1, index = 2});
	-- 	table.insert(BP_ARRAY_Ice_Gem_Lucky_Items, {itemId = 1400330, itemCount = 1, index = 3});
	-- 	table.insert(BP_ARRAY_Ice_Gem_Lucky_Items, {itemId = 1400332, itemCount = 1, index = 4});
	-- 	table.insert(BP_ARRAY_Ice_Gem_Lucky_Items, {itemId = 1400333, itemCount = 1, index = 5});
	-- 	table.insert(BP_ARRAY_Ice_Gem_Lucky_Items, {itemId = 1400334, itemCount = 1, index = 6});

	-- 	table.insert(BP_ARRAY_Ice_Gem_Lucky_Items, {itemId = 1400335, itemCount = 1, index = 7});
	-- 	table.insert(BP_ARRAY_Ice_Gem_Lucky_Items, {itemId = 1400336, itemCount = 1, index = 8});
	-- 	table.insert(BP_ARRAY_Ice_Gem_Lucky_Items, {itemId = 1400337, itemCount = 1, index = 9});
	-- 	table.insert(BP_ARRAY_Ice_Gem_Lucky_Items, {itemId = 1400338, itemCount = 1, index = 10});
	-- 	table.insert(BP_ARRAY_Ice_Gem_Lucky_Items, {itemId = 1400339, itemCount = 1, index = 11});
	-- 	table.insert(BP_ARRAY_Ice_Gem_Lucky_Items, {itemId = 1400341, itemCount = 1, index = 12});

	-- 	for i,v in ipairs(BP_ARRAY_Ice_Gem_Lucky_Items) do
	-- 		IceLuckyGemUI.LuckyItemIds2Index[v.itemId] = v.index
	-- 	end
		
	-- end

	BP_Ice_Gem_Snatch_Count = LogicIceLuckyGem.TotalSnatchTimes

	BP_Ice_Gem_Curr_Result_Index = 0 --当前展示的结果index

	BP_Ice_Gem_Max_Result_Index = 0
	--BP_Ice_Gem_Ignore_Ani = false

	BP_ARRAY_Ice_Gem_Lucky_Result = {}

	BP_ARRAY_Ice_Gem_Lucky_UC = LogicIceLuckyGem.SnatchUC
	BP_ARRAY_Ice_Gem_Lucky_Ticket = LogicIceLuckyGem.SnatchTicket
	
	BP_ARRAY_Ice_Gem_Ani_Items = {}

	BP_Ice_Gem_Is_Show_Detail_Task = false
	

    LuaClassObj.HandleDynamicCreation(bp_ice_lucky_gem);
    IceLuckyGemUI.RefreshTime();

 	BP_Ice_Gem_Ticket_Count = LogicIceLuckyGem.GetTicketCount()

	BP_Ice_Gem_Ticket_Id = LogicIceLuckyGem.TicketId

	IceLuckyGemUI.InitAniData__Hot__()

	IceLuckyGemUI.UpdateItemCount()
	
    LuaClassObj.HandleUIMessageNoFetch(bp_ice_lucky_gem, "UIShow");

	LuaClassObj.HandleUIMessageNoFetch(bp_ice_lucky_gem, "RefreshUI");
	LuaClassObj.HandleUIMessageNoFetch(bp_ice_lucky_gem, "RefreshShowTask");
	LuaClassObj.HandleUIMessageNoFetch(bp_ice_lucky_gem, "RefreshSnatchAward");
	LuaClassObj.HandleUIMessageNoFetch(bp_ice_lucky_gem, "PlaySnatchAwardAni");
	LuaClassObj.HandleUIMessageNoFetch(bp_ice_lucky_gem, "RefreshMask");

	LogicIceLuckyGem.get_ice_activity_info_req()

    EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_DATA_CHANGE, IceLuckyGemUI.UpdateItemCount)
	EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_DIAMOND_CHANGE, IceLuckyGemUI.UpdateItemCount);
end

function IceLuckyGemUI.UpdateItemCount()
	log("IceLuckyGemUI.UpdateItemCount")

 	BP_Ice_Gem_Ticket_Count = LogicIceLuckyGem.GetTicketCount()

	BP_Ice_Gem_Curr_UC_Num =  DataMgr.ticket

 	LuaClassObj.HandleUIMessageNoFetch(bp_ice_lucky_gem, "RefreshCommon");
end

function IceLuckyGemUI.GetItemIdByIndex(Index)
    for i,v in ipairs(BP_ARRAY_Ice_Gem_Lucky_Items) do
		if v.index == Index then
			return v.itemId
		end
	end

	return 0
end

function IceLuckyGemUI.HideUI(IsClickClose)
	AchievementFloatTipUI.BlockingPop = false
	
	log("IceLuckyGemUI.HideUI")
	IceLuckyGemUI.isShow = false

	if IceLuckyGemUI.AniStages ~= 0 then
		IceLuckyGemUI.EndAni()
	end

	DecomposeSystem.needDelay  = false
	
    EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_DATA_CHANGE, IceLuckyGemUI.UpdateItemCount)
	EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_DIAMOND_CHANGE, IceLuckyGemUI.UpdateItemCount);

    LuaClassObj.HandleUIMessageNoFetch(bp_ice_lucky_gem, "UIHide");
	
	Timer.RemoveTimer(IceLuckyGemUI.ZeroPointTimer)

	EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTTYPE_CHECK_BACK_TO_VIEW, IsClickClose);
end


function IceLuckyGemUI.RefreshTime()--更新活动时间
	local Start_Time, End_Time = LogicIceLuckyGem.GetActivityTime()

	local beginTime = os.date("!%Y/%m/%d", Start_Time)
    local endTime = os.date("!%Y/%m/%d", End_Time)

    BP_Ice_Gem_DateTime = beginTime .. "-" .. endTime
end


function IceLuckyGemUI.SetSnatch_Items()
	BP_ARRAY_Ice_Gem_Lucky_Items = LogicIceLuckyGem.Snatch_Items

	for i,v in ipairs(BP_ARRAY_Ice_Gem_Lucky_Items) do
		IceLuckyGemUI.SnatchItemIds2Index[v.itemId] = v.index
	end

	IceLuckyGemUI.LuckyItemCount = #BP_ARRAY_Ice_Gem_Lucky_Items

	IceLuckyGemUI.AniAngleInterval = 360 / IceLuckyGemUI.LuckyItemCount
	
	LuaClassObj.HandleUIMessageNoFetch(bp_ice_lucky_gem, "InitAwards");
end

function IceLuckyGemUI.SetTasks()

	BP_ARRAY_Ice_Gem_Tasks = {}
	--重新赋值排序,领取过的任务排在后面
	for i,v in ipairs(LogicIceLuckyGem.TaskInfos) do
		table.insert(BP_ARRAY_Ice_Gem_Tasks, v)
	end

	table.sort(BP_ARRAY_Ice_Gem_Tasks,
			function(Task1, Task2)
				if Task1.status == 2 or  Task2.status == 2 then
					if Task1.status < Task2.status then
						return true
					elseif Task1.status == Task2.status then
						return Task1.taskId < Task2.taskId
					else
						return false
					end
				else
					return Task1.taskId < Task2.taskId
				end
			end)
	
	local hasAward = false
	for i, v in ipairs(BP_ARRAY_Ice_Gem_Tasks) do
		if v.status == 1 then
			hasAward = true
		end
	end
	BP_Ice_Gem_Play_Arrow_Ani = hasAward
	
	LuaClassObj.HandleUIMessageNoFetch(bp_ice_lucky_gem, "RefreshTask");
end

function IceLuckyGemUI.on_ice_activity_info_rsp()
	BP_ARRAY_Ice_Gem_Lucky_Ticket = LogicIceLuckyGem.SnatchTicket
	BP_ARRAY_Ice_Gem_Lucky_UC = LogicIceLuckyGem.SnatchUC

	BP_Ice_Gem_Ticket_Id = LogicIceLuckyGem.TicketId
	
	IceLuckyGemUI.RefreshSnatchAccAward()
	IceLuckyGemUI.SetSnatch_Items()
	IceLuckyGemUI.SetTasks()

	IceLuckyGemUI.RefreshTime()

	LuaClassObj.HandleUIMessageNoFetch(bp_ice_lucky_gem, "RefreshCommon");
end


function IceLuckyGemUI.ItemId2Index(Result)
	local indexTb = {}
	for i,v in ipairs(Result) do
		table.insert(indexTb, IceLuckyGemUI.LuckyItemIds2Index[v.item_id])
	end
	return indexTb
end

--刷新累计抽奖奖励
function IceLuckyGemUI.RefreshSnatchAccAward()
	log("IceLuckyGemUI.RefreshNumAward")
	BP_ARRAY_Ice_Gem_Acc_Awards = {}
	--重新赋值排序,领取过的奖励排在后面
	local Snatch_Count_Stages = {}
	for i,v in ipairs(LogicIceLuckyGem.Snatch_Count_Awards) do
		table.insert(BP_ARRAY_Ice_Gem_Acc_Awards, v)
		table.insert(Snatch_Count_Stages, v.targetSnatchNum)
	end

	-- BP_STRUCT_Ice_Gem_Award_Status = {
	-- awardId = 0, --奖励id
	-- snatchCount = 0, -- 捣蛋次数
	-- status = 0, --0 表示未领取，1 表示可领取 2 表示已领取
	-- targetSnatchNum = 0, -- 需要达到的次数
	-- BP_ARRAY_Ice_Gem_AccItems = _G.BP_ARRAY_Ice_Gem_AccItems --奖励的物品


	--BP_ARRAY_Ice_Gem_Acc_Awards = Result
	table.sort(BP_ARRAY_Ice_Gem_Acc_Awards, 
		function(Award1, Award2)
				return Award1.targetSnatchNum > Award2.targetSnatchNum
		end)

	BP_Ice_Gem_Snatch_Count = LogicIceLuckyGem.TotalSnatchTimes

	table.sort(Snatch_Count_Stages,
			function(SnatchCount1, SnatchCount2)
				return SnatchCount1 < SnatchCount2
			end)

	local percent = 0
	local maxDisplayPercent = 0.97 --到达这个百分比之后，进度条就到达顶端了
	local firstGetPercent = 0.115-- 第一个超过此，才会获得奖励
	--log_tree("IceLuckyGemUI.Snatch_Count_Stages :" , Snatch_Count_Stages, "test")

	--log("IceLuckyGemUI.BP_Ice_Gem_Snatch_Count:" .. BP_Ice_Gem_Snatch_Count)
	if BP_Ice_Gem_Snatch_Count >= Snatch_Count_Stages[#Snatch_Count_Stages] then
		percent = 1
	else
		for i, SnatchCount in ipairs(Snatch_Count_Stages) do
			local CurrLen = i == 1 and firstGetPercent or (maxDisplayPercent - firstGetPercent) / (#Snatch_Count_Stages - 1)
			--log("IceLuckyGemUI.CurrLen:" .. CurrLen)
			if BP_Ice_Gem_Snatch_Count > SnatchCount then
				percent = percent + CurrLen
				--log("IceLuckyGemUI.percent:" .. percent)
			else
				local lastCount = (Snatch_Count_Stages[i - 1] or 0)
				percent = percent + (BP_Ice_Gem_Snatch_Count - lastCount) / (SnatchCount - lastCount) * CurrLen
				--log("IceLuckyGemUI.percent:" .. percent)
				break
			end
		end
	end

	BP_Ice_Gem_Progress_Bar_Percent_f = percent
	
    LuaClassObj.HandleUIMessageNoFetch(bp_ice_lucky_gem, "RefreshAccAward");
end

function IceLuckyGemUI.OnSnatchAwardResult()

	-- if true then
	-- 	local Trick_Result_Items = {}
	-- 	table.insert(Trick_Result_Items, 1400327);
	--  	LogicIceLuckyGem.on_hy_lottery(true, 330, Trick_Result_Items)
	-- end

	BP_Ice_Gem_Curr_Result_Index = 1 --当前抽奖的次数                              
	BP_Ice_Gem_Max_Result_Index = #LogicIceLuckyGem.Snatch_Result_Indexs --最大抽奖次数

	BP_ARRAY_Ice_Gem_Lucky_Result = LogicIceLuckyGem.Snatch_Result

	--if BP_Ice_Gem_Ignore_Ani then
	--	LuaClassObj.HandleUIMessageNoFetch(bp_ice_lucky_gem, "PlayLuckyAni");
	--else
	--	LuaClassObj.HandleUIMessageNoFetch(bp_ice_lucky_gem, "InitAwardAni");
	--end

	log("IceLuckyGemUI.BP_Ice_Gem_Ignore_Ani:" .. tostring(BP_Ice_Gem_Ignore_Ani))
	
	if BP_Ice_Gem_Ignore_Ani then
		IceLuckyGemUI.EndAni()
	else
		IceLuckyGemUI.StartAni()
	end
	
	LuaClassObj.HandleUIMessageNoFetch(bp_ice_lucky_gem, "RefreshMask");
end

function IceLuckyGemUI.CheckCanClick()
	if FuncUtil.GetServerTimeInSec() - IceLuckyGemUI.LastSnatchTime < IceLuckyGemUI.MinSnatchTime then
		IceLuckyGemUI.LastSnatchTime = FuncUtil.GetServerTimeInSec()
		return false
	end

	IceLuckyGemUI.LastSnatchTime = FuncUtil.GetServerTimeInSec()
	
	return true
end
--敲门
function EventHalloweenSnatchOneClicked()
	log("EventHalloweenSnatchOneClicked")

	if BP_Ice_Gem_Is_Show_Detail_Task or BP_Ice_Gem_Curr_Result_Index ~=0 then
		return
	end

	if not IceLuckyGemUI.CheckCanClick() then
		return
	end
	
	if BP_Ice_Gem_Ticket_Count >= BP_ARRAY_Ice_Gem_Lucky_Ticket[1] then
		IceLuckyGemUI.SnatchOne()
	else
	 	local strBuy = FuncUtil.GetLocalizeResStr("301185");
    	--local tip = string.format(FuncUtil.GetLocalizeResStr("6149"), BP_ARRAY_Ice_Gem_Lucky_UC[1], 1)
    	local tip = GlobalData.GetLocalizeStringWithNum(6149, 1, tostring(BP_ARRAY_Ice_Gem_Lucky_UC[1]), "1")
    	CommonMessageBoxUI:ShowPanel(2, strBuy, tip,  IceLuckyGemUI.SnatchOne);	
	end
	--hy_lottery_rsp
end

--敲5次门
function EventHalloweenSnatchFiveClicked()
	log("EventHalloweenSnatchFiveClicked:")

	if BP_Ice_Gem_Is_Show_Detail_Task or BP_Ice_Gem_Curr_Result_Index ~=0  then
		return
	end

	if not IceLuckyGemUI.CheckCanClick() then
		return
	end

	if BP_Ice_Gem_Ticket_Count >= BP_ARRAY_Ice_Gem_Lucky_Ticket[2] then
		IceLuckyGemUI.SnatchFive()
	else
	 	local strBuy = FuncUtil.GetLocalizeResStr("301185");
	    --local tip = string.format(FuncUtil.GetLocalizeResStr("6149"), BP_ARRAY_Ice_Gem_Lucky_UC[2], 5)
	    local tip = GlobalData.GetLocalizeStringWithNum(6149, 1, tostring(BP_ARRAY_Ice_Gem_Lucky_UC[2]), "5")
	    CommonMessageBoxUI:ShowPanel(2, strBuy, tip,  IceLuckyGemUI.SnatchFive);
    end

end

function IceLuckyGemUI.SnatchOne()

	if BP_Ice_Gem_Ticket_Count >= BP_ARRAY_Ice_Gem_Lucky_Ticket[1] then
		LogicIceLuckyGem.have_draw_req(3)
	else
		LogicIceLuckyGem.have_draw_req(1) 
	end
end


function IceLuckyGemUI.SnatchFive()

	
	if BP_Ice_Gem_Ticket_Count >= BP_ARRAY_Ice_Gem_Lucky_Ticket[2] then
		LogicIceLuckyGem.have_draw_req(4) 
	else
		LogicIceLuckyGem.have_draw_req(2)
	end
end

--点击弹出领取奖励
function EventIceLuckyPopupAwardClicked()
	log("EventIceLuckyPopupAwardClicked")

	if BP_Ice_Gem_Is_Show_Detail_Task or BP_Ice_Gem_Curr_Result_Index ~=0  then
		return
	end

	if not IceLuckyGemUI.CheckCanClick() then
		return
	end
	
	for i,v in ipairs(BP_ARRAY_Ice_Gem_Acc_Awards) do
		if v.awardId == BP_Ice_Gem_Clicked_Award_Id then
			IceLuckyAwardUI.SetData(v)
			IceLuckyAwardUI.ShowUI()
			return
		end
	end
	log("EventIceLuckyPopupAwardClicked not find")
end

function EventIceLuckyRateClicked()
	if BP_Ice_Gem_Is_Show_Detail_Task or BP_Ice_Gem_Curr_Result_Index ~=0  then
		return
	end

	if not IceLuckyGemUI.CheckCanClick() then
		return
	end
	
	local RateStr = "0,0,15%,57%,25.25%,2.75%,0,0"
	local rate = Rate_Panel_UI.StrSplit(RateStr, ",")

	Rate_Panel_UI.Show(rate, 6153);
end

function EventIceLuckyHideUI()
	IceLuckyGemUI.HideUI(true)
	
end

function EventIceLuckyTaskClick()
	log("EventIceLuckyTaskClick:" .. BP_Ice_Gem_Clicked_Task_Id)

	if BP_Ice_Gem_Curr_Result_Index ~=0  then
		return
	end

	if not IceLuckyGemUI.CheckCanClick() then
		return
	end

	for i,task in ipairs(BP_ARRAY_Ice_Gem_Tasks) do
		if task.taskId == BP_Ice_Gem_Clicked_Task_Id then
			if task.status == 1 then
				LogicIceLuckyGem.take_award_of_task_req(BP_Ice_Gem_Clicked_Task_Id)
			elseif task.status == 0 then
				if task.jumpTo ~= "" then
					IceLuckyGemUI.HideUI(false)
					GlobalData:JumpUrl(task.jumpTo)
				end
			end
		end
	end

    --status = 0, --0 表示未完成，1 表示已完成，可领取 2 已领取奖励
end

function EventIceLuckyTaskShowOrHideClick()
	log("EventIceLuckyTaskShowOrHideClick")
	LuaClassObj.HandleUIMessageNoFetch(bp_ice_lucky_gem, "RefreshShowTask");
	LuaClassObj.HandleUIMessageNoFetch(bp_ice_lucky_gem, "RefreshMask");
end

function EventIceLuckyRefreshPos()
	log("EventIceLuckyRefreshPos")
	LuaClassObj.HandleUIMessage(bp_common_itemtips_panel, "InitPos");
end

function EventIceLuckyOpenLaboratory()
	log("EventIceLuckyOpenLaboratory")
	IceLuckyGemUI.HideUI(false)
	ItemUpgradeUI.ShowByItemID(BP_Ice_Gem_Gun_Id)
end