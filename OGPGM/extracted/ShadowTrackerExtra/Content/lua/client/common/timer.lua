Timer = Timer or {}

Timer._list = {}
Timer._Check = false
Timer._DelayInsert = {}
Timer.CurrentTime = 0
--modify by rainpan 2018/05/03 增加参数bLimitDeltaTime 区分切后台时，是否计时
function Timer.InsertTimer(timeOffset, callfunc, loop, bLimitDeltaTime)
	-- insert time in order list
	if type(callfunc) ~= "function" or timeOffset < 0 then
		sandbox.LogError("Timer.InsertTimer callfunc params type error!!：" .. debug.traceback());
		return;
	end	
	local timePoint = Timer.CurrentTime + timeOffset
	local timer = {timePoint = timePoint, offset = timeOffset, func = callfunc, loop = loop, bLimitDeltaTime = bLimitDeltaTime}
	if Timer._Check then
		table.insert(Timer._DelayInsert,timer);
		return timer;
	else
	Timer._InsertTimer(timer);
	end
	return timer;
end

function Timer._InsertTimer(timer)
	local i = 1
	local j = #Timer._list
	while j >= i do
		local mid = math.ceil((j - i)/2) + i
		if Timer._list[mid].timePoint > timer.timePoint then
			j = mid - 1
		else
			i = mid + 1
		end
	end
	table.insert(Timer._list, i, timer)
end

function Timer.RemoveTimer(timer)
	timer.timePoint = 0
	timer.func = nil
	timer.loop = false
	timer.bLimitDeltaTime = false
end

function Timer.Tick(deltaTime)
	Timer.CurrentTime = Timer.CurrentTime + deltaTime
	local removeList = {}
	--local funcList = {}
	Timer._Check = true;
	for key,timer in ipairs(Timer._list) do
		if timer.bLimitDeltaTime ~= nil then
			if timer.bLimitDeltaTime == true and deltaTime > 2 then
				timer.timePoint = timer.timePoint + deltaTime;
			end
		end
		if timer.timePoint <= Timer.CurrentTime then
			if timer.func ~= nil  then
				timer.func()
				--table.insert(funcList, timer.func)
			end

			if timer.loop then
			timer.timePoint = timer.offset + Timer.CurrentTime;
			Timer._list[key] = timer;
			else
			table.insert(removeList, key);
			end
		end
	end
	Timer._Check = false;	
	-- 删除过期的timer
	--local loopList = {}
	for idx = #removeList, 1, -1 do
		removeIndex = removeList[idx];
		--local timer = Timer._list[removeIndex]
		table.remove(Timer._list, removeIndex)
		--if timer.loop then
		--	table.insert(loopList, timer)
		--end
	end

	for i = #Timer._DelayInsert, 1, -1 do
		local val = Timer._DelayInsert[i];
		Timer._InsertTimer(val);
		table.remove(Timer._DelayInsert, i);
	end
	-- 插入需要循环的timer
	--for _, timer in ipairs(loopList) do
	--	timer.timePoint = timer.offset + Timer.CurrentTime
	--	Timer._InsertTimer(timer)
	--end

	--for _, timerCallback in ipairs(funcList) do
	--	timerCallback()
	--end
end