-- 万圣节载具 捣蛋活动
HalloweenVehicleTrickUI = HalloweenVehicleTrickUI or {
	RotateAni_LastDeltaAngle= 0, --记录上次增加的角度
	RotateAni_LastAngleValue= 0, --记录上次的曲线值
	RotateAni_LastDelta = 0, --上次的Delta
	RotateAni_CurrStepTime = 0,
	RotateAni_AngleInterval= 30, --总共12个，360度，每个30度
	RotateAni_Step2_Angle =  0,--旋转某个角度，这个会计算出来
	RotateAni_MaxIndex = 12, --最大的index
	RotateAni_LastTargetIndex = 0, --上次目标的index

	RotateAni_Step1_Angle =  180,--首先旋转的度数度
	RotateAni_Step3_Angle =  180,--最后再旋转的度数度 RotateAni_Step1_Angle + RotateAni_Step3_Angle 需要为360的倍数
	RotateAni_CurrStep = 1, -- 当前旋转到第几步了

	RotateAni_Step2_Speed = 0, --旋转动画第二阶段旋转速度

	TrickClick_CurrCount = 0, --当前抽奖的次数                              
	TrickClick_MaxCount = 0, --最大抽奖次数
	TrickAction_Status = 0, --0表示正常状态，1，表示界面弹出开始，2 表示旋转开始 3 表示展示奖励开始 4 表示展示幸运值 5 界面返回
                                      --如果是多次抽奖的话，会在2和3之间循环
    OutAni_Time = 0.5, --界面展开动画时间
    OutAni_CurrTime = 0, --当前时间

    TrickItemIds2Index = {},--捣蛋的物品的Id，映射到index
    TrickItemIndexTb = {}, --捣蛋结果的Index 

    AwardShow_Time = 0.6, --奖励展示时间
    AwardShow_CurrTime = 0, --当前时间

    LuckyAni_Time = 0.8, --幸运值动画时间
    LuckyAni_CurrTime = 0, --当前时间
    LuckyUpAni_TimeRange = 2, --幸运值上涨动画的时间范围
    HasPlayOutAniForward = false,
	isShow = false,
};

BP_Halloween_Vehicle_DateTime = "" --万圣节活动时间
BP_Halloween_Vehicle_CandyCount = 0 --玩家拥有的糖果数量
BP_Halloween_Vehicle_Ignore_Ani = false --是否跳过敲门动画
BP_Halloween_Vehicle_Lucky_Value = 0 --幸运值
BP_Halloween_Vehicle_Lucky_MaxValue = 1000 --最大的幸运值
BP_Halloween_Vehicle_Trick_Count = 0 --累计捣蛋次数

BP_Halloween_Vehicle_Ticket_Count = 0 --捣蛋券个数
BP_Halloween_Vehicle_Ticket_Id = 1602036 --捣蛋券个数

BP_Halloween_Vehicle_Award_Radius = 185 --奖励的半径

BP_Halloween_Player_Ticket_Count = 0 --玩家uc

BP_STRUCT_Halloween_Vehicle_Item_Info = { --物品信息
	itemId = 0,
	itemCount = 1,
	index = 1, --在物品中的顺序
	itemExpireTime = 0,
}

BP_ARRAY_Halloween_Vehicle_Items = { --物品列表
	BP_STRUCT_Halloween_Vehicle_Item_Info = _G.BP_STRUCT_Halloween_Vehicle_Item_Info
}

BP_Halloween_Vehicle_Clicked_Award_Id = 0 --点击领取的奖励ID

BP_STRUCT_Halloween_Vehicle_Award_Status = {
	awardId = 0, --奖励id
	trickCount = 0, -- 捣蛋次数
	status = 0, --0 表示未领取，1 表示可领取 2 表示已领取
	lottery_num = 0, -- 需要达到的次数
	BP_ARRAY_Halloween_Vehicle_Items = _G.BP_ARRAY_Halloween_Vehicle_Items --奖励的物品
}

BP_ARRAY_Halloween_Vehicle_Awards = { --所有的奖励
	BP_STRUCT_Halloween_Vehicle_Award_Status = _G.BP_STRUCT_Halloween_Vehicle_Award_Status
}

BP_ARRAY_Halloween_Vehicle_Trick_Items = {--捣蛋的物品
	BP_STRUCT_Halloween_Vehicle_Item_Info = _G.BP_STRUCT_Halloween_Vehicle_Item_Info
} 

--捣蛋结果，捣蛋一次的，只有一个，捣蛋5次就会有五个
BP_ARRAY_Halloween_Vehicle_Trick_Result = {
	BP_STRUCT_Halloween_Vehicle_Item_Info = _G.BP_STRUCT_Halloween_Vehicle_Item_Info
}

--捣蛋需要的UC
BP_ARRAY_Halloween_Vehicle_Trick_UC = 
{
	0 --
}

--捣蛋需要的Ticket
BP_ARRAY_Halloween_Vehicle_Trick_Ticket = 
{
	0 --
}


--道具数量
BP_Halloween_Vehicle_Prop_Count = 0

--动画数据---
--先旋转BP_Halloween_RotateAni_MinAngle后，然后旋转到目标位置
BP_Halloween_RotateCurve_CurrTime_f = 0 --当前曲线的时间，用来同步时间
BP_Halloween_RotateCurve_CurrValue_f = 0 --当前曲线的值，用来同步时间
BP_Halloween_RotateAni_CurrAngle_f = 0 --当前的角度
BP_Halloween_RotateAni_TargetIndex = 1 --目标的index
BP_Halloween_RotateAni_IsPlaying = false --是否播放旋转动画
BP_Halloween_RotateAni_LastAngle_f = 0 --上一次动画停留的位置

function bp_halloween_vehicle_trick_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_halloween_vehicle_trick,
                                {{Path="/Game/UMG/UI_Logic/HalloweenVehicle/Halloween_Vehicle_trick_BP.Halloween_Vehicle_trick_BP_C", Container="Default", ZOrder=BP_ENUM_UI_HALLOWEEN_VEHICLE_ZORDER}},
                                {"Lobby"},
                                false,
                                false,
                                true);

end

function HalloweenVehicleTrickUI.InitAniData(SumAngle)
	SumAngle = 360 * math.floor(SumAngle / 360 + 0.5) --规整到360的倍数
	HalloweenVehicleTrickUI.RotateAni_Step1_Angle =  SumAngle/2 --首先旋转的度数

	HalloweenVehicleTrickUI.RotateAni_Step3_Angle =  SumAngle/2 --最后再旋转的度数
end

function HalloweenVehicleTrickUI.GetCurveValue(Time)
	BP_Halloween_RotateCurve_CurrTime_f = Time
	LuaClassObj.HandleUIMessageNoFetch(bp_halloween_vehicle_trick, "GetCurveValue")
end

function HalloweenVehicleTrickUI.OnJumpUrl(eventType, eventID, vars)
    log("HalloweenVehicleTrickUI.OnJumpUrl");
    HalloweenVehicleTrickUI.ShowUI();
end

function HalloweenVehicleTrickUI.StartAni(TargetIndex)
	if BP_Halloween_RotateAni_IsPlaying then
		return
	end

	if HalloweenVehicleTrickUI.RotateAni_LastTargetIndex <= 0 then
		HalloweenVehicleTrickUI.RotateAni_LastTargetIndex = 1
	end


	if TargetIndex - HalloweenVehicleTrickUI.RotateAni_LastTargetIndex >= 0 then
		HalloweenVehicleTrickUI.RotateAni_Step2_Angle = (TargetIndex - HalloweenVehicleTrickUI.RotateAni_LastTargetIndex) * HalloweenVehicleTrickUI.RotateAni_AngleInterval
	else
		HalloweenVehicleTrickUI.RotateAni_Step2_Angle = (TargetIndex - HalloweenVehicleTrickUI.RotateAni_LastTargetIndex + HalloweenVehicleTrickUI.RotateAni_MaxIndex) * HalloweenVehicleTrickUI.RotateAni_AngleInterval
	end

	BP_Halloween_RotateAni_CurrAngle_f = 0 --当前的角度
	BP_Halloween_RotateAni_TargetIndex = TargetIndex --目标的index

	HalloweenVehicleTrickUI.RotateAni_CurrStepTime = 0
	HalloweenVehicleTrickUI.RotateAni_CurrStep = 1
	HalloweenVehicleTrickUI.RotateAni_LastAngleValue = 0


	log("UpdateAni:RotateAni_LastTargetIndex:" .. HalloweenVehicleTrickUI.RotateAni_LastTargetIndex .. " RotateAni_Step2_Angle:" ..
		HalloweenVehicleTrickUI.RotateAni_Step2_Angle)

	BP_Halloween_RotateAni_IsPlaying = true

end

function HalloweenVehicleTrickUI.Update(DeltaTime)
	--log("HalloweenVehicleTrickUI.Update: TrickAction_Status:" .. HalloweenVehicleTrickUI.TrickAction_Status .. " DeltaTime:" .. DeltaTime)

	if HalloweenVehicleTrickUI.TrickAction_Status == 1 then
		HalloweenVehicleTrickUI.OutAni_CurrTime = HalloweenVehicleTrickUI.OutAni_CurrTime + DeltaTime
		if HalloweenVehicleTrickUI.OutAni_CurrTime >= HalloweenVehicleTrickUI.OutAni_Time then
			HalloweenVehicleTrickUI.TrickAction_Status = 2

			HalloweenVehicleTrickUI.OutAni_CurrTime = 0

			LuaClassObj.HandleUIMessageNoFetch(bp_halloween_vehicle_trick, "StartRotate");

			HalloweenVehicleTrickUI.DoShowResult()
		end
	elseif HalloweenVehicleTrickUI.TrickAction_Status == 2 then
		if BP_Halloween_Vehicle_Ignore_Ani or HalloweenVehicleTrickUI.UpdateAni(DeltaTime) then

			if BP_Halloween_Vehicle_Ignore_Ani then
				HalloweenVehicleTrickUI.EndRotateAni()
				LuaClassObj.HandleUIMessageNoFetch(bp_halloween_vehicle_trick, "RefreshAni");
			end

			HalloweenVehicleTrickUI.TrickAction_Status = 3
    		HalloweenVehicleTrickUI.AwardShow_CurrTime = 0 --当前时间
    		

    		LuaClassObj.HandleUIMessageNoFetch(bp_halloween_vehicle_trick, "EndRotate");

    		local TargetTb = LogicHalloweenVehicle.Trick_Result[HalloweenVehicleTrickUI.TrickClick_CurrCount]
			local TargetIndex = HalloweenVehicleTrickUI.TrickClick_CurrCount
			table.insert(BP_ARRAY_Halloween_Vehicle_Trick_Result, { itemId = TargetTb.item_id, itemCount = 1,index = TargetIndex})

			LuaClassObj.HandleUIMessageNoFetch(bp_halloween_vehicle_trick, "RefreshTrackAward");
			LuaClassObj.HandleUIMessageNoFetch(bp_halloween_vehicle_trick, "ShowRightAward");
		end
	elseif HalloweenVehicleTrickUI.TrickAction_Status == 3 then
		if BP_Halloween_Vehicle_Ignore_Ani then
			HalloweenVehicleTrickUI.TrickAction_Status = 4
			HalloweenVehicleTrickUI.LuckyAni_CurrTime = 0
			LuaClassObj.HandleUIMessageNoFetch(bp_halloween_vehicle_trick, "PlayLuckyAni");
		end

		HalloweenVehicleTrickUI.AwardShow_CurrTime = HalloweenVehicleTrickUI.AwardShow_CurrTime + DeltaTime
		if HalloweenVehicleTrickUI.AwardShow_CurrTime >= HalloweenVehicleTrickUI.AwardShow_Time then    
			if HalloweenVehicleTrickUI.TrickClick_CurrCount < HalloweenVehicleTrickUI.TrickClick_MaxCount then
				HalloweenVehicleTrickUI.TrickAction_Status = 2

				LuaClassObj.HandleUIMessageNoFetch(bp_halloween_vehicle_trick, "StartRotate");

				HalloweenVehicleTrickUI.TrickClick_CurrCount = HalloweenVehicleTrickUI.TrickClick_CurrCount + 1
				HalloweenVehicleTrickUI.DoShowResult()
			else	
				HalloweenVehicleTrickUI.TrickAction_Status = 4
				HalloweenVehicleTrickUI.LuckyAni_CurrTime = 0
				--LuaClassObj.HandleUIMessageNoFetch(bp_halloween_vehicle_trick, "ScrollToEnd");
				LuaClassObj.HandleUIMessageNoFetch(bp_halloween_vehicle_trick, "PlayLuckyAni");
			end
		end
	elseif HalloweenVehicleTrickUI.TrickAction_Status == 4 then
		HalloweenVehicleTrickUI.LuckyAni_CurrTime = HalloweenVehicleTrickUI.LuckyAni_CurrTime + DeltaTime

		if HalloweenVehicleTrickUI.LuckyAni_CurrTime >= HalloweenVehicleTrickUI.LuckyAni_Time - 0.3 then    
			HalloweenVehicleTrickUI.UpdateLucky(LogicHalloweenVehicle.Lucky_Value) 
		end

		if HalloweenVehicleTrickUI.LuckyAni_CurrTime >= HalloweenVehicleTrickUI.LuckyAni_Time then    
			HalloweenVehicleTrickUI.TrickAction_Status = 5
			log("HalloweenVehicleTrickUI.Update: PlayOutAniReverse")

			if HalloweenVehicleTrickUI.HasPlayOutAniForward then
				LuaClassObj.HandleUIMessageNoFetch(bp_halloween_vehicle_trick, "PlayOutAniReverse");
				HalloweenVehicleTrickUI.HasPlayOutAniForward = false
			end

			HalloweenVehicleTrickUI.UpdateLucky(LogicHalloweenVehicle.Lucky_Value) 
		end
	elseif HalloweenVehicleTrickUI.TrickAction_Status == 5 then
		HalloweenVehicleTrickUI.OutAni_CurrTime = HalloweenVehicleTrickUI.OutAni_CurrTime + DeltaTime
		if HalloweenVehicleTrickUI.OutAni_CurrTime >= HalloweenVehicleTrickUI.OutAni_Time then
			HalloweenVehicleTrickUI.TrickAction_Status = 0
			HalloweenVehicleTrickUI.OutAni_CurrTime = 0

			local Result = {}
			local checkShowTips = false;
			for i,v in ipairs(LogicHalloweenVehicle.Trick_Result) do
				table.insert(Result, {res_id = v.item_id, count = v.item_num, valid_hours = 0})
				if v.item_id == LogicHalloweenVehicle.CandyId then
					checkShowTips = true;
				end
			end

			BP_ARRAY_Halloween_Vehicle_Trick_Result = {}
			LuaClassObj.HandleUIMessageNoFetch(bp_halloween_vehicle_trick, "RefreshTrackAward");
			LuaClassObj.HandleUIMessageNoFetch(bp_halloween_vehicle_trick, "HideRightAward");
			

			if checkShowTips == true then
				HalloweenVehicleTrickUI.CheckShowExchangeTips();
			end

			CommonItemGetUI:ShowPanel(Result);
		end
	end

end

function HalloweenVehicleTrickUI.GetLuckyTimeRange()
	
	local currTime = BP_Halloween_Vehicle_Lucky_Value / BP_Halloween_Vehicle_Lucky_MaxValue * HalloweenVehicleTrickUI.LuckyUpAni_TimeRange
	local TargetTime = LogicHalloweenVehicle.Lucky_Value / BP_Halloween_Vehicle_Lucky_MaxValue * HalloweenVehicleTrickUI.LuckyUpAni_TimeRange
	
	--这三个判断的目的是为了保持当前时间小于目标时间
	if currTime == HalloweenVehicleTrickUI.LuckyUpAni_TimeRange then
		currTime = currTime - 0.01
	end

	if currTime > TargetTime then
		currTime = 0
	end

	if TargetTime <= currTime then
		TargetTime = currTime + 0.01
	end

	return currTime, TargetTime
end

function HalloweenVehicleTrickUI.UpdateAni(DeltaTime)
	local IsFinish = false
	if not BP_Halloween_RotateAni_IsPlaying  then
		return IsFinish
	end

	--log("UpdateAni,CurrStep:" .. HalloweenVehicleTrickUI.RotateAni_CurrStep .. ",CurrAngle:" .. BP_Halloween_RotateAni_CurrAngle_f
		--.. ",Curve_CurrValue:" .. BP_Halloween_RotateCurve_CurrValue_f .. ",CurrStepTime:" .. HalloweenVehicleTrickUI.RotateAni_CurrStepTime)
	if HalloweenVehicleTrickUI.RotateAni_CurrStep == 1 then --旋转第一阶段

		HalloweenVehicleTrickUI.RotateAni_CurrStepTime = HalloweenVehicleTrickUI.RotateAni_CurrStepTime + DeltaTime 
		HalloweenVehicleTrickUI.GetCurveValue(HalloweenVehicleTrickUI.RotateAni_CurrStepTime)
		local DeltaAngle = BP_Halloween_RotateCurve_CurrValue_f - HalloweenVehicleTrickUI.RotateAni_LastAngleValue

		BP_Halloween_RotateAni_CurrAngle_f = BP_Halloween_RotateAni_CurrAngle_f + DeltaAngle

		if BP_Halloween_RotateAni_CurrAngle_f > HalloweenVehicleTrickUI.RotateAni_Step1_Angle then

			HalloweenVehicleTrickUI.RotateAni_CurrStep = 2
			--log("UpdateAni,1->2, RotateAni_Step1_Angle" .. HalloweenVehicleTrickUI.RotateAni_Step1_Angle .. ",CurrAngle:" .. BP_Halloween_RotateAni_CurrAngle_f
		--.. ",DeltaAngle:" .. DeltaAngle)
		end
		
		HalloweenVehicleTrickUI.RotateAni_LastDeltaAngle = DeltaAngle
		HalloweenVehicleTrickUI.RotateAni_LastDelta = DeltaTime
		HalloweenVehicleTrickUI.RotateAni_LastAngleValue = BP_Halloween_RotateCurve_CurrValue_f
		HalloweenVehicleTrickUI.RotateAni_Step2_Speed = HalloweenVehicleTrickUI.RotateAni_LastDeltaAngle / HalloweenVehicleTrickUI.RotateAni_LastDelta
	elseif HalloweenVehicleTrickUI.RotateAni_CurrStep == 2 then --旋转第二阶段
		--log("UpdateAni:RotateAni_Step1_Angle:" .. HalloweenVehicleTrickUI.RotateAni_Step1_Angle .. " RotateAni_Step2_Angle:" ..
		--HalloweenVehicleTrickUI.RotateAni_Step2_Angle .. " Add:" .. HalloweenVehicleTrickUI.RotateAni_LastDeltaAngle * DeltaTime / HalloweenVehicleTrickUI.RotateAni_LastDelta)
		
		BP_Halloween_RotateAni_CurrAngle_f = BP_Halloween_RotateAni_CurrAngle_f + HalloweenVehicleTrickUI.RotateAni_Step2_Speed * DeltaTime
		
		local DiffValue = BP_Halloween_RotateAni_CurrAngle_f -  (HalloweenVehicleTrickUI.RotateAni_LastAngleValue + HalloweenVehicleTrickUI.RotateAni_Step2_Angle + 0.01) --加0.1是为了防止抖动

		if DiffValue >= 0  then 
			--如果差值超过了0.5度，那么通过曲线偏移来处理
			if DiffValue >= 0.5 then
				HalloweenVehicleTrickUI.RotateAniStep2DiffTime(DiffValue)
			end

			HalloweenVehicleTrickUI.RotateAni_CurrStep = 3

			--log("UpdateAni,2->3, RotateAni_Step2_Angle" .. (HalloweenVehicleTrickUI.RotateAni_Step1_Angle + HalloweenVehicleTrickUI.RotateAni_Step2_Angle + 10) .. ",CurrAngle:" .. BP_Halloween_RotateAni_CurrAngle_f)
		end
	elseif HalloweenVehicleTrickUI.RotateAni_CurrStep == 3 then --旋转第三阶段
		HalloweenVehicleTrickUI.RotateAni_CurrStepTime = HalloweenVehicleTrickUI.RotateAni_CurrStepTime + DeltaTime

		HalloweenVehicleTrickUI.GetCurveValue(HalloweenVehicleTrickUI.RotateAni_CurrStepTime)
		local DeltaAngle = BP_Halloween_RotateCurve_CurrValue_f - HalloweenVehicleTrickUI.RotateAni_LastAngleValue

		if DeltaAngle <= 0 then
			DeltaAngle = HalloweenVehicleTrickUI.RotateAni_LastDeltaAngle
		end
		local sumAngle = HalloweenVehicleTrickUI.RotateAni_Step1_Angle + HalloweenVehicleTrickUI.RotateAni_Step2_Angle + HalloweenVehicleTrickUI.RotateAni_Step3_Angle
		
		BP_Halloween_RotateAni_CurrAngle_f = BP_Halloween_RotateAni_CurrAngle_f + DeltaAngle

		if BP_Halloween_RotateAni_CurrAngle_f > sumAngle then

		-- log("UpdateAni,3->0, sumAngle" .. sumAngle .. ",CurrAngle:" .. BP_Halloween_RotateAni_CurrAngle_f
		-- .. ",DeltaAngle:" .. DeltaAngle)

			HalloweenVehicleTrickUI.EndRotateAni()

			IsFinish = true
		end
		
		HalloweenVehicleTrickUI.RotateAni_LastDeltaAngle = DeltaAngle
		HalloweenVehicleTrickUI.RotateAni_LastAngleValue = BP_Halloween_RotateCurve_CurrValue_f
	end




	--log("UpdateAni:DeltaTime:" .. DeltaTime .. " RotateAni_CurrStepTime:" .. HalloweenVehicleTrickUI.RotateAni_CurrStepTime
	--	.." RotateAni_CurrStep:" .. HalloweenVehicleTrickUI.RotateAni_CurrStep .. " RotateAni_LastDeltaAngle:" .. HalloweenVehicleTrickUI.RotateAni_LastDeltaAngle
	--	.. " BP_Halloween_RotateAni_CurrAngle_f:" .. BP_Halloween_RotateAni_CurrAngle_f)

	--log("UpdateAni:BP_Halloween_RotateCurve_CurrValue_f:" .. BP_Halloween_RotateCurve_CurrValue_f .. " BP_Halloween_RotateAni_LastAngle_f:" ..
	--	BP_Halloween_RotateAni_LastAngle_f)

	LuaClassObj.HandleUIMessageNoFetch(bp_halloween_vehicle_trick, "RefreshAni");

	return IsFinish
end

--旋转第二步，时间偏差处理，此处是为了把时间推移到曲线中
function HalloweenVehicleTrickUI.RotateAniStep2DiffTime(DiffValue)
	local NeedTime = DiffValue / HalloweenVehicleTrickUI.RotateAni_Step2_Speed
	local IntervalTime = NeedTime / 100

	repeat  --先找到大于此值得时间
		HalloweenVehicleTrickUI.GetCurveValue(HalloweenVehicleTrickUI.RotateAni_CurrStepTime + NeedTime)
		local DeltaAngle = BP_Halloween_RotateCurve_CurrValue_f - HalloweenVehicleTrickUI.RotateAni_LastAngleValue
		if DeltaAngle >= DiffValue then
			break
		end
		NeedTime = NeedTime + IntervalTime
	until false

	repeat --然后找到小于此值得时间
		NeedTime = NeedTime - IntervalTime
		HalloweenVehicleTrickUI.GetCurveValue(HalloweenVehicleTrickUI.RotateAni_CurrStepTime + NeedTime)
		local DeltaAngle = BP_Halloween_RotateCurve_CurrValue_f - HalloweenVehicleTrickUI.RotateAni_LastAngleValue
		if DeltaAngle <= DiffValue then
			break
		end
	until false

	HalloweenVehicleTrickUI.RotateAni_CurrStepTime = HalloweenVehicleTrickUI.RotateAni_CurrStepTime + NeedTime
	HalloweenVehicleTrickUI.RotateAni_LastAngleValue = BP_Halloween_RotateCurve_CurrValue_f
end

--旋转结束处理
function HalloweenVehicleTrickUI.EndRotateAni()
	local sumAngle = HalloweenVehicleTrickUI.RotateAni_Step1_Angle + HalloweenVehicleTrickUI.RotateAni_Step2_Angle + HalloweenVehicleTrickUI.RotateAni_Step3_Angle
	BP_Halloween_RotateAni_CurrAngle_f = sumAngle
	HalloweenVehicleTrickUI.RotateAni_CurrStepTime = 0
	HalloweenVehicleTrickUI.RotateAni_CurrStep = 1
	BP_Halloween_RotateAni_IsPlaying = false
	HalloweenVehicleTrickUI.RotateAni_LastTargetIndex = BP_Halloween_RotateAni_TargetIndex
	BP_Halloween_RotateAni_LastAngle_f = BP_Halloween_RotateAni_CurrAngle_f + BP_Halloween_RotateAni_LastAngle_f --记录上一次的的角度

	if BP_Halloween_RotateAni_LastAngle_f > 360 then
		BP_Halloween_RotateAni_LastAngle_f = BP_Halloween_RotateAni_LastAngle_f - 360
	end

	BP_Halloween_RotateAni_CurrAngle_f = 0
end

function HalloweenVehicleTrickUI.ShowUI()
	log("HalloweenVehicleTrickUI.ShowUI")
	HalloweenVehicleTrickUI.isShow = true
	-- if true then
	-- 	BP_ARRAY_Halloween_Vehicle_Trick_Items = {}
	-- 	table.insert(BP_ARRAY_Halloween_Vehicle_Trick_Items, {itemId = 1400327, itemCount = 1, index = 1});
	-- 	table.insert(BP_ARRAY_Halloween_Vehicle_Trick_Items, {itemId = 1400329, itemCount = 1, index = 2});
	-- 	table.insert(BP_ARRAY_Halloween_Vehicle_Trick_Items, {itemId = 1400330, itemCount = 1, index = 3});
	-- 	table.insert(BP_ARRAY_Halloween_Vehicle_Trick_Items, {itemId = 1400332, itemCount = 1, index = 4});
	-- 	table.insert(BP_ARRAY_Halloween_Vehicle_Trick_Items, {itemId = 1400333, itemCount = 1, index = 5});
	-- 	table.insert(BP_ARRAY_Halloween_Vehicle_Trick_Items, {itemId = 1400334, itemCount = 1, index = 6});

	-- 	table.insert(BP_ARRAY_Halloween_Vehicle_Trick_Items, {itemId = 1400335, itemCount = 1, index = 7});
	-- 	table.insert(BP_ARRAY_Halloween_Vehicle_Trick_Items, {itemId = 1400336, itemCount = 1, index = 8});
	-- 	table.insert(BP_ARRAY_Halloween_Vehicle_Trick_Items, {itemId = 1400337, itemCount = 1, index = 9});
	-- 	table.insert(BP_ARRAY_Halloween_Vehicle_Trick_Items, {itemId = 1400338, itemCount = 1, index = 10});
	-- 	table.insert(BP_ARRAY_Halloween_Vehicle_Trick_Items, {itemId = 1400339, itemCount = 1, index = 11});
	-- 	table.insert(BP_ARRAY_Halloween_Vehicle_Trick_Items, {itemId = 1400341, itemCount = 1, index = 12});

	-- 	for i,v in ipairs(BP_ARRAY_Halloween_Vehicle_Trick_Items) do
	-- 		HalloweenVehicleTrickUI.TrickItemIds2Index[v.itemId] = v.index
	-- 	end
		
	-- end

	BP_Halloween_RotateCurve_CurrTime_f = 0 --当前曲线的时间，用来同步时间
	BP_Halloween_RotateCurve_CurrValue_f = 0 --当前曲线的值，用来同步时间
	BP_Halloween_RotateCurve_MaxTime = 2  --旋转动画，最大的时间
	BP_Halloween_RotateAni_CurrAngle_f = 0 --当前的角度
	BP_Halloween_RotateAni_TargetIndex = 1 --目标的index
	BP_Halloween_RotateAni_IsPlaying = false --是否播放旋转动画
	HalloweenVehicleTrickUI.RotateAni_LastTargetIndex = 0
	HalloweenVehicleTrickUI.RotateAni_CurrStepTime = 0
	HalloweenVehicleTrickUI.RotateAni_CurrStep = 1
	HalloweenVehicleTrickUI.RotateAni_LastAngleValue = 0
	BP_Halloween_RotateAni_LastAngle_f = 0

	BP_Halloween_Vehicle_Trick_Count = 0

	BP_Halloween_Vehicle_Ignore_Ani = false

	BP_ARRAY_Halloween_Vehicle_Trick_Result = {}

	BP_ARRAY_Halloween_Vehicle_Trick_UC = {120, 540}
	BP_ARRAY_Halloween_Vehicle_Trick_Ticket = LogicHalloweenVehicle.TrickTicket

	HalloweenVehicleTrickUI.TrickAction_Status = 0

	HalloweenVehicleTrickUI.HasPlayOutAniForward = false
    
    HalloweenVehicleTrickUI.RefreshData();

    BP_Halloween_Vehicle_CandyCount = LogicHalloweenVehicle.GetCandyCount()
 	BP_Halloween_Vehicle_Ticket_Count = LogicHalloweenVehicle.GetTicketCount()
	BP_Halloween_Player_Ticket_Count = DataMgr.ticket;

	BP_Halloween_Vehicle_Ticket_Id = LogicHalloweenVehicle.TicketId

    LogicHalloweenVehicle.get_vst_level_up_info();
    
    ---http://tapd.oa.com/iGameInternational/prong/stories/view/1020360302064020469 【活动】日韩专属升级摩托车 
    local strRegion = Client.GetPublishRegion();
    if strRegion == "JAPAN" or strRegion == "KOREA" then
        EventHalloweenOpenSkinClicked();
    else
        LuaClassObj.HandleDynamicCreation(bp_halloween_vehicle_trick);
        LuaClassObj.HandleUIMessage(bp_halloween_vehicle_trick, "UIShow");
        LuaClassObj.HandleUIMessageNoFetch(bp_halloween_vehicle_trick, "PlayLuckyAni");
        LogicHalloweenVehicle.query_lottery_award_info()
        LogicHalloweenVehicle.query_lottery_info_req()
        EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_DATA_CHANGE, HalloweenVehicleTrickUI.UpdateItemCount)
		EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_TICKET_CHANGE, HalloweenVehicleTrickUI.UpdateUC)
    end
end

function HalloweenVehicleTrickUI.UpdateItemCount()
	log("HalloweenVehicleTrickUI.UpdateItemCount")
 	BP_Halloween_Vehicle_CandyCount = LogicHalloweenVehicle.GetCandyCount()

 	BP_Halloween_Vehicle_Ticket_Count = LogicHalloweenVehicle.GetTicketCount()

 	LuaClassObj.HandleUIMessage(bp_halloween_vehicle_trick, "RefreshUI");
end

function HalloweenVehicleTrickUI.UpdateUC()
	BP_Halloween_Player_Ticket_Count = DataMgr.ticket;
end

function HalloweenVehicleTrickUI.SetTrick_Items(Items)
    BP_ARRAY_Halloween_Vehicle_Trick_Items = Items

    for i,v in ipairs(BP_ARRAY_Halloween_Vehicle_Trick_Items) do
		HalloweenVehicleTrickUI.TrickItemIds2Index[v.itemId] = v.index
	end

 	LuaClassObj.HandleUIMessageNoFetch(bp_halloween_vehicle_trick, "InitAwardImages");
end

function HalloweenVehicleTrickUI.GetItemIdByIndex(Index)
    for i,v in ipairs(BP_ARRAY_Halloween_Vehicle_Trick_Items) do
		if v.index == Index then
			return v.itemId
		end
	end

	return 0
end

function HalloweenVehicleTrickUI.UpdateLucky(Lucky) --是否在动画中更新
	BP_Halloween_Vehicle_Lucky_Value = Lucky
    LuaClassObj.HandleUIMessage(bp_halloween_vehicle_trick, "RefreshCommon");
end



function HalloweenVehicleTrickUI.HideUI()

	HalloweenVehicleTrickUI.isShow = false

    EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_DATA_CHANGE, HalloweenVehicleTrickUI.UpdateItemCount)

	EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_TICKET_CHANGE, HalloweenVehicleTrickUI.UpdateUC)

    LuaClassObj.HandleUIMessageNoFetch(bp_halloween_vehicle_trick, "UIHide");
end


function HalloweenVehicleTrickUI.RefreshData()--更新活动的新数据，包括状态更新
	local Start_Time, End_Time = LogicHalloweenVehicle.GetActivityTime()

	local beginTime = os.date("!%Y/%m/%d", Start_Time)
    local endTime = os.date("!%Y/%m/%d", End_Time)

    BP_Halloween_Vehicle_DateTime = beginTime .. "-" .. endTime
end

function HalloweenVehicleTrickUI.RefreshUI()
    HalloweenVehicleTrickUI.RefreshData();
    LuaClassObj.HandleUIMessage(bp_halloween_vehicle_trick, "RefreshUI");
end

function HalloweenVehicleTrickUI.JumpToIndex(TargetIndex)
	BP_Halloween_RotateAni_IsPlaying = false

	HalloweenVehicleTrickUI.RotateAni_LastTargetIndex = 0

	BP_Halloween_RotateAni_LastAngle_f = 0
	BP_Halloween_RotateAni_TargetIndex = TargetIndex --目标的index

	BP_Halloween_RotateAni_CurrAngle_f = (BP_Halloween_RotateAni_TargetIndex - 1) * HalloweenVehicleTrickUI.RotateAni_AngleInterval--当前的角度

	HalloweenVehicleTrickUI.RotateAni_CurrStepTime = 0
	HalloweenVehicleTrickUI.RotateAni_CurrStep = 1
	HalloweenVehicleTrickUI.RotateAni_LastAngleValue = 0

	LuaClassObj.HandleUIMessageNoFetch(bp_halloween_vehicle_trick, "RefreshAni");

	BP_Halloween_RotateAni_LastAngle_f = BP_Halloween_RotateAni_CurrAngle_f
	BP_Halloween_RotateAni_CurrAngle_f = 0

end

function HalloweenVehicleTrickUI.ItemId2Index(Result)
	local indexTb = {}
	for i,v in ipairs(Result) do
		table.insert(indexTb, HalloweenVehicleTrickUI.TrickItemIds2Index[v.item_id])
	end
	return indexTb
end

--刷新左侧抽奖奖励
function HalloweenVehicleTrickUI.RefreshNumAward(Result)
	log("HalloweenVehicleTrickUI.RefreshNumAward")
	BP_ARRAY_Halloween_Vehicle_Awards = {}
	--重新赋值排序,领取过的奖励排在后面
	for i,v in ipairs(Result) do
		table.insert(BP_ARRAY_Halloween_Vehicle_Awards, v)
	end

	-- BP_STRUCT_Halloween_Vehicle_Award_Status = {
	-- awardId = 0, --奖励id
	-- trickCount = 0, -- 捣蛋次数
	-- status = 0, --0 表示未领取，1 表示可领取 2 表示已领取
	-- lottery_num = 0, -- 需要达到的次数
	-- BP_ARRAY_Halloween_Vehicle_Items = _G.BP_ARRAY_Halloween_Vehicle_Items --奖励的物品


	--BP_ARRAY_Halloween_Vehicle_Awards = Result
	table.sort(BP_ARRAY_Halloween_Vehicle_Awards, 
		function(Award1, Award2)
			if Award1.status == 2 or  Award2.status == 2 then
				if Award1.status < Award2.status then
					return true
				elseif Award1.status == Award2.status then
					return Award1.lottery_num < Award2.lottery_num
				else
					return false
				end
			else
				return Award1.lottery_num < Award2.lottery_num
			end
		end)
	LuaClassObj.HandleUIMessageNoFetch(bp_halloween_vehicle_trick, "RefreshLeftAward");
end

function HalloweenVehicleTrickUI.OnTrickAwardResult(Result)
	HalloweenVehicleTrickUI.OutAni_CurrTime = 0
	-- if true then
	-- 	local Trick_Result_Items = {}
	-- 	table.insert(Trick_Result_Items, 1400327);
	--  	LogicHalloweenVehicle.on_hy_lottery(true, 330, Trick_Result_Items)
	-- end



	log_tree("OnTrickAwardResult:", Result)
	HalloweenVehicleTrickUI.TrickItemIndexTb = HalloweenVehicleTrickUI.ItemId2Index(Result)

	log_tree("TrickItemIndexTb:", HalloweenVehicleTrickUI.TrickItemIndexTb)
	HalloweenVehicleTrickUI.TrickClick_CurrCount = 1 --当前抽奖的次数                              
	HalloweenVehicleTrickUI.TrickClick_MaxCount = #HalloweenVehicleTrickUI.TrickItemIndexTb --最大抽奖次数

	if BP_Halloween_Vehicle_Ignore_Ani then
		HalloweenVehicleTrickUI.TrickAction_Status = 4
		HalloweenVehicleTrickUI.LuckyAni_CurrTime = 0
		LuaClassObj.HandleUIMessageNoFetch(bp_halloween_vehicle_trick, "PlayLuckyAni");
	else
		HalloweenVehicleTrickUI.TrickAction_Status = 1
		log("HalloweenVehicleTrickUI.Update: PlayOutAniForward")

		HalloweenVehicleTrickUI.HasPlayOutAniForward = true
		LuaClassObj.HandleUIMessageNoFetch(bp_halloween_vehicle_trick, "PlayOutAniForward");
		LuaClassObj.HandleUIMessageNoFetch(bp_halloween_vehicle_trick, "InitAwardAni");
	end

	-- if BP_Halloween_Vehicle_Ignore_Ani then
	-- 	local Result = {}
	-- 	for i,v in ipairs(LogicHalloweenVehicle.Trick_Result) do
	-- 		table.insert(Result, {res_id = v.item_id, count = v.item_num, valid_hours = 0})
	-- 	end
	-- 	CommonItemGetUI:ShowPanel(Result);
	-- end
end

function HalloweenVehicleTrickUI.DoShowResult()
	if HalloweenVehicleTrickUI.TrickClick_CurrCount <= HalloweenVehicleTrickUI.TrickClick_MaxCount then
		HalloweenVehicleTrickUI.StartAni(HalloweenVehicleTrickUI.TrickItemIndexTb[HalloweenVehicleTrickUI.TrickClick_CurrCount])
		-- if not BP_Halloween_Vehicle_Ignore_Ani then
		-- else
		-- 	HalloweenVehicleTrickUI.JumpToIndex(HalloweenVehicleTrickUI.TrickItemIndexTb[HalloweenVehicleTrickUI.TrickClick_CurrCount])
		-- end
	end
end

function HalloweenVehicleTrickUI.CheckShowExchangeTips()
	log("CheckShowExchangeTips");
	local skins = LogicHalloweenVehicle.Vehicle_Skin_Info1;
	log_tree("skins", skins);
	for i, v in ipairs(skins) do
		log("LogicHalloweenVehicle.GetCandyCount" .. LogicHalloweenVehicle.GetCandyCount());
		if v.status == 2 and v.costCandy <= LogicHalloweenVehicle.GetCandyCount() then
			log_tree("subskin", v);
			log("bp_halloween_vehicle_trick.ShowExchangeTips");
			LuaClassObj.HandleUIMessageNoFetch(bp_halloween_vehicle_trick, "ShowExchangeTips");
		end
	end
end

--敲门
function EventHalloweenTrickOneClicked()

	log("EventHalloweenTrickOneClicked:TrickAction_Status" .. HalloweenVehicleTrickUI.TrickAction_Status)

	
	if HalloweenVehicleTrickUI.TrickAction_Status ~= 0 then
		return 
	end

	if BP_Halloween_Vehicle_Ticket_Count >= BP_ARRAY_Halloween_Vehicle_Trick_Ticket[1] then
		LogicHalloweenVehicle.hy_lottery_req(1)
	else
	 	local strBuy = FuncUtil.GetLocalizeResStr("301185");
    	--local tip = string.format(FuncUtil.GetLocalizeResStr("6149"), BP_ARRAY_Halloween_Vehicle_Trick_UC[1], 1)
    	local tip = GlobalData.GetLocalizeStringWithNum(6149, 1, tostring(BP_ARRAY_Halloween_Vehicle_Trick_UC[1]), "1")
    	CommonMessageBoxUI:ShowPanel(2, strBuy, tip,  HalloweenVehicleTrickUI.TrickOne);	
	end
	--hy_lottery_rsp
end

--敲5次门
function EventHalloweenTrickFiveClicked()
	log("EventHalloweenTrickOneClicked:TrickAction_Status" .. HalloweenVehicleTrickUI.TrickAction_Status)

	if HalloweenVehicleTrickUI.TrickAction_Status ~= 0 then
		return 
	end

	if BP_Halloween_Vehicle_Ticket_Count >= BP_ARRAY_Halloween_Vehicle_Trick_Ticket[2] then
		LogicHalloweenVehicle.hy_lottery_req(5)
	else
	 	local strBuy = FuncUtil.GetLocalizeResStr("301185");
	    --local tip = string.format(FuncUtil.GetLocalizeResStr("6149"), BP_ARRAY_Halloween_Vehicle_Trick_UC[2], 5)
	    local tip = GlobalData.GetLocalizeStringWithNum(6149, 1, tostring(BP_ARRAY_Halloween_Vehicle_Trick_UC[2]), "5")
	    CommonMessageBoxUI:ShowPanel(2, strBuy, tip,  HalloweenVehicleTrickUI.TrickFive);
    end

end

function HalloweenVehicleTrickUI.TrickOne()
   	LogicHalloweenVehicle.hy_lottery_req(1)
end


function HalloweenVehicleTrickUI.TrickFive()
   	LogicHalloweenVehicle.hy_lottery_req(5)
end

--点击弹出领取奖励
function EventHalloweenPopupAwardClicked()
	log("EventHalloweenPopupAwardClicked")

	for i,v in ipairs(BP_ARRAY_Halloween_Vehicle_Awards) do
		if v.awardId == BP_Halloween_Vehicle_Clicked_Award_Id then
			HalloweenVehicleAwardUI.SetData(v)
			HalloweenVehicleAwardUI.ShowUI()
			return
		end
	end
	log("EventHalloweenPopupAwardClicked not find")
end

--点击弹出载具兑换界面
function EventHalloweenOpenSkinClicked()
	log("EventHalloweenOpenSkinClicked")

    LuaClassObj.HandleUIMessage(bp_halloween_vehicle_trick, "HideRoot");

	LuaClassObj.HandleUIMessage(bp_halloween_vehicle_trick, "HideExchangeTips");

    LuaClassObj.HandleUIMessageNoFetch(bp_halloween_vehicle_trick, "SetIsClickExchange");

	HalloweenVehicleSkinUI.ShowUI()
end

function EventHalloweenVehicleTrickUI_HideUI()
	HalloweenVehicleTrickUI.HideUI()
end

function EventHalloweenVehicleHelpClicked()
	local RateStr = "0,0,0,70%,27%,3%,,0";
	local rate = Rate_Panel_UI.StrSplit(RateStr, ",")

	Rate_Panel_UI.Show(rate, 6153);
end

function  EventGlobalShowItemTips_RefreshPos()
    LuaClassObj.HandleUIMessage(bp_common_itemtips_panel, "InitPos");
end

