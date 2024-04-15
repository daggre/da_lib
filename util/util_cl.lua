--- Copyright © 2024 Joshua Nelson

Lib.Util.CalcBoundaryCenter = function(boundary)
    if not boundary or type(boundary) ~= "table" then Lib.Log.Warn("Invalid boundary:", boundary); return; end
    local minX, minY, maxX, maxY = nil, nil, nil, nil
    for _, edgeCoord in ipairs(boundary) do
        if minX ~= nil then minX = math.min(minX, edgeCoord.x); else minX = edgeCoord.x; end
        if maxX ~= nil then maxX = math.max(maxX, edgeCoord.x); else maxX = edgeCoord.x; end
        if minY ~= nil then minY = math.min(minY, edgeCoord.y); else minY = edgeCoord.y; end
        if maxY ~= nil then maxY = math.max(maxY, edgeCoord.y); else maxY = edgeCoord.y; end
    end
    xRange = maxX - minX
    yRange = maxY - minY
    center = vector2(minX+(xRange/2), minY+(yRange/2))
    return center, xRange, yRange
end

Lib.Util.TranslateCartesian = function(r, theta)
    local x = r * -math.sin(theta * math.pi / 180.0)
    local y = r * math.cos(theta * math.pi / 180.0)
    return x, y
end

Lib.Util.GetOffsetFromEntity = function(entity, theta, r, z, rotation)
    rotation = rotation or vec3(0, 0, 0)
    local origin = GetEntityCoords(entity)
    local w = GetEntityHeading(entity)
    local x, y = Lib.Util.TranslateCartesian(r, w - theta)
    local data = {
        coords = origin + vec3(x, y, z),
        rotation = rotation + vec3(0, 0, w),
    }
    return data
end

Lib.Util.GetEntitiesNearPoint = function(coords, radius, filter)
    local entities = {}
    local itemset = CreateItemset(true)
    local size = Citizen.InvokeNative(0x59B57C4B06531E1E, coords.x, coords.y, coords.z, radius, itemset, 3, Citizen.ResultAsInteger()) -- GetEntitiesNearPoint
    for i = 0, size - 1 do
        local entity = GetIndexedItemInItemset(i, itemset)
        if not filter or filter(entity) then
            table.insert(entities, entity)
        end
    end
    if IsItemsetValid(itemset) then
        DestroyItemset(itemset)
    end
    return entities
end
