RoleInfoCorpAliasSystem = RoleInfoCorpAliasSystem or {};

function RoleInfoCorpAliasSystem.get_corps_alias_list_request()
	NetUtil.SendPkg("get_corps_alias_list_request");
end

function RoleInfoCorpAliasSystem.change_corps_alias_request(res_id)
	NetUtil.SendPkg("change_corps_alias_request", res_id);
end

function RoleInfoCorpAliasSystem.get_corps_alias_list_respond(corps_alias_data)
	--log_tree("RoleInfoCorpAliasSystem.get_corps_alias_list_respond", corps_alias_data);
	if corps_alias_data and type(corps_alias_data) == "table" then
		--log("RoleInfoCorpAliasSystem.get_corps_alias_list_respond.." .. corps_alias_data.red_point);
		BP_Current_CorpAliasId = corps_alias_data.cur_corps_alias_id;
		DataMgr.roleData.corps_alias_data.red_point = corps_alias_data.red_point;
		if corps_alias_data.have_corps_alias_table and type(corps_alias_data.have_corps_alias_table) == "table" then
			BP_ARRAY_RoleInfo_CorpsAliasDataList = {};
			for k,v in pairs(corps_alias_data.have_corps_alias_table) do
				local data = {};
				local cfg = Client.GetTableData("corps_alias_table", k);
				data.aliasId = k;
				if v.expire_time == 0 then
					data.remainTime = Client.GetTableData("LocalizeRes", "301300").TextValue;
				else
					data.remainTime = FuncUtil.TimeFormatExtNoZero(v.expire_time - NetUtil.GetCurServerTime());
				end
				if cfg then
					data.aliasName = string.format(cfg.CorpsAliasNameBig, BP_STRUCT_CorpsSummary.str_name);
					data.position = BP_STRUCT_CorpsSummary.n_position;
					data.aliasType = cfg.default;
				end
				table.insert(BP_ARRAY_RoleInfo_CorpsAliasDataList, data);
			end
			RoleInfoCorpAlias.ShowUI();
			--再更新当前称号显示
			DataMgr.roleData.corps_alias_data.cur_corps_alias_id = corps_alias_data.cur_corps_alias_id;
			RoleInfoUI.UpDateCorpAliasInfo();
		end
	end
end

function RoleInfoCorpAliasSystem.change_corps_alias_respond(err_code , red_point, res_id)
	if err_code == "ok" then
		--log("RoleInfoCorpAliasSystem.change_corps_alias_respond.." .. red_point);
		DataMgr.roleData.corps_alias_data.red_point = red_point;
		BP_Current_CorpAliasId = res_id;
		DataMgr.roleData.corps_alias_data.cur_corps_alias_id = res_id;
		RoleInfoUI.UpDateCorpAliasInfo();
	else
		DataMgr.ShowNoticeByID(err_code);		
	end
end

function RoleInfoCorpAliasSystem.add_corps_alias_respond(red_point)
	--log("RoleInfoCorpAliasSystem.add_corps_alias_respond.." .. red_point);
	DataMgr.roleData.corps_alias_data.red_point = red_point;
	RoleInfoUI.UpDateCorpAliasInfo();
end

--军团称号
s2c["get_corps_alias_list_respond"] = RoleInfoCorpAliasSystem.get_corps_alias_list_respond;
s2c["change_corps_alias_respond"] = RoleInfoCorpAliasSystem.change_corps_alias_respond;
s2c["add_corps_alias_respond"] = RoleInfoCorpAliasSystem.add_corps_alias_respond;

