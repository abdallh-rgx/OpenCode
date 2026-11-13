local PlayerPrefsSystem =
{
    fileFolder = "SaveGames/%s.json"
};

-- 存档类型
PlayerPrefsSystem.ePlayerPrefsType =
{
    eDefault = "playerprefs",
    eMapSkill = "mapskill",
    ePetRedPoint = "Pet/Pet_RedPoint",
    ePetTips = "Pet/Pet_PetTips",
}

--以json方式保存一个table到本地文件中去
--needOpenIDTag 默认为false，true则给文件名加上玩家openid后续
function PlayerPrefsSystem.SaveTableToFile(table, fileType, needOpenIDTag)
    local fileName = fileType or ePlayerPrefsType.eDefault;
    local filePath
    if needOpenIDTag then
        filePath = string.format("SaveGames/%s_%s.json", fileName, tostring(DataMgr.roleData.openID))
    else
        filePath = string.format("SaveGames/%s.json", fileName)
    end

    local saveStr = json.encode(table)
    Client.SaveStringToFile(saveStr, filePath)
end

--读取本地Json到一个table中去
--needOpenIDTag 默认为false，true则给文件名加上玩家openid后续
function PlayerPrefsSystem.LoadFileToTable(fileType, needOpenIDTag)
    local fileName = fileType or ePlayerPrefsType.eDefault;
    local filePath
    if needOpenIDTag then
        filePath = string.format("SaveGames/%s_%s.json", fileName, tostring(DataMgr.roleData.openID))
    else
        filePath = string.format("SaveGames/%s.json", fileName)
    end

    local str = Client.LoadFileToString(filePath)
    if str == nil or str == "" then
        return nil
    else
        return json.decode(str)
    end
    return nil
end

function PlayerPrefsSystem.SavePlayerPrefs(dict, fileType)
    local fileName = fileType or ePlayerPrefsType.eDefault;
    local filePath = string.format(PlayerPrefsSystem.fileFolder, fileName);
    local str = Client.LoadFileToString(filePath)
    local content = {};
    if str ~= "" then
        content = json.decode(str)
        for k,v in pairs(dict) do
            content[k] = dict[k];
        end
    else
        content = dict;
    end
    local newStr = json.encode(content)
    Client.SaveStringToFile(newStr, filePath)
end

function PlayerPrefsSystem.GetPlayerPrefs(key, fileType)
    local fileName = fileType or ePlayerPrefsType.eDefault;
    local filePath = string.format(PlayerPrefsSystem.fileFolder, fileName);
    local str = Client.LoadFileToString(filePath)
    if str == "" then
        return nil;
    end
    local content = json.decode(str)
    return content[key];
end

return PlayerPrefsSystem