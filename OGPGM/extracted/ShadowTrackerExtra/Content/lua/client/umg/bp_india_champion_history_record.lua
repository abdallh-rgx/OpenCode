-- 线上锦标赛历史战绩ui
IndiaCompetitionHistoryRecordUI = IndiaCompetitionHistoryRecordUI or {
    isShowing = false;
}

--历史战绩的数据结构
BP_STRUCT_IndiaCompition_Record_Info =
{
    id = 0,
    time = "",
    level = "10UC",
    rank = 0,
    kill = 0,
    score = 0,
};

-- 奖励列表
BP_ARRAY_IndiaCompition_Record_List =
{
    BP_STRUCT_IndiaCompition_Record_Info = _G.BP_STRUCT_IndiaCompition_Record_Info, 
};

--注册Widget
function bp_india_champion_history_record_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_india_champion_history_record,
            {{Path="/Game/UMG/UI_Logic/ChampionshipIndia/Championship_India_History_LogicBP.Championship_India_History_LogicBP_C", Container="Default", ZOrder=16}},
            {"Lobby"},
            false,
            false,
            true
    );
end

function IndiaCompetitionHistoryRecordUI.Show()
    log("IndiaCompetitionHistoryRecordUI.Init")    
    BP_ARRAY_IndiaCompition_Record_List = {};
    LuaClassObj.HandleDynamicCreation(bp_india_champion_history_record);
    LuaClassObj.HandleUIMessage(bp_india_champion_history_record, "UIShow");
    UIManager.Show(eUIType.eIndiaChampionShipHistoryRecord);
    IndiaChampionShipLogic.tournament_info_req()
    EventSystem:registEvent(EVENTTYPE_INDIA_COMPETITION, EVENTID_INDIA_CHAMPIONSHIP_HISTORY_RECORD_UPDATE, IndiaCompetitionHistoryRecordUI.RefreshData);
    IndiaCompetitionHistoryRecordUI.isShowing = true;
end

-- 隐藏
function IndiaCompetitionHistoryRecordUI.Hide()
    LuaClassObj.HandleUIMessageNoFetch(bp_india_champion_history_record, "UIHide");
    EventSystem:unregistEvent(EVENTTYPE_INDIA_COMPETITION, EVENTID_INDIA_CHAMPIONSHIP_HISTORY_RECORD_UPDATE, IndiaCompetitionHistoryRecordUI.RefreshData);
    IndiaCompetitionHistoryRecordUI.isShowing = false;
end

-- 刷新数据，显示状态才刷新
function IndiaCompetitionHistoryRecordUI.RefreshData(eventType, eventID, tournamentsInfo)
    if IndiaCompetitionHistoryRecordUI.isShowing then
        BP_ARRAY_IndiaCompition_Record_List = {};
        local tempRecordList = {};
        if tournamentsInfo and tournamentsInfo.history_result then
            for id, datas in pairs(tournamentsInfo.history_result) do
                for i,data in pairs(datas) do
                    table.insert(tempRecordList, data);
                end
            end

            if #tempRecordList > 0 then
                table.sort(tempRecordList,
                function(a,b)
                    return a.time > b.time;
                end);
                for index, record in pairs(tempRecordList) do
                    local record_data = {};
                    record_data.time = os.date("%m-%d %H:%M", record.time);
                    record_data.rank = record.rank;
                    record_data.score = record.score;
                    record_data.kill = record.kill;
                    record_data.level = FuncUtil.LocalizeResFormat(6610, record.level or 10);
                    table.insert(BP_ARRAY_IndiaCompition_Record_List, record_data);
                end
                LuaClassObj.HandleUIMessage(bp_india_champion_history_record, "UpdateData");
            end
        end
    end
end

-- 测试数据
function IndiaCompetitionHistoryRecordUI.CreateTestData()
    BP_ARRAY_IndiaCompition_Record_List = {};
    for i= 1,10 do
        local record_data = {};
        record_data.level = "10UC";
        record_data.time = os.date("%m-%d %H:%M",1546512364 + i * 1067);
        record_data.rank = i+2;
        record_data.score = 125;
        record_data.kill = 5;
        table.insert(BP_ARRAY_IndiaCompition_Record_List, record_data);
    end 
end
