ActivitySystem = ActivitySystem or {
	questionID = 0, -- 新手问卷活动ID
	questionDone = false, -- 新手问卷活动是否已读
	activityDataTable = {},
	firstChargeInfo = nil,		--首充数据
    firstChargeInfoFromLogin = false,    --是否是登录拉取
}


local ActivityStatus = {
	["UNDONE"] = 0,
	["DONE"] = 1,
	["AWARDED"] = 2
}
function ActivitySystem.Req_AcitvityOneData(activityId)
	NetUtil.SendPkg("get_activity_one_req", activityId)
end

function ActivitySystem.Req_TakeActivityAward(activityId, awardIndex)
	NetUtil.SendPkg("take_activity_award_req", activityId, awardIndex)
end

-- 批量兑换奖励
function ActivitySystem.Req_TakeActivityAwardBatch(activityId, awardIndex, get_times)
	NetUtil.SendPkg("take_activity_award_req", activityId, awardIndex, get_times)
end

function ActivitySystem.Req_DealActivity(activityId, awardIndex, select)
	NetUtil.SendPkg("deal_activity_req", activityId, awardIndex, select)
end

function ActivitySystem.Req_TakeSpecialActivityAward(activityId, select)
	NetUtil.SendPkg("take_special_activity_award_req", activityId, select)
end

function ActivitySystem.Req_Activity_Market_Info(activityId)
	NetUtil.SendPkg("activity_market_info_req", activityId)  
end


function ActivitySystem.HasNoticeRedDot()
	return true
end

function ActivitySystem.HasActivityRedDot(typeList)
	local map = DataMgr.activity.activityListMap
	if map == nil then
		log("[ Error when HasActivityRedDot : activity data need init]")
		return false
	end
	for _, subActivity in pairs(map) do
		if typeList ~= nil then
			if typeList[subActivity.Type] ~= nil
			and subActivity.Status == ActivityStatus["DONE"] then
				return true
			end
		else
			if subActivity.Status == ActivityStatus["DONE"] then
				return true
			end
		end
	end
	return false
end

function ActivitySystem.HasNoticeRedDotByID(noticeId)
	return false --true
end

function ActivitySystem.HasActBtnRedPoint()
	log("HasActBtnRedPoint "..#DataMgr.activity.data);
	for _, activity in pairs(DataMgr.activity.data) do
		if activity and activity.Type == ActivityType["QUESTION"] and ActivitySystem.questionDone == false then
			log("问卷活动有小红点")
			return true
		end

		-- 排除吃鸡盛典和新兵八天活动 只显示通用活动
		if activity and activity.Type ~= nil and 
			ActivityTypeInActivtyPage[activity.Type] == true
			then
			local IsRedPoint = ActivitySystem.HasActivityRedDotByID(activity.ID)
			if IsRedPoint then
				return true
			end
		end
	end
	return false
end

function ActivitySystem.HasActivityRedDotByID(activityId)

	if activityId == nil then
		log("[ Error when HasActivityRedDotByID : activityId is null]")
		return false
	end

	local map = DataMgr.activity.activityMap
	if map == nil then
		log("[ Error when HasActivityRedDotByID : activity data need init]")
		return false
	end
	local activity = map[activityId]
	if activity == nil then
		log("[ Error when HasActivityRedDotByID : activity not found id :]" .. activityId)
		return false
	end

	--log_tree("HasActivityRedDotByID", activity);
	
	-- 新手调查问卷
	if activity.Type == ActivityType["QUESTION"] then
		log("HasActivityRedDotByID question done=" .. tostring(ActivitySystem.questionDone))
		return (ActivitySystem.questionDone == false)
	end

	for _,subActivity in ipairs(activity.List) do
		--区分下是否是兑换活动，兑换活动只有勾选了兑换提醒才计算红点信息
		if subActivity.Type == ActivityType["ITEM_EXCHANGE"] then 
			if subActivity.IsCheckNotice == 1 and subActivity.Status == ActivityStatus["DONE"] then
				--log("兑换活动"..activityId.."有小红点")
				return true
			end
		else
			if subActivity.Status == ActivityStatus["DONE"] then
				--log("活动"..activityId.."有小红点")
				return true
			end
		end
	end
	--log("活动"..activityId.."没有小红点")
	return false
end

function ActivitySystem.GetActivityInfoByType(actType)
	local map = DataMgr.activity.activityMap or {};
	for actId, info in pairs(map) do
		if info.Type == actType then
			return info;
		end
	end
	return nil;
end

--得到父活动关联的彩蛋活动
function ActivitySystem.GetSurpriseActivityInfoByBindID(inputID)
	local map = ActivitySystem.activityDataTable
	local res = {}
	for actId, info in pairs(map) do
		if info.cfg and info.cfg.type == ActivityType["LUCKYUNBACK_SURPRISE"] then
			res[actId] = info.cfg
		end
	end
	log_tree("ActivitySystem.GetSurpriseActivityInfoByBindID", res)
	for k, v in pairs(res) do
		local tmpcond = StrSplit(v.award[1].cond, ",")
		local parentID = tonumber(tmpcond[1])
		if parentID == inputID then
			return k
		end
	end
	return -1
end

-- 根据类型获取活动List
function ActivitySystem.GetActivityInfoListByType(actType)
	local list = {};
	local map = DataMgr.activity.activityMap or {};
	for k, info in pairs(map) do
		if info.Type == actType then
			table.insert(list,info);
		end
	end
	return list;
end

-- 根据id获取活动
function ActivitySystem.GetActivityByID(actId)
	local map = DataMgr.activity.activityMap or {};
	return map[actId];
end

function ActivitySystem.GetActivityData(actId)
	return DataMgr.activity.Data[actId];
end

------------------------------------------------
-- 服务器返回-
------------------------------------------------

function ActivitySystem.Res_TakeActivityAward(errorCode, activityId, awardIndex, factor)
	log("ActivitySystem.Res_TakeActivityAward "..tostring(errorCode)..","..tostring(activityId)..","..tostring(awardIndex)..","..tostring(factor))
	if errorCode == NetErrorCode_NONE then
		local key = string.format("%d_%d", activityId, awardIndex)
		if activityId == ActivtyShaoJiUI.activityId then
			ActivtyShaoJiUI.ProcExchangeRewardRes(awardIndex)
		elseif activityId == BP_LuckyUnback_AcivityInfo.SurpriseId then
			return
		else
			local subActivity = DataMgr.activity.activityListMap[key]
			local get_times = factor or 1
			if get_times < 1 then get_times = 1 end
			if subActivity ~= nil then
				local arrayItemData = {}
				for index, dropData in ipairs(subActivity.Drop) do
					table.insert(arrayItemData, {res_id = dropData.itemId, count = dropData.count * get_times, valid_hours = dropData.expireTime})
				end
				CommonItemGetUI:ShowPanel(arrayItemData)
				EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_ACTIVITY_EXCHANGE)
			end
		end
	else
		ShowNotice(errorCode)
	end
end

function ActivitySystem.Res_TakeSpecialActivityAward(errorCode, activityId, awardId, factor)
	log("ActivitySystem.Res_TakeSpecialActivityAward "..tostring(errorCode)..","..tostring(activityId)..","..tostring(awardId)..","..tostring(factor))
	if errorCode == NetErrorCode_NONE then
		local key = string.format("%d_%d", activityId, 1) -- 特殊兑换只有1个子活动
		local subActivity = DataMgr.activity.activityListMap[key]
		local get_times = factor or 1
		if get_times < 1 then get_times = 1 end
		if subActivity ~= nil then
			local arrayItemData = {}

			-- 找到之前选择兑换的某一个奖励
			for index, dropData in ipairs(subActivity.Drop) do
				if dropData.itemId == awardId then
					table.insert(arrayItemData, {res_id = dropData.itemId, count = dropData.count * get_times, valid_hours = dropData.expireTime})
					break
				end
			end

			if #arrayItemData == 1 then
				CommonItemGetUI:ShowPanel(arrayItemData)
			end
		end
	else
		ShowNotice(errorCode)
	end
end

function ActivitySystem.RemoveActivity(activityId)
	log("remove act ".. activityId)
	DataMgr.activity.hashList[activityId] = nil
	DataMgr.activity.activityMap[activityId] = nil
	local removed = false;
	for key, activity in pairs(DataMgr.activity.activityListMap) do
		if activity.ID == activityId then
			DataMgr.activity.activityListMap[key] = nil
			-- 删除图片集子活动
			if activity.Type == ActivityType["IMAGES_GROUP_SUB"] then
				local fatherActivity = DataMgr.activity.activityMap[DataMgr.activity.activityIdMap[activityId]];
				if fatherActivity ~= nil then
					for k, v in pairs(fatherActivity.List) do
						if v.ID == activityId then
							table.remove(fatherActivity.List, k);
							removed = true;
							log("[HHF]ActivitySystem.RemoveActivity, remove sub activity id = " .. tostring(activityId));
							break;
						end
					end
				end
			end
		end
	end

	if removed then
		ActivtyUI.RefreshUI();
	end

	local del = {}
	for key, activity in pairs(DataMgr.activity.data) do
		if activity.ID == activityId then
			del[key] = true
		end
	end

	for key,_ in pairs(del) do
		table.remove(DataMgr.activity.data, key)
		if BP_STRUCT_ActivtyInfo.ID == activityId then
			ActivtyUI.ClearCurrentActivityData();
			log("[HHF]ActivitySystem.RemoveActivity, activityID = " .. activityId);
		end
	end
end

function ActivitySystem.activity_market_info_rsp(data)
	if data.activity_id then
		for _, activity in ipairs(DataMgr.activity.data) do
	        if activity and activity.ID == data.activity_id  then
	        	if activity.Type == ActivityType["INVITE_TEAM"] then
	            	ActivityInviteTeamUI.activity_market_info_rsp(data)
	        	end
	        	break
	        end
    	end
	end
end

function ActivitySystem.IsActivityOpen(activity)
	if not activity then
		return false;
	end

	local currentTime = FuncUtil.GetServerTimeInSec();
	if currentTime < activity.StartTime then
		return false;
	end

	if currentTime > activity.EndTime then
		return false;
	end

	if activity.DailyStartTime ~= 0 or activity.DailyEndTime ~= 0 then
		local dst = activity.DailyStartTime % 86400
		local det = activity.DailyEndTime % 86400
		local dct = currentTime % 86400
		return dst <= dct and dct <= det;
	end

	return true;
end

function ActivitySystem.GetActivityRemainTime(activity)
	local currentTime = FuncUtil.GetServerTimeInSec();
	if activity.DailyStartTime ~= 0 or activity.DailyEndTime ~= 0 then
		local det = activity.DailyEndTime % 86400
		local timeInDay = currentTime % 86400
		return math.max(0, timeInDay - det)
	end

	return math.max(0, activity.EndTime - currentTime);
end

local function InitOther(node, data)--InitParentNode中的data是activity.cfg,此函数的data是activity.data
	node.other = data.other;
end

local function InitParentNode(node, id, data)
	--log("InitParentNode, id = " .. id .. ", type = " .. data.type .. ", name = " .. data.activity_name .. ", start = " .. data.start_time .. ", end = " .. data.end_time .. ", order = " .. tostring(data.show_order).."image_link = "..data.activity_image_link);
	DataMgr.activity.activityIdMap[id] = id
	node.ID = id
	node.Desc = data.activity_desc
	node.Detail = data.activity_detail
	node.Title = data.activity_name
	node.ImgUrl = data.activity_image_link
	node.ImgLink = data.page_link
	node.DailyStartTime = data.daily_start_time
	node.DailyEndTime = data.daily_end_time
	node.StartTime = data.start_time
	node.EndTime = data.end_time
	node.DailyStartTimeStr = os.date("%H:%M:%S", data.daily_start_time);--FormatTime(data.daily_start_time)
	node.DailyEndTimeStr = os.date("%H:%M:%S", data.daily_end_time);--FormatTime(data.daily_end_time)
	node.StartTimeStr = os.date("%Y-%m-%d %H:%M:%S", data.start_time);--FormatTime(data.start_time)
	node.EndTimeStr = os.date("%Y-%m-%d %H:%M:%S", data.end_time);--FormatTime(data.end_time)
	node.JoinLevelLimitUp = data.join_level_up_limit
	node.JoinLevelLimitLow = data.join_level_down_limit
	node.JoinVipLimitUp = data.join_vip_up_limit
	node.JoinVipLimitLow = data.join_vip_down_limit
	node.LabelDesc = ""
	node.LabelType = data.left_label
	if data.left_label == 1 then
		node.LabelDesc = "火爆"
	end
	if data.left_label == 2 then
		node.LabelDesc = "限时"
	end
	if data.left_label == 3 then
		node.LabelDesc = "预告"
	end
	if data.left_label == 4 then
		node.LabelDesc = "推荐"
	end
	if data.left_label == 5 then
		node.LabelDesc = "最新"
	end
	node.Order = data.show_order
	node.JumpActivity = data.jump_activity_id or 0
	node.Type = data.type
	node.List = node.List or {}
	if data.award and #data.award > 0 then
		node.Condition = data.award[1].cond;
	end

	DataMgr.activity.activityMap[id] = node
	-- 累积分享活动的时间段
	if (data.type == ActivityType["SHARE_AWARD"]) then
		local startTime = FuncUtil.SecToDateString(data.start_time);
		local endTime = FuncUtil.SecToDateString(data.end_time);
		local textData = Client.GetTableData("LocalizeRes", 430101);
		BP_String_ShareAward_ActiveTime = string.format(textData.TextValue, startTime, endTime);
	end

	-- 新手问卷永远排第一
	if (data.type == ActivityType["QUESTION"]) then
		ActivitySystem.questionID = id
		node.Order = -100
		log("question data order " .. node.Order)
	end

	
end

local function InitCond(activityType, cond, subActivity, extraCond)
	--zinotag cond活动条件配置
	if activityType == ActivityType["ITEM_EXCHANGE"] then
		local args = string.split(cond, ",")
		--是全服兑换活动
		if(args[8]~=nil and tonumber(args[8])>0) then
			--log("zino cond8 is exist: ".. args[8])
			subActivity.GlobalTotalNum = tonumber(args[8]);
			subActivity.Total = tonumber(args[8])	
			subActivity.GlobalPersonMaxGetNum = tonumber(args[5])
		else
		subActivity.Total = tonumber(args[5])
		end
		for i = 1,4,2 do
			table.insert(subActivity.CostList, {itemId = tonumber(args[i]), count = tonumber(args[i+1])})
		end

		-- 多于2个的消耗品
		if extraCond ~= nil and extraCond ~= "" then
			args = string.split(extraCond, ",")	
			for i = 1, #args, 2 do
				table.insert(subActivity.CostList, {itemId = tonumber(args[i]), count = tonumber(args[i+1])})
			end
		end
		
		log("Duihuan cost length"..#subActivity.CostList);
	elseif activityType == ActivityType["SUPPLY_BUY_ONE"]
		or activityType == ActivityType["SUPPLY_BUY_TEN"]
		then
		subActivity.Condition = cond;
	elseif activityType == ActivityType["BATTLEROUND"]
		or activityType == ActivityType["DECISIVE_BATTLEROUND"]
		or activityType == ActivityType["ACTIVITY_TYPE_BUY_CHEST"]
		or activityType == ActivityType["DECISIVE_BATTLEFIRST"]
		or activityType == ActivityType["BATTLEFIRST"]
		or activityType == ActivityType["SHARE"]
		or activityType == ActivityType["ACTIVITY_TYPE_BATTLE_COLLECT"]
		or activityType == ActivityType["BIOCHEMICAL_Battle"]
		or activityType == ActivityType["BIOCHEMICAL_KILL_ZOMBIE"]
		then
		local args = string.split(cond, ",")
		subActivity.Total = tonumber(args[2])
	elseif activityType == ActivityType["GROUP_EXCITE"]
		or activityType == ActivityType["PROMOTOR"]
		or activityType == ActivityType["ONLINE_TIME"]
		or activityType == ActivityType["KILL_CNT"]
		or activityType == ActivityType["SURVIVAL_TIME"]
		or activityType == ActivityType["INVITEFBFRIENDS"]
		or activityType == ActivityType["CONSUME_GOLD"]
		or activityType == ActivityType["NEW_KILL_CNT"]
		or activityType == ActivityType["NEW_SURVIVAL_TIME"] 
		or activityType == ActivityType["BATTLE_CORPS"] 
		or activityType == ActivityType["VALUE_CORPS"] 
		or activityType == ActivityType["ACTIVITY_TYPE_CONSUME_UC"] 
		or activityType == ActivityType["CONSUME_RP"]
		or activityType == ActivityType["CONSUME_UC"]
		or activityType ==  ActivityType["BUY_UPASS_ACTIVITY"]
        or activityType == ActivityType["LEVEL_UP_REWARD"] 
		or activityType == ActivityType["H5_REWARD"]
		then
		local args = string.split(cond, ",")
		subActivity.Total = tonumber(args[1])
	elseif activityType == ActivityType["OBTAIN_SEGMENT"] then
		subActivity.Total = 0
	elseif activityType == ActivityType["THROWCANDY"] --扔糖果
		or activityType == ActivityType["GET_ITEM_DO"]	--固定商品获得并完成行为
		or activityType == ActivityType["PVE_ALIVE"] --PVE存活时间
		then
		local args = string.split(cond, ",")
		subActivity.Total = tonumber(args[3])
	elseif activityType == ActivityType["ACTIVITY_TYPE_LINK"] then
		local args = string.split(cond, ",")
		subActivity.Total = tonumber(args[1])
	elseif activityType == ActivityType["QUESTIONNAIRE"] then
		local args = string.split(cond, ",")
		subActivity.Total = tonumber(args[1])
		if(subActivity.Total == 0) then
			subActivity.Total = 1;
		end
	elseif activityType == ActivityType["PVE_EVALUATION"]  then
		local args = string.split(cond, ",")
		subActivity.Total = tonumber(args[4])
	else
		if cond == nil then
			subActivity.Total = 0
		else
			subActivity.Total = tonumber(cond)
		end
	end
	subActivity.Total = subActivity.Total or 0
end

local function InitSubActivityNode(parentNode, id, data)
	--zinotag 子活动数据处理
	for index,award in ipairs(data.award) do
		local key = string.format("%d_%d", id, index)
		local subActivity = DataMgr.activity.activityListMap[key]
		if subActivity == nil then
			subActivity = {}
			table.insert(parentNode.List, subActivity)
			DataMgr.activity.activityListMap[key] = subActivity
		end
		subActivity.ID = id
		subActivity.Index = index
		subActivity.Title = award.task_title 
		subActivity.Arg1 = award.extern_arg_1  
		subActivity.Arg2 = award.extern_arg_2 
		subActivity.Key = key
		subActivity.Drop = {}
		subActivity.CostList = {}
		subActivity.Type = data.type
		subActivity.Order = data.show_order * 10000 + (100 - index)
		subActivity.ImgLink = data.page_link;
		subActivity.StartTime = data.start_time;
		subActivity.ShowImgLink = data.activity_image_link;

		InitCond(subActivity.Type, award.cond, subActivity, award.extra_cond)

		DataMgr.activity.activityIdMap[id] = parentNode.ID

		subActivity.IsCheckNotice = 0		
		for _,dropItem in ipairs(award.drop) do
			table.insert(subActivity.Drop, {
				itemId = dropItem.item_id,
				count = dropItem.item_num,
				expireTime = dropItem.item_expire_time,
				reviseId = dropItem.item_revise_id,
			})
		end
		subActivity.Progress = 0
		subActivity.Status = 0
		--log("Init activity subActivity : " ..  key)

		-- 处理特殊兑换类型
		if subActivity.Type == ActivityType["ITEM_EXCHANGE"] then
			subActivity.Progress = 0
			if award.extern_arg_1 == 1 then
				parentNode.SelectExchange = true
			else
				parentNode.SelectExchange = false
			end
		end

		--log("[HHF]InitSubActivityNode, id = " .. id .. ", index = " .. index .. ", title = " .. award.task_title .. ", fatherID = " .. parentNode.ID);
	end
end

function ActivitySystem.InitActivityList(activityTable)
	-- if BP_Is_Not_Login ~=0 then
	-- 	for activityId, activityData in pairs(activityTable) do
	-- 		if activityId == BP_Is_Not_Login then
	-- 			log("**********."..activityData.cfg.activity_image_link);
	-- 			BP_Img_Link = activityData.cfg.activity_image_link
	-- 			break;
	-- 		end
	-- 	end
	-- 	BP_Is_Not_Login = 0;
	-- else
		log("[HHF]ActivitySystem.InitActivityList, received get_activity_list_res.");
		DataMgr.activity.isInit = true
		ActivitySystem.activityDataTable = activityTable
		ActivitySystem.InitActivityData(activityTable)
		
	
		EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_ACTIVITY_INFO)
	-- end
end

function ActivitySystem.SortActivity()
	--log("[HHF]ActivitySystem.SortActivity");
	
	for _, activity in pairs(DataMgr.activity.data) do
		--log_tree("activity.List  ",activity.List)
		local finish = true;
		for _, subActivity in pairs(activity.List) do
			if subActivity.Status ~= ActivityStatus["AWARDED"] then
				finish = false;
				break;
			end
		end
		if finish == true then
			activity.Order = 2000;
			--log("[HHF]ActivitySystem.InitActivityData, id = " .. activity.ID .. " is finished, and set its order = 2000");
		end
		if nil == activity.Order then
			activity.Order = 0
		end
		if nil == activity.StartTime then
			activity.StartTime = 0
		end
	end

	if DataMgr.activity.data ~= nil and #DataMgr.activity.data > 1 then
		--log_tree("DataMgr.activity.data", DataMgr.activity.data)
		table.sort(DataMgr.activity.data, function(a, b)
			--log("a.Order ." .. a.Order)
			--log("b.Order ." .. b.Order)
			if a.Order == b.Order then
				return a.StartTime > b.StartTime
			else
				return a.Order < b.Order
			end
		end)
	end

	for _,activity in pairs(DataMgr.activity.activityMap) do
		if activity.Type == ActivityType["NEW_PLAYER"] then

		else
			if activity.List ~= nil and #activity.List > 1 then
				table.sort(activity.List, function(a, b)
					if a.Order == b.Order then
						if a.StartTime == b.StartTime then
							return a.ID < b.ID;
						else
							return a.StartTime > b.StartTime
						end
					else
						return a.Order > b.Order
					end
				end)
			end
		end
	end
end

function ActivitySystem.Preprocess(activityTable)
	local parentID = 0;
	for activityId, activityData in pairs(activityTable) do
		if activityData.cfg.type == ActivityType["IMAGES_GROUP"] then
			parentID = activityId;
			break;
		end
	end
	if parentID == 0 then
		for activityId, activityData in pairs(DataMgr.activity.data) do
			if activityData.Type == ActivityType["IMAGES_GROUP"] then
				parentID = activityData.ID;
				break;
			end
		end
	end

	log("[HHF]ActivitySystem.Preprocess, banner parent activity id = " .. parentID);

	if parentID ~= 0 then
		for activityId, activityData in pairs(activityTable) do
			local cfg = activityData.cfg;
			if cfg.type == ActivityType["IMAGES_GROUP_SUB"] then
				cfg.father_activity_id = parentID;
				log("[HHF]ActivitySystem.Preprocess, found one sub banner activity id = " .. cfg.activity_id);
			end
		end
	end
end

-- 是否在活动中心隐藏
function ActivitySystem.IsHideInActivity(cfg)
	if nil == cfg or nil == cfg.award then
		return false
	end
	local bAward = false
	for k,v in pairs(cfg.award) do
		bAward = true
		if v.extern_arg_2 ~= 1 then
			return false
		end
	end
	return bAward
end

--替换活动中心左侧图
function ActivitySystem.ReplaceActivityImageLink(activityTable)
	--log_tree("ActivitySystem.ReplaceActivityImageLink", activityTable)
	local replaceCfg
	for activityId, activityData in pairs(activityTable) do
		if activityData.cfg and activityData.cfg.type == 50 then
			if replaceCfg == nil or replaceCfg.activity_id < activityId then
				log("?????, roxy test"..activityId)
				replaceCfg = activityData.cfg
			end
		end
	end
	log_tree("ActivitySystem.ReplaceActivityImageLink", replaceCfg)
	if replaceCfg ~= nil then
		for activityId, activityData in pairs(activityTable) do
			if activityData.cfg ~= nil and activityData.cfg.type ~= 13 and activityData.cfg.type ~= 29 and activityData.cfg.type ~= 32
					and activityData.cfg.type ~= 47 and activityData.cfg.type ~= 59 and activityData.cfg.type ~= 46 and activityData.cfg.type ~= 61 
					and ActivityTypeInActivtyPage[activityData.cfg.type] == true then
				activityData.cfg.activity_image_link = replaceCfg.activity_image_link
			end
		end
	end
end

function ActivitySystem.InitActivityData(activityTable)
	--log_tree("ActivitySystem.InitActivityData, activityTable = ", activityTable, "[HHFTEST]");
	
	if DataMgr.activity.isInit ~= true then
		log("[HHF]ActivitySystem.InitActivityData, received get_activity_batch_res.");
	end

	ActivitySystem.ReplaceActivityImageLink(activityTable)
	--删除活动中心不显示的
	local actTb = {}
	for activityId, activityData in pairs(activityTable) do
		if not ActivitySystem.IsHideInActivity(activityData.cfg) then
			actTb[activityId] = activityData
		end
	end
	activityTable = actTb
	
	--更新红点
	ActivtyShaoJiUI.UpdateExchangeRedpoint()
	LuckyUnbackUI.IsLobbyOpen()
	
	--log_tree("[HHFTEST]ActivitySystem.InitActivityData, activityTable = ", activityTable, "[HHFTEST]");
	ActivitySystem.Preprocess(activityTable);
	local changeList = {idList = {}, typeList = {}}
	local newActivityMark = false
	local temp = DataMgr.activity.data
	-- 初始化模板表
	for activityId, activityData in pairs(activityTable) do
		local cfg = activityData.cfg
		cfg.father_activity_id = cfg.father_activity_id or 0
		cfg.show_order = cfg.show_order or 1000
		local parentNode = nil
		local parentId = cfg.father_activity_id == 0 and activityId or cfg.father_activity_id
		parentNode = DataMgr.activity.activityMap[parentId]
		if parentNode == nil then
			parentNode = {ID = parentId, List = {}}
			table.insert(temp, parentNode)
			DataMgr.activity.activityMap[parentId] = parentNode
			newActivityMark = true
		end
		-- 是父节点
		--log("zino cfg.father_activity_id" .. cfg.father_activity_id)
		--log("zino activityId" .. activityId)
		if cfg.father_activity_id == 0 then
			InitParentNode(parentNode, activityId, cfg)
			InitOther(parentNode, activityData.data)--other字段
		end
		--log_tree("zinotest.....parentNode",	parentNode)
		-- 处理子节点
		InitSubActivityNode(parentNode, activityId, cfg)

		DataMgr.activity.hashList[activityId] = {HashCode = cfg.chk_str, UpdateTime = 0}

		changeList.idList[(DataMgr.activity.activityIdMap[activityId] or -1)] = true
		changeList.typeList[cfg.type] = true
	end
 
	-- ActivitySystem.ArrangeActivity()

	-- 初始化数据
	for activityId, activityData in pairs(activityTable) do
		local data = activityData.data
		if not ActivitySystem.IsHideInActivity(activityData.cfg) then
			ActivitySystem.UpdateOneActivityData(activityId, data)
		end
	end

	ActivitySystem.SortActivity();
	
	-- log("===============printStart")
	-- log_tree("=================activityData", temp)
	-- log("===============printEnd")
	-- 派发事件给依赖于活动的系统处理
	--log_tree("zinotest.....changeList",	changeList)
	if DataMgr.activity.isInit then
		EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CHANGE, changeList)
		if newActivityMark then
			EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CR)
		end
	end
	--log_tree("zinotest.....temp",	temp)
	-- ExcitingPartyMgr.DealExcitingPartyFromActivity() 
end

-- 整理刚刚初始化玩的数据
function ActivitySystem.ArrangeActivity()
	-- 把兑换的活动移到正常活动中
	for _, activityData in ipairs(DataMgr.activity.data) do
		--log_tree("[Error: ArrangeActivity]", activityData.JumpActivity)
		if activityData.JumpActivity ~= 0 then
			local temp = DataMgr.activity.activityMap[activityData.JumpActivity]
			if temp ~= nil then
				for _,subActivityNode in ipairs(temp.List) do
					table.insert(activityData.List, subActivityNode)
				end
			else
				--log_tree("[Error: activity data error]" .. (activityData.JumpActivity or 0), DataMgr.activity)
			end
		end
	end
end

function ActivitySystem.UpdateActivityData(actId, activityData)
	--log("[HHF]ActivitySystem.UpdateActivityData, received get_activity_one_res");
	log("zino actid" .. actId)
	--log_tree("################[HHF]ActivitySystem.UpdateActivityData, activityData = ", activityData, "[HHF]");
	if not activityData or not activityData[actId] then
		-- 删除活动
		log("zino remove acaccacac")
		ActivitySystem.RemoveActivity(actId);
		EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CR)
		return;
	end
	local changeList = {idList = {}, typeList = {}}
	for id, data in pairs(activityData) do
		ActivitySystem.UpdateOneActivityData(id, data)
		changeList.idList[(DataMgr.activity.activityIdMap[id] or -1)] = true
		changeList.typeList[data.type] = true
	end

	ActivitySystem.SortActivity();

	if DataMgr.activity.isInit then
		EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CHANGE, changeList)
	end
	-- ExcitingPartyMgr.DealExcitingPartyFromActivity() 
end

function ActivitySystem.UpdateOneActivityData(id, data)
	
	--log("zino UpdateOneActivityData id= "..id)
	if DataMgr.activity.hashList[id] ~= nil then
		DataMgr.activity.hashList[id].UpdateTime = data.update_time
	else
		log("[Error : activity not found in hashList id ]" .. id)
	end

	for index, statusData in ipairs(data.award) do
		local key = string.format("%d_%d", id, index)
		local subActivity = DataMgr.activity.activityListMap[key]
		if subActivity == nil then
			log(string.format("[Error : activity can't find on id:%d index:%d ]", id, index))
		else
			--log("zino statusData.status " .. statusData.status)
			subActivity.Status = statusData.status
			if subActivity.Type == ActivityType["ITEM_EXCHANGE"] then
				subActivity.Progress = statusData.exchange_cnt or 0
				subActivity.IsCheckNotice = statusData.has_point or 0
				-- 强行修正一下状态，剩余兑换次数为0
				if subActivity.Progress == subActivity.Total then
					subActivity.Status = ActivityStatus["AWARDED"]
				end
			end
		end
	end

	local actType = tonumber(data.type);
	data.type = actType;
	-- 累计登陆不需要同步进度
	if actType == ActivityType["TOTAL_LOGIN"]
	or actType == ActivityType["SPRING_REDPACKET"]
	or actType == ActivityType["FRIEND_RECALL"]
	or actType == ActivityType["FRIEND_RECALL_REFLUX"] then 
		return
	end
	
	local activity = DataMgr.activity.activityMap[id]

	if activity then
		-- 新兵八天需要额外的open_time字段
		if actType == ActivityType["NEW_PLAYER"] then
			activity.open_time = data.open_time
		elseif actType == ActivityType["FIRST_RECHARGE_ADD"] then
			if data.other then
				if data.other.is_first_recharge then
					activity.other.is_first_recharge = data.other.is_first_recharge
				end
			end
		elseif actType == ActivityType["BUY_UPASS_ACTIVITY"] then
			if data.other then
				if data.other.pass_buy_total_cnt then
					activity.other.pass_buy_total_cnt = data.other.pass_buy_total_cnt
				end

				if data.other.join_activity_pass_buy then 
					activity.other.join_activity_pass_buy = data.other.join_activity_pass_buy
				end
			end
			--log_tree("xzx ActivitySystem.UpdateOneActivityData data: ", activity)
		elseif actType == ActivityType["INVITEFBFRIENDS"] then
			activity.invite_total_count = data.other.invite_total_count or 0;
			log("[HHF]ActivitySystem.UpdateOneActivityData, invite_total_count = " .. activity.invite_total_count);
		elseif actType == ActivityType["WelFARE_REWARD_PKG"] then
			-- 奖赏包直购礼包活动
		elseif actType == ActivityType["INVITE_TEAM"] then
			if data.other and data.other.invitees then
				activity.other.invitees = data.other.invitees
			end
		elseif actType == ActivityType["DISCOUNTFEVER"] then
			if data.other then
				--特惠派对系列活动的刷新
				log("特惠派对购买要刷新了roxy")
				ActivitySystem.activityDataTable[id].data.other = data.other
				EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_ACTIVITY_INFO)
			end
		elseif actType == ActivityType["SUPPLY_BUY_ONE"] or actType == ActivityType["SUPPLY_BUY_TEN"] then
			-- 商店补给折扣活动
			if data.other then
				activity.other.open_count = data.other.open_count
				EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_SUPPLY_DISCOUNT_UPDATE);
			end
		elseif actType == ActivityType["LUCKYUNBACK_SURPRISE"] then
			--不放回抽奖彩蛋的刷新
			log_tree("不放回抽奖彩蛋要刷新了roxy", data)
			ActivitySystem.activityDataTable[id].data = data
			EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_ACTIVITY_INFO)
		elseif actType == ActivityType["STARTER_PACK_US"] then
			log_tree("Get one data from server:  ", data);
			log_tree("Local Activity Data:  ", ActivitySystem.activityDataTable[id].data);

			-- if Starter Pakc not unlocked on Server side  OR if Starter Pack already Unlocked then return, no need to show the unlock dialog box
			--------------------------------------------------------save code---------------------------------------------------------------------
			if data == nil or data.award == nil or data.award[1] == nil or data.award[1].status == nil then
				return
			end
			--------------------------------------------------------save code---------------------------------------------------------------------
			if data ~= nil and data.award ~= nil then
				StarterPackSystem.bForceUpdate = true;
				log("Server Player Starterpack status:  ".. tostring(data.award[1].status) .." local Status: " .. tostring(ActivitySystem.activityDataTable[id].data.award[1].status));
				if data.award[1].status == 1 and ActivitySystem.activityDataTable[id].data.award[1].status == 0 then
					if data.other ~= nil then
						StarterPackSystem.fStarterpack_UnlockTime = data.other.starter_pack_unlock_time;
					end
					StarterPackSystem.bShowStarterPackUnlockUI = true;
				else
					log("Set unlockUI bShowStarterPackUnlockUI to false " )
					log("Server Player Starterpack status:  ".. tostring(data.award[1].status) .." local Status: " ..tostring(ActivitySystem.activityDataTable[id].data.award[1].status));
					--StarterPackSystem.bShowStarterPackUnlockUI = false;
				end

				ActivitySystem.activityDataTable[id].data.award[1].status = data.award[1].status;

				if data.award[1].status ~= 1 then
					if data.award[1].status == 2 then
						StarterPackSystem.Enabled = false;
					end
					StarterPackSystem.EndPurchase();
				end
			end
		elseif actType == ActivityType["ACTIVITY_TYPE_KRJP_PURCHASE"] then
			if data.other then
				activity.other = data.other
			end
		end
	end

	local NoNeedProgressType = {
		[ActivityType["INVITE_TEAM"]] = true,--邀请组队的进度是通过：data.other.invitees来确定的
		[ActivityType["STARTER_PACK_US"]] = true,--新手礼包没有进度，由后台保证是否解锁
	}

	if NoNeedProgressType[data.type]~= nil then
		return
	end

	local SpecialType = {
		[ActivityType["ONLINE_TIME"]] = "online_time",
		[ActivityType["KILL_CNT"]] = "kill_cnt",
		[ActivityType["SURVIVAL_TIME"]] = "survival_time",
		[ActivityType["LEVEL_UP_REWARD"]] = "level",
		[ActivityType["QUESTIONNAIRE"]] = "times",
		[ActivityType["H5_REWARD"]] = "click_count",
	}
	if SpecialType[data.type] ~= nil then
		for _, subActivity in pairs(DataMgr.activity.activityListMap) do
			if subActivity.Type == data.type and subActivity.ID == id then
				--log("data.other[SpecialType[data.type]] ="..data.other[SpecialType[data.type]]..", "..SpecialType[data.type])
				subActivity.Progress = data.other[SpecialType[data.type]] or 0
				if (subActivity.Progress > subActivity.Total) then
					subActivity.Progress = subActivity.Total
				end
			end
		end
		return
	end

	--log_tree("UpdateOneActivityData", data.other)
	for _, progressData in pairs(data.other) do
		if type(progressData) == "table" then
			for index,value in pairs(progressData) do
				local key = id.."_"..index
				local subActivity = DataMgr.activity.activityListMap[key]
				if subActivity then
					subActivity.Progress = value
					if (subActivity.Progress > subActivity.Total) then
						subActivity.Progress = subActivity.Total
					end
				end
			end
		end
	end
	
	--如果other为{}，那么此活动的所有子活动，进度设置为0
	if not next(data.other)  then
		for key, subActivity in pairs(DataMgr.activity.activityListMap) do
			--ITEM_EXCHANGE在上面已经处理了进度
			if subActivity.Type ~= ActivityType["ITEM_EXCHANGE"] and string.find(tostring(key), tostring(id))  then
				subActivity.Progress = 0
			end
		end
	end


end

function ActivitySystem.HandleH5WebViewJson(str)
	local result = json.decode(str);
	log_tree("HandleH5WebView Json Result", result);
	if(tostring(result["type"]) == "questionnaire") then
		ActivitySystem.questionnaire_finished_report_req();
	elseif (tostring(result["title"]) ~= nil) then
		ShareMgr.openShareSeasonResultUI(str);
	end
end

-- 获取加成卡活动
function ActivitySystem.GetBpAndExpActivity()
	local bpActiveData = DataMgr.GetActivityByType(ActivityType["LIMITGOLD"]);
	local expActiveData = DataMgr.GetActivityByType(ActivityType["LIMITEXP"]);

	return bpActiveData, expActiveData;
end

function ActivitySystem.IsContainsH5LeagueGameActivity()
	local strRegion = Client.GetPublishRegion();
	if strRegion == "JAPAN" or strRegion == "KOREA" then
		for _, activity in ipairs(DataMgr.activity.data) do
			if activity and activity.Type ~= nil then
				if(activity.ID == ActivtyUI.KR_H5LeagueGameActivityID) then
					return true;
				end
			end
		end
		return false;
	else
		for _, activity in ipairs(DataMgr.activity.data) do
			if activity and activity.Type ~= nil then
				if(activity.ID == ActivtyUI.H5LeagueGameActivityID) then
					return true;
				end
			end
		end
		return false;
	end
end

--------------------------0.10.0新首冲协议---------------------------
--拉取信息
function ActivitySystem.get_season_recharge_info_req(isFromLogin)
    ActivitySystem.firstChargeInfoFromLogin = isFromLogin;
	--NetUtil.SendPkg("get_season_recharge_info_req")
	NetUtil.SendPriorityPkg(false, "get_season_recharge_info_rsp", "get_season_recharge_info_req");
end

function ActivitySystem.get_season_recharge_info_rsp(res , data)
	--log("get_season_recharge_info_rsp .." .. res);
	--log_tree("get_season_recharge_info_rsp", data);
	if res == "ok" then
		if data then
			ActivitySystem.firstChargeInfo = data;
			if not ActivitySystem.firstChargeInfoFromLogin then
				--设置数据并更新UI
				TheFirstChargeUI.SetData();
				--打开设置小红点隐藏
				LobbyUI.HandleTheFirstChargeRedDot(false);
			else
				--检查是否完成，完成就关闭入口
				TheFirstChargeUI.CheckIsFinished();
				--拉取数据检查小红点
				TheFirstChargeUI.CheckFirstChargeRedDot();
			end
		end
	elseif res == "not-open"then
		log("ActivitySystem.get_season_recharge_info_rsp not-open")
		TheFirstChargeUI.SetOpenCountDown(data);
		LobbyUI.HandleTheFirstChargeHide();
	elseif res == "all-done" then
		log("ActivitySystem.get_season_recharge_info_rsp all-done")
		TheFirstChargeUI.SetAllDone();
		LobbyUI.HandleTheFirstChargeHide();
	else
		log("ActivitySystem.get_season_recharge_info_rsp error")
		LobbyUI.HandleTheFirstChargeHide();
	end
end

--领奖
function ActivitySystem.take_season_recharge_award_req(index)
	NetUtil.SendPkg("take_season_recharge_award_req", index);
end

function ActivitySystem.take_season_recharge_award_rsp(res, data)
	--log("ActivitySystem.take_season_recharge_award_rsp res .." .. res);
	--log_tree("ActivitySystem.take_season_recharge_award_rsp", data);
	if res == "ok" then
		
		local rewardList = {};
		for k, v in pairs(data) do
			table.insert(rewardList, {res_id = v.resid, count = v.count});
		end
		if #rewardList > 0 then
			CommonItemGetUI:ShowPanel(rewardList);
		end
		
		ActivitySystem.get_season_recharge_info_req(false);
	else
		log("ActivitySystem.take_season_recharge_award_rsp error")
	end
end

--购买
function ActivitySystem.season_recharge_buy_req()
	NetUtil.SendPkg("season_recharge_buy_req")
end

function ActivitySystem.season_recharge_buy_rsp(res, data)
	--log("ActivitySystem.season_recharge_buy_rsp res .." .. res);
	--log_tree("ActivitySystem.season_recharge_buy_rsp", data);
	if res == "ok" then
		--PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", 4304).TextValue);
		local rewardList = {};
		for k, v in pairs(data) do
			table.insert(rewardList, {res_id = v.resid, count = v.count});
		end
		if #rewardList > 0 then
			CommonItemGetUI:ShowPanel(rewardList);
		end
		ActivitySystem.get_season_recharge_info_req(false);
	else
		log("ActivitySystem.season_recharge_buy_rsp error");
	end
end

function ActivitySystem.season_recharge_progress_changed_notify(data)
    TheFirstChargeUI.ChangedNotify(data);
end

-- 通知服务器完成了问卷
function ActivitySystem.questionnaire_finished_report_req()
	QuestionnaireHander.send_questionnaire_finished_report_req()
	--NetUtil.SendPkg("questionnaire_finished_report_req");
end

--新的活动收到推送 告知去拉活动数据
function ActivitySystem.On_notify_activity_and_display_changed(is_activity_changed,is_display_chagned)
	-- body
	if is_activity_changed then
		log("is_activity_changed")
		DataMgr.ResetActivityData()
		--ActivtyUI.ClearCurrentActivityData()
		--NetUtil.SendPkg("get_activity_list_req")
	end

	if is_display_chagned then
		NetUtil.SendPkg("get_activity_display_req")
	end
end


s2c["take_activity_award_res"] = ActivitySystem.Res_TakeActivityAward
s2c["take_special_activity_award_res"] = ActivitySystem.Res_TakeSpecialActivityAward
s2c["get_activity_batch_res"] = ActivitySystem.InitActivityData
s2c["get_activity_list_res"] = ActivitySystem.InitActivityList
s2c["get_activity_one_res"] = ActivitySystem.UpdateActivityData
s2c["activity_market_info_rsp"] = ActivitySystem.activity_market_info_rsp

--------------------------0.10.0新首冲协议---------------------------
s2c["get_season_recharge_info_rsp"] = ActivitySystem.get_season_recharge_info_rsp
s2c["take_season_recharge_award_rsp"] = ActivitySystem.take_season_recharge_award_rsp
s2c["season_recharge_buy_rsp"] = ActivitySystem.season_recharge_buy_rsp
s2c["season_recharge_progress_changed_notify"] = ActivitySystem.season_recharge_progress_changed_notify


--------------------------0.11.0新的活动收到推送 告知去拉活动数据---------------------------

s2c["notify_activity_and_display_changed"] = ActivitySystem.On_notify_activity_and_display_changed


