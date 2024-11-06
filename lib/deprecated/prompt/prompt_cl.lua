local Prompt = {}
local PromptZoneId = "daPromptZone"
local PromptCache = {}
local VisiblePrompts = {}

---Create a promptGroup. If there are duplicate option keys the first option
---with passing conditions will be shown.

---@param title string The title shown for the promptGroup
---@param promptOptions table|nil A table of promptOptions
---@return integer|nil promptGroupHandle The promptGroup handle
Prompt.new = function(title, promptOptions)
    promptOptions = promptOptions or {}
    -- Create the promptGroup
    local promptGroup = API.promptGroupCreate(title)
    if not promptGroup then return; end

    -- Add the individual promptOptions
    for _, opt in pairs(promptOptions) do
        local text = type(opt.text) == "string" and opt.text or "1"
        local promptOption = Prompt.option.new(text, opt.key, opt.onTrigger)
        if promptOption then

            -- Instantiate the promptGroup cache if it doesn't exist
            if not PromptCache[promptGroup] then PromptCache[promptGroup] = {}; end
            -- Store the promptOption data
            PromptCache[promptGroup][promptOption] = {
                text = opt.text,
                key = opt.key,
                onTrigger = opt.onTrigger,
                condition = opt.condition,
                promptGroup = promptGroup,
            }
        end
    end
    -- Return the handle of the promptGroup
    return promptGroup
end

--- Add a promptOption to a promptGroup
---@param promptGroup integer The promptGroup handle
---@param promptOption integer The promptOption handle
---@param data table Includes the following fields: key, onTrigger, condition
---@param zoneData table|nil The data to be passed to the promptOptions
Prompt.add = function(promptGroup, promptOption, data, zoneData)
    data = data or {}
    assert(promptGroup, "PromptGroup.Add: promptGroup is required")
    assert(promptOption, "PromptGroup.Add: promptOption is required")
    assert(data.key, "PromptGroup.Add: data.key is required")
    assert(data.onTrigger, "PromptGroup.Add: data.onTrigger is required")
    API.promptGroupAddPrompt(promptGroup, promptOption, data, zoneData)
end

--- Hide a prompt group
---@param promptGroup integer The promptGroup handle
Prompt.hide = function(promptGroup, reset)
    assert(promptGroup, "PromptGroup.Hide: promptGroup is required")
    log.debug("PromptGroup.Hide", promptGroup, reset)
    if not reset then VisiblePrompts[promptGroup] = false; end
    API.promptGroupHide(promptGroup)
end

--- Show a promptGroup
---@param promptGroup integer The promptGroup handle
Prompt.show = function(promptGroup)
    assert(promptGroup, "PromptGroup.Show: promptGroup is required")
    log.debug("PromptGroup.Show", promptGroup)
    VisiblePrompts[promptGroup] = true
    API.promptGroupShow(promptGroup)
end

---Set the title of a promptGroup
---@param promptGroup integer The promptGroup handle
---@param title string The title of the promptGroup
Prompt.title = function(promptGroup, title)
    assert(promptGroup, "PromptGroup.Title: promptGroup is required")
    assert(title, "PromptGroup.Title: title is required")
    API.promptGroupSetTitle(promptGroup, title)
end

---Update a promptGroup
---@param promptGroup integer The promptGroup handle
---@param title string The title of the prompt to be displayed
---@param zoneData table|nil The data to be passed to the prompt options
Prompt.update = function(promptGroup, title, zoneData, enter)
    log.debug("Updating promptGroup:", promptGroup, title or "", zoneData, VisiblePrompts)
    if enter then VisiblePrompts[promptGroup] = true; end
    if not VisiblePrompts[promptGroup] then return; end
    if not promptGroup or not PromptCache[promptGroup] then return; end
    -- If a new title is passed as a param, update the title
    if title then
        local titleStr = ""
        if type(title) == "string" then
            titleStr = title
        elseif type(title) == "function" or (type(title) == "table" and title.__cfx_functionReference) then
            log.debug("Prompt.update: title is a function", title)
            titleStr = title(zoneData)
        end
        Prompt.title(promptGroup, titleStr)
    end

    -- Reset the promptGroup
    local promptVisible = false
    Prompt.reset(promptGroup)
    local optionKeys = {}

    -- For each promptOption in the promptGroup, conditionally add the promptOption
    for promptOption, promptOptionData in pairs(PromptCache[promptGroup]) do
        -- Check that the key isn't already used and if there is a condition, it passes
        if not optionKeys[promptOptionData.key] and (promptOptionData.condition == nil or promptOptionData.condition(zoneData)) then
            -- Add the promptOption
            Prompt.add(promptGroup, promptOption, { key = promptOptionData.key, onTrigger = promptOptionData.onTrigger, }, zoneData)
            -- Mark the key as used
            optionKeys[promptOptionData.key] = true
            if type(promptOptionData.text) == "function" or (type(promptOptionData.text) == "table" and promptOptionData.text.__cfx_functionReference) then
                local promptOptionText = promptOptionData.text(zoneData)
                Prompt.option.update(promptGroup, promptOptionData.key, promptOptionText)
            end
            -- There is at least one valid prompt option, mark the prompt to be shown
            promptVisible = true
        end
    end
    -- If there are any current valid promptOptions, show the promptGroup
    if promptVisible then Prompt.show(promptGroup); end
end

---Reset a promptGroup by removing all promptOptions
---@param promptGroup integer The promptGroup handle
Prompt.reset = function(promptGroup)
    assert(promptGroup, "Prompt.reset: promptGroup is required")
    API.promptReset(promptGroup)
    Prompt.hide(promptGroup, true)
end

local promptZoneHandlers = false
---Create a prompt zone and register the enter/exit event handlers.
---@param promptGroup integer The promptGroup handle
---@param coords table The vector3 of the zone
---@param radius number|nil The radius of the zone
---@param options table|nil The options of the zone
Prompt.zone = function(promptGroup, coords, radius, options)
    if not promptZoneHandlers then
        promptZoneHandlers = true
        Lib.PolyZone.OnEnter(PromptZoneId, function(zoneData)
            Prompt.update(zoneData.promptGroup, zoneData.name, zoneData, true)
        end)
        Lib.PolyZone.OnExit(PromptZoneId, function(zoneData)
            Prompt.hide(zoneData.promptGroup)
        end)
    end
    options = options or {}
    options.data = options.data or {}
    options.data.promptGroup = promptGroup
    Lib.PolyZone.Circle(PromptZoneId, coords, radius or 1.0, options)
end

---@param title string|table The title of the prompt option
---@param onTrigger function|nil The function to call when the prompt is triggered
---@return unknown|nil The promptOption handle
Prompt.option.new = function(title, key, onTrigger)
    if type(title) ~= "string" then title = "t"; end
    local promptOption = API.promptCreate(title, key)
    -- if not promptOption then return; end
    -- if onTrigger then
    --     API.promptUpdate(promptOption, {
    --         key = key,
    --         onTrigger = onTrigger,
    --     })
    -- end
    return promptOption
end

-- ---Hide a prompt option
-- ---@param promptOption number Id of the prompt
-- ---@return unknown|nil
-- Prompt.option.hide = function(promptOption)
--     return API.promptHide(promptOption)
-- end

---Update a promptOption
---@param promptGroup integer The promptGroup handle
---@param key string The key of the prompt option
---@param title any
Prompt.option.update = function(promptGroup, key, title)
    API.promptUpdateText(promptGroup, key, title)
end

_ENV.da_prompt = Prompt
