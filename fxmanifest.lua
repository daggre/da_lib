--- Copyright © 2024 Joshua Nelson

fx_version 'cerulean'
games {'rdr3'}
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

author 'daggre_actual'
description 'Library of shared functions and utilities for daggre_actual resources'
version '0.9'
lua54 'yes'

shared_scripts {
    'src/import_sh.lua',
    'lib/loglevel/commands_sh.lua',
    'lib/loglevel/level_sh.lua',
    'lib/loglevel/resource_sh.lua',
    'lib/net/callback_sh.lua',
    'lib/string/string_sh.lua',
}

server_scripts {
    'lib/net/callback_srv.lua',
    -- Order necessary above this line

    -- API
    'api/tmc/tmc_srv.lua',
    'api/api_srv.lua',

    -- Libraries
    'lib/audio/audio_srv.lua',
    'lib/cache/lazyupdate_sh.lua',
    'lib/cache/temp_sh.lua',
    'lib/fn/fn_srv.lua',
    'lib/lock/global_srv.lua',
    'lib/object/intprop/intprop_srv.lua',
    'lib/string/string_sh.lua',
    'lib/time/time_srv.lua',
}

client_scripts {
    'lib/net/callback_cl.lua',
    -- Order necessary above this line

    -- Data
    'bin/af_flags.lua',
    'bin/aik_flags.lua',
    'bin/animations.lua',
    'bin/control.lua',
    'bin/objects.lua',
    'bin/peds.lua',
    'bin/pickups.lua',
    'bin/propsets.lua',
    'bin/vehicles.lua',

    -- API
    'api/tmc/tmc_cl.lua',
    'api/api_cl.lua',

    -- Libraries
    'lib/anim/anim_cl.lua',
    'lib/audio/audio_cl.lua',
    'lib/cache/lazyupdate_sh.lua',
    'lib/cache/temp_sh.lua',
    'lib/chance/chance_cl.lua',
    'lib/check/check_cl.lua',
    'lib/control/control_cl.lua',
    'lib/control/passthrough_cl.lua',
    'lib/data/data_cl.lua',
    'lib/fn/fn_cl.lua',
    'lib/fx/fx_cl.lua',
    'lib/interact/interact_cl.lua',
    'lib/lock/global_cl.lua',
    'lib/mode/check.lua',
    'lib/mode/mode.lua',
    'lib/zone/polyzone/polyzone_cl.lua',
    'lib/object/npc_cl.lua',
    'lib/object/object_cl.lua',
    'lib/object/props_cl.lua',
    'lib/object/intprop/intprop_cl.lua',
    'lib/prompt/prompt_cl.lua',
    'lib/stats/stats_cl.lua',
    'lib/time/time_cl.lua',
    'lib/util/util_cl.lua',
    'lib/util/draw_cl.lua',
    'lib/weapon/weapon_cl.lua',
    'lib/zone/zone_cl.lua',

}
