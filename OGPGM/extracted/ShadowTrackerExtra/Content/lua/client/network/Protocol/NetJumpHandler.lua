
--跳转功能协议
NetJumpHandler = NetJumpHandler or
{
    
}

function NetJumpHandler.send_get_market_jump_info()
    NetManager.SendPkg(eMsgID.eMarketJumpInfo)
end

function NetJumpHandler.on_get_market_jump_info_rsp(res)
    --todo write response code here
    JumpUtils.bGetJumpMap = true
    JumpUtils.OnRecvMarketJumpInfo(res)
    --仓库图鉴需要此数据筛选，刷新仓库ui
    WardrobeUI.RefreshCurrentTab()
end

function NetJumpHandler.send_get_shop_jump_info()
    NetManager.SendPkg(eMsgID.eShopJumpInfo)
end

function NetJumpHandler.on_get_shop_jump_info_rsp(res)
    --todo write response code here
    JumpUtils.bGetJumpMap = true
    JumpUtils.OnRecvShopJumpInfo(res)
end

