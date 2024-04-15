--- Copyright © 2024 Joshua Nelson

local PropsId = 1
local GetPropId = function(data)
    local propId = PropsId
    PropsId = PropsId + 1
    return ("%s_%d"):format(data.objectHash, propId)
end

local AddProp = function(data)
    data.id = data.id or GetPropId(data)
    data.metadata = data.metadata or {}
    data.metadata.timeCreated = data.metadata.timeCreated or os.time()
    Lib.Log.DebugVerbose("Adding intprop:", data)
    Lib.Cache.Temp.Add("intprop", data.id, data, true)
    TriggerClientEvent("intprop:client:add", -1, data)
end

local RemoveProp = function(data)
    if not data or not data.id then return; end
    local removedData = Lib.Cache.Temp.Remove("intprop", data.id)
    if not removedData then
        Lib.Log.DebugVerbose(("Not removing prop: %s"):format(data.id))
        return
    end
    Lib.Log.DebugVerbose("Removing:", data.id, removedData)
    TriggerClientEvent("intprop:client:remove", -1, removedData)
    return removedData
end

RegisterNetEvent("intprop:server:add")
AddEventHandler("intprop:server:add", function(data)
    AddProp(data)
end)

Lib.Net.RegisterServerCb("intprop:server:remove", function(source, data)
    return RemoveProp(data)
end)

Lib.Net.RegisterServerCb("intprop:server:updateAmount", function(source, propData, amount, removalDelay)
    local cachePropData = Lib.Cache.Temp.Get("intprop", propData.id)
    if cachePropData and cachePropData.metadata and cachePropData.metadata.resourceAmount then
        cachePropData.metadata.resourceAmount = cachePropData.metadata.resourceAmount + amount
        Lib.Cache.Temp.Update("intprop", propData.id, cachePropData)
        Lib.Log.Debug(("Changed resource amount %.3f to %.3f"):format(amount, cachePropData.metadata.resourceAmount))
        if cachePropData.metadata.resourceAmount <= 0 then
            Citizen.SetTimeOut(removalDelay, function()
                RemoveProp(propData)
            end)
        end
    -- else
    --     Lib.Log.Warn(("Could not find prop to udpate: %s"):format(propData.id))
    end
end)
