-- The interact VOCABULARY. Kinds and the types each kind admits.
--
-- This is the one source. Two things read it and neither maintains its own copy:
--
--   da_lib/features/interact  — validates a registration. A typo'd `type` is a hard error at
--                               registration, not an interact that silently never matches anything.
--   da_anims                  — derives its condition keyword NAMES from it. `kind` + `type` gives
--                               the keyword: pickup + Rake = `pickupRake`, interact + WaterTrough =
--                               `interactWaterTrough`. Exactly the names da_xanims hand-maintained.
--
-- WHY DATA, and not "the keyword exists because someone registered an interact of that type" (which
-- is what the PRD proposed): a scenario's `when` keys are validated against the keyword list AT
-- SCENARIO REGISTRATION. If the keyword only came into being when da_ranching registered a trough,
-- then whether `when = { interactWaterTrough = true }` is a valid scenario or a hard error would
-- depend on whether da_ranching loaded before da_anims. Load order would decide whether a keyword
-- was real. As data, the vocabulary exists before anybody registers anything, drift is still
-- impossible (there is only one list), and adding a type is still a one-line edit.

dat = dat or {}

dat.interact = {
    -- The kinds. `interact` is the default and the one most scenarios gate on.
    kinds = { "interact", "pickup", "farm", "turnIn", "wagonTurnIn" },

    types = {
        -- Point at it and do something to it.
        interact = {
            "Banjo", "Guitar", "Pitchfork", "ShortFence", "TallFence", "Trough",
            "WaterPump", "WaterTrough", "Wheelbarrow", "AnimalStall",
        },
        -- Point at it and pick it up. The tool interacts da_ranching owns.
        pickup = {
            "Bale", "Bucket", "Crate", "Pitchfork", "Rake", "Sack", "Shovel", "Spade",
        },
        -- Workable ground: what the crop under your feet admits being done to it.
        farm = {
            "Handpick", "HandSpade", "Kneel", "Rake", "Root", "Shell", "Shovel", "Tree",
        },
        -- Hand it in on foot / into a wagon.
        turnIn      = { "Bale", "Crate", "Sack" },
        wagonTurnIn = { "Bale", "Crate", "Sack" },
    },
}

-- kind + type -> keyword. The one rule, in one place, so the registry and the condition batch
-- cannot disagree about what a keyword is called.
dat.interact.keyword = function(kind, typ)
    return kind .. typ:sub(1, 1):upper() .. typ:sub(2)
end

-- Every keyword the vocabulary admits. da_anims declares these to its condition batch.
dat.interact.keywords = function()
    local out = {}
    for _, kind in ipairs(dat.interact.kinds) do
        for _, typ in ipairs(dat.interact.types[kind] or {}) do
            out[#out + 1] = dat.interact.keyword(kind, typ)
        end
    end
    return out
end

dat.interact.valid = function(kind, typ)
    for _, t in ipairs(dat.interact.types[kind] or {}) do
        if t == typ then return true end
    end
    return false
end
