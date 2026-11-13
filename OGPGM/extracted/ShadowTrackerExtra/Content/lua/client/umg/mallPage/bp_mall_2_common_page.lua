MallPageCommonUI_2 = MallPageCommonUI_2 or
{
isShowing = false;
}

-- ��Ʒ��Ʒ�ṹ
BP_STRUCT_Store_Item_Info = 
{
	shopID = 0,                   -- shopID
	itemID = 0,                   -- ��ƷID
	count  = 0,                   -- ��Ʒ����
	limitCount = 0,               -- �޹�����
	quality = 0,                  -- ��ƷƷ��
	itemName = "",                -- ��Ʒ����
	itemIcon = "",                -- ��Ʒͼ��
	isNew = false,                -- �Ƿ���Ʒ
	isHot = false,                -- �Ƿ�����
	isEquip = false,              -- �Ƿ񴩴�
	isSelect = false,             -- �Ƿ�ѡ��
	isGet = false,                -- �Ƿ�ӵ��
	isLimit = false,              -- �Ƿ���ʱ����
	saleLimitTime = 0,            -- ��ʱ����ʱ��
	priceType = 0,                -- ��������
	price = 0,                    -- ԭʼ�۸�
	discount = 0,				  -- �ۿ�
	discountPrice = 0,            -- ���ۼ۸�
	isDiscountLimit = false,      -- �Ƿ���ʱ����
	discountLimit = 0, 			  -- ��ʱ�ۿ�
	discountLimitPrice = 0,       -- ��ʱ���ۼ۸�
	discountLimitStartTime = 0,	  -- ��ʱ���ۿ�ʼʱ��
	discountLimitEndTime = 0,     -- ��ʱ���۽���ʱ��
	isCanSend = false,     -- �Ƿ�������
	isUseCoupons = false,	--是否可以使用代金券
	PrimeItemStatus = 0,	--0 为非订阅物品，1为普通订阅状态物品，2为高级订阅物品
	CurPrimeStatus = 0,		--自身的订阅状态
	specialIcon = "",		--特殊角标
};

-- ��Ʒ�б�
BP_ARRAY_Store_Item_List = 
{
	BP_STRUCT_Store_Item_Info = _G.BP_STRUCT_Store_Item_Info, --����ṹ�����飬����д��Ҫ��Ϊ�淶�涨����
};

BP_ARRAY_Store_Sort_List = 
{
	shopId = 0;
};

BP_STRUCT_Mall_Second_Tab_Info =
{
	id = 0,
	name = "",
	icon = "",
	time = 0,
	itemListNum = 0,
};
BP_ARRAY_Mall_Second_Tab_List =
{
	BP_STRUCT_Mall_Second_Tab_Info = _G.BP_STRUCT_Mall_Second_Tab_Info;
}

BP_Mall_Hot_Point_2rd_IsShow = false;
BP_ARRAY_Mall_HOT_2rdTab =
{
    id = 0;
}

BP_ARRAY_Mall_Has_Seed_Items =
{
    id = 0;
}


BP_Mall_2_Cur_SELECT_SHOP_Id = 0;
BP_Mall_Cur_EQUIP_SHOP_Id = 0;
BP_Mall_Cur_EQUIP_STATE = 0;
BP_Mall_Cur_BUY_SHOP_ID = 0;

BP_Mall_IS_CHECK_NOHAS = false;
BP_Mall_SELECT_SORT = 0;

BP_Mall_Second_Tab_Id = 0;
BP_Mall_Item_List_Num = 0;

BP_Mall_Cur_Page_Is_Mystery = false;
BP_Mall_Mystery_Limit_Time = 0;
BP_Mall_Mystery_Limit_Time2 = 0;

--��ǰ������ʱ��
BP_Mall_2_Cur_ServerTime = 0;
BP_Mall_2_Mystery_Is_Hot = false;
BP_Mall_2_Mystery2_Is_Hot = false;
BP_Mall_2_Second_Hot_IsShow = false;

BP_Mall_Hot_Point_SecondTab = 0;
BP_Mall_Hot_Point_SecondTab_IsShow = false;

local curPageIndex = 0;
local curPageSecondIndex = 0;
local curDataList = nil;
local curFirstSelectShopId = 0;

local MysteryIndex = 13;
local WeaponIndex = 15;

BP_Tab2_Number = 1;
local isJump = false;
local tab2 = 0;

BP_Mall_2_JumpIndex = 0;

-- ע��widget
function bp_mall_2_common_page_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_mall_2_common_page,
	{{Path="/Game/UMG/UI_Logic/Lobby_Store/Store_2/Mall_Common_Logic_BP.Mall_Common_Logic_BP_C", Container="Default", ZOrder=0},
	},
	{"MallSystem","Lobby"},
	false,
	false
	);
end



local function localText(id)
    local data = Client.GetTableData("LocalizeRes",id);
    if data then
        return data.TextValue
    end
    return ""
end

function MallPageCommonUI_2.Init()
	if MallPageCommonUI_2.isShowing then
		return;
	end
	EventMallRefreshMultBuy()
	log("MallPageCommonUI_2 ShowUI");
	MallPageCommonUI_2.isShowing = true;
	LuaClassObj.HandleDynamicCreation(bp_mall_2_common_page);
end

function MallPageCommonUI_2.Show(startSecondeIndex)
	if startSecondeIndex > 0 then
		isJump = true;
		tab2 = startSecondeIndex;
	end
	
	BP_Mall_2_JumpIndex = 0;
	MallSystemUI_2.ForceRevertAvatar()

	LuaClassObj.HandleUIMessage(bp_mall_2_common_page, "UIShow");
end

function MallPageCommonUI_2.Hide(isRelease)
	if not isRelease then
		if curPageIndex == WeaponIndex then
			MallSystemUI_2.HideWeapon();
		end
		
	end

	MallSystemUI_2.ForceRevertAvatar()

	curPageSecondIndex = 0;
	LuaClassObj.HandleUIMessage(bp_mall_2_common_page, "UIHide");
end

function MallPageCommonUI_2.Release()
	MallPageCommonUI_2.Hide(true);
	MallPageCommonUI_2.isShowing = false;

	MallSystemUI_2.ForceRevertAvatar()
end

function MallPageCommonUI_2.UpdateList(pageIndex, dataList, tabInfo, curGetTime,curGetTime2,setFirstSelectShopId)
	MallSystemUI_2.ForceRevertAvatar()
	
	if dataList == nil then
		dataList = {};
	end
	log("MallPageCommonUI_2.UpdateList" .. pageIndex);
	--log_tree("dataList",dataList);
	--log_tree("tabInfo",tabInfo);
	BP_ARRAY_Store_Item_List = {};
	curPageIndex = pageIndex;
	curDataList = dataList;
	local item = nil;
	BP_Mall_IS_CHECK_NOHAS = false;
	BP_Mall_SELECT_SORT = 0;
	curFirstSelectShopId = setFirstSelectShopId;
	
	MallPageCommonUI_2.SetTabList(tabInfo,curGetTime,curGetTime2);
end

function MallPageCommonUI_2.SetTabList(tabInfo,curGetTime,curGetTime2)
	BP_ARRAY_Mall_Second_Tab_List = {};
	--log_tree("zino tabInfo",tabInfo)
	--log("tabInfo.B_table_number.. " .. tostring(tabInfo.B_table_number))
	for i = 1,tabInfo.B_table_number do
		local tabItem = {
			id = tabInfo["B_table_ID" .. i],
			name = localText(tabInfo["B_table_name" .. i]),
			icon = tabInfo["B_table_icon" .. i],
			time = 0,
			itemListNum = tabInfo["B_table_list" .. i],
		}
		if curPageIndex == MysteryIndex then
			if i == 1 then
				tabItem.time = curGetTime2;
			end
			if i == 2 then
				tabItem.time = curGetTime;
			end
		end
		table.insert(BP_ARRAY_Mall_Second_Tab_List,tabItem);
	end
	--log_tree("BP_ARRAY_Mall_Second_Tab_List",BP_ARRAY_Mall_Second_Tab_List);
	
	if isJump then
		isJump = false;
		for i,v in ipairs(BP_ARRAY_Mall_Second_Tab_List) do
			if v.id == tab2 then
				BP_Tab2_Number = i;
				break;
			end
		end
	else
		BP_Tab2_Number = 1;
	end
	
	LuaClassObj.HandleUIMessage(bp_mall_2_common_page, "LuaUpdateTabList");
end

function MallPageCommonUI_2.SelectItemByShopId(shopId)
	BP_Mall_2_Cur_SELECT_SHOP_Id = shopId
	LuaClassObj.HandleUIMessage(bp_mall_2_common_page, "LuaSetSelectItem");
end

function MallPageCommonUI_2.DynamicUpdate(dataList)
	log("MallPageCommonUI_2.DynamicUpdate");
	BP_ARRAY_Store_Item_List = {};
	for i,v in pairs(dataList) do
		local data = MallSystemUI_2.MarketData2ItemData(v);
		if data ~= nil then
			table.insert(BP_ARRAY_Store_Item_List, data);
		end
	end
	--log_tree("dataList",dataList);
	LuaClassObj.HandleUIMessage(bp_mall_2_common_page, "DynamicUpdateItem");
end

function MallPageCommonUI_2.GetHotState(firstTab, dataList, tabInfo)
	local isNew = false;
	
	for i = 1,tabInfo.B_table_number do
		local secondTab = tabInfo["B_table_ID" .. i];
		isNew =  isNew or MallPageCommonUI_2.GetTab2HotState(firstTab, secondTab, false);
	end
	
	return isNew;
end

function MallPageCommonUI_2.GetTab2HotState(firstTab, secondTab, isGetSecond)
	local isNew = false;
	local allDict = MallSystem.GetMallSimpleInfoDict(); 
	
	if firstTab == MysteryIndex and (secondTab == 1 or secondTab == 2) then
		
		if secondTab == 1 then
			LuaClassObj.HandleUIMessage(bp_mall_2_common_page, "IsNewMystery");
			if BP_Mall_2_Mystery_Is_Hot then
				BP_Mall_2_Second_Hot_IsShow = true;
				return true;
			end
		else
			LuaClassObj.HandleUIMessage(bp_mall_2_common_page, "IsNewMystery2");
			if BP_Mall_2_Mystery2_Is_Hot then
				BP_Mall_2_Second_Hot_IsShow = true;
				return true;
			end
		end
		
	else
		if allDict ~= nil and allDict[firstTab] ~= nil and allDict[firstTab][secondTab] ~= nil then
			local curDict = allDict[firstTab][secondTab];
			BP_ARRAY_Mall_HOT_2rdTab = curDict;
			LuaClassObj.HandleUIMessage(bp_mall_2_common_page, "LuaGetTab2Hot");
			if BP_Mall_Hot_Point_2rd_IsShow then
				BP_Mall_2_Second_Hot_IsShow = true;
				return true;
			end
		end
	end
	BP_Mall_2_Second_Hot_IsShow = isNew;
	return isNew;
end

function MallPageCommonUI_2.SetClickTab(secondTab)
	--�����ʱ��1��2���⣬ȥ����ʱ��ÿ�պ��
	local firstTab = curPageIndex;
	if firstTab == MysteryIndex and (secondTab == 1 or secondTab == 2) then
			
		if secondTab == 1 then
			LuaClassObj.HandleUIMessage(bp_mall_2_common_page, "SetNewMysteryTime");
		else
			LuaClassObj.HandleUIMessage(bp_mall_2_common_page, "SetNewMysteryTime2");
		end
		
		local allDict = MallSystem.GetMallSimpleInfoDict(); 
		local dataList = nil;
		if allDict ~= nil and allDict[firstTab] ~= nil and allDict[firstTab][1] ~= nil then
			dataList = allDict[firstTab][1];
		end
		if dataList == nil then
			return;
		end
		local temp = {};
		for i,v in pairs(dataList) do
			table.insert(temp, v);
		end
		BP_ARRAY_Mall_Has_Seed_Items = temp;
		LuaClassObj.HandleUIMessage(bp_mall_2_common_page, "LuaSetHasSeeItems");
		LuaClassObj.HandleUIMessage(bp_mall_2_common_page, "UpdateSecondHot");
		MallSystemUI_2.UpdateFirstTabHotState();
		return;
	end
	
	local allDict = MallSystem.GetMallSimpleInfoDict(); 
	local dataList = nil;
	if allDict ~= nil and allDict[firstTab] ~= nil and allDict[firstTab][secondTab] ~= nil then
		dataList = allDict[firstTab][secondTab];
	end
	if dataList == nil then
		return;
	end
	local temp = {};
	for i,v in pairs(dataList) do
		table.insert(temp, v);
	end
	BP_ARRAY_Mall_Has_Seed_Items = temp;
	LuaClassObj.HandleUIMessage(bp_mall_2_common_page, "LuaSetHasSeeItems");
	LuaClassObj.HandleUIMessage(bp_mall_2_common_page, "UpdateSecondHot");
	MallSystemUI_2.UpdateFirstTabHotState();
end


function MallPageCommonUI_2.SetEquip(shopId, isEquip)
	BP_Mall_Cur_EQUIP_SHOP_Id = shopId;
	BP_Mall_Cur_EQUIP_STATE = isEquip and 1 or 0;
	LuaClassObj.HandleUIMessage(bp_mall_2_common_page, "SetItemEquip");
end

--��������ѡ��item��ѡ��״̬����������
function MallPageCommonUI_2.SetItemSelect()
	LuaClassObj.HandleUIMessage(bp_mall_2_common_page, "LuaSetItemSelect");
end

function MallPageCommonUI_2.GetDatas(tab)
	if curDataList == nil then
		return {};
	end
	if curDataList[tab] == nil and (not (curPageIndex == MysteryIndex and tab == 2)) then
		return {};
	end
	if curPageIndex == MysteryIndex and tab <= 2 then
		return curDataList[1];
	end
	return curDataList[tab];
end

function MallPageCommonUI_2.UpdateItemList()
	if curPageIndex == WeaponIndex then
		if curPageSecondIndex == 1 and curPageSecondIndex ~=  BP_Mall_Second_Tab_Id then
			MallSystemUI_2.HideWeapon();
		end
	end
	MallSystemUI_2.HideEquipDescript();
	curPageSecondIndex = BP_Mall_Second_Tab_Id;
	local dataList = MallPageCommonUI_2.GetDatas(BP_Mall_Second_Tab_Id);
	BP_ARRAY_Store_Item_List = {};
	for i,v in pairs(dataList) do
		local data = MallSystemUI_2.MarketData2ItemData(v);
		if data ~= nil then
			table.insert(BP_ARRAY_Store_Item_List, data);
		end
	end
	--log_tree("BP_ARRAY_Store_Item_List before sort",BP_ARRAY_Store_Item_List)
	MallSystemUI_2.SortList(BP_ARRAY_Store_Item_List, BP_Mall_SELECT_SORT);
	--log_tree("BP_ARRAY_Store_Item_List After sort",BP_ARRAY_Store_Item_List)
	--��������д
	if curPageIndex == MysteryIndex then
		local arr = {};
		local firstNum = MallPageCommonUI_2:GetMysteryNum();
		log("MallPageCommonUI_2:GetMysteryNum:" .. firstNum);
		-- if BP_Mall_Second_Tab_Id == 1 then
		-- 	local len = #BP_ARRAY_Store_Item_List > firstNum and firstNum or #BP_ARRAY_Store_Item_List;
		-- 	for i = 1,len do
		-- 		table.insert(arr, BP_ARRAY_Store_Item_List[i]);
		-- 	end
		-- 	BP_ARRAY_Store_Item_List = arr;
		-- end
		-- if BP_Mall_Second_Tab_Id == 2 then
		-- 	if #BP_ARRAY_Store_Item_List > firstNum then
		-- 		len = #BP_ARRAY_Store_Item_List;
		-- 		for i = firstNum + 1,len do
		-- 			table.insert(arr, BP_ARRAY_Store_Item_List[i]);
		-- 		end
		-- 	end
		-- 	BP_ARRAY_Store_Item_List = arr;
		-- end
		
	end
	--log_tree("dataList",dataList);
	--log_tree("BP_ARRAY_Store_Item_List",BP_ARRAY_Store_Item_List);
	BP_Mall_Item_List_Num = 1;
	for i,v in ipairs(BP_ARRAY_Mall_Second_Tab_List) do
		if BP_Mall_Second_Tab_Id == v.id then
			BP_Mall_Item_List_Num = v.itemListNum;
			break;
		end
	end
	LuaClassObj.HandleUIMessage(bp_mall_2_common_page, "LuaUpdateItemList");

	if curFirstSelectShopId > 0 then

		-- ������ת����
		BP_Mall_2_JumpIndex = 0;
		for i,v in ipairs(BP_ARRAY_Store_Item_List) do
			if v.shopID == curFirstSelectShopId then
				BP_Mall_2_JumpIndex = i
			end
		end
		-- BP_Mall_2_JumpIndex = 30
		log("==================BP_Mall_2_JumpIndex "..BP_Mall_2_JumpIndex)
		LuaClassObj.HandleUIMessage(bp_mall_2_common_page, "JumpToItem");

		-- ================

		MallPageCommonUI_2.SelectItemByShopId(curFirstSelectShopId);
	end
end

function MallPageCommonUI_2.SendSelectItem()
	MallSystemUI_2.MallSendShopItem(BP_Mall_2_Cur_SELECT_SHOP_Id);
end

function MallPageCommonUI_2:GetMysteryNum()
	local sysCfg = Client.GetTableData("SystemConfig", "MarketNewNumber")
	if sysCfg ~= nil then
		return tonumber(sysCfg.ConfigValue)
	end
	return 3
end


function EventSetInfo_Push()
end

function EventFetchInfo()
end

function EventMall2SelectEquip()
	MallSystemUI_2.SelectEquip(BP_Mall_2_Cur_SELECT_SHOP_Id, true);
end

function EventMallBuyItem()
	MallSystemUI_2.OpenBuySingleItemWin(BP_Mall_Cur_BUY_SHOP_ID);
end

function EventMall2UpdateItemList()
	MallPageCommonUI_2.UpdateItemList();
end

function EventMall2SetCurTime()
	local dateTime = os.date("*t", FuncUtil.GetServerTimeInSec());
	BP_Mall_2_Cur_ServerTime = dateTime.year * 1000 +  dateTime.month * 100 + dateTime.day;
end


function EventMallGetSecondTabHotPointState()
	BP_Mall_Hot_Point_SecondTab_IsShow = MallPageCommonUI_2.GetTab2HotState(curPageIndex, BP_Mall_Hot_Point_SecondTab, true);
end

function EventMall2UpdateSecondTabHot()
	MallPageCommonUI_2.SetClickTab(BP_Mall_Second_Tab_Id)
end

function EventMall2HideAllContent()
	MallSystemUI_2.HideAllContent();
end