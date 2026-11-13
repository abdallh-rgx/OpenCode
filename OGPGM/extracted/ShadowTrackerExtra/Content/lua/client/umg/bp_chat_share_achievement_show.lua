-- 点击聊天界面分享的成就，顶上显示详情
ChatShareAchievementShow = ChatShareAchievementShow or
{
    -- chatInited = false;
}

--注册Widget
function bp_chat_share_achievement_show_RegisterUI()
  LuaClassObj.SubUIWidgetList(bp_chat_share_achievement_show,
    {{Path="/Game/UMG/UI_BP/RoleInfo/ChatShareAchievement_Item_UIBP.ChatShareAchievement_Item_UIBP_C", Container="Default", ZOrder=BP_ENUM_UI_CHAT_SHARE_ZORDER}},
    {"Lobby"},
	false,
    false,
    true
  );

    -- ChatShareAchievement.Init();
end

--创建
function ChatShareAchievementShow.Create()
    LuaClassObj.HandleDynamicCreation(bp_chat_share_achievement_show);
end

--成就
BP_STRUCT_ChatShareAchievementInfoShow =
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
    update_time = 0,
    owner_player_name = "",
};

BP_ShareAchievementPositionX = 0;   --显示位置
-- 展示数据
function ChatShareAchievementShow.ShowData(posX)
    BP_ShareAchievementPositionX = posX;
    LuaClassObj.HandleDynamicCreation(bp_chat_share_achievement_show);
    LuaClassObj.HandleUIMessage(bp_chat_share_achievement_show, "ResetDataAndShow");
    LuaClassObj.HandleUIMessage(bp_chat_share_achievement_show, "UIShow");
    UIManager.Show(eUIType.eChatShareAchievementShow)
end

-- 到成就界面看详情
function EventJumpToDetail()
    TaskUI.OpenTaskWithIndex(4)
    local id = BP_STRUCT_ChatShareAchievementInfoShow.id;
    local groupId = BP_STRUCT_ChatShareAchievementInfoShow.group_id;
    -- log("id"..tostring(id).."   groupId "..tostring(groupId));
    TaskUI.FromChatShareAchievement(id, groupId);
    UIManager.Hide(eUIType.eChatShareAchievementShow)
    LuaClassObj.HandleUIMessage(bp_chat_share_achievement_show, "UIHide")
end

--获得成就描述
function ChatShareAchievementShow.GetDesc(desc)
    local res = ""
    local delTable = {}
    local indexi = 0
    local indexj = 0
    
    for i = 1, #desc do
        local ch = string.sub(desc, i, i)
        if ch == "<" then
            indexi = i
        elseif ch == ">" then
            if indexi ~= 0 then
                indexj = i
                table.insert(delTable, indexi)
                table.insert(delTable, indexj)
                indexi = 0
                indexj = 0
            end
        end
    end
    
    local j = 0
    for i, v in pairs(delTable) do
        if i % 2 == 1 then
            res = res..(string.sub(desc, j, v - 1))
        else
            j = v + 1
        end
    end
    res = res..(string.sub(desc, j, #desc))
    return res
end