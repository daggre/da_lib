# Chance System

The Chance module provides a collection of utilities for probability-based operations, random selections, and dice rolls in RedM. It's designed for creating randomized game mechanics like loot drops, skill checks, and chance-based events.

## Features

- Basic dice and random number generation
- Percentage-based success checks
- Weighted random selection
- Skill check system with advantage/disadvantage mechanics
- Multi-roll systems for complex probability
- Game-specific utilities like lock-breaking and item drops

## API Reference

### Basic Random Functions

```lua
local value = da_chance.roll(max, [min])
```
- `max` (number): Maximum value (inclusive)
- `min` (number, optional): Minimum value (inclusive, default: 1)
- **Returns** (number): Random integer between min and max

```lua
local results = da_chance.multiDice(sides, amount)
```
- `sides` (number): Number of sides on each die
- `amount` (number): Number of dice to roll
- **Returns** (table): Array of dice roll results

### Success Checks

```lua
local passed = da_chance.success(threshold, amount)
```
- `threshold` (number): Number of successes needed
- `amount` (number): Maximum possible value
- **Returns** (boolean): True if random roll (1 to amount) is <= threshold

```lua
local passed = da_chance.successPercent(threshold)
```
- `threshold` (number): Percentage chance of success (0-100)
- **Returns** (boolean): True if check passed

```lua
local successCount = da_chance.multiRoll(threshold, attempts)
```
- `threshold` (number): Percentage chance of success for each attempt
- `attempts` (number): Number of attempts to make
- **Returns** (number): Total number of successful attempts

### Advantage/Disadvantage Systems

```lua
local passed = da_chance.disadvantage(threshold, [attempts])
```
- `threshold` (number): Percentage chance of success
- `attempts` (number, optional): Number of checks to pass (default: 2)
- **Returns** (boolean): True if ALL checks passed

```lua
local passed = da_chance.disadvantageSkillCheck(skill, threshold, [attempts])
```
- `skill` (number): Skill value
- `threshold` (number): Difficulty threshold
- `attempts` (number, optional): Number of checks to pass (default: 2)
- **Returns** (boolean): True if ALL skill checks passed

### Weighted Selection

```lua
local selection = da_chance.weightedChoice(weights)
```
- `weights` (table): Table with key-value pairs where values are weights
- **Returns** (any): Selected key based on weight probabilities

### Game Mechanics

```lua
local success = da_chance.skillCheck(skill, threshold)
```
- `skill` (number): Skill value
- `threshold` (number): Difficulty threshold
- **Returns** (boolean): True if skill check passed

```lua
local success = da_chance.lockbreak(skill, lockSkill)
```
- `skill` (number): Character's skill value
- `lockSkill` (number): Lock difficulty value
- **Returns** (boolean): True if lock was broken

```lua
local added = da_chance.item(threshold, itemName, [amount])
```
- `threshold` (number): Percentage chance (0-100)
- `itemName` (string): Item to add if successful
- `amount` (number, optional): Quantity to add (default: 1)
- **Returns** (boolean): True if item was added

## Examples

### Basic Random Generation

```lua
-- Generate a random number between 1 and 100
local randomValue = da_chance.roll(100)
print("Random value: " .. randomValue)

-- Roll a 20-sided die
local d20Result = da_chance.roll(20)
print("D20 roll: " .. d20Result)

-- Roll multiple dice (e.g., 3d6)
local diceResults = da_chance.multiDice(6, 3)
print("3d6 rolls:", table.unpack(diceResults))

-- Calculate sum of dice
local total = 0
for _, value in ipairs(diceResults) do
    total = total + value
end
print("Total: " .. total)
```

### Probability Checks

```lua
-- Simple 50% chance check
if da_chance.successPercent(50) then
    print("Success! This happens about half the time")
end

-- Different probabilities for item drops
function determinePlayerLoot()
    if da_chance.successPercent(5) then -- 5% chance
        return "rare_item"
    elseif da_chance.successPercent(25) then -- 25% chance
        return "uncommon_item"
    else
        return "common_item"
    end
end

-- Roll multiple times and count successes
local numSuccesses = da_chance.multiRoll(25, 4)
print("Got " .. numSuccesses .. " successes out of 4 attempts")
```

### Weighted Selection

```lua
-- Define probabilities for different weather types
local weatherWeights = {
    sunny = 50,
    cloudy = 25,
    rainy = 15,
    stormy = 7,
    foggy = 3
}

-- Select weather based on weights
local weather = da_chance.weightedChoice(weatherWeights)
print("Today's weather: " .. weather)

-- More complex example: Enemy spawn system with key-value pairs
local enemyTypes = {
    bandit = 70,
    lawman = 20,
    bounty_hunter = 9,
    legendary_gunslinger = 1
}

local enemyType = da_chance.weightedChoice(enemyTypes)
print("Spawning enemy type: " .. enemyType)
```

### Skill Checks and Game Mechanics

```lua
-- Basic skill check (player skill vs difficulty)
local playerLockpickSkill = 65  -- Player's skill (higher is better)
local lockDifficulty = 50       -- Lock difficulty (higher is harder)

if da_chance.skillCheck(playerLockpickSkill, lockDifficulty) then
    print("Lockpicking successful!")
else
    print("Failed to pick the lock")
end

-- Complex lockbreaking example
function attemptLockBreaking(playerSkill, lockLevel)
    print("Attempting to break lock with skill " .. playerSkill .. " vs lock level " .. lockLevel)

    if da_chance.lockbreak(playerSkill, lockLevel) then
        print("Lock broken successfully!")
        return true
    else
        print("Failed to break the lock")
        return false
    end
end

-- Disadvantage example (must succeed multiple times)
local stealthCheck = da_chance.disadvantage(70, 3)  -- 70% chance, but must succeed 3 times
if stealthCheck then
    print("Successfully moved without being detected")
else
    print("You were spotted!")
end
```

### Item Drop Systems

```lua
-- Try to give player an item with a 30% chance
local received = da_chance.item(30, "gold_nugget", 2)
if received then
    print("Found 2 gold nuggets!")
end

-- Create a loot table system
function generateLoot(lootLevel)
    local loot = {}

    -- Common items (50-90% chance based on level)
    local commonChance = 50 + (lootLevel * 10)
    if da_chance.successPercent(commonChance) then
        table.insert(loot, "canned_food")
    end

    -- Uncommon items (20-60% chance)
    local uncommonChance = 20 + (lootLevel * 10)
    if da_chance.successPercent(uncommonChance) then
        table.insert(loot, "medicine")
    end

    -- Rare items (5-25% chance)
    local rareChance = 5 + (lootLevel * 5)
    if da_chance.successPercent(rareChance) then
        table.insert(loot, "gold_bar")
    end

    return loot
end
```

## Implementation Notes

- Random number generation uses Lua's math.random, which should be seeded externally
- The `weightedChoice` function uses cumulative weights for selection
- Disadvantage systems require passing all checks (harder than individual checks)
- The lockbreak system includes special bonuses based on lock difficulty
- The chance module is accessed using the global `da_chance` table
- Item function requires an API with addItem functionality to work properly
