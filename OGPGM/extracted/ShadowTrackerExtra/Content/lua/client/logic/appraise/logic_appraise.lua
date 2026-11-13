--[[
引导评价相关逻辑
]]--
AppraiseSystem = AppraiseSystem or
{
	bShowUI = false,
	
}

function AppraiseSystem.Init()
    --TODO
	--Test
	
end

function AppraiseSystem.Release()
    --TODO
end


function AppraiseSystem.OnNotifyAppraise()
	if Client.GetPublishRegion() == "JAPAN" then
		return;
	end
	local curStatus = string.lower(LuaClassObj.GetGameStatus(bp_appraise));
	if string.lower(curStatus) == "lobby" then
		AppraiseUI.ShowUI();
	elseif string.lower(curStatus) == "login" then
		AppraiseSystem.bShowUI = false ;
	else
		AppraiseSystem.bShowUI = true ;
	end
end

function AppraiseSystem.Clear()
	AppraiseSystem.bShowUI = false ;
end

s2c["guild_review_notify"] = AppraiseSystem.OnNotifyAppraise;
