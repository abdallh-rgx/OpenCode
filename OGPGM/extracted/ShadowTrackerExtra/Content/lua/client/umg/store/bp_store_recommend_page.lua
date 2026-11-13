StoreRecommendPage = StoreRecommendPage or {
	ItemMap = {},			-- 推荐页物品表 ID to BP_STRUCT_Store_Item_Data
	ItemMapToSvrData = {},
	SvrData = {},
	TabId = 0,
	SubId = 0,
	isShow = false,
	UpdateTimer = nil,

	h5URL = "H5Demo",
	h5IsReady = false,
}

-- Item的标志
BP_STRUCT_Store_Item_Data = {
	Id = 0,					-- 物品ID

	ShopId = 0,				-- 商城ID
	Name = "",				-- 物品名称
	Desc = "",				-- 物品描述
	Quality = 0,			-- 物品品质

	bNew = false,			-- New标志
	bHot = false,			-- Hot标志
	EndTime = 0,			-- 用于Lua计算 蓝图不使用
	FestivalIconUrl = "",	-- 节日标志Url
	Discount_f = 0.0,		-- 折扣
	bRateUp = false,		-- 是否概率上升
	RateUpEndTime = 0,		-- 概率上升结束时间
	RateUpRate_f = 0.0,		-- 概率上升量
	isEnableCoupon = false,	-- 是否可使用折扣券
	bEquip = false,			-- 是否已穿上
	IsWeapon = false,		-- 是否是武器

	ItemCount = 0,			-- 物品数量
	DefaultPrice = 0,		-- 默认使用的货币
	PriceList = {},			-- 价格列表（用于逻辑处理 蓝图不使用）
	bCanBeGift = false,		-- 能否赠送
	ExpressionId = 0,		-- 红装表情
	DayLimit = 0,			-- 日限购
	WeekLimit = 0,			-- 周限购
	PermanentLimit = 0,		-- 永久限购
	JumpInfo = "",			-- 跳转信息
	IsPossessed = false,	-- 是否已拥有
	FestivalImage = "",     -- 物品详细特殊底图
	item_collected = false,
	item_collected_num = 0,

	IsInNew = true,			-- 是否放到新品栏中
    needShowEndTime = false,	--是否需要显示下架时间
	needShowEndTimeIcon = false,	--是否需要显示下架时间ICON
	needShowSpecialIcon = false,	--是否特殊ICON

	limitBuyType = 0,       --限购类型
	limitBuyNum = 0,        --限购数量
	hasBuyNum = 0,          --已购数量
	bVip = false,			--vip标志
}
-- 推荐页物品
BP_ARRAY_Recommend_Items = {
	BP_STRUCT_Store_Item_Data = _G.BP_STRUCT_Store_Item_Data,
}
-- 用于同步物品详细信息
BP_ARRAY_To_Set_UIInfo_ItemInfo = {
	BP_STRUCT_Store_Item_Data = _G.BP_STRUCT_Store_Item_Data,
}

-- Banner数据
BP_STRUCT_Banner_Data = {
	ImgUrl = "",		-- Banner图片Url
	JumpInfo = "",		-- 跳转物品ID
}
BP_ARRAY_Banners_Data = {
	BP_STRUCT_Banner_Data = _G.BP_STRUCT_Banner_Data
}

BP_STRUCT_Purchase_Btn_Info = {
	Price1Type = 0,				-- 货币1类型 0：BP 1:SF 2:UC
	Price1 = 0,					-- 货币1价格
	DiscountPrice1 = 0,			-- 货币1打折前价格
	Price2Type = 0,				-- 货币2类型
	Price2 = 0,					-- 货币2价格
	DiscountPrice2 = 0,			-- 货币2打折前价格
	JumpInfo = "",				-- 跳转信息
	IsPossessed = false,		-- 是否已拥有
	IsSoldOut = false,			-- 是否已售罄
	priceNumMax = 0,			--价格数量上限
}

BP_Struct_To_Update_Item_Time_Info = {
	Id = 0,
	Time = "",
}
-- 用于更新物品限时购买信息
BP_ARRAY_To_Update_Item_Time_Info = {
	BP_Struct_To_Update_Item_Time_Info = _G.BP_Struct_To_Update_Item_Time_Info
}

BP_To_Equip_Id           = 0        -- 需要穿上的物品ID
BP_To_TakeOff_Id         = 0        -- 需要脱下的物品ID
BP_Selected_Id           = 0        -- 选中的物品ID
BP_To_Set_UIInfo_Item_Id = 0   		-- 需要获取详细信息的物品ID
BP_Is_Male               = false    -- 性别标签
BP_Clicked_Banner_Idx    = 0        -- 点击的Banner下标
BP_Emotion_Id            = 0        -- 表情ID
BP_Is_Weapon_Model		 = false	-- 是否显示枪械模型
BP_Store_Recomm_Is_Show_Weapon = false 	--是否显示武器按钮
BP_Store_Recommend_H5_Btn_ShowType = 0	--显示h5商城入口类型
BP_Store_Recommend_H5_URL = ""		--h5跳转商城地址




--注册Widget
function bp_store_recommend_page_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_store_recommend_page,
								{ { Path = "/Game/UMG/UI_Logic/Store/Recommend/Store_Recommend_Page_01_BP.Store_Recommend_Page_01_BP_C",Container = "Default",ZOrder = BP_ENUM_UI_SHOP_ZORDER } },
								{ "Lobby" },
								false,
								false,
								true
	);
end

function StoreRecommendPage.Show()
	log("[HHF]StoreRecommendPage.Show");
	if UIManager.GetUI(eUIType.eStoreRecommendPage) then
		log("[HHF]StoreRecommendPage.Show, Is showing?")
		return
	end

	StoreRecommendPage.h5IsReady = Client.GetH5CacheStatus(StoreRecommendPage.h5URL);
	log("[HHF]StoreRecommendPage.Show, h5IsReady = " .. tostring(StoreRecommendPage.h5IsReady));
	if StoreRecommendPage.h5IsReady == true then
		Client.OpenH5FromCache(GameFrontendHUD, StoreRecommendPage.h5URL, 60, 170);
		UIManager.Show(eUIType.eStoreRecommendPage);
		StoreRecommendPage.isShow = true;
	else
		Client.CacheH5WebView(StoreRecommendPage.h5URL);
		EventSystem:registEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_DATA, StoreRecommendPage.SetData)
		EventSystem:registEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_BUY, StoreRecommendPage.OnPurchase)
		EventSystem:registEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_COLLECT, StoreRecommendPage.OnCollectedResult);
		EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_DATA_CHANGE, StoreRecommendPage.OnItemChange);
		EventSystem:registEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_BUY_INFO_CHANGE, StoreRecommendPage.OnBuyInfoChange);

		LobbyCameraManager.SwitchCamera(LobbyCameraManager.store_recommend)
		LuaClassObj.HandleDynamicCreation(bp_store_recommend_page)
		LuaClassObj.HandleUIMessageNoFetch(bp_store_recommend_page, "UIShow")
		UIManager.Show(eUIType.eStoreRecommendPage)

		StoreSystem.GetTabData(StoreSystem.store_tab, StoreSystem.Page_ID_Recommend)
		StoreRecommendPage.isShow = true
		--StoreRecommendPage.SetData()
	end

	if UIManager.GetUI(eUIType.eTheFirstCharge) then
		UIManager.Show(eUIType.eTheFirstCharge);
	end
end

function StoreRecommendPage.Hide()
	log("[HHF]StoreRecommendPage.Hide");
	if UIManager.GetUI(eUIType.eStoreRecommendPage) == nil then
		log("[HHF]StoreRecommendPage.Hide, not showing?");
		return
	end

	if StoreRecommendPage.h5IsReady == true then
		Client.CloseH5WebView(GameFrontendHUD);
		UIManager.Hide(eUIType.eStoreRecommendPage);
		StoreRecommendPage.isShow = false;
	else
		if StoreRecommendPage.UpdateTimer then
			Timer.RemoveTimer(StoreRecommendPage.UpdateTimer)
			StoreRecommendPage.UpdateTimer = nil
		end

		EventSystem:unregistEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_DATA, StoreRecommendPage.SetData)
		EventSystem:unregistEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_BUY, StoreRecommendPage.OnPurchase)
		EventSystem:unregistEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_COLLECT, StoreRecommendPage.OnCollectedResult);
		EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_DATA_CHANGE, StoreRecommendPage.OnItemChange);
		EventSystem:unregistEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_BUY_INFO_CHANGE, StoreRecommendPage.OnBuyInfoChange);

		UIManager.Hide(eUIType.eStoreRecommendPage)
		LuaClassObj.HandleUIMessageNoFetch(bp_store_recommend_page, "UIHide")

		StoreRecommendPage.isShow = false
	end
end

function StoreRecommendPage.UIOnlyShow()
	EventSystem:registEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_DATA, StoreRecommendPage.SetData)
	EventSystem:registEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_BUY, StoreRecommendPage.OnPurchase)
	EventSystem:registEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_COLLECT, StoreRecommendPage.OnCollectedResult);
	EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_DATA_CHANGE, StoreRecommendPage.OnItemChange);
	LobbyCameraManager.SwitchCamera(LobbyCameraManager.store_recommend)
	LuaClassObj.HandleUIMessageNoFetch(bp_store_recommend_page, "UIOnlyShow");

	if StoreJumpToChestUI.IsNeedShow(BP_Selected_Id) then
		LuaClassObj.HandleUIMessageNoFetch(bp_store_recommend_page, "HideH5Btn");
	else
		LuaClassObj.HandleUIMessageNoFetch(bp_store_recommend_page, "UpdateH5Btn");
	end
end

function StoreRecommendPage.UIOnlyHide()
	EventSystem:unregistEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_DATA, StoreRecommendPage.SetData)
	EventSystem:unregistEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_BUY, StoreRecommendPage.OnPurchase)
	EventSystem:unregistEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_COLLECT, StoreRecommendPage.OnCollectedResult);
	EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_DATA_CHANGE, StoreRecommendPage.OnItemChange);
	LuaClassObj.HandleUIMessageNoFetch(bp_store_recommend_page, "UIOnlyHide");
	StoreJumpToChestUI.Hide();
end

--设置UI数据
function StoreRecommendPage.SetData(eventType, eventID, data)
	if data.tab_id ~= StoreSystem.Page_ID_Recommend then
		return
	end
	log("StoreRecommendPage.SetData")

	StoreRecommendPage.TabId = data.tab_id or 0
	StoreRecommendPage.SubId = data.sub_id or 0

	StoreRecommendPage.FirstSelectItemId = nil
	StoreRecommendPage.ItemMap = {}
	BP_ARRAY_Recommend_Items = {}
	BP_ARRAY_Banners_Data = {}

	StoreRecommendPage.ParseSvrData(data);
	BP_Store_Recommend_H5_Btn_ShowType = StoreIndiaUtils.h5ShowType
	
	--初始化男女性别
	BP_Is_Male = StoreMainUI.AvatarIsMale()
	StoreRecommendPage.InitUI()
end

function StoreRecommendPage.OnPurchase()
	EventSetUIInfoByItemId()
end

function StoreRecommendPage.OnBuyInfoChange()
	log("[HHF]StoreRecommendPage.OnBuyInfoChange");
	EventSetUIInfoByItemId();
	--[[
	local ItemInfo = BP_ARRAY_To_Set_UIInfo_ItemInfo[1];
	if ItemInfo ~= nil then
		local buyInfo = StoreFuncUtils.GetBuyInfo(ItemInfo.ShopId);
		if StoreSystem.label_buy_limit_type_daily == ItemInfo.limitBuyType then --每日限购
			ItemInfo.hasBuyNum = buyInfo and buyInfo.daily_buy_cnt or 0;
		elseif StoreSystem.label_buy_limit_type_week == ItemInfo.limitBuyType then --每周限购
			ItemInfo.hasBuyNum = buyInfo and buyInfo.week_buy_cnt or 0;
		elseif StoreSystem.label_buy_limit_type_permanent == ItemInfo.limitBuyType then --永久限购
			ItemInfo.hasBuyNum = buyInfo and buyInfo.permanet_buy_cnt or 0;
		end

		if BP_STRUCT_Purchase_Btn_Info ~= nil then
			BP_STRUCT_Purchase_Btn_Info.IsSoldOut = StoreFuncUtils.IsSoldOut(ItemInfo.ShopId, ItemInfo.DayLimit, ItemInfo.WeekLimit, ItemInfo.PermanentLimit);
		end

		LuaClassObj.HandleUIMessageNoFetch(bp_store_recommend_page, "UpdateUIInfo");
	end
	--]]
end

function StoreRecommendPage.OnCollectedResult()
	local item_id = BP_To_Set_UIInfo_Item_Id;
	local result = StoreSystem.IsCollectedByItemID(item_id);
	log("[HHF]StoreRecommendPage.OnCollectedResult, result = " .. tostring(result));
	if result == true then
		if StoreSystem.global_collection_num[item_id] == nil then
			StoreSystem.global_collection_num[item_id] = 1;
		else
			StoreSystem.global_collection_num[item_id] = StoreSystem.global_collection_num[item_id] + 1;
		end
	else
		StoreSystem.global_collection_num[item_id] = StoreSystem.global_collection_num[item_id] - 1;
	end

	EventSetUIInfoByItemId();
end

function StoreRecommendPage.OnItemChange()
	EventSetUIInfoByItemId()
end

--解析服务器数据
function StoreRecommendPage.ParseSvrData(SvrData)
	StoreRecommendPage.SvrData = SvrData
	local data = SvrData.data[StoreSystem.label_market_index_banner_list]
	for _, v in pairs(data) do
		if v[StoreSystem.label_item_index_type] == 1 then--1为Banner
			local BannerData = {}
			BannerData.ImgUrl = v[StoreSystem.label_item_index_img_path]
			BannerData.JumpInfo = tostring(v[StoreSystem.label_item_index_skip_path])
			table.insert(BP_ARRAY_Banners_Data, BannerData)
		else
			local ItemData = FuncUtil:CopyTable(BP_STRUCT_Store_Item_Data)

			ItemData.Id = v[StoreSystem.label_item_index_id]
			ItemData.ShopId = v[StoreSystem.label_item_index_market_id]

			local cfg = Client.GetTableData("Item", v[StoreSystem.label_item_index_id])
			ItemData.Name = cfg.ItemName
			ItemData.Desc = cfg.ItemDesc
			ItemData.Quality = cfg.ItemQuality
			ItemData.FestivalImage = cfg.StoreDetailImage;
			ItemData.FestivalIconUrl = cfg.SpecialIcon;
			if cfg.ItemType == 1 then
				ItemData.IsWeapon = true
			else
				ItemData.IsWeapon = false
			end

			--if v[StoreSystem.label_item_index_hot_or_new] == 1 then
			--	ItemData.bHot = true
			--elseif v[StoreSystem.label_item_index_hot_or_new] == 2 then
			--	ItemData.bNew = true
			--end
			--
			--ItemData.EndTime = v[StoreSystem.label_item_index_time_limit] or 0
            --if v[StoreSystem.label_item_index_show_time_limit] ~= nil and v[StoreSystem.label_item_index_show_time_limit] == 1 then
            --    ItemData.needShowEndTime = true;
            --else
            --    ItemData.needShowEndTime = false;
            --end

			ItemData.needShowEndTime = StoreFuncUtils.CheckNeedShowSaleEndTime(v);
			ItemData.needShowEndTimeIcon = v[StoreSystem.label_item_index_show_time_limit] == 1;

			if ItemData.needShowEndTimeIcon == true then
				ItemData.EndTime = v[StoreSystem.label_item_index_time_limit] or 0;
			else
				ItemData.EndTime = 0
			end

			if v[StoreSystem.label_item_index_position] == 1 then
				ItemData.IsInNew = false
			elseif v[StoreSystem.label_item_index_position] == 2 then
				ItemData.IsInNew = true
			end

			if v[StoreSystem.label_item_index_special_mark] and v[StoreSystem.label_item_index_special_mark] == 1 then
				ItemData.FestivalIconUrl = ""
			end

			ItemData.Discount_f = v[StoreSystem.label_item_index_discount] or 0.0

			local showDiscount, showHot, showVip = StoreFuncUtils.GetItemLeftTopTagsQueue(ItemData.Discount_f ~= 0,
					StoreFuncUtils.CheckIsHot(v) == true,
					v[StoreSystem.label_item_index_vip] == 1);
			ItemData.bHot = showHot;
			ItemData.bVip = showVip;
			if showDiscount == false then
				ItemData.Discount_f = 0;
			end

			local showNew, showSpecialIcon = StoreFuncUtils.GetItemRightTopTagsQueue(
					StoreFuncUtils.CheckIsNew(v) == true,
					cfg.SpecialIcon ~= "");
			ItemData.bNew = showNew;
			ItemData.needShowSpecialIcon = showSpecialIcon;

			if v[StoreSystem.label_item_index_up_time] and v[StoreSystem.label_item_index_up_time] > 0 then
				ItemData.bRateUp = true
				ItemData.RateUpEndTime = tostring(v[StoreSystem.label_item_index_up_time])
				ItemData.RateUpRate_f = v[StoreSystem.label_item_index_up_value]
			end

			ItemData.isEnableCoupon = false
			ItemData.bEquip = MultipleAvatar.HasEquiped(v[StoreSystem.label_item_index_id])
			ItemData.ItemCount = v[StoreSystem.label_item_index_count] or 0
			ItemData.DefaultPrice = v[StoreSystem.label_item_index_price_default]

			local SvrPriceList = v[StoreSystem.label_item_index_price_list]
			local PriceList = {}
			for _, PriceInfo in pairs(SvrPriceList) do
				if StoreFuncUtils.IsValidPrice(v[StoreSystem.label_item_index_vip], PriceInfo[StoreSystem.label_price_index_price_type]) then
					local PriceDetail = {}
					PriceDetail.Price = PriceInfo[StoreSystem.label_price_index_one_original_price]
					PriceDetail.DiscountPrice = PriceInfo[StoreSystem.label_price_index_one_discount_price]
					PriceDetail.ValidHour = PriceInfo[StoreSystem.label_price_index_valid_hours]
					if not PriceList[PriceInfo[StoreSystem.label_price_index_price_type]] then
						PriceList[PriceInfo[StoreSystem.label_price_index_price_type]] = {};
					end
					table.insert(PriceList[PriceInfo[StoreSystem.label_price_index_price_type]], PriceDetail)
				end
			end
			ItemData.PriceList = PriceList

			if v[StoreSystem.label_item_index_can_gift] and v[StoreSystem.label_item_index_can_gift]==1 then
				ItemData.bCanBeGift = true
			else
				ItemData.bCanBeGift = false
			end

			ItemData.ExpressionId = v[StoreSystem.label_item_index_expression_id] or 0

			local LimitInfo = v[StoreSystem.label_item_index_buy_limit]
			if LimitInfo then
				ItemData.DayLimit = LimitInfo[StoreSystem.label_buy_limit_type_daily]
				ItemData.WeekLimit = LimitInfo[StoreSystem.label_buy_limit_type_week]
				ItemData.PermanentLimit = LimitInfo[StoreSystem.label_buy_limit_type_permanent]
			end

			-- 若跳转地址不为空则是URL 若跳转地址为空串则是物品ID
			if v[StoreSystem.label_item_index_skip_path] and v[StoreSystem.label_item_index_skip_path] ~= "" then
				ItemData.JumpInfo = tostring(v[StoreSystem.label_item_index_skip_path])
			else
				ItemData.JumpInfo = tostring(v[StoreSystem.label_item_index_id])
			end
			--不显示已拥有标签
			ItemData.IsPossessed = false--StoreFuncUtils.IsPossessed(v[StoreSystem.label_item_index_id])

			ItemData.item_collected = StoreSystem.IsCollectedByItemID(ItemData.Id);
			ItemData.item_collected_num = StoreSystem.global_collection_num[ItemData.Id] or 0;

			local limitData = v[StoreSystem.label_item_index_buy_limit]
			if limitData then
				for limitType, limitCnt in pairs(limitData) do
					ItemData.limitBuyType = limitType;
					ItemData.limitBuyNum = limitCnt;
					local buyInfo = StoreFuncUtils.GetBuyInfo(ItemData.ShopId);
					if StoreSystem.label_buy_limit_type_daily == limitType then --每日限购
						ItemData.hasBuyNum = buyInfo and buyInfo.daily_buy_cnt or 0;
					elseif StoreSystem.label_buy_limit_type_week == limitType then --每周限购
						ItemData.hasBuyNum = buyInfo and buyInfo.week_buy_cnt or 0;
					elseif StoreSystem.label_buy_limit_type_permanent == limitType then --永久限购
						ItemData.hasBuyNum = buyInfo and buyInfo.permanet_buy_cnt or 0;
					end
					break;
				end
			end

			table.insert(BP_ARRAY_Recommend_Items, ItemData)
			StoreRecommendPage.ItemMap[v[StoreSystem.label_item_index_id]] = ItemData
			StoreRecommendPage.ItemMapToSvrData[v[StoreSystem.label_item_index_id]] = v
		end
	end
end

--初始化UI
function StoreRecommendPage.InitUI()
	BP_Is_Weapon_Model = false
	StoreRecommendPage.UpdateModelSwitch()

	LuaClassObj.HandleUIMessageNoFetch(bp_store_recommend_page, "InitUI")
	LuaClassObj.HandleUIMessageNoFetch(bp_store_recommend_page, "InitSelectedItem")

	if StoreRecommendPage.UpdateTimer then
		Timer.RemoveTimer(StoreRecommendPage.UpdateTimer)
		StoreRecommendPage.UpdateTimer = nil
	else
		StoreRecommendPage.InitLeftTime()
		StoreRecommendPage.UpdateTimer = Timer.InsertTimer(1, StoreRecommendPage.UpdateLeftTime, true)
	end
end

function StoreRecommendPage.InitLeftTime()
	local CurTime = FuncUtil.GetServerTimeInSec()
	BP_ARRAY_To_Update_Item_Time_Info = {}
	for i, v in pairs(StoreRecommendPage.ItemMap) do
		local LeftTime = v.EndTime - CurTime
		if 0 < LeftTime and v.needShowEndTime then
			local TimeStr  = StoreRecommendPage.GetDayStringBySec(LeftTime)
			local TimeInfo = { Id = v.Id,Time = TimeStr }
			table.insert(BP_ARRAY_To_Update_Item_Time_Info, TimeInfo)
		end
	end
	if #BP_ARRAY_To_Update_Item_Time_Info > 0 then
		LuaClassObj.HandleUIMessageNoFetch(bp_store_recommend_page, "UpdateLeftTime")
	end
end

function StoreRecommendPage.UpdateLeftTime()
	local CurTime = FuncUtil.GetServerTimeInSec()
	BP_ARRAY_To_Update_Item_Time_Info = {}
	for i, v in pairs(StoreRecommendPage.ItemMap) do
		local LeftTime = v.EndTime - CurTime
		if 0 < LeftTime and v.needShowEndTime then
			local TimeStr  = StoreRecommendPage.GetDayStringBySec(LeftTime)
			local TimeInfo = { Id = v.Id,Time = TimeStr }
			table.insert(BP_ARRAY_To_Update_Item_Time_Info, TimeInfo)
		end
	end

	if #BP_ARRAY_To_Update_Item_Time_Info > 0 then
		LuaClassObj.HandleUIMessageNoFetch(bp_store_recommend_page, "UpdateLeftTime")
	end
end

--选中物品
function EventOnSelectedItem()
	StoreMainUI.OnSelectedItem(BP_Selected_Id)
	StoreRecommendPage.UpdateTags();
	local bWeapon = StoreFuncUtils.IsWeapon(BP_Selected_Id)-- and MultipleAvatar.HasEquiped(BP_Selected_Id)
	if bWeapon then
		--none
	else
		BP_Is_Weapon_Model = false
	end
	
	
	if StoreFuncUtils.IsWeapon(BP_Selected_Id) and (MultipleAvatar.HasEquiped(BP_Selected_Id) or BP_Is_Weapon_Model) then
		BP_Store_Recomm_Is_Show_Weapon = true
	else
		BP_Store_Recomm_Is_Show_Weapon = false
	end
	LuaClassObj.HandleUIMessageNoFetch(bp_store_recommend_page, "SetModelSwitchBtn")

	StoreRecommendPage.ParseSvrData(StoreRecommendPage.SvrData)
	
	LuaClassObj.HandleUIMessageNoFetch(bp_store_recommend_page, "UpdateItems")
	BP_Is_Male = StoreMainUI.AvatarIsMale()
	LuaClassObj.HandleUIMessageNoFetch(bp_store_recommend_page, "UpdateSex")

	if StoreJumpToChestUI.IsNeedShow(BP_Selected_Id) then
		LuaClassObj.HandleUIMessageNoFetch(bp_store_recommend_page, "HideH5Btn");
	else
		LuaClassObj.HandleUIMessageNoFetch(bp_store_recommend_page, "UpdateH5Btn");
	end
end


function StoreRecommendPage.UpdateTags()
	for _, v in ipairs(BP_ARRAY_Recommend_Items) do
		if v.Id == BP_Selected_Id and v.bNew == true then
			local cfg = Client.GetTableData("Item", BP_Selected_Id)
			if cfg ~= nil then
				StoreSystem.CheckRecordNewTag(v.ShopId);

				local showNew, showSpecialIcon = StoreFuncUtils.GetItemRightTopTagsQueue(
						false,
						cfg.SpecialIcon ~= "");
				v.bNew = showNew;
				v.needShowSpecialIcon = showSpecialIcon;
			end
		end
	end
end

--切换性别
function EventOnSwitchSex()
	StoreMainUI.SwitchSex()
	BP_Is_Male = StoreMainUI.AvatarIsMale()
	LuaClassObj.HandleUIMessageNoFetch(bp_store_recommend_page, "UpdateSex")
end

--初始化物品选中
function EventInitSelectedItem()
	if not MultipleAvatar.HasEquiped(BP_Selected_Id) then
		EventOnSelectedItem()
	end
	BP_Is_Male = StoreMainUI.AvatarIsMale()
	LuaClassObj.HandleUIMessageNoFetch(bp_store_recommend_page, "UpdateSex")
end

--播放红装表情
function EventOnPlayAvatarAnim()
	local Item = StoreRecommendPage.ItemMap[BP_Selected_Id]

	if Item and Item.ExpressionId and Item.ExpressionId > 0 then
		StoreMainUI.PlayAvatarEmotion(Item.ExpressionId)
		StoreMainUI.ResetEmotionTimer()
	end
end

function EventGetEmotionID()
	local Item = StoreRecommendPage.ItemMap[BP_Selected_Id]

	BP_Emotion_Id = Item.ExpressionId
end

--根据物品设置UI信息（详细信息、购买按钮、性别按钮）
function EventSetUIInfoByItemId()
	local ItemInfo = StoreRecommendPage.ItemMap[BP_To_Set_UIInfo_Item_Id]
	if ItemInfo == nil then
		return;
	end

	ItemInfo.item_collected = StoreSystem.IsCollectedByItemID(BP_To_Set_UIInfo_Item_Id);
	ItemInfo.item_collected_num = StoreSystem.global_collection_num[BP_To_Set_UIInfo_Item_Id] or 0;

	local buyInfo = StoreFuncUtils.GetBuyInfo(ItemInfo.ShopId);
	if StoreSystem.label_buy_limit_type_daily == ItemInfo.limitBuyType then --每日限购
		ItemInfo.hasBuyNum = buyInfo and buyInfo.daily_buy_cnt or 0;
	elseif StoreSystem.label_buy_limit_type_week == ItemInfo.limitBuyType then --每周限购
		ItemInfo.hasBuyNum = buyInfo and buyInfo.week_buy_cnt or 0;
	elseif StoreSystem.label_buy_limit_type_permanent == ItemInfo.limitBuyType then --永久限购
		ItemInfo.hasBuyNum = buyInfo and buyInfo.permanet_buy_cnt or 0;
	end

	BP_ARRAY_To_Set_UIInfo_ItemInfo = { ItemInfo }

	local BtnInfo = {
		Price1Type = 0,				-- 货币1类型 0：BP 1:SF 2:UC
		Price1 = 0,					-- 货币1价格
		Price2Type = 0,				-- 货币2类型
		Price2 = 0,					-- 货币2价格
		JumpInfo = "",				-- 跳转物品ID
		IsPossessed = false,		-- 是否已拥有
		IsSoldOut = false,			-- 是否已售罄
		priceNumMax = 0,			--价格数量上限
	}
	local PriceList = ItemInfo.PriceList
	local PriceInfo = {}
	for i, v in pairs(PriceList) do
		local Info = {}
		Info.Type = i
		Info.Price = v[1].Price
		Info.DiscountPrice = v[1].DiscountPrice

		table.insert(PriceInfo, Info)
	end
	if PriceInfo[1] then
		BtnInfo.Price1Type = PriceInfo[1].Type
		if PriceInfo[1].DiscountPrice and PriceInfo[1].DiscountPrice > 0 then
			BtnInfo.DiscountPrice1 = PriceInfo[1].DiscountPrice
		else
			BtnInfo.DiscountPrice1 = 0
		end
		BtnInfo.Price1 = PriceInfo[1].Price
	else
		BtnInfo.Price1Type     = 0
		BtnInfo.Price1         = 0
		BtnInfo.DiscountPrice1 = 0
	end
	if PriceInfo[2] then
		BtnInfo.Price2Type = PriceInfo[2].Type
		if PriceInfo[1].DiscountPrice and PriceInfo[2].DiscountPrice > 0 then
			BtnInfo.DiscountPrice2 = PriceInfo[2].DiscountPrice
		else
			BtnInfo.DiscountPrice2 = 0
		end
		BtnInfo.Price2 = PriceInfo[2].Price
	else
		BtnInfo.Price2Type     = 0
		BtnInfo.Price2         = 0
		BtnInfo.DiscountPrice2 = 0
	end
	BtnInfo.priceNumMax = StoreFuncUtils.GetFirstPriceNumMax2(PriceList)
	BtnInfo.JumpInfo  = ItemInfo.JumpInfo
	if string.find(BtnInfo.JumpInfo, "module=10003") then
		BtnInfo.JumpInfo = BtnInfo.JumpInfo.."&itemId="..ItemInfo.Id
	end
	BtnInfo.IsPossessed = StoreFuncUtils.IsPossessed(ItemInfo.Id)
	BtnInfo.IsSoldOut   = StoreFuncUtils.IsSoldOut(ItemInfo.ShopId, ItemInfo.DayLimit, ItemInfo.WeekLimit, ItemInfo.PermanentLimit)

	BP_STRUCT_Purchase_Btn_Info = BtnInfo

	LuaClassObj.HandleUIMessageNoFetch(bp_store_recommend_page, "UpdateUIInfo")
end

function StoreRecommendPage.GetDayStringBySec(LeftTime)
	local day = 0;--math.floor(LeftTime / FuncUtil.dayToSec)
	if day > 0 then
		local Str = GlobalData.GetLocalizeStringWithNum(501060, 0, day)
		return Str
	end

	local hour = math.floor(LeftTime / FuncUtil.hourToSec) - day * 24;
	local min = math.floor(LeftTime / FuncUtil.minToSec) - day * 24 * 60 - hour * 60
	local sec = LeftTime % 60
	local Str = string.format("%02d:%02d:%02d", hour, min, sec)
	return Str
end

--Banner跳转
function EventOnClickBanner()
	GemReportUtils.ReportBtnClickEvent(GemReportUtils.SubEventName_StoreClickBanner)
	local Banner = BP_ARRAY_Banners_Data[BP_Clicked_Banner_Idx + 1]
	local JumpInfo = Banner.JumpInfo
	log("OnClickedBanner: Idx: " .. BP_Clicked_Banner_Idx .. " JumpInfo: " .. tostring(JumpInfo))
	StoreFuncUtils.JumpAll(JumpInfo)
end

function EventOnClickPurchase()
	local ShopInfo = StoreFuncUtils.ConvertToShopInfo(StoreRecommendPage.ItemMapToSvrData[BP_Selected_Id], StoreRecommendPage.TabId, StoreRecommendPage.SubId)
	StoreFuncUtils.PurchaseItem(ShopInfo)
end

function EventOnClickSend()
	local ShopInfo = StoreFuncUtils.ConvertToShopInfo(StoreRecommendPage.ItemMapToSvrData[BP_Selected_Id], StoreRecommendPage.TabId, StoreRecommendPage.SubId)
	StoreFuncUtils.SendGift(ShopInfo)
end

function EventOnClickModelSwitchBtn()
	BP_Is_Weapon_Model = not BP_Is_Weapon_Model
	StoreRecommendPage.UpdateModelSwitch()
end

--点击印度商城入口按钮
function Event_StoreRecommend_ClickH5()
	log("Event_StoreRecommend_ClickH5 "..StoreIndiaUtils.h5ShowType)
	if StoreIndiaUtils.h5ShowType == StoreIndiaUtils.H5_Show_Type_None then
		return
	elseif StoreIndiaUtils.h5ShowType == StoreIndiaUtils.H5_Show_Type_Bind then
		--提示绑定
		StoreBindPhoneUI.Init()
	elseif StoreIndiaUtils.h5ShowType == StoreIndiaUtils.H5_Show_Type_India then
		--跳转h5商城
		local url = StoreIndiaUtils.h5StoreUrl
		BP_Store_Recommend_H5_URL = string.format(url, DataMgr.roleData.openID)
		LuaClassObj.HandleUIMessageNoFetch(bp_store_recommend_page, "OpenH5Url")
	end
end

function StoreRecommendPage.UpdateModelSwitch()
	if BP_Is_Weapon_Model then
		ModelDisplayer.SetShowtype(ModelDisplayer.SHOWTYPE_WEAPON_MODEL)
	else
		ModelDisplayer.SetShowtype(ModelDisplayer.SHOWTYPE_AVATAR)
	end
	LuaClassObj.HandleUIMessageNoFetch(bp_store_recommend_page, "SetModelSwitchBtn")
end

function EventOnClickCollectRecommend()
	log("[HHF]EventOnClickCollectRecommend");
	if UIUtil.CanClickNow(ClickFrequencyLimit.StoreCollectionBtn) == false then
		return;
	end

	if BP_ARRAY_To_Set_UIInfo_ItemInfo[1] ~= nil then
		if BP_ARRAY_To_Set_UIInfo_ItemInfo[1].item_collected then
			StoreSystem.cancel_market_collect_by_item_req(BP_ARRAY_To_Set_UIInfo_ItemInfo[1].Id);
		else
			StoreSystem.add_market_collect_by_item_req(BP_ARRAY_To_Set_UIInfo_ItemInfo[1].Id, StoreSystem.market_collect_source_market);
		end
	else
		log_tree("[HHF]EventOnClickCollectRecommend, BP_ARRAY_To_Set_UIInfo_ItemInfo = ", BP_ARRAY_To_Set_UIInfo_ItemInfo, "[HHF]");
	end
end
