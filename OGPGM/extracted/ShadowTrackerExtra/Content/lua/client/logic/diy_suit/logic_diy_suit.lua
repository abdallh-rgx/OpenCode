DiySuitSystem = DiySuitSystem or
{
	DiySuitConfig = nil,
}

function DiySuitSystem.Init()
	-- 构建配置数据
	DiySuitSystem.DiySuitConfig = {};
    local diySuitColorCfgs = Client.GetTable("DiySuitColorConfig");
    for id, cfg in pairs(diySuitColorCfgs) do
    	DiySuitSystem.SetConfig("DiySuitColorConfig", cfg.ItemID, cfg);
    end
    local diySuitPatternCfgs = Client.GetTable("DiySuitPatternConfig");
    for id, cfg in pairs(diySuitPatternCfgs) do
    	DiySuitSystem.SetConfig("DiySuitPatternConfig", cfg.ItemID, cfg);
    end
end

function DiySuitSystem.SetConfig(cfgType, id, cfg)
	if DiySuitSystem.DiySuitConfig[id] == nil then
		DiySuitSystem.DiySuitConfig[id] = {};
	end
	if DiySuitSystem.DiySuitConfig[id][cfgType] == nil then
		DiySuitSystem.DiySuitConfig[id][cfgType] = {};
	end
	table.insert(DiySuitSystem.DiySuitConfig[id][cfgType], cfg);
end

function DiySuitSystem.GetConfigByItemID(type, id)
	if DiySuitSystem.DiySuitConfig[id] ~= nil and DiySuitSystem.DiySuitConfig[id][type] ~= nil then
		return DiySuitSystem.DiySuitConfig[id][type];
	end
	return {};
end