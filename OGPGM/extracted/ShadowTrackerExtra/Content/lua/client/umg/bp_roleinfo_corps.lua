--系统报错界面
RoleInfoCorps = RoleInfoCorps or 
{
	IsShow = false,
}
----- end ----------
BP_STRUCT_RoleInfo_CorpsData= 
{
	str_corps_id = "",
	str_city = "",
	n_activeness = 0, 
	n_level = 0,
	n_leader = 0,
	n_icon = 0,
	n_join_level = 0,
	str_announcement = "",
	n_member_num = 0,
	n_member_max = 0,
	n_join_segment = 0,
	str_name = "",
	n_position = 0,
	b_IsOwnApply = false,
	str_icon_text = "",
	n_icon_text_colour = 0,
};

BP_STRUCT_RoleInfo_CorpsAvatar = {
    strUid = "",
    Name = "",
    Level = 1,
    Sex = 1,
    RankIntegralLevel = 1,
    IconUrl = "",
    IconFrameID  = 1,
    LastOnlineTimeStr = ""
}

BP_STRUCT_RoleInfo_Corps_AvatarData = {BP_STRUCT_RoleInfo_CorpsAvatar = _G.BP_STRUCT_RoleInfo_CorpsAvatar};
BP_RoleInfoCorpsMyCorpsID = ""
BP_RoleInfoCorpsCanJoint = false
--注册widget
function bp_roleinfo_corps_RegisterUI()
  LuaClassObj.SubUIWidgetList(bp_roleinfo_corps,
		{{Path="/Game/UMG/UI_Logic/RoleInfo/RoleInfoCorps_BP.RoleInfoCorps_BP_C", Container="Default", ZOrder=BP_ENUM_UI_ROLEINFO_ZORDER+1}},
		{"Lobby"},
		false,
		false,
		true
	);
end

function EventRoleInfoCorpsShow()
	RoleInfoCorps:Init()
end

function EventRoleInfoCorpsClose()
    RoleInfoCorps:Hide()
end

function RoleInfoCorps:SetCanJoin(can_join)
	BP_RoleInfoCorpsCanJoint = can_join
end

-- 不能删除，蓝图里面调用该函数才能保证变量成功存储到lua
function EventRoleInfoCorpsRefresh()

end

function EventRoleInfoCorpsReport()
    CommonMessageBoxUI:ShowPanel(2, DataMgr.GetMsgByID(101001), DataMgr.GetMsgByID(411043), 
		function ()
			local params = {BP_STRUCT_RoleInfo_CorpsData.n_leader}
			local cb = RoleInfoCorps.OnGetAvatarInfoForReport
			CorpsMgr.GetAvatarBaseInfo(params, cb, false)
            --DataMgr.ShowNoticeByID(117066);
        end
    );
end

-- 申请加入他人军团判断
function EventRoleInfoCorpsApplyJoinCorps()
	-- 申请时候的判断交给server处理
	CorpsMemberSystem.SendApplyJoinCorps( tonumber(BP_STRUCT_RoleInfo_CorpsData.str_corps_id) )
end


function RoleInfoCorps:SetCorpsInfo(corpsInfo)
	for k, v in pairs(corpsInfo) do
		BP_STRUCT_RoleInfo_CorpsData[k] = v
	end
	-- 自己的军团ID
	BP_RoleInfoCorpsMyCorpsID = "0"
	if DataMgr.corpsInfo.id ~= nil then
		BP_RoleInfoCorpsMyCorpsID = tostring(DataMgr.corpsInfo.id)
	end
end

function RoleInfoCorps.OnGetAvatarInfo(avatarInfoMap)
    if not RoleInfoCorps.IsShow then
        return;
    end

   	BP_STRUCT_RoleInfo_Corps_AvatarData.BP_STRUCT_RoleInfo_CorpsAvatar = avatarInfoMap[BP_STRUCT_RoleInfo_CorpsData.n_leader] or BP_STRUCT_RoleInfo_Corps_AvatarData.BP_STRUCT_RoleInfo_CorpsAvatar;
    LuaClassObj.HandleUIMessage(bp_roleinfo_corps, "UpdateAvatar");
end

function RoleInfoCorps.OnGetAvatarInfoForReport(avatarInfoMap)
	local avatarInfo = avatarInfoMap[BP_STRUCT_RoleInfo_CorpsData.n_leader]

	if avatarInfo then
		local leaderName = avatarInfo.Name or "" 
		local corpsId = BP_STRUCT_RoleInfo_CorpsData.str_corps_id
		local corpsName = BP_STRUCT_RoleInfo_CorpsData.str_name
		local corpsAnnoun = BP_STRUCT_RoleInfo_CorpsData.str_announcement
		
		CorpsMgr.SendReportInfo(leaderName, corpsId, corpsName, corpsAnnoun)
	end
end

function RoleInfoCorps:Init()
	LuaClassObj.HandleDynamicCreation(bp_roleinfo_corps);
	-- log(string.format("RoleInfoCorps:Init "));
	LuaClassObj.HandleUIMessage(bp_roleinfo_corps, "UIShow");
	UIManager.Show(eUIType.eRoleInfoCorpsUI)
	-- 初始化数值
	-- self:Release()
	-- 初始化控件
	LuaClassObj.HandleUIMessage(bp_roleinfo_corps, "InitUIInfo");
	RoleInfoCorps.IsShow = true
	-- 获取avatar信息
	CorpsMgr.GetAvatarBaseInfo({BP_STRUCT_RoleInfo_CorpsData.n_leader}, RoleInfoCorps.OnGetAvatarInfo, false)
end

function RoleInfoCorps:Hide()
	RoleInfoCorps.IsShow = false
	UIManager.Hide(eUIType.eRoleInfoCorpsUI)
	LuaClassObj.HandleUIMessage(bp_roleinfo_corps, "UIHide");
end