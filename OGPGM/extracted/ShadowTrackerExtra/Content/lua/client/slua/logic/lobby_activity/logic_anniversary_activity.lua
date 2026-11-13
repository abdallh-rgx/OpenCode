AnniversaryActivitySystem =
{
	DropItemConfig = {};	--掉落表
	StageAwardConfig = {};	--阶段奖励表
	ExchangeInfoConfig = {};	--兑换表
	TicketId = 1702041,	--夺标券物品id
	SnatchTicket = {1, 10}, --夺宝需要的券数量
	SnatchUC = {60, 540}, --夺宝需要的UC
	TotalSnatchTimes = 0, --总夺宝次数
	StageAwardStageCondition = {}, --阶段奖励领取状态
	StartTime = 0, --开始时间
	EndTime = 0, --结束时间
	ExchangConditon = {},	--当前兑换次数
	DropList = {},	--掉落
	IsShowAniamtion = true;
	DebrisID = 1702035,	--夺宝碎片物品id
	IsJumpToExchange = false;
}

local function HandleErrorCode(errorCode)
	if errorCode == "ok" then
		return true
	elseif errorCode == "not-open" then
		ShowNotice(9940015);
	elseif errorCode == "invalid-param" then
		ShowNotice(9940010);
	elseif errorCode == "uc-not-enough" then
		ShowNotice(9940011);
	elseif errorCode == "pay-failed" then
		ShowNotice(9940012);
	elseif errorCode == "status-invalid" then
		ShowNotice(9940013);
	elseif errorCode == "times-limit" then
		ShowNotice(9940014);
	elseif errorCode == "not-enough" then
		ShowNotice(9940016);
	elseif errorCode == "has-ended" then
		ShowNotice(4002);
	end
	return false;
end

local function SetConfig(serverConfig)
	local costInfo = serverConfig.show_info.draw_cost_info;
	AnniversaryActivitySystem.SnatchUC = {costInfo[1].cost_num, costInfo[2].cost_num};
	AnniversaryActivitySystem.SnatchTicket = {costInfo[3].cost_num, costInfo[4].cost_num};
	AnniversaryActivitySystem.TicketId = costInfo[3].cost_id;
	AnniversaryActivitySystem.StartTime = serverConfig.show_info.start_time;
	AnniversaryActivitySystem.EndTime = serverConfig.show_info.end_time;
	AnniversaryActivitySystem.StageAwardConfig = serverConfig.show_info.stage_award;
	AnniversaryActivitySystem.ExchangeInfoConfig = serverConfig.show_info.exchange_info;
	--AnniversaryActivitySystem.ExchangeInfoConfig = tempConfig;
	AnniversaryActivitySystem.StageAwardStageCondition = serverConfig.stage_award;
	AnniversaryActivitySystem.TotalSnatchTimes = serverConfig.total_draw_times;
	AnniversaryActivitySystem.ExchangConditon = serverConfig.exchanged;
	AnniversaryActivitySystem.DropItemConfig = {}
	for i,v in ipairs(serverConfig.show_info.drop_items) do
		table.insert(AnniversaryActivitySystem.DropItemConfig, {itemId = v.id, itemCount = v.num, index = i})
	end
end

function AnniversaryActivitySystem.ShowItemGetPanel()
	if AnniversaryActivitySystem.DropList == nil then
		return;
	end
	
	local result = {}
	for i, index in ipairs(AnniversaryActivitySystem.DropList) do
		local item = AnniversaryActivitySystem.DropItemConfig[index];
		table.insert(result, {res_id = item.itemId, count = item.itemCount, valid_hours = 0})
	end
	log_tree("ShowItemGetPanel : ", result);
	CommonItemGetUI:ShowPanel(result);
	AnniversaryActivitySystem.DropList = nil;
end

function AnniversaryActivitySystem.GetTicketCount()
	log("Ticket ID : " .. AnniversaryActivitySystem.TicketId)
	local itemData = DataMgr.GetHallDepotItemDataByResID(AnniversaryActivitySystem.TicketId);
	if (itemData ~= nil) then
		return itemData.count;
	end
	return 0
end

function AnniversaryActivitySystem.GetDebrisItemCount()
	log("Debris ID : " .. AnniversaryActivitySystem.DebrisID)
	local itemData = DataMgr.GetHallDepotItemDataByResID(AnniversaryActivitySystem.DebrisID);
	if (itemData ~= nil) then
		return itemData.count;
	end
	return 0
end

function AnniversaryActivitySystem.OpenMainUI(isExchange)
	local ui_manager = require("ui.manager");
	if ui_manager then
		AchievementFloatTipUI.BlockingPop = true;
		if isExchange == true then
			ui_manager.ShowUI(ui_manager.UI_Config.anniversary_exchangeStore)
		else
			ui_manager.ShowUI(ui_manager.UI_Config.anniversary_activity)
		end
	end
end

function AnniversaryActivitySystem.CloseMainUI()
	local ui_manager = require("ui.manager");
	if ui_manager then
		ui_manager.CloseUI(ui_manager.UI_Config.anniversary_activity)
		AchievementFloatTipUI.BlockingPop = false;
	end
end

function AnniversaryActivitySystem.OpenExchangeStore()
	local timeStemp = FuncUtil.GetServerTimeInSec();
	log("Current Time is : " .. tostring(timeStemp));
	if timeStemp >= AnniversaryActivitySystem.EndTime then
		ShowNotice(4002);
		return;
	end
	local ui_manager = require("ui.manager");
	if ui_manager then
		AchievementFloatTipUI.BlockingPop = true;
		ui_manager.ShowUI(ui_manager.UI_Config.anniversary_exchangeStore)
	end
end

function AnniversaryActivitySystem.CloseExchangeStore()
	local ui_manager = require("ui.manager");
	if ui_manager then
		ui_manager.CloseUI(ui_manager.UI_Config.anniversary_exchangeStore);
		if AnniversaryActivitySystem.IsJumpToExchange then
			AchievementFloatTipUI.BlockingPop = false;
		end
		AnniversaryActivitySystem.IsJumpToExchange = false;
	end
end

function AnniversaryActivitySystem.OpenPopNotice()
	local ui_manager = require("ui.manager");
	if ui_manager then
		ui_manager.ShowUI(ui_manager.UI_Config.anniversary_popnotice);
	end
end

function AnniversaryActivitySystem.ClosePopNotice()
	local ui_manager = require("ui.manager");
	if ui_manager then
		ui_manager.CloseUI(ui_manager.UI_Config.anniversary_popnotice)
	end
end

function AnniversaryActivitySystem.OpenRewardBox(id)
	AnniversaryActivitySystem.CurrentRewardBoxId = id;
	local ui_manager = require("ui.manager");
	if ui_manager then
		ui_manager.ShowUI(ui_manager.UI_Config.anniversary_rewardBox, id)
	end
end

function AnniversaryActivitySystem.CloseRewardBox()
	local ui_manager = require("ui.manager");
	if ui_manager then
		ui_manager.CloseUI(ui_manager.UI_Config.anniversary_rewardBox)
	end
end

function AnniversaryActivitySystem.OpenExchangeConfirm(id)
	local ui_manager = require("ui.manager");
	if ui_manager then
		ui_manager.ShowUI(ui_manager.UI_Config.anniversary_exchangeConfirm, id);
	end
end

function AnniversaryActivitySystem.CloseExchangeConfirm()
	local ui_manager = require("ui.manager");
	if ui_manager then
		ui_manager.CloseUI(ui_manager.UI_Config.anniversary_exchangeConfirm)
	end
end

function AnniversaryActivitySystem.OpenCheckMessageBox(callback, title, content)
	local ui_manager = require("ui.manager");
	if ui_manager then
		local ui = ui_manager.ShowUI(ui_manager.UI_Config.anniversary_messageBox, callback, title, content)
	end
end

function AnniversaryActivitySystem.CloseCheckMessageBox()
	local ui_manager = require("ui.manager");
	if ui_manager then
		ui_manager.CloseUI(ui_manager.UI_Config.anniversary_messageBox)
	end
end

function AnniversaryActivitySystem.JumpToExchangeStore()
	AnniversaryActivitySystem.IsJumpToExchange = true;
	AnniversaryActivitySystem.get_anniversary_activity_info_req();
end

function AnniversaryActivitySystem.JumpToMainPanel()
	AnniversaryActivitySystem.IsJumpToExchange = false;
	AnniversaryActivitySystem.get_anniversary_activity_info_req();
end


function AnniversaryActivitySystem.GetItemName(resID)
	local itemData = Client.GetTableData("Item",resID);
	if itemData then
		return itemData.item_name;
	end
	return "";
end

function AnniversaryActivitySystem.GetActivityTime()
	log("AnniversaryActivitySystem.StartTime: " .. AnniversaryActivitySystem.StartTime);
	log("AnniversaryActivitySystem.EndTime" .. AnniversaryActivitySystem.EndTime);
	return AnniversaryActivitySystem.StartTime, AnniversaryActivitySystem.EndTime
end

function AnniversaryActivitySystem.IsShowRedPoint()
	return not LobbyUI.HasClickAnniversary();
end

function AnniversaryActivitySystem.UpdateShowRedPoint()
	LobbyUI:LobbyRedPointUpdate(BP_ENUM_MODULE_ANNIVERSARY, AnniversaryActivitySystem.IsShowRedPoint());
end

---------------------------------------------协议---------------------------------------------
--LogNula: LuaLog:     ├─ total_draw_times: 0
--LogNula: LuaLog:     ├─ exchanged: { }
--LogNula: LuaLog:     ├─ show_info
--LogNula: LuaLog:     │  ├─ drop_items
--LogNula: LuaLog:     │  │  ├─ 1
--LogNula: LuaLog:     │  │  │  ├─ num: 2
--LogNula: LuaLog:     │  │  │  ├─ expire: 0
--LogNula: LuaLog:     │  │  │  └─ id: 1532022
--LogNula: LuaLog:     │  │  ├─ 2
--LogNula: LuaLog:     │  │  │  ├─ num: 1
--LogNula: LuaLog:     │  │  │  ├─ expire: 0
--LogNula: LuaLog:     │  │  │  └─ id: 1101004040
--LogNula: LuaLog:     │  │  ├─ 3
--LogNula: LuaLog:     │  │  │  ├─ num: 1
--LogNula: LuaLog:     │  │  │  ├─ expire: 0
--LogNula: LuaLog:     │  │  │  └─ id: 2601002
--LogNula: LuaLog:     │  │  ├─ 4
--LogNula: LuaLog:     │  │  │  ├─ num: 1
--LogNula: LuaLog:     │  │  │  ├─ expire: 0
--LogNula: LuaLog:     │  │  │  └─ id: 404008
--LogNula: LuaLog:     │  │  ├─ 5
--LogNula: LuaLog:     │  │  │  ├─ num: 1
--LogNula: LuaLog:     │  │  │  ├─ expire: 0
--LogNula: LuaLog:     │  │  │  └─ id: 1405023
--LogNula: LuaLog:     │  │  ├─ 6
--LogNula: LuaLog:     │  │  │  ├─ num: 2
--LogNula: LuaLog:     │  │  │  ├─ expire: 0
--LogNula: LuaLog:     │  │  │  └─ id: 1532021
--LogNula: LuaLog:     │  │  ├─ 7
--LogNula: LuaLog:     │  │  │  ├─ num: 1
--LogNula: LuaLog:     │  │  │  ├─ expire: 0
--LogNula: LuaLog:     │  │  │  └─ id: 1400750
--LogNula: LuaLog:     │  │  ├─ 8
--LogNula: LuaLog:     │  │  │  ├─ num: 1
--LogNula: LuaLog:     │  │  │  ├─ expire: 0
--LogNula: LuaLog:     │  │  │  └─ id: 402021
--LogNula: LuaLog:     │  │  ├─ 9
--LogNula: LuaLog:     │  │  │  ├─ num: 1
--LogNula: LuaLog:     │  │  │  ├─ expire: 0
--LogNula: LuaLog:     │  │  │  └─ id: 405006
--LogNula: LuaLog:     │  │  └─ 10
--LogNula: LuaLog:     │  │     ├─ num: 1
--LogNula: LuaLog:     │  │     ├─ expire: 0
--LogNula: LuaLog:     │  │     └─ id: 2601001
--LogNula: LuaLog:     │  ├─ stage_award
--LogNula: LuaLog:     │  │  ├─ 1
--LogNula: LuaLog:     │  │  │  ├─ cond: 25
--LogNula: LuaLog:     │  │  │  └─ award
--LogNula: LuaLog:     │  │  │     ├─ 1
--LogNula: LuaLog:     │  │  │     │  ├─ id: 1532021
--LogNula: LuaLog:     │  │  │     │  └─ num: 5
--LogNula: LuaLog:     │  │  │     └─ 2
--LogNula: LuaLog:     │  │  │        ├─ id: 1000
--LogNula: LuaLog:     │  │  │        └─ num: 1000
--LogNula: LuaLog:     │  │  ├─ 2
--LogNula: LuaLog:     │  │  │  ├─ cond: 50
--LogNula: LuaLog:     │  │  │  └─ award
--LogNula: LuaLog:     │  │  │     ├─ 1
--LogNula: LuaLog:     │  │  │     │  ├─ id: 1532002
--LogNula: LuaLog:     │  │  │     │  └─ num: 1
--LogNula: LuaLog:     │  │  │     └─ 2
--LogNula: LuaLog:     │  │  │        ├─ id: 1532001
--LogNula: LuaLog:     │  │  │        └─ num: 1
--LogNula: LuaLog:     │  │  ├─ 3
--LogNula: LuaLog:     │  │  │  ├─ cond: 120
--LogNula: LuaLog:     │  │  │  └─ award
--LogNula: LuaLog:     │  │  │     └─ 1
--LogNula: LuaLog:     │  │  │        ├─ id: 1101004040
--LogNula: LuaLog:     │  │  │        └─ num: 1
--LogNula: LuaLog:     │  │  ├─ 4
--LogNula: LuaLog:     │  │  │  ├─ cond: 250
--LogNula: LuaLog:     │  │  │  └─ award
--LogNula: LuaLog:     │  │  │     ├─ 1
--LogNula: LuaLog:     │  │  │     │  ├─ id: 1532002
--LogNula: LuaLog:     │  │  │     │  └─ num: 4
--LogNula: LuaLog:     │  │  │     └─ 2
--LogNula: LuaLog:     │  │  │        ├─ id: 1001
--LogNula: LuaLog:     │  │  │        └─ num: 50
--LogNula: LuaLog:     │  │  └─ 5
--LogNula: LuaLog:     │  │     ├─ cond: 500
--LogNula: LuaLog:     │  │     └─ award
--LogNula: LuaLog:     │  │        └─ 1
--LogNula: LuaLog:     │  │           ├─ id: 1101003041
--LogNula: LuaLog:     │  │           └─ num: 1
--LogNula: LuaLog:     │  ├─ exchange_info
--LogNula: LuaLog:     │  │  └─ 1
--LogNula: LuaLog:     │  │     ├─ limit_times: 1
--LogNula: LuaLog:     │  │     ├─ cost_num: 400
--LogNula: LuaLog:     │  │     ├─ cost_id: 400023
--LogNula: LuaLog:     │  │     └─ exchange
--LogNula: LuaLog:     │  │        └─ 1
--LogNula: LuaLog:     │  │           ├─ num: 1
--LogNula: LuaLog:     │  │           ├─ expire: 0
--LogNula: LuaLog:     │  │           └─ id: 100
--LogNula: LuaLog:     │  ├─ end_time: 1553644799
--LogNula: LuaLog:     │  ├─ start_time: 1545012000
--LogNula: LuaLog:     │  └─ draw_cost_info
--LogNula: LuaLog:     │     ├─ 1
--LogNula: LuaLog:     │     │  ├─ cost_num: 60
--LogNula: LuaLog:     │     │  ├─ cost_id: 1006
--LogNula: LuaLog:     │     │  └─ draw_times: 1
--LogNula: LuaLog:     │     ├─ 2
--LogNula: LuaLog:     │     │  ├─ cost_num: 270
--LogNula: LuaLog:     │     │  ├─ cost_id: 1006
--LogNula: LuaLog:     │     │  └─ draw_times: 5
--LogNula: LuaLog:     │     ├─ 3
--LogNula: LuaLog:     │     │  ├─ cost_num: 6
--LogNula: LuaLog:     │     │  ├─ cost_id: 1602041
--LogNula: LuaLog:     │     │  └─ draw_times: 1
--LogNula: LuaLog:     │     └─ 4
--LogNula: LuaLog:     │        ├─ cost_num: 30
--LogNula: LuaLog:     │        ├─ cost_id: 1602041
--LogNula: LuaLog:     │        └─ draw_times: 5
--LogNula: LuaLog:     └─ stage_award
--LogNula: LuaLog:        ├─ 1: 0
--LogNula: LuaLog:        ├─ 2: 0
--LogNula: LuaLog:        ├─ 3: 0
--LogNula: LuaLog:        ├─ 4: 0
--LogNula: LuaLog:        └─ 5: 0
function AnniversaryActivitySystem.get_anniversary_activity_info_rsp(rs, result)
	log("get_anniversary_activity_info_rsp.rs:" .. rs)
	log_tree("LogicIceLuckyGem.result,get_anniversary_activity_info_rsp:",result)
	if HandleErrorCode(rs) then
		SetConfig(result)
		AnniversaryActivitySystem.OpenMainUI(AnniversaryActivitySystem.IsJumpToExchange);
	end
end


function AnniversaryActivitySystem.anniversary_activity_have_draw_rsp(rs, drawInfo)
	log("anniversary_activity_have_draw_rsp rs:  " .. rs)

	log_tree("anniversary_activity_have_draw_rsp:" , drawInfo)
	
	if rs ~= "ok" then
		if rs == "uc-not-enough" then
			-- 打开充值界面
			local title = Client.GetTableData("LocalizeRes", "101001").TextValue;
			local tip = Client.GetTableData("LocalizeRes", "4119").TextValue;
			CommonMessageBoxUI:ShowPanel(2, title, tip, function()
					RechargeUI:Init();
					--IceLuckyGemUI.HideUI(false)
				return true;
			end);
		else
			HandleErrorCode(rs)
		end
		log("LogicIceLuckyGem.have_draw_rsp not ok")
		return
	end

	--AnniversaryActivitySystem.ShowItemGetPanel();
	
	AnniversaryActivitySystem.DropList = drawInfo.droped_list;
	
	AnniversaryActivitySystem.StageAwardStageCondition = drawInfo.stage_award;
	
	AnniversaryActivitySystem.TotalSnatchTimes = drawInfo.total_draw_times;
	
	EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_ANNIVERSARY_COST_CHANGE);

	if #AnniversaryActivitySystem.DropList > 1 then
		EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_ANNIVERSARY_DARW_TEN_ANIMATION);
	else
		EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_ANNIVERSARY_DARW_ONE_ANIMATION);
	end
	
end


function AnniversaryActivitySystem.take_award_of_anniversary_stage_award_rsp(rs, data)
    log_tree("AnniversaryActivitySystem.take_award_of_anniversary_stage_award_rsp ,item_list:",data)
	if not HandleErrorCode(rs) then
		return;
	end
	--显示获奖结果
    local Result = {}
    for i,v in ipairs(data.award) do
        table.insert(Result, {res_id = v.resid, count = v.count, valid_hours = v.itemExpireTime})
    end
    CommonItemGetUI:ShowPanel(Result);
	
	AnniversaryActivitySystem.StageAwardStageCondition = data.stage_award;
	
	EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_ANNIVERSARY_DRAW_STAGE_AWARD);
	
	AnniversaryActivitySystem.CloseRewardBox();
end

function AnniversaryActivitySystem.take_exchange_of_anniversary_activity_rsp(rs, list, exchanged)
	log("take_exchange_of_anniversary_activity_rsp.rs" .. rs)
	log_tree("take_exchange_of_anniversary_activity_rsp.droped_item_list", list);
	log_tree("take_exchange_of_anniversary_activity_rsp.exchanged", exchanged);
	if not HandleErrorCode(rs) then
		return;
	end
	--显示获奖结果
	local Result = {}
	for i,v in ipairs(list.drop_list) do
		table.insert(Result, {res_id = v.resid, count = v.count, valid_hours = v.valid_hours})
	end
	
	AnniversaryActivitySystem.ExchangConditon = list.exchanged;
	CommonItemGetUI:ShowPanel(Result);
	AnniversaryActivitySystem.CloseExchangeConfirm();
	
	
	EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_ANNIVERSARY_EXCHANGE);
end

--请求周年庆活动配置数据
function AnniversaryActivitySystem.get_anniversary_activity_info_req()
    log("AnniversaryActivitySystem.get_anniversary_activity_info_req")
    NetUtil.SendPriorityPkg(false, "get_anniversary_activity_info_rsp", "get_anniversary_activity_info_req");
end

--请求抽奖 1-uc单抽，2-uc五连抽, 3-道具单抽，4-道具五连抽
function AnniversaryActivitySystem.anniversary_activity_have_draw_req(draw_type)
	log("draw_type:" .. draw_type)
	NetUtil.SendPriorityPkg(false, "anniversary_activity_have_draw_rsp", "anniversary_activity_have_draw_req", draw_type);
end

--请求领取累计次数奖励
function AnniversaryActivitySystem.take_award_of_anniversary_stage_award_req(award_id)
    log("AnniversaryActivitySystem.take_award_of_stage_award_req:" .. award_id);
  	NetUtil.SendPriorityPkg(false, "take_award_of_anniversary_stage_award_rsp", "take_award_of_anniversary_stage_award_req", award_id);
end

--请求兑换
function AnniversaryActivitySystem.take_exchange_of_anniversary_activity_req(id, times)
	NetUtil.SendPriorityPkg(false, "take_exchange_of_anniversary_activity_rsp", "take_exchange_of_anniversary_activity_req", id, times);
end

return AnniversaryActivitySystem