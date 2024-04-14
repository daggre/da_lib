Lib.Ped.Create = function(modelHash, coords, option)
    if Lib.API.Active then
        Lib.API.CreatePed(modelHash, coords, option)
        return
    end
    Lib.Log.Debug(("API not active, local function '%s' not implemented"):format("Drink"))
end
