--加载界面

LoadingUI = LoadingUI or 
{
	isShowing = false;
}

--注册widget
function bp_loading_RegisterUI()
  LuaClassObj.SubUIWidgetList(bp_loading,
    {{Path="/Game/UMG/UI_BP/LoginLoading/Login_Loading_UIBP.Login_Loading_UIBP_C", Container="Top", ZOrder=BP_ENUM_UI_COMMON_ITEMTIPS_ZORDER-3}},
    {"Lobby"},
	true,
	true
  );
end

function bp_loading_OnModeSwitched(gamestatus)
	--log("OnModeSwitched gamestatus = " .. gamestatus);
    -- 进入场景成功关闭loading(战斗场景不要依赖于UI的切换)，否则会导致场景并未加载完毕，loading却没了--
    if gamestatus ~= "Fighting" then
    	LoadingUI.RefreshLoadPercent(1);
    end
end


BP_Percent_f = 1.0;
BP_InitPercent = 0;
BP_LoadingTo = 0;
BP_LoadingBgPath = "";

local function getPathFromTable(tbl)
	local _tempInfoTb = {}
	local now = FuncUtil.GetServerTimeInSec()
	for key, value in pairs(tbl) do
		---format: %Y-%m-%d %H:%M:%S
		if FuncUtil:StringTimeToUnixTime(value.begin_time) < now and FuncUtil:StringTimeToUnixTime(value.end_time) > now then
			table.insert(_tempInfoTb,value)
		end
	end
	local weightSum = 0;
	for key,value in pairs(_tempInfoTb) do
		weightSum = weightSum + value.weight;
	end
	if weightSum > 0 then
		local seed = math.random(weightSum);
		local curIndex = 0;
		for key,value in pairs(_tempInfoTb) do
			curIndex = curIndex + value.weight;
			if curIndex >= seed then
				return value.path;
			end
		end
	else
		--log("BP_LOADING CAN NOT GET Legal Path!!!")
		for key, value in pairs(tbl) do
			return value.path;
		end
	end
end

function EventBpLoadingSetBgResPath()
	local prefix_pros = BP_LoadingTo==1 and "battle" or "login";
	local prefix_reg = "gl";
	local strRegion = Client.GetPublishRegion();
    if strRegion == "JAPAN" then
		prefix_reg="jp";
	elseif strRegion == "KOREA" then
		prefix_reg="kr";
	end
	local tb = Client.GetTable(prefix_reg.."_"..prefix_pros.."_loading_table");
	BP_LoadingBgPath = getPathFromTable(tb);
end

function EventBpLoadingSetBgResPathByServer()
	local prefix_pros = BP_LoadingTo==1 and "battle" or "login";
	local tbString = GlobalData.GetGlobalConfigStringValue(prefix_pros.."_loading_table")
	--log("=ldUI=>SERVER "..tbString)
	if not tbString or tbString == "" then
		EventBpLoadingSetBgResPath()
	else
		local tb = GlobalData.Unserialize(tbString)
		if not tb or tb == {} then
			EventBpLoadingSetBgResPath()
		else
			BP_LoadingBgPath = getPathFromTable(tb);
		end
	end
end

function LoadingUI.RefreshLoadPercent(p)
	--log("---scene object loading finished, start loading progress bar----"..p);

	if p >= 1 then
		LoadingUI.isShowing = false;
	end

    BP_Percent_f = p;
    LuaClassObj.HandleUIMessage(bp_loading, "RefreshLoading");
end

function LoadingUI:Init()
	if not LoadingUI.isShowing then
		LoadingUI.isShowing = true;
		log("---show loading ui---");
		
		LuaClassObj.HandleUIMessage(bp_loading, "UIShow");
	end
end

function LoadingUI:Hide()
	log("---hide loading ui---");
	LoadingUI.isShowing = false;
	LuaClassObj.HandleUIMessage(bp_loading, "UIHide");
end

function LoadingUI:Release()
	LoadingUI.isShowing = false;
end


---服务器下行消息回调
function LoadingUI.loadpic_cfg_refresh(serverTableSetTime)
	--判断是否需要拉取最新表
	local res = GlobalData.GetGlobalConfigIntValue("TableSetTime")
	if res == nil or res < serverTableSetTime then
		local region_index = 0;
		local strRegion = Client.GetPublishRegion();
		if strRegion == "JAPAN" then
			region_index= 2;
		elseif strRegion == "KOREA" then
			region_index= 1;
		end
		NetUtil.SendPkg("get_loading_pic_cfg",region_index);
	end
end

function LoadingUI.get_loading_pic_cfg_rsp(login_loading_table,battle_loading_table)
	local loginStrings = GlobalData.Serialize(login_loading_table)
	--log("=ldUI=>SERVER_rsp: "..loginStrings);
	GlobalData.SetGlobalConfigData("login_loading_table",loginStrings , 2);
	local battleStrings = GlobalData.Serialize(battle_loading_table)
	GlobalData.SetGlobalConfigData("battle_loading_table",battleStrings , 2);
end

s2c = s2c or {};
s2c["loadpic_cfg_refresh"] = LoadingUI.loadpic_cfg_refresh;
s2c["get_loading_pic_cfg_rsp"] = LoadingUI.get_loading_pic_cfg_rsp;