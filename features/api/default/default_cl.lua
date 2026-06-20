log.debug("Initializing Framework API Client Defaults")

-- Default adapter (client): the graceful-degradation base. Enumerates the full
-- client API contract explicitly. Functions split into two kinds:
--   * standalone-meaningful — a real answer when no framework is installed
--   * no-op — framework-specific effects (inventory, hunger) go nowhere
local FW = {}

-- Standalone-meaningful --
---@diagnostic disable-next-line: duplicate-set-field
FW.notify = function(message) log.info(message) end

FW.hasItems = function(items)
    -- No inventory: report a large amount of everything so item-gated content runs.
    local hasItems = {}
    for itemName in pairs(items) do
        if not hasItems[itemName] then
            hasItems[itemName] = {}
        end
        table.insert(hasItems[itemName], { name = itemName, amount = 999 })
    end
    return hasItems
end

FW.isDead = function(entity)
    entity = entity or PlayerPedId()
    return IsEntityDead(entity)
end

FW.teleport = function(coords, fade)
    fade = fade == nil and true or fade
    local player = PlayerPedId()
    if fade then DoScreenFadeOut(100); end
    Citizen.Wait(100)
    FreezeEntityPosition(player, true)
    SetEntityCoords(player, coords.x, coords.y, coords.z)
    if coords.w ~= nil then
        SetEntityHeading(player, coords.w)
    end
    RequestCollisionAtCoord(coords.x, coords.y, coords.z)
    while not HasCollisionLoadedAroundEntity(player) do
        RequestCollisionAtCoord(coords.x, coords.y, coords.z)
        Citizen.Wait(0)
    end
    FreezeEntityPosition(player, false)
    if fade then DoScreenFadeIn(1000); end
end

FW.revive = function(entity)
    entity = entity or PlayerPedId()
    if not IsPedDeadOrDying(entity) then return; end

    SetEntityInvincible(entity, false)
    ClearPedBloodDamage(entity)
    SetEntityHealth(entity, GetEntityMaxHealth(entity))
end

---@diagnostic disable-next-line: duplicate-set-field
FW.hasJob = function(jobName) return false end

-- No inventory: a gate query reports having the item so item-gated content runs...
FW.hasItem = function(itemName) return true end
-- ...but an enumeration query has no inventory to return.
FW.getItems = function(filter) return {} end

-- No-op (info goes nowhere without a framework) --
FW.addItem = function(itemName, amount) return nil end
FW.eat = function(amount) return nil end
FW.drink = function(amount) return nil end
FW.consume = function(name, args) return nil end
FW.replaceItem = function(from, to, isInternalMove) return nil end
FW.setDoorStatus = function(args, status, value) return nil end

DAAPI.Default = FW
