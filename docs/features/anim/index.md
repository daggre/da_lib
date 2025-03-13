# Animation System

The Animation module provides a comprehensive interface for working with animations in RedM. It offers fine-grained control over entity animations with multiple animation methods for different use cases.

## Features

- Multiple animation methods (standard, object, advanced)
- Animation control and state management
- Animation timing and speed control
- Animation dictionary management
- Task clearing and animation stopping

## API Reference

### Entity Animation Methods

```lua
anim.ped(entity, dict, name, [blendIn], [blendOut], [duration], [flags], [rate], [ikFlags], [taskFilter])
```
- `entity` (number): Entity handle to animate
- `dict` (string): Animation dictionary
- `name` (string): Animation name
- `blendIn` (number, optional): Blend in duration (default: 3.0)
- `blendOut` (number, optional): Blend out duration (default: 0.5)
- `duration` (number, optional): Animation duration (-1 for full animation, default: -1)
- `flags` (number, optional): Animation flags (default: 0)
- `rate` (number, optional): Animation speed (default: 0)
- `ikFlags` (number, optional): IK flags (default: 0)
- `taskFilter` (boolean, optional): Task filter flag (default: false)

```lua
anim.object(entity, dict, name, [loop], [stayInAnim], [delta], [bitset])
```
- `entity` (number): Object entity handle
- `dict` (string): Animation dictionary
- `name` (string): Animation name
- `loop` (number, optional): Loop flag (default: 0)
- `stayInAnim` (number, optional): Stay in animation flag (default: 0)
- `delta` (number, optional): Animation delta (default: 0.0)
- `bitset` (number, optional): Bitset flags (default: 0)

```lua
anim.adv(entity, dict, name, [x], [y], [z], [yaw], [speed], [speedMult], [duration], [flags], [time])
```
- `entity` (number): Entity handle to animate
- `dict` (string): Animation dictionary
- `name` (string): Animation name
- `x`, `y`, `z` (number, optional): Position coordinates
- `yaw` (number, optional): Yaw rotation (default: 0.0)
- `speed` (number, optional): Animation speed (default: 1.0)
- `speedMult` (number, optional): Speed multiplier (default: 1.0)
- `duration` (number, optional): Animation duration (default: -1)
- `flags` (number, optional): Animation flags (default: 0)
- `time` (number, optional): Start time offset (default: 0.0)

### Animation Control

```lua
anim.stop(ped)
```
- `ped` (number): Entity handle to stop animations on

```lua
local state = anim.get(entity, [dict], [name])
```
- `entity` (number): Entity handle to check
- `dict` (string, optional): Animation dictionary
- `name` (string, optional): Animation name
- **Returns**:
  - With `dict` and `name`: Animation progress (0-1) or 0 if finished
  - Without parameters: Whether any animation is playing (boolean)

```lua
anim.set(entity, dict, name, [time], [speedMulti])
```
- `entity` (number): Entity handle to control
- `dict` (string): Animation dictionary
- `name` (string): Animation name
- `time` (number, optional): Time to set the animation to (-1 to stop)
- `speedMulti` (number, optional): Speed multiplier to set

## Examples

### Basic Ped Animation

```lua
-- Play a drinking animation on the player
local playerPed = PlayerPedId()
anim.ped(playerPed, "amb_rest_drunk", "a_player_drinking", 3.0, 3.0, -1, 1, 1.0)

-- Stop the animation after 5 seconds
Citizen.SetTimeout(5000, function()
    anim.stop(playerPed)
end)
```

### Object Animation

```lua
-- Animate a door object
local doorObject = GetClosestObjectOfType(coords.x, coords.y, coords.z, 2.0, GetHashKey("p_door_val_jail_cell01x"), false, false, false)
if doorObject ~= 0 then
    -- Open the door
    anim.object(doorObject, "script_common@jail_cell@open_cell_door", "action", 0, 1)
end
```

### Advanced Animation with Positioning

```lua
-- Play an animation that moves the player to a specific position
local playerPed = PlayerPedId()
local targetCoords = GetEntityCoords(targetEntity)
anim.adv(playerPed, "amb_misc@world_human_pray_dustoff@male_a@idle_a", "idle_a",
    targetCoords.x, targetCoords.y, targetCoords.z, 0.0, 1.0, 1.0, 5000, 0, 0.0)
```

### Animation State Management

```lua
-- Check if an entity is playing a specific animation
local entity = PlayerPedId()
local isPlaying = anim.get(entity, "amb_misc@world_human_smoke@male_a@idle_a", "idle_a")
if isPlaying > 0 then
    print("Animation is playing, progress: " .. isPlaying)
end

-- Check if entity is playing any animation
if anim.get(entity) then
    print("Entity is playing some animation")
end

-- Control animation speed
anim.set(entity, "amb_misc@world_human_smoke@male_a@idle_a", "idle_a", nil, 0.5) -- Half speed
```

### Animation in Game Logic

```lua
-- Only allow interaction when not in animation
RegisterCommand('interact', function()
    local playerPed = PlayerPedId()
    if not anim.get(playerPed) then
        -- Not in animation, allow interaction
        anim.ped(playerPed, "script_common@chores@common@lean_broom", "lean_broom_enter", 3.0, 3.0, -1, 1, 1.0)
    else
        -- Already animating, can't interact
        print("You're already busy with something")
    end
end)
```

## Implementation Notes

- Animation dictionaries are automatically loaded and unloaded
- Dictionary loading has a timeout of 200ms by default
- Animation flags modify behavior (looping, upper body only, etc.)
- The `stop` function uses ClearPedTasks which will interrupt all animations
- All animation parameters are sanitized with defaults to prevent nil errors
- Animation performance is logged at spam level for debugging
