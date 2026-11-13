RechargeJKUI = RechargeJKUI or
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
   region = "";
   }

BP_RechargeJK_To_Lobby = 0;
BP_RechargeJK_Has_ProduceInfo = false;

-- 判断日本版本是否需要年龄设置
BP_RechargeJK_Need_Set_Age = false;

-- 日本版本当前年龄，默认值20岁，不限额
BP_RechargeJK_JPAge = 20;

------------------------------------------------------------------
--赠送货币数据 PayNumList 为key，PayPresentList为Value
BP_ARRAY_RechargeJK_PayNumList =
{
    Recharge_PayNum = 0;
};

BP_ARRAY_RechargeJK_PayPresentList =
{
    Recharge_PayPresent = 0;
};
------------------------------------------------------------------

------------------------------------------------------------------
--midas的价格数据 MoneyKeyList 为key，MoneyList为Value
BP_ARRAY_RechargeJK_MoneyKeyList =
{
    Recharge_Moneykey = 0;
};

BP_ARRAY_RechargeJK_MoneyList =
{
    Recharge_Money = "";
};
------------------------------------------------------------------
--热卖标记
BP_ARRAY_RechargeJK_HotList =
{
    Recharge_Hot = 0;
}

--超值标记
BP_ARRAY_RechargeJK_CheapList =
{
    Recharge_Cheap = 0;
}

--物品信息列表(定义结构体数组：当且仅当以BP_ARRAY_开头的table能作为数组给蓝图访问)
BP_ARRAY_RechargeJK_DataList =
{
    tmp_UseExist_BP_STRUCT_Recharge_ItemInfo={}, --定义结构体数组，这种写法要作为规范规定下来
};

-- 当前正在充值的rechargeID
BP_Current_RechargeJKID = 0;
-- 当前正在充值的rechargeIndex
BP_Current_RechargeJKIndex = 0;

--Midas缓存的运营活动是否过期
BP_RechargeJK_Midas_CachedMPInfo_Expired= true;
--Midas缓存的商品价格是否过期
BP_RechargeJK_Midas_CachedProductInfo_Expired= true;

function bp_rechargeJK_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_rechargeJK,
	  {{Path="/Game/UMG/UI_Logic/Recharge/RechargeJK_BP.RechargeJK_BP_C", Container="Default", ZOrder=BP_ENUM_UI_RECHARGE_ZORDER+5}},
	  {"Lobby"},
      false,
      true,
      true
	);
    --EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_RECHARGE, RechargeJKUI.OnJumpUrl);
    EventSystem:registEvent(EVENTTYPE_MIDAS_NOTIFY, EVENTID_MIDAS_PAY_NOTIFY,RechargeJKUI.MidasPayBackEventHandler);
    EventSystem:registEvent(EVENTTYPE_MIDAS_NOTIFY, EVENTID_MIDAS_GETMPINFO_NOTIFY, RechargeJKUI.MidasMPEventHandler);
    EventSystem:registEvent(EVENTTYPE_MIDAS_NOTIFY, EVENTID_MIDAS_GET_RECHARGE_PRODUCT_INFO_NOTIFY, RechargeJKUI.MidasProductEventHandler);
    EventSystem:registEvent(EVENTTYPE_RECHARGE, EVENTID_RECHARGE_OFFTYPE, RechargeJKUI.RechargeOffEventHandler)
    -- RechargeJKUI:InitializeTableData();
end

function bp_rechargeJK_OnModeSwitched(gamestatus)
	log("bp_rechargeJK_OnModeSwitched gamestatus = " .. gamestatus);
    RechargeJKUI.isShowing = false;
	if string.lower(gamestatus) == "lobby" then
		--在第一次进入主场景的时候，拉取运营活动
        if RechargeJKUI.isLoadMiadsMP == false then
            RechargeJKUI.isLoadMiadsMP = true;
            RechargeJKUI.region = Client.GetPublishRegion();
            --RechargeJKUI.region = "JAPAN"
            -- EventRechargeMPInfoForActivity();
            RechargeJKUI:InitializeTableData();
        end
	else
        BP_RechargeJK_To_Lobby = 0;
	end
end

--关闭充值面板
function EventExitRechargeJKSystem()
	RechargeJKUI.isShowing = false;
	log("EventExitRechargeJKSystem");
    BP_RechargeJK_To_Lobby = 0;
    -- EventSystem:unregistEvent(EVENTTYPE_MIDAS_NOTIFY, EVENTID_MIDAS_GETMPINFO_NOTIFY, RechargeJKUI.MidasMPEventHandler);
end

function EventRechargeJKAddMpListener()

end

--单元测试
function EventClickRechargeJKItem()
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

function EventRechargeJKHideTipUI ()
    ConnectionWaitingUI:Hide();
end

function EventRechargeJKShowTipUI ()
    if string.lower(Client.GetDevicePlatformName()) == "windows" or
        string.lower(Client.GetDevicePlatformName()) == "mac" then -- 这个“mac”没测试过，项目组同事说当前不支持mac
        return;
    end
    ConnectionWaitingUI:Show();
end

--外部公用拉取midas运营活动接口，但是卡住的风险，必须在拉取前加mask遮罩
function EventRechargeJKMPInfoForActivity()
    RechargeJKUI:InitializeTableData();
    RechargeJKUI.isLoadingMP = true;
    Client.LoadMidasMP(RechargeJKUI.country, RechargeJKUI.monetaryUint);
end

--拉取midas充值物品的价格
function EventRechargeJKGetMidasProduct()
    RechargeJKUI:InitializeTableData();
    RechargeJKUI.isLoadingProductInfo = true;
    Client.LoadMidasProductInfo(RechargeJKUI.productId_str);
end

function EventFetchInfo()
end

function EventSetInfo_Push()
end

--组织 充值表数据
function RechargeJKUI:InitializeTableData()
    if RechargeJKUI.region == "JAPAN" or RechargeJKUI.region == "KOREA" then
        if RechargeJKUI.isInit == false then
            RechargeJKUI.isInit = true;
            local tabledata = nil;
            --if string.lower(Client.GetDevicePlatformName()) == "ios" then
            --    tabledata = Client.GetTable("RechargeLevel_IOS");
            --elseif string.lower(Client.GetDevicePlatformName()) == "android" then
            --    tabledata = Client.GetTable("RechargeLevel_Android");
            --else
            --    tabledata = Client.GetTable("RechargeLevel_IOS");
            --end
            tabledata = FuncUtil.GetRechargeLevelTable();
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
                    RechargeJKUI.productId_buynum_array[v.rechargeKey] = v.buyNum;
                    if RechargeJKUI.productId_str == "" then
                        RechargeJKUI.productId_str = v.rechargeKey;
                    else
                        RechargeJKUI.productId_str = RechargeJKUI.productId_str .. "," .. v.rechargeKey;
                    end
                    --保存国家 区域 货币等通用信息
                    if RechargeJKUI.isConfigRecharge == false then
                        RechargeJKUI.isConfigRecharge = true;
                        RechargeJKUI.zoneId = v.zoneId;
                        RechargeJKUI.country = v.country;
                        RechargeJKUI.monetaryUint = v.monetaryUint;
                    end
                end
            end
            table.sort(temp_Recharge_DataList, function(a, b)
                return a.rechargeId < b.rechargeId;
            end)
            BP_ARRAY_RechargeJK_DataList = temp_Recharge_DataList;
        end
    end
end

--拉取midas运营活动，只能在充值蓝图打开过一次后能使用
function RechargeJKUI:GetMPInfo()
    if RechargeJKUI.isShowing == true then
        return;
    end
    LuaClassObj.HandleUIMessage(bp_rechargeJK, "GetMpInfo");
end

--显示充值界面，请调用这个方法，不要调用 Show和 EventEnterRechargeSystem
function RechargeJKUI:Init()
    RechargeJKUI:InitShow();
end

--显示充值界面，请调用这个方法，不要调用 Show和 EventEnterRechargeSystem
function RechargeJKUI:InitShow()

    if RechargeJKUI.isShowing == true then
        return;
    end
    --功能未开放
    if not LobbyUI:CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_ENCHARGE) then
        return;
    end

    BP_RechargeJK_To_Lobby = 1;
    log("RechargeJKSystemUI Init");
    RechargeJKUI.isShowing = true;

    RechargeJKUI:InitializeTableData();
    RechargeJKUI:Show();
    RechargeSystem.IGameGetChargeHotTagReq();
end

function RechargeJKUI:Show()
  LuaClassObj.HandleDynamicCreation(bp_rechargeJK);
  log("RechargeJKSystemUI Show");
  LuaClassObj.HandleUIMessage(bp_rechargeJK, "UIShow");
    UIManager.Show(eUIType.eRechargeJKUI)
end

function EventRechargeJKUI_Hide()
    UIManager.Hide(eUIType.eRechargeJKUI)
end

--跳转事件处理
function RechargeJKUI:OnJumpUrl(eventType, eventID, vars)
    log("RechargeJKUI:OnJumpUrl")
    RechargeJKUI:Init();
end



--midas充值结果回调
function RechargeJKUI.MidasPayBackEventHandler(evenType, eventID, result_code)
    if RechargeJKUI.region == "JAPAN" or RechargeJKUI.region == "KOREA" then
        if RechargeJKUI.isShowing == true then
            LuaClassObj.HandleUIMessage(bp_rechargeJK, "ClearDelayHideTipUI");
        end
        EventRechargeJKHideTipUI();

        if result_code == "0" or result_code == 0 then
            -- EventRechargeMPInfoForActivity();
            RechargeJKUI:GetMPInfo();
            -- 充值打点
            LuaClassObj.HandleUIMessage(bp_rechargeJK, "OnMidasPay");
            -- 首充打点
            if DataMgr.Recharge == 1 then
                LuaClassObj.HandleUIMessage(bp_rechargeJK, "OnMidasFirstPay");
            end
        end
    end
end

function RechargeJKUI.MidasProductEventHandler(evenType, eventID, resultTable)
    if RechargeJKUI.region == "JAPAN" or RechargeJKUI.region == "KOREA" then

        local success = false;
        --local result_desc = MidasManager.productInfoJson;
        -- result_desc =
        -- "{\"ret\":\"0\",\"msg\":\"success\",\"productInfo\":[{\"productId\":\"com.tencent.ig.uc6000\",\"price\":\"HK$7.7566666666666\",\"currency\":\"TTZ\"},{\"productId\":\"com.tencent.ig.uc60\",\"price\":\"HK$15.51\",\"currency\":\"TTZ\"}]}";

        if resultTable ~= nil then
            BP_RechargeJK_Has_ProduceInfo = true;
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
                            local productNum = RechargeJKUI.productId_buynum_array[tostring(product.productId)];
                            if productNum ~= nil then
                                table.insert(temp_Recharge_MoneyKeyList, productNum);
                                table.insert(temp_Recharge_MoneyList, tostring(product.price));
                            end
                        end
                    end
                end
            end
            BP_ARRAY_RechargeJK_MoneyKeyList = temp_Recharge_MoneyKeyList;
            BP_ARRAY_RechargeJK_MoneyList = temp_Recharge_MoneyList;
        end


        if RechargeJKUI.isShowing == true then
            RechargeJKUI.isLoadingProductInfo = false;
            --同时拉到运营活动和价格才关闭转圈
            if RechargeJKUI.isLoadingProductInfo == false and RechargeJKUI.isLoadingMP == false then
                EventRechargeJKHideTipUI();
                LuaClassObj.HandleUIMessage(bp_rechargeJK, "ClearDelayHideTipUI");
            end

            if success == true then
                LuaClassObj.HandleUIMessage(bp_rechargeJK, "UpdatePruductInfo");
            end
        end
        
    end
end

--midas营销活动回调
function RechargeJKUI:MidasMPEventHandler(evenType, eventID, midas_recharge_code)
    if RechargeJKUI.region == "JAPAN" or RechargeJKUI.region == "KOREA" then
        local temp_Recharge_PayPresentList = {};
        local temp_Recharge_PayNumList = {};
        local success = false;
        if MidasManager.getMPResultCode == "0" or MidasManager.getMPResultCode == 0 then

            if string.len(MidasManager.present_level) <=2 then
                return;
            end

            local tempStr = string.sub(MidasManager.present_level, 2, string.len(MidasManager.present_level)-1 );
            log(MidasManager.present_level .. "  RechargeJKUI cast MidasManager.present_level to  :  " .. tempStr);
            local args = string.split(tempStr, ",");
            for i,v in ipairs(args) do
                local mod = math.fmod( i, 2 );
                if mod == 0 then
                    table.insert(temp_Recharge_PayPresentList, tonumber(v));
                else
                    table.insert(temp_Recharge_PayNumList, tonumber(v));
                end
            end
            BP_ARRAY_RechargeJK_PayPresentList = temp_Recharge_PayPresentList;
            BP_ARRAY_RechargeJK_PayNumList = temp_Recharge_PayNumList;
            log("  RechargeJKUI cast test ==========");

            success = true;
        end

        if RechargeJKUI.isShowing == true then
            RechargeJKUI.isLoadingMP = false;
            --同时拉到运营活动和价格才关闭转圈
            if RechargeJKUI.isLoadingProductInfo == false and RechargeJKUI.isLoadingMP == false then
                EventRechargeJKHideTipUI();
                LuaClassObj.HandleUIMessage(bp_rechargeJK, "ClearDelayHideTipUI");
            end

            if success == true then
                LuaClassObj.HandleUIMessage(bp_rechargeJK, "UpdateMpInfo");
            end
        end
    end
end


--热卖和超值标记刷新
function RechargeJKUI:RechargeOffEventHandler(evenType, eventID)
    if RechargeJKUI.region == "JAPAN" or RechargeJKUI.region == "KOREA" then

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
        BP_ARRAY_RechargeJK_HotList = string.split(offStr, "_");

        local offStr2 = offTable[2];
        if offStr2 == "" then
            return;
        end
        --超值标记
        BP_ARRAY_RechargeJK_CheapList = string.split(offStr2, "_");

        if RechargeJKUI.isShowing == true then
            LuaClassObj.HandleUIMessage(bp_rechargeJK, "UpdateOffType");
        end
        
    end
end

function EventRechargeJKGetJPAge()
    if DataMgr.jp_age ~= nil then
        BP_RechargeJK_Need_Set_Age = false;
        BP_RechargeJK_JPAge = DataMgr.jp_age;
    else
        BP_RechargeJK_Need_Set_Age = true;
    end
    log("[HHF]EventRechargeGetJPAge, BP_RechargeJK_Need_Set_Age=" .. tostring(BP_RechargeJK_Need_Set_Age) .. " BP_RechargeJK_JPAge=" .. tostring(BP_RechargeJK_JPAge));
end

function EventRechargeJKAskForJPLaw()
    CommonNoticeBoxUI:ShowMessageBox(2, LongTxt.JPLaw1_title_jp, LongTxt.JPLaw1_content_jp, "");
end

-- 日版充值的时候弹一个二次确认弹框
function EventRechargeJKJPConfirm()
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
    for i,v in ipairs(BP_ARRAY_RechargeJK_DataList) do
        if v.rechargeId == BP_Current_RechargeJKID then
            buyNum = v.buyNum;
            money = v.money;
            symbol = v.monetarySymbol;
            BP_Current_RechargeJKIndex = i - 1;
            break;
        end
    end

    -- 数字类型的buynum, 用于下面的赠送判断
    local nBuyNum = tonumber(buyNum);

    -- 遍历赠送
    local gen_ticket_index = -1;
    local index = 0;
    if BP_ARRAY_RechargeJK_PayNumList ~= nil then
        for k,v in pairs(BP_ARRAY_RechargeJK_PayNumList) do
            index=index+1;
            log("[HHF]EventRechargeJPConfirm, BP_ARRAY_RechargeJK_PayNumList k=" .. tostring(k) .. " v=" .. tostring(v) .. " index=" .. tostring(index) .. " nBuyNum=" .. tostring(nBuyNum));
            if v == nBuyNum then
                 gen_ticket_index = index;
            end
        end
    end

    log("[HHF]EventRechargeJPConfirm, gen_ticket_index=" .. tostring(gen_ticket_index));

    -- 找到赠送值
    local gen_ticket_number = 0;
    index = 0;
    if gen_ticket_index >= 0 and BP_ARRAY_RechargeJK_PayPresentList ~= nil then
        for k,v in pairs(BP_ARRAY_RechargeJK_PayPresentList) do
            index=index+1;
            log("[HHF]EventRechargeJPConfirm, BP_ARRAY_RechargeJK_PayPresentList k=" .. tostring(k) .. " v=" .. tostring(v) .. " index=" .. tostring(index));
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
        if RechargeJKUI.isShowing == true then
            LuaClassObj.HandleUIMessage(bp_rechargeJK, "DoPay");
        end
    end

    CommonMessageBoxUI:ShowPanel(2, msgTitle, msgContent, clickOKCallback);
end

-- rechargeID同步
function EventRechargeID_Push()

end

--检查缓存的Midas运营活动和商品价格是否过期
function EventCheckRechargeJKMPAndPriceExpire()
    RechargeJKUI:InitializeTableData();
    local isProductInfoCached,cachedProductInfoList = MidasManager.LoadCachedMidasProductInfo(RechargeJKUI.productId_str);
    local isMPExpire = MidasManager.IsMPExpire();

    --如果没过期就用缓存的数据
    if isProductInfoCached == true then
        RechargeJKUI.MidasProductEventHandler(EVENTTYPE_MIDAS_NOTIFY, EVENTID_MIDAS_GET_RECHARGE_PRODUCT_INFO_NOTIFY, cachedProductInfoList);
    end

    if isMPExpire == false then
        RechargeJKUI:MidasMPEventHandler(EVENTTYPE_MIDAS_NOTIFY, EVENTID_MIDAS_GETMPINFO_NOTIFY, MidasManager.getMPResultCode);
    end

    --通知蓝图
    BP_RechargeJK_Midas_CachedMPInfo_Expired = isMPExpire;
    BP_RechargeJK_Midas_CachedProductInfo_Expired = not isProductInfoCached;
    LuaClassObj.HandleUIMessage(bp_rechargeJK, "OnCheckRechargeMPAndPriceExpire");
end
