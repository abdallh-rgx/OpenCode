emulator_scanner = {}

local function init_emulator_data()
    emulators = {
        { name = "LeiDian", paths = {"/init.android_x86.rc", "/system/lib/libldutils.so", "/system/lib/arm/libhoudini.so", "/data/data/com.android.flysilkworm"}, },
        { name = "BlueStacks7", paths = {"/system/./lib/libhoudini.so", "/data/./data/com.bluestacks.appmart"}, },
        { name = "BlueStacks2", paths = {"/./init.x86.rc", "/data/./data/com.bluestacks.appmart", "/data/./data/com.bluestacks.settings"}, },
        { name = "Netease", paths = {"/init.x86.rc", "/sys/module/nemusf", "/data/data/com.mumu.launcher", "/data/data/com.mumu.store"}, },
        { name = "XiaoYao", paths = {"/init.intel.rc", "/data/data/com.microvirt.launcher", "/data/data/com.microvirt.installer"}, },
        { name = "Nox", paths = {"/system/./bin/nox-prop", "/system/./lib/libnoxd.so", "/system/./lib/libhoudini.so"}, },
        { name = "Phoenix", paths = {"/init.android_x86_64.rc", "/system/lib/libhoudini.so", "/data/data/com.chaozhuo.filemanager.phoenixos"}, },
        { name = "LeiDian3", paths = {"/init.android_x86.rc", "/system/lib/libldutils.so", "/system/lib/arm/libhoudini.so", "/data/data/com.android.ld.appstore"}, },
        { name = "51", paths = {"/./init.android_x86.rc", "/system/./lib/libhoudini.so", "/data/./data/com.anddoes.launcher", "/data/./data/com.bluestacks.settings"}, },
    }
    return emulators
end

local function file_exists(file_name)
    if (file_name == nil or type(file_name) ~= "string")
    then
        return false
    end
    
    local f,err,code = io.open(file_name, "rb")
    if (f ~= nil)
    then
        f.close()
        return true
    elseif (code == 13)
    then
        return true
    end
    return false
end

function emulator_scanner.find_emulator()
    --local emulator_data = init_emulator_data()
    local emulator_data = EmulatorSystem.emulatorCheckData;
    if (emulator_data == nil) then
        log("emulator_scanner.find_emulator() EmulatorSystem.emulatorCheckData = nil");
        emulator_data = init_emulator_data()
    end
    
    if (emulator_data == nil or type(emulator_data) ~= "table")
    then
        return false
    end
    
    for i,emulator in ipairs(emulator_data)
    do
        if (emulator == nil or type(emulator) ~= "table")
        then
            return false
        end
        
        local name = emulator["name"]
        local paths = emulator["paths"]
        
        if (name == nil or paths == nil or type(name) ~= "string" or type(paths) ~= "table")
        then
            return false
        end
        
        local matched = true
        for j,path in ipairs(paths)
        do
            if (file_exists(path) == false)
            then
                matched = false
                break
            end
        end
        if (matched == true and #paths > 0)
        then
            return true, name
        end
    end
    return false
end