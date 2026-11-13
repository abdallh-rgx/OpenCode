--sami 印度商城相关
StoreIndiaUtils = 
{
    H5_Show_Type_None = 0,
    H5_Show_Type_Bind = 1,
    H5_Show_Type_India = 2,
    
    h5ShowType = 0,     --0代表不展示，1代表展示需要绑定手机，2代表展示商城链接
    h5StoreUrl = "",    --不同区域采用不同的url,没有为空
}



--请求h5商城入口信息
function StoreIndiaUtils.ReqH5Market()
    NetUtil.SendPriorityPkg(false, "get_h5_market_rsp", "get_h5_market_req")
end


function StoreIndiaUtils.get_h5_market_rsp(show_type, url)
    log("StoreIndiaUtils.get_h5_market_rsp show_type="..show_type..",url="..url)
    StoreIndiaUtils.h5ShowType = show_type
    StoreIndiaUtils.h5StoreUrl = url
    EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_INDIA_H5);
end

--监听绑定手机错误
function StoreIndiaUtils.delete_account_bind_rsp(ok)
    log("StoreIndiaUtils.delete_account_bind_rsp ok="..ok)
    if ok == "unbind_time_error" then
        ShowNotice(6707)
    end
end

s2c["get_h5_market_rsp"] = StoreIndiaUtils.get_h5_market_rsp;
s2c["delete_account_bind_rsp"] = StoreIndiaUtils.delete_account_bind_rsp;

