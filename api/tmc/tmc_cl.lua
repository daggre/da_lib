--- Copyright © 2024 Joshua Nelson

if Lib.API.Active ~= "TMC" then return; end
TMC = exports.core:getCoreObject()

local ItemCategories = {
    cig = { cannabis = true, cigarette = true, rolledcigarette = true, },
    cigar = { cigar = true, },
    nails = { nails = true, },
    fenceRail = { splitrail = true, },
    oyster = { oyster = true, },
    clam = { clam = true, },
    apple = { apple = true, },
    bread = { bread = true, },
    guitar = { guitar = true, attach_back_guitar = true, },
    pipetobac = { pipetobacco = true, finetobacco = true, },

}

local ItemHasUses = {
    cigarette = "cigarettes",
    nails = "uses",
    pipetobacco = "tobacco",
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

Lib.API.TMC.SetDoorStatus = function(data, attribute, status)
    TMC.Functions.TriggerServerEvent("doorlocks:server:updateDamageStatus", data, { [attribute] = status })
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
    if data and data.name and data.name ~= name then
        -- Bad data, clear it and move on as if none was sent
        data = nil
    end
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

Lib.API.TMC.PolyZoneCreateZone = function(zoneId, points, options)
    assert(options.minZ, "PolyZoneCreateZone: minZ is required")
    assert(options.maxZ, "PolyZoneCreateZone: maxZ is required")
    assert(options.minZ < options.maxZ, "PolyZoneCreateZone: minZ must be less than maxZ")
    return TMC.Functions.AddPolyZone(zoneId, points, options)
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

Lib.API.TMC.PromptCreate = function(title, key)
    return TMC.Functions.CreatePrompt(title, key, 99999)
end

Lib.API.TMC.PromptHide = function(prompt)
    TMC.Functions.RemovePromptFromGroup(prompt)
end

Lib.API.TMC.PromptUpdate = function(promptGroup, data, zoneData)
    if data.title then TMC.Functions.UpdatePromptText(promptGroup, data.title) end
    if data.key and data.fn then TMC.Functions.UpdatePromptComplete(promptGroup, data.key, function() data.fn(zoneData) end) end
end

Lib.API.TMC.PromptUpdateText = function(promptGroup, key, text)
    TMC.Functions.UpdatePromptText(promptGroup, key, text)
end

Lib.API.TMC.PromptReset = function(promptGroup)
    TMC.Functions.RemoveAllPromptsFromPromptGroup(promptGroup)
end

Lib.API.TMC.PromptGroupCreate = function(title)
    return TMC.Functions.CreatePromptGroup(title, {})
end

Lib.API.TMC.PromptGroupAddPrompt = function(promptGroup, prompt, data, zoneData)
    Lib.Log.Debug("Adding prompt to group", promptGroup, prompt, data.key, zoneData)
    TMC.Functions.AddPromptToGroup(prompt, data.key, promptGroup, function() data.onTrigger(zoneData) end)
end

Lib.API.TMC.PromptGroupHide = function(promptGroup)
    TMC.Functions.HidePromptGroup(promptGroup)
end

Lib.API.TMC.PromptGroupShow = function(promptGroup)
    Lib.Log.Debug("Showing prompt group", promptGroup)
    TMC.Functions.ShowPromptGroup(promptGroup)
end

Lib.API.TMC.PromptGroupSetTitle = function(promptGroup, title)
    TMC.Functions.UpdatePromptGroupTitle(promptGroup, title)
end

Lib.API.TMC.Teleport = function(coords)
    TMC.Functions.TeleportToCoords(coords)
end

Lib.API.TMC.SetNPCAnimate = function(key, options)
    Lib.Log.Debug("Setting NPC animate", key, options)
    Lib.Log.Debug("fn", TMC.Functions.ChangePedOptions)
    TMC.Functions.ChangePedOptions(key, options)
end

---Check if the player has a specific job or job category
---@param job string
---@param active boolean|nil
---@return boolean
Lib.API.TMC.IsJob = function(job, active)
    local jobMap = {
        any = { "judge", "stategovt", "attorneygeneral", "doctor", "leo", "dop", "conductor", "rancher", "gunsmith" },
        good = { "leo", "dop", "judge", "stategovt", "attorneygeneral", },
        gov = { "judge", "stategovt", "attorneygeneral" },
        medical = { "doctor", },
        police = { "leo", "dop" },
        train = { "conductor", }
    }

    if jobMap[job] then
        for _,v in ipairs(jobMap[job]) do
            if active and TMC.Functions.HasJob(v) and TMC.Functions.IsOnDuty(v) then
                return true
            elseif not active and TMC.Functions.HasJob(v) then
                return true
            end
        end
        return false
    end

    return TMC.Functions.HasJob(job) and not active or TMC.Functions.IsOnDuty(job) ~= false
end

Lib.API.TMC.Inventory = function(type, id, data)
    TMC.Functions.TriggerServerEvent("inventory:server:openInventory", type, id, data)
end

