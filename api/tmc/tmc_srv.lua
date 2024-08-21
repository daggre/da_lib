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

Lib.API.TMC.SendLetter = function(src, category, message, location, sender)
    TMC.Functions.TriggerEvent('SendLetOrTele', {
        client = src,
        type = 'letter',
        teletype = category,
        sender = sender,
        location = location,
        message = message,
    }, true)
end

