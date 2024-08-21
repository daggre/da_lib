local PromptZoneId = "daPromptZone"
local PromptCache = {}
local VisiblePrompts = {}

---Create a promptGroup. If there are duplicate option keys the first option
---with passing conditions will be shown.

---@param title string The title shown for the promptGroup
---@param promptOptions table|nil A table of promptOptions
---@return integer|nil promptGroupHandle The promptGroup handle
Lib.Prompt.New = function(title, promptOptions)
    promptOptions = promptOptions or {}
    -- Create the promptGroup
    local promptGroup = Lib.API.PromptGroupCreate(title)
    if not promptGroup then return; end

    -- Add the individual promptOptions
    for _, opt in pairs(promptOptions) do
        local text = type(opt.text) == "string" and opt.text or "1"
        local promptOption = Lib.Prompt.Option.New(text, opt.key, opt.onTrigger)
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
Lib.Prompt.Add = function(promptGroup, promptOption, data, zoneData)
    data = data or {}
    assert(promptGroup, "PromptGroup.Add: promptGroup is required")
    assert(promptOption, "PromptGroup.Add: promptOption is required")
    assert(data.key, "PromptGroup.Add: data.key is required")
    assert(data.onTrigger, "PromptGroup.Add: data.onTrigger is required")
    Lib.API.PromptGroupAddPrompt(promptGroup, promptOption, data, zoneData)
end

--- Hide a prompt group
---@param promptGroup integer The promptGroup handle
Lib.Prompt.Hide = function(promptGroup, reset)
    assert(promptGroup, "PromptGroup.Hide: promptGroup is required")
    Lib.Log.Debug("PromptGroup.Hide", promptGroup, reset)
    if not reset then VisiblePrompts[promptGroup] = false; end
    Lib.API.PromptGroupHide(promptGroup)
end

--- Show a promptGroup
---@param promptGroup integer The promptGroup handle
Lib.Prompt.Show = function(promptGroup)
    assert(promptGroup, "PromptGroup.Show: promptGroup is required")
    Lib.Log.Debug("PromptGroup.Show", promptGroup)
    VisiblePrompts[promptGroup] = true
    Lib.API.PromptGroupShow(promptGroup)
end

---Set the title of a promptGroup
---@param promptGroup integer The promptGroup handle
---@param title string The title of the promptGroup
Lib.Prompt.Title = function(promptGroup, title)
    assert(promptGroup, "PromptGroup.Title: promptGroup is required")
    assert(title, "PromptGroup.Title: title is required")
    Lib.API.PromptGroupSetTitle(promptGroup, title)
end

---Update a promptGroup
---@param promptGroup integer The promptGroup handle
---@param title string The title of the prompt to be displayed
---@param zoneData table|nil The data to be passed to the prompt options
Lib.Prompt.Update = function(promptGroup, title, zoneData, enter)
    Lib.Log.Debug("Updating promptGroup:", promptGroup, title or "", zoneData, VisiblePrompts)
    if enter then VisiblePrompts[promptGroup] = true; end
    if not VisiblePrompts[promptGroup] then return; end
    if not promptGroup or not PromptCache[promptGroup] then return; end
    -- If a new title is passed as a param, update the title
    if title then
        local titleStr = ""
        if type(title) == "string" then
            titleStr = title
        elseif type(title) == "function" or (type(title) == "table" and title.__cfx_functionReference) then
            Lib.Log.Debug("Prompt.Update: title is a function", title)
            titleStr = title(zoneData)
        end
        Lib.Prompt.Title(promptGroup, titleStr)
    end

    -- Reset the promptGroup
    local promptVisible = false
    Lib.Prompt.Reset(promptGroup)
    local optionKeys = {}

    -- For each promptOption in the promptGroup, conditionally add the promptOption
    for promptOption, promptOptionData in pairs(PromptCache[promptGroup]) do
        -- Check that the key isn't already used and if there is a condition, it passes
        if not optionKeys[promptOptionData.key] and (promptOptionData.condition == nil or promptOptionData.condition(zoneData)) then
            -- Add the promptOption
            Lib.Prompt.Add(promptGroup, promptOption, { key = promptOptionData.key, onTrigger = promptOptionData.onTrigger, }, zoneData)
            -- Mark the key as used
            optionKeys[promptOptionData.key] = true
            if type(promptOptionData.text) == "function" or (type(promptOptionData.text) == "table" and promptOptionData.text.__cfx_functionReference) then
                local promptOptionText = promptOptionData.text(zoneData)
                Lib.Prompt.Option.Update(promptGroup, promptOptionData.key, promptOptionText)
            end
            -- There is at least one valid prompt option, mark the prompt to be shown
            promptVisible = true
        end
    end
    -- If there are any current valid promptOptions, show the promptGroup
    if promptVisible then Lib.Prompt.Show(promptGroup); end
end

---Reset a promptGroup by removing all promptOptions
---@param promptGroup integer The promptGroup handle
Lib.Prompt.Reset = function(promptGroup)
    assert(promptGroup, "Prompt.Reset: promptGroup is required")
    Lib.API.PromptReset(promptGroup)
    Lib.Prompt.Hide(promptGroup, true)
end

local promptZoneHandlers = false
---Create a prompt zone and register the enter/exit event handlers.
---@param promptGroup integer The promptGroup handle
---@param coords table The vector3 of the zone
---@param radius number|nil The radius of the zone
---@param options table|nil The options of the zone
Lib.Prompt.Zone = function(promptGroup, coords, radius, options)
    if not promptZoneHandlers then
        promptZoneHandlers = true
        Lib.PolyZone.OnEnter(PromptZoneId, function(zoneData)
            Lib.Prompt.Update(zoneData.promptGroup, zoneData.name, zoneData, true)
        end)
        Lib.PolyZone.OnExit(PromptZoneId, function(zoneData)
            Lib.Prompt.Hide(zoneData.promptGroup)
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
Lib.Prompt.Option.New = function(title, key, onTrigger)
    if type(title) ~= "string" then title = "t"; end
    local promptOption = Lib.API.PromptCreate(title, key)
    -- if not promptOption then return; end
    -- if onTrigger then
    --     Lib.API.PromptUpdate(promptOption, {
    --         key = key,
    --         onTrigger = onTrigger,
    --     })
    -- end
    return promptOption
end

-- ---Hide a prompt option
-- ---@param promptOption number Id of the prompt
-- ---@return unknown|nil
-- Lib.Prompt.Option.Hide = function(promptOption)
--     return Lib.API.PromptHide(promptOption)
-- end

---Update a promptOption
---@param promptGroup integer The promptGroup handle
---@param key string The key of the prompt option
---@param title any
Lib.Prompt.Option.Update = function(promptGroup, key, title)
    Lib.API.PromptUpdateText(promptGroup, key, title)
end


if Lib.Util.IsDev then
    -- Register a command to print out all the registered promptGroups
    RegisterCommand("dalib_prompt_dump", function(source, args, rawCommand)
        Lib.Log.Debug("Dumping promptGroups...")
        for promptGroup, promptGroupData in pairs(PromptCache) do
            Lib.Log.Debug(("PromptGroup: %s"):format(promptGroup))
            for promptOption, promptOptionData in pairs(promptGroupData) do
                Lib.Log.Debug(("PromptOption: %s"):format(promptOption))
                Lib.Log.Debug(promptOptionData)
            end
        end
    end, false)
end
