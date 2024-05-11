local PromptZoneId = "daPromptZone"
local PromptCache = {}

---Create a prompt group. If there are duplicate option keys the first option
---with passing conditions will be shown.
---@param title string The title shown for the prompt group
---@param promptOptions table|nil A table of prompt options
Lib.Prompt.New = function(title, promptOptions)
    promptOptions = promptOptions or {}
    local promptGroup = Lib.API.PromptGroupCreate(title)
    if not promptGroup then return; end
    for _, opt in pairs(promptOptions) do
        local promptOption = Lib.Prompt.Option.New(opt.text, opt.key, opt.onTrigger)
        if promptOption then
            if not PromptCache[promptGroup] then PromptCache[promptGroup] = {}; end
            PromptCache[promptGroup][promptOption] = {
                key = opt.key,
                onTrigger = opt.onTrigger,
                condition = opt.condition,
                promptGroup = promptGroup,
            }
            -- Lib.Prompt.Add(promptGroup, promptOption, { key = opt.key, onTrigger = opt.onTrigger })
        end
    end
    -- for promptOption, promptOptionData in pairs(PromptCache[promptGroup]) do
    --     Lib.Log.Debug(("t %s"):format(promptOption))
    -- end
    return promptGroup
end

--- Add a prompt to a prompt group
---@param promptGroup number The promptGroup ID
---@param promptOption number The prompt ID
---@param data table Includes the following fields: key, onTrigger, condition
---@param zoneData table|nil The data to be passed to the prompt options
Lib.Prompt.Add = function(promptGroup, promptOption, data, zoneData)
    data = data or {}
    assert(promptGroup, "PromptGroup.Title: promptGroup is required")
    assert(promptOption, "PromptGroup.Title: prompt is required")
    assert(data.key, "PromptGroup.Add: data.key is required")
    assert(data.onTrigger, "PromptGroup.Add: data.onTrigger is required")
    Lib.API.PromptGroupAddPrompt(promptGroup, promptOption, data, zoneData)
end

--- Hide a prompt group
---@param promptGroup number The promptGroup ID
Lib.Prompt.Hide = function(promptGroup)
    assert(promptGroup, "PromptGroup.Title: promptGroup is required")
    Lib.API.PromptGroupHide(promptGroup)
end

--- Show a prompt group
---@param promptGroup number The promptGroup ID
Lib.Prompt.Show = function(promptGroup)
    assert(promptGroup, "PromptGroup.Title: promptGroup is required")
    Lib.API.PromptGroupShow(promptGroup)
end

---Set the title of a prompt group
---@param promptGroup number The promptGroup ID
---@param title string The title of the prompt group
Lib.Prompt.Title = function(promptGroup, title)
    assert(promptGroup, "PromptGroup.Title: promptGroup is required")
    assert(title, "PromptGroup.Title: title is required")
    Lib.API.PromptGroupSetTitle(promptGroup, title)
end

---Update a prompt group
---@param promptGroup number The promptGroup ID
---@param title string The title of the prompt to be displayed
---@param zoneData table|nil The data to be passed to the prompt options
Lib.Prompt.Update = function(promptGroup, title, zoneData)
    Lib.Log.Debug(promptGroup, title or "", zoneData)
    if not promptGroup or not PromptCache[promptGroup] then return; end
    if title then Lib.Prompt.Title(promptGroup, title); end
    local promptVisible = false
    Lib.Prompt.Reset(promptGroup)
    local optionKeys = {}
    for promptOption, promptOptionData in pairs(PromptCache[promptGroup]) do
        if not optionKeys[promptOptionData.key] and (promptOptionData.condition == nil or promptOptionData.condition(zoneData)) then
            Lib.Prompt.Add(promptGroup, promptOption, { key = promptOptionData.key, onTrigger = promptOptionData.onTrigger, }, zoneData)
            optionKeys[promptOptionData.key] = true
            -- Lib.Prompt.Option.Update(promptGroup, promptOptionData, zoneData)
            promptVisible = true
        -- else
        --     Lib.Prompt.Option.Hide(promptGroup, promptOption)
        end
    end
    if promptVisible then Lib.Prompt.Show(promptGroup); end
end

---Reset a prompt group by removing all prompt options
---@param promptGroup number The promptGroup ID
Lib.Prompt.Reset = function(promptGroup)
    assert(promptGroup, "PromptGroup.Reset: promptGroup is required")
    Lib.API.PromptReset(promptGroup)
end

local promptZoneHandlers = false
---Create a prompt zone which updates the prompt options when entering the zone. If there
---are duplicate keys, the first option with passing conditions will be shown.
---@param promptGroup number The promptGroup ID
---@param coords any The vector3 of the zone
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

---Create a prompt option
---@param title string The title of the prompt option
---@param key string The key of the prompt option
---@param onTrigger function|nil The function to call when the prompt is triggered
---@return unknown|nil The prompt ID
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

-- ---Hide a prompt option
-- ---@param promptOption number Id of the prompt
-- ---@return unknown|nil
-- Lib.Prompt.Option.Hide = function(promptOption)
--     return Lib.API.PromptHide(promptOption)
-- end

---Update a prompt option
---@param promptGroup any
---@param data any Keys include: key, onTrigger, condition
Lib.Prompt.Option.Update = function(promptGroup, data, zoneData)
    Lib.API.PromptUpdate(promptGroup, data, zoneData)
end


if Lib.Util.IsDev then
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
