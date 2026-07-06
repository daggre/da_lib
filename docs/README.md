# da_lib Documentation

Welcome to the documentation for da_lib — a collection of shared utilities for RedM resources.

## Getting Started

- [Installation & Usage Guide](getting-started.md)

## Feature Modules

Features are imported individually via `fxmanifest.lua` includes. Each file creates one or more globals.

### Shared (client + server)

| Module | File | Globals | Doc |
|--------|------|---------|-----|
| Logging | `@da_log/log_sh.lua` | `log` | [da_log README](../../da_log/README.md) |
| Delay Cache | `features/cache/cache_delay.lua` | `delay` | [delay](features/cache/delay.md) |
| Lazy Cache | `features/cache/cache_lazy.lua` | `lazy` | [lazy](features/cache/lazy.md) |
| API Abstraction | `features/api/api_sh.lua` | `API`, `DAAPI` | — |
| CLI | `features/cli/cli_sh.lua` | `cli` | — |
| KVP | `features/kvp/kvp_sh.lua` | `kvp` | [kvp](features/kvp/index.md) |

### Client-Only

| Module | File | Globals | Doc |
|--------|------|---------|-----|
| Animation | `features/anim/anim_cl.lua` | `da_anim` | [anim](features/anim/index.md) |
| Audio | `features/audio/audio_cl.lua` | `da_audio` | [audio](features/audio/index.md) |
| Chance | `features/chance/chance_cl.lua` | `da_chance` | [chance](features/chance/index.md) |
| Control | `features/control/control_cl.lua` | `da_control`, `da_controlpass` | [control](features/control/index.md) |
| Draw | `features/draw/draw_cl.lua` | `DrawSphere`, `DrawLine`, `DrawText`, etc. | [draw](features/draw/index.md) |
| Epoch | `features/epoch/epoch_cl.lua` | `epoch` | [epoch](features/epoch/index.md) |
| FX | `features/fx/fx_cl.lua` | `fx` | [fx](features/fx/index.md) |
| Lock | `features/lock/lock_cl.lua` | `xlock`, `xunlock`, `gl_xlock`, `gl_xunlock` | [lock](features/lock/index.md) |
| Mode | `features/mode/mode_cl.lua` | `da_mode`, `da_mcp` | [mode](features/mode/index.md) |
| Move | `features/move/move_cl.lua` | `da_move` | [move](features/move/index.md) |
| Net | `features/net/net_cl.lua` | `da_net`, `TriggerBlockingServerEvent`, etc. | [net](features/net/index.md) |
| NUI | `features/nui/nui_cl.lua` | `da_ui` | [nui](features/nui/index.md) |
| Object | `features/object/object_cl.lua` | `da_obj` | [object](features/object/index.md) |
| Texture | `features/texture/texture_cl.lua` | `da_texture` | — |
| Trie | `features/trie/trie_cl.lua` | `da_trie` | [trie](features/trie/index.md) |
| Util | `features/util/util_cl.lua` | `da_util` | [util](features/util/index.md) |
| Weapon | `features/weapon/weapon_cl.lua` | `da_weapon` | [weapon](features/weapon/index.md) |

### Server-Only

| Module | File | Globals | Description |
|--------|------|---------|-------------|
| Epoch | `features/epoch/epoch_srv_ctl.lua` | *(internal)* | Serves epoch time to clients |
| Lock | `features/lock/lock_srv.lua` | `xlock`, `xunlock`, `gl_xlock`, `gl_xunlock` | Server-side exclusive locks |
| Net | `features/net/net_srv.lua` | `da_net`, `TriggerBlockingClientEvent`, etc. | Event registration and blocking server-client calls |

### Data Tables (client)

| File | Global | Contents |
|------|--------|----------|
| `data/key.lua` | `dat.keyHash` | Key name → game control hash map |
| `data/object.lua` | `dat.object`, `dat.getName` | Object model hashes |
| `data/ped.lua` | `dat.ped` | Ped model hashes |
| `data/vehicle.lua` | `dat.vehicle` | Vehicle model hashes |
| `data/animation.lua` | `dat.animation` | Animation dictionary definitions |
| `data/flags_af.lua` | `dat.flags_af` | Animation flag constants |
| `data/flags_aik.lua` | `dat.flags_aik` | IK flag constants |
| `data/bones.lua` | `dat.bones` | Bone name definitions |

## Contributing

See [CONTRIBUTING.md](../CONTRIBUTING.md) for code style and pull request guidelines.
