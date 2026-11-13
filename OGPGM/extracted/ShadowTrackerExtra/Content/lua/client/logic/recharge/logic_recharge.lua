
--[[
 充值相关逻辑
]]--

RechargeSystem = RechargeSystem or
{
	hotCfgStr = "";
}


function RechargeSystem.Enter()
	
end

function RechargeSystem.Release()
end


--获取邮件附件响应
function RechargeSystem.IGameGetChargeHotTagRsp(state, cfg)
	if state ~= "ok" then
		return;
	end
	if cfg == nil then
		return;
	end

	cfg = FuncUtil:StrTrim(cfg);
	if cfg == "" then
		return;
	end
	RechargeSystem.hotCfgStr = cfg;
	EventSystem:postEvent(EVENTTYPE_RECHARGE, EVENTID_RECHARGE_OFFTYPE, cfg);
end


--拉取热卖和超值标记
function RechargeSystem.IGameGetChargeHotTagReq()
	NetUtil.SendPkg("igame_get_charge_hot_tag")
end

--[[网络回调]]--
s2c["igame_get_charge_hot_tag_rsp"] = RechargeSystem.IGameGetChargeHotTagRsp
