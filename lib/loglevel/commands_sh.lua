--- Copyright © 2024 Joshua Nelson

if Lib.Util.IsDev then
    -- If the server is in development mode, we can add some commands to help with debugging

    ---Set the log level for a resource
    ---@param args table Arg 1: resource name, Arg 2: log level (string|integer)
    RegisterCommand("dalib_log_set", function(source, args, rawCommand)
        local resource = args[1]
        local logLevel= args[2]
        assert(resource and RegisteredResource[resource], ("Invalid resource: %s"):format(resource))
        assert(logLevel and tonumber(logLevel) or Level[logLevel], ("Invalid log level: %s"):format(logLevel))
        Lib.Log.SetLevel(resource, logLevel)
    end, false)

    ---Generate a log of each log type
    RegisterCommand("dalib_log_test", function(source, args, rawCommand)
        Lib.Log.Error("test error")
        Lib.Log.Warn("test warn")
        Lib.Log.Info("test info")
        Lib.Log.Verbose("test verbose")
        Lib.Log.Debug("test debug")
        Lib.Log.DebugVerbose("test debugVerbose")
    end, false)

    ---Print the registered log resources and their log levels
    RegisterCommand("dalib_log_dumpregistered", function(source, args, rawCommand)
        Lib.Log.Debug(Lib.String.Format(RegisteredResource))
    end, false)
end
