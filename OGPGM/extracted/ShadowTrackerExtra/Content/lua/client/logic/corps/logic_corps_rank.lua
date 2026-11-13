--[[
	军团排行榜
--]]

CorpsRankSystem = CorpsRankSystem or {}

CorpsWeekRankList = nil
CorpsWeekUinToRank = {}
CorpsSeasonRankList = nil
CorpsSeasonUinToRank = {}

CorpsRankInfoList = {}

MyWeekRankInfo = nil
MySeasonRankInfo = nil

Is_Corps_Rank_Have_Award = false

CorpsRankAwardInfo = {}

CorpsRankAwardShowList = {}

function CorpsRankSystem.Init()
    CorpsRankSystem.ClearData()
end

function CorpsRankSystem.ClearData()
    CorpsWeekRankList = nil
    CorpsWeekUinToRank = {}
    CorpsSeasonRankList = nil
    CorpsSeasonUinToRank = {}

    CorpsRankInfoList = {}

end

function CorpsRankSystem.Release()
	CorpsRankSystem.ClearData()
end

function CorpsRankSystem.GetRankAwardCfg( rank_lvl )
    local award_config = Client.GetTable("CorpsRankAward");
    local temp = 99999
    local temp_v = nil
    for k,v in pairs(award_config) do
        if v and v.ID and v.RankMinLvl > 0 then
            if rank_lvl <= v.RankMinLvl and v.RankMinLvl < temp then
                temp = v.RankMinLvl
                temp_v = v
            end
        end
    end
    return temp_v
end

--请求排行榜uin信息
function CorpsRankSystem.SendGetWeekRankData()
    CorpsRankInfoList = {}
    if CorpsWeekRankList then
        EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_RANK_GET_UIN)
        return
    end

    local personZoneid = 1
    local strRegion = Client.GetPublishRegion()


    if strRegion == "JAPAN" or strRegion == "KOREA"  then
        personZoneid = 6
    else
        personZoneid = 1
    end
    log("CorpsRankSystem.SendGetWeekRankData")
    NetUtil.SendPriorityPkg(false, "get_topn_rank_rsp", "get_topn_rank", personZoneid, 101);

end
function CorpsRankSystem.SendGetSeasonRankData()
    CorpsRankInfoList = {}
    if CorpsSeasonRankList then
        EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_RANK_GET_UIN)
        return
    end

    local personZoneid = 1
    local strRegion = Client.GetPublishRegion()
    if strRegion == "KOREA" or strRegion == "JAPAN" then
        personZoneid = 6
    else
        personZoneid = 1
    end
    log("CorpsRankSystem.SendGetSeasonRankData")
    NetUtil.SendPriorityPkg(false, "get_topn_rank_rsp", "get_topn_rank", personZoneid, 102);
end

function CorpsRankSystem.OnGetRankData(ok, score_type, list)
    log("请求军团排行榜uin信息回包 score_type ="..score_type);
    log("------------------list =")
    --log_tree("CorpsRankSystem.OnGetRankData ret=", list)
    log("-------------------end")

    if score_type == 101 then
        CorpsWeekRankList = list
        --保存反向查询,服务端下发的uid一个是字符串一个是数字，只能转换下
        for i=1,100 do
            if CorpsWeekRankList[i] then
                CorpsWeekUinToRank[tonumber(CorpsWeekRankList[i].uid)] = i
            end
        end
    end

    if score_type == 102 then
        CorpsSeasonRankList = list
        --保存反向查询,服务端下发的uid一个是字符串一个是数字，只能转换下
        for i=1,100 do
            if CorpsSeasonRankList[i] then
                CorpsSeasonUinToRank[tonumber(CorpsSeasonRankList[i].uid)] = i
            end
        end
    end

    EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_RANK_GET_UIN);
end

--请求排行榜详情信息
function CorpsRankSystem.SendGetRankInfoData(begin_index, end_index, is_week)

    log("CorpsRankSystem.SendGetRankInfoData(begin_index, end_index, is_week)")
    log("begin_index = "..begin_index)
    log("end_index = "..end_index)
    if is_week then
        log("is_week true")
    else
        log("is_week false")
    end

    local corps_list = {}

    if is_week then
        log("周奖励")
        if CorpsWeekRankList then
            for i=begin_index,end_index do
                if CorpsWeekRankList[i] then
                    if not CorpsRankInfoList[tonumber(CorpsWeekRankList[i].uid)] then
                        corps_list[#corps_list + 1] = tonumber(CorpsWeekRankList[i].uid)
                    end
                end
            end
        end    
    else
        log("季度奖励")
        if CorpsSeasonRankList then
            for i=begin_index,end_index do
                if CorpsSeasonRankList[i] then
                    if not CorpsRankInfoList[tonumber(CorpsSeasonRankList[i].uid)] then
                        corps_list[#corps_list + 1] = tonumber(CorpsSeasonRankList[i].uid)
                    end
                end
            end
        end
    end

    if #corps_list < 1 then
        log("全部都在缓存里面，无需发送数据")
        EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_RANK_GET_INFO);
        return
    end

    --log_tree("请求军团排行榜详情信息 corps_list =", corps_list);

    NetUtil.SendPkg("query_corps_info_for_rank_req", corps_list);
end

function CorpsRankSystem.OnGetRankInfoData(ok, ret_list)
    log("请求军团排行榜详情信息回包");
    log("------------------list =")
    --log_tree("CorpsRankSystem.OnGetRankInfoData ret_list=", ret_list)
    log("-------------------end")

    for k,v in pairs(ret_list) do
        if v and v.corps_id then
            CorpsRankInfoList[tonumber(v.corps_id)] = v
        end
    end

    EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_RANK_GET_INFO);
end

--请求自己的排行信息
function CorpsRankSystem.SendGetMyRankData(rank_type)
    log("请求自己的排行信息 rank_type ="..rank_type);

    if not CorpsMgr.IsInCorps() then
        log("自己没有加入任何军团")
        return
    end

    log("自己的军团id ="..DataMgr.corpsInfo.id)

    local personZoneid = 1
    local strRegion = Client.GetPublishRegion()
    if strRegion == "KOREA" or strRegion == "JAPAN"then
        personZoneid = 6
    else
        personZoneid = 1
    end

    NetUtil.SendPriorityPkg(false, "get_one_user_rank_rsp", "get_one_user_rank", "corps_rank_info", personZoneid, DataMgr.corpsInfo.id, rank_type);
    CorpsRankSystem.SendIsGetAward()
end

function CorpsRankSystem.OnGetMyRankInfoData( client_data, ret, zone_id, rank_info)
    log("请求自己军团排行榜信息回包");
    log("------------------rank_info =")
    --log_tree("CorpsRankSystem.OnGetMyRankInfoData rank_info=", rank_info)
    log("-------------------end")

    log("client_data =="..client_data)

    if ret == 0 then

        if client_data == "corps_rank_info" then
            log("排行榜信息")
            
            --先请求的是周榜，有回包了再请求季度，否则服务端无法处理
            if rank_info.score_type == 101 then
                MyWeekRankInfo = rank_info
                CorpsRankSystem.SendGetMyRankData(102)
            elseif rank_info.score_type == 102 then
                MySeasonRankInfo = rank_info
                EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_RANK_GET_MY_INFO);
            end
        end
    else
        log("error ret ="..ret)
    end
end

--获得自己的周排行和季度排行信息
function CorpsRankSystem.GetMyRankInfo()
   return MyWeekRankInfo,MySeasonRankInfo
end

--获得自己的周奖励和季度奖励信息
function CorpsRankSystem.GetMyCorpsAwardInfo()
    if not CorpsMgr.IsInCorps() then
        log("自己没有加入任何军团")
        return
    end

    if MyWeekRankInfo == nil or MySeasonRankInfo == nil then
        log("error.. CorpsRankSystem.GetMyCorpsAwardInfo MyWeekRankInfo = nil")
        return
    end

    local award_config = Client.GetTable("CorpsRankAward");
    local rank_lvl = MyWeekRankInfo.rank_no
    local award_cfg = nil
    -- body
    if rank_lvl > 0 then
        --排行
        local temp = 99999
        local temp_v = nil
        for k,v in pairs(award_config) do
            if v and v.ID and v.RankMinLvl > 0 then
                if rank_lvl <= v.RankMinLvl and v.RankMinLvl < temp then
                    temp = v.RankMinLvl
                    temp_v = v
                end
            end
        end

        ----log_tree("CorpsRankSystem.GetRankAwardId temp_v====",temp_v)
        award_cfg = temp_v
    else
        --万分比
        rank_lvl = MyWeekRankInfo.rank_rate
        local temp = 99999
        local temp_v = nil
        for k,v in pairs(award_config) do
            if v and v.ID and v.RankMinLvl == 0 then
                if rank_lvl <= v.RankPerMinLvl and v.RankPerMinLvl < temp then
                    temp = v.RankPerMinLvl
                    temp_v = v
                end
            end
        end

        ----log_tree("CorpsRankSystem.GetRankAwardId 2 temp_v====",temp_v)
        award_cfg = temp_v
    end

    local rank_lvl2 = MySeasonRankInfo.rank_no
    local award_cfg2 = nil
    -- body
    if rank_lvl2 > 0 then
        --排行
        local temp = 99999
        local temp_v = nil
        for k,v in pairs(award_config) do
            if v and v.ID and v.RankMinLvl > 0 then
                if rank_lvl2 <= v.RankMinLvl and v.RankMinLvl < temp then
                    temp = v.RankMinLvl
                    temp_v = v
                end
            end
        end

        ----log_tree("CorpsRankSystem.GetRankAwardId temp_v2====",temp_v)
        award_cfg2 = temp_v
    else
        --万分比
        rank_lvl2 = MySeasonRankInfo.rank_rate
        local temp = 99999
        local temp_v = nil
        for k,v in pairs(award_config) do
            if v and v.ID and v.RankMinLvl == 0 then
                if rank_lvl2 <= v.RankPerMinLvl and v.RankPerMinLvl < temp then
                    temp = v.RankPerMinLvl
                    temp_v = v
                end
            end
        end

        ----log_tree("CorpsRankSystem.GetRankAwardId 2 temp_v2====",temp_v)
        award_cfg2 = temp_v
    end

    return award_cfg, award_cfg2

end


--查询是否有奖励可以领取
function CorpsRankSystem.SendIsGetAward()
    log("发送查询是否可以领奖协议")
    Is_Corps_Rank_Have_Award = false
    NetUtil.SendPkg("is_corps_rank_award_exist")
end
function CorpsRankSystem.OnGetIsGetAward(ret)
    log("查询是否可以领奖协议--回包 ret ="..ret)
    if ret == 1 then
        Is_Corps_Rank_Have_Award = true
    else
        Is_Corps_Rank_Have_Award = false
    end
    EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_APPLYLIST);
    UpdateLobbyCorpsRedDot(CorpsMgr.HasRedDot("lobby"))
end

--领取排行奖励
local last_send_award_type = 0
function CorpsRankSystem.SendGetRankAward(rank_type)
    log("领取排行奖励 rank_type ="..rank_type);

    if not CorpsMgr.IsInCorps() then
        log("自己没有加入任何军团")
        return
    end

    last_send_award_type = rank_type

    local personZoneid = 1
    local strRegion = Client.GetPublishRegion()
    if strRegion == "KOREA" or strRegion == "JAPAN" then
        personZoneid = 6
    else
        personZoneid = 1
    end

    NetUtil.SendPriorityPkg(false, "query_corps_rank_award_rsp", "query_corps_rank_award", personZoneid, rank_type);
end

function CorpsRankSystem.OnGetMyRankAwardData(ret, score_type, rank_info, other_info, award, err_cnt)
    log("领取排行奖励回包");
    log("ret ="..ret)
    err_cnt = err_cnt or 0
    log("err_cnt ="..err_cnt)
    if ret == 0 or (ret == 111324 and err_cnt < 2) then
        log("score_type ="..score_type)
        log("------------------rank_info =")
        --log_tree("CorpsRankSystem.OnGetMyRankAwardData rank_info=", rank_info)
        --log_tree("CorpsRankSystem.OnGetMyRankAwardData other_info=", other_info)
        --log_tree("CorpsRankSystem.OnGetMyRankAwardData award=", award)
        log("-------------------end")

        local award_info = {} 

        award_info.is_week = (score_type == 101)
        award_info.icon = DataMgr.corpsInfo.icon
        award_info.coprs_name = DataMgr.corpsInfo.name
        award_info.last_rank = rank_info.rank_no
        award_info.last_rank_per = rank_info.rank_rate
        award_info.last_activity = rank_info.score
        award_info.my_activity = other_info.self_active
        award_info.is_get_award = (ret == 0)

        if score_type == 101 then
            award_info.need_activity = CorpsMgr.GetConfigToNumber("CorpWeekAwardActiveMin")
        end
        if score_type == 102 then
            award_info.need_activity = CorpsMgr.GetConfigToNumber("CorpSeasonAwardActiveMin")
        end

        CorpsRankSystem.SendGetTopMemberInfo(other_info.top_active_list)

        award_info.award_id = 0
        award_info.award_num = 0

        for k,v in pairs(award) do
            if v and v > 0 then
                award_info.award_id = k
                award_info.award_num = v
            end
        end


        CorpsRankAwardShowList = {}
        if ret == 0 then
            for k,v in pairs(award) do
                if v and v > 0 then
                    table.insert(CorpsRankAwardShowList, {res_id = k,count = v})
                end
            end
        end
        -- CommonItemGetUI:ShowPanel(CorpsRankAwardShowList)
        --log_tree("CorpsRankSystem.OnGetMyRankAwardData award_info=", award_info)


        CorpsRankAwardInfo = award_info

        EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_RANK_GET_AWARD,score_type);
    else
        if last_send_award_type == 102 then
            CorpsRankSystem.SendGetRankAward(101)
        end
        --ShowNotice(ret)
    end
end

function CorpsRankSystem.SendGetTopMemberInfo( top_active_list )

    BP_STRUCT_Corps_Rank_Award_Member1_Info = {is_init = false,BP_STRUCT_BASE_INFO = {}}
    BP_STRUCT_Corps_Rank_Award_Member2_Info = {is_init = false,BP_STRUCT_BASE_INFO = {}}
    BP_STRUCT_Corps_Rank_Award_Member3_Info = {is_init = false,BP_STRUCT_BASE_INFO = {}}

    if #top_active_list < 1 then
        return
    end

    local uid_list = {}
    local uid_to_key = {}
    for k,v in ipairs(top_active_list) do
        uid_list[k] = tonumber(v)
        uid_to_key[uid_list[k]] = k
    end

    log("去获取玩家的详细数据")

    CorpsMgr.GetAvatarBaseInfo(uid_list, function(profileList)
        log("获取详细数据回包")
        ----log_tree("profileList =",profileList)
        for _,memberInfo in pairs(profileList) do
            if uid_to_key[tonumber(memberInfo.strUid)] == 1 then
                BP_STRUCT_Corps_Rank_Award_Member1_Info.BP_STRUCT_BASE_INFO = memberInfo
                BP_STRUCT_Corps_Rank_Award_Member1_Info.is_init = true
            elseif uid_to_key[tonumber(memberInfo.strUid)] == 2 then
                BP_STRUCT_Corps_Rank_Award_Member2_Info.BP_STRUCT_BASE_INFO = memberInfo
                BP_STRUCT_Corps_Rank_Award_Member2_Info.is_init = true
            elseif uid_to_key[tonumber(memberInfo.strUid)] == 3 then
                BP_STRUCT_Corps_Rank_Award_Member3_Info.BP_STRUCT_BASE_INFO = memberInfo
                BP_STRUCT_Corps_Rank_Award_Member3_Info.is_init = true
            end                
        end
        EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_TOP_MEMBERINFO)
    end)
    
end

s2c["query_corps_info_for_rank_rsp"] = CorpsRankSystem.OnGetRankInfoData;

s2c["query_corps_rank_award_rsp"] = CorpsRankSystem.OnGetMyRankAwardData;
s2c["is_corps_rank_award_exist"] = CorpsRankSystem.OnGetIsGetAward;

