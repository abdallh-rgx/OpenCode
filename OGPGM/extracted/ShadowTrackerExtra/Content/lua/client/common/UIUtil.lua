--UI工具类
UIUtil = UIUtil or {
    globalUIFunctionLibrary = nil
}

--key是name，value是间隔限制和上次点击时间
ClickFrequencyLimit = ClickFrequencyLimit or {
    StoreTab = {0.5, 0},
    StoreCollectionBtn = {1, 0},
}

--为了避免玩家快速点击按钮造成高频操作（例如向后台发送请求、切换Avatar等），
--可在点击响应事件里调用它加个判断，点击间隔在ClickFrequencyLimit中配置。
function UIUtil.CanClickNow(info)
    if info == nil then
        log("[HHF]UIUtil.CanClickNow, no info and let it go.");
        return true;
    end

    local currentTime = FuncUtil.GetServerTimeInSecWithFraction();
    if math.abs(currentTime - info[2]) < info[1] then
        log("[HHF]UIUtil.CanClickNow, currentTime - preClickTime = "
            .. tostring(currentTime) .. " - " .. tostring(info[2])
            .. " < " .. tostring(info[1]) .. " = interval");

        local tips = FuncUtil.GetLocalizeResStr(421015);
        PopUpNoticeUI.ShowNewNotice(tips);
        return false;
    else
        log("[HHF]UIUtil.CanClickNow, currentTime - preClickTime = "
            .. tostring(currentTime) .. " - " .. tostring(info[2])
            .. " >= " .. tostring(info[1]) .. " = interval");
        info[2] = currentTime;
        return true;
    end
end

function UIUtil.BoolToVisible(visible, collapse, isButton)
    if collapse == nil then
        collapse = true
    end
    --return UIUtil.GetGlobalUIFunctionLibrary().BoolToVisible(visible or false, collapse, isButton or false, UIUtil.GetGameInstance())

    if visible then
        if isButton then
            return UEnums.ESlateVisibility.Visible
        else
            return UEnums.ESlateVisibility.SelfHitTestInvisible
        end
    else
        if collapse then
            return UEnums.ESlateVisibility.Collapsed
        else
            return UEnums.ESlateVisibility.Hidden
        end
    end
end

function UIUtil.IndexBP2Lua(index)
    return index + 1
end

function UIUtil.IndexLua2BP(index)
    return index - 1
end


function UIUtil.GetGameInstance()
    local GameInstClass = import("STExtraGameInstance")
    return GameInstClass.GetInstance()
end

function UIUtil.GetGlobalUIFunctionLibrary()
    if UIUtil.globalUIFunctionLibrary == nil then
        UIUtil.globalUIFunctionLibrary = slua.loadClass("/Game/UMG/UI_Utility/GlobalUIFunctionLibrary.GlobalUIFunctionLibrary");
    end
    return UIUtil.globalUIFunctionLibrary
end

function UIUtil.UIGetResWithPath(path)
    local BusinessHelper = import("BusinessHelper");
    return BusinessHelper.UIGetResWithPath(path);
end

function UIUtil.SetItemQuality(quality, imageWidget)
    UIUtil.GetGlobalUIFunctionLibrary().SetItemQuality(quality, imageWidget, UIUtil.GetGameInstance())
end

function UIUtil.SwitchSceneCameraByIndex(idx, BlendTime, SkipNotify)
    UIUtil.GetGlobalUIFunctionLibrary().SwitchSceneCameraByIndex(idx, BlendTime or 0, SkipNotify or false, UIUtil.GetGameInstance())
end

function UIUtil.UpdateNationImage(image, roleNation)
    UIUtil.GetGlobalUIFunctionLibrary().UpdateNationImage(image, roleNation, UIUtil.GetGameInstance())
end

function UIUtil.SetAdaptation(widget)
    local UICommonFunctionLibrary = slua.loadClass("/Game/UMG/UI_BP/Common/UICommonFunctionLibrary.UICommonFunctionLibrary");
    UICommonFunctionLibrary.SetAdaptation(widget, UIUtil.GetGameInstance())
end

function UIUtil.SetAdaptationLobby(widget)
    local UICommonFunctionLibrary = slua.loadClass("/Game/UMG/UI_BP/Common/UICommonFunctionLibrary.UICommonFunctionLibrary");
    UICommonFunctionLibrary.SetAdaptationLobby(widget, UIUtil.GetGameInstance())
end

function UIUtil.GetWidgetByPath(widgetPath)
    local WidgetBlueprintLibrary = import("WidgetBlueprintLibrary")
    local widgetClass = slua.loadClass(widgetPath);

    local widgets = slua.Array(UEnums.EPropertyClass.Object, widgetClass)

    local outWidgets = WidgetBlueprintLibrary.GetAllWidgetsOfClass(UIUtil.GetGameInstance(), widgets, widgetClass, false)

    --log("outWidgets:Num():" .. outWidgets:Num() )
    if outWidgets:Num() >= 1 then
        return outWidgets:Get(0)
    end

    return nil
    --UICommonFunctionLibrary.SetAdaptation(widget, UIUtil.GetGameInstance())
end

function UIUtil.GetWidgetByLogicName(logicName, widgetIndex)
    local  logic = slua_GameFrontendHUD:GetLogicManagerByName(logicName)
    if not logic then
        return nil
    end
    local widgets = logic.WidgetList
    widgetIndex = widgetIndex or 0
    if widgets:Num() >= widgetIndex + 1 then
        return widgets:Get(widgetIndex)
    end

    return nil
end

function UIUtil.GetWidgetByName(logicName, widgetName)
    local  logic = slua_GameFrontendHUD:GetLogicManagerByName(logicName)
    if not logic then
        return nil
    end
    return logic:GetWidgetByName(widgetName)
end
