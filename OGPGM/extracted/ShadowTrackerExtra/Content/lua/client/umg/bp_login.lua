LoginUI = LoginUI or
{

}

--蓝图调用
BP_InputOpenId = ""

--服务器信息
BP_STRUCT_ServerInfo =
{
	addrArray = {},
	showAddrInfo = "",
	channelInfo = "",
	serverStatus = 0,
	tab = 0,
};

--服务器列表
BP_ARRAY_ServerList_Info =
{
	BP_STRUCT_ServerInfo = _G.BP_STRUCT_ServerInfo,
};

--当前选择的ServerInfo
BP_SelectedShowServerInfo = 0;


BP_PatchTimeStamp = ""   --上一次Patch 的时间

--注册Widget
function bp_login_RegisterUI()

	LoginUI.initServerList()

	LuaClassObj.SubUIWidgetList(bp_login,
	{
		{Path="/Game/UMG/UI_BP/Login/Login_ServerList_UIBP.Login_ServerList_UIBP_C", Container="Default", ZOrder=0}
	},
	{"Login"},
	false,
	false
	);
end

function LoginUI.initServerList()
	local LOGIN_SERVER_LIST = {
	};
	local strRegion = Client.GetPublishRegion() ;
	log("LoginUI.initServerList strRegion = " .. strRegion);

	if strRegion == "JAPAN" or strRegion == "KOREA" then
		--日韩显示如下
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "0.x.0 日韩主干", addr = {"tcp://101.227.139.182:10007"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "0.x.5 日韩主干", addr = {"tcp://101.226.76.182:12116"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "日韩版-策划0x5测试服", addr = {"tcp://101.226.76.182:12051"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "日韩版-策划主干测试服", addr = {"tcp://101.226.76.182:12043"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "日韩测试1服", addr = {"tcp://101.227.139.182:10015"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "日韩测试2服", addr = {"tcp://101.227.139.182:10019"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "日韩测试3服", addr = {"tcp://101.227.139.182:10029"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "日韩测试4服", addr = {"tcp://101.227.130.125:14033"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "日韩测试5服", addr = {"tcp://101.227.139.182:10023"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "日韩测试6服", addr = {"tcp://101.227.139.182:10025"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "日韩测试7服", addr = {"tcp://101.227.139.182:10027"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "日韩测试8服", addr = {"tcp://101.226.76.182:12528"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "日韩测试9服", addr = {"tcp://101.227.139.182:10033"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "日韩测试10服", addr = {"tcp://101.226.76.182:12003"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "日韩测试11服", addr = {"tcp://101.226.76.182:12005"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "北美测试服", name = "0.x.0 日韩北美测试1服", addr = {"tcp://kr-test.igamecj.com:17500 "}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "北美测试服", name = "0.x.0 日韩北美测试2服", addr = {"tcp://49.51.195.144:17500 "}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "北美测试服", name = "0.x.0 日韩北美测试3服", addr = {"tcp://49.51.36.237:17500"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "北美测试服", name = "0.x.0 日韩北美测试4服", addr = {"tcp://49.51.47.134:17500"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "日韩GPC服", name = "0.x.0 日韩GPC服", addr = {"tcp://101.227.139.182:10009 "}, status = 0, tab =0});
		
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "日韩先游服", name = "0.x.0 日韩先游服", addr = {"tcp://krlobbyt.igamecj.com:17500"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "日韩提审服", name = "0.x.0 日韩提审服", addr = {"tcp://kr-ios2.igamecj.com:17500"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "日韩预发布", name = "0.x.0 日韩预发布", addr = {"tcp://krjp-pre.igamecj.com:17500"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "日韩预发布", name = "0.x.0 日韩预发布2", addr = {"tcp://170.106.64.202:17500"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "日韩正式服", name = "0.x.0 日韩正式服", addr = {"tcp://krlobby.igamecj.com:17500","tcp://krpublic.igamecj.com:8088","tcp://119.28.145.130:17500"}, status = 0, tab = 0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "日韩正式服", name = "0.x.0 日韩正式服备用VIP", addr = {"tcp://119.28.145.130:17500"}, status = 0, tab = 0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "日韩正式服", name = "日韩正式服灰度服(非测试勿点)", addr = {"tcp://49.51.39.38:17500"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "日韩正式服", name = "日韩版正式服备用机器灰度服(非测试勿点)", addr = {"tcp://49.51.195.135:17500"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "日韩测试服", name = "日韩北美活动测试服", addr = {"tcp://49.51.192.119:17500"}, status = 0, tab = 0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "日韩测试服", name = "PUBG test1 qa", addr = {"tcp://49.51.196.49:17500"}, status = 0, tab = 0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "日韩测试服", name = "PUBG test2 event", addr = {"tcp://49.51.198.174:17500"}, status = 0, tab = 0});

	elseif strRegion == "VNG" then 
		-- 越南显示如下
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "0.x.0 iGame主干", addr = {"tcp://101.226.76.182:12526"}, status = 0, tab =0});	
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "0.x.5 iGame主干", addr = {"tcp://101.226.76.182:12093"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGameVNG", name = "越南主干服", addr = {"tcp://101.226.76.182:10002"}, status = 0, tab =0});	
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGameVNG", name = "越南测试1服", addr = {"tcp://101.227.139.182:10011"}, status = 0, tab =0});	
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGameVNG", name = "越南测试2服", addr = {"tcp://101.226.76.182:10001"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGameVNG", name = "越南北美GPC服", addr = {"tcp://ig-us-test2.igamecj.com:17500"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGameVNG", name = "越南北美测试3服", addr = {"tcp://49.51.195.144:17500"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGameVNG", name = "越南服（GPD）", addr = {"tcp://103.105.134.140:17500"}, status = 0, tab =0});


		table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGameVNG", name = "越南提审服", addr = {"tcp://apple2.igamecj.com:17500"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGameVNG", name = "越南预发布服", addr = {"tcp://vng-pre-lobby.igamecj.com:17500"}, status = 0, tab =0});

		table.insert(LOGIN_SERVER_LIST, {channelInfo = "越南正式服", name = "0.x.0 越南正式服", addr = {"tcp://vnglobby.igamecj.com:17500","tcp://vngpublic.igamecj.com:35000","tcp://49.51.67.224:17500"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "越南正式服", name = "0.x.0 越南正式服备用VIP", addr = {"tcp://49.51.67.224:17500"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "越南正式服", name = "越南正式服灰度服(非测试勿点)", addr = {"tcp://49.51.70.96:17500"}, status = 0, tab =0});

		table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "赛事测试", addr = {"tcp://101.226.76.182:12469"}, status = 0, tab =0});	
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "测试1服", addr = {"tcp://101.227.139.182:10001"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "测试2服", addr = {"tcp://101.227.139.182:10002"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "测试3服", addr = {"tcp://180.163.15.191:10013"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "测试4服", addr = {"tcp://101.227.130.125:14014"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "测试5服", addr = {"tcp://101.226.76.182:12009"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "测试6服", addr = {"tcp://101.227.139.182:10017"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "测试7服", addr = {"tcp://101.227.139.182:10021"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "测试8服", addr = {"tcp://101.226.76.182:12527"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "测试9服", addr = {"tcp://101.227.139.182:10031"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "测试10服", addr = {"tcp://101.226.76.182:12002"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "测试11服", addr = {"tcp://101.226.76.182:12004"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "测试12服（gpc专用服）", addr = {"tcp://101.226.76.182:10004"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "活动测试服", addr = {"tcp://49.51.70.157:17500"}, status = 0, tab =0});
	
	elseif strRegion == "TW" then 
		-- 台湾显示如下
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGameTW", name = "台湾测试1服", addr = {"tcp://101.226.76.182:10023"}, status = 0, tab =0});	
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGameTW", name = "台湾测试2服", addr = {"tcp://180.163.15.191:10014"}, status = 0, tab =0});	
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGameTW", name = "台湾北美测试3服", addr = {"tcp://150.109.13.194:17500"}, status = 0, tab =0});		
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGameTW", name = "台湾北美活动测试服", addr = {"tcp://170.106.83.234:17500"}, status = 0, tab =0});	
		
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGameTW", name = "台湾预发布", addr = {"tcp://49.51.253.219:17500"}, status = 0, tab =0});	

		table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGameTW", name = "台湾提审服", addr = {"tcp://49.51.194.119:17500"}, status = 0, tab =0});

	else
		--全球显示如下
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "0.x.0 iGame主干", addr = {"tcp://101.226.76.182:12526"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "0.x.5 iGame主干", addr = {"tcp://101.226.76.182:12093"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "DS压测", name = "DS压测服", addr = {"tcp://101.226.76.182:17500"}, status = 0, tab =0});

		table.insert(LOGIN_SERVER_LIST, {channelInfo = "PVE", name = "PVE2", addr = {"tcp://101.226.76.182:12469"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "PVE", name = "PVE3", addr = {"tcp://101.226.76.182:10003"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "PVE", name = "PVE策划体验", addr = {"tcp://101.226.76.182:10021"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "PVE", name = "PVE常规测试", addr = {"tcp://101.226.76.182:10022"}, status = 0, tab =0});

		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "测试1服", addr = {"tcp://101.227.139.182:10001"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "测试2服", addr = {"tcp://101.227.139.182:10002"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "测试3服", addr = {"tcp://180.163.15.191:10013"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "测试4服", addr = {"tcp://101.227.130.125:14014"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "测试5服", addr = {"tcp://101.226.76.182:12009"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "测试6服", addr = {"tcp://101.227.139.182:10017"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "测试7服", addr = {"tcp://101.227.139.182:10021"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "测试8服", addr = {"tcp://101.226.76.182:12527"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "测试9服", addr = {"tcp://101.227.139.182:10031"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "测试10服", addr = {"tcp://101.226.76.182:12002"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "测试11服", addr = {"tcp://101.226.76.182:12004"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "测试12服（gpc专用服）", addr = {"tcp://101.226.76.182:10004"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "测试13服", addr = {"tcp://101.226.76.182:12005"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "测试专用", name = "测试14服", addr = {"tcp://101.226.76.182:12466"}, status = 0, tab =0});

		table.insert(LOGIN_SERVER_LIST, {channelInfo = "北美测试服", name = "CTest", addr = {"tcp://kr-test.igamecj.com:17500"}, status = 0, tab =0});	
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "北美测试服", name = "北美测试一服", addr = {"tcp://ig-us-test1.igamecj.com:17500"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "北美测试服", name = "北美测试二服", addr = {"tcp://ig-us-test2.igamecj.com:17500"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "北美测试服", name = "北美测试三服", addr = {"tcp://49.51.230.114:17500"}, status = 0, tab =0});
		
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "北美先游服", name = "0.x.0 北美先游服", addr = {"tcp://tlobby.igamecj.com:17500"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "北美预发布", name = "0.x.0 北美预发布服", addr = {"tcp://ig-us-pre.igamecj.com:17500"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "北美提审服", name = "0.x.0 北美提审服", addr = {"tcp://apple4.igamecj.com:17500"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "北美正式服", name = "0.x.0 北美正式服", addr = {"tcp://lobby.igamecj.com:17500","tcp://public.igamecj.com:35000","tcp://49.51.235.24:17500"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "北美预发布", name = "0.x.0 北美预发布服2", addr = {"tcp://49.51.37.34:17500"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "北美正式服", name = "0.x.0 北美正式服备用VIP", addr = {"tcp://49.51.235.24:17500"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "北美正式服", name = "0.x.0 北美正式灰度服(非测试勿点)", addr = {"tcp://49.51.37.130:17500"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "北美正式服", name = "全球版正式服备用机器灰度服(非测试勿点)", addr = {"tcp://49.51.228.164:17500"}, status = 0, tab =0});

		table.insert(LOGIN_SERVER_LIST, {channelInfo = "美术专用服", name = "0.x.0 美术专属服", addr = {"tcp://101.226.76.182:12545"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "线上模拟服", name = "0.x.0 线上模拟服", addr = {"tcp://180.163.15.191:10012"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "线上模拟服", name = "0.x.0 线上模拟服2", addr = {"tcp://101.226.76.182:10027"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "北美测试服", name = "全球北美活动测试服", addr = {"tcp://49.51.195.18:17500"}, status = 0, tab =0});
		table.insert(LOGIN_SERVER_LIST, {channelInfo = "潘多拉测试服", name = "潘多拉测试服", addr = {"tcp://101.226.76.182:10029"}, status = 0, tab = 0});

	end

	--各版本公用服
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "性能测试服", name = "性能专项测试服务器1", addr = {"tcp://101.226.76.182:10005"}, status = 0, tab =0});
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "性能测试服", name = "性能专项测试服务器2", addr = {"tcp://101.226.76.182:10006"}, status = 0, tab =0});
	
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "基础组专用", name = "基础组专用1", addr = {"tcp://101.226.76.182:12468"}, status = 0, tab =0});
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "基础组专用", name = "基础组专用2", addr = {"tcp://101.226.76.182:12043"}, status = 0, tab =0});

	table.insert(LOGIN_SERVER_LIST, {channelInfo = "策划服", name = "策划服", addr = {"tcp://101.226.76.182:12047"}, status = 0, tab =0});

	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "0.x.0 gpc", addr = {"tcp://180.163.15.191:10012"}, status = 0, tab =0});
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "大厅压测1", addr = {"tcp://101.226.76.182:12049"}, status = 0, tab =0});
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "大厅压测2", addr = {"tcp://101.226.76.182:12546"}, status = 0, tab =0});
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "DS 压测", addr = {"tcp://101.226.76.182:17500"}, status = 0, tab =0});

	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "生化危机安全测试", addr = {"tcp://203.205.147.178:17500"}, status = 0, tab =0});
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "全球安全测试", addr = {"tcp://61.151.186.111:17500"}, status = 0, tab =0});
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "全球0.X.5策划服", addr = {"tcp://101.227.139.182:10013"}, status = 0, tab =0});

	-- 开发服务器，注意：tab = 2 !!!
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "Oliver", addr = {"tcp://10.85.4.197:7572"}, status = 0, tab =2});
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "joseph活动测试服", addr = {"tcp://10.85.0.67:7572"}, status = 0, tab =2});
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "gorichen", addr = {"tcp://10.123.6.164:7572"}, status = 0, tab =2});
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "nolanzhou", addr = {"tcp://10.123.24.11:7572"}, status = 0, tab =2});
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "paddyzhang", addr = {"tcp://10.123.24.14:7572"}, status = 0, tab =2});
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "fengxli", addr = {"tcp://10.125.38.12:7572"}, status = 0, tab =2});
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "watsonwang", addr = {"tcp://10.123.24.37:7572"}, status = 0, tab =2});
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "alanliang", addr = {"tcp://10.85.8.14:7572"}, status = 0, tab =2});
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "allenjia", addr = {"tcp://10.85.8.59:7572"}, status = 0, tab =2});
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "leancjli", addr = {"tcp://10.85.4.208:7572"}, status = 0, tab =2}); 
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "10.85.4.197", addr = {"tcp://10.85.4.197:7572"}, status = 0, tab =2}); 
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = " lrvingluan", addr = {"tcp://10.85.4.177:7572"}, status = 0, tab =2}); 
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "nicky", addr = {"tcp://10.85.8.72:7572"}, status = 0, tab =2}); 
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "marskfliu", addr = {"tcp://10.85.8.73:7572"}, status = 0, tab =2}); 
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "yuke", addr = {"tcp://10.85.8.66:7572"}, status = 0, tab =2}); 
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "shahwu", addr = {"tcp://10.85.8.74:7572"}, status = 0, tab =2}); 
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "jielingyin", addr = {"tcp://10.85.4.225:7572"}, status = 0, tab =2}); 
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "katyguo", addr = {"tcp://10.85.4.227:7572"}, status = 0, tab =2}); 
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "kadenluo", addr = {"tcp://10.85.4.228:7572"}, status = 0, tab =2}); 
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "nethinwei", addr = {"tcp://10.85.4.193:7572"}, status = 0, tab =2}); 
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "10.123.24.14", addr = {"tcp://10.123.24.14:7572"}, status = 0, tab =2}); 
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "qqjingwang", addr = {"tcp://10.85.4.213:17500"}, status = 0, tab =2}); 
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "wenbinchen", addr = {"tcp://10.123.2.96:7572"}, status = 0, tab =2}); 
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "wyattli", addr = {"tcp://10.123.24.15:7572"}, status = 0, tab =2}); 
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "大厅压测服", addr = {"tcp://101.226.76.182:12049"}, status = 0, tab =2});
	table.insert(LOGIN_SERVER_LIST, {channelInfo = "iGame", name = "服务器专用工作站", addr = {"tcp://winds-test.igamecj.com:7572"}, status = 0, tab =2});

	BP_ARRAY_ServerList_Info = {};

	for index=1, #LOGIN_SERVER_LIST do
		local serverObj = LOGIN_SERVER_LIST[index];

		local BP_ServerObj = {};
		BP_ServerObj.showAddrInfo = (serverObj.name);
		BP_ServerObj.addrArray = serverObj.addr;
		BP_ServerObj.serverStatus = serverObj.status;
		BP_ServerObj.channelInfo = serverObj.channelInfo;
		BP_ServerObj.tab = serverObj.tab;
		table.insert(BP_ARRAY_ServerList_Info,BP_ServerObj);
	end
	--备用IP
	--移动
	--LoginUI.backup_ip_list_CMCC = {"tcp://183.192.199.48:17500", "tcp://183.192.199.63:17500"};
	--联通
	--LoginUI.backup_ip_list_WCDMA = {"tcp://223.167.104.59:17500","tcp://223.167.105.81:17500"};
	--电信
	--LoginUI.backup_ip_list_CDMA = {"tcp://61.151.186.58:17500", "tcp://180.163.26.85:17500"};
	--国内CAP(除了三大运营商其他所有小运营商的集合)
	--LoginUI.backup_ip_list_CAP = {"tcp://182.254.74.196", "tcp://182.254.74.197:17500"};
	--香港海外
	--LoginUI.backup_ip_list_OVERSEA = {"tcp://203.205.128.17:17500", "tcp://203.205.147.186:17500"};

end

function EventFetchInfo()

end

--点击登录
function EventConnectToGate()
	--加入登录保护
	if LoginProtectUtils.CheckCanLogin() == false then
		return
	end
	
	--初始化网络
	NetManager.Init()
	
	if BP_InputOpenId ~= nil and BP_InputOpenId ~= "" then
		--设置登录帐号
		log("InputOpenId = " .. BP_InputOpenId)
		Client.InitLoginAccount(NetInterface, BP_InputOpenId);
	end

	local _addrArray = {};
	local _addrID = 0;
	if globalConfig.IsDirectConnect() == false then
		for i=1, #BP_ARRAY_ServerList_Info do
			if i == (BP_SelectedShowServerInfo + 1) then
				_addrArray = BP_ARRAY_ServerList_Info[i].addrArray;
				_addrID = i;
				break;
			end
		end
	else
		-- 检查提审状态，看在提审状态就把服务器直连到提审服去
		LoginSystem.SetDirectLoginServer()
		--local channel = Client.GetLoginChannel(NetInterface);
		local strRegion = Client.GetPublishRegion();
		local serverInfo = {};
		log("EventConnectToGate strRegion = " .. strRegion);
		if Client.IsCEVersion() then
			serverInfo = LoginSystem.direct_login_server_list_ce;
		elseif strRegion == "JAPAN" or strRegion == "KOREA" then
			serverInfo = LoginSystem.direct_login_server_list_jk;
		elseif strRegion == "VNG" then
			serverInfo = LoginSystem.direct_login_server_list_vng;
		elseif strRegion == "TW" then
			serverInfo = LoginSystem.direct_login_server_list_tw;
		else
			serverInfo = LoginSystem.direct_login_server_list;
		end


		--log_tree("EventConnectToGate serverInfo:" .. tostring(serverInfo))

		if serverInfo ~= nil then

			--local _telecomSvrName = Client.GetTelecomSvr();
			--local _addrBackupArray = {};

			--if(_telecomSvrName == "ChinaMobile") then
			--	_addrBackupArray = LoginUI.backup_ip_list_CMCC;
			--elseif(_telecomSvrName == "ChinaUnicom") then
			--	_addrBackupArray = LoginUI.backup_ip_list_WCDMA;
			--elseif(_telecomSvrName == "ChinaTelecom") then
			--	_addrBackupArray = LoginUI.backup_ip_list_CDMA;
			--elseif(_telecomSvrName == "Unknown") then
			--	_addrBackupArray = LoginUI.backup_ip_list_OVERSEA;
			--else
			--	_addrBackupArray = LoginUI.backup_ip_list_CAP;
			--end

			--if(_addrBackupArray~=nil and (#_addrBackupArray>0)) then
			--	_addrArray = FuncUtil.TableConcat(serverInfo.addr, _addrBackupArray)
			--else
			_addrArray = serverInfo.addr;
			--end
		end
	end
	if _addrArray~=nil and (#_addrArray > 0) then
		LoginSystem.connectGateway(_addrArray, _addrID);
	else
		log("not selected addr info！");
	end

	EUGDPRSystemUI.InitializeData();

	--清空战区好友榜
	WarZoneRankSystem.recodeInfoList = {}
	WarZoneRankSystem.recodeCacheMark = {}
end

--隐藏选区
function EventShowScrollView()
	log("EventShowScrollView");
	LuaClassObj.HandleUIMessage(bp_login, "ShowScrollView");
end

--隐藏选区
function EventHideScrollView()
	log("EventHideScrollView");
	LuaClassObj.HandleUIMessage(bp_login, "HideScrollView");
end

--显示当前选区
function EventShowCurrentSelect()
	log("EventShowCurrentSelect");
	LuaClassObj.HandleUIMessage(bp_login, "ShowCurrentSelect");
end

--点击测试UMG
function EventOpenExampleUI()
	log("EventOpenExampleUI");
	LuaClassObj.HandleUIMessage(bp_test_entrance, "showUI");
end

--注销帐号
function EventLogout()
	log("EventLogout");
	Client.Logout(NetInterface);
end

function bp_login_OnModeSwitched(gamestatus)
	log("bp_login_OnModeSwitched gamestatus = " .. gamestatus);
	if string.lower(gamestatus) == "login" then
		--显示UI
		LuaClassObj.HandleUIMessage(bp_login, "UIHide");
		LuaClassObj.HandleUIMessage(bp_authorization, "showAuthorizationUI");
	end


end

function EventHandleTimeStamp()
	if not Client.IsCEVersion() then
		BP_PatchTimeStamp = global_patch_make_time
		LuaClassObj.HandleUIMessageNoFetch(bp_login, "ShowLastPatchTimeStampInfo")
	else
		LuaClassObj.HandleUIMessageNoFetch(bp_login, "HideLastPatchTimeStampInfo")
	end
end

-- 打开语言设置
function EventEnterLanguageSetting()
	log("enter language setting ui");
	SettingLanguageUI.ShowUIInLoginPanel();

end


function EventChangeEnvLogout()

    local function LogOut()
        LuaClassObj.HandleUIMessage(bp_global, "quitGame");
    end

    CommonMessageBoxUI:ShowPanel(2, Client.GetTableData("LocalizeRes", "102012").TextValue, Client.GetTableData("LocalizeRes", "6841").TextValue, LogOut);
end