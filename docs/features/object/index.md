# Object System

The Object module provides a comprehensive interface for creating, managing, and manipulating in-game objects and vehicles in RedM.

## Features

- Model loading and management
- Object and vehicle creation and deletion
- Position, rotation and quaternion control
- Attachment functionality
- Detailed object property configuration
- Vehicle-specific settings

## API Reference

### Model Loading

```lua
local success = object.load(hash)
```
- `hash` (string/hash): The model hash to load
- **Returns** (boolean): Whether the model was loaded successfully

### Object Creation and Management

```lua
local objectId = object.create(hash, coords, [options])
```
- `hash` (string/hash): The object model hash to create
- `coords` (vector3/vector4): The position to place the object
- `options` (table, optional): Additional creation options (see Options table below)
- **Returns** (number): The handle of the created object

```lua
object.delete(objectId)
```
- `objectId` (number): The handle of the object to delete

```lua
local vehicleId = object.createVehicle(hash, pos, [options])
```
- `hash` (string/hash): The vehicle model hash to create
- `pos` (vector3/vector4): The position to place the vehicle (w component can be used for heading)
- `options` (table, optional): Additional creation options (see Options table below)
- **Returns** (number): The handle of the created vehicle

### Object Attachment

```lua
object.attach(objectId, targetId, boneIndex, position, rotation, [options])
```
- `objectId` (number): The object handle to attach
- `targetId` (number): The target entity handle to attach to
- `boneIndex` (number): The bone index to attach to
- `position` (vector3): The offset position from the bone
- `rotation` (vector3): The rotation offset from the bone
- `options` (table, optional): Additional options for the attached object

```lua
object.detach(objectId)
```
- `objectId` (number): The handle of the attached object to detach

### Object Expression

```lua
object.expression(objectId, expression, value, [type])
```
- `objectId` (number): The object handle
- `expression` (string/hash): The expression hash to set
- `value` (number): The expression value
- `type` (number, optional): The expression type (defaults to 0)

### Object Property Configuration

```lua
object.set(objectId, options)
```
- `objectId` (number): The object handle
- `options` (table): Configuration options (see Options table below)

## Options Table Reference

The options table can include the following properties:

| Property | Type | Description |
|----------|------|-------------|
| `quaternion` | vector4 | Sets entity quaternion (x, y, z, w) |
| `rotation` | vector3 | Sets entity rotation (x, y, z) |
| `rotation_order` | number | Rotation order for SetEntityRotation (defaults to 0) |
| `heading` | number | Sets entity heading |
| `ground` | boolean | Places object properly on ground |
| `collision` | boolean | Enables/disables entity collision |
| `collisionKeepPhysics` | boolean | When disabling collision, keeps physics (defaults to true) |
| `visible` | boolean | Sets entity visibility |
| `frozen` | boolean | Freezes entity position |
| `settleFreeze` | number | Milliseconds delay before freezing entity |
| `texture` | number | Sets entity texture variation |
| `lod` | number | Sets level of detail distance |
| `fadeIn` | boolean | Fades in the entity |
| `alpha` | number | Sets entity alpha/transparency |
| `network` | boolean | Creates networked entity (in create functions) |
| `netMissionEntity` | boolean | Sets as mission entity (in create functions) |
| `doorFlag` | boolean | Door flag for CreateObjectNoOffset (defaults to true) |

### Vehicle-Specific Options

| Property | Type | Description |
|----------|------|-------------|
| `preventDraftAnimals` | boolean | Prevents draft animals for vehicles (defaults to true) |
| `scriptHostVeh` | boolean | Creates vehicle as script host (defaults to false) |
| `vehicle.tint` | number | Sets vehicle tint |
| `vehicle.livery` | number | Sets vehicle livery |
| `vehicle.lanterns` | number | Sets vehicle light prop sets |
| `vehicle.propset` | number | Sets vehicle prop set (wagon contents) |
| `vehicle.extra` | number | Enables specific vehicle extra (1-16) |

## Examples

### Creating Basic Objects

```lua
-- Load a model and create an object
local modelHash = joaat("p_campfire02x")
if object.load(modelHash) then
    local coords = vector3(100.0, 200.0, 50.0)
    local campfire = object.create(modelHash, coords)
    
    -- Delete after 30 seconds
    Citizen.SetTimeout(30000, function()
        object.delete(campfire)
    end)
end
```

### Using Advanced Object Options

```lua
-- Create a chest with specific options
local chestOptions = {
    rotation = vector3(0, 0, 45.0),
    frozen = true,
    collision = true,
    visible = true,
    ground = true,
    fadeIn = true
}

local chest = object.create(joaat("p_chest01x"), GetEntityCoords(PlayerPedId()), chestOptions)
```

### Creating and Configuring Vehicles

```lua
-- Create a wagon with specific settings
local wagonPos = vector4(100.0, 200.0, 50.0, 90.0) -- x, y, z, heading
local wagonOptions = {
    frozen = false,
    network = true,
    vehicle = {
        tint = 2,
        livery = 1,
        lanterns = 1,
        propset = joaat("pg_veh_wagontraveller01x_loot01x")
    }
}

local wagon = object.createVehicle(joaat("wagon01x"), wagonPos, wagonOptions)
```

### Attaching Objects

```lua
-- Create and attach a lantern to the player's hand
local lantern = object.create(joaat("p_lantern09x"), vector3(0,0,0), {visible = true})
local player = PlayerPedId()
local boneIndex = GetEntityBoneIndexByName(player, "SKEL_R_Hand")
local position = vector3(0.0, 0.0, 0.0)
local rotation = vector3(0.0, 0.0, 0.0)

object.attach(lantern, player, boneIndex, position, rotation, {
    collision = false,
    frozen = false
})

-- Detach after 10 seconds
Citizen.SetTimeout(10000, function()
    object.detach(lantern)
    object.delete(lantern)
end)
```

### Using Quaternion Rotation

```lua
-- Create an object with quaternion rotation
local objectOptions = {
    quaternion = vector4(0.0, 0.0, 0.0, 1.0), -- x, y, z, w
    frozen = true
}

local statue = object.create(joaat("p_statue01x"), GetEntityCoords(PlayerPedId()), objectOptions)
```

## Implementation Notes

- Objects persist until explicitly deleted or the resource stops
- Always check if the model loaded successfully before creating objects
- The module automatically unloads models after creation to free memory
- Objects are resource-intensive; manage them efficiently
- Vehicle extras are numbered 1-16; setting an extra enables it specifically and disables all others
- When using quaternions, the w component is negated internally during SetEntityQuaternion