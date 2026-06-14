local Weapon = {}

-- Accepts a weapon hash (number) or a weapon name (string, e.g. "weapon_revolver_cattleman").
local resolveHash = function(weaponName)
    if type(weaponName) == "string" then
        return GetHashKey(weaponName)
    end
    return weaponName
end

Weapon.current = function(attachPoint)
    attachPoint = attachPoint or 0
    local _, weaponHash = GetCurrentPedWeapon(PlayerPedId(), true, attachPoint, true)
    return weaponHash
end

Weapon.change = function(weaponHash, attachPoint)
    SetCurrentPedWeapon(PlayerPedId(), weaponHash, false, attachPoint)

    local timeout = GetGameTimer() + 1000
    while Weapon.current(attachPoint) ~= weaponHash do
        Citizen.Wait(0)
        if GetGameTimer() > timeout then
            log.warn("Failed to equip weapon " .. weaponHash .. " in alloted time")
            return
        end
    end
    if weaponHash == `weapon_unarmed` then
        Citizen.Wait(300)
    end
end

Weapon.equip = function(weaponHash, attachPoint)
    attachPoint = attachPoint or 0
    local currentHash = Weapon.current(attachPoint)
    if currentHash == weaponHash then return; end
    if currentHash ~= `weapon_unarmed` then
        Weapon.change(`weapon_unarmed`, 0)
    end
    if weaponHash == `weapon_unarmed` then return; end
    Weapon.change(weaponHash, attachPoint)
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

Weapon.attach = function(weaponHash, attachPoint)
    log.debug("Attach weapon", weaponHash, attachPoint)
    Weapon.give(weaponHash, {attachPoint = attachPoint})
end

-- Give a weapon to the local player.
--   opts.ammo    number  starting ammo (default 100)
--   opts.equip   bool    force into hand now (default false)
--   opts.holster bool    force into holster (default true)
Weapon.give = function(weaponName, opts)
    local default = function(v,d) if v ~= nil then return v end return d end
    local weaponHash = resolveHash(weaponName)
    if not weaponHash then log.warn("da_Weapon.give: invalid weapon", weaponName); return false end
    opts = opts or {}

    local ped = PlayerPedId()
    local ammo = default(opts.ammo, 100)
    local equipNow = default(opts.equipNow, true)
    local holster = default(opts.holster, false)
    local attachPoint = default(opts.attachPoint, 0)
    local allowMultiple = default(opts.allowMultiple, false)
    local p7 = 0.5
    local p8 = 1.0
    local addReason = 0
    local ignoreUnlocks = false
    local permanentDegradation = default(opts.permanentDegradation, 0.0)
    local p12 = false

    return GiveWeaponToPed_2(
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
end

-- Remove a single weapon from the local player.
Weapon.remove = function(weaponName)
    local weaponHash = resolveHash(weaponName)
    if not weaponHash then log.warn("da_weapon.remove: invalid weapon", weaponName); return false end
    log.debug("Removing weapon", weaponName)
    RemoveWeaponFromPed(PlayerPedId(), weaponHash, false, 0)
    return true
end

-- Remove every weapon from the local player.
Weapon.removeAll = function()
    log.debug("Removing all weapons")
    RemoveAllPedWeapons(PlayerPedId(), true, false)
    return true
end

-- Does the local player have this weapon?
Weapon.has = function(weaponName)
    local weaponHash = resolveHash(weaponName)
    if not weaponHash then return false end
    return HasPedGotWeapon(PlayerPedId(), weaponHash, 0, false)
end

-- Set the total ammo for a weapon to an exact amount.
Weapon.setAmmo = function(weaponName, amount)
    local weaponHash = resolveHash(weaponName)
    if not weaponHash then log.warn("da_weapon.setAmmo: invalid weapon", weaponName); return false end
    log.debug("Setting ammo", weaponName, amount)
    SetPedAmmo(PlayerPedId(), weaponHash, amount or 0)
    return true
end

-- Add to (or subtract from) the current ammo for a weapon.
Weapon.addAmmo = function(weaponName, amount)
    local weaponHash = resolveHash(weaponName)
    if not weaponHash then return false end
    return Weapon.setAmmo(weaponName, math.max(0, Weapon.getAmmo(weaponName) + (amount or 0)))
end

-- Get the current total ammo for a weapon.
Weapon.getWeaponAmmo = function(weaponName)
    local weaponHash = resolveHash(weaponName)
    if not weaponHash then return 0 end
    return GetAmmoInPedWeapon(PlayerPedId(), weaponHash) or 0
end

Weapon.getAmmoType = function(weaponName)
    local weaponHash = resolveHash(weaponName)
    if not weaponHash then return 0 end
    return GetAmmoTypeForWeapon(weaponHash) or nil
end

Weapon.getAmmo = function(weaponName)
    return GetPedAmmoByType(Weapon.getAmmoType(weaponName)) or 0
end

-- Set the rounds loaded in the clip/cylinder for a weapon.
Weapon.setClipAmmo = function(weaponName, amount)
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

Weapon.debug = function()
    local w = Weapon.current()
    local weaponData = {
        hash = w,
        name = dat.getWeaponName(w) or "",
        ammoType = Weapon.getAmmoType(w),
        weaponAmmo = Weapon.getWeaponAmmo(w),
        pedAmmo = Weapon.getAmmo(w),
    }
    log.debug(weaponData)
end

_ENV.da_weapon = Weapon
