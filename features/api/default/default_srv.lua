log.debug("Initializing Framework API Server Defaults")

-- Default adapter (server): the graceful-degradation base. Enumerates the full
-- server API contract explicitly. Functions split into two kinds:
--   * standalone-meaningful — a real answer when no framework is installed
--   * no-op — framework-specific effects (inventory, skills) go nowhere
local FW = {}

-- Standalone-meaningful --
---@diagnostic disable-next-line: duplicate-set-field
FW.notify = function(src, message, notifyType, duration)
    log.info({
        src = src,
        message = message,
        notifyType = notifyType,
        duration = duration,
    })
    TriggerClientEvent("notify", src, message, notifyType, duration)
end

FW.createUseableItem = function() return true end

---@diagnostic disable-next-line: duplicate-set-field
FW.hasJob = function(src, job, active) return true end

FW.minPolice = function(minAmount, active) return true end

FW.isCrimeAllowed = function() return true end

-- No character system: assume masculine so character-gated content still picks an animation.
FW.isCharMale = function(src) return true end

-- No-op (info goes nowhere without a framework) --
FW.removeItem = function(src, itemName, amount, slot, slotIndex, isInternalMove) return false end
FW.addItem = function(src, itemName, amount, slot, slotIndex, isInternalMove) return nil end
FW.consumeCharge = function(src, name, slot, index, info) return nil end
FW.setItemMetadata = function(src, itemData, metadata) return nil end
FW.addSkill = function(src, skill, amount) return nil end
FW.setSkill = function(src, skill, amount) return nil end

DAAPI.Default = FW
