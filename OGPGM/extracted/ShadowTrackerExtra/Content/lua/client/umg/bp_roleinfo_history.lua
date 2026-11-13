--个人信息历史战绩
RoleInfoHistoryUI = RoleInfoHistoryUI or
{
    IsShow = false,
}

BP_STRUCT_RoleInfoHistoryItem =
{
	battle_id = "",
    battle_type = "",
    time = "",
    rank = 0,
    kill = "",
    segment = 0,
    rating = "",
    change_rating = "",
    final_level = "",
    title_id = 0,
    show_score = true,
};

BP_ARRAY_RoleInfoHistoryList =
{
	BP_STRUCT_RoleInfoHistoryItem = _G.BP_STRUCT_RoleInfoHistoryItem,
};

BP_RoleInfoHistoryShowRecordBattleId = ""
BP_RoleInfoCanShowHistory = true
BP_RoleInfoHistoryEmptyType = 0

--注册Widget
function bp_roleinfo_history_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_roleinfo_history,
		{{Path="/Game/UMG/UI_Logic/RoleInfo/RoleInfo_History_BP.RoleInfo_History_BP_C", Container="Default", ZOrder=BP_ENUM_UI_ROLEINFO_ZORDER+1}},
		{"Lobby"},
		false,
		bp_roleinfo_history_OnModeSwitched ~= nil,
		true
	);
end

--跳转到Lobby
function bp_roleinfo_history_OnModeSwitched(gamestatus)
	if string.lower(gamestatus) == "lobby" then
        LobbyUI:LobbyRedPointUpdate(BP_ENUM_LOBBY_MENU_ROLE_INFO, BP_RoleInfo_HistoryRedpoint)
	end
end

function RoleInfoHistoryUI.Show(uid)
    log("RoleInfoHistoryUI.Show")
    RoleInfoHistoryUI.IsShow = true
    LuaClassObj.HandleDynamicCreation(bp_roleinfo_history);
    
    RoleInfoHistorySystem.Enter(uid)
    LuaClassObj.HandleDynamicCreation(bp_roleinfo_history);   --防止UI释放
    LuaClassObj.HandleUIMessage(bp_roleinfo_history, "ShowUI");
    UIManager.Show(eUIType.eRoleInfoHistoryUI)
    RoleInfoHistoryUI.HideRedpoint();
end

function RoleInfoHistoryUI.ReceiveCanShowHistory(showHistory)
    -- 异常则显示
    if showHistory == nil then
        BP_RoleInfoCanShowHistory = true
    else
        BP_RoleInfoCanShowHistory = showHistory
    end
end

local function FormatTime(tm)
    if type(tm) == "number" and tm >= 0 then
        local dt = os.date("*t", tm)
        return string.format("%02d-%02d %02d:%02d", dt.month, dt.day, dt.hour, dt.min)
    end
    return ""
end

local function localText(id)
    if id then
        local data = Client.GetTableData("LocalizeRes",id);
        if data then
            return data.TextValue
        end
    end
    return ""
end

-- if not RoleInfoHistorySystem.privacy and  RoleInfoHistorySystem.uid ~= DataMgr.roleData.uid then

function RoleInfoHistoryUI.Refresh()
    if not RoleInfoHistoryUI.IsShow then
        return
    end
    local ListCount = 0
    BP_ARRAY_RoleInfoHistoryList = {}
        
    if BP_RoleInfoCanShowHistory or RoleInfoHistorySystem.uid == DataMgr.roleData.uid then
        for i,v in ipairs(RoleInfoHistorySystem.record_summary_list) do
            local tmp = {}
            tmp.battle_id = tostring(v.battle_id)
            tmp.battle_type = ""
            tmp.rank = 0
            tmp.show_score = true
            local cfg = Client.GetTableData("MatchModeTable", v.battle_type)
            if cfg then
                local function get_bt(sub_mode)
                    if sub_mode then
                        local cfg_sub_mode = Client.GetTableData("BTMode", sub_mode)
                        if cfg_sub_mode then
                            return string.format("%s\n%s-%s", localText(cfg.WordsToShowID), localText(cfg_sub_mode.NumberShowId), localText(cfg_sub_mode.MapShowId))
                        end
                    end
                    return ""
                end
                if type(v.sub_mode) == "number" then
                    tmp.battle_type = get_bt(v.sub_mode)
                    if cfg.ModeType == 2 or cfg.ModeType == 4 then
                        tmp.show_score = false
                    end
                else
                    --老数据
                    local tmp2 = {
                        [101] = 1001,
                        [102] = 1002,
                        [103] = 1003,
                    }
                    tmp.battle_type = get_bt(tmp2[v.battle_type])
                end
                if cfg.MaxTeamPlayerNum == 1 then
                    tmp.rank = v.person_rank
                else
                    tmp.rank = v.team_rank
                end
            end
            tmp.time = FormatTime(v.time)
            tmp.kill = tostring(v.kill)
            tmp.segment = v.segment
            tmp.rating = tostring(v.rating)
            tmp.change_rating = ""
            if v.change_rating < 0 then
                tmp.change_rating = string.format("(-%d)", -v.change_rating)
            elseif v.change_rating > 0 then
                tmp.change_rating = string.format("(+%d)", v.change_rating)
            end
            tmp.final_level = v.final_level
            tmp.BP_ARRAY_RoleInfoHistoryTitleId = {}
            tmp.title_id = -1
            if type(v.title_id) == "table" then
                if v.title_id[1] then
                    tmp.title_id = v.title_id[1]
                end
            end
            table.insert(BP_ARRAY_RoleInfoHistoryList, tmp)
            ListCount = ListCount + 1
        end
    end

    -- 记录没有历史战绩的类型
    BP_RoleInfoHistoryEmptyType = 0
    if ListCount == 0 then
        if RoleInfoHistorySystem.uid == DataMgr.roleData.uid then
            BP_RoleInfoHistoryEmptyType = 1
        else
            if BP_RoleInfoCanShowHistory then
                BP_RoleInfoHistoryEmptyType = 2
            else
                BP_RoleInfoHistoryEmptyType = 3
            end
        end
    end
    LuaClassObj.HandleUIMessage(bp_roleinfo_history, "RefreshUI");
end

function RoleInfoHistoryUI.ShowRecord(data)
    if not RoleInfoHistoryUI.IsShow then
        return
    end
    if RoleInfoHistoryDetailSystem and RoleInfoHistoryDetailSystem.Enter then
        RoleInfoHistoryDetailSystem.Enter(data)
		RoleInfoHistoryDetailUI.Init()
    end
end

function RoleInfoHistoryUI.HideRedpoint()
    BP_RoleInfo_HistoryRedpoint = false
    RoleInfoUI.UpdateHistoryRedpoint()
    LobbyUI:LobbyRedPointUpdate(BP_ENUM_LOBBY_MENU_ROLE_INFO, BP_RoleInfo_HistoryRedpoint)
end

function RoleInfoHistoryUI.HideUI()
    log("RoleInfoHistoryUI.HideUI")
    LuaClassObj.HandleUIMessageNoFetch(bp_roleinfo_history, "HideUI")    
end
--(以Event开头的函数名就能暴露给蓝图调用)

function EventRoleInfoHistoryUIClose()
    UIManager.Hide(eUIType.eRoleInfoHistoryUI)
    RoleInfoHistoryUI.IsShow = false
    RoleInfoHistorySystem.Release()
end

function EventRoleInfoHistoryShowRecord()
    --log("EventRoleInfoHistoryShowRecord="..BP_RoleInfoHistoryShowRecordBattleId)
    RoleInfoHistorySystem.ReqRecord(tonumber(BP_RoleInfoHistoryShowRecordBattleId))
end

function EventRoleInfoHistorySettingHistory()
    RoleInfoHistoryUI.SendCanShowHistory()
end



