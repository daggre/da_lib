local Interactions = {}

local CreateEntityInteract = function(data)
    if Interactions[data.modelHash] then
        Lib.Log.Warn("Overwriting existing interact", data.modelHash, data.label)
    else
        Lib.Log.Debug("Creating new interact", Lib.Util.GetModelName(data.modelHash))
    end
    Interactions[data.modelHash] = {
        icon = data.icon,
        label = data.label,
        callback = data.callback,
    }
end

Lib.Interact.GetAllInteracts = function()
    return Interactions
end

Lib.Interact.New = function(interactType, ...)
    if interactType == "entity" then
        CreateEntityInteract(...)
    else
        Lib.Log.Error("Invalid interact type", interactType)
    end
end

