# Weapon System

The Weapon module provides a simplified interface for managing and controlling weapons in RedM. It offers functions for weapon equipping, holstering, toggling, and checking current weapons.

## Features

- Current weapon detection
- Reliable weapon equipping with validation
- Weapon holstering
- Weapon toggling (equip/holster)
- Support for weapon attachment points

## API Reference

### Weapon Status

```lua
local weaponHash = da_weapon.current([attachmentPoint])
```
- `attachmentPoint` (number, optional): Attachment point to check (default: 0)
- **Returns** (hash): Hash of the currently equipped weapon

### Weapon Control

```lua
da_weapon.equip(weaponHash, [attachmentPoint])
```
- `weaponHash` (hash): Hash of the weapon to equip
- `attachmentPoint` (number, optional): Attachment point to use (default: 0)

```lua
da_weapon.holster()
```
Holsters the currently equipped weapon (sets to unarmed).

```lua
da_weapon.toggle(weaponHash)
```
- `weaponHash` (hash): Hash of the weapon to toggle
- Equips the weapon if not currently equipped, or holsters it if already equipped

```lua
da_weapon.attach(weaponHash, [attachmentPoint])
```
- `weaponHash` (hash): Hash of the weapon to attach
- `attachmentPoint` (number, optional): Attachment point to use

## Examples

### Basic Weapon Management

```lua
-- Check the current weapon
local currentWeapon = da_weapon.current()
print("Currently equipped weapon: " .. currentWeapon)

-- Equip a specific weapon
local revolverHash = GetHashKey("WEAPON_REVOLVER_CATTLEMAN")
da_weapon.equip(revolverHash)

-- Holster the weapon
da_weapon.holster()
```

### Weapon Toggling

```lua
-- Create a command to toggle the revolver
RegisterCommand('togglerevolver', function()
    local revolverHash = GetHashKey("WEAPON_REVOLVER_CATTLEMAN")
    da_weapon.toggle(revolverHash)
end, false)

-- Create a command to toggle the rifle
RegisterCommand('togglerifle', function()
    local rifleHash = GetHashKey("WEAPON_RIFLE_BOLTACTION")
    da_weapon.toggle(rifleHash)
end, false)
```

### Weapon Switching System

```lua
-- Set up a list of weapons for the player
local playerWeapons = {
    GetHashKey("WEAPON_REVOLVER_CATTLEMAN"),
    GetHashKey("WEAPON_RIFLE_BOLTACTION"),
    GetHashKey("WEAPON_MELEE_KNIFE")
}

-- Create a command to cycle through weapons
local currentWeaponIndex = 1

RegisterCommand('nextweapon', function()
    -- Increment the index (cycle back to 1 if we reach the end)
    currentWeaponIndex = currentWeaponIndex + 1
    if currentWeaponIndex > #playerWeapons then
        currentWeaponIndex = 1
    end
    
    -- Equip the next weapon
    da_weapon.equip(playerWeapons[currentWeaponIndex])
end, false)

RegisterCommand('prevweapon', function()
    -- Decrement the index (cycle to the end if we reach 1)
    currentWeaponIndex = currentWeaponIndex - 1
    if currentWeaponIndex < 1 then
        currentWeaponIndex = #playerWeapons
    end
    
    -- Equip the previous weapon
    da_weapon.equip(playerWeapons[currentWeaponIndex])
end, false)
```

### Working with Multiple Attachment Points

```lua
-- Equip different weapons to different attachment points
function equipDualWield()
    local revolverHash = GetHashKey("WEAPON_REVOLVER_CATTLEMAN")
    local secondaryRevolverHash = GetHashKey("WEAPON_REVOLVER_SCHOFIELD")
    
    -- Equip main hand (attachment point 0)
    da_weapon.equip(revolverHash, 0)
    
    -- Equip offhand (attachment point 1) - Note: This feature depends on game support
    da_weapon.attach(secondaryRevolverHash, 1)
end

-- Check currently equipped weapons at different attachment points
function checkEquippedWeapons()
    local mainWeapon = da_weapon.current(0)
    local offhandWeapon = da_weapon.current(1)
    
    print("Main hand: " .. mainWeapon)
    print("Offhand: " .. offhandWeapon)
}
```

### Weapon Control in Animations

```lua
-- Holster weapon before playing an animation
function playDrinkingAnimation()
    -- Store current weapon to restore later
    local previousWeapon = da_weapon.current()
    
    -- Holster weapon
    da_weapon.holster()
    
    -- Play animation
    -- (animation code here)
    
    -- Wait for animation to complete
    Citizen.Wait(5000)
    
    -- Re-equip previous weapon if it wasn't unarmed
    if previousWeapon ~= GetHashKey("WEAPON_UNARMED") then
        da_weapon.equip(previousWeapon)
    end
}
```

## Implementation Notes

- The equip function ensures the weapon is properly holstered before equipping a new one
- There is a built-in timeout to prevent hanging if a weapon fails to equip
- Weapon changes include proper waiting to ensure animations complete
- The system uses RedM's native weapon hashing system
- Attachment point 0 is the primary weapon slot
- The attach function is currently a stub that only logs the request
- Weapon toggling is handled by checking the currently equipped weapon
- Holstering sets the current weapon to `WEAPON_UNARMED`
- The equip function waits for the weapon change to complete before returning