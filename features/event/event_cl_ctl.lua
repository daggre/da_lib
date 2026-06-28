-- Game-event dispatcher (controller, singleton in da_lib).
--
-- RDR3 surfaces AI/network "events" through polled queues ("groups"): each frame we
-- ask how many events are pending in a group (GetNumberOfEvents), read the hash of
-- the event at an index (GetEventAtIndex), and pull its data payload
-- (GET_EVENT_DATA / 0x57EC5FA4D4D6AFCA) into an 8-bytes-per-element buffer.
--
-- Features subscribe to a specific event (by name or hash) via the da_gameevent
-- facade -> these exports. We poll ONCE here and dispatch decoded payloads to every
-- subscriber, instead of each resource running its own poll loop. Polling is scoped
-- to only the groups that currently have subscribers, so steady cost stays minimal.
--
-- Reference + data-size table: https://github.com/femga/rdr3_discoveries/tree/master/AI/EVENTS
-- Buffer reads use the bundled DataView lib (@da_lib/features/util/dataview.lua).

local GET_EVENT_DATA = 0x57EC5FA4D4D6AFCA

-- Field types control how a decoded element is read:
--   "i"      signed int (default)        "f"     32-bit float
--   "hash"   int shown in decimal + hex  "bool"  int shown as true/false
--   "ent"    entity handle (plain int, labelled for readability)
-- Events without a `fields` list are still decoded generically as ints, labelled by
-- index. This is the single source of truth for event metadata (da_dev's capture
-- tool and any feature subscriber both read it).
local EVENTS = {
    -- Group 0 : SCRIPT_EVENT_QUEUE_AI -----------------------------------------
    { name = "EVENT_BUCKED_OFF", group = 0, size = 3, fields = { { "rider", "ent" }, { "mount", "ent" }, { "unk" }, }},
    { name = "EVENT_CALCULATE_LOOT", group = 0, size = 26 },
    { name = "EVENT_CALM_PED", group = 0, size = 4, fields = { { "calmer", "ent" }, { "mount", "ent" }, { "calmTypeId" }, { "isFullyCalmed", "bool" }, }},
    { name = "EVENT_CARRIABLE_UPDATE_CARRY_STATE", group = 0, size = 5, fields = {
        { "carriable", "ent" }, { "perpetrator", "ent" }, { "carrier", "ent" }, { "isOnHorse", "bool" }, { "isOnGround", "bool" },
    }},
    { name = "EVENT_CARRIABLE_PROMPT_INFO_REQUEST", group = 0, size = 6 },
    { name = "EVENT_CARRIABLE_VEHICLE_STOW_START", group = 0, size = 5 },
    { name = "EVENT_CARRIABLE_VEHICLE_STOW_COMPLETE", group = 0, size = 3 },
    { name = "EVENT_CHALLENGE_GOAL_COMPLETE", group = 0, size = 1, fields = { { "challengeGoalHash", "hash" }, }},
    { name = "EVENT_CHALLENGE_GOAL_UPDATE", group = 0, size = 1, fields = { { "challengeGoalHash", "hash" }, }},
    { name = "EVENT_CHALLENGE_REWARD", group = 0, size = 3, fields = { { "challengeRewardHash", "hash" }, { "unk" }, { "unk" }, }},
    { name = "EVENT_CONTAINER_INTERACTION", group = 0, size = 4, fields = { { "searcher", "ent" }, { "searched", "ent" }, { "unk" }, { "isContainerClosed", "bool" }, }},
    { name = "EVENT_CRIME_CONFIRMED", group = 0, size = 3, fields = { { "crimeTypeHash", "hash" }, { "criminal", "ent" }, { "witness" }, }},
    { name = "EVENT_DAILY_CHALLENGE_STREAK_COMPLETED", group = 0, size = 1 },
    { name = "EVENT_ENTITY_BROKEN", group = 0, size = 9, fields = {
        { "entity", "ent" }, { "unk" }, { "unk" }, { "unk" }, { "damageAmount", "f" }, { "unk" }, { "x", "f" }, { "y", "f" }, { "z", "f" },
    }},
    { name = "EVENT_ENTITY_DAMAGED", group = 0, size = 9, fields = {
        { "entity", "ent" }, { "damager", "ent" }, { "weaponHash", "hash" }, { "ammoHash", "hash" }, { "damageAmount", "f" }, { "unk" }, { "x", "f" }, { "y", "f" }, { "z", "f" },
    }},
    { name = "EVENT_ENTITY_DESTROYED", group = 0, size = 9, fields = {
        { "entity", "ent" }, { "damager", "ent" }, { "weaponHash", "hash" }, { "ammoHash", "hash" }, { "damageAmount", "f" }, { "unk" }, { "x", "f" }, { "y", "f" }, { "z", "f" },
    }},
    { name = "EVENT_ENTITY_DISARMED", group = 0, size = 4, fields = { { "victim", "ent" }, { "damager", "ent" }, { "weaponHash", "hash" }, { "unk" }, }},
    { name = "EVENT_ENTITY_EXPLOSION", group = 0, size = 6, fields = { { "ped", "ent" }, { "unk" }, { "weaponHash", "hash" }, { "x", "f" }, { "y", "f" }, { "z", "f" }, }},
    { name = "EVENT_ENTITY_HOGTIED", group = 0, size = 3, fields = { { "hogtied", "ent" }, { "hogtier", "ent" }, { "unk" }, }},
    { name = "EVENT_HEADSHOT_BLOCKED_BY_HAT", group = 0, size = 2, fields = { { "victim", "ent" }, { "inflictor", "ent" }, }},
    { name = "EVENT_HELP_TEXT_REQUEST", group = 0, size = 4 },
    { name = "EVENT_HITCH_ANIMAL", group = 0, size = 4, fields = { { "rider", "ent" }, { "mount", "ent" }, { "isAnimalHitched", "bool" }, { "hitchingTypeId" }, }},
    { name = "EVENT_HOGTIED_ENTITY_PICKED_UP", group = 0, size = 2, fields = { { "hogtied", "ent" }, { "carrier", "ent" }, }},
    { name = "EVENT_HORSE_BROKEN", group = 0, size = 3, fields = { { "rider", "ent" }, { "horse", "ent" }, { "horseBrokenEventTypeId" }, }},
    { name = "EVENT_IMPENDING_SAMPLE_PROMPT", group = 0, size = 2 },
    { name = "EVENT_INVENTORY_ITEM_PICKED_UP", group = 0, size = 5, fields = {
        { "itemHash", "hash" }, { "entityModel", "hash" }, { "isItemWasUsed", "bool" }, { "isItemWasBought", "bool" }, { "entity", "ent" },
    }},
    { name = "EVENT_INVENTORY_ITEM_REMOVED", group = 0, size = 1, fields = { { "itemHash", "hash" }, }},
    { name = "EVENT_ITEM_PROMPT_INFO_REQUEST", group = 0, size = 2, fields = { { "entity", "ent" }, { "itemHash", "hash" }, }},
    { name = "EVENT_LOOT", group = 0, size = 36 },
    { name = "EVENT_LOOT_COMPLETE", group = 0, size = 3, fields = { { "looter", "ent" }, { "looted", "ent" }, { "isLootSuccess", "bool" }, }},
    { name = "EVENT_LOOT_PLANT_START", group = 0, size = 36 },
    { name = "EVENT_LOOT_VALIDATION_FAIL", group = 0, size = 2, fields = { { "failReasonId" }, { "looted", "ent" }, }},
    { name = "EVENT_MISS_INTENDED_TARGET", group = 0, size = 3, fields = { { "shooter", "ent" }, { "target", "ent" }, { "weaponHash", "hash" }, }},
    { name = "EVENT_MOUNT_OVERSPURRED", group = 0, size = 6, fields = {
        { "rider", "ent" }, { "mount", "ent" }, { "rageAmount", "f" }, { "timesOverspurred" }, { "maxOverspurs" }, { "unk" },
    }},

    -- Group 1 : SCRIPT_EVENT_QUEUE_NETWORK -----------------------------------
    { name = "EVENT_NETWORK_AWARD_CLAIMED", group = 1, size = 12 },
    { name = "EVENT_NETWORK_BOUNTY_REQUEST_COMPLETE", group = 1, size = 7 },
    { name = "EVENT_NETWORK_BULLET_IMPACTED_MULTIPLE_PEDS", group = 1, size = 4, fields = { { "shooter", "ent" }, { "numImpacted" }, { "numKilled" }, { "numIncapacitated" }, }},
    { name = "EVENT_NETWORK_CASHINVENTORY_TRANSACTION", group = 1, size = 6 },
    { name = "EVENT_NETWORK_CREW_CREATION", group = 1, size = 10 },
    { name = "EVENT_NETWORK_CREW_DISBANDED", group = 1, size = 2 },
    { name = "EVENT_NETWORK_CREW_INVITE_RECEIVED", group = 1, size = 11 },
    { name = "EVENT_NETWORK_CREW_JOINED", group = 1, size = 2 },
    { name = "EVENT_NETWORK_CREW_KICKED", group = 1, size = 2 },
    { name = "EVENT_NETWORK_CREW_LEFT", group = 1, size = 2 },
    { name = "EVENT_NETWORK_CREW_RANK_CHANGE", group = 1, size = 7 },
    { name = "EVENT_NETWORK_DAMAGE_ENTITY", group = 1, size = 32, fields = {
        { "victim", "ent" }, { "killer", "ent" }, { "damage" }, { "isVictimDestroyed", "bool" },
        { "isVictimIncapacitated", "bool" }, { "weaponHash", "hash" }, { "ammoHash", "hash" },
        { "instigatedWeaponUsed" }, { "victimSpeed" }, { "damagerSpeed" },
        { "isResponsibleForCollision", "bool" }, { "isHeadShot", "bool" },
        { "isWithMeleeWeapon", "bool" }, { "isVictimExecuted", "bool" },
        { "victimBledOut", "bool" }, { "damagerWasScopedIn", "bool" },
        { "damagerSpecialAbilityActive", "bool" }, { "victimHogtied", "bool" },
        { "victimMounted", "bool" }, { "victimInVehicle", "bool" }, { "victimInCover", "bool" },
        { "damagerShotLastBullet", "bool" }, { "victimKilledByStealth", "bool" },
        { "victimKilledByTakedown", "bool" }, { "victimKnockedOut", "bool" },
        { "isVictimTranquilized", "bool" }, { "victimKilledByStandardMelee", "bool" },
        { "victimMissionEntity", "bool" }, { "victimFleeing", "bool" },
        { "victimInCombat", "bool" }, { "unk" }, { "isSuicide", "bool" },
    }},
    { name = "EVENT_NETWORK_GANG", group = 1, size = 18 },
    { name = "EVENT_NETWORK_GANG_WAYPOINT_CHANGED", group = 1, size = 3 },
    { name = "EVENT_NETWORK_HOGTIE_BEGIN", group = 1, size = 2, fields = { { "victim", "ent" }, { "perpetrator", "ent" }, }},
    { name = "EVENT_NETWORK_HOGTIE_END", group = 1, size = 2, fields = { { "victim", "ent" }, { "perpetrator", "ent" }, }},
    { name = "EVENT_NETWORK_HUB_UPDATE", group = 1, size = 1, fields = { { "updateHash", "hash" }, }},
    { name = "EVENT_NETWORK_INCAPACITATED_ENTITY", group = 1, size = 4, fields = { { "victim", "ent" }, { "damager", "ent" }, { "weaponHash", "hash" }, { "damage" }, }},
    { name = "EVENT_NETWORK_LASSO_ATTACH", group = 1, size = 2, fields = { { "victim", "ent" }, { "perpetrator", "ent" }, }},
    { name = "EVENT_NETWORK_LASSO_DETACH", group = 1, size = 2, fields = { { "victim", "ent" }, { "perpetrator", "ent" }, }},
    { name = "EVENT_NETWORK_LOOT_CLAIMED", group = 1, size = 9 },
    { name = "EVENT_NETWORK_MINIGAME_REQUEST_COMPLETE", group = 1, size = 6 },
    { name = "EVENT_NETWORK_PED_DISARMED", group = 1, size = 3, fields = { { "victim", "ent" }, { "damager", "ent" }, { "weaponHash", "hash" }, }},
    { name = "EVENT_NETWORK_PED_HAT_SHOT_OFF", group = 1, size = 3, fields = { { "victim", "ent" }, { "damager", "ent" }, { "weaponHash", "hash" }, }},
    { name = "EVENT_NETWORK_PERMISSION_CHECK_RESULT", group = 1, size = 2 },
    { name = "EVENT_NETWORK_PICKUP_COLLECTION_FAILED", group = 1, size = 3 },
    { name = "EVENT_NETWORK_PICKUP_RESPAWNED", group = 1, size = 2 },
    { name = "EVENT_NETWORK_PLAYER_COLLECTED_PICKUP", group = 1, size = 8, fields = {
        { "collected", "ent" }, { "collector" }, { "pickupTypeHash", "hash" }, { "unk" }, { "pickupModel", "hash" }, { "ammoAmount" }, { "ammoTypeHash", "hash" }, { "unk" },
    }},
    { name = "EVENT_NETWORK_PLAYER_COLLECTED_PORTABLE_PICKUP", group = 1, size = 3 },
    { name = "EVENT_NETWORK_PLAYER_DROPPED_PORTABLE_PICKUP", group = 1, size = 3 },
    { name = "EVENT_NETWORK_PLAYER_JOIN_SCRIPT", group = 1, size = 41 },
    { name = "EVENT_NETWORK_PLAYER_LEFT_SCRIPT", group = 1, size = 41 },
    { name = "EVENT_NETWORK_PLAYER_JOIN_SESSION", group = 1, size = 10 },
    { name = "EVENT_NETWORK_PLAYER_LEFT_SESSION", group = 1, size = 10 },
    { name = "EVENT_NETWORK_PLAYER_MISSED_SHOT", group = 1, size = 9 },
    { name = "EVENT_NETWORK_POSSE_CREATED", group = 1, size = 10 },
    { name = "EVENT_NETWORK_POSSE_DATA_CHANGED", group = 1, size = 2 },
    { name = "EVENT_NETWORK_POSSE_DISBANDED", group = 1, size = 2 },
    { name = "EVENT_NETWORK_POSSE_EX_ADMIN_DISBANDED", group = 1, size = 9 },
    { name = "EVENT_NETWORK_POSSE_EX_INACTIVE_DISBANDED", group = 1, size = 10 },
    { name = "EVENT_NETWORK_POSSE_JOINED", group = 1, size = 2 },
    { name = "EVENT_NETWORK_POSSE_LEADER_SET_ACTIVE", group = 1, size = 23 },
    { name = "EVENT_NETWORK_POSSE_LEFT", group = 1, size = 1 },
    { name = "EVENT_NETWORK_POSSE_MEMBER_DISBANDED", group = 1, size = 23 },
    { name = "EVENT_NETWORK_POSSE_MEMBER_JOINED", group = 1, size = 23 },
    { name = "EVENT_NETWORK_POSSE_MEMBER_KICKED", group = 1, size = 23 },
    { name = "EVENT_NETWORK_POSSE_MEMBER_LEFT", group = 1, size = 23 },
    { name = "EVENT_NETWORK_POSSE_MEMBER_SET_ACTIVE", group = 1, size = 23 },
    { name = "EVENT_NETWORK_PROJECTILE_ATTACHED", group = 1, size = 6, fields = { { "damager", "ent" }, { "victim", "ent" }, { "x", "f" }, { "y", "f" }, { "z", "f" }, { "weaponHash", "hash" }, }},
    { name = "EVENT_NETWORK_PROJECTILE_NO_DAMAGE_IMPACT", group = 1, size = 2, fields = { { "ped", "ent" }, { "ammoHash", "hash" }, }},
    { name = "EVENT_NETWORK_REVIVED_ENTITY", group = 1, size = 2, fields = { { "victim", "ent" }, { "reviver", "ent" }, }},
    { name = "EVENT_NETWORK_SESSION_EVENT", group = 1, size = 10 },
    { name = "EVENT_NETWORK_SESSION_MERGE_END", group = 1, size = 1 },
    { name = "EVENT_NETWORK_SESSION_MERGE_START", group = 1, size = 1 },
    { name = "EVENT_NETWORK_VEHICLE_LOOTED", group = 1, size = 3, fields = { { "looter", "ent" }, { "vehicle", "ent" }, { "unk" }, }},
    { name = "EVENT_NETWORK_VEHICLE_UNDRIVABLE", group = 1, size = 3, fields = { { "vehicle", "ent" }, { "damager", "ent" }, { "unk" }, }},

    -- Group 0 (continued) ----------------------------------------------------
    { name = "EVENT_OBJECT_INTERACTION", group = 0, size = 10, fields = {
        { "ped", "ent" }, { "interactionEntity", "ent" }, { "itemHash", "hash" }, { "itemQuantity" }, { "unk" }, { "unk" }, { "unk" }, { "unk" }, { "scenarioPointId" }, { "unk" },
    }},
    { name = "EVENT_PED_ANIMAL_INTERACTION", group = 0, size = 3, fields = { { "ped", "ent" }, { "animal", "ent" }, { "interactionTypeHash", "hash" }, }},
    { name = "EVENT_PED_CREATED", group = 0, size = 1, fields = { { "ped", "ent" }, }},
    { name = "EVENT_PED_DESTROYED", group = 0, size = 1, fields = { { "ped", "ent" }, }},
    { name = "EVENT_PED_HAT_KNOCKED_OFF", group = 0, size = 2, fields = { { "ped", "ent" }, { "hat", "ent" }, }},
    { name = "EVENT_PED_WHISTLE", group = 0, size = 2, fields = { { "whistler", "ent" }, { "whistleType" }, }},
    { name = "EVENT_PICKUP_CARRIABLE", group = 0, size = 4, fields = { { "carrier", "ent" }, { "carriable", "ent" }, { "isPickupDoneFromParent", "bool" }, { "carrierMount", "ent" }, }},
    { name = "EVENT_PLACE_CARRIABLE_ONTO_PARENT", group = 0, size = 6, fields = {
        { "perpetrator", "ent" }, { "carriable", "ent" }, { "carrier", "ent" }, { "unk" }, { "isCarriedEntityAPelt", "bool" }, { "itemHash", "hash" },
    }},
    { name = "EVENT_PLAYER_COLLECTED_AMBIENT_PICKUP", group = 0, size = 8, fields = {
        { "pickupNameHash", "hash" }, { "pickupEntity", "ent" }, { "player" }, { "pickupModel", "hash" }, { "unk" }, { "unk" }, { "itemQuantity" }, { "itemHash", "hash" },
    }},
    { name = "EVENT_PLAYER_ESCALATED_PED", group = 0, size = 2, fields = { { "player", "ent" }, { "escalatedPed", "ent" }, }},
    { name = "EVENT_PLAYER_HAT_EQUIPPED", group = 0, size = 10, fields = {
        { "player", "ent" }, { "hat", "ent" }, { "drawableHash", "hash" }, { "albedoHash", "hash" }, { "normalHash", "hash" }, { "materialHash", "hash" }, { "paletteHash", "hash" }, { "tint1" }, { "tint2" }, { "tint3" },
    }},
    { name = "EVENT_PLAYER_HAT_KNOCKED_OFF", group = 0, size = 5, fields = { { "player", "ent" }, { "thrower", "ent" }, { "hat", "ent" }, { "unk" }, { "unk" }, }},
    { name = "EVENT_PLAYER_HORSE_AGITATED_BY_ANIMAL", group = 0, size = 4, fields = { { "horse", "ent" }, { "animal", "ent" }, { "unk" }, { "unk" }, }},
    { name = "EVENT_PLAYER_MOUNT_WILD_HORSE", group = 0, size = 1, fields = { { "wildHorse", "ent" }, }},
    { name = "EVENT_PLAYER_PROMPT_TRIGGERED", group = 0, size = 10, fields = {
        { "promptTypeId" }, { "unk" }, { "target", "ent" }, { "discoveredItem" }, { "x", "f" }, { "y", "f" }, { "z", "f" }, { "discoverableEntityTypeId" }, { "unk" }, { "kitEmoteActionHash", "hash" },
    }},
    { name = "EVENT_RAN_OVER_PED", group = 0, size = 2, fields = { { "unk" }, { "ped", "ent" }, }},
    { name = "EVENT_REVIVE_ENTITY", group = 0, size = 3, fields = { { "victim", "ent" }, { "reviver", "ent" }, { "itemHash", "hash" }, }},
    { name = "EVENT_SHOCKING_ITEM_STOLEN", group = 0, size = 3, fields = { { "ped", "ent" }, { "ped2", "ent" }, { "carriable", "ent" }, }},
    { name = "EVENT_SHOT_FIRED_BULLET_IMPACT", group = 0, size = 1, fields = { { "entity", "ent" }, }},
    { name = "EVENT_SHOT_FIRED_WHIZZED_BY", group = 0, size = 1, fields = { { "entity", "ent" }, }},
    { name = "EVENT_STAT_VALUE_CHANGED", group = 0, size = 2, fields = { { "statValueTypeHash", "hash" }, { "unk" }, }},
    { name = "EVENT_TRIGGERED_ANIMAL_WRITHE", group = 0, size = 2, fields = { { "animal", "ent" }, { "damager", "ent" }, }},
    { name = "EVENT_VEHICLE_CREATED", group = 0, size = 1, fields = { { "vehicle", "ent" }, }},
    { name = "EVENT_VEHICLE_DESTROYED", group = 0, size = 1, fields = { { "vehicle", "ent" }, }},

    -- Group 2 : scenario -----------------------------------------------------
    { name = "EVENT_SCENARIO_ADD_PED", group = 2, size = 2 },
    { name = "EVENT_SCENARIO_DESTROY_PROP", group = 2, size = 2 },
    { name = "EVENT_SCENARIO_REMOVE_PED", group = 2, size = 2 },

    -- Group 3 : UI -----------------------------------------------------------
    { name = "EVENT_UI_ITEM_INSPECT_ACTIONED", group = 3, size = 6 },
    { name = "EVENT_UI_QUICK_ITEM_USED", group = 3, size = 6 },
}

-- name (and hash) -> def. Subscribers may pass either.
local byName = {}
local byHash = {}
for _, def in ipairs(EVENTS) do
    byName[def.name] = def
    byHash[GetHashKey(def.name)] = def
end

-- A handler from another resource arrives across the export boundary as a CFX
-- function-reference table, not a Lua function — but it is still callable. Accept
-- both (mirrors cache_lazy.lua's __newindex assert).
local function isCallable(fn)
    return type(fn) == "function"
        or (type(fn) == "table" and fn["__cfx_functionReference"] ~= nil)
end

local function defFor(nameOrHash)
    if type(nameOrHash) == "string" then
        return byName[nameOrHash] or byHash[GetHashKey(nameOrHash)]
    end
    return byHash[nameOrHash]
end

-- Decode one pending event's payload into a typed list { {label,t,value,raw}, ... }.
local function decode(def, index)
    local view = DataView.ArrayBuffer(math.max(8 * def.size, 64))
    local ok = Citizen.InvokeNative(GET_EVENT_DATA, def.group, index, view:Buffer(), def.size)
    if not ok then return nil end

    local data = {}
    for k = 0, def.size - 1 do
        local off = k * 8
        local field = def.fields and def.fields[k + 1]
        local t = field and field[2] or "i"
        local raw = view:GetInt32(off)
        data[k + 1] = {
            label = field and field[1] or ("[" .. k .. "]"),
            t = t,
            raw = raw,
            value = (t == "f") and view:GetFloat32(off) or raw,
        }
    end
    return data
end

-- Name-keyed view of a decoded payload: { carrier=.., isCarriedEntityAPelt=true, .. }.
-- Bools are surfaced as Lua booleans; everything else as its numeric value.
local function toMap(data)
    local map = {}
    for _, f in ipairs(data) do
        map[f.label] = (f.t == "bool") and (f.value ~= 0) or f.value
    end
    return map
end

-- ===================== subscription registry =====================

local GameEventController = {
    nextId = 0,
    subs = {},      -- [eventName] = { [id] = { fn, resource } }
    anySubs = {},   -- [id] = { fn, resource }
    idIndex = {},   -- [id] = { name | "*" } so off(id) can find its bucket
    groupSubs = {}, -- [group] = count of subscribers needing that group (anySubs hit all)
    polling = {},   -- [group] = true while a poll thread is alive
}

local ALL_GROUPS = { 0, 1, 2, 3 }

local function groupNeedsPoll(group)
    return (GameEventController.groupSubs[group] or 0) > 0
end

-- One thread per group, alive only while that group has subscribers. Decodes each
-- pending event once and fans it out to its name subscribers + every anySub.
local function startPoll(group)
    if GameEventController.polling[group] then return end
    GameEventController.polling[group] = true
    Citizen.CreateThread(function()
        while groupNeedsPoll(group) do
            local count = GetNumberOfEvents(group)
            for i = 0, count - 1 do
                local def = byHash[GetEventAtIndex(group, i)]
                if def then
                    local named = GameEventController.subs[def.name]
                    local hasNamed = named and next(named) ~= nil
                    local hasAny = next(GameEventController.anySubs) ~= nil
                    if hasNamed or hasAny then
                        local data = decode(def, i)
                        if data then
                            local ev = { name = def.name, group = def.group, def = def, raw = data, fields = toMap(data) }
                            if hasNamed then
                                for _, s in pairs(named) do
                                    local ok, err = pcall(s.fn, ev)
                                    if not ok then log.error("gameevent handler error (" .. def.name .. "): " .. tostring(err)) end
                                end
                            end
                            for _, s in pairs(GameEventController.anySubs) do
                                local ok, err = pcall(s.fn, ev)
                                if not ok then log.error("gameevent anyhandler error (" .. def.name .. "): " .. tostring(err)) end
                            end
                        end
                    end
                end
            end
            Citizen.Wait(0)
        end
        GameEventController.polling[group] = false
    end)
end

local function bumpGroup(group, delta)
    GameEventController.groupSubs[group] = (GameEventController.groupSubs[group] or 0) + delta
    if GameEventController.groupSubs[group] > 0 then startPoll(group) end
end

-- A named subscription needs only that event's group; an anySub needs all groups.
local function addGroupRef(scope)
    if scope == "*" then
        for _, g in ipairs(ALL_GROUPS) do bumpGroup(g, 1) end
    else
        local def = byName[scope]
        if def then bumpGroup(def.group, 1) end
    end
end

local function removeGroupRef(scope)
    if scope == "*" then
        for _, g in ipairs(ALL_GROUPS) do bumpGroup(g, -1) end
    else
        local def = byName[scope]
        if def then bumpGroup(def.group, -1) end
    end
end

local function subscribe(nameOrHash, fn, resource)
    local def = defFor(nameOrHash)
    if not def then
        log.error("onGameEvent: unknown event " .. tostring(nameOrHash))
        return nil
    end
    if not isCallable(fn) then
        log.error("onGameEvent: handler must be a function (" .. def.name .. ")")
        return nil
    end
    GameEventController.nextId = GameEventController.nextId + 1
    local id = GameEventController.nextId
    GameEventController.subs[def.name] = GameEventController.subs[def.name] or {}
    GameEventController.subs[def.name][id] = { fn = fn, resource = resource }
    GameEventController.idIndex[id] = def.name
    addGroupRef(def.name)
    return id
end

local function subscribeAny(fn, resource)
    if not isCallable(fn) then
        log.error("onAnyGameEvent: handler must be a function")
        return nil
    end
    GameEventController.nextId = GameEventController.nextId + 1
    local id = GameEventController.nextId
    GameEventController.anySubs[id] = { fn = fn, resource = resource }
    GameEventController.idIndex[id] = "*"
    addGroupRef("*")
    return id
end

local function unsubscribe(id)
    local scope = GameEventController.idIndex[id]
    if not scope then return end
    if scope == "*" then
        GameEventController.anySubs[id] = nil
    else
        local bucket = GameEventController.subs[scope]
        if bucket then bucket[id] = nil end
    end
    GameEventController.idIndex[id] = nil
    removeGroupRef(scope)
end

-- ===================== exports =====================

exports("onGameEvent", function(nameOrHash, fn)
    return subscribe(nameOrHash, fn, GetInvokingResource())
end)

exports("onAnyGameEvent", function(fn)
    return subscribeAny(fn, GetInvokingResource())
end)

exports("offGameEvent", function(id)
    unsubscribe(id)
end)

-- Read-only copy of the event metadata, for inspection / da_dev formatting.
exports("gameEventDefs", function()
    return EVENTS
end)

-- ===================== cleanup =====================

AddEventHandler("onResourceStop", function(resourceName)
    for id, scope in pairs(GameEventController.idIndex) do
        local entry = (scope == "*") and GameEventController.anySubs[id]
            or (GameEventController.subs[scope] and GameEventController.subs[scope][id])
        if entry and entry.resource == resourceName then
            unsubscribe(id)
        end
    end
end)

-- ===================== cli inspection =====================

cli.add_cmd("gameevent", { desc = "Game-event dispatcher commands" })
cli.add_subcmd("gameevent", "subs", { desc = "List active subscriptions",
    fn = function()
        log.info("-- gameevent subscriptions --")
        for name, bucket in pairs(GameEventController.subs) do
            for id, s in pairs(bucket) do
                log.info(string.format("  %-40s id=%d  %s", name, id, tostring(s.resource)))
            end
        end
        for id, s in pairs(GameEventController.anySubs) do
            log.info(string.format("  %-40s id=%d  %s", "* (any)", id, tostring(s.resource)))
        end
        log.info("-- polling groups --")
        for g, n in pairs(GameEventController.groupSubs) do
            if n > 0 then log.info(string.format("  group %d : %d refs", g, n)) end
        end
    end,
})
