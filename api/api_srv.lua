--- Copyright © 2024 Joshua Nelson

local API = Lib.API.Active

local isAPI = function() return API and Lib.API[API] end

---@diagnostic disable-next-line: duplicate-set-field
Lib.API.AddItem = function(src, itemName, amount, slot, slotIndex, isInternalMove)
    if not isAPI() then return; end
    return Lib.API[API].AddItem(src, itemName, amount, slot, slotIndex, isInternalMove)
end

---@diagnostic disable-next-line: duplicate-set-field
Lib.API.RemoveItem = function(src, itemName, amount, slot, slotIndex, isInternalMove)
    if not isAPI() then return false; end
    return Lib.API[API].RemoveItem(src, itemName, amount, slot, slotIndex, isInternalMove)
end

Lib.Net.RegisterServerCb("da_lib:removeItem", function(src, itemName, itemData, amount, isInternalMove)
    return Lib.API[API].RemoveItem(src, itemName, itemData, amount, isInternalMove)
end)

Lib.Net.RegisterServerCb("da_lib:addItem", function(src, itemName, amount, slot, slotIndex, isInternalMove)
    return Lib.API[API].AddItem(src, itemName, amount, slot, slotIndex, isInternalMove)
end)

---@diagnostic disable-next-line: duplicate-set-field
Lib.API.Notify = function(src, message, notifyType, duration)
    Lib.API[API].Notify(src, message, notifyType, duration)
end

---@diagnostic disable-next-line: duplicate-set-field
Lib.API.ConsumeCharge = function(src, name, slot, index, info)
    if not isAPI() then return; end
    return Lib.API[API].ConsumeCharge(src, name, slot, index, info)
end

---@diagnostic disable-next-line: duplicate-set-field
Lib.API.DependencyCheck = function(resourceName)
    if not isAPI() then return; end
    return Lib.API[API].DependencyCheck(resourceName)
end

Lib.API.CreateUseableItem = function(src, itemName, fn)
    if not isAPI() then return; end
    return Lib.API[API].CreateUseableItem(src, itemName, fn)
end

Lib.API.IsCharMale = function(src)
    if not isAPI() then return; end
    return Lib.API[API].IsCharMale(src)
end

Lib.API.HasPermission = function(src, permission)
    if not isAPI() then return; end
    return Lib.API[API].HasPermission(src, permission)
end

Lib.Net.RegisterServerCb("da_lib:consumeCharge", function(src, name, slot, index, info)
    return Lib.API.ConsumeCharge(src, name, slot, index, info)
end)

RegisterServerEvent("da_lib:setItemMetadata")
AddEventHandler("da_lib:setItemMetadata", function(item, metadata)
    if not isAPI() then return; end
    local src = source
    Lib.API[API].SetItemMetadata(src, item, metadata)
end)

RegisterServerEvent("da_lib:npcAnimate")
AddEventHandler("da_lib:npcAnimate", function(id, options)
    TriggerClientEvent("da_lib:npc:animate", -1, id, options)
end)

RegisterServerEvent("da_lib:addSkill")
AddEventHandler("da_lib:addSkill", function(skill, amount)
    if not isAPI() then return; end
    local src = source
    Lib.API[API].AddSkill(src, skill, amount)
end)

RegisterServerEvent("da_lib:setSkill")
AddEventHandler("da_lib:setSkill", function(skill, amount)
    if not isAPI() then return; end
    local src = source
    Lib.API[API].SetSkill(src, skill, amount)
end)

Lib.API.SendTelegram = function(src, category, message, location, sender)
    if not isAPI() then return; end
    return Lib.API[API].SendTelegram(src, category, message, location, sender)
end

Lib.API.SendLetter = function(src, category, message, location, sender)
    if not isAPI() then return; end
    return Lib.API[API].SendLetter(src, category, message, location, sender)
end

Lib.API.GetPlayerUniqueId = function(src)
    if not isAPI() then return; end
    return Lib.API[API].GetPlayerUniqueId(src)
end

Lib.API.GetItemLabel = function(item)
    if not isAPI() then return; end
    return Lib.API[API].GetItemLabel(item)
end

---@diagnostic disable-next-line: duplicate-set-field
Lib.API.SetDoorStatus = function(data, attribute, status)
    if not isAPI() then return; end
    Lib.API[API].SetDoorStatus(data, attribute, status)
end

---@diagnostic disable-next-line: duplicate-set-field
Lib.API.IsJob = function(src, job, active)
    if not isAPI() then return true; end
    return Lib.API[API].IsJob(src, job, active)
end

Lib.API.MinimumPolice = function(minAmount, active)
    if not isAPI() then return true; end
    return Lib.API[API].MinimumPolice(minAmount, active)
end

Lib.API.IsCrimeAllowed = function()
    if not isAPI() then return true; end
    return Lib.API[API].IsCrimeAllowed()
end
