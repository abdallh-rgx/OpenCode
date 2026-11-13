LeagueGameSignUpPop = LeagueGameSignUpPop or {
	
}

function LeagueGameSignUpPop.SignReq(zoneId, isFpp)
	NetUtil.SendPkg("carteam_enroll_league_req", zoneId, isFpp);
end

function LeagueGameSignUpPop.SignRsp(ok, reason, team_id, uid, enroll_zone_id, is_tpp, last_cancel_enroll_time)
	log("LeagueGameSignUpPop.SignRsp ok" .. tostring(ok));
	log("LeagueGameSignUpPop.SignRsp reason" .. reason);
	if not ok then
		if reason == 505036 then
			log("505036");
			local timeStr = FuncUtil.GetTimeBySec(1800);
			if LeagueGameSystem.EnrollCdTime > 0 then
				local sec = (last_cancel_enroll_time + LeagueGameSystem.EnrollCdTime) - FuncUtil.GetServerTimeInSec();
				if sec > 0 then
					timeStr = FuncUtil.GetTimeBySec(sec);
				else
					timeStr = FuncUtil.GetTimeBySec(5);
				end
			end
			PopUpNoticeUI.ShowNewNotice( string.gsub(Client.GetTableData("LocalizeRes", "6329").TextValue, "{0}", tostring(timeStr)));
		else
			PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", reason).TextValue);
		end
	else
		PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", 6045).TextValue);
		--LeagueGameSystem.Enter();
		LeagueGameSystem.LeagueGameInfoReq(false);
	end
end

s2c["carteam_enroll_league_rsp"] = LeagueGameSignUpPop.SignRsp;
