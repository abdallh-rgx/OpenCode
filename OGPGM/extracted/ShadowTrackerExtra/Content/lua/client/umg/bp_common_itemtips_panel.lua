CommonItemTipsUI = CommonItemTipsUI or {
	owningNum = 0,
}

BP_CommonItemTips_ItemID =0;
BP_CommonItemTips_ColorID =0;
BP_CommonItemTips_PatternID =0;
BP_CommonItemTips_Gender = 1;

--手动输入状态下，输入点击位置或者按钮位置，panel再计算摆放
BP_STRUCT_CommonItemTips_Pos = { x = 0,y = 0}

BP_CommonItemTips_OwningText = ""
BP_CommonItemTips_ShowLimitTimeIcon = false

local item_time_info = {}
-- 注册面板
function bp_common_itemtips_panel_RegisterUI()
	log("CommonItemTipsUI:bp_common_itemtips_panel_RegisterUI");
	LuaClassObj.SubUIWidgetList(bp_common_itemtips_panel,
		{{Path="/Game/UMG/UI_Logic/Common/Common_ItemTips_Panel_BP.Common_ItemTips_Panel_BP_C", Container="Top", ZOrder=BP_ENUM_UI_COMMON_ITEMTIPS_ZORDER}},
		{"Lobby","CreateRole"},
		false,
		false
	);	
end

function CommonItemTipsUI:ShowPanel(itemID,pos,colorID,patternID,owningNum,isLimitTime)
	BP_CommonItemTips_ItemID = itemID
	BP_CommonItemTips_ColorID = colorID or 0;
	BP_CommonItemTips_PatternID = patternID or 0;
    BP_STRUCT_CommonItemTips_Pos = pos
    BP_CommonItemTips_Gender = DataMgr.roleData.gender
	CommonItemTipsUI.owningNum = owningNum or 0;
	BP_CommonItemTips_ShowLimitTimeIcon = isLimitTime or false;
	LuaClassObj.HandleUIMessage(bp_common_itemtips_panel, "UIShow");
end

function CommonItemTipsUI:SetPanelTimeInfo(time_info)
	item_time_info = time_info
end

function CommonItemTipsUI:ClosePanel()
	LuaClassObj.HandleUIMessage(bp_common_itemtips_panel, "UIClose")
end

local function GetItemNum(itemID)
	log("查询id：" .. itemID)
	if CommonItemTipsUI.owningNum > 0 then
		return CommonItemTipsUI.owningNum;
	end
    local itemData = Client.GetTableData("Item", itemID)
    -- Avatar类型，从Avatar List里获取数量
    if itemData.AvatarID ~= 0 then
        if DataMgr.avatarData.avatar_list[itemData.AvatarID] ~= nil then
            return 1
        end
    end

	-- 宠物数量
	local petDepot = 0;
	if StoreFuncUtils.IsPetItemID(itemID) then
		local PetSystem = require("client.slua.logic.pet.logic_pet");
		if PetSystem.HasPet(itemID) then
			petDepot = 1;
		end
	end

	return DataMgr.GetHallDepotItemCountByResID(itemID) + petDepot;
end

function EventCommonItemTipsGetOwningText_Push()
	--头像框数据需要查表
	local itemData = Client.GetTableData("Item", BP_CommonItemTips_ItemID)
	local owningText = " "
	if BP_CommonItemTips_ItemID == 1000 then
		--金币不显示

		--owningText = "拥有金币 " .. DataMgr.gold
		--owningText = string.format(Client.GetTableData("LocalizeRes", "301220").TextValue, DataMgr.gold);
	-- elseif BP_CommonItemTips_ItemID == 1001 then
	-- 	owningText = "拥有钻石 " .. DataMgr.roleData.attr_type_diamond
	elseif BP_CommonItemTips_ItemID == 1001 then
		-- 银碎币不显示
	elseif BP_CommonItemTips_ItemID == 1101 then
		--猪排勋章不显示
	elseif BP_CommonItemTips_ItemID == 1003 then
		--经验不显示
	elseif BP_CommonItemTips_ItemID == 1104 then
		-- 金碎币不显示
		
		-- local  curlevel = tonumber(DataMgr.roleData.level)
		-- local  nextLevelExp = ""
		-- if curlevel > 0 and curlevel < 100 then
		-- 	local curmilitarylevel = Client.GetTableData("MilitaryRankLevel", curlevel);
		-- 	nextLevelExp = tostring(curmilitarylevel.Exp);
		-- end
		-- --owningText = "当前经验 " .. RoleInfoSystem.PersonalBasicInfo["role_curexpnum"].. "/" .. RoleInfoSystem.PersonalBasicInfo["role_needexpnum"] 
		-- owningText = Client.GetTableData("LocalizeRes", "301221").TextValue .. DataMgr.roleData.roleExp .. "/" .. nextLevelExp
	elseif BP_CommonItemTips_ItemID == 1004 then
		owningText = string.format(Client.GetTableData("LocalizeRes", "301222").TextValue, DataMgr.activeness.value);
	elseif BP_CommonItemTips_ItemID == 1005 then
		--名师点不显示
	elseif BP_CommonItemTips_ItemID == 1006 then
		--UC不显示
		--owningText = string.format(Client.GetTableData("LocalizeRes", "301222").TextValue, DataMgr.ticket or 0);
	elseif itemData.ItemType == 20 then 
		--头像框不显示
	elseif itemData.ItemType == 200 then 
		--头像不显示
	elseif itemData.ItemType == 24 then
		--称号不显示
	elseif BP_CommonItemTips_ItemID == 1008 then 
		-- 军团活跃值不显示
	elseif BP_CommonItemTips_ItemID == 1009 then 
		-- 军团币不显示
	elseif itemData.ItemType == 250 then 
		-- 军团称号不显示
	elseif BP_CommonItemTips_ItemID == 20001 then
		-- 赛季时装背包不显示
	elseif BP_CommonItemTips_ItemID == 1102 then
		-- 赛事币不显示	
	elseif BP_CommonItemTips_ItemID == 1099 then
		-- 绝地通行证积分不显示
	else
		--owningText = "拥有 " .. GetItemNum(BP_CommonItemTips_ItemID)  .. "个"
		owningText = string.format(Client.GetTableData("LocalizeRes", "301222").TextValue, GetItemNum(BP_CommonItemTips_ItemID));
	end


	--限时物品显示过期时间
	if item_time_info and item_time_info.is_limit and item_time_info.time_s ~= "" then
		BP_CommonItemTips_OwningText = item_time_info.time_s
	else
		BP_CommonItemTips_OwningText = owningText
	end

	log("[HHF]EventCommonItemTipsGetOwningText_Push, id = " .. BP_CommonItemTips_ItemID .. ", OwningText = " .. BP_CommonItemTips_OwningText);
end
