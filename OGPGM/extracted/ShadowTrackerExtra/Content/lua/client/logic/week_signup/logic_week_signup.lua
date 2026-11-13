WeekSignUpSystem = WeekSignUpSystem or
{
    day_amount = 7, --7天的数据

    -- 预定义状态
    status_notfinish = 0; --未完成
    status_notaward = 1; --未领取
    status_awarded = 2; --已领取
    status_resignup = 3;    -- 补签

    LastWeek = 0;
    TableData = nil;
    WeekSignUpTable = {};
    WeekReSignTable = {};
    Resource_StartTime = 0;
    Resource_EndTime = 0;
}

function WeekSignUpSystem.week_signup_award_res(res, day, itemList, resign_time)
    log("[HHF]WeekSignUpSystem.week_signup_award_res, received week_signup_award_res, res = " .. tostring(res) .. ", day = " .. tostring(day));

    -- body
    if res ~= nil and string.lower(res) == "ok" then
        DataMgr.UpdateWeekSignUpInfo(day, WeekSignUpSystem.status_awarded);
        
        DataMgr.WeekSignUpInfo.Resign_times = resign_time

        --log_tree(string.format("-- day[%d] itemList:", day), itemList);
        EventSystem:postEvent(EVENTTYPE_WEEK_SIGNUP, EVENTID_WEEK_SIGNUP_AWARD_RESULT, {isSuccessed = true, dropList = itemList});
        WeekSignUpSystem.PostUpdateStatus();
    else
        if res ~= nil then
            DataMgr.ShowMessageBoxByID(res);
        end
        EventSystem:postEvent(EVENTTYPE_WEEK_SIGNUP, EVENTID_WEEK_SIGNUP_AWARD_RESULT, {isSuccessed = false}); 
    end 
end

function WeekSignUpSystem.week_signup_chg_notify(signup)
    --log_tree("WeekSignUpSystem.week_signup_chg_notify :", signup);
    DataMgr.InitWeekSignUpList(signup);
end

function WeekSignUpSystem.PostUpdateStatus()
    -- body
    EventSystem:postEvent(EVENTTYPE_WEEK_SIGNUP, EVENTID_WEEK_SIGNUP_SYNCINFO); 
end

function WeekSignUpSystem.SendWeekSignUpReq(day, gold)
    log("[HHF]WeekSignUpSystem.SendWeekSignUpRe, Send week_signup_award_req");
    NetUtil.SendPriorityPkg(false, "week_signup_award_res", "week_signup_award_req", day, gold);
end

function WeekSignUpSystem.GetWeekData(timeInSec)
    WeekSignUpSystem.InitTableData();

    -- log_tree(string.format("WeekSignUpSystem.GetWeekData ：%d %d", timeInSec, WeekSignUpSystem.LastWeek), WeekSignUpSystem.TableData);
    -- log("WeekSignUpSystem.GetWeekData :"..os.date("%x", timeInSec));

    if timeInSec > WeekSignUpSystem.LastWeek then
        return WeekSignUpSystem.TableData[WeekSignUpSystem.LastWeek];
    end

    local result = WeekSignUpSystem.TableData[timeInSec];
    if result == nil then
        sandbox.LogError("WeekSignUpSystem.TableData[timeInSec] == nil");
        return nil;
    end

    return result;
end

function WeekSignUpSystem.GetSignUpAwardTable()
    local region = Client.GetPublishRegion();
    if WeekSignUpSystem.WeekSignUpTable and next(WeekSignUpSystem.WeekSignUpTable) ~= nil then
        return WeekSignUpSystem.WeekSignUpTable
    else
        if region == "JAPAN" or region == "KOREA" then
            log("[HHF]WeekSignUpSystem.GetSignUpAwardTable, region = JK, load JKWeekSignUpTable");
            return Client.GetTable("JKWeekSignUpTable");
        else
            log("[HHF]WeekSignUpSystem.GetSignUpAwardTable, region = GL, load WeekSignUpTable");
            return Client.GetTable("WeekSignUpTable");
        end
    end
end

function WeekSignUpSystem.InitTableData()
    if WeekSignUpSystem.TableData ~= nil then
        return;
    end

    -- 初始化表格数据容器
    WeekSignUpSystem.TableData = {};
    WeekSignUpSystem.LastWeek = 0;
    local tempTable = {};
    local cfgTable = WeekSignUpSystem.GetSignUpAwardTable();
    -- log_tree("WeekSignUpSystem.InitTableData", cfgTable);
    for k,v in pairs(cfgTable) do
        tempTable[v.Date] = tempTable[v.Date] or {};
        tempTable[v.Date][v.WeekDay] = v;
    end

    -- log_tree("WeekSignUpSystem.InitTableData 1", tempTable);


    -- 转成时间后保存
    log_tree("%%%%%%%%%", tempTable)
    for k,v in pairs(tempTable) do
        local strY, strM, strD = string.match(k, "(%d+)-(%d+)-(%d+)");
        local offset = os.time() - os.time(os.date("!*t"))
        local sec = os.time({year=tonumber(strY), month=tonumber(strM), day=tonumber(strD), hour = 0, min = 0, sec = 0})
        local isDst = os.date("*t", sec).isdst
        sec = sec + offset
        if isDst and isDst == true then
            sec = sec + 3600
        end
        if sec < FuncUtil.GetServerTimeInSec() then
            WeekSignUpSystem.LastWeek = math.max(WeekSignUpSystem.LastWeek, sec);
        end
        WeekSignUpSystem.TableData[sec] = v;
        log(WeekSignUpSystem.LastWeek);
    end
    -- log_tree("WeekSignUpSystem.InitTableData 2", WeekSignUpSystem.TableData);
end

function WeekSignUpSystem.ResetData()
    WeekSignUpSystem.TableData = nil;
end

function WeekSignUpSystem.InitSignUpTable(WeekSignUpInfo)
    --log_tree("WeekSignUpSystem.InitSignUpTable", WeekSignUpInfo)
    WeekSignUpSystem.WeekSignUpTable = WeekSignUpInfo[1];
    WeekSignUpSystem.WeekReSignTable = WeekSignUpInfo[2];
    WeekSignUpSystem.Resource_StartTime = WeekSignUpInfo[3];
    WeekSignUpSystem.Resource_EndTime = WeekSignUpInfo[4];
end

s2c = s2c or {};
s2c["week_signup_award_res"] = WeekSignUpSystem.week_signup_award_res; 
s2c["week_signup_chg_notify"] = WeekSignUpSystem.week_signup_chg_notify;
