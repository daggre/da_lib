# Cache System

The da_lib cache system provides multiple ways to optimize performance through different caching mechanisms.

## Available Cache Types

### [Lazy Cache](lazy.md)

The Lazy Cache implementation provides a way to cache function results with a configurable time-to-live (TTL). Functions are executed only when necessary, and their results are reused until the specified delay expires.

Key features:
- Lazy evaluation - functions execute only when accessed
- Configurable time-to-live delays
- Simple API with function assignment

[Read more about Lazy Cache](lazy.md)

### [Delay Cache](delay.md)

The Delay Cache provides a mechanism to control the frequency of function execution without storing results.

Key features:
- Throttles function calls
- Ensures minimum time between executions
- Useful for rate-limiting operations

[Read more about Delay Cache](delay.md)

## Choosing the Right Cache

| Cache Type | Use Case | Stores Results | Time-Based |
|------------|----------|----------------|------------|
| Lazy       | Expensive calculations that can be reused | Yes | Yes |
| Delay      | Rate-limiting operations | No | Yes |