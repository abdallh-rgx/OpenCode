
AchievementDetailUI = AchievementDetailUI or
{
    isShow = false,
    isJumpFromChat = false,
}

BP_STRUCT_AchievementDetail =
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
    cnd_num = 0,
    score = 0,
    param_des = "",
    show = true,
    update_time = 0,
    share_flag = false,
    version = 0,
};

BP_STRUCT_AchievementCnd =
{
    id = 0,
    totalProcess = 1,
    des = "",
    curProcess = 0,
    param = 0,
    paramID = 0,
    paramDes = "",
};

--成就当前显示数据
BP_ARRAY_AchievementDetailShowList =
{
    BP_STRUCT_AchievementDetail = _G.BP_STRUCT_AchievementDetail,
};

--当前成就条件数据
BP_ARRAY_AchievementCndShowList =
{
    BP_STRUCT_AchievementCnd = _G.BP_STRUCT_AchievementCnd,
};

--当前的成就id
BP_ACHIEVEMENT_DETAIL_ID = 0
BP_ACHIEVEMENT_DETAIL_SHOW_TYPE = 0
BP_ACHIEVEMENT_DETAIL_GetAWARD_ID = 0
BP_ACHIEVEMENT_DETAIL_SHARE_ID = 0
BP_ACHIEVEMENT_DETAIL_IS_SELF = true
BP_ACHIEVEMENT_DETAIL_DONE_TIME = ""

--注册Widget
function bp_achievement_detail_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_achievement_detail,
        {
            {Path = "/Game/UMG/UI_Logic/RoleInfo/Achievement/Achievement_Detail_BP.Achievement_Detail_BP_C", Container = "Default", ZOrder = BP_ENUM_UI_TASK_ZORDER+2},
        },
        {"Lobby"},
        false,
        false,
        true
    );
end

function AchievementDetailUI.Show()
    log("[yyc] AchievementDetailUI.Show");
    AchievementDetailUI.isShow = true;
    LuaClassObj.HandleDynamicCreation(bp_achievement_detail);
    LuaClassObj.HandleUIMessage(bp_achievement_detail, "ShowUI");
    UIManager.Show(eUIType.eAchievementDetailUI)

    EventSystem:registEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN, AchievementDetailUI.ResetHide);
    EventSystem:registEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE, AchievementDetailUI.ResetShow);
    
end

function AchievementDetailUI.Release()
    AchievementDetailUI.isShow = false;
end

function AchievementDetailUI.SetAchievementDetailID(id, isSelf, param)
    BP_ACHIEVEMENT_DETAIL_ID = id;
    local data = AchievementSystem.GetAchievementDataByID(id);
    if not data then
        log("[yyc] SetAchievementDetailID invalid achievement id "..id);
        return;
    end
    BP_ACHIEVEMENT_DETAIL_SHOW_TYPE = data.ShowType;
    --如果是看其他人的成就详情 多阶成就显示成单条件成就
    if not isSelf then
        if data.ShowType == BP_ENUM_ACHIEVEMENT_SHOW_TYPE_MULTI_LV then
            BP_ACHIEVEMENT_DETAIL_SHOW_TYPE = BP_ENUM_ACHIEVEMENT_SHOW_TYPE_SINGLE_CND;
        elseif data.ShowType == BP_ENUM_ACHIEVEMENT_SHOW_TYPE_RANK then
            BP_ACHIEVEMENT_DETAIL_SHOW_TYPE = BP_ENUM_ACHIEVEMENT_SHOW_TYPE_SINGLE_NO_PROCESS;
        end
    end
    BP_ACHIEVEMENT_DETAIL_IS_SELF = isSelf;
    if param then
        BP_ACHIEVEMENT_DETAIL_DONE_TIME = param.timestamp or "";
    end
    
    if (data.ShowType == BP_ENUM_ACHIEVEMENT_SHOW_TYPE_MULTI_LV or data.ShowType == BP_ENUM_ACHIEVEMENT_SHOW_TYPE_RANK)
        and isSelf then
        --多阶成就
        BP_ARRAY_AchievementDetailShowList = {};
        local ids = AchievementSystem.GetAchievementIDsByMultiLvGroup(data.MultiLvGroupID);
        if ids then
            for _, v in pairs(ids) do
                table.insert(BP_ARRAY_AchievementDetailShowList, AchievementDetailUI.MakeSingleDetailData(v))
            end
        else
            log("[yyc] GroupID is not valid "..data.MultiLvGroupID);
        end
        table.sort(BP_ARRAY_AchievementDetailShowList, function(a, b)
            return a.id < b.id
        end);
        log_tree("[yyc] BP_ARRAY_AchievementDetailShowList", BP_ARRAY_AchievementDetailShowList);
    else
        BP_ARRAY_AchievementCndShowList = {};
        for cndID, v in pairs(data.ParserCnds) do
            for param, d in pairs(v) do
                table.insert(BP_ARRAY_AchievementCndShowList, d);
            end
        end
        table.sort(BP_ARRAY_AchievementCndShowList, function(a, b)
            return a.param < b.param
        end);
        log_tree("[yyc] BP_ARRAY_AchievementCndShowList", BP_ARRAY_AchievementCndShowList);
    end
    
    BP_STRUCT_AchievementDetail = AchievementDetailUI.MakeSingleDetailData(id);
end

function AchievementDetailUI.MakeSingleDetailData(id)
    local ret = {};
    local data = AchievementSystem.GetAchievementDataByID(id);
    
    ret.id = data.ID
    ret.img_url = data.ImgUrl
    ret.big_img_url = data.BigImgUrl
    ret.des = data.Desc
    ret.title = data.Name
    ret.state = data.State
    ret.finish_time = os.date('%Y.%m.%d', data.FinishTime)
    ret.award_id = data.AwardID
    ret.award_num = data.AwardNum
    ret.award2_id = data.AwardID2
    ret.award2_num = data.AwardNum2
    ret.group_id = data.GroupID
    ret.total_process = data.TotalProcess
    ret.cur_process = data.CurProcess
    ret.cnd_num = data.ConditionNum
    ret.score = data.Score
    ret.param_des = data.ParamDes
    ret.show = data.Show
    ret.update_time = data.UpdateTime
    ret.share_flag = data.ShareFlag > 0 and true or false
    ret.group_title = data.MultiLvGroupTitle
    ret.group_num = data.MultiLvGroupNum
    ret.version = data.Version
    
    return ret;
end

function AchievementDetailUI.UpdateAchievementDetailState(data)
    --只对多阶成就的详情界面有效果
    if data.MultiLvGroupID ~= 0 then
        if AchievementDetailUI.isShow then
            AchievementDetailUI.SetAchievementDetailID(data.ID, true);
            LuaClassObj.HandleUIMessage(bp_achievement_detail, "UpdateMultiAchievementState");
        end
    end
end

function AchievementDetailUI.ResetShow()
    LuaClassObj.HandleUIMessage(bp_achievement_detail, "ShowSelf");
end

function AchievementDetailUI.ResetHide()
    LuaClassObj.HandleUIMessage(bp_achievement_detail, "HideSelf");
end

function EventCloseBtnClick()
    UIManager.Hide(eUIType.eAchievementDetailUI)
    AchievementDetailUI.Release();
    AchievementDetailUI.isJumpFromChat = false
    EventSystem:unregistEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN, AchievementDetailUI.ResetHide);
    EventSystem:unregistEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE, AchievementDetailUI.ResetShow);
end

function EventGetAward_Push()
    AchievementSystem.get_achievement_rewards_req(BP_ACHIEVEMENT_DETAIL_GetAWARD_ID);
end

function EventShareClick_Push()
    ShareAchievementShareUI.ShowUI(BP_ACHIEVEMENT_DETAIL_SHARE_ID);
end
