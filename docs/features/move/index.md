# Movement System

The Movement module provides utilities for controlling entity movement and orientation in RedM. It offers functions to make entities face specific directions or move to designated coordinates.

## Features

- Face entities toward specific coordinates
- Move entities to specific coordinates with configurable parameters
- Optional forced positioning for precise placement
- Configurable movement speed and slide distance
- Built-in waiting functionality for task completion

## API Reference

### Entity Facing

```lua
da_move.face(ped, coords, timeout)
```
- `ped` (number): Entity handle to control
- `coords` (vector3): Coordinates to face toward
- `timeout` (number): Maximum time in milliseconds to complete the facing task

### Entity Movement

```lua
da_move.to(ped, coords, timeout, forceCoords, speed, slideDistance)
```
- `ped` (number): Entity handle to move
- `coords` (vector4/table): Target position (x, y, z) and heading (w)
- `timeout` (number): Maximum time in milliseconds to complete the movement
- `forceCoords` (boolean): Whether to force-set entity position after movement
- `speed` (number, optional): Movement speed multiplier (default: 1.0)
- `slideDistance` (number, optional): Sliding distance at the end of movement (default: 0.3)

## Examples

### Basic Entity Facing

```lua
-- Make the player face a specific point
local playerPed = PlayerPedId()
local targetCoords = vector3(1234.5, 678.9, 45.6)

-- Face the target with a 2 second timeout
da_move.face(playerPed, targetCoords, 2000)

-- Now the player is facing the target coordinates
print("Player is now facing the target")
```

### Moving Entities to Coordinates

```lua
-- Move the player to specified coordinates
local playerPed = PlayerPedId()
local destination = vector4(1234.5, 678.9, 45.6, 90.0) -- x, y, z, heading

-- Move to the destination with a 5 second timeout
da_move.to(playerPed, destination, 5000, false, 1.5, 0.5)

-- Player has now moved to the destination
print("Player has arrived at the destination")
```

### Forced Positioning

```lua
-- Teleport the player to exact coordinates after movement animation
local playerPed = PlayerPedId()
local doorwayPosition = vector4(1234.5, 678.9, 45.6, 180.0)

-- Move to the doorway with forced final positioning
da_move.to(playerPed, doorwayPosition, 3000, true)

-- Player is now exactly at the specified position and heading
print("Player is now perfectly positioned in the doorway")
```

### Custom Movement Speed

```lua
-- Make the player run quickly to a position
local playerPed = PlayerPedId()
local targetPosition = vector4(1234.5, 678.9, 45.6, 0.0)

-- Use a higher speed value (2.0) for faster movement
da_move.to(playerPed, targetPosition, 4000, false, 2.0)

-- Player has arrived quickly
print("Player ran to the destination")
```

### Movement in a Sequence

```lua
-- Create a sequence of movements to follow a path
function followPath(points)
    local playerPed = PlayerPedId()

    for i, point in ipairs(points) do
        -- For each point, first face it
        da_move.face(playerPed, point, 1000)

        -- Then move to it
        da_move.to(playerPed, point, 3000, false, 1.0)

        -- Wait a moment at each point
        Citizen.Wait(500)
    end

    print("Path following complete")
end

-- Example usage with a path of points
local path = {
    vector4(1230.0, 670.0, 45.0, 0.0),
    vector4(1235.0, 675.0, 45.0, 90.0),
    vector4(1240.0, 675.0, 45.0, 180.0),
    vector4(1235.0, 680.0, 45.0, 270.0)
}

followPath(path)
```

## Implementation Notes

- The movement functions use native RedM tasks (TaskGoStraightToCoord, TaskTurnPedToFaceCoord)
- Both functions wait for the specified timeout period before returning
- The `forceCoords` parameter in `move.to` ensures exact positioning, useful for doorways or tight spaces
- Vector4 coordinates are used to include heading information (w component)
- Movement speed affects how quickly the entity moves (higher values = faster movement)
- Slide distance controls how far the entity will slide at the end of movement
- These functions are blocking due to the Wait call, so they should be used within threads if you need parallel execution
