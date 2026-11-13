--大厅表情动作UI
ExpressionUI = ExpressionUI or 
{
    isShow = false,
    IsNews = 0,
}

--目前最多可以设置的个数
BP_ExpressionMaxCount = 10
--当前点击哪个表情
BP_ExpressionClickIndex = 0

BP_STRUCT_News_Log_Data =
{
    id = 0,
    red_point = 0,
    icon = 0,
    type = 0,
    jump = 0,
};

BP_STRUCT_Expression =
{
	id = "",
};

BP_ARRAY_ExpressionList = 
{
	BP_STRUCT_Expression = _G.BP_STRUCT_Expression,
};
BP_ExpressionIsShow = false;

--sami 是否可以使用红装表情
BP_Expression_RedEmotion_Check_ItemId = 0
BP_Expression_RedEmotion_Check_Result = false

BP_Lobby_Notice_Icon = 0;
WarningNoticeTitle = "";
WarningNoticeContent = "";
WarningNoticeImgUrl = "";
WarningNoticeJump = "";
WarningNoticePos = "";
  --注册Widget
function bp_expression_RegisterUI()
  LuaClassObj.SubUIWidgetList(bp_expression,
    {{Path="/Game/UMG/UI_Logic/Wardrobe/Global_expression_BP.Global_expression_BP_C", Container="Default", ZOrder=35}},
	{"Lobby"},
	false,
	true,
    true,
    true
    );

    EventSystem:registEvent(EVENTTYPE_LOBBY_SKIN, EVENTID_LOBBY_SKIN_CHANGE_SEC, ExpressionUI.UpdateLobbySkin);
end

function ExpressionUI.Init()
	EventSystem:registEvent(EVENTTYPE_MOTION, EVENTID_MOTION_UPDATE_SLOT_LIST, ExpressionUI.UpdateMotionSlotList);
    EventSystem:registEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN, ExpressionUI.WardRobeAvatarResetOpen);
    EventSystem:registEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE, ExpressionUI.WardRobeAvatarResetClose);
    EventSystem:registEvent(EVENTTYPE_RANK, EVENTID_WARZONE_OPEN, ExpressionUI.WardRobeAvatarResetOpen);
    EventSystem:registEvent(EVENTTYPE_RANK, EVENTID_WARZONE_CLOSE, ExpressionUI.WardRobeAvatarResetClose);
    BP_News_Show_Button = false -- 如果是注销账号，而不是杀死进程重新登录，则全局变量还是上一次的值
    BP_News_Show_Flag = false --
end

function ExpressionUI.Release()
	EventSystem:unregistEvent(EVENTTYPE_MOTION, EVENTID_MOTION_UPDATE_SLOT_LIST, ExpressionUI.UpdateMotionSlotList);
    EventSystem:unregistEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN, ExpressionUI.WardRobeAvatarResetOpen);
    EventSystem:unregistEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE, ExpressionUI.WardRobeAvatarResetClose);
    EventSystem:unregistEvent(EVENTTYPE_RANK, EVENTID_WARZONE_OPEN, MatchPopupUI.WardRobeAvatarResetOpen);
    EventSystem:unregistEvent(EVENTTYPE_RANK, EVENTID_WARZONE_CLOSE, MatchPopupUI.WardRobeAvatarResetClose);
    BP_ExpressionIsShow = false
    --BP_isshowExpression = false
end

function ExpressionUI.WardRobeAvatarResetOpen()
    log("ExpressionUI.WardRobeAvatarResetOpen")
	LuaClassObj.HandleUIMessageNoFetch(bp_expression, "UIHideNative");
end

function ExpressionUI.WardRobeAvatarResetClose()
    log("ExpressionUI.WardRobeAvatarResetClose isMoreShow:"..tostring(LobbyUI.isMoreShow ).." isContentShowing:"
            ..tostring(TeamUPFriendUI.isContentShowing).." saveIsShowing:"..tostring(WardrobeUI.saveIsShowing));
    if LobbyUI.isMoreShow
    -- jaysun bug=67634869 【ALL】大厅: 通过"邀请"列表邀请好友发起聊天后，关闭聊天界面后，大厅表情管理按钮消失。
    -- cole bug=69083903 【【ALL】大厅: 打开好友邀请列表后，底层底部会出现表情管理按钮】
    or TeamUPFriendUI.isContentShowing == true
    or WardrobeUI.saveIsShowing == true
    then
        LuaClassObj.HandleUIMessageNoFetch(bp_expression, "UIHideNative");
    else
        LuaClassObj.HandleUIMessageNoFetch(bp_expression, "UIShowNative");
    end

    ExpressionUI.UpdateMotionSlotList(true)
end

function ExpressionUI.UpdateMotionData()
    BP_ExpressionMaxCount = DataMgr.MotionSlotMax;
	
    BP_ARRAY_ExpressionList = {}
    for i,v in ipairs(DataMgr.MotionSlotList) do
        local itemData = DataMgr.GetValidHallDepotItemDataByInsID(v);
		if itemData then
            table.insert(BP_ARRAY_ExpressionList,{id = itemData.resID})
		end
    end
end

function ExpressionUI.UpdateMotionSlotList(bForce)
    log("ExpressionUI.UpdateMotionSlotList")
    
    ExpressionUI.UpdateMotionData()
    
    if BP_ExpressionIsShow or bForce then 
        LuaClassObj.HandleUIMessage(bp_expression, "UpdateList")
    end
end

function ExpressionUI.Show()
    log("ExpressionUI.Show")
    BP_ExpressionIsShow = true
    BP_isshowExpression = 1
    ExpressionUI.UpdateMotionData()
	LuaClassObj.HandleDynamicCreation(bp_expression);
    LuaClassObj.HandleUIMessage(bp_expression, "UIShow")

    -- 审核期间不弹
    log("XZF NEWS_NOTIFY "..tostring(LobbySystem.CheckOpen(BP_ENUM_EXAMINE_UI_NEWS_NOTIFY)))
    if not LobbySystem.CheckOpen(BP_ENUM_EXAMINE_UI_NEWS_NOTIFY) then
        EventCloseExpressionNoticePanel();
    end
end

function ExpressionUI.Hide(isNative)
    if(isNative ~= nil) then
        log("ExpressionUI.Hide isNative：".. tostring(isNative))
    else
        log("ExpressionUI.Hide isNative：")
    end
    if BP_ExpressionIsShow then
        BP_ExpressionIsShow = false
        --BP_isshowExpression = false
        if isNative then
            LuaClassObj.HandleUIMessageNoFetch(bp_expression, "UIHideNative")
        else
            LuaClassObj.HandleUIMessageNoFetch(bp_expression, "UIHide")
        end
        LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "ExpressionHide");
    end
end

--原来的恶心写法导致这里必须跟着恶心，这样改动风险最小
function EventShowPetLobbyAction()
    local curStatus = string.lower(LuaClassObj.GetGameStatus(bp_lobby))
    if curStatus == "lobby" then
        local ui_manager = require("ui.manager");
        if ui_manager then
            local ui = ui_manager.ShowUI(ui_manager.UI_Config.pet_lobby_action)
            ui.UIRoot.Slot:SetZOrder(36)
        end
    end
end

--原来的恶心写法导致这里必须跟着恶心，这样改动风险最小
function EventShowPetLobbyActionList()
    local ui_manager = require("ui.manager");
    if ui_manager then
        local ui = ui_manager.GetUI(ui_manager.UI_Config.pet_lobby_action)
        if ui then
            ui:ShowActionList()
        end
    end
end

--原来的恶心写法导致这里必须跟着恶心，这样改动风险最小
function EventHidePetLobbyAction()
    local ui_manager = require("ui.manager");
    if ui_manager then
        ui_manager.HideUI(ui_manager.UI_Config.pet_lobby_action)
    end
end

function EventClosePetLobbyAction()
    local ui_manager = require("ui.manager");
    if ui_manager then
        ui_manager.CloseUI(ui_manager.UI_Config.pet_lobby_action)
    end
end

--原来的恶心写法导致这里必须跟着恶心，这样改动风险最小
function EventHidePetLobbyActionList()
    local ui_manager = require("ui.manager");
    if ui_manager then
        local ui = ui_manager.GetUI(ui_manager.UI_Config.pet_lobby_action)
        if ui then
            ui:HideActionList()
        end
    end
end

function EventOpenExpressionList()
	log("EventOpenExpressionList")
    TeamUPFriendUI.HidePanel();
    LuaClassObj.HandleUIMessage(bp_expression, "UpdateList")
	LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "ExpressionShow");

    --隐藏宠物动作列表
    EventSystem:postEvent(EVENTTYPE_PET, EVENTID_PET_HideLobbyActionList);
end

function EventCloseExpressionList()
	log("EventCloseExpressionList")
	LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "ExpressionHide");
end

function EventOpenExpressionConfig()
	log("EventOpenExpressionConfig")
    
    WardrobeSystem.CallOpenButtonClick()
    
    if WardrobeUI.isShowing then
        LuaClassObj.HandleUIMessageNoFetch(bp_wardrobe, "OpenEmojiTab");
    end
end

function EventOpenExpressionClick()
	log("EventOpenExpressionClick"..BP_ExpressionClickIndex)
    if BP_ExpressionClickIndex >= #BP_ARRAY_ExpressionList then
        return
    end
    local motionId = BP_ARRAY_ExpressionList[BP_ExpressionClickIndex + 1].id
	local canClick = WardrobeUI.CheckCanUseRedEmotion(motionId)
	if canClick then
		DataMgr.ShowNoticeByID(6014);
		return
	end

    --如果是嘲讽表情，增加随机参数
    local myUid = DataMgr.roleData.uid
    local sex = ProfileMgr.GetRoleSexByUid(myUid)
    local randSoundId = ExpressionUI.GetChaoFengRandSoundId(motionId, sex)
    --log("randSoundId = "..randSoundId)
    
    LobbyUI:ShowEmoteAction(DataMgr.roleData.uid, motionId, sex, randSoundId)
    
    if TeamUpSystem.TeamInfo.player_count ~= nil and TeamUpSystem.TeamInfo.player_count > 1 then
        TeamUpSystem.team_player_action(motionId, randSoundId)
    end
end

function bp_expression_OnModeSwitched(gamestatus)
	log("bp_expression_OnModeSwitched gamestatus = " .. gamestatus);
    status = string.lower(gamestatus);
	if status == "lobby" then
        --if ExpressionUI.CheckCanShow() then
            ExpressionUI.Init()
            ExpressionUI.Show()
        --end
    else
        if(BP_ExpressionIsShow) then
            ExpressionUI.Hide()
            ExpressionUI.Release()
        end
	end
end

-- 表情显示控制,有相关界面显示时,表情和提醒不显示
function ExpressionUI.CheckCanShow()
    if UIManager.GetUI(eUIType.eSupplyMainUI) ~= nil then
        return false;
    end
    if UIManager.GetUI(eUIType.eUnknowPassUI) ~= nil then
        return false;
    end
    if UIManager.GetUI(eUIType.eStoreMainUI) ~= nil then
        return false;
    end
    return true;
end

-----------------------------------------------显示问题，蓝图Lobby_BP中调用
function EventShowExpressionPanel()
    LuaClassObj.HandleUIMessage(bp_expression, "UIShowByLobby");
end

function EventCloseExpressionPanel()
    LuaClassObj.HandleUIMessage(bp_expression, "UIHideByLobby");
end

function EventShowExpressionNoticePanel()
    LuaClassObj.HandleUIMessage(bp_expression, "UIShowNoticePanel");
end

function EventCloseExpressionNoticePanel()
    LuaClassObj.HandleUIMessage(bp_expression, "UIHideNoticePanel");
end

-----------------------------------------------news

BP_Struct_News_ID = {
    id = 0,
    content = ""
}
BP_INT_CurNewsId = 0
BP_Array_News_IDS = {
    BP_Struct_News_ID = BP_Struct_News_ID
}
--正常数据
 BP_ARRAY_Item_IDS = {
    
 }
--测试数据
-- BP_ARRAY_Item_IDS = {
--     403010,
--     403016
-- }


news_start_time = 0;
news_end_time = 0; 
BP_News_Show_Button = false 
BP_News_Show_Flag = false --感叹号是否显示 -- 红点是否显示了
--点击Lobby的NEWS图标按钮
function EventShowNewsInfos()

end
--点击Lobby的NEWS图标按钮
function EventOpenNewsPanel()
    BP_News_Show_Flag = false
    LuaClassObj.HandleUIMessage(bp_expression, "SetRedPointShowOrHide");

    if ExpressionUI.IsNews == 1 then
        NewsUI.SetNewsItem(BP_ARRAY_Item_IDS)
        log("Enter News");
        -- BP_News_Show_Flag = false
        -- LuaClassObj.HandleUIMessage(bp_expression, "SetRedPointShowOrHide");
        LuaClassObj.HandleDynamicCreation(bp_news);
        LuaClassObj.HandleUIMessage(bp_news, "showui");
        --ClientSendBAReport(BP_BA_LOBBY_ACTIVITY_CENTER, 0);

    elseif ExpressionUI.IsNews == 2 then
        log("Enter Urgent");
        if WarningNoticeTitle == "" or WarningNoticeContent == "" then return end
        UrgentNoticeUI.ShowMessageBox(WarningNoticeTitle, WarningNoticeContent, WarningNoticeImgUrl, WarningNoticeJump, WarningNoticePos)
        -- report
        NetUtil.SendPkg("read_urgent_notice", BP_Lobby_Warning_Notice_ID)
    end
    
    --ClientSendBAReport(BP_BA_LOBBY_ACTIVITY_CENTER, 0);
end

--获得版本信息
function get_news_infos_req()
    NetUtil.SendPkg("get_release_notes")
end
--是否显示news按钮
function ExpressionUI.ShowNewsInfo()
    -- body
    local currentTime = FuncUtil.GetServerTimeInSec()
    log("zino currenttime ".. currentTime.." "..news_start_time.." "..news_end_time)
    if ExpressionUI.CheckCanShow() and news_start_time < currentTime and currentTime < news_end_time then
        log("zino show news")
        if BP_INT_CurNewsId ~= 0 and BP_INT_CurNewsId ~= news_start_time then    --这是来新活动了，要重新刷下倒计时
            if ExpressionUI.timer ~= nil then
                Timer.RemoveTimer(ExpressionUI.timer)
			    ExpressionUI.timer = Timer.InsertTimer(news_end_time - currentTime, ExpressionUI.HandleTimer, false)
		    end              
        end
        BP_INT_CurNewsId = news_start_time
        ExpressionUI.timer = Timer.InsertTimer(news_end_time - currentTime, ExpressionUI.HandleTimer, false)
        BP_News_Show_Button = true;
        --LuaClassObj.HandleUIMessage(bp_expression, "ShowNewsFlag") 
        LuaClassObj.HandleUIMessage(bp_expression, "UIShow")
        LuaClassObj.HandleUIMessage(bp_expression, "SetRedPointShowOrHide");
        MallSystem.GetMallAllItemsSimpleInfo();
    end
end
function get_news_infos_rsp(msg)
    log("zino  ................... get_news_infos_rsp" )
    log_tree("zino msg  ",msg)
    BP_Array_News_IDS = {}
    -------------------------------------测试代码Start----------------------------------------
    -- BP_News_Show_Button = true -- 如果是注销账号，而不是杀死进程重新登录，则全局变量还是上一次的值
    -- LuaClassObj.HandleUIMessage(bp_expression, "ShowNewsFlag")   
    -- LuaClassObj.HandleUIMessage(bp_expression, "UIShow")
    -------------------------------------测试代码End----------------------------------------
    if msg ~= nil and next(msg) ~=nil then

        BP_News_Show_Button = false -- 如果是注销账号，而不是杀死进程重新登录，则全局变量还是上一次的值
        BP_News_Show_Flag = true
        --log("%%%%%%1"..msg.text_content);

        --local currentTime = FuncUtil.GetServerTimeInSec()
        if msg.start_time ~= nil and msg.end_time ~= nil then
            news_start_time = msg.start_time
            news_end_time = msg.end_time
        end

        BP_STRUCT_News_Log_Data.id = msg.id
        BP_STRUCT_News_Log_Data.type = msg.type;
        BP_STRUCT_News_Log_Data.icon = msg.icon;
        BP_STRUCT_News_Log_Data.red_point = BP_News_Show_Flag;
        BP_Lobby_Notice_Icon = msg.icon
        if msg.type == 1 then
            BP_ARRAY_Item_IDS = {}
            if msg.item_ids ~=nil then 
                for _,itemIDIndex in ipairs(msg.item_ids) do     --插入itemid表    
                    table.insert( BP_ARRAY_Item_IDS, itemIDIndex)
                end
                log_tree("zino BP_Array_Item_IDS ",BP_ARRAY_Item_IDS)
                --ExpressionUI.ShowNewsInfo()
            end
            BP_News_Show_Title = msg.title
            BP_News_Show_Content = msg.text_content
            BP_News_Show_Pos = msg.align_type
            ExpressionUI.IsNews = 1;
        elseif msg.type > 1 then
            log("zino on_get_urgent_notice_rsp")
            
            BP_Lobby_Warning_Notice_ID = msg.id
            WarningNoticeTitle = msg.title
            WarningNoticeContent = msg.text_content
            WarningNoticeImgUrl = msg.map
            WarningNoticeJump = msg.jump
            WarningNoticePos = msg.align_type
            --BP_Lobby_Notice_Icon = msg.icon

            --LuaClassObj.HandleUIMessageNoFetch(bp_expression, "ShowWarningNoticeBtn")
            ExpressionUI.IsNews = 2;
        end

        ExpressionUI.ShowNewsInfo()
    else
        log("zino , get_news_msg == nil ")
    end 
end

--处理倒计时结束后 隐藏news入口的地方
function ExpressionUI.HandleTimer( ... )
    if ExpressionUI.CheckCanShow() then
        BP_News_Show_Button = false
        LuaClassObj.HandleUIMessage(bp_expression, "UIshow")
    end
end

--获取嘲讽表情随机id
function ExpressionUI.GetChaoFengRandSoundId(emoteId, sex)
    local cfg = Client.GetTableData("ChaoFengSoundConfig", emoteId)
    if cfg == nil then
        return 0
    end
    if sex == 1 then
        --男
        if cfg.soundNumNan <= 0 then
            return 0
        end
        local id = XRandom.Random2(0, cfg.soundNumNan) + 1
        return id
    else
        --女
        if cfg.soundNumNv <= 0 then
            return 0
        end
        local id = XRandom.Random2(0, cfg.soundNumNv) + 1
        return id
    end
    return 0
end

function EventSetFlagTrue()
    BP_News_Show_Flag = true;
end

function EventSetFlagFlase()
    BP_News_Show_Flag = false;
end


-------------------------------------------------------------------------
-- 告警图标相关逻辑
-- local WarningNoticeTitle = "";
-- local WarningNoticeContent = "";
function on_get_urgent_notice_rsp(res)
    log("zino on_get_urgent_notice_rsp")
	if res == nil then return end

	log("on_get_urgent_notice_rsp "..tostring(res.id)..","..tostring(res.title)..","..tostring(res.con))
	if res.id == nil or res.title == nil or res.con == nil then return end
	
	BP_Lobby_Warning_Notice_ID = res.id
	WarningNoticeTitle = res.title
	WarningNoticeContent = res.con

	LuaClassObj.HandleUIMessageNoFetch(bp_expression, "ShowWarningNoticeBtn")
end

BP_Lobby_Warning_Notice_ID = 0 -- 本地保存在PlayerPrefs里
-- 三角标消息拉取
function EventPullLobbyWarningNotice()
    log("get_urgent_notice_req "..tostring(BP_Lobby_Warning_Notice_ID))
    NetUtil.SendPkg("get_urgent_notice_req", BP_Lobby_Warning_Notice_ID)
end
-- 点击三角标打开查看消息
function EventLobbyWarningNoticeOpen()
    if WarningNoticeTitle == "" or WarningNoticeContent == "" then return end
    PopUpNoticeUI.ShowMessageBox(WarningNoticeTitle, WarningNoticeContent)
    -- report
    NetUtil.SendPkg("read_urgent_notice", BP_Lobby_Warning_Notice_ID)
end
-------------------------------------------------------------------------

--sami 计算是否可以使用红装表情
function EventExpressionCheckCanUseRedEmotion()
	BP_Expression_RedEmotion_Check_Result = WardrobeUI.CheckCanUseRedEmotion(BP_Expression_RedEmotion_Check_ItemId)
end

--更换皮肤
BP_Expression_Cur_Lobby_Skin_Id = 0;
function ExpressionUI.UpdateLobbySkin(eventType, eventID, skinId)
    BP_Expression_Cur_Lobby_Skin_Id = skinId;
    LuaClassObj.HandleUIMessageNoFetch(bp_expression, "UpdateLobbySkin")
end

s2c = s2c or {};
s2c["get_release_notes_rsp"] = get_news_infos_rsp;
s2c["get_urgent_notice_rsp"] = on_get_urgent_notice_rsp;