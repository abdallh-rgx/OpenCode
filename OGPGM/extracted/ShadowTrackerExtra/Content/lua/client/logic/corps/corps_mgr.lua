-- profileInfo
-- ├─ city: ""
-- ├─ segment_info
-- │  ├─ 1: 101
-- │  ├─ 2: 101
-- │  └─ 3: 101
-- ├─ exp: 455
-- ├─ picUrl: ""
-- ├─ platName: ""
-- ├─ lastOnlineTime: 1520151890
-- ├─ level: 14
-- ├─ startup_type: 0
-- ├─ lastLoginTime: 1520238279
-- ├─ uid: 410000161
-- ├─ social_card: { }
-- ├─ cur_avatar_box_id: 2001001
-- ├─ qq_vip: 0
-- ├─ vipLevel: ""
-- ├─ signature: ""
-- ├─ sex: 1
-- └─ nickName: "红发莉特e"

-- 军团职位枚举
-- corps_class = {
--     leader        = 1;  -- 团长
--     deputy        = 2;  -- 副团长
--     elite         = 3;  -- 精英
--     member        = 11;  -- 普通成员   -- 为后面预留一些职级
-- }

CorpsMgr = CorpsMgr or
{
    saveManagerInfo = nil,
    saveIconID = 0,
    saveIconText = "",
    saveIconColourID = 0,
    onCorpsDataRsp = nil,
    onBatchGetCorpsSummary = nil,
    onGetCorpsSummary = nil,
    unlockRedDotStr = "CorpsUnlockRedDot",
    remindInviteTimeStr = "CorpsRemindInviteTime",
    remindInviteTimeGapStr = "RemindInviteTimeGap",
    cmdrRemindNumLimitStr = "CmdrRemindNumLimit",
    remindNumLimitStr = "RemindNumLimit",
    memberInvitedMarkStr = "CorpsMemberInvitedMark",
    getSummaryReqMapCallBack = {},
    isJumpFromMall = false,
}
local CorpsGetProfileTimeMark = 0
local CorpsGetProfileTimeGap = 300

-- 初始化军团信息
function CorpsMgr.InitData(corps)
    --log_tree("CorpsMgr.InitData corps", corps);
    if corps == nil then
        return;
    end

    DataMgr.corpsInfo.isInit = true;
    CorpsInfoSystem.InitCorpsInfo(corps)
    CorpsInfoSystem.InitCorpsTaskInfo(corps)
    CorpsMemberSystem.InitMembers(corps);
    CorpsMgr.InitManagerInfo(corps);
    CorpsShopSystem.GetShopDataReq(CorpsShopSystem.CurrentShopHasStr, CorpsShopSystem.icon_change_time);
    CorpsShopSystem.GetShopLimitBuyReq();
    CorpsMemberSystem.InitApplyList(corps.apply_list);
    LobbyChatLogic.AddOfflineCorpsChatMsg(corps)
    EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_INFO);
end

function CorpsMgr.InitID(corps_id)
    log("CorpsMgr.InitID corps_id "..tostring(corps_id))
    DataMgr.corpsInfo.id = corps_id or 0;
    LobbyChatSystem.ChangeCorpsData();
    if corps_id == 0 then
        CorpsMemberSystem.isInit = false
        CorpsMgr.ResetData();
    end
    UpdateLobbyCorpsRedDot(CorpsMgr.HasRedDot("lobby"))

    --避免从个人信息跳转创建军团，然后返回个人信息后数据没刷新
    RoleInfoUI.RequestCorpSummaryInfo(false)
end

function CorpsMgr.GetUnlockKey()
    return string.format("%s_%s", DataMgr.roleData.uid, CorpsMgr.unlockRedDotStr)
end

local reddotTree = {
    ["lobby"] = {
        ["home_panel"] = {
            ["train"] = true,
        },
        ["info_panel"] = {
            ["apply"] = true,
        },
        --["task_panel"] = {
        --    ["task"] = true,
        --},
        ["store_panel"] = {
            ["store"] = true,
        },
        ["rank_panel"] = {
            ["rank"] = true,
        },
        ["suggestion_panel"] = {
            ["invited_corps"] = true,
        },
        ["welfare_panel"] = {
            ["welfare"] = true,
        },
        ["unlock_reddot"] = true
    },
}
local reddotCond
local function InitRedDotCond(condName, func)
    reddotCond = {}
    --reddotCond["task"] = function() return CorpsMgr.IsInCorps() and CorpsTaskUI.GetTaskRedDot() end
    reddotCond["apply"] = function() return CorpsMgr.IsInCorps() and CorpsMemberSystem.HasRedPoint end
    reddotCond["train"] = function() return CorpsMgr.IsInCorps() and CorpsTrainingSystem.TrainRedPointIsShow end
    reddotCond["rank"] = function() return CorpsMgr.IsInCorps() and Is_Corps_Rank_Have_Award end
    reddotCond["invited_corps"] = function()
        return not CorpsMgr.IsInCorps() and CorpsSuggestionSystem.hasNewIvitedCorps
    end
    reddotCond["store"] = function() return CorpsMgr.IsInCorps() and CorpsShopSystem.HasNewOpenShopItem() end
    reddotCond["welfare"] = function() return CorpsMgr.IsInCorps() and Is_Corps_Welfare_Have_Receive end
    reddotCond["unlock_reddot"] = function() 
        local limitLevel = CorpsMgr.GetConfigToNumber("CreateCorpsLevel") or 0
        local unlockMark = GlobalData.GetGlobalConfigBooleanValue(CorpsMgr.GetUnlockKey())
        if DataMgr.roleData.level >= limitLevel and not unlockMark then
            return true
        end
        return false
    end
end

function CorpsMgr.HasRedDot(typeStr)
    if reddotCond == nil then
        InitRedDotCond()
    end
    local function findCond(root, typeStr)
        for typeName, condSet in pairs(root) do
            if typeStr == typeName then
                return condSet
            elseif type(condSet) == "table" then
                local find = findCond(condSet, typeStr)
                if find then
                    return find
                end
            end
        end
    end
    local condSet = findCond(reddotTree, typeStr)
    if condSet == nil then
        return false
    end

    local function scan(tb, root)
        for typeName, condSet in pairs(root) do
            if type(condSet) == "table" then
                scan(tb, condSet)
            else
                table.insert(tb, typeName)
            end
        end
    end
    local condArray = {}
    scan(condArray, condSet)
    local result = false
    for _,cond in ipairs(condArray) do
        local condFunc = reddotCond[cond]
        if condFunc == nil then
            print("error can not found condfunc type : " .. cond)
        else
            if condFunc() then
                return true
            end
        end
    end
    return false
end

function CorpsMgr.InitManagerInfo(corps)
    DataMgr.corpsInfo.isAcceptApply = corps.accept_apply;         -- 是否接受申请
    DataMgr.corpsInfo.isNeedApproval = corps.need_approval;       -- 是否需要审批
    DataMgr.corpsInfo.joinLevel = math.max(1, corps.join_level);               -- 申请最低等级 无限制填1
    DataMgr.corpsInfo.joinSegment = math.max(101, corps.join_segment);           -- 申请最低段位 无限制填1 对应段位表
end

function CorpsMgr.ShowCorpsLimitError()
    local level = CorpsMgr.GetConfigToNumber("CreateCorpsLevel") or 0;
    local msg = FuncUtil.LocalizeResFormat(411038, level, CorpsMgr.GetLevelName(level));
    PopUpNoticeUI.ShowNewNotice(msg);
end

-- 重置军团信息
function CorpsMgr.ResetData()
    DataMgr.corpsInfo.isInit = false;
    DataMgr.corpsInfo.id = 0;
    CorpsOwnHomePageUI.ResetCorpsGroupState()
    CorpsMemberSystem.ResetData();
    CorpsShopSystem.ClearData();
end

function CorpsMgr.GetCorpsMemberList()
    -- 这里基本只给组队界面用

    log("CorpsMgr.GetCorpsMemberList","corps")
    if not CorpsMgr.IsInCorps() then
        log("CorpsMgr.GetCorpsMemberList 1","corps")
        CorpsMgr.waitForMemberList = false
        EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_GET_MEMBERLIST, {})
        return
    end

    if CorpsMemberSystem.isInit then
        log("CorpsMgr.GetCorpsMemberList 2","corps")
        CorpsMemberSystem.waitForMemberList = false
        EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_GET_MEMBERLIST, DataMgr.corpsInfo.corpsMemberList)
    else
        log("CorpsMgr.GetCorpsMemberList 3","corps")
        CorpsMgr.waitForMemberList = true
        if CorpsMgr.onCorpsDataRsp == nil then
            CorpsMgr.SendCorpsDataReq()
        end
    end
end

--是否有军团
function CorpsMgr.IsInCorps()
    return DataMgr.corpsInfo.id and DataMgr.corpsInfo.id ~= 0;
end

-- 登陆下发军团ID
function CorpsMgr.on_sync_player_corps_id(corps_id)
    log("CorpsMgr.on_sync_player_corps_id corps_id "..tostring(corps_id))

    if corps_id ~= 0 and corps_id == DataMgr.corpsInfo.id then
        return;
    end

    CorpsMgr.InitID(corps_id);

    if corps_id ~= 0 then
        CorpsMgr.SendCorpsDataReq();
        CorpsMemberSystem.SendGetCorpsApplyListReq();
        CorpsRankSystem.SendGetMyRankData(101)
        CorpsSuggestionSystem.InitInvitedCorpsArray({})
        CorpsWelfareSystem.have_can_recevie_share_ticket_request();
    else
        CorpsSuggestionSystem.get_corps_invitee_list_req(false);
    end
    EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_CORPS_ID);
end

-- 请求军团信息
function CorpsMgr.SendCorpsDataReq(isWaitting, onCorpsDataRspCB)
    -- local msg = debug.traceback()
    -- log("CorpsMgr.SendCorpsDataReq "..msg)
    log("CorpsMgr.SendCorpsDataReq")
    CorpsMgr.onCorpsDataRsp = onCorpsDataRspCB;
    if isWaitting then
        NetUtil.SendPkg("get_corps_data_req");
    else
        NetUtil.SendPkg("get_corps_data_req");
    end
end

function CorpsMgr.get_corps_data_rsp(msg, corps)
    log("CorpsMgr.get_corps_data_rsp msg "..tostring(msg));
    --log_tree("CorpsMgr.get_corps_data_rsp corps", corps, "corps");

    if msg == "ok" then
        -- 初始化数据
        CorpsMgr.InitData(corps);
        CorpsMgr.CallGetCorpsDataCB();
        -- 初始化军团任务数据
        --请求军团任务信息
        CorpsMgr.TaskGetDataReq()
    elseif msg ~= nil then
        CorpsMgr.InitID(0);
        if msg == 411008 then
            CorpsMgr.CallGetCorpsDataCB();
        else
            ShowNotice(msg);
        end
    end
end

function CorpsMgr.CallGetCorpsDataCB()
    log("CorpsMgr.CallGetCorpsDataCB");
    if CorpsMgr.onCorpsDataRsp ~= nil then
        local cb = CorpsMgr.onCorpsDataRsp;
        CorpsMgr.onCorpsDataRsp = nil;
        cb();
    end
end

-- 请求创建军团
function CorpsMgr.CreateCorpsReq()
	log("CorpsMgr.CreateCorpsReq");
    if BP_CorpsCreate_Currency_Icon_ID == 0  then
        BP_CorpsCreate_Currency_Icon_ID = 2001001
    end
    log("Name:" .. BP_CorpsCreate_Name .. "|Icon ID:" .. BP_CorpsCreate_Currency_Icon_ID .. "|Announcement: " .. BP_CorpsCreate_Announcement .. "|CityID:" .. CorpsCreateUI.CorpsCreate_City_ID .. "|Icon_Text:" .. BP_CorpsCreate_Currency_Icon_Text .. "|Icon_ColourID:" .. BP_CorpsCreate_Currency_Icon_ColourID);
    NetUtil.SendPriorityPkg(false, "create_corps_rsp", "create_corps_req",BP_CorpsCreate_Name,BP_CorpsCreate_Currency_Icon_ID,BP_CorpsCreate_Announcement,CorpsCreateUI.CorpsCreate_City_ID,BP_CorpsCreate_Currency_Icon_Text,BP_CorpsCreate_Currency_Icon_ColourID);
end

function CorpsMgr.create_corps_rsp(msg, corps_id, corps)
	log("CorpsMgr.create_corps_rsp msg "..tostring(msg));
    -- idip 禁止创建军团
    if msg == "ban-create-corps" then
        local endtime = corps_id
        local reason = corps
        local title = Client.GetTableData("LocalizeRes", "101001").TextValue;
        local timevalue = Client.GetTableData("LocalizeRes", "115005").TextValue;
        local date = os.date(timevalue, endtime);
        local textvalue = Client.GetTableData("LocalizeRes", "115007").TextValue;
        local text = string.format(textvalue, reason.."\n", date)
        CommonMessageBoxUI:ShowPanel(1, title, text);
        return
    end
	if msg == "ok" then 
        EventOnCorpsClose();
        CorpsMgr.InitID(corps_id);
        CorpsMgr.InitData(corps);
        CorpsMgr.TaskGetDataReq()
        CorpsBaseUI.Init();
        DataMgr.ShowNoticeByID(410045);
	else
        if msg == 411038 then
            CorpsMgr.ShowCorpsLimitError();
        else
            DataMgr.ShowNoticeByID(msg);
        end
	end

end

-- 获取军团配置参数
function CorpsMgr.GetCorpsConfig(configName)
	local msgConfig = Client.GetTableData("CorpsConfig", configName);
	
	if msgConfig then
		return msgConfig.ConfigValue;
	end
	return nil;
end

-- 获取军团配置信息
function CorpsMgr.GetConfigToNumber(cfgID)
    local cfg = Client.GetTableData("CorpsConfig", cfgID);
    if cfg then
        return tonumber(cfg.ConfigValue);
    end

    return nil;
end

-- 设置军团申请参数:
function CorpsMgr.SendSetupApplyParamReq(accept_apply, need_approval, join_level, join_segment)
    CorpsMgr.saveManagerInfo = {accept_apply = accept_apply, need_approval = need_approval, join_level = join_level, join_segment = join_segment};
    -- log_tree("CorpsMgr.SendSetupApplyParamReq CorpsMgr.saveManagerInfo", CorpsMgr.saveManagerInfo);
    NetUtil.SendPkg("corps_setup_apply_param_req", accept_apply, need_approval, join_level, join_segment);
end

function CorpsMgr.corps_setup_apply_param_rsp(msg)
    if msg == nil then
        return
    end
    log("CorpsMgr.corps_setup_apply_param_rsp msg "..tostring(msg));
    if msg == "ok" then
        ShowNotice(410004);
        if CorpsMgr.saveManagerInfo ~= nil then
            CorpsMgr.InitManagerInfo(CorpsMgr.saveManagerInfo);
            CorpsMgr.saveManagerInfo = nil;
        end
    else
        ShowNotice(msg);
    end
end

-- 修改图标：
function CorpsMgr.SendChangeIconReq(iconID,iconText,textCoulourId)
    log("CorpsMgr.SendChangeIconReq iconID "..iconID .. " iconText:" .. iconText .. " textCoulourId:" .. textCoulourId)
    CorpsMgr.saveIconID = iconID;
    CorpsMgr.saveIconText = iconText;
    CorpsMgr.saveIconColourID = textCoulourId;
    NetUtil.SendPkg("corps_change_icon_req", iconID, iconText, textCoulourId);
end

function CorpsMgr.corps_change_icon_rsp(res,timevalue)
    if res == nil then
        return
    end
    log("CorpsMgr.corps_change_icon_rsp res "..tostring(res))
    if res == "ok" then
        DataMgr.corpsInfo.icon = CorpsMgr.saveIconID;
        DataMgr.corpsInfo.icon_text = CorpsMgr.saveIconText;
        DataMgr.corpsInfo.icon_text_colour = CorpsMgr.saveIconColourID;
        CorpsManagerUILogic.OnChangeIconRes(CorpsMgr.saveIconID,CorpsMgr.saveIconText,CorpsMgr.saveIconColourID);
        EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_ICON)
    elseif res == 433005 then
        DataMgr.ShowNoticeByString(FuncUtil.LocalizeResFormat(tostring(res), FuncUtil.TimeFormatExtNoZero(timevalue)))
    else
        ShowNotice(res);
    end
end

function CorpsMgr.GetMaxSegment(profileInfo)
    return profileInfo.cur_max_segment_level or 0;
end

function CorpsMgr.GetMemberProfile(idList, completeFunc)
    local function callback(profileList)
        local infoList = {}
        local groupState = {}
        for _,profileInfo in ipairs(profileList) do
            local info = {}
            info.strUid = profileInfo.uid;
            info.Name = profileInfo.nickName
            info.Level = profileInfo.level;
            info.Sex = profileInfo.sex;
            info.RankIntegralLevel = CorpsMgr.GetMaxSegment(profileInfo);
            info.IconUrl = profileInfo.picUrl;
            info.IconFrameID = profileInfo.cur_avatar_box_id;
            info.lastOnlineTime = profileInfo.lastOnlineTime;
            info.lastOnlineTimeStr = FuncUtil.FormatTime(profileInfo.lastOnlineTime, "online");
            info.nation = profileInfo.nation;
            info.upass_is_buy, info.upass_is_show = FriendSystem.ParseUpassInfo(profileInfo.upass);  -- 绝地通行证
            infoList[tonumber(profileInfo.uid)] = info;

            -- teamup friend use
            info.profile = profileInfo

            -- local groupInfo = {}
            -- if tostring(info.strUid) == DataMgr.roleData.uid then -- 玩家自己永远在线              
            --     groupInfo.online = 1;
            -- else
            --     groupInfo.online = profileInfo.online
            -- end
            -- groupInfo.teamState = profileInfo.teamState
            -- groupInfo.currentTeamAmount = profileInfo.currentTeamAmount
            -- groupInfo.maxTeamAmount = profileInfo.maxTeamAmount
            -- if profileInfo.timeSinceGameBegin <= 0 then
            --     groupInfo.timeSinceGameBeginStr = "";
            -- else
            --     groupInfo.timeSinceGameBeginStr = FuncUtil.FormatTime2(profileInfo.timeSinceGameBegin);
            -- end
            -- groupState[tonumber(profileInfo.uid)] = groupInfo
        end
        -- log_tree("===============getAvatarBaseInfo ", infoList)
        if completeFunc then
            completeFunc(infoList, groupState)
        end
    end

    local curTime = FuncUtil.GetServerTimeInSec()
    -- 批量请求组队状态
    if curTime - CorpsGetProfileTimeMark > CorpsGetProfileTimeGap then
        CorpsGetProfileTimeMark = curTime
        ProfileMgr.GetProfileList(idList, callback);
    else
        ProfileMgr.GetProfileList(idList, callback);
    end
end

function CorpsMgr.GetAvatarBaseInfo(idList, completeFunc, forceUpdate)
    local function callback(profileList)
        local infoList = {}
        for _,profileInfo in ipairs(profileList) do
            local info = {}
            info.strUid = profileInfo.uid;
            info.Name = profileInfo.nickName
            info.Level = profileInfo.level;
            info.Sex = profileInfo.sex;
            info.RankIntegralLevel = CorpsMgr.GetMaxSegment(profileInfo);
            info.IconUrl = profileInfo.picUrl;
            info.IconFrameID = profileInfo.cur_avatar_box_id;
            info.lastOnlineTime = profileInfo.lastOnlineTime
            info.lastOnlineTimeStr = FuncUtil.FormatTime(profileInfo.lastOnlineTime, "online")
            infoList[tonumber(profileInfo.uid)] = info
        end
        -- log_tree("===============getAvatarBaseInfo ", infoList)
        if completeFunc then
            completeFunc(infoList)
        end
    end

    if forceUpdate == nil then
        forceUpdate = true;
    end
    -- 批量请求组队状态
    ProfileMgr.GetProfileList(idList, callback);
end

function CorpsMgr.TaskGetDataReq()
    log("$$CorpsMgr.TaskGetDataReq")
	--NetUtil.SendPkg("get_corps_task_req")
end

function CorpsMgr.ActivenessGetAwardReq(rewardId)
    NetUtil.SendPkg("get_corps_active_award_req", rewardId)
end

function CorpsMgr.TaskGetAwardReq(taskId)
    NetUtil.SendPkg("get_corps_task_award_req", taskId)
end

function CorpsMgr.get_corps_task_rsp(ret, task)
    -- log_tree("$$CorpsMgr.get_corps_task_rsp" ,task)
	log("CorpsMgr.get_corps_task_rsp msg "..tostring(ret));
	if ret == "ok" then 
        DataMgr.UpdateCorpsTaskChange(true, task)
        DataMgr.UpdateCorpsActiveBoxChange(true, task)
        -- CorpsTaskUI.RefreshTaskInfo()
        -- CorpsTaskUI.RefreshAwradInfo()
		-- DataMgr.ShowNoticeByString("获取军团任务信息成功")
	else
        ShowNotice(tonumber(ret))
		-- DataMgr.ShowNoticeByString("获取军团任务信息失败")
	end
end

function CorpsMgr.get_corps_active_award_rsp(ret, chest_id, itemlist)
	log("CorpsMgr.get_corps_active_award_rsp msg "..tostring(ret));
    -- log_tree("$$get_corps_active_award_rsp" ,itemlist)
	if ret == "ok" then 
		-- DataMgr.ShowNoticeByString("获取宝箱成功")

		-- 客户端自动设置任务状态
		local rewardData = DataMgr.corpsActiveness.list[chest_id]
		if rewardData == nil then
			log("Error: reward data can't find ID :" .. chest_id)
			return
		end
        rewardData.status = 2

		CorpsTaskUI.ActivenessGetAward(chest_id, itemlist)
        CorpsBaseUI.UpdateRedPoint()
	else
		ShowNotice(tonumber(ret))
	end
end

function CorpsMgr.get_corps_task_award_rsp(ret,taskid,itemlist)
	log("CorpsMgr.get_corps_task_award_rsp msg "..tostring(ret));
	if ret == "ok" then 
		-- DataMgr.ShowNoticeByString("获取任务成功")

		-- 客户端自动设置任务状态
        local taskData = DataMgr.corpsTaskData.list[taskid]
		if taskData == nil then
            log("Error: task data can't find ID :" .. taskid)
			return
		end
		taskData.status = 2

        CorpsTaskUI.TaskGetAward(taskid, itemlist)
        CorpsBaseUI.UpdateRedPoint()
    else
        log("$$CorpsMgr.get_corps_task_award_rsp" .. ret)
		ShowNotice(tonumber(ret))
	end
end

function CorpsMgr.get_corps_event_list()
    NetUtil.SendPkg("get_corps_event_list")
end

function CorpsMgr.get_corps_event_list_rsp(ok, corps_id, event_list)
    log("===============get_corps_event_list_rsp")
    if ok == NetErrorCode_NONE then
        CorpsInfoSystem.InitCorpsLog(event_list)
    end
end

local announcementCache = ""
function CorpsMgr.corps_change_announcement_req(announcement)
    announcementCache = announcement
    NetUtil.SendPkg("corps_change_announcement_req", announcement)
    log("================= " .. announcement)
end

function CorpsMgr.corps_change_announcement_rsp(msg)
    if msg == NetErrorCode_NONE then
        ShowNotice(410040)
        DataMgr.corpsInfo.announcement = announcementCache
        EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_NOTICE, announcementCache)
    else
        ShowNotice(tonumber(msg))
    end
end

function CorpsMgr.get_auto_invite_list_req()
    NetUtil.SendPkg("get_auto_invite_list_req")
end

function CorpsMgr.get_auto_invite_list_rsp(ret, idList)
    log_tree("get_auto_invite_list_req", {ret, idList})
    if ret == NetErrorCode_NONE and #idList ~= 0 then
        DataMgr.corpsInfo.lastAutoInviteTime = FuncUtil.GetServerTimeInSec();
        CorpsAutoInviteUI.ShowUI(idList) 
    end
end

function CorpsMgr.corps_auto_invite_req(idList)
    log_tree("corps_auto_invite_req", idList)
    if #idList > 0 then
        NetUtil.SendPkg("corps_auto_invite_req", idList)
    else
        CorpsAutoInviteUI.HideUI()
    end
end

function CorpsMgr.corps_auto_invite_rsp(ret)
    --log_tree("corps_auto_invite_rsp", {ret, idList})
    if ret == NetErrorCode_NONE then
        ShowNotice(422001)
        CorpsAutoInviteUI.HideUI()
    else
        ShowNotice(ret)
    end
end
-- 一键入群相关 start
-- 绑定群
-- c2s.bind_corps_group_req(group_id)
-- s2c.bind_corps_group_rsp(ok, group_id, group_name)   ok=="ok" 表示成功
-- 解绑群
-- c2s.unbind_corps_group_req()
-- s2c.unbind_corps_group_rsp(ok)
-- 查询群关系
-- c2s.get_corps_group_relation_req()
-- s2c.get_corps_group_relation_rsp(ok, relation)  ok=="ok" 表示成功  relation: 1 群主  2 管理员 3 普通成员 4 成员
-- 加入群
-- c2s.join_corps_group_req()
-- s2c.join_corps_group_rsp(ok, group_id)  ok=="ok" 表示成功
function CorpsMgr.CreateGroupWXError(errorCode)
    if errorCode == -1 then
        --DataMgr.ShowNoticeByString("创建错误"); 
        DataMgr.ShowNoticeByID(117016);              
    elseif errorCode == 2009 or errorCode == -10001 then
        --DataMgr.ShowNoticeByString("游戏没有建群权限"); 
        DataMgr.ShowNoticeByID(117017);
    elseif errorCode == 2010 or errorCode == -10002 then
        --DataMgr.ShowNoticeByString("参数检查错误"); 
        DataMgr.ShowNoticeByID(117018);
    elseif errorCode == 2011 or errorCode == -10005 then
        --DataMgr.ShowNoticeByString("微信群已存在"); 
        DataMgr.ShowNoticeByID(117019);
    elseif errorCode == 2012 or errorCode == -10006 then
        --DataMgr.ShowNoticeByString("建群数量超过上限"); 
        DataMgr.ShowNoticeByID(117020);
    elseif errorCode == 2013 or errorCode == -10007 then
        --DataMgr.ShowNoticeByString("群ID不存在"); 
        DataMgr.ShowNoticeByID(117021);
    elseif errorCode == 2014 or errorCode == -10008 then
        --DataMgr.ShowNoticeByString("ID今天已建过群，每天每个ID只能创建一个"); 
        DataMgr.ShowNoticeByID(117022);
    elseif errorCode == 2015 then
        --DataMgr.ShowNoticeByString("加群数量超限，每天每个ID最多可加2个群");
        DataMgr.ShowNoticeByID(117023); 
    else
        -- ShowNotice(errorCode)
    end
end

function CorpsMgr.GetCorpsGroupId()
    local prefix = GroupTypePerfix["CORPS"]
    local serverId = DataMgr.roleData.sns_group_zone_id
    local id = ""
    if serverId ~= ServerZoneId["ONLINE"] then
        id = string.format("_%d_%s%d", serverId, prefix, DataMgr.corpsInfo.id)
    else
        id = string.format("%s%d", prefix, DataMgr.corpsInfo.id)
    end
    log("CorpsMgr.GetCorpsGroupId : " .. id)
    return id
end

function CorpsMgr.get_corps_group_relation_req()
    if BP_Platform == BP_ENUM_PLAYFORM_WX then
        local groupId = CorpsMgr.GetCorpsGroupId()
        CorpsManagerUILogic.queryWechatGroup({unionId = groupId})
    else
        --NetUtil.SendPkg("get_corps_group_relation_req")
    end
end

function CorpsMgr.QueryCorpsGroupWX_rsp(hasGroup, selfInGroup)
    local groupInfo = {
        hasGroup = hasGroup,
        inGroup = selfInGroup
    }
    local roleId = tonumber(DataMgr.roleData.uid)
    local isCommand = roleId == DataMgr.corpsInfo.commanderId
    if isCommand and hasGroup and DataMgr.corpsInfo.group_id == 0 then
        CorpsMgr.BindCorpsGroupWXRsp()
    end
    EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_GROUPSTATE, groupInfo)
end

function CorpsMgr.get_corps_group_relation_rsp(errorCode, relation)
    log("===========get_corps_group_relation_rsp===============" .. errorCode)
    local hasGroup = false
    local inGroup = false
    if errorCode == NetErrorCode_NONE then
        hasGroup = true
        inGroup = relation ~= 4
    else
        -- ShowNotice(errorCode)
    end
    local groupInfo = {
        hasGroup = hasGroup,
        inGroup = inGroup
    }
    EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_GROUPSTATE, groupInfo)
end

function CorpsMgr.bind_corps_group_req()
    if BP_Platform == BP_ENUM_PLAYFORM_WX then
        local groupsId = CorpsMgr.GetCorpsGroupId()
        local corpsName = DataMgr.corpsInfo.name
        CorpsManagerUILogic.createWechatGroup({unionId = groupsId, chatRoomName = corpsName})
    else
        NetUtil.SendPkg("bind_corps_group_req")
    end
end

function CorpsMgr.BindCorpsGroupWXRsp()
    local groupsId = CorpsMgr.GetCorpsGroupId()
    NetUtil.SendPkg("bind_corps_group_req", groupsId)
end

function CorpsMgr.bind_corps_group_rsp(errorCode, groupId, groupName )
    log("===========bind_corps_group_rsp===============" .. errorCode)
    if errorCode == NetErrorCode_NONE then
        DataMgr.corpsInfo.group_id = groupId
        local groupInfo = {
            hasGroup = true,
            inGroup = true,
        }
        EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_GROUPSTATE, groupInfo)
        if (BP_Platform == BP_ENUM_PLAYFORM_WX) then
            ShowNotice(Client.GetTableData("LocalizeRes", "301277").TextValue)
        elseif (BP_Platform == BP_ENUM_PLAYFORM_QQ) then
            CommonMessageBoxUI:ShowPanel(1, "提示", Client.GetTableData("LocalizeRes", "117050").TextValue);
        end
    elseif errorCode == 421004 then -- 已经绑定过群 这个错误码不需要显示
        if groupId ~= nil then
            DataMgr.corpsInfo.group_id = groupId
        end
    else
        ShowNotice(errorCode)
    end
end

function CorpsMgr.join_corps_group_req()
    if BP_Platform == BP_ENUM_PLAYFORM_WX then
        local groupsId = CorpsMgr.GetCorpsGroupId()
        local corpsName = DataMgr.corpsInfo.name
        CorpsManagerUILogic.joinWechatGroup({unionId = groupsId, chatRoomName = corpsName})
    else
        NetUtil.SendPkg("join_corps_group_req")
    end
end

function CorpsMgr.join_corps_group_rsp(result)
    if result == NetErrorCode_NONE then
        local groupInfo = {
            hasGroup = true,
            inGroup = true
        }
        EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_GROUPSTATE, groupInfo)
        if (BP_Platform == BP_ENUM_PLAYFORM_WX) then

        elseif (BP_Platform == BP_ENUM_PLAYFORM_QQ) then
            CommonMessageBoxUI:ShowPanel(1, "提示", Client.GetTableData("LocalizeRes", "117049").TextValue);
        end
    else
        ShowNotice(result)
    end
end

function CorpsMgr.unbind_corps_group_req()
    NetUtil.SendPkg("unbind_corps_group_req")
end

function CorpsMgr.unbind_corps_group_rsp(result)
    log("...................unbind_corps_group_rsp " .. result)
    if result == NetErrorCode_NONE then
        local groupInfo = {
            hasGroup = false,
            inGroup = false
        }
        EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_GROUPSTATE, groupInfo)
        ShowNotice(Client.GetTableData("LocalizeRes", "301276").TextValue)
    else
        ShowNotice(result)
    end
end
-- 一键入群相关 end

-- 通过概要信息初始化数据
function CorpsMgr.InitBySummary(summary)
    CorpsMgr.InitManagerInfo(summary)
    DataMgr.corpsInfo.icon = summary.icon;
end

-- 请求军团信息
-- CorpsMgr.get_corps_summary_rsp corps_summary
-- ├─ corps_id: 100001
-- ├─ city: 51
-- ├─ activeness: 0
-- ├─ level: 1
-- ├─ leader: 410000021
-- ├─ icon: 0
-- ├─ join_level: 1
-- ├─ announcement: "请输入军团宣言"
-- ├─ member_num: 1
-- ├─ join_segment: 1
-- ├─ name: "iij
-- └─ member_max: 0


function CorpsMgr.get_corps_summary_req(corps_id, uid, cb, isWaitting, req_type)
    --log_tree("get_corps_summary_req", {uid, corps_id, cb, isWaitting, req_type});
    log("CorpsMgr.get_corps_summary_req corps_id:" .. tostring(corps_id) .. ",uid:" .. tostring(uid))
    if corps_id ~= nil then
        if req_type == nil then
            CorpsMgr.onGetCorpsSummary = cb;
        else
            CorpsMgr.getSummaryReqMapCallBack[req_type] = cb;
        end
        
        if isWaitting == nil then
            isWaitting = true;
        end

        if isWaitting then
            NetUtil.SendPkg("get_corps_summary_req", tonumber(corps_id), tonumber(uid), req_type);
        else
            NetUtil.SendPkg("get_corps_summary_req", tonumber(corps_id), tonumber(uid), req_type)
        end
    end
end

function CorpsMgr.get_corps_summary_rsp(res, corps_id, corps_summary, req_type)
    log("CorpsMgr.get_corps_summary_rsp:" .. tostring(res) .. ",corps_id:" .. tostring(corps_id))
    --log_tree("get_corps_summary_rsp", {res, corps_id, corps_summary, req_type});
    local cb = nil;
    if req_type == nil then
        cb = CorpsMgr.onGetCorpsSummary;
        CorpsMgr.onGetCorpsSummary = nil;
    else
        cb = CorpsMgr.getSummaryReqMapCallBack[req_type];
        CorpsMgr.getSummaryReqMapCallBack[req_type] = nil;

        if req_type == "plat_invite" then
            -- 平台拉起清除本地数据
            LoginSystem.extendInfo = {};
        end
    end

    if res == "ok" then
        -- log_tree("CorpsMgr.get_corps_summary_rsp corps_summary", corps_summary)
        if corps_summary ~= nil then
            corps_summary.corps_id = corps_id;

            if corps_id == DataMgr.corpsInfo.id then
                CorpsMgr.InitBySummary(corps_summary);
            end

            EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_GET_SUMMARY, corps_summary)

            -- 记录到概要里面
            RoleInfoSystem.get_corps_summary_rsp(corps_id, corps_summary)

            if cb ~= nil then
                cb(corps_summary);
            end
        end

    elseif res ~= nil then
        ShowNotice(res);

        if cb ~= nil then
            cb(nil)
        end
    end
end

function CorpsMgr.SummaryToPanelData(summary, panelData)
    if summary == nil or panelData == nil then
        return;
    end

    panelData.str_corps_id = tostring(summary.corps_id);
    panelData.level = summary.level;
    panelData.name = summary.name;
    panelData.activeness = summary.activeness;
    panelData.city = summary.city;
    -- local cityData = Client.GetTableData("SocialCardCity", summary.city);
    -- if cityData ~= nil then
    --     panelData.city = cityData.City2;
    -- else
    --     panelData.city = "";
    -- end

    panelData.icon = summary.icon;
    panelData.join_level = summary.join_level;
    panelData.join_segment = summary.join_segment;
    panelData.member_num = summary.member_num;

    panelData.icon_text = summary.icon_text
    panelData.icon_text_colour = summary.icon_text_colour

    local levelCfg = Client.GetTableData("CorpsLevel", summary.level);
    if levelCfg ~= nil then
        panelData.member_max = levelCfg.MemberLimit;
    else
        panelData.member_max = 0;
    end

    panelData.announcement = summary.announcement;
end

-- 批量请求军团信息
function CorpsMgr.batch_get_corps_summary_req(cb, corps_idlist)
    if not corps_idlist or #corps_idlist == 0 then
        log("CorpsMgr.batch_get_corps_summary_req is nil");
        if cb ~= nil then
            cb(nil)
        end
    else
        log("CorpsMgr.batch_get_corps_summary_req");
        -- log_tree("CorpsMgr.batch_get_corps_summary_req corps_idlist", corps_idlist);
        CorpsMgr.onBatchGetCorpsSummary = cb;
        NetUtil.SendPkg("batch_get_corps_summary_req", 1, corps_idlist);
    end
end

function CorpsMgr.batch_get_corps_summary_rsp(res, opt_type, corps_info)
    log("CorpsMgr.batch_get_corps_summary_rsp");
    -- log_tree("CorpsMgr.batch_get_corps_summary_rsp corps_info", corps_info);
    local cb = CorpsMgr.onBatchGetCorpsSummary;
    CorpsMgr.onBatchGetCorpsSummary = nil;

    if res == "ok" then
        if cb ~= nil then
            cb(corps_info);
        end
    elseif res ~= nil then
        ShowNotice(res);
    end
end

-- 举报功能
function CorpsMgr.SendReportInfo(captainName, teamID, teamName, teamNotice)
    local reportInfo = {}
    reportInfo.UserName = captainName;
    reportInfo.ReportRoleID = tonumber(DataMgr.roleData.uid)
    reportInfo.TeamID = tonumber(teamID)
    reportInfo.TeamName = teamName
    reportInfo.TeamNotice = teamNotice
    reportInfo.ComplaintType2 = 4
    
    NetUtil.SendPkg("report_info", reportInfo)

end

-- 获取等级和段位名
function CorpsMgr.GetLevelName(level)
    if level == 1 then
        return FuncUtil.GetLocalizeResStr("410002");
    end

    local lvlData = Client.GetTableData("MilitaryRankLevel", level);
    return lvlData.MilitaryRankName;
end

function CorpsMgr.GetRankLevelName(levelID)
    if levelID == 101 then
        return FuncUtil.GetLocalizeResStr("410003");
    end

    local lvlData = Client.GetTableData("RankIntegralLevel", levelID);
    return lvlData.Name;
end

local changeCityReqID = 0
function CorpsMgr.corps_change_city_req(id)
    changeCityReqID = id
    NetUtil.SendPkg("corps_change_city_req", id)
end

function CorpsMgr.corps_change_city_rsp(res,days)
    if res == NetErrorCode_NONE then
        DataMgr.corpsInfo.city = changeCityReqID
        EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_CITY)
        ShowNotice(301192)
    elseif res == 433001 then
        DataMgr.ShowNoticeByString(string.format(DataMgr.GetMsgByID(res), days));
    else
        ShowNotice(res)
    end
end

-- 军团改名
function CorpsMgr.corps_change_name_req(corpsName)
    NetUtil.SendPkg("corps_change_name_req", corpsName)
end

function CorpsMgr.corps_change_name_rsp(res, corpsName)    
    log("CorpsMgr.corps_change_name_rsp :"..tostring(res));
    if res ~= 0 then
        ShowNotice(res);    -- 后台错误码与本地化表一一对应了
    else
        DataMgr.corpsInfo.changeNameTime = FuncUtil.GetServerTimeInSec();
        ShowNotice(660022); -- 改名成功
        --更新仓库
        if WardrobeUI.isShowing then
            WardrobeUI:UpdateItemList();
        end

        ReviseNameUI.ModifyNameOk();
        ReviseNameUI.Hide();
    end
end

s2c["sync_player_corps_id"] = CorpsMgr.on_sync_player_corps_id;
s2c["get_corps_data_rsp"] = CorpsMgr.get_corps_data_rsp;
s2c["create_corps_rsp"] = CorpsMgr.create_corps_rsp;
s2c["corps_setup_apply_param_rsp"] = CorpsMgr.corps_setup_apply_param_rsp;
s2c["get_corps_task_rsp"] = CorpsMgr.get_corps_task_rsp;
s2c["get_corps_active_award_rsp"] = CorpsMgr.get_corps_active_award_rsp;
s2c["get_corps_task_award_rsp"] = CorpsMgr.get_corps_task_award_rsp;
s2c["get_corps_event_list_rsp"] = CorpsMgr.get_corps_event_list_rsp;
s2c["corps_change_announcement_rsp"] = CorpsMgr.corps_change_announcement_rsp;
s2c["corps_change_icon_rsp"] = CorpsMgr.corps_change_icon_rsp;
-- 一键入群 start
s2c["get_corps_group_relation_rsp"] = CorpsMgr.get_corps_group_relation_rsp;
s2c["bind_corps_group_rsp"] = CorpsMgr.bind_corps_group_rsp;
s2c["join_corps_group_rsp"] = CorpsMgr.join_corps_group_rsp;
s2c["unbind_corps_group_rsp"] = CorpsMgr.unbind_corps_group_rsp;
-- 一键入群 end
s2c["get_corps_summary_rsp"] = CorpsMgr.get_corps_summary_rsp;
s2c["batch_get_corps_summary_rsp"] = CorpsMgr.batch_get_corps_summary_rsp;
s2c["corps_change_city_rsp"] = CorpsMgr.corps_change_city_rsp;
s2c["get_auto_invite_list_rsp"] = CorpsMgr.get_auto_invite_list_rsp;
s2c["corps_auto_invite_rsp"] = CorpsMgr.corps_auto_invite_rsp;  -- 军团一键邀请
s2c["corps_change_name_rsp"] = CorpsMgr.corps_change_name_rsp;  -- 军团改名