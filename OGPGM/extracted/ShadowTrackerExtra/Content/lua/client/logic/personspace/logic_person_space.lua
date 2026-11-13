PersonSpaceSystem = PersonSpaceSystem or
        {
            CacheUid = 0,
            IntimacyPartnerData  = {},--亲密伙伴数据
            IntimacyReddot = {},--亲密好友红点
            VisibleSwitchs = {}, --可见的开关
            FriendIntimacyDatas = {}, --亲密好友数据
            CacheSwitchUid = 0, --缓存了那个玩家的开关数据了
            CancelApplyList = {}, --玩家取消申请后，短时间内不能再点击申请 {uid = time}
            AgainApplyTimeInterval = 10, -- 取消之后，等待时间
            PartnerIntimacyLimit = 400, -- 可以申请拍档的亲密度 400
            list = {},--亲密度列表
        }

PersonSpaceErrorCode = 
{
    intimacy_pnr_err_intimacy_not_enough                = 509001,    --亲密度不够
    intimacy_pnr_err_not_intimacy_relation              = 509002,    --非亲密关系
    intimacy_pnr_err_has_sent_req                       = 509003,    --已发送过搭档请求
    intimacy_pnr_err_already_have_partner               = 509004,    --已经有搭档
    intimacy_pnr_err_wrong_param                        = 509005,    --参数错误
    intimacy_pnr_err_partner_apply_reach_limit          = 509006,    --对方收到的申请达到上限
    intimacy_pnr_err_request_reach_limit                = 509007,    --我方请求达到上限
    intimacy_pnr_err_not_in_confirm_list                = 509008,    --不在待确认列表
    intimacy_pnr_err_not_in_req_list                    = 509009,    --不在请求列表
    intimacy_pnr_err_perr_have_partner                  = 509010,    --对方已经有搭档
    intimacy_pnr_err_not_have_partner                   = 509011,    --还没有搭档
    intimacy_pnr_err_not_inner_fri                      = 509012,    --不是好友关系
}

PersonSpaceReddotType =
{
    REDOT_NEW_INTIMACY_RELATION_AVAILABLE = 1,                 --新的可建立亲密关系的好友
    REDOT_NEW_INTIMACY_PARTNER_AVAILABLE  = 2,                 --新的可建立亲密搭档的亲密关系
    REDOT_NEW_INTIMACY_PARTNER_APPLY  = 3,                     --新的搭档申请
    REDOT_INTIMACY_PARTNER_CHG  = 4,                           --亲密搭档发生变动
}

---两个向导
PersonSpaceGuideType = 
{
    PartnerSetting = 1, 
    SecrecySetting = 2,
}

--partner设置向导进度
PersonSpacePartnerSettingProgress =
{
    Setting = 1,
    Apply = 2,
}

--Secrecy设置向导进度
PersonSpaceSecrecySettingProgress = 
{
    Setting = 1,
    Switch = 2,
}

--res数据结构
--{
--    partner_uid = 0,             --亲密搭档uid
--    partner_time = 0,            --搭档建立时间
--    partner_status = 0,          --搭档关系状态
--    sent_request_list = {},      --已发送申请搭档列表 {[uid] = {expirt_time, status}}
--    wait_confirm_list = {},      --待处理申请列表 {[uid] = {expirt_time, status}}
--}

function PersonSpaceSystem.Enter()
    PersonSpaceSystem.CacheUid = 0
    PersonSpaceSystem.CacheSwitchUid = 0
    --PersonSpaceSystem.IntimacyPartnerData  = {}--亲密伙伴数据
    --PersonSpaceSystem.IntimacyReddot = {}--亲密好友红点
    --PersonSpaceSystem.VisibleSwitchs = {} --可见的开关
    --PersonSpaceSystem.FriendIntimacyDatas = {} --亲密好友数据
    --PersonSpaceSystem.CancelApplyList = {} --玩家取消申请后，短时间内不能再点击申请
end

function PersonSpaceSystem.get_intimacy_relation_req()
    log("PersonSpaceSystem.get_intimacy_relation_req");

    if PersonSpaceSystem.CacheUid == DataMgr.roleData.uid then
        PersonSpaceSystem.get_intimacy_relation_rsp(PersonSpaceSystem.list, PersonSpaceSystem.IntimacyPartnerData, PersonSpaceSystem.IntimacyReddot)
    else
        --get_intimacy_relation_req, 第二个参数表示，是否需要发送红点信息
        local IsNeedRedpoint = true
        NetUtil.SendPriorityPkg(false, "get_intimacy_relation_rsp", "get_intimacy_relation_req", IsNeedRedpoint)
    end
end

function PersonSpaceSystem.get_other_intimacy_relation_req(other_uid)
    log("PersonSpaceSystem.get_other_intimacy_relation_req:" .. other_uid);

    if PersonSpaceSystem.CacheUid == other_uid then
        PersonSpaceSystem.get_other_intimacy_relation_rsp(other_uid, PersonSpaceSystem.list, PersonSpaceSystem.visible_switchs)
    else
        NetUtil.SendPriorityPkg(false, "get_other_intimacy_relation_rsp", "get_other_intimacy_relation_req", tonumber(other_uid));
    end
end

--function PersonSpaceSystem.get_intimacy_partner_data_req()
--    log("PersonSpaceSystem.get_intimacy_partner_data_req");
--    NetUtil.SendPriorityPkg(false, "get_intimacy_partner_data_rsp", "get_intimacy_partner_data_req");
--end

function PersonSpaceSystem.remove_intimacy_reddot(reddot_type)
    log("PersonSpaceSystem.remove_intimacy_reddot:" .. tostring(reddot_type));

    PersonSpaceSystem.IntimacyReddot[reddot_type] = nil

    EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_REDDOT_UPDATE);
    
    NetUtil.SendPkg("remove_intimacy_reddot", reddot_type);
end

function PersonSpaceSystem.HasIntimacyReddot(reddot_type)
    return PersonSpaceSystem.IntimacyReddot[reddot_type] or false
end

function PersonSpaceSystem.HasRelationshipInviteRedpoint()
    local wait_confirm_list = PersonSpaceSystem.IntimacyPartnerData.wait_confirm_list
    local hasWait = false
    if wait_confirm_list and next(wait_confirm_list) ~= nil then
        hasWait = true
    end
    local apply = PersonSpaceSystem.HasIntimacyReddot(PersonSpaceReddotType.REDOT_NEW_INTIMACY_PARTNER_APPLY)
    
    return hasWait or apply
end

--亲密拍档红点
function PersonSpaceSystem.HasIntimacyReddotAll()
    if not LobbyUI:CheckLobbyMenuOpen(BP_ENUM_PERSONSPACE_PARTNERSETTING, false) then
        return false
    end

    local apply = PersonSpaceSystem.HasIntimacyReddot(PersonSpaceReddotType.REDOT_NEW_INTIMACY_PARTNER_APPLY)
    local change = PersonSpaceSystem.HasIntimacyReddot(PersonSpaceReddotType.REDOT_INTIMACY_PARTNER_CHG)
    local available = PersonSpaceSystem.HasIntimacyReddot(PersonSpaceReddotType.REDOT_NEW_INTIMACY_PARTNER_AVAILABLE)
    local hasPartner =  PersonSpaceSystem.IntimacyPartnerData and PersonSpaceSystem.IntimacyPartnerData.partner_uid ~= 0

    local wait_confirm_list = PersonSpaceSystem.IntimacyPartnerData.wait_confirm_list
    local hasWait = false
    if wait_confirm_list and next(wait_confirm_list) ~= nil then
        hasWait = true
    end 
    
    return (not hasPartner and available)  or change or hasWait or apply
end


function PersonSpaceSystem.make_intimacy_partner_req(target_uid)
    log("PersonSpaceSystem.make_intimacy_partner_req:" .. tostring(target_uid));
    NetUtil.SendPriorityPkg(false, "make_intimacy_partner_rsp", "make_intimacy_partner_req", target_uid);;
end

function PersonSpaceSystem.agree_make_intimacy_partner_req(target_uid)
    log("PersonSpaceSystem.agree_make_intimacy_partner_req:" .. tostring(target_uid));
    NetUtil.SendPriorityPkg(false, "agree_make_intimacy_partner_rsp", "agree_make_intimacy_partner_req", target_uid);;
end

function PersonSpaceSystem.refuse_make_intimacy_partner_req(target_uid)
    log("PersonSpaceSystem.refuse_make_intimacy_partner_req:" .. tostring(target_uid));
    NetUtil.SendPriorityPkg(false, "refuse_make_intimacy_partner_rsp", "refuse_make_intimacy_partner_req", target_uid);
end

function PersonSpaceSystem.release_intimacy_partner_req(target_uid)
    log("PersonSpaceSystem.release_intimacy_partner_req:" .. tostring(target_uid));
    NetUtil.SendPriorityPkg(false, "release_intimacy_partner_rsp", "release_intimacy_partner_req", target_uid);
end

function PersonSpaceSystem.cancle_make_intimacy_partner_req(target_uid)
    log("PersonSpaceSystem.cancle_make_intimacy_partner_req:" .. tostring(target_uid));

    PersonSpaceSystem.CancelApplyList[target_uid] = FuncUtil.GetServerTimeInSec()
    
    NetUtil.SendPriorityPkg(false, "cancle_make_intimacy_partner_rsp", "cancle_make_intimacy_partner_req", target_uid);
end

--设置亲密关系可见
--relation: 0代所有关系  1，2，3，4代表各个关系（见配置）
--is_visible：true or false 开或者关

function PersonSpaceSystem.set_intimacy_relation_visible_req(switch_list)
    log_tree("PersonSpaceSystem.switch_list" , switch_list);
    NetUtil.SendPkg("set_intimacy_relation_visible_req", switch_list);
end

function PersonSpaceSystem.get_intimacy_relation_visible_req()
    log("get_intimacy_relation_visible_req:" .. PersonSpaceSystem.CacheSwitchUid);
    if PersonSpaceSystem.CacheSwitchUid ==  DataMgr.roleData.uid then
        EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_SWITCH_UPDATE);
    else
        NetUtil.SendPriorityPkg(false, "get_intimacy_relation_visible_rsp","get_intimacy_relation_visible_req");
    end
end

--此函数用在多个地方
function PersonSpaceSystem.AddProfileData(item, profile, intimacy)
    local upass_is_buy, upass_is_show = FriendSystem.ParseUpassInfo(profile.upass);

    item.nickName = profile.nickName
    item.level = profile.level
    item.picUrl = profile.picUrl
    item.vipLevel = profile.vipLevel
    item.sex = profile.sex
    item.signature = profile.signature
    item.intimacy = intimacy or profile.intimacy
    item.segment_info_max = math.max(profile.segment_info_solo or 0, profile.segment_info_duo or 0, profile.segment_info_squad or 0)
    item.cur_avatar_box_id = profile.cur_avatar_box_id
    item.upass_is_buy = upass_is_buy
    item.upass_is_show = upass_is_show
    item.aliasId = profile.aliasId;
    item.aliasTitle = profile.aliasTitle;
    item.aliasNation = profile.aliasNation;
    item.roleNation = ProfileMgr.GetRoleNationByUid(item.gid);
end

--list 亲密关系信息
--intimacy_partner_data 亲密好友信息
--intimacy_reddot   亲密系统红点信息
function PersonSpaceSystem.get_intimacy_relation_rsp(list, intimacy_partner_data, intimacy_reddot)
    log("PersonSpaceSystem.get_intimacy_relation_rsp");
    log_tree("PersonSpaceSystem list", list)
    log_tree("PersonSpaceSystem intimacy_partner_data", intimacy_partner_data)
    log_tree("PersonSpaceSystem intimacy_reddot", intimacy_reddot)

    PersonSpaceSystem.list = list
    PersonSpaceSystem.IntimacyPartnerData = intimacy_partner_data or {partner_uid = 0}

    --如果请求的协议不需要发送红点信息，那么可能为nil
    if intimacy_reddot then
        PersonSpaceSystem.IntimacyReddot = intimacy_reddot
    end

    PersonSpaceSystem.CacheUid = DataMgr.roleData.uid

    PersonSpaceSystem.FriendIntimacyDatas = {}

    local gids = {}

    for k,v in pairs(list) do
        if v.state == 4 then
            local data = {}
            data.gid = tostring(k)
            --state不同含义不同
            data.relation = v.param

            table.insert(gids, tonumber(data.gid))

            if v.intimacy then
                data.intimacy = v.intimacy --如果有传亲密度的话，那么使用之，是为了打开界面，由于使用旧的亲密度导致的刷新问题
            end

            table.insert(PersonSpaceSystem.FriendIntimacyDatas,data)
            log("uid:" .. tostring(k) ..",picUrl:" .. tostring(data.picUrl))
        end
    end

    if #gids > 0 then
        ProfileMgr.GetFriendProfileList(gids,function(list)
            for j, currProfile in pairs(list) do
                for i, data in ipairs(PersonSpaceSystem.FriendIntimacyDatas) do
                    if tonumber(data.gid) == tonumber(currProfile.uid) then
                        PersonSpaceSystem.AddProfileData(data, currProfile, data.intimacy)
                    end
                end
            end

            if next(PersonSpaceSystem.FriendIntimacyDatas) ~= nil then
                table.sort(PersonSpaceSystem.FriendIntimacyDatas, function(a, b)
                    return a.intimacy > b.intimacy
                end)
            end

            log_tree("PersonSpaceSystem BP_ARRAY_PersonSpace_Intimacy_Data", PersonSpaceSystem.FriendIntimacyDatas)


            EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_INTIMACY_DATA_UPDATE);
            EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_REDDOT_UPDATE);
        end ,false,false)
    else
        EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_INTIMACY_DATA_UPDATE);
        EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_REDDOT_UPDATE);
    end

end


--function PersonSpaceSystem.get_intimacy_partner_data_rsp(result)
--    log("PersonSpaceSystem.get_intimacy_partner_data_rsp");
--    log_tree("PersonSpaceSystem result", result)
--
--    PersonSpaceSystem.IntimacyPartnerData = result
--end

function PersonSpaceSystem.GetFriendIntimacyDataByUID(uid)
    for k,data in ipairs(PersonSpaceSystem.FriendIntimacyDatas) do
        if tonumber(data.gid) == tonumber(uid)then
            return data
        end
    end
    return nil
end

--other_uid:目标uid
--list:亲密关系列表
--visible_switchs:亲密关系开关（新增）
function PersonSpaceSystem.get_other_intimacy_relation_rsp(other_uid, list, visible_switchs)
    log("PersonSpaceSystem.get_other_intimacy_relation_rsp:" .. tostring(other_uid));
    log_tree("PersonSpaceSystem list", list)
    log_tree("PersonSpaceSystem visible_switchs", visible_switchs)

    PersonSpaceSystem.CacheUid = other_uid
    PersonSpaceSystem.CacheSwitchUid = other_uid
    PersonSpaceSystem.IntimacyFriend = {}
    PersonSpaceSystem.VisibleSwitchs = visible_switchs

    PersonSpaceSystem.list = list
    --PersonSpaceSystem.VisibleSwitchs[0] = true
    --PersonSpaceSystem.VisibleSwitchs[1] = false
    --PersonSpaceSystem.VisibleSwitchs[2] = false
    
    PersonSpaceSystem.FriendIntimacyDatas = {}
    log_tree("PersonSpaceSystem visible_switchs", visible_switchs)

    local gids = {}
    for k,v in pairs(list) do
        table.insert(gids, tonumber(k))
        table.insert(PersonSpaceSystem.FriendIntimacyDatas, {gid = tostring(k), relation = v.relation, intimacy = v.intimacy}) 
    end
    log_tree("PersonSpaceSystem BP_ARRAY_PersonSpace_Intimacy_Data", PersonSpaceSystem.FriendIntimacyDatas)

    --log_tree("PersonSpaceSystem gids", gids)

    if #gids > 0 then
        --查找到对应的profile数据
        ProfileMgr.GetProfileList(gids, function(list)

            --log_tree("PersonSpaceSystem GetProfileList list", list)

            for j, currProfile in pairs(list) do
                for i, data in ipairs(PersonSpaceSystem.FriendIntimacyDatas) do
                    if tonumber(data.gid) == tonumber(currProfile.uid) then
                        PersonSpaceSystem.AddProfileData(data, currProfile)
                    end
                end
            end

            if next(PersonSpaceSystem.FriendIntimacyDatas) ~= nil then
                table.sort(PersonSpaceSystem.FriendIntimacyDatas, function(a, b)
                    return a.intimacy > b.intimacy
                end)
            end

            log_tree("PersonSpaceSystem BP_ARRAY_PersonSpace_Intimacy_Data", PersonSpaceSystem.FriendIntimacyDatas)

            EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_INTIMACY_DATA_UPDATE);

        end , false)
    else
        EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_INTIMACY_DATA_UPDATE);
    end

    EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_SWITCH_UPDATE);
end

function PersonSpaceSystem.make_intimacy_partner_rsp(target_uid, res, intimacy_partner_data)
    log("PersonSpaceSystem.get_other_intimacy_relation_rsp:" .. tostring(res) .. ",target_uid:" .. target_uid);

    if res ~= 0 then
        ShowNotice(res)
    else
        ShowNotice(FuncUtil.LocalizeResFormat(6706))
    end

    if intimacy_partner_data then
        PersonSpaceSystem.IntimacyPartnerData = intimacy_partner_data
        log_tree("PersonSpaceSystem make_intimacy_partner_rsp intimacy_partner_data", intimacy_partner_data)
        EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_INTIMACY_DATA_UPDATE);
    end
end

function PersonSpaceSystem.agree_make_intimacy_partner_rsp(target_uid, res, intimacy_partner_data)
    log("PersonSpaceSystem.agree_make_intimacy_partner_rsp:" .. tostring(res) .. ",target_uid:" .. target_uid);
    if res ~= 0 then
        ShowNotice(res)
    else
        local data = PersonSpaceSystem.GetFriendIntimacyDataByUID(BP_PERSONSPACEPARTNER_CLICK_UID)
        local nickname = data and data.nickName or ""
        local tip = FuncUtil.LocalizeResFormat("6609", nickname);
        ShowNotice(tip) -- 与{0}的拍档关系建立成功
    end
    
    if intimacy_partner_data then
        log_tree("PersonSpaceSystem agree_make_intimacy_partner_rsp intimacy_partner_data", intimacy_partner_data)
        PersonSpaceSystem.IntimacyPartnerData = intimacy_partner_data
        EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_INTIMACY_DATA_UPDATE);
        EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_REDDOT_UPDATE);
        EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_PARTNER_CHANGE)
    end
end

function PersonSpaceSystem.release_intimacy_partner_rsp(target_uid, res, intimacy_partner_data)
    log("PersonSpaceSystem.release_intimacy_partner_rsp:" .. tostring(res) .. ",target_uid:" .. target_uid);
    if res ~= 0 then
        ShowNotice(res)
    end

    if intimacy_partner_data then
        log_tree("PersonSpaceSystem release_intimacy_partner_rsp intimacy_partner_data", intimacy_partner_data)
        PersonSpaceSystem.IntimacyPartnerData = intimacy_partner_data
        EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_INTIMACY_DATA_UPDATE);
        EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_PARTNER_CHANGE)
    end
end


function PersonSpaceSystem.cancle_make_intimacy_partner_rsp(target_uid, res, intimacy_partner_data)
    log("PersonSpaceSystem.cancle_make_intimacy_partner_rsp:" .. tostring(res) .. ",target_uid:" .. target_uid);
    if res ~= 0 then
        ShowNotice(res)
    end

    if intimacy_partner_data then
        log_tree("PersonSpaceSystem cancle_make_intimacy_partner_rsp intimacy_partner_data", intimacy_partner_data)
        PersonSpaceSystem.IntimacyPartnerData = intimacy_partner_data
        EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_INTIMACY_DATA_UPDATE);
        EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_REDDOT_UPDATE);
    end
end

function PersonSpaceSystem.refuse_make_intimacy_partner_rsp(target_uid, res, intimacy_partner_data)
    log("PersonSpaceSystem.refuse_make_intimacy_partner_rsp:" .. tostring(res) .. ",target_uid:" .. target_uid);
    if res ~= 0 then
        ShowNotice(res)
    end

    if intimacy_partner_data then
        log_tree("PersonSpaceSystem refuse_make_intimacy_partner_rsp intimacy_partner_data", intimacy_partner_data)
        PersonSpaceSystem.IntimacyPartnerData = intimacy_partner_data
        EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_INTIMACY_DATA_UPDATE);
        EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_REDDOT_UPDATE);
    end
end

function PersonSpaceSystem.set_intimacy_relation_visible_rsp(res, switch_list)
    log("PersonSpaceSystem.set_intimacy_relation_visible_rsp:" .. tostring(res));
    if res ~= "ok" then
        ShowNotice(res)
    end

    if switch_list then
        PersonSpaceSystem.VisibleSwitchs = switch_list
        PersonSpaceSystem.CacheSwitchUid = DataMgr.roleData.uid;
        EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_SWITCH_UPDATE);
    end
end

function PersonSpaceSystem.notify_client_intimacy_data_chg(reddot_type)
    log("PersonSpaceSystem.notify_intimacy_data_chg:" .. tostring(reddot_type));
    PersonSpaceSystem.IntimacyReddot[reddot_type] = true

    if reddot_type == PersonSpaceReddotType.REDOT_INTIMACY_PARTNER_CHG then
        EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_PARTNER_CHANGE)
    end

    --已经在特定的界面了，那么红点就自动消除
    if UIManager.GetUI(eUIType.ePersonSpaceMainUI) then
        if PersonSpaceSystem.HasIntimacyReddot(PersonSpaceReddotType.REDOT_INTIMACY_PARTNER_CHG) then
            PersonSpaceSystem.remove_intimacy_reddot(PersonSpaceReddotType.REDOT_INTIMACY_PARTNER_CHG)
        end
    end

    if UIManager.GetUI(eUIType.ePersonSpacePartnerSettingUI) then
        if BP_PersonSpacePartnerSetting_PageIndex == PersonSpacePartnerSetting_PageIndex.Apply then
            if PersonSpaceSystem.HasIntimacyReddot(PersonSpaceReddotType.REDOT_NEW_INTIMACY_PARTNER_AVAILABLE) then
                PersonSpaceSystem.remove_intimacy_reddot(PersonSpaceReddotType.REDOT_NEW_INTIMACY_PARTNER_AVAILABLE)
            end
        end

        if BP_PersonSpacePartnerSetting_PageIndex == PersonSpacePartnerSetting_PageIndex.Invite then
            if PersonSpaceSystem.HasIntimacyReddot(PersonSpaceReddotType.REDOT_NEW_INTIMACY_PARTNER_APPLY) then
                PersonSpaceSystem.remove_intimacy_reddot(PersonSpaceReddotType.REDOT_NEW_INTIMACY_PARTNER_APPLY)
            end
        end
    end
    --解除红点与重新申请的顺序很重要，因为重新请求会刷新红点
    if reddot_type == PersonSpaceReddotType.REDOT_NEW_INTIMACY_PARTNER_APPLY or reddot_type == PersonSpaceReddotType.REDOT_INTIMACY_PARTNER_CHG then
        --UIManager.Hide(eUIType.ePersonSpaceMainUI)
        PersonSpaceSystem.CacheUid = 0
        if UIManager.GetUI(eUIType.ePersonSpacePartnerSettingUI) then --如果当前界面打开的话，那么请求刷新
            PersonSpaceSystem.get_intimacy_relation_req()
        end
    end
    
    EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_REDDOT_UPDATE);
end

function PersonSpaceSystem.get_intimacy_relation_visible_rsp(switch_list)
    log_tree("PersonSpaceSystem.switch_list:" ,switch_list);
    PersonSpaceSystem.VisibleSwitchs = switch_list
    PersonSpaceSystem.CacheSwitchUid = DataMgr.roleData.uid
    EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_SWITCH_UPDATE);
end

--有达到配置拍档标准时，且玩家当前没有配置拍档好友时，显示红点：头像-->个人空间-->亲密关系-->拍档设置-->对应玩家
function PersonSpaceSystem.ShouldShowPartnerReddot()
    --log_tree("PersonSpaceSystem.switch_list:" ,switch_list);
    
    
end



--s2c["get_intimacy_relation_rsp"] = PersonSpaceSystem.get_intimacy_relation_rsp; --查询亲密关系信息

--other_uid:目标uid
--list:亲密关系列表
--visible_switchs:亲密关系开关（新增）
s2c["get_other_intimacy_relation_rsp"] = PersonSpaceSystem.get_other_intimacy_relation_rsp; --获取别人的亲密关系
--s2c["get_intimacy_partner_data_rsp"] = PersonSpaceSystem.get_intimacy_partner_data_rsp; --此协议只拉取亲密搭档信息，暂时保留视情况单独拉取
s2c["notify_client_intimacy_data_chg"] = PersonSpaceSystem.notify_client_intimacy_data_chg; --通知亲密好友数据变化
s2c["make_intimacy_partner_rsp"] = PersonSpaceSystem.make_intimacy_partner_rsp; --发出搭档请求回复
s2c["agree_make_intimacy_partner_rsp"] = PersonSpaceSystem.agree_make_intimacy_partner_rsp; --同意搭档请求
s2c["refuse_make_intimacy_partner_rsp"] = PersonSpaceSystem.refuse_make_intimacy_partner_rsp; --拒绝搭档请求
s2c["release_intimacy_partner_rsp"] = PersonSpaceSystem.release_intimacy_partner_rsp; --强制解除亲密搭档关系
s2c["cancle_make_intimacy_partner_rsp"] = PersonSpaceSystem.cancle_make_intimacy_partner_rsp; --取消搭档请求

--relation: 0代所有关系  1，2，3，4代表各个关系（见配置）
--is_visible：true or false 开或者关
s2c["set_intimacy_relation_visible_rsp"] = PersonSpaceSystem.set_intimacy_relation_visible_rsp; --设置亲密关系可见

s2c["get_intimacy_relation_visible_rsp"] = PersonSpaceSystem.get_intimacy_relation_visible_rsp; --拉取自己的开关信息