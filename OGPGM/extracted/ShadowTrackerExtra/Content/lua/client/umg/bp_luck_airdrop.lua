LuckAirDropUI = LuckAirDropUI or
{
    IsUIShow = false,
    IsInLobby = false,
    IsFinishFaceNotice = false,
}
BP_Struct_AirLuck_DropItemInfo = 
{
    itemid = 0,
    num =0,
    valid_hours = 0,
}

BP_Array_DropItemID = 
{
    BP_Struct_AirLuck_DropItemInfo = _G.BP_Struct_AirLuck_DropItemInfo,
}

BP_Struct_LuckAirDrop_OneInfo = 
{
    res_id = 0,
    num = 0, --可购买的数量
    old_uc = 0, --原价
    sale_uc = 0, --折扣价
    has_buy_num = 0, --已经购买的数量
    sale = "",        --折扣
    money_res_id = 0,     --货币类型
    other_sale_price = 0,   --其他类型货币的价格
    valid_hours = 0,        --剩余时间 11版本添加
    BP_Array_DropItemID = _G.BP_Array_DropItemID,   --礼包的话，预览的掉落物品,max为4
}

BP_Array_LuckAirDrop_Info =     --空投商城外层BOX列表
{
    BP_Struct_LuckAirDrop_OneInfo = _G.BP_Struct_LuckAirDrop_OneInfo,
}

BP_Struct_LuckAirDrop_AllInfo =
{
    beginTime = 0,  --开始时间
    durationSec = 0, --持续时间
    leftTime = 0, --剩余时间,用于倒计时
    BP_Array_LuckAirDrop_Info = _G.BP_Array_LuckAirDrop_Info,
}

BP_CurClickedBuyItemID = 0;     --在SingleLuckAirDrop_ITEM_BP 里面点击按钮赋值

function bp_luck_airdrop_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_luck_airdrop,
                                {{Path="/Game/UMG/UI_Logic/EightDay/LuckAirDrop_BP.LuckAirDrop_BP_c", Container="Top", ZOrder=BP_ENUM_UI_BINDFB_ZORDER}},
                                {"Lobby"},
                                false,
                                bp_luck_airdrop_OnModeSwitched ~= nil,
                                true);
    EventSystem:registEvent(EVENTTYPE_LOGIN, EVENTID_BACKLOGIN, LuckAirDropUI.ClearData);
    EventSystem:registEvent(EVENTTYPE_LOBBY_SKIN, EVENTID_LOBBY_SKIN_CHANGE,RefreshLuckAirDropLoacation);
	EventSystem:registEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_SYNC, LuckAirDropUI.on_teamup_info_changed);
end

--需要保证收到协议数据的时候，是在lobby状态，而不是在战斗、登录等其他状态
function bp_luck_airdrop_OnModeSwitched(gamestatus)
    if string.lower(gamestatus) == "lobby" then
        LuckAirDropUI.IsInLobby = true
    else
        LuckAirDropUI.IsInLobby = false
    end
end
--切场景 换了背景资源的时候 都要重新算一遍空投的位置 并且战斗回来 没有空投要隐藏箱子 
function RefreshLuckAirDropLoacation()
    -- body
    log("zino refresh location")
    log("BP_LuckAirDropTimeLeft " .. BP_LuckAirDropTimeLeft)
    LuckAirDropUI.RefreshData()
    if LuckAirDropUI.isDataLawful() then
        if BP_LuckAirDropTimeLeft > 0 and not RoleInfoUI.IsShow then
            local funcCall = function()
                log("zino funccall")
                LuaClassObj.HandleUIMessage(bp_lobby, "UpdateLuckyAirDropLocation")
            end
            Timer.InsertTimer(0.5, funcCall, false, true);
        else
            LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "HideLobbyAirDropBoxActorAndEntrance")
        end
    end
end
--从大厅进入的空投
function LuckAirDropUI.ShowFromLobby()
    LuckAirDropUI.RefreshData()
    if LuckAirDropUI.isDataLawful() then
        LuckAirDropUI.IsUIShow = true;
        LuaClassObj.HandleDynamicCreation(bp_luck_airdrop);
        LuaClassObj.HandleUIMessage(bp_luck_airdrop, "UIShowFromLobby");
        ClientSendBAReport(BP_BA_LOBBY_AIRSHOP_OPEN_FROM_LOBBY, 0);        --空投打点
        -- LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "HidePlayers");
        TeamAvatarManager.HideAllAvatar("LuckAirDropUI")
    end
end
--从弹窗进入的空投
function LuckAirDropUI.ShowUI()
    LuckAirDropUI.RefreshData()
    if LuckAirDropUI.isDataLawful() then
        LuckAirDropUI.IsUIShow = true;
        LuaClassObj.HandleDynamicCreation(bp_luck_airdrop);
        ClientSendBAReport(BP_BA_LOBBY_AIRSHOP_OPEN, 0);        --空投打点
        LuaClassObj.HandleUIMessage(bp_luck_airdrop, "UIShow");
        -- LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "HidePlayers");
        TeamAvatarManager.HideAllAvatar("LuckAirDropUI")
        LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "OnlyHideLobbyAirDropBoxActor");      --首次播放空投动画时候，先隐藏箱子
    end
end

function EventLuckAirDropHideUI()
    LuckAirDropUI.IsUIShow = false;
    LuaClassObj.HandleUIMessage(bp_luck_airdrop, "Hide");
    -- LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "ShowPlayers");
    TeamAvatarManager.ShowAllAvatar("LuckAirDropUI")

    LobbyUI:ShowLuckAirDropEntrance()    --第一次打开空投的时候，关闭的时候要打开大厅的箱子，因为播放了动画隐藏了
    --LuaClassObj.HandleUIMessage(bp_lobby, "UpdateLuckyAirDropLocation");
    LobbySystem.PopNextUI();
end
--处理购买后的逻辑 判定是否需要隐藏整体的空投界面
function LuckAirDropUI.AfterBuy()
    local isCloseLuckDrop = true

    for i, v in pairs(DataMgr.roleData.luck_airdrop.items_info) do
        if v.has_buy_num < v.num then
            isCloseLuckDrop = false
        end
    end
    if isCloseLuckDrop then --关闭这次空投
        LuaClassObj.HandleUIMessageNoFetch(bp_luck_airdrop, "UIHide")
        -- LuaClassObj.HandleUIMessage(bp_lobby, "ShowPlayers")
        LuckAirDropUI.ClearData()
        LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "HideLobbyAirDropBoxActorAndEntrance")--隱藏入口的箱子  
    else
        LuaClassObj.HandleUIMessage(bp_luck_airdrop, "UIUpdateShopItemList")--刷新界面UI
    end
    
end

function LuckAirDropUI.ClearData()
    log("zino clear data ")
    BP_Struct_LuckAirDrop_AllInfo = 
    {
        beginTime = 0,  --开始时间
        durationSec = 0, --持续时间
        leftTime = 0, --剩余时间,用于倒计时
        BP_Array_LuckAirDrop_Info = {}
    }
    DataMgr.roleData.luck_airdrop = {}
    BP_LuckAirDropTimeLeft = 0
end

function LuckAirDropUI.isDataLawful()
    if LuckAirDropUI.GetEndTimeStamp() <=0 then
        LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "HideLobbyAirDropBoxActorAndEntrance")--隱藏入口的箱子
        return false
    else
        return true
    end
end

--这是收到数据
function LuckAirDropUI.sync_luck_airdrop(data)--此函数只用来更新 DataMgr.roleData, BP数据只从DataMgr.roleData里面获取
    log_tree("xzx sync_luck_airdrop data:", data)
    if data then
        DataMgr.roleData.luck_airdrop = {
            last_luck_time = data.last_luck_time or 0,
            duration = data.duration or 0,
            items_info = {},    --空投数据
        }
        if data.items_info and next(data.items_info) then
            for i, v in pairs(data.items_info) do
                local tempSingleItemInfo = {
                    res_id = v.res_id or 0,
                    num = v.num or 0,
                    old_uc = v.old_uc or 0,
                    sale_uc = v.sale_uc or 0,
                    has_buy_num = v.has_buy_num or 0,
                    sale = tostring(v.sale) or "",
                    money_res_id = v.money_res_id or 0,
                    other_sale_price = v.other_sale_price or 0,
                }
                table.insert(DataMgr.roleData.luck_airdrop.items_info,tempSingleItemInfo)
            end
        end
        BP_Struct_LuckAirDrop_AllInfo.beginTime = DataMgr.roleData.luck_airdrop.last_luck_time
        if _isInLobby then
            LuckAirDropUI.RefreshData()
            if LuckAirDropUI.isDataLawful() then
                LuckAirDropUI.ShowQuery()
            end  
         end    
    end
end
local function localText(id)
    local data = Client.GetTableData("LocalizeRes",id);
    if data then
        return data.TextValue
    end
    return ""
end
function LuckAirDropUI.ShowQuery()
    -- 自动化测试阶段不展示
    if Client.IsUIAutoTest() or RoleInfoUI.IsShow then return end
    
    --此时如果是处于大厅中, 显示发现神秘空投,是否打开
    if _isInLobby then
        GlobalData:JumpUrl("game://?module=" .. BP_ENUM_MODULE_LOBBY)--跳到大厅, 关闭其他模块
        CommonMessageBoxUI:ShowPanel(2, localText(102012), localText(5089), 
            LuckAirDropUI.ShowUI, EventPopNextUI, 
            localText(5091), localText(5090));
        --记录弹窗时间
        
        LobbyUI:ShowLuckAirDropEntrance()--不管是稍后打开还是立即打开,都在大厅显示入口
        
        LobbyUI:SetLuckAirDropQueryTime()--记录弹窗时间
    end
end
function LuckAirDropUI.OnApplicationReactivated()
	local isTeamup = false;
	if TeamUpSystem.TeamInfo.player_count then
	    isTeamup = TeamUpSystem.TeamInfo.player_count > 1;
    end
    if not isTeamup and not RoleInfoUI.IsShow then    --不在组队且未开启个人界面的时候才会刷
        local funcCall = function()
            log("zino LobbyUI:ShowLuckAirDropQuery")
            LobbyUI:ShowLuckAirDropQuery(true);
        end
        Timer.InsertTimer(0.5, funcCall, false, true);  --发现 切后台回来同一帧无法调用蓝图方法，延时0.5S刷新大厅空投时间    
    end  
end

function LuckAirDropUI.GetChestDropList(itemid)
    local chestDropTable = Client.GetTable("ChestDrop");
	local dropId = nil;
	for _,chestDrop in pairs(chestDropTable) do
		if chestDrop.ChestID == itemid then
            dropId = chestDrop.DropID
            log("zino find dropid luckair ".. dropId)
            local drop_util = require("client.common.drop_util")
            return drop_util.GetDropList(dropId)
		end
    end
    
end

--得到空投消失的时间
function LuckAirDropUI.GetEndTimeStamp()
    -- body
    if BP_Struct_LuckAirDrop_AllInfo.beginTime and BP_Struct_LuckAirDrop_AllInfo.durationSec then
        return BP_Struct_LuckAirDrop_AllInfo.beginTime + BP_Struct_LuckAirDrop_AllInfo.durationSec - FuncUtil.GetServerTimeInSec()
    else
        return 0
    end
end


function LuckAirDropUI.RefreshData()
    local info = BP_Struct_LuckAirDrop_AllInfo
    info.BP_Array_LuckAirDrop_Info = {}
    if DataMgr.roleData and DataMgr.roleData.luck_airdrop then
        local data = DataMgr.roleData.luck_airdrop
        log_tree("zino luckair data ", data)
        info.beginTime = data.last_luck_time or 0
        info.durationSec = data.duration or 0
        if data.items_info and next(data.items_info) then
            for i, v in pairs(data.items_info) do
                local tempDropitemArray = {}
                local valid_hours_temp = 0  --存有效期
                if v.res_id then
                    local itemCfg = Client.GetTableData("Item", v.res_id);
                    if itemCfg then
                        if itemCfg.ValidTimes then
                            log("itemCfg.ValidTimes "..itemCfg.ValidTimes)
                            valid_hours_temp = itemCfg.ValidTimes / 24 --外层item的有效期时间
                        end

                        if itemCfg.ItemType == 15 then --礼包类型
                            local dropItemList = LuckAirDropUI.GetChestDropList(v.res_id)
                            if dropItemList and next(dropItemList) then
                                for ii, vv in pairs(dropItemList) do
                                    log_tree("vvvvvvvvv",vv)
                                    local tempSingleDropItemInfo =
                                    {
                                        itemid = vv.DropItemID,
                                        num = vv.DropItemNum,
                                    }
                                    if vv.Hours then
                                        tempSingleDropItemInfo.valid_hours = vv.Hours/24  --有效期时间    可能不存在
                                    end
                                    table.insert(tempDropitemArray,tempSingleDropItemInfo)
                                end
                            end
                        end

                        local tempSingleItemInfo = {
                            res_id = v.res_id or 0,
                            num = v.num or 0,
                            old_uc = v.old_uc or 0,
                            sale_uc = v.sale_uc or 0,
                            has_buy_num = v.has_buy_num or 0,
                            sale = tostring(v.sale) or "",
                            money_res_id = v.money_res_id or 0,
                            other_sale_price = v.other_sale_price or 0,
                            valid_hours = valid_hours_temp,
                            BP_Array_DropItemID = tempDropitemArray,

                        }
                        log_tree("tempSingleItemInfo",tempSingleItemInfo)
                        table.insert(info.BP_Array_LuckAirDrop_Info,tempSingleItemInfo)
                    end
                end
            end       
        end

        --处理时间
        if info.beginTime <= 0 or info.durationSec <= 0 or info.itemId == 0 then
            info.leftTime = -1
        else
            info.leftTime = info.beginTime + info.durationSec - FuncUtil.GetServerTimeInSec()
            --bp_luck_airdrop_lobbyShowUI.SetLeftTime(info.leftTime)
        end
    
    else
        LuckAirDropUI.ClearData()
    end
    --LuckAirDropUI.ResetData()
    BP_LuckAirDropTimeLeft = info.leftTime
    --log_tree("zino BP_Struct_LuckAirDrop_AllInfo:", BP_Struct_LuckAirDrop_AllInfo);
end

function EventLuckAirDropCountTime()--显示倒计时
--TODO调用UIHide和lobby显示倒计时功能
end

function EventLuckAirDropBuyItem()--购买物品,默认能够买的时候,才会进入这个函数
    log("BP_CurClickedBuyItemID.. " ..BP_CurClickedBuyItemID)
    for i, v in pairs(BP_Struct_LuckAirDrop_AllInfo.BP_Array_LuckAirDrop_Info) do
        if v.res_id == BP_CurClickedBuyItemID then
            if v.has_buy_num < v.num then
                local strBuy = FuncUtil.GetLocalizeResStr("301185");
                local tip = "";
                local itemCfg = Client.GetTableData("Item", v.res_id);
                local itemName = ""
                if itemCfg then
                    itemName = itemCfg.ItemName or "";
                end

                if itemName ~= "" then
                    if v.money_res_id and v.money_res_id == 1006 then   --UC类型空投物品
                        tip = FuncUtil.LocalizeResFormat("301374",tonumber(v.sale_uc),itemName)
                        log("zino tip " ..tip)
                    else    --非UC类型空投物品--目前只有gold
                        tip = FuncUtil.LocalizeResFormat("301373",tonumber(v.other_sale_price),itemName)
                    end
                    
                    CommonMessageBoxUI:ShowPanel(2, strBuy, tip, LuckAirDropUI.BuyItem);
                end
            else
                ShowNotice(421010)--超出限购数量
            end
        end
    end


end

function LuckAirDropUI.BuyItem()
    NetUtil.SendPkg("buy_luck_airdrop_req",BP_CurClickedBuyItemID, 1) --此处先默认买一个
end

--商品购买响应
function LuckAirDropUI.buy_luck_airdrop_rsp(msg, resId, resCount)
    log("xzx buy_luck_airdrop_rsp, msg = "..msg);
    if msg == "ok" then
        log("xzx resId = "..resId..", resCount = "..resCount)
        
        --刷新用户数据
        local role = DataMgr.roleData.luck_airdrop
        if role then
            for i, v in pairs(role.items_info) do
               if v.res_id ==  resId then
                    if v.has_buy_num then
                        v.has_buy_num = v.has_buy_num + resCount
                    end
               end  
            end 
        end
        for i, v in pairs(BP_Struct_LuckAirDrop_AllInfo.BP_Array_LuckAirDrop_Info) do
            if v.res_id ==  resId then
                if v.has_buy_num then
                    v.has_buy_num = v.has_buy_num + resCount
                end
            end    
        end
        LuckAirDropUI.AfterBuy()
        MallSystem.ResetItemCache();
        local itemCfg = Client.GetTableData("Item", resId);
        local validhours = 0
            if itemCfg.ValidTimes then
                log("itemCfg.ValidTimes "..itemCfg.ValidTimes)
                validhours = itemCfg.ValidTimes / 24 --外层item的有效期时间
            end
        local cacheItemInfo = {}
        local itemData = {
            res_id = resId;
            count = resCount;
            valid_hours = validhours;
            expire_ts = 0;
        };
        table.insert(cacheItemInfo, itemData); 

        CommonItemGetUI:ShowPanel(cacheItemInfo);
    elseif msg == 9930004 then --UC不足
        local title = Client.GetTableData("LocalizeRes", "101001").TextValue;
        local tip = Client.GetTableData("LocalizeRes", "4119").TextValue;
        CommonMessageBoxUI:ShowPanel(2, title, tip, function()
            LuaClassObj.HandleUIMessageNoFetch(bp_luck_airdrop, "UIHide");
            RechargeUI:Init();
            return true;
        end);
    elseif msg == 9930007 then --金币不足
        ShowNotice(9910003)
    elseif msg == 9930002 then--超过限购数量
        ShowNotice(421010)
    else
        ShowNotice(430104)
        --PopUpNoticeUI.ShowNewNotice("支付失败");
    end
end
--组队模式隐藏入口
function LuckAirDropUI.on_teamup_info_changed(eventType, eventID, vars)
    if eventID == EVENTID_TEAMUP_TEAMINFO_SYNC then
		if TeamUpSystem.TeamInfo then
			local isTeamup = false;
			if TeamUpSystem.TeamInfo.player_count then
				isTeamup = TeamUpSystem.TeamInfo.player_count > 1;
            end
            if isTeamup then
                LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "UIHideAirDropEntrance")
            else
                if LuckAirDropUI.GetEndTimeStamp() > 0 then
                    
                    LobbyUI:ShowLuckAirDropEntrance()
                end
            end
		end
	end
	
end
--组队状态中 不显示入口
function LuckAirDropUI.IsinTeam()
    if TeamUpSystem.TeamInfo.player_count then
        return TeamUpSystem.TeamInfo.player_count > 1;
    end
end


--zefengxiao要求加的 在登录显示过拍脸图之后 控制弹窗顺序的逻辑
function EventPopNextUI()
    -- body
    log("EventPopNextUI")
    LobbySystem.PopNextUI()
end
--结束动画播放要切换哪个相机
function EventSwitchEndingCamera()
    if WardrobeUI.isShowing then
        LobbyUI:SwitchToTeamorMenuCamera(true)  --在仓库里面的话 要调用仓库切相机方式
    else
       LuaClassObj.HandleUIMessageNoFetch(bp_lobby,"SwitchBackLobbyMainCamera");    
    end
end

-- function LuckAirDropUI.TestLuckData()
--     -- body
--     local table = 
--     {
--         items_info = 
--         {
--             [1521701] = 
--             {
--                 num = 1,
--                 res_id = 1521701,
--                 luck_id = 3003,
--                 has_buy_num = 0,
--                 old_uc = 600,
--                 sale = 83,
--                 money_res_id = 1006,
--                 sale_uc = 102,
--             },
--             [1521702] = 
--             {
--                 num = 1,
--                 res_id = 1521702,
--                 luck_id = 3004,
--                 has_buy_num = 0,
--                 old_uc = 930,
--                 sale = 70,
--                 money_res_id = 1006,
--                 sale_uc = 102,
--             },
--             [1521703] = 
--             {
--                 num = 1,
--                 res_id = 1521703,
--                 luck_id = 3003,
--                 has_buy_num = 0,
--                 old_uc = 600,
--                 sale = 83,
--                 money_res_id = 1006,
--                 sale_uc = 102,
--             },

--         }  ,
--         duration = 3343200,
--         last_luck_time = 1549721338,
--     }
--     LuckAirDropUI.sync_luck_airdrop(table)
-- end
s2c = s2c or {};
s2c["sync_luck_airdrop"] = LuckAirDropUI.sync_luck_airdrop
s2c["buy_luck_airdrop_rsp"] = LuckAirDropUI.buy_luck_airdrop_rsp