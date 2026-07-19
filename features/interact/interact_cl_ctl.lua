-- The interact registry and THE proximity scan. One controller, in da_lib, like da_mode.
--
-- It holds DATA ONLY. That is not a style preference — the registry lives in da_lib's runtime and
-- every existing call site passes `callback = function(def, ctx) ... end`. Functions do not marshal
-- across an export hop (the same wall that keeps da_anims' hooks in-process, and that the condition
-- benchmark already impaled itself on at ~25ms/fetch for the funcref variant). So:
--
--     data crosses the boundary; code stays home.
--
-- The facade (interact_cl.lua) keeps the closure in the REGISTERING resource, keyed by the id this
-- controller hands back, and registers only the serializable half. When something fires an interact,
-- the controller broadcasts `da_interact:fire` and the OWNER runs its own closure, in its own
-- runtime. No call site changes.
--
-- WHY IT MOVED. da_xinteracts owned the registry, the scan, and a condition vocabulary — three
-- things that aren't a UI resource's job. da_ranching owns the knowledge that a pitchfork is a
-- pitchfork. And if da_anims had built its own world lookup for `lookup` rows, that would have been
-- a SECOND per-frame proximity scan over the same entities.

local Interact = {}

local Defs      = {}    -- [id] = def (data only)
local ByModel   = {}    -- [modelHash]    = { id, ... }
local ByEntity  = {}    -- [entityHandle] = { id, ... }
local ByCoords  = {}    -- { id, ... }
local ByPlayer  = {}    -- { id, ... }
local nextId    = 0

local SCAN_RADIUS = 10.0

-- ===================== the vocabulary =====================
--
-- An interact declares `kind` + `type` and the condition keyword FALLS OUT: kind "pickup" + type
-- "Rake" is `pickupRake`. That reproduces the whole of the old hand-maintained list —
-- `pickupRake`, `turnInBale`, `farmRake`, `interactWaterTrough` — from one rule.
--
-- The kinds and types themselves are DATA (`da_lib/data/interact.lua`), and a registration is
-- validated against them: a typo'd type is a hard error here, not an interact that silently never
-- matches. See that file for why the vocabulary can't be "whatever someone happened to register".
local function keywordFor(def)
    if not def.type then return nil end
    return dat.interact.keyword(def.kind, def.type)
end

-- Every keyword the vocabulary admits — not just the ones something has registered. A scenario
-- gated on `interactWaterTrough` is valid whether or not a trough exists in the world yet; it just
-- won't appear in the menu.
Interact.keywords = function() return dat.interact.keywords() end

-- ===================== registration =====================

Interact.register = function(owner, def)
    assert(type(def) == "table", "da_interact.register: def must be a table")

    def.kind = def.kind or "interact"

    -- A typo'd type is a registration error, not an interact that quietly never matches anything
    -- and never says why. Same philosophy as the menu's key-collision rule.
    if def.type and not dat.interact.valid(def.kind, def.type) then
        error(("da_interact.register: '%s' is not a known %s type (see da_lib/data/interact.lua)")
            :format(tostring(def.type), tostring(def.kind)))
    end

    nextId = nextId + 1
    local id = ("%s:%d"):format(owner or "?", nextId)

    def.id    = id
    def.owner = owner
    Defs[id]  = def

    if def.models then
        local models = type(def.models) == "table" and def.models or { def.models }
        for _, m in ipairs(models) do
            ByModel[m] = ByModel[m] or {}
            table.insert(ByModel[m], id)
        end
    elseif def.entity then
        ByEntity[def.entity] = ByEntity[def.entity] or {}
        table.insert(ByEntity[def.entity], id)
    elseif def.coords then
        def.radius = def.radius or 3.0
        table.insert(ByCoords, id)
    elseif def.player then
        table.insert(ByPlayer, id)
    else
        error("da_interact.register: def names no target (models / entity / coords / player)")
    end

    return id
end

local function dropFrom(list, id)
    if not list then return end
    for i = #list, 1, -1 do
        if list[i] == id then table.remove(list, i) end
    end
end

Interact.remove = function(id)
    local def = Defs[id]
    if not def then return end
    if def.models then
        local models = type(def.models) == "table" and def.models or { def.models }
        for _, m in ipairs(models) do dropFrom(ByModel[m], id) end
    elseif def.entity then
        dropFrom(ByEntity[def.entity], id)
        if ByEntity[def.entity] and #ByEntity[def.entity] == 0 then ByEntity[def.entity] = nil end
    elseif def.coords then
        dropFrom(ByCoords, id)
    elseif def.player then
        dropFrom(ByPlayer, id)
    end
    Defs[id] = nil
end

Interact.removeEntity = function(handle)
    for _, id in ipairs(ByEntity[handle] or {}) do Defs[id] = nil end
    ByEntity[handle] = nil
end

-- A resource that stops takes its interacts with it. The mode controller already does exactly this,
-- and without it a restarted da_ranching would double-register every trough it owns.
Interact.clearOwner = function(owner)
    for id, def in pairs(Defs) do
        if def.owner == owner then Interact.remove(id) end
    end
end

Interact.get  = function(id) return Defs[id] end
Interact.list = function()
    local out = {}
    for _, def in pairs(Defs) do out[#out + 1] = def end
    return out
end

-- ===================== THE scan =====================
--
-- One implementation, two very different callers:
--
--   da_xinteracts  — every 16ms while the player holds X, and it wants dots: screen coords, labels,
--                    icons, and its condition filter over them.
--   da_anims       — once per menu open (the condition batch, ctime 250), and it wants only the
--                    keyword set: "is there a trough near me at all".
--
-- They never run in the same frame (you can't be holding X for dots and opening the anim menu at
-- once), so "exactly one proximity scan" is a statement about there being one implementation of it,
-- not about a shared background thread. Neither caller needs one: this is on-demand.
--
-- Returns INSTANCES, not defs — a def is "the pitchfork interact", an instance is "that pitchfork,
-- over there, handle 41233". `lookup` rows resolve to an instance; that's the whole point of them.
Interact.scan = function(radius)
    radius = radius or SCAN_RADIUS
    local ped    = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local out    = {}

    local function addEntity(handle)
        local model = GetEntityModel(handle)
        local ids   = {}
        for _, id in ipairs(ByModel[model]  or {}) do ids[#ids + 1] = id end
        for _, id in ipairs(ByEntity[handle] or {}) do ids[#ids + 1] = id end
        for _, id in ipairs(ids) do
            local def = Defs[id]
            if def then
                out[#out + 1] = {
                    iid    = id .. "@" .. handle,
                    def    = def,
                    handle = handle,
                    model  = model,
                    coords = GetEntityCoords(handle),
                }
            end
        end
    end

    for _, e in pairs(da_util.GetEntitiesNearPoint(coords, radius)) do addEntity(e) end
    for _, e in pairs(da_util.GetPedsNearPoint(coords, radius))     do addEntity(e) end

    for _, id in ipairs(ByPlayer) do
        local def = Defs[id]
        if def then
            out[#out + 1] = { iid = id .. "@" .. ped, def = def, handle = ped,
                              model = GetEntityModel(ped), coords = coords }
        end
    end

    for _, id in ipairs(ByCoords) do
        local def = Defs[id]
        if def then
            local d = #(coords - def.coords)
            if d <= def.radius then
                out[#out + 1] = { iid = id .. "@0", def = def, handle = 0, model = 0,
                                  coords = def.coords, distance = d }
            end
        end
    end

    return out
end

-- The keyword set, for a condition batch. `interactWaterTrough = true` means "a water trough is
-- within reach right now" — it does NOT consult the interact's own `when`. Those are two different
-- questions: `when` decides whether the DOT is offered; this decides whether the trough EXISTS.
-- Conflating them is how you get a menu entry that vanishes because you happen to be holding the
-- wrong item.
Interact.nearby = function(radius)
    local out = {}
    for _, inst in ipairs(Interact.scan(radius)) do
        local kw = keywordFor(inst.def)
        if kw then out[kw] = true end
    end
    return out
end

-- The `lookup` row's resolver: the NEAREST instance of a kind+type, or nil.
--
-- This is phase two of the two-phase target check. The condition gated the MENU (cheap, O(1), and
-- possibly three metres and two seconds ago). This resolves the actual target at FIRE time, and it
-- is the authoritative one. A single pre-enter resolve would be gating on stale information — the
-- player opens the menu, walks away from the trough, and picks "fill trough".
Interact.lookup = function(kind, typ, radius)
    kind = kind or "interact"
    local best, bestD
    local ped = PlayerPedId()
    local from = GetEntityCoords(ped)

    for _, inst in ipairs(Interact.scan(radius)) do
        local def = inst.def
        if def.kind == kind and def.type == typ then
            local d = inst.distance or #(from - inst.coords)
            if not bestD or d < bestD then
                best, bestD = inst, d
            end
        end
    end

    if not best then return nil end
    -- Data only: this crosses an export hop to reach the scenario's ctx.
    return {
        iid      = best.iid,
        id       = best.def.id,
        entity   = best.handle ~= 0 and best.handle or nil,
        model    = best.model,
        coords   = best.coords,
        distance = bestD,
        label    = best.def.label,
        data     = best.def.data,
    }
end

-- ===================== dispatch =====================
--
-- The owner runs its own closure. The controller never holds one.
Interact.fire = function(iid, ctx)
    local defId = iid:match("^(.-)@")
    local def   = defId and Defs[defId]
    if not def then return false end
    TriggerEvent("da_interact:fire", defId, ctx or {})
    return true
end

-- ===================== exports =====================

exports("interactRegister",     function(owner, def) return Interact.register(owner, def) end)
exports("interactGet",          function(id) return Defs[id] end)
exports("interactRemove",       function(id) return Interact.remove(id) end)
exports("interactRemoveEntity", function(h) return Interact.removeEntity(h) end)
exports("interactClearOwner",   function(o) return Interact.clearOwner(o) end)
exports("interactScan",         function(r) return Interact.scan(r) end)
exports("interactNearby",       function(r) return Interact.nearby(r) end)
exports("interactLookup",       function(k, t, r) return Interact.lookup(k, t, r) end)
exports("interactFire",         function(iid, ctx) return Interact.fire(iid, ctx) end)
exports("interactList",         function() return Interact.list() end)
exports("interactKeywords",     function() return Interact.keywords() end)

AddEventHandler("onResourceStop", function(res)
    if res == GetCurrentResourceName() then return end
    Interact.clearOwner(res)
end)

_ENV.da_interact_ctl = Interact
