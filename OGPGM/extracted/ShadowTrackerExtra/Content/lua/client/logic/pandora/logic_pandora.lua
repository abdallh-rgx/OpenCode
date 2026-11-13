PANDORA_CLOUD_TEST = 0;--潘多拉环境, 0:正式环境 1:测试环境

PandoraSystem = PandoraSystem or {
    Act_Id_Pop = 9010070, --拍脸actid
    Act_Id_Notice = 9010333,--公告actid
    Act_Id_ActivityNavigator= 9010071,--集合页actid
    Act_Id_MysteriousShop= 9010072,--神秘商店actid

    isInit = false,
    isInitUINameTable = false,

    PopStatus = 0,--拍脸状态

    PopStatus_Init = 0, --初始
    PopStatus_Wait = 1, --等待
    PopStatus_Ready = 2, --ready
    PopStatus_Pop = 3, --pop
    PopStatus_End = 4, --end

    PopJumpModuleID = 0, --跳转模块ID
    PopJumpType = "", --跳转类型
    PopJumpFromScene = "", --跳转来源
    PopJumping = false, --是否在跳转中

    PopFinishCallback = nil, --拍脸完成回调

    ActReadyStateList = {},--活动ready状态列表
    ActRedPointStateList = {}, --活动红点状态列表

    RefreshActBtnTimer = nil, --活动入口按钮刷新定时器

    act_index = 15,  --对应区域化运营表的运营分组，默认分组为G1=15

}

local Module_UIName_Table = {};

local UI_ShowState_List = {};

local function EventActivityUpdate(eventType, eventID, vars)
    log("PandoraSystem.EventActivityUpdate eventType:"..eventType..",eventID:"..eventID);
    log_tree("vars=", vars);
    --log_tree("Pandora EventActivityUpdate vars=", vars);
    if vars["idList"] == nil then
        return;
    end

    local newIdList = {}
    for k, v in pairs(vars["idList"]) do
        if v then
            table.insert( newIdList, k );
        end
    end

    log_tree("Pandora EventActivityUpdate newIdList=", newIdList);
    PandoraSystem.RefreshActRedPoint(newIdList);
end

--pandora://?actid=9010071
local function EventUrlJump(eventType, eventID, vars)
    log("PandoraSystem.EventUrlJump eventType:"..eventType..",eventID:"..eventID);
    log_tree("vars=", vars);
    local actId = tonumber(vars["actid"]);
    if actId == nil or actId == 0 then
        return;
    end

    PandoraSystem.SendShow(actId);
end

--面板开关是否开启潘多拉
function PandoraSystem.CheckSysOpen()
    log("PandoraSystem.CheckSysOpen");
    local switch = LobbySystem.LobbyMenuOpenStatus[BP_ENUM_PANDORA_OPEN];
    if switch == nil then
        return true;
    end

    if switch.is_open == 1 then
        log("PandoraSystem.CheckSysOpen is open");
        return true;
    else
        log("PandoraSystem.CheckSysOpen is close");
        return false;
    end
end

function PandoraSystem.ShouldPop()
    log("PandoraSystem.ShouldPop");
    return (PandoraSystem.CheckSysOpen() and PandoraSystem.PopStatus ~= PandoraSystem.PopStatus_End);
end

function PandoraSystem.NoticeIsCanUse()
    log("PandoraSystem.NoticeIsCanUse");
    return (PandoraSystem.CheckSysOpen() and PandoraSystem.ActIsReady(PandoraSystem.Act_Id_Notice));
end

--活动是否准备好
function PandoraSystem.ActIsReady(actId)
    local isReay = PandoraSystem.ActReadyStateList[tonumber(actId)];
    log("PandoraSystem.ActHasRedPoint, actId: " .. actId);
    if isReay ~= nil then
        log("PandoraSystem.ActHasRedPoint, isReay: "..isReay);
    end
    if not isReay then
        return false;
    else
        return true;
    end
end

--设置活动状态
function PandoraSystem.SetActReady(actId, isReady)
    log("PandoraSystem.ActHasRedPoint, actId: " .. actId .. ",isReady: " ..tostring(isReady));
    PandoraSystem.ActReadyStateList[tonumber(actId)] = isReady;
end

--活动是否有红点
function PandoraSystem.ActHasRedPoint(actId)
    local hasRedPoint = PandoraSystem.ActRedPointStateList[tonumber(actId)];
    log("PandoraSystem.ActHasRedPoint, actId: " .. actId.." ,hasRedPoint"..tostring(hasRedPoint));

    if not hasRedPoint then
        return false;
    else
        return true;
    end
end

--记录活动是否有红点
function PandoraSystem.SetActRedPoint(actId, hasRedPoint)
    log("PandoraSystem.ActHasRedPoint, actId: " .. actId .. ",hasRedPoint: " ..tostring(hasRedPoint));
    PandoraSystem.ActRedPointStateList[tonumber(actId)] = hasRedPoint;
end

--清除定时器
function PandoraSystem.ClearTimer()
    log("PandoraSystem.ClearTimer");
    if PandoraSystem.RefreshActBtnTimer then
        Timer.RemoveTimer(PandoraSystem.RefreshActBtnTimer);
    end
    PandoraSystem.RefreshActBtnTimer = nil;
end

--初始蓝图widget名称和模块的映射关系
function PandoraSystem.InitModuleUINameTable()
    log("PandoraSystem.InitModuleUINameTable");
    if PandoraSystem.isInitUINameTable then
        return;
    end

--[[
    Module_UIName_Table["Share_DayFinalyLogicBP_C"] = {BP_ENUM_MODULE_SHARE};
    Module_UIName_Table["ShareAward_BP_C"] = {BP_ENUM_MODULE_SHARE_AWARD};
    Module_UIName_Table["Activty_BP_C"] = {BP_ENUM_MODULE_ACTIVITY};
    Module_UIName_Table["LobbyFriendList_UIBP_C"] = {BP_ENUM_MODULE_FRIEND, BP_ENUM_MODULE_MASTER};
    Module_UIName_Table["LobbyTeam_RecommendTeamList_LogicBP_C"] = {BP_ENUM_MODULE_ALLIANCE_MAIN_PANEL};
    Module_UIName_Table["LobbyTeamMain_LogicBP_C"] = {BP_ENUM_MODULE_ALLIANCE_MAIN_PANEL};
    Module_UIName_Table["Market_BP_C"] = {BP_ENUM_MODULE_MARKET};
    Module_UIName_Table["Wardrobe_BP_C"] = {BP_ENUM_MODULE_WARDROBE};
    Module_UIName_Table["Corps_Logic_BP_C"] = {BP_ENUM_MODULE_CORPS};
    Module_UIName_Table["Armory_Logic_BP_C"] = {BP_ENUM_MODULE_ARMORY};
    Module_UIName_Table["Newteaching_LogicBP_C"] = {BP_ENUM_MODULE_NEWTEACHING};
]]
    PandoraSystem.isInitUINameTable = true;
end

function PandoraSystem.GetLoginData(act_index)
    if act_index ~= nil then
        log("PandoraSystem.GetLoginData act_index: "..tostring(act_index));
        PandoraSystem.act_index = act_index;
    end
end


function PandoraSystem.Init()
    if  not PandoraSystem.CheckSysOpen() then
        return;
    end

    if BP_Panduola_Init then
        log("PandoraSystem.Init PandoraSystem is already initialized");
        return;
    end
    log("PandoraSystem.Init PANDORA_CLOUD_TEST="..tostring(PANDORA_CLOUD_TEST));

    PandoraSystem.ClearTimer();
    PandoraSystem.InitModuleUINameTable();

    PandoraSystem.PopStatus = PandoraSystem.PopStatus_Init;

    PandoraSystem.PopJumpModuleID = 0;
    PandoraSystem.PopJumpType = "";
    PandoraSystem.PopJumpFromScene = "";
    PandoraSystem.PopJumping = false;

    PandoraSystem.PopFinishCallback = nil;

    PandoraSystem.ActReadyStateList = {};
    PandoraSystem.ActRedPointStateList = {};

    EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CHANGE, EventActivityUpdate);
    EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_PANDORA, EventUrlJump);

    local openId = tostring(DataMgr.roleData.openID);
    local roleId = tostring(DataMgr.roleData.uid);
    local appId = Client.GetITopGameId(NetInterface);
    local platId = "1";
    local accType = "";
    local area = "1";
    local partion = "1";
    local cloudTest = tostring(PANDORA_CLOUD_TEST);
    if Client.IsCEVersion() then
        cloudTest = "2";--体验环境
    end
    local accessToken = Client.GetToken(NetInterface);
    local sdkVersion = "";
    local gameAppVersion = Client.GetAppVersion();
    local roleName = DataMgr.roleData.nickName;
    -- local payToken = Client.GetToken(NetInterface);
    local payToken = "";
    local headUrl = DataMgr.roleData.headIconUrl;
    local registerchannelID = Client.GetRegisterChannelID(NetInterface);

    local deviceplatform = string.lower(Client.GetDevicePlatformName());
    if deviceplatform == "android" then
        platId = "1";
        sdkVersion = "GziPubgM_Android_V1";
    elseif deviceplatform == "ios" then
        platId = "0";
        local is5sDevices = Client.IsIPhoneFiveS(GameFrontendHUD);
        if is5sDevices == true then        
            sdkVersion = "GziPubgM_IOS_5S_V1";
        else
            sdkVersion = "GziPubgM_IOS_V1";
        end
    else
        platId = "1";
        sdkVersion = "GziPubgM_Android_V1";
    end

    --根据平台修改获取潘多拉平台字符串
    local channel = Client.GetLoginChannel(NetInterface);
    log("PandoraSystem.Init channel="..channel);
    accType = PANDORA_PLAYFORM[channel];
--  if BP_Platform == BP_ENUM_PLAYFORM_WX then
--        accType = "wx";
--        area = "1";
--	elseif BP_Platform == BP_ENUM_PLAYFORM_QQ then
--        accType = "qq";
--        area = "2";
--    end
     local belongingId = PandoraSystem.act_index;
     local myLanguage = PandoraSystem.GetCurrentLanguage();
     --即itop_ticket，h5用来强校验登陆态的重要参数，并可以反解出用户openid
     local ticket = Client.GetWebViewTicket(NetInterface);
    
    if cloudTest == "1" then
        log("PandoraSystem.Init openId="..openId);
        log("PandoraSystem.Init roleId="..roleId);
        log("PandoraSystem.Init appId="..appId);
        log("PandoraSystem.Init platId="..platId);
        log("PandoraSystem.Init accType="..accType);
        log("PandoraSystem.Init area="..area);
        log("PandoraSystem.Init partion="..partion);
        log("PandoraSystem.Init cloudTest="..cloudTest);
        log("PandoraSystem.Init accessToken="..accessToken);
        log("PandoraSystem.Init sdkVersion="..sdkVersion);
        log("PandoraSystem.Init gameAppVersion="..gameAppVersion);
        log("PandoraSystem.Init roleName="..roleName);
        log("PandoraSystem.Init payToken="..payToken);
        log("PandoraSystem.Init headUrl="..headUrl);
        log("PandoraSystem.Init registerchannelID="..registerchannelID);    
        log("PandoraSystem.Init belongingId="..belongingId);
        log("PandoraSystem.Init language="..myLanguage);
        log("PandoraSystem.Init ticket="..ticket);
    end

    Client.PandoraInit(openId, roleId, appId, platId, accType, area, partion, cloudTest, accessToken, sdkVersion, gameAppVersion, roleName, payToken, headUrl, registerchannelID, belongingId, myLanguage, ticket);
    BP_Panduola_Init = true;
end

function PandoraSystem.Release()
    log("PandoraSystem.Release");
    if not BP_Panduola_Init then
        return;
    end

    PandoraSystem.ClearTimer();

    EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CHANGE, EventActivityUpdate);
    EventSystem:unregistEvent(EVENTTYPE_URL, BP_ENUM_MODULE_PANDORA, EventUrlJump);

    PandoraSystem.PopStatus = PandoraSystem.PopStatus_Init;

    PandoraSystem.PopJumpModuleID = 0;
    PandoraSystem.PopJumpType = "";
    PandoraSystem.PopJumpFromScene = "";
    PandoraSystem.PopJumping = false;

    PandoraSystem.PopFinishCallback = nil;

    PandoraSystem.ActReadyStateList = {};
    PandoraSystem.ActRedPointStateList = {};

    Client.PandoraClose();

    -- PandoraSystem.isInit = false;
    BP_Panduola_Init = false;
end

--弹出潘多拉界面
function PandoraSystem.DoPop(finishCallback)
    log("PandoraSystem.DoPop");
    if not PandoraSystem.ShouldPop() then
        return;
    end

    PandoraSystem.PopFinishCallback = finishCallback;

    log("PandoraSystem.DoPop "..Timer.CurrentTime)

    PandoraWaitingUI.Show();
    Timer.InsertTimer(-1, 
    function()
        PandoraWaitingUI.Hide();
        PandoraSystem.StartPop();
    end, false);
end

--潘多拉界面结束
function PandoraSystem.OnPopFinish()
    log("PandoraSystem.OnPopFinish");
    PandoraWaitingUI.Hide();

    if PandoraSystem.PopFinishCallback ~= nil then
        PandoraSystem.PopFinishCallback();
    end

    PandoraSystem.PopFinishCallback = nil;
end

--开始拍脸
function PandoraSystem.StartPop()
    log("PandoraSystem.StartPop 1");
    -- if not PandoraSystem.isInit then
    if not BP_Panduola_Init then
        log("PandoraSystem.StartPop PandoraSystem is not initialized");
        PandoraSystem.OnPopFinish();
        return;
    end

    log("PandoraSystem.StartPop 2");

    if not _isInLobby then
        PandoraSystem.OnPopFinish();
        return;
    end

    log("PandoraSystem.StartPop 3");

    if PandoraSystem.PopStatus == PandoraSystem.PopStatus_End then
        PandoraSystem.OnPopFinish();
        return;
    end

    if PandoraSystem.PopStatus == PandoraSystem.PopStatus_Pop then
        return;
    end

    if PandoraSystem.PopStatus == PandoraSystem.PopStatus_Ready then
        log("PandoraSystem.StartPop 4");
        PandoraSystem.PopStatus = PandoraSystem.PopStatus_Pop;
        PandoraSystem.SendShowPop();
    else
        log("PandoraSystem.StartPop 5");
        PandoraSystem.StartPopWait();
    end
end

--开始显示等待loading图
function PandoraSystem.StartPopWait()
    log("PandoraSystem.StartPopWait");
    if PandoraSystem.PopStatus ~= PandoraSystem.PopStatus_Init then
        return;
    end

    log("PandoraSystem.StartPopWait "..Timer.CurrentTime)

    PandoraSystem.PopStatus = PandoraSystem.PopStatus_Wait;

    PandoraWaitingUI.Show();

    Timer.InsertTimer(1, function()
        PandoraWaitingUI.Hide();

        if PandoraSystem.PopStatus == PandoraSystem.PopStatus_Wait then
            log("PandoraSystem PopWait timeout "..Timer.CurrentTime);
            PandoraSystem.StopPop();
        end
    end, false);
end

--终止拍脸
function PandoraSystem.StopPop()
    log("PandoraSystem.StopPop");
    if not BP_Panduola_Init then
        log("PandoraSystem.StopPop PandoraSystem is not initialized");
        return;
    end

    PandoraSystem.PopStatus = PandoraSystem.PopStatus_End;

    PandoraSystem.OnPopFinish();

    local jsonStr = "{\"type\":\"PopEnd\",\"content\":\"\"}";
    PandoraSystem.SendCmd(jsonStr);
end

--拍脸图处于已准备状态
function PandoraSystem.OnPopReady()
    log("PandoraSystem.OnPopReady");
    if PandoraSystem.PopStatus == PandoraSystem.PopStatus_End then
        return;
    end

    local isPopReady = PandoraSystem.ActIsReady(PandoraSystem.Act_Id_Pop);

    if isPopReady then
        if PandoraSystem.PopStatus == PandoraSystem.PopStatus_Wait then
            PandoraWaitingUI.Hide();
            PandoraSystem.PopStatus = PandoraSystem.PopStatus_Ready;
            PandoraSystem.StartPop();
        else 
            PandoraSystem.PopStatus = PandoraSystem.PopStatus_Ready;
        end
    end
end

--公告处于已准备状态
function PandoraSystem.OnNoticeReady()
    if PandoraSystem.ActHasRedPoint(PandoraSystem.Act_Id_Notice) then
        BP_Panduola_RedPoint = 1
    else
        BP_Panduola_RedPoint = 0
    end
    log("PandoraSystem.OnNoticeReady BP_Panduola_RedPoint: "..BP_Panduola_RedPoint);

    LuaClassObj.HandleUIMessageNoFetch(bp_activty, "UpdatePDLRedPoint");
end

--TODO 集合页
--活动集合页处于已准备状态
function PandoraSystem.OnActivityNavigatorReady()

    if PandoraSystem.ActHasRedPoint(PandoraSystem.Act_Id_ActivityNavigator) then
        BP_Panduola_RedPoint = 1
    else
        BP_Panduola_RedPoint = 0
    end
    log("PandoraSystem.OnActivityNavigatorReady BP_Panduola_RedPoint: "..BP_Panduola_RedPoint);

    --TODO 修改相应按钮红点状态
    --LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "UpdatePandoraActivityNavigatorRedPoint")
    -- 活动刷新
    -- LobbySystem.refresh_activity_display_byPandora();

   --[[ 

    --LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "UpdatePandoraActivityNavigatorRedPoint")
    LuaClassObj.HandleUIMessageNoFetch(bp_activty, "UpdatePDLRedPoint");--]]
end

function PandoraSystem.OnActivityMysteriousShopReady()

    if PandoraSystem.ActHasRedPoint(PandoraSystem.Act_Id_MysteriousShop) then
        BP_Panduola_RedPoint = 1
    else
        BP_Panduola_RedPoint = 0
    end
    log("PandoraSystem.OnActivityMysteriousShopReady BP_Panduola_RedPoint: "..BP_Panduola_RedPoint);
end

--发送协议
--jsonStr: "{\"type\":\"Open\",\"content\":\"Pop\"}"
function PandoraSystem.SendCmd(jsonStr)
    log("PandoraSystem.SendCmd jsonStr:"..jsonStr);    
    if not BP_Panduola_Init then
        log("PandoraSystem.SendCmd PandoraSystem is not initialized");
        return;
    end

    log("PandoraSystem.SendCmd: "..tostring(jsonStr));

    Client.PandoraSendCmd(jsonStr);
end

function PandoraSystem.SendShow(actId)
    log("PandoraSystem.SendShow actId:"..actId);
    --isPopPanel: 0表示不是拍脸活动，1表示是拍脸活动
    local IsPopPanel = 0;
    if actId == PandoraSystem.Act_Id_Pop then
        isPopPanel = 1;
    end
    local jsonStr = "";
    if actId == PandoraSystem.Act_Id_MysteriousShop then
        local isEnter = 1;
        jsonStr = "{\"type\":\"EnterStore\",\"content\":\""..isEnter.."\"}";
    else
        jsonStr = "{\"type\":\"Show\",\"actid\":\""..actId.."\",\"margin\":\""..LobbySystem.uiRect.."\",\"content\":\"\",\"isPopPanel\":\""..IsPopPanel.."\"}";
    end
    PandoraSystem.SendCmd(jsonStr);
end

function PandoraSystem.SendHide(actId)
    log("PandoraSystem.SendHide actId:"..actId);
    local jsonStr = "{\"type\":\"Hide\",\"actid\":\""..actId.."\",\"content\":\"\"}";
    PandoraSystem.SendCmd(jsonStr);
end

function PandoraSystem.SendShowNext(actId)
    log("PandoraSystem.SendShowNext actId:"..actId);
    local jsonStr = "{\"type\":\"ShowNext\",\"actid\":\""..actId.."\",\"margin\":\""..LobbySystem.uiRect.."\",\"content\":\"\"}";
    PandoraSystem.SendCmd(jsonStr);
end

function PandoraSystem.SendShowCurrent(actId)
    log("PandoraSystem.SendShowCurrent actId:"..actId);
    local jsonStr = "{\"type\":\"ShowCurrent\",\"actid\":\""..actId.."\",\"margin\":\""..LobbySystem.uiRect.."\",\"content\":\"\"}";
    PandoraSystem.SendCmd(jsonStr);
end

function PandoraSystem.SendShowPop()
    log("PandoraSystem.SendShowPop");
    PandoraSystem.SendShow(PandoraSystem.Act_Id_Pop);
end

function PandoraSystem.SendShowNextPop()
    log("PandoraSystem.SendShowNextPop");
    PandoraSystem.SendShowNext(PandoraSystem.Act_Id_Pop)
end

function PandoraSystem.SendShowCurrentPop()
    log("PandoraSystem.SendShowCurrentPop");
    PandoraSystem.SendShowCurrent(PandoraSystem.Act_Id_Pop)
end

function PandoraSystem.SendShowNotice()
    log("PandoraSystem.SendShowNotice");
    PandoraSystem.SendShow(PandoraSystem.Act_Id_Notice);
end

function PandoraSystem.SendHideNotice()
    log("PandoraSystem.SendHideNotice");
    PandoraSystem.SendHide(PandoraSystem.Act_Id_Notice);
end

function PandoraSystem.SetZOrder(NewZOrder)
    log("PandoraSystem.SetZOrder NewZOrder:"..NewZOrder);
    if nil == NewZOrder or type(NewZOrder) ~= "number" then
        return;
    end

    local jsonStr = "{\"type\":\"setZOrder\",\"content\":\""..NewZOrder.."\"}";
    PandoraSystem.SendCmd(jsonStr);
end

function PandoraSystem.GetModuleIdByUrl(url)
    log("PandoraSystem.GetModuleIdByUrl url:"..url);
    local params = FuncUtil:ParseURLParams(url);
	local moduleId = tonumber(params["module"]);

	return moduleId;
end

function PandoraSystem.GetActIdByUrl(url)
    log("PandoraSystem.GetActIdByUrl url:"..url);
    local params = FuncUtil:ParseURLParams(url);
	local actId = tonumber(params["actid"]);

	return actId;
end

function PandoraSystem.PopJumpScene(url, JumpType, FromScene)   
    if url == nil then
        return;
    end
    log("PandoraSystem.PopJumpScene url: "..url);
    if JumpType ~= nil then
        log("PandoraSystem.PopJumpScene JumpType: "..JumpType);
    end
    if FromScene ~= nil then
        log("PandoraSystem.PopJumpScene FromScene: "..FromScene);
    end
    local JumpID = PandoraSystem.GetModuleIdByUrl(url);
    if JumpID == nil or JumpID == 0 then
        log("PandoraSystem PopJumpScene error: JumpID is nil");
        return;
    end

    if FromScene == "Notice" then
        BP_STRUCT_ActivtyInfo_Click.SubActType = 1000;
        LuaClassObj.HandleUIMessageNoFetch(bp_activty, "OnCloseBtn");
        PandoraSystem.StopPop();
    end

    PandoraSystem.PopJumpModuleID = JumpID;
    PandoraSystem.PopJumpType = JumpType;
    PandoraSystem.PopJumpFromScene = FromScene;

    PandoraSystem.PopJumping = true;

    PandoraSystem.JumpPandoraUrl(url, false);
end

function PandoraSystem.Share(strTitle, strDesc, strUrl, shareType)
    if strTitle == nil or strDesc == nil or strUrl == nil then
        return;
    end

    log("PandoraSystem.Share("..strTitle..", "..strDesc..", "..strUrl..", "..shareType..")");

    local nShareType = 0;
    if shareType == "0" then
        nShareType = ShareType.Friend;
    elseif shareType == "1" then
        nShareType = ShareType.Moment;
    end

    --[[if BP_Platform == BP_ENUM_PLAYFORM_WX then
        Client.WechatShareWithUrlInfo(NetInterface,
		strDesc,
		strTitle,
		"Arts/UI/TableIcons/ShareBg/Share_Icon.jpg",
		strUrl, nShareType);
    elseif BP_Platform == BP_ENUM_PLAYFORM_QQ then
        Client.QQShare(NetInterface,
		strDesc,
		strTitle,
		"Arts/UI/TableIcons/ShareBg/Share_Icon.jpg",
		SHARE_IMG_URL,
		strUrl, nShareType);
    end--]]

    --根据平台修改获取潘多拉平台字符串
    local channel = Client.GetLoginChannel(NetInterface);
    log("PandoraSystem.Share channel="..channel);
    ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_ItemGetShare_ImagePath, strDesc, "", channel);

end

function PandoraSystem.UpdateRedPoint()
    log("PandoraSystem.UpdateRedPoint");
    for k, v in pairs(PandoraSystem.ActRedPointStateList) do
        if PandoraSystem.ActIsReady(k) then
            LobbyUI:LobbyRedPointUpdate(k, v);
        end
    end
end


local function QueryActRedPoint(idList, cmdType)
    log("PandoraSystem.QueryActRedPoint");
    if nil == idList or #idList == 0 then
        return;
    end
    log_tree("idList:",idList);
    log("cmdType: "..cmdType)
    local result = {};
    local strId = "";
    for _, v in ipairs(idList) do
        strId = tostring(v);
        result[strId] = 0;
        if ActivitySystem.HasActivityRedDotByID(tonumber(v)) then
            result[strId] = 1;
        end
        log(strId..": ".. tostring(result[strId]))
    end

    local strResult = json.encode(result);
    local strCmd = "{\"type\":\""..cmdType.."\",\"content\":"..strResult.."}";
    --log("PandoraSystem.OnQueryActRedPoint cmd="..strCmd);
    PandoraSystem.SendCmd(strCmd);
end

function PandoraSystem.OnProcessRtnAct(content)
    log("PandoraSystem.OnProcessRtnAct content: "..content)
    local idList = string.split(content, ",");
    QueryActRedPoint(idList, "RtnAct");
end

function PandoraSystem.RefreshActRedPoint(changeList)
    log("PandoraSystem.RefreshActRedPoint");
    log_tree("changeList:",changeList);
    QueryActRedPoint(changeList, "RefreshAct");
end

function PandoraSystem.RefreshActBtn()
    log("PandoraSystem.RefreshActBtn");
    if PandoraSystem.RefreshActBtnTimer then
        Timer.RemoveTimer(PandoraSystem.RefreshActBtnTimer);
        PandoraSystem.RefreshActBtnTimer = nil;
    end

    PandoraSystem.RefreshActBtnTimer = Timer.InsertTimer(1,PandoraSystem.OnRefreshActBtnTimer,false);
end

--查询活动显示情况
function PandoraSystem.OnRefreshActBtnTimer()
    log("PandoraSystem.OnRefreshActBtnTimer");
    EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CR);	
end

function PandoraSystem.CheckActIsShowByUrl(actUrl)
    log("PandoraSystem.CheckActIsShowByUrl");
    if actUrl and actUrl ~= "" and JumpUtils.IsPanDoraJumpUrl(actUrl) then
        log("PandoraSystem.CheckActIsShowByUrl actUrl: "..actUrl);
        if not PandoraSystem.CheckSysOpen() then
            return false;
        end

        local actId = PandoraSystem.GetActIdByUrl(actUrl)
        if actId == nil or actId == 0 then
            return false;
        end

        return PandoraSystem.ActIsReady(actId);
    end

    return true;
end

function PandoraSystem.OnPandoraReady(actId, RedMark)
    log("PandoraSystem.OnPandoraReady actId: "..actId.." ,RedMark: "..RedMark);
    PandoraSystem.SetActReady(actId, true);
    PandoraSystem.SetActRedPoint(actId, (RedMark == "1"))

    local act_id = tonumber(actId);
    if act_id == PandoraSystem.Act_Id_Pop then
        PandoraSystem.OnPopReady();
    elseif act_id ==  PandoraSystem.Act_Id_Notice then
        PandoraSystem.OnNoticeReady();
    elseif act_id ==  PandoraSystem.Act_Id_ActivityNavigator then
        PandoraSystem.OnActivityNavigatorReady();
    elseif actId == PandoraSystem.Act_Id_MysteriousShop then
        PandoraSystem.OnActivityMysteriousShopReady()
    else
        -- 查询活动显示情况
        PandoraSystem.RefreshActBtn();
    end
end

function PandoraSystem.OnPandoraEnd(actId)
    log("PandoraSystem.OnPandoraEnd");
    if actId == nil then
        return;
    end
    log("PandoraSystem.OnPandoraEnd actId: "..actId);
    PandoraSystem.SetActReady(actId, false);
    PandoraSystem.SetActRedPoint(actId, false);

    local act_id = tonumber(actId);
    if act_id == PandoraSystem.Act_Id_Pop then
        PandoraSystem.PopStatus = PandoraSystem.PopStatus_End;
        PandoraSystem.OnPopFinish();
    elseif act_id == PandoraSystem.Act_Id_Notice then
    else
        LobbySystem.SetActivityIfShowByModuleId(actId);    
    end
end

--data=
--├─ type: ""
--└─ content: ""
--潘多拉协议回调
function PandoraSystem.OnPandoraCallback(jsonStr)
    log("PandoraSystem.OnPandoraCallback jsonStr: "..jsonStr);

    local data = json.decode (jsonStr);
    if data == nil or data.type == nil then
        log("PandoraSystem.OnPandoraCallback json.decode failed");
        return;
    end
    if data.type == "JumpUrl" then
        log("PandoraSystem JumpUrl "..tostring(data.content).." "..tostring(data.IsLogin));
        PandoraSystem.JumpPandoraUrl(data.content, data.IsLogin);
        if JumpUtils.IsGameJumpUrl(data.content) then
            LuaClassObj.HandleUIMessageNoFetch(bp_activty, "OnCloseBtn");
        end
    elseif data.type == "JumpScene" then
        log("PandoraSystem JumpScene content"..tostring(data.content));
        log("PandoraSystem JumpScene FromScene="..tostring(data.FromScene));
        log("PandoraSystem JumpScene JumpType="..tostring(data.JumpType));

        PandoraSystem.PopJumpScene(data.content,data.JumpType, data.FromScene);
    elseif data.type == "CommonShare" then
        log("PandoraSystem CommonShare");
        PandoraSystem.Share(data.title,data.desc,data.url,data.ShareType);
    elseif data.type == "PicShare" then
        --需要做截屏，然后在界面上显示
        log("PandoraSystem PicShare");
        PandoraShareUI.ShowUI(data);
    elseif data.type == "QueryAct" then
        log("PandoraSystem QueryAct "..tostring(data.content));
        PandoraSystem.OnProcessRtnAct(data.content);
    elseif data.type == "PandoraReady" then
        log("PandoraSystem PandoraReady actid="..tostring(data.actid)..", RedMark="..tostring(data.RedMark));
        PandoraSystem.OnPandoraReady(data.actid, data.RedMark);
    elseif data.type == "PandoraEnd" then
        log("PandoraSystem PandoraEnd actid="..tostring(data.actid));
        PandoraSystem.OnPandoraEnd(data.actid);
    elseif data.type == "CreatePic" then
        log("PandoraSystem CreatePic position="..tostring(data.position));
        local arrPos = string.split(data.position, ",");
        PandoraScreenShot.MakePicture(arrPos[1], arrPos[2], arrPos[3], arrPos[4]);   
    elseif data.type == "RefreshCoin" then
        --购买完成后刷新主界面代币数量
        PandoraSystem.RefreshCoin(data);
    elseif data.type == "ShowItem" then
        --展示获取奖励弹窗
        PandoraSystem.ShowItem(data);
    elseif data.type == "PandoraStoreReady" then
        --告诉游戏把神秘商店页签设定到指定位置   
        log("PandoraSystem PandoraEnd actid="..tostring(data.actid)..", RedMark="..tostring(data.RedMark)..", isShow="..tostring(data.isShow)..", position="..tostring(data.position));
        PandoraSystem.OnPandoraEnd(data.actid);
    elseif data.type == "GetLanguage" then
        --发送当前语言
        EventSendCurrentLanguageToPandora();
    elseif data.type == "BackLobby" then
        LuaClassObj.HandleUIMessage(bp_lobby, "UIShow")
    elseif data.type == "TryOn" then
        PandoraSystem.OnTryOn(data);
    end
end

function PandoraSystem.OnTryOn(data)
    ModelDisplayer.Display(data.itemid, 0, 0);

    --[[if data.itemtype == 1 then 													      -- 武器
        ModelDisplayer.SetShowtype(ModelDisplayer.SHOWTYPE_WEAPON_MODEL)
    elseif data.itemtype == 4 then                                                    -- 服装
        ModelDisplayer.SetShowtype(ModelDisplayer.SHOWTYPE_AVATAR)
    elseif data.itemtype == 8 or data.itemtype == 9 then                              -- 载具
        ModelDisplayer.SetShowtype(ModelDisplayer.SHOWTYPE_MODEL)
    end]]
end

function PandoraSystem.OnAfterUIShow(widget_name)
    if widget_name == nil then
        log("PandoraSystem.OnAfterUIShow widget_name is nil");
        return;
    end
    log("PandoraSystem.OnAfterUIShow "..tostring(widget_name));

    UI_ShowState_List[widget_name] = true;
end

function PandoraSystem.OnAfterUIHide(widget_name)
    if widget_name == nil then
        log("PandoraSystem.OnAfterUIShow widget_name is nil");
        return;
    end
    log("PandoraSystem.OnAfterUIHide "..tostring(widget_name));

    if not UI_ShowState_List[widget_name] then
        return;
    end

    UI_ShowState_List[widget_name] = false;

    local UI_ID_List = Module_UIName_Table[widget_name];
    if nil ~= UI_ID_List  then
        for _, v in ipairs(UI_ID_List) do
            if v == PandoraSystem.PopJumpModuleID then
                PandoraSystem.JumpUIFinish(v);
                break;
            end
        end
    end
end

function PandoraSystem.JumpUIFinish(moduleId)
    log("PandoraSystem.JumpUIFinish "..tostring(moduleId));
    if not PandoraSystem.PopJumping then
        return;
    end

    if moduleId ~= PandoraSystem.PopJumpModuleID then
        return;
    end

    local JumpID = PandoraSystem.PopJumpModuleID
    local JumpType = PandoraSystem.PopJumpType;
    local FromScene = PandoraSystem.PopJumpFromScene;

    PandoraSystem.PopJumpModuleID = 0;
    PandoraSystem.PopJumpType = "";
    PandoraSystem.PopJumpFromScene = "";
    PandoraSystem.PopJumping = false;

    if FromScene == "Pop" then
        if PandoraSystem.PopStatus == PandoraSystem.PopStatus_End then
            -- FaceSlapSystem.OnStepFinished(FaceSlapSystem.Step_Pandora);
            return;
        end

        if JumpType == "Close" then
            log("PandoraSystem.JumpUIFinish Close");
            PandoraSystem.PopStatus = PandoraSystem.PopStatus_End;
            PandoraSystem.OnPopFinish();
            -- FaceSlapSystem.OnStepFinished(FaceSlapSystem.Step_Pandora);
        elseif JumpType == "ShowNext" then
            log("PandoraSystem.JumpUIFinish ShowNext");
            PandoraSystem.PopStatus = PandoraSystem.PopStatus_Pop;
            PandoraSystem.SendShowNextPop();
        elseif JumpType == "ShowCurrent" then
            log("PandoraSystem.JumpUIFinish ShowCurrent");
            PandoraSystem.PopStatus = PandoraSystem.PopStatus_Pop;
            PandoraSystem.SendShowCurrentPop();
        end
    elseif FromScene == "Notice" then
    end
end

function EventOnActivityNavigatorBtnClick()
    log("PandoraSystem.EventOnActivityNavigatorBtnClick");
    local Actid = PandoraSystem.Act_Id_ActivityNavigator;
    SendShow(Actid);
end

function PandoraSystem.RefreshCoin()
    log("PandoraSystem.RefreshCoin")
    --[[if data.imagePath == nil or data.imagePath == "" then
        log("PandoraShareUI.ShowUI imagepath empty.")
        return;
    end--]]
end

function PandoraSystem.ShowItem()
    log("PandoraSystem.ShowItem")
    
end

function EventSendCurrentLanguageToPandora()
    log("PandoraSystem.EventSendCurrentLanguageToPandora");
    local myLanguage = PandoraSystem.GetCurrentLanguage();
    local jsonStr = "{\"type\":\"language\",\"content\":\""..myLanguage.."\"}";
    PandoraSystem.SendCmd(jsonStr);
end

function PandoraSystem.GetCurrentLanguage( )
    local myLanguage = tostring(Client.GetCurrentLanguage());
    if myLanguage == nil then
        myLanguage="en";
    end
    if (myLanguage == "HK")then
        myLanguage = "zh-HK";
    elseif(myLanguage == "TW")then
        myLanguage = "zh-TW";
    end
    return myLanguage;
end

function PandoraSystem.SignOpenidAndLanguage(openid, language)
        local SeasonPrivateKey = "XEPPTNsQV5BAkGDA";
        local paramList = {
            {key = "openid", val = openid},
            {key = "language", val = language}
        };
        
        local signUrl = PandoraSystem.TableToStringParam(paramList, false);
        
        signUrl = string.gsub(signUrl, "&", "", 1);
        log("PandoraSystem signUrl:" .. signUrl);
        local encryptionStr = SeasonPrivateKey .. signUrl .. SeasonPrivateKey;
        --log("PandoraSystem encryptionStr:" .. encryptionStr);
        local sign = Client.MD5HashAnsiString(encryptionStr);
        log("PandoraSystem sign:" .. sign);
        return sign;
end

function PandoraSystem.TableToStringParam(paramList, startWithQuestionMark)
    table.sort(paramList, function(a,b) return a.key < b.key end);
    local param = "";
    local isFirstParam = true;
    local seprate = "";
    for k,v in ipairs(paramList) do
        if startWithQuestionMark and isFirstParam then
            seprate = "?";
            isFirstParam = false;
        else
            seprate = "&";
        end
        param = param .. seprate .. v.key .. "=" .. v.val;   
    end
    return param;
end

--跳转url
--以game://打头，为游戏内跳转，参考格式为game://?module=1000100&{参数1}=1&{参数2}=2
--其他方式，如http://，为网页跳转，参考格式为http://pg.qq.com?{参数1}=1&{参数2}=2
--潘多拉跳转链接pandora://?actid=9010071
function PandoraSystem.JumpPandoraUrl(url, has_token)
    if not PandoraSystem.CheckSysOpen() then
        return;
    end
    log("PandoraSystem.JumpPandoraUrl url = "..url)
    if url == "game://?module=1006004" then
        log("PandoraSystem.JumpPandoraUrl jump to special module")
        local AnniversaryActivitySystem = require("client.slua.logic.lobby_activity.logic_anniversary_activity")
        AnniversaryActivitySystem.get_anniversary_activity_info_req()
        return;
    end
    if JumpUtils.IsGameJumpUrl(url) then
        local params = FuncUtil:ParseURLParams(url);
        local moduleId = tonumber(params["module"]);
        EventSystem:postEvent(EVENTTYPE_URL, moduleId, params);
    elseif JumpUtils.IsPanDoraJumpUrl(url) then
        local params = FuncUtil:ParseURLParams(url);
        EventSystem:postEvent(EVENTTYPE_URL, BP_ENUM_MODULE_PANDORA, params);
    --[[
    elseif string.starts(url, "deeplink") then
        --deeplink配置,前缀替换成http
        local http_link = "http"..(string.sub(url, 9))
        log("http_link ="..http_link)
        --Client.WechatShareDeepLink(NetInterface, http_link)
    ]]
    else
        if string.starts(url, "http") then
            if has_token then
                --url = string.format("%s&access_token=%s", url, accessToken);

                --log("AppendTokenToUrl url = " .. url)
                --local finalEncodeUrl = Client.GetEncodeUrl(url);
                --log("AppendTokenToUrl finalEncodeUrl = " .. finalEncodeUrl)
                --url = string.format( "%s&access_token=%s", finalEncodeUrl, accessToken );

                --需要确认要传那些登录态
                local accessToken = Client.GetToken(NetInterface);
                local openId = tostring(DataMgr.roleData.openID);
                local channel = Client.GetLoginChannel(NetInterface);
                log("PandoraSystem.JumpPandoraUrl channel="..channel);
                local accType = PANDORA_PLAYFORM[channel];
                local myLanguage = PandoraSystem.GetCurrentLanguage();
                --签名（即language和openid的md5值），弱校验
                local sign = PandoraSystem.SignOpenidAndLanguage(openId, myLanguage);
                --玩家的角色id
                local uid = DataMgr.roleData.uid;
                --当前赛季，数据回顾类需求会用到
                local game_season  = UnknowPassSystem.Season;
                -- 游戏区服，比如北美，日韩
                local area = 1;
                -- local cloudTest = tostring(PANDORA_CLOUD_TEST);
                -- if Client.IsCEVersion() then
                --     --体验环境
                -- end
                
                --游戏id，比如1320是全球，1321是日韩
                local gameid = Client.GetITopGameId(NetInterface);
                --即itop_ticket，h5用来强校验登陆态的重要参数，并可以反解出用户openid
                local ticket = Client.GetWebViewTicket(NetInterface);
                --游戏侧内的活动id
                local activity_id = "";
                --用户当前的网络类型：(3G,4G)流量还是wifi;
                --网络类型-int 0 未知; 1 wifi;2 移动网络
                local networkType = 0;
                if Client.HasActiveWifi() then
                    networkType = 1;
                else
                    networkType = 2;
                end
                --用户当前选择的战斗赛区
                local region = LobbySystem.matchZone;


                --{key = "accType", val = accType},
                --{key = "accessToken", val = accessToken},
                local paramList2 = {
                    {key = "openid", val = openId},
                    {key = "language", val = myLanguage},
                    {key = "sign", val = sign},
                    {key = "uid", val = uid},
                    {key = "game_season", val = game_season},
                    {key = "area", val = area},
                    {key = "gameid", val = gameid},
                    {key = "sTicket", val = ticket},
                    {key = "activity_id", val = activity_id},
                    {key = "networkType", val = networkType},
                    {key = "region", val = region}
                };
                local startWithQuestionMark = false;
                if string.find(url, "?") == nil then
                    startWithQuestionMark = true;
                end

                local paramUrl = PandoraSystem.TableToStringParam(paramList2, startWithQuestionMark);
                url = url..paramUrl;
                
                log("AppendTokenToUrl url = " .. url);

            end
            Client.OpenURL(url);
            --GlobalData:JumpUrl(url);
        end
    end
end

function PandoraSystem.EnterBattleGCPandoraUI()
    if not BP_Panduola_Init then
        return;
    end
    local jsonStr = "{\"type\":\"gc\",\"content\":\"pandora\"}";
    PandoraSystem.SendCmd(jsonStr); 
end

---------------------以下为测试代码
function PandoraSystem.PandoraCmdFunc(cmdstring)
    log("PandoraSystem.PandoraCmdFunc cmd: "..cmdstring);
    local cmd = string.lower(cmdstring);

    local CmdJsonString = "";
    if cmd == "pandoraready" then
        --1 显示红点；0 不显示红点
        local HasRedMark = 1;
        --0表示不是拍脸活动，1表示是拍脸活动
        local IsPopPanel = 1;
        CmdJsonString = "{\"type\":\"PandoraReady\",\"RedMark\":\""..HasRedMark.."\",\"actid\":\""..PandoraSystem.Act_Id_ActivityNavigator.."\",\"isPopPanel\":\""..tostring(IsPopPanel).."\"}";
        PandoraSystem.OnPandoraCallback(CmdJsonString);
    elseif cmd == "pandoraend" then
        CmdJsonString = "{\"type\":\"PandoraEnd\",\"actid\":\""..tostring(PandoraSystem.Act_Id_ActivityNavigator).."\"}";
        PandoraSystem.OnPandoraCallback(CmdJsonString);
    elseif cmd == "jumpurl" then
        --指定跳转的URL链接
        local Content = "http://www.qq.com";
        --true/false 是否在URL链接上带上登录态参数
        local IsLogin = "false"
        CmdJsonString = "{\"type\":\"JumpUrl\",\"content\":\""..Content.."\",\"IsLogin\":\""..IsLogin.."\"}";
        PandoraSystem.OnPandoraCallback(CmdJsonString);
    elseif cmd == "jumpscene" then
        local ModuleID = tostring(BP_ENUM_MODULE_MALL);
        CmdJsonString = "{\"type\":\"JumpScene\",\"content\":\"game://?module="..ModuleID.."\"}";
        PandoraSystem.OnPandoraCallback(CmdJsonString);
    elseif cmd == "refreshcoin" then
        CmdJsonString = "{\"type\":\"RefreshCoin\"}";
        PandoraSystem.OnPandoraCallback(CmdJsonString);
    elseif cmd == "showitem" then
        -- content：道具id，多个,隔开
        local Content = "";
        -- type:时限道具与永久道具
        local Type = 1;
        --num：道具数量或者时限（单位秒）
        local num = 1;
        CmdJsonString = "{\"type\":\"ShowItem\",\"content\":\""..Content.."\",\"type\":\""..tostring(Type).."\",\"num\":\""..tostring(num).."\"}";
        PandoraSystem.OnPandoraCallback(CmdJsonString);

        -- TODO 确认item如何获取
        -- CommonItemGetUI:ShowPanel
    elseif cmd == "pandorastoreready" then
        --1 显示红点；0 不显示红点
        local HasRedMark = 1;
        -- 0 隐藏入口 1 展示入口
        local IsShow = 1;
        -- 0顶部位置 1底部位置
        local Position = 1;
        CmdJsonString = "{\"type\":\"PandoraStoreReady\",\"actid\":\""..tostring(PandoraSystem.Act_Id_MysteriousShop).."\",\"RedMark\":\""..tostring(HasRedMark).."\",\"isShow\":\""..tostring(IsShow).."\",\"position\":\""..Position.."\"}";
        PandoraSystem.OnPandoraCallback(CmdJsonString);
    elseif cmd == "picshare" then
        local Content = "1,1,2,4";
        local Source = "";
        local MediaTagName = "MSG_friend_exceed";
        local MessageAction = "WECHAT_SNS_JUMP_APP";
        CmdJsonString = "{\"type\":\"PicShare\",\"content\":\""..Content.."\",\"source\":\""..Source.."\",\"mediaTagName\":\""..MediaTagName.."\",\"messageAction\":\""..MessageAction.."\",\"imagePath\":\"".."../../../ShadowTrackerExtra/Saved/Pandora/HOTUPDATE/1.jpg".."\"}";
        PandoraSystem.OnPandoraCallback(CmdJsonString);
    elseif cmd == "shopready" then
        --1 显示红点；0 不显示红点
        local HasRedMark = 1;
        --0表示不是拍脸活动，1表示是拍脸活动
        local IsPopPanel = 1;
        CmdJsonString = "{\"type\":\"PandoraReady\",\"RedMark\":\""..HasRedMark.."\",\"actid\":\""..PandoraSystem.Act_Id_MysteriousShop.."\",\"isPopPanel\":\""..tostring(IsPopPanel).."\"}";
        PandoraSystem.OnPandoraCallback(CmdJsonString);
    elseif cmd == "shopend" then
        CmdJsonString = "{\"type\":\"PandoraEnd\",\"actid\":\""..tostring(PandoraSystem.Act_Id_MysteriousShop).."\"}";
        PandoraSystem.OnPandoraCallback(CmdJsonString);
    elseif cmd == "shoptryon" then
        local item_type = 9;
        local item_id = 1903018;
        local role_id = 123456;
        CmdJsonString = "{\"type\":\"TryOn\",\"itemtype\":\""..tostring(item_type).."\",\"itemid\":\""..tostring(item_id).."\",\"roleid\":\""..tostring(role_id).."\"}";
        PandoraSystem.OnPandoraCallback(CmdJsonString);

    --以下为游戏发给潘多拉后台
    elseif cmd == "picshareresult" then
        -- 游戏回给潘多拉的消息，返回分享结果
        local Content = "";
        local Source = "";
        CmdJsonString = "{\"type\":\"PicShareResult\",\"content\":\""..Content.."\",\"source\":\""..Source.."\"}";
        PandoraSystem.TestSendCmdToPandora(CmdJsonString);
    elseif cmd == "show" then
        -- 游戏通知潘多拉打开面板       
        local Content = "";
        local Actid = PandoraSystem.Act_Id_ActivityNavigator;
        -- isPopPanel: 0表示不是拍脸活动，1表示是拍脸活动
        local IsPopPanel = 0;
        CmdJsonString = "{\"type\":\"show\",\"content\":\""..Content.."\",\"actid\":\""..tostring(Actid).."\",\"margin\":\""..LobbySystem.uiRect.."\",\"isPopPanel\":\""..tostring(IsPopPanel).."\"}";
        PandoraSystem.TestSendCmdToPandora(CmdJsonString);
    elseif cmd == "shownext" then
        local Content = "";
        local Actid = PandoraSystem.Act_Id_MysteriousShop;
        CmdJsonString = "{\"type\":\"ShowNext\",\"content\":\""..Content.."\",\"actid\":\""..tostring(Actid).."\",\"margin\":\""..LobbySystem.uiRect.."\"}";
        PandoraSystem.TestSendCmdToPandora(CmdJsonString);
        -- SendShowNext(Actid);
    elseif cmd == "showcurrent" then
        local Content = "";
        local Actid = PandoraSystem.Act_Id_MysteriousShop;
        CmdJsonString = "{\"type\":\"ShowCurrent\",\"content\":\""..Content.."\",\"actid\":\""..tostring(Actid).."\",\"margin\":\""..LobbySystem.uiRect.."\"}";
        PandoraSystem.TestSendCmdToPandora(CmdJsonString);
        -- SendShowCurrent(Actid);
    elseif cmd == "hide" then
        local Content = "";
        local Actid = PandoraSystem.Act_Id_MysteriousShop;
        CmdJsonString = "{\"type\":\"hide\",\"content\":\""..Content.."\",\"actid\":\""..tostring(Actid).."\"}";
        PandoraSystem.TestSendCmdToPandora(CmdJsonString);
        -- SendHide(Actid);
    elseif cmd == "commonshare" then
        PandoraSystem.Share("分享测试Title","分享测试Desc","http://www.qq.com","0");
    elseif cmd == "queryact" then
        PandoraSystem.TestSendCmdToPandora(CmdJsonString);
    elseif cmd == "showtestui" then
        PandoraTestUI.Show();
    elseif cmd == "shopshow" then
        -- 游戏通知潘多拉打开面板
        CmdJsonString = "{\"type\":\"shopshow\"}";
        PandoraSystem.TestSendCmdToPandora(CmdJsonString);
    end
end

function PandoraSystem.TestSendCmdToPandora(jsonStr)
    log("PandoraSystem.TestSendCmdTo jsonStr: "..jsonStr);
    local data = json.decode (jsonStr);
    if data == nil then
        log("PandoraSystem.TestSendCmdTo json.decode failed");
        return;
    end 

    if data.type == "picshareresult" then 
    elseif data.type == "show" then
        PandoraSystem.SendShow(PandoraSystem.Act_Id_ActivityNavigator);
    elseif data.type == "shownext" then
    elseif data.type == "showcurrent" then
    elseif data.type == "hide" then
    elseif data.type == "queryact" then
    elseif data.type == "shopshow" then
        EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN)
        ModelDisplayer.Init()
        LobbyCameraManager.SwitchCamera(10112)
        LobbySceneManager.ChangeMallSceneTexture(StoreMainUI.defaultTexture)
        PandoraSystem.SendShow(PandoraSystem.Act_Id_MysteriousShop);
    else
    end
    
end