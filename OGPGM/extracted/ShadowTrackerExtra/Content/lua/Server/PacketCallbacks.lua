_G.PacketCallbacks = PacketCallbacks or {};

local FIREGUN_ITEM_CLASS = "/Game/Arts_PlayerBluePrints/Weapon/MainWeapon/Pistol/Flaregun/BP_Pistol_Flaregun_Wrapper.BP_Pistol_Flaregun_Wrapper_C"

PacketCallbacks.sync_game_param = function(params)
    sandbox.LogNormal(string.format("sync_game_param received"));
    log_tree("params", params);
    if params and params.server_time then
        sandbox.LogNormal(string.format("sync_game_param server_time :"));
        sandbox.LogNormal(os.date("%Y%m%d%H%M%S", params.server_time));
    end
    sandbox.LogShippingDS(string.format("sync_game_param received, game_id: %d, mode_id: %d, map_id: %d", params.game_id, params.mode_id, params.map_id));
    _G.GameID = params.game_id;
    _G.ModeID = params.mode_id;
    _G.ClubLogo = params.club_logo;

    local customConfigArray = {};
    local inBattleCustomCfg = params.battle_custom_cfg
	if inBattleCustomCfg then
        for k, v in pairs(inBattleCustomCfg) do
			local cfg = {};
			if type(v) == "boolean" then
				cfg = {Config = k, Value = (v == true) and 1.0 or 0.0};
			else
				cfg = {Config = k, Value = v};
			table.insert(customConfigArray, cfg);
			end
		end
	end
	
    local roomParams = {};
	if inBattleCustomCfg then
		roomParams.CircleSpeedMultiplicator = inBattleCustomCfg.ShrinkSpeed;
		roomParams.bAutoOpendoor = inBattleCustomCfg.AutoOpenDoor or false;
		roomParams.bAutoPickup = inBattleCustomCfg.AutoPick or false;
		roomParams.bAudioVisual = inBattleCustomCfg.SoundVisual or false;
		roomParams.bAutoAimAt = inBattleCustomCfg.AimAssist or false;
        roomParams.bGunRemoveBullet = inBattleCustomCfg.BuckleBullet or false;
    
        -- 房间参数毒圈倍数，100为1倍
        roomParams.BlueCircleDamageMultiplicator = inBattleCustomCfg.BluecircleDamage

        -- 房间自定义毒圈第一次延迟刷圈时间，第一次开始缩毒时间，第一次白圈的半径缩放值(100为1倍)
        roomParams.FirstWhiteCircleDelayTime = inBattleCustomCfg.WhitecircleShowtime
        roomParams.FirstSafeZoneAppearTime = inBattleCustomCfg.WhitecircleStarttime
        roomParams.FirstWhiteCircleRadiusMultiplicator = inBattleCustomCfg.WhitecircleDiameter
        roomParams.bUseFirstWhiteCircleDelayTime = inBattleCustomCfg.WhitecircleShowtime ~= nil
        roomParams.bUseFirstSafeZoneAppearTime = inBattleCustomCfg.WhitecircleStarttime ~= nil
        roomParams.bUseFirstWhiteCircleRadiusMultiplicator = inBattleCustomCfg.WhitecircleDiameter ~= nil

        -- 禁用轰炸区
        roomParams.EnableRedZone = inBattleCustomCfg.Redzone ~= false
    end
    
    -- 房间模式使用端游比赛参数
    local customCircleParamsList = {}
    if params.match_room_mode_table then
        for stage, cfg in pairs(params.match_room_mode_table) do
            table.insert(customCircleParamsList, {
                Stage = stage,
                DelayTime = cfg.delay_time,
                SafeZoneAppearTime = cfg.wait_time,
                LastTime = cfg.move_time,
                CircleDamage = cfg.min_damage,
                BlueCircleRadius = cfg.bluecircle_radius,
                WhiteCircleRadius = cfg.whitecircle_radius,
            })
        end
        table.sort(customCircleParamsList, function(a, b)
            return a.Stage < b.Stage
        end)
    end
    roomParams.CustomCircleParamsList = customCircleParamsList 

    -- 房间模式选项可能会禁用信号枪
    local IgnoreItemClassPathList = {}
    if inBattleCustomCfg and inBattleCustomCfg.Firegun == false then
        table.insert(IgnoreItemClassPathList, FIREGUN_ITEM_CLASS)
    end

    local DynamicLoadItemArray = {};
    if params.new_scene_act then
        for _, item in pairs(params.new_scene_act) do
            if item and item.path and item.pos_list then
                local DynamicLoadItem = {};
                DynamicLoadItem.ActID = item.id or 0;
                DynamicLoadItem.Path = item.path;
                DynamicLoadItem.IsClearAfterStart = item.clear_after_start or false;
                DynamicLoadItem.IsPlayerStartPot = item.is_spawn_pos or false;
                DynamicLoadItem.PosIdxList = item.pos_idx_list;
                DynamicLoadItem.TransArray = {};

                for _, trans in pairs(item.pos_list) do
                    if trans and #trans == 6 then
                        local ItemTrans = {};
                        ItemTrans["LocX"] = trans[1];
                        ItemTrans["LocY"] = trans[2];
                        ItemTrans["LocZ"] = trans[3];
                        ItemTrans["RotX"] = trans[4];
                        ItemTrans["RotY"] = trans[5];
                        ItemTrans["RotZ"] = trans[6];

                        table.insert(DynamicLoadItem.TransArray, ItemTrans)
                    end
                end

                table.insert(DynamicLoadItemArray, DynamicLoadItem)
            end
        end
    end

    local modeName = BP_ARRAY_BTMode[params.mode_id].GameModeName;

	local IsFpp = BP_ARRAY_BTMode[params.mode_id].IsFpp;
	if params.room_mode == 1 then
		IsFpp = params.is_fpp;
	end
    local mapPath = BP_ARRAY_Map[params.map_id].MapPath;
    local url = mapPath;

	local IngameUIManagerString = BP_ARRAY_BTMode[params.mode_id].ModeUI;
	local IngameUIManagerArray = {};
	if IngameUIManagerString ~= nil and type(IngameUIManagerString) == "string" then
	    local pattern = string.format("([^%s]*)", ",")
		string.gsub(IngameUIManagerString, pattern, function(c) IngameUIManagerArray[#IngameUIManagerArray+1] = c end)
		log_tree("IngameUIManagerArray", IngameUIManagerArray);
	end

    local localAdvConfigList, localPlaneBanner = PacketCallbacks.ConfigAdvertisement(params, mapPath);

        log_tree("localAdvConfigList", localAdvConfigList);
        log_tree("localPlaneBanner", localPlaneBanner);
        
    if localPlaneBanner == nil then
        localPlaneBanner = {}
    end

    local localTriggerList = PacketCallbacks.ConfigDynamicTriggers(params);
    log_tree("localTriggerList", localTriggerList);

    local grenadeEffectPath = "";
    local bSignalGunEffect = false; --周年庆信号枪特效#1/100开关
    local bGodzillaWarmUpSwitch = false; --哥斯拉预热开关
    local festivalAirDropBoxMesh = "";
    local festivalAirDropProb = 0.0;
    if params.ds_switch then
        grenadeEffectPath = params.ds_switch[1] or "";--ds_switch第一个是手雷爆炸特效路径
        festivalAirDropBoxMesh = params.ds_switch[2] or "";--节日空投箱子资源路径
        festivalAirDropProb = tonumber(params.ds_switch[3] or 0.0);--节日空投概率
        if params.ds_switch[4] ~= nil then
            if 1 == tonumber(params.ds_switch[4]) then 
                bSignalGunEffect = true; --周年庆信号枪特效#1/100开关
            end
        end
        if params.ds_switch[6] ~= nil then  --哥斯拉预热开关
            if 1 == tonumber(params.ds_switch[6]) then 
                bGodzillaWarmUpSwitch = true;
            end
        end
    end

    -- 换装开关
    local localOpenChangeWearing = true;
    if params.ds_switch then
        if params.ds_switch[5] ~= nil then
            if 1 == tonumber(params.ds_switch[5]) then
                localOpenChangeWearing = false;  -- 配置表配置的是DisableChangeWearing=1
            else
                localOpenChangeWearing = true;
            end
        end
    end

    local SeasonStatueList, SeasonStatueBaseInfo = PacketCallbacks.ConfigSeasonStatue(params);
    log_tree("SeasonStatueList", SeasonStatueList);
    log_tree("SeasonStatueBaseInfo", SeasonStatueBaseInfo);

    -- [albin]飞机拖尾横幅贴图链接 promotion_link
    local planeBannerLeftImgPath = params.promotion_link or "";
    local bLocalEnablePlaneBanner = false;
    if planeBannerLeftImgPath == "" then
        bLocalEnablePlaneBanner = false
    else
        bLocalEnablePlaneBanner = true
    end

    local buff_effect_ids = {}; --Buff生效id列表
    local buff_effect_display_ids = {}; --Buff展示id列表

    if params.scene_effect_ids ~= nil then
        -- buff_effect_ids = params.scene_effect_ids;
        for k, v in pairs(params.scene_effect_ids) do
            table.insert(buff_effect_ids, v);
        end
    end
    if params.scene_effect_display_ids ~= nil then
        -- buff_effect_display_ids = params.scene_effect_display_ids;
        for k, v in pairs(params.scene_effect_display_ids) do
            table.insert(buff_effect_display_ids, v);
        end
    end


    local info =
    {
        GameID = params.game_id,
        MaxPlayerLimit = params.max_players;
        DefaultTimeout = params.time_out,
        ListeningPort = params.port,
        bEnableClimbing = params.climb_switch,
        WeatherID = params.weather_id,
        WeatherName = params.weather_name,
        RoomMode = params.room_mode,
        ItemTableName = (params.item_spawn_table or ""),
        ItemClassPath = (params.item_generator_path or ""),
        IgnoreItemClassPathList = IgnoreItemClassPathList,
        VehicleTableName = (params.vehicle_spawn_table or ""),
        VehicleClassPath = (params.vehicle_generator_path or ""),
        BattleCustomConfig = customConfigArray,
		RoomCustomParams = roomParams,
		AdvConfigList = localAdvConfigList,
		DynamicTriggerList = localTriggerList,
		PickupBoxConfigClassPath = (params.box_generator_path or ""),
		PickupBoxConfigDataTableName = (params.box_spawn_table or ""),
		SeasonIdx = params.season_index,
        -- bEnablePlaneBanner=localPlaneBanner.bEnablePlaneBanner or false,
        -- HttpPlaneBannerLeftImgPath=localPlaneBanner.HttpPlaneBannerLeftImgPath or "",
        -- HttpPlaneBannerRightImgPath=localPlaneBanner.HttpPlaneBannerRightImgPath or "",
        bEnablePlaneBanner = bLocalEnablePlaneBanner,
        HttpPlaneBannerLeftImgPath = planeBannerLeftImgPath,
        HttpPlaneBannerRightImgPath = localPlaneBanner.HttpPlaneBannerRightImgPath or "",
        MeteorShowerRatio = params.meteor_shower_ratio or 0;
        
		GameModeID = _G.ModeID;
		GameModeUIManagerArray = IngameUIManagerArray;
        SeasonStatueCharacters = SeasonStatueList or {};
        SeasonStatueBaseParams = SeasonStatueBaseInfo;
        GrenadeEffectPath = grenadeEffectPath;
        bAnniversarySignalGunEffect = bSignalGunEffect;
        bGodzillaWarmUpSwitchOpened = bGodzillaWarmUpSwitch;
        FestivalAirDropBoxMesh = festivalAirDropBoxMesh;
        FestivalAirDropProb = festivalAirDropProb;
        DynamicLoadItemArray = DynamicLoadItemArray,
        BornItemId = params.born_item,
        BornItemCount = params.born_count,
        MonsterDropPar = params.monster_drop_param or 100,
        SceneDropParam = params.scene_drop_param or 100,
        bOpenChangeWearing = localOpenChangeWearing;
        BuffEffectIDArray = buff_effect_ids,
        BuffEffectDisplayIDArray = buff_effect_display_ids,
    }
    log_tree('FinalInfo', info)
    Server.SyncGameInfo(DSUtils, info);

    if string.len(modeName) > 0 then
        url = url .. '?game=' .. modeName;
    end
    url = url .. '?mapid=' .. params.map_id;
    if IsFpp then
        url = url .. '?IsFpp=1';
    else
        url = url .. '?IsFpp=0';
    end

    if params.mode_config_id then
        url = url .. '?hardId=' .. params.mode_config_id;
    end 

    if params.zone_id then
        url = url .. '?zoneId=' .. params.zone_id;
    end 
    
    if params.idc then
        url = url .. '?idcStr=' .. params.idc;
    end 

    sandbox.LogNormal(string.format("sync_game_param received TravelURL=%s VehicleTableName=%s VehicleClassPath=%s ", url,VehicleTableName,VehicleClassPath));

    Server.Travel(url, params.port, params.encrypt_key, params.game_id);
end

PacketCallbacks.ConfigAdvertisement = function(params, mapPath)
    local test_adv =
    {
    {id=1,url="http://down.qq.com/jdqssy/billboard/test.png"},
    {id=2,url="http://km.oa.com/files/photos/pictures/201806/1528089980_54_w1600_h2400.JPG"},
    {id=3,url="http://km.oa.com/files/photos/pictures/201806/1528090034_55_w1600_h2400.JPG"},
    {id=4,url="http://wx3.sinaimg.cn/large/7ba837b5gy1frozerrwo5j21hc1zu1f0.jpg"},
    {id=5,url="http://km.oa.com/files/photos/pictures/201804/1522593127_17_w2000_h2996.jpg"},
    {id=6,url="https://gss0.bdstatic.com/94o3dSag_xI4khGkpoWK1HF6hhy/baike/c0%3Dbaike116%2C5%2C5%2C116%2C38/sign=c3f6e3520523dd54357eaf3ab060d8bb/c8177f3e6709c93d782a91c1933df8dcd100542f.jpg"},
    {id=7,url="http://wx4.sinaimg.cn/large/7ba837b5gy1frozen9zlzj21hc1zmqn2.jpg"},
    {id=8,url="http://km.oa.com/files/photos/pictures/201806/1528089980_54_w1600_h2400.JPG"},
    {id=9,url="http://km.oa.com/files/photos/pictures/201806/1528090034_55_w1600_h2400.JPG"},
    {id=10,url="http://wx3.sinaimg.cn/large/7ba837b5gy1frozerrwo5j21hc1zu1f0.jpg"},
    {id=11,url="http://km.oa.com/files/photos/pictures/201804/1522593127_17_w2000_h2996.jpg"},
    {id=12,url="https://gss0.bdstatic.com/94o3dSag_xI4khGkpoWK1HF6hhy/baike/c0%3Dbaike116%2C5%2C5%2C116%2C38/sign=c3f6e3520523dd54357eaf3ab060d8bb/c8177f3e6709c93d782a91c1933df8dcd100542f.jpg"},
    {id=13,url="http://wx4.sinaimg.cn/large/7ba837b5gy1frozen9zlzj21hc1zmqn2.jpg"},
    {id=14,url="http://km.oa.com/files/photos/pictures/201806/1528089980_54_w1600_h2400.JPG"},
    {id=15,url="http://km.oa.com/files/photos/pictures/201806/1528090034_55_w1600_h2400.JPG"},
    {id=16,url="http://wx3.sinaimg.cn/large/7ba837b5gy1frozerrwo5j21hc1zu1f0.jpg"},
    {id=17,url="http://km.oa.com/files/photos/pictures/201804/1522593127_17_w2000_h2996.jpg"},
    {id=18,url="https://gss0.bdstatic.com/94o3dSag_xI4khGkpoWK1HF6hhy/baike/c0%3Dbaike116%2C5%2C5%2C116%2C38/sign=c3f6e3520523dd54357eaf3ab060d8bb/c8177f3e6709c93d782a91c1933df8dcd100542f.jpg"},
    {id=19,url="http://wx4.sinaimg.cn/large/7ba837b5gy1frozen9zlzj21hc1zmqn2.jpg"},
    {id=1000,url="1"},
    {id=1001,url="http://down.qq.com/jdqssy/billboard/Billboard.png"},
    };

    local localPlaneBanner = {}
    if Server.IsBuildDev() then
        if params.ad_list == nil or #params.ad_list < 1 then
            --sandbox.LogNormal("Set debug advertisement config");
            --params.ad_list = test_adv;
        end
    end
	if params.ad_list == nil then
		return nil, localPlaneBanner;
	end

    	local localAdvConfigList = {}
	for k,v in pairs(params.ad_list) do
		local id = v.id;
		--飞机尾翼横幅
		if id == 1000 then
			localPlaneBanner.bEnablePlaneBanner = (v.url ~= "0");
		elseif id == 1001 then
			localPlaneBanner.HttpPlaneBannerLeftImgPath = v.url or "";
		else
		--普通广告牌配置
			local data = BP_ARRAY_AdvertisementConfig[id];
			if data~=nil and data.MapPath == mapPath then
				local config={}
				config.HttpImgPath = v.url or "";
				config.ResPath = data.MeshPath;
				config.Loc = {data.ConfigList[1], data.ConfigList[2], data.ConfigList[3]};
				config.Rot = {Pitch=(data.ConfigList[4] or 0), Yaw=(data.ConfigList[5] or 0), Roll=(data.ConfigList[6] or 0)};
				config.Scale = {(data.ConfigList[7] or 1), (data.ConfigList[8] or 1), (data.ConfigList[9] or 1)};
				config.Id = id;
				table.insert(localAdvConfigList, config);
			end
        end
	end

	return localAdvConfigList, localPlaneBanner;
end

PacketCallbacks.ConfigDynamicTriggers = function(params)
	local localTriggerList = {};
	if params.scene_task_list then
		for _,v in pairs(params.scene_task_list) do
			local LocalTrigger = {};
			LocalTrigger.TriggerClassPath = v.path or "";
			LocalTrigger.Transforms = {};
			if v.pos_list ~= nil then
				for _, i in pairs(v.pos_list) do
					local LocalTransform = {};
					LocalTransform.Loc = {i[1] or 0, i[2] or 0, i[3] or 0};
					LocalTransform.Rot = {Pitch=(i[4] or 0), Yaw=(i[5] or 0), Roll=(i[6] or 0)};
					table.insert(LocalTrigger.Transforms, LocalTransform);
				end
			end
			table.insert(localTriggerList, LocalTrigger);
		end
	end

	return localTriggerList;
end

PacketCallbacks.ConfigSeasonStatue = function(params)
    local gameMode = params.mode_id;
    local statueInfo = params.league_statue;
    local SeasonStatueList = {};
    local SeasonStatueBaseInfo = {};
    local cfgData;

    local split = function(str, sep)
        local result = {}
        if str == nil or sep == nil or type(str) ~= "string" or type(sep) ~= "string" then
            return result
        end
        if #sep == 0 then
            return result
        end
        local pattern = string.format("([^%s]*)", sep)
        string.gsub(str, pattern, function(c) result[#result+1] = c end)
        return result
    end

    if type(statueInfo) ~= "table" then
        return SeasonStatueList, SeasonStatueBaseInfo;
    end

    local seasonID = statueInfo.league_id or 0;
    local regionID = statueInfo.zone_id or 0;

    SeasonStatueBaseInfo.ClassPath = "";
    SeasonStatueBaseInfo.MatPath = "";
    SeasonStatueBaseInfo.TeamFlag = statueInfo.team_flag or "";
    SeasonStatueBaseInfo.TeamName = statueInfo.name or "";
    SeasonStatueBaseInfo.Loc = {0, 0, 0};
    SeasonStatueBaseInfo.Rot = {Pitch = 0, Yaw = 0, Roll = 0};
    SeasonStatueBaseInfo.Scale = {1, 1, 1};

    if not BP_ARRAY_SeasonStatueTransform or not BP_ARRAY_SeasonStatueCfg then
        sandbox.LogNormal("BP_ARRAY_SeasonStatueTransform or BP_ARRAY_SeasonStatueCfg is not valid");
        return SeasonStatueList, SeasonStatueBaseInfo;
    end

    if BP_ARRAY_SeasonStatueTransform[gameMode] then
        local trans = split(BP_ARRAY_SeasonStatueTransform[gameMode].Transform, ";");
        SeasonStatueBaseInfo.Loc = {tonumber(trans[1] or 0), tonumber(trans[2] or 0), tonumber(trans[3] or 0)};
        SeasonStatueBaseInfo.Rot = {Pitch=tonumber(trans[4] or 0), Yaw=tonumber(trans[5] or 0), Roll=tonumber(trans[6] or 0)};
        SeasonStatueBaseInfo.Scale = {tonumber(trans[7] or 1), tonumber(trans[8] or 1), tonumber(trans[9] or 1)};
    else
        return SeasonStatueList, SeasonStatueBaseInfo;
    end

    local avatarList = {};

    if seasonID and regionID then
        for _,v in pairs(BP_ARRAY_SeasonStatueCfg) do
            if v.RegionID == regionID and v.SeasonID == seasonID then
                cfgData = v;
                break;
            end
        end
    end

    if cfgData then
        SeasonStatueBaseInfo.ClassPath = cfgData.StatueBasePath;
        SeasonStatueBaseInfo.MatPath = cfgData.StatueBaseMat;
        local members = statueInfo.members or {};
        for _,v in pairs(members) do
            local statue = {};
            statue.Name = v.name or "";
            statue.Nation = v.nation or "";
            statue.Loc = {0, 0, 0};
            statue.Rot = {Pitch = 0, Yaw = 0, Roll = 0};
            statue.Scale = {1, 1, 1};
            statue.AGender = v.gender or 0;

            if type(v[9]) == "table" then
                statue.Head = v[9][1] or 401993;
            else
                statue.Head = 401999;
            end

            if type(v[10]) == "table" then
                statue.Hair = v[10][1] or 40601001;
            else
                statue.Hair = 40601001;
            end

            if type(v[13]) == "table" then
                statue.WeaponId = v[13][1] or 101004;
            else
                statue.WeaponId = 101004;
            end

            statue.AvatarList = {};
            local ava = split(cfgData.AvatarList, ";");
            local hasCfgAvatar = false;

            if cfgData.AvatarList == "" then
                hasCfgAvatar = false;
            else
                hasCfgAvatar = true;
                for _,v in pairs(ava) do
                    table.insert(statue.AvatarList, tonumber(v or 0));
                end
            end

            if not hasCfgAvatar then
                sandbox.LogNormal("statue use avatar info from lobby ");
                --头饰
                if type(v[1]) == "table" then
                    table.insert(statue.AvatarList, tonumber(v[1][1] or 0));
                end

                --面罩
                if type(v[2]) == "table" then
                    table.insert(statue.AvatarList, tonumber(v[2][1] or 0));
                end

                --衣服
                if type(v[3]) == "table" then
                    table.insert(statue.AvatarList, tonumber(v[3][1] or 0));
                end

                --裤子
                if type(v[4]) == "table" then
                    table.insert(statue.AvatarList, tonumber(v[4][1] or 0));
                end

                --鞋子
                if type(v[5]) == "table" then
                    table.insert(statue.AvatarList, tonumber(v[5][1] or 0));
                end
            end
            
            table.insert(SeasonStatueList, statue);
        end
    end

    return SeasonStatueList, SeasonStatueBaseInfo;
end

PacketCallbacks.sync_player_info = function(uid, info)
    sandbox.LogNormal(string.format("sync_player_info received, uid=[%d] name=[%s]", uid, info.name));
    log_tree("info", info);
    
    local infoToDS = {};
    infoToDS.PlayerType = "Normal";
    infoToDS.PlayerName = (info.name or "");
    infoToDS.bIsGM = (info.gm or false);
	infoToDS.bTeamLeader = (info.is_team_leader == 1);
    infoToDS.TeamID = (info.teamid or 0);
    infoToDS.Gender = (info.gender or 0);
    infoToDS.bReconnect = false;
	infoToDS.DestinyValue = (info.destiny or 0);
	infoToDS.WarmScore = (info.warm_score or 0);
    infoToDS.bObserver = (info.is_ob or false);
	infoToDS.PlatformGender = (info.rela_sex or 0);
	infoToDS.RatingScore = (info.rank_rating or 0);
    infoToDS.Nation = info.nation or "";
    infoToDS.planeAvatarId = info.fly_skin or 0;
    infoToDS.bRoomCanKickPlayer = (info.room_can_kick_player or false);
    if info.upass_info then
        infoToDS.UpassInfo = {}
        if info.upass_info.is_buy == 0 then
            infoToDS.UpassInfo.isBuy = false
        else
            infoToDS.UpassInfo.isBuy = true
        end
        infoToDS.UpassInfo.updateTime = info.upass_info.acc_update_time
        infoToDS.UpassInfo.upassLevel = info.upass_info.level
        infoToDS.UpassInfo.upassScore = info.upass_info.acc_score
        infoToDS.UpassInfo.mainSwitch = info.upass_info.main_switch
        if info.upass_info.switch then
            infoToDS.UpassInfo.isBattleTitle = info.upass_info.switch.battle_title
            infoToDS.UpassInfo.isUI = info.upass_info.switch.ui
            infoToDS.UpassInfo.battleShow = info.upass_info.switch.battle_show
        end
        infoToDS.UpassInfo.iconUrl = info.upass_info.pic_url
    end
    
    if info.alias then
        infoToDS.AliasInfo = {}
        infoToDS.AliasInfo.aliasId = info.alias.id
        infoToDS.AliasInfo.aliasTitle = ""
        infoToDS.AliasInfo.aliasNation = info.alias.nation
        infoToDS.AliasInfo.aliasRank = info.alias.rank
    end
    infoToDS.WatchUID = 0;
    infoToDS.bAnchorOB = false;
    infoToDS.MatchLabel = (info.match_label or 0);
    infoToDS.CorpsID=(info.corps_id or 0);
    infoToDS.OnlyTeammateSeeAvatar = (info.only_teammate_can_see_my_avatar or false);
    --sandbox.LogNormal("infoToDS.OnlyTeammateSeeAvatar "..infoToDS.OnlyTeammateSeeAvatar)

    if (info.anchor_plat_info ~= nil) then
        infoToDS.AnchorPlatColorID = info.anchor_plat_info.color_id
        infoToDS.AnchorPlatResID  = info.anchor_plat_info.res_id
    else
        infoToDS.AnchorPlatColorID = -1
        infoToDS.AnchorPlatResID  = -1
    end

    if info.ban ~= nil and info.ban[2] ~= nil then
        infoToDS.banChat = info.ban[2];
    else
        infoToDS.banChat = {reason = "", end_time = 0};
    end

    if info.is_robot ~= nil then
        infoToDS.bAIPlayer = info.is_robot;
        sandbox.LogShippingDS(string.format("sync_player_info received, uid=[%d] name=[%s] is_robot=[%s]", uid, info.name, info.is_robot));
    end

    -- 旧的穿戴逻辑 开始
    local itemList = {};
    for i, v in pairs(info.wear) do
        local item = { ItemTableID = v, Count = 1 };
        table.insert(itemList, item);
    end
    infoToDS.ItemList = itemList;

    local allWear = {};
    if info.all_wear then
        for i = 1, 4 do
            local itemList = {};
            local wear = info.all_wear[i];
            if wear == nil then
                local rolewearInfo = { RolewearInfo = itemList, IsLocked = true };
                table.insert(allWear, rolewearInfo);
            else
                for i, v in pairs(wear) do
                    local item = { ItemTableID = v, Count = 1 };
                    table.insert(itemList, item);
                end
                local rolewearInfo = { RolewearInfo = itemList, IsLocked = false };
                table.insert(allWear, rolewearInfo);
            end
        end
    end
    infoToDS.AllWear = allWear;
    -- 旧的穿戴逻辑 结束

    local itemList = {};
    if info.wear_ext then
        for i, v in pairs(info.wear_ext) do
            if v and next(v) ~= nil and v[1] then
                local item = {};
                item.ItemTableID = v[1];
                local color_id = v[2] or 0;
                local pattern_id = v[3] or 0;
                item.AdditionIntData = {color_id, pattern_id};
                item.Count = 1;
                table.insert(itemList, item);
            end
        end
    end
    if next(itemList) ~= nil then
        infoToDS.ItemList = itemList;
        log_tree("ItemList: ", infoToDS.ItemList);
    end

    local allWear = {};
    if info.all_wear_ext then
        for i = 1, 4 do
            local itemList = {};
            local wear = info.all_wear_ext[i];
            if wear == nil then
                local rolewearInfo = { RolewearInfo = itemList, IsLocked = true };
                table.insert(allWear, rolewearInfo);
            else
                for i, v in pairs(wear) do
                    if v and next(v) ~= nil and v[1] then
                        local item = {};
                        item.ItemTableID = v[1];
                        local color_id = v[2] or 0;
                        local pattern_id = v[3] or 0;
                        item.AdditionIntData = {color_id, pattern_id};
                        item.Count = 1;
                        table.insert(itemList, item);
                    end
                end
                local rolewearInfo = { RolewearInfo = itemList, IsLocked = false };
                table.insert(allWear, rolewearInfo);
            end
        end
    end
    if next(allWear) ~= nil then
        infoToDS.AllWear = allWear;
    end

    infoToDS.RolewearIndex = info.use_rolewear or 1;

	local expressionList = {};
	if info.is_robot ~= nil and info.expression then
		if info.is_robot ~= true then

			for i,v in pairs(info.expression) do
				local item = { ItemTableID = v, Count = 1};
				table.insert(expressionList, item);
			end
		end
	end
    infoToDS.ExpressionItemList = expressionList;

	-- symigao: sync task process data
	local taskDataList = {};
	if info.task_list ~= nil then
		for i,v in pairs(info.task_list) do
			local item = { task_id = v.task_id, process = v.process, ext_info=v.ext_info};
			table.insert(taskDataList, item);
		end
	end
	infoToDS.TaskDataList = taskDataList;
    
    local fireworksInfo = {};
    if info.fireworks_info then
        for i, v in pairs(info.fireworks_info) do
            local item = { ItemTableID = v.item_id, Count = v.cur_count };
            log_tree("firework : ", item)
            table.insert(fireworksInfo, item);
        end
    end

    if info.ingame_use_item_info then
        for i, v in pairs(info.ingame_use_item_info) do
            local item = { ItemTableID = i, Count = v.count };
            log_tree("use_item_info : ", item)
            table.insert(fireworksInfo, item);
        end
    end

    infoToDS.fireworksInfo = fireworksInfo;

    local weaponList = {};
    if info.weapon_skin_list then
        for i, v in pairs(info.weapon_skin_list) do
            sandbox.LogNormal("v : "..v)
            local item = { ItemTableID = v, Count = 1 };
            table.insert(weaponList, item);
        end
    end
    infoToDS.WeaponAvatarList = weaponList;
    sandbox.LogNormal("print infoToDS.WeaponAvatar");
    log_tree("WeaponAvatar: ", infoToDS.WeaponAvatar);

    -- 载具
    local vehicleSkinList = {};
    if info.vst ~= nil then
        for i, v in pairs(info.vst) do
            if v > 0 then
                local item = { ItemTableID = v, Count = 1 };
                table.insert(vehicleSkinList, item);
            end
        end
    end
    infoToDS.VehicleAvatarList = vehicleSkinList;
    sandbox.LogNormal("print infoToDS.VehicleAvatarList");
    log_tree("VehicleAvatarList: ", infoToDS.VehicleAvatarList);

    -- 消耗品(预留)
    infoToDS.ConsumableAvatar = {};

    -- 装备(背包/头盔/防弹衣)
    infoToDS.EquipmentAvatar = {};
    if info.bag_skin ~= nil then
        infoToDS.EquipmentAvatar.BagAvatar = info.bag_skin;
    end
    if info.helmet_skin ~= nil then
        infoToDS.EquipmentAvatar.HelmetAvatar = info.helmet_skin;
    end
    if info.armor_skin ~= nil then
        infoToDS.EquipmentAvatar.ArmorAvatar = info.armor_skin;
    end
    sandbox.LogNormal("print infoToDS.EquipmentAvatar");
    log_tree("EquipmentAvatar: ", infoToDS.EquipmentAvatar);


    -- 观战人物信息名片 begin
    local playerOBInfoList = {};
    if info.ob_battle_record ~= nil then
        playerOBInfoList.IsEnableOB = info.ob_battle_record.watch_privacy == 1;
        playerOBInfoList.BattleMode = info.ob_battle_record.mode;
        if info.ob_battle_record.game_num ~= nil then
            playerOBInfoList.ValidBattleInfo = true;
            playerOBInfoList.GameCount = info.ob_battle_record.game_num;
            playerOBInfoList.WinCount = info.ob_battle_record.win_num;
            playerOBInfoList.TopTenCount = info.ob_battle_record.top10;
            playerOBInfoList.KillNum = info.ob_battle_record.kill_num;
            playerOBInfoList.KDNum = info.ob_battle_record.kd;
        else
            playerOBInfoList.IsEnableOB = false;
            playerOBInfoList.ValidBattleInfo = true;
            playerOBInfoList.GameCount = 0;
            playerOBInfoList.WinCount = 0;
            playerOBInfoList.TopTenCount = 0;
            playerOBInfoList.KillNum = 0;
            playerOBInfoList.KDNum = 0;
        end
    else
        playerOBInfoList.IsEnableOB = false;
        playerOBInfoList.BattleMode = 0;
        playerOBInfoList.ValidBattleInfo = true;
        playerOBInfoList.GameCount = 0;
        playerOBInfoList.WinCount = 0;
        playerOBInfoList.TopTenCount = 0;
        playerOBInfoList.KillNum = 0;
        playerOBInfoList.KDNum = 0;
    end

    playerOBInfoList.UID = uid;
    playerOBInfoList.PlayerKey = 0;
    playerOBInfoList.SegmentLevel = info.cur_mode_seg_level or info.segment_level;
    playerOBInfoList.ZoneID = info.zone_id or 0;

    if info.weapon_show_list ~= nil and
       info.weapon_show_list[1] ~= nil then
        playerOBInfoList.ShowWeaponID = info.weapon_show_list[1];
    else
        playerOBInfoList.ShowWeaponID = 0;
    end
    infoToDS.PlayerOBInfo = playerOBInfoList;
    log_tree("playerOBInfoList", playerOBInfoList);
    log_tree("infoToDS.PlayerOBInfo", infoToDS.PlayerOBInfo);
    -- 观战人物信息名片 end

    infoToDS.specialPickItem = info.item_info;
	infoToDS.LastGameResultTime = (info.last_game_result_time or 0);

    -- 宠物
    if info.pet_info ~= nil then
        infoToDS.PetInfo = {};
        infoToDS.PetInfo.PetId = (info.pet_info.pet_id or -1);
        infoToDS.PetInfo.PetLevel = (info.pet_info.pet_level or 0);
        infoToDS.PetInfo.PetCfgId = (infoToDS.PetInfo.PetId * 10000 + infoToDS.PetInfo.PetLevel);
    end

    local key = Server.SyncNewDSPlayer(DSUtils, uid, infoToDS);
    NetUtil.SendPacket(MsgToLobby.sync_login_key, uid, key);
end

PacketCallbacks.sync_corps_info = function(info)
    sandbox.LogNormal(string.format("sync_corps_info received" ));
    log_tree("info", info);

    local InfoArray = {};

    for i, v in pairs(info) do
         local item = {};
         item.CorpsID = i;
         item.CorpsName = v.corps_name;
         item.Icon = (v.corps_icon  or 0);
         item.SegmentLevel=(v.segment_level or 0);
         table.insert(InfoArray, item);
    end

    Server.SyncNewCorpsInfo(DSUtils,InfoArray);
end

PacketCallbacks.watch_player_info = function(uid, info)
    sandbox.LogNormal(string.format("watch_player_info received, uid=[%d] name=[%s]", uid, info.name));
    log_tree("info", info);

    local infoToDS = {};
    infoToDS.PlayerType = "PureWatcher";
    infoToDS.PlayerName = (info.name or "");
    infoToDS.bAnchorOB = (info.is_anchor_ob or false);
    infoToDS.bReconnect = false;
    infoToDS.WatchUID = (info.watch_uid or 0);

    local key = Server.SyncNewDSPlayer(DSUtils, uid, infoToDS);
    NetUtil.SendPacket(MsgToLobby.watch_login_key, uid, key);
end

PacketCallbacks.try_reconnect = function(uid)
    sandbox.LogNormal(string.format("try_reconnect received, uid=[%d]", uid));

    local infoToDS = { bReconnect = true, PlayerType = "Normal" };
    local key = Server.SyncNewDSPlayer(DSUtils, uid, infoToDS);
    NetUtil.SendPacket(MsgToLobby.try_reconnect_rsp, uid, key);
end

PacketCallbacks.watch_try_reconnect = function(uid)
    sandbox.LogNormal(string.format("watch_try_reconnect received, uid=[%d]", uid));

    local infoToDS = { bReconnect = true, PlayerType = "PureWatcher" };
    local key = Server.SyncNewDSPlayer(DSUtils, uid, infoToDS);
    NetUtil.SendPacket(MsgToLobby.watch_try_reconnect_rsp, uid, key);
end

PacketCallbacks.player_exit = function(uid, reason)
    sandbox.LogNormal(string.format("player_exit received, uid=[%d] reason=[%s]", uid, reason));

    Server.SyncDSPlayerExit(DSUtils, uid, false);
end

PacketCallbacks.watch_player_exit = function(uid, reason)
    sandbox.LogNormal(string.format("watch_player_exit received, uid=[%d] reason=[%s]", uid, reason));

    Server.SyncDSPlayerExit(DSUtils, uid, true);
end

PacketCallbacks.game_exit = function()
    sandbox.LogNormal("game_exit received");

    Server.SyncGameExit();
    Server.ShutdownProcess();
end


PacketCallbacks.use_item_rsp = function(uid, result, resid, count)
    sandbox.LogNormal(string.format("use_item_rsp received, uid=[%d] reason=[%d] resid=[%d] count=[%d]", uid, result, resid, count));
    Server.PlayerPaintDecalResponse(DSUtils, uid, result, resid, count);
end