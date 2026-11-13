
--[[
samizheng 协议配置文件 
本文件是自动生成，请勿手动修改
]]
--协议类型
eMsgID = eMsgID or { }

--网络协议配置类
NetConfig = NetConfig or
{
    msgMap = {},
    reconnectMsgMap = {},
}

--网络协议配置初始化
function NetConfig.Init()
    --协议枚举类型
    eMsgID =
    {
        eHeartBeat = 1001,
        eMarketJumpInfo = 1101,
        eShopJumpInfo = 1102,
        eDepotPutOn = 1201,
        eDepotPutDown = 1202,
        eBatchGetBinProfile = 1301,
        eQuestionnaireProfile = 1302,
        eCreateRoom = 1303,

    }

    --[[
        协议配置参数说明
        id - 协议id
        req - 发送协议名
        res - 回包协议名
    ]]
    NetConfig.msgMap =
    {
        [eMsgID.eHeartBeat] = {req = "heart_beat"; res = "heart_beat"; isUnique = 1; queueType = 0; isLock = 0, timeout = 30, needRsp = 0, timeInterval = 0, handler = NetHeartBeatHandler; };
        [eMsgID.eMarketJumpInfo] = {req = "get_market_jump_info"; res = "get_market_jump_info_rsp"; isUnique = 0; queueType = 2; isLock = 1, timeout = 10, needRsp = 0, timeInterval = 0, handler = NetJumpHandler; };
        [eMsgID.eShopJumpInfo] = {req = "get_shop_jump_info"; res = "get_shop_jump_info_rsp"; isUnique = 0; queueType = 2; isLock = 1, timeout = 10, needRsp = 0, timeInterval = 0, handler = NetJumpHandler; };
        [eMsgID.eDepotPutOn] = {req = "depot_put_on_req"; res = "depot_put_on_rsp"; isUnique = 0; queueType = 2; isLock = 1, timeout = 10, needRsp = 0, timeInterval = 0, handler = WardRobeHandler; };
        [eMsgID.eDepotPutDown] = {req = "depot_put_down_req"; res = "depot_put_down_rsp"; isUnique = 0; queueType = 2; isLock = 1, timeout = 10, needRsp = 0, timeInterval = 0, handler = WardRobeHandler; };
        [eMsgID.eBatchGetBinProfile] = {req = "batch_get_bin_profile_req"; res = "batch_get_bin_profile_rsp"; isUnique = 0; queueType = 2; isLock = 0, timeout = 10, needRsp = 0, timeInterval = 0, handler = ProfileHander; };
        [eMsgID.eQuestionnaireProfile] = {req = "questionnaire_finished_report_req"; res = "questionnaire_finished_report_rsp"; isUnique = 1; queueType = 2; isLock = 0, timeout = 30, needRsp = 1, timeInterval = 0, handler = QuestionnaireHander; };
        [eMsgID.eCreateRoom] = {req = "create_room_request"; res = "create_room_respond"; isUnique = 1; queueType = 0; isLock = 1, timeout = 30, needRsp = 0, timeInterval = 0, handler = CreateRoomHandler; };

    }
    
    --关键协议，超时需要走重登录
    NetConfig.reconnectMsgMap = 
    {
        eMsgID.eHeartBeat,

    }

    --协议监听
    s2c["heart_beat"] = function(...) NetManager.OnRecvPkg(eMsgID.eHeartBeat, ...) end
    s2c["get_market_jump_info_rsp"] = function(...) NetManager.OnRecvPkg(eMsgID.eMarketJumpInfo, ...) end
    s2c["get_shop_jump_info_rsp"] = function(...) NetManager.OnRecvPkg(eMsgID.eShopJumpInfo, ...) end
    s2c["depot_put_on_rsp"] = function(...) NetManager.OnRecvPkg(eMsgID.eDepotPutOn, ...) end
    s2c["depot_put_down_rsp"] = function(...) NetManager.OnRecvPkg(eMsgID.eDepotPutDown, ...) end
    s2c["batch_get_bin_profile_rsp"] = function(...) NetManager.OnRecvPkg(eMsgID.eBatchGetBinProfile, ...) end
    s2c["questionnaire_finished_report_rsp"] = function(...) NetManager.OnRecvPkg(eMsgID.eQuestionnaireProfile, ...) end
    s2c["create_room_respond"] = function(...) NetManager.OnRecvPkg(eMsgID.eCreateRoom, ...) end

end
