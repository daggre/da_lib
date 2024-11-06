log.debug("Initializing Framework API Server Defaults")
local FW = {}

---@diagnostic disable-next-line: duplicate-set-field
FW.notify = function(src, message, notifyType, duration)
    log.info({
        src = src,
        message = message,
        notifyType = notifyType,
        duration = duration,
    })
    TriggerClientEvent("notify", src, message, notifyType, duration)
end

FW.createUseableItem = function()
    return true
end

FW.removeItem = function(src, itemName, amount, slot, slotIndex, isInternalMove)
    return false
end

---@diagnostic disable-next-line: duplicate-set-field
FW.hasJob = function(src, job, active)
    return true
end

FW.minPolice = function(minAmount, active)
    return true
end

FW.isCrimeAllowed = function()
    return true
end

RegisterBlockingServerEvent("da_lib:removeItem", function(src, itemName, itemData, amount, isInternalMove)
    return API.removeItem(src, itemName, itemData, amount, isInternalMove)
end)

RegisterBlockingServerEvent("da_lib:addItem", function(src, itemName, amount, slot, slotIndex, isInternalMove)
    return API.addItem(src, itemName, amount, slot, slotIndex, isInternalMove)
end)

RegisterBlockingServerEvent("da_lib:consumeCharge", function(src, name, slot, index, info)
    return API.consumeCharge(src, name, slot, index, info)
end)

RegisterServerEvent("da_lib:setItemMetadata")
AddEventHandler("da_lib:setItemMetadata", function(itemData, metadata)
    local src = source
    API.setItemMetadata(src, itemData, metadata)
end)

RegisterServerEvent("da_lib:npcAnimate")
AddEventHandler("da_lib:npcAnimate", function(id, options)
    TriggerClientEvent("da_lib:npc:animate", -1, id, options)
end)

RegisterServerEvent("da_lib:addSkill")
AddEventHandler("da_lib:addSkill", function(skill, amount)
    local src = source
    API.addSkill(src, skill, amount)
end)

RegisterServerEvent("da_lib:setSkill")
AddEventHandler("da_lib:setSkill", function(skill, amount)
    local src = source
    API.setSkill(src, skill, amount)
end)

DAAPI.Default = FW
