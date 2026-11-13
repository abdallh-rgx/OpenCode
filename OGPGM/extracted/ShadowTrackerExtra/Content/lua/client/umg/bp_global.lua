GlobalData = GlobalData or 
{
}


BP_Platform = 0;
BP_Share_Platform = 0;
--是否播放过CG
BP_played_cg = 0;
--跳转url
BP_Global_Url = "";
--禁止聊天
BP_ChatBan = 0;
--欧盟16岁聊天限制
BP_EUChatRestriction = false;
--语音隐私弹窗功能开关
BP_ShouldRequestChatPrivacy = true;
--启动类型 0:正常 1:手Q游戏中心 2:微信游戏中心
BP_StartUpType = 0;
--是否外部服务器(包括苹果审核服和外发服) 平台特权专用，其他地方切勿使用
BP_IsAppleAudit = false;

BP_GlobalTips_ItemID =0;
BP_GlobalTips_ColorID =0;
BP_GlobalTips_PatternID =0;
BP_GlobalTips_ItemCount =0;
BP_GlobalTips_ShowLimitIcon = false;

-- 游戏内角色性别
BP_GameGender = 1;

--手动输入状态下，输入点击位置或者按钮位置，panel再计算摆放
BP_STRUCT_GlobalTips_Pos = { x = 0,y = 0}

--物品限时信息
BP_STRUCT_GlobalTips_TimeInfo = {is_limit = false, time_s = ""}

--文字提示弹框本地化表id
BP_GlobalHelpTips_StringID = 0;

--文字提示弹框提示坐标
BP_STRUCT_GlobalHelpTips_Pos = {x =0 ,y=0}

BP_String_ServerTime = "";

BP_HadPlayAnimation = false

-- 是否提审
BP_IOS_CHECK = false;

-- 是否是外发渠道
BP_IS_EXTERNAL_CHANNEL = false;

BP_Global_SelfUID = "";

--军团商店小红点用
BP_Global_CorpsShopLevelForRedPiont = -1;

-- 当前切到的相机Index(避免重复调用SwitchSceneCameraByIndex)
BP_CurSceneCameraIndex = 0;

-- 本地文件缓存
BP_GlobalConfigOperateKey = ""
BP_GlobalConfigOperateType = 0 -- 0:int 1:float 2:string 3:boolean
BP_GlobalConfigTempIntValue = 0
BP_GlobalConfigTempFloatValue_f = 0
BP_GlobalConfigTempStringValue = ""
BP_GlobalConfigTempBooleanValue = true
BP_GlobalConfigTempTableValue = {}

BP_Global_AvatarPreviewTarget = 0;
BP_Global_BackpackAvatarPreviewID = 0;  -- 背包/头盔/防弹衣预览皮肤ID

BP_Global_TouchTipString = ""; --按住触发tips提示
BP_Global_TouchTitleString = ""; --按住触发tips提示

BP_Global_AndroidKey_IsValid = true;  -- 标记安卓返回键是否有效
BP_Global_AdvertiseUnitID = ""; -- 广告id
BP_Global_AdvertiseNeedShowtask = false; -- 展示广告任务

BP_Global_Setting_LobbySkinId = 0;
BP_Global_Setting_LobbyBgmId = 0;

BP_Localize_StringWithNum_id = 0
BP_Localize_StringWithNum_NumStringIndex = 0
BP_Localize_StringWithNum_String1 = ""
BP_Localize_StringWithNum_String2 = ""
BP_Localize_StringWithNum_String3 = ""
BP_Localize_StringWithNum_String4 = ""
BP_Localize_StringWithNum_ReturnStr = ""

BP_Global_IS_Show_10Animation = false;

BP_Global_RechargePayPos = "";

BP_Global_IsChristmasNeedShow = false;
BP_Global_IsResidentEvilNeedShow = false;
BP_Global_IsAnniversaryNeedShow = false;
GlobalLoadingSkinQueue = 
{
    cur = 0,
    next = 0,
}

function bp_global_RegisterUI()
    
	LuaClassObj.SubUIWidgetList(bp_global,
		{{Path="/Game/UMG/UI_Logic/Global_Bp.Global_Bp_C", Container="Default", ZOrder=0}},
		{"Lobby","Login"},
		true,
		true
	);	
end

function bp_global_OnModeSwitched(gamestatus)
	log("bp_global OnModeSwitched gamestatus = " .. gamestatus);
    -- 进入战斗场景成功关闭之前的背景音乐
    if string.lower(gamestatus) == "fighting" then
        LuaClassObj.HandleUIMessage(bp_global, "EnterFightStopMusic");	
        BP_CurSceneCameraIndex = 0;
    elseif string.lower(gamestatus) == "login" then

    elseif string.lower(gamestatus) == "lobby" then
        -- LuaClassObj.HandleUIMessageNoFetch(bp_global, "LockLobbyMaxFps");
        BP_CurSceneCameraIndex = 0;
	end
end

function bp_global_OnUIStackRecover(src_tag, dst_tag)
    log("bp_global_OnUIStackRecover " .. src_tag .. " " .. dst_tag)
end

function GlobalData:SetPlatform(platform)
	BP_Platform = platform;
	log("SetPlatform "..BP_Platform);

    GlobalData:HideWidgetsByTourist()
end

-- 设置游戏内角色性别
function GlobalData:SetGameGender(gender)
    log("GlobalData:SetGameGender "..gender);
    BP_GameGender = gender;
    
end

function GlobalData:GetPlatform()
	return BP_Platform ;
end


function GlobalData:SetStartUpType(iType)
	BP_StartUpType = iType;
	log("SetStartUpType "..BP_StartUpType);
end

function GlobalData:SetIsAppleAudit(bValue)
	if bValue == true then
		BP_IsAppleAudit = bValue;
	elseif GlobalData:IsIOSCheck() then
		BP_IsAppleAudit = true;
	else
		BP_IsAppleAudit = BP_IS_EXTERNAL_CHANNEL;
	end
	log("SetIsAppleAudit "..tostring(BP_IsAppleAudit));
end

-- function GlobalData.RecoverMaxFps()
    -- LuaClassObj.HandleUIMessageNoFetch(bp_global, "RecoverMaxFps");
-- end

function EventSetInfo_Push()
end

function EventFetchInfo()
	-- 需要时时获取的变量，赋值逻辑写在这里
end

local lastUpdate = 0;
function EventUpdateServerTime( ... )
    local cur = FuncUtil.GetServerTimeInSec();
    if math.abs(cur - lastUpdate) >= 1 then
        lastUpdate = cur;
        BP_String_ServerTime = os.date("%Y-%m-%d %H:%M:%S", cur);
    end
end

function EventSetPlayedCG()
    BP_played_cg = 1;
end

--跳转url
--以game://打头，为游戏内跳转，参考格式为game://?module=1000100&{参数1}=1&{参数2}=2
--其他方式，如http://，为网页跳转，参考格式为http://pg.qq.com?{参数1}=1&{参数2}=2
function EventJumpUrl()
    if BP_Global_Url == "game://?module=1006004" then
        local AnniversaryActivitySystem = require("client.slua.logic.lobby_activity.logic_anniversary_activity")
        AnniversaryActivitySystem.get_anniversary_activity_info_req()
        return;
    end
    if JumpUtils.IsGameJumpUrl(BP_Global_Url) then
        local params = FuncUtil:ParseURLParams(BP_Global_Url);
        local moduleId = tonumber(params["module"]);
        EventSystem:postEvent(EVENTTYPE_URL, moduleId, params);
    elseif JumpUtils.IsPanDoraJumpUrl(BP_Global_Url) then
        local params = FuncUtil:ParseURLParams(BP_Global_Url);
        EventSystem:postEvent(EVENTTYPE_URL, BP_ENUM_MODULE_PANDORA, params);
    else
        Client.OpenURL(BP_Global_Url);
    end
end

function GlobalData:JumpUrl(url)
	BP_Global_Url = url;
	EventJumpUrl();
end

function EventSlapJumpUrl()
    local url = BP_Global_Url;
    --url = "https://www.pubgmobile.com/act/a20180727live/debug.html?gameid={gameid}&language={language}&openid={itop_openid}&itop_ticket={itop_ticket}&game_season={game_season}&game_area={game_area}"
    if JumpUtils.IsGameJumpUrl(url) == false and JumpUtils.IsPanDoraJumpUrl(url) == false then
        BP_Global_Url = WebSystem.PhraseUrlFromIdip(url);
    end
    log("BP_Global_Url = "..BP_Global_Url);
    EventJumpUrl();
end

-- 判断跳转类型跳转
function GlobalData:CheckCanJumpByTypeID(itemID, jumpTypeID)
    log("GlobalData:CheckCanJumpByTypeID itemID, jumpTypeID"..tostring(itemID)..", "..tostring(jumpTypeID));
    local jumpCfg = Client.GetTableData("JumpConfig", jumpTypeID);
    if jumpCfg == nil then
            log("GlobalData:CheckCanJumpByTypeID jumpCfg = nil")
        return false;
    end
    if jumpTypeID == 1 then-- 跳转商城
        if StoreSystem.IsUseNewStore() then
            local shopInfo = JumpUtils.FindJumpInfoAll(itemID)
            log("GlobalData:CheckCanJumpByTypeID shopInfo", shopInfo)
            if shopInfo == nil then
                log("GlobalData:CheckCanJumpByTypeID--new shopInfo is nil , itemID is :"..tostring(itemID));
                return false;
            end
            return true;
        else
            local shopInfo = MallSystem.getTabInfoByItemID(itemID)
            if shopInfo == nil then
                log("GlobalData:CheckCanJumpByTypeID--shopInfo is nil , itemID is :"..tostring(itemID));
                return false;
            end
            return true;
        end
    else
        if string.len(jumpCfg.JumpUrl) > 0 and LobbySystem.CheckUrlCanJump(jumpCfg.JumpUrl) == true then
            return true;
        end
    end
    return false;
end 

-- 根据跳转类型跳转
function GlobalData:JumpByTypeID(itemID, jumpTypeID)
    log("GlobalData:JumpByTypeID itemID, jumpTypeID"..tostring(itemID)..", "..tostring(jumpTypeID));
    local jumpCfg = Client.GetTableData("JumpConfig", jumpTypeID);
    if jumpCfg == nil then
        return false;
    end
    if jumpTypeID == 1 then-- 跳转商城
        if StoreSystem.IsUseNewStore() then
            local shopInfo = JumpUtils.FindJumpInfoAll(itemID)
            if shopInfo == nil then
                log("GlobalData:CheckCanJumpByTypeID--new shopInfo is nil , itemID is :"..tostring(itemID));
                return false;
            end

            local params = {
                ["Tab1"] = 0,
                ["Tab2"] = 0,
                ["isForceTab2"] = true,
                ["itemId"] = itemID,
            };
            EventSystem:postEvent(EVENTTYPE_URL, BP_ENUM_MODULE_MALL_CHILD, params);
            return true;
        else
            local shopInfo = MallSystem.getTabInfoByItemID(itemID)
            if shopInfo == nil then
                log("GlobalData:JumpByTypeID--shopInfo is nil , itemID is :"..tostring(itemID));
                return false;
            end

            local tap1 = shopInfo.first_tab
            local tap2 = shopInfo.second_tab
            
            local params = {
                ["Tab1"] = tap1,
                ["Tab2"] = tap2,
                ["isForceTab2"] = true,
                ["itemId"] = itemID,
            };
            if shopInfo.shop_id ~= nil and shopInfo.shop_id ~= 0 then
                params.selectShopId = shopInfo.shop_id
            else
                params.selectShopId = itemID
            end
            EventSystem:postEvent(EVENTTYPE_URL, BP_ENUM_MODULE_MALL_CHILD, params)
            return true;
        end
    else
        if string.len(jumpCfg.JumpUrl) > 0 and LobbySystem.CheckUrlCanJump(jumpCfg.JumpUrl) == true then
            GlobalData:JumpUrl(jumpCfg.JumpUrl);
            return true;
        end
    end
    return false;
end

--安卓点击返回键退出游戏
function EventAndroidQuitGame()
    local function clickOkCallback()
        LuaClassObj.HandleUIMessage(bp_global, "quitGame");
    end
    local title = Client.GetTableData("LocalizeRes", "101001").TextValue;
    --CommonMessageBoxUI:ShowPanel(2, "提示", "您确定要退出游戏？", clickOkCallback, nil)
    CommonMessageBoxUI:ShowPanel(2, title, Client.GetTableData("LocalizeRes", "301168").TextValue, clickOkCallback, nil)
end

function EventCheckEUChatRestriction()
    log("EventCheckEUChatRestriction");
    BP_EUChatRestriction = false;
    
    if (DataMgr.roleData.eugdpr ~= nil and LoginSystem.commonSwitch.EUGDPRForbidVoice == true) then 
        local usertype = DataMgr.roleData.eugdpr.user_type;
        log("EventCheckEUChatRestriction: usertype = "..usertype);
        if(usertype == 3 or usertype == 4 or usertype == 5) then
            BP_EUChatRestriction = true;
        end
    end

    BP_ShouldRequestChatPrivacy = true;
    if (DataMgr.roleData.eugdpr ~= nil and LoginSystem.commonSwitch.FirstVoicePopupSwitch == false) then 
        BP_ShouldRequestChatPrivacy = false;
    end
end

function EventChatCheckBan()
    log("EventChatCheckBan");
    BP_ChatBan = 0;
    if(DataMgr.ban ~= nil) then
        if(DataMgr.ban[2] ~= nil and type(DataMgr.ban[2]) == "table") then
            BP_ChatBan = 1;
        end
    end
    log("EventChatCheckBan = "..BP_ChatBan);
end

function EventChatBanInfo()
    log("EventChatBanInfo");
    if(DataMgr.ban ~= nil) then
        if(DataMgr.ban[2] ~= nil and type(DataMgr.ban[2]) == "table") then
            local time = DataMgr.ban[2].end_time;
            local reason = DataMgr.ban[2].reason;
            --local date = os.date("%Y年%m月%d日%H时%M分%S秒", time);
            --CommonMessageBoxUI:ShowPanel(1, "提示", reason.."\n解封时间为: "..date);
			local title = Client.GetTableData("LocalizeRes", "101001").TextValue
			local date = os.date(Client.GetTableData("LocalizeRes", "115005").TextValue, time);
			local str = string.format(Client.GetTableData("LocalizeRes",301143).TextValue, date);
			CommonMessageBoxUI:ShowPanel(1, title, reason..str);
        end
    end
end

function OnApplicationDeactivated()
	log("[HHF]OnApplicationDeactivated");	
	GlobalChatVoice.OnApplicationDeactivated();
	MatchPopupUI.OnApplicationDeactive();
end

function OnApplicationReactivated()
	GlobalChatVoice.OnApplicationReactivated();
	MatchPopupUI.OnApplicationReactive();

    local curStatus = string.lower(LuaClassObj.GetGameStatus(bp_global));
    log("[HHF]OnApplicationReactivated, curStatus = " .. tostring(curStatus));
    if curStatus == "lobby" then
        Client.AdjustParaAnalysis();
        --倒计时需要刷新
        LeagueGameSignUpUI.OnApplicationReactivated();
        LeagueGameLobbyUI.OnApplicationReactivated();
        LuckAirDropUI.OnApplicationReactivated();
        
    end
end

function OnApplicationEnterBackground()
	log("[HHF]OnApplicationEnterBackground");	
	--GlobalChatVoice.OnApplicationDeactivated();
end

function OnApplicationEnterForeground()
    log("[HHF]OnApplicationEnterForeground");
    MidasManager.OnApplicationEnterForeground();
end

function OnApplicationWillTerminate()
	log("[HHF]OnApplicationWillTerminate");
end

--新上报接口 供蓝图调用
BP_GEM_REPORT_SUBEVENT = ""
BP_GEM_REPORT_PARA1 = ""
BP_GEM_REPORT_PARA2 = ""
function EventSendClickGemReport()
    GemReportUtils.ReportBtnClickEvent(BP_GEM_REPORT_SUBEVENT, BP_GEM_REPORT_PARA1, BP_GEM_REPORT_PARA2)
end

function EventClickLobbyEventGemReport()
    GemReportUtils.ReportLobbyClickEvent(BP_GEM_REPORT_SUBEVENT, BP_GEM_REPORT_PARA1, BP_GEM_REPORT_PARA2)
end

-- 经分接口 ---
BP_BA_BUTTON_TYPE = 1
BP_BA_REASON = 1

function EventSendBAReport()
    ClientSendBAReport(BP_BA_BUTTON_TYPE, BP_BA_REASON)
end

-- 以下接口已经弃用，改用Gem上报。参考http://tapd.oa.com/iGameInternational/markdown_wikis/view/#1020360302008304903 ---
function ClientSendBAReport(button_type, reason, str)
    log("button_click_log button_type:"..tostring(button_type).." reason:"..tostring(reason).." str:"..tostring(str))
    NetUtil.SendPkg("button_click_log", button_type, reason, str);
end

function  EventGlobalShowItemTips_Push()
    CommonItemTipsUI:SetPanelTimeInfo(BP_STRUCT_GlobalTips_TimeInfo)
    CommonItemTipsUI:ShowPanel(BP_GlobalTips_ItemID, BP_STRUCT_GlobalTips_Pos, BP_GlobalTips_ColorID, BP_GlobalTips_PatternID,BP_GlobalTips_ItemCount,BP_GlobalTips_ShowLimitIcon)
end

--按住显示tips
function EventGlobalShowTouchTips_Push()
    GlobalData.ShowTouchTips();
end

function GlobalData.ShowTouchTips()
    log("=GlobalData.ShowTouchTips==================:"..tostring(BP_Global_TouchTipString))
    --log_tree("=GlobalData.ShowTouchTips==================:",BP_STRUCT_GlobalTips_Pos);
    CommonTouchTipsUI.ShowPanel(BP_Global_TouchTitleString, BP_Global_TouchTipString, BP_STRUCT_GlobalTips_Pos);
end

function EventGlobalCloseTouchTips( )
    CommonTouchTipsUI.ClosePanel();
end

function  EventGlobalCloseItemTips()
	CommonItemTipsUI:ClosePanel()
end

function EventShowPlatQQStartup()
	LobbyPlatformUI.ShowQQRightPanel();
end

function EventGlobalShowHelpTips()
    log("$$EventGlobalShowHelpTips")
    CommonHelpTipsUI:ShowPanel(BP_GlobalHelpTips_StringID,BP_STRUCT_GlobalHelpTips_Pos)
end

function EventGlobalCloseHelpTips()
    log("$$EventGlobalCloseHelpTips")
    CommonHelpTipsUI:ClosePanel()
end

function EventShowPlatQQVip()
	local roleId = tostring(DataMgr.roleData.uid);
	local baseURL = "https://mq.vip.qq.com/m/game/vipembed?sRoleId="..roleId.."&sPartition=1&sPfkey=pfkey"
	log("Open QQVip Url="..baseURL);
	Client.OpenURL(baseURL);
end

function EventShowPlatWXStartup()
	LobbyPlatformUI.ShowWXRightPanel();
end

function EventShowPlatIconTips()
	if BP_Platform == BP_ENUM_PLAYFORM_WX then
		ShowNotice(660011)
	end
end

-- 系统开关
BP_CHECK_MENU_OPEN_ID = 0
BP_CHECK_MENU_OPEN_RESULT = false

function EventCheckIfMenuOpen()

    if LobbySystem.LobbyMenuOpenStatus[BP_CHECK_MENU_OPEN_ID] == nil then
        BP_CHECK_MENU_OPEN_RESULT = true
        return
    end

    if LobbySystem.LobbyMenuOpenStatus[tonumber(BP_CHECK_MENU_OPEN_ID)].is_open == 0 then
        BP_CHECK_MENU_OPEN_RESULT = false
    else 
        BP_CHECK_MENU_OPEN_RESULT = true
    end
    
end

-- 是否IOS审核
function GlobalData:IsIOSCheck()
    log("GlobalData:IsIOSCheck BP_IOS_CHECK: "..tostring(BP_IOS_CHECK))
    --print( debug.traceback() )
    return BP_IOS_CHECK
end

-- 保存审核开关
function GlobalData.SaveIOSCheck(info)
    if info ~= nil and info.isIOSCheck ~= nil then
        if info.isIOSCheck == "1" then
            log("GlobalData.SaveIOSCheck info.isIOSCheck: "..info.isIOSCheck)
            BP_IOS_CHECK = true;
            --LuaClassObj.HandleUIMessage(bp_authorization, "iOSCheckHideBtn");

            EventSystem:postEvent(EVENTTYPE_BIND_INTL, EVENTID_VERSION_UPDATE_IOS_CHECK);
        end
    end
end


-- 是否游客登录
function GlobalData:IsPlatformTourist()
    return BP_Platform == BP_ENUM_PLAYFORM_TOURIST
end

function GlobalData:IsPlatformFacebook()
    log("[HHF]GlobalData:IsPlatformFacebook, BP_Platform = " .. tostring(BP_Platform));
    return BP_Platform == BP_ENUM_PLAYFORM_QQ;
end

-- 是否外发渠道
function GlobalData:IsExternalChannel()
    return BP_IS_EXTERNAL_CHANNEL;
end

-- 游客模式开关
function GlobalData:HideWidgetsByTourist()
    if not GlobalData:IsPlatformTourist() then
        return
    end
    
    LuaClassObj.SubCollapseWidgetList(bp_roleinfo,
        "RoleInfo_BP_C",
		{
			"Canvas_QQStartup",
            "Canvas_QQVip",
            "Overlay_TipsFather",
            "HorizontalBox_9",
            "Overlay_RealNameFather",
		}
	);
    
    LuaClassObj.SubCollapseWidgetList(bp_teamup_friend,
        "Lobby_InviteFriendLogic_BP_C",
        {
            "WidgetSwitcher_WXorQQ",
            "Overlay_OfflineShareFather",
        }
    );
    
    LuaClassObj.SubCollapseWidgetList(bp_alliance,
        "LobbyTeamMain_LogicBP_C",
		{
			"PlatformGroupBtns",
		}
    );
    
    -- LuaClassObj.SubCollapseWidgetList(bp_battleresult,
    --     "ResultsRanking_BP_C",
	-- 	{
	-- 		"Overlay_ShareBtn",
    --         "FlauntBox",
    --         "Overlay_ShareTips",
	-- 	}
    -- );
    
    LuaClassObj.SubCollapseWidgetList(bp_good_item_get_panel,
        "Good_Item_Get_BP_C",
		{
			"Overlay_Sharebtn",
            "Overlay_GridTips",
            
		}
    );
    
    LuaClassObj.SubCollapseWidgetList(bp_levelup,
        "LevelUp_LogicBP_C",
		{
			"Overlay_ShareRankFather",
            "CanvasPanel_RankTipsGroupFather",  
            "CanvasPanel_LevelTipsGroupFather",
            "Overlay_levelbtnshowfather",
		}
    );
    -- Now we only have one customer mode, show up the btn
    --[[
    LuaClassObj.SubCollapseWidgetList(bp_setting,
        "Setting_UIBP_C",
        {
            "Overlay_CustomerServiceFather",
        }
    );
    --]]
end

-- 国家对战开关

BP_STRUCT_NATION_SWITCH = {
    Updated = false;
    NationAllSwitch = false;
    NationBattleSwitch = false;
    NationRankSwitch = false;
};

function EventFetchNationSwitch()
	BP_STRUCT_NATION_SWITCH.Updated = LoginSystem.nation_switch.updated;
    BP_STRUCT_NATION_SWITCH.NationAllSwitch = LoginSystem.nation_switch.NationAllSwitch;
    BP_STRUCT_NATION_SWITCH.NationBattleSwitch = LoginSystem.nation_switch.NationBattleSwitch;
    BP_STRUCT_NATION_SWITCH.NationRankSwitch = LoginSystem.nation_switch.NationRankSwitch;
end 
 
-- 使用物品
BP_GLOBAL_USE_ITEM = "";

function GlobalData.OpenUseItemsUI(instID)
    BP_GLOBAL_USE_ITEM = instID;
    EventGlobalUseItem();
end

function EventGlobalUseItem()
    log("EventGlobalUseItem item "..BP_GLOBAL_USE_ITEM);
    local itemData = DataMgr.GetHallDepotItemDataByInsID(BP_GLOBAL_USE_ITEM)
    if not itemData then
        return;
    end

    local itemCfg = Client.GetTableData("Item", itemData.resID);
    if not itemCfg then
        return;
    end

    -- 改名卡的使用
    if itemCfg.ItemID == WardrobeUI.reviseNameCardId then
        -- 一天使用一张改名卡
        local nowTime = FuncUtil.GetServerTimeInSec();
        --log_tree("EventGlobalUseItem nowTime", nowTime);
        --log_tree("EventGlobalUseItem modify_name_time", DataMgr.modify_name_time);
        if FuncUtil.IsSameDay(DataMgr.modify_name_time, nowTime) then
            CommonMessageBoxUI:ShowPanel(1, Client.GetTableData("LocalizeRes", "101001").TextValue, Client.GetTableData("LocalizeRes", "660021").TextValue);
            return;
        end

        ReviseNameUI.InitPanelDetail(0)
        ReviseNameUI.Show();
        return;
    end

    -- 军团改名卡的使用
    if itemCfg.ItemID == WardrobeUI.reviseCorpsCardId then
        if DataMgr.corpsInfo.id == 0 then    -- 没有军团不能改名
            CommonMessageBoxUI:ShowPanel(1, Client.GetTableData("LocalizeRes", "101001").TextValue, Client.GetTableData("LocalizeRes", "5085").TextValue);
            return;
        else
            local roleId = tonumber(DataMgr.roleData.uid);
            if roleId ~= DataMgr.corpsInfo.commanderId then    -- 不是军团长没有改名权限
                CommonMessageBoxUI:ShowPanel(1, Client.GetTableData("LocalizeRes", "101001").TextValue, Client.GetTableData("LocalizeRes", "411006").TextValue);
                return;
            end
        end
        local param = DataMgr.corpsInfo.changeNameTime or 0;    
        cd = Client.GetTableData("CorpsConfig", "MaxChangeNameTime").ConfigValue;
        leftDay = math.ceil((cd - (FuncUtil.GetServerTimeInSec() - param)) / 86400);   
        if leftDay > 0 then       
            msgFmt = Client.GetTableData("LocalizeRes", "6023").TextValue;
            local content = string.format(msgFmt, leftDay);
            CommonMessageBoxUI:ShowPanel(1, Client.GetTableData("LocalizeRes", "101001").TextValue, content);
            return;
        end

        ReviseNameUI.InitPanelDetail(1);
        ReviseNameUI.Show();
        return;
    end

    if itemCfg.ItemID == WardrobeUI.countryFlagCardId then
        -- 判断当天是否改过旗帜
        local nowTime = FuncUtil.GetServerTimeInSec();
        log_tree("EventGlobalUseItem nowTime", nowTime);
        log_tree("EventGlobalUseItem last_modify_nation_time", DataMgr.last_modify_nation_time);
        log_tree("EventGlobalUseItem last_modify_nation_item_time", DataMgr.last_modify_nation_item_time);
        if FuncUtil.IsSameDay(DataMgr.last_modify_nation_item_time, nowTime) then
            CommonMessageBoxUI:ShowPanel(1, Client.GetTableData("LocalizeRes", "101001").TextValue, Client.GetTableData("LocalizeRes", "4548").TextValue);
            return;
        end
        -- 此时可能还未拉去玩家信息
        if next(RoleInfoSystem.PersonalBasicInfo) == nil then
            RoleInfoSystem.GetSelfBasicInfo();
        end
        RoleInfoUI.UpdateRoleInfoNation(RoleInfoSystem.PersonalBasicInfo.role_nation);

        -- 判断是否在旗帜修改CD内
        if CountryareaUI.IsOverNationModifyCd(DataMgr.last_modify_nation_time, nowTime) then
            local function onConfirmUseFlagItemShow()
                CountryareaUI.SetNeedUseFlagItem(false);
                CountryareaUI.UseFlagItemShow()
            end
            text = Client.GetTableData("LocalizeRes", 4549).TextValue -- "当前使用旗帜卡将不会消耗旗帜卡数量？"
            CommonMessageBoxUI:ShowPanel(2, Client.GetTableData("LocalizeRes", "101001").TextValue, text, onConfirmUseFlagItemShow, nil);
            return;
        end
        CountryareaUI.SetNeedUseFlagItem(true);
        CountryareaUI.UseFlagItemShow();
        return;
    end
	
	--sami 烧鸡道具的使用
	if itemCfg.ItemID == WardrobeSystem.GetShaoJiItemId() then
		ActivtyShaoJiUI.Init()
		return
	end

    --roxy 不放回抽奖道具的使用
    if  LuckyUnbackUI.IsLuckyUnbackVoucher(itemCfg.ItemID) then
        LuckyUnbackUI.OpenFromOther()
        return
    end

    --roxy 生化夺宝道具的使用
    if itemCfg.ItemID == BioChemicalUI.GetVoucherItemId() then
        BioChemicalUI.OpenFromUrl()
        return
    end

    local AnniversaryActivitySystem = require("client.slua.logic.lobby_activity.logic_anniversary_activity")
    if itemCfg.ItemID == AnniversaryActivitySystem.DebrisID then
        AnniversaryActivitySystem.JumpToExchangeStore()
        return;
    end
    
    if itemCfg.ItemID == AnniversaryActivitySystem.TicketId then
        AnniversaryActivitySystem.JumpToMainPanel()
        return;
    end
    
    --通行证升级卡的使用
    if itemCfg.ItemType == 16 and itemCfg.ItemSubType == 1603 then
        local buyId = 0
        local tb1 = Client.GetTable("UnknowPassBuyCfg")
        for k, v in pairs(tb1) do
            if v.BuyItemId == itemCfg.ItemID then
                buyId = v.ID
                break
            end
        end
        log("buyId = "..buyId)
        
        local tip = FuncUtil.LocalizeResFormat("301308", itemCfg.ItemName);;
        local  title = FuncUtil.GetLocalizeResStr("101001");
        CommonMessageBoxUI:ShowPanel(2, title, tip, function()
            local season = UnknowPassSystem.Season
            local cfg = Client.GetTableData("UnknowPassSeasonTimeCfg", season)
            if cfg == nil then
                return
            end
            UnknowPassSystem.upass_buy_pass_req(buyId)
            return true
        end
        )
        return
    end

    --local tip = string.format("是否确定开启一个<MessageProductColor>%s</>?", itemCfg.ItemName);
    
    if DoubleCardSystem.IsCanUse(itemCfg) then
        -- log("EventGlobalUseItem doUse");
        GlobalData.DoUseItem(itemData, itemCfg);
    else
        -- log("EventGlobalUseItem show dlg");
        local msg = "";
        if itemCfg.ItemType == 21 and itemCfg.ItemSubType == 2101 then
            msg = FuncUtil.LocalizeResFormat("9910113", itemCfg.ItemName);
        elseif itemCfg.ItemType == 21 and itemCfg.ItemSubType == 2102 then
            msg = FuncUtil.LocalizeResFormat("9910114", itemCfg.ItemName);
        end

        if msg ~= "" then
            CommonMessageBoxUI:ShowPanel(2, FuncUtil.GetLocalizeResStr("101001"), msg,
            function()
                GlobalData.DoUseItem(itemData, itemCfg);
                return true;
            end);
        end
    end
end

function GlobalData.DoUseItem(itemData, itemCfg)
    -- log_tree("GlobalData.DoUseItem itemData", itemData);
    -- log_tree("GlobalData.DoUseItem itemCfg", itemCfg);
    if itemCfg.IsBatchUse then
        CommonUseItemsUI.ShowUseItem(itemData, itemCfg);
    else

        local tip = FuncUtil.LocalizeResFormat("301308", itemCfg.ItemName);
        local  title = FuncUtil.GetLocalizeResStr("101001");
        CommonMessageBoxUI:ShowPanel(2, title, tip,
        function()
            WardrobeSystem.wardrobe_use_item_req(BP_GLOBAL_USE_ITEM, 1);
            return true;
        end
        );
    end
end   

function GlobalData.GetGlobalConfigData(key, valueType)
    BP_GlobalConfigOperateKey = key
    BP_GlobalConfigOperateType = valueType == 4 and 2 or valueType
    LuaClassObj.HandleUIMessage(bp_global, "GetGlobalConfigData")
    if valueType == 0 then
        return BP_GlobalConfigTempIntValue
    elseif valueType == 1 then
        return BP_GlobalConfigTempFloatValue_f
    elseif valueType == 2 then
        return BP_GlobalConfigTempStringValue
    elseif valueType == 3 then
        return BP_GlobalConfigTempBooleanValue
    elseif valueType == 4 then
        return GlobalData.Unserialize(BP_GlobalConfigTempStringValue)
    elseif valueType == nil then
       log_error("GetGlobalConfigData Error : value type can't be nil")
    else
       log_error("GetGlobalConfigData Error : invalid value type " .. tostring(valueType))
    end
end

function GlobalData.SetGlobalConfigData(key, value, valueType)
    BP_GlobalConfigOperateKey = key
    BP_GlobalConfigOperateType = valueType == 4 and 2 or valueType
    if valueType == 0 then
        BP_GlobalConfigTempIntValue = value
    elseif valueType == 1 then
        BP_GlobalConfigTempFloatValue_f = value
    elseif valueType == 2 then
        BP_GlobalConfigTempStringValue = value
    elseif valueType == 3 then
        BP_GlobalConfigTempBooleanValue = value
    elseif valueType == 4 then
        BP_GlobalConfigTempStringValue = GlobalData.Serialize(value)
    elseif valueType == nil then
       log_error("SetGlobalConfigData Error : value type can't be nil")
        return
    else
       log_error("SetGlobalConfigData Error : invalid value type " .. tostring(valueType))
        return
        end
        LuaClassObj.HandleUIMessage(bp_global, "SetGlobalConfigData")
end

function GlobalData.SetGlobalConfigIntValue(key, value)
    GlobalData.SetGlobalConfigData(key, value, 0)
end

function GlobalData.SetGlobalConfigFloatValue(key, value)
    GlobalData.SetGlobalConfigData(key, value, 1)
end

function GlobalData.SetGlobalConfigStringValue(key, value)
    GlobalData.SetGlobalConfigData(key, value, 2)
end

function GlobalData.SetGlobalConfigBooleanValue(key, value)
    GlobalData.SetGlobalConfigData(key, value, 3)
end

function GlobalData.GetGlobalConfigIntValue(key)
    return GlobalData.GetGlobalConfigData(key, 0)
end

function GlobalData.GetGlobalConfigFloatValue(key)
    return GlobalData.GetGlobalConfigData(key, 1)
end

function GlobalData.GetGlobalConfigStringValue(key)
    return GlobalData.GetGlobalConfigData(key, 2)
end

function GlobalData.GetGlobalConfigBooleanValue(key)
    return GlobalData.GetGlobalConfigData(key, 3)
end

function GlobalData.Serialize(obj)
    local seriString = ""
    local t = type(obj)
    if t == "number" then
        seriString = seriString .. obj
    elseif t == "boolean" then
        seriString = seriString .. tostring(obj)
    elseif t == "string" then
        seriString = seriString .. string.format("%q", obj)
    elseif t == "table" then
        seriString = seriString .. "{ "
        for k, v in pairs(obj) do
            seriString = seriString .. "[" .. GlobalData.Serialize(k) .. "]=" .. GlobalData.Serialize(v) .. ", "
        end
        local metatable = getmetatable(obj)
        if metatable ~= nil and type(metatable.__index) == "table" then
            for k, v in pairs(metatable.__index) do
                seriString = seriString .. "[" .. GlobalData.Serialize(k) .. "]=" .. GlobalData.Serialize(v) .. ", "
            end
        end
        seriString = seriString .. "}"
    elseif t == "nil" then
        return nil
    else
        error("can not serialize a " .. t .. " type.")
    end
    return seriString
end

function GlobalData.Unserialize(seriString)
    local t = type(seriString)
    if t == "nil" or seriString == "" then
        return nil
    elseif t == "number" or t == "string" or t == "boolean" then
        seriString = tostring(seriString)
    else
        error("can not unserialize a " .. t .. " type.")
    end
    seriString = "return " .. seriString
    local func = load(seriString)
    if func == nil then
        return nil
    end
    return func()
end

-- 全屏界面恢复遮盖场景
function EventOnLobbyRecoverCamera()
    --重新刷新下组队菜单界面，修复组队菜单丢失的BUG
    log("EventOnLobbyRecoverCamera");
    EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_RECOVER_CAMERA);
end

-- 全屏界面遮住场景
function EventOnLobbyCoverCamera()
    log("EventOnLobbyCoverCamera");
    EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_COVER_CAMERA);
end

--- 大厅相机处理 --- 
BP_GlobalSwitchCameraIndex = 0
function GlobalData.SwitchBackToLobbyCamera()
    LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "SwitchBackLobbyMainCamera");
end

function GlobalData.SwitchSceneCameraByIndex(idx)
    BP_GlobalSwitchCameraIndex = idx
    LuaClassObj.HandleUIMessageNoFetch(bp_global, "SwitchSceneCameraByIndexLua")
end
--------------------

--- 安卓返回键 ---
function GlobalData.SetAndroidKeyIsValid(bValid)
    BP_Global_AndroidKey_IsValid = bValid;
end
--- 广告 --- 

--缓存广告，有广告存在时会重新加载
function GlobalData.LoadAdvertise()
	log("LoadAD BP_Global_AdvertiseUnitID = " .. BP_Global_AdvertiseUnitID);
    LuaClassObj.HandleUIMessageNoFetch(bp_global, "LoadAdvertise");
end

--缓存广告，有广告存在时不会重新加载
function GlobalData.TryLoadAdvertise()
    log("TryLoadAD BP_Global_AdvertiseUnitID = " .. BP_Global_AdvertiseUnitID);
    LuaClassObj.HandleUIMessageNoFetch(bp_global, "TryLoadAdvertise");
end

--播放已缓存广告
function GlobalData.PlayAdvertise()
    LuaClassObj.HandleUIMessageNoFetch(bp_global, "PlayAdvertise")
end


--------------------

--- 系统场景背景切换
BP_GlobalSwitchLobbyMeshBgIndex = 0
function GlobalData.SwitchLobbyMeshBg(idx)
    BP_GlobalSwitchLobbyMeshBgIndex = idx
    LuaClassObj.HandleUIMessageNoFetch(bp_global, "SwitchLobbyMeshBg")
end

function GlobalData.GetLobbySkinIdAndBgmId()
    LuaClassObj.HandleUIMessageNoFetch(bp_global, "GetLobbySkinIDAndBgmID");
end

function GlobalData.SaveLobbySkinID()
    LuaClassObj.HandleUIMessageNoFetch(bp_global, "SaveLobbySkinID");
end

-- 大厅皮肤切换
BP_Global_Last_Lobby_Skin_Id = 0
BP_Global_Cur_Lobby_Skin_Id = 0
function GlobalData.SwitchLobbySkin(skinId)
    log("GlobalData.SwitchLobbySkin"..skinId..GlobalLoadingSkinQueue.cur..GlobalLoadingSkinQueue.next)

    if GlobalLoadingSkinQueue.cur == skinId or GlobalLoadingSkinQueue.next == skinId then
        log("no need switch lobby skin")
        return
    end
    --进到加载队列，还有等待或正在加载的皮肤，先进队列
    if GlobalLoadingSkinQueue.cur ~= 0 then
        GlobalLoadingSkinQueue.next = skinId
        return
    end
    
    GlobalData.SwitchLobbySkinNow(skinId)
end

--轮到了这个皮肤加载
function GlobalData.SwitchLobbySkinNow(skinId)
    local bUIAutoTest = Client.IsUIAutoTest();
    if bUIAutoTest then
        skinId = 10004
    end
    
    log("GlobalData.SwitchLobbySkin(skinId)"..tostring(skinId))
    if BP_Global_Cur_Lobby_Skin_Id == skinId then
        GlobalLoadingSkinQueue.cur = 0
        log("no need switch lobby skin")
        return
    end
    --真正可以去执行加载的，用cur记录下来
    GlobalLoadingSkinQueue.cur = skinId
    BP_Global_Last_Lobby_Skin_Id = BP_Global_Cur_Lobby_Skin_Id
    BP_Global_Cur_Lobby_Skin_Id = skinId
    BP_Lobby_CurSkinId = skinId;

    LuaClassObj.HandleUIMessageNoFetch(bp_global, "SwitchLobbySkin");
    LuaClassObj.HandleUIMessageNoFetch(bp_global, "SwitchLobbyBgm");
    LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "SetLobbySkinTheme");

    EventSystem:postEvent(EVENTTYPE_LOBBY_SKIN, EVENTID_LOBBY_SKIN_CHANGE_SEC, skinId)
    
    --MatchPopupUI.OnSetLobbySkinId(skinId);  -- 匹配界面按钮皮肤
    --TeamUpMatchInfoUI.OnSetLobbySkinId(skinId);
    --TeamUpModelUI.UpdateLobbySkin(skinId);
    --LobbyChatEntranceUI.UpdateLobbySkin(skinId);
    --ExpressionUI.UpdateLobbySkin(skinId);
    --TeamUPFriendUI.UpdateLobbySkin(skinId);
end

function EventSwitchLobbySkinCompleted()
    EventSystem:postEvent(EVENTTYPE_LOBBY_SKIN, EVENTID_LOBBY_SKIN_CHANGE);
    --加载完成出队列，并查看还有没有要加载的
    GlobalLoadingSkinQueue.cur = GlobalLoadingSkinQueue.next
    GlobalLoadingSkinQueue.next = 0
    if GlobalLoadingSkinQueue.cur ~= 0 then
        GlobalData.SwitchLobbySkinNow(GlobalLoadingSkinQueue.cur)
    end
    log("EventSwitchLobbySkinCompleted"..GlobalLoadingSkinQueue.cur..GlobalLoadingSkinQueue.next)
end

function GlobalData.ResetLobbySkinStatus()
    BP_Global_Last_Lobby_Skin_Id = 0
    BP_Global_Cur_Lobby_Skin_Id = 0
end

function GlobalData.GetLocalizeStringWithNum(id, NumStringIndex, String1, String2, String3, String4)
    BP_Localize_StringWithNum_id = id or 0
    BP_Localize_StringWithNum_NumStringIndex = NumStringIndex or 0
    BP_Localize_StringWithNum_String1 = String1 or ""
    BP_Localize_StringWithNum_String2 = String2 or ""
    BP_Localize_StringWithNum_String3 = String3 or ""
    BP_Localize_StringWithNum_String4 = String4 or ""
    LuaClassObj.HandleUIMessageNoFetch(bp_global, "GetLocalizeStringWithNum")

    return BP_Localize_StringWithNum_ReturnStr
end

--10连抽动画开关
function GlobalData.GetMallShow10Animation()
    LuaClassObj.HandleUIMessageNoFetch(bp_global, "GetMallShow10Animation");
end

function GlobalData.SaveMallShow10Animation()
    LuaClassObj.HandleUIMessageNoFetch(bp_global, "SaveMallShow10Animation");
end

--上一次充值档位
function GlobalData.GetRechargePayPos()
    LuaClassObj.HandleUIMessageNoFetch(bp_global, "GetRechargePayPos");
end

function GlobalData.SaveRechargePayPos()
    LuaClassObj.HandleUIMessageNoFetch(bp_global, "SaveRechargePayPos");
end


--设置冰雪节本地开关
function GlobalData.GetChristmasNeedShow()
    LuaClassObj.HandleUIMessageNoFetch(bp_global, "GetChristmasNeedShow");
end

function GlobalData.SaveChristmasNeedShow()
    LuaClassObj.HandleUIMessageNoFetch(bp_global, "SaveChristmasNeedShow");
end

--设置生化危机本地开关
function GlobalData.GetResidentEvilNeedShow()
    LuaClassObj.HandleUIMessageNoFetch(bp_global, "GetResidentEvilNeedShow");
end

function GlobalData.SaveResidentEvilNeedShow()
    LuaClassObj.HandleUIMessageNoFetch(bp_global, "SaveResidentEvilNeedShow");
end

--设置周年庆本地开关
function GlobalData.GetAnniversaryNeedShow()
    LuaClassObj.HandleUIMessageNoFetch(bp_global, "GetAnniversaryNeedShow");
end

function GlobalData.SaveAnniversaryNeedShow()
    LuaClassObj.HandleUIMessageNoFetch(bp_global, "SaveAnniversaryNeedShow");
end

function GlobalData.IsJapanOrKorea()
    local region = Client.GetPublishRegion();
    if region == "JAPAN" or region == "KOREA" then
        return true;
    else
        return false;
    end
end

-- 显示副本词汇提示
function EventGlobalShowMapInfoTips()
    log("BP_CommonItemTips_ItemID"..tostring(BP_GlobalTips_ItemID))
    TeamUpMapTipsUI.ShowPanel(BP_GlobalTips_ItemID, BP_STRUCT_GlobalTips_Pos)
end


-- 显示副本词汇提示
function EventGlobalHideMapInfoTips()
    TeamUpMapTipsUI.ClosePanel()
end

--越南个人信息成功回调
function OnVNGPostInfoSuccessed()
    local uiManager = require("ui.manager");
    if uiManager then
        local vngUI = uiManager.GetUI(uiManager.UI_Config.vng_personalInfo)
        vngUI:OnPostInfoSuccessed();
    end
end

--越南个人信息失败回调
function OnVNGPostInfoFailed()
    local uiManager = require("ui.manager");
    if uiManager then
        local vngUI = uiManager.GetUI(uiManager.UI_Config.vng_personalInfo)
        vngUI:OnPostInfoFailed();
    end
end