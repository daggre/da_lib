--- Copyright © 2024 Joshua Nelson

if Lib.Util.IsDev then
    RegisterCommand("dalib_log_set", function(source, args, rawCommand)
        local resource = args[1]
        local logLevel= args[2]
        assert(resource and RegisteredResource[resource], ("Invalid resource: %s"):format(resource))
        assert(logLevel and tonumber(logLevel) or Level[logLevel], ("Invalid log level: %s"):format(logLevel))
        Lib.Log.SetLevel(resource, logLevel)
    end, false)

    RegisterCommand("dalib_log_test", function(source, args, rawCommand)
        Lib.Log.Error("test error")
        Lib.Log.Warn("test warn")
        Lib.Log.Info("test info")
        Lib.Log.Verbose("test verbose")
        Lib.Log.Debug("test debug")
        Lib.Log.DebugVerbose("test debugVerbose")
    end, false)

    RegisterCommand("dalib_log_dumpregistered", function(source, args, rawCommand)
        Lib.Log.Debug(Lib.String.Format(RegisteredResource))
    end, false)
end
