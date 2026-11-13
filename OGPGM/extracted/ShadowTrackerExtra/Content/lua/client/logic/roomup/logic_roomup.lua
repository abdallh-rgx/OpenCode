--[[
 房间招募相关逻辑
]]--

RoomUpSystem = RoomUpSystem or
{
	msgIdGuid = 0;--msgId全局唯一标识符
	msgContentCacheMap =  --缓存发送的消息，服务器不再回发给发送者
	{
		--msgId = msgContent,
	};
}

function RoomUpSystem.CacheMsg(tabContent)
	RoomUpSystem.msgIdGuid = RoomUpSystem.msgIdGuid + 1;
	RoomUpSystem.msgContentCacheMap[RoomUpSystem.msgIdGuid] = tabContent;
	return RoomUpSystem.msgIdGuid;
end

-- 发送房间招募
function RoomUpSystem.RoomRecruitReq()
	log_tree("RoomSystem.RoomInfoList",RoomSystem.CurrentRoomInfo);
	NetUtil.SendPkg("room_recruit_req");
end

-- 接收房间招募回包
--time_left    请求频繁时返回还剩余多少秒可以请求
function RoomUpSystem.room_recruit_rsp(ret, time_left, chat_content)
	log_tree("room_recruit_rsp", chat_content);

	if ret == "ok" then
		local sender_name = DataMgr.roleData.nickName;
		local sender_uid = DataMgr.roleData.uid;		
		local zone_id = RoomSystem.CurrentRoomInfo.zone_id;		
		local msg_type = chat_content.msgType;
	    local nation = ProfileMgr.GetRoleNationByUid(sender_uid);
		local room_id = chat_content.room_id;
		local map_id = chat_content.map_id;		
		local player_num = chat_content.player_num;
		local max_player_num = chat_content.max_player_num;
		local content = RoomUpSystem.CombineRoomRecruitMsg(map_id, player_num, max_player_num);	-- 房间招募拼接消息
		local avatarData = LobbyChatLogic.GetHeadData(sender_uid)
		LobbyChatLogic.AddNewChat(LobbyChatSystem.channelTeamRecruit, msg_type, sender_name, "", 0, content, sender_uid, true, room_id, "", "", nation, nil, nil, nil, avatarData);
		LobbyChatEntranceUI.ReceiveNewMsg(LobbyChatSystem.channelTeamRecruit, msg_type, sender_name, "", 0, "", "", true);
	elseif ret == "request_frequent" then
		local msgContent = string.format(Client.GetTableData("LocalizeRes", "100007").TextValue, time_left);
		DataMgr.ShowNoticeByString(msgContent);		
	end
end

-- 接受招募免密进入房间
function RoomUpSystem.JoinRoomReq(room_id)
	if true == BP_Room_IsInRoom then	-- 在房间中不重复进入房间
		PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", "117071").TextValue);		
	else
		NetUtil.SendPkg("join_room_request", tonumber(room_id), nil, "chat");
	end
end

-- 组合聊天消息
function RoomUpSystem.CombineRoomRecruitMsg(map_id, player_num, max_player_num)
	local local_map = Client.GetTableData("Map", map_id);
	if nil ~= local_map then
		local mode = local_map.MapName;
		--Client.GetTableData("LocalizeRes",100048).TextValue; 	-- 经典模式
		local fpp = "("..Client.GetTableData("LocalizeRes",100054).TextValue..")|";	-- 第三人称

		if  local_map.IsFpp == 1 then
			fpp = "|";
			--Client.GetTableData("LocalizeRes",100053).TextValue;		-- 第一人称
		end
		-- 拼装房间招募信息
		local msg_content = mode..fpp..local_map.WatchingName.."||"..tostring(player_num).."/"..tostring(max_player_num).."|";
		return msg_content;
	else
		log("map config is error, map id is:"..tostring(map_id));
	end
	return "|||"..tostring(player_num).."/"..tostring(max_player_num).."|";
end

s2c["room_recruit_rsp"] = RoomUpSystem.room_recruit_rsp;
-----------------intl end-------------------