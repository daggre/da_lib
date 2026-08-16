-- Dev-menu facade: how a resource puts its own entry in da_dev's dev tree, from its own code.
--
-- The entry belongs to the resource that owns the feature, not to da_dev. da_dev used to carry a
-- stub file per resource (src/tack_cl.lua and friends) that fired an event the owner listened for.
-- With the owner unloaded the item was still in the menu and did nothing — a dead key. Registered
-- from this side, the item exists exactly as long as its owner does.
--
-- Same trick as the interact facade: the CLOSURES STAY HERE, in the owner's runtime, keyed by an
-- id. Only the description travels. da_dev calls back through this resource's exports to run an
-- option or test its condition.
--
-- da_dev absent, started later, or restarted is all fine — entries are held here and (re)sent when
-- da_dev announces its registry. Nothing about this file requires da_dev to exist.
--
--   da_devmenu.addOpt("devRoot", "tack", "2", function() toggle() end)

local DevMenu = {}

local entries = {}   -- ordered descriptors, replayed on every da_dev start
local locals  = {}   -- [id] = { fn = , condition = }   LOCAL. Never leaves this runtime.
local nextId  = 0

local function ready()
    return GetResourceState("da_dev") == "started"
end

-- pcall: da_dev can be running without the registry (an older build), and a soft dependency that
-- takes the owner's load down with it is not soft.
local function push(entry)
    if not ready() then return false end

    local ok, live = pcall(function()
        return exports.da_dev:devMenuRegister(GetCurrentResourceName(), entry)
    end)
    if not ok then
        log.warn(("dev menu: da_dev rejected '%s' (%s)"):format(tostring(entry.name), tostring(live)))
        return false
    end
    return live and true or false
end

-- `condition` goes down as a bare boolean: da_dev only needs to know whether to ask.
local function record(entry, fn, condition)
    nextId = nextId + 1
    entry.id = nextId
    entry.condition = condition ~= nil
    locals[entry.id] = { fn = fn, condition = condition }
    entries[#entries + 1] = entry
    return push(entry)
end

-- Both return whether the entry is live in da_dev RIGHT NOW. `false` also means "da_dev is not
-- running" — the entry is kept here and sent when it comes up, so it is not an error.
--
-- `add` is a submenu, for a resource with more than one entry; its condition gates the whole
-- folder, exactly as in da_trie.
DevMenu.add = function(parent, name, key, condition, label)
    return record({ kind = "menu", parent = parent, name = name, key = key, label = label }, nil, condition)
end

DevMenu.addOpt = function(parent, name, key, fn, condition, label)
    return record({ kind = "opt", parent = parent, name = name, key = key, label = label }, fn, condition)
end

-- Take every entry this resource owns back out of the dev tree. Stopping the resource does this
-- too (da_dev watches onResourceStop); this is for rebuilding a menu at runtime.
DevMenu.clear = function()
    entries, locals = {}, {}
    if not ready() then return end
    pcall(function() exports.da_dev:devMenuClear(GetCurrentResourceName()) end)
end

-- The owner's half of the dispatch. da_dev holds the id, this runtime holds the function.
exports("daDevMenuFire", function(id)
    local entry = locals[id]
    if not entry or not entry.fn then return end
    entry.fn()
end)

exports("daDevMenuCondition", function(id)
    local entry = locals[id]
    if not entry then return false end
    if not entry.condition then return true end
    return entry.condition() and true or false
end)

-- da_dev fires this when its registry is up. Covers both orders — da_dev starting after us, and a
-- da_dev restart, which takes its whole trie with it.
AddEventHandler("da_dev:menuReady", function()
    for _, entry in ipairs(entries) do push(entry) end
end)

_ENV.da_devmenu = DevMenu
