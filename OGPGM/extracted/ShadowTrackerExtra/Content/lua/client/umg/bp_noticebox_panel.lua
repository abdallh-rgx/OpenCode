CommonNoticeBoxUI = CommonNoticeBoxUI or 
{
	mySelf = nil,
	onClickOkCallback = nil,
	onClickCloseCallback = nil,
}

--标题和内容
BP_CommonNoticeBox_Title = "";
BP_CommonNoticeBox_Msg = "";
--OK按钮上的文字
BP_CommonNoticeBox_BtnOKTxt = "";
--Cancel按钮上的文字
BP_CommonNoticeBox_BtnCancelTxt = "";
-- 下方tips的文字
BP_CommonNoticeBox_Tips = "";
--1:只显示确定按钮 2:只显示关闭按钮，3：关闭和确定按钮都显示, 4: 关闭和确定按钮都显示，并显示下方tips
BP_CommonNoticeBox_style= 1;

-- 注册面板
function bp_noticebox_panel_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_noticebox_panel,
		{
			{Path="/Game/UMG/UI_BP/PopupNotice/NoticeBox_BP.NoticeBox_BP_C", Container="Top", ZOrder=BP_ENUM_UI_NOTICEBOX_ZORDER},
		 	{Path="/Game/UMG/UI_BP/PopupNotice/Gameplayerprotection/Protection08_UIBP.Protection08_UIBP_C", Container="Top", ZOrder=BP_ENUM_UI_BLOCK_ZORDER}
		},
		{"Lobby","Login","CreateRole"},
		false,
		false,
		true
	);
    EventSystem:registEvent(EVENTTYPE_LOGIN,EVENTID_BACKLOGIN, CommonNoticeBoxUI.on_backto_login);
end




--不做任何事，蓝图里调这个函数将把lua变量的值同步给蓝图变量
function EventFetchInfo()
	
end

function CommonNoticeBoxUI.on_backto_login()
	LuaClassObj.HandleUIMessage(bp_noticebox_panel, "UIHide");
end

function CommonNoticeBoxUI:ShowMessageBox(style, title, msg, btnOKText, btnCancelText, clickOkCallback, clickCloseCallback, tips)
	LuaClassObj.HandleDynamicCreation(bp_noticebox_panel);
    log("CommonNoticeBoxUI:ShowMessageBox"..style);
    BP_CommonNoticeBox_style = style;
	BP_CommonNoticeBox_Msg = msg;
    BP_CommonNoticeBox_Title = title;
    BP_CommonNoticeBox_BtnOKTxt = btnOKText;
    BP_CommonNoticeBox_BtnCancelTxt = btnCancelText;
    BP_CommonNoticeBox_Tips = tips or "";

	CommonNoticeBoxUI.mySelf = self;
	CommonNoticeBoxUI.mySelf.onClickOkCallback = clickOkCallback;
	CommonNoticeBoxUI.mySelf.onClickCloseCallback = clickCloseCallback;
    
    if style == 4 then
    	LuaClassObj.HandleUIMessage(bp_noticebox_panel, "UIShowWithTips");
    else
    	LuaClassObj.HandleUIMessage(bp_noticebox_panel, "UIShow");

	end	
end

function EventCommonNoticeBoxClickOK()
    log("CommonNoticeBoxUI:EventCommonNoticeBoxClickOK");
	if CommonNoticeBoxUI.mySelf.onClickOkCallback ~= nil then
		CommonNoticeBoxUI.mySelf.onClickOkCallback();
	end
end

function EventCommonNoticeBoxClickClose()
    log("CommonNoticeBoxUI:EventCommonNoticeBoxClickClose");
	if CommonNoticeBoxUI.mySelf.onClickCloseCallback ~= nil then
		CommonNoticeBoxUI.mySelf.onClickCloseCallback();
	end
end

function CommonNoticeBoxPanelAndroidBackHide()
	if BP_CommonNoticeBox_style == 4 then
    	LuaClassObj.HandleUIMessage(bp_noticebox_panel, "UIHideWithTips");
    else
    	LuaClassObj.HandleUIMessage(bp_noticebox_panel, "UIHide");
	end		
end