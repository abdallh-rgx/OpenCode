-- 数据配置管理，请求配置管理器
DataConfigMgr = DataConfigMgr or
{
    DataConfigVersion = {};
}

-- 批量请求配置
---@param tables_req tables 结构为tableName:version
function DataConfigMgr.ConfigBatchReq(tables_req)
    local datatableMap = {};
    for k,v in pairs(tables_req) do
        if DataConfigMgr.DataConfigVersion[v] then
            datatableMap[v] = DataConfigMgr.DataConfigVersion[v];
        else
            datatableMap[v] = 0;
        end        
    end
    NetUtil.SendPriorityPkg(false, "client_table_batch_rsp", "client_table_batch_req", datatableMap);
end

-- 批量请求配置回包
function DataConfigMgr.client_table_batch_rsp(res, tables)
    log("DataConfigMgr.client_table_batch_rsp,res:"..tostring(res))
    if res == 0 then
        for tableName, cfg in pairs(tables) do
            if cfg.err == 0 then
                DataConfigMgr.DataConfigVersion[tableName] = cfg.version;
                UnknowPassSystem.DealWithConfig(tableName, cfg.data)
            end
        end
        
    end
end

s2c["client_table_batch_rsp"] = DataConfigMgr.client_table_batch_rsp;