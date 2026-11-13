local M = {}
local STOP_TIME = -1
local MINIMUM_STEP_TIME = 1/60
M.MINIMUM_STEP_TIME = MINIMUM_STEP_TIME

local weakValueTable = {__mode = "v"}
local timerPool = setmetatable(
        {
            --{inUseFunc = callback, usedTimes = usedTimes, co = coroutine},
        }, weakValueTable)
local timerIndex = 0
local timers = {}
local timeTicker = FTimeTicker()

local function ReleaseTimerToPool(timer)
    timer.inUseFunc = nil
    table.insert(timerPool, timer)
end

local function CreateCoroutine(callback)
    if #timerPool > 0 then
        local timer = table.remove(timerPool)
        timer.inUseFunc = callback
        return timer
    end

    local timer = {inUseFunc = callback, co = nil}
    local function func(...)
        while true do
            timer.inUseFunc(...)
            ReleaseTimerToPool(timer)
            coroutine.yield(STOP_TIME)
        end
    end

    local co = coroutine.create(func)
    timer.co = co
    return timer
end

local function ResumeCoroutine(index)
    local timer = timers[index]
    if not timer then
        return STOP_TIME
    end

    local res, cycle = coroutine.resume(timer.co)
    if not res then
        log_error(debug.traceback(timer.co, cycle))
        timers[index] = nil
        return STOP_TIME
    end

    if cycle >= 0 and cycle < MINIMUM_STEP_TIME then
        cycle = MINIMUM_STEP_TIME
    end
    return cycle
end

function M.AddTimer(delay, func)
    assert(delay >= 0)
    local timer = CreateCoroutine(func)

    timerIndex = timerIndex + 1
    timeTicker:AddTimer(timerIndex, delay)
    timers[timerIndex] = timer
    return timerIndex
end

function M.RemoveTimer(timerIndex)
    timers[timerIndex] = nil
end

timeTicker:SetTickFunction(ResumeCoroutine)

return M