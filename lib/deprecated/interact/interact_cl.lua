local Interactions = {}

local CreateEntityInteract = function(data)
    if Interactions[data.modelHash] then
        log.warn("Overwriting existing interact", data.modelHash, data.label)
    else
        log.debug("Creating new interact", dat.getName(data.modelHash))
    end
    Interactions[data.modelHash] = {
        -- interactType = "entity",
        icon = data.icon,
        label = data.label,
        callback = data.callback,
    }
    TriggerEvent("da_xinteracts:add", data.modelHash, Interactions[data.modelHash])
end

Lib.Interact.GetAllInteracts = function()
    return Interactions
end

Lib.Interact.New = function(interactType, ...)
    if interactType == "entity" then
        CreateEntityInteract(...)
    else
        log.error("Invalid interact type", interactType)
    end
end

