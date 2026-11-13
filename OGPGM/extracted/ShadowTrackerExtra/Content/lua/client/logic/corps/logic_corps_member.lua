CorpsMemberSystem = CorpsMemberSystem or
{
    -- ApplyListItem =
    -- {
    --     uid = 0,
    --     name = "abc",
    --     level = 1
    --     recomm_name="recomm_name",
    --     status=1,
    -- },

    ApplyStatus =
    {
        no_op = 0,      -- 无需操作
        approval = 1,   -- 邀请加入需要批准
        accept = 2,     -- 邀请加入需要好友同意
        refuse = 3      -- 邀请加入拒绝
    },

    HasRedPoint = false,
    ApplyList = {},
    InvitedList = {},

    accept_yes = 1,
    accept_no = 2,

    isInit = false,
    waitForMemberList = false,
    invitedRemainNum = 0,
};

local MemberPosition = {
    ["Commander"] = 1,
    ["SecCommander"] = 2,
    ["Elite"] = 3,
    ["Member"] = 11,
}
    
function CorpsMemberSystem.OnStatusChanged(packet)
    log_tree("CorpsMemberSystem OnStatusChanged",packet,"StatusManager")

    if packet.key ~= StatusManager.KEY_CORPS_PANEL 
    and packet.key ~= StatusManager.KEY_SERVER_NOTIFY 
    then 
		return 
    end

    for _,memberInfo in ipairs(DataMgr.corpsInfo.corpsMemberList) do
        local groupInfo = {}
        local status = StatusManager.getInstance():getStatus(memberInfo.id)
        log_tree("CorpsMemberSystem.OnStatusChanged status", status, "corps")
        if status ~= nil then
            if tostring(memberInfo.id) == tostring(DataMgr.roleData.uid) then -- 玩家自己永远在线
                groupInfo.online = 1;
            else
                groupInfo.online = status.online
            end
            groupInfo.teamState = status.teamState
            groupInfo.currentTeamAmount = status.currentTeamAmount
            groupInfo.maxTeamAmount = status.maxTeamAmount

            local diff = os.time() - status.timeSinceGameBeginStamp
            groupInfo.timeSinceGameBeginStr = FuncUtil.FormatTime2(diff)
            -- if status.timeSinceGameBegin <= 0 then
            --     groupInfo.timeSinceGameBeginStr = "";
            --     status.timeSinceGameBegin = 0
            --     status.timeSinceGameBeginStamp = os.time() - status.timeSinceGameBegin
            --     groupInfo.timeSinceGameBeginStr = FuncUtil.FormatTime2(status.timeSinceGameBegin)
            -- else
            --     status.timeSinceGameBeginStamp = os.time() - status.timeSinceGameBegin
            --     groupInfo.timeSinceGameBeginStr = FuncUtil.FormatTime2(status.timeSinceGameBegin)
            -- end

            memberInfo.BP_STRUCT_GROUP_INFO = groupInfo
        end
    end

    EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_MEMBERINFO)
end

function CorpsMemberSystem.InitMembers(corps)
    DataMgr.corpsInfo.corpsMemberList = {}
    DataMgr.corpsInfo.memberList = {}

    local memberIdList = {}
    for uId, memberInfo in pairs(corps.members) do
        local info = FuncUtil:CopyTable(memberInfo)
        info.id = uId
        info.strId = tostring(uId)
        table.insert(DataMgr.corpsInfo.corpsMemberList, info)
        table.insert(memberIdList, uId)
        if uId == tonumber(DataMgr.roleData.uid) then
            DataMgr.corpsInfo.selfMember = info
        end
    end

    CorpsMgr.GetMemberProfile(memberIdList, function(profileList, groupInfo)
        local idlist = {}

        for _,memberInfo in ipairs(DataMgr.corpsInfo.corpsMemberList) do
            memberInfo.BP_STRUCT_BASE_INFO = profileList[memberInfo.id] or {}
            local groupState = groupInfo[memberInfo.id]
            memberInfo.BP_STRUCT_GROUP_INFO = groupState or {}

            --军团分享福利保存军团玩家个人信息
            if memberInfo.BP_STRUCT_BASE_INFO then
                if memberInfo.BP_STRUCT_BASE_INFO.strUid then
                    table.insert(idlist, memberInfo.BP_STRUCT_BASE_INFO.strUid)
                    local item = {};
                    item.strUid = memberInfo.BP_STRUCT_BASE_INFO.strUid;
                    item.Name = memberInfo.BP_STRUCT_BASE_INFO.Name;
                    item.Level = memberInfo.BP_STRUCT_BASE_INFO.Level;
                    item.Sex = memberInfo.BP_STRUCT_BASE_INFO.sex;
                    item.RankIntegralLevel = memberInfo.BP_STRUCT_BASE_INFO.RankIntegralLevel;
                    item.IconUrl = memberInfo.BP_STRUCT_BASE_INFO.IconUrl;
                    item.IconFrameID  = memberInfo.BP_STRUCT_BASE_INFO.IconFrameID;
                    item.lastOnlineTimeStr = memberInfo.BP_STRUCT_BASE_INFO.lastOnlineTime;

                    -- 绝地通行证
                    item.upass_is_buy = memberInfo.BP_STRUCT_BASE_INFO.upass_is_buy; --是否购买(1为已购买，0为未购买)
                    item.upass_is_show = memberInfo.BP_STRUCT_BASE_INFO.upass_is_show; --是否显示(1为显示，0为不显示)
                    --国籍
                    item.nation = memberInfo.BP_STRUCT_BASE_INFO.nation;
                    table.insert(CorpsWelfareSystem.corpsMemberList, item);    
                end
            end
        end
        CorpsMemberSystem.isInit = true
        if CorpsMemberSystem.waitForMemberList then
            CorpsMemberSystem.waitForMemberList = false
            EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_GET_MEMBERLIST, DataMgr.corpsInfo.corpsMemberList)
        end
        EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_MEMBERINFO)

        -- 通过StatusManager再请求玩家状态
        log_tree("CorpsMemberSystem.InitMembers",idlist,"corps")
        StatusManager.getInstance():request(idlist,  StatusManager.KEY_CORPS_PANEL)
    end)

    CorpsMemberSystem.UpdateMemberPosition()
    DataMgr.corpsInfo.memberNum = #DataMgr.corpsInfo.corpsMemberList
    -- log_tree("CorpsMemberSystem.InitMembers corpsMemberList", DataMgr.corpsInfo.corpsMemberList);
end

function CorpsMemberSystem.UpdateMemberPosition()
    DataMgr.corpsInfo.secCommanderList = {}
    DataMgr.corpsInfo.eliteList = {}
    DataMgr.corpsInfo.memberList = {}
    for _,memberInfo in ipairs(DataMgr.corpsInfo.corpsMemberList) do
        if memberInfo.position == MemberPosition["Commander"] then
            DataMgr.corpsInfo.commanderId = memberInfo.id
        elseif memberInfo.position == MemberPosition["SecCommander"] then
            DataMgr.corpsInfo.secCommanderList[memberInfo.id] = true
        elseif memberInfo.position == MemberPosition["Elite"] then
            DataMgr.corpsInfo.eliteList[memberInfo.id] = true
        elseif memberInfo.position == MemberPosition["Member"] then
            DataMgr.corpsInfo.memberList[memberInfo.id] = true
        end
    end
end

function CorpsMemberSystem.FindApplyByID(id)
    id = tonumber(id);
    for i,v in ipairs(CorpsMemberSystem.ApplyList) do
        if v.uid == id then
            return v;
        end
    end

    return nil;
end

function CorpsMemberSystem.FindMemberByID(id)
    id = tonumber(id)
    for i,v in ipairs(DataMgr.corpsInfo.corpsMemberList) do
        if v.id == id then
            return v;
        end
    end

    return nil;
end

function CorpsMemberSystem.ResetData()
    DataMgr.corpsInfo.corpsMemberList = {}
    CorpsMemberSystem.ApplyList = {}
end

-- 申请加入军团
function CorpsMemberSystem.SendApplyJoinCorps(corps_id)
    log("CorpsMemberSystem.SendApplyJoinCorps corps_id "..corps_id)
    NetUtil.SendPkg("apply_join_corps_req", corps_id);
end

function CorpsMemberSystem.apply_join_corps_rsp(res, corps_id, can_join_time, auto_join)
    log("CorpsMemberSystem.apply_join_corps_rsp res "..res);
    log(string.format("CorpsMemberSystem.apply_join_corps_rsp(res[%s], corps_id[%s], can_join_time[%s], auto_join[%s])",
        tostring(res), tostring(corps_id), tostring(can_join_time), tostring(auto_join)))
    if res == "ok" then
        if auto_join then
            CorpsMgr.InitID(corps_id);
             -- 显示加入成功通知
            LuaClassObj.HandleUIMessage(bp_corps, "UIClose");
            EventOnCorpsClose();
            LobbySystem.OpenCorpsUI()
            LobbyChatLogic.CloseUI();
            ShowNotice(410031)
        else
            ShowNotice(410032)
            -- 显示已申请
            CorpsSuggestionSystem.UpdateTempApplyIDList(corps_id);
        end
        EventCorpsInvitationUIClose();

        --如果在个人空间中申请成功刷新角色信息
        RoleInfoUI.ChacheOwnHasApply()
        RoleInfoUI.SetHasApply(true)
    else

        --如果在个人空间中申请失败刷新角色信息
        RoleInfoUI.ChacheOwnHasApplyInfo(RoleInfoSystem.PersonalBasicInfo.role_id, false)
        RoleInfoUI.SetHasApply(false)
        
        if res == 411039 then
            -- log("CorpsMemberSystem.apply_join_corps_rsp can_join_time "..can_join_time);
            local msg = CorpsMemberSystem.GetRemainTimeStr(res, can_join_time);
            PopUpNoticeUI.ShowNewNotice(msg);
        elseif res == 411038 then
            CorpsMgr.ShowCorpsLimitError();
        else
            ShowNotice(res);
        end
    end
end

function CorpsMemberSystem.GetRemainTimeStr(errorCode, endTime)
    -- log_tree("CorpsMemberSystem.GetRemainTimeStr endTime", os.date(endTime))
    local remainTime = endTime - FuncUtil.GetServerTimeInSec();
    return FuncUtil.LocalizeResFormat(tostring(errorCode), FuncUtil.TimeFormatExtNoZero(remainTime))
end

-- 通知团长 副团长有人申请(小红点?)
function CorpsMemberSystem.notify_someone_apply_join()
    log("CorpsMemberSystem.notify_someone_apply_join")
    -- if CorpsMemberSystem.IsCommanderOrSecCommander(tonumber(DataMgr.roleData.uid)) then
    CorpsMemberSystem.SetApplyListRedPoint(true);
    -- end
end

-- 更新申请列表小红点
function CorpsMemberSystem.SetApplyListRedPoint(hasRedPoint)
    CorpsMemberSystem.HasRedPoint = hasRedPoint;
    UpdateLobbyCorpsRedDot(CorpsMgr.HasRedDot("lobby"))
    EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_APPLYLIST, hasRedPoint);
end

-- 获取申请列表
function CorpsMemberSystem.SendGetCorpsApplyListReq(isWaitting)
    if DataMgr.corpsInfo.id ~= 0 then
        if isWaitting then
            NetUtil.SendPkg("get_corps_apply_list_req");
        else
            NetUtil.SendPkg("get_corps_apply_list_req");
        end
    end
end

function CorpsMemberSystem.get_corps_apply_list_rsp(msg, apply_list)
    log("CorpsMemberSystem.get_corps_apply_list_rsp msg "..tostring(msg))
    if msg == "ok" then
        -- log_tree("CorpsMemberSystem.get_corps_apply_list_rsp apply_list", apply_list);

        CorpsMemberSystem.InitApplyList(apply_list);
        CorpsMemberSystem.OnApplyListInfoReq();

    elseif msg ~= nil and msg ~= 411006 then
        ShowNotice(msg);
    end
end

function CorpsMemberSystem.IsCanAddToApplyList(applyInfo)
    if applyInfo == nil then
        return false;
    end

    local isValidStatus = applyInfo.status == CorpsMemberSystem.ApplyStatus.approval
    return applyInfo.recomm_name == nil or isValidStatus;
end

function CorpsMemberSystem.IsSelfCommander()
    return CorpsMemberSystem.IsCommander(tonumber(DataMgr.roleData.uid));
end

function CorpsMemberSystem.IsCommander(uid)
    return uid == DataMgr.corpsInfo.commanderId;
end

function CorpsMemberSystem.IsSelfCommanderOrSecCommander()
    return CorpsMemberSystem.IsCommanderOrSecCommander(tonumber(DataMgr.roleData.uid));
end

function CorpsMemberSystem.IsCommanderOrSecCommander(uid)
    return uid == DataMgr.corpsInfo.commanderId or DataMgr.corpsInfo.secCommanderList[uid] ~= nil;
end

function CorpsMemberSystem.InitApplyList(apply_list)
    -- log("CorpsMemberSystem.InitApplyList")
    CorpsMemberSystem.ApplyList = {};

    -- if not CorpsMemberSystem.IsSelfCommanderOrSecCommander() then
    --     return;
    -- end

    if apply_list and CorpsMemberSystem.IsSelfCommanderOrSecCommander() then
        for i,v in ipairs(apply_list) do
            if CorpsMemberSystem.IsCanAddToApplyList(v) then
                table.insert(CorpsMemberSystem.ApplyList, FuncUtil:CopyTable(v));
            end
        end
    end

    CorpsMemberSystem.SetApplyListRedPoint(#CorpsMemberSystem.ApplyList > 0);
end

-- 拉取申请列表概要信息
function CorpsMemberSystem.OnApplyListInfoReq()
    local uidList = {}
    for i,v in ipairs(CorpsMemberSystem.ApplyList) do
        table.insert(uidList, v.uid);
    end

    if #uidList == 0 then
        CorpsMemberSystem.OnApplyListInfoRes(nil);
    else
        CorpsMgr.GetAvatarBaseInfo(uidList, CorpsMemberSystem.OnApplyListInfoRes);
    end
end

function CorpsMemberSystem.OnApplyListInfoRes(base_info_List)
    EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_GET_APPLY_LIST, base_info_List);
end

-- 处理玩家申请：
function CorpsMemberSystem.SendDealPlayerApplyReq(apply_uid, accept)
    log("CorpsMemberSystem.SendDealPlayerApplyReq apply_uid "..apply_uid)
    log("CorpsMemberSystem.SendDealPlayerApplyReq accept "..tostring(accept))
    NetUtil.SendPkg("deal_player_apply_req", tonumber(apply_uid), accept);
end

function CorpsMemberSystem.deal_player_apply_rsp(msg, corps, apply_uid, accept)
    -- log_tree("CorpsMemberSystem.deal_player_apply_rsp corps", corps)
    log("CorpsMemberSystem.deal_player_apply_rsp msg "..tostring(msg))
    -- log("CorpsMemberSystem.deal_player_apply_rsp apply_uid "..tostring(apply_uid))
    if apply_uid == nil then
        CorpsMemberSystem.SendGetCorpsApplyListReq(true);
    else
        CorpsMemberSystem.RemoveFromApplyList(apply_uid);
        CorpsMemberSystem.OnApplyListInfoReq();
    end
    if msg == "ok" then
        if accept then
            CorpsMgr.InitData(corps);
            ShowNotice(410035)
        else
            ShowNotice(410036)
        end
    elseif msg ~= nil then
        ShowNotice(msg);
    end
end

function CorpsMemberSystem.RemoveFromApplyList(apply_uid)
    local removeIdx = -1;
    for i,v in ipairs(CorpsMemberSystem.ApplyList) do
        if v.uid == apply_uid then
            removeIdx = i;
            break;
        end
    end

    -- log("CorpsMemberSystem.RemoveFromApplyList apply_uid "..apply_uid);
    -- log_tree("CorpsMemberSystem.RemoveFromApplyList CorpsMemberSystem.ApplyList", CorpsMemberSystem.ApplyList)

    if removeIdx ~= -1 then
        -- log("CorpsMemberSystem.RemoveFromApplyList removeIdx "..removeIdx)
        table.remove(CorpsMemberSystem.ApplyList, removeIdx);
        CorpsApplyListUILogic.RemoveItem(apply_uid);
        CorpsMemberSystem.SetApplyListRedPoint(#CorpsMemberSystem.ApplyList > 0);
    end
end

-- 退出军团
function CorpsMemberSystem.SendExitCorpsReq()
    -- log("CorpsMemberSystem.SendExitCorpsReq");
    if CorpsMemberSystem.IsSelfCommander() then
        if #DataMgr.corpsInfo.corpsMemberList > 1 then
            CommonMessageBoxUI:ShowPanel(1, FuncUtil.GetLocalizeResStr("101001"), FuncUtil.GetLocalizeResStr("410012"));
        else
            CommonMessageBoxUI:ShowPanel(2, FuncUtil.GetLocalizeResStr("101001"), FuncUtil.GetLocalizeResStr("410013"), CorpsMemberSystem.DoSendExitCorpsReq);
        end
    else
        CommonMessageBoxUI:ShowPanel(2, FuncUtil.GetLocalizeResStr("101001"), FuncUtil.GetLocalizeResStr("410014"), CorpsMemberSystem.DoSendExitCorpsReq);
    end
end

function CorpsMemberSystem.DoSendExitCorpsReq()
    log("CorpsMemberSystem.DoSendExitCorpsReq");
    NetUtil.SendPkg("exit_corps_req");
end

function CorpsMemberSystem.exit_corps_rsp(msg)
    log("CorpsMemberSystem.exit_corps_rsp msg "..msg)
    if msg == "ok" then
        -- 显示提示信息
        CorpsMgr.InitID(0);
        EventCorpsClose();
        CorpsMemberSystem.ResetData();
        LobbyChatSystem.QuitCorps()
        CorpsSuggestionSystem.InitInvitedCorpsArray({})
        ShowNotice(410039);
    else
        ShowNotice(msg);
    end
end

-- 军团踢人
function CorpsMemberSystem.SendKickMember(memberUID)
    NetUtil.SendPkg("corps_kick_member", memberUID);
end

function CorpsMemberSystem.corps_kick_member_rsp(msg, corps)
    if msg == "ok" then
        CorpsMgr.InitData(corps);
    elseif msg ~= nil then
        ShowNotice(msg);
    end
end

-- 邀请加入
--approval_status
    -- 0： 一般邀请
    -- 1：团长或副团长 审批 【同意】
    -- 2：团长或副团长 审批 【拒绝】
function CorpsMemberSystem.SendInviteReq(fri_uid, approval_status)
    log("CorpsMemberSystem.SendInviteReq fri_uid "..fri_uid)
    log("CorpsMemberSystem.SendInviteReq approval_status "..approval_status)
    log("CorpsMemberSystem.SendInviteReq DataMgr.corpsInfo.id "..DataMgr.corpsInfo.id)

    -- 不是团长或者副团长，只能发0
    if approval_status ~= 0 and not CorpsMemberSystem.IsSelfCommanderOrSecCommander() then
        approval_status = 0;
    end
    NetUtil.SendPkg("corps_invite_req", DataMgr.corpsInfo.id, tonumber(fri_uid), approval_status);
end

function CorpsMemberSystem.corps_invite_rsp(res, corps_id, fri_uid, approval_status, left_cnt)
    log(string.format("CorpsMemberSystem.corps_invite_rsp %s, %s, %s %s", tostring(res), tostring(corps_id), tostring(fri_uid), tostring(left_cnt)))
    -- if approval_status ~= nil then
    --     log("CorpsMemberSystem.corps_invite_rsp approval_status:"..approval_status)
    -- else
    --     log("CorpsMemberSystem.corps_invite_rsp approval_status == nil")
    -- end
    
    if res == "ok" then
        if approval_status == 0 then
            CorpsMemberSystem.invitedRemainNum = left_cnt or 0;
            ShowNotice(410011);
        elseif approval_status == 1 then
            ShowNotice(410011);
        elseif approval_status == 2 then
            ShowNotice(410036);
        end
        AllianceRecruitUI.HasSendInvite(fri_uid);
        CorpsMemberSystem.RemoveFromApplyList(fri_uid);
        RoleInfoUI.SetInviteCorpsResult();
    else
        ShowNotice(res);
    end
end


local SendGetDailyInvitedListDelegate = nil
-- 获取已邀请列表
function CorpsMemberSystem.SendGetDailyInvitedListReq(del)
    SendGetDailyInvitedListDelegate = del
    NetUtil.SendPkg("corps_get_daily_invited_list_req");
end

function CorpsMemberSystem.corps_get_daily_invited_list_rsp(res, invited_list, left_cnt)
    CorpsMemberSystem.InvitedList = {}
    if res == "ok" then
        -- log_tree("CorpsMemberSystem.corps_get_daily_invited_list_rsp invited_list", invited_list);
        for i,v in ipairs(invited_list) do
            table.insert(CorpsMemberSystem.InvitedList, v);
        end

        log("CorpsMemberSystem.corps_get_daily_invited_list_rsp left_cnt "..tostring(left_cnt))
        CorpsMemberSystem.invitedRemainNum = left_cnt or 0;
        -- AllianceRecruitUI.ResetCorpsInviteList();  --todo chris.这里应该不需要更新界面，先屏蔽看看


    elseif res ~= nil then
        ShowNotice(res);
    end

    if SendGetDailyInvitedListDelegate ~= nil then 
        SendGetDailyInvitedListDelegate()
        SendGetDailyInvitedListDelegate = nil
    end
end

-- 处理军团邀请
-- accept：
        -- CorpsSuggestionSystem.accept_yes:接受
        -- CorpsSuggestionSystem.accept_no:拒绝
function CorpsMemberSystem.corps_accept_invite_req(corps_id, accept)
    corps_id = tonumber(corps_id)
    log("CorpsMemberSystem.corps_accept_invite_req corps_id "..corps_id)
    NetUtil.SendPkg("corps_accept_invite_req", corps_id, accept)
end

function CorpsMemberSystem.corps_accept_invite_rsp(res, corps_id, accept, open_join_time)
    if res == nil then
        return
    end
    log("CorpsMemberSystem.corps_accept_invite_rsp res "..tostring(res))
    log("CorpsMemberSystem.corps_accept_invite_rsp corps_id "..tostring(corps_id))
    log("CorpsMemberSystem.corps_accept_invite_rsp accept "..tostring(accept))
    corps_id = corps_id or 0
    if res == "ok" then
        if accept == CorpsMemberSystem.accept_yes then
            ShowNotice(410031);
            EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_JOINED);
            LobbySystem.OpenCorpsUI();
        elseif accept == CorpsMemberSystem.accept_no then
            ShowNotice(410036);
            CorpsSuggestionSystem.RemoveInvitedCorpsByID(corps_id)
            EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_NO_JOIN, {res = res, corps_id=corps_id, accept=accept});
        end
    else
        if res == 411039 then
            local msg = CorpsMemberSystem.GetRemainTimeStr(res, open_join_time or 0);
            PopUpNoticeUI.ShowNewNotice(msg);
        else
            ShowNotice(res);
            CorpsSuggestionSystem.RemoveInvitedCorpsByID(corps_id)
            EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_NO_JOIN, {res = res, corps_id=corps_id, accept=accept});
        end
    end
end

-- 成员任命
function CorpsMemberSystem.SendAppoint(target_uid, class_type)
    log("CorpsMemberSystem.SendAppoint class_type "..class_type)
    NetUtil.SendPkg("corps_appoint", target_uid, class_type);
end

function CorpsMemberSystem.corps_appoint_rsp(res, target_uid, class_type)
    if res == nil then
        return
    end
    log("CorpsMemberSystem.corps_appoint_rsp res "..res)
    if res == "ok" then
        CorpsAppointUI.HideUI()
        CorpsMemberSystem.SetMemberAppoint(target_uid, class_type)
        ShowNotice(410001);
    else
        ShowNotice(res);
    end
end

function CorpsMemberSystem.SetMemberAppoint(target_uid, class_type)
    -- log("CorpsMemberSystem.SetMemberAppoint target_uid "..target_uid)
    log("CorpsMemberSystem.SetMemberAppoint class_type "..tostring(class_type))
    -- 记录旧的阶级
    local oldEnable = CorpsMemberSystem.IsSelfCommanderOrSecCommander();
    if class_type == MemberPosition["Commander"] then
        local commander = CorpsMemberSystem.FindMemberByID(DataMgr.corpsInfo.commanderId);

        if commander ~= nil then
            commander.position = MemberPosition["Member"];
        else
            sandbox.LogError("can't find commander");
        end
    end

    local member = CorpsMemberSystem.FindMemberByID(target_uid);
    if member == nil then
        return;
    end

    member.position = class_type;
    CorpsMemberSystem.UpdateMemberPosition()

    -- 我的新阶级
    local newEnable = CorpsMemberSystem.IsSelfCommanderOrSecCommander();
    if newEnable ~= oldEnable then
        if not newEnable then
            CorpsMemberSystem.InitApplyList(nil);
        else
            CorpsMemberSystem.SendGetCorpsApplyListReq(false);
        end
    end

    --认命后不是团长或者副团长，隐藏审批列表
    if member.position > 2 then
        CorpsApplyListUILogic.HideUI();
    end

    BP_SelfCorpsPosition = member.position;

    EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_MEMBERINFO)
end

function CorpsMemberSystem.notify_corps_target_appoint_info(corps_id, op_uid, class_type)
    log("CorpsMemberSystem.notify_corps_target_appoint_info")
    CorpsMemberSystem.SetMemberAppoint(tonumber(DataMgr.roleData.uid), class_type);
end

s2c["apply_join_corps_rsp"] = CorpsMemberSystem.apply_join_corps_rsp;
s2c["notify_someone_apply_join"] = CorpsMemberSystem.notify_someone_apply_join;
s2c["get_corps_apply_list_rsp"] = CorpsMemberSystem.get_corps_apply_list_rsp;
s2c["exit_corps_rsp"] = CorpsMemberSystem.exit_corps_rsp;
s2c["corps_kick_member_rsp"] = CorpsMemberSystem.corps_kick_member_rsp;
s2c["deal_player_apply_rsp"] = CorpsMemberSystem.deal_player_apply_rsp;
s2c["corps_invite_rsp"] = CorpsMemberSystem.corps_invite_rsp;
s2c["corps_get_daily_invited_list_rsp"] = CorpsMemberSystem.corps_get_daily_invited_list_rsp;
s2c["corps_appoint_rsp"] = CorpsMemberSystem.corps_appoint_rsp;
s2c["corps_accept_invite_rsp"] = CorpsMemberSystem.corps_accept_invite_rsp;
s2c["notify_corps_target_appoint_info"] = CorpsMemberSystem.notify_corps_target_appoint_info;
