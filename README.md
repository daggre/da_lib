# da_lib

A library of shared functions and utilities for RedM resources.

## Features

- **Animation System** - Simplified animation handling
- **Audio Management** - Advanced audio controls
- **Caching System** - Multiple caching strategies
- **Input Handling** - Keyboard and controller input management
- **Object System** - Object creation and manipulation
- **Networking** - Client-server communication
- **Mode System** - Resource state management
- **Drawing Utilities** - On-screen rendering helpers
- **Zone Management** - Create and manage world zones

## Installation

1. Copy this resource to your RedM server's resources directory
2. Add `ensure da_lib` to your server configuration
3. Import in your resource fxmanifest as needed

## Usage

```lua
-- Import the required modules in fxmanifest.lua
client_scripts {
    '@da_lib/features/anim/anim_cl.lua',
}

-- Use the imported library in your script
RegisterCommand('playerAnimTest', function()
    da_anim.ped(PlayerPedId(), "ai@react@point@base", "point_fwd", 3.0, 0.5, -1, 0, 0, false, 0, false, false)
end)
```

## Documentation

For detailed documentation, see the [docs](docs/README.md) directory.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please read the [CONTRIBUTING.md](CONTRIBUTING.md) for details on how to contribute.

## Credits

Developed by daggre_actual
