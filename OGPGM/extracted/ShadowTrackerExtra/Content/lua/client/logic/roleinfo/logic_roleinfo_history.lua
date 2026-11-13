--[[
  个人信息历史战绩
]]--

RoleInfoHistorySystem = RoleInfoHistorySystem or
{
    uid = "",
    history_record_summary = 
    {
        battle_id = 0,
        battle_type = 0,
        time = 0,
        person_rank = 0,
        team_rank = 0,
        kill = 0,
        segment = 0,
        rating = 0,
        change_rating = 0,
        final_level = "",
        title_id = 0,
    },
    role_history_record = {},
    record_summary_list = {},
    show_record_battle_id = 0,
    privacy = true,
    cachedUid = "",
}


function RoleInfoHistorySystem.Enter(uid)
    log("RoleInfoHistorySystem Enter uid:" .. uid)
    RoleInfoHistorySystem.uid = uid

    --增加缓存
    if tonumber(RoleInfoHistorySystem.cachedUid) == tonumber(uid) then
        RoleInfoHistorySystem.get_history_record_summary_rsp(uid,RoleInfoHistorySystem.record_summary_list)
    else
        RoleInfoHistorySystem.get_history_record_summary()
    end
end

function RoleInfoHistorySystem.Release()
    RoleInfoHistorySystem.uid = ""
    RoleInfoHistorySystem.role_history_record = {}

    log("RoleInfoHistorySystem.Release")
end

function RoleInfoHistorySystem.ReqRecord(id)
    RoleInfoHistorySystem.show_record_battle_id = id
    local data = RoleInfoHistorySystem.role_history_record[RoleInfoHistorySystem.show_record_battle_id]
    if data then
        RoleInfoHistoryUI.ShowRecord(data)
    else
        local cache_num = 2
        --一次请求5个详细信息
        local function find_id()
            for i,v in ipairs(RoleInfoHistorySystem.record_summary_list) do
                if RoleInfoHistorySystem.show_record_battle_id == v.battle_id then
                    return i
                end
            end
        end
        local id = find_id()
        if id then
            local tmp = {}
            for i=id-cache_num,id+cache_num do
                local s = RoleInfoHistorySystem.record_summary_list[i]
                if s then
                    local data = RoleInfoHistorySystem.role_history_record[s.battle_id]
                    if data == nil then
                        table.insert(tmp, s.battle_id);
                    end
                end
            end
            if #tmp > 0 then
                RoleInfoHistorySystem.bath_get_history_record(tmp)
            end
        end
    end
end

function RoleInfoHistorySystem.get_history_record_summary()
    --是他人，且不能显示历史战绩，则不拉取，直接刷新
    if not RoleInfoHistorySystem.privacy and  RoleInfoHistorySystem.uid ~= DataMgr.roleData.uid then
        RoleInfoHistoryUI.Refresh()
        return
    end

    NetUtil.SendPriorityPkg(false, "get_history_record_summary_rsp", "get_history_record_summary", tonumber(RoleInfoHistorySystem.uid));
end
function RoleInfoHistorySystem.get_history_record_summary_rsp(uid,list)
    --log_tree("get_history_record_summary_rsp", {uid,list})
    RoleInfoHistorySystem.cachedUid = uid
    RoleInfoHistorySystem.record_summary_list = list
    table.sort(RoleInfoHistorySystem.record_summary_list, function(a,b) return a.time > b.time end)
    --最多显示100条
    local limit = 100
    local num = #RoleInfoHistorySystem.record_summary_list
    for i=num,limit+1,-1 do
        table.remove(RoleInfoHistorySystem.record_summary_list)
    end
    
    --log_tree("RoleInfoHistorySystem.record_summary_list", RoleInfoHistorySystem.record_summary_list)
    RoleInfoHistoryUI.Refresh()
end

function RoleInfoHistorySystem.send_show_history(showHistory)
    local privacyValue = true
    if showHistory ~= nil then
        privacyValue = showHistory
    end
    RoleInfoHistorySystem.privacy = showHistory
    NetUtil.SendPkg("modify_role_privacy", privacyValue);
end

function RoleInfoHistorySystem.SetCanShowHistory(canShow)
     -- 设置显示历史战绩否
    RoleInfoHistorySystem.privacy = canShow
    RoleInfoHistoryUI.ReceiveCanShowHistory(canShow)
end

function RoleInfoHistorySystem.bath_get_history_record(battle_ids)
    if tonumber(RoleInfoHistorySystem.uid) == nil then
        log("bath_get_history_record RoleInfoHistorySystem.uid = nil:" .. debug.traceback())
        return
    end
    NetUtil.SendPriorityPkg(false, "bath_get_history_record_rsp", "bath_get_history_record", tonumber(RoleInfoHistorySystem.uid), battle_ids);
end
function RoleInfoHistorySystem.bath_get_history_record_rsp(uid,history_record_list)
    --log_tree("bath_get_history_record_rsp", {uid,history_record_list})
    for i,v in ipairs(history_record_list) do
        RoleInfoHistorySystem.role_history_record[v.battle_id] = v
    end
    local data = RoleInfoHistorySystem.role_history_record[RoleInfoHistorySystem.show_record_battle_id]
    if data then
        RoleInfoHistoryUI.ShowRecord(data)
    end
end

function RoleInfoHistorySystem.notify_first_history_record(is_first_record)
    --log_tree("notify_first_history_record", {is_first_record})
    BP_RoleInfo_HistoryRedpoint = true
end

--[[网络回调]]--
s2c["get_history_record_summary_rsp"] = RoleInfoHistorySystem.get_history_record_summary_rsp;
s2c["bath_get_history_record_rsp"] = RoleInfoHistorySystem.bath_get_history_record_rsp;
s2c["notify_first_history_record"] = RoleInfoHistorySystem.notify_first_history_record;

