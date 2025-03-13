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
3. Import in your resources as needed

## Usage

```lua
-- Client-side example
local MyResource = {}

-- Import the required modules
local anims = exports.da_lib.anim
local audio = exports.da_lib.audio
local cache = exports.da_lib.cache
local draw = exports.da_lib.draw

-- Use the API
RegisterCommand('example', function()
    anims.playAnimation('WORLD_HUMAN_SMOKE')
    audio.playSound('DISTANT_SHOTS', 0.5)
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