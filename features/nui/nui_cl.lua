local NUI = {}

NUI.callback = function(n, fn)
    RegisterNUICallback(n, function(d,cb)
        cb(fn(d))
    end)
end

NUI.event = function(n, fn)
    RegisterNUICallback(n, function(d, cb)
        cb({})
        fn(d)
    end)
end

NUI.send = function(n, d)
    d = d or {}
    d.type = n
    SendNUIMessage(d)
end

NUI.encode = function(n, d)
    d = d or {}
    d.type = n
    SendNUIMessage(json.encode(d))
end

NUI.callbacks = function(a)
    for n, fn in pairs(a) do
        NUI.callback(n, fn)
    end
end

NUI.events = function(a)
    for n, fn in pairs(a) do
        NUI.event(n, fn)
    end
end

_ENV.da_ui = NUI
