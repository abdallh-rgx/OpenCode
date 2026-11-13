--时间工具类
--此类提供两个功能：1、与服务器对时，用于计算显示开始，结束，以及倒计时等；2、转换为本地时间，支持多种格式，也可以自己指定
--例如：%y.%m.%d，%m.%d %H:%M，%M:%S
--一般性说明：UTCtime表示UTC0的时间，默认是用服务器下发，通常是配置表里面读取的时间
TimeUtil = TimeUtil or {
    
}

--获取当前时间和服务器时间的时间差，单位秒
--UTCtime表示服务器下发过来的时间（UTC0)
function TimeUtil.GetSecondsByUTCTime(UTCtime)
    local serverTime = FuncUtil.GetServerTimeInSec();
    if UTCtime > serverTime then
        return UTCtime - serverTime;
    end
    return 0;
end

--服务器UTC时间转换成本地时间，默认转换 分:秒
--return eg: 09:59
function TimeUtil.formatUTCToLocal0(UTCtime, format)
    if UTCtime == nil or UTCtime < 0 then
        return "";
    end
    return os.date(format or "%M:%S", UTCtime);
end

--服务器UTC时间转换成本地时间，默认转换为 年.月.日
--return eg: 2018.11.29
function TimeUtil.formatUTCToLocal1(UTCtime, format)
    if UTCtime == nil or UTCtime < 0 then
        return "";
    end
    return os.date(format or "%y.%m.%d", UTCtime);
end

--服务器UTC时间转换成本地时间，默认转换为 月.日 小时.分
--return eg 11.29 21:50
function TimeUtil.formatUTCToLocal2(UTCtime, format)
    if UTCtime == nil or UTCtime < 0 then
        return "";
    end
    return os.date(format or "%m.%d %H:%M", UTCtime);
end

--显示倒计时
--return 大于2天返回 eg: 4 days
--return 小于2天返回 eg: 47:59:59
--deltaTime表示时间差
function TimeUtil.FormatTimeCountDown0(deltaTime)
    -- body
    local str = "";

    if deltaTime == nil or deltaTime <= 0 then
        return str;
    end
    local days = math.floor(deltaTime/86400);
    local hours = math.fmod(math.floor(deltaTime/3600), 24);
    local mins = math.fmod(math.floor(deltaTime/60), 60);
    local seconds = math.fmod(deltaTime, 60);

    if days >= 2 then
        str = str .. FuncUtil.LocalizeResFormat("301153", days);
        --str = str .. Client.GetTableData("LocalizeRes", 301367).TextValue;
    else
        if days > 0 then
            hours = hours + days * 24;
        end
        if hours >= 10 then
            str = str .. hours;
        else
            str = str .. "0" .. hours;
        end
        str = str .. ":";
        if mins >= 10 then
            str = str .. mins;
        else
            str = str .. "0" .. mins;
        end
        str = str .. ":";
        if seconds >= 10 then
            str = str .. seconds;
        else
            str = str .. "0" .. seconds;
        end
    end
    return str;
end

--服务器UTC时间转换成UTC时间 默认转换为 年月日 
--return eg: 2018年11月30日 
function TimeUtil.SecToDateStringUTC(UTCtime, format)
    local DateFormat = FuncUtil.GetLocalizeResStr(110070);
    return os.date("!" .. (format or DateFormat), UTCtime);
end

-- 参数格式如：2018-11-01 06:00:00
-- 返回值：1541052000，（进出都是UTC时间）
function TimeUtil.TimeStringToUnixstamp(timeString)
    if not timeString or string.len(timeString) == 0 then
        return 0;
    end

    local p = "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)";
    local year, month, day, hour, min, sec = string.match(timeString, p);
    if year and month and day and hour and min and sec then
        local offset = os.time() - os.time(os.date("!*t"));
        return os.time({year=year, month=month, day=day, hour=hour, min=min, sec=sec, isdst = false}) + offset;
    end

    return 0;
end
