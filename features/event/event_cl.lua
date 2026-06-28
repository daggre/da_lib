-- Game-event facade: the stateless stub each resource includes. Every method
-- forwards to the single game-event dispatcher in da_lib via exports. Carries no
-- state itself (same pattern as the Mode facade).
--
--   local h = da_gameevent.on("EVENT_PLACE_CARRIABLE_ONTO_PARENT", function(ev)
--       -- ev = { name, group, def, raw = {typed list}, fields = {name-keyed map} }
--       print(ev.fields.carrier, ev.fields.carriable, ev.fields.isCarriedEntityAPelt)
--   end)
--   ...
--   da_gameevent.off(h)
local GameEvent = {}

GameEvent.on    = function(name, fn) return exports.da_lib:onGameEvent(name, fn) end
GameEvent.onAny = function(fn)       return exports.da_lib:onAnyGameEvent(fn) end
GameEvent.off   = function(handle)   return exports.da_lib:offGameEvent(handle) end
GameEvent.defs  = function()         return exports.da_lib:gameEventDefs() end

_ENV.da_gameevent = GameEvent
