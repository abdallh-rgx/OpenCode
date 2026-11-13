

ChatTopicLanguage = ChatTopicLanguage or {
}

--当前话题语言
BP_TopicLanguage = 0;

--可选择语言列表
BP_ARRAY_LanguageNameList = {
	"",
}

function bp_chat_topic_language_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_chat_topic_language,
		{
			{Path="/Game/UMG/UI_BP/LobbyChat/Chat_language.Chat_language_C", Container="Default", ZOrder=BP_ENUM_UI_CHAT_TOPIC_LANGUAGE_ZORDER},
		},
		{"Lobby"},
		false,
		false,
		true
	);
end

--显示UI
function ChatTopicLanguage.ShowUI()
	LuaClassObj.HandleDynamicCreation(bp_chat_topic_language);
	LuaClassObj.HandleUIMessage(bp_chat_topic_language, "UIShow");
end

function EventOnChange()
	EventOnTopicLanguageChange()
end
