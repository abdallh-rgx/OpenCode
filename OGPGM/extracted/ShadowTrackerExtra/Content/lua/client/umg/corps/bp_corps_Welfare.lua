--[[
	军团福利UI
--]]

CorpsWelfareUI = CorpsWelfareUI or 
{

};

BP_STRUCT_BASE_INFO = {
    strUid = "",
    Name = "",
    Level = 1,
    Sex = 1,
    RankIntegralLevel = 1,
    IconUrl = "",
    IconFrameID  = 1,
    lastOnlineTimeStr = "",

    -- 绝地通行证
    upass_is_buy = 0, --是否购买(1为已购买，0为未购买)
    upass_is_show = 0, --是否显示(1为显示，0为不显示)
    --国籍
    nation = "",
}

BP_STRUCT_WelfareItemData = {
	owner_uid = 0, 			-- 谁发的
	share_sum_ticket = 0, 	-- 一共发多少UC
	remain_ticket = 0,		-- 还剩多少UC
	res_id = 0,				-- 购买的物品ID
	share_ticket_id = "", 	-- 分享的红包ID
	max_recevie_num = 0, 	-- 最大可领次数
	create_time = 0,		-- 红包创建时间
	have_recevie_num = 0,  	-- 已经领取的次数
	elapse_time = "",  		-- 红包发了多久
	state = 0,				-- 红包状态 (1:可领取,2:已领取,3:已领完)
	is_anonymous = false, 	-- 是否匿名
	BP_STRUCT_BASE_INFO = BP_STRUCT_BASE_INFO, -- 个人信息
}

BP_ARRAY_WelfareDataList = {
	BP_STRUCT_WelfareItemData = _G.BP_STRUCT_WelfareItemData;
}

BP_CurrentDetailTicketId = "";


-- 注册Widget
function bp_corps_Welfare_RegisterUI()
	log("bp_corps_Welfare_RegisterUI")
	LuaClassObj.SubUIWidgetList(bp_corps_Welfare,
    	{{Path="/Game/UMG/UI_Logic/Corps/CorpsWelfare_BP.CorpsWelfare_BP_C", Container="Default", ZOrder = BP_ENUM_UI_OWN_CORPS_ZORDER + 1}},
    	{"Lobby"},
		false,
		false,
		true
  	);
  	CorpsBaseUI.RegisterCallBacks(CorpsBaseUI.PageWelfare, CorpsWelfareUI.Init, CorpsWelfareUI.Close);
end

function CorpsWelfareUI.Init()
	CorpsWelfareSystem.GetCorpsWelfareListReq();
	-- show一次，防止和主界面出现层级错误
	CorpsBaseUI.JustShowUI();	
	UIManager.Show(eUIType.eCorpsBaseUI);
	LuaClassObj.HandleDynamicCreation(bp_corps_Welfare);
	LuaClassObj.HandleUIMessage(bp_corps_Welfare, "UIShow");
	UIManager.Show(eUIType.eCorpsWelfareUI)
	Is_Corps_Welfare_Have_Receive = false;
	UpdateLobbyCorpsRedDot(CorpsMgr.HasRedDot("lobby"));
	EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_APPLYLIST);
end

function CorpsWelfareUI.Release()
	BP_STRUCT_BASE_INFO = {};
	BP_STRUCT_WelfareItemData = {};
	BP_ARRAY_WelfareDataList = {};
	BP_CurrentDetailTicketId = "";
end

function CorpsWelfareUI.Close()
	CorpsWelfareUI.Release();
	UIManager.Hide(eUIType.eCorpsWelfareUI)
	LuaClassObj.HandleUIMessage(bp_corps_Welfare, "UIHide");
end

function CorpsWelfareUI.RefreshList()
	LuaClassObj.HandleUIMessage(bp_corps_Welfare, "RefreshList");
end


function CorpsWelfareUI.UpdateRedPoint()
	CorpsBaseUI.UpdateRedPoint();
end

function EventOnGetWelfareClick()
	--log("BP_CurrentDetailTicketId.."..BP_CurrentDetailTicketId)
	CorpsWelfareSystem.ReceiveCorpsWelfareReq(tonumber(BP_CurrentDetailTicketId));
end

function EventOnShowReceiveDetailClick()
	CorpsWelfareReceiveUI.Init();
end

function EventOnShowWelfareDescription()
	local title = Client.GetTableData("LocalizeRes", "5061").TextValue
    local context = Client.GetTableData("LocalizeRes", "5051").TextValue
    context = string.gsub(context, "\\n", "\n")
    PopUpNoticeUI.ShowMessageBox(title, context)
end