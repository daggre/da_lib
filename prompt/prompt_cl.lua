local PromptZoneId = "daPromptZone"
local PromptCache = {}

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
        -- Create the promptOption
        local promptOption = Lib.Prompt.Option.New(opt.text, opt.key, opt.onTrigger)
        if promptOption then

            -- Instantiate the promptGroup cache if it doesn't exist
            if not PromptCache[promptGroup] then PromptCache[promptGroup] = {}; end
            -- Store the promptOption data
            PromptCache[promptGroup][promptOption] = {
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
    assert(promptGroup, "PromptGroup.Title: promptGroup is required")
    assert(promptOption, "PromptGroup.Title: prompt is required")
    assert(data.key, "PromptGroup.Add: data.key is required")
    assert(data.onTrigger, "PromptGroup.Add: data.onTrigger is required")
    Lib.API.PromptGroupAddPrompt(promptGroup, promptOption, data, zoneData)
end

--- Hide a promptGroup
---@param promptGroup integer The promptGroup handle
Lib.Prompt.Hide = function(promptGroup)
    assert(promptGroup, "PromptGroup.Title: promptGroup is required")
    Lib.API.PromptGroupHide(promptGroup)
end

--- Show a promptGroup
---@param promptGroup integer The promptGroup handle
Lib.Prompt.Show = function(promptGroup)
    assert(promptGroup, "PromptGroup.Title: promptGroup is required")
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
---@param zoneData table|nil The data to be passed to the promptOptions
Lib.Prompt.Update = function(promptGroup, title, zoneData)
    Lib.Log.Debug("Updating promptGroup:", promptGroup, title or "", zoneData)
    if not promptGroup or not PromptCache[promptGroup] then return; end

    -- If a new title is passed as a param, update the title
    if title then Lib.Prompt.Title(promptGroup, title); end

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
    assert(promptGroup, "PromptGroup.Reset: promptGroup is required")
    Lib.API.PromptReset(promptGroup)
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
            Lib.Prompt.Update(zoneData.promptGroup, zoneData.name, zoneData)
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

---Create a promptOption
---@param title string The title of the promptOption
---@param key string The key of the promptOption
---@param onTrigger function|nil The function to call when the prompt is triggered
---@return unknown|nil The promptOption handle
Lib.Prompt.Option.New = function(title, key, onTrigger)
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

---Update a promptOption
---@param promptGroup integer The promptGroup handle
---@param data table Keys include: key, onTrigger, condition
---@param zoneData table|nil The zone data to be passed to the promptOptions
Lib.Prompt.Option.Update = function(promptGroup, data, zoneData)
    Lib.API.PromptUpdate(promptGroup, data, zoneData)
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
