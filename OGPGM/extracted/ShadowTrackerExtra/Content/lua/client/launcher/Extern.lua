-- Add by Ant/hy . 2018.10.25
function clone(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for key, value in pairs(object) do
            new_table[_copy(key)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

-- Add by Ant/hy . 2018.10.20
-- For Lua OOP 
function LuaClass(classname, super)
    local superType = type(super)

    --print("the classname is "..classname)
    --print("the type(super) is "..type(super))
    local cls

    if superType ~= "function" and superType ~= "table" then
        superType = nil
        super = nil
    end

    if superType == "function" or (super and super.__ctype == 1) then
        -- inherited from native C++ Object
        cls = {}

        if superType == "table" then
            -- copy fields from super
            for k,v in pairs(super) do cls[k] = v end
            cls.__create = super.__create
            cls.super    = super
        else
            cls.__create = super
        end

        cls.ctor    = function() end
        cls.__cname = classname
        cls.__ctype = 1

        function cls.new(...)
            local instance = cls.__create(...)
            -- copy fields from class to native object
            for k,v in pairs(cls) do instance[k] = v end
            instance.class = cls
            instance:ctor(...)
            return instance
        end

    else
        -- inherited from Lua Object
        if super then
            cls = clone(super)
            cls.super = super
        else
            cls = {ctor = function() end}
        end

        cls.__cname = classname
        cls.__ctype = 2 -- lua
        cls.__index = cls

        function cls.new(...)
            local instance = setmetatable({}, cls)
            instance.class = cls
            instance:ctor(...)
            return instance
        end
    end

    return cls
end

--[[
	editor: 
		huang yi
	data: 
		20150629
	desc:

	Useage:
		-----add component-----
		local TestManager = class("TestManager",BaseManager)
		TestManager.EVENT_TEST="EVENT_TEST"

		function TestManager:ctor(id)
			EventCenter.extend(self)
		end

		function TestManager:dispath()
			self:dispathEvent(TestManager.EVENT_TEST,{abc="1"})
		end
		-----------------------------------

		-----use event-----
	    local tMgr=GameApp:getManager("TestManager")
	    tMgr:addEventListener(tMgr.EVENT_TEST,function(data)
	        GameApp:log("test Event",data)
	    end)

	    GameApp:log("tMgr:getTestData()",tMgr:getTestData())
	    tMgr:removeAllEventListener()
		-----------------------------------

		-----method-----
		addEventListener(key,handler)
		dispathEvent(key[,{}])

		removeAllEventListener([name])
		removeEventListener(handler)
		-----------------------------------
]]
EventCenter = LuaClass("EventCenter")

function EventCenter.extend(target)
	if target.__eventHandler then
		--GameApp:log("Error,__eventHandler already exists.")
		return
	end

	target.__eventHandler={}

	target.addEventListener=function(targetObj,eventName,handler)
		local handlerList=targetObj.__eventHandler[eventName]
		targetObj.__eventHandler[eventName]=handlerList or {}
		handlerList=targetObj.__eventHandler[eventName]

		handlerList[#handlerList+1]=handler
	end

	target.dispathEvent=function(targetObj,eventName,data)
		local handlerList=targetObj.__eventHandler[eventName]
		if handlerList==nil then 
			-- GameApp:log("There is not ",eventName,"event.")
			return 
		end

		for i,handler in ipairs(handlerList) do
			handler(data)
		end
	end

	target.removeAllEventListener=function(targetObj,name)
		if name then
			targetObj.__eventHandler[name]={}
			return
		end

		targetObj.__eventHandler={}
	end

	target.removeEventListener=function(targetObj,handler)
		local handlerList=targetObj.__eventHandler

		local tmpHandlers={}
		for name,handlers in pairs(handlerList) do
			tmpHandlers={}

			for i,curHandler in ipairs(handlers) do
				if curHandler~=handler then
					table.insert(tmpHandlers,curHandler)
				end
			end
			handlerList[name]=tmpHandlers
		end
	end
end

StatusManagerBase = LuaClass("StatusManagerBase")

-- add by ant/hy 2018.10.23
StatusManager = LuaClass("StatusManager", StatusManagerBase)

StatusManager.EVENT_ON_NOTIFY_STATUS_CHANGED = "EVENT_ON_NOTIFY_STATUS_CHANGED"

StatusManager.KEY_SERVER_NOTIFY = "KEY_SERVER_NOTIFY"

StatusManager.KEY_CORPS_PANEL = "KEY_CORPS_PANEL"

StatusManager.KEY_CORPS_TEAMUP = "KEY_CORPS_TEAMUP"
StatusManager.KEY_RECENT_TEAMUP = "KEY_RECENT_TEAMUP"

function StatusManager.getInstance()
    if StatusManager.__instance == nil then
        StatusManager.__instance = StatusManager.new()
    end

    return StatusManager.__instance
end

function StatusManager:ctor()
    StatusManager.super.ctor(self)
    EventCenter.extend(self)
    
    self._checkBlockTime = 15
    self._checkTimer = nil

    self:reset()

    -- self:addEventListener(StatusManager.EVENT_ON_NOTIFY_STATUS_CHANGED, TeamUPFriendUI.OnStatusChanged)
    self:addEventListener(StatusManager.EVENT_ON_NOTIFY_STATUS_CHANGED, CorpsMemberSystem.OnStatusChanged)
end

function StatusManager:reset()
    self._requestPacket = nil

    self._requestQueue = {}
    self._statusCache = {}

    self._corpsLastTime = 0
    self:_setWaiting(false)
end

function StatusManager:request(idList, key, isForce)
    key = key or ""

    local tmpList = {}
    for _, id in ipairs(idList) do
        table.insert(tmpList, tonumber(id))
    end

    self:_enqueue(tmpList, key, isForce)

    if self._isWaiting == true then
        log("StatusManager:request is waiting", StatusManager.__cname)
        return
    end

    self:_setWaiting(true)
    self:_processQueue()
end

function StatusManager:setOnline(uid, isOnline)
    uid = tonumber(uid)

    if isOnline == false then isOnline = 0 end
    if isOnline == true then isOnline = 1 end

    if self:_hasCache(uid) == false then
        self._statusCache[uid] = {}
    end
    self._statusCache[uid].online = isOnline

    -- if self._statusCache[uid].teamState == nil then
    --     self:request({uid}, StatusManager.KEY_SERVER_NOTIFY)
    --     return
    -- end
    
    local packet = {}
    packet.idList = {uid}
    packet.key = StatusManager.KEY_SERVER_NOTIFY

    self:dispathEvent(StatusManager.EVENT_ON_NOTIFY_STATUS_CHANGED, packet)
end

function StatusManager:setGroupStatus(uid, status)
    uid = tonumber(uid)

    if self:_hasCache(uid) == false then
        self._statusCache[uid] = {}
    end

    local myStatus = self._statusCache[uid]
    for key, value in pairs(status) do
        myStatus[key] = value
    end

    myStatus.timeSinceGameBeginStamp = os.time() - myStatus.timeSinceGameBegin
    -- if myStatus.online == nil then
    --     self:request({uid}, StatusManager.KEY_SERVER_NOTIFY)
    --     return
    -- end

    local packet = {}
    packet.idList = {uid}
    packet.key = StatusManager.KEY_SERVER_NOTIFY

    self:dispathEvent(StatusManager.EVENT_ON_NOTIFY_STATUS_CHANGED, packet)
end

function StatusManager:getStatus(uid)
    uid = tonumber(uid)
    
    return self._statusCache[uid]
end

function StatusManager:_startCheckBlockTimer()
    self:_stopCheckBlockTimer()

    self._checkTimer = Timer.InsertTimer(self._checkBlockTime, function()
        log("StatusManager respone time out", StatusManager.__cname)
        self:_stopCheckBlockTimer()
        self:_processQueue()
    end, false, false)
end

function StatusManager:_stopCheckBlockTimer()
    if self._checkTimer ~= nil then
        Timer.RemoveTimer(self._checkTimer)
        self._checkTimer = nil
    end
end

function StatusManager:_processQueue()
    log("StatusManager:_processQueue ", StatusManager.__cname)

    local packet = self:_dequeue()
    if packet == nil then
        self:_setWaiting(false)
        self:_stopCheckBlockTimer()
        log("StatusManager:_processQueue self._requestQueue is empty.",StatusManager.__cname)
        return
    end

    -- log_tree("StatusManager:processServerData current cache is ", self._statusCache, StatusManager.__cname)
    self._requestPacket = packet

    -- process for corps
    if packet.key == StatusManager.KEY_CORPS_PANEL
    or packet.key == StatusManager.KEY_CORPS_TEAMUP
    then
        log("StatusManager:_processQueue request for corps ,lastTime "..self._corpsLastTime, StatusManager.__cname)
        NetUtil.SendPkg("get_corps_member_online_info_req", self._corpsLastTime)
        self:_startCheckBlockTimer()
        return
    end

    local tmpIds = {}
    for _, id in ipairs(packet.idList) do
        if packet.isForce == true then
            table.insert(tmpIds, id)
        else
            if self:_hasCache(id) == false then
                table.insert(tmpIds, id)
            end
        end
    end

    if #tmpIds == 0 then
        self:dispathEvent(StatusManager.EVENT_ON_NOTIFY_STATUS_CHANGED, self._requestPacket)
        self:_processQueue()
        return
    end

    log_tree("StatusManager:_processQueue request", tmpIds, StatusManager.__cname)
    NetUtil.SendPkg("batch_get_group_and_online_req", StatusManager.__cname, tmpIds)
    self:_startCheckBlockTimer()
end

function StatusManager:processServerData(listType, res, cacheData)
    if listType ~= StatusManager.__cname then
        return
    end

    log("StatusManager:processServerData res is "..res, StatusManager.__cname)

    if res ~= "ok" then
        log("StatusManager:processServerData failure", StatusManager.__cname)
        self:_processQueue()
        return
    end
    
    if cacheData == nil then
        log("processServerData server rsp cache is nil", StatusManager.__cname)
        self:_processQueue()
        return
    end

    --log_tree("StatusManager:processServerData server rsp cache is ", cacheData, StatusManager.__cname)

    for uid, status in pairs(cacheData) do
        uid = tonumber(uid)

        if self:_hasCache(uid) == false then
            self._statusCache[uid] = {}
        end
    
        local myStatus = self._statusCache[uid]
        for key, value in pairs(status) do
            if key == "online" then
                if value == false then value = 0 end
                if value == true then value = 1 end
            end
            myStatus[key] = value
        end

        myStatus.timeSinceGameBeginStamp = os.time() - myStatus.timeSinceGameBegin
    end

    -- log_tree("StatusManager:processServerData server rsp cache isssss ", self._statusCache, "corps")

    self:dispathEvent(StatusManager.EVENT_ON_NOTIFY_STATUS_CHANGED, self._requestPacket)
    self:_processQueue()
end

function StatusManager:processServerDataForCorps(lastTime, cacheData)
    self._corpsLastTime = lastTime

    -- for k,v in pairs(cacheData) do
    --     v.timeSinceGameBeginStamp = os.time() - v.timeSinceGameBegin
    -- end

    self:processServerData(StatusManager.__cname, "ok", cacheData)
end

function StatusManager:_setWaiting(isWaiting)
    log("StatusManager _setWaiting "..tostring(isWaiting), StatusManager.__cname)
    self._isWaiting = isWaiting
end

function StatusManager:_hasCache(id)
    return self._statusCache[id] ~= nil
end

function StatusManager:_enqueue(idList, key, isForce)
    local packet = {}
    packet.idList = idList
    packet.key = key
    packet.isForce = isForce
    table.insert(self._requestQueue, packet)
end

function StatusManager:_dequeue()
    if #self._requestQueue == 0 then
        return nil
    end

    local result = self._requestQueue[1]
    table.remove(self._requestQueue, 1)

    return result
end

function StatusManager.__onNotifyOnline(uid, isOnline)
    log("__onNotifyStatus","StatusManager")

    FriendSystem.on_notify_online_status_chg(uid, isOnline)
    StatusManager.getInstance():setOnline(uid, isOnline)
end

function StatusManager.__onNotifyGroupStatus(uid, status)
    log("__onNotifyGroupStatus","StatusManager")

    FriendSystem.on_notify_group_status_chg(uid, status)
    StatusManager.getInstance():setGroupStatus(uid, status)
end

function StatusManager.__onCorpsStatusRsp(ret, lastTime, cache)
    log("StatusManager __onCorpsStatusRsp ret "..tostring(ret), StatusManager.__cname)
    if ret ~= 0 then
        return
    end
    log("StatusManager __onCorpsStatusRsp lastTime "..tostring(lastTime), StatusManager.__cname)
    --log_tree("StatusManager __onCorpsStatusRsp cache ", cache, "corps")
    StatusManager.getInstance():processServerDataForCorps(lastTime, cache)
end

s2c["notify_online_status_chg"] = StatusManager.__onNotifyOnline
s2c["notify_group_status_chg"] = StatusManager.__onNotifyGroupStatus
s2c["get_corps_member_online_info_rsp"] = StatusManager.__onCorpsStatusRsp

-- add by Ant/hy 20181020
-- For moni server

PacketCacher = LuaClass("PacketCacher")
PacketCacher.__instance = nil

function PacketCacher.getInstance()
    if PacketCacher.__instance == nil then
        PacketCacher.__instance = PacketCacher.new()
    end

    return PacketCacher.__instance
end

function PacketCacher:ctor()
    self:reset()
end

function PacketCacher:reset()
    self._packetCache = {}
    self._cacheData = {}

    self:regist("league_battle_history_req", "league_battle_history_rsp", 300, function(errcode, records)
        if errcode == 505034 then
            return 1
        end

        return 300
    end)

    self:regist("igame_market_get_all_sell_item_page_info", "igame_market_get_all_sell_item_page_info_rsp", 300)
    
    -- self:regist("carteam_coin_exchange_list_req", "carteam_coin_exchange_list_rsp", 100,nil,nil,nil,nil,function(...)return 10 end )
end
--[[
    cdFilter: 
        params: server respone paramsre
        return: cdTime

    sendFilter:
        params: server request paramsre
        return: uniKey

    callbackFilter:
        params: server respone paramsre
        return: uniKey

    cacheFilter:
        params: cache server respone paramsre
        return: new cache server respone
]]
function PacketCacher:regist(sendKey, callbackKey, cdTime, cdFilter, sendFilter, callbackFilter, cacheFilter, delayFilter)
    local cacheData = self._cacheData[sendKey]

    if cacheData == nil then
        cacheData = {}
        self._cacheData[sendKey] = cacheData
    end

    cacheData.sendKey = sendKey
    cacheData.cdTime = cdTime
    cacheData.lastTime = 0

    cacheData.callbackKey = callbackKey
    cacheData.callbackData = {}

    cacheData.cdFilter = cdFilter
    cacheData.sendFilter = sendFilter
    cacheData.callbackFilter = callbackFilter
    cacheData.delayFilter = delayFilter

    log_tree("PacketCacher regist self._cacheData",self._cacheData, PacketCacher.__cname)
end

function PacketCacher:storeServerPacket(callbackkey, ...)
    for sendKey, data in pairs(self._cacheData) do
        if data.callbackKey == callbackkey then
            -- log_tree("PacketCacher storeServerPacket self._cacheData", self._cacheData, PacketCacher.__cname)
            -- log("PacketCacher storeServerPacket "..callbackkey, PacketCacher.__cname)
            
            -- data.callbackData = {...}
            data.lastTime = os.time()

            if data.cdFilter ~= nil then
                data.cdTime = data.cdFilter(...)
                -- log("PacketCacher storeServerPacket data.cdTime "..data.cdTime, PacketCacher.__cname)
            end

            local key = ""
            if data.callbackFilter ~= nil then
                key = data.callbackFilter(...)
            end

            if data.cacheFilter ~= nil then
                data.callbackData[key] = {data.cacheFilter(...)}
            else
                data.callbackData[key] = {...}
            end
            
            break
        end
    end
end

function PacketCacher:moniCall( ... )
    local arg = {...}
    local sendKey = arg[1]
    local cacheData = self._cacheData[sendKey]
    if cacheData == nil then
        return false
    end

    if os.time() - cacheData.lastTime > cacheData.cdTime then
        return false
    end

    local key = ""
    if cacheData.sendFilter ~= nil then
        key = cacheData.sendFilter(...)
    end

    if cacheData.callbackData[key] == nil then
        return false
    end

    local delay = 0.1
    if cacheData.delayFilter ~=nil then
        delay = cacheData.delayFilter(...)
        if delay < 0.1 then 
            delay = 0.1
        end
    end

    Timer.InsertTimer(delay, function()
        log("PacketCacher moniCall "..cacheData.callbackKey, PacketCacher.__cname)
        s2c[cacheData.callbackKey](table.unpack(cacheData.callbackData[key]))
    end, false, false)

    return true
end
