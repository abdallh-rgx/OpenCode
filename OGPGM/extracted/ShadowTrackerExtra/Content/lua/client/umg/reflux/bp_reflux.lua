UIReflux = UIReflux or {

	bWaitingCallback = false;		-- 等待回调
	HaveGotData = false;			-- 是否收到足够数据
	NumOfFriendsWillBeGeted = 200;	-- 总共拉取多少个
	FriendsPage = 1;				-- 当前拉取批次
	NumOfFriendsPerPage = 200;		-- 每批多少个
	NumOfElementsPerFriend = 4;		-- 拉取回调数据项数
	PLATFriendsRegList = {};		-- 注册过游戏的FB好友列表
	FriendsType = 0;				-- 注册过游戏的FB好友类型
	UIDMapOpenID = {};				-- UID查OpenID
	
	HaveClickOpen = false;
	friendList = {};
}

local PlatFormStr = {"WeChat", "Facebook"}

BP_STRUCT_Reflux_Friend_Info =
{
	openID = "",
	nickName = "",
	headUrl = "",
    inviteStatus = 0,
    level = 0,
    callReward = 0,
	uid = "",
	weekNum = 0,
}

--服务器列表
BP_ARRAY_Reflux_Friend_Infos =
{
	BP_STRUCT_Reflux_Friend_Info = _G.BP_STRUCT_Reflux_Friend_Info,
}

-- 邀请的好友
BP_Reflux_Call_Friend_OpenID = ""
BP_Reflux_Call_Friend_UID = "" 

-- 奖励信息
BP_STRUCT_Reflux_Award_Info =
{
	itemIdx = 0,
	needInviteCount = 0,
	currentInviteCount = 0,
	awardID = 0,
	status = 0,
    expireTime = 0,
    iconPath = "",
    iconOpenPath = "",
    name = "",
    Type = 0,
    rank =0,
}

BP_ARRAY_Reflux_Award_Infos =
{
	BP_STRUCT_Reflux_Award_Info = _G.BP_STRUCT_Reflux_Award_Info
}

BP_Reflux_Friend_Page_Idx = 1

BP_Reflux_Friend_Count = 0

BP_Reflux_Total_Back_Count = 0
-- 领取的奖励
BP_Reflux_Award_Index_Get = - 1
-- 活动时间
BP_Reflux_Open_Time = ""


--显示帮助
BP_Reflux_Help_Content = ""
local PromotionRule_Title = ""

--注册Widget
function bp_reflux_RegisterUI()
	
	LuaClassObj.SubUIWidgetList(bp_reflux,
	{
		{Path = "/Game/UMG/UI_Logic/Reflux/Reflux_BP.Reflux_BP_C", Container = "Default", ZOrder = BP_ENUM_UI_REFLUX_TRAINING_ZORDER + 1},
		-- {Path = "/Game/UMG/UI_Logic/Promotion/PromotionRegisterFriend_BP.PromotionRegisterFriend_BP_C", Container = "Default", ZOrder = BP_ENUM_UI_REFLUX_ZORDER + 1}
	},
	{"Lobby"},
	false,
	bp_reflux_OnModeSwitched ~= nil,
	true
	)
	
	-- EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CHANGE, UIReflux.RefreshPromotionInfo)
	EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_REFLUX, UIReflux.GetRefluxInfoAndOpenUI)
	-- EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_SHARE, ShareDayFinalyShareUI.ShowUI)
	RefluxTrainingUI.RegisterPanelEvent(RefluxTrainingUI.RefluxPanel, UIReflux.GetRefluxInfoAndOpenUI, EventRefluxCloseUI)
end

function UIReflux:GetRefluxInfoAndOpenUI()
	log("[HHF]UIReflux:GetRefluxInfoAndOpenUI, Open Recall Activity.");
	ConnectionWaitingUI:Show();
	UIReflux.timer = Timer.InsertTimer(3, UIReflux.OnTimerCallback, false);
	BP_Reflux_Friend_Page_Idx = 1;
	UIReflux.HaveClickOpen = true;
	RefluxMgr.StartToGetPlatformFriendInfo();
	RefluxMgr.SendGetRefluxInfo()
end

function UIReflux.OnTimerCallback()
	log("[HHF]UIReflux.OnTimerCallback");
	ConnectionWaitingUI:Hide();
	UIReflux.timer = nil;
end

function UIReflux.DeleteTableAt(index)
	log("[HHF]UIReflux:DeleteTableAt, index = " .. index);
	log("[HHF]UIReflux:DeleteTableAt, before delete UIReflux.friendList.num = " .. #UIReflux.friendList);
	for i = index, #UIReflux.friendList do
		UIReflux.friendList[i] = UIReflux.friendList[i + 1];
	end
	log("[HHF]UIReflux:DeleteTableAt, after delete UIReflux.friendList.num = " .. #UIReflux.friendList);
end

function UIReflux.OnGetRefluxFriendList(frdList, ext)
	log("[HHF]UIReflux.OnGetRefluxFriendList");
	UIReflux.friendList = {}
	BP_ARRAY_Reflux_Friend_Infos = {}
	local listNeedUin = {} 
	if frdList then
		for i = 1, #frdList do
			local svrData = frdList[i]
			local frd = {}

			if svrData.visible == 1 then 
	            frd.openID = "" -- svrData.openid  
	            frd.uid = tostring(svrData.uid)

	            local frdInfo = FriendSystem.GetFriendDataByGID(frd.uid)
				if frdInfo then
					frd.nickName = frdInfo.nickName
	                frd.headUrl = frdInfo.picUrl
	                frd.level = frdInfo.level 
				else
					table.insert(listNeedUin, frd.uid)
					frd.nickName = ""
	                frd.headUrl = ""
	                frd.level = 0
				end

				frd.inviteStatus = svrData.status
				frd.callReward = svrData.reward
				frd.weekNum = svrData.totalnum
				frd.Type = svrData.type
				frd.rank = svrData.rank

				if frd.weekNum >= 3 and frd.inviteStatus == 0 then
					frd.inviteStatus = 1 
				end
				table.insert(UIReflux.friendList, frd)
			end
		end
    end

    UIReflux.FilterFriendsByITOP(false);

    if #listNeedUin > 0 then
        --log_tree("[HHFTEST]UIReflux.OnGetRefluxFriendList, need get info list = ", listNeedUin, "[HHFTEST]")
        ProfileMgr.GetFriendProfileList(listNeedUin, UIReflux.OnGetFriendProfile, false)
    end
	
    local function sortFriendList(f1, f2)
    	local state = false
    	if f1.inviteStatus < f2.inviteStatus then 
    		state = true
    	elseif f1.inviteStatus > f2.inviteStatus then 
    		state = false
    	else
    		if f1.Type < f2.Type then 
    			state = true
    		elseif f1.Type > f2.Type then
    			state = false
    		else
    			state = f1.rank < f2.rank
    		end
    	end
    	return state
	end	
	table.sort(UIReflux.friendList, sortFriendList)
	
	BP_Reflux_Friend_Count = #UIReflux.friendList
    UIReflux.GetNextPageData()
    
    UIReflux.InitAwardData(ext)
    
    BP_Reflux_Total_Back_Count = ext.recall_num    
    local NeedShowAward = ext.recall_player_award == 1 
    if NeedShowAward then 
    	RefluxTrainingAwardUI.ShowUI()
    end

    RefluxTrainingUI.RecordListData(ext.recall_num, ext.recall_list);
end

function UIReflux.GetNextPageData()
	local startIdx = (BP_Reflux_Friend_Page_Idx - 1) * 4 + 1;
	log("[HHF]UIReflux.GetNextPageData, page_idx = " .. BP_Reflux_Friend_Page_Idx .. ", start_idx = " .. startIdx);
	UIReflux.GetPageDataFromeIdx(startIdx)
end

function UIReflux.GetPageDataFromeIdx(start)
	BP_ARRAY_Reflux_Friend_Infos = {}
	for i = start, BP_Reflux_Friend_Page_Idx * 4 do		
		if UIReflux.friendList[i] ~= nil then
			table.insert(BP_ARRAY_Reflux_Friend_Infos, UIReflux.friendList[i])
		end
	end
	--log_tree("[HHFTEST]UIReflux.GetPageDataFromeIdx, BP_ARRAY_Reflux_Friend_Infos = " , BP_ARRAY_Reflux_Friend_Infos, "[HHFTEST]")
end

function UIReflux.FilterFriendsByITOP(update)
	if FuncUtil:CountTable(UIReflux.UIDMapOpenID) > 0 then
		log("[HHF]UIReflux.FilterFriendsByITOP, before filter UIReflux.friendList.num = " .. #UIReflux.friendList);
    	for i = 1, #UIReflux.friendList do
    		if UIReflux.UIDMapOpenID[UIReflux.friendList[i].uid] == nil then
				log("[HHF]UIReflux.FilterFriendsByITOP, remove uid = " .. UIReflux.friendList[i].uid);
    			UIReflux.DeleteTableAt(i);
    			UIReflux.FilterFriendsByITOP(update);
    			return;
    		else
				log("[HHF]UIReflux.FilterFriendsByITOP, keep uid = " .. UIReflux.friendList[i].uid .. ", openID = " .. UIReflux.UIDMapOpenID[UIReflux.friendList[i].uid].openid);
    		end
    	end
		BP_Reflux_Friend_Count = #UIReflux.friendList;
		log("[HHF]UIReflux.FilterFriendsByITOP, after filter UIReflux.friendList.num = " .. #UIReflux.friendList);

		if update then
			BP_Reflux_Friend_Page_Idx = 1;
			UIReflux.GetNextPageData()
			LuaClassObj.HandleUIMessage(bp_reflux, "UpdateFriendData")
		end
    else
		log("[HHF]UIReflux.FilterFriendsByITOP, UIReflux.UIDMapOpenID.num = 0");
    end
end

function UIReflux.InitAwardData(ext)
    local actData = DataMgr.GetActivityByType(ActivityType.FRIEND_RECALL_REFLUX)
    if actData then
	    BP_Reflux_Open_Time = actData.Desc --string.format("%s~%s，成功邀请好友登陆游戏即可", os.date(dateFormat, actData.StartTime), os.date(dateFormat, actData.EndTime))
		BP_Reflux_Help_Content = actData.Detail --string.format(HELP_TEXT, PlatFormStr[BP_Platform], PlatFormStr[BP_Platform]) 
	else
    	log("[HHF]UIReflux.InitAwardData, could not found activtyType = ActivityType.FRIEND_RECALL_REFLUX");
	end
    log("[HHF]UIReflux.InitAwardData, Open_Time = " .. BP_Reflux_Open_Time .. ", Help_Content = " .. BP_Reflux_Help_Content);
    
	BP_ARRAY_Reflux_Award_Infos = {}
	for i = 1, 4 do
		local actOne = {}
		actOne.itemIdx = i		
        actOne.status = ext.recall_reward[i] 
        --actOne.currentInviteCount = ext.recall_num 
        local awardConfig = Client.GetTableData("RefluxAwards", tostring(i)) 
        
        if awardConfig then
            actOne.needInviteCount = awardConfig.RefluxNum
            local drop_util = require("client.common.drop_util")
            local itemlist = drop_util.GetDropsList({awardConfig.DropID});
            if itemlist[1] ~= nil then
            	actOne.awardID = itemlist[1].DropItemID;
            	actOne.expireTime = itemlist[1].DropItemTime;
            else
            	actOne.awardID = awardConfig.DropID 
            	actOne.expireTime = 0;
            end
            actOne.iconPath = awardConfig.IconPath 
            actOne.iconOpenPath = awardConfig.IconGot 
            actOne.name = awardConfig.BoxName
        else
            actOne.needInviteCount = 0
            actOne.awardID = 0
            actOne.iconPath = ""
            actOne.iconOpenPath = ""
            actOne.name = ""
            actOne.expireTime = 0;
        end
        actOne.currentInviteCount = (ext.recall_num < actOne.needInviteCount) and ext.recall_num or actOne.needInviteCount;
		table.insert(BP_ARRAY_Reflux_Award_Infos, actOne)
	end
	--table.sort(BP_ARRAY_Reflux_Award_Infos, function(a,b) return a.needInviteCount < b.needInviteCount end)
	--log_tree("[HHFTEST]UIReflux.InitAwardData, Award_Infos = " , BP_ARRAY_Reflux_Award_Infos, "[HHFTEST]");
	-- BP_Reflux_Help_Content = string.format(HELP_TEXT, PlatFormStr[BP_Platform], PlatFormStr[BP_Platform])
end

function UIReflux.OpenUI()
	log("[HHF]UIReflux.OpenUI, UIReflux.HaveClickOpen = " .. tostring(UIReflux.HaveClickOpen));
	if UIReflux.HaveClickOpen == true then
		UIReflux.HaveClickOpen = false;
		if UIReflux.timer ~= nil then
			Timer.RemoveTimer(UIReflux.timer);
		end
		ConnectionWaitingUI:Hide();
		LuaClassObj.HandleDynamicCreation(bp_reflux)
		LuaClassObj.HandleUIMessage(bp_reflux, "UIShow")
		LuaClassObj.HandleUIMessage(bp_reflux, "UpdateFriendData")
		LuaClassObj.HandleUIMessage(bp_reflux, "UpdateAwardData")
	end
end

function UIReflux.OnGetFriendProfile(profileList)
	log("[HHF]UIReflux.OnGetFriendProfile, profileList.num = " .. FuncUtil:CountTable(profileList));
	--log_tree("[HHFTEST]UIReflux.OnGetFriendProfile, profileList = ", profileList, "[HHFTEST]")
	for k, v in pairs(profileList) do
		for i = #BP_ARRAY_Reflux_Friend_Infos, 1, - 1 do
			if tonumber(BP_ARRAY_Reflux_Friend_Infos[i].uid) == tonumber(v.uid) then
				BP_ARRAY_Reflux_Friend_Infos[i].nickName = v.nickName
				BP_ARRAY_Reflux_Friend_Infos[i].headUrl = v.picUrl
			end
		end

		for i = #UIReflux.friendList, 1, - 1 do
			if tonumber(UIReflux.friendList[i].uid) == tonumber(v.uid) then
				UIReflux.friendList[i].nickName = v.nickName
				UIReflux.friendList[i].headUrl = v.picUrl
			end
		end
	end
	
	LuaClassObj.HandleUIMessage(bp_reflux, "RefreshFriendData")
end

function UIReflux.ResetData()
	log("[HHF]UIReflux.ResetData");
	UIReflux.PLATFriendsRegList = {};
	UIReflux.UIDMapOpenID = {};
	UIReflux.FriendsPage = 1;
	UIReflux.bWaitingCallback = false;
	UIReflux.HaveGotData = false;
end

function UIReflux.SetAwardGet(idx)
    log("[HHF]UIReflux.SetAwardGet, idx = " .. idx);
    for _, info in pairs(BP_ARRAY_Reflux_Award_Infos) do
    	if info.itemIdx == idx then
    		info.status = 2
    		LuaClassObj.HandleUIMessage(bp_reflux, "UpdateAwardData") 
    		break
    	end
    end
end

function UIReflux.RefreshPromotionInfo(eventType, eventID, changeList)
	log("[HHF]UIReflux.RefreshPromotionInfo, eventType = " .. tostring(eventType) .. ", eventID = " .. tostring(eventID) .. ", changeList = " .. tostring(changeList));
	if changeList.typeList[ActivityType.PROMOTOR] == true then
		PromotionMgr.DealPromotionFromActivity()
		LuaClassObj.HandleUIMessage(bp_reflux, "UpdateAwardData")
	end
end

function UIReflux.InviteFriendByFacebook()
	log("[HHF]UIReflux.InviteFriendByFacebook");
	local paramtable = {};
	paramtable.invitetype = "batch";
	paramtable.userlist = {};

	if UIReflux.UIDMapOpenID[BP_Reflux_Call_Friend_UID] ~= nil then
		local openID = UIReflux.UIDMapOpenID[BP_Reflux_Call_Friend_UID].openid;
		local friend = UIReflux.PLATFriendsRegList[openID];
		if friend ~= nil then	
			table.insert(paramtable.userlist, friend.userID);
			local title = FuncUtil.GetLocalizeResStr("106052");
			local param = json.encode(paramtable);
			local content = FuncUtil.GetLocalizeResStr("4366");
			log("[HHF]UIReflux.InviteFriendByFacebook, param = " .. param);
			UIReflux.bWaitingCallback = true;
			Client.InviteFBFriendsUnregistered(NetInterface, title, content, param);
		else
			log("[HHF]UIReflux.InviteFriendByFacebook, friendInfo = nil which openID = " .. openID .. ", try to get friends info again!");
			UIReflux.HaveGotData = false;
			RefluxMgr.StartToGetPlatformFriendInfo();
		end
	else
		log("[HHF]UIReflux.InviteFriendByFacebook, friendInfo = nil which uid = " .. BP_Reflux_Call_Friend_UID);
	end

	--[[ for test
	PlatformFriendsUnregisteredUI.OnGetFriendsUnreg(0, nil)
	--]]
end

function UIReflux.UpdateFriendInviteStatus(uid)
	log("[HHF]UIReflux.UpdateFriendInviteStatus, uid = " .. uid)
	for i = 1, #BP_ARRAY_Reflux_Friend_Infos do
		local svrData = BP_ARRAY_Reflux_Friend_Infos[i]
		if svrData.uid == tostring(uid) then
            svrData.inviteStatus = 1			
			svrData.weekNum = svrData.weekNum + 1
			LuaClassObj.HandleUIMessage(bp_reflux, "RefreshFriendData")			
			break
		end
	end

	for i = 1, #UIReflux.friendList do
		local svrData = UIReflux.friendList[i]
		if svrData.uid == tostring(uid) then
            svrData.inviteStatus = 1			
			svrData.weekNum = svrData.weekNum + 1
			break
		end
	end
end

function EventRefluxNextPage()
	log("[HHF]EventRefluxNextPage");
	if BP_Reflux_Friend_Page_Idx * 4 >= #UIReflux.friendList then
		BP_Reflux_Friend_Page_Idx = 1;
	else
		BP_Reflux_Friend_Page_Idx = BP_Reflux_Friend_Page_Idx + 1;
	end
	
	UIReflux.GetNextPageData()
	LuaClassObj.HandleUIMessage(bp_reflux, "UpdateFriendData")
end

function EventRefluxGetAward()
	log("[HHF]EventRefluxGetAward, BP_Reflux_Award_Index_Get = " .. BP_Reflux_Award_Index_Get)
	
	local awardInfo = BP_ARRAY_Reflux_Award_Infos[BP_Reflux_Award_Index_Get]
	if awardInfo then		
		RefluxMgr.SenGetRecallAward(BP_Reflux_Award_Index_Get)
	end
	
	BP_Reflux_Award_Index_Get = - 1
end

-- 邀请好友
function EventRefluxFriendInvite()
	log("[HHF]EventRefluxFriendInvite, uid = " .. BP_Reflux_Call_Friend_UID)
	
	local strTile = DataMgr.GetMsgByID(102012)
	local strMsg = DataMgr.GetMsgByID(9990002)
	strMsg = string.format(strMsg, PlatFormStr[BP_Platform])
	
	local function clickOkCallback()
		local device = string.lower(Client.GetDevicePlatformName());
		if device == "windows" then
			RefluxMgr.SendRecallFriend(BP_Reflux_Call_Friend_UID);
		else
			UIReflux.InviteFriendByFacebook();
		end
	end
	CommonMessageBoxUI:ShowPanel(2, strTile, strMsg, clickOkCallback)
end

function EventRefluxViewRegisterFriend()
	log("[HHF]EventRefluxViewRegisterFriend")
	LuaClassObj.HandleUIMessage(bp_reflux, "ShowReigsterFriends")
end

function EventRefluxCloseUI()
	log("[HHF]EventRefluxCloseUI")
	UIReflux.HaveClickOpen = false;
	LuaClassObj.HandleUIMessage(bp_reflux, "UIHide")
end

function EventRefluxRule()
	log("[HHF]EventRefluxRule")
	PromotionRule_Title = FuncUtil.GetLocalizeResStr("4726");
	PopUpNoticeUI.ShowMessageBox(PromotionRule_Title, BP_Reflux_Help_Content)
end

function EventRefluxViewBox()
	log("[HHF]EventRefluxViewBox, BP_Reflux_Award_Index_Get = " .. BP_Reflux_Award_Index_Get);
    local awardInfo = BP_ARRAY_Reflux_Award_Infos[BP_Reflux_Award_Index_Get]
	if awardInfo then		
		CommonTreasureBoxPopup:showPanelByDropId(awardInfo.awardID)
		CommonTreasureBoxPopup:SetTitleString(awardInfo.name)
	else
		log("[HHF]EventRefluxViewBox, BP_ARRAY_Reflux_Award_Infos[" .. BP_Reflux_Award_Index_Get .. "] = nil");
	end
end

function EventFetchInfo()
	
end

function EventSetInfo_Push()
end
