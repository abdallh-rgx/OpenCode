BuyUPassActUI = BuyUPassActUI or
{
    IsUIShow = false,
}

BP_STRUCT_Buy_UPass_Act_Item_Info = 
{
    index = 0,--因为奖励的id可能会相同，所以用index来区分
    id = 0,
    count = 0,
    status = 0, --0不能领取,1可领取但还未领取,2已领取
    stepNum = 0, --要领取该礼包需要达到的人数
}
--新增pass购买的运营活动
BP_STRUCT_Buy_UPass_Act_Info = --pass购买活动info
{
    actTime = "", --活动时间

    actId = 0, --活动id

    isBuy = false,--是否购买通行证
    curBuy = 0, --目前购买人数
    allBuy = 0, --目标购买人数(进度条的最大值)

    BP_ARRAY_Buy_UPass_Act_Item_Infos = {
        BP_STRUCT_Buy_UPass_Act_Item_Info = BP_STRUCT_Buy_UPass_Act_Item_Info
    },
}

BP_Cur_HandleBuyUPassItemIndex = 0 --目前处理的礼包index,因为id可能会是一样的

function bp_buy_upass_act_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_buy_upass_act,
                                {{Path="/Game/UMG/UI_Logic/EightDay/BuyUPassAct_BP.BuyUPassAct_BP_C", Container="Default", ZOrder=BP_ENUM_UI_BINDFB_ZORDER - 1}},
                                {"Lobby"},
                                false,
                                bp_buy_upass_act_OnModeSwitched ~= nil,
                                true);

    --EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CHANGE, BuyUPassActUI.RefreshUI) 
    EventSystem:registEvent(EVENTTYPE_LOGIN, EVENTID_BACKLOGIN, BuyUPassActUI.ClearData);
end

function BuyUPassActUI.OnJumpUrl(eventType, eventID, vars)--需要在bp_lobby.lua里面注册与解除注册
    BuyUPassActUI.ShowUI();
end

function BuyUPassActUI.ShowUI()
    BuyUPassActUI.RefreshBuyData();
    log("xzx BuyUPassAct, actId = "..BP_STRUCT_Buy_UPass_Act_Info.actId)
    if BP_STRUCT_Buy_UPass_Act_Info.actId ~= 0 then
        ActivitySystem.Req_AcitvityOneData(BP_STRUCT_Buy_UPass_Act_Info.actId);--请求一下最新数据,已购买人数
    else --如果没有数据,就不打开这个UI
        return
    end

    BuyUPassActUI.IsUIShow = true;
    LuaClassObj.HandleDynamicCreation(bp_buy_upass_act);
    LuaClassObj.HandleUIMessage(bp_buy_upass_act, "UIShow");
    EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CHANGE, BuyUPassActUI.RefreshUI) 
    UnknowPassSystem.upass_buy_pass_list_req();
end

function BuyUPassActUI.RefreshUI()--活动数据有变的时候调用
    if not BuyUPassActUI.IsUIShow then
        return;
    end

    BuyUPassActUI.RefreshBuyData();
    LuaClassObj.HandleUIMessage(bp_buy_upass_act, "UIShow");
end

function BuyUPassActUI.ClearData()
    log("xzx BuyUpassAct ClearData")
    local info = BP_STRUCT_Buy_UPass_Act_Info
    info.actTime = ""
    info.actId = 0
    info.isBuy = false
    info.curBuy = 0
    info.allBuy = 0
    info.BP_ARRAY_Buy_UPass_Act_Item_Infos = {}
end

function BuyUPassActUI.TestData()
    local info = BP_STRUCT_Buy_UPass_Act_Info
    info.BP_ARRAY_Buy_UPass_Act_Item_Infos = {}
    for i = 1, 4 do
        local s = 0
        if i == 2 then
            s = 1
        elseif i == 3 then
            s = 2
        end
        table.insert(info.BP_ARRAY_Buy_UPass_Act_Item_Infos,{
                    index = i,
                    id = 401020 + i,--
                    count = i,
                    status = s,
                    stepNum = i * 100000 --这里记得在InitCond里面获取
        })
    end
    info.actId = 123
    info.actTime = "2018/03/02-2018/03/03"
    info.curBuy = 234567
    info.isBuy = true
end

function BuyUPassActUI.HandleRedPoint()
    --已购买通行证, 有物品可以领取
    local info = BP_STRUCT_Buy_UPass_Act_Info
    if info.isBuy == true then
        for k,v in ipairs(info.BP_ARRAY_Buy_UPass_Act_Item_Infos) do
            if v ~= nil and v.status ~= nil  and v.status == 1 then
                log("xzx BuyUPassActUI.hasRedPoint = true")
                LobbyUI:LobbyRedPointUpdate(BP_ENUM_MODULE_BUY_UPASS_ACT, true);
                return
            end
        end
    end
    log("xzx BuyUPassActUI.hasRedPoint = false");
    LobbyUI:LobbyRedPointUpdate(BP_ENUM_MODULE_BUY_UPASS_ACT, false);
end

function BuyUPassActUI.RefreshBuyData()
    
    log("xzx BuyUPassActUI.RefreshBuyData")
    local actType = ActivityType["BUY_UPASS_ACTIVITY"]; --42 活动类型

    --log_tree("xzx DataMgr.roleData:",DataMgr.roleData)

    for _, activity in ipairs(DataMgr.activity.data) do
        if activity and activity.Type ~= nil and activity.Type == actType then
            
            --log_tree("xzx activity data:", activity)

            local info = BP_STRUCT_Buy_UPass_Act_Info;
            info.actId = activity.ID

            local beginTime = os.date("%Y/%m/%d", activity.StartTime)
            local endTime = os.date("%Y/%m/%d", activity.EndTime)
            --local text = FuncUtil.GetLocalizeResStr("660018");
            info.actTime = beginTime.."-"..endTime;--string.format(text, beginTime, endTime)

            
            if activity.other then
                if activity.other.pass_buy_total_cnt then
                    info.curBuy = activity.other.pass_buy_total_cnt
                end
                if info.curBuy > 9999999 then
                    info.curBuy = 9999999--蓝图中数字码只有7位
                end

                if activity.other.join_activity_pass_buy then
                    info.isBuy = activity.other.join_activity_pass_buy
                end
                info.isBuy = info.isBuy or UnknowPassSystem.IsBuyElite;--购买通行证会刷新此数据
            end
            --info.curBuy = 200001

            --[[if DataMgr.roleData and DataMgr.roleData.upass and DataMgr.roleData.upass.is_buy ~= nil then
                info.isBuy = DataMgr.roleData.upass.is_buy == 1
            end]]--

            info.BP_ARRAY_Buy_UPass_Act_Item_Infos = {}
            for k,v in ipairs(activity.List) do
                local tmpStatus = v.Status
                if info.isBuy == false then--没有买通行证,后台数据所有item的status为0,需在这里改正一下,这样在蓝图中可统一显示
                    if info.curBuy ~= 0 and info.curBuy >= v.Total then
                        tmpStatus = 1
                    end
                end

                table.insert(info.BP_ARRAY_Buy_UPass_Act_Item_Infos,{
                    index = v.Index,
                    id = v.Drop[1].itemId,--101001 + k,--
                    count = v.Drop[1].count,
                    status = tmpStatus,
                    stepNum = v.Total --这里记得在logic_activity.InitCond里面获取 (activityType ==  ActivityType["BUY_UPASS_ACTIVITY"])
                })
            end
        end
    end

    --BuyUPassActUI.TestData()
    BuyUPassActUI.HandleProgress()
    BuyUPassActUI.HandleRedPoint()--处理红点
    log_tree("xzx BuyUPassActUI, info:", BP_STRUCT_Buy_UPass_Act_Info)
end

function BuyUPassActUI.HandleProgress()
    if BP_STRUCT_Buy_UPass_Act_Info.curBuy == 0 then
        return
    end
    local buyNum = BP_STRUCT_Buy_UPass_Act_Info.curBuy
    local infos = BP_STRUCT_Buy_UPass_Act_Info.BP_ARRAY_Buy_UPass_Act_Item_Infos
    local num1 = 0
    local num2 = 0
    local num3 = 0
    local num4 = 0
    for k,v in ipairs(infos) do
        if v.index == 1 then
            num1 = v.stepNum
        elseif v.index == 2 then
            num2 = v.stepNum 
        elseif v.index == 3 then
            num3 = v.stepNum
        elseif v.index == 4 then
            num4 = v.stepNum
        end
    end

    --log("xzx buyNum = "..buyNum..", num1 = "..num1..", num2 = "..num2..", num3 = "..num3..", num4 = "..num4);

    if num1 == 0 or num2 == 0 or num3 == 0 or num4 == 0 then
        return
    end

    local progress = 0
    if buyNum < num1 then
        progress = buyNum / num1 * 0.081
    elseif buyNum < num2 then
        progress = (buyNum - num1) / (num2 - num1) * (0.362 - 0.081) + 0.081
    elseif buyNum < num3 then
        progress = (buyNum - num2) / (num3 - num2) * (0.643 - 0.362) + 0.362
    elseif buyNum < num4 then
        progress = (buyNum - num3) / (num4 - num3) * (0.92 - 0.643) + 0.643
    elseif buyNum >= num4 then
        progress = (buyNum - num4) / (num4 - num3) * (1.0 - 0.92) + 0.92
    end

    --log("xzx progress = "..progress)
    BP_STRUCT_Buy_UPass_Act_Info.allBuy = math.ceil(progress * 1000)--取整数部分
end

function EventBuyUPassActHideUI()
    log("xzx hideUI")
    BuyUPassActUI.IsUIShow = false;
    EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CHANGE, BuyUPassActUI.RefreshUI) 
    LuaClassObj.HandleUIMessage(bp_buy_upass_act, "Hide");
end

--查看奖励(状态0查看tips,状态1(isBuy-True: 领取奖励,isBuy-False:请先升级通行证),状态2显示已领取)
function EventBuyUPassActClickItemBtn()
    log("xzx BuyUPassAct, BP_Cur_HandleBuyUPassItemIndex = "..BP_Cur_HandleBuyUPassItemIndex)

    
    local index = BP_Cur_HandleBuyUPassItemIndex;

    local arrayInfos = BP_STRUCT_Buy_UPass_Act_Info.BP_ARRAY_Buy_UPass_Act_Item_Infos
    for i, v in ipairs(arrayInfos) do
        if v.index == index and v.id ~= 0 then
            log("xzx BuyUPassAct, cur click index = "..v.index..", id = "..v.id..", status = "..v.status)
            if v.status == 0 then
            --DoNothing 显示tips在蓝图里面实现
            elseif v.status == 1 then
                if BP_STRUCT_Buy_UPass_Act_Info.isBuy == true then
                    --走的活动兑换/领取协议
                    ActivitySystem.Req_TakeActivityAwardBatch(BP_STRUCT_Buy_UPass_Act_Info.actId, v.index, 1)--此处i为子活动index
                else
                    --DataMgr.ShowNoticeByString("请先升级通行证")
                    ShowNotice(750004)
                end
            elseif v.status == 2 then
                --DataMgr.ShowNoticeByString("奖励已领取")
                ShowNotice(108002)
            end
        end
    end
end
