# NUI System

The NUI (Native UI) module provides a simplified interface for handling communication between Lua code and the web-based UI in RedM. It offers a cleaner API for registering callbacks, sending messages, and managing events between the game client and the NUI interface.

## Features

- Simplified callback registration with automatic response handling
- Event-based communication between client and UI
- Easy message sending with type classification
- Bulk registration of callbacks and events
- JSON encoding support for complex data structures

## API Reference

### Callbacks and Events

```lua
da_ui.callback(name, handlerFunction)
```
- `name` (string): Name of the callback to register
- `handlerFunction` (function): Function that processes data and returns a response
  - Receives data from the UI
  - Should return a value to be sent back to the UI

```lua
da_ui.event(name, handlerFunction)
```
- `name` (string): Name of the event to register
- `handlerFunction` (function): Function that processes data without returning a response
  - Receives data from the UI
  - No return value expected

### Message Sending

```lua
da_ui.send(type, data)
```
- `type` (string): Message type identifier
- `data` (table, optional): Data to send to the UI (default: empty table)

```lua
da_ui.encode(type, data)
```
- `type` (string): Message type identifier
- `data` (table, optional): Data to send to the UI after JSON encoding (default: empty table)

### Bulk Registration

```lua
da_ui.callbacks(callbackTable)
```
- `callbackTable` (table): Map of callback names to handler functions

```lua
da_ui.events(eventTable)
```
- `eventTable` (table): Map of event names to handler functions

## Examples

### Basic Callback Registration

```lua
-- Register a callback that processes inventory data
da_ui.callback("getInventory", function(data)
    -- data contains parameters from the UI
    local playerId = data.playerId or GetPlayerServerId(PlayerId())
    
    -- Fetch the inventory data
    local inventory = GetPlayerInventory(playerId)
    
    -- Return data to the UI
    return {
        items = inventory.items,
        money = inventory.money,
        weight = inventory.weight,
        maxWeight = inventory.maxWeight
    }
end)
```

### Event-Based Communication

```lua
-- Register an event for UI notifications
da_ui.event("closeInventory", function(data)
    -- No response needed, just process the event
    CloseInventoryMenu()
    SetNuiFocus(false, false)
    
    -- Optional: Perform additional actions based on data
    if data.saveChanges then
        SaveInventoryChanges()
    end
end)
```

### Sending Messages to UI

```lua
-- Send a simple message to update UI state
function updatePlayerHealth(health)
    da_ui.send("updateHealth", {
        currentHealth = health,
        maxHealth = 100
    })
end

-- Send a notification to the UI
function notifyPlayer(message, type)
    da_ui.send("showNotification", {
        message = message,
        type = type, -- "success", "error", "info"
        duration = 3000
    })
end
```

### Using JSON Encoding for Complex Data

```lua
-- Send complex nested data structure
function updateWorldMap(locations)
    da_ui.encode("updateMap", {
        playerPosition = GetEntityCoords(PlayerPedId()),
        locations = locations,
        settings = {
            zoom = 2.5,
            showLabels = true,
            filters = {
                showMissions = true,
                showStores = false,
                showPlayers = true
            }
        }
    })
end
```

### Bulk Registration

```lua
-- Register multiple callbacks at once
da_ui.callbacks({
    getPlayerData = function(data)
        return GetPlayerDataForUI()
    end,
    
    getVehicleInfo = function(data)
        local vehicle = GetVehicleFromId(data.vehicleId)
        return {
            model = GetVehicleModel(vehicle),
            health = GetVehicleHealth(vehicle),
            fuel = GetVehicleFuel(vehicle)
        }
    end,
    
    searchItems = function(data)
        return SearchInventoryItems(data.query)
    end
})

-- Register multiple events at once
da_ui.events({
    closeAllMenus = function(data)
        CloseAllActiveMenus()
    end,
    
    playAnimation = function(data)
        PlayAnimation(data.animName, data.duration)
    end,
    
    teleportToMarker = function(data)
        TeleportToMarker()
    end
})
```

## Integration with HTML/JS

Here's how to communicate with this system from the UI side (JavaScript):

```javascript
// For callbacks (expecting a response)
fetch('https://your_resource_name/getInventory', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ playerId: 123 })
})
.then(resp => resp.json())
.then(resp => {
    // Handle the response data here
    console.log('Got inventory:', resp);
    updateInventoryUI(resp);
});

// For events (no response needed)
fetch('https://your_resource_name/closeInventory', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ saveChanges: true })
});

// Listen for messages from Lua
window.addEventListener('message', (event) => {
    const data = event.data;
    
    switch (data.type) {
        case 'updateHealth':
            updateHealthBar(data.currentHealth, data.maxHealth);
            break;
            
        case 'showNotification':
            showNotification(data.message, data.type, data.duration);
            break;
            
        case 'updateMap':
            updateMapDisplay(data.playerPosition, data.locations, data.settings);
            break;
    }
});
```

## Implementation Notes

- The module automatically manages callback responses with empty objects where needed
- The `type` field is automatically added to all messages sent using this module
- Callback handlers should return a value, which will be sent back to the UI
- Event handlers should not return values as they are "fire and forget"
- For complex data structures, use `encode` which applies JSON encoding
- The module is exposed globally as `da_ui`
- This module simplifies the standard FiveM NUI API for easier usage