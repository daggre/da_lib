--- Copyright © 2024 Joshua Nelson

Lib = {}
Lib.API = {}
Lib.API.TMC = {}
Lib.Anim = {}
Lib.Audio = {}
Lib.Cache = {}
Lib.Chance = {}
Lib.Check = {}
Lib.Control = {}
Lib.Data = {}
Lib.Draw = {}
Lib.Fn = {}
Lib.Fx = {}
Lib.Interact = {}
Lib.Lock = {}
Lib.Log = {}
Lib.Mode = {}
Lib.Net = {}
Lib.NPC = {}
Lib.Obj = {}
Lib.Prompt = {}
Lib.Prompt.Option = {}
Lib.Props = {}
Lib.Stats = {}
Lib.String = {}
Lib.Time = {}
Lib.Util = {}
Lib.Weapon = {}
Lib.Zone = {}
Lib.PolyZone = {}

Lib.Util.IsDev = GetConvar("server_type", "DEV") == "DEV"
Lib.API.Active = "TMC"

exports('importLib', function() return Lib; end)
