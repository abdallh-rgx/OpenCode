BindFacebookUI = BindFacebookUI or
{
    IsUIShow = false,
    IsTimeUp = false,
    IsNoData = false, --false为初始状态,true表示无数据
}

BP_STRUCT_BindFacebook_Info =
{
    name = "",
    status = 0,
    itemName = "",
    itemImage = "",
    itemQuality = 0,
    itemID = 0,
}

-- 排序后的登录类型列表, 空就是没有
BP_ARRAY_BindTypeOrderList =
{
    "",
    "",
    "",
    "",
    "",
}

BP_Reward = 100;
BP_STRUCT_BetterAwardInfo = _G.BP_STRUCT_BindFacebook_Info;
BP_SELECTED_BIND_PLATFORM = "";

function bp_bind_facebook_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_bind_facebook,
                                {{Path="/Game/UMG/UI_Logic/EightDay/BindFacebook_Logic_BP.BindFacebook_Logic_BP_c", Container="Default", ZOrder=BP_ENUM_UI_BINDFB_ZORDER}},
                                {"Lobby"},
                                false,
                                bp_bind_facebook_OnModeSwitched ~= nil,
                                true);

    EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CHANGE, BindFacebookUI.RefreshUI) 
    EventSystem:registEvent(EVENTTYPE_LOGIN, EVENTID_BACKLOGIN, BindFacebookUI.ClearData);
end

function BindFacebookUI.OnJumpUrl(eventType, eventID, vars)
    BP_Reward = Client.GetTableData("SystemConfig", "AccountBindingAward").ConfigValue;
    log("[HHF]BindFacebookUI.OnJumpUrl, reward = " .. BP_Reward);
    BindFacebookUI.ShowUI();
end

function BindFacebookUI.ShowUI()
    BindFacebookUI.IsUIShow = true;
    LuaClassObj.HandleDynamicCreation(bp_bind_facebook);
    BindFacebookUI.RefreshBindData();
    LuaClassObj.HandleUIMessage(bp_bind_facebook, "UIShow");

    EventSystem:registEvent(EVENTTYPE_BIND_INTL, EVENTID_INTL_BIND_NOTIFY, BindFacebookUI.OnBindNotify);
end

function BindFacebookUI.RefreshUI()
    if not BindFacebookUI.IsUIShow then
        log("[HHF]BindFacebookUI.UpdateUI, IsUIShow == false!");
        return;
    end

    BindFacebookUI.RefreshBindData();
    LuaClassObj.HandleUIMessage(bp_bind_facebook, "UIShow");
end

function BindFacebookUI.UpdateUI()
    if not BindFacebookUI.IsUIShow then
        log("[HHF]BindFacebookUI.UpdateUI, IsUIShow == false!");
        return;
    end
    
    LuaClassObj.HandleUIMessage(bp_bind_facebook, "UpdateUI");
end

function BindFacebookUI.OnBindNotify(eventType, eventID, vars)
    log("[HHF]BindFacebookUI.OnBindNotify, eventID = " .. tostring(eventID) .. ", vars = " .. tostring(vars));
end

function BindFacebookUI.HideUI()
    BindFacebookUI.IsUIShow = false;
    EventSystem:unregistEvent(EVENTTYPE_BIND_INTL, EVENTID_INTL_BIND_NOTIFY, BindFacebookUI.OnBindNotify);
end

function EventBindFacebookUpdateUI()
    BindFacebookUI.UpdateUI();
end

function EventBindFacebookHideUI()
    BindFacebookUI.HideUI();
    LuaClassObj.HandleUIMessage(bp_bind_facebook, "Hide");
end

function EventFetchInfo()
end

function EventBindFacebook_Push()
    if BP_SELECTED_BIND_PLATFORM == "FB" then
        BP_BindChannel = BP_ENUM_IMSDK_CHANNEL_FACEBOOK;
    elseif BP_SELECTED_BIND_PLATFORM == "GC" then
        BP_BindChannel = BP_ENUM_IMSDK_CHANNEL_GAMECENTER;
    elseif BP_SELECTED_BIND_PLATFORM == "GP" then
        BP_BindChannel = BP_ENUM_IMSDK_CHANNEL_GOOGLEPLAY;
    elseif BP_SELECTED_BIND_PLATFORM == "WC" then
        BP_BindChannel = BP_ENUM_IMSDK_CHANNEL_WECHAT;
    elseif BP_SELECTED_BIND_PLATFORM == "VK" then
        BP_BindChannel = BP_ENUM_IMSDK_CHANNEL_VK;
    elseif BP_SELECTED_BIND_PLATFORM == "TW" then
        BP_BindChannel = BP_ENUM_IMSDK_CHANNEL_TWITTER;
    elseif BP_SELECTED_BIND_PLATFORM == "Line" then
        BP_BindChannel = BP_ENUM_IMSDK_CHANNEL_LINE;
    elseif BP_SELECTED_BIND_PLATFORM == "QQ" then
        BP_BindChannel = BP_ENUM_IMSDK_CHANNEL_QQ;
    end
    
end

BP_STRUCT_Bind_Gifts_Info = --绑定礼品及状态
{
    activityId = 0,--活动id
    subActId1 = 0, --第一个物品所属的子活动id
    subActIndex1 = 0, --第一个物品所属的子活动index

    itemID1 = 0, --第一个物品，用于领取
    itemID2_1 = 0, --
    itemID2_2 = 0, --

    status1 = 0, -- 0不可领取， 1 可领取，2已领取
    status2 = 0, -- 0原价可购买，折扣价不能买，1原价不可购买，折扣价可买， 2 折扣价已购买，原价可购买。
    
    off_rate = 0, --折扣，百分制
    price = 0, --现价
    origin_price = 0, --原价

    isLinked = false, --是否绑定账号
    actBeginTime = 0, --活动开始时间
    
    leftTime = 0, --活动倒计时时间(针对已绑定的用户，物品2的兑换倒计时)
}

function BindFacebookUI.ClearData()--以防没有退出游戏，而只是退出账号，此时内存中这些数据是脏的
    BP_STRUCT_Bind_Gifts_Info.activityId = 0
    BP_STRUCT_Bind_Gifts_Info.subActId1 = 0
    BP_STRUCT_Bind_Gifts_Info.subActIndex1 = 0
    BP_STRUCT_Bind_Gifts_Info.itemID1 = 0
    BP_STRUCT_Bind_Gifts_Info.itemID2_1 = 0
    BP_STRUCT_Bind_Gifts_Info.itemID2_2 = 0
    BP_STRUCT_Bind_Gifts_Info.status1 = 0
    BP_STRUCT_Bind_Gifts_Info.status2 = 0
    BP_STRUCT_Bind_Gifts_Info.off_rate = 0
    BP_STRUCT_Bind_Gifts_Info.price = 0
    BP_STRUCT_Bind_Gifts_Info.origin_price = 0
    BP_STRUCT_Bind_Gifts_Info.isLinked = false
    BP_STRUCT_Bind_Gifts_Info.actBeginTime = 0
    BP_STRUCT_Bind_Gifts_Info.leftTime = 0
    BindFacebookUI.IsUIShow = false
    BindFacebookUI.IsTimeUp = false;
    BindFacebookUI.IsNoData = false
end

function BindFacebookUI.IsShowDisplayActivity()
    if (BP_STRUCT_Bind_Gifts_Info.status1 == 2 and BP_STRUCT_Bind_Gifts_Info.status2 == 2) or BindFacebookUI.IsTimeUp 
        or BindFacebookUI.IsNoData == true then
        return false
    else
        return true
    end
end

function BindFacebookUI.get_account_link_info_rsp(data)
    log_tree("xzx link info:", data);
    if data then
        BP_STRUCT_Bind_Gifts_Info.itemID2_1 = data.rewards.items[1]
        BP_STRUCT_Bind_Gifts_Info.itemID2_2 = data.rewards.items[2]
        BP_STRUCT_Bind_Gifts_Info.off_rate = data.rewards.off_rate
        BP_STRUCT_Bind_Gifts_Info.price = data.rewards.price
        BP_STRUCT_Bind_Gifts_Info.origin_price = data.rewards.origin_price
    end
    --BP_STRUCT_Bind_Gifts_Info
    log_tree("xzx gifts info :", BP_STRUCT_Bind_Gifts_Info);
    if BindFacebookUI.IsUIShow == true then
        LuaClassObj.HandleUIMessage(bp_bind_facebook, "UIShow");
    end

    if BP_STRUCT_Bind_Gifts_Info.status1 == 2 and BP_STRUCT_Bind_Gifts_Info.status2 == 2 then
        LobbySystem.refresh_activity_display_byMidas();
    end
    --如果是已绑定玩家，需要更新大厅活动图片
    --[[if BP_STRUCT_Bind_Gifts_Info.status1 ~= 0 and BP_STRUCT_Bind_Gifts_Info.status2 ~= 0 and BP_STRUCT_Bind_Gifts_Info.itemID1 ~= 0 then
        local itemCfg = Client.GetTableData("Item", BP_STRUCT_Bind_Gifts_Info.itemID1);
        if itemCfg and itemCfg.ItemSmallIcon then
            LobbyUI:LobbyActIconUpdate(BP_ENUM_MODULE_BIND_FACEBOOK, itemCfg.ItemSmallIcon)
            log("xzx smallIcon = "..itemCfg.ItemSmallIcon)
        end
    end]]--
end

function BindFacebookUI.RefreshBindData()--更新活动的新数据，包括状态更新
    local bindType = ActivityType["BIND_SEND_GIFT"];--绑定活动特定Type

    for _, activity in ipairs(DataMgr.activity.data) do

        if activity and activity.Type ~= nil and activity.Type == bindType then
            --log_tree("xzx bind activity : ", activity)
            BP_STRUCT_Bind_Gifts_Info.activityId = activity.ID;
            BP_STRUCT_Bind_Gifts_Info.actBeginTime = activity.StartTime;

            for k,v in ipairs(activity.List) do
                if v.Index == 1 then
                    BP_STRUCT_Bind_Gifts_Info.status1 = v.Status;
                    BP_STRUCT_Bind_Gifts_Info.subActId1 = v.ID
                    BP_STRUCT_Bind_Gifts_Info.subActIndex1 = 1
                    BP_STRUCT_Bind_Gifts_Info.itemID1 = v.Drop[1].itemId;                    
                end

                if v.Index == 2 then 
                    BP_STRUCT_Bind_Gifts_Info.status2 = v.Status;
                    --BP_STRUCT_Bind_Gifts_Info.itemID2 = v.Drop[1].itemId
                end                
            end

            if activity.other == nil then
                BP_STRUCT_Bind_Gifts_Info.leftTime = -1 --leftTime = -1 表示活动长期有效
            else
                if activity.other.bind_activity_expire_time == nil then
                    BP_STRUCT_Bind_Gifts_Info.leftTime = -1
                else
                    BP_STRUCT_Bind_Gifts_Info.leftTime = activity.other.bind_activity_expire_time - FuncUtil.GetServerTimeInSec();
                end
            end

            break;
        end
    end

    if Client.GetLoginChannel(NetInterface) == BP_ENUM_PLAYFORM_TOURIST then
        BP_STRUCT_Bind_Gifts_Info.isLinked = false;
    else
        BP_STRUCT_Bind_Gifts_Info.isLinked = true;
    end

    if BP_STRUCT_Bind_Gifts_Info.itemID1 ~= 0 then
        BindFacebookUI.IsNoData = false

        --获取物品2数据
        if BP_STRUCT_Bind_Gifts_Info.activityId ~= nil and BP_STRUCT_Bind_Gifts_Info.activityId ~= 0 then
            --消息已经转义为activity_market_info_req
            --获取活动相关数据
            NetUtil.SendPkg("get_account_link_info_req", BP_STRUCT_Bind_Gifts_Info.activityId)  
        end
    else
        BindFacebookUI.IsNoData = true
        log("xzx RefreshBindData, itemID1 == 0")
        LobbySystem.refresh_activity_display_byMidas();
    end

    --log_tree("xzx RefreshBindData, gifts info :", BP_STRUCT_Bind_Gifts_Info);
end

function EventBindTimeIsUp()--倒计时停止，关闭页面，并去除activity display
    BindFacebookUI.IsTimeUp = true;
    EventBindFacebookHideUI();
    LobbySystem.refresh_activity_display_byMidas();
end

--领取第一个物品，走的活动领取协议，
function EventBindGetItem1()
    if BP_STRUCT_Bind_Gifts_Info.status1 == 0 then
        PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", "4792").TextValue);--todo
    elseif BP_STRUCT_Bind_Gifts_Info.status1 == 1 then
        if BP_STRUCT_Bind_Gifts_Info.subActId1 ~= nil and BP_STRUCT_Bind_Gifts_Info.subActId1 ~= 0 and
            BP_STRUCT_Bind_Gifts_Info.subActIndex1 ~= nil and BP_STRUCT_Bind_Gifts_Info.subActIndex1 ~= 0 then
            ActivitySystem.Req_TakeActivityAwardBatch(BP_STRUCT_Bind_Gifts_Info.subActId1, BP_STRUCT_Bind_Gifts_Info.subActIndex1, 1)
        end
    end
end

--购买第二个物品，走的activity_buy_req,参数为活动id
function EventBindBuyItem2()
    if BP_STRUCT_Bind_Gifts_Info.status2 == 0 then

        PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", "4794").TextValue);--todo

    elseif BP_STRUCT_Bind_Gifts_Info.status2 == 1 then
        local strBuy = FuncUtil.GetLocalizeResStr("301185");
        local itemCfg1 = Client.GetTableData("Item", BP_STRUCT_Bind_Gifts_Info.itemID2_1);
        local itemCfg2 = Client.GetTableData("Item", BP_STRUCT_Bind_Gifts_Info.itemID2_2);
        local itemName = "";
        if itemCfg1 ~= nil and itemCfg2 ~= nil and itemCfg1.ItemName ~= nil and itemCfg2.ItemName ~= nil 
            and BP_STRUCT_Bind_Gifts_Info.price > 0 then 
            itemName = itemCfg1.ItemName
            itemName = itemName..","
            itemName = itemName..itemCfg2.ItemName;

            local tip = FuncUtil.LocalizeResFormat("301372",tostring(BP_STRUCT_Bind_Gifts_Info.price),itemName);
            CommonMessageBoxUI:ShowPanel(2, strBuy, tip, BindFacebookUI.BuyItem2);
        end
    end
    
end

function BindFacebookUI.BuyItem2()
    local actId = BP_STRUCT_Bind_Gifts_Info.activityId;
    if actId ~= nil and actId ~= 0 then
        MallSystem.HandleReqNum()
        NetUtil.SendPkg("activity_buy_req", actId)  
    end
end

function BindFacebookUI.CheckRedPoint(timeNotBind, timeBind)
    local isShow = BindFacebookUI.HasRedPoint(timeNotBind, timeBind, BP_STRUCT_Bind_Gifts_Info.actBeginTime, BP_STRUCT_Bind_Gifts_Info.isLinked);
    if isShow == true then
        log("xzx red = true")
    else
        log("xzx red = false")
    end

    LobbyUI:LobbyRedPointUpdate(BP_ENUM_MODULE_BIND_FACEBOOK, isShow);
end

--actBeginTime活动上线时间
--isLinked是否为guest,是否绑定
function BindFacebookUI.HasRedPoint(timeNotBind, timeBind, actBeginTime, isLinked)
    if isLinked == false then--没有绑定
        if timeNotBind  < actBeginTime then
            return true;
        else
            return false;
        end
    else --已绑定，可能是新绑定，也可能是早已绑定的老玩家
        if timeBind < actBeginTime then
            return true;
        else
            return false;
        end
    end
end

--点击活动入口,考虑到该活动可能会上多次
function BindFacebookUI.ClickActEnterance(timeNotBind, timeBind)
    local curTime = FuncUtil.GetServerTimeInSec();
    local actBeginTime = BP_STRUCT_Bind_Gifts_Info.actBeginTime;
    local isLinked = BP_STRUCT_Bind_Gifts_Info.isLinked;

    log("xzx actBeginTime = "..actBeginTime..",timeNotBind = "..timeNotBind..", timeBind = "..timeBind..", curTime = "..curTime);

    local hasChange = false;

    if isLinked == false then
        if timeNotBind <  actBeginTime then
            timeNotBind = curTime;
            hasChange = true;
        end
    else --已经绑定
        if timeBind < actBeginTime then
            timeBind = curTime;
            hasChange = true;
        end
    end

    if hasChange == true then
        LobbyUI:SetBindActClickTime(timeNotBind, timeBind)
        LobbyUI:LobbyRedPointUpdate(BP_ENUM_MODULE_BIND_FACEBOOK, false);
    end
end

-- 获取登录类型配置
function EventGetBindTypeList()

    BP_ARRAY_BindTypeOrderList = FuncUtil.GetLoginTypeList(BP_ARRAY_BindTypeOrderList);
    
end

s2c = s2c or {};
s2c["get_account_link_info_rsp"] = BindFacebookUI.get_account_link_info_rsp