AchievementAwardUI = AchievementAwardUI or
{
    isShow = false;
}

BP_ACHIEVEMENT_AWARD_SCORE = 10

--注册Widget
function bp_achievement_award_RegisterUI()
    log("yyc  bp_achievement_award_RegisterUI ")
    LuaClassObj.SubUIWidgetList(bp_achievement_award,
        {
            {Path = "/Game/UMG/UI_Logic/RoleInfo/Achievement/Achievement_Award_BP.Achievement_Award_BP_C", Container = "Top", ZOrder = BP_ENUM_UI_COMMON_ITEM_GET_ZORDER + 1},
        },
        {"Lobby"},
        false,
        false,
        true
    );
    log("yyc  bp_achievement_award_RegisterUI ")
end

function AchievementAwardUI.Show(score)
    log("[yyc] AchievementAwardUI.Show");
    AchievementAwardUI.isShow = true;
    BP_ACHIEVEMENT_AWARD_SCORE = score;
    LuaClassObj.HandleDynamicCreation(bp_achievement_award);
    LuaClassObj.HandleUIMessage(bp_achievement_award, "ShowUI");
end

function AchievementAwardUI.Hide()
    log("[yyc] AchievementAwardUI.Hide");
    LuaClassObj.HandleUIMessage(bp_achievement_award, "HideUI");
    AchievementAwardUI.isShow = false;
end
