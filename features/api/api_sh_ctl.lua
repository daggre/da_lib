DAAPI = {}
DAAPI.ActiveFramework = GetConvar("framework", "Default")
DAAPI.Framework = {}
DAAPI.Default = {}

exports('importAPI', function() return DAAPI; end)
