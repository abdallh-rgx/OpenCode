--生化夺宝UI
BioChemicalUI = BioChemicalUI or
{
    isShow = false,
    bRedDot = false,
}

--错误类型枚举
ENUM_BIOCHEMICAL_ERR_CODE =
{
    success = 0,

    activity_errcode_activity_have_end = 108108,
    activity_errcode_param_error = 108109,
    activity_errcode_activity_not_exist = 108101,

    --生化夺宝活动
    biochemical_err_need_res_not_enough         = 502006,    --抽奖所需代币不够
    biochemical_err_pay_error                   = 995002,    --抽奖代币支付失败
    biochemical_err_voucher_not_exist           = 995003,    --代金券不存在
    biochemical_err_can_not_next_round          = 995004,    --代金券不足
}

--主推商品
BP_STRUCT_BioChemical_ItemInfo =
{
    itemId = 0,
    num = 0,
    hasGet = false,
    iconPath = "",
    oldUC = 0,
    saleUC = 0,
    name = "",
    itemQualityIcon = "",
    pos = 0,
}

BP_ARRAY_BioChemical_ItemInfo_List =
{
    BP_STRUCT_BioChemical_ItemInfo = _G.BP_STRUCT_BioChemical_ItemInfo;
}

BP_STRUCT_BioChemical_Voucher = 
{
    voucher_id = 0,
    price = 0,
    name = "",
}

BP_ARRAY_BioChemical_Voucher_List = 
{
    BP_STRUCT_BioChemical_Voucher = _G.BP_STRUCT_BioChemical_Voucher;
}

BP_BioChemical_Round_Count = 0          --第几轮夺宝
BP_BioChemical_Had_Draw_Count = 0       --已经刷新几次
BP_BioChemical_Cur_UC = 0               --现在的剩余UC
BP_BioChemical_RedPoint = true          --轮播图红点
BP_BioChemical_Had_Get_Last = false     --是否有获得最终大奖
BP_BioChemical_Price_List = {}          --价格列表
BP_BioChemical_Cur_Price = 0;           --当前的价格
BP_BioChemical_CurGetPos = 0;           --获得物品的位置
BP_BioChemical_CurVoucherPrice = 0;     --当前代金券金额
BP_BioChemical_CurVoucherId = 0;        --当前代金券id
BP_BioChemical_CurVoucherCount = 0;     --代金券总数
BP_BioChemical_TimePeriod = "";         --活动持续时间
local arrayItemList = {}

--注册Widget
function bp_biochemical_lucky_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_biochemical_lucky,
            {{Path="/Game/UMG/UI_Logic/Activty/Lobby_BioChemical_BP.Lobby_BioChemical_BP_C", Container="Default", ZOrder=60}},
            {"Lobby"},
            false,
            false,
            true
    );
end

--从入口进入
function BioChemicalUI.OpenFromUrl()
    log("BioChemicalUI.OpenFromUrl")
    BP_BioChemical_RedPoint = false;
    DataMgr.SetNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_LUCKYUNBACK, 1)
    BioChemicalUI.Show()
end

function BioChemicalUI.Init()

end

function BioChemicalUI.Release()
    log("BP_BioChemical_RedPoint.Release")
end

--展示界面
function BioChemicalUI.Show()
    --BioChemicalUI.GetVoucherList()
    NetUtil.SendPkg("get_biochemical_activity_data_req")
    LuaClassObj.HandleDynamicCreation(bp_biochemical_lucky);
    LuaClassObj.HandleUIMessage(bp_biochemical_lucky, "UIShow");
    AchievementFloatTipUI.BlockingPop = true
end

function EventBioChemicalUIClose()
    AchievementFloatTipUI.BlockingPop = false
end

--返回抵扣券专属道具id
function BioChemicalUI.GetVoucherItemId()
    return 1802015
end

--初始化红点
function BioChemicalUI.InitRedPoint()
    local NeedBioChemicalShow = DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_LUCKYUNBACK, 1);
    log("BioChemical Latest Banner "..tostring(NeedBioChemicalShow));
    BP_BioChemical_RedPoint = NeedBioChemicalShow
end

--刷新红点
function BioChemicalUI.UpdateRedPoint()
    --log("BP_BioChemical_RedPoint"..tostring(BP_BioChemical_RedPoint))
    if BioChemicalUI.bRedDot ~= BP_BioChemical_RedPoint then
        BioChemicalUI.bRedDot = BP_BioChemical_RedPoint
        LobbyUI:LobbyRedPointUpdate(BP_ENUM_MODULE_BIOCHEMICAL_LUCKY, BP_BioChemical_RedPoint)
    end
end

function BioChemicalUI.RefreshUI()
    BioChemicalUI.GetVoucherList()
    LuaClassObj.HandleUIMessage(bp_biochemical_lucky, "UIRefresh");
end

function BioChemicalUI.GetVoucherList()
    BP_ARRAY_BioChemical_Voucher_List = {}
    local voucherItem = {}
    local cacheItem = DataMgr.GetHallDepotItemDataByResIDAndValidExpireTime(BioChemicalUI.GetVoucherItemId())
    log_tree("cacheItem", cacheItem)
    if cacheItem ~= nil then
        voucherItem.voucher_id = cacheItem.resID
        voucherItem.price = 50
        voucherItem.name = Client.GetTableData("Item", cacheItem.resID).ItemName
        table.insert(BP_ARRAY_BioChemical_Voucher_List, voucherItem)

        BP_BioChemical_CurVoucherId = voucherItem.voucher_id
        BP_BioChemical_CurVoucherPrice = 50
        BP_BioChemical_CurVoucherCount = cacheItem.count
    else
        BP_BioChemical_CurVoucherId = -1
        BP_BioChemical_CurVoucherPrice = 0
        BP_BioChemical_CurVoucherCount = 0
    end
    log_tree("BP_ARRAY_BioChemical_Voucher_List", BP_ARRAY_BioChemical_Voucher_List)
end

--刷新全部商品状态
function BioChemicalUI.UpdateAllItem(lucky_draw_unback_cfg, had_draw_info)
    BP_ARRAY_BioChemical_ItemInfo_List = {}
    for k, v in pairs(lucky_draw_unback_cfg) do
        local luckyItem = {}
        luckyItem.itemId = k
        local cfg = Client.GetTableData("Item", luckyItem.itemId)
        if cfg then
            luckyItem.iconPath = cfg.ItemSmallIcon
            luckyItem.name = cfg.ItemName
            luckyItem.itemQualityIcon = "/Game/UMG/Texture/Atlas/ItemLevelUI/Frames/T_item_icon_quality_" ..tostring(cfg.ItemQuality - 1) .."_png.T_item_icon_quality_" ..tostring(cfg.ItemQuality - 1) .."_png"
        else
            luckyItem.iconPath = ""
            luckyItem.name = ""
            luckyItem.itemQualityIcon = ""
        end
        luckyItem.num = lucky_draw_unback_cfg[k].item_num
        luckyItem.pos = lucky_draw_unback_cfg[k].pos_id
        luckyItem.hasGet = false
        
        table.insert(BP_ARRAY_BioChemical_ItemInfo_List, luckyItem)
    end

    table.sort(BP_ARRAY_BioChemical_ItemInfo_List, function(a, b) return a.pos < b.pos end);
    for k, v in pairs(had_draw_info) do
        BP_ARRAY_BioChemical_ItemInfo_List[v.pos_id].hasGet = true
    end
    
    log_tree("BioChemicalUI.UpdateAllItem: ", BP_ARRAY_BioChemical_ItemInfo_List)
end

--拉取抽奖信息回包
function BioChemicalUI.get_biochemical_activity_data_rsp(res, lucky_draw_unback_cfg, lucky_draw_unback_price_cfg, self_biochemical_activity_data, start_time, end_time)
    log_tree("BioChemicalUI.get_biochemical_activity_data_rsp ", lucky_draw_unback_cfg)
    log("BioChemicalUI.get_biochemical_activity_data_rsp res"..tostring(res))
    if res ~= ENUM_BIOCHEMICAL_ERR_CODE.success then
        ShowNotice(res)
        return
    end
    if next(lucky_draw_unback_cfg) ~= nil then
        BioChemicalUI.UpdateAllItem(lucky_draw_unback_cfg, self_biochemical_activity_data.had_draw_info)
    end
    BP_BioChemical_Had_Draw_Count = self_biochemical_activity_data.had_draw_count
    BP_BioChemical_Had_Get_Last = self_biochemical_activity_data.had_get_last_award
    BP_BioChemical_Round_Count = self_biochemical_activity_data.cur_round_id
    BP_BioChemical_Cur_UC = DataMgr.ticket;
    BP_BioChemical_Price_List = lucky_draw_unback_price_cfg
    if BP_BioChemical_Had_Draw_Count < 10 then
        BP_BioChemical_Cur_Price = BP_BioChemical_Price_List[BP_BioChemical_Had_Draw_Count + 1].price
    end
    BP_BioChemical_TimePeriod = BioChemicalUI.GetTimePeriod(start_time, end_time)
    
    BioChemicalUI.RefreshUI();
end

function BioChemicalUI.GetTimePeriod(startTime, endTime)
    local startDate = os.date("!*t", startTime);
    local endDate = os.date("!*t", endTime);
    
    local startTimeString = string.format("%d.%d.%d", startDate.year, startDate.month, startDate.day)
    local endTimeString = string.format("%d.%d.%d", endDate.year, endDate.month, endDate.day)

    return FuncUtil.LocalizeResFormat("6515", startTimeString, endTimeString)
end

--用于同步BP变量到蓝图
function EventBioChemicalFetchInfo()
    
end

--点击抽奖按钮
function EventBioChemicalExchangeClick()
    log("EventBioChemicalExchangeClick"..BP_BioChemical_Round_Count..BP_BioChemical_Had_Draw_Count..BP_BioChemical_CurVoucherId)
    if BP_BioChemical_CurVoucherId == -1 then
        NetUtil.SendPriorityPkg(false, "do_biochemical_activity_one_draw_rsp", "do_biochemical_activity_one_draw_req", BP_BioChemical_Round_Count, BP_BioChemical_Had_Draw_Count)
    else
        NetUtil.SendPriorityPkg(false, "do_biochemical_activity_one_draw_rsp", "do_biochemical_activity_one_draw_req", BP_BioChemical_Round_Count, BP_BioChemical_Had_Draw_Count, BP_BioChemical_CurVoucherId)
    end
end

--抽奖结果的回包
function BioChemicalUI.do_biochemical_activity_one_draw_rsp(res, self_biochemical_activity_data, award_info)
    if res ~= ENUM_BIOCHEMICAL_ERR_CODE.success then
        ShowNotice(res)
            if res == ENUM_BIOCHEMICAL_ERR_CODE.biochemical_err_need_res_not_enough then
                local title = Client.GetTableData("LocalizeRes", "101001").TextValue;
                local tip = Client.GetTableData("LocalizeRes", "4119").TextValue;
                CommonMessageBoxUI:ShowPanel(2, title, tip, function()
                    RechargeUI:Init();
                    return true;
                end);
            end
    else
        log_tree("BioChemicalUI.do_biochemical_activity_one_draw_rsp", self_biochemical_activity_data)
        log_tree("BioChemicalUI.do_biochemical_activity_one_draw_rsp award_info", award_info)
        
        arrayItemList = {}
        local arrayItem = {}
        arrayItem.res_id = award_info.resid
        arrayItem.expire_ts = 0
        arrayItem.valid_hours = 0
        arrayItem.count = award_info.count
        table.insert(arrayItemList, arrayItem)
        --CommonItemGetUI:ShowPanel(arrayItemList)
        BP_BioChemical_CurGetPos = award_info.pos_id
        
        for k, v in pairs(self_biochemical_activity_data.had_draw_info) do
            BP_ARRAY_BioChemical_ItemInfo_List[v.pos_id].hasGet = true
        end

        BP_BioChemical_Had_Draw_Count = self_biochemical_activity_data.had_draw_count
        BP_BioChemical_Had_Get_Last = self_biochemical_activity_data.had_get_last_award
        BP_BioChemical_Round_Count = self_biochemical_activity_data.cur_round_id
        BP_BioChemical_Cur_UC = DataMgr.ticket;
        if BP_BioChemical_Had_Draw_Count < 10 then
            BP_BioChemical_Cur_Price = BP_BioChemical_Price_List[BP_BioChemical_Had_Draw_Count + 1].price 
        end
        
        LuaClassObj.HandleUIMessageNoFetch(bp_biochemical_lucky, "PlayAnim");
        --log_tree("BioChemicalUI.do_biochemical_activity_one_draw_rsp: ", BP_ARRAY_BioChemical_ItemInfo_List)
    end
end

--延迟展示物品掉落并刷新界面
function EventBioChemicalShowGet()
    CommonItemGetUI:ShowPanel(arrayItemList)
    BioChemicalUI.RefreshUI();
end

--当前的UC
function EventBioChemicalGetCurUC()
    BP_BioChemical_Cur_UC = DataMgr.ticket;
    LuaClassObj.HandleUIMessage(bp_biochemical_lucky, "SetMoney");
end

--展示活动规则
function EventBioChemicalShowRule()
    log("EventBioChemicalShowRule");
    local title = Client.GetTableData("LocalizeRes", 4726).TextValue
    local content = Client.GetTableData("LocalizeRes", 6512).TextValue
    PopUpNoticeUI.ShowMessageBox(title, content);
end

--展示概率公示
function EventBioChemicalShowRate()
    log("EventBioChemicalShowRate");
    EventPVERateUIShow()
end


-------------------------------------------------------------------------

s2c = s2c or {};
s2c["get_biochemical_activity_data_rsp"] = BioChemicalUI.get_biochemical_activity_data_rsp;
s2c["do_biochemical_activity_one_draw_rsp"] = BioChemicalUI.do_biochemical_activity_one_draw_rsp;