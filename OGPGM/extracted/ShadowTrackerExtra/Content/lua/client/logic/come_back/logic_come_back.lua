ComeBackSystem = ComeBackSystem or
{
    PanelType_Start = 1,
    PanelType_LoginGift = 2,
    PanelType_NotifyMyFriends = 3,
    PanelType_FirstGameGift = 4,
    PanelType_JumpToTask = 5,
    PanelType_Finished = 5,

    UpdateFuncMap = {},
    LoginGiftTitleList = {430204, 430205, 430206},

    panelToTaskSubType = {},

    JumpToTaskPreviewID = 670004,

    FriendList = {},

    GetOpenIdMsg = "comebacknotify",

    JumpToTaskDataKey = "ComeBackJumpToTask_%s",

    CheckShowFunc = {},

    CacheFriendIDList = {},

    ShowAfterFight = false,
}

-- 映射面板刷新函数
function ComeBackSystem.Init()
    ComeBackSystem.panelToTaskSubType[ComeBackSystem.PanelType_LoginGift] = ComeBackMgr.TaskSubType_LoginGift
    ComeBackSystem.panelToTaskSubType[ComeBackSystem.PanelType_NotifyMyFriends] = ComeBackMgr.TaskSubType_NotifyMyFriends
    ComeBackSystem.panelToTaskSubType[ComeBackSystem.PanelType_FirstGameGift] = ComeBackMgr.TaskSubType_FirstGameGift

    -- 检测是否能弹出
    ComeBackSystem.CheckShowFunc[ComeBackSystem.PanelType_LoginGift] = ComeBackSystem.IsCanShowLoginGift
    ComeBackSystem.CheckShowFunc[ComeBackSystem.PanelType_NotifyMyFriends] = ComeBackSystem.IsCanShowFriendPanel
    ComeBackSystem.CheckShowFunc[ComeBackSystem.PanelType_FirstGameGift] = ComeBackSystem.IsCanShowFirstGame
    ComeBackSystem.CheckShowFunc[ComeBackSystem.PanelType_JumpToTask] = ComeBackSystem.IsCanShowJumpToTask

    ComeBackSystem.UpdateFuncMap = {}

    -- 准备数据
    ComeBackSystem.UpdateFuncMap[ComeBackSystem.PanelType_Start] = ComeBackSystem.UpdateStartPanel;
    ComeBackSystem.UpdateFuncMap[ComeBackSystem.PanelType_LoginGift] = ComeBackSystem.UpdateLoginGiftPanel;
    ComeBackSystem.UpdateFuncMap[ComeBackSystem.PanelType_NotifyMyFriends] = ComeBackSystem.UpdateNotifyMyFriendsPanel;
    ComeBackSystem.UpdateFuncMap[ComeBackSystem.PanelType_FirstGameGift] = ComeBackSystem.UpdateFirstGameGiftPanel;
    ComeBackSystem.UpdateFuncMap[ComeBackSystem.PanelType_JumpToTask] = ComeBackSystem.UpdateJumpToTaskPanel;
end

function ComeBackSystem.GetTaskInsBySubType(subType)
    local taskCfg = ComeBackMgr.GetFirstTaskBySubType(subType);
    if taskCfg == nil then
        return nil
    end

    return ComeBackMgr.GetTaskInsByTaskID(taskCfg.ID)
end

-- 根据当前的任务状态显示面板类型
function ComeBackSystem.GetFirstShowType()
    if ComeBackSystem.IsCanShowLoginGift() then
        log("ComeBackSystem.GetFirstShowType "..tostring(ComeBackSystem.PanelType_Start));
        return ComeBackSystem.PanelType_Start;
    end

    if ComeBackSystem.IsCanShowFriendPanel() then
        log("ComeBackSystem.GetFirstShowType "..tostring(ComeBackSystem.PanelType_NotifyMyFriends));
        return ComeBackSystem.PanelType_NotifyMyFriends;
    end

    if ComeBackSystem.IsCanShowFirstGame() then
        log("ComeBackSystem.GetFirstShowType "..tostring(ComeBackSystem.PanelType_FirstGameGift));
        return ComeBackSystem.PanelType_FirstGameGift;
    end

    if ComeBackSystem.IsCanShowJumpToTask() then
        log("ComeBackSystem.GetFirstShowType "..tostring(ComeBackSystem.PanelType_JumpToTask));
        return ComeBackSystem.PanelType_JumpToTask;
    end

    log("ComeBackSystem.GetFirstShowType 0");
    return 0
end

-- 根据当前的任务状态显示面板类型
function ComeBackSystem.ShowByTaskStatus()
    local showType = ComeBackSystem.GetFirstShowType()
    log("ComeBackSystem.ShowByTaskStatus showType "..tostring(showType))
    if showType == 0 then
        ComeBackSystem.ShowNextFinish()
    else
        ComeBackUI.ShowUI(showType);
    end
end

-- 是否可以登陆拍脸
function ComeBackSystem.IsCanSlap()
    if not ComeBackSystem.IsCanShowUI() then
        return false;
    end

    local panelType = ComeBackSystem.GetFirstShowType()
    if panelType == 0 then
        return false;
    end

    return true;
end

-- 是否可以显示UI
function ComeBackSystem.IsCanShowUI()
    if not DataMgr.RejoinTaskData.is_open then
        return false;
    end

    return true;
end

-- 是否可以战斗后拍脸
function ComeBackSystem.IsCanAfterFightingSlap()
    if not ComeBackSystem.IsCanShowUI() then
        return false;
    end

    return ComeBackSystem.IsCanShowJumpToTask();
end

-- 是否已经显示结束
function ComeBackSystem.IsShowFinished()
    return BP_ComeBack_PanelType >= ComeBackSystem.PanelType_Finished;
end

-- 显示下一个类型
function ComeBackSystem.ShowNext()
    if not ComeBackUI.IsShow then
        ComeBackUI.IsShow = false;
    end

    if not ComeBackSystem.IsShowFinished() then
        local showIndex = 0;
        for i=BP_ComeBack_PanelType + 1,ComeBackSystem.PanelType_Finished do
            local checkFunc = ComeBackSystem.CheckShowFunc[i]
            local check = checkFunc == nil or checkFunc()
            if check and ComeBackSystem.ShowByType(i) then
                showIndex = i;
                break;
            end
        end

        if showIndex == 0 then
            ComeBackSystem.ShowNextFinish()
        end
    else
        ComeBackSystem.ShowNextFinish()
    end
end

-- 下个显示结束
function ComeBackSystem.ShowNextFinish()
    log("ComeBackSystem.ShowNextFinish");
    ComeBackUI.HideUI()
    -- FaceSlapSystem.OnStepFinished(FaceSlapSystem.Step_ComeBack);
    AfterFightingSlapSystem.OnStepFinished(AfterFightingSlapSystem.Step_ComeBack)
    FaceSlapSystem.ShowNext(BP_ENUM_MODULE_COME_BACK);
end

-- 通过类型显示
function ComeBackSystem.ShowByType(type)
    -- log("ComeBackSystem.ShowByType")
    log("ComeBackSystem.ShowByType type "..tostring(type))
    BP_ComeBack_PanelType = type;

    BP_ComeBack_IsShowClose = true;
    local updateFunc = ComeBackSystem.UpdateFuncMap[BP_ComeBack_PanelType]
    local isSuccessed = true;
    if updateFunc then
        isSuccessed = updateFunc()
    end

    if isSuccessed then
        LuaClassObj.HandleUIMessageNoFetch(bp_come_back, "UpdateByType");
    end
    return isSuccessed;
end

-- 更新开始面板
function ComeBackSystem.UpdateStartPanel()
    BP_ComeBack_IsShowClose = false;

    BP_ComeBack_PlayerName = DataMgr.roleData.nickName or "";

    -- 离开天数
    -- BP_ComeBack_LeaveDayCount = 0;

    return true;
end

function ComeBackSystem.GetTaskDropList(taskSubType)
    local taskCfg = ComeBackMgr.GetFirstTaskBySubType(taskSubType)
    if not taskCfg then
        -- log("ComeBackSystem.GetTaskDropList 2")
        return nil;
    end

    -- log("dropID "..tostring(taskCfg.previewDropID));
    local drop_util = require("client.common.drop_util")
    return drop_util.GetDropList(taskCfg.previewDropID)
end

-- 更新回归礼物界面
function ComeBackSystem.UpdateLoginGiftPanel()
    BP_ComeBack_IsShowClose = false
    local dropList = ComeBackSystem.GetTaskDropList(ComeBackMgr.TaskSubType_LoginGift)

    if not dropList or #dropList < 6 then
        -- log_tree("ComeBackSystem.UpdateLoginGiftPanel dropList", dropList)
        sandbox.LogError("ComeBackSystem.UpdateLoginGiftPanel #dropList < 6");
        return false
    end

    BP_ARRAY_ComeBack_LoginGiftSubPanelList = {}
    for i=1,3 do
        local info = {}
        info.name = FuncUtil.GetLocalizeResStr(ComeBackSystem.LoginGiftTitleList[i])
        info.BP_ARRAY_Gifts = {}
        table.insert(info.BP_ARRAY_Gifts,  ComeBackSystem.GetAwardItemData(dropList[i*2-1]))
        table.insert(info.BP_ARRAY_Gifts,  ComeBackSystem.GetAwardItemData(dropList[i*2]))

        table.insert(BP_ARRAY_ComeBack_LoginGiftSubPanelList, info)
    end
    -- log_tree("ComeBackSystem.UpdateLoginGiftPanel BP_ARRAY_ComeBack_LoginGiftSubPanelList", BP_ARRAY_ComeBack_LoginGiftSubPanelList);

    return true;
end

-- 掉落信息转成界面信息
function ComeBackSystem.GetAwardItemData(dropInfo)
    if not dropInfo then
        return nil
    end

    local result = {}
    result.resID = dropInfo.DropItemID
    result.count = dropInfo.DropItemNum
    result.time = dropInfo.Hours

    return result
end

-- 更新通知好友界面(不用)
function ComeBackSystem.UpdateNotifyMyFriendsPanel()
    ComeBackSystem.FriendList = {}
    BP_ARRAY_ComeBack_FriendList = {}
    -- log_tree("ComeBackSystem.UpdateNotifyMyFriendsPanel ComeBackSystem.CacheFriendIDList", ComeBackSystem.CacheFriendIDList)
    ProfileMgr.GetFriendProfileList(ComeBackSystem.CacheFriendIDList, ComeBackSystem.GetFriendInfo, false, false);
    return true;
end

local function ComeBackFriendSort(a, b)
    return a.lastOnlineTime > b.lastOnlineTime
end

-- (不用)
function ComeBackSystem.GetFriendInfo(profile_list)
    local tempList = {}
    for k,v in pairs(profile_list) do
        table.insert(tempList, v)
    end

    -- log_tree("ComeBackSystem.GetFriendInfo profile_list", profile_list)

    table.sort(tempList, ComeBackFriendSort)
    local count = math.min(#tempList, 5)

    for i=1,count do
        local profile = tempList[i]
        if profile then
            table.insert(ComeBackSystem.FriendList,
            {
                uid = tostring(profile.uid),
                name = profile.nickName,
                iconUrl = profile.picUrl,
                gender = profile.sex,
                frameLevel = profile.cur_avatar_box_id,
                playerLevel = profile.level or 0,
            })
        end
    end

    BP_ARRAY_ComeBack_FriendList = ComeBackSystem.FriendList;
    -- log_tree("ComeBackSystem.GetFriendInfo BP_ARRAY_ComeBack_FriendList", BP_ARRAY_ComeBack_FriendList)
    LuaClassObj.HandleUIMessageNoFetch(bp_come_back, "UpdateNotifyMyFriendsPanel")
end

-- 更新首次战斗界面
function ComeBackSystem.UpdateFirstGameGiftPanel()
    local dropList = ComeBackSystem.GetTaskDropList(ComeBackMgr.TaskSubType_FirstGameGift)
    local count = 0
    if dropList then
        count = math.min(#dropList, 3)
    end

    BP_ARRAY_ComeBack_FirstGameGiftList = {}
    for i=1,count do
        table.insert(BP_ARRAY_ComeBack_FirstGameGiftList, ComeBackSystem.GetAwardItemData(dropList[i]))
    end

    -- log_tree("ComeBackSystem.UpdateFirstGameGiftPanel BP_ARRAY_ComeBack_FirstGameGiftList", BP_ARRAY_ComeBack_FirstGameGiftList)
    -- log_tree("ComeBackSystem.UpdateFirstGameGiftPanel dropList", dropList)

    return true;
end

-- 更新前往任务窗口
function ComeBackSystem.UpdateJumpToTaskPanel()
    local drop_util = require("client.common.drop_util")
    local dropList = drop_util.GetDropList(ComeBackSystem.JumpToTaskPreviewID)
    local count = 0
    if dropList then
        count = math.min(#dropList, 6)
    end

    BP_ARRAY_ComeBack_TaskAwardPreview = {}

    for i=1,count do
        table.insert(BP_ARRAY_ComeBack_TaskAwardPreview, ComeBackSystem.GetAwardItemData(dropList[i]))
    end

    return true;
end

-- 点击通知好友(不用)
function ComeBackSystem.OnClickNotifyFriends()
    if #BP_ARRAY_ComeBack_FriendSelectd == 0 then
        ShowNotice(430203)
    else
        local title = FuncUtil.GetLocalizeResStr(101001)
        local platformStr = ""
        if BP_Platform == BP_ENUM_PLAYFORM_WX then
            platformStr = FuncUtil.GetLocalizeResStr(101012)
        elseif BP_Platform == BP_ENUM_PLAYFORM_QQ then
            platformStr = FuncUtil.GetLocalizeResStr(301288)
        end

        local okStr = FuncUtil.GetLocalizeResStr(102027)
        local cancelStr = FuncUtil.GetLocalizeResStr(102026)

        local content = FuncUtil.LocalizeResFormat(430202, platformStr)
        CommonMessageBoxUI.ShowPlatformPanel(2, title, content, ComeBackSystem.OnClickNotifyFriendsOK, nil, okStr, cancelStr);
    end
end

-- (不用)
function ComeBackSystem.OnClickNotifyFriendsOK()
    -- log_tree("ComeBackSystem.OnClickNotifyFriendsOK BP_ARRAY_ComeBack_FriendSelectd", BP_ARRAY_ComeBack_FriendSelectd)
    local taskCfg = ComeBackMgr.GetFirstTaskBySubType(ComeBackMgr.TaskSubType_NotifyMyFriends)
    if taskCfg then
        ComeBackMgr.rejoin_task_get_award_req(taskCfg.ID)
    end

    -- 发送结构化消息
    for i,v in ipairs(BP_ARRAY_ComeBack_FriendSelectd) do
        local frienData = BP_ARRAY_ComeBack_FriendList[v+1]
        if frienData ~= nil then
            FriendSystem.get_openid_by_gid_req(tonumber(frienData.uid), ComeBackSystem.GetOpenIdMsg)
        end
    end
end

function ComeBackSystem.SendGetAward(taskSubType)
    local taskCfg = ComeBackMgr.GetFirstTaskBySubType(taskSubType)
    if taskCfg then
        ComeBackMgr.rejoin_task_get_award_req(taskCfg.ID)
    end
end

-- (不用)
function ComeBackSystem.OnOpenIDRes(userOpenID, gid)
    -- log("ComeBackSystem.OnOpenIDRes gid "..tostring(gid))
    local params = {openid = userOpenID, title = FuncUtil.GetLocalizeResStr(430207) ,desc = FuncUtil.GetLocalizeResStr(430208)}

    if gid ~= nil then
        local extendInfo = {};
        extendInfo.come_back_invite_info = {target = gid};
        params.extendInfo = FuncUtil:EncodeURI(json.encode(extendInfo));
    end

    -- log_tree("ComeBackSystem.OnOpenIDRes params", params)
    ShareMgr:shareToFriend(params);
end

-- 点击前往任务
function ComeBackSystem.OnClickJumpToTask()
    AfterFightingSlapSystem.EndShow();
    -- FaceSlapSystem.StopShow()
    ComeBackUI.HideUI()

    GlobalData:JumpUrl("game://?module=1000800&id=3")
    ComeBackSystem.MarkShowJumpTask()
end

-- 强制结束
function ComeBackSystem.ForceFinishd()
    BP_ComeBack_PanelType = ComeBackSystem.PanelType_Finished
    ComeBackUI.HideUI();
end

-- 任务结束事件
function ComeBackSystem.OnTaskFinished(taskCfg)
    local curPanelToSubType = ComeBackSystem.panelToTaskSubType[BP_ComeBack_PanelType]
    -- log("ComeBackSystem.OnTaskFinished curPanelToSubType "..tostring(curPanelToSubType))
    -- log("ComeBackSystem.OnTaskFinished BP_ComeBack_PanelType "..tostring(BP_ComeBack_PanelType))
    -- log_tree("ComeBackSystem.OnTaskFinished taskCfg", taskCfg)
    if curPanelToSubType == taskCfg.SubType then
        ComeBackSystem.ShowByTaskStatus();
    end
end

-- 点击获取回流任务奖励
function ComeBackSystem.OnClickGetLoginGift()
    local taskCfg = ComeBackMgr.GetFirstTaskBySubType(ComeBackMgr.TaskSubType_LoginGift)
    -- log_tree("ComeBackSystem.OnClickGetLoginGift taskCfg ", taskCfg)
    if taskCfg then
        ComeBackMgr.rejoin_task_get_award_req(taskCfg.ID)
    end
end

-- 点击关闭
function ComeBackSystem.OnClickClose()
    log("ComeBackSystem.OnClickClose")

    if BP_ComeBack_PanelType == ComeBackSystem.PanelType_NotifyMyFriends then
        ComeBackSystem.SendGetAward(ComeBackMgr.TaskSubType_NotifyMyFriends)
    elseif BP_ComeBack_PanelType == ComeBackSystem.PanelType_FirstGameGift then        
        ComeBackUI.HideUI();
        FaceSlapSystem.ShowNext(BP_ENUM_MODULE_COME_BACK);
        return;
    elseif BP_ComeBack_PanelType == ComeBackSystem.PanelType_JumpToTask then
        -- 记录状态
        ComeBackSystem.MarkShowJumpTask()
    end

    ComeBackSystem.ShowNext();
end

-- 是否能显示回流礼包
function ComeBackSystem.IsCanShowLoginGift()
    if not LobbySystem.IsLabelSwitchOpen(BP_ENUM_COME_BACK_LOGIN_AWARD) then
        log("ComeBackSystem.IsCanShowLoginGift switch off")
        return false;
    end

    local taskIns = ComeBackSystem.GetTaskInsBySubType(ComeBackMgr.TaskSubType_LoginGift);
    if taskIns == nil then
        log("ComeBackSystem.IsCanShowLoginGift no taskData")
        return false
    end

    if taskIns.status == 2 then
        log("ComeBackSystem.IsCanShowLoginGift has got")
        return false
    end

    return true;
end

-- 是否可显示通知好友(不用)
function ComeBackSystem.IsCanShowFriendPanel()
    return false;   --海外版不要

    -- if not LobbySystem.IsLabelSwitchOpen(BP_ENUM_COME_BACK_NOTIFY_FRIENDS) then
    --     log("ComeBackSystem.IsCanShowFriendPanel switch off")
    --     return false;
    -- end

    -- if BP_Platform == BP_ENUM_PLAYFORM_TOURIST then
    --     log("ComeBackSystem.IsCanShowFriendPanel 1")
    --     return false
    -- end

    -- -- 获取好友列表
    -- ComeBackSystem.CacheFriendIDList = {}
    -- for k,v in pairs(ID_PLAT_FRIENDLIST) do
    --     local friendInfo = ProfileMgr.GetFriendProfileByUid(v)
    --     if friendInfo ~= nil then
    --         table.insert(ComeBackSystem.CacheFriendIDList, tonumber(friendInfo.uid))
    --     end
    -- end

    -- if #ComeBackSystem.CacheFriendIDList == 0 then
    --     log("ComeBackSystem.IsCanShowFriendPanel 2")
    --     return false
    -- end

    -- local taskIns = ComeBackSystem.GetTaskInsBySubType(ComeBackMgr.TaskSubType_NotifyMyFriends);
    -- if taskIns == nil then
    --     log("ComeBackSystem.IsCanShowFriendPanel no taskData")
    --     return false
    -- end

    -- if taskIns.status == 2 then
    --     log("ComeBackSystem.IsCanShowFriendPanel has got")
    --     return false
    -- end

    -- log("ComeBackSystem.IsCanShowFriendPanel true")
    -- return true;
end

-- 是否显示首战奖励
function ComeBackSystem.IsCanShowFirstGame()
    if not LobbySystem.IsLabelSwitchOpen(BP_ENUM_COME_BACK_FIRST_GAME) then
        log("ComeBackSystem.IsCanShowFirstGame switch off")
        return false
    end

    local taskIns = ComeBackSystem.GetTaskInsBySubType(ComeBackMgr.TaskSubType_FirstGameGift);
    if taskIns == nil then
        log("ComeBackSystem.IsCanShowFirstGame no taskData")
        return false
    end

    if taskIns.status == 2 then
        log("ComeBackSystem.IsCanShowFirstGame has got")
        return false
    end

    return true;
end

-- 获取是否能显示跳转任务
function ComeBackSystem.IsCanShowJumpToTask()
    if not LobbySystem.IsLabelSwitchOpen(BP_ENUM_COME_BACK_TASK) then
        log("ComeBackSystem.IsCanShowJumpToTask switch off")
        return false
    end

    local key = string.format(ComeBackSystem.JumpToTaskDataKey, DataMgr.roleData.uid)
     log("ComeBackSystem.IsCanShowJumpToTask key "..key)
    local value = GlobalData.GetGlobalConfigIntValue(key)
     log("ComeBackSystem.IsCanShowJumpToTask value "..value)
     log("DataMgr.RejoinTaskData.rejoin_start_time  ".. tostring(DataMgr.RejoinTaskData.rejoin_start_time))
    return value ~= DataMgr.RejoinTaskData.rejoin_start_time
end

-- 记录当前跳转任务显示状态
function ComeBackSystem.MarkShowJumpTask()

    -- 记录状态
    local key = string.format(ComeBackSystem.JumpToTaskDataKey, DataMgr.roleData.uid)
    GlobalData.SetGlobalConfigIntValue(key, DataMgr.RejoinTaskData.rejoin_start_time)
end

-- 点击马上打一把
function ComeBackSystem.OnClickPlayNow()
    MatchPopupUI.ShowWeakGuideImmediately()
    -- LobbySystem.ClearAllPopUI()
    ComeBackUI.HideUI()
    FaceSlapSystem.UninterruptableFinallyShow();
end

-- 重置窗口状态
function ComeBackSystem.ResetWindow()
    ComeBackUI.IsShow = false;
end

-- 获取“登录时检测是否要弹”的回调
function ComeBackSystem.GetCheckComebackPopUICallback()
end

-- 登录时检测是否要弹
function ComeBackSystem.CheckPopUI()
    log("ComeBackSystem.CheckPopUI  isOpen:"..tostring(DataMgr.RejoinTaskData.is_open));
    if DataMgr.RejoinTaskData.is_open then
        ComeBackSystem.Init();
        ComeBackSystem.UpdateFuncMap[ComeBackSystem.PanelType_Start]();
        ComeBackSystem.ShowByTaskStatus();
    end
end

-- 登录时是否需要弹出
function ComeBackSystem.ShouldSlap()
    -- 审核期间不弹
    log("come back "..tostring(LobbySystem.CheckOpen(BP_ENUM_EXAMINE_UI_COME_BACK)))
    if not LobbySystem.CheckOpen(BP_ENUM_EXAMINE_UI_COME_BACK) then
        return false;
    end

    if not DataMgr.RejoinTaskData.is_open then
        log("DataMgr.RejoinTaskData.is_open " .. tostring(DataMgr.RejoinTaskData.is_open))
        return false;
    end

    return true;
    -- return hasSignIn;
end

-- 战斗后弹出
function ComeBackSystem.PopAfterFight()
    if ComeBackSystem.ShowAfterFight == true and ComeBackSystem.ShouldSlap() then
        local showType = ComeBackSystem.GetFirstShowType();
        if showType == ComeBackSystem.PanelType_JumpToTask then
            ComeBackUI.ShowUI(showType);
        end
    end
end