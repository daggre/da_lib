# Utility System

The Utility module provides a collection of helper functions for common geometric calculations, coordinate transformations, and entity queries in RedM. These utilities simplify common operations like finding entities near a point, calculating boundary centers, and working with polar coordinates.

## Features

- Boundary center and dimension calculations
- Polar to Cartesian coordinate conversion
- Entity-relative position calculations
- Proximity entity queries with filtering
- Specialized queries for peds and vehicles

## API Reference

### Geometric Calculations

```lua
local center, xWidth, yWidth = da_util.CalcBoundaryCenter(boundary)
```
- `boundary` (table): Array of vector2/vector3 coordinates defining a boundary
- **Returns**:
  - `center` (vector2): Center point of the boundary
  - `xWidth` (number): Width of the boundary on the x-axis
  - `yWidth` (number): Width of the boundary on the y-axis

```lua
local deltaX, deltaY = da_util.TranslateCartesian(radius, angle)
```
- `radius` (number): Distance from origin
- `angle` (number): Angle in degrees
- **Returns**:
  - `deltaX` (number): X-coordinate offset
  - `deltaY` (number): Y-coordinate offset

### Entity-Relative Calculations

```lua
local offsetData = da_util.GetOffsetFromEntity(entity, angle, distance, zOffset, rotation)
```
- `entity` (number): Entity handle to use as origin
- `angle` (number): Angle in degrees relative to entity heading
- `distance` (number): Distance from entity
- `zOffset` (number): Vertical offset
- `rotation` (vector3, optional): Rotation offset (default: vector3(0,0,0))
- **Returns** (table): Table containing:
  - `coords` (vector3): Calculated world position
  - `rotation` (vector3): Calculated world rotation

### Entity Queries

```lua
local entities = da_util.GetEntitiesNearPoint(coords, radius, filter)
```
- `coords` (vector3): Center point for the search
- `radius` (number): Search radius
- `filter` (function, optional): Function that takes an entity handle and returns boolean
- **Returns** (table): Array of entity handles that match the criteria

```lua
local peds = da_util.GetPedsNearPoint(coords, radius, filter)
```
- `coords` (vector3): Center point for the search
- `radius` (number): Search radius
- `filter` (function, optional): Function that takes a ped handle and returns boolean
- **Returns** (table): Array of ped handles that match the criteria

```lua
local vehicles = da_util.GetVehiclesNearPoint(coords, radius, filter)
```
- `coords` (vector3): Center point for the search
- `radius` (number): Search radius
- `filter` (function, optional): Function that takes a vehicle handle and returns boolean
- **Returns** (table): Array of vehicle handles that match the criteria

## Examples

### Calculating Boundary Centers

```lua
-- Calculate the center of a polygon
local polygonPoints = {
    vector2(100.0, 100.0),
    vector2(150.0, 100.0),
    vector2(150.0, 150.0),
    vector2(100.0, 150.0)
}

local center, width, height = da_util.CalcBoundaryCenter(polygonPoints)
print("Polygon center: " .. center.x .. ", " .. center.y)
print("Dimensions: " .. width .. " x " .. height)

-- Use this center point to place an object
local objectCoords = vector3(center.x, center.y, GetGroundZFor_3dCoord(center.x, center.y, 1000.0))
local object = CreateObject(GetHashKey("p_campfire02x"), objectCoords.x, objectCoords.y, objectCoords.z, true, false, false)
```

### Working with Polar Coordinates

```lua
-- Create a circle of objects around a central point
function CreateObjectCircle(centerCoords, modelHash, radius, numObjects)
    local objects = {}
    
    for i = 1, numObjects do
        local angle = (360 / numObjects) * i
        local x, y = da_util.TranslateCartesian(radius, angle)
        
        local objectCoords = vector3(
            centerCoords.x + x,
            centerCoords.y + y,
            centerCoords.z
        )
        
        local object = CreateObject(modelHash, objectCoords.x, objectCoords.y, objectCoords.z, true, false, false)
        table.insert(objects, object)
    end
    
    return objects
end

-- Example: Create 8 lanterns in a circle around the player
local playerPos = GetEntityCoords(PlayerPedId())
local lanternHash = GetHashKey("p_lantern09x")
CreateObjectCircle(playerPos, lanternHash, 3.0, 8)
```

### Positioning Relative to Entities

```lua
-- Place an object in front of the player
local playerPed = PlayerPedId()
local objectData = da_util.GetOffsetFromEntity(playerPed, 0.0, 2.0, 0.0)

local campfire = CreateObject(GetHashKey("p_campfire02x"), 
    objectData.coords.x, 
    objectData.coords.y, 
    objectData.coords.z, 
    true, false, false)

-- Position a camera behind the player looking forward
function CreateFollowCamera()
    local playerPed = PlayerPedId()
    local cameraData = da_util.GetOffsetFromEntity(playerPed, 180.0, 3.0, 1.0)
    
    local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamCoord(cam, cameraData.coords.x, cameraData.coords.y, cameraData.coords.z)
    
    -- Calculate rotation to look at player
    local playerCoords = GetEntityCoords(playerPed)
    PointCamAtCoord(cam, playerCoords.x, playerCoords.y, playerCoords.z + 0.5)
    
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 0, true, true)
    
    return cam
end
```

### Finding Nearby Entities

```lua
-- Find and highlight all NPCs within 10 meters
function HighlightNearbyNPCs()
    local playerCoords = GetEntityCoords(PlayerPedId())
    local nearbyPeds = da_util.GetPedsNearPoint(playerCoords, 10.0, function(ped)
        return ped ~= PlayerPedId() and not IsPedAPlayer(ped)
    end)
    
    print("Found " .. #nearbyPeds .. " NPCs nearby")
    
    -- Apply visual effect to each NPC
    for _, ped in ipairs(nearbyPeds) do
        Citizen.InvokeNative(0x897934E868EDDD6C, ped) -- ApplyPedDamagePack
    end
end

-- Find the closest vehicle
function GetClosestVehicle(maxDistance)
    maxDistance = maxDistance or 50.0
    local playerCoords = GetEntityCoords(PlayerPedId())
    local vehicles = da_util.GetVehiclesNearPoint(playerCoords, maxDistance)
    
    local closestDistance = maxDistance
    local closestVehicle = nil
    
    for _, vehicle in ipairs(vehicles) do
        local vehicleCoords = GetEntityCoords(vehicle)
        local distance = #(playerCoords - vehicleCoords)
        
        if distance < closestDistance then
            closestDistance = distance
            closestVehicle = vehicle
        end
    end
    
    return closestVehicle, closestDistance
end
```

### Complex Entity Filtering

```lua
-- Find all entities matching specific criteria
function FindInteractableObjects()
    local playerCoords = GetEntityCoords(PlayerPedId())
    
    return da_util.GetEntitiesNearPoint(playerCoords, 5.0, function(entity)
        -- Check if it's an object
        if not IsEntityAnObject(entity) then return false end
        
        -- Check if it has a specific model or property
        local model = GetEntityModel(entity)
        local isInteractable = false
        
        -- List of interactable object models
        local interactableModels = {
            GetHashKey("p_chest01x"),
            GetHashKey("p_strongbox01x"),
            GetHashKey("p_chair_crate02x")
        }
        
        for _, interactModel in ipairs(interactableModels) do
            if model == interactModel then
                isInteractable = true
                break
            end
        end
        
        return isInteractable
    end)
end
```

## Implementation Notes

- Boundary calculation requires at least two points to determine dimensions
- The `TranslateCartesian` function uses mathematical convention where 0° is North
- Entity offsets take the entity's heading into account, making them rotate with the entity
- Entity query functions use different native implementations:
  - `GetEntitiesNearPoint` and `GetPedsNearPoint` use a native function with an itemset
  - `GetVehiclesNearPoint` uses the game pool and manual distance calculation
- Filters allow for precise control over which entities are returned
- All coordinate calculations use RedM's coordinate system (X east/west, Y north/south, Z up/down)
- The utility module is exposed globally as `da_util`