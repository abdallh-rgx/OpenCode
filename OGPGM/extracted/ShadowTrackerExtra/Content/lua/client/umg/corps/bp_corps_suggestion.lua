
-- 军团推荐UI

CorpsSuggestionUI = CorpsSuggestionUI or {
    IsFirstGetInvitedCorpsList = true;
    isShowing = false,
}

BP_Corps_MemberID = "";



-- 军团信息
BP_STRUCT_CorpsSnapInfo = 
{
	commander_id = "",
	commander_name = "",
    commander_gender = 0,
	icon = "",
	level = 0,
	corps_id = "",
	name = "",
	city = "",
	province = "",
	friend_num = 0,
	need_approval = true,
	join_level = 0,
	join_segment = 0,
	activeness = 0,
    activeness_tag = false,
	announcement = "",
    icon_text = "",
    icon_text_colour = 0,
	BP_ARRAY_Corps_MemberList = 
	{
		BP_Corps_MemberID = _G.BP_Corps_MemberID,
	}
};

-- 邀请军团信息
BP_STRUCT_CorpsSuggestion_InviteCorpsInfo =
{
    -- corps_id = 0,
    corps_id_str = "",
    name = "",
    recomm_name = "",
    friend_num = 0,
    city = "",
    level = 0,
    icon = "",
    activeness = 0,
    BP_ARRAY_Corps_MemberList =
    {
        BP_Corps_MemberID = _G.BP_Corps_MemberID,
    },

    invite_status = 0,
    commander_id = "",
}

BP_STRUCT_CorpsFriendInfo = 
{
	HeadUrl = "",
	Frame = 0,
	Level = 0,
}

-- 当前选中军团好友头像列表
BP_ARRAY_Corps_SelectedFriends = 
{
	BP_STRUCT_CorpsFriendInfo = _G.BP_STRUCT_CorpsFriendInfo,
}

BP_STRUCT_Corps_SelectedCommanderInfo = 
{
	url = "",
	level = 0,
	frame = 0,
};

-- 军团推荐列表
BP_ARRAY_Corps_SuggestionList = 
{
	BP_STRUCT_CorpsSnapInfo = _G.BP_STRUCT_CorpsSnapInfo,
};

BP_ARRAY_Corps_ApplicationTempIDList = 
{
	id = "",
};

-- 军团申请列表
BP_ARRAY_Corps_ApplicationList = 
{
	BP_STRUCT_CorpsSnapInfo = _G.BP_STRUCT_CorpsSnapInfo,
};

-- 军团搜索列表
BP_ARRAY_Corps_SearchList = 
{
	BP_STRUCT_CorpsSnapInfo = _G.BP_STRUCT_CorpsSnapInfo,
};

-- 军团邀请列表
BP_ARRAY_Corps_InvitedCorpsList =
{
    BP_STRUCT_CorpsSuggestion_InviteCorpsInfo = _G.BP_STRUCT_CorpsSuggestion_InviteCorpsInfo,
};

-- 当前选中页签 1推荐 2申请 3邀请军团
BP_Corps_Suggestion_Toggle = 1; 

-- 当前选中推荐项
BP_Corps_Suggestion_CurSelectedIndex = -1;

-- 旧的选中推荐项
BP_Corps_Suggestion_OldSelectedIndex = -1;

-- 推荐条件：无需审批
BP_Corps_Suggestion_NotNeedApproval = false;

-- 推荐条件：符合要求
BP_Corps_Suggestion_AccordRequirement = false;

-- 搜索名字
BP_Corps_Suggestion_SearchName = "";

-- 显示搜索结果
BP_Corps_Suggestion_SearchResult = false;

BP_Corps_Suggestion_CityID = 0;

-- 显示军团详细信息
BP_STRUCT_CORPS_Suggestion_DetailPanelData =  {BP_STRUCT_CorpsSnapInfo = _G.BP_STRUCT_CorpsSnapInfo}

-- 是否需要显示动画
BP_CorpsSuggestionShowAnimation = true

-- 注册Widget
function bp_corps_suggestion_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_corps_suggestion,
    	{{Path="/Game/UMG/UI_Logic/Corps/CorpsSuggestion_BP.CorpsSuggestion_BP_C", Container="Default", ZOrder = BP_ENUM_UI_CORPS_ZORDER + 1}},
    	{"Lobby"},
		false,
		false,
		true
  	);
  	CorpsUI.RegisterPanelEvent(1,EventCorpsSuggestionShowUI,EventCorpsSuggestionHideUI)
end

local lastRefreshTime = 0;

local function CorpsSuggestionEventHandler(eventType, eventID, vars)
	--列表更新
	if eventID == EVENTID_CORPS_UPDATE_SUGGESTIONLIST then
        CorpsSuggestionUI.UpdateList();
	elseif eventID == EVENTID_ROLEINFO_UPDATE_CARDINFO then
		BP_Corps_Suggestion_CityID = RoleInfoSystem.SocialCard.city_id or 0;
		log("CorpsSuggestionEventHandler city_id=" .. BP_Corps_Suggestion_CityID);
	end
end

function EventCorpsSuggestionHideUI()
	log("EventCorpsSuggestionHideUI");
	CorpsSuggestionUI.Release();
    UIManager.Hide(eUIType.eCorpsSuggestionUI)
	LuaClassObj.HandleUIMessage(bp_corps_suggestion, "UIHide");
end

function CorpsSuggestionUI.Init()
    CorpsSuggestionUI.isShowing = true;
    BP_ARRAY_Corps_InvitedCorpsList = {}
    lastRefreshTime = 0;
    CorpsSuggestionSystem.Init();

    if CorpsSuggestionSystem.hasNewIvitedCorps then
        BP_Corps_Suggestion_Toggle = 3
    else
        BP_Corps_Suggestion_Toggle = 1
    end

    log("CorpsSuggestionUI.Init BP_Corps_Suggestion_Toggle "..tostring(BP_Corps_Suggestion_Toggle))

    EventSystem:registEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_SUGGESTIONLIST, CorpsSuggestionEventHandler);
    EventSystem:registEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_CARDINFO, CorpsSuggestionEventHandler);
    EventSystem:registEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_INVITED_CORPS_LIST, CorpsSuggestionUI.OnUpdateInvitedCorpsList);
    EventSystem:registEvent(EVENTTYPE_CORPS, EVENTID_CORPS_NO_JOIN, CorpsSuggestionUI.OnNoJoin);
end

function CorpsSuggestionUI.Release()
    CorpsSuggestionUI.isShowing = false;
	EventSystem:unregistEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_SUGGESTIONLIST, CorpsSuggestionEventHandler);
	EventSystem:unregistEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_CARDINFO, CorpsSuggestionEventHandler);
    EventSystem:unregistEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_INVITED_CORPS_LIST, CorpsSuggestionUI.OnUpdateInvitedCorpsList);
    EventSystem:unregistEvent(EVENTTYPE_CORPS, EVENTID_CORPS_NO_JOIN, CorpsSuggestionUI.OnNoJoin);
	CorpsSuggestionSystem.Release();
end

function CorpsSuggestionUI.CleanList()
	LuaClassObj.HandleUIMessage(bp_corps_suggestion, "CleanList");
end

function CorpsSuggestionUI.UpdateList()
	if BP_Corps_Suggestion_Toggle == 1 then
		if BP_Corps_Suggestion_SearchName == "" and #BP_ARRAY_Corps_SuggestionList > 0 then
			BP_Corps_Suggestion_CurSelectedIndex = 0;
		elseif BP_Corps_Suggestion_SearchName ~= "" and #BP_ARRAY_Corps_SearchList > 0 then
			BP_Corps_Suggestion_CurSelectedIndex = 0;
		else
			BP_Corps_Suggestion_CurSelectedIndex = -1;
		end
	elseif BP_Corps_Suggestion_Toggle == 2 then
		if #BP_ARRAY_Corps_ApplicationList > 0 then
			BP_Corps_Suggestion_CurSelectedIndex = 0;
		else
			BP_Corps_Suggestion_CurSelectedIndex = -1;
		end
    elseif BP_Corps_Suggestion_Toggle == 3 then
        BP_Corps_Suggestion_CurSelectedIndex = -1;
	end
	LuaClassObj.HandleUIMessage(bp_corps_suggestion, "UpdateList");
	LuaClassObj.HandleUIMessage(bp_corps_suggestion, "RefreshSelectDetailInfo");
	CorpsSuggestionSystem.GetSelectedHeadIcons();
end

function CorpsSuggestionUI.UpdateSearchResult()
	log("CorpsSuggestionUI.UpdateSearchResult()");
	BP_Corps_Suggestion_SearchResult = true;
	if #BP_ARRAY_Corps_SearchList > 0 then
		BP_Corps_Suggestion_CurSelectedIndex = 0;
	else
		BP_Corps_Suggestion_CurSelectedIndex = -1;
	end
	LuaClassObj.HandleUIMessage(bp_corps_suggestion, "UpdateSearchResult");
	CorpsSuggestionSystem.GetSelectedHeadIcons();
end

function EventCorpsSuggestionShowUI()	
	log("EventCorpsSuggestionShowUI");
	CorpsSuggestionUI.Init();
	LuaClassObj.HandleDynamicCreation(bp_corps_suggestion);
	LuaClassObj.HandleUIMessage(bp_corps_suggestion, "UIShow");
    UIManager.Show(eUIType.eCorpsSuggestionUI)
    BP_CorpsSuggestionShowAnimation = false
end

-- 军团搜索
function EventCorpsSuggestionClickSearch()
	log("EventCorpsSuggestionClickSearch");
    if BP_Corps_Suggestion_SearchName == "" or BP_Corps_Suggestion_SearchName == nil then
        ShowNotice(410073);
        return;
    end
	CorpsSuggestionSystem.SendReqSearch(BP_Corps_Suggestion_SearchName);
end

-- 申请加入
function EventCorpsSuggestionClickApply()
	log("EventCorpsSuggestionClickApply  " .. BP_Corps_Suggestion_CurSelectedIndex);
	local corps_id = "";
	if BP_Corps_Suggestion_SearchResult == false then
		corps_id = BP_ARRAY_Corps_SuggestionList[BP_Corps_Suggestion_CurSelectedIndex + 1].corps_id;
	else
		corps_id = BP_ARRAY_Corps_SearchList[BP_Corps_Suggestion_CurSelectedIndex + 1].corps_id;
	end
	log("EventCorpsSuggestionClickApply id=" .. tonumber(corps_id));
	CorpsMemberSystem.SendApplyJoinCorps(tonumber(corps_id));
end

-- 切换推荐/已申请页签
function EventCorpsSuggestionOnTabChange()
	log("EventCorpsSuggestionOnTabChange");
	BP_Corps_Suggestion_SearchName = "";
	BP_Corps_Suggestion_SearchResult = false;
	if BP_Corps_Suggestion_OldSelectedIndex >= 0 then
		BP_Corps_Suggestion_OldSelectedIndex = -1;
	end
	BP_Corps_Suggestion_CurSelectedIndex = -1;
	if BP_Corps_Suggestion_Toggle == 1 then
		local param1 = true;
		local param2 = false;
		if BP_Corps_Suggestion_NotNeedApproval then
			param1 = false;
		end
		if BP_Corps_Suggestion_AccordRequirement then
			param2 = true;
		end
		CorpsSuggestionSystem.SendReqSuggestionList(param1, param2);
	elseif BP_Corps_Suggestion_Toggle == 2 then
		CorpsSuggestionSystem.SendReqApplicationList();
    elseif BP_Corps_Suggestion_Toggle == 3 then
        BP_ARRAY_Corps_InvitedCorpsList = {};
        CorpsSuggestionUI.IsFirstGetInvitedCorpsList = true;
        CorpsSuggestionSystem.get_corps_invitee_list_req();
	end
end

-- 切换当前选中item
function EventCorpsSuggestionOnSelectItemChange()
	log("EventCorpsSuggestionOnSelectItemChange");
	if BP_Corps_Suggestion_OldSelectedIndex >= 0 then
		LuaClassObj.HandleUIMessage(bp_corps_suggestion, "UnSelectItem");
	end

    if BP_Corps_Suggestion_Toggle == 1 or BP_Corps_Suggestion_Toggle == 2 then
        LuaClassObj.HandleUIMessage(bp_corps_suggestion, "RefreshSelectDetailInfo");
    elseif BP_Corps_Suggestion_Toggle == 3 then
        CorpsSuggestionUI.UpdateSelectedInvitedCorps();
        LuaClassObj.HandleUIMessageNoFetch(bp_corps_suggestion, "UpdateSelectedInvitedInfo");
    end

	CorpsSuggestionSystem.GetSelectedHeadIcons();
end

function EventCorpsSuggestionClickRefresh()
	log("EventCorpsSuggestionClickRefresh");
    local curTime = os.time();
    if curTime - lastRefreshTime < 2 then
        ShowNotice(421015);
        return;
    end 
    lastRefreshTime = curTime;
	BP_Corps_Suggestion_SearchName = "";
	BP_Corps_Suggestion_SearchResult = false;
	local param1 = true;
	local param2 = false;
	if BP_Corps_Suggestion_NotNeedApproval then
		param1 = false;
	end
	if BP_Corps_Suggestion_AccordRequirement then
		param2 = true;
	end
	CorpsSuggestionSystem.SuggestionList = {};
	CorpsSuggestionSystem.SendReqSuggestionList(param1, param2);
end

function EventFetchCorpsSuggestionInfo()
end

function EventCorpsSuggestionOnFilterStateChange()
    BP_Corps_Suggestion_SearchResult = false;
	local filterList = CorpsSuggestionSystem.FilterSuggestionList(not BP_Corps_Suggestion_NotNeedApproval, BP_Corps_Suggestion_AccordRequirement);

	local function GetTableLen(tab)
		local len = 0;
		for k, v in pairs(tab) do
			len = len + 1;
		end
		return len;
	end

	local filterListLen = GetTableLen(filterList);
	if filterListLen >= 10 then
		BP_ARRAY_Corps_SuggestionList = {};
		for k,v in pairs(filterList) do
        	local corpsInfo = CorpsSuggestionSystem.CreateSuggestItem(v);
        	table.insert(BP_ARRAY_Corps_SuggestionList, corpsInfo);
    	end
    	table.sort(BP_ARRAY_Corps_SuggestionList, CorpsSuggestionSystem.CompareItem);
        CorpsSuggestionSystem.TagActiveness(BP_ARRAY_Corps_SuggestionList);
    	CorpsSuggestionUI.UpdateList();
	else
		CorpsSuggestionSystem.SendReqSuggestionList(not BP_Corps_Suggestion_NotNeedApproval, BP_Corps_Suggestion_AccordRequirement);
	end
end

function EventCorpsSuggestionClickCleanSearch()
	BP_Corps_Suggestion_SearchName = "";
	BP_Corps_Suggestion_SearchResult = false;
	LuaClassObj.HandleUIMessage(bp_corps_suggestion, "UpdateList");
	LuaClassObj.HandleUIMessage(bp_corps_suggestion, "RefreshSelectDetailInfo");
	CorpsSuggestionSystem.GetSelectedHeadIcons();
end

function EventCorpsSuggestionHelpShow()
    log("no clan info.")
    local title = Client.GetTableData("LocalizeRes", 410041).TextValue
    local context = Client.GetTableData("LocalizeRes", 4226).TextValue
    ..Client.GetTableData("LocalizeRes", 4812).TextValue
    ..Client.GetTableData("LocalizeRes", 4229).TextValue
    ..Client.GetTableData("LocalizeRes", 4813).TextValue
    ..Client.GetTableData("LocalizeRes", 4814).TextValue
    ..Client.GetTableData("LocalizeRes", 4232).TextValue
    ..Client.GetTableData("LocalizeRes", 4815).TextValue
    ..Client.GetTableData("LocalizeRes", 4816).TextValue
    ..Client.GetTableData("LocalizeRes", 4817).TextValue
    ..Client.GetTableData("LocalizeRes", 4818).TextValue
    ..Client.GetTableData("LocalizeRes", 4235).TextValue
    ..Client.GetTableData("LocalizeRes", 4236).TextValue
    ..Client.GetTableData("LocalizeRes", 4819).TextValue
    ..Client.GetTableData("LocalizeRes", 4820).TextValue
    ..Client.GetTableData("LocalizeRes", 4242).TextValue
    ..Client.GetTableData("LocalizeRes", 4821).TextValue
    ..Client.GetTableData("LocalizeRes", 4822).TextValue
    ..Client.GetTableData("LocalizeRes", 4823).TextValue
    context = string.gsub(context, "\\n", "\n")
    PopUpNoticeUI.ShowMessageBox(title, context)
	-- PopUpNoticeUI.ShowMessageBox("帮助","Surprise！！")
end

function EventCorpsSuggestionShowRole()
	local commander = 0;
	if BP_Corps_Suggestion_Toggle == 1 then
        if BP_Corps_Suggestion_SearchResult == false then
            commander = BP_ARRAY_Corps_SuggestionList[BP_Corps_Suggestion_CurSelectedIndex + 1].commander_id;
        else
            commander = BP_ARRAY_Corps_SearchList[BP_Corps_Suggestion_CurSelectedIndex + 1].commander_id;
        end
    elseif BP_Corps_Suggestion_Toggle == 2 then
        commander = BP_ARRAY_Corps_ApplicationList[BP_Corps_Suggestion_CurSelectedIndex + 1].commander_id;
    elseif BP_Corps_Suggestion_Toggle == 3 then
        commander = BP_STRUCT_CORPS_Suggestion_DetailPanelData.BP_STRUCT_CorpsSnapInfo.commander_id;
    end
    RoleInfoSystem.Enter(commander);
    RoleInfoUI.Init(false, RoleInfoOpenFromType.CorpsSuggestion);
end

function EventSetCorpsSuggestionInfo_Push()
end

-- 推荐军团举报
function EventCorpsRecommendListReport()
    
    CommonMessageBoxUI:ShowPanel(2, DataMgr.GetMsgByID(101001), DataMgr.GetMsgByID(411043), 
        
        function ()
            
            local corps_id = ""
            local corps_name = ""
            local corps_announcement = ""
            local commander_name = ""
            
            if BP_Corps_Suggestion_SearchResult == false then
                corps_id = BP_ARRAY_Corps_SuggestionList[BP_Corps_Suggestion_CurSelectedIndex + 1].corps_id;
                corps_name = BP_ARRAY_Corps_SuggestionList[BP_Corps_Suggestion_CurSelectedIndex + 1].name;
                corps_announcement = BP_ARRAY_Corps_SuggestionList[BP_Corps_Suggestion_CurSelectedIndex + 1].announcement;
                commander_name = BP_ARRAY_Corps_SuggestionList[BP_Corps_Suggestion_CurSelectedIndex + 1].commander_name;
            else
                corps_id = BP_ARRAY_Corps_SearchList[BP_Corps_Suggestion_CurSelectedIndex + 1].corps_id;
                corps_name = BP_ARRAY_Corps_SearchList[BP_Corps_Suggestion_CurSelectedIndex + 1].name;
                corps_announcement = BP_ARRAY_Corps_SearchList[BP_Corps_Suggestion_CurSelectedIndex + 1].announcement;
                commander_name = BP_ARRAY_Corps_SearchList[BP_Corps_Suggestion_CurSelectedIndex + 1].commander_name;
            end
            
            CorpsMgr.SendReportInfo(commander_name, tonumber(corps_id), corps_name, corps_announcement)
            
            --DataMgr.ShowNoticeByID(117066);
        end
    );

end

-- 刷新邀请列表
function CorpsSuggestionUI.OnUpdateInvitedCorpsList()
    if BP_Corps_Suggestion_Toggle ~= 3 then
        return;
    end

    CorpsSuggestionSystem.hasNewIvitedCorps = false;
    UpdateLobbyCorpsRedDot(CorpsMgr.HasRedDot("lobby"))
    log("CorpsSuggestionUI.OnUpdateInvitedCorpsList CorpsSuggestionSystem.hasNewIvitedCorps "..tostring(CorpsSuggestionSystem.hasNewIvitedCorps))

    if CorpsSuggestionUI.IsFirstGetInvitedCorpsList then
        CorpsSuggestionUI.IsFirstGetInvitedCorpsList = false;
        CorpsSuggestionSystem.CurrentInvitedCorpsSummaryReq();
    end
end

function CorpsSuggestionUI.UpdateInvitedCorpsSummaryList()
    if not CorpsSuggestionUI.isShowing then
        return;
    end

    if BP_Corps_Suggestion_Toggle ~= 3 then
        return;
    end

    local cityID = RoleInfoSystem.SocialCard.city_id or 0;

    BP_ARRAY_Corps_InvitedCorpsList = {}
    local recommName = "";
    for k,v in pairs(CorpsSuggestionSystem.InvitedCorpsArray) do
        if v.name ~= nil then
            recommName = ProfileMgr.GetNickName(v.invite_uid) or v.invite_name
            recommName = FuncUtil.SubString(recommName, 1, 9);
            table.insert(BP_ARRAY_Corps_InvitedCorpsList, {
                corps_id_str = tostring(v.corps_id),
                name = v.name,
                recomm_name = recommName,
                friend_num = v.friend_num,
                level = v.level,
                status = v.status,
                icon = v.icon,
                activeness = v.activeness,
                invite_status = v.invite_status,
                time = v.time,
                BP_ARRAY_Corps_MemberList = v.BP_ARRAY_Corps_MemberList,
                commander_id = v.commander_id,
            });
        end
    end

    table.sort(BP_ARRAY_Corps_InvitedCorpsList, function(a, b)
            if a.invite_status ~= b.invite_status then
                return b.invite_status ~= 0;
            end

            return a.time > b.time;
        end);

    -- log_tree("CorpsSuggestionUI.UpdateInvitedCorpsSummaryList BP_ARRAY_Corps_InvitedCorpsList", BP_ARRAY_Corps_InvitedCorpsList);

    if #BP_ARRAY_Corps_InvitedCorpsList == 0 then
        BP_Corps_Suggestion_CurSelectedIndex = -1
        LuaClassObj.HandleUIMessageNoFetch(bp_corps_suggestion, "UpdateInvitedCorpsList");
    else
        BP_Corps_Suggestion_CurSelectedIndex = math.max(0, BP_Corps_Suggestion_CurSelectedIndex);
        BP_Corps_Suggestion_CurSelectedIndex = math.min(BP_Corps_Suggestion_CurSelectedIndex, #BP_ARRAY_Corps_InvitedCorpsList-1);

        LuaClassObj.HandleUIMessageNoFetch(bp_corps_suggestion, "UpdateInvitedCorpsList");

        local afterSetGenderCallback = function()
            if BP_Corps_Suggestion_CurSelectedIndex >= 0 then
                CorpsSuggestionUI.UpdateSelectedInvitedCorps();
            end
            LuaClassObj.HandleUIMessageNoFetch(bp_corps_suggestion, "UpdateInvitedCorpsList");
        end

        CorpsSuggestionSystem.UpdateListGender(CorpsSuggestionSystem.InvitedCorpsArray, afterSetGenderCallback);
    end
end

function CorpsSuggestionUI.UpdateSelectedInvitedCorps()
    CorpsSuggestionSystem.GetSelectedHeadIcons();
    local info = BP_ARRAY_Corps_InvitedCorpsList[BP_Corps_Suggestion_CurSelectedIndex + 1];
    if info == nil then
        return
    end
    info.invite_status = 1;

    local idx, data = CorpsSuggestionSystem.GetInvitedCorpsKvpByID(info.corps_id_str);
    if data ~= nil then
        BP_STRUCT_CORPS_Suggestion_DetailPanelData.BP_STRUCT_CorpsSnapInfo = data;
        if idx > 0 then
            CorpsSuggestionSystem.change_invitee_status_req(idx);
        end
    end

    -- log_tree("CorpsSuggestionUI.UpdateSelectedInvitedCorps data", data)
    -- log_tree("CorpsSuggestionUI.UpdateSelectedInvitedCorps info", info)
    log("CorpsSuggestionUI.UpdateSelectedInvitedCorps BP_Corps_Suggestion_CurSelectedIndex "..BP_Corps_Suggestion_CurSelectedIndex);
end

function EventCorpsSuggestionClickAccept()
    local info = BP_ARRAY_Corps_InvitedCorpsList[BP_Corps_Suggestion_CurSelectedIndex + 1];
    CorpsMemberSystem.corps_accept_invite_req(info.corps_id_str, CorpsMemberSystem.accept_yes);

end

function EventCorpsSuggestionClickIgnor()
    local info = BP_ARRAY_Corps_InvitedCorpsList[BP_Corps_Suggestion_CurSelectedIndex + 1];
    CorpsMemberSystem.corps_accept_invite_req(info.corps_id_str, CorpsMemberSystem.accept_no);
end

-- 一键申请
function EventCorpsSuggestionClickOneKeyApply()
    CommonMessageBoxUI:ShowPanel(2, Client.GetTableData("LocalizeRes", "101001").TextValue, 
        Client.GetTableData("LocalizeRes", "410078").TextValue, 
            function()
                CorpsSuggestionSystem.easy_apply_join_corps_req();
            end);
end

function CorpsSuggestionUI.OnNoJoin(type, eid, args)
    if not CorpsSuggestionUI.isShowing then
        return;
    end

    if BP_Corps_Suggestion_Toggle ~= 3 then
        return;
    end

    log("CorpsSuggestionUI.OnNoJoin")
    CorpsSuggestionUI.UpdateInvitedCorpsSummaryList()
end