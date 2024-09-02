--- Copyright © 2024 Joshua Nelson

Lib.Net.RegisterServerCb("da_lib:checkPerm", function(src, level)
    local success = Lib.API.HasPermission(src, level)
    Lib.Log.Debug(("%s checking %s perm: %s"):format(src, level, success))
    return success
end)

---@diagnostic disable-next-line: duplicate-set-field
Lib.Fn.AddItem = function(src, itemName, amount, slot, slotIndex)
    if Lib.API.Active then
        return Lib.API.AddItem(src, itemName, amount, slot, slotIndex)
    end
    Lib.Log.Debug(("API not active, local function '%s' not implemented"):format("AddItem"))
end

---@diagnostic disable-next-line: duplicate-set-field
Lib.Fn.RemoveItem = function(src, itemName, amount, slot, slotIndex)
    if Lib.API.Active then
        return Lib.API.RemoveItem(src, itemName, amount, slot, slotIndex)
    end
    Lib.Log.Debug(("API not active, local function '%s' not implemented"):format("RemoveItem"))
end

---@diagnostic disable-next-line: duplicate-set-field
Lib.Fn.ReplaceItem = function(src, removeItem, addItem, isInternalMove)
    if Lib.API.Active then
        if Lib.API.RemoveItem(src, removeItem.name, removeItem.amount, removeItem.slot, removeItem.slotIndex, isInternalMove) then
            return Lib.API.AddItem(src, addItem.name, addItem.amount, addItem.slot, addItem.slotIndex, isInternalMove)
        end
    end
    Lib.Log.Debug(("API not active, local function '%s' not implemented"):format("ReplaceItem"))
end

Lib.Fn.IsMale = function(src)
    if Lib.API.Active then
        return Lib.API.IsCharMale(src)
    end
    Lib.Log.Debug(("API not active, local function '%s' not implemented"):format("IsMale"))
end

Lib.Fn.HasPermission = function(src, level)
    if Lib.API.Active then
        return Lib.API.HasPermission(src, level)
    end
    return true
end

Lib.Fn.SendTelegram = function(src, category, message, location, sender)
    if Lib.API.Active then
        return Lib.API.SendTelegram(src, category, message, location, sender)
    end
    Lib.Log.Debug(("API not active, local function '%s' not implemented"):format("SendTelegram"))
end

Lib.Fn.SendLetter = function(src, receiver, message, sender)
    if Lib.API.Active then
        return Lib.API.SendLetter(src, receiver, message, sender)
    end
    Lib.Log.Debug(("API not active, local function '%s' not implemented"):format("SendLetter"))
end

