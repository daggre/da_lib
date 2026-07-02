local Hud = {}

Hud.Icon = {
    VisibilityIndex = {
        -- These enum names begin at 0, so we will need to -1 if working in LUA
        "STAMINA", "STAMINA_CORE",
        "DEADEYE", "DEADEYE_CORE",
        "HEALTH", "HEALTH_CORE",
        "HORSE_HEALTH", "HORSE_HEALTH_CORE",
        "HORSE_STAMINA", "HORSE_STAMINA_CORE",
        "HORSE_COURAGE", "HORSE_COURAGE_CORE",
    },
    WAIT_TO_HIDE = 0,
    ALWAYS_SHOW = 1,
    ALWAYS_HIDE = 2,
    ALWAYS_BLINK = 3,
}

Hud.Icon.Set = function(index, value)
    UitutorialSetRpgIconVisibility(index, value)
end
Hud.Icon.SetAll = function(value)
    for i, c in ipairs(Hud.Icon.VisibilityIndex) do
        Hud.Icon.Set(i-1, value)
    end
end

_ENV.da_hud = Hud
