# Network System

The Network module provides utilities for client-server communication in RedM resources. It specializes in blocking event handling and simplified event registration, allowing for more structured communication between clients and the server.

## Features

- Blocking event communication with timeout support
- Simple event registration helpers
- Multiple event registration in a single call
- Reliable client-server and server-client RPC-style communication

## API Reference

### Global Network Functions

These functions are exposed globally and can be used without the da_net module:

```lua
-- Client-side
local result = TriggerBlockingServerEvent(eventName, timeoutMs, ...)
```
- `eventName` (string): Event name to trigger on the server
- `timeoutMs` (number): Timeout in milliseconds to wait for a response
- `...` (any): Any parameters to send to the server
- **Returns**: The values returned by the server handler, or nil if timed out

```lua
-- Client-side
RegisterBlockingClientEvent(eventName, handlerFunction)
```
- `eventName` (string): Event name to register a handler for
- `handlerFunction` (function): Function to call when event is received
  - Should return values to be sent back to the server

```lua
-- Server-side
local result = TriggerBlockingClientEvent(eventName, playerId, timeoutMs, ...)
```
- `eventName` (string): Event name to trigger on the client
- `playerId` (number): Server ID of the target player
- `timeoutMs` (number): Timeout in milliseconds to wait for a response
- `...` (any): Any parameters to send to the client
- **Returns**: The values returned by the client handler, or nil if timed out

```lua
-- Server-side
RegisterBlockingServerEvent(eventName, handlerFunction)
```
- `eventName` (string): Event name to register a handler for
- `handlerFunction` (function): Function to call when event is received
  - Receives source as first parameter
  - Should return values to be sent back to the client

### da_net Module

```lua
da_net.event(eventName, handlerFunction)
```
- `eventName` (string): Name of the event to listen for
- `handlerFunction` (function): Function to call when event is received

```lua
da_net.events(eventTable)
```
- `eventTable` (table): Map of event names to handler functions

## Examples

### Basic Blocking Events

**Client-side:**
```lua
-- Register a blocking client event handler
RegisterBlockingClientEvent("getPlayerData", function()
    -- Gather player data
    local playerPed = PlayerPedId()
    local health = GetEntityHealth(playerPed)
    local coords = GetEntityCoords(playerPed)

    -- Return the data to the server
    return health, coords
end)

-- Send a blocking request to the server
function requestItemData(itemId)
    -- Call server and wait for response with 2-second timeout
    local name, description, rarity = TriggerBlockingServerEvent("getItemData", 2000, itemId)

    if name then
        print("Item: " .. name .. " (" .. rarity .. ")")
        print("Description: " .. description)
    else
        print("Request timed out or item doesn't exist")
    end
end
```

**Server-side:**
```lua
-- Register a blocking server event handler
RegisterBlockingServerEvent("getItemData", function(source, itemId)
    -- Get the item data from the database
    local item = Database.GetItem(itemId)

    if item then
        -- Return the data to the client
        return item.name, item.description, item.rarity
    else
        -- Return nil values if item not found
        return nil, nil, nil
    end
end)

-- Send a blocking request to a specific client
function getPlayerStatus(playerId)
    -- Call client and wait for response with 3-second timeout
    local health, coords = TriggerBlockingClientEvent("getPlayerData", playerId, 3000)

    if health then
        print("Player " .. playerId .. " health: " .. health)
        print("Position: " .. vector3(coords.x, coords.y, coords.z))
        return true
    else
        print("Failed to get player data (timeout)")
        return false
    end
end
```

### Using da_net for Event Registration

```lua
-- Register a single event handler
da_net.event("playerJoined", function(playerId, playerName)
    print("Player joined: " .. playerName .. " (ID: " .. playerId .. ")")
end)

-- Register multiple event handlers at once
da_net.events({
    playerLeft = function(playerId, reason)
        print("Player " .. playerId .. " left: " .. reason)
    end,

    itemPickup = function(itemId, quantity)
        print("Picked up " .. quantity .. "x item " .. itemId)
    end,

    questCompleted = function(questId, rewards)
        print("Completed quest " .. questId)
        for rewardType, amount in pairs(rewards) do
            print(" - " .. rewardType .. ": " .. amount)
        end
    end
})
```

### Complex Blocking Communication Example

**Client-side:**
```lua
-- Function to start a trade with another player
function initiateTradeWithPlayer(targetPlayerId)
    -- Get local player inventory
    local myInventory = GetPlayerInventory()

    -- Request trade initiation with the other player
    local accepted, theirInventory = TriggerBlockingServerEvent(
        "tradeRequest",
        10000,  -- 10 second timeout for player to respond
        targetPlayerId,
        myInventory
    )

    if accepted then
        -- They accepted, show trade UI
        ShowTradeUI(myInventory, theirInventory)
        return true
    elseif accepted == false then
        -- They explicitly declined
        ShowNotification("Player declined your trade request")
        return false
    else
        -- Request timed out
        ShowNotification("Trade request timed out")
        return false
    end
end

-- Handle incoming trade requests
RegisterBlockingClientEvent("incomingTradeRequest", function(sourcePlayerId, theirInventory)
    -- Show trade request notification
    ShowTradeRequestUI(sourcePlayerId, theirInventory)

    -- Wait for player response (handled by UI)
    local timeout = GetGameTimer() + 10000
    while GetGameTimer() < timeout do
        if tradeAccepted then
            -- Player accepted, return their inventory
            return true, GetPlayerInventory()
        elseif tradeDeclined then
            -- Player declined
            return false, nil
        end
        Citizen.Wait(100)
    end

    -- Timed out without response
    return nil, nil
end)
```

**Server-side:**
```lua
-- Handle trade request
RegisterBlockingServerEvent("tradeRequest", function(source, targetPlayerId, sourceInventory)
    -- Validate the request
    if not IsPlayerOnline(targetPlayerId) then
        return false, nil
    end

    -- Forward the trade request to the target player
    local accepted, targetInventory = TriggerBlockingClientEvent(
        "incomingTradeRequest",
        targetPlayerId,
        15000, -- 15 second server timeout (longer than client timeout)
        source,
        sourceInventory
    )

    -- Return the result to the original requester
    return accepted, targetInventory
end)
```

## Implementation Notes

- Blocking events create a synchronous-like experience in an asynchronous environment
- All blocking events have timeouts to prevent hanging on no response
- The system uses unique IDs for each request to match responses correctly
- The implementation creates a thread per request to wait for the response
- Be careful with timeout values - they should match expectations for the operation
- Event registration is validated to prevent duplicates and type errors
- The server handler receives the source ID as the first parameter
- Network functions have security implications - always validate data on both ends
- The da_net module provides simple wrappers around standard event registration
- Global functions are available without requiring imports
