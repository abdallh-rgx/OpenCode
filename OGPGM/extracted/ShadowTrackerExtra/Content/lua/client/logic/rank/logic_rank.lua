
--[[
 排行榜相关逻辑
profile = {
    uid   = 0,
    name  = "",
    level = 0,
    city  = "",
    gender = 0,
    rankdata = {
        total_rank_rating = 0,
        solo = {
            rank_rating = 0,    --总积分
            playtime = 0,       --生存时长
            win_rating = 0,     --生存积分
            kill_rating = 0,    --击败积分
            win_num = 0,        --总吃鸡数
            top10_count = 0,    --前十数
            win_ratio = 0,      --吃鸡率
            kill_num = 0,       --总击败数
            max_kill = 0,       --单局最高击败
            kd = 0,             --击败/淘汰
        },
        duo = {
            rank_rating = 0,    --总积分
            playtime = 0,       --生存时长
            win_rating = 0,     --生存积分
            kill_rating = 0,    --击败积分
            win_num = 0,        --总吃鸡数
            win_ratio = 0,      --胜率
            kill_num = 0,       --总击败数
            max_kill = 0,       --单局最高击败
            kd = 0,             --击败/淘汰
        },
        squad = {
            rank_rating = 0,    --总积分
            playtime = 0,       --生存时长
            win_rating = 0,     --生存积分
            kill_rating = 0,    --击败积分
            win_num = 0,        --总吃鸡数
            win_ratio = 0,      --胜率
            kill_num = 0,       --总击败数
            max_kill = 0,       --单局最高击败
            kd = 0,             --击败/淘汰
        },
        fppsolo = {
            rank_rating = 0,    --总积分
            playtime = 0,       --生存时长
            win_rating = 0,     --生存积分
            kill_rating = 0,    --击败积分
            win_num = 0,        --总吃鸡数
            top10_count = 0,    --前十数
            win_ratio = 0,      --吃鸡率
            kill_num = 0,       --总击败数
            max_kill = 0,       --单局最高击败
            kd = 0,             --击败/淘汰
        },
        fppduo = {
            rank_rating = 0,    --总积分
            playtime = 0,       --生存时长
            win_rating = 0,     --生存积分
            kill_rating = 0,    --击败积分
            win_num = 0,        --总吃鸡数
            win_ratio = 0,      --胜率
            kill_num = 0,       --总击败数
            max_kill = 0,       --单局最高击败
            kd = 0,             --击败/淘汰
        },
        fppsquad = {
            rank_rating = 0,    --总积分
            playtime = 0,       --生存时长
            win_rating = 0,     --生存积分
            kill_rating = 0,    --击败积分
            win_num = 0,        --总吃鸡数
            win_ratio = 0,      --胜率
            kill_num = 0,       --总击败数
            max_kill = 0,       --单局最高击败
            kd = 0,             --击败/淘汰
        },
    },
}
]]--



RankSystem = RankSystem or
{
    RankRoleInfoItem =
    {
        uid   = "",
        name  = "",
        nation = "",
        plat_name = "",
        url   = "",
        level = 0,
        city  = "",
        gender = 0,
		startup_type = 0,--启动类型
		qq_vip = 0,--qq会员

        upass = {
            is_buy = 0,
            uishow = false,
            level = 0,
            acc_score = 0,
            acc_update_time = 0,
        },
        alias = {
            id = 0,
            title = "",
            nation = "",
        },

        rankdata = {
            
        },
        
        allzonerankdata = {
            
        },

        segment_info = {
            [1] = 1,
            [2] = 1,
            [3] = 1,
            [4] = 1,
            [5] = 1,
            [6] = 1,
        },
        all_segment_info = {},
        cur_avatar_box_id = 0,
    },
	--排行榜
    RankInfoListItem =
    {
        no = 0,
        uid = "",
        score = 0,
        name = "",              --名称
        nation = "",            --国籍
        url = "",               --头像
        level = 0,              --等级
        city = "",              --地点
        gender = 0,             --性别
        content1 = "",
        content2 = "",
        content3 = "",
        is_buy = 0, --upass
        uishow = false, --upass
        segment = 0,            --段位
        cur_avatar_box_id = 0,  --头像框
		startup_type = 0,--启动类型
		qq_vip = 0,--qq会员
        aliasId = 0,
        aliasTitle = "",
        aliasNation = "",
    },
	RankInfoList = {},
    RankInfoSelf =
    {
        no = 0,
        uid = "",
        score = 0,
        name = "",              --名称
        url = "",               --头像
        level = 0,              --等级
        city = "",              --地点
        gender = 0,             --性别
        content1 = "",
        content2 = "",
        content3 = "",
        is_buy = 0, --upass
        uishow = false, --upass
        segment = 0,            --段位
        cur_avatar_box_id = 0,  --头像框
		startup_type = 0,--启动类型
		qq_vip = 0,--qq会员
        aliasId = 0,
        aliasTitle = "",
        aliasNation = "",
    },
    --sum总分榜 win胜利榜 beat击败榜 total综合榜 upass通行证榜
    RankSelectType = "sum";
    --single单人 double双人 team组队
    RankSelectMemberType = "single";
    --all全区 friend好友
    RankRegionType = "all";

    --total累计, week本周
    RankPeriodType = "total";

    RankFriendList = {},
    RankRoleInfo = {},
    RankRoleInfoSending = {},
    QueryRankRoleInfoByIdxFrom = 1,
    OnePageCount = 5,
    FriendRemark = {},
    DefaultScore = 1200,
    DefaultSegment = 101,

    Cached_Popularit_summary_rsp = {},
}
local ScoreType = {
    total_rating       = 1000, -- 综合总积分
    solo_total_rating  = 1001, -- 单排总积分
    solo_win_rating    = 1002, -- 单排胜利积分
    solo_kill_rating   = 1003, -- 单排击败积分
    duo_total_rating   = 2001, -- 双排总积分
    duo_win_rating     = 2002, -- 双排胜利积分
    duo_kill_rating    = 2003, -- 双排基本积分
    squad_total_rating = 3001, -- 四排总积分
    squad_win_rating   = 3002, -- 四排胜利积分
    squad_kill_rating  = 3003, -- 四排击败积分

    -- fpp
    fpp_total_rating       = 4000, -- 综合总积分

    fpp_solo_total_rating  = 4001, -- 单排总积分
    fpp_solo_win_rating    = 4002, -- 单排生存积分
    fpp_solo_kill_rating   = 4003, -- 单排击败积分

    fpp_duo_total_rating   = 5001, -- 双排总积分
    fpp_duo_win_rating     = 5002, -- 双排生存积分
    fpp_duo_kill_rating    = 5003, -- 双排击败积分

    fpp_squad_total_rating = 6001, -- 四排总积分
    fpp_squad_win_rating   = 6002, -- 四排生存积分
    fpp_squad_kill_rating  = 6003, -- 四排击败积分

    corps_week_rating  = 101, -- 军团周活跃榜
    corps_season_rating  = 102, -- 军团赛季活跃榜  

    unknown_pass_acc_score_rating = 99001, --通行证榜，此时zoneid = 0.. 0.7.0之前的版本
    --新的通行证排行榜，0.7.5版本开始使用
    unknown_pass_acc_score_rating_Global = 99002, --全球版（不含日韩）绝地通行证累计增加积分榜
    unknown_pass_acc_score_rating_KRJP = 99003,   --日韩绝地通行证累计增加积分榜

    popularity_total_rating = 72001,     --个人空间人气总榜
    popularity_weekly_rating = 72002,     --个人空间人气周榜

    pve_rating = 10001, --pve 排行榜

    --点赞榜，0.9.0版本开始使用
    like_rating = 71003,
}

local function scoretype2RankType(scoretype)
    local score_type_conv = {
        [ScoreType.total_rating      ] = {member_type = RankSystem.RankSelectMemberType, rank_type = "total"}, -- 综合总积分
        [ScoreType.solo_total_rating ] = {member_type = "single", rank_type = "sum"},   -- 单排总积分
        [ScoreType.solo_win_rating   ] = {member_type = "single", rank_type = "win"},   -- 单排胜利积分
        [ScoreType.solo_kill_rating  ] = {member_type = "single", rank_type = "beat"},  -- 单排击败积分
        [ScoreType.duo_total_rating  ] = {member_type = "double", rank_type = "sum"},   -- 双排总积分
        [ScoreType.duo_win_rating    ] = {member_type = "double", rank_type = "win"},   -- 双排胜利积分
        [ScoreType.duo_kill_rating   ] = {member_type = "double", rank_type = "beat"},  -- 双排基本积分
        [ScoreType.squad_total_rating] = {member_type = "team", rank_type = "sum"},     -- 四排总积分
        [ScoreType.squad_win_rating  ] = {member_type = "team", rank_type = "win"},     -- 四排胜利积分
        [ScoreType.squad_kill_rating ] = {member_type = "team", rank_type = "beat"},    -- 四排击败积分


        [ScoreType.fpp_total_rating      ] = {member_type = RankSystem.RankSelectMemberType, rank_type = "fpp_total"}, -- 综合总积分

        [ScoreType.fpp_solo_total_rating ] = {member_type = "single", rank_type = "fpp_sum"},   -- 单排总积分
        [ScoreType.fpp_solo_win_rating   ] = {member_type = "single", rank_type = "fpp_win"},   -- 单排胜利积分
        [ScoreType.fpp_solo_kill_rating  ] = {member_type = "single", rank_type = "fpp_beat"},  -- 单排击败积分

        [ScoreType.fpp_duo_total_rating  ] = {member_type = "double", rank_type = "fpp_sum"},   -- 双排总积分
        [ScoreType.fpp_duo_win_rating    ] = {member_type = "double", rank_type = "fpp_win"},   -- 双排胜利积分
        [ScoreType.fpp_duo_kill_rating   ] = {member_type = "double", rank_type = "fpp_beat"},  -- 双排基本积分

        [ScoreType.fpp_squad_total_rating] = {member_type = "team", rank_type = "fpp_sum"},     -- 四排总积分
        [ScoreType.fpp_squad_win_rating  ] = {member_type = "team", rank_type = "fpp_win"},     -- 四排胜利积分
        [ScoreType.fpp_squad_kill_rating ] = {member_type = "team", rank_type = "fpp_beat"},    -- 四排击败积分
        --upass没有子菜单
        [ScoreType.unknown_pass_acc_score_rating] = {member_type = RankSystem.RankSelectMemberType, rank_type = "upass"},
        [ScoreType.unknown_pass_acc_score_rating_Global] = {member_type = RankSystem.RankSelectMemberType, rank_type = "upass"},
        [ScoreType.unknown_pass_acc_score_rating_KRJP] = {member_type = RankSystem.RankSelectMemberType, rank_type = "upass"},
        --like没有子菜单
        [ScoreType.like_rating] = {member_type = RankSystem.RankSelectMemberType, rank_type = "like"},

        --人气值 total累计, week本周
        [ScoreType.popularity_total_rating] = {member_type = RankSystem.RankSelectMemberType, rank_type = "popularity", period_type = "total"},
        [ScoreType.popularity_weekly_rating] = {member_type = RankSystem.RankSelectMemberType, rank_type = "popularity", period_type = "week"},

        [ScoreType.pve_rating] = {member_type = RankSystem.RankSelectMemberType, rank_type = "pve"},
    };
    return score_type_conv[scoretype];
end

local function IsFilter(filterType, uid)
    if filterType == 1 then -- 过滤全球服的
        if FuncUtil.IsUidGlobal(uid) then
            return true;
        end
    elseif filterType == 2 then -- 过滤日韩服的
        if FuncUtil.IsUidJPKR(uid) then
            return true;
        end
    end
    return false;
end


local function RankType2scoretype(rank_type, member_type, period_type)

    if rank_type == "upass" then
        if FuncUtil.IsPlayerJPKR() then
            return ScoreType.unknown_pass_acc_score_rating_KRJP; --99003 日韩服
        else
            return ScoreType.unknown_pass_acc_score_rating_Global; --99002 全球服
        end
    end

    -- 点赞榜
    if rank_type == "like" then
        return ScoreType.like_rating; --71003
    end

    if rank_type == "popularity" then
        return period_type == "total" and ScoreType.popularity_total_rating or ScoreType.popularity_weekly_rating; --71003
    end

    if rank_type == "pve" then
        return ScoreType.pve_rating; --10001
    end

    local rank_type_conv = {
        sum = 1,
        win = 2,
        beat = 3,
        fpp_sum = 1,
        fpp_win = 2,
        fpp_beat = 3,
    };
    local member_type_conv = {
        single = 1000,
        double = 2000,
        team = 3000,
    };

    if (rank_type == "fpp_sum" or rank_type == "fpp_win" or rank_type == "fpp_beat") then
        member_type_conv = {
            single = 4000,
            double = 5000,
            team = 6000,
        };
    end

    if rank_type == "total" then
        return ScoreType.total_rating;
    end

    if rank_type == "fpp_total" then
        return ScoreType.fpp_total_rating;
    end

    local hn = member_type_conv[member_type];
    local ln = rank_type_conv[rank_type];
    return hn + ln;
end

--时间转字符串
function RankTimeToStringHHMMSS(tm)
    if type(tm) ~= "number" then
        return ""
    end
    tm = math.modf(tm)
    local months = math.modf(tm / (60*60*24*30))
    if months >= 1 then
		local days = math.modf(math.fmod(tm, 60*60*24*30) / (60*60*24))
        if days > 0 then
			--return string.format("%d月%d天", months, days)
			return string.format(Client.GetTableData("LocalizeRes",301150).TextValue, months, days)
		else
			--return string.format("%d月", months)
			return string.format(Client.GetTableData("LocalizeRes",301151).TextValue, months)
		end
    end
	local days = math.modf(tm / (60*60*24))
    if days >= 1 then
		local hours = math.modf(math.fmod(tm, 60*60*24) / (60*60))
		if hours > 0 then
			--return string.format("%d天%d小时", days, hours)
			return string.format(Client.GetTableData("LocalizeRes",301152).TextValue, days, hours)
		else
			--return string.format("%d天", days)
			return string.format(Client.GetTableData("LocalizeRes",301153).TextValue, days)
		end
    end
	local hours = math.modf(tm / (60*60))
    if hours >= 1 then
		local mins = math.modf(math.fmod(tm, 60*60) / 60)
		if mins > 0 then
			--return string.format("%d小时%d分", hours, mins)
			return string.format(Client.GetTableData("LocalizeRes",301154).TextValue, hours, mins)
		else
			--return string.format("%d小时", hours)
			return string.format(Client.GetTableData("LocalizeRes",301155).TextValue, hours)
		end
    end
	local mins = math.modf(tm / 60)
	local last_tm = math.fmod(tm, 60)
    if mins >= 1 then
        --return string.format("%d分", mins)
		return string.format(Client.GetTableData("LocalizeRes",301156).TextValue, mins)
    end
    --return string.format("%d秒", last_tm)
	return string.format(Client.GetTableData("LocalizeRes",301157).TextValue, last_tm)
end

--积分四舍五入
local function RankSorceInt(score)
    return math.floor(score+0.5)
end

function RankSystem.Enter()
	--log("RankSystem enter");
    
    RankSystem.RankInfoList = {};
    
    --这里应该加入自己的信息
    RankSystem.RankRoleInfo = {};
    RankSystem.RankRoleInfoSending = {};
    RankSystem.OnePageCount = 5;
    
    --log_tree("DataMgr.roleData=", DataMgr.roleData);
    local selfRole = FuncUtil:CopyTable(RankSystem.RankRoleInfoItem);
    selfRole.uid = tostring(DataMgr.roleData.uid);
    selfRole.name = DataMgr.roleData.nickName;
    selfRole.nation = DataMgr.roleData.nation;
    selfRole.url = DataMgr.roleData.headIconUrl;
    selfRole.level = DataMgr.roleData.level;
    selfRole.gender = DataMgr.roleData.gender;
    selfRole.cur_avatar_box_id = DataMgr.roleData.cur_avatar_box_id;
	selfRole.startup_type = BP_StartUpType;
	selfRole.qq_vip = DataMgr.roleData.qq_vip;
    --log_tree("selfRole=", selfRole)
    RankSystem.RankRoleInfo[selfRole.uid] = selfRole;
    RankSystem.RankInfoSelf.uid = tostring(DataMgr.roleData.uid);
    --log("BP_Back_ShowRankZoneId = "..BP_Back_ShowRankZoneId);
    --RankSystem.UpdateRankSelf(BP_Back_ShowRankZoneId);
    --这里还缺rankdata，先拉取一下
    ProfileMgr.GetRankProfileList({tonumber(DataMgr.roleData.uid)}, RankSystem.RspRankRoleInfo)
    
    RankSystem.RankFriendList = {};
    
    --获得好友备注
    RankSystem.FriendRemark = {}
    for i,v in ipairs(BP_ARRAY_All_Friend_Profile) do
        if v.remarks_name ~= "" then
            RankSystem.FriendRemark[v.gid] = v.remarks_name
        end
    end


    RankSystem.Cached_Popularit_summary_rsp = {}
end

function RankSystem.Release()

	--log("RankSystem enter");
    RankSystem.RankInfoList = {};
    --这里应该加入自己的信息
    RankSystem.RankRoleInfo = {};
    RankSystem.RankRoleInfoSending = {};
    RankSystem.RankFriendList = {};
    RankSystem.FriendRemark = {}

    RankSystem.Cached_Popularit_summary_rsp = {}
end

function RankSystem.AddTestRank()
    
end

--计算排行榜 前xx.xx%
function RankSystem.calc_topn_percentage(score, top_1w_score, rank_type, rankNo)
    log_tree("RankSystem.calc_topn_percentage", {score, top_1w_score, rank_type})
    
    log("RankSystem.calc_topn_percentage top_1w_score:"..tostring(top_1w_score));

    if top_1w_score == nil then
        return tostring(Client.GetTableData("LocalizeRes", 102127).TextValue);
    end
  
    --解决没有1W人上榜的时候排行不显示
    if rankNo > 0 and rankNo <= 10000 then
        return tostring(rankNo);
    end

    if rank_type == "upass" then
        -- upass榜潜规则，不处理
    else
        if top_1w_score <= score then
            return tostring(Client.GetTableData("LocalizeRes", 102127).TextValue);
        end
    end
	
    local middle_score = 0
	if rank_type == "upass" then
		--upass排名计算公式
		middle_score = score / top_1w_score * 5 - 1;
	elseif rank_type == "win" or rank_type == "beat" then
        middle_score = ((score - 900) / (top_1w_score - 900)) * 5 - 1;
    else
        middle_score = ((score - 1080) / (top_1w_score - 1080)) * 5 - 1;
    end
    local percentage = 1 - math.max(math.min(((1 / (1 + math.exp(-0.65 * middle_score)) - 0.5) * 1.72 + 0.2585), 1), 0);
    --return string.format("前%.2f%%", percentage * 100);
    return string.format(tostring(Client.GetTableData("LocalizeRes", 108036).TextValue), percentage * 100);
end

--请求拉取排行榜
function RankSystem.ReqFetchRankData(bQueryFriend, zoneId)
    log("RankSystem.ReqFetchRankData zoneid = "..zoneId..", bQueryFriend = "..tostring(bQueryFriend))
    if RankSystem.RankRegionType == "friend" then
        if bQueryFriend then
            if RankSystem.RankSelectType == "popularity" then
                RankSystem.batch_get_popularit_summary_req()
            else
                RankSystem.ReqFriendRankRole(zoneId);
            end
        else
            RankSystem.UpdateFriendRankRole(zoneId);
        end
    else
        local st = RankType2scoretype(RankSystem.RankSelectType, RankSystem.RankSelectMemberType, RankSystem.RankPeriodType);
        -- log_tree("RankSystem.ReqFetchRankData", st);

        if RankSystem.RankSelectType == "upass" or RankSystem.RankSelectType == "like" or RankSystem.RankSelectType == "pve" or RankSystem.RankSelectType == "popularity" then
            zoneId = 0
        end

        NetUtil.SendPriorityPkg(false, "get_topn_rank_rsp", "get_topn_rank", zoneId, st);
         --自己的
        NetUtil.SendPkg("get_one_user_rank", "rank", zoneId, 0, st);

        if RankSystem.RankSelectType == "popularity" then
            RankSystem.get_self_popularit_summary_req()
        end

    end
end

--返回拉取排行榜
function RankSystem.RspFetchRankData(ok, zone_id, score_type, list)
    log_tree("RankSystem.RspFetchRankData ret=", {ok, zone_id, score_type, list})

    --军团排行相关
    if score_type == 101 or score_type == 102 then
        CorpsRankSystem.OnGetRankData(ok, score_type, list)
        return
    end

    if ok == 0 then
        local st = scoretype2RankType(score_type)
        RankSystem.RankRegionType = "all";
        RankSystem.RankSelectType = st.rank_type
        RankSystem.RankSelectMemberType = st.member_type
        RankSystem.RankPeriodType = st.period_type or "total"

        RankSystem.RankInfoList = {};
        if list == nil then
            list = {}
        end
        for i,v in ipairs(list) do
            local itm = FuncUtil:CopyTable(RankSystem.RankInfoListItem)
            itm.no = v.rank_no
            itm.uid = tostring(v.uid)
            itm.score = v.score
            RankSystem.UpdateRankRole(itm, v.uid, zone_id)
            itm.score = RankSorceInt(itm.score)
            table.insert(RankSystem.RankInfoList, itm)
        end

        EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_RANK_UPDATE_LIST)
        if RankSystem.RankSelectType == "upass" then
            EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_RANK_UPDATE_LIST);
        end
    else
        RankSystem.RankInfoList = {};
        EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_RANK_UPDATE_LIST)
        if RankSystem.RankSelectType == "upass" then
            EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_RANK_UPDATE_LIST);
        end
    end

    --score_type的意义参考ScoreType
    --Client.StopUIStat("排行榜—" .. scoretype2RankType(score_type))排行榜-子页签
    Client.StopUIStat("排行榜-子页签")
end

--返回自己的排行榜
function RankSystem.RspFetchSelfRankData(client_data,  ok, zoneId, rank_info)
    if client_data == "rank" then
        log("client_data = "..client_data ..", ok="..ok..", zoneId = "..zoneId)
        log_tree("wayne rank_info=", rank_info)
        if ok == 0 then
            if rank_info.rank_no == nil then
                RankSystem.RankInfoSelf.no = 0;
                RankSystem.RankInfoSelf.score = 0;
            else
                RankSystem.RankInfoSelf.no = rank_info.rank_no;
                RankSystem.RankInfoSelf.score = rank_info.score;
            end

            RankSystem.RankInfoSelf.top1w = rank_info.top1w

            RankSystem.RankInfoSelf.score = RankSorceInt(RankSystem.RankInfoSelf.score)
            RankSystem.UpdateRankRole(RankSystem.RankInfoSelf, tostring(DataMgr.roleData.uid), zoneId);

            log("RankSystem.RankInfoSelf.score "..tostring(RankSystem.RankInfoSelf.score))

			local rankNo = RankSystem.RankInfoSelf.no
			local score = RankSystem.RankInfoSelf.score
			local top_1w_score = rank_info.top1w
			local rank_type = RankSystem.RankSelectType
            -- 潜规则，因为RankSystem.RankInfoSelf.score被改为upass.level了
            if rank_type == "upass" then
                --score = rank_info.score or 0;
                if RankSystem.RankRoleInfo[DataMgr.roleData.uid] ~= nil then
                    score = RankSystem.RankRoleInfo[DataMgr.roleData.uid].upass.acc_score;
                end
                UnknowPassRankSystem.top_1w_score = top_1w_score;
            end
            --log("rank_type =" .. rank_type)
            --log("score = "..score ..", top_1w_score="..top_1w_score..", rankNo = "..rankNo)
            BP_RankInfoSelfBelow1wDisplay = RankSystem.calc_topn_percentage(score, top_1w_score, rank_type, rankNo)
            log("BP_RankInfoSelfBelow1wDisplay:"..tostring(BP_RankInfoSelfBelow1wDisplay));
            EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_RANK_UPDATE_SELF);
            if RankSystem.RankSelectType == "upass" then
                EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_RANK_UPDATE_SELF);
            end
        else
            RankSystem.RankInfoSelf.no = 0;
            RankSystem.RankInfoSelf.score = 0;
            RankSystem.UpdateRankRole(RankSystem.RankInfoSelf, tostring(DataMgr.roleData.uid), zoneId);
            EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_RANK_UPDATE_SELF);
            if RankSystem.RankSelectType == "upass" then
                EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_RANK_UPDATE_SELF);
            end
        end
    end
end

function RankSystem.QueryRankRoleInfoByScroll()
    local listUid = {}
    local pageidx = math.modf(RankSystem.QueryRankRoleInfoByIdxFrom / RankSystem.OnePageCount)
    for i=pageidx-1,pageidx+2 do
        for j=1,RankSystem.OnePageCount do
            local idx = i*RankSystem.OnePageCount + j
            local itm = RankSystem.RankInfoList[idx]
            if itm then
                local role = RankSystem.RankRoleInfo[itm.uid];
                if role == nil then
                    local curtm = os.time();
                    local tm = RankSystem.RankRoleInfoSending[itm.uid];
                    if tm == nil or (curtm - tm > 30) then
                        RankSystem.RankRoleInfoSending[itm.uid] = curtm;
                        table.insert(listUid, tonumber(itm.uid));
                    end
                end
            end
            
        end
    end
    if #listUid > 0 then
        ProfileMgr.GetRankProfileList(listUid, RankSystem.RspRankRoleInfo)
    end
end

function RankSystem.RspRankRoleInfo(profileList)

    --log_tree("RankSystem.RspRankRoleInfo profileList", profileList)
    if type(profileList) ~= "table" then
        return
    end
    local list = {}
    for i,v in ipairs(profileList) do
        list[v.uid] = v
    end
    for k,v in pairs(list) do
        local role = FuncUtil:CopyTable(RankSystem.RankRoleInfoItem)
        role.uid = tostring(k)
        role.name  = v.nickName
        role.nation = v.nation

        --upass
        role.upass.level = v.upass.level
        role.upass.acc_score = v.upass.acc_score
        role.upass.acc_update_time = v.upass.acc_update_time
        role.upass.uishow = v.upass.switch.ui
        role.upass.is_buy = v.upass.is_buy
        role.alias.id = v.alias.id
        role.alias.title = v.alias.title
        role.alias.nation = v.alias.nation;
        role.upvote = v.upvote or 0

        role.pve_level= v.pve_level or 1

        --平台名
        if type(v.platName) == "string" and v.platName ~= "" then
            role.plat_name = v.platName
        else
            role.plat_name = ""
        end
        --备注名
        local remark = RankSystem.FriendRemark[tonumber(role.uid)]
        if remark then
            role.plat_name = remark
        end
        role.url   = v.picUrl
        role.level = v.level
        role.city  = ""
        role.gender = v.sex
        if v.startup_type ~= nil then
            role.startup_type = v.startup_type
        end
        if v.qq_vip ~= nil then
            role.qq_vip = v.qq_vip
        end
        
        -------------------------------intl modify----------------------------------
        --[[
        if type(v.rankdata) == "table" then
            role.rankdata = FuncUtil:CopyTable(v.rankdata)
        end
        if type(v.segment_info) == "table" then
            for i1,v1 in ipairs(role.segment_info) do
                local n = v.segment_info[i1]
                if type(n) == "number" then
                    role.segment_info[i1] = n
                end
            end
        end
        ]]
       --记录所有区排行榜数据
       role.allzonerankdata = v.rankdata;
       -- 选当前区的排行信息
        if type(v.rankdata) == "table" then
            if v.rankdata[BP_Back_ShowRankZoneId] ~= nil then
                role.rankdata = FuncUtil:CopyTable(v.rankdata[BP_Back_ShowRankZoneId])
            end
        end
        -- 选当前区的段位信息
        role.all_segment_info =v.segment_info;
        cur_zone_segment_info = role.all_segment_info[BP_Back_ShowRankZoneId];
        if cur_zone_segment_info ~= nil then
             for i1,v1 in ipairs(role.segment_info) do
                    role.segment_info[i1] = cur_zone_segment_info[i1]
             end
        end
        
        --log_tree("RankSystem.RspRankRoleInfo Role = " , role)
        -------------------------------intl modify----------------------------------
        if type(v.cur_avatar_box_id) == "number" then
            role.cur_avatar_box_id = v.cur_avatar_box_id
        end
        RankSystem.RankRoleInfo[role.uid] = role
        RankSystem.RankRoleInfoSending[role.uid] = nil
    end
    for i,v in ipairs(RankSystem.RankInfoList) do
        if list[tonumber(v.uid)] then
            RankSystem.UpdateRankRole(v, v.uid, BP_Back_ShowRankZoneId)
            EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_RANK_UPDATE_ITEM, v)
            if RankSystem.RankSelectType == "upass" then
                EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_RANK_UPDATE_ITEM, v);
            end
        end
    end
    for k,v in pairs(list) do
        if tostring(DataMgr.roleData.uid) == tostring(k) then
            log("RspRankRoleInfo EVENTID_RANK_UPDATE_SELF")
            RankSystem.UpdateRankSelf(BP_Back_ShowRankZoneId)
            break
        end
    end
end

function RankSystem.IsFpp()
    return RankSystem.RankSelectType == "fpp_sum" or RankSystem.RankSelectType == "fpp_win" or RankSystem.RankSelectType == "fpp_beat" or RankSystem.RankSelectType == "fpp_total";
end

function RankSystem.UpdateRankRole(itm, uid, zoneId)
    log("RankSystem.UpdateRankRole:uid:" .. uid .. ",zoneId:" .. zoneId)
    --log_tree("RankSystem.RankRoleInfo", RankSystem.RankRoleInfo);
    local role = RankSystem.RankRoleInfo[uid];
    if role == nil then
        if RankSystem.RankSelectType == "upass" then
            itm.content3 = "-"
            itm.content1 = "-"
            itm.score = 0 --score是int类型，所以需要在蓝图里面判断后将其置为“-”
         end
        return false
    end
    -- if RankSystem.RankRegionType == "friend" and 
    --     role.plat_name ~= "" and 
    --     tostring(DataMgr.roleData.uid) ~= tostring(uid) then
    --     itm.name = string.format("%s(%s)", role.name, role.plat_name)
    -- else
    --     itm.name = role.name
    -- end ---不用显示平台的名字
    itm.name = role.name
    itm.url = role.url
    itm.level = role.level
    itm.nation = role.nation
    itm.city = role.city
    itm.gender = role.gender
	itm.startup_type = role.startup_type
	itm.qq_vip = role.qq_vip
    itm.content1 = ""
    itm.content2 = ""
    itm.content3 = ""

    itm.uishow = role.upass.uishow --upass
    itm.is_buy = role.upass.is_buy --upass
    itm.aliasId = role.alias.id
    itm.aliasTitle = role.alias.title
    itm.aliasNation = role.alias.nation

    itm.segment = 1
    itm.cur_avatar_box_id = role.cur_avatar_box_id
    role.segment_info = role.all_segment_info[zoneId];
    local mt = nil

    local zonerankdata = role.allzonerankdata[zoneId]

    if role.allzonerankdata[zoneId] and role.segment_info then
        if (RankSystem.IsFpp() == false) then
            if RankSystem.RankSelectMemberType == "single" then
                mt = zonerankdata.solo
                itm.segment = role.segment_info[1]
            elseif RankSystem.RankSelectMemberType == "double" then
                mt = zonerankdata.duo
                itm.segment = role.segment_info[2]
            elseif RankSystem.RankSelectMemberType == "team" then
                mt = zonerankdata.squad
                itm.segment = role.segment_info[3]
            end
            if mt then
                if RankSystem.RankSelectType == "sum" then
                    itm.content1 = RankTimeToStringHHMMSS(mt.playtime)
                    itm.content2 = tostring(RankSorceInt(mt.win_rating))
                    itm.content3 = tostring(RankSorceInt(mt.kill_rating))
                elseif RankSystem.RankSelectType == "win" then
                    itm.content1 = tostring(mt.win_num)
                    itm.content2 = tostring(mt.top10_count)
                    itm.content3 = string.format("%.2f%%", mt.win_ratio*100)
                elseif RankSystem.RankSelectType == "beat" then
                    itm.content1 = tostring(mt.kill_num)
                    itm.content2 = tostring(mt.max_kill)
                    itm.content3 = string.format("%.2f", mt.kd)
                end
            end
        else
             if RankSystem.RankSelectMemberType == "single" then
                mt = zonerankdata.fppsolo;
                itm.segment = role.segment_info[4];
            elseif RankSystem.RankSelectMemberType == "double" then
                mt = zonerankdata.fppduo;
                itm.segment = role.segment_info[5];
            elseif RankSystem.RankSelectMemberType == "team" then
                mt = zonerankdata.fppsquad
                itm.segment = role.segment_info[6];
            end
            
            if RankSystem.RankSelectType == "fpp_sum" then
                itm.content1 = mt == nil and "0秒" or RankTimeToStringHHMMSS(mt.playtime)
                itm.content2 = mt == nil and "0" or tostring(RankSorceInt(mt.win_rating))
                itm.content3 = mt == nil and "0" or tostring(RankSorceInt(mt.kill_rating))
            elseif RankSystem.RankSelectType == "fpp_win" then
                itm.content1 = mt == nil and "0" or tostring(mt.win_num)
                itm.content2 = mt == nil and "0" or tostring(mt.top10_count)
                itm.content3 = mt == nil and "0.00%" or string.format("%.2f%%", mt.win_ratio*100)
            elseif RankSystem.RankSelectType == "fpp_beat" then
                itm.content1 = mt == nil and "0" or tostring(mt.kill_num)
                itm.content2 = mt == nil and "0" or tostring(mt.max_kill)
                itm.content3 = mt == nil and "0.00" or string.format("%.2f", mt.kd)
            end
            
        end
        if RankSystem.RankSelectType == "total" then
            itm.content1 = tostring(RankSorceInt(zonerankdata.solo.rank_rating))
            itm.content2 = tostring(RankSorceInt(zonerankdata.duo.rank_rating))
            itm.content3 = tostring(RankSorceInt(zonerankdata.squad.rank_rating))
            --取最高段位
            --local tmp = FuncUtil:CopyTable(role.segment_info)
            --table.sort(tmp, function(a,b) return a > b end)
            --itm.segment = tmp[1]
            itm.segment = math.max(role.segment_info[1], role.segment_info[2], role.segment_info[3]);
        end

        if RankSystem.RankSelectType == "fpp_total" then
            itm.content1 = zonerankdata.fppsolo == nil and tostring(RankSystem.DefaultScore) or tostring(RankSorceInt(zonerankdata.fppsolo.rank_rating))
            itm.content2 = zonerankdata.fppduo == nil and tostring(RankSystem.DefaultScore) or tostring(RankSorceInt(zonerankdata.fppduo.rank_rating))
            itm.content3 = zonerankdata.fppsquad == nil and tostring(RankSystem.DefaultScore) or tostring(RankSorceInt(zonerankdata.fppsquad.rank_rating))
            --取最高段位
            --local tmp = FuncUtil:CopyTable(role.segment_info)
            --table.sort(tmp, function(a,b) return a > b end)
            --itm.segment = tmp[1]
            if (role.segment_info[4] ~= nil and role.segment_info[5] ~= nil and role.segment_info[6] ~= nil) then
                itm.segment = math.max(role.segment_info[4], role.segment_info[5], role.segment_info[6]);
            else
                itm.segment = RankSystem.DefaultSegment;
            end
        end

        --未上榜读取自己的分数
        if itm.no == 0 then
            itm.score = zonerankdata.total_rank_rating

            if RankSystem.RankSelectMemberType == "single" then
                if RankSystem.RankSelectType == "sum" then
                    itm.score = zonerankdata.solo.rank_rating
                elseif RankSystem.RankSelectType == "win" then
                    itm.score = zonerankdata.solo.win_rating
                elseif RankSystem.RankSelectType == "beat" then
                    itm.score = zonerankdata.solo.kill_rating
                end

                if RankSystem.RankSelectType == "fpp_sum" then
                    itm.score = zonerankdata.fppsolo and zonerankdata.fppsolo.rank_rating or  0; --    .fpp_rank_rating
                elseif RankSystem.RankSelectType == "fpp_win" then
                    itm.score = zonerankdata.fppsolo and zonerankdata.fppsolo.win_rating or 0;
                elseif RankSystem.RankSelectType == "fpp_beat" then
                    itm.score = zonerankdata.fppsolo and zonerankdata.fppsolo.kill_rating or 0;
                end

            elseif RankSystem.RankSelectMemberType == "double" then
                if RankSystem.RankSelectType == "sum" then
                    itm.score = zonerankdata.duo.rank_rating
                elseif RankSystem.RankSelectType == "win" then
                    itm.score = zonerankdata.duo.win_rating
                elseif RankSystem.RankSelectType == "beat" then
                    itm.score = zonerankdata.duo.kill_rating
                end

                if RankSystem.RankSelectType == "fpp_sum" then
                    itm.score = zonerankdata.fppduo and zonerankdata.fppduo.rank_rating or 0;
                elseif RankSystem.RankSelectType == "fpp_win" then
                    itm.score = zonerankdata.fppduo and zonerankdata.fppduo.win_rating or 0;
                elseif RankSystem.RankSelectType == "fpp_beat" then
                    itm.score = zonerankdata.fppduo and zonerankdata.fppduo.fpp_kill_rating or 0;
                end

            elseif RankSystem.RankSelectMemberType == "team" then
                if RankSystem.RankSelectType == "sum" then
                    itm.score = zonerankdata.squad.rank_rating
                elseif RankSystem.RankSelectType == "win" then
                    itm.score = zonerankdata.squad.win_rating
                elseif RankSystem.RankSelectType == "beat" then
                    itm.score = zonerankdata.squad.kill_rating
                end

                if RankSystem.RankSelectType == "fpp_sum" then
                    itm.score = zonerankdata.fppsquad and zonerankdata.fppsquad.rank_rating or 0;
                elseif RankSystem.RankSelectType == "fpp_win" then
                    itm.score = zonerankdata.fppsquad and zonerankdata.fppsquad.win_rating or 0;
                elseif RankSystem.RankSelectType == "fpp_beat" then
                    itm.score = zonerankdata.fppsquad and zonerankdata.fppsquad.kill_rating or 0;
                end
            end

            itm.score = RankSorceInt(itm.score)
        end
    end

    --upass 通行证只有三列数据，为统一，content2不显示
    if RankSystem.RankSelectType == "upass" then
        if role.upass.acc_update_time == 0 then
            itm.score = 0 --score是int类型，所以需要在蓝图里面判断后将其置为“-”
            itm.content3 = "-"
            itm.content1 = "-"
        else
            itm.score = role.upass.level --通行证排行榜，score为等级数
            itm.content3 = tostring(role.upass.acc_score)
            --local timezone = Client.GetLocalTimezone(); 
            --local currentTime = os.date("%m-%d-%Y", role.upass.acc_update_time + timezone / 100 * 60 * 60);
            local currentTime = os.date("%m-%d-%Y", role.upass.acc_update_time);
            itm.content1 = tostring(currentTime);
        end
    end

    if RankSystem.RankSelectType == "pve" then
        itm.score = role.pve_level or 1
    end

    if RankSystem.RankSelectType == "upass" or RankSystem.RankSelectType == "like"
            or RankSystem.RankSelectType == "popularity" then
        --通行证需要取所有段位的最高段位，不分模式和地区
        itm.segment = RankSystem.DefaultSegment;
        if role.all_segment_info then
            for _, v in ipairs(role.all_segment_info) do
                for i, seg in ipairs(v) do
                    if seg > itm.segment then
                        itm.segment = seg
                    end
                end
            end
        end
    end

    if RankSystem.RankSelectType == "like" then
        itm.score = role.upvote
    end

    --人气值不存储在RankData中,走自己的缓存
    if RankSystem.RankSelectType == "popularity" then
        local popularit = RankSystem.Cached_Popularit_summary_rsp[tonumber(uid)]
        log_tree("Cached_Popularit_summary_rsp", popularit)
        if popularit then
            if RankSystem.RankPeriodType == "total" then
                itm.score = popularit.total_devote or 0;
            else
                itm.score = popularit.last_week_devote or 0;
            end
        end
    end

    return true
end

function RankSystem.UpdateRankSelf(zoneId)
    RankSystem.UpdateRankRole(RankSystem.RankInfoSelf, tostring(DataMgr.roleData.uid), zoneId);
    EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_RANK_UPDATE_SELF);
    if RankSystem.RankSelectType == "upass" then
        EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_RANK_UPDATE_SELF);
    end
end

function RankSystem.ReqFriendRankRole(zoneid)
    --获得好友列表
    local tmp = {};
    --log_tree("ID_PLAT_FRIENDLIST", ID_PLAT_FRIENDLIST);
    --log_tree("ID_INNER_FRIENDLIST", ID_INNER_FRIENDLIST);
    --去重
    for i,v in ipairs(ID_PLAT_FRIENDLIST) do
        tmp[v] = 1;
    end
    for i,v in ipairs(ID_INNER_FRIENDLIST) do
        tmp[v] = 1;
    end
    local filterType = 0; --无过滤
    if RankSystem.RankSelectType == "upass" then
        if FuncUtil.IsPlayerJPKR() then
            filterType = 1; --过滤全球服的
        else
            filterType = 2; --过滤日韩服的
        end
    end
    local lstFriendUid = {};
    table.insert(lstFriendUid, tonumber(DataMgr.roleData.uid));
    for uid,v in pairs(tmp) do
        if not IsFilter(filterType, uid) then
            table.insert(lstFriendUid, tonumber(uid));
            if #lstFriendUid >= 100 then
                --log_tree("lstFriendUid=", lstFriendUid)
                NetUtil.SendPriorityPkg(false, "get_friend_rank_rsp", "get_friend_rank", zoneid, lstFriendUid);
                lstFriendUid = {};
            end
        end
    end
    --请求好友排行榜
    if #lstFriendUid > 0 then
        --log_tree("lstFriendUid=", lstFriendUid)
        NetUtil.SendPriorityPkg(false, "get_friend_rank_rsp", "get_friend_rank", zoneid, lstFriendUid);
    end
    RankSystem.RankFriendList = {};
end

function RankSystem.RspFriendRankRole(ok, zoneid, list)
    --log_tree("get_friend_rank_rsp ok=", ok)
    --log_tree("get_friend_rank_rsp list=", list)
    log("RankSystem.RspFriendRankRole zoneid = "..zoneid)
    if ok == 0 then
        for k,v in pairs(list) do
            RankSystem.RankFriendList[k] = v;
        end
        RankSystem.UpdateFriendRankRole(zoneid);
    end
    --log_tree("RankSystem.RankFriendList", RankSystem.RankFriendList)
end

function RankSystem.UpdateFriendRankRole(zoneId)
    log("RankSystem.UpdateFriendRankRole，zoneId= "..zoneId)
    RankSystem.RankRegionType = "friend";
    RankSystem.RankInfoList = {};
    RankSystem.RankInfoSelf.no = 0;
    RankSystem.RankInfoSelf.score = 0;
    for k,v in pairs(RankSystem.RankFriendList) do
        local itm = FuncUtil:CopyTable(RankSystem.RankInfoListItem)
        itm.uid = tostring(k);
        itm.score = v.total_rank_rating;
        if RankSystem.RankSelectMemberType == "single" then
            if RankSystem.RankSelectType == "sum" then
                itm.score = v.solo_rank_rating;
            elseif RankSystem.RankSelectType == "win" then
                itm.score = v.solo_win_rating;
            elseif RankSystem.RankSelectType == "beat" then
                itm.score = v.solo_kill_rating;
            end

            if RankSystem.RankSelectType == "fpp_sum" then
                itm.score = v.fpp_solo_rank_rating;
            elseif RankSystem.RankSelectType == "fpp_win" then
                itm.score = v.fpp_solo_win_rating;
            elseif RankSystem.RankSelectType == "fpp_beat" then
                itm.score = v.fpp_solo_kill_rating;
            end

        elseif RankSystem.RankSelectMemberType == "double" then
            if RankSystem.RankSelectType == "sum" then
                itm.score = v.duo_rank_rating;
            elseif RankSystem.RankSelectType == "win" then
                itm.score = v.duo_win_rating;
            elseif RankSystem.RankSelectType == "beat" then
                itm.score = v.duo_kill_rating;
            end

            if RankSystem.RankSelectType == "fpp_sum" then
                itm.score = v.fpp_duo_rank_rating;
            elseif RankSystem.RankSelectType == "fpp_win" then
                itm.score = v.fpp_duo_win_rating;
            elseif RankSystem.RankSelectType == "fpp_beat" then
                itm.score = v.fpp_duo_kill_rating;
            end

        elseif RankSystem.RankSelectMemberType == "team" then
            if RankSystem.RankSelectType == "sum" then
                itm.score = v.squad_rank_rating;
            elseif RankSystem.RankSelectType == "win" then
                itm.score = v.squad_win_rating;
            elseif RankSystem.RankSelectType == "beat" then
                itm.score = v.squad_kill_rating;
            end

            if RankSystem.RankSelectType == "fpp_sum" then
                itm.score = v.fpp_squad_rank_rating;
            elseif RankSystem.RankSelectType == "fpp_win" then
                itm.score = v.fpp_squad_win_rating;
            elseif RankSystem.RankSelectType == "fpp_beat" then
                itm.score = v.fpp_squad_kill_rating;
            end
        end

        if RankSystem.RankSelectType == "like" then
             itm.score = v.upvote_rating;
        end

        if RankSystem.RankSelectType == "popularity" then
            if RankSystem.RankPeriodType == "total" then
                itm.score = v.total_devote or 0;
            else
                itm.score = v.last_week_devote or 0;
            end
        end

        if RankSystem.RankSelectType == "pve" then
            itm.score = v.pve_level or 1
        end

        itm.score = RankSorceInt(itm.score)
        table.insert(RankSystem.RankInfoList, itm);
    end

    --upass排行榜的时候，排序的就不是score了，而是 level, acc_score, acc_update_time
    if RankSystem.RankSelectType ~= "upass" then
        local function compFunc(a1, a2)
            return a1.score > a2.score;
        end
        table.sort(RankSystem.RankInfoList, compFunc)
    else
        local function compFuncUpass(a1, a2)
            local v1 = RankSystem.RankFriendList[tonumber(a1.uid)]
            local v2 = RankSystem.RankFriendList[tonumber(a2.uid)]

            if v1.upass.level ~= v2.upass.level then
                return v1.upass.level > v2.upass.level
            elseif v1.upass.acc_score ~= v2.upass.acc_score then
                return v1.upass.acc_score > v2.upass.acc_score 
            else
                return v1.upass.acc_update_time < v2.upass.acc_update_time
            end
        end
        table.sort(RankSystem.RankInfoList, compFuncUpass);
    end

    for i,v in ipairs(RankSystem.RankInfoList) do
        v.no = i;
        RankSystem.UpdateRankRole(v, v.uid, zoneId);
    end
    
    --特殊处理，好友总分榜的生存积分和击败积分读取get_friend_rank_rsp返回的数据，不要读取概要里的数据
    if RankSystem.RankSelectType == "fpp_sum" then
        for i,v in ipairs(RankSystem.RankInfoList) do
            local dat = RankSystem.RankFriendList[tonumber(v.uid)]
            if dat then
                local win_rating = 0
                local kill_rating = 0
                if RankSystem.RankSelectMemberType == "single" then
                    win_rating = dat.fpp_solo_win_rating
                    kill_rating = dat.fpp_solo_kill_rating
                elseif RankSystem.RankSelectMemberType == "double" then
                    win_rating = dat.fpp_duo_win_rating
                    kill_rating = dat.fpp_duo_kill_rating
                elseif RankSystem.RankSelectMemberType == "team" then
                    win_rating = dat.fpp_squad_win_rating
                    kill_rating = dat.fpp_squad_kill_rating
                end
                v.content2 = RankSorceInt(win_rating)
                v.content3 = RankSorceInt(kill_rating)
            end
        end
    end
    
    EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_RANK_UPDATE_LIST);
    if RankSystem.RankSelectType == "upass" then
        EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_RANK_UPDATE_LIST);
    end
    --log_tree("----------- RankSystem.RankInfoList, " , RankSystem.RankInfoList)
    for i,v in pairs(RankSystem.RankInfoList) do
        if tostring(v.uid) == tostring(DataMgr.roleData.uid) then
            RankSystem.RankInfoSelf = FuncUtil:CopyTable(v)
            break
        end
    end
    EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_RANK_UPDATE_SELF);
    if RankSystem.RankSelectType == "upass" then
        EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_RANK_UPDATE_SELF);
    end
end

function RankSystem.get_self_popularit_summary_req()
    local reqType = "SelfReq"
    local cached_result = RankSystem.Cached_Popularit_summary_rsp[tonumber(DataMgr.roleData.uid)]
    if cached_result then
        RankSystem.batch_get_popularit_summary_rsp(0,  {[tonumber(DataMgr.roleData.uid)] = cached_result}, reqType)
    else
        NetUtil.SendPriorityPkg(false, "batch_get_popularit_summary_rsp", "batch_get_popularit_summary_req", {tonumber(DataMgr.roleData.uid)}, reqType);
    end
end

--批量拉取好友的人气概要
function RankSystem.batch_get_popularit_summary_req()
    RankSystem.RankFriendList = {};

    local tmp = {};

    for i,v in ipairs(ID_PLAT_FRIENDLIST) do
        tmp[v] = 1;
    end
    for i,v in ipairs(ID_INNER_FRIENDLIST) do

        tmp[v] = 1;
    end

    tmp[tonumber(DataMgr.roleData.uid)] = 1

    local cached_result = {}

    local sendUids = {}
    for uid,v in pairs(tmp) do
        uid = tonumber(uid)
        local hasCached = RankSystem.Cached_Popularit_summary_rsp[tonumber(uid)]
        if hasCached then
            cached_result[uid] = hasCached
        else
            table.insert(sendUids, uid);
        end
    end

    local reqType = "FriendReq"


    --直接转发缓存结果
    if next(cached_result) then
        log_tree("cached_result=", cached_result)
        RankSystem.batch_get_popularit_summary_rsp(0,  cached_result, reqType)
    end


    local lstFriendUid = {};
    --table.insert(lstFriendUid, tonumber(DataMgr.roleData.uid));
    for i, uid in ipairs(sendUids) do
        table.insert(lstFriendUid, tonumber(uid));
        if #lstFriendUid >= 100 then
            log_tree("lstFriendUid=", lstFriendUid)
            NetUtil.SendPriorityPkg(false, "batch_get_popularit_summary_rsp", "batch_get_popularit_summary_req", lstFriendUid, reqType);
            lstFriendUid = {};
        end
    end
    --请求好友排行榜
    if #lstFriendUid > 0 then
        log_tree("batch_get_popularit_summary_req uid_list=", lstFriendUid)
        NetUtil.SendPriorityPkg(false, "batch_get_popularit_summary_rsp", "batch_get_popularit_summary_req", lstFriendUid, reqType);
    end

end

function RankSystem.self_popularit_summary_Rsp(result)
    log_tree("self_popularit_summary_Rsp", result)

    for k,v in pairs(result) do
        RankSystem.Cached_Popularit_summary_rsp[tonumber(k)] = v
    end

    RankSystem.UpdateRankRole(RankSystem.RankInfoSelf, tostring(DataMgr.roleData.uid), 0);

    log("RankSystem.RankInfoSelf.score "..tostring(RankSystem.RankInfoSelf.score))

    if RankSystem.RankInfoSelf.top1w then
        local rankNo = RankSystem.RankInfoSelf.no
        local score = RankSystem.RankInfoSelf.score
        local top_1w_score = RankSystem.RankInfoSelf.top1w
        local rank_type = RankSystem.RankSelectType

        --log("rank_type =" .. rank_type)
        --log("score = "..score ..", top_1w_score="..top_1w_score..", rankNo = "..rankNo)
        BP_RankInfoSelfBelow1wDisplay = RankSystem.calc_topn_percentage(score, top_1w_score, rank_type, rankNo)
        --log_tree("RankInfoSelf:", RankInfoSelf);

        log("BP_RankInfoSelfBelow1wDisplay:"..tostring(BP_RankInfoSelfBelow1wDisplay));
    end

    EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_RANK_UPDATE_SELF);
end
-- res 操作结果 number
--  result 数据 table
--result  = [uid] ={
--total_devote=0,
--last_update_time = 0,
--last_week_devote = 0,
--}
function RankSystem.batch_get_popularit_summary_rsp(res,  result, reqType)
    log("RankSystem.batch_get_popularit_summary_rsp res = "..tostring(res) .. ",reqType:" ..  tostring(reqType))
    --log_tree("batch_get_popularit_summary_rsp result", result)
    if res == 0 then
        --预处理,如果更新时间不是本周的,那么贡献要为0,主要是服务器并不会主动去更新一个玩家的贡献
        for i, bin_info in pairs(result) do
            local info = bin_info
            if type(bin_info) == "string" then --如果是string的话,需要解包,否则是缓存传递过来的
                info = Client.Load(LuaStateWrapper, bin_info);
            end

            log_tree("batch_get_popularit_summary_rsp info", info)
            info.last_week_devote = info.last_week_devote or 0
            info.last_update_time = info.last_update_time or 0
            info.total_devote = info.total_devote or 0
            if not FuncUtil.issameweek_by_tz(info.last_update_time, FuncUtil.GetServerTimeInSec(), 0) then
                info.last_week_devote = 0
            end
            result[i] = info
        end

        if reqType == "SelfReq" then
            RankSystem.self_popularit_summary_Rsp(result)
        elseif reqType == "FriendReq" then
            for k,v in pairs(result) do
                RankSystem.Cached_Popularit_summary_rsp[tonumber(k)] = v
                RankSystem.RankFriendList[k] = v;
            end
            RankSystem.UpdateFriendRankRole(0);
        end
    elseif res == 700001 then
        DataMgr.ShowNoticeByID(9920020)
    elseif res == 700002 then
        DataMgr.ShowNoticeByID(502001)
    end
end

--[[网络回调]]--
s2c["get_topn_rank_rsp"] = RankSystem.RspFetchRankData;
s2c["get_one_user_rank_rsp"] = function(...)
    RankSystem.RspFetchSelfRankData(...);
	RoleInfoSystem.get_role_rank_info_rsp(...);
    SeasonSystem.get_one_user_rank_rsp(...);
    CorpsRankSystem.OnGetMyRankInfoData(...);
end;
s2c["get_friend_rank_rsp"] = RankSystem.RspFriendRankRole;
s2c["get_topn_1w_score_rsp"] = RankSystem.RspFriendRankRole;
s2c["batch_get_popularit_summary_rsp"] = RankSystem.batch_get_popularit_summary_rsp;

