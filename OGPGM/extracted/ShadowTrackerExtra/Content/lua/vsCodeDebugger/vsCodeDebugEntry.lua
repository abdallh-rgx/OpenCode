  --[[
  local info = debug.getinfo(1, "S");
  local m_MyFilePath = info.source;
  m_MyFilePath = string.sub(m_MyFilePath, 2, -1) -- 去掉开头的"@"

  local vsCodeDebuggerRootPath = string.match(m_MyFilePath, "^.*/") -- 捕获最后一个 "/" 之前的部分 就是我们最终要的目录部分
  local luasocketRootPath = vsCodeDebuggerRootPath.."luasocket/";
  local socketRootPath = luasocketRootPath.."socket/";

  local m_package_path = package.path;
  package.path = string.format("%s?.lua;%s?.lua;%s?.lua;%s", vsCodeDebuggerRootPath, luasocketRootPath, socketRootPath, m_package_path);
  ]]

  
  log("### vsCodeDebugEntry   [Windows] ###");

  --require module
  --require("LuaDebug").start("127.0.0.1",9999);


  --dostring module
  VSCodeLuaDebug.start("127.0.0.1",9999);
