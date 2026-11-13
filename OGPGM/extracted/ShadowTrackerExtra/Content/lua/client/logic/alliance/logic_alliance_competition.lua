--[[
    战队赛相关逻辑
]]

AllianceCompetitionSystem = AllianceCompetitionSystem or {}

-- 是否有历史排名
AllianceCompetitionSystem.HasCompetitionRank = false
-- 历史排名
AllianceCompetitionSystem.MaxCompetitionRank = 0
-- 历史排名赛季ID
AllianceCompetitionSystem.MaxCompetitionId = 0
-- 历史排名赛季阶段ID
AllianceCompetitionSystem.MaxCompetitionStageId = 0
-- 历史排名小组赛分组
AllianceCompetitionSystem.MaxCompetitionGroupId = 0
-- 历史赛季排名获取时间
AllianceCompetitionSystem.MaxCompetitionObtainTime = 0

-- 队旗id
AllianceCompetitionSystem.GuidonId = nil
-- 国旗id
AllianceCompetitionSystem.NationFlagId = nil

-- 当前赛季阶段
AllianceCompetitionSystem.CurrentStageId = 0
-- 是否已经报名
AllianceCompetitionSystem.SignedUp = false
-- 下个阶段剩余时间
AllianceCompetitionSystem.NextStageTime = 0
-- 当前赛季积分
AllianceCompetitionSystem.CurrentCompetitionScore = 0
-- 是否已经晋级
AllianceCompetitionSystem.HasPromoted = false
-- 对阵信息
AllianceCompetitionSystem.VersusInfo = {}

-- 阶段一共分为四种
-- 第一种阶段 报名 海选 小组 决赛
AllianceCompetitionSystem.FirstStepID = 0
-- 第二种阶段 比赛期 评估期 等待下个赛季期(只有海选 小组 决赛 有)
AllianceCompetitionSystem.SecondStepID = 0
-- 第三种阶段 第N轮比赛(只有比赛期 有)
AllianceCompetitionSystem.ThirdStepID = 0
-- 第四种阶段 准备中 进行中(只有第N轮比赛有)
AllianceCompetitionSystem.FourthStepID = 0

AllianceCompetitionSystem.FirstStep =
{
    REBORT = 1,                     -- 预报
    SIGNUP = 2,                     -- 报名  
    FIRST_MATCH = 3,                -- 海选赛
    GROUP_MATCH = 4,                -- 小组赛
    ZONE_FINAL_MATCH = 5,           -- 战区决赛
}

AllianceCompetitionSystem.SecondStep =
{
    MATCHING = 1,                   -- 比赛期
    ASSESSING = 2,                  -- 评估期  
    WAITING_NEXT = 3,               -- 等待下个赛季期
}

AllianceCompetitionSystem.FourthStep =
{
    READY = 1,                       -- 准备期
    ON_GOING = 2,                    -- 进行期 
}

-- 小组字符串
AllianceCompetitionSystem.GruopStr = {
    "A","B","C","D","E"
}

-- 服务端比赛进程数据数据
AllianceCompetitionSystem._ServerData = {}

-- 模式
AllianceCompetitionSystem.Mode = -1
-- 模式
AllianceCompetitionSystem.SubMode = -1
-- 地区
AllianceCompetitionSystem.Zone = -1

AllianceCompetitionSystem.records = {}

function AllianceCompetitionSystem.log(content)
    -- log("===== [AllianceCompetitionSystem] ====== :"..content)
end

function AllianceCompetitionSystem.log_tree(content, value)
    -- log_tree("===== [AllianceCompetitionSystem] ====== :"..content, value)
end

-- ├─ league_history
-- │  └─ best_rank
-- │     └─ 1  --赛事id
-- │        ├─ rank_no: 6  --排名
-- │        ├─ zone_id: 1  
-- │        ├─ stage: 4   --阶段
-- │        └─ battle_mode: 11103

-- function function_name( ... )
--     -- body
-- end

-- 战队赛新增数据处理
function AllianceCompetitionSystem.FormatAllianceData(carteam)
    AllianceCompetitionSystem.log_tree("FormatAllianceData carteam",carteam)

    -- 是否有历史数据
    AllianceCompetitionSystem.HasCompetitionRank = true
    -- carteam.league_history = {}
    -- carteam.league_history.best_rank = {}

    -- local a = {}
    -- a.stage = 4
    -- a.rank_no = 1
    -- a.group_id = 1
    -- a.obtain_time = os.time()

    -- carteam.league_history.best_rank[1] = a
    -- carteam.league_history.best_rank[5] = a


    local historyInfo = carteam.league_history
    if historyInfo == nil or historyInfo.best_rank  == nil then
        AllianceCompetitionSystem.HasCompetitionRank = false
    else
        local rankList = {}

        for k,v in pairs(historyInfo.best_rank) do
            v.seasonId = k
            table.insert(rankList, v)
        end

        table.sort(rankList, function(a, b)
            return a.seasonId < b.seasonId
        end)

        if #rankList == 0 then
            AllianceCompetitionSystem.HasCompetitionRank = false
            
        else
            local bestInfo = nil
            local seasonId = nil

            for _,data in ipairs(rankList) do
                if bestInfo == nil then
                    bestInfo = data
                    seasonId = data.seasonId

                else
                    if data.stage > bestInfo.stage then
                        bestInfo = data
                        seasonId = data.seasonId 

                    elseif data.stage == bestInfo.stage then
                        if data.rank_no >= bestInfo.rank_no then
                            bestInfo = data
                            seasonId = data.seasonId 
                        end
                    end
                end
            end

            -- local seasonId = #historyInfo.best_rank
            local info = historyInfo.best_rank[seasonId]

            -- log_tree("historyInfo.best_rank[seasonId]", info, "asd")
            AllianceCompetitionSystem.MaxCompetitionRank = info.rank_no
            AllianceCompetitionSystem.MaxCompetitionId = seasonId
            AllianceCompetitionSystem.MaxCompetitionStageId = info.stage
            AllianceCompetitionSystem.MaxCompetitionGroupId = info.group_id
            AllianceCompetitionSystem.MaxCompetitionObtainTime = info.obtain_time
        end
        
    end

    log("AllianceCompetitionSystem.HasCompetitionRank "..tostring(AllianceCompetitionSystem.HasCompetitionRank))

    if carteam.league_info then
        AllianceCompetitionSystem.league_info = carteam.league_info;
    end
    -- 队旗数据
    AllianceCompetitionSystem.GuidonId = carteam.team_flag
    -- 国旗数据
    AllianceCompetitionSystem.NationFlagId = carteam.nation_flag
end

function AllianceCompetitionSystem.SetDataFromServer(serverData)
    AllianceCompetitionSystem.log_tree("SetDataFromServer", serverData)
    AllianceCompetitionSystem._ServerData = serverData

    AllianceCompetitionRoomUI.CheckToQuick()
end

function AllianceCompetitionSystem.getGuidonUrl()
    if AllianceCompetitionSystem.GuidonId == nil then
        BP_NATION_OPEN_TYPE = CountryareaUI.OPEN_TYPE_GUIDON
        local allNationCode = {};
        for k,v in pairs(Client.GetTable("GuidonConfig")) do
            table.insert(allNationCode, k)
        end

        local data = CountryareaUI.SortNationCode(allNationCode)
        AllianceCompetitionSystem.GuidonId = data[1]
    end

    log("AllianceCompetitionSystem.getGuidonUrl "..AllianceCompetitionSystem.GuidonId)
    if Client.GetTable("GuidonConfig")[AllianceCompetitionSystem.GuidonId] == nil then return "" end
    return Client.GetTable("GuidonConfig")[AllianceCompetitionSystem.GuidonId].res_path
end

function AllianceCompetitionSystem.getNationFlagUrl()
    local tabRegion = FuncUtil.GetRegionConfigTable();
    if AllianceCompetitionSystem.NationFlagId == nil then
        BP_NATION_OPEN_TYPE = CountryareaUI.OPEN_TYPE_TEAM_NATION
        local allNationCode = {};
        for k,v in pairs(tabRegion) do
            table.insert(allNationCode, k)
        end

        local data = CountryareaUI.SortNationCode(allNationCode) 
        AllianceCompetitionSystem.NationFlagId = data[1]
    end

    log("AllianceCompetitionSystem.getNationFlagUrl "..AllianceCompetitionSystem.NationFlagId)
    if tabRegion[AllianceCompetitionSystem.NationFlagId] == nil then return "" end

    return tabRegion[AllianceCompetitionSystem.NationFlagId].res_path
end

-- 通过当前时间，换算当前比赛进程数据
function AllianceCompetitionSystem.FormatCompetitionData()
    local curtime = FuncUtil.GetServerTimeInSec()
    -- curtime = 1542866401
    -- AllianceCompetitionSystem.Mode = 11103
    -- AllianceCompetitionSystem.Zone = 1

    AllianceCompetitionSystem.log("formatCompetitionData curtime "..curtime)

    local serverData = AllianceCompetitionSystem._ServerData
    if serverData.league_process_table == nil then return end

    -- 处理第一阶段
    AllianceCompetitionSystem.FirstStepID = -1
    for stepId,data in ipairs(serverData.league_process_table) do
        if curtime < data.begin_time then
            AllianceCompetitionSystem.FirstStepID = stepId - 1
            break
        end
    end

    -- 处理决赛期越界问题
    if AllianceCompetitionSystem.FirstStepID <= AllianceCompetitionSystem.FirstStep.SIGNUP
    or AllianceCompetitionSystem.FirstStepID > AllianceCompetitionSystem.FirstStep.ZONE_FINAL_MATCH
    then
        AllianceCompetitionSystem.FirstStepID = AllianceCompetitionSystem.FirstStep.ZONE_FINAL_MATCH
    end

    -- 处理第二阶段
    AllianceCompetitionSystem.SecondStepID = -1
    local stepInfo = AllianceCompetitionSystem._getStepInfo(AllianceCompetitionSystem.FirstStepID)

    if AllianceCompetitionSystem.HasSecondStep(AllianceCompetitionSystem.FirstStepID) == true then

        if AllianceCompetitionSystem._betweenDate(curtime, stepInfo.begin_time, stepInfo.promote_time) then
            AllianceCompetitionSystem.SecondStepID = AllianceCompetitionSystem.SecondStep.MATCHING

        elseif AllianceCompetitionSystem._betweenDate(curtime, stepInfo.promote_time, stepInfo.end_time) then
            AllianceCompetitionSystem.SecondStepID = AllianceCompetitionSystem.SecondStep.ASSESSING

        else
            AllianceCompetitionSystem.SecondStepID = AllianceCompetitionSystem.SecondStep.WAITING_NEXT
        end

    end

    -- 处理第三、四阶段
    log("AllianceCompetitionSystem.Mode "..AllianceCompetitionSystem.Mode)
    log("AllianceCompetitionSystem.Zone "..AllianceCompetitionSystem.Zone)
                
    local mode = AllianceCompetitionSystem.Mode --比赛模式 和服务端拿
    local zone = AllianceCompetitionSystem.Zone --比赛地区 和服务端拿
    AllianceCompetitionSystem.ThirdStepID = -1
    AllianceCompetitionSystem.FourthStepID = -1

    log("mode   "..mode.." zone "..zone)
    if AllianceCompetitionSystem.SecondStepID == AllianceCompetitionSystem.SecondStep.MATCHING 
    and mode ~= -1
    and zone ~= -1
    then
        AllianceCompetitionSystem.SubMode = serverData.league_game_table[AllianceCompetitionSystem.FirstStepID][mode][zone].sub_mode
        local competitionInfos = serverData.league_game_table[AllianceCompetitionSystem.FirstStepID][mode][zone].vaild_match_time_slot
        for id,times in ipairs(competitionInfos) do

            local readyStartTime = times[1]
            local ongoingStartTime = times[2]
            local ongoingEndTime = ongoingStartTime + 2400 --和策划确认过，默认+40分钟为结束进行时时间

            if AllianceCompetitionSystem._betweenDate(curtime, readyStartTime, ongoingStartTime) then
                AllianceCompetitionSystem.ThirdStepID = id
                AllianceCompetitionSystem.FourthStepID = AllianceCompetitionSystem.FourthStep.READY
                break

            elseif AllianceCompetitionSystem._betweenDate(curtime, readyStartTime, ongoingEndTime) then
                AllianceCompetitionSystem.ThirdStepID = id
                AllianceCompetitionSystem.FourthStepID = AllianceCompetitionSystem.FourthStep.ON_GOING
                break

            end
        end
    end

    AllianceCompetitionSystem.log("FormatCompetitionData end")
    AllianceCompetitionSystem.log("FirstStepID "..AllianceCompetitionSystem.FirstStepID)
    AllianceCompetitionSystem.log("SecondStepID "..AllianceCompetitionSystem.SecondStepID)
    AllianceCompetitionSystem.log("ThirdStepID "..AllianceCompetitionSystem.ThirdStepID)
    AllianceCompetitionSystem.log("FourthStepID "..AllianceCompetitionSystem.FourthStepID)
end

function AllianceCompetitionSystem.initCompetitionData()

end

-- 是否拥有第二阶段
function AllianceCompetitionSystem.HasSecondStep(stepId)
    if stepId == AllianceCompetitionSystem.FirstStep.FIRST_MATCH
    or stepId == AllianceCompetitionSystem.FirstStep.GROUP_MATCH
    or stepId == AllianceCompetitionSystem.FirstStep.ZONE_FINAL_MATCH
    then
        return true
    end

    return false
end

-- 下个赛季倒计时
function AllianceCompetitionSystem.countdownNextStage()
    local nextStageTime = AllianceCompetitionSystem.NextStageTime
    if nextStageTime <= 0 then
        nextStageTime = 0
    else
        nextStageTime = nextStageTime - 1
    end

    AllianceCompetitionSystem.NextStageTime = nextStageTime

    return nextStageTime
end

-- 是否有历史最高战绩
function AllianceCompetitionSystem.hasMaxCompetitionRank()
    if AllianceCompetitionSystem.MaxCompetitionId == nil
    or AllianceCompetitionSystem.MaxCompetitionRank == nil
    then
        return false
    end

    return true
end

-- -- 是否允许报名
-- function AllianceCompetitionSystem.HasSignedUp()
--     -- body todo
--     return true
-- end

-- 获取下一个阶段数据
function AllianceCompetitionSystem.getNextStageInfo()
    -- body todo
end

-- 是否在某个阶段
-- function AllianceCompetitionSystem.isInStageType(StageType)
--     -- body
--     return true
-- end

function AllianceCompetitionSystem._betweenDate(curtime, startTime, endTime)
    if curtime >= startTime and curtime < endTime then
        return true
    end

    return false
end

function AllianceCompetitionSystem._getStepInfo(stepId)
    return AllianceCompetitionSystem._ServerData.league_process_table[stepId]
end

function AllianceCompetitionSystem.getRecord(index)
    return AllianceCompetitionSystem.records[index]
end

-- ====================================================中文处理====================================================
function AllianceCompetitionSystem.getStageName(stageID)
    local data = {}
    data[AllianceCompetitionSystem.FirstStep.FIRST_MATCH] = Client.GetTableData("LocalizeRes",6049).TextValue
    data[AllianceCompetitionSystem.FirstStep.GROUP_MATCH] = Client.GetTableData("LocalizeRes",6050).TextValue
    data[AllianceCompetitionSystem.FirstStep.ZONE_FINAL_MATCH] = Client.GetTableData("LocalizeRes",6051).TextValue

    return data[stageID]
end

function AllianceCompetitionSystem.getTeamName(teamID)
    return FuncUtil.LocalizeResFormat(6181, teamID);
end

function AllianceCompetitionSystem.getRoundName(value)
    return FuncUtil.LocalizeResFormat(6182, value);
end

function AllianceCompetitionSystem.getAreaName(area)
    local zoneCfg = Client.GetTableData("ZoneConfig", area)
    if zoneCfg == nil then
        return "地区"..area
    end

    return zoneCfg.NameInChinese
end

function AllianceCompetitionSystem.getMyAreaName()
    return AllianceCompetitionSystem.getAreaName(AllianceCompetitionSystem.Zone)
end

function AllianceCompetitionSystem.getModeName(mode)
    if mode == LeagueGameSystem.LEAGUE_TPP_MODE then
         return Client.GetTableData("LocalizeRes",100054).TextValue;      -- 第3人称
    end

    if mode == LeagueGameSystem.LEAGUE_FPP_MODE then
         return Client.GetTableData("LocalizeRes",100053).TextValue;      -- 第1人称
    end    

    return "模式"..mode
end

function AllianceCompetitionSystem.getMyModeName()
    return AllianceCompetitionSystem.getModeName(AllianceCompetitionSystem.Mode)
end

function AllianceCompetitionSystem.getRoomTip()
    return FuncUtil.LocalizeResFormat(6183, AllianceCompetitionSystem.ThirdStepID);
end

-- AllianceCompetitionSystem.FirstStep =
-- {
--     REBORT = 1,                     -- 预报
--     SIGNUP = 2,                     -- 报名  
--     FIRST_MATCH = 3,                -- 海选赛
--     GROUP_MATCH = 4,                -- 小组赛
--     ZONE_FINAL_MATCH = 5,           -- 战区决赛
-- }
function AllianceCompetitionSystem.getTeamMainRankContentText()
    -- if true then
    --     AllianceCompetitionSystem.MaxCompetitionRank = 3
    --     -- 历史排名赛季ID
    --     AllianceCompetitionSystem.MaxCompetitionId = 1
    --     -- 历史排名赛季阶段ID
    --     AllianceCompetitionSystem.MaxCompetitionStageId = AllianceCompetitionSystem.FirstStep.GROUP_MATCH
    --     -- 历史排名小组赛分组
    --     AllianceCompetitionSystem.MaxCompetitionGroupId = 1
    -- end

    local text = ""
    if AllianceCompetitionSystem.MaxCompetitionStageId == AllianceCompetitionSystem.FirstStep.GROUP_MATCH then
        text = Client.GetTableData("LocalizeRes",6346).TextValue

        text = string.gsub(text, "{0}", AllianceCompetitionSystem.GruopStr[AllianceCompetitionSystem.MaxCompetitionGroupId])
        text = string.gsub(text, "{1}", AllianceCompetitionSystem.MaxCompetitionRank)
    end

    if AllianceCompetitionSystem.MaxCompetitionStageId == AllianceCompetitionSystem.FirstStep.ZONE_FINAL_MATCH then
        text = Client.GetTableData("LocalizeRes",6347).TextValue

        text = string.gsub(text, "{0}", AllianceCompetitionSystem.MaxCompetitionRank)
    end

    return text or "找不到6289"
end

function AllianceCompetitionSystem.getShareRankContentText()
    -- if true then
    --     AllianceCompetitionSystem.MaxCompetitionRank = 1
    --     -- 历史排名赛季ID
    --     AllianceCompetitionSystem.MaxCompetitionId = 1
    --     -- 历史排名赛季阶段ID
    --     AllianceCompetitionSystem.MaxCompetitionStageId = AllianceCompetitionSystem.FirstStep.ZONE_FINAL_MATCH
    --     -- 历史排名小组赛分组
    --     AllianceCompetitionSystem.MaxCompetitionGroupId = 1
    -- end

    local text = ""
    if AllianceCompetitionSystem.MaxCompetitionStageId == AllianceCompetitionSystem.FirstStep.GROUP_MATCH then
        text = Client.GetTableData("LocalizeRes",6348).TextValue
        text = string.gsub(text, "{0}", AllianceCompetitionSystem.GruopStr[AllianceCompetitionSystem.MaxCompetitionGroupId])
    end

    if AllianceCompetitionSystem.MaxCompetitionStageId == AllianceCompetitionSystem.FirstStep.ZONE_FINAL_MATCH then
        text = Client.GetTableData("LocalizeRes",6349).TextValue
    end

    return text or "找不到6289"
end

function AllianceCompetitionSystem.UpdateTabStr()

    BP_STRUCT_Alliance_TapIndex_Str = 
    {
        Main = Client.GetTableData("LocalizeRes",6185).TextValue,                  --主界面
        Member = Client.GetTableData("LocalizeRes",6245).TextValue,                     --队员
        Score = Client.GetTableData("LocalizeRes",6246).TextValue,                  --战绩
        Shop = Client.GetTableData("LocalizeRes",6187).TextValue,                  --商店
    }

end