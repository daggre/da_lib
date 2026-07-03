local Raycast = {}
local Deg2Rad = math.pi / 180

Raycast.get = function(distance, ped)
    ped = ped or PlayerPedId()
    local pos = GetFinalRenderedCamCoord()
    local rot = GetFinalRenderedCamRot()
    local yaw = rot.z * Deg2Rad
    local pitch = rot.x * Deg2Rad
    local hdg = {
        x = -math.sin(yaw) * math.abs(math.cos(pitch)),
        y = math.cos(yaw) * math.abs(math.cos(pitch)),
        z = math.sin(pitch),
    }
    local _, hit, endPos, _, _ = GetShapeTestResult(
        StartShapeTestRay(
            pos.x, pos.y, pos.z,
            pos.x + hdg.x * distance,
            pos.y + hdg.y * distance,
            pos.z + hdg.z * distance,
            -1, ped, 0
        )
    )
    return hit, endPos
end

Raycast.getEntity = function(distance, radius, ped)
    if da_util == nil then log.error("Raycast depends on importing da_util"); return end
    radius = radius or 30.0
    local hit, pos = Raycast.get(distance, ped)
    if hit ~= 1 then return end
    return da_util.GetClosestPedNearPoint(pos, radius, function(e)
        return not IsPedDeadOrDying(e)
    end)
end

_ENV.da_raycast = Raycast
