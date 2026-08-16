# Changelog

## [1.0.0] - 2026-08-15

First stable release. The library has been in production use across every `da_*`
resource; this version number is a compatibility promise, not a rewrite.

### Provides
- **Mode system** — priority-based state management with lifecycle hooks, keymap
  dispatch, and mode control passthrough
- **Condition engine** — data-driven availability checks, evaluated per resource
- **Animation** — ped and object animation with flags, IK, and task filters
- **Objects** — entity spawning (objects, peds, vehicles), attachment, bone transforms
- **API abstraction** — framework-agnostic, with VORP and standalone implementations
- **Drawing** — world-space and screen-space rendering primitives
- **Control** — key state polling, long/short press tracking, passthrough
- **Trie** — hierarchical keyboard-navigable menu structure
- Plus audio, caching, chance, CLI, epoch, FX, KVP, locks, movement, networking, NUI,
  raycast, texture, weapon and vegetation helpers

### Notes
- Each feature is a separate `@da_lib/features/...` include. Take only what you use.
- `registerMode` takes a mode definition table; `unregisterMode` takes the mode **name**.
