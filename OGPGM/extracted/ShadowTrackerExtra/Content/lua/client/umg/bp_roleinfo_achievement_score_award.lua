-- 成就积分领取奖励
AchievementScoreAwardUI = AchievementScoreAwardUI or
{
    bShow = false,
};

BP_STRUCT_AchievementScoreAwardItem =
{
    id = 0,
    score = 0,
    award0 = 0,
    awardcount0 = 0,
    award1 = 0,
    awardcount1 = 0,
    award2 = 0,
    awardcount2 = 0,
    award3 = 0,
    awardcount3 = 0,
    award4 = 0,
    awardcount4 = 0,
    canget = 0, -- 是否可领
    timestamp = 0 -- 已经领的时间戳
};

BP_ARRAY_AchievementScoreAwardList =
{
    BP_STRUCT_AchievementScoreAwardItem = _G.BP_STRUCT_AchievementScoreAwardItem,
};

BP_AchievementScoreAward_Select_ID = 0; -- 当前选中待领取的奖励
BP_AchievementScoreAward_Sum = 0; -- 当前总积分

--注册Widget
function bp_roleinfo_achievement_score_award_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_roleinfo_achievement_score_award,
		{{Path="/Game/UMG/UI_Logic/RoleInfo/Achievement/AchievementScoreAward_BP.AchievementScoreAward_BP_C", Container="Default", ZOrder=BP_ENUM_UI_TASK_ZORDER+2}},
		{"Lobby"},
		false,
		false,
		true
	);
end

function AchievementScoreAwardUI.Open()
    LuaClassObj.HandleDynamicCreation(bp_roleinfo_achievement_score_award);

    BP_AchievementScoreAward_Select_ID = 0;
    AchievementScoreAwardUI.InitData();
    AchievementScoreAwardUI.SortData();

    LuaClassObj.HandleUIMessage(bp_roleinfo_achievement_score_award, "ShowUI");
    UIManager.Show(eUIType.eAchievementScoreAwardUI)
end

function AchievementScoreAwardUI.Release()
    BP_ARRAY_AchievementScoreAwardList = nil;
end

function AchievementScoreAwardUI.InitData()
    local myscore = AchievementSystem.Summary.achieve_score;
    BP_AchievementScoreAward_Sum = myscore;

    -- read table data
    BP_ARRAY_AchievementScoreAwardList = {};
    local data = Client.GetTable("AchievementScoreCfg");
	for k,v in pairs(data) do
        local dat = {
            id = v.ID,
            score = v.Score,
            canget = 0,
            timestamp = 0
        };

        if v.Awards ~= "" then
            local awards = string.split(v.Awards, ";");
            local len = #awards;
            local arr = { 0, 0 };
            if len > 0 then
                arr = string.split(awards[1], "-");
                dat.award0 = tonumber(arr[1]);
                dat.awardcount0 = tonumber(arr[2]);
            end
            if len > 1 then
                arr = string.split(awards[2], "-");
                dat.award1 = tonumber(arr[1]);
                dat.awardcount1 = tonumber(arr[2]);
            end
            if len > 2 then
                arr = string.split(awards[3], "-");
                dat.award2 = tonumber(arr[1]);
                dat.awardcount2 = tonumber(arr[2]);
            end
            if len > 3 then
                arr = string.split(awards[4], "-");
                dat.award3 = tonumber(arr[1]);
                dat.awardcount3 = tonumber(arr[2]);
            end
            if len > 4 then
                arr = string.split(awards[5], "-");
                dat.award4 = tonumber(arr[1]);
                dat.awardcount4 = tonumber(arr[2]);
            end
        end

        if myscore >= dat.score then
            dat.canget = 1;
        end
        
        if AchievementSystem.ScoreAward[dat.id] ~= nil then -- 已经领取过了
            dat.timestamp = AchievementSystem.ScoreAward[dat.id];
        end

        table.insert(BP_ARRAY_AchievementScoreAwardList, dat);
    end
end

function AchievementScoreAwardUI.SortData()
    local function funcSort(a,b)
        local sa = 0
        local sb = 0
        if a.canget == 1 and a.timestamp == 0 then
            sa = -a.id + 10000 -- 可领取的优先
        elseif a.canget == 0 and a.timestamp == 0 then
            sa = -a.id + 1000 -- 未达成的中间
        else
            sa = -a.id
        end

        if b.canget == 1 and b.timestamp == 0 then
            sb = -b.id + 10000 -- 可领取的优先
        elseif b.canget == 0 and b.timestamp == 0 then
            sb = -b.id + 1000 -- 未达成的中间
        else
            sb = -b.id
        end

        return sa > sb;
    end

    table.sort(BP_ARRAY_AchievementScoreAwardList, funcSort);
end

-- 领取了一个奖励
function AchievementScoreAwardUI.GotAward()
    if BP_AchievementScoreAward_Select_ID == 0 then return end

    local found = false;
    for i,v in ipairs(BP_ARRAY_AchievementScoreAwardList) do
        if v.id == BP_AchievementScoreAward_Select_ID then
            v.timestamp = FuncUtil.GetServerTimeInSec();
            found = true;
            break;
        end
    end

    if not found then return end

    -- 重新排序，刷新界面
    AchievementScoreAwardUI.SortData();
    LuaClassObj.HandleUIMessage(bp_roleinfo_achievement_score_award, "RefreshUI");
end

---------------------------------------------------------------------------------------------------
-- BP 接口

function EventAchievementScoreAwardUIClose()
    UIManager.Hide(eUIType.eAchievementScoreAwardUI)
    AchievementScoreAwardUI.Release()
end

-- 领取奖励
function EventAchievementScoreAwardAccept()
    if BP_AchievementScoreAward_Select_ID == 0 then return end

    AchievementSystem.get_achieve_record_rewards_req(BP_AchievementScoreAward_Select_ID);
end

---------------------------------------------------------------------------------------------------