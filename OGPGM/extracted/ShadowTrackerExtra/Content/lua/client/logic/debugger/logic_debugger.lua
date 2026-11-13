
DebuggerSystem = DebuggerSystem or {
    m_bIsTabOpen = false,
    m_bIsStart = false,
    m_bPaused = false,
    bPauseForMainThread = false,
    m_bIsDebuging = false,

    bStepOver = false,
    bStepIn = false,
    bStepOut = false,


    BreakPoints = {},
    BreakLines = {},
    StepInStackCount = 0,
    StepOutStackCount = 0,
    LuaSourceDir = "",
    Cached = {},
	LuaPathCached = {},
	
	m_WeakVars = {},
	m_VarsIndex = 0,
	m_IgnoreKeySet = nil,
	m_GlobalProperty = {},
}

local bInEditor = LuaDebugHelper and LuaDebugHelper.IsEditor()
if not bInEditor then --非编辑器下，退出后续代码块的加载
	return
end

function DebuggerSystem.ShouldIgnoreKey(key)
	if (string.find(key,"^%(")) then
		log("Ignore var: " .. tostring(key));
		return true;
	end

	if (DebuggerSystem.m_IgnoreKeySet == nil) then
		DebuggerSystem.m_IgnoreKeySet = {};
		DebuggerSystem.m_IgnoreKeySet["_G"] = true;
		DebuggerSystem.m_IgnoreKeySet["_ENV"] = true;
		DebuggerSystem.m_IgnoreKeySet["(*temporary)"] = true;
	end

	if (DebuggerSystem.m_IgnoreKeySet[key]) then
		log("Ignore var: " .. tostring(key));
		return true;
	end
	return false;
end

function DebuggerSystem.GetGlobalPropertyList(BpName)
	if (BpName == nil) then
		return nil;
	end
	local propertyList = DebuggerSystem.m_GlobalProperty[BpName]
	if (propertyList == nil) then
		propertyList = LuaDebugHelper.GetLuaPropertyList(GameFrontendHUD, BpName);
		DebuggerSystem.m_GlobalProperty[BpName] = propertyList;
	end
	return propertyList;
end

function DebuggerSystem.GetFullFilePath(Path)
    if (DebuggerSystem.LuaSourceDir == nil or string.len(DebuggerSystem.LuaSourceDir) == 0) then
        DebuggerSystem.LuaSourceDir = LuaDebugHelper.GetLuaSourceDir();
        log("LuaSourceDir = " .. tostring(DebuggerSystem.LuaSourceDir));
    end

	local TheCached = DebuggerSystem.Cached[Path]
	if not TheCached then
		local FullPath = string.match(Path, "@.*/client/(.*%.lua)")
		if FullPath then
			FullPath = string.gsub(FullPath, "\\", "/")
			FullPath = DebuggerSystem.LuaSourceDir .. "/" ..FullPath
			DebuggerSystem.Cached[Path] = FullPath
			return FullPath
		end
		local LuaPath = string.match(Path, "%-%-%[%[(.-)%]%]")
		if LuaPath then
			LuaPath = string.gsub(LuaPath, "%.", "/")
			LuaPath = DebuggerSystem.LuaSourceDir .. "/"..LuaPath .. ".lua"
			DebuggerSystem.Cached[Path] = LuaPath
			return LuaPath
		end
		DebuggerSystem.Cached[Path] = Path
		return Path
	else
		return TheCached
	end
end

function DebuggerSystem.GetBpName(Source)
	if (Source == nil or string.len(Source) == 0) then
		return nil;
	end
	return string.match(Source, ".+/([^/]*)%.%w+$") 
end

function DebuggerSystem.GetLuaPath(Path)
	local TheCached = DebuggerSystem.LuaPathCached[Path]
	if not TheCached then
		local FullPath = string.match(Path, ".*client/(.*)%.lua")
		if FullPath == nil then
			FullPath = Path
		end
		FullPath = string.gsub(FullPath, "/", ".")
		DebuggerSystem.LuaPathCached[Path] = FullPath
		return FullPath
	else
		return TheCached
	end
end

function DebuggerSystem.CollectStackData()
	local Contents={}
	local FilePaths={}
	local Lines={}
	local StackIndexs={}
	for i = 3, math.huge do
		local StackInfo
		local RunningCoroutine = coroutine.running()
		if RunningCoroutine then
			StackInfo = debug.getinfo(RunningCoroutine, i)
		else
			StackInfo = debug.getinfo(i)
		end
		if not StackInfo then break end
		local FilePath = DebuggerSystem.GetFullFilePath(StackInfo.source)
		local Line = StackInfo.currentline
		local LuaPath = DebuggerSystem.GetLuaPath(FilePath)
		local FuncName = DebuggerSystem.GetFunctionName(StackInfo)
		local Content = LuaPath.." @ "..FuncName..":Line "..tostring(Line)
		table.insert(Contents, Content)
		table.insert(FilePaths, FilePath)
		table.insert(Lines, Line)
		table.insert(StackIndexs, i)
    end
    LuaDebugHelper.SetStackData(Contents, Lines, FilePaths, StackIndexs)
end

function DebuggerSystem.GetFunctionName(StackInfo)
	if (StackInfo ~= nil and StackInfo.name ~= nil) then
		return StackInfo.name;
	end
	if (StackInfo == nil or StackInfo.func == nil) then
		return "nil";
	end
	if (_ENV ~= nil) then
		for k, v in pairs(_ENV) do
			if (v == StackInfo.func) then
				return tostring(k);
			end
		end
	end
	return "nil";
end

function DebuggerSystem.UpdateBreakPoint()
    local InBreakPoints = LuaDebugHelper.GetBreakPoint();
    log_tree("InBreakPoints", InBreakPoints);
	DebuggerSystem.BreakPoints = {}
	DebuggerSystem.BreakLines = {}
    for k,v in pairs(InBreakPoints) do
        local result = string.split(v, "#")
        local FilePath = result[1];
        local LineNum = result[2];

		DebuggerSystem.BreakPoints[FilePath..tostring(LineNum)] = true
		DebuggerSystem.BreakLines[tonumber(LineNum)] = true
		
	end
	DebuggerSystem.CheckToRun()
end

function DebuggerSystem.HasAnyBreakPoint( )
	if DebuggerSystem.BreakPoints then
        for a,b in pairs(DebuggerSystem.BreakPoints) do
            log("HasAnyBreakPoint == true");
			return true
		end
	end
	return false
end

function DebuggerSystem.ShouldRunDebug()

	log("m_bIsTabOpen = " .. tostring(DebuggerSystem.m_bIsTabOpen))
	log("m_bIsStart = " .. tostring(DebuggerSystem.m_bIsStart))
	log("m_bPaused = " .. tostring(DebuggerSystem.m_bPaused))
	log("HasAnyBreakPoint = " .. tostring(DebuggerSystem.HasAnyBreakPoint()))

	return DebuggerSystem.m_bIsTabOpen and DebuggerSystem.m_bIsStart and DebuggerSystem.HasAnyBreakPoint() and DebuggerSystem.m_bPaused == false
end

function DebuggerSystem.HookCallBack(Event, Line)
    
    if Line then
        
		local IsDebugOperation = (DebuggerSystem.bStepOut and DebuggerSystem.StepOutStackCount<=-1)
								or (DebuggerSystem.bStepOver and DebuggerSystem.StepInStackCount<=0) 
								or DebuggerSystem.bStepIn 
		if not IsDebugOperation then
			if not DebuggerSystem.BreakLines[Line] then
				return 
			end
        end			
        
       -- log("DebuggerSystem.HookCallBack ……………………")
        
		local RunningCoroutine = coroutine.running()
		if RunningCoroutine == nil and DebuggerSystem.bPauseForMainThread then
			return
		end	
		local StackInfo
		if RunningCoroutine then
			StackInfo = debug.getinfo(RunningCoroutine, 2, "S")
		else
			StackInfo = debug.getinfo(2, "S")
        end
      --  log_tree("StackInfo", StackInfo);
        local FilePath = DebuggerSystem.GetFullFilePath(StackInfo.source)
       -- log("FilePath = " .. tostring(FilePath));
      --  log_tree("DebuggerSystem.BreakPoints", DebuggerSystem.BreakPoints);

		if 	IsDebugOperation or DebuggerSystem.BreakPoints[FilePath..tostring(Line)] then
			--log("HookCallBack Line IsDebugOperation = " .. tostring(IsDebugOperation))
			DebuggerSystem.StepInStackCount = 0
			DebuggerSystem.StepOutStackCount = 0
			DebuggerSystem.bStepIn = false
			DebuggerSystem.bStepOver = false
			DebuggerSystem.bStepOut = false
			DebuggerSystem.CollectStackData()
			LuaDebugHelper.EnterDebug(FilePath, Line)
		end
	elseif DebuggerSystem.bStepOver then
		--log("bStepOver, Event = " .. tostring(Event) .. ", StepInStackCount = " .. tostring(DebuggerSystem.StepInStackCount));
		if Event == "call" then
			DebuggerSystem.StepInStackCount = DebuggerSystem.StepInStackCount + 1
		else
			DebuggerSystem.StepInStackCount = DebuggerSystem.StepInStackCount - 1
		end
	elseif DebuggerSystem.bStepOut then
		if Event == "call" then
			DebuggerSystem.StepOutStackCount = DebuggerSystem.StepOutStackCount + 1
		else
			DebuggerSystem.StepOutStackCount = DebuggerSystem.StepOutStackCount - 1
		end 
		if DebuggerSystem.StepOutStackCount <= -1 then
			DebuggerSystem.bStepOut = false
			DebuggerSystem.bStepIn = true
		end
	end
end

function DebuggerSystem.CheckToRun()
    log("ShouldRunDebug() = " .. tostring(DebuggerSystem.ShouldRunDebug()) .. ", m_bIsDebuging = " .. tostring(DebuggerSystem.m_bIsDebuging))
	if DebuggerSystem.m_bIsDebuging then
		if not DebuggerSystem.ShouldRunDebug() then
            log("debug.sethook()")
			debug.sethook()
			DebuggerSystem.m_bIsDebuging = false
		end	
	else
        if DebuggerSystem.ShouldRunDebug() then
            log("debug.sethook(DebuggerSystem.HookCallBack)")
			debug.sethook(DebuggerSystem.HookCallBack, "lcr")
			DebuggerSystem.m_bIsDebuging = true
		end	
	end
end

function DebuggerSystem.SetTabIsOpen(bIsTabOpen)
	log("SetTabIsOpen bIsTabOpen = " .. tostring(bIsTabOpen));
	DebuggerSystem.m_bIsTabOpen = bIsTabOpen
	DebuggerSystem.CheckToRun()
end

function DebuggerSystem.ToggleDebugStart(bIsStart)
    log("ToggleDebugStart bIsStart = " .. tostring(bIsStart));
	DebuggerSystem.m_bIsStart = bIsStart
	DebuggerSystem.CheckToRun()
end

function DebuggerSystem.MayHaveChildren(Var)
	local TheType = type(Var)
	if TheType == "table" or TheType == "userdata" then
		return true
	else
		return false
	end
end

function DebuggerSystem.AddToWeak(LuaValue)
	local index = DebuggerSystem.m_VarsIndex + 1
	DebuggerSystem.m_VarsIndex = index
	if DebuggerSystem.IsContainer(LuaValue) then
		LuaValue = LuaValue:Table()
	end
	DebuggerSystem.m_WeakVars[index] = LuaValue
	return index
end

function DebuggerSystem.GetVarValueByKey(key, Value)
	if (key == nil) then
		return nil;
	end

	local valueList = string.split(key, ".");
	--log_tree("valueList", valueList);
	if (valueList ~= nil and #valueList > 1) then
		return DebuggerSystem.GetVarValue(Value, valueList, 1);
	else
		return Value[key];
	end
end

function DebuggerSystem.GetVarValue(baseValue, valueList, index)
	--log("DebuggerSystem.GetVarValue index = " .. index);
	if (baseValue == nil) then
		--log("base value is nil then return")
		return nil;
	end

	

	local subKey = valueList[index];
	local subValue = baseValue[subKey];
	--log("subKey = " .. tostring(subKey) .. ", subValue = " .. tostring(subValue));
	if (subValue == nil) then
		--log("subValue == nil so return nil")
		return nil;
	end

	if (index == #valueList) then
		--log("return value is " .. tostring(subValue));
		return subValue;
	end
	return DebuggerSystem.GetVarValue(subValue, valueList, index + 1);
end

function DebuggerSystem.GetStackVars(StackIndex)
	
	local WatchNameList = LuaDebugHelper.GetWatchNameList();
	--log_tree("WatchNameList", WatchNameList);

	local result = {}
	StackIndex = StackIndex + 1

	local StackInfo
	local RunningCoroutine = coroutine.running()

	if RunningCoroutine then
		StackInfo = debug.getinfo(RunningCoroutine, StackIndex, "fS")
	else
		StackInfo = debug.getinfo(StackIndex, "fS")
	end
	
	local func = StackInfo and StackInfo.func
	
	if func then
		local function AddNode(name, value, type)
			name = tostring(name)
			if (DebuggerSystem.ShouldIgnoreKey(name)) then
				return;
			end
			local NewNode = {}
			if DebuggerSystem.MayHaveChildren(value) then
				local WeakIndex = DebuggerSystem.AddToWeak(value)
				NewNode.ValueWeakIndex = WeakIndex
				--log_tree(name, value);
			end
			if (type == 1) then
				NewNode.Type = "Custom";
			elseif (type == 2) then
				NewNode.Type = "Local";
			elseif (type == 3) then
				NewNode.Type = "Global";
			end
			NewNode.Name = name
			NewNode.Value = tostring(value)..DebuggerSystem.GetClassName(value)
			table.insert(result, NewNode)
		end
	

		local localNode = {};
		for i = 1, math.huge do
			local name, value = debug.getupvalue(func, i)
			if not name then break end
			localNode[name] = value;
			--AddNode(name, value, 2)
		end
		for i = 1, math.huge do
			local name, value
			if RunningCoroutine then
				name, value = debug.getlocal(RunningCoroutine, StackIndex, i)
			else
				name, value = debug.getlocal(StackIndex, i)
			end			
			if not name then break end
			localNode[name] = value;
			--AddNode(name, value, 2)
		end
		
		local bpName = DebuggerSystem.GetBpName(StackInfo.source);
		local global = {};
		local propertyList = DebuggerSystem.GetGlobalPropertyList(bpName);
		if (propertyList ~= nil and _ENV ~= nil) then
			
			for k, v in pairs(propertyList) do
				local propertyValue = _ENV[v];
				if (propertyValue ~= nil) then
					global[v] = propertyValue;
					--AddNode(v, propertyValue, 3);
				end
			end
			
		end

		if (_ENV ~= nil and #WatchNameList > 0) then
			for k, v in pairs(WatchNameList) do
				if (v) then
					local value = DebuggerSystem.GetVarValueByKey(v, _ENV);
					if (value == nil) then
						value = DebuggerSystem.GetVarValueByKey(v, localNode);
					end
					if (value == nil) then
						value = DebuggerSystem.GetVarValueByKey(v, global);
					end
					
					if (value == nil) then
						AddNode(v, "nil", 1)
					else
						AddNode(v, value, 1)
					end
				end
			end
		end

		AddNode("Local", localNode, 2);
		AddNode("Global", global, 3);
	else
		log("GetStackVars func is nil");
	end
	--log_tree("UpdateStackVars result", result);
	LuaDebugHelper.UpdateStackVars(result);
	return result
end


function DebuggerSystem.GetVarNodeChildren(ValueWeakIndex)
	local result = {}
	local Var = DebuggerSystem.m_WeakVars[ValueWeakIndex]
	if Var then	
		local function AddNode(name, value)
			name = tostring(name)
			if (DebuggerSystem.ShouldIgnoreKey(name)) then
				return;
			end
			local NewNode = {} --FDebuggerVarNode.New()
			if DebuggerSystem.MayHaveChildren(value) then
				local WeakIndex = DebuggerSystem.AddToWeak(value)
				NewNode.ValueWeakIndex = WeakIndex
			end
			NewNode.Name = name
			NewNode.Value = tostring(value)..DebuggerSystem.GetClassName(value)
			table.insert(result, NewNode)
		end
		if type(Var) == "table" then
			local meta = getmetatable(Var)
			if meta then
				AddNode("$meta$", meta)
			end
			for name, value in pairs(Var) do 
				AddNode(name, value)
			end
			
			if meta then
				for key, v in pairs(meta) do
					if key:find("^LuaGet_") and type(v) == "function" then
						local name = key:match("^LuaGet_(.*)")
						local value = v(Var)
						AddNode(name, value)
					end
				end
			end
		elseif type(Var) == "userdata" then 
			local meta = getmetatable(Var)
			if meta then
				AddNode("$meta$", meta)
				for key, v in pairs(meta) do
					if key:find("^LuaGet_") and type(v) == "function" then
						local name = key:match("^LuaGet_(.*)")
						local value = v(Var)
						AddNode(name, value)
					end
				end
			end
		end
	end
	--log_tree("UpdateStackVarNodeChildren result", result);
	LuaDebugHelper.UpdateStackVarNodeChildren(result);
	return result
end

function DebuggerSystem.StepOver()
	DebuggerSystem.bStepOver = true	
end

function DebuggerSystem.StepIn()
	DebuggerSystem.bStepIn = true	
end

function DebuggerSystem.StepOut()
	DebuggerSystem.bStepOut = true	
end

function DebuggerSystem.GetClassName(VarValue)
	local name = ""
	if type(VarValue) == "table" or type(VarValue) == "userdata" then
		local function getname()
			if VarValue.classname then
				name = "("..VarValue.classname..")"
			end
		end
		-- lightweight userdata will error
		pcall(getname)
	end
	return name
end

function DebuggerSystem.IsContainer(Var)
	local classname = DebuggerSystem.GetClassName(Var)
	if classname == "(ULuaArrayHelper)" or classname == "(ULuaSetHelper)" or classname == "(ULuaMapHelper)" then
		return true
	else
		return false
	end
end

function DebuggerSystem.ToggleHotUpdate(Enable)
	log("DebuggerSystem.ToggleHotUpdate" .. tostring(Enable));

	HotUpdateSystem.Enable = Enable
	if (HotUpdateSystem.Enable and HotUpdateSystem.HasInitHoupdate == false) then
		HotUpdateSystem.InitLuaHotUpdate();
	end
end
