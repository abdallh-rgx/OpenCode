--匹配第一、第二语言选择
MatchLanguageSelect = MatchLanguageSelect or
{
}

BP_ARRAY_MATCH_LANGUAGE_SELECT_OPTION1 = {"01", "02", "04"};
BP_ARRAY_MATCH_LANGUAGE_SELECT_OPTION2 = {"03", "05", "07"};

BP_MATCH_LANGUAGE_SELECTED_1 = "";
BP_MATCH_LANGUAGE_SELECTED_2 = "";

BP_IS_MATCHINFO_LANGUAGE_SELECT_TYPE = false;

--注册Widget
function bp_match_language_select_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_match_language_select,
        {{Path="/Game/UMG/UI_BP/LobbyChat/SelectLanguage_Match_BP.SelectLanguage_Match_BP_C", Container="Default", ZOrder=BP_ENUM_UI_CHAT_LANGUAGE_SELECT}},
        {"Lobby"},
        false,
        false,
        true
    );
end

-- 设置语言
local function GetLanguageData()
    BP_ARRAY_MATCH_LANGUAGE_SELECT_OPTION1 = BP_ARRAY_LanguageNameList;
    BP_ARRAY_MATCH_LANGUAGE_SELECT_OPTION2 = FuncUtil:CopyTable(BP_ARRAY_LanguageNameList);
    table.insert(BP_ARRAY_MATCH_LANGUAGE_SELECT_OPTION2, 1, LanguageSelectSystem.secondDefautLanguageName);
    BP_MATCH_LANGUAGE_SELECTED_2 = LanguageSelectSystem.secondDefautLanguageName;
    
    -- 语言数据使用和聊天一样的数据,数据源logic_lobby_chat.topic_fetch_lang_list_rsp
    for i,v in ipairs(BP_ChatLanguageDataList) do
        if v.id == DataMgr.MatchLanguage[1] then
            BP_MATCH_LANGUAGE_SELECTED_1 = v.langName;
        end
        if v.id == DataMgr.MatchLanguage[2] then
            BP_MATCH_LANGUAGE_SELECTED_2 = v.langName;
        end
    end
end

--显示
function MatchLanguageSelect.Show()    
    GetLanguageData();
    LuaClassObj.HandleDynamicCreation(bp_match_language_select);
    LuaClassObj.HandleUIMessage(bp_match_language_select, "UIShow");
    MatchLanguageSelect.isShowing = true;
    UIManager.Show(eUIType.eMatchLanguageSelect);
end

-- 显示的时候刷新一遍数据
function  MatchLanguageSelect.Refresh()    
    GetLanguageData();
    if MatchLanguageSelect.isShowing then
        LuaClassObj.HandleUIMessage(bp_match_language_select, "Init");
    end
end

function MatchLanguageSelect.Hide()
    MatchLanguageSelect.isShowing = false;
    LuaClassObj.HandleUIMessage(bp_match_language_select, "UIHide");
end

-- 隐藏界面
function EventHideMatchLanguagePanel()
    MatchLanguageSelect.Hide();
end

-- 设置为从匹配界面打开
function MatchLanguageSelect.SetAsMatchInfoType(isMatchInfo)
    BP_IS_MATCHINFO_LANGUAGE_SELECT_TYPE = isMatchInfo;
end

-- 修改第一第二语言后同步给服务器
function EventSaveMatchLanguageSetting()
    log_tree("BP_ChatLanguageDataList",BP_ChatLanguageDataList);
    log("s1:"..tostring(BP_MATCH_LANGUAGE_SELECTED_1).." s2:"..tostring(BP_MATCH_LANGUAGE_SELECTED_2));
    local id1, id2;
    for i,v in ipairs(BP_ChatLanguageDataList) do
        if v.langName == BP_MATCH_LANGUAGE_SELECTED_1 then
            id1 = v.id;
        end
        if v.langName == BP_MATCH_LANGUAGE_SELECTED_2 then
            id2 = v.id;
        end
    end
    LanguageSelectSystem.MatchLanguageSelectReq(id1, id2, BP_IS_MATCHINFO_LANGUAGE_SELECT_TYPE);
end

-- 弹出提示窗（不能选择一样的）
function EventPopForbidTipMatchLanguage()
    LanguageSelectSystem.PopForbidTipLanguage();
end