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

Lib.Chance.Disadvantage = function(chance, max, disadvantageCap)
    disadvantageCap = disadvantageCap or 2
    -- Calculate how many disadvantages to apply based on skill level
    return math.min(disadvantageCap, math.floor(max/chance))
end

Lib.Chance.Roll = function(min, max, disadvantage)
    disadvantage = disadvantage or 0
    local value = min
    for _ = 0, disadvantage do
        value = math.max(value, math.random(max))
    end
    return value
end

Lib.Chance.Lockbreak = function(skill, lockSkill)
    if not skill then return false; end
    local maxChance = 95
    local bonusChance = lockSkill <= 15 and 33 or lockSkill <= 25 and 20 or 0
    local chance = maxChance - bonusChance
    local skillBonus = math.floor(chance * (skill / lockSkill))
    local roll = Lib.Chance.Roll(1, 100, Lib.Chance.Disadvantage(skill, lockSkill, 6))
    return roll <= bonusChance + skillBonus
end
