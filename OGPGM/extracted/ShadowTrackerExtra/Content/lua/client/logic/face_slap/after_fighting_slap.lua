AfterFightingSlapSystem = AfterFightingSlapSystem or
{
    Step_RedPacket = 1,
    Step_ComeBack = 2,

    StepInfoArray = {},

    CurrentStep = 0,


    Status_Init = 1,
    Status_Begin = 2,
    Status_End = 3,

    CurrentStatus = 1,
}

function ShowComeBack()
    -- ComeBackUI.ShowUI(ComeBackSystem.PanelType_JumpToTask)
    ComeBackSystem.ShowAfterFight = true;
end

local function ShowNext()
    if AfterFightingSlapSystem.CurrentStatus ~= AfterFightingSlapSystem.Status_Begin then
        return
    end

    local nextIndex = 0
    for i=AfterFightingSlapSystem.CurrentStep+1, #AfterFightingSlapSystem.StepInfoArray do
        local stepInfo = AfterFightingSlapSystem.StepInfoArray[i]
        if stepInfo and stepInfo.check then
            local ec, result = pcall(stepInfo.check)
            if ec and result then
                nextIndex = i;
                break;
            end
        end
    end

    log("AfterFightingSlapSystem ShowNext nextIndex "..tostring(nextIndex))

    if nextIndex > 0 then
        AfterFightingSlapSystem.CurrentStep = nextIndex;
        local stepInfo = AfterFightingSlapSystem.StepInfoArray[nextIndex];
        if stepInfo then
            local ec, result = pcall(stepInfo.showUI)
            if not ec then
                log("AfterFightingSlapSystem ShowNext error!")
                log(string.format("AfterFightingSlapSystem ShowNext slap[%s] error[%s]", tostring(nextIndex), tostring(result)))
                FaceSlapSystem.StopShow()
            end
        end
    else
        AfterFightingSlapSystem.EndShow()
    end
end

function AfterFightingSlapSystem.Init()
    AfterFightingSlapSystem.StepInfoArray[AfterFightingSlapSystem.Step_RedPacket] = {}
    AfterFightingSlapSystem.StepInfoArray[AfterFightingSlapSystem.Step_ComeBack] = {check = ComeBackSystem.IsCanAfterFightingSlap, showUI = ShowComeBack}
end

function AfterFightingSlapSystem.BeginShow()
    log("AfterFightingSlapSystem.BeginShow")
    AfterFightingSlapSystem.CurrentStatus = AfterFightingSlapSystem.Status_Begin
    AfterFightingSlapSystem.CurrentStep = 0
    ShowNext()
end

function AfterFightingSlapSystem.OnStepFinished(step)
    if AfterFightingSlapSystem.CurrentStep == step then
        ShowNext();
    end
end

function AfterFightingSlapSystem.EndShow()
    AfterFightingSlapSystem.CurrentStatus = AfterFightingSlapSystem.Status_End;
    AfterFightingSlapSystem.CurrentStep = #AfterFightingSlapSystem.StepInfoArray + 1;
end