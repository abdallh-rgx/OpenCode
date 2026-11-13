--sami 商城红点模块
StoreRedDotModel = 
{
	MODEL_ID_TAB1 = 1,		--一级页签
	MODEL_ID_TAB2 = 2,		--二级页签
	MODEL_ID_SUPPLY = 3,	--补给红点
	
	--红点数据表
	reddotMap = {}
}


--接收商城红点协议数据
function StoreRedDotModel.OnRecvReddotRsp(res)
	log_tree("[HHF]StoreRedDotModel.OnRecvReddotRsp, res = ", res, "[HHF]");
	if res == nil then
		return
	end

	--StoreRedDotModel.reddotMap = {	}
	--StoreRedDotModel.reddotMap[StoreRedDotModel.MODEL_ID_TAB1] = {}
	--StoreRedDotModel.reddotMap[StoreRedDotModel.MODEL_ID_TAB2] = {}
	--StoreRedDotModel.reddotMap[StoreRedDotModel.MODEL_ID_SUPPLY] = {}
	for k,v in pairs(res) do
		--补给
		if k == StoreRedDotModel.MODEL_ID_SUPPLY then
			for kk,vv in pairs(v) do
				if StoreRedDotModel.reddotMap[StoreRedDotModel.MODEL_ID_SUPPLY] == nil then
					StoreRedDotModel.reddotMap[StoreRedDotModel.MODEL_ID_SUPPLY] =  {}
				end
				StoreRedDotModel.reddotMap[StoreRedDotModel.MODEL_ID_SUPPLY][kk] = true
			end
		else
			--一级二级
			for kk,vv in pairs(v) do
				local id1 = math.modf(kk/100)

				if StoreRedDotModel.reddotMap[StoreRedDotModel.MODEL_ID_TAB1] == nil then
					StoreRedDotModel.reddotMap[StoreRedDotModel.MODEL_ID_TAB1] = {}
				end

				if StoreRedDotModel.reddotMap[StoreRedDotModel.MODEL_ID_TAB2] == nil then
					StoreRedDotModel.reddotMap[StoreRedDotModel.MODEL_ID_TAB2] = {}
				end

				if id1 == 0 then
					StoreRedDotModel.reddotMap[StoreRedDotModel.MODEL_ID_TAB1][kk] = true
				else
					StoreRedDotModel.reddotMap[StoreRedDotModel.MODEL_ID_TAB1][id1] = true
					StoreRedDotModel.reddotMap[StoreRedDotModel.MODEL_ID_TAB2][kk] = true
				end
			end
		end
	end

	if FuncUtil:CountTable(StoreSystem.collection_red_dot) > 0 then
		log("[HHF]StoreRedDotModel.OnRecvReddotRsp, set collect tab reddot = true.");
		StoreRedDotModel.reddotMap[StoreRedDotModel.MODEL_ID_TAB1][StoreSystem.Page_ID_Collect] = true;
	end
end

--判断是否有红点
function StoreRedDotModel.HasRedDot(tab1Id, tab2Id, bSupply)
	log("StoreRedDotModel.HasRedDot tab1Id="..tab1Id..",tab2Id="..tab2Id)

	--第一版商城全部红点
	local bNewbie = StoreRedDotModel.HasTabNewbie(tab1Id, tab2Id, bSupply)
	if bNewbie then
		return true
	end
	--补给
	if bSupply then
		if StoreRedDotModel.reddotMap[StoreRedDotModel.MODEL_ID_SUPPLY] == nil then
			return false
		end
		if StoreRedDotModel.reddotMap[StoreRedDotModel.MODEL_ID_SUPPLY][tab1Id] == nil then
			return false
		end
		return true
	end
	--一级
	if tab2Id == 0 then
		if StoreRedDotModel.reddotMap[StoreRedDotModel.MODEL_ID_TAB1] == nil then
			return false
		end
		if StoreRedDotModel.reddotMap[StoreRedDotModel.MODEL_ID_TAB1][tab1Id] == nil then
			return false
		end
		return true
	end
	--二级
	if StoreRedDotModel.reddotMap[StoreRedDotModel.MODEL_ID_TAB2] == nil then
		return false
	end
	if StoreRedDotModel.reddotMap[StoreRedDotModel.MODEL_ID_TAB2][tab2Id] == nil then
		return false
	end
	return true
end

--设置红点map
function StoreRedDotModel.SetRedDotMap(tab1Id, tab2Id, bSupply)
	log("StoreRedDotModel.SetRedDotMap tab1Id="..tab1Id..",tab2Id="..tab2Id)
	--补给
	if bSupply then
		if StoreRedDotModel.reddotMap[StoreRedDotModel.MODEL_ID_SUPPLY] == nil then
			return
		end
		StoreRedDotModel.reddotMap[StoreRedDotModel.MODEL_ID_SUPPLY][tab1Id] = nil
	end
	--一级
	if tab2Id == 0 then
		if StoreRedDotModel.reddotMap[StoreRedDotModel.MODEL_ID_TAB1] == nil then
			return
		end
		if tab1Id ~= StoreSystem.Page_ID_Collect then
			StoreRedDotModel.reddotMap[StoreRedDotModel.MODEL_ID_TAB1][tab1Id] = nil
		end
	end
	--二级
	if StoreRedDotModel.reddotMap[StoreRedDotModel.MODEL_ID_TAB2] == nil then
		return
	end
	StoreRedDotModel.reddotMap[StoreRedDotModel.MODEL_ID_TAB2][tab2Id] = nil
end

function StoreRedDotModel.SetCollectionTabRedDotMap(itemID)
	if StoreSystem.collection_red_dot[itemID] ~= nil then
		StoreSystem.collection_red_dot[itemID] = nil;

		if FuncUtil:CountTable(StoreSystem.collection_red_dot) == 0 then
			log("[HHF]StoreRedDotModel.SetCollectionTabRedDotMap, set collect tab reddot = false.");
			StoreRedDotModel.reddotMap[StoreRedDotModel.MODEL_ID_TAB1][StoreSystem.Page_ID_Collect] = nil;

			--EventStoreMainUI_Click_Tab();
			StoreMainUI.UpdateTabListRedDot();
			StoreMainUI.InitShowTabListData();
			LuaClassObj.HandleUIMessageNoFetch(bp_store_main, "UpdateTab");
		end
	end
end

--判断新手标记
function StoreRedDotModel.HasTabNewbie(tab1Id, tab2Id, bSupply)
	local key = 0
	if bSupply then
		key = tab1Id
	elseif tab2Id == 0 then
		key = tab1Id
	else
		key = tab2Id
	end
	if key == 0 then
		return false
	end
	--商城不走新手
	if not bSupply then
		return false
	end
	local bNewbie = DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_NEW_STORE, key);
	return bNewbie
end

--设置新手标记
function StoreRedDotModel.SetTabNewbie(tab1Id, tab2Id, bSupply)
	local key = 0
	if bSupply then
		key = tab1Id
	elseif tab2Id == 0 then
		key = tab1Id
	else
		key = tab2Id
	end
	if key == 0 then
		return
	end
	--商城不走新手
	if not bSupply then
		return
	end
	local bNewbie = DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_NEW_STORE, key);
	if not bNewbie then
		return
	end
	DataMgr.SetNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_NEW_STORE, key);
end

function StoreRedDotModel.HasLobbyRedDot()
	--第一次商城入口红点
	local bNewbie = DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_NEW_STORE, 1);
	if bNewbie then
		return true
	end
	local redNum = StoreMainUI.UpdateTabListRedDot()
	if redNum > 0 then
		log("[HHF]StoreRedDotModel.HasLobbyRedDot = true");
		return true
	else
		log("[HHF]StoreRedDotModel.HasLobbyRedDot = false");
		return false
	end
end

function StoreRedDotModel.HasLobbySupplyRedDot()
	local redNum = SupplyMainUI.GetTabRedDotNum()
	if redNum > 0 then
		return true
	end

	local discountRedNum = SupplyMainUI.GetTabDiscountRedDotNum()
	if discountRedNum > 0 then
		return true
	else
		return false
	end
end

function StoreRedDotModel.HasStoreSupplyRedDot()
    return StoreRedDotModel.HasLobbySupplyRedDot();
end

