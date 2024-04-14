local ZoneId = "da_scene"
local Scenes = {}
local LoadedScenes = {}

local function LoadScene(data)
    if not data then return; end
    if LoadedScenes[data.name] then return; end

    LoadedScenes[data.name] = { loaded = true, props = {} }
    for _, prop in ipairs(data.Props) do
        local obj = nil
        if prop.vehicle then
            obj = Lib.Obj.CreateVehicle(prop.model, prop.position, prop)
        else
            obj = Lib.Obj.Create(prop.model, prop.position, prop)
        end
        if not LoadedScenes[data.name].loaded then
            Lib.Obj.Delete(obj)
            break
        end
        if obj then table.insert(LoadedScenes[data.name].props, obj) end
    end
end

local function UnloadScene(name)
    LoadedScenes[name].loaded = false
    for _, obj in ipairs(LoadedScenes[name].props) do
        Lib.Obj.Delete(obj)
    end
end

Lib.Scene.Register = function(sceneName, scene)
    if not sceneName or not scene then return; end
    if Scenes[sceneName] then return; end

    Scenes[sceneName] = scene
    if not scene.Zone or not scene.Zone.Radius or not scene.Zone.Coords then
        Lib.Log.Debug(scene.Zone.Radius, ("Zone malformed %s"):format(sceneName))
        return
    end
    Lib.PolyZone.Circle(ZoneId, scene.Zone.Coords.Center, scene.Zone.Radius, {
        data = { id = sceneName, }
    })
    if scene.Peds then
        for index, ped in ipairs(scene.Peds) do
            local option = ped
            option.id = ("%s_%s"):format(sceneName, index)
            Lib.Ped.Create(ped.ped, ped.loc, option)
        end
    end
end

Lib.Scene.Load = function(sceneName)
    if not sceneName then return; end
    if not Scenes[sceneName] then return; end
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
    LoadScene(Scenes[sceneName])
end

Lib.Scene.Remove = function(sceneName)
    if not sceneName then return; end
    if not LoadedScenes[sceneName] then return; end

    LoadedScenes[sceneName].loaded = false
    UnloadScene(sceneName)
    LoadedScenes[sceneName] = nil
end

Citizen.CreateThread(function()
    Lib.PolyZone.EnterHandler(ZoneId, function(data) Lib.Scene.Load(data.id) end)
    Lib.PolyZone.ExitHandler(ZoneId, function(data) Lib.Scene.Remove(data.id) end)
end)

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return; end
    for sceneName, _ in pairs(LoadedScenes) do
        UnloadScene(sceneName)
    end
end)
