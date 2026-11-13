WarZoneRankSystem = WarZoneRankSystem or
{
    IsOpendWarZone = "IsOpendWarZone",
    recodeInfoList = {},
    recodeCacheMark = {},
    recodeCurSeq = 0,
    recodeWaitSeq = {},
    reqReocdeTimer = nil,
    -- 排行榜item模板
    RankInfoListItem =
    {
        no = 0,
        uid = "",
        score = 0,

        name = "",              --名称
        url = "",               --头像
        level = 0,              --等级
        gender = 0,             --性别
        segment = 0,            --段位
        cur_avatar_box_id = 0,  --头像框
        startup_type = 0,--启动类型
        qq_vip = 0,--qq会员
        showWarZone = true,
        content1 = "",
        content2 = "",
        content3 = "",
        warzone_id = 0,
        roleNation = "",
    },
    -- 排行榜列表
    RankInfoList = {},
    MyRankInfo = {
        no = 0,
        uid = "",
        score = 0,

        name = "",              --名称
        url = "",               --头像
        level = 0,              --等级
        gender = 0,             --性别
        segment = 0,            --段位
        cur_avatar_box_id = 0,  --头像框
        startup_type = 0,--启动类型
        qq_vip = 0,--qq会员
        showWarZone = true,
        content1 = "",
        content2 = "",
        content3 = "",
        warzone_id = 0,
    },  -- 自己
    FriendRankInfoList = {},

    -- 拉排行榜请求参数
    client_data =
    {
        rank_type = 1, -- 排行榜类型 1-13
        rank_id = 440305, --   排行榜id  china_city_table中的key
        from_index = 1, -- 起始名次
        count = 100, -- 拉去的榜单数量（目前最大支持数量为100，所以 from_index + count - 1 <= 100 )

        req_type = 0,
        callback = nil,
    },
    -- 总人数
    RankInfoListCount = 0,

    -- 个人信息缓存
    RankRoleInfoItem =
    {
        uid = "",
        name = "",              --名称
        url = "",               --头像
        level = 0,              --等级
        gender = 0,             --性别
        startup_type = 0,--启动类型
        qq_vip = 0,--qq会员
        segment = 0,
        cur_avatar_box_id = 0,
        warzone_id = 0,
    },
    RankRoleInfo = {},
    RankRoleInfoSending = {},

    RankRoleAvatarInfo = {},

    -- 个人信息查询
    QueryRoleInfoStart = 1,
    QueryRoleInfoCount = 5,

    -- callback
    CallbackList = {},
    CallbackIndex = 1,

    -- 街区
    StreetZoneRankInfoList = {},
    StreetZoneLocationInfo =
    {
        selected_index = 0, --around_info的索引
        around_info =
        {
            --{longitude, latitude, name}
        }
    },

    StreetZoneGainTitleList = {},
    WarzoneNewbieStatus = {},
}

local ReqRankTimeGap = 150

local REQ_LBS_TOPN_RANK_OK = 0                    -- 拉取成功
local REQ_LBS_TOPN_RANK_ERR_PARAM_RANK_TYPE = 1   -- 无效的rank_type参数
local REQ_LBS_TOPN_RANK_ERR_PARAM_RANK_ID = 2     -- 无效的rank_id参数
local REQ_LBS_TOPN_RANK_ERR_PARAM_RANGE = 3       -- 无效的from_index, count
local REQ_LBS_TOPN_RANK_ERR_WAIT = 4              -- 访问太频繁

-- 获取省列表
local function GetProvinceList()

end

-- 获取市列表
local function GetCityList(province_id)

end

-- 获取区列表
local function GetDistrictList(city_id)

end

function WarZoneRankSystem.Enter()
    log("WarZoneRankSystem Enter");
    WarZoneRankSystem.RankInfoList = {};

    --这里应该加入自己的信息
    WarZoneRankSystem.RankRoleInfo = {};
    WarZoneRankSystem.RankRoleInfoSending = {};
    WarZoneRankSystem.RankRoleAvatarInfo = {};

    local roleId = tonumber(DataMgr.roleData.uid)
    ProfileMgr.GetProfileList({roleId}, function(profileList)
        local list = {}
        for i,v in ipairs(profileList) do
            list[tonumber(v.uid)] = v
        end
        WarZoneRankSystem.ProcessRoleInfoList(list);

        WarZoneRankSystem.UpdateRankSelf();
    end)

    WarZoneRankSystem.FriendRankInfoList = {};

    if DataMgr.lbs_warzone_info ~= nil then
        WarZoneRankSystem.client_data.rank_id = DataMgr.lbs_warzone_info.warzone_id;
    else
        WarZoneRankSystem.client_data.rank_id = 440305;
    end
    log("WarZoneRankSystem Enter rank_id=" .. tostring(WarZoneRankSystem.client_data.rank_id));
    --sami war
    --WarZoneRankSystem.ReqWarzoneRecodeInfo({tonumber(DataMgr.roleData.uid)})
end

function WarZoneRankSystem.UpdateRankSelf()
    if BP_WarZoneRank_Tab == 1 then
        WarZoneRankSystem.UpdateFriendRole(WarZoneRankSystem.MyRankInfo, tostring(DataMgr.roleData.uid));
        WarZoneRankSystem.MyRankInfo.uid = tostring(DataMgr.roleData.uid)
        WarZoneRankSystem.MyRankInfo.segment = WarZoneRankSystem.GetRoleSegment(DataMgr.roleData.uid, 0);
        WarZoneRankSystem.MyRankInfo.score = WarZoneRankSystem.GetRoleScore(DataMgr.roleData.uid, 0)
    else 
        WarZoneRankSystem.UpdateFriendRole(WarZoneRankSystem.MyRankInfo, tostring(DataMgr.roleData.uid));
        WarZoneRankSystem.MyRankInfo.uid = tostring(DataMgr.roleData.uid)
        WarZoneRankSystem.MyRankInfo.segment = WarZoneRankSystem.GetRoleSegment(DataMgr.roleData.uid, 1);
        WarZoneRankSystem.MyRankInfo.score = WarZoneRankSystem.GetRoleScore(DataMgr.roleData.uid, 1)
        WarZoneRankSystem.MyRankInfo.no = WarZoneRankSystem.GetMyFriendRankNo()
    end
    BP_STRUCT_WarZoneRankInfoMe.BP_STRUCT_WarZoneRankInfo = FuncUtil:CopyTable(WarZoneRankSystem.MyRankInfo);
    EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_WARZONE_RANK_UPDATE_SELF);
end

function WarZoneRankSystem.Release()
    log("WarZoneRankSystem Release");
end

WarZoneRankSystem.ModifyWarZoneIgnoreError = false
-- 修改战区
-- 修改战区请求 warZoneId 战区id
function WarZoneRankSystem.ModifyWarZoneReq(warZoneId, ignoreError)
    if ignoreError == nil then
        ignoreError = false
    end
    WarZoneRankSystem.ModifyWarZoneIgnoreError = ignoreError
    log("WarZoneRankSystem ModifyWarZoneReq: " .. tostring(warZoneId));
    NetUtil.SendPkg("modify_lbs_warzone_id", warZoneId);
end

-- 修改战区回包 ret_code 结果
--[[
    local REQ_LBS_TOPN_RANK_OK = 0                    -- 拉取成功
    local REQ_LBS_TOPN_RANK_ERR_PARAM_RANK_TYPE = 1   -- 无效的rank_type参数
    local REQ_LBS_TOPN_RANK_ERR_PARAM_RANK_ID = 2     -- 无效的rank_id参数
    local REQ_LBS_TOPN_RANK_ERR_PARAM_RANGE = 3       -- 无效的from_index, count
    local REQ_LBS_TOPN_RANK_ERR_WAIT = 4              -- 访问太频繁
]]
function WarZoneRankSystem.ModifyWarZoneRes(ret_code, warzone_id)
    log(string.format("WarZoneRankSystem.ModifyWarZoneRes ret_code=%s, warzone_id=%s", tostring(ret_code), tostring(warzone_id)))
    if not WarZoneRankSystem.ModifyWarZoneIgnoreError or ret_code == 0 then
    end
end

--[[ 请求排行榜人数
    rank_id 排行榜的类型
]]
function WarZoneRankSystem.GetWarZoneRankListCountReq(rank_id)
    log("WarZoneRankSystem GetWarZoneRankListCountReq: id=" .. tostring(WarZoneRankSystem.client_data.rank_id));

    if rank_id ~= nil then
        NetUtil.SendPkg("query_lbs_warzone_playernum_req", rank_id);
    else
        NetUtil.SendPkg("query_lbs_warzone_playernum_req", WarZoneRankSystem.client_data.rank_id);
    end
end

--[[ 排行榜人数回包
    rank_id 排行榜的类型
    count 人数
]]
function WarZoneRankSystem.GetWarZoneRankListCountRes(id, count)
    log("WarZoneRankSystem GetWarZoneRankListCountRes id=" .. tostring(id) .. " count=" .. tostring(count))
    --if client_data.rank_type ~= WarZoneRankSystem.client_data.rank_type or client_data.rank_id ~= WarZoneRankSystem.client_data.rank_id then
    --    return
    --end

    WarZoneRankSystem.RankInfoListCount = count

    local bundle = {id=id, count=count}
    EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_WARZONE_RANK_LIST_COUNT, bundle)
end

function WarZoneRankSystem.ReqWarzoneRecodeInfo(uidList)
    --log_tree("WarZoneRankSystem.ReqWarzoneRecodeInfo = ", uidList);
    
    local curTime = FuncUtil.GetServerTimeInSec()
    local invalidList = {}
    for _,uid in pairs(uidList) do
        uid = tonumber(uid)
        local markTime = WarZoneRankSystem.recodeCacheMark[uid] or 0
        if curTime - markTime > ReqRankTimeGap then
            table.insert(invalidList, uid)
        end
    end
    --log_tree("invalidList = ", invalidList);

    if #invalidList > 0 then
        -- 分包请求好友lbs记录数据
        local startIndex = 1
        local reqList = {}
        while(startIndex <= #invalidList) do
			reqList = {}
			for k = startIndex, startIndex + 100 - 1 do
				if invalidList[k] ~= nil then
					table.insert(reqList, invalidList[k])
				end
			end
			
            --table.move(invalidList, startIndex, startIndex + 100, 1, reqList)
			
            WarZoneRankSystem.recodeCurSeq = WarZoneRankSystem.recodeCurSeq + 1
            table.insert(WarZoneRankSystem.recodeWaitSeq, WarZoneRankSystem.recodeCurSeq)

            --log_tree("reqList = ", reqList);
            NetUtil.SendPkg("batch_get_profile_lbs_warzone_req", reqList, WarZoneRankSystem.recodeCurSeq)
            startIndex = startIndex + 100
        end
        -- 处理请求超时
        if WarZoneRankSystem.reqRecordTimer ~= nil then
            Timer.RemoveTimer(WarZoneRankSystem.reqRecordTimer)
        end
        WarZoneRankSystem.reqRecordTimer = Timer.InsertTimer(5, function()
            WarZoneRankSystem.recodeWaitSeq = {}
            log("=======================EVENTID_WARZONE_GET_RECODE_INFO timer out")
            EventSystem:postEvent(EVENTTYPE_WARZONE, EVENTID_WARZONE_GET_RECODE_INFO)
        end)
    else
        log("=======================EVENTID_WARZONE_GET_RECODE_INFO invalid list is empty")
        EventSystem:postEvent(EVENTTYPE_WARZONE, EVENTID_WARZONE_GET_RECODE_INFO)
    end
end

function WarZoneRankSystem.RspWarzoneRecodeInfo(ret, recodeInfoList, seq)
    log("ret = " ..ret);
    log("seq = " ..seq);
    --log_tree("WarZoneRankSystem.RspWarzoneRecodeInfo recodeInfoList = ", recodeInfoList);

    if ret == NetErrorCode_NONE then
        local curTime = FuncUtil.GetServerTimeInSec()
        for uid, recodeInfo in pairs(recodeInfoList) do
            uid = tonumber(uid)
            WarZoneRankSystem.recodeCacheMark[uid] = curTime
            WarZoneRankSystem.recodeInfoList[uid] = recodeInfo
        end
        
        if recodeInfoList[tonumber(DataMgr.roleData.uid)] ~= nil then
            WarZoneRankSystem.UpdateRankSelf()
        end
    end
    --log_tree("============wait seq " .. seq, WarZoneRankSystem.recodeWaitSeq)
    -- 处理合包操作，计数器记录剩余请求数
    for i,seqCache in ipairs(WarZoneRankSystem.recodeWaitSeq) do
        if seqCache == seq then
            table.remove(WarZoneRankSystem.recodeWaitSeq, i)
            break
        end
    end
    if #WarZoneRankSystem.recodeWaitSeq == 0 then
        if WarZoneRankSystem.reqRecordTimer ~= nil then
            Timer.RemoveTimer(WarZoneRankSystem.reqRecordTimer)
        end
        log("=======================EVENTID_WARZONE_GET_RECODE_INFO")
        EventSystem:postEvent(EVENTTYPE_WARZONE, EVENTID_WARZONE_GET_RECODE_INFO)
    end
end

function WarZoneRankSystem.GetCurRankTypeScore(uid)
    local recodeInfo = WarZoneRankSystem.recodeInfoList[tonumber(uid)]
    if recodeInfo == nil then
        return 0
    else
        --log("uid = "..uid)
        --log_tree("WarZoneRankSystem.GetCurRankTypeScore recodeInfo = ", recodeInfo);
        local rankType = BP_WarZoneMedalChooseType;
        local config = Client.GetTableData("lbsranktypetable", rankType)
        local score_var = config.score_var
        --log("BP_CurSelectAreaId = "..BP_CurSelectAreaId..", score_var = "..score_var);

        if recodeInfo.lbs_warzone_record == nil or recodeInfo.lbs_warzone_record[BP_CurSelectAreaId] == nil then
            return 0
        end
        return recodeInfo.lbs_warzone_record[BP_CurSelectAreaId][score_var] or 0
    end
end

function WarZoneRankSystem.GetValidFriendList()
    log_tree("GetValidFriendList", WarZoneRankSystem.recodeInfoList)
    local rankType = BP_WarZoneMedalChooseType;
    local config = Client.GetTableData("lbsranktypetable", rankType)
    local score_var = config.score_var
    local result = {}
    local areaId = BP_CurSelectAreaId;

    for uid, recodeInfo in pairs(WarZoneRankSystem.recodeInfoList) do
        --log_tree("uid, recodeInfo = ", uid, recodeInfo);
        if recodeInfo.lbs_warzone_record ~= nil and
            recodeInfo.lbs_warzone_record[areaId] ~= nil and
            recodeInfo.lbs_warzone_record[areaId][score_var] ~= nil then
            table.insert(result, uid);
        end
    end
    --log_tree("result = ", result);

    --无用协议屏蔽
    --NetUtil.SendPkg("report_frd_num_req", rankType, #result)

    return result
end

-- 请求好友排行
function WarZoneRankSystem.GetWarZoneFriendListReq()
    log("=============================GetWarZoneFriendListReq")
    ConnectionWaitingUI:Show()
    Timer.InsertTimer(3, function ( ... )
            ConnectionWaitingUI:Hide();
        end, false);
    local function UpdateFriendList()
        log("=======================================get RecodeInfo succ")
        EventSystem:unregistEvent(EVENTTYPE_WARZONE, EVENTID_WARZONE_GET_RECODE_INFO, UpdateFriendList)
        local showFriendList = WarZoneRankSystem.GetValidFriendList()
        local bundle = {id= WarZoneRankSystem.client_data.rank_id, count = #showFriendList}
        EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_WARZONE_RANK_LIST_COUNT, bundle)

        local listUid = {}
        -- 遍历个人信息 积分都在个人信息里
        for _, uid in ipairs(showFriendList) do
            local uidStr = tostring(uid)
            local role = WarZoneRankSystem.RankRoleInfo[uidStr];
            if role == nil then
                table.insert(listUid, uid);
            end
        end
        if #listUid > 0 then
            ProfileMgr.GetProfileList(listUid, function (profileList)
                --log_tree("WarZoneRankSystem.GetWarZoneFriendListReq =", profileList)
                local list = {}
                for i,v in ipairs(profileList) do
                    list[tonumber(v.uid)] = v
                end
                WarZoneRankSystem.ProcessRoleInfoList(list)
                WarZoneRankSystem.InitFriendList(showFriendList)
                ConnectionWaitingUI:Hide()
                EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_WARZONE_RANK_UPDATE_LIST)
                WarZoneRankSystem.UpdateRankSelf()
            end, false, false);
        else
            ConnectionWaitingUI:Hide()
            WarZoneRankSystem.InitFriendList(showFriendList)
            EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_WARZONE_RANK_UPDATE_LIST)
            WarZoneRankSystem.UpdateRankSelf()
        end
    end
    EventSystem:registEvent(EVENTTYPE_WARZONE, EVENTID_WARZONE_GET_RECODE_INFO, UpdateFriendList)

    local friendList = FriendSystem.GetAllFriendIDList()
    table.insert(friendList, DataMgr.roleData.uid)
    WarZoneRankSystem.ReqWarzoneRecodeInfo(friendList)
end

function WarZoneRankSystem.InitFriendList(showFriendList)
    --log_tree("=====================InitFriendList = ", showFriendList)
    local rankType = BP_WarZoneMedalChooseType;
    local config = Client.GetTableData("lbsranktypetable", rankType)
    local score_var = config.score_var
    WarZoneRankSystem.FriendRankInfoList = {}
    for _, uid in ipairs(showFriendList) do
        local roleInfo = WarZoneRankSystem.RankRoleInfo[tostring(uid)]
        if roleInfo ~= nil then
            local item = FuncUtil:CopyTable(WarZoneRankSystem.RankInfoListItem);
            item.uid = tostring(uid);
            item.score = WarZoneRankSystem.GetCurRankTypeScore(uid)
            WarZoneRankSystem.UpdateFriendRole(item, item.uid);

            --log_tree("item = ", item);
            if item.score > 0 then
                table.insert(WarZoneRankSystem.FriendRankInfoList, item);
            end
        end
    end
    log("=====================InitFriendList2 " .. #WarZoneRankSystem.FriendRankInfoList)

    table.sort(WarZoneRankSystem.FriendRankInfoList, function(a,b)
        return a.score > b.score or (a.score == b.score and a.uid > b.uid)
    end)
    for index, rankInfo in ipairs(WarZoneRankSystem.FriendRankInfoList) do
        local prevRankInfo = WarZoneRankSystem.FriendRankInfoList[index - 1]
        if prevRankInfo ~= nil and prevRankInfo.score == rankInfo.score then
            rankInfo.no = prevRankInfo.no
        else
            rankInfo.no = index
        end
        if tostring(rankInfo.uid) == tostring(WarZoneRankSystem.MyRankInfo.uid) then
            WarZoneRankSystem.MyRankInfo.no = rankInfo.no
        end
    end
end

function WarZoneRankSystem.GetMyFriendRankNo()
    table.sort(WarZoneRankSystem.FriendRankInfoList, function(a,b)
        return a.score > b.score or (a.score == b.score and a.uid > b.uid)
    end)
    for index, rankInfo in ipairs(WarZoneRankSystem.FriendRankInfoList) do
        if tostring(rankInfo.uid) == tostring(WarZoneRankSystem.MyRankInfo.uid) then
            return index
        end
    end
    return 0
end

-- 请求排行榜
function WarZoneRankSystem.GetWarZoneRankListReq()
    log("WarZoneRankSystem GetWarZoneRankListReq: type=" .. tostring(WarZoneRankSystem.client_data.rank_type)
      .. " id=" .. tostring(WarZoneRankSystem.client_data.rank_id)
      .. " from_index=" .. tostring(WarZoneRankSystem.client_data.from_index));
      WarZoneRankSystem.client_data.req_type = 0;
      NetUtil.SendPriorityPkg(false, "get_lbs_topn_rank_rsp", "get_lbs_topn_rank", WarZoneRankSystem.client_data);
end

-- 排行榜回包
function WarZoneRankSystem.GetWarZoneRankListRes(ret_code, client_data, rank_list)
    if rank_list  ~= nil then
        --log_tree("WarZoneRankSystem GetWarZoneRankListRes ret=" .. ret_code .. " list=", rank_list);
    else
        log("WarZoneRankSystem GetWarZoneRankListRes ret=" .. ret_code);
    end

    if ret_code == REQ_LBS_TOPN_RANK_OK then
        if client_data.req_type == 0 then
            WarZoneRankSystem.RankInfoList = {}
            local selfScore = false
            if rank_list ~= nil then
                for i, v in ipairs(rank_list) do
                    local item = FuncUtil:CopyTable(WarZoneRankSystem.RankInfoListItem);
                    item.no = v.rank_no;
                    item.uid = tostring(v.uid);
                    item.score = math.floor(v.score + 0.5);
                    WarZoneRankSystem.UpdateRankRole(item, v.uid);
                    table.insert(WarZoneRankSystem.RankInfoList, item);

                    -- 如果是自己
                    if item.uid == tostring(DataMgr.roleData.uid) then
                        WarZoneRankSystem.MyRankInfo.score = item.score
                        WarZoneRankSystem.MyRankInfo.no = item.no
                        selfScore = true
                    end
                end
            end
            if selfScore == false then
                WarZoneRankSystem.MyRankInfo.no = 0
            end
            EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_WARZONE_RANK_UPDATE_LIST)

            WarZoneRankSystem.UpdateRankSelf()
        end
    elseif ret_code == REQ_LBS_TOPN_RANK_ERR_WAIT then
        DataMgr.ShowMessageBoxByID(ret_code);
        log("WarZoneRankSystem need wait. retry")

        --DataMgr.ShowNoticeByString("点击太快 正在重试");

        ConnectionWaitingUI:Show();
        Timer.InsertTimer(1, function ( ... )
            ConnectionWaitingUI:Hide();
            NetUtil.SendPriorityPkg(false, "get_lbs_topn_rank_rsp", "get_lbs_topn_rank", WarZoneRankSystem.client_data);
        end, false);
    else
        DataMgr.ShowMessageBoxByID(ret_code);
        -- DataMgr.ShowNoticeByString("错误");
    end
end

--积分四舍五入
local function RankSorceInt(score)
    return math.floor(score + 0.5)
end

function WarZoneRankSystem.GetRoleSegment(uid, byArea)
    local role = WarZoneRankSystem.RankRoleInfo[uid];
    if role == nil then
        return 101;
    end
    if byArea == 1 then
        return WarZoneRankUI.GetTableMax(role.segment[BP_CurSelectAreaId]);
    end
	
	local res = DataMgr.lbs_warzone_info.lbs_warzone_record;
	if res == nil then
        return 101;
    end
	local config = Client.GetTableData("lbsranktypetable", BP_WarZoneMedalChooseType)
    local score_var = config.score_var
    local tb = res[score_var];
    local area = tb[1];
	BP_Warzone_MyTopRankArea = area;
	return WarZoneRankUI.GetTableMax(role.segment[area]);
end

function WarZoneRankSystem.GetRoleScore(uid, byArea)
	local res = DataMgr.lbs_warzone_info.lbs_warzone_record;
	if res == nil then
		return 0
	end
    local config = Client.GetTableData("lbsranktypetable", BP_WarZoneMedalChooseType)
    local score_var = config.score_var
    if byArea == 0 then
        local tb = res[score_var];
		local area = tb[1];
		local score = tb[2];
		return score
    end

    local recodeInfo = WarZoneRankSystem.recodeInfoList[tonumber(uid)]
    if recodeInfo == nil or recodeInfo.lbs_warzone_record == nil then
        return 0
    end
    return recodeInfo.lbs_warzone_record[BP_CurSelectAreaId][score_var];
end

-- 更新个人信息
function WarZoneRankSystem.UpdateRankRole(itm, uid)
    local role = WarZoneRankSystem.RankRoleInfo[uid];
    if role == nil then
        return false
    end
    -- log_tree("update record:" .. uid .. " ", role)

    itm.name = role.name
    itm.url = role.url
    itm.level = role.level
    itm.city = role.city
    itm.gender = role.gender
	itm.startup_type = role.startup_type
	itm.qq_vip = role.qq_vip
    itm.cur_avatar_box_id = role.cur_avatar_box_id
    local roleInfo = ProfileMgr.GetPlayerDataByUid(uid);
    if nil ~= roleInfo then
        role.lbs_warzone_info = roleInfo.lbs_warzone_info;
    end
    local config = Client.GetTableData("lbsranktypetable", BP_WarZoneMedalChooseType);
    local score_var = config.score_var
    local areaId = 1;
    if role.lbs_warzone_info ~= nil and
        role.lbs_warzone_info.lbs_warzone_record ~= nil and
        role.lbs_warzone_info.lbs_warzone_record.on_rank_info ~= nil and
        role.lbs_warzone_info.lbs_warzone_record.on_rank_info[score_var] ~= nil and
        role.lbs_warzone_info.lbs_warzone_record.on_rank_info[score_var][1] ~= nil and
        role.lbs_warzone_info.lbs_warzone_record.on_rank_info[score_var][1] ~= 0 then

        areaId = role.lbs_warzone_info.lbs_warzone_record.on_rank_info[score_var][1];
    end

    itm.segment = WarZoneRankUI.GetTableMax(role.segment[areaId]);
    --log("itm.segment = " ..itm.segment);
    itm.showWarZone = role.showWarZone
    
    itm.content1 = config.display_desc
    if itm.score ~= nil then
        itm.score = RankSorceInt(itm.score)
    else
        itm.score = 0
    end
    itm.warzone_id = role.warzone_id
end

-- 更新好友信息
function WarZoneRankSystem.UpdateFriendRole(itm, uid)
    local role = WarZoneRankSystem.RankRoleInfo[uid];
    if role == nil then
        return false
    end
    -- log_tree("update record:" .. uid .. " ", role)

    itm.name = role.name
    itm.url = role.url
    itm.level = role.level
    itm.city = role.city
    itm.gender = role.gender
	itm.startup_type = role.startup_type
	itm.qq_vip = role.qq_vip
    itm.cur_avatar_box_id = role.cur_avatar_box_id
    itm.segment = WarZoneRankUI.GetTableMax(role.segment[BP_CurSelectAreaId]);
    itm.showWarZone = role.showWarZone
    local config = Client.GetTableData("lbsranktypetable", BP_WarZoneMedalChooseType);
    itm.content1 = config.display_desc
    itm.warzone_id = role.warzone_id
    itm.roleNation = role.nation;
end

local function GetRankListByTab( tab )
    if tab == 1 then
        return WarZoneRankSystem.RankInfoList
    elseif tab == 2 then
        return WarZoneRankSystem.FriendRankInfoList
    end
end

function WarZoneRankSystem.QueryRankRoleInfoByScroll(tab)
    local listUid = {}
    local onePageCount = WarZoneRankSystem.QueryRoleInfoCount
    local startIndex = WarZoneRankSystem.QueryRoleInfoStart
    local pageidx = math.modf(startIndex / onePageCount)
    for i = pageidx - 1, pageidx + 2 do
        for j = 1, onePageCount do
            local idx = i * onePageCount + j
            local itm = (GetRankListByTab(tab))[idx]
            if itm then
                local role = WarZoneRankSystem.RankRoleInfo[itm.uid];
                if role == nil then
                    local curtm = os.time();
                    local tm = WarZoneRankSystem.RankRoleInfoSending[itm.uid];
                    if tm == nil or (curtm - tm > 30) then
                        WarZoneRankSystem.RankRoleInfoSending[itm.uid] = curtm;
                        table.insert(listUid, tonumber(itm.uid));
                    end
                end
            end
        end
    end
    --log_tree("QueryRankRoleInfoByScroll:", {listUid, WarZoneRankSystem.StreetZoneRankInfoList, WarZoneRankSystem.RankRoleInfo})

    if #listUid > 0 then
        ProfileMgr.GetProfileList(listUid, WarZoneRankSystem.RspRankRoleInfo, false, false)
    else
        --直接刷新
        WarZoneRankSystem.RspRankRoleInfo({})
        WarZoneRankSystem.UpdateRankSelf()
    end
end

function WarZoneRankSystem.ProcessRoleInfoList(list)
    for k,v in pairs(list) do
        local role = FuncUtil:CopyTable(WarZoneRankSystem.RankRoleInfoItem)
        role.uid = tostring(k)
        role.name  = v.nickName
        role.url   = v.picUrl
        role.level = v.level
        role.gender = v.sex
        role.showWarZone = v.showWarZone
        if v.startup_type ~= nil then
            role.startup_type = v.startup_type
        end
        if v.qq_vip ~= nil then
            role.qq_vip = v.qq_vip
        end
        role.segment = v.segment_info;
        if type(v.cur_avatar_box_id) == "number" then
            role.cur_avatar_box_id = v.cur_avatar_box_id
        end
		
        --if v.lbs_warzone_info ~= nil then
            --role.warzone_id = v.lbs_warzone_info.warzone_id
        --end		
		if v.warZoneID ~= 0 then
			role.warzone_id = v.warZoneID
		end
		
        WarZoneRankSystem.RankRoleInfo[role.uid] = role
        WarZoneRankSystem.RankRoleInfoSending[role.uid] = nil
    end
end

-- 个人信息回包
function WarZoneRankSystem.RspRankRoleInfo(profileList)

    if type(profileList) ~= "table" then
        return
    end

    -- log_tree("WarZoneRankSystem RspRankRoleInfo: ", profileList)
    local list = {}
    for i,v in ipairs(profileList) do
        list[tonumber(v.uid)] = v
    end
    WarZoneRankSystem.ProcessRoleInfoList(list)
    for i,v in ipairs(WarZoneRankSystem.RankInfoList) do
        if list[tonumber(v.uid)] ~= nil then
            WarZoneRankSystem.UpdateRankRole(v, v.uid)
            EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_WARZONE_RANK_UPDATE_ITEM, {1, v})
        end
    end

    for k,v in pairs(list) do
        if tostring(DataMgr.roleData.uid) == tostring(k) then
            --log("RspRankRoleInfo EVENTID_RANK_UPDATE_SELF")
            WarZoneRankSystem.UpdateRankSelf()
            break
        end
    end
end

function WarZoneRankSystem.GetStreetListInfo( vars )
    local around_info = {}
    if vars ~= nil then
        local index = 1
        for k, v in pairs(vars) do
            if string.len(v.title) <= 24 then
                around_info[index] = {longitude = tonumber(v.location.lng), latitude = tonumber(v.location.lat), name = v.title};
                index = index + 1
                if index >= 11 then
                    break
                end
            end
        end
    end
    return around_info
end

-- 街区定位
function WarZoneRankSystem.RequestLocatizeCurStreetZone()
    ConnectionWaitingUI:Show()
    local function GetLocationCallback()
        EventSystem:unregistEvent(EVENTTYPE_RANK, EVENTID_WARZONE_GET_CITYCODE, GetLocationCallback)
        ConnectionWaitingUI:Hide()
    end
    local function LocationFail(_, _, vars)
        if vars.errorCode ~= 0 then
            ConnectionWaitingUI:Hide()
        end
    end
    local function PermissionFail()
        ConnectionWaitingUI:Hide()
    end
    EventSystem:registEvent(EVENTTYPE_RANK, EVENTID_WARZONE_GET_CITYCODE, GetLocationCallback)
    EventSystem:registEvent(EVENTTYPE_PLATFORM, EVENT_PLATFORM_REQUEST_LOCATION_FINISH, LocationFail)
end

function WarZoneRankSystem.ClearStreetZoneInfo( )
    WarZoneRankSystem.StreetZoneLocationInfo =
    {
        selected_index = 0,
        around_info = {},
    }
    WarZoneRankSystem.StreetZoneRankInfoList = {}
    BP_WarZoneStreetPkIndex = -1
end

-- 街区协议集

-- 请求所有榜单数据
function WarZoneRankSystem.query_lbs_streetzone_my_rank_req(latitude, longitude, rankList)
    NetUtil.SendPkg("query_lbs_streetzone_my_rank_req", latitude, longitude, rankList)
end

function WarZoneRankSystem.query_lbs_streetzone_my_rank_rsp(ret, rankList, rank_no_list)
    if ret == 0 then
        for index, rank in ipairs(rankList) do
            if rank_no_list[index] ~= 0 then
                WarZoneRankSystem.StreetZoneGainTitleList[rank] = rank_no_list[index]
            end
        end
    else
        ShowNotice(ret)
    end
    EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_WARZONE_CUR_STREET_TITLE_LIST, WarZoneRankSystem.StreetZoneGainTitleList);
end

-- 请求单个榜单数据
function WarZoneRankSystem.query_lbs_streetzone_rank_req(latitude, longitude, rank)
    -- log_tree("query_lbs_streetzone_rank_req:", {latitude, longitude, rank})
    NetUtil.SendPriorityPkg(false, "query_lbs_streetzone_rank_rsp", "query_lbs_streetzone_rank_req", latitude, longitude, rank);
end

function WarZoneRankSystem.query_lbs_streetzone_rank_rsp(ret_code, rank, data)
     --log_tree("query_lbs_streetzone_rank_rsp:", {ret_code, rank, data})

    --先清空
    WarZoneRankSystem.StreetZoneRankInfoList = {}
    WarZoneRankSystem.MyRankInfo.no = 0

    if ret_code == 0 then
        if rank ~= WarZoneRankSystem.client_data.rank_type then
            return
        end

        if data ~= nil then
                for i, v in pairs(data) do
                    local item = FuncUtil:CopyTable(WarZoneRankSystem.RankInfoListItem);
                    item.no = v.rank_no;
                    item.uid = tostring(i);
                    item.score = math.floor(v.score + 0.5);
                    WarZoneRankSystem.UpdateRankRole(item, tostring(i));
                    table.insert(WarZoneRankSystem.StreetZoneRankInfoList, item);

                    -- 如果是自己
                    if item.uid == tostring(DataMgr.roleData.uid) then
                        WarZoneRankSystem.MyRankInfo.no = item.no
                    end
                end
        else
        end
        table.sort(WarZoneRankSystem.StreetZoneRankInfoList, function ( a,b )
        return a.no < b.no
        end)
        EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_WARZONE_RANK_UPDATE_LIST)
    else
        DataMgr.ShowMessageBoxByID(ret_code);
    -- elseif ret_code == 1 then
    --     DataMgr.ShowNoticeByString("非法的经纬度参数");
    -- elseif ret_code == 2 then
    --     DataMgr.ShowNoticeByString("经纬度不在中国");
    -- elseif ret_code == 3 then
    --     DataMgr.ShowNoticeByString("非法的排行数据");
    -- elseif ret_code == 4 then
    --     DataMgr.ShowNoticeByString("服务器获取数据失败");
    end
    EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_WARZONE_RANK_UPDATE_LIST)
    WarZoneRankSystem.UpdateRankSelf();
end

local record_pk_req_rank = nil
-- 街区打榜
function WarZoneRankSystem.pk_lbs_streetzone_rank_req(latitude, longitude, rank)
    -- log_tree("pk_lbs_streetzone_rank_req:", {latitude, longitude, rank})
    record_pk_req_rank = rank
    NetUtil.SendPriorityPkg(false, "pk_lbs_streetzone_rank_rsp", "pk_lbs_streetzone_rank_req", latitude, longitude, rank);
    --pk后马上请求排行榜数据
    NetUtil.SendPkg("query_lbs_streetzone_rank_req", latitude, longitude, rank);
end

function WarZoneRankSystem.pk_lbs_streetzone_rank_rsp(ret_code, rank, rank_list)
     --log_tree("pk_lbs_streetzone_rank_rsp:", {ret_code, rank, rank_list})

    if ret_code == 0 then
    else
        DataMgr.ShowMessageBoxByID(ret_code);
    -- elseif ret_code == 1 then
    --     DataMgr.ShowNoticeByString("处于PK冷却中");
    --     return
    -- elseif ret_code == 2 then
    -- elseif ret_code == 3 then
    -- elseif ret_code == 4 then
    -- elseif ret_code == 5 then
    -- elseif ret_code == 6 then
    --     local err_tip = "不能打榜"
    --     if record_pk_req_rank ~= nil then
    --         local rank_cfg = BP_ARRAY_l bsranktypetable[record_pk_req_rank]
    --         if rank_cfg ~= nil then
    --             err_tip = "您的"..rank_cfg.display_desc.."为零，不能打"..rank_cfg.rank_name.."榜"
    --         end
    --     end
    --     --DataMgr.ShowNoticeByString(err_tip);
    end
end

function WarZoneRankSystem.GetRoleAvatarWearReq(uid, source)
    log("GetRoleAvatarWearReq " .. uid .. ",source:" .. tostring(source))
    ProfileMgr.get_avatar_show_req(uid, source);
end

function WarZoneRankSystem.GetRoleAvatarWearRsp(ret_code, uid, callback, avatar_wear_info)
    if ret_code == 0 then
        --log_tree("WarZoneRankSystem GetRoleAvatarWearRsp uid=" .. tostring(uid) .. " ", avatar_wear_info)
        WarZoneRankSystem.RankRoleAvatarInfo[uid] = avatar_wear_info;
        EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_WARZONE_UPDATE_AVATAR, uid)
        return
    elseif ret_code == 1 then
        DataMgr.ShowNoticeByString("avatar参数错误, uid=" .. tostring(uid));
    elseif ret_code == 2 then
        DataMgr.ShowNoticeByString("avatar查询失败, uid=" .. tostring(uid));
    end
    WarZoneRankSystem.RankRoleAvatarInfo[uid] = {avatar = {gamegender = 2, headid = 401999, hairid = 40601001}, wear = {}, avatar_feature_list = {}, weapon_wear = {res_id = 101004001}}
    EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_WARZONE_UPDATE_AVATAR, uid)
end

--获取优先级最高的勋章id
function WarZoneRankSystem.GetFirstMedal()
    local arr = {}
    for k,v in pairs(Client.GetTable("lbsranktypetable")) do
        local item = FuncUtil:CopyTable(v)
        table.insert(arr, item);
    end
    table.sort(arr, function(a, b) return (a.order < b.order) end)
    return arr[1].id;
end

local ShowWarzoneCache = true
function WarZoneRankSystem.ChangeShowWarzoneState(isShow)
    ShowWarzoneCache = isShow
    log("==============changeShow " .. tostring(isShow))
    NetUtil.SendPkg("set_role_setting_req", 1, isShow and 0 or 1)
end

function WarZoneRankSystem.ChangeShowWarzoneState_Rsp(ret)
    if ret ~= NetErrorCode_NONE then
        ShowNotice(ret)
    else
        log("============================ChangeShowWarzoneState_Rsp " .. tostring(ShowWarzoneCache))
        DataMgr.roleData.showWarZone = ShowWarzoneCache
    end
end

function WarZoneRankSystem.GetAreaCfg(areaId)
    for k,v in pairs(Client.GetTable("GlobalCountryCfg")) do
	    if v.Level == 3 and v.ID == areaId then
		    return v;
	    end
    end
    return nil;
end


s2c["modify_lbs_warzone_id_rsp"] = WarZoneRankSystem.ModifyWarZoneRes;
s2c["get_lbs_topn_rank_rsp"] = WarZoneRankSystem.GetWarZoneRankListRes;
s2c["query_lbs_warzone_playernum_rsp"] = WarZoneRankSystem.GetWarZoneRankListCountRes;
s2c["query_lbs_streetzone_rank_rsp"] = WarZoneRankSystem.query_lbs_streetzone_rank_rsp;
s2c["pk_lbs_streetzone_rank_rsp"] = WarZoneRankSystem.pk_lbs_streetzone_rank_rsp;
s2c["get_role_avatar_wear_rsp"] = WarZoneRankSystem.GetRoleAvatarWearRsp;
s2c["batch_get_profile_lbs_warzone_rsp"] = WarZoneRankSystem.RspWarzoneRecodeInfo;
s2c["query_lbs_streetzone_my_rank_rsp"] = WarZoneRankSystem.query_lbs_streetzone_my_rank_rsp;
s2c["set_role_setting_rsp"] = WarZoneRankSystem.ChangeShowWarzoneState_Rsp;
