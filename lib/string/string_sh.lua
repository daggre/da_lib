--- Copyright © 2024 Joshua Nelson

-- String utils for lua not provided by native lib

---Split the string into a table of strings based on the separator
---@param str string The string to split
---@param sep string|nil The separator to split the string on
---@return table splitString The table of strings
Lib.String.Split = function(str, sep)
    -- Default to splitting on spaces
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for s in string.gmatch(str, "([^"..sep.."]+)") do
        table.insert(t,s)
    end
    return t
end

---Search string for a substring
---@param s string The string to check
---@param f string The substring to find
---@return boolean match Whether the substring was found
Lib.String.LooseMatch = function(s, f)
    -- Check if b is empty or longer than a
    if #f == 0 or #f > #s then return false end
    -- Iterate the string using gmatch
    for match in s:gmatch(("^(%s)"):format(f)) do
        -- The substring was found
        if match == f then return true end
    end
    -- No match
    return false
end

---Format any type into a readable string
---@param m any The value to format
---@param addQuotes boolean|nil Whether to add quotes to strings
---@return string string The formatted string
Lib.String.Format = function(m, addQuotes)
    if type(m) == 'nil' then return "nil"
    elseif type(m) == 'string' and addQuotes then return '"'..m..'"'
    elseif type(m) == 'string' then return m
    elseif type(m) == 'boolean' then if m then return "true"; else return "false"; end
    elseif type(m) == 'number' then return tostring(m)
    elseif type(m) == 'table' then
        local s = '{'
        for key, value in pairs(m) do
            local k = ""
            if type(key) == 'number' then k = "["..key.."]"
            elseif type(key) == 'string' then k = "[\""..key.."\"]"
            else k = "[\""..key.."\"]"
            end
            s = ("%s%s=%s, "):format(s, k, Lib.String.Format(value, true))
        end
        s = s..'}'
        return s
    elseif type(m) == 'vector3' then
        return ("vector3(%.3f, %.3f, %.3f)"):format(m.x, m.y, m.z)
    elseif type(m) == 'vector4' then
        return ("vector4(%.3f, %.3f, %.3f, %.3f)"):format(m.x, m.y, m.z, m.w)
    end
    return ""
end

---Concatenate any number of arguments into a single string separated by spaces
---@param ... unknown The arguments to concatenate
---@return string string The concatenated string
Lib.String.Concat = function(...)
    local args = {...}
    local s = ""
    local spc = ""
    for _, a in pairs(args) do -- TODO see if there is a better way to utilize ipairs
        s = s..spc..Lib.String.Format(a)
        spc = "    "
    end
    return s
end
