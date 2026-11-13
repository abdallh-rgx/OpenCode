local M = {}
local event_config = require("client.slua.config.event")

function M.Init()
    require("client.common.event.event_system")
    for _, config in pairs(event_config) do
        local FuncWrap = function (eventType, eventID, ...)
            local m = require(config.moduleName)
            local func = m[config.funcName]
            func(eventType, eventID, ...)
        end
        EventSystem:registEvent(config.eventType, config.eventID, FuncWrap)
    end
end

return M