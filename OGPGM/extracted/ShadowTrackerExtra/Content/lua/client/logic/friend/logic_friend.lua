-- 好友相关逻辑
FriendSystem = FriendSystem or
{
	FetchTimer = 0.0;			----每隔10分钟更新一下好友数据
	FetchTimelength = 600;		----每隔10分钟更新一下好友数据
	FetchTimeStamp = 0;			----点击UI的话，2分钟内更新一下好友数据
	FetchClickTimeLength = 120;	----点击UI的话，2分钟内更新一下好友数据
	HasInit = false;
	NeedRefresh = false;
	HasInitLabelSearchData = false;
	HasInitIntimacyDetailData = false;
	HasInitMatchModeMap = false;

	ClickAgreeBtnTimeStamp = 0; --点击同意按钮的时间戳
	ClickAgreeBtnTimeThreshold = 0.2;--点击同意按钮的时间戳

	ClickIntimacyTabTimeStamp = 0;--点击亲密关系页签的时间戳
	ClickIntimacyTabTimeThreshold = 15;--隔多久再次点击亲密关系页签拉取新数据

	ClickRecentTeammateTabTimeStamp = 0;--点击最近组队页签时间戳
	ClickRecentTeammateTabTimeThreshold = 5;--隔多久点击再次重新拉取最近组队数据

	ClickSearchBtnTimeStamp = 0;
	ClickSearchBtnTimeThreshold = 10;--点击搜索键多久重新拉取一次概要数据 needrefresh置为true

	NearByPersonInfoArray = {};
	ShowNearByPersonInfoArray = {};
	NearByShowPageIndex = 1;
	NearByShowPageMaxNum = 20; --TODO jack
	NearByProfileReady = false;
	NearByStatusReady = false;
	UIdOpenIdDict = {};
	FetchNearByStatusTimeStamp = 0;			----点击UI的话，2分钟内更新一下好友数据
	FetchNearByStatusTimeLength = 30;	----点击UI的话，5分钟内更新一下好友数据
	find_uid_by_name_req_reason = "";
	GetNearbyPersonInfoTimeStamp = 0;
	GetNearbyPersonInfoTimeLength = 43200;	--每隔12小时，向MSDK请求一次附近的人数据
	NearByEmptyTimeStamp = 0;
	NearByEmptyTimeLength = 300;	--没有数据的情况下，每隔5分钟拉一次数据
	HasNew = false;
	NearByClear = false;
	NearByGenderCount = 0;
	LastSearchUid = nil;   --最后一次搜索的uid
	LastSearchNation = nil;
	LastSearchSegment = nil;
	LastSearchLanguage = nil;
}

ID_PLAT_FRIENDLIST={}
ID_INNER_FRIENDLIST={}
ID_RECENT_TEAMMATELIST={}

BP_ARRAY_All_Friend_Profile = {}
BP_ARRAY_Inner_Friend_Profile = {}
BP_ARRAY_Plat_Friend_Profile = {}

BP_ARRAY_Search_Friend_Profile = {}
BP_ARRAY_Apply_Friend_Profile = {}
BP_ARRAY_Friend_ID_Blacklist = {}
BP_ARRAY_Recent_Teammate_Profile = {}

FRIEND_AGREE_UID = 0
FRIEND_REFUSE_UID = 0

ADD_FRIEND = false
REFRESH_PANEL = false

-- 标识符均为true表示好友的概要，在线及组队信息均已拿到（注意拿到汇总数据后重置标识符）
FLAG_PROFILE_ALL = false
FLAG_ONLINE_AND_TEAMINFO_ALL = false

FLAG_RECENTTEAMMATE_PROFILE = false
FLAG_RECENTTEAMMATE_ONLINE_AND_TEAMINFO = false

--亲密关系最大人数
BP_Friend_Intimacy_Lover_MaxCount = 1
BP_Friend_Intimacy_Other_MaxCount = 5
BP_Friend_Intimacy_Threshold = 100
BP_Friend_Intimacy_MaxCount = 30

BP_Friend_MatchMode_Map = {}

-- 好友系统状态缓存处理
FriendSystem.friendStatusCache = {}

-- 
function FriendSystem.OnRefreshFriendProfile()
	log("eventlobbyfriendgetfriendprofile")
	if (FriendSystem.HasInit == true) then
		if (bp_lobby ~= nil) then
			local timeDiff = os.time() - FriendSystem.FetchTimeStamp;
			log("timeDiff2: "..tostring(timeDiff))
			local curStatus = string.lower(LuaClassObj.GetGameStatus(bp_lobby));
			if curStatus == "lobby" then
				FriendSystem.FetchTimeStamp = os.time()
				FriendSystem.getServerFriendIDList()
				log("eventlobbyfriendgetfriendprofile getserverfriendidlist")
			end
		end
	end
end

function FriendSystem.FetchNearByStatus()
	log("FriendSystem.FetchNearByStatus");
	local timeDiff = os.time() - FriendSystem.FetchNearByStatusTimeStamp;
	log("timeDiff1: "..tostring(timeDiff))
	if (timeDiff >= FriendSystem.FetchNearByStatusTimeLength) then
		FriendSystem.FetchNearByStatusTimeStamp = os.time();
		FriendSystem.UpdateNearByStatus();
	else
		LobbyFriendUI.UpdateNearByPanel()
	end
end

function FriendSystem.FetchFriendList()
	log("FriendSystem.FetchFriendList");
	local timeDiff = os.time() - FriendSystem.FetchTimeStamp;
	log("timeDiff1: "..tostring(timeDiff))
	if (timeDiff >= FriendSystem.FetchClickTimeLength) then
		FriendSystem.FetchTimeStamp = os.time();
		FriendSystem.getServerFriendIDList();
	else
		FriendSystem.getFriendIDList();
	end
end

function FriendSystem.CheckFetchFriendList()
	log("FriendSystem.CheckFetchFriendList");
	local timeDiff = os.time() - FriendSystem.FetchTimeStamp;
	log("timeDiff3: "..tostring(timeDiff))
	if (timeDiff >= FriendSystem.FetchClickTimeLength) then
		FriendSystem.FetchTimeStamp = os.time();
		FriendSystem.getServerFriendIDList();
	end
end

function FriendSystem.getServerFriendIDList()
	log("getServerFriendIDList");
	FriendSystem.NeedRefresh = true;
	FriendSystem.getFriendIDList();
	LuaClassObj.HandleUIMessage(bp_lobby, "UpdateFriendList");
end

-- 登出清理数据，关闭好友界面
local function BackLoginEventHandler(eventType, eventID, vars)
    if eventType ~= EVENTTYPE_LOGIN then
      return
    end
    if eventID == EVENTID_BACKLOGIN then
		FriendSystem.Quit()
    end
end

function FriendSystem.ResetData(isReconnect)
	log("friendsystem resetdata")
	StatusManager.getInstance():reset()
	PacketCacher.getInstance():reset()
	
	FriendSystem.friendStatusCache = {}

	ID_PLAT_FRIENDLIST={}
    ID_INNER_FRIENDLIST={}
	ID_RECENT_TEAMMATELIST={}

	log("friendlog BP_ARRAY_All_Friend_Profile = {}")
	BP_ARRAY_All_Friend_Profile = {}
	BP_ARRAY_Inner_Friend_Profile = {}
	BP_ARRAY_Plat_Friend_Profile = {}

	-- 避免重连后搜索列表丢失问题
	if isReconnect ~= true then
		BP_ARRAY_Search_Friend_Profile = {}
	end

	BP_ARRAY_Apply_Friend_Profile = {}
	BP_ARRAY_Friend_ID_Blacklist = {}

	BP_ARRAY_Recent_Teammate_Profile = {}

	FRIEND_AGREE_UID = 0
	FRIEND_REFUSE_UID = 0

	ADD_FRIEND = false
	REFRESH_PANEL = false

	-- 标识符均为true表示好友的概要，在线及组队信息均已拿到（注意拿到汇总数据后重置标识符）
	FLAG_PROFILE_ALL = false
	FLAG_ONLINE_AND_TEAMINFO_ALL = false

	FLAG_RECENTTEAMMATE_PROFILE = false
	FLAG_RECENTTEAMMATE_ONLINE_AND_TEAMINFO = false

	FriendSystem.NeedRefresh = false
	FriendSystem.HasInitLabelSearchData = false
	FriendSystem.HasInitIntimacyDetailData = false
	FriendSystem.HasInitMatchModeMap = false
	FriendSystem.GetNearbyPersonInfoTimeStamp = 0;
	FriendSystem.FetchNearByStatusTimeStamp = 0;
	FriendSystem.NearByEmptyTimeStamp = 0;
	BP_NearBy_Gender_Filter = 0;
end

function FriendSystem.Quit()
	log("friendsystem quit")
	EventSystem:unregistEvent(EVENTTYPE_LOGIN,EVENTID_BACKLOGIN,BackLoginEventHandler)
	FriendSystem.ResetData()
	LobbyFriendUI:Hide()
end

-- 断线重连重新拉取好友数据（好友申请，在线和组队状态）
function FriendSystem.GetFriendDataRequest()
	log("FriendSystem.GetFriendDataRequest");
	FriendSystem.ResetData(true)
	--请求好友列表
	FriendSystem.IsFromEnter = true	--getFriendIDList要去请求在线数据状态的都要加这个
	FriendSystem.getFriendIDList()
	FriendSystem.get_black_list_req()
	FriendSystem.get_addfriend_reqlist_req()
	FriendSystem.getRecentTeammate()
	log("getfrienddatarequest")
end

function FriendSystem.Enter()
	log("FriendSystem Enter")
	FriendSystem.HasInit = true
	FriendSystem.IsFromEnter = true
	--大厅10分钟捞取好友数据
	LuaClassObj.HandleUIMessage(bp_lobby, "UpdateFriendList")
	FriendSystem.FetchTimeStamp = os.time()

	EventSystem:unregistEvent(EVENTTYPE_LOGIN,EVENTID_BACKLOGIN,BackLoginEventHandler)
	EventSystem:registEvent(EVENTTYPE_LOGIN,EVENTID_BACKLOGIN,BackLoginEventHandler)

	--游戏返回大厅,拉取数据
	FriendSystem.getFriendIDList()
	FriendSystem.get_black_list_req()
	FriendSystem.get_addfriend_reqlist_req()

	--进入大厅拉取最近组队数据
	FriendSystem.getRecentTeammate()

	--获取亲密关系数据（显示小红点需提前拉取）
	FriendSystem.getIntimacyRelationReq(true)


	FriendSystem.InitLabelSearchData()

	FriendSystem.InitMatchModeData()

	BP_Global_SelfUID = DataMgr.roleData.uid;

	LuaClassObj.HandleUIMessage(bp_global, "GetCloseLocation");

	log("BP_Global_CloseLocation = " .. tostring(BP_Global_CloseLocation) .. ", BP_Global_SelfUID = " .. tostring(BP_Global_SelfUID));
	--[[
	if (BP_Global_CloseLocation == false) then
		--上报位置信息
		log("Client.GetLocationInfo()");
		Client.GetLocationInfo(NetInterface);
		BP_NearBy_Location_Open = true;
	else
		BP_NearBy_Location_Open = false;
	end
	]]
	BP_Global_CloseLocation = false
	BP_NearBy_Location_Open = false
end

function FriendSystem.InitMatchModeData()
	if FriendSystem.HasInitMatchModeMap == true then
		return
	end

	BP_Friend_MatchMode_Map = {}
	local friendMatchMode = Client.GetTable("MatchModeTable")
	for k,v in pairs(friendMatchMode) do
		local tmpValue = {modeStr = v.WordsToShow}
		BP_Friend_MatchMode_Map[tostring(k)] = tmpValue
	end
	FriendSystem.HasInitMatchModeMap = true
	--log_tree("BP_Friend_MatchMode_Map",BP_Friend_MatchMode_Map)
end
-----------------------------------------------------------请求好友id列表----------------------------------------
function FriendSystem.getFriendIDList()
	log("getFriendIDList")
	-- 所有好友
	FLAG_PROFILE_ALL = false
	FLAG_ONLINE_AND_TEAMINFO_ALL = false

	log("friendlog get_all_friendlist_req......")
	log("get_all_friendlist_req")
	NetUtil.SendPkg("get_all_friendlist_req")
	FriendSystem.FetchTimer = 0.0;
	FriendSystem.ClickAgreeBtnTimeStamp = 0
end
-----------------------------------------------------------请求好友id列表----------------------------------------

-----------------------------------------------------------批量请求组队状态--------------------------------------
-- 批量请求组队状态
function FriendSystem.batchGetTeamInfoList()
	-- local list = FriendSystem.UnionFriendIDList(ID_INNER_FRIENDLIST,ID_PLAT_FRIENDLIST)

	-- if next(list) == nil then
	-- 	return
	-- end
	-- NetUtil.SendPkg("batch_get_group_and_online_req","updateteam",list)
end
-----------------------------------------------------------批量请求组队状态--------------------------------------

-----------------------------------------------------------回包好友id列表----------------------------------------
-- 所有好友id列表
function FriendSystem.on_get_all_friendlist_rsp(res,friendlist)
	--log_tree("get_all_friendlist_rsq",friendlist)
	log("on_get_all_friendlist_rsp-----------"..tostring(res))
	log("friendlog on_get_all_friendlist_rsp......")
	ID_PLAT_FRIENDLIST={}
    ID_INNER_FRIENDLIST={}

	local curTime = FuncUtil.GetServerTimeInSec()
	if res == "ok" then
		if next(friendlist) ~= nil then
			--平台好友数据
			for k,v in pairs(friendlist.plat_list) do
				table.insert(ID_PLAT_FRIENDLIST,k)
				local has = false
				for i = #BP_ARRAY_All_Friend_Profile,1,-1 do
					if tonumber(BP_ARRAY_All_Friend_Profile[i].gid) == tonumber(k) then
						BP_ARRAY_All_Friend_Profile[i].lastInviteTime = v.lastInviteTime
						-- 平台好友亲密度默认值为0，如果也是游戏好友，再赋值下亲密度
						BP_ARRAY_All_Friend_Profile[i].intimacy = 0
						BP_ARRAY_All_Friend_Profile[i].remarks_name = v.remarks_name

						if v.presented ~= nil and tonumber(v.presented) == 0 then
							BP_ARRAY_All_Friend_Profile[i].lastPresentCoinTime = 0
							BP_ARRAY_All_Friend_Profile[i].bPresentedCoin = 0

						else
							BP_ARRAY_All_Friend_Profile[i].lastPresentCoinTime = curTime
							BP_ARRAY_All_Friend_Profile[i].bPresentedCoin = 1
						end

						has = true
						break
					end
				end
				if not has then
					local profile = {gid=tostring(k),intimacy=0,lastInviteTime=v.lastInviteTime,remarks_name=v.remarks_name}

					if v.presented ~= nil and tonumber(v.presented) == 0 then
						profile.lastPresentCoinTime = 0
						profile.bPresentedCoin = 0
					else
						profile.lastPresentCoinTime = curTime
						profile.bPresentedCoin = 1
					end

					table.insert(BP_ARRAY_All_Friend_Profile,profile)
				end
			end

			--游戏好友数据
			for k,v in pairs(friendlist.inner_list) do
				table.insert(ID_INNER_FRIENDLIST,k)
				local has = false
				for i = #BP_ARRAY_All_Friend_Profile,1,-1 do
					if tonumber(BP_ARRAY_All_Friend_Profile[i].gid) == tonumber(k) then
						BP_ARRAY_All_Friend_Profile[i].intimacy = v.intimacy
						BP_ARRAY_All_Friend_Profile[i].create_time = v.create_time

						if v.presented ~= nil and tonumber(v.presented) == 0 then
							BP_ARRAY_All_Friend_Profile[i].lastPresentCoinTime = 0
							BP_ARRAY_All_Friend_Profile[i].bPresentedCoin = 0

						else
							BP_ARRAY_All_Friend_Profile[i].lastPresentCoinTime = curTime
							BP_ARRAY_All_Friend_Profile[i].bPresentedCoin = 1
						end

						has = true
						break
					end
				end
				if not has then
					local profile = {gid=tostring(k),intimacy=v.intimacy,create_time=v.create_time}
					if v.presented ~= nil and tonumber(v.presented) == 0 then
						profile.lastPresentCoinTime = 0
						profile.bPresentedCoin = 0
					else
						profile.lastPresentCoinTime = curTime
						profile.bPresentedCoin = 1
					end
					table.insert(BP_ARRAY_All_Friend_Profile,profile)
				end
			end
			--log_tree("BP_ARRAY_All_Friend_Profile all1:", BP_ARRAY_All_Friend_Profile)
			--log_tree("friendlist.inner_list:", friendlist.inner_list)


			local list = FriendSystem.UnionFriendIDList(ID_INNER_FRIENDLIST,ID_PLAT_FRIENDLIST)
			if next(list) == nil or ProfileMgr == nil then
				log("friendlist is nil")

				BP_ARRAY_Plat_Friend_Profile = {}
				BP_ARRAY_Inner_Friend_Profile = {}

				--local xiaoyueProfile = {bXiaoYue=1,bNewMessage=BP_YXXY_RedPoint, gid="999"}
				--table.insert(BP_ARRAY_Plat_Friend_Profile,1,xiaoyueProfile)

				--local xiaoyueProfile2 = {bXiaoYue=1,bNewMessage=BP_YXXY_RedPoint, gid="9999"}
				--table.insert(BP_ARRAY_Inner_Friend_Profile,1,xiaoyueProfile2)

				if BP_Friend_Send_Item then
					-- 赠送道具给好友模式
					LobbyFriendUI:UpdateAllFriends(nil)
				else
					LobbyFriendUI:UpdatePlatList()
					LobbyFriendUI:UpdateInnerList()
				end

				return
			end

			if FriendSystem.NeedRefresh == true then
			log("friendlog ProfileMgr.GetFriendProfileList(list,FriendSystem.on_batch_get_all_profile_rsp,true,false)......")
				ProfileMgr.GetFriendProfileList(list,FriendSystem.on_batch_get_all_profile_rsp,false,false)
				FriendSystem.NeedRefresh = false
				log("friendsystem needrefresh true")
			else
				log("friendlog ProfileMgr.GetFriendProfileList(list,FriendSystem.on_batch_get_all_profile_rsp,false,false)......")
				ProfileMgr.GetFriendProfileList(list,FriendSystem.on_batch_get_all_profile_rsp,false,false)
				log("friendsystem needrefresh false")
			end
			if FriendSystem.IsFromEnter then
			log("friendlog batch_get_group_and_online_req......")
			-- log_tree("friendlog BP_ARRAY_All_Friend_Profile",BP_ARRAY_All_Friend_Profile)

			NetUtil.SendPkg("batch_get_group_and_online_req", "all", list)	
			FriendSystem.IsFromEnter = false
			end

		end

		EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_REFRESH_LIST)
	else
		log("get_all_friendlist_rsq fail:"..res)
	end

	if #BP_ARRAY_All_Friend_Profile > 0 then
		Bargain_Detail_UI.InitFriendsList();
	end
end
-----------------------------------------------------------回包好友id列表----------------------------------------

-----------------------------------------------------------合并uid列表-------------------------------------------
-- 合并两个uid列表
function FriendSystem.UnionFriendIDList(list1,list2)
	local list = {}
	for i = #list1,1,-1 do
		table.insert(list,list1[i])
	end

	for i = #list2,1,-1 do
		local has = false
		for j = #list1,1,-1 do
			if tonumber(list1[j]) == tonumber(list2[i]) then
				has = true
				break
			end
		end

		if not has then
			table.insert(list,list2[i])
		end
	end
	return list
end
-----------------------------------------------------------合并uid列表-------------------------------------------

-----------------------------------------------------------通知额外平台好友id列表-----------------------------------------
function FriendSystem.on_notify_topn_plat_friend_chg_info(list)
	--log_tree("on_notify_topn_plat_friend_chg_info",list);
	log("on_notify_topn_plat_friend_chg_info");
	
	if list == nil then
		return;
	end
	
	--如果服务器可以保证发送过来的list ids和unionList没有交集，客户端可以不用去重
	local unionList = FriendSystem.UnionFriendIDList(ID_INNER_FRIENDLIST,ID_PLAT_FRIENDLIST);
	local extraList = {};
	local curTime = FuncUtil.GetServerTimeInSec()
	local friendList = {plat_list={}};
	for k,v in pairs(list) do
		local has = false;
		for	i = 1,#unionList,1 do
			if tonumber(k) == unionList[i] then
				has = true;
				break;
			end
		end
		if not has then
			table.insert(extraList,k);
			table.insert(ID_PLAT_FRIENDLIST,k);
						
			--将数据缓存到ProfileMgr
			friendList.plat_list[k] = {}
			friendList.plat_list[k] = v;
			ProfileMgr.SetFriendSubData(friendList);
			
			local friGid = tonumber(k)
			BP_ARRAY_All_Friend_Profile[friGid] = BP_ARRAY_All_Friend_Profile[friGid] or {}
			local friendData = BP_ARRAY_All_Friend_Profile[friGid]
			friendData.gid = tostring(friGid)
			friendData.intimacy = 0
			friendData.lastInviteTime = v.lastInviteTime or 0
			--friendData.remarks_name = v.remarks_name or ""
			if v.presented ~= nil and tonumber(v.presented) == 0 then
				friendData.lastPresentCoinTime = 0
				friendData.bPresentedCoin = 0
			else
				friendData.lastPresentCoinTime = curTime
				friendData.bPresentedCoin = 1
			end
		end
	end
	--获取额外平台好友数据
	if #extraList > 0 then
		ProfileMgr.GetFriendProfileList(extraList,FriendSystem.on_batch_get_all_profile_rsp,true,true)
		--NetUtil.SendPkg("batch_get_group_and_online_req", "all", extraList)
	end
end
-----------------------------------------------------------通知额外平台好友id列表-----------------------------------------

-----------------------------------------------------------请求最近组队队友----------------------------------------
function FriendSystem.fetchRecentTeammateList()
	log("fetchRecentTeammateList")
	local timeDiff = os.time() - FriendSystem.ClickRecentTeammateTabTimeStamp
	if (timeDiff >= FriendSystem.ClickRecentTeammateTabTimeThreshold) then
		FriendSystem.ClickRecentTeammateTabTimeStamp = os.time()
		log(">= ClickRecentTeammateTabTimeThreshold getRecentTeammate")
		FriendSystem.getRecentTeammate()
	else
		LobbyFriendUI:UpdateRecentTeammateList()
		log("< ClickRecentTeammateTabTimeThreshold UpdateRecentTeammateList")
	end
end

function FriendSystem.getRecentTeammate()
	log("getRecentTeammate")

	NetUtil.SendPkg("get_recent_teammate_req")
end

function FriendSystem.NotifyUpdateRecentTeammatePanel()
	log("NotifyUpdateRecentTeammatePanel")
	if FLAG_RECENTTEAMMATE_PROFILE == true and FLAG_RECENTTEAMMATE_ONLINE_AND_TEAMINFO == true then
		FLAG_RECENTTEAMMATE_PROFILE = false
		FLAG_RECENTTEAMMATE_ONLINE_AND_TEAMINFO = false
		LobbyFriendUI:UpdateRecentTeammateList()
		--log_tree("BP_ARRAY_Recent_Teammate_Profile",BP_ARRAY_Recent_Teammate_Profile)
	end
end
-----------------------------------------------------------请求最近组队队友----------------------------------------

-----------------------------------------------------------回包最近组队队友----------------------------------------
function FriendSystem.on_get_recent_teammate_rsp(list)
	--log_tree("on_get_recent_teammate_rsp list",list)
	log("on_get_recent_teammate_rsp")

	ID_RECENT_TEAMMATELIST = {}
	BP_ARRAY_Recent_Teammate_Profile = {}

	FLAG_RECENTTEAMMATE_PROFILE = false
	FLAG_RECENTTEAMMATE_ONLINE_AND_TEAMINFO = false

	if next(list) == nil then
		log("on_get_recent_teammate_rsp list is nil")
		LobbyFriendUI:UpdateRecentTeammateList()
		return
	end

	ID_RECENT_TEAMMATELIST = {}
	BP_ARRAY_Recent_Teammate_Profile = {}
	local idlist = {}

	for i = 1,#list,1 do
		table.insert(ID_RECENT_TEAMMATELIST,list[i].uid)
		local profile = {gid = tostring(list[i].uid),endtime = list[i].endtime,endtimeStr = FriendSystem.FormatTime(list[i].endtime,""),rank=list[i].rank,total=list[i].total,score=tostring(list[i].score),kill=list[i].kill,mode=list[i].mode}
		local matchConfig = Client.GetTableData("MatchModeTable",tonumber(list[i].mode))
		if matchConfig then
			profile.modeStr = matchConfig.ModeStr
		else
			profile.modeStr = "";
		end
		profile.roleNation = ProfileMgr.GetRoleNationByUid(list[i].uid);
		table.insert(BP_ARRAY_Recent_Teammate_Profile,profile)
		table.insert(idlist,list[i].uid)
	end

	--log_tree("BP_ARRAY_Recent_Teammate_Profile",BP_ARRAY_Recent_Teammate_Profile)

	ProfileMgr.GetProfileList(idlist,FriendSystem.on_batch_get_recentteammate_profile_rsp)
	NetUtil.SendPkg("batch_get_group_and_online_req", "recentteammate", idlist)
end
-----------------------------------------------------------回包最近组队队友----------------------------------------

-----------------------------------------------------------返回概要信息----------------------------------------
--获取所有好友概要数据
function FriendSystem.on_batch_get_all_profile_rsp(profileList)
	--log_tree("on_batch_get_all_profile_rsp",profileList)
	log("friendlog on_batch_get_friend_profile_rsp" );
	-- log_tree("friendlog on_batch_get_friend_profile_rsp1",BP_ARRAY_All_Friend_Profile)
	-- log_tree("friendlog FriendSystem.friendStatusCache",FriendSystem.friendStatusCache)
    --log_tree("profileList " , profileList);
    local idList = {}
	for k,v in pairs(profileList) do
		-- table.insert(idList, tonumber(v.uid))
		
		local has = false
		for i = #BP_ARRAY_All_Friend_Profile,1,-1 do
			if tonumber(BP_ARRAY_All_Friend_Profile[i].gid) == tonumber(v.uid) then
	    		-- 重新赋值好友缓存
				for index,vv in pairs(FriendSystem.friendStatusCache) do
                    --jaysunzhu，屏蔽。两重循环中的日志量有点大
					--log("friendlog set BP_ARRAY_All_Friend_Profile[i].gid "..BP_ARRAY_All_Friend_Profile[i].gid.."vv.gid"..vv.gid)
					if tonumber(BP_ARRAY_All_Friend_Profile[i].gid) == tonumber(vv.gid) 
					and BP_ARRAY_All_Friend_Profile[i].online == nil
					then
						log("friendlog 重新赋值好友缓存 "..vv.gid)
						BP_ARRAY_All_Friend_Profile[i].online = vv.online
						BP_ARRAY_All_Friend_Profile[i].teamState = vv.teamState
						BP_ARRAY_All_Friend_Profile[i].currentTeamAmount = vv.currentTeamAmount
						BP_ARRAY_All_Friend_Profile[i].maxTeamAmount = vv.maxTeamAmount

						if vv.timeSinceGameBeginStamp == nil then
							BP_ARRAY_All_Friend_Profile[i].timeSinceGameBegin = vv.timeSinceGameBegin
						else
							BP_ARRAY_All_Friend_Profile[i].timeSinceGameBeginStamp = vv.timeSinceGameBeginStamp
							BP_ARRAY_All_Friend_Profile[i].timeSinceGameBegin = os.time() - vv.timeSinceGameBeginStamp
						end

						BP_ARRAY_All_Friend_Profile[i].timeSinceGameBeginStr = FriendSystem.FormatTime2(vv.timeSinceGameBegin)
						BP_ARRAY_All_Friend_Profile[i].game_mode = vv.game_mode
						BP_ARRAY_All_Friend_Profile[i].gameModeStr = vv.gameModeStr

						BP_ARRAY_All_Friend_Profile[i].lastPresentCoinTime = vv.lastPresentCoinTime
						BP_ARRAY_All_Friend_Profile[i].bPresentedCoin = vv.bPresentedCoin
						BP_ARRAY_All_Friend_Profile[i].intimacy = vv.intimacy
					end
				end

				BP_ARRAY_All_Friend_Profile[i].nickName = v.nickName
				BP_ARRAY_All_Friend_Profile[i].level = v.level
				BP_ARRAY_All_Friend_Profile[i].vipLevel = v.vipLevel
				BP_ARRAY_All_Friend_Profile[i].picUrl = v.picUrl
				BP_ARRAY_All_Friend_Profile[i].platName = v.platName
				BP_ARRAY_All_Friend_Profile[i].sex = v.sex
				BP_ARRAY_All_Friend_Profile[i].signature = v.signature
				BP_ARRAY_All_Friend_Profile[i].lastOnlineTime = v.lastOnlineTime
				BP_ARRAY_All_Friend_Profile[i].lastOnlineTimeStr = FriendSystem.FormatTime(v.lastOnlineTime,"online")
				BP_ARRAY_All_Friend_Profile[i].lastLoginTime = v.lastLoginTime
				BP_ARRAY_All_Friend_Profile[i].exp = v.exp
				--[[if v.segment_info then
					BP_ARRAY_All_Friend_Profile[i].segment_info_solo = v.segment_info[1]
					BP_ARRAY_All_Friend_Profile[i].segment_info_duo = v.segment_info[2]
					BP_ARRAY_All_Friend_Profile[i].segment_info_squad = v.segment_info[3]
                end]]
                ----------------------------------------intl modify--------------------------------------
                BP_ARRAY_All_Friend_Profile[i].AllSegment_Info = v.segment_info;
                for k, v in pairs(BP_ARRAY_All_Friend_Profile[i].AllSegment_Info) do
                        BP_ARRAY_All_Friend_Profile[i].segment_info_solo  = BP_ARRAY_All_Friend_Profile[i].AllSegment_Info[k][1];
                        BP_ARRAY_All_Friend_Profile[i].segment_info_duo   = BP_ARRAY_All_Friend_Profile[i].AllSegment_Info[k][2];
                        BP_ARRAY_All_Friend_Profile[i].segment_info_squad = BP_ARRAY_All_Friend_Profile[i].AllSegment_Info[k][3];
                    break;
                end

                BP_ARRAY_All_Friend_Profile[i].segment_info_solo, BP_ARRAY_All_Friend_Profile[i].segment_info_duo,BP_ARRAY_All_Friend_Profile[i].segment_info_squad =  FuncUtil.GetMaxSegement(BP_ARRAY_All_Friend_Profile[i].AllSegment_Info);
                ----------------------------------------intl modify--------------------------------------
				BP_ARRAY_All_Friend_Profile[i].history_max_segment_level = v.history_max_segment_level;

				BP_ARRAY_All_Friend_Profile[i].startup_type = GetSafeNumber(v.startup_type)
				BP_ARRAY_All_Friend_Profile[i].qq_vip = GetSafeNumber(v.qq_vip)
				BP_ARRAY_All_Friend_Profile[i].cur_avatar_box_id = v.cur_avatar_box_id
                BP_ARRAY_All_Friend_Profile[i].isInnerFriendNotPlatFriend = FriendSystem.IsInnerFriendNotPlatFriend(v.uid)
				BP_ARRAY_All_Friend_Profile[i].corps_id = v.corps_id
				BP_ARRAY_All_Friend_Profile[i].upass_is_buy, BP_ARRAY_All_Friend_Profile[i].upass_is_show = FriendSystem.ParseUpassInfo(v.upass);
				BP_ARRAY_All_Friend_Profile[i].roleNation = v.nation;
				BP_ARRAY_All_Friend_Profile[i].language = v.language;
				BP_ARRAY_All_Friend_Profile[i].aliasId = v.alias.id;
				BP_ARRAY_All_Friend_Profile[i].aliasTitle = v.alias.title;
				BP_ARRAY_All_Friend_Profile[i].aliasNation = v.alias.nation;
				BP_ARRAY_All_Friend_Profile[i].enableWatch = v.enableWatch
				has = true
				break
			end
		end

		if not has then
			local data = {}
			data.gid = v.uid
			data.friendType = 0
			data.nickName = v.nickName
			data.level = v.level
			data.vipLevel = v.vipLevel
			data.picUrl = v.picUrl
			data.platName = v.platName
			data.sex = v.sex
			data.signature = v.signature
			data.lastOnlineTime = v.lastOnlineTime
			data.lastOnlineTimeStr = FriendSystem.FormatTime(v.lastOnlineTime,"online")
			data.lastLoginTime = v.lastLoginTime
			data.exp = v.exp
             ----------------------------------------intl modify--------------------------------------
			--[[if v.segment_info then
				data.segment_info_solo = v.segment_info[1]
				data.segment_info_duo = v.segment_info[2]
				data.segment_info_squad = v.segment_info[3]
            end]]

            data.AllSegment_Info = v.segment_info;
            for k, v in pairs(data.AllSegment_Info) do
                data.segment_info_solo   = data.AllSegment_Info[k][1];
                data.segment_info_duo    = data.AllSegment_Info[k][2];
                data.segment_info_squad = data.AllSegment_Info[k][3];
                break;
            end

            data.segment_info_solo, data.segment_info_duo,data.segment_info_squad = FuncUtil.GetMaxSegement(data.AllSegment_Info);
             ----------------------------------------intl modify--------------------------------------
	     	data.history_max_segment_level = v.history_max_segment_level;
			data.startup_type = GetSafeNumber(v.startup_type)
			data.qq_vip = GetSafeNumber(v.qq_vip)
			data.cur_avatar_box_id = v.cur_avatar_box_id
			data.bPresentedCoin = 0
			data.lastPresentCoinTime = 0
			data.corps_id = v.corps_id
			data.upass_is_buy, data.upass_is_show = FriendSystem.ParseUpassInfo(v.upass)  -- 绝地通行证
			data.aliasId = v.alias.id;
			data.aliasTitle = v.alias.title;
			data.aliasNation = v.alias.nation;
			data.enableWatch = v.enableWatch;
            data.isInnerFriendNotPlatFriend = FriendSystem.IsInnerFriendNotPlatFriend(v.uid)

    		-- 重新赋值好友缓存
    		for index,vv in pairs(FriendSystem.friendStatusCache) do
                --jaysunzhu，屏蔽。两重循环中的日志量有点大
    			--log("friendlog add data.gid "..data.gid.."vv.gid"..vv.gid)
    			if tonumber(data.gid) == tonumber(vv.gid)
				and data.online == nil
				then
    				log("friendlog 重新赋值好友缓存 "..vv.gid)
					data.online = vv.online
					data.teamState = vv.teamState
					data.currentTeamAmount = vv.currentTeamAmount
					data.maxTeamAmount = vv.maxTeamAmount

					if vv.timeSinceGameBeginStamp == nil then
						data.timeSinceGameBegin = vv.timeSinceGameBegin
					else
						data.timeSinceGameBeginStamp = vv.timeSinceGameBeginStamp
						data.timeSinceGameBegin = os.time() - vv.timeSinceGameBeginStamp
					end

					data.timeSinceGameBeginStr = FriendSystem.FormatTime2(vv.timeSinceGameBegin)
					data.game_mode = vv.game_mode
					data.gameModeStr = vv.gameModeStr

					data.lastPresentCoinTime = vv.lastPresentCoinTime
					data.bPresentedCoin = vv.bPresentedCoin
					data.intimacy = vv.intimacy
    			end
    		end

			table.insert(BP_ARRAY_All_Friend_Profile, data)
		end
    end

	--刷新界面，通知其他系统更新
	FLAG_PROFILE_ALL = true
	-- log_tree("friendlog on_batch_get_friend_profile_rsp",BP_ARRAY_All_Friend_Profile)
	-- NetUtil.SendPkg("batch_get_group_and_online_req","all",idList)
	FriendSystem.NotifyPullFriendList()
end

-- 获取最近组队队友概要信息
function FriendSystem.on_batch_get_recentteammate_profile_rsp(profileList)
	--log_tree("recentteammate profile:",profileList)

	for k,v in pairs(profileList) do
		for kk,vv in pairs(BP_ARRAY_Recent_Teammate_Profile) do
			if tonumber(vv.gid) == tonumber(v.uid) then
				vv.nickName = v.nickName
				vv.level = v.level
				vv.picUrl = v.picUrl
				vv.vipLevel = v.vipLevel
				vv.platName = v.platName
				vv.sex = v.sex
				vv.lastOnlineTime = v.lastOnlineTime
				vv.lastLoginTime = v.lastLoginTime
				vv.exp = v.exp
                 ----------------------------------------intl modify--------------------------------------
                 vv.AllSegment_Info = v.segment_info;
                 for kseg, vseg in pairs(vv.AllSegment_Info) do
                       vv.segment_info_solo   = vv.AllSegment_Info[kseg][1];
                       vv.segment_info_duo    = vv.AllSegment_Info[kseg][2];
                       vv.segment_info_squad = vv.AllSegment_Info[kseg][3];
                       break;
                 end
                 vv.segment_info_solo, vv.segment_info_duo, vv.segment_info_squad =  FuncUtil.GetMaxSegement(vv.AllSegment_Info);
                --[[
				vv.segment_info_solo = v.segment_info[1]
				vv.segment_info_duo = v.segment_info[2]
				vv.segment_info_squad = v.segment_info[3]
                ]]
                 ----------------------------------------intl modify--------------------------------------
		 		vv.history_max_segment_level = v.history_max_segment_level;
				vv.startup_type = GetSafeNumber(v.startup_type)
				vv.qq_vip = GetSafeNumber(v.qq_vip)
				vv.cur_avatar_box_id = v.cur_avatar_box_id
				vv.upass_is_buy, vv.upass_is_show = FriendSystem.ParseUpassInfo(v.upass)  -- 绝地通行证
				vv.aliasId = v.alias.id;
				vv.aliasTitle = v.alias.title;
				vv.aliasNation = v.alias.nation;
                vv.roleNation = ProfileMgr.GetRoleNationByUid(v.uid);
			end
		end
	end

	table.sort(BP_ARRAY_Recent_Teammate_Profile,SortRecentFunc)
	FLAG_RECENTTEAMMATE_PROFILE = true
	FriendSystem.NotifyUpdateRecentTeammatePanel()
	--log_tree("BP_ARRAY_Recent_Teammate_Profile",BP_ARRAY_Recent_Teammate_Profile)
end

-----------------------------------------------------------查找好友----------------------------------------
--通过名字查找uid 精确查找 名字必须输全
function FriendSystem.find_uid_by_name_req(name, reason)
    log("find_uid_by_name_req:"..name)
    FriendSystem.find_uid_by_name_req_reason = reason;
    NetUtil.SendPkg("find_uid_by_name_req", name)
end

--查找回包
function FriendSystem.on_find_uid_by_name_rsp(res, name, uids)
    log("on_find_uid_by_name_rsp:"..res.." name:"..name)
	--log_tree("on_find_uid_by_name_rsp uids ",uids)

    if (FriendSystem.find_uid_by_name_req_reason == "MasterDisciple") then
		--MasterDiscipleSystem.on_find_uid_by_name_rsp(res, name, uids);
	else
		if res == "ok" then
			log("search success")
			BP_ARRAY_Search_Friend_Profile = {}

			for i = 1,#uids,1 do
				local data = {gid=tostring(uids[i])}
				table.insert(BP_ARRAY_Search_Friend_Profile,data)
			end

			local needRefreshProfile = false
			local timeDiff = os.time() - FriendSystem.ClickSearchBtnTimeStamp
			if timeDiff > FriendSystem.ClickSearchBtnTimeThreshold then
				needRefreshProfile = true
				FriendSystem.ClickSearchBtnTimeStamp = os.time()
			else
				needRefreshProfile = false
			end
			ProfileMgr.GetProfileList(uids,FriendSystem.on_batch_get_search_profile_rsp,needRefreshProfile)
		elseif res == "have-dirty-in-name" then
			log("searching words have dirty in name")
			DataMgr.ShowNoticeByID(990004); 
		else
			log("search fail")
			LobbyFriendUI:ShowSearchFailResult()
		end
	end
end

--通过标签查找
function FriendSystem.social_search_role_req(condition)
    log("social_search_role_req()")
    if (condition == nil) then
    	return;
    end
    log_tree("condition:", condition)
    if (condition.nation ~= FriendSystem.LastSearchNation or condition.segment ~= FriendSystem.LastSearchSegment or condition.language ~= FriendSystem.LastSearchLanguage) then
    	FriendSystem.LastSearchUid = nil;
    end
    log("social_search_role_req() FriendSystem.LastSearchUid:"..tostring(FriendSystem.LastSearchUid))
    NetUtil.SendPkg("social_search_role_req", condition, 20, FriendSystem.LastSearchUid)
end

--查找回包
function FriendSystem.on_social_search_role_rsp(res, uidlist)
    log("on_social_search_role_rsp:"..res)
    if (res == "server_busy") then
    	DataMgr.ShowNoticeByID(120164)
    	return;
    end

    if (uidlist ~= nil) then
    	log_tree("uids:", uidlist)
    end
	if res == "ok" then
		if uidlist ~= nil and next(uidlist) ~= nil then
			FriendSystem.LastSearchUid = uidlist[#uidlist]
		else
			FriendSystem.LastSearchUid = nil;
		end
	else
		FriendSystem.LastSearchUid = nil;
	end

	if uidlist ~= nil and next(uidlist) ~= nil then
		BP_ARRAY_Search_Friend_Profile = {}
		for i = 1,#uidlist,1 do
			local data = {gid=tostring(uidlist[i])}
			table.insert(BP_ARRAY_Search_Friend_Profile,data)
		end

		local needRefreshProfile = false
		local timeDiff = os.time() - FriendSystem.ClickSearchBtnTimeStamp
		if timeDiff > FriendSystem.ClickSearchBtnTimeThreshold then
			needRefreshProfile = true
			FriendSystem.ClickSearchBtnTimeStamp = os.time()
		else
			needRefreshProfile = false
		end
		ProfileMgr.GetProfileList(uidlist,FriendSystem.on_batch_get_search_profile_rsp,needRefreshProfile)
	else
		BP_ARRAY_Search_Friend_Profile = {}
		LobbyFriendUI:UpdateSearchList()
		LobbyFriendUI:ShowSearchFailResult()
	end
end
-----------------------------------------------------------查找好友----------------------------------------

--获取要添加的玩家的概要数据
function FriendSystem.on_batch_get_search_profile_rsp(profileList)
	--log_tree("search profile:", profileList)

	if next(profileList) == nil then
		log("search empty")
		LobbyFriendUI:ShowSearchFailResult()
		return
	end

    BP_ARRAY_Search_Friend_Profile = {}
	for k,v in pairs(profileList) do
		local has = false
		for i = #BP_ARRAY_Search_Friend_Profile,1,-1 do
			if tonumber(BP_ARRAY_Search_Friend_Profile[i].gid) == tonumber(v.uid) then
				BP_ARRAY_Search_Friend_Profile[i].nickName = v.nickName
				BP_ARRAY_Search_Friend_Profile[i].level = v.level
				BP_ARRAY_Search_Friend_Profile[i].picUrl = v.picUrl
				BP_ARRAY_Search_Friend_Profile[i].vipLevel = v.vipLevel
				BP_ARRAY_Search_Friend_Profile[i].platName = v.platName
				BP_ARRAY_Search_Friend_Profile[i].sex = v.sex
				BP_ARRAY_Search_Friend_Profile[i].lastOnlineTime = v.lastOnlineTime
				BP_ARRAY_Search_Friend_Profile[i].lastLoginTime = v.lastLoginTime
				BP_ARRAY_Search_Friend_Profile[i].exp = v.exp
				BP_ARRAY_Search_Friend_Profile[i].language = v.language
                ----------------------------------------intl modify--------------------------------------
                --[[
				BP_ARRAY_Search_Friend_Profile[i].segment_info_solo = v.segment_info[1]
				BP_ARRAY_Search_Friend_Profile[i].segment_info_duo = v.segment_info[2]
				BP_ARRAY_Search_Friend_Profile[i].segment_info_squad = v.segment_info[3]
                ]]
                BP_ARRAY_Search_Friend_Profile[i].AllSegment_Info = v.segment_info;
                for k, v in pairs(BP_ARRAY_Search_Friend_Profile[i].AllSegment_Info) do
                    BP_ARRAY_Search_Friend_Profile[i].segment_info_solo   = BP_ARRAY_Search_Friend_Profile[i].AllSegment_Info [k][1];
                    BP_ARRAY_Search_Friend_Profile[i].segment_info_duo    = BP_ARRAY_Search_Friend_Profile[i].AllSegment_Info [k][2];
                    BP_ARRAY_Search_Friend_Profile[i].segment_info_squad = BP_ARRAY_Search_Friend_Profile[i].AllSegment_Info [k][3];
                    break;
                end
                BP_ARRAY_Search_Friend_Profile[i].segment_info_solo, BP_ARRAY_Search_Friend_Profile[i].segment_info_duo, BP_ARRAY_Search_Friend_Profile[i].segment_info_squad =  FuncUtil.GetMaxSegement(BP_ARRAY_Search_Friend_Profile[i].AllSegment_Info);
                ----------------------------------------intl modify--------------------------------------
				BP_ARRAY_Search_Friend_Profile[i].history_max_segment_level = v.history_max_segment_level
				BP_ARRAY_Search_Friend_Profile[i].startup_type = GetSafeNumber(v.startup_type)
				BP_ARRAY_Search_Friend_Profile[i].qq_vip = GetSafeNumber(v.qq_vip)
				BP_ARRAY_Search_Friend_Profile[i].cur_avatar_box_id = v.cur_avatar_box_id
				BP_ARRAY_Search_Friend_Profile[i].upass_is_buy, BP_ARRAY_Search_Friend_Profile[i].upass_is_show = FriendSystem.ParseUpassInfo(v.upass)  -- 绝地通行证
				BP_ARRAY_Search_Friend_Profile[i].aliasId = v.alias.id;
				BP_ARRAY_Search_Friend_Profile[i].aliasTitle = v.alias.title;
				BP_ARRAY_Search_Friend_Profile[i].aliasNation = v.alias.nation;

				if v.social_card == nil then
					BP_ARRAY_Search_Friend_Profile[i].tendency = 0
					BP_ARRAY_Search_Friend_Profile[i].playDate = 0
					BP_ARRAY_Search_Friend_Profile[i].playTime = 0
					BP_ARRAY_Search_Friend_Profile[i].cityId = 0
					BP_ARRAY_Search_Friend_Profile[i].expertArea_1 = 0
					BP_ARRAY_Search_Friend_Profile[i].expertArea_2 = 0
				else
					BP_ARRAY_Search_Friend_Profile[i].tendency = v.social_card.tendency or 0
					BP_ARRAY_Search_Friend_Profile[i].playDate = v.social_card.play_date or 0
					BP_ARRAY_Search_Friend_Profile[i].playTime = v.social_card.play_time or 0
					BP_ARRAY_Search_Friend_Profile[i].cityId = v.social_card.city_id or 0

					if v.social_card.expert_area ~= nil then
						if v.social_card.expert_area[1] ~= nil then
							BP_ARRAY_Search_Friend_Profile[i].expertArea_1 = v.social_card.expert_area[1] or 0
						else
							BP_ARRAY_Search_Friend_Profile[i].expertArea_1 = 0
						end

						if v.social_card.expert_area[2] ~= nil then
							BP_ARRAY_Search_Friend_Profile[i].expertArea_2 = v.social_card.expert_area[2] or 0
						else
							BP_ARRAY_Search_Friend_Profile[i].expertArea_2 = 0
						end
					else
						BP_ARRAY_Search_Friend_Profile[i].expertArea_1 = 0
						BP_ARRAY_Search_Friend_Profile[i].expertArea_2 = 0
					end
				end
				has = true
				break
			end
		end

		if not has then
			local data = {}
			data.gid = v.uid
			data.nickName = v.nickName
			data.level = v.level
			data.picUrl = v.picUrl
			data.vipLevel = v.vipLevel
			data.platName = v.platName
			data.sex = v.sex
			data.lastOnlineTime = v.lastOnlineTime
			data.lastLoginTime = v.lastLoginTime
			data.exp = v.exp
			data.language = v.language

            ----------------------------------------intl modify--------------------------------------
            --[[
			data.segment_info_solo = v.segment_info[1]
			data.segment_info_duo = v.segment_info[2]
			data.segment_info_squad = v.segment_info[3]
            ]]
            data.AllSegment_Info = v.segment_info;
            for kseg, v in pairs(data.AllSegment_Info) do
                data.segment_info_solo = data.AllSegment_Info[kseg][1];
                data.segment_info_duo = data.AllSegment_Info[kseg][2];
                data.segment_info_squad = data.AllSegment_Info[kseg][3];
                break;
            end
            data.segment_info_solo,  data.segment_info_duo,  data.segment_info_squad = FuncUtil.GetMaxSegement( data.AllSegment_Info );
            ----------------------------------------intl modify--------------------------------------
            data.history_max_segment_level = v.history_max_segment_level;
			data.startup_type = GetSafeNumber(v.startup_type)
			data.qq_vip = GetSafeNumber(v.qq_vip)
			data.cur_avatar_box_id = v.cur_avatar_box_id
			data.upass_is_buy, data.upass_is_show = FriendSystem.ParseUpassInfo(v.upass)  -- 绝地通行证
			data.aliasId = v.alias.id;
			data.aliasTitle = v.alias.title;
			data.aliasNation = v.alias.nation;

			if v.social_card == nil then
				data.tendency = 0
				data.playDate = 0
				data.playTime = 0
				data.cityId = 0
				data.expertArea_1 = 0
				data.expertArea_2 = 0
			else
				data.tendency = v.social_card.tendency or 0
				data.playDate = v.social_card.play_date or 0
				data.playTime = v.social_card.play_time or 0
				data.cityId = v.social_card.city_id or 0

				if v.social_card.expert_area ~= nil then
					if v.social_card.expert_area[1] ~= nil then
						data.expertArea_1 = v.social_card.expert_area[1] or 0
					else
						data.expertArea_1 = 0
					end

					if v.social_card.expert_area[2] ~= nil then
						data.expertArea_2 = v.social_card.expert_area[2] or 0
					else
						data.expertArea_2 = 0
					end
				else
					data.expertArea_1 = 0
					data.expertArea_2 = 0
				end
			end
			table.insert(BP_ARRAY_Search_Friend_Profile, data)
		end
    end
    
    FriendSystem.SortSearchList(BP_ARRAY_Search_Friend_Profile)
	--log_tree("BP_ARRAY_Search_Friend_Profile:", BP_ARRAY_Search_Friend_Profile)
    --刷新查找列表
	LobbyFriendUI:UpdateSearchList()
end

--请求黑名单拉取陌生人概要数据
function FriendSystem.on_batch_get_blacklist_profile_rsp(profileList)
	--log_tree("black profile:",profileList)

	for k,v in pairs(profileList) do
		local has = false
		for i= #BP_ARRAY_Blacklist_Friend_Profile,1,-1 do
			if tonumber(BP_ARRAY_Blacklist_Friend_Profile[i].gid) == tonumber(v.uid) then
				BP_ARRAY_Blacklist_Friend_Profile[i].nickName = v.nickName
				BP_ARRAY_Blacklist_Friend_Profile[i].level = v.level
				BP_ARRAY_Blacklist_Friend_Profile[i].picUrl = v.picUrl
				BP_ARRAY_Blacklist_Friend_Profile[i].vipLevel = v.vipLevel
				BP_ARRAY_Blacklist_Friend_Profile[i].platName = v.platName
				BP_ARRAY_Blacklist_Friend_Profile[i].sex = v.sex
				BP_ARRAY_Blacklist_Friend_Profile[i].lastOnlineTime = v.lastOnlineTime
				BP_ARRAY_Blacklist_Friend_Profile[i].lastLoginTime = v.lastLoginTime
				BP_ARRAY_Blacklist_Friend_Profile[i].exp = v.exp
                ----------------------------------------intl modify--------------------------------------
                --[[
				BP_ARRAY_Blacklist_Friend_Profile[i].segment_info_solo = v.segment_info[1]
				BP_ARRAY_Blacklist_Friend_Profile[i].segment_info_duo = v.segment_info[2]
				BP_ARRAY_Blacklist_Friend_Profile[i].segment_info_squad = v.segment_info[3]
                ]]
                BP_ARRAY_Blacklist_Friend_Profile[i].AllSegment_Info = v.segment_info;
                for k, v in pairs(BP_ARRAY_Blacklist_Friend_Profile[i].AllSegment_Info) do
                    BP_ARRAY_Blacklist_Friend_Profile[i].segment_info_solo   = BP_ARRAY_Blacklist_Friend_Profile[i].AllSegment_Info [k][1];
                    BP_ARRAY_Blacklist_Friend_Profile[i].segment_info_duo    = BP_ARRAY_Blacklist_Friend_Profile[i].AllSegment_Info [k][2];
                    BP_ARRAY_Blacklist_Friend_Profile[i].segment_info_squad = BP_ARRAY_Blacklist_Friend_Profile[i].AllSegment_Info [k][3];
                    break;
                end
                BP_ARRAY_Blacklist_Friend_Profile[i].segment_info_solo,  BP_ARRAY_Blacklist_Friend_Profile[i].segment_info_duo,  BP_ARRAY_Blacklist_Friend_Profile[i].segment_info_squad =  FuncUtil.GetMaxSegement( BP_ARRAY_Blacklist_Friend_Profile[i].AllSegment_Info );
                ----------------------------------------intl modify--------------------------------------
				BP_ARRAY_Blacklist_Friend_Profile[i].history_max_segment_level = v.history_max_segment_level
				BP_ARRAY_Blacklist_Friend_Profile[i].startup_type = GetSafeNumber(v.startup_type)
				BP_ARRAY_Blacklist_Friend_Profile[i].qq_vip = GetSafeNumber(v.qq_vip)
				BP_ARRAY_Blacklist_Friend_Profile[i].cur_avatar_box_id = v.cur_avatar_box_id
				BP_ARRAY_Blacklist_Friend_Profile[i].upass_is_buy, BP_ARRAY_Blacklist_Friend_Profile[i].upass_is_show = FriendSystem.ParseUpassInfo(v.upass)  -- 绝地通行证
				BP_ARRAY_Blacklist_Friend_Profile[i].aliasId = v.alias.id;
				BP_ARRAY_Blacklist_Friend_Profile[i].aliasTitle = v.alias.title;
				BP_ARRAY_Blacklist_Friend_Profile[i].aliasNation = v.alias.nation;
				has = true
				break
			end
		end

		if not has then
			local data = {}
			data.gid = v.uid
			data.nickName = v.nickName
			data.level = v.level
			data.picUrl = v.picUrl
			data.vipLevel = v.vipLevel
			data.platName = v.platName
			data.sex = v.sex
			data.lastOnlineTime = v.lastOnlineTime
			data.lastLoginTime = v.lastLoginTime
			data.exp = v.exp
            ----------------------------------------intl modify--------------------------------------
            --[[
			data.segment_info_solo = v.segment_info[1]
			data.segment_info_duo = v.segment_info[2]
			data.segment_info_squad = v.segment_info[3]
            ]]
            data.AllSegment_Info = v.segment_info;
            for kseg, v in pairs(data.AllSegment_Info) do
                 data.segment_info_solo   = data.AllSegment_Info[kseg][1];
                 data.segment_info_duo    = data.AllSegment_Info[kseg][2];
                 data.segment_info_squad = data.AllSegment_Info[kseg][3];
                 break;
            end
            data.segment_info_solo,  data.segment_info_duo,  data.segment_info_squad =  FuncUtil.GetMaxSegement( data.AllSegment_Info );
             ----------------------------------------intl modify--------------------------------------
	     		data.history_max_segment_level = v.history_max_segment_level;
			data.startup_type = GetSafeNumber(v.startup_type)
			data.qq_vip = GetSafeNumber(v.qq_vip)
			data.cur_avatar_box_id = v.cur_avatar_box_id
			data.upass_is_buy, data.upass_is_show = FriendSystem.ParseUpassInfo(v.upass)  -- 绝地通行证
			data.aliasId = v.alias.id;
			data.aliasTitle = v.alias.title;
			data.aliasNation = v.alias.nation;
			table.insert(BP_ARRAY_Blacklist_Friend_Profile, data)
		end
	end

	--log_tree("BP_ARRAY_Blacklist_Friend_Profile",BP_ARRAY_Blacklist_Friend_Profile)
	--刷新黑名单列表
	if BP_Friend_Is_Show then
		LobbyFriendUI:UpdateBlackist()
	end
end

-----------------------------------------------------------拉黑好友----------------------------------------
function FriendSystem.AddBlack(friUid)
	FriendSystem.add_black_list_req(friUid)
end

--拉黑好友
-- uid: 准备拉黑的好友uid
function FriendSystem.add_black_list_req(friUid)
    --log("add_black_list_req:"..friUid)

	for i = 1,#BP_ARRAY_Friend_ID_Blacklist,1 do
		if tonumber(BP_ARRAY_Friend_ID_Blacklist[i]) == tonumber(friUid) then
			--已经拉黑该好友
			local msgConfig = Client.GetTableData("LocalizeRes", 200009);
			if msgConfig then
				PopUpNoticeUI.ShowFastNoticeQueue(msgConfig.TextValue);
			end
		end
	end
    NetUtil.SendPkg("add_black_list_req", tonumber(friUid))
end

--拉黑回包
-- res 字符串返回码, "ok" 正常， 其他为错误
-- uid: 拉黑的好友uid
function FriendSystem.on_add_black_list_rsp(res,friUid)
	log("on_add_black_list_rsp:"..res)
	if res == "ok" then
		--拉黑成功
		local msgConfig = Client.GetTableData("LocalizeRes", 200010);
		if msgConfig then
			PopUpNoticeUI.ShowFastNoticeQueue(msgConfig.TextValue);
		end
		table.insert(BP_ARRAY_Friend_ID_Blacklist,friUid)
		--刷新黑名单列表
		if BP_Friend_Is_Show then
			FriendSystem.refresh_black_list_panel(BP_ARRAY_Friend_ID_Blacklist)
		end

		--拉黑以后告知聊天和组队系统（显示上移除）
		FriendSystem.ProcessDeleteFriend(friUid)
	elseif res == "fri_repeat" then
		--已经在黑名单中
		local msgConfig = Client.GetTableData("LocalizeRes", 200009);
		if msgConfig then
			PopUpNoticeUI.ShowFastNoticeQueue(msgConfig.TextValue);
		end
	elseif res == "fri_list_full" then
		--黑名单列表已满
		local msgConfig = Client.GetTableData("LocalizeRes", 200012);
		if msgConfig then
			PopUpNoticeUI.ShowFastNoticeQueue(msgConfig.TextValue);
		end
	elseif res == "fri_not_exist" then
		--好友不存在
		local msgConfig = Client.GetTableData("LocalizeRes", 200013);
		if msgConfig then
			PopUpNoticeUI.ShowFastNoticeQueue(msgConfig.TextValue);
		end
	end
end

--解除屏蔽
-- uid: 准备从黑名单中移除的好友uid
function FriendSystem.del_black_list_req(friUid)
	log("del_black_list_req:"..friUid)
    NetUtil.SendPkg("del_black_list_req", friUid)
end

-- res 字符串返回码,"ok" 正常,其他为错误
-- uid: 从黑名单移除的的好友uid
function FriendSystem.on_del_black_list_rsp(res,friUid)
	log("on_del_black_list_rsp:"..res)

	if res == "ok" then
		for i = #BP_ARRAY_Friend_ID_Blacklist,1,-1 do
			if tonumber(BP_ARRAY_Friend_ID_Blacklist[i]) == tonumber(friUid) then
				table.remove(BP_ARRAY_Friend_ID_Blacklist,i)
				break
			end
		end
		--log_tree("blacklist_id",BP_ARRAY_Friend_ID_Blacklist)

		for i = #BP_ARRAY_Blacklist_Friend_Profile,1,-1 do
			if tonumber(BP_ARRAY_Blacklist_Friend_Profile[i].gid) == tonumber(friUid) then
				table.remove(BP_ARRAY_Blacklist_Friend_Profile,i)
				break
			end
		end

		--log_tree("blacklist_profile",BP_ARRAY_Blacklist_Friend_Profile)
		--刷新黑名单列表
		if BP_Friend_Is_Show then
			LobbyFriendUI:UpdateBlackist()

			-- 将拉黑好友显示到好友列表
			local isInnerFriend = FriendSystem.IsInnerFriend(friUid)
			if isInnerFriend then
				FriendSystem.SortInnerFriendList()
				--LobbyFriendUI:UpdateInnerList()
			end

			local isPlatFriend = FriendSystem.IsPlatFriend(friUid)
			if isPlatFriend then
				FriendSystem.SortPlatFriendList()
				--LobbyFriendUI:UpdatePlatList()
			end

			--通知其他系统
			FriendSystem.ProcessAddFriend()
		end
	else
		log("delete black fail")
	end
end

--请求黑名单列表
function FriendSystem.get_black_list_req()
    log("get_black_list_req")

    NetUtil.SendPkg("get_black_list_req")
end

-- 黑名单列表回包
-- res 字符串返回码, "ok" 正常， 其他为错误
-- uid 玩家uid
-- list = {[1]=uid1, [2]=uid2, [3]=uid3, ...}
function FriendSystem.on_get_black_list_rsp(res,uid,blacklist)
    --log_tree("on_get_black_list_rsp:", blacklist)

	-- 返回给自己
	if res == "ok" then
		if tonumber(uid) == tonumber(DataMgr.roleData.uid) then
			BP_ARRAY_Friend_ID_Blacklist = {}
			BP_ARRAY_Blacklist_Friend_Profile = {}
			for k,v in pairs(blacklist) do
				table.insert(BP_ARRAY_Friend_ID_Blacklist, v)
			end
			--刷新黑名单列表
			if BP_Friend_Is_Show then
				FriendSystem.refresh_black_list_panel(BP_ARRAY_Friend_ID_Blacklist)
			end
		end
	else
		log("on_get_black_list_rsp.."..res)
	end
end

--刷新黑名单界面（黑名单只存id列表，概要数据从好友系统获取）
function FriendSystem.refresh_black_list_panel(idList)
	if next(idList) == nil then
		log("black list is nil")
	end

	local list = FriendSystem.SortFriendList2() -- 已做去重
	local toGetList = {}
	for k,v in pairs(idList) do
		local has = false
		for i = #list,1,-1 do
			if tonumber(list[i].gid) == tonumber(v) then
				table.insert(BP_ARRAY_Blacklist_Friend_Profile,list[i])
				has = true
				break
			end
		end

		-- 黑名单中存在未缓存的id，再请求一次概要
		if not has then
			table.insert(toGetList,v)
		end
	end

	--无额外数据需要请求，刷新界面
	if next(toGetList) == nil then
		LobbyFriendUI:UpdateBlackist()
	else
		-- 需要请求陌生人的概要数据
		ProfileMgr.GetProfileList(toGetList,FriendSystem.on_batch_get_blacklist_profile_rsp)
	end
end
-----------------------------------------------------------拉黑好友----------------------------------------

function FriendSystem.on_batch_get_apply_profile_rsp(profileList)
	--log_tree("apply profile:", profileList)

    for k,v in pairs(profileList) do
        for kk, vv in pairs(BP_ARRAY_Apply_Friend_Profile) do
            if tonumber(vv.gid) == tonumber(v.uid) then
                vv.nickName = v.nickName
				vv.level = v.level
				vv.picUrl = v.picUrl
				vv.vipLevel = v.vipLevel
				vv.platName = v.platName
				vv.sex = v.sex
				vv.lastOnlineTime = v.lastOnlineTime
				vv.lastLoginTime = v.lastLoginTime
				vv.exp = v.exp
                ----------------------------------------intl modify--------------------------------------
                --[[
				vv.segment_info_solo = v.segment_info[1]
				vv.segment_info_duo = v.segment_info[2]
				vv.segment_info_squad = v.segment_info[3]
                ]]
                vv.AllSegment_Info = v.segment_info
                 for kseg, vseg in pairs(vv.AllSegment_Info) do
                       vv.segment_info_solo   = vv.AllSegment_Info[kseg][1];
                       vv.segment_info_duo    = vv.AllSegment_Info[kseg][2];
                       vv.segment_info_squad = vv.AllSegment_Info[kseg][3];
                       break;
                 end
                vv.segment_info_solo,  vv.segment_info_duo,  vv.segment_info_squad =  FuncUtil.GetMaxSegement( vv.AllSegment_Info );
                ----------------------------------------intl modify--------------------------------------
                		vv.history_max_segment_level = v.history_max_segment_level;
				vv.startup_type = GetSafeNumber(v.startup_type)
				vv.qq_vip = GetSafeNumber(v.qq_vip)
				vv.cur_avatar_box_id = v.cur_avatar_box_id
				vv.upass_is_buy, vv.upass_is_show = FriendSystem.ParseUpassInfo(v.upass)  -- 绝地通行证
				vv.aliasId = v.alias.id;
				vv.aliasTitle = v.alias.title;
				vv.aliasNation = v.alias.nation;
				break
            end
        end
    end

	--刷新小红点
	if BP_Friend_Is_Show then
		LobbyFriendUI:UpdateApplyNewTips()
		LobbyFriendUI:UpdateApplyList()
	end

	FriendSystem.UpdateLobbyFriendNewTips()
	--log_tree("BP_ARRAY_Apply_Friend_Profile:", BP_ARRAY_Apply_Friend_Profile)
end

-----------------------------------------------------------请求申请列表好友----------------------------------------
--请求申请列表
function FriendSystem.get_addfriend_reqlist_req()
    log("get_addfriend_reqlist_req")

    NetUtil.SendPkg("get_addfriend_reqlist_req")
end

function FriendSystem.on_get_addfriend_reqlist_rsp(res, uid, addfriend_reqlist)
    log_tree("on_get_addfriend_reqlist_rsp:", addfriend_reqlist)

    local idlist = {}
    BP_ARRAY_Apply_Friend_Profile = {}
    for k,v in pairs(addfriend_reqlist) do
        table.insert(idlist, k)
        local pro = {gid = k, op = v.op, applyMsg = v.applyMsg,createTime = v.createTime,createTimeStr = FriendSystem.FormatTime(v.createTime,"")}
        table.insert(BP_ARRAY_Apply_Friend_Profile, pro)
    end

	if next(idlist) == nil then
		return
	else
		-- 好友申请列表不为空显示小红点
		if BP_Friend_Is_Show then
			LobbyFriendUI:UpdateApplyNewTips()
		end
		FriendSystem.UpdateLobbyFriendNewTips()
	end

    ProfileMgr.GetProfileList(idlist,FriendSystem.on_batch_get_apply_profile_rsp)
	--log_tree("BP_ARRAY_Apply_Friend_Profile:", BP_ARRAY_Apply_Friend_Profile)
end
-----------------------------------------------------------请求申请列表好友----------------------------------------

-- 批量返回好友在线和组队信息
function FriendSystem.on_batch_get_group_and_online_rsp(listType,res,infos)
	log("on_batch_get_group_and_online_rsp:"..listType)
	--log("zinores  "..res)
	--log("zinolistType  "..listType)
	if res == "ok" then
		if listType == "all" then
			-- log_tree("online and team info all",infos)

			FriendSystem.updateOnlineAndGroupInfo(infos,BP_ARRAY_All_Friend_Profile,listType)
			--log_tree("zino BP_ARRAY_All_Friend_Profile", BP_ARRAY_All_Friend_Profile)
			FLAG_ONLINE_AND_TEAMINFO_ALL = true
			TeamUPFriendUI.UpdateTeamUpProfile()
			FriendSystem.PullFriendList()
			LobbyFriendUI.RefreshInnerPanel()
			
		elseif listType == "updateteam" then
			--log_tree("online and team info updateteam",infos)

			FriendSystem.updateOnlineAndGroupInfo(infos,BP_ARRAY_All_Friend_Profile,listType)
			FriendSystem.ProcessStateChange()
		elseif listType == "recentteammate" then
			--log_tree("online and team info recentteammate",infos)
			FriendSystem.updateOnlineAndGroupInfo(infos,BP_ARRAY_Recent_Teammate_Profile,listType)
			table.sort(BP_ARRAY_Recent_Teammate_Profile,SortRecentFunc)
			FLAG_RECENTTEAMMATE_ONLINE_AND_TEAMINFO = true
			FriendSystem.NotifyUpdateRecentTeammatePanel()
			--派发最近组队成员状态变化事件
			EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_RECENT_STATE_UPDATE);
		elseif listType == "nearby" then
			FriendSystem.updateOnlineAndGroupInfo(infos,BP_ARRAY_Near_By_Profile,listType);
			FriendSystem.NearByStatusReady = true;
			FriendSystem.CheckNearByQueryReady();
		elseif listType == "MasterDisciple" then
			--FriendSystem.updateOnlineAndGroupInfo(infos,BP_ARRAY_MasterDiscipleSearchList,listType);
			--MasterDiscipleSystem.on_batch_get_search_status_rsp();
		elseif listType == "MasterServerRecommend" then
			--FriendSystem.updateOnlineAndGroupInfo(infos,BP_ARRAY_ServerRecommendList,listType);
			--MasterDiscipleSystem.on_batch_get_server_recommend_status_rsp();
		elseif listType == "recentcarteam" then
			--更新战队成员状态
			AllianceSystem.UpdateAlliaceMemberStatu(infos);
			--派发战队成员状态
			EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_RECENT_STATE_UPDATE);
		elseif listType == "corpsTeamup" then
			--派发消息
			EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_CORPS_STATE_UPDATE,infos);
		end
	else
		log("on_batch_get_group_and_online_rsp fail:"..res)
	end
end

-- 更新好友状态缓存
function FriendSystem.GetProfileById(id)
	for i,info in ipairs(BP_ARRAY_All_Friend_Profile) do
		if tonumber(info.gid) == tonumber(id) then
			return info
		end
	end

	return nil
end

function FriendSystem.updateOnlineAndGroupInfoCache(infos,profileList,listType)
	log("friendlog FriendSystem.updateOnlineAndGroupInfoCache......")

	for k,v in pairs(infos) do
		local has = false
		for	i = #profileList,1,-1 do
			if tonumber(profileList[i].gid) == tonumber(k) then
				
				local info = FriendSystem.GetProfileById(profileList[i].gid)
				if info ~= nil then
					log("friendlog 更新好友亲密度之类......"..profileList[i].gid)
					profileList[i].lastPresentCoinTime = info.lastPresentCoinTime
					profileList[i].bPresentedCoin = info.bPresentedCoin
					profileList[i].intimacy = info.intimacy
				end

				log("friendlog 更新好友状态......"..profileList[i].gid.."v.online"..v.online)
				profileList[i].online = v.online
				profileList[i].teamState = v.teamState
				profileList[i].currentTeamAmount = v.currentTeamAmount
				profileList[i].maxTeamAmount = v.maxTeamAmount
				profileList[i].timeSinceGameBegin = v.timeSinceGameBegin
				profileList[i].timeSinceGameBeginStamp = os.time() - v.timeSinceGameBegin

				profileList[i].timeSinceGameBeginStr = FriendSystem.FormatTime2(v.timeSinceGameBegin)
				profileList[i].game_mode = v.game_mode
				if v.game_mode == 0 then
					if BP_Friend_MatchMode_Map["101"] ~= nil then
						profileList[i].gameModeStr = BP_Friend_MatchMode_Map["101"].modeStr or ""
					else
						profileList[i].gameModeStr = ""
					end
				else
					if BP_Friend_MatchMode_Map[tostring(v.game_mode)] ~= nil then
						profileList[i].gameModeStr = BP_Friend_MatchMode_Map[tostring(v.game_mode)].modeStr or ""
					else
						profileList[i].gameModeStr = ""
					end
				end

				has = true
				if listType ~= "recentteammate" then
					break
				end
			end
		end

		if not has then
			local data = {}
			data.gid = k
			data.online = v.online
			data.teamState = v.teamState
			data.currentTeamAmount = v.currentTeamAmount
			data.maxTeamAmount = v.maxTeamAmount
			data.timeSinceGameBegin = v.timeSinceGameBegin
			data.timeSinceGameBeginStamp = os.time() - v.timeSinceGameBegin

			data.timeSinceGameBeginStr = FriendSystem.FormatTime2(v.timeSinceGameBegin)
			data.game_mode = v.game_mode
			if v.game_mode == 0 then
				if BP_Friend_MatchMode_Map["101"] ~= nil then
					data.gameModeStr = BP_Friend_MatchMode_Map["101"].modeStr
				else
					data.gameModeStr = ""
				end
			else
				if BP_Friend_MatchMode_Map[tostring(v.game_mode)] ~= nil then
					data.gameModeStr = BP_Friend_MatchMode_Map[tostring(v.game_mode)].modeStr or ""
				else
					data.gameModeStr = ""
				end
			end

			local info = FriendSystem.GetProfileById(data.gid)
			if info ~= nil then
				log("friendlog 更新好友亲密度之类......"..data.gid)
				data.lastPresentCoinTime = info.lastPresentCoinTime
				data.bPresentedCoin = info.bPresentedCoin
				data.intimacy = info.intimacy
			end
			table.insert(profileList,data)
		end
	end

	-- log_tree("friendlog FriendSystem.friendStatusCache ",FriendSystem.friendStatusCache)
end

function FriendSystem.updateOnlineAndGroupInfo(infos,profileList,listType)
	FriendSystem.updateOnlineAndGroupInfoCache(infos,FriendSystem.friendStatusCache,listType)

	log("friendlog FriendSystem.updateOnlineAndGroupInfo......")

	for k,v in pairs(infos) do
		local has = false
		for	i = #profileList,1,-1 do
			if tonumber(profileList[i].gid) == tonumber(k) then
				log("friendlog 更新好友状态......"..profileList[i].gid.."v.online"..v.online)
				profileList[i].online = v.online
				profileList[i].teamState = v.teamState
				profileList[i].currentTeamAmount = v.currentTeamAmount
				profileList[i].maxTeamAmount = v.maxTeamAmount
				profileList[i].timeSinceGameBegin = v.timeSinceGameBegin
				profileList[i].timeSinceGameBeginStamp = os.time() - v.timeSinceGameBegin

				profileList[i].timeSinceGameBeginStr = FriendSystem.FormatTime2(v.timeSinceGameBegin)
				profileList[i].game_mode = v.game_mode
				if v.game_mode == 0 then
					if BP_Friend_MatchMode_Map["101"] ~= nil then
						profileList[i].gameModeStr = BP_Friend_MatchMode_Map["101"].modeStr or ""
					else
						profileList[i].gameModeStr = ""
					end
				else
					if BP_Friend_MatchMode_Map[tostring(v.game_mode)] ~= nil then
						profileList[i].gameModeStr = BP_Friend_MatchMode_Map[tostring(v.game_mode)].modeStr or ""
					else
						profileList[i].gameModeStr = ""
					end
				end

				has = true
				if listType ~= "recentteammate" then
					break
				end
			end
		end

		if not has then
			local data = {}
			data.gid = k
			data.online = v.online
			data.teamState = v.teamState
			data.currentTeamAmount = v.currentTeamAmount
			data.maxTeamAmount = v.maxTeamAmount
			data.timeSinceGameBegin = v.timeSinceGameBegin
			data.timeSinceGameBeginStamp = os.time() - v.timeSinceGameBegin

			data.timeSinceGameBeginStr = FriendSystem.FormatTime2(v.timeSinceGameBegin)
			data.game_mode = v.game_mode
			if v.game_mode == 0 then
				if BP_Friend_MatchMode_Map["101"] ~= nil then
					data.gameModeStr = BP_Friend_MatchMode_Map["101"].modeStr
				else
					data.gameModeStr = ""
				end
			else
				if BP_Friend_MatchMode_Map[tostring(v.game_mode)] ~= nil then
					data.gameModeStr = BP_Friend_MatchMode_Map[tostring(v.game_mode)].modeStr or ""
				else
					data.gameModeStr = ""
				end
			end
			table.insert(profileList,data)
		end
	end

	-- g___dddddddd = BP_ARRAY_All_Friend_Profile
	-- log_tree("friendlog g___dddddddd",g___dddddddd)

	--if (listType == "nearby") then
	--	log_tree("nearby profileList",profileList)
	--end
end

function FriendSystem.NotifyPullFriendList()
	if FLAG_PROFILE_ALL == true then
		FLAG_PROFILE_ALL = false
		FLAG_ONLINE_AND_TEAMINFO_ALL = false
		log("friendsystem notifypullfriendlist")

		-- log_tree("friendlog BP_ARRAY_All_Friend_Profile all:", BP_ARRAY_All_Friend_Profile)

		--临时解决不显示好友的问题（需要和国服的开发人员确定）
		FriendSystem.SortInnerFriendList()
		FriendSystem.SortPlatFriendList()
		----

		FriendSystem.RefreshFriendList(ADD_FRIEND,REFRESH_PANEL)
		if ADD_FRIEND then
			-- 弹出提示，和谁成为好友
			if tonumber(FRIEND_AGREE_UID) ~= 0 then
				for i = 1,#BP_ARRAY_All_Friend_Profile,1 do
					if tonumber(BP_ARRAY_All_Friend_Profile[i].gid) == tonumber(FRIEND_AGREE_UID) then
						local msg = Client.GetTableData("LocalizeRes",200014)
						if msg then
							local str = string.format(msg.TextValue,BP_ARRAY_All_Friend_Profile[i].nickName)
							PopUpNoticeUI.ShowFastNoticeQueue(str)
							FRIEND_AGREE_UID = 0
						end
						break
					end
				end
			end
			FriendSystem.ProcessAddFriend()
			ADD_FRIEND = false
		end
		FriendSystem.PullFriendList()
	end
end

function FriendSystem.RefreshFriendList(addFriend,refreshPanel)
	log("FriendSystem.RefreshFriendList--------------"..tostring(addFriend))
	if BP_Platform == BP_ENUM_PLAYFORM_WX or BP_Platform == BP_ENUM_PLAYFORM_QQ or BP_Platform == BP_ENUM_PLAYFORM_VK or BP_Platform == BP_ENUM_PLAYFORM_QQByiTOP then
		if BP_Friend_Is_Show then
			if addFriend == nil or addFriend == false then
				if BP_Friend_Send_Item then
					-- 赠送道具给好友模式
					LobbyFriendUI:UpdateAllFriends(FriendSystem.SortFriendList())
				else
					FriendSystem.SortPlatFriendList()
					FriendSystem.SortInnerFriendList()
				end
			elseif addFriend == true then
				FriendSystem.SortInnerFriendList()
				if refreshPanel == true then
					--LobbyFriendUI:UpdateInnerList()
					REFRESH_PANEL = false
				end
			end
			LobbyFriendUI:UpdateApplyNewTips()
		end
	else -- 游客模式
		if BP_Friend_Is_Show then
			if BP_Friend_Send_Item then
				-- 赠送道具给好友模式
				LobbyFriendUI:UpdateAllFriends(FriendSystem.SortFriendList())
			else
				FriendSystem.SortInnerFriendList()
				--LobbyFriendUI:UpdateInnerList()
				LobbyFriendUI:UpdateApplyNewTips()
			end
		end
	end
end
-----------------------------------------------------------返回概要信息----------------------------------------

-----------------------------------------------------------发送好友申请----------------------------------------
function FriendSystem.AddFriend(friUid,from,msgId)
	local id = 21
	if msgId ~= nil and msgId > 0 then
		id = msgId
	end
	FriendSystem.add_inner_friend_req(friUid, "",from,id)
end

--请求加好友 from标识从哪里加好友,用于经分统计,类型定义在cs_macros.lua中
function FriendSystem.add_inner_friend_req(friUid, msg,from,msgId)
	if friUid == nil then
		return
	end

	local fromSystem = 0
	if from ~= nil and from ~= "" then
		fromSystem = from
	end

	local id = 21
	if msgId ~= nil and msgId > 0 then
		id = tonumber(msgId)
	end

	local sendMsg = msg
	if sendMsg == nil or sendMsg == "" then
		local msgConfig = Client.GetTableData("FriendApplyConfig",id)
		if msgConfig then
			sendMsg = msgConfig.DefaultWords
		end
	end

	--如既无传入字符串且从好友申请配置表中读取不到字段，采用默认语
	if sendMsg == nil or sendMsg == "" then
		local localizeConfig = Client.GetTableData("LocalizeRes",200006)
		if localizeConfig  then
			sendMsg = localizeConfig.TextValue
		end
	end

	log("add_inner_friend_req:" .. friUid .. "  sendMsg:" .. sendMsg)
    NetUtil.SendPkg("add_inner_friend_req", tonumber(friUid), sendMsg,fromSystem)

	if fromSystem == BP_ENUM_ADD_FRIEND_FROM_FRIEND_SEARCH or fromSystem == BP_ENUM_ADD_FRIEND_FROM_FRIEND_RECENTTEAMMATE or
	fromSystem == BP_ENUM_ADD_FRIEND_FROM_FRIEND_NEARBY then
		LobbyFriendUI:RefreshAddFriendBtnState(fromSystem,friUid)
	end
end

function FriendSystem.present_friend_gold_req(friUid,optype)
	log("FriendSystem.present_friend_gold_req!")
	--客户端自定义字段，服务器透传
	--op = 1时，表示邮件批量赠送时调用，不需要在on_present_friend_gold_rsp里提示
	local msg = { op = optype} ;
    NetUtil.SendPkg("present_friend_gold_req", tonumber(friUid),msg)
end

function FriendSystem.on_present_friend_gold_rsp(res,friUid,msg)
	if res == "ok" then
        --赠送成功
        log("present_friend_gold succ")
		local curTime = FuncUtil.GetServerTimeInSec()
		local friend = FriendSystem.GetFriendDataByGID(friUid);

		local function shareToFriend()
			--好友数据里没有openid的信息，只能根据昵称去查询openid。(不要问我为什么。。。)
			FriendSystem.get_openid_by_nickname_req(friend.nickName,"friendpresentcoin")
			--local params = {openid = friend.openid,title = DataMgr.GetMsgByID(200021),desc = DataMgr.GetMsgByID(200022)}
			--ShareMgr:shareToFriend(params)
			DataMgr.ShowNoticeFastQueueByID(102031);
			--log("----------------------shareToFriend")
		end
		if friend ~= nil then
			friend.lastPresentCoinTime = curTime
			friend.bPresentedCoin = 1
		end
		--[[
		-- op = 0 表示单个赠送，op = 1表示批量同时调用此接口
		if msg ~= nil and msg.op == 1 then
			--不提示
		else
			if friend ~= nil then
				friend.lastPresentCoinTime = curTime
				friend.bPresentedCoin = 1
				if FriendSystem.IsPlatFriend(friUid) then

					if GlobalData:GetPlatform() == BP_ENUM_PLAYFORM_WX then
						CommonMessageBoxUI:ShowPanel(2, DataMgr.GetMsgByID(102012), DataMgr.GetMsgByID(102032), shareToFriend,nil,DataMgr.GetMsgByID(102027),DataMgr.GetMsgByID(102026));
					elseif GlobalData:GetPlatform() == BP_ENUM_PLAYFORM_QQ then
						CommonMessageBoxUI:ShowPanel(2, DataMgr.GetMsgByID(102012), DataMgr.GetMsgByID(102028), shareToFriend,nil,DataMgr.GetMsgByID(102027),DataMgr.GetMsgByID(102026));
					end

				end
			end
		end
		]]

		local friendPlat = FriendSystem.GetPlatFriendDataByGID(friUid);
		if friendPlat ~= nil then
			friendPlat.lastPresentCoinTime = curTime
			friendPlat.bPresentedCoin = 1
			LobbyFriendUI:UpdatePlatList()
		end

		local friendInner = FriendSystem.GetInnerFriendDataByGID(friUid);
		if friendInner ~= nil then
			friendInner.lastPresentCoinTime = curTime
			friendInner.bPresentedCoin = 1
			LobbyFriendUI:UpdateInnerList()
		end

		--DataMgr.ShowNoticeByString("赠送成功")

		local msgConfig = Client.GetTableData("LocalizeRes", 200018);
		if msgConfig then
			PopUpNoticeUI.ShowFastNoticeQueue(msgConfig.TextValue);
		end
	elseif res == "limit" then
		--每日赠送次数达到上限;
		log("present_friend-limit")
		local msgConfig = Client.GetTableData("LocalizeRes", 200019);
		if msgConfig then
			PopUpNoticeUI.ShowFastNoticeQueue(msgConfig.TextValue);
		end
	elseif res == "in_blacklist" then
		--每日赠送次数达到上限;
		log("present_friend-in_blacklist")
		local msgConfig = Client.GetTableData("LocalizeRes", 200023);
		if msgConfig then
			PopUpNoticeUI.ShowFastNoticeQueue(msgConfig.TextValue);
		end
	elseif res == "repeat" then
		--同一个好友不能赠送多次
		log("present_friend-repeat")
		local curTime = FuncUtil.GetServerTimeInSec()
		local friend = FriendSystem.GetFriendDataByGID(friUid);
		if friend ~= nil then
			friend.lastPresentCoinTime = curTime
			friend.bPresentedCoin = 1
		end

		friend = FriendSystem.GetPlatFriendDataByGID(friUid);
		if friend ~= nil then
			friend.lastPresentCoinTime = curTime
			friend.bPresentedCoin = 1
			LobbyFriendUI:UpdatePlatList()
		end

		friend = FriendSystem.GetInnerFriendDataByGID(friUid);
		if friend ~= nil then
			friend.lastPresentCoinTime = curTime
			friend.bPresentedCoin = 1
			LobbyFriendUI:UpdateInnerList()
		end

		local msgConfig = Client.GetTableData("LocalizeRes", 200020);
		if msgConfig then
			PopUpNoticeUI.ShowFastNoticeQueue(msgConfig.TextValue);
		end
	end
	--do something
end

-- 赠送道具给好友
function FriendSystem.send_friend_item_req(friUid, itemID, num)
	log("FriendSystem.send_friend_item_req "..friUid..", "..tostring(itemID))
    NetUtil.SendPkg("send_friend_item_req", tonumber(friUid), itemID, num)
end

-- 赠送道具给好友的回包
function FriendSystem.on_send_friend_item_rsp(res)
	log("FriendSystem.on_send_friend_item_rsp "..res);
	if res == "ok" then
		LobbyFriendUI:SendItemSuccess();
	else
		local msg = Client.GetTableData("LocalizeRes", 501043);
		if msg then
			local str = msg.TextValue;
			PopUpNoticeUI.ShowFastNoticeQueue(str);
		end
	end
end

--请求加好友,只针对这个消息是否发送成功，返回给发送者
function FriendSystem.on_add_inner_friend_rsp(res, endtime, reason)
	log("on_add_inner_friend_rsp")

    if res == "ok" then
        --发送成功
        log("send invite succ")

		local msg = Client.GetTableData("LocalizeRes",200001);
		if msg then
			local str = msg.TextValue
			PopUpNoticeUI.ShowFastNoticeQueue(str)
		end
	elseif res == "ban-add-friend" then
        log("endtime"..endtime)
        log("reason"..reason)
        local title = Client.GetTableData("LocalizeRes", "101001").TextValue;
        local timevalue = Client.GetTableData("LocalizeRes", "115005").TextValue;
        local date = os.date(timevalue, endtime);
        local textvalue = Client.GetTableData("LocalizeRes", "115007").TextValue;
        text = string.format(textvalue, reason.."\n", date)
        CommonMessageBoxUI:ShowPanel(1, title, text);
	elseif res == "fri_already" then
		--已经是好友
		log("fri_already")

		local msg = Client.GetTableData("LocalizeRes",200007);
		if msg then
			local str = msg.TextValue
			PopUpNoticeUI.ShowFastNoticeQueue(str)
		end
	elseif res == "fri_list_full" then
		--对方好友申请已满
		log("fri_list_full")
		--DataMgr.ShowNoticeByID(200008)
	elseif res == "fri_repeat" then
		log("fri_repeat")

		local msg = Client.GetTableData("LocalizeRes",200002);
		if msg then
			local str = msg.TextValue
			PopUpNoticeUI.ShowFastNoticeQueue(str)
		end
	elseif res == "fri_self" then
		log("fri_self")

		local msg = Client.GetTableData("LocalizeRes",200004);
		if msg then
			local str = msg.TextValue
			PopUpNoticeUI.ShowFastNoticeQueue(str)
		end
	else
		log("add friend fail")

		local msg = Client.GetTableData("LocalizeRes",200005);
		if msg then
			local str = msg.TextValue
			PopUpNoticeUI.ShowFastNoticeQueue(str)
		end
    end
	LobbyFriendUI:SendInviteSuccess()
end

--请求加好友,返回给被接收者，add_req_friend为发送申请者的ID
function FriendSystem.on_add_inner_friend_notify(add_req_friend, msg,msgcreateTime)
    --将这个塞到邀请列表里面 BP_ARRAY_Apply_Friend_Profile
	log("on_add_inner_friend_notify")

	local idlist = {}
	table.insert(idlist, add_req_friend)
    local pro = {gid = tostring(add_req_friend), op = -1, applyMsg = msg,createTime = msgcreateTime,createTimeStr = FriendSystem.FormatTime(msgcreateTime,"")}
    table.insert(BP_ARRAY_Apply_Friend_Profile, pro)

	--log_tree("BP_ARRAY_Apply_Friend_Profile:",BP_ARRAY_Apply_Friend_Profile)
	ProfileMgr.GetFriendProfileList(idlist,FriendSystem.on_batch_get_apply_profile_rsp)
end
-----------------------------------------------------------发送好友申请----------------------------------------

-----------------------------------------------------------处理好友申请----------------------------------------
--被邀请人回复friUid是否同意  op=1，同意；op=0,拒绝；-1 未操作
function FriendSystem.add_inner_friend_op_req(friUid, op)
	if FriendSystem.ClickAgreeBtnTimeStamp == nil then
		FriendSystem.ClickAgreeBtnTimeStamp = 0
	end

	local timeDiff = os.time() - FriendSystem.ClickAgreeBtnTimeStamp
	if timeDiff > FriendSystem.ClickAgreeBtnTimeThreshold then
		log("add_inner_friend_op_req:"..friUid.." op:"..op)
		log("add_inner_friend timediff:"..timeDiff)
		FriendSystem.ClickAgreeBtnTimeStamp = os.time()
		NetUtil.SendPkg("add_inner_friend_op_req", friUid, op)
		if op == 1 then
			FRIEND_AGREE_UID = friUid
		else
			FRIEND_REFUSE_UID = friUid
		end
	end
end

--添加好友请求好友数据，设置亲密度，赠送金币等默认值
function FriendSystem.AddFriendRequestData(friUid,refreshPanel)
	ADD_FRIEND = true
	REFRESH_PANEL = refreshPanel

	table.insert(ID_INNER_FRIENDLIST, friUid)
	FriendSystem.on_become_friend_delete_black_data(friUid)

	--添加好友设置亲密度默认值，赠送金币
	local profile = {gid=tostring(friUid),intimacy=0,bPresentedCoin=0,lastPresentCoinTime=0,create_time=FuncUtil.GetServerTimeInSec()}
	local has = false
	for i = #BP_ARRAY_All_Friend_Profile,1,-1 do
		if tonumber(BP_ARRAY_All_Friend_Profile[i].gid) == tonumber(friUid) then
			has = true
			-- 如果也是平台好友，好友数据不会删除，需要刷新亲密度,赠送金币属性不用重置,否则赠送金币会自动加平台好友为游戏好友后又可以赠送一次金币
			BP_ARRAY_All_Friend_Profile[i].intimacy = 0
			--好友的添加时间也要重置
			BP_ARRAY_All_Friend_Profile[i].create_time = FuncUtil.GetServerTimeInSec()
			break
		end
	end
	if not has then
		table.insert(BP_ARRAY_All_Friend_Profile,profile)
	end

	-- log_tree("AddFriendRequestData BP_ARRAY_All_Friend_Profile",BP_ARRAY_All_Friend_Profile)
	local list = {friUid}
	ProfileMgr.GetFriendProfileList(list,FriendSystem.on_batch_get_all_profile_rsp)
	NetUtil.SendPkg("batch_get_group_and_online_req","all",list)
end

--被邀请人收到是否同意的回包，返回ok表示已经成为好友（加好友仅针对游戏内好友）
function FriendSystem.on_add_inner_friend_op_rsp(res, friUid,op)
    --这里还不知道谁和玩家是好友关系，所以要再加个id
    log("on_add_inner_friend_op_rsp res= "..res.." op= "..op.." friUid= "..friUid)

    if res == "ok" then
		if op == 1 then
			FriendSystem.AddFriendRequestData(FRIEND_AGREE_UID,false)
			FriendSystem.on_refresh_friend_apply_lists(friUid)
		else
			FriendSystem.on_refresh_friend_apply_lists(friUid)
			FRIEND_REFUSE_UID = 0
		end
		log("add inner friend op rsp success")
		-- 同意或者拒绝后更新小红点
		if BP_Friend_Is_Show then
			LobbyFriendUI:UpdateApplyNewTips()
		end

		-- 更新大厅界面好友小红点
		FriendSystem.UpdateLobbyFriendNewTips()
	elseif res == "fri_not_exist" then
		log("add inner friend op rsp fri_not_exist")

		local msg = Client.GetTableData("LocalizeRes",200024);
		if msg then
			local str = msg.TextValue
			PopUpNoticeUI.ShowFastNoticeQueue(str)
		end

		FriendSystem.on_delete_invalid_data(op,FRIEND_AGREE_UID,FRIEND_REFUSE_UID)
	elseif res == "fri_already" then
		log("add inner friend op rsp fri_already")

		local msg = Client.GetTableData("LocalizeRes",200007);
		if msg then
			local str = msg.TextValue
			PopUpNoticeUI.ShowFastNoticeQueue(str)
		end

		FriendSystem.on_delete_invalid_data(op,FRIEND_AGREE_UID,FRIEND_REFUSE_UID)
	elseif res == "fri_list_full" then
		log("add inner friend op rsp fri_list_full")

		local msg = Client.GetTableData("LocalizeRes",200008);
		if msg then
			local str = msg.TextValue
			PopUpNoticeUI.ShowFastNoticeQueue(str)
		end
	else
		log("add inner friend op rsp fail")
		FriendSystem.on_delete_invalid_data(op,FRIEND_AGREE_UID,FRIEND_REFUSE_UID)
    end
end

-- 成为好友后清理拉黑数据
function FriendSystem.on_become_friend_delete_black_data(friUid)
	--如果加为好友的人之前被拉黑，加为好友后从黑名单中移除
	for i= #BP_ARRAY_Friend_ID_Blacklist,1,-1 do
		if tonumber(BP_ARRAY_Friend_ID_Blacklist[i]) == tonumber(friUid) then
			table.remove(BP_ARRAY_Friend_ID_Blacklist,i)
			break
		end
	end

	for j = #BP_ARRAY_Blacklist_Friend_Profile,1,-1 do
		if tonumber(BP_ARRAY_Blacklist_Friend_Profile[j].gid == tonumber(friUid)) then
			table.remove(BP_ARRAY_Blacklist_Friend_Profile,j)
			break
		end
	end
end

-- 申请列表无效数据点击同意后根据错误码进行清理
function FriendSystem.on_delete_invalid_data(op,agreeuid,refuseuid)
	if op == 1 then
		FriendSystem.on_refresh_friend_apply_lists(agreeuid)
	else
		FriendSystem.on_refresh_friend_apply_lists(refuseuid)
	end

	if BP_Friend_Is_Show then
		LobbyFriendUI:UpdateApplyNewTips()
	end
	FriendSystem.UpdateLobbyFriendNewTips()
end

--点击同意或者拒绝移除数据，刷新界面
function FriendSystem.on_refresh_friend_apply_lists(removeUid)
	log(" on_refresh_friend_apply_lists "..removeUid)
	-- log_tree("BP_ARRAY_Apply_Friend_Profile_",BP_ARRAY_Apply_Friend_Profile)
	for i = #BP_ARRAY_Apply_Friend_Profile,1,-1 do
		if tonumber(BP_ARRAY_Apply_Friend_Profile[i].gid) == tonumber(removeUid) then
			table.remove(BP_ARRAY_Apply_Friend_Profile,i)
			break
		end
	end
	if BP_Friend_Is_Show then
		LobbyFriendUI:UpdateApplyList()
	end
end

--邀请人收到是否同意的回包
function FriendSystem.on_add_inner_friend_op_notify(op, friUid)
    log("on_add_inner_friend_op_notify op "..op.." friUid "..friUid )

    if op == 1 then
		FriendSystem.AddFriendRequestData(friUid,true)
	else
		log("add inner friend op notify fail")
    end
end

--平台好友一起开黑自动添加好友
function FriendSystem.on_auto_add_inner_friend_notify(uid)
	log(" auto_add_inner_friend_notify"..tostring(uid))
	FriendSystem.AddFriendRequestData(uid,true)
end

--双方互相加好友时其中一方已点击同意，删除另一方相应好友请求
function FriendSystem.on_del_addfriend_req_notify(uid)
	log("on_del_addfriend_req_notify"..uid)

	for i = 1,#BP_ARRAY_Apply_Friend_Profile,1 do
		if BP_ARRAY_Apply_Friend_Profile[i] ~= nil then
			if tonumber(BP_ARRAY_Apply_Friend_Profile[i].gid) == tonumber(uid) then
				table.remove(BP_ARRAY_Apply_Friend_Profile,i)
				break
			end
		end
	end
	--刷新小红点，更新申请列表
	if BP_Friend_Is_Show then
		LobbyFriendUI:UpdateApplyNewTips()
		LobbyFriendUI:UpdateApplyList()
	end
	FriendSystem.UpdateLobbyFriendNewTips()
end
-----------------------------------------------------------处理好友申请----------------------------------------

-----------------------------------------------------------删除好友----------------------------------------
--请求删除好友
function FriendSystem.del_inner_friend_req(friUid)
	if friUid == nil then return end
	
	log("del_inner_friend_req:"..friUid)
	NetUtil.SendPkg("del_inner_friend_req", friUid)
end

--删除好友回包(给自己)
function FriendSystem.on_del_inner_friend_rsp(res)
    log("on_del_inner_friend_rsp:" .. res)
	log("del_inner_friend_id:"..BP_Delete_Friend_ID)

	if res == "ok" then
		FriendSystem.UpdateDeleteFriendData(BP_Delete_Friend_ID)
		FriendSystem.delFriendRemoveIntimacyData(BP_Delete_Friend_ID)
	end
end

-- 批量删除好友
function FriendSystem.del_inner_friend_batch_req(friendUidList)
	log("FriendSystem.del_inner_friend_batch_req:")
	log_tree("friendUidList",friendUidList)

	if friendUidList == nil then return end
	if #friendUidList == 0 then return end

    local result = {}
    for index, value in ipairs(friendUidList) do
        table.insert(result, tonumber(value))
    end
    
	NetUtil.SendPkg("del_inner_friend_batch_req", result)
end

function FriendSystem.del_inner_friend_batch_rsp(res, friendUidList)
	log("FriendSystem.del_inner_friend_batch_rsp:" .. res)
	log_tree("friendUidList",friendUidList)

	if res ~= "ok" then
		return
	end

	for i,uid in ipairs(friendUidList) do
		FriendSystem.UpdateDeleteFriendData(uid)
		FriendSystem.delFriendRemoveIntimacyData(uid)
	end

	-- FriendSystem.SortInnerFriendList(LOGIC_FRIEND_SORT_TYPE.LAST_ONLINE_TIME)
	LobbyFriendUI:BatchDeleteFriendRsp(friendUidList)
end

--删除好友时如果该好友有亲密度数据，需要删除相应的亲密度数据
function FriendSystem.delFriendRemoveIntimacyData(friUid)
	log("delFriendRemoveIntimacyData"..tostring(friUid))
	if next(BP_ARRAY_Intimacy_Data) ~= nil then
		for i = #BP_ARRAY_Intimacy_Data,1,-1 do
			if tonumber(BP_ARRAY_Intimacy_Data[i].gid) == tonumber(friUid) then
				table.remove(BP_ARRAY_Intimacy_Data,i)
				log("delFriendRemoveIntimacyData removed"..tostring(friUid))
				break
			end
		end

		for i = 1,#BP_ARRAY_All_Friend_Profile,1 do
			if tonumber(BP_ARRAY_All_Friend_Profile[i].gid) == tonumber(friUid) then
				BP_ARRAY_All_Friend_Profile[i].intimacy = 0
				break
			end
		end
	end
end

--删除好友回包(给被删除方)
function FriendSystem.on_del_inner_friend_notify(uid)
    log("on_del_inner_friend_notify")
	log("del_inner_friend_id:"..uid)

	LobbyFriendUI:OnOneDelete( uid )
	FriendSystem.UpdateDeleteFriendData(uid)
	FriendSystem.delFriendRemoveIntimacyData(uid)
end

function FriendSystem.UpdateDeleteFriendData(uid)
	local isPlatFriend = false
	for i = #ID_PLAT_FRIENDLIST,1,-1 do
		if tonumber(ID_PLAT_FRIENDLIST[i]) == tonumber(uid) then
			isPlatFriend = true
			break
		end
	end

	for index,vv in pairs(FriendSystem.friendStatusCache) do
		if tonumber(uid) == tonumber(vv.gid) then
			log("cache 删除亲密度命中=0")
			vv.intimacy = 0
		end
	end

	for i = 1,#BP_ARRAY_All_Friend_Profile,1 do
		if tonumber(BP_ARRAY_All_Friend_Profile[i].gid) == tonumber(uid) then
			log("删除亲密度命中=0")
			BP_ARRAY_All_Friend_Profile[i].intimacy = 0
			break
		end
	end

	if not isPlatFriend then
		for i = #BP_ARRAY_All_Friend_Profile,1,-1 do
			if tonumber(BP_ARRAY_All_Friend_Profile[i].gid) == tonumber(uid) then
				table.remove(BP_ARRAY_All_Friend_Profile,i)
				break
			end
		end

		-- 删除好友时如果该好友已被拉黑且不是平台好友需要删除黑名单相关信息
		for j = #BP_ARRAY_Friend_ID_Blacklist,1,-1 do
			if tonumber(BP_ARRAY_Friend_ID_Blacklist[j]) == tonumber(uid) then
				table.remove(BP_ARRAY_Friend_ID_Blacklist,j)
				break
			end
		end
		for k = #BP_ARRAY_Blacklist_Friend_Profile,1,-1 do
			if tonumber(BP_ARRAY_Blacklist_Friend_Profile[k].gid) == tonumber(uid) then
				table.remove(BP_ARRAY_Blacklist_Friend_Profile,k)
				break
			end
		end

		--非平台好友才可以删除
		FriendSystem.ProcessDeleteFriend(uid)
	end

	for i = #ID_INNER_FRIENDLIST,1,-1 do
		if tonumber(ID_INNER_FRIENDLIST[i]) == tonumber(uid) then
			table.remove(ID_INNER_FRIENDLIST,i)
			break
		end
	end

	--更新主界面大厅的好友列表 samizheng 2018-05-01
	LuaClassObj.HandleUIMessage(bp_lobby, "UpdateFriendList");

	if BP_Friend_Is_Show then
	
		if BP_IsInBatchDelete == true then
			FriendSystem.SortInnerFriendList(LOGIC_FRIEND_SORT_TYPE.LAST_ONLINE_TIME)
		else
			FriendSystem.SortInnerFriendList()
		end

		--删除好友item
		--LobbyFriendUI:UpdateInnerList()
	end
end
-----------------------------------------------------------删除好友----------------------------------------

-----------------------------------------------------------好友亲密度变更------------------------------------------
--只通知自己
function FriendSystem.notify_friend_intimacy_chg(friUid,chg,newIntimacy)
	log("notify_friend_intimacy_chg "..friUid..", chg="..chg..", newIntimacy="..newIntimacy)
	local nickName = ""
	for i = 1,#BP_ARRAY_All_Friend_Profile,1 do
		if tonumber(BP_ARRAY_All_Friend_Profile[i].gid) == tonumber(friUid) then
			BP_ARRAY_All_Friend_Profile[i].intimacy = tonumber(newIntimacy)
			nickName = BP_ARRAY_All_Friend_Profile[i].nickName
			break
		end
	end

	--tips提示（和xxx亲密度变化多少，仅在好友界面显示）
	-- if BP_Friend_Is_Show then
	local str =  GlobalData.GetLocalizeStringWithNum(6470, 1, nickName,tostring(chg));
	if str then
		PopUpNoticeUI.ShowFastNoticeQueue(str)
	end
	-- end

	--刷新游戏好友界面亲密度显示
	--界面数据变化，需要重新更新蓝图BP数据 samizheng 2018-05-01
	if BP_Friend_Is_Show then
		log("BP_Friend is Show SortInnerFriendList")
		FriendSystem.SortInnerFriendList()
		LobbyFriendUI:UpdateInnerList()
	else
		log("BP_Friend is not show")
		LobbyFriendUI:UpdateInnerList()
	end

	EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_INTIMACY_UPDATE, friUid, newIntimacy);
end
-----------------------------------------------------------好友亲密度变更------------------------------------------

-----------------------------------------------------------好友组队状态变更----------------------------------------
-- 更新好友在线状态
function FriendSystem.on_notify_online_status_chg(uid,isOnline)
	log("[HHF]FriendSystem.on_notify_online_status_chg, uid = " .. uid .. ", isOnline = " .. tostring(isOnline))

	if next(BP_ARRAY_All_Friend_Profile) == nil then
		return
	end

	for i = #BP_ARRAY_All_Friend_Profile,1,-1 do
		if tonumber(BP_ARRAY_All_Friend_Profile[i].gid) == tonumber(uid) then
			BP_ARRAY_All_Friend_Profile[i].online = isOnline
			break
		end
	end
	--log_tree("on_notify_online_status_chg all", BP_ARRAY_All_Friend_Profile)

	FriendSystem.ProcessOnlineStateChange()
end

-- 更新好友组队状态
function FriendSystem.on_notify_group_status_chg(uid,newStatus)
	log_tree("on_notify_group_status_chg:",newStatus,"StatusManager")

	if next(BP_ARRAY_All_Friend_Profile) == nil then
		return
	end

	for i = #BP_ARRAY_All_Friend_Profile,1,-1 do
		if tonumber(BP_ARRAY_All_Friend_Profile[i].gid) == tonumber(uid) then
			BP_ARRAY_All_Friend_Profile[i].teamState = newStatus.teamState
			BP_ARRAY_All_Friend_Profile[i].currentTeamAmount = newStatus.currentTeamAmount
			BP_ARRAY_All_Friend_Profile[i].maxTeamAmount = newStatus.maxTeamAmount
			BP_ARRAY_All_Friend_Profile[i].teamId = newStatus.teamId
			BP_ARRAY_All_Friend_Profile[i].timeSinceGameBegin = newStatus.timeSinceGameBegin
			BP_ARRAY_All_Friend_Profile[i].timeSinceGameBeginStamp = os.time() - newStatus.timeSinceGameBegin

			BP_ARRAY_All_Friend_Profile[i].timeSinceGameBeginStr = FriendSystem.FormatTime2(newStatus.timeSinceGameBegin)
			BP_ARRAY_All_Friend_Profile[i].game_mode = newStatus.game_mode
			BP_ARRAY_All_Friend_Profile[i].enableWatch = newStatus.enable_watch or 1
			BP_ARRAY_All_Friend_Profile[i].teamState = newStatus.teamStateNew or 0
			--log("[CCL] enableWatch5 "..tostring(BP_ARRAY_All_Friend_Profile[i].enableWatch))
			if newStatus.game_mode == 0 then
				if BP_Friend_MatchMode_Map["101"] ~= nil then
					BP_ARRAY_All_Friend_Profile[i].gameModeStr = BP_Friend_MatchMode_Map["101"].modeStr or ""
				else
					BP_ARRAY_All_Friend_Profile[i].gameModeStr = ""
				end
			else
				if BP_Friend_MatchMode_Map[tostring(newStatus.game_mode)] ~= nil then
					BP_ARRAY_All_Friend_Profile[i].gameModeStr = BP_Friend_MatchMode_Map[tostring(newStatus.game_mode)].modeStr or ""
				else
					BP_ARRAY_All_Friend_Profile[i].gameModeStr = ""
				end
			end
			break
		end
	end
	--log_tree("on_notify_online_status_chg all", BP_ARRAY_All_Friend_Profile)

	FriendSystem.ProcessStateChange()
end
-----------------------------------------------------------好友组队状态变更----------------------------------------

function FriendSystem.invite_offline_friend_req(channel)
	FriendSystem.InviteChannnel = channel;
	log("[HHF]FriendSystem.invite_offline_friend_req, channel = " .. tostring(FriendSystem.InviteChannnel));
	NetUtil.SendPkg("invite_offline_friend_req");
	--FriendSystem.invite_offline_friend_rsp("ok", "123456789");
end

function FriendSystem.ConstructInviteLink(language, uid, teamid, source)
	local link = "";
	local region = Client.GetPublishRegion();
	if region == "JAPAN" or region == "KOREA" then
		--link = "https://mqf5.adj.st/module=1003100&uid=" .. DataMgr.roleData.uid .. "&teamid=" .. teamid .. "?adjust_t=309y2te_92lgiiw&adjust_deeplink=igame1321%3a%2f%2fmodule%3d1003100%26uid%3d" .. DataMgr.roleData.uid .. "%26teamid%3d" .. teamid;
		link = "https://www.pubgmobile.com/" .. language .. "/event/inviteplay/?module=1003100&uid=" .. uid .. "&teamid=" .. teamid .. "&src=" .. source .. "&adjust_t=309y2te_92lgiiw&adjust_deeplink=igame1321%3a%2f%2fmodule%3d1003100%26uid%3d" .. uid .. "%26teamid%3d" .. teamid .. "%26src%3d" .. source .. "&region=jk";
	elseif region == "VNG" then
		--link = "https://uqp6.adj.st/module=1003100&uid=" .. DataMgr.roleData.uid .. "&teamid=" .. teamid .. "?adjust_t=ieqk3q5_j6dc7yr&adjust_deeplink=igame1380%3a%2f%2fmodule%3d1003100%26uid%3d" .. DataMgr.roleData.uid .. "%26teamid%3d" .. teamid;
		link = "https://www.pubgmobile.com/" .. language .. "/event/inviteplay/?module=1003100&uid=" .. uid .. "&teamid=" .. teamid .. "&src=" .. source .. "&adjust_t=ieqk3q5_j6dc7yr&adjust_deeplink=igame1380%3a%2f%2fmodule%3d1003100%26uid%3d" .. uid .. "%26teamid%3d" .. teamid .. "%26src%3d" .. source .. "&region=vn";
	elseif region == "TW" then
		--link = "https://uqp6.adj.st/module=1003100&uid=" .. DataMgr.roleData.uid .. "&teamid=" .. teamid .. "?adjust_t=2yw4nqf_v7xgqie&adjust_deeplink=igame1380%3a%2f%2fmodule%3d1003100%26uid%3d" .. DataMgr.roleData.uid .. "%26teamid%3d" .. teamid;
		link = "https://www.pubgmobile.com/" .. language .. "/event/inviteplay/?module=1003100&uid=" .. uid .. "&teamid=" .. teamid .. "&src=" .. source .. "&adjust_t=2yw4nqf_v7xgqie&adjust_deeplink=igame1390%3a%2f%2fmodule%3d1003100%26uid%3d" .. uid .. "%26teamid%3d" .. teamid .. "%26src%3d" .. source .. "&region=tw";
	else
		--link = "https://uqp6.adj.st/module=1003100&uid=" .. DataMgr.roleData.uid .. "&teamid=" .. teamid .. "?adjust_t=d05sefz_ejv4ir5&adjust_deeplink=igame1320%3a%2f%2fmodule%3d1003100%26uid%3d" .. DataMgr.roleData.uid .. "%26teamid%3d" .. teamid;
		link = "https://www.pubgmobile.com/" .. language .. "/event/inviteplay/?module=1003100&uid=" .. uid .. "&teamid=" .. teamid .. "&src=" .. source .. "&adjust_t=d05sefz_ejv4ir5&adjust_deeplink=igame1320%3a%2f%2fmodule%3d1003100%26uid%3d" .. uid .. "%26teamid%3d" .. teamid .. "%26src%3d" .. source .. "&region=gl";
	end

	log("[HHF]FriendSystem.ConstructInviteLink, link = " .. link);
	return link;
end

function FriendSystem.invite_offline_friend_rsp(res, teamid)
	log("[HHF]FriendSystem.invite_offline_friend_rsp, res = " .. res .. ", teamid = " .. teamid);
	if res == "ok" then
		local title = FuncUtil.GetLocalizeResStr("106052");
		local tips = FuncUtil.GetLocalizeResStr("4488");
		local link = FriendSystem.ConstructInviteLink(Client.GetCurrentLanguage(), DataMgr.roleData.uid, teamid, FriendSystem.InviteChannnel);
		
		if FriendSystem.InviteChannnel == InviteJoinTeamUI.InviteByMessenger then
			local content = FuncUtil.GetLocalizeResStr("4366");
			Client.InviteFBOfflineFriends(NetInterface, title, content, link);
		elseif FriendSystem.InviteChannnel == InviteJoinTeamUI.InviteBySMS then
			local content = tips .. " " .. link;
			Client.InviteSMSOfflineFriends(NetInterface, content);
		elseif FriendSystem.InviteChannnel == InviteJoinTeamUI.InviteByWhatsapp then
			local content = tips .. " " .. link;
			Client.InviteWhatsappOfflineFriends(NetInterface, title, content);
		elseif FriendSystem.InviteChannnel == InviteJoinTeamUI.InviteBySystem then
			local content = tips .. " " .. link;
			Client.InviteSystemOfflineFriends(NetInterface, title, content);
		elseif FriendSystem.InviteChannnel == InviteJoinTeamUI.InviteByLine then
			local content = tips .. " " .. link;
			Client.InviteLineOfflineFriends(NetInterface, title, content);
		end
	elseif res == "team_is_full" then
		DataMgr.ShowNoticeByID(110019);
	end
end

-----------------------------------------------------------查询好友openid----------------------------------------
function FriendSystem.get_openid_by_nickname_req(nickname, cb)
	log("FriendSystem.get_openid_by_nickname_req")
	NetUtil.SendPkg("get_openid_by_nickname_req", nickname, cb)
end

function FriendSystem.get_openid_by_nickname_rsp(nickname, res, openid, cb)
	log("FriendSystem.get_openid_by_nickname_rsp"..tostring(res))
	if res == "ok" then
		if cb == "offlineInvite" then
			--如果是邀请上线查询，则发送邀请上线分享
			local friend = FriendSystem.GetFriendDataByNickname(nickname);
			local gid = nil;
			if friend ~= nil then
				gid = tonumber(friend.gid);
				FriendSystem.check_and_update_invite_plat_req(gid);
			end
			local params = {};
			params.openid = openid;
			params.title = DataMgr.GetMsgByID(110106);
			params.desc = DataMgr.GetMsgByID(110107);
			if gid ~= nil then
				local extendInfo = {};
				extendInfo.invite_info = {inviter = gid};
				params.extendInfo = FuncUtil:EncodeURI(json.encode(extendInfo));
			end
			ShareMgr:shareToFriend(params);

		elseif cb == "friendpresentcoin" then

			local params = {openid = openid,title = DataMgr.GetMsgByID(200021),desc = DataMgr.GetMsgByID(200022) ,adtag = GameCenterADTAG.heart,gameTag="MSG_HEART_SEND"}
			ShareMgr:shareToFriend(params);

        -- 加QQ好友
        elseif cb == "AddQQFriend" then
            log("GetOpenId AddQQFriend")
            local params = {}
            params.openid = openid
            params.desc = BP_FriendSystem_SelectedFriendNickNameAddQQFriend
            local message = DataMgr.GetMsgByID(200029)
            params.message = string.format(message, DataMgr.roleData.nickName)

            ShareMgr:addQQFriend(params)
        end
    else
        DataMgr.ShowNoticeByID(200013)
	end
end
-----------------------------------------------------------查询好友openid----------------------------------------

-----------------------------------------------------------更新邀请好友上线时间----------------------------------------
function FriendSystem.check_and_update_invite_plat_req(friUid)
	log("FriendSystem.check_and_update_invite_plat_req");
	NetUtil.SendPkg("check_and_update_invite_plat_req", friUid);
end

function FriendSystem.check_and_update_invite_plat_rsp(res, friUid)
	log("FriendSystem.check_and_update_invite_plat_rsp");
	if res == "ok" then
		local friend = FriendSystem.GetFriendDataByGID(friUid);
		if friend ~= nil then
			friend.lastInviteTime = FuncUtil.GetServerTimeInSec();
			TeamUPFriendUI.UpdateAllFriendStatus();
		end
		--DataMgr.ShowNoticeByString("邀请成功");
		DataMgr.ShowNoticeByString(Client.GetTableData("LocalizeRes", "301265").TextValue);
	else
		log("FriendSystem.check_and_update_invite_plat_rsp:" .. res);
	end
end
-----------------------------------------------------------更新邀请好友上线时间----------------------------------------

-----------------------------------------------------------通知最近组队数据--------------------------------
function FriendSystem.on_notify_team_result_finished()
	log("on notify team result finished")
	FriendSystem.getRecentTeammate()
end
-----------------------------------------------------------通知最近组队数据--------------------------------

-----------------------------------------------------------亲密关系相关协议--------------------------------
function FriendSystem.InitIntimacyDetailData()--可做缓存
	if FriendSystem.HasInitIntimacyDetailData == true then
		return
	end

	BP_Array_Intimacy_DetailData = {}
	for i = 1,4,1 do
		local intimacyData = {}
		intimacyData.relation = i
		intimacyData.curCount = 0
		if intimacyData.relation == 2 then
			intimacyData.maxCount = BP_Friend_Intimacy_Lover_MaxCount--恋人只有一个
		else
			intimacyData.maxCount = BP_Friend_Intimacy_Other_MaxCount--其余关系数量
		end
		intimacyData.relationStr = FriendSystem.GetRelationNameByType(intimacyData.relation).."("..tostring(intimacyData.curCount).."/"..tostring(intimacyData.maxCount)..")"
		table.insert(BP_Array_Intimacy_DetailData,intimacyData)
	end
	FriendSystem.HasInitIntimacyDetailData = true
end

--刷新亲密关系数量
function FriendSystem.RefreshIntimacyDetailData()
	if next(BP_ARRAY_Intimacy_Data) == nil then
		log("RefreshIntimacyDetailData BP_ARRAY_Intimacy_Data is nil")
		FriendSystem.InitIntimacyDetailData()
		return
	end

	local jiyouCount = 0
	local loversCount = 0
	local sidangCount = 0
	local guimiCount = 0

	for i = 1,#BP_ARRAY_Intimacy_Data,1 do
		--已建立亲密关系的好友
		if tonumber(BP_ARRAY_Intimacy_Data[i].state) == 4 then
			local relation = tonumber(BP_ARRAY_Intimacy_Data[i].param)
			if relation == 1 then
				jiyouCount = jiyouCount + 1
			elseif relation == 2 then
				loversCount = loversCount + 1
			elseif relation == 3 then
				sidangCount = sidangCount + 1
			elseif relation == 4 then
				guimiCount = guimiCount + 1
			end
		end
	end

	BP_Array_Intimacy_DetailData = {}
	for i = 1,4,1 do
		local intimacyData = {}
		intimacyData.relation = i

		if intimacyData.relation == 1 then
			intimacyData.curCount = jiyouCount
		elseif intimacyData.relation == 2 then
			intimacyData.curCount = loversCount
		elseif intimacyData.relation == 3 then
			intimacyData.curCount = sidangCount
		elseif intimacyData.relation == 4 then
			intimacyData.curCount = guimiCount
		end

		if intimacyData.relation == 2 then
			intimacyData.maxCount = BP_Friend_Intimacy_Lover_MaxCount--恋人只有一个
		else
			intimacyData.maxCount = BP_Friend_Intimacy_Other_MaxCount--其余关系数量
		end
		intimacyData.relationStr = FriendSystem.GetRelationNameByType(intimacyData.relation).."("..tostring(intimacyData.curCount).."/"..tostring(intimacyData.maxCount)..")"
		table.insert(BP_Array_Intimacy_DetailData,intimacyData)
	end

	if BP_Friend_Is_Show then
		log("RefreshIntimacyArray")
		LobbyFriendUI:RefreshIntimacyArray()
	end
end

function FriendSystem.RefreshIntimacyRelationPanel()
	local hasInit = true

	if next(BP_ARRAY_Intimacy_Data) ~= nil then
		for i = 1,#BP_ARRAY_Intimacy_Data,1 do
			--异步拉取亲密度数据和好友数据，需确保数据完整性
			if BP_ARRAY_Intimacy_Data[i].sex == nil or BP_ARRAY_Intimacy_Data[i].sex == 0 then
				hasInit = false
				break
			end
		end

		if hasInit then
			log("hasInit true")
		else
			for k,v in pairs(BP_ARRAY_Intimacy_Data) do
				local find = false
				for i = 1,#BP_ARRAY_All_Friend_Profile,1 do
					if tonumber(v.gid) == tonumber(BP_ARRAY_All_Friend_Profile[i].gid) then
						find = true
						v.nickName = BP_ARRAY_All_Friend_Profile[i].nickName
						v.level = BP_ARRAY_All_Friend_Profile[i].level
						v.picUrl = BP_ARRAY_All_Friend_Profile[i].picUrl
						v.vipLevel = BP_ARRAY_All_Friend_Profile[i].vipLevel
						v.sex = BP_ARRAY_All_Friend_Profile[i].sex
						v.signature = BP_ARRAY_All_Friend_Profile[i].signature
						v.intimacy = BP_ARRAY_All_Friend_Profile[i].intimacy
						v.segment_info_solo = BP_ARRAY_All_Friend_Profile[i].segment_info_solo
						v.segment_info_duo = BP_ARRAY_All_Friend_Profile[i].segment_info_duo
						v.segment_info_squad = BP_ARRAY_All_Friend_Profile[i].segment_info_squad
						v.history_max_segment_level = BP_ARRAY_All_Friend_Profile[i].history_max_segment_level
						v.cur_avatar_box_id = BP_ARRAY_All_Friend_Profile[i].cur_avatar_box_id
						v.upass_is_buy = BP_ARRAY_All_Friend_Profile[i].upass_is_buy
						v.upass_is_show = BP_ARRAY_All_Friend_Profile[i].upass_is_show
						v.aliasId = BP_ARRAY_All_Friend_Profile[i].aliasId;
						v.aliasTitle = BP_ARRAY_All_Friend_Profile[i].aliasTitle;
						v.aliasNation = BP_ARRAY_All_Friend_Profile[i].aliasNation;
					end
				end
			end
			if next(BP_ARRAY_Intimacy_Data) ~= nil then
				FriendSystem.spliceAndSortIntimacyData(BP_ARRAY_Intimacy_Data,SortIntimcayData)
			end
		end
	end

	if BP_Friend_Is_Show then
		LobbyFriendUI:UpdateIntimacyRelationPanel()
	end
end

--排序规则
function SortIntimcayData(a,b)
	if a.stateSortPriority == nil or b.stateSortPriority == nil then
		return false
	end

	if a.stateSortPriority == b.stateSortPriority then
		if a.relationSortPriority == nil or b.relationSortPriority == nil then
			return false
		end

		if a.relationSortPriority == b.relationSortPriority then
			if a.intimacy == nil or b.intimacy == nil then
				return false
			end

			return a.intimacy > b.intimacy
		else
			return a.relationSortPriority > b.relationSortPriority
		end
	else
		return a.stateSortPriority > b.stateSortPriority
	end
end

function FriendSystem.spliceAndSortIntimacyData(list,sortFunc)
	for i = 1,#list,1 do
		local state = list[i].state

		if state == 0 then
			list[i].stateSortPriority = 1
		elseif state == 1 then
			list[i].stateSortPriority = 3
		elseif state == 2 then
			list[i].stateSortPriority = 2
		elseif state == 3 then
			list[i].stateSortPriority = 0
		elseif state == 4 then
			list[i].stateSortPriority = 4
		end

		list[i].relation = FriendSystem.getRelationByGid(tonumber(list[i].gid))
		list[i].relationSortPriority = 1

		local relation = list[i].relation
		if relation == 1 then
			list[i].relationSortPriority = 2
		elseif relation == 2 then
			list[i].relationSortPriority = 4
		elseif relation == 3 then
			list[i].relationSortPriority = 1
		elseif relation == 4 then
			list[i].relationSortPriority = 3
		end
	end
	--排序后删除多余数据
	table.sort(list,sortFunc)
	if #BP_ARRAY_Intimacy_Data > BP_Friend_Intimacy_MaxCount then
		for i = #BP_ARRAY_Intimacy_Data,1,-1 do
			if i > BP_Friend_Intimacy_MaxCount then
				table.remove(BP_ARRAY_Intimacy_Data,i)
			end
		end
	end
	--log_tree("BP_ARRAY_Intimacy_Data",BP_ARRAY_Intimacy_Data)
end

--获取指定好友的亲密关系
function FriendSystem.getRelationByGid(gid)
	local relation = 0

	if next(BP_ARRAY_Intimacy_Data) ~= nil then
		for i = 1,#BP_ARRAY_Intimacy_Data,1 do
			if tonumber(BP_ARRAY_Intimacy_Data[i].gid) == tonumber(gid) and tonumber(BP_ARRAY_Intimacy_Data[i].state) == 4 then
				relation = tonumber(BP_ARRAY_Intimacy_Data[i].param)
				break
			end
		end
	end

	return relation
end

--获取好友亲密关系相关数据
function FriendSystem.getIntimacyRelationReq(IsNeedRedpoint)
	log("getIntimacyRelationReq")

	local timeDiff = os.time() - FriendSystem.ClickIntimacyTabTimeStamp
	if timeDiff > FriendSystem.ClickIntimacyTabTimeThreshold then
		FriendSystem.ClickIntimacyTabTimeStamp = os.time()
		NetUtil.SendPkg("get_intimacy_relation_req", IsNeedRedpoint or false)
	else
		--数据不全需要重新取值，全则刷新界面
		FriendSystem.RefreshIntimacyRelationPanel()
	end
end

function FriendSystem.on_get_intimacy_relation_rsp(list)
	log("on_get_intimacy_relation_rsp")
	--log_tree("on_get_intimacy_relation_rsp",list)

	BP_ARRAY_Intimacy_Data = {}
	FriendSystem.InitIntimacyDetailData()

	for k,v in pairs(list) do
		--处于非删除状态才显示
		local data = {}
		data.gid = tostring(k)
		data.state = v.state
		--state不同含义不同
		data.param = v.param

		--是否能查找到对应的好友数据
		local has = false
		for i = 1,#BP_ARRAY_All_Friend_Profile,1 do
			if tonumber(data.gid) == tonumber(BP_ARRAY_All_Friend_Profile[i].gid) then
				has = true
				data.nickName = BP_ARRAY_All_Friend_Profile[i].nickName
				data.level = BP_ARRAY_All_Friend_Profile[i].level
				data.picUrl = BP_ARRAY_All_Friend_Profile[i].picUrl
				data.vipLevel = BP_ARRAY_All_Friend_Profile[i].vipLevel
				data.sex = BP_ARRAY_All_Friend_Profile[i].sex
				data.signature = BP_ARRAY_All_Friend_Profile[i].signature
				data.intimacy = BP_ARRAY_All_Friend_Profile[i].intimacy
				data.segment_info_solo = BP_ARRAY_All_Friend_Profile[i].segment_info_solo
				data.segment_info_duo = BP_ARRAY_All_Friend_Profile[i].segment_info_duo
				data.segment_info_squad = BP_ARRAY_All_Friend_Profile[i].segment_info_squad
				data.history_max_segment_level = BP_ARRAY_All_Friend_Profile[i].history_max_segment_level
				data.cur_avatar_box_id = BP_ARRAY_All_Friend_Profile[i].cur_avatar_box_id
				data.upass_is_buy = BP_ARRAY_All_Friend_Profile[i].upass_is_buy
				data.upass_is_show = BP_ARRAY_All_Friend_Profile[i].upass_is_show
				data.aliasId = BP_ARRAY_All_Friend_Profile[i].aliasId;
				data.aliasTitle = BP_ARRAY_All_Friend_Profile[i].aliasTitle;
				data.aliasNation = BP_ARRAY_All_Friend_Profile[i].aliasNation;
                data.roleNation = ProfileMgr.GetRoleNationByUid(data.gid);
				break
			end
		end

		if has then
			table.insert(BP_ARRAY_Intimacy_Data,data)
		end

		--已删除状态检测亲密度是否满足
		if v.state == 3 then
			local intimacy = FriendSystem.getInnerFriendIntimacyByGid(k)
			for i = #BP_ARRAY_Intimacy_Data,1,-1 do
				if tonumber(BP_ARRAY_Intimacy_Data[i].gid) == tonumber(k) then
					if intimacy >= BP_Friend_Intimacy_Threshold then
						BP_ARRAY_Intimacy_Data[i].state = 0
						BP_ARRAY_Intimacy_Data[i].param = intimacy
					else
						table.remove(BP_ARRAY_Intimacy_Data,i)
					end
					break
				end
			end
		end
	end

	if next(BP_Array_Intimacy_DetailData) ~= nil then
		table.sort(BP_Array_Intimacy_DetailData,SortIntimacyDetailData)
	end

	if next(BP_ARRAY_Intimacy_Data) ~= nil then
		FriendSystem.spliceAndSortIntimacyData(BP_ARRAY_Intimacy_Data,SortIntimcayData)
	end

	FriendSystem.UpdateIntimacyNewTips()
	FriendSystem.UpdateLobbyFriendNewTips()
	FriendSystem.RefreshIntimacyDetailData()

	-- 刷新亲密关系界面
	if BP_Friend_Is_Show then
		LobbyFriendUI:UpdateIntimacyRelationPanel()
	end
end

--亲密关系下拉列表排序
function SortIntimacyDetailData(a,b)
	if a.relation == nil or b.relation == nil then
		return false
	end
	return a.relation < b.relation
end

--与谁建立何种亲密关系
function FriendSystem.buildIntimacyRelationReq(friUid,relation)
	log("buildIntimacyRelationReq friUid:"..tostring(friUid).." relation:"..tostring(relation))
	NetUtil.SendPkg("build_intimacy_relation_req",tonumber(friUid),tonumber(relation))
end

--建立亲密关系请求服务器返回结果
function FriendSystem.on_build_intimacy_relation_rsp(res,friUid,relation)
	log("on_build_intimacy_relation_rsp res:"..tostring(res).." friUid:"..tostring(friUid).." relation:"..tostring(relation))

	local relationName = FriendSystem.GetRelationNameByType(relation)
	if res == "ok" then
		--xx关系申请已发送成功
		local msgConfig = Client.GetTableData("LocalizeRes",200034)
		if msgConfig then
			if relationName ~= "" then
				local str = string.format(msgConfig.TextValue,relationName)
				PopUpNoticeUI.ShowFastNoticeQueue(str)
			else
				log("on_build_intimacy_relation_rsp res ok "..tostring(relationName))
			end
		end

		--状态转为已发送亲密关系状态
		for i = 1,#BP_ARRAY_Intimacy_Data,1 do
			if tonumber(BP_ARRAY_Intimacy_Data[i].gid) == tonumber(friUid) then
				BP_ARRAY_Intimacy_Data[i].state = 1
				BP_ARRAY_Intimacy_Data[i].param = relation
				break
			end
		end
		if next(BP_ARRAY_Intimacy_Data) ~= nil then
			FriendSystem.spliceAndSortIntimacyData(BP_ARRAY_Intimacy_Data,SortIntimcayData)
		end

		-- 刷新亲密关系界面
		if BP_Friend_Is_Show then
			LobbyFriendUI:UpdateIntimacyRelationPanel()
		end
	elseif res == "del-cd" then
		--删除亲密关系7天冷却期间内
		local msg = Client.GetTableData("LocalizeRes",200045);
		if msg then
			PopUpNoticeUI.ShowFastNoticeQueue(msg.TextValue)
		end
	elseif res == "full" then
		--对方或自己的亲密关系已满
		local msg = Client.GetTableData("LocalizeRes",200046);
		if msg then
			PopUpNoticeUI.ShowFastNoticeQueue(msg.TextValue)
		end
	elseif res == "invalid-param" then
		--建立的亲密关系无效
		local msg = Client.GetTableData("LocalizeRes",200047);
		if msg then
			PopUpNoticeUI.ShowFastNoticeQueue(msg.TextValue)
		end
	elseif res == "low-intimacy" then
		--亲密度不足以建立任何关系
		local msg = Client.GetTableData("LocalizeRes",200048);
		if msg then
			PopUpNoticeUI.ShowFastNoticeQueue(msg.TextValue)
		end
	elseif res == "already-build" then
		--已经建立亲密关系
		local msg = Client.GetTableData("LocalizeRes",200056);
		if msg then
			PopUpNoticeUI.ShowFastNoticeQueue(msg.TextValue)
		end
	elseif res == "wait-confirm" then
		--等待确认对方发来的请求
		local msg = Client.GetTableData("LocalizeRes",200049);
		if msg then
			PopUpNoticeUI.ShowFastNoticeQueue(msg.TextValue)
		end
	elseif res == "more-intimacy" then
		--亲密度不足够建立指定的关系
		local msg = Client.GetTableData("LocalizeRes",200050);
		if msg then
			PopUpNoticeUI.ShowFastNoticeQueue(msg.TextValue)
		end
	else
		--xx关系申请发送失败
		local msgConfig = Client.GetTableData("LocalizeRes",200038)
		if msgConfig then
			if relationName ~= "" then
				local str = string.format(msgConfig.TextValue,relationName)
				PopUpNoticeUI.ShowFastNoticeQueue(str)
			else
				log("on_build_intimacy_relation_rsp fail "..tostring(relationName))
			end
		end
		log("on_build_intimacy_relation_rsp fail res"..tostring(res))
	end
end

function FriendSystem.delete_invalid_intimacy_data(friUid)
	if next(BP_ARRAY_Intimacy_Data) ~= nil then
		for i = #BP_ARRAY_Intimacy_Data,1,-1 do
			if tonumber(BP_ARRAY_Intimacy_Data[i].gid) == tonumber(friUid) then
				table.remove(BP_ARRAY_Intimacy_Data,i)
				break
			end
		end

		if BP_Friend_Is_Show then
			LobbyFriendUI:UpdateIntimacyRelationPanel()
		end
	end
end

--处理好友亲密关系建议申请(0,拒绝,1,接受)
function FriendSystem.replyIntimacyRelationReq(friUid,relation,op)
	if tonumber(friUid) <= 0 or tonumber(relation) <= 0 then
		log("replyIntimacyRelationReq friUid:"..tostring(friUid).." relation:"..tostring(relation))
		return
	end

	log("replyIntimacyRelationReq friUid:"..tostring(friUid).." relation:"..tostring(relation).." op:"..tostring(op))
	NetUtil.SendPkg("reply_intimacy_relation_req",tonumber(friUid),tonumber(relation),tonumber(op))
end

--处理好友亲密关系申请服务器回包（同意或者拒绝）
function FriendSystem.on_reply_intimacy_relation_rsp(res,friUid,relation,op)
	log("on_reply_intimacy_relation_rsp res:"..tostring(res).." friUid:"..tostring(friUid).." relation:"..tostring(relation).." op:"..tostring(op))

	if res == "ok" then
		if op == 1 then
			for	i = 1,#BP_ARRAY_Intimacy_Data,1 do
				if tonumber(BP_ARRAY_Intimacy_Data[i].gid) == tonumber(friUid) then
					BP_ARRAY_Intimacy_Data[i].state = 4
					BP_ARRAY_Intimacy_Data[i].param = relation
					break
				end
			end

			--您已和xxx建立xx关系
			if BP_Friend_Is_Show then
				local msg = Client.GetTableData("LocalizeRes",200037)
				if msg then
					local relationName = FriendSystem.GetRelationNameByType(tonumber(BP_Friend_Intimacy_Relation))
					local str = string.format(msg.TextValue,BP_Friend_Intimacy_NickName,relationName)
					PopUpNoticeUI.ShowFastNoticeQueue(str)
				end
			end

			--（建立亲密关系后刷新数据（游戏好友页签））
			for i = #BP_ARRAY_Inner_Friend_Profile,1,-1 do
				if tonumber(BP_ARRAY_Inner_Friend_Profile[i].gid) == tonumber(friUid) then
					if BP_ARRAY_Inner_Friend_Profile[i].relation ~= nil then
						BP_ARRAY_Inner_Friend_Profile[i].relation = relation
					else
						BP_ARRAY_Inner_Friend_Profile[i].relation = relation
					end
					break
				end
			end
		else
			--回到状态0还是删除数据取决于和对方的亲密度
			local intimacy = FriendSystem.getInnerFriendIntimacyByGid(friUid)
			for i = #BP_ARRAY_Intimacy_Data,1,-1 do
				if tonumber(BP_ARRAY_Intimacy_Data[i].gid) == tonumber(friUid) then
					if intimacy >= BP_Friend_Intimacy_Threshold then
						BP_ARRAY_Intimacy_Data[i].state = 0
						BP_ARRAY_Intimacy_Data[i].param = intimacy
					else
						table.remove(BP_ARRAY_Intimacy_Data,i)
					end
					break
				end
			end
		end
	elseif res == "not-exist" then
		--删除无效数据
		local msg = Client.GetTableData("LocalizeRes",200051);
		if msg then
			PopUpNoticeUI.ShowFastNoticeQueue(msg.TextValue)
		end
		FriendSystem.deleteReplyIntimacyRelationInvalidData(friUid)
	elseif res == "invalid-param" then
		--relation无效
		local msg = Client.GetTableData("LocalizeRes",200047);
		if msg then
			PopUpNoticeUI.ShowFastNoticeQueue(msg.TextValue)
		end
		FriendSystem.deleteReplyIntimacyRelationInvalidData(friUid)
	elseif res == "low-intimacy" then
		--亲密度不足以建立任何关系
		local msg = Client.GetTableData("LocalizeRes",200048);
		if msg then
			PopUpNoticeUI.ShowFastNoticeQueue(msg.TextValue)
		end
		FriendSystem.deleteReplyIntimacyRelationInvalidData(friUid)
	elseif res == "state-error" then
		--当前状态不是等待确认状态
		local msg = Client.GetTableData("LocalizeRes",200052);
		if msg then
			PopUpNoticeUI.ShowFastNoticeQueue(msg.TextValue)
		end
		FriendSystem.deleteReplyIntimacyRelationInvalidData(friUid)
	elseif res == "relation-error" then
		--等待确认的关系和发送上来的关系不一致
		local msg = Client.GetTableData("LocalizeRes",200053);
		if msg then
			PopUpNoticeUI.ShowFastNoticeQueue(msg.TextValue)
		end
		FriendSystem.deleteReplyIntimacyRelationInvalidData(friUid)
	end

	if next(BP_ARRAY_Intimacy_Data) ~= nil then
		FriendSystem.spliceAndSortIntimacyData(BP_ARRAY_Intimacy_Data,SortIntimcayData)
	end

	FriendSystem.UpdateIntimacyNewTips()
	FriendSystem.UpdateLobbyFriendNewTips()
	FriendSystem.RefreshIntimacyDetailData()
	if BP_Friend_Is_Show then
		LobbyFriendUI:UpdateIntimacyRelationPanel()
	end
end

function FriendSystem.deleteReplyIntimacyRelationInvalidData(friUid)
	if next(BP_ARRAY_Intimacy_Data) ~= nil then
		for i = #BP_ARRAY_Intimacy_Data,1,-1 do
			if tonumber(BP_ARRAY_Intimacy_Data[i].gid) == tonumber(friUid) then
				table.remove(BP_ARRAY_Intimacy_Data,i)
				break
			end
		end
	end
end

--删除亲密关系
function FriendSystem.deleteIntimacyRelationReq(friUid)
	log("deleteIntimacyRelationReq friUid:"..tostring(friUid))

	NetUtil.SendPkg("delete_intimacy_relation_req",tonumber(friUid))
end

--删除亲密关系服务器回包
function FriendSystem.on_delete_intimacy_relation_rsp(res,friUid)
	log("on_delete_intimacy_relation_rsp res:"..tostring(res).." friUid:"..tostring(friUid))

	if res == "ok" then
		local intimacy = FriendSystem.getInnerFriendIntimacyByGid(friUid)
		for i = #BP_ARRAY_Intimacy_Data,1,-1 do
			if tonumber(BP_ARRAY_Intimacy_Data[i].gid) == tonumber(friUid) then
				if intimacy >= BP_Friend_Intimacy_Threshold then
					BP_ARRAY_Intimacy_Data[i].state = 0
					BP_ARRAY_Intimacy_Data[i].param = intimacy
				else
					table.remove(BP_ARRAY_Intimacy_Data,i)
				end
				break
			end
		end
		--log_tree("BP_ARRAY_Intimacy_Data",BP_ARRAY_Intimacy_Data)

		--你已解除和xxx的xx关系
		local msg = Client.GetTableData("LocalizeRes",200035);
		if msg then
			if BP_Friend_Intimacy_Delete_NickName ~= "" then
				local relationName = FriendSystem.GetRelationNameByType(tonumber(BP_Friend_Intimacy_Delete_Relation))
				local str = string.format(msg.TextValue,BP_Friend_Intimacy_Delete_NickName,relationName)
				PopUpNoticeUI.ShowFastNoticeQueue(str)
			else
				log("BP_Friend_Intimacy_Delete_NickName "..tostring(BP_Friend_Intimacy_Delete_NickName))
			end
		end

		--好友数据中重置relation字段为0
		for i = #BP_ARRAY_Inner_Friend_Profile,1,-1 do
			if tonumber(BP_ARRAY_Inner_Friend_Profile[i].gid) == tonumber(friUid) then
				if BP_ARRAY_Inner_Friend_Profile[i].relation ~= nil then
					BP_ARRAY_Inner_Friend_Profile[i].relation = 0
					break
				end
			end
		end

		if next(BP_ARRAY_Intimacy_Data) ~= nil then
			FriendSystem.spliceAndSortIntimacyData(BP_ARRAY_Intimacy_Data,SortIntimcayData)
		end

		FriendSystem.RefreshIntimacyDetailData()
		if BP_Friend_Is_Show then
			LobbyFriendUI:UpdateIntimacyRelationPanel()
		end
	elseif res == "not-build" then
		local msg = Client.GetTableData("LocalizeRes",200055);
		if msg then
			PopUpNoticeUI.ShowFastNoticeQueue(msg.TextValue)
		end

		for i = #BP_ARRAY_Intimacy_Data,1,-1 do
			if tonumber(BP_ARRAY_Intimacy_Data[i].gid) == tonumber(friUid) then
				table.remove(BP_ARRAY_Intimacy_Data,i)
				break
			end
		end

		FriendSystem.RefreshIntimacyDetailData()
		if BP_Friend_Is_Show then
			LobbyFriendUI:UpdateIntimacyRelationPanel()
		end
	else
		log("on_delete_intimacy_relation_rsp fail")
	end
end

--撤回亲密关系申请
function FriendSystem.cancelBuildIntimacyRelationReq(friUid)
	log("cancelBuildIntimacyRelationReq"..tostring(friUid))

	NetUtil.SendPkg("cancel_build_intimacy_relation_req",tonumber(friUid))
end

--撤回亲密关系申请回包
function FriendSystem.on_cancel_build_intimacy_relation_rsp(res,friUid)
	log("on_cancel_build_intimacy_relation_rsp res "..tostring(res).." friUid "..tostring(friUid))

	if res == "ok" then
		--撤回亲密关系申请成功
		local msg = Client.GetTableData("LocalizeRes",200058)
		if msg then
			PopUpNoticeUI.ShowFastNoticeQueue(msg.TextValue)
		end

		--状态转为待建立亲密关系状态
		for i = 1,#BP_ARRAY_Intimacy_Data,1 do
			if tonumber(BP_ARRAY_Intimacy_Data[i].gid) == tonumber(friUid) then
				BP_ARRAY_Intimacy_Data[i].state = 0
				BP_ARRAY_Intimacy_Data[i].param = FriendSystem.getInnerFriendIntimacyByGid(friUid)
				break
			end
		end

		if next(BP_ARRAY_Intimacy_Data) ~= nil then
			FriendSystem.spliceAndSortIntimacyData(BP_ARRAY_Intimacy_Data,SortIntimcayData)
		end

		-- 刷新亲密关系界面
		if BP_Friend_Is_Show then
			LobbyFriendUI:UpdateIntimacyRelationPanel()
		end
	elseif res == "state-error" then
		--撤回亲密关系申请失败
		local msg = Client.GetTableData("LocalizeRes",200059)
		if msg then
			PopUpNoticeUI.ShowFastNoticeQueue(msg.TextValue)
		end
	end
end

function FriendSystem.on_cancel_build_intimacy_relation_notify(friUid,canBuild)
	log("on_cancel_build_intimacy_relation_notify friUid "..tostring(friUid).." canBuild "..tostring(canBuild))

	if canBuild then
		for i = #BP_ARRAY_Intimacy_Data,1,-1 do
			if tonumber(BP_ARRAY_Intimacy_Data[i].gid) == tonumber(friUid) then
				BP_ARRAY_Intimacy_Data[i].state = 0
				BP_ARRAY_Intimacy_Data[i].param = FriendSystem.getInnerFriendIntimacyByGid(friUid)
				break
			end
		end
	else
		--删除数据
		for i = #BP_ARRAY_Intimacy_Data,1,-1 do
			if tonumber(BP_ARRAY_Intimacy_Data[i].gid) == tonumber(friUid) then
				table.remove(BP_ARRAY_Intimacy_Data,i)
				break
			end
		end
	end

	if next(BP_ARRAY_Intimacy_Data) ~= nil then
		FriendSystem.spliceAndSortIntimacyData(BP_ARRAY_Intimacy_Data,SortIntimcayData)
	end

	FriendSystem.UpdateIntimacyNewTips()
	FriendSystem.UpdateLobbyFriendNewTips()
	-- 刷新亲密关系界面
	if BP_Friend_Is_Show then
		LobbyFriendUI:UpdateIntimacyRelationPanel()
	end
end

--获取指定游戏内好友的亲密度
function FriendSystem.getInnerFriendIntimacyByGid(friUid)
	local intimacy = 0
	for i = 1,#BP_ARRAY_All_Friend_Profile,1 do
		if tonumber(BP_ARRAY_All_Friend_Profile[i].gid) == tonumber(friUid) then
			if BP_ARRAY_All_Friend_Profile[i].intimacy ~= nil then
				intimacy = BP_ARRAY_All_Friend_Profile[i].intimacy
				break
			end
		end
	end

	return intimacy
end

function FriendSystem.on_notify_intimacy_relation_chg(friUid,state,param)
	log("on_notify_intimacy_relation_chg friUid:"..tostring(friUid).." state:"..tostring(state))

	if state ~= 3 then
		--之前获取过数据，仅刷新亲密关系相关字段
		local has = false
		for i = #BP_ARRAY_Intimacy_Data,1,-1 do
			if tonumber(BP_ARRAY_Intimacy_Data[i].gid) == tonumber(friUid) then
				has = true
				BP_ARRAY_Intimacy_Data[i].state = state
				BP_ARRAY_Intimacy_Data[i].param = param
				break
			end
		end

		--如果是新数据则插入table中
		if not has then
			local data = {}
			data.gid = friUid
			data.state = state
			--state不同含义不同
			data.param = param

			local hasProfile = false
			for i = 1,#BP_ARRAY_All_Friend_Profile,1 do
				if tonumber(data.gid) == tonumber(BP_ARRAY_All_Friend_Profile[i].gid) then
					hasProfile = true
					data.nickName = BP_ARRAY_All_Friend_Profile[i].nickName
					data.level = BP_ARRAY_All_Friend_Profile[i].level
					data.picUrl = BP_ARRAY_All_Friend_Profile[i].picUrl
					data.vipLevel = BP_ARRAY_All_Friend_Profile[i].vipLevel
					data.sex = BP_ARRAY_All_Friend_Profile[i].sex
					data.signature = BP_ARRAY_All_Friend_Profile[i].signature
					data.intimacy = BP_ARRAY_All_Friend_Profile[i].intimacy
					data.segment_info_solo = BP_ARRAY_All_Friend_Profile[i].segment_info_solo
					data.segment_info_duo = BP_ARRAY_All_Friend_Profile[i].segment_info_duo
					data.segment_info_squad = BP_ARRAY_All_Friend_Profile[i].segment_info_squad
					data.history_max_segment_level = BP_ARRAY_All_Friend_Profile[i].history_max_segment_level
					data.cur_avatar_box_id = BP_ARRAY_All_Friend_Profile[i].cur_avatar_box_id
					data.upass_is_buy = BP_ARRAY_All_Friend_Profile[i].upass_is_buy
					data.upass_is_show = BP_ARRAY_All_Friend_Profile[i].upass_is_show
					data.aliasId = BP_ARRAY_All_Friend_Profile[i].aliasId;
					data.aliasTitle = BP_ARRAY_All_Friend_Profile[i].aliasTitle;
					data.aliasNation = BP_ARRAY_All_Friend_Profile[i].aliasNation;
					break
				end
			end

			if hasProfile then
				table.insert(BP_ARRAY_Intimacy_Data,data)
			end
		end

		--重新排序（取前30个数据,删除多余数据）
		if next(BP_ARRAY_Intimacy_Data) ~= nil then
			FriendSystem.spliceAndSortIntimacyData(BP_ARRAY_Intimacy_Data,SortIntimcayData)
		end
		--log_tree("notify relation chg BP_ARRAY_Intimacy_Data",BP_ARRAY_Intimacy_Data)
		if #BP_ARRAY_Intimacy_Data > BP_Friend_Intimacy_MaxCount then
			for i = #BP_ARRAY_Intimacy_Data,1,-1 do
				if i > BP_Friend_Intimacy_MaxCount then
					table.remove(BP_ARRAY_Intimacy_Data,i)
				end
			end
		end
		if state == 4 then
			--（建立亲密关系后刷新数据）
			for i = #BP_ARRAY_Inner_Friend_Profile,1,-1 do
				if tonumber(BP_ARRAY_Inner_Friend_Profile[i].gid) == tonumber(friUid) then
					if BP_ARRAY_Inner_Friend_Profile[i].relation ~= nil then
						BP_ARRAY_Inner_Friend_Profile[i].relation = param
					else
						BP_ARRAY_Inner_Friend_Profile[i].relation = param
					end
					break
				end
			end
		end
	elseif state == 3 then
		--删除亲密关系
		local intimacy = FriendSystem.getInnerFriendIntimacyByGid(friUid)
		for i = #BP_ARRAY_Intimacy_Data,1,-1 do
			if tonumber(BP_ARRAY_Intimacy_Data[i].gid) == tonumber(friUid) then
				if intimacy >= BP_Friend_Intimacy_Threshold then
					BP_ARRAY_Intimacy_Data[i].state = 0
					BP_ARRAY_Intimacy_Data[i].param = intimacy
				else
					table.remove(BP_ARRAY_Intimacy_Data,i)
				end
				break
			end
		end

		--好友数据中重置relation字段
		for i = #BP_ARRAY_Inner_Friend_Profile,1,-1 do
			if tonumber(BP_ARRAY_Inner_Friend_Profile[i].gid) == tonumber(friUid) then
				if BP_ARRAY_Inner_Friend_Profile[i].relation ~= nil then
					BP_ARRAY_Inner_Friend_Profile[i].relation = 0
					break
				end
			end
		end
	end

	if next(BP_ARRAY_Intimacy_Data) ~= nil then
		FriendSystem.spliceAndSortIntimacyData(BP_ARRAY_Intimacy_Data,SortIntimcayData)
	end

	FriendSystem.UpdateIntimacyNewTips()
	FriendSystem.UpdateLobbyFriendNewTips()
	FriendSystem.RefreshIntimacyDetailData()
	if BP_Friend_Is_Show then
		LobbyFriendUI:UpdateIntimacyRelationPanel()
	end
end

function FriendSystem.GetRelationNameByType(relation)
	local relationName = ""

	if relation == 1 then
		relationName = DataMgr.GetMsgByID(200030)
	elseif relation == 2 then
		relationName = DataMgr.GetMsgByID(200031)
	elseif relation == 3 then
		relationName = DataMgr.GetMsgByID(200032)
	elseif relation == 4 then
		relationName = DataMgr.GetMsgByID(200033)
	end

	return relationName
end

--社交名片相关表格数据
FriendSystem.searchLanguageInfo = {}

function FriendSystem.InitLabelSearchData()
	if FriendSystem.HasInitLabelSearchData == true then
		return
	end

	BP_Array_Search_Data = {}

	--1社交倾向
	local searchDataTendency = {}
	searchDataTendency.labelType = 0
	searchDataTendency.labelId = 0
	searchDataTendency.labelStr = DataMgr.GetMsgByID(200041)
	table.insert(BP_Array_Search_Data,searchDataTendency)

	local socialCardTendency = Client.GetTable("SocialCardTendency")
    for k,v in pairs(socialCardTendency) do
		local searchDataTendencyTmp = {}

		searchDataTendencyTmp.labelType = 0
		searchDataTendencyTmp.labelId = tonumber(v.ID)
		searchDataTendencyTmp.labelStr = v.Tendency

		table.insert(BP_Array_Search_Data,searchDataTendencyTmp)
    end

	--2常玩日期
	local searchDataPlayDate = {}
	searchDataPlayDate.labelType = 1
	searchDataPlayDate.labelId = 0
	searchDataPlayDate.labelStr = DataMgr.GetMsgByID(200041)
	table.insert(BP_Array_Search_Data,searchDataPlayDate)

	local socialCardDate = Client.GetTable("SocialCardDate")
    for k,v in pairs(socialCardDate) do
		local searchDataPlayDateTmp = {}

		searchDataPlayDateTmp.labelType = 1
		searchDataPlayDateTmp.labelId = tonumber(v.ID)
		searchDataPlayDateTmp.labelStr = v.Date

		table.insert(BP_Array_Search_Data,searchDataPlayDateTmp)
    end

	--3常玩时间
	local searchDataPlayTime = {}
	searchDataPlayTime.labelType = 2
	searchDataPlayTime.labelId = 0
	searchDataPlayTime.labelStr = DataMgr.GetMsgByID(200041)
	table.insert(BP_Array_Search_Data,searchDataPlayTime)

	local socialCardTime = Client.GetTable("SocialCardTime")
    for k,v in pairs(socialCardTime) do
		local searchDataPlayTimeTmp = {}

		searchDataPlayTimeTmp.labelType = 2
		searchDataPlayTimeTmp.labelId = tonumber(v.ID)
		searchDataPlayTimeTmp.labelStr = v.Time

		table.insert(BP_Array_Search_Data,searchDataPlayTimeTmp)
    end

	--4段位
	local searchDataSegment = {}
	searchDataSegment.labelType = 3
	searchDataSegment.labelId = 0
	searchDataSegment.labelStr = DataMgr.GetMsgByID(200041)
	table.insert(BP_Array_Search_Data,searchDataSegment)

	local rankIntegralLevel = Client.GetTable("RankIntegralLevel")
    for k,v in pairs(rankIntegralLevel) do
		local has = false
		for i = 1,#BP_Array_Search_Data,1 do
			if tonumber(BP_Array_Search_Data[i].labelType) == 3 and tonumber(BP_Array_Search_Data[i].labelId) == tonumber(v.IntegralType) then
				has = true
				break
			end
		end

		if not has then
			local searchDataSegmentTmp = {}
			searchDataSegmentTmp.labelType = 3
			searchDataSegmentTmp.labelId = tonumber(v.IntegralType)
			searchDataSegmentTmp.labelStr = v.IntegralTypeName
			table.insert(BP_Array_Search_Data,searchDataSegmentTmp)
		end
    end

	--性别
	local searchDataGender = {}
	searchDataGender.labelType = 4
	searchDataGender.labelId = 0
	searchDataGender.labelStr = DataMgr.GetMsgByID(200041)
	table.insert(BP_Array_Search_Data,searchDataGender)

	local searchDataGenderMan = {}
	searchDataGenderMan.labelType = 4
	searchDataGenderMan.labelId = 1
	searchDataGenderMan.labelStr = DataMgr.GetMsgByID(200042)
	table.insert(BP_Array_Search_Data,searchDataGenderMan)

	local searchDataGenderWoMan = {}
	searchDataGenderWoMan.labelType = 4
	searchDataGenderWoMan.labelId = 2
	searchDataGenderWoMan.labelStr = DataMgr.GetMsgByID(200043)
	table.insert(BP_Array_Search_Data,searchDataGenderWoMan)

	--语言
	FriendSystem.searchLanguageInfo = {}

	local searchDataLanguage = {}
	searchDataLanguage.labelType = 5
	searchDataLanguage.labelId = -1
	searchDataLanguage.labelStr = DataMgr.GetMsgByID(200041)
	table.insert(BP_Array_Search_Data,searchDataLanguage)
	table.insert(FriendSystem.searchLanguageInfo,searchDataLanguage)

	local region = Client.GetPublishRegion();
	local searchDataLanguageEnTmp = {}
	searchDataLanguageEnTmp.labelType = 5
	searchDataLanguageEnTmp.labelId = 0
	searchDataLanguageEnTmp.labelStr = "English"
	local searchDataLanguageJaTmp = {}
	searchDataLanguageJaTmp.labelType = 5
	searchDataLanguageJaTmp.labelId = 1
	searchDataLanguageJaTmp.labelStr = "日本語"
	local searchDataLanguageKoTmp = {}
	searchDataLanguageKoTmp.labelType = 5
	searchDataLanguageKoTmp.labelId = 2
	searchDataLanguageKoTmp.labelStr = "한국어"
	if region == "JAPAN" then
		table.insert(BP_Array_Search_Data,searchDataLanguageEnTmp)
		table.insert(BP_Array_Search_Data,searchDataLanguageJaTmp)

		table.insert(FriendSystem.searchLanguageInfo,searchDataLanguageEnTmp)
		table.insert(FriendSystem.searchLanguageInfo,searchDataLanguageJaTmp)
	elseif region == "KOREA" then
		table.insert(BP_Array_Search_Data,searchDataLanguageEnTmp)
		table.insert(BP_Array_Search_Data,searchDataLanguageKoTmp)

		table.insert(FriendSystem.searchLanguageInfo,searchDataLanguageEnTmp)
		table.insert(FriendSystem.searchLanguageInfo,searchDataLanguageKoTmp)
	else
		local tranSupportCfg = FuncUtil.GetLanguageTable()

	    for k,v in pairs(tranSupportCfg) do
	    	if(v.languageCode ~= "ja" and v.languageCode ~= "ko") then
	    		if v.isSupported == true then
					local searchDataLanguageTmp = {}
					searchDataLanguageTmp.labelType = 5
					searchDataLanguageTmp.labelId = tonumber(v.languageID);
					searchDataLanguageTmp.labelStr = v.displayName
					table.insert(BP_Array_Search_Data,searchDataLanguageTmp)

					table.insert(FriendSystem.searchLanguageInfo,searchDataLanguageTmp)
				end
			end
	    end
	end

	table.sort(BP_Array_Search_Data,SortSearchData)
	table.sort(FriendSystem.searchLanguageInfo,SortSearchData)
	FriendSystem.HasInitLabelSearchData = true

	--log_tree("BP_Array_Search_Data",BP_Array_Search_Data)
end

function SortSearchData(a,b)
	if a.labelType == nil or b.labelType == nil then
		return false
	end

	if a.labelType == b.labelType then
		if a.labelId == nil or b.labelId == nil then
			return false
		end

		return a.labelId < b.labelId
	else
		return a.labelType < b.labelType
	end
end

--更新亲密关系界面小红点
function FriendSystem.UpdateIntimacyNewTips()
	local hasNew = false
	if next(BP_ARRAY_Intimacy_Data) ~= nil then
		for i = #BP_ARRAY_Intimacy_Data,1,-1 do
			if BP_ARRAY_Intimacy_Data[i].state == 2 then
				hasNew = true
				break
			end
		end
	end
	BP_Friend_Intimacy_Apply_Has_New = hasNew
	if BP_Friend_Is_Show then
		LobbyFriendUI:UpdateIntimacyApplyNewTips()
	end
end
-----------------------------------------------------------亲密关系相关协议--------------------------------

----------------------------------------------------------------标签搜索--------------------------------------
-- function FriendSystem.searchSocialRoleReq(tendency,play_date,play_time,segment,gender,same_city)
-- 	log("searchSocialRoleReq "..tostring(tendency).." "..tostring(play_date).." "..tostring(play_time).." "..tostring(segment).." "..tostring(gender).." "..tostring(same_city))

-- 	--NetUtil.SendPkg("search_social_role_req",tendency,play_date,play_time,segment,gender,same_city)
-- end

-- --标签搜索返回结果
-- function FriendSystem.on_search_social_role_res(res,uidlist)
-- 	log("on_search_social_role_res"..tostring(res))
-- 	--log_tree("on_search_social_role_res uidlist",uidlist)

-- 	if res == "ok" then
-- 		log("searchSocialRoleReq success")
-- 		if next(uidlist) ~= nil then
-- 			BP_ARRAY_Search_Friend_Profile = {}

-- 			for i = 1,#uidlist,1 do
-- 				local data = {gid=tostring(uidlist[i])}
-- 				table.insert(BP_ARRAY_Search_Friend_Profile,data)
-- 			end

-- 			local needRefreshProfile = false
-- 			local timeDiff = os.time() - FriendSystem.ClickSearchBtnTimeStamp
-- 			if timeDiff > FriendSystem.ClickSearchBtnTimeThreshold then
-- 				needRefreshProfile = true
-- 				FriendSystem.ClickSearchBtnTimeStamp = os.time()
-- 			else
-- 				needRefreshProfile = false
-- 			end
-- 			ProfileMgr.GetProfileList(uidlist,FriendSystem.on_batch_get_search_profile_rsp,needRefreshProfile)
-- 		else
-- 			BP_ARRAY_Search_Friend_Profile = {}
-- 			LobbyFriendUI:UpdateSearchList()

-- 			LobbyFriendUI:ShowSearchFailResult()
-- 		end
-- 	elseif res == "db-error" then
-- 		log("searchSocialRoleReq db-error")
-- 		LobbyFriendUI:ShowSearchFailResult()
-- 	else
-- 		log("searchSocialRoleReq fail")
-- 		LobbyFriendUI:ShowSearchFailResult()
-- 	end
-- end
----------------------------------------------------------------标签搜索--------------------------------------

-----------------------------------------------------------数据排序----------------------------------------
LOGIC_FRIEND_SORT_TYPE = {
	NORMAL = 1,
	LAST_ONLINE_TIME = 2,
}

function SortLastOnlineTimeFunc(a,b)
	if a.online == nil or b.online == nil then
		log("friendlog a or b online is nil")
		return false
	end

	if a.online == b.online then
		if a.teamState == nil or b.teamState == nil then
			log("friendlog a or b teamState is nil")
				return false
			end

		if a.teamState == b.teamState then
			if a.intimacy == nil or b.intimacy == nil then
				log("friendlog a or b intimacy is nil")
				return false
			end

			if a.intimacy == b.intimacy then
				if a.level == nil or b.level == nil then
					log("friendlog a or b level is nil")
					return false
				end

				if a.level == b.level then
					return tonumber(a.lastOnlineTime) > tonumber(b.lastOnlineTime)

				else
					return a.level > b.level
				end
			else
				return a.intimacy > b.intimacy
			end
		else
			return a.teamState < b.teamState
		end
	else
		return a.online < b.online
	end
end

--(在线>组队中>游戏中>离线(离线按最近登录时间排序)
function SortFunc(a,b)
	if a.online == nil or b.online == nil then
		log("friendlog a or b online is nil")
		return false
	end

	if a.online == b.online then
		if a.teamState == nil or b.teamState == nil then
			log("friendlog a or b teamState is nil")
				return false
			end

		if a.teamState == b.teamState then
			if a.intimacy == nil or b.intimacy == nil then
				log("friendlog a or b intimacy is nil")
				return false
			end

			if a.intimacy == b.intimacy then
				if a.level == nil or b.level == nil then
					log("friendlog a or b level is nil")
					return false
				end

				if a.level == b.level then
					return tonumber(a.lastOnlineTime) > tonumber(b.lastOnlineTime)

				else
					return a.level > b.level
				end
			else
				return a.intimacy > b.intimacy
			end
		else
			return a.teamState < b.teamState
		end
	else
		return a.online > b.online
	end
end

function SortRecentFunc(a,b)
	if a.endtime == nil or b.endtime == nil then
		return false
	end

	if a.endtime == b.endtime then
		if a.online == nil or b.online == nil then
			return false
		end

		if a.online == b.online then
			if a.teamState == nil or b.teamState == nil then
				return false
			end

			if a.teamState == b.teamState then
				if a.intimacy == nil or b.intimacy == nil then
					return false
				end

				if a.intimacy == b.intimacy then
					if a.level == nil or b.level == nil then
						return false
					end

					if a.level == b.level then
						return tonumber(a.lastOnlineTime) > tonumber(b.lastOnlineTime)
					else
						return a.level > b.level
					end
				else
					return a.intimacy > b.intimacy
				end
			else
				return a.teamState < b.teamState
			end
		else
			return a.online > b.online
		end
	else
		return a.endtime > b.endtime
	end
end

--好友搜索排序
function FriendSystem.SortSearchList(list)
	local languagePar = 1;
	local segmentPar = 1;
	local recentLikePar = 1;
	local myLanguage = Client.GetCurrentLanguage();

	local myMaxSegment = DataMgr.GetMaxRankLevel()
	local myMaxSegmentCfg = Client.GetTableData("RankIntegralLevel",myMaxSegment)
	local myMaxSegmentType = 0;

	if (myMaxSegmentCfg ~= nil) then
		myMaxSegmentType = myMaxSegmentCfg.IntegralType;
	end
	local segmentTypeDiff = 0;
	local maxSegmenet = 0;
	local maxSegmenetType = 0;
	local maxSegmenetCfg = nil;
	
	for i = 1,#list,1 do
		if (list[i].language == myLanguage) then
			languagePar = 3
		else
			languagePar = 1;
		end
		maxSegmenet = math.max(list[i].segment_info_solo, list[i].segment_info_duo, list[i].segment_info_squad)
		maxSegmenetCfg = Client.GetTableData("RankIntegralLevel",maxSegmenet)
		if (maxSegmenetCfg ~= nil) then
			maxSegmenetType = maxSegmenetCfg.IntegralType;
		end

		segmentDiff = math.abs(myMaxSegmentType - maxSegmenetType);
		if (segmentDiff > 1) then
			segmentPar = 0.5;
		elseif (segmentDiff > 0) then
			segmentPar = 0.7
		else
			segmentPar = 1;
		end

		-- 点赞时间戳
		if list[i].recentLikeTs and list[i].recentLikeTs > 0 then
			recentLikePar = list[i].recentLikeTs;
		end

		list[i].sortValue = languagePar * segmentPar * recentLikePar;
	end
	
	--排序后删除多余数据
	table.sort(list,SortSearchFunc)
	--log_tree("BP_ARRAY_Intimacy_Data",BP_ARRAY_Intimacy_Data)
end

--搜索好友
function SortSearchFunc(a,b)
	if a.sortValue ~= b.sortValue then
		return a.sortValue > b.sortValue
	end
	return a.gid < b.gid
end


--好友数据排序(供聊天和组队使用)
function FriendSystem.SortFriendList()
	local list = {}

	--过滤脏数据
	for i = #BP_ARRAY_All_Friend_Profile,1,-1 do
		if BP_ARRAY_All_Friend_Profile[i].nickName == "" or BP_ARRAY_All_Friend_Profile[i].nickName == nil then
			table.remove(BP_ARRAY_All_Friend_Profile,i)
		end
	end

	local curTime = FuncUtil.GetServerTimeInSec()
	for i = 1,#BP_ARRAY_All_Friend_Profile,1 do
		local profile = BP_ARRAY_All_Friend_Profile[i]
		--默认不显示邀请
		profile.showInviteIcon = 0
		local lastInviteTime = profile.lastInviteTime
		if profile.online == 0 and FriendSystem.IsPlatFriend(profile.gid) then
			if lastInviteTime == nil or FuncUtil.IsSameDay(curTime, lastInviteTime) == false then
				--不在同一天，显示可邀请
				profile.showInviteIcon = 1
			else
				--在同一天，显示已邀请
				profile.showInviteIcon = 2
			end
		end

		if profile.timeSinceGameBeginStamp ~= nil then
			profile.timeSinceGameBegin = os.time() - profile.timeSinceGameBeginStamp
			profile.timeSinceGameBeginStr = FriendSystem.FormatTime2(profile.timeSinceGameBegin)
		end

		table.insert(list,BP_ARRAY_All_Friend_Profile[i])
	end

	-- 过滤黑名单数据
	for i = #list,1,-1 do
		for j = #BP_ARRAY_Friend_ID_Blacklist,1,-1 do
			if tonumber(list[i].gid) == tonumber(BP_ARRAY_Friend_ID_Blacklist[j]) then
				table.remove(list,i)
				break
			end
		end
	end

	--获取最新概要数据
	for k = #list,1,-1 do
		if ProfileMgr.dicFriendProfile[tonumber(list[k].gid)] then
			if ProfileMgr.dicFriendProfile[tonumber(list[k].gid)].cur_avatar_box_id ~= nil then
				list[k].cur_avatar_box_id = ProfileMgr.dicFriendProfile[tonumber(list[k].gid)].cur_avatar_box_id
				list[k].nickName = ProfileMgr.dicFriendProfile[tonumber(list[k].gid)].nickName
				list[k].level = ProfileMgr.dicFriendProfile[tonumber(list[k].gid)].level
			end
            list[k].roleNation = ProfileMgr.dicFriendProfile[tonumber(list[k].gid)].nation;
            list[k].language = ProfileMgr.dicFriendProfile[tonumber(list[k].gid)].language;
		end
	end

	table.sort(list,SortFunc)


    --过滤非好友的
    for k,v in pairs(list) do
        local isFriend = FriendSystem.IsPlatFriend(v.gid);
        if isFriend == false then
            --非好友不显示平台名字和备注名字
            v.platName = "";
            v.remarks_name = "";
        end
	end
	--log_tree("zino BP_ARRAY_Teamuup_Friend_Profile",list)
	return list
end

--仅供黑名单使用
function FriendSystem.SortFriendList2()
	local list = {}

	--过滤脏数据
	for i = #BP_ARRAY_All_Friend_Profile,1,-1 do
		if BP_ARRAY_All_Friend_Profile[i].nickName == "" or BP_ARRAY_All_Friend_Profile[i].nickName == nil then
			table.remove(BP_ARRAY_All_Friend_Profile,i)
		end
	end

	for i = 1,#BP_ARRAY_All_Friend_Profile,1 do
		if BP_ARRAY_All_Friend_Profile[i].timeSinceGameBeginStr ~= nil then
			BP_ARRAY_All_Friend_Profile[i].timeSinceGameBegin = os.time() - BP_ARRAY_All_Friend_Profile[i].timeSinceGameBeginStamp
			BP_ARRAY_All_Friend_Profile[i].timeSinceGameBeginStr = FriendSystem.FormatTime2(BP_ARRAY_All_Friend_Profile[i].timeSinceGameBegin)
		end

		table.insert(list,BP_ARRAY_All_Friend_Profile[i])
	end

	table.sort(list,SortFunc)
	return list
end

--供最近队友列表使用
function FriendSystem.SortRecentList()
	local list = {}
	local ids = {}

	--过滤脏数据
	for i = #BP_ARRAY_Recent_Teammate_Profile,1,-1 do
		if BP_ARRAY_Recent_Teammate_Profile[i].nickName == "" or BP_ARRAY_Recent_Teammate_Profile[i].nickName == nil then
			table.remove(BP_ARRAY_Recent_Teammate_Profile,i)
		end
	end

	for i = 1,#BP_ARRAY_Recent_Teammate_Profile,1 do
		if ids[BP_ARRAY_Recent_Teammate_Profile[i].gid] == nil then
			table.insert(list,BP_ARRAY_Recent_Teammate_Profile[i])
			ids[BP_ARRAY_Recent_Teammate_Profile[i].gid] = BP_ARRAY_Recent_Teammate_Profile[i].gid
		end
	end

	table.sort(list,SortRecentFunc)

    --过滤非好友的
    for k,v in pairs(list) do
        local isFriend = FriendSystem.IsPlatFriend(v.gid);
        if isFriend == false then
            --非好友不显示平台名字和备注名字
            v.platName = "";
            v.remarks_name = "";
        end
    end


	return list
end

--游戏内好友排序
function FriendSystem.SortInnerFriendList(sortType)
	log("sortinnerfriendlist--------")
	-- log_tree("friendlog BP_ARRAY_All_Friend_Profile",BP_ARRAY_All_Friend_Profile)
	-- log_tree("friendlog g___dddddddd",g___dddddddd)

	if sortType~= nil then log("sortType "..tostring(sortType)) end
	
	BP_ARRAY_Inner_Friend_Profile = {}

	for i = #BP_ARRAY_All_Friend_Profile,1,-1 do
		if BP_ARRAY_All_Friend_Profile[i].nickName == "" or BP_ARRAY_All_Friend_Profile[i].nickName == nil then
			table.remove(BP_ARRAY_All_Friend_Profile,i)
		end
	end

	local curTime = FuncUtil.GetServerTimeInSec()

	for	i = #BP_ARRAY_All_Friend_Profile,1,-1 do
		local has = false;
		for j = #ID_INNER_FRIENDLIST,1,-1 do
			if tonumber(ID_INNER_FRIENDLIST[j]) == tonumber(BP_ARRAY_All_Friend_Profile[i].gid) then
				has = true
				break
			end
		end
		if has then
			local data = {}
			-- 值拷贝
			data.gid = BP_ARRAY_All_Friend_Profile[i].gid
			data.nickName = BP_ARRAY_All_Friend_Profile[i].nickName
			data.level = BP_ARRAY_All_Friend_Profile[i].level
			data.militaryRank = BP_ARRAY_All_Friend_Profile[i].militaryRank
			data.picUrl = BP_ARRAY_All_Friend_Profile[i].picUrl
			data.vipLevel = BP_ARRAY_All_Friend_Profile[i].vipLevel
			data.ladder = BP_ARRAY_All_Friend_Profile[i].ladder
			data.platName = BP_ARRAY_All_Friend_Profile[i].platName
			data.sex = BP_ARRAY_All_Friend_Profile[i].sex
			data.lastOnlineTime = BP_ARRAY_All_Friend_Profile[i].lastOnlineTime
			data.lastLoginTime = BP_ARRAY_All_Friend_Profile[i].lastLoginTime
			data.exp = BP_ARRAY_All_Friend_Profile[i].exp
			data.segment_info_solo = BP_ARRAY_All_Friend_Profile[i].segment_info_solo
			data.segment_info_duo = BP_ARRAY_All_Friend_Profile[i].segment_info_duo
			data.segment_info_squad = BP_ARRAY_All_Friend_Profile[i].segment_info_squad
			data.history_max_segment_level = BP_ARRAY_All_Friend_Profile[i].history_max_segment_level
			data.friendType = 0
			data.isPlatFriend = FriendSystem.IsPlatFriend(data.gid)
			data.teamState = BP_ARRAY_All_Friend_Profile[i].teamState
			data.currentTeamAmount = BP_ARRAY_All_Friend_Profile[i].currentTeamAmount
			data.maxTeamAmount = BP_ARRAY_All_Friend_Profile[i].maxTeamAmount
			
			if BP_ARRAY_All_Friend_Profile[i].timeSinceGameBeginStamp == nil then
				data.timeSinceGameBegin = BP_ARRAY_All_Friend_Profile[i].timeSinceGameBegin
			else
				data.timeSinceGameBegin = os.time() - BP_ARRAY_All_Friend_Profile[i].timeSinceGameBeginStamp
				data.timeSinceGameBeginStr = FriendSystem.FormatTime2(data.timeSinceGameBegin)
			end

			data.game_mode = BP_ARRAY_All_Friend_Profile[i].game_mode
			data.gameModeStr = BP_ARRAY_All_Friend_Profile[i].gameModeStr
			data.online = BP_ARRAY_All_Friend_Profile[i].online
			data.lastOnlineTimeStr = BP_ARRAY_All_Friend_Profile[i].lastOnlineTimeStr
			data.startup_type = BP_ARRAY_All_Friend_Profile[i].startup_type
			data.qq_vip = BP_ARRAY_All_Friend_Profile[i].qq_vip

			data.intimacy = BP_ARRAY_All_Friend_Profile[i].intimacy
			data.lastPresentCoinTime = BP_ARRAY_All_Friend_Profile[i].lastPresentCoinTime
			data.cur_avatar_box_id = BP_ARRAY_All_Friend_Profile[i].cur_avatar_box_id
			--data.history_max_segment_level = BP_ARRAY_All_Friend_Profile[i].history_max_segment_level
			data.remarks_name = BP_ARRAY_All_Friend_Profile[i].remarks_name or ""
			data.relation = FriendSystem.getRelationByGid(data.gid)
			data.isInnerFriendNotPlatFriend = BP_ARRAY_All_Friend_Profile[i].isInnerFriendNotPlatFriend
			data.upass_is_buy = BP_ARRAY_All_Friend_Profile[i].upass_is_buy
			data.upass_is_show = BP_ARRAY_All_Friend_Profile[i].upass_is_show
			data.roleNation = BP_ARRAY_All_Friend_Profile[i].roleNation;
			data.language = BP_ARRAY_All_Friend_Profile[i].language;
			data.aliasId = BP_ARRAY_All_Friend_Profile[i].aliasId;
			data.aliasTitle = BP_ARRAY_All_Friend_Profile[i].aliasTitle;
			data.aliasNation = BP_ARRAY_All_Friend_Profile[i].aliasNation;
			data.create_time = BP_ARRAY_All_Friend_Profile[i].create_time;
			data.enableWatch = BP_ARRAY_All_Friend_Profile[i].enableWatch

			local lastPresentCoinTime = data.lastPresentCoinTime
			if lastPresentCoinTime ~= nil and FuncUtil.IsSameDay(curTime, lastPresentCoinTime) == false then
				data.bPresentedCoin = 0
			else
				data.bPresentedCoin = 1
			end
			table.insert(BP_ARRAY_Inner_Friend_Profile,data)
		end
	end

	-- 过滤黑名单数据
	for i = #BP_ARRAY_Inner_Friend_Profile,1,-1 do
		for j = #BP_ARRAY_Friend_ID_Blacklist,1,-1 do
			if tonumber(BP_ARRAY_Inner_Friend_Profile[i].gid) == tonumber(BP_ARRAY_Friend_ID_Blacklist[j]) then
				table.remove(BP_ARRAY_Inner_Friend_Profile,i)
				break
			end
		end
	end

	if BP_IsInBatchDelete == true then
		table.sort(BP_ARRAY_Inner_Friend_Profile,SortLastOnlineTimeFunc)
	else
		table.sort(BP_ARRAY_Inner_Friend_Profile,SortFunc)
	end

	--local xiaoyueProfile = {bXiaoYue=1,bNewMessage=BP_YXXY_RedPoint, gid="9999"}
	--table.insert(BP_ARRAY_Inner_Friend_Profile,1,xiaoyueProfile)

	--log_tree("ID_INNER_FRIENDLIST:",ID_INNER_FRIENDLIST)
	-- log_tree("friendlog BP_ARRAY_Inner_Friend_Profile:",BP_ARRAY_Inner_Friend_Profile)
	LobbyFriendUI:UpdateInnerList();
end

--平台好友排序
function FriendSystem.SortPlatFriendList()
	log("sortplatfriendlist")
	BP_ARRAY_Plat_Friend_Profile = {}

	for i = #BP_ARRAY_All_Friend_Profile,1,-1 do
		if BP_ARRAY_All_Friend_Profile[i].nickName == "" or BP_ARRAY_All_Friend_Profile[i].nickName == nil then
			table.remove(BP_ARRAY_All_Friend_Profile,i)
		end
	end

	local curTime = FuncUtil.GetServerTimeInSec()

	for	i = #BP_ARRAY_All_Friend_Profile,1,-1 do
		local has = false;
		for j = #ID_PLAT_FRIENDLIST,1,-1 do
			if tonumber(ID_PLAT_FRIENDLIST[j]) == tonumber(BP_ARRAY_All_Friend_Profile[i].gid) then
				has = true
				break
			end
		end
		if has then
			local data = {}
			-- 值拷贝
			data.gid = BP_ARRAY_All_Friend_Profile[i].gid
			data.nickName = BP_ARRAY_All_Friend_Profile[i].nickName
			data.level = BP_ARRAY_All_Friend_Profile[i].level
			data.militaryRank = BP_ARRAY_All_Friend_Profile[i].militaryRank
			data.picUrl = BP_ARRAY_All_Friend_Profile[i].picUrl
			data.vipLevel = BP_ARRAY_All_Friend_Profile[i].vipLevel
			data.ladder = BP_ARRAY_All_Friend_Profile[i].ladder
			data.platName = BP_ARRAY_All_Friend_Profile[i].platName
			data.sex = BP_ARRAY_All_Friend_Profile[i].sex
			data.lastOnlineTime = BP_ARRAY_All_Friend_Profile[i].lastOnlineTime
			data.lastLoginTime = BP_ARRAY_All_Friend_Profile[i].lastLoginTime
			data.exp = BP_ARRAY_All_Friend_Profile[i].exp
			data.segment_info_solo = BP_ARRAY_All_Friend_Profile[i].segment_info_solo
			data.segment_info_duo = BP_ARRAY_All_Friend_Profile[i].segment_info_duo
			data.segment_info_squad = BP_ARRAY_All_Friend_Profile[i].segment_info_squad
			data.history_max_segment_level = BP_ARRAY_All_Friend_Profile[i].history_max_segment_level
			data.friendType = 1
			data.isPlatFriend = FriendSystem.IsPlatFriend(data.gid)
			data.teamState = BP_ARRAY_All_Friend_Profile[i].teamState
			data.currentTeamAmount = BP_ARRAY_All_Friend_Profile[i].currentTeamAmount
			data.maxTeamAmount = BP_ARRAY_All_Friend_Profile[i].maxTeamAmount

			if BP_ARRAY_All_Friend_Profile[i].timeSinceGameBeginStamp == nil then
				data.timeSinceGameBegin = BP_ARRAY_All_Friend_Profile[i].timeSinceGameBegin
			else
				data.timeSinceGameBegin = os.time() - BP_ARRAY_All_Friend_Profile[i].timeSinceGameBeginStamp
				data.timeSinceGameBeginStr = FriendSystem.FormatTime2(data.timeSinceGameBegin)
			end

			data.timeSinceGameBeginStr = BP_ARRAY_All_Friend_Profile[i].timeSinceGameBeginStr
			data.game_mode = BP_ARRAY_All_Friend_Profile[i].game_mode
			data.gameModeStr = BP_ARRAY_All_Friend_Profile[i].gameModeStr
			data.online = BP_ARRAY_All_Friend_Profile[i].online
			data.lastOnlineTimeStr = BP_ARRAY_All_Friend_Profile[i].lastOnlineTimeStr
			data.startup_type = BP_ARRAY_All_Friend_Profile[i].startup_type
			data.qq_vip = BP_ARRAY_All_Friend_Profile[i].qq_vip

			data.intimacy = 0
			data.lastPresentCoinTime = BP_ARRAY_All_Friend_Profile[i].lastPresentCoinTime
			data.cur_avatar_box_id = BP_ARRAY_All_Friend_Profile[i].cur_avatar_box_id
			data.remarks_name = BP_ARRAY_All_Friend_Profile[i].remarks_name
			data.isInnerFriendNotPlatFriend = BP_ARRAY_All_Friend_Profile[i].isInnerFriendNotPlatFriend
			data.upass_is_buy = BP_ARRAY_All_Friend_Profile[i].upass_is_buy
			data.upass_is_show = BP_ARRAY_All_Friend_Profile[i].upass_is_show
			data.roleNation = BP_ARRAY_All_Friend_Profile[i].roleNation;
			data.language = BP_ARRAY_All_Friend_Profile[i].language;
			data.aliasId = BP_ARRAY_All_Friend_Profile[i].aliasId;
			data.aliasTitle = BP_ARRAY_All_Friend_Profile[i].aliasTitle;
			data.aliasNation = BP_ARRAY_All_Friend_Profile[i].aliasNation;
			data.create_time = BP_ARRAY_All_Friend_Profile[i].create_time;
			data.enableWatch = BP_ARRAY_All_Friend_Profile[i].enableWatch

			local lastPresentCoinTime = data.lastPresentCoinTime
			if lastPresentCoinTime ~= nil and FuncUtil.IsSameDay(curTime, lastPresentCoinTime) == false then
				data.bPresentedCoin = 0
			else
				data.bPresentedCoin = 1
			end

			table.insert(BP_ARRAY_Plat_Friend_Profile,data)
		end
	end
	--过滤黑名单数据
	for i = #BP_ARRAY_Plat_Friend_Profile,1,-1 do
		for j = #BP_ARRAY_Friend_ID_Blacklist,1,-1 do
			if tonumber(BP_ARRAY_Plat_Friend_Profile[i].gid) == tonumber(BP_ARRAY_Friend_ID_Blacklist[j]) then
				table.remove(BP_ARRAY_Plat_Friend_Profile,i)
				break
			end
		end
	end
	log("friendlog 平台好友排序开始")
	table.sort(BP_ARRAY_Plat_Friend_Profile,SortFunc)
	log("friendlog 平台好友排序结束")
	-- log_tree("BP_ARRAY_Plat_Friend_Profile",BP_ARRAY_Plat_Friend_Profile)
	--local xiaoyueProfile = {bXiaoYue=1,bNewMessage=BP_YXXY_RedPoint, gid="999"}
	--table.insert(BP_ARRAY_Plat_Friend_Profile,1,xiaoyueProfile)

	--log_tree("ID_PLAT_FRIENDLIST:",ID_PLAT_FRIENDLIST)
	--log_tree("BP_ARRAY_Plat_Friend_Profile:",BP_ARRAY_Plat_Friend_Profile)
	LobbyFriendUI:UpdatePlatList();
end
-----------------------------------------------------------数据排序----------------------------------------

-----------------------------------------------------------格式化日期------------------------------------------
function FriendSystem.FormatTime(t,s)
	--  废弃重复方法
	return FuncUtil.FormatTime(t,s)

	-- if t == nil then
	-- 	return ""
	-- end

	-- local str = ""
	-- if s == "online" then
	-- 	--str = "最近上线 ";
	-- 	str = Client.GetTableData("LocalizeRes",301101).TextValue;
	-- end

	-- local diff = os.time() - t
 --    local days = math.floor(diff/86400)
 --    local hours = math.fmod(math.floor(diff/3600), 24)
 --    local mins = math.fmod(math.floor(diff/60), 60)
 --    local seconds = math.fmod(diff, 60)

 --    if days >= 1 then
	-- 	if hours >= 1 then
	-- 	    --return str..days.."天前";
	-- 		return str..string.format(Client.GetTableData("LocalizeRes", "301255").TextValue, tostring(days));
	-- 	elseif hours < 1 and hours >= 0 then
	-- 		--return str..days.."天前";
	-- 		return str..string.format(Client.GetTableData("LocalizeRes", "301255").TextValue, tostring(days));
	-- 	end
 --    end
 --    if hours >= 1 then
	-- 	if mins >= 1 then
	-- 	    --return str..hours.."小时前";
	-- 		return str..string.format(Client.GetTableData("LocalizeRes", "301257").TextValue, tostring(hours));
	-- 	elseif mins < 1 and mins >= 0 then
	-- 		--return str..hours.."小时前";
	-- 		return str..string.format(Client.GetTableData("LocalizeRes", "301257").TextValue, tostring(hours));
	-- 	end
 --    end
 --    if mins >= 1 then
 --        --return str..mins.."分钟前";
	-- 	return str..string.format(Client.GetTableData("LocalizeRes", "301264").TextValue, tostring(mins));
	-- else
	-- 	--return str.."1分钟前";
	-- 	return str..Client.GetTableData("LocalizeRes", "301105").TextValue;
 --    end
end

function FriendSystem.FormatTime2(t)
	if t == nil then
		return "0"
	end

    local hours = math.fmod(math.floor(t/3600), 24)
    local mins = math.fmod(math.floor(t/60), 60)
    local seconds = math.fmod(t, 60)

    if hours >= 1 then
		if mins >= 1 then
		    --return "(已开局"..hours.."小时)";
		    return string.format(Client.GetTableData("LocalizeRes",301128).TextValue, tostring(hours));
		elseif mins < 1 and mins >= 0 then
			--return "(已开局"..hours.."小时)";
			return string.format(Client.GetTableData("LocalizeRes",301128).TextValue, tostring(hours));
		end
    end
    if mins >= 1 then
        --return "(已开局"..mins.."分钟)";
        return string.format(Client.GetTableData("LocalizeRes",301127).TextValue, tostring(mins));
	else
		--return "(已开局1分钟)";
		return Client.GetTableData("LocalizeRes",301126).TextValue;
    end
end
-----------------------------------------------------------格式化日期------------------------------------------
BP_YXXY_RedPoint = 0

function FriendSystem.UpdateLobbyFriendNewTips()
	-- 更新大厅小红点
	log("updatelobbyfriendnewtips")
	local hasNew = false
	--检查好友申请数量
	if next(BP_ARRAY_Apply_Friend_Profile) ~= nil then
		LobbyUI:LobbySystemMessageUpdate(BP_ENUM_LOBBY_MENU_FRIEND,#BP_ARRAY_Apply_Friend_Profile)
		local count = #BP_ARRAY_Apply_Friend_Profile
		if count > 0 then
			hasNew = true
		end
	else
		LobbyUI:LobbySystemMessageUpdate(BP_ENUM_LOBBY_MENU_FRIEND,0)
	end
	--检查建立亲密关系申请数量
	if next(BP_ARRAY_Intimacy_Data) ~= nil then
		for i = #BP_ARRAY_Intimacy_Data,1,-1 do
			if BP_ARRAY_Intimacy_Data[i].state == 2 then
				hasNew = true
				break
			end
		end
	end
	--检查小悦小红点
    LuaClassObj.HandleUIMessage(bp_global, "GetYXXYRedPoint")
	if BP_YXXY_RedPoint == 1 then
		hasNew = true
	end

	--if 	MasterSystem.IsRedPoint() then
		--hasNew = true
	--end

	LobbyUI.HasNew = hasNew;
	FriendSystem.UpdateLobbyNewTips();
	--LobbyUI:LobbyRedPointUpdate(BP_ENUM_LOBBY_MENU_FRIEND, hasNew)
end

function FriendSystem.UpdateLobbyNewTips()
	BP_Global_SelfUID = DataMgr.roleData.uid;
	LuaClassObj.HandleUIMessageNoFetch(bp_global, "SetNearByRedPoint");
	local HasNew = LobbyUI.HasNew
	LobbyUI:LobbyRedPointUpdate(BP_ENUM_LOBBY_MENU_FRIEND, HasNew);
end

--更新游戏小悦小红点
function FriendSystem.UpdateXiaoYueRedPoint(xyRedPoint,tabIndex)
	log("UpdateXiaoYueRedPoint xyRedPoint"..tostring(xyRedPoint).." "..tostring(tabIndex))
	FriendSystem.UpdateLobbyFriendNewTips()

	if BP_Friend_Is_Show then
		if next(BP_ARRAY_Inner_Friend_Profile) ~= nil then
			if BP_ARRAY_Inner_Friend_Profile[1].bXiaoYue ~= nil then
				if BP_ARRAY_Inner_Friend_Profile[1].bXiaoYue == 1 then
					BP_ARRAY_Inner_Friend_Profile[1].bNewMessage = xyRedPoint
				end
			end
		end
		if next(BP_ARRAY_Plat_Friend_Profile) ~= nil then
			if BP_ARRAY_Plat_Friend_Profile[1].bXiaoYue ~= nil then
				if BP_ARRAY_Plat_Friend_Profile[1].bXiaoYue == 1 then
					BP_ARRAY_Plat_Friend_Profile[1].bNewMessage = xyRedPoint
				end
			end
		end

		if tonumber(tabIndex) == 0 then
			LobbyFriendUI:UpdatePlatList()
		elseif tonumber(tabIndex) == 1 then
			LobbyFriendUI:UpdateInnerList()
		end
	end
end

-- 返回好友gid列表
function FriendSystem.GetFriendUidList()
	return ID_PLAT_FRIENDLIST,ID_INNER_FRIENDLIST
end

-- 第一次拉取好友列表
function FriendSystem.PullFriendList()
	log("FriendSystem.PullFriendList")

	--更新组队信息
	TeamUPFriendUI.UpdateFriend()
	LobbyChatSystem.UpdateFriend()
end

--添加好友
function FriendSystem.ProcessAddFriend()
	log("FriendSystem.ProcessAddFriend add")
	--更新组队信息
	TeamUPFriendUI.UpdateFriend()
	LobbyChatSystem.UpdateFriend()
end

--删除好友
function FriendSystem.ProcessDeleteFriend(uid)
	log("FriendSystem.ProcessDeleteFriend del")
	--更新组队信息
	TeamUPFriendUI.UpdateFriend()
	LobbyChatSystem.UpdateFriend()
	LobbyChatSystem.DeleteFriend(uid)
end

--状态变更（组队状态）[好友那边做定时拉取派发状态更新]
function FriendSystem.ProcessStateChange()
	log("FriendSystem.ProcessStateChange status")
	--更新组队状态
	TeamUPFriendUI.UpdateAllFriendStatus()
	LobbyChatSystem.UpdateFriend()
	FriendSystem.RefreshFriendList()
end

--状态变更（在线状态）
function FriendSystem.ProcessOnlineStateChange()
	log("[HHF]FriendSystem.ProcessOnlineStateChange")

	--更新组队好友在线状态
	TeamUPFriendUI.UpdateAllFriendStatus()
	LobbyChatSystem.UpdateFriend()
	FriendSystem.RefreshFriendList()
	TeamUPFriendUI.UpdateOnlineNum();

	EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_ONLINE_STATE_CHANGE)
end

-- 获取单个好友数据
function FriendSystem.GetFriendDataByGID(gid)
	for i = #BP_ARRAY_All_Friend_Profile,1,-1 do
		if tonumber(BP_ARRAY_All_Friend_Profile[i].gid) == tonumber(gid) then
			return BP_ARRAY_All_Friend_Profile[i]
		end
	end
	return nil
end

-- 获取单个平台好友数据
function FriendSystem.GetPlatFriendDataByGID(gid)
	for i = #BP_ARRAY_Plat_Friend_Profile,1,-1 do
		if tonumber(BP_ARRAY_Plat_Friend_Profile[i].gid) == tonumber(gid) then
			return BP_ARRAY_Plat_Friend_Profile[i]
		end
	end
	return nil
end

-- 获取单个内部好友数据
function FriendSystem.GetInnerFriendDataByGID(gid)
	for i = #BP_ARRAY_Inner_Friend_Profile,1,-1 do
		if tonumber(BP_ARRAY_Inner_Friend_Profile[i].gid) == tonumber(gid) then
			return BP_ARRAY_Inner_Friend_Profile[i]
		end
	end
	return nil

end

-- 根据昵称获取好友信息
function FriendSystem.GetFriendDataByNickname(nickname)
	for i = #BP_ARRAY_All_Friend_Profile,1,-1 do
		if BP_ARRAY_All_Friend_Profile[i].nickName == nickname then
			return BP_ARRAY_All_Friend_Profile[i];
		end
	end
	return nil;
end

-- 是否是好友
function FriendSystem.IsMyFriend(gid)
	--被拉黑属不属于于好友？
	if ID_PLAT_FRIENDLIST ~= nil then
		for i = #ID_PLAT_FRIENDLIST,1,-1 do
			if tonumber(ID_PLAT_FRIENDLIST[i]) == tonumber(gid) then
				return true
			end
		end
	end

	if ID_INNER_FRIENDLIST ~= nil then
		for i = #ID_INNER_FRIENDLIST,1,-1 do
			if tonumber(ID_INNER_FRIENDLIST[i]) == tonumber(gid) then
				return true
			end
		end
	end

	return false
end

-- 是否被拉黑
function FriendSystem.IsPulBlack(gid)
	local isPullBlack = false
	for i = #BP_ARRAY_Friend_ID_Blacklist,1,-1 do
		if tonumber(BP_ARRAY_Friend_ID_Blacklist[i]) == tonumber(gid) then
			isPullBlack = true
			break
		end
	end
	return isPullBlack
end

function FriendSystem.IsPlatFriend(gid)
	local isPlat = false
    for k,v in pairs(ID_PLAT_FRIENDLIST) do
        if tonumber(v) == tonumber(gid) then
            isPlat = true
            break
        end
    end
	return isPlat
end

function FriendSystem.IsInnerFriend(gid)
	local isInner = false
	for k,v in pairs(ID_INNER_FRIENDLIST) do
		if tonumber(v) == tonumber(gid) then
			isInner = true
			break
		end
	end
	return isInner
end

-- 是否是游戏好友但不是平台好友
function FriendSystem.IsInnerFriendNotPlatFriend(gid)
	local isInner = false

    for k,v in pairs(ID_INNER_FRIENDLIST) do
        if tonumber(v) == tonumber(gid) then
            isInner = true
            break
        end
    end

    if not isInner then
        return false
    end

    local isPlat = false
    for k,v in pairs(ID_PLAT_FRIENDLIST) do
        if tonumber(v) == tonumber(gid) then
            isPlat = true
            break
        end
    end

    if not isPlat then
        return true
    else
        return false
    end
end

--获取所有好友的id列表
function FriendSystem.GetAllFriendIDList()
	local list = {}
	list = FriendSystem.UnionFriendIDList(ID_INNER_FRIENDLIST,ID_PLAT_FRIENDLIST)
	return list
end

function FriendSystem.on_notify_friend_redpoint_chg(redpoint_pos)
    log("FriendSystem.on_notify_friend_redpoint_chg:"..redpoint_pos);

	LobbyUI.HasNew = true;

    LobbyUI:LobbyRedPointUpdate(BP_ENUM_LOBBY_MENU_FRIEND, true)
    EventSetXYAPIShowRedPoint();
end

--获取到当前所在的城市名字
function FriendSystem.OnQueryMyInfoNotify()
	log("FriendSystem.OnQueryMyInfoNotify");
	local gpsCity = Client.GetGPSCity(NetInterface);
	log("gpsCity = " .. tostring(gpsCity));
end

--查询自己所在的城市 channel：1是微信，2是qq
function FriendSystem.SendQueryMyInfo(channel)
	log("FriendSystem.SendQueryMyInfo");
	Client.QueryMyInfo(NetInterface, channel);
end

function FriendSystem.CheckAndGetNearbyPersonInfo()
--[[
	if (BP_Global_CloseLocation == true) then
		log("CheckAndGetNearbyPersonInfo BP_Global_CloseLocation == true")
		return;
	end
	if (FriendSystem.ShowNearByPersonInfoArray == nil or #FriendSystem.ShowNearByPersonInfoArray == 0) then
		--没有数据的情况下，每隔5分钟拉一次数据
		local timeDiff = os.time() - FriendSystem.NearByEmptyTimeStamp;
		if (FriendSystem.NearByEmptyTimeStamp == 0 or timeDiff >= FriendSystem.NearByEmptyTimeLength) then
			FriendSystem.NearByEmptyTimeStamp = os.time();
			FriendSystem.GetNearbyPersonInfo();
		end
	else
		--有数据的情况下，每隔12小时拉一次数据
		local timeDiff = os.time() - FriendSystem.GetNearbyPersonInfoTimeStamp;
		if (FriendSystem.GetNearbyPersonInfoTimeStamp == 0 or timeDiff >= FriendSystem.GetNearbyPersonInfoTimeLength) then
			FriendSystem.GetNearbyPersonInfo();
		end
	end
]]

end


function FriendSystem.GetNearbyPersonInfo()
	log("FriendSystem.GetNearbyPersonInfo");
	FriendSystem.FetchNearByStatusTimeStamp = os.time();
	--Client.GetNearbyPersonInfo(NetInterface);
	FriendSystem.NearByClear = false;
end

--附近的人数据
function FriendSystem.OnNearByPersonInfoNotify()
	log("FriendSystem.OnNearByPersonInfoNotify() FriendSystem.NearByClear = " .. tostring(FriendSystem.NearByClear));
	if (FriendSystem.NearByClear == false) then
		FriendSystem.FetchNearByPersonInfo();
	end
end

function FriendSystem.FetchNearByPersonInfo()
	log("Client.FetchNearByPersonInfo()");
	FriendSystem.ShowNearByPersonInfoArray = Client.FetchNearByPersonInfo(NetInterface);
	log("#FriendSystem.ShowNearByPersonInfoArray = " .. #FriendSystem.ShowNearByPersonInfoArray);
	--log_tree("FriendSystem.ShowNearByPersonInfoArray", FriendSystem.ShowNearByPersonInfoArray);

	table.sort(FriendSystem.ShowNearByPersonInfoArray, FriendSystem.SortNearByRawFunc);

	if (#FriendSystem.ShowNearByPersonInfoArray > 0) then
		FriendSystem.GetNearbyPersonInfoTimeStamp = os.time();
		local openIdList = {};
		for i = 1, #FriendSystem.ShowNearByPersonInfoArray, 1 do
			if (#openIdList < 99) then
				table.insert(openIdList, FriendSystem.ShowNearByPersonInfoArray[i].OpenId);
			else
				log("FetchNearByPersonInfo() #openIdList > 99");
				break;
			end
		end
		FriendSystem.batch_get_uid_from_openid_req(openIdList)
	else
		BP_ARRAY_Near_By_Profile = {};
		LobbyFriendUI.UpdateNearByPanel();
		TeamUPFriendUI.UpdateNearByStatus();
	end
end

function FriendSystem.SortNearByRawFunc(a,b)
	if a.Distance == nil or b.Distance == nil then
		return false
	elseif a.Distance < b.Distance then
		return true;
	elseif a.Distance > b.Distance then
		return false;
	else
		return false;
	end
end

function FriendSystem.query_gid_by_openid_req()
	log("FriendSystem.QueryGidByOpenId");
end

function FriendSystem.on_batch_get_near_by_profile_rsp(profileList)
	--log_tree("nearbyteammate profile:",profileList)
	log("#profileList = " .. #profileList);
	for k,v in pairs(profileList) do
		for kk,vv in pairs(BP_ARRAY_Near_By_Profile) do
			if tonumber(vv.gid) == tonumber(v.uid) then
				vv.nickName = v.nickName
				vv.level = v.level
				vv.picUrl = v.picUrl
				vv.vipLevel = v.vipLevel

				vv.sex = v.sex
				vv.lastOnlineTime = v.lastOnlineTime
				vv.lastLoginTime = v.lastLoginTime
				vv.exp = v.exp

				-- vv.segment_info_solo = v.segment_info[1]
				-- vv.segment_info_duo = v.segment_info[2]
				-- vv.segment_info_squad = v.segment_info[3]

	            vv.segment_info_solo, vv.segment_info_duo, vv.segment_info_squad = FuncUtil.GetMaxSegement(v.segment_info);

				vv.history_max_segment_level = v.history_max_segment_level;
				vv.startup_type = GetSafeNumber(v.startup_type)
				vv.qq_vip = GetSafeNumber(v.qq_vip)
				vv.cur_avatar_box_id = v.cur_avatar_box_id

				local isFriend = FriendSystem.IsInnerFriend(vv.gid);

                vv.remarks_name = isFriend and v.remarks_name or "";
                vv.platName = isFriend and v.platName or "";
                vv.upass_is_buy, vv.upass_is_show = FriendSystem.ParseUpassInfo(v.upass);  -- 绝地通行证
                vv.aliasId = v.alias.id;
				vv.aliasTitle = v.alias.title;
				vv.aliasNation = v.alias.nation;	
			end
		end
	end
	--log_tree("on_batch_get_near_by_profile_rsp BP_ARRAY_Near_By_Profile", BP_ARRAY_Near_By_Profile);
	log("on_batch_get_near_by_profile_rsp #BP_ARRAY_Near_By_Profile = " .. #BP_ARRAY_Near_By_Profile);
	FriendSystem.NearByProfileReady = true;
	FriendSystem.CheckNearByQueryReady();
end

function FriendSystem.CheckNearByQueryReady()
	if (FriendSystem.NearByProfileReady == true and FriendSystem.NearByStatusReady == true) then
		FriendSystem.NearByProfileReady = false;
		FriendSystem.NearByStatusReady = false;

		local loginTimeDict = {};	--key是openId value是登陆时间
		local loginTimeUIdDict = {};	--key是openId value是gid
		local invalidUIdList = {};
		if (#BP_ARRAY_Near_By_Profile > 0) then
			for i = 1, #BP_ARRAY_Near_By_Profile, 1 do
				local info = BP_ARRAY_Near_By_Profile[i];
				local openId = FriendSystem.UIdOpenIdDict[info.gid];
				local myLoginTime = info.lastLoginTime;
				local existLoginTime = loginTimeDict[openId];

				if (myLoginTime == nil) then
					table.insert(invalidUIdList, info.gid);
				elseif (existLoginTime ~= nil) then
					if (myLoginTime <= existLoginTime) then
						table.insert(invalidUIdList, info.gid);
					else
						table.insert(invalidUIdList, loginTimeUIdDict[openId]);
					end
				end

				loginTimeDict[openId] = myLoginTime;
				loginTimeUIdDict[openId] = info.gid;
			end
		end
		log("#invalidUIdList = " .. #invalidUIdList);
		--log_tree("invalidUIdList", invalidUIdList);

		if (#invalidUIdList > 0) then
			for j = 1, #invalidUIdList, 1 do
				local uId = invalidUIdList[j];
				local index = -1;
				if (#BP_ARRAY_Near_By_Profile > 0) then
					for i = 1, #BP_ARRAY_Near_By_Profile, 1 do
						if (BP_ARRAY_Near_By_Profile[i].gid == uId) then
							index = i;
							break;
						end
					end
				end

				if (index > 0) then
					table.remove(BP_ARRAY_Near_By_Profile, index);
				else
					log("cannot find uid to remove , uid = " .. uId);
				end
			end
		end

		log("#BP_ARRAY_Near_By_Profile = " .. #BP_ARRAY_Near_By_Profile);
		--log_tree("BP_ARRAY_Near_By_Profile", BP_ARRAY_Near_By_Profile);


		TeamUPFriendUI.UpdateNearByPersonInfo();
		LobbyFriendUI.UpdateNearByPanel();
		TeamUPFriendUI.UpdateNearByStatus()
	end
end

function FriendSystem.batch_get_uid_from_openid_req(list)
	log("FriendSystem.batch_get_uid_from_openid_req #list = " .. #list);
	--log_tree("list", list);
	NetUtil.SendPkg("batch_get_uid_from_openid_req", list);
end

--[[
 list =
{
[uid1] =
{
	openid = openid, 				// openid
	client_type = client_type 		// 设备类型: 101: android; 102: ios
},
[uid2] =
{
	openid = openid, 				// openid
	lient_type = client_type 		// 设备类型: 101: android; 102: ios
	}
}
]]
function FriendSystem.batch_get_uid_from_openid_rsp(res, list)
	log("FriendSystem.batch_get_uid_from_openid_rsp res = " .. tostring(res));
	if (res == "ok") then
		log("#list = " .. #list);
		--log_tree("list", list);
		FriendSystem.on_query_gid_by_openid_rsp(list);
	elseif (res == "invalid-param") then
		DataMgr.ShowNoticeByID(200067);
		--DataMgr.ShowNoticeByString("数组长度不正确");
	elseif (res == "db-error") then
		DataMgr.ShowNoticeByID(200068);
		--DataMgr.ShowNoticeByString("系统错误");
	elseif (res == "not-exist") then
		--DataMgr.ShowNoticeByString("一个都查不到");
	else
		DataMgr.ShowNoticeByID(200069);
		--DataMgr.ShowNoticeByString("查询uid失败");
	end

	if (res ~= "ok") then
		BP_ARRAY_Near_By_Profile = {};
		LobbyFriendUI.UpdateNearByPanel();
		TeamUPFriendUI.UpdateNearByStatus();
	end
end
--[[
─ 410000680
  ├─ openid: "11A99D012FB7195AE64DB7187AC28BEE"
  └─ client_type: 101
]]

function FriendSystem.on_query_gid_by_openid_rsp(list)
	log("FriendSystem.on_query_gid_by_openid_rsp");
	local array = {};
	log("#FriendSystem.ShowNearByPersonInfoArray = " .. #FriendSystem.ShowNearByPersonInfoArray);
	log("#list = " .. #list);
	FriendSystem.UIdOpenIdDict = {};
	if (#FriendSystem.ShowNearByPersonInfoArray > 0) then

		for i = 1, #FriendSystem.ShowNearByPersonInfoArray, 1 do
			local info = FriendSystem.ShowNearByPersonInfoArray[i];
			for k,v in pairs(list) do
				local rspInfo = v;
				if (tostring(rspInfo.openid) == tostring(info.OpenId)) then
					local newInfo = {};
					newInfo.OpenId = info.OpenId;
					newInfo.IsFriend = info.IsFriend;
					newInfo.Distance = info.Distance;
					newInfo.Gender = info.Gender;
					newInfo.Gid = tostring(k);
					table.insert(array, newInfo);
					FriendSystem.UIdOpenIdDict[newInfo.Gid] = newInfo.OpenId;
				end
			end
		end
	end

	FriendSystem.ShowNearByPersonInfoArray = array;
	--log_tree("array", array);
	log("#array = " .. #array);

	FriendSystem.UpdateNearByStatus();
end

function FriendSystem.UpdateNearByStatus()
	log("FriendSystem.UpdateNearByStatus");
	local idlist = {};
	local myId = DataMgr.roleData.uid;

	BP_ARRAY_Near_By_Profile = {};
	for i = 1,#FriendSystem.ShowNearByPersonInfoArray,1 do
		local personInfo = FriendSystem.ShowNearByPersonInfoArray[i];
		local profile = {};
		profile.gid = tostring(personInfo.Gid);
		profile.distance = personInfo.Distance;
		profile.isFriend = FriendSystem.IsInnerFriend(profile.gid) or profile.gid == myId;
		table.insert(BP_ARRAY_Near_By_Profile, profile);
		table.insert(idlist, profile.gid);
	end
	log("before on_batch_get_near_by_profile_rsp idlist = " .. #idlist);
	--log_tree("before on_batch_get_near_by_profile_rsp idlist", idlist);
	ProfileMgr.GetProfileList(idlist, FriendSystem.on_batch_get_near_by_profile_rsp);
	NetUtil.SendPkg("batch_get_group_and_online_req", "nearby", idlist);
end

--------------------------------好友军团信息--------------------------------------
-- 重新请求刷新好友军团信息
function FriendSystem.RefreshFriendsCorpsID()
	local list = FriendSystem.UnionFriendIDList(ID_INNER_FRIENDLIST,ID_PLAT_FRIENDLIST)
	EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_FRIEND_REFRESH);
	if #list ~= 0 then
		ProfileMgr.GetFriendProfileList(list,FriendSystem.OnGetProfileForCorps)
	end
end

function FriendSystem.OnGetProfileForCorps(profileList)
	-- log_tree("FriendSystem.OnGetProfileForCorps profileList:",profileList)
	for k,v in pairs(profileList) do
		FriendSystem.SetFriendCorpsID(v.uid, v.corps_id);
	end

	EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_FRIEND_REFRESH);
end

function FriendSystem.SetFriendCorpsID(id, corps_id)
	for i,v in ipairs(BP_ARRAY_All_Friend_Profile) do
		if tonumber(v.gid) == tonumber(id) then
			v.corps_id = corps_id
			break;
		end
	end
end

function FriendSystem.GetFriendsInCorps(corps_id)
	local list = {}
	for i,v in ipairs(BP_ARRAY_All_Friend_Profile) do
		if v.corps_id == tonumber(corps_id) then
			table.insert(list, v);
		end
	end

	return list;
end

-- 解析好友绝地通行证信息
function FriendSystem.ParseUpassInfo(upassInfo)
	if upassInfo ~= nil then
		local is_buy = 0;
		local is_uishow = false;
		if upassInfo.switch == nil then
			is_uishow = false
		else
			is_uishow = upassInfo.switch.ui or is_uishow
		end
		is_buy = upassInfo.is_buy or is_buy;
		return is_buy, is_uishow and 1 or 0;
	end

end

function FriendSystem.GetNicknameByUid(uid)
	local strUID = tostring(uid);
	log("[HHF]FriendSystem.GetNicknameByUid, uid = " .. strUID);
	local nickname = "";
	
	for k, v in pairs(BP_ARRAY_RoomMemberList) do
		if tostring(v.openid) == strUID then
			nickname = v.name;
			break;
		end
	end

	if nickname == "" then
		for k, v in pairs(BP_ARRAY_TeamUpMenuInfoList) do
			if tostring(v.player_id) == strUID then
				nickname = v.player_name;
				break;
			end
		end
	end

	if nickname == "" then
		nickname = strUID;
	end

	return nickname;
end

-----------------------------------------------------------最近点赞----------------------------------------
-- 请求数据
function FriendSystem.get_upvote_recent_req()
	NetUtil.SendPkg("get_upvote_recent_req")
end

recentLikeRowDatas = {};	-- 服务器发来的初始数据
-- 返回点赞数据
function FriendSystem.get_upvote_recent_rsp(data)
	log("FriendSystem.get_upvote_recent_rsp")
	-- log_tree("get_upvote_recent_req1", data);

	if data == nil then
		BP_ARRAY_Recent_Like_Profile = {}
		LobbyFriendUI:UpdateRecentLikePanel();
		return
	end

	recentLikeRowDatas = {};
	local uidList = {};
	for i,v in pairs(data.map) do
		-- log_tree("V1", v);
		local item = {};
		item.uid = i;
		item.ts = v.ts;
		item.op = v.op;
		table.insert(recentLikeRowDatas, item);

		table.insert(uidList, tostring(i));
	end
	-- log_tree("BP_ARRAY_Recent_Like_Data", recentLikeRowDatas);
	ProfileMgr.GetProfileList(uidList, FriendSystem.on_batch_get_recent_like_profile_rsp, true);
end

--获取要添加的玩家的概要数据
function FriendSystem.on_batch_get_recent_like_profile_rsp(profileList)
	-- log_tree("recent_like profile:", profileList);
    BP_ARRAY_Recent_Like_Profile = {}

	if next(profileList) == nil then
		log("recent like empty");
		LobbyFriendUI:ShowSearchFailResult();
		return;
	end

	for k,v in pairs(profileList) do
		local data = {}
		local find = false;
		for i2,v2 in ipairs(recentLikeRowDatas) do
			if v.uid == v2.uid then
				find = true;
				data.recentLikeUID = v2.uid;
				data.recentLikeTs = v2.ts;
				data.recentLikeOp = v2.op;
				break;
			end
		end
		if find then
			data.gid = v.uid
			data.nickName = v.nickName
			data.level = v.level
			data.picUrl = v.picUrl
			data.vipLevel = v.vipLevel
			data.platName = v.platName
			data.sex = v.sex
			data.lastOnlineTime = v.lastOnlineTime
			data.lastLoginTime = v.lastLoginTime
			data.exp = v.exp
			data.language = v.language

			data.isFriend = FriendSystem.IsMyFriend(v.uid)

            ----------------------------------------intl modify--------------------------------------
            data.AllSegment_Info = v.segment_info;
            for kseg, v in pairs(data.AllSegment_Info) do
                data.segment_info_solo = data.AllSegment_Info[kseg][1];
                data.segment_info_duo = data.AllSegment_Info[kseg][2];
                data.segment_info_squad = data.AllSegment_Info[kseg][3];
                break;
            end
            data.segment_info_solo,  data.segment_info_duo,  data.segment_info_squad = FuncUtil.GetMaxSegement( data.AllSegment_Info );
            ----------------------------------------intl modify--------------------------------------
            data.history_max_segment_level = v.history_max_segment_level;
			data.startup_type = GetSafeNumber(v.startup_type)
			data.qq_vip = GetSafeNumber(v.qq_vip)
			data.cur_avatar_box_id = v.cur_avatar_box_id
			data.upass_is_buy, data.upass_is_show = FriendSystem.ParseUpassInfo(v.upass)  -- 绝地通行证
			data.aliasId = v.alias.id;
			data.aliasTitle = v.alias.title;
			data.aliasNation = v.alias.nation;
            data.isInnerFriendNotPlatFriend = FriendSystem.IsInnerFriendNotPlatFriend(v.uid)
			data.roleNation = v.nation;
			data.language = v.language;

			if v.social_card == nil then
				data.tendency = 0
				data.playDate = 0
				data.playTime = 0
				data.cityId = 0
				data.expertArea_1 = 0
				data.expertArea_2 = 0
			else
				data.tendency = v.social_card.tendency or 0
				data.playDate = v.social_card.play_date or 0
				data.playTime = v.social_card.play_time or 0
				data.cityId = v.social_card.city_id or 0

				if v.social_card.expert_area ~= nil then
					if v.social_card.expert_area[1] ~= nil then
						data.expertArea_1 = v.social_card.expert_area[1] or 0
					else
						data.expertArea_1 = 0
					end

					if v.social_card.expert_area[2] ~= nil then
						data.expertArea_2 = v.social_card.expert_area[2] or 0
					else
						data.expertArea_2 = 0
					end
				else
					data.expertArea_1 = 0
					data.expertArea_2 = 0
				end
			end
			data.endtime = data.recentLikeTs
			data.endtimeStr = FriendSystem.FormatTime(data.endtime,"")

			table.insert(BP_ARRAY_Recent_Like_Profile, data)
		end
    end
    
    FriendSystem.SortSearchList(BP_ARRAY_Recent_Like_Profile)
	-- log_tree("BP_ARRAY_Recent_Like_Profile:", BP_ARRAY_Recent_Like_Profile)
    --刷新查找列表
	LobbyFriendUI:UpdateRecentLikePanel();
end

-----------------------------------------------------------最近点赞----------------------------------------

--[[网络回调]]--
s2c["get_all_friendlist_rsp"] = FriendSystem.on_get_all_friendlist_rsp
s2c["notify_topn_plat_friend_chg_info"] = FriendSystem.on_notify_topn_plat_friend_chg_info

s2c["add_inner_friend_rsp"] = FriendSystem.on_add_inner_friend_rsp
s2c["add_inner_friend_notify"] = FriendSystem.on_add_inner_friend_notify

s2c["add_inner_friend_op_rsp"] = FriendSystem.on_add_inner_friend_op_rsp
s2c["add_inner_friend_op_notify"] = FriendSystem.on_add_inner_friend_op_notify
s2c["auto_add_inner_friend_notify"] = FriendSystem.on_auto_add_inner_friend_notify

s2c["del_inner_friend_rsp"] = FriendSystem.on_del_inner_friend_rsp
s2c["del_inner_friend_notify"] = FriendSystem.on_del_inner_friend_notify

s2c["find_uid_by_name_rsp"] = FriendSystem.on_find_uid_by_name_rsp
s2c["social_search_role_rsp"] = FriendSystem.on_social_search_role_rsp

s2c["get_addfriend_reqlist_rsp"] = FriendSystem.on_get_addfriend_reqlist_rsp
s2c["del_addfriend_req_notify"] = FriendSystem.on_del_addfriend_req_notify

s2c["add_black_list_rsp"] = FriendSystem.on_add_black_list_rsp
s2c["del_black_list_rsp"] = FriendSystem.on_del_black_list_rsp
s2c["get_black_list_rsp"] = FriendSystem.on_get_black_list_rsp

-- s2c["notify_online_status_chg"] = FriendSystem.on_notify_online_status_chg
-- s2c["notify_group_status_chg"] = FriendSystem.on_notify_group_status_chg

s2c["invite_offline_friend_rsp"] = FriendSystem.invite_offline_friend_rsp
s2c["get_openid_by_nickname_rsp"] = FriendSystem.get_openid_by_nickname_rsp

s2c["check_and_update_invite_plat_rsp"] = FriendSystem.check_and_update_invite_plat_rsp

s2c["get_recent_teammate_rsp"] = FriendSystem.on_get_recent_teammate_rsp

s2c["present_friend_gold_rsp"] = FriendSystem.on_present_friend_gold_rsp;
s2c["send_friend_item_res"] = FriendSystem.on_send_friend_item_rsp;

s2c["notify_friend_intimacy_chg"] = FriendSystem.notify_friend_intimacy_chg

s2c["friend_redpoint_res"] = FriendSystem.on_notify_friend_redpoint_chg;

s2c["notify_team_result_finished"] = FriendSystem.on_notify_team_result_finished

s2c["get_intimacy_relation_rsp"] = function(...)
	FriendSystem.on_get_intimacy_relation_rsp(...)
	PersonSpaceSystem.get_intimacy_relation_rsp(...)
end

s2c["build_intimacy_relation_rsp"] = FriendSystem.on_build_intimacy_relation_rsp
s2c["reply_intimacy_relation_rsp"] = FriendSystem.on_reply_intimacy_relation_rsp
s2c["delete_intimacy_relation_rsp"] = FriendSystem.on_delete_intimacy_relation_rsp
s2c["notify_intimacy_relation_chg"] = FriendSystem.on_notify_intimacy_relation_chg
s2c["cancel_build_intimacy_relation_rsp"] = FriendSystem.on_cancel_build_intimacy_relation_rsp
s2c["cancel_build_intimacy_relation_notify"] = FriendSystem.on_cancel_build_intimacy_relation_notify
-- s2c["search_social_role_res"] = FriendSystem.on_search_social_role_res

s2c["batch_get_uid_from_openid_rsp"] = FriendSystem.batch_get_uid_from_openid_rsp
s2c["del_inner_friend_batch_rsp"] = FriendSystem.del_inner_friend_batch_rsp
s2c["get_upvote_recent_rsp"] = FriendSystem.get_upvote_recent_rsp