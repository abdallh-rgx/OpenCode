--sami 跳转框架类
JumpUtils = 
{
	MODEL_ID_STORE = 10001,		--新商城
	MODEL_ID_SUPPLY = 10002,	--新补给
	MODEL_ID_PASS = 10003,		--pass
	MODEL_ID_LOBBY = 10004,		--大厅
	MODEL_ID_FULL_PREVIEW = 10005,	--商城全屏预览
	MODEL_ID_PET = 10006,       --宠物
	--跳转映射关系表
	jumpMap = {},
	
	--跳转来源映射表
	itemJumpMap = {},
	
	--是否有数据
	bGetJumpMap = false,
	region = "GLOBAL",
}


--初始化
function JumpUtils.Init()
	JumpUtils.region = Client.GetPublishRegion();
	JumpUtils.bGetJumpMap = false
	JumpUtils.RegisterJump(JumpUtils.MODEL_ID_STORE, JumpUtils.MODEL_ID_SUPPLY, SupplyMainUI.JumpFromStoreToSupply)
	JumpUtils.RegisterJump(JumpUtils.MODEL_ID_LOBBY, JumpUtils.MODEL_ID_STORE, StoreMainUI.JumpFromLobbyToStore)
	JumpUtils.RegisterJump(JumpUtils.MODEL_ID_LOBBY, JumpUtils.MODEL_ID_PASS, UnknowPassUI.JumpFromLobbyToPass)
	JumpUtils.RegisterJump(JumpUtils.MODEL_ID_LOBBY, JumpUtils.MODEL_ID_SUPPLY, SupplyMainUI.JumpFromLobbyToSupply)
	JumpUtils.RegisterJump(JumpUtils.MODEL_ID_STORE, JumpUtils.MODEL_ID_PASS, UnknowPassUI.JumpFromStoreToPass)
	JumpUtils.RegisterJump(JumpUtils.MODEL_ID_SUPPLY, JumpUtils.MODEL_ID_PASS, UnknowPassUI.JumpFromSupplyToPass)
	JumpUtils.RegisterJump(JumpUtils.MODEL_ID_PASS, JumpUtils.MODEL_ID_STORE, UnknowPassUI.JumpFromPassToStore)
	JumpUtils.RegisterJump(JumpUtils.MODEL_ID_STORE, JumpUtils.MODEL_ID_STORE, StoreMainUI.JumpFromStoreToStore)
	JumpUtils.RegisterJump(JumpUtils.MODEL_ID_FULL_PREVIEW, JumpUtils.MODEL_ID_SUPPLY, StorePreviewUI.JumpFromFullPreviewToSupply)
	JumpUtils.RegisterJump(JumpUtils.MODEL_ID_PET, JumpUtils.MODEL_ID_STORE, StoreMainUI.JumpFromPetToStore)
	JumpUtils.RegisterJump(JumpUtils.MODEL_ID_PET, JumpUtils.MODEL_ID_PASS, UnknowPassUI.JumpFromPetToPass)
	JumpUtils.RegisterJump(JumpUtils.MODEL_ID_PET, JumpUtils.MODEL_ID_SUPPLY, SupplyMainUI.JumpFromPetToSupply)
end

--注册跳转
function JumpUtils.RegisterJump(fromModelId, toModuleId, func)
	if JumpUtils.jumpMap[fromModelId] == nil then
		JumpUtils.jumpMap[fromModelId] = {}
	end
	log("JumpUtils.RegisterJump from="..fromModelId..",to="..toModuleId)
	JumpUtils.jumpMap[fromModelId][toModuleId] = func
end

--真正模块跳转
function JumpUtils.JumpReal(fromModelId, toModuleId, para)
	if JumpUtils.jumpMap[fromModelId] == nil then
		log("JumpUtils.Jump no support jump 1 from="..fromModelId..",to="..toModuleId)
		return
	end
	if JumpUtils.jumpMap[fromModelId][toModuleId] == nil then
		log("JumpUtils.Jump no support jump 2 from="..fromModelId..",to="..toModuleId)
		return
	end
	log("JumpUtils.Jump from="..fromModelId..",to="..toModuleId)
	JumpUtils.jumpMap[fromModelId][toModuleId](para)
end

--根据道具id跳转对应模块，除了来源模块
function JumpUtils.Jump(fromModelId, itemId)
	log("JumpUtils.Jump fromModelId="..fromModelId..",itemId="..itemId)
	local info = JumpUtils.FindJumpInfo(itemId, fromModelId)
	if info == nil then
		log_warning("Jump Info is nil")
		return
	end
	log_tree("FindJumpInfo=",info)
	JumpUtils.JumpReal(fromModelId, info.moduleId, info)
end

--根据道具id跳转对应模块，优先模块
function JumpUtils.JumpFirst(modelId, itemId)
	log("[HHF]JumpUtils.JumpFirst, modelId = " .. tostring(modelId) .. ", itemId = " .. tostring(itemId));
	local info = JumpUtils.FindJumpInfoFirst(itemId, modelId);
	if info == nil then
		log_warning("[HHF]JumpUtils.JumpFirst, Jump Info is nil")
		return
	end

	info = JumpUtils.PreprocessJumpInfo(info);
	log_tree("[HHF]JumpUtils.JumpFirst, info = ", info, "[HHF]");
	JumpUtils.JumpReal(modelId, info.moduleId, info);
end

function JumpUtils.PreprocessJumpInfo(info)
	if info.Tab1 == StoreSystem.Page_ID_Parachute then
		if StoreFuncUtils.IsPetItemID(info.itemId) then
			info.Tab2 = StoreSystem.label_subtype_pet;
		elseif StoreFuncUtils.IsParachuteItemID(info.itemId) then
			info.Tab2 = StoreSystem.label_subtype_parachute;
		end
	end

	return info;
end

--根据道具id跳转对应模块，包括所有模块
function JumpUtils.JumpAll(fromModelId, itemId)
	log("JumpUtils.JumpAll fromModelId="..fromModelId..",itemId="..itemId)
    local info = JumpUtils.FindJumpInfoAll(itemId)
    if info == nil then
        return
    end
    log_tree("FindJumpInfoAll=",info)
    JumpUtils.JumpReal(fromModelId, info.moduleId, info)
end

--根据道具id跳转指定模块
function JumpUtils.JumpAllByToModelId(fromModelId, itemId, toModuleId)
	log("JumpUtils.JumpAll fromModelId="..fromModelId..",itemId="..itemId..",toModuleId="..toModuleId)
    local info = JumpUtils.FindJumpInfoAllByToModelId(itemId, toModuleId)
    if info == nil then
        return
    end
    log_tree("FindJumpInfoAllByToModelId=",info)
    JumpUtils.JumpReal(fromModelId, info.moduleId, info)
end

function JumpUtils.ForceRequestJumpMapInfo()
	JumpUtils.bGetJumpMap = false;
	JumpUtils.RequestJumpMapInfo();
end

--请求跳转映射数据
function JumpUtils.RequestJumpMapInfo()
	if JumpUtils.bGetJumpMap then
		return
	end
	if StoreSystem.IsUseNewStore() then
		NetJumpHandler.send_get_market_jump_info()
		NetJumpHandler.send_get_shop_jump_info()
	end
end

--接收商城跳转信息
function JumpUtils.OnRecvMarketJumpInfo(res)
	log_tree("[HHF]JumpUtils.OnRecvMarketJumpInfo, res = ", res, "[HHF]");
	if res == nil then
		return
	end
	--if JumpUtils.itemJumpMap[JumpUtils.MODEL_ID_STORE] == nil then
		JumpUtils.itemJumpMap[JumpUtils.MODEL_ID_STORE] = {}
	--end
	local itemMap = JumpUtils.itemJumpMap[JumpUtils.MODEL_ID_STORE]
	for k,v in pairs(res) do
		local info = {}
		if JumpUtils.region == "JAPAN" or JumpUtils.region == "KOREA" then
			info.moduleId = JumpUtils.MODEL_ID_SUPPLY;
		else
			info.moduleId = JumpUtils.MODEL_ID_STORE;
		end
		info.itemId = v.item_id;
		info.Tab1 = v.page_id;
		info.Tab2 = v.page_id_2 or 0;
		info.chestItemIdList = v.chest_item_ids;
		info.vipType = v.vip;
		info.cant_buy = v.cant_buy;

		local needAdd = true;
		if info.cant_buy ~= nil then
			if itemMap[v.item_id] and itemMap[v.item_id].cant_buy == nil then
				needAdd = false;
			end
		end
		if needAdd then
			itemMap[v.item_id] = info;
		end

		if v.chest_item_ids ~= nil then
			for index, item_id in pairs(v.chest_item_ids) do
				local sub_info = {}
				if JumpUtils.region == "JAPAN" or JumpUtils.region == "KOREA" then
					sub_info.moduleId = JumpUtils.MODEL_ID_SUPPLY;
				else
					sub_info.moduleId = JumpUtils.MODEL_ID_STORE;
				end
				sub_info.itemId = info.itemId;
				sub_info.Tab1 = info.Tab1;
				sub_info.Tab2 = 0;

				if itemMap[item_id] ~= nil and itemMap[item_id].cant_buy == nil then
					--商城可以直购
				else
					itemMap[item_id] = sub_info;
				end
			end
		end
	end
end

--接收补给跳转信息
function JumpUtils.OnRecvShopJumpInfo(res)
	log_tree("[HHF]JumpUtils.OnRecvShopJumpInfo, res = ", res, "[HHF]");
	if res == nil then
		return
	end
	--if JumpUtils.itemJumpMap[JumpUtils.MODEL_ID_SUPPLY] == nil then
		JumpUtils.itemJumpMap[JumpUtils.MODEL_ID_SUPPLY] = {}
	--end
	local itemMap = JumpUtils.itemJumpMap[JumpUtils.MODEL_ID_SUPPLY]
	local list = {}
	for k,v in pairs(res) do
		local info = {}
		info.moduleId = JumpUtils.MODEL_ID_SUPPLY
		info.itemId = k
		info.Tab1 = v[1]
		info.vipType = v[3]
		itemMap[k] = info
		if list[info.Tab1] == nil then
			list[info.Tab1] = 1;
		end
	end
	for k, v in pairs(list) do
		StoreSystem.get_shop_info_req(k, 0);
	end
end

--查找道具跳转信息，除了来源模块
function JumpUtils.FindJumpInfo(itemId, fromModelId)
	log("JumpUtils.FindJumpInfo itemId="..itemId)
	for k,v in pairs(JumpUtils.itemJumpMap) do
		if k ~= fromModelId then
			local info = v[tonumber(itemId)]
			if info ~= nil then
				info.bValid = true
				return info
			end
		end
	end
	return nil
end

--查找道具跳转信息，优先来源模块
function JumpUtils.FindJumpInfoFirst(itemId, modelId)
	log("[HHF]JumpUtils.FindJumpInfoFirst, itemId = " .. tostring(itemId) .. ", modelId = " .. tostring(modelId));
	local backup = nil;
	for k, v in pairs(JumpUtils.itemJumpMap) do
		local info = v[tonumber(itemId)];
		if info ~= nil then
			info.bValid = true;
			if k == modelId then
				if info.cant_buy ~= nil then
					if backup == nil then
						backup = info;
					end
				else
					return info;
				end
			else
				backup = info;
			end
		end
	end

	return backup;
end

--查找道具跳转信息，所有模块
function JumpUtils.FindJumpInfoAll(itemId)
    --log("JumpUtils.FindJumpInfoAll itemId="..itemId)
    for k,v in pairs(JumpUtils.itemJumpMap) do
        local info = v[tonumber(itemId)]
        if info ~= nil and JumpUtils.ExceptSomeTabsForJapanVersion(info) then
			info.bValid = true
            return info
        end
    end
    return nil
end

function JumpUtils.ExceptSomeTabsForJapanVersion(info)
	if JumpUtils.region == "JAPAN" or JumpUtils.region == "KOREA" then
		if info.Tab1 == StoreSystem.Page_ID_Recommend or
			info.Tab1 == StoreSystem.Page_ID_Cloth or
			info.Tab1 == StoreSystem.Page_ID_Weapon or
			info.Tab1 == StoreSystem.Page_ID_Car or
			info.Tab1 == StoreSystem.Page_ID_Parachute then
			return false;
		else
			return true;
		end
	else
		return true;
	end
end

--查找可以开出指定道具的礼包id
function JumpUtils.GetJumpToChestItemId(itemId)
	log("JumpUtils.itemJumpMap"..tostring(itemId));
	for _,list in pairs(JumpUtils.itemJumpMap) do
		for __, info in pairs(list) do
			if info ~= nil and info.chestItemIdList ~= nil then
				--log_tree("JumpUtils.itemJumpMap", info.chestItemIdList)
				for _, id in ipairs(info.chestItemIdList) do
					if id == itemId then
						return info.itemId;
					end
				end
			end
		end
	end
	return -1;
end

--查找指定模块的跳转信息
function JumpUtils.FindJumpInfoAllByToModelId(itemId, toModelId)
    log("JumpUtils.FindJumpInfoAll itemId="..itemId)
    for k,v in pairs(JumpUtils.itemJumpMap) do
        local info = v[tonumber(itemId)]
        if info ~= nil and info.moduleId == toModelId then
            return info
        end
    end
    return nil
end

--判断是否game跳转url
function JumpUtils.IsGameJumpUrl(url)
	if string.starts(tostring(url), "game://") then
		return true
	else
		return false
	end
end

--判断是否潘多拉地址
function JumpUtils.IsPanDoraJumpUrl(url)
	if string.starts(tostring(url), "pandora://") then
		return true
	else
		return false
	end
end

--大厅跳转补给指定页签
function JumpUtils.JumpFromLobbyToSupply(Tab1)
	if not LobbyUI:CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_NEW_SUPPLY, false) then
		return
	end
	local para = 
	{
		Tab1 = Tab1
	}
	SupplyMainUI.Init(0, para)
    OpenBoxtUI.SetOpenBoxBackCamera(3);
end

function JumpUtils.TryJumpFromSubscribeToStore()
	local dataMap = JumpUtils.itemJumpMap[JumpUtils.MODEL_ID_STORE];
	if dataMap ~= nil then
		for itemId, data in pairs(dataMap) do
			if data.vipType ~= nil then
				JumpUtils.JumpAllByToModelId(JumpUtils.MODEL_ID_LOBBY, itemId, JumpUtils.MODEL_ID_STORE);
				return true;
			end
		end
	end
	return false;
end

function JumpUtils.TryJumpFromSubscribeToSupply()
	local dataMap = JumpUtils.itemJumpMap[JumpUtils.MODEL_ID_SUPPLY];
	if dataMap ~= nil then
		for _, data in pairs(dataMap) do
			if data.vipType ~= nil then
				JumpUtils.JumpFromLobbyToSupply(data.Tab1);
				return true;
			end
		end
	end
	return false;
end
