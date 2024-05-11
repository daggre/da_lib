--- Copyright © 2024 Joshua Nelson

local API = Lib.API.Active

local isAPI = function() return API and Lib.API[API] end

Lib.API.Eat = function(increaseAmount)
    if not isAPI() then return; end
    Lib.API[API].Eat(increaseAmount)
end

---@diagnostic disable-next-line: duplicate-set-field
Lib.API.DependencyCheck = function(resourceName)
    if not isAPI() then return; end
    return Lib.API[API].DependencyCheck(resourceName)
end

Lib.API.Drink = function(increaseAmount)
    if not isAPI() then return; end
    Lib.API[API].Drink(increaseAmount)
end

Lib.API.Consume = function(name, data)
    if not isAPI() then return; end
    return Lib.API[API].Consume(name, data)
end

---@diagnostic disable-next-line: duplicate-set-field
Lib.API.ConsumeCharge = function(itemName, slot, index)
    if not isAPI() then return; end
    return Lib.Net.BlockingCb("da_lib:consumeCharge", 2000, itemName, slot, index)
end

---@diagnostic disable-next-line: duplicate-set-field
Lib.API.AddItem = function(itemName, amount, slot, slotIndex, isInternalMove)
    if not isAPI() then return; end
    return Lib.Net.BlockingCb("da_lib:addItem", 2000, itemName, amount, slot, slotIndex, isInternalMove)
end

Lib.API.GetItems = function(filter)
    if not isAPI() then return; end
    return Lib.API[API].GetItems(filter)
end

Lib.API.HasItem = function(itemName)
    if not isAPI() then return; end
    return Lib.API[API].HasItem(itemName)
end

Lib.API.HasItems = function(items)
    if not isAPI() then
        local hasItems = {}
        for itemName in pairs(items) do
            if not hasItems[itemName] then
                hasItems[itemName] = {}
            end
            -- No inventory so just return a large amount of everything
            table.insert(hasItems[itemName], { name = itemName, amount = 999 })
        end
        return hasItems
    end
    return Lib.API[API].HasItems(items)
end

---@diagnostic disable-next-line: duplicate-set-field
Lib.API.Notify = function(message, notifyType, time)
    if not isAPI() then
        Lib.Log.Info(message)
        return
    end
    Lib.API[API].Notify(message, notifyType, time)
end

Lib.API.SetItemMetadata = function(item, metadata)
    if not isAPI() then return; end
    TriggerServerEvent("da_lib:setItemMetadata", item, metadata)
end

---@diagnostic disable-next-line: duplicate-set-field
Lib.API.RemoveItem = function(itemName, amount, slot, slotIndex, isInternalMove)
    if not isAPI() then return; end
    return Lib.Net.BlockingCb("da_lib:removeItem", 2000, itemName, amount, slot, slotIndex, isInternalMove)
end

Lib.API.PolyZoneEnterHandler = function(zoneId, cb)
    if not isAPI() then return; end
    Lib.API[API].PolyZoneEnterHandler(zoneId, cb)
end

Lib.API.PolyZoneExitHandler = function(zoneId, cb)
    if not isAPI() then return; end
    Lib.API[API].PolyZoneExitHandler(zoneId, cb)
end

Lib.API.PolyZoneCreateCircle = function(zoneId, coords, radius, options)
    if not isAPI() then return; end
    return Lib.API[API].PolyZoneCreateCircle(zoneId, coords, radius, options)
end

Lib.API.PolyZoneCreateZone = function(zoneId, points, options)
    if not isAPI() then return; end
    return Lib.API[API].PolyZoneCreateZone(zoneId, points, options)
end

Lib.API.CreatePed = function(modelHash, coords, option)
    if not isAPI() then return; end
    return Lib.API[API].CreatePed(modelHash, coords, option)
end

Lib.API.PromptCreate = function(title, key)
    if not isAPI() then return; end
    return Lib.API[API].PromptCreate(title, key)
end

Lib.API.PromptHide = function(prompt)
    if not isAPI() then return; end
    return Lib.API[API].PromptHide(prompt)
end

Lib.API.PromptReset = function(prompt)
    if not isAPI() then return; end
    return Lib.API[API].PromptReset(prompt)
end

Lib.API.PromptUpdate = function(promptGroup, data, zoneData)
    if not isAPI() then return; end
    return Lib.API[API].PromptUpdate(promptGroup, data, zoneData)
end

Lib.API.PromptGroupCreate = function(title)
    if not isAPI() then return; end
    return Lib.API[API].PromptGroupCreate(title)
end

Lib.API.PromptGroupAddPrompt = function(promptGroup, prompt, data, zoneData)
    if not isAPI() then return; end
    return Lib.API[API].PromptGroupAddPrompt(promptGroup, prompt, data, zoneData)
end

Lib.API.PromptGroupHide = function(promptGroup)
    if not isAPI() then return; end
    return Lib.API[API].PromptGroupHide(promptGroup)
end

Lib.API.PromptGroupShow = function(promptGroup)
    if not isAPI() then return; end
    return Lib.API[API].PromptGroupShow(promptGroup)
end

Lib.API.PromptGroupSetTitle = function(promptGroup, title)
    if not isAPI() then return; end
    return Lib.API[API].PromptGroupSetTitle(promptGroup, title)
end

Lib.API.Teleport = function(coords)
    if not isAPI() then return; end
    return Lib.API[API].Teleport(coords)
end

Lib.API.RequestNPCAnimate = function(id, options)
    if not isAPI() then return; end
    TriggerServerEvent("da_lib:npcAnimate", id, options)
end

Lib.API.SetNPCAnimate = function(id, options)
    if not isAPI() then return; end
    return Lib.API[API].SetNPCAnimate(id, options)
end

Lib.API.IsJob = function(job, active)
    if not isAPI() then return; end
    return Lib.API[API].IsJob(job, active)
end

Lib.API.Inventory = function(type, id, data)
    if not isAPI() then return; end
    return Lib.API[API].Inventory(type, id, data)
end
