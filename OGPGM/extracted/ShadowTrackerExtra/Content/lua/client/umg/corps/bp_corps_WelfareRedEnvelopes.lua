--[[
	收到触发分享军团福利
--]]
CorpsWelfareRedEnvelopesUI = CorpsWelfareRedEnvelopesUI or 
{
	
};

BP_STRUCT_WelfareRedEnvelopes_ItemData =
{
	res_id = 0,
	count = 0,
	valid_hours = 0,
	expire_ts = 0,
};

BP_ARRAY_WelfareRedEnvelopes_ItemData =
{
    BP_STRUCT_WelfareRedEnvelopes_ItemData = _G.BP_STRUCT_WelfareRedEnvelopes_ItemData, --定义结构体数组，这种写法要作为规范规定下来
};

BP_RedEnvelopes_Count = 0;
BP_RedEnvelopes_IsAnonymous = false;
BP_RedEnvelopes_IsConfirm = true;

-- 注册Widget
function bp_corps_WelfareRedEnvelopes_RegisterUI()
	log("bp_corps_WelfareRedEnvelopes_RegisterUI")
	LuaClassObj.SubUIWidgetList(bp_corps_WelfareRedEnvelopes,
    	{{Path="/Game/UMG/UI_Logic/Corps/CorpsRedEnvelopes_Item_BP.CorpsRedEnvelopes_Item_BP_C", Container="Default", ZOrder = BP_ENUM_UI_WEFLARE_SHARE_TIP + 1}},
    	{"Lobby"},
		false,
		false,
		true
  	);
	BP_ARRAY_WelfareRedEnvelopes_ItemData = {};
end

function CorpsWelfareRedEnvelopesUI.ShowPanel()
	if BP_RedEnvelopes_Count > 0 then
		LuaClassObj.HandleUIMessage(bp_corps_WelfareRedEnvelopes, "UIShow");
		UIManager.Show(eUIType.eCorpsWelfareRedEnvelopes)
	end
end

function CorpsWelfareRedEnvelopesUI.ReceiveData(arrayItemData)
	--log("CorpsWelfareRedEnvelopesUI.Show");
	
	LuaClassObj.HandleDynamicCreation(bp_corps_WelfareRedEnvelopes);
	
	--BP_ARRAY_WelfareRedEnvelopes_ItemData = {};

	for k,v in pairs(arrayItemData) do
		if v and v.res_id and v.res_id ~= 0 then
			local item = {}
			item.res_id = v.res_id
			item.count = v.count or 0
			item.valid_hours = v.valid_hours or 0
			item.expire_ts = v.expire_ts or 0
			table.insert(BP_ARRAY_WelfareRedEnvelopes_ItemData, item)
		end
	end

	--for i, v in pairs(BP_ARRAY_WelfareRedEnvelopes_ItemData) do
	--	if v.res_id == 0 then
	--		BP_ARRAY_WelfareRedEnvelopes_ItemData[i] = nil
	--	end
	--end

	BP_RedEnvelopes_Count = #BP_ARRAY_WelfareRedEnvelopes_ItemData;
end

function CorpsWelfareRedEnvelopesUI.Close()
	BP_ARRAY_WelfareRedEnvelopes_ItemData = {};
	BP_RedEnvelopes_Count = 0;
	LuaClassObj.HandleUIMessage(bp_corps_WelfareRedEnvelopes, "UIHide");
	UIManager.Hide(eUIType.eCorpsWelfareRedEnvelopes)
end

function CorpsWelfareRedEnvelopesUI.GotoWelfare()
	--关闭十连抽和商城界面
	OpenBoxtUI.HidePanel();
	MallSystemUI_2.isFromLeague = 2;
	EventStartCloseMallSystem();
	UnknowPassLevelUp.HideUI();
	CorpsBaseUI.Init();
	local t = Timer.InsertTimer(0.5, DelayWelfareRedEnvelopesJumpCorps, false, true);
end

function DelayWelfareRedEnvelopesJumpCorps()
	CorpsBaseUI.JumpToPage(CorpsBaseUI.PageWelfare);
	CorpsMgr.isJumpFromMall = true;
end

function CorpsWelfareRedEnvelopesUI.SendTrue()
	BP_RedEnvelopes_IsConfirm = true;
	CorpsWelfareSystem.CorpsWelfareReq(BP_RedEnvelopes_IsConfirm, BP_RedEnvelopes_IsAnonymous);
end

function CorpsWelfareRedEnvelopesUI.SendFalse()
	BP_RedEnvelopes_IsConfirm = false;
	CorpsWelfareSystem.CorpsWelfareReq(BP_RedEnvelopes_IsConfirm, BP_RedEnvelopes_IsAnonymous);
end

function EventOnWelfareRedEnvelopesClose()
	--log("BP_RedEnvelopes_IsConfirm.." .. tostring(BP_RedEnvelopes_IsConfirm))
	--log("BP_RedEnvelopes_IsAnonymous.." .. tostring(BP_RedEnvelopes_IsAnonymous))
	if BP_RedEnvelopes_IsConfirm then
		--确定派发，直接发送
		CorpsWelfareSystem.CorpsWelfareReq(BP_RedEnvelopes_IsConfirm, BP_RedEnvelopes_IsAnonymous);
	else
		--弹出二次确认
		CommonMessageBoxUI:ShowPanel(2, FuncUtil.GetLocalizeResStr("5074"), FuncUtil.GetLocalizeResStr("5079"), CorpsWelfareRedEnvelopesUI.SendTrue, CorpsWelfareRedEnvelopesUI.SendFalse, FuncUtil.GetLocalizeResStr("5076"), FuncUtil.GetLocalizeResStr("5075"));
	end
	CorpsWelfareRedEnvelopesUI.Close();
end





