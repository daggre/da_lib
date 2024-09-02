--- Copyright © 2024 Joshua Nelson

if Lib.API.Active ~= "TMC" then return; end
TMC = exports.core:getCoreObject()

---@diagnostic disable-next-line: duplicate-set-field
Lib.API.TMC.AddItem = function(src, itemName, amount, slot, slotIndex, isInternalMove)
    local player = TMC.Functions.GetPlayer(src)
    return player.Functions.AddItem(itemName, amount, slot, slotIndex, isInternalMove)
end

---@diagnostic disable-next-line: duplicate-set-field
Lib.API.TMC.RemoveItem = function(src, itemName, amount, slot, slotIndex, isInternalMove)
    local player = TMC.Functions.GetPlayer(src)
    return player.Functions.RemoveItem(itemName, amount or 1, slot, slotIndex, isInternalMove)
end

---@diagnostic disable-next-line: duplicate-set-field
Lib.API.TMC.Notify = function(src, message, notifyType, duration)
    TMC.Functions.SimpleNotify(src, message, notifyType, duration)
end

Lib.API.TMC.ConsumeCharge = function(src, itemName, slot, index, info)
    assert(itemName, "name was nil "..Lib.String.Format(itemName, slot))
    assert(slot, "slot invalid "..Lib.String.Format(itemName, slot))
    assert(index, "index invalid "..Lib.String.Format(itemName, slot))
    assert(info, "info invalid "..Lib.String.Format(itemName, slot))

    local amount = 1
    local player = TMC.Functions.GetPlayer(src)
    local slotItems = player.Functions.GetItemBySlot(slot)
    local item = slotItems and slotItems[next(slotItems)] or nil
    if not item then return false; end

    player.Functions.UpdateItemInfo(slot, index, info)
    TriggerClientEvent("inventory:client:ItemBox", src, item.name, "use", amount)
    return true
end

---@diagnostic disable-next-line: duplicate-set-field
Lib.API.TMC.DependencyCheck = function(resourceName)
    return TMC.Common.IsDepRunning(resourceName)
end

Lib.API.TMC.SetItemMetadata = function(src, item, metadata)
    local player = TMC.Functions.GetPlayer(src)
    local updateItem = false
    if not player then return; end

    local slotItems = player.Functions.GetItemBySlot(item.slot)
    for index, indexItem in ipairs(slotItems) do
        if item.index == index then
            tmcItem = indexItem
            break
        end
    end

    if not tmcItem then
        Lib.Log.Debug("Could not find item in slot", item.name, item.slot, item.index)
        return
    end

    if tmcItem and tmcItem.name == item.name then
        if not tmcItem.info or type(tmcItem.info) == "string" then tmcItem.info = {}; end

        for key, value in pairs(metadata) do
            tmcItem.info[key] = value
            updateItem = true
        end

        if updateItem then
            player.Functions.UpdateItemInfo(item.slot, item.index, tmcItem.info)
        end
    end
end

Lib.API.TMC.CreateUseableItem = function(src, itemName, fn)
    TMC.Functions.CreateUseableItem(src, itemName, fn)
end

Lib.API.TMC.IsCharMale = function(src)
    local player = TMC.Functions.GetPlayer(src)
    if player and player.PlayerData and player.PlayerData.charinfo and player.PlayerData.charinfo.gender ~= nil then
        return player.PlayerData.charinfo.gender == 0
    end
    -- If we dont know, then just return male
    return true
end

Lib.API.TMC.HasPermission = function(src, level)
    return TMC.Functions.HasPermission(src, level)
end

Lib.API.TMC.AddSkill = function(src, skill, amount)
    local player = TMC.Functions.GetPlayer(src)
    if player then
        player.Functions.AddReputation(skill, amount)
    end
end

Lib.API.TMC.SetSkill = function(src, skill, amount)
    local player = TMC.Functions.GetPlayer(src)
    if player then
        player.Functions.SetReputation(skill, amount)
    end
end

Lib.API.TMC.SendTelegram = function(src, category, message, location, sender)
    TMC.Functions.TriggerEvent('SendLetOrTele', {
        client = src,
        type = 'telegram',
        teletype = category,
        sender = sender,
        location = location,
        message = message,
    }, true)
end

Lib.API.TMC.SendLetter = function(src, receiver, message, sender)
    TMC.Functions.TriggerEvent('SendLetOrTele', {
        client = src,
        type = 'letter',
        sender = sender,
        receiver = receiver,
        message = message,
    }, true)
end

Lib.API.TMC.GetPlayerUniqueId = function(src)
    local player = TMC.Functions.GetPlayer(src)
    if player then
        return player.PlayerData.citizenid
    end
end

Lib.API.TMC.GetItemLabel = function(item)
    return TMC.Shared.Items[item] and TMC.Shared.Items[item].label or item
end

---@diagnostic disable-next-line: duplicate-set-field
Lib.API.TMC.SetDoorStatus = function(data, attribute, status)
    TMC.Functions.TriggerEvent("doorlocks:server:updateDamageStatus", data, { [attribute] = status })
end

---Check if the player has a specific job or job category
---@param src integer Player source
---@param job string
---@param active boolean|nil
---@return boolean
---@diagnostic disable-next-line: duplicate-set-field
Lib.API.TMC.IsJob = function(src, job, active)
    local player = TMC.Functions.GetPlayer(src)
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
            if active and player.Functions.HasJob(v) and player.Functions.IsOnDuty(v) then
                return true
            elseif not active and TMC.Functions.HasJob(v) then
                return true
            end
        end
        return false
    end

    return player.Functions.HasJob(job) and not active or player.Functions.IsOnDuty(job) ~= false
end

Lib.API.TMC.MinimumPolice = function(minAmount, active)
    active = active ~= nil or true
    local numCopsOnDuty = 0
    for _, player in pairs(TMC.Functions.GetPlayers()) do
        if Lib.API.TMC.IsJob(player, "leo", active) then numCopsOnDuty = numCopsOnDuty + 1; end
        if numCopsOnDuty >= minAmount then return true; end
    end
    return numCopsOnDuty >= minAmount
end

Lib.API.TMC.IsCrimeAllowed = function()
    return true
end
