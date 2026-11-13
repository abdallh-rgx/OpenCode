LobbyChatEmojiLogic = LobbyChatEmojiLogic or 
{
	chatEmojiInited = false;
}

BP_ChatEmoji_ClickIndex = 0;

function bp_chat_emoji_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_chat_emoji,
	{
		{Path="/Game/UMG/UI_BP/LobbyChat/LobbyChatEmoji_BP.LobbyChatEmoji_BP_C", Container="Default", ZOrder=BP_ENUM_UI_CHAT_ZORDER + 2}
	},
	{"Lobby"},
	false,
	false,
	true
	);
end

function LobbyChatEmojiLogic.Init()
	if false == LobbyChatEmojiLogic.chatEmojiInited then
		LuaClassObj.HandleDynamicCreation(bp_chat_emoji);
		LuaClassObj.HandleUIMessage(bp_chat_emoji, "UIInit");
	end
	UIManager.Show(eUIType.eChatEmoji);
	--房间等待时层级问题
	--[[if RoomWaitingUI.IsShow then
		LuaClassObj.SetWidgetZorder(bp_chat_emoji,0,50)
	else
		LuaClassObj.RestoreWidgetZorder(bp_chat_main,0)
	end--]]
end

function LobbyChatEmojiLogic.Release()
	LobbyChatEmojiLogic.chatEmojiInited = false;
	LuaClassObj.HandleUIMessage(bp_chat_emoji, "UIRelease");
	--房间等待时层级问题
	--[[if RoomWaitingUI.IsShow then
		LuaClassObj.SetWidgetZorder(bp_chat_emoji,0,50)
	else
		LuaClassObj.RestoreWidgetZorder(bp_chat_main,0)
	end--]]
	UIManager.Hide(eUIType.eChatEmoji);
end

function LobbyChatEmojiLogic.Show()
	LobbyChatEmojiLogic.Init()
	LuaClassObj.HandleUIMessage(bp_chat_emoji, "UIShow");
	UIManager.Show(eUIType.eChatEmoji)

end

function LobbyChatEmojiLogic.Hide()
	LuaClassObj.HandleUIMessage(bp_chat_emoji, "UIHide");
	UIManager.Hide(eUIType.eChatEmoji)
end

function EventClickEmojiItem()
	LobbyChatLogic.OnEmojiItemClicked(BP_ChatEmoji_ClickIndex);
end
