# Logging
The Logging utility includes log levels which allow limiting the amount/level of logging for individual resources. Now you don't have to remove all your useful debug logging when pushing a script to LIVE, or if you forget to remove a log, players wont be able to see under the hood. If you still need to debug an issue on your live server, you will be able to configure the logging level for your client so that you are able to view the pertinent information.

## Register
To use log levels provided by da_lib, after import the da_lib, register the resource with the logger:
```lua
da = exports.da_lib:importLib()
da.Log.Register(function(msg) print(msg) end)
```

You can still use the da.Log calls if you do not register the resource, but it will print to console from da_lib with your resource in brackets.

## Levels
By default, if the convar `server_type == DEV` is set, the log level will be set to 5 (Debug), if you are not on a DEV server the log level will be set to 3 (Info). A resource will log to the client console any line that is at or below the set logging level.

Log levels are in the following order:
1. Error
2. Warn
3. Info
4. Verbose
5. Debug
6. DebugVerbose

## Setting the level
The log level can only be set if the resource is registered. The level can be set when registering the resource by passing the level as the second parameter. Setting the log level will override the defaults for both DEV and LIVE servers:
```lua
da = exports.da_lib:importLib()
da.Log.Register(function(msg) print(msg) end, 6) -- Set the log level to 6 (DebugVerbose) for both DEV and LIVE
```

You can also pass in the string equivalent of the log level:
```lua
da = exports.da_lib:importLib()
da.Log.Register(function(msg) print(msg) end, "verbose") -- Set the log level to 4 (Verbose) for both DEV and LIVE
```

## Logging
You can call specific log levels using the da_lib:
```lua
da.Log.Error("This will log with red text and prefixed by ERROR:") -- ERROR: This will log with red...
da.Log.Warn("This will log with yellow text and prefixed by WARN:") -- WARN: This will log with yellow...
da.Log.Info("This is a log that will be visible by default on LIVE servers")
da.Log.Debug("This line will be printed to console if the log level is >= 5")
```

## Setting the log level
By using applicable log levels for specific info, you can have access to information if needed, or you can silence a script entirely. For each resource client and server will have separate log levels, so you will need to set each level independantly.
```lua
dalib_log_set da_lib debugVerbose
-- Outputs: [       script:da_lib] Set log level 'da_lib' debug->debugVerbose
```

You can set the log level using a number to a level less than 1, this will mute all logs from that resource that are called through da.Log.
```lua
dalib_log_set da_lib 0
```

## Logging tables and other data types
I use a string formatter which checks the type and then iterates over that data type to print the information. This way you dont have to manually iterate over key value pairs. Simply include the data type into the logging call.
```lua
tableData = { info = "Useful", name = "td1" }
da.Log.Debug("My Data Table:", tableData)
-- Outputs: 'My Data Table:    {["name"]="td1", ["info"]="Useful", }'
```
