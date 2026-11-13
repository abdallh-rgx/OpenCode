local Reload = {}
local protection = {}
local errorHappen = false
local debugEnable = false
local fakeENV = nil
local ENV = nil
local fakeTable = nil
local failNotify = nil
local UpdateUpvalue --function

local function setfenv(fn, env)
    local i = 1
    while true do
        local name = debug.getupvalue(fn, i)
        if name == "_ENV" then
            debug.upvaluejoin(fn, i, (function()
            return env
            end), 1)
            break
        elseif not name then
            break
        end

        i = i + 1
    end

    return fn
end

local function getfenv(fn)
    local i = 1
    while true do
        local name, val = debug.getupvalue(fn, i)
        if name == "_ENV" then
            return val
        elseif not name then
            break
        end
        i = i + 1
    end
end

local function FailNotify(msg)
    failNotify(msg)
	error(msg)
end

local function ErrorHandle(e)
	FailNotify("HotUpdate Error\n"..tostring(e))
	errorHappen = true
end

local function DebugNofity(...)
	if debugEnable then 
        print(...)
    end
end

local function FindLoader(name)
	local msg = {}
	for _, loader in ipairs(package.searchers) do
		local f , extra = loader(name)
		local t = type(f)
		if t == "function" then
			return f, extra
		elseif t == "string" then
			table.insert(msg, f)
		end
	end
	FailNotify(string.format("module '%s' not found:%s", name, table.concat(msg)))
end

local function InitFakeTable()
	local meta = {}
	Reload.Meta = meta
	local function FakeT() 
        return setmetatable({}, meta) 
    end
	local function EmptyFunc() 
    end
	local function pairs() 
        return EmptyFunc
    end  
	local function setmetatable(t, metaT)
		Reload.MetaMap[t] = metaT 
		return t
	end
	local function getmetatable(t, metaT)
		return setmetatable({}, t)
	end
    local require_ = require
    local function require(moduleName)
        if moduleName == "class" then
            return require_(moduleName)
        end
		if not Reload.RequireMap[moduleName] then
			local FakeTable = FakeT()
			Reload.RequireMap[moduleName] = FakeTable
		end
		return Reload.RequireMap[moduleName]
	end
	function meta.__index(t, k)
		if k == "setmetatable" then
			return setmetatable
		elseif k == "pairs" or k == "ipairs" then
			return pairs
		elseif k == "next" then
			return EmptyFunc
		elseif k == "require" then
			return require
		else
			local FakeTable = FakeT()
			rawset(t, k, FakeTable)
			return FakeTable 
		end
	end
    
	function meta.__newindex(t, k, v) 
        rawset(t, k, v)
    end
    
	function meta.__call(...) 
        return FakeT(), FakeT(), FakeT()
    end
    
    local function call(...)
        return FakeT(), FakeT(), FakeT()
    end
    
	function meta.__add(...) 
        return call(...)
    end
    
	function meta.__sub(...) 
        return call(...)
    end
    
	function meta.__mul(...) 
        return call(...)
    end
    
	function meta.__div(...) 
        return call(...)
    end
    
	function meta.__mod(...) 
        return call(...)
    end
    
	function meta.__pow(...) 
        return call(...)
    end
    
	function meta.__unm(...) 
        return call(...)
    end
    
	function meta.__concat(...) 
        return call(...)
    end
    
	function meta.__eq(...) 
        return call(...)
    end
    
	function meta.__lt(...) 
        return call(...)
    end
    
	function meta.__le(...) 
        return call(...)
    end
    
	function meta.__len(...) 
        return call(...)
    end
    
	return FakeT
end

local function BuildNewCode(moduleName)
	local loader, arg = FindLoader(moduleName)
	if not loader then 
  		FailNotify(moduleName.." has syntax error.")  	
  		collectgarbage("collect")
  		return false
	else
		fakeENV = fakeTable()
		Reload.MetaMap = {}
        Reload.RequireMap = {}
		setfenv(loader, fakeENV)
		local NewObject
		errorHappen = false
		xpcall(function () NewObject = loader(moduleName, arg) end, ErrorHandle)
		if not errorHappen then 
			return true, NewObject
		else
	  		collectgarbage("collect")
			return false
		end
	end
end

local function Travel_G()
	local visited = {}
	visited[Reload] = true
	local function Replace(t)
		if (type(t) ~= "function" and type(t) ~= "table") or visited[t] or protection[t] then 
            return 
        end
		visited[t] = true
		if type(t) == "function" then
		  	for i = 1, math.huge do
				local name, value = debug.getupvalue(t, i)
				if not name then 
                    break
                end
				if type(value) == "function" then
					for _, funcs in ipairs(Reload.changedFuncList) do
						if value == funcs[1] then
							debug.setupvalue(t, i, funcs[2])
						end
					end
				end
				Replace(value)
			end
		elseif type(t) == "table" then
			Replace(debug.getmetatable(t))
			local changeIndexs = {}
			for k,v in pairs(t) do
				Replace(k); Replace(v);
				if type(v) == "function" then
					for _, funcs in ipairs(Reload.changedFuncList) do
						if v == funcs[1] then 
                            t[k] = funcs[2]
                        end
					end
				end
				if type(k) == "function" then
					for index, funcs in ipairs(Reload.changedFuncList) do
						if k == funcs[1] then 
                            changeIndexs[#changeIndexs+1] = index 
                        end
					end
				end
			end
			for _, index in ipairs(changeIndexs) do
				local funcs = Reload.changedFuncList[index]
				t[funcs[2]] = t[funcs[1]] 
				t[funcs[1]] = nil
			end
		end
	end
	
	Replace(_G)
	local registryTable = debug.getregistry()
	Replace(registryTable)
	
	for _, funcs in ipairs(Reload.changedFuncList) do
		if funcs[3] == "HUDebug" then 
            funcs[4]:HUDebug()
        end
	end
end

local function UpdateOneFunction(OldObject, NewObject, FuncName, OldTable, From, Deepth)
	if protection[OldObject] or protection[NewObject] then
        return
    end
	if OldObject == NewObject then
        return
    end
	local signature = tostring(OldObject)..tostring(NewObject)
	if Reload.visitedSig[signature] then
        return
    end
	Reload.visitedSig[signature] = true
	DebugNofity(Deepth.."UpdateOneFunction "..FuncName.."  from:"..From)
	if pcall(setfenv, NewObject, getfenv(OldObject)) then
		UpdateUpvalue(OldObject, NewObject, FuncName, "UpdateOneFunction", Deepth.."    ")
		Reload.changedFuncList[#Reload.changedFuncList + 1] = {OldObject, NewObject, FuncName, OldTable}
	end
end

local function UpdateAllFunction(OldTable, NewTable, Name, From, Deepth)
	if protection[OldTable] or protection[NewTable] then 
        return
    end
	local signature = tostring(OldTable)..tostring(NewTable)
	if Reload.visitedSig[signature] then 
        return
    end
	Reload.visitedSig[signature] = true
	DebugNofity(Deepth.."UpdateAllFunction "..tostring(Name).."  from:"..From)
	for ElementName, Element in pairs(NewTable) do
		local OldElement = OldTable[ElementName]
		if type(Element) == type(OldElement) then
			if type(Element) == "function" then
				UpdateOneFunction(OldElement, Element, ElementName, OldTable, "UpdateAllFunction", Deepth.."    ")
			elseif type(Element) == "table" then
				UpdateAllFunction(OldElement, Element, ElementName, "UpdateAllFunction", Deepth.."    ")
			end
		elseif OldElement == nil and type(Element) == "function" then
			if pcall(setfenv, Element, ENV) then
				OldTable[ElementName] = Element
			end
		end
	end
	local OldMeta = debug.getmetatable(OldTable)  
	local NewMeta = Reload.MetaMap[NewTable]
    if NewMeta == nil then
        NewMeta = debug.getmetatable(NewTable)
    end
	if type(OldMeta) == "table" and type(NewMeta) == "table" then
		UpdateAllFunction(OldMeta, NewMeta, Name.."'s Meta", "UpdateAllFunction", Deepth.."    ")
	end
end

local function ReplaceOld(OldObject, NewObject, LuaPath, From, Deepth)
	if type(OldObject) == type(NewObject) then
		if type(NewObject) == "table" then
			UpdateAllFunction(OldObject, NewObject, LuaPath, From, "") 
		elseif type(NewObject) == "function" then
			UpdateOneFunction(OldObject, NewObject, LuaPath, nil, From, "")
		end
	end
end

local function ResetENV(object, name, From, Deepth)
	local visited = {}
	local function Reset(object, name)
		if not object or visited[object] then
            return
        end
		visited[object] = true
		if type(object) == "function" then
			DebugNofity(Deepth.."ResetENV", name, "  from:"..From)
			xpcall(function () setfenv(object, ENV) end, FailNotify)
		elseif type(object) == "table" then
			DebugNofity(Deepth.."ResetENV", name, "  from:"..From)
			for k, v in pairs(object) do
				Reset(k, tostring(k).."__key")
				Reset(v, tostring(k))
			end
		end
	end
	Reset(object, name)
end

UpdateUpvalue = function (OldFunction, NewFunction, Name, From, Deepth)
	DebugNofity(Deepth.."UpdateUpvalue", Name, "  from:"..From)
	local OldUpvalueMap = {}
	local OldExistName = {}
	for i = 1, math.huge do
		local name, value = debug.getupvalue(OldFunction, i)
		if not name then
            break
        end
		OldUpvalueMap[name] = value
		OldExistName[name] = true
	end
	for i = 1, math.huge do
		local name, value = debug.getupvalue(NewFunction, i)
		if not name then
            break
        end
		if OldExistName[name] then
			local OldValue = OldUpvalueMap[name]
			if type(OldValue) ~= type(value) then
				debug.setupvalue(NewFunction, i, OldValue)
			elseif type(OldValue) == "function" then
				UpdateOneFunction(OldValue, value, name, nil, "UpdateUpvalue", Deepth.."    ")
			elseif type(OldValue) == "table" then
				UpdateAllFunction(OldValue, value, name, "UpdateUpvalue", Deepth.."    ")
				debug.setupvalue(NewFunction, i, OldValue)
			else
				debug.setupvalue(NewFunction, i, OldValue)
			end
		else
			ResetENV(value, name, "UpdateUpvalue", Deepth.."    ")
		end
	end
end

local function HotUpdateCode(moduleName)
	local OldObject = package.loaded[moduleName]
	if OldObject ~= nil then
		Reload.visitedSig = {}
		Reload.changedFuncList = {}
		local Success, NewObject = BuildNewCode(moduleName)
		if Success then
			ReplaceOld(OldObject, NewObject, moduleName, "Main", "")
            for Name, NewObject in pairs(Reload.RequireMap) do
				local OldObject = package.loaded[Name]
				ReplaceOld(OldObject, NewObject, Name, "Main_require", "")
			end
			setmetatable(fakeENV, nil)
			UpdateAllFunction(ENV, fakeENV, " ENV ", "Main", "")
			if #Reload.changedFuncList > 0 then
				Travel_G()
			end
			collectgarbage("collect")
		end
        return Success
    else
        FailNotify(string.format("Module[%s] not found or not loaded!", moduleName))
	end
end

local function InitProtection()
	protection[setmetatable] = true
	protection[pairs] = true
	protection[ipairs] = true
	protection[next] = true
	protection[require] = true
	protection[Reload] = true
	protection[Reload.Meta] = true
	protection[math] = true
	protection[string] = true
	protection[table] = true
    
    protection[setfenv] = true
    protection[getfenv] = true
    protection[FindLoader] = true
    protection[DebugNofity] = true
    protection[FailNotify] = true
    protection[InitFakeTable] = true
    protection[InitProtection] = true
    protection[ErrorHandle] = true
    protection[BuildNewCode] = true
    protection[Travel_G] = true
    protection[UpdateOneFunction] = true
    protection[UpdateAllFunction] = true
    protection[ReplaceOld] = true
    protection[ResetENV] = true
    protection[UpdateUpvalue] = true
    protection[HotUpdateCode] = true
end

function Reload.Reload(moduleList, notifyCallback, failNotifyCallback, isDebug, env)
    assert(type(moduleList) == "table", "Module list must be table type!")

	fakeENV = nil
	ENV = env or _G
    failNotify = failNotifyCallback
    debugEnable = isDebug
	fakeTable = InitFakeTable()
    InitProtection()
    
    for _, moduleName in pairs(moduleList) do
        if HotUpdateCode(moduleName) and notifyCallback then
            notifyCallback(moduleName)
        end
    end
end

return Reload
