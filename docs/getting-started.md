# Getting Started with da_lib

This guide will help you get started with da_lib in your RedM project.

> [!CAUTION]
> This documentation was AI generated and has high chance of hallucinations.

## Installation

1. Copy the da_lib folder to your server's resources directory
2. Add `ensure da_lib` to your server.cfg file
3. Restart your server or start the resource manually

## Quick Start

### Basic Usage

Most features in da_lib can be accessed through exports. Here's a basic example:

```lua
-- In your client script
local cache = exports.da_lib:getCache()
local audio = exports.da_lib:getAudio()
local draw = exports.da_lib:getDraw()

-- Use the lazy cache
cache.lazy.someFunction = function()
    return "Expensive calculation result"
end

-- Call the function with a 5-second cache
local result = cache.lazy(5000).someFunction()

-- Play an audio sound
audio.playSound("DISTANT_SHOTS", 0.5)

-- Draw text on screen
RegisterNetEvent('someEvent', function()
    draw.text("Hello World", 0.5, 0.5, 0.5, 255, 255, 255, 255)
end)
```

### Feature Import Examples

Here are examples of importing different features:

#### Animation System

```lua
local anim = exports.da_lib:getAnim()

-- Play an animation
anim.playAnimation('WORLD_HUMAN_SMOKE')

-- Stop animation
anim.stopAnimation()
```

#### Object Management

```lua
local object = exports.da_lib:getObject()

-- Spawn an object
local objId = object.create('p_bottlemedicine01x', vector3(x, y, z))

-- Remove the object
object.remove(objId)
```

#### Mode System

```lua
local mode = exports.da_lib:getMode()

-- Register a mode
mode.register('camping')

-- Check if a mode is active
if mode.check('camping') then
    -- Do something while in camping mode
end
```

## Next Steps

Explore the [Documentation](README.md) for more detailed information about each feature module.

- [Lazy Cache](features/cache/lazy.md) - For efficient function caching
- [Animation System](features/anim/index.md) - For animation control
- [Audio Management](features/audio/index.md) - For sound control
- [And more...](README.md#features)
