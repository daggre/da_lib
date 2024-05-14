--- Copyright © 2024 Joshua Nelson

Lib = {}
Lib.API = {}
Lib.API.Active = "TMC"
Lib.API.TMC = {}
Lib.Anim = {}
Lib.Audio = {}
Lib.Cache = {}
Lib.Chance = {}
Lib.Check = {}
Lib.Control = {}
Lib.Draw = {}
Lib.Fn = {}
Lib.Fx = {}
Lib.Lock = {}
Lib.Log = {}
Lib.Net = {}
Lib.NPC = {}
Lib.Obj = {}
Lib.Prompt = {}
Lib.Prompt.Option = {}
Lib.Props = {}
Lib.String = {}
Lib.Time = {}
Lib.Util = {}
Lib.Zone = {}
Lib.PolyZone = {}

Lib.Util.IsDev = GetConvar("server_type", "DEV") == "DEV"

exports('importLib', function() return Lib; end)
