# Lock System

The Lock module provides a distributed locking mechanism for RedM resources. It allows different parts of the system to coordinate access to shared resources and prevent race conditions. Two lock types are available: standard exclusive locks and global state exclusive locks.

## Features

- Exclusive locking mechanism with timeout support
- Ownership tracking for locks
- Automatic timeout-based unlock
- Server-side centralized lock management
- Client-to-server blocking lock requests
- Global state synchronization option for specific locks

## API Reference

### Standard Exclusive Locks

```lua
local success = xlock(owner, id, [timeout])
```
- `owner` (string/number): Identifier for the lock requester
- `id` (string): Unique identifier for the lock
- `timeout` (number, optional): Duration in milliseconds before the lock automatically releases (default: 2500ms)
- **Returns** (boolean): Whether the lock was successfully acquired

```lua
local success = xunlock(owner, id)
```
- `owner` (string/number): Identifier for the lock owner
- `id` (string): Unique identifier for the lock to release
- **Returns** (boolean): Whether the lock was successfully released

### Global State Exclusive Locks

```lua
local success = gl_xlock(owner, id, [timeout])
```
- `owner` (string/number): Identifier for the lock requester
- `id` (string): Unique identifier for the lock
- `timeout` (number, optional): Duration in milliseconds before the lock automatically releases (default: 2500ms)
- **Returns** (boolean): Whether the lock was successfully acquired

```lua
local success = gl_xunlock(owner, id)
```
- `owner` (string/number): Identifier for the lock owner
- `id` (string): Unique identifier for the lock to release
- **Returns** (boolean): Whether the lock was successfully released

## Examples

### Basic Lock Usage

```lua
-- Client-side: Acquire a lock before accessing a resource
local resourceId = "bank_vault_1"
local playerId = GetPlayerServerId(PlayerId())

-- Try to acquire the lock
if xlock(playerId, resourceId, 5000) then
    -- Lock acquired, perform operations that require exclusive access
    print("Lock acquired for " .. resourceId)

    -- Simulating some work
    Citizen.Wait(3000)

    -- Release the lock when done
    if xunlock(playerId, resourceId) then
        print("Lock released for " .. resourceId)
    else
        print("Failed to release lock, may have timed out already")
    end
else
    print("Could not acquire lock, resource is busy")
end
```

### Global State Lock for Synchronized State

```lua
-- Server-side: Manage access to a global resource
RegisterNetEvent('startBankHeist')
AddEventHandler('startBankHeist', function(bankId)
    local src = source
    local resourceId = "bank_heist_" .. bankId

    if gl_xlock(src, resourceId, 10000) then
        -- Lock acquired, this player has exclusive access to start the heist
        print("Player " .. src .. " started bank heist at bank " .. bankId)

        -- Begin heist logic
        TriggerClientEvent('bankHeist:begin', -1, bankId, src)

        -- Lock will automatically time out after 10 seconds if not explicitly released
    else
        -- Another player already has a heist in progress
        TriggerClientEvent('notification', src, "This bank is already being robbed!")
    end
end)

-- When heist completes or fails
RegisterNetEvent('endBankHeist')
AddEventHandler('endBankHeist', function(bankId)
    local src = source
    local resourceId = "bank_heist_" .. bankId

    if gl_xunlock(src, resourceId) then
        print("Bank heist ended at bank " .. bankId)
    end
end)
```

### Handling Lock Timeouts

```lua
-- Function that performs a long operation with lock protection
function performLongOperation(resourceId)
    local myId = "server_script_1"
    local operationTimeout = 10000 -- 10 seconds

    if xlock(myId, resourceId, operationTimeout) then
        print("Starting long operation on " .. resourceId)

        -- Simulate work in stages
        for i = 1, 5 do
            -- Do some work
            Citizen.Wait(1500)
            print("Operation stage " .. i .. " complete")

            -- Check if we should continue (external condition)
            if shouldAbort then
                print("Operation aborted, releasing lock")
                xunlock(myId, resourceId)
                return false
            end
        end

        print("Operation completed successfully")
        return xunlock(myId, resourceId)
    else
        print("Could not acquire lock for operation")
        return false
    end
end
```

### Resource Coordination Between Players

```lua
-- Client-side: Coordinate access to a crafting station
local stationId = "crafting_station_" .. nearestStation
local playerId = GetPlayerServerId(PlayerId())

-- Try to acquire lock for the crafting station
function useCraftingStation()
    if gl_xlock(playerId, stationId, 30000) then
        -- Player has exclusive access to the crafting station
        print("You begin using the crafting station")

        -- Show crafting UI
        openCraftingMenu()

        -- Monitor if player walks away or cancels
        Citizen.CreateThread(function()
            while true do
                Citizen.Wait(500)

                -- Check if player walked away or pressed cancel
                if #(GetEntityCoords(PlayerPedId()) - stationCoords) > 2.0 or IsControlJustPressed(0, 0x26E9DC00) then
                    -- Player left the area or cancelled, release lock
                    gl_xunlock(playerId, stationId)
                    closeCraftingMenu()
                    return
                end
            end
        end)

        return true
    else
        -- Station is in use by another player
        print("This crafting station is already in use")
        return false
    end
end

-- When crafting is completed
function finishCrafting()
    closeCraftingMenu()
    gl_xunlock(playerId, stationId)
    print("You finish using the crafting station")
end
```

## Implementation Notes

- Locks are server-side and managed through blocking events for reliability
- Lock timeout is specified in milliseconds but converted to seconds internally
- Global state locks are synchronized through the FiveM GlobalState system
- If a player disconnects, their locks will remain until timeout
- The locking mechanism uses a simple owner + timeout approach
- A lock can be forcibly taken if it has expired (timeout reached)
- Lock functions use TriggerBlockingServerEvent with a 2 second timeout to prevent hanging clients
- Standard locks are only tracked on the server
- Global locks (gl_*) are tracked both on server and in the GlobalState for all clients
