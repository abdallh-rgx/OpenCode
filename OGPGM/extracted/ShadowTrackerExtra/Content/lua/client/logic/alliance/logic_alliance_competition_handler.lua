--[[
    战队赛服务端交互相关逻辑
]]

AllianceCompetitionSystemHandler = AllianceCompetitionSystemHandler or {}

-- 请求修改队旗
function AllianceCompetitionSystemHandler.ChangeGuidonReq(id)
    log("AllianceCompetitionSystemHandler.ChangeGuidonReq id "..id)
    NetUtil.SendPkg("set_car_team_flag_req",id)
end

-- 请求修改队旗回调
function AllianceCompetitionSystemHandler.set_car_team_flag_rsp(retCode, id)
    log("set_car_team_flag_rsp "..retCode.." id "..id)
    if retCode ~= 0 then
        DataMgr.ShowNoticeByID(retCode)
        return
    end

    AllianceCompetitionSystem.GuidonId = id
    AllianceUI:RefreshTeamMainPanel()
    LuaClassObj.HandleUIMessage(bp_countryarea, "UIHide")
end

-- 请求修改国旗
function AllianceCompetitionSystemHandler.ChangeNationReq(id)
    NetUtil.SendPkg("set_car_team_nation_flag_req",id)
end

-- 请求修改国旗回调
function AllianceCompetitionSystemHandler.set_car_team_nation_flag_rsp(retCode, id)
    log("set_car_team_nation_flag_rsp "..retCode.." id "..id)
    if retCode ~= 0 then
        DataMgr.ShowNoticeByID(retCode)
        return
    end

    AllianceCompetitionSystem.NationFlagId = id
    AllianceUI:RefreshTeamMainPanel()
    LuaClassObj.HandleUIMessage(bp_countryarea, "UIHide")
end

-- 商店列表请求
function AllianceCompetitionSystemHandler.ShaopItemsReq()
    NetUtil.SendPkg("carteam_coin_exchange_list_req")
end

-- 商店列表响应
function AllianceCompetitionSystemHandler.carteam_coin_exchange_list_rsp(retCode, items, limit)
    if retCode ~= 0 then
        DataMgr.ShowNoticeByID(retCode)
        return
    end

    --log_tree("items",items)
    --log_tree("limit",limit)
--     LogNula: LuaLog: ├─ 103
-- LogNula: LuaLog: │  ├─ sort: 3
-- LogNula: LuaLog: │  ├─ item_id: 1400101
-- LogNula: LuaLog: │  ├─ cost_score: 720
-- LogNula: LuaLog: │  ├─ item_show_type: 1
-- LogNula: LuaLog: │  ├─ season_index: 1
-- LogNula: LuaLog: │  ├─ item_expire_time: 0
-- LogNula: LuaLog: │  ├─ limit: 1
-- LogNula: LuaLog: │  └─ item_num: 1

    -- BP_AllianceCompetition_operateShopId = 0

    AllianceCompetitionSystem.log("carteam_coin_exchange_list_rsp")
    BP_ARRAY_AllianceCompetition_ShopItemInfoList = {}
    if items then
        for exchangeId,v in pairs(items) do
            local itemLimit = limit[exchangeId]
            local item = {}
            item.exchangeId = exchangeId
            item.costScore = v.cost_score
            if itemLimit == nil then
                item.curCount = 0
            else
                item.curCount = itemLimit.buy_count
            end

            item.maxCount = v.limit
            item.sort = v.sort
            item.itemId = v.item_id

            table.insert( BP_ARRAY_AllianceCompetition_ShopItemInfoList, item)
        end

        table.sort( BP_ARRAY_AllianceCompetition_ShopItemInfoList, function(a,b)
            if a.sort == b.sort then
                return a.itemId > b.itemId
            end

            return a.sort < b.sort
        end )
    end
    AllianceCompetitionShopUI:UpdateShopItems()
end

-- 请求购买商品
function AllianceCompetitionSystemHandler.carteam_coin_exchange_req(exchangeId, item_count, cur_buy_count)
    log("carteam_coin_exchange_req "..exchangeId.." item_count "..item_count.." cur_buy_count "..cur_buy_count)
    NetUtil.SendPkg("carteam_coin_exchange_req", exchangeId, item_count, cur_buy_count)
end

-- 请求购买商品响应
function AllianceCompetitionSystemHandler.carteam_coin_exchange_rsp(res, id, reward_list, new_buy_count)
    log("carteam_coin_exchange_rsp res"..res)
    if res ~= 0 then
        DataMgr.ShowNoticeByID(res)

    else
        local Result = {}
        for i,v in ipairs(reward_list) do
            table.insert(Result, {res_id = v.item_id, count = v.item_num, valid_hours = 0})
        end
        CommonItemGetUI:ShowPanel(Result)

        AllianceCompetitionSystemHandler.ShaopItemsReq()
    end
end

-- 请求房间请求
function AllianceCompetitionSystemHandler.participate_competition()
    NetUtil.SendPkg("participate_competition_req")
end

-- 请求进入房间响应
function AllianceCompetitionSystemHandler.participate_competition_rsp(retCode)
    if retCode ~= 0 then
        DataMgr.ShowNoticeByID(retCode)
        return
    end

	AllianceCompetitionRoomUI.Show()
	-- 不管如何，先请求一遍
    --63675347优化注释
	--TeamUpSystem.team_info_request()
end

-- 退出房间请求
function AllianceCompetitionSystemHandler.reqQuickRoom()
	TeamUpSystem.team_quit_request(TeamUpSystem.TeamInfo.id)
end

-- 退出房间响应
function AllianceCompetitionSystemHandler.rspQuickRoom()
	AllianceCompetitionRoomUI.Hide()
end

-- 请求历史战绩
-- AllianceCompetitionSystemHandler.lastScoreReqTiem = 0
-- AllianceCompetitionSystemHandler.lastScoreReqTiemMaxCD = 300
-- AllianceCompetitionSystemHandler.lastScoreReqTiemMinCD = 1

-- AllianceCompetitionSystemHandler.lastScoreReqTiemNeedCD = AllianceCompetitionSystemHandler.lastScoreReqTiemMaxCD
function AllianceCompetitionSystemHandler.league_battle_history_req()
    -- local curTime = os.time()
    -- local difftime = curTime - AllianceCompetitionSystemHandler.lastScoreReqTiem
    -- if difftime < AllianceCompetitionSystemHandler.lastScoreReqTiemNeedCD then
    --     return
    -- end

    -- AllianceCompetitionSystemHandler.lastScoreReqTiem = curTime
    NetUtil.SendPkg("league_battle_history_req")
end

-- -- 战绩信息
-- BP_STRUCT_Alliance_Competition_Record_Info = {
--     IsWinner = true,
--     StageStr = "小组赛1",
--     TeamStr = "第一组",
--     RoundStr = "第一轮",
--     RankStr = "1",
--     killStr = "60",
--     Score = "200",
--     Evaluate = "SSS",
-- }
function AllianceCompetitionSystemHandler.league_battle_history_rsp(errcode, records)
    AllianceCompetitionSystem.log("league_battle_history_rsp errcode "..tostring(errcode))

    if errcode == 505034 then
        -- AllianceCompetitionSystemHandler.lastScoreReqTiemNeedCD = AllianceCompetitionSystemHandler.lastScoreReqTiemMinCD
        -- AllianceCompetitionSystem.log("set lastScoreReqTiemNeedCD "..AllianceCompetitionSystemHandler.lastScoreReqTiemNeedCD)
        return
    end

    -- AllianceCompetitionSystemHandler.lastScoreReqTiemNeedCD = AllianceCompetitionSystemHandler.lastScoreReqTiemMaxCD
    -- AllianceCompetitionSystem.log("set lastScoreReqTiemNeedCD "..AllianceCompetitionSystemHandler.lastScoreReqTiemNeedCD)

    AllianceCompetitionSystem.records = records
    BP_ARRAY_Alliance_Competition_Record_Info_List = {}

    for i,record in ipairs(records) do
    	local data = {}
        data.battle_id = i
    	data.IsWinner = (tonumber(record.team_rank) == 1)
    	data.StageStr = AllianceCompetitionSystem.getStageName(record.league_stage)
    	data.TeamStr = AllianceCompetitionSystem.getTeamName(record.league_group).." "..AllianceCompetitionSystem.getRoundName(record.league_round)
    	
        -- 时间
        data.RoundStr = os.date("%m-%d %H:%M",record.time)
    	data.RankStr = "#"..tostring(record.team_rank) --todo

    	local killCount = 0
    	for i,v in ipairs(record.TeammateList) do
    		killCount = killCount + v.Kill
    	end
    	data.killStr = tostring(killCount)

    	data.Score = tostring(math.floor(record.league_score))
    	data.Evaluate = record.final_level

    	table.insert( BP_ARRAY_Alliance_Competition_Record_Info_List, data )
    end

    -- table.insert(BP_ARRAY_Alliance_Competition_Record_Info_List, BP_STRUCT_Alliance_Competition_Record_Info)

    AllianceCompetitionSystem.log("league_battle_history_rsp BP_ARRAY_Alliance_Competition_Record_Info_List "..tostring(#BP_ARRAY_Alliance_Competition_Record_Info_List))
    
    if AllianceUI.isShowing == true then
		AllianceUI:UpdateRecords()
	end
end

--请求进入小组赛房间
function AllianceCompetitionSystemHandler.EnterRoomReq()
    if AllianceCompetitionSystem.Mode > 0 and AllianceCompetitionSystem.Zone > 0 then
        log("send msg enter_league_room_req");
        local zoneId=AllianceCompetitionSystem.Zone;
        local modeId=AllianceCompetitionSystem.Mode;
        NetUtil.SendPkg("enter_league_room_req", zoneId, modeId);
    else
        log("send enter_league_room_req error: invalid league_info!!!");
    end
end
-- --[[网络回调]]--
-- 加入海选赛房间回调
s2c["participate_competition_rsp"] = AllianceCompetitionSystemHandler.participate_competition_rsp
-- 历史战绩回调
s2c["league_battle_history_rsp"] = AllianceCompetitionSystemHandler.league_battle_history_rsp
-- 修改队旗
s2c["set_car_team_flag_rsp"] = AllianceCompetitionSystemHandler.set_car_team_flag_rsp
-- 修改国旗回调
s2c["set_car_team_nation_flag_rsp"] = AllianceCompetitionSystemHandler.set_car_team_nation_flag_rsp
-- 商店列表响应
s2c["carteam_coin_exchange_list_rsp"] = AllianceCompetitionSystemHandler.carteam_coin_exchange_list_rsp
-- 购买响应
s2c["carteam_coin_exchange_rsp"] = AllianceCompetitionSystemHandler.carteam_coin_exchange_rsp