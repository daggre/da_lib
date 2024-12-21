cli.add_cmd("kvp", { desc = "KVP commands"})
cli.add_subcmd("kvp", "find", { desc = "Find KVP entries with given prefix",
    args = { "resource", "prefix" },
    fn = function(args)
        local keys = kvp.rsearch(args.resource, args.prefix)
        for _, key in ipairs(keys) do
            log.info(key)
        end
    end
})
cli.add_subcmd("kvp", "delete", { desc = "Remove KVP entry",
    args = { "resource", "key" },
    fn = function(args) TriggerEvent("kvp:delete", args.resource, args.key) end
})
cli.add_subcmd("kvp", "get", { desc = "Get KVP entry",
    args = { "resource", "key" },
    fn = function(args) log.info(kvp.rrawget(args.resource, args.key)) end
})
