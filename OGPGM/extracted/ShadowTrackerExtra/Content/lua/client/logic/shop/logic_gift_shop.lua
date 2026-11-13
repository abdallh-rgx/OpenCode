
--[[
 赠送索取相关逻辑
]]--
LogicGiftShop = LogicGiftShop or
{
	needShowWnd = true,
	askInfo = {},
}

--索取次数请求
function LogicGiftShop.market_get_askinfo_req(needShowWnd)
	log("samcen market_get_askinfo_req  client call")
	LogicGiftShop.needShowWnd = needShowWnd
	NetUtil.SendPriorityPkg(false, "market_get_askinfo_rsp", "market_get_askinfo_req");
end

--获取列表响应
function LogicGiftShop.market_get_askinfo_rsp(res, askInfo)
	log("samcen market_get_askinfo_rsp  client call")
	LogicGiftShop.askInfo = askInfo
	if LogicGiftShop.needShowWnd then
		ShopGiftUI:Init()
	end
 end

 function LogicGiftShop.Release()
 	LogicGiftShop.askInfo = {}
 end

 function LogicGiftShop.CheckWantGiftTimesOK(friendGID, timesLimit)
 	if LogicGiftShop.askInfo == nil then
		log("samcen EventGiftUISendOrWant LogicGiftShop.askInfo == nil")
		return true
	end

	-- 索取次数是否超了
	local askInfo = LogicGiftShop.askInfo[tonumber(friendGID)]
	local curAskNum = nil
	if askInfo ~= nil then
		curAskNum = askInfo.asknum
	end

	if curAskNum ~= nil and curAskNum >= timesLimit then
		log("samcen EventGiftUISendOrWant askNum >= timesLimit")
		return false
	else
		if curAskNum == nil then
			log("samcen EventGiftUISendOrWant askNum == nil")
		else
			log("samcen EventGiftUISendOrWant askNum:"..curAskNum)
		end
		return true
	end
 end

--[[网络回调]]--
s2c["market_get_askinfo_rsp"] = LogicGiftShop.market_get_askinfo_rsp;

