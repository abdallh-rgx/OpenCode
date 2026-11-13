

--聊天举报界面
ChatReport = ChatReport or 
{
	onClickOkCb = nil,
	onClickCancelCb = nil,
	isShowing = false,
}

-- 显示的信息
BP_Chat_ReportMsg = "";
-- 举报内容选项
BP_ARRAY_ReportItem = {
	""
};
-- 选择的内容项
BP_ReportSelect = -1;

-- 外挂 仇恨言论 垃圾信息 其他
local arrayItemId = {4962, 4963, 4964, 4965};

-- 注册面板
function bp_chat_report_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_chat_report,
		{
			{Path="/Game/UMG/UI_Logic/LobbyChat/ChatReport_LogicBp.ChatReport_LogicBp_C", Container="Top", ZOrder=BP_ENUM_UI_COMMON_MESSAGEBOX_ZORDER}
		},
		{"Lobby"},
		false,
		false,
		true
	);	
end

function ChatReport.ShowPanel(msg, onClickOkCb, onClickCancelCb)
	LuaClassObj.HandleDynamicCreation(bp_chat_report);

	ChatReport.onClickOkCb = onClickOkCb;
	ChatReport.onClickCancelCb = onClickCancelCb;
	
	BP_Chat_ReportMsg = msg;

	BP_ARRAY_ReportItem = {};
	BP_ReportSelect = -1;

	for k,v in ipairs(arrayItemId) do
		table.insert(BP_ARRAY_ReportItem, Client.GetTableData("LocalizeRes", v).TextValue);
	end

	LuaClassObj.HandleUIMessage(bp_chat_report, "UIShow");
end

function EventFetchInfo()
end

function EventChat_reportClickOK()
	local selectId;
	if BP_ReportSelect ~= -1 then
		selectId = arrayItemId[BP_ReportSelect + 1];
	end

	if ChatReport.onClickOkCb ~= nil then
		ChatReport.onClickOkCb(selectId);
	end
end

function EventChat_reportClickCancel()
	if ChatReport.onClickCancelCb ~= nil then
		ChatReport.onClickCancelCb();
	end
end

function EventChatReportNoSelectReason( )
	DataMgr.ShowNoticeByID(5021);
end
