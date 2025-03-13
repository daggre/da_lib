local CurrentWeap = function(ap)
    ap = ap or 0
    local _, hash = GetCurrentPedWeapon(PlayerPedId(), true, ap, true)
    return hash
end

local ChangeWeapon = function(hash, ap)
    SetCurrentPedWeapon(PlayerPedId(), hash, false, ap)

    local timeout = GetGameTimer() + 1000
    while CurrentWeap(ap) ~= hash do
        Citizen.Wait(0)
        if GetGameTimer() > timeout then
            log.warn("Failed to equip weapon " .. hash .. " in alloted time")
            return
        end
    end
    if hash == `weapon_unarmed` then
        Citizen.Wait(300)
    end
end

local Equip = function(hash, ap)
    ap = ap or 0
    local currentHash = CurrentWeap(ap)
    if currentHash == hash then return; end
    if currentHash ~= `weapon_unarmed` then
        ChangeWeapon(`weapon_unarmed`, 0)
    end
    if hash == `weapon_unarmed` then return; end
    ChangeWeapon(hash, ap)
end

local weapon = {}

weapon.current = CurrentWeap

weapon.equip = Equip

weapon.holster = function()
    Equip(`weapon_unarmed`, 0)
end

weapon.toggle = function(hash)
    if weapon.current() == hash then
        weapon.holster()
    else
        weapon.equip(hash)
    end
end

weapon.attach = function(hash, ap)
    log.debug("Attach weapon", hash, ap)
end

_ENV.da_weapon = weapon
