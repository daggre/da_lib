# Temporary Cache

The Temporary Cache provides a simple key-value storage system for runtime data that doesn't need to persist between resource restarts. It's designed for storing temporary data in organized, named caches.

## Features

- **Structured Storage**: Organizes cached data into named collections
- **In-Memory Storage**: Fast access with no persistence
- **Simple API**: Easy to use with Add, Get, Update, Remove operations
- **Collision Detection**: Optional warning when overwriting existing values

## API Reference

> Note: Based on references in the codebase, the Temp Cache appears to be in development or deprecated. The API described below is based on the expected functionality. Check the implementation for the most up-to-date version.

### Adding Values

```lua
temp.Add(cacheId, key, value, warnOnCollision)
```

- `cacheId` (string): The identifier for the cache collection
- `key` (string): The key to store the value under
- `value` (any): The value to store
- `warnOnCollision` (boolean, optional): Whether to log a warning if the key already exists

### Checking if a Key Exists

```lua
local exists = temp.Hit(cacheId, key)
```

- `cacheId` (string): The identifier for the cache collection
- `key` (string): The key to check
- **Returns** (boolean): Whether the key exists in the specified cache

### Retrieving Values

```lua
local value = temp.Get(cacheId, key)
```

- `cacheId` (string): The identifier for the cache collection
- `key` (string): The key to retrieve
- **Returns** (any): The stored value, or nil if it doesn't exist

### Removing Values

```lua
local removedValue = temp.Remove(cacheId, key)
```

- `cacheId` (string): The identifier for the cache collection
- `key` (string): The key to remove
- **Returns** (any): The removed value, or nil if it didn't exist

### Updating Values

```lua
temp.Update(cacheId, key, newValue)
```

- `cacheId` (string): The identifier for the cache collection
- `key` (string): The key to update
- `newValue` (any): The new value to store

### Counting Items

```lua
local count = temp.Count(cacheId)
```

- `cacheId` (string): The identifier for the cache collection
- **Returns** (number): The number of items in the specified cache

## When to Use Temporary Cache

The Temporary Cache is ideal for:

- Storing runtime state that doesn't need persistence
- Managing collections of related data with a simple interface
- Sharing data between different parts of your resource
- Quick lookups for frequently accessed values

## Examples

### Basic Usage

```lua
-- Store player state in a temporary cache
temp.Add('players', playerId, {
    health = 100,
    position = vector3(0, 0, 0),
    lastActivity = GetGameTimer()
})

-- Later, retrieve the player state
if temp.Hit('players', playerId) then
    local playerData = temp.Get('players', playerId)
    -- Use playerData
end
```

### Managing Multiple Collections

```lua
-- Store different types of data in separate collections
temp.Add('vehicles', vehicleId, vehicleData)
temp.Add('items', itemId, itemData)
temp.Add('npcs', npcId, npcData)

-- Get counts for statistics
print('Active vehicles: ' .. temp.Count('vehicles'))
print('Active items: ' .. temp.Count('items'))
print('Active NPCs: ' .. temp.Count('npcs'))
```

### Updating Values

```lua
-- First add an initial value
temp.Add('playerStats', playerId, { kills = 0, deaths = 0 })

-- Later, update the value
local stats = temp.Get('playerStats', playerId)
stats.kills = stats.kills + 1
temp.Update('playerStats', playerId, stats)
```

### Cleanup

```lua
-- Remove data when no longer needed
function playerDisconnected(playerId)
    temp.Remove('players', playerId)
    temp.Remove('playerStats', playerId)
    -- Other cleanup
end
```