
local zone = {}

zone.square = function(pos, range, opts)
    return BoxZone:Create(pos, range, opts)
end

zone.circle = function(pos, range, opts)
    return CircleZone:Create(pos, range, opts)
end

zone.poly = function(points, opts)
    return PolyZone:Create(points, opts)
end

_ENV.zone = zone

-- TODO: Remove this
RegisterCommand("pzone", function(source, args, rawCommand)
    if args[1] == "add" then
        local phandle = zone.circle(GetEntityCoords(), tonumber(args[2]) or 1.0, {
            debugPoly = true,
            useZ = true,
        })
        log.info(phandle)
    end
end, false)
