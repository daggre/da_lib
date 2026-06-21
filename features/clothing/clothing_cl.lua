local Clothing = {}

Clothing.apply = function(ped)
    ped = ped or PlayerPedId()
    -- 0xA0BC8FAED8CFEB3C was used here as an "is ped ready" gate, but the
    -- da_test clothing probes proved it returns false for a live, fully-loaded
    -- mp player ped — so the old wait-loop never passed and stalled every apply
    -- for its whole timeout. Dropped; the refresh natives below are enough
    -- (femga's canonical apply is just refresh + _UPDATE_PED_VARIATION).
    Citizen.InvokeNative(0x704C908E9C405136, ped)
    Citizen.InvokeNative(0xAAB86462966168CE, ped, 1)
    Citizen.InvokeNative(0xCC8CA3E88256E58F, ped, 0, 1, 1, 1, 0) -- _UPDATE_PED_VARIATION
end

Clothing.setColor = function(ped, category, palette, tint0, tint1, tint2)
    ped = ped or PlayerPedId()
    Citizen.InvokeNative(0x4EFC1F8FF1AD94DE, ped, category, palette, tint0, tint1, tint2)
end

Clothing.equip = function(componentHash, opts, ped)
    opts = opts or {}
    ped = ped or PlayerPedId()
    local immediately = false
    Citizen.InvokeNative(0xD3A7B003ED343FD9, ped, componentHash, immediately, true, true)
    if opts.color then
        Clothing.setColor(ped, opts.category, opts.palette, opts.tint0, opts.tint1, opts.tint2)
    end
    Clothing.apply(ped)
end

-- Remove whatever component occupies a category (by category hash), e.g. take
-- off the hat with da_clothing.remove(dat.clothing.categories.hats).
-- 0xD710A5007C2AC539 = RemoveTagFromMetaPed; the categories share the metaped
-- tag system, so shop components are removed the same way.
Clothing.remove = function(categoryHash, ped)
    ped = ped or PlayerPedId()
    Citizen.InvokeNative(0xD710A5007C2AC539, ped, categoryHash, 1)
    Clothing.apply(ped)
end

-- Remove a shop item by its component hash. The dedicated native
-- _REMOVE_SHOP_ITEM_FROM_PED (0x0D7FFA1B2F69ED82) was inert in testing, so we
-- resolve the item's category and remove that — since a category holds exactly
-- one item, this clears precisely the item occupying that slot.
Clothing.removeItem = function(componentHash, ped)
    ped = ped or PlayerPedId()
    local metapedType = (GetEntityModel(ped) == `mp_female`) and 1 or 0
    local category = Citizen.InvokeNative(0x5FF9A878C3D115B8, componentHash, metapedType, true)
    if category and category ~= 0 then
        Citizen.InvokeNative(0xD710A5007C2AC539, ped, category, 1) -- REMOVE_TAG_FROM_META_PED
    end
    Clothing.apply(ped)
end

-- Apply one of the model's built-in outfit presets by index (SetPedOutfitPreset
-- = _EQUIP_META_PED_OUTFIT_PRESET). On mp_male/mp_female, preset 4 is the empty
-- 0-component baseline — a clean slate to build an outfit on. Confirmed in
-- da_test (mp_male 4->0, mp_female 3->0); da_dev uses preset 4 for the same.
Clothing.setOutfitPreset = function(presetId, ped)
    ped = ped or PlayerPedId()
    SetPedOutfitPreset(ped, presetId or 0, false)
    Clothing.apply(ped)
end

-- Wearable-state args per nativedb: (ped, hash, wearableState, p3=0, isMp=true,
-- p5=1). We previously passed p3=1, which was wrong.
Clothing.rollSleeves = function(componentHash, ped)
    ped = ped or PlayerPedId()
    Citizen.InvokeNative(0x66B957AAC2EAAEAB, ped, componentHash, `open_collar_rolled_sleeve`, 0, true, 1)
    Clothing.apply(ped)
end

Clothing.openCollar = function(componentHash, ped)
    ped = ped or PlayerPedId()
    Citizen.InvokeNative(0x66B957AAC2EAAEAB, ped, componentHash, `closed_collar_rolled_sleeve`, 0, true, 1)
    Clothing.apply(ped)
end

Clothing.equipAsset = function(drawable, albedo, normal, material, palette, tint0, tint1, tint2)
    tint0 = tint0 or 1
    tint1 = tint1 or 1
    tint2 = tint2 or 1
    local ped = PlayerPedId()
    Citizen.InvokeNative(0xBC6DF00D7A4A6819, ped, drawable, albedo, normal, material, palette, tint0, tint1, tint2)
    Clothing.apply(ped)
end

-- ---- equipped-state read ----
local MP_MALE, MP_FEMALE = `mp_male`, `mp_female`

local function pedTypeOf(ped)
    local m = GetEntityModel(ped)
    if m == MP_MALE then return "male" elseif m == MP_FEMALE then return "female" end
    return nil
end

-- The shop component hashes currently equipped on the ped, via
-- _GET_SHOP_ITEM_COMPONENT_AT_INDEX (the per-slot readback). This is the lib-side
-- read save/restore is built on; da_audit.clothing wraps it.
Clothing.equipped = function(ped)
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

-- ---- outfit save/load ----
-- capture/restore are framework-agnostic game logic (read/apply the ped's
-- clothing); persistence is routed through the API so a framework can store it
-- in its DB. The Default adapter persists via KVP (see features/api/default).
Clothing.outfit = {}

-- A serializable snapshot of the ped's current outfit: model + equipped items.
Clothing.outfit.capture = function(ped)
    ped = ped or PlayerPedId()
    return {
        model = GetEntityModel(ped) & 0xFFFFFFFF,
        pedType = pedTypeOf(ped),
        components = Clothing.equipped(ped),
    }
end

-- Apply a captured outfit. Sets the player model first if it differs (an outfit
-- is model-specific), then clears to the preset-4 baseline and re-equips each
-- component. Returns true on apply.
Clothing.outfit.restore = function(outfit, ped)
    if type(outfit) ~= "table" then return false end
    ped = ped or PlayerPedId()
    if outfit.model and (GetEntityModel(ped) & 0xFFFFFFFF) ~= (outfit.model & 0xFFFFFFFF) then
        RequestModel(outfit.model)
        local deadline = GetGameTimer() + 5000
        while not HasModelLoaded(outfit.model) and GetGameTimer() < deadline do Citizen.Wait(0) end
        if HasModelLoaded(outfit.model) then
            SetPlayerModel(PlayerId(), outfit.model, false)
            SetModelAsNoLongerNeeded(outfit.model)
            ped = PlayerPedId()
        end
    end
    Clothing.setOutfitPreset(4, ped)
    -- Equips apply asynchronously, so firing them back-to-back drops some. restore
    -- is a whole-outfit orchestration, so it verifies via Clothing.equipped and
    -- re-issues any that didn't land (bounded). Returns true once all are on (or
    -- the deadline passes).
    local want = outfit.components or {}
    local deadline = GetGameTimer() + 3000
    while true do
        local have = {}
        for _, h in ipairs(Clothing.equipped(ped)) do have[h & 0xFFFFFFFF] = true end
        local allOn = true
        for _, h in ipairs(want) do
            if not have[h & 0xFFFFFFFF] then
                allOn = false
                Clothing.equip(h, nil, ped)
            end
        end
        if allOn or GetGameTimer() > deadline then return allOn end
        Citizen.Wait(30)
    end
end

-- Capture the current outfit and persist it under `slot` via the API.
Clothing.outfit.save = function(slot, ped)
    return API.saveOutfit(slot or "default", Clothing.outfit.capture(ped))
end

-- Load the outfit stored under `slot` via the API and apply it. False if none.
Clothing.outfit.load = function(slot, ped)
    local data = API.loadOutfit(slot or "default")
    if not data then return false end
    return Clothing.outfit.restore(data, ped)
end

_ENV.da_clothing = Clothing
