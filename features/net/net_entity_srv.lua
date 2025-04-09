local netEntities = {}

local UID = 0

local _getUID = function()
    UID = UID + 1
    return UID
end

RegisterNetEvent("da_lib.netent.add")
AddEventHandler("da_lib.netent.add", function(data)
    local uid = tostring(_getUID())
    if not netEntities[uid] then
        netEntities[uid] = data
        TriggerClientEvent("da_lib.netent.sync", -1, uid, data)
    end
end)

RegisterNetEvent("da_lib.netent.request")
AddEventHandler("da_lib.netent.request", function()
    local src = source
    TriggerClientEvent("da_lib.netent.syncfull", src, netEntities)
end)

RegisterNetEvent("da_lib.netent.remove")
AddEventHandler("da_lib.netent.remove", function(uid)
    if netEntities[uid] then
        netEntities[uid] = nil
        TriggerClientEvent("da_lib.netent.remove", -1, uid)
    end
end)
