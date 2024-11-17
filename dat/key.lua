if dat == nil then dat = {} end

dat.keyHash = {
    ['1'] = `INPUT_SELECT_QUICKSELECT_SIDEARMS_LEFT`,
    ['2'] = `INPUT_SELECT_QUICKSELECT_DUALWIELD`,
    ['3'] = `INPUT_SELECT_QUICKSELECT_SIDEARMS_RIGHT`,
    ['4'] = `INPUT_SELECT_QUICKSELECT_UNARMED`,
    ['5'] = `INPUT_SELECT_QUICKSELECT_MELEE_NO_UNARMED`,
    ['6'] = `INPUT_SELECT_QUICKSELECT_SECONDARY_LONGARM`,
    ['7'] = `INPUT_SELECT_QUICKSELECT_THROWN`,
    ['8'] = `INPUT_SELECT_QUICKSELECT_PRIMARY_LONGARM`,
    ['a'] = `INPUT_MOVE_LEFT_ONLY`,
    ['c'] = `INPUT_LOOK_BEHIND`,
    ['d'] = `INPUT_MOVE_RIGHT_ONLY`,
    ['e'] = `INPUT_DYNAMIC_SCENARIO`,
    ['f'] = `INPUT_CONTEXT_B`,
    ['g'] = `INPUT_INTERACT_ANIMAL`,
    ['h'] = `INPUT_WHISTLE`,
    ['q'] = `INPUT_FRONTEND_LB`,
    ['r'] = `INPUT_RELOAD`,
    ['s'] = `INPUT_MOVE_DOWN_ONLY`,
    ['v'] = `INPUT_NEXT_CAMERA`,
    ['w'] = `INPUT_MOVE_UP_ONLY`,
    ['x'] = `INPUT_SWITCH_SHOULDER`,
    ['z'] = `INPUT_GAME_MENU_TAB_LEFT_SECONDARY`,
    -- ['alt'] = `INPUT_SELECT_RADAR_MODE`,
    ['alt'] = `INPUT_HUD_SPECIAL`,
    ['shift'] = `INPUT_SPRINT`,
    ['ctrl'] = `INPUT_FRONTEND_RUP`,
    ['Crouch'] = `INPUT_DUCK`,
    ['Spacebar'] = `INPUT_JUMP`,
    [' '] = `INPUT_JUMP`,
    ['MouseLR'] = `INPUT_LOOK_LR`,
    ['MouseUD'] = `INPUT_LOOK_UD`,
    ['MouseLeft'] = `INPUT_ATTACK`,
    ['MouseLeft2'] = `SKIPCUTSCENE`,
    ['MouseRight'] = `INPUT_AIM`,
    -- ['MouseScrollClick'] = `INPUT_PC_FREE_LOOK`, -- LALT conflict
    ['MouseScrollClick'] = `INPUT_SPECIAL_ABILITY`,
    ['WheelUp'] = `INPUT_PREV_WEAPON`,
    ['WheelDown'] = `INPUT_NEXT_WEAPON`,
    [']'] = `INPUT_SNIPER_ZOOM_IN_ONLY`, -- Possible conflict with scroll up
    ['RightBracket'] = `INPUT_SNIPER_ZOOM_IN_ONLY`,
    ['Escape'] = `INPUT_GAME_MENU_CANCEL`, -- Conflict with Backspace
    ['Escape2'] = `INPUT_FRONTEND_RRIGHT`,
    ['Escape3'] = `INPUT_FRONTEND_PAUSE_ALTERNATE`, -- Opens exit menu
}

dat.keyHashList = {}
for _, keyHash in pairs(dat.keyHash) do
    table.insert(dat.keyHashList, keyHash)
    dat.keyHashList[keyHash] = keyHash
end
