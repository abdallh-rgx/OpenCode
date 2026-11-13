--黑五UI
BlackFridayUI = BlackFridayUI or 
{
    isShow = false,
    bRedDot = false,
}

--错误类型枚举
ENUM_BLACK_FRIDAY_ERR_CODE = 
{
    not_in_activity = 120106,
    incorrect_item_info = 9940002,
    sale_uc_wrong = 9940003,
    ticket_not_enough = 502006,
    pay_fail = 502005,
    refresh_count = 9940006,
    has_refresh = 9940007,
}

--主推商品
BP_STRUCT_Black_Friday_Special_ItemInfo =
{
    itemId = 0,
    num = 0,
    leftnum = 0,
    iconPath = "",
    oldUC = 0,
    saleUC = 0,
    type = 0,
    name = "",
    itemQualityIcon = "",
}

--普通推荐商品
BP_STRUCT_Black_Friday_ItemInfo =
{
    itemId = 0,
    num = 0,
    leftnum = 0,
    iconPath = "",
    oldUC = 0,
    saleUC = 0,
    type = 0,
    name = "",
    itemQualityIcon = "",
}
BP_ARRAY_Black_Friday_ItemInfo_List =
{
    BP_STRUCT_Black_Friday_ItemInfo = _G.BP_STRUCT_Black_Friday_ItemInfo;
}

--第二期剩余时间，小时分钟秒
BP_STRUCT_Black_Friday_LeftTime = 
{
    Hour = 0,
    Min = 0,
    Sec = 0,
}

--第二期限购商品结构
BP_STRUCT_Black_Friday_LimitItem =
{
    itemId = 0,
    percent = 0,
    iconPath = "",
    oldUC = 0,
    saleUC = 0,
    name = "",
    limitNum = 0,
    itemQualityIcon = "",
}

BP_ARRAY_Black_Friday_LimitItem_List =
{
    BP_STRUCT_Black_Friday_LimitItem = _G.BP_STRUCT_Black_Friday_LimitItem;
}

Black_Friday_Last_Refresh_Time = ""     --上次刷新时间
Black_Friday_Refresh_Count = 0          --刷新次数
BP_Black_Friday_Exchange_Index = 0      --购买的是第几个商品
BP_Black_Friday_Buy_Num = 0             --购买商品数量
BP_Black_Friday_Cur_UC = 0              --现在的剩余UC
BP_Black_Friday_RedPoint = true         --黑五轮播图红点

  --注册Widget
function bp_blackfriday_RegisterUI()
  LuaClassObj.SubUIWidgetList(bp_blackfriday,
    {{Path="/Game/UMG/UI_Logic/Activty/Lobby_BlackFriday_BP.Lobby_BlackFriday_BP_C", Container="Default", ZOrder=60}},
	{"Lobby"},
	false,
	false,
    true
    );
end

--从入口进入
function BlackFridayUI.OpenFromUrl()
    log("BlackFridayUI.Show")
    BP_Black_Friday_RedPoint = false;
    local currentTimeInDay = math.ceil(FuncUtil.GetServerTimeInSec() / 86400);
    DataMgr.SetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_BLACK_FRIDAY, 1, currentTimeInDay)
    BlackFridayUI.Show()
end

function BlackFridayUI.Init()

end

function BlackFridayUI.Release()
	log("BlackFridayUI.Release")
end

--展示界面
function BlackFridayUI.Show()
    NetUtil.SendPkg("get_black_friday_recommend")
    NetUtil.SendPkg("get_black_friday_snatch")
	LuaClassObj.HandleDynamicCreation(bp_blackfriday);
    LuaClassObj.HandleUIMessage(bp_blackfriday, "UIShow");
end

function BlackFridayUI.Hide(isNative)

end

function BlackFridayUI.RefreshUI()

end

--初始化红点
function BlackFridayUI.InitRedPoint()
    local currentTimeInDay = math.ceil(FuncUtil.GetServerTimeInSec() / 86400);
    local latestShowTime = DataMgr.GetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_BLACK_FRIDAY, 1) or 1;
    log("Black Latest Banner "..currentTimeInDay.." "..latestShowTime);
    if currentTimeInDay == latestShowTime then
        BP_Black_Friday_RedPoint = false
    end
    if currentTimeInDay ~= latestShowTime then
        BP_Black_Friday_RedPoint = true
    end
end

--刷新红点
function BlackFridayUI.UpdateRedPoint()
    if BlackFridayUI.bRedDot ~= BP_Black_Friday_RedPoint then
        BlackFridayUI.bRedDot = BP_Black_Friday_RedPoint
        LobbyUI:LobbyRedPointUpdate(BP_ENUM_MODULE_BLACK_FRIDAY, BP_Black_Friday_RedPoint)
    end
end

--根据服务器数据刷新某个商品
function BlackFridayUI.UpdateItemByIndex(index, count)
    if index == 1 then
        BP_STRUCT_Black_Friday_Special_ItemInfo.leftnum = BP_STRUCT_Black_Friday_Special_ItemInfo.leftnum - count
    else
        BP_ARRAY_Black_Friday_ItemInfo_List[index - 1].leftnum = BP_ARRAY_Black_Friday_ItemInfo_List[index - 1].leftnum - count
    end
    LuaClassObj.HandleUIMessage(bp_blackfriday, "UIRefresh");
end

--根据服务器数据刷新所有第一期商品
function BlackFridayUI.UpdateAllItem(itemtable)
    BP_ARRAY_Black_Friday_ItemInfo_List = {}
    Black_Friday_Last_Refresh_Time = itemtable.last_refresh_time
    Black_Friday_Refresh_Count = itemtable.today_refresh_count
    for k, v in pairs(itemtable.today_recommend) do
        if itemtable.today_recommend[k].type == 1 then
            BP_STRUCT_Black_Friday_Special_ItemInfo.itemId = itemtable.today_recommend[k].res_id
            local cfg = Client.GetTableData("Item", BP_STRUCT_Black_Friday_Special_ItemInfo.itemId)
            if cfg then
                BP_STRUCT_Black_Friday_Special_ItemInfo.iconPath = cfg.ItemSmallIcon
                if cfg.ItemType == 1 then
                    BP_STRUCT_Black_Friday_Special_ItemInfo.iconPath = cfg.ItemBigIcon
                end
                BP_STRUCT_Black_Friday_Special_ItemInfo.name = cfg.ItemName
                BP_STRUCT_Black_Friday_Special_ItemInfo.itemQualityIcon = "/Game/UMG/Texture/Atlas/ItemLevelUI/Frames/T_item_icon_quality_" ..tostring(cfg.ItemQuality - 1) .."_png.T_item_icon_quality_" ..tostring(cfg.ItemQuality - 1) .."_png"
            else
                BP_STRUCT_Black_Friday_Special_ItemInfo.iconPath = ""
                BP_STRUCT_Black_Friday_Special_ItemInfo.name = ""
                BP_STRUCT_Black_Friday_Special_ItemInfo.itemQualityIcon = ""
            end
            BP_STRUCT_Black_Friday_Special_ItemInfo.num = itemtable.today_recommend[k].num
            BP_STRUCT_Black_Friday_Special_ItemInfo.leftnum = itemtable.today_recommend[k].num - itemtable.today_recommend[k].has_buy_num
            BP_STRUCT_Black_Friday_Special_ItemInfo.oldUC = itemtable.today_recommend[k].old_uc
            BP_STRUCT_Black_Friday_Special_ItemInfo.saleUC = itemtable.today_recommend[k].sale_uc
            BP_STRUCT_Black_Friday_Special_ItemInfo.type = itemtable.today_recommend[k].type
        else
            local recommendItem = {}
            recommendItem.itemId = itemtable.today_recommend[k].res_id
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
            recommendItem.num = itemtable.today_recommend[k].num
            recommendItem.leftnum = itemtable.today_recommend[k].num - itemtable.today_recommend[k].has_buy_num
            recommendItem.oldUC = itemtable.today_recommend[k].old_uc
            recommendItem.saleUC = itemtable.today_recommend[k].sale_uc
            recommendItem.type = itemtable.today_recommend[k].type

            table.insert(BP_ARRAY_Black_Friday_ItemInfo_List, recommendItem)
            --log_tree("BP_ARRAY_Black_Friday_ItemInfo_List", BP_ARRAY_Black_Friday_ItemInfo_List)
        end
    end
    LuaClassObj.HandleUIMessage(bp_blackfriday, "UIRefresh");
    --log_tree("BP_ARRAY_Black_Friday_ItemInfo_List", BP_ARRAY_Black_Friday_ItemInfo_List)
end

--第一期点击购买按钮
function EventBlackFridayExchangeClick()
    log("EventBlackFridayExchangeClick"..BP_Black_Friday_Exchange_Index.." "..BP_Black_Friday_Buy_Num)
    local res_id = 0
    if BP_Black_Friday_Exchange_Index == 5 then
        res_id = BP_STRUCT_Black_Friday_Special_ItemInfo.itemId
        NetUtil.SendPkg("buy_black_friday_recommend_req", 1, res_id, BP_Black_Friday_Buy_Num)
    else
        res_id = BP_ARRAY_Black_Friday_ItemInfo_List[BP_Black_Friday_Exchange_Index + 1].itemId
        NetUtil.SendPkg("buy_black_friday_recommend_req", BP_Black_Friday_Exchange_Index + 2, res_id, BP_Black_Friday_Buy_Num)
    end
    log("res_id: "..res_id)
end

--批量拉取第一批商品信息
function BlackFridayUI.sync_black_friday_recommend(res, itemtable)
    log_tree("BlackFridayUI.sync_black_friday_recommend: ", itemtable)
    if res ~= "ok" then
        return
    end
    --log_tree("BlackFridayUI.sync_black_friday_recommend: ", itemtable)
    if next(itemtable) ~= nil then
        BlackFridayUI.UpdateAllItem(itemtable)
    end
end

--用于同步BP变量到蓝图
function EventBlackFridayFetchInfo()

end

--购买第一期商品的回包
function BlackFridayUI.buy_black_friday_recommend_rsp(res, index, res_id, count, has_buy_num)
    --log("buy_black_friday_recommend_rsp: "..res)
    if res ~= "ok" then
        ShowNotice(res)
        if res == ENUM_BLACK_FRIDAY_ERR_CODE.ticket_not_enough then
            local title = Client.GetTableData("LocalizeRes", "101001").TextValue;
            local tip = Client.GetTableData("LocalizeRes", "4119").TextValue;
            CommonMessageBoxUI:ShowPanel(2, title, tip, function()
                    RechargeUI:Init();
                return true;
            end);
        end
    else
    --log_tree("BlackFridayUI.sync_black_friday_recommend: ", itemtable)
        local arrayItemList = {}
        local arrayItem = {}
        arrayItem.res_id = res_id
        arrayItem.expire_ts = 0
        arrayItem.valid_hours = 0
        arrayItem.count = count
        table.insert(arrayItemList, arrayItem)
        CommonItemGetUI:ShowPanel(arrayItemList)

        BlackFridayUI.UpdateItemByIndex(index, count)
    end
end

--尝试刷新一批第一期商品
function EventBlackFridayTryRefresh()
    NetUtil.SendPkg("try_refresh_black_friday_recommend_req")
end

--刷新第一批商品的回包
function BlackFridayUI.try_refresh_black_friday_recommend_rsp(res, itemtable)
    log_tree("BlackFridayUI.try_refresh_black_friday_recommend_rsp: ", itemtable)
    if res ~= "ok" then
        ShowNotice(res)
        if res == ENUM_BLACK_FRIDAY_ERR_CODE.ticket_not_enough then
            local title = Client.GetTableData("LocalizeRes", "101001").TextValue;
            local tip = Client.GetTableData("LocalizeRes", "4119").TextValue;
            CommonMessageBoxUI:ShowPanel(2, title, tip, function()
                    RechargeUI:Init();
                return true;
            end);
        end
    elseif next(itemtable) ~= nil then
        BlackFridayUI.UpdateAllItem(itemtable)
    end
end

--当前的UC
function EventBlackFridayGetCurUC()
    BP_Black_Friday_Cur_UC = DataMgr.ticket;
    LuaClassObj.HandleUIMessage(bp_blackfriday, "SetMoney");
end

--展示活动规则
function EventBlackFridayShowRule()
    log("EventBlackFridayShowRule");
    local title = Client.GetTableData("LocalizeRes", 4726).TextValue
    local content = Client.GetTableData("LocalizeRes", 6314).TextValue
    PopUpNoticeUI.ShowMessageBox(title, content);
end

--根据服务器数据刷新所有第二期限购商品
function BlackFridayUI.UpdateAllLimitItem(itemtable)
    BP_ARRAY_Black_Friday_LimitItem_List = {}
    for k, v in pairs(itemtable) do
        local snatchItem = {}
        snatchItem.itemId = itemtable[k].res_id
        local cfg = Client.GetTableData("Item", snatchItem.itemId)
        if cfg then
            snatchItem.iconPath = cfg.ItemSmallIcon
            if cfg.ItemType == 1 then
                snatchItem.iconPath = cfg.ItemBigIcon
            end
            snatchItem.name = cfg.ItemName
            snatchItem.itemQualityIcon = "/Game/UMG/Texture/Atlas/ItemLevelUI/Frames/T_item_icon_quality_" ..tostring(cfg.ItemQuality - 1) .."_png.T_item_icon_quality_" ..tostring(cfg.ItemQuality - 1) .."_png"
        else
            snatchItem.iconPath = ""
            snatchItem.name = ""
            snatchItem.itemQualityIcon = ""
        end
        snatchItem.percent = math.ceil(((itemtable[k].num - itemtable[k].has_buy_num) * 100) / itemtable[k].num)
        --snatchItem.percent = 40
        snatchItem.limitNum = itemtable[k].num - itemtable[k].has_buy_num
        snatchItem.oldUC = itemtable[k].old_uc
        snatchItem.saleUC = itemtable[k].sale_uc

        table.insert(BP_ARRAY_Black_Friday_LimitItem_List, snatchItem)
    end
    LuaClassObj.HandleUIMessage(bp_blackfriday, "UIRefreshLimit");
    --log_tree("BP_ARRAY_Black_Friday_LimitItem_List", BP_ARRAY_Black_Friday_LimitItem_List)
end

--计算第二期剩余时间
function BlackFridayUI.GetLeftTime(timeInSec)
    local curTimeInSec = FuncUtil.GetServerTimeInSec()
    log("check timeInSec"..timeInSec.." "..curTimeInSec)
    local leftTimeInSec = 3600 * 2 - (curTimeInSec - timeInSec)
    local hours = math.floor(leftTimeInSec/3600)
    local mins = math.floor((leftTimeInSec - hours * 3600) / 60)
    local seconds = leftTimeInSec - hours * 3600 - mins * 60
    BP_STRUCT_Black_Friday_LeftTime.Hour = hours
    BP_STRUCT_Black_Friday_LeftTime.Min = mins
    BP_STRUCT_Black_Friday_LeftTime.Sec = seconds

    log_tree("BP_STRUCT_Black_Friday_LeftTime",  BP_STRUCT_Black_Friday_LeftTime)
end

--批量拉取第二期商品信息回包
function BlackFridayUI.sync_black_friday_snatch(res, itemtable, timeInSec)
    log_tree("BlackFridayUI.sync_black_friday_snatch", itemtable)
    if res ~= "ok" then
        ShowNotice(res)
        return
    end
    if timeInSec then
        BlackFridayUI.GetLeftTime(timeInSec)
    end
    if next(itemtable) ~= nil then
        BlackFridayUI.UpdateAllLimitItem(itemtable)
    end
end

--购买第二期商品请求
function EventBlackFridayExchangeLimitClick()
    log("EventBlackFridayExchangeLimitClick"..BP_Black_Friday_Exchange_Index.." "..BP_Black_Friday_Buy_Num)
    local res_id = 0
    res_id = BP_ARRAY_Black_Friday_LimitItem_List[BP_Black_Friday_Exchange_Index - 5].itemId
    NetUtil.SendPkg("buy_black_friday_snatch_req", BP_Black_Friday_Exchange_Index - 5, res_id, BP_Black_Friday_Buy_Num)
    log("res_id: "..res_id)
end

--购买第二期商品的回包
function BlackFridayUI.buy_black_friday_snatch_rsp(res, res_id, count, itemtable, timeInSec)
    log_tree("BlackFridayUI.buy_black_friday_snatch_rsp: ", itemtable)
    if res ~= "ok" then
        ShowNotice(res)
        if res == ENUM_BLACK_FRIDAY_ERR_CODE.ticket_not_enough then
            local title = Client.GetTableData("LocalizeRes", "101001").TextValue;
            local tip = Client.GetTableData("LocalizeRes", "4119").TextValue;
            CommonMessageBoxUI:ShowPanel(2, title, tip, function()
                    RechargeUI:Init();
                return true;
            end);
        end
    else
    --log_tree("BlackFridayUI.sync_black_friday_recommend: ", itemtable)
        local arrayItemList = {}
        local arrayItem = {}
        arrayItem.res_id = res_id
        arrayItem.expire_ts = 0
        arrayItem.valid_hours = 0
        arrayItem.count = count
        table.insert(arrayItemList, arrayItem)
        CommonItemGetUI:ShowPanel(arrayItemList)
    end

    if timeInSec then
        BlackFridayUI.GetLeftTime(timeInSec)
    end
    if next(itemtable) ~= nil then
        BlackFridayUI.UpdateAllLimitItem(itemtable)
    end
end

--切换页签时重新批量拉取第二期信息
function EventBlackFridaySwitchTab()
    NetUtil.SendPkg("get_black_friday_snatch")
end
-------------------------------------------------------------------------

s2c = s2c or {};
s2c["sync_black_friday_recommend"] = BlackFridayUI.sync_black_friday_recommend;
s2c["try_refresh_black_friday_recommend_rsp"] = BlackFridayUI.try_refresh_black_friday_recommend_rsp;
s2c["buy_black_friday_recommend_rsp"] = BlackFridayUI.buy_black_friday_recommend_rsp;
s2c["sync_black_friday_snatch"] = BlackFridayUI.sync_black_friday_snatch;
s2c["buy_black_friday_snatch_rsp"] = BlackFridayUI.buy_black_friday_snatch_rsp;