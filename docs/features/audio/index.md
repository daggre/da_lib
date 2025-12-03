# Audio System

The Audio module provides functionality for playing audio streams from entities in RedM. It supports both client-side playing and server-synchronized audio playback.

## Features

- Play audio streams from specific entities
- Network-synchronized audio playback
- Stop audio streams when no longer needed
- Server-to-client audio coordination

## API Reference

### Client-Side Audio

```lua
da_audio.play(entity, streamName, soundSet)
```
- `entity` (number): Entity handle to play the sound from
- `streamName` (string): Name of the audio stream to play
- `soundSet` (string/number): Sound set the stream belongs to (automatically converted to string)

**Note**: Keep a reference to the entity if you need to stop the stream later.

```lua
da_audio.stop(entity)
```
- `entity` (number): Entity handle to stop the audio stream on

### Server-Side Events

```lua
-- Trigger from client or server
TriggerServerEvent("da_lib.audio.playStream", netId, streamName, soundSet)
```
- `netId` (number): Network ID of the entity
- `streamName` (string): Name of the audio stream to play
- `soundSet` (string/number): Sound set the stream belongs to

```lua
-- Trigger from client or server
TriggerServerEvent("da_lib.audio.stopStream", netId)
```
- `netId` (number): Network ID of the entity to stop audio on

## Examples

### Playing Client-Side Audio

```lua
-- Play a stream from the player's ped
local playerPed = PlayerPedId()
da_audio.play(playerPed, "MUSIC_STOP", "RDRO_Music_Moonshiner_Cripps")

-- Stop the stream after 10 seconds
Citizen.SetTimeout(10000, function()
    da_audio.stop(playerPed)
end)
```

### Network-Synchronized Audio

```lua
-- Client script: Play a sound from an object that all players can hear
RegisterCommand('playmusic', function()
    local phonograph = GetClosestObjectOfType(coords.x, coords.y, coords.z, 5.0,
        GetHashKey("p_phonograph01x"), false, false, false)

    if phonograph ~= 0 then
        local netId = NetworkGetNetworkIdFromEntity(phonograph)
        TriggerServerEvent("da_lib.audio.playStream", netId, "MUSIC_STOP", "RDRO_Music_Moonshiner_Cripps")
        print("Playing music from phonograph")
    end
end)

-- Client script: Stop the music
RegisterCommand('stopmusic', function()
    local phonograph = GetClosestObjectOfType(coords.x, coords.y, coords.z, 5.0,
        GetHashKey("p_phonograph01x"), false, false, false)

    if phonograph ~= 0 then
        local netId = NetworkGetNetworkIdFromEntity(phonograph)
        TriggerServerEvent("da_lib.audio.stopStream", netId)
        print("Stopping music")
    end
end)
```

### Server-Side Audio Control

```lua
-- Server script: Play sound for all players from an entity
RegisterCommand('playmusic', function(source, args)
    local player = source
    local ped = GetPlayerPed(player)
    local netId = NetworkGetNetworkIdFromEntity(ped)

    local streamName = args[1] or "MUSIC_STOP"
    local soundSet = args[2] or "RDRO_Music_Moonshiner_Cripps"

    TriggerClientEvent("da_lib.audio.playStream", -1, netId, streamName, soundSet)
end, true)
```

### Managing Multiple Audio Streams

```lua
-- Play different streams from different entities
local campfire = GetClosestObjectOfType(coords.x, coords.y, coords.z, 5.0,
    GetHashKey("p_campfire02x"), false, false, false)
local phonograph = GetClosestObjectOfType(coords.x, coords.y, coords.z, 5.0,
    GetHashKey("p_phonograph01x"), false, false, false)

-- Track the entities to stop streams later
da_audio.play(campfire, "CAMPFIRE_LIGHT", "CAMPFIRE_SOUNDS")
da_audio.play(phonograph, "PIANO_PLAYER_IDLE_02", "SALOON_MUSIC")

-- Stop specific streams using the entity handles
function stopCampfireSound()
    da_audio.stop(campfire)
end

function stopMusicSound()
    da_audio.stop(phonograph)
end
```

## Implementation Notes

- The audio system uses RedM's native streaming audio functions
- Streams are identified and managed by stream IDs and network IDs
- Network-synchronized audio is managed internally with a table of active streams
- Stream loading has a timeout mechanism (100 tries) to prevent infinite loading
- Audio streams play directly from entities, allowing for spatial positioning
- When a stream is played on an entity that already has a stream, the previous stream is automatically stopped
- Debug information is logged at the spam log level
