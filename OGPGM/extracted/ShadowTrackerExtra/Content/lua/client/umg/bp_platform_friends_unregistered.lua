PlatformFriendsUnregisteredUI = PlatformFriendsUnregisteredUI or 
{
	HaveGotData = false;			-- 是否收到足够数据
	NumOfFriendsWillBeGeted = 50;	-- 总共拉取多少个
	FriendsPage = 1;				-- 当前拉取批次
	NumOfFriendsPerPage = 50;		-- 每批多少个
	NumOfElementsPerFriend = 4;		-- 拉取回调数据项数
	PLATFriendsUnregList = {};		-- 未注册游戏的FB好友

	NumOfFriendsToBeShowed = 9;		-- 界面显示的好友数
	StartIndex = 1;					-- 当前显示起始序列号
	EndIndex = 50;					-- 当前显示末尾序列号
	PLATInvitingFriends = {};		-- 当前邀请的好友
	ActivityID = 0;
	FriendsType = 1;				-- 未注册游戏的FB好友
}

BP_IPFU_CurrentUserID = "";
BP_IPFU_CurrentInviteState = true;
BP_IPFU_AllInviteState = true;
BP_IPFU_ActivityTime = "";
BP_IPFU_NumOfAllInvitedFriends = 0;
BP_IPFU_CurrentRequestAwardIndex = 0;

BP_STRUCT_PLATInviteTarget = 
{
	target = 0;
	status = 0;
	itemID = 0;
	itemNum = 0;
	itemImage = "";
}

BP_ARRAY_PLATInviteTargetList = 
{
	BP_STRUCT_PLATInviteTarget = _G.BP_STRUCT_PLATInviteTarget;
}

BP_STRUCT_PLATFriendsUnregInfo = 
{
	userID = "";
	userName = "";
	headportraitURL = "";
}

BP_STRUCT_PLATFriendsUnregShowInfo = 
{
	userID = "";
	userName = "";
	headportraitURL = "";
	invite = true;
}

BP_ARRAY_PLATFriendsUnregShowList = 
{
	BP_STRUCT_PLATFriendsUnregShowInfo = _G.BP_STRUCT_PLATFriendsUnregShowInfo;
}

BP_ARRAY_PLATFriendsHaveInvited = 
{
	userID = "";
}


function bp_platform_friends_unregistered_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_platform_friends_unregistered,
								{{Path="/Game/UMG/UI_BP/Lobbypromoters/Lobbypromoters_UIBP.Lobbypromoters_UIBP_C", Container="Default", ZOrder=BP_ENUM_UI_ACTIVITY_GROUP_ZORDER}},
								{"Lobby"},
								false,
								false,
								true);
end

function PlatformFriendsUnregisteredUI.OnJumpUrl(eventType, eventID, vars)
    log("[HHF]PlatformFriendsUnregisteredUI.OnJumpUrl, eventType = " .. tostring(eventType) .. ", eventID = " .. tostring(eventID) .. ", vars = " .. tostring(vars));
    local result = PlatformFriendsUnregisteredUI.PrepareActivityData();
    if result == true then
	    PlatformFriendsUnregisteredUI.ShowUI();
	    PlatformFriendsUnregisteredUI.StartToGetData();
    else
    	PopUpNoticeUI.ShowNewNotice(FuncUtil.GetLocalizeResStr("430104"));
    end
end

function PlatformFriendsUnregisteredUI.PrepareActivityData()
	local actData = PlatformFriendsUnregSystem.GetActivityData();
    if actData == nil then
        log("[HHF]PlatformFriendsUnregisteredUI.PrepareActivityData, missing activity data");
        return false;
    else
    	local text = FuncUtil.GetLocalizeResStr("660018");
        local startTime = FuncUtil.SecToDateString(actData.StartTime);
        local endTime = FuncUtil.SecToDateString(actData.EndTime);
        BP_IPFU_ActivityTime = string.format(text, startTime, endTime);
        PlatformFriendsUnregisteredUI.ActivityID = actData.ID;
        log("[HHF]PlatformFriendsUnregisteredUI.PrepareActivityData, ID = " .. actData.ID .. ", time = " .. BP_IPFU_ActivityTime);

        BP_IPFU_NumOfAllInvitedFriends = actData.invite_total_count;

        BP_ARRAY_PLATInviteTargetList = {};
        for k, v in pairs(actData.List) do
        	local temp = {};
        	temp.target = v.Total;
        	temp.status = v.Status;
        	for k1, v1 in pairs(v.Drop) do
        		temp.itemID = v1.itemId;
        		temp.itemNum = v1.count;
        		break;
        	end
        	temp.itemImage = PlatformFriendsUnregisteredUI.GetItemImageByID(temp.itemID, temp.status);
        	table.insert(BP_ARRAY_PLATInviteTargetList, temp);
        end
        --log_tree("[HHF]PlatformFriendsUnregisteredUI.PrepareActivityData, target info = ", BP_ARRAY_PLATInviteTargetList, "[HHF]");

        return true;
    end
end

function PlatformFriendsUnregisteredUI.GetItemImageByID(id, status)
	log("[HHF]PlatformFriendsUnregisteredUI.GetItemImageByID");
	local itemInfo = Client.GetTableData("Item", id);
	if itemInfo ~= nil then
		return itemInfo.ItemBigIcon;
	else
		log("[HHF]PlatformFriendsUnregisteredUI.GetItemImageByID, use Default");
		if status == 2 then
			return "/Game/Arts/UI/TableIcons/Task_Icon/Box/Task_icon_box_1_1.Task_icon_box_1_1";
		else
			return "/Game/Arts/UI/TableIcons/Task_Icon/Box/Task_icon_box_1.Task_icon_box_1";
		end
	end
end

function PlatformFriendsUnregisteredUI.ResetData()
	log("[HHF]PlatformFriendsUnregisteredUI.ResetData");
	PlatformFriendsUnregisteredUI.HaveGotData = false;
	BP_ARRAY_PLATFriendsHaveInvited = {};
	BP_ARRAY_PLATFriendsUnregShowList = {};
	PlatformFriendsUnregisteredUI.PLATFriendsUnregList = {};
end

--[[
@param page     分页数
@param count    每页记录条数
@param type     好友类型：-1：表示兼容老接口；0：同玩好友；1：非同玩好友
--]]
function PlatformFriendsUnregisteredUI.StartToGetData()
	if PlatformFriendsUnregisteredUI.HaveGotData == false then
		log("[HHF]PlatformFriendsUnregisteredUI.StartToGetData");
		BP_ARRAY_PLATFriendsUnregShowList = {};
		PlatformFriendsUnregisteredUI.PLATFriendsUnregList = {};
		PlatformFriendsUnregisteredUI.FriendsPage = 1;
		Client.GetFBFriendsUnregistered(NetInterface, PlatformFriendsUnregisteredUI.FriendsPage, PlatformFriendsUnregisteredUI.NumOfFriendsPerPage, PlatformFriendsUnregisteredUI.FriendsType, "");
	else
		log("[HHF]PlatformFriendsUnregisteredUI.StartToGetData, Have got data!");
		PlatformFriendsUnregisteredUI.UpdateUI();
	end
end

function PlatformFriendsUnregisteredUI.OnGetFriendsUnreg(page, friendsUnreg)
	if PlatformFriendsUnregisteredUI.FriendsPage == page then
		local count = FuncUtil:CountTable(friendsUnreg) / PlatformFriendsUnregisteredUI.NumOfElementsPerFriend;
		log("[HHF]PlatformFriendsUnregisteredUI.OnGetFriendsUnreg, page = " .. page .. ", count = " .. tostring(count));
		local enoughToShow = false;
		local totalCount = #PlatformFriendsUnregisteredUI.PLATFriendsUnregList;
		for i = 1, count do
			local friend = {};
			friend.userID = friendsUnreg["userID" .. i] or "";
			friend.userName = friendsUnreg["userName" .. i] or "";
			friend.headportraitURL = friendsUnreg["headportraitURL" .. i] or "";
			table.insert(PlatformFriendsUnregisteredUI.PLATFriendsUnregList, friend);
			totalCount = totalCount + 1;
			enoughToShow = PlatformFriendsUnregisteredUI.InsertToShowListByFilter(totalCount, friend);
		end

		log("[HHF]PlatformFriendsUnregisteredUI.OnGetFriendsUnreg, totalNum = " .. totalCount);
		if totalCount > 0 then
			PlatformFriendsUnregisteredUI.HaveGotData = true;
			if enoughToShow == false then
				PlatformFriendsUnregisteredUI.UpdateUI();
			end
		end
	elseif page == 0 then
		log("[HHF]PlatformFriendsUnregisteredUI.OnGetFriendsUnreg, invited success!");
		for _, v in pairs(PlatformFriendsUnregisteredUI.PLATInvitingFriends) do
			table.insert(BP_ARRAY_PLATFriendsHaveInvited, v);
		end
		PlatformFriendsUnregSystem.ReportInvitedFriendsNumber(#PlatformFriendsUnregisteredUI.PLATInvitingFriends);
		PlatformFriendsUnregisteredUI.UpdateDataForNextPage(PlatformFriendsUnregisteredUI.StartIndex);
	elseif page == -1 then
		log("[HHF]PlatformFriendsUnregisteredUI.OnGetFriendsUnreg, user canceled!");
	else
		log("[HHF]PlatformFriendsUnregisteredUI.OnGetFriendsUnreg, page = " .. page .. ", but I want page = " .. PlatformFriendsUnregisteredUI.FriendsPage);
	end
end

function PlatformFriendsUnregisteredUI.InsertToShowListByFilter(index, friend)
	if #BP_ARRAY_PLATFriendsUnregShowList >= PlatformFriendsUnregisteredUI.NumOfFriendsToBeShowed then
		log("[HHF]PlatformFriendsUnregisteredUI.InsertToShowListByFilter, have enough data and immediately return.");
		return true;
	else
		local haveInvited = false;
		for _, v in pairs(BP_ARRAY_PLATFriendsHaveInvited) do
			if friend.userID == v then
				haveInvited = true;
				break;
			end
		end

		if haveInvited == false then
			local showInfo = {};
			showInfo.userID = friend.userID;
			showInfo.userName = friend.userName;
			showInfo.headportraitURL = friend.headportraitURL;
			showInfo.invite = BP_IPFU_AllInviteState;
			table.insert(BP_ARRAY_PLATFriendsUnregShowList, showInfo);
			PlatformFriendsUnregisteredUI.UpdateShowIndex(index);
		else
			log("[HHF]PlatformFriendsUnregisteredUI.InsertToShowListByFilter, have been invited friend = " .. friend.userName);
		end

		if #BP_ARRAY_PLATFriendsUnregShowList >= PlatformFriendsUnregisteredUI.NumOfFriendsToBeShowed then
			log("[HHF]PlatformFriendsUnregisteredUI.InsertToShowListByFilter, have enough data and update UI.");
			PlatformFriendsUnregisteredUI.UpdateUI();
			return true;
		else
			return false;
		end
	end
end

function PlatformFriendsUnregisteredUI.UpdateShowIndex(index)
	if #BP_ARRAY_PLATFriendsUnregShowList == 1 then
		PlatformFriendsUnregisteredUI.StartIndex = index;
	elseif #BP_ARRAY_PLATFriendsUnregShowList == PlatformFriendsUnregisteredUI.NumOfFriendsToBeShowed then
		PlatformFriendsUnregisteredUI.EndIndex = index;
	end
end

function PlatformFriendsUnregisteredUI.UpdateDataForNextPage(startIndex)
	log("[HHF]PlatformFriendsUnregisteredUI.UpdateDataForNextPage");
	BP_ARRAY_PLATFriendsUnregShowList = {};
	local totalCount = #PlatformFriendsUnregisteredUI.PLATFriendsUnregList;
	for i = startIndex, totalCount do
		if PlatformFriendsUnregisteredUI.PLATFriendsUnregList[i] == nil then
			log("[HHF]PlatformFriendsUnregisteredUI.UpdateDataForNextPage, " .. i .. " > " .. totalCount);
			break;
		else
			local enough = PlatformFriendsUnregisteredUI.InsertToShowListByFilter(i, PlatformFriendsUnregisteredUI.PLATFriendsUnregList[i]);
			if enough == true then
				return;
			end
		end
	end

	if #BP_ARRAY_PLATFriendsUnregShowList < PlatformFriendsUnregisteredUI.NumOfFriendsToBeShowed then
		for i = 1, startIndex - 1 do
			if PlatformFriendsUnregisteredUI.PLATFriendsUnregList[i] == nil then
				log("[HHF]PlatformFriendsUnregisteredUI.UpdateDataForNextPage, " .. i .. " > " .. totalCount);
				break;
			else
				local enough = PlatformFriendsUnregisteredUI.InsertToShowListByFilter(i, PlatformFriendsUnregisteredUI.PLATFriendsUnregList[i]);
				if enough == true then
					return;
				end
			end
		end
	end

	PlatformFriendsUnregisteredUI.UpdateUI();
end

function PlatformFriendsUnregisteredUI.ShowUI()
	log("[HHF]PlatformFriendsUnregisteredUI.ShowUI");
	LuaClassObj.HandleDynamicCreation(bp_platform_friends_unregistered);
    LuaClassObj.HandleUIMessage(bp_platform_friends_unregistered, "ShowUI");
    LuaClassObj.HandleUIMessage(bp_platform_friends_unregistered, "UpdateActivityInfo");
    EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CHANGE, PlatformFriendsUnregisteredUI.OnActivityChange);
end

function PlatformFriendsUnregisteredUI.UpdateUI()
	log("[HHF]PlatformFriendsUnregisteredUI.UpdateUI");
    LuaClassObj.HandleUIMessage(bp_platform_friends_unregistered, "UpdateUI");
end

function PlatformFriendsUnregisteredUI.OnActivityChange(eventType, eventID, changeList)
	log("[HHF]PlatformFriendsUnregisteredUI.OnActivityChange, eventType = " .. tostring(eventType) .. ", eventID = " .. tostring(eventID));
	--log_tree("[HHF]changeList = ", changeList, "[HHF]");
	
	if changeList.typeList[ActivityType.INVITEFBFRIENDS] == true then 
		PlatformFriendsUnregisteredUI.PrepareActivityData();
    	LuaClassObj.HandleUIMessage(bp_platform_friends_unregistered, "UpdateActivityInfo");
	end
end

function PlatformFriendsUnregisteredUI.HideUI()
	log("[HHF]PlatformFriendsUnregisteredUI.HideUI");
    EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CHANGE, PlatformFriendsUnregisteredUI.OnActivityChange);
    LuaClassObj.HandleUIMessage(bp_platform_friends_unregistered, "HideUI");
end

function EventUpdateAllInviteState()
	log("[HHF]EventUpdateAllInviteState, invite = " .. tostring(BP_IPFU_AllInviteState));
	for _, v in pairs(BP_ARRAY_PLATFriendsUnregShowList) do
		v.invite = BP_IPFU_AllInviteState;
	end

	PlatformFriendsUnregisteredUI.UpdateUI();
end

function EventUpdateOneInviteState()
	log("[HHF]EventUpdateOneInviteState, userID = " .. BP_IPFU_CurrentUserID .. ", invite = " .. tostring(BP_IPFU_CurrentInviteState));
	local found = false;
	for _, v in pairs(BP_ARRAY_PLATFriendsUnregShowList) do
		if v.userID == BP_IPFU_CurrentUserID then
			v.invite = BP_IPFU_CurrentInviteState;
			found = true;
			break;
		end
	end

	if found == true then
		PlatformFriendsUnregisteredUI.UpdateUI();
	else
		log("[HHF]EventUpdateOneInviteState, can not found userID = " .. BP_IPFU_CurrentUserID .. ", unbelievable!" );
	end
end

function EventShowNextPage()
	log("[HHF]EventShowNextPage");
	PlatformFriendsUnregisteredUI.UpdateDataForNextPage(PlatformFriendsUnregisteredUI.EndIndex + 1);
end

function EventInviteSelectedFBFriends()
	PlatformFriendsUnregisteredUI.PLATInvitingFriends = {};
	local paramtable = {};
	paramtable.invitetype = "batch";
	paramtable.userlist = {};
	for _, v in pairs(BP_ARRAY_PLATFriendsUnregShowList) do
		if v.invite == true then
			table.insert(paramtable.userlist, v.userID);
			table.insert(PlatformFriendsUnregisteredUI.PLATInvitingFriends, v.userID);
		end
	end

	if #paramtable.userlist > 0 then
		local title = FuncUtil.GetLocalizeResStr("106052");
		local param = json.encode(paramtable);
		local content = FuncUtil.GetLocalizeResStr("4366");
		if content == "" then
			content = "Tap the link to join me and we'll win together!";
		end
		log("[HHF]EventInviteSelectedFBFriends, param = " .. param);
		Client.InviteFBFriendsUnregistered(NetInterface, title, content, param);
	else
		log("[HHF]EventInviteSelectedFBFriends, no selected friends");
	end

	--[[ for test
	PlatformFriendsUnregisteredUI.OnGetFriendsUnreg(0, nil)
	--]]
end

function EventOnClickIPFUAward()
	log("[HHF]EventOnClickIPFUAward");
	PlatformFriendsUnregSystem.RequestActivityAward(PlatformFriendsUnregisteredUI.ActivityID, BP_IPFU_CurrentRequestAwardIndex);
end

function EventClosePLATUI()
	log("[HHF]EventClosePLATUI");
	PlatformFriendsUnregisteredUI.HideUI();
end

function EventFetchInfo()
	
end