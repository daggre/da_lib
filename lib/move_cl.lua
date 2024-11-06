local Move = {}

---Face the ped towards a direction
---@param ped any
---@param coords any
---@param timeout any
Move.face = function(ped, coords, timeout)
    TaskTurnPedToFaceCoord(ped, coords.xyz, timeout)
    Citizen.Wait(timeout)
end

---Automatically move the player to a set of coordinates
---@param ped integer the id of the entity/ped
---@param coords table vector3 coordinates to move to
---@param timeout number the amount of time in ms to wait for the task to complete
---@param forceCoords boolean whether to force the player to the coordinates
---@param speed number|nil the speed of the movement
---@param slideDistance number|nil the distance to slide the player
Move.to = function(ped, coords, timeout, forceCoords, speed, slideDistance)
    speed = speed or 1.0
    slideDistance = slideDistance or 0.3
    TaskGoStraightToCoord(ped, coords.xyz, speed, timeout, coords.w, slideDistance)
    Citizen.Wait(timeout)
    if forceCoords then
		SetEntityCoords(ped, coords.xyz)
		SetEntityHeading(ped, coords.w)
    end
end

_ENV.da_move = Move
