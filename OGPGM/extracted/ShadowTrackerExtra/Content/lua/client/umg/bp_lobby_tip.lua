--大厅弹窗系统 
--战斗带出的物品提示 盖在成就弹窗上面
--非提示类弹窗，是成就弹窗那种弹窗
--控制成就弹窗

Lobby_Tip_System = 
{
    isNeedToshow = false,    
}


BP_Lobby_Tip_System_ItemID = ""
BP_Lobby_Tip_System_Count = 0
BP_Lobby_Tip_System_MaxCount = 0
BP_Lobby_Tip_System_Describe = ""

function bp_lobby_tip_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_lobby_tip,
        {{Path = "/Game/UMG/UI_Logic/Lobby/Lobby_Tip_BP.Lobby_Tip_BP_C", Container = "Top", ZOrder = BP_ENUM_UI_COMMON_ITEMTIPS_ZORDER-4}},
        {"Lobby"},
        false,
        bp_lobby_tip_OnModeSwitched ~= nil,
        true
    );
end

function bp_lobby_tip_OnModeSwitched(gameStatus)
    log("bp_lobby_tip_OnModeSwitched gameStatus = " .. tostring(gameStatus))
    
    if string.lower(gameStatus) == "lobby" then
        if Lobby_Tip_System.isNeedToshow then   --有带出的物品缓存
            -- 延时4秒之后再处理
            if Lobby_Tip_System.delayOpenTimer == nil then
                Lobby_Tip_System.delayOpenTimer = Timer.InsertTimer(4, Lobby_Tip_System.HandlerTimer, false)
            end
            
        end
    end
end

function Lobby_Tip_System.HandlerTimer()
    -- body
    log("Handle Lobby_Tip_System timer")
    Timer.RemoveTimer(Lobby_Tip_System.delayOpenTimer)
    Lobby_Tip_System.delayOpenTimer = nil
    Lobby_Tip_System.UIShow()
    Lobby_Tip_System.isNeedToshow = false
end


function Lobby_Tip_System.UIShow()
    -- body
    log("Lobby_Tip_System show")
    LuaClassObj.HandleDynamicCreation(bp_lobby_tip)
    LuaClassObj.HandleUIMessage(bp_lobby_tip, "UIShow")
end

--跳转到仓库面板
function EventJumpToWardrobe()
    -- body
    EventSystem:postEvent(EVENTTYPE_URL, BP_ENUM_MODULE_WARDROBE,true);
end
--收到推送协议 缓存数据 
--数据驱动显示
--在大厅中 直接触发推送
function Lobby_Tip_System.On_add_battle_item_notify(itemid,count,MaxCount)
    -- body
    Lobby_Tip_System.isNeedToshow = true
    BP_Lobby_Tip_System_ItemID = itemid
    BP_Lobby_Tip_System_Count = count
    BP_Lobby_Tip_System_MaxCount = MaxCount
    local resItem = Client.GetTableData("Item",itemid);
    if not MaxCount then    --没达到上限 弹这个
        BP_Lobby_Tip_System_Describe = FuncUtil.LocalizeResFormat("6519",count, resItem.ItemName)
    else
        if count == -1 then --说明无法带出 触达上限
            BP_Lobby_Tip_System_Describe = FuncUtil.LocalizeResFormat("6520",resItem.ItemName, MaxCount)
        else    --说明带出了count个物品之后 达到上限
            BP_Lobby_Tip_System_Describe = FuncUtil.LocalizeResFormat("6520",resItem.ItemName, MaxCount)
        end
    end
    log("BP_Lobby_Tip_System_Describe "..BP_Lobby_Tip_System_Describe)
    if _isInLobby then
        bp_lobby_tip_OnModeSwitched("lobby")
    end
end
--[[网络回调]]--
s2c = s2c or {}
s2c["add_battle_item_notify"] = Lobby_Tip_System.On_add_battle_item_notify
