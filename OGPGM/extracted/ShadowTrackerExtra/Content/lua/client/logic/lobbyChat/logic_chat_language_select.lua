-- 第二语言选择

ChatLanguageSelectSystem = ChatLanguageSelectSystem or
{
	-- chatInited = false;
}	


-- -- 像服务器要数据
function ChatLanguageSelectSystem.GetLanguageData()
	-- NetUtil.SendPkg("topic_flat_list_req");
	-- return BP_ARRAY_LanguageNameList;

end
-- function LobbyOfficialInfoSystem.Entry()
-- 	if not LobbyChatSystem.canOpenChatWnd then
-- 		return;
-- 	end
	
-- 	LobbyOfficialInfoSystem.RequestData();
-- end

-- function LobbyOfficialInfoSystem.RequestData()	
-- 	NetUtil.SendPkg("get_official_media", securityLog);
-- 	log("get_official_media");
-- end

-- 服务器回包
-- function LobbyOfficialInfoSystem.on_official_media_rsp(ok, media_tb)
-- 	log("LobbyOfficialInfoSystem.on_official_media_rsp");
-- 	--log(media_tb[1].channel);
-- 	--BP_ARRAY_OfficialInfoData = {};

-- 	for k, v in pairs(media_tb) do
-- 		--log_tree("media_tb", v);
-- 		--log("LobbyOfficialInfoSystem.on_official_media_rsp  k= "..k);
-- 		BP_ARRAY_OfficialInfoData[k] = {};
-- 		BP_ARRAY_OfficialInfoData[k].channel = v.channel;
-- 		BP_ARRAY_OfficialInfoData[k].lowVersion = v.lowVersion;
-- 		BP_ARRAY_OfficialInfoData[k].gameId = v.gameId;
-- 		BP_ARRAY_OfficialInfoData[k].language = v.lang;
-- 		BP_ARRAY_OfficialInfoData[k].link = v.link;
-- 		BP_ARRAY_OfficialInfoData[k].name = v.name;
-- 		BP_ARRAY_OfficialInfoData[k].icon = v.icon;
-- 		--log();
-- 		--BP_ARRAY_OfficialInfoData[k].link = v.link;
-- 		--log("LobbyOfficialInfoSystem.on_official_media_rsp  loop!");
-- 	end
-- 	LobbyOfficialInfoSystem.RefreshUI();
-- end

-- -- 根据服务器数据刷新UI
-- function LobbyOfficialInfoSystem.RefreshUI()
-- 	--log("RefreshUI");
-- 	LuaClassObj.HandleUIMessage(bp_official_info, "DownloadIconImage");
-- end

-- -- 点击Icon回调
-- function LobbyOfficialInfoSystem.ShowOfficialInfoWebView(buttonIndex)
-- 	-- 打点
-- 	NetUtil.SendPkg("offical_media_click_log", BP_ARRAY_OfficialInfoData[buttonIndex].name);

-- 	if BP_ARRAY_OfficialInfoData[buttonIndex] == nil then
-- 		log("officialInfoArray[buttonIndex] == nil");
-- 	end
-- 	-- log("button "..buttonIndex.."  link:"..BP_ARRAY_OfficialInfoData[buttonIndex].link);
-- 	GlobalData:JumpUrl(BP_ARRAY_OfficialInfoData[buttonIndex].link);

-- end

--[[网络回调]]--
-- s2c["topic_flat_list_rsp"] = LobbyOfficialInfoSystem.on_official_media_rsp;