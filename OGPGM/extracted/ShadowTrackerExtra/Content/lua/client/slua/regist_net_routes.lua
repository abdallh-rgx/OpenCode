local M = {}
local net_route = require("client.slua.config.net_route")

function M.Init()
    for _, routeConfig in pairs(net_route) do
        local moduleName = routeConfig.moduleName
        for name, funcName in pairs(routeConfig.routes) do
            _G.s2c[name] = {moduleName, funcName}
        end
    end
end

return M