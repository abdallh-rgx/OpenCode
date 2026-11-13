--[[
 第一、第二语言选择相关逻辑，聊天、匹配
]]--

LanguageSelectSystem = LanguageSelectSystem or
{
    secondDefautLanguageName = "";    --默认第二语言，none
}

-- 初始化默认第二语言
function LanguageSelectSystem.Init()
    LanguageSelectSystem.secondDefautLanguageName = Client.GetTableData("LocalizeRes", "5201").TextValue;
end;

-- 聊天拉取语言信息列表
function LanguageSelectSystem.PopForbidTipLanguage()
	DataMgr.ShowNoticeByID("5043");
end

function LanguageSelectSystem.GetLanguage()
    local id1, id2;
    for i,v in ipairs(BP_ChatLanguageDataList) do
        if v.langName == BP_CHAT_LANGUAGE_SELECTED_1 then
            id1 = v.id;
        end
        if v.langName == BP_CHAT_LANGUAGE_SELECTED_2 then
            id2 = v.id;
        end
    end
    return id1, id2;
end



-- 拉取语言信息列表回包
function LanguageSelectSystem.topic_fetch_lang_list_rsp(list, timeSpan)
	
end

-- 聊天第一、第二语言修改请求
function LanguageSelectSystem.ChatLanguageSelectReq(id1, id2)
    --log("chat id1:"..tostring(id1).." id2:"..tostring(id2))
	if nil ~= id1 then  -- 第一语言不能为空
        NetUtil.SendPkg("set_player_langs_req", id1, id2);
    end
end

-- 聊天第一、第二语言修改回包
function LanguageSelectSystem.set_player_langs_rsp(err_code ,data)
    log_tree("set_player_langs_rsp"..tostring(err_code),data);
    if err_code == 0 then
        DataMgr.FirstSecondLanguage = data;
    end
    
    if (LobbyChatLogic.isShowing == true) then
        LobbyChatLogic.OnSecondLanguageChange();
    end
end

-- 聊天第一、第二语言修改请求
function LanguageSelectSystem.MatchLanguageSelectReq(id1, id2, onlymatch)
    log("match id1:"..tostring(id1).." id2:"..tostring(id2))
    if nil ~= id1 then  -- 第一语言不能为空
        NetUtil.SendPkg("set_player_match_langs_req", id1, id2, onlymatch);
    end
end

-- 匹配第一、第二语言修改回包
function LanguageSelectSystem.set_player_match_langs_rsp(err_code ,data)
    log_tree("set_player_match_langs_rsp:",data);
    if err_code == 0 then
        DataMgr.MatchLanguage = data;
    end
    MatchPopupUI.SetLanguageSet();  -- 语言修改了通知匹配界面修改语言
end

--[[网络回调]]--
s2c = s2c or {};
s2c["set_player_langs_rsp"] = LanguageSelectSystem.set_player_langs_rsp;				-- 聊天语言回包
s2c["set_player_match_langs_rsp"] = LanguageSelectSystem.set_player_match_langs_rsp;	-- 匹配语言回包
-----------------intl end-------------------