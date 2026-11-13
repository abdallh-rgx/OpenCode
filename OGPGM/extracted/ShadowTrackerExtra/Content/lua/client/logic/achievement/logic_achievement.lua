AchievementSystem = AchievementSystem or
{
    -- 成就系统初始化数据
    Data = {},
    --用于查找属于同一组成就id
    MultiLvGroupIDMap = {},
    --条件类型数据
    ConditionTypeData = {},
    --条件、成就map数据
    ConditionMap = {},
    -- 积分奖励领取情况
    ScoreAward = {},
    -- 成就种类个数map
    GroupNumMap = {},
    -- 个人成就首页总览数据
    Summary = {
        achieve_score = 0, -- 总积分
        show = {0, 0, 0, 0}, -- 槽位展示的成就id
        time = {0, 0, 0, 0}, -- 成就获得的时间点
        progress = {}, -- 进度汇总，各子类的进度
    },
    -- 缓存同时到达的多个成就的ID
    AchievementIDList = {},
    hasTotalData = false,
    firstInitialize = false, -- 成就系统是否已初始化（全局状态保存在本地PlayerPrefs中）
    totalNum = 0,
    cacheRegion = "",
    AsyncShowCommmonPannel,
    AsycCacheId,
}

function AchievementSystem.Enter()
    log("[yyc] AchievementSystem Enter");
    AchievementSystem.InitData();
    AchievementSystem.get_achieve_rewards_list_req();
    AchievementSystem.get_achievement_data_req();
    AchievementSystem.get_achievement_summary_req(DataMgr.roleData.uid);
    AchievementSystem.get_achieve_record_rewards_list_req();
    AchievementSystem.get_achieve_hit_list_req();
end

function AchievementSystem.Release()
    log("[yyc] AchievementSystem Release");
end

function AchievementSystem.GetNextID(CurrID)
    local data = AchievementSystem.Data[CurrID] 
    if data == nil or data.NextID == nil then
        return 0
    end
    return data.NextID
end

function AchievementSystem.GetPreID(CurrID)
    local data = AchievementSystem.Data[CurrID] 
    if data == nil or data.PreID == nil then
        return 0
    end
    return data.PreID
end

function AchievementSystem.InitData()
    log("[yyc] AchievementSystem InitData");
    AchievementSystem.ResetData();
    
    AchievementSystem.InitConditionTypeData();
    
    local tb = Client.GetTable("AchievementCfg");
    local isJPorKR = AchievementSystem.IsJAPANorKOREA();
    --有些成就不在日韩显示
    for id, value in pairs(tb) do
        id = tonumber(id);
        AchievementSystem.Data[id] = AchievementSystem.Data[id] or {};
        AchievementSystem.Data[id].ID = value.ID;
        AchievementSystem.Data[id].Name = value.Name;
        AchievementSystem.Data[id].GroupID = value.GroupID;
        AchievementSystem.Data[id].AwardID = value.AwardID;
        AchievementSystem.Data[id].AwardNum = value.AwardNum;
        AchievementSystem.Data[id].AwardID2 = value.AwardID2 or 0;
        AchievementSystem.Data[id].AwardNum2 = value.AwardNum2 or 0;
        AchievementSystem.Data[id].Score = value.Score;
        AchievementSystem.Data[id].PreID = value.PreID;
        local preID = tonumber(value.PreID)
        if preID ~= 0 then
            AchievementSystem.Data[preID] = AchievementSystem.Data[preID] or {}
            AchievementSystem.Data[preID].NextID = id
        end
        AchievementSystem.Data[id].Desc = value.Desc;
        AchievementSystem.Data[id].ShareFlag = value.ShareFlag;
        AchievementSystem.Data[id].ImgUrl = value.ImgUrl;
        AchievementSystem.Data[id].BigImgUrl = value.BigImgUrl;
        AchievementSystem.Data[id].ShowType = value.ShowType;
        AchievementSystem.Data[id].MultiLvGroupID = value.MultiLvGroupID; --多阶成就组id
        AchievementSystem.Data[id].MultiLvGroupTitle = value.MultiLvGroupTitle; --多阶成就组title
        AchievementSystem.Data[id].MultiLvGroupNum = value.MultiLvGroupNum; --多阶成就阶数
        AchievementSystem.Data[id].State = BP_ENUM_ACHIEVEMENT_STATE_NOT_FINISH;
        AchievementSystem.Data[id].FinishTime = 0;
        AchievementSystem.Data[id].TotalProcess = 1;
        AchievementSystem.Data[id].CurProcess = 0;
        AchievementSystem.Data[id].ConditionNum = 0;
        AchievementSystem.Data[id].ParamDes = ""; --描述里替换的物品、模式等文字
        AchievementSystem.Data[id].Show = true;
        AchievementSystem.Data[id].UpdateTime = 0; --发生变动的时间
        AchievementSystem.Data[id].ParserCnds = {};
        AchievementSystem.Data[id].Version = AchievementSystem.ParserVersion(value.Version);
        AchievementSystem.Data[id].ShowNew = FuncUtil:IsMatchVersion(value.Version);
        AchievementSystem.Data[id].GlobalEnable = value.GlobalEnable;
        AchievementSystem.Data[id].JPKREnable = value.JPKREnable;
        
        local ret = AchievementSystem.ParserCondition(value.Conditions);
        AchievementSystem.AddConditionData(ret, value.ID);
        AchievementSystem.AddMultiLvGroupData(value.ID, value.MultiLvGroupID);
        
        for i = 1, #ret do
            local cnd = ret[i];
            if not AchievementSystem.Data[id].ParserCnds[cnd.id] then
                AchievementSystem.Data[id].ParserCnds[cnd.id] = {};
            end
            if not AchievementSystem.Data[id].ParserCnds[cnd.id][cnd.param] then
                AchievementSystem.Data[id].ParserCnds[cnd.id][cnd.param] = {};
            end
            AchievementSystem.Data[id].ParserCnds[cnd.id][cnd.param] = cnd;
        end
        --如果这个成就只有一个条件，那么条件描述就是成就描述,进度也是一致的
        if #ret == 1 then
            AchievementSystem.Data[id].Desc = ret[1].des;
            AchievementSystem.Data[id].ParamDes = ret[1].paramDes;
            AchievementSystem.Data[id].TotalProcess = ret[1].totalProcess;
        else
            AchievementSystem.Data[id].TotalProcess = #ret;
        end
        AchievementSystem.Data[id].ConditionNum = #ret;
    end
    
    --更新多阶信息
    for mid, _ in pairs(AchievementSystem.MultiLvGroupIDMap) do
        AchievementSystem.UpdateMultiLvGroupIDShowInfo(mid);
    end
    AchievementSystem.UpdateAchievementNum();
    --log_tree("[yyc] AchievementSystem data", AchievementSystem.Data);
end

function AchievementSystem.IsValidAchievementID(id)
    local isJPorKR = AchievementSystem.IsJAPANorKOREA();
    local data = AchievementSystem.Data[id];
    if not data then
         data = Client.GetTableData("AchievementCfg", id);
    end
    if data then
        if (isJPorKR == false and data.GlobalEnable == true) or
            (isJPorKR == true and data.JPKREnable == true) then
            return true;
        else
            return false;
        end
    else
        return false;
    end
end

function AchievementSystem.ParserVersion(version)
    local ret = 0;
    local versions = string.split(version, ".");
    if not versions or #versions ~= 3 then
        log("[yyc] version is not valid"..tostring(version));
        return ret;
    end
    
    local d = {10000, 100, 1};
    for i = 1, #versions do
        ret = ret + tonumber(versions[i]) * d[i];
    end
    
    --log("[yyc] ParserVersion ret = "..ret);
    return ret;
end

function AchievementSystem.GetNewFlag(id)
    if AchievementSystem.Data[id] then
        return AchievementSystem.Data[id].ShowNew;
    else
        return false;
    end
end

function AchievementSystem.SetNewFlag(id, show)
    log("[yyc]AchievementSystem.SetNewFlag id = "..tostring(id) .. " show = "..tostring(show));
    local data = AchievementSystem.Data[id];
    if data then
        if show then
            data.ShowNew = true;
        else
            data.ShowNew = false;
        end
    else
        log("[yyc] AchievementSystem.SetNewFlag id is not valid :"..tostring(id));
    end
end

function AchievementSystem.IsJAPANorKOREA()
    if AchievementSystem.cacheRegion == "" then
        AchievementSystem.cacheRegion = Client.GetPublishRegion();
    end
    local strRegion = AchievementSystem.cacheRegion;
    local isJPorKR = false;
    if strRegion == "JAPAN" or strRegion == "KOREA" then
        isJPorKR = true;
    end
    --log("[yyc] AchievementSystem.IsJAPANorKOREA "..tostring(isJPorKR));
    return isJPorKR;
end

function AchievementSystem.GetAchievementDataByID(id)
    local ret = AchievementSystem.Data[id];
    if not ret then
        log("[yyc] invalid achievement id "..id);
    end
    return ret;
end

function AchievementSystem.InitConditionTypeData()
    AchievementSystem.ConditionTypeData = {};
    local tb = Client.GetTable("AchievementCondTypeCfg");
    for k, v in pairs(tb) do
        if v.Param2ID then
            if not AchievementSystem.ConditionTypeData[v.Param2ID] then
                AchievementSystem.ConditionTypeData[v.Param2ID] = {};
            end
            
            if not AchievementSystem.ConditionTypeData[v.Param2ID][v.Param2TypeID] then
                AchievementSystem.ConditionTypeData[v.Param2ID][v.Param2TypeID] = {};
            end
            
            AchievementSystem.ConditionTypeData[v.Param2ID][v.Param2TypeID].Desc = v.Desc;
        else
            log("[yyc] invalid Param2ID "..v.Param2ID);
        end
    end
end

function AchievementSystem.GetConditionTypeData(id, type)
    if AchievementSystem.ConditionTypeData[id] and AchievementSystem.ConditionTypeData[id][type] then
        return AchievementSystem.ConditionTypeData[id][type];
    end
end

function AchievementSystem.AddConditionData(ret, achievementID)
    if not ret then
        log("yyc AchievementSystem AddConditionData ret not valid");
        return;
    end
    for i = 1, #ret do
        local cnd = ret[i];
        if not cnd.id then
            log("yyc AchievementSystem AddConditionData condition id not valid");
            return;
        end
        
        if not AchievementSystem.ConditionMap[cnd.id] then
            AchievementSystem.ConditionMap[cnd.id] = {};
        end
        
        if not AchievementSystem.ConditionMap[cnd.id][cnd.param] then
            AchievementSystem.ConditionMap[cnd.id][cnd.param] = {};
        end
        table.insert(AchievementSystem.ConditionMap[cnd.id][cnd.param], achievementID);
    end
end

function AchievementSystem.AddMultiLvGroupData(achievementID, groupID)
    local isValid = AchievementSystem.IsValidAchievementID(achievementID);
    if groupID == 0 or not isValid then
        return;
    end
    if not AchievementSystem.MultiLvGroupIDMap[groupID] then
        AchievementSystem.MultiLvGroupIDMap[groupID] = {};
    end
    table.insert(AchievementSystem.MultiLvGroupIDMap[groupID], achievementID);
end

function AchievementSystem.GetAchievementIDsByMultiLvGroup(groupID)
    return AchievementSystem.MultiLvGroupIDMap[groupID];
end

function AchievementSystem.ParserCondition(cnds)
    local ret = {};
    local data = string.split(cnds, ";");
    if #data <= 0 then
        log("yyc AchievementSystem ParserCondition data not valid  ");
        return;
    end
    
    for i = 1, #data do
        if data[i] and data[i] ~= "" then
            -- 分割后数据：条件id，总进度，条件参数id
            local temp = string.split(data[i], "-");
            local tempCndID = tonumber(temp[1]);
            local tempProcess = tonumber(temp[2]);
            local tempParam = tonumber(temp[3]); --成就表条件类型里的参数2选项id
            if tempCndID == 37 then --段位这个条件需要特殊处理，既是进度又是参数id
                tempParam = tonumber(temp[2]);
            end
            if tempCndID and tempProcess and tempParam then
                local cndData = Client.GetTableData("AchievementCondCfg", tempCndID);
                local cndTypeData = AchievementSystem.GetConditionTypeData(cndData.Param2ID, tempParam);
                local tempParamDes = "";
                if cndTypeData then
                    tempParamDes = cndTypeData.Desc;
                else
                    --如果没有找到数据那么配置的就是物品表里的id
                    local itemCfg = Client.GetTableData("Item", tempParam);
                    if itemCfg then
                        tempParamDes = itemCfg.ItemName;
                    else
                        log("[yyc] ParserCondition item id not valid "..tempParam);
                    end
                end
                
                table.insert(ret, {id = tempCndID,
                    totalProcess = tempProcess,
                    des = cndData.Desc,
                    curProcess = 0,
                    param = tonumber(temp[3]),
                    paramID = cndData.Param2ID,
                    paramDes = tempParamDes,
                });
            else
                log("yyc AchievementSystem ParserCondition cnds not valid :"..data[i]);
            end
        end
    end
    return ret;
end

function AchievementSystem.GetAchievementIDsByCondition(cndID, param)
    if AchievementSystem.ConditionMap[cndID] and AchievementSystem.ConditionMap[cndID][param] then
        return AchievementSystem.ConditionMap[cndID][param];
    else
        log("[yyc] GetAchievementIDsByCondition invalid cnd ID "..cndID.."param"..param);
        return nil;
    end
end

function AchievementSystem.UpdateAchievementProcess(achievementID, cndID, param)
    local data = AchievementSystem.Data[achievementID];
    if data.ConditionNum == 1 then
        data.CurProcess = data.ParserCnds[cndID][param].curProcess;
    else
        local cnds = data.ParserCnds;
        data.CurProcess = 0;
        for _, cnd in pairs(cnds) do
            for _, v in pairs(cnd) do
                if v.curProcess >= v.totalProcess then
                    data.CurProcess = data.CurProcess + 1;
                end
            end
        end
    end
    local preState = data.State;
    if data.FinishTime > 0 then
        data.State = BP_ENUM_ACHIEVEMENT_STATE_FINISH_GET_AWARD;
    elseif data.CurProcess >= data.TotalProcess then
        data.State = BP_ENUM_ACHIEVEMENT_STATE_FINISH_NO_AWARD;
    else
        data.State = BP_ENUM_ACHIEVEMENT_STATE_NOT_FINISH;
    end
    AchievementSystem.UpdateMultiLvGroupIDShowInfo(data.MultiLvGroupID)
    
    if data.State == BP_ENUM_ACHIEVEMENT_STATE_FINISH_NO_AWARD then
        BP_ARRAY_AchievementRedPointList[data.GroupID] = true;
    end
    
    if preState == BP_ENUM_ACHIEVEMENT_STATE_NOT_FINISH and data.State == BP_ENUM_ACHIEVEMENT_STATE_FINISH_NO_AWARD then
        return true; --成就是否从未完成到完成
    else
        return false;
    end
end

function AchievementSystem.UpdateMultiLvGroupIDShowInfo(multiLvGroupID)
    --计算多阶成就里的成就是否可见
    local ids = AchievementSystem.GetAchievementIDsByMultiLvGroup(multiLvGroupID);
    if ids and #ids > 0 then
        local notGetData; --未领取里的最低阶成就
        local getData; --已领取里的最高阶成就
        for _, v in pairs(ids) do
            local tempData = AchievementSystem.Data[v];
            tempData.Show = false;
            if tempData.State == BP_ENUM_ACHIEVEMENT_STATE_FINISH_GET_AWARD then
                if not getData then
                    getData = tempData;
                else
                    if tempData.TotalProcess >= getData.TotalProcess then
                        getData = tempData;
                    end
                end
            end
            if tempData.State ~= BP_ENUM_ACHIEVEMENT_STATE_FINISH_GET_AWARD then
                if not notGetData then
                    notGetData = tempData;
                else
                    if tempData.TotalProcess < notGetData.TotalProcess then
                        notGetData = tempData;
                    end
                end
            end
        end
        if notGetData then
            AchievementSystem.Data[notGetData.ID].Show = true;
        end
        if getData then
            AchievementSystem.Data[getData.ID].Show = true;
        end
    end
end

function AchievementSystem.GetAchievementCategoryNum(groupID)
    local num = AchievementSystem.GroupNumMap[groupID] or 0;
    return num;
end

function AchievementSystem.GetAchievementTotalNum()
    return AchievementSystem.totalNum;
end

function AchievementSystem.UpdateAchievementNum()
    for k, v in pairs(AchievementSystem.Data) do
        local isValidID = AchievementSystem.IsValidAchievementID(v.ID);
        if isValidID then
            if not AchievementSystem.GroupNumMap[v.GroupID] then
                AchievementSystem.GroupNumMap[v.GroupID] = 0;
            end
            AchievementSystem.GroupNumMap[v.GroupID] = AchievementSystem.GroupNumMap[v.GroupID] + 1;
            AchievementSystem.totalNum = AchievementSystem.totalNum +  1;
        end
    end
end

function AchievementSystem.ResetData()
    --log("[yyc] AchievementSystem ResetData");
    AchievementSystem.hasTotalData = false;
    AchievementSystem.Data = {};
    AchievementSystem.ConditionMap = {};
    AchievementSystem.MultiLvGroupIDMap = {};
    AchievementSystem.ConditionTypeData = {};
    AchievementSystem.GroupNumMap = {};
    AchievementSystem.totalNum = 0;
    BP_ARRAY_AchievementRedPointList =
    {
        [1] = false,
        [2] = false,
        [3] = false,
        [4] = false,
        [5] = false,
        [6] = false,
        [7] = false,
    };
end

function AchievementSystem.CanGetAwardNum(groupID)
    local ret = 0;
    for _, v in pairs(AchievementSystem.Data) do
        local isValidID = AchievementSystem.IsValidAchievementID(v.ID);
        if v.GroupID == groupID and v.State == BP_ENUM_ACHIEVEMENT_STATE_FINISH_NO_AWARD and isValidID then
            ret = ret + 1;
        end
    end
    return ret;
end

--获取成就领取列表
function AchievementSystem.get_achieve_rewards_list_req()
    log("[yyc] AchievementSystem get_achieve_rewards_list_req");
    NetUtil.SendPriorityPkg(false, "get_achieve_rewards_list_res", "get_achieve_rewards_list_req");
end

function AchievementSystem.get_achieve_rewards_list_res(res)
    --log_tree("[yyc] AchievementSystem get_achieve_rewards_list_res", res);
    for k, v in pairs(res) do
        AchievementSystem.Data[k].FinishTime = v;
    end
end

--获取当前成就数据
function AchievementSystem.get_achievement_data_req()
    log("[yyc] AchievementSystem get_achievement_data_req");
    NetUtil.SendPriorityPkg(false, "get_achievement_data_res", "get_achievement_data_req");
end

function AchievementSystem.get_achievement_data_res(type, res)
    --log_tree("[yyc] AchievementSystem get_achievement_data_res", res);
    log("[yyc] AchievementSystem get_achievement_data_res type "..type.." AchievementSystem.hasTotalData "..tostring(AchievementSystem.hasTotalData));
    
    if not AchievementSystem.hasTotalData and type == 2 then
        --全量数据没有收到之前屏蔽掉所有的增量消息
        return;
    end
    
    local stateChangeIDS = {};
    for cndID, v in pairs(res) do
        for param, info in pairs(v) do
            local achievementIDs = AchievementSystem.GetAchievementIDsByCondition(cndID, param);
            if achievementIDs then
                for _, achievementID in pairs(achievementIDs) do
                    local isValid = AchievementSystem.IsValidAchievementID(achievementID);
                    if isValid then
                        AchievementSystem.Data[achievementID].UpdateTime = info[2] or 0;

                        if info[1] then
                            AchievementSystem.Data[achievementID].ParserCnds[cndID][param].curProcess = math.floor(info[1]);
                        else
                            AchievementSystem.Data[achievementID].ParserCnds[cndID][param].curProcess = 0;
                        end
                        
                        local stateChange = AchievementSystem.UpdateAchievementProcess(achievementID, cndID, param);
                        if stateChange then
                            stateChangeIDS[achievementID] = true;
                        end
                    end
                end
            end
        end
    end
    
    --1全量，2更新
    if type == 1 then
        if next(res) == nil then
            --gm重置命令才会走到这里
            AchievementSystem.InitData();
        end
        AchievementSystem.hasTotalData = true;
        
        log("AchievementSystem get_achievement_data_res firstInitialize="..tostring(AchievementSystem.firstInitialize))
        if AchievementSystem.firstInitialize then
            AchievementSystem.GetFinishedList() -- 首次开启成就系统
            AchievementSystem.firstInitialize = false
        end
    elseif type == 2 then
        for k, v in pairs(stateChangeIDS) do
            if v then
                AchievementSystem.PushNewAchievement(k);
                AchievementSystem.report_achievement_finish(k)
            end
        end
    end
    
    AchievementTaskUI.UpdateAchievementShowList();
    AchievementTaskUI.UpdateAchievementSubTabRedPoint();
end

--领取奖励
function AchievementSystem.get_achievement_rewards_req(id)
    log("[yyc] AchievementSystem get_achievement_rewards_req"..id);
    NetUtil.SendPriorityPkg(false, "get_achievement_rewards_res", "get_achievement_rewards_req", id);
end

function AchievementSystem.get_achievement_rewards_res(id, result, timestamps)
    --log("[yyc] AchievementSystem get_achievement_rewards_res" .. "id:"..id.."result"..result);
    if result == 0 then
        log("[yyc ] get_achievement_rewards_res success");
        if AchievementSystem.Data[id] then
            AchievementSystem.Data[id].FinishTime = timestamps;
            AchievementSystem.Data[id].State = BP_ENUM_ACHIEVEMENT_STATE_FINISH_GET_AWARD;
            
            if AchievementSystem.Data[id].MultiLvGroupID and AchievementSystem.Data[id].MultiLvGroupID ~= 0 then
                AchievementSystem.UpdateMultiLvGroupIDShowInfo(AchievementSystem.Data[id].MultiLvGroupID);
                AchievementDetailUI.UpdateAchievementDetailState(AchievementSystem.Data[id]);
            end
            
            AchievementTaskUI.UpdateAchievementShowList();
            
            -- 弹出奖励
            local awardData = {}
            table.insert(awardData, {res_id = AchievementSystem.Data[id].AwardID,
                count = AchievementSystem.Data[id].AwardNum,
                valid_hours = 0,
            })
            
            if AchievementSystem.Data[id].AwardID2 ~= 0 then
                table.insert(awardData, {res_id = AchievementSystem.Data[id].AwardID2,
                    count = AchievementSystem.Data[id].AwardNum2,
                    valid_hours = 0,
                })
            end
            
            AchievementAwardUI.Show(AchievementSystem.Data[id].Score);
            --CommonItemGetUI:ShowPanelWithCallback(awardData, cb, false);
            AchievementSystem.AsycCacheId = id;
            if nil ~= AchievementSystem.AsyncShowCommmonPannel then
                Timer.RemoveTimer(AchievementSystem.AsyncShowCommmonPannel);
                AchievementSystem.AsyncShowCommmonPannel = nil;
            end
            AchievementSystem.AsyncShowCommmonPannel = Timer.InsertTimer(0.1,AchievementSystem.AsyncShowPanel,false,false);
            local num = AchievementSystem.CanGetAwardNum(AchievementSystem.Data[id].GroupID);
            BP_ARRAY_AchievementRedPointList[AchievementSystem.Data[id].GroupID] = num > 0 and true or false;
            --RoleInfoUI.UpdateAchievementSubTabRedPoint();
            AchievementTaskUI.UpdateAchievementSubTabRedPoint();
        else
            log("[yyc ] get_achievement_rewards_res invalid id"..id);
        end
    else
        log("[yyc ] get_achievement_rewards_res error id:"..id.."result:"..result);
    end
end

function AchievementSystem.AsyncShowPanel()
            local lid = AchievementSystem.AsycCacheId;
            --log("lid::"..tostring(lid))
            local function cb()
                AchievementAwardUI.Hide();
                if AchievementSystem.Data[AchievementSystem.AsycCacheId].ShareFlag ~= 0 then
                    ShareAchievementShareUI.ShowUI(lid);
                end
            end
            -- 弹出奖励
            local awardData = {}
            table.insert(awardData, {res_id = AchievementSystem.Data[lid].AwardID,
                count = AchievementSystem.Data[lid].AwardNum,
                valid_hours = 0,
            })
            
            if AchievementSystem.Data[lid].AwardID2 ~= 0 then
                table.insert(awardData, {res_id = AchievementSystem.Data[lid].AwardID2,
                    count = AchievementSystem.Data[lid].AwardNum2,
                    valid_hours = 0,
                })
            end
            CommonItemGetUI:ShowPanelWithCallback(awardData, cb, false);
end

-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- 周边逻辑；设置、积分奖励、分享、通知等

--新成就点击
function AchievementSystem.achieve_hit_req(id)
    --log("[yyc]AchievementSystem.achieve_hit_req:"..id);
    NetUtil.SendPkg("get_achieve_hit_req", id);
end

--请求新成就点击列表
function AchievementSystem.get_achieve_hit_list_req()
    NetUtil.SendPkg("get_achieve_hit_list_req");
end

--新成就点击列表回包
function AchievementSystem.get_achieve_hit_list_res(res)
    --log_tree("[yyc] get_achieve_hit_list_res", res);
    for k, _ in pairs(res) do
        AchievementSystem.SetNewFlag(tonumber(k), false);
    end
end

--上报成就完成
function AchievementSystem.report_achievement_finish(id)
    NetUtil.SendPkg("report_achievement_finish", id);
end

--设置总览页成就
-- req = {[1] = 100,[2] = 101,} key:位置，value:成就id
function AchievementSystem.set_achievement_show_req(req)
    --log_tree("[yyc] AchievementSystem set_achievement_show_req", req);
    -- 回包走get_achievement_data_res的更新协议
    NetUtil.SendPkg("set_achievement_show_req", req);
end

-- 拉取积分奖励的领取情况
function AchievementSystem.get_achieve_record_rewards_list_req()
    NetUtil.SendPkg("get_achieve_record_rewards_list_req");
end

-- res = { id = timestamp }
function AchievementSystem.get_achieve_record_rewards_list_res(res)
    --log_tree("[yyc] get_achieve_record_rewards_list_res", res);
    AchievementSystem.ScoreAward = res;
    AchievementTaskUI.RefreshSummaryUI();
end

-- 领取一个成就积分奖励
function AchievementSystem.get_achieve_record_rewards_req(id)
    NetUtil.SendPkg("get_achieve_record_rewards_req", id)
end

-- res
function AchievementSystem.get_achieve_record_rewards_res(id, errCode, timestamp)
    if errCode ~= 0 then
        if errCode == 1 then
            ShowNotice(108104)
        else
            ShowNotice(108106)
        end
        return
    end
    
    --log("get_achieve_record_rewards_res "..id..", "..timestamp)
    local data = Client.GetTableData("AchievementScoreCfg", id);
    if data == nil then return end
    -- 弹出掉落结果
    local awards = string.split(data.Awards, ";")
    local arrayItemData = {}
    for i, v in ipairs(awards) do
        local arr = string.split(v, "-")
        table.insert(arrayItemData, {res_id = arr[1], count = arr[2], valid_hours = 0})
    end
    CommonItemGetUI:ShowPanel(arrayItemData)
    
    AchievementSystem.ScoreAward[id] = timestamp
    
    RoleInfoUI.RefreshSummaryRedPoint()
    
    AchievementTaskUI.RefreshSummaryRedPoint()
    
    AchievementScoreAwardUI.GotAward()
end

--获取成就概要信息
function AchievementSystem.get_achievement_summary_req(uid)
    --log("[yyc] AchievementSystem get_achievement_summary_req " .. tostring(uid));
    NetUtil.SendPkg("get_achievement_summary_req", uid);
end

function AchievementSystem.get_achievement_summary_res(type, res)
    --log_tree("[yyc] AchievementSystem get_achievement_summary_res "..type, res);
    
    local update = false;
    if type == 1 then
        -- 全量
        AchievementSystem.Summary = res;
        
        if res.uid == tonumber(DataMgr.roleData.uid) then
            update = true;
        end
    else
        -- 局部更新（只有玩家自己才有）
        if res.achieve_score ~= nil then
            if res.achieve_score > AchievementSystem.Summary.achieve_score then
                update = true;
            end
            AchievementSystem.Summary.achieve_score = res.achieve_score;
        end
        
        local install = false;
        if res.show ~= nil then
            for k, v in pairs(res.show) do
                if v > 0 and AchievementSystem.Summary.show[k] ~= v then
                    install = true; -- 安装了新成就
                end
                AchievementSystem.Summary.show[k] = v;
            end
        end
        
        if res.hand == 1 and install == true then
            ShowNotice(4797); -- 设置成就外显回包成功
        end
        
        if res.time ~= nil then
            for k, v in pairs(res.time) do
                AchievementSystem.Summary.time[k] = v;
            end
        end
        
        if res.progress ~= nil then
            for k, v in pairs(res.progress) do
                AchievementSystem.Summary.progress[k][1] = v; -- 只刷新分子
            end
            log_tree("[yyc] AchievementSystem progress ", AchievementSystem.Summary.progress);
        end
    end
    
    RoleInfoSystem.AchievementSummaryGet = res.uid or 0
    
    RoleInfoUI.RefreshSummaryUI();
    --只有自己的消息刷新.type是2代表增量更新，一定是玩家自己
    if res.uid == tonumber(DataMgr.roleData.uid) or type == 2 then
        AchievementTaskUI.RefreshSummaryUI();
    end
    
    if update == true then
        LobbyUI:UpdateHeadportraitReddot();
    end
end

-- 检查是否有积分奖励可领
function AchievementSystem.CheckScoreAward()
    local myscore = AchievementSystem.Summary.achieve_score
    local data = Client.GetTable("AchievementScoreCfg");
    -- log_tree("AchievementSystem.CheckScoreAward", data)
    for k, v in pairs(data) do
        -- log_tree("CheckScoreAward "..v.ID..", "..v.Score, v)
        if myscore >= v.Score and (AchievementSystem.ScoreAward[v.ID] == nil or AchievementSystem.ScoreAward[v.ID] == 0) then
            return true
        end
    end
    return false
end

-- 新的成就达成，入列准备弹出
function AchievementSystem.PushNewAchievement(id)
    -- 判断战斗内则先缓存起来，回到大厅再弹
    local curStatus = string.lower(LuaClassObj.GetGameStatus(bp_lobby))
    if curStatus == "lobby" then
        if not AchievementFloatTipUI.IsOpen then
            AchievementFloatTipUI.Open(id) -- 大厅内第一个达成的，直接弹出
            return
        end
    end
    
    -- 优先队列：分数小的排前面
    local function scoreSort(a, b)
        if AchievementSystem.Data[a].Score < AchievementSystem.Data[b].Score then
            return true
        elseif AchievementSystem.Data[a].Score == AchievementSystem.Data[b].Score then
            return a < b
        else
            return false
        end
    end
    
    local len = #AchievementSystem.AchievementIDList
    if len >= 5 then
        -- 挤掉头部最少分数的
        local score = AchievementSystem.Data[id].Score
        local firstID = AchievementSystem.AchievementIDList[1]
        if score >= AchievementSystem.Data[firstID].Score then
            --log("[ft]remove "..firstID)
            table.remove(AchievementSystem.AchievementIDList, 1)
            --log("[ft]push "..id)
            table.insert(AchievementSystem.AchievementIDList, id)
            table.sort(AchievementSystem.AchievementIDList, scoreSort)
        end
    else
        --log("[ft]push "..id)
        table.insert(AchievementSystem.AchievementIDList, id)
        table.sort(AchievementSystem.AchievementIDList, scoreSort)
    end
    
end

-- 清空未弹出的成就达成浮框列表
function AchievementSystem.ClearNewAchievementList()
    local t = AchievementSystem.AchievementIDList
    if #t > 0 then
        for k in pairs (t) do
            t[k] = nil
        end
    end
end

-- 从一个槽位上删除成就显示
function AchievementSystem.DeleteAchievement(slot)
    local req = {}
    for k, v in pairs(AchievementSystem.Summary.show) do
        if k == slot then
            req[k] = 0
        else
            req[k] = v
        end
    end
    AchievementSystem.set_achievement_show_req(req)
end

-- 整个成就系统是否有红点提示
function AchievementSystem.HasRedpoint()
    local scoreAward = AchievementSystem.CheckScoreAward()
    --log("AchievementSystem.HasRedpoint score award="..tostring(scoreAward))
    if scoreAward then return true end
    
    for _, v in pairs(BP_ARRAY_AchievementRedPointList) do
        if v then return true end
    end
    
    log("AchievementSystem.HasRedpoint return default false")
    return false
end

-- 遍历得到已经达成的成就列表，并插入弹框队列中
function AchievementSystem.GetFinishedList()
    for k, v in pairs(AchievementSystem.Data) do
        if v.State == BP_ENUM_ACHIEVEMENT_STATE_FINISH_NO_AWARD then
            log("AchievementSystem.GetFinishedList="..v.ID)
            AchievementSystem.PushNewAchievement(v.ID)
        end
    end
end

--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

s2c["get_achieve_rewards_list_res"] = AchievementSystem.get_achieve_rewards_list_res;
s2c["get_achievement_data_res"] = AchievementSystem.get_achievement_data_res;
s2c["get_achievement_summary_res"] = AchievementSystem.get_achievement_summary_res;
s2c["get_achievement_rewards_res"] = AchievementSystem.get_achievement_rewards_res;
s2c["get_achieve_record_rewards_list_res"] = AchievementSystem.get_achieve_record_rewards_list_res;
s2c["get_achieve_record_rewards_res"] = AchievementSystem.get_achieve_record_rewards_res;
s2c["get_achieve_hit_list_res"] = AchievementSystem.get_achieve_hit_list_res;
