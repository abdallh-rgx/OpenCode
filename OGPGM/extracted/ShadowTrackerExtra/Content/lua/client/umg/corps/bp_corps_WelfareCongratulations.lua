--[[
	收到触发分享军团福利
--]]
CorpsWelfareCongratulationsUI = CorpsWelfareCongratulationsUI or 
{
	onClickCallback = nil,
};

BP_STRUCT_WelfareCongratulations_ItemData =
{
	res_id = 0,
	count = 0,
	valid_hours = 0,
	expire_ts = 0,
};

BP_ARRAY_WelfareCongratulations_ItemData =
{
    BP_STRUCT_WelfareCongratulations_ItemData = _G.BP_STRUCT_WelfareCongratulations_ItemData, --定义结构体数组，这种写法要作为规范规定下来
};

BP_WelfareCongratulations_ItemLength = 0;


-- 注册Widget
function bp_corps_WelfareCongratulations_RegisterUI()
	log("bp_corps_WelfareCongratulations_RegisterUI")
	LuaClassObj.SubUIWidgetList(bp_corps_WelfareCongratulations,
    	{{Path="/Game/UMG/UI_Logic/Corps/CorpsCongratulations_BP.CorpsCongratulations_BP_C", Container="Default", ZOrder = BP_ENUM_UI_OPEN_BOX_ZORDER + 1}},
    	{"Lobby"},
		false,
		false,
		true
  	);
end

function CorpsWelfareCongratulationsUI.ShowPanel(arrayItemData)
	LuaClassObj.HandleDynamicCreation(bp_corps_WelfareCongratulations);
	CorpsWelfareCongratulationsUI.onClickCallback = nil;

	BP_ARRAY_WelfareCongratulations_ItemData = {};

	for k,v in pairs(arrayItemData) do
		if v and v.res_id then
			local item = {}
			item.res_id = v.res_id
			item.count = v.count or 0
			item.valid_hours = v.valid_hours or 0
			item.expire_ts = v.expire_ts or 0
			BP_ARRAY_WelfareCongratulations_ItemData[#BP_ARRAY_WelfareCongratulations_ItemData + 1] = item
		end
	end
	BP_WelfareCongratulations_ItemLength = #BP_ARRAY_WelfareCongratulations_ItemData;
	LuaClassObj.HandleUIMessage(bp_corps_WelfareCongratulations, "UIShow");
end


function CorpsWelfareCongratulationsUI.Close()
	BP_ARRAY_WelfareCongratulations_ItemData = {};
	if CorpsWelfareCongratulationsUI.onClickCallback ~= nil then
		CorpsWelfareCongratulationsUI.onClickCallback()
		CorpsWelfareCongratulationsUI.onClickCallback = nil
	end
	LuaClassObj.HandleUIMessage(bp_corps_WelfareCongratulations, "UIHide");
	CorpsWelfareRedEnvelopesUI.Show(BP_WelfareCongratulations_ItemLength);
end


function EventOnWelfareCongratulationsClose()
	CorpsWelfareCongratulationsUI.Close();
end





