# PolyZone System

The PolyZone module provides a powerful system for creating and managing zones in RedM. These zones can be used for triggering events, restricting areas, or creating interactive regions in the game world.

## Features

- Create polygon-shaped zones with any number of points
- Circle zone support for simpler radius-based areas
- Zone entry and exit event triggering
- Performance optimized zone checking
- Debug visualization

## API Reference

### Creating Zones

```lua
local zone = polyzone.create(points, options)
```
- `points` (table): Array of vector2 points defining the polygon
- `options` (table): Configuration options
  - `name` (string): Name of the zone
  - `minZ` (number): Minimum Z coordinate (height)
  - `maxZ` (number): Maximum Z coordinate (height)
  - `debugPoly` (boolean): Whether to show debug visuals
- **Returns** (table): Zone object

```lua
local circle = polyzone.createCircle(center, radius, options)
```
- `center` (vector3): Center point of the circle
- `radius` (number): Radius of the circle
- `options` (table): Configuration options (same as create)
- **Returns** (table): Circle zone object

### Zone Management

```lua
polyzone.destroy(zone)
```
- `zone` (table): The zone to destroy

```lua
polyzone.onEnter(zone, callback)
```
- `zone` (table): The zone to monitor
- `callback` (function): Function to call when player enters the zone

```lua
polyzone.onExit(zone, callback)
```
- `zone` (table): The zone to monitor
- `callback` (function): Function to call when player exits the zone

### Zone State Checking

```lua
local isInZone = polyzone.isInZone(zone)
```
- `zone` (table): The zone to check
- **Returns** (boolean): Whether the player is currently in the zone

```lua
local isPointInZone = polyzone.isPointInZone(zone, point)
```
- `zone` (table): The zone to check
- `point` (vector3): The point to check
- **Returns** (boolean): Whether the point is in the zone

## Examples

### Creating a Simple Zone

```lua
-- Create a rectangular zone around the Valentine saloon
local valentineSaloon = polyzone.create({
    vector2(-313.32, 803.45),
    vector2(-313.32, 809.45),
    vector2(-303.32, 809.45),
    vector2(-303.32, 803.45)
}, {
    name = "valentine_saloon",
    minZ = 117.0,
    maxZ = 122.0,
    debugPoly = false
})

-- Add enter/exit handlers
polyzone.onEnter(valentineSaloon, function()
    print("Entered Valentine Saloon")
    -- Play saloon ambient music
    TriggerEvent('myResource:playSaloonMusic')
end)

polyzone.onExit(valentineSaloon, function()
    print("Exited Valentine Saloon")
    -- Stop saloon ambient music
    TriggerEvent('myResource:stopSaloonMusic')
end)
```

### Creating a Circle Zone

```lua
-- Create a camp zone with radius
local campLocation = vector3(-1350.0, 2435.0, 308.0)
local campZone = polyzone.createCircle(campLocation, 15.0, {
    name = "player_camp",
    debugPoly = false
})

-- Check if player is in camp
Citizen.CreateThread(function()
    while true do
        if polyzone.isInZone(campZone) then
            -- Player is in camp, enable camp features
            draw.text3D("Camp", campLocation.x, campLocation.y, campLocation.z)
        end
        Citizen.Wait(500)
    end
end)
```

### Advanced Zone with Dynamic Events

```lua
-- Create a danger zone
local dangerZone = polyzone.create(dangerPoints, {
    name = "danger_zone",
    minZ = 0.0,
    maxZ = 300.0,
    debugPoly = true
})

-- Variables to track state
local inDangerZone = false
local dangerLevel = 0

-- Monitor zone entry/exit
polyzone.onEnter(dangerZone, function()
    inDangerZone = true
    TriggerEvent('myResource:enterDangerZone')
    
    -- Start danger monitoring
    Citizen.CreateThread(function()
        while inDangerZone do
            dangerLevel = dangerLevel + 1
            if dangerLevel > 10 then
                -- Trigger danger effect
                TriggerEvent('myResource:dangerEffect')
                dangerLevel = 0
            end
            Citizen.Wait(1000)
        end
    end)
end)

polyzone.onExit(dangerZone, function()
    inDangerZone = false
    dangerLevel = 0
    TriggerEvent('myResource:exitDangerZone')
end)
```

## Implementation Notes

- PolyZone uses the PolyZone library (required dependency)
- Zone checking is optimized for performance but can be resource-intensive with many zones
- Use appropriate Citizen.Wait values in threads that check zones
- Debug visualization is helpful during development but should be disabled in production
- Zones can be created, destroyed, and modified at runtime