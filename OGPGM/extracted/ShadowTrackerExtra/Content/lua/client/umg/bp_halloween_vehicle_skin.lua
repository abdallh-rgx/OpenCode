-- 万圣节载具皮肤兑换
HalloweenVehicleSkinUI = HalloweenVehicleSkinUI or {
	SkinInfoMap = {},
	isShow = false,
};

BP_STRUCT_Halloween_Vehicle_Skin_Info = {
	skinId = 0, 
	status = 0, --0表示不可兑换，1表示已兑换, 2表示可以兑换
	costCandy = 0, --消耗的糖果数量
	fromSkinId = 0, --从哪个皮肤升级的
	lineId = 0,
	index = 1,
};

--第一组皮肤的升级状态
BP_ARRAY_Halloween_Vehicle_Skin_Info1 = {
	BP_STRUCT_Halloween_Vehicle_Skin_Info = _G.BP_STRUCT_Halloween_Vehicle_Skin_Info
};

--第二组皮肤的升级状态
BP_ARRAY_Halloween_Vehicle_Skin_Info2 = {
	BP_STRUCT_Halloween_Vehicle_Skin_Info = _G.BP_STRUCT_Halloween_Vehicle_Skin_Info
};

BP_Halloween_Vehicle_DateTime = "" --万圣节活动时间

BP_Halloween_Vehicle_CandyCount = 0 --玩家拥有的糖果数量

BP_Halloween_Vehicle_SelectSkinId = 0 --选择SKinId

BP_STRUCT_Halloween_Vehicle_Skin_CurrInfo = _G.BP_STRUCT_Halloween_Vehicle_Skin_Info

BP_Halloween_Vehicle_LobbyMeshBg_Id = 5 --载具背景

function bp_halloween_vehicle_skin_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_halloween_vehicle_skin,
                                {{Path="/Game/UMG/UI_Logic/HalloweenVehicle/Halloween_Vehicle_Skin_BP.Halloween_Vehicle_Skin_BP_C", Container="Default", ZOrder=BP_ENUM_UI_HALLOWEEN_VEHICLE_ZORDER}},
                                {"Lobby"},
                                false,
                                false,
                                true);
end

function HalloweenVehicleSkinUI.ShowUI()
	HalloweenVehicleSkinUI.isShow = true
    log("HalloweenVehicleSkinUI.ShowUI");
	-- if true then
	-- 	BP_ARRAY_Halloween_Vehicle_Skin_Info1 = {}
	-- 	table.insert(BP_ARRAY_Halloween_Vehicle_Skin_Info1, {skinId = 1903101, status = 0, costCandy = 1, fromSkinId = 0});
	-- 	table.insert(BP_ARRAY_Halloween_Vehicle_Skin_Info1, {skinId = 1903102, status = 0, costCandy = 1, fromSkinId = 1903101});
	-- 	table.insert(BP_ARRAY_Halloween_Vehicle_Skin_Info1, {skinId = 1903103, status = 0, costCandy = 1, fromSkinId = 1903102});

	-- 	BP_ARRAY_Halloween_Vehicle_Skin_Info2 = {}
	-- 	table.insert(BP_ARRAY_Halloween_Vehicle_Skin_Info2, {skinId = 1903104, status = 0, costCandy = 1, fromSkinId = 0});
	-- 	table.insert(BP_ARRAY_Halloween_Vehicle_Skin_Info2, {skinId = 1903105, status = 0, costCandy = 1, fromSkinId = 1903104});
	-- 	table.insert(BP_ARRAY_Halloween_Vehicle_Skin_Info2, {skinId = 1903106, status = 0, costCandy = 1, fromSkinId = 1903105});

	-- 	for i,v in ipairs(BP_ARRAY_Halloween_Vehicle_Skin_Info1) do
	-- 		HalloweenVehicleSkinUI.SkinInfoMap[v.skinId] = v
	-- 	end

	-- 	for i,v in ipairs(BP_ARRAY_Halloween_Vehicle_Skin_Info2) do
	-- 		HalloweenVehicleSkinUI.SkinInfoMap[v.skinId] = v
	-- 	end
	-- end

    LuaClassObj.HandleDynamicCreation(bp_halloween_vehicle_skin);
    HalloweenVehicleSkinUI.RefreshData();


    LuaClassObj.HandleUIMessage(bp_lobby, "CloseOtherMenu")

    	--hide 所有的主界面
	EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN)

	--LuaClassObj.HandleUIMessage(bp_unknow_pass, "UIShowAvatarAni");
	--LuaClassObj.HandleUIMessage(bp_unknow_pass, "SwitchToUnknowPassCamera");

	LuaClassObj.HandleUIMessage(bp_lobby, "EndLobbyToMall");

			--隐藏玩家
	LuaClassObj.HandleUIMessage(bp_lobby, "HideMallPlayer");

	LobbyCameraManager.SwitchCamera(10108);

    --HalloweenVehicleSkinUI.ShowItem(1903101) --何时销毁呢？·

	local strRegion = Client.GetPublishRegion();
	if strRegion == "JAPAN" or strRegion == "KOREA" then
		
	else
		HalloweenVehicleSkinUI.InitSelectSkinId()
		log("BP_Halloween_Vehicle_SelectSkinId   " .. tostring(BP_Halloween_Vehicle_SelectSkinId));
		if BP_Halloween_Vehicle_SelectSkinId ~= 0 then
			BP_STRUCT_Halloween_Vehicle_Skin_CurrInfo = HalloweenVehicleSkinUI.SkinInfoMap[BP_Halloween_Vehicle_SelectSkinId]
			HalloweenVehicleSkinUI.ShowItem(BP_Halloween_Vehicle_SelectSkinId)
			LuaClassObj.HandleUIMessageNoFetch(bp_halloween_vehicle_skin, "RefreshSelectInfo");
		end
	end

    BP_Halloween_Vehicle_CandyCount = LogicHalloweenVehicle.GetCandyCount()

    EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_DATA_CHANGE, HalloweenVehicleSkinUI.UpdateCandyCount)
    --EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CHANGE, HalloweenVehicleSkinUI.RefreshUI) 

    LuaClassObj.HandleUIMessage(bp_halloween_vehicle_skin, "UIShow");
end

function HalloweenVehicleSkinUI.UpdateCandyCount()
 	BP_Halloween_Vehicle_CandyCount = LogicHalloweenVehicle.GetCandyCount()

 	LuaClassObj.HandleUIMessage(bp_halloween_vehicle_skin, "RefreshUI");
end

function HalloweenVehicleSkinUI.InitSelectSkinId()
	local canUpgradeIdTb = {}
    log_tree("BP_ARRAY_Halloween_Vehicle_Skin_Info1    " , BP_ARRAY_Halloween_Vehicle_Skin_Info1);
    log_tree("BP_ARRAY_Halloween_Vehicle_Skin_Info2    " , BP_ARRAY_Halloween_Vehicle_Skin_Info2);

    if #BP_ARRAY_Halloween_Vehicle_Skin_Info1 ~= 0 then   --如果是两套皮肤
        for i,v in ipairs(BP_ARRAY_Halloween_Vehicle_Skin_Info1) do
            if v.status == 2 and v.costCandy <= LogicHalloweenVehicle.GetCandyCount() then
                table.insert(canUpgradeIdTb, v.skinId)
                break
            end
        end

        for i,v in ipairs(BP_ARRAY_Halloween_Vehicle_Skin_Info2) do
            if v.status == 2 and v.costCandy <= LogicHalloweenVehicle.GetCandyCount() then
                table.insert(canUpgradeIdTb, v.skinId)
                break
            end
        end


        if #canUpgradeIdTb >= 1 then
            BP_Halloween_Vehicle_SelectSkinId = canUpgradeIdTb[math.random(#canUpgradeIdTb)]
            log_tree("canUpgradeIdTb", canUpgradeIdTb)
        else
            local canSelectIdTb = {}
            if BP_ARRAY_Halloween_Vehicle_Skin_Info1[3].status ~= 1 then
                table.insert(canSelectIdTb, BP_ARRAY_Halloween_Vehicle_Skin_Info1[3].skinId)
            end

            if BP_ARRAY_Halloween_Vehicle_Skin_Info2[3].status ~= 1 then
                table.insert(canSelectIdTb, BP_ARRAY_Halloween_Vehicle_Skin_Info2[3].skinId)
            end

            if #canSelectIdTb >= 1 then
                BP_Halloween_Vehicle_SelectSkinId = canSelectIdTb[math.random(#canSelectIdTb)]
            else
                if math.random(2) == 1 then
                    BP_Halloween_Vehicle_SelectSkinId = BP_ARRAY_Halloween_Vehicle_Skin_Info1[3].skinId
                else
                    BP_Halloween_Vehicle_SelectSkinId = BP_ARRAY_Halloween_Vehicle_Skin_Info2[3].skinId
                end
            end
        end
    else
        for i,v in ipairs(BP_ARRAY_Halloween_Vehicle_Skin_Info2) do
            if v.status == 2 and v.costCandy <= LogicHalloweenVehicle.GetCandyCount() then
                table.insert(canUpgradeIdTb, v.skinId)
                break
            end
        end
        if #canUpgradeIdTb >= 1 then
            BP_Halloween_Vehicle_SelectSkinId = canUpgradeIdTb[math.random(#canUpgradeIdTb)]
            log_tree("canUpgradeIdTb", canUpgradeIdTb)
        else
            BP_Halloween_Vehicle_SelectSkinId = BP_ARRAY_Halloween_Vehicle_Skin_Info2[3].skinId
        end
    end
end

function HalloweenVehicleSkinUI.SetSkin_Info(Skin_Info1, Skin_Info2, isResetSelect)
	isResetSelect = isResetSelect or false
    BP_ARRAY_Halloween_Vehicle_Skin_Info1 = Skin_Info2
    BP_ARRAY_Halloween_Vehicle_Skin_Info2 = Skin_Info1

	for i,v in ipairs(BP_ARRAY_Halloween_Vehicle_Skin_Info1) do
		HalloweenVehicleSkinUI.SkinInfoMap[v.skinId] = v
	end

	for i,v in ipairs(BP_ARRAY_Halloween_Vehicle_Skin_Info2) do
		HalloweenVehicleSkinUI.SkinInfoMap[v.skinId] = v
	end

    if isResetSelect then
		HalloweenVehicleSkinUI.InitSelectSkinId()
	end
	
    LuaClassObj.HandleUIMessage(bp_halloween_vehicle_skin, "RefreshUI");
	--EventHalloweenOpenSkinClicked();
end

function HalloweenVehicleSkinUI.RefreshUI()
    HalloweenVehicleSkinUI.RefreshData();
    LuaClassObj.HandleUIMessage(bp_halloween_vehicle_skin, "RefreshUI");
end

function HalloweenVehicleSkinUI.HideUI()
	HalloweenVehicleSkinUI.isShow = false


    LuaClassObj.HandleUIMessage(bp_halloween_vehicle_skin, "UIHide");

	EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE);

	LuaClassObj.HandleUIMessage(bp_lobby, "UIShowFromMall");
		--显示玩家
	LuaClassObj.HandleUIMessage(bp_lobby, "ShowMallPlayer");

	LuaClassObj.HandleUIMessage(bp_lobby, "StartMallToLobby");

	MallSystemWeaponModelHandler:DestroyWeaponShowActor()

    EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_DATA_CHANGE, HalloweenVehicleSkinUI.UpdateCandyCount)

	LuaClassObj.HandleUIMessage(bp_halloween_vehicle_trick, "ShowRoot");
    --EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CHANGE, HalloweenVehicleSkinUI.RefreshUI) 
end

function EventFetchInfo()
end

--点击查看
function EventHalloweenSkinViewClicked()
	if BP_Halloween_Vehicle_SelectSkinId == 0  then
		log("SkinUpgradeClicked:no selected")
		return
	end
	BP_STRUCT_Halloween_Vehicle_Skin_CurrInfo = HalloweenVehicleSkinUI.SkinInfoMap[BP_Halloween_Vehicle_SelectSkinId]

	HalloweenVehicleSkinUI.ShowItem(BP_Halloween_Vehicle_SelectSkinId)

	LuaClassObj.HandleUIMessageNoFetch(bp_halloween_vehicle_skin, "RefreshUI");
end

--点击兑换或升级
function EventHalloweenSkinUpgradeClicked()
	if BP_Halloween_Vehicle_SelectSkinId == 0  then
		log("SkinUpgradeClicked:no selected")
		return
	end

	local Halloween_Vehicle_To_Skin_Info = HalloweenVehicleSkinUI.SkinInfoMap[BP_Halloween_Vehicle_SelectSkinId]
	local Halloween_Vehicle_From_Skin_Info = HalloweenVehicleSkinUI.SkinInfoMap[Halloween_Vehicle_To_Skin_Info.fromSkinId]

	if Halloween_Vehicle_To_Skin_Info ~= nil then
		log("BP_STRUCT_Halloween_Vehicle_Skin_Info,skinId：" .. Halloween_Vehicle_To_Skin_Info.skinId ..",status:" .. Halloween_Vehicle_To_Skin_Info.status
			.. ",costCandy：" .. Halloween_Vehicle_To_Skin_Info.costCandy)
	end

	if Halloween_Vehicle_To_Skin_Info == nil or Halloween_Vehicle_To_Skin_Info.status ~= 2 or Halloween_Vehicle_To_Skin_Info.skinId == 0 then
		log("SkinUpgradeClicked:Halloween_Vehicle_To_Skin_Info status error")

		if Halloween_Vehicle_To_Skin_Info ~= nil and Halloween_Vehicle_To_Skin_Info.status == 0 then
			ShowNotice(6144)
		end
		return
	end

	local itemCfg1 = Client.GetTableData("Item", Halloween_Vehicle_To_Skin_Info.skinId);
	if itemCfg1 == nil then
		log("SkinUpgradeClicked:no To Item id：" .. Halloween_Vehicle_To_Skin_Info.skinId)
		return
	end
	
	if Halloween_Vehicle_To_Skin_Info.costCandy > LogicHalloweenVehicle.GetCandyCount() then
		ShowNotice(6147)
		return 
	end

	local tip = nil
	if Halloween_Vehicle_From_Skin_Info ~= nil then
    	local itemCfg2 = Client.GetTableData("Item", Halloween_Vehicle_From_Skin_Info.skinId);
    	if itemCfg2 == nil then
    		log("SkinUpgradeClicked:no From Item id：" .. Halloween_Vehicle_To_Skin_Info.skinId)
			return
    	end
		
		tip  = GlobalData.GetLocalizeStringWithNum(6155,0, Halloween_Vehicle_To_Skin_Info.costCandy);
		
	else
		tip  = GlobalData.GetLocalizeStringWithNum(6156,0, Halloween_Vehicle_To_Skin_Info.costCandy);
		
	end

	local prompt = FuncUtil.GetLocalizeResStr("101001");
    CommonMessageBoxUI:ShowPanel(2, prompt, tip, HalloweenVehicleSkinUI.UpgradeItem);
end


function HalloweenVehicleSkinUI.UpgradeItem()
	log("HalloweenVehicleSkinUI.UpgradeItem: ".. tostring(BP_Halloween_Vehicle_SelectSkinId));
	local Halloween_Vehicle_To_Skin_Info = HalloweenVehicleSkinUI.SkinInfoMap[BP_Halloween_Vehicle_SelectSkinId]
 	LogicHalloweenVehicle.vst_level_up_req(Halloween_Vehicle_To_Skin_Info.lineId)
end


function HalloweenVehicleSkinUI.RefreshData()--更新活动的新数据，包括状态更新
	local Start_Time, End_Time = LogicHalloweenVehicle.GetActivityTime()

	local beginTime = os.date("!%Y/%m/%d", Start_Time)
    local endTime = os.date("!%Y/%m/%d", End_Time)

    BP_Halloween_Vehicle_DateTime = beginTime .. "-" .. endTime
end

function HalloweenVehicleSkinUI.ShowItem(itemid)
	log("HalloweenVehicleSkinUI.ShowItem(itemid)3 ".. tostring(itemid));
	local resItem = Client.GetTableData("Item", itemid);
	if resItem == nil then
		return 0;
	end	
	
	HalloweenVehicleSkinUI.showItemId = itemid;
	if resItem.ItemType == 9 then
		MallSystemWeaponModelHandler:Init();
		MallSystemWeaponModelHandler:ShowWeaponByResId(itemid, true, false, true, false, false, 12)
	else
		log("HalloweenVehicleSkinUI.ShowItem itemid:" .. itemid .. " not a vehicle!");
	end
end

function EventHalloweenVehicleSkin_HideUI()
	HalloweenVehicleSkinUI.HideUI()
end
