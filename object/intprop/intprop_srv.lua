--- Copyright © 2024 Joshua Nelson

local PropsId = 1
---Get a unique prop id
---@param data table The prop data
---@return string propId The unique prop id
local GetPropId = function(data)
    local propId = PropsId
    PropsId = PropsId + 1
    return ("%s_%d"):format(data.objectHash, propId)
end

---Add a prop to the world
---@param data table The prop data to add
local AddProp = function(data)
    -- If the data doesn't include a prop id, generate one
    data.id = data.id or GetPropId(data)
    -- Instantiate the metadata if it doesn't exist
    data.metadata = data.metadata or {}
    -- Set the creation time if it doesn't exist
    data.metadata.timeCreated = data.metadata.timeCreated or os.time()
    Lib.Log.DebugVerbose("Adding intprop:", data)
    --  Add the prop to the server cache
    Lib.Cache.Temp.Add("intprop", data.id, data, true)
    -- Tell all clients to add the prop
    TriggerClientEvent("intprop:client:add", -1, data)
end

-- Remove a prop from the world
local RemoveProp = function(data)
    if not data or not data.id then return; end
    -- Remove the prop from the server cache
    local removedData = Lib.Cache.Temp.Remove("intprop", data.id)
    if not removedData then
        Lib.Log.DebugVerbose(("Not removing prop: %s"):format(data.id))
        return
    end
    Lib.Log.DebugVerbose("Removing:", data.id, removedData)
    -- Tell all clients to remove the prop
    TriggerClientEvent("intprop:client:remove", -1, removedData)
    return removedData
end

-- Register a server event to add a prop
RegisterNetEvent("intprop:server:add")
AddEventHandler("intprop:server:add", function(data)
    AddProp(data)
end)

---Register a server callback to remove a prop that returns the prop data that was removed
---@param source integer The client id of the player making the call
---@param data table The prop data to remove
---@return unknown|nil removedData The removed prop data
Lib.Net.RegisterServerCb("intprop:server:remove", function(source, data)
    return RemoveProp(data)
end)

---Update a prop's stored resource amount
---@param source integer The client id of the player making the call
---@param propData data The prop data to update
---@param amount number The amount to update the resource by
Lib.Net.RegisterServerCb("intprop:server:updateAmount", function(source, propData, amount)
    local cachePropData = Lib.Cache.Temp.Get("intprop", propData.id)
    -- If the prop data exists and has metadata and a resource amount
    if cachePropData and cachePropData.metadata and cachePropData.metadata.resourceAmount then
        -- Update the resource amount
        cachePropData.metadata.resourceAmount = cachePropData.metadata.resourceAmount + amount
        Lib.Cache.Temp.Update("intprop", propData.id, cachePropData)
        Lib.Log.Debug(("Changed resource amount %.3f to %.3f"):format(amount, cachePropData.metadata.resourceAmount))
        -- If the resource amount is less than or equal to 0
        if cachePropData.metadata.resourceAmount <= 0 then
            -- Remove the prop from the world after 2 seconds
            Citizen.SetTimeout(2000, function()
                RemoveProp(propData)
            end)
        end
    end
end)
