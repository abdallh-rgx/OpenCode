AdvertiseSystem = AdvertiseSystem or {}

local Advertise_RefreshCooldownTime = 30 * 60; --广告刷新时间(秒)，假如处于cd时间，不会重复刷新广告，为0时无cd
local lastRefreshTime = 0;

--请求广告数据
function  AdvertiseSystem.GetAdvertiseInfo(need_pull_cache, ad_info, unit_id)
	log("AdvertiseSystem.GetAdvertiseInfo : " .. need_pull_cache)
	
	--由于战斗内重连，收到协议加载广告偶现崩溃，在此处加一层保护，战斗内不会因为此协议加载广告
	local curStatus = string.lower(LuaClassObj.GetGameStatus(bp_global));
	if curStatus == "fighting" then 
		return;
	end
	
	if Advertise_RefreshCooldownTime > 0 then
		if  FuncUtil.GetServerTimeInSec() - lastRefreshTime <= Advertise_RefreshCooldownTime then
			return;
		else
			lastRefreshTime = FuncUtil.GetServerTimeInSec();
		end
	end
	local t_unitID = ""
	if unit_id ~= nil then
		if string.lower(Client.GetDevicePlatformName()) == "ios" then
			if unit_id["ios"] ~= nil then
				log("AdvertiseSystem.GetAdvertiseInfo GetKey ios: " .. unit_id["ios"])
				t_unitID = unit_id["ios"];
			end
		else
			if unit_id["aos"] ~= nil then
				log("AdvertiseSystem.GetAdvertiseInfo GetKey aos: " .. unit_id["aos"])
				t_unitID = unit_id["aos"];
			end
		end
	else
		log("[error]AdvertiseSystem.UpdateAdvertiseInfo unit_id is null");
	end
	if need_pull_cache == 1 and t_unitID ~= "" then
		BP_Global_AdvertiseUnitID = t_unitID;
		GlobalData.LoadAdvertise();
	end
end


--上报玩家播放广告协议
function AdvertiseSystem.UpdatePlayAdvertiseEvent()
	log("AdvertiseSystem.UpdatePlayAdvertiseEvent");
	NetUtil.SendPkg("play_google_ad");
end

--获取广告任务是否展示
function AdvertiseSystem.GetAdvertiseShowTask()
	NetUtil.SendPkg("show_google_task_req")
end

--获取广告任务是否展示回包
function AdvertiseSystem.SetAdvertiseShowTask(needShow)
	log("AdvertiseSystem.SetAdvertiseTask needShow = " .. tostring(needShow));
	BP_Global_AdvertiseNeedShowtask = needShow;
	--刷新任务界面数据
	if TaskUI.isShow == true then
		TaskUI.RefreshTaskInfo();
		LuaClassObj.HandleUIMessage(bp_task, "UpdatePanel");
	end
end

--广告的C++的加载回调
function OnAdvertiseLoad(result)
	log("AdvertiseSystem.OnAdvertiseLoad result = " .. tostring(result));
end

--广告的C++的播放回调
function OnAdvertisePlay(result)
	log("AdvertiseSystem.OnAdvertisePlay result = " .. tostring(result));
end

s2c["update_google_ad_info"] = AdvertiseSystem.GetAdvertiseInfo; --获取广告相关数据
s2c["show_google_task_rsp"] = AdvertiseSystem.SetAdvertiseShowTask; --获取广告任务是否展示