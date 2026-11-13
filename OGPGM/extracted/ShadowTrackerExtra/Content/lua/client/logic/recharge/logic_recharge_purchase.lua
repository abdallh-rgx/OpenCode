
--[[
 充值直购相关逻辑
]]--

RechargePurchaseSystem = RechargePurchaseSystem or
{
    purchase_type_uc = 2;
    purchase_type_cash = 10;
    purchase_save_string = "RechargePurchaseSave";
}
RechargePurchaseSystem.dropList = {};
RechargePurchaseSystem.SelectedNumber = 0;--当前选择的item购买数量
RechargePurchaseSystem.SelectedRechargeInfo = {};--当前选择/正在购买的item信息
RechargePurchaseSystem.RechargeInfoList ={};--存储充值直购的信息，无序
RechargePurchaseSystem.RechargeInfoArray ={};--有序数组
RechargePurchaseSystem.ChestInfoList = {};
RechargePurchaseSystem.NeedShowRedDot = false;

RechargePurchaseSystem.SelectedId = 0;--选择的活动id，仅用于刷新选择数据

local DirectPurchaseItemList = {};
local RedDotInfoList = {};
--[[
	activityId = 0,--对应的活动id
    packId = 0,--礼包id (直购为直购礼包表的id，UC为掉落方案表的宝箱id)
    itemId = 0,--物品id 实际礼包的id
    num = 0, --总共可购买数量
    leftnum = 0, --剩余可购买数量
    index = 0,
    price = 0,
    name = "",
    iconPath = "",
    purchaseType = 0,--购买类型，2为现金，10为UC，见上述purchase_type定义
    tag = 0,--标记类型，0为无标记，1为new，2为hot
    startTime = 0,--上架时间
    endTime = 0,--结束时间
    rateUrl = "",--跳转的概率链接，为空则不显示
  	purchaseInfo =  --现金直购信息
  	{
  		midasProductId = 0,
		midasPayItem = 0,
		midasPrice = 0,
		midasCountry,
		midasCurrency,
  	}
]]
--活动类型 ACTIVITY_TYPE_KRJP_PURCHASE

function RechargePurchaseSystem.Enter()
    EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CHANGE, RechargePurchaseSystem.RefreshActivityInfo)
    --EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CR, Direct_Purchase_By_Ativity_UI.HideUI);
    --EventSystem:registEvent(EVENTTYPE_MIDAS_NOTIFY, EVENTID_MIDAS_GET_GOODS_PRODUCT_INFO_NOTIFY, Direct_Purchase_By_Ativity_UI.RefreshMidasProductInfo);
end

function RechargePurchaseSystem.RefreshActivityInfo(eventType, eventID, changeList)
    if changeList.typeList[ActivityType.ACTIVITY_TYPE_KRJP_PURCHASE] == true then
        log_tree("RechargePurchaseSystem.RefreshActivityInfo Purchase Info Changes!");

        DirectPurchaseItemList = {};
        for _, activity in ipairs(DataMgr.activity.data) do
            if tonumber(activity.Type) == ActivityType.ACTIVITY_TYPE_KRJP_PURCHASE then
                RechargePurchaseSystem.ConvertActDataToPurchaseInfo(activity);
            end
        end
        if #DirectPurchaseItemList ~= 0 then
            RechargePurchaseSystem.GetPurchaseInfoReq(DirectPurchaseItemList);
        else
            RechargePurchaseSystem.SortRechargeInfoList()
        end
        --刷新小红点信息
        RechargePurchaseSystem.LoadRechargePurchaseInfo();
    end
end

--计算活动持续时间
function RechargePurchaseSystem.GetTimePeriod(startTime, endTime)
	local startDate = os.date("!*t", startTime);
	local endDate = os.date("!*t", endTime);

	local startTimeString = string.format("%d.%d.%d", startDate.year, startDate.month, startDate.day)
	local endTimeString = string.format("%d.%d.%d", endDate.year, endDate.month, endDate.day)

	return string.format("%s-%s", startTimeString, endTimeString)
end

--根据活动数据生成直购数据
--1 直购为直购礼包表的id，UC为掉落方案表的唯一id | 2-购买方式（0为现金，1为UC） | 3-限购数量 | 4-价格 | 5-保留字段
function RechargePurchaseSystem.ConvertActDataToPurchaseInfo(actData)
    log_tree("RechargePurchaseSystem.ConvertActDataToPurchaseInfo", actData)
    local info = actData.Condition;
    local recommendItem = {}
    local tmpcond = StrSplit(info, ",")

    --活动已过期，则不再加入List，并剔除原有list中的对应项
    if actData.EndTime <= NetUtil.GetCurServerTime() then
        log_error("RechargePurchaseSystem.ConvertActDataToPurchaseInfo timeout!!! activityid : ".. actData.ID);
        if RechargePurchaseSystem.RechargeInfoList[actData.ID] ~= nil then
            RechargePurchaseSystem.RechargeInfoList[actData.ID] = nil
            return;
        end
    end

    recommendItem.packId = tonumber(tmpcond[1])
    recommendItem.purchaseType = tonumber(tmpcond[2])
    
    if recommendItem.purchaseType ~= RechargePurchaseSystem.purchase_type_uc and recommendItem.purchaseType~= RechargePurchaseSystem.purchase_type_cash then
        log_error("RechargePurchaseSystem.ConvertActDataToPurchaseInfo type Error!! activityid :".. actData.ID .. "|| type : " .. recommendItem.purchaseType);
        return;
    end
    
    if recommendItem.purchaseType == RechargePurchaseSystem.purchase_type_uc then
        local chestItemId = recommendItem.packId;
        recommendItem.itemId = chestItemId;
        if chestItemId ~= 0 then
            local cfg = Client.GetTableData("Item", chestItemId)
            if cfg then
                recommendItem.name = cfg.ItemName
            else
                recommendItem.name = ""
            end
        end
    elseif recommendItem.purchaseType == RechargePurchaseSystem.purchase_type_cash then
        table.insert(DirectPurchaseItemList,recommendItem.packId);
    end
    recommendItem.iconPath = actData.ImgUrl or "";
    recommendItem.rateUrl = actData.ImgLink or "";
	recommendItem.num = tonumber(tmpcond[3])
	if actData.other and next(actData.other) ~= nil then
		recommendItem.leftnum = recommendItem.num - actData.other.times
	else
		recommendItem.leftnum = recommendItem.num
	end
	recommendItem.price = tonumber(tmpcond[4])
	recommendItem.startTime = actData.StartTime;
	recommendItem.endTime = actData.EndTime;
	recommendItem.activityId = actData.ID;
    
    --标记类型，0为无标记，1为new，2为hot
    if actData.LabelType == 1 then
        recommendItem.tag = 2
    elseif actData.LabelType == 5 then
        recommendItem.tag = 1
    else
        recommendItem.tag = 0
    end
    
    if RechargePurchaseSystem.RechargeInfoList == nil then
        RechargePurchaseSystem.RechargeInfoList = {};
    end
	RechargePurchaseSystem.RechargeInfoList[actData.ID] = recommendItem;
	--log_tree("RechargeInfoList", RechargeInfoList)
end

--读取本地存储的直购信息
function RechargePurchaseSystem.LoadRechargePurchaseInfo()
    log("RechargePurchaseSystem.LoadRechargePurchaseInfo");
    local gameplayStatics = import("GamePlayStatics");
    local saveString = RechargePurchaseSystem.purchase_save_string .. "_" .. DataMgr.roleData.uid;
    if gameplayStatics.DoesSaveGameExist(saveString,0) then
        local SaveInfo = gameplayStatics.LoadGameFromSlot(saveString,0);
        if SaveInfo == nil then
            log_error("RechargePurchaseSystem.LoadRechargePurchaseInfo SaveInfo is null!!!");
            return
        end
        RedDotInfoList = {};
        for i = 0, SaveInfo.PurchaseRedDotList:Num() - 1 do
            RedDotInfoList[SaveInfo.PurchaseRedDotList:Get(i)] = 1;
        end
        log_tree("RechargePurchaseSystem.LoadRechargePurchaseInfo RedDotInfoList :",RedDotInfoList);
    else
        RedDotInfoList = {};
    end
    RechargePurchaseSystem.CheckNeedShowRedDot()
end

--将直购信息存储至本地
function RechargePurchaseSystem.SaveRechargePurchaseInfo()
    local gameplayStatics = import("GamePlayStatics");
    local saveString = RechargePurchaseSystem.purchase_save_string .. "_" .. DataMgr.roleData.uid;
    local classSettingConfig = slua.loadClass("/Game/UMG/UI_Logic/Recharge/RechargeSave.RechargeSave")
    if classSettingConfig == nil then
        log_error("RechargePurchaseSystem.SaveRechargePurchaseInfo classSettingConfig is null!!");
        return;
    end
    
    local saveGameObject = gameplayStatics.CreateSaveGameObject(classSettingConfig)
    if saveGameObject == nil then
        log_error("RechargePurchaseSystem.SaveRechargePurchaseInfo saveGameObject is null!!");
        return;
    end
    
    local redDotBPArray = slua.Array(UEnums.EPropertyClass.Int)
    for i,j in pairs(RedDotInfoList) do
        redDotBPArray:Add(i);
    end
    
    saveGameObject:SetRedDotInfoList(redDotBPArray);
    local result = gameplayStatics.SaveGameToSlot(saveGameObject, saveString, 0);
    log("RechargePurchaseSystem.SaveRechargePurchaseInfo result : " .. tostring(result));
end

--检查是否需要显示小红点
function RechargePurchaseSystem.CheckNeedShowRedDot()
    log("RechargePurchaseSystem.CheckNeedShowRedDot");
    for key,info in pairs(RechargePurchaseSystem.RechargeInfoList) do
        --假如存在没有收录到红点列表的活动，说明这个活动没有被用户点击看到过
        if RedDotInfoList[info.activityId] == nil then
            RechargePurchaseSystem.NeedShowRedDot = true
            return;
        end
    end
    RechargePurchaseSystem.NeedShowRedDot = false;
end

--每次点击进界面时都会刷新红点信息，并保存至本地
function RechargePurchaseSystem.RefreshRedDotInfo()
    log("RechargePurchaseSystem.RefreshRedDotInfo NeedShowRedDot : " .. tostring(RechargePurchaseSystem.NeedShowRedDot));
    RechargePurchaseSystem.CheckNeedShowRedDot();
    --无红点无需更新
    if RechargePurchaseSystem.NeedShowRedDot == false then
        return;
    end
    RechargePurchaseSystem.NeedShowRedDot = true;
    for key,info in pairs(RechargePurchaseSystem.RechargeInfoList) do
        if RedDotInfoList == nil then
            RedDotInfoList = {};
        end
        RedDotInfoList[info.activityId] = 1;
    end
    RechargePurchaseSystem.SaveRechargePurchaseInfo();
end

--排序，规则为(1.NEW > HOT > 普通 > 售完 2.限时短到长，非限时在最后 3.上架时间新到旧)
function RechargePurchaseSystem.SortRechargeInfoList()
	RechargePurchaseSystem.RechargeInfoArray = {};
	for k, v in pairs(RechargePurchaseSystem.RechargeInfoList) do
        --剔除现金直购中没有收到后台回包的数据
        if v.purchaseType == 10 and (v.purchaseInfo == nil or v.purchaseInfo == {}) then
            log("RechargePurchaseSystem.SortRechargeInfoList purchaseInfo is null ,id = " .. v.activityId);
        else
            table.insert(RechargePurchaseSystem.RechargeInfoArray,v)
        end
	end

    log_tree("RechargePurchaseSystem.SortRechargeInfoList before :",RechargePurchaseSystem.RechargeInfoArray);
    
	table.sort(RechargePurchaseSystem.RechargeInfoArray,function(a,b)
        if a.activityId == b.activityId then
            return false;
        end

        local a_tagScore = a.tag;
        local b_tagScore = b.tag;
        if a_tagScore == 0 then
            a_tagScore = 3
        end
        if b_tagScore == 0 then
            b_tagScore = 3
        end
        if a_tagScore ~= b_tagScore then
            return a_tagScore< b_tagScore;
        end
        
		local a_soldout = (a.leftnum == 0);
		local b_soldout = (b.leftnum == 0);
		if a_soldout ~= b_soldout then
			return not a_soldout;
		end
        
		if a.endTime ~= b.endTime then
			return a.endTime < b.endTime;
		end
		
		return a.startTime > b.startTime;
	end)
	log_tree("RechargePurchaseSystem.SortRechargeInfoList :",RechargePurchaseSystem.RechargeInfoArray);

    --由于数据顺序会变化，通过activityId查找并刷新已选择的数据
    if RechargePurchaseSystem.SelectedId ~= 0 then
        for i,info in pairs(RechargePurchaseSystem.RechargeInfoList) do
            if info.activityId == RechargePurchaseSystem.SelectedId then
                RechargePurchaseSystem.SelectedRechargeInfo = info;
                break;
            end
        end
    end

    EventSystem:postEvent(EVENTTYPE_RECHARGE, EVENTID_RECHARGE_PURCHASE_INFO_CHANGE)
end

--获取直购预检信息
function RechargePurchaseSystem.GetBuyPreCheckReq(acitivityId)
    log("RechargePurchaseSystem.GetBuyPrecheckReq acitivityId : " .. acitivityId);
    --此处播放缓冲圈
    ConnectionWaitingUI:Show();
    
    local funcHide = function() ConnectionWaitingUI:Hide() end
    Timer.InsertTimer(3, funcHide, false, false)
    
    NetUtil.SendPkg("direct_buy_pre_check",acitivityId);
end

--获取直购预检信息|回包
function RechargePurchaseSystem.GetBuyPrecheckRsp(res, activityId)
    log("RechargePurchaseSystem.GetBuyPrecheckRsp res : " .. res .. ",activityId:" .. tostring(activityId));
    if res ~= "ok" then
        --取消缓冲区圈，弹出错误提示
        log_error("RechargePurchaseSystem.GetBuyPrecheckRsp error!");
        ConnectionWaitingUI:Hide()
        return;
    end
    ConnectionWaitingUI:Hide()

    if Direct_Purchase_By_Ativity_UI.activityId == activityId then
        Direct_Purchase_By_Ativity_UI.MidasGoods()
    else
        --成功则进行实际的购买流程
        if RechargePurchaseSystem.SelectedRechargeInfo == nil or RechargePurchaseSystem.SelectedRechargeInfo.purchaseInfo == nil then
            log_error("RechargePurchaseSystem.GetBuyPrecheckRsp info is null!!");
            PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", "301270").TextValue);
            return;
        end
        local info = RechargePurchaseSystem.SelectedRechargeInfo.purchaseInfo;
        log_tree("RechargePurchaseSystem.GetBuyPrecheckRsp MidasGood Info:",info);
        Client.MidasGoods(info.midasProductId,
                info.midasPayItem,
                info.midasPrice,
                info.midasCountry,
                info.midasCurrency);
        --直购回调是否隐藏缓冲条存疑
    end
end

--所有购买按钮的通用封装接口，购买直接调用此接口即可
function RechargePurchaseSystem.PurchaseSelectedItem()
    log_tree("RechargePurchaseSystem.PurchaseItemByMoney itemInfo",RechargePurchaseSystem.SelectedRechargeInfo);
    local info = RechargePurchaseSystem.SelectedRechargeInfo;
    if RechargePurchaseSystem.SelectedRechargeInfo == nil or RechargePurchaseSystem.SelectedRechargeInfo.activityId == nil or RechargePurchaseSystem.SelectedRechargeInfo.activityId == 0 then
        log_error("RechargePurchaseSystem.PurchaseSelectedItem info null!!");
        return;
    end

    --数量为0
    if RechargePurchaseSystem.SelectedRechargeInfo.num ~= 0 and RechargePurchaseSystem.SelectedRechargeInfo.leftnum == 0 then
        PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", "4990").TextValue);
        return;
    end

    --数量超出
    if RechargePurchaseSystem.SelectedNumber == 0 or RechargePurchaseSystem.SelectedNumber > RechargePurchaseSystem.SelectedRechargeInfo.leftnum then
        PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", "301270").TextValue);
        return;
    end

    --已过期
    if info.endTime < NetUtil.GetCurServerTime() then
        PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", "433013").TextValue);
    end

    local strBuy = Client.GetTableData("LocalizeRes", "301185").TextValue;--购买
    local itemName = RechargePurchaseSystem.SelectedRechargeInfo.name;  --4576  {0}个等级 ， 4577 {0}个积分
    local price = RechargePurchaseSystem.SelectedRechargeInfo.price * RechargePurchaseSystem.SelectedNumber;
    local tip;
    if RechargePurchaseSystem.SelectedRechargeInfo.purchaseType == RechargePurchaseSystem.purchase_type_uc then
        --UC
        tip = FuncUtil.LocalizeResFormat(301372, price , itemName)
    elseif RechargePurchaseSystem.SelectedRechargeInfo.purchaseType == RechargePurchaseSystem.purchase_type_cash then
        --现金
        tip = FuncUtil.LocalizeResFormat(6393, "₩" .. price, itemName);
    end
    
    CommonMessageBoxUI:ShowPanel(2, strBuy, tip, function()
        if RechargePurchaseSystem.SelectedRechargeInfo.purchaseType == RechargePurchaseSystem.purchase_type_cash then
            RechargePurchaseSystem.PurchaseItemByMoney()
        elseif RechargePurchaseSystem.SelectedRechargeInfo.purchaseType == RechargePurchaseSystem.purchase_type_uc then
            RechargePurchaseSystem.PurchaseItemByUC()
        end
    end
    )

end

--使用现金购买当前选中商品
function RechargePurchaseSystem.PurchaseItemByMoney()
    RechargePurchaseSystem.GetBuyPreCheckReq(RechargePurchaseSystem.SelectedRechargeInfo.activityId);
end

--使用UC购买当前选中商品
function RechargePurchaseSystem.PurchaseItemByUC()
    if RechargePurchaseSystem.SelectedNumber <= 0 then
        log("RechargePurchaseSystem.PurchaseItemByUC number is 0!");
        return;
    end
    log("RechargePurchaseSystem.PurchaseItemByUC activityid : " .. RechargePurchaseSystem.SelectedRechargeInfo.activityId .. "|| buyNumber : " .. RechargePurchaseSystem.SelectedNumber);
    NetUtil.SendPkg("unified_purchase",RechargePurchaseSystem.SelectedRechargeInfo.activityId,RechargePurchaseSystem.SelectedNumber);
end

--使用UC购买当前选中商品|回包
function RechargePurchaseSystem.PurchaseItemByUCRsp(res)
    log("RechargePurchaseSystem.PurchaseItemByUCRsp");
    if res ~= "ok" then
        if ENUM_DISCOUNT_FEVER_ERR_CODE[res] ~= nil then
            ShowNotice(ENUM_DISCOUNT_FEVER_ERR_CODE[res])
        end
        log_error("RechargePurchaseSystem.PurchaseItemByUCRsp error! res : " .. res);
        return;
    end
end
--获取直购信息
function RechargePurchaseSystem.GetPurchaseInfoReq(reqList)
    log_tree("RechargePurchaseSystem.GetPurchaseInfoReq :",reqList);
    NetUtil.SendPkg("batch_query_direct_buy_info",reqList);
end

--获取直购信息|回包
function RechargePurchaseSystem.GetPurchaseInfoRsp(res,list)
    log("RechargePurchaseSystem.GetPurchaseInfoRsp res : " .. res);
    if res ~= "ok" then
        return;
    end
    log_tree("RechargePurchaseSystem.GetPurchaseInfoRsp list : ", list);
    
    for k,v in pairs(list) do
        local rechargeInfo = {};
        for i,tInfo in pairs(RechargePurchaseSystem.RechargeInfoList)do
            if k == tInfo.packId then
                rechargeInfo = tInfo;
            end
        end
        if rechargeInfo ~= {} then
            local tPurchaseInfo = {};

            tPurchaseInfo.midasProductId = v.productid;
            tPurchaseInfo.midasCountry = v.country;
            tPurchaseInfo.midasCurrency = v.curency_unit;
            tPurchaseInfo.midasPrice = v.midasPrice;
            tPurchaseInfo.midasPayItem = v.payItem;
            --tPurchaseInfo.item_id = v.item_id;

            tPurchaseInfo.rewardItems = {};
            if v.parm2 and v.parm2 ~= "" then
                -- 充值返的UC
                local returnUC = MallSystem.ParseDirectPurchaseParam(v.parm2);
                if returnUC > 0 then
                    tPurchaseInfo.rewardItems[1] = { itemId = 1006, itemNum = returnUC};
                end
            end
            for index, item in ipairs(v.item_content) do
                tPurchaseInfo.rewardItems[#tPurchaseInfo.rewardItems+1] =
                {itemId = item.DropItemID, itemNum = item.DropItemNum};
            end

            tPurchaseInfo.configPrice = v.price;
            tPurchaseInfo.productPriceDesc = MidasManager.GetPriceByProductId(tPurchaseInfo.midasProductId,
                    tPurchaseInfo.midasCurrency,
                    "", true);

            rechargeInfo.purchaseInfo = tPurchaseInfo;
            rechargeInfo.itemId = v.item_id;
            if v.item_id ~= 0 then
                local cfg = Client.GetTableData("Item", v.item_id)
                if cfg then
                    rechargeInfo.name = cfg.ItemName
                else
                    rechargeInfo.name = ""
                end
            end
        end
    end
    
    RechargePurchaseSystem.SortRechargeInfoList()
end

-- 请求礼包内容数据(id为宝箱表的宝箱id)
function RechargePurchaseSystem.GetSelectedChestInfo()
    if RechargePurchaseSystem.SelectedRechargeInfo == nil then
        log_error("RechargePurchaseSystem.GetSelectedChestInfo info is null");
        return;
    end
    local chestId = RechargePurchaseSystem.SelectedRechargeInfo.itemId;
    if RechargePurchaseSystem.ChestInfoList[chestId] ~= nil then
        EventSystem:postEvent(EVENTTYPE_RECHARGE, EVENTID_RECHARGE_GET_CHEST_INFO, RechargePurchaseSystem.ChestInfoList[chestId]);
    else
        RechargePurchaseSystem.get_content_by_chestid(chestId);
    end
end


-- 请求礼包内容数据
function RechargePurchaseSystem.GetChestInfo(chestId)
    if RechargePurchaseSystem.ChestInfoList[chestId] ~= nil then
        EventSystem:postEvent(EVENTTYPE_RECHARGE, EVENTID_RECHARGE_GET_CHEST_INFO, RechargePurchaseSystem.ChestInfoList[chestId]);
    else
        RechargePurchaseSystem.get_content_by_chestid(chestId);
    end
end

-- 请求礼包内容数据
function RechargePurchaseSystem.get_content_by_chestid(chestId)
    log("RechargePurchaseSystem.get_content_by_chestid id = " .. chestId);
    NetUtil.SendPriorityPkg(false, "get_content_by_chestid_rsp", "get_content_by_chestid", chestId)
end

-- 礼包内容数据回包，data结构与label_shop_index_item_list对应的table相同
function RechargePurchaseSystem.get_content_by_chestid_rsp(res, data, chestId)
    if res ~= "ok" then
        log_error("RechargePurchaseSystem.get_market_chest_info_rsp error reason : " .. res);
        return;
    end
    log_tree("RechargePurchaseSystem.get_content_by_chestid_rsp",data);
    RechargePurchaseSystem.ChestInfoList[chestId] = data;
    EventSystem:postEvent(EVENTTYPE_RECHARGE, EVENTID_RECHARGE_GET_CHEST_INFO, data);
end

--[[网络回调]]--
s2c["batch_query_direct_buy_info_rsp"] = RechargePurchaseSystem.GetPurchaseInfoRsp --批量请求直购信息回包
s2c["direct_buy_pre_check_rsp"] = RechargePurchaseSystem.GetBuyPrecheckRsp --直购检查回包
s2c["unified_purchase_rsp"] = RechargePurchaseSystem.PurchaseItemByUCRsp --UC购买成功回包
s2c["get_content_by_chestid_rsp"] = RechargePurchaseSystem.get_content_by_chestid_rsp;--获取礼包内容信息回包
