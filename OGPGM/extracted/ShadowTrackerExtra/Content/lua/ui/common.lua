local M = {}

function M.CallCombinationArgs(func, args, ...)
    if args.n > 0 then
        local argsExtend = table.pack(...)
        if argsExtend.n > 0 then
            local argsInternal = {}
            table.move(args, 1, args.n, 1, argsInternal)
            table.move(argsExtend, 1, argsExtend.n, args.n + 1, argsInternal)
            
            local argsCount = args.n + argsExtend.n
            func(table.unpack(argsInternal, 1, argsCount))
        else
            func(table.unpack(args, 1, args.n))
        end
    else
        func(...)
    end
end

return M