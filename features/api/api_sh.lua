DAAPI = exports.da_lib:importAPI()

-- Dispatch: framework adapter override -> Default adapter -> out-of-contract warn.
-- Reads DAAPI.Framework / DAAPI.Default LIVE on every call rather than capturing
-- the tables at load, so adapter load order is not load-bearing. The API contract
-- is the Default adapter's keyset: anything Default (or the framework) implements is
-- in-contract; a call neither implements is out-of-contract and is the only warn path.
local apiCall = setmetatable({ framework = DAAPI.ActiveFramework }, {
    __index = function(_, name)
        return setmetatable({}, {
            __call = function(_, ...)
                local framework = DAAPI.Framework
                local default = DAAPI.Default
                if framework[name] then
                    return framework[name](...)
                elseif default[name] then
                    return default[name](...)
                else
                    log.warn("API call '" .. name .. "' is not in the contract — no adapter (framework '" .. DAAPI.ActiveFramework .. "' or Default) implements it")
                    return nil
                end
            end,
        })
    end,
})

_ENV.API = apiCall
