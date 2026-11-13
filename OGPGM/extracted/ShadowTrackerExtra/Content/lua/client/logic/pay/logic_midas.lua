--[[
  Midas相关逻辑
]]--

MidasManager =  MidasManager or {

  --物品价格Json串
  productInfoJson="",
  --解析后的json
  productInfoParsed=nil,
  --拉取运营活动是否成功
  getMPResultCode="",
  --满赠列表(奇数位为充值额，偶数位为赠送额)
  present_level="",

  --显示本地货币价格的币种
  localCurrencyArray =
  {
       "THB",--泰币
       -- "IDR",--印尼币
       "BRL",--巴西雷亚尔
       "RUB",--卢布
       "TRY",--土耳其币
       "VND",--越南盾
       "INR",--印度卢比
       "GBP",--英镑
       "PHP",--菲律宾比索
       "MXN",--墨西哥元
       "EUR",--欧元
       "CAD",--加拿大币 加元
       "MYR",--马来币
       "USD",--美元
       "HKD",--港币
       "AUD",--澳大利亚币 澳元
       "JPY",--日元
       "KRW",--韩元
       "TWD",--台币
  },


  CachedProductInfoList = {},--Midas缓存的商品信息
  CachedProductInfoExpireTime = 300,--Midas缓存商品过期时间

  CachedMPTimeStampLoaded = 0,--Midas运营活动加载时间戳
  CachedMPExpireTime = 300,--Midas缓存运营活动过期时间

  CachedIntroPriceList = {},
  CachedIntroPriceListExpireTime = 300,

  hasRegisterBackLogin = false,

  RejectRecharge_PlayGameTime = 20,--风控时玩家需要参加游戏的时间
}

function MidasManager.Initialize()
  Client.MidasSDKInit();

  if MidasManager.hasRegisterBackLogin == false then
    MidasManager.hasRegisterBackLogin = true;
    EventSystem:registEvent(EVENTTYPE_LOGIN,EVENTID_BACKLOGIN, MidasManager.OnBackLogin);
    log("MidasManager registEvent.");
  end

end

function MidasManager.OnBackLogin()
  log("MidasManager OnBackLogin.");
  
  --清除缓存的商品价格
  MidasManager.CachedProductInfoList = {};

  --清空打折商品价格信息
  MidasManager.CachedIntroPriceList = {};

  --清除缓存的运营活动
  MidasManager.getMPResultCode="";
  MidasManager.present_level="";
end

function MidasManager.OnInitialize(initCallBack)
  --Midas SDK 初始化回调(补发货回调)
	log("MidasManager received OnInitialize");
  
  --补发货后，向后台请求一下当前余额
  NetUtil.SendPkg("igame_notify_client_charge", 0);
end

function MidasManager.OnPayNeedLogin()
  --支付回调，需要重新登录
	log("MidasManager received OnPayNeedLogin");
  
  local msgTitle = FuncUtil.GetLocalizeResStr("4085");
	local msgContent = FuncUtil.GetLocalizeResStr("4084");

	local function clickOKCallback()
    --重新登录
    log("MidasManager.OnPayNeedLogin logOut");
		LoginSystem.sendLogout();

	end
  CommonMessageBoxUI:ShowPanel(2, msgTitle, msgContent, clickOKCallback);
  
end

function MidasManager.OnPay(payCallBack)
  --支付回调
	log("MidasManager received OnPay,resultCode:"..payCallBack.resultCode..",appExtends:"..payCallBack.appExtends);

  local paytype = "0";
  if string.find(payCallBack.appExtends, "recharge") ~= nil then
    MidasManager.OnReCharge(payCallBack);
    paytype = "1";
  elseif string.find(payCallBack.appExtends, "goods") ~= nil then
    MidasManager.OnGoods(payCallBack);
    paytype = "2";
  elseif string.find(payCallBack.appExtends, "subscribe") ~= nil then
    MidasManager.OnSubscribe(payCallBack);
    paytype="3";
  else
    log("MidasManager received unknown OnPay appExtends.");
  end

  --风控
  if payCallBack.resultCode ~=nil and payCallBack.resultCode == "-1" and payCallBack.resultInnerCode == "-5" then
    local rc_type = "save";
    if string.find(payCallBack.appExtends, "goods") ~= nil then
      rc_type = "bg";
    elseif string.find(payCallBack.appExtends, "subscribe") ~= nil then
      rc_type = "unimonth";
    end
    NetUtil.SendPriorityPkg(false, "report_reject_charge_rsp", "report_reject_charge",rc_type);
    local strTips = Client.GetTableData("LocalizeRes", "6321").TextValue;
	  CommonMessageBoxUI:ShowPanel(1, Client.GetTableData("LocalizeRes", "102012").TextValue, string.format(strTips, MidasManager.RejectRecharge_PlayGameTime));
  end
  --支付上报GEM

  local payresult = "2";--error
  if payCallBack.resultCode == "0" then
    payresult = "0";--success
  elseif payCallBack.resultCode == "1" then
    payresult = "1";--user cancel
  end

  local devicetype = "Android";
  if string.lower(Client.GetDevicePlatformName()) == "ios" then
    devicetype = "iOS";
  end

  local payEvent = 
  {
      openid = DataMgr.roleData.openID,
      pay_type = paytype,
      pay_result = payresult,
      pay_channel = payCallBack.payChannel,
      device_type = devicetype,
      resultCode = payCallBack.resultCode,
      resultInnerCode = payCallBack.resultInnerCode,
      resultMsg = payCallBack.resultMsg,
  };
  Client.GEMReportEvent(GameFrontendHUD, "pay", payEvent);
end

function MidasManager.OnReCharge(payCallBack)
  --充值回调
  if payCallBack.resultCode == "0" then
    --pay success
    DataMgr.ShowNoticeByID("4080");

    --支付成功后，向后台请求一下当前余额
    NetUtil.SendPkg("igame_notify_client_charge", 0);
  elseif payCallBack.resultCode == "3" then
    -- net error
    DataMgr.ShowNoticeByID("4081");
  elseif payCallBack.resultCode == "2" then
    --param error
    DataMgr.ShowNoticeByID("4082");
  else
    --other error
    DataMgr.ShowNoticeByID("4083");
  end

  EventSystem:postEvent(EVENTTYPE_MIDAS_NOTIFY,EVENTID_MIDAS_PAY_NOTIFY,payCallBack.resultCode);
end

function MidasManager.OnGoods(payCallBack)
  --直购回调
  if payCallBack.resultCode == "0" then
    --pay success
    --DataMgr.ShowNoticeByID("4304");
  elseif payCallBack.resultCode == "3" then
    -- net error
    DataMgr.ShowNoticeByID("4305");
  elseif payCallBack.resultCode == "2" then
    --param error
    DataMgr.ShowNoticeByID("4306");
  else
    --other error
    DataMgr.ShowNoticeByID("4307");
  end

  EventSystem:postEvent(EVENTTYPE_MIDAS_NOTIFY,EVENTID_MIDAS_BUY_GOODS_NOTIFY,payCallBack.resultCode);
end

function MidasManager.OnSubscribe(payCallBack)
  --订阅回调
  if payCallBack.resultCode == "0" then
    --pay success
    DataMgr.ShowNoticeByID("4304");

  elseif payCallBack.resultCode == "3" then
    -- net error
    DataMgr.ShowNoticeByID("4305");
  elseif payCallBack.resultCode == "2" then
    --param error
    DataMgr.ShowNoticeByID("4306");
  else
    --other error
    DataMgr.ShowNoticeByID("4307");
  end

  EventSystem:postEvent(EVENTTYPE_MIDAS_NOTIFY,EVENTID_MIDAS_SUBSCRIBE_NOTIFY,payCallBack.resultCode);
end

function MidasManager.OnGetMP(getMPCallBack)
  --拉取运营活动回调
  log("MidasManager received OnGetMP");
  --log("resultCode="..getMPCallBack.resultCode..",first_save_flag="..getMPCallBack.first_save_flag..",present_level="..getMPCallBack.present_level);

  MidasManager.getMPResultCode = "-2";
  MidasManager.present_level = "";

  if getMPCallBack.mpInfoJson == nil then
    log("MidasManager.OnGetMP failed 1");
    EventSystem:postEvent(EVENTTYPE_MIDAS_NOTIFY,EVENTID_MIDAS_GETMPINFO_NOTIFY,MidasManager.getMPResultCode);
    return;
  end

  local mpInfo = json.decode (getMPCallBack.mpInfoJson);

  if mpInfo == nil then
    log("MidasManager.OnGetMP failed 2");
    EventSystem:postEvent(EVENTTYPE_MIDAS_NOTIFY,EVENTID_MIDAS_GETMPINFO_NOTIFY,MidasManager.getMPResultCode);
    return;
  end

  if mpInfo.ret ~= nil and mpInfo.ret == 0 then
    if mpInfo.present_level ~= nil then
      MidasManager.getMPResultCode = tostring(mpInfo.ret);
      MidasManager.present_level = mpInfo.present_level;
      MidasManager.CachedMPTimeStampLoaded = os.time();
    end
  end

  if MidasManager.getMPResultCode == "0" then
    log("MidasManager.OnGetMP success.");
  else
    log("MidasManager.OnGetMP failed 3");
  end

  EventSystem:postEvent(EVENTTYPE_MIDAS_NOTIFY,EVENTID_MIDAS_GETMPINFO_NOTIFY,MidasManager.getMPResultCode);

end

function MidasManager.OnGetProductInfo(getProductInfoCallBack)
  --获取物品价格信息
  log("MidasManager received OnGetProductInfo"..getProductInfoCallBack.productInfoJson);
  MidasManager.productInfoJson = getProductInfoCallBack.productInfoJson;

  --json解析
  MidasManager.productInfoParsed = json.decode (MidasManager.productInfoJson);
  if MidasManager.productInfoParsed ~= nil then
    --拉取价格信息成功
    if MidasManager.productInfoParsed.ret ~= nil and (MidasManager.productInfoParsed.ret == "0" or MidasManager.productInfoParsed.ret == 0) then
      
      if MidasManager.productInfoParsed.productInfo ~= nil and #MidasManager.productInfoParsed.productInfo > 0 then
        --首先缓存商品信息
        for i,v in pairs(MidasManager.productInfoParsed.productInfo) do
          if v.productId ~= nil and v.currency ~= nil and v.price ~= nil then
            local bExistInCachedList = false;
            for k,p in pairs(MidasManager.CachedProductInfoList) do
              if p.productId == v.productId then
                bExistInCachedList = true;
                p.currency = v.currency;
                p.price = v.price;
                p.timeStampLoaded = os.time();
              end
            end

            if bExistInCachedList == false then
              local temp_ProductInfo = {
                productId = v.productId,
                currency = v.currency,
                price = v.price,
                timeStampLoaded = os.time();
              };

              table.insert(MidasManager.CachedProductInfoList, temp_ProductInfo);
            end
          end
        end

        --取第一个商品判断其类型
        if MidasManager.productInfoParsed.productInfo[1].productId ~= nil then
          local productType = MidasManager.GetProductType(MidasManager.productInfoParsed.productInfo[1].productId);
          if productType == 1 then
            --充值
            EventSystem:postEvent(EVENTTYPE_MIDAS_NOTIFY,EVENTID_MIDAS_GET_RECHARGE_PRODUCT_INFO_NOTIFY, MidasManager.productInfoParsed.productInfo);
            return;
          elseif productType == 2 then
            --直购
            EventSystem:postEvent(EVENTTYPE_MIDAS_NOTIFY, EVENTID_MIDAS_GET_GOODS_PRODUCT_INFO_NOTIFY, MidasManager.productInfoParsed.productInfo);
            return;
          elseif productType == 3 then
            --月卡
            EventSystem:postEvent(EVENTTYPE_MIDAS_NOTIFY, EVENTID_MIDAS_GET_SUBSCRIBE_PRODUCT_INFO_NOTIFY, MidasManager.productInfoParsed.productInfo);
            return;
          end
        end
        
      end

    end
  end

  --拉取商品信息失败
  EventSystem:postEvent(EVENTTYPE_MIDAS_NOTIFY,EVENTID_MIDAS_GET_RECHARGE_PRODUCT_INFO_NOTIFY, nil);
  EventSystem:postEvent(EVENTTYPE_MIDAS_NOTIFY, EVENTID_MIDAS_GET_GOODS_PRODUCT_INFO_NOTIFY, nil);
  EventSystem:postEvent(EVENTTYPE_MIDAS_NOTIFY, EVENTID_MIDAS_GET_SUBSCRIBE_PRODUCT_INFO_NOTIFY, nil);

end

function MidasManager.OnGetIntroPrice(getIntroPriceCallBack)
  log("MidasManager received OnGetIntroPrice"..getIntroPriceCallBack.introPriceJson);

  local devicetype = 1;
  if string.lower(Client.GetDevicePlatformName()) == "ios" then
    devicetype = 0;
  end

  local introPriceJson = getIntroPriceCallBack.introPriceJson;
  
  --json解析
  local introPriceJsonParsed = json.decode (introPriceJson);
  
  if introPriceJsonParsed == nil then
    log("MidasManager.OnGetIntroPrice failed1");
    EventSystem:postEvent(EVENTTYPE_MIDAS_NOTIFY, EVENTID_MIDAS_GET_INTRO_PRICE_INFO_NOTIFY, false);
    return;
  end
  --拉取价格信息成功
  if introPriceJsonParsed.ret == nil or (introPriceJsonParsed.ret ~= "0" and introPriceJsonParsed.ret ~= 0) then
    log("MidasManager.OnGetIntroPrice failed2");
    EventSystem:postEvent(EVENTTYPE_MIDAS_NOTIFY, EVENTID_MIDAS_GET_INTRO_PRICE_INFO_NOTIFY, false);
    return;
  end
  
  local bSuccess = false;
  local mainEligibilityInfo = introPriceJsonParsed.gwallet_eligibility_info;
  local slaveEligibilityInfo = introPriceJsonParsed.eligibility_info;
  local priceInfo = introPriceJsonParsed.gwallet_productInfo;
  if devicetype == 0 then
    mainEligibilityInfo = introPriceJsonParsed.eligibility_info;
    slaveEligibilityInfo = introPriceJsonParsed.gwallet_eligibility_info;
    priceInfo = introPriceJsonParsed.productInfo;
  end
  
  if mainEligibilityInfo ~= nil and #mainEligibilityInfo> 0 then
    
    for i,v in pairs(mainEligibilityInfo) do
      
      if v.productid ~= nil and (v.num ~= nil or v.intro_num ~= nil) then
        
        local bFoundInCache = false;
        local cachedIntroPrice = nil;
        for k,p in pairs(MidasManager.CachedIntroPriceList) do
          if v.productid == p.productId then
            bFoundInCache = true;
            cachedIntroPrice = p;
          end
        end
        
        if not bFoundInCache then
          cachedIntroPrice = {
            productId = v.productid,
            currency = "",
            price = "",
            intro_price = "",
            intro_gwallet_num = 0,
            intro_ios_num = 0,
            timeStampLoaded = 0,
            isValid = false;
          };
          table.insert(MidasManager.CachedIntroPriceList, cachedIntroPrice);
          
        end
        
        cachedIntroPrice.isValid = false;
        cachedIntroPrice.timeStampLoaded = os.time();
        local bFoundInMainEligibility = false;
        if introPriceJsonParsed.eligibility_info ~= nil then
          for k,p in pairs(introPriceJsonParsed.eligibility_info) do
            if p.productid == cachedIntroPrice.productId and p.num ~= nil then
              cachedIntroPrice.intro_ios_num = p.num;
              if devicetype == 0 then
                bFoundInMainEligibility = true;
              end
            end
          end
        end

        if introPriceJsonParsed.gwallet_eligibility_info ~= nil then
          for k,p in pairs(introPriceJsonParsed.gwallet_eligibility_info) do
            if p.productid == cachedIntroPrice.productId and p.intro_num ~= nil then
              cachedIntroPrice.intro_gwallet_num = p.intro_num;
              if devicetype == 1 then
                bFoundInMainEligibility = true;
              end
            end
          end
        end

        if not bFoundInMainEligibility then
          log("MidasManager.OnGetIntroPrice failed3 in main eligibility_info" .. cachedIntroPrice.productId);
          EventSystem:postEvent(EVENTTYPE_MIDAS_NOTIFY, EVENTID_MIDAS_GET_INTRO_PRICE_INFO_NOTIFY, false);
          return;
        end

        bFoundInMainEligibility = false;
        if priceInfo ~= nil then
          for k,p in pairs(priceInfo) do
            if p.productId == cachedIntroPrice.productId and p.currency ~= nil and p.price ~= nil then
              cachedIntroPrice.currency = p.currency;
              cachedIntroPrice.price = p.price;
              if p.introPrice ~= nil then
                cachedIntroPrice.intro_price = p.introPrice;
              else
                cachedIntroPrice.intro_price = "";
              end
              bFoundInMainEligibility = true;
            end
          end
        end

        if not bFoundInMainEligibility then
          log("MidasManager.OnGetIntroPrice failed4");
          EventSystem:postEvent(EVENTTYPE_MIDAS_NOTIFY, EVENTID_MIDAS_GET_INTRO_PRICE_INFO_NOTIFY, false);
          return;
        end

        cachedIntroPrice.isValid = true;
      end
    end
  else
    log("MidasManager.OnGetIntroPrice failed5 eligibility_info is null or empty.");
    EventSystem:postEvent(EVENTTYPE_MIDAS_NOTIFY, EVENTID_MIDAS_GET_INTRO_PRICE_INFO_NOTIFY, false);
    return;
  end
  
  EventSystem:postEvent(EVENTTYPE_MIDAS_NOTIFY, EVENTID_MIDAS_GET_INTRO_PRICE_INFO_NOTIFY, true);
end

function MidasManager.OnApplicationEnterForeground()
  --Android切后台后回来重新，iOS没有补发货接口
  if string.lower(Client.GetDevicePlatformName()) == "android" then
    local curStatus = string.lower(LuaClassObj.GetGameStatus(bp_lobby));
    --充值、直购、月卡会调用Midas支付接口，这些界面不调用补发货，以免冲突
    if curStatus == "lobby" and RechargeUI.isShowing == false and Direct_Purchase_UI.isShowing == false then
      log("MidasManager try to reprovide.");
      MidasManager.Reprovide();
    end
  end
end

function MidasManager.Reprovide()
  local payChannel = Client.GetMidasPayChannel();
  if payChannel == "os_offical" then
    Client.MidasReprovide();
  end
end

function MidasManager.OnReprovide(reprovideCallBack)
  --log("MidasManager received OnReprovide");

  --补发货后，向后台请求一下当前余额
  NetUtil.SendPkg("igame_notify_client_charge", 0);
end

--判断商品的类型,1为uc币,2为直购物品,3为月卡
function MidasManager.GetProductType(productId)
  local rechargeTable = nil;

  -- if string.lower(Client.GetDevicePlatformName()) == "ios" then
  --   rechargeTable = Client.GetTable("RechargeLevel_IOS");
  -- else
  --   rechargeTable = Client.GetTable("RechargeLevel_Android");
  -- end
  rechargeTable = FuncUtil.GetRechargeLevelTable()

  if rechargeTable ~= nil then
    for i,v in pairs(rechargeTable) do
          if v.rechargeKey == productId then
            return 1;
          end
    end
  end

  --是不是月卡
  if BP_Normal_Productid == productId or BP_Super_Productid == productId or BP_Normal_MonthProductid == productId or BP_Super_MonthProductid == productId then
    return 3;
  end

  return 2;
end

--是否显示本地货币
function MidasManager.ShouldShowLocalCurrency (currency)
  if currency == nil then
      return false;
  end
  for k,v in pairs(MidasManager.localCurrencyArray) do
      if v == currency then
          return true;
      end
  end
  return false;
end

function MidasManager.GetPriceByProductId(productId, currency, oldPrice, needReload)
    log("MidasManager.GetPriceByProductId productId:"..tostring(productId));
    if not MidasManager.ShouldShowLocalCurrency(currency) then
        return oldPrice;
    end
    local result,productInfos = MidasManager.LoadCachedMidasProductInfo(productId);
    if not result or not productInfos or #productInfos<= 0 then
        -- 没有米大师数据或过期
        if needReload then
              local funcCall = function()
                  Client.LoadMidasProductInfo(productId);
              end
              -- 延时请求
              Timer.InsertTimer(0.2, funcCall,false, false);
        end
    else
        local info = productInfos[1];
        log("MidasManager.GetPriceByProductId price:"..tostring(info.price));
        return info.price or oldPrice;
    end
    log("MidasManager.GetPriceByProductId oldPrice:"..tostring(oldPrice));
    return oldPrice;
end

function MidasManager.LoadCachedMidasProductInfo(productList)

  if productList == nil then
    log("MidasManager.LoadCachedMidasProductInfo failed1");
    return false, nil;
  end

  local productarr = string.split(productList, ",");

  if productarr == nil then
    log("MidasManager.LoadCachedMidasProductInfo failed2");
    return false, nil;
  end

  --缓存信息是否过期
  local notExpiredCount = 0;
  local cachedProductInfoList = {};
  local curTimestamp = os.time();

  for i,v in pairs(productarr) do
    --判断请求的商品信息是不是都过期
    for k,productInfo in pairs(MidasManager.CachedProductInfoList) do
      if v == productInfo.productId and curTimestamp < productInfo.timeStampLoaded + MidasManager.CachedProductInfoExpireTime then
        notExpiredCount = notExpiredCount + 1;

        local cachedProductInfo = {
          productId = productInfo.productId,
          currency = productInfo.currency,
          price = productInfo.price,
        };

        table.insert(cachedProductInfoList, cachedProductInfo);
      end
    end
  end
  
  if notExpiredCount == #productarr then
    --商品都没过期，返回缓存结果
    log("MidasManager.LoadCachedMidasProductInfo success.");
    return true, cachedProductInfoList;
  end

  log("MidasManager.LoadCachedMidasProductInfo failed3");
  return false, nil;
end

function MidasManager.LoadCachedMidasIntroPrice(productList)

  if productList == nil then
    log("MidasManager.LoadCachedMidasIntroPrice failed1");
    return false, nil;
  end

  local productarr = string.split(productList, ",");

  if productarr == nil then
    log("MidasManager.LoadCachedMidasIntroPrice failed2");
    return false, nil;
  end

  --缓存信息是否过期
  local notExpiredCount = 0;
  local cachedProductInfoList = {};
  local curTimestamp = os.time();
  
  for i,v in pairs(productarr) do
    --判断请求的商品信息是不是都过期
    for k,productInfo in pairs(MidasManager.CachedIntroPriceList) do
      if v == productInfo.productId and productInfo.isValid == true and curTimestamp < productInfo.timeStampLoaded + MidasManager.CachedIntroPriceListExpireTime then
        notExpiredCount = notExpiredCount + 1;

        local cachedProductInfo = {
          productId = productInfo.productId,
          currency = productInfo.currency,
          price = productInfo.price,
          intro_price = productInfo.intro_price,
          intro_ios_num = productInfo.intro_ios_num,
          intro_gwallet_num = productInfo.intro_gwallet_num,
        };

        table.insert(cachedProductInfoList, cachedProductInfo);
      end
    end
  end
  
  if notExpiredCount == #productarr then
    --商品都没过期，返回缓存结果
    log("MidasManager.LoadCachedMidasIntroPrice success.");
    return true, cachedProductInfoList;
  end

  log("MidasManager.LoadCachedMidasIntroPrice failed3");
  return false, nil;
end

--运营活动是否过期
function MidasManager.IsMPExpire()
  --回调结果不对
  if string.len(MidasManager.getMPResultCode) == 0 or MidasManager.getMPResultCode ~= "0" then
    return true;
  end

  --缓存的运营活动为空
  if string.len(MidasManager.present_level) == 0 then
    return true;
  end
  
  --判断缓存是否过期
  if os.time() < MidasManager.CachedMPTimeStampLoaded + MidasManager.CachedMPExpireTime then
    return false;
  end

  return true;
end

-- 数字加上千分位逗号
local function FormatNumberThousands(num)
  local formatted = tostring(num or 0)
  local k;
  while true do
    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
    if k == 0 then
      break
    end
  end
  return formatted;
end

-- 转换价格描述(类似US$5,465.14），根据折扣价格得到原价
function MidasManager.TransformPrice(priceDesc, discount)
  local priceTemp = priceDesc;
  local priceNumDesc = string.gsub(priceTemp, "[,]?%s?", "")               -- 去除逗号和空格
  local priceNum = string.match(priceNumDesc,"(%d+[.]?%d*)") or 0;       -- 提取价格数字
  local price = tonumber(priceNum);
  local discount = tonumber(discount) or 1;                                      -- 得到折扣值

  if nil ~= price and 0 ~= discount then
      local defaultNum = string.format("%.2f", tonumber(priceNum) / discount);	-- 保留2位小数
      local formatNum  = FormatNumberThousands(defaultNum);                            -- 格式化数字,使用千分位逗号隔开
      formatNum =  string.gsub(priceNumDesc, priceNum, formatNum);
      return formatNum;
  end
  return priceDesc;
end

function MidasManager.on_report_reject_charge(reportResult)
  log("on_report_reject_charge: "..reportResult);
end


s2c["report_reject_charge_rsp"] = MidasManager.on_report_reject_charge;