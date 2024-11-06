log.debug("Initializing Framework API Client Defaults")

-- Register dependency checks to be lazy cached
local lazyDepends = {}
local LazyCacheRegisterDependCheck = function(resourceName)
    if not lazyDepends[resourceName] then
        lazyDepends[resourceName] = true
        lazy["depends_"..resourceName] = function()
            if next(exports[resourceName]) then return true end
            return false
        end
    end
end

local FW = {}

---@diagnostic disable-next-line: duplicate-set-field
FW.notify = function(message) log.info(message) end

FW.hasItems = function(items)
    local hasItems = {}
    for itemName in pairs(items) do
        if not hasItems[itemName] then
            hasItems[itemName] = {}
        end
        -- No inventory, mock having large amounts of everything
        table.insert(hasItems[itemName], { name = itemName, amount = 999 })
    end
    return hasItems
end

---@diagnostic disable-next-line: duplicate-set-field
FW.hasJob = function(jobName) return
    false
end

FW.checkDepends = function(resourceName)
    LazyCacheRegisterDependCheck(resourceName)
    return lazy(15000)['depends_' .. resourceName]()
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
    -- SetEntityMaxHealth(entity, 200)
    -- SetPedMaxHealth(entity, 200)
    SetEntityHealth(entity, GetEntityMaxHealth(entity))
end

FW.IsDead = function(entity)
    entity = entity or PlayerPedId()
    return IsEntityDead(entity)
end

DAAPI.Default = FW
