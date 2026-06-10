local Texture = {}

local LoadTextureDict = function(dict)
    if HasStreamedTextureDictLoaded(dict) then return true; end
    RequestStreamedTextureDict(dict, false)
    local timeout = GetGameTimer() + 1000
    while not HasStreamedTextureDictLoaded(dict) do
        if GetGameTimer() > timeout then
            log.debug("Failed to load textureDict", dict)
            return false
        end
        Citizen.Wait(100)
    end
    return true
end

---Load a streamed texture dictionary. Blocks until loaded or 1s timeout.
---@param dict string The texture dictionary name
---@return boolean success
Texture.load = function(dict)
    return LoadTextureDict(dict)
end

---Release a streamed texture dictionary.
---@param dict string The texture dictionary name
Texture.unload = function(dict)
    SetStreamedTextureDictAsNoLongerNeeded(dict)
end

---Draw a sprite from a streamed texture dict each frame.
---Non-blocking: if the dict is not loaded, issues a request and returns false.
---Call Texture.load() once before using in a render loop.
---@param dict string The texture dictionary name
---@param name string The texture name within the dictionary
---@param sx number Screen X (0–1)
---@param sy number Screen Y (0–1)
---@param w number Width (0–1)
---@param h number Height (0–1)
---@param heading number Rotation in degrees
---@param r number Red (0–255)
---@param g number Green (0–255)
---@param b number Blue (0–255)
---@param a number Alpha (0–255)
---@return boolean drawn True if the sprite was drawn this frame
Texture.drawSprite = function(dict, name, sx, sy, w, h, heading, r, g, b, a)
    if not HasStreamedTextureDictLoaded(dict) then
        RequestStreamedTextureDict(dict, false)
        return false
    end
    DrawSprite(dict, name, sx, sy, w, h, heading or 0.0, r or 255, g or 255, b or 255, a or 255)
    return true
end

_ENV.da_texture = Texture
