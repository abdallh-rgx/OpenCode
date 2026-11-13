local function Init()
    local regist_net_routes = require("client.slua.regist_net_routes")
    regist_net_routes.Init()

    local regist_events = require("client.slua.regist_events")
    regist_events.Init()
end

Init()