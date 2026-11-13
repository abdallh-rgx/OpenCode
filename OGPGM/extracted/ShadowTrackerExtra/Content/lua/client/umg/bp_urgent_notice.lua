UrgentNoticeUI = UrgentNoticeUI or 
{
}

BP_UrgentNoticeTitle = "";
BP_UrgentNoticeMsg = "";
BP_UrgentNoticeImgUrl = "";
BP_UrgentNoticeJump = "";
BP_UrgentNoticePos = 0;


--注册Widget
function bp_urgent_notice_RegisterUI()
  LuaClassObj.SubUIWidgetList(bp_urgent_notice,
	{{Path="/Game/UMG/UI_BP/Common/Common_MessageBox_News_UIBP.Common_MessageBox_News_UIBP_C", Container="default", ZOrder=BP_ENUM_UI_URGENT_NOTICE_BOX}},
    {"Lobby", "Login"},
    false,
    false,
	true
	);
end

--关闭或跳转打点
function EventJumpFromNews()
    BP_STRUCT_News_Log_Data.jump = 1;
    NetUtil.SendPkg("client_push_news_log", BP_STRUCT_News_Log_Data);
end

function EventCloseFromNews()
    BP_STRUCT_News_Log_Data.jump = 0;
    NetUtil.SendPkg("client_push_news_log", BP_STRUCT_News_Log_Data);
end

function UrgentNoticeUI:Init()
end

function UrgentNoticeUI:Release()
end

function UrgentNoticeUI:Hide()
	LuaClassObj.HandleUIMessage(bp_urgent_notice, "UIHide");
end

function UrgentNoticeUI.ShowMessageBox(title, msg, img, jump, pos)
	BP_UrgentNoticeMsg = msg;
    BP_UrgentNoticeTitle = title;
    BP_UrgentNoticeImgUrl = img;
    BP_UrgentNoticeJump = jump;
    BP_UrgentNoticePos = pos;
    LuaClassObj.HandleDynamicCreation(bp_urgent_notice);
    LuaClassObj.HandleUIMessage(bp_urgent_notice, "UIShow");
	LuaClassObj.HandleUIMessage(bp_urgent_notice, "ShowMsgBox");
end

function UrgentNoticeUI.ScrollToTop()
	LuaClassObj.HandleUIMessage(bp_urgent_notice, "ScrollToTop");
end