local HUD = {}

local frontendUtils = nil
if slua_GameFrontendHUD then
    frontendUtils = slua_GameFrontendHUD:GetUtils()
end
local gameStatusListener = {}

function HUD.AddToContainer(containerName, widget, zOrder)
    local container = frontendUtils:GetGlobalUIContainer(containerName)
    assert(container ~= nil, string.format("Can't get global ui container [%s]", containerName))
    container:AddWidgetWithZOrder(widget, zOrder)
end

function HUD.RemoveFromContainer(containerName, widget)
    local container = frontendUtils:GetGlobalUIContainer(containerName)
    container:RemoveWidget(widget)
end

function HUD.SetGameStatusListener(func)
    assert(type(func) == "function", "parameter must be function type")
	table.insert(gameStatusListener, func)
end

function HUD._OnGameStatusChange(status)
    if next(gameStatusListener) ~=nil then
		for key, func in pairs(gameStatusListener) do
			func(status)
		end
    end
end

if slua_GameFrontendHUD then
    slua_GameFrontendHUD.OnSwitchGameStatusEvent:Add(HUD._OnGameStatusChange)
end

return HUD