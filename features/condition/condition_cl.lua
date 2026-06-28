-- Condition engine (local, per-resource)
--
-- A fast batch cache of boolean world/player conditions, compiled into each resource
-- that includes it: `@da_lib/features/condition/condition_cl.lua`. Every resource gets
-- its OWN registry + cache in its own Lua runtime — there is no cross-resource
-- controller.
--
-- Why local: we benchmarked a da_lib singleton reached via exports. The export hop +
-- marshalling the result table back across the runtime boundary costs ~7-10x a local
-- fetch (~17-247us vs ~1-25us per fetch), and a per-condition funcRef variant was far
-- worse (~25ms/fetch at 1000 conditions). For the primary goal — the fastest possible
-- batch cache — the engine is local; cross-resource value sharing is given up for speed.
--
-- Usage:
--   da_condition.register(id, { ctime = 0, names = {...}, compute = fn(missNames) -> {name=val} })
--   da_condition.register(id, { ctime = 0, conditions = { { name=, callback=fn }, ... } })
--   local v = da_condition.fetch(id)            -- { name = value, ... }
--   da_condition.check(v, { onMount = true, isDead = da_condition.allow })
--   da_condition.eval(id, list)                 -- fetch + check in one call
-- The cache is keyed by condition NAME, so a condition shared across several ids in
-- this resource is computed once per freshness window (ctime ms; 0 = always fresh).

local ALLOW = "allow"

local registry = {} -- id   -> { ctime, model, names, byName?, compute? }
local cache = {}    -- name -> { value, ts }  (ts = GetGameTimer() at last compute)

local function isFresh(entry, ctime, now)
    return entry ~= nil and ctime ~= 0 and entry.ts ~= nil and (now - entry.ts) < ctime
end

local Condition = {}
Condition.allow = ALLOW

Condition.register = function(id, spec)
    if not id then log.error("condition: register needs an id"); return end
    if type(spec) ~= "table" then log.error("condition: register needs a spec table"); return end

    local entry = { ctime = spec.ctime or 0 } -- default: always fresh (recompute every fetch)
    if spec.compute then
        entry.model = "batch"
        entry.compute = spec.compute
        entry.names = spec.names or {}
    elseif spec.conditions then
        entry.model = "each"
        entry.names = {}
        entry.byName = {}
        for _, c in ipairs(spec.conditions) do
            entry.names[#entry.names + 1] = c.name
            entry.byName[c.name] = c.callback
        end
    else
        log.error("condition: spec needs `compute` (batch) or `conditions` (per-condition)")
        return
    end

    registry[id] = entry
    return true
end

Condition.fetch = function(id)
    local entry = registry[id]
    if not entry then log.warn("condition: id not registered:", id); return {} end

    local ctime = entry.ctime
    local now = GetGameTimer()
    local results = {}
    local miss

    for i = 1, #entry.names do
        local name = entry.names[i]
        local c = cache[name]
        if isFresh(c, ctime, now) then
            results[name] = c.value
        else
            miss = miss or {}
            miss[#miss + 1] = name
        end
    end

    if miss then
        if entry.model == "batch" then
            local computed = entry.compute(miss) or {} -- one call fills all misses
            for i = 1, #miss do
                local name = miss[i]
                local v = computed[name]
                cache[name] = { value = v, ts = now }
                results[name] = v
            end
        else
            for i = 1, #miss do
                local name = miss[i]
                local cb = entry.byName[name]
                local v = cb and cb()                  -- keep a legitimate false!
                cache[name] = { value = v, ts = now }
                results[name] = v
            end
        end
    end

    return results
end

-- list[name] == allow -> wildcard; otherwise strict equality with values[name].
-- A name missing from values fails (matches the original Conditions.Check).
Condition.check = function(values, list)
    if not list then return true end
    for name, want in pairs(list) do
        if want ~= ALLOW and values[name] ~= want then return false end
    end
    return true
end

-- fetch + check in one call (the common "does this set hold right now?" question).
Condition.eval = function(id, list)
    return Condition.check(Condition.fetch(id), list)
end

-- Drop cached values for an id's names (force a recompute). With no registered id,
-- clears the whole cache.
Condition.evict = function(id)
    local entry = registry[id]
    if not entry then cache = {}; return end
    for i = 1, #entry.names do
        cache[entry.names[i]] = nil
    end
end

Condition.unregister = function(id)
    Condition.evict(id)
    registry[id] = nil
end

_ENV.da_condition = Condition
