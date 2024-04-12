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
