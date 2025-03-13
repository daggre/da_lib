if DAAPI.ActiveFramework ~= "TMC" then return; end
log.debug("Setting up Framework API: " .. DAAPI.ActiveFramework)
local FW = {}
local TMC = exports.core:getCoreObject()
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

FW.addItem = function(itemName, amount, slot, slotIndex, isInternalMove)
    return TriggerBlockingServerEvent("da_lib:addItem", 2000, itemName, amount, slot, slotIndex, isInternalMove)
end

FW.removeItem = function(itemName, amount, slot, slotIndex, isInternalMove)
    return TriggerBlockingServerEvent("da_lib:removeItem", 2000, itemName, amount, slot, slotIndex, isInternalMove)
end

FW.replaceItem = function(removeItem, addItem, isInternalMove)
    if FW.removeItem(removeItem.name, removeItem.amount, removeItem.slot, removeItem.slotIndex, isInternalMove) then
        FW.addItem(addItem.name, addItem.amount, addItem.slot, addItem.slotIndex, isInternalMove)
    end
end

FW.eat = function(increaseAmount)
    increaseAmount = tonumber(increaseAmount) or 10
    local newHunger = LocalPlayer.state.metadata.hunger + increaseAmount
    TMC.Functions.TriggerServerEvent('TMC:Server:SetMetaData', 'hunger', newHunger)
end

---@diagnostic disable-next-line: duplicate-set-field
FW.checkDepends = function(resourceName)
    return TMC.Common.IsDepRunning(resourceName)
end

FW.drink = function(increaseAmount)
    if increaseAmount then log.warn("DrinkWater doesn't take a value yet, implement this.") end
    local drinkType = "watersmall"
    TriggerEvent("consumeables:client:Water", drinkType)
    API.notify("You slowly begin to feel more hydrated...", "success")
end

FW.getItems = function(filter)
    return TMC.Functions.GetItemsByPredicate(filter)
end

FW.hasItem = function(itemName)
    return TMC.Functions.HasItem(itemName)
end

FW.hasItems = function(items)
    return TMC.Functions.HasItems(items)
end

---@diagnostic disable-next-line: duplicate-set-field
FW.setDoorStatus = function(data, attribute, status)
    TMC.Functions.TriggerServerEvent("doorlocks:server:updateDamageStatus", data, { [attribute] = status })
end

---@diagnostic disable-next-line: duplicate-set-field
FW.notify = function(message, type, time)
    TMC.Functions.SimpleNotify(message, type, time)
end

local ConsumeItem = function(name, slot, index, info)
    if not name or not slot or not index then
        log.warn("Could not find item to consume", name, slot, index)
        return
    end
    local chargeName = ItemHasUses[name]
    if chargeName and info and info[chargeName] and info[chargeName] > 1 then
        info[chargeName] = info[chargeName] - 1
        Lib.Net.AsyncCb("da_lib:consumeCharge", name, slot, index, info)
        return
    end
    Lib.Net.AsyncCb("da_lib:removeItem", name, 1, slot, index)
end

FW.consume = function(name, data)
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
        items = API.getItems(function(item)
            return ItemCategories[name][item.name] and
                (not slot or slot and slot == item.slot) and
                (not index or index and index == item.index)
        end)
    else
        items = API.getItems(function(item)
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

FW.polyZoneEnterHandler = function(zoneId, cb)
    TMC.Functions.AddPolyZoneEnterHandler(zoneId, cb)
end

FW.polyZoneExitHandler = function(zoneId, cb)
    TMC.Functions.AddPolyZoneExitHandler(zoneId, cb)
end

FW.polyZoneCreateCircle = function(zoneId, coords, radius, options)
    return TMC.Functions.AddCircleZone(zoneId, coords, radius, options)
end

FW.polyZoneCreateZone = function(zoneId, points, options)
    assert(options.minZ, "PolyZoneCreateZone: minZ is required")
    assert(options.maxZ, "PolyZoneCreateZone: maxZ is required")
    assert(options.minZ < options.maxZ, "PolyZoneCreateZone: minZ must be less than maxZ")
    return TMC.Functions.AddPolyZone(zoneId, points, options)
end

FW.createPed = function(modelHash, coords, option)
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

FW.promptCreate = function(title, key)
    return TMC.Functions.CreatePrompt(title, key, 99999)
end

FW.promptHide = function(prompt)
    TMC.Functions.RemovePromptFromGroup(prompt)
end

FW.promptUpdate = function(promptGroup, data, zoneData)
    if data.title then TMC.Functions.UpdatePromptText(promptGroup, data.title) end
    if data.key and data.fn then TMC.Functions.UpdatePromptComplete(promptGroup, data.key, function() data.fn(zoneData) end) end
end

FW.promptUpdateText = function(promptGroup, key, text)
    TMC.Functions.UpdatePromptText(promptGroup, key, text)
end

FW.promptReset = function(promptGroup)
    TMC.Functions.RemoveAllPromptsFromPromptGroup(promptGroup)
end

FW.promptGroupCreate = function(title)
    return TMC.Functions.CreatePromptGroup(title, {})
end

FW.promptGroupAddPrompt = function(promptGroup, prompt, data, zoneData)
    log.debug("Adding prompt to group", promptGroup, prompt, data.key, zoneData)
    TMC.Functions.AddPromptToGroup(prompt, data.key, promptGroup, function() data.onTrigger(zoneData) end)
end

FW.promptGroupHide = function(promptGroup)
    TMC.Functions.HidePromptGroup(promptGroup)
end

FW.promptGroupShow = function(promptGroup)
    log.debug("Showing prompt group", promptGroup)
    TMC.Functions.ShowPromptGroup(promptGroup)
end

FW.promptGroupSetTitle = function(promptGroup, title)
    TMC.Functions.UpdatePromptGroupTitle(promptGroup, title)
end

FW.teleport = function(coords)
    TMC.Functions.TeleportToCoords(coords)
end

FW.isDead = function()
    return LocalPlayer.state.metadata.isdead
end

FW.setNPCAnimate = function(key, options)
    log.debug("Setting NPC animate", key, options)
    log.debug("fn", TMC.Functions.ChangePedOptions)
    TMC.Functions.ChangePedOptions(key, options)
end

---Check if the player has a specific job or job category
---@param job string
---@param active boolean|nil
---@return boolean
---@diagnostic disable-next-line: duplicate-set-field
FW.hasJob = function(job, active)
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

FW.inventory = function(type, id, data)
    TMC.Functions.TriggerServerEvent("inventory:server:openInventory", type, id, data)
end

DAAPI.Framework = FW
