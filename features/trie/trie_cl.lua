local Menu = {}
local Option = {}
local Trie = {}

-- A node's label lives in its PARENT's entry (that's where `add` puts it), which is exactly the one
-- place `get(name)` can't reach — it walks DOWN from a node and never learns who pointed at it. So
-- the label is also recorded here, keyed by node, and `get` can title the node the player is
-- actually looking at instead of falling back to its id.
local Label = {}

-- `condition` and `label` are optional and positional-compatible with the original signature.
-- A submenu's condition gates the whole subtree (a `smoke` folder should not appear when you have
-- no cigarettes); `label` is the human-facing text when the node's name is an id.
Trie.add = function(parent, name, key, condition, label)
    if not Menu[parent] then
        Menu[parent] = {}
    end

    for menu, menuData in pairs(Menu[parent]) do
        if menuData.key == key then
            log.error(("Duplicate key '%s' in %s: key assigned to '%s'. %s"):format(key, name, menu, log.line(2)))
            return false
        end
    end

    Menu[parent][name] = { key = key, condition = condition, label = label }
    Menu[name] = Menu[name] or {}
    Label[name] = label
    return true
end

Trie.addOpt = function(parent, name, key, fn, condition, label)
    if not Menu[parent] then
        log.error(("Menu '%s' does not exist. %s"):format(parent, log.line(2)))
        return false
    end

    for menu, menuData in pairs(Menu[parent]) do
        if menuData.key == key then
            log.error(("Duplicate key '%s' in %s: key assigned to '%s'. %s"):format(key, name, menu, log.line(2)))
            return false
        end
    end

    if not Option[parent] then
        Option[parent] = {}
    end

    for option, optionData in pairs(Option[parent]) do
        if optionData.key == key then
            if not condition or not optionData.condition then
                log.error(("Duplicate key '%s' in %s: key assigned to '%s'. %s"):format(key, name, option, log.line(2)))
                return false
            end
            log.spam(("Duplicate key '%s' in %s: key conditionally assigned to '%s'. %s"):format(key, name, option, log.line(2)))
        end
    end

    Option[parent][name] = { key = key, fn = fn, condition = condition, label = label }
    return true
end

-- Drop a whole subtree — the node, its options, and every descendant. Used when a resource rebuilds
-- its menu from scratch.
--
-- It has to RECURSE. Clearing only the root leaves each submenu's option table intact, so a
-- rebuild that deliberately omits an option still shows it: the stale entry from the previous
-- build is sitting under the submenu, and addOpt overwrites by name but never removes.
Trie.clear = function(name)
    local children = {}
    for child in pairs(Menu[name] or {}) do children[#children + 1] = child end

    Menu[name] = nil
    Option[name] = nil
    Label[name] = nil
    for _, child in ipairs(children) do Trie.clear(child) end
    for _, kids in pairs(Menu) do kids[name] = nil end
end

-- A root has no parent to carry its label, so it takes one directly. Optional: a caller that passes
-- nothing gets the old behaviour, the node's id as its title.
Trie.addRoot = function(name, label)
    Label[name] = label
    if not Menu[name] then
        Menu[name] = {}
        return true
    end
    return false
end

-- `opts.prune` builds the tree RECURSIVELY, evaluates each submenu's condition, and drops any
-- submenu left with no options and no surviving submenus. Without it a conditioned menu shows empty
-- folders that do nothing when you open them.
--
-- Off by default: da_dev drives this trie too and expects the original shallow, unpruned shape.
Trie.get = function(name, opts)
    if not Menu[name] then
        log.error(("Menu '%s' does not exist. %s"):format(name, log.line(2)))
        return nil
    end
    opts = opts or {}

    local tree = { name = name, label = Label[name], options = Trie.getOpt(name), submenus = {} }

    for submenu, submenuData in pairs(Menu[name]) do
        local allowed = (not opts.prune)
            or not submenuData.condition
            or submenuData.condition()

        if allowed then
            local node = { name = submenu, key = submenuData.key, label = submenuData.label }

            if opts.prune then
                local child = Trie.get(submenu, opts)
                node.options  = child and child.options
                node.submenus = child and child.submenus
                -- Prune: an empty folder is not a choice, it's a dead end.
                if (node.options and #node.options > 0)
                    or (node.submenus and #node.submenus > 0) then
                    table.insert(tree.submenus, node)
                end
            else
                table.insert(tree.submenus, node)
            end
        end
    end
    table.sort(tree.submenus, function(a, b) return (a.key or "") < (b.key or "") end)

    return tree
end

Trie.getOpt = function(name)
    if not Option[name] then
        return nil
    end
    local options = {}
    for option, optionData in pairs(Option[name]) do
        if not optionData.condition or optionData.condition() then
            table.insert(options, {
                name = option,
                key = optionData.key,
                label = optionData.label,
            })
        end
    end

    if options and next(options) then
        table.sort(options, function(a,b) return (a.key or "") < (b.key or "") end)
        return options
    end

    return nil
end

Trie.run = function(parent, name, params)
    if not Option[parent] then
        log.error(("Menu '%s' does not exist. %s"):format(parent, log.line(2)))
        return false
    end

    if not Option[parent][name] then
        log.error(("Option '%s' does not exist in menu '%s'. %s"):format(name, parent, log.line(2)))
        return false
    end

    Option[parent][name].fn(params)
end

_ENV.da_trie = Trie
