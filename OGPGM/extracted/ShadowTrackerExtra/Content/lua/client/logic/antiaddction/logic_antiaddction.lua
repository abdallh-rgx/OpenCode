AntiaddctionSystem = AntiaddctionSystem or
{
    is_nonage = true;
    need_show = false;
    age = -1;
    open_type = 0;
    is_login = false;
    anti_table = {};

    rest_time = 0,
}

function AntiaddctionSystem.OpenNoticePanel()
    local uiManager = require("ui.manager");
    if uiManager then
        uiManager.ShowUI(uiManager.UI_Config.antiaddction_notice)
    end
end

function AntiaddctionSystem.OpenKickPanel(contentMsg, popupType)
    local uiManager = require("ui.manager");
    if uiManager then
        uiManager.ShowUI(uiManager.UI_Config.antiaddction_kick, contentMsg, popupType)
    end
end

function AntiaddctionSystem.CloseNoticePanel()
    log("CloseNoticePanel");
    local uiManager = require("ui.manager");
    if uiManager then
        uiManager.CloseUI(uiManager.UI_Config.antiaddction_notice)
    end
    FaceSlapSystem.ShowNext(BP_ENUM_MODULE_ANTIADDCTION);
end

function AntiaddctionSystem.CloseKickPanel()
    log("CloseNoticePanel");
    local uiManager = require("ui.manager");
    if uiManager then
        uiManager.CloseUI(uiManager.UI_Config.antiaddction_kick)
    end
    FaceSlapSystem.ShowNext(BP_ENUM_MODULE_ANTIADDCTION);
end
function AntiaddctionSystem.SetAge()
    local contentMsg =  FuncUtil.LocalizeResFormat(6769, AntiaddctionSystem.age)
    GlobalData.GetLocalizeStringWithNum()
    local okMsg = Client.GetTableData("LocalizeRes",4110).TextValue;
    local noMsg = Client.GetTableData("LocalizeRes",4115).TextValue;
    local title = Client.GetTableData("LocalizeRes",6770).TextValue;
    CommonMessageBoxUI:ShowPanel(2, title, contentMsg, function()
        log("click confirm");
        AntiaddctionSystem.set_nonage_req(1)
        AntiaddctionSystem.OpenNoticePanel()
    end, function()
        log("click cancle");
        AntiaddctionSystem.set_nonage_req(0)
        AntiaddctionSystem.OpenNoticePanel()
    end, okMsg, noMsg);
end

function AntiaddctionSystem.set_nonage_rsp(ok)
    log("set_nonage_rsp" .. tostring(ok));
end

function AntiaddctionSystem.get_nonage_data_rsp(is_show, is_nonage, age)
    log("is show " .. tostring(is_show));
    log("is_nonage" .. tostring(is_nonage));
    log("age" .. tostring(age));
    log("AntiaddctionSystem.get_nonage_data_rsp");
    if is_show == true and is_nonage == nil then
        AntiaddctionSystem.need_show = true;
    else
        AntiaddctionSystem.need_show = false;
    end
    AntiaddctionSystem.is_nonage = is_nonage;
    AntiaddctionSystem.age = age;
end

function AntiaddctionSystem.ShouldSlap()
    log(" AntiaddctionSystem.ShouldSlap")
    if AntiaddctionSystem.need_show == true then
        AntiaddctionSystem.SetAge();
        return true;
    elseif AntiaddctionSystem.is_login == true then
        local contentMsg;
        if AntiaddctionSystem.anti_table.popup_type == 2 then
            contentMsg = FuncUtil.LocalizeResFormat(tonumber(AntiaddctionSystem.anti_table.content_attempt), FuncUtil.TimeFormatExtNoZero(AntiaddctionSystem.rest_time));
            AntiaddctionSystem.OpenKickPanel(contentMsg, AntiaddctionSystem.anti_table.popup_type);
        elseif AntiaddctionSystem.anti_table.popup_type == 3 then
            contentMsg = FuncUtil.LocalizeResFormat(tonumber(AntiaddctionSystem.anti_table.content_attempt), AntiaddctionSystem.GetNextLoginTime());
            AntiaddctionSystem.OpenKickPanel(contentMsg, AntiaddctionSystem.anti_table.popup_type);
        end
        return true;
    end
    return false;
end

function AntiaddctionSystem.check_nonage_anti_work(ok, plan_id, anti_table, rest_time, is_login)
    log("check_nonage_anti_work");
    local curStatus = string.lower(LuaClassObj.GetGameStatus(bp_lobby))
    if curStatus == "lobby" or curStatus == "login" then
        if ok == 0 then
            log("check_nonage_anti_work is ok")
            local contentMsg;
            AntiaddctionSystem.is_login = is_login;
            AntiaddctionSystem.rest_time = rest_time;
            AntiaddctionSystem.anti_table = anti_table;
            if is_login == false then
                if anti_table.popup_type == 1 then
                    contentMsg = GlobalData.GetLocalizeStringWithNum(tonumber(anti_table.content), 0, FuncUtil.TimeFormatExtNoZero(anti_table.sustained_time_down), FuncUtil.TimeFormatExtNoZero(anti_table.gap_time));
                    AntiaddctionSystem.OpenKickPanel(contentMsg, anti_table.popup_type);
                elseif anti_table.popup_type == 2 then
                    contentMsg = GlobalData.GetLocalizeStringWithNum(tonumber(anti_table.content), 0, FuncUtil.TimeFormatExtNoZero(anti_table.sustained_time_down), FuncUtil.TimeFormatExtNoZero(rest_time), FuncUtil.TimeFormatExtNoZero(anti_table.gap_time));
                    AntiaddctionSystem.OpenKickPanel(contentMsg, anti_table.popup_type);
                elseif anti_table.popup_type == 3 then
                    contentMsg = GlobalData.GetLocalizeStringWithNum(tonumber(anti_table.content), 0, FuncUtil.TimeFormatExtNoZero(anti_table.sustained_time_down), AntiaddctionSystem.GetNextLoginTime());
                    AntiaddctionSystem.OpenKickPanel(contentMsg, anti_table.popup_type);
                end
            end
        else
            AntiaddctionSystem.is_login = false;
            log("check_nonage_anti_work error code is " .. tostring(ok))
        end
    end
    log("plan_id " .. tostring(plan_id));
    log_tree("anti_table", anti_table);
    log("rest_time " .. tostring(rest_time));
    log("is_login " .. tostring(is_login));
end

function AntiaddctionSystem.GetNextLoginTime()
    local str = FuncUtil.GetServerTimeInSec();
    local zero = os.date('!%Y-%m-%d 00:00:00', str)
    local result = TimeUtil.TimeStringToUnixstamp(zero) + 86400;
    log("after == " .. os.date('%Y-%m-%d 00:00:00', result));
    return os.date('%Y-%m-%d %H:%M:%S', result);
end

------------------------------------------------------------------协议-----------------------------------------------------------------------------------------

function AntiaddctionSystem.set_nonage_req(is_nonage)
    NetUtil.SendPkg("set_nonage_req", is_nonage);
end

s2c["set_nonage_rsp"] = AntiaddctionSystem.set_nonage_rsp;
s2c["get_nonage_data_rsp"] = AntiaddctionSystem.get_nonage_data_rsp;
s2c["check_nonage_anti_work"] = AntiaddctionSystem.check_nonage_anti_work


