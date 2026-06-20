-- VORP framework adapter (client).
-- Registration pattern for every framework adapter:
--   1. self-guard on the `framework` convar
--   2. build a table of contract functions this framework overrides
--   3. merge into the shared DAAPI.Framework table IN PLACE (never replace it),
--      so the live dispatch in api_sh.lua sees the overrides.
-- Only override functions where VORP differs from the Default adapter; anything
-- left out falls through to Default.
if DAAPI.ActiveFramework ~= "VORP" then return end
log.debug("Setting up Framework API: " .. DAAPI.ActiveFramework)

local FW = {}

-- TODO(parked): implement VORP client contract (notify, hasItems, eat, consume, ...)

for name, fn in pairs(FW) do
    DAAPI.Framework[name] = fn
end
