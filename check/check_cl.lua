---Check if a player has a specific job or job category
---@param job string the job name or job category
---@param active boolean|nil whether the player must be on duty (clocked in)
---@return boolean jobStatus does the player have the job nad is clocked in
Lib.Check.IsJob = function(job, active)
    if Lib.API.Active then
        return Lib.API.IsJob(job, active)
    end
    return true
end
