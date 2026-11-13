------------log过滤功能---------------
---该功能涉及范围:
---log_tree()
---log()
---print()
---logc()
---logu()
---
---1 根据Key过滤
---  1.1 请将bLogFilterOn和bLogFilterWithKeys设置为true，
---      并在WhiteListKeys添加对应的Key
---
---2 根据文件名过滤
---  2.1 请将bLogFilterOn和bLogFilterWithFiles设置为true，
---      并在WhiteListFiles添加对应的文件名
---
---3 log和log_tree可以分开控制，将其对应子开关设置为true即开启其过滤功能
---
---提交时请保持bLogFilterOn为false，以免影响他人
---提交时请保持bLogFilterOn为false，以免影响他人
---提交时请保持bLogFilterOn为false，以免影响他人
LogUtil = LogUtil or {
	bLogFilterOn = false,			--总开关
	bLogFilterOn_Log = true,		--log的子开关
	bLogFilterOn_LogTree = true,	--log_tree的子开关
	bLogFilterWithKeys = true,		--是否通过key进行过滤
	bLogFilterWithFiles = false,		--是否通过文件名进行过滤
}
local WhiteListKeys = {
	"modulename",
}
local WhiteListFiles = {
	"log",
	"bp_chat_main",
	"logic_teamup",
}
--------------------------------------------------
----------------------使用示例---------------------
--[[
--------------------------------------------------
函数: log(msg, filterKey, toScreen)
功能: 打印信息
msg: 要打印的信息
filterKey: 当过滤器开启后,只有该值在sandbox.lua中的WhiteListKeys里存在时才会打印出来
toScreen: 是否打印到屏幕上
--------------------------------------------------

根据Key过滤示例:
---------------------过滤器开启---------------------
bLogFilterOn = true
bLogFilterOn_Log = true
bLogFilterWithKeys = true
local WhiteListKeys = {
    "modulename",
}
log("TestLog", "modulename")  	--打印TestLog
log("TestLog", "xxx")			--不打印
log("TestLog")					--不打印
--------------------------------------------------

根据文件名过滤示例:
------------------过滤器开启------------------------
bLogFilterOn = true
bLogFilterOn_Log = true
bLogFilterWithFiles = ture
local LogFilterListFiles = {
    "bp_chat_main",
}
在bp_chat_main中：
log("Log in chat main")  	--打印Log in chat main

在bp_shop_gift中：
log("Log in shop gift")		--不打印
----------------------------------------------------

两个过滤可以同时使用，相当于双重过滤
]]

local function clientLog(msg, toScreen)
	sandbox.Log("Log", msg)

	toScreen = toScreen or false;
	if toScreen then
		Client.ShowScreenDebugMessage(msg);
	end
end

function LogUtil.logWithFilter(msg, filterKey, toScreen)
	if LogUtil.bLogFilterOn and LogUtil.bLogFilterOn_Log then
		if LogUtil.bLogFilterWithFiles then
			local short_src = debug.getinfo(2, "S").source
			local FileName = string.match(short_src, "([^/]+)%.lua")
			if not (FileName and LogUtil.LogFilterListFiles[FileName]) then
				return
			end
		end

		if LogUtil.bLogFilterWithKeys then
			if not (filterKey and LogUtil.LogFilterList[filterKey]) then
				return
			end
		end
	end

	clientLog(msg, toScreen)
end

_G.log = LogUtil.logWithFilter
_G.log_error = sandbox.LogError
_G.log_warning = sandbox.LogWarning
--_G.print = LogUtil.logWithFilter

-------------此处无需修改--------------
LogUtil.LogFilterList = {}
for i, v in pairs(WhiteListKeys) do
	LogUtil.LogFilterList[v] = true
end

LogUtil.LogFilterListFiles = {}
for i, v in pairs(WhiteListFiles) do
	LogUtil.LogFilterListFiles[v] = true
end
log_tree("过滤Key白名单：",LogUtil.LogFilterList)
log_tree("过滤文件白名单：",LogUtil.LogFilterListFiles)
-------------------------------------
