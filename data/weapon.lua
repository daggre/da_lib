if dat == nil then dat = {} end

dat.weapon = {
    { name = "melee_knife_jawbone",       hash = `weapon_melee_knife_jawbone`,       group = `group_melee` },
    { name = "melee_machete",             hash = `weapon_melee_machete`,             group = `group_melee` },
    { name = "melee_torch",               hash = `weapon_melee_torch`,               group = `group_melee` },
    { name = "melee_knife",               hash = `weapon_melee_knife`,               group = `group_melee` },

    { name = "pistol_volcanic",           hash = `weapon_pistol_volcanic`,           group = `group_pistol` },
    { name = "pistol_m1899",              hash = `weapon_pistol_m1899`,              group = `group_pistol` },
    { name = "pistol_semiauto",           hash = `weapon_pistol_semiauto`,           group = `group_pistol` },
    { name = "pistol_mauser",             hash = `weapon_pistol_mauser`,             group = `group_pistol` },

    { name = "repeater_evans",            hash = `weapon_repeater_evans`,            group = `group_repeater` },
    { name = "repeater_henry",            hash = `weapon_repeater_henry`,            group = `group_repeater` },
    { name = "repeater_winchester",       hash = `weapon_repeater_winchester`,       group = `group_repeater` },
    { name = "repeater_carbine",          hash = `weapon_repeater_carbine`,          group = `group_repeater` },

    { name = "revolver_doubleaction",     hash = `weapon_revolver_doubleaction`,     group = `group_revolver` },
    { name = "revolver_cattleman",        hash = `weapon_revolver_cattleman`,        group = `group_revolver` },
    { name = "revolver_cattleman_mexican",hash = `weapon_revolver_cattleman_mexican`,group = `group_revolver` },
    { name = "revolver_lemat",            hash = `weapon_revolver_lemat`,            group = `group_revolver` },
    { name = "revolver_schofield",        hash = `weapon_revolver_schofield`,        group = `group_revolver` },
    { name = "revolver_doubleaction_gambler", hash = `weapon_revolver_doubleaction_gambler`, group = `group_revolver` },

    { name = "rifle_springfield",         hash = `weapon_rifle_springfield`,         group = `group_rifle` },
    { name = "rifle_boltaction",          hash = `weapon_rifle_boltaction`,          group = `group_rifle` },
    { name = "rifle_varmint",             hash = `weapon_rifle_varmint`,             group = `group_rifle` },

    { name = "shotgun_sawedoff",          hash = `weapon_shotgun_sawedoff`,          group = `group_shotgun` },
    { name = "shotgun_doublebarrel_exotic", hash = `weapon_shotgun_doublebarrel_exotic`, group = `group_shotgun` },
    { name = "shotgun_pump",              hash = `weapon_shotgun_pump`,              group = `group_shotgun` },
    { name = "shotgun_repeating",         hash = `weapon_shotgun_repeating`,         group = `group_shotgun` },
    { name = "shotgun_semiauto",          hash = `weapon_shotgun_semiauto`,          group = `group_shotgun` },
    { name = "shotgun_doublebarrel",      hash = `weapon_shotgun_doublebarrel`,      group = `group_shotgun` },

    { name = "sniperrifle_carcano",       hash = `weapon_sniperrifle_carcano`,       group = `group_sniper` },
    { name = "sniperrifle_rollingblock",  hash = `weapon_sniperrifle_rollingblock`,  group = `group_sniper` },

    { name = "melee_hatchet",             hash = `weapon_melee_hatchet`,             group = `group_thrown` },
    { name = "melee_hatchet_hunter",      hash = `weapon_melee_hatchet_hunter`,      group = `group_thrown` },
    { name = "thrown_molotov",            hash = `weapon_thrown_molotov`,            group = `group_thrown` },
    { name = "thrown_tomahawk_ancient",   hash = `weapon_thrown_tomahawk_ancient`,   group = `group_thrown` },
    { name = "thrown_tomahawk",           hash = `weapon_thrown_tomahawk`,           group = `group_thrown` },
    { name = "thrown_dynamite",           hash = `weapon_thrown_dynamite`,           group = `group_thrown` },
    { name = "melee_hatchet_double_bit",  hash = `weapon_melee_hatchet_double_bit`,  group = `group_thrown` },
    { name = "thrown_throwing_knives",    hash = `weapon_thrown_throwing_knives`,    group = `group_thrown` },
    { name = "melee_cleaver",             hash = `weapon_melee_cleaver`,             group = `group_thrown` },

    { name = "melee_davy_lantern",        hash = `weapon_melee_davy_lantern`,        group = `group_held` },
    { name = "kit_binoculars",            hash = `weapon_kit_binoculars`,            group = `group_held` },
    { name = "kit_camera",                hash = `weapon_kit_camera`,                group = `group_held` },

    { name = "bow",                       hash = `weapon_bow`,                       group = `group_bow` },
    { name = "fishingrod",                hash = `weapon_fishingrod`,                group = `group_fishingrod` },
    { name = "lasso",                     hash = `weapon_lasso`,                     group = `group_lasso` },

    { name = "kit_camera_advanced",       hash = `weapon_kit_camera_advanced`,       group = `group_held` },
    { name = "melee_machete_horror",      hash = `weapon_melee_machete_horror`,      group = `group_melee` },
    { name = "bow_improved",              hash = `weapon_bow_improved`,              group = `group_bow` },
    { name = "rifle_elephant",            hash = `weapon_rifle_elephant`,            group = `group_rifle` },
    { name = "revolver_navy",             hash = `weapon_revolver_navy`,             group = `group_revolver` },
    { name = "lasso_reinforced",          hash = `weapon_lasso_reinforced`,          group = `group_lasso` },
    { name = "kit_binoculars_improved",   hash = `weapon_kit_binoculars_improved`,   group = `group_held` },
    { name = "melee_knife_trader",        hash = `weapon_melee_knife_trader`,        group = `group_melee` },
    { name = "melee_machete_collector",   hash = `weapon_melee_machete_collector`,   group = `group_melee` },
    { name = "moonshinejug_mp",           hash = `weapon_moonshinejug_mp`,           group = `group_petrolcan` },
    { name = "thrown_bolas",              hash = `weapon_thrown_bolas`,              group = `group_thrown` },
    { name = "thrown_poisonbottle",       hash = `weapon_thrown_poisonbottle`,       group = `group_thrown` },

    { name = "kit_metal_detector",        hash = `weapon_kit_metal_detector`,        group = `group_held` },
    { name = "revolver_navy_crossover",   hash = `weapon_revolver_navy_crossover`,   group = `group_revolver` },
    { name = "thrown_bolas_hawkmoth",     hash = `weapon_thrown_bolas_hawkmoth`,     group = `group_thrown` },
    { name = "thrown_bolas_ironspiked",   hash = `weapon_thrown_bolas_ironspiked`,   group = `group_thrown` },
    { name = "thrown_bolas_intertwined",  hash = `weapon_thrown_bolas_intertwined`,  group = `group_thrown` },

    { name = "melee_knife_horror",        hash = `weapon_melee_knife_horror`,        group = `group_melee` },
    { name = "melee_knife_rustic",        hash = `weapon_melee_knife_rustic`,        group = `group_melee` },
    { name = "melee_lantern_halloween",   hash = `weapon_melee_lantern_halloween`,   group = `group_held` },
}

dat.attachpoint = {
    [-1] = { ["attachpoint"] = `weapon_attach_point_invalid`,         ["addOnMount"] = false, ["overlap"] = nil, },
    [0]  = { ["attachpoint"] = `weapon_attach_point_hand_primary`,    ["addOnMount"] = true,  ["overlap"] = nil, },
    [1]  = { ["attachpoint"] = `weapon_attach_point_hand_secondary`,  ["addOnMount"] = true,  ["overlap"] = nil, },
    [2]  = { ["attachpoint"] = `weapon_attach_point_pistol_r`,        ["addOnMount"] = true,  ["overlap"] = nil, },
    [3]  = { ["attachpoint"] = `weapon_attach_point_pistol_l`,        ["addOnMount"] = true,  ["overlap"] = nil, },
    [4]  = { ["attachpoint"] = `weapon_attach_point_knife`,           ["addOnMount"] = true,  ["overlap"] = nil, },
    [5]  = { ["attachpoint"] = `weapon_attach_point_lasso`,           ["addOnMount"] = true,  ["overlap"] = nil, },
    [6]  = { ["attachpoint"] = `weapon_attach_point_thrower`,         ["addOnMount"] = true,  ["overlap"] = nil, },
    [7]  = { ["attachpoint"] = `weapon_attach_point_bow`,             ["addOnMount"] = false, ["overlap"] = 9,   },
    [8]  = { ["attachpoint"] = `weapon_attach_point_bow_alternate`,   ["addOnMount"] = false, ["overlap"] = 10,  },
    [9]  = { ["attachpoint"] = `weapon_attach_point_rifle`,           ["addOnMount"] = false, ["overlap"] = 7,   },
    [10] = { ["attachpoint"] = `weapon_attach_point_rifle_alternate`, ["addOnMount"] = false, ["overlap"] = 8,   },
    [11] = { ["attachpoint"] = `weapon_attach_point_lantern`,         ["addOnMount"] = true,  ["overlap"] = nil, },
    [12] = { ["attachpoint"] = `weapon_attach_point_temp_lantern`,    ["addOnMount"] = true,  ["overlap"] = nil, },
    [13] = { ["attachpoint"] = `weapon_attach_point_melee`,           ["addOnMount"] = true,  ["overlap"] = nil, },
}

if dat.lookup == nil then dat.lookup = {} end

dat.lookup.attachpointGroup = {
    [`group_held`] = { 11, 12 },
    [`group_thrown`] = { 6 },
    [`group_revolver`] = { 2, 3 },
    [`group_bow`] = { 7, 8 },
    [`group_rifle`] = { 9, 10 },
    [`group_sniper`] = { 9, 10 },
    [`group_melee`] = { 4, 13 },
    [`group_fishingrod`] = { -1 },
    [`group_lasso`] = { 5 },
    [`group_petrolcan`] = { 0, 1 },
}

dat.lookup.weapon = {}
for _, w in ipairs(dat.weapon) do
    dat.lookup.weapon[w.hash] = w
end

---@diagnostic disable-next-line: duplicate-set-field
dat.getWeaponName = function(hash)
    local weaponData = dat.lookup.weapon[hash]
    return weaponData and weaponData.name or hash
end

---@diagnostic disable-next-line: duplicate-set-field
dat.getGroupAttachpoint = function(hash)
    local groupData = dat.lookup.attachpointGroup[hash]
    if not groupData then return { 0, 1 } end
    return groupData
end

---@diagnostic disable-next-line: duplicate-set-field
dat.getWeaponAttachpoint = function(hash)
    local weaponData = dat.lookup.weapon[hash]
    if not weaponData or weaponData.group == nil then return { 0, 1 } end
    return dat.getGroupAttachpoint(weaponData.group)
end

