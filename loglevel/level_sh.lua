--- Copyright © 2024 Joshua Nelson

LevelTypes = {}
Level = {}
LogLevel = {}

---Instantiate the logging level functions that are called from the da lib
Lib.Log.Error = function(...) Level.error:log(...) end
Lib.Log.Warn = function(...) Level.warn:log(...) end
Lib.Log.Info = function(...) Level.info:log(...) end
Lib.Log.Verbose = function(...) Level.verbose:log(...) end
Lib.Log.Debug = function(...) Level.debug:log(...) end
Lib.Log.DebugVerbose = function(...) Level.debugVerbose:log(...) end

--- Generate a string with the file and line number
Lib.Log.Line = function(debuginfo) return ("%s:%s: "):format(debuginfo.short_src, debuginfo.currentline) end

---Initialize a Log Level
---@param data table values to initialize LogLevel
function LogLevel:init(data)
    local t = {}
    setmetatable(t, self)
    self.__index = self
    assert(data.name, "Failed to initialize log level (Invalid Name): "..data.name)
    t.name = data.name
    table.insert(LevelTypes, t.name)
    t.level = #LevelTypes
    t.prefix = data.prefix
    t.prefixColor = data.prefixColor
    t.color = data.color
    Level[t.name] = t
    return t
end

---Print log message to console
function LogLevel:log(...)
    -- WARNING: dont use log from inside log
    local msg = self:formatMessage(...)
    if msg == "" then return; end
    local resource = GetInvokingResource() or GetCurrentResourceName()
    local threshhold = RegisteredResource[resource] and RegisteredResource[resource].level or DefaultLogLevel
    if not tonumber(threshhold) and not Level[threshhold] then
        print(("^1ERROR: [%s] Invalid log level threshhold: %s^7"):format(resource, threshhold))
    end
    threshhold = tonumber(threshhold) and threshhold or Level[threshhold] and Level[threshhold].level or DefaultLogLevel
    if self.level > threshhold then return; end
    local callback = resource and RegisteredResource[resource] and RegisteredResource[resource].callback or function(msg) print(("[%s] %s"):format(resource, msg)) end
    callback(msg)
end

---Add color and prefix to log message
function LogLevel:formatMessage(...)
    local msg = Lib.String.Concat(...)
    if msg == "" then return; end
    if self.color then msg = ("^%s%s^7"):format(self.color, msg) end
    if self.prefix then
        if self.prefixColor and self.color then
            msg = ("^%s%s %s"):format(self.prefixColor, self.prefix, msg)
        elseif self.prefixColor then
            msg = ("^%s%s^7 %s"):format(self.prefixColor, self.prefix, msg)
        else
            msg = ("%s %s"):format(self.prefix, msg)
        end
    end
    return msg
end

---Initialize Log Levels and configure their colors and prefixes
LogLevel:init({ name = "error", prefixColor = 1, color = 1, prefix = "ERROR:" })
LogLevel:init({ name = "warn", prefixColor = 3, prefix = "WARN:" })
LogLevel:init({ name = "info" })
LogLevel:init({ name = "verbose" })
LogLevel:init({ name = "debug", color = 3, })
LogLevel:init({ name = "debugVerbose", color = 3, prefix = "+" })
-- 0:White, 1:Red, 2:Green, 3:Yellow, 4:Blue, 5:Cyan, 6:Purple, 7:Gray, 8:Red, 9:Blue,

---Set the default log level to debug in development mode and info in production mode
DefaultLogLevel = Lib.Util.IsDev and Level.debug.level or Level.info.level
