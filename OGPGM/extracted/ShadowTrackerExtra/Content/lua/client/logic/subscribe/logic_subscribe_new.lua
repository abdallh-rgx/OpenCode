--------订阅相关逻辑层

NewSubscribeSystem = NewSubscribeSystem or
        {

            ---------------------------------ENUM START-------------------------------------------

            ENUM_SubStatus = {
                NONE = 0, --没订阅
                NormalStatus = 1, --普通订阅会员
                SuperStatus = 2, --高级订阅会员
                BothStatus = 3, --全部订阅
            }, --订阅状态
            ENUM_SubId = {
                Normal = 101, --普通ID
                Super = 201, --高级ID
            },


            ENUM_SubInfoID = --订阅特权配置ID
            {

                EVERYDAY_GET_UC = 1001, --高级订阅每日领取UC
                SHOP_BUY = 1002, --商城使用BP购买7,30,永久
                EXTRA_RP_SCORE = 1004, --每日可额外领取的RP积分
                DISCOUNT_ITEM = 1005, --每日折扣物品刷新
                DISCOUNT_BOX = 1006, --丰厚典藏宝箱0.2折
                Get_Award = 1007,       --每个月领取奖励
            },

            ---------------------------------ENUM END--------------------------------------------
---
            _Is_Succeed_Get_Prime_Data = false, --是否收到了订阅全量数据回包

            _IsFromBuy = false,  --收到订阅成功回调后为true

            _is_Subscribe_Open = false, --订阅是否开启

            _CurSubStatus = 0, --当前订阅状态缓存

            _NormalInfo = --普通订阅全局数据
            {
                _is_Open = false, --普通订阅是否开启
                _SubscribeID = "", --普通订阅ID
                _IsCouldGetFirstAward = false, --是否可以领取普通订阅周期奖励
                _show_price = "",   --从米大师拉过来的价格
                _tablePrice = "", --后台传过来的普通订阅美元价格保底数据
                _award_UC_Num = 0, --首次订阅奖励UC数量
                _left_time = 0, --剩余时间

                _InfoList = --普通订阅的优惠信息 展示用
                {
                    ["InfoID"] = --key：功能ID  value : 展示data table
                    {
                        Describe = "",
                        num = 0,
                    },
                },

                _EveryDayGetTimes = 0,  --每日领取UC 次数状态
            },

            _SuperInfo = --高级订阅全局数据
            {
                _is_Open = false, --高级订阅是否开启
                _SubscribeID = "", --高级订阅ID
                _IsCouldGetFirstAward = false, --是否可以领取高级订阅周期奖励
                _show_price = "",   --从米大师拉过来的价格
                _first_month_price = "", --首月折扣价格
                _first_motnth_tableprice = "US$4.99",   --从后台发过来的保底首月折扣价
                _tablePrice = "", --后台传过来的高级订阅美元价格保底数据
                _left_time = "", --剩余时间
                _award_UC_Num = 0, --首次订阅奖励UC数量
                _Is_Could_Take_Award = false,   --是否可以领取奖励
                _uniq_id = 0,       --当天每日折扣物品id
                _is_first_time_buy = false,
                _redpoint = false,  --BP直购红点信息
                _InfoList = --高级订阅的优惠信息 展示用
                {
                    ["InfoID"] = --key：功能ID  value : 展示data table
                    {
                        Describe = "",
                        num = 0,
                    },
                },
                _DropAwardList =    -- 首冲掉落奖励
                {

                },

                _EveryDayGetTimes = 0,  --每日领取UC 次数状态
            },
        }

--拉取订阅信息,登录拉取一次
function NewSubscribeSystem.PostReq()

    log("zino isopen subscribe.. " .. tostring(NewSubscribeSystem.GetIsPrimeOpen()))
    if not NewSubscribeSystem.GetIsPrimeOpen() or NewSubscribeSystem.IsJapanIP() then
        --屏蔽日本IP
        return
    end
    NetUtil.SendPkg("query_prime_info")
end

--屏蔽日本IP
function NewSubscribeSystem.IsJapanIP()
    -- body
    local strRegion = Client.GetPublishRegion()
    if strRegion == "JAPAN" then
        return true
    else
        return false
    end
end

--初始化一些数据
function NewSubscribeSystem.Init()
    -- body
    NewSubscribeSystem._NormalInfo._InfoList = {}
    NewSubscribeSystem._NormalInfo._NormalPrimeAddInfoList = {}
    NewSubscribeSystem._SuperInfo._InfoList = {}
    NewSubscribeSystem._SuperInfo._SuperPrimeAddInfoList = {}
    NewSubscribeSystem.SetSubStatus(NewSubscribeSystem.ENUM_SubStatus.NONE)

    NewSubscribeSystem._NormalInfo = --普通订阅全局数据
    {
        _is_Open = false, --普通订阅是否开启
        _SubscribeID = "", --普通订阅ID
        _IsCouldGetFirstAward = false, --是否可以领取普通订阅周期奖励
        _show_price = "",   --从米大师拉过来的价格
        _tablePrice = "", --后台传过来的普通订阅美元价格保底数据
        _award_UC_Num = 0, --首次订阅奖励UC数量
        _left_time = 0, --结束时间戳

        _InfoList = --普通订阅的优惠信息 展示用
        {

        },

        _EveryDayGetTimes = 0,  --每日领取UC 次数状态
    }

    NewSubscribeSystem._SuperInfo = --高级订阅全局数据
    {
        _is_Open = false, --高级订阅是否开启
        _SubscribeID = "", --高级订阅ID
        _IsCouldGetFirstAward = false, --是否可以领取高级订阅周期奖励
        _show_price = "",   --从米大师拉过来的价格
        _first_month_price = "", --首月折扣价格
        _first_motnth_tableprice = "US$4.99",   --从后台发过来的保底首月折扣价
        _tablePrice = "", --后台传过来的高级订阅美元价格保底数据
        _left_time = 0, --剩余时间
        _award_UC_Num = 0, --首次订阅奖励UC数量
        _uniq_id = 0,       --每日折扣特殊唯一ID
        _redpoint = false,  --BP直购红点信息

        _is_first_time_buy = false,
        _InfoList = --高级订阅的优惠信息 展示用
        {

        },
        _DropAwardList =    -- 首冲掉落奖励
        {

        },

        _EveryDayGetTimes = 0,  --每日领取UC 次数状态
    }
end

--登出处理
function NewSubscribeSystem.Handle_LogOut()
    log("NewSubscribeSystem log  out ")
    NewSubscribeSystem._Is_Succeed_Get_Prime_Data = false
    NewSubscribeSystem._IsFromBuy = false
end

--处理banner图红点
function NewSubscribeSystem.Handle_Banner_redpot(datachange)
    log("NewSubscribeSystem.Handle_Banner_redpot ")
    if datachange then
        LobbyUI:LobbyRedPointUpdate(BP_ENUM_MODULE_PRIME, true)
        return
    else
        local PlayerPrefs = slua.loadClass("/Game/UMG/UI_Utility/PlayerPrefs.PlayerPrefs")
        if PlayerPrefs then
            PlayerPrefs = PlayerPrefs:LoadData()
            local is_first_time_show_prime = PlayerPrefs:GetIsFirstTimeShowPrime()
            log("is_first_time_show_prime " .. tostring(is_first_time_show_prime))
            if is_first_time_show_prime then
                log("prime banner id " .. BP_ENUM_MODULE_PRIME)
                LobbyUI:LobbyRedPointUpdate(BP_ENUM_MODULE_PRIME, true)
                return
            end
        end
    end
    LobbyUI:LobbyRedPointUpdate(BP_ENUM_MODULE_PRIME, false)
    return
end


---------------------------------------------------------------SET GET function Start---------------------------------------------------------------
--Set订阅是否开启
function NewSubscribeSystem.SetPrimeOpen(activity_display_table)

    if activity_display_table then
        for i, v in pairs(activity_display_table) do
            if v.jump and v.jump == "game://?module=1008100" then   --说明是订阅
                local cur_time = FuncUtil.GetServerTimeInSec()
                if cur_time then
                    if v.start_time <cur_time and v.end_time > cur_time then
                        log("prime  open")
                        NewSubscribeSystem._is_Subscribe_Open = true

                        NewSubscribeSystem.PostReq()
                        NewSubscribeSystem.Handle_Banner_redpot(false)
                        return true
                    end
                end
            end
        end
    end
    NewSubscribeSystem._is_Subscribe_Open = false
    log("prime not open")
    return NewSubscribeSystem._is_Subscribe_Open
end

--Get订阅是否开启
function NewSubscribeSystem.GetIsPrimeOpen()
    log("get prime is open " ..tostring(NewSubscribeSystem._is_Subscribe_Open) )
    return NewSubscribeSystem._is_Subscribe_Open
end

--设置订阅状态
function NewSubscribeSystem.SetSubStatus(status)
    if status then
        NewSubscribeSystem._CurSubStatus = status
    end
end

--获取订阅状态
--枚举值：ENUM_SubStatus
function NewSubscribeSystem.GetSubStatus()
    -- body
    log("zino   CurSubStatus " .. tostring(NewSubscribeSystem._CurSubStatus))
    return NewSubscribeSystem._CurSubStatus
end

--普通订阅状态设置
function NewSubscribeSystem.Set_Is_Normal_Prime_Open(isopen)

    NewSubscribeSystem._NormalInfo._is_Open = isopen
end

function NewSubscribeSystem.Get_Is_Normal_Prime_Open()
    return NewSubscribeSystem._NormalInfo._is_Open
end

--高级订阅状态设置
function NewSubscribeSystem.Set_Is_Super_Prime_Open(isopen)

    NewSubscribeSystem._SuperInfo._is_Open = isopen
end

function NewSubscribeSystem.Get_Is_Super_Prime_Open()
    return NewSubscribeSystem._SuperInfo._is_Open
end

--获取订阅有效期剩余时间
function NewSubscribeSystem.Get_Left_Time(type)
    if type == NewSubscribeSystem.ENUM_SubId.Normal then
       -- log("NewSubscribeSystem._NormalInfo._left_time " .. NewSubscribeSystem._NormalInfo._left_time)
        if NewSubscribeSystem._NormalInfo._left_time then
            return tonumber(NewSubscribeSystem._NormalInfo._left_time)
        else

        end

    end
    if type == NewSubscribeSystem.ENUM_SubId.Super then
        if NewSubscribeSystem._SuperInfo._left_time then
            return tonumber(NewSubscribeSystem._SuperInfo._left_time)
        else
            return 0
        end
    end
end

--判定是否在有效期内
function NewSubscribeSystem.Get_Is_Valid(type)
    return FuncUtil.GetServerTimeInSec() < NewSubscribeSystem.Get_Left_Time(type)
end

--设置ProductID
function NewSubscribeSystem.Set_SubProduct_ID(type, productId)
    if type == NewSubscribeSystem.ENUM_SubId.Normal then
        NewSubscribeSystem._NormalInfo._SubscribeID = productId
    end
    if type == NewSubscribeSystem.ENUM_SubId.Super then
        NewSubscribeSystem._SuperInfo._SubscribeID = productId
    end
end

--读取product id
function NewSubscribeSystem.Get_SubProduct_ID(type)
    if type == NewSubscribeSystem.ENUM_SubId.Normal then
        return NewSubscribeSystem._NormalInfo._SubscribeID
    end
    if type == NewSubscribeSystem.ENUM_SubId.Super then
        return NewSubscribeSystem._SuperInfo._SubscribeID
    end
end

---Set 米大师拉过来的价格
function NewSubscribeSystem.Set_Price(type,price)
    if type and price then
        if type == NewSubscribeSystem.ENUM_SubId.Normal then
            NewSubscribeSystem._NormalInfo._show_price = price
        end

        if type == NewSubscribeSystem.ENUM_SubId.Super then
            NewSubscribeSystem._SuperInfo._show_price = price
        end
    end
end

function NewSubscribeSystem.Get_Price(type)
    if type then
        if type == NewSubscribeSystem.ENUM_SubId.Normal then
            if NewSubscribeSystem._NormalInfo._show_price == "" then
                log("get_price " ..NewSubscribeSystem._NormalInfo._tablePrice )
                --log("FuncUtil.LocalizeResFormat(6378,NewSubscribeSystem._NormalInfo._tablePrice)   " ..FuncUtil.LocalizeResFormat(6378,NewSubscribeSystem._NormalInfo._tablePrice))
                return FuncUtil.LocalizeResFormat(6378,NewSubscribeSystem._NormalInfo._tablePrice)
            end
            --log("FuncUtil.LocalizeResFormat(6378,NewSubscribeSystem._NormalInfo._tablePrice)   " ..FuncUtil.LocalizeResFormat(6378,NewSubscribeSystem._NormalInfo._show_price))
            return FuncUtil.LocalizeResFormat(6378,NewSubscribeSystem._NormalInfo._show_price)
        end
        if type == NewSubscribeSystem.ENUM_SubId.Super then
            if NewSubscribeSystem._SuperInfo._show_price == "" then
                --log("FuncUtil.LocalizeResFormat(6378,NewSubscribeSystem._NormalInfo._tablePrice)   " ..FuncUtil.LocalizeResFormat(6378,NewSubscribeSystem._SuperInfo._tablePrice))
                return FuncUtil.LocalizeResFormat(6378,NewSubscribeSystem._SuperInfo._tablePrice)
            end
           -- log("FuncUtil.LocalizeResFormat(6378,NewSubscribeSystem._NormalInfo._tablePrice)   " ..FuncUtil.LocalizeResFormat(6378,NewSubscribeSystem._SuperInfo._show_price))
            return FuncUtil.LocalizeResFormat(6378,NewSubscribeSystem._SuperInfo._show_price)
        end
    end
end

--设置首月折扣价格
function NewSubscribeSystem.Set_First_Month_Price(price,isshowlocalprice)
    if NewSubscribeSystem._SuperInfo._is_first_time_buy then
        if isshowlocalprice and price and price ~= "" then
            NewSubscribeSystem._SuperInfo._first_month_price = price
        else
            if NewSubscribeSystem._SuperInfo._first_motnth_tableprice then
                NewSubscribeSystem._SuperInfo._first_month_price = NewSubscribeSystem._SuperInfo._first_motnth_tableprice
            else
                NewSubscribeSystem._SuperInfo._first_month_price = "US$4.99"
            end

        end
    else
        NewSubscribeSystem._SuperInfo._first_month_price = ""
    end


end

--获取首月折扣价格
function NewSubscribeSystem.Get_First_Month_Price()
    return NewSubscribeSystem._SuperInfo._first_month_price
end

function NewSubscribeSystem.Get_EveryDay_GetTimes(type)
    log("type ~~~~~~~~ " .. type)
    if type == NewSubscribeSystem.ENUM_SubId.Normal then
        log("normal _EveryDayGetTimes " .. tostring(NewSubscribeSystem._NormalInfo._EveryDayGetTimes))
        return NewSubscribeSystem._NormalInfo._EveryDayGetTimes
    end

    if type == NewSubscribeSystem.ENUM_SubId.Super then
        log("_SuperInfo _EveyDayGetTimes " .. tostring(NewSubscribeSystem._SuperInfo._EveryDayGetTimes))
        return NewSubscribeSystem._SuperInfo._EveryDayGetTimes
    end

end



--给唯一显示补领次数的地方准备的
function NewSubscribeSystem.Get_EveryDay_Times_Buy_Status(status)
    log("status ~~~~~~" .. status)
    if status == NewSubscribeSystem.ENUM_SubStatus.NormalStatus then
        log("Get_EveryDay_Times_Buy_Status times " .. tostring(NewSubscribeSystem._NormalInfo._EveryDayGetTimes))
        return NewSubscribeSystem._NormalInfo._EveryDayGetTimes
    end

    if status == NewSubscribeSystem.ENUM_SubStatus.SuperStatus then
        log("Get_EveryDay_Times_Buy_Status times " .. tostring(NewSubscribeSystem._SuperInfo._EveryDayGetTimes))
        return NewSubscribeSystem._SuperInfo._EveryDayGetTimes
    end

    if status == NewSubscribeSystem.ENUM_SubStatus.BothStatus then
        if NewSubscribeSystem._NormalInfo._EveryDayGetTimes > NewSubscribeSystem._SuperInfo._EveryDayGetTimes then
            log("Get_EveryDay_Times_Buy_Status times " .. tostring(NewSubscribeSystem._NormalInfo._EveryDayGetTimes))
            return NewSubscribeSystem._NormalInfo._EveryDayGetTimes
        else
            log("Get_EveryDay_Times_Buy_Status times " .. tostring(NewSubscribeSystem._SuperInfo._EveryDayGetTimes))
            return NewSubscribeSystem._SuperInfo._EveryDayGetTimes
        end
    end
end

--获取每日UC 的展示数目
function NewSubscribeSystem.GetShowNum()
    local curstatus = NewSubscribeSystem.GetSubStatus()
    local num_normal = NewSubscribeSystem._NormalInfo._InfoList[NewSubscribeSystem.ENUM_SubInfoID.EVERYDAY_GET_UC].num
    local num_super = NewSubscribeSystem._SuperInfo._InfoList[NewSubscribeSystem.ENUM_SubInfoID.EVERYDAY_GET_UC].num
    if curstatus == NewSubscribeSystem.ENUM_SubStatus.NormalStatus then
        log("num_normal " .. tostring(num_normal))
        return num_normal
    end

    if curstatus == NewSubscribeSystem.ENUM_SubStatus.SuperStatus then
        return num_super
    end

    if curstatus == NewSubscribeSystem.ENUM_SubStatus.BothStatus then
        log("num_normal " .. tostring(num_normal))
        log("num_super " .. tostring(num_super))
        if NewSubscribeSystem._NormalInfo._EveryDayGetTimes > NewSubscribeSystem._SuperInfo._EveryDayGetTimes then
            return num_normal
        elseif NewSubscribeSystem._NormalInfo._EveryDayGetTimes < NewSubscribeSystem._SuperInfo._EveryDayGetTimes then
            return num_super
        else
            return num_normal + num_super
        end

    end

end

--获取补给状态是否可以领取
--true为可用
--false不可用
function NewSubscribeSystem.Get_Supply_Status()
    if not NewSubscribeSystem.GetIsPrimeOpen() then
        return false
    end

    if not NewSubscribeSystem.Get_Is_Super_Prime_Open() then
        return false
    end

    local iscouldbuy = NewSubscribeSystem._SuperInfo._InfoList[NewSubscribeSystem.ENUM_SubInfoID.DISCOUNT_BOX].iscouldbuy
    if iscouldbuy == true then
        log("iscouldbuy" .. tostring(iscouldbuy))
        return iscouldbuy
    end
end

--获取补给折扣额度
function NewSubscribeSystem.Get_Supply_Discount_Num()
    local num = NewSubscribeSystem._SuperInfo._InfoList[NewSubscribeSystem.ENUM_SubInfoID.DISCOUNT_BOX].num
    if num then
        return num
    end
end


--获取UPASS积分数量
function NewSubscribeSystem.Get_UPASS_Num()
    local num = NewSubscribeSystem._SuperInfo._InfoList[NewSubscribeSystem.ENUM_SubInfoID.EXTRA_RP_SCORE].num
    if num then
        return num
    end
end

-- 设置UPASS 领取状态
function NewSubscribeSystem.Set_UPASS_Is_Take(is_take)
    if NewSubscribeSystem._SuperInfo._InfoList[NewSubscribeSystem.ENUM_SubInfoID.EXTRA_RP_SCORE] then
        NewSubscribeSystem._SuperInfo._InfoList[NewSubscribeSystem.ENUM_SubInfoID.EXTRA_RP_SCORE].iscouldbuy = is_take
    end
end

--获取UPASS领取状态是否可以领取
function NewSubscribeSystem.Get_UPASS_Is_Take()
    local iscouldbuy = NewSubscribeSystem._SuperInfo._InfoList[NewSubscribeSystem.ENUM_SubInfoID.EXTRA_RP_SCORE].iscouldbuy
    if iscouldbuy then
        return iscouldbuy
    else
        return false
    end
end

--设置订阅里每日折扣物品是否可领取
function NewSubscribeSystem.Set_Discount_Is_Take(is_take)
    if NewSubscribeSystem._SuperInfo._InfoList[NewSubscribeSystem.ENUM_SubInfoID.DISCOUNT_ITEM] then
        NewSubscribeSystem._SuperInfo._InfoList[NewSubscribeSystem.ENUM_SubInfoID.DISCOUNT_ITEM].iscouldbuy = is_take
    end
end

--获得订阅里每日折扣物品是否可领取
function NewSubscribeSystem.Get_Discount_Is_Could_Buy()
    local iscouldbuy = NewSubscribeSystem._SuperInfo._InfoList[NewSubscribeSystem.ENUM_SubInfoID.DISCOUNT_ITEM].iscouldbuy
    if iscouldbuy then
        return iscouldbuy
    else
        return false
    end
end
--设置订阅里每日折扣物品配置信息
function NewSubscribeSystem.Set_Discount_Item_Info(item_id, money_type, sale_price, ori_price, sale, item_num,uniq_id)
    if NewSubscribeSystem._SuperInfo._InfoList[NewSubscribeSystem.ENUM_SubInfoID.DISCOUNT_ITEM] then
        NewSubscribeSystem._SuperInfo._InfoList[NewSubscribeSystem.ENUM_SubInfoID.DISCOUNT_ITEM].item_id = item_id
        NewSubscribeSystem._SuperInfo._InfoList[NewSubscribeSystem.ENUM_SubInfoID.DISCOUNT_ITEM].money_type = money_type
        NewSubscribeSystem._SuperInfo._InfoList[NewSubscribeSystem.ENUM_SubInfoID.DISCOUNT_ITEM].sale_price = sale_price
        NewSubscribeSystem._SuperInfo._InfoList[NewSubscribeSystem.ENUM_SubInfoID.DISCOUNT_ITEM].ori_price = ori_price
        NewSubscribeSystem._SuperInfo._InfoList[NewSubscribeSystem.ENUM_SubInfoID.DISCOUNT_ITEM].sale = sale
        NewSubscribeSystem._SuperInfo._InfoList[NewSubscribeSystem.ENUM_SubInfoID.DISCOUNT_ITEM].item_num = item_num
        NewSubscribeSystem._SuperInfo._uniq_id = uniq_id
    end
end

--获得订阅里每日折扣物品ID
function NewSubscribeSystem.Get_Discount_ITemID()
    if NewSubscribeSystem._SuperInfo._InfoList[NewSubscribeSystem.ENUM_SubInfoID.DISCOUNT_ITEM].item_id then
        return NewSubscribeSystem._SuperInfo._InfoList[NewSubscribeSystem.ENUM_SubInfoID.DISCOUNT_ITEM].item_id
    end
end

--设置是否可以领取订阅奖励
function NewSubscribeSystem.Set_Is_Could_Take_Award(is_could_take)
    NewSubscribeSystem._SuperInfo._Is_Could_Take_Award = is_could_take
end

--获取是否可以领取奖励
function NewSubscribeSystem.Get_Is_Could_Take_Award()
    if NewSubscribeSystem._SuperInfo._Is_Could_Take_Award then
        return NewSubscribeSystem._SuperInfo._Is_Could_Take_Award
    else
        return false
    end
end

function NewSubscribeSystem.Get_uniq_id()
    if NewSubscribeSystem._SuperInfo._uniq_id then
        log("NewSubscribeSystem.uniq_id  " .. tostring(NewSubscribeSystem._SuperInfo._uniq_id ))
        return NewSubscribeSystem._SuperInfo._uniq_id
    end
end

---------------------------------------------------------------SET GET function END---------------------------------------------------------------

--显示订阅面板入口
function NewSubscribeSystem.ShowSubscribe()
    -- body
    if not NewSubscribeSystem._Is_Succeed_Get_Prime_Data then
        log("NewSubscribeSystem._Is_Succeed_Get_Prime_Data " .. tostring(NewSubscribeSystem._Is_Succeed_Get_Prime_Data))
        NewSubscribeSystem._IsFromBuy = true
        NewSubscribeSystem.PostReq()
        return
    end
    if NewSubscribeSystem.GetSubStatus() == NewSubscribeSystem.ENUM_SubStatus.NONE then
        --没开通订阅
        --展示第一级订阅界面
        local uiManager = require("ui.manager")
        if uiManager then
            uiManager.ShowUI(uiManager.UI_Config.ui_subscribe_buy)
        end
    else
        --开通了订阅 展示二级订阅界面

        local uiManager = require("ui.manager")
        if uiManager then
            uiManager.ShowUI(uiManager.UI_Config.ui_subscribe)
        end
    end
    local PlayerPrefs = slua.loadClass("/Game/UMG/UI_Utility/PlayerPrefs.PlayerPrefs")
    if PlayerPrefs then
        PlayerPrefs = PlayerPrefs:LoadData()
        PlayerPrefs:SetIsFirstTimeShowPrime()
    end
    NewSubscribeSystem.Handle_Banner_redpot(false)

end

function NewSubscribeSystem.CloseSubscribeUI()
    local uiManager = require("ui.manager");
    if uiManager then
        uiManager.CloseUI(uiManager.UI_Config.ui_subscribe)
    end
end

--屏蔽日本IP
function NewSubscribeSystem.IsJapanIP()
    -- body
    local strRegion = Client.GetPublishRegion()
    if strRegion == "JAPAN" then
        return true
    else
        return false
    end
end

---收到订阅全部信息下发
---cfg : 配置信息
---prime : 状态信息
function NewSubscribeSystem.on_query_prime_info(prime_success, cfg, prime,discountbuy)

    if prime_success and prime_success == 0 then


        NewSubscribeSystem.Init()   --初始化数据

        NewSubscribeSystem._Is_Succeed_Get_Prime_Data = true    --Cached 收到数据状态

        if cfg and next(cfg) then
            log_tree("cfg", cfg)
            if cfg.priv then
                NewSubscribeSystem.Cached_Describe_Info(cfg.priv)
            end

            if cfg.buy then
                --订阅首次购买奖励信息
                NewSubscribeSystem.Cached_FirstBuy_RewardInfo(cfg.buy)
            end
        end

        if discountbuy then
            log_tree("discountbuy", discountbuy)
            NewSubscribeSystem.Cached_Discount_Item_Data(discountbuy)
        end

        --这个要放到最后处理 因为post 了 收到数据协议
        if prime then
            log_tree("prime", prime)
            NewSubscribeSystem.Handle_Prime_Status(prime)
        else
            log("NewSubscribeSystem._SuperInfo._is_first_time_buy = true")
            NewSubscribeSystem._SuperInfo._is_first_time_buy = true
        end


        --收到状态变更 post event



    end

end

function NewSubscribeSystem.Cached_Discount_Item_Data(data)
    if data then
        if data.item_id and data.sale_price and data. ori_price and data.money_type and data.item_num and data.sale and data.uniq_id then
            NewSubscribeSystem.Set_Discount_Item_Info(data.item_id,data.money_type,data.sale_price,data.ori_price,data.sale,data.item_num,data.uniq_id)
        end

    end
end
--cache普通订阅优惠文字描述内容
function NewSubscribeSystem.Cached_Describe_Info(priv_info)
    -- body
    if priv_info then
        if priv_info[NewSubscribeSystem.ENUM_SubId.Normal] then

            for k, v in pairs(priv_info[NewSubscribeSystem.ENUM_SubId.Normal]) do
                local TempOneInfo = {}
                if v.privilege_type_des then
                    TempOneInfo.Describe = v.privilege_type_des
                end
                if v.privilege_des then
                    TempOneInfo.Name = v.privilege_des
                end
                if v.privilege_num then
                    TempOneInfo.num = v.privilege_num
                end
                NewSubscribeSystem._NormalInfo._InfoList[tonumber(k)] = TempOneInfo
            end
        end
        if priv_info[NewSubscribeSystem.ENUM_SubId.Super] then

            for k, v in pairs(priv_info[NewSubscribeSystem.ENUM_SubId.Super]) do
                local TempOneInfo = {}
                if v.privilege_type_des then
                    TempOneInfo.Describe = v.privilege_type_des
                end
                if v.privilege_des then
                    TempOneInfo.Name = v.privilege_des
                end
                if v.privilege_num then
                    TempOneInfo.num = v.privilege_num
                end
                NewSubscribeSystem._SuperInfo._InfoList[tonumber(k)] = TempOneInfo
            end
        end
    end
end


--cache 普通订阅首次购买奖励信息
function NewSubscribeSystem.Cached_FirstBuy_RewardInfo(buy_info)
    -- body
    if buy_info then
        if buy_info[NewSubscribeSystem.ENUM_SubId.Normal] then
            local normal_buy_info = buy_info[NewSubscribeSystem.ENUM_SubId.Normal]
            if normal_buy_info.productid then
                NewSubscribeSystem.Set_SubProduct_ID(NewSubscribeSystem.ENUM_SubId.Normal,normal_buy_info.productid)
            end
            if normal_buy_info.prime_price then
                NewSubscribeSystem._NormalInfo._tablePrice = normal_buy_info.prime_price
            end
        end

        if buy_info[NewSubscribeSystem.ENUM_SubId.Super] then
            local super_buy_info = buy_info[NewSubscribeSystem.ENUM_SubId.Super]
            if super_buy_info.productid then
                NewSubscribeSystem.Set_SubProduct_ID(NewSubscribeSystem.ENUM_SubId.Super,super_buy_info.productid)
            end
            if super_buy_info.prime_price then
                NewSubscribeSystem._SuperInfo._tablePrice = super_buy_info.prime_price
            end
            if super_buy_info.item_num_UC then
                NewSubscribeSystem._SuperInfo._award_UC_Num = super_buy_info.item_num_UC
            end
            if super_buy_info.first_time_price then
                NewSubscribeSystem._SuperInfo._first_motnth_tableprice = super_buy_info.first_time_price
            end
            if super_buy_info.drop and next(super_buy_info.drop) then
                NewSubscribeSystem._SuperInfo._DropAwardList = {}
                for k, v in pairs(super_buy_info.drop) do
                    if tonumber(v.item_id) ~= 1006 then
                        local tempdrop = {}
                        tempdrop.itemid = v.item_id
                        tempdrop.itemnum = v.item_num
                        table.insert(NewSubscribeSystem._SuperInfo._DropAwardList,tempdrop)
                    end
                end
            end
        end
    end
end

function NewSubscribeSystem.on_notify_prime_change(data,dailyinfo,redpoint)
    if dailyinfo then
        log_tree("dailyinfo",dailyinfo)
        NewSubscribeSystem.Cached_Discount_Item_Data(dailyinfo)
    end
    if redpoint then
        log("redpoint " .. tostring(redpoint))
        NewSubscribeSystem.Handle_Banner_redpot(true)
        NewSubscribeSystem._SuperInfo._redpoint = true
    end
    if data then
        log_tree("on_notify_prime_change data", data)
        NewSubscribeSystem.Handle_Prime_Status(data)
    end

end

--缓存全部状态信息
function NewSubscribeSystem.Handle_Prime_Status(data)
    if data then

        if data.uniq_id then
            log("data.uniq_id " .. tostring(data.uniq_id))
            NewSubscribeSystem._SuperInfo._uniq_id = data.uniq_id
        end

        local Normal_Data = data[NewSubscribeSystem.ENUM_SubId.Normal]
        if Normal_Data and next(Normal_Data) then
            if FuncUtil.GetServerTimeInSec() < Normal_Data.end_time then
                --说明在时间范围内
                NewSubscribeSystem.Set_Is_Normal_Prime_Open(true)
                NewSubscribeSystem._NormalInfo._left_time = Normal_Data.end_time  --记录结束时间
            else
                NewSubscribeSystem.Set_Is_Normal_Prime_Open(false)
            end

            if Normal_Data.priv then
                if Normal_Data.priv[NewSubscribeSystem.ENUM_SubInfoID.EVERYDAY_GET_UC] then
                    if Normal_Data.priv[NewSubscribeSystem.ENUM_SubInfoID.EVERYDAY_GET_UC].times then

                        NewSubscribeSystem._NormalInfo._EveryDayGetTimes = Normal_Data.priv[NewSubscribeSystem.ENUM_SubInfoID.EVERYDAY_GET_UC].times
                        log("NewSubscribeSystem._NormalInfo._EveryDayGetTimes" .. NewSubscribeSystem._NormalInfo._EveryDayGetTimes)
                    end
                end
            end
        end

        local Super_Data = data[NewSubscribeSystem.ENUM_SubId.Super]

        if Super_Data and next(Super_Data) then
            if FuncUtil.GetServerTimeInSec() < Super_Data.end_time then
                --说明在时间范围内
                NewSubscribeSystem.Set_Is_Super_Prime_Open(true)
                NewSubscribeSystem._SuperInfo._left_time = Super_Data.end_time   --记录结束时间
            else
                NewSubscribeSystem.Set_Is_Super_Prime_Open(false)
            end
            if Super_Data.priv then
                log_tree("Super_Data.priv",Super_Data.priv)
                if Super_Data.priv[NewSubscribeSystem.ENUM_SubInfoID.EVERYDAY_GET_UC] then
                    if Super_Data.priv[NewSubscribeSystem.ENUM_SubInfoID.EVERYDAY_GET_UC].times then
                        NewSubscribeSystem._SuperInfo._EveryDayGetTimes = Super_Data.priv[NewSubscribeSystem.ENUM_SubInfoID.EVERYDAY_GET_UC].times
                        log("NewSubscribeSystem._SuperInfo._EveryDayGetTimes" .. NewSubscribeSystem._SuperInfo._EveryDayGetTimes)
                    end
                end

                if Super_Data.priv[NewSubscribeSystem.ENUM_SubInfoID.DISCOUNT_BOX] ~= nil then
                    log("Super_Data.priv[NewSubscribeSystem.ENUM_SubInfoID.DISCOUNT_BOX] " .. tostring(Super_Data.priv[(NewSubscribeSystem.ENUM_SubInfoID.DISCOUNT_BOX)]))
                    NewSubscribeSystem._SuperInfo._InfoList[NewSubscribeSystem.ENUM_SubInfoID.DISCOUNT_BOX].iscouldbuy =
                    Super_Data.priv[NewSubscribeSystem.ENUM_SubInfoID.DISCOUNT_BOX]
                end

                if Super_Data.priv[NewSubscribeSystem.ENUM_SubInfoID.EXTRA_RP_SCORE] ~= nil then
                    NewSubscribeSystem.Set_UPASS_Is_Take(Super_Data.priv[NewSubscribeSystem.ENUM_SubInfoID.EXTRA_RP_SCORE])
                end
                if Super_Data.priv[NewSubscribeSystem.ENUM_SubInfoID.DISCOUNT_ITEM] and Super_Data.priv[NewSubscribeSystem.ENUM_SubInfoID.DISCOUNT_ITEM]._uniq_id then
                    NewSubscribeSystem._SuperInfo._uniq_id = Super_Data.priv[NewSubscribeSystem.ENUM_SubInfoID.DISCOUNT_ITEM].uniq_id
                end
                if Super_Data.priv[NewSubscribeSystem.ENUM_SubInfoID.DISCOUNT_ITEM] then
                    if Super_Data.priv[NewSubscribeSystem.ENUM_SubInfoID.DISCOUNT_ITEM].status then
                        NewSubscribeSystem.Set_Discount_Is_Take(Super_Data.priv[NewSubscribeSystem.ENUM_SubInfoID.DISCOUNT_ITEM].status)
                    end
                end
            end

            if Super_Data.first_reward then
                NewSubscribeSystem.Set_Is_Could_Take_Award(Super_Data.first_reward)
            end
        else
            log("            NewSubscribeSystem._SuperInfo._is_first_time_buy = true")
            NewSubscribeSystem._SuperInfo._is_first_time_buy = true
        end

        --判定四种状态中的哪种
        if not NewSubscribeSystem.Get_Is_Normal_Prime_Open() and not NewSubscribeSystem.Get_Is_Super_Prime_Open() then
            NewSubscribeSystem.SetSubStatus(NewSubscribeSystem.ENUM_SubStatus.NONE)
        elseif NewSubscribeSystem.Get_Is_Normal_Prime_Open() and not NewSubscribeSystem.Get_Is_Super_Prime_Open() then
            NewSubscribeSystem.SetSubStatus(NewSubscribeSystem.ENUM_SubStatus.NormalStatus)
        elseif not NewSubscribeSystem.Get_Is_Normal_Prime_Open() and NewSubscribeSystem.Get_Is_Super_Prime_Open() then
            NewSubscribeSystem.SetSubStatus(NewSubscribeSystem.ENUM_SubStatus.SuperStatus)
        elseif NewSubscribeSystem.Get_Is_Normal_Prime_Open() and NewSubscribeSystem.Get_Is_Super_Prime_Open() then
            NewSubscribeSystem.SetSubStatus(NewSubscribeSystem.ENUM_SubStatus.BothStatus)
        end
    end

    if NewSubscribeSystem._IsFromBuy then
        --展示过 此值为false
        log("_isfrombuy == true")
        NewSubscribeSystem.ShowSubscribe()
        NewSubscribeSystem._IsFromBuy = false
    end
    EventSystem:postEvent(EVENTTYPE_SUBSCRIBE,EVENTID_SUBSCRIBE_GET_STATUS_DATA)


end

function NewSubscribeSystem.On_take_daily_uc_priv(ret,number,super_times,normal_times)
    --local prime_success = 0
    --local prime_err_param = 100   --请求参数错误
    --local prime_err_sys = 101  --系统错误
    --local prime_err_not_prime = 102 --非会员
    --local prime_err_have_take_daily_award = 103 --已领取过当日奖励
    --local prime_err_bp_not_enough = 104 --bp不够
    --local prime_err_not_plus = 105 --非高级会员

    if ret then
        if ret == 0 then
            log("ret " .. ret)
            if super_times then
                log("super_times " .. super_times)
                NewSubscribeSystem._SuperInfo._EveryDayGetTimes = super_times
            end
            if normal_times then
                log("normal_times " .. normal_times)
                NewSubscribeSystem._NormalInfo._EveryDayGetTimes = normal_times
            end
            if number then
                local arrayItemData = {};
                table.insert(arrayItemData, {res_id = 1006, count = number});
                CommonItemGetUI:ShowPanel(arrayItemData);
                EventSystem:postEvent(EVENTTYPE_SUBSCRIBE, EVENTID_SUBSCRIBE_GET_UC_DATA,number)
            end

            return
        end
        if ret == 103 then
            DataMgr.ShowNoticeByID(6503)
        end
        if ret == 104 then
            DataMgr.ShowNoticeByID(FuncUtil.GetLocalizeResStr(6494))
        end

    end
    --to doing : 刷新订阅界面
end

function NewSubscribeSystem.On_take_daily_rp_priv(ret)
    --local prime_success = 0
    --local prime_err_param = 100   --请求参数错误
    --local prime_err_sys = 101  --系统错误
    --local prime_err_not_prime = 102 --非会员
    --local prime_err_have_take_daily_award = 103 --已领取过当日奖励
    --local prime_err_bp_not_enough = 104 --bp不够
    --local prime_err_not_plus = 105 --非高级会员
    --local prime_err_not_rp_season = 106 --非RP赛季
    --local prime_err_refresh = 107 --物品已刷新

    if ret then
        if ret == 0 then
            NewSubscribeSystem.Set_UPASS_Is_Take(false) --领取成功后变为不可领取
            EventSystem:postEvent(EVENTTYPE_SUBSCRIBE, EVENTID_SUBSCRIBE_GET_RP_DATA)
            local arrayItemData = {};
            table.insert(arrayItemData, {res_id = 1099, count = NewSubscribeSystem.Get_UPASS_Num()});
            CommonItemGetUI:ShowPanel(arrayItemData);
        end

        if ret == 103 then
            DataMgr.ShowNoticeByID(6503)
        end
        if ret == 104 then
            DataMgr.ShowNoticeByID(FuncUtil.GetLocalizeResStr(6494))
        end
        if ret == 106 then
            DataMgr.ShowNoticeByID(6794)
        end
    end
end

function NewSubscribeSystem.On_buy_discount_sale_item_rsp(ret,item_id,item_num)
    --local prime_success = 0
    --local prime_err_param = 100   --请求参数错误
    --local prime_err_sys = 101  --系统错误
    --local prime_err_not_prime = 102 --非会员
    --local prime_err_have_take_daily_award = 103 --已领取过当日奖励
    --local prime_err_not_enough = 104 --bp不够
    --local prime_err_not_plus = 105 --非高级会员
    --local prime_err_not_rp_season = 106 --非RP赛季
    --local prime_err_refresh = 107 --物品已刷新
    if ret then
        log("ret " .. ret)
        if ret == 0 then

            if item_id then
                log("On_buy_discount_sale_itemid " ..item_id)

            end

            if item_num then
                NewSubscribeSystem._SuperInfo._InfoList[NewSubscribeSystem.ENUM_SubInfoID.DISCOUNT_ITEM].item_num = item_num
                log("On_buy_discount_sale_item num " ..item_num)
            end
            if item_num and item_id then
                local arrayItemData = {};
                table.insert(arrayItemData, {res_id = item_id, count = item_num});
                CommonItemGetUI:ShowPanel(arrayItemData);
                NewSubscribeSystem.Set_Discount_Is_Take(false)
            end
            EventSystem:postEvent(EVENTTYPE_SUBSCRIBE,EVENTID_SUBSCRIBE_DAILYSHOP_DATA)
        end

        if ret == 103 then
            DataMgr.ShowNoticeByID(4793)
        end
        if ret == 104 then
            DataMgr.ShowNoticeByID(6494)
            NewSubscribeSystem.BPNotEnough()
        end

    end
end

function NewSubscribeSystem.BPNotEnough()
    local str = string.format(FuncUtil.LocalizeResFormat(501052,StoreFuncUtils.GetMoneyName(1006)))
    CommonMessageBoxUI:ShowPanel(2, FuncUtil.GetLocalizeResStr(101001), str,
            function()
                RechargeUI:Init();
            end);
end

-- 拉取打折价格和正常的价格
function NewSubscribeSystem.LoadPrice()
    -- body
    log("NewSubscribeSystem load price ")
    if NewSubscribeSystem.Get_SubProduct_ID(NewSubscribeSystem.ENUM_SubId.Normal) ~= "" and NewSubscribeSystem.Get_SubProduct_ID(NewSubscribeSystem.ENUM_SubId.Super) ~= "" then
        local productid_str = string.format("%s,%s", NewSubscribeSystem.Get_SubProduct_ID(NewSubscribeSystem.ENUM_SubId.Normal),
                NewSubscribeSystem.Get_SubProduct_ID(NewSubscribeSystem.ENUM_SubId.Super))
        local isProductInfoCached,cachedProductInfoList = MidasManager.LoadCachedMidasIntroPrice(productid_str);
        if isProductInfoCached then
            log_tree("zino cachedProductInfoList", cachedProductInfoList)
            NewSubscribeSystem.GetMidasGoodsInfo(EVENTTYPE_MIDAS_NOTIFY, EVENTID_MIDAS_GET_INTRO_PRICE_INFO_NOTIFY, cachedProductInfoList)	--处理非打折价格
            NewSubscribeSystem.GetMidasIntroInfo(EVENTTYPE_MIDAS_NOTIFY,EVENTID_MIDAS_GET_INTRO_PRICE_INFO_NOTIFY,cachedProductInfoList)
        else
            if Client.IsCEVersion() then
                ConnectionWaitingUI:Show()
            end
            local funcCall1 = function() ConnectionWaitingUI:Hide() end
            Timer.InsertTimer(20, funcCall1, false, false)
            log("LoadMidasProductIntroInfo")
            Client.LoadMidasIntroPrice(productid_str)
        end
    end
end

--收到购买订阅回调信息
function NewSubscribeSystem.buy_callback(evenType, eventID, resultCode)
    ConnectionWaitingUI:Hide()
    if (resultCode == nil) then
        log("拉取数据失败");
        return ;
    end

    log_tree("zino prime buy_callback resultCode", resultCode);
    --购买成功
    if tonumber(resultCode) == 0 then
        --告诉服务器去拉米大师刷新
        log("igame_notify_client_charge")
        NetUtil.SendPkg("igame_notify_client_charge", 0)
        NewSubscribeSystem._IsFromBuy = true
        EventSystem:postEvent(EVENTTYPE_SUBSCRIBE,EVENTID_SUBSCRIBE_Buy_Succeed)
    end

end

--收到米大师回调的订阅价格信息
function NewSubscribeSystem.GetMidasGoodsInfo(evenType, eventID, resultTable)

    if (resultTable == nil) then
        log("GetMidasPriceInfo拉取数据失败")
        ConnectionWaitingUI:Hide()
        return
    end
    log_tree("zino GetMidasGoodsInfo resultTable", resultTable);

    for k, product in pairs(resultTable) do
        if MidasManager.ShouldShowLocalCurrency(product.currency) == false then
            
            return ;
        end

        if product.productId ~= nil and product.price ~= nil then
            if product.productId == NewSubscribeSystem.Get_SubProduct_ID(NewSubscribeSystem.ENUM_SubId.Normal) then
                log("product.Normalprice " .. product.price)
                NewSubscribeSystem.Set_Price(NewSubscribeSystem.ENUM_SubId.Normal,product.price)

            elseif product.productId == NewSubscribeSystem.Get_SubProduct_ID(NewSubscribeSystem.ENUM_SubId.Super) then
                log("product.Superprice " .. product.price)
                NewSubscribeSystem.Set_Price(NewSubscribeSystem.ENUM_SubId.Super,product.price)
            end

            local ui_manager = require("ui.manager")
            local curstatus = NewSubscribeSystem.GetSubStatus()
            if curstatus > NewSubscribeSystem.ENUM_SubStatus.NONE then
                local ui_subscribe= ui_manager.GetUI(ui_manager.UI_Config.ui_subscribe)
                if ui_subscribe then
                    if curstatus == NewSubscribeSystem.ENUM_SubStatus.NormalStatus then
                        ui_subscribe:SetShowPrice(NewSubscribeSystem.ENUM_SubId.Super)
                    end
                    if curstatus == NewSubscribeSystem.ENUM_SubStatus.SuperStatus  then
                        ui_subscribe:SetShowPrice(NewSubscribeSystem.ENUM_SubId.Normal)
                    end
                end
            else

                local ui_subscribe_buy = ui_manager.GetUI(ui_manager.UI_Config.ui_subscribe_buy)
                if ui_subscribe_buy then
                    ui_subscribe_buy:RefreshPrice()
                end
            end

        else
            log("GetMidasGoodsInfo 拉取数据失败")
            ConnectionWaitingUI:Hide()
        end
    end

    ConnectionWaitingUI:Hide()

end

--有缓存了 读取打折数据
function NewSubscribeSystem.GetMidasIntroInfo(evenType, eventID, resultTable)
    -- body

    if (resultTable == nil) then
        log("GetMidasIntroInfo读取数据失败");
        ConnectionWaitingUI:Hide()
        return;
    end
    log_tree("zino GetMidasIntroInfo resultTable", resultTable);

    for k,product in pairs(resultTable) do


        if product.productId  and product.intro_price and product.intro_gwallet_num and product.intro_ios_num then
            if product.productId == NewSubscribeSystem.Get_SubProduct_ID(NewSubscribeSystem.ENUM_SubId.Super) then

                NewSubscribeSystem.Set_First_Month_Price(product.intro_price,MidasManager.ShouldShowLocalCurrency(product.currency))

            end
            local ui_manager = require("ui.manager")

            local curstatus = NewSubscribeSystem.GetSubStatus()
            if curstatus > NewSubscribeSystem.ENUM_SubStatus.NONE then
                local ui_subscribe= ui_manager.GetUI(ui_manager.UI_Config.ui_subscribe)
                if ui_subscribe then
                    if curstatus == NewSubscribeSystem.ENUM_SubStatus.NormalStatus then
                        ui_subscribe:SetShowPrice(NewSubscribeSystem.ENUM_SubId.Super)
                    end
                    if curstatus == NewSubscribeSystem.ENUM_SubStatus.SuperStatus  then
                        ui_subscribe:SetShowPrice(NewSubscribeSystem.ENUM_SubId.Normal)
                    end
                end
            else
                local ui_subscribe_buy = ui_manager.GetUI(ui_manager.UI_Config.ui_subscribe_buy)
                if ui_subscribe_buy then
                    ui_subscribe_buy:RefreshPrice()
                end
            end

        else
            log("GetMidasIntroInfo 拉取数据失败")
        end
    end


    ConnectionWaitingUI:Hide()

end

--收到米大师打折回调信息  EVENTID_MIDAS_GET_INTRO_PRICE_INFO_NOTIFY 的回调
function NewSubscribeSystem.LoadIntroPriceFromCached(evenType, eventID, resultCode)
    -- body

    log("LoadIntroPriceFromCached" .. tostring(resultCode))

    if resultCode then
        if NewSubscribeSystem.Get_SubProduct_ID(NewSubscribeSystem.ENUM_SubId.Normal) ~= "" and NewSubscribeSystem.Get_SubProduct_ID(NewSubscribeSystem.ENUM_SubId.Super) ~= "" then
            local productid_str = string.format("%s,%s", NewSubscribeSystem.Get_SubProduct_ID(NewSubscribeSystem.ENUM_SubId.Normal),
                    NewSubscribeSystem.Get_SubProduct_ID(NewSubscribeSystem.ENUM_SubId.Super))
            local isProductInfoCached, cachedProductInfoList = MidasManager.LoadCachedMidasIntroPrice(productid_str);
            if isProductInfoCached then
                log_tree("zino cachedProductInfoList", cachedProductInfoList)

                NewSubscribeSystem.GetMidasGoodsInfo(evenType, eventID, cachedProductInfoList)    --处理非打折价格

                NewSubscribeSystem.GetMidasIntroInfo(evenType, eventID, cachedProductInfoList)    --处理打折价格
            else
                log("no reason to go here if go here find alex")
            end
        end

    end
    ConnectionWaitingUI:Hide()
end

--收到领奖物品协议
--数据驱动显示，收到这个协议就显示奖励
function NewSubscribeSystem.On_take_first_award_rsp(ret,res)
    -- body
    if ret and ret == 0 then
        log_tree("On_notify_take_first_award",ret)
        log_tree("res ",res)
        local AwardList = {}
        for k,v in pairs(res) do
            local award = {}
            award.count = v
            award.res_id = tonumber(k)
            table.insert(AwardList,award)
        end
        log_tree("zino AwardList",AwardList)
        local str = FuncUtil.GetLocalizeResStr("6374")
        CommonItemGetUI:ShowPanel(AwardList, str);
        NewSubscribeSystem.Set_Is_Could_Take_Award(false)

        EventSystem:postEvent(EVENTTYPE_SUBSCRIBE,EVENTID_SUBSCRIBE_GET_AWARD)
    else
        log("ret " .. ret)
    end
end

--查看越南版和台湾版开关是否打开 80004 80005
function NewSubscribeSystem.CheckMenuOpen()
    local strRegion = Client.GetPublishRegion()
    if strRegion then
        if strRegion == "VNG" then
            return LobbyUI:CheckLobbyMenuOpen(80004,false)
        end

        if strRegion == "TW" then
            return LobbyUI:CheckLobbyMenuOpen(80005,false)
        end

    else
        return true
    end
    return true

end



--[[网络回调]]--
s2c["query_prime_info_rsp"] = NewSubscribeSystem.on_query_prime_info;   --收到订阅全部信息下发
s2c["notify_prime_change"] = NewSubscribeSystem.on_notify_prime_change;
s2c["take_first_award_rsp"] = NewSubscribeSystem.On_take_first_award_rsp;
s2c["take_daily_uc_priv_rsp"] = NewSubscribeSystem.On_take_daily_uc_priv;   
s2c["take_daily_rp_priv_rsp"] = NewSubscribeSystem.On_take_daily_rp_priv;
s2c["buy_discount_sale_item_rsp"] = NewSubscribeSystem.On_buy_discount_sale_item_rsp;

return NewSubscribeSystem