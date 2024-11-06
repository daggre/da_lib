-- Delay cache

-- @usage
-- delay.myDelay()
-- if delay.myDelay(1000) then print("1 sec passed since cached myDelay") end

local delays = {}
local delay = setmetatable({}, {
    __index = function(_, name)
        return setmetatable({}, {
            __call = function(_, delay)
                delay = delay or 0
                if delays[name] and GetGameTimer() - delay < delays[name] then
                    return false
                end
                delays[name] = GetGameTimer()
                return true
            end
        })
    end,
})

_ENV.delay = delay
