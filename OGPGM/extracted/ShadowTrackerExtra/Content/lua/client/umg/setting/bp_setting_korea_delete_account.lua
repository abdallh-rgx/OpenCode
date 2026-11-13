--删除账号

SettingKoreaDeleteAccountUI = SettingKoreaDeleteAccountUI or 
{
	
}

BP_Korea_DelAccount_BtnOKTxt = "";
BP_Korea_DelAccount_BtnCancelTxt = "";
BP_Korea_DelAccount_DelaySeconds = 5;

--注册widget
function bp_setting_korea_delete_account_RegisterUI()
  LuaClassObj.SubUIWidgetList(bp_setting_korea_delete_account,
    {{Path="/Game/UMG/UI_BP/Setting/Setting_CancelPUBGM_UIBP.Setting_CancelPUBGM_UIBP_C", Container="Default", ZOrder = BP_ENUM_UI_BLOCK_ZORDER}},
    {"Lobby"},
	false,
	false,
	true
  );
end

--显示UI 
function SettingKoreaDeleteAccountUI.ShowUI()	
	log("[CCW]SettingKoreaDeleteAccountUI.ShowUI");
	LuaClassObj.HandleDynamicCreation(bp_setting_korea_delete_account);
	BP_Korea_DelAccount_BtnOKTxt = Client.GetTableData("LocalizeRes", "4709").TextValue;
	BP_Korea_DelAccount_BtnCancelTxt = Client.GetTableData("LocalizeRes", "4142").TextValue;
	LuaClassObj.HandleUIMessage(bp_setting_korea_delete_account, "UIShow");	
end

--关闭UI
function EventHideUI()
	LuaClassObj.HandleUIMessage(bp_setting_korea_delete_account, "UIHide");	
end

--确认删号
function EventKoreaConfirmDeleteAccount()
	SettingKoreaDeleteAccountUI:ConfirmKoreaDeleteAccount();
end

function SettingKoreaDeleteAccountUI:ConfirmKoreaDeleteAccount()
	local function deleteAccount()
		log("[CCW]SettingKoreaDeleteAccountUI:ConfirmKoreaDeleteAccount  deleteAccount isInLobby "..tostring(LoginSystem.isInLobby).." isCanDeleteOp "..tostring(LoginSystem.isCanDeleteOp));    
		if LoginSystem.isInLobby == true and LoginSystem.isCanDeleteOp == true then
            EUGDPRSystem.DeleteKoreaAccountReq(true, true);
        end
	end

	local function regretDelete()     
    	log("[CCW]SettingKoreaDeleteAccountUI:ConfirmKoreaDeleteAccount  regretDelete isInLobby "..tostring(LoginSystem.isInLobby).." isCanDeleteOp "..tostring(LoginSystem.isCanDeleteOp));    
		if LoginSystem.isInLobby == true and LoginSystem.isCanDeleteOp == true then
            EUGDPRSystem.SendKoreaCancelDeleteAccount();
        end 
    end

    local timeSecond = 7 * 24 * 60 * 60;
    if LoginSystem.commonSwitch ~= nil and LoginSystem.commonSwitch.KRJPDelAccountTime ~= nil then
		timeSecond = LoginSystem.commonSwitch.KRJPDelAccountTime;
	end

	log("[CCW]SettingKoreaDeleteAccountUI:ConfirmKoreaDeleteAccount, timeSecond = " .. timeSecond);
	-- 时间精确到小时
	local day = timeSecond / (24 * 60 * 60)
	local hours = (day - math.floor(day)) * 24
	local timeStr = tostring(math.floor(day))..Client.GetTableData("LocalizeRes", "301367").TextValue;
	if hours > 0 then
		timeStr = timeStr .. tostring(math.floor(hours)) .. Client.GetTableData("LocalizeRes", "1215").TextValue;
	end
	local msg = string.format(Client.GetTableData("LocalizeRes", "4708").TextValue, timeStr);

	SettingGDPRUI:ShowNoticeBox(0, Client.GetTableData("LocalizeRes", "101001").TextValue, 
		msg, --.."\n"..Client.GetTableData("LocalizeRes", "4323").TextValue, --联系客服 超链接
		Client.GetTableData("LocalizeRes", "4114").TextValue, 
		Client.GetTableData("LocalizeRes", "4112").TextValue, deleteAccount, regretDelete);
end