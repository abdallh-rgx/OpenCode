--------StarterPack相关逻辑层
StarterPackSystem =
    StarterPackSystem or
    {
        PurchaseStatus = {
            NONE = 0, --沒購買
            ALREADY = 1 --已經購買
        }, --購買狀態
        DirectPurchaseInfoDefine = {
            configPrice = "", --直购配置表里的价格
            productPriceDesc = "", --用于显示用的价格
            actEndTime = 0, --活动截止时间
            midasProductId = 0, --直购productId
            midasPrice = "", --米大师价格
            midasCountry = "", --米大师购买国家
            midasCurrency = "", --购买国家货币符号
            midasCurrencyUnit = "", --购买国家货币符号单位
            midasPayItem = 1, --米大师购买数量
            --[[ [1]={itemId=1,itemNum=2} [2]={itemId=2,itemNum=2} ]]
            rewardItems = {},
            discount = 1, -- 折扣
            item_id = 0, -- 礼包的id
            awards_uc_num = 0 -- 奖励的UC数量
        },
         --直购礼包的信息
        PurchaseTriggerUI = {
            NONE = 0, --无
            POPWINDOW = 1, --新手礼包通过弹出框购买
            CAROUSEL = 2, --新手礼包通过循环展示框购买
            UCSTORE = 3, --新手礼包通过uc商店购买
            FINAL_POPWINDOW = 4 --新手礼包通过最后机会购买
        } --購買触发的界面
    }

StarterPackSystem.StaticEnabled = true --StarterPack功能客户端总开关

StarterPackSystem.Enabled = true --购买结束后关闭不能再购买
StarterPackSystem.ServerEnabled = false --StarterPack功能服务器总开关
StarterPackSystem.IsCouldPurchase = false --是否可以購買禮包
StarterPackSystem.IsCouldPurchaseEffectiveTime = 0 --是否可以購買生效時間
StarterPackSystem.CurPurchaseStatus = StarterPackSystem.PurchaseStatus.NONE --現在購買禮包狀態

StarterPackSystem.IsWaiting = false --是否等待中

StarterPackSystem.IsAlreadyReqOpenDirectPurchase = false --是否請求過
StarterPackSystem.IsValidDirectPurchasePackItem = false --活动配置的直购礼包是否有效
StarterPackSystem.IsValidMidasDirectPurchasePack = false --活动配置的直购礼包Midas是否有效

StarterPackSystem.DirectPurchaseItemID = 0 --活动配置的直购礼包ItemID，不是直購表ID，是直購表中的ItemID
StarterPackSystem.DirectPurchaseInfo = FuncUtil:CopyTable(StarterPackSystem.DirectPurchaseInfoDefine)--活动配置的直购礼包信息 DirectPurchaseInfoDefine
StarterPackSystem.CurePurchaseTriggerUI = StarterPackSystem.PurchaseTriggerUI.NONE --購買触发的界面
StarterPackSystem.IsDirectPurchaseMidasReq = false --是够请求直购购买中

StarterPackSystem.bStarterPackUnlocked = false --玩家是否解锁starter pack
StarterPackSystem.fStarterpack_UnlockTime = 0   --玩家解锁starter pack的时间点
StarterPackSystem.fStarterPackValidPeriod = 0   --玩家解锁后，starter pack 有效期

StarterPackSystem.sStarterPack_RemainingTime = "" --玩家解锁后到玩家有效期结束的倒计时
StarterPackSystem.fStarterPack_LastUpdateFromServerTime = 0 --程序上次更新服务器信息的时间

StarterPackSystem.bForceUpdate = false --强制从服务器下发信息来更新starter pack核心数据
StarterPackSystem.bForceUpdatePurchaseInf = false


StarterPackSystem.iLimitedPopupCount = 0 --玩家解锁starter pack后，能够提醒玩家显示次数的限制
StarterPackSystem.iCurrentPopupCount = 0 --玩家解锁后，现在已经弹出提醒框的次数
StarterPackSystem.iLastLoginTime = 0 --上次登录时间

StarterPackSystem.iStarterPackDirectPurchaseId = 0 --starter pack购买的id

StarterPackSystem.bShowStarterPackUI = false --触发拍脸图
StarterPackSystem.bShowStarterPackUnlockUI = false --触发显示unlock 界面
StarterPackSystem.bShowFinalOfferUI = false --触发显示final offer
StarterPackSystem.CloseFinaUICB = nil --final offer关闭的回调函数
--StarterPackSystem.bShowFinalOfferUI = true
--StarterPackSystem.bInitializedOnStart = false


---------------------------------------------------------------------------------
-- 初始化和登入登出接口
---------------------------------------------------------------------------------

--初始化数据
function StarterPackSystem.Init()    

    if StarterPackSystem.StaticEnabled == false then
        return
    end

    if StarterPackSystem.Enabled == false then
        return
    end

    log("StarterPackSystem.Init()")

    EventSystem:registEvent(EVENTTYPE_LOGIN, EVENTID_LOGIN_SUCCESS, StarterPackSystem.OnLogin)
    EventSystem:registEvent(EVENTTYPE_LOGIN, EVENTID_BACKLOGIN, StarterPackSystem.OnLogout)
    EventSystem:registEvent(EVENTTYPE_STATE, EVENTID_ONGAMESTATECHANGE, StarterPackSystem.OnGameStateChange)
    EventSystem:registEvent(EVENTTYPE_SHOPLIMIT, EVENTID_SHOPLIMIT_STARTERPACK_ISOPEN_UPDATED,StarterPackSystem.OnIsOpenChanged);
    --EventSystem:registEvent(EVENTTYPE_ACTIVITY, EVENTID_STARTERPACK_UNLOCK, StarterPackSystem.OnUnlockStarterPack);
end

--登录
function StarterPackSystem.OnLogin()
    log("StarterPackSystem.OnLogin")

    --log_tree("LobbyMenuOpenStatus", LobbySystem.LobbyMenuOpenStatus)

    -- For Test
    --StarterPackSystem.SetIsCouldPurchase(true);
    --StarterPackSystem.ReqOpenDirectPurchase(620601);

    log("StarterPackSystem OnLogin. " .. tostring(StarterPackSystem.IsOpen()))
end

--登出 清除数据
function StarterPackSystem.OnLogout()
    -- body
    log("StarterPackSystem.OnLogout")

    StarterPackSystem.Enabled = true --购买结束后关闭不能再购买
    StarterPackSystem.IsCouldPurchase = false --是否可以購買禮包
    StarterPackSystem.IsCouldPurchaseEffectiveTime = 0 --是否可以購買生效時間
    StarterPackSystem.CurPurchaseStatus = StarterPackSystem.PurchaseStatus.NONE --現在購買禮包狀態

    StarterPackSystem.IsWaiting = false --是否等待中

    StarterPackSystem.IsAlreadyReqOpenDirectPurchase = false --是否請求過
    StarterPackSystem.IsValidDirectPurchasePackItem = false --活动配置的直购礼包是否有效
    StarterPackSystem.IsValidMidasDirectPurchasePack = false --活动配置的直购礼包Midas是否有效

    StarterPackSystem.DirectPurchaseItemID = 0 --活动配置的直购礼包ID
    StarterPackSystem.DirectPurchaseInfo = FuncUtil:CopyTable(StarterPackSystem.DirectPurchaseInfoDefine)
     --活动配置的直购礼包信息 DirectPurchaseInfoDefine

    StarterPackSystem.CurePurchaseTriggerUI = StarterPackSystem.PurchaseTriggerUI.NONE

    StarterPackSystem.bStarterPackUnlocked = false --玩家没有解锁
    StarterPackSystem.fStarterpack_UnlockTime = 0   
    StarterPackSystem.fStarterPackValidPeriod = 0   

    StarterPackSystem.sStarterPack_RemainingTime = "" 
    StarterPackSystem.fStarterPack_LastUpdateFromServerTime = 0 

    StarterPackSystem.iLimitedPopupCount = 0 
    --每次登陆都会调用这个logout，所以这边不能清存档
    --StarterPackSystem.SaveStarterPackUIShowOffCountBySaveData(0) --reset local data
    StarterPackSystem.iCurrentPopupCount = 0 
    StarterPackSystem.iLastLoginTime = 0 

    StarterPackSystem.iStarterPackDirectPurchaseId = 0 

    StarterPackSystem.bShowStarterPackUI = false 
    StarterPackSystem.bShowStarterPackUnlockUI = false 
    StarterPackSystem.bShowFinalOfferUI = false 

    StarterPackSystem.CloseDirectPurchase()
end

--function StarterPackSystem.OnUnlockStarterPack()
--StarterPackSystem.bShowStarterPackUnlockUI = true;
--end

-- 当活动状态发生变化的时候
function StarterPackSystem.OnGameStateChange(eventType, eventID, vars)    
    log("StarterPackSystem.OnGameStateChange  " .. vars.current .. "  " .. vars.pre)
    if StarterPackSystem.StaticEnabled == false then
        return
    end
    log("StarterPackSystem.OnGameStateChange  " .. tostring(StarterPackSystem.bShowStarterPackUnlockUI))    
    if StarterPackSystem.Enabled == false then
    --if StarterPackSystem.IsOpen() == false  then
        return
    end    
    log("StarterPackSystem.OnGameStateChange  StarterPackSystem.Enabled" .. tostring(StarterPackSystem.Enabled))
    --log_tree("UnlockStarterPackSystem.OnGameStateChange", vars);

    if vars.current == GameStatus.Lobby then
        log("Start StarterPackSystem timer for purchase countdown")
        --StarterPackSystem.UpdateDateFromServer()
        StarterPackSystem.bForceUpdate = true;
        StarterPackSystem.StartCountDown(1)
    elseif vars.current == GameStatus.Fighting then
        log("stop StarterPackSystem timer for purchase countdown")
        StarterPackSystem.StopCountDown()
    end

    if vars.current == GameStatus.Lobby and vars.pre == GameStatus.Fighting then
        --if vars.current == GameStatus.Lobby then
        if StarterPackSystem.bShowStarterPackUnlockUI == true then
        --if true then
            --解锁starterpack后，尝试取服务器购买信息
            StarterPackSystem.SetIsCouldPurchase(true)--设置starter pack 活动开启
            
            if StarterPackSystem.iStarterPackDirectPurchaseId == nil or StarterPackSystem.iStarterPackDirectPurchaseId == 0 then
                StarterPackSystem.bForceUpdatePurchaseInf = true
            else
                StarterPackSystem.ReqOpenDirectPurchase(StarterPackSystem.iStarterPackDirectPurchaseId)
            end
            
            log("on OnGameStateChange trying to OpenUnlockStarterPackPanel")
            StarterPackSystem.OpenUnlockStarterPackPanel()
            StarterPackSystem.bShowStarterPackUnlockUI = false
        end
    end
end

---------------------------------------------------------------------------------
-- 主流程
---------------------------------------------------------------------------------

-- 打开直购的GM命令
function StarterPackSystem.GM_Command_OpenPurchase()
    log("StarterPackSystem.GM_Command_OpenPurchase()")
    StarterPackSystem.UpdateDateFromServer()
    StarterPackSystem.SetIsCouldPurchase(true)
    StarterPackSystem.ReqOpenDirectPurchase(StarterPackSystem.iStarterPackDirectPurchaseId)
end

-- 关闭直购的GM命令
function StarterPackSystem.GM_Command_ClosePurchase()
    log("StarterPackSystem.GM_Command_ClosePurchase()")
    StarterPackSystem.EndPurchase()
end



-- 关闭结束购买
-- 当活动关闭或者退出的登入的时候
function StarterPackSystem.EndPurchase()
    log("StarterPackSystem.EndPurchase()")

    if StarterPackSystem.IsDirectPurchaseMidasReq == true then
        StarterPackSystem.ReportPurchaseLog()
    end

    StarterPackSystem.iStarterPackDirectPurchaseId = 0
    StarterPackSystem.SetIsCouldPurchase(false)
end

-- 设置是否能够购买
function StarterPackSystem.SetIsCouldPurchase(isCouldPurchase)
    log("StarterPackSystem.SetIsCouldPurchase," .. tostring(isCouldPurchase))

    StarterPackSystem.IsCouldPurchase = isCouldPurchase

    EventSystem:postEvent(EVENTTYPE_SHOPLIMIT, EVENTID_SHOPLIMIT_STARTERPACK_ISOPEN_UPDATED)
end

-- 请求开启直购
function StarterPackSystem.ReqOpenDirectPurchase(directPurchaseItemID)
    log("StarterPackSystem.ReqOpenDirectPurchase, id = " .. tostring(directPurchaseItemID))

    if not StarterPackSystem.IsCouldPurchase or directPurchaseItemID == nil or directPurchaseItemID == 0 then
        return
    end

    StarterPackSystem.DirectPurchaseItemID = directPurchaseItemID

    -- 如果直购礼包数据已经更新过则不再更新
    if StarterPackSystem.IsDirectPurchaseInfoValid() == true then
        if StarterPackSystem.IsAlreadyReqOpenDirectPurchase == true then
            return
        end
    end

    EventSystem:registEvent(
        EVENTTYPE_MIDAS_NOTIFY,
        EVENTID_MIDAS_GET_GOODS_PRODUCT_INFO_NOTIFY,
        StarterPackSystem.GetMidasGoodsInfoRsp
    )
    EventSystem:registEvent(
        EVENTTYPE_MIDAS_NOTIFY,
        EVENTID_MIDAS_GET_RECHARGE_PRODUCT_INFO_NOTIFY,
        StarterPackSystem.GetMidasGoodsInfoRsp
    )
    EventSystem:registEvent(
            EVENTTYPE_MIDAS_NOTIFY,
            EVENTID_MIDAS_BUY_GOODS_NOTIFY,
            StarterPackSystem.DirectPurchaseMidasRsp
    )

    StarterPackSystem.IsAlreadyReqOpenDirectPurchase = true
    StarterPackSystem.GetDirectBuyInfoReq()
end

-- 关闭直购
function StarterPackSystem.CloseDirectPurchase()
    log("StarterPackSystem.CloseDirectPurchase")

    StarterPackSystem.IsCouldPurchase = false

    EventSystem:postEvent(EVENTTYPE_SHOPLIMIT, EVENTID_SHOPLIMIT_STARTERPACK_OLOSE)

    EventSystem:unregistEvent(
        EVENTTYPE_MIDAS_NOTIFY,
        EVENTID_MIDAS_GET_GOODS_PRODUCT_INFO_NOTIFY,
        StarterPackSystem.GetMidasGoodsInfoRsp
    )
    EventSystem:unregistEvent(
        EVENTTYPE_MIDAS_NOTIFY,
        EVENTID_MIDAS_GET_RECHARGE_PRODUCT_INFO_NOTIFY,
        StarterPackSystem.GetMidasGoodsInfoRsp
    )
    EventSystem:unregistEvent(
        EVENTTYPE_MIDAS_NOTIFY,
        EVENTID_MIDAS_BUY_GOODS_NOTIFY,
        StarterPackSystem.DirectPurchaseMidasRsp
    )
end

-- 啟動直购
function StarterPackSystem.StartDirectPurchase()
    log("StarterPackSystem.StartDirectPurchase")
    if StarterPackSystem.IsOpen() then
        StarterPackSystem.DirectPurchaseMidasReq()
    end
end

---------------------------------------------------------------------------------
-- 直购活动相关接口
---------------------------------------------------------------------------------

--UI STUFF

function StarterPackSystem.SaveStarterPackUIShowOffCountBySaveData(msg)
    log("StarterPackSystem.SaveStarterPackUIShowOffCountBySaveData ," .. tostring(msg))

    local str = json.encode(msg)
    local fileName = "StarterP"
    local fullFileName = string.format("SaveGames/%s.sav", fileName)
    Client.SaveStringToFile(str, fullFileName)
end

function StarterPackSystem.LoadStarterPackUIShowOffCountBySaveData()
    log("StarterPackSystem.LoadStarterPackUIShowOffCountBySaveData")

    local fileName = "StarterP"
    local fullFileName = string.format("SaveGames/%s.sav", fileName)
    local str = Client.LoadFileToString(fullFileName)
    if str == nil or str == "" then
        return nil
    end
    local data = json.decode(str)
    StarterPackSystem.iCurrentPopupCount = tonumber(data)
    log("StarterPackSystem. load data: " .. data)
    --[[
	--LuaClassObj.HandleUIMessage(bp_starterpack, "GetStarterPackShowOffCount");
	local gameplayStatics = import("GamePlayStatics");
	local savingClass = slua.loadClass("/Game/UMG/UI_Logic/StarterPack/StarterPackSave.StarterPackSave")	
	local saveObj = gameplayStatics.CreateSaveGameObject(savingClass);
	if saveObj == nil then
        sandbox.logError("StarterPackUI_QuickMessage:SaveStarterPackUIShowOffCountBySaveData CreateSaveGameObject is nil")
        return
    end
    local counterSaver = saveObj.iStarterPackShowOffCount
    if counterSaver == nil then
        sandbox.logError("StarterPackUI_QuickMessage:SaveStarterPackUIShowOffCountBySaveData counterSaver is nil")
        return
    end
    ]]
end

function StarterPackSystem.InitLastlogin(lastlogin)    

    if StarterPackSystem.StaticEnabled == false then    
        return
    end

    if StarterPackSystem.Enabled == false then    
        return
    end
    log("StarterPackSystem.InitLastlogin")
    log("Init Last Login time " .. tostring(lastlogin))

    if StarterPackSystem.iLastLoginTime ~= nil then
        if StarterPackSystem.iLastLoginTime > 0 then
            log("Since we already had a last login time, so won't set it this time")
            return
        end
    end

    StarterPackSystem.iLastLoginTime = lastlogin
end

function StarterPackSystem.shouldRemindFinalOffer()
    if StarterPackSystem.bStarterPackUnlocked == false then
        return false
    end
    return StarterPackSystem.bShowFinalOfferUI
end

function StarterPackSystem.shouldRemindStarterpack()
    if StarterPackSystem.bStarterPackUnlocked == false then
        return false
    end
    return StarterPackSystem.bShowStarterPackUI
end

function StarterPackSystem.OpenUnlockStarterPackPanel()
    log("UnlockStarterPackSystem.OpenUnlockStarterPackPanel")

    local ui_manager = require("ui.manager")
    if ui_manager then
        ui_manager.ShowUI(ui_manager.UI_Config.starterpack_unlock_panel)
    end
end

function StarterPackSystem.CloseStarterFinalOfferUI()
    return
end

function StarterPackSystem.OpenStarterPackFinalOfferUI(cb)
    log("StarterPackSystem.OpenStarterPackFinalOfferUI")
    if cb ~= nil then
        StarterPackSystem.CloseFinaUICB = cb;
        log("set starterpack final offer close cb")
    end

    local ui_manager = require("ui.manager")
    if ui_manager then
        ui_manager.ShowUI(ui_manager.UI_Config.starterpack_finaloffer_panel)
    end
end

function StarterPackSystem.InitStatusOnStartup()
    log("StarterPackSystem.InitStatusOnStartup")

    if StarterPackSystem.bStarterPackUnlocked == false then
        return false
    end

    StarterPackSystem.LoadStarterPackUIShowOffCountBySaveData();
    log(
        "Limit popup Count: " ..
            tostring(StarterPackSystem.iLimitedPopupCount) ..
                "   current count:  " .. tostring(StarterPackSystem.iCurrentPopupCount)
    )
    --if new account then clear local cached save data
    --if LoginSystem.lastLogoutTime == nil or  LoginSystem.lastLogoutTime == 0 or StarterPackSystem.iLastLoginTime  == StarterPackSystem.fStarterpack_UnlockTime then
    if LoginSystem.lastLogoutTime == nil or LoginSystem.lastLogoutTime == 0 or StarterPackSystem.iLastLoginTime == nil then
        log("clean local save data for new user")
        StarterPackSystem.SaveStarterPackUIShowOffCountBySaveData(0)
        if StarterPackSystem.iLastLoginTime == nil then
            StarterPackSystem.iLastLoginTime = 0
        end
    end

    local ServerTime = FuncUtil.GetServerTimeInSec()
    local ExpiredTime = StarterPackSystem.fStarterpack_UnlockTime + StarterPackSystem.fStarterPackValidPeriod
    log("Last login Time" .. tostring(StarterPackSystem.iLastLoginTime))
    log("last Logout Time: " .. LoginSystem.lastLogoutTime)
    log(
        "Unlock Time: " ..
            StarterPackSystem.fStarterpack_UnlockTime ..
                " and Now time: " .. ServerTime .. "  valid period " .. StarterPackSystem.fStarterPackValidPeriod
    )
    log("Starterpack Expired time : " .. ExpiredTime)

    --right now this time login is already expired
    if ServerTime > ExpiredTime then
        log("on shouldRemind Final Offer, final offer alread expired")
        local LastLoginTime = LoginSystem.lastLogoutTime

        --just in case we havn't get the lastLoginTime when game start
        if DataMgr.roleData ~= nil then
            if DataMgr.roleData.old_last_login_time ~= nil then
                LastLoginTime = DataMgr.roleData.old_last_login_time
                StarterPackSystem.iLastLoginTime = LastLoginTime
            end
        end

        if StarterPackSystem.iLastLoginTime == 0 then
            log("Get last ShowStarterPackUi time 0, then use last logout time instead")
            --just in case havn't receive iLastLoginTime from server
            StarterPackSystem.iLastLoginTime = LoginSystem.lastLogoutTime
        end

        local LastLoginSinceUnlock = StarterPackSystem.iLastLoginTime - StarterPackSystem.fStarterpack_UnlockTime

        --but last login still valid
        --if LastLoginSinceUnlock < StarterPackSystem.fStarterPackValidPeriod and StarterPackSystem.bShowFinalOffer == 0 then
        if LastLoginSinceUnlock < StarterPackSystem.fStarterPackValidPeriod then
            log("here shouldRemindFinalOffer")
            StarterPackSystem.bShowFinalOfferUI = true
            StarterPackSystem.SetIsCouldPurchase(true)--设置starter pack 活动开启
            StarterPackSystem.ReqOpenDirectPurchase(StarterPackSystem.iStarterPackDirectPurchaseId)
        end
    else
        --if right now still valid period
        StarterPackSystem.SetIsCouldPurchase(true)--设置starter pack 活动开启
        StarterPackSystem.ReqOpenDirectPurchase(StarterPackSystem.iStarterPackDirectPurchaseId)

        --right now still valid, temp set should bShowStarterPackUI to true
        StarterPackSystem.bShowStarterPackUI = true
        if StarterPackSystem.iLimitedPopupCount > 0 then 
            if StarterPackSystem.iLimitedPopupCount < StarterPackSystem.iCurrentPopupCount then
                StarterPackSystem.bShowStarterPackUI = false
            end
        end
    end
    return false
end

--update data based on data that got from server
--usually this function will called once the starter packer status changed (by server)
--also it will called some time when necessary （bForceUpdate is true and then update it in internal timer)
function StarterPackSystem.UpdateDateFromServer()
    local actData = DataMgr.GetActivityByType(ActivityType["STARTER_PACK_US"])

    --[[

        ├─ Detail: ""
        LogNula: LuaLog:     ├─ StartTimeStr: "2019-02-09 16:00:00"
        LogNula: LuaLog:     ├─ EndTimeStr: "2019-03-01 15:59:59"
        LogNula: LuaLog:     ├─ JoinLevelLimitUp: 0
        LogNula: LuaLog:     ├─ Desc: "新玩家累计登录N天或完成M局战队，获得直购大礼包机会"
        LogNula: LuaLog:     ├─ DailyStartTimeStr: "16:00:00"
        LogNula: LuaLog:     ├─ other
        LogNula: LuaLog:     │  └─ starter_pack_counter
        LogNula: LuaLog:     │     └─ 1: 1
        LogNula: LuaLog:     ├─ DailyStartTime: 0
        LogNula: LuaLog:     ├─ List
        LogNula: LuaLog:     │  └─ 1
        LogNula: LuaLog:     │     ├─ Arg2: 3
        LogNula: LuaLog:     │     ├─ Title: "登录N天或完成M局战队"
        LogNula: LuaLog:     │     ├─ Order: 99
        LogNula: LuaLog:     │     ├─ ShowImgLink: ""
        LogNula: LuaLog:     │     ├─ Index: 1
        LogNula: LuaLog:     │     ├─ Total: 0
        LogNula: LuaLog:     │     ├─ Drop
        LogNula: LuaLog:     │     │  └─ 1
        LogNula: LuaLog:     │     │     ├─ count: 0
        LogNula: LuaLog:     │     │     ├─ itemId: 620601
        LogNula: LuaLog:     │     │     ├─ reviseId: 0
        LogNula: LuaLog:     │     │     └─ expireTime: 0
        LogNula: LuaLog:     │     ├─ Arg1: 3
        LogNula: LuaLog:     │     ├─ IsCheckNotice: 0
        LogNula: LuaLog:     │     ├─ CostList: { }
        LogNula: LuaLog:     │     ├─ Key: "19020001_1"
        LogNula: LuaLog:     │     ├─ Type: 64
        LogNula: LuaLog:     │     ├─ StartTime: 1549756800
        LogNula: LuaLog:     │     ├─ Status: 1
        LogNula: LuaLog:     │     ├─ Progress: 0
        LogNula: LuaLog:     │     ├─ ImgLink: ""
        LogNula: LuaLog:     │     └─ ID: 19020001
        LogNula: LuaLog:     ├─ LabelType: 0
        LogNula: LuaLog:     ├─ Condition: "2,1,3,3,0,0,0,0"
        LogNula: LuaLog:     ├─ Type: 64
        LogNula: LuaLog:     ├─ JumpActivity: 0
        LogNula: LuaLog:     ├─ Order: 0
        LogNula: LuaLog:     ├─ JoinVipLimitUp: 0
        LogNula: LuaLog:     ├─ ImgUrl: ""
        LogNula: LuaLog:     ├─ JoinVipLimitLow: 0
        LogNula: LuaLog:     ├─ LabelDesc: ""
        LogNula: LuaLog:     ├─ JoinLevelLimitLow: 0
        LogNula: LuaLog:     ├─ DailyEndTimeStr: "16:00:00"
        LogNula: LuaLog:     ├─ ID: 19020001
        LogNula: LuaLog:     ├─ StartTime: 1549756800
        LogNula: LuaLog:     ├─ EndTime: 1551484799
        LogNula: LuaLog:     ├─ DailyEndTime: 0
        LogNula: LuaLog:     ├─ Title: "Rookie Pack"
        LogNula: LuaLog:     └─ ImgLink: ""
    ]]    

    if actData == nil or actData.List[1] == nil or actData.List[1].Status == nil then
        return false
    end
    --StarterPackSystem.SetIsCouldPurchase(false)
    if actData.List[1].Status == 1 then        
        log_tree("On StarterPackSystem::UpdateDateFromServer, Get Server Data: ", actData)
        --log("Update Data From Server get starter pack unlocked status true")
        --update starter pack feature status
        StarterPackSystem.bStarterPackUnlocked = true

        --update starter pack system parameters:   unlock_time, validPeriod, remaingTime, direct_purchase id and last_update_time

        if actData.other ~= nil and actData.other.starter_pack_unlock_time ~= nil then
            StarterPackSystem.fStarterpack_UnlockTime = actData.other.starter_pack_unlock_time
        end
        if StarterPackSystem.fStarterPackValidPeriod == 0 then
            --[[
            奖励条件1：Number of days to login required to unlock Starter Pack
            奖励条件2：Number of games played required to unlock Starter Pack
            奖励条件3：Amount of time (in minutes) Starter Pack is available
            奖励条件4：Number of times pop-up displays before it is no longer shown to the player
        ]]  if actData.Condition ~= nil then
                local extraInf = actData.Condition
                local msgArr = string.split(extraInf, ",")
                if msgArr == nil or #msgArr < 4 then
                    log("try to decode server extra info failed")
                    StarterPackSystem.fStarterPackValidPeriod = 3 * 24 * 60 * 60 --3 days
                else
                    log(
                        "Get array from server， length : " ..
                            #msgArr .. " value: " .. msgArr[1] .. msgArr[2] .. msgArr[3] .. msgArr[4]
                    )
                    StarterPackSystem.fStarterPackValidPeriod = tonumber(msgArr[3]) * 60
                    StarterPackSystem.iLimitedPopupCount = tonumber(msgArr[4])
                    log("fStarterPackValidPeriod  " .. tostring(StarterPackSystem.fStarterPackValidPeriod))
                    log("iLimitedPopupCount  " .. tostring(StarterPackSystem.iLimitedPopupCount))
                end
            end
        end

        StarterPackSystem.iStarterPackDirectPurchaseId = actData.List[1].Drop[1].itemId;

        log("on Update data from serve get direct purchase Id: " .. tostring(StarterPackSystem.iStarterPackDirectPurchaseId));
        --if StarterPackSystem.bForceUpdate == true then
            --StarterPackSystem.PreparePurchase();
        --end
        StarterPackSystem.bForceUpdate = false
        return true
    else
        StarterPackSystem.bStarterPackUnlocked = false
        StarterPackSystem.bForceUpdate = false
        return true
    end
    return false
end

function StarterPackSystem.internalUpdateTimer()
    --log("StarterPackSystem.internalUpdateTimer");

    --local finalStr = StarterPackSystem.GetPurchaseEffectiveTimeDesc();
    StarterPackSystem.GetPurchaseEffectiveTimeDesc()
    EventSystem:postEvent(
        EVENTTYPE_SHOPLIMIT,
        EVENTID_SHOPLIMIT_STARTERPACK_TIME_LIMIT_UPDATED,
        StarterPackSystem.sStarterPack_RemainingTime
    )

    if StarterPackSystem.bForceUpdate == true then
        StarterPackSystem.UpdateDateFromServer()
    end
    if  StarterPackSystem.bForceUpdatePurchaseInf == true then
        if StarterPackSystem.iStarterPackDirectPurchaseId == nil or StarterPackSystem.iStarterPackDirectPurchaseId == 0 then
            log("still need to get direct purchase info as just unlock start pack")
        else
            StarterPackSystem.ReqOpenDirectPurchase(StarterPackSystem.iStarterPackDirectPurchaseId)
            StarterPackSystem.bForceUpdatePurchaseInf = false
        end
    end    
    --update timeleft for used in UI count down
    if StarterPackSystem.bStarterPackUnlocked == true then
        local fStarterPackRemainTime =StarterPackSystem.fStarterpack_UnlockTime + StarterPackSystem.fStarterPackValidPeriod - FuncUtil.GetServerTimeInSec();

        if fStarterPackRemainTime < 0 then
        fStarterPackRemainTime = 0
        end
        StarterPackSystem.sStarterPack_RemainingTime =
            StarterPackSystem.CovertTimeInSecondToString(fStarterPackRemainTime)
        StarterPackSystem.fStarterPack_LastUpdateFromServerTime = os.time()
    end    
    LobbySystem.refresh_activity_display_starterpack_countdown()
end

function StarterPackSystem.StartCountDown(fTimeInterval)
    log("StarterPackSystem.StartCountDown")

    --StarterPackSystem.DelegateEvent = delegateFn;
    UpdateTimer = Timer.InsertTimer(fTimeInterval, StarterPackSystem.internalUpdateTimer, true, true)
end

function StarterPackSystem.StopCountDown()
    log("StarterPackSystem.StopCountDown")

    if nil ~= UpdateTimer then
        log("StarterPackSystem.StopCountDown remove Timer")
        Timer.RemoveTimer(UpdateTimer)
        UpdateTimer = nil
        InitiallyTimeOffset = 0
    end
end

---------------------------------------------------------------------------------
-- Reprot Event Log
---------------------------------------------------------------------------------

--设置UI触发
function StarterPackSystem.SetPurchaseUITrigger(ui_enum, isOpen)
    log("StarterPackSystem.SetPurchaseUITrigger ui_enum =" .. tostring(ui_enum) .. ", " .. tostring(isOpen))

    if isOpen == false then
        StarterPackSystem.CurePurchaseTriggerUI = StarterPackSystem.PurchaseTriggerUI.NONE
        return
    end

    if ui_enum == StarterPackSystem.PurchaseTriggerUI.CAROUSEL then
        GemReportUtils.ReportEventImmediate(
            GemReportUtils.EventName_StarterPack,
            GemReportUtils.SubEventName_StarterPackCarouselClick
        )
    end

    if StarterPackSystem.CurePurchaseTriggerUI == StarterPackSystem.PurchaseTriggerUI.CAROUSEL then
        if ui_enum == StarterPackSystem.PurchaseTriggerUI.POPWINDOW then
            return
        end
        if ui_enum == StarterPackSystem.PurchaseTriggerUI.FINAL_POPWINDOW then
            return
        end
    end

    if isOpen == true then
        StarterPackSystem.CurePurchaseTriggerUI = ui_enum
    end
end

--发送购买的日志
function StarterPackSystem.ReportPurchaseLog()
    log("StarterPackSystem.ReportPurchaseLog ui = " .. tostring(StarterPackSystem.CurePurchaseTriggerUI))

    if StarterPackSystem.CurePurchaseTriggerUI == StarterPackSystem.PurchaseTriggerUI.POPWINDOW then
        GemReportUtils.ReportEventImmediate(
                GemReportUtils.EventName_StarterPack,
                GemReportUtils.SubEventName_StarterPackBuyThroughPopUp
        )
    elseif StarterPackSystem.CurePurchaseTriggerUI == StarterPackSystem.PurchaseTriggerUI.CAROUSEL then
        GemReportUtils.ReportEventImmediate(
                GemReportUtils.EventName_StarterPack,
                GemReportUtils.SubEventName_StarterPackBuyThroughCarousel
        )
    elseif StarterPackSystem.CurePurchaseTriggerUI == StarterPackSystem.PurchaseTriggerUI.UCSTORE then
        GemReportUtils.ReportEventImmediate(
                GemReportUtils.EventName_StarterPack,
                GemReportUtils.SubEventName_StarterPackBuyThroughUCStore
        )
    elseif StarterPackSystem.CurePurchaseTriggerUI == StarterPackSystem.PurchaseTriggerUI.FINAL_POPWINDOW then
        GemReportUtils.ReportEventImmediate(
                GemReportUtils.EventName_StarterPack,
                GemReportUtils.SubEventName_StarterPackBuyThroughFinalOffer
        )
    else
        return;
    end

    GemReportUtils.ReportEventImmediate(
            GemReportUtils.EventName_StarterPack,
            GemReportUtils.SubEventName_StarterPackPopUpTimeBeforeBuy,
            StarterPackSystem.iCurrentPopupCount
    )

    StarterPackSystem.CurePurchaseTriggerUI = StarterPackSystem.PurchaseTriggerUI.NONE
end

---------------------------------------------------------------------------------
-- 主要數據獲得接口
---------------------------------------------------------------------------------

--给其他功能模块判定是否开启 蓝图里可以call lua 调用
function StarterPackSystem.IsOpen()

    if not StarterPackSystem.StaticEnabled then
        log("StarterPackSystem.StaticEnabled false")
        return false
    end

    if not StarterPackSystem.Enabled then
        log("StarterPackSystem.Enabled false")
        return false
    end

    -- 是否启动新手礼包
    StarterPackSystem.ServerEnabled = LobbyUI:CheckLobbyMenuOpen(BP_ENUM_MODULE_STARTER_PACK, false)
    log("LobbyUI.CheckLobbyMenuOpen, " .. tostring(BP_ENUM_MODULE_STARTER_PACK))
    if not StarterPackSystem.ServerEnabled then
        log("StarterPackSystem.ServerEnabled false")
        return false
    end

    if not StarterPackSystem.IsCouldPurchase then
        log("StarterPackSystem.IsCouldPurchase false")
        return false
    end

    log("StarterPackSystem.IsOpen true")
    return true
end

-- 转变时间字符串
function StarterPackSystem.CovertTimeInSecondToString(TimeLeft)
    local TimeSeconds = 0
    local TimeMinutes = 0
    local TimeHours = 0
    local TimeDays = 0
    local result = ""

    --second
    TimeSeconds = TimeLeft % 60

    --minute
    TimeMinutes = (TimeLeft - TimeSeconds) / 60
    if (TimeMinutes < 60) then
        if TimeSeconds == 0 and TimeMinutes == 0 and TimeHours == 0 and  TimeDays == 0 then
            result = ""
        else
            result = string.format("%dd, %.2d:%.2d:%.2d", TimeDays, TimeHours, TimeMinutes, TimeSeconds)
        end
        return result
    else
        local tmpMinute = TimeMinutes
        TimeMinutes = tmpMinute % 60
        TimeHours = (tmpMinute - TimeMinutes) / 60
    end

    --hours
    if (TimeHours < 24) then
        result = string.format("%dd, %.2d:%.2d:%.2d", TimeDays, TimeHours, TimeMinutes, TimeSeconds)
        return result
    else
        local tmpHour = TimeHours
        TimeHours = tmpHour % 24
        TimeDays = (tmpHour - TimeHours) / 24
    end

    --days
    result = string.format("%dd, %.2d:%.2d:%.2d", TimeDays, TimeHours, TimeMinutes, TimeSeconds)

    return result
end

-- 获取剩下時間描述
function StarterPackSystem.GetPurchaseEffectiveTimeDesc()
    --StarterPackSystem.UpdateDateFromServer();
    return StarterPackSystem.sStarterPack_RemainingTime
    --[[
    local actData = DataMgr.GetActivityByType(ActivityType["STARTER_PACK_US"]);
	  if actData == nil or actData.List[1] == nil then
	  	return "";
	  end
	  if actData.List[1].Status == 1 then
	  	if actData.other.starter_pack_unlock_time == nil then
	  		log("actData.other.starter_pack_unlock_time is nil");
	  		if 
	  		return
	  	end
	  	local fUnlockTime = actData.other.starter_pack_unlock_time;	  	
	  	local fTimeRemaining = fUnlockTime + StarterPackSystem.fStarterPackValidPeriod - FuncUtil.GetServerTimeInSec();
	  	StarterPackSystem.sStarterPack_RemainingTime = StarterPackSystem.CovertTimeInSecondToString(fTimeRemaining);	  	
	  	return StarterPackSystem.sStarterPack_RemainingTime;
	  end
	  return "";
	  ]]
end

-- 获取物品獎勵描述
function StarterPackSystem.GetPackItemDesc()
    --TODO:
    return ""
end

-- 获取价钱描述
function StarterPackSystem.GetPriceDesc()
    local price_desc = StarterPackSystem.DirectPurchaseInfo.productPriceDesc
    if price_desc == "" then
        price_desc = "Updating"
    end
    log("StarterPackSystem.GetPriceDesc, " .. tostring(price_desc))
    return price_desc
end

-- 获取奖励UC描述
function StarterPackSystem.GetUCRewardsDesc()
    local uc_desc = StarterPackSystem.DirectPurchaseInfo.awards_uc_num
    log("StarterPackSystem.GetUCRewardsDesc, " .. tostring(uc_desc))
    if uc_desc == 0 then
        return "???"
    end
    return uc_desc
end

---------------------------------------------------------------------------------
-- 等待框
---------------------------------------------------------------------------------

-- 显示等待框
function StarterPackSystem.ShowWaitingUI()
    log("StarterPackSystem.ShowWaitingUI")
    Direct_Purchase_UI.IsWaiting = true
    ConnectionWaitingUI:Show()
end

-- 隐藏等待框
function StarterPackSystem.HideWaitingUI()
    log("StarterPackSystem.HideWaitingUI")
    Direct_Purchase_UI.IsWaiting = false
    ConnectionWaitingUI:Hide()
end

---------------------------------------------------------------------------------
-- 開啟新手禮包驗證流程
---------------------------------------------------------------------------------

-- 是否打开改变
function StarterPackSystem.OnIsOpenChanged()
    log("StarterPackSystem.OnIsOpenChanged")
    LobbySystem.refresh_activity_display_bystarterpack()
end

-- 直購道具數據更新
function StarterPackSystem.OnGetDirectPurchaseItemInfo()
    log("StarterPackSystem.OnGetDirectPurchaseItemInfo")

    StarterPackSystem.IsValidDirectPurchasePackItem = true

    EventSystem:postEvent(EVENTTYPE_SHOPLIMIT, EVENTID_SHOPLIMIT_STARTERPACK_DROPITEM_INFO_UPDATED)

    StarterPackSystem.CheckOpenDirectPurchaseSucceed()
end

-- 直購道具價錢更新
function StarterPackSystem.OnGetDirectPurchaseItemPrice()
    log("StarterPackSystem.OnGetDirectPurchaseItemPrice")

    StarterPackSystem.IsValidMidasDirectPurchasePack = true

    EventSystem:postEvent(EVENTTYPE_SHOPLIMIT, EVENTID_SHOPLIMIT_STARTERPACK_DROPITEM_PRICE_UPDATED)

    StarterPackSystem.CheckOpenDirectPurchaseSucceed()
end

-- 檢查开启直购成功
function StarterPackSystem.CheckOpenDirectPurchaseSucceed()
    log("StarterPackSystem.OnOpenDirectPurchaseSucceed")

    if StarterPackSystem.IsValidDirectPurchasePackItem and StarterPackSystem.IsValidMidasDirectPurchasePack then
        StarterPackSystem.OnOpenDirectPurchaseSucceed()
    end
end

-- 请求开启直购成功
function StarterPackSystem.OnOpenDirectPurchaseSucceed()
    log("StarterPackSystem.OnOpenDirectPurchaseSucceed")

    StarterPackSystem.IsValidDirectPurchasePack = true
    EventSystem:postEvent(EVENTTYPE_SHOPLIMIT, EVENTID_SHOPLIMIT_STARTERPACK_OPEN_VERIFY_SUCCEED)
end

---------------------------------------------------------------------------------
-- Net
---------------------------------------------------------------------------------

StarterPackSystem.IsReqDirectPurchase = false --是够请求直购数据中
-- 请求直购数据
function StarterPackSystem.GetDirectBuyInfoReq()
    log(
        "StarterPackSystem.GetDirectBuyInfoReq From Server, itemid=" .. tostring(StarterPackSystem.DirectPurchaseItemID)
    )

    StarterPackSystem.IsReqDirectPurchase = true
    NetUtil.SendPriorityPkg(
        false,
        "query_direct_buy_info_rsp",
        "query_direct_buy_info",
        StarterPackSystem.DirectPurchaseItemID
    )
    --NetUtil.SendPriorityPkg(true, "igame_get_direct_buy_info_rsp", "igame_get_direct_buy_info", StarterPackSystem.DirectPurchaseItemID);
end

-- 得到直购数据服务器回包
function StarterPackSystem.GetDirectPurchaseInfoRsp(res, info)
    log("StarterPackSystem.GetDirectPurchaseInfoRsp from server" .. tostring(res))

    if not StarterPackSystem.IsReqDirectPurchase then
        return false
    end
    StarterPackSystem.IsReqDirectPurchase = false

    log_tree("StarterPackSystem. list", info)

    if res ~= "ok" then
        DataMgr.ShowNoticeByID(res)
        log("StarterPackSystem. GetDirectPurchaseInfoRsp res is not ok , return:")
        return false
    end

    if info == nil then
        log("StarterPackSystem. GetDirectPurchaseInfoRsp info fail: return")
        return false
    end

    if info.item_id ~= StarterPackSystem.DirectPurchaseItemID then
        log("StarterPackSystem.GetDirectPurchaseInfoRsp info not match: return")
        return false
    end

    local rewardPkgInfo = StarterPackSystem.DirectPurchaseInfo

    rewardPkgInfo.midasProductId = info.productid
    rewardPkgInfo.midasCountry = info.country
    rewardPkgInfo.midasCurrencyUnit = info.curency
    rewardPkgInfo.midasCurrency = info.curency_unit
    rewardPkgInfo.midasPrice = info.midasPrice
    rewardPkgInfo.midasPayItem = info.payItem
    rewardPkgInfo.discount = info.discount
    rewardPkgInfo.item_id = info.item_id
    rewardPkgInfo.configPrice = info.price

    -- 还需要从米大师获取下最新数据
    rewardPkgInfo.productPriceDesc = info.price

    rewardPkgInfo.rewardItems = {}
    rewardPkgInfo.awards_uc_num = 0
    if info.parm2 and info.parm2 ~= "" then
        -- 充值返的UC
        local returnUC = MallSystem.ParseDirectPurchaseParam(info.parm2)
        if returnUC > 0 then
            rewardPkgInfo.rewardItems[1] = {itemId = 1006, itemNum = returnUC}
            rewardPkgInfo.awards_uc_num = returnUC
        end
    end
    for index, item in ipairs(info.item_content) do
        rewardPkgInfo.rewardItems[#rewardPkgInfo.rewardItems + 1] = {
            itemId = item.DropItemID,
            itemNum = item.DropItemNum
        }

        if item.DropItemID == 1006 then
            rewardPkgInfo.awards_uc_num = item.DropItemNum
        end
    end

    log_tree("StarterPackSystem list", StarterPackSystem.DirectPurchaseInfo)

    if StarterPackSystem.IsDirectPurchaseInfoValid() then
        StarterPackSystem.OnGetDirectPurchaseItemInfo()
        StarterPackSystem.DirectBuyMidasInfoReq(rewardPkgInfo.midasProductId, rewardPkgInfo.midasCurrency, "", true)
    end

    return true
end

-- 直购数据是否有效
function StarterPackSystem.IsDirectPurchaseInfoValid()
    if StarterPackSystem.DirectPurchaseItemID == 0 then
        return false
    end

    if StarterPackSystem.DirectPurchaseInfo.item_id == 0 then
        return false
    end

    if tostring(StarterPackSystem.DirectPurchaseInfo.item_id) ~= tostring(StarterPackSystem.DirectPurchaseItemID) then
        return false
    end

    return true
end

-- 直购成功回包
function StarterPackSystem.DirectBuyResultNotify(res, id, limit_num)
    log("StarterPackSystem.DirectBuyResultNotify, res =" .. tostring(res) .. ", id =" .. tostring(id))

    if res ~= "ok" then
        DataMgr.ShowNoticeByID(res)
        return
    else
        -- 购买成功，关闭直购
        if StarterPackSystem.IsDirectPurchaseMidasReq == true then
            StarterPackSystem.ReportPurchaseLog()
            StarterPackSystem.EndPurchase()
        end
    end

    StarterPackSystem.IsDirectPurchaseMidasReq = false
    StarterPackSystem.DirectPurchaseServerRsp(id, limit_num)
end

--
--[[网络回调]]
--s2c["query_direct_buy_info_rsp"] = StarterPackSystem.GetDirectPurchaseInfoRsp
--s2c["igame_direct_buy_result_notify"] = StarterPackSystem.DirectBuyResultNotify

---------------------------------------------------------------------------------
-- MIDAS
---------------------------------------------------------------------------------

-- 請求米大師數據
function StarterPackSystem.DirectBuyMidasInfoReq(productId, currency, oldPrice, needReload)
    log("StarterPackSystem.DirectBuyMidasInfoReq,  productId:" .. tostring(productId))

    local result, productInfos = MidasManager.LoadCachedMidasProductInfo(productId)
    if not result or not productInfos or #productInfos <= 0 then
        -- 没有米大师数据或过期
        if needReload then
            local funcCall = function()
                log("StarterPackSystem. DirectBuyMidasInfoReq : Client.LoadMidasProductInfo, " .. tostring(productId))
                Client.LoadMidasProductInfo(productId)
            end
            log("StarterPackSystem.DirectBuyMidasInfoReq: start Timer.InsertTimer")
            -- 延时请求
            Timer.InsertTimer(0.2, funcCall, false, false)
        end
    else
        local info = productInfos[1]
        log("StarterPackSystem.StarterPackSystem, get cache price:" .. tostring(info.price))
        StarterPackSystem.SetMidasGoodsInfo(productId, info.price or oldPrice)
        return
    end

    -- test
    -- local resultTable = { {productId = "com.tencent.ig.uc60",price= "$0.99",currency="USD",microprice=990000},{productId="com.tencent.ig.starterpack",price="$6.99",currency="USD",microprice=6990000}  }
    -- StarterPackSystem.GetMidasGoodsInfoRsp(0, 0, resultTable)
end

-- 設置米大师物品信息
function StarterPackSystem.SetMidasGoodsInfo(productId, price)
    log("StarterPackSystem.SetMidasGoodsInfo, productId = " .. tostring(productId) .. ",price_desc=" .. tostring(price))

    if (tostring(productId) == StarterPackSystem.DirectPurchaseInfo.midasProductId) then
        log("StarterPackSystem. update productId price:" .. tostring(price))
        StarterPackSystem.DirectPurchaseInfo.configPrice = tostring(price)
        StarterPackSystem.DirectPurchaseInfo.productPriceDesc = tostring(price)
        StarterPackSystem.OnGetDirectPurchaseItemPrice()
    end
end

-- 拉取米大师物品信息接口回调
function StarterPackSystem.GetMidasGoodsInfoRsp(evenType, eventID, resultTable)
    log("StarterPackSystem.GetMidasGoodsInfoRsp")

    if (resultTable == nil) then
        log("StarterPackSystem.GetMidasGoodsInfoRsp, resultTable is null return")
        return
    end

    for k, product in pairs(resultTable) do
        --log_tree("StarterPackSystem. product=" , product);
        --log("StarterPackSystem. midasProductId=" .. tostring(StarterPackSystem.DirectPurchaseInfo.midasProductId));
        if (tostring(product.productId) == tostring(StarterPackSystem.DirectPurchaseInfo.midasProductId)) then
            if MidasManager.ShouldShowLocalCurrency(product.currency) == false then
                -- 不是特殊货币,直接显示配置表里美元
                log("StarterPackSystem. 不是特殊货币,直接显示配置表里美元")
                StarterPackSystem.SetMidasGoodsInfo(product.productId, StarterPackSystem.DirectPurchaseInfo.configPrice)
                return
            else
                StarterPackSystem.SetMidasGoodsInfo(product.productId, product.price)
            end
        end
    end

    log_tree("StarterPackSystem. resultTable", resultTable)
end

-- 米大师购买請求
function StarterPackSystem.DirectPurchaseMidasReq()
    log("StarterPackSystem.DirectPurchaseMidasReq")

    -- 先显示转圈圈
    StarterPackSystem.ShowWaitingUI()

    local funcCall1 = function()
        StarterPackSystem.HideWaitingUI()
    end

    StarterPackSystem.IsDirectPurchaseMidasReq = true
    local funcCall2 = function()
        local info = StarterPackSystem.DirectPurchaseInfo
        log_tree("StarterPackSystem. RewardPkgInfo", info)
        log("StarterPackSystem. midas buy goods")
        -- 使用直购接口MidasGoods;MidasPay是游戏币购买接口
        Client.MidasGoods(
            info.midasProductId,
            info.midasPayItem,
            info.midasPrice,
            info.midasCountry,
            info.midasCurrency
        )
    end

    Timer.InsertTimer(2, funcCall1, false, false)
    Timer.InsertTimer(0.2, funcCall2, false, false)
end

-- 米大师购买回调
function StarterPackSystem.DirectPurchaseMidasRsp(eventType, eventID, result)
    log("StarterPackSystem.DirectPurchaseMidasRsp, result = " .. tostring(result))

    if tostring(result) ~= "0" then
        StarterPackSystem.HideWaitingUI()
    else
        -- 购买成功，关闭直购
        if StarterPackSystem.IsDirectPurchaseMidasReq == true then
            log("StarterPackSystem.DirectPurchaseMidasRsp, IsDirectPurchaseMidasReq is true" )
            StarterPackSystem.ReportPurchaseLog()
            StarterPackSystem.EndPurchase()
        end
    end

    StarterPackSystem.IsDirectPurchaseMidasReq = false
end

-- 服務器购买成功回调
function StarterPackSystem.DirectPurchaseServerRsp(id, limit_num)
    log("StarterPackSystem.DirectPurchaseServerRsp")

    StarterPackSystem.HideWaitingUI()
end
