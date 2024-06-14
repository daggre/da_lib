--- Copyright © 2024 Joshua Nelson

---Add an enter handler for polyzone id
---@param zoneId string The zone id
---@param cb function The callback function to be called on entry
Lib.PolyZone.OnEnter = function(zoneId, cb)
    if Lib.API.Active then
        Lib.API.PolyZoneEnterHandler(zoneId, cb)
        return
    end
    Lib.Log.Debug(("API not active, local function '%s' not implemented"):format("PolyZone.OnEnter"))
end

---Add an exit handler for polyzone id
---@param zoneId string The zone id
---@param cb function The callback function to be called on exit
Lib.PolyZone.OnExit = function(zoneId, cb)
    if Lib.API.Active then
        Lib.API.PolyZoneExitHandler(zoneId, cb)
        return
    end
    Lib.Log.Debug(("API not active, local function '%s' not implemented"):format("PolyZone.OnExit"))
end

---Create a circle polyzone
---@param zoneId string The zone id
---@param coords table The center coordinates of the circle
---@param radius number The radius of the circle
---@param options table The creation options for the circle
---@return unknown|nil handle The created polyzone's handle
Lib.PolyZone.Circle = function(zoneId, coords, radius, options)
    if Lib.API.Active then
        return Lib.API.PolyZoneCreateCircle(zoneId, coords, radius, options)
    end
    Lib.Log.Debug(("API not active, local function '%s' not implemented"):format("PolyZone.Circle"))
end

---Create a polyzone with custom border points
---@param zoneId string The zone id
---@param points table The points of the polyzone's border
---@param options table The creation options for the polyzone
---@return unknown|nil handle The created polyzone's handle
Lib.PolyZone.Custom = function(zoneId, points, options)
    if Lib.API.Active then
        return Lib.API.PolyZoneCreateZone(zoneId, points, options)
    end
    Lib.Log.Debug(("API not active, local function '%s' not implemented"):format("PolyZone.Custom"))
end
