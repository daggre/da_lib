# FX System

The FX module provides a comprehensive interface for creating and managing particle effects in RedM. It supports various types of particle effects, including networked effects, looped effects, and effects attached to entities or world coordinates.

## Features

- Simple API for particle effect creation and management
- Support for entity attachment (with optional bone targeting)
- Looped and one-shot particle effects
- Networked particle effects for multiplayer visibility
- Automatic particle dictionary loading and management
- Multiple removal options (by handle, entity, or area)

## API Reference

### Creating Particle Effects

```lua
local handle = fx.new(ptfxDict, ptfxName, options)
```
- `ptfxDict` (string): Dictionary name that contains the particle effect
- `ptfxName` (string): Name of the specific particle effect
- `options` (table): Configuration options
  - `entity` (number, optional): Entity to attach the effect to
  - `bone` (string, optional): Bone name to attach to (requires entity)
  - `coords` (vector3, optional): World coordinates for the effect
  - `loop` (boolean, optional): Whether the effect should loop continuously
  - `networked` (boolean, optional): Whether the effect should be visible to other players
  - `xOff`, `yOff`, `zOff` (number, optional): Offset from attachment point
  - `xRot`, `yRot`, `zRot` (number, optional): Rotation of the effect
  - `scale` (number, optional): Size scale of the effect (default: 1.0)
  - `xAxis`, `yAxis`, `zAxis` (number, optional): Axis alignment values
- **Returns** (number/nil): Handle to the created particle effect, or nil if failed

### Removing Particle Effects

```lua
fx.remove(options)
```
- `options` (table): One of the following must be provided:
  - `handle` (number): The specific effect handle to remove
  - `entity` (number): Remove all effects from this entity
  - `coords` (vector3): Remove effects in range of these coordinates
  - `radius` (number, optional): Range for area removal (default: 1.0)

## Examples

### Basic Particle Effect at Coordinates

```lua
-- Create a smoke effect at specific coordinates
local coords = vector3(100.0, 200.0, 50.0)
local smokeHandle = fx.new("core", "ent_amb_smoke", {
    coords = coords,
    scale = 2.0,
    loop = true
})

-- Remove the effect after 10 seconds
Citizen.SetTimeout(10000, function()
    fx.remove({ handle = smokeHandle })
end)
```

### Attaching Effect to an Entity

```lua
-- Attach fire effect to a campfire object
local campfire = GetClosestObjectOfType(coords.x, coords.y, coords.z, 5.0,
    GetHashKey("p_campfire02x"), false, false, false)

if campfire ~= 0 then
    local fireEffect = fx.new("core", "fire_campfire", {
        entity = campfire,
        loop = true,
        zOff = 0.3, -- Offset above the campfire
        scale = 1.5
    })

    -- Store the handle for later removal
    campfireEffects[campfire] = fireEffect
end

-- Function to clean up effects
function removeCampfireEffects()
    for entity, handle in pairs(campfireEffects) do
        fx.remove({ handle = handle })
    end
    campfireEffects = {}
end
```

### Bone Attachment

```lua
-- Create smoke effect coming from character's mouth
local playerPed = PlayerPedId()
local smokeEffect = fx.new("core", "ent_amb_cigar_smoke", {
    entity = playerPed,
    bone = "SKEL_Head", -- Attach to head bone
    xOff = 0.0,
    yOff = 0.1,
    zOff = 0.0, -- Position near mouth
    scale = 0.5,
    loop = true
})

-- Later, clean up the effect
RegisterCommand('stopsmoking', function()
    if smokeEffect then
        fx.remove({ handle = smokeEffect })
        smokeEffect = nil
    end
end)
```

### Networked Effects

```lua
-- Create an explosion effect that all players can see
function createNetworkedExplosion(coords)
    fx.new("core", "exp_grd_dynamite", {
        coords = coords,
        scale = 2.0,
        networked = true -- Make visible to all players
    })

    -- No need to store handle since it's a one-time effect
end

-- Remove all effects in an area
function cleanupArea(coords, radius)
    fx.remove({
        coords = coords,
        radius = radius or 10.0
    })
end
```

### Multiple Effects for a Complex Scene

```lua
-- Create a complex scene with multiple effects
function createMagicScene(position)
    local effects = {}

    -- Center glow
    effects.glow = fx.new("core", "ent_amb_fbi_light", {
        coords = position,
        loop = true,
        scale = 3.0
    })

    -- Surrounding particles
    effects.particles = fx.new("core", "ent_amb_falling_leaves", {
        coords = position,
        loop = true,
        zOff = 2.0,
        scale = 5.0
    })

    -- Add a character with effect attached
    local ped = CreatePed(GetHashKey("A_M_M_SKPTOWNFOLK_01"), position.x, position.y, position.z, 0.0, true, false)
    effects.pedEffect = fx.new("core", "ent_amb_torch_fire", {
        entity = ped,
        bone = "SKEL_R_Hand",
        loop = true,
        scale = 1.0
    })

    return effects, ped
end

-- Remove all effects in a scene
function cleanupMagicScene(effects, ped)
    for _, handle in pairs(effects) do
        fx.remove({ handle = handle })
    end

    if DoesEntityExist(ped) then
        DeleteEntity(ped)
    end
end
```

## Implementation Notes

- Particle dictionaries are automatically loaded with a timeout mechanism (1000ms)
- Not all combinations of networked/looped/bone effects are supported
- Unsupported combinations will produce error messages in the log
- Particle effects may require specific dictionaries to be loaded
- Effects attached to entities will be automatically removed when the entity is deleted
- Performance impact increases with the number of active particle effects
- Network visibility requires the effect to be created with the networked option
- Dictionary and effect names vary by game version and can be found in game files
- Bone names must match exactly with the entity model's skeleton
