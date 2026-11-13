-- 冰雪节奖励
IceLuckyAwardUI = IceLuckyAwardUI or {

};

--BP_ARRAY_Ice_Gem_Curr_Awards = { --累计奖励
--	BP_STRUCT_Ice_Gem_Award_Status = _G.BP_STRUCT_Ice_Gem_Award_Status
--}

BP_STRUCT_Ice_Lucky_Awards = {
	awardId = 0, --奖励id
	snatchCount = 0, -- 捣蛋次数
	status = 0, --0 表示未领取，1 表示可领取 2 表示已领取
	targetSnatchNum = 0, -- 需要达到的次数
	BP_ARRAY_Ice_Gem_AccItems = 
	{
		tmp_UseExist_BP_STRUCT_Ice_Gem_Item_Info = {}, --奖励的物品
	}
}

function bp_ice_lucky_award_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_ice_lucky_award,
                                {{Path="/Game/UMG/UI_Logic/IceLucky/IceLucky_Award_BP.IceLucky_Award_BP_C", Container="Default", ZOrder=BP_ENUM_UI_ICE_LUCKY_ZORDER + 4}},
                                {"Lobby"},
                                false,
                                false,
                                true);

end


function IceLuckyAwardUI.SetData(Awards)
	BP_STRUCT_Ice_Lucky_Awards = Awards
end

function IceLuckyAwardUI.ShowUI()
	log("IceLuckyAwardUI.ShowUI")

    LuaClassObj.HandleDynamicCreation(bp_ice_lucky_award);

    LuaClassObj.HandleUIMessage(bp_ice_lucky_award, "UIShow");
end


function IceLuckyAwardUI.HideUI()
    LuaClassObj.HandleUIMessageNoFetch(bp_ice_lucky_award, "UIHide");
end

--点击领取奖励
function EventIceAwardClicked()
	if BP_STRUCT_Ice_Lucky_Awards.status == 1 then
		log("EventIceAwardClicked take_lottery_award")

		LogicIceLuckyGem.take_award_of_stage_award_req(BP_STRUCT_Ice_Lucky_Awards.awardId)

		IceLuckyAwardUI.HideUI()
		return
	end
	log("EventIceAwardClicked cannot take_lottery_award")
end

function EventIceAwardHideUI()
	log("EventIceAwardHideUI")
	IceLuckyAwardUI.HideUI()
end
