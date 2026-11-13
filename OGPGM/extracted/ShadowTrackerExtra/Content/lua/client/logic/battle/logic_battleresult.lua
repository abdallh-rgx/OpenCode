
BattleResult = BattleResult or 
{
	resultAvatarPoseNormal = 0;
	resultAvatarPoseAim = 1;
	resultAvatarPoseCrouch = 2;
}

function BattleResult.on_game_result(uid, result)
	--
	log_tree("on_game_result_uid", uid);
	log_tree("on_game_result", result);

	ResetResultMonitor();
	NetUtil.BBattleResultRecieved = true;
	--BattleResultUI.OnBattleResult(uid, result);

	-- 新版本拼多多红包
	if uid.battle_gid_newyear_ext ~= nil and uid.battle_gid_newyear_ext ~= 0 then
		RedPacketSystem.ResetPDDUrl();
		BattleResult.battleNewyearGIDExt = uid.battle_gid_newyear_ext;
		local leftTime = 2;
		if uid.newyear_ext_maxnum ~= nil and  uid.newyear_ext_getnum ~= nil then
			leftTime = uid.newyear_ext_maxnum - uid.newyear_ext_getnum ;
		end

		local delaytime = 2;
		if uid.Reason ~= "win" then 
			delaytime = 12;
		end

		if _G.BP_Platform == BP_ENUM_PLAYFORM_WX or _G.BP_Platform == BP_ENUM_PLAYFORM_QQ then
			--SharePDDHBUI.SetRoomId(uid.battle_gid_newyear_ext, leftTime);
			--SharePDDHBUI.SetDelayShowTime(delaytime);
			--LuaClassObj.HandleUIMessage(bp_share_pddhb, "ShowUI");
		end
	end

	-- 春节红包
	if uid.battle_gid_newyear ~= nil and uid.battle_gid_newyear ~= 0 then
		RedPacketSystem.ResetShareUrl();
		BattleResult.battleNewyearGID = uid.battle_gid_newyear;
		local leftTime = 2;
		if uid.newyear_maxnum ~= nil and  uid.newyear_getnum ~= nil then
			leftTime = uid.newyear_maxnum - uid.newyear_getnum - 1 ;
		end

		local delaytime = 2;
		if uid.Reason ~= "win" then 
			delaytime = 12;
		end

		if _G.BP_Platform == BP_ENUM_PLAYFORM_WX or _G.BP_Platform == BP_ENUM_PLAYFORM_QQ then
			ShareCJHBUI.SetRoomId(uid.battle_gid_newyear, leftTime);
			ShareCJHBUI.SetDelayShowTime(delaytime);
			LuaClassObj.HandleUIMessage(bp_share_cjhb, "ShowUI");
		end
	end

	--吃鸡红包
	if uid.battle_gid ~= nil and uid.battle_gid ~= 0 then
		BattleResult.battleGID = uid.battle_gid;
		log("on_test_game_result roomid = "..uid.battle_gid);
		local leftMoney = 0;
		local totalMoney = 0;
		if uid.redpacktype == 2 then
			--黑金
			leftMoney = uid.cj_redpack_remainnum;
			totalMoney = uid.cj_redpack_allnum;
		elseif uid.redpacktype == 1 then
			--普通
			leftMoney = uid.cj_n_redpack_remainnum;
			totalMoney = uid.cj_redpack_allnum_normal;
		end
		ShareNromalCJHBUI.Show(uid.redpacktype,  leftMoney, totalMoney);
	end
	
	BP_BattleResultNeedShowAd = false
	
	--开始加载广告
	if uid.push_ad ~= nil and uid.push_ad == true then
		log("BattleResult push_ad : " .. tostring(uid.push_ad));
		BattleResultUI.ShowAdvertiseButton()
		BP_BattleResultNeedShowAd = true
	end
	

	BattleResultUI.OnBattleResult(0, uid);
	
	FriendSystem.getRecentTeammate()
end

function BattleResult.on_game_over( game_id )
	log("on_game_over:" .. game_id);
	if g_game_id == game_id then
		BattleResultUI.OnGameOver(game_id);
	end
end

--发给OB的结算信息
function BattleResult.on_game_result_ob(result)
    --log_tree("on_game_result_ob", result);
	result.isobserver=true
	--InGameUIManager.HandleUIMessage(observe, "Hide");
	--BattleResultUI.OnBattleResult(0, result);
end

function BattleResult.SendTestGetResult()
	log("SendTestGetResult")
	NetUtil.SendPkg("test_gameresult_req");
end

function BattleResult.on_test_game_result(result_gs)
	log("on_test_game_result")
	--log_tree("on_test_game_result = ", result_gs);

	-- 新版本拼多多红包
	if result_gs.battle_gid_newyear_ext ~= nil and result_gs.battle_gid_newyear_ext ~= 0 then
		RedPacketSystem.ResetPDDUrl();
		BattleResult.battleNewyearGIDExt = result_gs.battle_gid_newyear_ext;
		local leftTime = 2;
		if result_gs.newyear_ext_maxnum ~= nil and  result_gs.newyear_ext_getnum ~= nil then
			leftTime = result_gs.newyear_ext_maxnum - result_gs.newyear_ext_getnum;
		end

		local delaytime = 2;
		--[[if result_gs.Reason == "win" then 
			delaytime = 12;
		end]]
		
		if _G.BP_Platform == BP_ENUM_PLAYFORM_WX or _G.BP_Platform == BP_ENUM_PLAYFORM_QQ then
			--SharePDDHBUI.SetRoomId(result_gs.battle_gid_newyear_ext, leftTime);
			--SharePDDHBUI.SetDelayShowTime(delaytime);
			--LuaClassObj.HandleUIMessage(bp_share_pddhb, "ShowUI");
		end
	end

	-- 春节红包
	if result_gs.battle_gid_newyear ~= nil and result_gs.battle_gid_newyear ~= 0 then
		RedPacketSystem.ResetShareUrl();
		BattleResult.battleNewyearGID = result_gs.battle_gid_newyear;
		local leftTime = 2;
		if result_gs.newyear_maxnum ~= nil and result_gs.newyear_getnum ~= nil then
			leftTime = result_gs.newyear_maxnum - result_gs.newyear_getnum - 1 ;
		end

		local delaytime = 2;

		if _G.BP_Platform == BP_ENUM_PLAYFORM_WX or _G.BP_Platform == BP_ENUM_PLAYFORM_QQ then
			ShareCJHBUI.SetRoomId(result_gs.battle_gid_newyear, leftTime);
			ShareCJHBUI.SetDelayShowTime(delaytime);
			LuaClassObj.HandleUIMessage(bp_share_cjhb, "ShowUI");
		end 
	end
	
	--吃鸡红包
	if result_gs.battle_gid ~= nil and result_gs.battle_gid ~= 0 then
		BattleResult.battleGID = result_gs.battle_gid;
		log("on_test_game_result roomid = "..result_gs.battle_gid);
		local leftMoney = 0;
		local totalMoney = 0;
		if result_gs.redpacktype == 2 then
			--黑金
			leftMoney = result_gs.cj_redpack_remainnum;
			totalMoney = result_gs.cj_redpack_allnum;
		elseif result_gs.redpacktype == 1 then
			--普通
			leftMoney = result_gs.cj_n_redpack_remainnum;
			totalMoney = result_gs.cj_redpack_allnum_normal;
		end
		ShareNromalCJHBUI.Show(result_gs.redpacktype,  leftMoney, totalMoney);
	end

end

function BattleResult.on_game_finished_ob_result(room_result)
	--log_tree("ob_game_result", room_result);
	BattleResultUI.ShowOBBattleResult(room_result)
end

function BattleResult.on_upvote_res(uid, name)
	log("BattleResult.on_upvote_res uid:"..uid.." name:"..name);
	BattleResultUI.ShowUpvoteTips(uid, name);
	TeamUpUI.ShowUpvoteTips(uid, name);
end

function BattleResult.enter_room_battle_watch()
	log("BattleResult.enter_room_battle_watch");
	LoadingUI:Init();
	NetUtil.SendPkg("enter_room_battle_watch")
end

function BattleResult.on_enter_room_battle_watch_rsp(reason)
	log("BattleResult.on_enter_room_battle_watch_rsp reason:"..tostring(reason));

	local strTile = DataMgr.GetMsgByID(102012);
	local strMsg = "";	
	if reason == "watch_game_over" or reason == "game_over" or reason == "no_ob_game" then
		strMsg = Client.GetTableData("LocalizeRes",301111).TextValue;
	else
		strMsg = Client.GetTableData("LocalizeRes",501150).TextValue;
	end
	
	CommonMessageBoxUI:ShowPanel(1, strTile, strMsg, 
	function()
		curStatus = string.lower(LuaClassObj.GetGameStatus(bp_lobby));
		if curStatus == "fighting" then
			--如果在战斗中  返回大厅
			Client.ReturnToLobby(GameFrontendHUD);
						
		elseif LobbySystem.isWaittingEnterBattle then
			-- 重置匹配状态
			LobbySystem.SetWaitingBattleFlag(false);
			-- 关闭loading
			LoadingUI.RefreshLoadPercent(1);
			Client.ReturnToLobby(GameFrontendHUD);
		end
	end
	);			
end

-- 请求观战历史战绩
function BattleResult.get_ob_battle_info_rsp(ret, uid, ob_mode, ob_battle_record)
	log("get_ob_battle_info_rsp [ret:"..ret.."][uid:"..uid.."][ob_mode:"..ob_mode.."]");
	log_tree("ob_battle_record:", ob_battle_record);
	local playerOBBattleInfo = {};
	playerOBBattleInfo.UID = uid;
	if ret == "ok" and ob_battle_record ~= nil and ob_battle_record.game_num ~= nil then
		playerOBBattleInfo.ValidBattleInfo = true;
		playerOBBattleInfo.BattleMode = ob_mode;
		playerOBBattleInfo.GameCount = ob_battle_record.game_num;
		playerOBBattleInfo.WinCount = ob_battle_record.win_num;
		playerOBBattleInfo.TopTenCount = ob_battle_record.top10;
		playerOBBattleInfo.KillNum = ob_battle_record.kill_num;
		playerOBBattleInfo.KDNum = ob_battle_record.kd;
	else
		playerOBBattleInfo.ValidBattleInfo = false;
		playerOBBattleInfo.BattleMode = 0;
		playerOBBattleInfo.GameCount = 0;
		playerOBBattleInfo.WinCount = 0;
		playerOBBattleInfo.TopTenCount = 0;
		playerOBBattleInfo.KillNum = 0;
		playerOBBattleInfo.KDNum = 0;
	end
	log_tree("playerOBBattleInfo:", playerOBBattleInfo);
	BattleResultUI.OnGetOBPlayerBattleInfo(playerOBBattleInfo);
end

--[[网络回调]]--
s2c["game_result"] = BattleResult.on_game_result;
s2c["on_game_over"] = BattleResult.on_game_over;
s2c["game_result_ob"] = BattleResult.on_game_result_ob;
s2c["test_gameresult_res"] = BattleResult.on_test_game_result;
s2c["cust_room_result"] = BattleResult.on_game_finished_ob_result;
s2c["upvote_res"] = BattleResult.on_upvote_res;
s2c["enter_room_battle_watch_rsp"] = BattleResult.on_enter_room_battle_watch_rsp

-- 请求观战历史战绩
--c2s.get_ob_battle_info_req(uid, mode)
s2c["get_ob_battle_info_rsp"] = BattleResult.get_ob_battle_info_rsp; --请求观战历史战绩
