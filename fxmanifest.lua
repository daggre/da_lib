fx_version 'cerulean'
games {'rdr3'}
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

author 'daggre_actual'
description 'Library of shared functions and utilities for daggre_actual resources'
version '0.9'
lua54 'yes'

shared_scripts {
    '@da_log/log_sh.lua',
    'features/cache/cache_delay.lua',
    'features/cache/cache_lazy.lua',
    'features/api/api_sh_ctl.lua',
    'features/cli/cli_sh.lua',
    'features/kvp/kvp_sh.lua',
}

server_scripts {
    'features/net/net_srv.lua',
    'features/lock/lock_srv_ctl.lua',
    'features/epoch/epoch_srv_ctl.lua',
    'features/audio/audio_srv_ctl.lua',

    -- API
    'features/api/api_sh.lua',
    'features/api/default/default_srv.lua',
    'features/api/transport_srv.lua',
}

client_scripts {
    -- Data
    'data/flags_af.lua',
    'data/flags_aik.lua',
    'data/animation.lua',
    'data/bones.lua',
    'data/control.lua',
    'data/key.lua',
    'data/object.lua',
    'data/ped.lua',
    'data/pickup.lua',
    'data/propset.lua',
    'data/taskFilter.lua',
    'data/vehicle.lua',
    'data/weapon.lua',
    'data/clothing.lua',
    'data/horse.lua',
    'data/hunting.lua', -- Lowest priority

    'features/anim/anim_cl.lua',
    'features/util/util_cl.lua',
    'features/util/dataview.lua',
    'features/event/event_cl_ctl.lua',
    'features/event/event_cl.lua',

    'features/net/net_cl.lua',
    'features/lock/lock_cl.lua',
    'features/audio/audio_cl.lua',
    'features/chance/chance_cl.lua',
    'features/condition/condition_cl.lua',
    'features/control/control_cl.lua',
    'features/draw/draw_cl.lua',
    'features/texture/texture_cl.lua',
    'features/epoch/epoch_cl.lua',
    'features/fx/fx_cl.lua',
    'features/hud/cores_cl.lua',
    'features/object/object_cl.lua',
    'features/mode/mode_cl_ctl.lua',
    'features/mode/mode_cl.lua',
    'features/mode/mcp_cl.lua',
    'features/move/move_cl.lua',
    'features/nui/nui_cl.lua',
    'features/raycast/raycast_cl.lua',
    'features/trie/trie_cl.lua',
    'features/weapon/weapon_cl.lua',
    'features/clothing/clothing_cl.lua',
    'features/horse/horse_cl.lua',
    'features/camera/camera_cl.lua',
    'features/kvp/kvp_cl_ctl.lua',

    -- API
    'features/api/api_sh.lua',
    'features/api/default/default_cl.lua',
    'features/mode/game/init_cl.lua',
}
