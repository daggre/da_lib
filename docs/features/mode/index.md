# Mode System

The Mode system provides a state management framework for RedM resources. It allows you to create and control different gameplay modes, states, and behaviors.

## Features

- Register and activate different modes
- Check if specific modes are active
- Mode prioritization and primary mode management
- Mode transition events and lifecycle hooks
- Mode Control Passthrough (MCP) for handling UI and game input focus
- Advanced keymap configuration with modifier keys

## API Reference

### Mode Registration and Control

```lua
da_mode.register(modeDefinition)
```
- `modeDefinition` (table): Mode definition object with the following properties:
  - `name` (string, required): Unique identifier for the mode
  - `priority` (number, optional): Priority level (higher numbers take precedence, default: 0)
  - `onActivate` (function, optional): Called when mode is activated
  - `onDeactivate` (function, optional): Called when mode is deactivated
  - `onPrimary` (function, optional): Called when mode becomes the primary mode
  - `onLosePrimary` (function, optional): Called when mode loses primary status
  - `keymaps` (table, optional): Keymap configurations
  - `disableGame` (boolean, optional): Whether this mode disables game controls

```lua
da_mode.activate(modeName)
```
- `modeName` (string): The mode to activate

```lua
da_mode.deactivate(modeName)
```
- `modeName` (string): The mode to deactivate

```lua
da_mode.toggle(modeName)
```
- `modeName` (string): The mode to toggle on/off

### Mode State Checking

```lua
local isActive = da_mode.isActive(modeName)
```
- `modeName` (string): The mode to check
- **Returns** (boolean): Whether the specified mode is currently active

```lua
local isPrimary = da_mode.isPrimary(modeName)
```
- `modeName` (string): The mode to check
- **Returns** (boolean): Whether the specified mode is currently the primary mode

### Internal Events

The mode system uses local events to communicate with the controller:

- `modeController:registerMode` — Register a mode definition
- `modeController:activateMode` — Activate a mode by name
- `modeController:deactivateMode` — Deactivate a mode by name
- `modeController:toggleMode` — Toggle a mode on/off
- `modeController:dispatchEvents` — Dispatch input events to the controller

These are triggered internally by `da_mode.*` calls. You do not need to trigger them directly.

## Examples

### Basic Mode Registration and Use

```lua
-- Register gameplay modes
da_mode.register({name = 'normal', priority = 1})
da_mode.register({name = 'combat', priority = 2})
da_mode.register({name = 'conversation', priority = 3})
da_mode.register({name = 'cinematic', priority = 4})

-- Activate a mode
function enterCombat()
    da_mode.activate('combat')
    -- Combat-specific setup
end

-- Check current mode
Citizen.CreateThread(function()
    while true do
        if da_mode.isActive('combat') then
            -- Enable combat UI
        else
            -- Hide combat UI
        end
        Citizen.Wait(100)
    end
end)
```

### Advanced Mode Registration with Lifecycle Hooks

```lua
da_mode.register({
    name = "freecam",
    priority = 80,
    onActivate = function()
        print("Freecam mode activated")
        SetNuiFocus(false, false)
        -- Setup camera entity
        freecam.camera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
        -- Additional setup code
    end,

    onDeactivate = function()
        print("Freecam mode deactivated")
        -- Cleanup camera
        DestroyCam(freecam.camera)
        freecam.camera = nil
        -- Additional cleanup code
    end,

    onPrimary = function()
        print("Freecam is now the primary mode")
        -- Enable specific controls for this mode
        freecam.attachControls()
    end,

    onLosePrimary = function()
        print("Freecam is no longer the primary mode")
        -- Disable specific controls for this mode
        freecam.detachControls()
    end
})
```

### Keymap Configuration

Keymaps are an array of objects in the mode definition. Each entry specifies a key, an event type, and a callback function.

```lua
da_mode.register({
    name = "objectEditor",
    priority = 70,
    onActivate = function()
        -- Mode activation code
    end,
    keymaps = {
        -- Standard key: justPressed event
        {
            key = "r",
            event = "justPressed",
            fn = function() ToggleGizmo() end,
        },

        -- Primary-only keymap (only fires when this mode is highest priority)
        {
            key = "Escape",
            event = "justPressed",
            primary = true,
            fn = function() da_mode.deactivate("objectEditor") end,
        },

        -- Key with modifier check
        {
            key = "MouseLeft",
            event = "justPressed",
            primary = true,
            modifiers = { shift = true },
            fn = function() SpawnSelectedObject() end,
        },

        -- Different handlers for different event types on the same key
        {
            key = "MouseLeft",
            event = "justPressed",
            primary = true,
            modifiers = { shift = false },
            fn = function() SelectObject() end,
        },
    }
})
```

### Mode Control Passthrough (MCP)

MCP (`da_mcp`) is a separate system for toggling NUI cursor focus on/off within a mode — useful for tools that need to switch between game controls and a UI cursor.

```lua
-- Toggle NUI cursor on middle mouse click inside a mode
da_mode.register({
    name = "editorMode",
    priority = 100,
    onActivate = function()
        SetNuiFocus(false, false)
    end,
    onDeactivate = function()
        SetNuiFocus(false, false)
        da_mcp.deactivate()
    end,
    keymaps = {
        {
            key = "MouseMiddle",
            event = "justPressed",
            primary = true,
            fn = function()
                if da_mcp.active then
                    da_mcp.deactivate()
                    SetNuiFocus(false, false)
                else
                    da_mcp.activate({
                        activate = function() SetNuiFocus(true, true) end,
                        deactivate = function() SetNuiFocus(false, false) end,
                    })
                end
            end,
        },
    }
})
```

### Mode Dependencies and Relationships

```lua
-- Register modes that interact with each other
da_mode.register({
    name = "editor",
    priority = 50,
    onActivate = function()
        log.info("editor mode on")
    end,
    onDeactivate = function()
        -- Auto-deactivate dependent modes
        if da_mode.isActive("gizmo") then
            da_mode.deactivate("gizmo")
        end
    end,
})

da_mode.register({
    name = "gizmo",
    priority = 60,
    onActivate = function()
        if not da_mode.isActive("editor") then
            log.warn("gizmo requires editor mode")
            da_mode.deactivate("gizmo")
            return
        end
    end,
})
```

## Implementation Notes

- Modes can have priorities - higher priority modes take precedence and become the primary mode
- Multiple modes can be active simultaneously, but only the highest priority one is the primary mode
- The primary mode receives special events (onPrimary, onLosePrimary) and can have primaryOnly keymaps
- Mode Control Passthrough (MCP) is a pattern for toggling between UI focus and game controls
- Resource cleanup is handled automatically when using proper lifecycle hooks
- A mode's lifecycle functions can return false to prevent activation/deactivation
- Modes can be organized in hierarchies with parent-child relationships and dependencies
