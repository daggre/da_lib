local roll = function(max, min)
    min = min or 1
    return math.random(min, max)
end

local success = function(threshhold, amount)
    return math.random(amount) <= threshhold
end

local successPercent = function(threshold)
    return math.random(100) <= threshold
end

local dice = function(sides)
    return roll(sides)
end

local multiDice = function(sides, amount)
    local rolls = {}
    for _ = 1, amount do
        table.insert(rolls, dice(sides))
    end
    return rolls
end

-- Returns table key based on weighted choice (value)
local weightedChoice = function(weights)
    local totalWeight = 0
    for _, weight in pairs(weights) do
        totalWeight = totalWeight + weight
    end

    local rand = roll(totalWeight)
    local cumulative = 0

    for item, weight in pairs(weights) do
        cumulative = cumulative + weight
        if rand <= cumulative then
            return item
        end
    end
end

-- Adds item to inventory if check passes
local item = function(threshold, itemName, amount)
    amount = amount or 1
    if successPercent(threshold) then
        return API.addItem(itemName, amount)
    end
end

-- Returns number of successes
local multiRoll = function(threshold, attempts)
    local successes = 0
    for _ = 1, attempts do
        if successPercent(threshold) then
            successes = successes + 1
        end
    end
    return successes
end

-- Returns true if disadvantage check is passed
local disadvantage = function(threshold, attempts)
    attempts = attempts or 2
    for _ = 1, attempts do
        if not successPercent(threshold) then
            return false
        end
    end
    return true
end

-- Returns true if roll is within threshold amount
local skillCheck = function(skill, threshold)
    return success(skill, threshold)
end

-- Returns true if all rolls are within threshold amount
local disadvantageSkillCheck = function(skill, threshold, attempts)
    attempts = attempts or 2
    for _ = 1, attempts do
        if not success(threshold, skill) then
            return false
        end
    end
    return true
end

local lockbreak = function(skill, lockSkill)
    local rolls = math.min(3, math.floor(lockSkill/skill))
    local bonus = lockSkill <= 15 and 33 or lockSkill <= 25 and 20 or 5
    return disadvantageSkillCheck(skill + bonus, lockSkill, rolls)
end

_ENV.Chance = {
    disadvantage = disadvantage,
    disadvantageSkillCheck = disadvantageSkillCheck,
    item = item,
    lockbreak = lockbreak,
    multiDice = multiDice,
    multiRoll = multiRoll,
    roll = roll,
    skillCheck = skillCheck,
    success = success,
    successPercent = successPercent,
    weightedChoice = weightedChoice,
}
