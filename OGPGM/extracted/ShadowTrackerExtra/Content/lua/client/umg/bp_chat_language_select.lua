--聊天第一、第二语言选择
ChatLanguageSelect = ChatLanguageSelect or
{
}

BP_ARRAY_CHAT_LANGUAGE_SELECT_OPTION1 = {"01", "02", "04"};
BP_ARRAY_CHAT_LANGUAGE_SELECT_OPTION2 = {"03", "05", "07"};

BP_CHAT_LANGUAGE_SELECTED_1 = "";
BP_CHAT_LANGUAGE_SELECTED_2 = "";

--注册Widget
function bp_chat_language_select_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_chat_language_select,
        {{Path="/Game/UMG/UI_BP/LobbyChat/SelectLanguage_BP.SelectLanguage_BP_C", Container="Default", ZOrder=BP_ENUM_UI_CHAT_LANGUAGE_SELECT}},
        {"Lobby"},
        false,
        false,
        true
    );
end

-- 设置语言
local function GetLanguageData()
    BP_ARRAY_CHAT_LANGUAGE_SELECT_OPTION1 = BP_ARRAY_LanguageNameList;
    BP_ARRAY_CHAT_LANGUAGE_SELECT_OPTION2 = FuncUtil:CopyTable(BP_ARRAY_LanguageNameList);
    table.insert(BP_ARRAY_CHAT_LANGUAGE_SELECT_OPTION2, 1, LanguageSelectSystem.secondDefautLanguageName);
    BP_CHAT_LANGUAGE_SELECTED_2 = LanguageSelectSystem.secondDefautLanguageName;

    -- BP_ChatLanguageDataList 数据源来自logic_lobby_chat.topic_fetch_lang_list_rsp
    for i,v in ipairs(BP_ChatLanguageDataList) do
        if v.id == DataMgr.FirstSecondLanguage[1] then
            BP_CHAT_LANGUAGE_SELECTED_1 = v.langName;
        end
        if v.id == DataMgr.FirstSecondLanguage[2] then
            BP_CHAT_LANGUAGE_SELECTED_2 = v.langName;
        end
    end
end

--显示
function ChatLanguageSelect.Show()    
    GetLanguageData();
    LuaClassObj.HandleDynamicCreation(bp_chat_language_select);
    LuaClassObj.HandleUIMessage(bp_chat_language_select, "UIShow");
    ChatLanguageSelect.isShowing = true;
    UIManager.Show(eUIType.eChatLanguageSelect);
end

-- 显示的时候刷新一遍数据
function  ChatLanguageSelect.Refresh()    
    GetLanguageData();
    if ChatLanguageSelect.isShowing then
        LuaClassObj.HandleUIMessage(bp_chat_language_select, "Init");
    end
end

function ChatLanguageSelect.Hide()
    ChatLanguageSelect.isShowing = false;
    LuaClassObj.HandleUIMessage(bp_chat_language_select, "UIHide");
end

function EventHideChatLanguagePanel()
    ChatLanguageSelect.Hide();
end

-- 修改第一第二语言后同步给服务器
function EventSaveChatLanguageSetting()
    local id1, id2;
    for i,v in ipairs(BP_ChatLanguageDataList) do
        if v.langName == BP_CHAT_LANGUAGE_SELECTED_1 then
            id1 = v.id;
        end
        if v.langName == BP_CHAT_LANGUAGE_SELECTED_2 then
            id2 = v.id;
        end
    end
    LanguageSelectSystem.ChatLanguageSelectReq(id1, id2);
end

-- 弹出提示窗（不能选择一样的）
function EventPopForbidTipChatLanguage()
    LanguageSelectSystem.PopForbidTipLanguage();
end

-- 聊天界面打开的时候弹出提示窗,引导玩家去设置面板修改
function ChatLanguageSelect.ShowTips()
    LuaClassObj.HandleUIMessageNoFetch(bp_chat_language_select, "ShowTips");
end