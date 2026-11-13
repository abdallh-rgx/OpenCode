--军团特训
CorpsTrainingSystem = CorpsTrainingSystem or {
    TodayTrainID = 0,
    TodaySelfTaskID = 0,
    TodaySelfTotal = 0,
    TodaySelfScore = 0,
    TodaySelfStatus = 1,
    TodaySelfAwards = {},
    
    TodayCorpsScore = 0,
    TodayCorpsTaskList = {},

    TodayRankList = {},

    TrainHisRankInfo = {}, --历史排行信息

    reqTrainInfoCallBack = nil,

    reqRoleInfoTimeList = {},

    TrainRoleInfo = {},

    TrainRedPointIsShow = false,

    TodayWeekDay = 0,
}

function CorpsTrainingSystem.ResetData()
    CorpsTrainingSystem.TodayTrainID = 0;
    CorpsTrainingSystem.TodaySelfTaskID = 0;
    CorpsTrainingSystem.TodaySelfTotal = 0;
    CorpsTrainingSystem.TodaySelfScore = 0;
    CorpsTrainingSystem.TodaySelfStatus = 1;
    CorpsTrainingSystem.TodaySelfAwards = {};
    
    CorpsTrainingSystem.TodayCorpsScore = 0;
    CorpsTrainingSystem.TodayCorpsTaskList = {};

    CorpsTrainingSystem.TodayRankList = {};

    CorpsTrainingSystem.TrainHisRankInfo = {}; 

    CorpsTrainingSystem.reqTrainInfoCallBack = nil;

    CorpsTrainingSystem.reqRoleInfoTimeList = {};

    CorpsTrainingSystem.TrainRoleInfo = {};

    CorpsTrainingSystem.TrainRedPointIsShow = false;
end

function CorpsTrainingSystem.GenRoleInfoData(info)
    local data = {
        uid   = info.uid,
        name  = info.nickName,
        plat_name = info.platName,
        url   = info.picUrl,
        level = info.level,
        city  = info.city,
        gender = info.sex,
        cur_avatar_box_id = info.cur_avatar_box_id,
		startup_type = info.startup_type,
		qq_vip = info.qq_vip,
    };

    return data;
end

function CorpsTrainingSystem.IsNeedReqRoleInfo(uid)
    local tm = CorpsTrainingSystem.reqRoleInfoTimeList[tostring(uid)];
    local now_tm = os.time();
    if tm == nil or (now_tm - tm >= 60) then
        return true;
    end

    return false;
end

function CorpsTrainingSystem.RecordRoleInfoReq(uid)
    CorpsTrainingSystem.reqRoleInfoTimeList[tostring(uid)] = os.time();
end

function CorpsTrainingSystem.GetTrainRoleInfo(uid)
    local info = CorpsTrainingSystem.TrainRoleInfo[tostring(uid)];

    return info;
end

function CorpsTrainingSystem.GetTodayTrainCfg()
    local cfg = Client.GetTableData("CorpsTrainingConfig", CorpsTrainingSystem.TodayTrainID);
    
    return cfg;
end

function CorpsTrainingSystem.JumpToTodayTrain()
    local cfg = Client.GetTableData("CorpsTrainingConfig", CorpsTrainingSystem.TodayTrainID);
    if nil == cfg then
        return ;
    end

    if _G[cfg.JumpID] == nil then
        return;
    end

    GlobalData:JumpUrl("game://?module=" .. _G[cfg.JumpID]);
end

function CorpsTrainingSystem.IsCanOpenTraining()
    local switch = LobbySystem.LobbyMenuOpenStatus[BP_ENUM_CORPS_UI_TRAINING];
    if switch == nil then
        return true;
    end

    if switch.is_open == 1 then
        return true;
    else
        return false;
    end
end

function CorpsTrainingSystem.OpenTrainingUI()
    if not CorpsTrainingSystem.IsCanOpenTraining() then
        ShowNotice(116009);
        return;
    end

    CorpsTrainingSystem.ReqCorpsTrainingInfo(true,function()
        CorpsTrainingUI.Show();
    end)
end

function CorpsTrainingSystem.ReqCorpsTrainingInfo(isWaitting, callback)
    CorpsTrainingSystem.reqTrainInfoCallBack = callback;

    if isWaitting then
        NetUtil.SendPkg("get_corps_training_req");
    else
        NetUtil.SendPkg("get_corps_training_req");
    end
end

function CorpsTrainingSystem.ReqCorpsTrainingAward(task_id)
    NetUtil.SendPkg("corps_training_award_req", task_id);
end

function CorpsTrainingSystem.get_corps_training_res(res, train_info)
    log("CorpsTrainingSystem.get_corps_training_res res="..tostring(res));
    if tonumber(res) ~= 0 then
        ShowNotice(res)
        return;
    end
    log_tree("CorpsTrainingSystem.get_corps_training_res train_info=", train_info);
    if nil ~= train_info.today_train.today_date then
        CorpsTrainingSystem.TodayWeekDay = train_info.today_train.today_date;
    else
        CorpsTrainingSystem.TodayWeekDay = FuncUtil.GetServerWeekDay();
    end

    CorpsTrainingSystem.TodayTrainID = train_info.today_train.train_id;
    CorpsTrainingSystem.TodaySelfTaskID = train_info.today_train.person_task.task_id;
    CorpsTrainingSystem.TodaySelfTotal = train_info.today_train.person_task.target;
    CorpsTrainingSystem.TodaySelfScore = 0;
    CorpsTrainingSystem.TodaySelfStatus = train_info.today_train.person_task.status;
    
    CorpsTrainingSystem.TodaySelfAwards = train_info.today_train.person_task.award_list;

    CorpsTrainingSystem.TodayCorpsTaskList = train_info.today_train.corps_task;

    CorpsTrainingSystem.TodayCorpsScore = 0;

    CorpsTrainingSystem.TrainHisRankInfo = train_info.train_rank;

    CorpsTrainingSystem.TodayRankList = {};

    local curWeek = CorpsTrainingSystem.TodayWeekDay;
    --log("CorpsTrainingSystem.get_corps_training_res curWeek="..curWeek);
    local curRankData = train_info.train_rank[curWeek];
    local uidList = {};
    if nil ~= curRankData then
        CorpsTrainingSystem.TodayCorpsScore = curRankData.corps_score;
        for k, v in pairs(curRankData.members) do
            if tostring(k) == tostring(DataMgr.roleData.uid) then
                CorpsTrainingSystem.TodaySelfScore = v;
            end

            if v > 0 then
                local rankItem = {};
                rankItem.uid = k;
                rankItem.score = v;
                rankItem.time = 0;
                if curRankData.last_train_time ~= nil then
                    rankItem.time = GetSafeNumber(curRankData.last_train_time[k]);
                end
                table.insert( CorpsTrainingSystem.TodayRankList, rankItem );

                if CorpsTrainingSystem.IsNeedReqRoleInfo(k) then
                    table.insert(uidList, k);
                    CorpsTrainingSystem.RecordRoleInfoReq(k);
                end
            end
        end

        table.sort( CorpsTrainingSystem.TodayRankList, function(a, b)
            return (a.score > b.score) or (a.score == b.score and a.time < b.time);
        end )

        if #uidList > 0 then
            CorpsTrainingSystem.GetRankRoleProfile(uidList);
        end
    end

    CorpsTrainingSystem.CheckRedPoint();

    EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_TRAINING_UPDATE_INFO);

    if CorpsTrainingSystem.reqTrainInfoCallBack ~= nil then
        CorpsTrainingSystem.reqTrainInfoCallBack();
    end

end

function CorpsTrainingSystem.GetRankRoleProfile(uidList)
    ProfileMgr.GetProfileList(uidList,CorpsTrainingSystem.on_get_role_info_rsp,true);
end

function CorpsTrainingSystem.on_get_role_info_rsp(profileList)
    for k, v in pairs(profileList) do
        local roleData = CorpsTrainingSystem.GenRoleInfoData(v);
        CorpsTrainingSystem.TrainRoleInfo[tostring(v.uid)] = roleData;
    end

    EventSystem:postEvent(EVENTTYPE_CORPS,EVENTID_CORPS_TRAINING_ROLE_INFO);
end

function CorpsTrainingSystem.corps_training_award_res(res, task_id, reward_list)
    log("CorpsTrainingSystem.corps_training_award_res res="..tostring(res));
    if tonumber(res) == 0 then
        log("CorpsTrainingSystem.corps_training_award_res task_id="..tostring(task_id));
        --log_tree("CorpsTrainingSystem.corps_training_award_res reward_list=", reward_list);
        local arrItemData = {};
        for k, v in pairs(reward_list) do
            table.insert(arrItemData, {res_id = v.res_id, count = v.num});
        end

        if #arrItemData > 0 then
            CommonItemGetUI:ShowPanel(arrItemData);
        end

        if task_id == CorpsTrainingSystem.TodaySelfTaskID then
            CorpsTrainingSystem.TodaySelfStatus = 3;
        else
            for i, v in pairs(CorpsTrainingSystem.TodayCorpsTaskList) do
                if v.task_id == task_id then
                    v.status = 3;
                    break;
                end
            end
        end

        CorpsTrainingSystem.CheckRedPoint();

        EventSystem:postEvent(EVENTTYPE_CORPS,EVENTID_CORPS_TRAINING_STATUS);
    else
        ShowNotice(res);
    end
end

function CorpsTrainingSystem.sync_corps_trainning_red_point(status)
    log("CorpsTrainingSystem.sync_corps_trainning_red_point status="..tostring(status));
    CorpsTrainingSystem.TrainRedPointIsShow = (status == 1);
    CorpsOwnHomePageUI.UpdateTrainRedPoint();
    UpdateLobbyCorpsRedDot(CorpsMgr.HasRedDot("lobby"))
    CorpsBaseUI.UpdateRedPoint()
end

function CorpsTrainingSystem.CheckRedPoint()
    if CorpsTrainingSystem.TodaySelfStatus == 2 then
        return;
    end
    for i, v in pairs(CorpsTrainingSystem.TodayCorpsTaskList) do
        if v.status == 2 then
            return;
        end
    end
    CorpsTrainingSystem.TrainRedPointIsShow = false;
    CorpsOwnHomePageUI.UpdateTrainRedPoint();
    UpdateLobbyCorpsRedDot(CorpsMgr.HasRedDot("lobby"))
    CorpsBaseUI.UpdateRedPoint()
end

s2c["get_corps_training_res"] = CorpsTrainingSystem.get_corps_training_res;
s2c["corps_training_award_res"] = CorpsTrainingSystem.corps_training_award_res;
s2c["sync_corps_trainning_red_point"] = CorpsTrainingSystem.sync_corps_trainning_red_point;
