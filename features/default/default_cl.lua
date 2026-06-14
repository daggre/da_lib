Default = {}

Default.value = function(v, d)
    if v ~= nil then return v end
    return d
end

-- local n = n or 1                                        (nil=1,0=0,42=42,"42"="42")
-- local n = type(n) == "number" and n or 1                (nil=1,0=0,42=42,"42"=1)
-- local n = type(n) == "number" and n > 0 and n or 1      (nil=1,0=0,42=42,-42=1)
-- local n = type(n) == "number" and n or 0                (nil=0,0=0,42=42,"42"=0)
Default.number = function(v, d)
    if type(v) == "number" then return v end
    return d
end


-- local n = type(n) == "number" and n % 1 == 0 and n or 1 (nil=1,0=0,42=42,42.5=1)
Default.integer = function(v, d)
    if type(v) == "number" and v % 1 == 0 then return v end
    return d
end

-- local s = s or "default"                                (nil="default"/""=""/"ab"="ab"/123=123)
-- local s = type(s) == "string" and s or "default"        (nil="default"/""=""/"ab"="ab"/123="default")
-- local s = type(s) == "string" and s ~= "" or "default"  (nil="default"/""="default"/"ab"="ab"/123="default")
-- local s = type(s) == "string" and s or ""               (nil=""/""=""/"ab"="ab"/123="")
Default.string = function(v, d)
    if type(v) == "string" then return v end
    return d
end

-- local b = b and b == true                (nil=false/false=false/true=true)
-- local b = b ~= false                     (nil=true/false=false/true=true)
-- local b = b; if b then b = DEFAULT end   (nil=DEFAULT/false=false,true=true)
Default.boolean = function(v, d)
    if type(v) == "boolean" then return v end
    return d
end

_ENV.da_default = Default
