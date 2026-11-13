--[[
Created by stuartwang/wangqing. 3030078087@qq.com
Ver:   Mem_0.8

API:
    MemProfiler.getSystemVar()
    	获取系统变量，通常放置在Lua函数入口处，只需调用一次。
    MemProfiler.startSnapShot()
    	起始快照
    MemProfiler.endSnapShot()
    	结束快照，并生成分析结果文件
设置项:
	isUseBlackList
		手动编辑黑名单列表. 默认无需修改
	isOutputResToConsole
		把分析结果输出到控制台.默认无需修改
]]

--settings
local isUseBlackList = false;
local isOutputResToConsole = true;
--内部变量
--if UseRequire then
--MemProfiler = {}
--else
MemProfiler = MemProfiler or {}
--end
local this = MemProfiler
local profilerGlobalStartTable = {}
local profilerRegStartTable = {}
local profilerGlobalEndTable = {}
local profilerRegEndTable = {}
local globalOutputTable = {}
local regOutputTable = {}
local recordNewTab = {} 			--实现回溯的table
local compareLookupTable = {}		--记录对比结果
local isInit = false
local timeStr = ""
local resCount = 1 					--计数器.本次运行期间做了几次快照
--if UseRequire then
--local tools = require("DebugTools");
--else
local tools = DebugTools;
--end
this.LogFileWritePath = "";

if isUseBlackList then
	require "MemProfilerBlackList"
end

--序列化
function this.record(t, name, indent)
	local str = (tools.show(t, name, indent))
	return str
end

--写文件
--name 文件名  text 内容
function this.writeFile( name, text )
		if this.LogFileWritePath ~= "" then
			local fileName = "MemProfiler_"..name.."_"..timeStr.."_"..resCount;
			VSCodeLuaDebug.print("LogFileWritePath:"..this.LogFileWritePath.."/"..tostring(fileName), 1);
			local gFile,msg = io.open(this.LogFileWritePath.."/"..tostring(fileName) ,"w");
			if gFile== nil then
				VSCodeLuaDebug.print(msg);
			else
				gFile:write(text);
				io.flush()
				gFile:close();
			end
		else
			--error
		end
end

--init中判断黑名单表是否在
function this.init()
	isInit = true
	print("[MemProfiler][info] init | timeStr:"..timeStr)
	--getTime
	if timeStr == "" or timeStr == nil then
		timeStr = os.date("%Y-%m-%d_%H-%M-%S",os.time())
	end

	if MemProfilerBlackList == nil then
		print("[MemProfiler][Warning] MemProfilerBlackList is nil")
		MemProfilerBlackList = { blackList = {} }
	end
end

--每次序列化之后要做clear
function this.clear()
	profilerGlobalStartTable = {}
	profilerRegStartTable = {}
	profilerGlobalEndTable = {}
	profilerRegEndTable = {}
	compareLookupTable = {}
	globalOutputTable = {}
	regOutputTable = {}
end

function this.getSystemVar()
	print("[MemProfiler][info] getSystemVar")
	if isInit == false then
		this.init()
	else
		print("[MemProfiler][Warning] MemProfiler.getSystemVar has be called more times!")
	end
	--收集regstry和_G中的系统变量
	for k,v in pairs(_G) do
		-- print(k,v)
		table.insert(MemProfilerBlackList.blackList, k)
	end

	for k,v in pairs(debug.getregistry()) do
		-- print(k,v)
		table.insert(MemProfilerBlackList.blackList, k)
	end

end

function this.startSnapShot()
	print("[MemProfiler][info] startSnapShot")
	collectgarbage("collect");
	if isInit == false then
		this.init()
	end
	profilerGlobalStartTable = this.deepcopy(_G)
	profilerRegStartTable = this.deepcopy(debug.getregistry())
end

function this.endSnapShot()
	print("[MemProfiler][info] endSnapShot")
	collectgarbage("collect");
	if next(profilerGlobalStartTable) == nil then
		print("[MemProfiler][Warning] profilerGlobalStartTable is a empty table!")
	end

	profilerGlobalEndTable = this.deepcopy(_G)
	profilerRegEndTable = this.deepcopy(debug.getregistry())
	this.compareTable(profilerGlobalEndTable , profilerGlobalStartTable, true, 0)
	this.compareTable(profilerRegEndTable , profilerRegStartTable, true, 1)
	--序列化和记录
	local globalResInfo = this.record(globalOutputTable)
	local regResInfo = this.record(regOutputTable)
	local info = "_G res is:\n".. globalResInfo ..'\n'.."_Reg res is:\n".. regResInfo ..'\n'
	if isOutputResToConsole then
		print("[MemProfiler][info] result: "..info)
	end
	this.writeFile("log", info)
	this.clear()
	resCount = resCount + 1
end

--table快照
function this.deepcopy(object)
	local lookup_table = {}
    local function _copy(object, first_in)
		if type(object) == "function" then
		    --原先的处理是建立一个新func。这是不合理的，因为这样已经无法判断func本身在profiler的过程中是否改变
			--新的处理方法是使用一个table来记录func的信息，在比对时如果查到这个table的信息就要按照func来处理
	    	local FuncTable = { MemProfilerType = "Luafunction" }
			FuncTable.MemProfilerAddress = object

			if _VERSION == "Lua 5.1" then
				FuncTable.MemProfilerEnv = getfenv(object)
			end

			return FuncTable
		elseif type(object) == "table" then
			if lookup_table[object] then
	    		--这个lookuptable是必要的，一个table被多处引用时如果不用lookUptable,会被创建两份实例的
	        	return lookup_table[object]
	        end

	        local new_table = {}
	        lookup_table[object] = new_table

	        local jumpFlag = false
	        for index, value in pairs(object) do
				if first_in and MemProfilerBlackList.blackList then
					--print("jmp flag true 1")

					for i,x in ipairs(MemProfilerBlackList.blackList) do
						if index == x then
							--调过本次循环
							--print("jmp flag true ".. tostring(x))
							jumpFlag = true
							break
						end
					end
				end

				if jumpFlag == false then
					new_table[_copy(index, false)] = _copy(value, false)
	            else
	            	jumpFlag = false
	            end
	        end

	        local recordMetatable = {}
	        recordMetatable.MemProfilerRecordMetaTable = getmetatable(object)
	        return setmetatable(new_table, recordMetatable)
		else
			return object
		end
	end
    return _copy(object, true)
end


--	递归对比table
--	first_in 是否第一次进入， 仅在首次进入时对比BlackList
--	key_prefix是key前缀，作用是如果新增项在一个已有Table中，能够显示出新增项目的完全路径
--  flag 0:_G  1:reg
function this.compareTable(profiler_end_table , profiler_start_table, first_in, compareFlag, key_prefix)
	--传入的两个变量类型不同，输出返回。如果end是nil，返回。
	if tostring(type(profiler_end_table)) ~= tostring(type(profiler_start_table)) then
		--类型不等，直接输出
		local infoTable = {}
		--追踪路径
		if key_prefix ~= nil and key_prefix ~= "" then
			infoTable["var_name"] = tostring(key_prefix)
		end
		--结束快照的类型
		infoTable["end_type"] = tostring(type(profiler_end_table))
		infoTable["end_value"] = tostring(profiler_end_table)
		infoTable["record_reason"] = "类型改变"
		infoTable["start_type"] = tostring(type(profiler_start_table))
		infoTable["start_value"] = tostring(profiler_start_table)
		-- table.insert(outputTable, infoTable)
		this.insertResToTable(infoTable, compareFlag)
		return
	elseif tostring(type(profiler_end_table)) == "nil" then
		--变量被销毁了
		return
	end

	--此时两个带比对的变量类型一定是相同的，都是table的情况
	if tostring(type(profiler_end_table)) == "table" then
		--循环遍历table profiler_end_table中的每一个key
		local jumpFlag = false
		for k,v in pairs(profiler_end_table) do
			--黑名单处理。首次进入才判断黑名单
			if first_in and MemProfilerBlackList.blackList then
				for i,x in ipairs(MemProfilerBlackList.blackList) do
					if k == x then
						--调过本次循环
						jumpFlag = true
						break
					end
				end
			end
			if jumpFlag == false then
				-- if first_in then
				-- 	print("profiler_end_table key:".. tostring(k))
				-- end
				--是Func的情况（func被记录成了一个table）
				if tostring(type(v)) == "table" then
					if rawget(v, "MemProfilerType") == "Luafunction" then
						local infoTable = {}
						if profiler_start_table[k] == nil then
							infoTable["record_reason"] = "新增function"
							if v.MemProfilerEnv ~= _G then
								infoTable["env"] = tostring(v.MemProfilerEnv)
							else
								infoTable["env"] = "_G"
							end

							infoTable["type"] = "function"
							infoTable["key"] = tostring(k)
							infoTable["value"] = tostring(v.MemProfilerAddress)
							-- upvalue
							infoTable["upValues"] = this.getUpValues(v.MemProfilerAddress)
							-- table.insert(outputTable, infoTable)
							this.insertResToTable(infoTable, compareFlag)
							--[[
						elseif xpcall(
							function()
								return v.MemProfilerEnv ~= profiler_start_table[k].MemProfilerEnv;
							end,function()
								return
							end) then
							--对比env
							infoTable["record_reason"] = "function 环境改变"
							--旧env
							if profiler_start_table[k].MemProfilerEnv == _G then
								infoTable["old_env"] = "_G"
							else
								infoTable["old_env"] = tostring(profiler_start_table[k].MemProfilerEnv)
							end

							if v.MemProfilerEnv == _G then
								infoTable["new_env"] = "_G"
							else
								infoTable["new_env"] = tostring(v.MemProfilerEnv)
							end
							infoTable["type"] = "function"
							infoTable["key"] = tostring(k)
							infoTable["value"] = tostring(v.MemProfilerAddress)
							infoTable["upValues"] = this.getUpValues(v.MemProfilerAddress)
							-- table.insert(outputTable, infoTable)
							this.insertResToTable(infoTable, compareFlag)

						elseif xpcall(function()
							return v.MemProfilerAddress ~= profiler_start_table[k].MemProfilerAddress;
						end, function()
							return
						end) then

							infoTable["record_reason"] = "function 改变"

							infoTable["type"] = "function"
							infoTable["key"] = tostring(k)
							infoTable["old_value"] = tostring(profiler_start_table[k].MemProfilerAddress)
							infoTable["new_value"] = tostring(v.MemProfilerAddress)

							if v.MemProfilerEnv ~= _G then
								infoTable["new_env"] = tostring(v.MemProfilerEnv)
							else
								infoTable["new_env"] = "_G"
							end
							infoTable["upValues"] = this.getUpValues(v.MemProfilerAddress)
							-- table.insert(outputTable, infoTable)
							this.insertResToTable(infoTable, compareFlag)
							]]
						end
						--打印upvalue
						--infoTable["upValues"] = tostring(debug.getupvalue(v.MemProfilerAddress,n))
					--记录新增的项目
					elseif profiler_start_table[k] == nil then   	--增加的key,记录下来
						local infoTable = {}
						if key_prefix == nil then
							infoTable["key"] = tostring(k)
						else
							infoTable["key"] = key_prefix.."."..tostring(k)
						end
						infoTable["value"] = tostring(v)
						infoTable["type"] = tostring(type(v))
						-- infoTable["id"] = tostring(0)
						--如何获取变量内存地址和定义位置
						infoTable["record_reason"] = "新增全局变量"
						if tostring(type(v)) == "table" then
							--新增table，打印一下metatable
							if getmetatable(v) and getmetatable(v).MemProfilerRecordMetaTable ~= nil then
								xpcall(function()
									infoTable["table_metatable"] = tostring(getmetatable(v).MemProfilerRecordMetaTable);
								end , function()
									infoTable["table_metatable"] = "metatable 解析失败";
								end );
							end
							--这里应该把table装入一个数组备查, 仅用名称是标识不了一个table的，要把它在table中的位置作为id标识出来
							--虽然全局变量不会重复，但可能出现 x = "5" , aa.x = "5"的情况，这时候仅靠变量名x是没法定位的，所以需要id
							--能否打印出变量的大小？
							-- infoTable["id"] = tostring(#recordNewTab)
							table.insert(recordNewTab, v)
						elseif tostring(type(v)) == "userdata" or tostring(type(v)) == "function" or tostring(type(v)) == "thread" then
							--新增变量仅展示table,ud,function,thread
							this.insertResToTable(infoTable, compareFlag)

						end

					else
						--对比当前Table的metatable,如果有改变直接输出,无改变继续遍历
						if getmetatable(v) ~= nil then
							if getmetatable(profiler_start_table[k]) == nil or rawget(getmetatable(v), "MemProfilerRecordMetaTable") ~= rawget(getmetatable(profiler_start_table[k]), "MemProfilerRecordMetaTable") then
								print("getmetatable not equal")
								local infoTable = {}
								--追踪路径
								if key_prefix == nil then
									infoTable["key"] = tostring(k)
								else
									infoTable["key"] = key_prefix.."."..tostring(k)
								end
								--结束快照的类型
								infoTable["type"] = tostring(type(profiler_end_table))
								infoTable["record_reason"] = "table metatable改变"


								xpcall(function()
									infoTable["start_metatable"] = tostring(getmetatable(profiler_start_table[k]).MemProfilerRecordMetaTable);
								end , function()
									infoTable["start_metatable"] = "metatable 解析失败";
								end );

								xpcall(function()
									infoTable["end_metatable"] = tostring(getmetatable(v).MemProfilerRecordMetaTable);
								end , function()
									infoTable["end_metatable"] = "metatable 解析失败";
								end );
								-- table.insert(outputTable, infoTable)
								this.insertResToTable(infoTable, compareFlag)
							else
								--遍历metatable
								local next_key_prefix = ""
								if key_prefix == nil then
									next_key_prefix = tostring(k)
								else
									next_key_prefix = key_prefix..".metatable"
								end
								--print("visit metatable ".. next_key_prefix)
								--print(tostring(getmetatable(v).MemProfilerRecordMetaTable).. " ".. tostring(getmetatable(profiler_start_table[k]).MemProfilerRecordMetaTable))
								--这个目前还不起作用
								this.compareTable(rawget(getmetatable(v),"MemProfilerRecordMetaTable") ,rawget(getmetatable(profiler_start_table[k]), "MemProfilerRecordMetaTable"), false, compareFlag,next_key_prefix)
							end
						end

						--查询一下
						if compareLookupTable[v] == nil then
							--print("==x record ..".. tostring(compareLookupTable[v]))
							--没查到，记录下来
							compareLookupTable[v] = profiler_start_table[k]

							--print("==xx record ..".. tostring(compareLookupTable[v]))

							--有相同的key, 继续遍历
							local next_key_prefix = ""
							if key_prefix == nil then
								next_key_prefix = tostring(k)
							else
								next_key_prefix = key_prefix.."."..tostring(k)
							end
							this.compareTable(v, profiler_start_table[k], false, compareFlag, next_key_prefix)

						else
							if compareLookupTable[v] == profiler_start_table[k] then
								--如果查到了，那么说明这个table被遍历过了，直接continue
								--print("==x get")
							else
								--print("==x record2")
								local next_key_prefix = ""
								if key_prefix == nil then
									next_key_prefix = tostring(k)
								else
									next_key_prefix = key_prefix.."."..tostring(k)
								end
								this.compareTable(v, profiler_start_table[k], false, compareFlag, next_key_prefix)
							end
						end

					end
				else
					--如果不是table怎么处理
					--判断是否新增，不是新增

					--新增
					if profiler_start_table[k] == nil then
						local infoTable = {}
						--追踪路径
						if key_prefix == nil then
							infoTable["key"] = tostring(k)
						else
							infoTable["var_name"] = key_prefix.."."..tostring(k)
						end
						--结束快照的类型
						infoTable["type"] = tostring(type(v))
						infoTable["value"] = tostring(v)
						infoTable["record_reason"] = "新增变量"
						if  tostring(type(v)) == "function" or tostring(type(v)) == "thread" then
							this.insertResToTable(infoTable, compareFlag)
						elseif tostring(type(v)) == "userdata" then
							--ud的值不为null
							if tostring(v) ~= "null" then
								this.insertResToTable(infoTable, compareFlag)
							end
						end
					else
						if profiler_start_table[k] ~= v then
							--变量改变
							local infoTable = {}
							if key_prefix == nil then
								infoTable["key"] = tostring(k)
							else
								infoTable["var_name"] = key_prefix.."."..tostring(k)
							end
							infoTable["type"] = tostring(type(v))
							infoTable["new_value"] = tostring(v)
							infoTable["old_value"] = tostring(profiler_start_table[k])
							infoTable["record_reason"] = "变量值变化"
							if tostring(type(v)) == "function" or tostring(type(v)) == "thread" then
								this.insertResToTable(infoTable, compareFlag)
							elseif tostring(type(v)) == "userdata" then
								--ud的值不为null
								if tostring(v) ~= "null" then
									this.insertResToTable(infoTable, compareFlag)
								end
							end
						end
					end

				end
			else
				jumpFlag = false
			end
		end
	end
end

function this.insertResToTable( res, compareFlag )
	print("[MemProfiler][info] this.insertResToTable add flag ".. tostring(compareFlag))
	if compareFlag == 0 then
		--_G
		table.insert(globalOutputTable, res)
	elseif compareFlag == 1 then
		--_REG
		table.insert(regOutputTable, res)
	end
end

function this.getUpValues(func)
	local n = 1
	local tempUpvalue = {}
	while true do
		local name,value = debug.getupvalue(func, n)
		print("upval debug info".. tostring(name).. " ".. tostring(value))
		if not name then
			break
		end

		if value == nil then
			value = {}
		end

		tempUpvalue[name] = value
		n = n + 1
	end

	return tempUpvalue
end

function this.testCompare()
	local tab1 = {}
	local tab2 = {}
	tab2.str1 = {}

	this.compareTable( tab2, tab1, true, 0)
	--序列化和记录
	local info = PLTable.record(outputTable)
	this.writeFile("compare_log", info)
	this.clear()
end

function this.testprintG()
	local info = PLTable.record(_G)
	this.writeFile("testprintG_log", info)
end

