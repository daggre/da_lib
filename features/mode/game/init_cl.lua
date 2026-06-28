da_mode.register({
    name = "game",
    priority = 1, -- Lowest priority
    onActivate = function() log.spam("da_mode game startFn") end,
    onDeactivate = function() log.spam("da_mode game stopFn") end,
    -- Baseline game-level keys are registered by their owning resources via
    -- da_mode.addGameKey(...) (e.g. da_xanims registers the x key). They ride this
    -- "game" baseline and are suppressed whenever an active mode sets disableGame.
})

Citizen.CreateThread(function() da_mode.activate("game") end)
