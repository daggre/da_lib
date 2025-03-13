# Control System

The Control module provides utilities for handling player input and controls in RedM. It offers sophisticated input state tracking, long press detection, passthrough controls, and waiting for key releases.

## Features

- Input state tracking for multiple controls (pressed, just pressed, released, just released)
- Long press detection with configurable durations
- Short press tracking with callbacks
- Control passthrough mode for special input scenarios
- Wait for key release functionality

## API Reference

### Main Control Module (da_control)

#### Input State Checking

```lua
local stateMap = da_control.isPressed(controls)
```
- `controls` (table): Array of control keys to check
- **Returns** (table): Map of control keys to their pressed state (boolean)

```lua
local stateMap = da_control.isJustPressed(controls)
```
- `controls` (table): Array of control keys to check
- **Returns** (table): Map of control keys to their just pressed state (boolean)

```lua
local stateMap = da_control.isReleased(controls)
```
- `controls` (table): Array of control keys to check
- **Returns** (table): Map of control keys to their released state (boolean)

```lua
local stateMap = da_control.isJustReleased(controls)
```
- `controls` (table): Array of control keys to check
- **Returns** (table): Map of control keys to their just released state (boolean)

#### Long Press Detection

```lua
local isLong = da_control.isLongPressed(key, [ms])
```
- `key` (string): The control key to check for long press
- `ms` (number, optional): Duration in milliseconds to consider a long press (default: 300ms)
- **Returns** (boolean): Whether the key has been pressed for longer than the specified duration

#### Short Press Tracking

```lua
da_control.trackShortPress(key, releaseCallback, [ms])
```
- `key` (string): The control key to track for short press
- `releaseCallback` (function): Function to call if key is released before the timeout
- `ms` (number, optional): Duration in milliseconds for timeout (default: 300ms)

#### Wait For Key Release

```lua
local released = da_control.waitForRelease(keys, [timeout])
```
- `keys` (number/table): Single key or array of keys to wait for release
- `timeout` (number, optional): Maximum time to wait in milliseconds (default: 10000)
- **Returns** (boolean): Whether all keys were released before timeout

### Control Passthrough Module (da_controlpass)

```lua
da_controlpass:start(haltKey, [callback])
```
- `haltKey` (number): Key that will stop the passthrough when released
- `callback` (function, optional): Function to call when passthrough stops

```lua
da_controlpass:stop()
```
Stops the active passthrough mode.

```lua
da_controlpass:toggle(haltKey, [callback])
```
- `haltKey` (number): Key that will stop the passthrough when released
- `callback` (function, optional): Function to call when passthrough stops
- Toggles the passthrough mode on/off

```lua
local active = da_controlpass:isActive()
```
- **Returns** (boolean): Whether passthrough mode is currently active

```lua
da_controlpass:set(active, haltKey, [callback])
```
- `active` (boolean): Whether to activate (true) or deactivate (false) passthrough
- `haltKey` (number): Key that will stop the passthrough when released
- `callback` (function, optional): Function to call when passthrough stops

## Examples

### Basic Control Checking

```lua
-- Check if player is pressing the interact key and run key
Citizen.CreateThread(function()
    while true do
        local keys = {"INPUT_INTERACT_ANIMAL", "INPUT_SPRINT"}
        local pressed = da_control.isPressed(keys)
        local justPressed = da_control.isJustPressed(keys)

        if justPressed["INPUT_INTERACT_ANIMAL"] then
            -- Player just pressed the interact key
            TriggerEvent('myResource:interact')
        end

        if pressed["INPUT_SPRINT"] then
            -- Player is holding the sprint key
            -- Do something continuously while sprint is held
        end

        Citizen.Wait(0)
    end
end)
```

### Long Press Detection

```lua
-- Detect long press for a different action
Citizen.CreateThread(function()
    while true do
        -- Check if E key is long-pressed (500ms)
        if da_control.isLongPressed("INPUT_INTERACT_ANIMAL", 500) then
            -- Perform long-press action
            TriggerEvent('myResource:longInteract')
        end

        Citizen.Wait(0)
    end
end)
```

### Short Press Tracking

```lua
-- Track short press for inventory key with callback
function openInventory()
    print("Opening inventory")
    -- Inventory opening logic
end

-- When inventory key is pressed
da_control.trackShortPress("INPUT_OPEN_SATCHEL_MENU", openInventory, 300)
```

### Waiting For Key Release

```lua
-- Function that waits for player to release a key before continuing
function performActionAfterKeyRelease()
    print("Please release the key to continue...")

    if da_control.waitForRelease("INPUT_ATTACK", 5000) then
        print("Key released, continuing...")
        -- Action continues here
    else
        print("Timed out waiting for key release")
    end
end
```

### Using Passthrough Mode

```lua
-- Start a control passthrough for a special interaction
function beginSpecialMode()
    -- Start passthrough that will end when INPUT_FRONTEND_CANCEL is released
    da_controlpass:start("INPUT_FRONTEND_CANCEL", function()
        print("Special mode ended")
    end)

    print("Special mode active - press ESC to exit")
end

-- Example of toggling passthrough mode
function toggleFreeCamera()
    da_controlpass:toggle("INPUT_FRONTEND_CANCEL", function()
        print("Camera mode toggled off")
    end)

    if da_controlpass:isActive() then
        print("Free camera mode activated")
        -- Camera activation logic
    end
end
```

## Implementation Notes

- The control system uses RedM's native control functions in the background
- Control keys should be specified using the RedM control key names from data files
- The long press system tracks press start times internally
- The short press system creates separate threads for tracking
- Control passthrough uses a separate thread that continues until explicitly stopped
- Wait for release will show on-screen text prompting the user to release keys
- Default long press duration is 300ms but can be customized
- The control passthrough system is exposed as `da_controlpass` globally
