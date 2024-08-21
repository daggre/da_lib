--- Copyright © 2024 Joshua Nelson

---Check if the client has the permission level
---@param level string Permission level
---@return unknown|nil success true if the client has the permission level
---@diagnostic disable-next-line: duplicate-set-field
Lib.Fn.HasPermission = function(level)
    Lib.Log.Debug(("Checking %s permission"):format(level))
    return Lib.Net.BlockingCb("da_lib:checkPerm", 3000, level)
end

---Adjust the hunger status of the player
---@param amount integer the amount to adjust the hunger by (positive values decrease hunger)
Lib.Fn.Eat = function(amount)
    if Lib.API.Active then
        Lib.API.Eat(amount)
        return
    end
    Lib.Log.Debug(("API not active, local function '%s' not implemented"):format("Eat"))
end

--- Event handler for calling the Eat functionality
RegisterNetEvent("da_lib:eat")
AddEventHandler("da_lib:eat", function(increaseAmount)
    Lib.Fn.Eat(increaseAmount)
end)

---Adjust the thirst status of the player
---@param amount integer the amount to adjust the thirst by (positive values decrease thirst)
Lib.Fn.Drink = function(amount)
    if Lib.API.Active then
        Lib.API.Drink(amount)
        return
    end
    Lib.Log.Debug(("API not active, local function '%s' not implemented"):format("Drink"))
end

---Face the ped towards a direction
---@param ped any
---@param coords any
---@param timeout any
Lib.Fn.Face = function(ped, coords, timeout)
    TaskTurnPedToFaceCoord(ped, coords.xyz, timeout)
    Citizen.Wait(timeout)
end

---Automatically move the player to a set of coordinates
---@param ped integer the id of the entity/ped
---@param coords table vector3 coordinates to move to
---@param timeout number the amount of time in ms to wait for the task to complete
---@param forceCoords boolean whether to force the player to the coordinates
---@param speed number|nil the speed of the movement
---@param slideDistance number|nil the distance to slide the player
Lib.Fn.Move = function(ped, coords, timeout, forceCoords, speed, slideDistance)
    speed = speed or 1.0
    slideDistance = slideDistance or 0.3
    TaskGoStraightToCoord(ped, coords.xyz, speed, timeout, coords.w, slideDistance)
    Citizen.Wait(timeout)
    if forceCoords then
		SetEntityCoords(ped, coords.xyz)
		SetEntityHeading(ped, coords.w)
    end
end

Lib.Fn.Consume = function(name, data)
    if Lib.API.Active then
        return Lib.API.Consume(name, data)
    end
    Lib.Log.Debug(("API not active, local function '%s' not implemented"):format("Consume"))
end

Lib.Fn.ChanceItem = function(...)
    -- TODO: Deprecate this function
    Lib.Log.Warn("Lib.Fn.ChanceItem is deprecated, use Lib.Chance.Item")
    return Lib.Chance.Item(...)
end

---@diagnostic disable-next-line: duplicate-set-field
Lib.Fn.AddItem = function(itemName, amount, slot, slotIndex, isInternalMove)
    if Lib.API.Active then
        return Lib.API.AddItem(itemName, amount, slot, slotIndex, isInternalMove)
    end
    Lib.Log.Debug(("API not active, local function '%s' not implemented"):format("AddItem"))
end

---@diagnostic disable-next-line: duplicate-set-field
Lib.Fn.RemoveItem = function(itemName, amount, slot, slotIndex, isInternalMove)
    if Lib.API.Active then
        return Lib.API.RemoveItem(itemName, amount, slot, slotIndex, isInternalMove)
    end
    Lib.Log.Debug(("API not active, local function '%s' not implemented"):format("RemoveItem"))
end

---@diagnostic disable-next-line: duplicate-set-field
Lib.Fn.ReplaceItem = function(removeItem, addItem, isInternalMove)
    if Lib.API.Active then
        if Lib.API.RemoveItem(removeItem.name, removeItem.amount, removeItem.slot, removeItem.slotIndex, isInternalMove) then
            return Lib.API.AddItem(addItem.name, addItem.amount, addItem.slot, addItem.slotIndex, isInternalMove)
        end
    end
    Lib.Log.Debug(("API not active, local function '%s' not implemented"):format("ReplaceItem"))
end

Lib.Fn.HolsterWeapon = function()
    -- if Lib.API.Active then
    --     return Lib.API.HolsterWeapon()
    -- end
    local playerPedId = PlayerPedId()
    for _, handAttachPoint in pairs({0,1}) do
        local hasWeap, weapon = GetCurrentPedWeapon(playerPedId, true, handAttachPoint)
        if hasWeap and weapon ~= `weapon_unarmed` then
            SetCurrentPedWeapon(playerPedId, `weapon_unarmed`, true, handAttachPoint, false, false)
            Citizen.Wait(200)
            return
        end
    end
end

Lib.Fn.Teleport = function(coords)
    if Lib.API.Active then
        return Lib.API.Teleport(coords)
    end
    Lib.Log.Debug(("API not active, local function '%s' not implemented"):format("Teleport"))
end

