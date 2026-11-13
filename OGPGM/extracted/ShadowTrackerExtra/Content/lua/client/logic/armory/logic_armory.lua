
--[[
 军备库关逻辑
]]--

ArmorySystem = ArmorySystem or
{
    --宏定义
    ENUM_REQ_Armory = 1; --请求来源
    ENUM_REQ_Wardrobe   = 2; --请求来源仓库
    ENUM_REQ_Other = 0; --其他请求来源
    ENUM_REQ_ItemUpgrade   = 3; --请求来源外显升级成功后

    -- 获取枪械皮肤列表,后台返回的原始数据
    rsp_list = {};
    --[[
    rsp_list= {
            skin_list = {
                [weapon_id] = {
                    [skin_id] = {
                        is_open = is_open,
                        shop_info = {
                            shop_id=shop_id, money_type=money_type, lowest_price=lowest_price
                        }
                    }
                }
            }
            install_list = {
                [weapon_id] = {
                    skin_id = skin_id
                }
            }
    } 
    ]]

    WardrobeInsList = {};

   --前台重新组装好的数据结构
    AllWeaponSkinData = {};
    --[[
    [1] = 
    {
        WeaponID = 10010,
        CurrentSkinID = 101,
        SkinArray = 
        {
            [1] = 
            {
                SkinID = 101	
                ShopingID =  1
                IsOpen = 1
                HasEquip = false,
                HasOwner = false,
                --前台使用
                WeaponID = 0,
               	WeaponType = 0, --武器类型
                ShortHandType = 0, --6皮肤
                SkinUrl = "",
                SkinDesc = "",   
                SkinDetailDesc = ""            ,
                IsRedPoint = false,     
                leftTime = 0;
                Quality = 0;
                SkinName = "";
                
            },
            [2] = 
            {
                SkinId = 102	
                ShipingId =  2
                IsOpen = 1
                ...
            }
        }
    }
    ]]
    --存储所有武器的皮肤

    --存储所有红点
    RedPointMap = {}
}

--初始化后台下发数据
function ArmorySystem.ReBuildInitData(dataList)
    if nil == dataList then
        --dataList = {};
        --dataList.skin_list = {};
        log("ArmorySystem.skin_list data is nil");
        return;
    end
    ArmorySystem.RedPointMap = {};
    ArmorySystem.AllWeaponSkinData = {};
    --武器
    for k,v in pairs(dataList.skin_list) do
        local WeaponID = k;         
        if  ArmorySystem.AllWeaponSkinData[WeaponID] == nil then
            ArmorySystem.AllWeaponSkinData[WeaponID] = {};
        end
        ArmorySystem.AllWeaponSkinData[WeaponID].WeaponID= WeaponID;

        local data = DataMgr.GetHallDepotItemDataByInsID(tostring(ArmorySystem.GetSkinIdByWeaponID(WeaponID)));
        if data ~= nil then
           ArmorySystem.AllWeaponSkinData[WeaponID].CurrentSkinID = data.resID;
        end
        
        ArmorySystem.AllWeaponSkinData[WeaponID].SkinArray = {};
        --武器对应皮肤    
        local skinData = v;
        for tk,tv in pairs(skinData) do
            --过滤不开放的皮肤
            if tv.is_open ~= 0 then  
                local SkinID = tk;           
                local IsOpen = tv.is_open;
                local ShopingID = 0;
                local MoneyType = 0;
                local Price = 0;
                local HasEquip = false;
                if ArmorySystem.AllWeaponSkinData[WeaponID].CurrentSkinID == SkinID then
                    HasEquip = true;
                end
                if tv.shop_info ~= nil then
                    ShopingID = tv.shop_info.shopid;
                    MoneyType = tv.shop_info.money_type;
                    Price = tv.shop_info.lowest_price;
                end
                local skinItem = ArmorySystem.BuildSkinItemData(WeaponID, SkinID, ShopingID, IsOpen, MoneyType, Price, HasEquip);
                table.insert( ArmorySystem.AllWeaponSkinData[WeaponID].SkinArray, skinItem);
            end
        end   
    end
    --Test假数据
    --for i=1,6 do
       --ArmorySystem.TestData(i);      
    --end

    ArmorySystem.UpdateAllRedPoint();
    
    -- log_tree("ArmorySystemReBuildInitData", ArmorySystem.AllWeaponSkinData);
end

--构造皮肤数据结构
function ArmorySystem.BuildSkinItemData(WeaponID, SkinID, ShopingID, IsOpen, MoneyType, Price, HasEquip)
    local item = {};
    item.SkinID = SkinID;
    item.ShopingID = ShopingID;
    item.IsOpen = IsOpen;
    item.WeaponID = WeaponID;
    item.MoneyType = MoneyType;
    item.Price = Price;

    -- 武器 载具 还是 飞机
    local itemType = ArmoryUI.MAIN_TYPE.WEAPON
    --取皮肤映射表的皮肤URL
    local skinMap = Client.GetTableData("WeaponSkinMapping", SkinID)
    if skinMap == nil then
        skinMap = Client.GetTableData("VehiclePlaneSkinMapping", SkinID)
        if skinMap ~= nil then
            itemType = ArmoryUI.MAIN_TYPE.VEHICLE
        end
    end

    local weaponCfg  
    if itemType == ArmoryUI.MAIN_TYPE.WEAPON then
        weaponCfg = Client.GetTableData("ArmoryConfig",WeaponID);
        item.WeaponType = weaponCfg.WeaponType;
    else
        weaponCfg = Client.GetTableData("ArmoryVehicleConfig",WeaponID);

        if weaponCfg == nil then
            weaponCfg = Client.GetTableData("ArmoryPlaneConfig",WeaponID);
        end

        if weaponCfg ~= nil then
            item.WeaponType = weaponCfg.Type;
        else
            log("not found ArmoryConfig " .. WeaponID)
            item.WeaponType = 1
        end
    end

    local skinCfg  = Client.GetTableData("Item",SkinID);
    local insID = ArmorySystem.GetInsIdByResID(SkinID);

    item.ShortHandType = 6; --6皮肤
    item.HasEquip = HasEquip;--是否装备上    
    item.HasOwner = false;--是否拥有  --TODO要读取仓库
    item.IsRedPoint = WardrobeSystem.ContainsGunSkinHotDot(SkinID);
    item.leftTime = 0;
    item.SkinUrl = "";
    item.SkinDesc = "";
    item.SkinDetailDesc = "";
    item.Quality = 0; --默认读表格
    item.SkinName = "";
    if skinCfg ~= nil then
        -- item.SkinUrl = skinCfg.ItemSmallIcon;
        item.SkinDesc = skinCfg.ArmorySimpleDesc;   
        item.Quality = skinCfg.ItemQuality; --默认读表格
        item.SkinName = skinCfg.ItemName;
        item.SkinDetailDesc = skinCfg.ItemDesc
    end
    if skinMap ~= nil then
        item.SkinUrl = skinMap.iconURL;
    end

    if insID ~= nil then
       local data = DataMgr.GetHallDepotItemDataByInsID(insID);
       if data ~= nil then
        item.HasOwner = true;
        item.leftTime = data.expireTS; --为0表是永久
        -- item.IsRedPoint = data.isNew; --TODO要读取仓库
        item.Quality = data.itemQuality; --品质
       end
    end
    return item;    
end

--测试数据
function ArmorySystem.TestData(id)
    local  WeaponID = 101000+id;
    if  ArmorySystem.AllWeaponSkinData[WeaponID] == nil then
        ArmorySystem.AllWeaponSkinData[WeaponID] = {};
    end
    ArmorySystem.AllWeaponSkinData[WeaponID].WeaponID= WeaponID;
    ArmorySystem.AllWeaponSkinData[WeaponID].CurrentSkinID = WeaponID;    
    ArmorySystem.AllWeaponSkinData[WeaponID].SkinArray = {};
    local skinItem = ArmorySystem.BuildSkinItemData(WeaponID, WeaponID, 1, 1, 1, 10, false);
    --log_tree("TestData", skinItem);
    table.insert(ArmorySystem.AllWeaponSkinData[WeaponID].SkinArray, skinItem);
end

--存储所有红点
function ArmorySystem.UpdateAllRedPoint()
    for k,v in pairs(ArmorySystem.AllWeaponSkinData) do
        local skinData = v;
        for sk,sv in pairs(skinData.SkinArray) do
            if sv.IsRedPoint == true then
                ArmorySystem.RedPointMap[sv.WeaponID] = 1;
                if ArmorySystem.RedPointMap[sv.WeaponType] == nil then
                    ArmorySystem.RedPointMap[sv.WeaponType] = 1;
                else
                    local curNum = ArmorySystem.RedPointMap[sv.WeaponType];
                    ArmorySystem.RedPointMap[sv.WeaponType] = curNum + 1; 
                end

               break
            end
        end
    end

    log_tree("UpdateAllRedPoint",ArmorySystem.RedPointMap);
end

--是否有红点，武器ID，武器类型
function ArmorySystem.HasRedPointByWeaponIdOrType(WeaponIDOrType)
    local redpoint = false;
    if ArmorySystem.RedPointMap[WeaponIDOrType] ~= nil then
        if ArmorySystem.RedPointMap[WeaponIDOrType] > 0 then
            redpoint = true;
        end       
    end
    return redpoint;
end


--取消红点
function ArmorySystem.OnCancelRePoint(WeaponID)
   local result = false;
   log("OnCancelRePoint WeaponID:"..tostring(WeaponID));
   local skinData = ArmorySystem.GetSkinArrayByWeaponID(WeaponID);
   if skinData ~= nil then
    log_tree("OnCancelRePoint",skinData);
    for k,v in pairs(skinData.SkinArray) do
        if WeaponID == v.WeaponID then
            if v.IsRedPoint == true then
                v.IsRedPoint = false;
                ArmorySystem.RedPointMap[v.WeaponID] = 0;    
                if ArmorySystem.RedPointMap[v.WeaponType] == nil then
                    ArmorySystem.RedPointMap[v.WeaponType] = 0;
                elseif ArmorySystem.RedPointMap[v.WeaponType] > 0 then
                    local curNum = ArmorySystem.RedPointMap[v.WeaponType];
                    ArmorySystem.RedPointMap[v.WeaponType] = curNum -1;
                else
                    ArmorySystem.RedPointMap[v.WeaponType] = 0;
                end  

                --同步仓库数据
                WardrobeSystem.RemoveGunHotDot(v.WeaponID);
                result = true;

                log("OnCancelRePoint v.WeaponType:"..v.WeaponType.." ArmorySystem.RedPointMap[v.WeaponType] "..ArmorySystem.RedPointMap[v.WeaponType]);
                break;
            end
        end
    end
   end

   return result;
 
end


--获取军备武器皮肤
function ArmorySystem.GetSkinArrayByWeaponID(WeaponID)
    log("GetSkinArrayByWeaponID"..tostring(WeaponID));    
    --log_tree("GetSkinArrayByWeaponID",ArmorySystem.AllWeaponSkinData);
    return ArmorySystem.AllWeaponSkinData[WeaponID];
end

--返回武器对应的皮肤列表
function ArmorySystem.GetSkinListByWeaponID(WeaponID)
    local result = {};
    if ArmorySystem.rsp_list ~= nil then
        if ArmorySystem.rsp_list.skin_list[WeaponID] ~= nil then
            result = ArmorySystem.rsp_list.skin_list[WeaponID];        
        end
    end
    return result;
end

--返回已穿带的皮肤(这个返回的是installID)
function ArmorySystem.GetSkinIdByWeaponID(WeaponID)
    
    local skinid = 0;
    if ArmorySystem.rsp_list.install_list ~= nil then
        --log_tree("ArmorySystem.rsp_list.install_list",ArmorySystem.rsp_list.install_list);
        if ArmorySystem.rsp_list.install_list[WeaponID] ~= nil then
            skinid = ArmorySystem.rsp_list.install_list[WeaponID].skin_id;            
        end
    end
    log("GetSkinIdByWeaponID:"..tostring(WeaponID).."skinid:"..tostring(skinid));
    return skinid;
end

--返回已穿带的皮肤(这个返回的是resID)
function ArmorySystem.GetSkinResIdByWeaponID(WeaponID)
    local data = DataMgr.GetHallDepotItemDataByInsID(tostring(ArmorySystem.GetSkinIdByWeaponID(WeaponID)));
    if data == nil then
       return 0;
    end
    return data.resID;
end

--取实例ID
function ArmorySystem.GetInsIdByResID(skinResId)
   return  ArmorySystem.WardrobeInsList[skinResId];
end

--重建索引，资源ID和仓库唯一ID管理
function ArmorySystem.ContructResIdToWardrobeInsID()
    if nil == ArmorySystem.rsp_list.skin_list then
        log("ArmorySystem.skin_list data is nil 111");
        return;
    end
    ArmorySystem.WardrobeInsList = {};

    for k,v in pairs(ArmorySystem.rsp_list.skin_list) do
        local skinArray = v;
        for tk,tv in pairs(skinArray) do
            local skinResId = tk;
            --log("skinResId"..tostring(skinResId));
            local insID = ArmorySystem.GetWardrobeInsIdByResId(skinResId);
            ArmorySystem.WardrobeInsList[skinResId] = insID;           
        end
    end

    --log_tree("ContructResIdToWardrobeInsID",ArmorySystem.WardrobeInsList);
end

function ArmorySystem.GetWardrobeInsIdByResId(skinResId)
    local insID = 0;
    local insIdArray = DataMgr.GetHallDepotItemListByResID(skinResId);    
    --log_tree("insIdArray",insIdArray);
    for k,v in pairs(insIdArray) do
      local dataInfo = DataMgr.GetHallDepotItemDataByInsID(v.insID);
      --log_tree("dataInfo",dataInfo);
      local time = 0;
      if dataInfo ~= nil then
        if dataInfo.expireTS == 0 then
            insID = dataInfo.insID;
            break;
        elseif dataInfo.expireTS > time then 
            time = dataInfo.expireTS;
            insID = dataInfo.insID;
        end
      end
    end
    return insID;
end

-- 请求枪械皮肤列表
--client_data透传字段,请求来源 仓库、军备库？
function ArmorySystem.get_weapon_skin_list(client_data)
    log("get_weapon_skin_list");
    -- if client_data == ArmorySystem.ENUM_REQ_Wardrobe then
    --     NetUtil.SendPriorityPkg(false, "get_weapon_skin_list_rsp", "get_weapon_skin_list", client_data);
    -- else
    --     NetUtil.SendPkg("get_weapon_skin_list",client_data);
    -- end

    -- NetUtil.SendPriorityPkg(false, "get_weapon_skin_list_rsp", "get_weapon_skin_list", client_data);
    NetUtil.SendPriorityPkg(false, "get_all_skin_list_rsp", "get_all_skin_list", client_data);
end
--返回皮肤列表，client_data来源，errorCode错误码(0表示成功)，rsp_list皮肤列表
function ArmorySystem.get_weapon_skin_list_rsp(client_data, errorCode, rsp_list)
   -- log("get_weapon_skin_list_rsp");    
    --log_tree("get_weapon_skin_list_rsp",rsp_list);  
    if errorCode ~= 0 then
        --TODO,读取本地化表
        DataMgr.ShowNoticeByID(errorCode)
        return;
    end

    -- 测试载具皮肤数据
    -- local shopInfo = {}
    -- shopInfo.lowest_price = 1500
    -- shopInfo.shopid = 0
    -- shopInfo.money_type = 1

    -- local testSkinData = {}
    -- testSkinData.is_open = 1
    -- testSkinData.shop_info = shopInfo

    -- local testData = {}
    -- testData[1901002] = testSkinData
    -- testData[1901003] = testSkinData
    -- testData[1901004] = testSkinData
    -- testData[1901005] = testSkinData

    -- -- 载具测试皮肤
    -- rsp_list.skin_list[1901001] = testData

    -- -- 飞机测试皮肤
    -- local testPlaneData = {}
    -- testPlaneData[1801102] = testSkinData
    -- testPlaneData[1801103] = testSkinData
    -- rsp_list.skin_list[1801101] = testPlaneData

    -- =========
    -- log_tree("========rsp_list=====",rsp_list)
    ArmorySystem.rsp_list = rsp_list;
    if client_data ~= nil and client_data == ArmorySystem.ENUM_REQ_Armory then
        --注加上0.01 是为了保证delayRefreshItems的timer先执行.因为咱们的timer的时间精度太低了,以及初始时间计算的有问题
        local rs = coroutine.resume(ArmoryUI.DelayNetCo)
        if not rs then
            log_error(debug.traceback(ArmoryUI.DelayNetCo))
        end
       --Timer.InsertTimer(0.1 + 0.01,DelayNetRefreshWeaponUIInfo,false,false);
    elseif client_data ~= nil and client_data == ArmorySystem.ENUM_REQ_Wardrobe then
        --处理仓库逻辑
         Timer.InsertTimer(0.1,DelayNetRefreshWarobeInfo,false,false);
    end  
    
end

function DelayNetRefreshWeaponUIInfo()
    log("ArmoryUI DelayNetRefreshWeaponUIInfo")
     --处理武器库逻辑,重建索引
        ArmorySystem.ContructResIdToWardrobeInsID();
        --重构前端数据结构
        ArmorySystem.ReBuildInitData(ArmorySystem.rsp_list);
        --更新皮肤菜单
        --ArmoryUI.UpdateSkinMenu();
        --首次打开军备库，展开涂装列表
        ArmoryUI.ShowWeaponSkinList();
end

function  DelayNetRefreshWarobeInfo()
    WardrobeSystem.OnGunSkinListRes();
end
--装备皮肤
function ArmorySystem.install_weapon_skin(client_data, weapon_id, instanceID)
    log("install_weapon_skin weapon_id "..weapon_id.." instanceID"..instanceID);

    if BP_Armory_MainType == ArmoryUI.MAIN_TYPE.WEAPON or client_data == ArmorySystem.ENUM_REQ_Wardrobe then 
        NetUtil.SendPriorityPkg(false, "install_weapon_skin_rsp", "install_weapon_skin", client_data, weapon_id, tonumber(instanceID));

    elseif BP_Armory_MainType == ArmoryUI.MAIN_TYPE.VEHICLE then
        WardrobeSystem.wardrobe_puton_req(instanceID)

    elseif BP_Armory_MainType == ArmoryUI.MAIN_TYPE.PLANE then
        WardrobeSystem.wardrobe_puton_req(instanceID)
    end
end

function ArmorySystem.install_weapon_skin_rsp(client_data, errorCode, weapon_id, instanceID)    
    log("install_weapon_skin_rsp weapon_id:"..tostring(weapon_id).."instanceID:"..tostring(instanceID));    
    if errorCode ~= 0 then
        --TODO,读取本地化表
        DataMgr.ShowNoticeByID(errorCode)
        return;
    end
    HallThemeUtils.ProcGunInstall(weapon_id, instanceID)
    
    if client_data ~= ArmorySystem.ENUM_REQ_ItemUpgrade then
        DataMgr.ShowNoticeByID(4464)
    end

    --处理数据
    if ArmorySystem.rsp_list.install_list == nil then
        ArmorySystem.rsp_list.install_list = {};
    end
    ArmorySystem.rsp_list.install_list[weapon_id] = {};
    ArmorySystem.rsp_list.install_list[weapon_id].skin_id = instanceID;    

    if weapon_id == DataMgr.Weapon_ID then
        DataMgr.InitWeaponData(weapon_id, instanceID);
    end

    if client_data ~= nil and client_data == ArmorySystem.ENUM_REQ_Armory then
        --处理武器库逻辑
        ArmoryUI.UpdateSecMenuUI();
        if weapon_id == DataMgr.Weapon_ID then
            WardrobeSystem.UpdateCurrentGunAvatar(weapon_id, instanceID);
        end
    elseif client_data ~= nil and client_data == ArmorySystem.ENUM_REQ_Wardrobe then
        --处理仓库逻辑
        WardrobeSystem.UpdateGunCount()
        WardrobeSystem.UpdateCurrentPutOnGunSkin(true);
    elseif client_data ~= nil and client_data == ArmorySystem.ENUM_REQ_ItemUpgrade then
        log("ArmorySystem.install_weapon_skin_rsp")
        WardrobeSystem.UpdateCurrentGunAvatar(weapon_id, instanceID);
    end  
     --TODO
    EventSystem:postEvent(EVENTTYPE_ARMORY, EVENTID_ARMORY_EQUIP_STAT_CHANGE);
end

--卸载皮肤
function ArmorySystem.uninstall_weapon_skin(client_data, weapon_id)
    log("uninstall_weapon_skin");
    
    if BP_Armory_MainType == ArmoryUI.MAIN_TYPE.WEAPON or client_data == ArmorySystem.ENUM_REQ_Wardrobe then 
        NetUtil.SendPriorityPkg(false, "uninstall_weapon_skin_rsp", "uninstall_weapon_skin", client_data, weapon_id);

    elseif BP_Armory_MainType == ArmoryUI.MAIN_TYPE.VEHICLE then
        local insID = ArmorySystem.GetWardrobeInsIdByResId(weapon_id)
        WardrobeSystem.wardrobe_puton_req(insID)

    elseif BP_Armory_MainType == ArmoryUI.MAIN_TYPE.PLANE then
        local insID = ArmorySystem.GetWardrobeInsIdByResId(weapon_id)
        WardrobeSystem.wardrobe_puton_req(weapon_id)
    end
end

function ArmorySystem.uninstall_weapon_skin_rsp(client_data, errorCode, weapon_id)
    log("uninstall_weapon_skin_rsp errorCode:"..tostring(errorCode).."weapon_id:"..tostring(weapon_id));    
    if errorCode ~= 0 then
        --TODO,读取本地化表
        DataMgr.ShowNoticeByID(errorCode)
        return;
    end
    HallThemeUtils.ProcGunUnInstall(weapon_id)
    
    if client_data ~= ArmorySystem.ENUM_REQ_ItemUpgrade then
        DataMgr.ShowNoticeByID(4465)
    end
    --处理数据,
    if ArmorySystem.rsp_list.install_list ~= nil then
        if  ArmorySystem.rsp_list.install_list[weapon_id] ~= nil then
            ArmorySystem.rsp_list.install_list[weapon_id].skin_id = 0;
        end
    end

    if weapon_id == DataMgr.Weapon_ID then
        DataMgr.InitWeaponData(weapon_id, 0);
    end

    if client_data ~= nil and client_data == ArmorySystem.ENUM_REQ_Armory then
        --处理武器库逻辑
        ArmoryUI.UpdateSecMenuUI();
        if weapon_id == DataMgr.Weapon_ID then
            WardrobeSystem.UpdateCurrentGunAvatar(weapon_id);
        end
    elseif client_data ~= nil and client_data == ArmorySystem.ENUM_REQ_Wardrobe then
        --处理仓库逻辑
        WardrobeSystem.UpdateGunCount()
        WardrobeSystem.UpdateCurrentPutOnGunSkin(true);
    elseif client_data ~= nil and client_data == ArmorySystem.ENUM_REQ_Other then
        WardrobeSystem.UpdateCurrentGunAvatar(weapon_id);
    end
    EventSystem:postEvent(EVENTTYPE_ARMORY, EVENTID_ARMORY_EQUIP_STAT_CHANGE);
end

--单独更新商品价格
function ArmorySystem.get_one_weapon_skin_shop_info(skin_res_id)
    log("get_one_weapon_skin_shop_info");
    NetUtil.SendPriorityPkg(false, "get_one_weapon_skin_shop_info_rsp", "get_one_weapon_skin_shop_info", skin_res_id);
end

function ArmorySystem.get_one_weapon_skin_shop_info_rsp(errorCode, shop_info, market_buy_info, market_detail, version)
    log("get_one_weapon_skin_shop_info_rsp errorCode:"..tostring(errorCode));    
    if errorCode ~= 0 then
        --TODO,读取本地化表
        DataMgr.ShowNoticeByID(errorCode)
        return;
    end
    --TODO更新价格
    --[[
    {[skin_res_id] = = {
        shop_id=shop_id, money_type=money_type, lowest_price=lowest_price
    }
    ]]
    -- log_tree("get_one_weapon_skin_shop_info_rsp", shop_info);
    if shop_info ~= nil then
        for k,v in pairs(shop_info) do
           local skinResId = tonumber(k);
           local shopInfo = v;
           --TEST
           --log_tree("get_one_weapon_skin_shop_info_rsp", shopInfo);
           -- shopInfo.lowest_price = 10;
           ArmorySystem.UpdateShopInfo(skinResId, shopInfo);
        end
    end
    MallBuyItemUI:Init();
    MallBuyItemUI.SetData(market_detail, market_buy_info or {daily_buy_cnt = 0; week_buy_cnt = 0; permanet_buy_cnt = 0;}, 0, 0, version);
end

function ArmorySystem.UpdateShopInfo(skinResID, shopInfo)
    if ArmorySystem.rsp_list.skin_list == nil then
        return;
    end
    local weaponResID = 0;
    local isFind = false;
    --处理后台的数据
    for k,v in pairs(ArmorySystem.rsp_list.skin_list) do
        local skinArray = v;
        for tk,tv in pairs(skinArray) do
            local curID = tk;       
            if  curID == skinResID then
                tv.shop_info = shopInfo;
                isFind = true;
                break;
            end         
        end
        weaponResID = k;
        if isFind == true then
            break;
        end
    end
    --log_tree("UpdateShopInfo", ArmorySystem.rsp_list.skin_list);

    --处理UI缓存的数据
    local skinData =  ArmorySystem.GetSkinArrayByWeaponID(weaponResID);
    if skinData ~= nil then  
        for k,v in pairs(skinData.SkinArray) do
            if skinResID == v.SkinID then
                v.ShopingID = shopInfo.shopid;
                v.MoneyType = shopInfo.money_type;
                v.Price = shopInfo.lowest_price;
                break;
            end
        end
    end
    ArmoryUI.UpdateSkinPrice();
end

--单独更新是否拥有皮肤，用于购买皮肤后刷新UI状态
function ArmorySystem.UpdateSkinHasOwner(weaponResID, skinResID)
    --log("UpdateSkinHasOwner:"..tostring(skinResID));
    local skinData =  ArmorySystem.GetSkinArrayByWeaponID(weaponResID);
    if skinData ~= nil then  
        for k,v in pairs(skinData.SkinArray) do
            if v.SkinID == skinResID then
                local insID = ArmorySystem.GetWardrobeInsIdByResId(skinResID);
                --log("UpdateSkinHasOwner:"..tostring(insID));
                if insID ~= nil then
                    local data = DataMgr.GetHallDepotItemDataByInsID(insID);
                    if data ~= nil then
                        --log_tree("UpdateSkinHasOwner data",data);
                        --用于协议通信
                        ArmorySystem.WardrobeInsList[skinResID] = insID;
                        v.HasOwner = true;
                        v.leftTime = data.expireTS; --为0表是永久
                        --v.Quality = data.itemQuality; --品质
                    end
                end            
            end           
        end
    end
end


--单独更新是否装备皮肤，用于装备/卸下皮肤后刷新UI状态
function ArmorySystem.UpdateSkinHasEquip(weaponResID, skinResID)
    --log("UpdateSkinHasOwner:"..tostring(skinResID));
    local skinData =  ArmorySystem.GetSkinArrayByWeaponID(weaponResID);
    if skinData == nil then  
        return;
    end

    local data = DataMgr.GetHallDepotItemDataByInsID(tostring(ArmorySystem.GetSkinIdByWeaponID(weaponResID)));
    for k,v in pairs(skinData.SkinArray) do
        if (data ~= nil) then
            v.HasEquip = data.resID == v.SkinID;
        else
            v.HasEquip = false;
        end
        -- end           
    end
end

--判断ak47有没皮肤
function ArmorySystem.CheckHasSkin(weaponId)
    return true
    -- local rsp_list = ArmorySystem.rsp_list;
    -- if (rsp_list == nil or rsp_list.skin_list == nil or rsp_list.skin_list[weaponId] == nil) then
    --     return false;
    -- end
    -- for _, v in pairs(rsp_list.skin_list[weaponId]) do
    --     if v.is_open == 1 then
    --         return true;
    --     end
    -- end
    -- return false;
end

-- 获取枪械皮肤列表
--c2s.get_weapon_skin_list(ss, client_data)
--ss.call("get_weapon_skin_list_rsp", client_data, 0, rsp_list);
s2c["get_weapon_skin_list_rsp"] = ArmorySystem.get_weapon_skin_list_rsp; --请求军备库武器皮肤
s2c["get_all_skin_list_rsp"] = ArmorySystem.get_weapon_skin_list_rsp
-- 安装枪械皮肤
--c2s.install_weapon_skin(ss, client_data, weapon_id, skin_id)
--ss.call("install_weapon_skin_rsp", client_data, 0, weapon_id, skin_id);   0 --成功  其他读本地化表
s2c["install_weapon_skin_rsp"] = ArmorySystem.install_weapon_skin_rsp;
-- 卸载枪械皮肤
--c2s.uninstall_weapon_skin(ss, client_data, weapon_id)
--ss.call("uninstall_weapon_skin_rsp", client_data, 0, weapon_id);  0 --成功  其他读本地化表
s2c["uninstall_weapon_skin_rsp"] = ArmorySystem.uninstall_weapon_skin_rsp;
--单独更新价格
--c2s.get_one_weapon_skin_shop_info(ss, skin_res_id)
--ss.call("get_one_weapon_skin_shop_info_rsp", 0, skin_res_id, shop_info);
s2c["get_one_weapon_skin_shop_info_rsp"] = ArmorySystem.get_one_weapon_skin_shop_info_rsp;
