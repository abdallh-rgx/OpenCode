
AchievementTaskUI = AchievementTaskUI or {
    isShow = false,
}

--成就种类红点数据
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

BP_STRUCT_AchievementInfo =
{
    id = 0,
    img_url = "",
    big_img_url = "",
    des = "",
    title = "",
    state = 1,
    finish_time = "",
    award_id = 0,
    award_num = 0,
    award2_id = 0,
    award2_num = 0,
    group_id = 1,
    group_title = "",
    group_num = 1,
    total_process = 1,
    cur_process = 0,
    cnd_num = 1,
    score = 0,
    param_des = "",
    show = true,
    update_time = 0,
    share_flag = false,
    version = 0,
};

--成就当前显示数据
BP_ARRAY_AchievementShowList =
{
    BP_STRUCT_AchievementInfo = _G.BP_STRUCT_AchievementInfo,
};

BP_ACHIEVEMENT_CurIndex = 1
BP_ACHIEVEMENT_FirstIn = true
BP_ACHIEVEMENT_CLICK_ID = 0
BP_ACHIEVEMENT_UPDATE_INDEX = 1 --需要更新信息的成就在列表里的index
BP_ACHIEVEMENT_GETAWARD_ID = 0 --点击的获取奖励成就id
BP_ACHIEVEMENT_DONE_CHECK = false --完成是否选中
BP_ACHIEVEMENT_SHARE_ID = 0
BP_ACHIEVEMENT_OTHER_TIMETAMP = "" --其他人的完成时间
BP_ACHIEVEMENT_CATEGORY_TOTAL_NUM = 0 --当前种类总数量
BP_ACHIEVEMENT_CATEGORY_FINISH_NUM = 0 --当前种类完成数量

-- 注册Widget
function bp_achievement_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_achievement,
        {
            {Path = "/Game/UMG/UI_Logic/Task/Achievement_BP.Achievement_BP_C", Container = "Default", ZOrder = BP_ENUM_UI_TASK_ZORDER + 1},
        },
        {"Lobby"},
        false,
        false,
        true
    );
    --log("[yyc] bp_achievement_RegisterUI");
end

function AchievementTaskUI.Show()
    log("[yyc] AchievementTaskUI.Show");
    AchievementTaskUI.isShow = true;
    LuaClassObj.HandleDynamicCreation(bp_achievement);
    LuaClassObj.HandleUIMessage(bp_achievement, "UIShow");
    UIManager.Show(eUIType.eAchievementUI)
    AchievementTaskUI.ResetShow()
    EventSystem:registEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN, AchievementTaskUI.ResetHide);
    EventSystem:registEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE, AchievementTaskUI.ResetShow);
end

function AchievementTaskUI.Hide()
    if not AchievementTaskUI.isShow then
        return
    end
    log("[yyc] AchievementTaskUI.Hide");
    AchievementTaskUI.isShow = false;
    BP_TASK_ACHIEVEMENT_FirstIn = true;
    UIManager.Hide(eUIType.eAchievementUI)
    LuaClassObj.HandleUIMessage(bp_achievement, "UIHide");
    EventSystem:unregistEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN, AchievementTaskUI.ResetHide);
    EventSystem:unregistEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE, AchievementTaskUI.ResetShow);
end

function AchievementTaskUI.ResetShow()
    local bp = UIUtil.GetWidgetByName("bp_achievement", "Achievement_BP")
    if bp then
        bp:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible);
    end
    --LuaClassObj.HandleUIMessage(bp_achievement, "ShowSelf");
end

function AchievementTaskUI.ResetHide()
    local bp = UIUtil.GetWidgetByName("bp_achievement", "Achievement_BP")
    if bp then
        bp:SetVisibility(UEnums.ESlateVisibility.Collapsed);
    end
    --LuaClassObj.HandleUIMessage(bp_achievement, "HideSelf");
end

function AchievementTaskUI.UpdateNotDoneCheckState()
    LuaClassObj.HandleUIMessage(bp_achievement, "UpdateNotDoneCheckState");
end

function AchievementTaskUI.UpdateAchievementSubTabRedPoint()
    --log_tree("[yyc] AchievementTaskUI UpdateAchievementSubTabRedPoint", BP_ARRAY_AchievementRedPointList);
    LuaClassObj.HandleUIMessage(bp_achievement, "UpdateAchievementSubTabRedPoint");
    LuaClassObj.HandleUIMessage(bp_task, "UpdateAchievementTabRedDot")
    TaskUI.RefreshLobbyTaskRedDot()
end

function AchievementTaskUI.UpdateAchievementShowList()
    log("[yyc] AchievementTaskUI.UpdateAchievementShowList curIndex = "..BP_ACHIEVEMENT_CurIndex);
    BP_ARRAY_AchievementShowList = {};
    BP_ACHIEVEMENT_CATEGORY_TOTAL_NUM = 0;
    BP_ACHIEVEMENT_CATEGORY_FINISH_NUM = 0;
    for k, v in pairs(AchievementSystem.Data) do
        local temp = AchievementDetailUI.MakeSingleDetailData(v.ID);
        local isValidID = AchievementSystem.IsValidAchievementID(v.ID);
        if v.GroupID == BP_ACHIEVEMENT_CurIndex and v.Show and isValidID then
            if BP_ACHIEVEMENT_DONE_CHECK then
                if v.State == BP_ENUM_ACHIEVEMENT_STATE_FINISH_GET_AWARD then
                    table.insert(BP_ARRAY_AchievementShowList, temp);
                end
            else
                table.insert(BP_ARRAY_AchievementShowList, temp);
            end
        end
        
        if v.GroupID == BP_ACHIEVEMENT_CurIndex and isValidID then
            BP_ACHIEVEMENT_CATEGORY_TOTAL_NUM = BP_ACHIEVEMENT_CATEGORY_TOTAL_NUM + 1;
            if v.State == BP_ENUM_ACHIEVEMENT_STATE_FINISH_GET_AWARD then
                BP_ACHIEVEMENT_CATEGORY_FINISH_NUM = BP_ACHIEVEMENT_CATEGORY_FINISH_NUM + 1;
            end
        end
    end
    table.sort(BP_ARRAY_AchievementShowList, function(a, b)
        if a.state ~= b.state then
            local weight = {};
            weight[BP_ENUM_ACHIEVEMENT_STATE_NOT_FINISH] = 2;
            weight[BP_ENUM_ACHIEVEMENT_STATE_FINISH_GET_AWARD] = 1;
            weight[BP_ENUM_ACHIEVEMENT_STATE_FINISH_NO_AWARD] = 3;
            local cpA = weight[a.state] or 1;
            local cpB = weight[b.state] or 1;
            return cpA > cpB
        elseif a.version ~= b.version then
            return a.version > b.version
        elseif a.update_time ~= b.update_time then
            return a.update_time > b.update_time
        elseif a.score ~= b.score then
            return a.score > b.score
        else
            return a.id < b.id
        end
    end);
    LuaClassObj.HandleUIMessage(bp_achievement, "UpdateAchievementShowList");
end

function EventTaskAchievementTabSelect()
    if BP_TASK_ACHIEVEMENT_FirstIn then
        BP_TASK_ACHIEVEMENT_FirstIn = false;
        AchievementTaskUI.UpdateNotDoneCheckState();
    end
    
    AchievementTaskUI.RefreshSummaryUI()
end

function EventTaskAchievementSubTabChange_Push()
    log("[yyc] EventTaskAchievementSubTabChange_Push");
    AchievementTaskUI.UpdateAchievementShowList();
end

function EventTaskAchievementNotDoneCheckChange_Push()
    log("[yyc] EventTaskAchievementNotDoneCheckChange_Push BP_ACHIEVEMENT_DONE_CHECK = "..tostring(BP_ACHIEVEMENT_DONE_CHECK));
    AchievementTaskUI.UpdateAchievementShowList();
end

function EventTaskAchievementItemClick_Push()
    log("[yyc] click achievement id "..BP_ACHIEVEMENT_CLICK_ID);
    AchievementDetailUI.SetAchievementDetailID(BP_ACHIEVEMENT_CLICK_ID, true);
    AchievementDetailUI.Show();
end

function EventTaskAchievementClickGetAward_Push()
    AchievementSystem.get_achievement_rewards_req(BP_ACHIEVEMENT_GETAWARD_ID);
end

function EventTaskAchievementShareClick_Push()
    ShareAchievementShareUI.ShowUI(BP_ACHIEVEMENT_SHARE_ID);
end

BP_STRUCT_AchievementSlot =
{
    slot0 = 0,
    slot0_name = "",
    slot0_stamp = "",
    slot1 = 0,
    slot1_name = "",
    slot1_stamp = "",
    slot2 = 0,
    slot2_name = "",
    slot2_stamp = "",
    slot3 = 0,
    slot3_name = "",
    slot3_stamp = "",
}

-- 个人成就总览数据
BP_STRUCT_AchievementSummary =
{
    BP_STRUCT_AchievementSlot = _G.BP_STRUCT_AchievementSlot,
    
    Total_Score = 0, -- 总积分
    Award_Score_Redpoint = false, -- 是否有积分奖励可领
    
    Progress_All = 0,
    Total_All = 0,
    
    Progress_0 = 0,
    Total_0 = 0,
    Progress_1 = 0,
    Total_1 = 0,
    Progress_2 = 0,
    Total_2 = 0,
    Progress_3 = 0,
    Total_3 = 0,
    Progress_4 = 0,
    Total_4 = 0,
    Progress_5 = 0,
    Total_5 = 0,
    Progress_6 = 0,
    Total_6 = 0,
}

BP_Achievement_Slot = 0 -- 当前操作的成就槽位，从1开始计

function AchievementTaskUI.ResetSummaryData()
    BP_Achievement_Slot = 0
    
    BP_STRUCT_AchievementSummary.BP_STRUCT_AchievementSlot = {
        slot0 = 0,
        slot0_name = "",
        slot0_stamp = "",
        slot1 = 0,
        slot1_name = "",
        slot1_stamp = "",
        slot2 = 0,
        slot2_name = "",
        slot2_stamp = "",
        slot3 = 0,
        slot3_name = "",
        slot3_stamp = ""
    }
    
    BP_STRUCT_AchievementSummary.Total_Score = 0
    BP_STRUCT_AchievementSummary.Award_Score_Redpoint = false
    
    BP_STRUCT_AchievementSummary.Progress_All = 0
    BP_STRUCT_AchievementSummary.Total_All = 0
    
    BP_STRUCT_AchievementSummary.Progress_0 = 0
    BP_STRUCT_AchievementSummary.Total_0 = 0
    BP_STRUCT_AchievementSummary.Progress_1 = 0
    BP_STRUCT_AchievementSummary.Total_1 = 0
    BP_STRUCT_AchievementSummary.Progress_2 = 0
    BP_STRUCT_AchievementSummary.Total_2 = 0
    BP_STRUCT_AchievementSummary.Progress_3 = 0
    BP_STRUCT_AchievementSummary.Total_3 = 0
    BP_STRUCT_AchievementSummary.Progress_4 = 0
    BP_STRUCT_AchievementSummary.Total_4 = 0
    BP_STRUCT_AchievementSummary.Progress_5 = 0
    BP_STRUCT_AchievementSummary.Total_5 = 0
    BP_STRUCT_AchievementSummary.Progress_6 = 0
    BP_STRUCT_AchievementSummary.Total_6 = 0
end

-- 根据index序号反查配表里的group id
local function queryGroupIdByIndex(cfg, index)
    for k, v in pairs(cfg) do
        if v.Index == index then
            return v.ID
        end
    end
end

-- 填充上面的首页结构体数据
function AchievementTaskUI.InitSummaryData()
    AchievementTaskUI.ResetSummaryData()
    
    for k, v in pairs(AchievementSystem.Summary.show) do
        local td = Client.GetTableData("AchievementCfg", v);
        if v > 0 and td then
            if k == 1 then
                BP_STRUCT_AchievementSummary.BP_STRUCT_AchievementSlot.slot0 = v
                BP_STRUCT_AchievementSummary.BP_STRUCT_AchievementSlot.slot0_name = AchievementSystem.Data[v].Name
                BP_STRUCT_AchievementSummary.BP_STRUCT_AchievementSlot.slot0_stamp = os.date('%Y.%m.%d', AchievementSystem.Summary.time[1])
            elseif k == 2 then
                BP_STRUCT_AchievementSummary.BP_STRUCT_AchievementSlot.slot1 = v
                BP_STRUCT_AchievementSummary.BP_STRUCT_AchievementSlot.slot1_name = AchievementSystem.Data[v].Name
                BP_STRUCT_AchievementSummary.BP_STRUCT_AchievementSlot.slot1_stamp = os.date('%Y.%m.%d', AchievementSystem.Summary.time[2])
            elseif k == 3 then
                BP_STRUCT_AchievementSummary.BP_STRUCT_AchievementSlot.slot2 = v
                BP_STRUCT_AchievementSummary.BP_STRUCT_AchievementSlot.slot2_name = AchievementSystem.Data[v].Name
                BP_STRUCT_AchievementSummary.BP_STRUCT_AchievementSlot.slot2_stamp = os.date('%Y.%m.%d', AchievementSystem.Summary.time[3])
            elseif k == 4 then
                BP_STRUCT_AchievementSummary.BP_STRUCT_AchievementSlot.slot3 = v
                BP_STRUCT_AchievementSummary.BP_STRUCT_AchievementSlot.slot3_name = AchievementSystem.Data[v].Name
                BP_STRUCT_AchievementSummary.BP_STRUCT_AchievementSlot.slot3_stamp = os.date('%Y.%m.%d', AchievementSystem.Summary.time[4])
            end
        end
    end
    
    BP_STRUCT_AchievementSummary.Total_Score = AchievementSystem.Summary.achieve_score
    BP_STRUCT_AchievementSummary.Award_Score_Redpoint = AchievementSystem.CheckScoreAward()
    log("AchievementTaskUI.InitSummaryData "..BP_STRUCT_AchievementSummary.Total_Score..", "..tostring(BP_STRUCT_AchievementSummary.Award_Score_Redpoint))
    
    if (#AchievementSystem.Summary.progress == 7) then
        BP_STRUCT_AchievementSummary.Progress_All = AchievementSystem.Summary.progress[0][1]
        BP_STRUCT_AchievementSummary.Total_All = AchievementSystem.GetAchievementTotalNum()
        
        local seqCfg = Client.GetTable("AchievementSeqCfg")
        local index = queryGroupIdByIndex(seqCfg, 1)
        BP_STRUCT_AchievementSummary.Progress_0 = AchievementSystem.Summary.progress[index][1]
        BP_STRUCT_AchievementSummary.Total_0 = AchievementSystem.GetAchievementCategoryNum(index)
        index = queryGroupIdByIndex(seqCfg, 2)
        BP_STRUCT_AchievementSummary.Progress_1 = AchievementSystem.Summary.progress[index][1]
        BP_STRUCT_AchievementSummary.Total_1 = AchievementSystem.GetAchievementCategoryNum(index)
        index = queryGroupIdByIndex(seqCfg, 3)
        BP_STRUCT_AchievementSummary.Progress_2 = AchievementSystem.Summary.progress[index][1]
        BP_STRUCT_AchievementSummary.Total_2 = AchievementSystem.GetAchievementCategoryNum(index)
        index = queryGroupIdByIndex(seqCfg, 4)
        BP_STRUCT_AchievementSummary.Progress_3 = AchievementSystem.Summary.progress[index][1]
        BP_STRUCT_AchievementSummary.Total_3 = AchievementSystem.GetAchievementCategoryNum(index)
        index = queryGroupIdByIndex(seqCfg, 5)
        BP_STRUCT_AchievementSummary.Progress_4 = AchievementSystem.Summary.progress[index][1]
        BP_STRUCT_AchievementSummary.Total_4 = AchievementSystem.GetAchievementCategoryNum(index)
        index = queryGroupIdByIndex(seqCfg, 6)
        BP_STRUCT_AchievementSummary.Progress_5 = AchievementSystem.Summary.progress[index][1]
        BP_STRUCT_AchievementSummary.Total_5 = AchievementSystem.GetAchievementCategoryNum(index)
        index = queryGroupIdByIndex(seqCfg, 7)
        BP_STRUCT_AchievementSummary.Progress_6 = AchievementSystem.Summary.progress[index][1]
        BP_STRUCT_AchievementSummary.Total_6 = AchievementSystem.GetAchievementCategoryNum(index)
    end
end

-- 刷新成就总览界面
function AchievementTaskUI.RefreshSummaryUI()
    log("AchievementTaskUI.RefreshSummaryUI")
    AchievementTaskUI.InitSummaryData()
    
    LuaClassObj.HandleUIMessage(bp_achievement, "UpdateAchievementSlots")
    LuaClassObj.HandleUIMessage(bp_achievement, "UpdateAchievementSummary")
    LuaClassObj.HandleUIMessage(bp_task, "UpdateAchievementTabRedDot")
    TaskUI.RefreshLobbyTaskRedDot()
end

-- 刷新总览面板相关的红点
function AchievementTaskUI.RefreshSummaryRedPoint()
    BP_STRUCT_AchievementSummary.Award_Score_Redpoint = AchievementSystem.CheckScoreAward()
    LuaClassObj.HandleUIMessage(bp_achievement, "UpdateAchievementSummary")
    LuaClassObj.HandleUIMessage(bp_task, "UpdateAchievementTabRedDot")
    TaskUI.RefreshLobbyTaskRedDot()
end

-- 直接打开成就面板
function AchievementTaskUI.GotoAchievement()
    LuaClassObj.HandleUIMessage(bp_achievement, "DirectCheckAchievement");
end

-- 清空一个槽位
function EventTaskDeleteAchievement()
    if BP_Achievement_Slot == 0 then return end
    
    AchievementSystem.DeleteAchievement(BP_Achievement_Slot)
end

-- 填充一个槽位
function EventTaskEditAchievement()
    if BP_Achievement_Slot == 0 then return end
    
    SelectAchievementUI.Open(BP_Achievement_Slot)
end

-- 打开成就详情面板
function EventOpenTaskAchievementDetail()
    if BP_Achievement_Slot == 0 then return end
    
    local id = AchievementSystem.Summary.show[BP_Achievement_Slot]
    if id == 0 then return end
    local isSelf = true;
    local param = {};
    param.timestamp = BP_ACHIEVEMENT_OTHER_TIMETAMP;
    AchievementDetailUI.SetAchievementDetailID(id, isSelf, param);
    AchievementDetailUI.Show();
end

-- 打开成就积分领取奖励界面
function EventOpenTaskAchievementScoreAward()
    AchievementScoreAwardUI.Open()
end

BP_ChatShareAchievementId = 0;
BP_ChatShareAchievementGroupId = 0;
-- 从聊天窗口的成就分享跳转而来
function AchievementTaskUI.FromChatShareAchievement(id, groupId)
    BP_ChatShareAchievementId = id;
    BP_ChatShareAchievementGroupId = groupId;
    LuaClassObj.HandleUIMessage(bp_achievement, "JumpFromChatShareAchievement");
    BP_ACHIEVEMENT_CLICK_ID = id;
    AchievementDetailUI.isJumpFromChat = true
    EventTaskAchievementItemClick_Push();
end