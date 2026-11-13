--rain 宠物logic
local PetSystem =
{
	PetCfg = {},
	PetLevelCfg = {},
	PetActionCfg = {},
	FoodCfg = {},
	MyPetInfo = {},
    bShowEquipTips = false,
	isInited = false,
	isReadyToShowPetMain = false,
	PetGuideImgUrl = "",

	Enum_AccessType = {
		EnumPet = 1,
		EnumFood = 2,
	},
	Enum_PetJumpType = {
		EnumJumpToStore = 1,
		EnumJumpToSupply = 2,
		EnumJumpToPass = 3,
	},
	Enum_PetNoticeType = {
		EnumPetEquip = 1,
		EnumPetUnequip = 2,
		EnumPetLevelUp = 3,
		EnumPetPlayAction = 4,
		EnumPetRename = 5,
	}
}

--------------------------宠物协议结构体--------------------------
--     PetSystem.sync_pet_data,data:
--     ├─ equip_pet_id: 0
--     ├─ pets
--     │  └─ 10001
--     │     ├─ id: 10001
--     │     └─ exp: 0
--     |     └─ name: 非必有字段
--     └─ pet_cnt: 0

function PetSystem.HandleErrorCode(errorCode)
	log("PetSystem.HandleErrorCode code: " .. tostring(errorCode))
	if errorCode == 0 then
		return true
	elseif errorCode == 530001 then --未找到宠物
		ShowNotice(530001);
	elseif errorCode == 530002 then --未找到宠物配置
		ShowNotice(530002);
	elseif errorCode == 530003 then --扣除道具失败
		ShowNotice(530003);
	elseif errorCode == 530004 then --未找到该经验道具
		ShowNotice(530004);
	elseif errorCode == 530005 then --队伍已解散
		ShowNotice(530005);
	elseif errorCode == 530006 then --伙伴不在队伍中
		ShowNotice(530006);
	elseif errorCode == 530007 then --已经达到最高等级
		ShowNotice(530007);
	elseif errorCode == 530008 then --无法使用经验道具
		ShowNotice(530008);
	elseif errorCode == 530009 then --无法使用经验道具
		ShowNotice(530010);
	elseif errorCode == 530010 then --伙伴名字不合要求
		ShowNotice(530010);
	elseif errorCode == 530011 then --伙伴名字过长
		ShowNotice(530011);
	elseif errorCode == 530012 then --此时无法更改伙伴名字
		ShowNotice(530012);
	elseif errorCode == 530013 then --伙伴改名卡扣除失败
		ShowNotice(530013);
	elseif errorCode == 120164 then --操作太频繁，请稍后再试
		ShowNotice(120164);
	end
	return false;
end

--读取宠物配置表和宠物等级配置表
function PetSystem.InitPetFromTable()
	log("PetSystem.InitPetFromTable isInited = " .. tostring(PetSystem.isInited));
	if PetSystem.isInited == false then
		for _, v in pairs(Client.GetTable("PetTable")) do
			local temp = {}
			temp.PetID = v.PetID
			temp.PetName = v.PetName
			temp.PetMaxLevel = v.PetMaxLevel
			temp.FoodCnt = v.FoodCnt
			temp.Foods = {}
			temp.Foods[1] = v.FoodID1
			temp.Foods[2] = v.FoodID2
			temp.Foods[3] = v.FoodID3
			temp.JumpType = v.JumpType
			temp.JumpUrl = v.JumpUrl
			temp.PetImage = v.PetImage
			temp.ShareBgUrl = v.ShareBgUrl

			table.insert(PetSystem.PetCfg, temp)
		end
		log_tree("PetSystem.InitPetFromTable PetCfg: ", PetSystem.PetCfg);

		for _, v in pairs(Client.GetTable("PetLevelTable")) do
			local temp = {}
			temp.KeyID = v.KeyID
			temp.PetID = v.PetID
			temp.PetLevel = v.PetLevel
			temp.PetNeedExp = v.PetNeedExp
			temp.ActionCnt = v.ActionCnt
			temp.Actions = {}
			temp.Actions[1] = v.ActionID1
			temp.Actions[2] = v.ActionID2
			temp.Actions[3] = v.ActionID3
			temp.Actions[4] = v.ActionID4
			temp.Actions[5] = v.ActionID5
			temp.AllAction = v.AllAction

			table.insert(PetSystem.PetLevelCfg, temp)
		end
		log_tree("PetSystem.InitPetFromTable PetLevelCfg: ", PetSystem.PetLevelCfg);

		for _, v in pairs(Client.GetTable("PetActionTable")) do
			local temp = {}
			temp.PetActionID = v.PetActionID
			temp.PetID = v.PetID
			temp.PetActionName = v.PetActionName
			temp.SortKey = v.SortKey
			temp.PetAnimRes = v.PetAnimRes
			temp.PetActionIcon = v.PetActionIcon
            temp.ShowInLobby = v.ShowInLobby

			table.insert(PetSystem.PetActionCfg, temp)
		end
		table.sort(PetSystem.PetActionCfg,function(a,b)
			return a.SortKey < b.SortKey
		end)
		log_tree("PetSystem.InitPetFromTable PetActionCfg: ", PetSystem.PetActionCfg);

		for _, v in pairs(Client.GetTable("FoodTable")) do
			local temp = {}
			temp.FoodID = v.FoodID
			temp.FoodAddExp = v.FoodAddExp

			table.insert(PetSystem.FoodCfg, temp)
		end
		log_tree("PetSystem.InitPetFromTable FoodCfg: ", PetSystem.FoodCfg);

		for _, v in pairs(Client.GetTable("PetGuideTable")) do
			PetSystem.PetGuideImgUrl = v.PetGuideImgUrl
		end

		PetSystem.isInited = true
	end
end

--根据宠物ID获取对应宠物配置表
function PetSystem.GetPetItemCfgByPetID(pet_id)
	if PetSystem.PetCfg == nil then
		log("PetSystem.GetPetItemCfgByPetID PetSystem.PetCfg = nil")
		return nil
	end

	for i, v in pairs(PetSystem.PetCfg) do
		if pet_id == v.PetID then
			return v
		end
	end
	return nil
end

--根据宠物ID获取自己的宠物信息
function PetSystem.GetPetDataByPetID(pet_id)
	if PetSystem.MyPetInfo == nil then
		log("PetSystem.GetPetDataByPetID PetSystem.MyPetInfo = nil")
		return nil
	end

	if PetSystem.MyPetInfo.pets == nil then
		return nil
	end

	return PetSystem.MyPetInfo.pets[pet_id]
end

--根据宠物DI和等级获取对应的宠物等级配置表
function PetSystem.GetPetLevelItemCfg(pet_id, pet_level)
	if PetSystem.PetLevelCfg == nil then
		log("PetSystem.GetPetLevelItemCfg PetSystem.PetLevelCfg = nil")
		return nil
	end

	for _, v in pairs(PetSystem.PetLevelCfg) do
		if pet_id == v.PetID and pet_level == v.PetLevel then
			return v
		end
	end

	return nil
end

--根据宠物ID和总经验值获取当前宠物在这一级的经验值
function PetSystem.GetCurLevelExp(pet_id, exp)
	if exp <= 0 then
		return 0
	end

	if not PetSystem.PetLevelCfg then
		return 0
	end

	for k, v in ipairs(PetSystem.PetLevelCfg) do
		if v.PetID == pet_id then
			if exp >= v.PetNeedExp then
				exp = exp - v.PetNeedExp
			else
				return exp
			end
		end
	end

	return exp
end

--根据宠物ID获取我的宠物的当季
function PetSystem.GetMyPetLevel(pet_id)
	local level = 1
	local petData = PetSystem.GetPetDataByPetID(pet_id)
	if petData == nil then
		return level
	end

	level = PetSystem.GetPetLevelByExp(pet_id, petData.exp)
	return level
end

--根据宠物ID和总经验值获取对应宠物当前等级
function PetSystem.GetPetLevelByExp(pet_id, exp)
	local level = 1
	if exp <= 0 then
		return level
	end

	if not PetSystem.PetLevelCfg then
		return level
	end

	for _, v in ipairs(PetSystem.PetLevelCfg) do
		if v.PetID == pet_id then
			level = v.PetLevel
			if exp >= v.PetNeedExp then
				exp = exp - v.PetNeedExp
			else
				return level
			end
		end
	end
	return level
end

--根据食物ID获取对应增加的经验
function PetSystem.GetAddExpByFoodID(foodID)
	for _, v in pairs(PetSystem.FoodCfg) do
		if foodID == v.FoodID then
			return v.FoodAddExp
		end
	end
	return 0
end

--是否拥有该宠物
function PetSystem.HasPet(pet_id)
	if PetSystem.MyPetInfo == nil then
		log("PetSystem.HasPet PetSystem.MyPetInfo = nil")
		return false
	end

	if PetSystem.MyPetInfo.pet_cnt == nil or PetSystem.MyPetInfo.pet_cnt == 0 then
		return false
	end

	for i, v in pairs(PetSystem.MyPetInfo.pets) do
		if pet_id == v.id then
			return true 
		end
	end
	return false
end

--是否出战
function PetSystem.IsPetEquip(pet_id)
	if PetSystem.MyPetInfo == nil then
		log("PetSystem.HasPet PetSystem.MyPetInfo = nil")
		return false
	end

	return PetSystem.MyPetInfo.equip_pet_id == pet_id
end

function PetSystem.GetEquipedPet()
	if PetSystem.MyPetInfo == nil then
		return 0
	end

	return PetSystem.MyPetInfo.equip_pet_id or 0
end

--动作是否解锁
function PetSystem.IsActionUnLock(petID, petActionID)
	if PetSystem.HasPet(petID) then
		local petData = PetSystem.GetPetDataByPetID(petID)
		local level = PetSystem.GetPetLevelByExp(petData.id, petData.exp)
		local curPetLevelData = PetSystem.GetPetLevelItemCfg(petData.id, level)

		local allAction = string.split(curPetLevelData.AllAction, "|")
		for _, v in pairs(allAction) do
			if tostring(petActionID) == v then
				return true
			end
		end
	end
	return false
end

--解锁动作所需等级
function PetSystem.GetUnlockActionNeedLevel(petID, actionID)
	for _, v1 in pairs(PetSystem.PetLevelCfg) do
		if v1.PetID == petID then
			local allAction = string.split(v1.AllAction, "|")
			for _, v2 in pairs(allAction) do
				if tostring(actionID) == v2 then
					return v1.PetLevel
				end
			end
		end
	end
	return 1
end

--获得宠物数据
function PetSystem.get_pet_data_req()
	log("PetSystem.get_pet_data_req")
	NetUtil.SendPriorityPkg(false, "sync_pet_data", "get_pet_data_req");
end

function PetSystem.sync_pet_data(data)
	--log_tree("PetSystem.sync_pet_data,data:", data)
	if data == nil then
		log("PetSystem.sync_pet_data data == nil")
	else
		--装备宠物ID发生变化时通知
		if PetSystem.MyPetInfo == nil then
			PetSystem.MyPetInfo = data

			local level = PetSystem.GetMyPetLevel(data.equip_pet_id)
			local petData = {}
			petData.UID = DataMgr.roleData.uid
			petData.PetID = data.equip_pet_id
			petData.PetLevel = level
			EventSystem:postEvent(EVENTTYPE_PET, EVENTID_PET_EquipPet_Change, petData);
		elseif  PetSystem.MyPetInfo.equip_pet_id ~= data.equip_pet_id then
			PetSystem.MyPetInfo = data

			local level = PetSystem.GetMyPetLevel(data.equip_pet_id)
			local petData = {}
			petData.UID = DataMgr.roleData.uid
			petData.PetID = data.equip_pet_id
			petData.PetLevel = level
			EventSystem:postEvent(EVENTTYPE_PET, EVENTID_PET_EquipPet_Change, petData);
		else
			PetSystem.MyPetInfo = data
		end
	end

	if PetSystem.isReadyToShowPetMain then
		if string.lower(LuaClassObj.GetGameStatus(bp_lobby)) == "lobby" then
			local ui_manager = require("ui.manager");
			if ui_manager then
				local time_ticker = require("client.time_ticker")
				time_ticker.AddTimer(0, function()
					--WardrobeUI:Hide()
					LuaClassObj.HandleUIMessage(bp_wardrobe, "UIHide");
					coroutine.yield(0.02)
					ui_manager.ShowUI(ui_manager.UI_Config.pet_main)
				end)
			end
		end
	end
	PetSystem.isReadyToShowPetMain = false
end

function PetSystem.notice_pet_change(pets)
	--log_tree("PetSystem.notice_pet_change, pets:", pets)
	local PlayerPrefsSystem = require("client.tools.playerprefs")

	if pets == nil then
		log("PetSystem.notice_pet_change pets == nil")
		return
	end

	if PetSystem.MyPetInfo == nil then
		log("PetSystem.notice_pet_change MyPetInfo == nil")
		return
	end

	for _, v in pairs(pets) do
		--判断是否拥有新宠物
		if PetSystem.MyPetInfo.pets[v.id] == nil then
            PetSystem.bShowEquipTips = true

			BP_Wardrobe_Pet_RedPoint = true
			local redPoint = {}
			redPoint.NeedShowPetRedPoint = BP_Wardrobe_Pet_RedPoint

			PlayerPrefsSystem.SaveTableToFile(redPoint, PlayerPrefsSystem.ePlayerPrefsType.ePetRedPoint, true)

			WardrobeSystem.UpdateLobbyHotDot()
		else
			--判断是否升级 升级则红点
			local oldLevel = PetSystem.GetPetLevelByExp(v.id, PetSystem.MyPetInfo.pets[v.id].exp)
			local newLevel = PetSystem.GetPetLevelByExp(v.id, v.exp)
			if newLevel > oldLevel then
				BP_Wardrobe_Pet_RedPoint = true

				local redPoint = {}
				redPoint.NeedShowPetRedPoint = BP_Wardrobe_Pet_RedPoint

				PlayerPrefsSystem.SaveTableToFile(redPoint, PlayerPrefsSystem.ePlayerPrefsType.ePetRedPoint, true)

				WardrobeSystem.UpdateLobbyHotDot()
			end
		end
		PetSystem.MyPetInfo.pets[v.id] = v
	end

	local cnt = 0
	for _, v in pairs(PetSystem.MyPetInfo.pets) do
		cnt = cnt + 1
	end
    PetSystem.MyPetInfo.pet_cnt = cnt

	EventSystem:postEvent(EVENTTYPE_PET, EVENTID_PET_Change);
end

--装备宠物 上行
function PetSystem.equip_pet_req(pet_id)
	log("PetSystem.equip_pet_rep")
	NetUtil.SendPriorityPkg(false, "equip_pet_rsp", "equip_pet_req", pet_id);
end

--装备宠物 下行
function PetSystem.equip_pet_rsp(code, pet_id)
	log("PetSystem.equip_pet_rsp code:" .. tostring(code) .. "pet_id:" .. tostring(pet_id))
	if PetSystem.HandleErrorCode(code) then
		PetSystem.MyPetInfo.equip_pet_id = pet_id
		EventSystem:postEvent(EVENTTYPE_PET, EVENTID_PET_EquipPet_Success, pet_id);

		local level = PetSystem.GetMyPetLevel(pet_id)
		local petData = {}
		petData.UID = DataMgr.roleData.uid
		petData.PetID = pet_id
		petData.PetLevel = level
		EventSystem:postEvent(EVENTTYPE_PET, EVENTID_PET_EquipPet_Change, petData);
	end
end

--卸下宠物 上行
function PetSystem.unequip_pet_req()
	log("PetSystem.unequip_pet_rep")
	NetUtil.SendPriorityPkg(false, "unequip_pet_rsp", "unequip_pet_req");
end

--卸下宠物 下行
function PetSystem.unequip_pet_rsp(code)
	log("PetSystem.equip_pet_rsp code:" .. tostring(code))
	if PetSystem.HandleErrorCode(code) then
		PetSystem.MyPetInfo.equip_pet_id = 0
		EventSystem:postEvent(EVENTTYPE_PET, EVENTID_PET_UnequipPet_Success);

		local petData = {}
		petData.UID = DataMgr.roleData.uid
		petData.PetID = 0
		petData.PetLevel = 0
		EventSystem:postEvent(EVENTTYPE_PET, EVENTID_PET_EquipPet_Change, petData);
	end
end

--升级宠物 上行
function PetSystem.pet_add_exp_req(pet_id, food_id, cnt)
	log("PetSystem.pet_add_exp_rep")
	NetUtil.SendPriorityPkg(false, "pet_add_exp_rsp", "pet_add_exp_req", pet_id, food_id, cnt);
end

--升级宠物 下行
function PetSystem.pet_add_exp_rsp(code, pet_id, exp)
	if PetSystem.HandleErrorCode(code) then
		local oldLevel = PetSystem.GetPetLevelByExp(pet_id, PetSystem.MyPetInfo.pets[pet_id].exp)
		local newLevel = PetSystem.GetPetLevelByExp(pet_id, exp)
		if newLevel > oldLevel then
			local petData = {}
			petData.UID = DataMgr.roleData.uid
			petData.PetLevel = newLevel
			EventSystem:postEvent(EVENTTYPE_PET, EVENTID_PET_LevelUp, petData);
		end

		--修改我的宠物经验数据
		local addExp = exp - PetSystem.MyPetInfo.pets[pet_id].exp
		PetSystem.MyPetInfo.pets[pet_id].exp = exp

		local petData = {}
		petData.UID = DataMgr.roleData.uid
		petData.PetID = pet_id
		petData.PetExp = exp
		petData.PetAddExp = addExp

		EventSystem:postEvent(EVENTTYPE_PET, EVENTID_PET_AddExp_Success, petData);

	end
end

--宠物改名 上行
function PetSystem.pet_reanme_req(pet_id, name)
	log("PetSystem.pet_reanme_req")
	NetUtil.SendPriorityPkg(false, "pet_reanme_rsp", "pet_reanme_req", pet_id, name);
end

--宠物改名 下行
function PetSystem.pet_reanme_rsp(code, pet_id, name, oldName)
	log("PetSystem.pet_reanme_rsp")
	if PetSystem.HandleErrorCode(code) then
		PetSystem.MyPetInfo.pets[pet_id].name = name

		local petData = {}
		petData.UID = DataMgr.roleData.uid
		petData.PetID = pet_id
		petData.PetName = name
		EventSystem:postEvent(EVENTTYPE_PET, EVENTID_PET_Rename, petData);
	end
end

--播放宠物动作 上行
function PetSystem.pet_action_req(action_id)
	if TeamAvatarManager.GetAvatarCount() == 1 then
		--log("只有一个人 "..action_id)
		local petID = PetSystem.MyPetInfo.equip_pet_id or 0
		if PetSystem.IsActionUnLock(petID ,action_id) == true then
			--log("已经解锁")
			local petData = {}
			petData.UID = DataMgr.roleData.uid
			petData.PetActionID = action_id
			EventSystem:postEvent(EVENTTYPE_PET, EVENTID_PET_PlayAction, petData)
		else
			--log("没有解锁")
		end
		return
	end

	log("PetSystem.pet_action_req")
	NetUtil.SendPriorityPkg(false, "pet_action_rsp", "pet_action_req", action_id);
end

function PetSystem.pet_action_rsp(code, action_id)
	log("PetSystem.pet_action_rsp code:" .. tostring(code) .. "pet_id:" .. tostring(action_id))
	if PetSystem.HandleErrorCode(code) then
		local petData = {}
		petData.UID = DataMgr.roleData.uid
		petData.PetActionID = action_id
		EventSystem:postEvent(EVENTTYPE_PET, EVENTID_PET_PlayAction, petData);
	end
end

function PetSystem.notice_pet_event_res(notice_info)
	log_tree("PetSystem.notice_pet_event_res notice_info: ", notice_info)
	if notice_info == nil then
		return
	end

	if notice_info.type == PetSystem.Enum_PetNoticeType.EnumPetPlayAction then --队友宠物播放动作
		local petData = {}
		petData.UID = notice_info.send_uid
		petData.PetActionID = notice_info.action_id
		EventSystem:postEvent(EVENTTYPE_PET, EVENTID_PET_PlayAction, petData);
	elseif notice_info.type == PetSystem.Enum_PetNoticeType.EnumPetLevelUp then --队友宠物升级
		local level = PetSystem.GetPetLevelByExp(notice_info.pet_id, notice_info.exp)
		local petData = {}
		petData.UID = notice_info.send_uid
		petData.PetLevel = level
		EventSystem:postEvent(EVENTTYPE_PET, EVENTID_PET_LevelUp, petData);
	elseif notice_info.type == PetSystem.Enum_PetNoticeType.EnumPetUnequip then
		local petData = {}
		petData.UID = notice_info.send_uid
		petData.PetID = notice_info.pet_id
		petData.PetLevel = 1
		EventSystem:postEvent(EVENTTYPE_PET, EVENTID_PET_EquipPet_Change, petData);
	elseif notice_info.type == PetSystem.Enum_PetNoticeType.EnumPetEquip then
		local level = PetSystem.GetPetLevelByExp(notice_info.pet_id, notice_info.exp)
		local petData = {}
		petData.UID = notice_info.send_uid
		petData.PetID = notice_info.pet_id
		petData.PetLevel = level
		EventSystem:postEvent(EVENTTYPE_PET, EVENTID_PET_EquipPet_Change, petData);
	else
		local petData = {}
		petData.UID = notice_info.send_uid
		petData.PetID = notice_info.pet_id
		petData.PetName = notice_info.name
		EventSystem:postEvent(EVENTTYPE_PET, EVENTID_PET_Rename, petData);
	end
end

return PetSystem