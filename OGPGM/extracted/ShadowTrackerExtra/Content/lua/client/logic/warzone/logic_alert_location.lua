AlertLocationSystem = AlertLocationSystem or
{	
	CheckPermissionTimer = nil,
}

function AlertLocationSystem.OnEnter()
	AlertLocationSystem.StartTimer()
end

function AlertLocationSystem.CheckPermission()
	if LocationSystem.isPermitted() then
		LuaClassObj.HandleUIMessage(bp_alert_location, "UIHide");
		AlertLocationSystem.ClearTimer();
	else
		AlertLocationSystem.StartTimer();
	end
end

function AlertLocationSystem.OnLeave()
	AlertLocationSystem.ClearTimer()
end

function AlertLocationSystem.StartTimer()
	AlertLocationSystem.ClearTimer();
    AlertLocationSystem.CheckPermissionTimer = Timer.InsertTimer(1, AlertLocationSystem.CheckPermission, false)
end

function AlertLocationSystem.ClearTimer()
	if AlertLocationSystem.CheckPermissionTimer ~= nil then
		Timer.RemoveTimer(AlertLocationSystem.CheckPermissionTimer)
		AlertLocationSystem.CheckPermissionTimer = nil
	end
end
