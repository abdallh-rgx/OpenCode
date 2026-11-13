--军团特训排行榜UI
CorpsTrainingRankUI = CorpsTrainingRankUI or {
    isInited = false;
    isShow = false;
    isOnlyShow = true;
    selfRankNo = 0;
    selfRankScore = 0;
}

BP_CorpsTrainRank_TabIndex = 0;
BP_CorpsTrainRank_TrainID = 0;

BP_CorpsTrainRank_IsReLoadList = false;

BP_CorpsTrainRank_SelectUid = "";
BP_CorpsTrainRank_SelectIsFriend = false;

BP_STRUCT_CorpsTrainRankTabInfo = {
    week_day = 0,
    train_id = 0,
    tab_name = "",
    isToday = false,
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

BP_ARRAY_CorpsTrainRankTabList = {
    BP_STRUCT_CorpsTrainRankTabInfo = _G.BP_STRUCT_CorpsTrainRankTabInfo,
}

BP_ARRAY_CorpsTrainRankItemList = {
    BP_STRUCT_CorpsTrainRankItem = _G.BP_STRUCT_CorpsTrainRankItem,
}

BP_STRUCT_CorpsTrainRankItemMe = {
    BP_STRUCT_CorpsTrainRankItem = _G.BP_STRUCT_CorpsTrainRankItem,
};

local strWeekDayID = 410047;
local strPreWeekDayID = 410048;
local arrWeekDay = {}; --"周一", "周二", "周三", "周四", "周五", "周六", "周日"
local arrPreWeekDay = {};--"上周一", "上周二", "上周三", "上周四", "上周五", "上周六", "上周日"

local function CorpsTrainingRankEvent(eventType, eventID, vars)
    if eventID == EVENTID_CORPS_TRAINING_UPDATE_INFO then
        CorpsTrainingRankUI.UpdateUI();
    elseif eventID == EVENTID_CORPS_TRAINING_ROLE_INFO then
        CorpsTrainingRankUI.UpdateRankRoleInfo();
    end
end

--注册Widget
function bp_corps_training_rank_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_corps_training_rank,
      {{Path="/Game/UMG/UI_Logic/Corps/CorpsTraining_Rank_BP.CorpsTraining_Rank_BP_C", Container="Default", ZOrder=BP_ENUM_UI_CORPS_ZORDER + 2}},
      {"Lobby"},
      false,
      bp_corps_training_rank_OnModeSwitched ~= nil,
      true
    );
    
    BP_STRUCT_CorpsTrainRankItemMe.BP_STRUCT_CorpsTrainRankItem = {};
end


function bp_corps_training_rank_OnModeSwitched(gamestatus)
	log("bp_corps_training_rank_OnModeSwitched gameStatus = " .. gamestatus);
    if string.lower(gamestatus) == "fighting" then
        CorpsTrainingRankUI.Release();
    elseif string.lower(gamestatus) == "login" then
        CorpsTrainingRankUI.Release();
	end
end

function CorpsTrainingRankUI.Init()
    if CorpsTrainingRankUI.isInited then
        return;
    end

    EventSystem:registEvent(EVENTTYPE_CORPS, EVENTID_CORPS_TRAINING_UPDATE_INFO,CorpsTrainingRankEvent);
    EventSystem:registEvent(EVENTTYPE_CORPS, EVENTID_CORPS_TRAINING_ROLE_INFO, CorpsTrainingRankEvent);

    CorpsTrainingRankUI.isInited = true;
end

function CorpsTrainingRankUI.Release()
    if not CorpsTrainingRankUI.isInited then
        return;
    end

    EventSystem:unregistEvent(EVENTTYPE_CORPS, EVENTID_CORPS_TRAINING_UPDATE_INFO,CorpsTrainingRankEvent);
    EventSystem:unregistEvent(EVENTTYPE_CORPS, EVENTID_CORPS_TRAINING_ROLE_INFO, CorpsTrainingRankEvent);

    CorpsTrainingRankUI.isShow = false;
    CorpsTrainingRankUI.isInited = false;
end

function CorpsTrainingRankUI.Show()
    log("CorpsTrainingRankUI Show");
    LuaClassObj.HandleDynamicCreation(bp_corps_training_rank);
    
    CorpsTrainingRankUI.isShow = true;

    CorpsTrainingRankUI.Init();

    local strWeekDay = Client.GetTableData("LocalizeRes", strWeekDayID);
    if strWeekDay ~= nil then
        arrWeekDay = string.split(strWeekDay.TextValue, "|");
    end

    local strPreWeekDay = Client.GetTableData("LocalizeRes", strPreWeekDayID);
    if strPreWeekDay ~= nil then
        arrPreWeekDay = string.split(strPreWeekDay.TextValue, "|");
    end

    BP_CorpsTrainRank_TabIndex = 0;

    LuaClassObj.HandleUIMessage(bp_corps_training_rank, "UIShow");
    UIManager.Show(eUIType.eCorpsTrainingRankUI)
    CorpsTrainingRankUI.ChangeIsOnlyShow(true)
end

function CorpsTrainingRankUI.Hide()
    log("CorpsTrainingRankUI Hide");
	CorpsTrainingRankUI.Release();
    UIManager.Hide(eUIType.eCorpsTrainingRankUI)
	LuaClassObj.HandleUIMessage(bp_corps_training_rank, "UIHide");
end

function CorpsTrainingRankUI.UpdateUI()
    if not CorpsTrainingRankUI.isShow then
        return;
    end

    local tabNum = CorpsTrainingRankUI.UpdateRankTabData();

    local curTabData = BP_ARRAY_CorpsTrainRankTabList[BP_CorpsTrainRank_TabIndex + 1];
    if nil == curTabData then
        sandbox.LogError("CorpsTrainingRankUI.UpdateUI not tab "..BP_CorpsTrainRank_TabIndex);
        return;
    end

    BP_CorpsTrainRank_TrainID = curTabData.train_id;

    local rankInfo = CorpsTrainingSystem.TrainHisRankInfo[curTabData.week_day];
    if nil == rankInfo then
        sandbox.LogError("CorpsTrainingRankUI.UpdateUI not rank info "..curTabData.week_day);
        return;
    end

    CorpsTrainingRankUI.selfRankNo = 0;
    CorpsTrainingRankUI.selfRankScore = 0;
    
    BP_ARRAY_CorpsTrainRankItemList = {};

    local uidList = {};
    local sortlist = {};
    for k, v in pairs(rankInfo.members) do
        if v > 0 then
            local st = {};
            st.uid = k;
            st.score = v;
            st.time = 0;
            if rankInfo.last_train_time ~= nil then
                st.time = GetSafeNumber(rankInfo.last_train_time[k]);
            end
            table.insert(sortlist, st);

            if CorpsTrainingSystem.IsNeedReqRoleInfo(k) then
                table.insert(uidList, k);
                CorpsTrainingSystem.RecordRoleInfoReq(k);
            end
        end
    end

    if #sortlist > 0 then
        table.sort(sortlist, function(a, b)
            return (a.score > b.score) or (a.score == b.score and a.time < b.time);
        end);

        for i, v in ipairs(sortlist) do
            local itm = FuncUtil:CopyTable(BP_STRUCT_CorpsTrainRankItem);
            itm.no = i;
            itm.uid = tostring(v.uid);
            itm.score = v.score;
            if tostring(v.uid) == tostring(DataMgr.roleData.uid) then
                itm.itemtype = 1;
                CorpsTrainingRankUI.selfRankNo = i;
                CorpsTrainingRankUI.selfRankScore = v.score;
            end
            CorpsTrainingRankUI.UpdateItemRoleInfo(itm, v.uid);
            table.insert(BP_ARRAY_CorpsTrainRankItemList, itm);
        end
    end

    CorpsTrainingRankUI.UpdateSelfRankInfo();

    BP_CorpsTrainRank_IsReLoadList = true;

    LuaClassObj.HandleUIMessage(bp_corps_training_rank, "UpdateUI");

    if #uidList > 0 then
        CorpsTrainingSystem.GetRankRoleProfile(uidList);
    end
end

function CorpsTrainingRankUI.TestRankData()
    local st = #BP_ARRAY_CorpsTrainRankItemList + 1;
    for i=st, 10 do
        local tm = FuncUtil:CopyTable(BP_STRUCT_CorpsTrainRankItem);
        tm.no = i;
        tm.uid = "100000"..i;
        tm.score = 200 - i;
        tm.name = "测试数据"..i;
        table.insert( BP_ARRAY_CorpsTrainRankItemList, tm );
    end
end

function CorpsTrainingRankUI.UpdateRankTabData()
    local curWeedDay = CorpsTrainingSystem.TodayWeekDay;

    BP_ARRAY_CorpsTrainRankTabList = {};
    for k, v in pairs(CorpsTrainingSystem.TrainHisRankInfo) do
        local tabData = FuncUtil:CopyTable(BP_STRUCT_CorpsTrainRankTabInfo);
        tabData.week_day = k;
        tabData.train_id = v.train_id;
        tabData.isToday = (k == curWeedDay);
        if k > curWeedDay then
            tabData.tab_name = arrPreWeekDay[k];
        else
            tabData.tab_name = arrWeekDay[k];
        end
        table.insert(BP_ARRAY_CorpsTrainRankTabList,  tabData);
    end

    local tabNum = #BP_ARRAY_CorpsTrainRankTabList;
    if tabNum > 1 then
        table.sort(BP_ARRAY_CorpsTrainRankTabList, function(a, b)
            if a.week_day == curWeedDay then
                return true;
            elseif a.week_day < curWeedDay and b.week_day > curWeedDay then
                return true;
            elseif (a.week_day < curWeedDay and b.week_day < curWeedDay) or (a.week_day > curWeedDay and b.week_day > curWeedDay) then
                return (a.week_day > b.week_day);
            else
                return false;
            end
        end);
    end

    --log_tree("CorpsTrainingRankUI.UpdateRankTabData list=", BP_ARRAY_CorpsTrainRankTabList);

    return tabNum;
end

function CorpsTrainingRankUI.UpdateSelfRankInfo()
    BP_STRUCT_CorpsTrainRankItemMe.BP_STRUCT_CorpsTrainRankItem.no = CorpsTrainingRankUI.selfRankNo;
    BP_STRUCT_CorpsTrainRankItemMe.BP_STRUCT_CorpsTrainRankItem.uid = tostring(DataMgr.roleData.uid);
    BP_STRUCT_CorpsTrainRankItemMe.BP_STRUCT_CorpsTrainRankItem.itemtype = 2;
    BP_STRUCT_CorpsTrainRankItemMe.BP_STRUCT_CorpsTrainRankItem.score = CorpsTrainingRankUI.selfRankScore;
    BP_STRUCT_CorpsTrainRankItemMe.BP_STRUCT_CorpsTrainRankItem.name = DataMgr.roleData.nickName;
    BP_STRUCT_CorpsTrainRankItemMe.BP_STRUCT_CorpsTrainRankItem.url =  DataMgr.roleData.headIconUrl;
    BP_STRUCT_CorpsTrainRankItemMe.BP_STRUCT_CorpsTrainRankItem.level = DataMgr.roleData.level;
    BP_STRUCT_CorpsTrainRankItemMe.BP_STRUCT_CorpsTrainRankItem.city = "";
    BP_STRUCT_CorpsTrainRankItemMe.BP_STRUCT_CorpsTrainRankItem.gender = DataMgr.roleData.gender;
    BP_STRUCT_CorpsTrainRankItemMe.BP_STRUCT_CorpsTrainRankItem.cur_avatar_box_id = DataMgr.roleData.cur_avatar_box_id;
    BP_STRUCT_CorpsTrainRankItemMe.BP_STRUCT_CorpsTrainRankItem.startup_type = BP_StartUpType;
    BP_STRUCT_CorpsTrainRankItemMe.BP_STRUCT_CorpsTrainRankItem.qq_vip = DataMgr.roleData.qq_vip;
end

function CorpsTrainingRankUI.UpdateItemRoleInfo(itm, uid)
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

function CorpsTrainingRankUI.UpdateRankRoleInfo()
    if not CorpsTrainingRankUI.isShow then
        return;
    end

    if #BP_ARRAY_CorpsTrainRankItemList == 0 then
        return;
    end

    for i, v in ipairs(BP_ARRAY_CorpsTrainRankItemList) do
        CorpsTrainingRankUI.UpdateItemRoleInfo(v, v.uid);
    end

    BP_CorpsTrainRank_IsReLoadList = false;

    LuaClassObj.HandleUIMessage(bp_corps_training_rank, "UpdateRankList");
end

function EventCorpsTrainingRankUIHide()
	CorpsTrainingRankUI.Release();
end

function EventCorpsTrainingRankUIUpdate()
    log("EventCorpsTrainingRankUIUpdate");
    CorpsTrainingRankUI.UpdateUI();
end

function EventCorpsTrainingRankUIItemMenu()
    BP_CorpsTrainRank_SelectIsFriend = FriendSystem.IsMyFriend(BP_CorpsTrainRank_SelectUid);
end

function EventCorpsTrainingRankUIShowRoleInfo()
    log("EventCorpsTrainingRankUIShowRoleInfo"..BP_CorpsTrainRank_SelectUid);
    RoleInfoSystem.Enter(BP_CorpsTrainRank_SelectUid);
    RoleInfoUI.Init(true, RoleInfoOpenFromType.CorpsTrainingRank);
end

function EventCorpsTrainingRankUIAddFriend()
    log("EventCorpsTrainingRankUIAddFriend"..BP_CorpsTrainRank_SelectUid);
    FriendSystem.AddFriend(BP_CorpsTrainRank_SelectUid, BP_ENUM_ADD_FRIEND_FROM_CORPS);
end

function EventCorpsTrainingRankUIChat()
    log("EventCorpsTrainingRankUIChat"..BP_CorpsTrainRank_SelectUid);
    LobbyChatSystem.ChatWithFriend(BP_CorpsTrainRank_SelectUid);
    CorpsTrainingRankUI.Hide();
    CorpsTrainingUI.Hide();
    EventCorpsClose();
end

function CorpsTrainingRankUI.ChangeIsOnlyShow(isOnlyShow)
    log("CorpsBaseUI.ChangeIsOnlyShow:" .. tostring(isOnlyShow))
    CorpsTrainingRankUI.isOnlyShow = isOnlyShow
    if CorpsTrainingRankUI.isOnlyShow then
        LuaClassObj.HandleUIMessageNoFetch(bp_corps_training_rank, "UIOnlyShow");
    else
        LuaClassObj.HandleUIMessageNoFetch(bp_corps_training_rank, "UIOnlyHide");
    end
end

function CorpsTrainingRankUI.GetStatus()
    log("CorpsBaseUI.GetStatus:" .. tostring(CorpsTrainingRankUI.isOnlyShow))
    return {isOnlyShow = CorpsTrainingRankUI.isOnlyShow}
end

function CorpsTrainingRankUI.RecoverStatus(status)
    if status and status.isOnlyShow ~= nil then
        log("CorpsTrainingRankUI.RecoverStatus:" .. tostring(status.isOnlyShow))
        CorpsTrainingRankUI.ChangeIsOnlyShow(status.isOnlyShow)
    end

end