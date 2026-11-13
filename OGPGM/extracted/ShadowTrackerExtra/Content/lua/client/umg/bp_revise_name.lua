ReviseNameUI = ReviseNameUI or {}

BP_ReviseRole_Name = "";	--玩家的名字
BP_PanelTitle = "";			-- 标题 更改名字
BP_Description = "";		-- 描述 使用改名卡来修改您的名字（每天只能修改一次）
BP_InputHintText = "";		-- 输入框提示 输入您的新名字
ModifyType = 0;				-- 改名卡为0，军团改名卡为1 	

--注册Widget
function bp_revise_name_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_revise_name,
		{{Path="/Game/UMG/UI_Logic/RoleInfo/ReviseName_BP.ReviseName_BP_C", Container="Default", ZOrder=BP_ENUM_UI_REVISE_NAME}},
		{"Lobby"},
		false,
		false,
		true
	);
end

-- 初始化改名卡相关
function ReviseNameUI.InitPanelDetail(modify_type)
	ModifyType = modify_type;
	BP_ReviseRole_Name = "";
	if ModifyType == 0 then	-- 改名卡设置信息
		BP_PanelTitle = Client.GetTableData("LocalizeRes", "6017").TextValue;
		BP_Description = Client.GetTableData("LocalizeRes", "6018").TextValue;
		BP_InputHintText = Client.GetTableData("LocalizeRes", "6019").TextValue;
	else				-- 军团改名卡设置信息
		BP_PanelTitle = Client.GetTableData("LocalizeRes", "6020").TextValue;
		BP_Description = Client.GetTableData("LocalizeRes", "6021").TextValue;
		BP_InputHintText = Client.GetTableData("LocalizeRes", "6022").TextValue;
	end
end

function ReviseNameUI.Show()
	LuaClassObj.HandleDynamicCreation(bp_revise_name);	
	LuaClassObj.HandleUIMessage(bp_revise_name, "UIShow");
end

function ReviseNameUI.Hide()
	LuaClassObj.HandleUIMessage(bp_revise_name, "UIHide");
end

function ReviseNameUI.ModifyNameOk()
	if ModifyType == 0 then			-- 改名卡,设置名字和时间
		DataMgr.roleData.nickName = BP_ReviseRole_Name
		DataMgr.modify_name_time = FuncUtil.GetServerTimeInSec();
	end
end

function ReviseNameUI.RealModifyName()
	local ret, len, retStr = false, 0, "";
	if ModifyType == 0 then 	-- 改名卡提示
		ret, len, retStr = FuncUtil:CheckName(BP_ReviseRole_Name, true);
		if ret then
			PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", "990004").TextValue);
			return;
		elseif len > 14 then
			PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", "990002").TextValue);
			return;
		elseif len == 0 then
			PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", "990003").TextValue);
			return;
		end
	else
		ret, len, retStr = FuncUtil:CheckName(BP_ReviseRole_Name, true, 14, false);
		if ret then 	-- 改名卡提示
			PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", "411019").TextValue);
			return;
		elseif len > 14 then
			PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", "411017").TextValue);
			return;
		elseif len == 0 then
			PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", "411018").TextValue);
			return;
		end
	end

	if ModifyType == 0 then
		RoleInfoSystem.SendModifyRoleName(BP_ReviseRole_Name);
	else
		CorpsMgr.corps_change_name_req(BP_ReviseRole_Name);
	end
end

--过滤不合法字符
function EventReviseNameFilterName()
	BP_ReviseRole_Name = FuncUtil:StrTrim(BP_ReviseRole_Name);	--去除两头的空格
	if ModifyType == 0 then
		_ , _ , BP_ReviseRole_Name = FuncUtil:CheckName(BP_ReviseRole_Name, true, 14);
	else
		_ , _ , BP_ReviseRole_Name = FuncUtil:CheckName(BP_ReviseRole_Name, true, 14, true);
	end
	LuaClassObj.HandleUIMessage(bp_revise_name, "UpdatePlayerName");
end

function EventReviseNameConfirmModify()
	local msgFmt = "";
	if ModifyType == 0 then
		msgFmt = Client.GetTableData("LocalizeRes", "660023").TextValue;
	else
		msgFmt = Client.GetTableData("LocalizeRes", "6027").TextValue;
	end	
	local msg = string.format(msgFmt, BP_ReviseRole_Name);
	CommonMessageBoxUI:ShowPanel(2, 
					Client.GetTableData("LocalizeRes", "101001").TextValue, 
					msg,
					ReviseNameUI.RealModifyName
					)
	
end