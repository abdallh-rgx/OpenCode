--[[
  称号相关逻辑
]]--

RoleInfoAliasSystem = RoleInfoAliasSystem or
{
	alias_list_info = {},
}

--初始化称号title
local function InitAliasTitle()
    for k , v in pairs(RoleInfoAliasSystem.alias_list_info) do
        local cfg = Client.GetTableData("AliasCfg", k);
        if cfg ~= nil then
            v.title = FuncUtil:Gen_title(k, v.rank);
        end
    end
end

function RoleInfoAliasSystem.Enter()
    log("RoleInfoAliasSystem Enter");
    RoleInfoAliasSystem.alias_list_info = {};
    RoleInfoAliasSystem.get_alias_list();
end

function RoleInfoAliasSystem.Release()
	--log("RoleInfoAliasSystem Release");
   RoleInfoAliasSystem.alias_list_info = {};
end

function RoleInfoAliasSystem.get_alias_list()
    NetUtil.SendPkg("get_alias_list");
end

function RoleInfoAliasSystem.change_alias_req(id, state)
    NetUtil.SendPkg("change_alias_req", id, state);
end

function RoleInfoAliasSystem.alias_list_res(res, list, red_point)
    --log_tree("RoleInfoAliasSystem.alias_list_res", list);
    if res == "ok" then
        if type(list) == "table" then
            RoleInfoAliasSystem.alias_list_info = list;
            InitAliasTitle();
            RoleInfoAliasUI.refreshAliasList();
        end
    end
end

function RoleInfoAliasSystem.change_alias_rsp(res, id)
    if res == 0 and RoleInfoAliasUI.CurrentChangeState ~= 0 then
        RoleInfoAliasSystem.get_alias_list();
    end
end

function RoleInfoAliasSystem.notify_add_alias(isShow, alias_id, alias_info)
    log("RoleInfoAliasSystem.notify_add_alias isShow:" .. tostring(isShow).." alias_id "..tostring(alias_id));
    log_tree("alias_info", alias_info);
    if isShow then
        DataMgr.roleData.alias.red_point = 1;
        LobbyUI:UpdateHeadportraitReddot();
        RoleInfoUI.UpdateHeadportraitReddot();
    end
    ShareAliasUI.AddAliasInfo(alias_id, alias_info)
end

function RoleInfoAliasSystem.hasRedpoint()
    if DataMgr.roleData.alias.red_point == 1 then
        return true;
    end
    return false;
end

--[[网络回调]]--
s2c["alias_list_res"] = RoleInfoAliasSystem.alias_list_res;
s2c["change_alias_rsp"] = RoleInfoAliasSystem.change_alias_rsp;
s2c["notify_add_alias"] = RoleInfoAliasSystem.notify_add_alias;
