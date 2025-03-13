DAAPI = exports.da_lib:importAPI()
local Framework = DAAPI.Framework
local Default = DAAPI.Default

local apiCall = setmetatable({ framework = DAAPI.ActiveFramework }, {
    __index = function(_, name)
        return setmetatable({}, {
            __call = function(_, ...)
                if Framework[name] then
                    return Framework[name](...)
                elseif Default[name] then
                    return Default[name](...)
                else
                    log.warn("Framework '".. DAAPI.ActiveFramework .. "' does not have function '" .. name .. "'")
                    return nil
                end
            end,
        })
    end,
})

_ENV.API = apiCall
