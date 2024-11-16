-- Delay Cache
-- Function call which will return false if the delay cache function has been
-- called within the specified ms. You will most likely want to use the
-- cache_lazy if your use case involves doing a cache value lookup which
-- refreshes based on the specified ms.

-- @usage
-- delay.myDelay()
-- -- Calling again within specified ms will return false
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
