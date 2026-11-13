--特惠派对UI
DiscountFeverUI = DiscountFeverUI or
{
    isShow = false,
    bRedDot = false,
    activityId = 0,
    isbuying = false,    --是否在等待购买回包
}

--错误类型枚举
ENUM_DISCOUNT_FEVER_ERR_CODE =
{
    ["param err"] = 108109,
    ["not exist"] = 108101,
    ["uc not enough"] = 502006,
    ["buy err"] = 9940012,
    ["limited"] = 433016,
    ["ok"] = 6493,
}

--商品信息
BP_STRUCT_Discount_Fever_ItemInfo =
{
    itemId = 0,
    num = 0,
    leftnum = 0,
    index = 0,
    oldUC = 0,
    saleUC = 0,
    discount = 0,
    name = "",
    itemQualityIcon = "",
}
BP_ARRAY_Discount_Fever_ItemInfo_List =
{
    BP_STRUCT_Discount_Fever_ItemInfo = _G.BP_STRUCT_Discount_Fever_ItemInfo;
}

BP_Discount_Fever_Exchange_Index = 0      --购买的是第几个商品
BP_Discount_Fever_Buy_Num = 0             --购买商品数量
BP_Discount_Fever_Cur_UC = 0              --现在的剩余UC
BP_Discount_Fever_RedPoint = true         --轮播图红点
BP_Discount_Fever_Background_Url = ""     --背景图cdn链接
BP_Discount_Fever_Time_Period = ""        --持续时间
BP_Discount_Fever_ActDesc = ""            --活动描述


--注册Widget
function bp_discount_fever_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_discount_fever,
            {{Path="/Game/UMG/UI_Logic/Activty/Lobby_DiscountFever_BP.Lobby_DiscountFever_BP_C", Container="Default", ZOrder=60}},
            {"Lobby"},
            false,
            false,
            true
    );
end

--从入口进入
function DiscountFeverUI.OpenFromUrl(eventType, eventID, vars)
    log("DiscountFeverUI.Show")
    DiscountFeverUI.activityId = tonumber(vars.activityid)
    DiscountFeverUI.Show()
end

function DiscountFeverUI.Init()

end

function DiscountFeverUI.Release()
    log("DiscountFeverUI.Release")
end

--展示界面
function DiscountFeverUI.Show()
    
    LuaClassObj.HandleDynamicCreation(bp_discount_fever);
    LuaClassObj.HandleUIMessage(bp_discount_fever, "UIShow");
    --ActivitySystem.Req_AcitvityOneData(DiscountFeverUI.activityId)
    DiscountFeverUI.RefreshUI()

    EventSystem:registEvent(EVENTTYPE_ACTIVITY, EVENTID_ACTIVITY_INFO, DiscountFeverUI.OnActInfo);
    EventSystem:registEvent(EVENTTYPE_ACTIVITY, EVENTID_ACTIVITY_EXCHANGE, DiscountFeverUI.OnExchange);
end

--关闭界面
function EventDiscountFeverUIHide()
    EventSystem:unregistEvent(EVENTTYPE_ACTIVITY, EVENTID_ACTIVITY_INFO, DiscountFeverUI.OnActInfo);
    EventSystem:unregistEvent(EVENTTYPE_ACTIVITY, EVENTID_ACTIVITY_EXCHANGE, DiscountFeverUI.OnExchange);
end

--读取活动列表刷新界面
function DiscountFeverUI.RefreshUI()
    local data = ActivitySystem.activityDataTable[DiscountFeverUI.activityId]
    if data == nil then
        return
    end
    
    --local data = {}
    --local oneData = {}
    --local oneData1 = {}
    --local oneData2 = {}
    --oneData.cond = {1006, 20, 7, 8, 0, 0, 0}
    --table.insert(data, oneData)
    --oneData1.cond = {402027, 6, 6, 8, 0, 0, 0}
    --table.insert(data, oneData1)
    --oneData2.cond = {403049, 12, 7, 14, 0, 0, 0}
    --
    --table.insert(data, oneData2)
    
    BP_Discount_Fever_Time_Period = DiscountFeverUI.GetTimePeriod(data.cfg.start_time, data.cfg.end_time)
    BP_Discount_Fever_ActDesc = data.cfg.activity_desc
    BP_Discount_Fever_Background_Url = data.cfg.activity_image_link
    DiscountFeverUI.UpdateAllItem(data)
    BP_Discount_Fever_Cur_UC = DataMgr.ticket;
    LuaClassObj.HandleUIMessage(bp_discount_fever, "UIRefresh");
    DiscountFeverUI.isbuying = false
end

--计算活动持续时间
function DiscountFeverUI.GetTimePeriod(startTime, endTime)
    local startDate = os.date("!*t", startTime);
    local endDate = os.date("!*t", endTime);

    local startTimeString = string.format("%d.%d.%d", startDate.year, startDate.month, startDate.day)
    local endTimeString = string.format("%d.%d.%d", endDate.year, endDate.month, endDate.day)

    return string.format("%s-%s", startTimeString, endTimeString)
end

--根据活动数据刷新商品
function DiscountFeverUI.UpdateAllItem(actData)
    log_tree("DiscountFeverUI.UpdateAllItem", actData.cfg.award)
    BP_ARRAY_Discount_Fever_ItemInfo_List = {}
    for k, v in pairs(actData.cfg.award) do
        local recommendItem = {}
        local tmpcond = StrSplit(v.cond, ",")
        recommendItem.itemId = tonumber(tmpcond[1])
        local cfg = Client.GetTableData("Item", recommendItem.itemId)
        if cfg then
            recommendItem.iconPath = cfg.ItemSmallIcon
            recommendItem.name = cfg.ItemName
            recommendItem.itemQualityIcon = "/Game/UMG/Texture/Atlas/ItemLevelUI/Frames/T_item_icon_quality_" ..tostring(cfg.ItemQuality - 1) .."_png.T_item_icon_quality_" ..tostring(cfg.ItemQuality - 1) .."_png"
        else
            recommendItem.iconPath = ""
            recommendItem.name = ""
            recommendItem.itemQualityIcon = ""
        end
        recommendItem.num = tonumber(tmpcond[2])
        if actData.data.other and next(actData.data.other) ~= nil then
            recommendItem.leftnum = recommendItem.num - actData.data.other.items[k]
        else
            recommendItem.leftnum = recommendItem.num
        end
        recommendItem.oldUC = tonumber(tmpcond[3])
        recommendItem.saleUC = tonumber(tmpcond[4]) * tonumber(tmpcond[3]) / 10
        recommendItem.discount = (10 - tonumber(tmpcond[4])) * 10

        table.insert(BP_ARRAY_Discount_Fever_ItemInfo_List, recommendItem)
    end
    log_tree("BP_ARRAY_Discount_Fever_ItemInfo_List", BP_ARRAY_Discount_Fever_ItemInfo_List)
end

--刷新红点
function DiscountFeverUI.UpdateRedPoint()
    if DiscountFeverUI.bRedDot ~= BP_Discount_Fever_RedPoint then
        DiscountFeverUI.bRedDot = BP_Discount_Fever_RedPoint
        LobbyUI:LobbyRedPointUpdate(BP_ENUM_MODULE_DISCOUNT_FEVER, BP_Discount_Fever_RedPoint)
    end
end

--初始化红点
function DiscountFeverUI.InitRedPoint()
    local currentTimeInDay = math.ceil(FuncUtil.GetServerTimeInSec() / 86400);
    local latestShowTime = DataMgr.GetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_DISCOUNT_FEVER, 1) or 1;
    log("DiscountFever Latest Banner "..currentTimeInDay.." "..latestShowTime);
    if currentTimeInDay == latestShowTime then
        BP_Discount_Fever_RedPoint = false
    end
    if currentTimeInDay ~= latestShowTime then
        BP_Discount_Fever_RedPoint = true
    end
end


--用于同步BP变量到蓝图
function EventDiscountFeverFetchInfo()

end

--活动数据更新后刷新界面
function DiscountFeverUI.OnActInfo()
    log("DiscountFeverUI.OnActInfo")
    DiscountFeverUI.RefreshUI()
end

--购买后更新活动数据
function DiscountFeverUI.OnExchange()
    log("DiscountFeverUI.OnExchange")
    DataMgr.ResetActivityData()
end

--点击购买按钮
function EventDiscountFeverExchangeClick()
    if DiscountFeverUI.isbuying then
        log("you are waiting for the discount rsp!!!")
        return
    end
    --BP_Discount_Fever_RedPoint = false
    --local currentTimeInDay = math.ceil(FuncUtil.GetServerTimeInSec() / 86400);
    --DataMgr.SetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_DISCOUNT_FEVER, 1, currentTimeInDay)
    log("EventDiscountFeverExchangeClick"..BP_Discount_Fever_Exchange_Index.." "..BP_Discount_Fever_Buy_Num)
    DiscountFeverUI.isbuying = true
    NetUtil.SendPriorityPkg(false,"limited_discount_buy_rsp", "limited_discount_buy", DiscountFeverUI.activityId, BP_Discount_Fever_Exchange_Index + 1, BP_Discount_Fever_Buy_Num)
end

--购买商品的回包
function DiscountFeverUI.limited_discount_buy_rsp(res, res_id, count)
    log("limited_discount_buy_rsp: "..res)
    --log("limited_discount_buy_rsp2: "..res_id..count)
    if res ~= "ok" then
        if ENUM_DISCOUNT_FEVER_ERR_CODE[res] ~= nil then
            ShowNotice(ENUM_DISCOUNT_FEVER_ERR_CODE[res])
            if res == "uc not enough" then
                local title = Client.GetTableData("LocalizeRes", "101001").TextValue;
                local tip = Client.GetTableData("LocalizeRes", "4119").TextValue;
                CommonMessageBoxUI:ShowPanel(2, title, tip, function()
                    RechargeUI:Init();
                    return true;
                end);
            end
        end
    else
        local arrayItemList = {}
        local arrayItem = {}
        arrayItem.res_id = res_id
        arrayItem.expire_ts = 0
        arrayItem.valid_hours = 0
        arrayItem.count = count
        table.insert(arrayItemList, arrayItem)
        CommonItemGetUI:ShowPanel(arrayItemList)

        --EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_ACTIVITY_EXCHANGE)
    end
end

-------------------------------------------------------------------------

s2c = s2c or {};
s2c["limited_discount_buy_rsp"] = DiscountFeverUI.limited_discount_buy_rsp;