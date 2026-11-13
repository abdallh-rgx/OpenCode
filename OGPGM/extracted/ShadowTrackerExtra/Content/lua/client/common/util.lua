FuncUtil = FuncUtil or {
    LastServerTime = 0,
    LastServerTimeWithFraction = 0,
    LocalTimeTick = 0,

    BitCount = 32,
    BitValues = {1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048},
    secToMin = 1 / 60,
    dayToMin = 24 * 60,
    hourToMin = 60,

    minToSec = 60,
    hourToSec = 60 * 60,
    dayToSec = 24 * 60 * 60,
	curVersion = "0",
}
FuncUtil.minToDay = 1 / FuncUtil.dayToMin;
FuncUtil.minToHour = 1 / FuncUtil.hourToMin;

function FuncUtil:getDefaultOpenID()
	return "";
end

--版本是否客户端一致
function FuncUtil:IsMatchVersion(sVersion)
    --只处理大版本号0.0.1
   --log("severVersion"..sVersion);
   if FuncUtil.curVersion == "0" then
        FuncUtil.curVersion = Client.GetAppVersion();
   end
   --local curVerion = Client.GetAppVersion(); --"0.0.5.1018";
   local clientVersion = FuncUtil:GetClientFormat(FuncUtil.curVersion);
   local serverVersion = FuncUtil:GetClientFormat(sVersion);
   --log("clientVersion"..clientVersion);
   --log("serverVersion"..serverVersion);

   local serverStrArray = string.split(serverVersion, ".");
   local clientStrArray = string.split(clientVersion, ".");

   for i = 1, #serverStrArray do 
       if tonumber(serverStrArray[i]) ~= tonumber(clientStrArray[i]) then
            return false;
       end
   end

   return true;
end

--结构化版本字符串，和后台统一
function FuncUtil:GetClientFormat(newVesion)
    local  curVerion = newVesion;
    local iteratorFunc = string.gmatch(curVerion, "%w+");
    local count = 0;
    local len = 0;
    for subver in iteratorFunc do
        len = len+string.len(subver);
        count = count+1;
        if  count >= 3 then 
            break;
        end
    end
    if  count < 3 then
        
        return "0.0.0";
    end    
    return string.sub(curVerion, 1, len+2 );
end

function FuncUtil:getRandName()
    --local name = "吃鹅"
    local name = FuncUtil.GetLocalizeResStr("301125");    
    math.randomseed(os.time());
    for i=1,5 do
        name = name .. string.char(math.random(97,122));
    end
    return name;
end

function FuncUtil:err(msg)
	ScriptHelperClient.ShowScreenDebugMessage(msg)
end

--复制表格
function FuncUtil:CopyTable(st)
    local tab = {}
    for k, v in pairs(st or {}) do
        if type(v) ~= "table" and type(v) ~= "userdata" then
            tab[k] = v
        else
            tab[k] = FuncUtil:CopyTable(v)
        end
    end
    return tab
end

--求表长
function FuncUtil:CountTable(st)
    if type(st) ~= "table" then
        return 0;
    else
        local count = 0;
        for k, v in pairs(st) do
            count = count + 1
        end
        return count;
    end
end

function FuncUtil:TableSlice(values,i1,i2)
    local res = {}
    local n = #values
    i1 = i1 or 1
    i2 = i2 or n
    if i2 < 0 then
        i2 = n + i2 + 1
    elseif i2 > n then
        i2 = n
    end
    if i1 < 1 or i1 > n then
        return {}
    end
    local k = 1
    for i = i1,i2 do
        res[k] = values[i]
        k = k + 1
    end
    return res
end

function FuncUtil:InitConfigs()
    self:InitStyles();
    self:InitGameStatusMap();
end

function FuncUtil:InitStyles()
    local fontStyles = Client.GetTable("FontStyleRes");
    for k,v in pairs(fontStyles) do
        Client.SetFontStyle(v.StyleName, v.FontSize, v.FontPath, v.FontColor, v.FontShadow and v.FontShadow ~= 0);
    end
    
    local imgStyles = Client.GetTable("ImageStyleRes");
    for k,v in pairs(imgStyles) do
        Client.SetImageStyle(v.StyleName, v.ImageSize, v.ImagePath, v.ImageColor);
    end
    
    local linkStyles = Client.GetTable("LinkStyleRes");
    for k,v in pairs(linkStyles) do
        Client.SetLinkStyle(v.StyleName, v.FontSize, v.FontPath, v.FontColor, v.UnderLine);
    end
end

--游戏状态到地图的对应表
function FuncUtil:InitGameStatusMap()
    local StatusToMap = 
    {
        Login = "/Game/Maps/UImap/Editor_login",
        Lobby = "/Game/Maps/UImap/Lobby_Main_int",
        CreateRole = "/Game/Maps/UImap/Createrole",
    };
    Client.SetGameStatusMap(GameFrontendHUD, StatusToMap);
end

function OnHyperLinkClicked(MetaData)
    --log_tree("OnClickMeta", MetaData)
end

function string.split(str, sep)
    local result = {}
    if str == nil or sep == nil or type(str) ~= "string" or type(sep) ~= "string" then
        return result
    end
    if #sep == 0 then
        return result
    end
    local pattern = string.format("([^%s]*)", sep)
    string.gsub(str, pattern, function(c) result[#result+1] = c end)
    return result
end

-- 获取星期几
-- 1~7 周一~周日
function FuncUtil.GetWeekDayByTime(t)
	local weekDay = tonumber(os.date("%w", t));
	if weekDay and weekDay == 0 then
		weekDay = 7;
	end
	return weekDay;
end

function FuncUtil.GetUTCWeekDayByTime(t)
	local weekDay = tonumber(os.date("!%w", t));
	if weekDay and weekDay == 0 then
		weekDay = 7;
	end
	return weekDay;
end

function FuncUtil.GetDaySeconds(hour, min, sec)
    return hour * 3600 + min * 60 + sec;
end


function FuncUtil.GetTimeBySec(sec)
    local day = math.floor(sec / FuncUtil.dayToSec);
    local hour = math.floor(sec / FuncUtil.hourToSec) - day * 24;
    local min = math.floor(sec / FuncUtil.minToSec) - day * 24 * 60 - hour * 60;
    sec = sec % 60;

    local timeStr = "";
    if day > 0 then
        timeStr = FuncUtil.LocalizeResFormat("301153", day);
    end
    if hour > 0 then
        timeStr = timeStr..FuncUtil.LocalizeResFormat("301155", hour);
    end
    if min > 0 then
        timeStr = timeStr..FuncUtil.LocalizeResFormat("301156", min);
    end
    if sec > 0 then
        timeStr = timeStr..FuncUtil.LocalizeResFormat("301157", sec);
    end

    return timeStr;
end

-- 当前时间是否在指定时间段内
-- startHourTime/endHourTime 格式 "hh:mm:ss"
function FuncUtil.IsInUTCDayTimeRange(curTime, startHourTime, endHourTime)
	if not startHourTime or startHourTime == "" or not endHourTime or endHourTime == "" then
        return true;
    end

	local patern = "(%d+):(%d+):(%d+)";
	local startHour, startMin, startSec = string.match(startHourTime, patern);
    local endHour, endMin, endSec = string.match(endHourTime, patern);
    local ut = os.date('!*t', curTime);

    local startSec = FuncUtil.GetDaySeconds(startHour, startMin, startSec);
    local endSec = FuncUtil.GetDaySeconds(endHour, endMin, endSec);
    local curSec = FuncUtil.GetDaySeconds(ut.hour, ut.min, ut.sec);

    local inRange = (curSec >= startSec and curSec <= endSec);
	
    return inRange;
end

function FuncUtil.FormatTime(t,s)
    if t == nil then
        return ""
    end

    -- 为了土耳其语修改   
    local str = ""
    if s == "online" then
        --str = "最近上线 ";
        -- str = Client.GetTableData("LocalizeRes",301101).TextValue;
    end
    
    local diff = os.time() - t
    local days = math.floor(diff/86400)
    local hours = math.fmod(math.floor(diff/3600), 24)
    local mins = math.fmod(math.floor(diff/60), 60)
    local seconds = math.fmod(diff, 60)
        
--             if days >= 1 then
--         if hours >= 1 then
--             --return str..days.."天前";
--             return str..string.format(Client.GetTableData("LocalizeRes", "301255").TextValue, tostring(days));
--         elseif hours < 1 and hours >= 0 then
--             --return str..days.."天前";
--             return str..string.format(Client.GetTableData("LocalizeRes", "301255").TextValue, tostring(days));
--         end
--     end
--     if hours >= 1 then
--         if mins >= 1 then
--             --return str..hours.."小时前";
--             return str..string.format(Client.GetTableData("LocalizeRes", "301257").TextValue, tostring(hours));
--         elseif mins < 1 and mins >= 0 then
--             --return str..hours.."小时前";
--             return str..string.format(Client.GetTableData("LocalizeRes", "301257").TextValue, tostring(hours));
--         end
--     end
--     if mins >= 1 then
--         --return str..mins.."分钟前";
--         return str..string.format(Client.GetTableData("LocalizeRes", "301264").TextValue, tostring(mins));
--     else
--         --return str.."1分钟前";
--         return str..Client.GetTableData("LocalizeRes", "301105").TextValue;
--     end
-- end

    if days >= 1 then
        if hours >= 1 then
            --return str..days.."天前";
            if s == "online" then
                return str..string.format(Client.GetTableData("LocalizeRes", "5095").TextValue, tostring(days));
            else
                return str..string.format(Client.GetTableData("LocalizeRes", "301255").TextValue, tostring(days));
            end
        elseif hours < 1 and hours >= 0 then
            --return str..days.."天前";
            if s == "online" then
                return str..string.format(Client.GetTableData("LocalizeRes", "5095").TextValue, tostring(days));
            else
                return str..string.format(Client.GetTableData("LocalizeRes", "301255").TextValue, tostring(days));
            end
        end
    end
    if hours >= 1 then
        if mins >= 1 then
            --return str..hours.."小时前";
            if s == "online" then
                return str..string.format(Client.GetTableData("LocalizeRes", "5096").TextValue, tostring(hours));
            else
                return str..string.format(Client.GetTableData("LocalizeRes", "301257").TextValue, tostring(hours));
            end

        elseif mins < 1 and mins >= 0 then
            --return str..hours.."小时前";
            if s == "online" then
                return str..string.format(Client.GetTableData("LocalizeRes", "5096").TextValue, tostring(hours));
            else
                return str..string.format(Client.GetTableData("LocalizeRes", "301257").TextValue, tostring(hours));
            end
        end
    end
    if mins >= 1 then
        --return str..mins.."分钟前";
        if s == "online" then
            return str..string.format(Client.GetTableData("LocalizeRes", "5097").TextValue, tostring(mins));
        else
            return str..string.format(Client.GetTableData("LocalizeRes", "301264").TextValue, tostring(mins));
        end

    else
        --return str.."1分钟前";
        if s == "online" then
            return str..Client.GetTableData("LocalizeRes", "5098").TextValue;
        else
            return str..Client.GetTableData("LocalizeRes", "301105").TextValue;
        end
    end
end

function FuncUtil.FormatTime2(t)
	if t == nil then
		return;
	end
	
    local hours = math.fmod(math.floor(t/3600), 24);
    local mins = math.fmod(math.floor(t/60), 60);
    local seconds = math.fmod(t, 60);

    if hours >= 1 then
		if mins >= 1 then
		    --return "已开局"..hours.."小时"..mins.."分钟";
		    return FuncUtil.LocalizeResFormat( "301260", tostring(hours), tostring(mins));
		elseif mins < 1 and mins >= 0 then
			--return "已开局"..hours.."小时";
			return FuncUtil.LocalizeResFormat( "301261", tostring(hours));
		end
    end
    if mins >= 1 then
        --return "已开局"..mins.."分钟"..seconds.."秒";
		return FuncUtil.LocalizeResFormat( "301262", tostring(mins), tostring(seconds));
    end
    --return "已开局"..seconds.."秒";
	return FuncUtil.LocalizeResFormat( "301263", tostring(seconds));
end

--返回 08:08 15:15
function FuncUtil.FormatTime3(t)
    if t == nil or t < 0 then
        return "";
    end
    return os.date(Client.GetTableData("LocalizeRes", 5093).TextValue, t);
end

function FuncUtil.FormatTime4(t)
    if t == nil or t < 0 then
        return "";
    end
    return os.date("%y.%m.%d", t);
end

-- 返回 hours小时
function FuncUtil.FormatTime5(t)
    if t == nil or t < 0 then
        return "";
    end
    local hours = math.ceil(t / 3600);
    log("FuncUtil.FormatTime5:----"..tostring(hours))
    return hours
end

function FuncUtil.FormatTimeCountDown(t)
    -- body
    local str = "";

    if t == nil or t <= 0 then
        return str;
    end
    local days = math.floor(t/86400);
    local hours = math.fmod(math.floor(t/3600), 24);
    local mins = math.fmod(math.floor(t/60), 60);
    local seconds = math.fmod(t, 60);

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

function FuncUtil.FormatTimeCountDown2(t)
    -- body
    local str = "";

    if t == nil or t <= 0 then
        return str;
    end
    local days = math.floor(t/86400);
    local hours = math.fmod(math.floor(t/3600), 24);
    local mins = math.fmod(math.floor(t/60), 60);
    local seconds = math.fmod(t, 60);

    if days > 0 then
        str = FuncUtil.LocalizeResFormat("301153", days);
        str = str .. FuncUtil.LocalizeResFormat("301155", hours);
    else
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

function FuncUtil:StrTrim(s)
    return (string.gsub(s, "^%s*(.-)%s*$", "%1"))  
end

function FuncUtil:EncodeURI(s)
    if type(s) == "string" then
        s = string.gsub(s, "\n", "\r\n")
        s = string.gsub(s, "([^%w ])",
            function (c) return string.format("%%%02X", string.byte(c)) end)
        s = string.gsub(s, " ", "+")
    end
    return s
end

function FuncUtil:DecodeURI(s)
    if type(s) == "string" then
        s = string.gsub(s, '%%(%x%x)', 
            function (hex) return string.char(tonumber(hex,16)) end )
    end
    return s
end

function FuncUtil:DecodeXML(str)
    local map={ ["lt"]="<", ["gt"]=">", ["amp"]="&", ["quot"]='"', ["apos"]="'" }
    str = string.gsub( str, '(&(#?x?)([%d%a]+);)', function(orig,n,s)
    return (n=='' and map[s])
           or (n=="#x" and tonumber(s,16)) and string.char(tonumber(s,16))
           or (n=="#" and tonumber(s)) and string.char(s)
           or orig
  end )
  return str
end

function FuncUtil:GetGCloudErrorMsg(errorId)
	--local msg = "服务器连接状态异常，请重新登录："..errorId;
	local msg = FuncUtil.GetLocalizeResStr("301234")..tostring(errorId);
	if errorId == GCLOULD_ErrorNetworkException then
		--msg = "无法连接到服务器，请检查你的网络";
		msg = FuncUtil.GetLocalizeResStr("103015");
	elseif errorId == GCLOULD_ErrorTimeout then
		--msg = "服务器连接超时，请稍候再试";
		msg = FuncUtil.GetLocalizeResStr("301235");
	elseif errorId == GCLOULD_ErrorInvalidArgument then
		--msg = "网络通讯参数错误";
		msg = FuncUtil.GetLocalizeResStr("301236");
	elseif errorId == GCLOULD_ErrorLengthError then
		--msg = "网络通讯输出参数长度错误";
		msg = FuncUtil.GetLocalizeResStr("301237");
	elseif errorId == GCLOULD_ErrorEmpty then
		--msg = "帐号未登录，请重新登录";
		msg = FuncUtil.GetLocalizeResStr("301238");
	elseif errorId == GCLOULD_ErrorNotInitialized then
		--msg = "网络连接未初始化";
		msg = FuncUtil.GetLocalizeResStr("301239");
	elseif errorId == GCLOULD_ErrorNotSupported then
		--msg = "当前网络不支持";
		msg = FuncUtil.GetLocalizeResStr("301240");
	elseif errorId == GCLOULD_ErrorNotInstalled then
		--msg = "QQ或微信未安装";
		msg = FuncUtil.GetLocalizeResStr("301241");
	elseif errorId == GCLOULD_ErrorSystemError then
		--msg = "系统错误，请重新登录";
		msg = FuncUtil.GetLocalizeResStr("301242");
	elseif errorId == GCLOULD_ErrorNoPermission then
		--msg = "没有鉴权，请重新登录";
		msg = FuncUtil.GetLocalizeResStr("301243");
	elseif errorId == GCLOULD_ErrorInvalidGameId then
		--msg = "无效的游戏应用ID，请重新下载";
		msg = FuncUtil.GetLocalizeResStr("301244");
	elseif errorId == GCLOULD_ErrorChecking then
		--msg = "鉴权校验中，请稍候";
		msg = FuncUtil.GetLocalizeResStr("301245");
	elseif errorId == GCLOULD_ErrorConnectFailed then
		--msg = "连接服务器失败，请重试";		
		msg = FuncUtil.GetLocalizeResStr("301246");
	elseif errorId == GCLOULD_ErrorPeerCloseConnection then
		--msg = "服务器连接已断开，请重新登录";
		msg = FuncUtil.GetLocalizeResStr("301247");
	elseif errorId == GCLOULD_ErrorPeerStopSession then
		--msg = "服务器已断开，请重新登录";
		msg = FuncUtil.GetLocalizeResStr("301248");
	elseif errorId == GCLOULD_ErrorStayInQueue then
		--msg = "正在队列中，请稍后";
		msg = FuncUtil.GetLocalizeResStr("301249");
	elseif errorId == GCLOULD_ErrorSvrIsFull then
		--msg = "服务器已满，请稍后登录";
		msg = FuncUtil.GetLocalizeResStr("301250");
	elseif errorId == GCLOULD_ErrorTokenSvrError then
		--msg = "鉴权服务器错误，请稍候登录";
		msg = FuncUtil.GetLocalizeResStr("301251");
	elseif errorId == GCLOULD_ErrorAuthFailed then
		--msg = "鉴权失败，请重新登录";
		msg = FuncUtil.GetLocalizeResStr("301252");
	elseif errorId == GCLOULD_ErrorOverflow then
		--msg = "缓冲区溢出";
        msg = FuncUtil.GetLocalizeResStr("301253");
    elseif errorId == GCLOULD_ErrorInvalidToken then
        --token过期，提示如下
        --连接超时，请重新登录
        msg = FuncUtil.GetLocalizeResStr("4007");
	end
	
	return msg;
end

function FuncUtil:ParseURLParams(s)
	log(s);
	local params = {};
    for k, v in string.gmatch(s, "([^&=?]+)=([^&=?]+)") do
		params[k] = FuncUtil:DecodeURI(v);
	end
	return params;
end

--检查名字合法性
function FuncUtil:CheckName(inputstr, symbol, maxLen, support_space)
    local unitLen = 0
    local hasIllegalChar = false
    local lenInByte = #inputstr
    local retStr = ""
    local i = 1
    --汉字基本集 E4B880-E9BEBF
    local chinese1 = tonumber("E4B880", 16)
    local chinese2 = tonumber("E9BEBF", 16)
    local chineseSymbol = {"EFBC81","EFBFA5","E280A6","E280A6","EFBC88","EFBC89","E28094","EFBD9B","EFBD9D",
      "EFBC9A","E2809C","E2809D","E3808A","E3808B","EFBC9F","E38090","E38091","E38081","EFBC9B","E28098","EFBC8C","E38082","E38081","E28099"}
    --日文平假名
    local janpan1 = tonumber("E38180", 16)
    local janpan2 = tonumber("E3829F", 16)
    --日文片假名
    local janpan3 = tonumber("E382A0", 16)
    local janpan4 = tonumber("E383BF", 16)
    --日式标点
    local janpan5 = tonumber("E38080", 16)
    local janpan6 = tonumber("E380BF", 16)
    --全角数字
    local fullWidthNum1 = tonumber("EFBC90", 16)
    local fullWidthNum2 = tonumber("EFBC99", 16)
    --全角大写字母
    local fullWidthClatin1 = tonumber("EFBCA1", 16)
    local fullWidthClatin2 = tonumber("EFBCBA", 16)
    --全角小写字母
    local fullWidthSlatin1 = tonumber("EFBD81", 16)
    local fullWidthSlatin2 = tonumber("EFBD9A", 16)
    --日文半角片假名
    local halfWidthKata1 = tonumber("EFBDA6",16)
    local halfWidthKata2 = tonumber("EFBE9D",16)
    --韩文
    local korean1 = tonumber("EAB080", 16)
    local korean2 = tonumber("ED9EAF", 16)
    -- 俄文 西里尔字母
    local russia1 = tonumber("D080", 16)
    local russia2 = tonumber("D3Bf", 16)
    -- 俄文 西里尔字母扩充集
    local russia3 = tonumber("D480", 16)
    local russia4 = tonumber("D4AF", 16)
    -- 泰文
    local tai1 = tonumber("E0B880", 16)
    local tai2 = tonumber("E0B9BF", 16)
    -- EU special
    local EU_specail1 = tonumber("C2A1", 16)
    local EU_specail2 = tonumber("CAAf", 16)
    -- Vietnamese
    local Vietnamese1 = tonumber("E1B880", 16)
    local Vietnamese2 = tonumber("E1BBBF", 16)
    local Vietnamese3 = tonumber("CC80", 16)
    local Vietnamese4 = tonumber("CDBA", 16)

    -- hindi
    local hindi1 = tonumber("E0A480",16)
    local hindi2 = tonumber("E0A5BF",16)

    -- arabic
    local arabic1 = tonumber("D880",16)
    local arabic2 = tonumber("DBBF",16)
    
    while ( i <= lenInByte ) 
    do
        local a = string.byte(inputstr, i)
        local byteCount = 1;
        
        if a >= 0 and a < 192 then
            byteCount = 1                                               --1字节字符
            unitLen = unitLen + 1
            local isok = true
            if(symbol ~= nil) then
                if (a >= 0 and a<39) or (a > 39 and a < 48) or (a > 57 and a < 65) or (a > 90 and a < 97) or (a > 122) then
                -- if (a >= 0 and a < 48) or (a > 57 and a < 65) or (a > 90 and a < 97) or (a > 122) then
                -- make space and single quotes valid
                    isok = false
                end
            elseif (a >= 0 and a < 32) or (a > 126) then
                --elseif (a >= 0 and a < 33) or (a > 126) then
                -- make space valid
                isok = false
            end

            if(support_space ~= nil and a == 32) then
                isok = true
            end
            if( isok) then
                retStr = retStr .. string.char(a)
            else
                hasIllegalChar = true
            end
        elseif a >= 192 and a < 224 then                                --2节字符
            byteCount = 2                                
            local b = string.byte(inputstr, i + 1)
            local str = string.format("%X",a)..string.format("%X",b);
            local value = tonumber(str, 16)
            local isok = false
            if(value >= russia1 and value <= russia2) or (value >= russia3 and value <= russia4) then
                log("checkname is Russia")
                unitLen = unitLen + 1
                isok = true
            elseif ( value >= EU_specail1 and value <= EU_specail2) then
                log("checkname is EU special")
                unitLen = unitLen + 1
                isok = true
            elseif ( value >= Vietnamese3 and value <= Vietnamese4) then
                log("checkname is vietnamese")
                unitLen = unitLen + 1
                isok = true
            elseif (value >= arabic1 and value <= arabic2) then
                log("checkname is arabic")
                unitLen = unitLen + 1
                isok = true
            else
                unitLen = unitLen + 2
            end

            if ( isok ) then
                retStr = retStr .. string.sub(inputstr, i, i + byteCount - 1)
            else
                hasIllegalChar = true
            end
        elseif a >= 224 and a < 240 then            
            byteCount = 3                                               --3字节
            local b = string.byte(inputstr, i + 1)
            local c = string.byte(inputstr, i + 2)
            local str = string.format("%X",a)..string.format("%X",b)..string.format("%X",c);
            local value = tonumber(str, 16)            
            local isok = false
            if ( value >= chinese1 and value <= chinese2) then
                log("checkname is chinese")
                unitLen = unitLen + 2
                isok = true
            elseif ( value >= janpan1 and value <= janpan2) then
                log("checkname is janpan1-2")
                unitLen = unitLen + 2
                isok = true
            elseif ( value >= janpan3 and value <= janpan4) then
                log("checkname is janpan3-4")
                unitLen = unitLen + 2
                isok = true
            elseif ( value >= janpan5 and value <= janpan6) then
                log("checkname is janpan5-6")
                unitLen = unitLen + 2
                isok = true
            elseif ( value >= fullWidthNum1 and value <= fullWidthNum2) then
                log("checkname is fullWidthNum1-2")
                unitLen = unitLen + 2
                isok = true
            elseif ( value >= fullWidthClatin1 and value <= fullWidthClatin2) then
                log("checkname is fullWidthClatin1-2")
                unitLen = unitLen + 2
                isok = true
            elseif ( value >= fullWidthSlatin1 and value <= fullWidthSlatin2) then
                log("checkname is fullWidthSlatin1-2")
                unitLen = unitLen + 2
                isok = true
            elseif ( value >= halfWidthKata1 and value <= halfWidthKata2) then
                log("checkname is halfWidthKata1-2")
                unitLen = unitLen + 1
                isok = true
            elseif ( value >= tai1 and value <= tai2) then
                log("checkname is tai")
                unitLen = unitLen + 1
                isok = true
            elseif ( value >= Vietnamese1 and value <= Vietnamese2) then
                log("checkname is vietnamese")
                unitLen = unitLen + 1
                isok = true
            elseif ( value >= korean1 and value <= korean2) then
                log("checkname is korean")
                unitLen = unitLen + 2
                isok = true
            elseif (value >= hindi1 and value <= hindi2) then
                log("checkname is hindi")
                unitLen = unitLen + 2
                isok = true
            else
                unitLen = unitLen + 2
            end
            if( not isok and symbol == nil) then
              for i,v in ipairs(chineseSymbol) do
                if(value == tonumber(v , 16)) then
                    isok = true
                    break;
                end
              end
            end
            if ( isok ) then
                retStr = retStr .. string.sub(inputstr, i, i + byteCount - 1)
            else
                hasIllegalChar = true
            end
        elseif a >= 240 and a < 248 then
            byteCount = 4                                               --4字节
            unitLen = unitLen + 2
            hasIllegalChar = true
        elseif a >= 248 and a < 252 then
            byteCount = 5                                               --5字节
            unitLen = unitLen + 2
            hasIllegalChar = true;
        elseif a >= 252  then
            byteCount = 6                                               --6字节
            unitLen = unitLen + 2
            hasIllegalChar = true;
        end
        i = i + byteCount

        if (maxLen ~= nil and unitLen >= maxLen) then
            break;
        end
    end
    return hasIllegalChar , unitLen , retStr
end

function string.starts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

function string.ends(String,End)
   return End=='' or string.sub(String,-string.len(End))==End
end

function ShowNotice(noticeId)
    local noticeStr = FuncUtil.GetLocalizeResStr(noticeId)
    if noticeStr ~= "" then
        PopUpNoticeUI.ShowNewNotice(noticeStr)
    else
        PopUpNoticeUI.ShowNewNotice(noticeId)
    end
end

function print_r ( t )  
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            log(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        log(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        log(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        log(indent.."["..pos..'] => "'..val..'"')
                    else
                        log(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                log(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        log(tostring(t).." {")
        sub_print_r(t,"  ")
        log("}")
    else
        sub_print_r(t,"  ")
    end
    log()
end

function string.split(str, sep)
    local result = {}
    if str == nil or sep == nil or type(str) ~= "string" or type(sep) ~= "string" then
        return result
    end
    if #sep == 0 then
        return result
    end
    local pattern = string.format("([^%s]*)", sep)
    string.gsub(str, pattern, function(c) result[#result+1] = c end)
    return result
end

function FormatTime(seconds)
    local date = os.date("*t", seconds)
    local str = string.format("%d-%d-%d", date.year, date.month, date.day)
    return str
end

function FuncUtil.SetServerTimeInSec(serverTime)
    if serverTime == nil then
        return
    end
    -- log("FuncUtil.SetServerTimeInSec"..serverTime);
    FuncUtil.LocalTimeTick = 0;
    FuncUtil.LastServerTime = serverTime;
    FuncUtil.LastServerTimeWithFraction = serverTime;
end

function FuncUtil.GetServerTimeInSec()
    if FuncUtil.LastServerTime == 0 then
        return os.time();
    end

    return FuncUtil.LastServerTime + math.ceil(FuncUtil.LocalTimeTick);
end

function FuncUtil.GetServerTimeInSecWithFraction()
    if FuncUtil.LastServerTimeWithFraction == 0 then
        return os.time();
    end

    return FuncUtil.LastServerTimeWithFraction + FuncUtil.LocalTimeTick;
end

--如果小于起始时间，返回-1 如果大于结束时间返回1 如果处于范围内则返回0
function FuncUtil.TimeBetween(startTimeStr, endTimeStr)
    local now = FuncUtil.GetServerTimeInSec()
    if now < FuncUtil:UnixStringTimeToUnixTime(startTimeStr) then
        return -1
    elseif now > FuncUtil:UnixStringTimeToUnixTime(endTimeStr) then
        return 1
    else
        return 0
    end
end

--如果小于起始时间，返回-1 如果大于结束时间返回1 如果处于范围内则返回0
function FuncUtil.TimeNumBetween(startTime, endTime)
    local now = FuncUtil.GetServerTimeInSec()

    log("FuncUtil.TimeNumBetween startTime:" .. startTime .. ",endTime:" .. endTime ..  ",now:" .. now)
    if now < startTime then
        return -1
    elseif now > endTime then
        return 1
    else
        return 0
    end
end

-- 1~7 == 周一~周天
function FuncUtil.GetWeekDay(day)
    if day == 1 then
        return 7;
    else
        return day - 1;
    end
end

function FuncUtil.GetServerWeekDay()
    local currentDate = os.date("!*t", FuncUtil.GetServerTimeInSec());
    return FuncUtil.GetWeekDay(currentDate.wday);
end

-- 是否是同一天
function FuncUtil.IsSameDay(time1, time2)
    return math.floor((time1 - 57600) / 86400) == math.floor((time2 - 57600) / 86400);
end

function FuncUtil.IsInTime(beginTime, endTime)
	
	if beginTime == nil or endTime == nil then
		return false
	end
	log("time range = " .. beginTime .. "~" .. endTime)
	
	local begDate = {}
	for value in string.gmatch(beginTime, "%d+") do
		table.insert(begDate, tonumber(value))
	end
	
	local endDate = {}
	for value in string.gmatch(endTime, "%d+") do
		table.insert(endDate, tonumber(value))
	end
	
	if #begDate < 6 or #endDate < 6 then
		return false
	end
	
	local timeValBegin = os.time({year = begDate[1], month = begDate[2], day = begDate[3], hour = begDate[4], min = begDate[5], sec = begDate[6]})
	local timeValEnd = os.time({year = endDate[1], month = endDate[2], day = endDate[3], hour = endDate[4], min = endDate[5], sec = endDate[6]})
	local now = FuncUtil.GetServerTimeInSec()
	
	return now >= timeValBegin and now < timeValEnd
end

function FuncUtil.SecToDateString(sec)
    local DateFormat = FuncUtil.GetLocalizeResStr(110070);
    return os.date(DateFormat, sec);
end

function FuncUtil.SecToDateStringUTC(sec)
    local DateFormat = FuncUtil.GetLocalizeResStr(110070);
    return os.date("!"..DateFormat, sec);
end

function FuncUtil.EncodeBase64(source_str)  
    local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'  
    local s64 = ''  
    local str = source_str  
  
    while #str > 0 do  
        local bytes_num = 0  
        local buf = 0  
  
        for byte_cnt=1,3 do  
            buf = (buf * 256)  
            if #str > 0 then  
                buf = buf + string.byte(str, 1, 1)  
                str = string.sub(str, 2)  
                bytes_num = bytes_num + 1  
            end  
        end  
  
        for group_cnt=1,(bytes_num+1) do  
            local b64char = math.fmod(math.floor(buf/262144), 64) + 1  
            s64 = s64 .. string.sub(b64chars, b64char, b64char)  
            buf = buf * 64  
        end  
  
        for fill_cnt=1,(3-bytes_num) do  
            s64 = s64 .. '='  
        end  
    end  
  
    return s64  
end

function GetSafeNumber(value)
	if value == nil then
		return 0
	end
	
	return value;
end 

--翻译文字
function translate(value)
	return value;
end

function FuncUtil.GetLocalizeResStr(id)
    local localResCfg = Client.GetTableData("LocalizeRes", id);
    if localResCfg ~= nil then
        return localResCfg.TextValue;
    end
    sandbox.LogError("LocalizeRes not found id="..id);
    return "";
end

function FuncUtil.LocalizeResFormat(id, ...)
    local strFormat = FuncUtil.GetLocalizeResStr(id);
    if strFormat == "" then
        sandbox.LogError("LocalizeRes format is empty id="..id);
    end

    local IsNewStyle = string.find(strFormat, "{0}")
    local res = ""
    if IsNewStyle then
        res = strFormat
        for i, v in pairs({ ... }) do
            local pattern = "{" .. i - 1 .. "}"
            res = string.gsub(res, pattern, tostring(v))
        end
    else
        res = string.format(strFormat, ...);
    end

    return res
end

function FuncUtil.LocalizeResFormatByStr(strFormat, ...)
    if strFormat == "" then
        sandbox.LogError("LocalizeRes format is empty strFormat="..strFormat);
    end

    local IsNewStyle = string.find(strFormat, "{0}")
    local res = ""
    if IsNewStyle then
        res = strFormat
        for i, v in pairs({ ... }) do
            local pattern = "{" .. i - 1 .. "}"
            res = string.gsub(res, pattern, tostring(v))
        end
    else
        res = string.format(strFormat, ...);
    end

    return res
end

--function FuncUtil.LocalizeResFormatWithBrackets(id, ...)
--    local str = FuncUtil.GetLocalizeResStr(id);
--    for i, v in pairs({...}) do
--        str = string.gsub(str, "{" .. i - 1 .. "}", tostring(v))
--    end
--    return str
--end

function FuncUtil.TableConcat(t1,t2)
    for i=1,#t2 do
        t1[#t1+1] = t2[i]
    end
    return t1
end


-- 位掩码
function FuncUtil.MarkBit(maskTable, index)
    if index <= 0 or index > FuncUtil.BitCount then
        sandbox.LogError("FuncUtil.MarkBit index invalid "..index);
        return;
    end

    maskTable[index] = true;
end

function FuncUtil.UnmarkBit(maskTable, index)
    if index <= 0 or index > FuncUtil.BitCount then
        sandbox.LogError("FuncUtil.UnmarkBit index invalid "..index);
        return;
    end

    maskTable[index] = false;
end

function FuncUtil.GetBitMaskValue(maskTable)
    local result = 0;
    local value = 0;
    for i=1,FuncUtil.BitCount do
        if maskTable[i] then
            value = FuncUtil.BitValues[i];
            if value == nil then
                value = 2 ^ (i-1);
                FuncUtil.BitValues[i] = value;
            end
            result = result + value;
        end
    end
    return result;
end

-- 查找元素
function FuncUtil.Find(array, element)
    for i,v in pairs(array) do
        if v == element then
            return i;
        end
    end

    return -1;
end

function FuncUtil.GetMaxSegement(allSegmentInfo)
    local maxSegment_Solo = -1;
    local maxSegment_duo  = -1;
    local maxSegment_squad = -1;
    -- log_tree("================================allSegmentInfo", allSegmentInfo)
    for k,v in pairs(allSegmentInfo) do
        maxSegment_Solo = math.max(maxSegment_Solo, allSegmentInfo[k][1] or 0, allSegmentInfo[k][4] or 0);
        maxSegment_duo = math.max(maxSegment_duo, allSegmentInfo[k][2] or 0, allSegmentInfo[k][5] or 0);
        maxSegment_squad = math.max(maxSegment_squad, allSegmentInfo[k][3] or 0, allSegmentInfo[k][6] or 0);
    end
    -- sandbox.LogError("maxSegment_Solo:"..tostring(maxSegment_Solo))
    -- sandbox.LogError("maxSegment_duo:"..tostring(maxSegment_duo))
    -- sandbox.LogError("maxSegment_squad:"..tostring(maxSegment_squad))
    return maxSegment_Solo, maxSegment_duo, maxSegment_squad
end

function FuncUtil.GetCurMaxSegementLevel(allSegmentInfo)
    local maxSegment_Solo = -1;
    local maxSegment_duo  = -1;
    local maxSegment_squad = -1;
    maxSegment_Solo, maxSegment_duo, maxSegment_squad = FuncUtil.GetMaxSegement(allSegmentInfo)
    return math.max(maxSegment_Solo, maxSegment_duo, maxSegment_squad)
end

-- 显示最高的两个单位时间，入XX天XX小时，或XX小时XX分钟，其中最小位为0时不显示
function FuncUtil.TimeFormatExtNoZero(t)
    if t <= 0 then
        return FuncUtil.TimeFormatExt(1);
    end

    return FuncUtil.TimeFormatExt(t);
end

function FuncUtil.TimeFormatExt(t)
    local timeStr = "";
    local minAmmount = math.ceil(t * FuncUtil.secToMin);
    local day = math.floor(minAmmount * FuncUtil.minToDay);
    minAmmount = minAmmount - day * FuncUtil.dayToMin;
    local hour = math.floor(minAmmount * FuncUtil.minToHour);
    local min = minAmmount - hour * FuncUtil.hourToMin;
    -- log(string.format("FuncUtil.GetDoubleCardTimeStr d:%d h:%d m:%d", day, hour, min));

    if day > 0 then
        timeStr = FuncUtil.LocalizeResFormat("9910108", tostring(day));

        if hour > 0 then
            timeStr = timeStr..FuncUtil.LocalizeResFormat("9910107", tostring(hour));
        end

        return timeStr;
    end

    if hour > 0 then
        timeStr = FuncUtil.LocalizeResFormat("9910107", tostring(hour));
        if min > 0 then
            timeStr = timeStr..FuncUtil.LocalizeResFormat("9910115", tostring(min));
        end
        return timeStr;
    end

    timeStr = FuncUtil.LocalizeResFormat("9910115", tostring(min));

    return timeStr;
end

-- 截取中文字符串
function FuncUtil.SubString(str, subBegin, subEnd)
    if not str then
        return "";
    end

    local beginIdxArray = {}
    local endIdxArray = {}
    local idx = 1
    while idx <= #str do

        b, e = string.find(str, "[%z\1-\127\194-\244][\128-\191]*", idx)
        table.insert(beginIdxArray, b);
        table.insert(endIdxArray, e);

        if #beginIdxArray >= subEnd then
            break;
        end

        idx = e + 1;
    end

    if subBegin > #beginIdxArray then
        return "";
    end

    local endIndex = endIdxArray[math.min(#endIdxArray, subEnd)];
    return string.sub(str, beginIdxArray[subBegin], endIndex);
end

_isInLobby = false
function LuaClassObj.HandleLobbyUIMessage(...)
    if _isInLobby then
        LuaClassObj.HandleUIMessage(...);
    end
end

function FuncUtil:FormatMoney(n)
    if n > 99999999 then
        return string.format("%dW", (math.modf(n/10000)))
    end
    return tostring(n)
end

function FuncUtil:UnixStringTimeToUnixTime(s)
    if not s or string.len(s) == 0 then
        return 0;
    end

    local p = "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)";
    local year, month, day, hour, min, sec = s:match(p);
    if year and month and day and hour and min and sec then
        local isdst = os.date("*t", s).isdst
        local offset=os.time() - os.time(os.date("!*t"))
        return os.time({year=year, month=month, day=day, hour=hour, min=min, sec=sec}) + offset + (isdst and 3600 or 0);
    end
    return 0;
end

function FuncUtil:StringTimeToUnixTime(s)
    if not s or string.len(s) == 0 then
        return 0;
    end

    local p = "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)";
    local year, month, day, hour, min, sec = s:match(p);
    if year and month and day and hour and min and sec then
        return os.time({year=year, month=month, day=day, hour=hour, min=min, sec=sec});
    end
    return 0;
end

function FuncUtil:StrSplit(str, sep)
    local result = {}
    if str == nil or sep == nil or type(str) ~= "string" or type(sep) ~= "string" then
        return result
    end
    if #sep == 0 then
        return result
    end

    local iter = string.gmatch(str, "([^"..sep.."]+)");
    local index = 1;
    for value in iter do
        result[index] = value;
        index = index + 1;
    end
    return result;
end

--话题聊天字符串识别加处理
function FuncUtil.GetResultChatMsg(msg, data)
    local state = {
        normal = 1,
        ttopic = 2,
        ftopic = 3,
        atuser = 4,
    }

    local code_at    = utf8.codepoint("@")
    local code_topic = utf8.codepoint("#")

    local stop_atuser_string = " \n\t\v\f"
    local stop_ttopic_string = " -/:：;；(（)）$&@\"“”.。,，?？!！][{}%^*+=_\\|~<>€£¥•、"
    local stop_atuser_symbol = {}
    local stop_ttopic_symbol = {}

    if not data.selectPlayer then
        data.selectPlayer = {};
    end

    for _, code in utf8.codes(stop_atuser_string) do
        stop_atuser_symbol[code] = true
    end

    for _, code in utf8.codes(stop_ttopic_string) do
        stop_ttopic_symbol[code] = true
    end

    local function change(context, pos, state, new_state)
        if context.pos < pos then
            context.list[#context.list + 1] =
                {state=state,pos={context.pos,pos-1}}
            context.pos = pos
        end
        return new_state
    end

    local machine = {
        [state.normal] = function(context, pos, code)
            if code == code_at then
                return change(context, pos, state.normal, state.atuser)
            end
            if code == code_topic then
                return change(context, pos, state.normal, state.ttopic)
            end
        end,
        [state.ttopic] = function(context, pos, code)
            if code == code_at then
                return change(context, pos, state.ttopic, state.atuser)
            end
            if code == code_topic then
                return state.ftopic
            end
            if stop_ttopic_symbol[code] then
                return change(context, pos, state.ttopic, state.normal)
            end
        end,
        [state.ftopic] = function(context, pos, code)
            if code == code_at then
                return change(context, pos, state.ttopic, state.atuser)
            end
            if stop_ttopic_symbol[code] then
                return change(context, pos, state.ftopic, state.normal)
            end
        end,
        [state.atuser] = function(context, pos, code)
            if code == code_at then
                return change(context, pos, state.atuser, state.atuser)
            end
            if code == code_topic then
                return change(context, pos, state.atuser, state.ttopic)
            end
            if stop_atuser_symbol[code] then
                return change(context, pos, state.atuser, state.normal)
            end
        end,
    }

    local function extract_pos(input, b, e)
        local current = state.normal
        local context = {list={},pos=b or 1}
        for pos, code in utf8.codes(input, b, e) do
            current = machine[current](context, pos, code) or current
        end
        change(context, string.len(input) + 1, current)
        return context
    end

    local extract_str

    local callback = {
        [state.normal] = function(data, input, p1, p2)
            return string.sub(input, p1, p2)
        end,
        [state.ttopic] = function(data, input, p1, p2)
            local topic = string.sub(input, p1 + 1, p2)
            data.topicList[topic] = true
            if p1 == p2 then
                return string.sub(input, p1, p2)
            else
                return string.format("<Topic_Name>%s</>", string.sub(input, p1, p2))
            end
        end,
        [state.ftopic] = function(data, input, p1, p2)
            return string.sub(input, p1, p2)
        end,
        [state.atuser] = function(data, input, p1, p2)
            if #LobbyChatLogic.Local_ARRAY_SelectPlayerList > 0 then
                local findb, finde
                local realb, reale, node = p1 + 1, 0, false
                for _, v in pairs(LobbyChatLogic.Local_ARRAY_SelectPlayerList) do
                    findb, finde = string.find(input, v.name, realb)
                    -- 最大匹配
                    if findb and findb == realb then
                        if finde > reale then
                            node, reale = v, finde
                        end
                    end
                end
                if reale == 0 then -- 没匹配到
                    return string.sub(input, p1, p2)
                elseif reale >= p2 then -- 完全匹配
                    data.selectPlayer[node.gid] = node.name
                    return string.format("<Topic_PlayerName>@%s</>", node.name)
                else -- 还有剩余
                    data.selectPlayer[node.gid] = node.name
                    return string.format("<Topic_PlayerName>@%s</>", node.name) .. extract_str(input, data, reale + 1, p2)
                end
            end
            return string.sub(input, p1, p2)
        end,
    }

    extract_str = function(input, data, b, e)
        local sublist = {}
        local context = extract_pos(input, b, e)
        for i, sub in ipairs(context.list) do
            sublist[#sublist + 1] =
                callback[sub.state](data, input, sub.pos[1], sub.pos[2])
        end
        return table.concat(sublist)
    end
    
    return extract_str(msg, data);
end

function FuncUtil:Gen_title(res_id, rank)
    if res_id == 0 then
        return "";
    end
    local alias_info = Client.GetTableData("AliasCfg", res_id);
    if not alias_info then
        log("alias not found, id:%s uid:%s", res_id);
        return "";
    end
    local title = alias_info.AliasName;
    local type = alias_info.AliasSubType;
    if not rank then
        rank = 0;
    end
    if type == RoleInfoAliasUI.alias_type_warzone_nation then
        if rank <=100 and rank > 0 then
            title = string.format(title, rank);
        end
    end
    return title;
end



local function rightShift(num, shift)
    return math.floor(num/(2^shift));
end

local function numToAscii(num)
    num = num % 256;
    return string.char(num);
end

local function leftShift(num, shift)
    return math.floor(num * (2 ^ shift));
end

-- 二进制转int
function bufToInt32(num1, num2, num3, num4)
    local num = 0;
    num = num + leftShift(num1, 24);
    num = num + leftShift(num2, 16);
    num = num + leftShift(num3, 8);
    num = num + num4;
    return num;
end

-- int转二进制
function int32ToBufStr(num)
    local strList = {};
    table.insert(strList, string.byte(numToAscii(rightShift(num, 24))));
    table.insert(strList, string.byte(numToAscii(rightShift(num, 16))));
    table.insert(strList, string.byte(numToAscii(rightShift(num, 8))));
    table.insert(strList, string.byte(numToAscii(num)));
    --log_tree("int32ToBufStr", strList);
    return strList;
    --[[
    local str = "";
    str = str .. numToAscii(rightShift(num, 24));
    str = str .. numToAscii(rightShift(num, 16));
    str = str .. numToAscii(rightShift(num, 8));
    str = str .. numToAscii(num);
    return str;
    ]]
end

--组队招募消息编码
function FuncUtil.InCodeTeamRecruitMsg(modeIndex, perspectiveIndex, voiceIndex, playerCount, arrMapIndex, arrPosIndex)
    local arrBuf = {}
    table.insert( arrBuf, bufToInt32(modeIndex, perspectiveIndex, voiceIndex, playerCount) )
    table.insert( arrBuf, bufToInt32(tonumber(arrMapIndex[1]), tonumber(arrMapIndex[2]), tonumber(arrMapIndex[3]), tonumber(arrMapIndex[4])) )
    table.insert( arrBuf, table.concat(arrPosIndex, ",") )
    ---上传组队招募消息时增加时间戳
    if LobbySystem.LobbyMenuOpenStatus[70018] == nil or LobbySystem.LobbyMenuOpenStatus[70018].is_open ~= 0 then
        table.insert( arrBuf, FuncUtil.GetServerTimeInSec() );
    end
    return table.concat( arrBuf, "-" );
end

--组队招募消息解码
function FuncUtil.DeCodeTeamRecruitMsg(msg)
    if #BP_ARRAY_MapJdList == 0 or #BP_ARRAY_MapYlList == 0 then
        RecruitUI.MapIdList();
    end

    local msgArr = string.split(msg, "-");
    local resultMsg = "";
    --解码
    local msgArr1 = int32ToBufStr(tonumber(msgArr[1]));
    local msgArr2 = int32ToBufStr(tonumber(msgArr[2]));
    local strPos = "";

    -- 解析招募位置
    if msgArr[3] ~= "" then
        strPos = msgArr[3];

        local posArr = string.split(strPos, ",");
        local lstStr = {};
        for _, v in ipairs(posArr) do
            table.insert(lstStr, Client.GetTableData("SocialCardExpertArea", tonumber(v) + 1).ExpertArea);
        end
        strPos = table.concat(lstStr, ",");
    else
        -- 任意
        strPos = Client.GetTableData("LocalizeRes", 4988).TextValue;
    end

    --local msgArr1 = {string.byte(msgArr[1], 1, string.len(msgArr[1]))};
    --local msgArr2 = {string.byte(msgArr[2], 1, string.len(msgArr[2]))};
    --log_tree("1111", msgArr1);
    
    resultMsg = resultMsg .. BP_ARRAY_TypeModelList[msgArr1[1]+1] .. "(" .. BP_ARRAY_PerspectiveList[msgArr1[2]+1] .. ")";
    --判断模式，0是经典模式，1是娱乐模式
    if msgArr1[1] == 0 then
        local mapStr = ARRAY_MapJdList[msgArr2[1]+1];
        local times = 1;
        for i = 2 , #msgArr2 do
            if msgArr2[1] ~= msgArr2[i] and msgArr2[i] >= i-1 then
                if times >= 3 then
                    mapStr = mapStr .. "..."
                else
                    mapStr = mapStr .. ', ' .. ARRAY_MapJdList[msgArr2[i]+1];
                end
                times = times + 1;
            end
        end
        resultMsg = resultMsg .. "|" .. mapStr;
    elseif msgArr1[1] == 1 then
        local mapStr = ARRAY_MapYlList[msgArr2[1]+1];
        local times = 1;
        for i = 2 , #msgArr2 do
            if msgArr2[1] ~= msgArr2[i] and msgArr2[i] >= i-1 then
                if times >= 3 then
                    mapStr = mapStr .. "..."
                else
                    mapStr = mapStr .. ', ' .. ARRAY_MapYlList[msgArr2[i]+1];
                end
                times = times + 1;
            end
        end
        resultMsg = resultMsg .. "|" .. mapStr;
    else
        resultMsg = resultMsg .. "|" .. ARRAY_MapHdList[msgArr2[1]+1];
    end
    resultMsg = resultMsg .. "|" .. BP_ARRAY_VoiceTypeList[msgArr1[3]+1];
    resultMsg = resultMsg .. "|" .. msgArr1[4] .. "/4";
    resultMsg = resultMsg .. "|" .. strPos;
    return resultMsg;
end
    
function FuncUtil.GetMapNames(msgArr, MapDict)
    local mapStr = "";
    local times = 1;
    local hasMap = false;
    for i = 1 , #msgArr do
        local groupId = msgArr[i];
        if groupId ~= 0 then
            if times >= 3 then
                mapStr = mapStr .. "..."
            elseif MapDict[groupId] ~= nil and MapDict[groupId].name ~= nil then
                if hasMap == true then
                    mapStr = mapStr .. ', ' .. MapDict[groupId].name;
                else
                    mapStr = MapDict[groupId].name;
                end
                hasMap = true;
                times = times + 1;
            end
        end
    end
    return mapStr;
end

-- 组队招募地图信息
function FuncUtil.TeamRecruitMap(msg, mapData)
    if #BP_ARRAY_MapJdList == 0 or #BP_ARRAY_MapYlList == 0 then
        RecruitUI.MapIdList();
    end

    local msgArr = string.split(msg, "-");
    local resultMsg = "";
    --解码
    local msgArr1 = int32ToBufStr(tonumber(msgArr[1]));
    local strPos = "";
    
    -- 解析招募位置
    if msgArr[3] ~= "" then
        strPos = msgArr[3];

        local posArr = string.split(strPos, ",");
        local lstStr = {};
        for _, v in ipairs(posArr) do
            table.insert(lstStr, Client.GetTableData("SocialCardExpertArea", tonumber(v) + 1).ExpertArea);
        end
        strPos = table.concat(lstStr, ",");
    else
        -- 任意
        strPos = Client.GetTableData("LocalizeRes", 4988).TextValue;
    end

    resultMsg = resultMsg .. BP_ARRAY_TypeModelList[msgArr1[1]+1] .. " (" .. BP_ARRAY_PerspectiveList[msgArr1[2]+1] .. ")";
    --判断模式，0是经典模式，1是娱乐模式
    local Pve_Map = nil;
    if msgArr1[1] == 0 then
        local mapStr = FuncUtil.GetMapNames(mapData, MapJdDict);;
        resultMsg = resultMsg .. "|" .. mapStr;
    elseif msgArr1[1] == 1 then
        local mapStr = FuncUtil.GetMapNames(mapData, MapYlDict);;
        resultMsg = resultMsg .. "|" .. mapStr;
    else
        local mapStr = FuncUtil.GetMapNames(mapData, MapHdDict);;
        resultMsg = resultMsg .. "|" .. mapStr;
        Pve_Map = mapData;
    end
    resultMsg = resultMsg .. "|" .. BP_ARRAY_VoiceTypeList[msgArr1[3]+1];
    resultMsg = resultMsg .. "|" .. msgArr1[4] .. "/4";
    resultMsg = resultMsg .. "|" .. strPos;
    return resultMsg, Pve_Map;
end


local function LevelVaild(map_data, map_Dict)
    for index,groupId in pairs(map_data) do
        if groupId ~= 0 and map_Dict[groupId] then
            local pvpLevel = map_Dict[groupId].level or 0;
            local pveLevel = map_Dict[groupId].pve_level or 0;
            if DataMgr.roleData.pve_level >= pveLevel and DataMgr.roleData.level >= pvpLevel then
                return true;
            end
        end
    end
    return false;
end

--组队招募当前pve等级是否满足
function FuncUtil.LevelEnough(map_data)
    if #BP_ARRAY_MapJdList == 0 or #BP_ARRAY_MapYlList == 0 then
        RecruitUI.MapIdList();
    end

    --经典模式
    local jdValid = LevelVaild(map_data, MapJdDict);
    local ylValid = LevelVaild(map_data, MapYlDict);
    local hdValid = LevelVaild(map_data, MapHdDict);
    log("LevelEnough jd:"..tostring(jdValid).." yl:"..tostring(ylValid).." hd:"..tostring(hdValid))
    return jdValid or ylValid or hdValid;
end

local UID_TPPE_GLOBAL = 5;  -- 全球服UID的第一个数字
local UID_TYPE_JPKR = 6;    -- 日韩服UID的第一个数字

function FuncUtil.IsUidGlobal(uid) 
    return (tonumber(string.sub(uid, 1, 1)) == UID_TPPE_GLOBAL);
end

function FuncUtil.IsUidJPKR(uid)  
    return (tonumber(string.sub(uid, 1, 1)) == UID_TYPE_JPKR);
end

-- 玩家自己是否为日本服
function FuncUtil.IsPlayerJP()
    local strRegion = Client.GetPublishRegion();
    if strRegion == "JAPAN" then
        return true;
    end
    return false;
end

-- 玩家自己是否为日韩服
function FuncUtil.IsPlayerJPKR()
    local strRegion = Client.GetPublishRegion();
    if strRegion == "JAPAN" or strRegion == "KOREA" then
        return true;
    end
    return false;
end

-- 根据地区（全球、日、韩）获取数据
function FuncUtil.GetWithRegion(globalData, japanData, koreaData)
    local strRegion = Client.GetPublishRegion();
    if strRegion == "KOREA" then
        return koreaData;
    elseif strRegion == "JAPAN" then
        return japanData;
    end
    return globalData;
end

-- 获取登录类型
function FuncUtil.GetLoginTypeList(arrLoginType)

    local strRegion = Client.GetPublishRegion() ;
	--log("GetLoginTypeList strRegion:"..strRegion);
    -- 先清空
    arrLoginType = {};

    local cfg = FuncUtil.GetLoginTypeTable(strRegion);
    if cfg ~= nil then

        -- facebook 插入到排序列表
        if (cfg.facebook ~= "0" and cfg.facebook ~= 0) then
            local index = tonumber(cfg.facebook);
            arrLoginType[index] = "facebook";
        end

        -- twitter 插入到排序列表
        if (cfg.twitter ~= "0" and cfg.twitter ~= 0) then
            local index = tonumber(cfg.twitter);
            arrLoginType[index] = "twitter";
        end

        -- wechat 插入到排序列表
        if (cfg.wechat ~= "0" and cfg.wechat ~= 0) then
            local index = tonumber(cfg.wechat);
            arrLoginType[index] = "wechat";
        end

        -- vk 插入到排序列表
        if (cfg.vk ~= "0" and cfg.vk ~= 0) then
            local index = tonumber(cfg.vk);
            arrLoginType[index] = "vk";
        end

        -- gpgc 插入到排序列表
        if (cfg.gpgc ~= "0" and cfg.gpgc ~= 0) then
            local index = tonumber(cfg.gpgc);
            arrLoginType[index] = "gpgc";
        end

        -- Line 插入到排序列表
        if (cfg.line ~= "0" and cfg.line ~= 0) then
            local index = tonumber(cfg.line);
            arrLoginType[index] = "line";
        end

        -- qq 插入到排序列表
        if (cfg.qq ~= "0" and cfg.qq ~= 0) then
            local index = tonumber(cfg.qq);
            arrLoginType[index] = "qq";
        end

        --游客 插入到排序列表
        if (cfg.guest ~= "0" and cfg.guest ~= 0 and strRegion ~= "KOREA" and strRegion ~= "JAPAN") then
            local index = tonumber(cfg.guest);
            arrLoginType[index] = "guest";
        end
    end

    return arrLoginType;
end

--计算排行榜 前xx.xx%
function FuncUtil.calc_topn_percentage(score, top_1w_score, rank_type)
    --log_tree("FuncUtil.calc_topn_percentage", {score, top_1w_score, rank_type})
    if top_1w_score == nil then
        return nil
    end
    if top_1w_score <= score then
        return nil
    end
    local middle_score = 0
    if rank_type == "win" or rank_type == "beat" then
        middle_score = ((score - 900) / (top_1w_score - 900)) * 5 - 1;
    else
        middle_score = ((score - 1080) / (top_1w_score - 1080)) * 5 - 1;
    end
    local percentage = 1 - math.max(math.min(((1 / (1 + math.exp(-0.65 * middle_score)) - 0.5) * 1.72 + 0.2585), 1), 0);
    
    return string.format(tostring(Client.GetTableData("LocalizeRes", 108036).TextValue), percentage * 100);
end

Global_WindowOB = nil
function GetWindowOBState()
    if Global_WindowOB == nil then
        Global_WindowOB = Client.IsWindowOB();
    end
    return Global_WindowOB;
end

local formatStr = nil;
function FuncUtil.GetItemName(itemName, colorID, patternID)
    --log(string.format("itemName = %s, colorID = %s, patternID = %s", tostring(itemName), tostring(colorID), tostring(patternID)));
    if formatStr == nil then
        formatStr = Client.GetTableData("LocalizeRes", 6227).TextValue;
    end
    -- 暂时只处理颜色
    if colorID ~= nil and colorID ~= 0 then
        local colorCfg = Client.GetTableData("DiySuitColorConfig", colorID);
        if colorCfg then
            return string.format(formatStr, itemName, colorCfg.ColorName);
        end
    end
    return itemName
end

function FuncUtil.Getdaystart_by_tz(time, tz)
    return math.floor((time + tz * 36) / 86400) * 86400 - tz * 36
end

function FuncUtil.GetLanguageTable()
    local strRegion = Client.GetPublishRegion();

    if strRegion == "JAPAN" or strRegion == "KOREA" then
        return Client.GetTable("TransSupportConfig_JK")
    elseif strRegion == "VNG" then
        return Client.GetTable("TransSupportConfig_VNG")
	elseif strRegion == "TW" then
        return Client.GetTable("TransSupportConfig_TW")
    else
        return Client.GetTable("TransSupportConfig_GLOBAL")
    end
end

function FuncUtil.GetRechargeLevelTable()

    local tabledata = nil;
	local strRegion = Client.GetPublishRegion();
	
    if string.lower(Client.GetDevicePlatformName()) == "ios" then
        
        if strRegion == "JAPAN" or strRegion == "KOREA" then
            tabledata = Client.GetTable("RechargeLevel_IOS_JK")
        elseif strRegion == "VNG" then
            tabledata = Client.GetTable("RechargeLevel_IOS_VNG")
        elseif strRegion == "TW" then
            tabledata = Client.GetTable("RechargeLevel_IOS_TW")
        else
            tabledata = Client.GetTable("RechargeLevel_IOS_GLOBAL")
        end

    elseif string.lower(Client.GetDevicePlatformName()) == "android" then
        if strRegion == "JAPAN" or strRegion == "KOREA" then
            tabledata = Client.GetTable("RechargeLevel_Android_JK")
        elseif strRegion == "VNG" then
            tabledata = Client.GetTable("RechargeLevel_Android_VNG")
		elseif strRegion == "TW" then
            tabledata = Client.GetTable("RechargeLevel_Android_TW")
        else
            tabledata = Client.GetTable("RechargeLevel_Android_GLOBAL")
        end
    else
        tabledata = Client.GetTable("RechargeLevel_IOS_GLOBAL")
    end

    return tabledata
end

function FuncUtil.GetLoginTypeTable(Region)
    return Client.GetTableData("LoginTypeListCfg",Region)
end

function FuncUtil.GotoBuyItemInMallSystem(page, itemId, isOpenFromRoleUI)
    local shopId = MallSystem.GetShopId(page, itemId)

    if(shopId == 0) then
        return false
    end
    
    local params = {
        ["Tab1"] = page,
        ["Tab2"] = MallSystem.GetShopTab2(page, itemId),
        ["selectShopId"] = shopId,
        ["isOpenFromRoleUI"] = isOpenFromRoleUI or false,
        ["itemId"] = itemId,
    }
    EventSystem:postEvent(EVENTTYPE_URL, BP_ENUM_MODULE_MALL_CHILD, params)
    return true
end

function FuncUtil.GetRegionConfigTable()
    return Client.GetTable("RegionConfig");
end

function FuncUtil.GetPetSwitch()
    local switch = LobbySystem.LobbyMenuOpenStatus[BP_ENUM_PET_SWITCH];
    if switch ~= nil then
        return switch.is_open == 1
    end
    return true
end

--获取距离当天0点剩余时间
function FuncUtil.getTodayTimeStamp()
    return 86400 - math.fmod(FuncUtil.GetServerTimeInSec(), 86400)
end

--"0.12.0.8888"
function FuncUtil.CompareVersion(ver1, ver2)
    local ver_table1 = FuncUtil:StrSplit(ver1, ".")
    local ver_table2 = FuncUtil:StrSplit(ver2, ".")

    local function CompareIndex(index)
        local ver1 = ver_table1[index]
        local ver2 = ver_table2[index]
        if ver1 == nil and ver2 == nil then
            return 0
        end

        if ver1 == nil then
            return -1
        end

        if ver2 == nil then
            return 1
        end

        if ver1 == ver2 then
            return 0
        else
            return ver1 > ver2 and 1 or -1
        end

    end
    local ver1 = CompareIndex(1)
    local ver2 = CompareIndex(2)
    local ver3 = CompareIndex(3)
    local ver4 = CompareIndex(4)
    if ver1 ~= 0 then
        return ver1
    elseif ver2 ~= 0 then
        return ver2
    elseif ver3 ~= 0 then
        return ver3
    elseif ver4 ~= 0 then
        return ver4
    end
    return 0
end

function FuncUtil.getweekstart_by_tz(time, tz)
    local tz_tmp = 259200 + tz * 36
    return math.floor((time + tz_tmp) / 604800) * 604800 - tz_tmp
end

function FuncUtil.issameweek_by_tz(time1, time2, tz)
    return FuncUtil.getweekstart_by_tz(time1,tz) == FuncUtil.getweekstart_by_tz(time2, tz)
end