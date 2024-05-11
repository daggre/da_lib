Lib.Check.IsJob = function(job, active)
    if Lib.API.Active then
        return Lib.API.IsJob(job, active)
    end
    Lib.Log.Debug(("API not active, local function '%s' not implemented"):format("Check.IsJob"))
end
