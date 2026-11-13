SubscribeUI = SubscribeUI or
		{
			isshow = false
		}
----------------------------UIDATA Start-------------------------------------

BP_Normal_Productid = ""	--普通会员midas productid

BP_Super_Productid = ""		--高级会员midas productid

BP_Normal_MonthProductid = ""	--普通会员不连续的月卡 product id

BP_Super_MonthProductid = ""	--高级会员不连续的月卡 product id

BP_SubState = 0		--订阅状态

BP_IsFirstTimeOpenNormal = false --是否第一次开通普通订阅功能
BP_IsFirstTimeOpenSuper = false --是否第一次开通高级订阅功能

BP_IsOpenNormal = false		--是否开启了普通订阅
BP_IsOpenSuper = false		--是否开启了高级订阅

BP_NormalInfo = ""	--普通订阅会员优惠信息
BP_SuperInfo = ""	--高级订阅会员优惠信息

BP_NormalLeftTime = ""	--普通会员到期时间
BP_SuperLeftTime  = ""	--高级会员到期时间

BP_NormalUCNum = 0	--普通订阅奖励UC数量
BP_SuperUCNum = 0	--高级订阅奖励UC数量

BP_NormalIsOutOfTire = false	--是不是订阅过普通 过期的状态
BP_SuperIsOutOfTire = false		--是不是订阅过高级 过期的状态

BP_NormalPrice = "0.99"		--普通订阅价格 从米大师返回格式：$6.99
BP_SuperPrice = "4.99"		--高级订阅价格 从米大师返回格式：$6.99

BP_FirstMonth_NormalPrice = ""	--普通订阅首月优惠价格 从米大师返回格式：$6.99
BP_FirstMonth_SuperPrice = ""	--高级订阅首月优惠价格 从米大师返回格式：$6.99

BP_Normal_LoginGetUC = ""	--普通会员每日登陆领取UC
BP_Super_LoginGetUC = ""	--高级会员每日登陆领取UC

BP_Normal_IsAutoDeduct = false	--是否在连续订阅状态中
BP_Super_IsAutoDeduct = false	--是否在连续订阅状态中

BP_Normal_IsHaveDiscount = false --普通订阅是否有首冲折扣
BP_Super_IsHaveDiscount = false --高级订阅是否有首冲折扣

BP_STRUCT_FirstBuyReward =
{
	itemid = 0,
	itemnum = 0,
}

BP_Array_FirstBuyNormalInfo = 	--普通订阅会员首次购买奖励优惠信息
{
	BP_STRUCT_FirstBuyReward = _G.BP_STRUCT_FirstBuyReward
}

BP_Array_FirstBuySuperInfo = 	--高级订阅会员首次购买奖励优惠信息
{
	BP_STRUCT_FirstBuyReward = _G.BP_STRUCT_FirstBuyReward
}


----------------------------UIDATA End----------------------------------------

function bp_subscribe_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_subscribe,
			{{Path="/Game/UMG/UI_BP/Lobby_Store_Int/Lobby_Store_Member0115_UIBP.Lobby_Store_Member0115_UIBP_C", Container="Default", ZOrder=BP_ENUM_UI_RECHARGE_ZORDER+6}},
			{"Lobby"},
			false,
			true,
			true
	);
end

--准备数据供显示
function SubscribeUI.LoadData()
	-- body
	log_tree("BP_Array_FirstBuySuperInfo",BP_Array_FirstBuySuperInfo)
	BP_SubState = NewSubscribeSystem.GetSubStatus()

	SubscribeUI.LoadPrice()--处理普通和高级订阅折扣显示价格 同时带着普通价格...

	log("zino BP_Normal_MonthProductid ".. BP_Normal_MonthProductid)
	log("zino BP_Super_MonthProductid ".. BP_Super_MonthProductid)
	SubscribeUI.SafeProductIDHandle()
end

--如果后台传入productid失败，保底
function SubscribeUI.SafeProductIDHandle()
	-- body
	if BP_Normal_Productid == ""	then
		BP_Normal_Productid = "com.tencent.ig.auto.prime"
	end
	if BP_Super_Productid == ""	then
		BP_Super_Productid = "com.tencent.ig.auto.primeplus"
	end
	if BP_Normal_MonthProductid == ""	then
		BP_Normal_MonthProductid = "com.tencent.ig.monthcard"
	end
	if BP_Super_MonthProductid == ""	then
		BP_Super_MonthProductid = "com.tencent.ig.monthcardplus"
	end
end

--初始化UI
function SubscribeUI.InitUI()
	log("handle bp_subscribe")
	SubscribeUI.isshow = true
	SubscribeUI.LoadData()	--load全部数据后显示

	SubscribeUI.ReadAtLeastIntroPrice()	--读取保底折扣数据
	SubscribeUI.ReadAtLeastPrice()	--读取保底价格数据
	LuaClassObj.HandleDynamicCreation(bp_subscribe)
	LuaClassObj.HandleUIMessage(bp_subscribe, "UIShow")
	UIManager.Show(eUIType.eSubscribeUI);
end


--收到米大师打折回调信息  EVENTID_MIDAS_GET_INTRO_PRICE_INFO_NOTIFY 的回调
function SubscribeUI.LoadIntroPriceFromCached(evenType, eventID, resultCode)
	-- body

	log("LoadIntroPriceFromCached"..tostring(resultCode))

	if status then
		local productid_str = string.format("%s,%s",BP_Normal_Productid,BP_Super_Productid)
		local isProductInfoCached,cachedProductInfoList = MidasManager.LoadCachedMidasIntroPrice(productid_str);
		if isProductInfoCached then
			log_tree("zino cachedProductInfoList", cachedProductInfoList)

			SubscribeUI.GetMidasGoodsInfo(evenType, eventID, cachedProductInfoList)	--处理非打折价格

			SubscribeUI.GetMidasIntroInfo(evenType, eventID, cachedProductInfoList)	--处理打折价格
		else
			log("no reason to go here if go here find alex")
		end
	end
	ConnectionWaitingUI:Hide()
end

--有缓存了 读取打折数据
function SubscribeUI.GetMidasIntroInfo(evenType, eventID, resultTable)
	-- body

	if (resultTable == nil) then
		log("GetMidasIntroInfo读取数据失败");
		ConnectionWaitingUI:Hide()
		return;
	end
	log_tree("zino GetMidasIntroInfo resultTable", resultTable);

	for k,product in pairs(resultTable) do
		if MidasManager.ShouldShowLocalCurrency(product.currency) == false then
			return;
		end

		if product.productId  and product.intro_price and product.intro_gwallet_num and product.intro_ios_num then
			if product.productId == BP_Super_Productid then

				log("product.introPrice ".. product.intro_price)

				BP_FirstMonth_SuperPrice = product.intro_price
				BP_FirstMonth_SuperPrice = string.gsub(FuncUtil.GetLocalizeResStr("6378"),"{0}",BP_FirstMonth_SuperPrice)
				log("BP_FirstMonth_SuperPrice " .. BP_FirstMonth_SuperPrice)
				BP_Super_IsHaveDiscount = true
			end
			SubscribeUI.UIRefreshPrice()
		else
			log("GetMidasIntroInfo 拉取数据失败")
		end
	end


	ConnectionWaitingUI:Hide()

end

--收到米大师回调的订阅价格信息
function SubscribeUI.GetMidasGoodsInfo(evenType, eventID, resultTable)

	if (resultTable == nil) then
		log("GetMidasPriceInfo拉取数据失败");
		ConnectionWaitingUI:Hide()
		return;
	end
	log_tree("zino GetMidasGoodsInfo resultTable", resultTable);

	for k,product in pairs(resultTable) do
		if MidasManager.ShouldShowLocalCurrency(product.currency) == false then
			return;
		end

		if product.productId ~= nil and product.price ~= nil then
			if product.productId == BP_Normal_Productid then
				log("product.Normalprice "..product.price)
				BP_NormalPrice = product.price
				SubscribeUI.GetSymbol(false)

			elseif product.productId == BP_Super_Productid then
				log("product.Superprice "..product.price)
				BP_SuperPrice = product.price
				SubscribeUI.GetSymbol(true)
			end



			SubscribeUI.UIRefreshPrice()
		else
			log("GetMidasGoodsInfo 拉取数据失败")
		end
	end

	ConnectionWaitingUI:Hide()

end


-- 拉取打折价格和正常的价格
function SubscribeUI.LoadPrice()
	-- body
	BP_FirstMonth_NormalPrice = ""
	BP_FirstMonth_SuperPrice = ""

	if BP_Normal_Productid~= "" and BP_Super_Productid~= "" then
		local productid_str = string.format("%s,%s",BP_Normal_Productid,BP_Super_Productid)
		local isProductInfoCached,cachedProductInfoList = MidasManager.LoadCachedMidasIntroPrice(productid_str);
		if isProductInfoCached then
			log_tree("zino cachedProductInfoList", cachedProductInfoList)
			SubscribeUI.GetMidasGoodsInfo(EVENTTYPE_MIDAS_NOTIFY, EVENTID_MIDAS_GET_INTRO_PRICE_INFO_NOTIFY, cachedProductInfoList)	--处理非打折价格
			SubscribeUI.GetMidasIntroInfo(EVENTTYPE_MIDAS_NOTIFY,EVENTID_MIDAS_GET_INTRO_PRICE_INFO_NOTIFY,cachedProductInfoList)
		else
			ConnectionWaitingUI:Show()
			local funcCall1 = function() ConnectionWaitingUI:Hide() end
			Timer.InsertTimer(20, funcCall1, false, false)
			log("LoadMidasProductIntroInfo")
			Client.LoadMidasIntroPrice(productid_str)
		end
	end
end


--根据订阅状态处理价格调用的本地化符号
--Normal == false
--Super == true
function SubscribeUI.GetSymbol(NormalOrSuper)
	-- body
	if NormalOrSuper then	--高级的处理
		if BP_IsOpenSuper then
			BP_SuperPrice = string.gsub(FuncUtil.GetLocalizeResStr("6377"),"{0}",BP_SuperPrice)
		else
			if not BP_SuperIsOutOfTire then	--没购买过的 有优惠价格 等midas
				BP_SuperPrice = string.gsub(FuncUtil.GetLocalizeResStr("6378"),"{0}",BP_SuperPrice)
			end
		end
	else		--普通订阅处理
		if BP_IsOpenNormal then
			BP_NormalPrice = string.gsub(FuncUtil.GetLocalizeResStr("6377"),"{0}",BP_NormalPrice)
		else
			if not BP_NormalIsOutOfTire then	--没购买过的 有优惠价格 等midas
				BP_NormalPrice = string.gsub(FuncUtil.GetLocalizeResStr("6378"),"{0}",BP_NormalPrice)
			end
		end
	end

end
--没拿到或者不需要midas价格数据，处理保底价格
function SubscribeUI.ReadAtLeastPrice()
	-- body

	if BP_NormalPrice == "" then

		BP_NormalPrice = NewSubscribeSystem._NormalInfo._tablePrice    --有误 读取保底价格
		SubscribeUI.GetSymbol(false)
	end
	if BP_SuperPrice == "" then

		BP_SuperPrice = NewSubscribeSystem._SuperInfo._tableSUperPrice	--有误 读取保底价格
		SubscribeUI.GetSymbol(true)
	end
end

--没拿到或者不需要midas价格数据，处理保底折扣价格
function SubscribeUI.ReadAtLeastIntroPrice()
	-- body
	log("BP_FirstMonth_NormalPrice"  ..BP_FirstMonth_NormalPrice)
	log("BP_FirstMonth_SuperPrice"  ..BP_FirstMonth_SuperPrice)
	if BP_FirstMonth_NormalPrice == "" then
		BP_FirstMonth_NormalPrice = string.gsub(FuncUtil.GetLocalizeResStr("6378"),"{0}",NewSubscribeSystem._NormalInfo._tablePriceMonth)	--有误 读取保底折扣价格
	end
	if BP_FirstMonth_SuperPrice == "" then
		BP_FirstMonth_SuperPrice = string.gsub(FuncUtil.GetLocalizeResStr("6378"),"{0}",NewSubscribeSystem._SuperInfo._tablePriceMonth)	--有误 读取保底折扣价格
	end
end

--界面刷新价格
function SubscribeUI.UIRefreshPrice()
	log("SubscribeUI.UIRefreshPrice "..tostring(SubscribeUI.isshow))
	if SubscribeUI.isshow then
		LuaClassObj.HandleUIMessage(bp_subscribe, "UIUpdateSuperStatus");
		LuaClassObj.HandleUIMessageNoFetch(bp_subscribe, "UIUpdateNormalStatus");
	end
end

--控制是否显示第一次进入的图标
function SubscribeUI.IsShowLobbySignal()
	-- body
	return false
end

--购买后 刷新UI
function SubscribeUI.RefreshUIAfterBuy()
	-- body
	log("zino UIRefreshAfterBuy1")
	if SubscribeUI.isshow then
		log("zino UIRefreshAfterBuy2")
		LuaClassObj.HandleUIMessage(bp_subscribe, "UIRefreshAfterBuy");
	end
end

--优惠信息描述
function SubscribeUI.Set_Describe(type,describeList)
	-- body
	log_tree("describeList",describeList)
	local bp_primestring = ""
	if type and describeList and next(describeList) then
		bp_primestring = ""
		for key, value in pairs(describeList) do
			-- body
			if bp_primestring and bp_primestring == "" then
				bp_primestring = value.Describe
			else
				bp_primestring = bp_primestring.."\n"..value.Describe
			end
		end
	end
	if type == NewSubscribeSystem.ENUM_SubId.Normal then
		BP_NormalInfo = bp_primestring
		log("BP_NormalInfo " .. BP_NormalInfo)
	elseif type == NewSubscribeSystem.ENUM_SubId.Super then
		BP_SuperInfo = bp_primestring
		log("BP_SuperInfo " .. BP_SuperInfo)
	end


end
----------------------------Event Start--------------------------------------

--点击普通订阅
function EventClickedNormalSubscribe()
	-- body
	ConnectionWaitingUI:Show();
	local funcCall1 = function() ConnectionWaitingUI:Hide() end
	Timer.InsertTimer(20, funcCall1, false, false)
end

--点击高级订阅
function EventClickedSuperSubscribe()
	-- body
	ConnectionWaitingUI:Show();
	local funcCall1 = function() ConnectionWaitingUI:Hide() end
	Timer.InsertTimer(20, funcCall1, false, false)
end

--点问号
function EventClickedRule()
	-- body
	local title = FuncUtil.GetLocalizeResStr("6371")
	local content = FuncUtil.GetLocalizeResStr("6372")
	PopUpNoticeUI.ShowMessageBox(title,content);
end


function EventSubscribe_Close()
	log("close subscribe")
	UIManager.Hide(eUIType.eSubscribeUI);
	SubscribeUI.isshow = false
end

----------------------------Event End-------------------------------------



