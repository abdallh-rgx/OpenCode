--[[
查看官媒链接数据管理
]]--

LobbyOfficialInfoSystem = LobbyOfficialInfoSystem or
{
	chatInited = false;
}	


function LobbyOfficialInfoSystem.Entry()
	if not LobbyChatSystem.canOpenChatWnd then
		return;
	end
	
	LobbyOfficialInfoSystem.RequestData();
end

-- 像服务器要数据
function LobbyOfficialInfoSystem.RequestData()	
	NetUtil.SendPkg("get_official_media");
	-- log("get_official_media");
end

-- 服务器回包
function LobbyOfficialInfoSystem.on_official_media_rsp(ok, media_tb)
	-- log("LobbyOfficialInfoSystem.on_official_media_rsp");
	--log(media_tb[1].channel);
	BP_ARRAY_OfficialInfoData = {};

	for k, v in pairs(media_tb) do
		BP_ARRAY_OfficialInfoData[k] = {};
		BP_ARRAY_OfficialInfoData[k].channel = v.channel;
		BP_ARRAY_OfficialInfoData[k].lowVersion = v.lowVersion;
		BP_ARRAY_OfficialInfoData[k].gameId = v.gameId;
		BP_ARRAY_OfficialInfoData[k].language = v.lang;
		BP_ARRAY_OfficialInfoData[k].link = v.link;
		BP_ARRAY_OfficialInfoData[k].name = v.name;
		BP_ARRAY_OfficialInfoData[k].icon = v.icon;
	end
	LobbyOfficialInfoSystem.RefreshUI();
end

-- 根据服务器数据刷新UI
function LobbyOfficialInfoSystem.RefreshUI()
	LuaClassObj.HandleUIMessage(bp_official_info, "DownloadIconImage");
end

-- 点击Icon回调
function LobbyOfficialInfoSystem.ShowOfficialInfoWebView(buttonIndex)
	-- 打点
	NetUtil.SendPkg("offical_media_click_log", BP_ARRAY_OfficialInfoData[buttonIndex].name);

	if BP_ARRAY_OfficialInfoData[buttonIndex] == nil then
		log("officialInfoArray[buttonIndex] == nil");
	end
	-- log("button "..buttonIndex.."  link:"..BP_ARRAY_OfficialInfoData[buttonIndex].link);
	GlobalData:JumpUrl(BP_ARRAY_OfficialInfoData[buttonIndex].link);

end

--[[网络回调]]--
s2c["get_official_media_rsp"] = LobbyOfficialInfoSystem.on_official_media_rsp;