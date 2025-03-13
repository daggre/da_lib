# Lazy Cache

The Lazy Cache provides a lightweight, flexible caching mechanism that allows for lazy evaluation of functions with a configurable time-to-live (TTL) delay. Functions are executed only when accessed, and their results are cached based on a delay specified by the user.

## Features

- **Lazy Evaluation**: Functions are only executed when accessed
- **Configurable TTL**: Results are cached to avoid repeated computation, with customizable delays
- **Dynamic Function Assignment**: Add functions to the cache with simple assignment
- **RedM/FiveM Compatible**: Special handling for CitizenFX function references

## API Reference

### Setting a Function

```lua
lazy.functionName = function(...) ... end
```

- Assigns a function to the cache
- Function must be a valid Lua function or a CitizenFX function reference
- Throws an error if the assigned value is not a function

### Calling a Function

```lua
local result = lazy(delay).functionName(...)
```

- `delay` (number, optional): Time in milliseconds before refreshing the cache (default: 0)
- Returns the cached result or computes and caches a new result if:
  - The function has never been called before, or
  - The specified delay has elapsed since the last computation

### Usage Without Delay

```lua
local result = lazy.functionName(...)
```

- When called without a delay parameter, the function will always be executed
- Equivalent to `lazy(nil).functionName(...)`

## Implementation Details

- Cache is stored in an internal table with function references and their last results
- Uses Lua metatables to provide the caching functionality:
  - `__call` metamethod: Handles the delay parameter
  - `__index` metamethod: Creates callable proxies for cached functions
  - `__newindex` metamethod: Validates and stores functions in the cache
- The cached `ttl` value stores the timestamp of the last execution
- Uses `GetGameTimer()` for timestamp comparison (compatible with RedM/FiveM)

## Examples

### Basic Usage

```lua
-- Define a function to cache
lazy.multiply = function(a, b)
    print("Computing multiply")
    return a * b
end

-- First call executes the function
local result1 = lazy(1000).multiply(4, 5)  -- Prints "Computing multiply", returns 20

-- Call again within delay - uses cached result
local result2 = lazy(1000).multiply(4, 5)  -- No print, returns 20 from cache

-- Wait more than 1000ms
Wait(1500)

-- Call after delay expired - executes function again
local result3 = lazy(1000).multiply(4, 5)  -- Prints "Computing multiply", returns 20
```

### Different Delay Values

```lua
-- Different delays can be used for the same function
lazy.expensiveOperation = function()
    print("Running expensive operation")
    return os.time()
end

-- Cache for 5 seconds
local result1 = lazy(5000).expensiveOperation()

-- Different code can use different cache durations
local result2 = lazy(10000).expensiveOperation()  -- Uses cached result

-- No caching
local result3 = lazy(0).expensiveOperation()  -- Always executes
```
