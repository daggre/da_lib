if dat == nil then dat = {} end

-- These are all the birds I should divide these into birds that are only
-- plucked and birds that are harvested for organs and meat (animation)
dat.bird = {
    "a_c_bat_01",
    "a_c_bluejay_01",
    "a_c_californiacondor_01",
    "a_c_cardinal_01",
    "a_c_carolinaparakeet_01",
    "a_c_cedarwaxwing_01",
    "a_c_chicken_01",
    "a_c_cormorant_01",
    "a_c_cranewhooping_01",
    "a_c_crow_01",
    "a_c_duck_01",
    "a_c_eagle_01",
    "a_c_egret_01",
    "a_c_goosecanada_01",
    "a_c_hawk_01",
    "a_c_heron_01",
    "a_c_loon_01",
    "a_c_oriole_01",
    "a_c_owl_01",
    "a_c_parrot_01",
    "a_c_pelican_01",
    "a_c_pheasant_01",
    "a_c_pigeon",
    "a_c_prairiechicken_01",
    "a_c_quail_01",
    "a_c_raven_01",
    "a_c_redfootedbooby_01",
    "a_c_robin_01",
    "a_c_rooster_01",
    "a_c_roseatespoonbill_01",
    "a_c_seagull_01",
    "a_c_songbird_01",
    "a_c_sparrow_01",
    "a_c_turkey_01",
    "a_c_turkey_02",
    "a_c_turkeywild_01",
    "a_c_vulture_01",
    "a_c_woodpecker_01",
    "a_c_woodpecker_02",
}

-- I need to confirm this, when looted these models are plucked
dat.plucked = {
    "a_c_bluejay_01",
    "a_c_californiacondor_01",
    "a_c_cardinal_01",
    "a_c_carolinaparakeet_01",
    "a_c_cedarwaxwing_01",
    "a_c_cormorant_01",
    "a_c_cranewhooping_01",
    "a_c_crow_01",
    "a_c_eagle_01",
    "a_c_egret_01",
    "a_c_hawk_01",
    "a_c_heron_01",
    "a_c_loon_01",
    "a_c_oriole_01",
    "a_c_owl_01",
    "a_c_parrot_01",
    "a_c_pelican_01",
    "a_c_pigeon",
    "a_c_quail_01",
    "a_c_raven_01",
    "a_c_redfootedbooby_01",
    "a_c_robin_01",
    "a_c_rooster_01",
    "a_c_roseatespoonbill_01",
    "a_c_seagull_01",
    "a_c_songbird_01",
    "a_c_sparrow_01",
    "a_c_vulture_01",
    "a_c_woodpecker_01",
    "a_c_woodpecker_02",
}

-- I need to confirm this, when looted these models are opened up and meat is harvested
dat.birdMeat = {
    "a_c_chicken_01",
    "a_c_duck_01",
    "a_c_goosecanada_01",
    "a_c_pheasant_01",
    "a_c_prairiechicken_01",
    "a_c_turkey_01",
    "a_c_turkey_02",
    "a_c_turkeywild_01",
}

-- Thse animals are stuffed into a pouch as soon as they are picked up, unskinnable
dat.smallAnimal = {
    "a_c_chipmunk_01",
    "a_c_crab_01",
    "a_c_crawfish_01",
    "a_c_frogbull_01",
    "a_c_muskrat_01",
    "a_c_rat_01",
    "a_c_squirrel_01",
    "a_c_toad_01",
}

-- These are domestic animals (pets), may want to treat them differently for hunting
dat.domestic = {
    "a_c_cat_01",
    "a_c_dogamericanfoxhound_01",
    "a_c_dogaustraliansheperd_01",
    "a_c_dogbluetickcoonhound_01",
    "a_c_dogcatahoulacur_01",
    "a_c_dogchesbayretriever_01",
    "a_c_dogcollie_01",
    "a_c_doghobo_01",
    "a_c_doghound_01",
    "a_c_doghusky_01",
    "a_c_doglab_01",
    "a_c_doglion_01",
    "a_c_dogpoodle_01",
    "a_c_dogrufus_01",
    "a_c_dogstreet_01",
    "a_c_donkey_01",
}

-- These are animals that are stowed on each side of the saddle (2 slots)
dat.stowSaddle = {
    "a_c_californiacondor_01",
    "a_c_chicken_01",
    "a_c_cormorant_01",
    "a_c_cranewhooping_01",
    "a_c_duck_01",
    "a_c_eagle_01",
    "a_c_egret_01",
    "a_c_goosecanada_01",
    "a_c_hawk_01",
    "a_c_heron_01",
    "a_c_loon_01",
    "a_c_owl_01",
    "a_c_parrot_01",
    "a_c_pelican_01",
    "a_c_pheasant_01",
    "a_c_prairiechicken_01",
    "a_c_quail_01",
    "a_c_raven_01",
    "a_c_rooster_01",
    "a_c_roseatespoonbill_01",
    "a_c_seagull_01",
    "a_c_turkey_01",
    "a_c_turkey_02",
    "a_c_turkeywild_01",
    "a_c_vulture_01",
    "a_c_woodpecker_01",
    "a_c_woodpecker_02",

    "a_c_badger_01",
    "a_c_possum_01",
    "a_c_rabbit_01",
    "a_c_raccoon_01",
    "a_c_skunk_01",
    "a_c_snake_01",
    "a_c_snake_pelt_01",
    "a_c_snakeblacktailrattle_01",
    "a_c_snakeferdelance_01",
    "a_c_snakeredboa10ft_01",
    "a_c_snakeredboa_01",
    "a_c_snakewater_01",
}

-- These animals are carriable and skinnable
dat.skinnable = {
    "a_c_alligator_01",
    "a_c_alligator_02",
    "a_c_alligator_03",
    "a_c_armadillo_01",
    "a_c_badger_01",
    "a_c_bear_01",
    "a_c_bearblack_01",
    "a_c_beaver_01",
    "a_c_bighornram_01",
    "a_c_boar_01",
    "a_c_boarlegendary_01",
    "a_c_buck_01",
    "a_c_buffalo_01",
    "a_c_buffalo_tatanka_01",
    "a_c_bull_01",
    "a_c_cougar_01",
    "a_c_cow",
    "a_c_coyote_01",
    "a_c_deer_01",
    "a_c_elk_01",
    "a_c_fox_01",
    "a_c_gilamonster_01",
    "a_c_goat_01",
    "a_c_iguana_01",
    "a_c_iguanadesert_01",
    "a_c_javelina_01",
    "a_c_lionmangy_01",
    "a_c_moose_01",
    "a_c_ox_01",
    "a_c_panther_01",
    "a_c_pig_01",
    "a_c_possum_01",
    "a_c_pronghorn_01",
    "a_c_rabbit_01",
    "a_c_raccoon_01",
    "a_c_sheep_01",
    "a_c_skunk_01",
    "a_c_snake_01",
    "a_c_snake_pelt_01",
    "a_c_snakeblacktailrattle_01",
    "a_c_snakeblacktailrattle_pelt_01",
    "a_c_snakeferdelance_01",
    "a_c_snakeferdelance_pelt_01",
    "a_c_snakeredboa10ft_01",
    "a_c_snakeredboa_01",
    "a_c_snakeredboa_pelt_01",
    "a_c_snakewater_01",
    "a_c_snakewater_pelt_01",
    "a_c_turtlesnapping_01",
    "a_c_wolf",
    "a_c_wolf_medium",
    "a_c_wolf_small",
}

-- These animals are not able to be carried, but can be skinned for a carriable pelt
dat.largeAnimal = {
    "a_c_alligator_01",
    "a_c_alligator_02",
    "a_c_alligator_03",
    "a_c_armadillo_01",
    "a_c_bear_01",
    "a_c_bearblack_01",
    "a_c_boar_01",
    "a_c_boarlegendary_01",
    "a_c_buffalo_01",
    "a_c_buffalo_tatanka_01",
    "a_c_bull_01",
    "a_c_cow",
    "a_c_elk_01",
    "a_c_javelina_01",
    "a_c_lionmangy_01",
    "a_c_moose_01",
    "a_c_ox_01",
    "a_c_pig_01",
}

-- Whole carcasses you shoulder and place on the rear seat of the horse (the
-- carriable-entity transport path, GET_CARRIABLE_ENTITY_STATE / rear-seat Stow).
-- HAND-CURATED — not derived from the other lists. Seeded with the medium animals
-- (skinnable that are neither largeAnimal nor stowSaddle); adjust by hand. Small
-- animals that ride in a saddle-side slot live in dat.stowSaddle, the un-carriable
-- big game in dat.largeAnimal.
dat.carriable = {
    "a_c_beaver_01",
    "a_c_bighornram_01",
    "a_c_buck_01",
    "a_c_cougar_01",
    "a_c_coyote_01",
    "a_c_deer_01",
    "a_c_fox_01",
    "a_c_gilamonster_01",
    "a_c_goat_01",
    "a_c_iguana_01",
    "a_c_iguanadesert_01",
    "a_c_panther_01",
    "a_c_pronghorn_01",
    "a_c_sheep_01",
    "a_c_turtlesnapping_01",
    "a_c_wolf",
    "a_c_wolf_medium",
    "a_c_wolf_small",
}

-- These pelts are large and are attached on the back of the horse, not draped in pelt slots
dat.largePelts = {
    "p_cs_pelt_elklegendary",
    "p_cs_pelt_xlarge",
    "p_cs_pelt_xlarge_alligator",
    "p_cs_pelt_xlarge_bear",
    "p_cs_pelt_xlarge_bearlegendary",
    "p_cs_pelt_xlarge_buffalo",
    "p_cs_pelt_xlarge_elk",
    "p_cs_pelt_xlarge_tbuffalo",
    "p_cs_pelt_xlarge_wbuffalo",
}

-- These pelts are either carried in a pouch or are draped across the horse in pelt slots
dat.pelts = {
    "p_cs_pelt_large",
    "p_cs_pelt_med_armadillo",
    "p_cs_pelt_med_badger",
    "p_cs_pelt_med_muskrat",
    "p_cs_pelt_med_possum",
    "p_cs_pelt_med_raccoon",
    "p_cs_pelt_med_skunk",
    "p_cs_pelt_medium",
    "p_cs_pelt_medium_og",
    "p_cs_pelt_medlarge",
    "p_cs_pelt_medlarge_roll",
    "p_cs_pelt_wolf",
    "p_cs_pelt_wolf_roll",
    "p_cs_pelt_ws_alligator",
}

dat.fish = {
    "a_c_fishbluegil_01_ms",
    "a_c_fishbluegil_01_sm",
    "a_c_fishbullheadcat_01_ms",
    "a_c_fishbullheadcat_01_sm",
    "a_c_fishchainpickerel_01_ms",
    "a_c_fishchainpickerel_01_sm",
    "a_c_fishchannelcatfish_01_lg",
    "a_c_fishchannelcatfish_01_xl",
    "a_c_fishlakesturgeon_01_lg",
    "a_c_fishlargemouthbass_01_lg",
    "a_c_fishlargemouthbass_01_ms",
    "a_c_fishlongnosegar_01_lg",
    "a_c_fishmuskie_01_lg",
    "a_c_fishnorthernpike_01_lg",
    "a_c_fishperch_01_ms",
    "a_c_fishperch_01_sm",
    "a_c_fishrainbowtrout_01_lg",
    "a_c_fishrainbowtrout_01_ms",
    "a_c_fishredfinpickerel_01_ms",
    "a_c_fishredfinpickerel_01_sm",
    "a_c_fishrockbass_01_ms",
    "a_c_fishrockbass_01_sm",
    "a_c_fishsalmonsockeye_01_lg",
    "a_c_fishsalmonsockeye_01_ml",
    "a_c_fishsalmonsockeye_01_ms",
    "a_c_fishsmallmouthbass_01_lg",
    "a_c_fishsmallmouthbass_01_ms",
    "a_c_sharkhammerhead_01",
    "a_c_sharktiger",
    "a_c_turtlesea_01",
}

-- ============================ hash tables ============================
-- AddInteract (da_xinteracts) keys interacts on model HASHES and accepts a table
-- of them, so every list above also needs a parallel hash form. For each list
-- dat.<name> we generate:
--   dat.<name>Hash  - array of GetHashKey(name), pass straight to AddInteract
--   dat.<name>Set   - set keyed by hash -> name, for O(1) "is this model an X?"
-- Model names already resolve through dat.getName (animals via dat.ped, pelt props
-- via dat.object), so we don't register a getName lookup here.
local huntingLists = {
    "bird", "plucked", "birdMeat", "smallAnimal", "domestic",
    "stowSaddle", "skinnable", "largeAnimal", "carriable",
    "largePelts", "pelts", "fish",
}

for _, key in ipairs(huntingLists) do
    local names = dat[key]
    local hashes, set = {}, {}
    for _, name in ipairs(names) do
        local h = GetHashKey(name)
        hashes[#hashes + 1] = h
        set[h] = name
    end
    dat[key .. "Hash"] = hashes
    dat[key .. "Set"] = set
end

-- ============================ harvest yields ============================
-- The inventory item a model grants when harvested (small animal pouched, bird
-- plucked/butchered, gather prop). Skinning is NOT here: a skinned pelt is a
-- carriable ENTITY, not an inventory item.
--
-- dat.huntItem maps a model NAME to the real inventory item name your framework
-- expects. It's intentionally empty — fill it in. Until a model is mapped,
-- dat.itemFor falls back to a name DERIVED from the model ("a_c_squirrel_01" ->
-- "squirrel"), which is a readable placeholder, not a guaranteed-real item id.
dat.huntItem = dat.huntItem or {}

-- Resolve the inventory item for a model (hash or name). Override wins; otherwise
-- derive: drop the "a_c_" prefix and a trailing "_NN" index.
dat.itemFor = function(model)
    local name = dat.getName(model) or model
    if type(name) ~= "string" then return nil end
    if dat.huntItem[name] then return dat.huntItem[name] end
    return (name:gsub("^a_c_", ""):gsub("_%d+$", ""))
end
