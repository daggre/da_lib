--- Copyright © 2024 Joshua Nelson

---Add an enter handler for polyzone id
---@param zoneId string The zone id
---@param cb function The callback function to be called on entry
PolyZone.OnEnter = function(zoneId, cb)
    API.polyZoneEnterHandler(zoneId, cb)
end

---Add an exit handler for polyzone id
---@param zoneId string The zone id
---@param cb function The callback function to be called on exit
PolyZone.OnExit = function(zoneId, cb)
    API.polyZoneExitHandler(zoneId, cb)
end

---Create a circle polyzone
---@param zoneId string The zone id
---@param coords table The center coordinates of the circle
---@param radius number The radius of the circle
---@param options table The creation options for the circle
---@return unknown|nil handle The created polyzone's handle
PolyZone.Circle = function(zoneId, coords, radius, options)
    return API.polyZoneCreateCircle(zoneId, coords, radius, options)
end

---Create a polyzone with custom border points
---@param zoneId string The zone id
---@param points table The points of the polyzone's border
---@param options table The creation options for the polyzone
---@return unknown|nil handle The created polyzone's handle
PolyZone.Custom = function(zoneId, points, options)
    return API.polyZoneCreateZone(zoneId, points, options)
end
