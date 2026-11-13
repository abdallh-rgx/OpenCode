--[[
Created by stuartwang/wangqing. 3030078087@qq.com
Ver:   1.0.0

API:
    VSCodeLuaDebug.print()
        打印信息到VSCode控制台的Debugger/log中

    VSCodeLuaDebug.BP();
        强制打断点，可以在协程中使用。建议使用以下写法:
        local ret = VSCodeLuaDebug and VSCodeLuaDebug.BP and VSCodeLuaDebug.BP();
        如果成功加入断点ret返回true，否则是nil

    VSCodeLuaDebug.test();
        观察函数，如果需要调试调试器，可以打开launch.json中的DebugMode:true。再在用户空间调用这个函数
        调试时就可以从这里进入调试器，观察内部数据。
        用户可以自行在这个函数中添加代码
]]
local TCPSplitChar = "|*|";                --json协议分隔符，不可修改
--if UseRequire then
--local tools = require("DebugTools");  --必须要进到这个目录下，否则找不到DebugTools 
--require("MemProfiler");                    --引入内存分析模块 
--else    
local tools = DebugTools;
--end

local Platform_Window = string.lower(Client.GetDevicePlatformName()) == "windows";
local Platform_Android = string.lower(Client.GetDevicePlatformName()) == "android";
local Platform_IOS = string.lower(Client.GetDevicePlatformName()) == "ios";

VSCodeLuaDebug = {};
local this = VSCodeLuaDebug;
--json的临时变量
local json = tools.createJson()

--运行状态枚举
local hookState = {
    NO_HOOK = 0,                --断开连接
    LITE_HOOK = 1,               --全局无断点
    MID_HOOK = 2,               --全局有断点，本文件无断点
    ALL_HOOK = 3,               --本文件有断点
};
--运行状态枚举
local runState = {
    WAIT_CMD = 0,       --等待命令
    STOP_ON_ENTRY = 1,   --初始状态
    RUN = 2,
    STEP = 3,
    STEPIN = 4,
    STEPOUT = 5,
    PAUSE = 6,
    HIT_BREAKPOINT = 7
};

local MAX_TIMEOUT_SEC = 3600;
--当前运行状态
local currentStats;
local currentHookState;
--断点信息
local breaks = {};              --保存断点的数组
local recCallbackId = "";
--VSCode端传过来的配置，这里不要赋值，由VSCode端的launch赋值并传过来
local luaFileExtension = "";    --脚本后缀
local cwd = "";                 --工作路径
local DebuggerFileName = "";    --Debugger文件名, 函数中会自动获取
local lastRunFunction = {};     --上一个执行过的函数。在有些复杂场景下(find,getcomponent)一行会挺两次
local debugMode = false;      --是否开启调试模式
local hitBP = false;                --BP()中的强制断点命中标记
local TempFilePath_luaString = ""; --VSCode端配置的临时文件存放路径
local connectHost;              --记录连接端IP
local connectPort;              --记录连接端口号
local sock;                         --tcp socket
--一些标记位
local logLevel = 1;                 --日志等级all/info/error
local variableRefIdx = 1;         --变量索引
local variableRefTab = {};       --变量记录table
local connectStateFlag = false; --连接状态标记位 true:已连接  false:未连接或连接断开 | 收发消息时，如果发现收发失败，则需要重连
local connectStateReason = "";  --连接断开的原因
local lastRunFilePath = "";         --最后执行的文件路径
local inDebugLayer = false;       --debug模式下，调入了Debug层级，用来变量层级展示是判断
local pathCaseSensitivity = true;
--反序裁剪字符串 如:print(subString("a/b/c", "/"))输出c
function this.revSubString(str, k)
    ts = string.reverse(str);
    _, i = string.find(ts, k)
    if i == nil then
        --没找到/
        return str;
    end
    m = string.len(ts) - i + 1
    return string.sub(str, m + 1, str.length)
end

function this.revFindString( str, k )
    -- body
end

function this.setrecCallbackId( id )
    if id ~= nil and  id ~= "0" then
        recCallbackId = tostring(id);
    end
end

function this.getrecCallbackId()
    if recCallbackId == nil then
        recCallbackId = "0";
    end
    local id = recCallbackId;
    recCallbackId = "0";
    return id;
end

--生成平台无关的路径。
--return:nil(error)/path
function this.genUnifiedPath(path)
    if path == "" or path == nil then
        return nil;
    end
    --大小写不敏感时，路径全部转为小写
    if pathCaseSensitivity == false then
        path = string.lower(path);
    end
    --统一路径全部替换成/
    path = string.gsub(path, [[\]], "/");
    --消除路径中的/./
    while string.match(path,"/%./") do
        path = string.gsub(path, "/%./", "/");
    end
    --消除路径中的//
    while string.match(path,"//") do
        path = string.gsub(path, "//", "/");
    end
    --处理 /../
    while string.match(path,"/%w+/%.%./") do
        path = string.gsub(path, "/%w+/%.%./", "/");
    end
    return path;
end

--获取一个消息Table
function this.getMsgTable(cmd ,callbackId)
    callbackId = callbackId or 0;
    local msgTable = {};
    msgTable["cmd"] = cmd;
    msgTable["callbackId"] = callbackId;
    msgTable["info"] = {};
    return msgTable;
end

--发消息
function this.sendMsg( sendTab )
    --如果连接已断开，停止并重建连接
    if connectStateFlag == false then
        this.stop();
        return;
    end

    local sendStr = json.encode(sendTab);
    local succ,err = sock:send(sendStr..TCPSplitChar.."\n");
    if succ == nil then
        if err == "closed" then
            --非超时发送失败，默认是连接关闭，停止并重建连接
            connectStateFlag = false;
            connectStateReason = err;
            this.stop();
        end
    end
end

--获取当前堆栈
function this.getStackTable( level )
    local i = level or 3;
    local stackTab = {};

    repeat
        local info = debug.getinfo(i, "SlLnf")
        if info == nil then
            break;
        end
        if info.source == "=[C]" then
            break;
        end

        local ss = {};
        if Platform_Window then
            ss.file = this.getPath(info);
        elseif Platform_Android then
            ss.file = cwd.."/"..this.getPath(info);
        elseif Platform_IOS then
            ss.file = cwd.."/"..this.getPath(info);
        end
        log("####ss.file="..ss.file);
        ss.name = "文件名"; --这里要做截取
        ss.line = tostring(info.currentline);
        ss.index = tostring(i - 3);

        table.insert(stackTab,ss);
        i = i + 1;
    until info == nil
    return stackTab;
end

--这个方法是根据工程中的cwd和luaFileExtension修改
function this.getPath( info )

    if Platform_Android then
        return this.getFilePathFromSource(info.source);
    end
    if Platform_IOS then
        return this.getFilePathFromSource(info.source);
    end

    local filePath = info.source;
    --判断@
    if filePath:sub(1,1) == '@' then
        filePath = filePath:sub(2);
    end
    --换后缀
    local checkExtension = string.sub(filePath, -6, -1)
    local ExtensionMatchRes = string.find(checkExtension, "%.");
    if ExtensionMatchRes ~= nil then
        --去后缀.这里的完整公式是(-1)*(6 - ExtensionMatchRes + 2)
        filePath = string.sub(filePath, 1 , -6 - 2 + ExtensionMatchRes);
    end
    if luaFileExtension ~= "" then
        filePath = filePath.."."..luaFileExtension;
    end

    -- hogoliu Add Begin
    if Platform_Window then
        local finadFilePath = string.gsub(filePath, "../../../../Survive/Source/Lua", cwd);
        return finadFilePath;
    end  
    -- hogoliu Add End

    --拼路径
    --若在Mac下以/开头，或者在Win下以*:开头，说明是绝对路径，不需要再拼。直接返回
    if filePath:sub(1,1) == [[/]]  then
        return this.genUnifiedPath(filePath);
    end

    if filePath:sub(1,2):match("%a:") then
        return this.genUnifiedPath(filePath);
    end

    --需要拼接
    local retPath = filePath;
    if cwd ~= "" then
        --这里做一次匹配,文件名不能出现符号，否则会匹配错误
        local matchRes = string.match(filePath, cwd);
       if matchRes == nil then
            retPath = cwd.."/"..filePath;--TODO 可能有也可能没有/
        end
        --检查一下是否出现/./
       retPath = this.genUnifiedPath(retPath);
    end    
    return retPath;
end

function this.getFilePathFromSource( source )
    local i, j = string.find( source, "FilePathBegin#");
    local m, n = string.find( source, "#FilePathEnd");  
    if i == nil or j == nil or m == nil or n == nil or j >= m then
        this.print("[error] getFilePathFromSource() Cut file path failed@1");
        this.print(source);
        this.print("====================================================");
        return nil;
    end
    local finalPath = string.sub(source, j + 1, m - 1)

    local p, q = string.find(finalPath, "/Lua/");
    if p == nil or q == nil then
        this.print("[error] getFilePathFromSource() Cut file path failed@2");
        this.print(finalPath);
        this.print("====================================================");
        return nil; 
    end
    finalPath = string.sub(finalPath, q + 1, -1);

    --this.print("###"..finalPath);

    return finalPath; 
end

--参数info是当前堆栈信息
function this.isHitBreakpoint( info )
    local curPath = info.source;
    local curLine = tostring(info.currentline);
    if breaks[curPath] ~= nil then
        for k,v in ipairs(breaks[curPath]) do
            if tostring(v["line"]) == tostring(curLine) then
                return true;
            end
        end
    end
    return false;
end

local callnum = 0;      --step计数器
local stepOutCounter = 0;
-- local jumpCall = false; --call标志位
local jumpRet = false;

function this.sendLuaMemory()
    local luaMem = collectgarbage("count");
    local sendTab = {};
    sendTab["callbackId"] = "0";
    sendTab["cmd"] = "refreshLuaMemory";
    sendTab["info"] = {};
    sendTab["info"]["memInfo"] = tostring(luaMem);
    this.sendMsg(sendTab);
end

--加入断点函数
function this.BP()
    local co = coroutine.running();
    hitBP = true;
    if co ~= nil then
        --协程
        debug.sethook(co, this.debug_hook, "lrc")
    else
        this.changeHookState(hookState.ALL_HOOK);
    end
    return true;
end

--钩子函数
function this.debug_hook(event, line)
    --this.print("-------enter debug_hook------- event:"..event);
    if connectStateFlag == false then
        this.stop();
        return;
    end

    if currentHookState ==  hookState.LITE_HOOK then
        --接收断点，停止等消息
        this.debugger_wait_msg();
        return;
    end
    --重置变量索引
    variableRefTab = {};
    variableRefIdx = 1;
    --调过标记位。
    local jumpFlag = false;
    --运行中
    local info;
    local co = coroutine.running();
    if co ~= nil then
        info = debug.getinfo(co, 2, "SlLnf")
    else
        info = debug.getinfo(2, "SlLnf")
    end

    --各种不处理的情况
    --不打印C函数
    if info.source == "=[C]" then
        --this.print("current method is C");
        return;
    end

    if info.namewhat ~= "method" then
        local v = info.namewhat;
        if v ~= "" and v ~= "global" and v ~= "field" and v ~= "local" and v ~= "upvalue" then --在有些环境下namewhat是空，兼容这些环境
            --this.print("current namewhat not method : "..v);
            jumpFlag = true;
        end
    end

    --[[
    if info.short_src:match("%[string \"")  then
        --兼容 [string "路径""] 的形式，裁剪掉周围的[string ""]
        local stringPath = string.sub(info.source, 10, -3);
        --判断路径尾部和用户设置的后缀相同，如果相同把路径放入info.source
        if string.match(stringPath:sub(#luaFileExtension * (-1),  -1), luaFileExtension)  then
            info.source = stringPath;
        else
        --当做普通string
            local luaString = getStringFromMD5 and getStringFromMD5(tostring(info.source));
            if luaString == nil or luaString == "" then
                jumpFlag = true;
            else
                this.print("[Code Section ".. info.source .. " ]:".. tostring(luaString));
                local filePath = TempFilePath_luaString.. "/" .. info.source.."."..luaFileExtension;
                local file, err = io.open(filePath);
                if file ~= nil then
                    --文件已经存在
                    info.source = filePath;
                    file:close();
                else
                    --文件不存在
                    local file, err = io.open(filePath, "w+");
                    if file ~= nil then
                        file:write(luaString);
                        -- 关闭打开的文件
                        file:close()
                        info.source = filePath;
                    else
                        this.print("file error:"..tostring(err) ,2);
                        jumpFlag = true;
                    end
                end
            end
        end
    end
    --]]

    if jumpFlag == false then
        info.source = this.getPath(info);
        lastRunFilePath = info.source;

        --如果运行在Debugger中，不做处理, 调试中暂时不处理
        local matchRes = string.match(info.source, DebuggerFileName);
        if matchRes ~= nil and debugMode == false then
            jumpFlag = true;
        else
            if matchRes ~= nil then
                inDebugLayer = true;
            else
                inDebugLayer = false;
            end
        end
    end
    --本次执行的函数和上次执行的函数作对比，防止在一行停留两次
    if lastRunFunction["currentline"] == info["currentline"] and lastRunFunction["source"] == info["source"] and lastRunFunction["function"] == info["function"] and lastRunFunction["event"] == event then
        this.print("run twice");
        jumpFlag = true;
    end

    --记录最后一次调用信息
    if jumpFlag == false then
        lastRunFunction = info;
        lastRunFunction["event"] = event;
    end

    --输出函数信息到前台
    if logLevel == 0 then
        local logInfo = event;
        for k,v in pairs(info) do
            logInfo = logInfo .. " | " .. tostring(k).." : "..tostring(v);
        end
        this.print("event:"..tostring(logInfo).." currentStats:"..tostring(currentStats));
    end
    --仅在line时做断点判断。进了断点之后不再进入本次STEP类型的判断，用Aflag做标记
    local Aflag = false;
    if tostring(event) == "line" and jumpFlag == false then
        if currentStats == runState.RUN or currentStats == runState.STEP or currentStats == runState.STEPIN or currentStats == runState.STEPOUT then
            --断点判断
            local ret = this.isHitBreakpoint(info) or hitBP;
            if ret == true then
                this.print("Hit Breakpoint");
                hitBP = false;
                --计数器清0
                callnum = 0;
                stepOutCounter = 0;
                this.changeState(runState.HIT_BREAKPOINT);
                --发消息并等待
                local msgTab = this.getMsgTable("stopOnBreakpoint");
                msgTab["stack"] = this.getStackTable();
                this.sendMsg(msgTab);
                Aflag = true;
                this.debugger_wait_msg();
            end
        end
    end

    if  Aflag == true then
        return;
    end

    if currentStats == runState.STEP then
        -- line callnum!= 0 不作操作
        -- line callnum == 0 停止
        if event == "line" and callnum == 0 and jumpFlag == false then
            local cmdStr = "stopOnStep";
            local msgTab = this.getMsgTable(cmdStr);
            msgTab["stack"] = this.getStackTable();
            this.sendMsg(msgTab);
            this.debugger_wait_msg();
        elseif event == "return" or event == "tail return" then
            if callnum ~= 0 then
                callnum = callnum - 1;
            end
        elseif event == "call" then
            callnum = callnum + 1;
        end
    elseif currentStats == runState.STOP_ON_ENTRY then
        --在Lua入口点处直接停住
        if event == "line" and jumpFlag == false then
            --初始化内存分析的变量
            MemProfiler.getSystemVar();
            --这里要判断一下是Lua的入口点，否则停到
            local cmdStr = "stopOnEntry";
            --取堆栈
            local msgTab = this.getMsgTable(cmdStr);
            msgTab["stack"] = this.getStackTable();
            this.sendMsg(msgTab);
            this.debugger_wait_msg();
        end
    elseif currentStats == runState.STEPIN then
        if event == "line" and jumpFlag == false then
            local cmdStr = "stopOnStepIn";
            local msgTab = this.getMsgTable(cmdStr, this.getrecCallbackId());
            msgTab["stack"] = this.getStackTable();
            this.sendMsg(msgTab);
            this.debugger_wait_msg();
        end
    elseif currentStats == runState.STEPOUT then
        --line 不做操作
        --in 计数器+1
        --out 计数器-1
        if jumpFlag == false then
            if stepOutCounter <= -1 then
                stepOutCounter = 0;
                local cmdStr = "stopOnStepOut";
                local msgTab = this.getMsgTable(cmdStr, this.getrecCallbackId());
                msgTab["stack"] = this.getStackTable();
                this.sendMsg(msgTab);
                this.debugger_wait_msg();
            end
        end

        if event == "return" or event == "tail return" then
            stepOutCounter = stepOutCounter - 1;
        elseif event == "call" then
            stepOutCounter = stepOutCounter + 1;
        end
    elseif currentStats == runState.PAUSE or currentStats == runState.RUN then
        --这里没有做断点判断，所以即使执行C函数也会进入
        this.debugger_wait_msg();
    end

    --在RUN时检查并改变状态
    if currentStats == runState.RUN then
        local fileBP, G_BP =this.checkHasBreakpoint(lastRunFilePath);
        if fileBP == false then
            if G_BP == true then
                this.changeHookState(hookState.MID_HOOK);
            else
                this.changeHookState(hookState.LITE_HOOK);
            end
        else
            this.changeHookState(hookState.ALL_HOOK);
        end

        --MID_HOOK状态下，return需要在下一次hook检查文件（return时，还是当前文件，检查文件时状态无法转换）
        if  event == "return" and currentHookState == hookState.MID_HOOK then
            this.changeHookState(hookState.ALL_HOOK);
        end
    end
end

--检查当前文件中是否有断点
--如果填写参数fileName  返回fileName中有无断点， 全局有无断点
--fileName为空，返回全局是否有断点
function this.checkHasBreakpoint(fileName)
    local hasBk = true;
    --有无全局断点
    if next(breaks) == nil then
        hasBk = false;
    else
        hasBk = true;
    end
    --当前文件中是否有断点
    if fileName ~= nil then
        return breaks[fileName] ~= nil, hasBk;
    else
        return hasBk;
    end
end

--处理 收到的消息
function this.dataProcess( dataStr )
    --this.print("debugger get:"..dataStr);
    local dataTable = json.decode(dataStr);
--    tools.printTable(dataTable, "[Get Msg Tab]");
    if dataTable == nil then
        this.print("[error] Json is error", 2);
        return;
    end

    if dataTable.callbackId ~= "0" then
        this.setrecCallbackId(dataTable.callbackId);
    end

    --按照收到的消息改变状态  TODO 还有一些请求变量的消息
    if dataTable.cmd == "stopOnEntry" then
        this.print("RecMsg=[stopOnEntry]");
        this.changeState(runState.STOP_ON_ENTRY);
    elseif dataTable.cmd == "continue" then
        this.print("RecMsg=[continue]");
        this.changeState(runState.RUN);
        local msgTab = this.getMsgTable("continue", this.getrecCallbackId());
        this.sendMsg(msgTab);

    elseif dataTable.cmd == "stopOnStep" then
        this.print("RecMsg=[stopOnStep]");
        this.changeState(runState.STEP);
        local msgTab = this.getMsgTable("stopOnStep", this.getrecCallbackId());
        this.sendMsg(msgTab);

    elseif dataTable.cmd == "stopOnStepIn" then
        this.print("RecMsg=[stopOnStepIn]");
        this.changeState(runState.STEPIN);
        local msgTab = this.getMsgTable("stopOnStepIn", this.getrecCallbackId());
        this.sendMsg(msgTab);

    elseif dataTable.cmd == "stopOnStepOut" then
        this.print("RecMsg=[stopOnStepOut]");
        this.changeState(runState.STEPOUT);
        local msgTab = this.getMsgTable("stopOnStepOut", this.getrecCallbackId());
        this.sendMsg(msgTab);

    elseif dataTable.cmd == "setBreakPoint" then
        --用数据记录所有断点
        local bkPath = dataTable.info.path;
        bkPath = this.genUnifiedPath(bkPath);
        if Platform_Window then
            breaks[bkPath] = dataTable.info.bks;
        elseif Platform_Android then
            bkPath = string.gsub(bkPath,cwd.."/","");
            breaks[bkPath] = dataTable.info.bks;
        elseif Platform_IOS then
            bkPath = string.gsub(bkPath,cwd.."/","");
            breaks[bkPath] = dataTable.info.bks; 
        end

        for k, v in pairs(breaks) do
            if next(v) == nil then
                breaks[k] = nil;
            end
        end

        -----------------------
        local bkCount  = 0;
        for k, v in pairs(breaks[bkPath]) do
            if next(v) == nil then
                breaks[bkPath][k] = nil;
            end 
            bkCount = bkCount + 1;
        end
        this.print("RecMsg=[setBreakPoint] path:"..tostring(bkPath).."   BreakPointNum="..bkCount);
        -----------------------

        if currentStats ~= runState.STOP_ON_ENTRY then
            local fileBP, G_BP =this.checkHasBreakpoint(lastRunFilePath);
            if fileBP == false then
                if G_BP == true then
                    this.changeHookState(hookState.MID_HOOK);
                else
                    this.changeHookState(hookState.LITE_HOOK);
                end
            else
                this.changeHookState(hookState.ALL_HOOK);
            end
        end
        --tools.printTable(breaks);
        local msgTab = this.getMsgTable("setBreakPoint", this.getrecCallbackId());
        this.sendMsg(msgTab);
        this.debugger_wait_msg();

    elseif dataTable.cmd == "getVariable" then
        --发送变量给游戏，并保持之前的状态,等待再次接收数据
        --dataTable.info.varRef  10000~20000局部变量
        --                       20000~30000全局变量
        --                       30000~     upvalue
        -- 1000~2000结构化局部变量的查询，2000~3000全局，3000~4000upvalue
        local msgTab = this.getMsgTable("getVariable", this.getrecCallbackId());
        local varRefNum = tonumber(dataTable.info.varRef);
        if varRefNum < 10000 then
            --查询变量
            local varTable = this.getVariableRef(dataTable.info.varRef);
            msgTab.info = varTable;
        elseif varRefNum >= 10000 and varRefNum < 20000 then
            --局部变量
            local varTable = this.getVariable();
            msgTab.info = varTable;
        elseif varRefNum >= 20000 and varRefNum < 30000 then
            --全局变量
            local varTable = this.getGlobalVariable();
            msgTab.info = varTable;
        elseif varRefNum >= 30000 then
            --upValue
            local varTable = this.getUpValueVariable();
            msgTab.info = varTable;
        end
        this.sendMsg(msgTab);
        this.debugger_wait_msg();
    elseif dataTable.cmd == "initSuccess" then
        --初始化会传过来一些变量，这里记录这些变量
        this.print("RecMsg=[initSuccess]===");
        this.print("#luaFileExtension="..dataTable.info.luaFileExtension)
        this.print("#TempFilePath="..dataTable.info.TempFilePath)
        this.print("#cwd="..dataTable.info.cwd)
        this.print("=====================");

        luaFileExtension = dataTable.info.luaFileExtension
        local TempFilePath = dataTable.info.TempFilePath;
        if TempFilePath:sub(-1, -1) == [[\]] or TempFilePath:sub(-1, -1) == [[/]] then
            TempFilePath = TempFilePath:sub(1, -2);
        end

        TempFilePath_luaString = TempFilePath;
        TempFilePath_memProfiler = TempFilePath;

        MemProfiler.LogFileWritePath = TempFilePath_memProfiler;
        cwd = this.genUnifiedPath(dataTable.info.cwd);
        logLevel = tonumber(dataTable.info.logLevel) or 1;
        if  tostring(dataTable.info.debugMode) == "true" then
            debugMode =  true;
        else
            debugMode =  false;
        end

        if  tostring(dataTable.info.pathCaseSensitivity) == "false" then
            pathCaseSensitivity =  false;
        else
            pathCaseSensitivity =  true;
        end
        print("pathCaseSensitivity "..tostring(pathCaseSensitivity));
        --设置是否stopOnEntry
        if dataTable.info.stopOnEntry == "true" then
            this.changeState(runState.STOP_ON_ENTRY);
        else
            this.changeState(runState.RUN);
        end
        local msgTab = this.getMsgTable("initSuccess", this.getrecCallbackId());
        this.sendMsg(msgTab);
    elseif dataTable.cmd == "getWatchedVariable" then
        local wv =  this.getWatchedVariable(dataTable.info.varName);
        local msgTab = this.getMsgTable("getWatchedVariable", this.getrecCallbackId());
        if wv ~= nil then
            msgTab.info = wv;
        end
        this.sendMsg(msgTab);
        this.debugger_wait_msg();
    elseif dataTable.cmd == "stopRun" then
        --停止hook，已不在处理任何断点信息，也就不会产生日志等。发送消息后等待前端主动断开连接
        local msgTab = this.getMsgTable("stopRun", this.getrecCallbackId());
        this.sendMsg(msgTab);
        connectStateReason = "User Close";
        this.stop();
    elseif "MemProfilerStart" == dataTable.cmd then
        MemProfiler.startSnapShot();
        this.debugger_wait_msg();
    elseif "MemProfilerStop" == dataTable.cmd then
        MemProfiler.endSnapShot();
        this.debugger_wait_msg();
    elseif "LuaGarbageCollect" == dataTable.cmd then
        this.print("collect garbage!");
        collectgarbage("collect");
        --回收后刷一下内存
        this.sendLuaMemory();
        this.debugger_wait_msg();
    end


end



--获取当前函数的堆栈层级
function this.getCurrentFunctionStackLevel( ... )
    --print(debug.traceback("===getCurrentFunctionStackLevel Stack trace==="))
    local funclayer = 2;
    repeat
        local info = debug.getinfo(funclayer, "S"); --通过name来判断
        info.source = this.genUnifiedPath(info.source);
        if info ~= nil then
            for k,v in pairs(info) do
                --print(k,v);
                if k == "source" then
                    local matchRes = string.match(v, DebuggerFileName);
                    if matchRes == nil then
                        return (funclayer - 1);
                    else
                        if debugMode == true and inDebugLayer == true  then
                            return (funclayer - 1);
                        end
                    end
                end
            end
        end
        funclayer = funclayer + 1;
    until not info
    return 0;
end

--检查当前堆栈是否是Lua
function checkCurrentLayerisLua( checkLayer )
    local info = debug.getinfo(checkLayer, "S");
    if info == nil then
        return false;
    end

    info.source = this.genUnifiedPath(info.source);

    if info ~= nil then
        for k,v in pairs(info) do
            if k == "what" then
                if v == "C" then
                    return false;
                else
                    return true;
                end
            end
        end
    end
    return false;
end

function this.stringSplit( str, reps)
    local resultStrList = {}
    string.gsub(str,'[^'..reps..']+',function ( w )
        table.insert(resultStrList,w)
    end)
    return resultStrList
end

--用tableVarName作为key去查逐层级查找realVar是否匹配
function  this.findTableVar( tableVarName,  realVar)
    -- body
    if type(tableVarName) ~= "table" or type(realVar) ~= "table" then
        return nil;
    end

    local layer = 2;
    local curVar = realVar;
    local jumpOutFlag = false;
    repeat
        if tableVarName[layer] ~= nil then
            --这里优先展示数字key，比如a{"1" = "aa", [1] = "bb"} 会展示[1]的值
            local tmpCurVar = nil;
            xpcall(function() tmpCurVar = curVar[tonumber(tableVarName[layer])]; end , function() tmpCurVar = nil end );
            if tmpCurVar == nil then
                xpcall(function() curVar = curVar[tostring(tableVarName[layer])]; end , function() curVar = nil end );
            else
                curVar = tmpCurVar;
            end
            layer = layer + 1;
            if curVar == nil then
                return nil;
            end
        else
            --找到
            jumpOutFlag = true;
        end
    until(jumpOutFlag == true)
    return curVar;
end

--被观察的变量
--local（local要逐级查找）,  global的顺序查找 | 这里不再需要查询upvalue，因为upvalue属于local逐级查询的一部分
function this.getWatchedVariable( varName )
    if tostring(varName) == nil or tostring(varName) == "" then
        return nil;
    end
    --orgname 记录原名字
    local orgname = varName;
    --支持a.b.c形式。切割varName
    local tableVarName = {};
    if varName:match('%.') then
        tableVarName = this.stringSplit(varName , '%.');
        if type(tableVarName) ~= "table" or #tableVarName < 1 then
            return nil;
        end
        varName = tableVarName[1];
    end

    --用来返回，带有查到变量的table
    local varTab = {};
    local ly = this.getCurrentFunctionStackLevel();
    --从当前层级向上遍历
    repeat
        local layerVarTab = this.getVariable( ly + 1 );
        for i,realVar in ipairs(layerVarTab) do
            if realVar.name == varName then
                --print("findout ".. varName);
                if #tableVarName > 0 and type(realVar) == "table" then
                    local findRes = this.findTableVar(tableVarName,  variableRefTab[realVar.variablesReference]);
                    if findRes ~= nil then
                        --命中，重建结构并返给前台
                        local var = {};
                        var.name = orgname;
                        var.type = tostring(type(findRes));

                        xpcall(function() var.value = tostring(findRes) end , function() var.value = "[value can't trans to string]" end );

                        var.variablesReference = "0";  --这个地方必须用“0”， 以免variableRefTab[0]出错
                        if var.type == "table" or var.type == "function" then
                            var.variablesReference = variableRefIdx;
                            variableRefTab[variableRefIdx] = findRes;
                            variableRefIdx = variableRefIdx + 1;
                        end
                        table.insert(varTab, var);
                        --添加释放监控
                        this.setGCMonitor(findRes , orgname);
                        return varTab;
                    else
                        --继续查找
                    end
                else
                    --命中，返回给前台
                    --print("findout no table".. varName .."o ."..orgname);

                    table.insert(varTab, realVar);
                    this.setGCMonitor(variableRefTab[realVar.variablesReference] , realVar.name);
                    return varTab;
                end
            end
        end
        --查询upvalue。目前只查询当前函数的upvalue
        local upTable = this.getUpValueVariable();
        for i,realVar in ipairs(upTable) do
            if realVar.name == varName then
                --print("findout ".. varName);
                if #tableVarName > 0 and type(realVar) == "table" then
                    local findRes = this.findTableVar(tableVarName,  variableRefTab[realVar.variablesReference]);
                    if findRes ~= nil then
                        --命中，重建结构并返给前台
                        local var = {};
                        var.name = orgname;
                        var.type = tostring(type(findRes));

                        xpcall(function() var.value = tostring(findRes) end , function() var.value = "[value can't trans to string]" end );

                        var.variablesReference = "0";  --这个地方必须用“0”， 以免variableRefTab[0]出错
                        if var.type == "table" or var.type == "function" then
                            var.variablesReference = variableRefIdx;
                            variableRefTab[variableRefIdx] = findRes;
                            variableRefIdx = variableRefIdx + 1;
                        end
                        table.insert(varTab, var);
                        --添加释放监控
                        this.setGCMonitor(findRes , orgname);
                        return varTab;
                    else
                        --继续查找
                    end
                else
                    --命中，返回给前台
                    --print("findout no table".. varName .."o ."..orgname);

                    table.insert(varTab, realVar);
                    this.setGCMonitor(variableRefTab[realVar.variablesReference] , realVar.name);
                    return varTab;
                end
            end
        end
        ly = ly + 1;
    until not checkCurrentLayerisLua(ly + 1)
    --没有找到，在全局变量_G中查找
    if _G[varName] ~= nil then
        --命中
        if #tableVarName > 0 and type(_G[varName]) == "table" then
        local findRes = this.findTableVar(tableVarName,  _G[varName]);
            if findRes ~= nil then
                local var = {};
                var.name = orgname;
                var.type = tostring(type(findRes));
                xpcall(function() var.value = tostring(findRes) end , function() var.value = "[value can't trans to string]" end );
                var.variablesReference = "0";
                if var.type == "table" or var.type == "function" then
                    var.variablesReference = variableRefIdx;
                    variableRefTab[variableRefIdx] = findRes;
                    variableRefIdx = variableRefIdx + 1;
                end
                table.insert(varTab, var);
                --添加释放监控
                this.setGCMonitor(findRes , orgname);
            end
        else
            local var = {};
            var.name = varName;
            var.type = tostring(type(_G[varName]));
            xpcall(function() var.value = tostring(_G[varName]) end , function() var.value = "[value can't trans to string]" end );
            var.variablesReference = "0";
            if var.type == "table" or var.type == "function" then
                var.variablesReference = variableRefIdx;
                variableRefTab[variableRefIdx] = _G[varName];
                variableRefIdx = variableRefIdx + 1;
            end
            table.insert(varTab, var);
            this.setGCMonitor(_G[varName] , varName);
        end
    end
    return varTab;
end

function this.getVariableRef( refStr )
    local varRef = tonumber(refStr);
    local varTab = {};

    if tostring(type(variableRefTab[varRef])) == "table" then
        for n,v in pairs(variableRefTab[varRef]) do
            if tostring(n) ==  "setGCMonitor" and type(v) == "userdata" and debugMode == false then
                --正式环境 不展示setGCMonitor;
            else
                local var = {};
                var.name = tostring(n);
                var.type = tostring(type(v));
                xpcall(function() var.value = tostring(v) end , function() var.value = "[value can't trans to string]" end );
                var.variablesReference = "0";
                if var.type == "table" or var.type == "function" then
                    var.variablesReference = variableRefIdx;
                    --variableRefTab[variableRefIdx] = {};
                    variableRefTab[variableRefIdx] = v;
                    variableRefIdx = variableRefIdx + 1;
                end
                table.insert(varTab, var);
            end
        end
        --获取一下mtTable
        local mtTab = getmetatable(variableRefTab[varRef]);
        if mtTab ~= nil and type(mtTab) == "table" then
            local var = {};
            var.name = "_Metatable_";
            var.type = tostring(type(mtTab));
            xpcall(function() var.value = "元表 "..tostring(mtTab); end , function() var.value = "元表 [value can't trans to string]" end );
            var.variablesReference = variableRefIdx;
            variableRefTab[variableRefIdx] = mtTab;
            variableRefIdx = variableRefIdx + 1;
            table.insert(varTab, var);
        end
    elseif tostring(type(variableRefTab[varRef])) == "function" then
        --取upvalue
        varTab = this.getUpValueVariable(variableRefTab[varRef]);
    elseif tostring(type(variableRefTab[varRef])) == "userdata" then
        --取mt table
        local udMtTable = getmetatable(variableRefTab[varRef]);
        if udMtTable ~= nil and type(udMtTable) == "table" then
            local var = {};
            var.name = "_Metatable_";
            var.type = tostring(type(udMtTable));
            xpcall(function() var.value = "元表 "..tostring(udMtTable); end , function() var.value = "元表 [value can't trans to string]" end );
            var.variablesReference = variableRefIdx;
            variableRefTab[variableRefIdx] = udMtTable;
            variableRefIdx = variableRefIdx + 1;
            table.insert(varTab, var);
        end
    end
    return varTab;
end

--获取全局变量。方法和内存管理中获取全局变量的方法一样
function this.getGlobalVariable( ... )
    --成本比较高，这里只能遍历_G中的所有变量，并去除系统变量，再返回给客户端
    local varTab = {};
    for k,v in pairs(_G) do
        local var = {};
        var.name = tostring(k);
        var.type = tostring(type(v));
        xpcall(function() var.value = tostring(v) end , function() var.value = "[value can't trans to string]" end );
        var.variablesReference = "0";
        if var.type == "table" or var.type == "function" then
            var.variablesReference = variableRefIdx;
            variableRefTab[variableRefIdx] = v;
            variableRefIdx = variableRefIdx + 1;
        end
        table.insert(varTab, var);
    end
    return varTab;
end

--获取upValues
function this.getUpValueVariable( checkFunc )
    --通过Debug获取当前函数的Func
    checkFunc = checkFunc or lastRunFunction.func;
    local varTab = {};
    local i = 1
    repeat
        local n, v = debug.getupvalue(checkFunc, i)
        if n then

        local var = {};
        var.name = n;
        var.type = tostring(type(v));
        xpcall(function() var.value = tostring(v) end , function() var.value = "[value can't trans to string]" end );
        var.variablesReference = "0";
        if var.type == "table" or var.type == "function" then
            var.variablesReference = variableRefIdx;
            --variableRefTab[variableRefIdx] = {};
            variableRefTab[variableRefIdx] = v;
            variableRefIdx = variableRefIdx + 1;
        end
        table.insert(varTab, var);
        i = i + 1
        end
    until not n
    return varTab;
end

--获取局部变量 checkLayer是要查询的层级，如果不设置则查询当前层级
function this.getVariable( checkLayer )
    local ly = checkLayer or this.getCurrentFunctionStackLevel();
    if ly == 0 then
        this.print("[error]获取层次失败！", 2);
        return;
    end
    local varTab = {};
    local stacklayer = ly;
    --print("stacklayer"..stacklayer);
    local k = 1;
    repeat
        local n, v = debug.getlocal(stacklayer, k)
        if n == nil then
            break;
        end
        --print(n, v);
        --(*temporary)是系统变量，过滤掉
        if "(*temporary)" ~= tostring(n) then
            local var = {};
            var.name = n;
            var.type = tostring(type(v));
            xpcall(function() var.value = tostring(v) end , function() var.value = "[value can't trans to string]" end );
            var.variablesReference = "0";
            if var.type == "table" or var.type == "function" or var.type == "userdata" then
                var.variablesReference = variableRefIdx;
                --variableRefTab[variableRefIdx] = {};
                variableRefTab[variableRefIdx] = v;
                variableRefIdx = variableRefIdx + 1;
            end
            table.insert(varTab, var);
        end
        k = k + 1
    until n == nil
    return varTab;
end

local recvMsgQueue = {};  --接收的消息队列
--接收消息
--这里维护一个队列
function this.receiveMessage( timeoutSec )
    timeoutSec = timeoutSec or MAX_TIMEOUT_SEC;
    sock:settimeout(timeoutSec);
    --如果队列中还有消息，直接取出来交给dataProcess处理
    if #recvMsgQueue > 0 then
        local saved_cmd = recvMsgQueue[1];
        table.remove(recvMsgQueue, 1);
        this.dataProcess(saved_cmd);
        return true;
    end

    if connectStateFlag == false then
        this.stop();
        return false; 
    end

    local response, err = sock:receive();
    if response == nil then
        if err == "closed" then
            print("[error]接收信息失败 .. reason:"..err);
            connectStateFlag = false;
            connectStateReason = err;
            this.stop();
        end
        return false;
    else
        --print("[get Msg]"..response);
        --判断是否是一条消息，分拆
        local proc_response = string.sub(response, 1, -1 * (TCPSplitChar:len() + 1 ));
        local match_res = string.find(proc_response, TCPSplitChar);
        if match_res == nil then
            --单条
            this.dataProcess(proc_response);
        else
            --有粘包
            repeat
                --待处理命令
                local str1 = string.sub(proc_response, 1, match_res - 1);
                table.insert(recvMsgQueue, str1);
                --剩余匹配
                local str2 = string.sub(proc_response, match_res + TCPSplitChar:len() , -1);
                match_res = string.find(str2, TCPSplitChar);
            until not match_res
            this.receiveMessage();
        end
        return true;
    end
    return false;
end

--这里不用循环，在外面处理完消息会在调用回来
function this.debugger_wait_msg(...)
    if currentStats == runState.WAIT_CMD then
        --print("currentStats == runState.WAIT_CMD");
        local ret = this.receiveMessage(10);
        return ret;
    end

    if currentStats == runState.STOP_ON_ENTRY or currentStats == runState.STEP or currentStats == runState.STEPIN or currentStats == runState.STEPOUT then
        this.sendLuaMemory();
        this.receiveMessage();
        return
    end

    if currentStats == runState.HIT_BREAKPOINT then
        this.sendLuaMemory();
        this.receiveMessage();
        return;
    end

    if currentStats == runState.RUN then
        --非阻塞
        this.receiveMessage(0);
        return;
    end
end

--把日志打印在VSCode端
--printLevel: all(0)/info(1)/error(2)
function this.print(str, printLevel)
    log("[LuaDebugger]==> "..str);
    printLevel = printLevel or 0;
    if logLevel > printLevel then
        return;
    end

    local sendTab = {};
    sendTab["callbackId"] = "0";
    sendTab["cmd"] = "log";
    sendTab["info"] = {};
    sendTab["info"]["logInfo"] = tostring(str);
    this.sendMsg(sendTab);
end

function this.VSCTip(str, printLevel)
    printLevel = printLevel or 0;
    if logLevel > printLevel then
        return;
    end

    local sendTab = {};
    sendTab["callbackId"] = "0";
    sendTab["cmd"] = "tip";
    sendTab["info"] = {};
    sendTab["info"]["tipInfo"] = tostring(str);
    this.sendMsg(sendTab);
end

function this.stop()
    this.changeHookState( hookState.NO_HOOK );
    connectStateFlag  = false;
    --在断开连接以后，要重新启动socket
    if sock ~= nil then
        sock:close();
    end
    this.reGetSock();
    this.attachModeConnecting();
end

--刷新sock
function this.reGetSock()
    sock = lua_extension and lua_extension.luasocket and lua_extension.luasocket().tcp();
    if sock == nil then
        --if UseRequire then
        --pcall(function() sock =  require("socket.core").tcp(); end);
        --else
        pcall(function() sock =  socket.tcp(); end);
        --end
        if sock == nil then
            this.print("[error]reGetSock() sock is nil");
        end
    end
end

--仅在存在LuaTimer.Add的函数中使用attach
function this.attachModeConnecting()
    --如果没有检测到sock, 不再继续
    if sock == nil then
        this.print("[error]Can not find luasocket");
        return;
    end
    if LuaTimer ~= nil and LuaTimer.Add ~= nil then
        sock:settimeout(0.03);
        LuaTimer.Add(1000, 1000, function()
            sockSuccess = sock and sock:connect(connectHost, connectPort);
            if sockSuccess ~= nil then
                --连接成功
                connectStateFlag  = true;
                connectStateReason = "";
                this.connectSuccess();
                return false;
            else
                --等待连接
                return true;
            end
            return true
        end)
    end;
end

function this.start(host, port)
    this.print("start()");
    if sock ~= nil then
        this.print("[Warning]调试器已经启动，请不要再次调用start()");
        return;
    end
    this.reGetSock();
    --launch首次连接
    connectHost = tostring(host);
    connectPort = tonumber(port);
    --------------------------------------------
    --sockSuccess = sock and sock:connect(connectHost, connectPort);
    local errorStr;
    if sock ~= nil then
        sockSuccess, errorStr = sock:connect(connectHost, connectPort);
    else 
        sockSuccess = nil;
    end
    if errorStr ~= nil then
        this.print("[error]start(), Socket connent error :"..errorStr);
    end
    --------------------------------------------
    if sockSuccess ~= nil then
        --连接成功
        this.connectSuccess();
    else
        --等待连接
        this.print("[error]start(), Socket connent failed, wait connent");
        this.attachModeConnecting()
    end
end

--启动调试
function this.connectSuccess(host, port)
    connectStateFlag = true;
    connectStateReason = "";

    if Platform_Window then
        --自动获取文件名
        if DebuggerFileName == "" then
            local info = debug.getinfo(1, "S")
            for k,v in pairs(info) do
                if k == "source" then
                    DebuggerFileName = this.revSubString((this.genUnifiedPath(v)), "/")
                end
            end
        end 
    elseif Platform_Android then
        if DebuggerFileName == "" then
            local info = debug.getinfo(1, "S")
            for k,v in pairs(info) do
                if k == "source" then
                    local filePath = this.getFilePathFromSource(v);
                    DebuggerFileName = this.revSubString((this.genUnifiedPath(filePath)), "/")
                end
            end
        end   
    elseif Platform_IOS then
        if DebuggerFileName == "" then
            local info = debug.getinfo(1, "S")
            for k,v in pairs(info) do
                if k == "source" then
                    local filePath = this.getFilePathFromSource(v);
                    DebuggerFileName = this.revSubString((this.genUnifiedPath(filePath)), "/")
                end
            end
        end  
    end

    --设置初始状态
    this.print("connectSuccess(), Connect success");
    this.changeState(runState.WAIT_CMD);
    local ret = this.debugger_wait_msg();
    if ret == false then
        this.print("[error] 初始化未完成", 2);
        return;
    end
    this.print("初始化完成")

    this.changeHookState(hookState.ALL_HOOK);
    --协程调试
    if type(coroutine.create) == "function" then
        local coroutineCreate = coroutine.create;
        coroutine.create = function(...)
            local co =  coroutineCreate(...)
            debug.sethook(co, this.debug_hook, "lrc")
            return co;
        end
    end
end

--内部函数
--状态机，状态变更
function this.changeState( s )
    currentStats = s;
end

--hook状态改变
function this.changeHookState( s )
    if currentHookState == s then
        return;
    end

    if s ~= hookState.NO_HOOK then
        --this.print("change hook state to "..s)
    end

    currentHookState = s;
    if s == hookState.NO_HOOK then
        debug.sethook();
    elseif s == hookState.LITE_HOOK then
        debug.sethook(this.debug_hook, "rc");
    elseif s == hookState.MID_HOOK then
        debug.sethook(this.debug_hook, "rc");
    elseif s == hookState.ALL_HOOK then
        debug.sethook(this.debug_hook, "lrc");
    end
end

--gc监控回调
function this.gcCallback(varName, varType)

    --print(debug.traceback("Stack trace"))
    --应该加上对本变量是否还在监视中的判断
    --print("Watched Var Reslease: ".. varName .. " [".. varType.."]" );

    this.VSCTip("Watched Var Reslease: ".. varName .. " [".. varType.."]" , 1);
end

-- for Lua5.1
-- 内存追踪相关, 这里可以追踪table和userdata
--TODO 在考虑下这里的调用时机
function this.setGCMonitor(var, name)
    --print("setGCMonitor ".. type(var))
    if type(var) ~= "table" and type(var) ~= "userdata" then
        return;
    end

    if type(var) == "table" then
        if _VERSION == "Lua 5.1" then
            if rawget(var, "setGCMonitor") ~= nil then
                --已有监控
                return;
            end
            --没有监控，添加
            local prox = newproxy(true)
            getmetatable(prox).__gc = function() this.gcCallback(name, type(var)) end;
            rawset(var, "setGCMonitor", prox);
        else
            --5.2， 5.3待验证
            this.print("this.setGCMt: " ..name .." ".. tostring(var) );
            if type(var) == "table" or type(var) == "userdata" then
                local origion_mt = getmetatable(var)

                if origion_mt == nil then
                    --var没有mt
                    this.print("have no mt");
                    local gcmt = {};
                    gcmt.__gc = function() this.gcCallback(name, type(var)); end;
                    setmetatable(var, gcmt);
                else
                    --var已有mt
                    if origion_mt.__gc == nil then
                        --mt中无gc
                        this.print("have  mt no gc");
                        origion_mt.__gc = function() this.gcCallback(name, type(var)); end;
                    elseif origion_mt.__gc ~= nil and type(origion_mt.__gc) == "function" then
                        --mt中有gc
                        this.print("have  mt have gc");
                        local var_org_gc = origion_mt.__gc;
                        origion_mt.__gc = function(...) this.gcCallback(name, type(var)); var_org_gc(...);  end;
                    end
                end
            end
        end
    elseif type(var) == "userdata"  then
        if _VERSION == "Lua 5.1" then
            local mtTab = getmetatable(var);
            --ud 没有mttable, 暂时无法处理 TODO
            if mtTab == nil then
                -- local udmt = { __gc = function() this.gcCallback(name, type(var)) end};
                -- setmetatable(var, udmt);
                return;
            end
            --已有mt
            if rawget(mtTab, "setGCMonitor") ~= nil then
                --已有监控
                return;
            end

            if mtTab.__gc ~= nil and type(mtTab.__gc) == "function" then
                --已有__gc
                local oriGCFunc = mtTab.__gc;
                local newGCFunc = function()
                    rawset(mtTab, "setGCMonitor", true);
                    this.gcCallback(name, type(var));
                    oriGCFunc();
                end
                mtTab.__gc = newGCFunc;
                rawset(mtTab, "setGCMonitor",  true);

            else
                --有mtTab，其中没gc
                mtTab.__gc = function() this.gcCallback(name, type(var)) end;
                rawset(mtTab, "setGCMonitor",  true);

            end
        end
    end
end

function this.test()
    print("这个函数是测试用的，在测试模式下，外部调用这个方法可以进入断点，查看Debug内部数据")
end
--if UseRequire then
--return this;
--end