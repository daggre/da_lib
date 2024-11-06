--- Copyright © 2024 Joshua Nelson

fx_version 'cerulean'
games {'rdr3'}
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

author 'daggre_actual'
description 'Library of shared functions and utilities for daggre_actual resources'
version '0.9'
lua54 'yes'

shared_scripts {
    '@da_log/log_sh.lua',
    'lib/cache_delay.lua',
    'lib/cache_lazy.lua',
    -- 'lib/cache_temp.lua',
    'ctl/api_sh_ctl.lua',
    'lib/kvp_sh.lua',
    'lib/cli_sh.lua',
}

server_scripts {
    'lib/net_srv.lua',
    'ctl/lock_srv_ctl.lua',
    'ctl/epoch_srv_ctl.lua',
    'ctl/audio_srv_ctl.lua',

    -- Libraries
    -- 'lib/fn/fn_srv.lua',
    -- 'lib/object/intprop/intprop_srv.lua',

    -- API
    'api/**/*_srv.lua',
    'api/api_sh.lua',
}

client_scripts {
    'lib/net_cl.lua',
    'lib/lock_cl.lua',
    'lib/audio_cl.lua',
    'lib/chance_cl.lua',
    'lib/control_cl.lua',
    'lib/draw_cl.lua',
    'lib/epoch_cl.lua',
    'lib/fx_cl.lua',
    'lib/object_cl.lua',
    'ctl/mode_cl_ctl.lua',
    'lib/mode_cl.lua',
    'lib/trie_cl.lua',

    '@polyzone/client.lua',
    '@polyzone/CircleZone.lua',
    'lib/polyzone_cl.lua',

    -- Data
    'dat/flags_af.lua',
    'dat/flags_aik.lua',
    'dat/animation.lua',
    'dat/key.lua',
    'dat/object.lua',
    'dat/ped.lua',
    'dat/pickup.lua',
    'dat/propset.lua',
    'dat/vehicle.lua',

    'lib/anim_cl.lua',
    'lib/util_cl.lua',

    -- Libraries
    -- 'lib/chance/chance_cl.lua',
    -- 'lib/control/control_cl.lua',
    -- 'lib/control/passthrough_cl.lua',
    -- 'lib/fn/fn_cl.lua',
    -- 'lib/fx/fx_cl.lua',
    -- 'lib/interact/interact_cl.lua',
    -- 'lib/mode/check.lua',
    -- 'lib/mode/mode.lua',
    -- 'lib/zone/polyzone/polyzone_cl.lua',
    -- 'lib/object/npc_cl.lua',
    -- 'lib/object/props_cl.lua',
    -- 'lib/object/intprop/intprop_cl.lua',
    -- 'lib/prompt/prompt_cl.lua',
    -- 'lib/util/util_cl.lua',
    -- 'lib/util/draw_cl.lua',
    -- 'lib/zone/zone_cl.lua',

    -- API
    'api/**/*_cl.lua',
    'api/api_sh.lua',
}
