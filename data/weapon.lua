if dat == nil then dat = {} end

-- Curated weapon reference. `key` is an optional single-char hint for menus
-- (e.g. the da_dev devtree); `ammo` is a sensible default give amount.
dat.weapon = {
    { name = "cattleman",    hash = `weapon_revolver_cattleman`,       category = "revolver", key = "c", ammo = 100 },
    { name = "lemat",        hash = `weapon_revolver_lemat`,           category = "revolver", key = "l", ammo = 100 },
    { name = "mauser",       hash = `weapon_pistol_mauser`,            category = "pistol",   key = "m", ammo = 100 },
    { name = "winchester",   hash = `weapon_repeater_winchester`,      category = "repeater", key = "w", ammo = 100 },
    { name = "springfield",  hash = `weapon_rifle_springfield`,        category = "rifle",    key = "s", ammo = 100 },
    { name = "rollingblock", hash = `weapon_sniperrifle_rollingblock`, category = "sniper",   key = "o", ammo = 100 },
    { name = "dblbarrel",    hash = `weapon_shotgun_doublebarrel`,     category = "shotgun",  key = "d", ammo = 100 },
    { name = "bow",          hash = `weapon_bow`,                      category = "bow",      key = "b", ammo = 100 },
    { name = "dynamite",     hash = `weapon_thrown_dynamite`,          category = "thrown",   key = "y", ammo = 10 },
    { name = "knife",        hash = `weapon_melee_knife`,              category = "melee",    key = "k", ammo = 1 },
}

if dat.lookup == nil then dat.lookup = {} end
dat.lookup.weapon = {}
for _, w in ipairs(dat.weapon) do dat.lookup.weapon[w.hash] = w end

---@diagnostic disable-next-line: duplicate-set-field
dat.getWeaponName = function(hash)
    local weaponData = dat.lookup.weapon[hash]
    return weaponData and weaponData.name or hash
end
