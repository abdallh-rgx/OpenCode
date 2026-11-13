-- 聊天界面分享成就
ChatShareAchievementSystem = ChatShareAchievementSystem or
{
	-- chatInited = false;
}	

-- 向服务器发送要分享的成就
function ChatShareAchievementSystem.ShareAchievement(achievementId, chievementName)
	-- log("Share "..tostring(achievementId));


	-- 检查合法性
	local satisfy = LobbyChatLogic.CheckHasRightToChat();
	if (not satisfy) then
		return;
	end

	local achievementData = {};
	for k,v in pairs(BP_ARRAY_ChatAchievementList) do
		if v.id == achievementId then
			achievementData = v;
			break;
		end
	end

	-- 组队招募频道不能分享
	if BP_AchievementShareChannel == LobbyChatSystem.channelTeamRecruit then
		return;
	end

	-- local receiver = BP_AchievementShareReceiverId;
	local receiver = BP_AchievementShareReceiverId;
	if BP_ChannelType == LobbyChatSystem.channelPrivate then
		receiver = tonumber(BP_ReceiverGID);
	end
	local channel = BP_AchievementShareChannel;
	
	local content = FuncUtil.GetLocalizeResStr("5027");
	-- content = string.format(content, "AAAA", "BBB");
	-- local content = "A1 <a id=$$GDPRHyperLink$$ style=$$GDPRLink$$ url=$$CustomerService$$>B</> C";

	local topicId = BP_AchievementShareTopicId;
	local selectPlayer = BP_AchievementShareSelectPlayer;
	local topicList = BP_AchievementShareTopicList;
	local msgType = 14;
	local other = {};
	other.achievementId = achievementId;
	other.finish_time = achievementData.finish_time;
	-- local msgType = 0;
	channel = LobbyChatSystem.GetChannelType(channel, topicId);
	-- log_tree("data", achievementData);
	LobbyChatSystem.on_chat_req(receiver, channel, content, topicId, selectPlayer, topicList, other, msgType);

end