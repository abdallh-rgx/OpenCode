local M = {}
local zeroLocation = FVector()
local zeroRotator = FRotator()

function M.PlayAudio(audioPath, worldContextObject, eventName)
    local BusinessHelper = import("BusinessHelper")
    local akEvent = BusinessHelper.LoadAssetFromPath(audioPath)
    assert(akEvent ~= nil, string.format("Can't load audio from path[%s]", audioPath))
    local AkGameplayStatics = import("AkGameplayStatics")
    AkGameplayStatics.PostEventAtLocation(akEvent, zeroLocation, zeroRotator, eventName or "", worldContextObject)
end

function M.PlaySound(audioPath, eventName, switchGroup, switchState, worldContextObject)
    local AkGameplayStatics = import("AkGameplayStatics")
    if switchState ~= nil or switchState ~= "" then
        AkGameplayStatics.LoadBank(nil, switchState)
    end

    if (switchGroup ~= nil or switchGroup ~= "") and (switchState ~= nil and switchState ~= "") then
        AkGameplayStatics.SetSwitchWithDummyActor(switchGroup, switchState)
    end

    local BusinessHelper = import("BusinessHelper")
    local akEvent = BusinessHelper.LoadAssetFromPath(audioPath)
    assert(akEvent ~= nil, string.format("Can't load audio from path[%s]", audioPath))
    return AkGameplayStatics.PostEventWithDummyActor(akEvent, eventName or "", worldContextObject)
end

function M.StopSound(playingID)
    local AkGameplayStatics = import("AkGameplayStatics")
    AkGameplayStatics.StopPlayingID(playingID)
end

function M.SetTexture(control, path)
    local BusinessHelper = import("BusinessHelper")
    local Texture2D = import("Texture2D")
    local PaperSprite = import("PaperSprite")

    local textureOrSprite = BusinessHelper.UIGetResWithPath(path)
    if not textureOrSprite then
        control:SetBrushFromTexture(nil, false)
    elseif BusinessHelper.IsClassOf(textureOrSprite, PaperSprite) then
        local width, height = control.Brush.ImageSize.X, control.Brush.ImageSize.Y
        local PaperSpriteBlueprintLibrary = import("PaperSpriteBlueprintLibrary")
        local brush = PaperSpriteBlueprintLibrary.MakeBrushFromSprite(textureOrSprite, width, height)
        control:SetBrush(brush)
    elseif BusinessHelper.IsClassOf(textureOrSprite, Texture2D) then
        control:SetBrushFromTexture(textureOrSprite, false)
    else
        error(string.format("Not support SetTexture of %s", textureOrSprite))
    end
end

return M