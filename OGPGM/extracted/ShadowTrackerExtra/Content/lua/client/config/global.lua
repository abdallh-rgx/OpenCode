--[[全局的配置]]--

globalConfig = globalConfig or
{
	--是否直连服务器，否则选区选服. 之所以放在这里是因为iOS外网提审之后patch要打logic_login.lua出去，但是构建的连预发布服务器的ipa在测试patch的时候，会被外网patch强制直连外网服.
    isDirectConnect = true;
	--是否在windows上显示拍脸系统——face_slap_system
    isShowFaceSlapOnWindows = false;

}

function globalConfig.IsDirectConnect()
	--CE需要修改成直连
	if Client.IsCEVersion() then
		return true;
	end
	
	return globalConfig.isDirectConnect;
end
