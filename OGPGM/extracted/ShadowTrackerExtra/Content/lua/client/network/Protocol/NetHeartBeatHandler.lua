
--心跳包协议
NetHeartBeatHandler = NetHeartBeatHandler or
{
    
}

function NetHeartBeatHandler.send_heart_beat(curTime)
    NetManager.SendPkg(eMsgID.eHeartBeat, curTime)
end

function NetHeartBeatHandler.on_heart_beat(key, now)
    --todo write response code here
    NetUtil.OnHeartBeatRsp(key, now)
end
