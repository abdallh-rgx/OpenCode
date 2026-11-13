-- 回流系统UI
ComeBackUI = ComeBackUI or
{
    IsShow = false,
}

-- 回流奖励结构
BP_STRUCT_ComeBack_AwardItemData =
{
    resID = 0,
    count = 0,
    time = 0,
}

-- 显示关闭按钮
BP_ComeBack_IsShowClose = false;

-- 显示类型
BP_ComeBack_PanelType = 0;

-- 玩家名字
BP_ComeBack_PlayerName = "";

-- 玩家离开的时间
BP_ComeBack_LeaveDayCount = 0;

-- 登陆奖励面板数据
BP_STRUCT_ComeBack_LoginGiftSubPanel =
{
    name = "",
    BP_ARRAY_Gifts = {BP_STRUCT_ComeBack_AwardItemData = _G.BP_STRUCT_ComeBack_AwardItemData}
}

-- 登陆奖励子面板数据列表
BP_ARRAY_ComeBack_LoginGiftSubPanelList = {BP_STRUCT_ComeBack_LoginGiftSubPanel = _G.BP_STRUCT_ComeBack_LoginGiftSubPanel}

-- 通知好友界面
BP_STRUCT_ComeBack_NotifyFriendData =
{
    uid = "",
    name = "",
    iconUrl = "",
    gender = 0,
    frameLevel = 0,
    playerLevel = 0,
}

-- 通知好友列表
BP_ARRAY_ComeBack_FriendList = {BP_STRUCT_ComeBack_NotifyFriendData = _G.BP_STRUCT_ComeBack_NotifyFriendData}

-- 通知好友已选好友列表
BP_ARRAY_ComeBack_FriendSelectd = {0}

-- 回流首战奖励
BP_ARRAY_ComeBack_FirstGameGiftList = {BP_STRUCT_ComeBack_AwardItemData = _G.BP_STRUCT_ComeBack_AwardItemData}

-- 任务奖励预览
BP_ARRAY_ComeBack_TaskAwardPreview = {BP_STRUCT_ComeBack_AwardItemData = _G.BP_STRUCT_ComeBack_AwardItemData}

function bp_come_back_OnModeSwitched(gamestatus)
    log("bp_come_back_OnModeSwitched  gamestatus = "..gamestatus);
    -- 回到登录场景清数据
    if string.lower(gamestatus) == "login" then
    elseif string.lower(gamestatus) == "lobby" then
        --回流系统
        ComeBackMgr.InitTaskTable()
        ComeBackSystem.ResetWindow()
    end
end

function bp_come_back_RegisterUI()
    -- log("bp_come_back_RegisterUI")
    LuaClassObj.SubUIWidgetList(bp_come_back,
    {{Path="/Game/UMG/UI_Logic/ComeBack/Lobby_ComeBack_BP.Lobby_ComeBack_BP_C", Container="Default", ZOrder=BP_ENUM_UI_COME_BACK_ZORDER}},
    {"Lobby"},
    false,
    bp_come_back_OnModeSwitched ~= nil,
    true);

    EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_COME_BACK, ComeBackSystem.CheckPopUI);
end

function ComeBackUI.ShowUI(panelType)
    log("ComeBackUI.ShowUI panelType:"..tostring(panelType).." IsCanShowUI:"..tostring(ComeBackSystem.IsCanShowUI()).." IsShow:"..tostring(ComeBackUI.IsShow));
    if not ComeBackSystem.IsCanShowUI() then
        log("ComeBackUI.ShowUI failed")
        return;
    end

    local bUIAutoTest = Client.IsUIAutoTest()
    if bUIAutoTest then
        return
    end

    if not ComeBackUI.IsShow then
        ComeBackSystem.ShowAfterFight = false;
        ComeBackUI.IsShow = true;
        -- log("ComeBackUI.ShowUI")
        ComeBackSystem.Init()
        LuaClassObj.HandleDynamicCreation(bp_come_back);
        LuaClassObj.HandleUIMessageNoFetch(bp_come_back, "ShowUI");
    end

    ComeBackSystem.ShowByType(panelType or 1)
end

function ComeBackUI.HideUI()
    log("ComeBackUI.HideUI")
    ComeBackUI.IsShow = false;
    BP_ComeBack_PanelType = ComeBackSystem.PanelType_Finished
    LuaClassObj.HandleUIMessageNoFetch(bp_come_back, "HideUI");
end

-- 点击关闭界面
function EventComeBackClickClose()
    ComeBackSystem.OnClickClose()
end

-- 点击接受礼物
function EventComeBackClickGetAward()
    log("EventComeBackClickGetAward")
    ComeBackSystem.ShowNext();
end

-- 点击获取回流礼物
function EventComeBackClickGetLoginGift()
    log("EventComeBackClickGetLoginGift")
    ComeBackSystem.OnClickGetLoginGift()
end

-- 点击通知好友
function EventComeBackClickNotifyFriends()
    log("EventComeBackClickNotifyFriends")
    ComeBackSystem.OnClickNotifyFriends();
end

-- 点击马上玩一把
function EventComeBackClickPlayNow()
    log("EventComeBackClickPlayNow")
    ComeBackSystem.OnClickPlayNow()
end

-- 点击去完成回流任务
function EventComeBackClickJumpToTask()
    log("EventComeBackClickJumpToTask")
    ComeBackSystem.OnClickJumpToTask();
end