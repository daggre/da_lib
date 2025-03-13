# Drawing System

The Draw module provides a collection of utilities for rendering visual elements in the 3D world and on the screen in RedM. It includes functions for drawing shapes, lines, bounding boxes, and text.

## Features

- 3D shape rendering (spheres, cylinders)
- Line drawing in 3D space (vertical, horizontal, custom)
- Entity bounding box visualization
- 3D text rendering in world space
- Screen text display with customization options
- Math utilities for rotation and transformation

## API Reference

### Shapes

```lua
DrawSphere(position, radius, color)
```
- `position` (vector3): Position to draw the sphere
- `radius` (number): Radius of the sphere
- `color` (table): Color with r, g, b, a components

```lua
DrawCylinder(position, radius, height, color)
```
- `position` (vector3): Position to draw the cylinder
- `radius` (number): Radius of the cylinder
- `height` (number): Height of the cylinder
- `color` (table): Color with r, g, b, a components

### Lines

```lua
DrawLine(startPos, endPos, r, g, b, a)
```
- `startPos` (vector3): Starting position of the line
- `endPos` (vector3): Ending position of the line
- `r`, `g`, `b`, `a` (number): Color components (0-255)

```lua
DrawHLine(radius, position, [color])
```
- `radius` (number): Length of the horizontal line
- `position` (vector3): Starting position
- `color` (table, optional): Color with r, g, b, a components (default: white)

```lua
DrawVLine(height, position, [color])
```
- `height` (number): Height of the vertical line
- `position` (vector3): Starting position
- `color` (table, optional): Color with r, g, b, a components (default: white)

### Bounding Boxes

```lua
DrawBB(object, [color])
```
- `object` (number): Entity handle to draw bounding box around
- `color` (table, optional): Color with r, g, b, a components (default: white)

### Text

```lua
DrawText(text, position, [color], [size])
```
- `text` (string): Text to display
- `position` (vector3): World position for the text
- `color` (table, optional): Color with r, g, b, a components (default: white)
- `size` (number, optional): Text size (default: 0.2)

```lua
DrawScreenText(text, screenX, screenY, [color], [size])
```
- `text` (string): Text to display
- `screenX`, `screenY` (number): Screen coordinates (0.0-1.0)
- `color` (table, optional): Color with r, g, b, a components (default: white)
- `size` (number, optional): Text size (default: 0.2)

## Examples

### Drawing Shapes

```lua
-- Draw a red sphere at player's position
Citizen.CreateThread(function()
    while true do
        local playerPos = GetEntityCoords(PlayerPedId())

        -- Draw a sphere with radius 1.0 and red color
        DrawSphere(playerPos, 1.0, {r = 255, g = 0, b = 0, a = 100})

        -- Draw a blue cylinder
        local cylinderPos = playerPos + vector3(0, 0, -1.0)
        DrawCylinder(cylinderPos, 0.5, 2.0, {r = 0, g = 0, b = 255, a = 100})

        Citizen.Wait(0)
    end
end)
```

### Drawing Lines

```lua
-- Draw connecting lines between points of interest
Citizen.CreateThread(function()
    local points = {
        vector3(100.0, 200.0, 50.0),
        vector3(110.0, 210.0, 50.0),
        vector3(120.0, 200.0, 50.0),
        vector3(110.0, 190.0, 50.0)
    }

    while true do
        -- Draw lines connecting all points
        for i = 1, #points do
            local nextIdx = i % #points + 1
            DrawLine(points[i], points[nextIdx], 255, 255, 0, 255)
        end

        -- Draw vertical marker at first point
        DrawVLine(5.0, points[1], {r = 0, g = 255, b = 0, a = 255})

        Citizen.Wait(0)
    end
end)
```

### Drawing Bounding Boxes

```lua
-- Draw bounding boxes around nearby objects
Citizen.CreateThread(function()
    while true do
        local playerPos = GetEntityCoords(PlayerPedId())

        -- Find objects within 5 meters
        local objects = GetGamePool("CObject")
        for _, obj in ipairs(objects) do
            local objPos = GetEntityCoords(obj)
            local dist = #(playerPos - objPos)

            if dist < 5.0 then
                -- Draw red bounding box around close objects
                DrawBB(obj, {r = 255, g = 0, b = 0, a = 255})

                -- Draw object name above it
                local height = objPos.z + 1.0
                local textPos = vector3(objPos.x, objPos.y, height)
                DrawText("Object: " .. obj, textPos, {r = 255, g = 255, b = 255, a = 255}, 0.15)
            end
        end

        Citizen.Wait(0)
    end
end)
```

### Drawing Text

```lua
-- Display text on screen and in the world
Citizen.CreateThread(function()
    while true do
        -- Display text on screen at top-right corner
        DrawScreenText("Current Time: " .. GetGameTimer(), 0.9, 0.1, {r = 255, g = 255, b = 255, a = 255}, 0.3)

        -- Display text above player
        local playerPos = GetEntityCoords(PlayerPedId())
        local textPos = playerPos + vector3(0, 0, 1.0)
        DrawText("Player Name", textPos, {r = 255, g = 255, b = 0, a = 255}, 0.25)

        Citizen.Wait(0)
    end
end)
```

## Implementation Notes

- All drawing functions must be called every frame (in a loop with Citizen.Wait(0))
- Screen coordinates range from 0.0 to 1.0, with (0,0) at top-left and (1,1) at bottom-right
- Text drawing checks if coordinates are on screen before rendering
- The bounding box calculation uses entity dimensions and rotation matrix
- Colors are specified as tables with r, g, b, a components ranging from 0 to 255
- All 3D drawing is only visible within certain render distances
- Performance impact increases with the number of rendered elements
