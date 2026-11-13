ChangeWarZoneSystem = ChangeWarZoneSystem or
{
    -- 获得当前位置后，是否弹设置区域框
    ShowChangeBoxOnGetLocationFinished = false,

    -- 获得位置成功后回调
    GetLocationCallback = nil,

    -- 有战区/修改战区后的回调
    HasWarZoneCallback = nil,

    -- 权限允许了的回调
    PermittedCallback = nil,

    registerEvent = false,

    -- 是否尝试过设置战区
    isTryToSetWarZone = false,
}

--[[
	@desc 获得当前位置
	@param succCallback [optional] 获得位置成功后回调， succCallback(errorCode, cityCode, latitude, longitude)
]]
function ChangeWarZoneSystem.GetLocation(succCallback, errorCallback)
	ChangeWarZoneSystem._Reset()
	local _succCallback = succCallback
	ChangeWarZoneSystem._AcquirePermission(function()
	    ChangeWarZoneSystem.GetLocationCallback = _succCallback
	    ChangeWarZoneSystem._RegisterLocationChange()
	    LocationSystem.startLocation()
		end, errorCallback)
end

--[[
    @desc 检测战区数据
          1.先检测是否开启定位权限，没开启则弹框
          2.如果玩家当前没有战区，并且可以取到当前citycode，将当前citycode发送给服务器，服务器回送成功后，调用succCallback
    @param showChangeBoxOnGetLocationFinished [optional] 当获取到位置后，是否弹框设置
    @param HasWarZoneCallback [optional] 玩家设置好战区后的回调
    @param alreadyHasWarZoneCallback 已经有战区的回调
    @return true表示一切顺利，false表示中间有问题（权限没开，或者没有战区数据等）
]]
function ChangeWarZoneSystem.CheckData(showChangeBoxOnGetLocationFinished, hasWarZoneCallback)
	log("=======================ChangeWarZoneSystem.CheckData")
	ChangeWarZoneSystem._Reset()
    ChangeWarZoneSystem.HasWarZoneCallback = hasWarZoneCallback  -- 为了ios，这一句要加上
	ChangeWarZoneSystem._AcquirePermission(function()
		if ChangeWarZoneSystem._HasZone() then
			if hasWarZoneCallback ~= nil then
				hasWarZoneCallback()
				ChangeWarZoneSystem.HasWarZoneCallback = nil
			end
		else
		    ChangeWarZoneSystem.HasWarZoneCallback = hasWarZoneCallback
            ChangeWarZoneSystem.ShowChangeBoxOnGetLocationFinished = showChangeBoxOnGetLocationFinished
            ChangeWarZoneSystem._RegisterLocationChange()
            LocationSystem.startLocation()
		end
		end)
end

function ChangeWarZoneSystem.RequestChangeWarZone(hasWarZoneCallback)
	ChangeWarZoneSystem._Reset()
	local _hasWarZoneCallback = hasWarZoneCallback
	ChangeWarZoneSystem._AcquirePermission(function()
		ChangeWarZoneSystem.GetLocation(function(errorCode, cityCode, latitude, longitude)
	        ChangeWarZoneSystem.HasWarZoneCallback = _hasWarZoneCallback
			if errorCode == 0 then
                ChangeWarZoneUI.Show(cityCode)
			end
			end)
		end)
end

--[[
	@desc 请求设置战区返回
]]
function ChangeWarZoneSystem.OnModifyZoneSucc(ret_code, warzone_id)
    if ret_code == 0 then
	    local lbs_warzone_info = DataMgr.lbs_warzone_info
	    if lbs_warzone_info == nil then
	        lbs_warzone_info = {}
	        DataMgr.lbs_warzone_info = lbs_warzone_info
	    end
	    if lbs_warzone_info ~= nil then
	        lbs_warzone_info.warzone_id = warzone_id
	    end
	    if ChangeWarZoneSystem.HasWarZoneCallback ~= nil then
	        ChangeWarZoneSystem.HasWarZoneCallback()
	    end
	else
		DataMgr.ShowMessageBoxByID(ret_code);
    -- elseif ret_code == 1 then
    --     DataMgr.ShowNoticeByString("无效的战区id");
    -- elseif ret_code == 2 then
    --     DataMgr.ShowNoticeByString("当前就是这个战区id");
    -- elseif ret_code == 3 then
    --     DataMgr.ShowNoticeByString("更改次数已达上限");
    -- elseif ret_code == 4 then
    --     DataMgr.ShowNoticeByString("后台获取数据失败");
    end
    ChangeWarZoneSystem.HasWarZoneCallback = nil
end

--[[
	@desc 游戏进入前台
]]
function ChangeWarZoneSystem.OnEnterForeground()
	local isPermitted = LocationSystem.isPermitted()
	if isPermitted then
		-- 有监听允许的回调，调用它
		-- 还没有战区，后台请求设置战区
		if ChangeWarZoneSystem.PermittedCallback ~= nil then
			ChangeWarZoneSystem.PermittedCallback()
			ChangeWarZoneSystem.PermittedCallback = nil
		else
			if not ChangeWarZoneSystem._HasZone() and not ChangeWarZoneSystem.isTryToSetWarZone then
				log("==ChangeWarZoneSystem.OnEnterForeground== try to set warzone")
				ChangeWarZoneSystem.isTryToSetWarZone = true
				ChangeWarZoneSystem.CheckData(false, ChangeWarZoneSystem.HasWarZoneCallback)
			end
		end
	else  -- IOS下， 如果第一次安装没开GPS进去，设置GPS后，必须回来后台弹第一次请求框
		if not ChangeWarZoneSystem._HasZone() then
			local oldHasCityCodeCallback = ChangeWarZoneSystem.HasWarZoneCallback
			ChangeWarZoneSystem._Reset()
			ChangeWarZoneSystem.HasWarZoneCallback = oldHasCityCodeCallback
		    ChangeWarZoneSystem._RegisterLocationChange()
		end
	end
end

--[[
	@desc 是否有战区
	@return 有战区返回true，否则false
]]
function ChangeWarZoneSystem._HasZone()
    local lbs_warzone_info = DataMgr.lbs_warzone_info
    return lbs_warzone_info ~= nil and lbs_warzone_info.warzone_id ~= -1;
end

--[[
	@desc 获取访问位置权限
	@param [optional] 获取成功后调用 permittedCallback
]]
function ChangeWarZoneSystem._AcquirePermission(permittedCallback, errorCallback)
	if LocationSystem.checkPermission() then
		if permittedCallback ~= nil then
			permittedCallback()
		end
	else
		if errorCallback ~= nil then
			errorCallback()
		end
		-- ChangeWarZoneSystem.PermittedCallback = permittedCallback
	end
end

--[[
	@desc 重置数据
]]
function ChangeWarZoneSystem:_Reset()
    ChangeWarZoneSystem.ShowChangeBoxOnGetLocationFinished = false
    ChangeWarZoneSystem.GetLocationCallback = nil
    ChangeWarZoneSystem.HasWarZoneCallback = nil
    ChangeWarZoneSystem.PermittedCallback = nil
end


function ChangeWarZoneSystem._OnRequestCityCodeFinished()
	if LocationSystem.cityCode ~= 0 then
	    LocationSystem.cityCode = LocationSystem.AdjustCityCode(LocationSystem.cityCode)
        if ChangeWarZoneSystem.ShowChangeBoxOnGetLocationFinished then
            ChangeWarZoneUI.Show(LocationSystem.cityCode)
        else
        	-- 如果当前还没有战区，请求
        	if not ChangeWarZoneSystem._HasZone() then
                WarZoneRankSystem.ModifyWarZoneReq(LocationSystem.cityCode, true)
        	end
        end
	end
    if ChangeWarZoneSystem.GetLocationCallback ~= nil then
    	ChangeWarZoneSystem.GetLocationCallback(0, LocationSystem.cityCode, LocationSystem.latitude, LocationSystem.longitude)
	    ChangeWarZoneSystem.GetLocationCallback = nil
    end
    ChangeWarZoneSystem.ShowChangeBoxOnGetLocationFinished = nil
end
--[[
    @desc sdk获取本机位置回调
]]
function ChangeWarZoneSystem._OnRequestLocationFinished(eventType, eventID, vars)
    if vars.errorCode == 0 then
    	LocationSystem.GetCityCode(vars.latitude, vars.longitude)
    else
        log("error:ChangeWarZoneSystem.OnRequestLocationFinished failed. error="..tostring(vars.errorCode))
        if ChangeWarZoneSystem.GetLocationCallback ~= nil then
	    	ChangeWarZoneSystem.GetLocationCallback(vars.errorCode)
		    ChangeWarZoneSystem.GetLocationCallback = nil
	    end
	    ChangeWarZoneSystem.ShowChangeBoxOnGetLocationFinished = nil
    end
end

--[[
    @desc 监听位置信息改变
]]
function ChangeWarZoneSystem._RegisterLocationChange()
	if ChangeWarZoneSystem.registerEvent  then
		return
	end
	ChangeWarZoneSystem.registerEvent = true
    EventSystem:registEvent(EVENTTYPE_PLATFORM, EVENT_PLATFORM_REQUEST_LOCATION_FINISH, ChangeWarZoneSystem._OnRequestLocationFinished)
    EventSystem:registEvent(EVENTTYPE_RANK, EVENTID_WARZONE_GET_CITYCODE, ChangeWarZoneSystem._OnRequestCityCodeFinished)
end