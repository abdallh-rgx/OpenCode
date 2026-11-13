local ActorVoiceSystem = ActorVoiceSystem or {}

local VOICE_FRACTION = 100000
local isInited = false;

local newActorID = 0; --新获取的声优ID

--已拥有的声优列表
local ownActorList =
{
	--ActorID = 0;
};

--可显示的声优信息列表
local actorVoiceInfoList =
{
--[[{
		BankName = "",
		ActorName = "",
		ActorItemID = 0,
		IsShow = 0,
		ActorID = 0,
		SortKey = 0,
		IsUnLock = 0,
	}]]
};

--声优列表
local actorList =
{
	--ActorID = 0;
};

--玩家自定义列表
local selectedVoiceList =
{
	--Key = 0;
};

--玩家自定义轮盘列表
local selectedWheelVoiceList =
{
	--Key = 0;
};

local ownActorVoiceList =
{
	--Key = 0,
    --IsNew = false,
}

--语音包ID列表
--[[
[ActorID][VoiceType] = {key, ...}
]]
local actorVoiceIDList = {};

--正在播放的声音ID
local voiceSoundID = 0

--物品到声优的映射
local ItemToActorID = {}

--初始化事件
function ActorVoiceSystem.InitActorVoiceInfo()

	if isInited == false then
        ActorVoiceSystem.InitActorInfoFromTable()
        ActorVoiceSystem.InitVoiceIDInfoFromTable()
		ActorVoiceSystem.InitSelectListFromConfig()
		isInited = true
	end
	ActorVoiceSystem.GetActorVoiceInfoReq()
end

function ActorVoiceSystem.InitSelectListFromConfig()
	selectedVoiceList = {};
	selectedWheelVoiceList = {};
	slua_GameFrontendHUD:BeginModifyUserSettings()
	local settingConfig = slua_GameFrontendHUD:GetUserSettings()

	for i = 0, settingConfig.PlayerChatQuickTextIDList:Num() - 1 do
		table.insert(selectedVoiceList, settingConfig.PlayerChatQuickTextIDList:Get(i))
	end
	for i = 0, settingConfig.PlayerWheelChatQuickTextIDList:Num() - 1 do
		table.insert(selectedWheelVoiceList, settingConfig.PlayerWheelChatQuickTextIDList:Get(i))
	end
end

-- 重新登陆后清空数据
function ActorVoiceSystem.ResetVoiceData()
	log("ActorVoiceSystem.ResetVoiceData")
	--fix bug ID72062769
    --切换语言回到登陆界面，isInited没有清空，导致语音包名称刷新不及时
	isInited = false
end
--请求语音包数据
function  ActorVoiceSystem.GetActorVoiceInfoReq()
	log("ActorVoiceSystem.GetActorVoiceInfoReq")
	NetUtil.SendPriorityPkg(false, "get_voice_msg_info_rsp", "get_voice_msg_info_req")
end

--请求语音包数据回包
function ActorVoiceSystem.GetActorVoiceInfoRes(res)
	log_tree("ActorVoiceSystem.GetActorVoiceInfoRes : ", res)

	--语音包权限
	if res.dubber ~= nil then
		ActorVoiceSystem.VoiceActorChangedNotify(res.dubber)
	end

	if res.is_need_report == true then
		log("ActorVoiceSystem.GetActorVoiceInfoRes Need Report");
		ActorVoiceSystem.UploadPlayerQuickMsgList()
		return
	end

	--已选择的消息列表
	if res.msgs ~= nil then
		selectedVoiceList={};
		--先铺上0
		for i = 1,20 do
			table.insert(selectedVoiceList,0);
		end
		for i,j in pairs(res.msgs) do
			selectedVoiceList[j] = i;
		end
	end
	
	--已选择的轮盘列表，由于服务器为了索引，存储结构为[id] - [index]，接受时需要进行转换
	if res.rotary_table ~= nil then
		selectedWheelVoiceList = {};
		--先铺上0
		for i = 1,8 do
			table.insert(selectedWheelVoiceList,0);
		end
		for id,index in pairs(res.rotary_table) do
			selectedWheelVoiceList[index] = id;
		end
	end

	--已拥有的语音列表
	if res.own_msgs ~= nil then
        for key, _ in pairs(res.own_msgs) do
            ownActorVoiceList[key] = {Key = key, IsNew = false}
        end
	end
end

--上报玩家自定义语音列表
function ActorVoiceSystem.UploadPlayerQuickMsgList()

	ActorVoiceSystem.InitSelectListFromConfig()
	log_tree("ActorVoiceSystem.UploadPlayerQuickMsgList selectedVoiceList",selectedVoiceList)
	log_tree("ActorVoiceSystem.UploadPlayerQuickMsgList selectedWheelVoiceList",selectedWheelVoiceList)
	
	if #selectedVoiceList > 0 or #selectedWheelVoiceList > 0 then
		NetUtil.SendPkg("update_voice_msgs_req", selectedVoiceList ,selectedWheelVoiceList);
	end
end

--上报玩家试听语音事件
function ActorVoiceSystem.UpdatePlayerListenVoiceEvent(id)
	log("ActorVoiceSystem.UpdatePlayerListenVoiceEvent id:".. id);
	NetUtil.SendPkg("voice_msg_audition_req",id);
end

--刷新权限列表
function ActorVoiceSystem.RefreshActorOwnerList(list)
	local temp = {}
	for _, actorID in pairs(list) do
		log("ActorVoiceSystem.RefreshActorOwnerList v = " .. tostring(actorID));
		table.insert(temp, actorID)
	end
	ownActorList = temp
end

--初始化声优表信息
function ActorVoiceSystem.InitActorInfoFromTable()

	log("ActorVoiceSystem.InitActorInfoFromTable");

	local actorTable = Client.GetTable("VoiceActorCfg")
	local tempActor = {}
	local tempActorInfo = {}
	local strRegion = Client.GetPublishRegion();

	log("ActorVoiceSystem.InitActorInfoFromTable ip_Region :" .. LoginSystem.ip_region);
	for k,v in pairs(actorTable) do
		log_tree("actorTable", actorTable)
		local tempIsShow = 0
		if strRegion == "JAPAN" or strRegion == "KOREA" then
			if LoginSystem.ip_region == "JP" then
				tempIsShow = v.IsShowJP
			elseif LoginSystem.ip_region == "KR" then
				tempIsShow = v.IsShowKR
			else
				tempIsShow = v.IsShowOther
			end
		else
			tempIsShow = v.IsShow
		end
		--table.insert(tempActorInfo, {data = v, isShow = tempIsShow})
		table.insert(tempActorInfo,
				{
					ActorName = v.ActorName,
					BankName = v.BankName,
					ActorID = v.ActorID,
					ActorItemID = v.ActorItemID,
					IsShow = tempIsShow,
					SortKey = v.SortKey,
					IsUnLock = v.IsUnLock
				}
		)

		ItemToActorID[v.ActorItemID] = v.ActorID
	end


	table.sort(tempActorInfo,function(a,b)
		return a.SortKey < b.SortKey
	end)

	actorVoiceInfoList = {}
	for k,v in pairs(tempActorInfo) do
		if v.IsShow == 1 then
			table.insert(actorVoiceInfoList, v)
			table.insert(tempActor,v.ActorID)
		end
	end


	--BP_ARRAY_ActorVoiceInfoList = tempActorInfo
	log_tree("BP_ARRAY_ActorVoiceInfoList", actorVoiceInfoList);

	actorList = tempActor
	log_tree("BP_ARRAY_ActorList", actorList);
end

--初始化语音包ID表信息
function ActorVoiceSystem.InitVoiceIDInfoFromTable()
	local voiceTable = Client.GetTable("VoiceIDCfg")
	local temp = {}
	for k,v in pairs(voiceTable) do
		if temp[v.ActorID] == nil then
			temp[v.ActorID] = {}
		end
		if temp[v.ActorID][v.VoiceType] == nil then
			temp[v.ActorID][v.VoiceType] = {}
		end
		table.insert(temp[v.ActorID][v.VoiceType],v.Key)
	end

	for k,v in pairs(temp) do
		for kt,vt in pairs(temp[k]) do
			table.sort(vt,function(a,b)
				return a < b
			end)
		end
	end
	actorVoiceIDList = temp;
	--log_tree("ActorVoiceSystem.ActorVoiceIDList",ActorVoiceSystem.ActorVoiceIDList);
end

function ActorVoiceSystem.GetActorIDByKey(key)
    local actorID = key // VOICE_FRACTION
    return actorID
end

function ActorVoiceSystem.GetMessageIDByKey(key)
	local math = require("math")
	local msgID = math.fmod(key, VOICE_FRACTION)
	return msgID
end

function ActorVoiceSystem.PlaySound(key, worldContextObject)
	local actorID = ActorVoiceSystem.GetActorIDByKey(key)
	local msgID = ActorVoiceSystem.GetMessageIDByKey(key)

	local path = string.format("/Game/WwiseEvent/Voice_Battle/Play_chat_%d.Play_chat_%d", msgID, msgID)
	local util = require("ui.util")

	ActorVoiceSystem.StopSound()

	local voiceActorData = Client.GetTableData("VoiceActorCfg", actorID)
	voiceSoundID = util.PlaySound(path, "", "Character", voiceActorData.BankName, worldContextObject)
end

function ActorVoiceSystem.StopSound()
	local util = require("ui.util")
	util.StopSound(voiceSoundID)
	voiceSoundID = 0
end

local function UpdateRedPoint()
    WardrobeUI:UpdatePanelRedPoint(true, BP_ENUM_WardrobePageType_Parachute, WardrobeUI.wardrobeTabType_quickmessage)
end

function ActorVoiceSystem.FirstGetActor(ActorID)
	log("ActorVoiceSystem.FirstGetActor :".. ActorID)
	newActorID = ActorID;
    if newActorID ~= 0 then
        UpdateRedPoint()
    end
end

function ActorVoiceSystem.SetNewActorID(id)
	newActorID = id
end

function ActorVoiceSystem.GetNewActorID()
	return newActorID
end

function ActorVoiceSystem.GetOwnActorVoiceList()
	return ownActorVoiceList
end

function ActorVoiceSystem.GetActorVoiceInfoList(index)
	return actorVoiceInfoList[index]
end

function ActorVoiceSystem.GetActorList()
	return actorList
end

function ActorVoiceSystem.GetOwnActorListByIndex(index)
	return ownActorList[index]
end

function ActorVoiceSystem.GetSelectedActorList()
	return selectedVoiceList
end

function ActorVoiceSystem.GetSelectedWheelActorList()
	return selectedWheelVoiceList
end

function ActorVoiceSystem.GetActorName(ActorID)
    for i, actorVoice in pairs(actorVoiceInfoList) do
        if ActorID == actorVoice.ActorID then
            return actorVoice.ActorName
        end
    end
    return nil
end

function ActorVoiceSystem.CheckIsActorValid(ActorID)
    for i, v in pairs(actorVoiceInfoList) do
        if v.ActorID == ActorID then
			if v.IsUnLock == 1 then
				return true
			end
        end
    end

    for _, v in pairs(ownActorList) do
        if v == ActorID then
            return true
        end
    end
    return false
end

function ActorVoiceSystem.CheckIsActorValidByItemID(itemID)
	local actorID = ItemToActorID[itemID]
	if actorID then
		return ActorVoiceSystem.CheckIsActorValid(actorID)
	end

	return false
end

function ActorVoiceSystem.GetActorVoiceIDList()
	return actorVoiceIDList
end

function ActorVoiceSystem.GetVoiceListByActorIDAndType(actorID, selectType)
	if actorVoiceIDList[actorID] then
		return actorVoiceIDList[actorID][selectType]
	end
end

function ActorVoiceSystem.CheckIsVoiceUnLock(key)
    local actorID = key // VOICE_FRACTION
	if ActorVoiceSystem.CheckIsActorValid(actorID) then
		return true
	end

	return ownActorVoiceList[key]
end

function ActorVoiceSystem.CheckIsVoiceNew(key)
    if ownActorVoiceList[key] then
        return ownActorVoiceList[key].IsNew
    end

    return false
end

function ActorVoiceSystem.ReadVoice(key)
    if ownActorVoiceList[key] then
        ownActorVoiceList[key].IsNew = false
    end
end

function ActorVoiceSystem.VoiceActorChangedNotify(dubber)
	log_tree("ActorVoiceSystem.VoiceActorChangedNotify:", dubber)
    ActorVoiceSystem.RefreshActorOwnerList(dubber)

    require("client.common.event.event_system")
    EventSystem:postEvent(EVENTTYPE_ACTOR_VOICE, EVENTID_ACTOR_VOICE_ACTOR_CHANGE)

    --UpdateRedPoint()
end

function ActorVoiceSystem.VoiceChangedNotify(own_msgs)
	log_tree("ActorVoiceSystem.VoiceChangedNotify", own_msgs)

    for key, _ in pairs(own_msgs) do
		if not ownActorVoiceList[key] then
			ownActorVoiceList[key] = {Key = key, IsNew = true}
		end
    end

    require("client.common.event.event_system")
    EventSystem:postEvent(EVENTTYPE_ACTOR_VOICE, EVENTID_ACTOR_VOICE_OWN_MESSAGE_CHANGAE)

    UpdateRedPoint()
end

function ActorVoiceSystem.VoiceDecomposeNotify(resId, items)
	print("ActorVoiceSystem.VoiceDecomposeNotify:", resId)
	log_tree("", items)
end

return ActorVoiceSystem