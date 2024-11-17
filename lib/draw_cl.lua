local CubeEdges = {
    {1, 2}, {2, 3}, {3, 4}, {4, 1},
    {5, 6}, {6, 7}, {7, 8}, {8, 5},
    {1, 5}, {2, 6}, {3, 7}, {4, 8},
}

local GetExtents = function(min, max)
    local offset = vec3(
        (max.x + min.x) / 2,
        (max.y + min.y) / 2,
        (max.z + min.z) / 2
    )
    local extents = vec3(
        (max.x - min.x) / 2,
        (max.y - min.y) / 2,
        (max.z - min.z) / 2
    )
    local extentsMin = offset - extents
    local extentsMax = offset + extents

    return extentsMin, extentsMax
end

local GetRotationMatrix = function(fVec, rVec, uVec)
    return {
        {rVec.x, fVec.x, uVec.x},
        {rVec.y, fVec.y, uVec.y},
        {rVec.z, fVec.z, uVec.z},
    }
end

local ApplyRotationMatrix = function(pIn, m)
    local pOut = {}
    for _, p in ipairs(pIn) do
        table.insert(pOut, vec3(
            p.x * m[1][1] + p.y * m[1][2] + p.z * m[1][3],
            p.x * m[2][1] + p.y * m[2][2] + p.z * m[2][3],
            p.x * m[3][1] + p.y * m[3][2] + p.z * m[3][3]
        ))
    end
    return pOut
end

local GetBoundingBox = function(obj)
    local model = GetEntityModel(obj)
    local dMin, dMax = GetModelDimensions(model)
    local min, max = GetExtents(dMin, dMax)
    local vertices = {
        vec3(min.x, min.y, min.z),
        vec3(max.x, min.y, min.z),
        vec3(max.x, max.y, min.z),
        vec3(min.x, max.y, min.z),
        vec3(min.x, min.y, max.z),
        vec3(max.x, min.y, max.z),
        vec3(max.x, max.y, max.z),
        vec3(min.x, max.y, max.z),
    }

    -- INFO: Swapped fVec and rVec according to API documentation
    local fVec, rVec, uVec, pos = GetEntityMatrix(obj)
    local matrix = GetRotationMatrix(fVec, rVec, uVec)
    vertices = ApplyRotationMatrix(vertices, matrix)

    return vertices, pos
end

local DrawSphere = function(pos, radius, color)
    Citizen.InvokeNative(0x2A32FAA57B937173, 0x50638AB9, pos.x, pos.y, pos.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, radius, radius, radius, color.r, color.g, color.b, color.a, false, false, 2, nil, nil, false)
end

local DrawCylinder = function(pos, radius, height, color)
    Citizen.InvokeNative(0x2A32FAA57B937173, 0x50638AB9, pos.x, pos.y, -200.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, radius, radius, height, color.r, color.g, color.b, color.a, false, false, 2, nil, nil, false)
end

local DrawLine = function(...)
    Citizen.InvokeNative(0xB3426BCC, ...)
end

local DrawHLine = function(radius, pos, color)
    local xd, yd = da_util.TranslateCartesian(radius, pos)
    color = color or { r = 255, g = 255, b = 255, a = 255 }
    DrawLine(pos, pos + vec3(xd, yd, 0), color.r, color.g, color.b, color.a)
end

local DrawVLine = function(height, pos, color)
    color = color or { r = 255, g = 255, b = 255, a = 255 }
    DrawLine(pos, pos + vec3(0, 0, height), color.r, color.g, color.b, color.a)
end

local DrawBoundingBox = function(o, c)
    if not o then return; end
    c = c or { r = 255, g = 255, b = 255, a = 255 }
    local v, p = GetBoundingBox(o)
    for _, e in ipairs(CubeEdges) do
        DrawLine(v[e[1]] + p, v[e[2]] + p, c.r, c.g, c.b, c.a)
    end
end

local DrawScreenText = function(text, sx, sy, color, size)
    if sx <= 0 or sx >= 1 or sy <= 0 or sy >= 1 then return; end
    local str = CreateVarString(10, "LITERAL_STRING", text)
    color = color or { r = 255, g = 255, b = 255, a = 255 }
    SetTextScale(1, size or 0.2)
    SetTextColor(color.r, color.g, color.b, color.a)
    SetTextCentre(true)
    SetTextDropshadow(1, 0, 0, 0, 255)
    SetTextFontForCurrentCommand(1)
    DisplayText(str, sx, sy)
end

local DrawText = function(text, pos, color, size)
    local _, sx, sy = GetScreenCoordFromWorldCoord(pos.x, pos.y, pos.z)
    if sx <= 0 or sx >= 1 or sy <= 0 or sy >= 1 then return; end
    DrawScreenText(text, sx, sy, color, size)
end

_ENV.DrawSphere = DrawSphere
_ENV.DrawCylinder = DrawCylinder
_ENV.DrawLine = DrawLine
_ENV.DrawHLine = DrawHLine
_ENV.DrawVLine = DrawVLine
_ENV.DrawBB = DrawBoundingBox
_ENV.DrawText = DrawText
_ENV.DrawScreenText = DrawScreenText
