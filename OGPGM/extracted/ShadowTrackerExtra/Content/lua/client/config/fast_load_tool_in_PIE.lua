--[[此文件主要目标是为了加快PIE下，从打开游戏到进入大厅界面，以及打开某个模块的时间：全部使用的话，可以加快15s左右的时间.
1,通过屏蔽不必要加载的widget，大约节省6-7s，通过Is_Enable_Mask_Widget来控制
2,通过屏蔽加载LuaCSV下的配置文件，大约节省1-2s
3,通过实现自动登录，免去手动点击的时间，大约节省3-5s，通过Is_Enable_Auto_Login来控制，具体登录那个服可以参看servers，serverIndex]]

local bInEditor = LuaDebugHelper and LuaDebugHelper.IsEditor()
if not bInEditor then --非编辑器下，退出后续代码块的加载
    return
end

local Is_Enable_Mask_Widget = false --是否开启屏蔽widget
local Is_Enable_Auto_Login = false --是否开启自动登录
local servers =
{
    [1] = "0.10.0 iGame主干",
    [2] = "0.8.5 0.X.5主干服",
    [3] = "kadenluo",
    [4] = "Oliver",
    [5] = "shahwu",
    [6] = "joseph",
}
local serverIndex = 1 --修改此serverindex 改变自动登录的server

--以__Hot__ 为结尾表示此函数改变后，会执行此函数
function Test__Hot__()
    log("Test__Hot__")
    --PersonSpaceMgr.ShowUI()
end


--自动登录完成后，会运行此函数，可以在这里写打开模块等代码
local hasOpen = false
local function Test_Open()
    log("Test__Open__")
    --IceLuckyGemUI.ShowUI()
    --EventEnterRoleInfo()
end

local NoCreateWidget = --主动监听OnModeSwitched回调，并在其中创建此widget
{
    "bp_device_notice",
    "bp_notice_intl",
    "bp_pdd_system",
    "bp_armory",
    "bp_mall_system_2",
    "bp_corps_own_homepage",
    "bp_corps_task",
    "bp_week_signup",
    "bp_come_back",
    "bp_task",
    "bp_eightday",
}

local NoDynamicWidget = -- bDynamicWidget = false的界面
{
    "bp_fade",
    "bp_coupons",
    "bp_share_exciting_party",
    --"bp_teamup",
    "bp_live_broadcast",
    "bp_common_messagebox_panel",
    "bp_connection_waiting",
    --"bp_teamup_match_info",
    --"bp_match",
    "bp_unknow_pass_mission",
    "bp_share",
    "bp_promotion",
    "bp_chat_entrance",
    --"bp_common_itemtips_panel",
    "bp_wardrobe",
    "bp_versionupdate",
    "bp_actor_voice",
    "bp_exciting_party",
    "bp_notice",
    "bp_chat_voice",
    "bp_activity_group",
    --"bp_teamup_model",
    --"bp_loading",
    "bp_unknow_pass_award",
    "bp_common_helptips_panel",
    "bp_unknow_pass_exchange",
    "bp_teamup_friend",
    "bp_common_touchtips_panel",
    "bp_newteaching",
    "bp_moviecg",
    --"bp_teamup_map",
    --"bp_popup_notice",
    "bp_unknow_pass",
    "bp_mall_buy_item",
    "bp_mall_page_diy",
    "bp_mall_buy_item_with_count",
    "bp_corps_auto_invite",
    "bp_corps",
    "bp_corps_own_info",
    "bp_reflux_training",
    "bp_reflux_training_award",
    "bp_reflux_training_list",
    "bp_season_review",
    "bp_mall_2_common_page",
    "bp_panel_open_close_anim",
}

----------------------------------实现细节-----------------------------------------------------------

--自动登录实现
local Test_AutoLogin = function(bp_widget)
    if not Is_Enable_Auto_Login then
        return false
    end
    
    if bp_widget == bp_authorization then
        Timer.InsertTimer(0.5, function()
            LoginSystem.sendLogin(BP_ENUM_PLAYFORM_TOURIST)

            Timer.InsertTimer(0.5, function()
                for i, v in ipairs(BP_ARRAY_ServerList_Info) do
                    if string.find(v.showAddrInfo, servers[serverIndex]) then
                        BP_SelectedShowServerInfo = i - 1
                        EventConnectToGate()
                    end
                end
            end)
        end)

        Timer.InsertTimer(11, function()
            local time
            time = Timer.InsertTimer(0.5, function()
                if LoginSystem.isInitLogin and not hasOpen and not ConnectionWaitingUI.isShowing then
                    hasOpen = true
                    Test_Open()

                    Timer.RemoveTimer(time)
                end
            end, true)
        end)
    end
end

--屏蔽widget加载
local SubUIWidgetList = LuaClassObj.SubUIWidgetList

LuaClassObj.SubUIWidgetList = function(bp_widget, InWidgetConfigList, GameStatusStrList, bPersistentUI, InStatusConcern, bDynamicWidget, bKeepDynamicWidget)
    if Test_AutoLogin then
        Test_AutoLogin(bp_widget)
    end
    
    if Is_Enable_Mask_Widget then

        local IsNoCreateWidget = false
        local NoCreateWidgetName = ""
        for i, v in ipairs(NoCreateWidget) do
            if _G[v] == bp_widget then
                IsNoCreateWidget = true
                NoCreateWidgetName = v
            end
        end

        if IsNoCreateWidget then
            log("SubUIWidgetList_ NoCreateWidget:" .. NoCreateWidgetName )
            return
        end


        local IsNoDynamicWidget = false
        local NoDynamicWidgetName = ""
        for i, v in ipairs(NoDynamicWidget) do
            if _G[v] == bp_widget then
                IsNoDynamicWidget = true
                NoDynamicWidgetName = v
            end
        end

        if IsNoDynamicWidget then
            if not bDynamicWidget then
                bDynamicWidget = true
            end
            log("SubUIWidgetList_ NoDynamicWidget:" .. NoDynamicWidgetName )
        end
    end

    SubUIWidgetList(bp_widget, InWidgetConfigList, GameStatusStrList, bPersistentUI, InStatusConcern, bDynamicWidget, bKeepDynamicWidget)
end
