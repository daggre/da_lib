# da_lib

A library of shared functions and utilities for RedM resources.

## Features

- **Mode System** — Priority-based state management with lifecycle hooks and keybind dispatch
- **Animation** — Simplified ped and object animation with flags and IK support
- **API Abstraction** — Framework-agnostic API supporting VORP and default implementations
- **Audio** — Networked audio playback (broadcast to all clients)
- **Caching** — Delay cache (rate limiting) and lazy cache (TTL-based result caching)
- **Chance** — Dice rolls, weighted random choices, skill checks
- **CLI** — Console command tree with subcommands, flags, and argument parsing
- **Control** — Key state polling, long press detection, and control passthrough
- **Drawing** — World-space and screen-space rendering (spheres, lines, text, sprites)
- **Epoch** — Server-synchronized `os.time()` for consistent timestamps
- **FX** — Particle effect creation, attachment, and removal
- **KVP** — Persistent key-value storage with JSON encode/decode helpers
- **Lock** — Exclusive locks with timeout (client and server, including GlobalState)
- **Move** — Ped facing and movement helpers with completion waiting
- **Networking** — Event registration and blocking client-server communication with timeout
- **NUI** — NUI message and callback registration helpers
- **Object** — Entity spawning (objects, peds, vehicles) with extensive option support
- **Texture** — Texture dictionary loading and sprite drawing
- **Trie** — Hierarchical menu tree structure for keyboard-navigable menus
- **Utility** — Entity search, ground positioning, coordinate math
- **Weapon** — Weapon equip, holster, and toggle helpers

## Installation

1. Copy `da_lib` and `da_log` into your server's resources directory
2. Add to `server.cfg` (order matters — da_log first, then da_lib, then dependent resources):
   ```
   ensure da_log
   ensure da_lib
   ```
3. In your resource's `fxmanifest.lua`, import the specific feature files you need

## Usage

Features are imported by including their files in your resource's `fxmanifest.lua`. Each file creates globals in your resource's Lua environment.

```lua
-- fxmanifest.lua
shared_scripts {
    '@da_log/log_sh.lua',
}

client_scripts {
    '@da_lib/features/mode/mode_cl.lua',
    '@da_lib/features/anim/anim_cl.lua',
}
```

```lua
-- your client script
da_mode.register({
    name = "mymode",
    priority = 10,
    onActivate = function() log.info("mode activated") end,
})

da_anim.ped(PlayerPedId(), "ai@react@point@base", "point_fwd", 3.0, 0.5, -1, 0)
```

## Documentation

See [docs/README.md](docs/README.md) for the full feature module reference and [docs/getting-started.md](docs/getting-started.md) for detailed usage examples.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for code style and contribution guidelines.

## Credits

Developed by daggre_actual
