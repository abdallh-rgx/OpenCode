-- 万圣节载具 捣蛋活动
HalloweenVehicleAwardUI = HalloweenVehicleAwardUI or {

};

BP_STRUCT_Halloween_Vehicle_Item_Info = { --物品信息
	itemId = 0,
	itemCount = 1,
	index = 1, --在物品中的顺序
	itemExpireTime = 0,
}

BP_ARRAY_Halloween_Vehicle_Items = { --物品列表
	BP_STRUCT_Halloween_Vehicle_Item_Info = _G.BP_STRUCT_Halloween_Vehicle_Item_Info
}


BP_STRUCT_Halloween_Vehicle_Awards = {
	awardId = 0, --奖励id
	trickCount = 0, -- 捣蛋次数
	status = 0, --0 表示未领取，1 表示可领取 2 表示已领取
	lottery_num = 0, -- 需要达到的次数
	BP_ARRAY_Halloween_Vehicle_Items = _G.BP_ARRAY_Halloween_Vehicle_Items --奖励的物品
}

function bp_halloween_vehicle_award_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_halloween_vehicle_award,
                                {{Path="/Game/UMG/UI_Logic/HalloweenVehicle/Halloween_Vehicle_Award_BP.Halloween_Vehicle_Award_BP_C", Container="Default", ZOrder=BP_ENUM_UI_HALLOWEEN_VEHICLE_ZORDER + 1}},
                                {"Lobby"},
                                false,
                                false,
                                true);

end


function HalloweenVehicleAwardUI.SetData(Awards)
	BP_STRUCT_Halloween_Vehicle_Awards = Awards
end

function HalloweenVehicleAwardUI.ShowUI()
	log("HalloweenVehicleAwardUI.ShowUI")

    LuaClassObj.HandleDynamicCreation(bp_halloween_vehicle_award);

    LuaClassObj.HandleUIMessage(bp_halloween_vehicle_award, "UIShow");
end


function HalloweenVehicleAwardUI.HideUI()
    LuaClassObj.HandleUIMessageNoFetch(bp_halloween_vehicle_award, "UIHide");
end

--点击领取奖励
function EventHalloweenAwardClicked()
	if BP_STRUCT_Halloween_Vehicle_Awards.status == 1 then
		log("EventHalloweenAwardClicked take_lottery_award")
		LogicHalloweenVehicle.take_lottery_award(BP_STRUCT_Halloween_Vehicle_Awards.awardId)

		HalloweenVehicleAwardUI.HideUI()
		return
	end
	log("EventHalloweenAwardClicked cannot take_lottery_award")
end

function EventHalloweenVehicleAward_HideUI()
	HalloweenVehicleAwardUI.HideUI()
end