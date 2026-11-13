
--个人信息协议
ProfileHander = ProfileHander or
{
    
}

function ProfileHander.send_batch_get_bin_profile_req(sendSeq, binListUid, rankDataFlag, count)
    NetManager.SendPkg(eMsgID.eBatchGetBinProfile, sendSeq, binListUid, rankDataFlag, count)
end

function ProfileHander.on_batch_get_bin_profile_rsp(sendSeq, res, bin_profiles, hasRankData)
    --todo write response code here
    local profiles = Client.Load(LuaStateWrapper, bin_profiles);
    if profiles then
        ProfileMgr.OnBatchGetProfileRsp(sendSeq, res, profiles, hasRankData);
    else
        log("batch_get_bin_profile_rsp error: cannt load bin_profiles");
    end
end
