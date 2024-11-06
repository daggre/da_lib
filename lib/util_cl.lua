local Util = {}

---Calculate the center of a set of boundary coordinates
---@param boundary table The boundary coordinates
---@return table|nil The center of the boundary
---@return number|nil xWidth The width of the boundary on the x-axis
---@return number|nil yWidth The width of the boundary on the y-axis
Util.CalcBoundaryCenter = function(boundary)
    if not boundary or type(boundary) ~= "table" then
        log.warn("Invalid boundary:", boundary)
        return nil
    end
    local minX, minY, maxX, maxY = nil, nil, nil, nil
    for _, edgeCoord in ipairs(boundary) do
        if minX ~= nil then minX = math.min(minX, edgeCoord.x); else minX = edgeCoord.x; end
        if maxX ~= nil then maxX = math.max(maxX, edgeCoord.x); else maxX = edgeCoord.x; end
        if minY ~= nil then minY = math.min(minY, edgeCoord.y); else minY = edgeCoord.y; end
        if maxY ~= nil then maxY = math.max(maxY, edgeCoord.y); else maxY = edgeCoord.y; end
    end
    local xRange = maxX - minX
    local yRange = maxY - minY
    local center = vector2(minX+(xRange/2), minY+(yRange/2))
    return center, xRange, yRange
end

---Translate a polar to cartesian coordinate
---@param r number The radius
---@param theta number The angle in degrees
---@return number deltaX The x translation
---@return number deltaY The y translation
Util.TranslateCartesian = function(r, theta)
    local x = r * -math.sin(theta * math.pi / 180.0)
    local y = r * math.cos(theta * math.pi / 180.0)
    return x, y
end

---Given a position with a heading as the origin, calculate the cartesian offset
---position given polar coordinates
---@param entity integer The entity id to calculate the offset from
---@param theta number The angle in degrees
---@param r number The radius
---@param z number The z offset
---@param rotation number|nil The rotation offset
---@return table offsetData Table containing coords and rotation of point after translation
Util.GetOffsetFromEntity = function(entity, theta, r, z, rotation)
    rotation = rotation or vec3(0, 0, 0)
    -- Get the position and heading of the entity
    local origin = GetEntityCoords(entity)
    local w = GetEntityHeading(entity)

    -- Translate the polar coordinates to cartesian
    local x, y = Util.TranslateCartesian(r, w - theta)

    -- Calculate the position from the origin and translation and store the data
    local data = {
        coords = origin + vec3(x, y, z),
        rotation = rotation + vec3(0, 0, w),
    }
    return data
end

---Get the entities near a point
---@param coords table The coordinates to search from
---@param radius number The radius to search
---@param filter function|nil The filter to apply to the entities
---@return table entities The entities within the radius of the point matching the filter conditions
Util.GetEntitiesNearPoint = function(coords, radius, filter)
    local entities = {}
    local itemset = CreateItemset(true)
    local size = Citizen.InvokeNative(0x59B57C4B06531E1E, coords.xyz, radius+0.0, itemset, 3, Citizen.ResultAsInteger()) -- GetEntitiesNearPoint
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

---Get the peds near a point
---@param coords table The coordinates to search from
---@param radius number The radius to search
---@param filter function|nil The filter to apply to the peds
---@return table entities The peds within the radius of the point matching the filter conditions
Util.GetPedsNearPoint = function(coords, radius, filter)
    local entities = {}
    local itemset = CreateItemset(true)
    local size = Citizen.InvokeNative(0x59B57C4B06531E1E, coords.xyz, radius+0.0, itemset, 1, Citizen.ResultAsInteger()) -- GetEntitiesNearPoint
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

---Get the vehicles near a point
---@param coords table The coordinates to search from
---@param radius number The radius to search
---@param filter function|nil The filter to apply to the peds
---@return table entities The peds within the radius of the point matching the filter conditions
Util.GetVehiclesNearPoint = function(coords, radius, filter)
    local entities = {}
    for _, entity in ipairs(GetGamePool("CVehicle")) do
        local vehicleCoords = GetEntityCoords(entity)
        if #(coords - vehicleCoords) < tonumber(radius) and (not filter or filter(entity)) then
            table.insert(entities, entity)
        end
    end
    return entities
end

_ENV.da_util = Util
