--- Copyright © 2024 Joshua Nelson

local DrawActive = false
local DrawItems = { LineVert = {}, LineHoriz = {}, Text = {}, }

---Draw a vertical line in the world
---@param coords table The coordinates to draw the line at
---@param r integer The height of the line
function DrawLineVert(coords, r)
    -- local color = vector4(255, 0, 255, 255)
    Citizen.InvokeNative(
        `DRAW_LINE` & 0xFFFFFFFF,
        coords.xyz,
        coords.xy, coords.z+r,
        255, 0, 255, 255
    )
end

---Draw a horizontal line in the world
---@param coords table The coordinates to draw the line at
---@param r number The length of the line
function DrawLineHoriz(coords, r)
    -- Get the x and y translation using the length of the line and the heading
    local xTranslate, yTranslate = Lib.Util.TranslateCartesian(r, coords.w)
    Citizen.InvokeNative(
        `DRAW_LINE` & 0xFFFFFFFF,
        coords.xyz,
        coords.x + xTranslate, coords.y + yTranslate, coords.z,
        255, 0, 255, 255
    )
end

---Draw text on the screen
---@param str string The text to draw
---@param screenX number The x position on the screen
---@param screenY number The y position on the screen
function DrawText(str, screenX, screenY)
    local size = 0.2
    local alignCenter = true
    local font = 1
    local text = CreateVarString(10, "LITERAL_STRING", str)

    SetTextScale(1, size)
    SetTextColor(255, 255, 255, 255)
    SetTextCentre(alignCenter)
    SetTextDropshadow(1, 0, 0, 0, 255)
    SetTextFontForCurrentCommand(font)
    DisplayText(text, screenX, screenY)
end

---Draw text at a world coordinate
---@param coords table The coordinates to draw the text at
---@param str string The text to draw
function DrawTextAtWorldCoord(coords, str)
    -- Calculate the screen x and y position based on world coordinates
    local _, screenX, screenY = GetScreenCoordFromWorldCoord(coords.x, coords.y, coords.z)
    if (screenX > 0 and screenX < 1) or (screenY > 0 and screenY < 1) then
        local _, screenX, screenY = GetHudScreenPositionFromWorldPosition(coords.x, coords.y, coords.z)
        DrawText(str, screenX, screenY)
    end
end

---Add a vertical line to the draw list
---@param coords table The coordinates to draw the line at
---@param height number The height of the line
function Lib.Draw.LineVert(coords, height)
    ToggleDraw(true)
    table.insert(DrawItems.LineVert, { coords = coords, height = height })
end

---Add a horizontal line to the draw list
---@param coords table The coordinates to draw the line at
---@param len number The length of the line
function Lib.Draw.LineHoriz(coords, len)
    ToggleDraw(true)
    table.insert(DrawItems.LineHoriz, { coords = coords, length = len })
end

---Add text to the draw list
---@param coords table The coordinates to draw the text at
---@param str string The text to draw
function Lib.Draw.Text(coords, str)
    ToggleDraw(true)
    table.insert(DrawItems.Text, { coords = coords, str = str })
end

---Disable the draw thread
function Lib.Draw.Disable() ToggleDraw(false); end
--- Enable the draw thread
function Lib.Draw.Enable() ToggleDraw(true); end
---Toggle the draw thread
---@param state boolean The state to toggle to
function Lib.Draw.Toggle(state) ToggleDraw(state); end

---Toggle the draw thread
---@param state boolean The state to toggle to
function ToggleDraw(state)
    -- If the state is the same as the current state, return
    if state ~= nil and state == DrawActive then return; end
    -- Toggle the state
    DrawActive = not DrawActive

    if DrawActive then
        -- Activate the draw thread
        Citizen.CreateThread(function()
            -- Draw all the items in the draw list
            while DrawActive do
                -- Draw all the vertical lines in the draw list
                for _, line in ipairs(DrawItems.LineVert) do
                    DrawLineVert(line.coords, line.height)
                end
                -- Draw all the horizontal lines in the draw list
                for _, line in ipairs(DrawItems.LineHoriz) do
                    DrawLineHoriz(line.coords, line.length)
                end
                -- Draw all the text in the draw list
                for _, text in ipairs(DrawItems.Text) do
                    DrawTextAtWorldCoord(text.coords, text.str)
                end
                Citizen.Wait(0)
            end
        end)
    else
        -- Disable draw
        DrawItems = { LineVert = {}, LineHoriz = {}, Text = {}, }
    end
end
