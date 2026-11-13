OfficialInfoUI = OfficialInfoUI or 
{
	isShow = false;
}

BP_STRUCT_OfficialInfo =
{
    channel=0,		--
	lowVersion = "",--最低版本号
	gameId = 0,		--
    language = "",		--语言
    link = "",		--官媒链接
    name = "",		--官媒名称
    icon = "",		--官媒图标
};

--官媒数据列表
BP_ARRAY_OfficialInfoData =
{
    BP_STRUCT_OfficialInfo = _G.BP_STRUCT_OfficialInfo, --定义结构体数组，这种写法要作为规范规定下来
}

function bp_official_info_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_official_info,
		{
			{Path="/Game/UMG/UI_BP/Lobby/Lobby_OfficialInfo_LogicBP.Lobby_OfficialInfo_LogicBP_C", Container="Top", ZOrder=BP_ENUM_UI_OFFICIAL_INFO},
		},
		{"Lobby"},
		false,
        false,
		true
	);
	--LuaClassObj.SubShowHideEvent(bp_faceteam, { "ZhiboChoice_Item_BP_C" });	
	--EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_FRIEND, LobbyFriendUI.Show);
end

--打开社交平台面板
function OfficialInfoUI:OpenCreateOfficialInfoPanel()
	--log("OfficialInfoUI:OpenCreateOfficialInfoPanel")
	LuaClassObj.HandleDynamicCreation(bp_official_info);
	LobbyOfficialInfoSystem.Entry();
	LuaClassObj.HandleUIMessage(bp_official_info, "ShowOfficialInfoPanel");
	
end

--打开选择社交平台面板
function EventClickChannelBtn(buttonIndex)
	--LuaClassObj.HandleUIMessage(bp_official_info, "ShowOfficialInfoPanel");
end
function EventClickChannelBtn1()
	--log("EventClickChannelBtn1");
	LobbyOfficialInfoSystem.ShowOfficialInfoWebView(1);
end
function EventClickChannelBtn2()
	--log("EventClickChannelBtn2");
	LobbyOfficialInfoSystem.ShowOfficialInfoWebView(2);
end
function EventClickChannelBtn3()
	--log("EventClickChannelBtn3");
	LobbyOfficialInfoSystem.ShowOfficialInfoWebView(3);
end
function EventClickChannelBtn4()
	--log("EventClickChannelBtn4");
	LobbyOfficialInfoSystem.ShowOfficialInfoWebView(4);
end
function EventClickChannelBtn5()
	--log("EventClickChannelBtn5");
	LobbyOfficialInfoSystem.ShowOfficialInfoWebView(5);
end
function EventClickChannelBtn6()
	--log("EventClickChannelBtn6");
	LobbyOfficialInfoSystem.ShowOfficialInfoWebView(6);
end