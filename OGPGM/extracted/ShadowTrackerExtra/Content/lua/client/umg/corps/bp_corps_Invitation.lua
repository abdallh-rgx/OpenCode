CorpsInvitationUI = CorpsInvitationUI or
{
    isShow = false;
    leader = 0;

    isShowJoin = 1;
    isShowApply = 2;
    isNoButton = 3;
    showCorpsID = 0;
};

function bp_corps_Invitation_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_corps_Invitation,
        {{Path = "/Game/UMG/UI_Logic/Corps/CorpsInvitation_BP.CorpsInvitation_BP_c", Container = "Default", ZOrder = BP_ENUM_UI_CORPS_Invitation}},
        {"Lobby"},
        false,
        false,
        true);

    EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_CORPS_INVITE, CorpsInvitationUI.JumpUrl)
end

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

BP_STRUCT_CorpsSummary_Data =
{
    str_corps_id = "",
    level = 0,
    name = "",
    activeness = 0,
    city = "",
    icon = 0,
    join_level = 0,
    join_segment = 0,
    member_num = 0,
    member_max = 0,
    announcement = "",
    icon_text = "",
    icon_text_colour = 0,
}

BP_STRUCT_CorpsInvitation_AvatarData = {BP_STRUCT_BASE_INFO = _G.BP_STRUCT_BASE_INFO};

BP_CorpsInvitation_ShowType = 1;

-- opt
-- ├─ go_link: "game://?module=1002100"
-- ├─ sys_id: "2"
-- ├─ type: 3
-- ├─ corps_name: ""
-- ├─ invite_name: "梦呓者哈里顿73"
-- ├─ can_invalid: 0
-- ├─ button_style: "1"
-- ├─ item_style: "1"
-- ├─ corps_id: 100013
-- ├─ msg_type: 16
-- └─ invite_uid: 410000699
function CorpsInvitationUI.JumpUrl(type, id, params)
    local fromMail = params["fromMail"] == "1"
    if fromMail then
        if Mail_Select_ID == nil or Mail_Select_ID == 0 then
            return
        end

        local mailid = math.tointeger(Mail_Select_ID);
        local mailInfo = MailSystem.MailInfoList[mailid];
        if mailInfo ~= nil and mailInfo.corps_id ~= nil then
            CorpsInvitationUI.RequestShowUI(mailInfo.corps_id, CorpsInvitationUI.isShowJoin)
        end
    end
end

function CorpsInvitationUI.RequestShowUI(corps_id, showType, req_type)
    CorpsInvitationUI.showCorpsID = corps_id;
    BP_CorpsInvitation_ShowType = showType;
    CorpsMgr.get_corps_summary_req(corps_id, nil, CorpsInvitationUI.OnGetCorpsSummary, nil, req_type);
end

function CorpsInvitationUI.OnGetCorpsSummary(summary)
    if summary and summary.corps_id == CorpsInvitationUI.showCorpsID then
        CorpsInvitationUI.ShowUI(summary)
    end
end

function CorpsInvitationUI.ShowUI(summary)
    if summary == nil then
        return;
    end
    -- log_tree("CorpsInvitationUI.ShowUI summary", summary)

    LuaClassObj.HandleDynamicCreation(bp_corps_Invitation);

    CorpsInvitationUI.isShow = true;
    -- 初始化数据
    CorpsMgr.SummaryToPanelData(summary, BP_STRUCT_CorpsSummary_Data);
    -- log_tree("CorpsInvitationUI.ShowUI summary", summary);
    -- log_tree("CorpsInvitationUI.ShowUI BP_STRUCT_CorpsSummary_Data", BP_STRUCT_CorpsSummary_Data);

    LuaClassObj.HandleUIMessage(bp_corps_Invitation, "ShowUI");
    UIManager.Show(eUIType.eCorpsInvitationUI)
    CorpsInvitationUI.leader = summary.leader;
    CorpsMgr.GetAvatarBaseInfo({summary.leader}, CorpsInvitationUI.OnGetPicUrl, false)

    EventSystem:registEvent(EVENTTYPE_CORPS, EVENTID_CORPS_JOINED, CorpsInvitationUI.HideUI)
end

function CorpsInvitationUI.OnGetPicUrl(avatarInfoMap)
    if not CorpsInvitationUI.isShow then
        return;
    end

    BP_STRUCT_CorpsInvitation_AvatarData.BP_STRUCT_BASE_INFO = avatarInfoMap[CorpsInvitationUI.leader] or BP_STRUCT_CorpsInvitation_AvatarData.BP_STRUCT_BASE_INFO;
    LuaClassObj.HandleUIMessage(bp_corps_Invitation, "UpdateAvatar");
end

function CorpsInvitationUI.HideUI()
    log("CorpsInvitationUI.HideUI")

    CorpsInvitationUI.isShow = false;
    if _isInLobby then
        UIManager.Hide(eUIType.eCorpsInvitationUI)
        LuaClassObj.HandleUIMessage(bp_corps_Invitation, "HideUI")
    end

    EventSystem:unregistEvent(EVENTTYPE_CORPS, EVENTID_CORPS_JOINED, CorpsInvitationUI.HideUI)
end

function EventCorpsInvitationUIClose()
    CorpsInvitationUI.HideUI()
end

function EventCorpsInvitationUIConfirm()
    local corps_id = tonumber(BP_STRUCT_CorpsSummary_Data.str_corps_id);
    CorpsMemberSystem.corps_accept_invite_req(corps_id, CorpsMemberSystem.accept_yes);
end

function EventCorpsInvitationApply()
    local corps_id = tonumber(BP_STRUCT_CorpsSummary_Data.str_corps_id);
    CorpsMemberSystem.SendApplyJoinCorps(corps_id);
end

function EventCorpsInvitationReport()
    CommonMessageBoxUI:ShowPanel(2, DataMgr.GetMsgByID(101001), DataMgr.GetMsgByID(411043), 
        function ()
            local commander = CorpsMemberSystem.FindMemberByID(DataMgr.corpsInfo.commanderId);
            CorpsMgr.SendReportInfo(commander.name, BP_STRUCT_CorpsSummary_Data.str_corps_id, BP_STRUCT_CorpsSummary_Data.name, BP_STRUCT_CorpsSummary_Data.announcement)
            --DataMgr.ShowNoticeByID(117066);
        end
    );
end