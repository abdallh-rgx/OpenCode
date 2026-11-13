CorpsOwnHomePageUI = CorpsOwnHomePageUI or {
    canRemind = true,
    isOnlyShow = true,
}

BP_CorpsHasGroup = false
BP_CorpsIsCommander = false
BP_CorpsIsSecCommander = false
BP_CorpsInGroup = false
BP_CorpsHomePageIsWX = false
BP_CorpsHomePage_TrainRedPoint = false
BP_CorpsHomePageAnnouncement = ""
BP_CorpsMemberNum = 0
BP_CorpsHomepageShowAnimation = true
BP_STRUCT_CorpsHomePageActiveHelpPos = { x = 0, y = 0 }

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

BP_STRUCT_SelfMemberInfo = {
    id = 0,
    position = 1,
    online_state = 1,
    svr = 0,
    day_active = 0,
    week_active = 0,
    season_active = 0,
    BP_STRUCT_BASE_INFO = BP_STRUCT_BASE_INFO,
}

BP_STRUCT_HomePageCorpsInfo = {
	city = "",
	icon = 0,
	exp = 0,
	level = 1,
	name = "",
    icon_text = "",
    icon_text_colour = 0,
}
BP_CorpsSelfRankByWeekActive = 1
BP_CorpsHomePageCorpsMoney = 0
BP_CorpsHomePage_SkipGroup = true
BP_CorpsHomePage_NeedRemindInvite = false
CorpsGroupShow = false
local isShow = false

function bp_corps_own_homepage_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_corps_own_homepage,
		{{Path="/Game/UMG/UI_Logic/Corps/CorpsOwnHomePage.CorpsOwnHomePage_C", Container="Default", ZOrder=BP_ENUM_UI_CORPS_HOMEPAGE_ZORDER}},
		{"Lobby"},
		false,
		false,
		false
	);
	CorpsBaseUI.RegisterCallBacks(CorpsBaseUI.PageMain, CorpsOwnHomePageUI.ShowUI, CorpsOwnHomePageUI.CloseUI)
	EventSystem:registEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_INFO, CorpsOwnHomePageUI.UpdateInfo)
	EventSystem:registEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_GROUPSTATE, CorpsOwnHomePageUI.UpdateGroupState)
	EventSystem:registEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_NOTICE, CorpsOwnHomePageUI.UpdateNotice)
    EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_CORPS_ACTIVENESS_CHANGE, CorpsOwnHomePageUI.UpdateInfo)
	EventSystem:registEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_MEMBERINFO, CorpsOwnHomePageUI.UpdateInfo)
    EventSystem:registEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_ICON, CorpsOwnHomePageUI.UpdateIcon)
    EventSystem:registEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_CITY, CorpsOwnHomePageUI.UpdateLocation)
    EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_CORPS_MONEY_CHANGE, CorpsOwnHomePageUI.UpdateInfo)
end

local function GetSelfRank()
    local rank = 1
    local selfActive = DataMgr.corpsInfo.selfMember.week_active
    local selfActiveTime = DataMgr.corpsInfo.selfMember.active_time or 0
    local selfId = DataMgr.corpsInfo.selfMember.id
    for _, memberInfo in ipairs(DataMgr.corpsInfo.corpsMemberList) do
        if memberInfo.week_active > selfActive then
            rank = rank + 1
        elseif memberInfo.week_active == selfActive then
            memberInfo.active_time = memberInfo.active_time or 0
            if memberInfo.active_time < selfActiveTime then
                rank = rank + 1
            elseif memberInfo.active_time == selfActiveTime then
                if memberInfo.id > selfId then
                    rank = rank + 1
                end
            end
        end
    end
    return rank
end

local function GetRemindInviteStatus()
    local roleId = tonumber(DataMgr.roleData.uid)
    local memberNum = #DataMgr.corpsInfo.corpsMemberList
    local isCmdr = roleId == DataMgr.corpsInfo.commanderId
    local isScmdr = DataMgr.corpsInfo.secCommanderList[roleId]
    if isCmdr or isScmdr then
        local cmdrMemberFlag = false
        local curTime = FuncUtil.GetServerTimeInSec()
        local key = string.format("%d_%s", DataMgr.corpsInfo.id, CorpsMgr.remindInviteTimeStr)
        local lastSaveTime = GlobalData.GetGlobalConfigIntValue(key)
        local timeFlag = false
        if curTime - lastSaveTime > CorpsMgr.GetConfigToNumber(CorpsMgr.remindInviteTimeGapStr) then
            timeFlag = true
        end

        local cmdrRemindNumLimit = CorpsMgr.GetConfigToNumber(CorpsMgr.cmdrRemindNumLimitStr)
        if memberNum < cmdrRemindNumLimit then
            cmdrMemberFlag = true
        end
        local emptyFlag = memberNum == 1
        return emptyFlag or ( cmdrMemberFlag and timeFlag )
    else
        local memberFlag = false
        local remindNumLimit = CorpsMgr.GetConfigToNumber(CorpsMgr.remindNumLimitStr)
        local levelInfo = Client.GetTableData("CorpsLevel", DataMgr.corpsInfo.level) or {}
        local maxNum = levelInfo.MemberLimit or 50
        if memberNum < remindNumLimit * maxNum then
            memberFlag = true
        end

        local key = string.format("%d_%s", DataMgr.corpsInfo.id, CorpsMgr.memberInvitedMarkStr)
        local invitedFlag = GlobalData.GetGlobalConfigBooleanValue(key)
        return memberFlag and not invitedFlag
    end
end

function CorpsOwnHomePageUI.ResetCorpsGroupState()
    BP_CorpsHasGroup = false
    BP_CorpsInGroup = false
end

function CorpsOwnHomePageUI.ShowUI()
	log("CorpsOwnHomePageShowUI")
	isShow = true

    CorpsOwnHomePageUI.ChangeIsOnlyShow(true)
    
    local openStatus = LobbySystem.LobbyMenuOpenStatus[BP_ENUM_CORPS_UI_GROUP]
    BP_CorpsHomePage_SkipGroup = openStatus == nil or openStatus.is_open ~= 1;
    if CorpsGroupShow then
        BP_CorpsHomePage_SkipGroup = false
    end
    BP_CorpsHomePage_NeedRemindInvite = GetRemindInviteStatus()
	LuaClassObj.HandleDynamicCreation(bp_corps_own_homepage)
	BP_STRUCT_HomePageCorpsInfo = DataMgr.corpsInfo
    BP_CorpsHomePageCorpsMoney = DataMgr.corps_money
    BP_CorpsSelfRankByWeekActive = GetSelfRank()
    local roleId = tonumber(DataMgr.roleData.uid)
    BP_CorpsIsCommander = roleId == DataMgr.corpsInfo.commanderId
    BP_CorpsIsSecCommander = DataMgr.corpsInfo.secCommanderList[roleId]
    BP_CorpsHomePageIsWX = BP_Platform == BP_ENUM_PLAYFORM_WX
    BP_CorpsHomePageAnnouncement = DataMgr.corpsInfo.announcement
    BP_CorpsMemberNum = #DataMgr.corpsInfo.corpsMemberList
	BP_CorpsHomePage_TrainRedPoint = CorpsTrainingSystem.TrainRedPointIsShow;
    BP_STRUCT_SelfMemberInfo = DataMgr.corpsInfo.selfMember
	--LobbyChatEntranceUI.OnRoomModeChanged()
    --LobbyChatEntranceUI.SetVisibilityCorps(false)
    LuaClassObj.HandleUIMessage(bp_chat_entrance, "UIHide");
	LuaClassObj.HandleLobbyUIMessage(bp_corps_own_homepage, "ShowUI")
    UIManager.Show(eUIType.eCorpsOwnHomeUI);
    

    local openPlatformInviteBtn = LobbySystem.LobbyMenuOpenStatus[BP_ENUM_CORPS_UI_PLATFORMINVITE]
    if openPlatformInviteBtn == nil or openPlatformInviteBtn.is_open ~= 1 then
        LuaClassObj.HandleLobbyUIMessage(bp_corps_own_homepage, "HidePlatformInviteButtons")
    else
        LuaClassObj.HandleLobbyUIMessage(bp_corps_own_homepage, "ShowPlatformInviteButtons")
    end

    BP_CorpsHomepageShowAnimation = false
    --CorpsMgr.get_corps_group_relation_req()    

    if BP_CorpsIsCommander or BP_CorpsIsSecCommander then   -- 军团长和副军团长才能发送一键邀请
        local memberNum = DataMgr.corpsInfo.memberNum;
        local minCorps = tonumber(Client.GetTableData("CorpsConfig", "MinCorpsAutoInvite").ConfigValue);
        if memberNum <= minCorps then                       -- 军团人数少于配置值时(例如15)才发送一键邀请
            local param = DataMgr.corpsInfo.lastAutoInviteTime or 0;       
            cd = tonumber(Client.GetTableData("CorpsConfig", "CorpsAutoInviteCD").ConfigValue);
            leftDay = math.ceil((cd - (FuncUtil.GetServerTimeInSec() - param)) / 86400);   

            log("corps auto invite : " ..tostring(param).."  "..tostring(cd).."  "..tostring(leftDay));
            if leftDay <= 0 then    
                CorpsMgr.get_auto_invite_list_req()
            end
        end        
    end

    ClientSendBAReport(BP_BA_CORPS_HOMEPAGE, 0)
end

function CorpsOwnHomePageUI.CloseUI()
	log("CorpsOwnHomePageCloseUI")
	isShow = false
	--LobbyChatEntranceUI.SetVisibilityCorps(false)
    UIManager.Hide(eUIType.eCorpsOwnHomeUI);
	LuaClassObj.HandleLobbyUIMessage(bp_corps_own_homepage, "CloseUI")
end

function CorpsOwnHomePageUI.UpdateGroupState(_, _, groupInfo)
    BP_CorpsHasGroup = groupInfo.hasGroup
    BP_CorpsInGroup = groupInfo.inGroup
	LuaClassObj.HandleLobbyUIMessage(bp_corps_own_homepage, "UpdateGroupState")
end

function CorpsOwnHomePageUI.UpdateNotice(_, _, notice)
    BP_CorpsHomePageAnnouncement = notice
    LuaClassObj.HandleLobbyUIMessage(bp_corps_own_homepage, "UpdateNotice")
end

function CorpsOwnHomePageUI.UpdateIcon()
    LuaClassObj.HandleLobbyUIMessage(bp_corps_own_homepage, "UpdateIcon")
end

function CorpsOwnHomePageUI.UpdateLocation()
    LuaClassObj.HandleLobbyUIMessage(bp_corps_own_homepage, "UpdateLocation")
end

--DataMgr.corpsInfo.selfMember中的头像和相框数据有误，需要刷新
function CorpsOwnHomePageUI.RefreshIconAndIconBox()
    if DataMgr.corpsInfo.selfMember.BP_STRUCT_BASE_INFO then
        DataMgr.corpsInfo.selfMember.BP_STRUCT_BASE_INFO.IconFrameID = DataMgr.roleData.cur_avatar_box_id
        DataMgr.corpsInfo.selfMember.BP_STRUCT_BASE_INFO.IconUrl = DataMgr.roleData.headIconUrl
    end
end

function CorpsOwnHomePageUI.UpdateInfo()
	if isShow then
        BP_STRUCT_HomePageCorpsInfo = DataMgr.corpsInfo
        BP_CorpsMemberNum = #DataMgr.corpsInfo.corpsMemberList

        CorpsOwnHomePageUI.RefreshIconAndIconBox()

        BP_STRUCT_SelfMemberInfo = DataMgr.corpsInfo.selfMember
		LuaClassObj.HandleLobbyUIMessage(bp_corps_own_homepage, "UpdateInfo")
	end
end

function CorpsOwnHomePageUI.UpdateTrainRedPoint()
	BP_CorpsHomePage_TrainRedPoint = CorpsTrainingSystem.TrainRedPointIsShow;
	LuaClassObj.HandleLobbyUIMessage(bp_corps_own_homepage, "UpdateTrainRedPoint");
end

function EventShowInviteUI()
    if BP_CorpsIsCommander or BP_CorpsIsSecCommander then
        local cmdrInviteKey = string.format("%d_%s", DataMgr.corpsInfo.id, CorpsMgr.remindInviteTimeStr)
        GlobalData.SetGlobalConfigIntValue(cmdrInviteKey, FuncUtil.GetServerTimeInSec())
    end
    local mbrInviteKey = string.format("%d_%s", DataMgr.corpsInfo.id, CorpsMgr.memberInvitedMarkStr)
    GlobalData.SetGlobalConfigBooleanValue(mbrInviteKey, true)
	AllianceRecruitUI.ShowUIRecruit(2);
    BP_CorpsHomePage_NeedRemindInvite = GetRemindInviteStatus()
    LuaClassObj.HandleLobbyUIMessage(bp_corps_own_homepage, "UpdateInviteTips")
end

function EventClickCorpsTrain()
	CorpsTrainingSystem.OpenTrainingUI();
end

function EventClickCorpsExercise()
end

function EventClickCorpsHelp()
    log("function EventClickCorpsHelp()")
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
end

function EventNoticeChange_Push()
    if BP_CorpsHomePageAnnouncement == DataMgr.corpsInfo.announcement then
        return
    end
	CorpsMgr.corps_change_announcement_req(BP_CorpsHomePageAnnouncement)
end

-- 自己军团举报
function EventCorpsSelfTeamReport()
    
    CommonMessageBoxUI:ShowPanel(2, DataMgr.GetMsgByID(101001), DataMgr.GetMsgByID(411043), 
        function ()
            local commander = CorpsMemberSystem.FindMemberByID(DataMgr.corpsInfo.commanderId);
            CorpsMgr.SendReportInfo(commander.name or "", DataMgr.corpsInfo.id, DataMgr.corpsInfo.name, DataMgr.corpsInfo.announcement)
            
            --DataMgr.ShowNoticeByID(117066);
        end
    );

end

function EventCorpsActiveHelp()
    local str = DataMgr.GetMsgByID(410070)
    local limit = CorpsMgr.GetCorpsConfig("Active_Day_Limit")
    log(str .. limit .. tostring(DataMgr.corpsInfo.selfMember.day_active))
    str = string.format(str, tostring(DataMgr.corpsInfo.selfMember.day_active), limit)
    str = string.gsub(str, "\\n", "\n")
    CommonHelpTipsUI:ShowPanelStr(str, BP_STRUCT_CorpsHomePageActiveHelpPos)
end

function EventCorpsHomepageChangeIcon()
    BP_CorpsIconCurUseId = DataMgr.corpsInfo.icon
    BP_CorpsCurIconText = DataMgr.corpsInfo.icon_text
    BP_CorpsCurIconColourId = DataMgr.corpsInfo.icon_text_colour
    BP_STRUCT_HomePageCorpsInfo.icon = DataMgr.corpsInfo.icon
    BP_STRUCT_HomePageCorpsInfo.icon_text = DataMgr.corpsInfo.icon_text
    BP_STRUCT_HomePageCorpsInfo.icon_text_colour = DataMgr.corpsInfo.icon_text_colour
    CorpsIconSelectUI.ShowUI(CorpsIconSelectUI.openFromType_CorpsHomepage)
end

function EventCorpsHomepageChangeLocation()
    CorpsLocationEditorUI.ShowUI()
end

-- 一键建群 start
function EventCorpsGroupWXCreate()
    log("==================EventCorpsGroupWXCreate")
    CorpsMgr.bind_corps_group_req(DataMgr.corpsInfo.id)
end

function EventCorpsGroupWXDismiss()
    log("==================EventCorpsGroupWXDismiss")
    CommonMessageBoxUI:ShowPanel(2, "提示", DataMgr.GetMsgByID(410066), 
        function ()
            CorpsMgr.unbind_corps_group_req()
        end
    );
end

function EventCorpsGroupWXJoin()
    log("==================EventCorpsGroupWXJoin")
    CorpsMgr.join_corps_group_req()
end

function EventCorpsGroupWXRemind()
    log("==================EventCorpsGroupWXRemind")
    if CorpsOwnHomePageUI.canRemind then
        CorpsOwnHomePageUI.RemindColdDown()
        LobbyChatSystem.on_chat_req(0, 8, DataMgr.GetMsgByID(410067))
        LobbyChatLogic.OpenCorpsTab()
    else
        local offset = Timer.GetDistance(CorpsOwnHomePageUI.remindTime)
        local formatStr = Client.GetTableData("LocalizeRes", 100007).TextValue
        local msgContent = string.format(formatStr, tostring(math.ceil(offset)));
        PopUpNoticeUI.ShowNewNotice(msgContent)
    end
    ClientSendBAReport(BP_BA_CORPS_REMIND_GROUP, 0)
end

function EventCorpsGroupQQCreate()
    log("==================EventCorpsGroupQQCreate")
    CorpsMgr.bind_corps_group_req(DataMgr.corpsInfo.id)
end

function EventCorpsGroupQQDismiss()
    log("==================EventCorpsGroupQQDismiss")
    CommonMessageBoxUI:ShowPanel(2, "提示", DataMgr.GetMsgByID(410066), 
        function ()
            CorpsMgr.unbind_corps_group_req()
        end
    );
end

function EventCorpsGroupQQJoin()
    log("==================EventCorpsGroupQQJoin")
    CorpsMgr.join_corps_group_req()
end

function CorpsOwnHomePageUI.RemindColdDown()
    CorpsOwnHomePageUI.canRemind = false
    CorpsOwnHomePageUI.remindTime = Timer.InsertTimer("60", function()
        CorpsOwnHomePageUI.canRemind = true
    end, false)
end

function EventCorpsGroupQQRemind()
    log("==================EventCorpsGroupQQRemind")
    if CorpsOwnHomePageUI.canRemind then
        CorpsOwnHomePageUI.RemindColdDown()
        LobbyChatSystem.on_chat_req(0, 8, DataMgr.GetMsgByID(410067))
        LobbyChatLogic.OpenCorpsTab()
    else
        local offset = Timer.GetDistance(CorpsOwnHomePageUI.remindTime)
        local formatStr = Client.GetTableData("LocalizeRes", 100007).TextValue
        local msgContent = string.format(formatStr, tostring(math.ceil(offset)));
        PopUpNoticeUI.ShowNewNotice(msgContent)
    end
    ClientSendBAReport(BP_BA_CORPS_REMIND_GROUP, 0)
end
-- 一键建群 end

local SHOWED_TIPS_KEY_PRE = "ShowedJoinGroupTips"

function EventCorpsHomepageShowJoinGroupTips()
    local key = SHOWED_TIPS_KEY_PRE ..  DataMgr.corpsInfo.id
    log( "~~~~~~~~~~~~" .. key)
    -- GlobalData.SetGlobalConfigBooleanValue(key, false)
    local hasShowed = GlobalData.GetGlobalConfigBooleanValue(key)
    if not hasShowed then 
        local content = BP_CorpsHomePageIsWX and FuncUtil.GetLocalizeResStr(422002) or FuncUtil.GetLocalizeResStr(422003)
        CommonMessageBoxUI:ShowPanel(2,FuncUtil.GetLocalizeResStr(101001), content, CorpsOwnHomePageUI.OnSowJoinGroupTipsClickedOK, nil);   
        GlobalData.SetGlobalConfigBooleanValue(key, true)
    end
end

function CorpsOwnHomePageUI.OnSowJoinGroupTipsClickedOK()
    if BP_CorpsHomePageIsWX then
        EventCorpsGroupWXJoin()
    else
        EventCorpsGroupQQJoin()
    end
end

function EventCorpsOwnHomePagePlatformInviteBtnClicked()
    log("EventCorpsOwnHomePagePlatformInviteBtnClicked");
    local shareData = ShareDataList[MEDIA_TAG_SHARE_INVITE_JOINCORPS];

    local gamedata = {
        corps_id = DataMgr.corpsInfo.id;
    }
    
    local str = json.encode(gamedata);
    local encodedstr = FuncUtil:EncodeURI(str);
    local titleTableIds = {410080, 410081};
    local descTableIds = {410082, 410083, 410084, 410085, 410086, 410087};
    log(titleTableIds[math.random(1,#titleTableIds)])
    local title = Client.GetTableData("LocalizeRes",  titleTableIds[math.random(1,#titleTableIds)]).TextValue;
    log("title:" .. title)
    local desc = string.format(Client.GetTableData("LocalizeRes", descTableIds[math.random(1,#descTableIds)]).TextValue, DataMgr.corpsInfo.name);
    log("desc:" .. desc)
    if _G.BP_Platform == BP_ENUM_PLAYFORM_WX then
        ShareMgr:shareWechat(MEDIA_TAG_SHARE_INVITE_JOINCORPS, desc, encodedstr, title);
    elseif _G.BP_Platform == BP_ENUM_PLAYFORM_QQ then
        local url = ShareMgr:constructQQGameCenterURL(encodedstr, GameCenterADTAG.invite);
        log("url:" .. url)
        ShareMgr:shareQQ(MEDIA_TAG_SHARE_INVITE_JOINCORPS, desc, shareData.iShareType, title, url);
    end
end

function CorpsOwnHomePageUI.ChangeIsOnlyShow(isOnlyShow)
    log("CorpsOwnHomePageUI.ChangeIsOnlyShow:" .. tostring(isOnlyShow))
    CorpsOwnHomePageUI.isOnlyShow = isOnlyShow
    if CorpsOwnHomePageUI.isOnlyShow then
        LuaClassObj.HandleUIMessageNoFetch(bp_corps_own_homepage, "UIOnlyShow");
    else
        LuaClassObj.HandleUIMessageNoFetch(bp_corps_own_homepage, "UIOnlyHide");
    end
end

function CorpsOwnHomePageUI.GetStatus()
    return {isOnlyShow = CorpsOwnHomePageUI.isOnlyShow}
end

function CorpsOwnHomePageUI.RecoverStatus(status)
    if status and status.isOnlyShow ~= nil then
        CorpsOwnHomePageUI.ChangeIsOnlyShow(status.isOnlyShow)
    end
end