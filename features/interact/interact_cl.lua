-- Interact facade: the stub each resource includes. Forwards to the one controller in da_lib.
--
-- Its one real job is CALLBACK LOCALITY. `register` is handed a def with a closure on it; the
-- closure stays here, in the registering resource's runtime, keyed by the id the controller hands
-- back. Only the serializable half goes down. When the controller broadcasts a fire, the handler
-- below finds the closure and runs it — so `callback = function(def, ctx) ... end` keeps working
-- unchanged at every call site, while the registry itself holds nothing it cannot marshal.

local Interact = {}

local callbacks = {}   -- [id] = fn      LOCAL. Never leaves this runtime.
local defs      = {}   -- [id] = def     the original table, so callback(def, ctx) still gets its extras

-- Everything except the closure. The def is data from here on.
local function serializable(def)
    local out = {}
    for k, v in pairs(def) do
        if k ~= "callback" then out[k] = v end
    end
    return out
end

-- def = {
--   models | entity | coords (+radius) | player   -- what it attaches to
--   kind   = "interact" | "pickup" | "farm" | "turnIn" | "wagonTurnIn"   (default "interact")
--   type   = "WaterTrough"          -- kind+type derives the condition keyword: interactWaterTrough
--   label, icon, offset, bone       -- the dot
--   when   = { ... }                -- da_condition list; gates the DOT, not the keyword
--   scenario = "fill_trough"        -- sugar: synthesizes the callback (see below)
--   callback = function(def, ctx)   -- stays local
--   data   = { ... }                -- anything the callback or a `lookup` row wants; serializable
-- }
Interact.register = function(def)
    local cb = def.callback

    -- SUGAR, and the point of the whole exercise: an interact may name a scenario instead of
    -- carrying a callback. Then ONE declaration drives both the world dot and the anim-menu entry,
    -- gated by the same condition, and they cannot disagree — which they currently do (da_xinteracts
    -- fires queueAnim directly, bypassing a condition check that has been false in production the
    -- whole time). Fully serializable, so a builder UI can export it.
    if not cb and def.scenario then
        local scenario = def.scenario
        local state    = def.state or "enter"
        cb = function(_, ctx) da_anims.play(scenario, state, { interact = ctx }) end
    end

    local id = exports.da_lib:interactRegister(GetCurrentResourceName(), serializable(def))
    if cb then callbacks[id] = cb end
    defs[id] = def
    def.id = id
    return id
end

Interact.remove = function(id)
    callbacks[id] = nil
    defs[id] = nil
    return exports.da_lib:interactRemove(id)
end

Interact.removeEntity = function(handle) return exports.da_lib:interactRemoveEntity(handle) end

-- The scan, the keyword set, and the target resolver. One export hop each — `nearby` is folded into
-- a condition batch's compute as a SINGLE call, not one per keyword, which is the design the
-- condition benchmark killed.
Interact.get     = function(id)      return exports.da_lib:interactGet(id) end
Interact.scan    = function(r)       return exports.da_lib:interactScan(r) end
Interact.nearby  = function(r)       return exports.da_lib:interactNearby(r) end
Interact.lookup  = function(k, t, r) return exports.da_lib:interactLookup(k, t, r) end
Interact.fire    = function(iid, ctx) return exports.da_lib:interactFire(iid, ctx) end
Interact.list    = function()        return exports.da_lib:interactList() end
Interact.keywords = function()       return exports.da_lib:interactKeywords() end

-- The owner's half of the dispatch. Every resource that includes the facade hears every fire; only
-- the one holding the closure acts on it.
AddEventHandler("da_interact:fire", function(id, ctx)
    local cb = callbacks[id]
    if not cb then return end
    cb(defs[id], ctx)
end)

_ENV.da_interact = Interact
