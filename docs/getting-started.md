# Getting Started with da_lib

This guide explains how to use da_lib features in your own RedM resource.

## How da_lib Features Work

da_lib does **not** use an exports-based API. Each feature is a standalone Lua file that, when loaded, creates global variables in your resource's Lua environment. You include the files you need directly in your resource's `fxmanifest.lua`.

da_lib must be started before any resource that depends on it. Add `ensure da_lib` to `server.cfg` before your resource.

## Installation

1. Place the `da_lib` folder in your server's resources directory (e.g., `resources/[da]/da_lib`)
2. Add to `server.cfg`:
   ```
   ensure da_log
   ensure da_lib
   ```
3. In your resource's `fxmanifest.lua`, include the specific feature files you need (see examples below)

## Feature Import Examples

Each feature file creates one or more globals when loaded. Import only what your resource needs.

### Logging (da_log)

```lua
-- fxmanifest.lua
shared_scripts {
    '@da_log/log_sh.lua',
}
```
Creates global: `log`
```lua
log.info("Player connected:", playerName)
log.debug("State:", { health = 100, pos = playerCoords })
log.error("Failed to load resource:", resourceName)
```

### Animation

```lua
-- fxmanifest.lua
client_scripts {
    '@da_lib/features/anim/anim_cl.lua',
}
```
Creates global: `da_anim`
```lua
-- Play animation on ped
da_anim.ped(PlayerPedId(), "ai@react@point@base", "point_fwd", 3.0, 0.5, -1, 0)
-- Stop all animations
da_anim.stop(PlayerPedId())
```

### Mode System

```lua
-- fxmanifest.lua
client_scripts {
    '@da_lib/features/mode/mode_cl.lua',
}
```
Creates global: `da_mode`
```lua
da_mode.register({
    name = "mymode",
    priority = 10,
    onActivate = function() ... end,
    onDeactivate = function() ... end,
    keymaps = {
        x = { justPressed = { fn = function() ... end } }
    }
})
da_mode.activate("mymode")
da_mode.deactivate("mymode")
```

### Delay Cache

```lua
-- fxmanifest.lua
shared_scripts {
    '@da_lib/features/cache/cache_delay.lua',
}
```
Creates global: `delay`
```lua
-- Returns true only once per 1000ms per named cache entry
if delay.myCheck(1000) then
    -- runs at most once per second
end
```

### Lazy Cache

```lua
-- fxmanifest.lua
shared_scripts {
    '@da_lib/features/cache/cache_lazy.lua',
}
```
Creates global: `lazy`
```lua
lazy.getPlayerMoney = function()
    return API.getMoney()  -- expensive call
end
-- Returns cached result for 2 seconds
local money = lazy(2000).getPlayerMoney()
```

### Object System

```lua
-- fxmanifest.lua
client_scripts {
    '@da_lib/data/object.lua',  -- hash lookup tables
    '@da_lib/features/object/object_cl.lua',
}
```
Creates global: `da_obj`
```lua
-- Spawn an object
local hash = `p_campfire01x`
da_obj.load(hash)
local obj = da_obj.createObj(hash, coords, { frozen = true })
-- Apply options
da_obj.set(obj, { frozen = false, collision = true })
-- Delete
da_obj.delete(obj)
```

### Input Control

```lua
-- fxmanifest.lua
client_scripts {
    '@da_lib/data/key.lua',
    '@da_lib/features/control/control_cl.lua',
}
```
Creates global: `da_control`
```lua
-- Wait for a key to be released
da_control.waitForRelease("x")
-- Check long press (holds for 300ms)
if da_control.isLongPressed("x") then ... end
```

### Networking

```lua
-- fxmanifest.lua
client_scripts {
    '@da_lib/features/net/net_cl.lua',
}
-- and/or server_scripts for server side
```
Creates global: `da_net`
```lua
-- Client: register event handlers
da_net.event("myresource:doThing", function(data) ... end)
da_net.events({ ["myresource:a"] = fn1, ["myresource:b"] = fn2 })

-- Blocking request from client to server (waits for response, 2s timeout)
local result = TriggerBlockingServerEvent("myresource:getData", 2000, playerId)
```

### Particle Effects

```lua
-- fxmanifest.lua
client_scripts {
    '@da_lib/features/fx/fx_cl.lua',
}
```
Creates global: `fx`
```lua
local handle = fx.new("core", "ent_amb_fire_campfire_01", {
    entity = someEntity,
    bone = "SKEL_ROOT",
    loop = true,
    scale = 1.0,
})
fx.remove({ handle = handle })
```

### Drawing

```lua
-- fxmanifest.lua
client_scripts {
    '@da_lib/features/draw/draw_cl.lua',
}
```
Creates globals: `DrawSphere`, `DrawCylinder`, `DrawLine`, `DrawText`, `DrawScreenText`, etc.
```lua
DrawText("Hello World", vector3(x, y, z), { r=255, g=255, b=255, a=255 }, 0.5)
DrawSphere(coords, 1.0, { r=255, g=0, b=0, a=100 })
```

### API Abstraction (framework-agnostic)

```lua
-- fxmanifest.lua
shared_scripts {
    '@da_lib/features/api/api_sh.lua',
}
```
Creates globals: `DAAPI`, `API`
```lua
-- DAAPI.ActiveFramework is the active framework name (from convar "framework")
-- API calls dispatch to the active framework implementation or the default
API.notify("Hello!")
API.hasJob("lawman")
API.teleport(vector4(x, y, z, heading), true)
```

### KVP (Persistent Key-Value Storage)

```lua
-- fxmanifest.lua
shared_scripts {
    '@da_lib/features/kvp/kvp_sh.lua',
}
```
Creates global: `kvp`
```lua
kvp.encode("mykey", { value = 42 })
local data = kvp.decode("mykey")   -- returns table
kvp.delete("mykey")
```

### Utilities

```lua
-- fxmanifest.lua
client_scripts {
    '@da_lib/features/util/util_cl.lua',
}
```
Creates global: `da_util`
```lua
local entities = da_util.GetEntitiesNearPoint(coords, 10.0)
local peds = da_util.GetPedsNearPoint(coords, 5.0)
local groundPos = da_util.GetGroundPositionForward(coords, 5.0, heading)
```

## Full Import Example (typical resource)

```lua
-- fxmanifest.lua
fx_version 'cerulean'
games {'rdr3'}
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
lua54 'yes'

shared_scripts {
    '@da_log/log_sh.lua',
    '@da_lib/features/api/api_sh.lua',
}

client_scripts {
    '@da_lib/data/key.lua',
    '@da_lib/features/control/control_cl.lua',
    '@da_lib/features/mode/mode_cl.lua',
    '@da_lib/features/object/object_cl.lua',
    'src/my_script_cl.lua',
}

dependencies {
    'da_lib',
}
```

## Next Steps

- [Feature Reference](README.md) — full list of available feature modules
- [da_log README](../../da_log/README.md) — logging configuration
- [da_mode system](../../CLAUDE.md#mode-system-da_lib) — priority-based state management
