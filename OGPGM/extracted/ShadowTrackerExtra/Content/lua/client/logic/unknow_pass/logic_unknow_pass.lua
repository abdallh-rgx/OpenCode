UnknowPassSystem = UnknowPassSystem or
{
	Data = {}, -- upass_get_rsp返回的第三个参数，具体数据定义参考协议文件
	Award_Group_Data = {}, -- 奖励分组信息
	Award_Group_Cfg_Md5 = nil,	-- 分组表md5值,后台透传

	Level = 0,
	Score = 0,
	Season = 0,
	SeasonInfo = {},

	IsBuyElite = false,  -- 是否购买精英通行证
	switch = {}, --switch  = {ui = true, battle_tittle = true, battle_show = true}
	MaxLevel = 0,

	IsInCurSession = false,

	BuyBeforeLevel = 0,  -- 购买通行证之前的等级

	HasUnclaimedReward = false,
	bTaskRedpotAfterBuyPass = false,	--购买pass之后的任务红点提示
	
	--sami 结算触发完成pass任务id
	gameEndShowFinishTaskId = 0,
    
    -- 一键领取奖励的选择 
    SelectAwards = {},
	--是否有兑换数据
	bExchangeRsp = false,
	Avatar = nil,
	--购买pass请求id
	reqBuyId = 0,
	
	bShowAwatar = false;
	bShowUpgradeUI = false;
	bShowIcon = false;
}

UNKNOW_PASS_REASON_UPASS_ADD_SCORE_WEEK          = 1001; --绝地通行证增加分数，周任务奖励
UNKNOW_PASS_REASON_UPASS_ADD_SCORE_DAILY         = 1002; --绝地通行证增加分数，日任务奖励
UNKNOW_PASS_REASON_UPASS_ADD_SCORE_BUY           = 1003; --绝地通行证增加分数，购买奖励
UNKNOW_PASS_REASON_UPASS_COST_EXCHANGE           = 1004; --绝地通行证消耗分数，兑换
UNKNOW_PASS_REASON_UPASS_ITEM_AWARD              = 1005; --绝地通行证道具奖励
UNKNOW_PASS_REASON_UPASS_ADD_SCORE_CARD          = 1006; --绝地通行证增加分数，使用积分卡
UNKNOW_PASS_REASON_UPASS_ADD_SCORE_CHEST         = 1007; --绝地通行证增加分数，开宝箱
UNKNOW_PASS_REASON_UPASS_ADD_SCORE_QUICK_LEVEL   = 1008; --绝地通行证增加分数，快速升级

-- 分组信息回包错误码
local errcode_level_award_group_cfg_ok = 0;		-- 分组信息有改动，后台会传来配置项
local errcode_level_award_group_cfg_not_change = 502035;			-- 分组信息无改动，后台会传来配置项

UnkonwPass_ShowLeftDetailLastType = 0;
UnkonwPass_ShowLeftDetailNone = 0;
UnkonwPass_ShowLeftDetailUpgradeUI = 1; 	-- 显示upgrade upass的ui
UnkonwPass_ShowLeftDetailItemAvatar = 2;	-- 显示物品相应的avatar预览
UnkonwPass_ShowLeftDetailItemExpression = 3;-- 显示物品相应的avatar表情预览
UnkonwPass_ShowLeftDetailItemIcon = 4;		-- 显示物品的icon
UnkonwPass_ShowLeftDetailDefaultAvatar = 5; -- 显示默认的玩家avatar预览

UnknowPass_Tab_Show = 0;			-- 当前显示的页签
UnknowPass_Tab_None = 0;			-- 空白页签
UnknowPass_Tab_Award = 1;			-- 奖励页签
UnknowPass_Tab_Mission = 2;			-- 任务页签
UnknowPass_Tab_Exchange = 3;		-- 兑换页签
UnknowPass_Tab_Rank = 4;		-- 兑换页签

UnknowPassNeedShowLevelUpReasonList = {
	UNKNOW_PASS_REASON_UPASS_ADD_SCORE_WEEK,
	UNKNOW_PASS_REASON_UPASS_ADD_SCORE_DAILY,
	UNKNOW_PASS_REASON_UPASS_COST_EXCHANGE,
	UNKNOW_PASS_REASON_UPASS_ITEM_AWARD,
	UNKNOW_PASS_REASON_UPASS_ADD_SCORE_CARD,
	UNKNOW_PASS_REASON_UPASS_ADD_SCORE_CHEST,
}


function UnknowPassSystem.Enter()
	log("UnknowPassSystem enter");
	UnkonwPass_ShowLeftDetailLastType = UnkonwPass_ShowLeftDetailNone;
	UnknowPassSystem.TaskConfigSeasonId = 0;
	UnknowPassSystem.GetAllPassConfig()
	UnknowPassSystem.upass_get_req();
	UnknowPassSystem.upass_buy_pass_list_req();
	UnknowPassSystem.upass_exchange_list_req();
end

function UnknowPassSystem.Release()
	log("UnknowPassSystem Release");
	UnkonwPass_ShowLeftDetailLastType = UnkonwPass_ShowLeftDetailNone;
	UnknowPassSystem.DestroyAvatar();
end

--获取通行证开关 switch  = {ui = true, battle_tittle = true, battle_show = true}
--ui：是否在排行榜、聊天、好友界面显示绝地通行证
--battle_title：在出生岛以及战斗内显示绝地通行证信息 
--battle_show：参与通行证等级评选  
function UnknowPassSystem:GetUnknowPassSwitch()
	return UnknowPassSystem.switch
end

function UnknowPassSystem:PopErrorMsg(errorCode)
	local msg = Client.GetTableData("LocalizeRes", errorCode);
	if msg then
		PopUpNoticeUI.ShowFastNoticeQueue(msg.TextValue)
	end
	
	--log_tree("UnknowPassSystem:PopErrorMsg: ", errorCode);
end

function UnknowPassSystem:SetSeasonStatus(season_info)
	UnknowPassSystem.SeasonInfo = season_info;
	UnknowPassSystem.IsInCurSession = season_info.in_cur_season;
	
	BP_UNKNOWPASS_IS_IN_CURRENT_SESSION = UnknowPassSystem.IsInCurSession;
	LobbyUI.ShowUnknowPassSeasonLock()

	-- 修改赛季名和赛季时间
	BP_UnknowPass_Award_SeasonName = season_info.cfg.season_name;
	BP_UnknowPass_Award_SeasonTime = season_info.cfg.show_time;

	BP_UnknowPass_Mission_SeasonName = season_info.cfg.season_name;
	BP_UnknowPass_Mission_SeasonTime = season_info.cfg.show_time;

	BP_UnknowPass_Exchange_SeasonName = season_info.cfg.season_name;
	BP_UnknowPass_Exchange_SeasonTime = season_info.cfg.show_time;

	BP_UnknowPass_Buy_SeasonName = season_info.cfg.season_name;
	BP_UnknowPass_Buy_SeasonTime = season_info.cfg.show_time;

	BP_UnknowPass_Rank_SeasonName = season_info.cfg.season_name;
	BP_UnknowPass_Rank_SeasonTime = season_info.cfg.show_time;
end

function UnknowPassSystem.IsMaxLevel()
	return UnknowPassSystem.Level >= UnknowPassSystem.MaxLevel;
end

function UnknowPassSystem:GetAwardList(reward_list)
	local itemList = {};
	if reward_list then
		for i,v in ipairs(reward_list) do
			table.insert(itemList, {
				resId = v.item_id,
				number = v.item_num,
				showType = v.item_show_type,
			})
		end
	end
	return itemList;
end

-- 请求可购买的通行证列表
function UnknowPassSystem.upass_buy_pass_list_req()
	log("upass_buy_pass_list_req");
	NetUtil.SendPriorityPkg(false, "upass_buy_pass_list_rsp", "upass_buy_pass_list_req");
end

function UnknowPassSystem.upass_buy_pass_list_rsp(tb, isBuy)
	--log_tree("upass_buy_pass_list_rsp", tb);
	-- log("upass_buy_pass_list_rsp isBuy: " .. isBuy);
	UnknowPassSystem.IsBuyElite = isBuy ~= 0;
	BP_UnknowPass_HasBuy = UnknowPassSystem.IsBuyElite;

	UnknowPassAwardUI.UpdateBuyButton();

	UnknowPassBuy.OnUpdateBuyData(tb)
	if UnknowPassSystem.IsBuyElite and UnknowPassAwardUI.isShowing then
		--UnknowPassUI.ResetItemAvatar()
	end
end

--是否是普通pass
function UnknowPassSystem.IsNormalPassBuyId(buyId)
	local tb = Client.GetTable("UnknowPassBuyCfg")
	for k, v in pairs(tb) do
		if v.ID == buyId then
			if v.buyType == 1 then
				return true
			else
				return false
			end
		end
	end
	return false
end

-- 购买通行证
function UnknowPassSystem.upass_buy_pass_req(buyid)
	UnknowPassSystem.reqBuyId = buyid
	NetUtil.SendPriorityPkg(false, "upass_buy_pass_rsp", "upass_buy_pass_req", buyid);
end

function UnknowPassSystem.upass_buy_pass_rsp(res, reward_list, upass_score, upass_level, before_level)
	if res == 0 then	
		UnknowPassBuy.HideUI()
		UnknowPassSystem.Level = upass_level;
		UnknowPassSystem.Score = upass_score;
		UnknowPassSystem.BuyBeforeLevel = before_level;
		UnknowPassSystem.IsBuyElite = true;
		UnknowPassUI.showWeekReddot = true;
		UnknowPassSystem.bTaskRedpotAfterBuyPass = true
		UnknowPassAwardUI.bFreshed = false
		UnknowPassAwardUI.isNeedInitAwards = true;
		UnknowPassUI.UpdateReddot();
		EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_BUY_PASS, reward_list);

		if UnknowPassSystem.IsNormalPassBuyId(UnknowPassSystem.reqBuyId) then
			UnknowPassUI.ReportBuyEvent(true, false, false, 1)
		else
			UnknowPassUI.ReportBuyEvent(true, false, false, 2)
		end
		
		-- 刷新下购买信息
		UnknowPassSystem.upass_buy_pass_list_req();
		UnknowPassSystem.upass_get_req();

		-- 刷新主界面的活动列表
		LobbySystem.refresh_activity_display_by_unknow_pass();
		if BP_UnknowPass_Tab_Index == 0 then	-- 等级奖励界面才会刷新为人物显示
			UnknowPassSystem.ShowLeftDetail(UnkonwPass_ShowLeftDetailDefaultAvatar)
		end
	else
		if res == 502006 then
			local title = Client.GetTableData("LocalizeRes", "101001").TextValue;
			local tip = Client.GetTableData("LocalizeRes", "4119").TextValue;
			CommonMessageBoxUI:ShowPanel(2, title, tip, function()
				RechargeUI:Init();
				return true;
			end);
		else
			UnknowPassSystem:PopErrorMsg(res);
		end
	end
end

-- 获取分组信息
function UnknowPassSystem.upass_level_award_group_cfg()
	log("upass_level_award_group_cfg_req,md5:"..tostring(UnknowPassSystem.Award_Group_Cfg_Md5));
	NetUtil.SendPriorityPkg(false, "client_table_rsp", "client_table_req","unpass_level_award_group_cfg",UnknowPassSystem.Award_Group_Cfg_Md5);
end

-- 分组信息回包
function UnknowPassSystem.client_table_rsp(msg, table_name, group_config, version)
	log("client_table_rsp, unpass_level_award_group_cfg, msg:"..tostring(msg)..", version:"..tostring(version));
	--log_tree("group_config:",group_config);
	if msg == errcode_level_award_group_cfg_ok then	-- 配置有变化,设置md5和config
		UnknowPassSystem.Award_Group_Cfg_Md5 = version;
		UnknowPassSystem.Award_Group_Data = group_config;
	elseif msg == errcode_level_award_group_cfg_not_change then	--配置没有变化
		-- do nothing
	end
end

-- 获取pass的配置数据
function UnknowPassSystem.GetAllPassConfig()
	local dataTable = {"unpass_level_award_group_cfg","upass_ordinary_reward_cfg",
					   "upass_elite_reward_cfg","upass_weekly_reward_cfg"};
	DataConfigMgr.ConfigBatchReq(dataTable)
end

function UnknowPassSystem.DealWithConfig(tableName, data)
	if tableName == "unpass_level_award_group_cfg" then		-- 等级分组
		UnknowPassSystem.Award_Group_Data = data;
	elseif tableName == "upass_ordinary_reward_cfg" then 	-- 普通奖励
		UnknowPassSystem.Data.ordinary_reward_cfg = data;
	elseif tableName == "upass_elite_reward_cfg" then		-- 精英奖励
		UnknowPassSystem.Data.elite_reward_cfg = data;
	elseif tableName == "upass_weekly_reward_cfg" then		-- 挑战任务
		UnknowPassSystem.Data.weekly_reward_cfg = data;
	end
end

-- 获取通行证数据（旧方案，完整数据,新协议，部分数据,大部分数据从配置读取）
function UnknowPassSystem.upass_get_req()
	NetUtil.SendPriorityPkg(false, "upass_new_get_rsp", "upass_new_get_req");
end

-- 从本地配置读取信息
local function CombineUPassData(res_data)
	res_data.ordinary_reward_cfg = UnknowPassSystem.Data.ordinary_reward_cfg or {};
	res_data.elite_reward_cfg = UnknowPassSystem.Data.elite_reward_cfg or {};
	res_data.weekly_reward_cfg = UnknowPassSystem.Data.weekly_reward_cfg or {};
	res_data.all_week_task_cfg = UnknowPassSystem.Data.all_week_task_cfg or {};
	UnknowPassSystem.Data = res_data;

	-- task_cfg 每日任务 daily_task
	for taskId,task in pairs(UnknowPassSystem.Data.daily_task) do
		local taskCfg = Client.GetTableData("UnknowPassMissionCfg", taskId)
		if taskCfg then
			local taskCfgInfo = {};
			taskCfgInfo.title = taskCfg.MissionTitle;			-- 任务标题
			taskCfgInfo.desc = taskCfg.Desc;					-- 任务描述
			taskCfgInfo.finish_value = taskCfg.FinishValue;		-- 完成数值
			taskCfgInfo.finish_type = taskCfg.FinishType;		-- 完成方式
			taskCfgInfo.reward_score = taskCfg.RewardScore;		-- 奖励积分
			task.task_cfg = taskCfgInfo;
		end
	end

	if UnknowPassSystem.TaskConfigSeasonId ~= res_data.base.cur_season then
		local all_week_task_cfg = {};
		local hasSetWeekCfg = false;
		local taskCfgs = Client.GetTable("UnknowPassMissionCfg")
		for id, taskCfg in pairs(taskCfgs) do
			if taskCfg.SeasonId == res_data.base.cur_season and taskCfg.UpdateType == 2 then
				local taskCfgInfo = {};
				taskCfgInfo.sort = taskCfg.Sort;					-- 排序顺序
				taskCfgInfo.week_index = taskCfg.WeekIndex;			-- 所属周
				taskCfgInfo.finish_type = taskCfg.FinishType;		-- 完成方式
				taskCfgInfo.title = taskCfg.MissionTitle;			-- 任务标题
				taskCfgInfo.finish_value = taskCfg.FinishValue;		-- 完成数值	
				taskCfgInfo.desc = taskCfg.Desc;					-- 描述
				taskCfgInfo.is_elite_task = taskCfg.IsEliteTask;	-- 是否精英任务
				taskCfgInfo.reward_score = taskCfg.RewardScore;		-- 奖励积分
				all_week_task_cfg[tonumber(id)] = taskCfgInfo;
				hasSetWeekCfg = true;
			end
		end
		if hasSetWeekCfg then
			UnknowPassSystem.Data.all_week_task_cfg = all_week_task_cfg;
			UnknowPassSystem.TaskConfigSeasonId = res_data.base.cur_season;
		end
	end
end

-- 通行证回包（新方案，接收了部分数据、大部分数据从本地配置表读取）
function UnknowPassSystem.upass_new_get_rsp(upass_score, upass_level, res_data)
	--通行证信息数据，daily_reward_time: 0 每日奖励领取时间
	log("UnknowPassSystem.upass_get_rsp upass_score = ".. tostring(upass_score))
	--log_tree("UnknowPassSystem.upass_get_rsp res_data = ", res_data)

	CombineUPassData(res_data);	-- 客户端读取本地表格
	UnknowPassSystem.Score = upass_score;
	UnknowPassSystem.Level = upass_level;
	UnknowPassSystem.Season = res_data.base.cur_season;
	UnknowPassSystem.IsBuyElite = res_data.base.is_buy == 1;
	UnknowPassSystem.MaxLevel = res_data.upass_max_level or 20;
	UnknowPassSystem.HasUnclaimedReward = res_data.unclaimed and res_data.unclaimed.reward and #res_data.unclaimed.reward > 0;

	if UIManager.GetUI(eUIType.eUnknowPassAwardUI)~= nil or  UIManager.GetUI(eUIType.eUnknowPassExchangeUI)~= nil then
		UnknowPassUI.CheckAndShowSeasonReward();
	end	
	UnknowPassSystem:SetSeasonStatus(res_data.season_info);

	--通行证开关
	UnknowPassSystem.switch = res_data.base.switch;
	SettingUI:SetUnknowPassSwitch(UnknowPassSystem.switch)
	-- log_tree("res_data:", res_data);
	-- UnknowPassSystem.ParseUnknowInfo(res_data);

	log("[HHF]UnknowPassSystem.upass_get_rsp, received upass_get_rsp, level = " .. tostring(upass_level) .. ", maxLevel = " .. tostring(res_data.upass_max_level) .. ", score = " .. tostring(upass_score) .. ", and update reddot.");
	EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_INFO_UPDATE);
	UnknowPassUI.UpdateReddot();
end

-- 获取奖励
function UnknowPassSystem.upass_get_level_award_req(level, is_elite_task, group_id)
	NetUtil.SendPriorityPkg(false, "upass_get_level_award_rsp", "upass_get_level_award_req", level, is_elite_task, group_id);
end

function UnknowPassSystem.upass_get_level_award_rsp(res, level, is_elite_task, reward_list, group_id, need_buy_awards)
	if res ~= 0 then
		UnknowPassSystem:PopErrorMsg(res);
	else
		if nil ~= need_buy_awards then	-- 更新可买列表
			UnknowPassSystem.Data.reward_status.need_by_awards = need_buy_awards;
		end
		EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_GET_LEVEL_AWARD, {
			level = level,
			is_elite_task = is_elite_task,
			reward_list = reward_list,
			group_id = group_id
		});
		--小红点需要刷新奖励
		--UnknowPassSystem.upass_get_req();
	end
end

-- 购买奖励
function UnknowPassSystem.upass_buy_level_award_req(award_id)
	NetUtil.SendPriorityPkg(false, "upass_buy_level_award_rsp", "upass_buy_level_award_req", award_id);
end

-- 购买奖励回包
function UnknowPassSystem.upass_buy_level_award_rsp(res, award_id, reward_list)
	if res == 0 then
		if nil ~= UnknowPassSystem.Data.reward_status.need_by_awards then	-- 更新可买列表
			log_tree("need_by_awards",UnknowPassSystem.Data.reward_status.need_by_awards)
			local award = UnknowPassSystem.Data.reward_status.need_by_awards[award_id];
			local is_elite_task = award.is_elite;
			local level = award.level;
			local group_id = award.group_id;
			UnknowPassSystem.Data.reward_status.need_by_awards.award_id = nil;
			EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_GET_LEVEL_AWARD, {
				level = level,
				is_elite_task = is_elite_task,
				reward_list = reward_list,
				group_id = group_id
			});			
		end
		UnknowPassSystem.upass_get_req();
	else

	end
end

--请求获取每日任务奖励
function UnknowPassSystem.upass_get_daily_award_req(task_id)
	NetUtil.SendPriorityPkg(false, "upass_get_daily_award_rsp", "upass_get_daily_award_req", task_id);
end

function UnknowPassSystem.upass_get_daily_award_rsp(res, task_id)
	if res ~= 0 then
		UnknowPassSystem:PopErrorMsg(res);
	else
		UnknowPassSystem.upass_get_req();
		--此处要显示增加了多少积分
		if BP_ARRAY_UnknowPass_Day_Mission_List ~= nil then
			for i,list in pairs(BP_ARRAY_UnknowPass_Day_Mission_List) do
				if list and list.taskId ~= nil and list.taskId == task_id then
					local msg = Client.GetTableData("LocalizeRes", 4585) --使用成功，增加%s积分
					if msg then
						local str = string.format(msg.TextValue, tostring(list.score))
						PopUpNoticeUI.ShowFastNoticeQueue(str)
						return;
					end
				end
			end
		end
	end
end

--请求获取周任务奖励
function UnknowPassSystem.upass_get_weekly_award_req(week_index, task_id)
	NetUtil.SendPriorityPkg(false, "upass_get_weekly_award_rsp", "upass_get_weekly_award_req", week_index, task_id);
end

function UnknowPassSystem.upass_get_weekly_award_rsp(res, week_index, task_id)
	if res ~= 0 then
		UnknowPassSystem:PopErrorMsg(res);
	else
		UnknowPassSystem.upass_get_req();

		--此处要显示增加了多少积分
		if BP_ARRAY_UnknowPass_Week_Mission_List ~= nil then
			for i,list in pairs(BP_ARRAY_UnknowPass_Week_Mission_List) do
				if list and list.taskId ~= nil and list.taskId == task_id then
					local msg = Client.GetTableData("LocalizeRes", 4585) --使用成功，增加%s积分
					if msg then
						local str = string.format(msg.TextValue, tostring(list.score))
						PopUpNoticeUI.ShowFastNoticeQueue(str)
						return;
					end
				end
			end
		end
	end
end

--请求手动刷新每日任务
function UnknowPassSystem.upass_refreash_daily_req(task_id)
	NetUtil.SendPriorityPkg(false, "upass_refreash_daily_rsp", "upass_refreash_daily_req", task_id);
end

function UnknowPassSystem.upass_refreash_daily_rsp(res, task_id, new_task_info)
	if res ~= 0 then
		UnknowPassSystem:PopErrorMsg(res);
	else
		UnknowPassSystem.upass_get_req();
	end
end

--请求积分兑换道具列表
function UnknowPassSystem.upass_exchange_list_req()
	NetUtil.SendPriorityPkg(false, "upass_exchange_list_rsp", "upass_exchange_list_req");
end

function UnknowPassSystem.upass_exchange_list_rsp(res, tb, exchange_limit)
	log("UnknowPassSystem.upass_exchange_list_rsp")
	UnknowPassSystem.bExchangeRsp = true
	tb = tb or {}
	BP_ARRAY_UnknowPass_Exchange_Item_List = {}
	for k,v in pairs(tb) do
		local limit = exchange_limit[k]
		local item =
		{
			exchangeId = k,				--配置ID
			limit = v.limit,			--兑换次数限制1-999次
			cost_item_num = v.cost_item_num,	--消耗物品数量
			item_num = v.item_num,				--物品数量
			season_index = v.season_index,		--赛季ID
			sort = v.sort,						--排序顺序
			pass_level_limit = v.pass_level_limit,		--通行证等级限制
			disc_cost_item_num = v.disc_cost_item_num,	--折扣消耗物品数量
			item_id = v.item_id,						--物品ID
			item_expire_time = v.item_expire_time,	--物品有效时间
			item_show_type = v.item_show_type,		--物品获取展示方式
			cost_item_id = v.cost_item_id,			--消耗物品ID
		}
		if limit and limit.buy_count > 0 then
			item.buy_count = limit.buy_count
		else
			item.buy_count = 0
		end
		--修正打折
		if item.disc_cost_item_num == 0 then
			item.disc_cost_item_num = item.cost_item_num
		end
		
		local fmt = Client.GetTableData("LocalizeRes", 6391).TextValue;
		item.strLevelLimit = string.format(fmt, v.pass_level_limit)
		local cfg = Client.GetTableData("Item", v.cost_item_id)
		item.strCostItemIcon = cfg.ItemSmallIcon
	
		table.insert(BP_ARRAY_UnknowPass_Exchange_Item_List, item);
	end
	
	table.sort(BP_ARRAY_UnknowPass_Exchange_Item_List, function(a, b)
		return a.sort < b.sort;
	end)
	--log_tree("BP_ARRAY_UnknowPass_Exchange_Item_List", BP_ARRAY_UnknowPass_Exchange_Item_List);

	LuaClassObj.HandleUIMessage(bp_unknow_pass_exchange, "InitExchangeItemList");

	if UnknowPassUI.jumpInfo and UnknowPassUI.jumpInfo.Tab1 == 2 then
		UnknowPassExchangeUI.JumpTo(UnknowPassUI.jumpInfo.itemId)
		--UnknowPassUI.jumpInfo = nil
	end
end

--请求额外积分兑换道具
function UnknowPassSystem.upass_exchange_req(exchangeId, item_count, cur_buy_count)
	log(string.format("exchangeId: %d, item_count, %d, cur_buy_count: %d", exchangeId, item_count, cur_buy_count));
	NetUtil.SendPriorityPkg(false, "upass_exchange_rsp", "upass_exchange_req", exchangeId, item_count, cur_buy_count);
end

function UnknowPassSystem.upass_exchange_rsp(res, id, reward_list, new_buy_count)
	if res ~= 0 then
		UnknowPassSystem:PopErrorMsg(res);
	else
		UnknowPassSystem.upass_exchange_list_req();
		UnknowPassSystem.upass_get_req();
		EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_EXCHANGE_SUCCESS, reward_list);
	end
end
  
--请求购买积分 （购买积分快速升级）
function UnknowPassSystem.upass_buy_score_req(diff_score, cur_level, cur_score)
	NetUtil.SendPriorityPkg(false, "upass_buy_score_rsp", "upass_buy_score_req", diff_score, cur_level, cur_score);
end

function UnknowPassSystem.upass_buy_score_rsp(res, score_add, price_cost, upass_score, upass_level, before_level)
	log("[HHF]UnknowPassSystem.upass_buy_score_rsp, received upass_buy_score_rsp, res = " .. tostring(res));
	if res ~= 0 then
		if res == 502006 then
			local title = Client.GetTableData("LocalizeRes", "101001").TextValue;
			local tip = Client.GetTableData("LocalizeRes", "4119").TextValue;
			CommonMessageBoxUI:ShowPanel(2, title, tip, function()
					RechargeUI:Init();
					return true;
			end);
		else
			UnknowPassSystem:PopErrorMsg(res);
		end
	else
		EventCloseBuyScoreClick();
		UnknowPassSystem.Level = upass_level;
		UnknowPassSystem.Score = upass_score;
		UnknowPassSystem.BuyBeforeLevel = before_level;

		UnknowPassUI.ReportBuyEvent(false, true, false, score_add)
		
		EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_BUY_SCORE);

		Timer.InsertTimer(0.2, function()
			UnknowPassAwardUI.InitAwardLevelPosition();
		end , false, true);
		
		UnknowPassSystem.upass_get_req();
	end
end

--请求购买等级（购买积分快速升级）
function UnknowPassSystem.upass_quick_level_up_req(buyLevel, curLevel)
	NetUtil.SendPriorityPkg(false, "upass_quick_level_up_rsp", "upass_quick_level_up_req", buyLevel, curLevel);
end

function UnknowPassSystem.upass_quick_level_up_rsp(res, score_add, price_cost, upass_score, upass_level, before_level)
	if res ~= 0 then
		if res == 502006 then
			local title = Client.GetTableData("LocalizeRes", "101001").TextValue;
			local tip = Client.GetTableData("LocalizeRes", "4119").TextValue;
			CommonMessageBoxUI:ShowPanel(2, title, tip, function()
				RechargeUI:Init();
				return true;
			end);
		else
			UnknowPassSystem:PopErrorMsg(res);
		end

		UnknowPassUI.ShowTab();
	else
		UnknowPassSystem.Level = upass_level;
		UnknowPassSystem.Score = upass_score;
		UnknowPassSystem.BuyBeforeLevel = before_level;
		EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_BUY_SCORE);

		Timer.InsertTimer(0.2, function()
			UnknowPassAwardUI.InitAwardLevelPosition();
		end , false, true);
	end
end

--请求一键领取所有等级奖励
function UnknowPassSystem.upass_batch_get_level_award_req(selects)
    log_tree("selects",selects);
	NetUtil.SendPriorityPkg(false, "upass_batch_get_level_award_rsp", "upass_batch_get_level_award_req",selects);
end

function UnknowPassSystem.upass_batch_get_level_award_rsp(res, reward_tb, need_buy_awards)
	if res ~= 0 then
		UnknowPassSystem:PopErrorMsg(res);
	else
		if nil ~= need_buy_awards then	-- 更新可买列表
			UnknowPassSystem.Data.reward_status.need_by_awards = need_buy_awards;
		end		
		EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_BATCH_GET_LEVEL_AWARD, reward_tb);
		UnknowPassSystem.upass_get_req();
	end
end

--修改通行证开关
function UnknowPassSystem:upass_change_switch_req(ui, battle_title, battle_show)
	NetUtil.SendPkg("upass_change_switch_req", ui, battle_title, battle_show);
end

function UnknowPassSystem.upass_change_switch_rsp(res, switch)
	if res ~= 0 then
        UnknowPassSystem:PopErrorMsg(res);
		return;
	end
	UnknowPassSystem.switch = switch;
	SettingUI:SetUnknowPassSwitch(switch)
end

-- 领取当前周奖励
function UnknowPassSystem.upass_get_curweek_award_req()
	NetUtil.SendPriorityPkg(false, "upass_get_curweek_award_rsp", "upass_get_curweek_award_req");
end

function UnknowPassSystem.upass_get_curweek_award_rsp(res, reward_list)
	if res ~= 0 then
		UnknowPassSystem:PopErrorMsg(res);
	else
		UnknowPassSystem.upass_get_req();
		UnknowPassMissionUI.ShowAwardList(reward_list);
	end
end

-- 一键领取当前所有任务
function UnknowPassSystem.upass_task_batch_reward_req()
	NetUtil.SendPriorityPkg(false, "upass_task_batch_reward_rsp", "upass_task_batch_reward_req");
end

-- 一键领取奖励回包
function UnknowPassSystem.upass_task_batch_reward_rsp(res, total_score)
	if res ~= 0 then
		UnknowPassSystem:PopErrorMsg(res);
	else
        UnknowPassSystem.upass_get_req();
        UnknowPassMissionAwardAllUI.Init(total_score)
    end
end

--通知积分变化
function UnknowPassSystem.UPassScoreNotifyChg(value, cur_score, cur_level, before_level, reason)
	
	UnknowPassSystem.Level = cur_level;
	UnknowPassSystem.Score = cur_score;
	UnknowPassSystem.BuyBeforeLevel = before_level;

	if OpenBoxtUI.isShow then
		local tips = string.format(Client.GetTableData("LocalizeRes", "4585").TextValue, tostring( value));
		PopUpNoticeUI.ShowNewNotice(tips);
	end

	EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_ADD_SCORE_NOTIFY, reason);
end

--使用积分卡通知
function UnknowPassSystem.SyncUpassScoreCardInfo(score, itemid, count, cur_score, cur_level)
	
	local msg = Client.GetTableData("LocalizeRes", 4579) --使用成功，增加%s积分
	if msg then
		local str = string.format(msg.TextValue, tostring(score))
		PopUpNoticeUI.ShowFastNoticeQueue(str)
	end
end

--请求领取之前赛季的未领奖励
function UnknowPassSystem.upass_get_unclaimed_reward_req()
	NetUtil.SendPriorityPkg(false, "upass_get_unclaimed_reward_rsp", "upass_get_unclaimed_reward_req");
end

function UnknowPassSystem.upass_get_unclaimed_reward_rsp(res, reward_tb)
	UnknowPassSystem.HasUnclaimedReward = false;
	if res == 0 and reward_tb then
		EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_GET_UNCLAIMED_SEASON_AWARD, reward_tb);
	end
end

--请求获取赛季相关数据
function UnknowPassSystem.upass_get_season_info_req()
	NetUtil.SendPriorityPkg(false, "upass_get_season_info_rsp", "upass_get_season_info_req");
end

function UnknowPassSystem.upass_get_season_info_rsp(season_info)
	--log_tree("season_info", season_info);
	UnknowPassSystem:SetSeasonStatus(season_info);
end

function UnknowPassSystem.upass_notify_data_chg()
	--log("UnknowPassSystem.upass_notify_data_chg");
	LobbyUI:UpdateUnknowPassReddot(true);
end

function UnknowPassSystem.requestGetDailyTask()
	log("UnknowPassSystem.requestGetDailyTask");
	NetUtil.SendPriorityPkg(false, "upass_daily_award_rsp", "upass_daily_award_req");
end

function UnknowPassSystem.upass_daily_award_rsp(resCode, awardCfg, cur_time)
	log("UnknowPassSystem.upass_daily_award_rsp resCode = ".. resCode)
	if resCode ~= 0 then
		if resCode == 502015 then
			UnknowPassSystem:PopErrorMsg(502015);
		elseif resCode == 502021 then
			UnknowPassSystem:PopErrorMsg(108301);
		end
		return
	end
	--log_tree("awardCfg = ", awardCfg)

	local itemList = {};
	local score = 0
	for k,v in pairs(awardCfg) do
		table.insert(itemList, {
			resId = k,
			number = v.item_num,
			showType = 0,
		})
		score = v.item_num
	end
	--log_tree("itemList = ", itemList)
	
	local msg = Client.GetTableData("LocalizeRes", 4585) --使用成功，增加%s积分
	if msg then
		local str = string.format(msg.TextValue, tostring(score))
		PopUpNoticeUI.ShowFastNoticeQueue(str)
	end
	
	UnknowPassSystem.upass_get_req()
end


--sami 获取任务信息
function UnknowPassSystem.GetWeekTitle()
	if UnknowPassSystem.Data == nil then
		return ""
	end
	local cfg = Client.GetTableData("UnknowPassWeekNameCfg", UnknowPassSystem.Data.cur_week_index)
	if cfg == nil then
		return ""
	end
	return cfg.WeekName
end

function UnknowPassSystem.GetWeekTaskNum()
	local num = 0
	local data = UnknowPassSystem.Data
	if data and data.base and data.base.week_finish then
		num = data.base.week_finish
	end
	--限制完成任务数最大值
	if data and data.weekly_reward_cfg and num > (data.weekly_reward_cfg.task_num or 0) then
		num = data.weekly_reward_cfg.task_num
	end
	return num
end

function UnknowPassSystem.GetGameEndShowPassTaskInfo()
	local taskInfo = 
	{
		taskId = 0,		--0表示全部任务已完成
		desc = "",		--任务描述
		status = 0,		--任务完成状态，0-未完成
		weekTitle = "",	--周标题
		weekTaskNum = 0,	--周任务完成数量
		refresh_time = 0,
	}
	taskInfo.weekTitle = UnknowPassSystem.GetWeekTitle()
	taskInfo.weekTaskNum = UnknowPassSystem.GetWeekTaskNum()
	
	if UnknowPassSystem.Data == nil or UnknowPassSystem.gameEndShowFinishTaskId == 0 then
		return taskInfo
	end
	local taskId = UnknowPassSystem.gameEndShowFinishTaskId
	if UnknowPassSystem.gameEndShowFinishTaskId == 0 then
		local info = UnknowPassSystem.GetUnFinishPassTaskInfo()
		if info == nil then
			return taskInfo
		end
		taskInfo = info
	else
		local dailyTask = UnknowPassSystem.Data.daily_task[taskId]
		if dailyTask ~= nil then
			taskInfo.taskId = taskId
			taskInfo.desc = dailyTask.task_cfg.desc
			taskInfo.status = dailyTask.task_data.status
			taskInfo.refresh_time = dailyTask.task_data.refresh_time
			return taskInfo
		end
		
		local taskCfg = UnknowPassSystem.Data.all_week_task_cfg[taskId]
		local weekTask = UnknowPassSystem.Data.week_task[taskId]
		if taskCfg ~= nil and weekTask ~= nil  then
			taskInfo.taskId = taskId
			taskInfo.desc = taskCfg.desc
			taskInfo.status = weekTask.task_data.status
			taskInfo.refresh_time = 0
			return taskInfo
		end
	end
	return taskInfo
end

--sami 获取一个未完成的pass任务
function UnknowPassSystem.GetUnFinishPassTaskInfo()
	if UnknowPassSystem.Data == nil then
		return nil
	end
	
	--每日任务
	local taskList = {}
	if UnknowPassSystem.Data and UnknowPassSystem.Data.daily_task then
		for taskId,task in pairs(UnknowPassSystem.Data.daily_task) do
			if task.task_cfg and task.task_data then
				if task.task_data.status == BP_UnknowPass_Mission_NotFinish then
					local taskInfo = {}
					taskInfo.taskId = taskId
					taskInfo.desc = task.task_cfg.desc
					taskInfo.status = task.task_data.status
					taskInfo.weekTitle = UnknowPassSystem.GetWeekTitle()
					taskInfo.weekTaskNum = UnknowPassSystem.GetWeekTaskNum()
					taskInfo.refresh_time = task.task_data.refresh_time
					table.insert(taskList, taskInfo)
				end
			end
		end
	end
	table.sort(taskList, function(a, b)
		return a.refresh_time > b.refresh_time
	end)
	--log_tree("UnknowPassSystem.GetUnFinishPassTaskInfo taskList 1 ", taskList)
	if #taskList > 0 then
		return taskList[1]
	end
	
	--周任务
	taskList = {}
	if UnknowPassSystem.Data.all_week_task_cfg then
		for taskId,task_cfg in pairs(UnknowPassSystem.Data.all_week_task_cfg) do
			if task_cfg and task_cfg.week_index == UnknowPassSystem.Data.cur_week_index then
				local task = UnknowPassSystem.Data.week_task[taskId];
				if task and task.task_data.status == BP_UnknowPass_Mission_NotFinish then
					log_tree("task ", task)
					local taskInfo = {}
					taskInfo.taskId = taskId
					taskInfo.desc = task_cfg.desc
					taskInfo.status = task.task_data.status
					taskInfo.weekTitle = UnknowPassSystem.GetWeekTitle()
					taskInfo.weekTaskNum = UnknowPassSystem.GetWeekTaskNum()
					taskInfo.refresh_time = 0
					table.insert(taskList, taskInfo)
				end
			end
		end
	end
	--log_tree("UnknowPassSystem.GetUnFinishPassTaskInfo taskList 2 ", taskList)
	if #taskList > 0 then
		return taskList[1]
	end	
	return nil
end

--sami 结算展示upass任务完成进度
function UnknowPassSystem.on_game_end_show_finish_task(taskId)
	log("on_game_end_show_finish_task " ..taskId)
	UnknowPassSystem.gameEndShowFinishTaskId = taskId
	
	UnknowPassSystem.upass_get_req();
end

function UnknowPassSystem.upass_imm_finish_task_rsp(ret, task_id, task_data, get_reward_num_if_buy)
    --log("upass_imm_finish_task_rsp:"..ret.." "..task_id)
    --log_tree("task_data:", task_data)
    if ret ~= 0 then
        ShowNotice(ret)
        return
    end
    
    local function IncreaceWeekTaskFinish()
        if ret == 0 and task_data.status > 0 then
			local base = UnknowPassSystem.Data.base
			base.week_finish = base.week_finish + 1
			UnknowPassMissionUI.UpdateBoxInfo()
		end
    end
    
    local dailyTask = UnknowPassSystem.Data.daily_task[task_id]
    if dailyTask then
        IncreaceWeekTaskFinish()
        
        dailyTask.task_data = task_data
        UnknowPassMissionUI.UpdateDayMissionList()
    end
    
    local weekTask = UnknowPassSystem.Data.week_task[task_id]
	if weekTask then
		IncreaceWeekTaskFinish()
        
        weekTask.task_data = task_data
        UnknowPassMissionUI.UpdateWeekMissionList()
    end
    
    if UnknowPassMissionUI.IsShowDayMission then
		UnknowPassMissionUI.InitDayMissionList();
	else
		UnknowPassMissionUI.InitWeekMissionList();
	end

	UnknowPassSystem.Data.get_reward_num_if_buy = get_reward_num_if_buy or 0
	UnknowPassAwardUI.FreshBuyPassTip()
	UnknowPassMissionUI.UpdateAllMissionButton();
end

--处理道具不足
function UnknowPassSystem.ProcItemNotEnough(itemId, needNum)
	log("UnknowPassSystem.ProcItemNotEnough itemId "..itemId..",needNum="..needNum)
	if itemId == 1000 then
		local num = DataMgr.gold
		if num < needNum then
			ShowNotice(502024)
			return false
		end
	elseif itemId == 1006 then
		local num = DataMgr.ticket
		if num < needNum then
			local title = Client.GetTableData("LocalizeRes", "101001").TextValue;
			local tip = Client.GetTableData("LocalizeRes", "4119").TextValue;
			CommonMessageBoxUI:ShowPanel(2, title, tip, function()
				RechargeUI:Init();
				return true;
			end);
			return false
		end
	elseif itemId == 1099 then
		local num = UnknowPassSystem.Score
		if num < needNum then
			local title = Client.GetTableData("LocalizeRes", "101001").TextValue;
			local tip = Client.GetTableData("LocalizeRes", "4607").TextValue;
			CommonMessageBoxUI:ShowPanel(2, title, tip, function()
				EventUnknowPassExchangeOpenBuyDialog()
				return true;
			end);
			return false
		end
	end
	return true
end

-- 能否切换到指定的tab
function UnknowPassSystem.IsSwitchTabVaild(showTab)
	if UnknowPass_Tab_Show == showTab then
		return false;
	else
		UnknowPass_Tab_Show = showTab;
		return true;
	end
end

-- 显示左侧物品的内容、玩家形象、或者ui展示
-- @显示类型，物品为0，
-- @物品id
function UnknowPassSystem.ShowLeftDetail(showType, itemId)
	if nil == UIManager.GetUI(eUIType.eUnknowPassUI) then
		return;
    end

	UnknowPassSystem.StopAction();
	
	if showType == UnkonwPass_ShowLeftDetailUpgradeUI then			-- 显示升级UI,隐藏其他的显示类型
		UnknowPassAwardUI.ShowUpgradeUI();
		UnknowPassUI.HideItemIcon();
		UnknowPassSystem.HideAvatar();
		UnknowPassUI.HideItemDescription();		
	elseif showType == UnkonwPass_ShowLeftDetailItemAvatar then		-- 显示玩家角色,隐藏其他的显示类型
		UnknowPassSystem.ShowItemAvatar(itemId)
		UnknowPassAwardUI.HideUpgradeUI();
		UnknowPassUI.HideItemIcon()
	elseif showType == UnkonwPass_ShowLeftDetailItemExpression then	-- 显示玩家角色播放表情,隐藏其他的显示类型
		UnknowPassSystem.PlayAction(itemId);
		UnknowPassAwardUI.HideUpgradeUI();
		UnknowPassUI.HideItemIcon()
	elseif showType == UnkonwPass_ShowLeftDetailDefaultAvatar then		-- 显示玩家角色,隐藏其他的显示类型
		UnknowPassSystem.ShowAvatar()
		UnknowPassAwardUI.HideUpgradeUI();
		UnknowPassUI.HideItemIcon()
		UnknowPassAwardUI.HideSelectItem()
		UnknowPassUI.HideItemDescription();
	else							-- 显示Icon,隐藏其他的显示类型
		UnknowPassUI.ShowItemIcon(itemId)
		UnknowPassAwardUI.HideUpgradeUI();
		UnknowPassSystem.HideAvatar()
	end	
	UnkonwPass_ShowLeftDetailLastType = showType;
end

function UnknowPassSystem.ShowLeftDetailDefault()
	if UnknowPassSystem.IsBuyElite then
		UnknowPassSystem.ShowLeftDetail(UnkonwPass_ShowLeftDetailDefaultAvatar)
	else
		UnknowPassSystem.ShowLeftDetail(UnkonwPass_ShowLeftDetailUpgradeUI)
	end
end

function UnknowPassSystem.CreateAvatar()
	local myUid = DataMgr.roleData.uid;
	local roleData = ProfileMgr.GetRoleInfoDataByUid(myUid);
	if roleData == nil then
		log("UnknowPassUI.CreateAvatar roleData == nil")
		return
	end	
	
	-- 显示默认的玩家奖励显示装备
	UnknowPassSystem.Avatar = GenderAvatar.Create({}, {x = -45.3, y = -383.5, z = -14347})

	BP_STRUCT_UnknowPass_PlayerData.sex = roleData.gender;
	UnknowPassSystem.SwitchSex(roleData.gender)
	UnknowPassSystem.Avatar:EnableHatHelmetMutex(false);		-- 帽子和头盔不互斥
	UnknowPassSystem.Avatar:EnableLobbyShowItem(true);			-- 头盔背包使用头盔背包映射表内容来映射等级
	UnknowPassSystem.Avatar:PutonEquipment(1405096);
	UnknowPassSystem.Avatar:PutonEquipment(1402132);
	UnknowPassSystem.Avatar:PutonEquipment(1101008014);
	UnknowPassSystem.Avatar:PutonEquipment(1501000045);
end

-- 穿戴装备、武器
function UnknowPassSystem.ShowItemAvatar(itemId)
	UnknowPassSystem.ShowAvatar();
	-- 连续点装备,有脱下的操作
	if UnkonwPass_ShowLeftDetailLastType == UnkonwPass_ShowLeftDetailItemAvatar then
		UnknowPassSystem.Avatar:PutonOrPutoff(itemId);
	else
		UnknowPassSystem.Avatar:PutonEquipment(itemId);
	end
	UnknowPassUI.HideItemDetailOnly(itemId)
end

function UnknowPassSystem.ShowAvatar()
	if nil == UnknowPassSystem.Avatar then
		UnknowPassSystem.CreateAvatar()
	end
	UnknowPassSystem.Avatar:ShowAvatar();
	UnknowPassUI.SetSexButtonVisibile(true)
end

-- 播放表情动画
function UnknowPassSystem.PlayAction(itemId)
	UnknowPassSystem.ShowAvatar();
	UnknowPassSystem.Avatar:PlayAction(itemId);
	UnknowPassUI.HideItemDetailOnly(itemId);
	local myUid = DataMgr.roleData.uid;
	LobbyUI.PlayEmotionSound(itemId, BP_UnknowPass_Preview_Sex, 0, myUid, 1)
end

-- 停止表情动作
function UnknowPassSystem.StopAction()
	if nil ~= UnknowPassSystem.Avatar and  UnkonwPass_ShowLeftDetailLastType == UnkonwPass_ShowLeftDetailItemExpression then
		UnknowPassSystem.Avatar:StopAction();
		LobbyUI.StopEmotionSound();
	end
end

function UnknowPassSystem.HideAvatar()
	if UnknowPassSystem.Avatar then
		UnknowPassSystem.Avatar:HideAvatar();
	end
	UnknowPassUI.SetSexButtonVisibile(false)
end

function UnknowPassSystem.DestroyAvatar()
	if UnknowPassSystem.Avatar then
		UnknowPassSystem.Avatar:Destroy();
		UnknowPassSystem.Avatar = nil;
	end
end

-- 切换性别按钮
function UnknowPassSystem.SwitchSex(sexType)
    BP_UnknowPass_Preview_Sex = sexType;
	if nil ~= UnknowPassSystem.Avatar then
		if sexType == LobbyAvatar.SEX_MALE then
			UnknowPassSystem.Avatar:ShowSex(LobbyAvatar.SEX_MALE)
		else
			UnknowPassSystem.Avatar:ShowSex(LobbyAvatar.SEX_FEMALE)
		end
		UnknowPassUI.UpdateSexButton();
	end
end

s2c["upass_buy_pass_list_rsp"] = UnknowPassSystem.upass_buy_pass_list_rsp;
s2c["upass_buy_pass_rsp"] = UnknowPassSystem.upass_buy_pass_rsp;
s2c["upass_new_get_rsp"] = UnknowPassSystem.upass_new_get_rsp;
s2c["client_table_rsp"] = UnknowPassSystem.client_table_rsp;
s2c["upass_get_level_award_rsp"] = UnknowPassSystem.upass_get_level_award_rsp;
s2c["upass_get_daily_award_rsp"] = UnknowPassSystem.upass_get_daily_award_rsp;
s2c["upass_get_weekly_award_rsp"] = UnknowPassSystem.upass_get_weekly_award_rsp;
s2c["upass_task_batch_reward_rsp"] = UnknowPassSystem.upass_task_batch_reward_rsp;
s2c["upass_refreash_daily_rsp"] = UnknowPassSystem.upass_refreash_daily_rsp;
s2c["upass_exchange_list_rsp"] = UnknowPassSystem.upass_exchange_list_rsp;
s2c["upass_exchange_rsp"] = UnknowPassSystem.upass_exchange_rsp;
s2c["upass_quick_level_up_rsp"] = UnknowPassSystem.upass_quick_level_up_rsp;
s2c["upass_batch_get_level_award_rsp"] = UnknowPassSystem.upass_batch_get_level_award_rsp;
s2c["upass_change_switch_rsp"] = UnknowPassSystem.upass_change_switch_rsp;
s2c["upass_get_curweek_award_rsp"] = UnknowPassSystem.upass_get_curweek_award_rsp;
s2c["upass_score_notify_chg"] = UnknowPassSystem.UPassScoreNotifyChg;
s2c["sync_upass_score_card_info"] = UnknowPassSystem.SyncUpassScoreCardInfo;
s2c["upass_get_unclaimed_reward_rsp"] = UnknowPassSystem.upass_get_unclaimed_reward_rsp;
s2c["upass_get_season_info_rsp"] = UnknowPassSystem.upass_get_season_info_rsp;
s2c["upass_notify_data_chg"] = UnknowPassSystem.upass_notify_data_chg;
s2c["upass_buy_score_rsp"] = UnknowPassSystem.upass_buy_score_rsp;
s2c["upass_daily_award_rsp"] = UnknowPassSystem.upass_daily_award_rsp;
s2c["game_end_show_finish_upass_task"] = UnknowPassSystem.on_game_end_show_finish_task;
s2c["upass_imm_finish_task_rsp"] = UnknowPassSystem.upass_imm_finish_task_rsp;
s2c["upass_buy_level_award_rsp"] = UnknowPassSystem.upass_buy_level_award_rsp;