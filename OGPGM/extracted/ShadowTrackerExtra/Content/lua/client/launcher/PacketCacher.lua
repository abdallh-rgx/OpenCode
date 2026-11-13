-- -- add by Ant/hy 20181020
-- -- For moni server

-- PacketCacher = class("PacketCacher")
-- PacketCacher.__instance = nil

-- function PacketCacher.getInstance()
--     if PacketCacher.__instance == nil then
--         PacketCacher.__instance = PacketCacher.new()
--     end

--     return PacketCacher.__instance
-- end

-- function PacketCacher:ctor()
--     self:reset()
-- end

-- function PacketCacher:reset()
--     self._packetCache = {}
--     self._cacheData = {}

--     self:regist("league_battle_history_req", "league_battle_history_rsp", 300, function(errcode, records)
--         if errcode == 505034 then
--             return 1
--         end

--         return 300
--     end)

--     -- self:regist("carteam_coin_exchange_list_req", "carteam_coin_exchange_list_rsp", 5)
-- end
-- --[[
--     cdFilter: 
--         params: server respone paramsre
--         return: cdTime

--     sendFilter:
--         params: server request paramsre
--         return: uniKey

--     callbackFilter:
--         params: server respone paramsre
--         return: uniKey

--     cacheFilter:
--         params: cache server respone paramsre
--         return: new cache server respone
-- ]]
-- function PacketCacher:regist(sendKey, callbackKey, cdTime, cdFilter, sendFilter, callbackFilter, cacheFilter)
--     local cacheData = self._cacheData[sendKey]

--     if cacheData == nil then
--         cacheData = {}
--         self._cacheData[sendKey] = cacheData
--     end

--     cacheData.sendKey = sendKey
--     cacheData.cdTime = cdTime
--     cacheData.lastTime = 0

--     cacheData.callbackKey = callbackKey
--     cacheData.callbackData = {}

--     cacheData.cdFilter = cdFilter
--     cacheData.sendFilter = sendFilter
--     cacheData.callbackFilter = callbackFilter

--     log_tree("PacketCacher regist self._cacheData",self._cacheData, PacketCacher.__cname)
-- end

-- function PacketCacher:storeServerPacket(callbackkey, ...)
--     for sendKey, data in pairs(self._cacheData) do
--         if data.callbackKey == callbackkey then
--             -- log_tree("PacketCacher storeServerPacket self._cacheData", self._cacheData, PacketCacher.__cname)
--             -- log("PacketCacher storeServerPacket "..callbackkey, PacketCacher.__cname)
            
--             -- data.callbackData = {...}
--             data.lastTime = os.time()

--             if data.cdFilter ~= nil then
--                 data.cdTime = data.cdFilter(...)
--                 -- log("PacketCacher storeServerPacket data.cdTime "..data.cdTime, PacketCacher.__cname)
--             end

--             local key = ""
--             if data.callbackFilter ~= nil then
--                 key = data.callbackFilter(...)
--             end

--             if data.cacheFilter ~= nil then
--                 data.callbackData[key] = {data.cacheFilter(...)}
--             else
--                 data.callbackData[key] = {...}
--             end
            
--             break
--         end
--     end
-- end

-- function PacketCacher:moniCall( ... )
--     local arg = {...}
--     local sendKey = arg[1]
--     local cacheData = self._cacheData[sendKey]
--     if cacheData == nil then
--         return false
--     end

--     if os.time() - cacheData.lastTime > cacheData.cdTime then
--         return false
--     end

--     local key = ""
--     if cacheData.sendFilter ~= nil then
--         key = cacheData.sendFilter(...)
--     end

--     if cacheData.callbackData[key] == nil then
--         return false
--     end

--     log("PacketCacher moniCall "..cacheData.callbackKey, PacketCacher.__cname)
--     s2c[cacheData.callbackKey](table.unpack(cacheData.callbackData[key]))
--     return true
-- end
