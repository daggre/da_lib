--- Copyright © 2024 Joshua Nelson

---Give an item to the player based on chance
---@param itemName string The item name
---@param amount integer The amount of the item to give
---@param chance integer The percent chance out of 100 to receive the item
---@return unknown|nil
Lib.Chance.Item = function(itemName, amount, chance)
    if chance and chance < 100 then
        local chanceResult = math.random(100)
        if chanceResult <= chance then
            return Lib.Fn.AddItem(itemName, amount)
        end
    else
        return Lib.Fn.AddItem(itemName, amount)
    end
end

---Given a base chance and a max chance, calculate how many disadvantages to
---apply based on how many times the chance goes into the max chance.
---@param chance integer the base chance or skill to calculate disadvantages for
---@param max integer the max chance or skill to calculate disadvantages for
---@param disadvantageCap integer the maximum number of disadvantages to apply
---@return integer disadvantages the number of disadvantages to apply
Lib.Chance.Disadvantage = function(chance, max, disadvantageCap)
    disadvantageCap = disadvantageCap or 2
    -- Calculate how many disadvantages to apply based on skill level
    return math.min(disadvantageCap, math.floor(max/chance))
end

---Roll for chance and apply disadvantages
---@param min integer base chance of success (roll lower than value to succeed)
---@param max integer maximum chance
---@param disadvantage integer number of disadvantages to apply
---@return integer roll the value of the roll after applying disadvantages
Lib.Chance.Roll = function(min, max, disadvantage)
    disadvantage = disadvantage or 0
    local value = min
    for _ = 0, disadvantage do
        value = math.max(value, math.random(max))
    end
    return value
end

---Calculate the chance to break a lock given a skill value and a lock skill
---@param skill integer the skill ability of the player to break a lock
---@param lockSkill integer the skill level of the lock
---@return boolean success did the player successfully break the lock
Lib.Chance.Lockbreak = function(skill, lockSkill)
    Lib.Log.Debug(("Lockbreak skill: %s, lockSkill: %s"):format(skill, lockSkill))
    assert(tonumber(skill), "skill must be a number: "..skill)
    assert(tonumber(lockSkill), "lockSkill must be a number: "..lockSkill)
    if not skill then return false; end
    local maxChance = 95
    local bonusChance = lockSkill <= 15 and 33 or lockSkill <= 25 and 20 or 0
    local disadvantage = lockSkill <= 15 and 0 or Lib.Chance.Disadvantage(skill, lockSkill, 3)
    local chance = maxChance - bonusChance
    local skillBonus = math.floor(chance * (skill / lockSkill))
    local roll = Lib.Chance.Roll(1, 100, disadvantage)
    Lib.Log.Debug(("Lockbreak roll: %s, chance: %s, bonusChance: %s, skillBonus: %s"):format(roll, chance, bonusChance, skillBonus))
    local success = roll <= bonusChance + skillBonus
    if success and skill <= lockSkill then
        Lib.Stats.Add("lockbreakrep", 1)
    end
    return success
end

Lib.Chance.ValueLootTable = function(lootTable, maxValue)
    local lootedValue = 0
    local totalChance = 1
    local chanceLookup = {}
    for _, lootData in ipairs(lootTable) do
        table.insert(chanceLookup, { min = totalChance, max = totalChance + lootData.chance, value = lootData.value, item = lootData.item })
        totalChance = totalChance + lootData.chance
    end
    Lib.Log.Debug("Chance lookup: ", chanceLookup)
    Lib.Log.Debug(("Total chance: %s"):format(totalChance))
    while lootedValue < maxValue do
        Citizen.Wait(250)
        local roll = math.random(totalChance)
        for _, chanceData in ipairs(chanceLookup) do
            if roll > chanceData.min and roll <= chanceData.max then
                Lib.Log.Debug(("Rolled table item: %s, value: %s, currentValue: %s"):format(chanceData.item, chanceData.value, lootedValue))
                if lootedValue ~= 0 and lootedValue + (chanceData.value/2) > maxValue then return; end
                lootedValue = lootedValue + chanceData.value
                Lib.Fn.AddItem(chanceData.item, 1)
            end
        end
    end
end
