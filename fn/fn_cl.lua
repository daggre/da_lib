--- Copyright © 2024 Joshua Nelson

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

---Automatically move the player to a set of coordinates
---@param ped integer the id of the entity/ped
---@param coords table vector3 coordinates to move to
---@param timeout number the amount of time in ms to wait for the task to complete
---@param forceCoords boolean whether to force the player to the coordinates
Lib.Fn.Move = function(ped, coords, timeout, forceCoords)
    local speed = 1.0
    local slideDistance = 0.3
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

-- TODO: Move this to chance lib
Lib.Fn.ChanceItem = function(itemName, amount, chance)
    if chance and chance < 100 then
        local chanceResult = math.random(100)
        if chanceResult <= chance then
            return Lib.Fn.AddItem(itemName, amount)
        end
    else
        return Lib.Fn.AddItem(itemName, amount)
    end
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
    SetCurrentPedWeapon(PlayerPedId(), `weapon_unarmed`, false, 0, false, false)
    Citizen.Wait(500)
end

Lib.Fn.Teleport = function(coords)
    if Lib.API.Active then
        return Lib.API.Teleport(coords)
    end
    Lib.Log.Debug(("API not active, local function '%s' not implemented"):format("Teleport"))
end
