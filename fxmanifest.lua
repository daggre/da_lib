--- Copyright © 2024 Joshua Nelson

fx_version 'cerulean'
games {'rdr3'}
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

author 'daggre_actual'
description 'Library of shared functions and utilities for daggre_actual resources'
version '0.8'
lua54 'yes'

server_scripts {
    'import_sh.lua',
    'loglevel/commands_sh.lua',
    'loglevel/level_sh.lua',
    'loglevel/resource_sh.lua',
    'net/callback_sh.lua',
    'net/callback_srv.lua',
    -- Order necessary above this line
    'api/tmc/tmc_srv.lua',
    'api/api_srv.lua',
    'audio/audio_srv.lua',
    'cache/lazyupdate_sh.lua',
    'cache/temp_sh.lua',
    'fn/fn_srv.lua',
    'lock/global_srv.lua',
    'object/intprop/intprop_srv.lua',
    'string/string_sh.lua',
    'time/time_srv.lua',
}

client_scripts {
    'import_sh.lua',
    'loglevel/commands_sh.lua',
    'loglevel/level_sh.lua',
    'loglevel/resource_sh.lua',
    'net/callback_sh.lua',
    'net/callback_cl.lua',
    -- Order necessary above this line
    'string/string_sh.lua',
    'api/tmc/tmc_cl.lua',
    'api/api_cl.lua',
    'anim/anim_cl.lua',
    'audio/audio_cl.lua',
    'cache/lazyupdate_sh.lua',
    'cache/temp_sh.lua',
    'chance/chance_cl.lua',
    'check/check_cl.lua',
    'control/control_cl.lua',
    'fn/fn_cl.lua',
    'fx/fx_cl.lua',
    'lock/global_cl.lua',
    'zone/polyzone/polyzone_cl.lua',
    'object/npc_cl.lua',
    'object/object_cl.lua',
    'object/props_cl.lua',
    'object/intprop/intprop_cl.lua',
    'prompt/prompt_cl.lua',
    'time/time_cl.lua',
    'util/util_cl.lua',
    'util/draw_cl.lua',
    'zone/zone_cl.lua',
}
