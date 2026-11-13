-- 仓库相关逻辑
WardrobeSystem = WardrobeSystem or
{
	sellCount = 0,

	IsGunMapInited = false,
	TypeToGunMap = {},

	GunType_Rifle = 1,

	hasGunSkinList = false,

	skinHotDotMap = {},

	-- hasNewSkinToLobby = false,

	previewGunResID = 0,
}

function WardrobeSystem.CallOpenButtonClick()
	if _isInLobby then
		--log("WardrobeSystem.CallOpenButtonClick")
		--LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "DepotSystemClick")
		LobbyUI.EnterWardrobe();
	end
end

function WardrobeSystem.Enter(CheckQuickMsgGuide)
	log("WardrobeSystem.Enter")
    if WardrobeSystem.isWardrobeSysInit ~= true then
        --log("WardrobeSystem enter"); 
        WardrobeSystem.isWardrobeSysInit = true;
    end
    -- 告知服务器，用于检查时装背包过期状态
	NetUtil.SendPkg("client_in_depot");
	---判断是否有商城跳转数据需要拉取（仓库图鉴筛选需要）
	local _needRequireJumpInfo = true
	for k,v in pairs(JumpUtils.itemJumpMap) do
		if k then
			_needRequireJumpInfo = false;
			break;
		end
	end
	-----
	if _needRequireJumpInfo then
		NetJumpHandler.send_get_market_jump_info()
	end
	---
	WardrobeUI:Show();
	WardrobeUI.CheckNeedQuickMsgGuide(CheckQuickMsgGuide);
	local time_ticker = require("client.time_ticker")
	time_ticker.AddTimer(0.1,function()
		if 	WardrobeIndexSystem.JudgeIsShow() then
			WardrobeIndexSystem.Show()
		end
	end)

	-- Renamed CheckNeedItemUpgradeGuide to NeedQuickMsgGuide
	-- WardrobeUI.CheckNeedItemUpgradeGuide(CheckNeedItemUpgradeGuide);
end

function WardrobeSystem.IsWearValid(insID, serverTime)
	local itemData = DataMgr.GetHallDepotItemDataByInsID(insID);

	if itemData == nil or (itemData.expireTS ~= 0 and itemData.expireTS < serverTime) then
		log_tree("WardrobeSystem.IsWearValid", itemData);
		return false;
	end

	return true;
end

function WardrobeSystem.UpdateInvalidWearInfo(invalidIDList)
	-- 处理时装
	local serverTime = FuncUtil.GetServerTimeInSec();
	if DataMgr.rolewear ~= nil then
		local curWear = "";
		for i = #DataMgr.rolewear, 1, -1 do
			curWear = DataMgr.rolewear[i];
			if not WardrobeSystem.IsWearValid(curWear, serverTime) then
				if invalidIDList then
					table.insert(invalidIDList, curWear);
				end
				table.remove(DataMgr.rolewear, i);
				--log("WardrobeSystem.UpdateInvalidWearInfo timeout avatar "..tostring(curWear));
			end
		end
	end

	-- 处理降落伞(考虑限时装扮超时)
	if DataMgr.parachute ~= "" and not WardrobeSystem.IsWearValid(DataMgr.parachute, serverTime) then
		DataMgr.parachute = DataMgr.defaultParachuteInsID;
		--log("WardrobeSystem.UpdateInvalidWearInfo revert parachute");
	end
	-- 处理飞机涂装(考虑限时装扮超时)
	if DataMgr.planeSkinInsID ~= "" and not WardrobeSystem.IsWearValid(DataMgr.planeSkinInsID, serverTime) then
		DataMgr.planeSkinInsID = DataMgr.defaultPlaneSkinInsID;
		--log("WardrobeSystem.UpdateInvalidWearInfo revert planeSkin");
	end
	-- 处理载具涂装(考虑限时装扮超时)
	if next(DataMgr.vehicleSkinInsIDTable) ~= nil then
		local skinTable = {};
		for k, v in pairs(DataMgr.vehicleSkinInsIDTable) do
			itemResID = DataMgr.defaultVehicleSkinResIDTable[k];
			if v ~= "" and not WardrobeSystem.IsWearValid(v, serverTime) and itemResID ~= nil then
				skinTable[k] = DataMgr.defaultVehicleSkinInsIDTable[itemResID];
				--log("WardrobeSystem.UpdateInvalidWearInfo revert vehicleSkin:"..tostring(itemResID).."  type:"..tostring(k));
			else
				-- log("[LLP]WardrobeSystem.UpdateInvalidWearInfo"..tostring(k).."insID"..v)
				skinTable[k] = v;
			end
		end
		DataMgr.vehicleSkinInsIDTable = skinTable;
	end
end

--sami 获取道具在身上的部位1-帽子，2-面具，3-上衣，4-裤子，5-鞋子，6-枪
function WardrobeSystem.GetItemPart(itemId)
	local itemCfg = Client.GetTableData("Item", itemId);
	if itemCfg == nil then
		return 0;
	end
	if itemCfg.ItemType == 1 then
		return 6;
	end
	if itemCfg.ItemType == 4 then
		if itemCfg.ItemSubType == 401 then
			return 1;
		elseif itemCfg.ItemSubType == 402 then
			return 2;
		elseif itemCfg.ItemSubType == 403 then
			return 3;
		elseif itemCfg.ItemSubType == 404 then
			return 4;
		elseif itemCfg.ItemSubType == 405 then
			return 5;
		else
			return 0;
		end
	end
	return 0;
end

--请求穿戴
function WardrobeSystem.wardrobe_puton_req(insID)
    --log("WardrobeSystem.wardrobe_puton_req ..... " .. insID);
    WardRobeHandler.send_depot_put_on_req(tonumber(insID))
end

--请求穿戴返回
function WardrobeSystem.on_puton_rsp(res, item, olditem)
	--log("on_puton_rsp:"..res);
	-- log_tree("puton_item:", item);
	-- log_tree("putdown_item:", olditem);

	if res == "ok" then
		if item == nil then
			return
		end
		local itemCfg = Client.GetTableData("Item", item.res_id);
		if itemCfg ~= nil then
			if itemCfg.ItemType == eItemType.eHallThemeItem then
				--处理主题穿戴
				HallThemeUtils.ProcPutOnHallTheme(item, olditem)
			elseif itemCfg.WardrobeMainTab == BP_ENUM_WardrobePageType_Avatar then
				-- 更新时装
				if olditem then
					DataMgr.UpdateRoleWearData(tostring(item.instid), tostring(olditem.instid));
				else
					DataMgr.UpdateRoleWearData(tostring(item.instid), "");
				end
				BP_IsWardrobePutOnAvatar = true;
				WardrobeUI.CheckPutOffHelmetAvatar(itemCfg);
				if(itemCfg.WardrobeTab == BP_ENUM_wardrobeTabString_head) then
					WardrobeSystem.depot_set_head_show_req(item.instid);
				end
				LobbyUI:AvatarChange(LobbyUI:CreateAvatarChangeData(DataMgr.roleData.uid, item.res_id, item.color, item.pattern), true);
			elseif itemCfg.WardrobeMainTab == BP_ENUM_WardrobePageType_Parachute then
				if itemCfg.WardrobeTab == BP_ENUM_wardrobeTabString_parachute then
					-- 更新降落伞
					DataMgr.UpdateParachute(tostring(item.instid));
				elseif itemCfg.WardrobeTab == BP_ENUM_wardrobeTabString_plane then
					DataMgr.UpdatePlaneSkin(tostring(item.instid));
					-- 处理军备飞机装备
					-- local skinMap = Client.GetTableData("VehiclePlaneSkinMapping", item.res_id)
					-- ArmorySystem.install_weapon_skin_rsp(ArmorySystem.ENUM_REQ_Armory, 0, skinMap.OrginalID, item.instid)
				
				elseif FuncUtil.Find(WardrobeUI.wardrobeEquipmentTabString, itemCfg.WardrobeTab) >= 0 then
					DataMgr.UpdateEquipmentSkin(itemCfg.ItemSubType, tostring(item.instid));
					WardrobeUI.CheckPutoffHatAvatar(itemCfg);
					if(itemCfg.WardrobeTab == BP_ENUM_wardrobeTabString_helmet) then
						WardrobeSystem.depot_set_head_show_req(item.instid);
					end
					local itemResID = WardrobeUI:GetEquipmentItemIDBySkinInsID(itemCfg.ItemSubType, tostring(item.instid));
					if itemResID >= 0 then
						BP_IsWardrobePutOnAvatar = true;
						LobbyUI:AvatarChange(LobbyUI:CreateAvatarChangeData(DataMgr.roleData.uid, itemResID, item.color, item.pattern), true);
					end
				end
			elseif itemCfg.WardrobeMainTab == BP_ENUM_WardrobePageType_Vehicle then
				DataMgr.UpdateVehicleSkin(itemCfg.ItemSubType, tostring(item.instid))
				HallThemeUtils.ProcPutOnVehicle(item, olditem)
				-- 处理军备载具装备
				-- local skinMap = Client.GetTableData("VehiclePlaneSkinMapping", item.res_id)
				-- ArmorySystem.install_weapon_skin_rsp(ArmorySystem.ENUM_REQ_Armory, 0, skinMap.OrginalID, item.instid)

			end
			WardrobeUI:UpdatePutOnData(item, olditem);
		end
		
		--sami 计算部位
		local oldPart = 0;
		if(nil ~= olditem) then
			oldPart = WardrobeSystem.GetItemPart(olditem.res_id);
		end
		local newPart = 0;
		if(nil ~= item) then
			newPart = WardrobeSystem.GetItemPart(item.res_id);
		end

		--更新玩家自己数据
		local roleUid = DataMgr.roleData.uid;
		local playerInfo = ProfileMgr.GetPlayerDataByUid(roleUid);
		if(nil ~= playerInfo and nil ~= playerInfo.avatar_show and nil ~= playerInfo.avatar_show.wear_ext) then
			if(oldPart > 0) then
				playerInfo.avatar_show.wear_ext[oldPart] = LobbyUI:CreateClientAvatarWearInfo(0,0,0);
				--log("WardrobeSystem.on_puton_rsp off oldPart = " ..oldPart ..", res_id = " ..olditem.res_id);
			end
			if(newPart > 0) then
				playerInfo.avatar_show.wear_ext[newPart] = LobbyUI:CreateClientAvatarWearInfo(item.res_id, item.color_id, item.pattern_id);
				--log("WardrobeSystem.on_puton_rsp on newPart = " ..newPart ..", res_id = " ..item.res_id);
			end
		end
		ProfileMgr.get_avatar_show_req(roleUid)
	else
		DataMgr.ShowNoticeByID(res);
	end
end

--请求脱下
function WardrobeSystem.wardrobe_put_down_req(insID, hasRes)
    --log("WardrobeSystem.wardrobe_put_down_req ..... " .. insID);
	WardRobeHandler.send_depot_put_down_req(tonumber(insID))
end
--请求脱下返回
function WardrobeSystem.on_putdown_rsp(res, item)
	--log("on_putdown_rsp:"..res);
	-- log_tree("putdown_item:", item);

	
	if res == "ok" then
		local itemCfg = Client.GetTableData("Item", item.res_id);
		if itemCfg ~= nil then
			if itemCfg.WardrobeMainTab == BP_ENUM_WardrobePageType_Avatar then
				local instID = tostring(item.instid)
				local isPutOn = false;
				for i,v in ipairs(DataMgr.rolewear) do
					if v == instID then
						isPutOn = true;
						break;
					end
				end

				if isPutOn then
					DataMgr.UpdateRoleWearData("", instID);
					if(itemCfg.WardrobeTab == BP_ENUM_wardrobeTabString_head) then
						WardrobeSystem.depot_set_head_show_req(0);
						WardrobeUI.CheckPutOffHelmetAvatar(itemCfg);
					end
					LobbyUI:AvatarChange(LobbyUI:CreateAvatarChangeData(DataMgr.roleData.uid, item.res_id), false);
					WardrobeUI:UpdatePutDownData(item);
				end
			elseif itemCfg.WardrobeMainTab == BP_ENUM_WardrobePageType_Parachute then
				local instID = tostring(item.instid)
				local isPutOn = false;
				if FuncUtil.Find(WardrobeUI.wardrobeEquipmentTabString, itemCfg.WardrobeTab) >= 0 then
					if DataMgr.equipmentSkinInsIDTable[itemCfg.ItemSubType] == instID then
						isPutOn = true
					end
				end
				if isPutOn then
					DataMgr.UpdateEquipmentSkin(itemCfg.ItemSubType, "");
					local itemResID = WardrobeUI:GetEquipmentItemIDBySkinInsID(itemCfg.ItemSubType, instID);
					if itemResID >= 0 then
						if(itemCfg.WardrobeTab == BP_ENUM_wardrobeTabString_helmet) then
							WardrobeSystem.depot_set_head_show_req(0);
						end
						LobbyUI:AvatarChange(LobbyUI:CreateAvatarChangeData(DataMgr.roleData.uid, itemResID), false);
					end
					WardrobeUI:UpdatePutDownData(item);
				end
			end
		end
		ProfileMgr.get_avatar_show_req(DataMgr.roleData.uid)
	else
		DataMgr.ShowMessageBoxByID(res);
	end
end

--请求修改使用的时装橱窗
function WardrobeSystem.select_use_rolewear_req(index)
	--log("WardrobeSystem.select_use_rolewear_req index:"..index);
	NetUtil.SendPkg("select_use_rolewear", tonumber(index));	
end

function WardrobeSystem.on_select_use_rolewear_rsp(res, index, pspace_rolewear_index)
	--log("WardrobeSystem.on_select_use_rolewear_rsp res:"..tostring(res));
	if res == "ok" then
		DataMgr.pspace_rolewear_index = pspace_rolewear_index

		WardrobeUI.OnSelectUseRolewearSuccess(index);
	end
	
end

-- 请求开启时装橱窗
function WardrobeSystem.unlock_rolewear_req(index, change_idx)
	if change_idx ~= nil then
		log("WardrobeSystem.unlock_rolewear_req index:"..index.." change_idx:"..change_idx)
		NetUtil.SendPkg("unlock_rolewear", tonumber(index), tonumber(change_idx));
	else
		log("WardrobeSystem.unlock_rolewear_req index:"..index)
		NetUtil.SendPkg("unlock_rolewear", tonumber(index));
	end
	
end

function WardrobeSystem.on_unlock_rolewear_rsp(res, index, change_idx, timestamp)
	--log("WardrobeSystem.on_unlock_rolewear_rsp res:"..tostring(res));
	if res == 9910135 or res == 9910010 or res == 9910003 then
		DataMgr.ShowNoticeByID(tostring(res));
	end
	if res == "ok" then
		if change_idx ~= nil and timestamp ~= nil then 
			log("WardrobeSystem.on_unlock_rolewear_rsp success current index:"..index.." change_idx:"..change_idx.." timestamp:"..timestamp);
		else
			log("WardrobeSystem.on_unlock_rolewear_rsp success current index:"..index);
		end
		
		WardrobeUI.OnRolewearUnlocked(index, change_idx, timestamp);
	end
end

-- 时装橱窗状态改变
function WardrobeSystem.on_update_rolewear_state(rolewear_state, rolewear, use_rolewear, all_knapsack_ext_info, pspace_rolewear_index)
	--log("WardrobeSystem.on_update_rolewear_state use_rolewear: "..use_rolewear)
	--log_tree("WardrobeSystem.on_update_rolewear_state rolewear_state:", rolewear_state);
	--log_tree("WardrobeSystem.on_update_rolewear_state rolewear:", rolewear);
	--log_tree("on_update_rolewear_state all_knapsack_ext_info:", all_knapsack_ext_info);
	--log_tree("on_update_rolewear_state pspace_rolewear_index:", pspace_rolewear_index);

	DataMgr.pspace_rolewear_index = pspace_rolewear_index
	--
	HallThemeUtils.ProcRoleWearState(all_knapsack_ext_info, pspace_rolewear_index)
	--
	WardrobeUI.OnRolewearStateUpdated(rolewear_state, rolewear, use_rolewear);

	local RoleInfoDecorationSystem = require("client.slua.logic.person_space.logic_roleinfo_decoration")
	if RoleInfoDecorationSystem.HasInDecoration then
		RoleInfoDecorationSystem.WearInfos = nil
		EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_SELECT_USE_PSPACE_ROLEWEAR_RSP);

		RoleInfoDecorationSystem.UpdateRolewearState()
	end
end


--请求出售
function WardrobeSystem.wardrobe_sell_req(instID, count)
    --log("WardrobeSystem.wardrobe_sell_req instID:" .. instID..", count:"..count);
	WardrobeSystem.sellCount = count;
    NetUtil.SendPriorityPkg(false, "depot_sell_item_rsp", "depot_sell_item_req", tonumber(instID), count);
end
--请求出售返回
function WardrobeSystem.on_sell_rsp(res, sellItem)
    --log("on_sell_rsp res:" .. res);
--log_tree("selllItem", sellItem);
	
	if res == "ok" then
		-- 弹出金币获得提示
		local itemDataCfg = Client.GetTableData("Item", sellItem.res_id);		
		if itemDataCfg then
			local gold = itemDataCfg.SellPrice * WardrobeSystem.sellCount;
			--local tip = string.format("出售成功，获得<img src=\"GoldImage\"/><MessageGoldColor>%s</>", gold);
			local tip = string.format(Client.GetTableData("LocalizeRes",301164).TextValue, gold);
			tip = (string.gsub(tip, "\'", "\"")); 
			PopUpNoticeUI.ShowNewNotice(tip);
		end
		
		-- 刷新avatar
		if sellItem.count == 0 then
			LobbyUI:AvatarChange(LobbyUI:CreateAvatarChangeData(DataMgr.roleData.uid, sellItem.res_id), false);	
		end
		-- 刷新仓库ui
		WardrobeUI:UpdateItemData(sellItem);
	else	
		DataMgr.ShowMessageBoxByID(res);
	end
end

-- 请求使用道具
function WardrobeSystem.wardrobe_use_item_req(instID, count)
	--log("WardrobeSystem.wardrobe_use_item_req instID "..tostring(instID));
	--log("WardrobeSystem.wardrobe_use_item_req count "..tostring(count));
	if instID ~= "" and count > 0 then
		NetUtil.SendPriorityPkg(false, "use_item_rsp", "use_item", tonumber(instID), count);
	end
end
-- 请求使用道具返回，开宝箱的表现通过open_chest_rsp返回  实现在logic_shop中
function WardrobeSystem.on_use_item_rsp(res, itemData)
--log_tree("WardrobeSystem.on_use_item_rsp", itemData);
	
	if res == "ok" then
		-- 刷新仓库ui
		WardrobeUI:UpdateItemData(itemData);

		local itemCfg = Client.GetTableData("Item", itemData.res_id);
		if itemCfg then
			if itemCfg.ItemSubType == 2101 or itemCfg.ItemSubType == 2102 then
				local msg = FuncUtil.LocalizeResFormat("9910112", itemCfg.ItemName);
	        	PopUpNoticeUI.ShowNewNotice(msg);
				EventLobbyUpdateDoubleCardButton();
			elseif WardrobeUI.IsActiveSubType(itemCfg.ItemSubType) then
				local msg = "已激活，请前往更换形象系统使用";
				PopUpNoticeUI.ShowNewNotice(msg);
			end
		end

		EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_ITEM_USED, itemData);
	else
		ShowNotice(res);
		if res == 9910101 then
			WardrobeUI.UpdateTime();
		end
	end
end

-- 取消物品new标签
function WardrobeSystem.wardrobe_change_item_new_status(instID)
	-- log("WardrobeSystem.wardrobe_change_item_new_status instID "..tostring(instID));
	DataMgr.ChangeHallDepotItemNewStatus(instID);
	NetUtil.SendPkg("select_item", tonumber(instID));
end

function WardrobeSystem.RefreshEmojSlotsUI(isRefresh)
	if isRefresh == nil then
		isRefresh = true;
	end

	BP_Wardrobe_Emoj_Slots_Max = DataMgr.MotionSlotMax;
	BP_ARRAY_Wardrobe_Emoj_Slots = {};
	-- BP_Wardrobe_Emoj_Slots_Max = 10;
	-- BP_ARRAY_Wardrobe_Emoj_Slots = {"6548315574139617320"};
	local motionItems = DataMgr.GetMotionItemDatas()
	for i,v in ipairs(motionItems) do
		table.insert(BP_ARRAY_Wardrobe_Emoj_Slots, v.insID)
	end

	-- log_tree("WardrobeSystem.RefreshEmojSlotsUI BP_ARRAY_Wardrobe_Emoj_Slots ", BP_ARRAY_Wardrobe_Emoj_Slots)

	if isRefresh then
		LuaClassObj.HandleUIMessageNoFetch(bp_wardrobe, "UpdateEmojSlots");
	end
end

-- 查找动作
function WardrobeSystem.FindMotion(instid)
	instid = tostring(instid)
	for i,v in ipairs(DataMgr.MotionSlotList) do
		if v == instid then
			return i
		end
	end

	return -1;
end
-- 装备动作
function WardrobeSystem.EquipMotion(instid, dst_slot)
	local insSlot = WardrobeSystem.FindMotion(instid);
	local curIns = DataMgr.MotionSlotList[dst_slot];

	-- 是否已经装备
	if insSlot > 0 then
		-- 如果是同一个装备不处理
		if curIns == instid then
			return;
		end

		-- 交换
		WardrobeSystem.exchange_motion_req(insSlot, dst_slot)
	else
		-- 装备
		WardrobeSystem.equip_motion_req(instid, dst_slot)
	end
end

function WardrobeSystem.equip_motion_req(instid, dst_slot)
	--log("WardrobeSystem.equip_motion_req instid "..tostring(instid))
	--log("WardrobeSystem.equip_motion_req dst_slot "..tostring(dst_slot))
	NetUtil.SendPriorityPkg(false, "equip_motion_rsp", "equip_motion_req", tostring(instid), dst_slot);
end

function WardrobeSystem.equip_motion_rsp(result, slot, item, old_item)
	--log("WardrobeSystem.equip_motion_rsp")
	if result == "ok" then
		--正常
	elseif tostring(result) == "9910138" then
		--未装备对应外观，无法使用此表情
		ShowNotice(6014)		
	elseif result ~= nil then
		ShowNotice(result)
	end
end

-- 卸载动作
function WardrobeSystem.unequip_motion_req(instid, slot)
	--log("WardrobeSystem.unequip_motion_req instid "..tostring(instid))
	--log("WardrobeSystem.unequip_motion_req slot "..tostring(slot))
	NetUtil.SendPriorityPkg(false, "unequip_motion_rsp", "unequip_motion_req", tostring(instid), slot);
end

function WardrobeSystem.unequip_motion_rsp(result, slot, old_item)
	--log("WardrobeSystem.unequip_motion_rsp")
	if result == "ok" then
	elseif result ~= nil then
		ShowNotice(result)
	end
end

-- 交换槽位
function WardrobeSystem.exchange_motion_req(src_slot, dst_slot)
	--log("WardrobeSystem.exchange_motion_req src_slot "..tostring(src_slot))
	--log("WardrobeSystem.exchange_motion_req dst_slot "..tostring(dst_slot))
	NetUtil.SendPriorityPkg(false, "exchange_motion_rsp", "exchange_motion_req", src_slot, dst_slot);
end

function WardrobeSystem.exchange_motion_rsp(result, src_item, dst_item)
	if result == "ok" then
	elseif result ~= nil then
		ShowNotice(result)
	end
end

-- 表情新增列表
function WardrobeSystem.equip_motion_list_req(motion_list)
	-- log_tree("WardrobeSystem.equip_motion_list_req motion_list", motion_list);
	NetUtil.SendPkg("equip_motion_list_req", motion_list);
end

function WardrobeSystem.PlayMotion(motionResID)
	--log("WardrobeSystem.PlayMotion motionResID "..tostring(motionResID));

	--如果是嘲讽表情，增加随机参数
	local myUid = DataMgr.roleData.uid
	local sex = ProfileMgr.GetRoleSexByUid(myUid)
	local randSoundId = ExpressionUI.GetChaoFengRandSoundId(motionResID, sex)
	--log("randSoundId = "..randSoundId)
    LobbyUI:ShowEmoteAction(DataMgr.roleData.uid, motionResID, sex, randSoundId);

    if TeamUpSystem.TeamInfo.player_count ~= nil and TeamUpSystem.TeamInfo.player_count > 1 then
        TeamUpSystem.team_player_action(motionResID, randSoundId)
    end
end

-- 剩余时间
function WardrobeSystem.GetRemainTimeStr(expireTS)
	local result = "";
	local remainTime = expireTS - FuncUtil.GetServerTimeInSec();
	if remainTime <= 0 then
		remainTime = 1;
	end
	
	return WardrobeSystem.GetTimeStr(remainTime);
end


function WardrobeSystem.GetTimeStr(remainTime)
	-- 计算天数和小时数
	local hour = math.ceil(remainTime * WardrobeUI.secToHour);
	local day = math.floor(hour * WardrobeUI.hourToDay);
	if hour >1 then
		hour = hour%24
	else
		hour = 1
	end

	local transableStr = ""

	if day ~= 0  then
		transableStr = FuncUtil.LocalizeResFormat(301152, day,hour); -- xx天xx小时
	else --不够一天 xx小时
		if hour ~= 0 then
			transableStr = FuncUtil.LocalizeResFormat(9910107, tostring(hour));
		end
	end
	return transableStr;
end

-- 更新仓库小红点
function WardrobeSystem.UpdateLobbyHotDot()
	local hasNewGunSkin = WardrobeSystem.HasAnyGunSkinHotDot();
	local hasNewAvatar = BP_Wardrobe_ResetAvatar_RedPoint;
	local hasUpgradeItem = ItemUpgradeSystem.NeedShowRedPoint();

	LobbyUI:LobbyRedPointUpdate(BP_ENUM_LOBBY_MENU_WARDROBE,
			(hasNewGunSkin or #WardrobeUI.redPointTabType > 0
					or hasNewAvatar or hasUpgradeItem or BP_Wardrobe_Pet_RedPoint));
end

-----------------------------枪械相关-------------------------
-- 初始化枪械列表
function WardrobeSystem.InitGunTable()
	if WardrobeSystem.IsGunMapInited then
		return;
	end

	WardrobeSystem.IsGunMapInited = true;

	local ArmoryTable = Client.GetTable("ArmoryConfig");
	for k,v in pairs(ArmoryTable) do
		local itemDataCfg = Client.GetTableData("Item", v.WeaponID);
		if itemDataCfg and itemDataCfg.WardrobeMainTab == BP_ENUM_WardrobePageType_Gun then
			local gunArray = WardrobeSystem.TypeToGunMap[v.WeaponType];
			if gunArray == nil then
				gunArray = {}
				WardrobeSystem.TypeToGunMap[v.WeaponType] = gunArray;
			end
			table.insert(gunArray, v);

			local gunArrayall = WardrobeSystem.TypeToGunMap[100]
			if gunArrayall == nil then
				gunArrayall = {}
				WardrobeSystem.TypeToGunMap[100] = gunArrayall
			end
			table.insert(gunArrayall, v);
		end
	end

	-- 排序id小的在前面
	for k,v in pairs(WardrobeSystem.TypeToGunMap) do
		table.sort(v, function(a, b)
			--[[
			local x1 = math.modf(a/100)
			local x2 = math.modf(b/100)
			if x1 ~= x2 then
				if x1 == 101 or x2 == 101 then
					return x1 == 101
				elseif x1 == 103 or x2 == 103 then
					return x1 == 103
				elseif x1 == 102 or x2 == 102 then
					return x1 == 102
				else
					return x1 < x2
				end
			end
			]]
			if a.WeaponType ~= b.WeaponType then
				return a.WeaponType < b.WeaponType
			end
			return a.WeaponID < b.WeaponID;
		end)
	end
end

-- 请求武器列表
function WardrobeSystem.GetGunSkinListReq()
	if not WardrobeSystem.hasGunSkinList then

		--log("WardrobeSystem.GetGunSkinListReq");
		ArmorySystem.get_weapon_skin_list(ArmorySystem.ENUM_REQ_Wardrobe);
	else
		WardrobeSystem.UpdateGunList(BP_Wardrobe_CurrentGunType)
	end
end

-- 获得列表后刷新界面
function WardrobeSystem.OnGunSkinListRes()
	--log("WardrobeSystem.OnGunSkinListRes")
	if not WardrobeUI.isShowing then
		return;
	end

	if not WardrobeSystem.hasGunSkinList and ArmorySystem.rsp_list then
		WardrobeSystem.hasGunSkinList = true;
		WardrobeSystem.RebuildGunData();
		WardrobeSystem.UpdateGunList(-1)
	end
end

-- 更新枪械列表
function WardrobeSystem.UpdateGunList(showType)
	if not WardrobeUI.isShowing then
		return
	end

	--log("WardrobeSystem.UpdateGunList showType "..tostring(showType))
	BP_ARRAY_Wardrobe_GunResInfoList = {}
	BP_ARRAY_WardrobeItemList = {}

	local curGun = 0;

	if showType < 0 then
		-- BP_Wardrobe_CurrentGunType = 100
		BP_Wardrobe_GunID = 0
		BP_Wardrobe_GunSkinUID = ""
		WardrobeSystem.previewGunResID = 0;

		-- 如果没有指定显示的枪械类型，则显示已装备的枪械
		if DataMgr.Weapon_ID ~= 0 then
			local gunCfg = Client.GetTableData("ArmoryConfig", DataMgr.Weapon_ID);
			if gunCfg ~= nil then
				--BP_Wardrobe_CurrentGunType = gunCfg.WeaponType;
				curGun = DataMgr.Weapon_ID;
				WardrobeSystem.previewGunResID = DataMgr.Weapon_ID;
				local itemData = DataMgr.GetValidHallDepotItemDataByInsID(DataMgr.Weapon_Skin_InsID);
				if itemData then
					WardrobeSystem.previewGunResID = itemData.resID
				end
			end
		else
			-- 没有装备枪械，使用步枪
			--BP_Wardrobe_CurrentGunType = WardrobeSystem.GunType_Rifle;
		end

		LuaClassObj.HandleUIMessageNoFetch(bp_wardrobe, "InitGunType");
	else
		--BP_Wardrobe_CurrentGunType = showType;
		curGun = BP_Wardrobe_GunID
	end
	
	-- BP_Wardrobe_CurrentGunType = 100
	-- 获取指定类型枪械列表
	local gunArray = WardrobeSystem.TypeToGunMap[BP_Wardrobe_CurrentGunType - 1];
	if BP_Wardrobe_CurrentGunType == 1 then
		gunArray = WardrobeSystem.TypeToGunMap[100]
	end
	
	if gunArray ~= nil then
		-- 填充枪械列表
		for i,v in ipairs(gunArray) do
			local info = {}
			info.resID = v.WeaponID
			local skinInsID = ArmorySystem.GetSkinIdByWeaponID(v.WeaponID);
			WardrobeSystem.InitGunInfo(info, skinInsID);
			info.total_count = UnknowPassTreasureBoxUI.GetItemCount(info.skinResID)
			info.use_count = HallThemeUtils.GetUsedItemCount(skinInsID, HallThemeUtils.knapsack_ext_weapon_skin)
			table.insert(BP_ARRAY_Wardrobe_GunResInfoList, info);
		end
	end

	-- log_tree("WardrobeSystem.UpdateGunList BP_ARRAY_Wardrobe_GunResInfoList", BP_ARRAY_Wardrobe_GunResInfoList);

	-- if showType < 0 and curGun == 0 and #BP_ARRAY_Wardrobe_GunResInfoList > 0 then
	-- 	curGun = BP_ARRAY_Wardrobe_GunResInfoList[1]
	-- end

	-- 更新当前装备
	WardrobeSystem.UpdateCurrentPutOnGun(false, curGun);
	-- 刷新列表
	LuaClassObj.HandleUIMessageNoFetch(bp_wardrobe, "UpdateGunList");
	-- 刷新小红点
	WardrobeUI.RefreshRedPoint();
end

function WardrobeSystem.InitGunInfo(info, skinInsID)
	local itemData = DataMgr.GetValidHallDepotItemDataByInsID(skinInsID);
	if itemData then
		-- 隔离状态下，枪的页签显示为默认
		if WardrobeSystem.IsItemIsolated(itemData.resID) then
			info.skinResID = 0;
		else
			info.skinResID = itemData.resID;
		end
	else
		info.skinResID = 0;
	end
end

-- 更新当前装备的枪支，gunID为物品表ID，gunID>0为装备，gunID<0为卸载
function WardrobeSystem.UpdateCurrentPutOnGun(isRefresh, gunID)
	if not WardrobeUI.isShowing then
		return;
	end

	--log("WardrobeSystem.UpdateCurrentPutOnGun isRefresh "..tostring(isRefresh))
	--log("WardrobeSystem.UpdateCurrentPutOnGun gunID "..tostring(gunID))
	-- if gunID ~= 0 then
	-- 	local isFind = false;

	--     -- 如果装备的枪不在列表中，则不处理
	-- 	for i,v in ipairs(BP_ARRAY_Wardrobe_GunResInfoList) do
	-- 		if v.resID == gunID then
	-- 			isFind = true;
	-- 			break;
	-- 		end
	-- 	end

	-- 	if not isFind then
	-- 		return;
	-- 	end
	-- end

	BP_Wardrobe_GunID = gunID;

	if BP_Wardrobe_GunID ~= 0 then
		WardrobeSystem.RemoveGunHotDot(BP_Wardrobe_GunID);

		if WardrobeSystem.HasAnyGunSkinHotDot() then
			WardrobeUI.RefreshRedPoint()
		end
	end

	-- 更新是否装备枪
	BP_Wardrobe_PutOnCurrentGun = DataMgr.Weapon_ID ~= 0;

	-- 如果有数据刷新皮肤列表，没有则请求
	BP_ARRAY_WardrobeItemList = {};
	if WardrobeSystem.hasGunSkinList then
		WardrobeSystem.UpdateGunSkinList();
	else
		WardrobeSystem.GetGunSkinListReq()
	end

	if isRefresh then
		LuaClassObj.HandleUIMessageNoFetch(bp_wardrobe, "UpdatePutOnGun");
	end
end

-- 更新枪械皮肤界面
function WardrobeSystem.UpdateGunSkinList()
	if not WardrobeUI.isShowing then
		return;
	end

	--log("WardrobeSystem.UpdateGunSkinList BP_Wardrobe_GunID "..tostring(BP_Wardrobe_GunID))
	BP_ARRAY_WardrobeItemList = {};
	BP_Wardrobe_ClickGunSkin = "";

	-- 是否当前皮肤分组，是则更新皮肤列表
	local curGun = 0;
	local armoryCfg = Client.GetTableData("ArmoryConfig", BP_Wardrobe_GunID);
	if armoryCfg then
		curGun = BP_Wardrobe_GunID
	end

	if curGun ~= 0 then
		-- 更新皮肤列表
		local skinList
		if WardrobeUI.isGunTypeChange == false then
			skinList = ArmorySystem.GetSkinListByWeaponID(BP_Wardrobe_GunID);
		else
			--log("==========BP_Wardrobe_CurrentGunType "..BP_Wardrobe_CurrentGunType)
			local showType = BP_Wardrobe_CurrentGunType - 1
			if showType == 0 then showType = 100 end

			local gunArray = WardrobeSystem.TypeToGunMap[showType]
			skinList = ArmorySystem.GetSkinListByWeaponID(gunArray[1].WeaponID);
			WardrobeUI.isGunTypeChange = false
		end
		-- log_tree("WardrobeSystem.UpdateGunSkinList skinList", skinList);

		if skinList ~= nil then
			WardrobeSystem.InitSkinList(skinList);
		end

		-- 更新已装备皮肤
		WardrobeSystem.UpdateCurrentPutOnGunSkin(false);
	else
		-- log("WardrobeSystem.UpdateGunSkinList WardrobeSystem.PutOffGunAvatar");
		-- WardrobeSystem.PutOffGunAvatar();
	end

	LuaClassObj.HandleUIMessageNoFetch(bp_wardrobe, "UpdateGunSkinList");
end

--sami 更新枪数量
function WardrobeSystem.UpdateGunCount()
	log("WardrobeSystem.UpdateGunCount")
	for k,v in pairs(BP_ARRAY_WardrobeItemList) do
		local itemInfo = v
		itemInfo.use_count = HallThemeUtils.GetUsedItemCount(itemInfo.ins_id, HallThemeUtils.knapsack_ext_weapon_skin)
	end
end

function WardrobeSystem.InitSkinList(skinList)
	local skinInsID = ArmorySystem.GetSkinIdByWeaponID(BP_Wardrobe_GunID);
	for k,v in pairs(DataMgr.arrayHallDepotItemInfo) do
		local skinInfo = skinList[v.resID];
		local isWear = false;
		if skinInfo and DataMgr.IsValidTime(v.expireTS) then
			if skinInsID ~= nil then
				isWear = tonumber(v.insID) == skinInsID;
				log("isWear .. " .. tostring(isWear));
			end
			local itemInfo =
			{
				ins_id = v.insID,
				res_id = v.resID,
				count = v.count,
				is_using = false,
				is_new = v.isNew,
				is_selected = isWear,
				is_sourcebook = false,
				validHours = v.validHours,
				expireTS = v.expireTS,
				itemSubType = v.itemSubType,
				itemQuality = v.itemQuality,
				is_isolated = WardrobeSystem.IsItemIsolated( v.resID ),
			}
			itemInfo.use_count = HallThemeUtils.GetUsedItemCount(v.insID, HallThemeUtils.knapsack_ext_weapon_skin)

			table.insert(BP_ARRAY_WardrobeItemList, itemInfo);
		end
	end

	table.sort(BP_ARRAY_WardrobeItemList, WardrobeUI.SortItemWithoutType);
	--log_tree("WardrobeSystem.InitSkinList BP_ARRAY_WardrobeItemList", BP_ARRAY_WardrobeItemList);
end

-- 更新装备的皮肤，数据来自装备库，根据BP_Wardrobe_GunID查找对应的已装备皮肤
function WardrobeSystem.UpdateCurrentPutOnGunSkin(isRefresh)
	if not WardrobeUI.isShowing or BP_Wardrobe_GunID == 0 then
		return;
	end

	-- 获取枪械已装备皮肤
	local skinInsID = ArmorySystem.GetSkinIdByWeaponID(BP_Wardrobe_GunID);
	if skinInsID == nil then
		return;
	end
	BP_Wardrobe_GunSkinUID = tostring(skinInsID);

    local item = DataMgr.GetHallDepotItemDataByInsID(skinInsID)
    if item then
        BP_Wardrobe_ClickGunSkin =  item.insID;
    end

	-- 更新当前Avatar
	WardrobeSystem.UpdateCurrentGunAvatar(BP_Wardrobe_GunID, BP_Wardrobe_GunSkinUID);

	for i,v in ipairs(BP_ARRAY_Wardrobe_GunResInfoList) do
		if v.resID == BP_Wardrobe_GunID then
			WardrobeSystem.InitGunInfo(v, skinInsID);
			BP_STRUCT_Wardrobe_Changed_GunResInfo = v;
			break;
		end
	end

	if isRefresh then
		LuaClassObj.HandleUIMessageNoFetch(bp_wardrobe, "UpdatePutOnSkin");
		LuaClassObj.HandleUIMessageNoFetch(bp_wardrobe, "UpdateVisibleGun");
	end
end

-- 更新avatar
function WardrobeSystem.UpdateCurrentGunAvatar(gunID, skinID)
	skinID = tostring(skinID)
	local itemData = DataMgr.GetValidHallDepotItemDataByInsID(skinID);
	if itemData == nil then
		if gunID > 0 then
			WardrobeSystem.PutOnGunAvatar(gunID);
		else
			WardrobeSystem.PutOffGunAvatar();
		end
	else
		WardrobeSystem.PutOnGunAvatar(itemData.resID);
	end
end

-- 点击装卸枪械
function WardrobeSystem.OnPutOnStateChange()
	if BP_Wardrobe_PutOnCurrentGun then
		WardrobeSystem.put_on_weapon_wear(ArmorySystem.ENUM_REQ_Wardrobe, 0);
	else
		if BP_Wardrobe_GunID == 0 then
			if BP_Wardrobe_keep_GunID and BP_Wardrobe_keep_GunID ~= 0 then
				BP_Wardrobe_GunID = BP_Wardrobe_keep_GunID
				WardrobeSystem.put_on_weapon_wear(ArmorySystem.ENUM_REQ_Wardrobe, BP_Wardrobe_GunID);
			else
				WardrobeSystem.put_on_weapon_wear(ArmorySystem.ENUM_REQ_Wardrobe, 101001);
			end
			--ShowNotice(9910134);
		else
			WardrobeSystem.put_on_weapon_wear(ArmorySystem.ENUM_REQ_Wardrobe, BP_Wardrobe_GunID);
		end
	end
end

-- 点击枪械
function WardrobeSystem.OnClickGun()
	--log("WardrobeSystem.OnClickGun BP_Wardrobe_ClickGun "..tostring(BP_Wardrobe_ClickGun))
	if DataMgr.Weapon_ID ~= 0 then
		-- 已经装备，换装备
		if BP_Wardrobe_ClickGun ~= DataMgr.Weapon_ID then
			WardrobeSystem.put_on_weapon_wear(ArmorySystem.ENUM_REQ_Wardrobe, BP_Wardrobe_ClickGun);
			BP_Wardrobe_keep_GunID = BP_Wardrobe_ClickGun
		else
			WardrobeSystem.put_on_weapon_wear(ArmorySystem.ENUM_REQ_Wardrobe, 0);
		end
	else
		-- 没有装备，换预览
		if BP_Wardrobe_GunID ~= BP_Wardrobe_ClickGun then
			BP_Wardrobe_GunID = BP_Wardrobe_ClickGun;
			BP_Wardrobe_keep_GunID = BP_Wardrobe_ClickGun;
			--点击枪械强行装备
			WardrobeSystem.put_on_weapon_wear(ArmorySystem.ENUM_REQ_Wardrobe, BP_Wardrobe_ClickGun);
		else
			if BP_Wardrobe_GunID ~= 0 then
				BP_Wardrobe_keep_GunID = BP_Wardrobe_GunID
			end
			BP_Wardrobe_GunID = 0;
			WardrobeSystem.PutOffGunAvatar();
		end

		WardrobeSystem.UpdateCurrentPutOnGun(true, BP_Wardrobe_GunID);
	end
end

function WardrobeSystem.PutOnGunAvatar(gunID)
	--log("WardrobeSystem.PutOnGunAvatar gunID "..tostring(gunID))

	if gunID == nil then
		return;
	end

	if gunID ~= WardrobeSystem.previewGunResID then
		WardrobeSystem.previewGunResID = gunID;
		LobbyUI:EquipWeapon(DataMgr.roleData.uid, gunID);
	else
		-- log("WardrobeSystem.PutOnGunAvatar equip same skin "..tostring(gunID));
	end
end

function WardrobeSystem.PutOffGunAvatar()
	--log("WardrobeSystem.PutOffGunAvatarb")
	WardrobeSystem.previewGunResID = 0;
	LobbyUI:UnEquipWeapon(DataMgr.roleData.uid);
end

-- 点击枪械皮肤
function WardrobeSystem.OnClickGunSkin()
	-- 已经装备，换皮肤
	local skinInsID = BP_STRUCT_WardrobeClickedItemData.ins_id;
	--log("WardrobeSystem.OnClickGunSkin skinInsID "..skinInsID);

	local cfg = Client.GetTableData("WeaponSkinMapping",BP_STRUCT_WardrobeClickedItemData.res_id)
	BP_Wardrobe_GunID = cfg.WeaponID
	-- log_tree("====BP_STRUCT_WardrobeClickedItemData==",BP_STRUCT_WardrobeClickedItemData)
	BP_Wardrobe_ClickGunSkin = skinInsID;
	if HallThemeUtils.IsWeaponWear(skinInsID) == false then
		-- 装备皮肤
		ArmorySystem.install_weapon_skin(ArmorySystem.ENUM_REQ_Wardrobe, BP_Wardrobe_GunID, skinInsID);
	else
		-- 卸载皮肤
		ArmorySystem.uninstall_weapon_skin(ArmorySystem.ENUM_REQ_Wardrobe, BP_Wardrobe_GunID);
	end

	--LuaClassObj.HandleUIMessageNoFetch(bp_wardrobe, "UpdateGunList")
	WardrobeUI.UpdateSelectItem();
end

-- 装备枪械
function WardrobeSystem.put_on_weapon_wear(client_data, weapon_id)
	--log("WardrobeSystem.put_on_weapon_wear weapon_id "..tostring(weapon_id))
	NetUtil.SendPriorityPkg(false, "put_on_weapon_wear_rsp", "put_on_weapon_wear", client_data, weapon_id);
end

function WardrobeSystem.put_on_weapon_wear_rsp(client_data, res, weapon_id, new_skin_id)
	--log("WardrobeSystem.put_on_weapon_wear_rsp weapon_id "..tostring(weapon_id))
	if res == 0 then
		HallThemeUtils.ProcGunWear(weapon_id, new_skin_id)
		
		DataMgr.InitWeaponData(weapon_id, new_skin_id);

		-- 更新avatar

		if client_data == ArmorySystem.ENUM_REQ_Wardrobe then
			if weapon_id == 0 then
				WardrobeSystem.PutOffGunAvatar()
			end

			-- 更新界面
			WardrobeSystem.UpdateCurrentPutOnGun(true, weapon_id);
		end
	elseif res ~= nil then
		ShowNotice(res);
	end
end

-- 初始化枪械类型
function WardrobeSystem.InitGunTypeArray()
	-- if #BP_ARRAY_Wardrobe_GunType ~= 0 then
	-- 	return;
	-- end

	BP_ARRAY_Wardrobe_GunType = {};

	local tempTable = {}

    local armoryTypeCfgTable = Client.GetTable("ArmoryTypeConfig");
    for k,v in pairs(armoryTypeCfgTable) do
		table.insert(tempTable, v);
    end

    table.sort(tempTable, function(a, b)
    	return a.TypeID < b.TypeID;
	end);

	local strMsg = Client.GetTableData("LocalizeRes",4462).TextValue
	table.insert(BP_ARRAY_Wardrobe_GunType, strMsg)

	for i,v in ipairs(tempTable) do
		table.insert(BP_ARRAY_Wardrobe_GunType, v.TypeName);
	end

	return BP_ARRAY_Wardrobe_GunType
end

-- 重建枪械数据
function WardrobeSystem.RebuildGunData()
	if not ArmorySystem.rsp_list or not ArmorySystem.rsp_list.skin_list then
		return;
	end

	WardrobeSystem.InitGunTypeArray();
	WardrobeSystem.InitGunTable();
end

-- 通过皮肤id添加小红点
function WardrobeSystem.AddGunHotDotBySkin(skinResID)
	--log("WardrobeSystem.AddGunHotDotBySkin skinResID "..tostring(skinResID))

	WardrobeSystem.skinHotDotMap[skinResID] = true;
	WardrobeUI.UpdatePanelRedPointForGun(true)
end

-- 通过枪ID取消小红点
function WardrobeSystem.RemoveGunHotDot(gunID)
	--log("WardrobeSystem.RemoveGunHotDot gunID "..tostring(gunID))
	-- log_tree("WardrobeSystem.RemoveGunHotDot before WardrobeSystem.skinHotDotMap", WardrobeSystem.skinHotDotMap)

	local skinList = ArmorySystem.GetSkinListByWeaponID(gunID);
	-- log_tree("WardrobeSystem.RemoveGunHotDot skinList", skinList)

	if skinList then
		for k,v in pairs(skinList) do
			if v then
				if WardrobeSystem.skinHotDotMap[k] then
					WardrobeSystem.skinHotDotMap[k] = nil;
				end
			end
		end

		-- WardrobeSystem.UpdateLobbyHotDot();

		local isFind = WardrobeSystem.HasAnyGunSkinHotDot();
		if not isFind then
			WardrobeUI.UpdatePanelRedPointForGun(false);
		end
	end

	-- log_tree("WardrobeSystem.RemoveGunHotDot after WardrobeSystem.skinHotDotMap", WardrobeSystem.skinHotDotMap)
end

function WardrobeSystem.ContainsGunSkinHotDot(skinResID)
	return WardrobeSystem.skinHotDotMap[skinResID] == true;
end

function WardrobeSystem.ContainsGunHotDot(gunID)
	local skinList = ArmorySystem.GetSkinListByWeaponID(gunID);
	if not skinList then
		return false;
	end

	-- log_tree("WardrobeSystem.ContainsGunHotDot skinList", skinList);
	for k,v in pairs(skinList) do
		if WardrobeSystem.skinHotDotMap[k] == true then
			return true
		end
	end

	return false
end

function WardrobeSystem.UpdateGunListRedPoint()
	--log("WardrobeSystem.UpdateGunListRedPoint")
	BP_ARRAY_Wardrobe_TabRedPoint = {}

	for i,v in ipairs(BP_ARRAY_Wardrobe_GunResInfoList) do
		if WardrobeSystem.ContainsGunHotDot(v.resID) then
			table.insert(BP_ARRAY_Wardrobe_TabRedPoint, i - 1)
		end
	end
end

function WardrobeSystem.ShowLobbyHotDot(isShow)
	--log("WardrobeSystem.ShowLobbyHotDot isShow "..tostring(isShow))
	WardrobeSystem.UpdateLobbyHotDot();
	LobbyUI:LobbyRedPointUpdate(BP_ENUM_LOBBY_MENU_ARMORY, isShow);
end

function WardrobeSystem.HasAnyGunSkinHotDot()
	return next(WardrobeSystem.skinHotDotMap) ~= nil;
end

function WardrobeSystem.on_item_compose(instid, count)
	--log("WardrobeSystem.on_item_compose :"..instid)
	NetUtil.SendPriorityPkg(false, "on_item_compose_rsp", "on_item_compose", instid, count);
end

function WardrobeSystem.on_item_compose_rsp(res, item_list)
	--log("on_item_compose_rsp: " .. res);

	log_tree("item_list", item_list);

    if res == "ok" then
		CommonItemGetUI:ShowPanel(item_list);
    else
       DataMgr.ShowNoticeByID(res);
    end
end

function WardrobeSystem.IsServerJK()
    local iServerRegion = TeamUpSystem.ChooseZoneId;
    return (iServerRegion == 6)
end

function WardrobeSystem.IsItemIsolated( resId )
	-- if true then return true end
	if resId == 0 then
		return false;
	end
	
    local bServerJk = WardrobeSystem.IsServerJK();

    local itemCfg = DataMgr.WardrobeItemList[resId];
	if(itemCfg == nil) then
		itemCfg = Client.GetTableData("Item", resId);
	end
    if itemCfg then
    	local strRegion = itemCfg.ItemRegion;
    	local bItemJk = (strRegion == "krjp");
    	local bItemGlobal = (strRegion == "global");
    	if bItemGlobal and bServerJk or (bItemJk and not bServerJk) then
    		return true;
    	end

    	local validRegionCodes = string.split(itemCfg.ValidRegionCodes, "|")
    	if #validRegionCodes > 1 then
    		for i, regionCode in ipairs(validRegionCodes) do
    			if regionCode == LoginSystem.ip_region then
    				return false
    			end
    		end

    		return true
    	end
    	
    end
    return false;
end

function WardrobeSystem.HasSameDiySuit(resID, colorID, patternID)
	for k,v in pairs(DataMgr.arrayHallDepotItemInfo) do
		if v.resID == resID and v.colorID == colorID and v.patternID == patternID then
			return true;
		end
	end
	return false;
end

--获取烧鸡道具itemid，区分全球版，日韩版
function WardrobeSystem.GetShaoJiItemId()
	if FuncUtil.IsPlayerJPKR() then
		return 1602908
	else
		return 1602008
	end
end

-- 同步头部物品（帽子 or 头盔）给服务器
function WardrobeSystem.depot_set_head_show_req(insID)
	NetUtil.SendPkg("depot_set_head_show_req", insID);
	log("depot_set_head_show_req : " .. insID)
end

function WardrobeSystem.depot_set_skin_info_req(bag, helmet)
	local level = {};
	level.bag_level = bag;
	level.helmet_level = helmet;
	NetUtil.SendPkg("depot_set_skin_info_req", level);
	log_tree("depot_set_skin_info_req ", level)
end

function WardrobeSystem.depot_set_skin_info_rsp(error_code, skin_info)
	if(error_code == 0 or error_code == "0") then
		log("depot_set_skin_info_rsp success")
		log_tree("skin_info", skin_info)
		local itemSubType = BP_CurTabType;
		wearInfo = WardrobeUI.currentWearPreviewMap[itemSubType];
		if wearInfo ~= nil then
			local itemInsID = wearInfo.insID;
			local itemResID = WardrobeUI:GetEquipmentItemIDBySkinInsID(itemSubType, itemInsID);
			log("EventWardrobeClickEquipmentLevel EquipmentChange:oldResID"..wearInfo.resID.." newResID"..itemResID);
			WardrobeUI.AddToWearInfo(itemSubType, itemInsID, itemResID, wearInfo.colorID, wearInfo.patternID);
			LobbyUI:AvatarChange(LobbyUI:CreateAvatarChangeData(DataMgr.roleData.uid, itemResID, wearInfo.colorID, wearInfo.patternID), true)
			DataMgr.bag_level = BP_STRUCT_WardrobeEquipmentLevel.bag;
			DataMgr.helmet_level = BP_STRUCT_WardrobeEquipmentLevel.helmet;
		end
	else
		log("errorCode is : " .. error_code)
	end
end

--获取烧鸡道具itemid，区分全球版，日韩版
function WardrobeSystem.GetShaoJiItemId()
	if FuncUtil.IsPlayerJPKR() then
		return 1602908
	else
		return 1602008
	end
end

--[[网络回调]]--
--s2c["list_depot_rsp"] = WardrobeSystem.on_itemlist_rsp;
s2c["depot_sell_item_rsp"] = WardrobeSystem.on_sell_rsp;
s2c["use_item_rsp"] = WardrobeSystem.on_use_item_rsp;
s2c["equip_motion_rsp"] = WardrobeSystem.equip_motion_rsp;
s2c["unequip_motion_rsp"] = WardrobeSystem.unequip_motion_rsp;
s2c["exchange_motion_rsp"] = WardrobeSystem.exchange_motion_rsp;
s2c["put_on_weapon_wear_rsp"] = WardrobeSystem.put_on_weapon_wear_rsp;
s2c["select_use_rolewear_rsp"] = WardrobeSystem.on_select_use_rolewear_rsp;
s2c["unlock_rolewear_rsp"] = WardrobeSystem.on_unlock_rolewear_rsp;
s2c["update_rolewear_state"] = WardrobeSystem.on_update_rolewear_state;
s2c["on_item_compose_rsp"] = WardrobeSystem.on_item_compose_rsp;
s2c["depot_set_skin_info_rsp"] = WardrobeSystem.depot_set_skin_info_rsp;
