--- Copyright © 2024 Joshua Nelson

local ZoneId = "propZone"
local Scenes = {}
local LoadedScenes = {}

---Load a scene of props, vehicles, and/or peds into the world
---@param data table The scene data
local function LoadScene(data)
    if not data then return; end
    -- If the scene is already loaded, don't load it again
    if LoadedScenes[data.name] then return; end

    -- Set the scene as loaded and set up a table to track which props are added.
    -- If we exit the scene during load, we can interrupt the scene load using
    -- this data.
    LoadedScenes[data.name] = { loaded = true, props = {} }
    local objectGroup = nil

    -- Load each prop/vehicle/ped
    for _, prop in ipairs(data.Props) do
        local obj = nil
        if prop.vehicle then
            obj = Lib.Obj.CreateVehicle(prop.model, prop.position, prop)
        else
            obj = Lib.Obj.Create(prop.model, prop.position, prop)
        end
        if not LoadedScenes[data.name] or not LoadedScenes[data.name].loaded then
            -- The scene was unloaded during load, delete the object and break
            Lib.Obj.Delete(obj)
            obj = nil
            break
        end
        if obj and LoadedScenes[data.name] then
            -- The scene is still valid and the object was created
            table.insert(LoadedScenes[data.name].props, obj)
            if prop.animation then
                Lib.Log.DebugVerbose(("Playing animation %s on %s"):format(prop.animation.anim, prop.model))
                Lib.Anim.Object(obj,
                    prop.animation.dict,
                    prop.animation.anim,
                    prop.animation.flags.p3,
                    prop.animation.flags.loop,
                    prop.animation.flags.stayInAnim,
                    prop.animation.flags.p6,
                    prop.animation.flags.delta,
                    prop.animation.flags.bitset
                )
                if prop.animation.flags then
                    local animSpeed = tonumber(prop.animation.flags.speed) and prop.animation.flags.speed > 0 and prop.animation.flags.speed or nil
                    local animTime = prop.animation.flags.time
                    if animSpeed ~= nil or animTime ~= nil then
                        -- Wait for the animation to start playing before we can change its speed
                        SetTimeout(200, function()
                            Lib.Log.Debug(("Setting object %s time:%s speed:%s"):format(obj, animTime or "-", animSpeed or "-"))
                            Lib.Anim.SetObject(obj, prop.animation.dict, prop.animation.anim, animTime, animSpeed)
                        end)
                    end
                end
            end
            if prop.group then
                if not objectGroup then objectGroup = {}; end
                if not objectGroup[prop.group] then objectGroup[prop.group] = {}; end
                objectGroup[prop.group][obj] = {
                    animDict = prop.animation and prop.animation.dict,
                    anim = prop.animation and prop.animation.anim,
                }
            end
        end
        if not LoadedScenes[data.name] or not LoadedScenes[data.name].loaded then
            -- Check again if the scene was unloaded to catch race conditions
            -- The scene was unloaded during load, delete the object and break
            Lib.Obj.Delete(obj)
            obj = nil
            break
        end
    end
    -- The scene loaded fully, send any object group entity handles to the client
    if (objectGroup or data.GroupEvent) and LoadedScenes[data.name] then
        if not objectGroup then Lib.Log.Warn("GroupEvent is set but no objectGroups created"); end
        local groupEvent = data.GroupEvent or ("%s:ObjectGroup"):format(data.name)
        -- Callback to deliver entity groups
        Lib.Log.Debug("Triggering group event", groupEvent, objectGroup)
        TriggerEvent(groupEvent, objectGroup)
    end

end

---Unload a scene of props, vehicles, and/or peds from the world
---@param name string The scene id
local function UnloadScene(name)
    LoadedScenes[name].loaded = false
    -- Delete each prop/vehicle/ped
    for _, obj in ipairs(LoadedScenes[name].props) do
        Lib.Obj.Delete(obj)
    end
    -- If the scene is actively loading, rely on LoadScene to clean up any props
    -- added during the load process.
    LoadedScenes[name] = nil
end

---Register a scene for loading and unloading
---@param sceneName string The name/id of the scene to register
---@param scene table The scene data containing the object/vehicle/ped information
Lib.Props.Register = function(sceneName, scene)
    if not sceneName or not scene then return; end
    -- Check if the scene is already registered
    if Scenes[sceneName] then return; end

    -- Verify the scene has valid zone data for creating the polyzone
    Scenes[sceneName] = scene
    if not scene.Zone or not scene.Zone.Radius or not scene.Zone.Coords then
        Lib.Log.Warn(scene.Zone.Radius, ("Zone malformed %s"):format(sceneName))
        return
    end

    -- Register the scene
    Scenes[sceneName] = scene
    -- Create the polyzone for the scene to trigger load and unload
    Lib.PolyZone.Circle(ZoneId, scene.Zone.Coords.Center, scene.Zone.Radius, {
        data = { id = sceneName, }
    })
    -- If there are peds in this scene, register them and let the NPC system handle them
    if scene.Peds then
        for index, ped in ipairs(scene.Peds) do
            local option = ped
            option.id = ("%s_%s"):format(sceneName, index)
            Lib.NPC.New(ped.ped, ped.loc, option)
        end
    end
end

---Load a prop scene
---@param sceneName string The name/id of the scene to load
Lib.Props.Load = function(sceneName)
    if not sceneName then return; end
    if not Scenes[sceneName] then return; end
    -- If the scene is already loaded, wait temporarily for it to unload or abort
    if LoadedScenes[sceneName] then
        local unloadTimeout = GetGameTimer() + 2000
        while LoadedScenes[sceneName] and LoadedScenes[sceneName].loaded == false and GetGameTimer() < unloadTimeout do
            -- The scene is currently unloading.
            Citizen.Wait(100)
            if GetGameTimer() >= unloadTimeout then
                Lib.Log.Debug(("Failed load scene, it never finished unloading '%s'"):format(sceneName))
                return
            end
        end

    end
    -- Load the scene
    LoadScene(Scenes[sceneName])
end

---Unload a prop scene
---@param sceneName string The name/id of the scene to unload
Lib.Props.Unload = function(sceneName)
    if not sceneName then return; end
    if not LoadedScenes[sceneName] then return; end

    LoadedScenes[sceneName].loaded = false
    UnloadScene(sceneName)
    LoadedScenes[sceneName] = nil
end

-- Register the polyzone enter/exit event handlers to load and unload scenes
Citizen.CreateThread(function()
    Lib.PolyZone.OnEnter(ZoneId, function(data) Lib.Props.Load(data.id) end)
    Lib.PolyZone.OnExit(ZoneId, function(data) Lib.Props.Unload(data.id) end)
end)

-- Unload all scenes when the resource stops
AddEventHandler("onResourceStop", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return; end
    for sceneName, _ in pairs(LoadedScenes) do
        UnloadScene(sceneName)
    end
end)
