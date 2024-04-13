Lib = {}
Lib.API = {}
Lib.API.Active = "TMC"
Lib.API.TMC = {}
Lib.Audio = {}
Lib.Cache = {}
Lib.Draw = {}
Lib.Fn = {}
Lib.Lock = {}
Lib.Log = {}
Lib.Net = {}
Lib.Obj = {}
Lib.String = {}
Lib.Time = {}
Lib.Util = {}
Lib.Zone = {}
Lib.PolyZone = {}

Lib.Util.IsDev = GetConvar("server_type", "DEV") == "DEV"

exports('importLib', function() return Lib; end)
