local RoleInfoPopularitySystem =
{
    --看自己时
    TotalPopularity = 0, --总人气值
    PopularityContriList = {}, --人气值贡献列表
    PopularityRecentList = {}, --最近点赞榜

    GiftRecord = {},
    IsShowDetail = false,
    IsShowReddot = false,
    AddDevote = 0,

    CachedUid = {
        get_popularity = 0,
        get_popularity_devote_rank_profile = 0,
        get_popularity_last_trend_profile = 0,
    },

    CurrUid = 0,

    DevoteGiftType = { Gift1 = 1,},

    DevoteRank = {},
    LastTrend = {},

}

function RoleInfoPopularitySystem.enter(uid)
    RoleInfoPopularitySystem.CurrUid = uid
    --RoleInfoPopularitySystem.get_popularity_req(uid)
end

function RoleInfoPopularitySystem.leave()
    RoleInfoPopularitySystem.PopularityContriList = {}
    RoleInfoPopularitySystem.PopularityRecentList = {}
    RoleInfoPopularitySystem.TotalPopularity = 0

    RoleInfoPopularitySystem.CachedUid = {
        get_popularity = 0,
        get_popularity_devote_rank_profile = 0,
        get_popularity_last_trend_profile = 0,
    }

    RoleInfoPopularitySystem.DevoteRank = {}
    RoleInfoPopularitySystem.LastTrend = {}

    RoleInfoPopularitySystem.IsShowReddot = false
end

function RoleInfoPopularitySystem.get_popularity_req(uid)
    log("get_popularity_req:" .. tostring(uid))

    if RoleInfoPopularitySystem.CachedUid.get_popularity == tostring(uid) then
        EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_GET_POPULARITY_RSP);
    else
        -------------初始化--------------
        NetUtil.SendPriorityPkg(false, "get_popularity_rsp", "get_popularity_req", tonumber(uid))
    end
end

--gift_record {[type=1]={cur_devote_count = 1}},type代表送礼类型,cur_devote_count当前贡献次数
--is_show_detail      : 是否给当前玩家展示详情信息
--is_show_reddot      : 最近点赞榜是否展示红点,当为自己的时候,为true或者false,其他人为nil
function RoleInfoPopularitySystem.get_popularity_rsp(ok, uid, total_devote, gift_record, is_show_detail, is_show_reddot, devote_rank, last_trend)
    log("get_popularity_rsp - ok:" .. tostring(ok) .. ",uid:" .. tostring(uid) .. ",total_devote:" .. tostring(total_devote)
            .. ",is_show_detail:" .. tostring(is_show_detail) .. ",is_show_reddot:" .. tostring(is_show_reddot))

    if ok ~= 0 then
        return
    end

    log_tree("gift_record", gift_record)
    log_tree("devote_rank", devote_rank)
    log_tree("last_trend", last_trend)
    RoleInfoPopularitySystem.TotalPopularity = total_devote
    RoleInfoPopularitySystem.GiftRecord = gift_record or {}
    RoleInfoPopularitySystem.IsShowDetail = is_show_detail
    RoleInfoPopularitySystem.IsShowReddot = is_show_reddot or false
    RoleInfoPopularitySystem.DevoteRank = devote_rank
    RoleInfoPopularitySystem.LastTrend = last_trend


    RoleInfoPopularitySystem.CachedUid.get_popularity_last_trend_profile = 0
    RoleInfoPopularitySystem.CachedUid.get_popularity_devote_rank_profile = 0

    --RoleInfoPopularitySystem.DevoteRank = {[510016789] = {value = 0, last_devote_time = 0}}
    --table.insert(RoleInfoPopularitySystem.PopularityContriList, {gid = tostring(uid), devote = devoteInfo.value, last_devote_time = devoteInfo.last_devote_time})

    RoleInfoPopularitySystem.CachedUid.get_popularity = tostring(uid)


    EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_GET_POPULARITY_RSP);
end

function RoleInfoPopularitySystem.CheckCanDevote(giftType)
    if RoleInfoSystem.IsSelf() then
        return false
    end

    local GiftInfo = Client.GetTableData("PopularityGift", giftType)
    if not GiftInfo then
        return false
    end
    local devote_info = RoleInfoPopularitySystem.GiftRecord[giftType]
    if devote_info then
       return devote_info.count < GiftInfo.MaxDevote
    end
    return true
end

--获取人气值贡献榜profile
function RoleInfoPopularitySystem.get_popularity_devote_rank_profile(uid)

    log("get_popularity_devote_rank_profile:" .. tostring(uid))

    if RoleInfoPopularitySystem.CachedUid.get_popularity_devote_rank_profile == tostring(uid) then
        EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_GET_POPULARITY_DEVOTE_RANK_PROFILE);
        return
    end

    RoleInfoPopularitySystem.PopularityContriList = {}

    local gids = {}

    for uid, devoteInfo in pairs(RoleInfoPopularitySystem.DevoteRank) do
        table.insert(gids, tonumber(uid))

        if type(devoteInfo) == "number" then
            table.insert(RoleInfoPopularitySystem.PopularityContriList, {gid = tostring(uid), devote = devoteInfo})
        else
            table.insert(RoleInfoPopularitySystem.PopularityContriList, {gid = tostring(uid), devote = devoteInfo.value, last_devote_time = devoteInfo.last_devote_time})
        end
    end

    log_tree("RoleInfoPopularitySystem PopularityContriList", RoleInfoPopularitySystem.PopularityContriList)


    if #gids > 0 then
        --查找到对应的profile数据
        ProfileMgr.GetProfileList(gids, function(list)

            --log_tree("PersonSpaceSystem GetProfileList list", list)
            RoleInfoPopularitySystem.CachedUid.get_popularity_devote_rank_profile = tostring(uid)

            for j, currProfile in pairs(list) do
                for i, data in ipairs(RoleInfoPopularitySystem.PopularityContriList) do
                    if tonumber(data.gid) == tonumber(currProfile.uid) then
                        PersonSpaceSystem.AddProfileData(data, currProfile)
                    end
                end
            end


            if next(RoleInfoPopularitySystem.PopularityContriList) ~= nil then
                table.sort(RoleInfoPopularitySystem.PopularityContriList, function(a, b)
                    if a.devote == b.devote then
                        return (a.last_devote_time or 0) < (b.last_devote_time or 0)
                    end
                    return a.devote > b.devote
                end)
            end

            log_tree("RoleInfoPopularitySystem PopularityContriList profile", RoleInfoPopularitySystem.PopularityContriList)

            EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_GET_POPULARITY_DEVOTE_RANK_PROFILE);

        end , false)
    else
        EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_GET_POPULARITY_DEVOTE_RANK_PROFILE);
    end
end

--针对单个玩家的最近动态{[1]={uid=123, time=123}, [2]={uid=1234, time=1234}}
function RoleInfoPopularitySystem.get_popularity_last_trend_profile(uid)
    log("get_popularity_last_trend_profile:" .. tostring(uid))

    if RoleInfoPopularitySystem.CachedUid.get_popularity_last_trend_profile == tostring(uid) then
        EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_GET_POPULARITY_LAST_TREND_PROFILE);
        return
    end

    RoleInfoPopularitySystem.PopularityRecentList = {}

    local gids = {}

    for k,v in pairs(RoleInfoPopularitySystem.LastTrend) do
        table.insert(gids, tonumber(v.uid))
        table.insert(RoleInfoPopularitySystem.PopularityRecentList, {gid = tostring(v.uid), datetime = v.devote_time})
    end

    log_tree("RoleInfoPopularitySystem PopularityRecentList", RoleInfoPopularitySystem.PopularityRecentList)


    if #gids > 0 then
        --查找到对应的profile数据
        ProfileMgr.GetProfileList(gids, function(list)

            RoleInfoPopularitySystem.CachedUid.get_popularity_last_trend_profile = tostring(uid)

            --log_tree("PersonSpaceSystem GetProfileList list", list)
            for j, currProfile in pairs(list) do
                for i, data in ipairs(RoleInfoPopularitySystem.PopularityRecentList) do
                    if tonumber(data.gid) == tonumber(currProfile.uid) then
                        PersonSpaceSystem.AddProfileData(data, currProfile)
                    end
                end
            end

            if next(RoleInfoPopularitySystem.PopularityRecentList) ~= nil then
                table.sort(RoleInfoPopularitySystem.PopularityRecentList, function(a, b)
                    return a.datetime > b.datetime
                end)
            end

            log_tree("RoleInfoPopularitySystem PopularityRecentList profile", RoleInfoPopularitySystem.PopularityRecentList)

            EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_GET_POPULARITY_LAST_TREND_PROFILE);

        end , false)
    else
        EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_GET_POPULARITY_LAST_TREND_PROFILE);
    end

end

function RoleInfoPopularitySystem.show_popularity_detail_req(is_show)
    log("show_popularity_detail_req:" .. tostring(is_show))
    NetUtil.SendPriorityPkg(false, "show_popularity_detail_rsp", "show_popularity_detail_req", is_show)
end

function RoleInfoPopularitySystem.show_popularity_detail_rsp(ok, is_show)
    log("show_popularity_detail_rsp:" .. tostring(is_show))
    RoleInfoPopularitySystem.IsShowDetail = is_show
    EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_GET_POPULARITY_RSP);
end

function RoleInfoPopularitySystem.pspace_send_gift_req(uid, type)
    log("pspace_send_gift_req:" .. tostring(type))
    NetUtil.SendPriorityPkg(false, "pspace_send_gift_rsp", "pspace_send_gift_req", tonumber(uid), type)
end

function RoleInfoPopularitySystem.pspace_send_gift_rsp(ok, total_devote, add_devote, gift_record, devote_rank, last_trend)

    log("pspace_send_gift_rsp:ok" .. tostring(ok)..",total_devote" .. tostring(total_devote) .. ",add_devote:" .. tostring(add_devote))
    if ok ~= 0 then
        if ok == 700002 then
            DataMgr.ShowNoticeByID(502001)
        elseif ok == 540001 then
            DataMgr.ShowNoticeByID(9920020)
        elseif ok == 700001 then
            DataMgr.ShowNoticeByID(9920020)
        elseif ok == 540002 then
            DataMgr.ShowNoticeByID(540002)
        end
        return
    end

    RoleInfoPopularitySystem.GiftRecord = gift_record or {}
    RoleInfoPopularitySystem.TotalPopularity = total_devote
    RoleInfoPopularitySystem.AddDevote = add_devote
    RoleInfoPopularitySystem.DevoteRank = devote_rank
    RoleInfoPopularitySystem.LastTrend = last_trend

    RoleInfoPopularitySystem.CachedUid.get_popularity_last_trend_profile = 0
    RoleInfoPopularitySystem.CachedUid.get_popularity_devote_rank_profile = 0

    EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_PSPACE_SEND_GIFT_RSP);
end

function RoleInfoPopularitySystem.close_popularity_reddot_req()
    log("close_popularity_reddot_req")
    NetUtil.SendPriorityPkg(false, "close_popularity_reddot_rsp", "close_popularity_reddot_req")
end

function RoleInfoPopularitySystem.close_popularity_reddot_rsp(ok)
    log("close_popularity_reddot_rsp:")
    if ok ==0 then
        RoleInfoPopularitySystem.IsShowReddot = false
        EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_CLOSE_REDDOT_RSP);
    end
end


return RoleInfoPopularitySystem