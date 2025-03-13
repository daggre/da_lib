# Key-Value Pair (KVP) Storage

The KVP system provides persistent storage for your RedM resources. This wrapper simplifies the native KVP functions with additional features like JSON encoding/decoding, external resource access, and convenient CLI commands.

## Features

- **JSON Serialization**: Automatically encode and decode complex Lua tables
- **Type-Specific Methods**: Dedicated functions for strings, integers, and floats
- **Cross-Resource Access**: Read KVP data from other resources
- **Search Capability**: Find all keys with a specific prefix
- **CLI Integration**: Manage KVP data through console commands

## API Reference

### Basic Operations

#### Setting Values (with JSON encoding)

```lua
kvp.encode(key, value)
```
- `key` (string): The storage key
- `value` (any): Any value that can be JSON-encoded

#### Getting Values (with JSON decoding)

```lua
local value = kvp.decode(key)
```
- `key` (string): The storage key
- **Returns** (any): The decoded value, or nil if not found

#### Reading from Other Resources

```lua
local value = kvp.rdecode(resource, key)
```
- `resource` (string): The resource name to read from
- `key` (string): The storage key
- **Returns** (any): The decoded value from the specified resource

#### Initialize with Default

```lua
local wasInitialized = kvp.init(key, defaultValue)
```
- `key` (string): The storage key
- `defaultValue` (any): Value to set if key doesn't exist
- **Returns** (boolean):
  - `true` if the key was initialized with the default value
  - `false` if the key already existed

#### Deleting Keys

```lua
kvp.delete(key)
```
- `key` (string): The storage key to delete

### Type-Specific Methods

#### Strings

```lua
kvp.set_string(key, value)
local value = kvp.get_string(key)
local value = kvp.rget_string(resource, key)  -- External resource
```

#### Integers

```lua
kvp.set_int(key, value)
local value = kvp.get_int(key)
local value = kvp.rget_int(resource, key)  -- External resource
```

#### Floats

```lua
kvp.set_float(key, value)
local value = kvp.get_float(key)
local value = kvp.rget_float(resource, key)  -- External resource
```

### Raw Operations (No JSON Encoding)

```lua
kvp.rawset(key, value)
local value = kvp.rawget(key)
local value = kvp.rrawget(resource, key)  -- External resource
```

### Searching and Utility

#### Search by Prefix

```lua
local keys = kvp.search(prefix)
```
- `prefix` (string): The key prefix to search for
- **Returns** (table): Sorted array of matching key names

#### Search in External Resource

```lua
local keys = kvp.rsearch(resource, prefix)
```
- `resource` (string): The resource name to search in
- `prefix` (string): The key prefix to search for
- **Returns** (table): Sorted array of matching key names

#### Force Flush to Disk

```lua
kvp.flush()
```
- Forces an immediate write of all KVP data to disk

## CLI Commands

The KVP system includes several console commands for management:

### Find Keys

```
/kvp find [resource] [prefix]
```
- Lists all keys in the specified resource that start with the given prefix

### Delete a Key

```
/kvp delete [resource] [key]
```
- Deletes the specified key from the resource's KVP storage

### Get a Value

```
/kvp get [resource] [key]
```
- Displays the raw value of the specified key

## Examples

### Storing Player Preferences

```lua
-- Save player preferences (automatically JSON encoded)
function savePlayerPreferences(playerId, preferences)
    kvp.encode('player:' .. playerId .. ':preferences', preferences)
end

-- Load player preferences with defaults
function loadPlayerPreferences(playerId)
    local prefs = kvp.decode('player:' .. playerId .. ':preferences')
    if not prefs then
        -- Set default preferences if none found
        prefs = {
            uiScale = 1.0,
            showHUD = true,
            audioVolume = 0.8
        }
        kvp.encode('player:' .. playerId .. ':preferences', prefs)
    end
    return prefs
end
```

### Using Type-Specific Storage

```lua
-- Store high score
kvp.set_int('highscores:player' .. playerId, score)

-- Store last login time
kvp.set_string('player:' .. playerId .. ':lastLogin', os.date())

-- Store location
local pos = GetEntityCoords(PlayerPedId())
kvp.set_float('player:' .. playerId .. ':lastX', pos.x)
kvp.set_float('player:' .. playerId .. ':lastY', pos.y)
kvp.set_float('player:' .. playerId .. ':lastZ', pos.z)
```

### Working with Multiple Resources

```lua
-- Check if the player has completed a quest in another resource
function hasCompletedQuest(questId)
    local questData = kvp.rdecode('my_quests_resource', 'player:' .. GetPlayerServerId(PlayerId()) .. ':quests')
    if questData and questData[questId] and questData[questId].completed then
        return true
    end
    return false
end
```

### Searching for Related Keys

```lua
-- Find all keys related to a specific player
function getAllPlayerData(playerId)
    local playerKeys = kvp.search('player:' .. playerId)
    local result = {}

    for _, key in ipairs(playerKeys) do
        result[key] = kvp.decode(key)
    end

    return result
end
```

## Best Practices

1. **Use Prefixes**: Organize keys with prefixes like `player:1234:setting`
2. **Handle Missing Values**: Always check if `decode()` returns nil
3. **Use Type-Specific Methods**: For simple values, use `set_int`, `set_float`, etc.
4. **Resource Name Conventions**: When accessing external resources, use their exact resource name
5. **Limit Storage Size**: KVP is meant for small data - don't store large objects

## Implementation Details

- KVP storage persists between server restarts
- All data is ultimately stored as strings in the underlying system
- JSON encoding/decoding happens automatically with `encode()` and `decode()`
- The `flush()` function can be used to ensure data is written to disk
