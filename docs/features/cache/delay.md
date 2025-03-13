# Delay Cache

The Delay Cache provides a lightweight mechanism to control the frequency of function calls. Instead of caching function results like the Lazy Cache, the Delay Cache focuses on throttling how often a named action can occur.

## Features

- **Call Throttling**: Limits how frequently a named action can be executed
- **Boolean Return**: Returns true only when sufficient time has passed since the last call
- **Named Delays**: Create multiple independent delay checks by name
- **Zero Configuration**: No setup required, just call the function directly

## API Reference

### Checking a Delay

```lua
local canExecute = delay.actionName(timeInMs)
```

- `actionName` (string): A unique name for the action being throttled
- `timeInMs` (number, optional): Time in milliseconds that must pass between successful calls (default: 0)
- **Returns** (boolean):
  - `true` if the specified time has passed since the last call with this name
  - `false` if the action was called too recently

## Implementation Details

- Uses a table to track the last execution time for each named action
- Stores timestamps using `GetGameTimer()` for RedM/FiveM compatibility
- Uses Lua metatables to create dynamic function handlers for each action name
- Requires zero setup - just call the function with your desired action name

## When to Use Delay Cache

The Delay Cache is ideal for:

- Rate-limiting UI updates
- Preventing input spam
- Throttling network requests
- Any situation where you need to limit how often an action can occur

Unlike the Lazy Cache, the Delay Cache does not store any results - it only tracks timing information.

## Examples

### Basic Usage

```lua
-- Create a delay check that allows an action once per second
if delay.myAction(1000) then
    -- This code will only run if at least 1000ms have passed
    -- since the last successful call to delay.myAction()
    print("Action executed!")
else
    print("Too soon, action throttled")
end
```

### Input Throttling

```lua
RegisterCommand('some_command', function()
    -- Prevent command spam by allowing it only once every 500ms
    if not delay.commandThrottle(500) then
        -- Command was called too recently
        return
    end

    -- Command logic here
    print("Command executed")
end, false)
```

### Multiple Independent Delays

```lua
-- Different actions can have different delays
function checkInputs()
    -- Check for jump input (can occur every 1000ms)
    if IsControlJustPressed(0, 0x8FFC75D6) and delay.jumpAction(1000) then
        DoJumpAction()
    end

    -- Check for sprint input (can occur every 200ms)
    if IsControlPressed(0, 0x8FFC75D6) and delay.sprintAction(200) then
        DoSprintAction()
    end
end
```

### Comparison with Lazy Cache

```lua
-- Delay cache: doesn't store results, only controls execution frequency
if delay.checkInventory(1000) then
    -- This code runs at most once per second
    local inventory = GetPlayerInventory()
    -- Process inventory
end

-- Lazy cache: stores and returns the cached result
lazy.getInventory = function()
    return GetPlayerInventory()
end
-- This returns the cached inventory if called within 1000ms
local inventory = lazy(1000).getInventory()
```
