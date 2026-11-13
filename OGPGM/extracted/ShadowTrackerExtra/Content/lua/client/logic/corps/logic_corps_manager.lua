CorpsManagerUILogic = CorpsManagerUILogic or
{
    isShow = false,
    segmentArray = {},
    CorpsNeedQueryWechatGroup = false,
    levelCfgArray = {},
    LobbyWXGroupQueryQueue = {},
    LobbyWXGroupSystemType = 0,
}

local function CorpsManagerUILogicDoShow()
    LuaClassObj.HandleDynamicCreation(bp_corps_manager);
    CorpsManagerUILogic.isShow = true;

    CorpsManagerUILogic.InitOptions();

    BP_STRUCT_CorpsManager_PanelInfo.isAcceptApply = DataMgr.corpsInfo.isAcceptApply;
    BP_STRUCT_CorpsManager_PanelInfo.isNeedApproval = DataMgr.corpsInfo.isNeedApproval;
    BP_STRUCT_CorpsManager_PanelInfo.joinLevel = CorpsManagerUILogic.GetLevelIndex(DataMgr.corpsInfo.joinLevel) - 1;
    BP_STRUCT_CorpsManager_PanelInfo.joinSegment = CorpsManagerUILogic.GetSegmentIndexByID(DataMgr.corpsInfo.joinSegment) - 1;
    BP_CorpsManager_IconID = DataMgr.corpsInfo.icon;
    BP_CorpsManager_IconText = DataMgr.corpsInfo.icon_text;
    BP_CorpsManager_IconColourId = DataMgr.corpsInfo.icon_text_colour;

    -- log_tree("CorpsManagerUILogic.ShowUI BP_STRUCT_CorpsManager_PanelInfo", BP_STRUCT_CorpsManager_PanelInfo);
    LuaClassObj.HandleUIMessage(bp_corps_manager, "ShowUI");
    UIManager.Show(eUIType.eCorpsManagerUI)

    EventSystem:registEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_CORPS_ID, CorpsManagerUILogic.OnUpdateCorpsID);
end

function CorpsManagerUILogic.ShowUI()
    if CorpsManagerUILogic.isShow then
        return;
    end

    CorpsMgr.get_corps_summary_req(DataMgr.corpsInfo.id, nil, CorpsManagerUILogicDoShow, true);
end

function CorpsManagerUILogic.OnUpdateCorpsID()
    if DataMgr.corpsInfo.id == 0 then
        CorpsManagerUILogic.HideUI();
    end
end

function CorpsManagerUILogic.GetSegmentIndexByID(id)
    for i,v in ipairs(CorpsManagerUILogic.segmentArray) do
        if v.Level == id then
            return i;
        end
    end

    return 0;
end

function CorpsManagerUILogic.GetLevelIndex(level)
    local minLevel = CorpsMgr.GetConfigToNumber("CreateCorpsLevel");
    if level < minLevel then
        return 1
    end

    for i,v in ipairs(CorpsManagerUILogic.levelCfgArray) do
        if v.Level == level then
            return i;
        end
    end

    return 1;
end

function CorpsManagerUILogic.InitOptions()

    -- 初始化等级
    -- BP_ARRAY_CorpsManager_LevelOption = {FuncUtil.GetLocalizeResStr("410002")};
    BP_ARRAY_CorpsManager_LevelOption = {};
    CorpsManagerUILogic.levelCfgArray = {}
    local minLevel = CorpsMgr.GetConfigToNumber("CreateCorpsLevel");
    for k,v in pairs(Client.GetTable("MilitaryRankLevel")) do
        if v.Level >= minLevel then
            table.insert(CorpsManagerUILogic.levelCfgArray, v);
        end
    end

    table.sort(CorpsManagerUILogic.levelCfgArray, CorpsManagerUILogic.OptionSort);

    for i=1,#CorpsManagerUILogic.levelCfgArray do
        local v = CorpsManagerUILogic.levelCfgArray[i]
        table.insert(BP_ARRAY_CorpsManager_LevelOption, v.MilitaryRankName);
    end

    -- 初始化段位
    BP_ARRAY_CorpsManager_SegmentOption = {FuncUtil.GetLocalizeResStr("410003")};
    CorpsManagerUILogic.segmentArray = {}
    for k,v in pairs(Client.GetTable("RankIntegralLevel")) do
        table.insert(CorpsManagerUILogic.segmentArray, v);
    end

    table.sort(CorpsManagerUILogic.segmentArray, CorpsManagerUILogic.OptionSort);

    for i,v in ipairs(CorpsManagerUILogic.segmentArray) do
        table.insert(BP_ARRAY_CorpsManager_SegmentOption, v.Name);
    end
    table.remove(BP_ARRAY_CorpsManager_SegmentOption, 2)

    -- log_tree("CorpsManagerUILogic.InitOptions CorpsManagerUILogic.levelCfgArray", CorpsManagerUILogic.levelCfgArray)
    -- log_tree("CorpsManagerUILogic.InitOptions BP_ARRAY_CorpsManager_LevelOption", BP_ARRAY_CorpsManager_LevelOption)
    -- log_tree("CorpsManagerUILogic.InitOptions BP_ARRAY_CorpsManager_SegmentOption", BP_ARRAY_CorpsManager_SegmentOption)
    -- log_tree("CorpsManagerUILogic.InitOptions CorpsManagerUILogic.segmentArray", CorpsManagerUILogic.segmentArray)
end

function CorpsManagerUILogic.OptionSort(a, b)
    return a.Level < b.Level;
end

function CorpsManagerUILogic.HideUI()
    if not CorpsManagerUILogic.isShow then
        return;
    end
    CorpsManagerUILogic.isShow = false;
    UIManager.Hide(eUIType.eCorpsManagerUI)
    LuaClassObj.HandleUIMessage(bp_corps_manager, "HideUI");

    EventSystem:unregistEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_CORPS_ID, CorpsManagerUILogic.OnUpdateCorpsID);
end

function CorpsManagerUILogic.OnChangeIconRes(iconID,iconText,iconTextColour)
    CorpsIconSelectUI.HideUI();
    BP_CorpsManager_IconID = iconID;
    BP_CorpsCurIconText = iconText;
    BP_CorpsCurIconColourId = iconTextColour
    LuaClassObj.HandleUIMessage(bp_corps_manager, "UpdateIcon");
end

function CorpsManagerUILogic.OnAppReactive()
    log("CorpsManagerUILogic.OnAppReactive")
    if BP_Platform == BP_ENUM_PLAYFORM_WX and CorpsManagerUILogic.CorpsNeedQueryWechatGroup then

        local groupId = CorpsMgr.GetCorpsGroupId()
        CorpsManagerUILogic.queryWechatGroup({unionId = groupId})
        log("CorpsManagerUILogic.OnAppReactive Query Send")
    end
end

function CorpsManagerUILogic.OnClickOK()
    local level = CorpsManagerUILogic.levelCfgArray[BP_STRUCT_CorpsManager_PanelInfo.joinLevel + 1].Level;

    local segmentData = CorpsManagerUILogic.segmentArray[BP_STRUCT_CorpsManager_PanelInfo.joinSegment + 1];
    if segmentData == nil then
        segmentData = CorpsManagerUILogic.segmentArray[1];
    end

    local segment = segmentData.Level;

    CorpsMgr.SendSetupApplyParamReq(BP_STRUCT_CorpsManager_PanelInfo.isAcceptApply,
        BP_STRUCT_CorpsManager_PanelInfo.isNeedApproval,
        level,
        segment);

    CorpsManagerUILogic.HideUI();
end
--***************************************************平台工会群方法******************
--创建微信工会群
function CorpsManagerUILogic.createWechatGroup(params)
	if params == nil then
		return;
	end
	params.unionId = params.unionId;
	--params.chatRoomName = params.chatRoomName or "工会群";
    local allianceGroup = Client.GetTableData("LocalizeRes", "301275").TextValue;
    params.chatRoomName = params.chatRoomName or allianceGroup;
    
	params.chatRoomNickName = params.chatRoomNickName or DataMgr.roleData.nickName;
	log("CorpsManagerUILogic create wechat group!");
    CorpsManagerUILogic.LobbyWXGroupSystemType = 2
    CorpsManagerUILogic.CorpsNeedQueryWechatGroup = true
	Client.WechatCreateGroup(NetInterface, params.unionId, params.chatRoomName, params.chatRoomNickName);
end

--加入微信工会群
function CorpsManagerUILogic.joinWechatGroup(params)
	if params == nil then
		return;
	end
	params.unionId = params.unionId;
	params.chatRoomNickName = params.chatRoomNickName or DataMgr.roleData.nickName;
	log("CorpsManagerUILogic join wechat group!");
    CorpsManagerUILogic.LobbyWXGroupSystemType = 2
    CorpsManagerUILogic.CorpsNeedQueryWechatGroup = true
	Client.WechatJoinGroup(NetInterface, params.unionId, params.chatRoomNickName);
end

--查询微信工会群
function CorpsManagerUILogic.queryWechatGroup(params)
	if params == nil then
		return;
	end
	params.unionId = params.unionId;
	params.openIdList = params.openIdList or DataMgr.roleData.openID;
	log("CorpsManagerUILogic query wechat group!"..tostring(params.unionId).. "openidList".. params.openIdList);
    CorpsManagerUILogic.LobbyWXGroupSystemType = 2
    table.insert(CorpsManagerUILogic.LobbyWXGroupQueryQueue, CorpsManagerUILogic.LobbyWXGroupSystemType)
    -- log_tree("Corp Query wx group", LobbyWXGroupQueryQueue)
	Client.WechatQueryGroup(NetInterface, params.unionId, params.openIdList);
end

--工会群回调
--SnsAction见MsdkAdapterPublicDefine的SnsAction
--groupInfo中的错误码参见http://wiki.msdk.qq.com/Unity/const.html#Unity_GroupRet eFlag
function CorpsManagerUILogic.OnGroupNotify(snsAction)
    if snsAction ~= 111 and CorpsManagerUILogic.LobbyWXGroupSystemType ~= 2 then
        log("Not crops Call Group!")
        return
    end
    
    if snsAction == 111 then
        local correctQuery = false
        for k,v in pairs(CorpsManagerUILogic.LobbyWXGroupQueryQueue) do
            if v == 2 then
                CorpsManagerUILogic.LobbyWXGroupQueryQueue[k] = nil
                correctQuery = true
                break
            end
        end
        -- log_tree("crop Query wx group rsp", CorpsManagerUILogic.LobbyWXGroupQueryQueue)
        if not correctQuery then
            return
        end
    end
    CorpsManagerUILogic.CorpsNeedQueryWechatGroup = false
    
	log("CorpsManagerUILogic onGroupResult snsAction" .. tostring(snsAction));
	local groupInfo = Client.GetGroupInfo(NetInterface, tonumber(snsAction));
    -- log_tree("CorpsManagerUILogic onGroupResult groupInfo", groupInfo);
	if groupInfo == nil then
		log("CorpsManagerUILogic OnGroupNotify is null!");
		return;
	end
	--local snsAction = groupInfo["SnsAction"];
	local flag = tonumber(groupInfo["Flag"]);
	local errorCode = groupInfo["ErrorCode"];
	local platform = groupInfo["Platform"];
	local desc = groupInfo["Desc"];
    local wechatGroupInfo = groupInfo["wechatGroupInfo"]
    
	if flag ~= 0 then
		log("军团工会群功能失败，错误码为" .. tostring(flag));
        
        if tonumber(snsAction) ~= 111 then
            if tonumber(flag) == -1 then
                flag = errorCode
            end
            CorpsMgr.CreateGroupWXError(flag)
            return
        end
	end
    
	if snsAction == 112 then
		--创建微信工会
		log("CorpsManagerUILogic OnGroupNotify create wechat group");
        CorpsMgr.BindCorpsGroupWXRsp()
	elseif snsAction == 113 then
		--加入微信工会
		log("CorpsManagerUILogic OnGroupNotify join wechat group");
        CorpsMgr.join_corps_group_rsp("ok")
	elseif snsAction == 111 then
		--查询微信工会
		log("CorpsManagerUILogic OnGroupNotify query wechat group ");
        CorpsMgr.QueryCorpsGroupWX_rsp(flag == 0, wechatGroupInfo.OpenIdList ~= "")
	end
end
