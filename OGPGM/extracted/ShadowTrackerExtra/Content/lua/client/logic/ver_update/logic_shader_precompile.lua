--[[
  Shader预编译
]]--

ShaderPreCompileSystem =  ShaderPreCompileSystem or {
	ShaderCompile = false,     --是否在预编译shader
    TotalTimer = 0.0,          --计时器，最多等待2分钟，超时就继续后续流程
    Timeout = 120,             --计时器，最多等待2分钟，超时就继续后续流程
}


function ShaderPreCompileSystem.HandleTimer(DeltaTime)
    if (ShaderPreCompileSystem.ShaderCompile == true) then
        ShaderPreCompileSystem.TotalTimer = ShaderPreCompileSystem.TotalTimer + DeltaTime;
        local progress = Client.GetShaderPrecompileProgress();
        log("Client.GetShaderPrecompileProgress() = " .. tostring(progress) .. ", TotalTimer = " .. tostring(ShaderPreCompileSystem.TotalTimer));

        --进度100%，则继续后续流程
        if (progress >= 100) then

            log("ShaderPreCompileSystem.ShaderCompile end");

            ShaderPreCompileSystem.OnShaderPrecompileFinish();          
        else
            --最多等待2分钟，超时就继续后续流程
            if (ShaderPreCompileSystem.TotalTimer > ShaderPreCompileSystem.Timeout) then
                log("ShaderPreCompileSystem.ShaderCompile timeout !!!");

                ShaderPreCompileSystem.OnShaderPrecompileFinish();
            else
                --刷新进度条
                ShaderPreCompileSystem.UpdateProgress(progress);
            end
        end
    end
end


--刷新进度条显示
function ShaderPreCompileSystem.UpdateProgress(progress)
    BP_ShaderCompileCurPercent = progress;
    LuaClassObj.HandleUIMessageNoFetch(bp_versionupdate, "UpdateProgressShaderPreCompile");
end

--开始shader预编译
function ShaderPreCompileSystem.StartShaderPrecompile()
    log("ShaderPreCompileSystem.StartShaderPrecompile()");
    ShaderPreCompileSystem.ShaderCompile = true;
    ShaderPreCompileSystem.TotalTimer = 0;
    LuaClassObj.HandleUIMessage(bp_versionupdate, "UpdateStartShaderPreCompile");
end

--预编译结束
function ShaderPreCompileSystem.OnShaderPrecompileFinish()
    if (ShaderPreCompileSystem.ShaderCompile == true) then
        ShaderPreCompileSystem.ShaderCompile = false;
        LuaClassObj.HandleUIMessage(bp_versionupdate, "StopShaderPreCompileTimer");
    end
    ShaderPreCompileSystem.ShaderCompile = false;
    ShaderPreCompileSystem.TotalTimer = 0;
    VersionUpdate.AfterFinishUpdate();
end

--处理shader预编译的入口
function ShaderPreCompileSystem.OnFinishUpdate()

    local progress = Client.GetShaderPrecompileProgress();

    --在set(1)之前就可以取下progress，如果是100可以不用等直接下一步
    if (progress == 100) then
        log("progress == 100 before StartShaderPrecompile")
        ShaderPreCompileSystem.OnShaderPrecompileFinish();
        return;
    end

    local start = Client.StartShaderPrecompile();

    if (start == true) then

        progress = Client.GetShaderPrecompileProgress();

        --如果已经编译过，那么progress==100，则执行后续流程
        if (progress == 100) then
            log("progress == 100 after StartShaderPrecompile")
            ShaderPreCompileSystem.OnShaderPrecompileFinish();
        else
            ShaderPreCompileSystem.StartShaderPrecompile();
        end
    else
        --如果调用预编译接口失败，则直接跳过，执行后续流程
        ShaderPreCompileSystem.OnShaderPrecompileFinish();
    end
end