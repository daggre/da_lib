local mode_t1 = {
    name = "test_1",
    priority = 1,
    onActivate = function() log.info("  Mode test_1 onActivate called") end,
    onDeactivate = function() log.info("  Mode test_1 onDeactivate called") end,
    onPrimary = function() log.info("  Mode test_1 onPrimary called") end,
    onLosePrimary = function() log.info("  Mode test_1 onLosePrimary called") end,
    keymaps = {
        ['1'] = {
            justPressed = {
                primary = true,
                fn = function() log.info("> 1 justPressed test_1") end
            },
        },
        ['2'] = {
            justPressed = {
                active = true,
                modifiers = { ctrl = true, },
                fn = function() log.info("> ctrl 2 justPressed test_1") end
            },
        },
        ['3'] = {
            justPressed = {
                fn = function() log.info("> 3 justPressed test_1") end
            },
        },
    }
}
local mode_t2 = {
    name = "test_2",
    priority = 2,
    onActivate = function() log.info("  Mode test_2 onActivate called") end,
    onDeactivate = function() log.info("  Mode test_2 onDeactivate called") end,
    onPrimary = function() log.info("  Mode test_2 onPrimary called") end,
    onLosePrimary = function() log.info("  Mode test_2 onLosePrimary called") end,
    keymaps = {
        ['1'] = {
            justPressed = {
                primary = true,
                fn = function() log.info("> 1 justPressed test_2") end
            },
        },
        ['2'] = {
            justPressed = {
                active = true,
                modifiers = { shift = true, },
                fn = function() log.info("> shift 2 justPressed test_2") end
            },
        },
        ['3'] = {
            justPressed = {
                fn = function() log.info("> 3 justPressed test_2") end
            },
        },
    }
}
local mode_t3 = {
    name = "test_3",
    priority = 3,
    onActivate = function() log.info("  Mode test_3 onActivate called") end,
    onDeactivate = function() log.info("  Mode test_3 onDeactivate called") end,
    onPrimary = function() log.info("  Mode test_3 onPrimary called") end,
    onLosePrimary = function() log.info("  Mode test_3 onLosePrimary called") end,
    keymaps = {
        ['1'] = {
            justPressed = {
                primary = true,
                fn = function() log.info("> 1 justPressed test_3") end
            },
        },
        ['2'] = {
            justPressed = {
                active = true,
                modifiers = { alt = true, },
                fn = function() log.info("> alt 2 justPressed test_3") end
            },
        },
        ['3'] = {
            justPressed = {
                fn = function() log.info("> 3 justPressed test_3") end
            },
        },
    }
}

local function TestRegisterModes()
    log.info("--- Testing Register Modes")
    da_mode.register(mode_t1)
    da_mode.register(mode_t2)
    da_mode.register(mode_t3)
end

local function TestPrimaryAndActiveModes()
    log.info("--- Testing Primary and Active Modes")
    da_mode.activate("test_1")
    da_mode.activate("test_2")
    da_mode.activate("test_3")

    da_mode.deactivate("test_3")
    da_mode.deactivate("test_1")
    da_mode.deactivate("test_2")
end

local function TestEventsInactive()
    log.info("--- Testing Event Inactive")
    da_mode.simulateEvent({ key = "1", type = "justPressed", mods = { alt = true, shift = true, ctrl = true } })
    da_mode.simulateEvent({ key = "2", type = "justPressed", mods = { alt = true, shift = true, ctrl = true } })
    da_mode.simulateEvent({ key = "3", type = "justPressed", mods = { alt = true, shift = true, ctrl = true } })
end

local function TestEventsActive1()
    log.info("--- Testing Event Active: 1")
    da_mode.activate("test_1")
    da_mode.simulateEvent({ key = "1", type = "justPressed", mods = { alt = true, shift = true, ctrl = true } })
    da_mode.simulateEvent({ key = "2", type = "justPressed", mods = { alt = true, shift = true, ctrl = true } })
    da_mode.simulateEvent({ key = "3", type = "justPressed", mods = { alt = true, shift = true, ctrl = true } })
end

local function TestEventsActive12()
    log.info("--- Testing Event Active: 1,2")
    da_mode.activate("test_2")
    da_mode.simulateEvent({ key = "1", type = "justPressed", mods = { alt = true, shift = true, ctrl = true } })
    da_mode.simulateEvent({ key = "2", type = "justPressed", mods = { alt = true, shift = true, ctrl = true } })
    da_mode.simulateEvent({ key = "3", type = "justPressed", mods = { alt = true, shift = true, ctrl = true } })
end


local function TestEventsActive123()
    log.info("--- Testing Event Active: 1,2,3")
    da_mode.activate("test_3")
    da_mode.simulateEvent({ key = "1", type = "justPressed", mods = { alt = true, shift = true, ctrl = true } })
    da_mode.simulateEvent({ key = "2", type = "justPressed", mods = { alt = true, shift = true, ctrl = true } })
    da_mode.simulateEvent({ key = "3", type = "justPressed", mods = { alt = true, shift = true, ctrl = true } })
end

Citizen.CreateThread(function()
    log.info("--- Running Mode Tests ---")
    log.info("---")
    TestRegisterModes()
    log.info("---")
    TestPrimaryAndActiveModes()
    log.info("---")
    TestEventsInactive()
    log.info("---")
    TestEventsActive1()
    log.info("---")
    TestEventsActive12()
    log.info("---")
    TestEventsActive123()
    log.info("---")
    log.info("--- Teardown")
    da_mode.deactivate("test_3")
    da_mode.deactivate("test_2")
    da_mode.deactivate("test_1")
end)
