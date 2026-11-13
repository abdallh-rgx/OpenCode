--------订阅相关逻辑层
SubscribeSystem = SubscribeSystem or
{
    SubStatus = 
    {
        NONE = 0,   --没订阅
        NormalStatus = 1,   --普通订阅会员
        SuperStatus = 2,    --高级订阅会员
        BothStatus = 3,     --全部订阅
    },  --订阅状态
    
    SubId = 
    {
        Normal = 101,   --普通ID
        Super = 201,    --高级ID
    },
    SubInfoID = 
    {
        ADDSHOPUCITEM = 101,    --限时商店增加UC购买物品
        ADDSHOPBPITEM = 102,    --限时商店增加UC购买物品
        ADDRP = 103,            --每日可领取的RP积分增加
        EXTRAVOICE = 104,       --战斗中和可使用扩展语音包
        ADDPASSEXP = 105,    --pass任务经验提升
        LOGINGET = 106,    --每日登陆领取
    },
}
SubscribeSystem.NormalInfo = --普通订阅会员优惠信息
{
    infoID = 0,
    Describe = "",
    num = 0,
}     

SubscribeSystem.SuperInfo = --高级订阅会员优惠信息
{
    infoID = 0,
    Describe = "",
    num = 0,
}   

SubscribeSystem.TaskIDList = 
{
    Normal = 100018,
    Super = 100019,
}

SubscribeSystem.NormalPrimeAddInfo =    --普通订阅加成信息
{
    [SubscribeSystem.SubInfoID.ADDPASSEXP] = 0,    --pass任务经验提升
    [SubscribeSystem.SubInfoID.LOGINGET] = 0,       --每日登陆领取
}

SubscribeSystem.SuperPrimeAddInfo =     --高级订阅加成信息
{
    [SubscribeSystem.SubInfoID.ADDPASSEXP] = 0,    --pass任务经验提升
    [SubscribeSystem.SubInfoID.LOGINGET] = 0,       --每日登陆领取
}

SubscribeSystem.IsOpen = false  --订阅功能开关，其他模块根据此来屏蔽对应功能

SubscribeSystem.CurSubStatus = 0       --当前订阅状态缓存
SubscribeSystem.IsCouldGetNormalFirstAward = false    --是否可以领取普通订阅周期奖励
SubscribeSystem.IsCouldGetSuperFirstAward = false    --是否可以领取高级订阅周期奖励

SubscribeSystem.tableNormalPrice = ""   --后台传过来的美元保底数据

SubscribeSystem.tableSuperPrice = ""    --后台传过来的美元保底数据

SubscribeSystem.tableNormalPriceMonth = ""   --后台传过来的美元保底数据/普通月卡

SubscribeSystem.tableSuperPriceMonth = ""   --后台传过来的美元保底数据/高级月卡


--初始化数据
function SubscribeSystem.Init()
    log("SubscribeSystem.Init()")
    EventSystem:registEvent(EVENTTYPE_LOGIN, EVENTID_LOGIN_SUCCESS, SubscribeSystem.PostReq);
    EventSystem:registEvent(EVENTTYPE_LOGIN,EVENTID_BACKLOGIN, SubscribeSystem.clear);
end

--登出 清除数据
function SubscribeSystem.clear()
    -- body
    log("SubscribeSystem.clear")
    SubscribeSystem.IsOpen = false  --订阅功能开关，其他模块根据此来屏蔽对应功能

    SubscribeSystem.CurSubStatus = 0       --当前订阅状态缓存
    SubscribeSystem.IsCouldGetNormalFirstAward = false    --是否可以领取普通订阅周期奖励
    SubscribeSystem.IsCouldGetSuperFirstAward = false    --是否可以领取高级订阅周期奖励

    SubscribeSystem.tableNormalPrice = ""   --后台传过来的美元保底数据

    SubscribeSystem.tableSuperPrice = ""    --后台传过来的美元保底数据

    SubscribeSystem.tableNormalPriceMonth = ""   --后台传过来的美元保底数据/普通月卡

    SubscribeSystem.tableSuperPriceMonth = ""   --后台传过来的美元保底数据/高级月卡

    
    --充值面板的订阅数据 重置
    BP_Recharge_Subscribe_IsExchange = false
    BP_Recharge_SubscribeStatus = 0;
    BP_Recharge_Subscribe_BuyOrPrice = ""
    
    --大厅面板消息重置
    BP_Lobby_IsShowPrimeImage = false
    BP_Lobby_IsFirstTimeShowPrime = true
    
end



