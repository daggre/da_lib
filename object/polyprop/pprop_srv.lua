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
    Lib.Log.DebugVerbose("Adding polyprop:", data)
    Lib.Cache.Temp.Add("polyprops", data.id, data, true)
    TriggerClientEvent("polyprops:client:add", -1, data)
end

local RemoveProp = function(data)
    if not data or not data.id then return; end
    local removedData = Lib.Cache.Temp.Remove("polyprops", data.id)
    if not removedData then
        Lib.Log.DebugVerbose(("Not removing prop: %s"):format(data.id))
        return
    end
    Lib.Log.DebugVerbose("Removing:", data.id, removedData)
    TriggerClientEvent("polyprops:client:remove", -1, removedData)
    return removedData
end

RegisterNetEvent("polyprops:server:add")
AddEventHandler("polyprops:server:add", function(data)
    AddProp(data)
end)

Lib.Net.RegisterServerCb("polyprops:server:remove", function(source, data)
    return RemoveProp(data)
end)

Lib.Net.RegisterServerCb("polyprops:server:updateAmount", function(source, data, amount, removalDelay)
    local cachePropData = Lib.Cache.Temp.Get("polyprops", data.id)
    if cachePropData and cachePropData.metadata and cachePropData.metadata.resourceAmount then
        cachePropData.metadata.resourceAmount = cachePropData.metadata.resourceAmount + amount
        Lib.Cache.Temp.Update("polyprops", data.id, cachePropData)
        Lib.Log.Debug(("Changed resource amount %.3f to %.3f"):format(amount, cachePropData.metadata.resourceAmount))
        Lib.Log.DebugVerbose(cachePropData)
        if cachePropData.resourceAmount <= 0 then
            Citizen.SetTimeOut(removalDelay, function()
                RemoveProp(data)
            end)
        end
    else
        Lib.Log.Warning(("Could not find prop to udpate: %s"):format(data.id))
    end
end)
