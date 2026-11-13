RefluxMgr = RefluxMgr or
{
	RES_OK = "ok",
}

function RefluxMgr.StartToGetPlatformFriendInfo()
	if UIReflux.HaveGotData == false then
		log("[HHF]RefluxMgr.StartToGetPlatformFriendInfo");
		UIReflux.PLATFriendsRegList = {};
		UIReflux.UIDMapOpenID = {};
		UIReflux.FriendsPage = 1;
		UIReflux.bWaitingCallback = true;
		Client.GetFBFriendsUnregistered(NetInterface, UIReflux.FriendsPage, UIReflux.NumOfFriendsPerPage, UIReflux.FriendsType, "");
	else
		log("[HHF]RefluxMgr.StartToGetPlatformFriendInfo, Have got data!");
	end
end

function RefluxMgr.OnGetFriendsUnreg(page, friendsUnreg)
	if UIReflux.bWaitingCallback == false then
		log("[HHF]RefluxMgr.OnGetFriendsUnreg, unexpected callback and page = " .. page);
		return;
	end

	UIReflux.bWaitingCallback = false;
	if UIReflux.FriendsPage == page then
		local count = FuncUtil:CountTable(friendsUnreg) / UIReflux.NumOfElementsPerFriend;
		log("[HHF]RefluxMgr.OnGetFriendsUnreg, page = " .. page .. ", count = " .. tostring(count));
		local totalCount = FuncUtil:CountTable(UIReflux.PLATFriendsRegList);
		local openIDList = {};
		for i = 1, count do
			local friend = {};
			friend.userID = friendsUnreg["userID" .. i] or "";
			friend.userName = friendsUnreg["userName" .. i] or "";
			friend.headportraitURL = friendsUnreg["headportraitURL" .. i] or "";
			local openID = friendsUnreg["openID" .. i] or "";
			if UIReflux.PLATFriendsRegList[openID] == nil then
				totalCount = totalCount + 1;
			else
				log("[HHF]RefluxMgr.OnGetFriendsUnreg, update openID = " .. openID);
			end
			UIReflux.PLATFriendsRegList[openID] = friend;
			table.insert(openIDList, openID);
		end

		log("[HHF]RefluxMgr.OnGetFriendsUnreg, totalNum = " .. totalCount);
		if totalCount > 0 then
			UIReflux.HaveGotData = true;
			RefluxMgr.GetUIDByOpenID(openIDList);
		end
	elseif page == 0 then
		RefluxMgr.SendRecallFriend(BP_Reflux_Call_Friend_UID);
		log("[HHF]RefluxMgr.OnGetFriendsUnreg, invited success!");
	elseif page == -1 then
		log("[HHF]RefluxMgr.OnGetFriendsUnreg, user canceled!");
	else
		log("[HHF]RefluxMgr.OnGetFriendsUnreg, page = " .. page .. ", but I want page = " .. UIReflux.FriendsPage);
	end
end

function RefluxMgr.GetUIDByOpenID(list)
	--[[for test
	list = {};
	table.insert(list, "67309318178088");
	table.insert(list, "67414880421160");
	table.insert(list, "67453736453416");
	table.insert(list, "67216842163496");
	table.insert(list, "67220264715560");
	table.insert(list, "67265630307624");
	table.insert(list, "67221674001704");
	table.insert(list, "67263214388520");
	table.insert(list, "67218922538280");
	table.insert(list, "67206373180712");
	table.insert(list, "67240934245672");
	table.insert(list, "67220130497832");
	--]]
	log("[HHF]RefluxMgr.GetUIDByOpenID, list.num = " .. #list);
	--log_tree("[HHFTEST]RefluxMgr.GetUIDByOpenID, list = ", list, "[HHFTEST]");
	NetUtil.SendPkg("batch_get_uid_from_openid_for_frd_req", list);
end

function RefluxMgr.batch_get_uid_from_openid_for_frd_rsp(res, list)
	log("[HHF]RefluxMgr.batch_get_uid_from_openid_for_frd_rsp, res = " .. tostring(res) .. ", list.num = " .. FuncUtil:CountTable(list));
	if res == "ok" then
		for k, v in pairs(list) do
			UIReflux.UIDMapOpenID[tostring(k)] = v;
		end
		--log_tree("[HHFTEST]RefluxMgr.batch_get_uid_from_openid_for_frd_rsp, UIReflux.UIDMapOpenID = ", UIReflux.UIDMapOpenID, "[HHFTEST]");
		UIReflux.FilterFriendsByITOP(true);
	elseif (res == "invalid-param") then
		--DataMgr.ShowNoticeByID(200067);
		--DataMgr.ShowNoticeByString("数组长度不正确");
	elseif (res == "db-error") then
		--DataMgr.ShowNoticeByID(200068);
		--DataMgr.ShowNoticeByString("系统错误");
	elseif (res == "not-exist") then
		--DataMgr.ShowNoticeByString("一个都查不到");
	else
		--DataMgr.ShowNoticeByID(200069);
		--DataMgr.ShowNoticeByString("查询uid失败");
	end
end

function RefluxMgr.SendGetRefluxInfo()
	log("[HHF]RefluxMgr.SendGetRefluxInfo, Send friend_recall_get_info_req");
	NetUtil.SendPkg("friend_recall_get_info_req")
end

function RefluxMgr.friend_recall_get_info_rsp(res, data)
    log("[HHF]RefluxMgr.friend_recall_get_info_rsp, received friend_recall_get_info_rsp, res = " .. res);
	if res == RefluxMgr.RES_OK then
		--log_tree("[HHFTEST]RefluxMgr.friend_recall_get_info_rsp, data = ", data, "[HHFTEST]")
		UIReflux.OnGetRefluxFriendList(data.sns_fri_list, data.ext)
		UIReflux.OpenUI()
	else
		-- 其他服务器错误
		-- log("RefluxMgr:friend_recall_get_info_rsp error!")
		DataMgr.ShowNoticeByID(tonumber(res))
    end
end

function RefluxMgr.SendRecallFriend(uid)
	log("[HHF]RefluxMgr.SendRecallFriend, send friend_recall_req, uid = " .. uid);
	NetUtil.SendPkg("friend_recall_req", uid)
end

function RefluxMgr.friend_recall_rsp(res, uid)
	log("[HHF]RefluxMgr.friend_recall_rsp, res = " .. res .. ", uid = " .. uid);	
	if res == RefluxMgr.RES_OK then
		UIReflux.UpdateFriendInviteStatus(uid) 
	else
		-- 其他服务器错误
		-- log("RefluxMgr:friend_recall_rsp error!")
		DataMgr.ShowNoticeByID(tonumber(res))
	end
end

function RefluxMgr.SenGetRecallAward(idx)
	log("[HHF]RefluxMgr.SenGetRecallAward, idx = " .. idx);	
    NetUtil.SendPkg("friend_recall_award_req", idx)
end

function RefluxMgr.friend_recall_award_rsp(res, idx, itemlist)
	log("[HHF]RefluxMgr.friend_recall_award_rsp, res = " .. res .. ", idx = " .. idx .. ", itemlist.num = " .. FuncUtil:CountTable(itemlist));
	--log_tree("[HHFTEST]RefluxMgr.friend_recall_award_rsp, item = ", itemlist, "[HHFTEST]") 
    if res == RefluxMgr.RES_OK then
		UIReflux.SetAwardGet(idx)
		local arrayItemData = {}
		for index, dropData in ipairs(itemlist) do
			table.insert(arrayItemData, { res_id = dropData.res_id, count = dropData.count, valid_hours = dropData.valid_hours })
		end

		CommonItemGetUI:ShowPanel(arrayItemData)
    else
		DataMgr.ShowNoticeByID(tonumber(res))
    end
end

function RefluxMgr:notify_refresh_recall_frd()
    -- if res == RefluxMgr.RES_OK then
	-- 	log_tree("Reflux info = ", data)
	-- 	UIReflux.OnGetRefluxFriendList(data.sns_fri_list, data.ext)
	-- 	UIReflux.OpenUI()
	-- elseif res == "invite-repeat" or res == "send-repeat" then
	-- 	DataMgr.ShowNoticeByID(9990003)
	-- elseif res == "send-failed" then
	-- 	DataMgr.ShowNoticeByID(9990004)
	-- else
	-- 	-- 其他服务器错误
	-- 	log("RefluxMgr:friend_recall_get_info_rsp error!")
	-- 	DataMgr.ShowNoticeByID(106036)
    -- end
end

function RefluxMgr.GetRefluxAwards()
	log("[HHF]RefluxMgr.GetRefluxAwards, send friend_recall_player_award_req");
	NetUtil.SendPriorityPkg(false, "friend_recall_player_award_rsp", "friend_recall_player_award_req");
end

function RefluxMgr.friend_recall_player_award_rsp(res, res_list)
	log("[HHF]RefluxMgr.friend_recall_player_award_rsp, received friend_recall_player_award_rsp, res = " .. tostring(res) .. ", res_list.num = " .. FuncUtil:CountTable(res_list));
	if res == NetErrorCode_NONE then
		CommonItemGetUI:ShowPanel(res_list)
    else
        ShowNotice(res)
    end
end

local getProfileListDelegate = nil

function RefluxMgr.GetProfileList(uidList , del)
	log("[HHF]RefluxMgr.GetProfileList, uidList.num = " .. FuncUtil:CountTable(uidList) .. ", del = " .. tostring(del));
	getProfileListDelegate = del
	ProfileMgr.GetProfileList(uidList, RefluxMgr.OnGetProfileListDone, false, false, nil, true);
end

function RefluxMgr.OnGetProfileListDone( role_basic_info_list )
	log("[HHF]RefluxMgr.OnGetProfileListDone, list.num = " .. FuncUtil:CountTable(role_basic_info_list))
	if getProfileListDelegate ~= nil then
		getProfileListDelegate(role_basic_info_list)
		getProfileListDelegate = nil
	end
end

--[[   
    网络回调
]]
--
s2c["friend_recall_rsp"] = RefluxMgr.friend_recall_rsp
s2c["friend_recall_get_info_rsp"] = RefluxMgr.friend_recall_get_info_rsp
s2c["friend_recall_award_rsp"] = RefluxMgr.friend_recall_award_rsp 
s2c["friend_recall_player_award_rsp"] = RefluxMgr.friend_recall_player_award_rsp 
s2c["batch_get_uid_from_openid_for_frd_rsp"] = RefluxMgr.batch_get_uid_from_openid_for_frd_rsp
