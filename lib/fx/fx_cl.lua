local RequestNamedPtfxAsset = function(ptfxDictHash) Citizen.InvokeNative(0xF2B2353BBC0D4E8F, ptfxDictHash) end

local HasNamedPtfxAssetLoaded = function(ptfxDictHash) return Citizen.InvokeNative(0x65BB72F29138F5D6, ptfxDictHash) end

---Load Particle Fx Dictionary
---@param ptfxDict string The name of the particle fx dictionary
---@return boolean success Returns true if the dictionary was successfully loaded
local LoadPtfxDict = function(ptfxDict)
    local ptfxDictHash = GetHashKey(ptfxDict)
    if HasNamedPtfxAssetLoaded(ptfxDictHash) then return true; end

    Lib.Log.Debug("Requesting Asset ptfxDict", ptfxDictHash)
    RequestNamedPtfxAsset(ptfxDictHash)
    local timeout = GetGameTimer() + 1000
    while not HasNamedPtfxAssetLoaded(ptfxDictHash) do
        if GetGameTimer() > timeout then
            Lib.Log.Debug("Failed to load ptfxDict", ptfxDictHash)
            return false
        end
        Citizen.Wait(100)
    end
    return true
end

local UsePtfxAsset = function(ptfxDictHash) Citizen.InvokeNative(0xA10DB07FC234DD12, ptfxDictHash) end

-- Clientside fx functions
local StartParticleFxLoopedOnEntity = function(ptfxName, entity, xOff, yOff, zOff, xRot, yRot, zRot, scale, xAxis, yAxis, zAxis)
    return Citizen.InvokeNative(0xBD41E1440CE39800, ptfxName, entity, xOff, yOff, zOff, xRot, yRot, zRot, scale, xAxis, yAxis, zAxis, false)
end

local StartParticleFxOnEntity = function(ptfxName, entity, xOff, yOff, zOff, xRot, yRot, zRot, scale, xAxis, yAxis, zAxis)
    return Citizen.InvokeNative(0xFF4C64C513388C12, ptfxName, entity, xOff, yOff, zOff, xRot, yRot, zRot, scale, xAxis, yAxis, zAxis, false)
end

local StartParticleFxLoopedOnBone = function(ptfxName, entity, boneIndex, xOff, yOff, zOff, xRot, yRot, zRot, scale, xAxis, yAxis, zAxis)
    return Citizen.InvokeNative(0xE689C1B1432BB8AF, ptfxName, entity, xOff, yOff, zOff, xRot, yRot, zRot, boneIndex, scale, xAxis, yAxis, zAxis, false)
end

local StartParticleFxOnBone = function(ptfxName, entity, boneIndex, xOff, yOff, zOff, xRot, yRot, zRot, scale, xAxis, yAxis, zAxis)
    return Citizen.InvokeNative(0x3FAA72BD940C3AC0, ptfxName, entity, xOff, yOff, zOff, xRot, yRot, zRot, boneIndex, scale, xAxis, yAxis, zAxis, false)
end

local StartParticleFxLoopedAtCoord = function(ptfxName, x, y, z, xRot, yRot, zRot, scale, xAxis, yAxis, zAxis)
    return Citizen.InvokeNative(0xBA32867E86125D3A, ptfxName, x, y, z, xRot, yRot, zRot, scale, xAxis, yAxis, zAxis, false)
end

local StartParticleFxAtCoord = function(ptfxName, x, y, z, xRot, yRot, zRot, scale, xAxis, yAxis, zAxis)
    return Citizen.InvokeNative(0x2E80BF72EF7C87AC, ptfxName, x, y, z, xRot, yRot, zRot, scale, xAxis, yAxis, zAxis, false)
end

--Networked fx functions
local StartNetParticleFxLoopedOnEntity = function(ptfxName, entity, xOffset, yOffset, zOffset, xRot, yRot, zRot, scale, xAxis, yAxis, zAxis)
    return Citizen.InvokeNative(0x8F90AB32E1944BDE, ptfxName, entity, xOffset, yOffset, zOffset, xRot, yRot, zRot, scale, xAxis, yAxis, zAxis)
end

local StartNetParticleFxOnEntity = function(ptfxName, entity, xOffset, yOffset, zOffset, xRot, yRot, zRot, scale, xAxis, yAxis, zAxis)
    return Citizen.InvokeNative(0xE6CFE43937061143, ptfxName, entity, xOffset, yOffset, zOffset, xRot, yRot, zRot, scale, xAxis, yAxis, zAxis)
end

local StartNetParticleFxLoopedOnBone = function(ptfxName, entity, boneIndex, xOffset, yOffset, zOffset, xRot, yRot, zRot, scale, xAxis, yAxis, zAxis)
    return Citizen.InvokeNative(0x9C56621462FFE7A6, ptfxName, entity, boneIndex, xOffset, yOffset, zOffset, xRot, yRot, zRot, scale, xAxis, yAxis, zAxis)
end

local StartNetParticleFxAtCoord = function(ptfxName, x, y, z, xRot, yRot, zRot, scale, xAxis, yAxis, zAxis)
    return Citizen.InvokeNative(0xFB97618457994A62, ptfxName, x, y, z, xRot, yRot, zRot, scale, xAxis, yAxis, zAxis)
end

---Given a particle fx name, play the particle fx based on the options
---@param ptfxName string The name of the particle fx
---@param options table The options for the particle fx
---@return number|nil fxHandleThe The handle of the particle fx
local StartPtfx = function(ptfxName, options)
    local coords = options.coords
    local boneIndex = options.entity and options.bone and GetEntityBoneIndexByName(options.entity, options.bone) or false
    local xOff = options.xOff or 0.0
    local yOff = options.yOff or 0.0
    local zOff = options.zOff or 0.0
    local xRot = options.xRot or 0.0
    local yRot = options.yRot or 0.0
    local zRot = options.zRot or 0.0
    local scale = options.scale or 1.0
    local xAxis = options.xAxis or 0.0
    local yAxis = options.yAxis or 0.0
    local zAxis = options.zAxis or 0.0

    if options.networked then
        -- If the particle fx is networked
        if options.entity then
            -- If the particle fx is networked and should be attached to an entity
            if options.bone then
                -- If the particle fx is networked, attached to an entity bone
                if options.loop then
                    -- If the particle fx is networked, attached to an entity bone, and looped
                    Lib.Log.Debug("Starting looped ptfx on bone")
                    return StartNetParticleFxLoopedOnBone(ptfxName, options.entity, boneIndex, xOff, yOff, zOff, xRot, yRot, zRot, scale, xAxis, yAxis, zAxis)
                else
                    -- If the particle fx is networked, attached to an entity bone, and not looped
                    Lib.Log.Error("Networked ptfx non-looped on bone is not supported")
                    -- Lib.Log.Debug("Starting ptfx on bone")
                    -- return StartNetParticleFxOnBone(ptfxName, options.entity, boneIndex, xOff, yOff, zOff, xRot, yRot, zRot, scale, xAxis, yAxis, zAxis)
                end
            else
                -- If the particle fx is networked, attached to an entity, and not attached to a bone
                if options.loop then
                    -- If the particle fx is networked, attached to an entity, not attached to a bone, and looped
                    Lib.Log.Debug("Starting looped ptfx on entity")
                    return StartNetParticleFxLoopedOnEntity(ptfxName, options.entity, xOff, yOff, zOff, xRot, yRot, zRot, scale, xAxis, yAxis, zAxis)
                else
                    -- If the particle fx is networked, attached to an entity, not attached to a bone, and not looped
                    Lib.Log.Debug("Starting ptfx on entity")
                    return StartNetParticleFxOnEntity(ptfxName, options.entity, xOff, yOff, zOff, xRot, yRot, zRot, scale, xAxis, yAxis, zAxis)
                end
            end
        elseif options.coords then
            -- If the particle fx is networked and should be attached to a location
            if options.loop then
                -- If the particle fx is networked, attached to a location, and looped
                Lib.Log.Error("Networked looped ptfx at location is not supported")
                -- Lib.Log.Debug("Starting looped ptfx at location", ptfxName, coords.x, coords.y, coords.z, xRot, yRot, zRot, scale, xAxis, yAxis, zAxis)
                -- return StartNetParticleFxLoopedAtCoord(ptfxName, coords.x, coords.y, coords.z, xRot, yRot, zRot, scale, xAxis, yAxis, zAxis)
            else
                -- If the particle fx is networked, attached to a location, and not looped
                Lib.Log.Debug("Starting ptfx at location", options)
                return StartNetParticleFxAtCoord(ptfxName, coords.x, coords.y, coords.z, xRot, yRot, zRot, scale, xAxis, yAxis, zAxis)
            end
        end
    else
        -- If the particle fx is not networked
        if options.entity then
            -- If the particle fx is not networked and attached to an entity
            if options.bone then
                -- If the particle fx is not networked, attached to an entity bone
                if options.loop then
                    -- If the particle fx is not networked, attached to an entity bone, and looped
                    Lib.Log.Debug("Starting looped ptfx on bone")
                    return StartParticleFxLoopedOnBone(ptfxName, options.entity, boneIndex, xOff, yOff, zOff, xRot, yRot, zRot, scale, xAxis, yAxis, zAxis)
                else
                    -- If the particle fx is not networked, attached to an entity bone, and not looped
                    Lib.Log.Debug("Starting ptfx on bone")
                    return StartParticleFxOnBone(ptfxName, options.entity, boneIndex, xOff, yOff, zOff, xRot, yRot, zRot, scale, xAxis, yAxis, zAxis)
                end
            else
                -- If the particle fx is not networked, attached to an entity, and not attached to a bone
                if options.loop then
                    -- If the particle fx is not networked, attached to an entity, not attached to a bone, and looped
                    Lib.Log.Debug("Starting looped ptfx on entity")
                    return StartParticleFxLoopedOnEntity(ptfxName, options.entity, xOff, yOff, zOff, xRot, yRot, zRot, scale, xAxis, yAxis, zAxis)
                else
                    -- If the particle fx is not networked, attached to an entity, not attached to a bone, and not looped
                    Lib.Log.Debug("Starting ptfx on entity")
                    return StartParticleFxOnEntity(ptfxName, options.entity, xOff, yOff, zOff, xRot, yRot, zRot, scale, xAxis, yAxis, zAxis)
                end
            end
        elseif options.coords then
            -- If the particle fx is not networked and should be attached to a location
            if options.loop then
                -- If the particle fx is not networked, attached to a location, and looped
                Lib.Log.Debug("Starting looped ptfx at location", ptfxName, coords.x, coords.y, coords.z, xRot, yRot, zRot, scale, xAxis, yAxis, zAxis)
                return StartParticleFxLoopedAtCoord(ptfxName, coords.x, coords.y, coords.z, xRot, yRot, zRot, scale, xAxis, yAxis, zAxis)
            else
                -- If the particle fx is not networked, attached to a location, and not looped
                Lib.Log.Debug("Starting ptfx at location", options)
                return StartParticleFxAtCoord(ptfxName, coords.x, coords.y, coords.z, xRot, yRot, zRot, scale, xAxis, yAxis, zAxis)
            end
        end
    end
    return nil
end

local DoesParticleFxExist = function(ptfxHandle)
    return Citizen.InvokeNative(0x9DD5AFF561E88F2A, ptfxHandle)
end

local RemoveParticleFx = function(ptfxHandle, p2)
    return Citizen.InvokeNative(0x459598F579C98929, ptfxHandle, p2)
end

local RemoveParticleFxFromEntity = function(entity)
    return Citizen.InvokeNative(0x92884B4A49D81325, entity)
end

local RemoveParticleFxInRange = function(x, y, z, radius)
    return Citizen.InvokeNative(0x87B5905ECA623B68, x, y, z, radius)
end

---Create a new particle fx effect and return the id
---@param ptfxDict string The name of the particle fx dictionary
---@param ptfxName string The name of the particle fx
---@param options table The options for creating the particle fx
---@return number|nil fxHandle The particle fx handle
Lib.Fx.New = function(ptfxDict, ptfxName, options)
    if not LoadPtfxDict(ptfxDict) then return nil; end
    UsePtfxAsset(ptfxDict)
    return StartPtfx(ptfxName, options)
end

---Remove a particle fx effect
---@param options any
Lib.Fx.Remove = function(options)
    if options.handle then
        if DoesParticleFxExist(options.handle) then
            RemoveParticleFx(options.handle)
        end
    elseif options.entity then
        RemoveParticleFxFromEntity(options.entity)
    elseif options.coords then
        RemoveParticleFxInRange(options.coords.x, options.coords.y, options.coords.z, options.radius or 1.0)
    end
end

if Lib.Util.IsDev then
    -- If in dev mode, register test commands to test particle fx

    --- Generate a particle fx
    ---@param args table Arg 1: ptfxDict, Arg 2: ptfxName, Arg 3: duration
    RegisterCommand("da_fx_test", function(source, args, rawCommand)
        local ptfxDict = args[1]
        local ptfxName = args[2]
        local fxHandle = Lib.Fx.New(ptfxDict, ptfxName, {
            coords = Lib.Util.GetOffsetFromEntity(PlayerPedId(), 0, 1.0, 0.0).coords,
            -- entity = PlayerPedId(),
            -- bone = "SKEL_R_Hand",
            loop = true,
        })
        Lib.Log.Debug("Created ptfx fxHandle", fxHandle)
        SetTimeout(tonumber(args[3]) or 10000, function()
            Lib.Log.Debug("Removing fxHandle", fxHandle)
            Lib.Fx.Remove({handle = fxHandle})
        end)
    end, false)
end
