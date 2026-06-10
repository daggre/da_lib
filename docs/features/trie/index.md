# Trie System

The Trie module provides a hierarchical menu system for organizing and managing menu structures in RedM. It maintains a tree-like structure of menus, submenus, and options with associated keys and actions.

## Features

- Hierarchical menu structure with parent-child relationships
- Menu options with associated actions (functions)
- Conditional menu options that appear based on criteria
- Key-based navigation and selection
- Duplicate key detection to prevent conflicts
- Sorting capabilities for consistent menu display
- Integration with mode system for context-aware commands
- Keyboard shortcut support for quick access

## API Reference

### Menu Management

```lua
da_trie.addRoot(name)
```
- `name` (string): Name of the root menu to create
- **Returns** (boolean): Whether the root menu was successfully created

```lua
da_trie.add(parent, name, key)
```
- `parent` (string): Name of the parent menu
- `name` (string): Name of the submenu to add
- `key` (string/number): Key to assign to this submenu
- **Returns** (boolean): Whether the submenu was successfully added

### Option Management

```lua
da_trie.addOpt(parent, name, key, function, condition)
```
- `parent` (string): Name of the parent menu
- `name` (string): Name of the option to add
- `key` (string/number): Key to assign to this option
- `function` (function): Function to execute when option is selected
- `condition` (function, optional): Function that returns boolean to determine if option should be shown
- **Returns** (boolean): Whether the option was successfully added

### Menu Retrieval

```lua
local menuTree = da_trie.get(name)
```
- `name` (string): Name of the menu to retrieve
- **Returns** (table): Table containing the menu structure:
  - `name` (string): Menu name
  - `options` (table): Array of option objects
  - `submenus` (table): Array of submenu objects

```lua
local options = da_trie.getOpt(name)
```
- `name` (string): Name of the menu to retrieve options for
- **Returns** (table/nil): Array of option objects or nil if no options exist

### Option Execution

```lua
da_trie.run(parent, name, params)
```
- `parent` (string): Name of the parent menu
- `name` (string): Name of the option to execute
- `params` (any): Parameters to pass to the option's function

**Note**: This function does not return a value. It executes the option's function directly.

## Examples

### Creating a Basic Menu Structure

```lua
-- Create root menu
da_trie.addRoot("mainMenu")

-- Add submenus to the main menu
da_trie.add("mainMenu", "inventory", 1)
da_trie.add("mainMenu", "character", 2)
da_trie.add("mainMenu", "settings", 3)

-- Add options to the inventory submenu
da_trie.addOpt("inventory", "Use Item", 1, function(params)
    UseInventoryItem(params.itemId)
end)

da_trie.addOpt("inventory", "Drop Item", 2, function(params)
    DropInventoryItem(params.itemId)
end)

-- Add options to the character submenu
da_trie.addOpt("character", "Change Clothes", 1, function()
    OpenClothingMenu()
end)

-- Add options with conditions to the settings submenu
da_trie.addOpt("settings", "Admin Options", 1, function()
    OpenAdminMenu()
end, function()
    -- Only show for admins
    return IsPlayerAdmin()
end)
```

### Advanced Trie Integration with Mode System

```lua
-- Create a developer menu root
da_trie.addRoot("devRoot")

-- Add development submenus
da_trie.add("devRoot", "camera", "c")
da_trie.add("devRoot", "objects", "o")
da_trie.add("devRoot", "animation", "a")

-- Add mode activation commands with keyboard shortcuts
da_trie.addOpt("camera", "freecam mode", "f", function()
    -- Toggle freecam mode on/off
    da_mode.toggle("freecam")
end)

-- Add commands that only appear when a specific mode is active
da_trie.addOpt("objects", "freeze object", "f", function()
    -- Freeze the selected object
    FreezeObject(GetSelectedObject())
end, function()
    -- Only show when object mode is active AND an object is selected
    return da_mode.isActive("object") and GetSelectedObject() ~= nil
end)

-- Add commands that only appear when an object is in a specific state
da_trie.addOpt("objects", "unfreeze object", "u", function()
    -- Unfreeze the selected object
    UnfreezeObject(GetSelectedObject())
end, function()
    -- Only show when an object is selected AND frozen
    local obj = GetSelectedObject()
    return obj ~= nil and IsObjectFrozen(obj)
end)

-- Add actions with dynamic names based on state
da_trie.addOpt("camera", "lock camera", "l", function()
    -- Toggle camera lock
    ToggleCameraLock()
end, function()
    -- Change the displayed name based on current state
    local state = IsCameraLocked()
    if state then
        return {name = "unlock camera"}
    else
        return {name = "lock camera"}
    end
end)
```

### Complex Menu Navigation with Namespace Management

```lua
-- Developer tree with multiple branches and specialized command groups

-- Create main development tree
da_trie.addRoot("devRoot")

-- Create object manipulation submenu
da_trie.add("devRoot", "objects", "o")
da_trie.add("objects", "create", "c")
da_trie.add("objects", "modify", "m")
da_trie.add("objects", "selection", "s")

-- Create animation control submenu
da_trie.add("devRoot", "animation", "a")
da_trie.add("animation", "playback", "p")
da_trie.add("animation", "record", "r")

-- Add grouped commands to specific namespaces
for _, objType in ipairs({"prop", "vehicle", "ped"}) do
    da_trie.add("create", objType, string.sub(objType, 1, 1))

    -- Add object-type-specific creation commands
    da_trie.addOpt(objType, "spawn " .. objType, "s", function()
        SpawnObject(objType)
    end)

    da_trie.addOpt(objType, "list recent " .. objType .. "s", "l", function()
        ListRecentObjects(objType)
    end)
end

-- Add selection manipulation commands
da_trie.addOpt("selection", "select nearest", "n", function()
    SelectNearestObject()
end)

da_trie.addOpt("selection", "clear selection", "c", function()
    ClearObjectSelection()
end, function()
    -- Only show when something is selected
    return GetSelectedObject() ~= nil
end)

-- Add contextual mode commands to main menu for easy access
da_trie.addOpt("devRoot", "toggle object mode", "o", function()
    da_mode.toggle("object")
end)

da_trie.addOpt("devRoot", "toggle freecam", "c", function()
    da_mode.toggle("freecam")
end)
```

### Context-Aware Dynamic Menus with State Management

```lua
-- Create a system where different modes expose different command sets

-- Root menu is always accessible
da_trie.addRoot("devRoot")

-- Create object-specific menus based on selection
da_trie.addRoot("devRoot")

-- Add options that are dynamically shown based on object type
local objectType = GetSelectedObjectType()

if objectType == "VEHICLE" then
    da_trie.addOpt("devRoot", "modify vehicle", "m", ModifyVehicle, function()
        return GetSelectedObjectType() == "VEHICLE"
    end)
    da_trie.addOpt("devRoot", "enter driver seat", "e", EnterDriverSeat, function()
        return GetSelectedObjectType() == "VEHICLE"
    end)
elseif objectType == "PED" then
    da_trie.addOpt("devRoot", "modify ped", "m", ModifyPed, function()
        return GetSelectedObjectType() == "PED"
    end)
    da_trie.addOpt("devRoot", "set animation", "a", SetPedAnimation, function()
        return GetSelectedObjectType() == "PED"
    end)
elseif objectType == "PROP" then
    da_trie.addOpt("devRoot", "modify prop", "m", ModifyProp, function()
        return GetSelectedObjectType() == "PROP"
    end)
    da_trie.addOpt("devRoot", "duplicate prop", "d", DuplicateProp, function()
        return GetSelectedObjectType() == "PROP"
    end)
end

-- Add mode toggle with conditional menu options
da_trie.addOpt("devRoot", "toggle gizmo mode", "g", function()
    da_mode.toggle("gizmo")
end)

-- Create gizmo-specific menu (always present but conditionally visible)
da_trie.add("devRoot", "gizmo", "g")
da_trie.addOpt("gizmo", "translate mode", "t", function()
    SetGizmoMode("translate")
end, function()
    return da_mode.isActive("gizmo")
end)
da_trie.addOpt("gizmo", "rotate mode", "r", function()
    SetGizmoMode("rotate")
end, function()
    return da_mode.isActive("gizmo")
end)
da_trie.addOpt("gizmo", "scale mode", "s", function()
    SetGizmoMode("scale")
end, function()
    return da_mode.isActive("gizmo")
end)
```

### Integrating UI with Trie Menu System

```lua
-- Setup event handler for NUI
RegisterNUICallback("getMenuTree", function(data, cb)
    local menuName = data.menu or "mainRoot"

    -- Get menu structure
    local menu = da_trie.get(menuName)

    -- Sanitize menu structure for JSON
    local sanitizedMenu = {
        name = menu.name,
        options = {},
        submenus = {}
    }

    -- Process options
    if menu.options then
        for _, opt in ipairs(menu.options) do
            table.insert(sanitizedMenu.options, {
                name = opt.name,
                key = opt.key
            })
        end
    end

    -- Process submenus
    if menu.submenus then
        for _, submenu in ipairs(menu.submenus) do
            table.insert(sanitizedMenu.submenus, {
                name = submenu.name,
                key = submenu.key
            })
        end
    end

    -- Return menu data to UI
    cb(sanitizedMenu)
end)

-- Handle UI menu option selection
RegisterNUICallback("selectMenuOption", function(data, cb)
    local parentMenu = data.parentMenu
    local optionName = data.option

    -- Execute selected option
    da_trie.run(parentMenu, optionName, data.params or {})

    -- Acknowledge to UI
    cb({
        success = true
    })
end)

-- Send initial menu structure to UI on resource start
AddEventHandler("onClientResourceStart", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    -- Send root menu to UI
    SendNUIMessage({
        type = "initMenu",
        menu = da_trie.get("mainRoot")
    })
end)
```

## Implementation Notes

- The trie structure uses nested tables to organize menus and options
- Duplicate keys are detected and will log an error in most cases
- Conditional options with duplicate keys are allowed but will generate a spam log
- Menu options are sorted by key for consistent display
- Conditional options are evaluated when retrieving a menu with `get`
- The system is designed for hierarchical menu navigation rather than a flat structure
- Error logging includes source file and line information for easy debugging
- The module is exposed globally as `da_trie`

## Advanced Usage Patterns

### Mode-Trie Integration

The trie system works extremely well with the mode system:
- Create commands that toggle modes on/off
- Show/hide commands based on active modes
- Dynamically build command sets when modes activate
- Use mode-specific submenus for specialized commands

### Dynamic Menu Generation

Menus can be generated dynamically:
- Build menus on-the-fly based on game state
- Add/remove options based on player context
- Generate option lists from data sources (e.g., inventory items)
- Rebuild menus when modes or states change

### Contextual Commands

Make menus respond to context:
- Show commands only when they're applicable
- Use condition functions to check prerequisites
- Return modified option properties from condition functions
- Create smart UI with awareness of game state

### Namespace Management

Organize commands effectively:
- Group related commands into dedicated namespaces
- Use consistent key mappings across menu areas
- Create shortcut commands at root level for frequently used actions
- Balance between depth (nested menus) and breadth (many options)

### State-Driven Command Visibility

Control command visibility with state:
- Track state in external systems
- Create commands that modify tracked state
- Update command visibility based on state changes
- Design self-consistent command systems
