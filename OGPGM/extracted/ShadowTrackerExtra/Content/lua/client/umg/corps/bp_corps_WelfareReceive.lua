--[[
	军团福利UI
--]]

CorpsWelfareReceiveUI = CorpsWelfareReceiveUI or 
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

BP_STRUCT_WelfareReceiveData = {
	uid = 0,
	count = 0,
	resId = 0,
	receiveTime = "",
	BP_STRUCT_BASE_INFO = BP_STRUCT_BASE_INFO,
}

BP_ARRAY_WelfareReceiveDataList = {
	BP_STRUCT_WelfareReceiveData = _G.BP_STRUCT_WelfareReceiveData;
}

-- 注册Widget
function bp_corps_WelfareReceive_RegisterUI()
	log("bp_corps_WelfareReceive_RegisterUI")
	LuaClassObj.SubUIWidgetList(bp_corps_WelfareReceive,
    	{{Path="/Game/UMG/UI_Logic/Corps/CropsReceivingrecords_BP.CropsReceivingrecords_BP_C", Container="Default", ZOrder = BP_ENUM_UI_OPEN_BOX_ZORDER + 1}},
    	{"Lobby"},
		false,
		false,
		true
  	);
end

function CorpsWelfareReceiveUI.Init()
	CorpsWelfareSystem.GetCorpsWelfareReceiveData();
	if BP_ARRAY_WelfareReceiveDataList and #BP_ARRAY_WelfareReceiveDataList > 0 then
		--显示记录
		LuaClassObj.HandleDynamicCreation(bp_corps_WelfareReceive);
		LuaClassObj.HandleUIMessage(bp_corps_WelfareReceive, "UIShow");
		UIManager.Show(eUIType.eCorpsWelfareReceiveUI)
	else
		--提示领奖
		--CommonMessageBoxUI:ShowPanel(2, "strTile", "strMsg", function() CorpsWelfareSystem.ReceiveCorpsWelfareReq(tonumber(BP_CurrentDetailTicketId)); end);	
	end
	
end

function CorpsWelfareReceiveUI.Release()
	BP_ARRAY_WelfareReceiveDataList = {};
end

function CorpsWelfareReceiveUI.Close()
	CorpsWelfareReceiveUI.Release();
	UIManager.Hide(eUIType.eCorpsWelfareReceiveUI)
	LuaClassObj.HandleUIMessage(bp_corps_WelfareReceive, "UIHide");
end

function CorpsWelfareReceiveUI.RefreshList()
	LuaClassObj.HandleUIMessage(bp_corps_WelfareReceive, "RefreshList");
end


function EventOnWelfareReceiveClose()
	CorpsWelfareReceiveUI.Close();
end







