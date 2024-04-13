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
    assert(itemName, "name was nil "..Lib.String.Format(itemName, slot, index, info))
    assert(slot, "slot invalid "..Lib.String.Format(itemName, slot, index, info))
    assert(index, "index invalid "..Lib.String.Format(itemName, slot, index, info))
    assert(info, "info invalid "..Lib.String.Format(itemName, slot, index, info))

    local amount = 1
    local player = TMC.Functions.GetPlayer(src)
    local slotItems = player.Functions.GetItemBySlot(slot)
    local item = slotItems and slotItems[next(slotItems)] or nil
    if not item then return false; end

    player.Functions.UpdateItemInfo(slot, index, info)
    TriggerClientEvent("inventory:client:ItemBox", src, item.name, "use", amount)
    return true
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
