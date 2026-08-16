# Dev Menu

Puts an entry in da_dev's dev tree (`z`) **from the resource that owns the feature**, instead of
from a stub file inside da_dev.

The old shape was a file in `da_dev/src/` per resource, firing an event the owner listened for. That
entry is registered whether or not the owner is loaded — on a server without, say, `da_tack`, the
dev menu still shows `tack` and pressing it does nothing. Registering from the owner means the entry
exists exactly as long as the owner does.

Closures stay in the owning resource (same design as the interact facade):
only `parent`, `name`, `key`, `label` and an id travel to da_dev, which calls back through the
owner's exports to run the option or test its condition.

## Include

```lua
client_scripts {
    '@da_lib/features/devmenu/devmenu_cl.lua',
}
```

No dependency on da_dev, in the manifest or anywhere else. With da_dev absent the calls below are
no-ops; if da_dev starts (or restarts) later, entries are re-sent automatically.

## API Reference

```lua
da_devmenu.addOpt(parent, name, key, fn, condition, label)
```
- `parent` (string): menu to hang it under — `"devRoot"` for the top level, `"objRoot"` for the
  object-mode menu, or a submenu this resource added
- `name` (string): option name, shown in the menu
- `key` (string): selection key, unique within `parent`
- `fn` (function): runs when the player picks it
- `condition` (function, optional): returns truthy for the option to show
- `label` (string, optional): human-facing text when `name` is an id
- **Returns** (boolean): whether the entry is live in da_dev *right now*. `false` also means "da_dev
  is not running" — the entry is held and sent when it comes up, so it is not an error.

```lua
da_devmenu.add(parent, name, key, condition, label)
```
Submenu, for a resource with more than one entry. `condition` gates the whole folder.

```lua
da_devmenu.clear()
```
Takes every entry this resource owns back out of the tree. Stopping the resource does this too
(da_dev watches `onResourceStop`); this is for rebuilding a menu at runtime.

## Example

```lua
local function toggle() ... end

da_devmenu.addOpt("devRoot", "tack", "2", toggle)
```

A resource with several entries:

```lua
da_devmenu.add("devRoot", "ranch", "9")
da_devmenu.addOpt("ranch", "spawn herd", "s", spawnHerd)
da_devmenu.addOpt("ranch", "clear herd", "c", clearHerd, function() return herdActive() end)
```

## Notes

- Keys are checked for collisions inside `parent`, da_dev's own entries included. da_dev's registry
  loads last, so a collision is reported against the remote entry and that entry is dropped — pick
  another key.
- `condition` is evaluated in the owner's runtime each time the menu is drawn; keep it cheap.
- da_dev side: `da_dev/src/devmenu_cl.lua` (`devMenuRegister` / `devMenuClear` exports).
