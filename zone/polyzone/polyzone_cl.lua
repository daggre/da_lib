--- Copyright © 2024 Joshua Nelson

Lib.PolyZone.OnEnter = function(zoneId, cb)
    if Lib.API.Active then
        Lib.API.PolyZoneEnterHandler(zoneId, cb)
        return
    end
    Lib.Log.Debug(("API not active, local function '%s' not implemented"):format("PolyZone.OnEnter"))
end

Lib.PolyZone.OnExit = function(zoneId, cb)
    if Lib.API.Active then
        Lib.API.PolyZoneExitHandler(zoneId, cb)
        return
    end
    Lib.Log.Debug(("API not active, local function '%s' not implemented"):format("PolyZone.OnExit"))
end

Lib.PolyZone.Circle = function(zoneId, coords, radius, options)
    if Lib.API.Active then
        return Lib.API.PolyZoneCreateCircle(zoneId, coords, radius, options)
    end
    Lib.Log.Debug(("API not active, local function '%s' not implemented"):format("PolyZone.Circle"))
end

Lib.PolyZone.Custom = function(zoneId, points, options)
    if Lib.API.Active then
        return Lib.API.PolyZoneCreateZone(zoneId, points, options)
    end
    Lib.Log.Debug(("API not active, local function '%s' not implemented"):format("PolyZone.Custom"))
end
