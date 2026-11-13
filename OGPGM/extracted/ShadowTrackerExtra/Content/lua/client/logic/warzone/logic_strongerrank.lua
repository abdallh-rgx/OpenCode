--[[
  强者榜的相关逻辑：地区强者榜，全国强者榜
]]--

StrongerRankSystem =  StrongerRankSystem or {
    StrongerRankListItem =
    {
        no = 0,
        uid = "",               --唯一id
        name = "",              --名称
        url = "",               --头像
        level = 0,              --等级
        gender = 0,             --性别
        cur_avatar_box_id = 0,  --头像框
        score = 0,              --上榜分数
        stronger_type = 0,      --强者类型：0: 国服最强, 1: 全省第一..
        strongerlist_type = 0,  --榜单类型
        --rank_times = 0,         --上榜次数 
        locationId = 0,         -- 所在地区id              
        --rank_times_map = {},    --上榜次数
    },

    --地区强者榜
	RegionStrongerList = {},    --地区强者榜列表
    RegionLocationId = 0,       --地区强者榜列表,地区Id, 去BP_ARRAY_chinacitytable表里查
    RegionPeopleNumber = 0,     --地区人数
    RegionDataCountryReady = false,    --全服最强数据完成
    RegionDataProvinceReady = false,   --全省第一数据完成
    RegionDataPeopleNumberReady = false, --人数请求完毕
    --全国强者榜
    CountryStrongerList = {},   --国服强者榜列表
    CountryStrongerListType = 0,  --国服强者榜榜单类型
    CountryStrongerUpRankData = 0, --上榜数据显示， 上榜的10个人最低那个的数据，比如刚枪王榜就是十人里击杀数最低那个值
    --请求数据
    client_data =
    {
        --area_type = 0,   --number类型 区域类型(1区, 2市, 3省, 4国)
        rank_id = 0,     --china_city_table key
        count = 0,       --number类型 拉取前n名
    },
    --数据缓存
    StrongerRoleInfo = {},
    StrongerRoleInfoSending = {},
}

--释放
function StrongerRankSystem.Release()
	StrongerRankSystem.RegionStrongerList = {};
	StrongerRankSystem.CountryStrongerList = {};
end

--获取国服id
function GetCountryRankId()
    local countryId = 100000;

    return countryId;
end

--数据缓存机制
function StrongerRankSystem.ProcessStrongerRoleInfoList(list)
    for k,v in pairs(list) do
        local role = FuncUtil:CopyTable(StrongerRankSystem.StrongerRankListItem)
        role.uid = tostring(k);
        role.name  = v.nickName;
        role.url   = v.picUrl;
        role.level = v.level;
        role.gender = v.sex;
        if type(v.cur_avatar_box_id) == "number" then
            role.cur_avatar_box_id = v.cur_avatar_box_id
        end
        --if v.lbs_warzone_info ~= nil then
            --role.locationId = v.lbs_warzone_info.warzone_id;
        --end
		if v.warZoneID ~= 0 then
			role.locationId = v.warZoneID;
		end
		
        StrongerRankSystem.StrongerRoleInfo[role.uid] = role;
        StrongerRankSystem.StrongerRoleInfoSending[role.uid] = os.time();
    end
end

function StrongerRankSystem.ReqCountryStrongerData()
    StrongerRankSystem.CountryStrongerListType = BP_STRUCT_WarZoneMedalInfo.id;
    StrongerRankSystem.client_data.rank_type = BP_STRUCT_WarZoneMedalInfo.id;
    StrongerRankSystem.client_data.rank_id = 100000;

    --log_tree("StrongerRankSystem.client_data = ", StrongerRankSystem.client_data);

    NetUtil.SendPriorityPkg(false, "get_lbs_global_rank_rsp", "get_lbs_global_rank", StrongerRankSystem.client_data);
end

function StrongerRankSystem.RspCountryStrongerData(ret, client_data, rank_list_map)
    --log_tree("ret = ", ret);
    --log_tree("client_data = ", client_data);
    --log_tree("rank_list_map = ", rank_list_map);

    if true then
        --return
    end

    if ret == 0 then
        StrongerRankSystem.CountryStrongerList = {}
        StrongerRankSystem.AddCountryStrongerData(rank_list_map);
    else
        log(ret)
        ShowNotice(ret)
    end
end

--添加国服榜数据
function StrongerRankSystem.AddCountryStrongerData(rank_list_map)   
    local targetRankData = rank_list_map[StrongerRankSystem.CountryStrongerListType];
    local minScore = 0; --最小分数
    if targetRankData ~= nil then
        --log_tree("StrongerRankSystem.AddCountryStrongerData",{targetRankData, StrongerRankSystem.CountryStrongerListType});
        for index, innerItem in pairs(targetRankData) do
            local item = FuncUtil:CopyTable(StrongerRankSystem.StrongerRankListItem);
            item.no = innerItem.rank_no;
            item.uid = innerItem.uid;
            item.score = math.floor(innerItem.score + 0.5);
            table.insert(StrongerRankSystem.CountryStrongerList, item);
            if (minScore == 0) or (minScore > innerItem.score) then
                minScore = innerItem.score;
            end
        end   
        StrongerRankSystem.CountryStrongerUpRankData = minScore;  --上榜数据

        LuaClassObj.HandleDynamicCreation(bp_countrystrongerrank);
        LuaClassObj.HandleUIMessage(bp_countrystrongerrank, "ShowUI"); 
        UIManager.Show(eUIType.eCountryStrongerRankUI)
        CountryStrongerRankUI.isShowing = true;
        EventSystem:registEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN, CountryStrongerRankUI.WardRobeAvatarResetOpen);
        EventSystem:registEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE, CountryStrongerRankUI.WardRobeAvatarResetClose);	

        StrongerRankSystem.GetCountryStrongerPlayerInfo(); --获取用户数据   
    end
end

--请求国服强者榜用户数据
function StrongerRankSystem.GetCountryStrongerPlayerInfo()
    if StrongerRankSystem.CountryStrongerList ~= nil then
        local listUid = {};
        local uidMap = {};
        for i,item in ipairs(StrongerRankSystem.CountryStrongerList) do
            --作缓存机制
            if uidMap[item.uid] == nil then
                uidMap[item.uid] = true;
                local curtm = os.time();
                local tm = StrongerRankSystem.StrongerRoleInfoSending[item.uid];
                if tm == nil or (curtm - tm > 60) then
                    --StrongerRankSystem.StrongerRoleInfoSending[item.uid] = curtm;
                    table.insert(listUid, tonumber(item.uid));
                end
            end
        end
        --log_tree("listUid = ", listUid);
        -- 查询用户信息
        if #listUid > 0 then
            ProfileMgr.GetProfileList(listUid, StrongerRankSystem.RspCountryStrongerRoleInfo, false, false);
        else
            StrongerRankSystem.UpdateCountryStrongerList();
        end
    end
end

--国服榜用户数据
function StrongerRankSystem.RspCountryStrongerRoleInfo(profileList)
    --log_tree("profileList = ", profileList);

    if type(profileList) ~= "table" then
        return;
    end

    local list = {};
    for i,v in ipairs(profileList) do
        list[v.uid] = v;
    end

    --提取数据
    StrongerRankSystem.ProcessStrongerRoleInfoList(list);
    StrongerRankSystem.UpdateCountryStrongerList();
end

--刷新国服强者榜列表数据
function StrongerRankSystem.UpdateCountryStrongerList()
    local tmpList = FuncUtil:CopyTable(StrongerRankSystem.CountryStrongerList);
    --log_tree("tmpList 1 = ", tmpList);

    StrongerRankSystem.CountryStrongerList = {};
    for i, v in pairs(tmpList) do
        if StrongerRankSystem.StrongerRoleInfo[v.uid] ~= nil then
            local item = StrongerRankSystem.StrongerRoleInfo[v.uid];
            StrongerRankSystem.RefreshCountryStrongerData(v, item);           
        end
    end

    --log_tree("tmpList 2 = ", tmpList);

    EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_COUNTRY_STRONGER_RANK_UPDATE_LIST);
end

--刷新国服强者用户数据
function StrongerRankSystem.RefreshCountryStrongerData(regionData, cacheData)
    --log_tree("regionData:",{regionData});
    --log_tree("profileData:",{cacheData});
    local item = FuncUtil:CopyTable(regionData);
    item.name = cacheData.name;
    item.url = cacheData.url;
    item.level = cacheData.level;
    item.gender = cacheData.gender;
    item.cur_avatar_box_id = cacheData.cur_avatar_box_id;
    item.locationId = cacheData.locationId;
    table.insert(StrongerRankSystem.CountryStrongerList, item);  
end

--请求拉取地区强者榜数据
function StrongerRankSystem.GetRegionStrongerData()
    log("StrongerRankSystem.GetRegionStrongerData()");
    if WarZoneRankSystem.client_data == nil then
        return;
    end
    StrongerRankSystem.RegionStrongerList = {}; --清理一次
    StrongerRankSystem.RegionDataCountryReady = false;    --全服最强数据完成
    StrongerRankSystem.RegionDataProvinceReady = false;   --全省第一数据完成
    StrongerRankSystem.RegionDataPeopleNumberReady = false;
    StrongerRankSystem.RegionLocationId = WarZoneRankSystem.client_data.rank_id; --地区ID
    
    --全国最强，前100
    local rankId = WarZoneRankSystem.client_data.rank_id;
    StrongerRankSystem.ReqFetchStrongerData(rankId, 100);
    --全省第一   
    --local rankId = 0;
    --if city ~= nil then
        --rankId = city.province_id;
        --StrongerRankSystem.ReqFetchStrongerData(rankId, 1);
    --end
    --地区人数
    --StrongerRankSystem.ReqFetchRegionPeopleNumber(StrongerRankSystem.RegionLocationId)
end

--请求拉取地区强者榜
function StrongerRankSystem.ReqFetchStrongerData(rankid, count)
    log("StrongerRankSystem ReqFetchStrongerData: type=" ..tostring(rankid));
    StrongerRankSystem.client_data.rank_id = math.floor(rankid / 100000) * 100000;
    StrongerRankSystem.client_data.count = count;
    NetUtil.SendPriorityPkg(false, "get_lbs_strongest_rank_rsp", "get_lbs_strongest_rank", StrongerRankSystem.client_data);
end

local REQ_LBS_STRONGEST_RANK_OK = 0              -- 成功
local REQ_LBS_STRONGEST_RANK_ERR_SYS = 1         -- 后台数据错误
local REQ_LBS_STRONGEST_RANK_ERR_WARZONE = 2     -- 无效的战区（未设置战区或者战区为海外）
local REQ_LBS_STRONGEST_RANK_ERR_PARAM = 3       -- client_data参数错误
local REQ_LBS_STRONGEST_RANK_ERR_WAIT = 4        -- 1秒钟一种area_type只能查一次

--返回拉取地区强者榜
function StrongerRankSystem.RspFetchStrongerData(ret_code, client_data, rank_list_map)
    log("StrongerRankSystem.RspFetchStrongerData ret_code = " ..tostring(ret_code));
    --log_tree("StrongerRankSystem.RspFetchStrongerData ret=", {ret_code, client_data, rank_list_map});

    if ret_code == REQ_LBS_STRONGEST_RANK_OK then
        StrongerRankSystem.AddRegionStrongerData(rank_list_map, client_data.rank_id);
    else
        DataMgr.ShowMessageBoxByID(ret_code);
    end

end

--请求地区强者榜用户数据
function StrongerRankSystem.GetRegionStrongerPlayerInfo()
    if StrongerRankSystem.RegionStrongerList ~= nil then
        local listUid = {};
        local uidMap = {};
        for i, item in pairs(StrongerRankSystem.RegionStrongerList) do
            ---table.insert(listUid, tonumber(v.uid));
            if uidMap[item.uid] == nil then
                uidMap[item.uid] = true;
                --作缓存机制
                --local role = StrongerRankSystem.StrongerRoleInfo[item.uid];
                --if role == nil then
                    local curtm = os.time();
                    local tm = StrongerRankSystem.StrongerRoleInfoSending[item.uid];
                    if tm == nil or (curtm - tm > 120) then --两分钟请求
                        --StrongerRankSystem.StrongerRoleInfoSending[item.uid] = curtm;
                        table.insert(listUid, tonumber(item.uid));
                    end
                --end
            end
        end
        --ConnectionWaitingUI:Show();
        -- 查询用户信息
        if #listUid > 0 then
            log("StrongerRankSystem.GetRegionStrongerPlayerInfo"..tostring(#listUid));
            --ProfileMgr.GetProfileList(listUid, StrongerRankSystem.RspRegionStrongerRoleInfo, false, false);
            --当数据量太大，分批请求
            if #listUid > 50 then
                local tempIdList = {};
                for i, uid in ipairs(listUid) do
                    table.insert(tempIdList, uid);
                    if #tempIdList == 30 or i == #listUid then
                        ProfileMgr.GetProfileList(tempIdList, StrongerRankSystem.RspRegionStrongerRoleInfo, false, false);
                        tempIdList = {};
                    end
                end
            else
                ProfileMgr.GetProfileList(listUid, StrongerRankSystem.RspRegionStrongerRoleInfo, false, false);
            end
        else
            StrongerRankSystem.UpdateRegionStronerList();
        end
    end
end

--获取地区强者用户信息
function StrongerRankSystem.RspRegionStrongerRoleInfo(profileList)
    --log_tree("StrongerRankSystem.RspRegionStrongerRoleInfo",{profileList});

    if type(profileList) ~= "table" then
        return;
    end

    local list = {};
    for i,v in ipairs(profileList) do
        list[v.uid] = v;
    end
    
    --提取数据
    StrongerRankSystem.ProcessStrongerRoleInfoList(list);
    -- --信息准备完成
    -- for i, item in pairs(StrongerRankSystem.RegionStrongerList) do
    --     if StrongerRankSystem.StrongerRoleInfo[item.uid] == nil then
    --         return;
    --     end
    -- end
    --刷新列表
    StrongerRankSystem.UpdateRegionStronerList();
end

--地区强者列表数据更新
function StrongerRankSystem.UpdateRegionStronerList()
    --log("StrongerRankSystem.UpdateRegionStronerList");
    --ConnectionWaitingUI:Hide();
    --过滤操作：对于同时为全省第一和国服最强，只显示国服最强
    local tmpCountryStrongerMap = {};
    for i, v in pairs(StrongerRankSystem.RegionStrongerList) do
        if v.stronger_type == 0 then
            if tmpCountryStrongerMap[v.uid] == nil then
                local typeMap = {};
                typeMap[v.strongerlist_type] = true;
                tmpCountryStrongerMap[v.uid] = typeMap;
            else
                tmpCountryStrongerMap[v.uid][v.strongerlist_type] = true;
            end
        end
    end

    local tmpList = FuncUtil:CopyTable(StrongerRankSystem.RegionStrongerList);
    StrongerRankSystem.RegionStrongerList = {};
    for i, v in pairs(tmpList) do
        if StrongerRankSystem.StrongerRoleInfo[v.uid] ~= nil then
            local item = StrongerRankSystem.StrongerRoleInfo[v.uid];
            StrongerRankSystem.RefreshRegionStrongerData(v, item);   
        end
    end
    --打开UI并触发数据更新   
    EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_REGION_STRONGER_RANK_UPDATE_LIST);
end

--刷新地区用户数据
function StrongerRankSystem.RefreshRegionStrongerData(regionData, cacheData)
    --log_tree("profileData:",{cacheData});

    if cacheData.locationId ~=  StrongerRankSystem.RegionLocationId then --在不在目标区
        --log("not in target region")
        --return;
    end
    local item = FuncUtil:CopyTable(regionData);
    item.name = cacheData.name;
    item.url = cacheData.url;
    item.level = cacheData.level;
    item.gender = cacheData.gender;
    item.cur_avatar_box_id = cacheData.cur_avatar_box_id;
    --if cacheData.rank_times_map[regionData.strongerlist_type] ~= nil then
        --local rankTimeMap = cacheData.rank_times_map[regionData.strongerlist_type];
        --if rankTimeMap[regionData.locationId] ~= nil then
            --item.rank_times = rankTimeMap[regionData.locationId].times;
        --end
    --end
    table.insert(StrongerRankSystem.RegionStrongerList, item);  
end

--添加地区榜数据
function StrongerRankSystem.AddRegionStrongerData(rank_list_map, rankid)
    log("StrongerRankSystem.AddRegionStrongerData, rankid=" ..tostring(rankid));

    for rank_type, rank_list in pairs(rank_list_map) do
        for j, innerItem in pairs(rank_list) do
            local item = FuncUtil:CopyTable(StrongerRankSystem.StrongerRankListItem);
            item.no = innerItem.rank_no;
            item.uid = innerItem.uid;
            item.score = math.floor(innerItem.score + 0.5);
            item.locationId = innerItem.warzone_id;
            item.stronger_type = 0;
            item.strongerlist_type = rank_type;           
            table.insert(StrongerRankSystem.RegionStrongerList, item);
        end
    end   
    --log_tree("StrongerRankSystem.RegionStrongerList = ", StrongerRankSystem.RegionStrongerList);
    LuaClassObj.HandleDynamicCreation(bp_regionstrongerrank);
    LuaClassObj.HandleUIMessage(bp_regionstrongerrank, "ShowUI");
    UIManager.Show(eUIType.eRegionStrongerRankUI)
    EventSystem:registEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN, RegionStrongerRankUI.WardRobeAvatarResetOpen);
    EventSystem:registEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE, RegionStrongerRankUI.WardRobeAvatarResetClose);
    RegionStrongerRankUI.isShowing = true;

    StrongerRankSystem.GetRegionStrongerPlayerInfo();
end

--请求地区人数
function StrongerRankSystem.ReqFetchRegionPeopleNumber(regionid)
    log("StrongerRankSystem.ReqFetchRegionPeopleNumber: region id=" ..tostring(regionid));
    WarZoneRankSystem.GetWarZoneRankListCountReq(regionid);
end

function StrongerRankSystem.GetAreaStrongName(areaId)
    local idMap = 
    {
        [1] = 4700;
        [2] = 4701;
        [3] = 4699;
        [4] = 4698;
        [6] = 4702;
    };
    if idMap[areaId] == nil then
        return ""
    end
    local data = Client.GetTableData("LocalizeRes", idMap[areaId]);
    if data == nil then
        return ""
    end
    return data.TextValue;
end


--[[网络回调]]--
s2c["get_lbs_strongest_rank_rsp"] = StrongerRankSystem.RspFetchStrongerData;
s2c["get_lbs_global_rank_rsp"] = StrongerRankSystem.RspCountryStrongerData;