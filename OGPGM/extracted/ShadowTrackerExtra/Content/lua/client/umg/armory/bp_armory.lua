-- 武器库主UI
ArmoryUI = ArmoryUI or 
{
    --军备库展示总数据
    TotalData = 
    {
    --[[ 
        [WeaponType] = {    
            WeaponType = 0,
            WeaponDatas= 
            {
                [1] ={
                    WeaponID = 0,
                    WeaponType = 0,
                    WeaponName = "",
                    WeaponShortName ="",
                    WeaponIconUrl = "",
                    IsSelect = 0,   
                    WeaponDesc = "", --武器描述
                    BulletID = 0, --子弹ID
                    BulletName = "", --子弹名字
                    BulletUrl = "", --子弹图标路径
                    BulletDesc = "", --子弹描述                                         
                    ShortHandDatas = 
                    {
                        [1] = 
                        {
                            ShortHandType = 0,--配件类型，1是瞄具 2枪口 3弹夹 4握把 5枪托，0默认没有
                            IsSelect = 0, --是否选中
                            ShortHandID = 0,
                            ShortHandName = "",
                            ShortHandUrl = "",
                            ShortHandDesc = "",     
                        }   
                    }
                    AttrDatas = 
                    {
                        [1] =
                        {
                            AttrType = 0, --1 威力、2稳定性、3射速、4弹夹容量 5准确性
                            AttrName = "", --名称
                            AttrValue = "", --当前属性对应的值
                            AttrMaxValue = 100, --最大值
                        }                       .
                    }
                
                }
            }   
         }
    ]] 
    },    
    --只存储武器分类数据
    WeaponClassData = 
    {
        --[[
        [1] ={
            WeaponDatas = 
            {
                [WeaponID] ={
                    WeaponID = 0,
                }
            }
        }
        ]]
    },
 
    LastShortHandID = 0,

    --存储当前配件装备，一个类型只能装备一个配件
    EquipShortHandData = 
    {
        --[[
        [ShortHandType] = 
        {
            ShortHandType = ,--配件类型，1是瞄具 2枪口 3弹夹 4握把 5枪托，0默认没有,6皮肤
            ShortHandID = ， --配件ID
            ShortHandUrl = ""
        }
        ]]
    },

    --配件属性叠加
    ExtAttrOverlay = 
    {
        --[[
        Power = ""
        ShotRange="", 
        ReloadSpeed="", 
        VerticalRecoil="0.8", 
        HorizontalRecoil="0.75", 
        Shake="",
        ]] 
    },
    
    isShow = false,

    DelayNetCo = nil,
}
--一级菜单数据结构
BP_STRUCT_Weapon_FirstMenu = 
{
    WeaponType = 0, --武器类型
    TypeName = "", --类型名称
    IconUrl = "", --图标路径
    IsSelect = 0, --是否选中
    RedPoint = false;
}
BP_ARRAY_Weapon_FirstMenuData = 
{
    BP_STRUCT_Weapon_FirstMenu = _G.BP_STRUCT_Weapon_FirstMenu,
}

--二级菜单数据结构
BP_STRUCT_Weapon_SecMenu = 
{
    WeaponID = 0, --武器ID
    WeaponType = 0, --武器类型
    WeaponName = "", --武器名称
    WeaponShortName = "", --武器简写
    WeaponIconUrl = "", 
    IsSelect = 0,
    RedPoint = false;
    SkinQuality = 0; --装后皮肤的品质
}
BP_ARRAY_Weapon_SecMenuData = 
{
    BP_STRUCT_Weapon_SecMenu = _G.BP_STRUCT_Weapon_SecMenu,
}

--枪配件菜单
BP_STRUCT_ShortHand_Menu =
{
    ShortHandType = 0, --配件类型，1是瞄具 2枪口 3弹夹 4握把 5枪托，0默认没有
    IsSelect = 0, --是否选中
    RedPoint = false;
    SkinIconUrl = ""; --主要用于皮肤
}
BP_ARRAY_ShortHand_MenuData = 
{
    BP_STRUCT_ShortHand_Menu = _G.BP_STRUCT_ShortHand_Menu,
}

--配件
BP_STRUCT_ShortHand = 
{
    ShortHandType = 0,--配件类型，1是瞄具 2枪口 3弹夹 4握把 5枪托，0默认没有
    IsSelect = 0, --是否选中
    ShortHandID = 0,
    ShortHandName = "",
    ShortHandUrl = "",
    ShortHandDesc = "",
}
BP_ARRAY_ShortHandData = 
{
    BP_STRUCT_ShortHand = _G.BP_STRUCT_ShortHand,
}
--当前武器装备所有配件数据
BP_ARRAY_CurrentShortHandEquip = 
{
    BP_STRUCT_ShortHand = _G.BP_STRUCT_ShortHand,
}

--武器属性
BP_STRUCT_WeaponAttr =
{
    AttrType = 0, --1 威力、2稳定性、3射速、4弹夹容量 5准确性
    AttrName = "", --名称
    AttrValue = "", --当前属性对应的值 
    AttrValueBase = "", --基本值
    AttrMaxValue = 100, --最大值
}
BP_ARRAY_WeaponAttrData = 
{
    BP_STRUCT_WeaponAttr = _G.BP_STRUCT_WeaponAttr,
}

--武器显示详情
BP_STRUCT_WeaponDetailInfo = 
{
    WeaponResID = 0, --武器资源ID
    WeaponName = "", --武器名字
    WeaponDesc = "", --武器描述
    BulletID = 0, --子弹ID
    BulletName = "", --子弹名字
    BulletUrl = "", --子弹图标路径
    BulletDesc = "", --子弹描述
}

BP_Armory_MainType = 0
BP_Current_WeaponType = 0;--选中的武器类型
BP_Current_WeaponID = 0;--选中的武器ID
BP_Current_ShortHandType = 0;--选中的武器配件类型
BP_Current_ShortHandID = 0; --选中配件的ID
--BP_IsPutOnEquipMent = true; --是否穿上配件
BP_Current_SelectSkinID = 0; --选中的皮肤ID
BP_Last_SelectSkinID = 0; --上一次选中的皮肤ID

BP_Armory_Isopen = 1;


--********************************皮肤**************
BP_STRUCT_WeaponSkinInfo = 
{

    SkinID = 0,
    ShopingID = 0,
    IsOpen = true; --是否开启
    HasEquip = false; --是否装备上
    HasOwner = false; --是否拥有

    WeaponID = 0, --武器ID
    WeaponType = 0, --武器类型
    ShortHandType = 0, --6皮肤
    MoneyType = 0, --货币类型   
    Price = 0, --价格  

    SkinUrl = "",
    SkinDesc = "",   
    SkinDetailDesc = "",
    SkinName = "",
    IsRedPoint = false,
    IsSelect = 0, --是否选中

    leftTime = ""; --剩余时间
    Quality = 0;  --品质
}
BP_ARRAY_WeaponSkinData = 
{
    BP_STRUCT_WeaponSkinInfo = _G.BP_STRUCT_WeaponSkinInfo,
}

BP_Armory_Market_Gold = "";
BP_Armory_Market_Diamond = "";
BP_Armory_Market_Ticket = "";
BP_Armory_Market_GoldChip = "";
Armory_Type_Config = {};

BP_ARRAY_Armory_ThirdTypeStr = {""}

--注册Widget
function bp_armory_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_armory,
        {{Path="/Game/UMG/UI_Logic/Armory/Armory_Logic_BP.Armory_Logic_BP_C", Container="Default", ZOrder=0}
        -- {Path="/Game/UMG/UI_BP/Lobby/Lobby_AvatarAnim_UIBP.Lobby_AvatarAnim_UIBP_C", Container="Default", ZOrder=9999}
        },
        {"Lobby"},
        false,
        true,
        true
    );
end

function bp_armory_OnModeSwitched(gamestatus)
    log("bp_armory_OnModeSwitched gamestatus = " .. gamestatus .. ",BP_Armory_Isopen = " .. BP_Armory_Isopen);
    status = string.lower(gamestatus);
    if status == "lobby" then
        ArmoryUI.InitData();
        if BP_Armory_Isopen == 0 then
        LuaClassObj.HandleDynamicCreation(bp_armory);
        BP_Armory_Isopen = 1;
        end
    else
        ArmoryUI.TotalData = nil;
        ArmoryUI.WeaponClassData = nil;
        ArmoryUI.TotalVehicleData = nil;
        ArmoryUI.VehicleClassData = nil;
        ArmoryUI.TotalPlaneData = nil;
        ArmoryUI.PlaneClassData = nil;
        if BP_Armory_Isopen == 1 then
            BP_Armory_Isopen = 0
            ArmoryUI.isShow = false
            LuaClassObj.HandleUIMessageNoFetch(bp_armory, "UIHide");
            EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE, SceneType.Armory)
        end
    end
end

function ArmoryUI.OnDiamondChange()
    if  ArmoryUI.isShow == true then 
        BP_Armory_Market_Diamond = FuncUtil:FormatMoney(DataMgr.diamond)
        LuaClassObj.HandleUIMessage(bp_armory, "UpdateDiamond");
    end

end

function ArmoryUI.OnTicketChange()
    if  ArmoryUI.isShow == true then 
        BP_Armory_Market_Ticket = FuncUtil:FormatMoney(DataMgr.ticket)
        LuaClassObj.HandleUIMessage(bp_armory, "UpdateTicket");
    end   
end

function ArmoryUI.OnGoldChange()
    if  ArmoryUI.isShow == true then 
        BP_Armory_Market_Gold = FuncUtil:FormatMoney(DataMgr.gold)
        LuaClassObj.HandleUIMessage(bp_armory, "UpdateGold");
    end

end

function ArmoryUI.OnGoldChipChange()
    if  ArmoryUI.isShow == true then
        BP_Armory_Market_GoldChip = FuncUtil:FormatMoney(DataMgr.gold_chip)
        LuaClassObj.HandleUIMessageNoFetch(bp_armory, "UpdateGoldChip");
    end
end

function ArmoryUI.RegistEvent()
    EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_DIAMOND_CHANGE, ArmoryUI.OnDiamondChange);
    EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_TICKET_CHANGE, ArmoryUI.OnTicketChange);
    EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_GOLD_CHANGE, ArmoryUI.OnGoldChange);
    EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_GOLD_CHIP_CHANGE, ArmoryUI.OnGoldChipChange);
    --用于购买后解锁
    EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_DATA_CHANGE, ArmoryUI.UpdateSkinForBuySucess)
    EventSystem:registEvent(EVENTTYPE_ARMORY, EVENTID_ARMORY_EQUIP_STAT_CHANGE, ArmoryUI.UpdateSkinEquipState)
    -- EventSystem:registEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_SYNC, ArmoryUI.OnTeamInfoChange);    
end

function ArmoryUI.Release()
    EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_DIAMOND_CHANGE, ArmoryUI.OnDiamondChange);
    EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_TICKET_CHANGE, ArmoryUI.OnTicketChange);    
    EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_GOLD_CHANGE, ArmoryUI.OnGoldChange);
    EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_GOLD_CHIP_CHANGE, ArmoryUI.OnGoldChipChange);
    EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_DATA_CHANGE, ArmoryUI.UpdateSkinForBuySucess)  
    EventSystem:unregistEvent(EVENTTYPE_ARMORY, EVENTID_ARMORY_EQUIP_STAT_CHANGE, ArmoryUI.UpdateSkinEquipState)
    -- EventSystem:unregistEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_SYNC, ArmoryUI.OnTeamInfoChange);    
end

function ArmoryUI.OnTeamInfoChange()
    log("[HHF]ArmoryUI.OnTeamInfoChange, close self.");
    LuaClassObj.HandleUIMessage(bp_armory, "OnClickBtnClose");
end

ArmoryUI.MAIN_TYPE = {}
ArmoryUI.MAIN_TYPE.WEAPON = 1
ArmoryUI.MAIN_TYPE.VEHICLE = 2
ArmoryUI.MAIN_TYPE.PLANE = 3
ArmoryUI.LAST_REQ_MALL_TIME = 0
local timerCacheFunc = nil;
local delayRefreshItems = nil;
--显示过场动画和切镜头
function ArmoryUI:OpenArmoryMainUI()
    local curTime = os.time()
    -- 每隔5分钟重新请求一次商店简约数据
    if curTime - ArmoryUI.LAST_REQ_MALL_TIME > 300 then
        MallSystem.GetMallAllItemsSimpleInfo()
        ArmoryUI.LAST_REQ_MALL_TIME = curTime
    end

    log("OpenArmoryMainUI BP_Armory_Isopen = " .. BP_Armory_Isopen)
    --if BP_Armory_Isopen == 0 then
    LuaClassObj.HandleDynamicCreation(bp_armory);
        --BP_Armory_Isopen = 1;
    --end
    BP_Armory_Market_Diamond = FuncUtil:FormatMoney(DataMgr.diamond);
    BP_Armory_Market_Ticket = FuncUtil:FormatMoney(DataMgr.ticket);
    BP_Armory_Market_Gold = FuncUtil:FormatMoney(DataMgr.gold);
    BP_Armory_Market_GoldChip = FuncUtil:FormatMoney(DataMgr.gold_chip);
    ArmoryUI.RegistEvent();    
    BP_Armory_MainType = ArmoryUI.MAIN_TYPE.WEAPON
    WeaponModelHandler:Init();
    WeaponModelHandler:SwitchToArmoryMainCamera();
    EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN, SceneType.Armory)
    -- LuaClassObj.HandleUIMessageNoFetch(bp_armory, "UIShowFromArmory");
    BP_Current_WeaponType = 1;    
    ArmoryUI.isShow = true;
    --每次打开面板请求数据
    local time_ticker = require("client.time_ticker")
    time_ticker.AddTimer(0.1, DelayShowWeaponUI)
end

function DelayShowWeaponUI()
    log("ArmoryUI DelayShowWeaponUI")
    --BP_Armory_Isopen = 1
    EventFadeIn();
    LuaClassObj.HandleUIMessageNoFetch(bp_armory, "UIShow");
    BP_ARRAY_Armory_ThirdTypeStr = {}
    --EventArmoryOpenArmoryMainUIEnter();
    local tempTable = {}
    --local armoryTypeCfgTable = Client.GetTable("ArmoryTypeConfig");
    for k,v in pairs(Armory_Type_Config) do
        table.insert(tempTable, v);
    end

    table.sort(tempTable, function(a, b)
        return a.TypeID < b.TypeID;
    end);

    for i,v in ipairs(tempTable) do
        table.insert(BP_ARRAY_Armory_ThirdTypeStr, v.TypeName);
    end
    LuaClassObj.HandleUIMessageNoFetch(bp_armory, "initCombox");

    ArmoryUI.DelayNetCo = coroutine.create(function()
        ArmoryUI.ResetIDForClickFirstMenu();
        ArmorySystem.get_weapon_skin_list(ArmorySystem.ENUM_REQ_Armory);
        coroutine.yield()
        DelayNetRefreshWeaponUIInfo()
    end)

    local rs = coroutine.resume(ArmoryUI.DelayNetCo)
    if not rs then
        log_error(debug.traceback(ArmoryUI.DelayNetCo))
    end

end

function DelayShowWeaponSkinList()    
    --EventArmoryOpenArmoryMainUIEnter();
    ArmoryUI.ResetIDForClickFirstMenu();
end
--显示进场动画和UI
function EventArmoryOpenArmoryMainUIEnter()
    --BP_Current_WeaponID = 101001;--
    --BP_Current_ShortHandType = 1;-- 
    --ArmoryUI.InitData();
    ArmoryUI.UpdateUI(true);
    -- LuaClassObj.HandleUIMessageNoFetch(bp_fade, "UIShowFadeIn");
end

--初始化数据
function ArmoryUI.InitData()
    log("ArmoryUI.InitData");
    ArmoryUI.TotalData = {};
    ArmoryUI.WeaponClassData = {};
    --初始化军备库展示数据  
    -- nanneli csv 
    local Armory_Config = Client.GetTable("ArmoryConfig")      
    -- for k,v in pairs(BP_ARRAY_ArmoryConfig) do
    for k,v in pairs(Armory_Config) do     
        if v.IsShow > 0 then
            local itemTable = {};
            if ArmoryUI.WeaponClassData[v.WeaponType] == nil then
                ArmoryUI.WeaponClassData[v.WeaponType] = {};
            end   
            itemTable.WeaponID = v.WeaponID;
            itemTable.BulletID = v.BulletID;
            itemTable.WeaponType = v.WeaponType;
            itemTable.WeaponName = v.WeaponName;
            table.insert(ArmoryUI.WeaponClassData[v.WeaponType],itemTable);  
        end

    end 
    

    --log_tree("ArmoryUIWeaponClassData", ArmoryUI.WeaponClassData);  
    --初始化武器类型数据
    -- nanneli csv 
    Armory_Type_Config = Client.GetTable("ArmoryTypeConfig") 
    -- for k,v in pairs(BP_ARRAY_ArmoryTypeConfig) do
    for k,v in pairs(Armory_Type_Config) do   
        ArmoryUI.TotalData[v.TypeID] = {};
        ArmoryUI.TotalData[v.TypeID].WeaponType = v.TypeID;
        ArmoryUI.TotalData[v.TypeID].WeaponDatas = {};
        local weaponData = ArmoryUI.GetWeaponDataByWeaponType(v.TypeID);
        --log_tree("weaponData",weaponData);
        for tk,tv in pairs(weaponData) do     
            local weaponCfg  = Client.GetTableData("Item",tv.WeaponID);
            --log("weaponCfg"..tostring(tv.WeaponID)..tostring(weaponCfg));
            local bulletCfg  = Client.GetTableData("Item",tv.BulletID);
            --log("bulletCfg"..tostring(tv.BulletID)..tostring(bulletCfg));
            local newData = {};
            newData.WeaponID = tv.WeaponID;
            newData.WeaponType = tv.WeaponType;
            newData.WeaponName = tv.WeaponName;
            newData.IsSelect = 0;   
            newData.WeaponShortName ="";
            newData.WeaponIconUrl = "";           
            newData.WeaponDesc = ""; --武器描述
            if weaponCfg ~= nil then
                newData.WeaponShortName = weaponCfg.ArmorySimpleDesc;
                newData.WeaponIconUrl = weaponCfg.ItemSmallIcon;    
                newData.WeaponDesc = weaponCfg.ArmoryDesc;           
            end
            newData.BulletID = tv.BulletID; --子弹ID
            newData.BulletName = ""; --子弹名字
            newData.BulletUrl = ""; --子弹图标路径
            newData.BulletDesc = ""; --子弹描述
            if bulletCfg ~= nil then
                newData.BulletName = bulletCfg.ItemName; --子弹名字
                newData.BulletUrl = bulletCfg.ItemSmallIcon; --子弹图标路径
                newData.BulletDesc = bulletCfg.ArmoryDesc; --子弹描述         
            end
            newData.ShortHandDatas = ArmoryUI.GetShortHandDatas(tv.WeaponID);     
            newData.AttrDatas = ArmoryUI.GetAttrDatas(tv.WeaponID);
            table.insert(ArmoryUI.TotalData[v.TypeID].WeaponDatas, newData);
        end
        --table.insert(ArmoryUI.TotalData, weaponType);
    end   
    --log_tree("ArmoryUITotalData", ArmoryUI.TotalData);

    --初始化皮肤数据TEST
    --ArmorySystem.ReBuildInitData();

    ArmoryUI.InitVehicleData()
    ArmoryUI.InitPlaneData()
end

--初始化载具数据
function ArmoryUI.InitVehicleData()
    log("ArmoryUI.InitVehicleData");
    ArmoryUI.TotalVehicleData = {};
    ArmoryUI.VehicleClassData = {};

    local configs = Client.GetTable("ArmoryVehicleConfig")      
    for k,v in pairs(configs) do     
        local itemTable = {};
        if ArmoryUI.VehicleClassData[v.Type] == nil then
            ArmoryUI.VehicleClassData[v.Type] = {};
        end   
        itemTable.WeaponID = v.ID;
        itemTable.BulletID = 0;
        itemTable.WeaponType = v.Type;
        itemTable.WeaponName = v.Name;
        table.insert(ArmoryUI.VehicleClassData[v.Type],itemTable);  
    end 

    local VehicleTypeConfig = Client.GetTable("VehicleTypeConfig") 
    -- for k,v in pairs(BP_ARRAY_ArmoryTypeConfig) do
    for k,v in pairs(VehicleTypeConfig) do
        local data = {}
        local typeID = v.TypeID

        -- ArmoryUI.TotalData[v.TypeID] = {};
        data.WeaponType = typeID;
        data.WeaponDatas = {};

        local weaponData = ArmoryUI.GetVehicleDataByWeaponType(typeID);
        --log_tree("weaponData",weaponData);
        for tk,tv in pairs(weaponData) do     
            local weaponCfg  = Client.GetTableData("Item",tv.WeaponID);
            -- local bulletCfg  = Client.GetTableData("Item",tv.BulletID);
            --log("bulletCfg"..tostring(tv.BulletID)..tostring(bulletCfg));
            local newData = {};
            newData.WeaponID = tv.WeaponID;
            newData.WeaponType = tv.WeaponType;
            newData.WeaponName = tv.WeaponName;
            newData.IsSelect = 0;   
            newData.WeaponShortName ="";
            newData.WeaponIconUrl = "";           
            newData.WeaponDesc = ""; --武器描述
            if weaponCfg ~= nil then
                newData.WeaponShortName = weaponCfg.ItemName;
                newData.WeaponIconUrl = weaponCfg.ItemSmallIcon;    
                newData.WeaponDesc = weaponCfg.ItemDesc;           
            end
            newData.BulletID = tv.BulletID; --子弹ID
            newData.BulletName = ""; --子弹名字
            newData.BulletUrl = ""; --子弹图标路径
            newData.BulletDesc = ""; --子弹描述
            -- if bulletCfg ~= nil then
            --     newData.BulletName = bulletCfg.ItemName; --子弹名字
            --     newData.BulletUrl = bulletCfg.ItemSmallIcon; --子弹图标路径
            --     newData.BulletDesc = bulletCfg.ArmoryDesc; --子弹描述         
            -- end
            newData.ShortHandDatas = {}     
            newData.AttrDatas = {}
            table.insert(data.WeaponDatas, newData);
        end
        ArmoryUI.TotalVehicleData[typeID] = data
        --table.insert(ArmoryUI.TotalData, weaponType);
    end  

    -- log_tree("TotalVehicleData", ArmoryUI.TotalVehicleData);

    --初始化皮肤数据TEST
    --ArmorySystem.ReBuildInitData();
end

--初始化飞机数据
function ArmoryUI.InitPlaneData()
    log("ArmoryUI.InitPlaneData");
    ArmoryUI.TotalPlaneData = {};
    ArmoryUI.PlaneClassData = {};

    local configs = Client.GetTable("ArmoryPlaneConfig")      
    for k,v in pairs(configs) do     
        local itemTable = {};
        if ArmoryUI.PlaneClassData[v.Type] == nil then
            ArmoryUI.PlaneClassData[v.Type] = {};
        end   
        itemTable.WeaponID = v.ID;
        itemTable.BulletID = 0;
        itemTable.WeaponType = v.Type;
        itemTable.WeaponName = v.Name;
        table.insert(ArmoryUI.PlaneClassData[v.Type],itemTable);
    end 

    local PlaneTypeConfig = Client.GetTable("PlaneTypeConfig") 
    -- for k,v in pairs(BP_ARRAY_ArmoryTypeConfig) do
    for k,v in pairs(PlaneTypeConfig) do
        local data = {}
        local typeID = v.TypeID

        -- ArmoryUI.TotalData[v.TypeID] = {};
        data.WeaponType = typeID;
        data.WeaponDatas = {};

        local weaponData = ArmoryUI.GetPlaneDataByWeaponType(typeID);
        --log_tree("weaponData",weaponData);
        for tk,tv in pairs(weaponData) do     
            local weaponCfg  = Client.GetTableData("Item",tv.WeaponID);
            -- local bulletCfg  = Client.GetTableData("Item",tv.BulletID);
            --log("bulletCfg"..tostring(tv.BulletID)..tostring(bulletCfg));
            local newData = {};
            newData.WeaponID = tv.WeaponID;
            newData.WeaponType = tv.WeaponType;
            newData.WeaponName = tv.WeaponName;
            newData.IsSelect = 0;   
            newData.WeaponShortName ="";
            newData.WeaponIconUrl = "";           
            newData.WeaponDesc = ""; --武器描述
            if weaponCfg ~= nil then
                newData.WeaponShortName = weaponCfg.ItemName;
                newData.WeaponIconUrl = weaponCfg.ItemSmallIcon;    
                newData.WeaponDesc = weaponCfg.ItemDesc;           
            end
            newData.BulletID = tv.BulletID; --子弹ID
            newData.BulletName = ""; --子弹名字
            newData.BulletUrl = ""; --子弹图标路径
            newData.BulletDesc = ""; --子弹描述
            -- if bulletCfg ~= nil then
            --     newData.BulletName = bulletCfg.ItemName; --子弹名字
            --     newData.BulletUrl = bulletCfg.ItemSmallIcon; --子弹图标路径
            --     newData.BulletDesc = bulletCfg.ArmoryDesc; --子弹描述         
            -- end
            newData.ShortHandDatas = {}     
            newData.AttrDatas = {}
            table.insert(data.WeaponDatas, newData);
        end
        ArmoryUI.TotalPlaneData[typeID] = data
        --table.insert(ArmoryUI.TotalData, weaponType);
    end  

    -- log_tree("TotalPlaneData", ArmoryUI.TotalPlaneData);

    --初始化皮肤数据TEST
    --ArmorySystem.ReBuildInitData();
end


--更新UI(needRefreshWeaponModel是否需要刷新武器模型)
function ArmoryUI.UpdateUI(needRefreshWeaponModel)
    ArmoryUI.ProcessFirstMenu();
    ArmoryUI.UpdateSecMenu(needRefreshWeaponModel);
    ArmoryUI.UpdateShortHandMenu();    
    ArmoryUI.UpdateWeaponAttrData();
    ArmoryUI.UpdateWeaponDetailInfo();   
    ArmoryUI.UpdateShortHandData();
    --TODO更新UI
    LuaClassObj.HandleUIMessageNoFetch(bp_armory, "UpdateUI");
end

--只更新二级菜单的UI
function ArmoryUI.UpdateSecMenuUI()
    ArmoryUI.UpdateSecMenu();
    LuaClassObj.HandleUIMessageNoFetch(bp_armory, "UpdateSecMenu");

    --更新配件菜单
    ArmoryUI.UpdateShortHandMenu();
    LuaClassObj.HandleUIMessageNoFetch(bp_armory, "UpdateShorHandMenu");   
end

--只更新皮肤菜单
function ArmoryUI.UpdateSkinMenu()
    ArmoryUI.UpdateUI();
    --ArmoryUI.UpdateShortHandMenu();  
    --LuaClassObj.HandleUIMessageNoFetch(bp_armory, "UpdateShorHandMenu");
end

--武器属性
function ArmoryUI.GetAttrDatas(weaponID)
    --log("GetAttrDatasCfg"..weaponID);
    local datas = {};
    local cfg = Client.GetTableData("ArmoryConfig", weaponID);
    --log_tree("GetAttrDatasCfg", cfg);
    if cfg ~= nil then
        --AttrType = 0, --1 威力、2有效射程、3稳定性、4射速 5弹夹容量
        --AttrName = "", --名称
        --AttrValue = 0, --当前属性对应的值
        --AttrMaxValue = 100, --最大值    
        if cfg.Power ~= "" then
            local tmpData = {};
            tmpData.AttrType = 1;
            tmpData.AttrName = Client.GetTableData("LocalizeRes",5055).TextValue
            tmpData.AttrValue = cfg.Power;
            tmpData.AttrMaxValue = 110;
            table.insert(datas,tmpData);
        end

        if cfg.ShotRange ~= "" then
            local tmpData = {};
            tmpData.AttrType = 2;
            tmpData.AttrName = Client.GetTableData("LocalizeRes",5056).TextValue
            tmpData.AttrValue = cfg.ShotRange;
            tmpData.AttrMaxValue = 600;
            table.insert(datas,tmpData);
        end

        if cfg.VerticalRecoil ~= "" or cfg.HorizontalRecoil ~= "" or cfg.Shake ~= "" then

            local VerticalRecoil = 0;
            local Horizontal = 0;
            local Shake = 0;
            if cfg.VerticalRecoil ~= "" then 
                VerticalRecoil = cfg.VerticalRecoil;
            end
            if cfg.HorizontalRecoil ~= "" then 
                Horizontal = cfg.HorizontalRecoil;
            end
            if cfg.Shake ~= "" then 
                Shake = cfg.Shake;
            end
            local tmpData = {};
            tmpData.AttrType = 3;
            tmpData.AttrName = Client.GetTableData("LocalizeRes",5057).TextValue
            tmpData.AttrValue = VerticalRecoil + Horizontal + Shake; --稳定性：垂直后坐力+水平后坐力+画面抖动   范围0-5
            tmpData.AttrMaxValue = 5;
            table.insert(datas,tmpData);
        end

        if cfg.ShootInterval ~= "" then
            local ReloadSpeed = 0;
            local ClipCapacity = 1;
            if cfg.ReloadSpeed ~= "" then
                ReloadSpeed = cfg.ReloadSpeed;
            end
            if cfg.ClipCapacity ~= "" then
                ClipCapacity = cfg.ClipCapacity;
            end

            local tmpData = {};
            tmpData.AttrType = 4;
            tmpData.AttrName = Client.GetTableData("LocalizeRes",5058).TextValue
            tmpData.AttrValue = 60 / (cfg.ShootInterval + (ReloadSpeed / ClipCapacity));--射速：60/[射击间隔+(换弹速度/当前弹容量)]  范围0-500
            tmpData.AttrMaxValue = 500;
            table.insert(datas,tmpData);
        end

        if cfg.ClipCapacity ~= "" then
            local tmpData = {};
            tmpData.AttrType = 5;
            tmpData.AttrName = Client.GetTableData("LocalizeRes",5059).TextValue
            tmpData.AttrValue = cfg.ClipCapacity;
            tmpData.AttrMaxValue = 100;
            table.insert(datas,tmpData);
        end 
    end
    --log_tree("ArmoryUIGetAttrDatas",datas);
    return datas;
end

function ArmoryUI.BuildShortHandItemData(type, itemID)
    local tmpData = {};
    tmpData.ShortHandType = type;
    tmpData.IsSelect = 0; --是否选中
    tmpData.ShortHandID = itemID;
    tmpData.ShortHandName = "";
    tmpData.ShortHandUrl = "";
    tmpData.ShortHandDesc = "";	
    local handCfg = Client.GetTableData("Item", itemID);
    if handCfg ~= nil then
        tmpData.ShortHandName = handCfg.ArmorySimpleDesc;
        tmpData.ShortHandUrl = handCfg.ItemSmallIcon;
        tmpData.ShortHandDesc = handCfg.ArmoryDesc;	                
    end
    return tmpData;
end

--武器配件
function ArmoryUI.GetShortHandDatas(weaponID)
    local cfg = Client.GetTableData("WeaponAttachments", weaponID);
    local datas = {};
    if cfg ~= nil then
        -- log_tree("=====cfg:", cfg)
        --1是瞄具 2枪口 3弹夹 4握把 5枪托，0默认没有
       if cfg.Muzzle1ID ~= 0 then --2枪口
            local Muzzle = {};
            local tmpData = {};
            tmpData.ShortHandType = 2;
            tmpData.IsSelect = 0; --是否选中
            tmpData.ShortHandID = cfg.Muzzle1ID;
            tmpData.ShortHandName = "";
            tmpData.ShortHandUrl = "";
            tmpData.ShortHandDesc = ""; 
            local handCfg = Client.GetTableData("Item", cfg.Muzzle1ID);
            if handCfg ~= nil then
                tmpData.ShortHandName = handCfg.ArmorySimpleDesc;
                tmpData.ShortHandUrl = handCfg.ItemSmallIcon;
                tmpData.ShortHandDesc = handCfg.ArmoryDesc;                 
            end

            table.insert(Muzzle,tmpData);
            if cfg.Muzzle2ID ~= 0 then
                local tmpData1 = {};
                tmpData1.ShortHandType = 2;
                tmpData1.IsSelect = 0; --是否选中
                tmpData1.ShortHandID = cfg.Muzzle2ID;
                tmpData1.ShortHandName = "";
                tmpData1.ShortHandUrl = "";
                tmpData1.ShortHandDesc = "";    
                local handCfg = Client.GetTableData("Item", cfg.Muzzle2ID);
                if handCfg ~= nil then
                    tmpData1.ShortHandName = handCfg.ArmorySimpleDesc;
                    tmpData1.ShortHandUrl = handCfg.ItemSmallIcon;
                    tmpData1.ShortHandDesc = handCfg.ArmoryDesc;                    
                end

                table.insert(Muzzle,tmpData1);
            end
            if cfg.Muzzle3ID ~= 0 then
                local tmpData2 = {};
                tmpData2.ShortHandType = 2;
                tmpData2.IsSelect = 0; --是否选中
                tmpData2.ShortHandID = cfg.Muzzle3ID;
                tmpData2.ShortHandName = "";
                tmpData2.ShortHandUrl = "";
                tmpData2.ShortHandDesc = "";    
                local handCfg = Client.GetTableData("Item", cfg.Muzzle3ID);
                if handCfg ~= nil then
                    tmpData2.ShortHandName = handCfg.ArmorySimpleDesc;
                    tmpData2.ShortHandUrl = handCfg.ItemSmallIcon;
                    tmpData2.ShortHandDesc = handCfg.ArmoryDesc;                    
                end

                table.insert(Muzzle,tmpData2);
            end

            if cfg.Muzzle4ID ~= 0 then
                local tmpData3 = {};
                tmpData3.ShortHandType = 2;
                tmpData3.IsSelect = 0; --是否选中
                tmpData3.ShortHandID = cfg.Muzzle4ID;
                tmpData3.ShortHandName = "";
                tmpData3.ShortHandUrl = "";
                tmpData3.ShortHandDesc = "";    
                local handCfg = Client.GetTableData("Item", cfg.Muzzle4ID);
                if handCfg ~= nil then
                    tmpData3.ShortHandName = handCfg.ArmorySimpleDesc;
                    tmpData3.ShortHandUrl = handCfg.ItemSmallIcon;
                    tmpData3.ShortHandDesc = handCfg.ArmoryDesc;                    
                end
                table.insert(Muzzle,tmpData3);
            end

            if cfg.Muzzle5ID ~= 0 then
                local tmpData4 = {};
                tmpData4.ShortHandType = 2;
                tmpData4.IsSelect = 0; --是否选中
                tmpData4.ShortHandID = cfg.Muzzle5ID;
                tmpData4.ShortHandName = "";
                tmpData4.ShortHandUrl = "";
                tmpData4.ShortHandDesc = "";    
                local handCfg = Client.GetTableData("Item", cfg.Muzzle5ID);
                if handCfg ~= nil then
                    tmpData4.ShortHandName = handCfg.ArmorySimpleDesc;
                    tmpData4.ShortHandUrl = handCfg.ItemSmallIcon;
                    tmpData4.ShortHandDesc = handCfg.ArmoryDesc;                    
                end
                table.insert(Muzzle,tmpData4);
            end

            if cfg.Muzzle6ID ~= 0 then
                local tmpData5 = {};
                tmpData5.ShortHandType = 2;
                tmpData5.IsSelect = 0; --是否选中
                tmpData5.ShortHandID = cfg.Muzzle6ID;
                tmpData5.ShortHandName = "";
                tmpData5.ShortHandUrl = "";
                tmpData5.ShortHandDesc = "";    
                local handCfg = Client.GetTableData("Item", cfg.Muzzle6ID);
                if handCfg ~= nil then
                    tmpData5.ShortHandName = handCfg.ArmorySimpleDesc;
                    tmpData5.ShortHandUrl = handCfg.ItemSmallIcon;
                    tmpData5.ShortHandDesc = handCfg.ArmoryDesc;                    
                end
                table.insert(Muzzle,tmpData5);
            end
            table.insert(datas,Muzzle);
       end  
       

       if cfg.Upper1ID ~= 0 then --1瞄准镜
            local Upper = {};
            local tmpData = {};
            tmpData.ShortHandType = 1;
            tmpData.IsSelect = 0; --是否选中
            tmpData.ShortHandID = cfg.Upper1ID;
            tmpData.ShortHandName = "";
            tmpData.ShortHandUrl = "";
            tmpData.ShortHandDesc = ""; 
            local handCfg = Client.GetTableData("Item", cfg.Upper1ID);
            if handCfg ~= nil then
                tmpData.ShortHandName = handCfg.ArmorySimpleDesc;
                tmpData.ShortHandUrl = handCfg.ItemSmallIcon;
                tmpData.ShortHandDesc = handCfg.ArmoryDesc;                 
            end
            table.insert(Upper,tmpData);

            if cfg.Upper2ID ~= 0 then
                local tmpData1 = {};
                tmpData1.ShortHandType = 1;
                tmpData1.IsSelect = 0; --是否选中
                tmpData1.ShortHandID = cfg.Upper2ID;
                tmpData1.ShortHandName = "";
                tmpData1.ShortHandUrl = "";
                tmpData1.ShortHandDesc = "";    
                local handCfg = Client.GetTableData("Item", cfg.Upper2ID);
                if handCfg ~= nil then
                    tmpData1.ShortHandName = handCfg.ArmorySimpleDesc;
                    tmpData1.ShortHandUrl = handCfg.ItemSmallIcon;
                    tmpData1.ShortHandDesc = handCfg.ArmoryDesc;                    
                end
                table.insert(Upper,tmpData1);
            end

            if cfg.Upper3ID ~= 0 then
                local tmpData2 = {};
                tmpData2.ShortHandType = 1;
                tmpData2.IsSelect = 0; --是否选中
                tmpData2.ShortHandID = cfg.Upper3ID;
                tmpData2.ShortHandName = "";
                tmpData2.ShortHandUrl = "";
                tmpData2.ShortHandDesc = "";    
                local handCfg = Client.GetTableData("Item", cfg.Upper3ID);
                if handCfg ~= nil then
                    tmpData2.ShortHandName = handCfg.ArmorySimpleDesc;
                    tmpData2.ShortHandUrl = handCfg.ItemSmallIcon;
                    tmpData2.ShortHandDesc = handCfg.ArmoryDesc;                    
                end
                table.insert(Upper,tmpData2);               
            end

            if cfg.Upper4ID ~= 0 then
                local tmpData3 = {};
                tmpData3.ShortHandType = 1;
                tmpData3.IsSelect = 0; --是否选中
                tmpData3.ShortHandID = cfg.Upper4ID;
                tmpData3.ShortHandName = "";
                tmpData3.ShortHandUrl = "";
                tmpData3.ShortHandDesc = "";    
                local handCfg = Client.GetTableData("Item", cfg.Upper4ID);
                if handCfg ~= nil then
                    tmpData3.ShortHandName = handCfg.ArmorySimpleDesc;
                    tmpData3.ShortHandUrl = handCfg.ItemSmallIcon;
                    tmpData3.ShortHandDesc = handCfg.ArmoryDesc;                    
                end
                table.insert(Upper,tmpData3);  
            end

            if cfg.Upper5ID ~= 0 then
                local tmpData4 = {};
                tmpData4.ShortHandType = 1;
                tmpData4.IsSelect = 0; --是否选中
                tmpData4.ShortHandID = cfg.Upper5ID;
                tmpData4.ShortHandName = "";
                tmpData4.ShortHandUrl = "";
                tmpData4.ShortHandDesc = "";
                local handCfg = Client.GetTableData("Item", cfg.Upper5ID);
                if handCfg ~= nil then
                    tmpData4.ShortHandName = handCfg.ArmorySimpleDesc;
                    tmpData4.ShortHandUrl = handCfg.ItemSmallIcon;
                    tmpData4.ShortHandDesc = handCfg.ArmoryDesc;                    
                end 
                table.insert(Upper,tmpData4);    
            end

            if cfg.Upper6ID ~= 0 then
                local tmpData5 = {};
                tmpData5.ShortHandType = 1;
                tmpData5.IsSelect = 0; --是否选中
                tmpData5.ShortHandID = cfg.Upper6ID;
                tmpData5.ShortHandName = "";
                tmpData5.ShortHandUrl = "";
                tmpData5.ShortHandDesc = "";
                local handCfg = Client.GetTableData("Item", cfg.Upper6ID);
                if handCfg ~= nil then
                    tmpData5.ShortHandName = handCfg.ArmorySimpleDesc;
                    tmpData5.ShortHandUrl = handCfg.ItemSmallIcon;
                    tmpData5.ShortHandDesc = handCfg.ArmoryDesc;                    
                end 
                table.insert(Upper,tmpData5);    
            end

            if cfg.Upper7ID ~= 0 then
                local tmpData6 = {};
                tmpData6.ShortHandType = 1;
                tmpData6.IsSelect = 0; --是否选中
                tmpData6.ShortHandID = cfg.Upper7ID;
                tmpData6.ShortHandName = "";
                tmpData6.ShortHandUrl = "";
                tmpData6.ShortHandDesc = "";
                local handCfg = Client.GetTableData("Item", cfg.Upper7ID);
                if handCfg ~= nil then
                    tmpData6.ShortHandName = handCfg.ArmorySimpleDesc;
                    tmpData6.ShortHandUrl = handCfg.ItemSmallIcon;
                    tmpData6.ShortHandDesc = handCfg.ArmoryDesc;                    
                end 
                table.insert(Upper,tmpData6);    
            end

            table.insert(datas,Upper);
       end

       if cfg.Stock1ID ~= 0 then --5枪托
            local Stock = {};
            local tmpData = {};
            tmpData.ShortHandType = 5;
            tmpData.IsSelect = 0; --是否选中
            tmpData.ShortHandID = cfg.Stock1ID;
            tmpData.ShortHandName = "";
            tmpData.ShortHandUrl = "";
            tmpData.ShortHandDesc = ""; 
            local handCfg = Client.GetTableData("Item", cfg.Stock1ID);
            if handCfg ~= nil then
                tmpData.ShortHandName = handCfg.ArmorySimpleDesc;
                tmpData.ShortHandUrl = handCfg.ItemSmallIcon;
                tmpData.ShortHandDesc = handCfg.ArmoryDesc;                 
            end 
            table.insert(Stock,tmpData);
            if cfg.Stock2ID ~= 0 then
                local tmpData1 = {};
                tmpData1.ShortHandType = 5;
                tmpData1.IsSelect = 0; --是否选中
                tmpData1.ShortHandID = cfg.Stock2ID;
                tmpData1.ShortHandName = "";
                tmpData1.ShortHandUrl = "";
                tmpData1.ShortHandDesc = "";    
                local handCfg = Client.GetTableData("Item", cfg.Stock2ID);
                if handCfg ~= nil then
                    tmpData1.ShortHandName = handCfg.ArmorySimpleDesc;
                    tmpData1.ShortHandUrl = handCfg.ItemSmallIcon;
                    tmpData1.ShortHandDesc = handCfg.ArmoryDesc;                    
                end 
                table.insert(Stock,tmpData1);
            end
            table.insert(datas,Stock);

       end

       if cfg.Magazine1ID ~= 0 then --3弹夹
            local Magazine = {};
            local tmpData = {};
            tmpData.ShortHandType = 3;
            tmpData.IsSelect = 0; --是否选中
            tmpData.ShortHandID = cfg.Magazine1ID;
            tmpData.ShortHandName = "";
            tmpData.ShortHandUrl = "";
            tmpData.ShortHandDesc = ""; 
            local handCfg = Client.GetTableData("Item", cfg.Magazine1ID);
            if handCfg ~= nil then
                tmpData.ShortHandName = handCfg.ArmorySimpleDesc;
                tmpData.ShortHandUrl = handCfg.ItemSmallIcon;
                tmpData.ShortHandDesc = handCfg.ArmoryDesc;                 
            end 
            table.insert(Magazine,tmpData);
            if cfg.Magazine2ID ~= 0 then
                local tmpData1 = {};
                tmpData1.ShortHandType = 3;
                tmpData1.IsSelect = 0; --是否选中
                tmpData1.ShortHandID = cfg.Magazine2ID;
                tmpData1.ShortHandName = "";
                tmpData1.ShortHandUrl = "";
                tmpData1.ShortHandDesc = "";    
                local handCfg = Client.GetTableData("Item", cfg.Magazine2ID);
                if handCfg ~= nil then
                    tmpData1.ShortHandName = handCfg.ArmorySimpleDesc;
                    tmpData1.ShortHandUrl = handCfg.ItemSmallIcon;
                    tmpData1.ShortHandDesc = handCfg.ArmoryDesc;                    
                end
                table.insert(Magazine,tmpData1);
            end
            if cfg.Magazine3ID ~= 0 then
                local tmpData2 = {};
                tmpData2.ShortHandType = 3;
                tmpData2.IsSelect = 0; --是否选中
                tmpData2.ShortHandID = cfg.Magazine3ID;
                tmpData2.ShortHandName = "";
                tmpData2.ShortHandUrl = "";
                tmpData2.ShortHandDesc = "";
                local handCfg = Client.GetTableData("Item", cfg.Magazine3ID);
                if handCfg ~= nil then
                    tmpData2.ShortHandName = handCfg.ArmorySimpleDesc;
                    tmpData2.ShortHandUrl = handCfg.ItemSmallIcon;
                    tmpData2.ShortHandDesc = handCfg.ArmoryDesc;                    
                end 
                table.insert(Magazine,tmpData2);
            end

            if cfg.Magazine4ID ~= 0 then
                local tmpData3 = {};
                tmpData3.ShortHandType = 3;
                tmpData3.IsSelect = 0; --是否选中
                tmpData3.ShortHandID = cfg.Magazine4ID;
                tmpData3.ShortHandName = "";
                tmpData3.ShortHandUrl = "";
                tmpData3.ShortHandDesc = "";
                local handCfg = Client.GetTableData("Item", cfg.Magazine4ID);
                if handCfg ~= nil then
                    tmpData3.ShortHandName = handCfg.ArmorySimpleDesc;
                    tmpData3.ShortHandUrl = handCfg.ItemSmallIcon;
                    tmpData3.ShortHandDesc = handCfg.ArmoryDesc;                    
                end 
                table.insert(Magazine,tmpData3);
            end

            if cfg.Magazine5ID ~= 0 then
                local tmpData4 = {};
                tmpData4.ShortHandType = 3;
                tmpData4.IsSelect = 0; --是否选中
                tmpData4.ShortHandID = cfg.Magazine5ID;
                tmpData4.ShortHandName = "";
                tmpData4.ShortHandUrl = "";
                tmpData4.ShortHandDesc = "";
                local handCfg = Client.GetTableData("Item", cfg.Magazine5ID);
                if handCfg ~= nil then
                    tmpData4.ShortHandName = handCfg.ArmorySimpleDesc;
                    tmpData4.ShortHandUrl = handCfg.ItemSmallIcon;
                    tmpData4.ShortHandDesc = handCfg.ArmoryDesc;                    
                end 
                table.insert(Magazine,tmpData4);
            end

            if cfg.Magazine6ID ~= 0 then
                local tmpData5 = {};
                tmpData5.ShortHandType = 3;
                tmpData5.IsSelect = 0; --是否选中
                tmpData5.ShortHandID = cfg.Magazine6ID;
                tmpData5.ShortHandName = "";
                tmpData5.ShortHandUrl = "";
                tmpData5.ShortHandDesc = "";
                local handCfg = Client.GetTableData("Item", cfg.Magazine6ID);
                if handCfg ~= nil then
                    tmpData5.ShortHandName = handCfg.ArmorySimpleDesc;
                    tmpData5.ShortHandUrl = handCfg.ItemSmallIcon;
                    tmpData5.ShortHandDesc = handCfg.ArmoryDesc;                    
                end 
                table.insert(Magazine,tmpData5);
            end

            table.insert(datas,Magazine);
       end

       if cfg.Lower1ID ~= 0 then --4握把
            local Lower = {};
            local tmpData = {};
            tmpData.ShortHandType = 4;
            tmpData.IsSelect = 0; --是否选中
            tmpData.ShortHandID = cfg.Lower1ID;
            tmpData.ShortHandName = "";
            tmpData.ShortHandUrl = "";
            tmpData.ShortHandDesc = ""; 
            local handCfg = Client.GetTableData("Item", cfg.Lower1ID);
            if handCfg ~= nil then
                tmpData.ShortHandName = handCfg.ArmorySimpleDesc;
                tmpData.ShortHandUrl = handCfg.ItemSmallIcon;
                tmpData.ShortHandDesc = handCfg.ArmoryDesc;                 
            end 
            table.insert(Lower,tmpData);
            if cfg.Lower2ID ~= 0 then
                local tmpData1 = {};
                tmpData1.ShortHandType = 4;
                tmpData1.IsSelect = 0; --是否选中
                tmpData1.ShortHandID = cfg.Lower2ID;
                tmpData1.ShortHandName = "";
                tmpData1.ShortHandUrl = "";
                tmpData1.ShortHandDesc = "";
                local handCfg = Client.GetTableData("Item", cfg.Lower2ID);
                if handCfg ~= nil then
                    tmpData1.ShortHandName = handCfg.ArmorySimpleDesc;
                    tmpData1.ShortHandUrl = handCfg.ItemSmallIcon;
                    tmpData1.ShortHandDesc = handCfg.ArmoryDesc;                    
                end     
                table.insert(Lower,tmpData1);                
            end

            if cfg.Lower3ID ~= 0 then
                local tmpData2 = {};
                tmpData2.ShortHandType = 4;
                tmpData2.IsSelect = 0; --是否选中
                tmpData2.ShortHandID = cfg.Lower3ID;
                tmpData2.ShortHandName = "";
                tmpData2.ShortHandUrl = "";
                tmpData2.ShortHandDesc = "";
                local handCfg = Client.GetTableData("Item", cfg.Lower3ID);
                if handCfg ~= nil then
                    tmpData2.ShortHandName = handCfg.ArmorySimpleDesc;
                    tmpData2.ShortHandUrl = handCfg.ItemSmallIcon;
                    tmpData2.ShortHandDesc = handCfg.ArmoryDesc;                    
                end     
                table.insert(Lower,tmpData2);                
            end

            if cfg.Lower4ID ~= 0 then
                local tmpData3 = {};
                tmpData3.ShortHandType = 4;
                tmpData3.IsSelect = 0; --是否选中
                tmpData3.ShortHandID = cfg.Lower4ID;
                tmpData3.ShortHandName = "";
                tmpData3.ShortHandUrl = "";
                tmpData3.ShortHandDesc = "";
                local handCfg = Client.GetTableData("Item", cfg.Lower4ID);
                if handCfg ~= nil then
                    tmpData3.ShortHandName = handCfg.ArmorySimpleDesc;
                    tmpData3.ShortHandUrl = handCfg.ItemSmallIcon;
                    tmpData3.ShortHandDesc = handCfg.ArmoryDesc;                    
                end     
                table.insert(Lower,tmpData3);                
            end

            if cfg.Lower5ID ~= 0 then
                local tmpData4 = {};
                tmpData4.ShortHandType = 4;
                tmpData4.IsSelect = 0; --是否选中
                tmpData4.ShortHandID = cfg.Lower5ID;
                tmpData4.ShortHandName = "";
                tmpData4.ShortHandUrl = "";
                tmpData4.ShortHandDesc = "";
                local handCfg = Client.GetTableData("Item", cfg.Lower5ID);
                if handCfg ~= nil then
                    tmpData4.ShortHandName = handCfg.ArmorySimpleDesc;
                    tmpData4.ShortHandUrl = handCfg.ItemSmallIcon;
                    tmpData4.ShortHandDesc = handCfg.ArmoryDesc;                    
                end     
                table.insert(Lower,tmpData4);                
            end

            if cfg.Lower6ID ~= 0 then
                local tmpData5 = ArmoryUI.BuildShortHandItemData(4, cfg.Lower6ID);                
                table.insert(Lower,tmpData5);    
            end

            table.insert(datas,Lower);
       end
    end
    -- log_tree("=====datas:", datas)
    table.sort( datas, function(a,b)
            if a.ShortHandType ~= b.ShortHandType then
                return a.ShortHandType < b.ShortHandType;
            else
                return false;
            end
        end            
    );
    -- log_tree("=====datas:", datas)
    return datas;
end

--是否有选中配件
function ArmoryUI.HasSelectShortHand(shortHandID)
    local result = false;
    for k,v in pairs(ArmoryUI.EquipShortHandData) do
       if v.ShortHandID == shortHandID then
         result = true;
         break;
       end
    end
    return result;
end

--是否装了扩容弹夹
function ArmoryUI.HasEquipExtClip()
    local result = false;
    for k,v in pairs(ArmoryUI.EquipShortHandData) do
        local shorHandAttrCfg = Client.GetTableData("ArmoryShortHandAttr", v.ShortHandID);
        if shorHandAttrCfg ~= nil then
           if shorHandAttrCfg.IsExtClip > 0 then
                result = true;
                break;
           end
        end
    end
    return result;
end

--处理武器一级菜单
function ArmoryUI.ProcessFirstMenu()
    --WeaponType = 0, --武器类型
    --TypeName = "", --类型名称
    --IconUrl = "", --图标路径
    --IsSelect = 0, --是否选中  
    BP_ARRAY_Weapon_FirstMenuData = {}; 
    -- nanneli csv 
    -- if BP_Armory_MainType == ArmoryUI.MAIN_TYPE.WEAPON then
        --local Armory_Type_Config = Client.GetTable("ArmoryTypeConfig")   
        -- for k,v in pairs(BP_ARRAY_ArmoryTypeConfig) do  
        for k,v in pairs(Armory_Type_Config) do 
            local item = {};
            item.WeaponType = v.TypeID;
            item.TypeName = v.TypeName;
            item.IconUrl = v.IconUrl;
            item.IsSelect = 0;
            -- 武器载具飞机切换
            -- if BP_Armory_MainType == v.TypeID then 

            -- 只用于武器
            if BP_Current_WeaponType == v.TypeID then 
                item.IsSelect = 1;
            end

            item.RedPoint = ArmorySystem.HasRedPointByWeaponIdOrType(v.TypeID);
            table.insert(BP_ARRAY_Weapon_FirstMenuData, item);
        end
    -- end

    -- if BP_Armory_MainType == ArmoryUI.MAIN_TYPE.VEHICLE then
    --     local configs = Client.GetTable("VehicleTypeConfig")      
    --     for k,v in pairs(configs) do     
    --         local item = {};
    --         item.WeaponType = v.TypeID;
    --         item.TypeName = v.TypeName;
    --         item.IconUrl = v.IconUrl;
    --         item.IsSelect = 0;
    --         if BP_Current_WeaponType == v.TypeID then
    --             item.IsSelect = 1;
    --         end

    --         -- item.RedPoint = ArmorySystem.HasRedPointByWeaponIdOrType(v.TypeID);
    --         table.insert(BP_ARRAY_Weapon_FirstMenuData, item);
    --     end 
    -- end

    -- if BP_Armory_MainType == ArmoryUI.MAIN_TYPE.PLANE then
    --     local configs = Client.GetTable("PlaneTypeConfig")      
    --     for k,v in pairs(configs) do     
    --         local item = {};
    --         item.WeaponType = v.TypeID;
    --         item.TypeName = v.TypeName;
    --         item.IconUrl = v.IconUrl;
    --         item.IsSelect = 0;
    --         if BP_Current_WeaponType == v.TypeID then
    --             item.IsSelect = 1;
    --         end

    --         -- item.RedPoint = ArmorySystem.HasRedPointByWeaponIdOrType(v.TypeID);
    --         table.insert(BP_ARRAY_Weapon_FirstMenuData, item);
    --     end 
    -- end

    table.sort( BP_ARRAY_Weapon_FirstMenuData, function (a, b)
        if a.WeaponType ~= b.WeaponType then
            return a.WeaponType < b.WeaponType;
        else
            return false;
        end
    end );

    -- log_tree("BP_ARRAY_Weapon_FirstMenuData",BP_ARRAY_Weapon_FirstMenuData);
end

function ArmoryUI.GetSecMenuURL(WeaponID, srcUrl)     
    local url = srcUrl;
    local skinInsID = ArmorySystem.GetSkinIdByWeaponID(WeaponID);
    --log("GetSecMenuURL WeaponID:"..tostring(WeaponID).."skinID:"..tostring(skinInsID));
    if skinInsID > 0 then
        local data = DataMgr.GetHallDepotItemDataByInsID(tostring(skinInsID));
        if data ~= nil then
            local resID = data.resID;
            local skinCfg  = Client.GetTableData("Item",resID);   
            if skinCfg ~= nil then
                url = skinCfg.ItemSmallIcon;    
            end
        end       
    end
    --log("GetSecMenuURL url:"..tostring(url));
   return url;
end

function ArmoryUI.GetSecMenuQuality(WeaponID)
   local reslut = 0;
   local skinInsID = ArmorySystem.GetSkinIdByWeaponID(WeaponID);
   if skinInsID > 0 then
        local data = DataMgr.GetHallDepotItemDataByInsID(tostring(skinInsID));
        if data ~= nil then
            local resID = data.resID;
            local skinCfg  = Client.GetTableData("Item",resID);   
            if skinCfg ~= nil then
                reslut = skinCfg.ItemQuality;    
            end
        end    
    end   
   return reslut;
end

--更新处理武器二级菜单
function ArmoryUI.UpdateSecMenu(needRefreshWeaponModel)
    --WeaponID = 0, --武器ID
    --WeaponType = 0, --武器类型
    --WeaponName = "", --武器名称
    --WeaponShortName = "", --武器简写
    --WeaponIconUrl = "",   
    --IsSelect = 0,
    BP_ARRAY_Weapon_SecMenuData = {};
    local allData 
    if BP_Armory_MainType == ArmoryUI.MAIN_TYPE.WEAPON then
        allData = ArmoryUI.GetTotalDataByType(BP_Current_WeaponType);

    elseif BP_Armory_MainType == ArmoryUI.MAIN_TYPE.VEHICLE then
        allData = ArmoryUI.GetTotalVehicleDataByType(BP_Current_WeaponType)

    elseif BP_Armory_MainType == ArmoryUI.MAIN_TYPE.PLANE then
        allData = ArmoryUI.GetTotalPlaneDataByType(BP_Current_WeaponType)
    end

    if allData == nil then return end

    for k,v in pairs(allData.WeaponDatas) do       
        local itemData = {};
        itemData.WeaponID =  v.WeaponID;
        itemData.WeaponType = v.WeaponType;
        itemData.WeaponName = v.WeaponName;
        itemData.WeaponShortName = v.WeaponShortName;
        itemData.WeaponIconUrl = ArmoryUI.GetSecMenuURL(v.WeaponID, v.WeaponIconUrl); -- v.WeaponIconUrl;
        itemData.SkinQuality = ArmoryUI.GetSecMenuQuality(v.WeaponID);
        itemData.IsSelect = 0;
        if BP_Current_WeaponID == v.WeaponID then
            itemData.IsSelect = 1;
        end
        itemData.RedPoint = ArmorySystem.HasRedPointByWeaponIdOrType(v.WeaponID);
        table.insert(BP_ARRAY_Weapon_SecMenuData,itemData);
    end  
    if #BP_ARRAY_Weapon_SecMenuData > 1 then
        table.sort( BP_ARRAY_Weapon_SecMenuData, function (a, b )
           if a.WeaponID ~= b.WeaponID then
                return a.WeaponID < b.WeaponID;
           else
                return false;
           end
        end);
    end
    --显示模型
    --log("WeaponModelHandlerShowWeaponByResId"..BP_Current_WeaponID);
    if needRefreshWeaponModel ~= nil then
        BP_Current_SelectSkinID = ArmorySystem.GetSkinResIdByWeaponID(BP_Current_WeaponID)
        --log("BP_Current_SelectSkinID = "..BP_Current_SelectSkinID .. "BP_Current_WeaponID " .. BP_Current_WeaponID);
        -- 兼容载具飞机3D显示
        if BP_Current_SelectSkinID == BP_Current_WeaponID then BP_Current_SelectSkinID = 0 end
        
        if (BP_Current_SelectSkinID ~= nil and BP_Current_SelectSkinID > 0) then
            BP_Last_SelectSkinID = BP_Current_SelectSkinID
            WeaponModelHandler:ShowWeaponByResId(BP_Current_SelectSkinID, true);
        else
            WeaponModelHandler:ShowWeaponByResId(BP_Current_WeaponID);
        end         
    end
    --log_tree("BP_ARRAY_Weapon_SecMenuData",BP_ARRAY_Weapon_SecMenuData);
end

--更新处理枪配件菜单
function ArmoryUI.UpdateShortHandMenu()
    --ShortHandType = 0, --配件类型，1是瞄具 2枪口 3弹夹 4握把 5枪托，0默认没有,6皮肤
    --IsSelect = 0, --是否选中
    --log("UpdateShortHandMenu"..BP_Current_ShortHandType);
    BP_ARRAY_ShortHand_MenuData = {};
    -- if BP_Armory_MainType == ArmoryUI.MAIN_TYPE.WEAPON then
        local shortHandData = {};
        local allData = ArmoryUI.GetTotalDataByType(BP_Current_WeaponType);
        
        if allData == nil then return end
        if allData.WeaponDatas == nil then return end

        for k,v in pairs(allData.WeaponDatas) do
            if v.WeaponID == BP_Current_WeaponID then
                shortHandData = v.ShortHandDatas;
                break;
            end
        end

        for tk,tv in pairs(shortHandData) do
            local itemData = {};
            if tv[1].ShortHandType ~= nil then
                itemData.ShortHandType = tv[1].ShortHandType;             
                itemData.IsSelect = 0;
                if BP_Current_ShortHandType == tv[1].ShortHandType then
                    itemData.IsSelect = 1;
                end
                itemData.RedPoint = false;
                itemData.SkinIconUrl = ""; --主要用于皮肤
            end   

            table.insert(BP_ARRAY_ShortHand_MenuData,itemData);
        end

         --额外增加皮肤
         local hasSkinData = ArmorySystem.GetSkinArrayByWeaponID(BP_Current_WeaponID);
         if nil ~= hasSkinData then
            if nil ~= hasSkinData.SkinArray  then
                if nil ~= next(hasSkinData.SkinArray) then        
                     local itemData = {};
                     itemData.ShortHandType = 6; --皮肤为6       
                     itemData.IsSelect = 0;
                     if BP_Current_ShortHandType == itemData.ShortHandType then
                         itemData.IsSelect = 1;
                     end         
                     itemData.RedPoint = ArmorySystem.HasRedPointByWeaponIdOrType(BP_Current_WeaponID);         
                     itemData.SkinIconUrl = ArmoryUI.GetSecMenuURL(BP_Current_WeaponID,""); --特殊，只有皮肤才有用到
                     table.insert(BP_ARRAY_ShortHand_MenuData,itemData);
                 end
             end
         end 
    -- end

    -- if BP_Armory_MainType == ArmoryUI.MAIN_TYPE.VEHICLE then
    --     BP_Current_ShortHandType = 6
    --     local itemData = {};
    --     itemData.ShortHandType = 6;
    --     itemData.IsSelect = 1;
    --     itemData.RedPoint = false      
    --     itemData.SkinIconUrl = ArmoryUI.GetSecMenuURL(BP_Current_WeaponID,""); --特殊，只有皮肤才有用到
    --     table.insert(BP_ARRAY_ShortHand_MenuData,itemData);
    -- end
    -- log_tree("BP_ARRAY_ShortHand_MenuData",BP_ARRAY_ShortHand_MenuData);
end

--更新配件数据
function ArmoryUI.UpdateShortHandData()
    --ShortHandType = 0,--配件类型，1是瞄具 2枪口 3弹夹 4握把 5枪托，0默认没有
    --IsSelect = 0, --是否选中
    --ShortHandID = 0,
    --ShortHandName = "",
    --ShortHandUrl = "",
    --ShortHandDesc = "",
    --log("UpdateShortHandData:"..tostring(BP_Current_WeaponType).."BP_Current_WeaponID:"..tostring(BP_Current_WeaponID).."BP_Current_ShortHandType"..tostring(BP_Current_ShortHandType));
    BP_ARRAY_ShortHandData = {};
    local shortHandData = {};
    local allData = ArmoryUI.GetTotalDataByType(BP_Current_WeaponType);
    --log_tree("shortHandDatadddddddddddd",allData);
    for k,v in pairs(allData.WeaponDatas) do
        if v.WeaponID == BP_Current_WeaponID then
            shortHandData = v.ShortHandDatas;
            break;
        end
    end
    --log_tree("shortHandDatadddddddddddd",shortHandData);

    for k,v in pairs(shortHandData) do
        --log_tree("shortHandDatadddddddddddd",v);
        local tmpData = v;
        for tk,tv in pairs(tmpData) do
            if BP_Current_ShortHandType == tv.ShortHandType then
                local itemData = {};
                itemData.ShortHandType = tv.ShortHandType;
                itemData.IsSelect = 0;
                itemData.ShortHandID = tv.ShortHandID;
                itemData.ShortHandName = tv.ShortHandName;
                itemData.ShortHandUrl = tv.ShortHandUrl;
                itemData.ShortHandDesc = tv.ShortHandDesc;
                local  isSelect = ArmoryUI.HasSelectShortHand(tv.ShortHandID);
                if isSelect == true then
                    itemData.IsSelect = 1;
                end
                table.insert(BP_ARRAY_ShortHandData,itemData);
            end
        end
    end
    -- table.sort(BP_ARRAY_ShortHandData, function(a, b)
    --    if a.ShortHandID ~= b.ShortHandID then
    --         return a.ShortHandID < b.ShortHandID;
    --    else
    --         return false;
    --    end
    -- end);
    -- log_tree("BP_ARRAY_ShortHandData",BP_ARRAY_ShortHandData);

end

--更新皮肤数据
function ArmoryUI.UpdateSkinData()
    if BP_Current_ShortHandType == 0 then
        --为0表是没有数据，关闭列表
        BP_ARRAY_WeaponSkinData = {};
        return;
    end
    --log("UpdateSkinData BP_Current_SelectSkinID:"..tostring(BP_Current_SelectSkinID).."BP_Last_SelectSkinID:"..tostring(BP_Last_SelectSkinID));
   

    local WeaponID = BP_Current_WeaponID;
    --log("UpdateSkinData WeaponID:"..tostring(WeaponID));
    local skinData = ArmorySystem.GetSkinArrayByWeaponID(WeaponID);
    -- log_tree("skinData",skinData);
    if skinData ~= nil then
        BP_ARRAY_WeaponSkinData = {};
        local arrayData = skinData.SkinArray;
        --log_tree("UpdateSkinData",arrayData);
        for k,v in pairs(arrayData) do
            local dataInfo = {};
            dataInfo.SkinID = v.SkinID;
            dataInfo.ShopingID = v.ShopingID;
            dataInfo.IsOpen = v.IsOpen;
            dataInfo.HasOwner = v.HasOwner;
            dataInfo.HasEquip = v.HasEquip;
            dataInfo.MoneyType = v.MoneyType;
            dataInfo.Price = v.Price;

            dataInfo.WeaponID = v.WeaponID;
            dataInfo.WeaponType = v.WeaponType;
            dataInfo.ShortHandType = v.ShortHandType;          
            dataInfo.SkinUrl = v.SkinUrl;--ArmoryUI.GetSecMenuURL(v.WeaponID, v.SkinUrl);
            dataInfo.SkinDesc = v.SkinDesc;          
            dataInfo.SkinDetailDesc = v.SkinDetailDesc;   
            dataInfo.IsRedPoint = false; -- v.IsRedPoint; 皮肤不需要红点，和仓库统一，点了武器就菜单就直接取消所有红点
            dataInfo.IsSelect = 0;     

            dataInfo.leftTime = "";
            -- 计算天数和小时数
            if v.leftTime > 0 then
                local timeStr = WardrobeSystem.GetRemainTimeStr(v.leftTime);
                if timeStr and timeStr ~= "" then
                    dataInfo.leftTime = timeStr;                    
                end
            end            
            dataInfo.Quality = v.Quality;
            dataInfo.SkinName = v.SkinName;
            --默认选中已装备的皮肤
            if BP_Current_SelectSkinID == v.SkinID then
                dataInfo.IsSelect = 1;           
            end
            table.insert( BP_ARRAY_WeaponSkinData, dataInfo); 
        end
    end
    -- log_tree("BP_ARRAY_WeaponSkinData",BP_ARRAY_WeaponSkinData);
end


--更新武器属性
function ArmoryUI.UpdateWeaponAttrData()
    --AttrType = 0, --1 威力、2有效射程、3稳定性、4射速 5弹夹容量
    --AttrName = "", --名称
    --AttrValue = 0, --当前属性对应的值
    --AttrMaxValue = 100, --最大值
    BP_ARRAY_WeaponAttrData = {};
    local attrData = {};
    local allData = ArmoryUI.GetTotalDataByType(BP_Current_WeaponType);
    --log("allData"..BP_Current_WeaponType);
    for k,v in pairs(allData.WeaponDatas) do
        if v.WeaponID == BP_Current_WeaponID then
            attrData = v.AttrDatas;
            break;
        end
    end

    --log_tree("attrData",attrData);

    for tk,tv in pairs(attrData) do
        local itemData = {};
        itemData.AttrType = tv.AttrType;
        itemData.AttrName = tv.AttrName;
        itemData.AttrValue = ArmoryUI.GetWeaponAttrDataByType(tv.AttrType,tv.AttrValue);
        itemData.AttrValueBase = tv.AttrValue;
        itemData.AttrMaxValue = tv.AttrMaxValue;
        if itemData.AttrValue ~= "" then 
            table.insert(BP_ARRAY_WeaponAttrData, itemData);
        end        
    end    
    --log_tree("BP_ARRAY_WeaponAttrData",BP_ARRAY_WeaponAttrData);
end

--通过类型获取额外属性
function ArmoryUI.GetWeaponAttrDataByType(attrType,attrValue)
    --log("attrType:"..attrType.."attrValue:"..attrValue);
    local cfg = Client.GetTableData("ArmoryConfig", BP_Current_WeaponID);
    local newAttrValue = attrValue;
    if cfg == nil then
        return newAttrValue;
    end
    for k,v in pairs(ArmoryUI.EquipShortHandData) do
       local ShortHandID = v.ShortHandID;
       local shorHandAttrCfg = Client.GetTableData("ArmoryShortHandAttr",ShortHandID);
       if shorHandAttrCfg == nil then
           return newAttrValue;
       end

       --1 威力、2有效射程、3稳定性、4射速(不会动态改变) 5弹夹容量
       if attrType == 1 then        
       elseif attrType == 2 then
       elseif attrType == 3 then
           local vX = ArmoryUI.ExtAttrOverlay.VerticalRecoil;
           local hX = ArmoryUI.ExtAttrOverlay.HorizontalRecoil;
           local sh = ArmoryUI.ExtAttrOverlay.Shake;    

           --表格兼容处理
           local VerticalRecoil = 0;
           local Horizontal = 0;
           local Shake = 0;
           if cfg.VerticalRecoil ~= "" then 
               VerticalRecoil = cfg.VerticalRecoil;
           end
           if cfg.HorizontalRecoil ~= "" then 
               Horizontal = cfg.HorizontalRecoil;
           end
           if cfg.Shake ~= "" then 
               Shake = cfg.Shake;
           end
           newAttrValue = VerticalRecoil * vX + Horizontal * hX + Shake * sh; --稳定性：垂直后坐力+水平后坐力+画面抖动   范围0-5
          
       elseif attrType == 4 then
           local speed = ArmoryUI.ExtAttrOverlay.ReloadSpeed;      

           --分母做保护
           local ReloadSpeed = 0;
           local ShootInterval = 1;
           local ClipCapacity = 1;
           if cfg.ReloadSpeed ~= "" then
               ReloadSpeed = cfg.ReloadSpeed;
           end
           if cfg.ClipCapacity ~= "" then
               ClipCapacity = cfg.ClipCapacity;
           end
           if cfg.ShootInterval ~= "" then
               ShootInterval = cfg.ShootInterval;
           end
           local capacity = ClipCapacity;
           local hasExtClip = ArmoryUI.HasEquipExtClip();
           if hasExtClip == true then
               capacity = cfg.ExtCapcity; --取扩容弹夹
           end
           newAttrValue = 60 / (ShootInterval + (ReloadSpeed *speed / capacity));--射速：60/[射击间隔+(换弹速度/当前弹容量)]  范围0-500
          
       elseif attrType == 5 then
           if shorHandAttrCfg.IsExtClip > 0 then
               newAttrValue = cfg.ExtCapcity; --读取扩展容量
           end
       end  

    end
    return newAttrValue;
end

--更新额外属性
function ArmoryUI.UpdateWeaponAttrDataExt(shortHandID)

    if ArmoryUI.EquipShortHandData[BP_Current_ShortHandType] == nil then
        ArmoryUI.EquipShortHandData[BP_Current_ShortHandType] = {};
    end
    local handCfg = Client.GetTableData("Item", shortHandID);
    ArmoryUI.EquipShortHandData[BP_Current_ShortHandType].ShortHandType = BP_Current_ShortHandType;
    ArmoryUI.EquipShortHandData[BP_Current_ShortHandType].ShortHandID = shortHandID;
    ArmoryUI.EquipShortHandData[BP_Current_ShortHandType].ShortHandUrl = "";
    if handCfg ~= nil then       
        ArmoryUI.EquipShortHandData[BP_Current_ShortHandType].ShortHandUrl = handCfg.ItemSmallIcon;         
    end

    --log_tree("UpdateWeaponAttrDataExt",ArmoryUI.EquipShortHandData);
    
end

--处理属性叠加
function ArmoryUI.UpdateWeaponAttrTotalExt()
     --处理属性叠加
     ArmoryUI.ExtAttrOverlay = {};
     local Power = 1;
     local ShotRange = 1;
     local ReloadSpeed = 1;
     local VerticalRecoil = 1;
     local HorizontalRecoil = 1;
     local Shake = 1;   
     for k,v in pairs(ArmoryUI.EquipShortHandData) do
         local ShortHandID = v.ShortHandID;
         local shorHandAttrCfg = Client.GetTableData("ArmoryShortHandAttr",ShortHandID);
         if shorHandAttrCfg ~= nil then
             if shorHandAttrCfg.Power ~= "" then
                 Power = Power * shorHandAttrCfg.Power;
             end
             if shorHandAttrCfg.ShotRange ~= "" then
                 ShotRange = ShotRange * shorHandAttrCfg.ShotRange;
             end
             if shorHandAttrCfg.ReloadSpeed ~= "" then
                 ReloadSpeed = ReloadSpeed * shorHandAttrCfg.ReloadSpeed;
             end
             if shorHandAttrCfg.VerticalRecoil ~= "" then
                 VerticalRecoil = VerticalRecoil * shorHandAttrCfg.VerticalRecoil;
             end
             if shorHandAttrCfg.HorizontalRecoil ~= "" then
                 HorizontalRecoil = HorizontalRecoil * shorHandAttrCfg.HorizontalRecoil;
             end
             if shorHandAttrCfg.Shake ~= "" then
                 Shake = Shake * shorHandAttrCfg.Shake;
             end           
         end
     end
     ArmoryUI.ExtAttrOverlay.Power = Power;
     ArmoryUI.ExtAttrOverlay.ShotRange = ShotRange;
     ArmoryUI.ExtAttrOverlay.ReloadSpeed = ReloadSpeed;
     ArmoryUI.ExtAttrOverlay.VerticalRecoil = VerticalRecoil;
     ArmoryUI.ExtAttrOverlay.HorizontalRecoil = HorizontalRecoil;
     ArmoryUI.ExtAttrOverlay.Shake = Shake;    
end


--更新当前武器装备的全配件（主要用于配件菜单的图标显示）
function ArmoryUI.UpdateCurrentShortHandEquip()    
    BP_ARRAY_CurrentShortHandEquip = {};
    for k,v in pairs(ArmoryUI.EquipShortHandData) do
        local tmpData = {};
        tmpData.ShortHandType = v.ShortHandType;
        tmpData.ShortHandID = v.ShortHandID;
        tmpData.ShortHandUrl = v.ShortHandUrl;
        tmpData.IsSelect = v.IsSelect;
        table.insert( BP_ARRAY_CurrentShortHandEquip, tmpData);
     end
end


--更新武器显示详情
function ArmoryUI.UpdateWeaponDetailInfo()
    --WeaponResID = 0, --武器资源ID
    --WeaponName = "", --武器名字
    --WeaponDesc = "", --武器描述
    --BulletID = 0, --子弹ID
    --BulletName = "", --子弹名字
    --BulletUrl = "", --子弹图标路径
    --BulletDesc = "", --子弹描述   
    local allData = nil
    if BP_Armory_MainType == ArmoryUI.MAIN_TYPE.WEAPON then
        allData = ArmoryUI.GetTotalDataByType(BP_Current_WeaponType);    
    end

    if BP_Armory_MainType == ArmoryUI.MAIN_TYPE.VEHICLE then
        allData = ArmoryUI.GetTotalVehicleDataByType(BP_Current_WeaponType);    
    end
 
    if BP_Armory_MainType == ArmoryUI.MAIN_TYPE.PLANE then
        allData = ArmoryUI.GetTotalPlaneDataByType(BP_Current_WeaponType);    
    end

	if allData == nil or allData.WeaponDatas == nil then
		return
	end

    for k,v in pairs(allData.WeaponDatas) do
        if v.WeaponID == BP_Current_WeaponID then
            BP_STRUCT_WeaponDetailInfo.WeaponResID = v.WeaponID;
            BP_STRUCT_WeaponDetailInfo.WeaponName = v.WeaponName;
            BP_STRUCT_WeaponDetailInfo.WeaponDesc = v.WeaponDesc;
            BP_STRUCT_WeaponDetailInfo.BulletID = v.BulletID;
            BP_STRUCT_WeaponDetailInfo.BulletName = v.BulletName;
            BP_STRUCT_WeaponDetailInfo.BulletUrl = v.BulletUrl;
            BP_STRUCT_WeaponDetailInfo.BulletDesc = v.BulletDesc;
            break;
        end
    end
    --log_tree("BP_Current_DetailInfo",BP_Current_DetailInfo);
end

--武器类型获取简要数据
function ArmoryUI.GetWeaponDataByWeaponType(weaponType)
    local dataType = {};
    if ArmoryUI.WeaponClassData[weaponType] ~= nil then
        dataType = ArmoryUI.WeaponClassData[weaponType];
    end
    --log_tree("GetWeaponDataByWeaponType",dataType);
    return dataType;    
end

function ArmoryUI.GetVehicleDataByWeaponType(typeID)
    local dataType = {};
    if ArmoryUI.VehicleClassData[typeID] ~= nil then
        dataType = ArmoryUI.VehicleClassData[typeID];
    end
    --log_tree("GetWeaponDataByWeaponType",dataType);
    return dataType;    
end

function ArmoryUI.GetPlaneDataByWeaponType(typeID)
    local dataType = {};
    if ArmoryUI.PlaneClassData[typeID] ~= nil then
        dataType = ArmoryUI.PlaneClassData[typeID];
    end
    --log_tree("GetWeaponDataByWeaponType",dataType);
    return dataType;    
end

--武器类型获详细数据
function ArmoryUI.GetTotalDataByType(weaponType)
    --log("GetTotalDataByType:"..weaponType);
    local dataInfo = {};
    if ArmoryUI.TotalData[weaponType] ~= nil then       
        dataInfo = ArmoryUI.TotalData[weaponType];
    end   

    if dataInfo.WeaponDatas ~= nil then
        table.sort( dataInfo.WeaponDatas, function (a, b)
            if a.WeaponID ~= b.WeaponID then
                return a.WeaponID < b.WeaponID;
            else
                return false;
            end
        end)
    end
    --log_tree("GetTotalDataByType",dataInfo);
    return  dataInfo;  
end

--载具类型获详细数据
function ArmoryUI.GetTotalVehicleDataByType(weaponType)
    local result = {}
    for type,dataInfo in pairs(ArmoryUI.TotalVehicleData) do
        if dataInfo.WeaponDatas ~= nil then
            for k,v in pairs(dataInfo.WeaponDatas) do
                table.insert(result,v)
            end
        end
    end

    table.sort( result, function (a, b)
        if a.WeaponID ~= b.WeaponID then
            return a.WeaponID < b.WeaponID;
        else
            return false;
        end
    end)

    local dataInfo = {}
    dataInfo.WeaponDatas = result
    --log_tree("GetTotalDataByType",dataInfo);
    return  dataInfo;  
end

--飞机类型获详细数据
function ArmoryUI.GetTotalPlaneDataByType(weaponType)
    --log("GetTotalDataByType:"..weaponType);
    -- local dataInfo = {};
    -- if ArmoryUI.TotalPlaneData[weaponType] ~= nil then       
    --     dataInfo = ArmoryUI.TotalPlaneData[weaponType];
    -- end   

    -- if dataInfo.WeaponDatas ~= nil then
    --     table.sort( dataInfo.WeaponDatas, function (a, b)
    --         if a.WeaponID ~= b.WeaponID then
    --             return a.WeaponID < b.WeaponID;
    --         else
    --             return false;
    --         end
    --     end)
    -- end
    -- --log_tree("GetTotalDataByType",dataInfo);

    -- return  dataInfo;  
    local result = {}
    for type,dataInfo in pairs(ArmoryUI.TotalPlaneData) do
        if dataInfo.WeaponDatas ~= nil then
            for k,v in pairs(dataInfo.WeaponDatas) do
                table.insert(result,v)
            end
        end
    end

    table.sort( result, function (a, b)
        if a.WeaponID ~= b.WeaponID then
            return a.WeaponID < b.WeaponID;
        else
            return false;
        end
    end)

    local dataInfo = {}
    dataInfo.WeaponDatas = result
    --log_tree("GetTotalDataByType",dataInfo);
    return  dataInfo;  
end

--重置默认武器ID和配件ID（用于点击一级菜单时候）
function ArmoryUI.ResetIDForClickFirstMenu()
    --重置武器ID
    local allData = nil
    if BP_Armory_MainType == ArmoryUI.MAIN_TYPE.WEAPON then
        allData = ArmoryUI.GetTotalDataByType(BP_Current_WeaponType);
    end

    if BP_Armory_MainType == ArmoryUI.MAIN_TYPE.VEHICLE then
        allData = ArmoryUI.GetTotalVehicleDataByType(BP_Current_WeaponType);
    end

    if BP_Armory_MainType == ArmoryUI.MAIN_TYPE.PLANE then
        allData = ArmoryUI.GetTotalPlaneDataByType(BP_Current_WeaponType);
    end

	if allData == nil or allData.WeaponDatas == nil then
		return
	end

    for k,v in pairs(allData.WeaponDatas) do       
        --取第一个武器ID
        BP_Current_WeaponID = v.WeaponID;
        BP_Current_ShortHandType = 0;
        break;
    end  

    --重置配件
    BP_Current_ShortHandID = 0;
    ArmoryUI.EquipShortHandData = {};
    BP_ARRAY_CurrentShortHandEquip = {};
    ArmoryUI.LastShortHandID = 0;

    BP_ARRAY_WeaponSkinData = {};
    BP_Current_SelectSkinID = 0;
    BP_Last_SelectSkinID = 0;
end

--重置配件
function ArmoryUI.ResetShordHandData()
    BP_Current_ShortHandType = 0;
    BP_Current_ShortHandID = 0;
    ArmoryUI.EquipShortHandData = {};
    BP_ARRAY_CurrentShortHandEquip = {};
    ArmoryUI.LastShortHandID = 0;
    BP_ARRAY_WeaponSkinData = {};
    BP_Current_SelectSkinID = 0;
    BP_Last_SelectSkinID = 0;
end

--更新当前选中皮肤
function ArmoryUI.UpdateCurrentSkinData()
    --BP_STRUCT_WeaponSkinInfo.SkinID = 0;
    log("UpdateCurrentSkinData BP_Current_SelectSkinID " .. BP_Current_SelectSkinID)
    -- log_tree("BP_STRUCT_WeaponSkinInfo1",BP_STRUCT_WeaponSkinInfo);
    -- log_tree("BP_ARRAY_WeaponSkinData",BP_ARRAY_WeaponSkinData)
    for k,v in pairs(BP_ARRAY_WeaponSkinData) do
        if v.SkinID == BP_Current_SelectSkinID then
            BP_STRUCT_WeaponSkinInfo = v;
            break;
        end
    end
    
    -- log_tree("BP_STRUCT_WeaponSkinInfo2",BP_STRUCT_WeaponSkinInfo);
    LuaClassObj.HandleUIMessageNoFetch(bp_armory, "UpdateSkinBuyInfo");     
end

--购买成功后刷新下数据
function ArmoryUI.UpdateSkinForBuySucess()
    log("UpdateSkinForBuySucess");
    --更新下UI缓存数据
    ArmorySystem.UpdateSkinHasOwner(BP_Current_WeaponID, BP_Current_SelectSkinID);    

    --清除当前皮肤选中态,更新购买信息数据
    --BP_Current_SelectSkinID = 0;    
    LuaClassObj.HandleUIMessageNoFetch(bp_armory, "UpdateSkinBuyInfo");   
    ArmoryUI.UpdateSkinPrice();
    ArmoryUI.UpdateCurrentSkinData();
end

--装备/卸下成功后刷新下数据
function ArmoryUI.UpdateSkinEquipState()
    --log("UpdateSkinEquipState");
    --更新下UI缓存数据
    ArmorySystem.UpdateSkinHasEquip(BP_Current_WeaponID, BP_Current_SelectSkinID);    
    ArmoryUI.UpdateSkinData();
    LuaClassObj.HandleUIMessageNoFetch(bp_armory, "UpdateSkinData");
    ArmoryUI.UpdateCurrentSkinData();
end

--价格变化后刷新显示
function ArmoryUI.UpdateSkinPrice()
    ArmoryUI.UpdateSkinData();
    LuaClassObj.HandleUIMessageNoFetch(bp_armory, "UpdateSkinData");
end

--显示枪械涂装列表
function ArmoryUI.ShowWeaponSkinList()
    BP_Current_ShortHandType = 6;
    ArmoryUI.UpdateUI(true);
    EventclickSkinShortHandMenu();
end

function ArmoryUI.CloseUI()
    LuaClassObj.HandleUIMessageNoFetch(bp_armory, "OnClickBtnClose");
end

-- 点击下拉菜单
function EventGuntypeChanged()
    --log("EventClickArmoryFirstMenu:"..BP_Current_WeaponType);
    ArmoryUI.ResetIDForClickFirstMenu();
    --ArmoryUI.UpdateUI(true);
    ArmoryUI.ShowWeaponSkinList();
end


--点击一级菜单
function EventClickArmoryFirstMenu()
    --BP_Current_WeaponType = 0;--选中的武器类型
    --BP_Current_WeaponID = 0;--选中的武器ID
    --更新UI显示
    -- log("EventClickArmoryFirstMenu:"..BP_Armory_MainType);
    -- BP_Armory_MainType = BP_Current_Weapon

    ArmoryUI.ResetIDForClickFirstMenu();
    ArmoryUI.UpdateUI(true);
    ArmoryUI.ShowWeaponSkinList();
 end

 --点击二级菜单
function EventClickArmorySecMenu()
    --取默认的第一个武器ID
    --更新UI显示
    log("EventClickArmorySecMenu:"..BP_Current_WeaponID);
       --重置配件ID
    ArmoryUI.ResetShordHandData();
    ArmoryUI.UpdateUI(true);
    ArmoryUI.ShowWeaponSkinList();
end

--点击配件菜单
function EventclickArmoryShorHandMenu()
  --取
  --log("EventclickArmoryShorHandMenu:"..tostring(BP_Current_ShortHandType));
  ArmoryUI.UpdateUI();
  --主要用于更新购买按钮信息组
  LuaClassObj.HandleUIMessageNoFetch(bp_armory, "UpdateSkinBuyInfo");   
end

--点击皮肤配件菜单
function EventclickSkinShortHandMenu()
    log("EventclickSkinShortHandMenu BP_Current_ShortHandType"..BP_Current_ShortHandType);

    -- 针对载具特殊处理
    -- if BP_Armory_MainType == ArmoryUI.MAIN_TYPE.VEHICLE then
    --     BP_Current_ShortHandType = 6
    -- end

    --更新皮肤数组,默认选中已装备皮肤
    ArmoryUI.UpdateSkinData();
    --取消红点
     local needUpdatUI =  ArmorySystem.OnCancelRePoint(BP_Current_WeaponID);
     if needUpdatUI == true then
         --刷新下各级菜单，取消红点--刷新下各级菜单，取消红点
         ArmoryUI.UpdateUI();
    else
        ArmoryUI.UpdateShortHandMenu();
    end  
    --刷新皮肤列表
    LuaClassObj.HandleUIMessageNoFetch(bp_armory, "UpdateSkinData");      
    LuaClassObj.HandleUIMessageNoFetch(bp_armory, "UpdateSkinBuyInfo");  
     
    ArmoryUI.UpdateCurrentSkinData();   
end

--装备皮肤
function EventclickSkinShortHandItem()

    --记录上一次的皮肤,用来切换选中态
    if BP_Last_SelectSkinID == BP_Current_SelectSkinID then
        BP_Current_SelectSkinID = 0;       
    end    
    BP_Last_SelectSkinID = BP_Current_SelectSkinID;

    --存储当前选中皮肤
    log("EventclickSkinShortHandItem"..tostring(BP_Current_SelectSkinID));   

    --刷新皮肤
    ArmoryUI.UpdateSkinData();   
    ArmoryUI.UpdateCurrentSkinData();    

    --如果有皮肤，则向后台发送装备皮肤请求TODO
    if BP_Current_SelectSkinID == 0 then  
        WeaponModelHandler:UnEquipSkin(BP_STRUCT_WeaponSkinInfo.WeaponID);
    else
        WeaponModelHandler:EquipSkin(BP_STRUCT_WeaponSkinInfo.SkinID);
    end
    --刷新皮肤列表
    LuaClassObj.HandleUIMessageNoFetch(bp_armory, "UpdateSkinData");      
end

--装备皮肤
function EventClickInstallSkin()
    if BP_STRUCT_WeaponSkinInfo.HasOwner == true then
        local insID = ArmorySystem.GetInsIdByResID(BP_STRUCT_WeaponSkinInfo.SkinID);
        -- log_tree("EventClickInstallSkin BP_STRUCT_WeaponSkinInfo",BP_STRUCT_WeaponSkinInfo)
        ArmorySystem.install_weapon_skin(ArmorySystem.ENUM_REQ_Armory, BP_STRUCT_WeaponSkinInfo.WeaponID, insID)
    end
end

--卸下皮肤
function EventClickUnInstallSkin()
    if BP_STRUCT_WeaponSkinInfo.HasOwner == true then
        ArmorySystem.uninstall_weapon_skin(ArmorySystem.ENUM_REQ_Armory, BP_STRUCT_WeaponSkinInfo.WeaponID)
    end
end

--装备配件
function EventclickArmoryShortHandItem()
    local off = false;
    log("EventclickArmoryShorHandItem1111:"..BP_Current_ShortHandID);
    --log_tree("EventclickArmoryShorHandItem1111", ArmoryUI.EquipShortHandData);
    if ArmoryUI.EquipShortHandData[BP_Current_ShortHandType] ~= nil then
        for k,v in pairs(ArmoryUI.EquipShortHandData[BP_Current_ShortHandType]) do
            --log_tree("EventclickArmoryShorHandItem1111", v);
            if v == BP_Current_ShortHandID then
                  ArmoryUI.EquipShortHandData[BP_Current_ShortHandType] = nil;            
                  off = true;
                  break;
            end
         end
    end
    --log_tree("EventclickArmoryShorHandItem222", ArmoryUI.EquipShortHandData);
    if off == true then
        WeaponModelHandler:PutoffEquipmentByResId(BP_Current_ShortHandID);
    else 
        WeaponModelHandler:PutonEquipmentByResId(BP_Current_ShortHandID);
        --增加额外属性
        ArmoryUI.UpdateWeaponAttrDataExt(BP_Current_ShortHandID);
    end 

    --累加总属性
    ArmoryUI.UpdateWeaponAttrTotalExt();
    ArmoryUI.UpdateWeaponAttrData();
    ArmoryUI.UpdateShortHandData();
    ArmoryUI.UpdateCurrentShortHandEquip();
    LuaClassObj.HandleUIMessageNoFetch(bp_armory, "UpdateShortHand");    
    LuaClassObj.HandleUIMessageNoFetch(bp_armory, "UpdateAttr");   
    LuaClassObj.HandleUIMessageNoFetch(bp_armory, "UpdateShorHandMenu");      
end

local function localText(id)
    local data = Client.GetTableData("LocalizeRes",id);
    if data then
        return data.TextValue
    end
    return ""
end

-- 判断商品是否在商城内
BP_Armory_IsSkinInShop = false

function EventIsArmorySkinInShop()
    log("EventIsArmorySkinInShop BP_Current_SelectSkinID "..BP_Current_SelectSkinID.." BP_Current_WeaponID "..BP_Current_WeaponID)
    BP_Armory_IsSkinInShop = false

    local itemId = BP_Current_WeaponID
    if BP_Current_SelectSkinID ~= 0 then
        itemId = BP_Current_SelectSkinID
    end

    local shopInfo = MallSystem.getTabInfoByItemID(itemId)
    if shopInfo ~= nil then
        BP_Armory_IsSkinInShop = true
        log("BP_Armory_IsSkinInShop true")
        return
    end

    log("BP_Armory_IsSkinInShop false")
end

function EventClickToMall()
    log("EventClickToMall BP_Current_SelectSkinID "..BP_Current_SelectSkinID.." BP_Current_WeaponID "..BP_Current_WeaponID)
    local itemId = BP_Current_WeaponID
    if BP_Current_SelectSkinID ~= 0 then
        itemId = BP_Current_SelectSkinID
    end

    local shopInfo = MallSystem.getTabInfoByItemID(itemId)
    if shopInfo == nil then
        CommonMessageBoxUI:ShowPanel(1, localText(101001), "商品没有上架")
        return
    end

    -- local tap1 = math.floor(shopInfo.page/100)
    -- local tap2 = shopInfo.page - tap1 * 100

    local tap1 = shopInfo.first_tab
    local tap2 = shopInfo.second_tab

    local params = {
        ["Tab1"] = tap1,
        ["Tab2"] = tap2,
        ["isForceTab2"] = true,
        ["itemId"] = itemId,
        -- ["selectShopId"] = shopInfo.shop_id,
    };
    if shopInfo.shop_id ~= nil and shopInfo.shop_id ~= 0 then
        params.selectShopId = shopInfo.shop_id
    else
        params.selectShopId = itemId
    end

    log("EventClickToMall BP_Armory_Isopen = " .. BP_Armory_Isopen)

    LuaClassObj.HandleUIMessageNoFetch(bp_armory, "UIHide");
    WeaponModelHandler:DestroyWeaponShowActor()
    BP_Armory_Isopen = 0
    
    EventArmoryCloseArmoryMainUIEnter();
    EventSystem:postEvent(EVENTTYPE_URL, BP_ENUM_MODULE_MALL_CHILD, params)
end

--清空所有配件
function EventclickClearAllEquipment()
    WeaponModelHandler:PutoffAllEquipment(BP_Current_WeaponID);
    --重置配件ID
    ArmoryUI.ResetShordHandData();
    ArmoryUI.UpdateUI();
end

--购买皮肤
function EventclickArmoryBuySkin()
    log("EventclickArmoryBuySkin"..tostring(BP_STRUCT_WeaponSkinInfo.ShopingID));
    ArmorySystem.get_one_weapon_skin_shop_info(BP_STRUCT_WeaponSkinInfo.SkinID);
    -- MarketBuySingleUI.RequestBuy(BP_STRUCT_WeaponSkinInfo.ShopingID);
end

--关闭军备界面
function EventArmoryCloseArmoryMainUI()

    log("EventArmoryCloseArmoryMainUI BP_Armory_Isopen = " .. BP_Armory_Isopen)
    WeaponModelHandler:DestroyWeaponShowActor()
    BP_Armory_Isopen = 0
    
    -- LuaClassObj.HandleUIMessageNoFetch(bp_armory, "UIShowFromArmory");
    EventArmoryCloseArmoryMainUIEnter();
    LuaClassObj.HandleUIMessage(bp_lobby, "UIShowFromArmory");   
end

--事件触发外部UI恢复
function EventArmoryCloseArmoryMainUIEnter()
    ArmoryUI.isShow = false
    ArmoryUI.Release();
    EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE, SceneType.Armory)
end

--打开充值页面
function EventArmoryOnRecharge()
    log("EventMarketOnRecharge")
    RechargeUI:Init();
end

----- 测试接口 -----
function EventTestShowWeapon()
    -- WeaponModelHandler:ShowWeaponByResId(101003)
        -- BP_Armory_MainType = ArmoryUI.MAIN_TYPE.VEHICLE
    if BP_Armory_MainType == ArmoryUI.MAIN_TYPE.WEAPON then 
        BP_Armory_MainType = ArmoryUI.MAIN_TYPE.VEHICLE 

    elseif BP_Armory_MainType == ArmoryUI.MAIN_TYPE.VEHICLE then
        BP_Armory_MainType = ArmoryUI.MAIN_TYPE.PLANE

    elseif BP_Armory_MainType == ArmoryUI.MAIN_TYPE.PLANE then
        BP_Armory_MainType = ArmoryUI.MAIN_TYPE.WEAPON
    end

    BP_Current_WeaponType = 1
    ArmoryUI.ResetIDForClickFirstMenu()
    ArmoryUI.ResetShordHandData()
    ArmoryUI.UpdateUI(true)
    ArmoryUI.ShowWeaponSkinList()
end

function EventTestShowWeapon2()
    -- WeaponModelHandler:ShowWeaponByResId(103003)
    EventClickToMall()
end

function EventTestShowWeapon3()
    WeaponModelHandler:ShowWeaponByResId(108004)
end

function EventTestPutonEquipment()
    WeaponModelHandler:PutonEquipmentByResId(203005)
end

function EventTestPutoffEquipment()
    WeaponModelHandler:PutoffEquipmentByResId(203005)
end

function ArmoryUI.CloseArmory()
    if ArmoryUI.isShow then
        LuaClassObj.HandleUIMessageNoFetch(bp_armory, "UIHide");
        EventArmoryCloseArmoryMainUI();
    end
end


  