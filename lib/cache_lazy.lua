-- Lazy cache
-- Cache a defined function result. When calling the function lazy(ms).fn()
-- the function will return the cached result if the time elapsed is less than
-- the defined ms, otherwise the function will be called and update the cache.

-- @usage
-- lazy.myFunction = function(a,b) return a*b end
-- lazy(1000).myFunction(1,2)

local cache = {}
local lazy = setmetatable({}, {
    __call = function(_, delay)
        delay = delay or 0
        return setmetatable({}, {
            __index = function(_, name)
                return setmetatable({}, {
                    __call = function(_, ...)
                        if not cache[name] then
                            return nil
                        end
                        if delay == nil or cache[name].ttl == nil or GetGameTimer() - delay >= cache[name].ttl then
                            cache[name].ttl = GetGameTimer()
                            cache[name].value = cache[name].fn(...)
                        end
                        return cache[name].value
                    end,
                })
            end,
        })
    end,
    __newindex = function(_, name, fn)
        assert(
            fn ~= nil and
            (type(fn) == "function" or
            (type(fn) == "table" and fn['__cfx_functionReference'])),
            "TypeError: callback is not type: \"function\"."
        )
        cache[name] = { fn = fn, }
    end,
})

_ENV.lazy = lazy
