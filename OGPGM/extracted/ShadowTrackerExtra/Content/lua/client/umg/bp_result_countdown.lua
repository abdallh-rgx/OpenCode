-- 战斗内即将结算倒计时
function bp_result_countdown_RegisterUI(self)
	LuaClassObj.SubUIWidgetList(bp_result_countdown,
		{
			{Path="/Game/BluePrints/ControlInput/IngameUI/GameOverTips_UIBP.GameOverTips_UIBP_C", Container="Default", ZOrder=BP_ENUM_UI_RANK_ZORDER},
		},
		{"Fighting"},
		false,
		true,
		true
		);

end

BP_ResultCountDown_Time = 0;
BP_ResultCountDown_IsTerminator = false;
--ResultCountDown_DynamicCreateUI(30, 0)
function ResultCountDown_DynamicCreateUI(delay_time, is_terminator)
	log("ResultCountDown_DynamicCreateUI:" .. delay_time);
	BP_ResultCountDown_Time = delay_time;
	BP_ResultCountDown_IsTerminator = is_terminator;
	LuaClassObj.HandleDynamicCreation(bp_result_countdown);
	LuaClassObj.HandleUIMessage(bp_result_countdown, "ShowCountDownUI");
end

function ResultCountDown_Show()
	ResultCountDown_DynamicCreateUI(30);
end

function EventSkipToShowBattleResult()
	BattleResultUI.SkipToShowBattleResult();
end