local EquipWeapon = function(weaponHash, attachPoint)
    SetCurrentPedWeapon(PlayerPedId(), weaponHash, false, attachPoint)

    local timeout = GetGameTimer() + 1000
    while Lib.Weapon.Current(attachPoint) ~= weaponHash do
        Citizen.Wait(0)
        if GetGameTimer() > timeout then
            Lib.Log.Warn("Failed to equip weapon", weaponHash)
            return
        end
    end
    if weaponHash == `weapon_unarmed` then
        Citizen.Wait(300)
    end
end

Lib.Weapon.Current = function(attachPoint)
    attachPoint = attachPoint or 0
    local _, weaponHash = GetCurrentPedWeapon(PlayerPedId(), true, attachPoint, true)
    return weaponHash
end

Lib.Weapon.Equip = function(weaponHash, attachPoint)
    attachPoint = attachPoint or 0
    local currentWeaponHash = Lib.Weapon.Current(attachPoint)
    if currentWeaponHash == weaponHash then return; end
    if currentWeaponHash ~= `weapon_unarmed` then EquipWeapon(`weapon_unarmed`, 0) end
    if weaponHash == `weapon_unarmed` then return; end

    EquipWeapon(weaponHash, attachPoint)
end

Lib.Weapon.Holster = function()
    Lib.Weapon.Equip(`weapon_unarmed`, 0)
end

Lib.Weapon.ToggleEquip = function(weaponHash)
    if Lib.Weapon.Current() == weaponHash then
        Lib.Weapon.Holster()
    else
        Lib.Weapon.Equip(weaponHash)
    end
end

Lib.Weapon.Attach = function(weaponHash, attachPoint)
    -- TODO: add
end
