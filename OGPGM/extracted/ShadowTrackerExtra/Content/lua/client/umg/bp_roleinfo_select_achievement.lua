--选择在个人成就首页展示的成就
SelectAchievementUI = SelectAchievementUI or
{
    bShow = false,
};

-- 可挑选的成就项
BP_STRUCT_AchievementSelectItem =
{
    id = 0,
    group = 1,
    star = 0,
    icon = "",
    name = "",
    state = "", --状态 use使用中,has拥有,none未拥有
};

BP_ARRAY_AchievementSelectItem =
{
    BP_STRUCT_AchievementSelectItem = _G.BP_STRUCT_AchievementSelectItem,
};

-- 当前展示的成就列表
BP_ARRAY_SelectItemIdList =
{
    id = 0,
}

BP_Achievement_Select_Slot = 0; -- 当前要替换的槽位，从1开始计
BP_Achievement_Select_ItemId = 0; -- 当前选中的成就ID

--注册Widget
function bp_roleinfo_select_achievement_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_roleinfo_select_achievement,
        {{Path = "/Game/UMG/UI_Logic/RoleInfo/Achievement/SelectAchievement_BP.SelectAchievement_BP_C", Container = "Default", ZOrder = BP_ENUM_UI_TASK_ZORDER + 2}},
        {"Lobby"},
        false,
        false,
        true
    );
end

-- 打开界面
function SelectAchievementUI.Open(slot)
    log("SelectAchievementUI.Open "..slot);
    BP_Achievement_Select_Slot = slot;
    BP_Achievement_Select_ItemId = 0;
    LuaClassObj.HandleDynamicCreation(bp_roleinfo_select_achievement);
    SelectAchievementUI.InitData();
    LuaClassObj.HandleUIMessage(bp_roleinfo_select_achievement, "ShowUI");
    UIManager.Show(eUIType.eRoleInfoSelectAchievementUI)
    SelectAchievementUI.bShow = true
end

function SelectAchievementUI.Release()
    --log("SelectAchievementUI.Release");
end

function SelectAchievementUI.InitData()
    -- 选择当前哪些成就外显
    BP_ARRAY_SelectItemIdList = {0, 0, 0, 0}
    if AchievementSystem.Summary.show ~= nil then
        for k, v in pairs(AchievementSystem.Summary.show) do
            BP_ARRAY_SelectItemIdList[k] = v
        end
    end
    
    -- 收集所有的成就记录
    BP_ARRAY_AchievementSelectItem = {}
    local data = AchievementSystem.Data
    for k, v in pairs(data) do
        if AchievementSystem.IsValidAchievementID(v.ID) then
            local dat = {
                id = v.ID,
                group = v.GroupID,
                star = v.MultiLvGroupNum,
                icon = v.BigImgUrl,
                name = v.Name,
                state = "none",
                time = v.FinishTime,
                score = v.Score
            };
            
            if dat.time > 0 then -- 已经达成
                dat.state = "has"
            end
            
            for i, s in ipairs(BP_ARRAY_SelectItemIdList) do
                if s == dat.id then
                    dat.state = "use"
                    break
                end
            end
            
            table.insert(BP_ARRAY_AchievementSelectItem, dat)
        end
        
    end
    
    --排序
    local function funcSort(a, b)
        if a.time > b.time then
            return true
        elseif a.time == b.time then
            if a.score > b.score then
                return true
            elseif a.score == b.score then
                return a.id < b.id
            else
                return false
            end
        else
            return false
        end
    end
    table.sort(BP_ARRAY_AchievementSelectItem, funcSort)
end

function SelectAchievementUI.IsShow()
    return SelectAchievementUI.bShow
end

function SelectAchievementUI.Close()
    LuaClassObj.HandleUIMessage(bp_roleinfo_select_achievement, "ShowUI")
end

---------------------------------------------------------------------------------------------------
-- BP 接口

function EventSelectAchievementUIClose()
    --log("EventSelectAchievementUIClose");
    UIManager.Hide(eUIType.eRoleInfoSelectAchievementUI)
    SelectAchievementUI.Release()
    SelectAchievementUI.bShow = false
end

-- 使用该成就来填充外显槽位
function EventSelectAchievementUse()
    if BP_Achievement_Select_Slot == 0 or BP_Achievement_Select_ItemId == 0 then return end
    
    local req = {}
    for k, v in pairs(BP_ARRAY_SelectItemIdList) do
        if k == BP_Achievement_Select_Slot then
            req[k] = BP_Achievement_Select_ItemId
        else
            req[k] = v
        end
    end
    
    -- 等svr回包成功后再关闭此窗口
    AchievementSystem.set_achievement_show_req(req)
end

---------------------------------------------------------------------------------------------------
