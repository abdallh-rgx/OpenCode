local M = {}

local snapshot = require "snapshot"
local snapshotFirst = nil
local leakRecords = {}

local function StringSplit(str, split)
    local lcSubStrTab = {}
	local num = 0
    while true do
        local lcPos = string.find(str,split)
        if not lcPos then
			local str1 = str:match("^%s+(.-)%s+$")
			if str1 ~= nil and str1 ~= "" then
				lcSubStrTab[num] =  str
			end
            break
        end
        local lcSubStr  = string.sub(str,1,lcPos-1)
        lcSubStrTab[num] = lcSubStr
        str = string.sub(str,lcPos+1,#str)
		num = num + 1
    end
    return lcSubStrTab
end

local function WriteLeakInfo(leaks)
	local json_table = {}
	local num = 0
	for k,v in pairs(leaks) do
		if v.num > 1 then
			json_table[num] = {}
			table.insert(json_table[num],{LeakNum = v.num, LeakLine = k:match("(.-)\n$")})
			json_table[num].LeakPaths = {}
			local leakInfo = "Leak! num: "..v.num.."\tline: "..k
			local num1 = 0
			for kk, vv in pairs(v.stack) do
				json_table[num].LeakPaths[num1] = StringSplit(kk,"\n")
				num1 = num1 + 1
				leakInfo = leakInfo..kk.."\n"
			end
			num = num + 1
			print(leakInfo)
		end
    end
    
	local str = json.encode(json_table, { indent = true })
    Client.SaveStringToFile(str, "LeakInfo.json")
end

function M.Snapshot()
    collectgarbage("collect")
    do
        local KismetSystemLibrary = import("KismetSystemLibrary")
        KismetSystemLibrary.CollectGarbage()
    end
    collectgarbage("collect")
    local snapMemory = snapshot()

    if snapshotFirst ~= nil then
        local s1 = snapshotFirst
		local s2 = snapMemory
		for k,v in pairs(s2) do
			if s1[k] == nil then
				--print(type(k), type(v))
				local start, __ = string.find(v, "\n")
				local vKey = v
				if start > 0 then
					vKey = string.sub(vKey, 0, start)
				end
				--print("vKey:", vKey, start)
				if leakRecords[vKey] == nil then
					local memoryInfo = {num = 1, stack = {}}
					memoryInfo.stack[v] = 1
					leakRecords[vKey] = memoryInfo
				else
					leakRecords[vKey].num = leakRecords[vKey].num + 1
					if leakRecords[vKey].stack[v] == nil then
						leakRecords[vKey].stack[v] = 1
					else
						leakRecords[vKey].stack[v] = leakRecords[vKey].stack[v] + 1
					end
				end
			end
        end
        
        WriteLeakInfo(leakRecords)
        leakRecords = {}
    end

    snapshotFirst = snapMemory
    collectgarbage("collect")
    do
        local KismetSystemLibrary = import("KismetSystemLibrary")
        KismetSystemLibrary.CollectGarbage()
    end
    collectgarbage("collect")
end

return M