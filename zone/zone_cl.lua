--- Copyright © 2024 Joshua Nelson

---Zone cache
InZone = {}

---Get the first zone matching the condition
---@param condition function
---@return table|nil
Lib.Zone.Get = function(condition)
    for _, zoneData in ipairs(InZone) do
        if condition(zoneData) then
            return zoneData
        end
    end
    return nil
end

---Collect data from all zones
---@param collectFn function
---@param data table
---@return table
Lib.Zone.Collect = function(collectFn, data)
    for _, zoneData in ipairs(InZone) do
        data = collectFn(zoneData, data)
    end
    return data
end

---Get all zones that meet the condition
---@param condition function
---@return table|nil
Lib.Zone.Filter = function(condition)
    local filteredZones = {}
    for _, zoneData in ipairs(InZone) do
        if condition(zoneData) then
            table.insert(filteredZones, zoneData)
        end
    end
    return #filteredZones > 0 and filteredZones or nil
end

---Add a zone
---@param zoneData table
Lib.Zone.Add = function(zoneData)
    table.insert(InZone, zoneData)
end

---Remove zones based on the conditions and return the number of zones removed
---@param condition function The condition to remove zones
---@return integer|boolean removedZones The number of zones removed
Lib.Zone.Remove = function(condition)
    local zonesRemoved = 0
    for i, zoneData in ipairs(InZone) do
        if condition(zoneData) then
            table.remove(InZone, i)
            zonesRemoved = zonesRemoved + 1
        end
    end
    return zonesRemoved > 0 and zonesRemoved or false
end

---Update zones based on the conditions and return the number of zones updated
---@param condition function The condition to match and update zones
---@param t table The table of values to update
---@return boolean|integer zonesUpdated The number of zones updated
Lib.Zone.Update = function(condition, t)
    local updated = 0
    for _, zoneData in ipairs(InZone) do
        if condition(zoneData) then
            updated = updated + 1
            for k, v in pairs(t) do
                zoneData[k] = v
            end
        end
    end
    return updated > 0 and updated or false
end

-- Add the zone to the cache when entering
RegisterNetEvent("interactionZone:enter")
AddEventHandler("interactionZone:enter", function(zoneData)
    Lib.Zone.Add(zoneData)
    Lib.Log.Debug("Entered zone: " .. zoneData.id)
end)

-- Remove the zone from the cache when exiting
RegisterNetEvent("interactionZone:exit")
AddEventHandler("interactionZone:exit", function(zoneData)
    local zonesRemoved = Lib.Zone.Remove(function(data)
        return data.id == zoneData.id
    end)
    Lib.Log.Debug("Exited zone: " .. zoneData.id)
    Lib.Log.Debug(("Removed %s zone(s) with id: %s"):format(zonesRemoved, zoneData.id))
end)

if Lib.Util.IsDev then
    RegisterCommand("dalib_zone_dump", function(source, args, rawCommand)
        Lib.Log.Debug("Dumping zones...")
        for _, zoneData in ipairs(InZone) do
            Lib.Log.Debug(zoneData.id)
            for k,v in pairs(zoneData) do
                Lib.Log.Debug("  " .. k .. ": " .. Lib.String.Format(v))
            end
        end
    end, false)

    RegisterCommand("dalib_zone_clear", function(source, args, rawCommand)
        Lib.Log.Debug("Clearing zones...")
        InZone = {}
    end, false)
end
