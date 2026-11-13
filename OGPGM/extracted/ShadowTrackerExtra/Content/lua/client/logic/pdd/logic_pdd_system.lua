PDD_System_Logic = PDD_System_Logic or {
	pddSystem_Time = {},

	can_show = false,
	can_buy = false,

	bNeedShow = false,
}

--拉取拼多多活动信息
function PDD_System_Logic.pdd_bargain_get_activity_req(bNeedShow)
	log("[HHF]PDD_System_Logic.pdd_bargain_get_activity_req, bNeedShow = " .. tostring(bNeedShow));
	PDD_System_Logic.bNeedShow = bNeedShow or false;
    NetUtil.SendPkg("pdd_bargain_get_activity_req");
    --NetUtil.SendPriorityPkg(false, "query_direct_buy_info_rsp", "query_direct_buy_info", itemId);
end

function PDD_System_Logic.pdd_bargain_get_activity_rsp(res, can_show, can_buy, cfg, left_time, now_time)
	log("[HHF]PDD_System_Logic.pdd_bargain_get_activity_rsp, res = " .. tostring(res) .. 
		", can_show = " .. tostring(can_show) .. 
		", can_buy = " .. tostring(can_buy) .. 
		", left_time = " .. tostring(left_time) ..
		", now_time = " .. tostring(now_time));
	--log_tree("[HHFTEST]PDD_System_Logic.pdd_bargain_get_activity_rsp, cfg = ", cfg, "[HHFTEST]");
	
	if res == 0 then
		PDD_System_Logic.can_show = can_show;
		PDD_System_Logic.can_buy = can_buy;
		PDD_System_Logic.pddSystem_Time = cfg;
		Bargain_System_UI.SetServerTime(now_time);


		if cfg ~= nil and cfg.max_help_cnt ~= nil then
			BP_BargainDetail_MaxHelpTime = cfg.max_help_cnt;
		end
		
		if can_buy or can_show then
			PDD_System_UI.InitLocalData();
			LobbyUI.UpdatePDDSystemReddot();

			if PDD_System_Logic.bNeedShow == true then
				PDD_System_UI.ShowBargain(PDD_System_UI.showShopID);
			end
		else
			if PDD_System_Logic.bNeedShow == true then
				LobbyUI.UpdatePDDSystemReddot();
				Bargain_Logic.ShowTipsByErrorCode(Bargain_Logic.pdd_bargain_errcode_not_in_period);
			end
		end
	else
		if PDD_System_Logic.bNeedShow == true then
			if res == Bargain_Logic.pdd_bargain_errcode_not_in_period then
				PDD_System_Logic.can_buy = false;
				PDD_System_Logic.can_show = false;
				LobbyUI.UpdatePDDSystemReddot();
			end
			Bargain_Logic.ShowTipsByErrorCode(res);
		end
	end
end

function PDD_System_Logic.ResetData()
	log("[HHF]PDD_System_Logic.ResetData");
	PDD_System_Logic.pddSystem_Time = {};
	PDD_System_Logic.can_show = false;
	PDD_System_Logic.can_buy = false;
	Bargain_System_UI.serverTime = 0;
end


s2c["pdd_bargain_get_activity_rsp"] = PDD_System_Logic.pdd_bargain_get_activity_rsp;
