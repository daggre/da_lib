# Epoch System

The Epoch module provides a simple, reliable way to get Unix timestamps (seconds since January 1, 1970) on the client-side by synchronizing with the server time. This ensures consistent timestamps across all clients regardless of local system clock settings.

## Features

- Client-server time synchronization
- Simple API for getting Unix timestamps
- Automatic offset calculation and compensation
- Reliable timing for events and operations
- Minimal overhead with cached time offset

## API Reference

### Basic Usage

```lua
local unixTimestamp = epoch()
```
- **Returns** (number): Current Unix timestamp (seconds since Jan 1, 1970)

## Examples

### Getting the Current Unix Timestamp

```lua
-- Get the current Unix timestamp
local currentTime = epoch()
print("Current Unix timestamp: " .. currentTime)

-- Use the timestamp for time-based operations
local startTime = epoch()
-- Do some operation...
local endTime = epoch()
local elapsedSeconds = endTime - startTime
print("Operation took " .. elapsedSeconds .. " seconds")
```

### Implementing Time-Based Features

```lua
-- Create a cooldown system using epochs
local lastActionTime = 0
local COOLDOWN_SECONDS = 60 -- 1 minute cooldown

function canPerformAction()
    local currentTime = epoch()
    if currentTime - lastActionTime >= COOLDOWN_SECONDS then
        lastActionTime = currentTime
        return true
    else
        local remainingCooldown = COOLDOWN_SECONDS - (currentTime - lastActionTime)
        print("Action on cooldown for " .. math.ceil(remainingCooldown) .. " more seconds")
        return false
    end
end

-- Usage example
RegisterCommand("special_action", function()
    if canPerformAction() then
        print("Special action performed!")
        -- Perform the action
    end
end)
```

### Time Formatting

```lua
-- Format epoch timestamp into readable date and time
-- (requires additional formatting utilities not included in the module)
function formatTimestamp(timestamp)
    -- You can use Lua's os.date on the server side
    -- Client-side implementation would need custom formatting
    -- or server-side callback

    -- Example server-side implementation:
    -- return os.date("%Y-%m-%d %H:%M:%S", timestamp)

    -- For client-side, you would need to add your own formatting logic
    -- or make a server call
    return timestamp
end

local current = epoch()
print("Current time: " .. formatTimestamp(current))
```

## Implementation Notes

- The first call to `epoch()` triggers a blocking server event to get the time
- Subsequent calls use a cached time offset for performance
- The time offset is calculated as: `serverTime - (gameTime in seconds)`
- The function uses `GetGameTimer()` for client-side time tracking
- Returns `0` if the server communication fails on initial synchronization
- For high precision timing, consider that time sync has network latency
- The timestamp uses seconds, not milliseconds (Unix standard)
- All operations in this module use UTC time to avoid time zone issues

## Technical Details

The module works by:

1. On first call, requesting the current Unix timestamp from the server using a blocking event
2. Calculating the offset between server time and local game time
3. Caching this offset for future calls
4. For subsequent calls, applying the offset to the current game time

This approach minimizes network traffic while maintaining accuracy. The time synchronization only happens once per client session.

## Dependencies

- Requires the Net module (`da_lib/lib/net_cl.lua`) for blocking server events
- Server-side controller (`epoch_srv_ctl.lua`) must be loaded for server time retrieval
