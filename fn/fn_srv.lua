--- Copyright © 2024 Joshua Nelson


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
Lib.Fn.ReplaceItem = function(src, removeItem, addItem)
    if Lib.API.Active then
        if Lib.API.RemoveItem(src, removeItem.name, removeItem.amount, removeItem.slot, removeItem.slotIndex) then
            Lib.API.AddItem(src, addItem.name, addItem.amount, addItem.slot, addItem.slotIndex)
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
