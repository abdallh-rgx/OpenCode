--[[
	设置界面下方，gdpr相关按钮的逻辑
--]]

SettingGDPRUI = SettingGDPRUI or {
	mySelf = nil,
	onClickOkCallback = nil,
	onClickCloseCallback = nil,
	onSelectChoice1Callback = nil,
	onSelectChoice2Callback = nil,
	onPolicyCallback = nil,
}

-- 弹窗的style，0是普通弹窗，1是确定按钮带有10s倒计时, 2是没有取消按钮, 3是只有确定按钮带有N秒倒计时
BP_NoticeBox_Style = 0;
BP_NoticeBox_Title = "";
BP_NoticeBox_Msg = "";
BP_NoticeBox_BtnOKTxt = "";
BP_NoticeBox_BtnCancelTxt = "";
BP_NoticeBox_DelaySeconds = 10;

BP_SelectBox_Title = "";
BP_SelectBox_Msg = "";
BP_SelectBox_Choice1 = "";
BP_SelectBox_Choice2 = "";
BP_SelectBox_BtnOKTxt = "";
BP_SelectBox_BtnCancelTxt = "";


function bp_setting_gdpr_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_setting_gdpr,
		{{Path="/Game/UMG/UI_BP/PopupNotice/Gameplayerprotection/Protection02_BP1.Protection02_BP1_C", Container="Default", ZOrder=BP_ENUM_UI_BLOCK_ZORDER},
		 {Path="/Game/UMG/UI_BP/PopupNotice/Gameplayerprotection/Protection06_BP.Protection06_BP_C", Container="Default", ZOrder=BP_ENUM_UI_BLOCK_ZORDER}},
		{"Lobby","Login"},
		false,
		false,
		true
	);
end	 

function SettingGDPRUI:ShowNoticeBox(style, title, msg, btnOKText, btnCancelText, clickOkCallback, clickCloseCallback, policyCallback, delaytime)
	LuaClassObj.HandleDynamicCreation(bp_setting_gdpr);
    log("SettingGDPRUI:ShowNoticeBox");
    BP_NoticeBox_Style = style;
	BP_NoticeBox_Msg = msg;
    BP_NoticeBox_Title = title;
    BP_NoticeBox_BtnOKTxt = btnOKText;
    BP_NoticeBox_BtnCancelTxt = btnCancelText;
	log("delaytime:" .. tostring(delaytime));
    if delaytime ~= nil then
		BP_NoticeBox_DelaySeconds = delaytime;
	end
	
    policyCallback = policyCallback or nil;
	SettingGDPRUI.mySelf = self;
	SettingGDPRUI.mySelf.onClickOkCallback = clickOkCallback;
	SettingGDPRUI.mySelf.onClickCloseCallback = clickCloseCallback;
	SettingGDPRUI.mySelf.onPolicyCallback = policyCallback;
    
	LuaClassObj.HandleUIMessage(bp_setting_gdpr, "UIShowNoticeBox");
end

function SettingGDPRUI:ShowSelectBox(title, msg, choice1, choice2, choice1Callback, choice2Callback, policyCallback)
	LuaClassObj.HandleDynamicCreation(bp_setting_gdpr);
    log("[CCW]SettingGDPRUI:ShowSelectBox");
	BP_SelectBox_Msg = msg;
    BP_SelectBox_Title = title;
    --BP_SelectBox_BtnOKTxt = btnOKText;
    --BP_SelectBox_BtnCancelTxt = btnCancelText;
    BP_SelectBox_Choice1 = choice1;
    BP_SelectBox_Choice2 = choice2;
    
    policyCallback = policyCallback or nil;
	SettingGDPRUI.mySelf = self;
	SettingGDPRUI.mySelf.onSelectChoice1Callback = choice1Callback;
	SettingGDPRUI.mySelf.onSelectChoice2Callback = choice2Callback;
	SettingGDPRUI.mySelf.onPolicyCallback = policyCallback;
    
	LuaClassObj.HandleUIMessage(bp_setting_gdpr, "UIShowSelectBox");
end

function EventSettingGDPRNoticeBoxClickOK()
    log("[CCW]SettingGDPRUI:EventCommonNoticeBoxClickOK");
	if SettingGDPRUI.mySelf.onClickOkCallback ~= nil then
		SettingGDPRUI.mySelf.onClickOkCallback();
	end
end

function EventSettingGDPRNoticeBoxClickClose()
    log("[CCW]SettingGDPRUI:EventCommonNoticeBoxClickClose");
	if SettingGDPRUI.mySelf.onClickCloseCallback ~= nil then
		SettingGDPRUI.mySelf.onClickCloseCallback();
	end
end

function EventSettingGDPRSelectBoxChoice1()
    log("[CCW]SettingGDPRUI:EventSettingGDPRSelectBoxChoice1");
	if SettingGDPRUI.mySelf.onSelectChoice1Callback ~= nil then
		SettingGDPRUI.mySelf.onSelectChoice1Callback();
	end
end

function EventSettingGDPRSelectBoxChoice2()
    log("[CCW]SettingGDPRUI:EventSettingGDPRSelectBoxChoice2");
	if SettingGDPRUI.mySelf.onSelectChoice2Callback ~= nil then
		SettingGDPRUI.mySelf.onSelectChoice2Callback();
	end
end

local function showPrivacyAgreement()
	log("showPrivacyAgreement");     
	
	local strRegion = Client.GetPublishRegion() ;
	log("bp_authorization EventShowPrivacyAgreement strRegion = " .. strRegion);

	if strRegion == "JAPAN" then
		PopUpNoticeUI.ShowMessageBox(LongTxt.PrivacyAgreement_title_jp, LongTxt.PrivacyAgreement_content_jp);
	elseif strRegion == "KOREA" then
		Client.OpenURL("https://cafe.naver.com/battlegroundsmobile/112197 ");
		--PopUpNoticeUI.ShowMessageBox(LongTxt.PrivacyAgreement_title_kr, LongTxt.PrivacyAgreement_content_kr);
	else
		PopUpNoticeUI.ShowMessageBox(LongTxt.PrivacyAgreement_title_en, LongTxt.PrivacyAgreement_content_en);
	end
end

function EventSettingPolicyCallback()
	if SettingGDPRUI.mySelf.onPolicyCallback ~= nil then
		SettingGDPRUI.mySelf.onPolicyCallback();
	end
end

function SettingGDPRUI:AskForDeleteAccount()
	local function confirmDelete() 
		local strRegion = Client.GetPublishRegion() ;
		log("[CCW]SettingGDPRUI:AskForDeleteAccount  confirmDelete strRegion=".. strRegion);
		--jaysunzhu dominicwang review。只有全球版才需要GDPR。以下是特殊用法，正确用法参考http://tapd.oa.com/iGameInternational/markdown_wikis/view/#1020360302008071849
		if strRegion ~= "GLOBAL" then
			SettingKoreaDeleteAccountUI.ShowUI();
		else
			SettingGDPRUI:ConfirmDeleteAccount();
		end
    end

    local function regretDelete()     
    	log("[CCW]SettingGDPRUI:AskForDeleteAccount  regretDelete");     
		EUGDPRSystem.SendPrivacyToServer(1);
    end
    local strDelTips = Client.GetTableData("LocalizeRes", "4379").TextValue;

    local timeSecond = 7 * 24 * 60 * 60;
    if LoginSystem.commonSwitch.KRJPDelAccountTime ~= nil then
		timeSecond = LoginSystem.commonSwitch.KRJPDelAccountTime;
		log("[CCW]SettingKoreaDeleteAccountUI:ConfirmKoreaDeleteAccount, timeSecond = " .. timeSecond);
	end
	--jaysunzhu dominicwang review。只有全球版才需要GDPR。以下是特殊用法，正确用法参考http://tapd.oa.com/iGameInternational/markdown_wikis/view/#1020360302008071849
	if Client.GetPublishRegion() ~= "GLOBAL" then
		local day = timeSecond / (24 * 60 * 60);
		strDelTips = string.format(Client.GetTableData("LocalizeRes", "4707").TextValue, tostring(math.floor(day)));
	end

	--jaysunzhu dominicwang review。只有全球版才需要GDPR。以下是特殊用法，正确用法参考http://tapd.oa.com/iGameInternational/markdown_wikis/view/#1020360302008071849
	--如果是日韩，且已经在删号期间，则直接弹出告警提示
	if Client.GetPublishRegion() ~= "GLOBAL" and BP_krjp_del_account_left_time > 0 then
		SettingKoreaDeleteAccountUI:ConfirmKoreaDeleteAccount();
	else
		SettingGDPRUI:ShowNoticeBox(1, Client.GetTableData("LocalizeRes", "101001").TextValue, 
			strDelTips, 
			Client.GetTableData("LocalizeRes", "4113").TextValue, 
			Client.GetTableData("LocalizeRes", "4112").TextValue, confirmDelete, regretDelete, 10);
	end
	
end

function SettingGDPRUI:ConfirmDeleteAccount()
	local function deleteAccount()
		log("[CCW]SettingGDPRUI:ConfirmDeleteAccount  deleteAccount");
		if LoginSystem.isInLobby == true and LoginSystem.isCanDeleteOp == true then
            EUGDPRSystem.DeleteAccountReq(true, true);
        end 
	end

	local function regretDelete()     
    	log("[CCW]SettingGDPRUI:ConfirmDeleteAccount  regretDelete");     
		if LoginSystem.isInLobby == true and LoginSystem.isCanDeleteOp == true then
            EUGDPRSystem.SendPrivacyToServer(1);
        end 
    end

    local timeSecond = 7 * 24 * 60 * 60;
    if LoginSystem.commonSwitch.EUGDPRDelAccountTime ~= nil then
		timeSecond = LoginSystem.commonSwitch.EUGDPRDelAccountTime;
		log("[CCW]SettingGDPRUI:ConfirmDeleteAccount, timeSecond = " .. timeSecond);
	end

	-- 时间精确到小时
	local day = timeSecond / (24 * 60 * 60)
	local hours = (day - math.floor(day)) * 24
	local timeStr = tostring(math.floor(day))..Client.GetTableData("LocalizeRes", "301367").TextValue;
	if hours > 0 then
		timeStr = timeStr .. tostring(math.floor(hours)) .. Client.GetTableData("LocalizeRes", "1215").TextValue;
	end
	local msg = string.format(Client.GetTableData("LocalizeRes", "4487").TextValue, timeStr);

	SettingGDPRUI:ShowNoticeBox(0, Client.GetTableData("LocalizeRes", "101001").TextValue, 
		msg, --.."\n"..Client.GetTableData("LocalizeRes", "4323").TextValue, --联系客服 超链接
		Client.GetTableData("LocalizeRes", "4114").TextValue, 
		Client.GetTableData("LocalizeRes", "4112").TextValue, deleteAccount, regretDelete);

end

function SettingGDPRUI:AskForPrivacyPolicy()
	showPrivacyAgreement();
	-- 5/10 改为直接弹出隐私协议查看界面
	-- local function confirmRejectPolicy()   
	-- 	log("[CCW]SettingGDPRUI:AskForPrivactPolicy  confirmRejectPolicy");     
	-- 	SettingGDPRUI:ConfirmRejectPolicy();
 --    end
	-- SettingGDPRUI:ShowSelectBox(Client.GetTableData("LocalizeRes", "101001").TextValue, 
	-- 	Client.GetTableData("LocalizeRes", "4102").TextValue, 
	-- 	Client.GetTableData("LocalizeRes", "117035").TextValue, --同意
	-- 	Client.GetTableData("LocalizeRes", "117036").TextValue, --拒绝 
	-- 	nil, confirmRejectPolicy, showPrivacyAgreement);
end

function SettingGDPRUI:ConfirmRejectPolicy()
	local function quitGame()
		log("[CCW]SettingGDPRUI:ConfirmRejectPolicy  quitGame");
		LuaClassObj.HandleUIMessage(bp_setting_gdpr, "RejectPolicy");
		LoginSystem.sendLogout();
	end

	local function backToPolicy()
		log("[CCW]SettingGDPRUI:ConfirmRejectPolicy  backToPolicy");
		SettingGDPRUI:AskForPrivacyPolicy();
	end
	SettingGDPRUI:ShowNoticeBox(0, Client.GetTableData("LocalizeRes", "101001").TextValue, 
		Client.GetTableData("LocalizeRes", "4103").TextValue, 
		Client.GetTableData("LocalizeRes", "4114").TextValue, 
		Client.GetTableData("LocalizeRes", "4142").TextValue, quitGame, backToPolicy);
end


--GDPR流程

local function backToAskForEUGDPR()   
	log("backToAskForEUGDPR"); 
	SettingGDPRUI:AskForEUGDPR();
	EUGDPRSystem.SendPrivacyToServer(1);
end

function SettingGDPRUI:AskForEUGDPR()
	local function confirmRejectEUGDPR()   
		log("[CCW]SettingGDPRUI:AskForEUGDPR  confirmRejectEUGDPR");     
		EUGDPRSystem.SendPrivacyToServer(2); 
		SettingGDPRUI:ConfirmRejectEUGDPR();
    end
	SettingGDPRUI:ShowSelectBox(Client.GetTableData("LocalizeRes", "4378").TextValue, 
		Client.GetTableData("LocalizeRes", "4380").TextValue, 
		Client.GetTableData("LocalizeRes", "301346").TextValue, --接受
		Client.GetTableData("LocalizeRes", "4111").TextValue, --不同意
		 nil, confirmRejectEUGDPR);
end

function SettingGDPRUI:ConfirmRejectEUGDPR()
	local function deleteAccount()   
		log("[CCW]SettingGDPRUI:ConfirmRejectEUGDPR  deleteAccount"); 
		EUGDPRSystem.SendPrivacyToServer(2);    
		SettingGDPRUI:AskForDeleteAccountForGDPR();
    end

    SettingGDPRUI:ShowNoticeBox(0, Client.GetTableData("LocalizeRes", "101001").TextValue, 
    	Client.GetTableData("LocalizeRes", "4373").TextValue, 
    	Client.GetTableData("LocalizeRes", "4113").TextValue, 
    	Client.GetTableData("LocalizeRes", "4142").TextValue, deleteAccount, backToAskForEUGDPR);
end

function SettingGDPRUI:AskForDeleteAccountForGDPR()
	local function confirmDelete() 
		log("[CCW]SettingGDPRUI:AskForDeleteAccount  confirmDelete");       
		SettingGDPRUI:ConfirmDeleteAccountForGDPR();
    end

	SettingGDPRUI:ShowNoticeBox(1, Client.GetTableData("LocalizeRes", "101001").TextValue, 
		Client.GetTableData("LocalizeRes", "4379").TextValue, 
		Client.GetTableData("LocalizeRes", "4113").TextValue, 
		Client.GetTableData("LocalizeRes", "4112").TextValue, confirmDelete, backToAskForEUGDPR, 10);
end

function SettingGDPRUI:ConfirmDeleteAccountForGDPR()
	local function deleteAccount()
		log("[CCW]SettingGDPRUI:ConfirmDeleteAccountForGDPR  deleteAccount");
		EUGDPRSystem.DeleteAccountReq(true, true);
	end

    local timeSecond = 7 * 24 * 60 * 60;
    if LoginSystem.commonSwitch.EUGDPRDelAccountTime ~= nil then
		timeSecond = LoginSystem.commonSwitch.EUGDPRDelAccountTime;
		log("[CCW]SettingGDPRUI:ConfirmDeleteAccount, timeSecond = " .. timeSecond);
	end

	-- 时间精确到小时
	local day = timeSecond / (24 * 60 * 60)
	local hours = (day - math.floor(day)) * 24
	local timeStr = tostring(math.floor(day))..Client.GetTableData("LocalizeRes", "301367").TextValue;
	if hours > 0 then
		timeStr = timeStr .. tostring(math.floor(hours)) .. Client.GetTableData("LocalizeRes", "1215").TextValue;
	end
	local msg = string.format(Client.GetTableData("LocalizeRes", "4356").TextValue, timeStr);

	SettingGDPRUI:ShowNoticeBox(0, Client.GetTableData("LocalizeRes", "101001").TextValue, 
		msg, --.."\n"..Client.GetTableData("LocalizeRes", "4323").TextValue, --联系客服 超链接
		Client.GetTableData("LocalizeRes", "4114").TextValue, 
		Client.GetTableData("LocalizeRes", "4112").TextValue, deleteAccount, backToAskForEUGDPR);

end



-- 家长允许流程

function SettingGDPRUI:AskForParentAllow()
	local function confirmParentNotAllow()   
		log("[CCW]SettingGDPRUI:AskForParentAllow  confirmParentNotAllow");   
		SettingGDPRUI:ConfirmParentNotAllow();
    end

    -- 增加隐私协议查看渠道
    local privacyString = [[<a id="GDPRHyperLink" style="GDPRLink" url="privacy">]]..Client.GetTableData("LocalizeRes", "4150").TextValue..[[</>]];

    SettingGDPRUI:ShowSelectBox(Client.GetTableData("LocalizeRes", "4381").TextValue, 
    	Client.GetTableData("LocalizeRes", "4391").TextValue,--.."\n"..privacyString, -- 您是否获得家长许可进行游戏？
    	Client.GetTableData("LocalizeRes", "4110").TextValue, 
    	Client.GetTableData("LocalizeRes", "4115").TextValue, nil, confirmParentNotAllow);
end

function SettingGDPRUI.OnHyperLinkClicked(MetaData)
    log("SettingGDPRUI.OnHyperLinkClicked")
    if MetaData.id == "GDPRHyperLink" and MetaData.url == "privacy" then
        showPrivacyAgreement();
    elseif MetaData.id == "GDPRHyperLink" and MetaData.url == "CustomerService" then
    	SettingUI.OpenCustomerService();
    end
end

function SettingGDPRUI:ConfirmParentNotAllow()
	local function regretParentNotAllow()
		log("[CCW]SettingGDPRUI:AskForParentAllow  regretParentNotAllow"); 
		SettingGDPRUI:AskForParentAllow();
	end

	local function confirm()
		log("[CCW]SettingGDPRUI:AskForParentAllow  confirm"); 
		EUGDPRSystem.SendStateToServer(5);		
		EUGDPRSystem.DeleteAccountReq(true, false);
		SettingGDPRUI:ParentNotAllow();
	end
	SettingGDPRUI:ShowNoticeBox(1, Client.GetTableData("LocalizeRes", "101001").TextValue, 
		Client.GetTableData("LocalizeRes", "4392").TextValue, 
		Client.GetTableData("LocalizeRes", "110036").TextValue, 
		Client.GetTableData("LocalizeRes", "110035").TextValue, 
		confirm, regretParentNotAllow, 10);
end

function SettingGDPRUI:ParentNotAllow()
	local function quitGame()
		log("[CCW]SettingGDPRUI:ParentNotAllow  quitGame"); 
		LoginSystem.sendLogout();
	end

	local function askForDeleteAccountimmediately()
		SettingGDPRUI:AskForDeleteAccountimmediately();
	end

	local timeSecond = 36 * 60 * 60;
    if LoginSystem.commonSwitch.EUGDPRChangeParentAgreeTime ~= nil then
		timeSecond = LoginSystem.commonSwitch.EUGDPRChangeParentAgreeTime;
		log("[CCW]SettingGDPRUI:ParentNotAllow, timeSecond = " .. timeSecond);
	end

	local timeStr = tostring(math.floor(timeSecond / (24 * 60 * 60)))..Client.GetTableData("LocalizeRes", "301367").TextValue;
	local msg = string.format(Client.GetTableData("LocalizeRes", "4117").TextValue, timeStr);

	SettingGDPRUI:ShowNoticeBox(0, Client.GetTableData("LocalizeRes", "101001").TextValue, 
		Client.GetTableData("LocalizeRes", "4375").TextValue,--.."\n"..msg, 
		Client.GetTableData("LocalizeRes", "4114").TextValue, 
		Client.GetTableData("LocalizeRes", "4353").TextValue, quitGame, askForDeleteAccountimmediately);
end

function SettingGDPRUI:AskForDeleteAccountimmediately()
	local function quitGame()
		log("[CCW]SettingGDPRUI:AskForDeleteAccountimmediately  quitGame"); 
		LoginSystem.sendLogout();
	end

	local function deleteAccountimmediately()
		EUGDPRSystem.DeleteAccountImmediatelyReq();
	end

	SettingGDPRUI:ShowNoticeBox(0, Client.GetTableData("LocalizeRes", "101001").TextValue, 
		Client.GetTableData("LocalizeRes", "4447").TextValue, 
		Client.GetTableData("LocalizeRes", "4114").TextValue, 
		Client.GetTableData("LocalizeRes", "110036").TextValue, quitGame, deleteAccountimmediately);
end
