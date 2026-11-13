local bInEditor = LuaDebugHelper and LuaDebugHelper.IsEditor()
if not bInEditor then --非编辑器下，退出后续代码块的加载
    return
end

print("********************************")

HotUpdateSystem = HotUpdateSystem or {
	Enable = false,	--是否开启lua热更新
    OnlyHotUpdateFunc = true, --是否只更新函数
    TickEnable = false, --是否开启每帧tick
	HasInitHoupdate = false,
	Timer = 0,
	TimeLength = 1,
    IsThisApplicationForeground = false, --保存当前的应用程序是否是前台程序
	files = {},
    hasReadFile = false,
    useNewHotUpdate = true,
}

--始终全量更新的文件
local AlwaysHotUpdateWholeFiles = 
{
    "logic_hot_update.lua",
    "log.lua",
    --"test.lua",
}

local HotUpdateRunFuntion = --热更新后会运行的函数
{
    --["IceLuckyGemUI.RefreshSnatchAccAward"] = true
}

function HotUpdateSystem.InitLuaHotUpdate()
    log("HotUpdateSystem.InitLuaHotUpdate()")
    if HotUpdateSystem.HasInitHoupdate then
        return
    end
    HotUpdateSystem.HasInitHoupdate = true

    local luaSourceDir = LuaDebugHelper.GetLuaSourceDir();
    log("HotUpdateSystem.InitLuaHotUpdate:" .. luaSourceDir);
    HotUpdateSystem.InitFileMap(luaSourceDir)
    
    local require_ = require
    require = function (moduleName)
        if not package.loaded[moduleName] then
            HotUpdateSystem.register_file(luaSourceDir, moduleName)
        end
        
        return require_(moduleName)
    end
end

function HotUpdateSystem.readFileContent()
    --log("HotUpdateSystem.readFileContent");
    for filename, node in pairs(HotUpdateSystem.files) do
        local filecontent = sandbox.ReadFile(filename)
        --log("HotUpdateSystem.readFileContent:" .. filename);
        if filecontent then
            node.funcs, node.functionLines = HotUpdateSystem.ReadFuncs(filecontent)
        end
        
        --log("node.time = " .. tostring(node.time));
    end
end

function HotUpdateSystem.get_filenode(filename, moduleName)
    local node = HotUpdateSystem.files[filename];
    if node then
        return node;
    end
    local env = {};
    setmetatable(env, sandbox.meta);
    node = {env = env, moduleName = moduleName, filename = filename, funcs = {}}
    HotUpdateSystem.files[filename] = node;
    return node;
end

function HotUpdateSystem.CheckOnlyHotUpdateFunc(content)
    local startIndex,endIndex,subStr = string.find(content, "OnlyHotUpdateFunc%s*=%s*(%a+)", 1)
    if subStr == "true" then
        --log("HotUpdateSystem.OnlyHotUpdateFunc = true");
        HotUpdateSystem.OnlyHotUpdateFunc = true
    elseif subStr == "false" then
        --log("HotUpdateSystem.OnlyHotUpdateFunc = false");
        HotUpdateSystem.OnlyHotUpdateFunc = false
    end
end

function HotUpdateSystem.register_file(RootPath, moduleName)
    local filename = RootPath .. string.gsub(moduleName,"%.", "/") .. ".lua"
    log("register_file " .. filename)
    local node = HotUpdateSystem.get_filenode(filename, moduleName)
    if not node.time then
        node.time = sandbox.GetFileTime(filename)
    end
    return node.env
end

function HotUpdateSystem.InitFileMap(RootPath)
    if package and package.loaded then
        for moduleName, _ in pairs(package.loaded) do
            if type(moduleName) == "string" then
                HotUpdateSystem.register_file(RootPath, moduleName)
            end
        end
    end
end

function HotUpdateSystem.CheckReload()
    local t1 = os.clock();
	local now = os.time();
    local ChangeFiles = {}
    local Logic_Hot_UpdateModify = nil
    for path, node in pairs(HotUpdateSystem.files) do
        local filetime = sandbox.GetFileTime(node.filename);
        if filetime ~= node.time and filetime ~= 0 and math.abs(now - filetime) > 1 then
            node.time = filetime;
            if HotUpdateSystem.useNewHotUpdate then
                table.insert(ChangeFiles, node.moduleName)
            else
                ChangeFiles[path] = node
            end
            if string.find(node.filename, "logic_hot_update", 1) then
                Logic_Hot_UpdateModify = node
            end
        end
    end
    --print("HotUpdateSystem：文件时间检测花费时间=", now - os.time())
    now = os.time()
    
    if HotUpdateSystem.useNewHotUpdate then
        if #ChangeFiles > 0 then
            local reload = require("reload")
            local function OnSuccess(moduleName)
                LuaDebugHelper.OnLuaFileHotUpdate(string.format("HotUpdate: %s success!", moduleName))
            end
            reload.Reload(ChangeFiles, OnSuccess, LuaDebugHelper.OnLuaFileHotUpdate)
        end
    else
        --首先检测是否值更新函数开关
        if Logic_Hot_UpdateModify then
            local filetext = sandbox.ReadFile(Logic_Hot_UpdateModify.filename);
            HotUpdateSystem.CheckOnlyHotUpdateFunc(filetext)
        end
        for path, node in pairs(ChangeFiles) do
          --log("reload " .. path);
            HotUpdateSystem.try_load(node);
        end
    end
    local t2 = os.clock();
    --print("HotUpdateSystem：热更新花费时间= " .. (t2 - t1))
end

function HotUpdateSystem.ReadFuncs(Codes)
    local CodeLines = {}
    local StartLine = 1
    for i = 1, string.len(Codes) do
        if string.sub(Codes, i, i) == "\n" or string.len(Codes) == i then
            table.insert(CodeLines, string.sub(Codes, StartLine, i))
            StartLine = i + 1
        end
    end
    
    
    local functionCodes = {} --函数代码
    local functionLines = {} --函数代码行
    local functionName = ""
    local functionContent = ""
    for i,v in ipairs(CodeLines) do
        if string.sub(v, 1, 8) == "function" then
            local startIndex,endIndex,subStr = string.find(v, "function%s+(%S+)%s*%(", 1)
            if subStr then
                functionName = subStr
                functionContent = ""

                functionLines[functionName] = i
            end
        end
        
        if functionName ~= "" then 
            functionContent = functionContent .. v
        end
        
        if string.sub(v, 1, 3) == "end" then
            functionCodes[functionName] = functionContent
            functionName = ""
            functionContent = ""
        end
    end
    
    return functionCodes,functionLines
end

function HotUpdateSystem.ResetEvent(oldFunc, newFunc)
    for i, listEventID in pairs(EventSystem.mapEvents) do
        for j, listProcessor in pairs(listEventID) do
            for j, func in ipairs(listProcessor) do
                if oldFunc  == func then
                    listProcessor[j] = newFunc
                end
            end
        end
    end
end

--	local timer = {timePoint = timePoint, offset = timeOffset, func = callfunc, loop = loop, bLimitDeltaTime = bLimitDeltaTime}
function HotUpdateSystem.ResetTimer(oldFunc, newFunc)
    for index, timer in pairs(Timer._list) do
        if timer.func  == oldFunc then
            timer.func  = newFunc
        end
    end
end

function HotUpdateSystem.Resets2c(oldFunc, newFunc)
    for name, func in pairs(s2c) do
        if oldFunc  == func then
            s2c[name] = newFunc
        end
    end
end

function HotUpdateSystem.GetFunc(funcName)
    local startIndex = 1
    local currTable = _G
    local len = string.len(funcName)

    --log_tree("HotUpdateSystem.GetFunc 1:" , funcName, "test")
    for i = 1, len do
        local currChar = string.sub(funcName, i, i)
        if currChar == "."  or currChar == ":" or i == len then

            --log_tree("HotUpdateSystem.GetFunc: currChar" , currChar, "test")
            local last = i - 1
            if i == len then
                last = i
            end
            currTable = currTable[string.sub(funcName, startIndex, last)]

            --log_tree("HotUpdateSystem.GetFunc 2:" , currTable, "test")
            if not currTable then
                return
            else
                startIndex = i + 1
            end
        end
    end

    if type(currTable) == "function" then
        return currTable
    end
    return
end

function HotUpdateSystem.rfind(str, k)
    local ts = string.reverse(str)--//反转字符串str
    local _, i = string.find(ts, k)--//获取k在反转后的str字符串ts的位置
    return string.len(ts) - i + 1--//获取k在字符串str中的位置
end

function HotUpdateSystem.OnlyReloadFunc(node, filetext)
    local funcs = HotUpdateSystem.ReadFuncs(filetext)
    
    local isFuncDiff = false

    --log("HotUpdateSystem.OnlyReloadFunc:" .. node.filename)
    
    for funcName,funcContent in pairs(funcs) do
        --log("HotUpdateSystem.OnlyReloadFunc:" .. funcName .. "," .. tostring(node.funcs[funcName] ~= funcContent) )
        if node.funcs[funcName] ~= funcContent then
            --保存原函数上值
            local upvalues = {}
            local name,val = nil, nil
            local index = 1

            local oldFunc = HotUpdateSystem.GetFunc(funcName)
            local upvalueContent = ""
            local lineNo = 0
            if oldFunc then
                --log(funcName .. ":" .. tostring(oldFunc))
                repeat
                    name, val = debug.getupvalue(oldFunc, index)
                    if name then
                        --log(name)
                        upvalues[name] = index
                        --创造上值
                        if name ~= "_ENV" then
                            upvalueContent = upvalueContent .. "local " .. tostring(name) .. " =  _G[" .. tostring(name) .. "] \n"
                            lineNo = lineNo + 1
                        end
                        index = index + 1
                    end
                until not name
            end
            
            --模拟相同的函数
            local targetLine = node.functionLines and node.functionLines[funcName] or nil
            if targetLine and lineNo <= targetLine - 1 then
                local strTb = {}
                for i = 1, targetLine - 1 - lineNo do
                    table.insert(strTb, "\n")
                end
                upvalueContent = upvalueContent .. table.concat(strTb)
            end
            
            local luaSourceDir = LuaDebugHelper.GetLuaSourceDir();
            local trunk, msg = load(upvalueContent .. funcContent, string.sub(node.filename, string.len(luaSourceDir) + 2));--, "bt", node.env);
            if not trunk then
                sandbox.LogError(string.format("load file: %s ... ... [failed]", node.filename));
                sandbox.LogError(msg);
                return;
            end
            
            local ok, err = pcall(trunk);
            if not ok then
                sandbox.LogError(string.format("exec file: %s ... ... [failed]", node.filename));
                sandbox.LogError(err);
                return;
            end

            local newFunc = HotUpdateSystem.GetFunc(funcName)
            if not newFunc then
                sandbox.LogError("load file: %s ... ...  = nil", funcName)
                return
            end


            if oldFunc then
                index = 1
                while true do
                    local name = debug.getupvalue(newFunc, index)
                    if name == nil then
                        break
                    end
                    --local local_value = local_id[name]
                    --if local_value then
                    --    debug.setupvalue(func, i, local_value)
                    --end
                    local upvalue_id = upvalues[name]
                    if upvalue_id then
                        debug.upvaluejoin(newFunc, index, oldFunc, upvalue_id)
                    end
                    index = index + 1
                end

                HotUpdateSystem.ResetEvent(oldFunc, newFunc)

                HotUpdateSystem.Resets2c(oldFunc, newFunc)

                HotUpdateSystem.ResetTimer(oldFunc, newFunc)
            end


            local startPos = HotUpdateSystem.rfind(node.filename, "/")
            local fileName = ""
            if startPos then
                fileName = string.sub(node.filename, startPos + 1, -5)
            end

            if funcName ~= fileName .. "__Hot__" then
                --以__Hot__ 为结尾表示此函数改变后，会执行此函数
                if string.ends(funcName, "__Hot__") or HotUpdateRunFuntion[funcName] then
                    local ok, err = pcall(newFunc)
                    if not ok then
                        sandbox.LogError(string.format("exec func: %s ... ... [failed]", funcName));
                        sandbox.LogError(err);
                    end
                elseif _G[funcName .. "__Hot__"] then
                    local ok, err = pcall(_G[funcName .. "__Hot__"])
                    if not ok then
                        sandbox.LogError(string.format("exec func: %s ... ... [failed]", funcName .. "__Hot__"));
                        sandbox.LogError(err);
                    end
                end

            end
     
            sandbox.LogNormal(string.format("load file: %s ... ... [ok]", node.filename));
            
            sandbox.LogNormal(string.format("load function: %s ... ... [ok]", funcName));

            --对文件中函数的热更新
            if _G[fileName .. "__Hot__"] then
                local ok, err = pcall(_G[fileName .. "__Hot__"], funcName)
                if not ok then
                    sandbox.LogError(string.format("exec func: %s ... ... [failed]", funcName .. "__Hot__"));
                    sandbox.LogError(err);
                end
            end
            
            isFuncDiff = true
        end
    end

    if isFuncDiff then
        node.funcs = funcs
        LuaDebugHelper.OnLuaFileHotUpdate("LuaHotUpdate: "..node.filename)
    end
end

function HotUpdateSystem.ReloadFile(node, filetext)
    local trunk, msg = load(filetext, node.filename);--, "bt", node.env);
    --log("HotUpdateSystem.ReloadFile:" .. node.filename)

    if not trunk then
        sandbox.LogError(string.format("load file: %s ... ... [failed]", node.filename));
        sandbox.LogError(msg);
        return;
    end

    local ok, err = pcall(trunk);
    if not ok then
        sandbox.LogError(string.format("exec file: %s ... ... [failed]", node.filename));
        sandbox.LogError(err);
        return;
    end

    sandbox.LogNormal(string.format("load file: %s ... ... [ok]", node.filename));

    LuaDebugHelper.OnLuaFileHotUpdate("LuaHotUpdate: "..node.filename);
end

function HotUpdateSystem.try_load(node)
    local filename = node.filename;
    --log("HotUpdateSystem.try_load:" .. filename)

    local filetext = sandbox.ReadFile(filename);
    if not filetext then
        sandbox.LogError(string.format("failed to read file: %s", filename));
        return;
    end

    if HotUpdateSystem.OnlyHotUpdateFunc then
        local IsAlwaysHotUpdateWhole = false
        for i, v in ipairs(AlwaysHotUpdateWholeFiles) do
            if string.find(node.filename, v, 1) then
                IsAlwaysHotUpdateWhole = true
            end
        end
        if IsAlwaysHotUpdateWhole then
            HotUpdateSystem.ReloadFile(node, filetext)
        else
            HotUpdateSystem.OnlyReloadFunc(node, filetext)
        end
    else
        HotUpdateSystem.ReloadFile(node, filetext)
    end
end

function HotUpdateSystem.Tick(DeltaTime)
	--登录后开始检测
	if (HotUpdateSystem.Enable == true and HotUpdateSystem.HasInitHoupdate == true) then
        if  HotUpdateSystem.TickEnable == true or HotUpdateSystem.IsThisApplicationForeground then
            HotUpdateSystem.Timer = HotUpdateSystem.Timer + DeltaTime;
            if (HotUpdateSystem.Timer >= HotUpdateSystem.TimeLength) then
                HotUpdateSystem.CheckReload();
            end
        end
        
        if HotUpdateSystem.IsThisApplicationForeground ~= LuaDebugHelper.IsThisApplicationForeground() then
            HotUpdateSystem.IsThisApplicationForeground = LuaDebugHelper.IsThisApplicationForeground()
            if HotUpdateSystem.IsThisApplicationForeground then 
                HotUpdateSystem.CheckReload();
            end
        end

        if not HotUpdateSystem.IsThisApplicationForeground then
            if not HotUpdateSystem.hasReadFile then
                HotUpdateSystem.readFileContent()
                HotUpdateSystem.hasReadFile = true
            end
        end
	end
end


