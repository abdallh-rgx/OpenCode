ActivityInviteTeamUI = ActivityInviteTeamUI or {}


BP_STRUCT_Activity_InviteTeam_Info =
{
    activityId = 0,
    award1Staus = 0,
    award2Staus = 0,
    inviteCount = 0,
}

BP_STRUCT_Activity_InviteTeam_BuyInfo =
{
    itemID2_1 = 0,
    itemID2_2 = 0,
    off_rate = 0,
    price = 0,
    origin_price = 0,
    libao = 1521017, --礼包
}



function bp_activity_invite_team_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_activity_invite_team,
                                {{Path="/Game/UMG/UI_Logic/EightDay/ActivityInviteTeam_Logic_BP.ActivityInviteTeam_Logic_BP_c", Container="Default", ZOrder=BP_ENUM_UI_ACTIVITYINVITETEAM_ZORDER}},
                                {"Lobby"},
                                false,
                                bp_activity_invite_team_OnModeSwitched ~= nil,
                                true);

end

function bp_activity_invite_team_OnModeSwitched(gameStatus)
    log("bp_activity_invite_team_OnModeSwitched gamestatus = " .. tostring(gameStatus));
    
    if string.lower(gameStatus) == "lobby" then
    else
        -- 离开大厅
        ActivityInviteTeamUI.HideUI()
    end
end

function ActivityInviteTeamUI.OnJumpUrl(eventType, eventID, vars)
    log("ActivityInviteTeamUI.OnJumpUrl");
    ActivityInviteTeamUI.ShowUI();
end

function ActivityInviteTeamUI.ShowUI()
    LuaClassObj.HandleDynamicCreation(bp_activity_invite_team);
    ActivityInviteTeamUI.RefreshData();

    if BP_STRUCT_Activity_InviteTeam_Info.activityId ~= nil then
        log("ActivityInviteTeamUI.ShowUI，activityId：" .. BP_STRUCT_Activity_InviteTeam_Info.activityId);

        ActivitySystem.Req_Activity_Market_Info(BP_STRUCT_Activity_InviteTeam_Info.activityId)
    end

    LuaClassObj.HandleUIMessage(bp_activity_invite_team, "UIShow");

    EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CHANGE, ActivityInviteTeamUI.RefreshUI) 
end

function ActivityInviteTeamUI.RefreshUI()
    ActivityInviteTeamUI.RefreshData();
    LuaClassObj.HandleUIMessageNoFetch(bp_activity_invite_team, "RefreshUI");
end

function ActivityInviteTeamUI.OnBindNotify(eventType, eventID, vars)
    log("[HHF]ActivityInviteTeamUI.OnBindNotify, eventID = " .. tostring(eventID) .. ", vars = " .. tostring(vars));
end

function ActivityInviteTeamUI.HideUI()
    LuaClassObj.HandleUIMessage(bp_activity_invite_team, "UIHide");

    EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CHANGE, ActivityInviteTeamUI.RefreshUI) 
end


function EventFetchInfo()
end



function ActivityInviteTeamUI.ClearData()--以防没有退出游戏，而只是退出账号，此时内存中这些数据是脏的

end

function ActivityInviteTeamUI.RefreshData()--更新活动的新数据，包括状态更新
    local bindType = ActivityType["INVITE_TEAM"];--绑定活动特定Type

    for _, activity in ipairs(DataMgr.activity.data) do

        if activity and activity.Type ~= nil and activity.Type == bindType then
            --log_tree("xzx bind activity : ", activity)
            BP_STRUCT_Activity_InviteTeam_Info.activityId = activity.ID;

            for k,v in ipairs(activity.List) do
                if v.Index == 1 then
                    BP_STRUCT_Activity_InviteTeam_Info.award1Staus = v.Status;                 
                end
                if v.Index == 2 then 
                    BP_STRUCT_Activity_InviteTeam_Info.award2Staus = v.Status;
                end                
            end

            if activity.other == nil or activity.other.invitees == nil then
                BP_STRUCT_Activity_InviteTeam_Info.inviteCount = 0 
            else
                BP_STRUCT_Activity_InviteTeam_Info.inviteCount = #activity.other.invitees
            end

            break;
        end
    end

     ActivityInviteTeamUI.HandleRedPoint()--处理红点
end

function ActivityInviteTeamUI.HandleRedPoint()
    if not LobbyUI.HasClickInviteTeamAct() then
        log("HasClickInviteTeamAct = false")
        LobbyUI:LobbyRedPointUpdate(BP_ENUM_MODULE_ACTIVITY_INVITE_TEAM, true);
    else
            --有物品可以领取
        local HasAward = BP_STRUCT_Activity_InviteTeam_Info.award1Staus == 1
        log("xzx ActivityInviteTeamUI.HandleRedPoint:" .. tostring(HasAward));
        LobbyUI:LobbyRedPointUpdate(BP_ENUM_MODULE_ACTIVITY_INVITE_TEAM, HasAward);
    end
end

function ActivityInviteTeamUI.activity_market_info_rsp(data)
    --log_tree("ActivityInviteTeamUI activity_market_info_rsp:", data);
    if data then
        BP_STRUCT_Activity_InviteTeam_BuyInfo.itemID2_1 = data.rewards.items[1]
        BP_STRUCT_Activity_InviteTeam_BuyInfo.itemID2_2 = data.rewards.items[2]
        BP_STRUCT_Activity_InviteTeam_BuyInfo.off_rate = data.rewards.off_rate
        BP_STRUCT_Activity_InviteTeam_BuyInfo.price = data.rewards.price
        BP_STRUCT_Activity_InviteTeam_BuyInfo.origin_price = data.rewards.origin_price
    end

    ActivityInviteTeamUI.RefreshUI()
end

function ActivityInviteTeamUI.GoToInviteTeam()
    --大厅邀请按钮的高亮显示，用在组队邀请活动中，需要高亮指引的地方
    --LuaClassObj.HandleUIMessageNoFetch(bp_teamup_friend, "OnMsg_Highlight_ButtonInvite")
     log("ActivityInviteTeamUI GoToInviteTeam");
    ClientSendBAReport(BP_BA_LOBBY_FRIEND_LIST_INVITE3, 0);
    ActivityInviteTeamUI.HideUI()
    InviteJoinTeamUI.ShowUI()
end

--领取第一个物品，走的活动领取协议，
function EventGainInviteTeamAward()
    log("ActivityInviteTeamUI EventGainInviteTeamAward:" .. BP_STRUCT_Activity_InviteTeam_Info.award1Staus);
    if BP_STRUCT_Activity_InviteTeam_Info.award1Staus == 0 then
    --      ActivityInviteTeamUI.GoToInviteTeam()
    --     --去邀请
        local strTile = Client.GetTableData("LocalizeRes",101001).TextValue;
        local btnOk = Client.GetTableData("LocalizeRes",110145).TextValue;
      
        local strMsg = Client.GetTableData("LocalizeRes",108154).TextValue;
      
        CommonMessageBoxUI:ShowPanel(2, strTile, strMsg, ActivityInviteTeamUI.GoToInviteTeam, nil, btnOk);
    elseif BP_STRUCT_Activity_InviteTeam_Info.award1Staus == 1 then
         ActivitySystem.Req_TakeActivityAward(BP_STRUCT_Activity_InviteTeam_Info.activityId, 1)
        --领取奖励
    end
end

--领取第一个物品，走的活动领取协议，
function EventGoToInviteTeam()
     log("ActivityInviteTeamUI EventGoToInviteTeam");
    ActivityInviteTeamUI.GoToInviteTeam()
end

--打开提示
function EventInviteTeamOpenTips()
    log("ActivityInviteTeamUI EventInviteTeamOpenTips");

    local title = FuncUtil.GetLocalizeResStr("6151");
    local content = FuncUtil.GetLocalizeResStr("6150");

    PopUpNoticeUI.ShowMessageBox(title, content);
end

--购买第二个物品，走的activity_buy_req,参数为活动id
function EventBuyInviteTeamItem()
     log("ActivityInviteTeamUI EventBuyInviteTeamItem:" .. BP_STRUCT_Activity_InviteTeam_Info.award2Staus);
    if BP_STRUCT_Activity_InviteTeam_Info.award2Staus == 0 then

        local strTile = Client.GetTableData("LocalizeRes",101001).TextValue;
        local btnOk = Client.GetTableData("LocalizeRes",110145).TextValue;
      
        local strMsg = Client.GetTableData("LocalizeRes",108153).TextValue;
      
        CommonMessageBoxUI:ShowPanel(2, strTile, strMsg, ActivityInviteTeamUI.GoToInviteTeam, nil, btnOk);
     
        --二级弹窗 领取
    elseif BP_STRUCT_Activity_InviteTeam_Info.award2Staus == 1 then
        local strBuy = FuncUtil.GetLocalizeResStr("301185");
        local tip = FuncUtil.GetLocalizeResStr("6154");
        CommonMessageBoxUI:ShowPanel(2, strBuy, tip, ActivityInviteTeamUI.BuyItem);

        -- local itemCfg1 = Client.GetTableData("Item", BP_STRUCT_Activity_InviteTeam_BuyInfo.itemID2_1);
        -- local itemCfg2 = Client.GetTableData("Item", BP_STRUCT_Activity_InviteTeam_BuyInfo.itemID2_2);
        -- local itemName = "";
        -- if itemCfg1 ~= nil and itemCfg2 ~= nil and itemCfg1.ItemName ~= nil and itemCfg2.ItemName ~= nil 
        --     and BP_STRUCT_Activity_InviteTeam_BuyInfo.price > 0 then 
        --     itemName = itemCfg1.ItemName
        --     itemName = itemName..","
        --     itemName = itemName..itemCfg2.ItemName;

        --     local tip = FuncUtil.GetLocalizeResStr("6154");
        --     --tip = string.format(tip, tostring(BP_STRUCT_Activity_InviteTeam_BuyInfo.price), itemName);
            
        -- end
    end
    
end

function ActivityInviteTeamUI.BuyItem()
    local actId = BP_STRUCT_Activity_InviteTeam_Info.activityId;
    if actId ~= nil and actId ~= 0 then
        MallSystem.HandleReqNum()
        NetUtil.SendPkg("activity_buy_req", actId)  
    end
end
