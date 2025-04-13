
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
