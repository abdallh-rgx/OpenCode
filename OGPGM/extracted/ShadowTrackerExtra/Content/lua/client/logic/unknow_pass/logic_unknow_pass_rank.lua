UnknowPassRankSystem = UnknowPassRankSystem or 
{
        RankInfoSelf = {
            no = 0,
            uid = "",
            level = 0,              --等级
            name = "",              --名称
            nation = "",            --国籍
            head_icon_url = "",     --头像
            segment = 0,            --段位
            cur_avatar_box_id = 0,  --头像框
            gender = 0,             -- 性别
            score = 0,
            pass_level = 0,
            is_buy = 0,             --是否购买
            show_icon = false,      --是否显示图标
        };

        --排行榜
        RankInfoListItem =
        {
            no = 0,
            uid = "",
            level = 0,              --等级
            name = "",              --名称
            nation = "",            --国籍
            head_icon_url = "",     --头像
            segment = 0,            --段位
            cur_avatar_box_id = 0,  --头像框
            gender = 0,             -- 性别
            score = 0,
            pass_level = 0,
            is_buy = 0,             --是否购买
            show_icon = false,      --是否显示图标
        },
        RankInfoList = {},

        top_1w_score = 1;       -- 1万名的积分数目
}

function UnknowPassRankSystem.Enter()
end

function UnknowPassRankSystem.SwitchShowPanel(bQueryFriend)
    if bQueryFriend then
        RankSystem.RankRegionType = "friend";
    else
        RankSystem.RankRegionType = "all";
    end
    
    RankSystem.RankSelectType = "upass";    
    RankSystem.ReqFetchRankData(bQueryFriend, 1);
end

function UnknowPassRankSystem.ConvertToRankInfo(item)
    local rankInfo = FuncUtil:CopyTable(UnknowPassRankSystem.RankInfoListItem)
    rankInfo.no = item.no
    rankInfo.uid = item.uid
    rankInfo.level = item.level
    rankInfo.name = item.name
    rankInfo.nation = item.nation
    rankInfo.head_icon_url = item.url
    rankInfo.segment = item.segment;   
    rankInfo.cur_avatar_box_id = item.cur_avatar_box_id
    rankInfo.gender = item.gender;
    
    if item.uid == DataMgr.roleData.uid then
        rankInfo.pass_level = UnknowPassSystem.Level
        rankInfo.score = UnknowPassSystem.Data.base.acc_score;
        rankInfo.is_buy = UnknowPassSystem.Data.base.is_buy;
        rankInfo.vaild = true;
    else
        rankInfo.pass_level = item.score or 1;
        rankInfo.score = item.content3;
        rankInfo.is_buy = item.is_buy;
        rankInfo.vaild = (item.content3 ~= "-");
    end

    rankInfo.show_icon = item.uishow;
    if rankInfo.pass_level == 0 then -- pass没有等级为0的
        rankInfo.pass_level = 1
    end

    if RankSystem.RankRegionType == "friend" then
        BP_UnknowpassRankSelfBelow1wDisplay = RankSystem.RankInfoSelf.no;
    else
        BP_UnknowpassRankSelfBelow1wDisplay = UnknowPassRankSystem.calc_topn_percentage(rankInfo.score, UnknowPassRankSystem.top_1w_score, item.no);
    end
    return rankInfo
end

--自己的排行榜
function UnknowPassRankSystem.get_role_rank_info_rsp(client_data,  score, ok, zoneId, rank_info)
    log("client_data = "..client_data ..", ok="..ok..", zoneId = "..zoneId)
    log_tree("------ rank_info=", rank_info)
    if ok == 0 then
        local rankInfo = {};
        rankInfo.no = rank_info.rank_no or 0;
        UnknowPassRankSystem.UpdateRankRole(rankInfo, tostring(DataMgr.roleData.uid));
        BP_UnknowpassRankSelfBelow1wDisplay = UnknowPassRankSystem.calc_topn_percentage(score, rank_info.top1w, rankInfo.no)
        log("BP_RankInfoSelfBelow1wDisplay:"..tostring(BP_UnknowpassRankSelfBelow1wDisplay));
        rankInfo.no = 0;
        UnknowPassRankSystem.RankInfoSelf = rankInfo;
        log_tree("------ rank_info2=",rankInfo)
        EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_RANK_UPDATE_SELF);
    else
        UnknowPassRankSystem.RankInfoSelf.no = 0;
        UnknowPassRankSystem.RankInfoSelf.score = 0;
        UnknowPassRankSystem.UpdateRankRole(UnknowPassRankSystem.RankInfoSelf, tostring(DataMgr.roleData.uid), zoneId);
        EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_RANK_UPDATE_SELF);
    end
end

--计算排行榜 前xx.xx%
function UnknowPassRankSystem.calc_topn_percentage(score, top_1w_score, rankNo)
    if top_1w_score == nil then
        return tostring(Client.GetTableData("LocalizeRes", 102127).TextValue);
    end

    --解决没有1W人上榜的时候排行不显示
    if rankNo > 0 and rankNo <= 10000 then
        return tostring(rankNo);
    end

    local middle_score = score / top_1w_score * 5 - 1;
    local percentage = 1 - math.max(math.min(((1 / (1 + math.exp(-0.65 * middle_score)) - 0.5) * 1.72 + 0.2585), 1), 0);
    return string.format(tostring(Client.GetTableData("LocalizeRes", 108036).TextValue), percentage * 100);
end

