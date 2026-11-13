--sami lua列表
XList = XList or {}

function XList.Alloc()
    local list = {}
    return list
end

function XList.Len(list)
    return #list
end

function XList.Get(list, index)
    return list[index]
end

function XList.Add(list, data)
    table.insert(list, data)
end

function XList.Remove(list, index)
    table.remove(list, index)
end







