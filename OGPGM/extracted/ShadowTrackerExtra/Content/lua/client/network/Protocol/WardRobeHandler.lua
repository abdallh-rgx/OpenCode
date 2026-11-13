
--仓库
WardRobeHandler = WardRobeHandler or
{
    
}

function WardRobeHandler.send_depot_put_on_req(insID)
    NetManager.SendPkg(eMsgID.eDepotPutOn, insID)
end

function WardRobeHandler.on_depot_put_on_rsp(res, item, olditem)
    --todo write response code here
    WardrobeSystem.on_puton_rsp(res, item, olditem)
end

function WardRobeHandler.send_depot_put_down_req(insID)
    NetManager.SendPkg(eMsgID.eDepotPutDown, insID)
end

function WardRobeHandler.on_depot_put_down_rsp(res, item)
    --todo write response code here
    WardrobeSystem.on_putdown_rsp(res, item)
end
