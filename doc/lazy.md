# Lazy Caching Library

This Lua library provides a lightweight, flexible caching mechanism that allows for lazy evaluation of functions with an optional time-to-live (TTL) delay. Functions are executed only when accessed, and their results are cached based on a delay specified by the user.

## Features
- **Lazy Evaluation**: Functions are only executed when accessed.
- **Caching with TTL**: Results are cached to avoid repeated computation, with optional delay support.
- **Dynamic Function Assignment**: Easily add functions to the cache with minimal setup.
- **Customizable Access**: Specify delays on a per-function basis, allowing for optimized, time-sensitive caching.

## Usage

### Setting Up the Cache
The cache is managed by the `lazy` table. Functions are added to `lazy` by assigning them directly:

```lua
lazy.myFunc = function(x) return x * 2 end
```

### Calling Cached Functions with Delay
To invoke a cached function with a delay, use:
```lua
local result = lazy(1000).myFunc(5)
```
In this example, `myFunc(5)` is executed only if:
- `myFunc` has not been called before.
- The cached result has expired based on the specified 1000ms delay.

### Technical Details
1. **Cache Table**: Stores function references, results, and the time-to-live (`ttl`) timestamp for each function.
2. **Lazy Table with Metatables**:
   - `__call` metamethod: Allows specifying a delay (in milliseconds) before the cached value expires.
   - `__index` metamethod: Creates a callable function on-the-fly, using the specified delay.
3. **Adding Functions**: Use `lazy[functionName] = function` syntax to add new functions.
4. **Calling Functions**: Use `lazy(delay)[functionName](arguments...)` to call a function with the specified delay.

## Installation
Simply copy the code into your Lua environment or include it in your project.

## License
This project is open source and available under the [MIT License](LICENSE).
