local Command = {}
local CLI = {}
CLI.version = 0.1

local exists = function(path)
	return Command[path] ~= nil
end

local init_cmd = function(data)
	local c = {}

	assert(data and data.desc, "desc invalid: Description is required.")
	c.desc = data.desc
	c.args = data.args or {}
	c.subcmd = data.subcmd or {}
	c.opt = data.opt or {}
    c.short = {}


    if c.opt and next(c.opt) then
        for opt, optData in pairs(c.opt) do
            if not optData.short then
                optData.short = opt:sub(1,1)
            end
            c.short[optData.short] = opt
        end
    end

	c.fn = data.fn

	return c
end

local usage = function(cmd)
	local data = Command[cmd]
	if not data then
		log.error(("Command '%s' does not exist. %s"):format(cmd, log.line(1)))
		return
	end

    local desc = "\nDescription: " .. data.desc

    local subcmd_desc = ""
    if #data.subcmd > 0 then
        table.sort(data.subcmd)
        subcmd_desc = "\nCommands:"
        for _, subcmd in pairs(data.subcmd) do
            local desc = nil
            desc = Command[cmd .. " " .. subcmd].desc
            if not desc then
                log.error(
                    ("Sub command '%s' has invalid description. %s"):format(cmd .. " " .. subcmd, log.line(1))
                )
                return
            end
            subcmd_desc = subcmd_desc .. "\n  " .. subcmd .. "\t\t" .. desc
        end
    end

	local opt_desc = ""
	local sorted_opt = {}
	for opt in pairs(data.opt) do
		table.insert(sorted_opt, opt)
	end
    table.sort(sorted_opt)
    opt_desc = "\nOptions:"
	for _, opt in pairs(sorted_opt) do
		local optData = data.opt[opt]
		if not optData then
			log.error(("Option '%s' does not exist. %s"):format(cmd .. " " .. opt, log.line(1)))
			return
		end
		opt_desc = opt_desc .. "\n  -" .. optData.short .. " " .. opt .. "\t\t" .. optData.desc
	end

	local usage = "Usage: " .. cmd
	if #data.subcmd > 0 then
		usage = usage .. " [command]"
	end

    if data.opt and next(data.opt) then
        usage = usage .. " [options]"
    end

    if data.args and next(data.args) then
        for _, arg in pairs(data.args) do
            usage = usage .. " [" .. arg .. "]"
        end
    end

	log.info(usage .. desc .. subcmd_desc .. opt_desc)
end

local load_cmd = function(cmd, data)
	if not data then
		log.error(("Command '%s' does not exist. %s"):format(cmd, log.line(1)))
		return false
	end

	RegisterCommand(cmd, function(source, args, rawCommand)
		local path = cmd
		local argData = {}
		while #args > 0 do
			if exists(path .. " " .. args[1]) then
				path = path .. " " .. args[1]
				table.remove(args, 1)
			else
				break
			end
		end

		if #args == 0 and not Command[path].fn then
			usage(path)
			return
		end

        while #args > 0 do
            -- Check if it is an option
            if args[1]:sub(1,1) ~= "-" then break end
            local opt = nil
            if args[1]:sub(1,2) == "--" then
                opt = args[1]:sub(3)
            else
                for i=2, #args[1] do
                    if Command[path].short[args[1]:sub(i,i)] then
                        opt = Command[path].short[args[1]:sub(i,i)]
                        if Command[path].opt[opt].bool then
                            argData[opt] = true
                            if i == #args[1] then
                                table.remove(args, 1)
                                break
                            end
                        else
                            if i ~= #args[1] then
                                log.warn(("Command '%s' option missing argument: %s"):format(path, opt))
                                usage(path)
                                return
                            end
                        end
                    end
                end
            end
            if not Command[path].opt[opt] then
                log.warn(("Command '%s' given invalid option: %s"):format(path, opt))
                usage(path)
                return
            end
            table.remove(args, 1)
            if not args[1] then
                log.warn(("Command '%s' missing argument for option %s."):format(path, opt))
                usage(path)
                return
            end
            argData[opt] = args[1]
            table.remove(args, 1)
        end

		local req_args = Command[path].args
		for _, req_arg in ipairs(req_args) do
			if not args[1] then
				log.warn(("Command '%s' missing argument %s."):format(path, req_arg))
                usage(path)
				return
			end
			argData[req_arg] = args[1]
			table.remove(args, 1)
		end

        if #args > 0 then
            log.warn(("Command '%s' given invalid argument: %s"):format(path, args[1]))
            usage(path)
            return
        end

		Command[path].fn(argData)
	end, false)

	log.spam(("CLI command '%s' registered."):format(cmd))
end

CLI.add_cmd = function(cmd, uninit_data)
	if exists(cmd) then
		log.warn(("Command '%s' already exists. %s"):format(cmd, log.line(1)))
		return false
	end
	local data = init_cmd(uninit_data)
	Command[cmd] = data
	load_cmd(cmd, data)
	return true
end

CLI.add_subcmd = function(path, cmd, uninit_data)
	local fullpath = path .. " " .. cmd
	if exists(fullpath) then
		log.warn(("Sub command '%s' already exists. %s"):format(fullpath, log.line(1)))
		return false
	end
	local data = init_cmd(uninit_data)
	Command[fullpath] = data
	if #Command[path].subcmd == 0 then
		table.insert(Command[path].subcmd, "help")
        Command[path .. " help"] = init_cmd({
            desc = "Display this help message.",
            fn = function() usage(path) end,
        })
	end
	table.insert(Command[path].subcmd, cmd)
	return true
end

if _ENV.cli == nil or _ENV.cli.version < CLI.version then _ENV.cli = CLI end

cli.add_cmd("da", { desc = "da resources", })
cli.add_subcmd("da", "log", { desc = "Adjust log settings." })
cli.add_subcmd("da log", "get", {
    desc = "Display the resource log level",
    args = { "resource", },
    fn = function(args) TriggerEvent("da_log:getLevel", args.resource) end,
})
cli.add_subcmd("da log", "set", {
    desc = "Adjust resource log.",
    args = { "resource", "level", },
    fn = function(args) TriggerEvent("da_log:setLevel", args.resource, args.level) end,
})
