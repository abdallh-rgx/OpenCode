PufferDownloader = PufferDownloader or {
    
}

PufferDownloader.FILE_LIST_NAME = "PufferFileList.json";
PufferDownloader.INPROGRESS_PAK_SUFFIX = "_inprog";
PufferDownloader.DOWNLOAD_DIR_RELATIVE = "Paks/";

PufferDownloader.INVALID_FILE_ID = -1;
PufferDownloader.INVALID_TASK_ID = -1;

-- Stage Code
PufferDownloader.STAGE_INITIALIZING = 1;
PufferDownloader.STAGE_FETCH_FILE_LIST = 2;
PufferDownloader.STAGE_FILE_DOWNLOADING = 3;
PufferDownloader.STAGE_FILE_MERGING = 4;
PufferDownloader.STAGE_FILE_CHECKING = 5;
PufferDownloader.STAGE_RETRY = 6;
PufferDownloader.STAGE_FINISH = 7;
PufferDownloader.STAGE_PRECHECK_OLDFILE = 8;

-- Error define
PufferDownloader.ERR_INVALID_TASK_ID = 0x01;
PufferDownloader.ERR_INVALID_TASK_ID_CALLBACK = 0x02;
PufferDownloader.ERR_INVALID_STAGE_DOWNLOAD_RETURN = 0x03;
PufferDownloader.ERR_INVALID_REQUEST_FILENAME = 0x04;
PufferDownloader.ERR_RETRYING_RETRY_STAGE = 0x05;
PufferDownloader.ERR_NOT_INITIALIZED = 0x06;
PufferDownloader.ERR_PAK_WRAPPER_NOT_EXIST = 0x07;
PufferDownloader.ERR_MOVE_FILE_FAILED = 0x08;
PufferDownloader.ERR_CHECK_FILE_FAILED = 0x09;

PufferDownloader.maxOutterTaskID = 1;
PufferDownloader.fileListPufferTaskID = 0;

PufferDownloader.MAX_RETRY_TIMES = 3;
PufferDownloader.MERGE_DUMMY_WAIT_TIME = 60;

PufferDownloader.filestateList = {};
PufferDownloader.outterTaskIDFilenameMapping = {};

PufferDownloader.mergeFailedTimes = {};

PufferDownloader.hasDesertReportedError = false;
PufferDownloader.hasSavageReportedError = false;
PufferDownloader.hasDihoroReportedError = false;
PufferDownloader.hasReportedError = {
	map_desert_ = false,
	map_savagemain_ = false,
	map_dihorotok_ = false,
	res_comml_ = false,
}
 

PufferDownloader.PufferStageFunction = {
	[PufferDownloader.STAGE_INITIALIZING] = function(filestate)
		log("[LogicPufferDownloaderLUA] PufferStageFunction 1")
		PufferDownloader.RequestFile(GameFrontendHUD, filestate.filename, filestate.forceUpdate)
	end,
	[PufferDownloader.STAGE_FETCH_FILE_LIST] = function(filestate)
		log("[LogicPufferDownloaderLUA] PufferStageFunction 2")
		PufferDownloader.FetchFileList(filestate);
	end,
	[PufferDownloader.STAGE_FILE_DOWNLOADING] = function(filestate)
		log("[LogicPufferDownloaderLUA] PufferStageFunction 3")
		PufferDownloader.DownloadFileImp(filestate);
	end,
	[PufferDownloader.STAGE_FILE_MERGING] =  function(filestate)
		log("[LogicPufferDownloaderLUA] PufferStageFunction 4")
		PufferDownloader.MergeFile(filestate);
	end,
	[PufferDownloader.STAGE_FILE_CHECKING] = function(filestate)
		log("[LogicPufferDownloaderLUA] PufferStageFunction 5")
		PufferDownloader.CheckFile(filestate);
	end,
	[PufferDownloader.STAGE_RETRY] = function(filestate)
		sandbox.LogError("[LogicPufferDownloaderLUA] OnDownloadProgress Retry should not retry self");
		filestate.lastErrno = PufferDownloader.ERR_RETRYING_RETRY_STAGE*100 + filestate.lastErrno;
		PufferDownloader.FinishRequestFile(filestate);
		return false;
	end,
	[PufferDownloader.STAGE_FINISH] = function(filestate)
		log("[LogicPufferDownloaderLUA] PufferStageFunction 7")
		PufferDownloader.FinishRequestFile(filestate);
	end,
}

--[[
	filename：被下载文件的文件名
	curStage：被下载文件当前所处的阶段
	pufferTaskID：底层 Puffer 所使用的下载 taskID
	outterTaskID: 对上层逻辑接口展示的 taskID
--]]
function PufferDownloader.FileState(filename, forceUpdate, curStage, pufferTaskID)
	log("[LogicPufferDownloaderLUA] Create new FileState. maxOutterTaskID="..PufferDownloader.maxOutterTaskID);
	local val =  {
		outterTaskID = PufferDownloader.maxOutterTaskID,
		filename = filename,
		forceUpdate = forceUpdate or false,
		curStage = curStage or PufferDownloader.STAGE_INITIALIZING,
		pufferTaskID = pufferTaskID or PufferDownloader.INVALID_TASK_ID,
		retryTimes = 0,
		retryStage = 0,
		lastErrno = 0, -- 0 代表成功
		diffFilename = nil,
		oldFilename = nil,
		mergePassedProg = 0,
		mergeTotalProg = 1,
		suspended = false,
		slient = false,
		preCheckPassed = nil
	}

	local metaTable = {
		__tostring = function(t)
			local str = [[{ outterTaskID = %d, filename = %s, forceUpdate = %s, curStage = %d, pufferTaskID = %d, retryTimes = %d, retryStage = %d, lastErrno=%d, diffFilename=%s, oldFilename=%s, mergePassedProg=%f, mergeTotalProg=%f, suspended=%s, slient=%s, preCheckPassed=%s}]];
			return string.format(str, 
				t.outterTaskID,
				t.filename,
				t.forceUpdate,
				t.curStage,
				t.pufferTaskID,
				t.retryTimes,
				t.retryStage,
				t.lastErrno,
				t.diffFilename,
				t.oldFilename,
				t.mergePassedProg,
				t.mergeTotalProg,
				t.suspended,
				t.slient,
				t.preCheckPassed
		 	);
		end 
	}

	PufferDownloader.maxOutterTaskID = PufferDownloader.maxOutterTaskID + 1;
	return setmetatable(val, metaTable);
end

function PufferDownloader.SyncProgressToCallback(outterTaskID, nowSize, totalSize, curStage)
	local filestate = PufferDownloader.filestateList[outterTaskID];
	if filestate ~= nil and (not filestate.slient) then
		TeamUpMatchInfoUI.OnUpdateDownloadProgress(outterTaskID, nowSize, totalSize, curStage);
	end

	log("[PufferLUAProgress] SynceProgressToCallback: outterTaskID:" .. outterTaskID .. " nowSize:" .. nowSize .. " totalSize:" .. totalSize .. " curStage:" .. curStage);
end

function PufferDownloader.SyncFinishToCallback(outterTaskID, isSuccess, errorCode)
	local filestate = PufferDownloader.filestateList[outterTaskID];
	if filestate ~= nil and (not filestate.slient) then
		TeamUpMatchInfoUI.OnDownloadMapCompleted(outterTaskID, isSuccess, errorCode);
	end
	
	if isSuccess == true then 
		log("[PufferLUAProgress] SyncFinishToCallback: outterTaskID:" .. outterTaskID .. " isSuccess:" .. tostring(isSuccess) .. " errorCode:" .. errorCode);
	else
		sandbox.LogError("[PufferLUAProgress] SyncFinishToCallback: outterTaskID:" .. outterTaskID .. " isSuccess:" .. tostring(isSuccess) .. " errorCode:" .. errorCode);
	end
end

--[[
此文件中所有接口的调用，请自行保证PufferDownloader已经被初始化！
每个Stage对应的函数中应该至少完成两个事情：1. 设置当前 filestate 的 Stage。 2. 向上层同步状态
--]]

-- 此函数需要立即返回给上层，且返回过程中不能执行与上层的状态同步
function PufferDownloader.RequestFile(gameFrontendHUD, filename, forceUpdate)
	log("[LogicPufferDownloaderLUA] RequestFile start");
	-- gameFrontendHUD 此参数纯为兼容性保留
	if not GCPufferDownloader.IsInitSuccess(Puffer) then
		log("[LogicPufferDownloaderLUA] RequestFile Not Initialized");
		return PufferDownloader.INVALID_TASK_ID;
	end


	-- 如果该文件已有任务则返回之前的任务，并不创建新的
	local filestate = PufferDownloader.GetfilestateByFilename(filename);
	if filestate == nil then
		filestate = PufferDownloader.FileState(filename, forceUpdate);

		log("[LogicPufferDownloaderLUA] RequestFile outterTaskIDFilenameMapping");
		for k,v in pairs(PufferDownloader.outterTaskIDFilenameMapping) do
			log("[LogicPufferDownloaderLUA] RequestFile: " .. tostring(k) .. " " .. tostring(v));
		end

		-- 一个文件名和一个outterTaskID 绑定
		local outterTaskID = PufferDownloader.outterTaskIDFilenameMapping[filename];
		if outterTaskID ~= nil then
			filestate.outterTaskID = outterTaskID;
		else
			PufferDownloader.outterTaskIDFilenameMapping[filename] = filestate.outterTaskID;
		end
		-- PufferDownloader.SyncProgressToCallback(filestate.outterTaskID, 100, 100, filestate.curStage);

		log("[LogicPufferDownloaderLUA] RequestFile new filestate: " .. tostring(filestate));
		log("[LogicPufferDownloaderLUA] RequestFile After create new filestate. maxOutterTaskID="..PufferDownloader.maxOutterTaskID);

		PufferDownloader.filestateList[filestate.outterTaskID] = filestate;
	else
		filestate.suspended = false;
		log("[LogicPufferDownloaderLUA] RequestFile filestate is existed " .. tostring(filestate));
	end

	return filestate.outterTaskID;
end

function PufferDownloader.IsFileListExist()
	if not GCPufferDownloader.IsInitSuccess(Puffer) then
		return false;
	end

	return GCPufferDownloader.IsFileExist(Puffer, PufferDownloader.FILE_LIST_NAME, "");
end

function PufferDownloader.GetfilestateByFilename(filename)
	return PufferDownloader.filestateList[PufferDownloader.outterTaskIDFilenameMapping[filename]];
end

function PufferDownloader.GetfilestateByPufferTaskID(pufferTaskID)
	for outterTaskID, filestate in pairs(PufferDownloader.filestateList) do
		if filestate.pufferTaskID == pufferTaskID then
			return filestate;
		end
	end

	return nil;
end

function PufferDownloader.Tick(DeltaTime)
	for outterTaskID, filestate in pairs(PufferDownloader.filestateList) do
		local curStage = filestate.curStage;

		if curStage == PufferDownloader.STAGE_INITIALIZING then
			PufferDownloader.FetchFileList(filestate);
		elseif curStage == PufferDownloader.STAGE_FILE_MERGING then -- Merge 没有提供进度接口，给个假的
			local dummyProgress = 0;
			if filestate.mergeTotalProg == -1 then
				-- 文件大小的接口无效, 按照时间来算
				filestate.mergePassedProg = filestate.mergePassedProg + DeltaTime;
				dummyProgress = filestate.mergePassedProg / PufferDownloader.MERGE_DUMMY_WAIT_TIME * 100;
			else
				-- 用文件大小来粗估合并进度
				local downloadPath = GCPufferDownloader.GetDownloadPath(Puffer);
				filestate.mergePassedProg = GCPufferDownloader.GetFileSize(Puffer, downloadPath .. filestate.filename .. PufferDownloader.INPROGRESS_PAK_SUFFIX);
				dummyProgress = filestate.mergePassedProg / filestate.mergeTotalProg * 100;
			end
			PufferDownloader.SyncProgressToCallback(filestate.outterTaskID, dummyProgress, 100, filestate.curStage);
		end
	end
end

function PufferDownloader.FetchFileList(filestate)
	if not GCPufferDownloader.IsInitSuccess(Puffer) then
		filestate.lastErrno = PufferDownloader.ERR_NOT_INITIALIZED;
		PufferDownloader.FinishRequestFile(filestate);
		return false;
	end

	filestate.curStage = PufferDownloader.STAGE_FETCH_FILE_LIST;
	PufferDownloader.ReportStageChange(filestate);

	-- 此处并没有选择使用 IsFileReady 因为 IsFileReady 在外网有相当几率的失败
	if PufferDownloader.IsFileListExist() then
		log("[LogicPufferDownloaderLUA] FetchFileList FileList existed, Start Download File")
		filestate.filename = PufferDownloader.GetRealFilename(filestate.filename);
		PufferDownloader.SyncProgressToCallback(filestate.outterTaskID, 100, 100, filestate.curStage);
		PufferDownloader.DownloadFileImp(filestate);
	else
		log("[LogicPufferDownloaderLUA] FetchFileList FileList NOT existed, Start Fetch FileList fileListPufferTaskID="..tostring(PufferDownloader.fileListPufferTaskID))
		PufferDownloader.SyncProgressToCallback(filestate.outterTaskID, 0, 100, filestate.curStage);

		-- 没有其他task在下载文件列表
		if PufferDownloader.fileListPufferTaskID <= 0 then
			-- 此处 forceUpdate 设置为true，因为filelist大小很小，没有断点续传的需求
			PufferDownloader.fileListPufferTaskID = GCPufferDownloader.RequestFile(Puffer, PufferDownloader.FILE_LIST_NAME, true);
			log("[LogicPufferDownloaderLUA] FetchFileList Fetch FileList pufferTaskID " .. tostring(PufferDownloader.fileListPufferTaskID));
			if PufferDownloader.fileListPufferTaskID == PufferDownloader.INVALID_TASK_ID then
				sandbox.LogError("[LogicPufferDownloaderLUA] FetchFileList FetchFileList Failed")
				filestate.lastErrno = PufferDownloader.ERR_INVALID_TASK_ID;
				PufferDownloader.RetryCurStage(filestate);
			end
		end
	end

	return true;
end

function PufferDownloader.ParsePakName(name)
	return string.match(name, "^([%a_]+)(%d+%.%d+%.%d+%.%d+)%.pak$");
end

function PufferDownloader.CompareVersion(version1, version2)
	local version1_splited = string.split(version1, ".");
	local version2_splited = string.split(version2, ".");

	for i=1,4 do
		if version1_splited[i] ~= version2_splited[i] then
			local val1 = tonumber(version1_splited[i]);
			local val2 = tonumber(version2_splited[i]);
			return val1 - val2;
		end
	end

	return 0;
end

function PufferDownloader.GetTargetFilename(filestate)
	log("[LogicPufferDownloaderLUA] GetTargetFilename filestate:" .. tostring(filestate));
	-- 检查本地所有的 pak 文件
	local localOldPak = {};

	local ret = GCPufferDownloader.ReturnLocalFiles(PufferDownloader.DOWNLOAD_DIR_RELATIVE, "");
	for idx, filename in pairs(ret) do
		local prefix, versionNo = PufferDownloader.ParsePakName(filename);
		log("[LogicPufferDownloaderLUA] GetTargetFilename parse local filename " .. filename .. " Prefix:" .. tostring(prefix) .. " versionNo" .. tostring(versionNo));
		if prefix ~= nil and versionNo ~= nil then -- 如果本地文件后缀不是 pak 会被自动忽略
			if localOldPak[prefix] ~= nil then
				-- 每次只考虑版本号最大的pak文件
				if PufferDownloader.CompareVersion(versionNo, localOldPak[prefix]) > 0 then
					localOldPak[prefix] = versionNo;
				end
			else
				localOldPak[prefix] = versionNo;
			end
		end
	end

	-- 解析文件列表
	local fileListContent = GCPufferDownloader.ReadFile(Puffer, PufferDownloader.FILE_LIST_NAME);
	local diffList = json.decode(fileListContent).diff_list;
	local downloadFilename = filestate.filename;

	-- 检查本地是否有旧文件，并根据旧文件版本号下载对应差异
	local targetFilePrefix, targetFileVersionNo = PufferDownloader.ParsePakName(filestate.filename);
	if targetFilePrefix == nil or targetFileVersionNo == nil then
		-- 要下载的目标文件不是已知的带版本号pak内容
		filestate.lastErrno = PufferDownloader.ERR_INVALID_REQUEST_FILENAME;
		return nil;
	end

	local oldVersion = localOldPak[targetFilePrefix];
	if oldVersion ~= nil then -- 本地有同前缀的 pak 文件
		log("[LogicPufferDownloaderLUA] GetTargetFilename diffList pak " .. tostring(diffList[oldVersion]));

		if diffList[oldVersion] ~= nil then
			filestate.diffFilename = diffList[oldVersion][filestate.filename];
			filestate.oldFilename = targetFilePrefix .. oldVersion .. ".pak";
		else
			sandbox.LogError("[LogicPufferDownloaderLUA] GetTargetFilename target version not in difflist " .. tostring(filestate.filename));
			for k,v in pairs(diffList) do
				sandbox.LogError("[LogicPufferDownloaderLUA] GetTargetFilename diffList: ".. tostring(k) .. " : " .. tostring(v));
			end
		end

		log("[LogicPufferDownloaderLUA] GetTargetFilename diffList pak " .. tostring(filestate));

		downloadFilename = filestate.diffFilename;

		if downloadFilename == nil then 
			sandbox.LogError("[LogicPufferDownloaderLUA] GetTargetFilename target filename is not exist in filelist version:" .. tostring(oldVersion) .. " filename:" .. tostring(filestate.filename));
			downloadFilename = filestate.filename;
		end
	end
	return downloadFilename;
end

function PufferDownloader.DownloadFileImp(filestate)
	if not GCPufferDownloader.IsInitSuccess(Puffer) then
		filestate.lastErrno = PufferDownloader.ERR_NOT_INITIALIZED;
		PufferDownloader.FinishRequestFile(filestate);
		return false;
	end

	filestate.curStage = PufferDownloader.STAGE_FILE_DOWNLOADING;
	PufferDownloader.ReportStageChange(filestate);

	local downloadFilename = PufferDownloader.GetTargetFilename(filestate);
	if downloadFilename == nil then
		sandbox.LogError("[LogicPufferDownloaderLUA] DownloadFileImp target filename parse error " .. tostring(filestate.filename));
		PufferDownloader.FinishRequestFile(filestate);
		return false;
	end

	if not GCPufferDownloader.IsFileReady(Puffer, downloadFilename) then
		log("[LogicPufferDownloaderLUA] DownloadFileImp start download:" .. tostring(filestate));
		local taskID = GCPufferDownloader.RequestFile(Puffer, downloadFilename, filestate.forceUpdate);
		log("[LogicPufferDownloaderLUA] DownloadFileImp start download: pufferTaskID" .. tostring(taskID));
		if taskID == PufferDownloader.INVALID_TASK_ID then
			sandbox.LogError("[LogicPufferDownloaderLUA] DownloadFileImp RequestFile Failed")
			filestate.lastErrno = PufferDownloader.ERR_INVALID_TASK_ID;
			PufferDownloader.RetryCurStage(filestate)
		end

		filestate.pufferTaskID = taskID;

		PufferDownloader.SyncProgressToCallback(filestate.outterTaskID, 0, 100, filestate.curStage);
	else
		log("[LogicPufferDownloaderLUA] DownloadFileImp " .. tostring(downloadFilename) .. " is ready");
		PufferDownloader.SyncProgressToCallback(filestate.outterTaskID, 100, 100, filestate.curStage);
		if filestate.diffFilename ~= nil then
			PufferDownloader.MergeFile(filestate);
		else
			-- 若直接下载完整文件则 直接结束更新流程
			PufferDownloader.FinishRequestFile(filestate);
		end
	end

	return true;
end

function PufferDownloader.MergeFile(filestate)
	log("[LogicPufferDownloaderLUA] MergeFile Start Merge")
	filestate.curStage = PufferDownloader.STAGE_FILE_MERGING;
	PufferDownloader.ReportStageChange(filestate);
	PufferDownloader.SyncProgressToCallback(filestate.outterTaskID, 0, 100, filestate.curStage);

	log("[LogicPufferDownloaderLUA] MergeFile " .. tostring(filestate));

	local downloadPath = GCPufferDownloader.GetDownloadPath(Puffer);
	local tempWorkPath = GCPufferDownloader.GetTempWorkPath(Puffer);
	log("[LogicPufferDownloaderLUA] MergeFile tempWorkPath=" .. tostring(tempWorkPath) .. ", downloadPath=" .. tostring(downloadPath));
	GCPufferDownloader.MergeBinDiffPak(Puffer, 
		filestate.outterTaskID,
		downloadPath .. filestate.oldFilename, 
		downloadPath .. filestate.diffFilename, 
		downloadPath .. filestate.filename .. PufferDownloader.INPROGRESS_PAK_SUFFIX,
		true -- fast mode default
	);

	-- 以旧文件+差异文件大小为预期的 新文件大小，此大小一般会大于新文件大小，留点富余
	local oldFileSize = GCPufferDownloader.GetFileSize(Puffer, downloadPath .. filestate.oldFilename);
	local diffFileSize = GCPufferDownloader.GetFileSize(Puffer, downloadPath .. filestate.diffFilename); 
	local newFileSize = GCPufferDownloader.GetFileSizeCompressed(Puffer, filestate.filename);

	if oldFileSize == -1 or diffFileSize == -1 or newFileSize == -1 then
		sandbox.LogError("[LogicPufferDownloaderLUA] MergeFile GetFileSizeFailed oldFile:" .. tostring(filestate.oldFilename) .. " " .. tostring(filestate.oldFileSize)
																		   .. " diffFile:" .. tostring(filestate.diffFilename) .. " " .. tostring(filestate.diffFileSize));
		filestate.mergeTotalProg = -1;
	else
		filestate.mergeTotalProg = newFileSize / 1024.0 ;
	end
							   

end

function PufferDownloader.OnMergeBinDiffPakReturn(outterTaskID, errorCode)
	log("[LogicPufferDownloaderLUA] MergeFile Merge return outterTaskID:" .. tostring(outterTaskID) .. " errorCode:" .. tostring(errorCode));
	local filestate = PufferDownloader.filestateList[outterTaskID];
	-- filestate 被用户Stop也会被清除
	if filestate == nil then
		sandbox.LogError("[LogicPufferDownloaderLUA] OnMergeBinDiffPakReturn cannot find correspond filestate for merge callback or the filestate is suspended" .. tostring(outterTaskID) .. "MergeErrorCode:"..errorCode);
		return;
	end

	log("[LogicPufferDownloaderLUA] OnMergeBinDiffPakReturn filestate " .. tostring(filestate));
	PufferDownloader.SyncProgressToCallback(filestate.outterTaskID, 100, 100, filestate.curStage);
	if errorCode == 0 then
		PufferDownloader.CheckFile(filestate);
	else
		-- 因为Merge操作太耗时，不进行重试直接结束更新流程
		filestate.lastErrno = errorCode;
		PufferDownloader.FinishRequestFile(filestate);
	end
end

function PufferDownloader.PreCheckOldFile(filestate)
	filestate.curStage = PufferDownloader.STAGE_PRECHECK_OLDFILE;
	-- 目前只作为临时检测手段，不上报filestate 的 stage
	-- PufferDownloader.ReportStageChange(filestate);

	PufferDownloader.SyncProgressToCallback(filestate.outterTaskID, 0, 100, filestate.curStage);
	log("[LogicPufferDownloaderLUA] CheckFile start PRE check olf File" .. tostring(filestate));
	local downloadPath = GCPufferDownloader.GetDownloadPath(Puffer);
	GCPufferDownloader.CheckDownloadFileFraming(Puffer, filestate.outterTaskID, downloadPath .. filestate.oldFilename, 4*1024*1024);
end

function PufferDownloader.CheckFile(filestate)
	filestate.curStage = PufferDownloader.STAGE_FILE_CHECKING;
	PufferDownloader.ReportStageChange(filestate);
	PufferDownloader.SyncProgressToCallback(filestate.outterTaskID, 0, 100, filestate.curStage);
	log("[LogicPufferDownloaderLUA] CheckFile start check File" .. tostring(filestate));
	local downloadPath = GCPufferDownloader.GetDownloadPath(Puffer);
	GCPufferDownloader.CheckDownloadFileFraming(Puffer, filestate.outterTaskID, downloadPath .. filestate.filename .. PufferDownloader.INPROGRESS_PAK_SUFFIX, 4*1024*1024);
end

function PufferDownloader.OnHashGenerateFinished(outterTaskID, hashcode)
	log("[LogicPufferDownloaderLUA] CheckFile return outterTaskID:" .. tostring(outterTaskID) .. " hashCode:" .. tostring(hashcode));
	-- filestate 被用户Stop也会被清除
	local filestate = PufferDownloader.filestateList[outterTaskID];
	if filestate == nil then
		sandbox.LogError("[LogicPufferDownloaderLUA] OnHashGenerateFinished cannot find correspond filestate for hashGen callback " .. tostring(outterTaskID));
		return;
	end

	-- 解析文件列表
	local fileListContent = GCPufferDownloader.ReadFile(Puffer, PufferDownloader.FILE_LIST_NAME);
	local checkList = json.decode(fileListContent).check_list;

	local checkPassed = false
	if filestate.curStage == PufferDownloader.STAGE_PRECHECK_OLDFILE then 
		-- 失败后校验老文件
		if filestate.oldFilename ~= nil and checkList[filestate.oldFilename] ~= nil and #checkList[filestate.oldFilename] ~= 0 then
			filestate.preCheckPassed = false;
			for i=1, #checkList[filestate.oldFilename] do
				log("[LogicPufferDownloaderLUA] CheckFile: Pre check targetHash=" .. tostring(checkList[filestate.oldFilename][i]));
				if string.lower(checkList[filestate.oldFilename][i]) == string.lower(hashcode) then
					filestate.preCheckPassed = true;
					log("[LogicPufferDownloaderLUA] CheckFile: Pre check success");
				end
			end
			-- 只是作为校验即使失败也直接返回
			if filestate.preCheckPassed == false then
				log("[LogicPufferDownloaderLUA] CheckFile: Pre check failed");
			end

			PufferDownloader.SyncProgressToCallback(filestate.outterTaskID, 100, 100, filestate.curStage);
			PufferDownloader.FinishRequestFile(filestate);
		else
			filestate.preCheckPassed = false;
			sandbox.LogWarning("[LogicPufferDownloaderLUA] PRE CheckFile skip check, filestate:" .. tostring(filestate));
			PufferDownloader.FinishRequestFile(filestate);
		end
		-- 校验完即结束
		return;
	elseif checkList[filestate.filename] == nil or #checkList[filestate.filename] == 0 then
		-- 文件列表中没有hash值，跳过
		sandbox.LogWarning("[LogicPufferDownloaderLUA] CheckFile skip check, because checkList does not contain corresponding Hash" .. tostring(filestate));
		checkPassed = true;
	else
		checkPassed = false;
		for i=1, #checkList[filestate.filename] do
			log("[LogicPufferDownloaderLUA] CheckFile: targetHash=" .. tostring(checkList[filestate.filename][i]));
			if string.lower(checkList[filestate.filename][i]) == string.lower(hashcode) then
				checkPassed = true;
			end
		end
		if not checkPassed then
			-- 因为 hash 操作太耗时，不进行重试直接结束更新流程
			filestate.lastErrno = PufferDownloader.ERR_CHECK_FILE_FAILED;
		end
	end

	if checkPassed then
		-- 收尾操作，将文件拷贝到工作目录
		local downloadPath = GCPufferDownloader.GetDownloadPath(Puffer);
		local tempWorkPath = GCPufferDownloader.GetTempWorkPath(Puffer);
		log("[LogicPufferDownloaderLUA] CheckFile: move file from ".. tostring(downloadPath .. filestate.filename .. PufferDownloader.INPROGRESS_PAK_SUFFIX) .. " " .. tostring(downloadPath .. filestate.filename));
		local ret = GCPufferDownloader.MoveFile(Puffer, downloadPath .. filestate.filename .. PufferDownloader.INPROGRESS_PAK_SUFFIX,
														downloadPath .. filestate.filename);
		if ret ~= 0 then
			sandbox.LogError("[LogicPufferDownloaderLUA] OnMergeBinDiffPakReturn MoveFileTo Operation Error " .. tostring(ret) .. "From:".. tostring(filestate.filename .. PufferDownloader.INPROGRESS_PAK_SUFFIX) .. "To:" .. tostring(downloadPath .. filestate.filename));
			filestate.lastErrno = ret;
			PufferDownloader.FinishRequestFile(filestate);
		end
	end

	-- 最后一步 Stage
	PufferDownloader.SyncProgressToCallback(filestate.outterTaskID, 100, 100, filestate.curStage);
	PufferDownloader.FinishRequestFile(filestate);
end

function PufferDownloader.ReportStageChange(filestate)
	local param = 
	{
		tostring(filestate.diffFilename ~= nil), -- isIncremental
		tostring(filestate.filename), -- filename =
		tostring(filestate.curStage) -- stage =
	};
	PufferDownloader.GEMReportEvent("PufferStageChanged", param);
end

function PufferDownloader.FinishRequestFile(filestate)

	local prefix, versionNo = PufferDownloader.ParsePakName(filestate.filename);
	local errorStage = filestate.curStage;
	if filestate.curStage == PufferDownloader.STAGE_RETRY or 
	   filestate.curStage == PufferDownloader.STAGE_PRECHECK_OLDFILE then -- 复用RetryStage变量给插入流程
		errorStage = filestate.retryStage;
	end

	-- 在 Merge 或 Check 阶段报错了，决策是否进行原始文件校验
	if (errorStage == PufferDownloader.STAGE_FILE_MERGING or errorStage == PufferDownloader.STAGE_FILE_CHECKING)
		and filestate.lastErrno ~= 0 then
		log("[LogicPufferDownloaderLUA] DownloadFileImp Merge/Check Error" .. tostring(filestate));
		-- 出错，但是没有进行原始文件校验
		if filestate.preCheckPassed == nil then
			filestate.retryStage = filestate.curStage;
			PufferDownloader.PreCheckOldFile(filestate);
			return;
		end
	end

	local param = 
	{
		isSuccess = tostring(filestate.lastErrno == 0),
		isIncremental = tostring(filestate.diffFilename ~= nil),
		filename = tostring(filestate.filename),
		errorCode = tostring(filestate.lastErrno),
		stage = tostring(errorStage),
		preCheckPassed = tostring(filestate.preCheckPassed)
	};

	for k,v in pairs(param) do
		log("GEM PufferFileRequestFinished PARAM " .. tostring(k) .. " " .. tostring(v));
	end

	if (filestate.lastErrno == 0) then
		-- 如果是成功的直接上报
		Client.GEMReportEvent(GameFrontendHUD, "PufferFileRequestFinished", param);
	elseif PufferDownloader.hasReportedError[prefix] == false then
		-- 当前 Prefix 的错误还没上报过
		PufferDownloader.hasReportedError[prefix] = true;
		Client.GEMReportEvent(GameFrontendHUD, "PufferFileRequestFinished", param);
	end


	-- 在Merge阶段报错了
	if (errorStage == PufferDownloader.STAGE_FILE_MERGING or errorStage == PufferDownloader.STAGE_FILE_CHECKING)
		and filestate.lastErrno ~= 0 then
		PufferDownloader.mergeFailedTimes[filestate.outterTaskID] = (PufferDownloader.mergeFailedTimes[filestate.outterTaskID] or 0) + 1;
		if PufferDownloader.mergeFailedTimes[filestate.outterTaskID] >= 1 then
			-- 清理掉旧地图，下次重试开始下载全量
			PufferDownloader.DeleteAllOldPak(prefix)
			local param = 
			{
				tostring(filestate.filename), -- filename =
				tostring(errorStage), -- stage =
				tostring(filestate.lastErrno), -- errorCode =
			};
			PufferDownloader.GEMReportEvent("PufferTriggerFullDownload", param);
		end
	end

	filestate.curStage = PufferDownloader.STAGE_FINISH;
	PufferDownloader.ReportStageChange(filestate);

	local downloadPath = GCPufferDownloader.GetDownloadPath(Puffer);
	if filestate.diffFilename ~= nil then
		GCPufferDownloader.DeleteFile(downloadPath .. filestate.diffFilename);
	end
	if filestate.filename ~= nil then
		GCPufferDownloader.DeleteFile(downloadPath .. filestate.filename .. PufferDownloader.INPROGRESS_PAK_SUFFIX);
	end
	log("[LogicPufferDownloaderLUA] DownloadFileImp cleanUp diffFile and tmpFile" .. tostring(filestate));

	if filestate.lastErrno ~= 0 then
		sandbox.LogError("[LogicPufferDownloaderLUA] DownloadFileImp RequestFile Failed " .. tostring(filestate));
		PufferDownloader.SyncFinishToCallback(filestate.outterTaskID, false, filestate.lastErrno);
	else
		log("[LogicPufferDownloaderLUA] DownloadFileImp RequestFile Success " .. tostring(filestate));
		local isMountSuccess = GCPufferDownloader.RemountPakFiles(Puffer);

		local param = 
		{
			tostring(isMountSuccess), -- isSuccess
			tostring(filestate.diffFilename ~= nil), -- isIncremental
			tostring(filestate.filename), -- filename
		};
		PufferDownloader.GEMReportEvent("PufferMountPak", param)

		PufferDownloader.SyncFinishToCallback(filestate.outterTaskID, isMountSuccess, filestate.lastErrno);
	end

	-- 清理filestate, 否则该文件的相关下载会卡死
	PufferDownloader.filestateList[filestate.outterTaskID] = nil;
end

-- 重试当前 Stage, 可能会有进度回扯的现象，需要上层处理。超过最大重试次数自动失败
function PufferDownloader.RetryCurStage(filestate)
	log("[LogicPufferDownloaderLUA] RetryCurStage: filestate ??" .. tostring(filestate));

	-- 保底，保证不会对已停止的任务进行重试
	if PufferDownloader.filestateList[filestate.outterTaskID] == nil then
		log("[LogicPufferDownloaderLUA] RetryCurStage: outerTask:" .. filestate.outterTaskID .. " has been stopped do not continue retrying");
		return;
	end

	filestate.retryStage = filestate.curStage;
	filestate.curStage = PufferDownloader.STAGE_RETRY;
	filestate.retryTimes = filestate.retryTimes + 1;

	PufferDownloader.ReportStageChange(filestate);

	-- 是否需要向上层同步重试状态，考虑到逻辑过于复杂，暂不抛出
	-- PufferDownloader.SyncProgressToCallback(filestate.outterTaskID, 99, 100, filestate.curStage);
	log("[LogicPufferDownloaderLUA] RetryCurStage: filestate " .. tostring(filestate));

	if filestate.retryTimes >= PufferDownloader.MAX_RETRY_TIMES then
		log("[LogicPufferDownloaderLUA] RetryCurStage: Over Max RetryTimes ");
		PufferDownloader.FinishRequestFile(filestate);
		return false;
	end

	local callback = function()
		PufferDownloader.PufferStageFunction[filestate.retryStage](filestate);
	end

	-- 三秒后静默重试
	PufferDownloader.retryTimer = Timer.InsertTimer(3, callback, false, false);

	return true;
end

-- Puffer 内部回调
function PufferDownloader.OnDownloadProgress(taskId, nowSize, totalSize)
	if not MAP_DOWNLOAD_INCREMENTAL_VERSION then
		TeamUpMatchInfoUI.OnUpdateDownloadProgress(taskId, nowSize, totalSize);
		return
	end

	log("[LogicPufferDownloaderLUA] OnDownloadProgress: pufferTaskID:" .. taskId .. " nowSize: " .. tostring(nowSize) .. " totalSize: " .. tostring(totalSize));
	local processedFilestateList = {};
	-- 如果此任务下载的是文件列表
	if taskId == PufferDownloader.fileListPufferTaskID then
		processedFilestateList = PufferDownloader.filestateList;
	else -- 如果此任务下载的是其他文件
		local filestate = PufferDownloader.GetfilestateByPufferTaskID(taskId);
		if filestate == nil then
			sandbox.LogError("[LogicPufferDownloaderLUA] OnDownloadProgress pufferTaskID is not mapping to filestate")
			-- 理论上不应该触发到此处，如果有是程序逻辑有漏洞
			-- TODO: add a GEM report here
			return;
		end

		processedFilestateList[filestate.outterTaskID] = filestate;
	end

	for outterTaskID, filestate in pairs(processedFilestateList) do
		PufferDownloader.SyncProgressToCallback(filestate.outterTaskID, nowSize, totalSize, filestate.curStage);
		log("[LogicPufferDownloaderLUA] OnDownloadProgress: filestate " .. tostring(filestate));
	end
end

function PufferDownloader.OnDownloadReturn(taskId, isSuccess, errorCode)
	if not MAP_DOWNLOAD_INCREMENTAL_VERSION then
		TeamUpMatchInfoUI.OnDownloadMapCompleted(taskId, isSuccess, errorCode);
		return
	end

	local processedFilestateList = {};
	-- 如果此任务下载的是文件列表, 各个文件列表共享一个PufferTaskId
	if taskId == PufferDownloader.fileListPufferTaskID then
		log("[LogicPufferDownloaderLUA] OnDownloadReturn: Fetch FileList finish ");
		TeamUpMatchInfoUI.InitMapInfo();
		processedFilestateList = PufferDownloader.filestateList;
		PufferDownloader.fileListPufferTaskID = 0;
	else -- 如果此任务下载的是其他文件
		local filestate = PufferDownloader.GetfilestateByPufferTaskID(taskId);
		if filestate == nil then
			sandbox.LogError("[LogicPufferDownloaderLUA] OnDownloadReturn pufferTaskID is not mapping to filestate");
			-- TODO: add a GEM report here
			return;
		end

		processedFilestateList[filestate.outterTaskID] = filestate;
	end
	log("[LogicPufferDownloaderLUA] OnDownloadReturn: isSuccess " .. tostring(isSuccess));

	for outterTaskID, filestate in pairs(processedFilestateList) do
		log("[LogicPufferDownloaderLUA] OnDownloadReturn: filestate " .. tostring(filestate));
		if not filestate.suspended then -- 如果该下载被暂停了
			if isSuccess == false then
				sandbox.LogError("[LogicPufferDownloaderLUA] OnDownloadReturn Error:" .. tostring(errorCode));
				filestate.lastErrno = errorCode;
				PufferDownloader.RetryCurStage(filestate);
			else
				-- 此处不进行状态同步，因为会有数据不一致的问题。
				-- PufferDownloader.SyncProgressToCallback(filestate.outterTaskID, nowSize, totalSize, filestate.curStage);

				if filestate.curStage == PufferDownloader.STAGE_FETCH_FILE_LIST then
					log("[LogicPufferDownloaderLUA] OnDownloadReturn: Fetch FileList finish " .. tostring(filestate));
					-- 为解绑地图版本号和包版本号做处理
					filestate.filename = PufferDownloader.GetRealFilename(filestate.filename);

					PufferDownloader.DownloadFileImp(filestate);
				elseif filestate.curStage == PufferDownloader.STAGE_FILE_DOWNLOADING then
					log("[LogicPufferDownloaderLUA] OnDownloadReturn: Fetch File finish over " .. tostring(filestate));
					if filestate.diffFilename ~= nil then
						PufferDownloader.MergeFile(filestate);
					else
						-- 若直接下载完整文件则 直接结束更新流程
						PufferDownloader.FinishRequestFile(filestate);
					end
				else
					sandbox.LogError("[LogicPufferDownloaderLUA] OnDownloadReturn: filestate curStage is invalid");
					filestate.lastErrno = PufferDownloader.ERR_INVALID_STAGE_DOWNLOAD_RETURN;
					PufferDownloader.RetryCurStage(filestate);
				end
			end
		end
	end
end

function PufferDownloader.OnInitProgress(stage, nowSize, totalSize)
end

function PufferDownloader.OnInitReturn(isSuccess, errorCode)
	-- 初始化结束立即拉取文件列表
	PufferDownloader.fileListPufferTaskID = GCPufferDownloader.RequestFile(Puffer, PufferDownloader.FILE_LIST_NAME, true);

	TeamUpMatchInfoUI.OnInitDownload(isSuccess, errorCode);
end


function PufferDownloader.StopTask(gameFrontendHUD, outterTaskID)
	-- gameFrontendHUD 此参数只为兼容性存在

	log("[LogicPufferDownloaderLUA] StopTask: outterTaskID:" .. tostring(outterTaskID));
	local filestate = PufferDownloader.filestateList[outterTaskID];
	if filestate ~= nil then
		filestate.suspended = true;

		local stageToStop = filestate.curStage;
		if stageToStop == PufferDownloader.STAGE_RETRY then
			-- 停止重试 timer 否则会出现对同一文件启动多个任务
			if PufferDownloader.retryTimer then
				log("[LogicPufferDownloaderLUA] StopTask: RemoveRetry Timer");
				Timer.RemoveTimer(PufferDownloader.retryTimer);
			end

			stageToStop = filestate.retryStage;
		end

		if stageToStop == PufferDownloader.STAGE_INITIALIZING then
			-- 无需处理
			log("[LogicPufferDownloaderLUA] StopTask: INITIALIZING nothing to process");
		elseif stageToStop == PufferDownloader.STAGE_FETCH_FILE_LIST then
			-- 文件列表不大，很多功能会用到，不结束下载文件列表的操作, 由于filestateList已删除此项，所以不会继续执行
			log("[LogicPufferDownloaderLUA] StopTask: FETCH_FILE_LIST just let fetch finished");
		elseif stageToStop == PufferDownloader.STAGE_FILE_DOWNLOADING then
			log("[LogicPufferDownloaderLUA] StopTask: FILE_DOWNLOADING stop download");
			-- 停止Puffer下载任务
			if filestate.pufferTaskID ~= nil then
				GCPufferDownloader.StopTask(Puffer, filestate.pufferTaskID);
			end
		elseif stageToStop == PufferDownloader.STAGE_FILE_MERGING then
			log("[LogicPufferDownloaderLUA] StopTask: FILE_MERGING merge thread became slient");
			-- 静默Merge线程，如果下次同文件进来会复用这个线程
			filestate.slient = true;
		elseif stageToStop == PufferDownloader.STAGE_FILE_CHECKING then
			log("[LogicPufferDownloaderLUA] StopTask: FILE_CHECKING stop checking");
			GCPufferDownloader.StopCheckDownloadFileFraming(Puffer, outterTaskID);
		elseif stageToStop == PufferDownloader.STAGE_RETRY then
			-- 无需处理
			log("[LogicPufferDownloaderLUA] StopTask: RETRY do nothing");
		elseif stageToStop == PufferDownloader.STAGE_FINISH then
			-- 直接返回，删除交给Finish去做
			log("[LogicPufferDownloaderLUA] StopTask: FINISH Let it finish");
			return true;
		end
		-- 清理状态，否则无法重试
		PufferDownloader.filestateList[filestate.outterTaskID] = nil;

		log("[LogicPufferDownloaderLUA] current filestateList")
		for k,v in pairs(PufferDownloader.filestateList) do
			log("[LogicPufferDownloaderLUA] " .. tostring(k) .. " " .. tostring(v));
		end
	else
		sandbox.LogError("[LogicPufferDownloaderLUA] StopTask: unknownOutterTaskID:" .. tostring(outterTaskID));
	end
	return true
end

-- 获取对应文件的大小，如果下载差异就是差异的大小
-- fullsize true 则一定返回文件大小，nil/false 则返回差异文件大小或文件大小
function PufferDownloader.GetFileSizeCompressed(gamefrontedendhud, filename, fullsize)
	-- gamefrontedendhud 遗弃，只为接口兼容保留
	fullsize = fullsize or false;
	if PufferDownloader.IsFileListExist() then
		filename = PufferDownloader.GetRealFilename(filename);
		local downloadFilename = filename;

		if not fullsize then
			-- 占位用的filestate，用完直接丢弃
			local filestate = PufferDownloader.FileState(filename);
			downloadFilename = PufferDownloader.GetTargetFilename(filestate);
		end

		log("[LogicPufferDownloaderLUA] GetFileSizeCompressed: targetFilename:" .. downloadFilename);
		local fileSize = GCPufferDownloader.GetFileSizeCompressed(Puffer, downloadFilename);
		if 0 < fileSize and fileSize < 104858 then	--小于0.1M，返回0.1M
			fileSize = 104858;
		end
		return fileSize;
	else
		log("[LogicPufferDownloaderLUA] GetFileSizeCompressed: filelist Not Exist:");
		return 0;
	end
end

-- 主要用于合并失败后放弃合并转而下载完整版本
function PufferDownloader.DeleteAllOldPak(target_prefix)
-- 不论本地是否有正确的地图，不等于app版本号的旧地图一律清除
	local version = Client.GetApplicationVersion();

	if target_prefix == nil then
		target_prefix = ".+_.+_"; -- support for multiple type of resource
	end
	-- 检查本地所有的 pak 文件
	local ret = GCPufferDownloader.ReturnLocalFiles(PufferDownloader.DOWNLOAD_DIR_RELATIVE, "");

	for idx, filename in pairs(ret) do
		local prefix, localMapVersion = PufferDownloader.ParsePakName(filename);
		log("[LogicPufferDownloaderLUA] DeleteAllOldPak parse local filename " .. filename .. " Prefix:" .. tostring(prefix) .. " versionNo " .. tostring(localMapVersion));
		if prefix ~= nil and localMapVersion ~= nil then -- 如果本地文件后缀不是 pak 会被自动忽略
			if string.match(prefix, target_prefix) ~= nil and
				PufferDownloader.CompareVersion(localMapVersion, version) < 0 then
				local filePath = Client.ProjectSavedDir() .. PufferDownloader.DOWNLOAD_DIR_RELATIVE .. filename;
				GCPufferDownloader.DeleteFile(filePath);
				log("[LogicPufferDownloaderLUA] DeleteAllOldPak delete filename " .. filePath);
			end

		end
	end

end

function PufferDownloader.GEMReportEvent(SubEventName, param)
	local GEM_param = {
		SubEvent = SubEventName
	};
	for i=1,#param do
		GEM_param["K" .. (i-1)] = param[i];
	end

	for k, v in pairs(GEM_param) do
		log("[PufferReportEvent] " .. tostring(k) .. " " .. tostring(v));
	end

	Client.GEMReportEvent(GameFrontendHUD, "PufferEvent", GEM_param);
end

function PufferDownloader.GetRealFilename(filename)

	if GCPufferDownloader.IsFileExist(Puffer, filename, "pak") then
		return filename;
	end

	local basename, ext = string.match(filename, "(.+)(%..+)");

	local fileListContent = GCPufferDownloader.ReadFile(Puffer, PufferDownloader.FILE_LIST_NAME);
	local jsonobj = json.decode(fileListContent)
	if jsonobj == nil then
		sandbox.LogError("[LogicPufferDownloaderLUA] GetRealFilename parse json FAILED!");
		-- 容灾保底，没有文件就返回自己
		return filename;
	end
	local versionMapping = jsonobj.version_mapping;
	local retName = "";
	if versionMapping[basename] == nil then
		local prefix, versionNo = string.match(basename, "(.+_.+_).*");
		retName = versionMapping[prefix .. "default"];
	else
		retName = versionMapping[basename];
	end

	log("[LogicPufferDownloaderLUA] name mapping from " .. filename .. " to " .. retName .. ext)
	return retName .. ext;
end

function PufferDownloader.IsFileExist(gamefrontendhud, filename)
	-- gamefrontendhud 没有实际意义，做接口兼容用
	local realFilename = PufferDownloader.GetRealFilename(filename);
	return GCPufferDownloader.IsFileExist(Puffer, realFilename, "pak");
end

function PufferDownloader.IsFileExistByExtension(gamefrontendhud, filename, extension)
	-- gamefrontendhud 没有实际意义，做接口兼容用
	local realFilename = PufferDownloader.GetRealFilename(filename);
	return GCPufferDownloader.IsFileExist(Puffer, realFilename, extension)
end

function PufferDownloader.DeleteFile(filename)
	local realFilename = PufferDownloader.GetRealFilename(filename);
	local fullName = Client.ProjectSavedDir() .. PufferDownloader.DOWNLOAD_DIR_RELATIVE .. realFilename;
	log("[LogicPufferDownloaderLUA] Delete" .. filename .. " (i.e. " .. realFilename .. ")");
	return GCPufferDownloader.DeleteFile(fullName);
end