-- Weapon library (local player). Game functionality only: use, manage, ammo.
-- Read-only "see the whole picture" inspection lives in da_audit, not here.
local Weapon = {}

-- Accepts a weapon hash (number) or a weapon name (string, e.g. "weapon_revolver_cattleman").
local resolveHash = function(weaponName)
    if type(weaponName) == "string" then
        return GetHashKey(weaponName)
    end
    return weaponName
end

-- The game's authoritative default attach point for a weapon, via
-- _GET_DEFAULT_WEAPON_ATTACH_POINT. Non-melee returns its exact slot (e.g.
-- revolver=2, rifle=10). Melee returns -1, which tells GiveWeaponToPed to
-- auto-place it in a free knife/melee slot — so a knife lands in slot 4 and a
-- machete in slot 13 without conflict. Confirmed by da_test/features/weapon.
-- (Replaces the old group-based guess that forced every melee into slot 4.)
local defaultAttachpoint = function(weaponHash)
    return Citizen.InvokeNative(0x65DC4AC5B96614CB, weaponHash, Citizen.ResultAsInteger())
end

-- ===================== USE — what's in the player's hand =====================

Weapon.current = function(attachPoint)
    attachPoint = attachPoint or 0
    local _, weaponHash = GetCurrentPedWeapon(PlayerPedId(), true, attachPoint, true)
    return weaponHash
end

-- Internal: swap the equipped weapon at an attach point and wait for it to take.
-- A freshly-given weapon isn't immediately drawable (SetCurrentPedWeapon no-ops
-- until it's ready — ~100ms melee, ~400ms revolver), so we re-issue until it
-- takes or we time out. This makes equip self-adaptive: it succeeds as soon as
-- the weapon is ready, so callers don't need a fixed settle delay before equip.
local change = function(weaponHash, attachPoint)
    SetCurrentPedWeapon(PlayerPedId(), weaponHash, false, attachPoint)

    local timeout = GetGameTimer() + 1500
    while Weapon.current(attachPoint) ~= weaponHash do
        if GetGameTimer() > timeout then
            log.warn("Failed to equip weapon " .. weaponHash .. " in alloted time")
            return false
        end
        Citizen.Wait(50)
        SetCurrentPedWeapon(PlayerPedId(), weaponHash, false, attachPoint) -- re-issue (no-op until ready)
    end
    if weaponHash == `weapon_unarmed` then
        Citizen.Wait(300)
    end
    return true
end

Weapon.equip = function(weaponHash, attachPoint)
    attachPoint = attachPoint or 0
    local currentHash = Weapon.current(attachPoint)
    if currentHash == weaponHash then return; end
    if currentHash ~= `weapon_unarmed` then
        change(`weapon_unarmed`, 0)
    end
    if weaponHash == `weapon_unarmed` then return; end
    change(weaponHash, attachPoint)
end

Weapon.holster = function()
    Weapon.equip(`weapon_unarmed`, 0)
end

Weapon.toggle = function(weaponHash)
    if Weapon.current() == weaponHash then
        Weapon.holster()
    else
        Weapon.equip(weaponHash)
    end
end

-- ===================== MANAGE — what the player owns =====================

-- Give a weapon to the local player.
--   opts.ammo       number  starting ammo (default 100)
--   opts.equip      bool    force into hand now (default false)
--   opts.holster    bool    place into holster (default true)
--   opts.attachPoint number slot to place into (default: weapon's first valid slot)
Weapon.give = function(weaponName, opts)
    log.debug("giving weapon", weaponName, opts)
    local default = function(v, d) if v ~= nil then return v end return d end
    local weaponHash = resolveHash(weaponName)
    if not weaponHash then log.warn("da_weapon.give: invalid weapon", weaponName); return false end
    opts = opts or {}

    local ped = PlayerPedId()
    local ammo = default(opts.ammo, 100)
    local equipNow = default(opts.equip, false)
    local holster = default(opts.holster, true)
    local attachPoint = default(opts.attachPoint, defaultAttachpoint(weaponHash))
    local allowMultiple = default(opts.allowMultiple, false)
    local p7 = 0.5
    local p8 = 1.0
    local addReason = 0
    local ignoreUnlocks = false
    local permanentDegradation = default(opts.permanentDegradation, 0.0)
    local p12 = false

    log.debug("giving", ped, ammo, equipNow, holster, attachPoint)
    GiveWeaponToPed_2(
        ped,
        weaponHash,
        ammo,
        equipNow,
        holster,
        attachPoint,
        allowMultiple,
        p7,
        p8,
        addReason,
        ignoreUnlocks,
        permanentDegradation,
        p12
    )
    return true
end

-- Give a weapon directly into a specific attach point.
Weapon.attach = function(weaponName, attachPoint)
    log.debug("Attach weapon", weaponName, attachPoint)
    return Weapon.give(weaponName, { attachPoint = attachPoint })
end

-- eRemoveItemReason; RDR3 ignores the removal unless a valid reason is given.
local REMOVE_REASON_DEFAULT = 0xF77DE93D

-- Remove a single weapon from the local player.
Weapon.remove = function(weaponName)
    local weaponHash = resolveHash(weaponName)
    if not weaponHash then log.warn("da_weapon.remove: invalid weapon", weaponName); return false end
    log.debug("Removing weapon", weaponName)
    RemoveWeaponFromPed(PlayerPedId(), weaponHash, true, REMOVE_REASON_DEFAULT)
    return true
end

-- Remove every weapon from the local player. RemoveAllPedWeapons does not
-- reliably clear RDR3 inventory weapons, so also remove each known weapon.
Weapon.removeAll = function()
    log.debug("Removing all weapons")
    RemoveAllPedWeapons(PlayerPedId(), true, false)
    if dat and dat.weapon then
        local ped = PlayerPedId()
        for _, w in ipairs(dat.weapon) do
            if HasPedGotWeapon(ped, w.hash, 0, false) then
                RemoveWeaponFromPed(ped, w.hash, true, REMOVE_REASON_DEFAULT)
            end
        end
    end
    return true
end

-- Does the local player have this weapon?
Weapon.has = function(weaponName)
    local weaponHash = resolveHash(weaponName)
    if not weaponHash then return false end
    return HasPedGotWeapon(PlayerPedId(), weaponHash, 0, false)
end

-- ===================== AMMO =====================
-- Reserve = ammo carried on the person, pooled by ammo type (e.g. all rifles
-- share one rifle pool). Clip = rounds currently loaded in the weapon.

Weapon.ammoType = function(weaponName)
    local weaponHash = resolveHash(weaponName)
    if not weaponHash then return nil end
    return GetAmmoTypeForWeapon(weaponHash) or nil
end

-- Reserve ammo for the weapon's ammo type, on the person.
Weapon.getReserve = function(weaponName)
    return GetPedAmmoByType(PlayerPedId(), Weapon.ammoType(weaponName)) or 0
end

-- eRemoveItemReason; the per-type ammo remover ignores the call with an invalid
-- reason. REMOVE_REASON_USED is a valid, side-effect-free choice. (See da_test.)
local AMMO_REMOVE_REASON = 0x2188E0A3 -- REMOVE_REASON_USED

-- Remove an amount of reserve ammo for the weapon's ammo type.
Weapon.removeReserve = function(weaponName, amount)
    local ammoType = Weapon.ammoType(weaponName)
    if not ammoType then log.warn("da_weapon.removeReserve: invalid weapon", weaponName); return false end
    -- _REMOVE_AMMO_FROM_PED_BY_TYPE(ped, ammoType, amount, removeReason)
    Citizen.InvokeNative(0xB6CFEC32E3742779, PlayerPedId(), ammoType, amount or 0, AMMO_REMOVE_REASON)
    return true
end

-- Set reserve ammo for the weapon's ammo type to an exact value. Reserve is pooled
-- by ammo type, so all weapons sharing the type see the change. RedM's raw
-- SetPedAmmoByType only raises (lowering is a no-op, citizenfx/fivem #3980), so to
-- lower we subtract the difference via removeReserve. Confirmed by da_test.
Weapon.setReserve = function(weaponName, amount)
    local ammoType = Weapon.ammoType(weaponName)
    if not ammoType then log.warn("da_weapon.setReserve: invalid weapon", weaponName); return false end
    amount = math.max(0, amount or 0)
    log.debug("Setting reserve ammo", weaponName, amount)
    local ped = PlayerPedId()
    local current = GetPedAmmoByType(ped, ammoType) or 0
    if amount > current then
        SetPedAmmoByType(ped, ammoType, amount)        -- raise
    elseif amount < current then
        Weapon.removeReserve(weaponName, current - amount) -- lower
    end
    return true
end

Weapon.addReserve = function(weaponName, amount)
    if not resolveHash(weaponName) then return false end
    return Weapon.setReserve(weaponName, math.max(0, Weapon.getReserve(weaponName) + (amount or 0)))
end

-- Clear ALL of the player's reserve ammo (every ammo type) to zero in one call.
Weapon.clearAmmo = function()
    log.debug("Clearing all reserve ammo")
    Citizen.InvokeNative(0x1B83C0DEEBCBB214, PlayerPedId()) -- _REMOVE_ALL_PED_AMMO
    return true
end

-- Rounds loaded in the clip/cylinder.
Weapon.getClip = function(weaponName)
    local weaponHash = resolveHash(weaponName)
    if not weaponHash then return 0 end
    local _, clip = GetAmmoInClip(PlayerPedId(), weaponHash)
    return clip or 0
end

Weapon.setClip = function(weaponName, amount)
    local weaponHash = resolveHash(weaponName)
    if not weaponHash then return false end
    return SetAmmoInClip(PlayerPedId(), weaponHash, amount or 0)
end

-- Toggle infinite reserve ammo for a specific weapon.
Weapon.setInfiniteAmmo = function(toggle, weaponName)
    local weaponHash = resolveHash(weaponName)
    if not weaponHash then log.warn("da_weapon.setInfiniteAmmo: invalid weapon", weaponName); return false end
    SetPedInfiniteAmmo(PlayerPedId(), toggle and true or false, weaponHash)
    return true
end

-- Toggle a never-needs-reloading clip across the player's weapons.
Weapon.setInfiniteClip = function(toggle)
    Citizen.InvokeNative(0xFBAA1E06B6BCA741, PlayerPedId(), toggle and true or false) -- _SET_PED_INFINITE_AMMO_CLIP
    return true
end

-- Quick one-weapon dump for console use. The full audit lives in da_audit.weapon.
Weapon.debug = function()
    local w = Weapon.current()
    log.debug({
        hash = w,
        name = dat.getWeaponName(w) or "",
        ammoType = Weapon.ammoType(w),
        reserve = Weapon.getReserve(w),
        clip = Weapon.getClip(w),
    })
end

_ENV.da_weapon = Weapon
