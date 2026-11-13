-- 来源：
-- https://www.cnblogs.com/yaukey/p/unity_lua_memory_leak_trace.html
-- https://blog.codingnow.com/2012/12/lua_snapshot.html

MemoryUtil = MemoryUtil or {
}

local DumpLuaCount = 0
local DumpLuaBaseFileName = ""
-- local DumpLuaDetailFileName = ""
local DumpLuaOneRefFile = ""

local function FormatDateTimeNow()
    local cDateTime = os.date("*t")
    local strDateTime = string.format("%04d%02d%02d-%02d%02d%02d", tostring(cDateTime.year), tostring(cDateTime.month), tostring(cDateTime.day),
        tostring(cDateTime.hour), tostring(cDateTime.min), tostring(cDateTime.sec))
    return strDateTime
end

function MemoryUtil:GetDumpLuaFileName(FileNameExt)
    DumpLuaCount = DumpLuaCount + 1
    local FileName = ""
    if BP_IsInLobby then
        FileNameExt = FileNameExt.."Lobby-"
    else
        FileNameExt = FileNameExt.."Fighting-"
    end
    local timeStr = FormatDateTimeNow()
    FileNameExt = FileNameExt.."-"..timeStr
    FileName = FileNameExt.."-"..tostring(DumpLuaCount)
    return FileName
end

function MemoryUtil:GCBeforeDump()
    collectgarbage("collect")
    collectgarbage("collect")
end

function MemoryUtil.DumpLuaBaseContent(InputContent)
    Client.SaveLuaMemoryFile(DumpLuaBaseFileName, tostring(InputContent), false)
end

function MemoryUtil:DumpLuaBaseMemory()
    log("MemoryUtil:DumpLuaBaseMemory call")
    self:GCBeforeDump()

    DumpLuaBaseFileName = self:GetDumpLuaFileName("LuaMem-All-")

    local MemoryCount = collectgarbage("count")
    local MBMemoryCount = MemoryCount / 1024.0
    local MBMemoryContent = "Memory:"..tostring(MBMemoryCount).."MB \n"

    -- 输入大小，如果存在则删掉
    MemoryUtil.DumpLuaBaseContent(MBMemoryContent)

    -- Client.SaveLuaMemoryRefLine(leakFileName, tostring(k), tostring(v))
    MemoryReferenceInfo.m_cMethods.DumpMemorySnapshot("", "", -1, nil, nil, MemoryUtil.DumpLuaBaseContent);
end


-- function MemoryUtil:DumpLuaDetailMemoryRefs()
--     log("MemoryUtil:DumpLuaDetailMemoryRefs call")
--     self:GCBeforeDump()

--     local MemoryCount = collectgarbage("count")
--     local MBMemoryCount = MemoryCount / 1024
--     local MBMemoryContent = "Memory:"..MBMemoryCount.."MB \n"

--     self:DumpLuaDetailContent(MBMemoryContent);

--     DumpLuaDetailFileName = self:GetDumpLuaFileName("LuaMemRefObj-Details-All-")
--     MemoryReferenceInfo.m_cMethods.DumpMemorySnapshotDetails("", "", -1, nil, nil, MemoryUtil.DumpLuaDetailContent)
-- end

-- function MemoryUtil.DumpLuaDetailContent(InputContent)
--     Client.SaveLuaMemoryFile(DumpLuaDetailFileName, tostring(InputContent))
-- end

function MemoryUtil.DumpLuaRefContent(InputContent)
    Client.SaveLuaMemoryFile(DumpLuaOneRefFile, tostring(InputContent), false)
end

function MemoryUtil:DumpLuaObjRefFile(value)
    self:GCBeforeDump()

    if value == nil then
        DumpLuaOneRefFile = self:GetDumpLuaFileName("LuaMemRef-All-")
        local snapshot = require("snapshot")
        local gcRefs = snapshot()
        for k,v in pairs(gcRefs) do
            if k ~= nil then
                MemoryUtil.DumpLuaRefContent(tostring(k))
            end
            if v ~= nil then
                 MemoryUtil.DumpLuaRefContent(tostring(v))
            end

            MemoryUtil.DumpLuaRefContent("\n")
        end
    else
        local t = type(value)
        if t == "string" then
            DumpLuaOneRefFile = self:GetDumpLuaFileName("LuaMemRef-String-")
            MemoryReferenceInfo.m_cMethods.DumpMemorySnapshotSingleObject("./", "SingleObjRef-String", -1, "String", value, MemoryUtil.DumpLuaRefContent)
        else
            DumpLuaOneRefFile = self:GetDumpLuaFileName("LuaMemRef-Table-")
            MemoryReferenceInfo.m_cMethods.DumpMemorySnapshotSingleObject("./", "SingleObjRef-Table", -1, "Table", value, MemoryUtil.DumpLuaRefContent)
        end
    end
    
end