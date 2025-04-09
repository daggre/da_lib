local netEntities = {}
local entityTypes = {}
NetEntity = {}
NetEntity.__index = NetEntity

function NetEntity:new(uid, data)
    local self = setmetatable({}, NetEntity)
    self.uid = uid
    self.type = data.type
    self.model = data.model
    self.range = data.range or 150
    self.coords = data.coords
    self.interactionPoints = {}
    self.interactions = {}
    return self
end

function NetEntity:onEnter()
    self:create()
    self:setupInteractions()
end

function NetEntity:onExit()
    self:remove()
    self:clearInteractions()
end

function NetEntity:create()
    log.debug("[NetEntity] Creating:", self.model, "at", self.coords)
    self.zone = zone.circle(self.coords, self.range, {
        enter = function() self:onEnter() end,
        exit = function() self:onExit() end
    })
end

function NetEntity:remove()
    log.debug("[NetEntity] Removing:", self.uid)
end

function NetEntity:addInteractionPoint(coords, interactionType, callback)
    table.insert(self.interactionPoints, { coords = coords, type = interactionType, callback = callback })
    self.interactions[interactionType] = callback
end

function NetEntity:setupInteractions()
    for _, point in ipairs(self.interactionPoints) do
        log.debug("[NetEntity] Interaction:", point.type, "at", point.coords)
    end
end

function NetEntity:clearInteractions()
    log.debug("[NetEntity] Clearing interactions for", self.uid)
end

function NetEntity:handleInteraction(interactionType)
    if self.interactions[interactionType] then
        self.interactions[interactionType]()
    end
end




-- Net Entity Types
--- TODO: Remove example type, define in other scripts

CraftingTable = setmetatable({}, { __index = NetEntity })

function CraftingTable:new(uid, data)
    local self = NetEntity.new(self, uid, data)

    -- Define an interaction point (e.g., front of the table)
    local interactionPos = vector3(data.coords.x, data.coords.y + 1.0, data.coords.z)
    self:addInteractionPoint(interactionPos, "open_crafting", function()
        self:openCraftingMenu()
    end)

    return self
end

function CraftingTable:openCraftingMenu()
    log.debug("[NetEntity][CraftingTable] Opening crafting menu for", self.uid)
end

entityTypes.crafting_table = CraftingTable


-- Net Entity Factory

_ENV.da_netent = {
    create = function(data) TriggerServerEvent("da_lib.netent.add", data) end,
    request = function() TriggerServerEvent("da_lib.netent.request") end
}

RegisterNetEvent("da_lib.netent.remove")
AddEventHandler("da_lib.netent.remove", function(uid)
    local netEntity = netEntities[uid]
    if not netEntity then
        return
    end
    netEntity:remove()
end)

RegisterNetEvent("da_lib.netent.sync")
AddEventHandler("da_lib.netent.sync", function(uid, data)
    if netEntities[uid] then
        return
    end
    local netEntity = entityTypes[data.type] and entityTypes[data.type]:new(uid, data) or NetEntity:new(uid, data)
    netEntities[uid] = netEntity
    netEntity:create()
end)

RegisterNetEvent("da_lib.netent.syncfull")
AddEventHandler("da_lib.netent.syncfull", function(data)
    for uid, entityData in pairs(data) do
        if not netEntities[uid] then
            local netEntity = entityTypes[entityData.type] and entityTypes[entityData.type]:new(uid, entityData) or NetEntity:new(uid, entityData)
            netEntities[uid] = netEntity
            netEntity:create()
        end
    end
end)
