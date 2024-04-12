-- String utils for lua not provided by native lib

Lib.String.Split = function(str, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for s in string.gmatch(str, "([^"..sep.."]+)") do
        table.insert(t,s)
    end
    return t
end

Lib.String.LooseMatch = function(a, b)
    for k,v in ipairs(a) do
        if b[k] and v ~= b[k] then return false; end
    end
    return true
end

---Pretty format any value type into a string
Lib.String.Format = function(m, addQuotes)
    if type(m) == 'nil' then return "nil"
    elseif type(m) == 'string' and addQuotes then return '"'..m..'"'
    elseif type(m) == 'string' then return m
    elseif type(m) == 'boolean' then if m then return "true"; else return "false"; end
    elseif type(m) == 'number' then return tostring(m)
    elseif type(m) == 'table' then
        local s = '{'
        for key, value in pairs(m) do
            k = ""
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
