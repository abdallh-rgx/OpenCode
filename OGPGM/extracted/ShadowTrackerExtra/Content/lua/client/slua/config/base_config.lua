_G.GameStatus = {
    Update = "Update",
    Login = "Login",
	Lobby = "Lobby",
    Fighting = "Fighting",
    Trainning = "Training",
    CreateRole = "CreateRole",
}

_G.UIContainers = {
    Default = "Default",
    Top = "Top",
    Bottom = "Bottom",
}

local ESlateVisibility      = UEnums.ESlateVisibility
local Visible               = ESlateVisibility.Visible
local Hidden                = ESlateVisibility.Hidden
local Collapsed             = ESlateVisibility.Collapsed
local HitTestInvisible      = ESlateVisibility.HitTestInvisible
local SelfHitTestInvisible  = ESlateVisibility.SelfHitTestInvisible

local UI_Config = 
{
    --[[template = {
        moduleName = "template",
        path = "/Game/UMG/UI_BP/Setting/Setting_language02_UIBP.Setting_language02_UIBP", --UI路径
        containerName = UIContainers.Default, --默认为UIContainers.Default UI层级
        closeOnSwitch = true, --默认为true, 状态切换时，自动关闭
        closeOnHide = true, --默认为true, 调用Hide时，销毁
        isSingleton = true, --默认为true, 是否单例
        showVisibility = SelfHitTestInvisible, --默认为SelfHitTestInvisible
        hideVisibility = Collapsed, --默认为Collapsed
        isAndroidBack = true, --默认为true, 是否相应android回退按钮，要求isSingleton为true
        isWindowsOBHide = false, --默认为false，是否在windows ob版本隐藏该UI

        uiStat = --用来统计打开耗时用
        {
            name = "模板界面", --UI中文界面名字
        },
    },]]

    test_scroll = {
        moduleName = "test_scroll",
        path = "/Game/UMG/TestScroll.TestScroll",
        zOrder = 60,
    },

    share_component = {
        moduleName = "common.share_component",
        path = "/Game/UMG/UI_BP/Lobby/Shareinterface_UIBP.Shareinterface_UIBP",
    },

    store_collection = {
        moduleName = "store.store_collection",
        closeOnHide = false,
        path = "/Game/UMG/UI_BP/Store/Store_Collection_UIBP.Store_Collection_UIBP", --UI路径
        isAndroidBack = false,

        uiStat = --用来统计打开耗时用
        {
            name = "商城-收藏", --UI中文界面名字
        },
    },

    store_other_pet = {
        moduleName = "store.store_other_pet",
        closeOnHide = false,
        path = "/Game/UMG/UI_BP/Store/Store_Pet_UIBP.Store_Pet_UIBP", --UI路径
        isAndroidBack = false,

        uiStat = --用来统计打开耗时用
        {
            name = "商城-其它-宠物", --UI中文界面名字
        },
    },

    store_other_parachute = {
        moduleName = "store.store_other_parachute",
        closeOnHide = false,
        path = "/Game/UMG/UI_BP/Store/Store_Prop_02_UIBP.Store_Prop_02_UIBP", --UI路径
        isAndroidBack = false,
    },

    setting_quickmessage = {
        moduleName = "setting.setting_quickmessage",
        closeOnHide = false, --调用Hide时，销毁
        path = "/Game/UMG/UI_BP/Setting/Setting_QuickMessage_BP.Setting_QuickMessage_BP", --UI路径
        isAndroidBack = false, --是否相应android回退按钮，要求isSingleton为true

        uiStat = --用来统计打开耗时用
        {
            name = "快捷语音", --UI中文界面名字
        },
    },
    
    anniversary_activity = {
        moduleName = "lobby_activity.anniversary_activity",
        path = "/Game/UMG/UI_BP/Lobby_Activity/Activity_AnnualTreasure_UIBP1.Activity_AnnualTreasure_UIBP1", --UI路径
    },

    anniversary_exchangeStore = {
        moduleName = "lobby_activity.anniversary_exchangeStore",
        path = "/Game/UMG/UI_BP/Lobby_Activity/Activity_AnnualTreasure_UIBP2.Activity_AnnualTreasure_UIBP2", --UI路径
    },

    anniversary_popnotice = {
        moduleName = "lobby_activity.anniversary_popnotice",
        path = "/Game/UMG/UI_BP/Common/Annual_PopupNotice_item.Annual_PopupNotice_item", --UI路径
    },

    anniversary_rewardBox = {
        moduleName = "lobby_activity.anniversary_rewardBox",
        path = "/Game/UMG/UI_BP/Common/Annual_Reward_popup_item.Annual_Reward_popup_item", --UI路径
    },

    anniversary_exchangeConfirm = {
        moduleName = "lobby_activity.anniversary_exchangeConfirm",
        path = "/Game/UMG/UI_BP/Common/Annual_Exchange_Confirm_item.Annual_Exchange_Confirm_item", --UI路径
    },

    anniversary_messageBox = {
        moduleName = "lobby_activity.anniversary_messageBox",
        path = "/Game/UMG/UI_BP/Common/Annual_MessageBox_item.Annual_MessageBox_item", --UI路径
    },

    pet_main = {
        moduleName = "pet.pet_main",
        path = "/Game/UMG/UI_BP/Pet/Pet_UIBP.Pet_UIBP", --UI路径
        closeOnHide = false,
        isAndroidBack = true, --默认为true, 是否相应android回退按钮，要求isSingleton为true
        uiStat = --用来统计打开耗时用
        {
            name = "宠物主界面", --UI中文界面名字
        },
    },

    pet_access = {
        moduleName = "pet.pet_access",
        path = "/Game/UMG/UI_BP/Pet/Pet_PopUp_UIBP.Pet_PopUp_UIBP", --UI路径
    },

    pet_lobby_action = {
        moduleName = "pet.pet_lobby_action",
        path = "/Game/UMG/UI_BP/Pet/Pet_LobbyControl_UIBP.Pet_LobbyControl_UIBP", --UI路径
        closeOnHide = false,
        isWindowsOBHide = true,
        isAndroidBack = false,
    },

    pet_rename = {
        moduleName = "pet.pet_rename",
        path = "/Game/UMG/UI_BP/Pet/Pet_ReviseName_UIBP.Pet_ReviseName_UIBP", --UI路径
    },

    pet_share = {
        moduleName = "pet.pet_share",
        path = "/Game/UMG/UI_BP/Pet/Pet_Share_01_UIBP.Pet_Share_01_UIBP", --UI路径
        uiStat = --用来统计打开耗时用
        {
            name = "宠物-分享", --UI中文界面名字
        },
    },

    pet_share_choose = {
        moduleName = "pet.pet_share_choose",
        path = "/Game/UMG/UI_BP/Pet/Pet_Share_UIBP.Pet_Share_UIBP", --UI路径
        uiStat = --用来统计打开耗时用
        {
            name = "宠物-分享-平台选择", --UI中文界面名字
        },
    },

    levelup_panel = {
        moduleName = "levelup.levelup_panel",
        path = "/Game/UMG/UI_BP/Lobby/Leve_UpUIBP.Leve_UpUIBP", --UI路径
        showVisibility = Visible,
        uiStat = --用来统计打开耗时用
        {
            name = "PVP 升级界面", --UI中文界面名字，
        },
    },

    pve_levelup_panel = {
        moduleName = "levelup.pve_levelup_panel",
        path = "/Game/BluePrints/PVE/UMG/Results/PVELevelUp_UIBP.PVELevelUp_UIBP", --UI路径
        uiStat = --用来统计打开耗时用
        {
            name = "PVE 升级界面", --UI中文界面名字，
        },
    },

    roleinfo_decoration = {
        moduleName = "person_space.roleinfo_decoration",
        path = "/Game/UMG/UI_BP/RoleInfo/Lobby_RoleInfo_Wear_UIBP.Lobby_RoleInfo_Wear_UIBP", --UI路径
        isAndroidBack = true,
        uiStat = --用来统计打开耗时用
        {
            name = "个人信息-装扮", --UI中文界面名字，
        },
    },

    roleinfo_popularity = {
        moduleName = "person_space.roleinfo_popularity",
        path = "/Game/UMG/UI_BP/PersonSpace/Lobby_RoleInfo_Popularity_UIBP.Lobby_RoleInfo_Popularity_UIBP", --UI路径
        isAndroidBack = true,
        uiStat = --用来统计打开耗时用
        {
            name = "个人信息-人气值界面", --UI中文界面名字，
        },
    },
    
    itempreview_panel = {
        moduleName = "lobby_item.item_preview_panel",
        path = "/Game/UMG/UI_BP/Lobby/ItemPreivew_UIBP.ItemPreivew_UIBP", --UI路径
        uiStat = --用来统计打开耗时用
        {
            name = "物品预览界面", --UI中文界面名字，
        },
    },

    starterPack_messageBox = {
        moduleName = "lobby_activity.starter_pack.starterpack_messageBox",
        path = "/Game/UMG/UI_BP/Lobby_Activity/StarterPack/Starterpack_MessageBox_item.Starterpack_MessageBox_item", --UI路径
    },

    starterpack_unlock_panel = {
        moduleName = "lobby_activity.starter_pack.unlockstarterpack_panel",
        path = "/Game/UMG/UI_BP/Lobby_Activity/StarterPack/StarterPack_Unlock_UIBP.StarterPack_Unlock_UIBP", --UI路径
        isAndroidBack = false, --是否相应android回退按钮，要求isSingleton为true
        showVisibility = Visible,
    },

    starterpack_finaloffer_panel = {
        moduleName = "lobby_activity.starter_pack.starterpack_finaloffer_panel",
        path = "/Game/UMG/UI_BP/Lobby_Activity/StarterPack/StarterPack_FinalOffer_UIBP.StarterPack_FinalOffer_UIBP", --UI路径
        isAndroidBack = false, --是否相应android回退按钮，要求isSingleton为true
        showVisibility = Visible,
    },

    package_preview_panel = {
        moduleName = "lobby_item.package_preview_panel",
        path = "/Game/UMG/UI_BP/Lobby/PackagePreview_UIBP.PackagePreview_UIBP", --UI路径
        uiStat = --用来统计打开耗时用
        {
            name = "普通礼包预览界面", --UI中文界面名字，
        },
    },
	
	common_messagebox_timer = {
        moduleName = "common.common_messagebox_timer",
        path = "/Game/UMG/UI_BP/Common/Common_MessageBox_YueNan_UIBP.Common_MessageBox_YueNan_UIBP", --UI路径
        closeOnSwitch = false,
        containerName = UIContainers.Top,
    },
    ui_subscribe_buy = {
        moduleName = "Subscribe.ui_subscribe_buy",
        path = "/Game/UMG/UI_BP/Lobby_Store_Int/Lobby_Store_Member0115_UIBP.Lobby_Store_Member0115_UIBP", --UI路径
        uiStat = --用来统计打开耗时用
        {
            name = "订阅购买界面", --UI中文界面名字
        },
    },

    ui_subscribe = {
        moduleName = "Subscribe.ui_subscribe",
        path = "/Game/UMG/UI_BP/Lobby_Store_Int/Lobby_Store_Member0115_Subscribed_UIBP.Lobby_Store_Member0115_Subscribed_UIBP", --UI路径
        uiStat = --用来统计打开耗时用
        {
            name = "订阅中心界面", --UI中文界面名字
        },
    },

    ui_subscribe_subFunc = {
        moduleName = "Subscribe.ui_subscribe_subFunc",
        path = "/Game/UMG/UI_BP/Lobby_Store_Int/Lobby_Store_Member0115_item_UIBP.Lobby_Store_Member0115_item_UIBP", --UI路径
    },

    ui_subscribe_confirm_buy = {
        moduleName = "Subscribe.ui_subscribe_confirm_buy",
        path = "/Game/UMG/UI_BP/Common/Common_MessageBox_115_UIBP.Common_MessageBox_115_UIBP", --UI路径
    },

    recharge_purchasePopup = {
        moduleName = "recharge.recharge_purchasePopup",
        path = "/Game/UMG/UI_BP/Lobby_Store_Int/item/Lobby_DirectPurchase_popup_115_UIBP.Lobby_DirectPurchase_popup_115_UIBP", --UI路径
        uiStat = --用来统计打开耗时用
        {
            name = "充值礼包", --UI中文界面名字
        },
    },
    
    recharge_purchase = {
        moduleName = "recharge.recharge_purchase",
        path = "/Game/UMG/UI_BP/Lobby_Store_Int/Lobby_DirectPurchase_115_UIBP.Lobby_DirectPurchase_115_UIBP", --UI路径
        uiStat = --用来统计打开耗时用
        {
            name = "充值直购", --UI中文界面名字
        },
    },
    
    recharge_mgr = {
        moduleName = "recharge.recharge_mgr",
        path = "/Game/UMG/UI_BP/Lobby_Store_Int/Lobby_DirectPurchase_Mgr_115_UIBP.Lobby_DirectPurchase_Mgr_115_UIBP", --UI路径
        isSingleton = true,
        uiStat = --用来统计打开耗时用
        {
            name = "充值页签", --UI中文界面名字
        },
    },
    
    antiaddction_notice = {
        moduleName = "antiaddction.anti_addction_notice",
        path = "/Game/UMG/UI_BP/PopupNotice/Anti_addiction_UIBP.Anti_addiction_UIBP", --UI路径
        containerName = UIContainers.Top, --默认为UIContainers.Default UI层级
    },

    antiaddction_kick = {
        moduleName = "antiaddction.anti_addction_kick",
        path = "/Game/UMG/UI_BP/PopupNotice/Anti_addiction2_UIBP.Anti_addiction2_UIBP", --UI路径
        isAndroidBack = false,
        containerName = UIContainers.Top, --默认为UIContainers.Default UI层级
    },
    
    vng_personalInfo = {
        moduleName = "lobby.vng_personalInfo",
        path = "/Game/UMG/UI_BP/Lobby/LobbyUI_Personal_information_UIBP.LobbyUI_Personal_information_UIBP", --UI路径
        closeOnSwitch = false,
        containerName = UIContainers.Top, --默认为UIContainers.Default UI层级
        uiStat = --用来统计打开耗时用
        {
            name = "越南个人信息", --UI中文界面名字
        },
    },

}

return UI_Config