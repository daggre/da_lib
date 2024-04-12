local DrawActive = false
local DrawItems = { LineVert = {}, LineHoriz = {}, Text = {}, }

function DrawLineVert(coords, r)
    -- local color = vector4(255, 0, 255, 255)
    Citizen.InvokeNative(
        `DRAW_LINE` & 0xFFFFFFFF,
        coords.xyz,
        coords.xy, coords.z+r,
        255, 0, 255, 255
    )
end

function DrawLineHoriz(coords, r)
    local xTranslate, yTranslate = Lib.Util.TranslateCartesian(r, coords.w)
    Citizen.InvokeNative(
        `DRAW_LINE` & 0xFFFFFFFF,
        coords.xyz,
        coords.x + xTranslate, coords.y + yTranslate, coords.z,
        255, 0, 255, 255
    )
end

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

function DrawTextAtWorldCoord(coords, str)
    local _, screenX, screenY = GetScreenCoordFromWorldCoord(coords.x, coords.y, coords.z)
    if (screenX > 0 and screenX < 1) or (screenY > 0 and screenY < 1) then
        local _, screenX, screenY = GetHudScreenPositionFromWorldPosition(coords.x, coords.y, coords.z)
        DrawText(str, screenX, screenY)
    end
end

function Lib.Draw.LineVert(coords, height)
    ToggleDraw(true)
    table.insert(DrawItems.LineVert, { coords = coords, height = height })
end

function Lib.Draw.LineHoriz(coords, len)
    ToggleDraw(true)
    table.insert(DrawItems.LineHoriz, { coords = coords, length = len })
end

function Lib.Draw.Text(coords, str)
    ToggleDraw(true)
    table.insert(DrawItems.Text, { coords = coords, str = str })
end

function Lib.Draw.Disable() ToggleDraw(false); end
function Lib.Draw.Enable() ToggleDraw(true); end
function Lib.Draw.Toggle(state) ToggleDraw(state); end

function ToggleDraw(state)
    if state ~= nil and state == DrawActive then return; end
    DrawActive = not DrawActive
    if DrawActive then
        -- Enable draw
        Citizen.CreateThread(function()
            while DrawActive do
                for _, line in ipairs(DrawItems.LineVert) do
                    DrawLineVert(line.coords, line.height)
                end
                for _, line in ipairs(DrawItems.LineHoriz) do
                    DrawLineHoriz(line.coords, line.length)
                end
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
