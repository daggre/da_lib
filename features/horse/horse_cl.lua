-- da_horse: spawn horses and equip/remove tack on a horse ped, plus capture and
-- persist tack *loadouts* (saddle + equipment) independent of any horse — a
-- loadout is built/saved by slot and applied to a horse later.
--
-- Horse tack rides the SAME metaped/shop-item system as player clothing
-- (eMetaPedType includes MPT_ANIMAL), so this mirrors da_clothing almost
-- exactly: _APPLY_SHOP_ITEM_TO_PED to equip, REMOVE_TAG_FROM_META_PED to clear,
-- the refresh/update natives to apply, and _GET_SHOP_ITEM_COMPONENT_AT_INDEX to
-- read back. The one difference: horse items are a mix of mp true/false, so the
-- apply native's isMp arg is taken per-item from dat.horse.items[hash].mp.
-- See docs/adr/0009-redm-horse-tack-natives.md for the empirically-confirmed flags.

local Horse = {}

local function maskHash(h) return h and (h & 0xFFFFFFFF) or 0 end

-- isMp arg for a component, from the generated data (default false: most tack is
-- single-player and the apply native wants the item's own mp flag).
local function isMpFor(componentHash)
    local it = dat.horse and dat.horse.items and dat.horse.items[maskHash(componentHash)]
    return it and it.mp == true or false
end

-- Re-render the horse after a component change. Identical to da_clothing.apply —
-- the metaped refresh/update natives are ped-type agnostic.
Horse.apply = function(ped)
    ped = ped or PlayerPedId()
    Citizen.InvokeNative(0x704C908E9C405136, ped)
    Citizen.InvokeNative(0xAAB86462966168CE, ped, 1)
    Citizen.InvokeNative(0xCC8CA3E88256E58F, ped, 0, 1, 1, 1, 0) -- _UPDATE_PED_VARIATION
end

-- Equip a tack component (saddle, stirrup, bridle, ...) on a horse ped. isMp is
-- resolved per-item unless overridden via opts.isMp.
--
-- Horse tack does NOT auto-replace within a category the way player clothing does:
-- applying a second item to an already-occupied category is a no-op (confirmed
-- empirically — see ADR-0009). So unless opts.replace == false, clear the item's
-- category first, then apply, giving callers a clean swap. The leading remove is
-- a harmless no-op when the slot is already empty.
Horse.equip = function(componentHash, opts, ped)
    opts = opts or {}
    ped = ped or PlayerPedId()
    local isMp = opts.isMp
    if isMp == nil then isMp = isMpFor(componentHash) end
    if opts.replace ~= false then
        local it = dat.horse and dat.horse.items and dat.horse.items[maskHash(componentHash)]
        local catHash = it and dat.horse.categories and dat.horse.categories[it.category]
        if catHash then
            Citizen.InvokeNative(0xD710A5007C2AC539, ped, catHash, 1) -- REMOVE_TAG_FROM_META_PED
        end
    end
    Citizen.InvokeNative(0xD3A7B003ED343FD9, ped, componentHash, false, true, isMp) -- _APPLY_SHOP_ITEM_TO_PED
    Horse.apply(ped)
end

-- Remove whatever component occupies a category (by category hash), e.g. take
-- the saddle off with da_horse.remove(dat.horse.categories.horse_saddles).
Horse.remove = function(categoryHash, ped)
    ped = ped or PlayerPedId()
    Citizen.InvokeNative(0xD710A5007C2AC539, ped, categoryHash, 1) -- REMOVE_TAG_FROM_META_PED
    Horse.apply(ped)
end

-- Remove a specific tack component by its hash, by resolving its category from
-- our data and clearing that slot (one item per slot). Avoids the metapedType
-- question the shop-item category resolver raises for animals.
Horse.removeItem = function(componentHash, ped)
    ped = ped or PlayerPedId()
    local it = dat.horse and dat.horse.items and dat.horse.items[maskHash(componentHash)]
    local catHash = it and dat.horse.categories and dat.horse.categories[it.category]
    if catHash then
        Citizen.InvokeNative(0xD710A5007C2AC539, ped, catHash, 1)
    end
    Horse.apply(ped)
end

-- Apply one of the horse model's built-in outfit presets by index. Useful as a
-- clean tack baseline before building a loadout (the empty preset index is
-- model-specific; confirm per ADR-0009).
Horse.setOutfitPreset = function(presetId, ped)
    ped = ped or PlayerPedId()
    SetPedOutfitPreset(ped, presetId or 0, false)
    Horse.apply(ped)
end

-- The shop component hashes currently on the horse, via the per-slot readback
-- _GET_SHOP_ITEM_COMPONENT_AT_INDEX. Same enumerator da_clothing.equipped uses.
Horse.equipped = function(ped)
    ped = ped or PlayerPedId()
    local out = {}
    for i = 0, 40 do
        local statusFlag = Citizen.PointerValueInt()
        local wearableState = Citizen.PointerValueInt()
        local comp = Citizen.InvokeNative(0x77BA37622E22023B, ped, i, true,
            statusFlag, wearableState, Citizen.ResultAsInteger())
        comp = comp and (comp & 0xFFFFFFFF) or 0
        if comp ~= 0 then out[#out + 1] = comp end
    end
    return out
end

-- ---- spawning ----
-- Spawn a horse ped from a model name/hash via the shared object helper, which
-- handles model load/unload. opts pass through to da_obj.set (heading, frozen…).
Horse.spawn = function(model, coords, opts)
    if not model or not coords then return nil end
    local hash = type(model) == "string" and GetHashKey(model) or model
    return da_obj.createPed(hash, coords, opts)
end

-- ---- tack loadout (capture / restore / save / load) ----
-- A loadout is a serializable snapshot of a horse's tack: model + equipped
-- component hashes. Capture/restore are framework-agnostic; persistence routes
-- through the API (Default adapter -> KVP), mirroring da_clothing.outfit.
Horse.tack = {}

Horse.tack.capture = function(ped)
    ped = ped or PlayerPedId()
    return {
        model = GetEntityModel(ped) & 0xFFFFFFFF,
        components = Horse.equipped(ped),
    }
end

-- Apply a captured loadout to a horse ped. Equips settle asynchronously, so this
-- verifies via Horse.equipped and re-issues any that didn't land (bounded), the
-- same pattern da_clothing.outfit.restore uses. The horse's model is not changed
-- here — a loadout is applied onto whatever horse you give it.
Horse.tack.restore = function(loadout, ped)
    if type(loadout) ~= "table" then return false end
    ped = ped or PlayerPedId()
    local want = loadout.components or {}
    local deadline = GetGameTimer() + 3000
    while true do
        local have = {}
        for _, h in ipairs(Horse.equipped(ped)) do have[h & 0xFFFFFFFF] = true end
        local allOn = true
        for _, h in ipairs(want) do
            if not have[h & 0xFFFFFFFF] then
                allOn = false
                Horse.equip(h, nil, ped)
            end
        end
        if allOn or GetGameTimer() > deadline then return allOn end
        Citizen.Wait(30)
    end
end

-- Capture the horse's current tack and persist it under `slot` via the API.
Horse.tack.save = function(slot, ped)
    return API.saveTack(slot or "default", Horse.tack.capture(ped))
end

-- Load the loadout stored under `slot` and apply it to the horse ped. False if none.
Horse.tack.load = function(slot, ped)
    local data = API.loadTack(slot or "default")
    if not data then return false end
    return Horse.tack.restore(data, ped)
end

_ENV.da_horse = Horse
