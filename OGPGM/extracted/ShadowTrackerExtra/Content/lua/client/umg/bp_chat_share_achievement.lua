-- 聊天界面分享成就
ChatShareAchievement = ChatShareAchievement or
{
}

-- 成就显示数量
BP_AchievementShowCount = 20;

-- 玩家名字
BP_AchievementRoleName = "";
-- 要分享的成就的ID
BP_AchievementShareId = 0;
-- 要分享的成就的ID
BP_AchievementShareName = "";

-- 来自聊天窗口数据
-- 分享频道
BP_AchievementShareReceiverId = 0;
BP_AchievementShareChannel = 0;
BP_AchievementShareTopicId = 0;
BP_AchievementShareSelectPlayer = 0;
BP_AchievementShareTopicList = {};

--成就(来自bp_roleinfo)
BP_STRUCT_ShareAchievementInfo =
{
    id = 0,
    img_url = "",
    big_img_url = "",
    des = "",
    title = "",
    state = 1,
    finish_time = "",
    finish_time_row = 0,
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
    update_time = 0,
    owner_player_name = "",
};

--成就所有数据
BP_ARRAY_ChatAchievementList =
{
    BP_STRUCT_ShareAchievementInfo=_G.BP_STRUCT_ShareAchievementInfo,
};

-- 个人成就自设4个
BP_ARRAY_ChatAchievementSummaryList =
{
    BP_STRUCT_ShareAchievementInfo=_G.BP_STRUCT_ShareAchievementInfo,
};

--注册Widget
function bp_chat_share_achievement_RegisterUI()
  LuaClassObj.SubUIWidgetList(bp_chat_share_achievement,
    {{Path="/Game/UMG/UI_Logic/RoleInfo/Achievement/ChatShareAchievement_LogicBP.ChatShareAchievement_LogicBP_C", Container="Default", ZOrder=BP_ENUM_UI_CHAT_SHARE_ZORDER}},
    {"Lobby"},
	false,
    false,
    true
  );

    ChatShareAchievement.Init();
end

--初始化
function ChatShareAchievement.Init()
end

function ChatShareAchievement.UpdateAchievementData()
    -- 收藏成就
    BP_ARRAY_ChatAchievementList = {};
    local contains = false;
    --BP_ARRAY_AchievementShowList = {};
    for k, v in pairs(AchievementSystem.Data) do
        if v.CurProcess >= v.TotalProcess then
            local temp = AchievementDetailUI.MakeSingleDetailData(v.ID);
            temp.finish_time_row = v.FinishTime;
            if temp.state == BP_ENUM_ACHIEVEMENT_STATE_FINISH_GET_AWARD then
                table.insert(BP_ARRAY_ChatAchievementList, temp);
            end
        end
    end

    -- 自设4成就    
    -- log_tree("1", AchievementSystem.Summary);
    -- log_tree("2", AchievementSystem.Data);
    -- log_tree("3", BP_ARRAY_ChatAchievementList);
    BP_ARRAY_ChatAchievementSummaryList = {};
    for k,v in pairs(AchievementSystem.Summary.show) do
        if AchievementSystem.Data ~= nil and AchievementSystem.Data[v] ~= nil then
            local temp = AchievementDetailUI.MakeSingleDetailData(AchievementSystem.Data[v].ID);
            table.insert(BP_ARRAY_ChatAchievementSummaryList, temp);
        -- else
        --     log("Error! Can not get achievement data! (bp_chat_share_achievement.lua : ChatShareAchievement.UpdateAchievementData())")
        end
    end
    -- log_tree("4", BP_ARRAY_ChatAchievementSummaryList);
end

--弹窗
function ChatShareAchievement.Show()
    --LobbyChatEmojiLogic.Init()
    ChatShareAchievement.UpdateAchievementData();
    BP_AchievementRoleName = DataMgr.roleData.nickName;

    LuaClassObj.HandleDynamicCreation(bp_chat_share_achievement);
    LuaClassObj.HandleUIMessage(bp_chat_share_achievement, "UIShow");
    UIManager.Show(eUIType.eChatShareAchievement)
    
    --房间等待时层级问题
    --if RoomWaitingUI.IsShow then
    --    LuaClassObj.SetWidgetZorder(bp_chat_share_achievement,0,52)
    --else
    --    LuaClassObj.RestoreWidgetZorder(bp_chat_share_achievement,0)
    --end
end

-- 分享成就条目
function EventChatShareAchievementItem()
    local title = FuncUtil.GetLocalizeResStr("101001");
    local desc = string.format(FuncUtil.GetLocalizeResStr("5028"), BP_AchievementShareName);
    CommonMessageBoxUI:ShowPanel(2, title, desc, ChatShareAchievement.ConfirmShare, nil); 
end

-- 弹窗确认
function ChatShareAchievement.ConfirmShare()
    --房间等待时层级问题
    --if RoomWaitingUI.IsShow then
    --    LuaClassObj.SetWidgetZorder(bp_chat_share_achievement,0,52)
    --else
    --    LuaClassObj.RestoreWidgetZorder(bp_chat_share_achievement,0)
    --end
    UIManager.Hide(eUIType.eChatShareAchievement)
    LuaClassObj.HandleUIMessage(bp_chat_share_achievement, "UIHide");
    ChatShareAchievementSystem.ShareAchievement(BP_AchievementShareId, BP_AchievementShareName);
end