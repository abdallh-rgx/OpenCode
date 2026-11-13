--[[
take_activity_award_req
take_activity_award_res

invite_new_player_succ_request
get_activity_one_res

get_activity_list_res
--]]


PlatformFriendsUnregSystem = PlatformFriendsUnregSystem or
{

}

function PlatformFriendsUnregSystem.GetActivityData()
    local data = DataMgr.GetActivityByType(ActivityType.INVITEFBFRIENDS);
    if data ~= nil then
    	--log_tree("[HHF]PlatformFriendsUnregSystem.GetActivityData, data = ", data, "[HHF]");
    else
    	log("[HHF]PlatformFriendsUnregSystem.GetActivityData, return nil.");
    end
    
    return data;
end

function PlatformFriendsUnregSystem.ReportInvitedFriendsNumber(number)
    log("[HHF]PlatformFriendsUnregSystem.ReportInvitedFriendsNumber, number = " .. number);
    if number > 0 then
    	NetUtil.SendPkg("invite_new_player_succ_request", number);
    end
end

function PlatformFriendsUnregSystem.RequestActivityAward(activityId, awardIndex)
    log("[HHF]PlatformFriendsUnregSystem.RequestActivityAward, activityId = " .. activityId .. ", awardIndex = " .. awardIndex);
	ActivitySystem.Req_TakeActivityAward(activityId, awardIndex)
end