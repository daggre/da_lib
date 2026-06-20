-- VORP framework adapter (server). See vorp_cl.lua for the registration pattern.
-- Only override functions where VORP differs from the Default adapter; anything
-- left out falls through to Default.
if DAAPI.ActiveFramework ~= "VORP" then return end
log.debug("Setting up Framework API: " .. DAAPI.ActiveFramework)

local FW = {}

-- TODO(parked): implement VORP server contract (removeItem, addItem, addSkill, ...)

for name, fn in pairs(FW) do
    DAAPI.Framework[name] = fn
end
