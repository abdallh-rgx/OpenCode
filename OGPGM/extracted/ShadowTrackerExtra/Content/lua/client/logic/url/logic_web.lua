-- 打开外链url专用
WebSystem = WebSystem or {}

-- 获取当前语言
function WebSystem.GetCurrentLanguage()
    local myLanguage = tostring(Client.GetCurrentLanguage());
    if myLanguage == nil then
        myLanguage="en";
    end
    if (myLanguage == "HK")then
        myLanguage = "zh-HK";
    elseif(myLanguage == "TW")then
        myLanguage = "zh-TW";
    end
    return myLanguage;
end

function WebSystem.SignOpenidAndLanguage()
        local SeasonPrivateKey = "XEPPTNsQV5BAkGDA";
        local openid = DataMgr.roleData.openID;
        local language = WebSystem.GetCurrentLanguage();
        local paramList = {
            {key = "openid", val = openid},
            {key = "language", val = language}
        };        
        local signUrl = WebSystem.TableToStringParam(paramList, false);        
        signUrl = string.gsub(signUrl, "&", "", 1);
        local encryptionStr = SeasonPrivateKey .. signUrl .. SeasonPrivateKey;
        local sign = Client.MD5HashAnsiString(encryptionStr);
        log("WebSystem sign:" .. sign);
        return sign;
end

function WebSystem.TableToStringParam(paramList, startWithQuestionMark)
    table.sort(paramList, function(a,b) return a.key < b.key end);
    local param = "";
    local isFirstParam = true;
    local seprate = "";
    for k,v in ipairs(paramList) do
        if startWithQuestionMark and isFirstParam then
            seprate = "?";
            isFirstParam = false;
        else
            seprate = "&";
        end
        param = param .. seprate .. v.key .. "=" .. v.val;   
    end
    return param;
end

--跳转url
-- @paramList 基本可选参数，格式：{"openid","language"}
-- @additionParam 附加参数，格式：{"key1" = value1,"key2" = value2}
-- @need_sign 是否带sign私钥
function WebSystem.OpenURL(url, paramList, need_sign, additionParam)
    if string.starts(url, "http") then
        local paramList2 = {};
        for k,v in pairs(paramList) do
            if v == "openid" then
                local openId = tostring(DataMgr.roleData.openID);
                table.insert(paramList2,{key = "openid", val = openId});
            elseif v == "language" then
                local myLanguage = WebSystem.GetCurrentLanguage();
                table.insert(paramList2,{key = "language", val = myLanguage});
            elseif v == "uid" then  --玩家的角色id                
                local uid = DataMgr.roleData.uid;
                table.insert(paramList2,{key = "uid", val = uid});
            elseif v == "game_season" then   --当前赛季，数据回顾类需求会用到               
                local game_season  = UnknowPassSystem.Season;
                table.insert(paramList2,{key = "game_season", val = game_season});
            elseif v == "gameid" then   --游戏id，比如1320是全球，1321是日韩                
                local gameid = Client.GetITopGameId(NetInterface);
                table.insert(paramList2,{key = "gameid", val = gameid});
            elseif v == "sTicket" then
                --即itop_ticket，h5用来强校验登陆态的重要参数，并可以反解出用户openid
                local ticket = Client.GetWebViewTicket(NetInterface);
                table.insert(paramList2,{key = "sTicket", val = ticket});
            elseif v == "networkType" then
                --用户当前的网络类型：(3G,4G)流量还是wifi;
                --网络类型-int 0 未知; 1 wifi;2 移动网络
                local networkType = 0;
                if Client.HasActiveWifi() then
                    networkType = 1;
                else
                    networkType = 2;
                end
                table.insert(paramList2,{key = "networkType", val = networkType});
            elseif v == "game_area" then
                --用户当前选择的战斗赛区
                local region = LobbySystem.matchZone;
                table.insert(paramList2,{key = "game_area", val = region});
            end
        end

        if need_sign == true then
            --签名（即language和openid的md5值），弱校验
            local sign = WebSystem.SignOpenidAndLanguage();
            table.insert(paramList2,{key = "sign", val = sign});
        end

        if additionParam then
            for k,v in pairs(additionParam) do
                table.insert(paramList2,{key = k, val = v});
            end
        end
        
        local startWithQuestionMark = false;
        if string.find(url, "?") == nil then
            startWithQuestionMark = true;
        end

        local paramUrl = WebSystem.TableToStringParam(paramList2, startWithQuestionMark);
        url = url..paramUrl;            
        log("AppendTokenToUrl url = " .. url);
        Client.OpenURL(url);
    end
end

function WebSystem.PhraseUrlFromIdip(url)
    if string.find(url, "?") == nil then
        return url;
    end
    local sign = WebSystem.SignOpenidAndLanguage();
    local webTicket = Client.GetWebViewTicket(NetInterface)
    local gameID = Client.GetITopGameId();
    local str = url;
    str = string.gsub(str, "{gameid}", gameID, 1)
    str = string.gsub(str, "{itop_openid}", DataMgr.roleData.openID, 1)
    str = string.gsub(str, "{itop_ticket}", webTicket, 1)
    str = string.gsub(str, "{game_season}", DataMgr.season_id, 1)
    str = string.gsub(str, "{game_area}", LobbySystem.matchZone, 1)
    str = string.gsub(str, "{language}", tostring(Client.GetCurrentLanguage()), 1)
    str = string.format("%s&sign=%s",str,sign);
    return str;
end
