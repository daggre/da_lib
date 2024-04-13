--- Copyright © 2024 Joshua Nelson

Lib.PolyZone.EnterHandler = function(zoneId, cb)
    if Lib.API.Active then
        Lib.API.PolyZoneEnterHandler(zoneId, cb)
        return
    end
    Lib.Log.Debug(("API not active, local function '%s' not implemented"):format("PolyZone.EnterHandler"))
end

Lib.PolyZone.ExitHandler = function(zoneId, cb)
    if Lib.API.Active then
        Lib.API.PolyZoneExitHandler(zoneId, cb)
        return
    end
    Lib.Log.Debug(("API not active, local function '%s' not implemented"):format("PolyZone.ExitHandler"))
end

Lib.PolyZone.Circle = function(zoneId, coords, radius, options)
    if Lib.API.Active then
        return Lib.API.PolyZoneCreateCircle(zoneId, coords, radius, options)
    end
    Lib.Log.Debug(("API not active, local function '%s' not implemented"):format("PolyZone.Circle"))
end
