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

-- ---- cold-load asset streaming ----
-- On a COLD first load the component's drawable isn't resident and
-- _APPLY_SHOP_ITEM_TO_PED silently no-ops — confirmed in da_test: heads/eyes/
-- teeth/bodies fail to apply cold, but apply fine once their asset is streamed in
-- (warm loads "just worked" only because the assets were already cached). So we
-- request the asset bundle and wait for it before applying. Bounded so a slow or
-- bad asset can never hang a caller.
local REQ_BUNDLE = 0x91FE941F9FCFB702 -- _REQUEST_META_PED_ASSET_BUNDLE(asset, p1=1) -> reqId
local HAS_LOADED = 0xB0B2C6D170B0E8E5 -- _HAS_META_PED_ASSET_LOADED(reqId) -> bool
local REL_REQ    = 0x13E7320C762F0477 -- _RELEASE_META_PED_ASSET_REQUEST(reqId)
local APPLY_ITEM = 0xD3A7B003ED343FD9 -- _APPLY_SHOP_ITEM_TO_PED(ped, hash, immediately, isMp, p4)

local function mask32(h) return h & 0xFFFFFFFF end

-- Request a component's asset bundle and wait (bounded) until streamed in.
-- Returns the requestId — release it once the component has been applied. Safe to
-- release after apply: the ped holds the asset (da_test: applied items survived
-- the release).
local function requestComponent(componentHash)
    local reqId = Citizen.InvokeNative(REQ_BUNDLE, mask32(componentHash), 1)
    if not reqId or reqId == 0 then return nil end
    local deadline = GetGameTimer() + 5000
    while not Citizen.InvokeNative(HAS_LOADED, reqId) and GetGameTimer() < deadline do
        Citizen.Wait(0)
    end
    return reqId
end

local function isOn(ped, m)
    for _, h in ipairs(Clothing.equipped(ped)) do
        if mask32(h) == m then return true end
    end
    return false
end

Clothing.equip = function(componentHash, opts, ped)
    opts = opts or {}
    ped = ped or PlayerPedId()
    local m = mask32(componentHash)
    -- stream the asset in first so the apply isn't a cold no-op
    local reqId = requestComponent(componentHash)
    -- a single apply after load isn't always enough for face components, so
    -- re-issue until it reads back (bounded). Warm/resident items take one pass.
    local deadline = GetGameTimer() + 1500
    repeat
        Citizen.InvokeNative(APPLY_ITEM, ped, componentHash, false, true, true)
        Clothing.apply(ped)
        if isOn(ped, m) then break end
        Citizen.Wait(30)
    until GetGameTimer() > deadline
    if opts.color then
        Clothing.setColor(ped, opts.category, opts.palette, opts.tint0, opts.tint1, opts.tint2)
    end
    if reqId then Citizen.InvokeNative(REL_REQ, reqId) end
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
    local want = outfit.components or {}

    -- COLD-LOAD FIX (confirmed via da_test): on a first load the component meshes
    -- aren't resident and the apply silently no-ops. Request every bundle up front
    -- so they stream in PARALLEL, wait until loaded, THEN apply + re-issue until
    -- each reads back. (Applying without streaming dropped heads/eyes/teeth/bodies;
    -- the asset request lands all 15.) Release the requests at the end — applied
    -- items survive it (the ped holds the asset).
    local reqs = {}
    for _, h in ipairs(want) do
        reqs[#reqs + 1] = { id = Citizen.InvokeNative(REQ_BUNDLE, mask32(h), 1) }
    end
    local loadDeadline = GetGameTimer() + 8000
    while GetGameTimer() < loadDeadline do
        local allLoaded = true
        for _, r in ipairs(reqs) do
            if r.id and not Citizen.InvokeNative(HAS_LOADED, r.id) then allLoaded = false; break end
        end
        if allLoaded then break end
        Citizen.Wait(0)
    end

    -- apply + verify (re-issue the APPLY, not just the variation update — re-issuing
    -- only the update was the bug that left face components off).
    local allOn = false
    local deadline = GetGameTimer() + 5000
    while true do
        local have = {}
        for _, h in ipairs(Clothing.equipped(ped)) do have[mask32(h)] = true end
        allOn = true
        for _, h in ipairs(want) do
            if not have[mask32(h)] then
                allOn = false
                Citizen.InvokeNative(APPLY_ITEM, ped, mask32(h), false, true, true)
            end
        end
        Clothing.apply(ped)
        if allOn or GetGameTimer() > deadline then break end
        Citizen.Wait(30)
    end

    for _, r in ipairs(reqs) do
        if r.id then Citizen.InvokeNative(REL_REQ, r.id) end
    end
    return allOn
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
