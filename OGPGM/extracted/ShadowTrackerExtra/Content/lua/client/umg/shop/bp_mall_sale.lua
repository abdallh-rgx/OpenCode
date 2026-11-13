MallSaleUI = MallSaleUI or
{
    isShowing = false;
    isInit = false;
    hasData = false;
}

--面板样式
BP_MallSale_Style = 1;

BP_MallSale_Start_Time = 0;
BP_MallSale_End_Time = 0;

BP_MallSale_Click_Jump_Url = "";
BP_MallSale_Click_Icon_Name = "";

BP_STRUCT_MallSale_ItemInfo =
{
	pos = 0,
    good_id = "",
    title = "",
    tag = 0, --角标
    icon_name = "",
    priority = 0,
    TemplateID = 0,
    TemplateNo = 0,
};

BP_ARRAY_MallSale_ItemList =
{
	BP_STRUCT_MallSale_ItemInfo=_G.BP_STRUCT_MallSale_ItemInfo, --定义结构体数组，这种写法要作为规范规定下来
};


function bp_mall_sale_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_mall_sale,
	  {{Path="/Game/UMG/UI_BP/Lobby_Store_Int/Store_2/Store_Sale_UIBP.Store_Sale_UIBP_C", Container="Default", ZOrder=BP_ENUM_UI_SHOP_ZORDER}},
      {"Lobby"},
  	false,
  	true,
    true
	);
end

function bp_mall_sale_OnModeSwitched(gamestatus)
	log("bp_mall_sale_OnModeSwitched gamestatus = " .. gamestatus);

	status = string.lower(gamestatus);
    if status == "lobby" then
		if MallSaleUI.isShowing == true then
			MallSaleUI.Release();
		end
	end

	-- 回到登录场景清数据
    if string.lower(gamestatus) == "login" then
		if MallSaleUI.isShowing == true then
			MallSaleUI.Release();
		end
    end
end


function MallSaleUI.Init()


end

function MallSaleUI.Show()
    log("MallSaleUI Show -------------");
    log(MallSaleUI.isShowing)
    LuaClassObj.HandleDynamicCreation(bp_mall_sale);
    LuaClassObj.HandleUIMessage(bp_mall_sale, "UIShow");
    MallSystemUI_2.SetBalckBgShow(true);
    MallSystemUI_2.HideAllContent();

    if MallSaleUI.isShowing == true then
        return;
    end
    MallSaleUI.isShowing = true;


    if MallSaleUI.hasData == false then
        -- MallSaleUI:Test();
    else
        log("MallSaleUI UpdateInfo ");
        LuaClassObj.HandleUIMessage(bp_mall_sale, "UpdateInfo");
    end

end

function MallSaleUI.Hide()
    MallSaleUI.isShowing = false;

    log("MallSaleUI Hide");
    LuaClassObj.HandleUIMessage(bp_mall_sale, "ReleaseBP");
    LuaClassObj.HandleUIMessage(bp_mall_sale, "UIHide");
    MallSystemUI_2.SetBalckBgShow(false);

end

-- 释放资源
function MallSaleUI.Release()

    -- LuaClassObj.HandleUIMessage(bp_mall_system_2, "ShowCurrentPlayer");
    log("MallSaleUI.Release");
	--MallSaleUI.Hide();
    LuaClassObj.HandleUIMessage(bp_mall_sale, "ReleaseBP");
    MallSystemUI_2.SetBalckBgShow(false);
    MallSaleUI.hasData = false;
end

function MallSaleUI:Test()
    local valid_banner_table = {};
    local temp = {};
    valid_banner_table[1] = temp;
    temp.TemplateID = 3;
    temp.bannner1 = "4,5";
    temp.bannner2 = "4,5";
    temp.bannner3 = "4,5,4";
    temp.bannner4 = "5";

    local banner_info = {};
    temp = {};
    banner_info[4] = temp;
    temp.TemplateID = 3;
    temp.TemplateNo = 1;
    temp.good_id = "game://?module=1003200&Tab1=3&Tab3=5&id=23001";
    temp.title = "牛逼的皮鞋";
    temp.icon_name = "/Game/Arts/UI/TableIcons/ItemIcon/Parachute/Icon_Parachute_Show_34.Icon_Parachute_Show_34";

    temp = {};
    banner_info[5] = temp;
    temp.TemplateID = 3;
    temp.TemplateNo = 1;
    temp.good_id = "game://?module=1003200&Tab1=3&Tab3=5&id=23001";
    temp.title = "废物的royy";
    temp.icon_name = "/Game/Arts/UI/TableIcons/ItemIcon/Equipment_Big/Icon_Shirt_01_A_int_Big.Icon_Shirt_01_A_int_Big";
end


function MallSaleUI:HandleBannerItem (bannerStr, banner_info, position)
    if bannerStr == "" or bannerStr == nil then
        return;
    end
    local idList = string.split(bannerStr, ",");
    for i,v in ipairs(idList) do
        local info = banner_info[tonumber(v)];
        if info ~= nil then
            local item =
            {
                pos = position,
                good_id = info.good_id,
                title = info.title,
                tag = info.tag, --角标
                icon_name = info.icon_name,
                priority = i,
                TemplateID = info.TemplateID,
                TemplateNo = info.TemplateNo,
            };
            table.insert(BP_ARRAY_MallSale_ItemList, item);
        end
    end
end


function EventMallSaleClickItem ()
    if BP_MallSale_Click_Jump_Url ~= "" then
        local str = string.split(BP_MallSale_Click_Icon_Name, "/");
        local pngName = tostring(str[#str]);
        ClientSendBAReport(BP_BA_STORE_SALE_ITEM, 0, pngName);

        GlobalData:JumpUrl(BP_MallSale_Click_Jump_Url);
    end
end
