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

### Mode Events

The mode system triggers events when modes change:

- `mode:activated` - When a mode is activated
- `mode:deactivated` - When a mode is deactivated
- `mode:changed` - When the active mode changes
- `mode:primary` - When a mode becomes primary
- `mode:losePrimary` - When a mode loses primary status

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

### Advanced Keymap Configuration

```lua
da_mode.register({
    name = "objectEditor",
    priority = 70,
    onActivate = function()
        -- Mode activation code
    end,

    -- Define complex keymaps with modifiers and specific event types
    keymaps = {
        -- Standard key without modifiers
        {key = "DELETE", func = DeleteSelectedObject},
        
        -- Key with modifiers
        {key = "MOUSE1", mod = "SHIFT", func = function() SelectObject(true) end},
        
        -- Specific event type (justPressed, pressed, justReleased, released)
        {key = "R", eventType = "justPressed", func = RotateMode},
        
        -- Primary-only keymap (only works when this mode is primary)
        {key = "MOUSE2", primaryOnly = true, func = RightClickAction},
        
        -- Combined modifiers
        {key = "Z", mod = {"CTRL", "SHIFT"}, func = RedoAction},
        
        -- Different handlers for different event types on same key
        {key = "MOUSE1", eventType = "justPressed", func = StartDrag},
        {key = "MOUSE1", eventType = "justReleased", func = EndDrag}
    }
})
```

### Mode Control Passthrough (MCP) Implementation

```lua
-- Define MCP toggle functions in your mode
local isMCPActive = false

local function activateMCP()
    if isMCPActive then return end
    isMCPActive = true
    
    -- Toggle to UI focus mode
    SetNuiFocus(true, true)
    -- Send NUI message to show cursor
    SendNUIMessage({type = "setCursorMode", enabled = true})
end

local function deactivateMCP()
    if not isMCPActive then return end
    isMCPActive = false
    
    -- Toggle to game control mode
    SetNuiFocus(false, false)
    -- Send NUI message to hide cursor
    SendNUIMessage({type = "setCursorMode", enabled = false})
end

-- Register mode with MCP toggle on middle mouse button
mode.register("editorMode", 100, {
    onActivate = function()
        -- Default to game controls on activation
        deactivateMCP()
    end,
    
    keymaps = {
        -- Toggle between cursor mode and game control mode
        {key = "MOUSE3", eventType = "justPressed", func = function()
            if isMCPActive then
                deactivateMCP()
            else
                activateMCP()
            end
        end}
    }
})
```

### Mode Dependencies and Relationships

```lua
-- Create modes that interact with each other
local modes = {
    editor = {
        active = false,
        -- Base editor mode
    },
    
    gizmo = {
        -- Depends on editor mode
        checkActivation = function()
            -- Only allow gizmo mode when editor is active
            return modes.editor.active
        end
    }
}

-- Register modes with dependencies
mode.register("editor", 50, {
    onActivate = function()
        modes.editor.active = true
    end,
    onDeactivate = function()
        modes.editor.active = false
        -- Auto-deactivate dependent modes
        if mode.check("gizmo") then
            mode.deactivate("gizmo")
        end
    end
})

mode.register("gizmo", 60, {
    onActivate = function()
        -- Check if activation is allowed
        if not modes.gizmo.checkActivation() then
            print("Cannot activate gizmo without editor mode")
            return false -- Prevent activation
        end
        -- Setup gizmo
    end
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
