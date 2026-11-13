LogicHalloweenVehicle = LogicHalloweenVehicle or
{
	Trick_Result = {}, --捣蛋的奖励
	Trick_Count_Awards = {}, --次数奖励
	lottery = {},
	Trick_Items = {},
	Lucky_Value = 0,
	Vehicle_Skin_Info1 = {},
	Vehicle_Skin_Info2 = {},
	VehicleSkinId = {},
	CandyId = 1602054,
	TicketId = 1602055,
	TrickTicket = {1, 5}, --捣蛋需要的券数量
	hy_data = {},
}


function LogicHalloweenVehicle.on_get_vst_level_up_info(rs, ha_vst_level_up, hy_data)
	log("on_get_vst_level_up_info" .. rs)
	if rs == "ok" then
		log_tree("LogicHalloweenVehicle.on_get_vst_level_up_info,ha_vst_level_up:", ha_vst_level_up);
		log_tree("LogicHalloweenVehicle.on_get_vst_level_up_info,hy_data:", hy_data);

		LogicHalloweenVehicle.Vehicle_Skin_Info1 = {}
		LogicHalloweenVehicle.Vehicle_Skin_Info2 = {}


		for i,v in ipairs(ha_vst_level_up) do
			local targetSkin_Info = v.list_id == 1 and LogicHalloweenVehicle.Vehicle_Skin_Info1 or LogicHalloweenVehicle.Vehicle_Skin_Info2
			
			local Info = {skinId = v.high_vst_ctrl, status = 0, costCandy = v.consum_item_num, fromSkinId = v.vst_id, lineId = v.list_id, index = #targetSkin_Info + 1}
			table.insert(targetSkin_Info, Info);
		
			LogicHalloweenVehicle.VehicleSkinId[v.high_vst_ctrl] = Info
		end
		log_tree("LogicHalloweenVehicle.Vehicle_Skin_Info1", LogicHalloweenVehicle.Vehicle_Skin_Info1);
		
		log_tree("LogicHalloweenVehicle.Vehicle_Skin_Info2", LogicHalloweenVehicle.Vehicle_Skin_Info2);
		
		
		
		LogicHalloweenVehicle.hy_data = hy_data
		LogicHalloweenVehicle.Refresh_hy_data(hy_data)
		HalloweenVehicleSkinUI.SetSkin_Info(LogicHalloweenVehicle.Vehicle_Skin_Info1, LogicHalloweenVehicle.Vehicle_Skin_Info2, true)
		local strRegion = Client.GetPublishRegion();
		if strRegion == "JAPAN" or strRegion == "KOREA" then
			EventHalloweenSkinViewClicked();
		end
	-- 	BP_ARRAY_Halloween_Vehicle_Skin_Info1 = {}
	-- 	table.insert(BP_ARRAY_Halloween_Vehicle_Skin_Info1, {skinId = 1903101, status = 0, costCandy = 1, fromSkinId = 0});
	-- 	table.insert(BP_ARRAY_Halloween_Vehicle_Skin_Info1, {skinId = 1903102, status = 0, costCandy = 1, fromSkinId = 1903101});
	-- 	table.insert(BP_ARRAY_Halloween_Vehicle_Skin_Info1, {skinId = 1903103, status = 0, costCandy = 1, fromSkinId = 1903102});

	end

end

-- LogNula: LuaLog: LogicHalloweenVehicle.on_get_vst_level_up_info,ha_vst_level_up:
-- LogNula: LuaLog: ├─ 1
-- LogNula: LuaLog: │  ├─ consum_item_num: 1
-- LogNula: LuaLog: │  ├─ vst_id: 0
-- LogNula: LuaLog: │  ├─ list_id: 1
-- LogNula: LuaLog: │  ├─ consum_item_id: 1602035
-- LogNula: LuaLog: │  └─ high_vst_ctrl: 1903101
-- LogNula: LuaLog: ├─ 2 ...
-- LogNula: LuaLog: ├─ 3 ...
-- LogNula: LuaLog: ├─ 4 ...
-- LogNula: LuaLog: ├─ 5 ...
-- LogNula: LuaLog: └─ 6 ...
-- LogNula: LuaLog: LogicHalloweenVehicle.on_get_vst_level_up_info,hy_data:
-- LogNula: LuaLog: ├─ vst_id: { 1903101}
-- LogNula: LuaLog: ├─ lottery
-- LogNula: LuaLog: │  ├─ award
-- LogNula: LuaLog: │  │  ├─ 1: 0
-- LogNula: LuaLog: │  │  ├─ 2: 0
-- LogNula: LuaLog: │  │  ├─ 3: 0
-- LogNula: LuaLog: │  │  ├─ 4: 0
-- LogNula: LuaLog: │  │  ├─ 5: 0
-- LogNula: LuaLog: │  │  ├─ 6: 0
-- LogNula: LuaLog: │  │  └─ 7: 0
-- LogNula: LuaLog: │  ├─ times: 0
-- LogNula: LuaLog: │  └─ lucky: 0
-- LogNula: LuaLog: └─ end_time: 1680307200


--万圣节载具活动是否开启
function LogicHalloweenVehicle.GetActivityTime()
    local activityType;
	local strRegion = Client.GetPublishRegion();
	if strRegion == "JAPAN" or strRegion == "KOREA" then
		activityType = ActivityType["HALLOWEEN_VEHICLE_KR"];--
	else
		activityType = ActivityType["HALLOWEEN_VEHICLE"];--
	end

    if LobbySystem.activityDisplayDataList == nil then
        return 0, 0
    end

    for _, activity in ipairs(LobbySystem.activityDisplayDataList) do
        if activity.ActivityType == activityType then
        	--log("LogicHalloweenVehicle.GetActivityTime:" .. activity.StartTime .. "," .. activity.EndTime)
            return activity.StartTimeUTC, activity.EndTimeUTC
            --return FuncUtil:StringTimeToUnixTime(activity.StartTime), FuncUtil:StringTimeToUnixTime(activity.EndTime)
        end
    end
    return 0, 0
end

function LogicHalloweenVehicle.notify_hy_lottery_award(awards)
	log_tree("LogicHalloweenVehicle.notify_hy_lottery_award ", awards)
	
	for i, awardStatus in ipairs(LogicHalloweenVehicle.Trick_Count_Awards) do
		awardStatus.status = awards[i]
	end

	HalloweenVehicleTrickUI.RefreshNumAward(LogicHalloweenVehicle.Trick_Count_Awards)
end

function LogicHalloweenVehicle.on_hy_lottery(rs, lottery, item_list)
	log("LogicHalloweenVehicle.on_hy_lottery,lottery " .. rs)

	log_tree("LogicHalloweenVehicle.on_hy_lottery,lottery:",lottery)
	log_tree("LogicHalloweenVehicle.on_hy_lottery,item_list:",item_list)

	if rs ~= "ok" then

		if rs == "not-enough" then
			--ShowNotice(502006)

			-- 打开充值界面
			local title = Client.GetTableData("LocalizeRes", "101001").TextValue;
			local tip = Client.GetTableData("LocalizeRes", "4119").TextValue;
			CommonMessageBoxUI:ShowPanel(2, title, tip, function()
					RechargeUI:Init();

					HalloweenVehicleTrickUI.HideUI()
				return true;
			end);
		elseif  rs == "not-open" then
			ShowNotice(4002)
		else
			ShowNotice(6148)
		end

		log("LogicHalloweenVehicle.on_hy_lottery not ok")
		return
	end

	LogicHalloweenVehicle.Trick_Result = item_list

-- 	LogNula: LuaLog:item_list
					-- └─ 1
-- LogNula: LuaLog:    ├─ lucky_level: 1
-- LogNula: LuaLog:    ├─ item_id: 1400427
-- LogNula: LuaLog:    ├─ item_expire_time: 0
-- LogNula: LuaLog:    ├─ weight: 10
-- LogNula: LuaLog:    └─ item_num: 1

	LogicHalloweenVehicle.lottery = lottery

	LogicHalloweenVehicle.Lucky_Value = lottery.lucky

	--HalloweenVehicleTrickUI.UpdateLucky(lottery.lucky)

	for i, awardStatus in ipairs(LogicHalloweenVehicle.Trick_Count_Awards) do
		awardStatus.trickCount = lottery.times
		awardStatus.status = lottery.award[i]
	end

	BP_Halloween_Vehicle_Trick_Count = lottery.times

	HalloweenVehicleTrickUI.RefreshNumAward(LogicHalloweenVehicle.Trick_Count_Awards)

	HalloweenVehicleTrickUI.OnTrickAwardResult(item_list)
end

function LogicHalloweenVehicle.Refresh_hy_data(hy_data)
	for i,itemId in pairs(hy_data.vst_id) do
		local VehicleSkin = LogicHalloweenVehicle.VehicleSkinId[itemId]
		local targetSkin_Info = VehicleSkin.lineId == 1 and LogicHalloweenVehicle.Vehicle_Skin_Info1 or LogicHalloweenVehicle.Vehicle_Skin_Info2
		for i,v in ipairs(targetSkin_Info) do
			if v.index <= VehicleSkin.index then
				v.status = 1
			elseif v.index == VehicleSkin.index + 1 then
				v.status = 2
			else
				v.status = 0
			end
		end
	end
	--如果第一个皮肤的状态是0，那么设置第一个皮肤状态为2
	local firstSkin1 = LogicHalloweenVehicle.Vehicle_Skin_Info1[1]
	if firstSkin1 and firstSkin1.status == 0 then
		firstSkin1.status = 2
	end

	local firstSkin2 = LogicHalloweenVehicle.Vehicle_Skin_Info2[1]
	if firstSkin2 and firstSkin2.status == 0 then
		firstSkin2.status = 2
	end

end

function LogicHalloweenVehicle.on_vst_level_up(rs, hy_data)
	log_tree("LogicHalloweenVehicle.on_hy_lottery,on_vst_level_up:",hy_data)

	if rs == "ok" then
		LogicHalloweenVehicle.Refresh_hy_data(hy_data)

		HalloweenVehicleSkinUI.SetSkin_Info(LogicHalloweenVehicle.Vehicle_Skin_Info1, LogicHalloweenVehicle.Vehicle_Skin_Info2)
		
	--显示获奖结果
		local Result = {}
		for i,itemId in pairs(hy_data.vst_id) do
			if FuncUtil.Find(LogicHalloweenVehicle.hy_data.vst_id, itemId) == -1 then
				table.insert(Result, {res_id = itemId, count = 1, valid_hours = 0})
			end 
		end
		CommonItemGetUI:ShowPanel(Result);

		LogicHalloweenVehicle.hy_data = hy_data
	else
		if  rs == "not-open" then
			ShowNotice(4002)
		else
			ShowNotice(6148)
		end

		log("LogicHalloweenVehicle.on_hy_lottery not ok")
		return	
	end
end

function LogicHalloweenVehicle.on_query_lottery_info(rs, lottery_tb)
	log("LogicHalloweenVehicle.on_query_lottery_info")
	log_tree("LogicHalloweenVehicle.on_hy_lottery,on_query_lottery_info:",lottery_tb)

	if rs ~= "ok" then
		return
	end
	LogicHalloweenVehicle.Trick_Items = {}

	for i,v in ipairs(lottery_tb) do
		table.insert(LogicHalloweenVehicle.Trick_Items, {itemId = v.item_id, itemCount = v.item_num, index = i})
	end

	HalloweenVehicleTrickUI.SetTrick_Items(LogicHalloweenVehicle.Trick_Items) 
end

function LogicHalloweenVehicle.on_take_lottery_award(rs, award)
	local GetAwardTb = nil

	for i, awardStatus in ipairs(LogicHalloweenVehicle.Trick_Count_Awards) do
		if awardStatus.status == 1 and award[i] == 2 then
			GetAwardTb = awardStatus.BP_ARRAY_Halloween_Vehicle_Items
		end
		awardStatus.status = award[i]
	end

	HalloweenVehicleTrickUI.RefreshNumAward(LogicHalloweenVehicle.Trick_Count_Awards)


--显示获奖结果
	if GetAwardTb ~= nil then
		local Result = {}
		for i,v in ipairs(GetAwardTb) do
			table.insert(Result, {res_id = v.itemId, count = v.itemCount, valid_hours = v.itemExpireTime})
		end
		CommonItemGetUI:ShowPanel(Result);
	end

	HalloweenVehicleTrickUI.CheckShowExchangeTips();
end

--返回左侧奖励信息
function LogicHalloweenVehicle.on_query_lottery_award_info(rs, lottery, ha_lottery_extra_reward)
	log("LogicHalloweenVehicle.on_query_lottery_award_info:".. rs);
	log_tree("LogicHalloweenVehicle.on_query_lottery_award_info,lottery:", lottery);
	log_tree("LogicHalloweenVehicle.ha_lottery_extra_reward,lottery:", ha_lottery_extra_reward);

	--log("LogicHalloweenVehicle.on_query_lottery_award_info times:".. lottery.times or -1);

	if rs == "ok" then
		LogicHalloweenVehicle.Lucky_Value = lottery.lucky
		LogicHalloweenVehicle.lottery = lottery

		BP_Halloween_Vehicle_Trick_Count = lottery.times

		HalloweenVehicleTrickUI.UpdateLucky(lottery.lucky)

		LogicHalloweenVehicle.Trick_Count_Awards = {}
		for i, reward in ipairs(ha_lottery_extra_reward) do
			local awardStatus = {}
			local _award = {}

			for i,v in ipairs(reward.drop) do
			 	table.insert(_award, {itemId = v.item_id, itemCount = v.item_num, index = i, itemExpireTime = v.item_expire_time})
			end 

		  	awardStatus.BP_ARRAY_Halloween_Vehicle_Items = _award
		  	awardStatus.awardId = i
		  	awardStatus.trickCount = lottery.times
			awardStatus.status = lottery.award[i] --0 标识未完成  1 是已完成未领奖  2是已领奖

			--log("awardStatus.status:" .. lottery.award[i])
			awardStatus.lottery_num = reward.lottery_num
			table.insert(LogicHalloweenVehicle.Trick_Count_Awards, awardStatus)
		end  
		HalloweenVehicleTrickUI.RefreshNumAward(LogicHalloweenVehicle.Trick_Count_Awards)
	end
end

--
function LogicHalloweenVehicle.hy_lottery_req(times)
	log("LogicHalloweenVehicle.hy_lottery_req")
    NetUtil.SendPriorityPkg(false, "hy_lottery_rsp", "hy_lottery", times);
end

--
function LogicHalloweenVehicle.vst_level_up_req(line)
    log("LogicHalloweenVehicle.vst_level_up")
    NetUtil.SendPriorityPkg(false, "vst_level_up_rsp", "vst_level_up", line);
end

--查询有哪些奖励
function LogicHalloweenVehicle.query_lottery_info_req()
    log("LogicHalloweenVehicle.query_lottery_info_req")
    NetUtil.SendPriorityPkg(false, "query_lottery_info_rsp", "query_lottery_info");
end

--领取左侧次数奖励
function LogicHalloweenVehicle.take_lottery_award(award_id)
    log("LogicHalloweenVehicle.take_lottery_award:" .. award_id);
  	NetUtil.SendPriorityPkg(false, "take_lottery_award_rsp", "take_lottery_award", award_id);
end

--查询左侧次数奖励
function LogicHalloweenVehicle.query_lottery_award_info()
    log("LogicHalloweenVehicle.query_lottery_award_info");
  	NetUtil.SendPriorityPkg(false, "query_lottery_award_info_rsp", "query_lottery_award_info");
end

--获取载具升级信息
function LogicHalloweenVehicle.get_vst_level_up_info()
    log("LogicHalloweenVehicle.get_vst_level_up_info");
  	NetUtil.SendPriorityPkg(false, "get_vst_level_up_info_rsp", "get_vst_level_up_info");
end

function LogicHalloweenVehicle.GetCandyCount()
	local itemData = DataMgr.GetHallDepotItemDataByResID(LogicHalloweenVehicle.CandyId);
	if (itemData ~= nil) then
		return itemData.count;
	end
	return 0
end

function LogicHalloweenVehicle.GetTicketCount()
	local itemData = DataMgr.GetHallDepotItemDataByResID(LogicHalloweenVehicle.TicketId);
	if (itemData ~= nil) then
		return itemData.count;
	end
	return 0
end


function LogicHalloweenVehicle.IsShowRedPoint()
	return not LobbyUI.HasClickHalloweenVehicle() or LogicHalloweenVehicle.GetTicketCount() >= LogicHalloweenVehicle.TrickTicket[1]
end

function LogicHalloweenVehicle.UpdateShowRedPoint()
	LobbyUI:LobbyRedPointUpdate(BP_ENUM_MODULE_ACTIVITY_HALLOWEEN_VEHICLE, LogicHalloweenVehicle.IsShowRedPoint());
end




--[[网络回调]]--
s2c["get_vst_level_up_info_rsp"] = LogicHalloweenVehicle.on_get_vst_level_up_info; --载具升级 会包  第一个table 是表格信息，第二个是个人相关数据
s2c["hy_lottery_rsp"]= LogicHalloweenVehicle.on_hy_lottery; --抽奖回包
s2c["vst_level_up_rsp"] = LogicHalloweenVehicle.on_vst_level_up; --载具升级结果返回
s2c["query_lottery_info_rsp"] = LogicHalloweenVehicle.on_query_lottery_info; --查询抽象结果
s2c["query_lottery_award_info_rsp"] = LogicHalloweenVehicle.on_query_lottery_award_info; --查询次数奖励
s2c["take_lottery_award_rsp"] = LogicHalloweenVehicle.on_take_lottery_award; --查询次数奖励
s2c["notify_hy_lottery_award"] = LogicHalloweenVehicle.notify_hy_lottery_award; --查询次数奖励

--c2s.hy_lottery( ss, times) 抽奖
--c2s.vst_level_up( ss, level_list_id) 载具升级
--c2s.get_vst_level_up_info( ss ) 载具升级信息
--c2s.query_lottery_info_req( ss ) 载具抽奖物品
--[[
LogNula: LuaLog: LogicHalloweenVehicle.on_query_lottery_award_info:ok
LogNula: LuaLog: LogicHalloweenVehicle.on_query_lottery_award_info,award:
LogNula: LuaLog: ├─ 1: 0
LogNula: LuaLog: ├─ 2: 0
LogNula: LuaLog: ├─ 3: 0
LogNula: LuaLog: ├─ 4: 0
LogNula: LuaLog: ├─ 5: 0
LogNula: LuaLog: ├─ 6: 0
LogNula: LuaLog: └─ 7: 0
LogNula: LuaLog: LogicHalloweenVehicle.ha_lottery_extra_reward,award:
LogNula: LuaLog: ├─ 1
LogNula: LuaLog: │  ├─ item_num_4: 0
LogNula: LuaLog: │  ├─ item_id_2: 1108004018
LogNula: LuaLog: │  ├─ item_expire_time_3: 0
LogNula: LuaLog: │  ├─ item_num_5: 0
LogNula: LuaLog: │  ├─ item_expire_time_2: 0
LogNula: LuaLog: │  ├─ item_num_3: 0
LogNula: LuaLog: │  ├─ item_expire_time_4: 0
LogNula: LuaLog: │  ├─ item_id_5: 0
LogNula: LuaLog: │  ├─ item_num_1: 100
LogNula: LuaLog: │  ├─ item_num_2: 1
LogNula: LuaLog: │  ├─ drop
LogNula: LuaLog: │  │  ├─ 1
LogNula: LuaLog: │  │  │  ├─ item_expire_time: 0
LogNula: LuaLog: │  │  │  ├─ item_num: 100
LogNula: LuaLog: │  │  │  └─ item_id: 1000
LogNula: LuaLog: │  │  └─ 2
LogNula: LuaLog: │  │     ├─ item_expire_time: 0
LogNula: LuaLog: │  │     ├─ item_num: 1
LogNula: LuaLog: │  │     └─ item_id: 1108004018
LogNula: LuaLog: │  ├─ item_expire_time_1: 0
LogNula: LuaLog: │  ├─ item_id_4: 0
LogNula: LuaLog: │  ├─ item_expire_time_5: 0
LogNula: LuaLog: │  ├─ item_id_3: 0
LogNula: LuaLog: │  ├─ lottery_num: 10
LogNula: LuaLog: │  └─ item_id_1: 1000
LogNula: LuaLog: ├─ 2  ...
LogNula: LuaLog: ├─ 3  ...
LogNula: LuaLog: ├─ 4  ...
LogNula: LuaLog: ├─ 5  ...
LogNula: LuaLog: ├─ 6  ...
LogNula: LuaLog: └─ 7  ...
]]