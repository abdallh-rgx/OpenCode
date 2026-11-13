--不放回抽奖UI
LuckyUnbackUI = LuckyUnbackUI or
{
    isShow = false,
    bRedDot = false,
}

--错误类型枚举
ENUM_LUCKYUNBACK_ERR_CODE =
{
    success = 0,

    activity_errcode_activity_have_end = 108108,
    activity_errcode_param_error = 108109,
    activity_errcode_activity_not_exist = 108101,

    luckyunback_err_need_res_not_enough         = 6494,      --抽奖所需代币不够
    luckyunback_err_pay_error                   = 995002,    --抽奖代币支付失败
    luckyunback_err_voucher_not_exist           = 995003,    --代金券不存在
    luckyunback_err_can_not_next_round          = 995004,    --代金券不足
}

--主推商品
BP_STRUCT_LuckyUnback_ItemInfo =
{
    itemId = 0,
    num = 0,
    hasGet = false,
    iconPath = "",
    oldUC = 0,
    saleUC = 0,
    name = "",
    itemQuality = 0,
    pos = 0,
    recommendLevel = 0,
}

BP_ARRAY_LuckyUnback_ItemInfo_List =
{
    BP_STRUCT_LuckyUnback_ItemInfo = _G.BP_STRUCT_LuckyUnback_ItemInfo;
}

BP_STRUCT_LuckyUnback_Voucher =
{
    voucher_id = 0,
    price = 0,
    name = "",
}

BP_ARRAY_LuckyUnback_Voucher_List =
{
    BP_STRUCT_LuckyUnback_Voucher = _G.BP_STRUCT_LuckyUnback_Voucher;
}

ENUM_LUCKYUNBACK_VOUCHER_PRICE =
{
    [1803015] = 30,
    [1803016] = 40,
    [1803017] = 50,
}

BP_LuckyUnback_AcivityInfo = 
{
    ActivityId = 0,
    
    AwardList = {},        --奖品列表
    PriceList = {},        --价格列表
    PlayerData = {},       --玩家抽奖数据
    
    SurpriseId = 0,        --彩蛋活动id
}
BP_LuckyUnback_Total_Round = 0          --一共有几轮抽奖
BP_LuckyUnback_Round_Count = 0          --第几轮夺宝
BP_LuckyUnback_RedPoint = true          --轮播图红点
BP_LuckyUnback_Cur_Price = 0;           --当前的价格
BP_LuckyUnback_CurGetPos = 0;           --获得物品的位置
BP_LuckyUnback_CurVoucherPrice = 0;     --当前代金券金额
BP_LuckyUnback_CurVoucherId = 0;        --当前代金券id
BP_LuckyUnback_CurVoucherCount = 0;     --代金券总数
BP_LuckyUnback_Had_Draw_Count = 0       --已经刷新几次
BP_LuckyUnback_Cur_UC = 0               --现在的剩余UC
BP_LuckyUnback_TimePeriod = "";         --活动持续时间
BP_LuckyUnback_SurpriseStatus = 0;      --彩蛋显示状态
BP_LuckyUnback_ImageLink = "";          --图片链接
BP_LuckyUnback_AnimStage = 0            --动画阶段
BP_LuckyUnback_ResourceType = 0         --不同活动的资源切换
BP_LuckyUnback_IsOpenLobbyEnter = false --是否打开大厅入口
BP_LuckyUnback_IsShowBubble = true      --是否展示气泡

local arrayItemList = {}

--注册Widget
function bp_lucky_unback_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_lucky_unback,
            {{Path="/Game/UMG/UI_Logic/Activty/Lobby_LuckyUnback_BP.Lobby_LuckyUnback_BP_C", Container="Default", ZOrder=60}},
            {"Lobby"},
            false,
            false,
            true
    );
end

--从入口进入
function LuckyUnbackUI.OpenFromUrl(eventType, eventID, vars)
    log("LuckyUnbackUI.OpenFromUrl")
    
    --隐藏banner红点
    BP_LuckyUnback_RedPoint = false;
    DataMgr.SetNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_LUCKYUNBACK, 1)
    
    --判断气泡是否存在
    BP_LuckyUnback_IsShowBubble = DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_LUCKYUNBACK, 2)
    
    BP_LuckyUnback_Round_Count = 1
    BP_LuckyUnback_AcivityInfo.ActivityId = tonumber(vars.activityid)
    
    log("BP_LuckyUnback_AcivityInfo.ActivityId"..BP_LuckyUnback_AcivityInfo.ActivityId)
    local data = ActivitySystem.activityDataTable[BP_LuckyUnback_AcivityInfo.ActivityId]
    if data == nil then
        return
    end

    BP_LuckyUnback_TimePeriod = LuckyUnbackUI.GetTimePeriod(data.cfg.start_time, data.cfg.end_time)
    BP_LuckyUnback_ImageLink = data.cfg.activity_image_link
    BP_LuckyUnback_ResourceType = data.cfg.label_type
    BP_LuckyUnback_AcivityInfo.SurpriseId = ActivitySystem.GetSurpriseActivityInfoByBindID(BP_LuckyUnback_AcivityInfo.ActivityId)
    LuckyUnbackUI.Show()
end

function LuckyUnbackUI.Init()

end

function LuckyUnbackUI.Release()
    
end

--展示界面
function LuckyUnbackUI.Show()
    NetUtil.SendPkg("get_lucky_draw_unback_activity_req", BP_LuckyUnback_AcivityInfo.ActivityId)
    LuaClassObj.HandleDynamicCreation(bp_lucky_unback);
    LuaClassObj.HandleUIMessage(bp_lucky_unback, "UIShow");
    AchievementFloatTipUI.BlockingPop = true

    EventSystem:registEvent(EVENTTYPE_ACTIVITY, EVENTID_ACTIVITY_INFO, LuckyUnbackUI.OnActInfo);
end

--关闭界面的lua部分处理
function EventLuckyUnbackClose()
    EventSystem:unregistEvent(EVENTTYPE_ACTIVITY, EVENTID_ACTIVITY_INFO, LuckyUnbackUI.OnActInfo);
    AchievementFloatTipUI.BlockingPop = false
end

--计算活动持续时间的字符串
function LuckyUnbackUI.GetTimePeriod(startTime, endTime)
    local startDate = os.date("!*t", startTime);
    local endDate = os.date("!*t", endTime);

    local startTimeString = string.format("%d.%d.%d", startDate.year, startDate.month, startDate.day)
    local endTimeString = string.format("%d.%d.%d", endDate.year, endDate.month, endDate.day)

    return string.format("%s-%s", startTimeString, endTimeString)
end

--初始化红点
function LuckyUnbackUI.InitRedPoint()
    local NeedBioChemicalShow = DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_LUCKYUNBACK, 1);
    log("luckyunback Latest Banner "..tostring(NeedBioChemicalShow));
    BP_LuckyUnback_RedPoint = NeedBioChemicalShow
end

--刷新红点
function LuckyUnbackUI.UpdateRedPoint()
    --log("LuckyUnbackUI.UpdateRedPoint"..tostring(BP_LuckyUnback_RedPoint))
    if LuckyUnbackUI.bRedDot ~= BP_LuckyUnback_RedPoint then
        LuckyUnbackUI.bRedDot = BP_LuckyUnback_RedPoint
        LobbyUI:LobbyRedPointUpdate(BP_ENUM_MODULE_LUCKY_UNBACK, BP_LuckyUnback_RedPoint)
        --LobbyUI.UpdateLuckyUnbackReddot()
    end
end

--刷新界面
function LuckyUnbackUI.RefreshUI()
    LuckyUnbackUI.GetVoucherList()
    LuckyUnbackUI.CheckSurprise()
    LuaClassObj.HandleUIMessage(bp_lucky_unback, "UIRefresh");
end

--从除banner图外的地方跳转到活动
function LuckyUnbackUI.OpenFromOther()
    --log_tree("LuckyUnbackUI.OpenFromOther", LobbySystem.activityDisplayDataList)
    for k, v in pairs(LobbySystem.activityDisplayDataList) do
        local globalUrl = v.JumpUrl
        if JumpUtils.IsGameJumpUrl(globalUrl) then
            local params = FuncUtil:ParseURLParams(globalUrl);
            local moduleId = tonumber(params["module"]);
            if moduleId == BP_ENUM_MODULE_LUCKY_UNBACK then
                EventSystem:postEvent(EVENTTYPE_URL, moduleId, params);
                return
            end
        end
    end
    ShowNotice(4002)
end

--判断大厅入口是否开启 春季开启 模板不开启
function LuckyUnbackUI.IsLobbyOpen()
    --log_tree("LuckyUnbackUI.IsLobbyOpen", LobbySystem.activityDisplayDataList)
    for k, v in pairs(LobbySystem.activityDisplayDataList) do
        local globalUrl = v.JumpUrl
        --log("LuckyUnbackUI.IsLobbyOpen"..globalUrl)
        if JumpUtils.IsGameJumpUrl(globalUrl) then
            local params = FuncUtil:ParseURLParams(globalUrl);
            local moduleId = tonumber(params["module"]);
            if moduleId == BP_ENUM_MODULE_LUCKY_UNBACK then
                local actid = tonumber(params["activityid"])
                local data = ActivitySystem.activityDataTable[actid]
                --log("EventLuckyUnbackCheckIsLobbyOpen"..actid)
                --log_tree("LuckyUnbackUI.IsLobbyOpen data", ActivitySystem.activityDataTable)
                if data == nil or data.cfg == nil then
                    return
                end

                if data.cfg.label_type and data.cfg.label_type == 1 then
                    BP_LuckyUnback_IsOpenLobbyEnter = true
                    LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "UpdateLuckyUnbackEnter")
                    return
                end
            end
        end
    end
    BP_LuckyUnback_IsOpenLobbyEnter = false
    LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "UpdateLuckyUnbackEnter")
end

--返回抵扣券专属道具id
function LuckyUnbackUI.GetVoucherItemIdList()
    return {1803015, 1803016, 1803017}
end

--判断是否为不放回抽奖道具
function LuckyUnbackUI.IsLuckyUnbackVoucher(id)
    for k, v in pairs(LuckyUnbackUI.GetVoucherItemIdList()) do
        if id == v then
            return true
        end
    end
    return false
end

--计算默认选中的抵扣券
function LuckyUnbackUI.GetSelectedVoucherItem()
    local greater = -1
    local lower = 1
    local greaterindex = 0
    local lowerindex = 0
    for k, v in pairs(BP_ARRAY_LuckyUnback_Voucher_List) do
        local distance = v.price - BP_LuckyUnback_Cur_Price
        if distance > 0 then
            if distance < greater or greater == -1 then
                greater = distance
                greaterindex = k
            end
        else
            if distance > lower or lower == 1 then
                lower = distance
                lowerindex = k
            end
        end
    end
    if lowerindex ~= 0 then
        BP_LuckyUnback_CurVoucherId = BP_ARRAY_LuckyUnback_Voucher_List[lowerindex].voucher_id
        BP_LuckyUnback_CurVoucherPrice = ENUM_LUCKYUNBACK_VOUCHER_PRICE[BP_LuckyUnback_CurVoucherId]
    elseif greaterindex ~= 0 then
        BP_LuckyUnback_CurVoucherId = BP_ARRAY_LuckyUnback_Voucher_List[greaterindex].voucher_id
        BP_LuckyUnback_CurVoucherPrice = ENUM_LUCKYUNBACK_VOUCHER_PRICE[BP_LuckyUnback_CurVoucherId]
    end
end

--获取所有可用抵扣券的列表
function LuckyUnbackUI.GetVoucherList()
    BP_ARRAY_LuckyUnback_Voucher_List = {}
    BP_LuckyUnback_CurVoucherCount = 0
    for i, v in pairs(LuckyUnbackUI.GetVoucherItemIdList()) do
        local voucherItem = {}
        local cacheItem = DataMgr.GetHallDepotItemDataByResIDAndValidExpireTime(v)
        log_tree("cacheItem", cacheItem)
        if cacheItem ~= nil then
            voucherItem.voucher_id = cacheItem.resID
            voucherItem.price = ENUM_LUCKYUNBACK_VOUCHER_PRICE[v]
            voucherItem.name = Client.GetTableData("Item", cacheItem.resID).ItemName
            table.insert(BP_ARRAY_LuckyUnback_Voucher_List, voucherItem)
            BP_LuckyUnback_CurVoucherCount = BP_LuckyUnback_CurVoucherCount + cacheItem.count
        end
    end
    if #BP_ARRAY_LuckyUnback_Voucher_List <= 0 then
        BP_LuckyUnback_CurVoucherId = -1
        BP_LuckyUnback_CurVoucherPrice = 0
        BP_LuckyUnback_CurVoucherCount = 0
    else
        LuckyUnbackUI.GetSelectedVoucherItem()
    end
    
    log_tree("BP_ARRAY_LuckyUnback_Voucher_List", BP_ARRAY_LuckyUnback_Voucher_List)
end

--刷新界面附带信息
function LuckyUnbackUI.UpdateCurStatus()
    BP_LuckyUnback_Cur_UC = DataMgr.ticket
    BP_LuckyUnback_Had_Draw_Count = 0
    local cur_round_activity_data = {}
    
    if BP_LuckyUnback_AcivityInfo.PlayerData[BP_LuckyUnback_Round_Count] ~= nil and next(BP_LuckyUnback_AcivityInfo.PlayerData[BP_LuckyUnback_Round_Count]) ~= nil then
        cur_round_activity_data = BP_LuckyUnback_AcivityInfo.PlayerData[BP_LuckyUnback_Round_Count]
        log_tree("cur_round_activity_data", cur_round_activity_data)
        BP_LuckyUnback_Had_Draw_Count = cur_round_activity_data.had_draw_count
        for k, v in pairs(cur_round_activity_data.had_draw_info) do
            BP_ARRAY_LuckyUnback_ItemInfo_List[v.pos_id].hasGet = true
        end
    end
    
    local AwardLen = 0
    for k, v in pairs(BP_LuckyUnback_AcivityInfo.AwardList[BP_LuckyUnback_Round_Count]) do
        AwardLen = AwardLen + 1
    end
    if BP_LuckyUnback_Had_Draw_Count < AwardLen then
        BP_LuckyUnback_Cur_Price = BP_LuckyUnback_AcivityInfo.PriceList[BP_LuckyUnback_Round_Count][BP_LuckyUnback_Had_Draw_Count + 1].price
    end
end

--刷新全部商品状态
function LuckyUnbackUI.UpdateAllItem()
    log_tree("BP_LuckyUnback_AcivityInfo.AwardList[BP_LuckyUnback_Round_Count]", BP_LuckyUnback_AcivityInfo.AwardList[BP_LuckyUnback_Round_Count])
    BP_ARRAY_LuckyUnback_ItemInfo_List = {}
    for k, v in pairs(BP_LuckyUnback_AcivityInfo.AwardList[BP_LuckyUnback_Round_Count]) do
        local luckyItem = {}
        luckyItem.itemId = k
        local cfg = Client.GetTableData("Item", luckyItem.itemId)
        if cfg then
            luckyItem.iconPath = cfg.ItemSmallIcon
            luckyItem.name = cfg.ItemName
            luckyItem.itemQuality = cfg.ItemQuality
        else
            luckyItem.iconPath = ""
            luckyItem.name = ""
            luckyItem.itemQualityIcon = 0
        end
        luckyItem.num = v.item_num
        luckyItem.pos = v.pos_id
        luckyItem.hasGet = false
        luckyItem.recommendLevel = v.recommend_level

        table.insert(BP_ARRAY_LuckyUnback_ItemInfo_List, luckyItem)
    end

    table.sort(BP_ARRAY_LuckyUnback_ItemInfo_List, function(a, b) return a.pos < b.pos end);

    log_tree("LuckyUnbackUI.UpdateAllItem: ", BP_ARRAY_LuckyUnback_ItemInfo_List)
end

--拉取抽奖信息回包
function LuckyUnbackUI.get_lucky_draw_unback_activity_rsp(res, lucky_draw_unback_cfg, lucky_draw_unback_price_cfg, my_activity_data)
    log_tree("LuckyUnbackUI.get_lucky_draw_unback_activity_rsp ", lucky_draw_unback_cfg)
    log("LuckyUnbackUI.get_lucky_draw_unback_activity_rsp res"..tostring(res))
    if res ~= ENUM_LUCKYUNBACK_ERR_CODE.success then
        ShowNotice(res)
        return
    end
    
    BP_LuckyUnback_AcivityInfo.PriceList = lucky_draw_unback_price_cfg
    BP_LuckyUnback_AcivityInfo.PlayerData = my_activity_data
    if next(lucky_draw_unback_cfg) ~= nil then
        BP_LuckyUnback_AcivityInfo.AwardList = lucky_draw_unback_cfg
        BP_LuckyUnback_Total_Round = #lucky_draw_unback_cfg
        LuckyUnbackUI.UpdateAllItem()
    end
    LuckyUnbackUI.UpdateCurStatus()

    LuckyUnbackUI.RefreshUI();
end

--拼接活动时间的字符串
function LuckyUnbackUI.GetTimePeriod(startTime, endTime)
    local startDate = os.date("!*t", startTime);
    local endDate = os.date("!*t", endTime);

    local startTimeString = string.format("%d.%d.%d", startDate.year, startDate.month, startDate.day)
    local endTimeString = string.format("%d.%d.%d", endDate.year, endDate.month, endDate.day)

    return FuncUtil.LocalizeResFormat("6515", startTimeString, endTimeString)
end

--计算动画播放阶段
function LuckyUnbackUI.GetAnimStage()
    local counter = 0
    if BP_LuckyUnback_AcivityInfo.PlayerData[BP_LuckyUnback_Round_Count] ~= nil and next(BP_LuckyUnback_AcivityInfo.PlayerData[BP_LuckyUnback_Round_Count]) ~= nil then
        cur_round_activity_data = BP_LuckyUnback_AcivityInfo.PlayerData[BP_LuckyUnback_Round_Count]
        log_tree("cur_round_activity_data", cur_round_activity_data)
        BP_LuckyUnback_Had_Draw_Count = cur_round_activity_data.had_draw_count
        for k, v in pairs(cur_round_activity_data.had_draw_info) do
            counter = counter + 1
        end
    end
    local AwardLen = 0
    for k, v in pairs(BP_LuckyUnback_AcivityInfo.AwardList[BP_LuckyUnback_Round_Count]) do
        AwardLen = AwardLen + 1
    end
    if counter <= AwardLen / 2 then
        return 1
    elseif counter == AwardLen then
        return 0
    end
    return 2
end

--点击抽奖按钮
function EventLuckyUnbackExchangeClick()
    log("EventLuckyUnbackExchangeClick"..BP_LuckyUnback_Round_Count..BP_LuckyUnback_Had_Draw_Count..BP_LuckyUnback_CurVoucherId)
    if BP_LuckyUnback_CurVoucherId == -1 then
        NetUtil.SendPriorityPkg(false, "do_one_draw_by_activity_rsp", "do_one_draw_by_activity_req", BP_LuckyUnback_AcivityInfo.ActivityId, BP_LuckyUnback_Round_Count, BP_LuckyUnback_Had_Draw_Count)
    else
        NetUtil.SendPriorityPkg(false, "do_one_draw_by_activity_rsp", "do_one_draw_by_activity_req", BP_LuckyUnback_AcivityInfo.ActivityId, BP_LuckyUnback_Round_Count, BP_LuckyUnback_Had_Draw_Count, BP_LuckyUnback_CurVoucherId)
    end
end

--抽奖结果的回包
function LuckyUnbackUI.do_one_draw_by_activity_rsp(res, my_activity_data, award_info)
    log("LuckyUnbackUI.do_one_draw_by_activity_rsp"..res)
    if res ~= ENUM_LUCKYUNBACK_ERR_CODE.success then
        ShowNotice(res)
        if res == ENUM_LUCKYUNBACK_ERR_CODE.luckyunback_err_need_res_not_enough then
            local title = Client.GetTableData("LocalizeRes", "101001").TextValue;
            local tip = Client.GetTableData("LocalizeRes", "4119").TextValue;
            CommonMessageBoxUI:ShowPanel(2, title, tip, function()
                RechargeUI:Init();
                return true;
            end);
        end
    else
        log_tree("LuckyUnbackUI.do_one_draw_by_activity_rsp", my_activity_data)
        --log_tree("LuckyUnbackUI.do_one_draw_by_activity_rsp award_info", award_info)

        arrayItemList = {}
        local arrayItem = {}
        arrayItem.res_id = award_info.resid
        arrayItem.expire_ts = 0
        arrayItem.valid_hours = 0
        arrayItem.count = award_info.count
        table.insert(arrayItemList, arrayItem)
        --CommonItemGetUI:ShowPanel(arrayItemList)

        BP_LuckyUnback_CurGetPos = award_info.pos_id
        BP_LuckyUnback_AcivityInfo.PlayerData = my_activity_data
        --LuckyUnbackUI.UpdateCurStatus()
        
        BP_LuckyUnback_AnimStage = LuckyUnbackUI.GetAnimStage()
        if BP_LuckyUnback_AnimStage == 0 then
            EventLuckyUnbackShowGet()
        end
        LuaClassObj.HandleUIMessageNoFetch(bp_lucky_unback, "PlayAnim");
        --log_tree("BioChemicalUI.do_biochemical_activity_one_draw_rsp: ", BP_ARRAY_BioChemical_ItemInfo_List)
    end
end

--点击切换奖池
function EventLuckyUnbackSwicthRound()
    LuckyUnbackUI.UpdateAllItem()
    LuckyUnbackUI.UpdateCurStatus()
    LuckyUnbackUI.RefreshUI()
end

--延迟展示物品掉落并刷新界面
function EventLuckyUnbackShowGet()
    LuckyUnbackUI.UpdateCurStatus()
    CommonItemGetUI:ShowPanel(arrayItemList)
    LuckyUnbackUI.RefreshUI();
end

--展示活动规则
function EventLuckyUnbackShowRule()
    log("EventLuckyUnbackShowRule");
    local title = Client.GetTableData("LocalizeRes", 4726).TextValue
    local content = ActivitySystem.activityDataTable[BP_LuckyUnback_AcivityInfo.ActivityId].cfg.activity_desc
    PopUpNoticeUI.ShowMessageBox(title, content);
end

--展示概率公示
function EventLuckyUnbackShowRate()
    log("EventLuckyUnbackShowRate");
    local remark_content = ActivitySystem.activityDataTable[BP_LuckyUnback_AcivityInfo.ActivityId].cfg.remark_content
    
    local strRegion = Client.GetPublishRegion();
    if strRegion == "JAPAN" or strRegion == "KOREA" then
        Client.OpenURL(remark_content);
    else
        local RateArray = LuckyUnbackUI.GetRateArrayFromActivity(remark_content)
        local rate_array = RateArray[BP_LuckyUnback_Round_Count]
        local desc = ActivitySystem.activityDataTable[BP_LuckyUnback_AcivityInfo.ActivityId].cfg.activity_detail
        Rate_Panel_UI.Show(rate_array, 6792, desc)
    end
end

--从客户端表获得概率列表
function LuckyUnbackUI.GetRateArray()
    local RateTable = Client.GetTable("LuckyUnbackRate")
    local RateArray = {}
    RateArray[1] = {}
    RateArray[2] = {}
    RateArray[3] = {}
    for k, v in pairs(RateTable) do
        if v.ActivityId == BP_LuckyUnback_AcivityInfo.ActivityId then
            if RateArray[v.Round] then
                RateArray[v.Round][v.Quality] = v.Rate
            end
        end
    end
    log_tree("LuckyUnbackUI.GetRateArray", RateArray)
    return RateArray
end

--从后台获得概率列表
function LuckyUnbackUI.GetRateArrayFromActivity(remark_content)
    local RateArray = {}
    RateArray[1] = {}
    RateArray[2] = {}
    RateArray[3] = {}
    local content = string.split(remark_content, "|")
    for i, v in pairs(content) do
        local sub_content = string.split(v, ",")
        for index, value in pairs(sub_content) do
            local res = string.split(value, "=")
            if tonumber(res[2]) == 0 then
                RateArray[i][tonumber(res[1])] = "0"
            else
                RateArray[i][tonumber(res[1])] = tostring(tonumber(res[2]) / 100).."%"
            end
        end
    end
    log_tree("LuckyUnbackUI.GetRateArrayFromActivity", RateArray)
    return RateArray
end

--触发彩蛋
function EventLuckyUnbackShowSurprise()
    log("EventLuckyUnbackShowSurprise");
    if BP_LuckyUnback_AcivityInfo.SurpriseId ~= -1 then
        ActivitySystem.Req_TakeActivityAwardBatch(BP_LuckyUnback_AcivityInfo.SurpriseId, 1, 1)
    end
end

--显示或隐藏彩蛋
function LuckyUnbackUI.CheckSurprise()
    log("LuckyUnbackUI.CheckSurprise"..BP_LuckyUnback_AcivityInfo.SurpriseId)
    if BP_LuckyUnback_AcivityInfo.SurpriseId <= 0 then
        BP_LuckyUnback_SurpriseStatus = 0
        LuaClassObj.HandleUIMessageNoFetch(bp_lucky_unback, "CheckSurprise");
        return;
    end
    local SurpriseData = ActivitySystem.activityDataTable[BP_LuckyUnback_AcivityInfo.SurpriseId].data
    log_tree("LuckyUnbackUI.CheckSurprise", SurpriseData)
    if SurpriseData and SurpriseData.award[1] then
        BP_LuckyUnback_SurpriseStatus = SurpriseData.award[1].status
        LuaClassObj.HandleUIMessageNoFetch(bp_lucky_unback, "CheckSurprise");
    end
end

--彩蛋活动变更通知
function LuckyUnbackUI.OnActInfo()
    log("LuckyUnbackUI.OnActInfo")
    LuckyUnbackUI.CheckSurprise()
end


--从大厅进入活动
function EventLuckyUnbackEnterFromLobby()
    log("EventLuckyUnbackEnterFromLobby");
    LuckyUnbackUI.OpenFromOther()
    --if skinId == 10006 then
    --    skinId = 10007
    --else
    --    skinId = 10006
    --end
    --GlobalData.SwitchLobbySkin(skinId)
end

--解除气泡记录
function EventLuckyUnbackHideBubble()
    BP_LuckyUnback_IsShowBubble = false
    if BP_LuckyUnback_ResourceType == 1 then
        DataMgr.SetNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_LUCKYUNBACK, 2)
    end
end

-------------------------------------------------------------------------

s2c = s2c or {};
s2c["get_lucky_draw_unback_activity_rsp"] = LuckyUnbackUI.get_lucky_draw_unback_activity_rsp;
s2c["do_one_draw_by_activity_rsp"] = LuckyUnbackUI.do_one_draw_by_activity_rsp;