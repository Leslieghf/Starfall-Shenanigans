local Manual = {}

Manual.HeldEntities = {}
Manual.WasActive = false

local function keyFor(ent)
    if not ent or not ent:isValid() then return nil end
    return ent:entIndex()
end

function Manual.isControlledPart(ent, props)
    return ent and ent:isValid() and props.isPhysicalProp(ent)
end

function Manual.pickup(ent)
    local key = keyFor(ent)
    if not key then return end

    Manual.HeldEntities[key] = true
end

function Manual.drop(ent)
    local key = keyFor(ent)
    if key then
        Manual.HeldEntities[key] = nil
    end
end

function Manual.clear(ent)
    local key = keyFor(ent)
    if key then
        Manual.HeldEntities[key] = nil
    end
end

function Manual.clearAll()
    Manual.HeldEntities = {}
    Manual.WasActive = false
end

function Manual.isActive()
    return next(Manual.HeldEntities) ~= nil
end

function Manual.consumeEndedTransition(active)
    local ended = Manual.WasActive and not active
    Manual.WasActive = active
    return ended
end

return Manual
