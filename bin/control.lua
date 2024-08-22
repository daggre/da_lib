Control = {
    a = `INPUT_MOVE_LEFT_ONLY`,
    c = 0x9959A6F0,
    d = `INPUT_MOVE_RIGHT_ONLY`,
    e = `INPUT_DYNAMIC_SCENARIO`,
    f = `INPUT_CONTEXT_B`,
    g = `INPUT_INTERACT_ANIMAL`,
    h = 0x24978A28,
    q = `INPUT_FRONTEND_LB`,
    r = `INPUT_RELOAD`,
    s = `INPUT_MOVE_DOWN_ONLY`,
    v = `INPUT_NEXT_CAMERA`,
    w = `INPUT_MOVE_UP_ONLY`,
    x = `INPUT_SWITCH_SHOULDER`,
    z = 0x26E9DC00,
    Crouch = `INPUT_DUCK`,
    Spacebar = `INPUT_JUMP`,
    [" "] = `INPUT_JUMP`,
    Alt = `INPUT_PC_FREE_LOOK`,
    Shift = `INPUT_SPRINT`,
    Control = `INPUT_FRONTEND_RUP`,
    MouseLR = `INPUT_LOOK_LR`,
    MouseUD = `INPUT_LOOK_UD`,
    MouseLeft = `INPUT_ATTACK`,
    MouseLeft2 = `SKIPCUTSCENE`,
    MouseRight = `INPUT_AIM`,
    WheelUp = `INPUT_PREV_WEAPON`,
    WheelDown = `INPUT_NEXT_WEAPON`,
    ["]"] = 0xA5BDCD3C,
    RightBracket = 0xA5BDCD3C,
    Escape = 0x308588E6,
    Escape2 = `INPUT_FRONTEND_RRIGHT`,
    Escape3 = `INPUT_FRONTEND_PAUSE_ALTERNATE`,
}

ControlKeys = {}
for _, keyHash in pairs(Control) do
    table.insert(ControlKeys, keyHash)
    ControlKeys[keyHash] = keyHash
end
