--开黑豪礼奖励弹窗
RefluxTrainingAwardUI = RefluxTrainingAwardUI or {
	isOpen = false,

}

BP_RefluxTrainingAwardData = 
{
	id = 0,
	iconPath = "",
	num = 0,
	name = "",
}

BP_ARRAY_RefluxTrainingAwardList =
{
	BP_RefluxTrainingAwardData = _G.BP_RefluxTrainingAwardData
}

--注册Widget
function bp_reflux_training_award_RegisterUI()
  LuaClassObj.SubUIWidgetList(bp_reflux_training_award,
    {{Path="/Game/UMG/UI_Logic/RefluxTraining/RefluxTrainingAward_BP.RefluxTrainingAward_BP_C", Container="Default", ZOrder=BP_ENUM_UI_REFLUX_TRAINING_AWARD_ZORDER}},
    {"Lobby"},
	false,
	false,
	false
  );
	--songGT ver devide，暂时屏蔽掉，转移到资源下载结束后调用一次
	--安裝包里不包含，無需處理
	RefluxTrainingAwardUI.InitData()
end

function RefluxTrainingAwardUI.InitData()
	log("[HHF]RefluxTrainingAwardUI.InitData");
	BP_ARRAY_RefluxTrainingAwardList = {}
	local awardConfig = Client.GetTableData("RefluxExtraAwards", 11) 
    local drop_util = require("client.common.drop_util")
	local awardList = drop_util.GetDropsList({awardConfig.DropID})
	if awardList ~= nil then
		for _, v in ipairs(awardList) do 
			local itemConfig = Client.GetTableData("Item", v.DropItemID) 
			if itemConfig ~= nil then
				table.insert(BP_ARRAY_RefluxTrainingAwardList , {id = v.DropItemID,num = v.DropItemNum,iconPath = itemConfig.ItemBigIcon,name = itemConfig.ItemName})
			else
				log("[HHF]RefluxTrainingAwardUI.InitData, GetTableData(" .. v.DropItemID .. ") = nil");
			end
		end
	else
		log("[HHF]RefluxTrainingAwardUI.InitData, GetDropsList(" .. awardConfig.DropID .. ") = nil");
	end
end

function RefluxTrainingAwardUI.ShowUI()
	log("[HHF]RefluxTrainingAwardUI.ShowUI");
	RefluxTrainingAwardUI.isOpen = true
	LuaClassObj.HandleUIMessage(bp_reflux_training_award, "UIShow");
end

function RefluxTrainingAwardUI.CloseUI()
	log("[HHF]RefluxTrainingAwardUI.CloseUI");
	RefluxTrainingAwardUI.isOpen = false
	LuaClassObj.HandleUIMessage(bp_reflux_training_award, "UIClose");
end

function EventRefluxTrainingAwardUIClose()
	log("[HHF]EventRefluxTrainingAwardUIClose");
	RefluxMgr.GetRefluxAwards()
	RefluxTrainingAwardUI.CloseUI()
end

function RefluxTrainingAwardUI.Release()
	log("[HHF]RefluxTrainingAwardUI.Release");
end

