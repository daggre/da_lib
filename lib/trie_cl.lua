local Menu = {}
local Option = {}
local Trie = {}

Trie.add = function(parent, name, key)
    if not Menu[parent] then
        Menu[parent] = {}
    end

    for menu, menuData in pairs(Menu[parent]) do
        if menuData.key == key then
            log.error(("Duplicate key '%s' in %s: key assigned to '%s'. %s"):format(key, name, menu, log.line(2)))
            return false
        end
    end

    Menu[parent][name] = { key = key }
    Menu[name] = {}
    return true
end

Trie.addOpt = function(parent, name, key, fn, condition)
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

    Option[parent][name] = { key = key, fn = fn, condition = condition }
    return true
end

Trie.addRoot = function(name)
    if not Menu[name] then
        Menu[name] = {}
        return true
    end
    return false
end

Trie.get = function(name)
    if not Menu[name] then
        log.error(("Menu '%s' does not exist. %s"):format(name, log.line(2)))
        return nil
    end
    local tree = {}

    tree.name = name
    tree.options = Trie.getOpt(name)
    tree.submenus = {}
    for submenu, submenuData in pairs(Menu[name]) do
        table.insert(tree.submenus, {
            name = submenu,
            key = submenuData.key,
        })
    end
    table.sort(tree.submenus, function(a,b) return a.key < b.key end)

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
            })
        end
    end

    if options and next(options) then
        table.sort(options, function(a,b) return a.key < b.key end)
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
