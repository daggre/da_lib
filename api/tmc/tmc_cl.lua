--- Copyright © 2024 Joshua Nelson

if Lib.API.Active ~= "TMC" then return; end
TMC = exports.core:getCoreObject()

local ItemCategories = {
    cig = { .cannabis, .cigarette, .rolledcigarette, },
    cigar = { .cigar, },
    nails = { .nails, },
    fenceRail = { .splitrail, },
    oyster = { .oyster, },
    clam = { .clam, },
    apple = { .apple, },
    bread = { .bread, },
    guitar = { .guitar, .attach_back_guitar, },
}

local ItemHasUses = {
    cigarette = "cigarettes",
    nails = "uses",
}

Lib.API.TMC.Eat = function(increaseAmount)
    increaseAmount = tonumber(increaseAmount) or 10
    local newHunger = LocalPlayer.state.metadata.hunger + increaseAmount
    TMC.Functions.TriggerServerEvent('TMC:Server:SetMetaData', 'hunger', newHunger)
end

---@diagnostic disable-next-line: duplicate-set-field
Lib.API.TMC.DependencyCheck = function(resourceName)
    return TMC.Common.IsDepRunning(resourceName)
end

Lib.API.TMC.Drink = function(increaseAmount)
    if increaseAmount then Lib.Log.Warn("DrinkWater doesn't take a value yet, implement this.") end
    local drinkType = "watersmall"
    TriggerEvent("consumeables:client:Water", drinkType)
    Lib.API.Notify("You slowly begin to feel more hydrated...", "success")
end

Lib.API.TMC.GetItems = function(filter)
    return TMC.Functions.GetItemsByPredicate(filter)
end

Lib.API.TMC.HasItem = function(itemName)
    return TMC.Functions.HasItem(itemName)
end

Lib.API.TMC.HasItems = function(items)
    return TMC.Functions.HasItems(items)
end

---@diagnostic disable-next-line: duplicate-set-field
Lib.API.TMC.Notify = function(message, type, time)
    TMC.Functions.SimpleNotify(message, type, time)
end

local ConsumeItem = function(name, slot, index, info)
    if not name or not slot or not index then
        Lib.Log.Warn("Could not find item to consume", name, slot, index)
        return
    end
    local chargeName = ItemHasUses[name]
    if chargeName and info and info[chargeName] and info[chargeName] > 1 then
        info[chargeName] = info[chargeName] - 1
        Lib.Net.AsyncCb("da_lib:consumeCharge", name, slot, index, info)
        return
    end
    Lib.Net.AsyncCb("da_lib:removeItem", name, 1, slot, index)
    return
end

Lib.API.TMC.Consume = function(name, data)
    name = data and data.name or name
    local slot = data and data.slot or nil
    local index = data and data.index or nil
    if data ~= nil and data.name and data.slot and data.index and data.info then
        ConsumeItem(data.name, data.slot, data.index, data.info)
        return
    end

    local items = nil
    if ItemCategories[name] then
        items = Lib.API.GetItems(function(item)
            return ItemCategories[name][item.name] and
                (not slot or slot and slot == item.slot) and
                (not index or index and index == item.index)
        end)
    else
        items = Lib.API.GetItems(function(item)
            return name == item.name and
                (not slot or slot and slot == item.slot) and
                (not index or index and index == item.index)
        end)
    end
    if items and next(items) then
        local _, itemData = next(items)
        ConsumeItem(itemData.name, itemData.slot, itemData.index, itemData.info)
        return
    end
end

Lib.API.TMC.PolyZoneEnterHandler = function(zoneId, cb)
    TMC.Functions.AddPolyZoneEnterHandler(zoneId, cb)
end

Lib.API.TMC.PolyZoneExitHandler = function(zoneId, cb)
    TMC.Functions.AddPolyZoneExitHandler(zoneId, cb)
end

Lib.API.TMC.PolyZoneCreateCircle = function(zoneId, coords, radius, options)
    return TMC.Functions.AddCircleZone(zoneId, coords, radius, options)
end

Lib.API.TMC.CreatePed = function(modelHash, coords, option)
    local pedId = "da_npc_"..option.id
    return TMC.Functions.CreateInteractionPed(pedId, {
        Hash = modelHash,
        Outfit = option.pedOutfit,
        Location = coords,
        Scenario = option.scenario,
        Frozen = option.frozen,
        Ai = option.ai,
    })
end
