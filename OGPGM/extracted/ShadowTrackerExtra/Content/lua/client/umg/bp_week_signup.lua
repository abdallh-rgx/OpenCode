WeekSignUpUI = WeekSignUpUI or
{
    IsInited = false,

    StringID_Name = 430001, -- 第%d天
    StringID_Desc = 430002, -- 是否花费%d金币补签
    StringID_Resign = 430003,  -- 补签
    StringID_NotEnough = 110055, -- 补签金币不足
    StringID_OK = 110036, -- 确定

    -- CurrentSignUpDayInWeek = 0,
    StartTimeInSec = 0,
    EndTimeInSec = 0,
    IsClickButtonWeekSign = false, --打点需求
    cost = 0;
}

BP_STRUCT_WeekSignUpUI_Info =
{
    name = "",
    status = 0,
    itemName = "",
    itemImage = "",
    itemQuality = 0,
    itemResID = 0,
}

WeekSignUp_DayDescList =
{
    [1] = 6600,
    [2] = 6601,
    [3] = 6602,
    [4] = 6603,
    [5] = 6604,
    [6] = 6605,
    [7] = 6606,
}

BP_CurrentSignUpDayInWeek = 0;
BP_Week_SignUp_TimeString = "";
BP_ARRAY_Week_SignUp_Info = { BP_STRUCT_WeekSignUpUI_Info = _G.BP_STRUCT_WeekSignUpUI_Info }
BP_Request_SignUp_day = 0;
BP_Week_SignUp_Platform = 0;
BP_Week_SignUp_Startup = 0;
BP_Week_SignUp_QQVip = 0;
BP_Week_SignUp_Resource_Index = 0;

function EventFetchInfo( ... )
    -- body
end

function EventWeekSignUpReq_Push( ... )
    -- body
end

function EventWeekSignUpReq()
    ClientSendBAReport(BP_BA_WEEK_SIGN_CLICK, 0);
    local weekDay = FuncUtil.GetServerWeekDay();
    if BP_CurrentSignUpDayInWeek ~= weekDay then -- 不是同一天签到，刷新数据
        log("[HHF]EventWeekSignUpReq, C/S not in the same day, cweek = " .. tostring(BP_CurrentSignUpDayInWeek) .. ", sweek = " .. tostring(weekDay));
        OnWeekSignUpUpdated();
        return;
    end

    WeekSignUpUI.IsClickButtonWeekSign = true;

    -- 查找消耗，如果有消耗则弹窗
    WeekSignUpUI.cost = WeekSignUpUI.GetSignUpCost(BP_Request_SignUp_day);
    log("resign cost: @@@"..WeekSignUpUI.cost)
    if WeekSignUpUI.cost > 0 then
        -- 11月5号前50BP
        local CheapResignDay = math.ceil(FuncUtil.GetServerTimeInSec() / 86400);
        if CheapResignDay < 17840 then
            WeekSignUpUI.cost = 50
        end
        -- 有消耗，弹提示窗
        local resign = FuncUtil.GetLocalizeResStr("430003");
        if DataMgr.gold < WeekSignUpUI.cost then   -- 钱不够
            local msg = string.format(FuncUtil.GetLocalizeResStr(WeekSignUpUI.StringID_NotEnough), WeekSignUpUI.cost);            
            msg = string.gsub(msg, "%$%$", "\"");            
            CommonMessageBoxUI:ShowPanel(1, resign, msg);
        else
            --StringID_Desc = 430002, -- 是否花费%d金币补签
            local msg = string.format(FuncUtil.GetLocalizeResStr("430002"), WeekSignUpUI.cost);
            msg = string.gsub(msg, "%$%$", "\"");            
            CommonMessageBoxUI:ShowPanel(2, resign, msg, WeekSignUpUI.SendSignMsg);
        end
    else
        WeekSignUpUI.SendSignMsg();
    end
end

function EventWeekSignUpInit( ... )
    -- body
    log("EventWeekSignUpInit server time:"..os.date("%Y-%m-%d %H:%M:%S", FuncUtil.GetServerTimeInSec()));
    WeekSignUpUI.Init();
end

function EventWeekSignUpHide( ... )
    -- body
    WeekSignUpUI.IsClickButtonWeekSign = false;
    WeekSignUpUI.HideUI();
end

function EventWeekSignPlatform_FetchInfo()
	BP_Week_SignUp_Platform = BP_Platform;
	BP_Week_SignUp_Startup = BP_StartUpType;
	BP_Week_SignUp_QQVip = DataMgr.roleData.qq_vip;
end

function WeekSignUpUI.SendSignMsg()
    log(string.format("[HHF]WeekSignUpUI.SendSignMsg, weekDay = %d, cost = %d", BP_Request_SignUp_day, WeekSignUpUI.cost));
    WeekSignUpSystem.SendWeekSignUpReq(BP_Request_SignUp_day, WeekSignUpUI.cost);
end

function WeekSignUpUI.GetSignUpCost(day)
    local cost = 0;
    if day < BP_CurrentSignUpDayInWeek then
        if WeekSignUpSystem.WeekReSignTable and next(WeekSignUpSystem.WeekReSignTable) ~= nil then
            local strRegion = Client.GetPublishRegion();
            if strRegion == "JAPAN" or strRegion == "KOREA" then
                local data = WeekSignUpSystem.WeekReSignTable[day]
                if data ~= nil then
                    cost = data.ResignCost;
                end
            else
                local data = WeekSignUpSystem.WeekReSignTable[DataMgr.WeekSignUpInfo.Resign_times + 1]
                if data ~= nil then
                    cost = data.ResignCost;
                end
            end
        else
            local strRegion = Client.GetPublishRegion();
            if strRegion == "JAPAN" or strRegion == "KOREA" then
                local data = Client.GetTableData("JKWeekSignUpResignCost", day);
                if data ~= nil then
                    cost = data.ResignCost;
                end
            else
                local data = Client.GetTableData("WeekSignUpResignCost", DataMgr.WeekSignUpInfo.Resign_times + 1);
                if data ~= nil then
                    cost = data.ResignCost;
                end
            end
        end
    end

    -- local CheapResignDay = math.ceil(FuncUtil.GetServerTimeInSec() / 86400);
    -- if CheapResignDay < 17840 then
    --     cost = 50
    -- end

    return cost;
end

local WeekSignUpSecondsOfDay = 24*60*60;
function WeekSignUpUI.UpdateTimeString( ... )
    local curTime = FuncUtil.GetServerTimeInSec();
    local curDate = os.date("!*t", curTime);
    log("[HHF]WeekSignUpUI.UpdateTimeString, current server time = " .. os.date('!%Y-%m-%d %H:%M:%S', curTime));
    local todaySec = curDate.hour * 3600 + curDate.min * 60 + curDate.sec
    
    -- 时间设置到0点
    curDate.hour = 0;
    curDate.min = 0;
    curDate.sec = 0;

    BP_CurrentSignUpDayInWeek = FuncUtil.GetWeekDay(curDate.wday); -- 装换一下周几，lua中1代表星期天

    local timeOffset = BP_CurrentSignUpDayInWeek - 1; -- 减掉周一获取偏移量

    WeekSignUpUI.StartTimeInSec = curTime - todaySec - timeOffset * WeekSignUpSecondsOfDay;  -- 第一天的0点
    WeekSignUpUI.EndTimeInSec = WeekSignUpUI.StartTimeInSec + 7 * WeekSignUpSecondsOfDay - 1; -- 最后一天的23.59.59

    --local startTime = FuncUtil.SecToDateString(WeekSignUpUI.StartTimeInSec);
    --local endTime = FuncUtil.SecToDateString(WeekSignUpUI.EndTimeInSec);
    --local textData = Client.GetTableData("LocalizeRes", EightDayUI.StringID_DateFormat);
    --BP_Week_SignUp_TimeString = string.format(textData.TextValue, startTime, endTime);
    --BP_Week_SignUp_TimeString = os.date("%Y-%m-%d %H:%M:%S", WeekSignUpUI.EndTimeInSec);
    BP_Week_SignUp_TimeString = string.format(FuncUtil.GetLocalizeResStr("4586"), os.date("%H:%M:%S", 0));
end

function OnWeekSignUpUpdated(...)
    -- 如果不是第一次更新
    -- if BP_CurrentSignUpDayInWeek ~= 0 then
    --     local currentTime = FuncUtil.GetServerTimeInSec();

    --     if currentTime > WeekSignUpUI.EndTimeInSec then -- 超过最后一天了，刷新数据
    --         log(string.format("EventWeekSignUpReq:超过最后一天了，刷新数据 %d %d", currentTime, WeekSignUpUI.EndTimeInSec));

    --         WeekSignUpUI.ResetData();
    --         DataMgr.ResetWeekSignUpInfo();
    --         OnWeekSignUpUpdated();
    --         return;
    --     end
    -- end

    -- 刷新时间
    WeekSignUpUI.UpdateTimeString();

    -- 刷新界面状态
    local hasResign = false;
    local weekData = WeekSignUpSystem.GetWeekData(WeekSignUpUI.StartTimeInSec);
    local strRegion = Client.GetPublishRegion()
    --log_tree("OnWeekSignUpUpdated 1", weekData);
    if weekData == nil then
        return;
    end

    for i = 1, WeekSignUpSystem.day_amount do
        local newStatus = DataMgr.WeekSignUpInfo.AwardState[i];
        local resignCost = 0;
        if newStatus ~= WeekSignUpSystem.status_awarded then  -- 如果没有领取过奖励，判断一下是补签还是签到
            if i < BP_CurrentSignUpDayInWeek then
                if strRegion == "JAPAN" or strRegion == "KOREA" then
                    newStatus = WeekSignUpSystem.status_resignup;
                else
                    if hasResign then
                        newStatus = WeekSignUpSystem.status_notfinish;
                    else
                        newStatus = WeekSignUpSystem.status_resignup;
                        hasResign = true;
                    end
                end
            elseif i == BP_CurrentSignUpDayInWeek then
                newStatus = WeekSignUpSystem.status_notaward;
            elseif i > BP_CurrentSignUpDayInWeek then
                newStatus = WeekSignUpSystem.status_notfinish;
            end
        end

        local signUpCfg = weekData[i];
        BP_ARRAY_Week_SignUp_Info[i].status = newStatus;
        WeekSignUpUI.InitItemInfo(BP_ARRAY_Week_SignUp_Info[i], signUpCfg.DropID);
    end

    -- log_tree("OnWeekSignUpUpdated 2", BP_ARRAY_Week_SignUp_Info);
    LuaClassObj.HandleUIMessage(bp_week_signup, "UpdateUI");
end


function WeekSignUpUI.InitItemInfo(info, dropID)
    local drop_util = require("client.common.drop_util")
    local dropList = drop_util.GetDropList(dropID);

    if #dropList ~= 0 then
        local firstDrop = dropList[1];
        local itemInfo = Client.GetTableData("Item", firstDrop.DropItemID);
        -- log_tree("WeekSignUpUI.InitItemInfo : ", itemInfo);
        info.itemName = firstDrop.Desc;
        info.itemImage = itemInfo.ItemBigIcon;
        info.itemQuality = itemInfo.ItemQuality;
        info.itemResID = itemInfo.ItemID;
    else
        sandbox.LogError("WeekSignUpUI.InitItemInfo dropList is empty!");
    end
end

function OnWeekSignUpResult(eventType, eventID, result)
    -- body
    if result.isSuccessed then
        --log_tree("OnWeekSignUpResult", result);
        local arrayItemData = result.dropList or {}
        -- if result.dropList ~= nil then
        --     for k, v in pairs(result.dropList) do
        --         table.insert(arrayItemData, {res_id = k, count = v});
        --     end
        -- end

        if #arrayItemData == 0 then
            sandbox.LogError("OnWeekSignUpResult list empty!");
        else
            --log_tree("OnWeekSignUpResult:arrayItemData=",arrayItemData);
            CommonItemGetUI:ShowPanel(arrayItemData);
        end
    else
        OnWeekSignUpUpdated();  -- 出错了，刷新一下界面状态
    end
end

function WeekSignUpUI.ResetData()
    BP_CurrentSignUpDayInWeek = 0;
    WeekSignUpUI.StartTimeInSec = 0;
    WeekSignUpUI.EndTimeInSec = 0;
end

function WeekSignUpUI.OnJumpUrl(eventType, eventID, vars)
    log("[HHF]WeekSignUpUI.OnJumpUrl, eventType = " .. eventType .. ", eventID = " .. eventID .. ", vars = " .. tostring(vars));
    WeekSignUpUI.ShowUI();
end

function WeekSignUpUI.Init(...)
    if not WeekSignUpUI.IsInited then
        log("WeekSignUpUI.Init");

        local region = Client.GetPublishRegion();
        local data = Client.GetTableData("LocalizeRes", WeekSignUpUI.StringID_Name);
        local info = nil;
        for i = 1, WeekSignUpSystem.day_amount do
            info = FuncUtil:CopyTable(BP_STRUCT_WeekSignUpUI_Info);
            if region == "JAPAN" or region == "KOREA" then
                log("WeekSignUp_DayDescList "..WeekSignUp_DayDescList[i])
                info.name = Client.GetTableData("LocalizeRes", WeekSignUp_DayDescList[i]).TextValue;
                log("info.name "..info.name)
            else
                info.name = string.format(data.TextValue, i);
            end
            BP_ARRAY_Week_SignUp_Info[i] = info;
        end
        
        local curTimeInSec = FuncUtil.GetServerTimeInSec()
        if curTimeInSec < WeekSignUpSystem.Resource_EndTime and curTimeInSec > WeekSignUpSystem.Resource_StartTime then
            BP_Week_SignUp_Resource_Index = 1
        else
            BP_Week_SignUp_Resource_Index = 0
        end
        EventSystem:registEvent(EVENTTYPE_WEEK_SIGNUP, EVENTID_WEEK_SIGNUP_SYNCINFO, OnWeekSignUpUpdated);
        EventSystem:registEvent(EVENTTYPE_WEEK_SIGNUP, EVENTID_WEEK_SIGNUP_AWARD_RESULT, OnWeekSignUpResult);
        WeekSignUpUI.IsInited = true;
    end
    OnWeekSignUpUpdated();
end

function WeekSignUpUI.Release(...)
    if WeekSignUpUI.IsInited then
        log("WeekSignUpUI.Release");
        EventSystem:unregistEvent(EVENTTYPE_WEEK_SIGNUP, EVENTID_WEEK_SIGNUP_SYNCINFO, OnWeekSignUpUpdated);
        EventSystem:unregistEvent(EVENTTYPE_WEEK_SIGNUP, EVENTID_WEEK_SIGNUP_AWARD_RESULT, OnWeekSignUpResult);
        WeekSignUpUI.IsInited = false;
    end
end

function WeekSignUpUI.ShowUI( ... )
	LuaClassObj.HandleDynamicCreation(bp_week_signup);
    -- BP_Week_Is_Not_Login = 1;
    -- NetUtil.SendPkg("get_activity_list_req")
    LuaClassObj.HandleUIMessage(bp_week_signup, "UpdateActivityImage");
    log("WeekSignUpUI.ShowUI");
    LuaClassObj.HandleUIMessage(bp_week_signup, "UIShow");

    local currentTimeInDay = math.ceil(FuncUtil.GetServerTimeInSec() / 86400);
    local latestSignUpDay = DataMgr.GetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_WEEK_SIGN, 1) or 1;
    if currentTimeInDay ~= latestSignUpDay then
        DataMgr.SetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_WEEK_SIGN, 1, currentTimeInDay)
    end
end

function WeekSignUpUI.HideUI( ... )
    WeekSignUpUI.Release();

    -- 审核期间不弹
    log("weak signUp "..tostring(LobbySystem.CheckOpen(BP_ENUM_EXAMINE_UI_WEAK_SIGNUP)))
    -- if LobbySystem.CheckOpen(BP_ENUM_EXAMINE_UI_WEAK_SIGNUP) then
    FaceSlapSystem.ShowNext(BP_ENUM_MODULE_WEEK_SIGNUP);
    -- end
end

function bp_week_signup_OnModeSwitched(gamestatus)
    log("bp_week_signup_OnModeSwitched gamestatus = "..gamestatus);
    -- 回到登录场景清数据
    if string.lower(gamestatus) == "login" then
        WeekSignUpSystem.ResetData();
        WeekSignUpUI.ResetData();
        WeekSignUpUI.Release();
    elseif string.lower(gamestatus) == "lobby" then

    end
end

function WeekSignUpUI.ShouldSlap()
    if #DataMgr.WeekSignUpInfo.AwardState == 0 then
        log("[HHF]WeekSignUpUI.ShouldSlap = false, AwardState = 0");
        return false
    end

    local weekDay = FuncUtil.GetServerWeekDay();
    if DataMgr.WeekSignUpInfo.AwardState[weekDay] == WeekSignUpSystem.status_awarded then
        log("[HHF]WeekSignUpUI.ShouldSlap = false, AwardState[weekDay] = WeekSignUpSystem.status_awarded");
        return false;
    end

    -- if DataMgr.IsEightDaySlpaed then
    --    return false;
    -- end

    -- 审核期间不弹
    log("weak signUp "..tostring(LobbySystem.CheckOpen(BP_ENUM_EXAMINE_UI_WEAK_SIGNUP)))
    if not LobbySystem.CheckOpen(BP_ENUM_EXAMINE_UI_WEAK_SIGNUP) then
        return false;
    end

    local currentTimeInDay = math.ceil(FuncUtil.GetServerTimeInSec() / 86400);
    local latestSignUpDay = DataMgr.GetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_WEEK_SIGN, 1) or 1;
    if currentTimeInDay == latestSignUpDay then
        log("[HHF]WeekSignUpUI.ShouldSlap = false, currentTimeInDay = latestSignUpDay = " .. tostring(currentTimeInDay));
        return false;
    end

    log("[HHF]WeekSignUpUI.ShouldSlap = true");
    return true;
end

function bp_week_signup_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_week_signup,
        {{Path = "/Game/UMG/UI_Logic/WeekSignUp/WeekSignUp_BP.WeekSignUp_BP_c", Container = "Default", ZOrder = BP_ENUM_UI_SIGNIN_ZORDER}},
        { "Lobby"},
        false,
        bp_week_signup_OnModeSwitched ~= nil,
		true);
    EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_WEEK_SIGNUP, WeekSignUpUI.OnJumpUrl);
end