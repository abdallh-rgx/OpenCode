FaceSlapSystem = FaceSlapSystem or
{
    ShowLimit = 2,
    IsFirstShow = true,
    HasBegin = false,
    IsDataReady = false,
    CurrentModuleIdx = 0,
    ModuleInfoArray = {},

    haveShowedFinal = false,
};

function FaceSlapSystem.Init()
    log("[HHF]FaceSlapSystem.Init");
    FaceSlapSystem.Reset();

    EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CHANGE, FaceSlapSystem.OnActivityChange);
end

function FaceSlapSystem.Reset()
    log("[HHF]FaceSlapSystem.Reset");
    FaceSlapSystem.ShowLimit = 2;
    FaceSlapSystem.IsFirstShow = true;
    FaceSlapSystem.HasBegin = false;
    FaceSlapSystem.IsDataReady = false;
    FaceSlapSystem.CurrentModuleIdx = 0;

    FaceSlapSystem.ModuleInfoArray = {};
    ------------------这里添加拍脸模块和显示检测，相关模块需实现跳转EventJumpUrl
   
    --table.insert(FaceSlapSystem.ModuleInfoArray, {id = BP_ENUM_MODULE_EIGHT_DAY, check = PandoraSystem.ShouldSlap});           -- Pandora
    table.insert(FaceSlapSystem.ModuleInfoArray, {id = BP_ENUM_MODULE_EIGHT_DAY, check = EightDayUI.ShouldSlap});           -- 新兵八天
    table.insert(FaceSlapSystem.ModuleInfoArray, {id = BP_ENUM_MODULE_STARTER_PACK, check = StarterPackUI.ShouldSlap});     -- Starter Pack
    table.insert(FaceSlapSystem.ModuleInfoArray, {id = BP_ENUM_MODULE_ANTIADDCTION, check = AntiaddctionSystem.ShouldSlap}); --防沉迷，不要加在我前面
	table.insert(FaceSlapSystem.ModuleInfoArray, {id = BP_ENUM_MODULE_WEEK_SIGNUP, check = WeekSignUpUI.ShouldSlap});       -- 周签到
    table.insert(FaceSlapSystem.ModuleInfoArray, {id = BP_ENUM_MODULE_PDD_BARGAIN, check = Bargain_Detail_UI.ShouldSlap});  -- 拼多多
    table.insert(FaceSlapSystem.ModuleInfoArray, {id = BP_ENUM_MODULE_COME_BACK, check = ComeBackSystem.ShouldSlap});       -- 玩家回流
    table.insert(FaceSlapSystem.ModuleInfoArray, {id = BP_ENUM_MODULE_ITOPNOTICE, check = IMSDKNoticeUI.ShouldSlap});       -- ITOP公告
    -----------------------------------------------------------------------

    FaceSlapSystem.haveShowedFinal = false;
end

function FaceSlapSystem.OnActivityChange()
    if not FaceSlapSystem.IsFirstShow then
        --log("[HHF]FaceSlapSystem.OnActivityChange, Not first show and return.");
        return;
    end

    log("[HHF]FaceSlapSystem.OnActivityChange, set IsDataReady = true");
    FaceSlapSystem.IsDataReady = true;
    FaceSlapSystem.ShowNext(0);
end

function FaceSlapSystem.BeginShow()
    if GlobalData:IsIOSCheck() then
        log("[HHF]FaceSlapSystem.BeginShow, IsIOSCheck() == true and return.");
        return;
    end

    if not FaceSlapSystem.IsFirstShow then
        log("[HHF]FaceSlapSystem.BeginShow, Not first show and return.");
        return;
    end

    log("[HHF]FaceSlapSystem.BeginShow, set HasBegin = true");
    FaceSlapSystem.HasBegin = true;
    FaceSlapSystem.ShowNext(0);
end

function FaceSlapSystem.ShowNext(currModuleID)
    if not FaceSlapSystem.HasBegin or not FaceSlapSystem.IsDataReady then
        log("[HHF]FaceSlapSystem.ShowNext, FaceSlapSystem.HasBegin = " .. tostring(FaceSlapSystem.HasBegin) .. ", FaceSlapSystem.IsDataReady = " .. tostring(FaceSlapSystem.IsDataReady) .. ", and return.");
        return;
    end

    local ModuleInfoArray = FaceSlapSystem.GetModuleInfoArray();

    local currentData = ModuleInfoArray[FaceSlapSystem.CurrentModuleIdx];
    if currentData and currentData.id ~= currModuleID then
        log("[HHF]FaceSlapSystem.ShowNext, currentData.id = " .. tostring(currentData.id) .. " ~= " .. tostring(currModuleID) .. " = currModuleID, and return.");
        return;
    end
    FaceSlapSystem.IsFirstShow = false;
    log("[HHF]FaceSlapSystem.ShowNext, CurrentModuleIdx = " .. tostring(FaceSlapSystem.CurrentModuleIdx) .. ", currModuleID = " .. tostring(currModuleID));
    local nextIndex = 0;
    for i = FaceSlapSystem.CurrentModuleIdx + 1, #ModuleInfoArray do
        local info = ModuleInfoArray[i];
        if info and info.check and info.check() then
            nextIndex = i;
            break;
        end
    end

    if nextIndex == 0 then
        FaceSlapSystem.CurrentModuleIdx = #ModuleInfoArray + 1;
        log("[HHF]FaceSlapSystem.ShowNext, no available and set CurrentModuleIdx = " .. FaceSlapSystem.CurrentModuleIdx .. "(len + 1).");
        FaceSlapSystem.UninterruptableFinallyShow();
    else
        if FaceSlapSystem.ShowLimit <= 0 then
            log("[HHF]FaceSlapSystem.ShowNext, ShowLimit = " .. tostring(FaceSlapSystem.ShowLimit) .. ", and abort.");
            FaceSlapSystem.UninterruptableFinallyShow();
        else
            FaceSlapSystem.Show(nextIndex);
        end
    end
end

function FaceSlapSystem.Show(index)
    local ModuleInfoArray = FaceSlapSystem.GetModuleInfoArray();

    if index <= 0 or index > #ModuleInfoArray then
        log("[HHF]FaceSlapSystem.Show, index = " .. tostring(index) .. " out of bounds and return.");
        return;
    end

    local moduleInfo = ModuleInfoArray[index];
    if moduleInfo == nil then
        log("[HHF]FaceSlapSystem.Show, moduleInfo = nil and return.");
        return;
    end

    FaceSlapSystem.SubShowLimit();
    FaceSlapSystem.CurrentModuleIdx = index;
    if moduleInfo.id == BP_ENUM_MODULE_PDD_BARGAIN then
        BP_Global_Url = Bargain_Detail_UI.bargainURL;
    else
        BP_Global_Url = string.format("game://?module=%d", moduleInfo.id);
    end
    log("[HHF]FaceSlapSystem.Show, index = " .. tostring(index) .. ", Jump to url = " .. BP_Global_Url);
    EventJumpUrl();
end

function FaceSlapSystem.SubShowLimit()
    FaceSlapSystem.ShowLimit = FaceSlapSystem.ShowLimit - 1;
    log("[HHF]FaceSlapSystem.SubShowLimit, " .. tostring(FaceSlapSystem.ShowLimit + 1) .. " - 1 = " .. tostring(FaceSlapSystem.ShowLimit));
end

function FaceSlapSystem.UninterruptableFinallyShow()
    log("[HHF]FaceSlapSystem.UninterruptableFinallyShow, haveShowedFinal = " .. tostring(FaceSlapSystem.haveShowedFinal));
    if FaceSlapSystem.haveShowedFinal == false then
        FaceSlapSystem.haveShowedFinal = true;
        LobbySystem.PopUIAfterNoticeInti();
        --IMSDKNoticeUI.haveShowedNoticeAfterLogin = true;
    end
end

function FaceSlapSystem.IsModuleShowedByModulID(moduleID)
    local ModuleInfoArray = FaceSlapSystem.GetModuleInfoArray();

    local found = false;
    for i = FaceSlapSystem.CurrentModuleIdx, 1, -1 do
        local info = ModuleInfoArray[i];
        if info and info.id == moduleID then
            found = true;
            break;
        end
    end

    log("[HHF]FaceSlapSystem.IsModuleShowedByModulID, moduleID = " .. tostring(moduleID) .. ", haveShowed = " .. tostring(found));
    return found;
end

function FaceSlapSystem.GetModuleInfoArray()
    -- 如果是UI自动化测试，就不弹框了
    local bUIAutoTest = Client.IsUIAutoTest();
    print("[HHF]FaceSlapSystem.GetModuleInfoArray bUIAutoTest=", bUIAutoTest);
    if bUIAutoTest then
        return {};
    end

    return FaceSlapSystem.ModuleInfoArray;
end
