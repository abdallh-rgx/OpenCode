CorpsOwnInfoUI = CorpsOwnInfoUI or {
    canRecruit = true,
    recruitTime = nil,
    isOnlyShow = true,
}

BP_STRUCT_BASE_INFO = {
    strUid = "",
    Name = "",
    Level = 1,
    Sex = 1,
    RankIntegralLevel = 1,
    IconUrl = "",
    IconFrameID  = 1,
    lastOnlineTimeStr = "",

    -- 绝地通行证
    upass_is_buy = 0, --是否购买(1为已购买，0为未购买)
    upass_is_show = 0, --是否显示(1为显示，0为不显示)
    --国籍
    nation = "",
}
BP_STRUCT_GROUP_INFO = {
    online = 1,
    teamState = 1,
    currentTeamAmount = 1,
    maxTeamAmount = 1,
    timeSinceGameBeginStr = "",
}

BP_STRUCT_InfoMemberInfo = {
    strId = "",
    position = 1,
    online_state = 1,
    svr = 0,
    day_active = 0,
    week_active = 0,
    season_active = 0,
    BP_STRUCT_BASE_INFO = BP_STRUCT_BASE_INFO,
    BP_STRUCT_GROUP_INFO = BP_STRUCT_GROUP_INFO,
}

BP_CorpsInfoMemberNum = 0
CorpsInfoMemberList = {
    BP_STRUCT_InfoMemberInfo = BP_STRUCT_InfoMemberInfo
}
BP_ARRAY_PartMemberList = {
    BP_STRUCT_InfoMemberInfo = BP_STRUCT_InfoMemberInfo
}

BP_STRUCT_InfoCorpsInfo = {
    icon = 0,
    level = 1,
    name = "",

    week_active = 0,
    season_active = 0,
    icon_text = "",
    icon_text_colour = 0,
}

BP_STRUCT_LogInfo = {
    msg = "",
    icon = "",
    date = "",
    time = "",
    level = 0,
    iconFrameID = 0,
}

BP_ARRAY_LogInfos = {
    BP_STRUCT_LogInfo = BP_STRUCT_LogInfo
}

BP_STRUCT_CorpsInfoRankInfo = {
    week_rank = "",
    week_award_id = 0,
    week_award_num = 0,
    season_award_id = 0,
    season_award_num = 0,
    season_rank = "",
}
BP_InviteRedDot = false

BP_SelfRoleId = "0"
BP_IsCommander = false
BP_CorpsOwn_SkipRecruit = false;
BP_OperateMemberId = ""
BP_STRUCT_ShowOp = {
    isMe = false,
    isFriend = true,
    isCommander = true,
    isSecCommander = true,
    otherCommander = true,
    otherSecCommander = true,
}
BP_STRUCT_CorpsInfoActiveHelpPos = { x = 0, y = 0 }
BP_CorpsInfo_SeasonTimeStr = "--"
BP_CorpsInfoMemberInfo_PageStart = 0
BP_CorpsInfoMemberInfo_PageEnd = 0

function bp_corps_own_info_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_corps_own_info,
                                {{Path="/Game/UMG/UI_Logic/Corps/CorpsOwnInfo.CorpsOwnInfo_C", Container="Default", ZOrder=BP_ENUM_UI_CORPS_INFO_ZORDER}},
                                {"Lobby"},
                                false,
                                false,
                                false
    );
    CorpsBaseUI.RegisterCallBacks(CorpsBaseUI.PageBaseInfo, CorpsOwnInfoUI.ShowUI, CorpsOwnInfoUI.CloseUI)
    EventSystem:registEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_MEMBERINFO, CorpsOwnInfoUI.UpdateMemberList)
    EventSystem:registEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_LOGINFO, CorpsOwnInfoUI.UpdateLogList)
    EventSystem:registEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_APPLYLIST, CorpsOwnInfoUI.UpdateInviteRedDot);
    EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_CORPS_ACTIVENESS_CHANGE, CorpsOwnInfoUI.UpdateInfo)
    EventSystem:registEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_ICON, CorpsOwnInfoUI.UpdateIcon)
end

local function GetCurrentSeason()
    local cfg = Client.GetTableData("SeasonInfo", DataMgr.season_id);
    return cfg;
end

function CorpsOwnInfoUI.InitInfo()
    local openStatus = LobbySystem.LobbyMenuOpenStatus[BP_ENUM_CORPS_UI_RECRUIT]
    if openStatus ~= nil then
        BP_CorpsOwn_SkipRecruit = openStatus.is_open ~= 1;
    else
        BP_CorpsOwn_SkipRecruit = false;
    end

    local cfg = GetCurrentSeason()
    if cfg then
        local temp = string.split(cfg.DisplayTime, "-")
        BP_CorpsInfo_SeasonTimeStr = temp[2] or "--"
    end
    BP_STRUCT_InfoCorpsInfo = DataMgr.corpsInfo
    --log_tree("=================corpsMemberList", BP_STRUCT_InfoCorpsInfo)
    local rankInfo = {}
    local weekRankInfo, seasonRankInfo = CorpsRankSystem.GetMyRankInfo()
    weekRankInfo = weekRankInfo or {rank_no = 0, rank_rate = 10000}
    seasonRankInfo = seasonRankInfo or {rank_no = 0, rank_rate = 10000}
    if weekRankInfo.rank_no == 0 then
        rankInfo.week_rank = string.format("%.1f%%", weekRankInfo.rank_rate / 100)
    else
        rankInfo.week_rank = tostring(weekRankInfo.rank_no)
    end
    if seasonRankInfo.rank_no == 0 then
        rankInfo.season_rank = string.format("%.1f%%", seasonRankInfo.rank_rate / 100)
    else
        rankInfo.season_rank = tostring(seasonRankInfo.rank_no)
    end

    local weekAwardInfo, seasonAwardInfo = CorpsRankSystem.GetMyCorpsAwardInfo()
    if weekAwardInfo ~= nil then
        rankInfo.week_award_id = weekAwardInfo.WeekAwardID
        rankInfo.week_award_num = weekAwardInfo.WeekAwardNum
    end
    if seasonAwardInfo ~= nil then
        if seasonAwardInfo.SeasonAwardNum2 == 0 then
            rankInfo.season_award_id = seasonAwardInfo.SeasonAwardID1
            rankInfo.season_award_num = seasonAwardInfo.SeasonAwardNum1
        else
            rankInfo.season_award_id = seasonAwardInfo.SeasonAwardID2
            rankInfo.season_award_num = seasonAwardInfo.SeasonAwardNum2
        end
    end
    BP_STRUCT_CorpsInfoRankInfo = rankInfo
end

function CorpsOwnInfoUI.ShowUI()
    CorpsOwnInfoUI.InitInfo()
    log("CorpsOwnInfoShowUI")
    local roleId = tonumber(DataMgr.roleData.uid)
    BP_SelfRoleId = DataMgr.roleData.uid
    BP_IsCommander = DataMgr.corpsInfo.commanderId == roleId
    local isSec = DataMgr.corpsInfo.secCommanderList[roleId]
    BP_IsCommander = BP_IsCommander or (isSec or false)
    BP_InviteRedDot = CorpsMemberSystem.HasRedPoint

    LuaClassObj.HandleDynamicCreation(bp_corps_own_info)
    LuaClassObj.HandleLobbyUIMessage(bp_corps_own_info, "ShowUI")
    UIManager.Show(eUIType.eCorpsOwnInfoUI);

    CorpsOwnInfoUI.ChangeIsOnlyShow(true)
end

function CorpsOwnInfoUI.CloseUI()
    log("CorpsOwnInfoCloseUI")
    UIManager.Hide(eUIType.eCorpsOwnInfoUI);
    LuaClassObj.HandleLobbyUIMessage(bp_corps_own_info, "CloseUI")
end

function CorpsOwnInfoUI.UpdateInviteRedDot()
    BP_InviteRedDot = CorpsMemberSystem.HasRedPoint
    -- log("CorpsOwnInfoUI.UpdateInviteRedDot BP_InviteRedDot "..tostring(BP_InviteRedDot))
    LuaClassObj.HandleLobbyUIMessage(bp_corps_own_info, "UpdateInviteRedDot")
end

function CorpsOwnInfoUI.SortMemberList()
    local roleId = tonumber(DataMgr.roleData.uid)
    table.sort(CorpsInfoMemberList, function(a, b)
        local aOrder = a.id == roleId and 1000 or 0
        local bOrder = b.id == roleId and 1000 or 0
        if aOrder == bOrder then
            a.week_active = a.week_active or 0
            b.week_active = b.week_active or 0
            if a.week_active == b.week_active then
                if a.online_state == b.online_state then
                    return a.id > b.id
                else
                    return a.online_state > b.online_state
                end
            else
                return a.week_active > b.week_active
            end
        else
            return aOrder > bOrder
        end
    end)
end

function CorpsOwnInfoUI.SelectPartMember()
    BP_ARRAY_PartMemberList = {}
    for i = BP_CorpsInfoMemberInfo_PageStart, BP_CorpsInfoMemberInfo_PageEnd do
        BP_ARRAY_PartMemberList[i - BP_CorpsInfoMemberInfo_PageStart + 1] = CorpsInfoMemberList[i]
    end
end

function CorpsOwnInfoUI.UpdateMemberList()
    local roleId = tonumber(DataMgr.roleData.uid)
    BP_IsCommander = DataMgr.corpsInfo.commanderId == roleId
    local isSec = DataMgr.corpsInfo.secCommanderList[roleId]
    BP_IsCommander = BP_IsCommander or (isSec or false)
    CorpsInfoMemberList = DataMgr.corpsInfo.corpsMemberList
    BP_CorpsInfoMemberNum = #CorpsInfoMemberList
    CorpsOwnInfoUI.SortMemberList()
    BP_CorpsInfoMemberInfo_PageStart = 1
    BP_CorpsInfoMemberInfo_PageEnd = 10
    CorpsOwnInfoUI.SelectPartMember()
    -- log_tree("CorpsOwnInfoUI.UpdateMemberList", CorpsInfoMemberList)
    LuaClassObj.HandleLobbyUIMessage(bp_corps_own_info, "InitMemberList")
end

function EventGetPartMember()
    log(string.format("BP_CorpsInfoMemberInfo_PageStart : %d  BP_CorpsInfoMemberInfo_PageEnd : %d", BP_CorpsInfoMemberInfo_PageStart, BP_CorpsInfoMemberInfo_PageEnd))
    CorpsOwnInfoUI.SelectPartMember()
end

function CorpsOwnInfoUI.UpdateLogList(_, _, event_list)
    BP_ARRAY_LogInfos = event_list
    -- log_tree("CorpsOwnInfoUI.UpdateLogList", event_list)
    LuaClassObj.HandleLobbyUIMessage(bp_corps_own_info, "InitLogList")
end

function CorpsOwnInfoUI.UpdateInfo()
    log("==================corpsOwnInfoUI.UpdateInfo")
    CorpsOwnInfoUI.InitInfo()
    BP_CorpsFund = DataMgr.corpsInfo.fund
    LuaClassObj.HandleLobbyUIMessage(bp_corps_own_info, "InitCorpsInfo")
    LuaClassObj.HandleLobbyUIMessage(bp_corps_own_info, "InitMemberList")
end

function CorpsOwnInfoUI.UpdateIcon()
    LuaClassObj.HandleLobbyUIMessage(bp_corps_own_info, "UpdateIcon")
end

function EventCorpsLogShow()
    CorpsMgr.get_corps_event_list()
end

function EventCorpsApplyListShow()
    log("EventCorpsApplyListShow")
    CorpsApplyListUILogic.ShowApplyListUI()	
end

function EventCorpsManageShow()
    log("EventCorpsManageShow");
    CorpsManagerUILogic.ShowUI();
end

function EventCorpsOwnExit()
    CorpsMemberSystem.SendExitCorpsReq()
end

function EventCorpsShowMemberOp_Push()
    local roleId = tonumber(DataMgr.roleData.uid)
    local opId = tonumber(BP_OperateMemberId)
    log("=====================" .. type(BP_OperateMemberId) .. " " .. type(roleId))

    BP_STRUCT_ShowOp = {
        isMe = roleId == opId,
        isFriend = FriendSystem.IsMyFriend(opId),
        isCommander = DataMgr.corpsInfo.commanderId == roleId,
        isSecCommander = DataMgr.corpsInfo.secCommanderList[roleId] or false,
        otherCommander = DataMgr.corpsInfo.commanderId == opId,
        otherSecCommander = DataMgr.corpsInfo.secCommanderList[opId] or false,
    }
    -- log_tree("===============", BP_STRUCT_ShowOp)
    LuaClassObj.HandleUIMessage(bp_corps_own_info, "ShowOp")
end

function EventCorpsOpClickPlayerInfo()
    local opId = tonumber(BP_OperateMemberId)

    --如果是个人空间打开的军团,而且个人空间是从upass跳进来的,那么需要关闭处理,不支持跳回
    if BP_Corps_NeedReOpenRoleInfo and RoleInfoUI.openFrom == RoleInfoOpenFromType.Upass then
        EventCorpsClose() --chuankesi

        RoleInfoSystem.Enter(opId)
        RoleInfoUI.Init(true, RoleInfoUI.openFrom, RoleInfoUI.openFromStatus)
    else
        RoleInfoSystem.Enter(opId)
        RoleInfoUI.Init(true, RoleInfoOpenFromType.CorpsOwnInfo)
        LuaClassObj.HandleUIMessageNoFetch(bp_corps_own_info, "HideOp")
    end
end

function EventCorpsOpClickAddFriend()
    local opId = tonumber(BP_OperateMemberId)
    local id = 19
    if DataMgr.roleData.gender == 1 then
        id = 19
    else
        id = 20
    end
    FriendSystem.AddFriend(opId, BP_ENUM_ADD_FRIEND_FROM_CORPS, id);
    LuaClassObj.HandleUIMessageNoFetch(bp_corps_own_info, "HideOp")
end

-- 军团查看信息界面,发起聊天,关闭军团界面
function EventCorpsOpClickChat()
    local opId = tonumber(BP_OperateMemberId)
    LobbyChatSystem.ChatWithFriend(opId)
    EventCorpsClose();
    --LuaClassObj.HandleUIMessageNoFetch(bp_corps_own_info, "HideOp")
end

function EventCorpsOpClickManage()
    local opId = tonumber(BP_OperateMemberId)
    -- log("EventCorpsOpClickManage BP_OperateMemberId "..BP_OperateMemberId)
    -- log_tree("DataMgr.corpsInfo.corpsMemberList", DataMgr.corpsInfo.corpsMemberList)
    for k, memberInfo in ipairs(DataMgr.corpsInfo.corpsMemberList) do
        if memberInfo.id == opId then
            -- 调用军团管理界面
            CorpsAppointUI.ShowUI(memberInfo);
            LuaClassObj.HandleUIMessageNoFetch(bp_corps_own_info, "HideOp")
            return
        end
    end
    LuaClassObj.HandleUIMessageNoFetch(bp_corps_own_info, "HideOp")
end

function EventCorpsOpClickRemove()
    local opId = tonumber(BP_OperateMemberId)
    CommonMessageBoxUI:ShowPanel(2, FuncUtil.GetLocalizeResStr("101001"), FuncUtil.GetLocalizeResStr("410015"),
                                 function()
                                     CorpsMemberSystem.SendKickMember(opId)
    end);
    LuaClassObj.HandleUIMessageNoFetch(bp_corps_own_info, "HideOp")
end

function EventCorpsClickInfoHelp()
    log("function EventCorpsClickInfoHelp()")
    local title = Client.GetTableData("LocalizeRes", 410061).TextValue
    local context = Client.GetTableData("LocalizeRes", 410062).TextValue
    context = string.gsub(context, "\\n", "\n")
    PopUpNoticeUI.ShowMessageBox(title, context)
end

function CorpsOwnInfoUI.RecruitColdDown()
    CorpsOwnInfoUI.canRecruit = false
    CorpsOwnInfoUI.recruitTime = Timer.InsertTimer("60", function()
        CorpsOwnInfoUI.canRecruit = true
    end, false)
end

function EventCorpsOpClickRecruit()
    -- 军团设置不接受申请时，不能招募
    if DataMgr.corpsInfo.isAcceptApply == false then
        ShowNotice(410077)
        return
    end
    local levelInfo = Client.GetTableData("CorpsLevel", DataMgr.corpsInfo.level)
    if levelInfo and levelInfo.MemberLimit == #DataMgr.corpsInfo.corpsMemberList then
        ShowNotice(421018)
        return
    end

    if CorpsOwnInfoUI.canRecruit then
        CorpsOwnInfoUI.RecruitColdDown()
        LobbyChatSystem.on_chat_corps_recruit();
    else
        local offset = Timer.GetDistance(CorpsOwnInfoUI.recruitTime)
        local formatStr = Client.GetTableData("LocalizeRes", 100007).TextValue
        local msgContent = string.format(formatStr, tostring(math.ceil(offset)));
        PopUpNoticeUI.ShowNewNotice(msgContent)
    end
end

function EventCorpsClickActiveHelp()
    local str = DataMgr.GetMsgByID(410071)
    local limit = CorpsMgr.GetCorpsConfig("Corp_Active_Day_Limit")
    log(str .. limit .. tostring(DataMgr.corpsInfo.day_active))
    str = string.format(str, tostring(DataMgr.corpsInfo.day_active), limit)
    str = string.gsub(str, "\\n", "\n")
    CommonHelpTipsUI:ShowPanelStr(str, BP_STRUCT_CorpsInfoActiveHelpPos)
end

function CorpsOwnInfoUI.ChangeIsOnlyShow(isOnlyShow)
    log("CorpsOwnInfoUI.ChangeIsOnlyShow:" .. tostring(isOnlyShow))
    CorpsOwnInfoUI.isOnlyShow = isOnlyShow
    if CorpsOwnInfoUI.isOnlyShow then
        LuaClassObj.HandleUIMessageNoFetch(bp_corps_own_info, "UIOnlyShow");
    else
        LuaClassObj.HandleUIMessageNoFetch(bp_corps_own_info, "UIOnlyHide");
    end
end

function CorpsOwnInfoUI.GetStatus()
    log("CorpsOwnInfoUI.GetStatus:" .. tostring(CorpsOwnInfoUI.isOnlyShow))
    return {isOnlyShow = CorpsOwnInfoUI.isOnlyShow}
end

function CorpsOwnInfoUI.RecoverStatus(status)
    if status and status.isOnlyShow ~= nil then
        log("CorpsOwnInfoUI.RecoverStatus:" .. tostring(status.isOnlyShow))
        CorpsOwnInfoUI.ChangeIsOnlyShow(status.isOnlyShow)
    end

end