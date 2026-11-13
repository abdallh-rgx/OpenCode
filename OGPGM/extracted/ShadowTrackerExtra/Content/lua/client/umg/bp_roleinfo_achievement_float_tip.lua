-- 成就达成通知浮框
AchievementFloatTipUI = AchievementFloatTipUI or
{
    IsOpen = false,
    delayOpenTimer = nil,
    HasClickedIngore = false, --是否点击过忽略
    BlockingPop = false, --屏蔽弹出
};

BP_Achievement_FloatTip_ID = 0;
BP_Achievement_FloatTip_Title = "";
BP_Achievement_FloatTip_Group = 0;
BP_Achievement_FloatTip_GroupNum = 0;
BP_Achievement_FloatTip_ImgUrl = "";
BP_Achievement_FloatTip_QuickHide = false; -- 队列拥挤，需要快速退出当前

BP_STRUCT_Achievement_FloatTip_Awards = {
    score = 0,
    id0 = 0,
    count0 = 0,
    id1 = 0,
    count1 = 0,
};

local TASK_ACHIEVEMENT_SWITCH_ID = 10026 -- 任务里的成就页签的开关

--注册Widget
function bp_roleinfo_achievement_float_tip_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_roleinfo_achievement_float_tip,
        {{Path = "/Game/UMG/UI_Logic/RoleInfo/Achievement/AchievementFloatTip_BP.AchievementFloatTip_BP_C", Container = "Top", ZOrder = BP_ENUM_UI_COMMON_ITEMTIPS_ZORDER-5 }},
        {"Lobby"},
        false,
        bp_roleinfo_achievement_float_tip_OnModeSwitched ~= nil,
        true
    );
end

function bp_roleinfo_achievement_float_tip_OnModeSwitched(gameStatus)
    log("AchievementFloatTipUI OnModeSwitched " .. tostring(gameStatus));
    
    if string.lower(gameStatus) == "lobby" then
        AchievementFloatTipUI.IsOpen = false;
        
        -- 延时三秒之后再处理
        if AchievementFloatTipUI.delayOpenTimer == nil then
            AchievementFloatTipUI.delayOpenTimer = Timer.InsertTimer(4, AchievementFloatTipUI.HandlerTimer, false);
        end
    else
        -- 离开大厅
        AchievementFloatTipUI.Release()
        AchievementSystem.ClearNewAchievementList()
    end
end

function AchievementFloatTipUI.HandlerTimer()
    log("AchievementFloatTipUI delay timer");
    Timer.RemoveTimer(AchievementFloatTipUI.delayOpenTimer);
    AchievementFloatTipUI.delayOpenTimer = nil;
    EventAchievementFloatTipNext();
end

function AchievementFloatTipUI.CheckMenuOpen(id)
    if LobbySystem.LobbyMenuOpenStatus[id] == nil then
        return true
    end
    
    if LobbySystem.LobbyMenuOpenStatus[tonumber(id)].is_open == 0 then
        return false
    else
        return true
    end
end

-- 成就达成通知，从右侧滑入屏幕
function AchievementFloatTipUI.Open(id)

    -- 自动化测试阶段不弹框
    if Client.IsUIAutoTest() then return end

    if AchievementFloatTipUI.BlockingPop then
        return
    end
    if HalloweenVehicleSkinUI.isShow or HalloweenVehicleTrickUI.isShow then return end -- 如果活動界面打開那麼不显示

    if not BP_Achievement_Open_Flag then return end -- 成就总开关关闭

    if AchievementFloatTipUI.HasClickedIngore then return end -- 击过忽略后，玩家在重现登录前都不会接受到成就达成通知了

    if not AchievementFloatTipUI.CheckMenuOpen(TASK_ACHIEVEMENT_SWITCH_ID) then
        return
    end
    
    log("[ft]AchievementFloatTipUI.Open "..id)
    LuaClassObj.HandleDynamicCreation(bp_roleinfo_achievement_float_tip)
    
    BP_Achievement_FloatTip_ID = id
    
    -- 得到该成就的积分和奖励
    local achievement = AchievementSystem.Data[id]
    
    BP_STRUCT_Achievement_FloatTip_Awards = {
        score = achievement.Score,
        id0 = achievement.AwardID,
        count0 = achievement.AwardNum,
        id1 = achievement.AwardID2,
        count1 = achievement.AwardNum2
    }
    
    BP_Achievement_FloatTip_Title = achievement.Name
    BP_Achievement_FloatTip_Group = achievement.GroupID
    BP_Achievement_FloatTip_GroupNum = achievement.MultiLvGroupNum
    BP_Achievement_FloatTip_ImgUrl = achievement.BigImgUrl
    
    LuaClassObj.HandleUIMessage(bp_roleinfo_achievement_float_tip, "ShowTopTip")
    
    AchievementFloatTipUI.IsOpen = true
    
    EventGiftUIClose() -- bug: http://tapd.oa.com/iGameInternational/bugtrace/bugs/view?bug_id=1120360302057197976
end

function AchievementFloatTipUI.Release()
    AchievementFloatTipUI.IsOpen = false
    
    if AchievementFloatTipUI.delayOpenTimer ~= nil then
        Timer.RemoveTimer(AchievementFloatTipUI.delayOpenTimer);
        AchievementFloatTipUI.delayOpenTimer = nil;
    end
    
    LuaClassObj.HandleUIMessage(bp_roleinfo_achievement_float_tip, "StopCountdown")
end

---------------------------------------------------------------------------------------------------
-- BP 接口

function EventAchievementFloatTipPeekNext()
    --log("[ft]EventAchievementFloatTipPeekNext "..#AchievementSystem.AchievementIDList)
    if #AchievementSystem.AchievementIDList > 0 then
        BP_Achievement_FloatTip_QuickHide = true
    else
        BP_Achievement_FloatTip_QuickHide = false
    end
end

-- 浮框退出后，看看还有没有下一个缓存的tip，支持连续弹出
function EventAchievementFloatTipNext()
    log("[ft]animation move out")
    AchievementFloatTipUI.IsOpen = false
    
    -- open next one
    local t = AchievementSystem.AchievementIDList
    if #t > 0 then
        local id = table.remove(t, 1) -- FIFO
        AchievementFloatTipUI.Open(id)
        log("[ft]pop "..id)
    end
end

-- 跳转到个人成就页面
function EventAchievementFloatTipGo()
	--rain 十连抽红包时机改动 http://tapd.oa.com/iGameInternational/prong/stories/view/1020360302063686607
	CorpsWelfareRedEnvelopesUI.ShowPanel()

    if BP_Achievement_FloatTip_ID == 0 then
        BP_ACHIEVEMENT_CurIndex = 1;
    else
        -- 先设置要跳转的子页签
        BP_ACHIEVEMENT_CurIndex = AchievementSystem.Data[BP_Achievement_FloatTip_ID].GroupID
    end
    TaskUI.OpenTaskWithIndex(4)--成就在任务里的index
    AchievementTaskUI.GotoAchievement()
    ClientSendBAReport(BP_BA_ACHIEVEMENT_FLOAT_TIP, 0);

    --跳转的时候如果开着一些二级界面会界面错乱，在这里关掉
    RoleInfoShowInfoUI.SafeHide();
    TeamUpMatchInfoUI.Hide();
    
    --add by cole(仿照以上处理增加一些界面)
    MatchLanguageSelect.Hide();
    ChatLanguageSelect.Hide();
    CommonMessageBoxUI:HidePanel();
    CommonItemGetUI:Hide();
    RoleInfoAliasUI.Hide();
    if OpenBoxtUI.isShow then
        OpenBoxtUI.HidePanel();
    end
    ItemUpgradeUI.Hide();
    AllianceRecruitUI.CloseUI();
    CorpsWelfareRedEnvelopesUI.Close();
    LevelUpSystem.ClosePveLevelupPanel()

    -- add by hy 
    --bug=70961083 【每日冒烟】军备库:军备库界面点击成就浮窗跳转后，出现界面错乱问题
    if ArmoryUI.isShow == true then
        WeaponModelHandler:ResetCamera()
    end
end

-- 清空队列
function EventAchievementFloatTipClear()
    AchievementSystem.ClearNewAchievementList()
end

--忽略
function EventAchievementClickIgnore()
    AchievementFloatTipUI.HasClickedIngore = true
end

-- 旧版本用户升级上来之后，首次初始化成就系统，将所有的历史成就都压入队列
function EventAchievementInitialize()
    AchievementSystem.GetFinishedList()
end

---------------------------------------------------------------------------------------------------
