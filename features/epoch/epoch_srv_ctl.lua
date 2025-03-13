-- Requires da_lib/lib/net_srv.lua
RegisterBlockingServerEvent("da_lib.getEpoch", function()
    return os.time()
end)
