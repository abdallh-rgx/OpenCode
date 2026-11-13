RechargeUI = RechargeUI or
{
   isShowing = false;
   isInit = false;
   isLoadMiadsMP = false;


   isConfigRecharge = false;
   zoneId = 1;
   country = "US";
   monetaryUint = "USD";

   --解析表数据获得，键值对，productId为key，buynum为值，
   productId_buynum_array = {};
   productId_str = "";

   isLoadingMP = false;
   isLoadingProductInfo = false;
   
   rechargePayPos = "300";     --默认档位4.99
   rechargeMaxIndex = 6;        --index = 6
   rechargeItemWidth = 240;     --目前一个UI的宽度240
}

BP_Recharge_To_Lobby = 0;
BP_Recharge_Has_ProduceInfo = false;

-- 判断日本版本是否需要年龄设置
BP_Recharge_Need_Set_Age = false;

-- 日本版本当前年龄，默认值20岁，不限额
BP_Recharge_JPAge = 20;

BP_STRUCT_Recharge_ItemInfo =
{
	rechargeId = 0,
    zoneId = 0,
	rechargeKey = "",
	name = "",
	buyNum = "",
	money = "",
	monetaryUint = "",
	monetarySymbol = "",
    country = "";
    icon = "",
};

------------------------------------------------------------------
--赠送货币数据 PayNumList 为key，PayPresentList为Value
BP_ARRAY_Recharge_PayNumList =
{
    Recharge_PayNum = 0;
};

BP_ARRAY_Recharge_PayPresentList =
{
    Recharge_PayPresent = 0;
};
------------------------------------------------------------------

------------------------------------------------------------------
--midas的价格数据 MoneyKeyList 为key，MoneyList为Value
BP_ARRAY_Recharge_MoneyKeyList =
{
    Recharge_Moneykey = 0;
};

BP_ARRAY_Recharge_MoneyList =
{
    Recharge_Money = "";
};
------------------------------------------------------------------
--热卖标记
BP_ARRAY_Recharge_HotList =
{
    Recharge_Hot = 0;
}

--超值标记
BP_ARRAY_Recharge_CheapList =
{
    Recharge_Cheap = 0;
}

--物品信息列表(定义结构体数组：当且仅当以BP_ARRAY_开头的table能作为数组给蓝图访问)
BP_ARRAY_Recharge_DataList =
{
	BP_STRUCT_Recharge_ItemInfo=_G.BP_STRUCT_Recharge_ItemInfo, --定义结构体数组，这种写法要作为规范规定下来
};

-- 当前正在充值的rechargeID
BP_Current_RechargeID = 0;
-- 当前正在充值的rechargeIndex
BP_Current_RechargeIndex = 0;

--Midas缓存的运营活动是否过期
BP_Recharge_Midas_CachedMPInfo_Expired= true;
--Midas缓存的商品价格是否过期
BP_Recharge_Midas_CachedProductInfo_Expired= true;

--设置scroll box
BP_Recharge_ScrollBox_Offset_f = 0;

--购买的档位
BP_Recharge_Buy_PosForSave = "";

--设置当前的高亮显示
BP_Recharge_Current_HighLightShow = 0;

-- 订阅是否开启
BP_Recharge_SubscribeSystem_IsPrimeOpen = false;

--订阅状态  0未订阅 1已经订阅
BP_Recharge_SubscribeStatus = 0;

--是否已经完成当天兑换 false没完成 true 已经完成
BP_Recharge_Subscribe_IsExchange = false;

--显示“购买”或者订阅价格
BP_Recharge_Subscribe_BuyOrPrice = "";

BP_Recharge_Player_Cur_Ticket = 0;

function bp_recharge_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_recharge,
	  {{Path="/Game/UMG/UI_Logic/Recharge/Recharge_BP.Recharge_BP_C", Container="Default", ZOrder=BP_ENUM_UI_RECHARGE_ZORDER+5}},
	  {"Lobby"},
      false,
      true,
      true
	);

    StarterPackSystem.Init();

    EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_RECHARGE, RechargeUI.OnJumpUrl);
    EventSystem:registEvent(EVENTTYPE_MIDAS_NOTIFY, EVENTID_MIDAS_PAY_NOTIFY,RechargeUI.MidasPayBackEventHandler);
    EventSystem:registEvent(EVENTTYPE_MIDAS_NOTIFY, EVENTID_MIDAS_GETMPINFO_NOTIFY, RechargeUI.MidasMPEventHandler);
    EventSystem:registEvent(EVENTTYPE_MIDAS_NOTIFY, EVENTID_MIDAS_GET_RECHARGE_PRODUCT_INFO_NOTIFY, RechargeUI.MidasProductEventHandler);
    EventSystem:registEvent(EVENTTYPE_RECHARGE, EVENTID_RECHARGE_OFFTYPE, RechargeUI.RechargeOffEventHandler)
    EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_TICKET_CHANGE, RechargeUI.OnTicketChange);

    EventSystem:registEvent(EVENTTYPE_SHOPLIMIT, EVENTID_SHOPLIMIT_STARTERPACK_TIME_LIMIT_UPDATED,RechargeUI.UpdateUICountDown);
    EventSystem:registEvent(EVENTTYPE_SHOPLIMIT, EVENTID_SHOPLIMIT_STARTERPACK_ISOPEN_UPDATED,RechargeUI.OnStarterPackIsOpenChanged);

    -- RechargeUI:InitializeTableData();
end

function bp_recharge_OnModeSwitched(gamestatus)
	log("bp_recharge_OnModeSwitched gamestatus = " .. gamestatus);
    RechargeUI.isShowing = false;
	if string.lower(gamestatus) == "lobby" then
		--在第一次进入主场景的时候，拉取运营活动
        if RechargeUI.isLoadMiadsMP == false then
            RechargeUI.isLoadMiadsMP = true;
            -- EventRechargeMPInfoForActivity();
            RechargeUI:InitializeTableData();
        end
	else
		BP_Recharge_To_Lobby = 0;
	end
end

--关闭充值面板
function EventExitRechargeSystem()
	RechargeUI.isShowing = false;
	log("EventExitRechargeSystem");
    BP_Recharge_To_Lobby = 0;
    -- EventSystem:unregistEvent(EVENTTYPE_MIDAS_NOTIFY, EVENTID_MIDAS_GETMPINFO_NOTIFY, RechargeUI.MidasMPEventHandler);
end

function EventRechargeAddMpListener()

end

--单元测试
function EventClickRechargeItem()
    -- MidasManager.present_level = "[60,61,6000,3281]";
    -- MidasManager.getMPResultCode = "0";
    -- EventSystem:postEvent(EVENTTYPE_MIDAS_NOTIFY,EVENTID_MIDAS_GETMPINFO_NOTIFY,"0");
    --
	-- log("click Recharge  ============================= zoneId ：" .. BP_STRUCT_Recharge_ItemInfo.zoneId);
    -- log("click Recharge  ============================= rechargeKey ：" .. BP_STRUCT_Recharge_ItemInfo.rechargeKey);
    -- log("click Recharge  ============================= buyNum ：" .. BP_STRUCT_Recharge_ItemInfo.buyNum);
    -- log("click Recharge  ============================= country ：" .. BP_STRUCT_Recharge_ItemInfo.country);
    -- log("click Recharge  ============================= monetaryUint ：" .. BP_STRUCT_Recharge_ItemInfo.monetaryUint);
end

function EventRechargeHideTipUI ()
    ConnectionWaitingUI:Hide();
end

function EventRechargeShowTipUI ()
    if string.lower(Client.GetDevicePlatformName()) == "windows" or
        string.lower(Client.GetDevicePlatformName()) == "mac" then -- 这个“mac”没测试过，项目组同事说当前不支持mac
        return;
    end
    ConnectionWaitingUI:Show();
end

--外部公用拉取midas运营活动接口，但是卡住的风险，必须在拉取前加mask遮罩
function EventRechargeMPInfoForActivity()
    RechargeUI:InitializeTableData();
    RechargeUI.isLoadingMP = true;
    Client.LoadMidasMP(RechargeUI.country, RechargeUI.monetaryUint);
end

--拉取midas充值物品的价格
function EventRechargeGetMidasProduct()
    RechargeUI:InitializeTableData();
    RechargeUI.isLoadingProductInfo = true;
    Client.LoadMidasProductInfo(RechargeUI.productId_str);
end

function EventFetchInfo()
end

function EventSetInfo_Push()
end

--组织 充值表数据
function RechargeUI:InitializeTableData()
    if RechargeUI.isInit == false then
        RechargeUI.isInit = true;
        local tabledata = nil;
        -- if string.lower(Client.GetDevicePlatformName()) == "ios" then
        --     tabledata = Client.GetTable("RechargeLevel_IOS");
        -- elseif string.lower(Client.GetDevicePlatformName()) == "android" then
        --     tabledata = Client.GetTable("RechargeLevel_Android");
        -- else
        --     tabledata = Client.GetTable("RechargeLevel_IOS");
        -- end
        tabledata = FuncUtil.GetRechargeLevelTable()
        local temp_Recharge_DataList = {};
        for i,v in pairs(tabledata) do
            if v.visible > 0 then
                local itemInfo = {
                    rechargeId = v.rechargeId,
                    zoneId = v.zoneId,
                    rechargeKey = v.rechargeKey,
                    name = v.name,
                    buyNum = v.buyNum,
                    money = v.money,
                    monetaryUint = v.monetaryUint,
                    monetarySymbol = v.monetarySymbol,
                    icon = v.iconURL,
                    country = v.country,
                };
                table.insert(temp_Recharge_DataList, itemInfo);
                RechargeUI.productId_buynum_array[v.rechargeKey] = v.buyNum;
                if RechargeUI.productId_str == "" then
                    RechargeUI.productId_str = v.rechargeKey;
                else
                    RechargeUI.productId_str = RechargeUI.productId_str .. "," .. v.rechargeKey;
                end
                --保存国家 区域 货币等通用信息
                if RechargeUI.isConfigRecharge == false then
                    RechargeUI.isConfigRecharge = true;
                    RechargeUI.zoneId = v.zoneId;
                    RechargeUI.country = v.country;
                    RechargeUI.monetaryUint = v.monetaryUint;
                end
               
            end
        end
        if temp_Recharge_DataList and #temp_Recharge_DataList > 0 then
            table.sort(temp_Recharge_DataList, function(a, b)
                return a.buyNum < b.buyNum;
            end);
        end
        
        BP_ARRAY_Recharge_DataList = temp_Recharge_DataList;
    end
    GlobalData.GetRechargePayPos();
    RechargeUI.rechargePayPos = BP_Global_RechargePayPos;
    log("RechargeUI:InitializeTableData.." .. tostring(RechargeUI.rechargePayPos));
    if tonumber(RechargeUI.rechargePayPos) < 60 then
        RechargeUI.rechargePayPos = "300";
    end
    --设置offset
    local offsetIndex = 0;
    for _k, _v in pairs(BP_ARRAY_Recharge_DataList) do
        if RechargeUI.rechargePayPos == tostring(_v.buyNum) then
            RechargeUI.SetScrollBoxOffSet(offsetIndex);
            BP_Recharge_Current_HighLightShow = offsetIndex;
            break; 
        end
        offsetIndex = offsetIndex + 1;
    end
    BP_Recharge_Player_Cur_Ticket = DataMgr.ticket
end

--拉取midas运营活动，只能在充值蓝图打开过一次后能使用
function RechargeUI:GetMPInfo()
    if RechargeUI.isShowing == true then
        return;
    end
    LuaClassObj.HandleUIMessage(bp_recharge, "GetMpInfo");
end

--显示充值界面，请调用这个方法，不要调用 Show和 EventEnterRechargeSystem
function RechargeUI:Init()
    local region = Client.GetPublishRegion();
    --story=63121879 【iGame0.9.0版本】第三方支付包
    if Client.GetAOSSHOP() == 'ThirdPartyPayment' then
        Client.MidasH5Pay("");
    elseif region == "JAPAN" or region == "KOREA" then
        RechargeJKUI:Init();
        local uiManager = require("ui.manager");
        uiManager.ShowUI(uiManager.UI_Config.recharge_mgr);
        --log("RechargeJKUIRechargeJKUIRechargeJKUIRechargeJKUIRechargeJKUI");
    else
        RechargeUI:InitShow();
        --log("RechargeUIRechargeUIRechargeUIRechargeUIRechargeUIRechargeUI");
    end 

end

--显示充值界面，请调用这个方法，不要调用 Show和 EventEnterRechargeSystem
function RechargeUI:InitShow()
    if RechargeUI.isShowing == true then
        return;
    end
    --功能未开放
    if not LobbyUI:CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_ENCHARGE) then
        return;
    end

    BP_Recharge_To_Lobby = 1;
    log("RechargeSystemUI Init");
    RechargeUI.isShowing = true;

    RechargeUI:InitializeTableData();
    RechargeUI:InitializeStarterPackData();

    RechargeUI:Show();
    RechargeSystem.IGameGetChargeHotTagReq();

end

function RechargeUI:Show()
  LuaClassObj.HandleDynamicCreation(bp_recharge);
  log("RechargeSystemUI Show");
  LuaClassObj.HandleUIMessage(bp_recharge, "UIShow");
    UIManager.Show(eUIType.eRechargeUI);
    --Timer.InsertTimer(0.5, RechargeUI.RechargeTestItem, false, false);
    StarterPackSystem.SetPurchaseUITrigger(StarterPackSystem.PurchaseTriggerUI.UCSTORE, true)
end

--跳转事件处理
function RechargeUI:OnJumpUrl(eventType, eventID, vars)
    RechargeUI:Init();
end

--设置scrollbox offset
function RechargeUI.SetScrollBoxOffSet(offsetIndex)
    if not offsetIndex or offsetIndex <= 0 then
        offsetIndex = -1;
    end
    if offsetIndex == 1 then
        offsetIndex = 0;
    end
    if offsetIndex > RechargeUI.rechargeMaxIndex then
        offsetIndex = RechargeUI.rechargeMaxIndex;
    end
    if offsetIndex > 1 then
        offsetIndex = offsetIndex - 1;
    end
    if offsetIndex == -1 then
        BP_Recharge_ScrollBox_Offset_f = 0;
    else
        BP_Recharge_ScrollBox_Offset_f = RechargeUI.rechargeItemWidth / 2 + RechargeUI.rechargeItemWidth * offsetIndex;
    end
end

--midas充值结果回调
function RechargeUI.MidasPayBackEventHandler(evenType, eventID, result_code)
    if RechargeUI.isShowing == true then
        LuaClassObj.HandleUIMessage(bp_recharge, "ClearDelayHideTipUI");
    end
    EventRechargeHideTipUI();

    if result_code == "0" or result_code == 0 then
        -- EventRechargeMPInfoForActivity();
        RechargeUI:GetMPInfo();
		-- 充值打点
		LuaClassObj.HandleUIMessage(bp_recharge, "OnMidasPay");
		-- 首充打点
		if DataMgr.Recharge == 1 then
			LuaClassObj.HandleUIMessage(bp_recharge, "OnMidasFirstPay");
		end
        log("RechargeUI.MidasPayBackEventHandler .." .. tostring(BP_Recharge_Buy_PosForSave));
        if BP_Recharge_Buy_PosForSave and BP_Recharge_Buy_PosForSave ~= "" then
            BP_Global_RechargePayPos = BP_Recharge_Buy_PosForSave;
            GlobalData.SaveRechargePayPos();
        end
    end
end

function RechargeUI.MidasProductEventHandler(evenType, eventID, resultTable)
    local success = false;
    --local result_desc = MidasManager.productInfoJson;
    -- result_desc =
    -- "{\"ret\":\"0\",\"msg\":\"success\",\"productInfo\":[{\"productId\":\"com.tencent.ig.uc6000\",\"price\":\"HK$7.7566666666666\",\"currency\":\"TTZ\"},{\"productId\":\"com.tencent.ig.uc60\",\"price\":\"HK$15.51\",\"currency\":\"TTZ\"}]}";

    if resultTable ~= nil then
        BP_Recharge_Has_ProduceInfo = true;
        local temp_Recharge_MoneyKeyList = {};
        local temp_Recharge_MoneyList = {};
        for k,product in pairs(resultTable) do
            if product ~= nil then
                --除20个非重点国家货币，都显示为美元
                if MidasManager.ShouldShowLocalCurrency(product.currency) == false then
                --特殊处理印度尼西亚和越南的货币，显示为美元
                -- if product.currency == "IDR" or product.currency == "VND" then
                    break;
                else
                    if success == false then
                        success = true;
                    end
                    if product.productId ~= nil and product.price ~= nil then
                        local productNum = RechargeUI.productId_buynum_array[tostring(product.productId)];
                        if productNum ~= nil then
                            table.insert(temp_Recharge_MoneyKeyList, productNum);
                            table.insert(temp_Recharge_MoneyList, tostring(product.price));
                        end
                    end
                end
            end
        end
        BP_ARRAY_Recharge_MoneyKeyList = temp_Recharge_MoneyKeyList;
        BP_ARRAY_Recharge_MoneyList = temp_Recharge_MoneyList;
    end


    if RechargeUI.isShowing == true then
        RechargeUI.isLoadingProductInfo = false;
        --同时拉到运营活动和价格才关闭转圈
        if RechargeUI.isLoadingProductInfo == false and RechargeUI.isLoadingMP == false then
            EventRechargeHideTipUI();
            LuaClassObj.HandleUIMessage(bp_recharge, "ClearDelayHideTipUI");
        end

        if success == true then
            LuaClassObj.HandleUIMessage(bp_recharge, "UpdatePruductInfo");
        end
    end
end

--midas营销活动回调
function RechargeUI:MidasMPEventHandler(evenType, eventID, midas_recharge_code)

    local temp_Recharge_PayPresentList = {};
    local temp_Recharge_PayNumList = {};
    local success = false;
    if MidasManager.getMPResultCode == "0" or MidasManager.getMPResultCode == 0 then

        if string.len(MidasManager.present_level) <=2 then
            return;
        end

        local tempStr = string.sub(MidasManager.present_level, 2, string.len(MidasManager.present_level)-1 );
        log(MidasManager.present_level .. "  rechargeUI cast MidasManager.present_level to  :  " .. tempStr);
        local args = string.split(tempStr, ",");
        for i,v in ipairs(args) do
            local mod = math.fmod( i, 2 );
            if mod == 0 then
                table.insert(temp_Recharge_PayPresentList, tonumber(v));
            else
                table.insert(temp_Recharge_PayNumList, tonumber(v));
            end
        end
        BP_ARRAY_Recharge_PayPresentList = temp_Recharge_PayPresentList;
        BP_ARRAY_Recharge_PayNumList = temp_Recharge_PayNumList;
        log("  rechargeUI cast test ==========");

        success = true;
    end
    
    if RechargeUI.isShowing == true then
        RechargeUI.isLoadingMP = false;
        --同时拉到运营活动和价格才关闭转圈
        if RechargeUI.isLoadingProductInfo == false and RechargeUI.isLoadingMP == false then
            EventRechargeHideTipUI();
            LuaClassObj.HandleUIMessage(bp_recharge, "ClearDelayHideTipUI");
        end

        if success == true then
            LuaClassObj.HandleUIMessage(bp_recharge, "UpdateMpInfo");
        end
    end
end


--热卖和超值标记刷新
function RechargeUI:RechargeOffEventHandler(evenType, eventID)

        local cfgstr = RechargeSystem.hotCfgStr;
    	local offTable = string.split(cfgstr, ";");
    	--必须包含热卖和超值标记
    	if #offTable < 2 then
    		return;
    	end

    	local offStr = offTable[1];
    	if offStr == "" then
    		return;
    	end

    	--热卖标记
    	BP_ARRAY_Recharge_HotList = string.split(offStr, "_");

    	local offStr2 = offTable[2];
    	if offStr2 == "" then
    		return;
    	end
    	--超值标记
    	BP_ARRAY_Recharge_CheapList = string.split(offStr2, "_");

        if RechargeUI.isShowing == true then
            LuaClassObj.HandleUIMessage(bp_recharge, "UpdateOffType");
        end
end

--function RechargeUI.RechargeTestItem()
--    BP_ARRAY_Recharge_PayPresentList = {10, 25, 60, 300, 850, 2100}
--    BP_ARRAY_Recharge_PayNumList = {180, 300, 600, 1500, 3000, 6000};
--    LuaClassObj.HandleUIMessage(bp_recharge, "UpdateMpInfo");
--end

function EventRechargeGetJPAge()
    if DataMgr.jp_age ~= nil then
        BP_Recharge_Need_Set_Age = false;
        BP_Recharge_JPAge = DataMgr.jp_age;
    else
        BP_Recharge_Need_Set_Age = true;
    end
    log("[HHF]EventRechargeGetJPAge, BP_Recharge_Need_Set_Age=" .. tostring(BP_Recharge_Need_Set_Age) .. " BP_Recharge_JPAge=" .. tostring(BP_Recharge_JPAge));
end

function EventRechargeAskForJPLaw()
    CommonNoticeBoxUI:ShowMessageBox(2, LongTxt.JPLaw1_title_jp, LongTxt.JPLaw1_content_jp, "");
end

-- 日版充值的时候弹一个二次确认弹框
function EventRechargeJPConfirm()
    -- 总点券
    local ticket = DataMgr.ticket or 0;
    -- 无偿点券
    local gen_ticket = DataMgr.gen_ticket or 0;
    -- 有尝点券
    local pay_ticket = ticket - gen_ticket;
    -- 容错
    if (pay_ticket < 0) then
        pay_ticket = 0;
    end

    -- 当前档位消耗货币，获得点券值
    local buyNum = "";
    local money = "";
    local symbol = "";
    for i,v in ipairs(BP_ARRAY_Recharge_DataList) do
        if v.rechargeId == BP_Current_RechargeID then
            buyNum = v.buyNum;
            money = v.money;
            symbol = v.monetarySymbol;
            BP_Current_RechargeIndex = i - 1;
            break;
        end
    end

    -- 数字类型的buynum, 用于下面的赠送判断
    local nBuyNum = tonumber(buyNum);

    -- 遍历赠送
    local gen_ticket_index = -1;
    local index = 0;
    if BP_ARRAY_Recharge_PayNumList ~= nil then
        for k,v in pairs(BP_ARRAY_Recharge_PayNumList) do
            index=index+1;
            log("[HHF]EventRechargeJPConfirm, BP_ARRAY_Recharge_PayNumList k=" .. tostring(k) .. " v=" .. tostring(v) .. " index=" .. tostring(index) .. " nBuyNum=" .. tostring(nBuyNum));
            if v == nBuyNum then
                 gen_ticket_index = index;
            end
        end
    end

    log("[HHF]EventRechargeJPConfirm, gen_ticket_index=" .. tostring(gen_ticket_index));

    -- 找到赠送值
    local gen_ticket_number = 0;
    index = 0;
    if gen_ticket_index >= 0 and BP_ARRAY_Recharge_PayPresentList ~= nil then
        for k,v in pairs(BP_ARRAY_Recharge_PayPresentList) do
            index=index+1;
            log("[HHF]EventRechargeJPConfirm, BP_ARRAY_Recharge_PayPresentList k=" .. tostring(k) .. " v=" .. tostring(v) .. " index=" .. tostring(index));
            if index == gen_ticket_index then
                gen_ticket_number = v;
            end
        end
    end

    log("[HHF]EventRechargeJPConfirm, gen_ticket_number=" .. tostring(gen_ticket_number));

    local total_buy_number = tonumber(buyNum) + gen_ticket_number;

    local symbol_money = symbol .. tostring(money);

    log("[HHF]EventRechargeJPConfirm, ticket=" .. tostring(ticket) .. " gen_ticket=" .. tostring(gen_ticket) .. " pay_ticket=" .. tostring(pay_ticket) .. " buyNum=" .. tostring(buyNum) .. " money=" .. tostring(money) .. " symbol=" .. symbol);

    local msgTitle = FuncUtil.GetLocalizeResStr("101001");
    local msgContent = FuncUtil.LocalizeResFormat("4424", tostring(pay_ticket), tostring(gen_ticket), symbol_money, tostring(total_buy_number));

    local function clickOKCallback()
        if RechargeUI.isShowing == true then
            LuaClassObj.HandleUIMessage(bp_recharge, "DoPay");
        end
    end

    CommonMessageBoxUI:ShowPanel(2, msgTitle, msgContent, clickOKCallback);
end

-- rechargeID同步
function EventRechargeID_Push()

end

--检查缓存的Midas运营活动和商品价格是否过期f
function EventCheckRechargeMPAndPriceExpire()
    RechargeUI:InitializeTableData();
    local isProductInfoCached,cachedProductInfoList = MidasManager.LoadCachedMidasProductInfo(RechargeUI.productId_str);
    local isMPExpire = MidasManager.IsMPExpire();

    --如果没过期就用缓存的数据
    if isProductInfoCached == true then
        RechargeUI.MidasProductEventHandler(EVENTTYPE_MIDAS_NOTIFY, EVENTID_MIDAS_GET_RECHARGE_PRODUCT_INFO_NOTIFY, cachedProductInfoList);
    end

    if isMPExpire == false then
        RechargeUI:MidasMPEventHandler(EVENTTYPE_MIDAS_NOTIFY, EVENTID_MIDAS_GETMPINFO_NOTIFY, MidasManager.getMPResultCode);
    end

    --通知蓝图
    BP_Recharge_Midas_CachedMPInfo_Expired = isMPExpire;
    BP_Recharge_Midas_CachedProductInfo_Expired = not isProductInfoCached;
    LuaClassObj.HandleUIMessage(bp_recharge, "OnCheckRechargeMPAndPriceExpire");
end


--点击订阅规则BUTTON
function EventClickedSubscribrRule()
    local title = FuncUtil.GetLocalizeResStr("6371")
	local content = FuncUtil.GetLocalizeResStr("6505")
	PopUpNoticeUI.ShowMessageBox(title,content);
end
--关闭
function EventRecharge_Hide()
    UIManager.Hide(eUIType.eRechargeUI);

    StarterPackSystem.SetPurchaseUITrigger(StarterPackSystem.PurchaseTriggerUI.UCSTORE, false)
end

--点券数据有变化 刷新点券
function RechargeUI.OnTicketChange()
    -- body
    if RechargeUI.isShowing then
        BP_Recharge_Player_Cur_Ticket = DataMgr.ticket
        LuaClassObj.HandleUIMessageNoFetch(bp_recharge, "UISetCurTicket");      
    end
end

---------------------------------------------------------------------------------------------------------------
-- Starter Pack
---------------------------------------------------------------------------------------------------------------

-- StarterPack是否开启
BP_Recharge_StarterPackSystem_IsOpen = false;
BP_Recharge_StarterPackSystem_PriceDesc = "Updating..";
BP_Recharge_StarterPackSystem_DayDesc = "";
BP_Recharge_StarterPackSystem_UCDesc = "";

--初始化StarterPack数据
function RechargeUI:InitializeStarterPackData()
    BP_Recharge_StarterPackSystem_IsOpen = StarterPackSystem.IsOpen();
    log("InitializeStarterPackData BP_Recharge_StarterPackSystem_IsOpen = " .. tostring(BP_Recharge_StarterPackSystem_IsOpen) );
    BP_Recharge_StarterPackSystem_PriceDesc = StarterPackSystem.GetPriceDesc();
    log("InitializeStarterPackData BP_Recharge_StarterPackSystem_PriceDesc = " .. tostring(BP_Recharge_StarterPackSystem_PriceDesc) );
    BP_Recharge_StarterPackSystem_DayDesc = StarterPackSystem.GetPurchaseEffectiveTimeDesc();
    log("InitializeStarterPackData BP_Recharge_StarterPackSystem_DayDesc = " .. tostring(BP_Recharge_StarterPackSystem_DayDesc) );
    BP_Recharge_StarterPackSystem_UCDesc = StarterPackSystem.GetUCRewardsDesc();
    log("InitializeStarterPackData BP_Recharge_StarterPackSystem_UCDesc = " .. tostring(BP_Recharge_StarterPackSystem_UCDesc) );
end

--购买新手礼包
function EventClickedStartPackPurchase()
    log("EventClickedStartPackPurchase ");

    if BP_Recharge_StarterPackSystem_IsOpen then
        StarterPackSystem.StartDirectPurchase()
    end
end

--购买新手礼包
function RechargeUI.UpdateUICountDown(timeRemain)
    --log("get final string time from Starsfadfdasfsa " .. tostring(timeRemain));
    --log("get final string time from Starsfadfdasfsa " .. tostring(StarterPackSystem.sStarterPack_RemainingTime));
    --BP_String_StarterPack_RemainingTime = timeRemain;
    BP_Recharge_StarterPackSystem_DayDesc = StarterPackSystem.GetPurchaseEffectiveTimeDesc();
    --log("get final string time " .. tostring(BP_String_StarterPack_RemainingTime));
    LuaClassObj.HandleUIMessage(bp_recharge, "UpdateStartPackTimeLeft");
end

--新手礼包状态变化
function RechargeUI.OnStarterPackIsOpenChanged()
    BP_Recharge_StarterPackSystem_IsOpen = StarterPackSystem.IsOpen();
    log("RechargeUI OnStarterPackIsOpenChanged = " .. tostring(BP_Recharge_StarterPackSystem_IsOpen) );
    LuaClassObj.HandleUIMessage(bp_recharge, "OnStarterPackIsOpenChanged");
end






















