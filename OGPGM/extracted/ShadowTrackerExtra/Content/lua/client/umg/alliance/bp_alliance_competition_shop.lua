--[[
	战队赛房间UI
--]]

AllianceCompetitionShopUI = AllianceCompetitionShopUI or 
{
	isShow = false;
}

-- 单个兑换信息
BP_STRUCT_AllianceCompetition_ShopItemInfo =
{
    exchangeId = 0,
    itemId = 0,
    costScore = 0,
    curCount = 0,
    maxCount = 0,
    sort = 0,
}

-- 兑换列表
BP_ARRAY_AllianceCompetition_ShopItemInfoList = 
{
    BP_STRUCT_AllianceCompetition_ShopItemInfo = _G.BP_STRUCT_AllianceCompetition_ShopItemInfo,
}

BP_AllianceCompetitionShop_Test = 0
-- 点选的道具ID
BP_AllianceCompetitionShopPreSelectItemId = 0
-- 显示道具类型
BP_AllianceCompetition_Show_Item_type = ""
-- 详细道具信息
BP_AllianceCompetition_Show_Detail_ResId = 0
-- 操作的道具ID
BP_AllianceCompetition_operateShopId = 0

-- 持有金币
BP_AllianceCompetition_coin = 0;
-- 赛季文字
BP_AllianceCompetition_seasonText = "";
-- 左下角商品名
BP_AllianceCompetition_GoodsSelectedName = "";
-- 展示3D模型
BP_AllianceCompetition_ShowAvatar = true;

local _avatar = nil

--注册Widget
function bp_alliance_competition_shop_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_alliance_competition_shop,
	{
	    {Path="/Game/UMG/UI_Logic/Lobby_Team/LobbyTeam_Competition_Shop_LogicBP.LobbyTeam_Competition_Shop_LogicBP_C", Container="Default", ZOrder=BP_ENUM_UI_ALLIANCE_ZORDER + 2}
	},
	{"Lobby"},
	false,
	false,
	true
	)
end

function AllianceCompetitionShopUI.InitData()
	local endTime = LeagueGameSystem.LeagueEndTime;
	local tb = {}
    tb.year = tostring(os.date("%Y",endTime))
    tb.month =tostring(os.date("%m",endTime))
    tb.day = tostring(os.date("%d",endTime))
    -- local endTimeStr = tb.year.."/"..tb.month.."/"..tb.day;
    -- local endTimeStr = tb.day.."/"..tb.month.."/"..tb.year;
    local dateFormat = Client.GetTableData("LocalizeRes", "110070").TextValue
    local endTimeStr = os.date(dateFormat, endTime)

	BP_AllianceCompetition_coin = DataMgr.carteam_coin_count;
	local strMsg = Client.GetTableData("LocalizeRes",6189).TextValue;
	strMsg = string.gsub(strMsg, "{0}", tostring(LeagueGameSystem.LeagueId))
	BP_AllianceCompetition_seasonText = string.gsub(strMsg, "{1}", endTimeStr)
end

function AllianceCompetitionShopUI.Show()
	if AllianceCompetitionShopUI.isShow == true then
		return
	end

	AllianceCompetitionShopUI.InitData();

	-- 兼容个人信息面板跳转=====================================
    EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN)
    LuaClassObj.HandleUIMessage(bp_alliance, "ShowSelf")
    -- ========================================================
    -- AllianceCompetitionShopUI._ShowPlayer()
    -- LuaClassObj.HandleUIMessage(bp_lobby, "EndLobbyToMall")
    if _avatar ~= nil then
    	_avatar:Destroy()
    end

	local showPosition = {}
	showPosition.x = -45
	if LobbyCameraManager.FetchCameraAdapt() == LobbyCameraManager.AdaptWide then
		showPosition.x = -15
	end
	showPosition.y = -383
	showPosition.z = -14347
	_avatar = GenderAvatar.CreateMyself(showPosition)
	_avatar:FixGender()
	
    LuaClassObj.HandleDynamicCreation(bp_alliance_competition_shop)
    LuaClassObj.HandleUIMessageNoFetch(bp_alliance_competition_shop, "UIShow")
    LuaClassObj.HandleUIMessageNoFetch(bp_alliance_competition_shop, "SwitchScene")
	LobbySceneManager.ShowMesh(LobbySceneManager.MALL_MESH_LobbyBgMesh)

	AllianceCompetitionShopUI.isShow = true
	UIManager.Show(eUIType.eAllianceCompetitionShop)

	AllianceCompetitionShopUI.InitItems()
    AllianceCompetitionSystemHandler.ShaopItemsReq()
end

function AllianceCompetitionShopUI.Hide()
	if AllianceCompetitionShopUI.isShow == false then
		return
	end
	_avatar:Destroy()

    -- AllianceCompetitionShopUI.ResetItemAvatar()
    -- AllianceCompetitionShopUI.ShowSelf()
    -- LuaClassObj.HandleUIMessage(bp_lobby, "StartMallToLobby")
	LuaClassObj.HandleUIMessageNoFetch(bp_alliance_competition_shop, "UIHide")
	AllianceCompetitionShopUI.isShow = false;
	UIManager.Hide(eUIType.eAllianceCompetitionShop);

	EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE);
end

function AllianceCompetitionShopUI.ShowSelf()
    AllianceCompetitionShopUI._ShowPlayer()
    LuaClassObj.HandleUIMessageNoFetch(bp_alliance_competition_shop, "ShowSelf")
end

function AllianceCompetitionShopUI.HideSelf()
    AllianceCompetitionShopUI._ShowPlayer()
    LuaClassObj.HandleUIMessageNoFetch(bp_alliance_competition_shop, "HideSelf")
end

function AllianceCompetitionShopUI._ShowPlayer()
	-- LuaClassObj.HandleUIMessage(bp_lobby, "ShowMallPlayer")
	_avatar:ShowAvatar()
end

function AllianceCompetitionShopUI._HidePlayer()
	-- LuaClassObj.HandleUIMessage(bp_lobby, "HideMallPlayer")
	_avatar:HideAvatar()
end

function AllianceCompetitionShopUI.HideImage()
	LuaClassObj.HandleUIMessageNoFetch(bp_alliance_competition_shop, "HideImage")
end

-- 初始化商店
function AllianceCompetitionShopUI.InitItems()
    BP_AllianceCompetition_operateShopId = 0
    BP_ARRAY_AllianceCompetition_ShopItemInfoList = {}
    AllianceCompetitionShopUI:UpdateShopItems()
    LuaClassObj.HandleUIMessageNoFetch(bp_alliance_competition_shop, "ScrollToTop")
end

-- 更新商店信息
function AllianceCompetitionShopUI:UpdateShopItems()
    LuaClassObj.HandleUIMessageNoFetch(bp_alliance_competition_shop, "UpdateShopItems")
    LuaClassObj.HandleUIMessageNoFetch(bp_alliance_competition_shop, "UpdateSelectItem")

	BP_AllianceCompetition_coin = DataMgr.carteam_coin_count;
    LuaClassObj.HandleUIMessageNoFetch(bp_alliance_competition_shop, "Refresh");
end

function EventUAllianceCompetitionShopItemClick()
    AllianceCompetitionSystem.log("EventUAllianceCompetitionShopItemClick BP_AllianceCompetition_operateShopId "..BP_AllianceCompetition_operateShopId)

    for i,v in ipairs(BP_ARRAY_AllianceCompetition_ShopItemInfoList) do
        if v.itemId == BP_AllianceCompetition_operateShopId then
            AllianceCompetitionShopUI.ShowItemInfo(BP_AllianceCompetition_operateShopId)
            break
        end
    end

    LuaClassObj.HandleUIMessageNoFetch(bp_alliance_competition_shop, "UpdateSelectItem")
end

function EventUAllianceCompetitionShopItemBuyClick()
    AllianceCompetitionSystem.log("EventUAllianceCompetitionShopItemBuyClick BP_AllianceCompetition_operateShopId "..BP_AllianceCompetition_operateShopId)

    EventUAllianceCompetitionShopItemClick()
    
    for i,v in ipairs(BP_ARRAY_AllianceCompetition_ShopItemInfoList) do
        if v.itemId == BP_AllianceCompetition_operateShopId then
            if v.curCount < v.maxCount then

                BP_UnknowPass_Confirm_ExchangeId = v.exchangeId
                BP_UnknowPass_Confirm_ExchangeItemId = v.itemId
				BP_UnknowPass_Confirm_Cost_ItemId = 0
				BP_UnknowPass_Confirm_Cost_ItemNum = v.costScore
				BP_UnknowPass_Confirm_BuyCount = v.curCount
				BP_UnknowPass_Confirm_Limit = v.maxCount
				
                UnknowPassExchangeConfirm.ShowUI(BP_UnknowPass_Confirm_Showtype.ALLIANCE_COMPETITION)
            else
                UnknowPassSystem:PopErrorMsg(502012);
            end 
            break
        end
    end
end

--------------------------------------------------------点选道具处理--------------------------------------------------
-- 获取极品宝箱道具列表
function AllianceCompetitionShopUI.GetJiPinBoxItemList(itemId)
	log("AllianceCompetitionShopUI.GetJiPinBoxItemList "..itemId)
	local roleUid = DataMgr.roleData.uid
	local playerInfo = ProfileMgr.GetPlayerDataByUid(roleUid)
	if nil == playerInfo then
		return nil
	end

	local sex = playerInfo.sex
	
	--查找掉落Id
	local tb1 = Client.GetTable("ChestDrop")
	local dropId = 0
	for k,v in pairs(tb1) do
		if v.ChestID == itemId then
			dropId = v.DropID
			break
		end
	end
	if dropId == 0 then
		return false
	end
	log("AllianceCompetitionShopUI.GetJiPinBoxItemList dropId"..dropId)
	
	--获取掉落物品列表
    local drop_util = require("client.common.drop_util")
    local drops = drop_util.GetByDropID(dropId)
    
	local itemList = {}
	for _,v in pairs(drops) do
		--log_tree("v = ", v)
        local cfg = Client.GetTableData("DropMapping", v.DropMappingID)
        --log_tree("cfg = ", cfg)
        if cfg then
            if sex == 1 then
                table.insert(itemList, cfg.DropItemMaleID)
            else
                table.insert(itemList, cfg.DropItemFemaleID)
            end
        end
	end

	return itemList
end

-- 点击商店道具
function AllianceCompetitionShopUI.ShowItemInfo(itemId)
	--极品宝箱道具预览
	local itemList = AllianceCompetitionShopUI.GetJiPinBoxItemList(itemId)
	if itemList then
		-- if UnknowPassBuy.IsUIShow == true then
		-- 	UnknowPassUI.lastBuyLevelSelectItemId = BP_AllianceCompetitionShopPreSelectItemId
		-- else
		-- 	UnknowPassUI.lastSelectItemId = BP_AllianceCompetitionShopPreSelectItemId
		-- end
		
		AllianceCompetitionTreasureBoxUI.SetData(itemId, itemList, _avatar)
		AllianceCompetitionTreasureBoxUI.Init()
		return
	else
		AllianceCompetitionSystem.log("ShowItemInfo itemList is nil")
	end
	
	
	local itemDataCfg = Client.GetTableData("Item", itemId);
	local showItemDetail = true;

	if itemDataCfg then
		if itemDataCfg.ItemType == 1 then
			if itemDataCfg.ItemSubType == 801 then
				BP_AllianceCompetition_Show_Item_type = "tool";	--平底锅
			else
				BP_AllianceCompetition_Show_Item_type = "weapon";--武器
				showItemDetail = false;
				_avatar:PutonOrPutoff(itemId);
			end

		elseif itemDataCfg.ItemType == 22 then
			BP_AllianceCompetition_Show_Item_type = "dance";--舞蹈
			showItemDetail = false;
			LobbyUI:ShowEmoteAction(DataMgr.roleData.uid, itemId, nil, nil, 1);

		elseif itemDataCfg.ItemType == 4 and itemDataCfg.ItemSubType == 701 then
			BP_AllianceCompetition_Show_Item_type = "parachute";--降落伞

		elseif itemDataCfg.ItemType == 8 and itemDataCfg.ItemSubType == 801 then
			BP_AllianceCompetition_Show_Item_type = "aircraft";--飞机皮肤

		elseif itemDataCfg.ItemType == 5 then
			if itemDataCfg.ItemSubType == 501 or itemDataCfg.ItemSubType == 504 then
				BP_AllianceCompetition_Show_Item_type = "image";	--背包
				showItemDetail = false;
				_avatar:PutonOrPutoff(itemId);

			elseif itemDataCfg.ItemSubType == 502 or itemDataCfg.ItemSubType == 505 then
				BP_AllianceCompetition_Show_Item_type = "image";	--头盔
				showItemDetail = false;
				_avatar:PutonOrPutoff(itemId);
			else
				BP_AllianceCompetition_Show_Item_type = "tool";	--道具
			end

		elseif itemDataCfg.ItemType == 4 then
			BP_AllianceCompetition_Show_Item_type = "image";--形象
			showItemDetail = false;
			_avatar:PutonOrPutoff(itemId);

		elseif itemDataCfg.ItemType == 9 then
			BP_AllianceCompetition_Show_Item_type = "car";	--载具
		else
			BP_AllianceCompetition_Show_Item_type = "tool";--默认为道具
		end

		log(string.format("[yyc] ShowItemInfo item type = %s", BP_AllianceCompetition_Show_Item_type));
		BP_AllianceCompetition_Show_Detail_ResId = itemId
		BP_AllianceCompetitionShopPreSelectItemId = itemId
		BP_AllianceCompetition_ShowAvatar = showItemDetail

		if showItemDetail == false then
			AllianceCompetitionShopUI._ShowPlayer()
		else
			AllianceCompetitionShopUI._HidePlayer()
		end
	end
end

--------------------------------------------------------点选道具处理完结----------------------------------------------
function EventAllianceCompetitionShopClickClose()
	AllianceCompetitionShopUI.Hide()
end