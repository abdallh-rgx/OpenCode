--军团特训UI
CorpsTrainingUI = CorpsTrainingUI or {
    isInited = false;
    isShow = false;
    isOnlyShow = true;
    selfRankNo = 0;
    selfRankScore = 0;
}

BP_Train_TodayID = 0;
BP_Train_SelfStatus = 1;
BP_Train_SelfTaskID = 0;
BP_Train_SelfTarget = 0;
BP_Train_SelfScore = 0;

BP_Train_CorpsScore = 0;
BP_Train_CorpsProgress = 0;

BP_Train_GetCorpsAwardIndex = 0;
BP_Train_isReLoadRankList = false;

BP_Train_SelectRankUid = "";
BP_Train_SelectIsFriend = false;

BP_STRUCT_CorpsTrainAwardItem = {
    res_id = 0,
    num = 0,
};

BP_ARRAY_CorpsTrainAward = {
    BP_STRUCT_CorpsTrainAwardItem = _G.BP_STRUCT_CorpsTrainAwardItem,
};

BP_STRUCT_CorpsTrainCorpsTask = {
    task_id = 0,
    target = 0,
    drop_id = 0,
    status = 1,
};

BP_ARRAY_CorpsTrainCorpsTask = {
    BP_STRUCT_CorpsTrainCorpsTask = _G.BP_STRUCT_CorpsTrainCorpsTask,
};


BP_STRUCT_CorpsTrainRankItem = {
    no = 0,
    uid = "",
    itemtype = 0,
	score = 0,
    name = "",              --名称
    url = "",               --头像
    level = 0,              --等级
    city = "",              --地点
    gender = 0,             --性别
    cur_avatar_box_id = 0,  --头像框
	startup_type = 0,--启动类型
	qq_vip = 0,--qq会员
};

BP_ARRAY_CorpsTrainRankList = {
    BP_STRUCT_CorpsTrainRankItem = _G.BP_STRUCT_CorpsTrainRankItem,
};

BP_STRUCT_CorpsTrainRankItemSelf = {
    BP_STRUCT_CorpsTrainRankItem = _G.BP_STRUCT_CorpsTrainRankItem,
};

local function CorpsTrainingEvent(eventType, eventID, vars)
    if eventID == EVENTID_CORPS_TRAINING_UPDATE_INFO then
        CorpsTrainingUI.UpdateUI();
    elseif eventID == EVENTID_CORPS_TRAINING_ROLE_INFO then
        CorpsTrainingUI.UpdateRankRoleInfo();
    elseif eventID == EVENTID_CORPS_TRAINING_STATUS then
        CorpsTrainingUI.UpdateTaskStatus();
    end
end

--注册Widget
function bp_corps_training_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_corps_training,
      {{Path="/Game/UMG/UI_Logic/Corps/CorpsTraining_BP.CorpsTraining_BP_C", Container="Default", ZOrder=BP_ENUM_UI_CORPS_ZORDER + 1}},
      {"Lobby"},
      false,
      bp_corps_training_OnModeSwitched ~= nil,
      true
    );
    
    BP_STRUCT_CorpsTrainRankItemSelf.BP_STRUCT_CorpsTrainRankItem = {};
end

local function JumpCorpTrain()
    CorpsTrainingSystem.OpenTrainingUI();
end

function bp_corps_training_OnModeSwitched(gamestatus)
    log("bp_corps_training_OnModeSwitched gamestatus = " .. gamestatus);
    if string.lower(gamestatus) == "lobby" then
        EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_CORPS_TRAINING, JumpCorpTrain);
        return;
	elseif string.lower(gamestatus) == "fighting" then
		CorpsTrainingUI.Release();
	elseif string.lower(gamestatus) == "login" then
        CorpsTrainingUI.Release();
        CorpsTrainingSystem.ResetData();
    end
    
    EventSystem:unregistEvent(EVENTTYPE_URL, BP_ENUM_MODULE_CORPS_TRAINING, JumpCorpTrain);
end


function CorpsTrainingUI.Init()
    if CorpsTrainingUI.isInited then
        return;
    end

    EventSystem:registEvent(EVENTTYPE_CORPS, EVENTID_CORPS_TRAINING_UPDATE_INFO,CorpsTrainingEvent);
    EventSystem:registEvent(EVENTTYPE_CORPS, EVENTID_CORPS_TRAINING_ROLE_INFO, CorpsTrainingEvent);
    EventSystem:registEvent(EVENTTYPE_CORPS, EVENTID_CORPS_TRAINING_STATUS, CorpsTrainingEvent);

    CorpsTrainingUI.isInited = true;
end

function CorpsTrainingUI.Release()
    if not CorpsTrainingUI.isInited then
        return;
    end

    EventSystem:unregistEvent(EVENTTYPE_CORPS, EVENTID_CORPS_TRAINING_UPDATE_INFO,CorpsTrainingEvent);
    EventSystem:unregistEvent(EVENTTYPE_CORPS, EVENTID_CORPS_TRAINING_ROLE_INFO, CorpsTrainingEvent);
    EventSystem:unregistEvent(EVENTTYPE_CORPS, EVENTID_CORPS_TRAINING_STATUS, CorpsTrainingEvent);

    CorpsTrainingUI.isShow = false;
    CorpsTrainingUI.isInited = false;
end

function CorpsTrainingUI.Show()
    log("CorpsTrainingUI Show");
    ClientSendBAReport(BP_BA_CORPS_TRAINING, 0);
    
    LuaClassObj.HandleDynamicCreation(bp_corps_training);
    
    CorpsTrainingUI.isShow = true;

    CorpsTrainingUI.Init();

    LuaClassObj.HandleUIMessage(bp_corps_training, "UIShow");
    UIManager.Show(eUIType.eCorpsTrainingUI)

    CorpsTrainingUI.ChangeIsOnlyShow(true)
end

function CorpsTrainingUI.Hide()
    log("CorpsTrainingUI Hide");
	CorpsTrainingUI.Release();
    UIManager.Hide(eUIType.eCorpsTrainingUI)
	LuaClassObj.HandleUIMessage(bp_corps_training, "UIHide");
end

function CorpsTrainingUI.UpdateUI()
    log("CorpsTrainingUI UpdateUI");
    if not CorpsTrainingUI.isShow then
        return;
    end

    BP_Train_TodayID = CorpsTrainingSystem.TodayTrainID;
    BP_Train_SelfTaskID = CorpsTrainingSystem.TodaySelfTaskID;
    BP_Train_SelfTarget = CorpsTrainingSystem.TodaySelfTotal;
    BP_Train_SelfStatus = CorpsTrainingSystem.TodaySelfStatus;
    BP_Train_SelfScore = CorpsTrainingSystem.TodaySelfScore;

    CorpsTrainingUI.UpdateSelfAwardData();

    CorpsTrainingUI.UpdateCorpsTrainTaskData();

    CorpsTrainingUI.UpdateRankData();
    
    LuaClassObj.HandleUIMessage(bp_corps_training, "UpdateUI");
end

function CorpsTrainingUI.UpdateCorpsTrainTaskData()
    BP_Train_CorpsScore = CorpsTrainingSystem.TodayCorpsScore;

    local corps_max_score = 0;
    BP_ARRAY_CorpsTrainCorpsTask = {};
    for i, v in ipairs(CorpsTrainingSystem.TodayCorpsTaskList) do
        local task = FuncUtil:CopyTable(BP_STRUCT_CorpsTrainCorpsTask);
        task.task_id = v.task_id;
        task.target = v.target;
        task.drop_id = v.drop_id;
        task.status = v.status;
        table.insert( BP_ARRAY_CorpsTrainCorpsTask, task );
        if v.target > corps_max_score then
            corps_max_score = v.target;
        end
    end
    --log_tree("CorpsTrainingUI.UpdateCorpsTrainTaskData list=", BP_ARRAY_CorpsTrainCorpsTask);

    BP_Train_CorpsProgress = (BP_Train_CorpsScore * 100) / corps_max_score;
    --log("CorpsTrainingUI.UpdateCorpsTrainTaskData BP_Train_CorpsProgress="..tostring(BP_Train_CorpsProgress));
end

function CorpsTrainingUI.UpdateSelfAwardData()
    BP_ARRAY_CorpsTrainAward = {};
    for i, v in ipairs(CorpsTrainingSystem.TodaySelfAwards) do
        local itm = FuncUtil:CopyTable(BP_STRUCT_CorpsTrainAwardItem);
        itm.res_id = v.res_id;
        itm.num = v.num;
        table.insert( BP_ARRAY_CorpsTrainAward, itm );
    end
    --log_tree("CorpsTrainingUI.UpdateSelfAwardData list=", BP_STRUCT_CorpsTrainAwardItem);
end

function CorpsTrainingUI.UpdateRankData()
    BP_ARRAY_CorpsTrainRankList = {};
    CorpsTrainingUI.selfRankNo = 0;
    CorpsTrainingUI.selfRankScore = 0;
    for i, v in ipairs(CorpsTrainingSystem.TodayRankList) do
        local itm = FuncUtil:CopyTable(BP_STRUCT_CorpsTrainRankItem);
        itm.no = i;
        itm.uid = tostring(v.uid);
        itm.score = v.score;
        if tostring(v.uid) == tostring(DataMgr.roleData.uid) then
            itm.itemtype = 1;
            CorpsTrainingUI.selfRankNo = i;
            CorpsTrainingUI.selfRankScore  = v.score;
        end
        CorpsTrainingUI.UpdateItemRoleInfo(itm, v.uid);
        table.insert(BP_ARRAY_CorpsTrainRankList, itm);
    end
    log_tree("CorpsTrainingUI.UpdateRankData list=", BP_ARRAY_CorpsTrainRankList);

    CorpsTrainingUI.UpdateSelfRankInfo();

    BP_Train_isReLoadRankList = true;
end

function CorpsTrainingUI.TestRankData()
    local st = #BP_ARRAY_CorpsTrainRankList + 1;
    for i=st, 10 do
        local tm = FuncUtil:CopyTable(BP_STRUCT_CorpsTrainRankItem);
        tm.no = i;
        tm.uid = "100000"..i;
        tm.score = 200 - i;
        tm.name = "测试数据"..i;
        table.insert( BP_ARRAY_CorpsTrainRankList, tm );
    end
end

function CorpsTrainingUI.UpdateSelfRankInfo()
    BP_STRUCT_CorpsTrainRankItemSelf.BP_STRUCT_CorpsTrainRankItem.no = CorpsTrainingUI.selfRankNo;
    BP_STRUCT_CorpsTrainRankItemSelf.BP_STRUCT_CorpsTrainRankItem.uid = tostring(DataMgr.roleData.uid);
    BP_STRUCT_CorpsTrainRankItemSelf.BP_STRUCT_CorpsTrainRankItem.itemtype = 2;
    BP_STRUCT_CorpsTrainRankItemSelf.BP_STRUCT_CorpsTrainRankItem.score = CorpsTrainingUI.selfRankScore;
    BP_STRUCT_CorpsTrainRankItemSelf.BP_STRUCT_CorpsTrainRankItem.name = DataMgr.roleData.nickName;
    BP_STRUCT_CorpsTrainRankItemSelf.BP_STRUCT_CorpsTrainRankItem.url =  DataMgr.roleData.headIconUrl;
    BP_STRUCT_CorpsTrainRankItemSelf.BP_STRUCT_CorpsTrainRankItem.level = DataMgr.roleData.level;
    BP_STRUCT_CorpsTrainRankItemSelf.BP_STRUCT_CorpsTrainRankItem.city = "";
    BP_STRUCT_CorpsTrainRankItemSelf.BP_STRUCT_CorpsTrainRankItem.gender = DataMgr.roleData.gender;
    BP_STRUCT_CorpsTrainRankItemSelf.BP_STRUCT_CorpsTrainRankItem.cur_avatar_box_id = DataMgr.roleData.cur_avatar_box_id;
    BP_STRUCT_CorpsTrainRankItemSelf.BP_STRUCT_CorpsTrainRankItem.startup_type = BP_StartUpType;
    BP_STRUCT_CorpsTrainRankItemSelf.BP_STRUCT_CorpsTrainRankItem.qq_vip = DataMgr.roleData.qq_vip;
end

function CorpsTrainingUI.UpdateItemRoleInfo(itm, uid)
    local roleInfo = CorpsTrainingSystem.GetTrainRoleInfo(uid);
    if nil == roleInfo then
        return;
    end

    itm.name = roleInfo.name;
    itm.url = roleInfo.url;
    itm.level = roleInfo.picUrl;
    itm.city = roleInfo.city;
    itm.gender = roleInfo.gender;
    itm.cur_avatar_box_id = roleInfo.cur_avatar_box_id;
    itm.startup_type = roleInfo.startup_type;
    itm.qq_vip = roleInfo.qq_vip;
end

function CorpsTrainingUI.UpdateRankRoleInfo()
    log("CorpsTrainingUI.UpdateRankRoleInfo");
    if not CorpsTrainingUI.isShow then
        return;
    end

    if #BP_ARRAY_CorpsTrainRankList == 0 then
        return;
    end

    for i, v in ipairs(BP_ARRAY_CorpsTrainRankList) do
        CorpsTrainingUI.UpdateItemRoleInfo(v, v.uid);
    end
    --log_tree("CorpsTrainingUI.UpdateRankRoleInfo list=",BP_ARRAY_CorpsTrainRankList);

    BP_Train_isReLoadRankList = false;

    LuaClassObj.HandleUIMessage(bp_corps_training, "UpdateTrainRank");
end

function CorpsTrainingUI.UpdateTaskStatus()
    log("CorpsTrainingUI.UpdateTaskStatus");
    BP_Train_SelfStatus = CorpsTrainingSystem.TodaySelfStatus;

    CorpsTrainingUI.UpdateCorpsTrainTaskData();

    LuaClassObj.HandleUIMessage(bp_corps_training, "UpdateTaskStatus");
end

function EventCorpsTrainingUIHide()
	CorpsTrainingUI.Release();
end

function EventCorpsTrainingUIUpdate()
    log("EventCorpsTrainingUIUpdate");
    CorpsTrainingUI.UpdateUI();
end

function EventCorpsTrainingUIOpenHisRank()
    CorpsTrainingRankUI.Show();
end

function EventCorpsTrainingUIItemMenu()
    BP_Train_SelectIsFriend = FriendSystem.IsMyFriend(BP_Train_SelectRankUid);
end

function EventCorpsTrainingUIShowRoleInfo()
    log("EventCorpsTrainingUIShowRoleInfo"..BP_Train_SelectRankUid);
    RoleInfoSystem.Enter(BP_Train_SelectRankUid);
    RoleInfoUI.Init(true, RoleInfoOpenFromType.CorpsTrainingUI);
end

function EventCorpsTrainingUIAddFriend()
    log("EventCorpsTrainingUIAddFriend"..BP_Train_SelectRankUid);
    FriendSystem.AddFriend(BP_Train_SelectRankUid, BP_ENUM_ADD_FRIEND_FROM_CORPS);
end

function EventCorpsTrainingUIChat()
    log("EventCorpsTrainingUIChat"..BP_Train_SelectRankUid);
    LobbyChatSystem.ChatWithFriend(BP_Train_SelectRankUid);
    CorpsTrainingUI.Hide();
    EventCorpsClose();
end

function EventCorpsTrainingUIHelp()
    log("function EventCorpsTrainingUIHelp()")
    local title = Client.GetTableData("LocalizeRes", 4933).TextValue
    local context = Client.GetTableData("LocalizeRes", 4934).TextValue
    PopUpNoticeUI.ShowMessageBox(title, context)
end

function EventCorpsTrainingUIGetSelfAward()
    log("EventCorpsTrainingUIGetSelfAward")
    if CorpsTrainingSystem.TodaySelfStatus == 1 then
        CorpsTrainingSystem.JumpToTodayTrain();
        CorpsTrainingUI.Hide();
        EventCorpsClose();
    elseif CorpsTrainingSystem.TodaySelfStatus == 2 then
        CorpsTrainingSystem.ReqCorpsTrainingAward(CorpsTrainingSystem.TodaySelfTaskID);
    end
end

function EventCorpsTrainingUIGetCorpsAward()
    log("EventCorpsTrainingUIGetCorpsAward 1");
    local corpsTaskInfo = BP_ARRAY_CorpsTrainCorpsTask[BP_Train_GetCorpsAwardIndex];
    if nil == corpsTaskInfo then
        return;
    end

    if corpsTaskInfo.status == 1 then
        CommonTreasureBoxPopup:showPanelByDropId(corpsTaskInfo.drop_id);
    elseif corpsTaskInfo.status == 2 then
        -- if CorpsTrainingSystem.TodaySelfStatus == 1 then
        --    CommonMessageBoxUI:ShowPanel(1, Client.GetTableData("LocalizeRes", "101001").TextValue, Client.GetTableData("LocalizeRes", "410063").TextValue);
        -- else
            CorpsTrainingSystem.ReqCorpsTrainingAward(corpsTaskInfo.task_id);
        --end
    end
end


function CorpsTrainingUI.ChangeIsOnlyShow(isOnlyShow)
    log("CorpsTrainingUI.ChangeIsOnlyShow:" .. tostring(isOnlyShow))
    CorpsTrainingUI.isOnlyShow = isOnlyShow
    if CorpsTrainingUI.isOnlyShow then
        LuaClassObj.HandleUIMessageNoFetch(bp_corps_training, "UIOnlyShow");
    else
        LuaClassObj.HandleUIMessageNoFetch(bp_corps_training, "UIOnlyHide");
    end
end

function CorpsTrainingUI.GetStatus()
    log("CorpsTrainingUI.GetStatus:" .. tostring(CorpsTrainingUI.isOnlyShow))
    return {isOnlyShow = CorpsTrainingUI.isOnlyShow}
end

function CorpsTrainingUI.RecoverStatus(status)
    if status and status.isOnlyShow ~= nil then
        log("CorpsTrainingUI.RecoverStatus:" .. tostring(status.isOnlyShow))
        CorpsTrainingUI.ChangeIsOnlyShow(status.isOnlyShow)
    end

end
