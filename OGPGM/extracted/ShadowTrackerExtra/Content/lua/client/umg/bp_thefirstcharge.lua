TheFirstChargeUI = TheFirstChargeUI or
{
    IsUIShow = false,
    timer = nil,
}

BP_STRUCT_FirstCharge_BuyInfo = {
    itemId = 0, 
    num = 0,                
    orgin_price = 0,        --原始价格
    price = 0,              --实际价格
    total_recharged = 0,    --消费的UC
    status = 0,             --1未完成，2已完成，3已领取
    seasonIndex = 0,        --赛季索引
    process_f = 0,          --进度百分比
}

BP_STRUCT_FirstCharge_Award1 = {
    itemId = 0,
    num = 0,
    condUC = 0,         --领取需要消费的UC
    status = 0,          --状态，1未完成，2已完成，3已领取
}

BP_STRUCT_FirstCharge_Award2 = {
    itemId = 0,
    num = 0,
    condUC = 0,         --领取需要消费的UC
    status = 0,          --状态，1未完成，2已完成，3已领取
}

BP_FirstCharge_AwardIndex = 0;      --领奖index
BP_FirstCharge_SeasonTitle = "";    --赛季title
BP_FirstCharge_SeasonDesc1 = "";    --描述1
BP_FirstCharge_SeasonDesc2 = "";    --描述2

BP_FirstCharge_Buy_SeasonTime = "";  --赛季时间显示

function bp_thefirstcharge_RegisterUI()
	log("[TAL]== registerUI bp_thefirstcharge RegisterUI")
    LuaClassObj.SubUIWidgetList(bp_thefirstcharge,
                                {{Path="/Game/UMG/UI_Logic/TheFirstCharge/TheFirstCharge_BP.TheFirstCharge_BP_c", Container="Default", ZOrder=BP_ENUM_UI_THEFIRSTCHARGE_ZORDER}},
                                {"Lobby"},
                                false,
                                bp_thefirstcharge_OnModeSwitched ~= nil,
                                true);
    --EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CHANGE, TheFirstChargeUI.UpdateUI) 
end

 function TheFirstChargeUI.OnJumpUrl(eventType, eventID, vars)

	log("[TAL]== registerUI bp_thefirstcharge OnJumpUrl")

    TheFirstChargeUI.ShowUI();
 end

function TheFirstChargeUI.OnJumpUrlSeason()
    log("[TAL]== registerUI bp_thefirstcharge OnJumpUrlSeason")
    
    TheFirstChargeUI.ShowUI010();
end

 function TheFirstChargeUI.ShowUI()
 	log("[TAL]== registerUI bp_thefirstcharge ShowUI")
    TheFirstChargeUI.IsUIShow = true;
    LuaClassObj.HandleDynamicCreation(bp_thefirstcharge);

    TheFirstChargeUI.RefreshData();
    LuaClassObj.HandleUIMessage(bp_thefirstcharge, "UIShow"); 
    
end

function TheFirstChargeUI.ShowUI010()
    log("[TAL]== registerUI bp_thefirstcharge ShowUI010")

    TheFirstChargeUI.IsUIShow = true;
    LuaClassObj.HandleDynamicCreation(bp_thefirstcharge);
    
    --拉取数据
    ActivitySystem.get_season_recharge_info_req(false);
end

function TheFirstChargeUI.SetData()
    BP_STRUCT_FirstCharge_BuyInfo = {};
    BP_STRUCT_FirstCharge_Award1 = {};
    BP_STRUCT_FirstCharge_Award2 = {};
    if ActivitySystem.firstChargeInfo then
        if ActivitySystem.firstChargeInfo.show_info then
            BP_STRUCT_FirstCharge_BuyInfo.total_recharged = ActivitySystem.firstChargeInfo.total_recharged;
            BP_STRUCT_FirstCharge_BuyInfo.status = ActivitySystem.firstChargeInfo.bargain_status;
            BP_STRUCT_FirstCharge_BuyInfo.itemId = ActivitySystem.firstChargeInfo.show_info.bargain_id;
            BP_STRUCT_FirstCharge_BuyInfo.num = ActivitySystem.firstChargeInfo.show_info.bargain_num;
            BP_STRUCT_FirstCharge_BuyInfo.orgin_price = ActivitySystem.firstChargeInfo.show_info.bargain_orgin_price;
            BP_STRUCT_FirstCharge_BuyInfo.price = ActivitySystem.firstChargeInfo.show_info.bargain_price;
            BP_STRUCT_FirstCharge_BuyInfo.seasonIndex = ActivitySystem.firstChargeInfo.season_index;
        end
        if ActivitySystem.firstChargeInfo.award_status and ActivitySystem.firstChargeInfo.show_info.award then
            BP_STRUCT_FirstCharge_Award1.itemId = ActivitySystem.firstChargeInfo.show_info.award[1].id;
            BP_STRUCT_FirstCharge_Award1.num = ActivitySystem.firstChargeInfo.show_info.award[1].num;
            BP_STRUCT_FirstCharge_Award1.condUC = ActivitySystem.firstChargeInfo.show_info.award[1].cond;
            BP_STRUCT_FirstCharge_Award1.status = ActivitySystem.firstChargeInfo.award_status[1];

            BP_STRUCT_FirstCharge_Award2.itemId = ActivitySystem.firstChargeInfo.show_info.award[2].id;
            BP_STRUCT_FirstCharge_Award2.num = ActivitySystem.firstChargeInfo.show_info.award[2].num;
            BP_STRUCT_FirstCharge_Award2.condUC = ActivitySystem.firstChargeInfo.show_info.award[2].cond;
            BP_STRUCT_FirstCharge_Award2.status = ActivitySystem.firstChargeInfo.award_status[2];
        end
        if ActivitySystem.firstChargeInfo and BP_STRUCT_FirstCharge_Award2.condUC > 0 then
            BP_STRUCT_FirstCharge_BuyInfo.process_f = ActivitySystem.firstChargeInfo.total_recharged / BP_STRUCT_FirstCharge_Award2.condUC;
        end

    end
    if NewSubscribeSystem.GetIsPrimeOpen() == true then
        BP_FirstCharge_SeasonDesc1 = Client.GetTableData("LocalizeRes", "6358").TextValue;
    else
        BP_FirstCharge_SeasonDesc1 = "";
    end
    BP_FirstCharge_SeasonDesc2 = Client.GetTableData("LocalizeRes", "6359").TextValue;
    BP_FirstCharge_Buy_SeasonTime = "";
    if UnknowPassSystem.SeasonInfo and UnknowPassSystem.SeasonInfo.in_cur_season then
        if UnknowPassSystem.SeasonInfo.cfg then
            BP_FirstCharge_Buy_SeasonTime = UnknowPassSystem.SeasonInfo.cfg.show_time or "";
        end
    end
    TheFirstChargeUI.IsRegionJK()
    LuaClassObj.HandleUIMessage(bp_thefirstcharge, "UpdateInfo");
    LuaClassObj.HandleUIMessageNoFetch(bp_thefirstcharge, "UIShow010");

    UIManager.Show(eUIType.eTheFirstCharge);
end

function TheFirstChargeUI.UpdateUI()
    if not TheFirstChargeUI.IsUIShow then
        log("[TAL]TheFirstChargeUI.UpdateUI, IsUIShow == false!");
        return;
    end
    
    TheFirstChargeUI.RefreshData();
    LuaClassObj.HandleUIMessage(bp_thefirstcharge, "UIShow");
end

function EventTheFirstChargeHideUI()
    TheFirstChargeUI.IsUIShow = false;
    LuaClassObj.HandleUIMessage(bp_thefirstcharge, "Hide");
    UIManager.Hide(eUIType.eTheFirstCharge);
end

function EventTheFirstChargeUpdateUI()
    TheFirstChargeUI.UpdateUI();
end

function TheFirstChargeUI.ShouldSlap()
    log("[TAL]===判断首充打脸图时候弹出 TheFirstChargeUI.ShouldSlap");    
    return DataMgr.Recharge == 1;
end

-------------------------------------------------------------------------------------首充和折扣放在一起了
 -- 蓝图内按钮事件与显示依据,1表示首充, 2表示折扣购买
BP_Struct_TheFirstCharge_info = 
{
    handleFlag = 0, --0(首充、折扣皆已完成; 无活动数据), 1(显示首充功能), 2(首充完成,显示折扣功能)
    hasCharged = false, --是否首充过
    status = 0, --折扣是可购买  0不可购买 1可购买但未购买 2已购买
    actId = 0, --活动id   
    isJK = false, --是否为日韩版本
}

function TheFirstChargeUI.ResetData()
    BP_Struct_TheFirstCharge_info.handleFlag = 0;
    BP_Struct_TheFirstCharge_info.hasCharged = false;
    BP_Struct_TheFirstCharge_info.status = 0;
    BP_Struct_TheFirstCharge_info.actId = 0;
    BP_Struct_TheFirstCharge_info.isJK = false;
end

function TheFirstChargeUI.IsRegionJK()
    local region = Client.GetPublishRegion();
    if region == "JAPAN" or region == "KOREA" then
        BP_Struct_TheFirstCharge_info.isJK = true
    else
        BP_Struct_TheFirstCharge_info.isJK = false
    end
end

function TheFirstChargeUI.TestDate()
    BP_Struct_TheFirstCharge_info.handleFlag = 2;
    BP_Struct_TheFirstCharge_info.hasCharged = true;
    BP_Struct_TheFirstCharge_info.status = 2;
    BP_Struct_TheFirstCharge_info.actId = 0;
    BP_Struct_TheFirstCharge_info.isJK = true;
end

function TheFirstChargeUI.RefreshData()
    TheFirstChargeUI.ResetData();

    local actType = ActivityType["FIRST_RECHARGE_ADD"]; --44
    for _, activity in ipairs(DataMgr.activity.data) do
        if activity and activity.Type and activity.Type == actType then
            
            --log_tree("xzx TheFirstCharge activity:", activity)

            if activity.other and activity.other.is_first_recharge then
                BP_Struct_TheFirstCharge_info.hasCharged = activity.other.is_first_recharge;
            end

            if activity.ID then
                BP_Struct_TheFirstCharge_info.actId = activity.ID;
            end

            if activity.List and activity.List[1] then
                local info = activity.List[1]
                if info.Status then
                    log("xzx info.Status = "..info.Status)
                    BP_Struct_TheFirstCharge_info.status = info.Status
                end
            end
        end
    end

    TheFirstChargeUI.IsRegionJK()

    local info = BP_Struct_TheFirstCharge_info
    if info.actId == 0 or info.status == 2 then
        info.handleFlag = 0
    elseif info.hasCharged == false then
        info.handleFlag = 1
    elseif info.hasCharged == true then
        info.handleFlag = 2
    end

    --TheFirstChargeUI.TestDate();

    log_tree("xzx TheFirstChargeInfo:", BP_Struct_TheFirstCharge_info)
    return info.handleFlag;
end

function EventFirstChargeBuySKin()--购买皮肤事件
    if BP_Struct_TheFirstCharge_info.status == 0 then
        --do nothing 不会走到这一步
    elseif BP_Struct_TheFirstCharge_info.status == 1 then
        local strBuy = FuncUtil.GetLocalizeResStr("301185");
        local tip = FuncUtil.GetLocalizeResStr("301372");
        local content = FuncUtil.GetLocalizeResStr("5015")
        tip = FuncUtil.LocalizeResFormatByStr(tip, "180", content);
        CommonMessageBoxUI:ShowPanel(2, strBuy, tip, TheFirstChargeUI.BuySkin);

    elseif BP_Struct_TheFirstCharge_info.status == 2 then --按道理也不会走到这一步,为2的时候是没有入口的
        --PopUpNoticeUI.ShowNewNotice("已购买 枪械涂装:淬火-SCAR-L");
        local tip = Client.GetTableData("LocalizeRes", "4793").TextValue
        tip = tip..Client.GetTableData("LocalizeRes", "5015").TextValue

        PopUpNoticeUI.ShowNewNotice(tip);
    end
end

function TheFirstChargeUI.BuySkin() --购买皮肤协议
    local activityId = BP_Struct_TheFirstCharge_info.actId;
    if activityId ~= nil and activityId ~= 0 then
        MallSystem.HandleReqNum()
        NetUtil.SendPkg("activity_market_buy_req", activityId)  
    end
end

--首充后台通知更新
function TheFirstChargeUI.ChangedNotify(data)
    
    if data then
        if data.total_recharged then
            BP_STRUCT_FirstCharge_BuyInfo.total_recharged = data.total_recharged;
        end
        if data.award then
            if data.award[1] then
                BP_STRUCT_FirstCharge_Award1.status = data.award[1];
            end
            if data.award[2] then
                BP_STRUCT_FirstCharge_Award2.status = data.award[2];
            end
        end
        if data.bargain_status then
            BP_STRUCT_FirstCharge_BuyInfo.status = data.bargain_status;
        end
    end
    if TheFirstChargeUI.IsUIShow then
        log("[TAL]TheFirstChargeUI.ChangedNotify, IsUIShow == true!");
        LuaClassObj.HandleUIMessage(bp_thefirstcharge, "UpdateInfo");
    end
    TheFirstChargeUI.CheckFirstChargeRedDot();
    TheFirstChargeUI.CheckIsFinished();
end

--检查是否已经做完
function TheFirstChargeUI.CheckIsFinished()
    if ActivitySystem.firstChargeInfo and ActivitySystem.firstChargeInfo.award_status then
        if ActivitySystem.firstChargeInfo.bargain_status == 3 and ActivitySystem.firstChargeInfo.award_status[1] == 3 and ActivitySystem.firstChargeInfo.award_status[2] == 3 then
            LobbyUI.HandleTheFirstChargeHide();
        end
    end
end

--检查小红点提示
function TheFirstChargeUI.CheckFirstChargeRedDot()
    local redDot = false;
    if ActivitySystem.firstChargeInfo then
        if ActivitySystem.firstChargeInfo.bargain_status == 2 then
            redDot = true;
        end
        if ActivitySystem.firstChargeInfo.award_status then
            if ActivitySystem.firstChargeInfo.award_status[1] == 2 or ActivitySystem.firstChargeInfo.award_status[2] == 2 then
                redDot = true;
            end
        end
        if BP_STRUCT_FirstCharge_Award1.status == 2 or BP_STRUCT_FirstCharge_Award2.status == 2 or BP_STRUCT_FirstCharge_BuyInfo.status == 2 then
            redDot = true;
        end
        if ActivitySystem.firstChargeInfo.is_first_login then
            redDot = true;
        end
    end
    LobbyUI.HandleTheFirstChargeRedDot(redDot);
end

--设置所有都完成
function TheFirstChargeUI.SetAllDone()
    BP_STRUCT_FirstCharge_BuyInfo.status = 3;
    BP_STRUCT_FirstCharge_Award1.status = 3;
    BP_STRUCT_FirstCharge_Award2.status = 3;
    LuaClassObj.HandleUIMessage(bp_thefirstcharge, "UpdateInfo");
end

--设置活动开始倒计时 - 时间到了拉取数据，开启活动
function TheFirstChargeUI.SetOpenCountDown(data)
    --log("TheFirstChargeUI.SetOpenCountDown .." .. data);
    if TheFirstChargeUI.timer then
        Timer.RemoveTimer(TheFirstChargeUI.timer);
    end
    if data and data > 0 then
        local serverTime = FuncUtil.GetServerTimeInSec();
        if data > serverTime then
            TheFirstChargeUI.timer = Timer.InsertTimer(data - serverTime + 5, TheFirstChargeUI.get_season_recharge_info_req, false, true);
        end
    end
end

--拉取数据
function TheFirstChargeUI.get_season_recharge_info_req()
    log("TheFirstChargeUI.timer____send")
    --ActivitySystem.get_season_recharge_info_req(false);
    --改为时间到了自动打开并提示小红点，不拉取数据
    LobbyUI.HandleTheFirstChargeRedDot(true);
end

--首冲新增购买
function EventFirstChargeBuyClick()
    local strBuy = Client.GetTableData("LocalizeRes", "301185").TextValue;
    local itemCfg = Client.GetTableData("Item", BP_STRUCT_FirstCharge_BuyInfo.itemId);
    local tip;
    if itemCfg then
        if (BP_STRUCT_FirstCharge_BuyInfo.price <= DataMgr.ticket) then
            tip = FuncUtil.GetLocalizeResStr("301372");
        else
            tip = FuncUtil.GetLocalizeResStr("4826");
        end
        tip = FuncUtil.LocalizeResFormatByStr(tip, BP_STRUCT_FirstCharge_BuyInfo.price, itemCfg.ItemName);
        CommonMessageBoxUI:ShowPanel(2, strBuy, tip, function()
            if BP_STRUCT_FirstCharge_BuyInfo.price <= DataMgr.ticket then
                ActivitySystem.season_recharge_buy_req();
            else
                RechargeUI:Init();
            end
        end);
    else
        log("EventFirstChargeBuyClick itemCfg error");
    end
end
--充值跳转
function EventFirstChargePayClick()
    RechargeUI:Init();
end
--首冲领奖
function EventFirstChargeAwardClick()
    ActivitySystem.take_season_recharge_award_req(BP_FirstCharge_AwardIndex);
end

