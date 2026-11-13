--[[
战区称号相关逻辑
]]--
local  t_insert, t_sort = table.insert, table.sort


WarZoneTitleSystem = WarZoneTitleSystem or
{
	UseTitle = {},--{warzone_id=, rank_id=, rank_no=}，服务端改了key，但客户端还是保持：warzone_id代表地区id，rank_id代表排行榜id，rank_no代表排行位置
	TitleList = {}, --{{warzone_id=, rank_id=, rank_no=},{warzone_id=, rank_id=, rank_no=},...}
}

--==================================================================================================================

function  WarZoneTitleSystem.Enter()
	log("WarZoneTitleSystem Enter");
	WarZoneTitleSystem.UseTitle = DataMgr.roleData.warzone_use_title;
	WarZoneTitleSystem.lbs_warzone_title_req();
end

function WarZoneTitleSystem.Release()
	WarZoneTitleSystem.TitleList = {}
	WarZoneTitleSystem.UseTitle = {}
end

--服务端改了key，但客户端还是保持：warzone_id代表地区id，rank_id代表排行榜id，rank_no代表排行位置
function WarZoneTitleSystem.create_client_tbl_from_server_tbl( server_format_tbl )
	local client_tbl = {}
	if server_format_tbl ~= nil and server_format_tbl.rank_id ~= nil then
		client_tbl.warzone_id = server_format_tbl.rank_id
		client_tbl.rank_id = server_format_tbl.rank_type
		client_tbl.rank_no = server_format_tbl.rank_no
	end
	return client_tbl
end

function WarZoneTitleSystem.get_title_des( title )
	local ret = ""
	if (title == nil or title.warzone_id == nil) then
	 ret = "--"
	else
	
	    return "--"

        --[[
		local tab = city_info.level
		local des = ""
		local rank_name = rank_info.rank_name

		if tab == 4 then 
			des = des..city_info.province_name
			ret = des.."最强"..rank_name
		else
			if tab <= 3 and tab >= 2 then
				des = des..city_info.province_name
			end
			if tab <= 2 then
				des = des..city_info.city_name
			end
			if tab <= 1 then
				des = des..city_info.district_name
			end
			ret = des.."第"..title.rank_no..rank_name
		end--]]

	end

	return ret
end

function WarZoneTitleSystem.GetShareTitleRankStr( title )
	local titStr , rankStr= ""
	if (title == nil or title.warzone_id == nil) then
	 titStr = "--"
	else

	end

	return titStr,rankStr
end

function WarZoneTitleSystem.get_title_tab_and_des(title)
	title = title or {}
	return 1, "--" 
    --[[
	local tab = city_info.level
	-- 服务端中途改变量名，但是蓝图不好维护，只能两套名字一起用，导致难以维护
	local des = WarZoneTitleSystem.get_title_des(title)

	return tab, des]]
end

function WarZoneTitleSystem.get_title_level(title)
	if title == nil then return 0 end
	local city_info = title.warzone_id ~= nil  or nil
	if city_info == nil then return 0 end
	return city_info.level
end

-- 获取rank_id对应的图标路径
function WarZoneTitleSystem.get_title_image_path(rank_id)
    local config = Client.GetTableData("lbsranktypetable", rank_id);
	if config ~= nil then
		return config.icon_path
	else
		return ""
	end
end

-- 获取rank_id对应的图标背景路径
function WarZoneTitleSystem.get_title_petal_image_path(rank_id)
    local config = Client.GetTableData("lbsranktypetable", rank_id);
	if config ~= nil then
		return config.pedal_path
	else
		return ""
	end
end

function WarZoneTitleSystem.get_show_red_pt_list( )
	local list = {}
	local  idx = 1
	local lbs_warzone_info = DataMgr.lbs_warzone_info
	if lbs_warzone_info == nil then return list end

	local redpoint_map = lbs_warzone_info.title_type_redpoint_map
	if redpoint_map == nil then return list end

	for k, v in pairs(redpoint_map) do
		if v == true then
			list[idx] = k
			idx = idx + 1
		end
	end
	return list
end

function WarZoneTitleSystem.refresh_red_point( )
	WarZoneTitleRedPointTypeOne = false
	WarZoneTitleRedPointTypeTwo = false
	WarZoneTitleRedPointTypeThree = false
	WarZoneTitleRedPointTypeFour = false
	local red_list = WarZoneTitleSystem.get_show_red_pt_list()
	if #red_list > 0 then
		BP_RoleInfo_SocialCardRedpoint = true
		local red_key_tbl = {}
		for k, v in pairs(red_list) do
			red_key_tbl[v] = true
		end
		if red_key_tbl[1] == true then
			WarZoneTitleRedPointTypeOne = true
		end
		if red_key_tbl[2] == true then
			WarZoneTitleRedPointTypeTwo = true
		end
		if red_key_tbl[3] == true then
			WarZoneTitleRedPointTypeThree = true
		end
		if red_key_tbl[4] == true then
			WarZoneTitleRedPointTypeFour = true
		end
	else
		BP_RoleInfo_SocialCardRedpoint = false
	end
	
	-- 刷新lobby界面的
	LobbyUI:LobbyRedPointUpdate(BP_ENUM_LOBBY_MENU_ROLE_INFO, RoleInfoUI.GetLobbyMenuRoleInfoRedPoint())
	-- 刷新个人信息界面和好友名片界面的
	RoleInfoUI.UpdateSocialCardRedpoint()
	-- 刷新战区称号界面的
	WarZoneTitleUI.UpdateRedPoint()
end

function WarZoneTitleSystem.modify_lbs_warzone_use_title_req( new_title )
	log_tree("WarZoneTitleSystem modify_lbs_warzone_use_title_req=", new_title);
	-- send pkg
	local server_format_new_title = {rank_id = new_title.warzone_id, rank_type = new_title.rank_id, rank_no = new_title.rank_no}
	NetUtil.SendPriorityPkg(false, "modify_lbs_warzone_use_title_rsp", "modify_lbs_warzone_use_title_req", server_format_new_title);
end

function WarZoneTitleSystem.modify_lbs_warzone_use_title_rsp( ok, new_title )
	log_tree("WarZoneTitleSystem.modify_lbs_warzone_use_title_rsp=", {ok, new_title});
	if ok == 0 then
		local client_new_tbl = WarZoneTitleSystem.create_client_tbl_from_server_tbl(new_title);
		WarZoneTitleSystem.UseTitle = client_new_tbl;
		--需要同步一下基本信息系统
		DataMgr.roleData.warzone_use_title = client_new_tbl;
		if WarZoneTitleUI.isShow then
			WarZoneTitleUI.RefreshUI(true)
		end

		RoleInfoUI.UpdteWarzoneUseTitle()
		LobbyChatLogic.ResetMyProfile();
	else
		DataMgr.ShowMessageBoxByID(ok);
	end
end

function WarZoneTitleSystem.lbs_warzone_title_req()
	log("WarZoneTitleSystem.lbs_warzone_title_req");
	--send pkg
	NetUtil.SendPriorityPkg(false, "lbs_warzone_title_rsp", "lbs_warzone_title_req");
end

function WarZoneTitleSystem.lbs_warzone_title_rsp( ok, title_list )
	log_tree("WarZoneTitleSystem.lbs_warzone_title_rsp=", {ok, title_list});
	if ok == 0 then
		WarZoneTitleSystem.TitleList = {}
		for k, v in pairs(title_list) do
			if type(v) == "table" then
				for kk, vv in pairs(v) do
					local tab = {warzone_id = vv.rank_id, rank_id = vv.rank_type, rank_no = vv.rank_no, score = vv.score}
					t_insert(WarZoneTitleSystem.TitleList, tab)
				end
			end
		end

		-- refresh UI
		WarZoneTitleUI.RefreshUI();
	else
		DataMgr.ShowMessageBoxByID(ok);
	end
end

-- 清空使用的称号
function WarZoneTitleSystem.clear_lbs_warzone_use_title(  )
	WarZoneTitleSystem.modify_lbs_warzone_use_title_rsp(0,{})
end

function WarZoneTitleSystem.clear_lbs_warzone_title_redpoint_req( type )
	local lbs_warzone_info = DataMgr.lbs_warzone_info
	local ignore = true

	if lbs_warzone_info == nil then
		ignore = false
	end


	local redpoint_map = lbs_warzone_info.title_type_redpoint_map
	
	if redpoint_map ~= nil and redpoint_map[type] ~= true then
		ignore = true
	else
		ignore = false
	end

	log("WarZoneTitleSystem.clear_lbs_warzone_title_redpoint_req, ignore:"..tostring(ignore).."---type:"..tostring(type))

	if ignore == false then
		NetUtil.SendPriorityPkg(false, "clear_lbs_warzone_title_redpoint_rsp", "clear_lbs_warzone_title_redpoint_req", type);
	end
end

function WarZoneTitleSystem.clear_lbs_warzone_title_redpoint_rsp(type, state)
	log_tree("WarZoneTitleSystem.clear_lbs_warzone_title_redpoint_rsp:", {type, state})
	local lbs_warzone_info = DataMgr.lbs_warzone_info
	if lbs_warzone_info == nil then return end

	local redpoint_map = lbs_warzone_info.title_type_redpoint_map
	if redpoint_map == nil then return end

	redpoint_map[type] = state
	-- 刷新小红点
	WarZoneTitleSystem.refresh_red_point()
end

function WarZoneTitleSystem.notify_lbs_warzone_title_redpoint_info(redpoint_map)
	log_tree("WarZoneTitleSystem.notify_lbs_warzone_title_redpoint_info:", redpoint_map)
	local lbs_warzone_info = DataMgr.lbs_warzone_info
	if lbs_warzone_info == nil then return end

	lbs_warzone_info.title_type_redpoint_map = redpoint_map
	-- 刷新小红点
	WarZoneTitleSystem.refresh_red_point()
end

--[[net rsp]]--
s2c["modify_lbs_warzone_use_title_rsp"] = WarZoneTitleSystem.modify_lbs_warzone_use_title_rsp;
s2c["lbs_warzone_title_rsp"] = WarZoneTitleSystem.lbs_warzone_title_rsp;
s2c["clear_lbs_warzone_use_title"] = WarZoneTitleSystem.clear_lbs_warzone_use_title;
s2c["clear_lbs_warzone_title_redpoint_rsp"] = WarZoneTitleSystem.clear_lbs_warzone_title_redpoint_rsp;
s2c["notify_lbs_warzone_title_redpoint_info"] = WarZoneTitleSystem.notify_lbs_warzone_title_redpoint_info;
